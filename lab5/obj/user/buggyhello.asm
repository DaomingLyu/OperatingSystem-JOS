
obj/user/buggyhello.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 17 00 00 00       	call   800048 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  80003a:	6a 01                	push   $0x1
  80003c:	6a 01                	push   $0x1
  80003e:	e8 be 00 00 00       	call   800101 <sys_cputs>
  800043:	83 c4 10             	add    $0x10,%esp
}
  800046:	c9                   	leave  
  800047:	c3                   	ret    

00800048 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800048:	55                   	push   %ebp
  800049:	89 e5                	mov    %esp,%ebp
  80004b:	56                   	push   %esi
  80004c:	53                   	push   %ebx
  80004d:	8b 75 08             	mov    0x8(%ebp),%esi
  800050:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800053:	e8 15 01 00 00       	call   80016d <sys_getenvid>
  800058:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800064:	c1 e0 07             	shl    $0x7,%eax
  800067:	29 d0                	sub    %edx,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800073:	85 f6                	test   %esi,%esi
  800075:	7e 07                	jle    80007e <libmain+0x36>
		binaryname = argv[0];
  800077:	8b 03                	mov    (%ebx),%eax
  800079:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  80007e:	83 ec 08             	sub    $0x8,%esp
  800081:	53                   	push   %ebx
  800082:	56                   	push   %esi
  800083:	e8 ac ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800088:	e8 0b 00 00 00       	call   800098 <exit>
  80008d:	83 c4 10             	add    $0x10,%esp
}
  800090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	c9                   	leave  
  800096:	c3                   	ret    
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009e:	e8 87 04 00 00       	call   80052a <close_all>
	sys_env_destroy(0);
  8000a3:	83 ec 0c             	sub    $0xc,%esp
  8000a6:	6a 00                	push   $0x0
  8000a8:	e8 9e 00 00 00       	call   80014b <sys_env_destroy>
  8000ad:	83 c4 10             	add    $0x10,%esp
}
  8000b0:	c9                   	leave  
  8000b1:	c3                   	ret    
	...

008000b4 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	83 ec 1c             	sub    $0x1c,%esp
  8000bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000c0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000c3:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c5:	8b 75 14             	mov    0x14(%ebp),%esi
  8000c8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d1:	cd 30                	int    $0x30
  8000d3:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000d9:	74 1c                	je     8000f7 <syscall+0x43>
  8000db:	85 c0                	test   %eax,%eax
  8000dd:	7e 18                	jle    8000f7 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000df:	83 ec 0c             	sub    $0xc,%esp
  8000e2:	50                   	push   %eax
  8000e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e6:	68 aa 1d 80 00       	push   $0x801daa
  8000eb:	6a 42                	push   $0x42
  8000ed:	68 c7 1d 80 00       	push   $0x801dc7
  8000f2:	e8 dd 0e 00 00       	call   800fd4 <_panic>

	return ret;
}
  8000f7:	89 d0                	mov    %edx,%eax
  8000f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000fc:	5b                   	pop    %ebx
  8000fd:	5e                   	pop    %esi
  8000fe:	5f                   	pop    %edi
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800107:	6a 00                	push   $0x0
  800109:	6a 00                	push   $0x0
  80010b:	6a 00                	push   $0x0
  80010d:	ff 75 0c             	pushl  0xc(%ebp)
  800110:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800113:	ba 00 00 00 00       	mov    $0x0,%edx
  800118:	b8 00 00 00 00       	mov    $0x0,%eax
  80011d:	e8 92 ff ff ff       	call   8000b4 <syscall>
  800122:	83 c4 10             	add    $0x10,%esp
	return;
}
  800125:	c9                   	leave  
  800126:	c3                   	ret    

00800127 <sys_cgetc>:

int
sys_cgetc(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80012d:	6a 00                	push   $0x0
  80012f:	6a 00                	push   $0x0
  800131:	6a 00                	push   $0x0
  800133:	6a 00                	push   $0x0
  800135:	b9 00 00 00 00       	mov    $0x0,%ecx
  80013a:	ba 00 00 00 00       	mov    $0x0,%edx
  80013f:	b8 01 00 00 00       	mov    $0x1,%eax
  800144:	e8 6b ff ff ff       	call   8000b4 <syscall>
}
  800149:	c9                   	leave  
  80014a:	c3                   	ret    

0080014b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800151:	6a 00                	push   $0x0
  800153:	6a 00                	push   $0x0
  800155:	6a 00                	push   $0x0
  800157:	6a 00                	push   $0x0
  800159:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015c:	ba 01 00 00 00       	mov    $0x1,%edx
  800161:	b8 03 00 00 00       	mov    $0x3,%eax
  800166:	e8 49 ff ff ff       	call   8000b4 <syscall>
}
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    

0080016d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800173:	6a 00                	push   $0x0
  800175:	6a 00                	push   $0x0
  800177:	6a 00                	push   $0x0
  800179:	6a 00                	push   $0x0
  80017b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800180:	ba 00 00 00 00       	mov    $0x0,%edx
  800185:	b8 02 00 00 00       	mov    $0x2,%eax
  80018a:	e8 25 ff ff ff       	call   8000b4 <syscall>
}
  80018f:	c9                   	leave  
  800190:	c3                   	ret    

00800191 <sys_yield>:

void
sys_yield(void)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800197:	6a 00                	push   $0x0
  800199:	6a 00                	push   $0x0
  80019b:	6a 00                	push   $0x0
  80019d:	6a 00                	push   $0x0
  80019f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001ae:	e8 01 ff ff ff       	call   8000b4 <syscall>
  8001b3:	83 c4 10             	add    $0x10,%esp
}
  8001b6:	c9                   	leave  
  8001b7:	c3                   	ret    

008001b8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001be:	6a 00                	push   $0x0
  8001c0:	6a 00                	push   $0x0
  8001c2:	ff 75 10             	pushl  0x10(%ebp)
  8001c5:	ff 75 0c             	pushl  0xc(%ebp)
  8001c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001cb:	ba 01 00 00 00       	mov    $0x1,%edx
  8001d0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001d5:	e8 da fe ff ff       	call   8000b4 <syscall>
}
  8001da:	c9                   	leave  
  8001db:	c3                   	ret    

008001dc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001e2:	ff 75 18             	pushl  0x18(%ebp)
  8001e5:	ff 75 14             	pushl  0x14(%ebp)
  8001e8:	ff 75 10             	pushl  0x10(%ebp)
  8001eb:	ff 75 0c             	pushl  0xc(%ebp)
  8001ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f1:	ba 01 00 00 00       	mov    $0x1,%edx
  8001f6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001fb:	e8 b4 fe ff ff       	call   8000b4 <syscall>
}
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800208:	6a 00                	push   $0x0
  80020a:	6a 00                	push   $0x0
  80020c:	6a 00                	push   $0x0
  80020e:	ff 75 0c             	pushl  0xc(%ebp)
  800211:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800214:	ba 01 00 00 00       	mov    $0x1,%edx
  800219:	b8 06 00 00 00       	mov    $0x6,%eax
  80021e:	e8 91 fe ff ff       	call   8000b4 <syscall>
}
  800223:	c9                   	leave  
  800224:	c3                   	ret    

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80022b:	6a 00                	push   $0x0
  80022d:	6a 00                	push   $0x0
  80022f:	6a 00                	push   $0x0
  800231:	ff 75 0c             	pushl  0xc(%ebp)
  800234:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800237:	ba 01 00 00 00       	mov    $0x1,%edx
  80023c:	b8 08 00 00 00       	mov    $0x8,%eax
  800241:	e8 6e fe ff ff       	call   8000b4 <syscall>
}
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  80024e:	6a 00                	push   $0x0
  800250:	6a 00                	push   $0x0
  800252:	6a 00                	push   $0x0
  800254:	ff 75 0c             	pushl  0xc(%ebp)
  800257:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80025a:	ba 01 00 00 00       	mov    $0x1,%edx
  80025f:	b8 09 00 00 00       	mov    $0x9,%eax
  800264:	e8 4b fe ff ff       	call   8000b4 <syscall>
}
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800271:	6a 00                	push   $0x0
  800273:	6a 00                	push   $0x0
  800275:	6a 00                	push   $0x0
  800277:	ff 75 0c             	pushl  0xc(%ebp)
  80027a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80027d:	ba 01 00 00 00       	mov    $0x1,%edx
  800282:	b8 0a 00 00 00       	mov    $0xa,%eax
  800287:	e8 28 fe ff ff       	call   8000b4 <syscall>
}
  80028c:	c9                   	leave  
  80028d:	c3                   	ret    

0080028e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
  800291:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800294:	6a 00                	push   $0x0
  800296:	ff 75 14             	pushl  0x14(%ebp)
  800299:	ff 75 10             	pushl  0x10(%ebp)
  80029c:	ff 75 0c             	pushl  0xc(%ebp)
  80029f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ac:	e8 03 fe ff ff       	call   8000b4 <syscall>
}
  8002b1:	c9                   	leave  
  8002b2:	c3                   	ret    

008002b3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002b9:	6a 00                	push   $0x0
  8002bb:	6a 00                	push   $0x0
  8002bd:	6a 00                	push   $0x0
  8002bf:	6a 00                	push   $0x0
  8002c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c4:	ba 01 00 00 00       	mov    $0x1,%edx
  8002c9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002ce:	e8 e1 fd ff ff       	call   8000b4 <syscall>
}
  8002d3:	c9                   	leave  
  8002d4:	c3                   	ret    

008002d5 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8002db:	6a 00                	push   $0x0
  8002dd:	6a 00                	push   $0x0
  8002df:	6a 00                	push   $0x0
  8002e1:	ff 75 0c             	pushl  0xc(%ebp)
  8002e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ec:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002f1:	e8 be fd ff ff       	call   8000b4 <syscall>
}
  8002f6:	c9                   	leave  
  8002f7:	c3                   	ret    

008002f8 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  8002fe:	6a 00                	push   $0x0
  800300:	ff 75 14             	pushl  0x14(%ebp)
  800303:	ff 75 10             	pushl  0x10(%ebp)
  800306:	ff 75 0c             	pushl  0xc(%ebp)
  800309:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80030c:	ba 00 00 00 00       	mov    $0x0,%edx
  800311:	b8 0f 00 00 00       	mov    $0xf,%eax
  800316:	e8 99 fd ff ff       	call   8000b4 <syscall>
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    
  80031d:	00 00                	add    %al,(%eax)
	...

00800320 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800323:	8b 45 08             	mov    0x8(%ebp),%eax
  800326:	05 00 00 00 30       	add    $0x30000000,%eax
  80032b:	c1 e8 0c             	shr    $0xc,%eax
}
  80032e:	c9                   	leave  
  80032f:	c3                   	ret    

00800330 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800333:	ff 75 08             	pushl  0x8(%ebp)
  800336:	e8 e5 ff ff ff       	call   800320 <fd2num>
  80033b:	83 c4 04             	add    $0x4,%esp
  80033e:	05 20 00 0d 00       	add    $0xd0020,%eax
  800343:	c1 e0 0c             	shl    $0xc,%eax
}
  800346:	c9                   	leave  
  800347:	c3                   	ret    

00800348 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800348:	55                   	push   %ebp
  800349:	89 e5                	mov    %esp,%ebp
  80034b:	53                   	push   %ebx
  80034c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80034f:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800354:	a8 01                	test   $0x1,%al
  800356:	74 34                	je     80038c <fd_alloc+0x44>
  800358:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80035d:	a8 01                	test   $0x1,%al
  80035f:	74 32                	je     800393 <fd_alloc+0x4b>
  800361:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800366:	89 c1                	mov    %eax,%ecx
  800368:	89 c2                	mov    %eax,%edx
  80036a:	c1 ea 16             	shr    $0x16,%edx
  80036d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800374:	f6 c2 01             	test   $0x1,%dl
  800377:	74 1f                	je     800398 <fd_alloc+0x50>
  800379:	89 c2                	mov    %eax,%edx
  80037b:	c1 ea 0c             	shr    $0xc,%edx
  80037e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800385:	f6 c2 01             	test   $0x1,%dl
  800388:	75 17                	jne    8003a1 <fd_alloc+0x59>
  80038a:	eb 0c                	jmp    800398 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80038c:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800391:	eb 05                	jmp    800398 <fd_alloc+0x50>
  800393:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800398:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80039a:	b8 00 00 00 00       	mov    $0x0,%eax
  80039f:	eb 17                	jmp    8003b8 <fd_alloc+0x70>
  8003a1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003a6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ab:	75 b9                	jne    800366 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003ad:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8003b3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003b8:	5b                   	pop    %ebx
  8003b9:	c9                   	leave  
  8003ba:	c3                   	ret    

008003bb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c1:	83 f8 1f             	cmp    $0x1f,%eax
  8003c4:	77 36                	ja     8003fc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c6:	05 00 00 0d 00       	add    $0xd0000,%eax
  8003cb:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003ce:	89 c2                	mov    %eax,%edx
  8003d0:	c1 ea 16             	shr    $0x16,%edx
  8003d3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003da:	f6 c2 01             	test   $0x1,%dl
  8003dd:	74 24                	je     800403 <fd_lookup+0x48>
  8003df:	89 c2                	mov    %eax,%edx
  8003e1:	c1 ea 0c             	shr    $0xc,%edx
  8003e4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003eb:	f6 c2 01             	test   $0x1,%dl
  8003ee:	74 1a                	je     80040a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f3:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fa:	eb 13                	jmp    80040f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800401:	eb 0c                	jmp    80040f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800403:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800408:	eb 05                	jmp    80040f <fd_lookup+0x54>
  80040a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	53                   	push   %ebx
  800415:	83 ec 04             	sub    $0x4,%esp
  800418:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80041e:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800424:	74 0d                	je     800433 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800426:	b8 00 00 00 00       	mov    $0x0,%eax
  80042b:	eb 14                	jmp    800441 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  80042d:	39 0a                	cmp    %ecx,(%edx)
  80042f:	75 10                	jne    800441 <dev_lookup+0x30>
  800431:	eb 05                	jmp    800438 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800433:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800438:	89 13                	mov    %edx,(%ebx)
			return 0;
  80043a:	b8 00 00 00 00       	mov    $0x0,%eax
  80043f:	eb 31                	jmp    800472 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800441:	40                   	inc    %eax
  800442:	8b 14 85 54 1e 80 00 	mov    0x801e54(,%eax,4),%edx
  800449:	85 d2                	test   %edx,%edx
  80044b:	75 e0                	jne    80042d <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80044d:	a1 04 40 80 00       	mov    0x804004,%eax
  800452:	8b 40 48             	mov    0x48(%eax),%eax
  800455:	83 ec 04             	sub    $0x4,%esp
  800458:	51                   	push   %ecx
  800459:	50                   	push   %eax
  80045a:	68 d8 1d 80 00       	push   $0x801dd8
  80045f:	e8 48 0c 00 00       	call   8010ac <cprintf>
	*dev = 0;
  800464:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80046a:	83 c4 10             	add    $0x10,%esp
  80046d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800472:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800475:	c9                   	leave  
  800476:	c3                   	ret    

00800477 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800477:	55                   	push   %ebp
  800478:	89 e5                	mov    %esp,%ebp
  80047a:	56                   	push   %esi
  80047b:	53                   	push   %ebx
  80047c:	83 ec 20             	sub    $0x20,%esp
  80047f:	8b 75 08             	mov    0x8(%ebp),%esi
  800482:	8a 45 0c             	mov    0xc(%ebp),%al
  800485:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800488:	56                   	push   %esi
  800489:	e8 92 fe ff ff       	call   800320 <fd2num>
  80048e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800491:	89 14 24             	mov    %edx,(%esp)
  800494:	50                   	push   %eax
  800495:	e8 21 ff ff ff       	call   8003bb <fd_lookup>
  80049a:	89 c3                	mov    %eax,%ebx
  80049c:	83 c4 08             	add    $0x8,%esp
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	78 05                	js     8004a8 <fd_close+0x31>
	    || fd != fd2)
  8004a3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004a6:	74 0d                	je     8004b5 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8004a8:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8004ac:	75 48                	jne    8004f6 <fd_close+0x7f>
  8004ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004b3:	eb 41                	jmp    8004f6 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004bb:	50                   	push   %eax
  8004bc:	ff 36                	pushl  (%esi)
  8004be:	e8 4e ff ff ff       	call   800411 <dev_lookup>
  8004c3:	89 c3                	mov    %eax,%ebx
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	78 1c                	js     8004e8 <fd_close+0x71>
		if (dev->dev_close)
  8004cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004cf:	8b 40 10             	mov    0x10(%eax),%eax
  8004d2:	85 c0                	test   %eax,%eax
  8004d4:	74 0d                	je     8004e3 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8004d6:	83 ec 0c             	sub    $0xc,%esp
  8004d9:	56                   	push   %esi
  8004da:	ff d0                	call   *%eax
  8004dc:	89 c3                	mov    %eax,%ebx
  8004de:	83 c4 10             	add    $0x10,%esp
  8004e1:	eb 05                	jmp    8004e8 <fd_close+0x71>
		else
			r = 0;
  8004e3:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	56                   	push   %esi
  8004ec:	6a 00                	push   $0x0
  8004ee:	e8 0f fd ff ff       	call   800202 <sys_page_unmap>
	return r;
  8004f3:	83 c4 10             	add    $0x10,%esp
}
  8004f6:	89 d8                	mov    %ebx,%eax
  8004f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004fb:	5b                   	pop    %ebx
  8004fc:	5e                   	pop    %esi
  8004fd:	c9                   	leave  
  8004fe:	c3                   	ret    

008004ff <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004ff:	55                   	push   %ebp
  800500:	89 e5                	mov    %esp,%ebp
  800502:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800505:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800508:	50                   	push   %eax
  800509:	ff 75 08             	pushl  0x8(%ebp)
  80050c:	e8 aa fe ff ff       	call   8003bb <fd_lookup>
  800511:	83 c4 08             	add    $0x8,%esp
  800514:	85 c0                	test   %eax,%eax
  800516:	78 10                	js     800528 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	6a 01                	push   $0x1
  80051d:	ff 75 f4             	pushl  -0xc(%ebp)
  800520:	e8 52 ff ff ff       	call   800477 <fd_close>
  800525:	83 c4 10             	add    $0x10,%esp
}
  800528:	c9                   	leave  
  800529:	c3                   	ret    

0080052a <close_all>:

void
close_all(void)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	53                   	push   %ebx
  80052e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800531:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800536:	83 ec 0c             	sub    $0xc,%esp
  800539:	53                   	push   %ebx
  80053a:	e8 c0 ff ff ff       	call   8004ff <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80053f:	43                   	inc    %ebx
  800540:	83 c4 10             	add    $0x10,%esp
  800543:	83 fb 20             	cmp    $0x20,%ebx
  800546:	75 ee                	jne    800536 <close_all+0xc>
		close(i);
}
  800548:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80054b:	c9                   	leave  
  80054c:	c3                   	ret    

0080054d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80054d:	55                   	push   %ebp
  80054e:	89 e5                	mov    %esp,%ebp
  800550:	57                   	push   %edi
  800551:	56                   	push   %esi
  800552:	53                   	push   %ebx
  800553:	83 ec 2c             	sub    $0x2c,%esp
  800556:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800559:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80055c:	50                   	push   %eax
  80055d:	ff 75 08             	pushl  0x8(%ebp)
  800560:	e8 56 fe ff ff       	call   8003bb <fd_lookup>
  800565:	89 c3                	mov    %eax,%ebx
  800567:	83 c4 08             	add    $0x8,%esp
  80056a:	85 c0                	test   %eax,%eax
  80056c:	0f 88 c0 00 00 00    	js     800632 <dup+0xe5>
		return r;
	close(newfdnum);
  800572:	83 ec 0c             	sub    $0xc,%esp
  800575:	57                   	push   %edi
  800576:	e8 84 ff ff ff       	call   8004ff <close>

	newfd = INDEX2FD(newfdnum);
  80057b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800581:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800584:	83 c4 04             	add    $0x4,%esp
  800587:	ff 75 e4             	pushl  -0x1c(%ebp)
  80058a:	e8 a1 fd ff ff       	call   800330 <fd2data>
  80058f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800591:	89 34 24             	mov    %esi,(%esp)
  800594:	e8 97 fd ff ff       	call   800330 <fd2data>
  800599:	83 c4 10             	add    $0x10,%esp
  80059c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80059f:	89 d8                	mov    %ebx,%eax
  8005a1:	c1 e8 16             	shr    $0x16,%eax
  8005a4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005ab:	a8 01                	test   $0x1,%al
  8005ad:	74 37                	je     8005e6 <dup+0x99>
  8005af:	89 d8                	mov    %ebx,%eax
  8005b1:	c1 e8 0c             	shr    $0xc,%eax
  8005b4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005bb:	f6 c2 01             	test   $0x1,%dl
  8005be:	74 26                	je     8005e6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c7:	83 ec 0c             	sub    $0xc,%esp
  8005ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8005cf:	50                   	push   %eax
  8005d0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005d3:	6a 00                	push   $0x0
  8005d5:	53                   	push   %ebx
  8005d6:	6a 00                	push   $0x0
  8005d8:	e8 ff fb ff ff       	call   8001dc <sys_page_map>
  8005dd:	89 c3                	mov    %eax,%ebx
  8005df:	83 c4 20             	add    $0x20,%esp
  8005e2:	85 c0                	test   %eax,%eax
  8005e4:	78 2d                	js     800613 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005e9:	89 c2                	mov    %eax,%edx
  8005eb:	c1 ea 0c             	shr    $0xc,%edx
  8005ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8005f5:	83 ec 0c             	sub    $0xc,%esp
  8005f8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8005fe:	52                   	push   %edx
  8005ff:	56                   	push   %esi
  800600:	6a 00                	push   $0x0
  800602:	50                   	push   %eax
  800603:	6a 00                	push   $0x0
  800605:	e8 d2 fb ff ff       	call   8001dc <sys_page_map>
  80060a:	89 c3                	mov    %eax,%ebx
  80060c:	83 c4 20             	add    $0x20,%esp
  80060f:	85 c0                	test   %eax,%eax
  800611:	79 1d                	jns    800630 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800613:	83 ec 08             	sub    $0x8,%esp
  800616:	56                   	push   %esi
  800617:	6a 00                	push   $0x0
  800619:	e8 e4 fb ff ff       	call   800202 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80061e:	83 c4 08             	add    $0x8,%esp
  800621:	ff 75 d4             	pushl  -0x2c(%ebp)
  800624:	6a 00                	push   $0x0
  800626:	e8 d7 fb ff ff       	call   800202 <sys_page_unmap>
	return r;
  80062b:	83 c4 10             	add    $0x10,%esp
  80062e:	eb 02                	jmp    800632 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800630:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800632:	89 d8                	mov    %ebx,%eax
  800634:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800637:	5b                   	pop    %ebx
  800638:	5e                   	pop    %esi
  800639:	5f                   	pop    %edi
  80063a:	c9                   	leave  
  80063b:	c3                   	ret    

0080063c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80063c:	55                   	push   %ebp
  80063d:	89 e5                	mov    %esp,%ebp
  80063f:	53                   	push   %ebx
  800640:	83 ec 14             	sub    $0x14,%esp
  800643:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800646:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800649:	50                   	push   %eax
  80064a:	53                   	push   %ebx
  80064b:	e8 6b fd ff ff       	call   8003bb <fd_lookup>
  800650:	83 c4 08             	add    $0x8,%esp
  800653:	85 c0                	test   %eax,%eax
  800655:	78 67                	js     8006be <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80065d:	50                   	push   %eax
  80065e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800661:	ff 30                	pushl  (%eax)
  800663:	e8 a9 fd ff ff       	call   800411 <dev_lookup>
  800668:	83 c4 10             	add    $0x10,%esp
  80066b:	85 c0                	test   %eax,%eax
  80066d:	78 4f                	js     8006be <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80066f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800672:	8b 50 08             	mov    0x8(%eax),%edx
  800675:	83 e2 03             	and    $0x3,%edx
  800678:	83 fa 01             	cmp    $0x1,%edx
  80067b:	75 21                	jne    80069e <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80067d:	a1 04 40 80 00       	mov    0x804004,%eax
  800682:	8b 40 48             	mov    0x48(%eax),%eax
  800685:	83 ec 04             	sub    $0x4,%esp
  800688:	53                   	push   %ebx
  800689:	50                   	push   %eax
  80068a:	68 19 1e 80 00       	push   $0x801e19
  80068f:	e8 18 0a 00 00       	call   8010ac <cprintf>
		return -E_INVAL;
  800694:	83 c4 10             	add    $0x10,%esp
  800697:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80069c:	eb 20                	jmp    8006be <read+0x82>
	}
	if (!dev->dev_read)
  80069e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006a1:	8b 52 08             	mov    0x8(%edx),%edx
  8006a4:	85 d2                	test   %edx,%edx
  8006a6:	74 11                	je     8006b9 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a8:	83 ec 04             	sub    $0x4,%esp
  8006ab:	ff 75 10             	pushl  0x10(%ebp)
  8006ae:	ff 75 0c             	pushl  0xc(%ebp)
  8006b1:	50                   	push   %eax
  8006b2:	ff d2                	call   *%edx
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	eb 05                	jmp    8006be <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8006be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c1:	c9                   	leave  
  8006c2:	c3                   	ret    

008006c3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c3:	55                   	push   %ebp
  8006c4:	89 e5                	mov    %esp,%ebp
  8006c6:	57                   	push   %edi
  8006c7:	56                   	push   %esi
  8006c8:	53                   	push   %ebx
  8006c9:	83 ec 0c             	sub    $0xc,%esp
  8006cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cf:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d2:	85 f6                	test   %esi,%esi
  8006d4:	74 31                	je     800707 <readn+0x44>
  8006d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006db:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006e0:	83 ec 04             	sub    $0x4,%esp
  8006e3:	89 f2                	mov    %esi,%edx
  8006e5:	29 c2                	sub    %eax,%edx
  8006e7:	52                   	push   %edx
  8006e8:	03 45 0c             	add    0xc(%ebp),%eax
  8006eb:	50                   	push   %eax
  8006ec:	57                   	push   %edi
  8006ed:	e8 4a ff ff ff       	call   80063c <read>
		if (m < 0)
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	78 17                	js     800710 <readn+0x4d>
			return m;
		if (m == 0)
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	74 11                	je     80070e <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006fd:	01 c3                	add    %eax,%ebx
  8006ff:	89 d8                	mov    %ebx,%eax
  800701:	39 f3                	cmp    %esi,%ebx
  800703:	72 db                	jb     8006e0 <readn+0x1d>
  800705:	eb 09                	jmp    800710 <readn+0x4d>
  800707:	b8 00 00 00 00       	mov    $0x0,%eax
  80070c:	eb 02                	jmp    800710 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80070e:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800710:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800713:	5b                   	pop    %ebx
  800714:	5e                   	pop    %esi
  800715:	5f                   	pop    %edi
  800716:	c9                   	leave  
  800717:	c3                   	ret    

00800718 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	53                   	push   %ebx
  80071c:	83 ec 14             	sub    $0x14,%esp
  80071f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800722:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800725:	50                   	push   %eax
  800726:	53                   	push   %ebx
  800727:	e8 8f fc ff ff       	call   8003bb <fd_lookup>
  80072c:	83 c4 08             	add    $0x8,%esp
  80072f:	85 c0                	test   %eax,%eax
  800731:	78 62                	js     800795 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800733:	83 ec 08             	sub    $0x8,%esp
  800736:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073d:	ff 30                	pushl  (%eax)
  80073f:	e8 cd fc ff ff       	call   800411 <dev_lookup>
  800744:	83 c4 10             	add    $0x10,%esp
  800747:	85 c0                	test   %eax,%eax
  800749:	78 4a                	js     800795 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80074b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800752:	75 21                	jne    800775 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800754:	a1 04 40 80 00       	mov    0x804004,%eax
  800759:	8b 40 48             	mov    0x48(%eax),%eax
  80075c:	83 ec 04             	sub    $0x4,%esp
  80075f:	53                   	push   %ebx
  800760:	50                   	push   %eax
  800761:	68 35 1e 80 00       	push   $0x801e35
  800766:	e8 41 09 00 00       	call   8010ac <cprintf>
		return -E_INVAL;
  80076b:	83 c4 10             	add    $0x10,%esp
  80076e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800773:	eb 20                	jmp    800795 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800775:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800778:	8b 52 0c             	mov    0xc(%edx),%edx
  80077b:	85 d2                	test   %edx,%edx
  80077d:	74 11                	je     800790 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80077f:	83 ec 04             	sub    $0x4,%esp
  800782:	ff 75 10             	pushl  0x10(%ebp)
  800785:	ff 75 0c             	pushl  0xc(%ebp)
  800788:	50                   	push   %eax
  800789:	ff d2                	call   *%edx
  80078b:	83 c4 10             	add    $0x10,%esp
  80078e:	eb 05                	jmp    800795 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800790:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800795:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800798:	c9                   	leave  
  800799:	c3                   	ret    

0080079a <seek>:

int
seek(int fdnum, off_t offset)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007a0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a3:	50                   	push   %eax
  8007a4:	ff 75 08             	pushl  0x8(%ebp)
  8007a7:	e8 0f fc ff ff       	call   8003bb <fd_lookup>
  8007ac:	83 c4 08             	add    $0x8,%esp
  8007af:	85 c0                	test   %eax,%eax
  8007b1:	78 0e                	js     8007c1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c1:	c9                   	leave  
  8007c2:	c3                   	ret    

008007c3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	53                   	push   %ebx
  8007c7:	83 ec 14             	sub    $0x14,%esp
  8007ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007d0:	50                   	push   %eax
  8007d1:	53                   	push   %ebx
  8007d2:	e8 e4 fb ff ff       	call   8003bb <fd_lookup>
  8007d7:	83 c4 08             	add    $0x8,%esp
  8007da:	85 c0                	test   %eax,%eax
  8007dc:	78 5f                	js     80083d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007de:	83 ec 08             	sub    $0x8,%esp
  8007e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e4:	50                   	push   %eax
  8007e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e8:	ff 30                	pushl  (%eax)
  8007ea:	e8 22 fc ff ff       	call   800411 <dev_lookup>
  8007ef:	83 c4 10             	add    $0x10,%esp
  8007f2:	85 c0                	test   %eax,%eax
  8007f4:	78 47                	js     80083d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fd:	75 21                	jne    800820 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007ff:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800804:	8b 40 48             	mov    0x48(%eax),%eax
  800807:	83 ec 04             	sub    $0x4,%esp
  80080a:	53                   	push   %ebx
  80080b:	50                   	push   %eax
  80080c:	68 f8 1d 80 00       	push   $0x801df8
  800811:	e8 96 08 00 00       	call   8010ac <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800816:	83 c4 10             	add    $0x10,%esp
  800819:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80081e:	eb 1d                	jmp    80083d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800820:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800823:	8b 52 18             	mov    0x18(%edx),%edx
  800826:	85 d2                	test   %edx,%edx
  800828:	74 0e                	je     800838 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082a:	83 ec 08             	sub    $0x8,%esp
  80082d:	ff 75 0c             	pushl  0xc(%ebp)
  800830:	50                   	push   %eax
  800831:	ff d2                	call   *%edx
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	eb 05                	jmp    80083d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800838:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80083d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800840:	c9                   	leave  
  800841:	c3                   	ret    

00800842 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	53                   	push   %ebx
  800846:	83 ec 14             	sub    $0x14,%esp
  800849:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80084c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80084f:	50                   	push   %eax
  800850:	ff 75 08             	pushl  0x8(%ebp)
  800853:	e8 63 fb ff ff       	call   8003bb <fd_lookup>
  800858:	83 c4 08             	add    $0x8,%esp
  80085b:	85 c0                	test   %eax,%eax
  80085d:	78 52                	js     8008b1 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085f:	83 ec 08             	sub    $0x8,%esp
  800862:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800865:	50                   	push   %eax
  800866:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800869:	ff 30                	pushl  (%eax)
  80086b:	e8 a1 fb ff ff       	call   800411 <dev_lookup>
  800870:	83 c4 10             	add    $0x10,%esp
  800873:	85 c0                	test   %eax,%eax
  800875:	78 3a                	js     8008b1 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  800877:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80087e:	74 2c                	je     8008ac <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800880:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800883:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80088a:	00 00 00 
	stat->st_isdir = 0;
  80088d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800894:	00 00 00 
	stat->st_dev = dev;
  800897:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80089d:	83 ec 08             	sub    $0x8,%esp
  8008a0:	53                   	push   %ebx
  8008a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8008a4:	ff 50 14             	call   *0x14(%eax)
  8008a7:	83 c4 10             	add    $0x10,%esp
  8008aa:	eb 05                	jmp    8008b1 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b4:	c9                   	leave  
  8008b5:	c3                   	ret    

008008b6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	56                   	push   %esi
  8008ba:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008bb:	83 ec 08             	sub    $0x8,%esp
  8008be:	6a 00                	push   $0x0
  8008c0:	ff 75 08             	pushl  0x8(%ebp)
  8008c3:	e8 78 01 00 00       	call   800a40 <open>
  8008c8:	89 c3                	mov    %eax,%ebx
  8008ca:	83 c4 10             	add    $0x10,%esp
  8008cd:	85 c0                	test   %eax,%eax
  8008cf:	78 1b                	js     8008ec <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d1:	83 ec 08             	sub    $0x8,%esp
  8008d4:	ff 75 0c             	pushl  0xc(%ebp)
  8008d7:	50                   	push   %eax
  8008d8:	e8 65 ff ff ff       	call   800842 <fstat>
  8008dd:	89 c6                	mov    %eax,%esi
	close(fd);
  8008df:	89 1c 24             	mov    %ebx,(%esp)
  8008e2:	e8 18 fc ff ff       	call   8004ff <close>
	return r;
  8008e7:	83 c4 10             	add    $0x10,%esp
  8008ea:	89 f3                	mov    %esi,%ebx
}
  8008ec:	89 d8                	mov    %ebx,%eax
  8008ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f1:	5b                   	pop    %ebx
  8008f2:	5e                   	pop    %esi
  8008f3:	c9                   	leave  
  8008f4:	c3                   	ret    
  8008f5:	00 00                	add    %al,(%eax)
	...

008008f8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	56                   	push   %esi
  8008fc:	53                   	push   %ebx
  8008fd:	89 c3                	mov    %eax,%ebx
  8008ff:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800901:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800908:	75 12                	jne    80091c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80090a:	83 ec 0c             	sub    $0xc,%esp
  80090d:	6a 01                	push   $0x1
  80090f:	e8 96 11 00 00       	call   801aaa <ipc_find_env>
  800914:	a3 00 40 80 00       	mov    %eax,0x804000
  800919:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80091c:	6a 07                	push   $0x7
  80091e:	68 00 50 80 00       	push   $0x805000
  800923:	53                   	push   %ebx
  800924:	ff 35 00 40 80 00    	pushl  0x804000
  80092a:	e8 26 11 00 00       	call   801a55 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80092f:	83 c4 0c             	add    $0xc,%esp
  800932:	6a 00                	push   $0x0
  800934:	56                   	push   %esi
  800935:	6a 00                	push   $0x0
  800937:	e8 a4 10 00 00       	call   8019e0 <ipc_recv>
}
  80093c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093f:	5b                   	pop    %ebx
  800940:	5e                   	pop    %esi
  800941:	c9                   	leave  
  800942:	c3                   	ret    

00800943 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	53                   	push   %ebx
  800947:	83 ec 04             	sub    $0x4,%esp
  80094a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	8b 40 0c             	mov    0xc(%eax),%eax
  800953:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  800958:	ba 00 00 00 00       	mov    $0x0,%edx
  80095d:	b8 05 00 00 00       	mov    $0x5,%eax
  800962:	e8 91 ff ff ff       	call   8008f8 <fsipc>
  800967:	85 c0                	test   %eax,%eax
  800969:	78 2c                	js     800997 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80096b:	83 ec 08             	sub    $0x8,%esp
  80096e:	68 00 50 80 00       	push   $0x805000
  800973:	53                   	push   %ebx
  800974:	e8 e9 0c 00 00       	call   801662 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800979:	a1 80 50 80 00       	mov    0x805080,%eax
  80097e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800984:	a1 84 50 80 00       	mov    0x805084,%eax
  800989:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80098f:	83 c4 10             	add    $0x10,%esp
  800992:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800997:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b2:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b7:	e8 3c ff ff ff       	call   8008f8 <fsipc>
}
  8009bc:	c9                   	leave  
  8009bd:	c3                   	ret    

008009be <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	56                   	push   %esi
  8009c2:	53                   	push   %ebx
  8009c3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8009cc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8009d1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8009d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009dc:	b8 03 00 00 00       	mov    $0x3,%eax
  8009e1:	e8 12 ff ff ff       	call   8008f8 <fsipc>
  8009e6:	89 c3                	mov    %eax,%ebx
  8009e8:	85 c0                	test   %eax,%eax
  8009ea:	78 4b                	js     800a37 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8009ec:	39 c6                	cmp    %eax,%esi
  8009ee:	73 16                	jae    800a06 <devfile_read+0x48>
  8009f0:	68 64 1e 80 00       	push   $0x801e64
  8009f5:	68 6b 1e 80 00       	push   $0x801e6b
  8009fa:	6a 7d                	push   $0x7d
  8009fc:	68 80 1e 80 00       	push   $0x801e80
  800a01:	e8 ce 05 00 00       	call   800fd4 <_panic>
	assert(r <= PGSIZE);
  800a06:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a0b:	7e 16                	jle    800a23 <devfile_read+0x65>
  800a0d:	68 8b 1e 80 00       	push   $0x801e8b
  800a12:	68 6b 1e 80 00       	push   $0x801e6b
  800a17:	6a 7e                	push   $0x7e
  800a19:	68 80 1e 80 00       	push   $0x801e80
  800a1e:	e8 b1 05 00 00       	call   800fd4 <_panic>
	memmove(buf, &fsipcbuf, r);
  800a23:	83 ec 04             	sub    $0x4,%esp
  800a26:	50                   	push   %eax
  800a27:	68 00 50 80 00       	push   $0x805000
  800a2c:	ff 75 0c             	pushl  0xc(%ebp)
  800a2f:	e8 ef 0d 00 00       	call   801823 <memmove>
	return r;
  800a34:	83 c4 10             	add    $0x10,%esp
}
  800a37:	89 d8                	mov    %ebx,%eax
  800a39:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a3c:	5b                   	pop    %ebx
  800a3d:	5e                   	pop    %esi
  800a3e:	c9                   	leave  
  800a3f:	c3                   	ret    

00800a40 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
  800a45:	83 ec 1c             	sub    $0x1c,%esp
  800a48:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a4b:	56                   	push   %esi
  800a4c:	e8 bf 0b 00 00       	call   801610 <strlen>
  800a51:	83 c4 10             	add    $0x10,%esp
  800a54:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a59:	7f 65                	jg     800ac0 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a5b:	83 ec 0c             	sub    $0xc,%esp
  800a5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a61:	50                   	push   %eax
  800a62:	e8 e1 f8 ff ff       	call   800348 <fd_alloc>
  800a67:	89 c3                	mov    %eax,%ebx
  800a69:	83 c4 10             	add    $0x10,%esp
  800a6c:	85 c0                	test   %eax,%eax
  800a6e:	78 55                	js     800ac5 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800a70:	83 ec 08             	sub    $0x8,%esp
  800a73:	56                   	push   %esi
  800a74:	68 00 50 80 00       	push   $0x805000
  800a79:	e8 e4 0b 00 00       	call   801662 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800a7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a81:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800a86:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a89:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8e:	e8 65 fe ff ff       	call   8008f8 <fsipc>
  800a93:	89 c3                	mov    %eax,%ebx
  800a95:	83 c4 10             	add    $0x10,%esp
  800a98:	85 c0                	test   %eax,%eax
  800a9a:	79 12                	jns    800aae <open+0x6e>
		fd_close(fd, 0);
  800a9c:	83 ec 08             	sub    $0x8,%esp
  800a9f:	6a 00                	push   $0x0
  800aa1:	ff 75 f4             	pushl  -0xc(%ebp)
  800aa4:	e8 ce f9 ff ff       	call   800477 <fd_close>
		return r;
  800aa9:	83 c4 10             	add    $0x10,%esp
  800aac:	eb 17                	jmp    800ac5 <open+0x85>
	}

	return fd2num(fd);
  800aae:	83 ec 0c             	sub    $0xc,%esp
  800ab1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ab4:	e8 67 f8 ff ff       	call   800320 <fd2num>
  800ab9:	89 c3                	mov    %eax,%ebx
  800abb:	83 c4 10             	add    $0x10,%esp
  800abe:	eb 05                	jmp    800ac5 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ac0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800ac5:	89 d8                	mov    %ebx,%eax
  800ac7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aca:	5b                   	pop    %ebx
  800acb:	5e                   	pop    %esi
  800acc:	c9                   	leave  
  800acd:	c3                   	ret    
	...

00800ad0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
  800ad5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ad8:	83 ec 0c             	sub    $0xc,%esp
  800adb:	ff 75 08             	pushl  0x8(%ebp)
  800ade:	e8 4d f8 ff ff       	call   800330 <fd2data>
  800ae3:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800ae5:	83 c4 08             	add    $0x8,%esp
  800ae8:	68 97 1e 80 00       	push   $0x801e97
  800aed:	56                   	push   %esi
  800aee:	e8 6f 0b 00 00       	call   801662 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800af3:	8b 43 04             	mov    0x4(%ebx),%eax
  800af6:	2b 03                	sub    (%ebx),%eax
  800af8:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800afe:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800b05:	00 00 00 
	stat->st_dev = &devpipe;
  800b08:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800b0f:	30 80 00 
	return 0;
}
  800b12:	b8 00 00 00 00       	mov    $0x0,%eax
  800b17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	c9                   	leave  
  800b1d:	c3                   	ret    

00800b1e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	53                   	push   %ebx
  800b22:	83 ec 0c             	sub    $0xc,%esp
  800b25:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b28:	53                   	push   %ebx
  800b29:	6a 00                	push   $0x0
  800b2b:	e8 d2 f6 ff ff       	call   800202 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b30:	89 1c 24             	mov    %ebx,(%esp)
  800b33:	e8 f8 f7 ff ff       	call   800330 <fd2data>
  800b38:	83 c4 08             	add    $0x8,%esp
  800b3b:	50                   	push   %eax
  800b3c:	6a 00                	push   $0x0
  800b3e:	e8 bf f6 ff ff       	call   800202 <sys_page_unmap>
}
  800b43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b46:	c9                   	leave  
  800b47:	c3                   	ret    

00800b48 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
  800b4e:	83 ec 1c             	sub    $0x1c,%esp
  800b51:	89 c7                	mov    %eax,%edi
  800b53:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b56:	a1 04 40 80 00       	mov    0x804004,%eax
  800b5b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800b5e:	83 ec 0c             	sub    $0xc,%esp
  800b61:	57                   	push   %edi
  800b62:	e8 a1 0f 00 00       	call   801b08 <pageref>
  800b67:	89 c6                	mov    %eax,%esi
  800b69:	83 c4 04             	add    $0x4,%esp
  800b6c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b6f:	e8 94 0f 00 00       	call   801b08 <pageref>
  800b74:	83 c4 10             	add    $0x10,%esp
  800b77:	39 c6                	cmp    %eax,%esi
  800b79:	0f 94 c0             	sete   %al
  800b7c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800b7f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800b85:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800b88:	39 cb                	cmp    %ecx,%ebx
  800b8a:	75 08                	jne    800b94 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800b8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	c9                   	leave  
  800b93:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800b94:	83 f8 01             	cmp    $0x1,%eax
  800b97:	75 bd                	jne    800b56 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800b99:	8b 42 58             	mov    0x58(%edx),%eax
  800b9c:	6a 01                	push   $0x1
  800b9e:	50                   	push   %eax
  800b9f:	53                   	push   %ebx
  800ba0:	68 9e 1e 80 00       	push   $0x801e9e
  800ba5:	e8 02 05 00 00       	call   8010ac <cprintf>
  800baa:	83 c4 10             	add    $0x10,%esp
  800bad:	eb a7                	jmp    800b56 <_pipeisclosed+0xe>

00800baf <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
  800bb5:	83 ec 28             	sub    $0x28,%esp
  800bb8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800bbb:	56                   	push   %esi
  800bbc:	e8 6f f7 ff ff       	call   800330 <fd2data>
  800bc1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bc3:	83 c4 10             	add    $0x10,%esp
  800bc6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bca:	75 4a                	jne    800c16 <devpipe_write+0x67>
  800bcc:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd1:	eb 56                	jmp    800c29 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800bd3:	89 da                	mov    %ebx,%edx
  800bd5:	89 f0                	mov    %esi,%eax
  800bd7:	e8 6c ff ff ff       	call   800b48 <_pipeisclosed>
  800bdc:	85 c0                	test   %eax,%eax
  800bde:	75 4d                	jne    800c2d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800be0:	e8 ac f5 ff ff       	call   800191 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800be5:	8b 43 04             	mov    0x4(%ebx),%eax
  800be8:	8b 13                	mov    (%ebx),%edx
  800bea:	83 c2 20             	add    $0x20,%edx
  800bed:	39 d0                	cmp    %edx,%eax
  800bef:	73 e2                	jae    800bd3 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800bf1:	89 c2                	mov    %eax,%edx
  800bf3:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800bf9:	79 05                	jns    800c00 <devpipe_write+0x51>
  800bfb:	4a                   	dec    %edx
  800bfc:	83 ca e0             	or     $0xffffffe0,%edx
  800bff:	42                   	inc    %edx
  800c00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c03:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800c06:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c0a:	40                   	inc    %eax
  800c0b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c0e:	47                   	inc    %edi
  800c0f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c12:	77 07                	ja     800c1b <devpipe_write+0x6c>
  800c14:	eb 13                	jmp    800c29 <devpipe_write+0x7a>
  800c16:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c1b:	8b 43 04             	mov    0x4(%ebx),%eax
  800c1e:	8b 13                	mov    (%ebx),%edx
  800c20:	83 c2 20             	add    $0x20,%edx
  800c23:	39 d0                	cmp    %edx,%eax
  800c25:	73 ac                	jae    800bd3 <devpipe_write+0x24>
  800c27:	eb c8                	jmp    800bf1 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c29:	89 f8                	mov    %edi,%eax
  800c2b:	eb 05                	jmp    800c32 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c2d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5f                   	pop    %edi
  800c38:	c9                   	leave  
  800c39:	c3                   	ret    

00800c3a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	57                   	push   %edi
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
  800c40:	83 ec 18             	sub    $0x18,%esp
  800c43:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c46:	57                   	push   %edi
  800c47:	e8 e4 f6 ff ff       	call   800330 <fd2data>
  800c4c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c4e:	83 c4 10             	add    $0x10,%esp
  800c51:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c55:	75 44                	jne    800c9b <devpipe_read+0x61>
  800c57:	be 00 00 00 00       	mov    $0x0,%esi
  800c5c:	eb 4f                	jmp    800cad <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c5e:	89 f0                	mov    %esi,%eax
  800c60:	eb 54                	jmp    800cb6 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c62:	89 da                	mov    %ebx,%edx
  800c64:	89 f8                	mov    %edi,%eax
  800c66:	e8 dd fe ff ff       	call   800b48 <_pipeisclosed>
  800c6b:	85 c0                	test   %eax,%eax
  800c6d:	75 42                	jne    800cb1 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c6f:	e8 1d f5 ff ff       	call   800191 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800c74:	8b 03                	mov    (%ebx),%eax
  800c76:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c79:	74 e7                	je     800c62 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800c7b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c80:	79 05                	jns    800c87 <devpipe_read+0x4d>
  800c82:	48                   	dec    %eax
  800c83:	83 c8 e0             	or     $0xffffffe0,%eax
  800c86:	40                   	inc    %eax
  800c87:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800c8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c8e:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800c91:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c93:	46                   	inc    %esi
  800c94:	39 75 10             	cmp    %esi,0x10(%ebp)
  800c97:	77 07                	ja     800ca0 <devpipe_read+0x66>
  800c99:	eb 12                	jmp    800cad <devpipe_read+0x73>
  800c9b:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800ca0:	8b 03                	mov    (%ebx),%eax
  800ca2:	3b 43 04             	cmp    0x4(%ebx),%eax
  800ca5:	75 d4                	jne    800c7b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ca7:	85 f6                	test   %esi,%esi
  800ca9:	75 b3                	jne    800c5e <devpipe_read+0x24>
  800cab:	eb b5                	jmp    800c62 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cad:	89 f0                	mov    %esi,%eax
  800caf:	eb 05                	jmp    800cb6 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cb1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	c9                   	leave  
  800cbd:	c3                   	ret    

00800cbe <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
  800cc4:	83 ec 28             	sub    $0x28,%esp
  800cc7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800cca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ccd:	50                   	push   %eax
  800cce:	e8 75 f6 ff ff       	call   800348 <fd_alloc>
  800cd3:	89 c3                	mov    %eax,%ebx
  800cd5:	83 c4 10             	add    $0x10,%esp
  800cd8:	85 c0                	test   %eax,%eax
  800cda:	0f 88 24 01 00 00    	js     800e04 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ce0:	83 ec 04             	sub    $0x4,%esp
  800ce3:	68 07 04 00 00       	push   $0x407
  800ce8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ceb:	6a 00                	push   $0x0
  800ced:	e8 c6 f4 ff ff       	call   8001b8 <sys_page_alloc>
  800cf2:	89 c3                	mov    %eax,%ebx
  800cf4:	83 c4 10             	add    $0x10,%esp
  800cf7:	85 c0                	test   %eax,%eax
  800cf9:	0f 88 05 01 00 00    	js     800e04 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800cff:	83 ec 0c             	sub    $0xc,%esp
  800d02:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800d05:	50                   	push   %eax
  800d06:	e8 3d f6 ff ff       	call   800348 <fd_alloc>
  800d0b:	89 c3                	mov    %eax,%ebx
  800d0d:	83 c4 10             	add    $0x10,%esp
  800d10:	85 c0                	test   %eax,%eax
  800d12:	0f 88 dc 00 00 00    	js     800df4 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d18:	83 ec 04             	sub    $0x4,%esp
  800d1b:	68 07 04 00 00       	push   $0x407
  800d20:	ff 75 e0             	pushl  -0x20(%ebp)
  800d23:	6a 00                	push   $0x0
  800d25:	e8 8e f4 ff ff       	call   8001b8 <sys_page_alloc>
  800d2a:	89 c3                	mov    %eax,%ebx
  800d2c:	83 c4 10             	add    $0x10,%esp
  800d2f:	85 c0                	test   %eax,%eax
  800d31:	0f 88 bd 00 00 00    	js     800df4 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d37:	83 ec 0c             	sub    $0xc,%esp
  800d3a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d3d:	e8 ee f5 ff ff       	call   800330 <fd2data>
  800d42:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d44:	83 c4 0c             	add    $0xc,%esp
  800d47:	68 07 04 00 00       	push   $0x407
  800d4c:	50                   	push   %eax
  800d4d:	6a 00                	push   $0x0
  800d4f:	e8 64 f4 ff ff       	call   8001b8 <sys_page_alloc>
  800d54:	89 c3                	mov    %eax,%ebx
  800d56:	83 c4 10             	add    $0x10,%esp
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	0f 88 83 00 00 00    	js     800de4 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d61:	83 ec 0c             	sub    $0xc,%esp
  800d64:	ff 75 e0             	pushl  -0x20(%ebp)
  800d67:	e8 c4 f5 ff ff       	call   800330 <fd2data>
  800d6c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d73:	50                   	push   %eax
  800d74:	6a 00                	push   $0x0
  800d76:	56                   	push   %esi
  800d77:	6a 00                	push   $0x0
  800d79:	e8 5e f4 ff ff       	call   8001dc <sys_page_map>
  800d7e:	89 c3                	mov    %eax,%ebx
  800d80:	83 c4 20             	add    $0x20,%esp
  800d83:	85 c0                	test   %eax,%eax
  800d85:	78 4f                	js     800dd6 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800d87:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d90:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800d92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d95:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800d9c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800da2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800da5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800da7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800daa:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800db7:	e8 64 f5 ff ff       	call   800320 <fd2num>
  800dbc:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800dbe:	83 c4 04             	add    $0x4,%esp
  800dc1:	ff 75 e0             	pushl  -0x20(%ebp)
  800dc4:	e8 57 f5 ff ff       	call   800320 <fd2num>
  800dc9:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800dcc:	83 c4 10             	add    $0x10,%esp
  800dcf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd4:	eb 2e                	jmp    800e04 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800dd6:	83 ec 08             	sub    $0x8,%esp
  800dd9:	56                   	push   %esi
  800dda:	6a 00                	push   $0x0
  800ddc:	e8 21 f4 ff ff       	call   800202 <sys_page_unmap>
  800de1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800de4:	83 ec 08             	sub    $0x8,%esp
  800de7:	ff 75 e0             	pushl  -0x20(%ebp)
  800dea:	6a 00                	push   $0x0
  800dec:	e8 11 f4 ff ff       	call   800202 <sys_page_unmap>
  800df1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800df4:	83 ec 08             	sub    $0x8,%esp
  800df7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800dfa:	6a 00                	push   $0x0
  800dfc:	e8 01 f4 ff ff       	call   800202 <sys_page_unmap>
  800e01:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800e04:	89 d8                	mov    %ebx,%eax
  800e06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	c9                   	leave  
  800e0d:	c3                   	ret    

00800e0e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e17:	50                   	push   %eax
  800e18:	ff 75 08             	pushl  0x8(%ebp)
  800e1b:	e8 9b f5 ff ff       	call   8003bb <fd_lookup>
  800e20:	83 c4 10             	add    $0x10,%esp
  800e23:	85 c0                	test   %eax,%eax
  800e25:	78 18                	js     800e3f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e27:	83 ec 0c             	sub    $0xc,%esp
  800e2a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e2d:	e8 fe f4 ff ff       	call   800330 <fd2data>
	return _pipeisclosed(fd, p);
  800e32:	89 c2                	mov    %eax,%edx
  800e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e37:	e8 0c fd ff ff       	call   800b48 <_pipeisclosed>
  800e3c:	83 c4 10             	add    $0x10,%esp
}
  800e3f:	c9                   	leave  
  800e40:	c3                   	ret    
  800e41:	00 00                	add    %al,(%eax)
	...

00800e44 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e47:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4c:	c9                   	leave  
  800e4d:	c3                   	ret    

00800e4e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e54:	68 b6 1e 80 00       	push   $0x801eb6
  800e59:	ff 75 0c             	pushl  0xc(%ebp)
  800e5c:	e8 01 08 00 00       	call   801662 <strcpy>
	return 0;
}
  800e61:	b8 00 00 00 00       	mov    $0x0,%eax
  800e66:	c9                   	leave  
  800e67:	c3                   	ret    

00800e68 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	57                   	push   %edi
  800e6c:	56                   	push   %esi
  800e6d:	53                   	push   %ebx
  800e6e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e74:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e78:	74 45                	je     800ebf <devcons_write+0x57>
  800e7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800e84:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800e8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e8d:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800e8f:	83 fb 7f             	cmp    $0x7f,%ebx
  800e92:	76 05                	jbe    800e99 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800e94:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800e99:	83 ec 04             	sub    $0x4,%esp
  800e9c:	53                   	push   %ebx
  800e9d:	03 45 0c             	add    0xc(%ebp),%eax
  800ea0:	50                   	push   %eax
  800ea1:	57                   	push   %edi
  800ea2:	e8 7c 09 00 00       	call   801823 <memmove>
		sys_cputs(buf, m);
  800ea7:	83 c4 08             	add    $0x8,%esp
  800eaa:	53                   	push   %ebx
  800eab:	57                   	push   %edi
  800eac:	e8 50 f2 ff ff       	call   800101 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eb1:	01 de                	add    %ebx,%esi
  800eb3:	89 f0                	mov    %esi,%eax
  800eb5:	83 c4 10             	add    $0x10,%esp
  800eb8:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ebb:	72 cd                	jb     800e8a <devcons_write+0x22>
  800ebd:	eb 05                	jmp    800ec4 <devcons_write+0x5c>
  800ebf:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800ec4:	89 f0                	mov    %esi,%eax
  800ec6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec9:	5b                   	pop    %ebx
  800eca:	5e                   	pop    %esi
  800ecb:	5f                   	pop    %edi
  800ecc:	c9                   	leave  
  800ecd:	c3                   	ret    

00800ece <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800ed4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ed8:	75 07                	jne    800ee1 <devcons_read+0x13>
  800eda:	eb 25                	jmp    800f01 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800edc:	e8 b0 f2 ff ff       	call   800191 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800ee1:	e8 41 f2 ff ff       	call   800127 <sys_cgetc>
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	74 f2                	je     800edc <devcons_read+0xe>
  800eea:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800eec:	85 c0                	test   %eax,%eax
  800eee:	78 1d                	js     800f0d <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800ef0:	83 f8 04             	cmp    $0x4,%eax
  800ef3:	74 13                	je     800f08 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800ef5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef8:	88 10                	mov    %dl,(%eax)
	return 1;
  800efa:	b8 01 00 00 00       	mov    $0x1,%eax
  800eff:	eb 0c                	jmp    800f0d <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f01:	b8 00 00 00 00       	mov    $0x0,%eax
  800f06:	eb 05                	jmp    800f0d <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f08:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f0d:	c9                   	leave  
  800f0e:	c3                   	ret    

00800f0f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f0f:	55                   	push   %ebp
  800f10:	89 e5                	mov    %esp,%ebp
  800f12:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f15:	8b 45 08             	mov    0x8(%ebp),%eax
  800f18:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f1b:	6a 01                	push   $0x1
  800f1d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f20:	50                   	push   %eax
  800f21:	e8 db f1 ff ff       	call   800101 <sys_cputs>
  800f26:	83 c4 10             	add    $0x10,%esp
}
  800f29:	c9                   	leave  
  800f2a:	c3                   	ret    

00800f2b <getchar>:

int
getchar(void)
{
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f31:	6a 01                	push   $0x1
  800f33:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f36:	50                   	push   %eax
  800f37:	6a 00                	push   $0x0
  800f39:	e8 fe f6 ff ff       	call   80063c <read>
	if (r < 0)
  800f3e:	83 c4 10             	add    $0x10,%esp
  800f41:	85 c0                	test   %eax,%eax
  800f43:	78 0f                	js     800f54 <getchar+0x29>
		return r;
	if (r < 1)
  800f45:	85 c0                	test   %eax,%eax
  800f47:	7e 06                	jle    800f4f <getchar+0x24>
		return -E_EOF;
	return c;
  800f49:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f4d:	eb 05                	jmp    800f54 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f4f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f54:	c9                   	leave  
  800f55:	c3                   	ret    

00800f56 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f5f:	50                   	push   %eax
  800f60:	ff 75 08             	pushl  0x8(%ebp)
  800f63:	e8 53 f4 ff ff       	call   8003bb <fd_lookup>
  800f68:	83 c4 10             	add    $0x10,%esp
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	78 11                	js     800f80 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f72:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f78:	39 10                	cmp    %edx,(%eax)
  800f7a:	0f 94 c0             	sete   %al
  800f7d:	0f b6 c0             	movzbl %al,%eax
}
  800f80:	c9                   	leave  
  800f81:	c3                   	ret    

00800f82 <opencons>:

int
opencons(void)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800f88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f8b:	50                   	push   %eax
  800f8c:	e8 b7 f3 ff ff       	call   800348 <fd_alloc>
  800f91:	83 c4 10             	add    $0x10,%esp
  800f94:	85 c0                	test   %eax,%eax
  800f96:	78 3a                	js     800fd2 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800f98:	83 ec 04             	sub    $0x4,%esp
  800f9b:	68 07 04 00 00       	push   $0x407
  800fa0:	ff 75 f4             	pushl  -0xc(%ebp)
  800fa3:	6a 00                	push   $0x0
  800fa5:	e8 0e f2 ff ff       	call   8001b8 <sys_page_alloc>
  800faa:	83 c4 10             	add    $0x10,%esp
  800fad:	85 c0                	test   %eax,%eax
  800faf:	78 21                	js     800fd2 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fb1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fba:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fbf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fc6:	83 ec 0c             	sub    $0xc,%esp
  800fc9:	50                   	push   %eax
  800fca:	e8 51 f3 ff ff       	call   800320 <fd2num>
  800fcf:	83 c4 10             	add    $0x10,%esp
}
  800fd2:	c9                   	leave  
  800fd3:	c3                   	ret    

00800fd4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	56                   	push   %esi
  800fd8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fd9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fdc:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800fe2:	e8 86 f1 ff ff       	call   80016d <sys_getenvid>
  800fe7:	83 ec 0c             	sub    $0xc,%esp
  800fea:	ff 75 0c             	pushl  0xc(%ebp)
  800fed:	ff 75 08             	pushl  0x8(%ebp)
  800ff0:	53                   	push   %ebx
  800ff1:	50                   	push   %eax
  800ff2:	68 c4 1e 80 00       	push   $0x801ec4
  800ff7:	e8 b0 00 00 00       	call   8010ac <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ffc:	83 c4 18             	add    $0x18,%esp
  800fff:	56                   	push   %esi
  801000:	ff 75 10             	pushl  0x10(%ebp)
  801003:	e8 53 00 00 00       	call   80105b <vcprintf>
	cprintf("\n");
  801008:	c7 04 24 af 1e 80 00 	movl   $0x801eaf,(%esp)
  80100f:	e8 98 00 00 00       	call   8010ac <cprintf>
  801014:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801017:	cc                   	int3   
  801018:	eb fd                	jmp    801017 <_panic+0x43>
	...

0080101c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	53                   	push   %ebx
  801020:	83 ec 04             	sub    $0x4,%esp
  801023:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801026:	8b 03                	mov    (%ebx),%eax
  801028:	8b 55 08             	mov    0x8(%ebp),%edx
  80102b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80102f:	40                   	inc    %eax
  801030:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801032:	3d ff 00 00 00       	cmp    $0xff,%eax
  801037:	75 1a                	jne    801053 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  801039:	83 ec 08             	sub    $0x8,%esp
  80103c:	68 ff 00 00 00       	push   $0xff
  801041:	8d 43 08             	lea    0x8(%ebx),%eax
  801044:	50                   	push   %eax
  801045:	e8 b7 f0 ff ff       	call   800101 <sys_cputs>
		b->idx = 0;
  80104a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801050:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801053:	ff 43 04             	incl   0x4(%ebx)
}
  801056:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801059:	c9                   	leave  
  80105a:	c3                   	ret    

0080105b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801064:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80106b:	00 00 00 
	b.cnt = 0;
  80106e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801075:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801078:	ff 75 0c             	pushl  0xc(%ebp)
  80107b:	ff 75 08             	pushl  0x8(%ebp)
  80107e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801084:	50                   	push   %eax
  801085:	68 1c 10 80 00       	push   $0x80101c
  80108a:	e8 82 01 00 00       	call   801211 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80108f:	83 c4 08             	add    $0x8,%esp
  801092:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801098:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80109e:	50                   	push   %eax
  80109f:	e8 5d f0 ff ff       	call   800101 <sys_cputs>

	return b.cnt;
}
  8010a4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010aa:	c9                   	leave  
  8010ab:	c3                   	ret    

008010ac <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010b2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010b5:	50                   	push   %eax
  8010b6:	ff 75 08             	pushl  0x8(%ebp)
  8010b9:	e8 9d ff ff ff       	call   80105b <vcprintf>
	va_end(ap);

	return cnt;
}
  8010be:	c9                   	leave  
  8010bf:	c3                   	ret    

008010c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	57                   	push   %edi
  8010c4:	56                   	push   %esi
  8010c5:	53                   	push   %ebx
  8010c6:	83 ec 2c             	sub    $0x2c,%esp
  8010c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010cc:	89 d6                	mov    %edx,%esi
  8010ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8010da:	8b 45 10             	mov    0x10(%ebp),%eax
  8010dd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010e0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8010e6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8010ed:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8010f0:	72 0c                	jb     8010fe <printnum+0x3e>
  8010f2:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8010f5:	76 07                	jbe    8010fe <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8010f7:	4b                   	dec    %ebx
  8010f8:	85 db                	test   %ebx,%ebx
  8010fa:	7f 31                	jg     80112d <printnum+0x6d>
  8010fc:	eb 3f                	jmp    80113d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8010fe:	83 ec 0c             	sub    $0xc,%esp
  801101:	57                   	push   %edi
  801102:	4b                   	dec    %ebx
  801103:	53                   	push   %ebx
  801104:	50                   	push   %eax
  801105:	83 ec 08             	sub    $0x8,%esp
  801108:	ff 75 d4             	pushl  -0x2c(%ebp)
  80110b:	ff 75 d0             	pushl  -0x30(%ebp)
  80110e:	ff 75 dc             	pushl  -0x24(%ebp)
  801111:	ff 75 d8             	pushl  -0x28(%ebp)
  801114:	e8 33 0a 00 00       	call   801b4c <__udivdi3>
  801119:	83 c4 18             	add    $0x18,%esp
  80111c:	52                   	push   %edx
  80111d:	50                   	push   %eax
  80111e:	89 f2                	mov    %esi,%edx
  801120:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801123:	e8 98 ff ff ff       	call   8010c0 <printnum>
  801128:	83 c4 20             	add    $0x20,%esp
  80112b:	eb 10                	jmp    80113d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80112d:	83 ec 08             	sub    $0x8,%esp
  801130:	56                   	push   %esi
  801131:	57                   	push   %edi
  801132:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801135:	4b                   	dec    %ebx
  801136:	83 c4 10             	add    $0x10,%esp
  801139:	85 db                	test   %ebx,%ebx
  80113b:	7f f0                	jg     80112d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80113d:	83 ec 08             	sub    $0x8,%esp
  801140:	56                   	push   %esi
  801141:	83 ec 04             	sub    $0x4,%esp
  801144:	ff 75 d4             	pushl  -0x2c(%ebp)
  801147:	ff 75 d0             	pushl  -0x30(%ebp)
  80114a:	ff 75 dc             	pushl  -0x24(%ebp)
  80114d:	ff 75 d8             	pushl  -0x28(%ebp)
  801150:	e8 13 0b 00 00       	call   801c68 <__umoddi3>
  801155:	83 c4 14             	add    $0x14,%esp
  801158:	0f be 80 e7 1e 80 00 	movsbl 0x801ee7(%eax),%eax
  80115f:	50                   	push   %eax
  801160:	ff 55 e4             	call   *-0x1c(%ebp)
  801163:	83 c4 10             	add    $0x10,%esp
}
  801166:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801169:	5b                   	pop    %ebx
  80116a:	5e                   	pop    %esi
  80116b:	5f                   	pop    %edi
  80116c:	c9                   	leave  
  80116d:	c3                   	ret    

0080116e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801171:	83 fa 01             	cmp    $0x1,%edx
  801174:	7e 0e                	jle    801184 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801176:	8b 10                	mov    (%eax),%edx
  801178:	8d 4a 08             	lea    0x8(%edx),%ecx
  80117b:	89 08                	mov    %ecx,(%eax)
  80117d:	8b 02                	mov    (%edx),%eax
  80117f:	8b 52 04             	mov    0x4(%edx),%edx
  801182:	eb 22                	jmp    8011a6 <getuint+0x38>
	else if (lflag)
  801184:	85 d2                	test   %edx,%edx
  801186:	74 10                	je     801198 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801188:	8b 10                	mov    (%eax),%edx
  80118a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80118d:	89 08                	mov    %ecx,(%eax)
  80118f:	8b 02                	mov    (%edx),%eax
  801191:	ba 00 00 00 00       	mov    $0x0,%edx
  801196:	eb 0e                	jmp    8011a6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801198:	8b 10                	mov    (%eax),%edx
  80119a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80119d:	89 08                	mov    %ecx,(%eax)
  80119f:	8b 02                	mov    (%edx),%eax
  8011a1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011a6:	c9                   	leave  
  8011a7:	c3                   	ret    

008011a8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011ab:	83 fa 01             	cmp    $0x1,%edx
  8011ae:	7e 0e                	jle    8011be <getint+0x16>
		return va_arg(*ap, long long);
  8011b0:	8b 10                	mov    (%eax),%edx
  8011b2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011b5:	89 08                	mov    %ecx,(%eax)
  8011b7:	8b 02                	mov    (%edx),%eax
  8011b9:	8b 52 04             	mov    0x4(%edx),%edx
  8011bc:	eb 1a                	jmp    8011d8 <getint+0x30>
	else if (lflag)
  8011be:	85 d2                	test   %edx,%edx
  8011c0:	74 0c                	je     8011ce <getint+0x26>
		return va_arg(*ap, long);
  8011c2:	8b 10                	mov    (%eax),%edx
  8011c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011c7:	89 08                	mov    %ecx,(%eax)
  8011c9:	8b 02                	mov    (%edx),%eax
  8011cb:	99                   	cltd   
  8011cc:	eb 0a                	jmp    8011d8 <getint+0x30>
	else
		return va_arg(*ap, int);
  8011ce:	8b 10                	mov    (%eax),%edx
  8011d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011d3:	89 08                	mov    %ecx,(%eax)
  8011d5:	8b 02                	mov    (%edx),%eax
  8011d7:	99                   	cltd   
}
  8011d8:	c9                   	leave  
  8011d9:	c3                   	ret    

008011da <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011e0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011e3:	8b 10                	mov    (%eax),%edx
  8011e5:	3b 50 04             	cmp    0x4(%eax),%edx
  8011e8:	73 08                	jae    8011f2 <sprintputch+0x18>
		*b->buf++ = ch;
  8011ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ed:	88 0a                	mov    %cl,(%edx)
  8011ef:	42                   	inc    %edx
  8011f0:	89 10                	mov    %edx,(%eax)
}
  8011f2:	c9                   	leave  
  8011f3:	c3                   	ret    

008011f4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011fa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011fd:	50                   	push   %eax
  8011fe:	ff 75 10             	pushl  0x10(%ebp)
  801201:	ff 75 0c             	pushl  0xc(%ebp)
  801204:	ff 75 08             	pushl  0x8(%ebp)
  801207:	e8 05 00 00 00       	call   801211 <vprintfmt>
	va_end(ap);
  80120c:	83 c4 10             	add    $0x10,%esp
}
  80120f:	c9                   	leave  
  801210:	c3                   	ret    

00801211 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	57                   	push   %edi
  801215:	56                   	push   %esi
  801216:	53                   	push   %ebx
  801217:	83 ec 2c             	sub    $0x2c,%esp
  80121a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80121d:	8b 75 10             	mov    0x10(%ebp),%esi
  801220:	eb 13                	jmp    801235 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801222:	85 c0                	test   %eax,%eax
  801224:	0f 84 6d 03 00 00    	je     801597 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80122a:	83 ec 08             	sub    $0x8,%esp
  80122d:	57                   	push   %edi
  80122e:	50                   	push   %eax
  80122f:	ff 55 08             	call   *0x8(%ebp)
  801232:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801235:	0f b6 06             	movzbl (%esi),%eax
  801238:	46                   	inc    %esi
  801239:	83 f8 25             	cmp    $0x25,%eax
  80123c:	75 e4                	jne    801222 <vprintfmt+0x11>
  80123e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  801242:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801249:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801250:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801257:	b9 00 00 00 00       	mov    $0x0,%ecx
  80125c:	eb 28                	jmp    801286 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80125e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801260:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  801264:	eb 20                	jmp    801286 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801266:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801268:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80126c:	eb 18                	jmp    801286 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80126e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801270:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801277:	eb 0d                	jmp    801286 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801279:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80127c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80127f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801286:	8a 06                	mov    (%esi),%al
  801288:	0f b6 d0             	movzbl %al,%edx
  80128b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80128e:	83 e8 23             	sub    $0x23,%eax
  801291:	3c 55                	cmp    $0x55,%al
  801293:	0f 87 e0 02 00 00    	ja     801579 <vprintfmt+0x368>
  801299:	0f b6 c0             	movzbl %al,%eax
  80129c:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012a3:	83 ea 30             	sub    $0x30,%edx
  8012a6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8012a9:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8012ac:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012af:	83 fa 09             	cmp    $0x9,%edx
  8012b2:	77 44                	ja     8012f8 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b4:	89 de                	mov    %ebx,%esi
  8012b6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012b9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012ba:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8012bd:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8012c1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012c4:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8012c7:	83 fb 09             	cmp    $0x9,%ebx
  8012ca:	76 ed                	jbe    8012b9 <vprintfmt+0xa8>
  8012cc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8012cf:	eb 29                	jmp    8012fa <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8012d4:	8d 50 04             	lea    0x4(%eax),%edx
  8012d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8012da:	8b 00                	mov    (%eax),%eax
  8012dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012df:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012e1:	eb 17                	jmp    8012fa <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8012e3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012e7:	78 85                	js     80126e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e9:	89 de                	mov    %ebx,%esi
  8012eb:	eb 99                	jmp    801286 <vprintfmt+0x75>
  8012ed:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012ef:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8012f6:	eb 8e                	jmp    801286 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f8:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8012fa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012fe:	79 86                	jns    801286 <vprintfmt+0x75>
  801300:	e9 74 ff ff ff       	jmp    801279 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801305:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801306:	89 de                	mov    %ebx,%esi
  801308:	e9 79 ff ff ff       	jmp    801286 <vprintfmt+0x75>
  80130d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801310:	8b 45 14             	mov    0x14(%ebp),%eax
  801313:	8d 50 04             	lea    0x4(%eax),%edx
  801316:	89 55 14             	mov    %edx,0x14(%ebp)
  801319:	83 ec 08             	sub    $0x8,%esp
  80131c:	57                   	push   %edi
  80131d:	ff 30                	pushl  (%eax)
  80131f:	ff 55 08             	call   *0x8(%ebp)
			break;
  801322:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801325:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801328:	e9 08 ff ff ff       	jmp    801235 <vprintfmt+0x24>
  80132d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  801330:	8b 45 14             	mov    0x14(%ebp),%eax
  801333:	8d 50 04             	lea    0x4(%eax),%edx
  801336:	89 55 14             	mov    %edx,0x14(%ebp)
  801339:	8b 00                	mov    (%eax),%eax
  80133b:	85 c0                	test   %eax,%eax
  80133d:	79 02                	jns    801341 <vprintfmt+0x130>
  80133f:	f7 d8                	neg    %eax
  801341:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801343:	83 f8 0f             	cmp    $0xf,%eax
  801346:	7f 0b                	jg     801353 <vprintfmt+0x142>
  801348:	8b 04 85 80 21 80 00 	mov    0x802180(,%eax,4),%eax
  80134f:	85 c0                	test   %eax,%eax
  801351:	75 1a                	jne    80136d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  801353:	52                   	push   %edx
  801354:	68 ff 1e 80 00       	push   $0x801eff
  801359:	57                   	push   %edi
  80135a:	ff 75 08             	pushl  0x8(%ebp)
  80135d:	e8 92 fe ff ff       	call   8011f4 <printfmt>
  801362:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801365:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801368:	e9 c8 fe ff ff       	jmp    801235 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80136d:	50                   	push   %eax
  80136e:	68 7d 1e 80 00       	push   $0x801e7d
  801373:	57                   	push   %edi
  801374:	ff 75 08             	pushl  0x8(%ebp)
  801377:	e8 78 fe ff ff       	call   8011f4 <printfmt>
  80137c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801382:	e9 ae fe ff ff       	jmp    801235 <vprintfmt+0x24>
  801387:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80138a:	89 de                	mov    %ebx,%esi
  80138c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80138f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801392:	8b 45 14             	mov    0x14(%ebp),%eax
  801395:	8d 50 04             	lea    0x4(%eax),%edx
  801398:	89 55 14             	mov    %edx,0x14(%ebp)
  80139b:	8b 00                	mov    (%eax),%eax
  80139d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8013a0:	85 c0                	test   %eax,%eax
  8013a2:	75 07                	jne    8013ab <vprintfmt+0x19a>
				p = "(null)";
  8013a4:	c7 45 d0 f8 1e 80 00 	movl   $0x801ef8,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8013ab:	85 db                	test   %ebx,%ebx
  8013ad:	7e 42                	jle    8013f1 <vprintfmt+0x1e0>
  8013af:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8013b3:	74 3c                	je     8013f1 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b5:	83 ec 08             	sub    $0x8,%esp
  8013b8:	51                   	push   %ecx
  8013b9:	ff 75 d0             	pushl  -0x30(%ebp)
  8013bc:	e8 6f 02 00 00       	call   801630 <strnlen>
  8013c1:	29 c3                	sub    %eax,%ebx
  8013c3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8013c6:	83 c4 10             	add    $0x10,%esp
  8013c9:	85 db                	test   %ebx,%ebx
  8013cb:	7e 24                	jle    8013f1 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8013cd:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8013d1:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8013d4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013d7:	83 ec 08             	sub    $0x8,%esp
  8013da:	57                   	push   %edi
  8013db:	53                   	push   %ebx
  8013dc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013df:	4e                   	dec    %esi
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	85 f6                	test   %esi,%esi
  8013e5:	7f f0                	jg     8013d7 <vprintfmt+0x1c6>
  8013e7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8013ea:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013f1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8013f4:	0f be 02             	movsbl (%edx),%eax
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	75 47                	jne    801442 <vprintfmt+0x231>
  8013fb:	eb 37                	jmp    801434 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8013fd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801401:	74 16                	je     801419 <vprintfmt+0x208>
  801403:	8d 50 e0             	lea    -0x20(%eax),%edx
  801406:	83 fa 5e             	cmp    $0x5e,%edx
  801409:	76 0e                	jbe    801419 <vprintfmt+0x208>
					putch('?', putdat);
  80140b:	83 ec 08             	sub    $0x8,%esp
  80140e:	57                   	push   %edi
  80140f:	6a 3f                	push   $0x3f
  801411:	ff 55 08             	call   *0x8(%ebp)
  801414:	83 c4 10             	add    $0x10,%esp
  801417:	eb 0b                	jmp    801424 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  801419:	83 ec 08             	sub    $0x8,%esp
  80141c:	57                   	push   %edi
  80141d:	50                   	push   %eax
  80141e:	ff 55 08             	call   *0x8(%ebp)
  801421:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801424:	ff 4d e4             	decl   -0x1c(%ebp)
  801427:	0f be 03             	movsbl (%ebx),%eax
  80142a:	85 c0                	test   %eax,%eax
  80142c:	74 03                	je     801431 <vprintfmt+0x220>
  80142e:	43                   	inc    %ebx
  80142f:	eb 1b                	jmp    80144c <vprintfmt+0x23b>
  801431:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801434:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801438:	7f 1e                	jg     801458 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80143a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80143d:	e9 f3 fd ff ff       	jmp    801235 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801442:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801445:	43                   	inc    %ebx
  801446:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801449:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80144c:	85 f6                	test   %esi,%esi
  80144e:	78 ad                	js     8013fd <vprintfmt+0x1ec>
  801450:	4e                   	dec    %esi
  801451:	79 aa                	jns    8013fd <vprintfmt+0x1ec>
  801453:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801456:	eb dc                	jmp    801434 <vprintfmt+0x223>
  801458:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80145b:	83 ec 08             	sub    $0x8,%esp
  80145e:	57                   	push   %edi
  80145f:	6a 20                	push   $0x20
  801461:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801464:	4b                   	dec    %ebx
  801465:	83 c4 10             	add    $0x10,%esp
  801468:	85 db                	test   %ebx,%ebx
  80146a:	7f ef                	jg     80145b <vprintfmt+0x24a>
  80146c:	e9 c4 fd ff ff       	jmp    801235 <vprintfmt+0x24>
  801471:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801474:	89 ca                	mov    %ecx,%edx
  801476:	8d 45 14             	lea    0x14(%ebp),%eax
  801479:	e8 2a fd ff ff       	call   8011a8 <getint>
  80147e:	89 c3                	mov    %eax,%ebx
  801480:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  801482:	85 d2                	test   %edx,%edx
  801484:	78 0a                	js     801490 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801486:	b8 0a 00 00 00       	mov    $0xa,%eax
  80148b:	e9 b0 00 00 00       	jmp    801540 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801490:	83 ec 08             	sub    $0x8,%esp
  801493:	57                   	push   %edi
  801494:	6a 2d                	push   $0x2d
  801496:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801499:	f7 db                	neg    %ebx
  80149b:	83 d6 00             	adc    $0x0,%esi
  80149e:	f7 de                	neg    %esi
  8014a0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8014a3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014a8:	e9 93 00 00 00       	jmp    801540 <vprintfmt+0x32f>
  8014ad:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014b0:	89 ca                	mov    %ecx,%edx
  8014b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8014b5:	e8 b4 fc ff ff       	call   80116e <getuint>
  8014ba:	89 c3                	mov    %eax,%ebx
  8014bc:	89 d6                	mov    %edx,%esi
			base = 10;
  8014be:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8014c3:	eb 7b                	jmp    801540 <vprintfmt+0x32f>
  8014c5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8014c8:	89 ca                	mov    %ecx,%edx
  8014ca:	8d 45 14             	lea    0x14(%ebp),%eax
  8014cd:	e8 d6 fc ff ff       	call   8011a8 <getint>
  8014d2:	89 c3                	mov    %eax,%ebx
  8014d4:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8014d6:	85 d2                	test   %edx,%edx
  8014d8:	78 07                	js     8014e1 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8014da:	b8 08 00 00 00       	mov    $0x8,%eax
  8014df:	eb 5f                	jmp    801540 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8014e1:	83 ec 08             	sub    $0x8,%esp
  8014e4:	57                   	push   %edi
  8014e5:	6a 2d                	push   $0x2d
  8014e7:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8014ea:	f7 db                	neg    %ebx
  8014ec:	83 d6 00             	adc    $0x0,%esi
  8014ef:	f7 de                	neg    %esi
  8014f1:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8014f4:	b8 08 00 00 00       	mov    $0x8,%eax
  8014f9:	eb 45                	jmp    801540 <vprintfmt+0x32f>
  8014fb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8014fe:	83 ec 08             	sub    $0x8,%esp
  801501:	57                   	push   %edi
  801502:	6a 30                	push   $0x30
  801504:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801507:	83 c4 08             	add    $0x8,%esp
  80150a:	57                   	push   %edi
  80150b:	6a 78                	push   $0x78
  80150d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801510:	8b 45 14             	mov    0x14(%ebp),%eax
  801513:	8d 50 04             	lea    0x4(%eax),%edx
  801516:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801519:	8b 18                	mov    (%eax),%ebx
  80151b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801520:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801523:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801528:	eb 16                	jmp    801540 <vprintfmt+0x32f>
  80152a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80152d:	89 ca                	mov    %ecx,%edx
  80152f:	8d 45 14             	lea    0x14(%ebp),%eax
  801532:	e8 37 fc ff ff       	call   80116e <getuint>
  801537:	89 c3                	mov    %eax,%ebx
  801539:	89 d6                	mov    %edx,%esi
			base = 16;
  80153b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801540:	83 ec 0c             	sub    $0xc,%esp
  801543:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  801547:	52                   	push   %edx
  801548:	ff 75 e4             	pushl  -0x1c(%ebp)
  80154b:	50                   	push   %eax
  80154c:	56                   	push   %esi
  80154d:	53                   	push   %ebx
  80154e:	89 fa                	mov    %edi,%edx
  801550:	8b 45 08             	mov    0x8(%ebp),%eax
  801553:	e8 68 fb ff ff       	call   8010c0 <printnum>
			break;
  801558:	83 c4 20             	add    $0x20,%esp
  80155b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80155e:	e9 d2 fc ff ff       	jmp    801235 <vprintfmt+0x24>
  801563:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801566:	83 ec 08             	sub    $0x8,%esp
  801569:	57                   	push   %edi
  80156a:	52                   	push   %edx
  80156b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80156e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801571:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801574:	e9 bc fc ff ff       	jmp    801235 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801579:	83 ec 08             	sub    $0x8,%esp
  80157c:	57                   	push   %edi
  80157d:	6a 25                	push   $0x25
  80157f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801582:	83 c4 10             	add    $0x10,%esp
  801585:	eb 02                	jmp    801589 <vprintfmt+0x378>
  801587:	89 c6                	mov    %eax,%esi
  801589:	8d 46 ff             	lea    -0x1(%esi),%eax
  80158c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801590:	75 f5                	jne    801587 <vprintfmt+0x376>
  801592:	e9 9e fc ff ff       	jmp    801235 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  801597:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80159a:	5b                   	pop    %ebx
  80159b:	5e                   	pop    %esi
  80159c:	5f                   	pop    %edi
  80159d:	c9                   	leave  
  80159e:	c3                   	ret    

0080159f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	83 ec 18             	sub    $0x18,%esp
  8015a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015ae:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015b2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	74 26                	je     8015e6 <vsnprintf+0x47>
  8015c0:	85 d2                	test   %edx,%edx
  8015c2:	7e 29                	jle    8015ed <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015c4:	ff 75 14             	pushl  0x14(%ebp)
  8015c7:	ff 75 10             	pushl  0x10(%ebp)
  8015ca:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015cd:	50                   	push   %eax
  8015ce:	68 da 11 80 00       	push   $0x8011da
  8015d3:	e8 39 fc ff ff       	call   801211 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8015d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015db:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8015de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	eb 0c                	jmp    8015f2 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8015e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015eb:	eb 05                	jmp    8015f2 <vsnprintf+0x53>
  8015ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8015f2:	c9                   	leave  
  8015f3:	c3                   	ret    

008015f4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8015fa:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8015fd:	50                   	push   %eax
  8015fe:	ff 75 10             	pushl  0x10(%ebp)
  801601:	ff 75 0c             	pushl  0xc(%ebp)
  801604:	ff 75 08             	pushl  0x8(%ebp)
  801607:	e8 93 ff ff ff       	call   80159f <vsnprintf>
	va_end(ap);

	return rc;
}
  80160c:	c9                   	leave  
  80160d:	c3                   	ret    
	...

00801610 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801616:	80 3a 00             	cmpb   $0x0,(%edx)
  801619:	74 0e                	je     801629 <strlen+0x19>
  80161b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801620:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801621:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801625:	75 f9                	jne    801620 <strlen+0x10>
  801627:	eb 05                	jmp    80162e <strlen+0x1e>
  801629:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80162e:	c9                   	leave  
  80162f:	c3                   	ret    

00801630 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801636:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801639:	85 d2                	test   %edx,%edx
  80163b:	74 17                	je     801654 <strnlen+0x24>
  80163d:	80 39 00             	cmpb   $0x0,(%ecx)
  801640:	74 19                	je     80165b <strnlen+0x2b>
  801642:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801647:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801648:	39 d0                	cmp    %edx,%eax
  80164a:	74 14                	je     801660 <strnlen+0x30>
  80164c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801650:	75 f5                	jne    801647 <strnlen+0x17>
  801652:	eb 0c                	jmp    801660 <strnlen+0x30>
  801654:	b8 00 00 00 00       	mov    $0x0,%eax
  801659:	eb 05                	jmp    801660 <strnlen+0x30>
  80165b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801660:	c9                   	leave  
  801661:	c3                   	ret    

00801662 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	53                   	push   %ebx
  801666:	8b 45 08             	mov    0x8(%ebp),%eax
  801669:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80166c:	ba 00 00 00 00       	mov    $0x0,%edx
  801671:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801674:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801677:	42                   	inc    %edx
  801678:	84 c9                	test   %cl,%cl
  80167a:	75 f5                	jne    801671 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80167c:	5b                   	pop    %ebx
  80167d:	c9                   	leave  
  80167e:	c3                   	ret    

0080167f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	53                   	push   %ebx
  801683:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801686:	53                   	push   %ebx
  801687:	e8 84 ff ff ff       	call   801610 <strlen>
  80168c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80168f:	ff 75 0c             	pushl  0xc(%ebp)
  801692:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801695:	50                   	push   %eax
  801696:	e8 c7 ff ff ff       	call   801662 <strcpy>
	return dst;
}
  80169b:	89 d8                	mov    %ebx,%eax
  80169d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a0:	c9                   	leave  
  8016a1:	c3                   	ret    

008016a2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016a2:	55                   	push   %ebp
  8016a3:	89 e5                	mov    %esp,%ebp
  8016a5:	56                   	push   %esi
  8016a6:	53                   	push   %ebx
  8016a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016ad:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016b0:	85 f6                	test   %esi,%esi
  8016b2:	74 15                	je     8016c9 <strncpy+0x27>
  8016b4:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8016b9:	8a 1a                	mov    (%edx),%bl
  8016bb:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016be:	80 3a 01             	cmpb   $0x1,(%edx)
  8016c1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016c4:	41                   	inc    %ecx
  8016c5:	39 ce                	cmp    %ecx,%esi
  8016c7:	77 f0                	ja     8016b9 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016c9:	5b                   	pop    %ebx
  8016ca:	5e                   	pop    %esi
  8016cb:	c9                   	leave  
  8016cc:	c3                   	ret    

008016cd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	57                   	push   %edi
  8016d1:	56                   	push   %esi
  8016d2:	53                   	push   %ebx
  8016d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016d9:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016dc:	85 f6                	test   %esi,%esi
  8016de:	74 32                	je     801712 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8016e0:	83 fe 01             	cmp    $0x1,%esi
  8016e3:	74 22                	je     801707 <strlcpy+0x3a>
  8016e5:	8a 0b                	mov    (%ebx),%cl
  8016e7:	84 c9                	test   %cl,%cl
  8016e9:	74 20                	je     80170b <strlcpy+0x3e>
  8016eb:	89 f8                	mov    %edi,%eax
  8016ed:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8016f2:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8016f5:	88 08                	mov    %cl,(%eax)
  8016f7:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8016f8:	39 f2                	cmp    %esi,%edx
  8016fa:	74 11                	je     80170d <strlcpy+0x40>
  8016fc:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  801700:	42                   	inc    %edx
  801701:	84 c9                	test   %cl,%cl
  801703:	75 f0                	jne    8016f5 <strlcpy+0x28>
  801705:	eb 06                	jmp    80170d <strlcpy+0x40>
  801707:	89 f8                	mov    %edi,%eax
  801709:	eb 02                	jmp    80170d <strlcpy+0x40>
  80170b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80170d:	c6 00 00             	movb   $0x0,(%eax)
  801710:	eb 02                	jmp    801714 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801712:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  801714:	29 f8                	sub    %edi,%eax
}
  801716:	5b                   	pop    %ebx
  801717:	5e                   	pop    %esi
  801718:	5f                   	pop    %edi
  801719:	c9                   	leave  
  80171a:	c3                   	ret    

0080171b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80171b:	55                   	push   %ebp
  80171c:	89 e5                	mov    %esp,%ebp
  80171e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801721:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801724:	8a 01                	mov    (%ecx),%al
  801726:	84 c0                	test   %al,%al
  801728:	74 10                	je     80173a <strcmp+0x1f>
  80172a:	3a 02                	cmp    (%edx),%al
  80172c:	75 0c                	jne    80173a <strcmp+0x1f>
		p++, q++;
  80172e:	41                   	inc    %ecx
  80172f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801730:	8a 01                	mov    (%ecx),%al
  801732:	84 c0                	test   %al,%al
  801734:	74 04                	je     80173a <strcmp+0x1f>
  801736:	3a 02                	cmp    (%edx),%al
  801738:	74 f4                	je     80172e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80173a:	0f b6 c0             	movzbl %al,%eax
  80173d:	0f b6 12             	movzbl (%edx),%edx
  801740:	29 d0                	sub    %edx,%eax
}
  801742:	c9                   	leave  
  801743:	c3                   	ret    

00801744 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	53                   	push   %ebx
  801748:	8b 55 08             	mov    0x8(%ebp),%edx
  80174b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80174e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801751:	85 c0                	test   %eax,%eax
  801753:	74 1b                	je     801770 <strncmp+0x2c>
  801755:	8a 1a                	mov    (%edx),%bl
  801757:	84 db                	test   %bl,%bl
  801759:	74 24                	je     80177f <strncmp+0x3b>
  80175b:	3a 19                	cmp    (%ecx),%bl
  80175d:	75 20                	jne    80177f <strncmp+0x3b>
  80175f:	48                   	dec    %eax
  801760:	74 15                	je     801777 <strncmp+0x33>
		n--, p++, q++;
  801762:	42                   	inc    %edx
  801763:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801764:	8a 1a                	mov    (%edx),%bl
  801766:	84 db                	test   %bl,%bl
  801768:	74 15                	je     80177f <strncmp+0x3b>
  80176a:	3a 19                	cmp    (%ecx),%bl
  80176c:	74 f1                	je     80175f <strncmp+0x1b>
  80176e:	eb 0f                	jmp    80177f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  801770:	b8 00 00 00 00       	mov    $0x0,%eax
  801775:	eb 05                	jmp    80177c <strncmp+0x38>
  801777:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80177c:	5b                   	pop    %ebx
  80177d:	c9                   	leave  
  80177e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80177f:	0f b6 02             	movzbl (%edx),%eax
  801782:	0f b6 11             	movzbl (%ecx),%edx
  801785:	29 d0                	sub    %edx,%eax
  801787:	eb f3                	jmp    80177c <strncmp+0x38>

00801789 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	8b 45 08             	mov    0x8(%ebp),%eax
  80178f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801792:	8a 10                	mov    (%eax),%dl
  801794:	84 d2                	test   %dl,%dl
  801796:	74 18                	je     8017b0 <strchr+0x27>
		if (*s == c)
  801798:	38 ca                	cmp    %cl,%dl
  80179a:	75 06                	jne    8017a2 <strchr+0x19>
  80179c:	eb 17                	jmp    8017b5 <strchr+0x2c>
  80179e:	38 ca                	cmp    %cl,%dl
  8017a0:	74 13                	je     8017b5 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017a2:	40                   	inc    %eax
  8017a3:	8a 10                	mov    (%eax),%dl
  8017a5:	84 d2                	test   %dl,%dl
  8017a7:	75 f5                	jne    80179e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8017a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ae:	eb 05                	jmp    8017b5 <strchr+0x2c>
  8017b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017b5:	c9                   	leave  
  8017b6:	c3                   	ret    

008017b7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bd:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017c0:	8a 10                	mov    (%eax),%dl
  8017c2:	84 d2                	test   %dl,%dl
  8017c4:	74 11                	je     8017d7 <strfind+0x20>
		if (*s == c)
  8017c6:	38 ca                	cmp    %cl,%dl
  8017c8:	75 06                	jne    8017d0 <strfind+0x19>
  8017ca:	eb 0b                	jmp    8017d7 <strfind+0x20>
  8017cc:	38 ca                	cmp    %cl,%dl
  8017ce:	74 07                	je     8017d7 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8017d0:	40                   	inc    %eax
  8017d1:	8a 10                	mov    (%eax),%dl
  8017d3:	84 d2                	test   %dl,%dl
  8017d5:	75 f5                	jne    8017cc <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8017d7:	c9                   	leave  
  8017d8:	c3                   	ret    

008017d9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	57                   	push   %edi
  8017dd:	56                   	push   %esi
  8017de:	53                   	push   %ebx
  8017df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017e8:	85 c9                	test   %ecx,%ecx
  8017ea:	74 30                	je     80181c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017ec:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017f2:	75 25                	jne    801819 <memset+0x40>
  8017f4:	f6 c1 03             	test   $0x3,%cl
  8017f7:	75 20                	jne    801819 <memset+0x40>
		c &= 0xFF;
  8017f9:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017fc:	89 d3                	mov    %edx,%ebx
  8017fe:	c1 e3 08             	shl    $0x8,%ebx
  801801:	89 d6                	mov    %edx,%esi
  801803:	c1 e6 18             	shl    $0x18,%esi
  801806:	89 d0                	mov    %edx,%eax
  801808:	c1 e0 10             	shl    $0x10,%eax
  80180b:	09 f0                	or     %esi,%eax
  80180d:	09 d0                	or     %edx,%eax
  80180f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801811:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801814:	fc                   	cld    
  801815:	f3 ab                	rep stos %eax,%es:(%edi)
  801817:	eb 03                	jmp    80181c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801819:	fc                   	cld    
  80181a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80181c:	89 f8                	mov    %edi,%eax
  80181e:	5b                   	pop    %ebx
  80181f:	5e                   	pop    %esi
  801820:	5f                   	pop    %edi
  801821:	c9                   	leave  
  801822:	c3                   	ret    

00801823 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	57                   	push   %edi
  801827:	56                   	push   %esi
  801828:	8b 45 08             	mov    0x8(%ebp),%eax
  80182b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80182e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801831:	39 c6                	cmp    %eax,%esi
  801833:	73 34                	jae    801869 <memmove+0x46>
  801835:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801838:	39 d0                	cmp    %edx,%eax
  80183a:	73 2d                	jae    801869 <memmove+0x46>
		s += n;
		d += n;
  80183c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80183f:	f6 c2 03             	test   $0x3,%dl
  801842:	75 1b                	jne    80185f <memmove+0x3c>
  801844:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80184a:	75 13                	jne    80185f <memmove+0x3c>
  80184c:	f6 c1 03             	test   $0x3,%cl
  80184f:	75 0e                	jne    80185f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801851:	83 ef 04             	sub    $0x4,%edi
  801854:	8d 72 fc             	lea    -0x4(%edx),%esi
  801857:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80185a:	fd                   	std    
  80185b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80185d:	eb 07                	jmp    801866 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80185f:	4f                   	dec    %edi
  801860:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801863:	fd                   	std    
  801864:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801866:	fc                   	cld    
  801867:	eb 20                	jmp    801889 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801869:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80186f:	75 13                	jne    801884 <memmove+0x61>
  801871:	a8 03                	test   $0x3,%al
  801873:	75 0f                	jne    801884 <memmove+0x61>
  801875:	f6 c1 03             	test   $0x3,%cl
  801878:	75 0a                	jne    801884 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80187a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80187d:	89 c7                	mov    %eax,%edi
  80187f:	fc                   	cld    
  801880:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801882:	eb 05                	jmp    801889 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801884:	89 c7                	mov    %eax,%edi
  801886:	fc                   	cld    
  801887:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801889:	5e                   	pop    %esi
  80188a:	5f                   	pop    %edi
  80188b:	c9                   	leave  
  80188c:	c3                   	ret    

0080188d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801890:	ff 75 10             	pushl  0x10(%ebp)
  801893:	ff 75 0c             	pushl  0xc(%ebp)
  801896:	ff 75 08             	pushl  0x8(%ebp)
  801899:	e8 85 ff ff ff       	call   801823 <memmove>
}
  80189e:	c9                   	leave  
  80189f:	c3                   	ret    

008018a0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	57                   	push   %edi
  8018a4:	56                   	push   %esi
  8018a5:	53                   	push   %ebx
  8018a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018a9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018ac:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018af:	85 ff                	test   %edi,%edi
  8018b1:	74 32                	je     8018e5 <memcmp+0x45>
		if (*s1 != *s2)
  8018b3:	8a 03                	mov    (%ebx),%al
  8018b5:	8a 0e                	mov    (%esi),%cl
  8018b7:	38 c8                	cmp    %cl,%al
  8018b9:	74 19                	je     8018d4 <memcmp+0x34>
  8018bb:	eb 0d                	jmp    8018ca <memcmp+0x2a>
  8018bd:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8018c1:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8018c5:	42                   	inc    %edx
  8018c6:	38 c8                	cmp    %cl,%al
  8018c8:	74 10                	je     8018da <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8018ca:	0f b6 c0             	movzbl %al,%eax
  8018cd:	0f b6 c9             	movzbl %cl,%ecx
  8018d0:	29 c8                	sub    %ecx,%eax
  8018d2:	eb 16                	jmp    8018ea <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018d4:	4f                   	dec    %edi
  8018d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018da:	39 fa                	cmp    %edi,%edx
  8018dc:	75 df                	jne    8018bd <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018de:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e3:	eb 05                	jmp    8018ea <memcmp+0x4a>
  8018e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ea:	5b                   	pop    %ebx
  8018eb:	5e                   	pop    %esi
  8018ec:	5f                   	pop    %edi
  8018ed:	c9                   	leave  
  8018ee:	c3                   	ret    

008018ef <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018f5:	89 c2                	mov    %eax,%edx
  8018f7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8018fa:	39 d0                	cmp    %edx,%eax
  8018fc:	73 12                	jae    801910 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018fe:	8a 4d 0c             	mov    0xc(%ebp),%cl
  801901:	38 08                	cmp    %cl,(%eax)
  801903:	75 06                	jne    80190b <memfind+0x1c>
  801905:	eb 09                	jmp    801910 <memfind+0x21>
  801907:	38 08                	cmp    %cl,(%eax)
  801909:	74 05                	je     801910 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80190b:	40                   	inc    %eax
  80190c:	39 c2                	cmp    %eax,%edx
  80190e:	77 f7                	ja     801907 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801910:	c9                   	leave  
  801911:	c3                   	ret    

00801912 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801912:	55                   	push   %ebp
  801913:	89 e5                	mov    %esp,%ebp
  801915:	57                   	push   %edi
  801916:	56                   	push   %esi
  801917:	53                   	push   %ebx
  801918:	8b 55 08             	mov    0x8(%ebp),%edx
  80191b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80191e:	eb 01                	jmp    801921 <strtol+0xf>
		s++;
  801920:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801921:	8a 02                	mov    (%edx),%al
  801923:	3c 20                	cmp    $0x20,%al
  801925:	74 f9                	je     801920 <strtol+0xe>
  801927:	3c 09                	cmp    $0x9,%al
  801929:	74 f5                	je     801920 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80192b:	3c 2b                	cmp    $0x2b,%al
  80192d:	75 08                	jne    801937 <strtol+0x25>
		s++;
  80192f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801930:	bf 00 00 00 00       	mov    $0x0,%edi
  801935:	eb 13                	jmp    80194a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801937:	3c 2d                	cmp    $0x2d,%al
  801939:	75 0a                	jne    801945 <strtol+0x33>
		s++, neg = 1;
  80193b:	8d 52 01             	lea    0x1(%edx),%edx
  80193e:	bf 01 00 00 00       	mov    $0x1,%edi
  801943:	eb 05                	jmp    80194a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801945:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80194a:	85 db                	test   %ebx,%ebx
  80194c:	74 05                	je     801953 <strtol+0x41>
  80194e:	83 fb 10             	cmp    $0x10,%ebx
  801951:	75 28                	jne    80197b <strtol+0x69>
  801953:	8a 02                	mov    (%edx),%al
  801955:	3c 30                	cmp    $0x30,%al
  801957:	75 10                	jne    801969 <strtol+0x57>
  801959:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80195d:	75 0a                	jne    801969 <strtol+0x57>
		s += 2, base = 16;
  80195f:	83 c2 02             	add    $0x2,%edx
  801962:	bb 10 00 00 00       	mov    $0x10,%ebx
  801967:	eb 12                	jmp    80197b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801969:	85 db                	test   %ebx,%ebx
  80196b:	75 0e                	jne    80197b <strtol+0x69>
  80196d:	3c 30                	cmp    $0x30,%al
  80196f:	75 05                	jne    801976 <strtol+0x64>
		s++, base = 8;
  801971:	42                   	inc    %edx
  801972:	b3 08                	mov    $0x8,%bl
  801974:	eb 05                	jmp    80197b <strtol+0x69>
	else if (base == 0)
		base = 10;
  801976:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80197b:	b8 00 00 00 00       	mov    $0x0,%eax
  801980:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801982:	8a 0a                	mov    (%edx),%cl
  801984:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801987:	80 fb 09             	cmp    $0x9,%bl
  80198a:	77 08                	ja     801994 <strtol+0x82>
			dig = *s - '0';
  80198c:	0f be c9             	movsbl %cl,%ecx
  80198f:	83 e9 30             	sub    $0x30,%ecx
  801992:	eb 1e                	jmp    8019b2 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801994:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801997:	80 fb 19             	cmp    $0x19,%bl
  80199a:	77 08                	ja     8019a4 <strtol+0x92>
			dig = *s - 'a' + 10;
  80199c:	0f be c9             	movsbl %cl,%ecx
  80199f:	83 e9 57             	sub    $0x57,%ecx
  8019a2:	eb 0e                	jmp    8019b2 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8019a4:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8019a7:	80 fb 19             	cmp    $0x19,%bl
  8019aa:	77 13                	ja     8019bf <strtol+0xad>
			dig = *s - 'A' + 10;
  8019ac:	0f be c9             	movsbl %cl,%ecx
  8019af:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8019b2:	39 f1                	cmp    %esi,%ecx
  8019b4:	7d 0d                	jge    8019c3 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8019b6:	42                   	inc    %edx
  8019b7:	0f af c6             	imul   %esi,%eax
  8019ba:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8019bd:	eb c3                	jmp    801982 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8019bf:	89 c1                	mov    %eax,%ecx
  8019c1:	eb 02                	jmp    8019c5 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019c3:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8019c5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019c9:	74 05                	je     8019d0 <strtol+0xbe>
		*endptr = (char *) s;
  8019cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019ce:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8019d0:	85 ff                	test   %edi,%edi
  8019d2:	74 04                	je     8019d8 <strtol+0xc6>
  8019d4:	89 c8                	mov    %ecx,%eax
  8019d6:	f7 d8                	neg    %eax
}
  8019d8:	5b                   	pop    %ebx
  8019d9:	5e                   	pop    %esi
  8019da:	5f                   	pop    %edi
  8019db:	c9                   	leave  
  8019dc:	c3                   	ret    
  8019dd:	00 00                	add    %al,(%eax)
	...

008019e0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	56                   	push   %esi
  8019e4:	53                   	push   %ebx
  8019e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8019e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8019ee:	85 c0                	test   %eax,%eax
  8019f0:	74 0e                	je     801a00 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8019f2:	83 ec 0c             	sub    $0xc,%esp
  8019f5:	50                   	push   %eax
  8019f6:	e8 b8 e8 ff ff       	call   8002b3 <sys_ipc_recv>
  8019fb:	83 c4 10             	add    $0x10,%esp
  8019fe:	eb 10                	jmp    801a10 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a00:	83 ec 0c             	sub    $0xc,%esp
  801a03:	68 00 00 c0 ee       	push   $0xeec00000
  801a08:	e8 a6 e8 ff ff       	call   8002b3 <sys_ipc_recv>
  801a0d:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a10:	85 c0                	test   %eax,%eax
  801a12:	75 26                	jne    801a3a <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a14:	85 f6                	test   %esi,%esi
  801a16:	74 0a                	je     801a22 <ipc_recv+0x42>
  801a18:	a1 04 40 80 00       	mov    0x804004,%eax
  801a1d:	8b 40 74             	mov    0x74(%eax),%eax
  801a20:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a22:	85 db                	test   %ebx,%ebx
  801a24:	74 0a                	je     801a30 <ipc_recv+0x50>
  801a26:	a1 04 40 80 00       	mov    0x804004,%eax
  801a2b:	8b 40 78             	mov    0x78(%eax),%eax
  801a2e:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a30:	a1 04 40 80 00       	mov    0x804004,%eax
  801a35:	8b 40 70             	mov    0x70(%eax),%eax
  801a38:	eb 14                	jmp    801a4e <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a3a:	85 f6                	test   %esi,%esi
  801a3c:	74 06                	je     801a44 <ipc_recv+0x64>
  801a3e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a44:	85 db                	test   %ebx,%ebx
  801a46:	74 06                	je     801a4e <ipc_recv+0x6e>
  801a48:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a51:	5b                   	pop    %ebx
  801a52:	5e                   	pop    %esi
  801a53:	c9                   	leave  
  801a54:	c3                   	ret    

00801a55 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	57                   	push   %edi
  801a59:	56                   	push   %esi
  801a5a:	53                   	push   %ebx
  801a5b:	83 ec 0c             	sub    $0xc,%esp
  801a5e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a64:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801a67:	85 db                	test   %ebx,%ebx
  801a69:	75 25                	jne    801a90 <ipc_send+0x3b>
  801a6b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801a70:	eb 1e                	jmp    801a90 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801a72:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a75:	75 07                	jne    801a7e <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801a77:	e8 15 e7 ff ff       	call   800191 <sys_yield>
  801a7c:	eb 12                	jmp    801a90 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801a7e:	50                   	push   %eax
  801a7f:	68 e0 21 80 00       	push   $0x8021e0
  801a84:	6a 43                	push   $0x43
  801a86:	68 f3 21 80 00       	push   $0x8021f3
  801a8b:	e8 44 f5 ff ff       	call   800fd4 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801a90:	56                   	push   %esi
  801a91:	53                   	push   %ebx
  801a92:	57                   	push   %edi
  801a93:	ff 75 08             	pushl  0x8(%ebp)
  801a96:	e8 f3 e7 ff ff       	call   80028e <sys_ipc_try_send>
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	75 d0                	jne    801a72 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801aa2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa5:	5b                   	pop    %ebx
  801aa6:	5e                   	pop    %esi
  801aa7:	5f                   	pop    %edi
  801aa8:	c9                   	leave  
  801aa9:	c3                   	ret    

00801aaa <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aaa:	55                   	push   %ebp
  801aab:	89 e5                	mov    %esp,%ebp
  801aad:	53                   	push   %ebx
  801aae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ab1:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801ab7:	74 22                	je     801adb <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ab9:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801abe:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801ac5:	89 c2                	mov    %eax,%edx
  801ac7:	c1 e2 07             	shl    $0x7,%edx
  801aca:	29 ca                	sub    %ecx,%edx
  801acc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ad2:	8b 52 50             	mov    0x50(%edx),%edx
  801ad5:	39 da                	cmp    %ebx,%edx
  801ad7:	75 1d                	jne    801af6 <ipc_find_env+0x4c>
  801ad9:	eb 05                	jmp    801ae0 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801adb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801ae0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801ae7:	c1 e0 07             	shl    $0x7,%eax
  801aea:	29 d0                	sub    %edx,%eax
  801aec:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801af1:	8b 40 40             	mov    0x40(%eax),%eax
  801af4:	eb 0c                	jmp    801b02 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801af6:	40                   	inc    %eax
  801af7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801afc:	75 c0                	jne    801abe <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801afe:	66 b8 00 00          	mov    $0x0,%ax
}
  801b02:	5b                   	pop    %ebx
  801b03:	c9                   	leave  
  801b04:	c3                   	ret    
  801b05:	00 00                	add    %al,(%eax)
	...

00801b08 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b08:	55                   	push   %ebp
  801b09:	89 e5                	mov    %esp,%ebp
  801b0b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b0e:	89 c2                	mov    %eax,%edx
  801b10:	c1 ea 16             	shr    $0x16,%edx
  801b13:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b1a:	f6 c2 01             	test   $0x1,%dl
  801b1d:	74 1e                	je     801b3d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b1f:	c1 e8 0c             	shr    $0xc,%eax
  801b22:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b29:	a8 01                	test   $0x1,%al
  801b2b:	74 17                	je     801b44 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b2d:	c1 e8 0c             	shr    $0xc,%eax
  801b30:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b37:	ef 
  801b38:	0f b7 c0             	movzwl %ax,%eax
  801b3b:	eb 0c                	jmp    801b49 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b42:	eb 05                	jmp    801b49 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b44:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b49:	c9                   	leave  
  801b4a:	c3                   	ret    
	...

00801b4c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	57                   	push   %edi
  801b50:	56                   	push   %esi
  801b51:	83 ec 10             	sub    $0x10,%esp
  801b54:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b57:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b5a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b5d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b60:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b63:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b66:	85 c0                	test   %eax,%eax
  801b68:	75 2e                	jne    801b98 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b6a:	39 f1                	cmp    %esi,%ecx
  801b6c:	77 5a                	ja     801bc8 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801b6e:	85 c9                	test   %ecx,%ecx
  801b70:	75 0b                	jne    801b7d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801b72:	b8 01 00 00 00       	mov    $0x1,%eax
  801b77:	31 d2                	xor    %edx,%edx
  801b79:	f7 f1                	div    %ecx
  801b7b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801b7d:	31 d2                	xor    %edx,%edx
  801b7f:	89 f0                	mov    %esi,%eax
  801b81:	f7 f1                	div    %ecx
  801b83:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801b85:	89 f8                	mov    %edi,%eax
  801b87:	f7 f1                	div    %ecx
  801b89:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b8b:	89 f8                	mov    %edi,%eax
  801b8d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b8f:	83 c4 10             	add    $0x10,%esp
  801b92:	5e                   	pop    %esi
  801b93:	5f                   	pop    %edi
  801b94:	c9                   	leave  
  801b95:	c3                   	ret    
  801b96:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801b98:	39 f0                	cmp    %esi,%eax
  801b9a:	77 1c                	ja     801bb8 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801b9c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801b9f:	83 f7 1f             	xor    $0x1f,%edi
  801ba2:	75 3c                	jne    801be0 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ba4:	39 f0                	cmp    %esi,%eax
  801ba6:	0f 82 90 00 00 00    	jb     801c3c <__udivdi3+0xf0>
  801bac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801baf:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801bb2:	0f 86 84 00 00 00    	jbe    801c3c <__udivdi3+0xf0>
  801bb8:	31 f6                	xor    %esi,%esi
  801bba:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bbc:	89 f8                	mov    %edi,%eax
  801bbe:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bc0:	83 c4 10             	add    $0x10,%esp
  801bc3:	5e                   	pop    %esi
  801bc4:	5f                   	pop    %edi
  801bc5:	c9                   	leave  
  801bc6:	c3                   	ret    
  801bc7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bc8:	89 f2                	mov    %esi,%edx
  801bca:	89 f8                	mov    %edi,%eax
  801bcc:	f7 f1                	div    %ecx
  801bce:	89 c7                	mov    %eax,%edi
  801bd0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bd2:	89 f8                	mov    %edi,%eax
  801bd4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bd6:	83 c4 10             	add    $0x10,%esp
  801bd9:	5e                   	pop    %esi
  801bda:	5f                   	pop    %edi
  801bdb:	c9                   	leave  
  801bdc:	c3                   	ret    
  801bdd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801be0:	89 f9                	mov    %edi,%ecx
  801be2:	d3 e0                	shl    %cl,%eax
  801be4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801be7:	b8 20 00 00 00       	mov    $0x20,%eax
  801bec:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801bee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bf1:	88 c1                	mov    %al,%cl
  801bf3:	d3 ea                	shr    %cl,%edx
  801bf5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801bf8:	09 ca                	or     %ecx,%edx
  801bfa:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801bfd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c00:	89 f9                	mov    %edi,%ecx
  801c02:	d3 e2                	shl    %cl,%edx
  801c04:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c07:	89 f2                	mov    %esi,%edx
  801c09:	88 c1                	mov    %al,%cl
  801c0b:	d3 ea                	shr    %cl,%edx
  801c0d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c10:	89 f2                	mov    %esi,%edx
  801c12:	89 f9                	mov    %edi,%ecx
  801c14:	d3 e2                	shl    %cl,%edx
  801c16:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c19:	88 c1                	mov    %al,%cl
  801c1b:	d3 ee                	shr    %cl,%esi
  801c1d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c1f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c22:	89 f0                	mov    %esi,%eax
  801c24:	89 ca                	mov    %ecx,%edx
  801c26:	f7 75 ec             	divl   -0x14(%ebp)
  801c29:	89 d1                	mov    %edx,%ecx
  801c2b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c2d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c30:	39 d1                	cmp    %edx,%ecx
  801c32:	72 28                	jb     801c5c <__udivdi3+0x110>
  801c34:	74 1a                	je     801c50 <__udivdi3+0x104>
  801c36:	89 f7                	mov    %esi,%edi
  801c38:	31 f6                	xor    %esi,%esi
  801c3a:	eb 80                	jmp    801bbc <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c3c:	31 f6                	xor    %esi,%esi
  801c3e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c43:	89 f8                	mov    %edi,%eax
  801c45:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c47:	83 c4 10             	add    $0x10,%esp
  801c4a:	5e                   	pop    %esi
  801c4b:	5f                   	pop    %edi
  801c4c:	c9                   	leave  
  801c4d:	c3                   	ret    
  801c4e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c50:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c53:	89 f9                	mov    %edi,%ecx
  801c55:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c57:	39 c2                	cmp    %eax,%edx
  801c59:	73 db                	jae    801c36 <__udivdi3+0xea>
  801c5b:	90                   	nop
		{
		  q0--;
  801c5c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c5f:	31 f6                	xor    %esi,%esi
  801c61:	e9 56 ff ff ff       	jmp    801bbc <__udivdi3+0x70>
	...

00801c68 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	57                   	push   %edi
  801c6c:	56                   	push   %esi
  801c6d:	83 ec 20             	sub    $0x20,%esp
  801c70:	8b 45 08             	mov    0x8(%ebp),%eax
  801c73:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c76:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801c79:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c7c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c7f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801c82:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801c85:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c87:	85 ff                	test   %edi,%edi
  801c89:	75 15                	jne    801ca0 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801c8b:	39 f1                	cmp    %esi,%ecx
  801c8d:	0f 86 99 00 00 00    	jbe    801d2c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c93:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801c95:	89 d0                	mov    %edx,%eax
  801c97:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801c99:	83 c4 20             	add    $0x20,%esp
  801c9c:	5e                   	pop    %esi
  801c9d:	5f                   	pop    %edi
  801c9e:	c9                   	leave  
  801c9f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ca0:	39 f7                	cmp    %esi,%edi
  801ca2:	0f 87 a4 00 00 00    	ja     801d4c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ca8:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801cab:	83 f0 1f             	xor    $0x1f,%eax
  801cae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801cb1:	0f 84 a1 00 00 00    	je     801d58 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801cb7:	89 f8                	mov    %edi,%eax
  801cb9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cbc:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cbe:	bf 20 00 00 00       	mov    $0x20,%edi
  801cc3:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801cc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cc9:	89 f9                	mov    %edi,%ecx
  801ccb:	d3 ea                	shr    %cl,%edx
  801ccd:	09 c2                	or     %eax,%edx
  801ccf:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cd8:	d3 e0                	shl    %cl,%eax
  801cda:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cdd:	89 f2                	mov    %esi,%edx
  801cdf:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801ce1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801ce4:	d3 e0                	shl    %cl,%eax
  801ce6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ce9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cec:	89 f9                	mov    %edi,%ecx
  801cee:	d3 e8                	shr    %cl,%eax
  801cf0:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801cf2:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cf4:	89 f2                	mov    %esi,%edx
  801cf6:	f7 75 f0             	divl   -0x10(%ebp)
  801cf9:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801cfb:	f7 65 f4             	mull   -0xc(%ebp)
  801cfe:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d01:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d03:	39 d6                	cmp    %edx,%esi
  801d05:	72 71                	jb     801d78 <__umoddi3+0x110>
  801d07:	74 7f                	je     801d88 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d0c:	29 c8                	sub    %ecx,%eax
  801d0e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d10:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d13:	d3 e8                	shr    %cl,%eax
  801d15:	89 f2                	mov    %esi,%edx
  801d17:	89 f9                	mov    %edi,%ecx
  801d19:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d1b:	09 d0                	or     %edx,%eax
  801d1d:	89 f2                	mov    %esi,%edx
  801d1f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d22:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d24:	83 c4 20             	add    $0x20,%esp
  801d27:	5e                   	pop    %esi
  801d28:	5f                   	pop    %edi
  801d29:	c9                   	leave  
  801d2a:	c3                   	ret    
  801d2b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d2c:	85 c9                	test   %ecx,%ecx
  801d2e:	75 0b                	jne    801d3b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d30:	b8 01 00 00 00       	mov    $0x1,%eax
  801d35:	31 d2                	xor    %edx,%edx
  801d37:	f7 f1                	div    %ecx
  801d39:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d3b:	89 f0                	mov    %esi,%eax
  801d3d:	31 d2                	xor    %edx,%edx
  801d3f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d44:	f7 f1                	div    %ecx
  801d46:	e9 4a ff ff ff       	jmp    801c95 <__umoddi3+0x2d>
  801d4b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d4c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d4e:	83 c4 20             	add    $0x20,%esp
  801d51:	5e                   	pop    %esi
  801d52:	5f                   	pop    %edi
  801d53:	c9                   	leave  
  801d54:	c3                   	ret    
  801d55:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d58:	39 f7                	cmp    %esi,%edi
  801d5a:	72 05                	jb     801d61 <__umoddi3+0xf9>
  801d5c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d5f:	77 0c                	ja     801d6d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d61:	89 f2                	mov    %esi,%edx
  801d63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d66:	29 c8                	sub    %ecx,%eax
  801d68:	19 fa                	sbb    %edi,%edx
  801d6a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801d6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d70:	83 c4 20             	add    $0x20,%esp
  801d73:	5e                   	pop    %esi
  801d74:	5f                   	pop    %edi
  801d75:	c9                   	leave  
  801d76:	c3                   	ret    
  801d77:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d78:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801d7b:	89 c1                	mov    %eax,%ecx
  801d7d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801d80:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801d83:	eb 84                	jmp    801d09 <__umoddi3+0xa1>
  801d85:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d88:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d8b:	72 eb                	jb     801d78 <__umoddi3+0x110>
  801d8d:	89 f2                	mov    %esi,%edx
  801d8f:	e9 75 ff ff ff       	jmp    801d09 <__umoddi3+0xa1>
