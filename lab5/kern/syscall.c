/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>
#include <inc/elf.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/syscall.h>
#include <kern/console.h>
#include <kern/sched.h>

// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void
sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
    user_mem_assert(curenv, (void *)s, len, PTE_U);
    
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
}

// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
}

// Destroy a given environment (possibly the currently running environment).
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	env_destroy(e);
	return 0;
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
}

// Allocate a new environment.
// Returns envid of new environment, or < 0 on error.  Errors are:
//	-E_NO_FREE_ENV if no free environment is available.
//	-E_NO_MEM on memory exhaustion.
static envid_t
sys_exofork(void)
{
	// Create the new environment with env_alloc(), from kern/env.c.
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env * new_env;
	int r = env_alloc(&new_env, curenv->env_id);
	if (r < 0) return r;
	
	new_env->env_status = ENV_NOT_RUNNABLE;
	memcpy((void *)(&new_env->env_tf), (void*)(&curenv->env_tf), sizeof(struct Trapframe));
	
	// for children environment, return 0
	new_env->env_tf.tf_regs.reg_eax = 0;

	return new_env->env_id;

	panic("sys_exofork not implemented");
}

// Set envid's env_status to status, which must be ENV_RUNNABLE
// or ENV_NOT_RUNNABLE.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if status is not a valid status for an environment.
static int
sys_env_set_status(envid_t envid, int status)
{
	// Hint: Use the 'envid2env' function from kern/env.c to translate an
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.
	// LAB 4: Your code here.

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) 
		return -E_INVAL;

	struct Env * env;
	int r = envid2env(envid, &env, 1);
	if (r < 0) return r;
	env->env_status = status;
	return 0;
}

// Set envid's trap frame to 'tf'.
// tf is modified to make sure that user environments always run at code
// protection level 3 (CPL 3) with interrupts enabled.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env * env;
	int r = envid2env(envid, &env, 1);
	if (r < 0) return -E_BAD_ENV;	

	user_mem_assert (env, tf, sizeof(struct Trapframe), PTE_U);

	env->env_tf = *tf;
	env->env_tf.tf_cs |= 3;
	env->env_tf.tf_eflags |= FL_IF;

	return 0;
}

// Set the page fault upcall for 'envid' by modifying the corresponding struct
// Env's 'env_pgfault_upcall' field.  When 'envid' causes a page fault, the
// kernel will push a fault record onto the exception stack, then branch to
// 'func'.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	// cprintf("In kernel sys_env_set_pgfault_upcall function\n");
	struct Env * env;
	int r = envid2env(envid, &env, 1);
	if (r < 0) return r;

	env->env_pgfault_upcall = func;
	return 0;
}

// Allocate a page of memory and map it at 'va' with permission
// 'perm' in the address space of 'envid'.
// The page's contents are set to 0.
// If a page is already mapped at 'va', that page is unmapped as a
// side effect.
//
// perm -- PTE_U | PTE_P must be set, PTE_AVAIL | PTE_W may or may not be set,
//         but no other bits may be set.  See PTE_SYSCALL in inc/mmu.h.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
//	-E_INVAL if perm is inappropriate (see above).
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	// Hint: This function is a wrapper around page_alloc() and
	//   page_insert() from kern/pmap.c.
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!
	// LAB 4: Your code here.
	// cprintf("In kernel sys_page_alloc function\n");

	struct Env * env;
	int r = envid2env(envid, &env, 1);
	if (r < 0) return -E_BAD_ENV;

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
	
	if (!((perm & PTE_U) && (perm & PTE_P) && (perm & (~PTE_SYSCALL))==0)) return -E_INVAL;

	struct PageInfo * pg = page_alloc(ALLOC_ZERO);
	if (pg == NULL) return -E_NO_MEM;
	if (page_insert(env->env_pgdir, pg, va, perm) < 0) {
		// page_insert fails, should free the page you allocated!  
		page_free(pg);
		return -E_NO_MEM;
	}
	return 0;
}

// Map the page of memory at 'srcva' in srcenvid's address space
// at 'dstva' in dstenvid's address space with permission 'perm'.
// Perm has the same restrictions as in sys_page_alloc, except
// that it also must not grant write access to a read-only
// page.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
//		or the caller doesn't have permission to change one of them.
//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
//		or dstva >= UTOP or dstva is not page-aligned.
//	-E_INVAL is srcva is not mapped in srcenvid's address space.
//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
//		address space.
//	-E_NO_MEM if there's no memory to allocate any necessary page tables.
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
	// Hint: This function is a wrapper around page_lookup() and
	//   page_insert() from kern/pmap.c.
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
	// LAB 4: Your code here.

	struct Env * dstenv, * srcenv;
	int r = envid2env(dstenvid, &dstenv, 1);
	if (r < 0) return -E_BAD_ENV;
	r = envid2env(srcenvid, &srcenv, 1);
	if (r < 0) return -E_BAD_ENV;

	if ((uint32_t)srcva >= UTOP || ROUNDUP(srcva, PGSIZE) != srcva) return -E_INVAL;
	if ((uint32_t)dstva >= UTOP || ROUNDUP(dstva, PGSIZE) != dstva) return -E_INVAL;


	// struct PageInfo * page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
	struct PageInfo * pg;
	pte_t * pte;
	pg = page_lookup(srcenv->env_pgdir, srcva, &pte);
	if (pg == NULL) return -E_INVAL;		

	if (!((perm & PTE_U) && (perm & PTE_P) && (perm & (~PTE_SYSCALL))==0)) return -E_INVAL;
	
	if ((perm & PTE_W) && ((*pte) & PTE_W) == 0) return -E_INVAL;

	// int page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	if (page_insert(dstenv->env_pgdir, pg, dstva, perm) < 0) return -E_NO_MEM;
	
	return 0;
}

// Unmap the page of memory at 'va' in the address space of 'envid'.
// If no page is mapped, the function silently succeeds.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().
	// LAB 4: Your code here.

	struct Env * env;
	int r = envid2env(envid, &env, 1);
	if (r < 0) return -E_BAD_ENV;

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
	
	// void page_remove(pde_t *pgdir, void *va)
	page_remove(env->env_pgdir, va);

	return 0;
}

// Try to send 'value' to the target env 'envid'.
// If srcva < UTOP, then also send page currently mapped at 'srcva',
// so that receiver gets a duplicate mapping of the same page.
//
// The send fails with a return value of -E_IPC_NOT_RECV if the
// target is not blocked, waiting for an IPC.
//
// The send also can fail for the other reasons listed below.
//
// Otherwise, the send succeeds, and the target's ipc fields are
// updated as follows:
//    env_ipc_recving is set to 0 to block future sends;
//    env_ipc_from is set to the sending envid;
//    env_ipc_value is set to the 'value' parameter;
//    env_ipc_perm is set to 'perm' if a page was transferred, 0 otherwise.
// The target environment is marked runnable again, returning 0
// from the paused sys_ipc_recv system call.  (Hint: does the
// sys_ipc_recv function ever actually return?)
//
// If the sender wants to send a page but the receiver isn't asking for one,
// then no page mapping is transferred, but no error occurs.
// The ipc only happens when no errors occur.
//
// Returns 0 on success, < 0 on error.
// Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist.
//		(No need to check permissions.)
//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
//		or another environment managed to send first.
//	-E_INVAL if srcva < UTOP but srcva is not page-aligned.
//	-E_INVAL if srcva < UTOP and perm is inappropriate
//		(see sys_page_alloc).
//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's
//		address space.
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
//		current environment's address space.
//	-E_NO_MEM if there's not enough memory to map srcva in envid's
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	
	// Any environment is allowed to send IPC messages to any other environment, 
	// and the kernel does no special permission checking other than verifying that the target envid is valid.
	// So set the checkperm falg to 0
	struct Env * env;
	int r = envid2env(envid, &env, 0);	
	//	-E_BAD_ENV if environment envid doesn't currently exist.
	if (r < 0) return -E_BAD_ENV;

	//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
	//		or another environment managed to send first.
	if (env->env_ipc_recving == false || env->env_ipc_from != 0) {
		return -E_IPC_NOT_RECV;
	}

	//	-E_INVAL if srcva < UTOP but srcva is not page-aligned.
	if ((uint32_t)srcva < UTOP && ROUNDUP(srcva, PGSIZE) != srcva)
		return -E_INVAL;

	//	-E_INVAL if srcva < UTOP and perm is inappropriate
	if ((uint32_t)srcva < UTOP && (!((perm & PTE_U) && (perm & PTE_P) && (perm & (~PTE_SYSCALL))==0))) 
		return -E_INVAL;

	//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's address space 
	if ((uint32_t)srcva < UTOP) {
		pte_t * pte;
		struct PageInfo * pg = page_lookup(curenv->env_pgdir, srcva, &pte);
		if (pg == NULL) return -E_INVAL;

		//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
		//		current environment's address space.
		if ((perm & PTE_W) && (*pte & PTE_W) == 0) 
			return -E_INVAL;

		//	-E_NO_MEM if there's not enough memory to map srcva in envid's
		//		address space.
		if (env->env_ipc_dstva != NULL) {
			r = page_insert(env->env_pgdir, pg, env->env_ipc_dstva, perm);
			if (r < 0) return -E_NO_MEM;
			env->env_ipc_perm = perm;
		} else env->env_ipc_perm = 0;	
	}

	env->env_ipc_recving = false;

	// ... I mistake write env->env_ipc_from = envid in the first
	// ... Debug a lot of time...
	env->env_ipc_from = curenv->env_id;
	env->env_ipc_value = value;
	env->env_tf.tf_regs.reg_eax = 0;
	env->env_status = ENV_RUNNABLE;

	return 0;
}

// Block until a value is ready.  Record that you want to receive
// using the env_ipc_recving and env_ipc_dstva fields of struct Env,
// mark yourself not runnable, and then give up the CPU.
//
// If 'dstva' is < UTOP, then you are willing to receive a page of data.
// 'dstva' is the virtual address at which the sent page should be mapped.
//
// This function only returns on error, but the system call will eventually
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// cprintf("I am receiving???\n");
	// LAB 4: Your code here.
	if (((uint32_t)dstva < UTOP) && ROUNDUP(dstva, PGSIZE) != dstva) return -E_INVAL;
	curenv->env_ipc_recving = true;			// Env is blocked receiving
	curenv->env_ipc_dstva = dstva;			// VA at which to map received page
	curenv->env_ipc_from = 0;				// set from to 0
	curenv->env_status = ENV_NOT_RUNNABLE;	// mark it not runnable
	sched_yield();							// give up the CPU

	return 0;
}

static int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
	struct Env * env;
	int r = envid2env(envid, &env, 1);	
	if (r < 0) return -E_BAD_ENV;
	
	//env->env_priority = new_priority;
	return 0;
}

static int
sys_exec(uint32_t eip, uint32_t esp, void * v_ph, uint32_t phnum)
{
	// set new eip and esp
	memset((void *)(&curenv->env_tf.tf_regs), 0, sizeof(struct PushRegs));
	curenv->env_tf.tf_eip = eip;
	curenv->env_tf.tf_esp = esp;

	int perm, i;
	uint32_t now_addr = MYTEMPLATE;
	uint32_t va, end_addr;
	struct PageInfo * pg;

	// Elf 
	struct Proghdr * ph = (struct Proghdr *) v_ph; 
	for (i = 0; i < phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;

		// Move to real virtual address
		end_addr = ROUNDUP(ph->p_va + ph->p_memsz, PGSIZE);
		for (va = ROUNDDOWN(ph->p_va, PGSIZE); va != end_addr; now_addr += PGSIZE, va += PGSIZE) {
			if ((pg = page_lookup(curenv->env_pgdir, (void *)now_addr, NULL)) == NULL) 
				return -E_NO_MEM;		// no page
			if (page_insert(curenv->env_pgdir, pg, (void *)va, perm) < 0)
				return -E_NO_MEM;		
			page_remove(curenv->env_pgdir, (void *)now_addr);
		}
	}

	// New Stack
	if ((pg = page_lookup(curenv->env_pgdir, (void *)now_addr, NULL)) == NULL) 
		return -E_NO_MEM;
	if (page_insert(curenv->env_pgdir, pg, (void *)(USTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W) < 0) 
		return -E_NO_MEM;
	page_remove(curenv->env_pgdir, (void *)now_addr);
	
	env_run(curenv);		// never return
	return 0;
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
    
    // cprintf("SYSCALLNO %d\n", syscallno);
	int r = 0;
    switch (syscallno) {
    	case SYS_exofork:
    		r = sys_exofork();
    		break;
    	case SYS_env_set_status:
    		r = sys_env_set_status((envid_t)a1, (int)a2);
    		break;
    	case SYS_page_alloc:
    		r = sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
    		break;    		
    	case SYS_page_map:
    		r = sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
    		break;
    	case SYS_page_unmap:
    		r = sys_page_unmap((envid_t)a1, (void *)a2);
    		break;
    	case SYS_env_set_pgfault_upcall:
    		r = sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
    		break;
    	case SYS_yield:
    		sys_yield();
    		r = 0;
    		break;
        case SYS_cputs:
            sys_cputs((char *)a1, (size_t)a2);
            r = 0;
            break;
        case SYS_cgetc:
            r = sys_cgetc();
            break;
        case SYS_getenvid:
            r = sys_getenvid();
            break;
        case SYS_env_destroy:
            r = sys_env_destroy(a1);
            break;
        case SYS_ipc_try_send:
        	r = sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
        	break;
        case SYS_ipc_recv:
        	r = sys_ipc_recv((void *)a1);
        	break;
        case SYS_set_priority:
        	r = sys_set_priority((envid_t)a1, (uint32_t)a2);
        	break;
        case SYS_env_set_trapframe:
        	r = sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
        	break;
        case SYS_exec:
        	r = sys_exec((uint32_t)a1, (uint32_t)a2, (void *)a3, (uint32_t)a4);
        	break;
        dafult:
            r = -E_INVAL;
	}
	return r;
}

