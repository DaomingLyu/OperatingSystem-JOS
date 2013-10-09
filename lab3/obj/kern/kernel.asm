
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 90 7f 1d f0       	mov    $0xf01d7f90,%eax
f010004b:	2d 64 70 1d f0       	sub    $0xf01d7064,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 64 70 1d f0       	push   $0xf01d7064
f0100058:	e8 44 47 00 00       	call   f01047a1 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 a5 04 00 00       	call   f0100507 <cons_init>
//    cprintf("H%x Wo%s\n", 57616, &i);

//    cprintf("x=%d y=%d", 3, 4);
//    cprintf("x=%d y=%d", 3);

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 00 4c 10 f0       	push   $0xf0104c00
f010006f:	e8 85 33 00 00       	call   f01033f9 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 b0 15 00 00       	call   f0101629 <mem_init>

    cprintf("mem_init done! \n");
f0100079:	c7 04 24 1b 4c 10 f0 	movl   $0xf0104c1b,(%esp)
f0100080:	e8 74 33 00 00       	call   f01033f9 <cprintf>
	// Lab 3 user environment initialization functions
	env_init();
f0100085:	e8 5b 2d 00 00       	call   f0102de5 <env_init>
    cprintf("env_init done! \n");
f010008a:	c7 04 24 2c 4c 10 f0 	movl   $0xf0104c2c,(%esp)
f0100091:	e8 63 33 00 00       	call   f01033f9 <cprintf>
	trap_init();
f0100096:	e8 d2 33 00 00       	call   f010346d <trap_init>
    cprintf("trap_init done! \n");
f010009b:	c7 04 24 3d 4c 10 f0 	movl   $0xf0104c3d,(%esp)
f01000a2:	e8 52 33 00 00       	call   f01033f9 <cprintf>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01000a7:	83 c4 0c             	add    $0xc,%esp
f01000aa:	6a 00                	push   $0x0
f01000ac:	68 5f d8 00 00       	push   $0xd85f
f01000b1:	68 76 bc 14 f0       	push   $0xf014bc76
f01000b6:	e8 38 2f 00 00       	call   f0102ff3 <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*
    
	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000bb:	83 c4 04             	add    $0x4,%esp
f01000be:	ff 35 b8 72 1d f0    	pushl  0xf01d72b8
f01000c4:	e8 6d 32 00 00       	call   f0103336 <env_run>

f01000c9 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000c9:	55                   	push   %ebp
f01000ca:	89 e5                	mov    %esp,%ebp
f01000cc:	56                   	push   %esi
f01000cd:	53                   	push   %ebx
f01000ce:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000d1:	83 3d 80 7f 1d f0 00 	cmpl   $0x0,0xf01d7f80
f01000d8:	75 37                	jne    f0100111 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000da:	89 35 80 7f 1d f0    	mov    %esi,0xf01d7f80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000e0:	fa                   	cli    
f01000e1:	fc                   	cld    

	va_start(ap, fmt);
f01000e2:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000e5:	83 ec 04             	sub    $0x4,%esp
f01000e8:	ff 75 0c             	pushl  0xc(%ebp)
f01000eb:	ff 75 08             	pushl  0x8(%ebp)
f01000ee:	68 4f 4c 10 f0       	push   $0xf0104c4f
f01000f3:	e8 01 33 00 00       	call   f01033f9 <cprintf>
	vcprintf(fmt, ap);
f01000f8:	83 c4 08             	add    $0x8,%esp
f01000fb:	53                   	push   %ebx
f01000fc:	56                   	push   %esi
f01000fd:	e8 d1 32 00 00       	call   f01033d3 <vcprintf>
	cprintf("\n");
f0100102:	c7 04 24 2a 4c 10 f0 	movl   $0xf0104c2a,(%esp)
f0100109:	e8 eb 32 00 00       	call   f01033f9 <cprintf>
	va_end(ap);
f010010e:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100111:	83 ec 0c             	sub    $0xc,%esp
f0100114:	6a 00                	push   $0x0
f0100116:	e8 d2 0c 00 00       	call   f0100ded <monitor>
f010011b:	83 c4 10             	add    $0x10,%esp
f010011e:	eb f1                	jmp    f0100111 <_panic+0x48>

f0100120 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100120:	55                   	push   %ebp
f0100121:	89 e5                	mov    %esp,%ebp
f0100123:	53                   	push   %ebx
f0100124:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100127:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010012a:	ff 75 0c             	pushl  0xc(%ebp)
f010012d:	ff 75 08             	pushl  0x8(%ebp)
f0100130:	68 67 4c 10 f0       	push   $0xf0104c67
f0100135:	e8 bf 32 00 00       	call   f01033f9 <cprintf>
	vcprintf(fmt, ap);
f010013a:	83 c4 08             	add    $0x8,%esp
f010013d:	53                   	push   %ebx
f010013e:	ff 75 10             	pushl  0x10(%ebp)
f0100141:	e8 8d 32 00 00       	call   f01033d3 <vcprintf>
	cprintf("\n");
f0100146:	c7 04 24 2a 4c 10 f0 	movl   $0xf0104c2a,(%esp)
f010014d:	e8 a7 32 00 00       	call   f01033f9 <cprintf>
	va_end(ap);
f0100152:	83 c4 10             	add    $0x10,%esp
}
f0100155:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100158:	c9                   	leave  
f0100159:	c3                   	ret    
	...

f010015c <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f010015c:	55                   	push   %ebp
f010015d:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010015f:	ba 84 00 00 00       	mov    $0x84,%edx
f0100164:	ec                   	in     (%dx),%al
f0100165:	ec                   	in     (%dx),%al
f0100166:	ec                   	in     (%dx),%al
f0100167:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f0100168:	c9                   	leave  
f0100169:	c3                   	ret    

f010016a <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010016a:	55                   	push   %ebp
f010016b:	89 e5                	mov    %esp,%ebp
f010016d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100172:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100173:	a8 01                	test   $0x1,%al
f0100175:	74 08                	je     f010017f <serial_proc_data+0x15>
f0100177:	b2 f8                	mov    $0xf8,%dl
f0100179:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010017a:	0f b6 c0             	movzbl %al,%eax
f010017d:	eb 05                	jmp    f0100184 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010017f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100184:	c9                   	leave  
f0100185:	c3                   	ret    

f0100186 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100186:	55                   	push   %ebp
f0100187:	89 e5                	mov    %esp,%ebp
f0100189:	53                   	push   %ebx
f010018a:	83 ec 04             	sub    $0x4,%esp
f010018d:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010018f:	eb 29                	jmp    f01001ba <cons_intr+0x34>
		if (c == 0)
f0100191:	85 c0                	test   %eax,%eax
f0100193:	74 25                	je     f01001ba <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f0100195:	8b 15 a4 72 1d f0    	mov    0xf01d72a4,%edx
f010019b:	88 82 a0 70 1d f0    	mov    %al,-0xfe28f60(%edx)
f01001a1:	8d 42 01             	lea    0x1(%edx),%eax
f01001a4:	a3 a4 72 1d f0       	mov    %eax,0xf01d72a4
		if (cons.wpos == CONSBUFSIZE)
f01001a9:	3d 00 02 00 00       	cmp    $0x200,%eax
f01001ae:	75 0a                	jne    f01001ba <cons_intr+0x34>
			cons.wpos = 0;
f01001b0:	c7 05 a4 72 1d f0 00 	movl   $0x0,0xf01d72a4
f01001b7:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001ba:	ff d3                	call   *%ebx
f01001bc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001bf:	75 d0                	jne    f0100191 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001c1:	83 c4 04             	add    $0x4,%esp
f01001c4:	5b                   	pop    %ebx
f01001c5:	c9                   	leave  
f01001c6:	c3                   	ret    

f01001c7 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01001c7:	55                   	push   %ebp
f01001c8:	89 e5                	mov    %esp,%ebp
f01001ca:	57                   	push   %edi
f01001cb:	56                   	push   %esi
f01001cc:	53                   	push   %ebx
f01001cd:	83 ec 0c             	sub    $0xc,%esp
f01001d0:	89 c6                	mov    %eax,%esi
f01001d2:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001d7:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001d8:	a8 20                	test   $0x20,%al
f01001da:	75 19                	jne    f01001f5 <cons_putc+0x2e>
f01001dc:	bb 00 32 00 00       	mov    $0x3200,%ebx
f01001e1:	bf fd 03 00 00       	mov    $0x3fd,%edi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01001e6:	e8 71 ff ff ff       	call   f010015c <delay>
f01001eb:	89 fa                	mov    %edi,%edx
f01001ed:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001ee:	a8 20                	test   $0x20,%al
f01001f0:	75 03                	jne    f01001f5 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01001f2:	4b                   	dec    %ebx
f01001f3:	75 f1                	jne    f01001e6 <cons_putc+0x1f>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01001f5:	89 f7                	mov    %esi,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001f7:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001fc:	89 f0                	mov    %esi,%eax
f01001fe:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001ff:	b2 79                	mov    $0x79,%dl
f0100201:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100202:	84 c0                	test   %al,%al
f0100204:	78 1d                	js     f0100223 <cons_putc+0x5c>
f0100206:	bb 00 00 00 00       	mov    $0x0,%ebx
		delay();
f010020b:	e8 4c ff ff ff       	call   f010015c <delay>
f0100210:	ba 79 03 00 00       	mov    $0x379,%edx
f0100215:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100216:	84 c0                	test   %al,%al
f0100218:	78 09                	js     f0100223 <cons_putc+0x5c>
f010021a:	43                   	inc    %ebx
f010021b:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100221:	75 e8                	jne    f010020b <cons_putc+0x44>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100223:	ba 78 03 00 00       	mov    $0x378,%edx
f0100228:	89 f8                	mov    %edi,%eax
f010022a:	ee                   	out    %al,(%dx)
f010022b:	b2 7a                	mov    $0x7a,%dl
f010022d:	b0 0d                	mov    $0xd,%al
f010022f:	ee                   	out    %al,(%dx)
f0100230:	b0 08                	mov    $0x8,%al
f0100232:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
    // set user_setcolor
    c |= (user_setcolor << 8);
f0100233:	a1 80 70 1d f0       	mov    0xf01d7080,%eax
f0100238:	c1 e0 08             	shl    $0x8,%eax
f010023b:	09 c6                	or     %eax,%esi

	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010023d:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f0100243:	75 06                	jne    f010024b <cons_putc+0x84>
		c |= 0x0700;
f0100245:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f010024b:	89 f0                	mov    %esi,%eax
f010024d:	25 ff 00 00 00       	and    $0xff,%eax
f0100252:	83 f8 09             	cmp    $0x9,%eax
f0100255:	74 78                	je     f01002cf <cons_putc+0x108>
f0100257:	83 f8 09             	cmp    $0x9,%eax
f010025a:	7f 0b                	jg     f0100267 <cons_putc+0xa0>
f010025c:	83 f8 08             	cmp    $0x8,%eax
f010025f:	0f 85 9e 00 00 00    	jne    f0100303 <cons_putc+0x13c>
f0100265:	eb 10                	jmp    f0100277 <cons_putc+0xb0>
f0100267:	83 f8 0a             	cmp    $0xa,%eax
f010026a:	74 39                	je     f01002a5 <cons_putc+0xde>
f010026c:	83 f8 0d             	cmp    $0xd,%eax
f010026f:	0f 85 8e 00 00 00    	jne    f0100303 <cons_putc+0x13c>
f0100275:	eb 36                	jmp    f01002ad <cons_putc+0xe6>
	case '\b':
		if (crt_pos > 0) {
f0100277:	66 a1 84 70 1d f0    	mov    0xf01d7084,%ax
f010027d:	66 85 c0             	test   %ax,%ax
f0100280:	0f 84 e0 00 00 00    	je     f0100366 <cons_putc+0x19f>
			crt_pos--;
f0100286:	48                   	dec    %eax
f0100287:	66 a3 84 70 1d f0    	mov    %ax,0xf01d7084
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010028d:	0f b7 c0             	movzwl %ax,%eax
f0100290:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f0100296:	83 ce 20             	or     $0x20,%esi
f0100299:	8b 15 88 70 1d f0    	mov    0xf01d7088,%edx
f010029f:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f01002a3:	eb 78                	jmp    f010031d <cons_putc+0x156>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01002a5:	66 83 05 84 70 1d f0 	addw   $0x50,0xf01d7084
f01002ac:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01002ad:	66 8b 0d 84 70 1d f0 	mov    0xf01d7084,%cx
f01002b4:	bb 50 00 00 00       	mov    $0x50,%ebx
f01002b9:	89 c8                	mov    %ecx,%eax
f01002bb:	ba 00 00 00 00       	mov    $0x0,%edx
f01002c0:	66 f7 f3             	div    %bx
f01002c3:	66 29 d1             	sub    %dx,%cx
f01002c6:	66 89 0d 84 70 1d f0 	mov    %cx,0xf01d7084
f01002cd:	eb 4e                	jmp    f010031d <cons_putc+0x156>
		break;
	case '\t':
		cons_putc(' ');
f01002cf:	b8 20 00 00 00       	mov    $0x20,%eax
f01002d4:	e8 ee fe ff ff       	call   f01001c7 <cons_putc>
		cons_putc(' ');
f01002d9:	b8 20 00 00 00       	mov    $0x20,%eax
f01002de:	e8 e4 fe ff ff       	call   f01001c7 <cons_putc>
		cons_putc(' ');
f01002e3:	b8 20 00 00 00       	mov    $0x20,%eax
f01002e8:	e8 da fe ff ff       	call   f01001c7 <cons_putc>
		cons_putc(' ');
f01002ed:	b8 20 00 00 00       	mov    $0x20,%eax
f01002f2:	e8 d0 fe ff ff       	call   f01001c7 <cons_putc>
		cons_putc(' ');
f01002f7:	b8 20 00 00 00       	mov    $0x20,%eax
f01002fc:	e8 c6 fe ff ff       	call   f01001c7 <cons_putc>
f0100301:	eb 1a                	jmp    f010031d <cons_putc+0x156>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100303:	66 a1 84 70 1d f0    	mov    0xf01d7084,%ax
f0100309:	0f b7 c8             	movzwl %ax,%ecx
f010030c:	8b 15 88 70 1d f0    	mov    0xf01d7088,%edx
f0100312:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f0100316:	40                   	inc    %eax
f0100317:	66 a3 84 70 1d f0    	mov    %ax,0xf01d7084
		break;
	}

	// What is the purpose of this?
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
f010031d:	66 81 3d 84 70 1d f0 	cmpw   $0x7cf,0xf01d7084
f0100324:	cf 07 
f0100326:	76 3e                	jbe    f0100366 <cons_putc+0x19f>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100328:	a1 88 70 1d f0       	mov    0xf01d7088,%eax
f010032d:	83 ec 04             	sub    $0x4,%esp
f0100330:	68 00 0f 00 00       	push   $0xf00
f0100335:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010033b:	52                   	push   %edx
f010033c:	50                   	push   %eax
f010033d:	e8 a9 44 00 00       	call   f01047eb <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100342:	8b 15 88 70 1d f0    	mov    0xf01d7088,%edx
f0100348:	83 c4 10             	add    $0x10,%esp
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010034b:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100350:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100356:	40                   	inc    %eax
f0100357:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010035c:	75 f2                	jne    f0100350 <cons_putc+0x189>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010035e:	66 83 2d 84 70 1d f0 	subw   $0x50,0xf01d7084
f0100365:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100366:	8b 0d 8c 70 1d f0    	mov    0xf01d708c,%ecx
f010036c:	b0 0e                	mov    $0xe,%al
f010036e:	89 ca                	mov    %ecx,%edx
f0100370:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100371:	66 8b 35 84 70 1d f0 	mov    0xf01d7084,%si
f0100378:	8d 59 01             	lea    0x1(%ecx),%ebx
f010037b:	89 f0                	mov    %esi,%eax
f010037d:	66 c1 e8 08          	shr    $0x8,%ax
f0100381:	89 da                	mov    %ebx,%edx
f0100383:	ee                   	out    %al,(%dx)
f0100384:	b0 0f                	mov    $0xf,%al
f0100386:	89 ca                	mov    %ecx,%edx
f0100388:	ee                   	out    %al,(%dx)
f0100389:	89 f0                	mov    %esi,%eax
f010038b:	89 da                	mov    %ebx,%edx
f010038d:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010038e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100391:	5b                   	pop    %ebx
f0100392:	5e                   	pop    %esi
f0100393:	5f                   	pop    %edi
f0100394:	c9                   	leave  
f0100395:	c3                   	ret    

f0100396 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100396:	55                   	push   %ebp
f0100397:	89 e5                	mov    %esp,%ebp
f0100399:	53                   	push   %ebx
f010039a:	83 ec 04             	sub    $0x4,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010039d:	ba 64 00 00 00       	mov    $0x64,%edx
f01003a2:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01003a3:	a8 01                	test   $0x1,%al
f01003a5:	0f 84 dc 00 00 00    	je     f0100487 <kbd_proc_data+0xf1>
f01003ab:	b2 60                	mov    $0x60,%dl
f01003ad:	ec                   	in     (%dx),%al
f01003ae:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01003b0:	3c e0                	cmp    $0xe0,%al
f01003b2:	75 11                	jne    f01003c5 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01003b4:	83 0d a8 72 1d f0 40 	orl    $0x40,0xf01d72a8
		return 0;
f01003bb:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003c0:	e9 c7 00 00 00       	jmp    f010048c <kbd_proc_data+0xf6>
	} else if (data & 0x80) {
f01003c5:	84 c0                	test   %al,%al
f01003c7:	79 33                	jns    f01003fc <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003c9:	8b 0d a8 72 1d f0    	mov    0xf01d72a8,%ecx
f01003cf:	f6 c1 40             	test   $0x40,%cl
f01003d2:	75 05                	jne    f01003d9 <kbd_proc_data+0x43>
f01003d4:	88 c2                	mov    %al,%dl
f01003d6:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003d9:	0f b6 d2             	movzbl %dl,%edx
f01003dc:	8a 82 c0 4c 10 f0    	mov    -0xfefb340(%edx),%al
f01003e2:	83 c8 40             	or     $0x40,%eax
f01003e5:	0f b6 c0             	movzbl %al,%eax
f01003e8:	f7 d0                	not    %eax
f01003ea:	21 c1                	and    %eax,%ecx
f01003ec:	89 0d a8 72 1d f0    	mov    %ecx,0xf01d72a8
		return 0;
f01003f2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003f7:	e9 90 00 00 00       	jmp    f010048c <kbd_proc_data+0xf6>
	} else if (shift & E0ESC) {
f01003fc:	8b 0d a8 72 1d f0    	mov    0xf01d72a8,%ecx
f0100402:	f6 c1 40             	test   $0x40,%cl
f0100405:	74 0e                	je     f0100415 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100407:	88 c2                	mov    %al,%dl
f0100409:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010040c:	83 e1 bf             	and    $0xffffffbf,%ecx
f010040f:	89 0d a8 72 1d f0    	mov    %ecx,0xf01d72a8
	}

	shift |= shiftcode[data];
f0100415:	0f b6 d2             	movzbl %dl,%edx
f0100418:	0f b6 82 c0 4c 10 f0 	movzbl -0xfefb340(%edx),%eax
f010041f:	0b 05 a8 72 1d f0    	or     0xf01d72a8,%eax
	shift ^= togglecode[data];
f0100425:	0f b6 8a c0 4d 10 f0 	movzbl -0xfefb240(%edx),%ecx
f010042c:	31 c8                	xor    %ecx,%eax
f010042e:	a3 a8 72 1d f0       	mov    %eax,0xf01d72a8

	c = charcode[shift & (CTL | SHIFT)][data];
f0100433:	89 c1                	mov    %eax,%ecx
f0100435:	83 e1 03             	and    $0x3,%ecx
f0100438:	8b 0c 8d c0 4e 10 f0 	mov    -0xfefb140(,%ecx,4),%ecx
f010043f:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100443:	a8 08                	test   $0x8,%al
f0100445:	74 18                	je     f010045f <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f0100447:	8d 53 9f             	lea    -0x61(%ebx),%edx
f010044a:	83 fa 19             	cmp    $0x19,%edx
f010044d:	77 05                	ja     f0100454 <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f010044f:	83 eb 20             	sub    $0x20,%ebx
f0100452:	eb 0b                	jmp    f010045f <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f0100454:	8d 53 bf             	lea    -0x41(%ebx),%edx
f0100457:	83 fa 19             	cmp    $0x19,%edx
f010045a:	77 03                	ja     f010045f <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f010045c:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010045f:	f7 d0                	not    %eax
f0100461:	a8 06                	test   $0x6,%al
f0100463:	75 27                	jne    f010048c <kbd_proc_data+0xf6>
f0100465:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010046b:	75 1f                	jne    f010048c <kbd_proc_data+0xf6>
		cprintf("Rebooting!\n");
f010046d:	83 ec 0c             	sub    $0xc,%esp
f0100470:	68 81 4c 10 f0       	push   $0xf0104c81
f0100475:	e8 7f 2f 00 00       	call   f01033f9 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010047a:	ba 92 00 00 00       	mov    $0x92,%edx
f010047f:	b0 03                	mov    $0x3,%al
f0100481:	ee                   	out    %al,(%dx)
f0100482:	83 c4 10             	add    $0x10,%esp
f0100485:	eb 05                	jmp    f010048c <kbd_proc_data+0xf6>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100487:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010048c:	89 d8                	mov    %ebx,%eax
f010048e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100491:	c9                   	leave  
f0100492:	c3                   	ret    

f0100493 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100493:	55                   	push   %ebp
f0100494:	89 e5                	mov    %esp,%ebp
f0100496:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100499:	80 3d 90 70 1d f0 00 	cmpb   $0x0,0xf01d7090
f01004a0:	74 0a                	je     f01004ac <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01004a2:	b8 6a 01 10 f0       	mov    $0xf010016a,%eax
f01004a7:	e8 da fc ff ff       	call   f0100186 <cons_intr>
}
f01004ac:	c9                   	leave  
f01004ad:	c3                   	ret    

f01004ae <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004ae:	55                   	push   %ebp
f01004af:	89 e5                	mov    %esp,%ebp
f01004b1:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004b4:	b8 96 03 10 f0       	mov    $0xf0100396,%eax
f01004b9:	e8 c8 fc ff ff       	call   f0100186 <cons_intr>
}
f01004be:	c9                   	leave  
f01004bf:	c3                   	ret    

f01004c0 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004c0:	55                   	push   %ebp
f01004c1:	89 e5                	mov    %esp,%ebp
f01004c3:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004c6:	e8 c8 ff ff ff       	call   f0100493 <serial_intr>
	kbd_intr();
f01004cb:	e8 de ff ff ff       	call   f01004ae <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004d0:	8b 15 a0 72 1d f0    	mov    0xf01d72a0,%edx
f01004d6:	3b 15 a4 72 1d f0    	cmp    0xf01d72a4,%edx
f01004dc:	74 22                	je     f0100500 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f01004de:	0f b6 82 a0 70 1d f0 	movzbl -0xfe28f60(%edx),%eax
f01004e5:	42                   	inc    %edx
f01004e6:	89 15 a0 72 1d f0    	mov    %edx,0xf01d72a0
		if (cons.rpos == CONSBUFSIZE)
f01004ec:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004f2:	75 11                	jne    f0100505 <cons_getc+0x45>
			cons.rpos = 0;
f01004f4:	c7 05 a0 72 1d f0 00 	movl   $0x0,0xf01d72a0
f01004fb:	00 00 00 
f01004fe:	eb 05                	jmp    f0100505 <cons_getc+0x45>
		return c;
	}
	return 0;
f0100500:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100505:	c9                   	leave  
f0100506:	c3                   	ret    

f0100507 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100507:	55                   	push   %ebp
f0100508:	89 e5                	mov    %esp,%ebp
f010050a:	57                   	push   %edi
f010050b:	56                   	push   %esi
f010050c:	53                   	push   %ebx
f010050d:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100510:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100517:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010051e:	5a a5 
	if (*cp != 0xA55A) {
f0100520:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f0100526:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010052a:	74 11                	je     f010053d <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010052c:	c7 05 8c 70 1d f0 b4 	movl   $0x3b4,0xf01d708c
f0100533:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100536:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010053b:	eb 16                	jmp    f0100553 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010053d:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100544:	c7 05 8c 70 1d f0 d4 	movl   $0x3d4,0xf01d708c
f010054b:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010054e:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100553:	8b 0d 8c 70 1d f0    	mov    0xf01d708c,%ecx
f0100559:	b0 0e                	mov    $0xe,%al
f010055b:	89 ca                	mov    %ecx,%edx
f010055d:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010055e:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100561:	89 da                	mov    %ebx,%edx
f0100563:	ec                   	in     (%dx),%al
f0100564:	0f b6 f8             	movzbl %al,%edi
f0100567:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010056a:	b0 0f                	mov    $0xf,%al
f010056c:	89 ca                	mov    %ecx,%edx
f010056e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010056f:	89 da                	mov    %ebx,%edx
f0100571:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100572:	89 35 88 70 1d f0    	mov    %esi,0xf01d7088

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100578:	0f b6 d8             	movzbl %al,%ebx
f010057b:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010057d:	66 89 3d 84 70 1d f0 	mov    %di,0xf01d7084
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100584:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100589:	b0 00                	mov    $0x0,%al
f010058b:	89 da                	mov    %ebx,%edx
f010058d:	ee                   	out    %al,(%dx)
f010058e:	b2 fb                	mov    $0xfb,%dl
f0100590:	b0 80                	mov    $0x80,%al
f0100592:	ee                   	out    %al,(%dx)
f0100593:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100598:	b0 0c                	mov    $0xc,%al
f010059a:	89 ca                	mov    %ecx,%edx
f010059c:	ee                   	out    %al,(%dx)
f010059d:	b2 f9                	mov    $0xf9,%dl
f010059f:	b0 00                	mov    $0x0,%al
f01005a1:	ee                   	out    %al,(%dx)
f01005a2:	b2 fb                	mov    $0xfb,%dl
f01005a4:	b0 03                	mov    $0x3,%al
f01005a6:	ee                   	out    %al,(%dx)
f01005a7:	b2 fc                	mov    $0xfc,%dl
f01005a9:	b0 00                	mov    $0x0,%al
f01005ab:	ee                   	out    %al,(%dx)
f01005ac:	b2 f9                	mov    $0xf9,%dl
f01005ae:	b0 01                	mov    $0x1,%al
f01005b0:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b1:	b2 fd                	mov    $0xfd,%dl
f01005b3:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005b4:	3c ff                	cmp    $0xff,%al
f01005b6:	0f 95 45 e7          	setne  -0x19(%ebp)
f01005ba:	8a 45 e7             	mov    -0x19(%ebp),%al
f01005bd:	a2 90 70 1d f0       	mov    %al,0xf01d7090
f01005c2:	89 da                	mov    %ebx,%edx
f01005c4:	ec                   	in     (%dx),%al
f01005c5:	89 ca                	mov    %ecx,%edx
f01005c7:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005c8:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f01005cc:	75 10                	jne    f01005de <cons_init+0xd7>
		cprintf("Serial port does not exist!\n");
f01005ce:	83 ec 0c             	sub    $0xc,%esp
f01005d1:	68 8d 4c 10 f0       	push   $0xf0104c8d
f01005d6:	e8 1e 2e 00 00       	call   f01033f9 <cprintf>
f01005db:	83 c4 10             	add    $0x10,%esp
}
f01005de:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005e1:	5b                   	pop    %ebx
f01005e2:	5e                   	pop    %esi
f01005e3:	5f                   	pop    %edi
f01005e4:	c9                   	leave  
f01005e5:	c3                   	ret    

f01005e6 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005e6:	55                   	push   %ebp
f01005e7:	89 e5                	mov    %esp,%ebp
f01005e9:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01005ef:	e8 d3 fb ff ff       	call   f01001c7 <cons_putc>
}
f01005f4:	c9                   	leave  
f01005f5:	c3                   	ret    

f01005f6 <getchar>:

int
getchar(void)
{
f01005f6:	55                   	push   %ebp
f01005f7:	89 e5                	mov    %esp,%ebp
f01005f9:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01005fc:	e8 bf fe ff ff       	call   f01004c0 <cons_getc>
f0100601:	85 c0                	test   %eax,%eax
f0100603:	74 f7                	je     f01005fc <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100605:	c9                   	leave  
f0100606:	c3                   	ret    

f0100607 <iscons>:

int
iscons(int fdnum)
{
f0100607:	55                   	push   %ebp
f0100608:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010060a:	b8 01 00 00 00       	mov    $0x1,%eax
f010060f:	c9                   	leave  
f0100610:	c3                   	ret    
f0100611:	00 00                	add    %al,(%eax)
	...

f0100614 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100614:	55                   	push   %ebp
f0100615:	89 e5                	mov    %esp,%ebp
f0100617:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010061a:	68 d0 4e 10 f0       	push   $0xf0104ed0
f010061f:	e8 d5 2d 00 00       	call   f01033f9 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100624:	83 c4 08             	add    $0x8,%esp
f0100627:	68 0c 00 10 00       	push   $0x10000c
f010062c:	68 b4 50 10 f0       	push   $0xf01050b4
f0100631:	e8 c3 2d 00 00       	call   f01033f9 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100636:	83 c4 0c             	add    $0xc,%esp
f0100639:	68 0c 00 10 00       	push   $0x10000c
f010063e:	68 0c 00 10 f0       	push   $0xf010000c
f0100643:	68 dc 50 10 f0       	push   $0xf01050dc
f0100648:	e8 ac 2d 00 00       	call   f01033f9 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010064d:	83 c4 0c             	add    $0xc,%esp
f0100650:	68 f0 4b 10 00       	push   $0x104bf0
f0100655:	68 f0 4b 10 f0       	push   $0xf0104bf0
f010065a:	68 00 51 10 f0       	push   $0xf0105100
f010065f:	e8 95 2d 00 00       	call   f01033f9 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100664:	83 c4 0c             	add    $0xc,%esp
f0100667:	68 64 70 1d 00       	push   $0x1d7064
f010066c:	68 64 70 1d f0       	push   $0xf01d7064
f0100671:	68 24 51 10 f0       	push   $0xf0105124
f0100676:	e8 7e 2d 00 00       	call   f01033f9 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010067b:	83 c4 0c             	add    $0xc,%esp
f010067e:	68 90 7f 1d 00       	push   $0x1d7f90
f0100683:	68 90 7f 1d f0       	push   $0xf01d7f90
f0100688:	68 48 51 10 f0       	push   $0xf0105148
f010068d:	e8 67 2d 00 00       	call   f01033f9 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100692:	b8 8f 83 1d f0       	mov    $0xf01d838f,%eax
f0100697:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010069c:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010069f:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006a4:	89 c2                	mov    %eax,%edx
f01006a6:	85 c0                	test   %eax,%eax
f01006a8:	79 06                	jns    f01006b0 <mon_kerninfo+0x9c>
f01006aa:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006b0:	c1 fa 0a             	sar    $0xa,%edx
f01006b3:	52                   	push   %edx
f01006b4:	68 6c 51 10 f0       	push   $0xf010516c
f01006b9:	e8 3b 2d 00 00       	call   f01033f9 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01006be:	b8 00 00 00 00       	mov    $0x0,%eax
f01006c3:	c9                   	leave  
f01006c4:	c3                   	ret    

f01006c5 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006c5:	55                   	push   %ebp
f01006c6:	89 e5                	mov    %esp,%ebp
f01006c8:	53                   	push   %ebx
f01006c9:	83 ec 04             	sub    $0x4,%esp
f01006cc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006d1:	83 ec 04             	sub    $0x4,%esp
f01006d4:	ff b3 c4 55 10 f0    	pushl  -0xfefaa3c(%ebx)
f01006da:	ff b3 c0 55 10 f0    	pushl  -0xfefaa40(%ebx)
f01006e0:	68 e9 4e 10 f0       	push   $0xf0104ee9
f01006e5:	e8 0f 2d 00 00       	call   f01033f9 <cprintf>
f01006ea:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01006ed:	83 c4 10             	add    $0x10,%esp
f01006f0:	83 fb 54             	cmp    $0x54,%ebx
f01006f3:	75 dc                	jne    f01006d1 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01006f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01006fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01006fd:	c9                   	leave  
f01006fe:	c3                   	ret    

f01006ff <mon_showmappings>:
    return 0;
}

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
f01006ff:	55                   	push   %ebp
f0100700:	89 e5                	mov    %esp,%ebp
f0100702:	57                   	push   %edi
f0100703:	56                   	push   %esi
f0100704:	53                   	push   %ebx
f0100705:	83 ec 0c             	sub    $0xc,%esp
f0100708:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 3) {
f010070b:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f010070f:	74 21                	je     f0100732 <mon_showmappings+0x33>
        cprintf("Command should be: showmappings [addr1] [addr2]\n");
f0100711:	83 ec 0c             	sub    $0xc,%esp
f0100714:	68 98 51 10 f0       	push   $0xf0105198
f0100719:	e8 db 2c 00 00       	call   f01033f9 <cprintf>
        cprintf("Example: showmappings 0x3000 0x5000\n");
f010071e:	c7 04 24 cc 51 10 f0 	movl   $0xf01051cc,(%esp)
f0100725:	e8 cf 2c 00 00       	call   f01033f9 <cprintf>
f010072a:	83 c4 10             	add    $0x10,%esp
f010072d:	e9 1a 01 00 00       	jmp    f010084c <mon_showmappings+0x14d>
    } else {
        uint32_t laddr = strtol(argv[1], NULL, 0);
f0100732:	83 ec 04             	sub    $0x4,%esp
f0100735:	6a 00                	push   $0x0
f0100737:	6a 00                	push   $0x0
f0100739:	ff 76 04             	pushl  0x4(%esi)
f010073c:	e8 99 41 00 00       	call   f01048da <strtol>
f0100741:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[2], NULL, 0);
f0100743:	83 c4 0c             	add    $0xc,%esp
f0100746:	6a 00                	push   $0x0
f0100748:	6a 00                	push   $0x0
f010074a:	ff 76 08             	pushl  0x8(%esi)
f010074d:	e8 88 41 00 00       	call   f01048da <strtol>
        if (laddr > haddr) {
f0100752:	83 c4 10             	add    $0x10,%esp
f0100755:	39 c3                	cmp    %eax,%ebx
f0100757:	76 01                	jbe    f010075a <mon_showmappings+0x5b>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f0100759:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, PGSIZE);
f010075a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        haddr = ROUNDUP(haddr, PGSIZE);
f0100760:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f0100766:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
f010076c:	83 ec 04             	sub    $0x4,%esp
f010076f:	57                   	push   %edi
f0100770:	53                   	push   %ebx
f0100771:	68 f2 4e 10 f0       	push   $0xf0104ef2
f0100776:	e8 7e 2c 00 00       	call   f01033f9 <cprintf>
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f010077b:	83 c4 10             	add    $0x10,%esp
f010077e:	39 fb                	cmp    %edi,%ebx
f0100780:	75 07                	jne    f0100789 <mon_showmappings+0x8a>
f0100782:	e9 c5 00 00 00       	jmp    f010084c <mon_showmappings+0x14d>
f0100787:	89 f3                	mov    %esi,%ebx
            cprintf("[ 0x%08x, 0x%08x ) -> ", now, now + PGSIZE); 
f0100789:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
f010078f:	83 ec 04             	sub    $0x4,%esp
f0100792:	56                   	push   %esi
f0100793:	53                   	push   %ebx
f0100794:	68 03 4f 10 f0       	push   $0xf0104f03
f0100799:	e8 5b 2c 00 00       	call   f01033f9 <cprintf>
            pte = pgdir_walk(kern_pgdir, (void *)now, 0);
f010079e:	83 c4 0c             	add    $0xc,%esp
f01007a1:	6a 00                	push   $0x0
f01007a3:	53                   	push   %ebx
f01007a4:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f01007aa:	e8 6b 0c 00 00       	call   f010141a <pgdir_walk>
f01007af:	89 c3                	mov    %eax,%ebx
            if (pte == 0 || (*pte & PTE_P) == 0) {
f01007b1:	83 c4 10             	add    $0x10,%esp
f01007b4:	85 c0                	test   %eax,%eax
f01007b6:	74 06                	je     f01007be <mon_showmappings+0xbf>
f01007b8:	8b 00                	mov    (%eax),%eax
f01007ba:	a8 01                	test   $0x1,%al
f01007bc:	75 12                	jne    f01007d0 <mon_showmappings+0xd1>
                cprintf(" no mapped \n");
f01007be:	83 ec 0c             	sub    $0xc,%esp
f01007c1:	68 1a 4f 10 f0       	push   $0xf0104f1a
f01007c6:	e8 2e 2c 00 00       	call   f01033f9 <cprintf>
f01007cb:	83 c4 10             	add    $0x10,%esp
f01007ce:	eb 74                	jmp    f0100844 <mon_showmappings+0x145>
            } else {
                cprintf("0x%08x ", PTE_ADDR(*pte));
f01007d0:	83 ec 08             	sub    $0x8,%esp
f01007d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01007d8:	50                   	push   %eax
f01007d9:	68 27 4f 10 f0       	push   $0xf0104f27
f01007de:	e8 16 2c 00 00       	call   f01033f9 <cprintf>
                if (*pte & PTE_U) cprintf(" user       ");
f01007e3:	83 c4 10             	add    $0x10,%esp
f01007e6:	f6 03 04             	testb  $0x4,(%ebx)
f01007e9:	74 12                	je     f01007fd <mon_showmappings+0xfe>
f01007eb:	83 ec 0c             	sub    $0xc,%esp
f01007ee:	68 2f 4f 10 f0       	push   $0xf0104f2f
f01007f3:	e8 01 2c 00 00       	call   f01033f9 <cprintf>
f01007f8:	83 c4 10             	add    $0x10,%esp
f01007fb:	eb 10                	jmp    f010080d <mon_showmappings+0x10e>
                else cprintf(" supervisor ");
f01007fd:	83 ec 0c             	sub    $0xc,%esp
f0100800:	68 3c 4f 10 f0       	push   $0xf0104f3c
f0100805:	e8 ef 2b 00 00       	call   f01033f9 <cprintf>
f010080a:	83 c4 10             	add    $0x10,%esp
                if (*pte & PTE_W) cprintf(" RW ");
f010080d:	f6 03 02             	testb  $0x2,(%ebx)
f0100810:	74 12                	je     f0100824 <mon_showmappings+0x125>
f0100812:	83 ec 0c             	sub    $0xc,%esp
f0100815:	68 49 4f 10 f0       	push   $0xf0104f49
f010081a:	e8 da 2b 00 00       	call   f01033f9 <cprintf>
f010081f:	83 c4 10             	add    $0x10,%esp
f0100822:	eb 10                	jmp    f0100834 <mon_showmappings+0x135>
                else cprintf(" R ");
f0100824:	83 ec 0c             	sub    $0xc,%esp
f0100827:	68 4e 4f 10 f0       	push   $0xf0104f4e
f010082c:	e8 c8 2b 00 00       	call   f01033f9 <cprintf>
f0100831:	83 c4 10             	add    $0x10,%esp
                cprintf("\n");
f0100834:	83 ec 0c             	sub    $0xc,%esp
f0100837:	68 2a 4c 10 f0       	push   $0xf0104c2a
f010083c:	e8 b8 2b 00 00       	call   f01033f9 <cprintf>
f0100841:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDUP(haddr, PGSIZE);
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f0100844:	39 f7                	cmp    %esi,%edi
f0100846:	0f 85 3b ff ff ff    	jne    f0100787 <mon_showmappings+0x88>
                cprintf("\n");
            }
        }
    }
    return 0;
}
f010084c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100851:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100854:	5b                   	pop    %ebx
f0100855:	5e                   	pop    %esi
f0100856:	5f                   	pop    %edi
f0100857:	c9                   	leave  
f0100858:	c3                   	ret    

f0100859 <mon_setpermission>:
    return 0;
}

int
mon_setpermission(int argc, char **argv, struct Trapframe *tf)
{
f0100859:	55                   	push   %ebp
f010085a:	89 e5                	mov    %esp,%ebp
f010085c:	57                   	push   %edi
f010085d:	56                   	push   %esi
f010085e:	53                   	push   %ebx
f010085f:	83 ec 0c             	sub    $0xc,%esp
f0100862:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 5) { 
f0100865:	83 7d 08 05          	cmpl   $0x5,0x8(%ebp)
f0100869:	74 21                	je     f010088c <mon_setpermission+0x33>
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
f010086b:	83 ec 0c             	sub    $0xc,%esp
f010086e:	68 f4 51 10 f0       	push   $0xf01051f4
f0100873:	e8 81 2b 00 00       	call   f01033f9 <cprintf>
        cprintf("Example: setpermissions 0x0 1 0 1\n");
f0100878:	c7 04 24 44 52 10 f0 	movl   $0xf0105244,(%esp)
f010087f:	e8 75 2b 00 00       	call   f01033f9 <cprintf>
f0100884:	83 c4 10             	add    $0x10,%esp
f0100887:	e9 a5 01 00 00       	jmp    f0100a31 <mon_setpermission+0x1d8>
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
f010088c:	83 ec 04             	sub    $0x4,%esp
f010088f:	6a 00                	push   $0x0
f0100891:	6a 00                	push   $0x0
f0100893:	ff 73 04             	pushl  0x4(%ebx)
f0100896:	e8 3f 40 00 00       	call   f01048da <strtol>
        uint32_t perm = 0;
        if (argv[2][0] == '1') perm |= PTE_W;
f010089b:	8b 53 08             	mov    0x8(%ebx),%edx
f010089e:	83 c4 10             	add    $0x10,%esp
    if (argc != 5) { 
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
        cprintf("Example: setpermissions 0x0 1 0 1\n");
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
        uint32_t perm = 0;
f01008a1:	80 3a 31             	cmpb   $0x31,(%edx)
f01008a4:	0f 94 c2             	sete   %dl
f01008a7:	0f b6 d2             	movzbl %dl,%edx
f01008aa:	89 d6                	mov    %edx,%esi
f01008ac:	d1 e6                	shl    %esi
        if (argv[2][0] == '1') perm |= PTE_W;
        if (argv[3][0] == '1') perm |= PTE_U;
f01008ae:	8b 53 0c             	mov    0xc(%ebx),%edx
f01008b1:	80 3a 31             	cmpb   $0x31,(%edx)
f01008b4:	75 03                	jne    f01008b9 <mon_setpermission+0x60>
f01008b6:	83 ce 04             	or     $0x4,%esi
        if (argv[4][0] == '1') perm |= PTE_P;
f01008b9:	8b 53 10             	mov    0x10(%ebx),%edx
f01008bc:	80 3a 31             	cmpb   $0x31,(%edx)
f01008bf:	75 03                	jne    f01008c4 <mon_setpermission+0x6b>
f01008c1:	83 ce 01             	or     $0x1,%esi
        addr = ROUNDUP(addr, PGSIZE);
f01008c4:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f01008ca:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 0);
f01008d0:	83 ec 04             	sub    $0x4,%esp
f01008d3:	6a 00                	push   $0x0
f01008d5:	57                   	push   %edi
f01008d6:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f01008dc:	e8 39 0b 00 00       	call   f010141a <pgdir_walk>
f01008e1:	89 c3                	mov    %eax,%ebx
        if (pte != NULL) {
f01008e3:	83 c4 10             	add    $0x10,%esp
f01008e6:	85 c0                	test   %eax,%eax
f01008e8:	0f 84 33 01 00 00    	je     f0100a21 <mon_setpermission+0x1c8>
            cprintf("0x%08x -> pa: 0x%08x\n old_perm: ", addr, PTE_ADDR(*pte));
f01008ee:	83 ec 04             	sub    $0x4,%esp
f01008f1:	8b 00                	mov    (%eax),%eax
f01008f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01008f8:	50                   	push   %eax
f01008f9:	57                   	push   %edi
f01008fa:	68 68 52 10 f0       	push   $0xf0105268
f01008ff:	e8 f5 2a 00 00       	call   f01033f9 <cprintf>
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100904:	83 c4 10             	add    $0x10,%esp
f0100907:	f6 03 02             	testb  $0x2,(%ebx)
f010090a:	74 12                	je     f010091e <mon_setpermission+0xc5>
f010090c:	83 ec 0c             	sub    $0xc,%esp
f010090f:	68 52 4f 10 f0       	push   $0xf0104f52
f0100914:	e8 e0 2a 00 00       	call   f01033f9 <cprintf>
f0100919:	83 c4 10             	add    $0x10,%esp
f010091c:	eb 10                	jmp    f010092e <mon_setpermission+0xd5>
f010091e:	83 ec 0c             	sub    $0xc,%esp
f0100921:	68 55 4f 10 f0       	push   $0xf0104f55
f0100926:	e8 ce 2a 00 00       	call   f01033f9 <cprintf>
f010092b:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f010092e:	f6 03 04             	testb  $0x4,(%ebx)
f0100931:	74 12                	je     f0100945 <mon_setpermission+0xec>
f0100933:	83 ec 0c             	sub    $0xc,%esp
f0100936:	68 8a 5f 10 f0       	push   $0xf0105f8a
f010093b:	e8 b9 2a 00 00       	call   f01033f9 <cprintf>
f0100940:	83 c4 10             	add    $0x10,%esp
f0100943:	eb 10                	jmp    f0100955 <mon_setpermission+0xfc>
f0100945:	83 ec 0c             	sub    $0xc,%esp
f0100948:	68 c5 63 10 f0       	push   $0xf01063c5
f010094d:	e8 a7 2a 00 00       	call   f01033f9 <cprintf>
f0100952:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100955:	f6 03 01             	testb  $0x1,(%ebx)
f0100958:	74 12                	je     f010096c <mon_setpermission+0x113>
f010095a:	83 ec 0c             	sub    $0xc,%esp
f010095d:	68 fe 5f 10 f0       	push   $0xf0105ffe
f0100962:	e8 92 2a 00 00       	call   f01033f9 <cprintf>
f0100967:	83 c4 10             	add    $0x10,%esp
f010096a:	eb 10                	jmp    f010097c <mon_setpermission+0x123>
f010096c:	83 ec 0c             	sub    $0xc,%esp
f010096f:	68 56 4f 10 f0       	push   $0xf0104f56
f0100974:	e8 80 2a 00 00       	call   f01033f9 <cprintf>
f0100979:	83 c4 10             	add    $0x10,%esp
            cprintf("  --> new_perm: ");
f010097c:	83 ec 0c             	sub    $0xc,%esp
f010097f:	68 58 4f 10 f0       	push   $0xf0104f58
f0100984:	e8 70 2a 00 00       	call   f01033f9 <cprintf>
            *pte = PTE_ADDR(*pte) | perm;     
f0100989:	8b 03                	mov    (%ebx),%eax
f010098b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100990:	09 c6                	or     %eax,%esi
f0100992:	89 33                	mov    %esi,(%ebx)
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100994:	83 c4 10             	add    $0x10,%esp
f0100997:	f7 c6 02 00 00 00    	test   $0x2,%esi
f010099d:	74 12                	je     f01009b1 <mon_setpermission+0x158>
f010099f:	83 ec 0c             	sub    $0xc,%esp
f01009a2:	68 52 4f 10 f0       	push   $0xf0104f52
f01009a7:	e8 4d 2a 00 00       	call   f01033f9 <cprintf>
f01009ac:	83 c4 10             	add    $0x10,%esp
f01009af:	eb 10                	jmp    f01009c1 <mon_setpermission+0x168>
f01009b1:	83 ec 0c             	sub    $0xc,%esp
f01009b4:	68 55 4f 10 f0       	push   $0xf0104f55
f01009b9:	e8 3b 2a 00 00       	call   f01033f9 <cprintf>
f01009be:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f01009c1:	f6 03 04             	testb  $0x4,(%ebx)
f01009c4:	74 12                	je     f01009d8 <mon_setpermission+0x17f>
f01009c6:	83 ec 0c             	sub    $0xc,%esp
f01009c9:	68 8a 5f 10 f0       	push   $0xf0105f8a
f01009ce:	e8 26 2a 00 00       	call   f01033f9 <cprintf>
f01009d3:	83 c4 10             	add    $0x10,%esp
f01009d6:	eb 10                	jmp    f01009e8 <mon_setpermission+0x18f>
f01009d8:	83 ec 0c             	sub    $0xc,%esp
f01009db:	68 c5 63 10 f0       	push   $0xf01063c5
f01009e0:	e8 14 2a 00 00       	call   f01033f9 <cprintf>
f01009e5:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f01009e8:	f6 03 01             	testb  $0x1,(%ebx)
f01009eb:	74 12                	je     f01009ff <mon_setpermission+0x1a6>
f01009ed:	83 ec 0c             	sub    $0xc,%esp
f01009f0:	68 fe 5f 10 f0       	push   $0xf0105ffe
f01009f5:	e8 ff 29 00 00       	call   f01033f9 <cprintf>
f01009fa:	83 c4 10             	add    $0x10,%esp
f01009fd:	eb 10                	jmp    f0100a0f <mon_setpermission+0x1b6>
f01009ff:	83 ec 0c             	sub    $0xc,%esp
f0100a02:	68 56 4f 10 f0       	push   $0xf0104f56
f0100a07:	e8 ed 29 00 00       	call   f01033f9 <cprintf>
f0100a0c:	83 c4 10             	add    $0x10,%esp
            cprintf("\n");
f0100a0f:	83 ec 0c             	sub    $0xc,%esp
f0100a12:	68 2a 4c 10 f0       	push   $0xf0104c2a
f0100a17:	e8 dd 29 00 00       	call   f01033f9 <cprintf>
f0100a1c:	83 c4 10             	add    $0x10,%esp
f0100a1f:	eb 10                	jmp    f0100a31 <mon_setpermission+0x1d8>
        } else {
            cprintf(" no mapped \n");
f0100a21:	83 ec 0c             	sub    $0xc,%esp
f0100a24:	68 1a 4f 10 f0       	push   $0xf0104f1a
f0100a29:	e8 cb 29 00 00       	call   f01033f9 <cprintf>
f0100a2e:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0100a31:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a36:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a39:	5b                   	pop    %ebx
f0100a3a:	5e                   	pop    %esi
f0100a3b:	5f                   	pop    %edi
f0100a3c:	c9                   	leave  
f0100a3d:	c3                   	ret    

f0100a3e <mon_setcolor>:
    return 0;
}

int
mon_setcolor(int argc, char **argv, struct Trapframe *tf)
{
f0100a3e:	55                   	push   %ebp
f0100a3f:	89 e5                	mov    %esp,%ebp
f0100a41:	56                   	push   %esi
f0100a42:	53                   	push   %ebx
f0100a43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 2) {
f0100a46:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100a4a:	74 66                	je     f0100ab2 <mon_setcolor+0x74>
        cprintf("Command should be: setcolor [binary number]\n");
f0100a4c:	83 ec 0c             	sub    $0xc,%esp
f0100a4f:	68 8c 52 10 f0       	push   $0xf010528c
f0100a54:	e8 a0 29 00 00       	call   f01033f9 <cprintf>
        cprintf("num show the color attribute. \n");
f0100a59:	c7 04 24 bc 52 10 f0 	movl   $0xf01052bc,(%esp)
f0100a60:	e8 94 29 00 00       	call   f01033f9 <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f0100a65:	c7 04 24 dc 52 10 f0 	movl   $0xf01052dc,(%esp)
f0100a6c:	e8 88 29 00 00       	call   f01033f9 <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100a71:	c7 04 24 10 53 10 f0 	movl   $0xf0105310,(%esp)
f0100a78:	e8 7c 29 00 00       	call   f01033f9 <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100a7d:	c7 04 24 54 53 10 f0 	movl   $0xf0105354,(%esp)
f0100a84:	e8 70 29 00 00       	call   f01033f9 <cprintf>
        cprintf("Example: setcolor 00001111\n");
f0100a89:	c7 04 24 69 4f 10 f0 	movl   $0xf0104f69,(%esp)
f0100a90:	e8 64 29 00 00       	call   f01033f9 <cprintf>
        cprintf("         set the background color to black\n");
f0100a95:	c7 04 24 98 53 10 f0 	movl   $0xf0105398,(%esp)
f0100a9c:	e8 58 29 00 00       	call   f01033f9 <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100aa1:	c7 04 24 c4 53 10 f0 	movl   $0xf01053c4,(%esp)
f0100aa8:	e8 4c 29 00 00       	call   f01033f9 <cprintf>
f0100aad:	83 c4 10             	add    $0x10,%esp
f0100ab0:	eb 52                	jmp    f0100b04 <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100ab2:	83 ec 0c             	sub    $0xc,%esp
f0100ab5:	ff 73 04             	pushl  0x4(%ebx)
f0100ab8:	e8 1b 3b 00 00       	call   f01045d8 <strlen>
f0100abd:	83 c4 10             	add    $0x10,%esp
f0100ac0:	48                   	dec    %eax
f0100ac1:	78 26                	js     f0100ae9 <mon_setcolor+0xab>
            colnum += (argv[1][i] == '1') << len;
f0100ac3:	8b 73 04             	mov    0x4(%ebx),%esi
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100ac6:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100acb:	b9 00 00 00 00       	mov    $0x0,%ecx
            colnum += (argv[1][i] == '1') << len;
f0100ad0:	80 3c 06 31          	cmpb   $0x31,(%esi,%eax,1)
f0100ad4:	0f 94 c3             	sete   %bl
f0100ad7:	0f b6 db             	movzbl %bl,%ebx
f0100ada:	d3 e3                	shl    %cl,%ebx
f0100adc:	01 da                	add    %ebx,%edx
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100ade:	48                   	dec    %eax
f0100adf:	78 0d                	js     f0100aee <mon_setcolor+0xb0>
f0100ae1:	41                   	inc    %ecx
f0100ae2:	83 f9 08             	cmp    $0x8,%ecx
f0100ae5:	75 e9                	jne    f0100ad0 <mon_setcolor+0x92>
f0100ae7:	eb 05                	jmp    f0100aee <mon_setcolor+0xb0>
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100ae9:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
            colnum += (argv[1][i] == '1') << len;
        user_setcolor = colnum;
f0100aee:	89 15 80 70 1d f0    	mov    %edx,0xf01d7080
        cprintf(" This is color that you want ! \n");
f0100af4:	83 ec 0c             	sub    $0xc,%esp
f0100af7:	68 f8 53 10 f0       	push   $0xf01053f8
f0100afc:	e8 f8 28 00 00       	call   f01033f9 <cprintf>
f0100b01:	83 c4 10             	add    $0x10,%esp
    }
    return 0;
}
f0100b04:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b09:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b0c:	5b                   	pop    %ebx
f0100b0d:	5e                   	pop    %esi
f0100b0e:	c9                   	leave  
f0100b0f:	c3                   	ret    

f0100b10 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{ 
f0100b10:	55                   	push   %ebp
f0100b11:	89 e5                	mov    %esp,%ebp
f0100b13:	57                   	push   %edi
f0100b14:	56                   	push   %esi
f0100b15:	53                   	push   %ebx
f0100b16:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100b19:	89 e8                	mov    %ebp,%eax
	uint32_t* ebp = (uint32_t*)read_ebp();
f0100b1b:	89 c6                	mov    %eax,%esi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100b1d:	85 c0                	test   %eax,%eax
f0100b1f:	74 6d                	je     f0100b8e <mon_backtrace+0x7e>
        eip = *(ebp + 1);
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100b21:	8d 7d d0             	lea    -0x30(%ebp),%edi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
        eip = *(ebp + 1);
f0100b24:	8b 5e 04             	mov    0x4(%esi),%ebx
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
f0100b27:	ff 76 18             	pushl  0x18(%esi)
f0100b2a:	ff 76 14             	pushl  0x14(%esi)
f0100b2d:	ff 76 10             	pushl  0x10(%esi)
f0100b30:	ff 76 0c             	pushl  0xc(%esi)
f0100b33:	ff 76 08             	pushl  0x8(%esi)
f0100b36:	53                   	push   %ebx
f0100b37:	56                   	push   %esi
f0100b38:	68 1c 54 10 f0       	push   $0xf010541c
f0100b3d:	e8 b7 28 00 00       	call   f01033f9 <cprintf>
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100b42:	83 c4 18             	add    $0x18,%esp
f0100b45:	57                   	push   %edi
f0100b46:	ff 76 04             	pushl  0x4(%esi)
f0100b49:	e8 63 32 00 00       	call   f0103db1 <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100b4e:	83 c4 0c             	add    $0xc,%esp
f0100b51:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100b54:	ff 75 d0             	pushl  -0x30(%ebp)
f0100b57:	68 85 4f 10 f0       	push   $0xf0104f85
f0100b5c:	e8 98 28 00 00       	call   f01033f9 <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100b61:	83 c4 0c             	add    $0xc,%esp
f0100b64:	ff 75 d8             	pushl  -0x28(%ebp)
f0100b67:	ff 75 dc             	pushl  -0x24(%ebp)
f0100b6a:	68 95 4f 10 f0       	push   $0xf0104f95
f0100b6f:	e8 85 28 00 00       	call   f01033f9 <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100b74:	83 c4 08             	add    $0x8,%esp
f0100b77:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f0100b7a:	53                   	push   %ebx
f0100b7b:	68 9a 4f 10 f0       	push   $0xf0104f9a
f0100b80:	e8 74 28 00 00       	call   f01033f9 <cprintf>
	uint32_t* ebp = (uint32_t*)read_ebp();
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100b85:	8b 36                	mov    (%esi),%esi
f0100b87:	83 c4 10             	add    $0x10,%esp
f0100b8a:	85 f6                	test   %esi,%esi
f0100b8c:	75 96                	jne    f0100b24 <mon_backtrace+0x14>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
    }
    return 0;
}
f0100b8e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b93:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b96:	5b                   	pop    %ebx
f0100b97:	5e                   	pop    %esi
f0100b98:	5f                   	pop    %edi
f0100b99:	c9                   	leave  
f0100b9a:	c3                   	ret    

f0100b9b <pa_con>:
    return 0;
}

bool
pa_con(uint32_t addr, uint32_t * value)
{
f0100b9b:	55                   	push   %ebp
f0100b9c:	89 e5                	mov    %esp,%ebp
f0100b9e:	53                   	push   %ebx
f0100b9f:	83 ec 04             	sub    $0x4,%esp
f0100ba2:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ba5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    // get value in addr(physical address)
    // if no page mapped in addr, return false;
    if (addr >= PADDR(pages) && addr < PADDR(pages) + PTSIZE) {
f0100ba8:	8b 15 8c 7f 1d f0    	mov    0xf01d7f8c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100bae:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100bb4:	77 15                	ja     f0100bcb <pa_con+0x30>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100bb6:	52                   	push   %edx
f0100bb7:	68 54 54 10 f0       	push   $0xf0105454
f0100bbc:	68 93 00 00 00       	push   $0x93
f0100bc1:	68 9f 4f 10 f0       	push   $0xf0104f9f
f0100bc6:	e8 fe f4 ff ff       	call   f01000c9 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100bcb:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100bd1:	39 d0                	cmp    %edx,%eax
f0100bd3:	72 18                	jb     f0100bed <pa_con+0x52>
f0100bd5:	8d 9a 00 00 40 00    	lea    0x400000(%edx),%ebx
f0100bdb:	39 d8                	cmp    %ebx,%eax
f0100bdd:	73 0e                	jae    f0100bed <pa_con+0x52>
        // PageInfo
        *value = *(uint32_t *)(UPAGES + (addr - PADDR(pages)));
f0100bdf:	29 d0                	sub    %edx,%eax
f0100be1:	8b 80 00 00 00 ef    	mov    -0x11000000(%eax),%eax
f0100be7:	89 01                	mov    %eax,(%ecx)
        return true;
f0100be9:	b0 01                	mov    $0x1,%al
f0100beb:	eb 56                	jmp    f0100c43 <pa_con+0xa8>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100bed:	ba 00 80 11 f0       	mov    $0xf0118000,%edx
f0100bf2:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100bf8:	77 15                	ja     f0100c0f <pa_con+0x74>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100bfa:	52                   	push   %edx
f0100bfb:	68 54 54 10 f0       	push   $0xf0105454
f0100c00:	68 98 00 00 00       	push   $0x98
f0100c05:	68 9f 4f 10 f0       	push   $0xf0104f9f
f0100c0a:	e8 ba f4 ff ff       	call   f01000c9 <_panic>
    }
    if (addr >= PADDR(bootstack) && addr < PADDR(bootstack) + KSTKSIZE) {
f0100c0f:	3d 00 80 11 00       	cmp    $0x118000,%eax
f0100c14:	72 18                	jb     f0100c2e <pa_con+0x93>
f0100c16:	3d 00 00 12 00       	cmp    $0x120000,%eax
f0100c1b:	73 11                	jae    f0100c2e <pa_con+0x93>
        // kernel stack
        *value = *(uint32_t *)(KSTACKTOP - KSTKSIZE + (addr - PADDR(bootstack)));
f0100c1d:	2d 00 80 11 00       	sub    $0x118000,%eax
f0100c22:	8b 80 00 80 ff ef    	mov    -0x10008000(%eax),%eax
f0100c28:	89 01                	mov    %eax,(%ecx)
        return true;
f0100c2a:	b0 01                	mov    $0x1,%al
f0100c2c:	eb 15                	jmp    f0100c43 <pa_con+0xa8>
    }
    if (addr < -KERNBASE) {
f0100c2e:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
f0100c33:	77 0c                	ja     f0100c41 <pa_con+0xa6>
        // Other
        *value = *(uint32_t *)(addr + KERNBASE);
f0100c35:	8b 80 00 00 00 f0    	mov    -0x10000000(%eax),%eax
f0100c3b:	89 01                	mov    %eax,(%ecx)
        return true;
f0100c3d:	b0 01                	mov    $0x1,%al
f0100c3f:	eb 02                	jmp    f0100c43 <pa_con+0xa8>
    }
    // Not in virtual memory mapped.
    return false;
f0100c41:	b0 00                	mov    $0x0,%al
}
f0100c43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100c46:	c9                   	leave  
f0100c47:	c3                   	ret    

f0100c48 <mon_dump>:

int
mon_dump(int argc, char **argv, struct Trapframe *tf)
{
f0100c48:	55                   	push   %ebp
f0100c49:	89 e5                	mov    %esp,%ebp
f0100c4b:	57                   	push   %edi
f0100c4c:	56                   	push   %esi
f0100c4d:	53                   	push   %ebx
f0100c4e:	83 ec 2c             	sub    $0x2c,%esp
f0100c51:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 4) {
f0100c54:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100c58:	74 2d                	je     f0100c87 <mon_dump+0x3f>
        cprintf("Command should be: dump [v/p] [addr1] [addr2]\n");
f0100c5a:	83 ec 0c             	sub    $0xc,%esp
f0100c5d:	68 78 54 10 f0       	push   $0xf0105478
f0100c62:	e8 92 27 00 00       	call   f01033f9 <cprintf>
        cprintf("Example: dump v 0xf0000000 0xf0000010\n");
f0100c67:	c7 04 24 a8 54 10 f0 	movl   $0xf01054a8,(%esp)
f0100c6e:	e8 86 27 00 00       	call   f01033f9 <cprintf>
        cprintf("         dump contents in virtual address [0xf0000000, 0xf0000010)\n");
f0100c73:	c7 04 24 d0 54 10 f0 	movl   $0xf01054d0,(%esp)
f0100c7a:	e8 7a 27 00 00       	call   f01033f9 <cprintf>
f0100c7f:	83 c4 10             	add    $0x10,%esp
f0100c82:	e9 59 01 00 00       	jmp    f0100de0 <mon_dump+0x198>
    } else {
        uint32_t laddr = strtol(argv[2], NULL, 0);
f0100c87:	83 ec 04             	sub    $0x4,%esp
f0100c8a:	6a 00                	push   $0x0
f0100c8c:	6a 00                	push   $0x0
f0100c8e:	ff 76 08             	pushl  0x8(%esi)
f0100c91:	e8 44 3c 00 00       	call   f01048da <strtol>
f0100c96:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[3], NULL, 0);
f0100c98:	83 c4 0c             	add    $0xc,%esp
f0100c9b:	6a 00                	push   $0x0
f0100c9d:	6a 00                	push   $0x0
f0100c9f:	ff 76 0c             	pushl  0xc(%esi)
f0100ca2:	e8 33 3c 00 00       	call   f01048da <strtol>
        if (laddr > haddr) {
f0100ca7:	83 c4 10             	add    $0x10,%esp
f0100caa:	39 c3                	cmp    %eax,%ebx
f0100cac:	76 01                	jbe    f0100caf <mon_dump+0x67>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f0100cae:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, 4);
f0100caf:	89 df                	mov    %ebx,%edi
f0100cb1:	83 e7 fc             	and    $0xfffffffc,%edi
        haddr = ROUNDDOWN(haddr, 4);
f0100cb4:	83 e0 fc             	and    $0xfffffffc,%eax
f0100cb7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        if (argv[1][0] == 'v') {
f0100cba:	8b 46 04             	mov    0x4(%esi),%eax
f0100cbd:	80 38 76             	cmpb   $0x76,(%eax)
f0100cc0:	74 0e                	je     f0100cd0 <mon_dump+0x88>
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100cc2:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100cc5:	0f 85 98 00 00 00    	jne    f0100d63 <mon_dump+0x11b>
f0100ccb:	e9 00 01 00 00       	jmp    f0100dd0 <mon_dump+0x188>
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100cd0:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100cd3:	74 7c                	je     f0100d51 <mon_dump+0x109>
f0100cd5:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
f0100cd7:	39 fb                	cmp    %edi,%ebx
f0100cd9:	74 15                	je     f0100cf0 <mon_dump+0xa8>
f0100cdb:	f6 c3 0f             	test   $0xf,%bl
f0100cde:	75 21                	jne    f0100d01 <mon_dump+0xb9>
                    if (now != laddr) cprintf("\n"); 
f0100ce0:	83 ec 0c             	sub    $0xc,%esp
f0100ce3:	68 2a 4c 10 f0       	push   $0xf0104c2a
f0100ce8:	e8 0c 27 00 00       	call   f01033f9 <cprintf>
f0100ced:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100cf0:	83 ec 08             	sub    $0x8,%esp
f0100cf3:	53                   	push   %ebx
f0100cf4:	68 ae 4f 10 f0       	push   $0xf0104fae
f0100cf9:	e8 fb 26 00 00       	call   f01033f9 <cprintf>
f0100cfe:	83 c4 10             	add    $0x10,%esp
                }
                pte = pgdir_walk(kern_pgdir, (void *)ROUNDDOWN(now, PGSIZE), 0);
f0100d01:	83 ec 04             	sub    $0x4,%esp
f0100d04:	6a 00                	push   $0x0
f0100d06:	89 d8                	mov    %ebx,%eax
f0100d08:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d0d:	50                   	push   %eax
f0100d0e:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0100d14:	e8 01 07 00 00       	call   f010141a <pgdir_walk>
                if (pte && (*pte & PTE_P)) 
f0100d19:	83 c4 10             	add    $0x10,%esp
f0100d1c:	85 c0                	test   %eax,%eax
f0100d1e:	74 19                	je     f0100d39 <mon_dump+0xf1>
f0100d20:	f6 00 01             	testb  $0x1,(%eax)
f0100d23:	74 14                	je     f0100d39 <mon_dump+0xf1>
                    cprintf("0x%08x  ", *((uint32_t *)now));
f0100d25:	83 ec 08             	sub    $0x8,%esp
f0100d28:	ff 33                	pushl  (%ebx)
f0100d2a:	68 b8 4f 10 f0       	push   $0xf0104fb8
f0100d2f:	e8 c5 26 00 00       	call   f01033f9 <cprintf>
f0100d34:	83 c4 10             	add    $0x10,%esp
f0100d37:	eb 10                	jmp    f0100d49 <mon_dump+0x101>
                else
                    cprintf("--------  ");
f0100d39:	83 ec 0c             	sub    $0xc,%esp
f0100d3c:	68 c3 4f 10 f0       	push   $0xf0104fc3
f0100d41:	e8 b3 26 00 00       	call   f01033f9 <cprintf>
f0100d46:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100d49:	83 c3 04             	add    $0x4,%ebx
f0100d4c:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100d4f:	75 86                	jne    f0100cd7 <mon_dump+0x8f>
                if (pte && (*pte & PTE_P)) 
                    cprintf("0x%08x  ", *((uint32_t *)now));
                else
                    cprintf("--------  ");
            }
            cprintf("\n");
f0100d51:	83 ec 0c             	sub    $0xc,%esp
f0100d54:	68 2a 4c 10 f0       	push   $0xf0104c2a
f0100d59:	e8 9b 26 00 00       	call   f01033f9 <cprintf>
f0100d5e:	83 c4 10             	add    $0x10,%esp
f0100d61:	eb 7d                	jmp    f0100de0 <mon_dump+0x198>
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100d63:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
                    if (now != laddr) cprintf("\n");
                    cprintf("0x%08x:  ", now);
                }
                if (pa_con(now, &value)) {
f0100d65:	8d 75 e4             	lea    -0x1c(%ebp),%esi
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
                if (now == laddr || ((now & 0xf) == 0)) {
f0100d68:	39 fb                	cmp    %edi,%ebx
f0100d6a:	74 15                	je     f0100d81 <mon_dump+0x139>
f0100d6c:	f6 c3 0f             	test   $0xf,%bl
f0100d6f:	75 21                	jne    f0100d92 <mon_dump+0x14a>
                    if (now != laddr) cprintf("\n");
f0100d71:	83 ec 0c             	sub    $0xc,%esp
f0100d74:	68 2a 4c 10 f0       	push   $0xf0104c2a
f0100d79:	e8 7b 26 00 00       	call   f01033f9 <cprintf>
f0100d7e:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100d81:	83 ec 08             	sub    $0x8,%esp
f0100d84:	53                   	push   %ebx
f0100d85:	68 ae 4f 10 f0       	push   $0xf0104fae
f0100d8a:	e8 6a 26 00 00       	call   f01033f9 <cprintf>
f0100d8f:	83 c4 10             	add    $0x10,%esp
                }
                if (pa_con(now, &value)) {
f0100d92:	83 ec 08             	sub    $0x8,%esp
f0100d95:	56                   	push   %esi
f0100d96:	53                   	push   %ebx
f0100d97:	e8 ff fd ff ff       	call   f0100b9b <pa_con>
f0100d9c:	83 c4 10             	add    $0x10,%esp
f0100d9f:	84 c0                	test   %al,%al
f0100da1:	74 15                	je     f0100db8 <mon_dump+0x170>
                    cprintf("0x%08x  ", value);
f0100da3:	83 ec 08             	sub    $0x8,%esp
f0100da6:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100da9:	68 b8 4f 10 f0       	push   $0xf0104fb8
f0100dae:	e8 46 26 00 00       	call   f01033f9 <cprintf>
f0100db3:	83 c4 10             	add    $0x10,%esp
f0100db6:	eb 10                	jmp    f0100dc8 <mon_dump+0x180>
                } else
                    cprintf("----------  ");
f0100db8:	83 ec 0c             	sub    $0xc,%esp
f0100dbb:	68 c1 4f 10 f0       	push   $0xf0104fc1
f0100dc0:	e8 34 26 00 00       	call   f01033f9 <cprintf>
f0100dc5:	83 c4 10             	add    $0x10,%esp
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100dc8:	83 c3 04             	add    $0x4,%ebx
f0100dcb:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100dce:	75 98                	jne    f0100d68 <mon_dump+0x120>
                if (pa_con(now, &value)) {
                    cprintf("0x%08x  ", value);
                } else
                    cprintf("----------  ");
            }
            cprintf("\n");
f0100dd0:	83 ec 0c             	sub    $0xc,%esp
f0100dd3:	68 2a 4c 10 f0       	push   $0xf0104c2a
f0100dd8:	e8 1c 26 00 00       	call   f01033f9 <cprintf>
f0100ddd:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0100de0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100de5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100de8:	5b                   	pop    %ebx
f0100de9:	5e                   	pop    %esi
f0100dea:	5f                   	pop    %edi
f0100deb:	c9                   	leave  
f0100dec:	c3                   	ret    

f0100ded <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100ded:	55                   	push   %ebp
f0100dee:	89 e5                	mov    %esp,%ebp
f0100df0:	57                   	push   %edi
f0100df1:	56                   	push   %esi
f0100df2:	53                   	push   %ebx
f0100df3:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100df6:	68 14 55 10 f0       	push   $0xf0105514
f0100dfb:	e8 f9 25 00 00       	call   f01033f9 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100e00:	c7 04 24 38 55 10 f0 	movl   $0xf0105538,(%esp)
f0100e07:	e8 ed 25 00 00       	call   f01033f9 <cprintf>

	if (tf != NULL)
f0100e0c:	83 c4 10             	add    $0x10,%esp
f0100e0f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100e13:	74 0e                	je     f0100e23 <monitor+0x36>
		print_trapframe(tf);
f0100e15:	83 ec 0c             	sub    $0xc,%esp
f0100e18:	ff 75 08             	pushl  0x8(%ebp)
f0100e1b:	e8 eb 29 00 00       	call   f010380b <print_trapframe>
f0100e20:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100e23:	83 ec 0c             	sub    $0xc,%esp
f0100e26:	68 ce 4f 10 f0       	push   $0xf0104fce
f0100e2b:	e8 d8 36 00 00       	call   f0104508 <readline>
f0100e30:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100e32:	83 c4 10             	add    $0x10,%esp
f0100e35:	85 c0                	test   %eax,%eax
f0100e37:	74 ea                	je     f0100e23 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100e39:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100e40:	be 00 00 00 00       	mov    $0x0,%esi
f0100e45:	eb 04                	jmp    f0100e4b <monitor+0x5e>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100e47:	c6 03 00             	movb   $0x0,(%ebx)
f0100e4a:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100e4b:	8a 03                	mov    (%ebx),%al
f0100e4d:	84 c0                	test   %al,%al
f0100e4f:	74 64                	je     f0100eb5 <monitor+0xc8>
f0100e51:	83 ec 08             	sub    $0x8,%esp
f0100e54:	0f be c0             	movsbl %al,%eax
f0100e57:	50                   	push   %eax
f0100e58:	68 d2 4f 10 f0       	push   $0xf0104fd2
f0100e5d:	e8 ef 38 00 00       	call   f0104751 <strchr>
f0100e62:	83 c4 10             	add    $0x10,%esp
f0100e65:	85 c0                	test   %eax,%eax
f0100e67:	75 de                	jne    f0100e47 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100e69:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100e6c:	74 47                	je     f0100eb5 <monitor+0xc8>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100e6e:	83 fe 0f             	cmp    $0xf,%esi
f0100e71:	75 14                	jne    f0100e87 <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100e73:	83 ec 08             	sub    $0x8,%esp
f0100e76:	6a 10                	push   $0x10
f0100e78:	68 d7 4f 10 f0       	push   $0xf0104fd7
f0100e7d:	e8 77 25 00 00       	call   f01033f9 <cprintf>
f0100e82:	83 c4 10             	add    $0x10,%esp
f0100e85:	eb 9c                	jmp    f0100e23 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100e87:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100e8b:	46                   	inc    %esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100e8c:	8a 03                	mov    (%ebx),%al
f0100e8e:	84 c0                	test   %al,%al
f0100e90:	75 09                	jne    f0100e9b <monitor+0xae>
f0100e92:	eb b7                	jmp    f0100e4b <monitor+0x5e>
			buf++;
f0100e94:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100e95:	8a 03                	mov    (%ebx),%al
f0100e97:	84 c0                	test   %al,%al
f0100e99:	74 b0                	je     f0100e4b <monitor+0x5e>
f0100e9b:	83 ec 08             	sub    $0x8,%esp
f0100e9e:	0f be c0             	movsbl %al,%eax
f0100ea1:	50                   	push   %eax
f0100ea2:	68 d2 4f 10 f0       	push   $0xf0104fd2
f0100ea7:	e8 a5 38 00 00       	call   f0104751 <strchr>
f0100eac:	83 c4 10             	add    $0x10,%esp
f0100eaf:	85 c0                	test   %eax,%eax
f0100eb1:	74 e1                	je     f0100e94 <monitor+0xa7>
f0100eb3:	eb 96                	jmp    f0100e4b <monitor+0x5e>
			buf++;
	}
	argv[argc] = 0;
f0100eb5:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100ebc:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100ebd:	85 f6                	test   %esi,%esi
f0100ebf:	0f 84 5e ff ff ff    	je     f0100e23 <monitor+0x36>
f0100ec5:	bb c0 55 10 f0       	mov    $0xf01055c0,%ebx
f0100eca:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100ecf:	83 ec 08             	sub    $0x8,%esp
f0100ed2:	ff 33                	pushl  (%ebx)
f0100ed4:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ed7:	e8 07 38 00 00       	call   f01046e3 <strcmp>
f0100edc:	83 c4 10             	add    $0x10,%esp
f0100edf:	85 c0                	test   %eax,%eax
f0100ee1:	75 20                	jne    f0100f03 <monitor+0x116>
			return commands[i].func(argc, argv, tf);
f0100ee3:	83 ec 04             	sub    $0x4,%esp
f0100ee6:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100ee9:	ff 75 08             	pushl  0x8(%ebp)
f0100eec:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100eef:	50                   	push   %eax
f0100ef0:	56                   	push   %esi
f0100ef1:	ff 97 c8 55 10 f0    	call   *-0xfefaa38(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100ef7:	83 c4 10             	add    $0x10,%esp
f0100efa:	85 c0                	test   %eax,%eax
f0100efc:	78 26                	js     f0100f24 <monitor+0x137>
f0100efe:	e9 20 ff ff ff       	jmp    f0100e23 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100f03:	47                   	inc    %edi
f0100f04:	83 c3 0c             	add    $0xc,%ebx
f0100f07:	83 ff 07             	cmp    $0x7,%edi
f0100f0a:	75 c3                	jne    f0100ecf <monitor+0xe2>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100f0c:	83 ec 08             	sub    $0x8,%esp
f0100f0f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100f12:	68 f4 4f 10 f0       	push   $0xf0104ff4
f0100f17:	e8 dd 24 00 00       	call   f01033f9 <cprintf>
f0100f1c:	83 c4 10             	add    $0x10,%esp
f0100f1f:	e9 ff fe ff ff       	jmp    f0100e23 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100f24:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f27:	5b                   	pop    %ebx
f0100f28:	5e                   	pop    %esi
f0100f29:	5f                   	pop    %edi
f0100f2a:	c9                   	leave  
f0100f2b:	c3                   	ret    

f0100f2c <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100f2c:	55                   	push   %ebp
f0100f2d:	89 e5                	mov    %esp,%ebp
f0100f2f:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100f31:	83 3d b0 72 1d f0 00 	cmpl   $0x0,0xf01d72b0
f0100f38:	75 0f                	jne    f0100f49 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100f3a:	b8 8f 8f 1d f0       	mov    $0xf01d8f8f,%eax
f0100f3f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f44:	a3 b0 72 1d f0       	mov    %eax,0xf01d72b0
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

    result = nextfree;
f0100f49:	a1 b0 72 1d f0       	mov    0xf01d72b0,%eax
    nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100f4e:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100f55:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100f5b:	89 15 b0 72 1d f0    	mov    %edx,0xf01d72b0

	return result;
}
f0100f61:	c9                   	leave  
f0100f62:	c3                   	ret    

f0100f63 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100f63:	55                   	push   %ebp
f0100f64:	89 e5                	mov    %esp,%ebp
f0100f66:	83 ec 08             	sub    $0x8,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100f69:	89 d1                	mov    %edx,%ecx
f0100f6b:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100f6e:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100f71:	a8 01                	test   $0x1,%al
f0100f73:	74 42                	je     f0100fb7 <check_va2pa+0x54>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100f75:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f7a:	89 c1                	mov    %eax,%ecx
f0100f7c:	c1 e9 0c             	shr    $0xc,%ecx
f0100f7f:	3b 0d 84 7f 1d f0    	cmp    0xf01d7f84,%ecx
f0100f85:	72 15                	jb     f0100f9c <check_va2pa+0x39>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f87:	50                   	push   %eax
f0100f88:	68 14 56 10 f0       	push   $0xf0105614
f0100f8d:	68 0a 03 00 00       	push   $0x30a
f0100f92:	68 75 5d 10 f0       	push   $0xf0105d75
f0100f97:	e8 2d f1 ff ff       	call   f01000c9 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100f9c:	c1 ea 0c             	shr    $0xc,%edx
f0100f9f:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100fa5:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100fac:	a8 01                	test   $0x1,%al
f0100fae:	74 0e                	je     f0100fbe <check_va2pa+0x5b>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100fb0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100fb5:	eb 0c                	jmp    f0100fc3 <check_va2pa+0x60>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100fb7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100fbc:	eb 05                	jmp    f0100fc3 <check_va2pa+0x60>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f0100fbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0100fc3:	c9                   	leave  
f0100fc4:	c3                   	ret    

f0100fc5 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100fc5:	55                   	push   %ebp
f0100fc6:	89 e5                	mov    %esp,%ebp
f0100fc8:	56                   	push   %esi
f0100fc9:	53                   	push   %ebx
f0100fca:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100fcc:	83 ec 0c             	sub    $0xc,%esp
f0100fcf:	50                   	push   %eax
f0100fd0:	e8 c3 23 00 00       	call   f0103398 <mc146818_read>
f0100fd5:	89 c6                	mov    %eax,%esi
f0100fd7:	43                   	inc    %ebx
f0100fd8:	89 1c 24             	mov    %ebx,(%esp)
f0100fdb:	e8 b8 23 00 00       	call   f0103398 <mc146818_read>
f0100fe0:	c1 e0 08             	shl    $0x8,%eax
f0100fe3:	09 f0                	or     %esi,%eax
}
f0100fe5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100fe8:	5b                   	pop    %ebx
f0100fe9:	5e                   	pop    %esi
f0100fea:	c9                   	leave  
f0100feb:	c3                   	ret    

f0100fec <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100fec:	55                   	push   %ebp
f0100fed:	89 e5                	mov    %esp,%ebp
f0100fef:	57                   	push   %edi
f0100ff0:	56                   	push   %esi
f0100ff1:	53                   	push   %ebx
f0100ff2:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ff5:	3c 01                	cmp    $0x1,%al
f0100ff7:	19 f6                	sbb    %esi,%esi
f0100ff9:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100fff:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101000:	8b 1d ac 72 1d f0    	mov    0xf01d72ac,%ebx
f0101006:	85 db                	test   %ebx,%ebx
f0101008:	75 17                	jne    f0101021 <check_page_free_list+0x35>
		panic("'page_free_list' is a null pointer!");
f010100a:	83 ec 04             	sub    $0x4,%esp
f010100d:	68 38 56 10 f0       	push   $0xf0105638
f0101012:	68 48 02 00 00       	push   $0x248
f0101017:	68 75 5d 10 f0       	push   $0xf0105d75
f010101c:	e8 a8 f0 ff ff       	call   f01000c9 <_panic>

	if (only_low_memory) {
f0101021:	84 c0                	test   %al,%al
f0101023:	74 50                	je     f0101075 <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101025:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101028:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010102b:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010102e:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101031:	89 d8                	mov    %ebx,%eax
f0101033:	2b 05 8c 7f 1d f0    	sub    0xf01d7f8c,%eax
f0101039:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f010103c:	c1 e8 16             	shr    $0x16,%eax
f010103f:	39 c6                	cmp    %eax,%esi
f0101041:	0f 96 c0             	setbe  %al
f0101044:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0101047:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f010104b:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f010104d:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101051:	8b 1b                	mov    (%ebx),%ebx
f0101053:	85 db                	test   %ebx,%ebx
f0101055:	75 da                	jne    f0101031 <check_page_free_list+0x45>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0101057:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010105a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101060:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101063:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101066:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101068:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010106b:	89 1d ac 72 1d f0    	mov    %ebx,0xf01d72ac
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101071:	85 db                	test   %ebx,%ebx
f0101073:	74 57                	je     f01010cc <check_page_free_list+0xe0>
f0101075:	89 d8                	mov    %ebx,%eax
f0101077:	2b 05 8c 7f 1d f0    	sub    0xf01d7f8c,%eax
f010107d:	c1 f8 03             	sar    $0x3,%eax
f0101080:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0101083:	89 c2                	mov    %eax,%edx
f0101085:	c1 ea 16             	shr    $0x16,%edx
f0101088:	39 d6                	cmp    %edx,%esi
f010108a:	76 3a                	jbe    f01010c6 <check_page_free_list+0xda>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010108c:	89 c2                	mov    %eax,%edx
f010108e:	c1 ea 0c             	shr    $0xc,%edx
f0101091:	3b 15 84 7f 1d f0    	cmp    0xf01d7f84,%edx
f0101097:	72 12                	jb     f01010ab <check_page_free_list+0xbf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101099:	50                   	push   %eax
f010109a:	68 14 56 10 f0       	push   $0xf0105614
f010109f:	6a 56                	push   $0x56
f01010a1:	68 81 5d 10 f0       	push   $0xf0105d81
f01010a6:	e8 1e f0 ff ff       	call   f01000c9 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01010ab:	83 ec 04             	sub    $0x4,%esp
f01010ae:	68 80 00 00 00       	push   $0x80
f01010b3:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f01010b8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010bd:	50                   	push   %eax
f01010be:	e8 de 36 00 00       	call   f01047a1 <memset>
f01010c3:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01010c6:	8b 1b                	mov    (%ebx),%ebx
f01010c8:	85 db                	test   %ebx,%ebx
f01010ca:	75 a9                	jne    f0101075 <check_page_free_list+0x89>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f01010cc:	b8 00 00 00 00       	mov    $0x0,%eax
f01010d1:	e8 56 fe ff ff       	call   f0100f2c <boot_alloc>
f01010d6:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010d9:	8b 15 ac 72 1d f0    	mov    0xf01d72ac,%edx
f01010df:	85 d2                	test   %edx,%edx
f01010e1:	0f 84 80 01 00 00    	je     f0101267 <check_page_free_list+0x27b>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01010e7:	8b 1d 8c 7f 1d f0    	mov    0xf01d7f8c,%ebx
f01010ed:	39 da                	cmp    %ebx,%edx
f01010ef:	72 43                	jb     f0101134 <check_page_free_list+0x148>
		assert(pp < pages + npages);
f01010f1:	a1 84 7f 1d f0       	mov    0xf01d7f84,%eax
f01010f6:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01010f9:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f01010fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01010ff:	39 c2                	cmp    %eax,%edx
f0101101:	73 4f                	jae    f0101152 <check_page_free_list+0x166>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101103:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0101106:	89 d0                	mov    %edx,%eax
f0101108:	29 d8                	sub    %ebx,%eax
f010110a:	a8 07                	test   $0x7,%al
f010110c:	75 66                	jne    f0101174 <check_page_free_list+0x188>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010110e:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101111:	c1 e0 0c             	shl    $0xc,%eax
f0101114:	74 7f                	je     f0101195 <check_page_free_list+0x1a9>
		assert(page2pa(pp) != IOPHYSMEM);
f0101116:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010111b:	0f 84 94 00 00 00    	je     f01011b5 <check_page_free_list+0x1c9>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0101121:	be 00 00 00 00       	mov    $0x0,%esi
f0101126:	bf 00 00 00 00       	mov    $0x0,%edi
f010112b:	e9 9e 00 00 00       	jmp    f01011ce <check_page_free_list+0x1e2>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101130:	39 da                	cmp    %ebx,%edx
f0101132:	73 19                	jae    f010114d <check_page_free_list+0x161>
f0101134:	68 8f 5d 10 f0       	push   $0xf0105d8f
f0101139:	68 9b 5d 10 f0       	push   $0xf0105d9b
f010113e:	68 62 02 00 00       	push   $0x262
f0101143:	68 75 5d 10 f0       	push   $0xf0105d75
f0101148:	e8 7c ef ff ff       	call   f01000c9 <_panic>
		assert(pp < pages + npages);
f010114d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0101150:	72 19                	jb     f010116b <check_page_free_list+0x17f>
f0101152:	68 b0 5d 10 f0       	push   $0xf0105db0
f0101157:	68 9b 5d 10 f0       	push   $0xf0105d9b
f010115c:	68 63 02 00 00       	push   $0x263
f0101161:	68 75 5d 10 f0       	push   $0xf0105d75
f0101166:	e8 5e ef ff ff       	call   f01000c9 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010116b:	89 d0                	mov    %edx,%eax
f010116d:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101170:	a8 07                	test   $0x7,%al
f0101172:	74 19                	je     f010118d <check_page_free_list+0x1a1>
f0101174:	68 5c 56 10 f0       	push   $0xf010565c
f0101179:	68 9b 5d 10 f0       	push   $0xf0105d9b
f010117e:	68 64 02 00 00       	push   $0x264
f0101183:	68 75 5d 10 f0       	push   $0xf0105d75
f0101188:	e8 3c ef ff ff       	call   f01000c9 <_panic>
f010118d:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101190:	c1 e0 0c             	shl    $0xc,%eax
f0101193:	75 19                	jne    f01011ae <check_page_free_list+0x1c2>
f0101195:	68 c4 5d 10 f0       	push   $0xf0105dc4
f010119a:	68 9b 5d 10 f0       	push   $0xf0105d9b
f010119f:	68 67 02 00 00       	push   $0x267
f01011a4:	68 75 5d 10 f0       	push   $0xf0105d75
f01011a9:	e8 1b ef ff ff       	call   f01000c9 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01011ae:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01011b3:	75 19                	jne    f01011ce <check_page_free_list+0x1e2>
f01011b5:	68 d5 5d 10 f0       	push   $0xf0105dd5
f01011ba:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01011bf:	68 68 02 00 00       	push   $0x268
f01011c4:	68 75 5d 10 f0       	push   $0xf0105d75
f01011c9:	e8 fb ee ff ff       	call   f01000c9 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01011ce:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01011d3:	75 19                	jne    f01011ee <check_page_free_list+0x202>
f01011d5:	68 90 56 10 f0       	push   $0xf0105690
f01011da:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01011df:	68 69 02 00 00       	push   $0x269
f01011e4:	68 75 5d 10 f0       	push   $0xf0105d75
f01011e9:	e8 db ee ff ff       	call   f01000c9 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01011ee:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01011f3:	75 19                	jne    f010120e <check_page_free_list+0x222>
f01011f5:	68 ee 5d 10 f0       	push   $0xf0105dee
f01011fa:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01011ff:	68 6a 02 00 00       	push   $0x26a
f0101204:	68 75 5d 10 f0       	push   $0xf0105d75
f0101209:	e8 bb ee ff ff       	call   f01000c9 <_panic>
f010120e:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101210:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101215:	76 3e                	jbe    f0101255 <check_page_free_list+0x269>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101217:	c1 e8 0c             	shr    $0xc,%eax
f010121a:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010121d:	77 12                	ja     f0101231 <check_page_free_list+0x245>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010121f:	51                   	push   %ecx
f0101220:	68 14 56 10 f0       	push   $0xf0105614
f0101225:	6a 56                	push   $0x56
f0101227:	68 81 5d 10 f0       	push   $0xf0105d81
f010122c:	e8 98 ee ff ff       	call   f01000c9 <_panic>
	return (void *)(pa + KERNBASE);
f0101231:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0101237:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f010123a:	76 1c                	jbe    f0101258 <check_page_free_list+0x26c>
f010123c:	68 b4 56 10 f0       	push   $0xf01056b4
f0101241:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101246:	68 6b 02 00 00       	push   $0x26b
f010124b:	68 75 5d 10 f0       	push   $0xf0105d75
f0101250:	e8 74 ee ff ff       	call   f01000c9 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0101255:	47                   	inc    %edi
f0101256:	eb 01                	jmp    f0101259 <check_page_free_list+0x26d>
		else
			++nfree_extmem;
f0101258:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101259:	8b 12                	mov    (%edx),%edx
f010125b:	85 d2                	test   %edx,%edx
f010125d:	0f 85 cd fe ff ff    	jne    f0101130 <check_page_free_list+0x144>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0101263:	85 ff                	test   %edi,%edi
f0101265:	7f 19                	jg     f0101280 <check_page_free_list+0x294>
f0101267:	68 08 5e 10 f0       	push   $0xf0105e08
f010126c:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101271:	68 73 02 00 00       	push   $0x273
f0101276:	68 75 5d 10 f0       	push   $0xf0105d75
f010127b:	e8 49 ee ff ff       	call   f01000c9 <_panic>
	assert(nfree_extmem > 0);
f0101280:	85 f6                	test   %esi,%esi
f0101282:	7f 19                	jg     f010129d <check_page_free_list+0x2b1>
f0101284:	68 1a 5e 10 f0       	push   $0xf0105e1a
f0101289:	68 9b 5d 10 f0       	push   $0xf0105d9b
f010128e:	68 74 02 00 00       	push   $0x274
f0101293:	68 75 5d 10 f0       	push   $0xf0105d75
f0101298:	e8 2c ee ff ff       	call   f01000c9 <_panic>
}
f010129d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012a0:	5b                   	pop    %ebx
f01012a1:	5e                   	pop    %esi
f01012a2:	5f                   	pop    %edi
f01012a3:	c9                   	leave  
f01012a4:	c3                   	ret    

f01012a5 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01012a5:	55                   	push   %ebp
f01012a6:	89 e5                	mov    %esp,%ebp
f01012a8:	56                   	push   %esi
f01012a9:	53                   	push   %ebx
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
    page_free_list = NULL;
f01012aa:	c7 05 ac 72 1d f0 00 	movl   $0x0,0xf01d72ac
f01012b1:	00 00 00 
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
f01012b4:	b8 00 00 00 00       	mov    $0x0,%eax
f01012b9:	e8 6e fc ff ff       	call   f0100f2c <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01012be:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01012c3:	77 15                	ja     f01012da <page_init+0x35>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01012c5:	50                   	push   %eax
f01012c6:	68 54 54 10 f0       	push   $0xf0105454
f01012cb:	68 24 01 00 00       	push   $0x124
f01012d0:	68 75 5d 10 f0       	push   $0xf0105d75
f01012d5:	e8 ef ed ff ff       	call   f01000c9 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01012da:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
f01012e0:	c1 ee 0c             	shr    $0xc,%esi
    for (i = 0; i < npages; i++) {
f01012e3:	83 3d 84 7f 1d f0 00 	cmpl   $0x0,0xf01d7f84
f01012ea:	74 5f                	je     f010134b <page_init+0xa6>
f01012ec:	8b 1d ac 72 1d f0    	mov    0xf01d72ac,%ebx
f01012f2:	ba 00 00 00 00       	mov    $0x0,%edx
f01012f7:	b8 00 00 00 00       	mov    $0x0,%eax
        if (i != 0 && (i < nf_lb || i >= nf_ub)) {
f01012fc:	85 c0                	test   %eax,%eax
f01012fe:	74 25                	je     f0101325 <page_init+0x80>
f0101300:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f0101305:	76 04                	jbe    f010130b <page_init+0x66>
f0101307:	39 c6                	cmp    %eax,%esi
f0101309:	77 1a                	ja     f0101325 <page_init+0x80>
		    pages[i].pp_ref = 0;
f010130b:	89 d1                	mov    %edx,%ecx
f010130d:	03 0d 8c 7f 1d f0    	add    0xf01d7f8c,%ecx
f0101313:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
            pages[i].pp_link = page_free_list;
f0101319:	89 19                	mov    %ebx,(%ecx)
		    page_free_list = &pages[i];
f010131b:	89 d3                	mov    %edx,%ebx
f010131d:	03 1d 8c 7f 1d f0    	add    0xf01d7f8c,%ebx
f0101323:	eb 14                	jmp    f0101339 <page_init+0x94>
        } else {
            pages[i].pp_ref = 1;
f0101325:	89 d1                	mov    %edx,%ecx
f0101327:	03 0d 8c 7f 1d f0    	add    0xf01d7f8c,%ecx
f010132d:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
            pages[i].pp_link = NULL;
f0101333:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	// free pages!
    page_free_list = NULL;
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
    for (i = 0; i < npages; i++) {
f0101339:	40                   	inc    %eax
f010133a:	83 c2 08             	add    $0x8,%edx
f010133d:	39 05 84 7f 1d f0    	cmp    %eax,0xf01d7f84
f0101343:	77 b7                	ja     f01012fc <page_init+0x57>
f0101345:	89 1d ac 72 1d f0    	mov    %ebx,0xf01d72ac
        } else {
            pages[i].pp_ref = 1;
            pages[i].pp_link = NULL;
        }
	}
}
f010134b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010134e:	5b                   	pop    %ebx
f010134f:	5e                   	pop    %esi
f0101350:	c9                   	leave  
f0101351:	c3                   	ret    

f0101352 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101352:	55                   	push   %ebp
f0101353:	89 e5                	mov    %esp,%ebp
f0101355:	53                   	push   %ebx
f0101356:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f0101359:	8b 1d ac 72 1d f0    	mov    0xf01d72ac,%ebx
f010135f:	85 db                	test   %ebx,%ebx
f0101361:	74 63                	je     f01013c6 <page_alloc+0x74>
f0101363:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101368:	74 63                	je     f01013cd <page_alloc+0x7b>
        page_free_list = page_free_list->pp_link;
f010136a:	8b 1b                	mov    (%ebx),%ebx
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f010136c:	85 db                	test   %ebx,%ebx
f010136e:	75 08                	jne    f0101378 <page_alloc+0x26>
f0101370:	89 1d ac 72 1d f0    	mov    %ebx,0xf01d72ac
f0101376:	eb 4e                	jmp    f01013c6 <page_alloc+0x74>
f0101378:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010137d:	75 eb                	jne    f010136a <page_alloc+0x18>
f010137f:	eb 4c                	jmp    f01013cd <page_alloc+0x7b>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101381:	89 d8                	mov    %ebx,%eax
f0101383:	2b 05 8c 7f 1d f0    	sub    0xf01d7f8c,%eax
f0101389:	c1 f8 03             	sar    $0x3,%eax
f010138c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010138f:	89 c2                	mov    %eax,%edx
f0101391:	c1 ea 0c             	shr    $0xc,%edx
f0101394:	3b 15 84 7f 1d f0    	cmp    0xf01d7f84,%edx
f010139a:	72 12                	jb     f01013ae <page_alloc+0x5c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010139c:	50                   	push   %eax
f010139d:	68 14 56 10 f0       	push   $0xf0105614
f01013a2:	6a 56                	push   $0x56
f01013a4:	68 81 5d 10 f0       	push   $0xf0105d81
f01013a9:	e8 1b ed ff ff       	call   f01000c9 <_panic>
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
        if (alloc_flags & ALLOC_ZERO) {
            memset(page2kva(alloc_page), 0, PGSIZE);
f01013ae:	83 ec 04             	sub    $0x4,%esp
f01013b1:	68 00 10 00 00       	push   $0x1000
f01013b6:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01013b8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01013bd:	50                   	push   %eax
f01013be:	e8 de 33 00 00       	call   f01047a1 <memset>
f01013c3:	83 c4 10             	add    $0x10,%esp
        }
        return alloc_page;
    }
}
f01013c6:	89 d8                	mov    %ebx,%eax
f01013c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01013cb:	c9                   	leave  
f01013cc:	c3                   	ret    
        page_free_list = page_free_list->pp_link;
    if (page_free_list == NULL) {
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
f01013cd:	8b 03                	mov    (%ebx),%eax
f01013cf:	a3 ac 72 1d f0       	mov    %eax,0xf01d72ac
        if (alloc_flags & ALLOC_ZERO) {
f01013d4:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01013d8:	74 ec                	je     f01013c6 <page_alloc+0x74>
f01013da:	eb a5                	jmp    f0101381 <page_alloc+0x2f>

f01013dc <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f01013dc:	55                   	push   %ebp
f01013dd:	89 e5                	mov    %esp,%ebp
f01013df:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
    if (pp == NULL || pp->pp_ref != 0) return;
f01013e2:	85 c0                	test   %eax,%eax
f01013e4:	74 14                	je     f01013fa <page_free+0x1e>
f01013e6:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01013eb:	75 0d                	jne    f01013fa <page_free+0x1e>
    pp->pp_link = page_free_list;
f01013ed:	8b 15 ac 72 1d f0    	mov    0xf01d72ac,%edx
f01013f3:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f01013f5:	a3 ac 72 1d f0       	mov    %eax,0xf01d72ac
}
f01013fa:	c9                   	leave  
f01013fb:	c3                   	ret    

f01013fc <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01013fc:	55                   	push   %ebp
f01013fd:	89 e5                	mov    %esp,%ebp
f01013ff:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101402:	8b 50 04             	mov    0x4(%eax),%edx
f0101405:	4a                   	dec    %edx
f0101406:	66 89 50 04          	mov    %dx,0x4(%eax)
f010140a:	66 85 d2             	test   %dx,%dx
f010140d:	75 09                	jne    f0101418 <page_decref+0x1c>
		page_free(pp);
f010140f:	50                   	push   %eax
f0101410:	e8 c7 ff ff ff       	call   f01013dc <page_free>
f0101415:	83 c4 04             	add    $0x4,%esp
}
f0101418:	c9                   	leave  
f0101419:	c3                   	ret    

f010141a <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010141a:	55                   	push   %ebp
f010141b:	89 e5                	mov    %esp,%ebp
f010141d:	56                   	push   %esi
f010141e:	53                   	push   %ebx
f010141f:	8b 75 0c             	mov    0xc(%ebp),%esi
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
f0101422:	89 f3                	mov    %esi,%ebx
f0101424:	c1 eb 16             	shr    $0x16,%ebx
f0101427:	c1 e3 02             	shl    $0x2,%ebx
f010142a:	03 5d 08             	add    0x8(%ebp),%ebx
f010142d:	8b 03                	mov    (%ebx),%eax
f010142f:	85 c0                	test   %eax,%eax
f0101431:	74 04                	je     f0101437 <pgdir_walk+0x1d>
f0101433:	a8 01                	test   $0x1,%al
f0101435:	75 2c                	jne    f0101463 <pgdir_walk+0x49>
        // page table is not exist
        if (create == false) return NULL;
f0101437:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010143b:	74 61                	je     f010149e <pgdir_walk+0x84>
        struct PageInfo * new_page = page_alloc(1);
f010143d:	83 ec 0c             	sub    $0xc,%esp
f0101440:	6a 01                	push   $0x1
f0101442:	e8 0b ff ff ff       	call   f0101352 <page_alloc>
        if (new_page == NULL) return NULL;      // allocation fails
f0101447:	83 c4 10             	add    $0x10,%esp
f010144a:	85 c0                	test   %eax,%eax
f010144c:	74 57                	je     f01014a5 <pgdir_walk+0x8b>
        ++new_page->pp_ref;
f010144e:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101452:	2b 05 8c 7f 1d f0    	sub    0xf01d7f8c,%eax
f0101458:	c1 f8 03             	sar    $0x3,%eax
f010145b:	c1 e0 0c             	shl    $0xc,%eax
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
f010145e:	83 c8 07             	or     $0x7,%eax
f0101461:	89 03                	mov    %eax,(%ebx)
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
f0101463:	8b 03                	mov    (%ebx),%eax
f0101465:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010146a:	89 c2                	mov    %eax,%edx
f010146c:	c1 ea 0c             	shr    $0xc,%edx
f010146f:	3b 15 84 7f 1d f0    	cmp    0xf01d7f84,%edx
f0101475:	72 15                	jb     f010148c <pgdir_walk+0x72>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101477:	50                   	push   %eax
f0101478:	68 14 56 10 f0       	push   $0xf0105614
f010147d:	68 87 01 00 00       	push   $0x187
f0101482:	68 75 5d 10 f0       	push   $0xf0105d75
f0101487:	e8 3d ec ff ff       	call   f01000c9 <_panic>
f010148c:	c1 ee 0a             	shr    $0xa,%esi
f010148f:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101495:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f010149c:	eb 0c                	jmp    f01014aa <pgdir_walk+0x90>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
        // page table is not exist
        if (create == false) return NULL;
f010149e:	b8 00 00 00 00       	mov    $0x0,%eax
f01014a3:	eb 05                	jmp    f01014aa <pgdir_walk+0x90>
        struct PageInfo * new_page = page_alloc(1);
        if (new_page == NULL) return NULL;      // allocation fails
f01014a5:	b8 00 00 00 00       	mov    $0x0,%eax
        ++new_page->pp_ref;
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
}
f01014aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01014ad:	5b                   	pop    %ebx
f01014ae:	5e                   	pop    %esi
f01014af:	c9                   	leave  
f01014b0:	c3                   	ret    

f01014b1 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01014b1:	55                   	push   %ebp
f01014b2:	89 e5                	mov    %esp,%ebp
f01014b4:	57                   	push   %edi
f01014b5:	56                   	push   %esi
f01014b6:	53                   	push   %ebx
f01014b7:	83 ec 1c             	sub    $0x1c,%esp
f01014ba:	89 c7                	mov    %eax,%edi
f01014bc:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f01014bf:	01 d1                	add    %edx,%ecx
f01014c1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01014c4:	39 ca                	cmp    %ecx,%edx
f01014c6:	74 32                	je     f01014fa <boot_map_region+0x49>
f01014c8:	89 d3                	mov    %edx,%ebx
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f01014ca:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014cd:	83 c8 01             	or     $0x1,%eax
f01014d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
        pte = pgdir_walk(pgdir, (void *)va_now, true);
f01014d3:	83 ec 04             	sub    $0x4,%esp
f01014d6:	6a 01                	push   $0x1
f01014d8:	53                   	push   %ebx
f01014d9:	57                   	push   %edi
f01014da:	e8 3b ff ff ff       	call   f010141a <pgdir_walk>
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f01014df:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01014e2:	09 f2                	or     %esi,%edx
f01014e4:	89 10                	mov    %edx,(%eax)
{
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f01014e6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01014ec:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01014f2:	83 c4 10             	add    $0x10,%esp
f01014f5:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01014f8:	75 d9                	jne    f01014d3 <boot_map_region+0x22>
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
    }
}
f01014fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014fd:	5b                   	pop    %ebx
f01014fe:	5e                   	pop    %esi
f01014ff:	5f                   	pop    %edi
f0101500:	c9                   	leave  
f0101501:	c3                   	ret    

f0101502 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101502:	55                   	push   %ebp
f0101503:	89 e5                	mov    %esp,%ebp
f0101505:	53                   	push   %ebx
f0101506:	83 ec 08             	sub    $0x8,%esp
f0101509:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
f010150c:	6a 00                	push   $0x0
f010150e:	ff 75 0c             	pushl  0xc(%ebp)
f0101511:	ff 75 08             	pushl  0x8(%ebp)
f0101514:	e8 01 ff ff ff       	call   f010141a <pgdir_walk>
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f0101519:	83 c4 10             	add    $0x10,%esp
f010151c:	85 c0                	test   %eax,%eax
f010151e:	74 37                	je     f0101557 <page_lookup+0x55>
f0101520:	f6 00 01             	testb  $0x1,(%eax)
f0101523:	74 39                	je     f010155e <page_lookup+0x5c>
    if (pte_store != 0) {
f0101525:	85 db                	test   %ebx,%ebx
f0101527:	74 02                	je     f010152b <page_lookup+0x29>
        *pte_store = pte;
f0101529:	89 03                	mov    %eax,(%ebx)
    }
    return pa2page(PTE_ADDR(*pte));
f010152b:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010152d:	c1 e8 0c             	shr    $0xc,%eax
f0101530:	3b 05 84 7f 1d f0    	cmp    0xf01d7f84,%eax
f0101536:	72 14                	jb     f010154c <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0101538:	83 ec 04             	sub    $0x4,%esp
f010153b:	68 fc 56 10 f0       	push   $0xf01056fc
f0101540:	6a 4f                	push   $0x4f
f0101542:	68 81 5d 10 f0       	push   $0xf0105d81
f0101547:	e8 7d eb ff ff       	call   f01000c9 <_panic>
	return &pages[PGNUM(pa)];
f010154c:	c1 e0 03             	shl    $0x3,%eax
f010154f:	03 05 8c 7f 1d f0    	add    0xf01d7f8c,%eax
f0101555:	eb 0c                	jmp    f0101563 <page_lookup+0x61>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f0101557:	b8 00 00 00 00       	mov    $0x0,%eax
f010155c:	eb 05                	jmp    f0101563 <page_lookup+0x61>
f010155e:	b8 00 00 00 00       	mov    $0x0,%eax
    if (pte_store != 0) {
        *pte_store = pte;
    }
    return pa2page(PTE_ADDR(*pte));
}
f0101563:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101566:	c9                   	leave  
f0101567:	c3                   	ret    

f0101568 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101568:	55                   	push   %ebp
f0101569:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010156b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010156e:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0101571:	c9                   	leave  
f0101572:	c3                   	ret    

f0101573 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101573:	55                   	push   %ebp
f0101574:	89 e5                	mov    %esp,%ebp
f0101576:	56                   	push   %esi
f0101577:	53                   	push   %ebx
f0101578:	83 ec 14             	sub    $0x14,%esp
f010157b:	8b 75 08             	mov    0x8(%ebp),%esi
f010157e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    // cprintf("page_remove\n");
	// Fill this function in
    pte_t * pte;
    struct PageInfo * pg = page_lookup(pgdir, va, &pte);
f0101581:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101584:	50                   	push   %eax
f0101585:	53                   	push   %ebx
f0101586:	56                   	push   %esi
f0101587:	e8 76 ff ff ff       	call   f0101502 <page_lookup>
    if (pg == NULL) return;
f010158c:	83 c4 10             	add    $0x10,%esp
f010158f:	85 c0                	test   %eax,%eax
f0101591:	74 26                	je     f01015b9 <page_remove+0x46>
    page_decref(pg);
f0101593:	83 ec 0c             	sub    $0xc,%esp
f0101596:	50                   	push   %eax
f0101597:	e8 60 fe ff ff       	call   f01013fc <page_decref>
    if (pte != NULL) *pte = 0;
f010159c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010159f:	83 c4 10             	add    $0x10,%esp
f01015a2:	85 c0                	test   %eax,%eax
f01015a4:	74 06                	je     f01015ac <page_remove+0x39>
f01015a6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tlb_invalidate(pgdir, va); 
f01015ac:	83 ec 08             	sub    $0x8,%esp
f01015af:	53                   	push   %ebx
f01015b0:	56                   	push   %esi
f01015b1:	e8 b2 ff ff ff       	call   f0101568 <tlb_invalidate>
f01015b6:	83 c4 10             	add    $0x10,%esp
}
f01015b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01015bc:	5b                   	pop    %ebx
f01015bd:	5e                   	pop    %esi
f01015be:	c9                   	leave  
f01015bf:	c3                   	ret    

f01015c0 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01015c0:	55                   	push   %ebp
f01015c1:	89 e5                	mov    %esp,%ebp
f01015c3:	57                   	push   %edi
f01015c4:	56                   	push   %esi
f01015c5:	53                   	push   %ebx
f01015c6:	83 ec 10             	sub    $0x10,%esp
f01015c9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01015cc:	8b 7d 10             	mov    0x10(%ebp),%edi
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
f01015cf:	6a 01                	push   $0x1
f01015d1:	57                   	push   %edi
f01015d2:	ff 75 08             	pushl  0x8(%ebp)
f01015d5:	e8 40 fe ff ff       	call   f010141a <pgdir_walk>
f01015da:	89 c3                	mov    %eax,%ebx
    if (pte == NULL) return -E_NO_MEM;
f01015dc:	83 c4 10             	add    $0x10,%esp
f01015df:	85 c0                	test   %eax,%eax
f01015e1:	74 39                	je     f010161c <page_insert+0x5c>
    ++pp->pp_ref;
f01015e3:	66 ff 46 04          	incw   0x4(%esi)
    if (*pte & PTE_P) {
f01015e7:	f6 00 01             	testb  $0x1,(%eax)
f01015ea:	74 0f                	je     f01015fb <page_insert+0x3b>
        page_remove(pgdir, va);
f01015ec:	83 ec 08             	sub    $0x8,%esp
f01015ef:	57                   	push   %edi
f01015f0:	ff 75 08             	pushl  0x8(%ebp)
f01015f3:	e8 7b ff ff ff       	call   f0101573 <page_remove>
f01015f8:	83 c4 10             	add    $0x10,%esp
    }
    *pte = page2pa(pp) | perm | PTE_P;        
f01015fb:	8b 55 14             	mov    0x14(%ebp),%edx
f01015fe:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101601:	2b 35 8c 7f 1d f0    	sub    0xf01d7f8c,%esi
f0101607:	c1 fe 03             	sar    $0x3,%esi
f010160a:	89 f0                	mov    %esi,%eax
f010160c:	c1 e0 0c             	shl    $0xc,%eax
f010160f:	89 d6                	mov    %edx,%esi
f0101611:	09 c6                	or     %eax,%esi
f0101613:	89 33                	mov    %esi,(%ebx)
	return 0;
f0101615:	b8 00 00 00 00       	mov    $0x0,%eax
f010161a:	eb 05                	jmp    f0101621 <page_insert+0x61>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
    if (pte == NULL) return -E_NO_MEM;
f010161c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    if (*pte & PTE_P) {
        page_remove(pgdir, va);
    }
    *pte = page2pa(pp) | perm | PTE_P;        
	return 0;
}
f0101621:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101624:	5b                   	pop    %ebx
f0101625:	5e                   	pop    %esi
f0101626:	5f                   	pop    %edi
f0101627:	c9                   	leave  
f0101628:	c3                   	ret    

f0101629 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101629:	55                   	push   %ebp
f010162a:	89 e5                	mov    %esp,%ebp
f010162c:	57                   	push   %edi
f010162d:	56                   	push   %esi
f010162e:	53                   	push   %ebx
f010162f:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101632:	b8 15 00 00 00       	mov    $0x15,%eax
f0101637:	e8 89 f9 ff ff       	call   f0100fc5 <nvram_read>
f010163c:	c1 e0 0a             	shl    $0xa,%eax
f010163f:	89 c2                	mov    %eax,%edx
f0101641:	85 c0                	test   %eax,%eax
f0101643:	79 06                	jns    f010164b <mem_init+0x22>
f0101645:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010164b:	c1 fa 0c             	sar    $0xc,%edx
f010164e:	89 15 b4 72 1d f0    	mov    %edx,0xf01d72b4
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101654:	b8 17 00 00 00       	mov    $0x17,%eax
f0101659:	e8 67 f9 ff ff       	call   f0100fc5 <nvram_read>
f010165e:	89 c2                	mov    %eax,%edx
f0101660:	c1 e2 0a             	shl    $0xa,%edx
f0101663:	89 d0                	mov    %edx,%eax
f0101665:	85 d2                	test   %edx,%edx
f0101667:	79 06                	jns    f010166f <mem_init+0x46>
f0101669:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010166f:	c1 f8 0c             	sar    $0xc,%eax
f0101672:	74 0e                	je     f0101682 <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101674:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010167a:	89 15 84 7f 1d f0    	mov    %edx,0xf01d7f84
f0101680:	eb 0c                	jmp    f010168e <mem_init+0x65>
	else
		npages = npages_basemem;
f0101682:	8b 15 b4 72 1d f0    	mov    0xf01d72b4,%edx
f0101688:	89 15 84 7f 1d f0    	mov    %edx,0xf01d7f84

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010168e:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101691:	c1 e8 0a             	shr    $0xa,%eax
f0101694:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101695:	a1 b4 72 1d f0       	mov    0xf01d72b4,%eax
f010169a:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010169d:	c1 e8 0a             	shr    $0xa,%eax
f01016a0:	50                   	push   %eax
		npages * PGSIZE / 1024,
f01016a1:	a1 84 7f 1d f0       	mov    0xf01d7f84,%eax
f01016a6:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01016a9:	c1 e8 0a             	shr    $0xa,%eax
f01016ac:	50                   	push   %eax
f01016ad:	68 1c 57 10 f0       	push   $0xf010571c
f01016b2:	e8 42 1d 00 00       	call   f01033f9 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01016b7:	b8 00 10 00 00       	mov    $0x1000,%eax
f01016bc:	e8 6b f8 ff ff       	call   f0100f2c <boot_alloc>
f01016c1:	a3 88 7f 1d f0       	mov    %eax,0xf01d7f88
	memset(kern_pgdir, 0, PGSIZE);
f01016c6:	83 c4 0c             	add    $0xc,%esp
f01016c9:	68 00 10 00 00       	push   $0x1000
f01016ce:	6a 00                	push   $0x0
f01016d0:	50                   	push   %eax
f01016d1:	e8 cb 30 00 00       	call   f01047a1 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01016d6:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01016db:	83 c4 10             	add    $0x10,%esp
f01016de:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01016e3:	77 15                	ja     f01016fa <mem_init+0xd1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01016e5:	50                   	push   %eax
f01016e6:	68 54 54 10 f0       	push   $0xf0105454
f01016eb:	68 8e 00 00 00       	push   $0x8e
f01016f0:	68 75 5d 10 f0       	push   $0xf0105d75
f01016f5:	e8 cf e9 ff ff       	call   f01000c9 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01016fa:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101700:	83 ca 05             	or     $0x5,%edx
f0101703:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
    pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101709:	a1 84 7f 1d f0       	mov    0xf01d7f84,%eax
f010170e:	c1 e0 03             	shl    $0x3,%eax
f0101711:	e8 16 f8 ff ff       	call   f0100f2c <boot_alloc>
f0101716:	a3 8c 7f 1d f0       	mov    %eax,0xf01d7f8c
    

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
    envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f010171b:	b8 00 80 01 00       	mov    $0x18000,%eax
f0101720:	e8 07 f8 ff ff       	call   f0100f2c <boot_alloc>
f0101725:	a3 b8 72 1d f0       	mov    %eax,0xf01d72b8
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010172a:	e8 76 fb ff ff       	call   f01012a5 <page_init>

	check_page_free_list(1);
f010172f:	b8 01 00 00 00       	mov    $0x1,%eax
f0101734:	e8 b3 f8 ff ff       	call   f0100fec <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101739:	83 3d 8c 7f 1d f0 00 	cmpl   $0x0,0xf01d7f8c
f0101740:	75 17                	jne    f0101759 <mem_init+0x130>
		panic("'pages' is a null pointer!");
f0101742:	83 ec 04             	sub    $0x4,%esp
f0101745:	68 2b 5e 10 f0       	push   $0xf0105e2b
f010174a:	68 85 02 00 00       	push   $0x285
f010174f:	68 75 5d 10 f0       	push   $0xf0105d75
f0101754:	e8 70 e9 ff ff       	call   f01000c9 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101759:	a1 ac 72 1d f0       	mov    0xf01d72ac,%eax
f010175e:	85 c0                	test   %eax,%eax
f0101760:	74 0e                	je     f0101770 <mem_init+0x147>
f0101762:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f0101767:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101768:	8b 00                	mov    (%eax),%eax
f010176a:	85 c0                	test   %eax,%eax
f010176c:	75 f9                	jne    f0101767 <mem_init+0x13e>
f010176e:	eb 05                	jmp    f0101775 <mem_init+0x14c>
f0101770:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101775:	83 ec 0c             	sub    $0xc,%esp
f0101778:	6a 00                	push   $0x0
f010177a:	e8 d3 fb ff ff       	call   f0101352 <page_alloc>
f010177f:	89 c6                	mov    %eax,%esi
f0101781:	83 c4 10             	add    $0x10,%esp
f0101784:	85 c0                	test   %eax,%eax
f0101786:	75 19                	jne    f01017a1 <mem_init+0x178>
f0101788:	68 46 5e 10 f0       	push   $0xf0105e46
f010178d:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101792:	68 8d 02 00 00       	push   $0x28d
f0101797:	68 75 5d 10 f0       	push   $0xf0105d75
f010179c:	e8 28 e9 ff ff       	call   f01000c9 <_panic>
	assert((pp1 = page_alloc(0)));
f01017a1:	83 ec 0c             	sub    $0xc,%esp
f01017a4:	6a 00                	push   $0x0
f01017a6:	e8 a7 fb ff ff       	call   f0101352 <page_alloc>
f01017ab:	89 c7                	mov    %eax,%edi
f01017ad:	83 c4 10             	add    $0x10,%esp
f01017b0:	85 c0                	test   %eax,%eax
f01017b2:	75 19                	jne    f01017cd <mem_init+0x1a4>
f01017b4:	68 5c 5e 10 f0       	push   $0xf0105e5c
f01017b9:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01017be:	68 8e 02 00 00       	push   $0x28e
f01017c3:	68 75 5d 10 f0       	push   $0xf0105d75
f01017c8:	e8 fc e8 ff ff       	call   f01000c9 <_panic>
	assert((pp2 = page_alloc(0)));
f01017cd:	83 ec 0c             	sub    $0xc,%esp
f01017d0:	6a 00                	push   $0x0
f01017d2:	e8 7b fb ff ff       	call   f0101352 <page_alloc>
f01017d7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017da:	83 c4 10             	add    $0x10,%esp
f01017dd:	85 c0                	test   %eax,%eax
f01017df:	75 19                	jne    f01017fa <mem_init+0x1d1>
f01017e1:	68 72 5e 10 f0       	push   $0xf0105e72
f01017e6:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01017eb:	68 8f 02 00 00       	push   $0x28f
f01017f0:	68 75 5d 10 f0       	push   $0xf0105d75
f01017f5:	e8 cf e8 ff ff       	call   f01000c9 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017fa:	39 fe                	cmp    %edi,%esi
f01017fc:	75 19                	jne    f0101817 <mem_init+0x1ee>
f01017fe:	68 88 5e 10 f0       	push   $0xf0105e88
f0101803:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101808:	68 92 02 00 00       	push   $0x292
f010180d:	68 75 5d 10 f0       	push   $0xf0105d75
f0101812:	e8 b2 e8 ff ff       	call   f01000c9 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101817:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010181a:	74 05                	je     f0101821 <mem_init+0x1f8>
f010181c:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f010181f:	75 19                	jne    f010183a <mem_init+0x211>
f0101821:	68 58 57 10 f0       	push   $0xf0105758
f0101826:	68 9b 5d 10 f0       	push   $0xf0105d9b
f010182b:	68 93 02 00 00       	push   $0x293
f0101830:	68 75 5d 10 f0       	push   $0xf0105d75
f0101835:	e8 8f e8 ff ff       	call   f01000c9 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010183a:	8b 15 8c 7f 1d f0    	mov    0xf01d7f8c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101840:	a1 84 7f 1d f0       	mov    0xf01d7f84,%eax
f0101845:	c1 e0 0c             	shl    $0xc,%eax
f0101848:	89 f1                	mov    %esi,%ecx
f010184a:	29 d1                	sub    %edx,%ecx
f010184c:	c1 f9 03             	sar    $0x3,%ecx
f010184f:	c1 e1 0c             	shl    $0xc,%ecx
f0101852:	39 c1                	cmp    %eax,%ecx
f0101854:	72 19                	jb     f010186f <mem_init+0x246>
f0101856:	68 9a 5e 10 f0       	push   $0xf0105e9a
f010185b:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101860:	68 94 02 00 00       	push   $0x294
f0101865:	68 75 5d 10 f0       	push   $0xf0105d75
f010186a:	e8 5a e8 ff ff       	call   f01000c9 <_panic>
f010186f:	89 f9                	mov    %edi,%ecx
f0101871:	29 d1                	sub    %edx,%ecx
f0101873:	c1 f9 03             	sar    $0x3,%ecx
f0101876:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101879:	39 c8                	cmp    %ecx,%eax
f010187b:	77 19                	ja     f0101896 <mem_init+0x26d>
f010187d:	68 b7 5e 10 f0       	push   $0xf0105eb7
f0101882:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101887:	68 95 02 00 00       	push   $0x295
f010188c:	68 75 5d 10 f0       	push   $0xf0105d75
f0101891:	e8 33 e8 ff ff       	call   f01000c9 <_panic>
f0101896:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101899:	29 d1                	sub    %edx,%ecx
f010189b:	89 ca                	mov    %ecx,%edx
f010189d:	c1 fa 03             	sar    $0x3,%edx
f01018a0:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f01018a3:	39 d0                	cmp    %edx,%eax
f01018a5:	77 19                	ja     f01018c0 <mem_init+0x297>
f01018a7:	68 d4 5e 10 f0       	push   $0xf0105ed4
f01018ac:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01018b1:	68 96 02 00 00       	push   $0x296
f01018b6:	68 75 5d 10 f0       	push   $0xf0105d75
f01018bb:	e8 09 e8 ff ff       	call   f01000c9 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018c0:	a1 ac 72 1d f0       	mov    0xf01d72ac,%eax
f01018c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01018c8:	c7 05 ac 72 1d f0 00 	movl   $0x0,0xf01d72ac
f01018cf:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018d2:	83 ec 0c             	sub    $0xc,%esp
f01018d5:	6a 00                	push   $0x0
f01018d7:	e8 76 fa ff ff       	call   f0101352 <page_alloc>
f01018dc:	83 c4 10             	add    $0x10,%esp
f01018df:	85 c0                	test   %eax,%eax
f01018e1:	74 19                	je     f01018fc <mem_init+0x2d3>
f01018e3:	68 f1 5e 10 f0       	push   $0xf0105ef1
f01018e8:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01018ed:	68 9d 02 00 00       	push   $0x29d
f01018f2:	68 75 5d 10 f0       	push   $0xf0105d75
f01018f7:	e8 cd e7 ff ff       	call   f01000c9 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01018fc:	83 ec 0c             	sub    $0xc,%esp
f01018ff:	56                   	push   %esi
f0101900:	e8 d7 fa ff ff       	call   f01013dc <page_free>
	page_free(pp1);
f0101905:	89 3c 24             	mov    %edi,(%esp)
f0101908:	e8 cf fa ff ff       	call   f01013dc <page_free>
	page_free(pp2);
f010190d:	83 c4 04             	add    $0x4,%esp
f0101910:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101913:	e8 c4 fa ff ff       	call   f01013dc <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101918:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010191f:	e8 2e fa ff ff       	call   f0101352 <page_alloc>
f0101924:	89 c6                	mov    %eax,%esi
f0101926:	83 c4 10             	add    $0x10,%esp
f0101929:	85 c0                	test   %eax,%eax
f010192b:	75 19                	jne    f0101946 <mem_init+0x31d>
f010192d:	68 46 5e 10 f0       	push   $0xf0105e46
f0101932:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101937:	68 a4 02 00 00       	push   $0x2a4
f010193c:	68 75 5d 10 f0       	push   $0xf0105d75
f0101941:	e8 83 e7 ff ff       	call   f01000c9 <_panic>
	assert((pp1 = page_alloc(0)));
f0101946:	83 ec 0c             	sub    $0xc,%esp
f0101949:	6a 00                	push   $0x0
f010194b:	e8 02 fa ff ff       	call   f0101352 <page_alloc>
f0101950:	89 c7                	mov    %eax,%edi
f0101952:	83 c4 10             	add    $0x10,%esp
f0101955:	85 c0                	test   %eax,%eax
f0101957:	75 19                	jne    f0101972 <mem_init+0x349>
f0101959:	68 5c 5e 10 f0       	push   $0xf0105e5c
f010195e:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101963:	68 a5 02 00 00       	push   $0x2a5
f0101968:	68 75 5d 10 f0       	push   $0xf0105d75
f010196d:	e8 57 e7 ff ff       	call   f01000c9 <_panic>
	assert((pp2 = page_alloc(0)));
f0101972:	83 ec 0c             	sub    $0xc,%esp
f0101975:	6a 00                	push   $0x0
f0101977:	e8 d6 f9 ff ff       	call   f0101352 <page_alloc>
f010197c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010197f:	83 c4 10             	add    $0x10,%esp
f0101982:	85 c0                	test   %eax,%eax
f0101984:	75 19                	jne    f010199f <mem_init+0x376>
f0101986:	68 72 5e 10 f0       	push   $0xf0105e72
f010198b:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101990:	68 a6 02 00 00       	push   $0x2a6
f0101995:	68 75 5d 10 f0       	push   $0xf0105d75
f010199a:	e8 2a e7 ff ff       	call   f01000c9 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010199f:	39 fe                	cmp    %edi,%esi
f01019a1:	75 19                	jne    f01019bc <mem_init+0x393>
f01019a3:	68 88 5e 10 f0       	push   $0xf0105e88
f01019a8:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01019ad:	68 a8 02 00 00       	push   $0x2a8
f01019b2:	68 75 5d 10 f0       	push   $0xf0105d75
f01019b7:	e8 0d e7 ff ff       	call   f01000c9 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019bc:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01019bf:	74 05                	je     f01019c6 <mem_init+0x39d>
f01019c1:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01019c4:	75 19                	jne    f01019df <mem_init+0x3b6>
f01019c6:	68 58 57 10 f0       	push   $0xf0105758
f01019cb:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01019d0:	68 a9 02 00 00       	push   $0x2a9
f01019d5:	68 75 5d 10 f0       	push   $0xf0105d75
f01019da:	e8 ea e6 ff ff       	call   f01000c9 <_panic>
	assert(!page_alloc(0));
f01019df:	83 ec 0c             	sub    $0xc,%esp
f01019e2:	6a 00                	push   $0x0
f01019e4:	e8 69 f9 ff ff       	call   f0101352 <page_alloc>
f01019e9:	83 c4 10             	add    $0x10,%esp
f01019ec:	85 c0                	test   %eax,%eax
f01019ee:	74 19                	je     f0101a09 <mem_init+0x3e0>
f01019f0:	68 f1 5e 10 f0       	push   $0xf0105ef1
f01019f5:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01019fa:	68 aa 02 00 00       	push   $0x2aa
f01019ff:	68 75 5d 10 f0       	push   $0xf0105d75
f0101a04:	e8 c0 e6 ff ff       	call   f01000c9 <_panic>
f0101a09:	89 f0                	mov    %esi,%eax
f0101a0b:	2b 05 8c 7f 1d f0    	sub    0xf01d7f8c,%eax
f0101a11:	c1 f8 03             	sar    $0x3,%eax
f0101a14:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a17:	89 c2                	mov    %eax,%edx
f0101a19:	c1 ea 0c             	shr    $0xc,%edx
f0101a1c:	3b 15 84 7f 1d f0    	cmp    0xf01d7f84,%edx
f0101a22:	72 12                	jb     f0101a36 <mem_init+0x40d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a24:	50                   	push   %eax
f0101a25:	68 14 56 10 f0       	push   $0xf0105614
f0101a2a:	6a 56                	push   $0x56
f0101a2c:	68 81 5d 10 f0       	push   $0xf0105d81
f0101a31:	e8 93 e6 ff ff       	call   f01000c9 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101a36:	83 ec 04             	sub    $0x4,%esp
f0101a39:	68 00 10 00 00       	push   $0x1000
f0101a3e:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101a40:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a45:	50                   	push   %eax
f0101a46:	e8 56 2d 00 00       	call   f01047a1 <memset>
	page_free(pp0);
f0101a4b:	89 34 24             	mov    %esi,(%esp)
f0101a4e:	e8 89 f9 ff ff       	call   f01013dc <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101a53:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101a5a:	e8 f3 f8 ff ff       	call   f0101352 <page_alloc>
f0101a5f:	83 c4 10             	add    $0x10,%esp
f0101a62:	85 c0                	test   %eax,%eax
f0101a64:	75 19                	jne    f0101a7f <mem_init+0x456>
f0101a66:	68 00 5f 10 f0       	push   $0xf0105f00
f0101a6b:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101a70:	68 af 02 00 00       	push   $0x2af
f0101a75:	68 75 5d 10 f0       	push   $0xf0105d75
f0101a7a:	e8 4a e6 ff ff       	call   f01000c9 <_panic>
	assert(pp && pp0 == pp);
f0101a7f:	39 c6                	cmp    %eax,%esi
f0101a81:	74 19                	je     f0101a9c <mem_init+0x473>
f0101a83:	68 1e 5f 10 f0       	push   $0xf0105f1e
f0101a88:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101a8d:	68 b0 02 00 00       	push   $0x2b0
f0101a92:	68 75 5d 10 f0       	push   $0xf0105d75
f0101a97:	e8 2d e6 ff ff       	call   f01000c9 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a9c:	89 f2                	mov    %esi,%edx
f0101a9e:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f0101aa4:	c1 fa 03             	sar    $0x3,%edx
f0101aa7:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101aaa:	89 d0                	mov    %edx,%eax
f0101aac:	c1 e8 0c             	shr    $0xc,%eax
f0101aaf:	3b 05 84 7f 1d f0    	cmp    0xf01d7f84,%eax
f0101ab5:	72 12                	jb     f0101ac9 <mem_init+0x4a0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ab7:	52                   	push   %edx
f0101ab8:	68 14 56 10 f0       	push   $0xf0105614
f0101abd:	6a 56                	push   $0x56
f0101abf:	68 81 5d 10 f0       	push   $0xf0105d81
f0101ac4:	e8 00 e6 ff ff       	call   f01000c9 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101ac9:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101ad0:	75 11                	jne    f0101ae3 <mem_init+0x4ba>
f0101ad2:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101ad8:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101ade:	80 38 00             	cmpb   $0x0,(%eax)
f0101ae1:	74 19                	je     f0101afc <mem_init+0x4d3>
f0101ae3:	68 2e 5f 10 f0       	push   $0xf0105f2e
f0101ae8:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101aed:	68 b3 02 00 00       	push   $0x2b3
f0101af2:	68 75 5d 10 f0       	push   $0xf0105d75
f0101af7:	e8 cd e5 ff ff       	call   f01000c9 <_panic>
f0101afc:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101afd:	39 d0                	cmp    %edx,%eax
f0101aff:	75 dd                	jne    f0101ade <mem_init+0x4b5>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101b01:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101b04:	89 0d ac 72 1d f0    	mov    %ecx,0xf01d72ac

	// free the pages we took
	page_free(pp0);
f0101b0a:	83 ec 0c             	sub    $0xc,%esp
f0101b0d:	56                   	push   %esi
f0101b0e:	e8 c9 f8 ff ff       	call   f01013dc <page_free>
	page_free(pp1);
f0101b13:	89 3c 24             	mov    %edi,(%esp)
f0101b16:	e8 c1 f8 ff ff       	call   f01013dc <page_free>
	page_free(pp2);
f0101b1b:	83 c4 04             	add    $0x4,%esp
f0101b1e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b21:	e8 b6 f8 ff ff       	call   f01013dc <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b26:	a1 ac 72 1d f0       	mov    0xf01d72ac,%eax
f0101b2b:	83 c4 10             	add    $0x10,%esp
f0101b2e:	85 c0                	test   %eax,%eax
f0101b30:	74 07                	je     f0101b39 <mem_init+0x510>
		--nfree;
f0101b32:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b33:	8b 00                	mov    (%eax),%eax
f0101b35:	85 c0                	test   %eax,%eax
f0101b37:	75 f9                	jne    f0101b32 <mem_init+0x509>
		--nfree;
	assert(nfree == 0);
f0101b39:	85 db                	test   %ebx,%ebx
f0101b3b:	74 19                	je     f0101b56 <mem_init+0x52d>
f0101b3d:	68 38 5f 10 f0       	push   $0xf0105f38
f0101b42:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101b47:	68 c0 02 00 00       	push   $0x2c0
f0101b4c:	68 75 5d 10 f0       	push   $0xf0105d75
f0101b51:	e8 73 e5 ff ff       	call   f01000c9 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101b56:	83 ec 0c             	sub    $0xc,%esp
f0101b59:	68 78 57 10 f0       	push   $0xf0105778
f0101b5e:	e8 96 18 00 00       	call   f01033f9 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101b63:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b6a:	e8 e3 f7 ff ff       	call   f0101352 <page_alloc>
f0101b6f:	89 c7                	mov    %eax,%edi
f0101b71:	83 c4 10             	add    $0x10,%esp
f0101b74:	85 c0                	test   %eax,%eax
f0101b76:	75 19                	jne    f0101b91 <mem_init+0x568>
f0101b78:	68 46 5e 10 f0       	push   $0xf0105e46
f0101b7d:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101b82:	68 1e 03 00 00       	push   $0x31e
f0101b87:	68 75 5d 10 f0       	push   $0xf0105d75
f0101b8c:	e8 38 e5 ff ff       	call   f01000c9 <_panic>
	assert((pp1 = page_alloc(0)));
f0101b91:	83 ec 0c             	sub    $0xc,%esp
f0101b94:	6a 00                	push   $0x0
f0101b96:	e8 b7 f7 ff ff       	call   f0101352 <page_alloc>
f0101b9b:	89 c6                	mov    %eax,%esi
f0101b9d:	83 c4 10             	add    $0x10,%esp
f0101ba0:	85 c0                	test   %eax,%eax
f0101ba2:	75 19                	jne    f0101bbd <mem_init+0x594>
f0101ba4:	68 5c 5e 10 f0       	push   $0xf0105e5c
f0101ba9:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101bae:	68 1f 03 00 00       	push   $0x31f
f0101bb3:	68 75 5d 10 f0       	push   $0xf0105d75
f0101bb8:	e8 0c e5 ff ff       	call   f01000c9 <_panic>
	assert((pp2 = page_alloc(0)));
f0101bbd:	83 ec 0c             	sub    $0xc,%esp
f0101bc0:	6a 00                	push   $0x0
f0101bc2:	e8 8b f7 ff ff       	call   f0101352 <page_alloc>
f0101bc7:	89 c3                	mov    %eax,%ebx
f0101bc9:	83 c4 10             	add    $0x10,%esp
f0101bcc:	85 c0                	test   %eax,%eax
f0101bce:	75 19                	jne    f0101be9 <mem_init+0x5c0>
f0101bd0:	68 72 5e 10 f0       	push   $0xf0105e72
f0101bd5:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101bda:	68 20 03 00 00       	push   $0x320
f0101bdf:	68 75 5d 10 f0       	push   $0xf0105d75
f0101be4:	e8 e0 e4 ff ff       	call   f01000c9 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101be9:	39 f7                	cmp    %esi,%edi
f0101beb:	75 19                	jne    f0101c06 <mem_init+0x5dd>
f0101bed:	68 88 5e 10 f0       	push   $0xf0105e88
f0101bf2:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101bf7:	68 23 03 00 00       	push   $0x323
f0101bfc:	68 75 5d 10 f0       	push   $0xf0105d75
f0101c01:	e8 c3 e4 ff ff       	call   f01000c9 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c06:	39 c6                	cmp    %eax,%esi
f0101c08:	74 04                	je     f0101c0e <mem_init+0x5e5>
f0101c0a:	39 c7                	cmp    %eax,%edi
f0101c0c:	75 19                	jne    f0101c27 <mem_init+0x5fe>
f0101c0e:	68 58 57 10 f0       	push   $0xf0105758
f0101c13:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101c18:	68 24 03 00 00       	push   $0x324
f0101c1d:	68 75 5d 10 f0       	push   $0xf0105d75
f0101c22:	e8 a2 e4 ff ff       	call   f01000c9 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101c27:	a1 ac 72 1d f0       	mov    0xf01d72ac,%eax
f0101c2c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	page_free_list = 0;
f0101c2f:	c7 05 ac 72 1d f0 00 	movl   $0x0,0xf01d72ac
f0101c36:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101c39:	83 ec 0c             	sub    $0xc,%esp
f0101c3c:	6a 00                	push   $0x0
f0101c3e:	e8 0f f7 ff ff       	call   f0101352 <page_alloc>
f0101c43:	83 c4 10             	add    $0x10,%esp
f0101c46:	85 c0                	test   %eax,%eax
f0101c48:	74 19                	je     f0101c63 <mem_init+0x63a>
f0101c4a:	68 f1 5e 10 f0       	push   $0xf0105ef1
f0101c4f:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101c54:	68 2b 03 00 00       	push   $0x32b
f0101c59:	68 75 5d 10 f0       	push   $0xf0105d75
f0101c5e:	e8 66 e4 ff ff       	call   f01000c9 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101c63:	83 ec 04             	sub    $0x4,%esp
f0101c66:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101c69:	50                   	push   %eax
f0101c6a:	6a 00                	push   $0x0
f0101c6c:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0101c72:	e8 8b f8 ff ff       	call   f0101502 <page_lookup>
f0101c77:	83 c4 10             	add    $0x10,%esp
f0101c7a:	85 c0                	test   %eax,%eax
f0101c7c:	74 19                	je     f0101c97 <mem_init+0x66e>
f0101c7e:	68 98 57 10 f0       	push   $0xf0105798
f0101c83:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101c88:	68 2e 03 00 00       	push   $0x32e
f0101c8d:	68 75 5d 10 f0       	push   $0xf0105d75
f0101c92:	e8 32 e4 ff ff       	call   f01000c9 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101c97:	6a 02                	push   $0x2
f0101c99:	6a 00                	push   $0x0
f0101c9b:	56                   	push   %esi
f0101c9c:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0101ca2:	e8 19 f9 ff ff       	call   f01015c0 <page_insert>
f0101ca7:	83 c4 10             	add    $0x10,%esp
f0101caa:	85 c0                	test   %eax,%eax
f0101cac:	78 19                	js     f0101cc7 <mem_init+0x69e>
f0101cae:	68 d0 57 10 f0       	push   $0xf01057d0
f0101cb3:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101cb8:	68 31 03 00 00       	push   $0x331
f0101cbd:	68 75 5d 10 f0       	push   $0xf0105d75
f0101cc2:	e8 02 e4 ff ff       	call   f01000c9 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101cc7:	83 ec 0c             	sub    $0xc,%esp
f0101cca:	57                   	push   %edi
f0101ccb:	e8 0c f7 ff ff       	call   f01013dc <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101cd0:	6a 02                	push   $0x2
f0101cd2:	6a 00                	push   $0x0
f0101cd4:	56                   	push   %esi
f0101cd5:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0101cdb:	e8 e0 f8 ff ff       	call   f01015c0 <page_insert>
f0101ce0:	83 c4 20             	add    $0x20,%esp
f0101ce3:	85 c0                	test   %eax,%eax
f0101ce5:	74 19                	je     f0101d00 <mem_init+0x6d7>
f0101ce7:	68 00 58 10 f0       	push   $0xf0105800
f0101cec:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101cf1:	68 35 03 00 00       	push   $0x335
f0101cf6:	68 75 5d 10 f0       	push   $0xf0105d75
f0101cfb:	e8 c9 e3 ff ff       	call   f01000c9 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d00:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f0101d05:	8b 08                	mov    (%eax),%ecx
f0101d07:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d0d:	89 fa                	mov    %edi,%edx
f0101d0f:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f0101d15:	c1 fa 03             	sar    $0x3,%edx
f0101d18:	c1 e2 0c             	shl    $0xc,%edx
f0101d1b:	39 d1                	cmp    %edx,%ecx
f0101d1d:	74 19                	je     f0101d38 <mem_init+0x70f>
f0101d1f:	68 30 58 10 f0       	push   $0xf0105830
f0101d24:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101d29:	68 36 03 00 00       	push   $0x336
f0101d2e:	68 75 5d 10 f0       	push   $0xf0105d75
f0101d33:	e8 91 e3 ff ff       	call   f01000c9 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101d38:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d3d:	e8 21 f2 ff ff       	call   f0100f63 <check_va2pa>
f0101d42:	89 f2                	mov    %esi,%edx
f0101d44:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f0101d4a:	c1 fa 03             	sar    $0x3,%edx
f0101d4d:	c1 e2 0c             	shl    $0xc,%edx
f0101d50:	39 d0                	cmp    %edx,%eax
f0101d52:	74 19                	je     f0101d6d <mem_init+0x744>
f0101d54:	68 58 58 10 f0       	push   $0xf0105858
f0101d59:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101d5e:	68 37 03 00 00       	push   $0x337
f0101d63:	68 75 5d 10 f0       	push   $0xf0105d75
f0101d68:	e8 5c e3 ff ff       	call   f01000c9 <_panic>
	assert(pp1->pp_ref == 1);
f0101d6d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d72:	74 19                	je     f0101d8d <mem_init+0x764>
f0101d74:	68 43 5f 10 f0       	push   $0xf0105f43
f0101d79:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101d7e:	68 38 03 00 00       	push   $0x338
f0101d83:	68 75 5d 10 f0       	push   $0xf0105d75
f0101d88:	e8 3c e3 ff ff       	call   f01000c9 <_panic>
	assert(pp0->pp_ref == 1);
f0101d8d:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d92:	74 19                	je     f0101dad <mem_init+0x784>
f0101d94:	68 54 5f 10 f0       	push   $0xf0105f54
f0101d99:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101d9e:	68 39 03 00 00       	push   $0x339
f0101da3:	68 75 5d 10 f0       	push   $0xf0105d75
f0101da8:	e8 1c e3 ff ff       	call   f01000c9 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101dad:	6a 02                	push   $0x2
f0101daf:	68 00 10 00 00       	push   $0x1000
f0101db4:	53                   	push   %ebx
f0101db5:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0101dbb:	e8 00 f8 ff ff       	call   f01015c0 <page_insert>
f0101dc0:	83 c4 10             	add    $0x10,%esp
f0101dc3:	85 c0                	test   %eax,%eax
f0101dc5:	74 19                	je     f0101de0 <mem_init+0x7b7>
f0101dc7:	68 88 58 10 f0       	push   $0xf0105888
f0101dcc:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101dd1:	68 3c 03 00 00       	push   $0x33c
f0101dd6:	68 75 5d 10 f0       	push   $0xf0105d75
f0101ddb:	e8 e9 e2 ff ff       	call   f01000c9 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101de0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101de5:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f0101dea:	e8 74 f1 ff ff       	call   f0100f63 <check_va2pa>
f0101def:	89 da                	mov    %ebx,%edx
f0101df1:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f0101df7:	c1 fa 03             	sar    $0x3,%edx
f0101dfa:	c1 e2 0c             	shl    $0xc,%edx
f0101dfd:	39 d0                	cmp    %edx,%eax
f0101dff:	74 19                	je     f0101e1a <mem_init+0x7f1>
f0101e01:	68 c4 58 10 f0       	push   $0xf01058c4
f0101e06:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101e0b:	68 3d 03 00 00       	push   $0x33d
f0101e10:	68 75 5d 10 f0       	push   $0xf0105d75
f0101e15:	e8 af e2 ff ff       	call   f01000c9 <_panic>
	assert(pp2->pp_ref == 1);
f0101e1a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e1f:	74 19                	je     f0101e3a <mem_init+0x811>
f0101e21:	68 65 5f 10 f0       	push   $0xf0105f65
f0101e26:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101e2b:	68 3e 03 00 00       	push   $0x33e
f0101e30:	68 75 5d 10 f0       	push   $0xf0105d75
f0101e35:	e8 8f e2 ff ff       	call   f01000c9 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101e3a:	83 ec 0c             	sub    $0xc,%esp
f0101e3d:	6a 00                	push   $0x0
f0101e3f:	e8 0e f5 ff ff       	call   f0101352 <page_alloc>
f0101e44:	83 c4 10             	add    $0x10,%esp
f0101e47:	85 c0                	test   %eax,%eax
f0101e49:	74 19                	je     f0101e64 <mem_init+0x83b>
f0101e4b:	68 f1 5e 10 f0       	push   $0xf0105ef1
f0101e50:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101e55:	68 41 03 00 00       	push   $0x341
f0101e5a:	68 75 5d 10 f0       	push   $0xf0105d75
f0101e5f:	e8 65 e2 ff ff       	call   f01000c9 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e64:	6a 02                	push   $0x2
f0101e66:	68 00 10 00 00       	push   $0x1000
f0101e6b:	53                   	push   %ebx
f0101e6c:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0101e72:	e8 49 f7 ff ff       	call   f01015c0 <page_insert>
f0101e77:	83 c4 10             	add    $0x10,%esp
f0101e7a:	85 c0                	test   %eax,%eax
f0101e7c:	74 19                	je     f0101e97 <mem_init+0x86e>
f0101e7e:	68 88 58 10 f0       	push   $0xf0105888
f0101e83:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101e88:	68 44 03 00 00       	push   $0x344
f0101e8d:	68 75 5d 10 f0       	push   $0xf0105d75
f0101e92:	e8 32 e2 ff ff       	call   f01000c9 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e97:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e9c:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f0101ea1:	e8 bd f0 ff ff       	call   f0100f63 <check_va2pa>
f0101ea6:	89 da                	mov    %ebx,%edx
f0101ea8:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f0101eae:	c1 fa 03             	sar    $0x3,%edx
f0101eb1:	c1 e2 0c             	shl    $0xc,%edx
f0101eb4:	39 d0                	cmp    %edx,%eax
f0101eb6:	74 19                	je     f0101ed1 <mem_init+0x8a8>
f0101eb8:	68 c4 58 10 f0       	push   $0xf01058c4
f0101ebd:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101ec2:	68 45 03 00 00       	push   $0x345
f0101ec7:	68 75 5d 10 f0       	push   $0xf0105d75
f0101ecc:	e8 f8 e1 ff ff       	call   f01000c9 <_panic>
	assert(pp2->pp_ref == 1);
f0101ed1:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ed6:	74 19                	je     f0101ef1 <mem_init+0x8c8>
f0101ed8:	68 65 5f 10 f0       	push   $0xf0105f65
f0101edd:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101ee2:	68 46 03 00 00       	push   $0x346
f0101ee7:	68 75 5d 10 f0       	push   $0xf0105d75
f0101eec:	e8 d8 e1 ff ff       	call   f01000c9 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ef1:	83 ec 0c             	sub    $0xc,%esp
f0101ef4:	6a 00                	push   $0x0
f0101ef6:	e8 57 f4 ff ff       	call   f0101352 <page_alloc>
f0101efb:	83 c4 10             	add    $0x10,%esp
f0101efe:	85 c0                	test   %eax,%eax
f0101f00:	74 19                	je     f0101f1b <mem_init+0x8f2>
f0101f02:	68 f1 5e 10 f0       	push   $0xf0105ef1
f0101f07:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101f0c:	68 4a 03 00 00       	push   $0x34a
f0101f11:	68 75 5d 10 f0       	push   $0xf0105d75
f0101f16:	e8 ae e1 ff ff       	call   f01000c9 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101f1b:	8b 15 88 7f 1d f0    	mov    0xf01d7f88,%edx
f0101f21:	8b 02                	mov    (%edx),%eax
f0101f23:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f28:	89 c1                	mov    %eax,%ecx
f0101f2a:	c1 e9 0c             	shr    $0xc,%ecx
f0101f2d:	3b 0d 84 7f 1d f0    	cmp    0xf01d7f84,%ecx
f0101f33:	72 15                	jb     f0101f4a <mem_init+0x921>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f35:	50                   	push   %eax
f0101f36:	68 14 56 10 f0       	push   $0xf0105614
f0101f3b:	68 4d 03 00 00       	push   $0x34d
f0101f40:	68 75 5d 10 f0       	push   $0xf0105d75
f0101f45:	e8 7f e1 ff ff       	call   f01000c9 <_panic>
	return (void *)(pa + KERNBASE);
f0101f4a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101f4f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101f52:	83 ec 04             	sub    $0x4,%esp
f0101f55:	6a 00                	push   $0x0
f0101f57:	68 00 10 00 00       	push   $0x1000
f0101f5c:	52                   	push   %edx
f0101f5d:	e8 b8 f4 ff ff       	call   f010141a <pgdir_walk>
f0101f62:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101f65:	83 c2 04             	add    $0x4,%edx
f0101f68:	83 c4 10             	add    $0x10,%esp
f0101f6b:	39 d0                	cmp    %edx,%eax
f0101f6d:	74 19                	je     f0101f88 <mem_init+0x95f>
f0101f6f:	68 f4 58 10 f0       	push   $0xf01058f4
f0101f74:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101f79:	68 4e 03 00 00       	push   $0x34e
f0101f7e:	68 75 5d 10 f0       	push   $0xf0105d75
f0101f83:	e8 41 e1 ff ff       	call   f01000c9 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101f88:	6a 06                	push   $0x6
f0101f8a:	68 00 10 00 00       	push   $0x1000
f0101f8f:	53                   	push   %ebx
f0101f90:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0101f96:	e8 25 f6 ff ff       	call   f01015c0 <page_insert>
f0101f9b:	83 c4 10             	add    $0x10,%esp
f0101f9e:	85 c0                	test   %eax,%eax
f0101fa0:	74 19                	je     f0101fbb <mem_init+0x992>
f0101fa2:	68 34 59 10 f0       	push   $0xf0105934
f0101fa7:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101fac:	68 51 03 00 00       	push   $0x351
f0101fb1:	68 75 5d 10 f0       	push   $0xf0105d75
f0101fb6:	e8 0e e1 ff ff       	call   f01000c9 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101fbb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fc0:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f0101fc5:	e8 99 ef ff ff       	call   f0100f63 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101fca:	89 da                	mov    %ebx,%edx
f0101fcc:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f0101fd2:	c1 fa 03             	sar    $0x3,%edx
f0101fd5:	c1 e2 0c             	shl    $0xc,%edx
f0101fd8:	39 d0                	cmp    %edx,%eax
f0101fda:	74 19                	je     f0101ff5 <mem_init+0x9cc>
f0101fdc:	68 c4 58 10 f0       	push   $0xf01058c4
f0101fe1:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0101fe6:	68 52 03 00 00       	push   $0x352
f0101feb:	68 75 5d 10 f0       	push   $0xf0105d75
f0101ff0:	e8 d4 e0 ff ff       	call   f01000c9 <_panic>
	assert(pp2->pp_ref == 1);
f0101ff5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ffa:	74 19                	je     f0102015 <mem_init+0x9ec>
f0101ffc:	68 65 5f 10 f0       	push   $0xf0105f65
f0102001:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102006:	68 53 03 00 00       	push   $0x353
f010200b:	68 75 5d 10 f0       	push   $0xf0105d75
f0102010:	e8 b4 e0 ff ff       	call   f01000c9 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102015:	83 ec 04             	sub    $0x4,%esp
f0102018:	6a 00                	push   $0x0
f010201a:	68 00 10 00 00       	push   $0x1000
f010201f:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0102025:	e8 f0 f3 ff ff       	call   f010141a <pgdir_walk>
f010202a:	83 c4 10             	add    $0x10,%esp
f010202d:	f6 00 04             	testb  $0x4,(%eax)
f0102030:	75 19                	jne    f010204b <mem_init+0xa22>
f0102032:	68 74 59 10 f0       	push   $0xf0105974
f0102037:	68 9b 5d 10 f0       	push   $0xf0105d9b
f010203c:	68 54 03 00 00       	push   $0x354
f0102041:	68 75 5d 10 f0       	push   $0xf0105d75
f0102046:	e8 7e e0 ff ff       	call   f01000c9 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010204b:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f0102050:	f6 00 04             	testb  $0x4,(%eax)
f0102053:	75 19                	jne    f010206e <mem_init+0xa45>
f0102055:	68 76 5f 10 f0       	push   $0xf0105f76
f010205a:	68 9b 5d 10 f0       	push   $0xf0105d9b
f010205f:	68 55 03 00 00       	push   $0x355
f0102064:	68 75 5d 10 f0       	push   $0xf0105d75
f0102069:	e8 5b e0 ff ff       	call   f01000c9 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010206e:	6a 02                	push   $0x2
f0102070:	68 00 10 00 00       	push   $0x1000
f0102075:	53                   	push   %ebx
f0102076:	50                   	push   %eax
f0102077:	e8 44 f5 ff ff       	call   f01015c0 <page_insert>
f010207c:	83 c4 10             	add    $0x10,%esp
f010207f:	85 c0                	test   %eax,%eax
f0102081:	74 19                	je     f010209c <mem_init+0xa73>
f0102083:	68 88 58 10 f0       	push   $0xf0105888
f0102088:	68 9b 5d 10 f0       	push   $0xf0105d9b
f010208d:	68 58 03 00 00       	push   $0x358
f0102092:	68 75 5d 10 f0       	push   $0xf0105d75
f0102097:	e8 2d e0 ff ff       	call   f01000c9 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010209c:	83 ec 04             	sub    $0x4,%esp
f010209f:	6a 00                	push   $0x0
f01020a1:	68 00 10 00 00       	push   $0x1000
f01020a6:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f01020ac:	e8 69 f3 ff ff       	call   f010141a <pgdir_walk>
f01020b1:	83 c4 10             	add    $0x10,%esp
f01020b4:	f6 00 02             	testb  $0x2,(%eax)
f01020b7:	75 19                	jne    f01020d2 <mem_init+0xaa9>
f01020b9:	68 a8 59 10 f0       	push   $0xf01059a8
f01020be:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01020c3:	68 59 03 00 00       	push   $0x359
f01020c8:	68 75 5d 10 f0       	push   $0xf0105d75
f01020cd:	e8 f7 df ff ff       	call   f01000c9 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020d2:	83 ec 04             	sub    $0x4,%esp
f01020d5:	6a 00                	push   $0x0
f01020d7:	68 00 10 00 00       	push   $0x1000
f01020dc:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f01020e2:	e8 33 f3 ff ff       	call   f010141a <pgdir_walk>
f01020e7:	83 c4 10             	add    $0x10,%esp
f01020ea:	f6 00 04             	testb  $0x4,(%eax)
f01020ed:	74 19                	je     f0102108 <mem_init+0xadf>
f01020ef:	68 dc 59 10 f0       	push   $0xf01059dc
f01020f4:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01020f9:	68 5a 03 00 00       	push   $0x35a
f01020fe:	68 75 5d 10 f0       	push   $0xf0105d75
f0102103:	e8 c1 df ff ff       	call   f01000c9 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102108:	6a 02                	push   $0x2
f010210a:	68 00 00 40 00       	push   $0x400000
f010210f:	57                   	push   %edi
f0102110:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0102116:	e8 a5 f4 ff ff       	call   f01015c0 <page_insert>
f010211b:	83 c4 10             	add    $0x10,%esp
f010211e:	85 c0                	test   %eax,%eax
f0102120:	78 19                	js     f010213b <mem_init+0xb12>
f0102122:	68 14 5a 10 f0       	push   $0xf0105a14
f0102127:	68 9b 5d 10 f0       	push   $0xf0105d9b
f010212c:	68 5d 03 00 00       	push   $0x35d
f0102131:	68 75 5d 10 f0       	push   $0xf0105d75
f0102136:	e8 8e df ff ff       	call   f01000c9 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010213b:	6a 02                	push   $0x2
f010213d:	68 00 10 00 00       	push   $0x1000
f0102142:	56                   	push   %esi
f0102143:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0102149:	e8 72 f4 ff ff       	call   f01015c0 <page_insert>
f010214e:	83 c4 10             	add    $0x10,%esp
f0102151:	85 c0                	test   %eax,%eax
f0102153:	74 19                	je     f010216e <mem_init+0xb45>
f0102155:	68 4c 5a 10 f0       	push   $0xf0105a4c
f010215a:	68 9b 5d 10 f0       	push   $0xf0105d9b
f010215f:	68 60 03 00 00       	push   $0x360
f0102164:	68 75 5d 10 f0       	push   $0xf0105d75
f0102169:	e8 5b df ff ff       	call   f01000c9 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010216e:	83 ec 04             	sub    $0x4,%esp
f0102171:	6a 00                	push   $0x0
f0102173:	68 00 10 00 00       	push   $0x1000
f0102178:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f010217e:	e8 97 f2 ff ff       	call   f010141a <pgdir_walk>
f0102183:	83 c4 10             	add    $0x10,%esp
f0102186:	f6 00 04             	testb  $0x4,(%eax)
f0102189:	74 19                	je     f01021a4 <mem_init+0xb7b>
f010218b:	68 dc 59 10 f0       	push   $0xf01059dc
f0102190:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102195:	68 61 03 00 00       	push   $0x361
f010219a:	68 75 5d 10 f0       	push   $0xf0105d75
f010219f:	e8 25 df ff ff       	call   f01000c9 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01021a4:	ba 00 00 00 00       	mov    $0x0,%edx
f01021a9:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f01021ae:	e8 b0 ed ff ff       	call   f0100f63 <check_va2pa>
f01021b3:	89 f2                	mov    %esi,%edx
f01021b5:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f01021bb:	c1 fa 03             	sar    $0x3,%edx
f01021be:	c1 e2 0c             	shl    $0xc,%edx
f01021c1:	39 d0                	cmp    %edx,%eax
f01021c3:	74 19                	je     f01021de <mem_init+0xbb5>
f01021c5:	68 88 5a 10 f0       	push   $0xf0105a88
f01021ca:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01021cf:	68 64 03 00 00       	push   $0x364
f01021d4:	68 75 5d 10 f0       	push   $0xf0105d75
f01021d9:	e8 eb de ff ff       	call   f01000c9 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01021de:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021e3:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f01021e8:	e8 76 ed ff ff       	call   f0100f63 <check_va2pa>
f01021ed:	89 f2                	mov    %esi,%edx
f01021ef:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f01021f5:	c1 fa 03             	sar    $0x3,%edx
f01021f8:	c1 e2 0c             	shl    $0xc,%edx
f01021fb:	39 d0                	cmp    %edx,%eax
f01021fd:	74 19                	je     f0102218 <mem_init+0xbef>
f01021ff:	68 b4 5a 10 f0       	push   $0xf0105ab4
f0102204:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102209:	68 65 03 00 00       	push   $0x365
f010220e:	68 75 5d 10 f0       	push   $0xf0105d75
f0102213:	e8 b1 de ff ff       	call   f01000c9 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102218:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f010221d:	74 19                	je     f0102238 <mem_init+0xc0f>
f010221f:	68 8c 5f 10 f0       	push   $0xf0105f8c
f0102224:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102229:	68 67 03 00 00       	push   $0x367
f010222e:	68 75 5d 10 f0       	push   $0xf0105d75
f0102233:	e8 91 de ff ff       	call   f01000c9 <_panic>
	assert(pp2->pp_ref == 0);
f0102238:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010223d:	74 19                	je     f0102258 <mem_init+0xc2f>
f010223f:	68 9d 5f 10 f0       	push   $0xf0105f9d
f0102244:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102249:	68 68 03 00 00       	push   $0x368
f010224e:	68 75 5d 10 f0       	push   $0xf0105d75
f0102253:	e8 71 de ff ff       	call   f01000c9 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102258:	83 ec 0c             	sub    $0xc,%esp
f010225b:	6a 00                	push   $0x0
f010225d:	e8 f0 f0 ff ff       	call   f0101352 <page_alloc>
f0102262:	83 c4 10             	add    $0x10,%esp
f0102265:	85 c0                	test   %eax,%eax
f0102267:	74 04                	je     f010226d <mem_init+0xc44>
f0102269:	39 c3                	cmp    %eax,%ebx
f010226b:	74 19                	je     f0102286 <mem_init+0xc5d>
f010226d:	68 e4 5a 10 f0       	push   $0xf0105ae4
f0102272:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102277:	68 6b 03 00 00       	push   $0x36b
f010227c:	68 75 5d 10 f0       	push   $0xf0105d75
f0102281:	e8 43 de ff ff       	call   f01000c9 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102286:	83 ec 08             	sub    $0x8,%esp
f0102289:	6a 00                	push   $0x0
f010228b:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0102291:	e8 dd f2 ff ff       	call   f0101573 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102296:	ba 00 00 00 00       	mov    $0x0,%edx
f010229b:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f01022a0:	e8 be ec ff ff       	call   f0100f63 <check_va2pa>
f01022a5:	83 c4 10             	add    $0x10,%esp
f01022a8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022ab:	74 19                	je     f01022c6 <mem_init+0xc9d>
f01022ad:	68 08 5b 10 f0       	push   $0xf0105b08
f01022b2:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01022b7:	68 6f 03 00 00       	push   $0x36f
f01022bc:	68 75 5d 10 f0       	push   $0xf0105d75
f01022c1:	e8 03 de ff ff       	call   f01000c9 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01022c6:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022cb:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f01022d0:	e8 8e ec ff ff       	call   f0100f63 <check_va2pa>
f01022d5:	89 f2                	mov    %esi,%edx
f01022d7:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f01022dd:	c1 fa 03             	sar    $0x3,%edx
f01022e0:	c1 e2 0c             	shl    $0xc,%edx
f01022e3:	39 d0                	cmp    %edx,%eax
f01022e5:	74 19                	je     f0102300 <mem_init+0xcd7>
f01022e7:	68 b4 5a 10 f0       	push   $0xf0105ab4
f01022ec:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01022f1:	68 70 03 00 00       	push   $0x370
f01022f6:	68 75 5d 10 f0       	push   $0xf0105d75
f01022fb:	e8 c9 dd ff ff       	call   f01000c9 <_panic>
	assert(pp1->pp_ref == 1);
f0102300:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102305:	74 19                	je     f0102320 <mem_init+0xcf7>
f0102307:	68 43 5f 10 f0       	push   $0xf0105f43
f010230c:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102311:	68 71 03 00 00       	push   $0x371
f0102316:	68 75 5d 10 f0       	push   $0xf0105d75
f010231b:	e8 a9 dd ff ff       	call   f01000c9 <_panic>
	assert(pp2->pp_ref == 0);
f0102320:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102325:	74 19                	je     f0102340 <mem_init+0xd17>
f0102327:	68 9d 5f 10 f0       	push   $0xf0105f9d
f010232c:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102331:	68 72 03 00 00       	push   $0x372
f0102336:	68 75 5d 10 f0       	push   $0xf0105d75
f010233b:	e8 89 dd ff ff       	call   f01000c9 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102340:	83 ec 08             	sub    $0x8,%esp
f0102343:	68 00 10 00 00       	push   $0x1000
f0102348:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f010234e:	e8 20 f2 ff ff       	call   f0101573 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102353:	ba 00 00 00 00       	mov    $0x0,%edx
f0102358:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f010235d:	e8 01 ec ff ff       	call   f0100f63 <check_va2pa>
f0102362:	83 c4 10             	add    $0x10,%esp
f0102365:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102368:	74 19                	je     f0102383 <mem_init+0xd5a>
f010236a:	68 08 5b 10 f0       	push   $0xf0105b08
f010236f:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102374:	68 76 03 00 00       	push   $0x376
f0102379:	68 75 5d 10 f0       	push   $0xf0105d75
f010237e:	e8 46 dd ff ff       	call   f01000c9 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102383:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102388:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f010238d:	e8 d1 eb ff ff       	call   f0100f63 <check_va2pa>
f0102392:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102395:	74 19                	je     f01023b0 <mem_init+0xd87>
f0102397:	68 2c 5b 10 f0       	push   $0xf0105b2c
f010239c:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01023a1:	68 77 03 00 00       	push   $0x377
f01023a6:	68 75 5d 10 f0       	push   $0xf0105d75
f01023ab:	e8 19 dd ff ff       	call   f01000c9 <_panic>
	assert(pp1->pp_ref == 0);
f01023b0:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01023b5:	74 19                	je     f01023d0 <mem_init+0xda7>
f01023b7:	68 ae 5f 10 f0       	push   $0xf0105fae
f01023bc:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01023c1:	68 78 03 00 00       	push   $0x378
f01023c6:	68 75 5d 10 f0       	push   $0xf0105d75
f01023cb:	e8 f9 dc ff ff       	call   f01000c9 <_panic>
	assert(pp2->pp_ref == 0);
f01023d0:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01023d5:	74 19                	je     f01023f0 <mem_init+0xdc7>
f01023d7:	68 9d 5f 10 f0       	push   $0xf0105f9d
f01023dc:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01023e1:	68 79 03 00 00       	push   $0x379
f01023e6:	68 75 5d 10 f0       	push   $0xf0105d75
f01023eb:	e8 d9 dc ff ff       	call   f01000c9 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01023f0:	83 ec 0c             	sub    $0xc,%esp
f01023f3:	6a 00                	push   $0x0
f01023f5:	e8 58 ef ff ff       	call   f0101352 <page_alloc>
f01023fa:	83 c4 10             	add    $0x10,%esp
f01023fd:	85 c0                	test   %eax,%eax
f01023ff:	74 04                	je     f0102405 <mem_init+0xddc>
f0102401:	39 c6                	cmp    %eax,%esi
f0102403:	74 19                	je     f010241e <mem_init+0xdf5>
f0102405:	68 54 5b 10 f0       	push   $0xf0105b54
f010240a:	68 9b 5d 10 f0       	push   $0xf0105d9b
f010240f:	68 7c 03 00 00       	push   $0x37c
f0102414:	68 75 5d 10 f0       	push   $0xf0105d75
f0102419:	e8 ab dc ff ff       	call   f01000c9 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010241e:	83 ec 0c             	sub    $0xc,%esp
f0102421:	6a 00                	push   $0x0
f0102423:	e8 2a ef ff ff       	call   f0101352 <page_alloc>
f0102428:	83 c4 10             	add    $0x10,%esp
f010242b:	85 c0                	test   %eax,%eax
f010242d:	74 19                	je     f0102448 <mem_init+0xe1f>
f010242f:	68 f1 5e 10 f0       	push   $0xf0105ef1
f0102434:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102439:	68 7f 03 00 00       	push   $0x37f
f010243e:	68 75 5d 10 f0       	push   $0xf0105d75
f0102443:	e8 81 dc ff ff       	call   f01000c9 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102448:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f010244d:	8b 08                	mov    (%eax),%ecx
f010244f:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102455:	89 fa                	mov    %edi,%edx
f0102457:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f010245d:	c1 fa 03             	sar    $0x3,%edx
f0102460:	c1 e2 0c             	shl    $0xc,%edx
f0102463:	39 d1                	cmp    %edx,%ecx
f0102465:	74 19                	je     f0102480 <mem_init+0xe57>
f0102467:	68 30 58 10 f0       	push   $0xf0105830
f010246c:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102471:	68 82 03 00 00       	push   $0x382
f0102476:	68 75 5d 10 f0       	push   $0xf0105d75
f010247b:	e8 49 dc ff ff       	call   f01000c9 <_panic>
	kern_pgdir[0] = 0;
f0102480:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102486:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010248b:	74 19                	je     f01024a6 <mem_init+0xe7d>
f010248d:	68 54 5f 10 f0       	push   $0xf0105f54
f0102492:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102497:	68 84 03 00 00       	push   $0x384
f010249c:	68 75 5d 10 f0       	push   $0xf0105d75
f01024a1:	e8 23 dc ff ff       	call   f01000c9 <_panic>
	pp0->pp_ref = 0;

	kern_pgdir[PDX(va)] = 0;
f01024a6:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f01024ab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01024b1:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
f01024b7:	89 f8                	mov    %edi,%eax
f01024b9:	2b 05 8c 7f 1d f0    	sub    0xf01d7f8c,%eax
f01024bf:	c1 f8 03             	sar    $0x3,%eax
f01024c2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024c5:	89 c2                	mov    %eax,%edx
f01024c7:	c1 ea 0c             	shr    $0xc,%edx
f01024ca:	3b 15 84 7f 1d f0    	cmp    0xf01d7f84,%edx
f01024d0:	72 12                	jb     f01024e4 <mem_init+0xebb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024d2:	50                   	push   %eax
f01024d3:	68 14 56 10 f0       	push   $0xf0105614
f01024d8:	6a 56                	push   $0x56
f01024da:	68 81 5d 10 f0       	push   $0xf0105d81
f01024df:	e8 e5 db ff ff       	call   f01000c9 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01024e4:	83 ec 04             	sub    $0x4,%esp
f01024e7:	68 00 10 00 00       	push   $0x1000
f01024ec:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01024f1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024f6:	50                   	push   %eax
f01024f7:	e8 a5 22 00 00       	call   f01047a1 <memset>
	page_free(pp0);
f01024fc:	89 3c 24             	mov    %edi,(%esp)
f01024ff:	e8 d8 ee ff ff       	call   f01013dc <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102504:	83 c4 0c             	add    $0xc,%esp
f0102507:	6a 01                	push   $0x1
f0102509:	6a 00                	push   $0x0
f010250b:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0102511:	e8 04 ef ff ff       	call   f010141a <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102516:	89 fa                	mov    %edi,%edx
f0102518:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f010251e:	c1 fa 03             	sar    $0x3,%edx
f0102521:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102524:	89 d0                	mov    %edx,%eax
f0102526:	c1 e8 0c             	shr    $0xc,%eax
f0102529:	83 c4 10             	add    $0x10,%esp
f010252c:	3b 05 84 7f 1d f0    	cmp    0xf01d7f84,%eax
f0102532:	72 12                	jb     f0102546 <mem_init+0xf1d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102534:	52                   	push   %edx
f0102535:	68 14 56 10 f0       	push   $0xf0105614
f010253a:	6a 56                	push   $0x56
f010253c:	68 81 5d 10 f0       	push   $0xf0105d81
f0102541:	e8 83 db ff ff       	call   f01000c9 <_panic>
	return (void *)(pa + KERNBASE);
f0102546:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010254c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010254f:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102556:	75 11                	jne    f0102569 <mem_init+0xf40>
f0102558:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010255e:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102564:	f6 00 01             	testb  $0x1,(%eax)
f0102567:	74 19                	je     f0102582 <mem_init+0xf59>
f0102569:	68 bf 5f 10 f0       	push   $0xf0105fbf
f010256e:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102573:	68 90 03 00 00       	push   $0x390
f0102578:	68 75 5d 10 f0       	push   $0xf0105d75
f010257d:	e8 47 db ff ff       	call   f01000c9 <_panic>
f0102582:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102585:	39 d0                	cmp    %edx,%eax
f0102587:	75 db                	jne    f0102564 <mem_init+0xf3b>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102589:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f010258e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102594:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f010259a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010259d:	89 0d ac 72 1d f0    	mov    %ecx,0xf01d72ac

	// free the pages we took
	page_free(pp0);
f01025a3:	83 ec 0c             	sub    $0xc,%esp
f01025a6:	57                   	push   %edi
f01025a7:	e8 30 ee ff ff       	call   f01013dc <page_free>
	page_free(pp1);
f01025ac:	89 34 24             	mov    %esi,(%esp)
f01025af:	e8 28 ee ff ff       	call   f01013dc <page_free>
	page_free(pp2);
f01025b4:	89 1c 24             	mov    %ebx,(%esp)
f01025b7:	e8 20 ee ff ff       	call   f01013dc <page_free>

	cprintf("check_page() succeeded!\n");
f01025bc:	c7 04 24 d6 5f 10 f0 	movl   $0xf0105fd6,(%esp)
f01025c3:	e8 31 0e 00 00       	call   f01033f9 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f01025c8:	a1 8c 7f 1d f0       	mov    0xf01d7f8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025cd:	83 c4 10             	add    $0x10,%esp
f01025d0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025d5:	77 15                	ja     f01025ec <mem_init+0xfc3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025d7:	50                   	push   %eax
f01025d8:	68 54 54 10 f0       	push   $0xf0105454
f01025dd:	68 b7 00 00 00       	push   $0xb7
f01025e2:	68 75 5d 10 f0       	push   $0xf0105d75
f01025e7:	e8 dd da ff ff       	call   f01000c9 <_panic>
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f01025ec:	8b 15 84 7f 1d f0    	mov    0xf01d7f84,%edx
f01025f2:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f01025f9:	83 ec 08             	sub    $0x8,%esp
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f01025fc:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102602:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102604:	05 00 00 00 10       	add    $0x10000000,%eax
f0102609:	50                   	push   %eax
f010260a:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010260f:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f0102614:	e8 98 ee ff ff       	call   f01014b1 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
    boot_map_region(kern_pgdir,
f0102619:	a1 b8 72 1d f0       	mov    0xf01d72b8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010261e:	83 c4 10             	add    $0x10,%esp
f0102621:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102626:	77 15                	ja     f010263d <mem_init+0x1014>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102628:	50                   	push   %eax
f0102629:	68 54 54 10 f0       	push   $0xf0105454
f010262e:	68 c4 00 00 00       	push   $0xc4
f0102633:	68 75 5d 10 f0       	push   $0xf0105d75
f0102638:	e8 8c da ff ff       	call   f01000c9 <_panic>
f010263d:	83 ec 08             	sub    $0x8,%esp
f0102640:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102642:	05 00 00 00 10       	add    $0x10000000,%eax
f0102647:	50                   	push   %eax
f0102648:	b9 00 80 01 00       	mov    $0x18000,%ecx
f010264d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102652:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f0102657:	e8 55 ee ff ff       	call   f01014b1 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010265c:	83 c4 10             	add    $0x10,%esp
f010265f:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f0102664:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102669:	77 15                	ja     f0102680 <mem_init+0x1057>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010266b:	50                   	push   %eax
f010266c:	68 54 54 10 f0       	push   $0xf0105454
f0102671:	68 d5 00 00 00       	push   $0xd5
f0102676:	68 75 5d 10 f0       	push   $0xf0105d75
f010267b:	e8 49 da ff ff       	call   f01000c9 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f0102680:	83 ec 08             	sub    $0x8,%esp
f0102683:	6a 02                	push   $0x2
f0102685:	68 00 80 11 00       	push   $0x118000
f010268a:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010268f:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102694:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f0102699:	e8 13 ee ff ff       	call   f01014b1 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f010269e:	83 c4 08             	add    $0x8,%esp
f01026a1:	6a 02                	push   $0x2
f01026a3:	6a 00                	push   $0x0
f01026a5:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01026aa:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01026af:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f01026b4:	e8 f8 ed ff ff       	call   f01014b1 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01026b9:	8b 1d 88 7f 1d f0    	mov    0xf01d7f88,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01026bf:	a1 84 7f 1d f0       	mov    0xf01d7f84,%eax
f01026c4:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f01026cb:	83 c4 10             	add    $0x10,%esp
f01026ce:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01026d4:	74 63                	je     f0102739 <mem_init+0x1110>
f01026d6:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01026db:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f01026e1:	89 d8                	mov    %ebx,%eax
f01026e3:	e8 7b e8 ff ff       	call   f0100f63 <check_va2pa>
f01026e8:	8b 15 8c 7f 1d f0    	mov    0xf01d7f8c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026ee:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01026f4:	77 15                	ja     f010270b <mem_init+0x10e2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026f6:	52                   	push   %edx
f01026f7:	68 54 54 10 f0       	push   $0xf0105454
f01026fc:	68 d8 02 00 00       	push   $0x2d8
f0102701:	68 75 5d 10 f0       	push   $0xf0105d75
f0102706:	e8 be d9 ff ff       	call   f01000c9 <_panic>
f010270b:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102712:	39 d0                	cmp    %edx,%eax
f0102714:	74 19                	je     f010272f <mem_init+0x1106>
f0102716:	68 78 5b 10 f0       	push   $0xf0105b78
f010271b:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102720:	68 d8 02 00 00       	push   $0x2d8
f0102725:	68 75 5d 10 f0       	push   $0xf0105d75
f010272a:	e8 9a d9 ff ff       	call   f01000c9 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010272f:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102735:	39 f7                	cmp    %esi,%edi
f0102737:	77 a2                	ja     f01026db <mem_init+0x10b2>
f0102739:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010273e:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
f0102744:	89 d8                	mov    %ebx,%eax
f0102746:	e8 18 e8 ff ff       	call   f0100f63 <check_va2pa>
f010274b:	8b 15 b8 72 1d f0    	mov    0xf01d72b8,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102751:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102757:	77 15                	ja     f010276e <mem_init+0x1145>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102759:	52                   	push   %edx
f010275a:	68 54 54 10 f0       	push   $0xf0105454
f010275f:	68 dd 02 00 00       	push   $0x2dd
f0102764:	68 75 5d 10 f0       	push   $0xf0105d75
f0102769:	e8 5b d9 ff ff       	call   f01000c9 <_panic>
f010276e:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102775:	39 d0                	cmp    %edx,%eax
f0102777:	74 19                	je     f0102792 <mem_init+0x1169>
f0102779:	68 ac 5b 10 f0       	push   $0xf0105bac
f010277e:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102783:	68 dd 02 00 00       	push   $0x2dd
f0102788:	68 75 5d 10 f0       	push   $0xf0105d75
f010278d:	e8 37 d9 ff ff       	call   f01000c9 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102792:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102798:	81 fe 00 80 01 00    	cmp    $0x18000,%esi
f010279e:	75 9e                	jne    f010273e <mem_init+0x1115>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01027a0:	a1 84 7f 1d f0       	mov    0xf01d7f84,%eax
f01027a5:	c1 e0 0c             	shl    $0xc,%eax
f01027a8:	74 41                	je     f01027eb <mem_init+0x11c2>
f01027aa:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01027af:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f01027b5:	89 d8                	mov    %ebx,%eax
f01027b7:	e8 a7 e7 ff ff       	call   f0100f63 <check_va2pa>
f01027bc:	39 c6                	cmp    %eax,%esi
f01027be:	74 19                	je     f01027d9 <mem_init+0x11b0>
f01027c0:	68 e0 5b 10 f0       	push   $0xf0105be0
f01027c5:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01027ca:	68 e1 02 00 00       	push   $0x2e1
f01027cf:	68 75 5d 10 f0       	push   $0xf0105d75
f01027d4:	e8 f0 d8 ff ff       	call   f01000c9 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01027d9:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01027df:	a1 84 7f 1d f0       	mov    0xf01d7f84,%eax
f01027e4:	c1 e0 0c             	shl    $0xc,%eax
f01027e7:	39 c6                	cmp    %eax,%esi
f01027e9:	72 c4                	jb     f01027af <mem_init+0x1186>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01027eb:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01027f0:	89 d8                	mov    %ebx,%eax
f01027f2:	e8 6c e7 ff ff       	call   f0100f63 <check_va2pa>
f01027f7:	be 00 90 ff ef       	mov    $0xefff9000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01027fc:	bf 00 80 11 f0       	mov    $0xf0118000,%edi
f0102801:	81 c7 00 70 00 20    	add    $0x20007000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102807:	8d 14 37             	lea    (%edi,%esi,1),%edx
f010280a:	39 c2                	cmp    %eax,%edx
f010280c:	74 19                	je     f0102827 <mem_init+0x11fe>
f010280e:	68 08 5c 10 f0       	push   $0xf0105c08
f0102813:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102818:	68 e5 02 00 00       	push   $0x2e5
f010281d:	68 75 5d 10 f0       	push   $0xf0105d75
f0102822:	e8 a2 d8 ff ff       	call   f01000c9 <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102827:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f010282d:	0f 85 25 04 00 00    	jne    f0102c58 <mem_init+0x162f>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102833:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102838:	89 d8                	mov    %ebx,%eax
f010283a:	e8 24 e7 ff ff       	call   f0100f63 <check_va2pa>
f010283f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102842:	74 19                	je     f010285d <mem_init+0x1234>
f0102844:	68 50 5c 10 f0       	push   $0xf0105c50
f0102849:	68 9b 5d 10 f0       	push   $0xf0105d9b
f010284e:	68 e6 02 00 00       	push   $0x2e6
f0102853:	68 75 5d 10 f0       	push   $0xf0105d75
f0102858:	e8 6c d8 ff ff       	call   f01000c9 <_panic>
f010285d:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102862:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102867:	72 2d                	jb     f0102896 <mem_init+0x126d>
f0102869:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f010286e:	76 07                	jbe    f0102877 <mem_init+0x124e>
f0102870:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102875:	75 1f                	jne    f0102896 <mem_init+0x126d>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102877:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f010287b:	75 7e                	jne    f01028fb <mem_init+0x12d2>
f010287d:	68 ef 5f 10 f0       	push   $0xf0105fef
f0102882:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102887:	68 ef 02 00 00       	push   $0x2ef
f010288c:	68 75 5d 10 f0       	push   $0xf0105d75
f0102891:	e8 33 d8 ff ff       	call   f01000c9 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102896:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010289b:	76 3f                	jbe    f01028dc <mem_init+0x12b3>
				assert(pgdir[i] & PTE_P);
f010289d:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01028a0:	f6 c2 01             	test   $0x1,%dl
f01028a3:	75 19                	jne    f01028be <mem_init+0x1295>
f01028a5:	68 ef 5f 10 f0       	push   $0xf0105fef
f01028aa:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01028af:	68 f3 02 00 00       	push   $0x2f3
f01028b4:	68 75 5d 10 f0       	push   $0xf0105d75
f01028b9:	e8 0b d8 ff ff       	call   f01000c9 <_panic>
				assert(pgdir[i] & PTE_W);
f01028be:	f6 c2 02             	test   $0x2,%dl
f01028c1:	75 38                	jne    f01028fb <mem_init+0x12d2>
f01028c3:	68 00 60 10 f0       	push   $0xf0106000
f01028c8:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01028cd:	68 f4 02 00 00       	push   $0x2f4
f01028d2:	68 75 5d 10 f0       	push   $0xf0105d75
f01028d7:	e8 ed d7 ff ff       	call   f01000c9 <_panic>
			} else
				assert(pgdir[i] == 0);
f01028dc:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01028e0:	74 19                	je     f01028fb <mem_init+0x12d2>
f01028e2:	68 11 60 10 f0       	push   $0xf0106011
f01028e7:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01028ec:	68 f6 02 00 00       	push   $0x2f6
f01028f1:	68 75 5d 10 f0       	push   $0xf0105d75
f01028f6:	e8 ce d7 ff ff       	call   f01000c9 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01028fb:	40                   	inc    %eax
f01028fc:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102901:	0f 85 5b ff ff ff    	jne    f0102862 <mem_init+0x1239>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102907:	83 ec 0c             	sub    $0xc,%esp
f010290a:	68 80 5c 10 f0       	push   $0xf0105c80
f010290f:	e8 e5 0a 00 00       	call   f01033f9 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102914:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102919:	83 c4 10             	add    $0x10,%esp
f010291c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102921:	77 15                	ja     f0102938 <mem_init+0x130f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102923:	50                   	push   %eax
f0102924:	68 54 54 10 f0       	push   $0xf0105454
f0102929:	68 f2 00 00 00       	push   $0xf2
f010292e:	68 75 5d 10 f0       	push   $0xf0105d75
f0102933:	e8 91 d7 ff ff       	call   f01000c9 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102938:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010293d:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102940:	b8 00 00 00 00       	mov    $0x0,%eax
f0102945:	e8 a2 e6 ff ff       	call   f0100fec <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f010294a:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f010294d:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102952:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102955:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102958:	83 ec 0c             	sub    $0xc,%esp
f010295b:	6a 00                	push   $0x0
f010295d:	e8 f0 e9 ff ff       	call   f0101352 <page_alloc>
f0102962:	89 c6                	mov    %eax,%esi
f0102964:	83 c4 10             	add    $0x10,%esp
f0102967:	85 c0                	test   %eax,%eax
f0102969:	75 19                	jne    f0102984 <mem_init+0x135b>
f010296b:	68 46 5e 10 f0       	push   $0xf0105e46
f0102970:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102975:	68 ab 03 00 00       	push   $0x3ab
f010297a:	68 75 5d 10 f0       	push   $0xf0105d75
f010297f:	e8 45 d7 ff ff       	call   f01000c9 <_panic>
	assert((pp1 = page_alloc(0)));
f0102984:	83 ec 0c             	sub    $0xc,%esp
f0102987:	6a 00                	push   $0x0
f0102989:	e8 c4 e9 ff ff       	call   f0101352 <page_alloc>
f010298e:	89 c7                	mov    %eax,%edi
f0102990:	83 c4 10             	add    $0x10,%esp
f0102993:	85 c0                	test   %eax,%eax
f0102995:	75 19                	jne    f01029b0 <mem_init+0x1387>
f0102997:	68 5c 5e 10 f0       	push   $0xf0105e5c
f010299c:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01029a1:	68 ac 03 00 00       	push   $0x3ac
f01029a6:	68 75 5d 10 f0       	push   $0xf0105d75
f01029ab:	e8 19 d7 ff ff       	call   f01000c9 <_panic>
	assert((pp2 = page_alloc(0)));
f01029b0:	83 ec 0c             	sub    $0xc,%esp
f01029b3:	6a 00                	push   $0x0
f01029b5:	e8 98 e9 ff ff       	call   f0101352 <page_alloc>
f01029ba:	89 c3                	mov    %eax,%ebx
f01029bc:	83 c4 10             	add    $0x10,%esp
f01029bf:	85 c0                	test   %eax,%eax
f01029c1:	75 19                	jne    f01029dc <mem_init+0x13b3>
f01029c3:	68 72 5e 10 f0       	push   $0xf0105e72
f01029c8:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01029cd:	68 ad 03 00 00       	push   $0x3ad
f01029d2:	68 75 5d 10 f0       	push   $0xf0105d75
f01029d7:	e8 ed d6 ff ff       	call   f01000c9 <_panic>
	page_free(pp0);
f01029dc:	83 ec 0c             	sub    $0xc,%esp
f01029df:	56                   	push   %esi
f01029e0:	e8 f7 e9 ff ff       	call   f01013dc <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01029e5:	89 f8                	mov    %edi,%eax
f01029e7:	2b 05 8c 7f 1d f0    	sub    0xf01d7f8c,%eax
f01029ed:	c1 f8 03             	sar    $0x3,%eax
f01029f0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01029f3:	89 c2                	mov    %eax,%edx
f01029f5:	c1 ea 0c             	shr    $0xc,%edx
f01029f8:	83 c4 10             	add    $0x10,%esp
f01029fb:	3b 15 84 7f 1d f0    	cmp    0xf01d7f84,%edx
f0102a01:	72 12                	jb     f0102a15 <mem_init+0x13ec>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a03:	50                   	push   %eax
f0102a04:	68 14 56 10 f0       	push   $0xf0105614
f0102a09:	6a 56                	push   $0x56
f0102a0b:	68 81 5d 10 f0       	push   $0xf0105d81
f0102a10:	e8 b4 d6 ff ff       	call   f01000c9 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102a15:	83 ec 04             	sub    $0x4,%esp
f0102a18:	68 00 10 00 00       	push   $0x1000
f0102a1d:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102a1f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a24:	50                   	push   %eax
f0102a25:	e8 77 1d 00 00       	call   f01047a1 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a2a:	89 d8                	mov    %ebx,%eax
f0102a2c:	2b 05 8c 7f 1d f0    	sub    0xf01d7f8c,%eax
f0102a32:	c1 f8 03             	sar    $0x3,%eax
f0102a35:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a38:	89 c2                	mov    %eax,%edx
f0102a3a:	c1 ea 0c             	shr    $0xc,%edx
f0102a3d:	83 c4 10             	add    $0x10,%esp
f0102a40:	3b 15 84 7f 1d f0    	cmp    0xf01d7f84,%edx
f0102a46:	72 12                	jb     f0102a5a <mem_init+0x1431>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a48:	50                   	push   %eax
f0102a49:	68 14 56 10 f0       	push   $0xf0105614
f0102a4e:	6a 56                	push   $0x56
f0102a50:	68 81 5d 10 f0       	push   $0xf0105d81
f0102a55:	e8 6f d6 ff ff       	call   f01000c9 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102a5a:	83 ec 04             	sub    $0x4,%esp
f0102a5d:	68 00 10 00 00       	push   $0x1000
f0102a62:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102a64:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a69:	50                   	push   %eax
f0102a6a:	e8 32 1d 00 00       	call   f01047a1 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102a6f:	6a 02                	push   $0x2
f0102a71:	68 00 10 00 00       	push   $0x1000
f0102a76:	57                   	push   %edi
f0102a77:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0102a7d:	e8 3e eb ff ff       	call   f01015c0 <page_insert>
	assert(pp1->pp_ref == 1);
f0102a82:	83 c4 20             	add    $0x20,%esp
f0102a85:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102a8a:	74 19                	je     f0102aa5 <mem_init+0x147c>
f0102a8c:	68 43 5f 10 f0       	push   $0xf0105f43
f0102a91:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102a96:	68 b2 03 00 00       	push   $0x3b2
f0102a9b:	68 75 5d 10 f0       	push   $0xf0105d75
f0102aa0:	e8 24 d6 ff ff       	call   f01000c9 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102aa5:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102aac:	01 01 01 
f0102aaf:	74 19                	je     f0102aca <mem_init+0x14a1>
f0102ab1:	68 a0 5c 10 f0       	push   $0xf0105ca0
f0102ab6:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102abb:	68 b3 03 00 00       	push   $0x3b3
f0102ac0:	68 75 5d 10 f0       	push   $0xf0105d75
f0102ac5:	e8 ff d5 ff ff       	call   f01000c9 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102aca:	6a 02                	push   $0x2
f0102acc:	68 00 10 00 00       	push   $0x1000
f0102ad1:	53                   	push   %ebx
f0102ad2:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0102ad8:	e8 e3 ea ff ff       	call   f01015c0 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102add:	83 c4 10             	add    $0x10,%esp
f0102ae0:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102ae7:	02 02 02 
f0102aea:	74 19                	je     f0102b05 <mem_init+0x14dc>
f0102aec:	68 c4 5c 10 f0       	push   $0xf0105cc4
f0102af1:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102af6:	68 b5 03 00 00       	push   $0x3b5
f0102afb:	68 75 5d 10 f0       	push   $0xf0105d75
f0102b00:	e8 c4 d5 ff ff       	call   f01000c9 <_panic>
	assert(pp2->pp_ref == 1);
f0102b05:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102b0a:	74 19                	je     f0102b25 <mem_init+0x14fc>
f0102b0c:	68 65 5f 10 f0       	push   $0xf0105f65
f0102b11:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102b16:	68 b6 03 00 00       	push   $0x3b6
f0102b1b:	68 75 5d 10 f0       	push   $0xf0105d75
f0102b20:	e8 a4 d5 ff ff       	call   f01000c9 <_panic>
	assert(pp1->pp_ref == 0);
f0102b25:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102b2a:	74 19                	je     f0102b45 <mem_init+0x151c>
f0102b2c:	68 ae 5f 10 f0       	push   $0xf0105fae
f0102b31:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102b36:	68 b7 03 00 00       	push   $0x3b7
f0102b3b:	68 75 5d 10 f0       	push   $0xf0105d75
f0102b40:	e8 84 d5 ff ff       	call   f01000c9 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102b45:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102b4c:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b4f:	89 d8                	mov    %ebx,%eax
f0102b51:	2b 05 8c 7f 1d f0    	sub    0xf01d7f8c,%eax
f0102b57:	c1 f8 03             	sar    $0x3,%eax
f0102b5a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b5d:	89 c2                	mov    %eax,%edx
f0102b5f:	c1 ea 0c             	shr    $0xc,%edx
f0102b62:	3b 15 84 7f 1d f0    	cmp    0xf01d7f84,%edx
f0102b68:	72 12                	jb     f0102b7c <mem_init+0x1553>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b6a:	50                   	push   %eax
f0102b6b:	68 14 56 10 f0       	push   $0xf0105614
f0102b70:	6a 56                	push   $0x56
f0102b72:	68 81 5d 10 f0       	push   $0xf0105d81
f0102b77:	e8 4d d5 ff ff       	call   f01000c9 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102b7c:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102b83:	03 03 03 
f0102b86:	74 19                	je     f0102ba1 <mem_init+0x1578>
f0102b88:	68 e8 5c 10 f0       	push   $0xf0105ce8
f0102b8d:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102b92:	68 b9 03 00 00       	push   $0x3b9
f0102b97:	68 75 5d 10 f0       	push   $0xf0105d75
f0102b9c:	e8 28 d5 ff ff       	call   f01000c9 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102ba1:	83 ec 08             	sub    $0x8,%esp
f0102ba4:	68 00 10 00 00       	push   $0x1000
f0102ba9:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0102baf:	e8 bf e9 ff ff       	call   f0101573 <page_remove>
	assert(pp2->pp_ref == 0);
f0102bb4:	83 c4 10             	add    $0x10,%esp
f0102bb7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102bbc:	74 19                	je     f0102bd7 <mem_init+0x15ae>
f0102bbe:	68 9d 5f 10 f0       	push   $0xf0105f9d
f0102bc3:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102bc8:	68 bb 03 00 00       	push   $0x3bb
f0102bcd:	68 75 5d 10 f0       	push   $0xf0105d75
f0102bd2:	e8 f2 d4 ff ff       	call   f01000c9 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102bd7:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f0102bdc:	8b 08                	mov    (%eax),%ecx
f0102bde:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102be4:	89 f2                	mov    %esi,%edx
f0102be6:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f0102bec:	c1 fa 03             	sar    $0x3,%edx
f0102bef:	c1 e2 0c             	shl    $0xc,%edx
f0102bf2:	39 d1                	cmp    %edx,%ecx
f0102bf4:	74 19                	je     f0102c0f <mem_init+0x15e6>
f0102bf6:	68 30 58 10 f0       	push   $0xf0105830
f0102bfb:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102c00:	68 be 03 00 00       	push   $0x3be
f0102c05:	68 75 5d 10 f0       	push   $0xf0105d75
f0102c0a:	e8 ba d4 ff ff       	call   f01000c9 <_panic>
	kern_pgdir[0] = 0;
f0102c0f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102c15:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c1a:	74 19                	je     f0102c35 <mem_init+0x160c>
f0102c1c:	68 54 5f 10 f0       	push   $0xf0105f54
f0102c21:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0102c26:	68 c0 03 00 00       	push   $0x3c0
f0102c2b:	68 75 5d 10 f0       	push   $0xf0105d75
f0102c30:	e8 94 d4 ff ff       	call   f01000c9 <_panic>
	pp0->pp_ref = 0;
f0102c35:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102c3b:	83 ec 0c             	sub    $0xc,%esp
f0102c3e:	56                   	push   %esi
f0102c3f:	e8 98 e7 ff ff       	call   f01013dc <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102c44:	c7 04 24 14 5d 10 f0 	movl   $0xf0105d14,(%esp)
f0102c4b:	e8 a9 07 00 00       	call   f01033f9 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102c50:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102c53:	5b                   	pop    %ebx
f0102c54:	5e                   	pop    %esi
f0102c55:	5f                   	pop    %edi
f0102c56:	c9                   	leave  
f0102c57:	c3                   	ret    
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102c58:	89 f2                	mov    %esi,%edx
f0102c5a:	89 d8                	mov    %ebx,%eax
f0102c5c:	e8 02 e3 ff ff       	call   f0100f63 <check_va2pa>
f0102c61:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102c67:	e9 9b fb ff ff       	jmp    f0102807 <mem_init+0x11de>

f0102c6c <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102c6c:	55                   	push   %ebp
f0102c6d:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.

	return 0;
}
f0102c6f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c74:	c9                   	leave  
f0102c75:	c3                   	ret    

f0102c76 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102c76:	55                   	push   %ebp
f0102c77:	89 e5                	mov    %esp,%ebp
f0102c79:	53                   	push   %ebx
f0102c7a:	83 ec 04             	sub    $0x4,%esp
f0102c7d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102c80:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c83:	83 c8 04             	or     $0x4,%eax
f0102c86:	50                   	push   %eax
f0102c87:	ff 75 10             	pushl  0x10(%ebp)
f0102c8a:	ff 75 0c             	pushl  0xc(%ebp)
f0102c8d:	53                   	push   %ebx
f0102c8e:	e8 d9 ff ff ff       	call   f0102c6c <user_mem_check>
f0102c93:	83 c4 10             	add    $0x10,%esp
f0102c96:	85 c0                	test   %eax,%eax
f0102c98:	79 1d                	jns    f0102cb7 <user_mem_assert+0x41>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102c9a:	83 ec 04             	sub    $0x4,%esp
f0102c9d:	6a 00                	push   $0x0
f0102c9f:	ff 73 48             	pushl  0x48(%ebx)
f0102ca2:	68 40 5d 10 f0       	push   $0xf0105d40
f0102ca7:	e8 4d 07 00 00       	call   f01033f9 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102cac:	89 1c 24             	mov    %ebx,(%esp)
f0102caf:	e8 32 06 00 00       	call   f01032e6 <env_destroy>
f0102cb4:	83 c4 10             	add    $0x10,%esp
	}
}
f0102cb7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102cba:	c9                   	leave  
f0102cbb:	c3                   	ret    

f0102cbc <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102cbc:	55                   	push   %ebp
f0102cbd:	89 e5                	mov    %esp,%ebp
f0102cbf:	57                   	push   %edi
f0102cc0:	56                   	push   %esi
f0102cc1:	53                   	push   %ebx
f0102cc2:	83 ec 0c             	sub    $0xc,%esp
f0102cc5:	89 c6                	mov    %eax,%esi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
    uint32_t addr = (uint32_t)ROUNDDOWN(va, PGSIZE);
f0102cc7:	89 d3                	mov    %edx,%ebx
f0102cc9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    uint32_t end  = (uint32_t)ROUNDUP(va + len, PGSIZE);
f0102ccf:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f0102cd6:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    struct PageInfo *pg;
    // cprintf("region_alloc: %u %u\n", addr, end);
    for ( ; addr != end; addr += PGSIZE) {
f0102cdc:	39 fb                	cmp    %edi,%ebx
f0102cde:	74 5c                	je     f0102d3c <region_alloc+0x80>
        pg = page_alloc(1);
f0102ce0:	83 ec 0c             	sub    $0xc,%esp
f0102ce3:	6a 01                	push   $0x1
f0102ce5:	e8 68 e6 ff ff       	call   f0101352 <page_alloc>
        if (pg == NULL) {
f0102cea:	83 c4 10             	add    $0x10,%esp
f0102ced:	85 c0                	test   %eax,%eax
f0102cef:	75 17                	jne    f0102d08 <region_alloc+0x4c>
            panic("region_alloc : can't alloc page\n");
f0102cf1:	83 ec 04             	sub    $0x4,%esp
f0102cf4:	68 20 60 10 f0       	push   $0xf0106020
f0102cf9:	68 29 01 00 00       	push   $0x129
f0102cfe:	68 9e 60 10 f0       	push   $0xf010609e
f0102d03:	e8 c1 d3 ff ff       	call   f01000c9 <_panic>
        } else {
            if (page_insert(e->env_pgdir, pg, (void *)addr, PTE_U | PTE_W) != 0) {
f0102d08:	6a 06                	push   $0x6
f0102d0a:	53                   	push   %ebx
f0102d0b:	50                   	push   %eax
f0102d0c:	ff 76 5c             	pushl  0x5c(%esi)
f0102d0f:	e8 ac e8 ff ff       	call   f01015c0 <page_insert>
f0102d14:	83 c4 10             	add    $0x10,%esp
f0102d17:	85 c0                	test   %eax,%eax
f0102d19:	74 17                	je     f0102d32 <region_alloc+0x76>
                panic("region_alloc : page_insert fail\n");
f0102d1b:	83 ec 04             	sub    $0x4,%esp
f0102d1e:	68 44 60 10 f0       	push   $0xf0106044
f0102d23:	68 2c 01 00 00       	push   $0x12c
f0102d28:	68 9e 60 10 f0       	push   $0xf010609e
f0102d2d:	e8 97 d3 ff ff       	call   f01000c9 <_panic>
	//   (Watch out for corner-cases!)
    uint32_t addr = (uint32_t)ROUNDDOWN(va, PGSIZE);
    uint32_t end  = (uint32_t)ROUNDUP(va + len, PGSIZE);
    struct PageInfo *pg;
    // cprintf("region_alloc: %u %u\n", addr, end);
    for ( ; addr != end; addr += PGSIZE) {
f0102d32:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102d38:	39 df                	cmp    %ebx,%edi
f0102d3a:	75 a4                	jne    f0102ce0 <region_alloc+0x24>
                panic("region_alloc : page_insert fail\n");
            }
        }
    }
    return;
}
f0102d3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d3f:	5b                   	pop    %ebx
f0102d40:	5e                   	pop    %esi
f0102d41:	5f                   	pop    %edi
f0102d42:	c9                   	leave  
f0102d43:	c3                   	ret    

f0102d44 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102d44:	55                   	push   %ebp
f0102d45:	89 e5                	mov    %esp,%ebp
f0102d47:	53                   	push   %ebx
f0102d48:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102d4e:	8a 5d 10             	mov    0x10(%ebp),%bl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102d51:	85 c0                	test   %eax,%eax
f0102d53:	75 0e                	jne    f0102d63 <envid2env+0x1f>
		*env_store = curenv;
f0102d55:	a1 bc 72 1d f0       	mov    0xf01d72bc,%eax
f0102d5a:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102d5c:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d61:	eb 55                	jmp    f0102db8 <envid2env+0x74>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102d63:	89 c2                	mov    %eax,%edx
f0102d65:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0102d6b:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102d6e:	c1 e2 05             	shl    $0x5,%edx
f0102d71:	03 15 b8 72 1d f0    	add    0xf01d72b8,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102d77:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0102d7b:	74 05                	je     f0102d82 <envid2env+0x3e>
f0102d7d:	39 42 48             	cmp    %eax,0x48(%edx)
f0102d80:	74 0d                	je     f0102d8f <envid2env+0x4b>
		*env_store = 0;
f0102d82:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102d88:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102d8d:	eb 29                	jmp    f0102db8 <envid2env+0x74>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102d8f:	84 db                	test   %bl,%bl
f0102d91:	74 1e                	je     f0102db1 <envid2env+0x6d>
f0102d93:	a1 bc 72 1d f0       	mov    0xf01d72bc,%eax
f0102d98:	39 c2                	cmp    %eax,%edx
f0102d9a:	74 15                	je     f0102db1 <envid2env+0x6d>
f0102d9c:	8b 58 48             	mov    0x48(%eax),%ebx
f0102d9f:	39 5a 4c             	cmp    %ebx,0x4c(%edx)
f0102da2:	74 0d                	je     f0102db1 <envid2env+0x6d>
		*env_store = 0;
f0102da4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102daa:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102daf:	eb 07                	jmp    f0102db8 <envid2env+0x74>
	}

	*env_store = e;
f0102db1:	89 11                	mov    %edx,(%ecx)
	return 0;
f0102db3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102db8:	5b                   	pop    %ebx
f0102db9:	c9                   	leave  
f0102dba:	c3                   	ret    

f0102dbb <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102dbb:	55                   	push   %ebp
f0102dbc:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102dbe:	b8 30 23 12 f0       	mov    $0xf0122330,%eax
f0102dc3:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102dc6:	b8 23 00 00 00       	mov    $0x23,%eax
f0102dcb:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102dcd:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102dcf:	b0 10                	mov    $0x10,%al
f0102dd1:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102dd3:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102dd5:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102dd7:	ea de 2d 10 f0 08 00 	ljmp   $0x8,$0xf0102dde
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102dde:	b0 00                	mov    $0x0,%al
f0102de0:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102de3:	c9                   	leave  
f0102de4:	c3                   	ret    

f0102de5 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102de5:	55                   	push   %ebp
f0102de6:	89 e5                	mov    %esp,%ebp
f0102de8:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
    uint32_t i;
    env_free_list = envs;
f0102de9:	8b 1d b8 72 1d f0    	mov    0xf01d72b8,%ebx
f0102def:	89 1d c0 72 1d f0    	mov    %ebx,0xf01d72c0
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
f0102df5:	c7 43 48 00 00 00 00 	movl   $0x0,0x48(%ebx)
        envs[i].env_status = ENV_FREE;
f0102dfc:	c7 43 54 00 00 00 00 	movl   $0x0,0x54(%ebx)
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0102e03:	8d 43 60             	lea    0x60(%ebx),%eax
f0102e06:	8d 8b 00 80 01 00    	lea    0x18000(%ebx),%ecx
f0102e0c:	89 c2                	mov    %eax,%edx
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
        envs[i].env_status = ENV_FREE;
        if (i + 1 != NENV)
            envs[i].env_link = envs + (i + 1);
f0102e0e:	89 43 44             	mov    %eax,0x44(%ebx)
{
	// Set up envs array
	// LAB 3: Your code here.
    uint32_t i;
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
f0102e11:	39 c8                	cmp    %ecx,%eax
f0102e13:	74 1c                	je     f0102e31 <env_init+0x4c>
        envs[i].env_id = 0;
f0102e15:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
        envs[i].env_status = ENV_FREE;
f0102e1c:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
f0102e23:	83 c0 60             	add    $0x60,%eax
        if (i + 1 != NENV)
f0102e26:	39 c8                	cmp    %ecx,%eax
f0102e28:	75 0f                	jne    f0102e39 <env_init+0x54>
            envs[i].env_link = envs + (i + 1);
        else 
            envs[i].env_link = NULL;
f0102e2a:	c7 42 44 00 00 00 00 	movl   $0x0,0x44(%edx)
    }

	// Per-CPU part of the initialization
	env_init_percpu();
f0102e31:	e8 85 ff ff ff       	call   f0102dbb <env_init_percpu>
}
f0102e36:	5b                   	pop    %ebx
f0102e37:	c9                   	leave  
f0102e38:	c3                   	ret    
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
        envs[i].env_status = ENV_FREE;
        if (i + 1 != NENV)
            envs[i].env_link = envs + (i + 1);
f0102e39:	89 42 44             	mov    %eax,0x44(%edx)
f0102e3c:	89 c2                	mov    %eax,%edx
f0102e3e:	eb d5                	jmp    f0102e15 <env_init+0x30>

f0102e40 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102e40:	55                   	push   %ebp
f0102e41:	89 e5                	mov    %esp,%ebp
f0102e43:	56                   	push   %esi
f0102e44:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102e45:	8b 35 c0 72 1d f0    	mov    0xf01d72c0,%esi
f0102e4b:	85 f6                	test   %esi,%esi
f0102e4d:	0f 84 8d 01 00 00    	je     f0102fe0 <env_alloc+0x1a0>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102e53:	83 ec 0c             	sub    $0xc,%esp
f0102e56:	6a 01                	push   $0x1
f0102e58:	e8 f5 e4 ff ff       	call   f0101352 <page_alloc>
f0102e5d:	89 c3                	mov    %eax,%ebx
f0102e5f:	83 c4 10             	add    $0x10,%esp
f0102e62:	85 c0                	test   %eax,%eax
f0102e64:	0f 84 7d 01 00 00    	je     f0102fe7 <env_alloc+0x1a7>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
    cprintf("env_setup_vm in\n");
f0102e6a:	83 ec 0c             	sub    $0xc,%esp
f0102e6d:	68 a9 60 10 f0       	push   $0xf01060a9
f0102e72:	e8 82 05 00 00       	call   f01033f9 <cprintf>

    p->pp_ref++;
f0102e77:	66 ff 43 04          	incw   0x4(%ebx)
f0102e7b:	2b 1d 8c 7f 1d f0    	sub    0xf01d7f8c,%ebx
f0102e81:	c1 fb 03             	sar    $0x3,%ebx
f0102e84:	c1 e3 0c             	shl    $0xc,%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e87:	89 d8                	mov    %ebx,%eax
f0102e89:	c1 e8 0c             	shr    $0xc,%eax
f0102e8c:	83 c4 10             	add    $0x10,%esp
f0102e8f:	3b 05 84 7f 1d f0    	cmp    0xf01d7f84,%eax
f0102e95:	72 12                	jb     f0102ea9 <env_alloc+0x69>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e97:	53                   	push   %ebx
f0102e98:	68 14 56 10 f0       	push   $0xf0105614
f0102e9d:	6a 56                	push   $0x56
f0102e9f:	68 81 5d 10 f0       	push   $0xf0105d81
f0102ea4:	e8 20 d2 ff ff       	call   f01000c9 <_panic>
	return (void *)(pa + KERNBASE);
f0102ea9:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
    e->env_pgdir = (pde_t *)page2kva(p);
f0102eaf:	89 5e 5c             	mov    %ebx,0x5c(%esi)
    // pay attention: have we set mapped in kern_pgdir ?
    // page_insert(kern_pgdir, p, (void *)e->env_pgdir, PTE_U | PTE_W); 

    memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0102eb2:	83 ec 04             	sub    $0x4,%esp
f0102eb5:	68 00 10 00 00       	push   $0x1000
f0102eba:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0102ec0:	53                   	push   %ebx
f0102ec1:	e8 8f 19 00 00       	call   f0104855 <memcpy>
    memset(e->env_pgdir, 0, PDX(UTOP) * sizeof(pde_t));
f0102ec6:	83 c4 0c             	add    $0xc,%esp
f0102ec9:	68 ec 0e 00 00       	push   $0xeec
f0102ece:	6a 00                	push   $0x0
f0102ed0:	ff 76 5c             	pushl  0x5c(%esi)
f0102ed3:	e8 c9 18 00 00       	call   f01047a1 <memset>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102ed8:	8b 46 5c             	mov    0x5c(%esi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102edb:	83 c4 10             	add    $0x10,%esp
f0102ede:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ee3:	77 15                	ja     f0102efa <env_alloc+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ee5:	50                   	push   %eax
f0102ee6:	68 54 54 10 f0       	push   $0xf0105454
f0102eeb:	68 cc 00 00 00       	push   $0xcc
f0102ef0:	68 9e 60 10 f0       	push   $0xf010609e
f0102ef5:	e8 cf d1 ff ff       	call   f01000c9 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102efa:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102f00:	83 ca 05             	or     $0x5,%edx
f0102f03:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)

    cprintf("env_setup_vm out\n");
f0102f09:	83 ec 0c             	sub    $0xc,%esp
f0102f0c:	68 ba 60 10 f0       	push   $0xf01060ba
f0102f11:	e8 e3 04 00 00       	call   f01033f9 <cprintf>
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;
    
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102f16:	8b 46 48             	mov    0x48(%esi),%eax
f0102f19:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102f1e:	83 c4 10             	add    $0x10,%esp
f0102f21:	89 c1                	mov    %eax,%ecx
f0102f23:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f0102f29:	7f 05                	jg     f0102f30 <env_alloc+0xf0>
		generation = 1 << ENVGENSHIFT;
f0102f2b:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f0102f30:	89 f0                	mov    %esi,%eax
f0102f32:	2b 05 b8 72 1d f0    	sub    0xf01d72b8,%eax
f0102f38:	c1 f8 05             	sar    $0x5,%eax
f0102f3b:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0102f3e:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0102f41:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0102f44:	89 d3                	mov    %edx,%ebx
f0102f46:	c1 e3 08             	shl    $0x8,%ebx
f0102f49:	01 da                	add    %ebx,%edx
f0102f4b:	89 d3                	mov    %edx,%ebx
f0102f4d:	c1 e3 10             	shl    $0x10,%ebx
f0102f50:	01 da                	add    %ebx,%edx
f0102f52:	8d 04 50             	lea    (%eax,%edx,2),%eax
f0102f55:	09 c1                	or     %eax,%ecx
f0102f57:	89 4e 48             	mov    %ecx,0x48(%esi)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102f5a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f5d:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f0102f60:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f0102f67:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f0102f6e:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102f75:	83 ec 04             	sub    $0x4,%esp
f0102f78:	6a 44                	push   $0x44
f0102f7a:	6a 00                	push   $0x0
f0102f7c:	56                   	push   %esi
f0102f7d:	e8 1f 18 00 00       	call   f01047a1 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102f82:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f0102f88:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f0102f8e:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f0102f94:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f0102f9b:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102fa1:	8b 46 44             	mov    0x44(%esi),%eax
f0102fa4:	a3 c0 72 1d f0       	mov    %eax,0xf01d72c0
	*newenv_store = e;
f0102fa9:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fac:	89 30                	mov    %esi,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102fae:	8b 56 48             	mov    0x48(%esi),%edx
f0102fb1:	a1 bc 72 1d f0       	mov    0xf01d72bc,%eax
f0102fb6:	83 c4 10             	add    $0x10,%esp
f0102fb9:	85 c0                	test   %eax,%eax
f0102fbb:	74 05                	je     f0102fc2 <env_alloc+0x182>
f0102fbd:	8b 40 48             	mov    0x48(%eax),%eax
f0102fc0:	eb 05                	jmp    f0102fc7 <env_alloc+0x187>
f0102fc2:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fc7:	83 ec 04             	sub    $0x4,%esp
f0102fca:	52                   	push   %edx
f0102fcb:	50                   	push   %eax
f0102fcc:	68 cc 60 10 f0       	push   $0xf01060cc
f0102fd1:	e8 23 04 00 00       	call   f01033f9 <cprintf>
	return 0;
f0102fd6:	83 c4 10             	add    $0x10,%esp
f0102fd9:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fde:	eb 0c                	jmp    f0102fec <env_alloc+0x1ac>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102fe0:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102fe5:	eb 05                	jmp    f0102fec <env_alloc+0x1ac>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102fe7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102fec:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0102fef:	5b                   	pop    %ebx
f0102ff0:	5e                   	pop    %esi
f0102ff1:	c9                   	leave  
f0102ff2:	c3                   	ret    

f0102ff3 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0102ff3:	55                   	push   %ebp
f0102ff4:	89 e5                	mov    %esp,%ebp
f0102ff6:	57                   	push   %edi
f0102ff7:	56                   	push   %esi
f0102ff8:	53                   	push   %ebx
f0102ff9:	83 ec 34             	sub    $0x34,%esp
f0102ffc:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("env_create %u %u %u\n", binary, size, type);
	// LAB 3: Your code here.
    struct Env * e;
    int r = env_alloc(&e, 0);
f0102fff:	6a 00                	push   $0x0
f0103001:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103004:	50                   	push   %eax
f0103005:	e8 36 fe ff ff       	call   f0102e40 <env_alloc>
    if (r < 0) {
f010300a:	83 c4 10             	add    $0x10,%esp
f010300d:	85 c0                	test   %eax,%eax
f010300f:	79 15                	jns    f0103026 <env_create+0x33>
        panic("env_create: %e\n", r);
f0103011:	50                   	push   %eax
f0103012:	68 e1 60 10 f0       	push   $0xf01060e1
f0103017:	68 96 01 00 00       	push   $0x196
f010301c:	68 9e 60 10 f0       	push   $0xf010609e
f0103021:	e8 a3 d0 ff ff       	call   f01000c9 <_panic>
    }
    load_icode(e, binary, size);
f0103026:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103029:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
f010302c:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f0103032:	74 17                	je     f010304b <env_create+0x58>
        panic("error elf magic number\n");
f0103034:	83 ec 04             	sub    $0x4,%esp
f0103037:	68 f1 60 10 f0       	push   $0xf01060f1
f010303c:	68 6b 01 00 00       	push   $0x16b
f0103041:	68 9e 60 10 f0       	push   $0xf010609e
f0103046:	e8 7e d0 ff ff       	call   f01000c9 <_panic>
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f010304b:	8b 5e 1c             	mov    0x1c(%esi),%ebx
    eph = ph + elf->e_phnum;
f010304e:	8b 7e 2c             	mov    0x2c(%esi),%edi

    lcr3(PADDR(e->env_pgdir));
f0103051:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103054:	8b 42 5c             	mov    0x5c(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103057:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010305c:	77 15                	ja     f0103073 <env_create+0x80>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010305e:	50                   	push   %eax
f010305f:	68 54 54 10 f0       	push   $0xf0105454
f0103064:	68 71 01 00 00       	push   $0x171
f0103069:	68 9e 60 10 f0       	push   $0xf010609e
f010306e:	e8 56 d0 ff ff       	call   f01000c9 <_panic>
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
        panic("error elf magic number\n");
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f0103073:	8d 1c 1e             	lea    (%esi,%ebx,1),%ebx
    eph = ph + elf->e_phnum;
f0103076:	0f b7 ff             	movzwl %di,%edi
f0103079:	c1 e7 05             	shl    $0x5,%edi
f010307c:	8d 3c 3b             	lea    (%ebx,%edi,1),%edi
	return (physaddr_t)kva - KERNBASE;
f010307f:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103084:	0f 22 d8             	mov    %eax,%cr3

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f0103087:	39 fb                	cmp    %edi,%ebx
f0103089:	73 48                	jae    f01030d3 <env_create+0xe0>
        if (ph->p_type == ELF_PROG_LOAD) {
f010308b:	83 3b 01             	cmpl   $0x1,(%ebx)
f010308e:	75 3c                	jne    f01030cc <env_create+0xd9>
            // cprintf("%u %u\n", ph->p_memsz, ph->p_filesz);
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103090:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103093:	8b 53 08             	mov    0x8(%ebx),%edx
f0103096:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103099:	e8 1e fc ff ff       	call   f0102cbc <region_alloc>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f010309e:	83 ec 04             	sub    $0x4,%esp
f01030a1:	ff 73 10             	pushl  0x10(%ebx)
f01030a4:	89 f0                	mov    %esi,%eax
f01030a6:	03 43 04             	add    0x4(%ebx),%eax
f01030a9:	50                   	push   %eax
f01030aa:	ff 73 08             	pushl  0x8(%ebx)
f01030ad:	e8 a3 17 00 00       	call   f0104855 <memcpy>
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f01030b2:	8b 43 10             	mov    0x10(%ebx),%eax
f01030b5:	83 c4 0c             	add    $0xc,%esp
f01030b8:	8b 53 14             	mov    0x14(%ebx),%edx
f01030bb:	29 c2                	sub    %eax,%edx
f01030bd:	52                   	push   %edx
f01030be:	6a 00                	push   $0x0
f01030c0:	03 43 08             	add    0x8(%ebx),%eax
f01030c3:	50                   	push   %eax
f01030c4:	e8 d8 16 00 00       	call   f01047a1 <memset>
f01030c9:	83 c4 10             	add    $0x10,%esp
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
    eph = ph + elf->e_phnum;

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f01030cc:	83 c3 20             	add    $0x20,%ebx
f01030cf:	39 df                	cmp    %ebx,%edi
f01030d1:	77 b8                	ja     f010308b <env_create+0x98>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
        }
    }
    e->env_tf.tf_eip = elf->e_entry;
f01030d3:	8b 46 18             	mov    0x18(%esi),%eax
f01030d6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01030d9:	89 42 30             	mov    %eax,0x30(%edx)

    lcr3(PADDR(kern_pgdir));
f01030dc:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01030e1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030e6:	77 15                	ja     f01030fd <env_create+0x10a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030e8:	50                   	push   %eax
f01030e9:	68 54 54 10 f0       	push   $0xf0105454
f01030ee:	68 7d 01 00 00       	push   $0x17d
f01030f3:	68 9e 60 10 f0       	push   $0xf010609e
f01030f8:	e8 cc cf ff ff       	call   f01000c9 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01030fd:	05 00 00 00 10       	add    $0x10000000,%eax
f0103102:	0f 22 d8             	mov    %eax,%cr3
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
    region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103105:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010310a:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010310f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103112:	e8 a5 fb ff ff       	call   f0102cbc <region_alloc>
    int r = env_alloc(&e, 0);
    if (r < 0) {
        panic("env_create: %e\n", r);
    }
    load_icode(e, binary, size);
    e->env_type = type;
f0103117:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010311a:	8b 55 10             	mov    0x10(%ebp),%edx
f010311d:	89 50 50             	mov    %edx,0x50(%eax)
    // cprintf("env_create out\n");
    return;
}
f0103120:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103123:	5b                   	pop    %ebx
f0103124:	5e                   	pop    %esi
f0103125:	5f                   	pop    %edi
f0103126:	c9                   	leave  
f0103127:	c3                   	ret    

f0103128 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103128:	55                   	push   %ebp
f0103129:	89 e5                	mov    %esp,%ebp
f010312b:	57                   	push   %edi
f010312c:	56                   	push   %esi
f010312d:	53                   	push   %ebx
f010312e:	83 ec 1c             	sub    $0x1c,%esp
f0103131:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103134:	a1 bc 72 1d f0       	mov    0xf01d72bc,%eax
f0103139:	39 c7                	cmp    %eax,%edi
f010313b:	75 2c                	jne    f0103169 <env_free+0x41>
		lcr3(PADDR(kern_pgdir));
f010313d:	8b 15 88 7f 1d f0    	mov    0xf01d7f88,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103143:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103149:	77 15                	ja     f0103160 <env_free+0x38>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010314b:	52                   	push   %edx
f010314c:	68 54 54 10 f0       	push   $0xf0105454
f0103151:	68 ac 01 00 00       	push   $0x1ac
f0103156:	68 9e 60 10 f0       	push   $0xf010609e
f010315b:	e8 69 cf ff ff       	call   f01000c9 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103160:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103166:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103169:	8b 4f 48             	mov    0x48(%edi),%ecx
f010316c:	ba 00 00 00 00       	mov    $0x0,%edx
f0103171:	85 c0                	test   %eax,%eax
f0103173:	74 03                	je     f0103178 <env_free+0x50>
f0103175:	8b 50 48             	mov    0x48(%eax),%edx
f0103178:	83 ec 04             	sub    $0x4,%esp
f010317b:	51                   	push   %ecx
f010317c:	52                   	push   %edx
f010317d:	68 09 61 10 f0       	push   $0xf0106109
f0103182:	e8 72 02 00 00       	call   f01033f9 <cprintf>
f0103187:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010318a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	// gets reused.
	if (e == curenv)
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103191:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103194:	c1 e0 02             	shl    $0x2,%eax
f0103197:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010319a:	8b 47 5c             	mov    0x5c(%edi),%eax
f010319d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01031a0:	8b 34 10             	mov    (%eax,%edx,1),%esi
f01031a3:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01031a9:	0f 84 ab 00 00 00    	je     f010325a <env_free+0x132>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01031af:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01031b5:	89 f0                	mov    %esi,%eax
f01031b7:	c1 e8 0c             	shr    $0xc,%eax
f01031ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01031bd:	3b 05 84 7f 1d f0    	cmp    0xf01d7f84,%eax
f01031c3:	72 15                	jb     f01031da <env_free+0xb2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031c5:	56                   	push   %esi
f01031c6:	68 14 56 10 f0       	push   $0xf0105614
f01031cb:	68 bb 01 00 00       	push   $0x1bb
f01031d0:	68 9e 60 10 f0       	push   $0xf010609e
f01031d5:	e8 ef ce ff ff       	call   f01000c9 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01031da:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01031dd:	c1 e2 16             	shl    $0x16,%edx
f01031e0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01031e3:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01031e8:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01031ef:	01 
f01031f0:	74 17                	je     f0103209 <env_free+0xe1>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01031f2:	83 ec 08             	sub    $0x8,%esp
f01031f5:	89 d8                	mov    %ebx,%eax
f01031f7:	c1 e0 0c             	shl    $0xc,%eax
f01031fa:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01031fd:	50                   	push   %eax
f01031fe:	ff 77 5c             	pushl  0x5c(%edi)
f0103201:	e8 6d e3 ff ff       	call   f0101573 <page_remove>
f0103206:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103209:	43                   	inc    %ebx
f010320a:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103210:	75 d6                	jne    f01031e8 <env_free+0xc0>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103212:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103215:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103218:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010321f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103222:	3b 05 84 7f 1d f0    	cmp    0xf01d7f84,%eax
f0103228:	72 14                	jb     f010323e <env_free+0x116>
		panic("pa2page called with invalid pa");
f010322a:	83 ec 04             	sub    $0x4,%esp
f010322d:	68 fc 56 10 f0       	push   $0xf01056fc
f0103232:	6a 4f                	push   $0x4f
f0103234:	68 81 5d 10 f0       	push   $0xf0105d81
f0103239:	e8 8b ce ff ff       	call   f01000c9 <_panic>
		page_decref(pa2page(pa));
f010323e:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103241:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103244:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f010324b:	03 05 8c 7f 1d f0    	add    0xf01d7f8c,%eax
f0103251:	50                   	push   %eax
f0103252:	e8 a5 e1 ff ff       	call   f01013fc <page_decref>
f0103257:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010325a:	ff 45 e0             	incl   -0x20(%ebp)
f010325d:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103264:	0f 85 27 ff ff ff    	jne    f0103191 <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010326a:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010326d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103272:	77 15                	ja     f0103289 <env_free+0x161>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103274:	50                   	push   %eax
f0103275:	68 54 54 10 f0       	push   $0xf0105454
f010327a:	68 c9 01 00 00       	push   $0x1c9
f010327f:	68 9e 60 10 f0       	push   $0xf010609e
f0103284:	e8 40 ce ff ff       	call   f01000c9 <_panic>
	e->env_pgdir = 0;
f0103289:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103290:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103295:	c1 e8 0c             	shr    $0xc,%eax
f0103298:	3b 05 84 7f 1d f0    	cmp    0xf01d7f84,%eax
f010329e:	72 14                	jb     f01032b4 <env_free+0x18c>
		panic("pa2page called with invalid pa");
f01032a0:	83 ec 04             	sub    $0x4,%esp
f01032a3:	68 fc 56 10 f0       	push   $0xf01056fc
f01032a8:	6a 4f                	push   $0x4f
f01032aa:	68 81 5d 10 f0       	push   $0xf0105d81
f01032af:	e8 15 ce ff ff       	call   f01000c9 <_panic>
	page_decref(pa2page(pa));
f01032b4:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01032b7:	c1 e0 03             	shl    $0x3,%eax
f01032ba:	03 05 8c 7f 1d f0    	add    0xf01d7f8c,%eax
f01032c0:	50                   	push   %eax
f01032c1:	e8 36 e1 ff ff       	call   f01013fc <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01032c6:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01032cd:	a1 c0 72 1d f0       	mov    0xf01d72c0,%eax
f01032d2:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01032d5:	89 3d c0 72 1d f0    	mov    %edi,0xf01d72c0
f01032db:	83 c4 10             	add    $0x10,%esp
}
f01032de:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01032e1:	5b                   	pop    %ebx
f01032e2:	5e                   	pop    %esi
f01032e3:	5f                   	pop    %edi
f01032e4:	c9                   	leave  
f01032e5:	c3                   	ret    

f01032e6 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f01032e6:	55                   	push   %ebp
f01032e7:	89 e5                	mov    %esp,%ebp
f01032e9:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f01032ec:	ff 75 08             	pushl  0x8(%ebp)
f01032ef:	e8 34 fe ff ff       	call   f0103128 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01032f4:	c7 04 24 68 60 10 f0 	movl   $0xf0106068,(%esp)
f01032fb:	e8 f9 00 00 00       	call   f01033f9 <cprintf>
f0103300:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0103303:	83 ec 0c             	sub    $0xc,%esp
f0103306:	6a 00                	push   $0x0
f0103308:	e8 e0 da ff ff       	call   f0100ded <monitor>
f010330d:	83 c4 10             	add    $0x10,%esp
f0103310:	eb f1                	jmp    f0103303 <env_destroy+0x1d>

f0103312 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103312:	55                   	push   %ebp
f0103313:	89 e5                	mov    %esp,%ebp
f0103315:	83 ec 0c             	sub    $0xc,%esp
	__asm __volatile("movl %0,%%esp\n"
f0103318:	8b 65 08             	mov    0x8(%ebp),%esp
f010331b:	61                   	popa   
f010331c:	07                   	pop    %es
f010331d:	1f                   	pop    %ds
f010331e:	83 c4 08             	add    $0x8,%esp
f0103321:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103322:	68 1f 61 10 f0       	push   $0xf010611f
f0103327:	68 f1 01 00 00       	push   $0x1f1
f010332c:	68 9e 60 10 f0       	push   $0xf010609e
f0103331:	e8 93 cd ff ff       	call   f01000c9 <_panic>

f0103336 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103336:	55                   	push   %ebp
f0103337:	89 e5                	mov    %esp,%ebp
f0103339:	83 ec 08             	sub    $0x8,%esp
f010333c:	8b 45 08             	mov    0x8(%ebp),%eax
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

    if (curenv != NULL) {
f010333f:	8b 15 bc 72 1d f0    	mov    0xf01d72bc,%edx
f0103345:	85 d2                	test   %edx,%edx
f0103347:	74 0d                	je     f0103356 <env_run+0x20>
        // context switch
        if (curenv->env_status == ENV_RUNNING) {
f0103349:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f010334d:	75 07                	jne    f0103356 <env_run+0x20>
            curenv->env_status = ENV_RUNNABLE;
f010334f:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
        }
        // how about other env_status ? e.g. like ENV_DYING ?
    }
    curenv = e;
f0103356:	a3 bc 72 1d f0       	mov    %eax,0xf01d72bc
    curenv->env_status = ENV_RUNNING;
f010335b:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    curenv->env_runs++;
f0103362:	ff 40 58             	incl   0x58(%eax)
    
    // may have some problem, because lcr3(x), x should be physical address
    lcr3(PADDR(curenv->env_pgdir));
f0103365:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103368:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010336e:	77 15                	ja     f0103385 <env_run+0x4f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103370:	52                   	push   %edx
f0103371:	68 54 54 10 f0       	push   $0xf0105454
f0103376:	68 1c 02 00 00       	push   $0x21c
f010337b:	68 9e 60 10 f0       	push   $0xf010609e
f0103380:	e8 44 cd ff ff       	call   f01000c9 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103385:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f010338b:	0f 22 da             	mov    %edx,%cr3

    env_pop_tf(&curenv->env_tf);    
f010338e:	83 ec 0c             	sub    $0xc,%esp
f0103391:	50                   	push   %eax
f0103392:	e8 7b ff ff ff       	call   f0103312 <env_pop_tf>
	...

f0103398 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103398:	55                   	push   %ebp
f0103399:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010339b:	ba 70 00 00 00       	mov    $0x70,%edx
f01033a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01033a3:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01033a4:	b2 71                	mov    $0x71,%dl
f01033a6:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01033a7:	0f b6 c0             	movzbl %al,%eax
}
f01033aa:	c9                   	leave  
f01033ab:	c3                   	ret    

f01033ac <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01033ac:	55                   	push   %ebp
f01033ad:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01033af:	ba 70 00 00 00       	mov    $0x70,%edx
f01033b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01033b7:	ee                   	out    %al,(%dx)
f01033b8:	b2 71                	mov    $0x71,%dl
f01033ba:	8b 45 0c             	mov    0xc(%ebp),%eax
f01033bd:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01033be:	c9                   	leave  
f01033bf:	c3                   	ret    

f01033c0 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01033c0:	55                   	push   %ebp
f01033c1:	89 e5                	mov    %esp,%ebp
f01033c3:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01033c6:	ff 75 08             	pushl  0x8(%ebp)
f01033c9:	e8 18 d2 ff ff       	call   f01005e6 <cputchar>
f01033ce:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f01033d1:	c9                   	leave  
f01033d2:	c3                   	ret    

f01033d3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01033d3:	55                   	push   %ebp
f01033d4:	89 e5                	mov    %esp,%ebp
f01033d6:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01033d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01033e0:	ff 75 0c             	pushl  0xc(%ebp)
f01033e3:	ff 75 08             	pushl  0x8(%ebp)
f01033e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01033e9:	50                   	push   %eax
f01033ea:	68 c0 33 10 f0       	push   $0xf01033c0
f01033ef:	e8 15 0d 00 00       	call   f0104109 <vprintfmt>
	return cnt;
}
f01033f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01033f7:	c9                   	leave  
f01033f8:	c3                   	ret    

f01033f9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01033f9:	55                   	push   %ebp
f01033fa:	89 e5                	mov    %esp,%ebp
f01033fc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01033ff:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103402:	50                   	push   %eax
f0103403:	ff 75 08             	pushl  0x8(%ebp)
f0103406:	e8 c8 ff ff ff       	call   f01033d3 <vcprintf>
	va_end(ap);

	return cnt;
}
f010340b:	c9                   	leave  
f010340c:	c3                   	ret    
f010340d:	00 00                	add    %al,(%eax)
	...

f0103410 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103410:	55                   	push   %ebp
f0103411:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103413:	c7 05 04 7b 1d f0 00 	movl   $0xf0000000,0xf01d7b04
f010341a:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f010341d:	66 c7 05 08 7b 1d f0 	movw   $0x10,0xf01d7b08
f0103424:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103426:	66 c7 05 28 23 12 f0 	movw   $0x68,0xf0122328
f010342d:	68 00 
f010342f:	b8 00 7b 1d f0       	mov    $0xf01d7b00,%eax
f0103434:	66 a3 2a 23 12 f0    	mov    %ax,0xf012232a
f010343a:	89 c2                	mov    %eax,%edx
f010343c:	c1 ea 10             	shr    $0x10,%edx
f010343f:	88 15 2c 23 12 f0    	mov    %dl,0xf012232c
f0103445:	c6 05 2e 23 12 f0 40 	movb   $0x40,0xf012232e
f010344c:	c1 e8 18             	shr    $0x18,%eax
f010344f:	a2 2f 23 12 f0       	mov    %al,0xf012232f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103454:	c6 05 2d 23 12 f0 89 	movb   $0x89,0xf012232d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010345b:	b8 28 00 00 00       	mov    $0x28,%eax
f0103460:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103463:	b8 38 23 12 f0       	mov    $0xf0122338,%eax
f0103468:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f010346b:	c9                   	leave  
f010346c:	c3                   	ret    

f010346d <trap_init>:
}


void
trap_init(void)
{
f010346d:	55                   	push   %ebp
f010346e:	89 e5                	mov    %esp,%ebp
	void vec17();
	void vec18();
	void vec19();
    void vec48();

	SETGATE(idt[0], 0, GD_KT, vec0, 0);
f0103470:	b8 24 3b 10 f0       	mov    $0xf0103b24,%eax
f0103475:	66 a3 e0 72 1d f0    	mov    %ax,0xf01d72e0
f010347b:	66 c7 05 e2 72 1d f0 	movw   $0x8,0xf01d72e2
f0103482:	08 00 
f0103484:	c6 05 e4 72 1d f0 00 	movb   $0x0,0xf01d72e4
f010348b:	c6 05 e5 72 1d f0 8e 	movb   $0x8e,0xf01d72e5
f0103492:	c1 e8 10             	shr    $0x10,%eax
f0103495:	66 a3 e6 72 1d f0    	mov    %ax,0xf01d72e6
	SETGATE(idt[1], 0, GD_KT, vec1, 0);
f010349b:	b8 2a 3b 10 f0       	mov    $0xf0103b2a,%eax
f01034a0:	66 a3 e8 72 1d f0    	mov    %ax,0xf01d72e8
f01034a6:	66 c7 05 ea 72 1d f0 	movw   $0x8,0xf01d72ea
f01034ad:	08 00 
f01034af:	c6 05 ec 72 1d f0 00 	movb   $0x0,0xf01d72ec
f01034b6:	c6 05 ed 72 1d f0 8e 	movb   $0x8e,0xf01d72ed
f01034bd:	c1 e8 10             	shr    $0x10,%eax
f01034c0:	66 a3 ee 72 1d f0    	mov    %ax,0xf01d72ee
	SETGATE(idt[2], 0, GD_KT, vec2, 0);
f01034c6:	b8 30 3b 10 f0       	mov    $0xf0103b30,%eax
f01034cb:	66 a3 f0 72 1d f0    	mov    %ax,0xf01d72f0
f01034d1:	66 c7 05 f2 72 1d f0 	movw   $0x8,0xf01d72f2
f01034d8:	08 00 
f01034da:	c6 05 f4 72 1d f0 00 	movb   $0x0,0xf01d72f4
f01034e1:	c6 05 f5 72 1d f0 8e 	movb   $0x8e,0xf01d72f5
f01034e8:	c1 e8 10             	shr    $0x10,%eax
f01034eb:	66 a3 f6 72 1d f0    	mov    %ax,0xf01d72f6
	SETGATE(idt[3], 0, GD_KT, vec3, 3);     // software interrupt 
f01034f1:	b8 36 3b 10 f0       	mov    $0xf0103b36,%eax
f01034f6:	66 a3 f8 72 1d f0    	mov    %ax,0xf01d72f8
f01034fc:	66 c7 05 fa 72 1d f0 	movw   $0x8,0xf01d72fa
f0103503:	08 00 
f0103505:	c6 05 fc 72 1d f0 00 	movb   $0x0,0xf01d72fc
f010350c:	c6 05 fd 72 1d f0 ee 	movb   $0xee,0xf01d72fd
f0103513:	c1 e8 10             	shr    $0x10,%eax
f0103516:	66 a3 fe 72 1d f0    	mov    %ax,0xf01d72fe
	SETGATE(idt[4], 0, GD_KT, vec4, 0);
f010351c:	b8 3c 3b 10 f0       	mov    $0xf0103b3c,%eax
f0103521:	66 a3 00 73 1d f0    	mov    %ax,0xf01d7300
f0103527:	66 c7 05 02 73 1d f0 	movw   $0x8,0xf01d7302
f010352e:	08 00 
f0103530:	c6 05 04 73 1d f0 00 	movb   $0x0,0xf01d7304
f0103537:	c6 05 05 73 1d f0 8e 	movb   $0x8e,0xf01d7305
f010353e:	c1 e8 10             	shr    $0x10,%eax
f0103541:	66 a3 06 73 1d f0    	mov    %ax,0xf01d7306

	SETGATE(idt[6], 0, GD_KT, vec6, 0);
f0103547:	b8 42 3b 10 f0       	mov    $0xf0103b42,%eax
f010354c:	66 a3 10 73 1d f0    	mov    %ax,0xf01d7310
f0103552:	66 c7 05 12 73 1d f0 	movw   $0x8,0xf01d7312
f0103559:	08 00 
f010355b:	c6 05 14 73 1d f0 00 	movb   $0x0,0xf01d7314
f0103562:	c6 05 15 73 1d f0 8e 	movb   $0x8e,0xf01d7315
f0103569:	c1 e8 10             	shr    $0x10,%eax
f010356c:	66 a3 16 73 1d f0    	mov    %ax,0xf01d7316
	SETGATE(idt[7], 0, GD_KT, vec7, 0);
f0103572:	b8 48 3b 10 f0       	mov    $0xf0103b48,%eax
f0103577:	66 a3 18 73 1d f0    	mov    %ax,0xf01d7318
f010357d:	66 c7 05 1a 73 1d f0 	movw   $0x8,0xf01d731a
f0103584:	08 00 
f0103586:	c6 05 1c 73 1d f0 00 	movb   $0x0,0xf01d731c
f010358d:	c6 05 1d 73 1d f0 8e 	movb   $0x8e,0xf01d731d
f0103594:	c1 e8 10             	shr    $0x10,%eax
f0103597:	66 a3 1e 73 1d f0    	mov    %ax,0xf01d731e
	SETGATE(idt[8], 0, GD_KT, vec8, 0);
f010359d:	b8 4e 3b 10 f0       	mov    $0xf0103b4e,%eax
f01035a2:	66 a3 20 73 1d f0    	mov    %ax,0xf01d7320
f01035a8:	66 c7 05 22 73 1d f0 	movw   $0x8,0xf01d7322
f01035af:	08 00 
f01035b1:	c6 05 24 73 1d f0 00 	movb   $0x0,0xf01d7324
f01035b8:	c6 05 25 73 1d f0 8e 	movb   $0x8e,0xf01d7325
f01035bf:	c1 e8 10             	shr    $0x10,%eax
f01035c2:	66 a3 26 73 1d f0    	mov    %ax,0xf01d7326
	SETGATE(idt[10], 0, GD_KT, vec10, 0);
f01035c8:	b8 54 3b 10 f0       	mov    $0xf0103b54,%eax
f01035cd:	66 a3 30 73 1d f0    	mov    %ax,0xf01d7330
f01035d3:	66 c7 05 32 73 1d f0 	movw   $0x8,0xf01d7332
f01035da:	08 00 
f01035dc:	c6 05 34 73 1d f0 00 	movb   $0x0,0xf01d7334
f01035e3:	c6 05 35 73 1d f0 8e 	movb   $0x8e,0xf01d7335
f01035ea:	c1 e8 10             	shr    $0x10,%eax
f01035ed:	66 a3 36 73 1d f0    	mov    %ax,0xf01d7336
	SETGATE(idt[11], 0, GD_KT, vec11, 0);
f01035f3:	b8 58 3b 10 f0       	mov    $0xf0103b58,%eax
f01035f8:	66 a3 38 73 1d f0    	mov    %ax,0xf01d7338
f01035fe:	66 c7 05 3a 73 1d f0 	movw   $0x8,0xf01d733a
f0103605:	08 00 
f0103607:	c6 05 3c 73 1d f0 00 	movb   $0x0,0xf01d733c
f010360e:	c6 05 3d 73 1d f0 8e 	movb   $0x8e,0xf01d733d
f0103615:	c1 e8 10             	shr    $0x10,%eax
f0103618:	66 a3 3e 73 1d f0    	mov    %ax,0xf01d733e
	SETGATE(idt[12], 0, GD_KT, vec12, 0);
f010361e:	b8 5c 3b 10 f0       	mov    $0xf0103b5c,%eax
f0103623:	66 a3 40 73 1d f0    	mov    %ax,0xf01d7340
f0103629:	66 c7 05 42 73 1d f0 	movw   $0x8,0xf01d7342
f0103630:	08 00 
f0103632:	c6 05 44 73 1d f0 00 	movb   $0x0,0xf01d7344
f0103639:	c6 05 45 73 1d f0 8e 	movb   $0x8e,0xf01d7345
f0103640:	c1 e8 10             	shr    $0x10,%eax
f0103643:	66 a3 46 73 1d f0    	mov    %ax,0xf01d7346
	SETGATE(idt[13], 0, GD_KT, vec13, 0);
f0103649:	b8 60 3b 10 f0       	mov    $0xf0103b60,%eax
f010364e:	66 a3 48 73 1d f0    	mov    %ax,0xf01d7348
f0103654:	66 c7 05 4a 73 1d f0 	movw   $0x8,0xf01d734a
f010365b:	08 00 
f010365d:	c6 05 4c 73 1d f0 00 	movb   $0x0,0xf01d734c
f0103664:	c6 05 4d 73 1d f0 8e 	movb   $0x8e,0xf01d734d
f010366b:	c1 e8 10             	shr    $0x10,%eax
f010366e:	66 a3 4e 73 1d f0    	mov    %ax,0xf01d734e
	SETGATE(idt[14], 0, GD_KT, vec14, 0);
f0103674:	b8 64 3b 10 f0       	mov    $0xf0103b64,%eax
f0103679:	66 a3 50 73 1d f0    	mov    %ax,0xf01d7350
f010367f:	66 c7 05 52 73 1d f0 	movw   $0x8,0xf01d7352
f0103686:	08 00 
f0103688:	c6 05 54 73 1d f0 00 	movb   $0x0,0xf01d7354
f010368f:	c6 05 55 73 1d f0 8e 	movb   $0x8e,0xf01d7355
f0103696:	c1 e8 10             	shr    $0x10,%eax
f0103699:	66 a3 56 73 1d f0    	mov    %ax,0xf01d7356

	SETGATE(idt[16], 0, GD_KT, vec16, 0);
f010369f:	b8 68 3b 10 f0       	mov    $0xf0103b68,%eax
f01036a4:	66 a3 60 73 1d f0    	mov    %ax,0xf01d7360
f01036aa:	66 c7 05 62 73 1d f0 	movw   $0x8,0xf01d7362
f01036b1:	08 00 
f01036b3:	c6 05 64 73 1d f0 00 	movb   $0x0,0xf01d7364
f01036ba:	c6 05 65 73 1d f0 8e 	movb   $0x8e,0xf01d7365
f01036c1:	c1 e8 10             	shr    $0x10,%eax
f01036c4:	66 a3 66 73 1d f0    	mov    %ax,0xf01d7366
	SETGATE(idt[17], 0, GD_KT, vec17, 0);
f01036ca:	b8 6e 3b 10 f0       	mov    $0xf0103b6e,%eax
f01036cf:	66 a3 68 73 1d f0    	mov    %ax,0xf01d7368
f01036d5:	66 c7 05 6a 73 1d f0 	movw   $0x8,0xf01d736a
f01036dc:	08 00 
f01036de:	c6 05 6c 73 1d f0 00 	movb   $0x0,0xf01d736c
f01036e5:	c6 05 6d 73 1d f0 8e 	movb   $0x8e,0xf01d736d
f01036ec:	c1 e8 10             	shr    $0x10,%eax
f01036ef:	66 a3 6e 73 1d f0    	mov    %ax,0xf01d736e
	SETGATE(idt[18], 0, GD_KT, vec18, 0);
f01036f5:	b8 72 3b 10 f0       	mov    $0xf0103b72,%eax
f01036fa:	66 a3 70 73 1d f0    	mov    %ax,0xf01d7370
f0103700:	66 c7 05 72 73 1d f0 	movw   $0x8,0xf01d7372
f0103707:	08 00 
f0103709:	c6 05 74 73 1d f0 00 	movb   $0x0,0xf01d7374
f0103710:	c6 05 75 73 1d f0 8e 	movb   $0x8e,0xf01d7375
f0103717:	c1 e8 10             	shr    $0x10,%eax
f010371a:	66 a3 76 73 1d f0    	mov    %ax,0xf01d7376
	SETGATE(idt[19], 0, GD_KT, vec19, 0);
f0103720:	b8 78 3b 10 f0       	mov    $0xf0103b78,%eax
f0103725:	66 a3 78 73 1d f0    	mov    %ax,0xf01d7378
f010372b:	66 c7 05 7a 73 1d f0 	movw   $0x8,0xf01d737a
f0103732:	08 00 
f0103734:	c6 05 7c 73 1d f0 00 	movb   $0x0,0xf01d737c
f010373b:	c6 05 7d 73 1d f0 8e 	movb   $0x8e,0xf01d737d
f0103742:	c1 e8 10             	shr    $0x10,%eax
f0103745:	66 a3 7e 73 1d f0    	mov    %ax,0xf01d737e
    SETGATE(idt[48], 0, GD_KT, vec48, 3);
f010374b:	b8 7e 3b 10 f0       	mov    $0xf0103b7e,%eax
f0103750:	66 a3 60 74 1d f0    	mov    %ax,0xf01d7460
f0103756:	66 c7 05 62 74 1d f0 	movw   $0x8,0xf01d7462
f010375d:	08 00 
f010375f:	c6 05 64 74 1d f0 00 	movb   $0x0,0xf01d7464
f0103766:	c6 05 65 74 1d f0 ee 	movb   $0xee,0xf01d7465
f010376d:	c1 e8 10             	shr    $0x10,%eax
f0103770:	66 a3 66 74 1d f0    	mov    %ax,0xf01d7466

	// Per-CPU setup 
	trap_init_percpu();
f0103776:	e8 95 fc ff ff       	call   f0103410 <trap_init_percpu>
}
f010377b:	c9                   	leave  
f010377c:	c3                   	ret    

f010377d <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f010377d:	55                   	push   %ebp
f010377e:	89 e5                	mov    %esp,%ebp
f0103780:	53                   	push   %ebx
f0103781:	83 ec 0c             	sub    $0xc,%esp
f0103784:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103787:	ff 33                	pushl  (%ebx)
f0103789:	68 2b 61 10 f0       	push   $0xf010612b
f010378e:	e8 66 fc ff ff       	call   f01033f9 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103793:	83 c4 08             	add    $0x8,%esp
f0103796:	ff 73 04             	pushl  0x4(%ebx)
f0103799:	68 3a 61 10 f0       	push   $0xf010613a
f010379e:	e8 56 fc ff ff       	call   f01033f9 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01037a3:	83 c4 08             	add    $0x8,%esp
f01037a6:	ff 73 08             	pushl  0x8(%ebx)
f01037a9:	68 49 61 10 f0       	push   $0xf0106149
f01037ae:	e8 46 fc ff ff       	call   f01033f9 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01037b3:	83 c4 08             	add    $0x8,%esp
f01037b6:	ff 73 0c             	pushl  0xc(%ebx)
f01037b9:	68 58 61 10 f0       	push   $0xf0106158
f01037be:	e8 36 fc ff ff       	call   f01033f9 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01037c3:	83 c4 08             	add    $0x8,%esp
f01037c6:	ff 73 10             	pushl  0x10(%ebx)
f01037c9:	68 67 61 10 f0       	push   $0xf0106167
f01037ce:	e8 26 fc ff ff       	call   f01033f9 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01037d3:	83 c4 08             	add    $0x8,%esp
f01037d6:	ff 73 14             	pushl  0x14(%ebx)
f01037d9:	68 76 61 10 f0       	push   $0xf0106176
f01037de:	e8 16 fc ff ff       	call   f01033f9 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01037e3:	83 c4 08             	add    $0x8,%esp
f01037e6:	ff 73 18             	pushl  0x18(%ebx)
f01037e9:	68 85 61 10 f0       	push   $0xf0106185
f01037ee:	e8 06 fc ff ff       	call   f01033f9 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01037f3:	83 c4 08             	add    $0x8,%esp
f01037f6:	ff 73 1c             	pushl  0x1c(%ebx)
f01037f9:	68 94 61 10 f0       	push   $0xf0106194
f01037fe:	e8 f6 fb ff ff       	call   f01033f9 <cprintf>
f0103803:	83 c4 10             	add    $0x10,%esp
}
f0103806:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103809:	c9                   	leave  
f010380a:	c3                   	ret    

f010380b <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f010380b:	55                   	push   %ebp
f010380c:	89 e5                	mov    %esp,%ebp
f010380e:	53                   	push   %ebx
f010380f:	83 ec 0c             	sub    $0xc,%esp
f0103812:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103815:	53                   	push   %ebx
f0103816:	68 ca 62 10 f0       	push   $0xf01062ca
f010381b:	e8 d9 fb ff ff       	call   f01033f9 <cprintf>
	print_regs(&tf->tf_regs);
f0103820:	89 1c 24             	mov    %ebx,(%esp)
f0103823:	e8 55 ff ff ff       	call   f010377d <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103828:	83 c4 08             	add    $0x8,%esp
f010382b:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010382f:	50                   	push   %eax
f0103830:	68 e5 61 10 f0       	push   $0xf01061e5
f0103835:	e8 bf fb ff ff       	call   f01033f9 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010383a:	83 c4 08             	add    $0x8,%esp
f010383d:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103841:	50                   	push   %eax
f0103842:	68 f8 61 10 f0       	push   $0xf01061f8
f0103847:	e8 ad fb ff ff       	call   f01033f9 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010384c:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f010384f:	83 c4 10             	add    $0x10,%esp
f0103852:	83 f8 13             	cmp    $0x13,%eax
f0103855:	77 09                	ja     f0103860 <print_trapframe+0x55>
		return excnames[trapno];
f0103857:	8b 14 85 c0 64 10 f0 	mov    -0xfef9b40(,%eax,4),%edx
f010385e:	eb 11                	jmp    f0103871 <print_trapframe+0x66>
	if (trapno == T_SYSCALL)
f0103860:	83 f8 30             	cmp    $0x30,%eax
f0103863:	75 07                	jne    f010386c <print_trapframe+0x61>
		return "System call";
f0103865:	ba a3 61 10 f0       	mov    $0xf01061a3,%edx
f010386a:	eb 05                	jmp    f0103871 <print_trapframe+0x66>
	return "(unknown trap)";
f010386c:	ba af 61 10 f0       	mov    $0xf01061af,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103871:	83 ec 04             	sub    $0x4,%esp
f0103874:	52                   	push   %edx
f0103875:	50                   	push   %eax
f0103876:	68 0b 62 10 f0       	push   $0xf010620b
f010387b:	e8 79 fb ff ff       	call   f01033f9 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103880:	83 c4 10             	add    $0x10,%esp
f0103883:	3b 1d e0 7a 1d f0    	cmp    0xf01d7ae0,%ebx
f0103889:	75 1a                	jne    f01038a5 <print_trapframe+0x9a>
f010388b:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010388f:	75 14                	jne    f01038a5 <print_trapframe+0x9a>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103891:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103894:	83 ec 08             	sub    $0x8,%esp
f0103897:	50                   	push   %eax
f0103898:	68 1d 62 10 f0       	push   $0xf010621d
f010389d:	e8 57 fb ff ff       	call   f01033f9 <cprintf>
f01038a2:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f01038a5:	83 ec 08             	sub    $0x8,%esp
f01038a8:	ff 73 2c             	pushl  0x2c(%ebx)
f01038ab:	68 2c 62 10 f0       	push   $0xf010622c
f01038b0:	e8 44 fb ff ff       	call   f01033f9 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01038b5:	83 c4 10             	add    $0x10,%esp
f01038b8:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01038bc:	75 45                	jne    f0103903 <print_trapframe+0xf8>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01038be:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01038c1:	a8 01                	test   $0x1,%al
f01038c3:	74 07                	je     f01038cc <print_trapframe+0xc1>
f01038c5:	b9 be 61 10 f0       	mov    $0xf01061be,%ecx
f01038ca:	eb 05                	jmp    f01038d1 <print_trapframe+0xc6>
f01038cc:	b9 c9 61 10 f0       	mov    $0xf01061c9,%ecx
f01038d1:	a8 02                	test   $0x2,%al
f01038d3:	74 07                	je     f01038dc <print_trapframe+0xd1>
f01038d5:	ba d5 61 10 f0       	mov    $0xf01061d5,%edx
f01038da:	eb 05                	jmp    f01038e1 <print_trapframe+0xd6>
f01038dc:	ba db 61 10 f0       	mov    $0xf01061db,%edx
f01038e1:	a8 04                	test   $0x4,%al
f01038e3:	74 07                	je     f01038ec <print_trapframe+0xe1>
f01038e5:	b8 e0 61 10 f0       	mov    $0xf01061e0,%eax
f01038ea:	eb 05                	jmp    f01038f1 <print_trapframe+0xe6>
f01038ec:	b8 14 63 10 f0       	mov    $0xf0106314,%eax
f01038f1:	51                   	push   %ecx
f01038f2:	52                   	push   %edx
f01038f3:	50                   	push   %eax
f01038f4:	68 3a 62 10 f0       	push   $0xf010623a
f01038f9:	e8 fb fa ff ff       	call   f01033f9 <cprintf>
f01038fe:	83 c4 10             	add    $0x10,%esp
f0103901:	eb 10                	jmp    f0103913 <print_trapframe+0x108>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103903:	83 ec 0c             	sub    $0xc,%esp
f0103906:	68 2a 4c 10 f0       	push   $0xf0104c2a
f010390b:	e8 e9 fa ff ff       	call   f01033f9 <cprintf>
f0103910:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103913:	83 ec 08             	sub    $0x8,%esp
f0103916:	ff 73 30             	pushl  0x30(%ebx)
f0103919:	68 49 62 10 f0       	push   $0xf0106249
f010391e:	e8 d6 fa ff ff       	call   f01033f9 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103923:	83 c4 08             	add    $0x8,%esp
f0103926:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010392a:	50                   	push   %eax
f010392b:	68 58 62 10 f0       	push   $0xf0106258
f0103930:	e8 c4 fa ff ff       	call   f01033f9 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103935:	83 c4 08             	add    $0x8,%esp
f0103938:	ff 73 38             	pushl  0x38(%ebx)
f010393b:	68 6b 62 10 f0       	push   $0xf010626b
f0103940:	e8 b4 fa ff ff       	call   f01033f9 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103945:	83 c4 10             	add    $0x10,%esp
f0103948:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010394c:	74 25                	je     f0103973 <print_trapframe+0x168>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010394e:	83 ec 08             	sub    $0x8,%esp
f0103951:	ff 73 3c             	pushl  0x3c(%ebx)
f0103954:	68 7a 62 10 f0       	push   $0xf010627a
f0103959:	e8 9b fa ff ff       	call   f01033f9 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010395e:	83 c4 08             	add    $0x8,%esp
f0103961:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103965:	50                   	push   %eax
f0103966:	68 89 62 10 f0       	push   $0xf0106289
f010396b:	e8 89 fa ff ff       	call   f01033f9 <cprintf>
f0103970:	83 c4 10             	add    $0x10,%esp
	}
}
f0103973:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103976:	c9                   	leave  
f0103977:	c3                   	ret    

f0103978 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103978:	55                   	push   %ebp
f0103979:	89 e5                	mov    %esp,%ebp
f010397b:	53                   	push   %ebx
f010397c:	83 ec 04             	sub    $0x4,%esp
f010397f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103982:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103985:	ff 73 30             	pushl  0x30(%ebx)
f0103988:	50                   	push   %eax
		curenv->env_id, fault_va, tf->tf_eip);
f0103989:	a1 bc 72 1d f0       	mov    0xf01d72bc,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010398e:	ff 70 48             	pushl  0x48(%eax)
f0103991:	68 60 64 10 f0       	push   $0xf0106460
f0103996:	e8 5e fa ff ff       	call   f01033f9 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010399b:	89 1c 24             	mov    %ebx,(%esp)
f010399e:	e8 68 fe ff ff       	call   f010380b <print_trapframe>
	env_destroy(curenv);
f01039a3:	83 c4 04             	add    $0x4,%esp
f01039a6:	ff 35 bc 72 1d f0    	pushl  0xf01d72bc
f01039ac:	e8 35 f9 ff ff       	call   f01032e6 <env_destroy>
f01039b1:	83 c4 10             	add    $0x10,%esp
}
f01039b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01039b7:	c9                   	leave  
f01039b8:	c3                   	ret    

f01039b9 <trap>:
    }
}

void
trap(struct Trapframe *tf)
{
f01039b9:	55                   	push   %ebp
f01039ba:	89 e5                	mov    %esp,%ebp
f01039bc:	57                   	push   %edi
f01039bd:	56                   	push   %esi
f01039be:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01039c1:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01039c2:	9c                   	pushf  
f01039c3:	58                   	pop    %eax
	
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01039c4:	f6 c4 02             	test   $0x2,%ah
f01039c7:	74 19                	je     f01039e2 <trap+0x29>
f01039c9:	68 9c 62 10 f0       	push   $0xf010629c
f01039ce:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01039d3:	68 e1 00 00 00       	push   $0xe1
f01039d8:	68 b5 62 10 f0       	push   $0xf01062b5
f01039dd:	e8 e7 c6 ff ff       	call   f01000c9 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f01039e2:	83 ec 08             	sub    $0x8,%esp
f01039e5:	56                   	push   %esi
f01039e6:	68 c1 62 10 f0       	push   $0xf01062c1
f01039eb:	e8 09 fa ff ff       	call   f01033f9 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f01039f0:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01039f4:	83 e0 03             	and    $0x3,%eax
f01039f7:	83 c4 10             	add    $0x10,%esp
f01039fa:	83 f8 03             	cmp    $0x3,%eax
f01039fd:	75 31                	jne    f0103a30 <trap+0x77>
		// Trapped from user mode.
		assert(curenv);
f01039ff:	a1 bc 72 1d f0       	mov    0xf01d72bc,%eax
f0103a04:	85 c0                	test   %eax,%eax
f0103a06:	75 19                	jne    f0103a21 <trap+0x68>
f0103a08:	68 dc 62 10 f0       	push   $0xf01062dc
f0103a0d:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0103a12:	68 e7 00 00 00       	push   $0xe7
f0103a17:	68 b5 62 10 f0       	push   $0xf01062b5
f0103a1c:	e8 a8 c6 ff ff       	call   f01000c9 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103a21:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103a26:	89 c7                	mov    %eax,%edi
f0103a28:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103a2a:	8b 35 bc 72 1d f0    	mov    0xf01d72bc,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103a30:	89 35 e0 7a 1d f0    	mov    %esi,0xf01d7ae0
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
    
    int r;
    cprintf("TRAPNO : %d\n", tf->tf_trapno);
f0103a36:	83 ec 08             	sub    $0x8,%esp
f0103a39:	ff 76 28             	pushl  0x28(%esi)
f0103a3c:	68 e3 62 10 f0       	push   $0xf01062e3
f0103a41:	e8 b3 f9 ff ff       	call   f01033f9 <cprintf>
    switch (tf->tf_trapno) {
f0103a46:	83 c4 10             	add    $0x10,%esp
f0103a49:	8b 46 28             	mov    0x28(%esi),%eax
f0103a4c:	83 f8 0e             	cmp    $0xe,%eax
f0103a4f:	74 0c                	je     f0103a5d <trap+0xa4>
f0103a51:	83 f8 30             	cmp    $0x30,%eax
f0103a54:	74 26                	je     f0103a7c <trap+0xc3>
f0103a56:	83 f8 03             	cmp    $0x3,%eax
f0103a59:	75 5d                	jne    f0103ab8 <trap+0xff>
f0103a5b:	eb 11                	jmp    f0103a6e <trap+0xb5>
        case T_PGFLT:
            page_fault_handler(tf);
f0103a5d:	83 ec 0c             	sub    $0xc,%esp
f0103a60:	56                   	push   %esi
f0103a61:	e8 12 ff ff ff       	call   f0103978 <page_fault_handler>
f0103a66:	83 c4 10             	add    $0x10,%esp
f0103a69:	e9 85 00 00 00       	jmp    f0103af3 <trap+0x13a>
            break;
        case T_BRKPT:
            monitor(tf); 
f0103a6e:	83 ec 0c             	sub    $0xc,%esp
f0103a71:	56                   	push   %esi
f0103a72:	e8 76 d3 ff ff       	call   f0100ded <monitor>
f0103a77:	83 c4 10             	add    $0x10,%esp
f0103a7a:	eb 77                	jmp    f0103af3 <trap+0x13a>
            break;
        case T_SYSCALL:
            r = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0103a7c:	83 ec 08             	sub    $0x8,%esp
f0103a7f:	ff 76 04             	pushl  0x4(%esi)
f0103a82:	ff 36                	pushl  (%esi)
f0103a84:	ff 76 10             	pushl  0x10(%esi)
f0103a87:	ff 76 18             	pushl  0x18(%esi)
f0103a8a:	ff 76 14             	pushl  0x14(%esi)
f0103a8d:	ff 76 1c             	pushl  0x1c(%esi)
f0103a90:	e8 03 01 00 00       	call   f0103b98 <syscall>
                        tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
            if (r < 0)
f0103a95:	83 c4 20             	add    $0x20,%esp
f0103a98:	85 c0                	test   %eax,%eax
f0103a9a:	79 17                	jns    f0103ab3 <trap+0xfa>
                panic("syscall error : \n");
f0103a9c:	83 ec 04             	sub    $0x4,%esp
f0103a9f:	68 f0 62 10 f0       	push   $0xf01062f0
f0103aa4:	68 c7 00 00 00       	push   $0xc7
f0103aa9:	68 b5 62 10 f0       	push   $0xf01062b5
f0103aae:	e8 16 c6 ff ff       	call   f01000c9 <_panic>
            else
                tf->tf_regs.reg_eax = r;
f0103ab3:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103ab6:	eb 3b                	jmp    f0103af3 <trap+0x13a>
            break;
        default:
	        // Unexpected trap: The user process or the kernel has a bug.
	        print_trapframe(tf);
f0103ab8:	83 ec 0c             	sub    $0xc,%esp
f0103abb:	56                   	push   %esi
f0103abc:	e8 4a fd ff ff       	call   f010380b <print_trapframe>
	        if (tf->tf_cs == GD_KT)
f0103ac1:	83 c4 10             	add    $0x10,%esp
f0103ac4:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103ac9:	75 17                	jne    f0103ae2 <trap+0x129>
		        panic("unhandled trap in kernel");
f0103acb:	83 ec 04             	sub    $0x4,%esp
f0103ace:	68 02 63 10 f0       	push   $0xf0106302
f0103ad3:	68 cf 00 00 00       	push   $0xcf
f0103ad8:	68 b5 62 10 f0       	push   $0xf01062b5
f0103add:	e8 e7 c5 ff ff       	call   f01000c9 <_panic>
	        else {
		        env_destroy(curenv);
f0103ae2:	83 ec 0c             	sub    $0xc,%esp
f0103ae5:	ff 35 bc 72 1d f0    	pushl  0xf01d72bc
f0103aeb:	e8 f6 f7 ff ff       	call   f01032e6 <env_destroy>
f0103af0:	83 c4 10             	add    $0x10,%esp

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103af3:	a1 bc 72 1d f0       	mov    0xf01d72bc,%eax
f0103af8:	85 c0                	test   %eax,%eax
f0103afa:	74 06                	je     f0103b02 <trap+0x149>
f0103afc:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103b00:	74 19                	je     f0103b1b <trap+0x162>
f0103b02:	68 84 64 10 f0       	push   $0xf0106484
f0103b07:	68 9b 5d 10 f0       	push   $0xf0105d9b
f0103b0c:	68 f9 00 00 00       	push   $0xf9
f0103b11:	68 b5 62 10 f0       	push   $0xf01062b5
f0103b16:	e8 ae c5 ff ff       	call   f01000c9 <_panic>
	env_run(curenv);
f0103b1b:	83 ec 0c             	sub    $0xc,%esp
f0103b1e:	50                   	push   %eax
f0103b1f:	e8 12 f8 ff ff       	call   f0103336 <env_run>

f0103b24 <vec0>:

.text
 /*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
 	TRAPHANDLER_NOEC(vec0, T_DIVIDE)
f0103b24:	6a 00                	push   $0x0
f0103b26:	6a 00                	push   $0x0
f0103b28:	eb 5a                	jmp    f0103b84 <_alltraps>

f0103b2a <vec1>:
 	TRAPHANDLER_NOEC(vec1, T_DEBUG)
f0103b2a:	6a 00                	push   $0x0
f0103b2c:	6a 01                	push   $0x1
f0103b2e:	eb 54                	jmp    f0103b84 <_alltraps>

f0103b30 <vec2>:
 	TRAPHANDLER_NOEC(vec2, T_NMI)
f0103b30:	6a 00                	push   $0x0
f0103b32:	6a 02                	push   $0x2
f0103b34:	eb 4e                	jmp    f0103b84 <_alltraps>

f0103b36 <vec3>:
 	TRAPHANDLER_NOEC(vec3, T_BRKPT)
f0103b36:	6a 00                	push   $0x0
f0103b38:	6a 03                	push   $0x3
f0103b3a:	eb 48                	jmp    f0103b84 <_alltraps>

f0103b3c <vec4>:
 	TRAPHANDLER_NOEC(vec4, T_OFLOW)
f0103b3c:	6a 00                	push   $0x0
f0103b3e:	6a 04                	push   $0x4
f0103b40:	eb 42                	jmp    f0103b84 <_alltraps>

f0103b42 <vec6>:

 	TRAPHANDLER_NOEC(vec6, T_BOUND)
f0103b42:	6a 00                	push   $0x0
f0103b44:	6a 05                	push   $0x5
f0103b46:	eb 3c                	jmp    f0103b84 <_alltraps>

f0103b48 <vec7>:
	TRAPHANDLER_NOEC(vec7, T_DEVICE)
f0103b48:	6a 00                	push   $0x0
f0103b4a:	6a 07                	push   $0x7
f0103b4c:	eb 36                	jmp    f0103b84 <_alltraps>

f0103b4e <vec8>:
 	TRAPHANDLER_NOEC(vec8, T_DBLFLT)
f0103b4e:	6a 00                	push   $0x0
f0103b50:	6a 08                	push   $0x8
f0103b52:	eb 30                	jmp    f0103b84 <_alltraps>

f0103b54 <vec10>:

 	TRAPHANDLER(vec10, T_TSS)
f0103b54:	6a 0a                	push   $0xa
f0103b56:	eb 2c                	jmp    f0103b84 <_alltraps>

f0103b58 <vec11>:
 	TRAPHANDLER(vec11, T_SEGNP)
f0103b58:	6a 0b                	push   $0xb
f0103b5a:	eb 28                	jmp    f0103b84 <_alltraps>

f0103b5c <vec12>:
 	TRAPHANDLER(vec12, T_STACK)
f0103b5c:	6a 0c                	push   $0xc
f0103b5e:	eb 24                	jmp    f0103b84 <_alltraps>

f0103b60 <vec13>:
 	TRAPHANDLER(vec13, T_GPFLT)
f0103b60:	6a 0d                	push   $0xd
f0103b62:	eb 20                	jmp    f0103b84 <_alltraps>

f0103b64 <vec14>:
 	TRAPHANDLER(vec14, T_PGFLT) 
f0103b64:	6a 0e                	push   $0xe
f0103b66:	eb 1c                	jmp    f0103b84 <_alltraps>

f0103b68 <vec16>:

 	TRAPHANDLER_NOEC(vec16, T_FPERR)
f0103b68:	6a 00                	push   $0x0
f0103b6a:	6a 10                	push   $0x10
f0103b6c:	eb 16                	jmp    f0103b84 <_alltraps>

f0103b6e <vec17>:
 	TRAPHANDLER(vec17, T_ALIGN)
f0103b6e:	6a 11                	push   $0x11
f0103b70:	eb 12                	jmp    f0103b84 <_alltraps>

f0103b72 <vec18>:
 	TRAPHANDLER_NOEC(vec18, T_MCHK)
f0103b72:	6a 00                	push   $0x0
f0103b74:	6a 12                	push   $0x12
f0103b76:	eb 0c                	jmp    f0103b84 <_alltraps>

f0103b78 <vec19>:
 	TRAPHANDLER_NOEC(vec19, T_SIMDERR)
f0103b78:	6a 00                	push   $0x0
f0103b7a:	6a 13                	push   $0x13
f0103b7c:	eb 06                	jmp    f0103b84 <_alltraps>

f0103b7e <vec48>:
    
    TRAPHANDLER_NOEC(vec48, T_SYSCALL)
f0103b7e:	6a 00                	push   $0x0
f0103b80:	6a 30                	push   $0x30
f0103b82:	eb 00                	jmp    f0103b84 <_alltraps>

f0103b84 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f0103b84:	1e                   	push   %ds
	pushl %es
f0103b85:	06                   	push   %es
	pushal
f0103b86:	60                   	pusha  

	movl $GD_KD, %eax
f0103b87:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f0103b8c:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0103b8e:	8e c0                	mov    %eax,%es

	pushl %esp
f0103b90:	54                   	push   %esp
	call trap
f0103b91:	e8 23 fe ff ff       	call   f01039b9 <trap>
	...

f0103b98 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103b98:	55                   	push   %ebp
f0103b99:	89 e5                	mov    %esp,%ebp
f0103b9b:	56                   	push   %esi
f0103b9c:	53                   	push   %ebx
f0103b9d:	83 ec 18             	sub    $0x18,%esp
f0103ba0:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103ba3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
    cprintf("%d\n", syscallno);
f0103ba6:	53                   	push   %ebx
f0103ba7:	68 ec 62 10 f0       	push   $0xf01062ec
f0103bac:	e8 48 f8 ff ff       	call   f01033f9 <cprintf>

    switch (syscallno) {
f0103bb1:	83 c4 10             	add    $0x10,%esp
f0103bb4:	83 fb 01             	cmp    $0x1,%ebx
f0103bb7:	74 3f                	je     f0103bf8 <syscall+0x60>
f0103bb9:	83 fb 01             	cmp    $0x1,%ebx
f0103bbc:	72 10                	jb     f0103bce <syscall+0x36>
f0103bbe:	83 fb 02             	cmp    $0x2,%ebx
f0103bc1:	74 3f                	je     f0103c02 <syscall+0x6a>
f0103bc3:	83 fb 03             	cmp    $0x3,%ebx
f0103bc6:	0f 85 a3 00 00 00    	jne    f0103c6f <syscall+0xd7>
f0103bcc:	eb 3e                	jmp    f0103c0c <syscall+0x74>

	// LAB 3: Your code here.
    

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103bce:	83 ec 04             	sub    $0x4,%esp
f0103bd1:	56                   	push   %esi
f0103bd2:	ff 75 10             	pushl  0x10(%ebp)
f0103bd5:	68 95 4f 10 f0       	push   $0xf0104f95
f0103bda:	e8 1a f8 ff ff       	call   f01033f9 <cprintf>
    cprintf("%d\n", syscallno);

    switch (syscallno) {
        case SYS_cputs:
            sys_cputs((char *)a1, (size_t)a2);
            cprintf("over sys cputs\n");
f0103bdf:	c7 04 24 10 65 10 f0 	movl   $0xf0106510,(%esp)
f0103be6:	e8 0e f8 ff ff       	call   f01033f9 <cprintf>
            return 0;
f0103beb:	83 c4 10             	add    $0x10,%esp
f0103bee:	b8 00 00 00 00       	mov    $0x0,%eax
f0103bf3:	e9 8b 00 00 00       	jmp    f0103c83 <syscall+0xeb>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0103bf8:	e8 c3 c8 ff ff       	call   f01004c0 <cons_getc>
            sys_cputs((char *)a1, (size_t)a2);
            cprintf("over sys cputs\n");
            return 0;
            break;
        case SYS_cgetc:
            return sys_cgetc();
f0103bfd:	e9 81 00 00 00       	jmp    f0103c83 <syscall+0xeb>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0103c02:	a1 bc 72 1d f0       	mov    0xf01d72bc,%eax
f0103c07:	8b 40 48             	mov    0x48(%eax),%eax
        case SYS_cgetc:
            return sys_cgetc();
            return 0;
            break;
        case SYS_getenvid:
            return sys_getenvid();
f0103c0a:	eb 77                	jmp    f0103c83 <syscall+0xeb>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0103c0c:	83 ec 04             	sub    $0x4,%esp
f0103c0f:	6a 01                	push   $0x1
f0103c11:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103c14:	50                   	push   %eax
f0103c15:	56                   	push   %esi
f0103c16:	e8 29 f1 ff ff       	call   f0102d44 <envid2env>
f0103c1b:	83 c4 10             	add    $0x10,%esp
f0103c1e:	85 c0                	test   %eax,%eax
f0103c20:	78 61                	js     f0103c83 <syscall+0xeb>
		return r;
	if (e == curenv)
f0103c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103c25:	8b 15 bc 72 1d f0    	mov    0xf01d72bc,%edx
f0103c2b:	39 d0                	cmp    %edx,%eax
f0103c2d:	75 15                	jne    f0103c44 <syscall+0xac>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103c2f:	83 ec 08             	sub    $0x8,%esp
f0103c32:	ff 70 48             	pushl  0x48(%eax)
f0103c35:	68 20 65 10 f0       	push   $0xf0106520
f0103c3a:	e8 ba f7 ff ff       	call   f01033f9 <cprintf>
f0103c3f:	83 c4 10             	add    $0x10,%esp
f0103c42:	eb 16                	jmp    f0103c5a <syscall+0xc2>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103c44:	83 ec 04             	sub    $0x4,%esp
f0103c47:	ff 70 48             	pushl  0x48(%eax)
f0103c4a:	ff 72 48             	pushl  0x48(%edx)
f0103c4d:	68 3b 65 10 f0       	push   $0xf010653b
f0103c52:	e8 a2 f7 ff ff       	call   f01033f9 <cprintf>
f0103c57:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0103c5a:	83 ec 0c             	sub    $0xc,%esp
f0103c5d:	ff 75 f4             	pushl  -0xc(%ebp)
f0103c60:	e8 81 f6 ff ff       	call   f01032e6 <env_destroy>
f0103c65:	83 c4 10             	add    $0x10,%esp
	return 0;
f0103c68:	b8 00 00 00 00       	mov    $0x0,%eax
            break;
        case SYS_getenvid:
            return sys_getenvid();
            break;
        case SYS_env_destroy:
            return sys_env_destroy(a1);
f0103c6d:	eb 14                	jmp    f0103c83 <syscall+0xeb>
            break;
        dafult:
            return -E_INVAL;
	}
    panic("syscall not implemented");
f0103c6f:	83 ec 04             	sub    $0x4,%esp
f0103c72:	68 53 65 10 f0       	push   $0xf0106553
f0103c77:	6a 5e                	push   $0x5e
f0103c79:	68 6b 65 10 f0       	push   $0xf010656b
f0103c7e:	e8 46 c4 ff ff       	call   f01000c9 <_panic>
}
f0103c83:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103c86:	5b                   	pop    %ebx
f0103c87:	5e                   	pop    %esi
f0103c88:	c9                   	leave  
f0103c89:	c3                   	ret    
	...

f0103c8c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103c8c:	55                   	push   %ebp
f0103c8d:	89 e5                	mov    %esp,%ebp
f0103c8f:	57                   	push   %edi
f0103c90:	56                   	push   %esi
f0103c91:	53                   	push   %ebx
f0103c92:	83 ec 14             	sub    $0x14,%esp
f0103c95:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103c98:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103c9b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103c9e:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103ca1:	8b 1a                	mov    (%edx),%ebx
f0103ca3:	8b 01                	mov    (%ecx),%eax
f0103ca5:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0103ca8:	39 c3                	cmp    %eax,%ebx
f0103caa:	0f 8f 97 00 00 00    	jg     f0103d47 <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0103cb0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103cb7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103cba:	01 d8                	add    %ebx,%eax
f0103cbc:	89 c7                	mov    %eax,%edi
f0103cbe:	c1 ef 1f             	shr    $0x1f,%edi
f0103cc1:	01 c7                	add    %eax,%edi
f0103cc3:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103cc5:	39 df                	cmp    %ebx,%edi
f0103cc7:	7c 31                	jl     f0103cfa <stab_binsearch+0x6e>
f0103cc9:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103ccc:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103ccf:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0103cd4:	39 f0                	cmp    %esi,%eax
f0103cd6:	0f 84 b3 00 00 00    	je     f0103d8f <stab_binsearch+0x103>
f0103cdc:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103ce0:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103ce4:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103ce6:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103ce7:	39 d8                	cmp    %ebx,%eax
f0103ce9:	7c 0f                	jl     f0103cfa <stab_binsearch+0x6e>
f0103ceb:	0f b6 0a             	movzbl (%edx),%ecx
f0103cee:	83 ea 0c             	sub    $0xc,%edx
f0103cf1:	39 f1                	cmp    %esi,%ecx
f0103cf3:	75 f1                	jne    f0103ce6 <stab_binsearch+0x5a>
f0103cf5:	e9 97 00 00 00       	jmp    f0103d91 <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103cfa:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103cfd:	eb 39                	jmp    f0103d38 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103cff:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103d02:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0103d04:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103d07:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103d0e:	eb 28                	jmp    f0103d38 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103d10:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103d13:	76 12                	jbe    f0103d27 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0103d15:	48                   	dec    %eax
f0103d16:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103d19:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103d1c:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103d1e:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103d25:	eb 11                	jmp    f0103d38 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103d27:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103d2a:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0103d2c:	ff 45 0c             	incl   0xc(%ebp)
f0103d2f:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103d31:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103d38:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0103d3b:	0f 8d 76 ff ff ff    	jge    f0103cb7 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103d41:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103d45:	75 0d                	jne    f0103d54 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f0103d47:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103d4a:	8b 03                	mov    (%ebx),%eax
f0103d4c:	48                   	dec    %eax
f0103d4d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103d50:	89 02                	mov    %eax,(%edx)
f0103d52:	eb 55                	jmp    f0103da9 <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103d54:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103d57:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103d59:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103d5c:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103d5e:	39 c1                	cmp    %eax,%ecx
f0103d60:	7d 26                	jge    f0103d88 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0103d62:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103d65:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0103d68:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0103d6d:	39 f2                	cmp    %esi,%edx
f0103d6f:	74 17                	je     f0103d88 <stab_binsearch+0xfc>
f0103d71:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103d75:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103d79:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103d7a:	39 c1                	cmp    %eax,%ecx
f0103d7c:	7d 0a                	jge    f0103d88 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0103d7e:	0f b6 1a             	movzbl (%edx),%ebx
f0103d81:	83 ea 0c             	sub    $0xc,%edx
f0103d84:	39 f3                	cmp    %esi,%ebx
f0103d86:	75 f1                	jne    f0103d79 <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103d88:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103d8b:	89 02                	mov    %eax,(%edx)
f0103d8d:	eb 1a                	jmp    f0103da9 <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103d8f:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103d91:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103d94:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0103d97:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103d9b:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103d9e:	0f 82 5b ff ff ff    	jb     f0103cff <stab_binsearch+0x73>
f0103da4:	e9 67 ff ff ff       	jmp    f0103d10 <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103da9:	83 c4 14             	add    $0x14,%esp
f0103dac:	5b                   	pop    %ebx
f0103dad:	5e                   	pop    %esi
f0103dae:	5f                   	pop    %edi
f0103daf:	c9                   	leave  
f0103db0:	c3                   	ret    

f0103db1 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103db1:	55                   	push   %ebp
f0103db2:	89 e5                	mov    %esp,%ebp
f0103db4:	57                   	push   %edi
f0103db5:	56                   	push   %esi
f0103db6:	53                   	push   %ebx
f0103db7:	83 ec 2c             	sub    $0x2c,%esp
f0103dba:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103dbd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103dc0:	c7 03 7a 65 10 f0    	movl   $0xf010657a,(%ebx)
	info->eip_line = 0;
f0103dc6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103dcd:	c7 43 08 7a 65 10 f0 	movl   $0xf010657a,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103dd4:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103ddb:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103dde:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103de5:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0103deb:	77 1e                	ja     f0103e0b <debuginfo_eip+0x5a>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103ded:	a1 00 00 20 00       	mov    0x200000,%eax
f0103df2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stab_end = usd->stab_end;
f0103df5:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0103dfa:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0103e00:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		stabstr_end = usd->stabstr_end;
f0103e03:	8b 35 0c 00 20 00    	mov    0x20000c,%esi
f0103e09:	eb 18                	jmp    f0103e23 <debuginfo_eip+0x72>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103e0b:	be ba 7f 11 f0       	mov    $0xf0117fba,%esi

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103e10:	c7 45 d4 ed f9 10 f0 	movl   $0xf010f9ed,-0x2c(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103e17:	b8 ec f9 10 f0       	mov    $0xf010f9ec,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103e1c:	c7 45 d0 94 67 10 f0 	movl   $0xf0106794,-0x30(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103e23:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0103e26:	0f 83 5c 01 00 00    	jae    f0103f88 <debuginfo_eip+0x1d7>
f0103e2c:	80 7e ff 00          	cmpb   $0x0,-0x1(%esi)
f0103e30:	0f 85 59 01 00 00    	jne    f0103f8f <debuginfo_eip+0x1de>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103e36:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103e3d:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0103e40:	c1 f8 02             	sar    $0x2,%eax
f0103e43:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103e49:	48                   	dec    %eax
f0103e4a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103e4d:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103e50:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103e53:	57                   	push   %edi
f0103e54:	6a 64                	push   $0x64
f0103e56:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103e59:	e8 2e fe ff ff       	call   f0103c8c <stab_binsearch>
	if (lfile == 0)
f0103e5e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103e61:	83 c4 08             	add    $0x8,%esp
		return -1;
f0103e64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0103e69:	85 d2                	test   %edx,%edx
f0103e6b:	0f 84 2a 01 00 00    	je     f0103f9b <debuginfo_eip+0x1ea>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103e71:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0103e74:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103e77:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103e7a:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103e7d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103e80:	57                   	push   %edi
f0103e81:	6a 24                	push   $0x24
f0103e83:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103e86:	e8 01 fe ff ff       	call   f0103c8c <stab_binsearch>

	if (lfun <= rfun) {
f0103e8b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103e8e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0103e91:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103e94:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0103e97:	83 c4 08             	add    $0x8,%esp
f0103e9a:	39 c1                	cmp    %eax,%ecx
f0103e9c:	7f 21                	jg     f0103ebf <debuginfo_eip+0x10e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103e9e:	6b c1 0c             	imul   $0xc,%ecx,%eax
f0103ea1:	03 45 d0             	add    -0x30(%ebp),%eax
f0103ea4:	8b 10                	mov    (%eax),%edx
f0103ea6:	89 f1                	mov    %esi,%ecx
f0103ea8:	2b 4d d4             	sub    -0x2c(%ebp),%ecx
f0103eab:	39 ca                	cmp    %ecx,%edx
f0103ead:	73 06                	jae    f0103eb5 <debuginfo_eip+0x104>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103eaf:	03 55 d4             	add    -0x2c(%ebp),%edx
f0103eb2:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103eb5:	8b 40 08             	mov    0x8(%eax),%eax
f0103eb8:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103ebb:	29 c7                	sub    %eax,%edi
f0103ebd:	eb 0f                	jmp    f0103ece <debuginfo_eip+0x11d>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103ebf:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0103ec2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103ec5:	89 55 cc             	mov    %edx,-0x34(%ebp)
		rline = rfile;
f0103ec8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103ecb:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103ece:	83 ec 08             	sub    $0x8,%esp
f0103ed1:	6a 3a                	push   $0x3a
f0103ed3:	ff 73 08             	pushl  0x8(%ebx)
f0103ed6:	e8 a4 08 00 00       	call   f010477f <strfind>
f0103edb:	2b 43 08             	sub    0x8(%ebx),%eax
f0103ede:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f0103ee1:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103ee4:	89 45 dc             	mov    %eax,-0x24(%ebp)
    rfun = rline;
f0103ee7:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0103eea:	89 55 d8             	mov    %edx,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0103eed:	83 c4 08             	add    $0x8,%esp
f0103ef0:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103ef3:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103ef6:	57                   	push   %edi
f0103ef7:	6a 44                	push   $0x44
f0103ef9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103efc:	e8 8b fd ff ff       	call   f0103c8c <stab_binsearch>
    if (lfun <= rfun) {
f0103f01:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103f04:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0103f07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f0103f0c:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f0103f0f:	0f 8f 86 00 00 00    	jg     f0103f9b <debuginfo_eip+0x1ea>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f0103f15:	6b ca 0c             	imul   $0xc,%edx,%ecx
f0103f18:	03 4d d0             	add    -0x30(%ebp),%ecx
f0103f1b:	0f b7 41 06          	movzwl 0x6(%ecx),%eax
f0103f1f:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103f22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103f25:	89 45 cc             	mov    %eax,-0x34(%ebp)
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103f28:	8d 41 08             	lea    0x8(%ecx),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103f2b:	eb 04                	jmp    f0103f31 <debuginfo_eip+0x180>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103f2d:	4a                   	dec    %edx
f0103f2e:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103f31:	3b 55 cc             	cmp    -0x34(%ebp),%edx
f0103f34:	7c 19                	jl     f0103f4f <debuginfo_eip+0x19e>
	       && stabs[lline].n_type != N_SOL
f0103f36:	8a 48 fc             	mov    -0x4(%eax),%cl
f0103f39:	80 f9 84             	cmp    $0x84,%cl
f0103f3c:	74 65                	je     f0103fa3 <debuginfo_eip+0x1f2>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103f3e:	80 f9 64             	cmp    $0x64,%cl
f0103f41:	75 ea                	jne    f0103f2d <debuginfo_eip+0x17c>
f0103f43:	83 38 00             	cmpl   $0x0,(%eax)
f0103f46:	74 e5                	je     f0103f2d <debuginfo_eip+0x17c>
f0103f48:	eb 59                	jmp    f0103fa3 <debuginfo_eip+0x1f2>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103f4a:	03 45 d4             	add    -0x2c(%ebp),%eax
f0103f4d:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103f4f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103f52:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103f55:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103f5a:	39 ca                	cmp    %ecx,%edx
f0103f5c:	7d 3d                	jge    f0103f9b <debuginfo_eip+0x1ea>
		for (lline = lfun + 1;
f0103f5e:	8d 42 01             	lea    0x1(%edx),%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103f61:	6b d0 0c             	imul   $0xc,%eax,%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103f64:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103f67:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f0103f6b:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103f6d:	eb 04                	jmp    f0103f73 <debuginfo_eip+0x1c2>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103f6f:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0103f72:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103f73:	39 f0                	cmp    %esi,%eax
f0103f75:	7d 1f                	jge    f0103f96 <debuginfo_eip+0x1e5>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103f77:	8a 0a                	mov    (%edx),%cl
f0103f79:	83 c2 0c             	add    $0xc,%edx
f0103f7c:	80 f9 a0             	cmp    $0xa0,%cl
f0103f7f:	74 ee                	je     f0103f6f <debuginfo_eip+0x1be>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103f81:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f86:	eb 13                	jmp    f0103f9b <debuginfo_eip+0x1ea>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103f88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103f8d:	eb 0c                	jmp    f0103f9b <debuginfo_eip+0x1ea>
f0103f8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103f94:	eb 05                	jmp    f0103f9b <debuginfo_eip+0x1ea>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103f96:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103f9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f9e:	5b                   	pop    %ebx
f0103f9f:	5e                   	pop    %esi
f0103fa0:	5f                   	pop    %edi
f0103fa1:	c9                   	leave  
f0103fa2:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103fa3:	6b d2 0c             	imul   $0xc,%edx,%edx
f0103fa6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103fa9:	8b 04 11             	mov    (%ecx,%edx,1),%eax
f0103fac:	2b 75 d4             	sub    -0x2c(%ebp),%esi
f0103faf:	39 f0                	cmp    %esi,%eax
f0103fb1:	72 97                	jb     f0103f4a <debuginfo_eip+0x199>
f0103fb3:	eb 9a                	jmp    f0103f4f <debuginfo_eip+0x19e>
f0103fb5:	00 00                	add    %al,(%eax)
	...

f0103fb8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103fb8:	55                   	push   %ebp
f0103fb9:	89 e5                	mov    %esp,%ebp
f0103fbb:	57                   	push   %edi
f0103fbc:	56                   	push   %esi
f0103fbd:	53                   	push   %ebx
f0103fbe:	83 ec 2c             	sub    $0x2c,%esp
f0103fc1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103fc4:	89 d6                	mov    %edx,%esi
f0103fc6:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fc9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103fcc:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103fcf:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103fd2:	8b 45 10             	mov    0x10(%ebp),%eax
f0103fd5:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0103fd8:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103fdb:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103fde:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0103fe5:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0103fe8:	72 0c                	jb     f0103ff6 <printnum+0x3e>
f0103fea:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0103fed:	76 07                	jbe    f0103ff6 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103fef:	4b                   	dec    %ebx
f0103ff0:	85 db                	test   %ebx,%ebx
f0103ff2:	7f 31                	jg     f0104025 <printnum+0x6d>
f0103ff4:	eb 3f                	jmp    f0104035 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103ff6:	83 ec 0c             	sub    $0xc,%esp
f0103ff9:	57                   	push   %edi
f0103ffa:	4b                   	dec    %ebx
f0103ffb:	53                   	push   %ebx
f0103ffc:	50                   	push   %eax
f0103ffd:	83 ec 08             	sub    $0x8,%esp
f0104000:	ff 75 d4             	pushl  -0x2c(%ebp)
f0104003:	ff 75 d0             	pushl  -0x30(%ebp)
f0104006:	ff 75 dc             	pushl  -0x24(%ebp)
f0104009:	ff 75 d8             	pushl  -0x28(%ebp)
f010400c:	e8 97 09 00 00       	call   f01049a8 <__udivdi3>
f0104011:	83 c4 18             	add    $0x18,%esp
f0104014:	52                   	push   %edx
f0104015:	50                   	push   %eax
f0104016:	89 f2                	mov    %esi,%edx
f0104018:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010401b:	e8 98 ff ff ff       	call   f0103fb8 <printnum>
f0104020:	83 c4 20             	add    $0x20,%esp
f0104023:	eb 10                	jmp    f0104035 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104025:	83 ec 08             	sub    $0x8,%esp
f0104028:	56                   	push   %esi
f0104029:	57                   	push   %edi
f010402a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010402d:	4b                   	dec    %ebx
f010402e:	83 c4 10             	add    $0x10,%esp
f0104031:	85 db                	test   %ebx,%ebx
f0104033:	7f f0                	jg     f0104025 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104035:	83 ec 08             	sub    $0x8,%esp
f0104038:	56                   	push   %esi
f0104039:	83 ec 04             	sub    $0x4,%esp
f010403c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010403f:	ff 75 d0             	pushl  -0x30(%ebp)
f0104042:	ff 75 dc             	pushl  -0x24(%ebp)
f0104045:	ff 75 d8             	pushl  -0x28(%ebp)
f0104048:	e8 77 0a 00 00       	call   f0104ac4 <__umoddi3>
f010404d:	83 c4 14             	add    $0x14,%esp
f0104050:	0f be 80 84 65 10 f0 	movsbl -0xfef9a7c(%eax),%eax
f0104057:	50                   	push   %eax
f0104058:	ff 55 e4             	call   *-0x1c(%ebp)
f010405b:	83 c4 10             	add    $0x10,%esp
}
f010405e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104061:	5b                   	pop    %ebx
f0104062:	5e                   	pop    %esi
f0104063:	5f                   	pop    %edi
f0104064:	c9                   	leave  
f0104065:	c3                   	ret    

f0104066 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104066:	55                   	push   %ebp
f0104067:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104069:	83 fa 01             	cmp    $0x1,%edx
f010406c:	7e 0e                	jle    f010407c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010406e:	8b 10                	mov    (%eax),%edx
f0104070:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104073:	89 08                	mov    %ecx,(%eax)
f0104075:	8b 02                	mov    (%edx),%eax
f0104077:	8b 52 04             	mov    0x4(%edx),%edx
f010407a:	eb 22                	jmp    f010409e <getuint+0x38>
	else if (lflag)
f010407c:	85 d2                	test   %edx,%edx
f010407e:	74 10                	je     f0104090 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104080:	8b 10                	mov    (%eax),%edx
f0104082:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104085:	89 08                	mov    %ecx,(%eax)
f0104087:	8b 02                	mov    (%edx),%eax
f0104089:	ba 00 00 00 00       	mov    $0x0,%edx
f010408e:	eb 0e                	jmp    f010409e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104090:	8b 10                	mov    (%eax),%edx
f0104092:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104095:	89 08                	mov    %ecx,(%eax)
f0104097:	8b 02                	mov    (%edx),%eax
f0104099:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010409e:	c9                   	leave  
f010409f:	c3                   	ret    

f01040a0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f01040a0:	55                   	push   %ebp
f01040a1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01040a3:	83 fa 01             	cmp    $0x1,%edx
f01040a6:	7e 0e                	jle    f01040b6 <getint+0x16>
		return va_arg(*ap, long long);
f01040a8:	8b 10                	mov    (%eax),%edx
f01040aa:	8d 4a 08             	lea    0x8(%edx),%ecx
f01040ad:	89 08                	mov    %ecx,(%eax)
f01040af:	8b 02                	mov    (%edx),%eax
f01040b1:	8b 52 04             	mov    0x4(%edx),%edx
f01040b4:	eb 1a                	jmp    f01040d0 <getint+0x30>
	else if (lflag)
f01040b6:	85 d2                	test   %edx,%edx
f01040b8:	74 0c                	je     f01040c6 <getint+0x26>
		return va_arg(*ap, long);
f01040ba:	8b 10                	mov    (%eax),%edx
f01040bc:	8d 4a 04             	lea    0x4(%edx),%ecx
f01040bf:	89 08                	mov    %ecx,(%eax)
f01040c1:	8b 02                	mov    (%edx),%eax
f01040c3:	99                   	cltd   
f01040c4:	eb 0a                	jmp    f01040d0 <getint+0x30>
	else
		return va_arg(*ap, int);
f01040c6:	8b 10                	mov    (%eax),%edx
f01040c8:	8d 4a 04             	lea    0x4(%edx),%ecx
f01040cb:	89 08                	mov    %ecx,(%eax)
f01040cd:	8b 02                	mov    (%edx),%eax
f01040cf:	99                   	cltd   
}
f01040d0:	c9                   	leave  
f01040d1:	c3                   	ret    

f01040d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01040d2:	55                   	push   %ebp
f01040d3:	89 e5                	mov    %esp,%ebp
f01040d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01040d8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f01040db:	8b 10                	mov    (%eax),%edx
f01040dd:	3b 50 04             	cmp    0x4(%eax),%edx
f01040e0:	73 08                	jae    f01040ea <sprintputch+0x18>
		*b->buf++ = ch;
f01040e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01040e5:	88 0a                	mov    %cl,(%edx)
f01040e7:	42                   	inc    %edx
f01040e8:	89 10                	mov    %edx,(%eax)
}
f01040ea:	c9                   	leave  
f01040eb:	c3                   	ret    

f01040ec <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01040ec:	55                   	push   %ebp
f01040ed:	89 e5                	mov    %esp,%ebp
f01040ef:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01040f2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01040f5:	50                   	push   %eax
f01040f6:	ff 75 10             	pushl  0x10(%ebp)
f01040f9:	ff 75 0c             	pushl  0xc(%ebp)
f01040fc:	ff 75 08             	pushl  0x8(%ebp)
f01040ff:	e8 05 00 00 00       	call   f0104109 <vprintfmt>
	va_end(ap);
f0104104:	83 c4 10             	add    $0x10,%esp
}
f0104107:	c9                   	leave  
f0104108:	c3                   	ret    

f0104109 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104109:	55                   	push   %ebp
f010410a:	89 e5                	mov    %esp,%ebp
f010410c:	57                   	push   %edi
f010410d:	56                   	push   %esi
f010410e:	53                   	push   %ebx
f010410f:	83 ec 2c             	sub    $0x2c,%esp
f0104112:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104115:	8b 75 10             	mov    0x10(%ebp),%esi
f0104118:	eb 13                	jmp    f010412d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010411a:	85 c0                	test   %eax,%eax
f010411c:	0f 84 6d 03 00 00    	je     f010448f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f0104122:	83 ec 08             	sub    $0x8,%esp
f0104125:	57                   	push   %edi
f0104126:	50                   	push   %eax
f0104127:	ff 55 08             	call   *0x8(%ebp)
f010412a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010412d:	0f b6 06             	movzbl (%esi),%eax
f0104130:	46                   	inc    %esi
f0104131:	83 f8 25             	cmp    $0x25,%eax
f0104134:	75 e4                	jne    f010411a <vprintfmt+0x11>
f0104136:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f010413a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0104141:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0104148:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f010414f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104154:	eb 28                	jmp    f010417e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104156:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104158:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f010415c:	eb 20                	jmp    f010417e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010415e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104160:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0104164:	eb 18                	jmp    f010417e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104166:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0104168:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010416f:	eb 0d                	jmp    f010417e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0104171:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104174:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104177:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010417e:	8a 06                	mov    (%esi),%al
f0104180:	0f b6 d0             	movzbl %al,%edx
f0104183:	8d 5e 01             	lea    0x1(%esi),%ebx
f0104186:	83 e8 23             	sub    $0x23,%eax
f0104189:	3c 55                	cmp    $0x55,%al
f010418b:	0f 87 e0 02 00 00    	ja     f0104471 <vprintfmt+0x368>
f0104191:	0f b6 c0             	movzbl %al,%eax
f0104194:	ff 24 85 10 66 10 f0 	jmp    *-0xfef99f0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010419b:	83 ea 30             	sub    $0x30,%edx
f010419e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f01041a1:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f01041a4:	8d 50 d0             	lea    -0x30(%eax),%edx
f01041a7:	83 fa 09             	cmp    $0x9,%edx
f01041aa:	77 44                	ja     f01041f0 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041ac:	89 de                	mov    %ebx,%esi
f01041ae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01041b1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f01041b2:	8d 14 92             	lea    (%edx,%edx,4),%edx
f01041b5:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f01041b9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f01041bc:	8d 58 d0             	lea    -0x30(%eax),%ebx
f01041bf:	83 fb 09             	cmp    $0x9,%ebx
f01041c2:	76 ed                	jbe    f01041b1 <vprintfmt+0xa8>
f01041c4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01041c7:	eb 29                	jmp    f01041f2 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01041c9:	8b 45 14             	mov    0x14(%ebp),%eax
f01041cc:	8d 50 04             	lea    0x4(%eax),%edx
f01041cf:	89 55 14             	mov    %edx,0x14(%ebp)
f01041d2:	8b 00                	mov    (%eax),%eax
f01041d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041d7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01041d9:	eb 17                	jmp    f01041f2 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f01041db:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01041df:	78 85                	js     f0104166 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041e1:	89 de                	mov    %ebx,%esi
f01041e3:	eb 99                	jmp    f010417e <vprintfmt+0x75>
f01041e5:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01041e7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f01041ee:	eb 8e                	jmp    f010417e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041f0:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f01041f2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01041f6:	79 86                	jns    f010417e <vprintfmt+0x75>
f01041f8:	e9 74 ff ff ff       	jmp    f0104171 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01041fd:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041fe:	89 de                	mov    %ebx,%esi
f0104200:	e9 79 ff ff ff       	jmp    f010417e <vprintfmt+0x75>
f0104205:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104208:	8b 45 14             	mov    0x14(%ebp),%eax
f010420b:	8d 50 04             	lea    0x4(%eax),%edx
f010420e:	89 55 14             	mov    %edx,0x14(%ebp)
f0104211:	83 ec 08             	sub    $0x8,%esp
f0104214:	57                   	push   %edi
f0104215:	ff 30                	pushl  (%eax)
f0104217:	ff 55 08             	call   *0x8(%ebp)
			break;
f010421a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010421d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104220:	e9 08 ff ff ff       	jmp    f010412d <vprintfmt+0x24>
f0104225:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104228:	8b 45 14             	mov    0x14(%ebp),%eax
f010422b:	8d 50 04             	lea    0x4(%eax),%edx
f010422e:	89 55 14             	mov    %edx,0x14(%ebp)
f0104231:	8b 00                	mov    (%eax),%eax
f0104233:	85 c0                	test   %eax,%eax
f0104235:	79 02                	jns    f0104239 <vprintfmt+0x130>
f0104237:	f7 d8                	neg    %eax
f0104239:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010423b:	83 f8 06             	cmp    $0x6,%eax
f010423e:	7f 0b                	jg     f010424b <vprintfmt+0x142>
f0104240:	8b 04 85 68 67 10 f0 	mov    -0xfef9898(,%eax,4),%eax
f0104247:	85 c0                	test   %eax,%eax
f0104249:	75 1a                	jne    f0104265 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f010424b:	52                   	push   %edx
f010424c:	68 9c 65 10 f0       	push   $0xf010659c
f0104251:	57                   	push   %edi
f0104252:	ff 75 08             	pushl  0x8(%ebp)
f0104255:	e8 92 fe ff ff       	call   f01040ec <printfmt>
f010425a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010425d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104260:	e9 c8 fe ff ff       	jmp    f010412d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f0104265:	50                   	push   %eax
f0104266:	68 ad 5d 10 f0       	push   $0xf0105dad
f010426b:	57                   	push   %edi
f010426c:	ff 75 08             	pushl  0x8(%ebp)
f010426f:	e8 78 fe ff ff       	call   f01040ec <printfmt>
f0104274:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104277:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010427a:	e9 ae fe ff ff       	jmp    f010412d <vprintfmt+0x24>
f010427f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0104282:	89 de                	mov    %ebx,%esi
f0104284:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104287:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010428a:	8b 45 14             	mov    0x14(%ebp),%eax
f010428d:	8d 50 04             	lea    0x4(%eax),%edx
f0104290:	89 55 14             	mov    %edx,0x14(%ebp)
f0104293:	8b 00                	mov    (%eax),%eax
f0104295:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104298:	85 c0                	test   %eax,%eax
f010429a:	75 07                	jne    f01042a3 <vprintfmt+0x19a>
				p = "(null)";
f010429c:	c7 45 d0 95 65 10 f0 	movl   $0xf0106595,-0x30(%ebp)
			if (width > 0 && padc != '-')
f01042a3:	85 db                	test   %ebx,%ebx
f01042a5:	7e 42                	jle    f01042e9 <vprintfmt+0x1e0>
f01042a7:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f01042ab:	74 3c                	je     f01042e9 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f01042ad:	83 ec 08             	sub    $0x8,%esp
f01042b0:	51                   	push   %ecx
f01042b1:	ff 75 d0             	pushl  -0x30(%ebp)
f01042b4:	e8 3f 03 00 00       	call   f01045f8 <strnlen>
f01042b9:	29 c3                	sub    %eax,%ebx
f01042bb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01042be:	83 c4 10             	add    $0x10,%esp
f01042c1:	85 db                	test   %ebx,%ebx
f01042c3:	7e 24                	jle    f01042e9 <vprintfmt+0x1e0>
					putch(padc, putdat);
f01042c5:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f01042c9:	89 75 dc             	mov    %esi,-0x24(%ebp)
f01042cc:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01042cf:	83 ec 08             	sub    $0x8,%esp
f01042d2:	57                   	push   %edi
f01042d3:	53                   	push   %ebx
f01042d4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01042d7:	4e                   	dec    %esi
f01042d8:	83 c4 10             	add    $0x10,%esp
f01042db:	85 f6                	test   %esi,%esi
f01042dd:	7f f0                	jg     f01042cf <vprintfmt+0x1c6>
f01042df:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01042e2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01042e9:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01042ec:	0f be 02             	movsbl (%edx),%eax
f01042ef:	85 c0                	test   %eax,%eax
f01042f1:	75 47                	jne    f010433a <vprintfmt+0x231>
f01042f3:	eb 37                	jmp    f010432c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f01042f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01042f9:	74 16                	je     f0104311 <vprintfmt+0x208>
f01042fb:	8d 50 e0             	lea    -0x20(%eax),%edx
f01042fe:	83 fa 5e             	cmp    $0x5e,%edx
f0104301:	76 0e                	jbe    f0104311 <vprintfmt+0x208>
					putch('?', putdat);
f0104303:	83 ec 08             	sub    $0x8,%esp
f0104306:	57                   	push   %edi
f0104307:	6a 3f                	push   $0x3f
f0104309:	ff 55 08             	call   *0x8(%ebp)
f010430c:	83 c4 10             	add    $0x10,%esp
f010430f:	eb 0b                	jmp    f010431c <vprintfmt+0x213>
				else
					putch(ch, putdat);
f0104311:	83 ec 08             	sub    $0x8,%esp
f0104314:	57                   	push   %edi
f0104315:	50                   	push   %eax
f0104316:	ff 55 08             	call   *0x8(%ebp)
f0104319:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010431c:	ff 4d e4             	decl   -0x1c(%ebp)
f010431f:	0f be 03             	movsbl (%ebx),%eax
f0104322:	85 c0                	test   %eax,%eax
f0104324:	74 03                	je     f0104329 <vprintfmt+0x220>
f0104326:	43                   	inc    %ebx
f0104327:	eb 1b                	jmp    f0104344 <vprintfmt+0x23b>
f0104329:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010432c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104330:	7f 1e                	jg     f0104350 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104332:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0104335:	e9 f3 fd ff ff       	jmp    f010412d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010433a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010433d:	43                   	inc    %ebx
f010433e:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0104341:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0104344:	85 f6                	test   %esi,%esi
f0104346:	78 ad                	js     f01042f5 <vprintfmt+0x1ec>
f0104348:	4e                   	dec    %esi
f0104349:	79 aa                	jns    f01042f5 <vprintfmt+0x1ec>
f010434b:	8b 75 dc             	mov    -0x24(%ebp),%esi
f010434e:	eb dc                	jmp    f010432c <vprintfmt+0x223>
f0104350:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104353:	83 ec 08             	sub    $0x8,%esp
f0104356:	57                   	push   %edi
f0104357:	6a 20                	push   $0x20
f0104359:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010435c:	4b                   	dec    %ebx
f010435d:	83 c4 10             	add    $0x10,%esp
f0104360:	85 db                	test   %ebx,%ebx
f0104362:	7f ef                	jg     f0104353 <vprintfmt+0x24a>
f0104364:	e9 c4 fd ff ff       	jmp    f010412d <vprintfmt+0x24>
f0104369:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010436c:	89 ca                	mov    %ecx,%edx
f010436e:	8d 45 14             	lea    0x14(%ebp),%eax
f0104371:	e8 2a fd ff ff       	call   f01040a0 <getint>
f0104376:	89 c3                	mov    %eax,%ebx
f0104378:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f010437a:	85 d2                	test   %edx,%edx
f010437c:	78 0a                	js     f0104388 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010437e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104383:	e9 b0 00 00 00       	jmp    f0104438 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0104388:	83 ec 08             	sub    $0x8,%esp
f010438b:	57                   	push   %edi
f010438c:	6a 2d                	push   $0x2d
f010438e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0104391:	f7 db                	neg    %ebx
f0104393:	83 d6 00             	adc    $0x0,%esi
f0104396:	f7 de                	neg    %esi
f0104398:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010439b:	b8 0a 00 00 00       	mov    $0xa,%eax
f01043a0:	e9 93 00 00 00       	jmp    f0104438 <vprintfmt+0x32f>
f01043a5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01043a8:	89 ca                	mov    %ecx,%edx
f01043aa:	8d 45 14             	lea    0x14(%ebp),%eax
f01043ad:	e8 b4 fc ff ff       	call   f0104066 <getuint>
f01043b2:	89 c3                	mov    %eax,%ebx
f01043b4:	89 d6                	mov    %edx,%esi
			base = 10;
f01043b6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f01043bb:	eb 7b                	jmp    f0104438 <vprintfmt+0x32f>
f01043bd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f01043c0:	89 ca                	mov    %ecx,%edx
f01043c2:	8d 45 14             	lea    0x14(%ebp),%eax
f01043c5:	e8 d6 fc ff ff       	call   f01040a0 <getint>
f01043ca:	89 c3                	mov    %eax,%ebx
f01043cc:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f01043ce:	85 d2                	test   %edx,%edx
f01043d0:	78 07                	js     f01043d9 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f01043d2:	b8 08 00 00 00       	mov    $0x8,%eax
f01043d7:	eb 5f                	jmp    f0104438 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f01043d9:	83 ec 08             	sub    $0x8,%esp
f01043dc:	57                   	push   %edi
f01043dd:	6a 2d                	push   $0x2d
f01043df:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f01043e2:	f7 db                	neg    %ebx
f01043e4:	83 d6 00             	adc    $0x0,%esi
f01043e7:	f7 de                	neg    %esi
f01043e9:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f01043ec:	b8 08 00 00 00       	mov    $0x8,%eax
f01043f1:	eb 45                	jmp    f0104438 <vprintfmt+0x32f>
f01043f3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f01043f6:	83 ec 08             	sub    $0x8,%esp
f01043f9:	57                   	push   %edi
f01043fa:	6a 30                	push   $0x30
f01043fc:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01043ff:	83 c4 08             	add    $0x8,%esp
f0104402:	57                   	push   %edi
f0104403:	6a 78                	push   $0x78
f0104405:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104408:	8b 45 14             	mov    0x14(%ebp),%eax
f010440b:	8d 50 04             	lea    0x4(%eax),%edx
f010440e:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104411:	8b 18                	mov    (%eax),%ebx
f0104413:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104418:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010441b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0104420:	eb 16                	jmp    f0104438 <vprintfmt+0x32f>
f0104422:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104425:	89 ca                	mov    %ecx,%edx
f0104427:	8d 45 14             	lea    0x14(%ebp),%eax
f010442a:	e8 37 fc ff ff       	call   f0104066 <getuint>
f010442f:	89 c3                	mov    %eax,%ebx
f0104431:	89 d6                	mov    %edx,%esi
			base = 16;
f0104433:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104438:	83 ec 0c             	sub    $0xc,%esp
f010443b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f010443f:	52                   	push   %edx
f0104440:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104443:	50                   	push   %eax
f0104444:	56                   	push   %esi
f0104445:	53                   	push   %ebx
f0104446:	89 fa                	mov    %edi,%edx
f0104448:	8b 45 08             	mov    0x8(%ebp),%eax
f010444b:	e8 68 fb ff ff       	call   f0103fb8 <printnum>
			break;
f0104450:	83 c4 20             	add    $0x20,%esp
f0104453:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0104456:	e9 d2 fc ff ff       	jmp    f010412d <vprintfmt+0x24>
f010445b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010445e:	83 ec 08             	sub    $0x8,%esp
f0104461:	57                   	push   %edi
f0104462:	52                   	push   %edx
f0104463:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104466:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104469:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010446c:	e9 bc fc ff ff       	jmp    f010412d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104471:	83 ec 08             	sub    $0x8,%esp
f0104474:	57                   	push   %edi
f0104475:	6a 25                	push   $0x25
f0104477:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010447a:	83 c4 10             	add    $0x10,%esp
f010447d:	eb 02                	jmp    f0104481 <vprintfmt+0x378>
f010447f:	89 c6                	mov    %eax,%esi
f0104481:	8d 46 ff             	lea    -0x1(%esi),%eax
f0104484:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0104488:	75 f5                	jne    f010447f <vprintfmt+0x376>
f010448a:	e9 9e fc ff ff       	jmp    f010412d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f010448f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104492:	5b                   	pop    %ebx
f0104493:	5e                   	pop    %esi
f0104494:	5f                   	pop    %edi
f0104495:	c9                   	leave  
f0104496:	c3                   	ret    

f0104497 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104497:	55                   	push   %ebp
f0104498:	89 e5                	mov    %esp,%ebp
f010449a:	83 ec 18             	sub    $0x18,%esp
f010449d:	8b 45 08             	mov    0x8(%ebp),%eax
f01044a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01044a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01044a6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01044aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01044ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01044b4:	85 c0                	test   %eax,%eax
f01044b6:	74 26                	je     f01044de <vsnprintf+0x47>
f01044b8:	85 d2                	test   %edx,%edx
f01044ba:	7e 29                	jle    f01044e5 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01044bc:	ff 75 14             	pushl  0x14(%ebp)
f01044bf:	ff 75 10             	pushl  0x10(%ebp)
f01044c2:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01044c5:	50                   	push   %eax
f01044c6:	68 d2 40 10 f0       	push   $0xf01040d2
f01044cb:	e8 39 fc ff ff       	call   f0104109 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01044d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01044d3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01044d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01044d9:	83 c4 10             	add    $0x10,%esp
f01044dc:	eb 0c                	jmp    f01044ea <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01044de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01044e3:	eb 05                	jmp    f01044ea <vsnprintf+0x53>
f01044e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01044ea:	c9                   	leave  
f01044eb:	c3                   	ret    

f01044ec <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01044ec:	55                   	push   %ebp
f01044ed:	89 e5                	mov    %esp,%ebp
f01044ef:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01044f2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01044f5:	50                   	push   %eax
f01044f6:	ff 75 10             	pushl  0x10(%ebp)
f01044f9:	ff 75 0c             	pushl  0xc(%ebp)
f01044fc:	ff 75 08             	pushl  0x8(%ebp)
f01044ff:	e8 93 ff ff ff       	call   f0104497 <vsnprintf>
	va_end(ap);

	return rc;
}
f0104504:	c9                   	leave  
f0104505:	c3                   	ret    
	...

f0104508 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104508:	55                   	push   %ebp
f0104509:	89 e5                	mov    %esp,%ebp
f010450b:	57                   	push   %edi
f010450c:	56                   	push   %esi
f010450d:	53                   	push   %ebx
f010450e:	83 ec 0c             	sub    $0xc,%esp
f0104511:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104514:	85 c0                	test   %eax,%eax
f0104516:	74 11                	je     f0104529 <readline+0x21>
		cprintf("%s", prompt);
f0104518:	83 ec 08             	sub    $0x8,%esp
f010451b:	50                   	push   %eax
f010451c:	68 ad 5d 10 f0       	push   $0xf0105dad
f0104521:	e8 d3 ee ff ff       	call   f01033f9 <cprintf>
f0104526:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104529:	83 ec 0c             	sub    $0xc,%esp
f010452c:	6a 00                	push   $0x0
f010452e:	e8 d4 c0 ff ff       	call   f0100607 <iscons>
f0104533:	89 c7                	mov    %eax,%edi
f0104535:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0104538:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010453d:	e8 b4 c0 ff ff       	call   f01005f6 <getchar>
f0104542:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104544:	85 c0                	test   %eax,%eax
f0104546:	79 18                	jns    f0104560 <readline+0x58>
			cprintf("read error: %e\n", c);
f0104548:	83 ec 08             	sub    $0x8,%esp
f010454b:	50                   	push   %eax
f010454c:	68 84 67 10 f0       	push   $0xf0106784
f0104551:	e8 a3 ee ff ff       	call   f01033f9 <cprintf>
			return NULL;
f0104556:	83 c4 10             	add    $0x10,%esp
f0104559:	b8 00 00 00 00       	mov    $0x0,%eax
f010455e:	eb 6f                	jmp    f01045cf <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104560:	83 f8 08             	cmp    $0x8,%eax
f0104563:	74 05                	je     f010456a <readline+0x62>
f0104565:	83 f8 7f             	cmp    $0x7f,%eax
f0104568:	75 18                	jne    f0104582 <readline+0x7a>
f010456a:	85 f6                	test   %esi,%esi
f010456c:	7e 14                	jle    f0104582 <readline+0x7a>
			if (echoing)
f010456e:	85 ff                	test   %edi,%edi
f0104570:	74 0d                	je     f010457f <readline+0x77>
				cputchar('\b');
f0104572:	83 ec 0c             	sub    $0xc,%esp
f0104575:	6a 08                	push   $0x8
f0104577:	e8 6a c0 ff ff       	call   f01005e6 <cputchar>
f010457c:	83 c4 10             	add    $0x10,%esp
			i--;
f010457f:	4e                   	dec    %esi
f0104580:	eb bb                	jmp    f010453d <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104582:	83 fb 1f             	cmp    $0x1f,%ebx
f0104585:	7e 21                	jle    f01045a8 <readline+0xa0>
f0104587:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010458d:	7f 19                	jg     f01045a8 <readline+0xa0>
			if (echoing)
f010458f:	85 ff                	test   %edi,%edi
f0104591:	74 0c                	je     f010459f <readline+0x97>
				cputchar(c);
f0104593:	83 ec 0c             	sub    $0xc,%esp
f0104596:	53                   	push   %ebx
f0104597:	e8 4a c0 ff ff       	call   f01005e6 <cputchar>
f010459c:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010459f:	88 9e 80 7b 1d f0    	mov    %bl,-0xfe28480(%esi)
f01045a5:	46                   	inc    %esi
f01045a6:	eb 95                	jmp    f010453d <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01045a8:	83 fb 0a             	cmp    $0xa,%ebx
f01045ab:	74 05                	je     f01045b2 <readline+0xaa>
f01045ad:	83 fb 0d             	cmp    $0xd,%ebx
f01045b0:	75 8b                	jne    f010453d <readline+0x35>
			if (echoing)
f01045b2:	85 ff                	test   %edi,%edi
f01045b4:	74 0d                	je     f01045c3 <readline+0xbb>
				cputchar('\n');
f01045b6:	83 ec 0c             	sub    $0xc,%esp
f01045b9:	6a 0a                	push   $0xa
f01045bb:	e8 26 c0 ff ff       	call   f01005e6 <cputchar>
f01045c0:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01045c3:	c6 86 80 7b 1d f0 00 	movb   $0x0,-0xfe28480(%esi)
			return buf;
f01045ca:	b8 80 7b 1d f0       	mov    $0xf01d7b80,%eax
		}
	}
}
f01045cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01045d2:	5b                   	pop    %ebx
f01045d3:	5e                   	pop    %esi
f01045d4:	5f                   	pop    %edi
f01045d5:	c9                   	leave  
f01045d6:	c3                   	ret    
	...

f01045d8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01045d8:	55                   	push   %ebp
f01045d9:	89 e5                	mov    %esp,%ebp
f01045db:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01045de:	80 3a 00             	cmpb   $0x0,(%edx)
f01045e1:	74 0e                	je     f01045f1 <strlen+0x19>
f01045e3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01045e8:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01045e9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01045ed:	75 f9                	jne    f01045e8 <strlen+0x10>
f01045ef:	eb 05                	jmp    f01045f6 <strlen+0x1e>
f01045f1:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01045f6:	c9                   	leave  
f01045f7:	c3                   	ret    

f01045f8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01045f8:	55                   	push   %ebp
f01045f9:	89 e5                	mov    %esp,%ebp
f01045fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01045fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104601:	85 d2                	test   %edx,%edx
f0104603:	74 17                	je     f010461c <strnlen+0x24>
f0104605:	80 39 00             	cmpb   $0x0,(%ecx)
f0104608:	74 19                	je     f0104623 <strnlen+0x2b>
f010460a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f010460f:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104610:	39 d0                	cmp    %edx,%eax
f0104612:	74 14                	je     f0104628 <strnlen+0x30>
f0104614:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0104618:	75 f5                	jne    f010460f <strnlen+0x17>
f010461a:	eb 0c                	jmp    f0104628 <strnlen+0x30>
f010461c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104621:	eb 05                	jmp    f0104628 <strnlen+0x30>
f0104623:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0104628:	c9                   	leave  
f0104629:	c3                   	ret    

f010462a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010462a:	55                   	push   %ebp
f010462b:	89 e5                	mov    %esp,%ebp
f010462d:	53                   	push   %ebx
f010462e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104631:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104634:	ba 00 00 00 00       	mov    $0x0,%edx
f0104639:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f010463c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f010463f:	42                   	inc    %edx
f0104640:	84 c9                	test   %cl,%cl
f0104642:	75 f5                	jne    f0104639 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104644:	5b                   	pop    %ebx
f0104645:	c9                   	leave  
f0104646:	c3                   	ret    

f0104647 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104647:	55                   	push   %ebp
f0104648:	89 e5                	mov    %esp,%ebp
f010464a:	53                   	push   %ebx
f010464b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010464e:	53                   	push   %ebx
f010464f:	e8 84 ff ff ff       	call   f01045d8 <strlen>
f0104654:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0104657:	ff 75 0c             	pushl  0xc(%ebp)
f010465a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f010465d:	50                   	push   %eax
f010465e:	e8 c7 ff ff ff       	call   f010462a <strcpy>
	return dst;
}
f0104663:	89 d8                	mov    %ebx,%eax
f0104665:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104668:	c9                   	leave  
f0104669:	c3                   	ret    

f010466a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010466a:	55                   	push   %ebp
f010466b:	89 e5                	mov    %esp,%ebp
f010466d:	56                   	push   %esi
f010466e:	53                   	push   %ebx
f010466f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104672:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104675:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104678:	85 f6                	test   %esi,%esi
f010467a:	74 15                	je     f0104691 <strncpy+0x27>
f010467c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0104681:	8a 1a                	mov    (%edx),%bl
f0104683:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104686:	80 3a 01             	cmpb   $0x1,(%edx)
f0104689:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010468c:	41                   	inc    %ecx
f010468d:	39 ce                	cmp    %ecx,%esi
f010468f:	77 f0                	ja     f0104681 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104691:	5b                   	pop    %ebx
f0104692:	5e                   	pop    %esi
f0104693:	c9                   	leave  
f0104694:	c3                   	ret    

f0104695 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104695:	55                   	push   %ebp
f0104696:	89 e5                	mov    %esp,%ebp
f0104698:	57                   	push   %edi
f0104699:	56                   	push   %esi
f010469a:	53                   	push   %ebx
f010469b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010469e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01046a1:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01046a4:	85 f6                	test   %esi,%esi
f01046a6:	74 32                	je     f01046da <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f01046a8:	83 fe 01             	cmp    $0x1,%esi
f01046ab:	74 22                	je     f01046cf <strlcpy+0x3a>
f01046ad:	8a 0b                	mov    (%ebx),%cl
f01046af:	84 c9                	test   %cl,%cl
f01046b1:	74 20                	je     f01046d3 <strlcpy+0x3e>
f01046b3:	89 f8                	mov    %edi,%eax
f01046b5:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f01046ba:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01046bd:	88 08                	mov    %cl,(%eax)
f01046bf:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01046c0:	39 f2                	cmp    %esi,%edx
f01046c2:	74 11                	je     f01046d5 <strlcpy+0x40>
f01046c4:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f01046c8:	42                   	inc    %edx
f01046c9:	84 c9                	test   %cl,%cl
f01046cb:	75 f0                	jne    f01046bd <strlcpy+0x28>
f01046cd:	eb 06                	jmp    f01046d5 <strlcpy+0x40>
f01046cf:	89 f8                	mov    %edi,%eax
f01046d1:	eb 02                	jmp    f01046d5 <strlcpy+0x40>
f01046d3:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f01046d5:	c6 00 00             	movb   $0x0,(%eax)
f01046d8:	eb 02                	jmp    f01046dc <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01046da:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f01046dc:	29 f8                	sub    %edi,%eax
}
f01046de:	5b                   	pop    %ebx
f01046df:	5e                   	pop    %esi
f01046e0:	5f                   	pop    %edi
f01046e1:	c9                   	leave  
f01046e2:	c3                   	ret    

f01046e3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01046e3:	55                   	push   %ebp
f01046e4:	89 e5                	mov    %esp,%ebp
f01046e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01046e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01046ec:	8a 01                	mov    (%ecx),%al
f01046ee:	84 c0                	test   %al,%al
f01046f0:	74 10                	je     f0104702 <strcmp+0x1f>
f01046f2:	3a 02                	cmp    (%edx),%al
f01046f4:	75 0c                	jne    f0104702 <strcmp+0x1f>
		p++, q++;
f01046f6:	41                   	inc    %ecx
f01046f7:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01046f8:	8a 01                	mov    (%ecx),%al
f01046fa:	84 c0                	test   %al,%al
f01046fc:	74 04                	je     f0104702 <strcmp+0x1f>
f01046fe:	3a 02                	cmp    (%edx),%al
f0104700:	74 f4                	je     f01046f6 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104702:	0f b6 c0             	movzbl %al,%eax
f0104705:	0f b6 12             	movzbl (%edx),%edx
f0104708:	29 d0                	sub    %edx,%eax
}
f010470a:	c9                   	leave  
f010470b:	c3                   	ret    

f010470c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010470c:	55                   	push   %ebp
f010470d:	89 e5                	mov    %esp,%ebp
f010470f:	53                   	push   %ebx
f0104710:	8b 55 08             	mov    0x8(%ebp),%edx
f0104713:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104716:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0104719:	85 c0                	test   %eax,%eax
f010471b:	74 1b                	je     f0104738 <strncmp+0x2c>
f010471d:	8a 1a                	mov    (%edx),%bl
f010471f:	84 db                	test   %bl,%bl
f0104721:	74 24                	je     f0104747 <strncmp+0x3b>
f0104723:	3a 19                	cmp    (%ecx),%bl
f0104725:	75 20                	jne    f0104747 <strncmp+0x3b>
f0104727:	48                   	dec    %eax
f0104728:	74 15                	je     f010473f <strncmp+0x33>
		n--, p++, q++;
f010472a:	42                   	inc    %edx
f010472b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010472c:	8a 1a                	mov    (%edx),%bl
f010472e:	84 db                	test   %bl,%bl
f0104730:	74 15                	je     f0104747 <strncmp+0x3b>
f0104732:	3a 19                	cmp    (%ecx),%bl
f0104734:	74 f1                	je     f0104727 <strncmp+0x1b>
f0104736:	eb 0f                	jmp    f0104747 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104738:	b8 00 00 00 00       	mov    $0x0,%eax
f010473d:	eb 05                	jmp    f0104744 <strncmp+0x38>
f010473f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104744:	5b                   	pop    %ebx
f0104745:	c9                   	leave  
f0104746:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104747:	0f b6 02             	movzbl (%edx),%eax
f010474a:	0f b6 11             	movzbl (%ecx),%edx
f010474d:	29 d0                	sub    %edx,%eax
f010474f:	eb f3                	jmp    f0104744 <strncmp+0x38>

f0104751 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104751:	55                   	push   %ebp
f0104752:	89 e5                	mov    %esp,%ebp
f0104754:	8b 45 08             	mov    0x8(%ebp),%eax
f0104757:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010475a:	8a 10                	mov    (%eax),%dl
f010475c:	84 d2                	test   %dl,%dl
f010475e:	74 18                	je     f0104778 <strchr+0x27>
		if (*s == c)
f0104760:	38 ca                	cmp    %cl,%dl
f0104762:	75 06                	jne    f010476a <strchr+0x19>
f0104764:	eb 17                	jmp    f010477d <strchr+0x2c>
f0104766:	38 ca                	cmp    %cl,%dl
f0104768:	74 13                	je     f010477d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010476a:	40                   	inc    %eax
f010476b:	8a 10                	mov    (%eax),%dl
f010476d:	84 d2                	test   %dl,%dl
f010476f:	75 f5                	jne    f0104766 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f0104771:	b8 00 00 00 00       	mov    $0x0,%eax
f0104776:	eb 05                	jmp    f010477d <strchr+0x2c>
f0104778:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010477d:	c9                   	leave  
f010477e:	c3                   	ret    

f010477f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010477f:	55                   	push   %ebp
f0104780:	89 e5                	mov    %esp,%ebp
f0104782:	8b 45 08             	mov    0x8(%ebp),%eax
f0104785:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0104788:	8a 10                	mov    (%eax),%dl
f010478a:	84 d2                	test   %dl,%dl
f010478c:	74 11                	je     f010479f <strfind+0x20>
		if (*s == c)
f010478e:	38 ca                	cmp    %cl,%dl
f0104790:	75 06                	jne    f0104798 <strfind+0x19>
f0104792:	eb 0b                	jmp    f010479f <strfind+0x20>
f0104794:	38 ca                	cmp    %cl,%dl
f0104796:	74 07                	je     f010479f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0104798:	40                   	inc    %eax
f0104799:	8a 10                	mov    (%eax),%dl
f010479b:	84 d2                	test   %dl,%dl
f010479d:	75 f5                	jne    f0104794 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f010479f:	c9                   	leave  
f01047a0:	c3                   	ret    

f01047a1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01047a1:	55                   	push   %ebp
f01047a2:	89 e5                	mov    %esp,%ebp
f01047a4:	57                   	push   %edi
f01047a5:	56                   	push   %esi
f01047a6:	53                   	push   %ebx
f01047a7:	8b 7d 08             	mov    0x8(%ebp),%edi
f01047aa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01047ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01047b0:	85 c9                	test   %ecx,%ecx
f01047b2:	74 30                	je     f01047e4 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01047b4:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01047ba:	75 25                	jne    f01047e1 <memset+0x40>
f01047bc:	f6 c1 03             	test   $0x3,%cl
f01047bf:	75 20                	jne    f01047e1 <memset+0x40>
		c &= 0xFF;
f01047c1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01047c4:	89 d3                	mov    %edx,%ebx
f01047c6:	c1 e3 08             	shl    $0x8,%ebx
f01047c9:	89 d6                	mov    %edx,%esi
f01047cb:	c1 e6 18             	shl    $0x18,%esi
f01047ce:	89 d0                	mov    %edx,%eax
f01047d0:	c1 e0 10             	shl    $0x10,%eax
f01047d3:	09 f0                	or     %esi,%eax
f01047d5:	09 d0                	or     %edx,%eax
f01047d7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01047d9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01047dc:	fc                   	cld    
f01047dd:	f3 ab                	rep stos %eax,%es:(%edi)
f01047df:	eb 03                	jmp    f01047e4 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01047e1:	fc                   	cld    
f01047e2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01047e4:	89 f8                	mov    %edi,%eax
f01047e6:	5b                   	pop    %ebx
f01047e7:	5e                   	pop    %esi
f01047e8:	5f                   	pop    %edi
f01047e9:	c9                   	leave  
f01047ea:	c3                   	ret    

f01047eb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01047eb:	55                   	push   %ebp
f01047ec:	89 e5                	mov    %esp,%ebp
f01047ee:	57                   	push   %edi
f01047ef:	56                   	push   %esi
f01047f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01047f3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01047f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01047f9:	39 c6                	cmp    %eax,%esi
f01047fb:	73 34                	jae    f0104831 <memmove+0x46>
f01047fd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104800:	39 d0                	cmp    %edx,%eax
f0104802:	73 2d                	jae    f0104831 <memmove+0x46>
		s += n;
		d += n;
f0104804:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104807:	f6 c2 03             	test   $0x3,%dl
f010480a:	75 1b                	jne    f0104827 <memmove+0x3c>
f010480c:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104812:	75 13                	jne    f0104827 <memmove+0x3c>
f0104814:	f6 c1 03             	test   $0x3,%cl
f0104817:	75 0e                	jne    f0104827 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104819:	83 ef 04             	sub    $0x4,%edi
f010481c:	8d 72 fc             	lea    -0x4(%edx),%esi
f010481f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0104822:	fd                   	std    
f0104823:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104825:	eb 07                	jmp    f010482e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104827:	4f                   	dec    %edi
f0104828:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010482b:	fd                   	std    
f010482c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010482e:	fc                   	cld    
f010482f:	eb 20                	jmp    f0104851 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104831:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104837:	75 13                	jne    f010484c <memmove+0x61>
f0104839:	a8 03                	test   $0x3,%al
f010483b:	75 0f                	jne    f010484c <memmove+0x61>
f010483d:	f6 c1 03             	test   $0x3,%cl
f0104840:	75 0a                	jne    f010484c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104842:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0104845:	89 c7                	mov    %eax,%edi
f0104847:	fc                   	cld    
f0104848:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010484a:	eb 05                	jmp    f0104851 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010484c:	89 c7                	mov    %eax,%edi
f010484e:	fc                   	cld    
f010484f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104851:	5e                   	pop    %esi
f0104852:	5f                   	pop    %edi
f0104853:	c9                   	leave  
f0104854:	c3                   	ret    

f0104855 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104855:	55                   	push   %ebp
f0104856:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0104858:	ff 75 10             	pushl  0x10(%ebp)
f010485b:	ff 75 0c             	pushl  0xc(%ebp)
f010485e:	ff 75 08             	pushl  0x8(%ebp)
f0104861:	e8 85 ff ff ff       	call   f01047eb <memmove>
}
f0104866:	c9                   	leave  
f0104867:	c3                   	ret    

f0104868 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104868:	55                   	push   %ebp
f0104869:	89 e5                	mov    %esp,%ebp
f010486b:	57                   	push   %edi
f010486c:	56                   	push   %esi
f010486d:	53                   	push   %ebx
f010486e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104871:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104874:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104877:	85 ff                	test   %edi,%edi
f0104879:	74 32                	je     f01048ad <memcmp+0x45>
		if (*s1 != *s2)
f010487b:	8a 03                	mov    (%ebx),%al
f010487d:	8a 0e                	mov    (%esi),%cl
f010487f:	38 c8                	cmp    %cl,%al
f0104881:	74 19                	je     f010489c <memcmp+0x34>
f0104883:	eb 0d                	jmp    f0104892 <memcmp+0x2a>
f0104885:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f0104889:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f010488d:	42                   	inc    %edx
f010488e:	38 c8                	cmp    %cl,%al
f0104890:	74 10                	je     f01048a2 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f0104892:	0f b6 c0             	movzbl %al,%eax
f0104895:	0f b6 c9             	movzbl %cl,%ecx
f0104898:	29 c8                	sub    %ecx,%eax
f010489a:	eb 16                	jmp    f01048b2 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010489c:	4f                   	dec    %edi
f010489d:	ba 00 00 00 00       	mov    $0x0,%edx
f01048a2:	39 fa                	cmp    %edi,%edx
f01048a4:	75 df                	jne    f0104885 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01048a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01048ab:	eb 05                	jmp    f01048b2 <memcmp+0x4a>
f01048ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01048b2:	5b                   	pop    %ebx
f01048b3:	5e                   	pop    %esi
f01048b4:	5f                   	pop    %edi
f01048b5:	c9                   	leave  
f01048b6:	c3                   	ret    

f01048b7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01048b7:	55                   	push   %ebp
f01048b8:	89 e5                	mov    %esp,%ebp
f01048ba:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01048bd:	89 c2                	mov    %eax,%edx
f01048bf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01048c2:	39 d0                	cmp    %edx,%eax
f01048c4:	73 12                	jae    f01048d8 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f01048c6:	8a 4d 0c             	mov    0xc(%ebp),%cl
f01048c9:	38 08                	cmp    %cl,(%eax)
f01048cb:	75 06                	jne    f01048d3 <memfind+0x1c>
f01048cd:	eb 09                	jmp    f01048d8 <memfind+0x21>
f01048cf:	38 08                	cmp    %cl,(%eax)
f01048d1:	74 05                	je     f01048d8 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01048d3:	40                   	inc    %eax
f01048d4:	39 c2                	cmp    %eax,%edx
f01048d6:	77 f7                	ja     f01048cf <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01048d8:	c9                   	leave  
f01048d9:	c3                   	ret    

f01048da <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01048da:	55                   	push   %ebp
f01048db:	89 e5                	mov    %esp,%ebp
f01048dd:	57                   	push   %edi
f01048de:	56                   	push   %esi
f01048df:	53                   	push   %ebx
f01048e0:	8b 55 08             	mov    0x8(%ebp),%edx
f01048e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01048e6:	eb 01                	jmp    f01048e9 <strtol+0xf>
		s++;
f01048e8:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01048e9:	8a 02                	mov    (%edx),%al
f01048eb:	3c 20                	cmp    $0x20,%al
f01048ed:	74 f9                	je     f01048e8 <strtol+0xe>
f01048ef:	3c 09                	cmp    $0x9,%al
f01048f1:	74 f5                	je     f01048e8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01048f3:	3c 2b                	cmp    $0x2b,%al
f01048f5:	75 08                	jne    f01048ff <strtol+0x25>
		s++;
f01048f7:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01048f8:	bf 00 00 00 00       	mov    $0x0,%edi
f01048fd:	eb 13                	jmp    f0104912 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01048ff:	3c 2d                	cmp    $0x2d,%al
f0104901:	75 0a                	jne    f010490d <strtol+0x33>
		s++, neg = 1;
f0104903:	8d 52 01             	lea    0x1(%edx),%edx
f0104906:	bf 01 00 00 00       	mov    $0x1,%edi
f010490b:	eb 05                	jmp    f0104912 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010490d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104912:	85 db                	test   %ebx,%ebx
f0104914:	74 05                	je     f010491b <strtol+0x41>
f0104916:	83 fb 10             	cmp    $0x10,%ebx
f0104919:	75 28                	jne    f0104943 <strtol+0x69>
f010491b:	8a 02                	mov    (%edx),%al
f010491d:	3c 30                	cmp    $0x30,%al
f010491f:	75 10                	jne    f0104931 <strtol+0x57>
f0104921:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104925:	75 0a                	jne    f0104931 <strtol+0x57>
		s += 2, base = 16;
f0104927:	83 c2 02             	add    $0x2,%edx
f010492a:	bb 10 00 00 00       	mov    $0x10,%ebx
f010492f:	eb 12                	jmp    f0104943 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0104931:	85 db                	test   %ebx,%ebx
f0104933:	75 0e                	jne    f0104943 <strtol+0x69>
f0104935:	3c 30                	cmp    $0x30,%al
f0104937:	75 05                	jne    f010493e <strtol+0x64>
		s++, base = 8;
f0104939:	42                   	inc    %edx
f010493a:	b3 08                	mov    $0x8,%bl
f010493c:	eb 05                	jmp    f0104943 <strtol+0x69>
	else if (base == 0)
		base = 10;
f010493e:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0104943:	b8 00 00 00 00       	mov    $0x0,%eax
f0104948:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010494a:	8a 0a                	mov    (%edx),%cl
f010494c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f010494f:	80 fb 09             	cmp    $0x9,%bl
f0104952:	77 08                	ja     f010495c <strtol+0x82>
			dig = *s - '0';
f0104954:	0f be c9             	movsbl %cl,%ecx
f0104957:	83 e9 30             	sub    $0x30,%ecx
f010495a:	eb 1e                	jmp    f010497a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f010495c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f010495f:	80 fb 19             	cmp    $0x19,%bl
f0104962:	77 08                	ja     f010496c <strtol+0x92>
			dig = *s - 'a' + 10;
f0104964:	0f be c9             	movsbl %cl,%ecx
f0104967:	83 e9 57             	sub    $0x57,%ecx
f010496a:	eb 0e                	jmp    f010497a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f010496c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f010496f:	80 fb 19             	cmp    $0x19,%bl
f0104972:	77 13                	ja     f0104987 <strtol+0xad>
			dig = *s - 'A' + 10;
f0104974:	0f be c9             	movsbl %cl,%ecx
f0104977:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010497a:	39 f1                	cmp    %esi,%ecx
f010497c:	7d 0d                	jge    f010498b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f010497e:	42                   	inc    %edx
f010497f:	0f af c6             	imul   %esi,%eax
f0104982:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0104985:	eb c3                	jmp    f010494a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0104987:	89 c1                	mov    %eax,%ecx
f0104989:	eb 02                	jmp    f010498d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010498b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f010498d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104991:	74 05                	je     f0104998 <strtol+0xbe>
		*endptr = (char *) s;
f0104993:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104996:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0104998:	85 ff                	test   %edi,%edi
f010499a:	74 04                	je     f01049a0 <strtol+0xc6>
f010499c:	89 c8                	mov    %ecx,%eax
f010499e:	f7 d8                	neg    %eax
}
f01049a0:	5b                   	pop    %ebx
f01049a1:	5e                   	pop    %esi
f01049a2:	5f                   	pop    %edi
f01049a3:	c9                   	leave  
f01049a4:	c3                   	ret    
f01049a5:	00 00                	add    %al,(%eax)
	...

f01049a8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f01049a8:	55                   	push   %ebp
f01049a9:	89 e5                	mov    %esp,%ebp
f01049ab:	57                   	push   %edi
f01049ac:	56                   	push   %esi
f01049ad:	83 ec 10             	sub    $0x10,%esp
f01049b0:	8b 7d 08             	mov    0x8(%ebp),%edi
f01049b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f01049b6:	89 7d f0             	mov    %edi,-0x10(%ebp)
f01049b9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f01049bc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f01049bf:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f01049c2:	85 c0                	test   %eax,%eax
f01049c4:	75 2e                	jne    f01049f4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f01049c6:	39 f1                	cmp    %esi,%ecx
f01049c8:	77 5a                	ja     f0104a24 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01049ca:	85 c9                	test   %ecx,%ecx
f01049cc:	75 0b                	jne    f01049d9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01049ce:	b8 01 00 00 00       	mov    $0x1,%eax
f01049d3:	31 d2                	xor    %edx,%edx
f01049d5:	f7 f1                	div    %ecx
f01049d7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01049d9:	31 d2                	xor    %edx,%edx
f01049db:	89 f0                	mov    %esi,%eax
f01049dd:	f7 f1                	div    %ecx
f01049df:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01049e1:	89 f8                	mov    %edi,%eax
f01049e3:	f7 f1                	div    %ecx
f01049e5:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01049e7:	89 f8                	mov    %edi,%eax
f01049e9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01049eb:	83 c4 10             	add    $0x10,%esp
f01049ee:	5e                   	pop    %esi
f01049ef:	5f                   	pop    %edi
f01049f0:	c9                   	leave  
f01049f1:	c3                   	ret    
f01049f2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f01049f4:	39 f0                	cmp    %esi,%eax
f01049f6:	77 1c                	ja     f0104a14 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f01049f8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f01049fb:	83 f7 1f             	xor    $0x1f,%edi
f01049fe:	75 3c                	jne    f0104a3c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0104a00:	39 f0                	cmp    %esi,%eax
f0104a02:	0f 82 90 00 00 00    	jb     f0104a98 <__udivdi3+0xf0>
f0104a08:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104a0b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f0104a0e:	0f 86 84 00 00 00    	jbe    f0104a98 <__udivdi3+0xf0>
f0104a14:	31 f6                	xor    %esi,%esi
f0104a16:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0104a18:	89 f8                	mov    %edi,%eax
f0104a1a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0104a1c:	83 c4 10             	add    $0x10,%esp
f0104a1f:	5e                   	pop    %esi
f0104a20:	5f                   	pop    %edi
f0104a21:	c9                   	leave  
f0104a22:	c3                   	ret    
f0104a23:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0104a24:	89 f2                	mov    %esi,%edx
f0104a26:	89 f8                	mov    %edi,%eax
f0104a28:	f7 f1                	div    %ecx
f0104a2a:	89 c7                	mov    %eax,%edi
f0104a2c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0104a2e:	89 f8                	mov    %edi,%eax
f0104a30:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0104a32:	83 c4 10             	add    $0x10,%esp
f0104a35:	5e                   	pop    %esi
f0104a36:	5f                   	pop    %edi
f0104a37:	c9                   	leave  
f0104a38:	c3                   	ret    
f0104a39:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0104a3c:	89 f9                	mov    %edi,%ecx
f0104a3e:	d3 e0                	shl    %cl,%eax
f0104a40:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0104a43:	b8 20 00 00 00       	mov    $0x20,%eax
f0104a48:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0104a4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104a4d:	88 c1                	mov    %al,%cl
f0104a4f:	d3 ea                	shr    %cl,%edx
f0104a51:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104a54:	09 ca                	or     %ecx,%edx
f0104a56:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f0104a59:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104a5c:	89 f9                	mov    %edi,%ecx
f0104a5e:	d3 e2                	shl    %cl,%edx
f0104a60:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f0104a63:	89 f2                	mov    %esi,%edx
f0104a65:	88 c1                	mov    %al,%cl
f0104a67:	d3 ea                	shr    %cl,%edx
f0104a69:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f0104a6c:	89 f2                	mov    %esi,%edx
f0104a6e:	89 f9                	mov    %edi,%ecx
f0104a70:	d3 e2                	shl    %cl,%edx
f0104a72:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0104a75:	88 c1                	mov    %al,%cl
f0104a77:	d3 ee                	shr    %cl,%esi
f0104a79:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0104a7b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104a7e:	89 f0                	mov    %esi,%eax
f0104a80:	89 ca                	mov    %ecx,%edx
f0104a82:	f7 75 ec             	divl   -0x14(%ebp)
f0104a85:	89 d1                	mov    %edx,%ecx
f0104a87:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0104a89:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104a8c:	39 d1                	cmp    %edx,%ecx
f0104a8e:	72 28                	jb     f0104ab8 <__udivdi3+0x110>
f0104a90:	74 1a                	je     f0104aac <__udivdi3+0x104>
f0104a92:	89 f7                	mov    %esi,%edi
f0104a94:	31 f6                	xor    %esi,%esi
f0104a96:	eb 80                	jmp    f0104a18 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0104a98:	31 f6                	xor    %esi,%esi
f0104a9a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0104a9f:	89 f8                	mov    %edi,%eax
f0104aa1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0104aa3:	83 c4 10             	add    $0x10,%esp
f0104aa6:	5e                   	pop    %esi
f0104aa7:	5f                   	pop    %edi
f0104aa8:	c9                   	leave  
f0104aa9:	c3                   	ret    
f0104aaa:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0104aac:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104aaf:	89 f9                	mov    %edi,%ecx
f0104ab1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104ab3:	39 c2                	cmp    %eax,%edx
f0104ab5:	73 db                	jae    f0104a92 <__udivdi3+0xea>
f0104ab7:	90                   	nop
		{
		  q0--;
f0104ab8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0104abb:	31 f6                	xor    %esi,%esi
f0104abd:	e9 56 ff ff ff       	jmp    f0104a18 <__udivdi3+0x70>
	...

f0104ac4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0104ac4:	55                   	push   %ebp
f0104ac5:	89 e5                	mov    %esp,%ebp
f0104ac7:	57                   	push   %edi
f0104ac8:	56                   	push   %esi
f0104ac9:	83 ec 20             	sub    $0x20,%esp
f0104acc:	8b 45 08             	mov    0x8(%ebp),%eax
f0104acf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0104ad2:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0104ad5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0104ad8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0104adb:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0104ade:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f0104ae1:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0104ae3:	85 ff                	test   %edi,%edi
f0104ae5:	75 15                	jne    f0104afc <__umoddi3+0x38>
    {
      if (d0 > n1)
f0104ae7:	39 f1                	cmp    %esi,%ecx
f0104ae9:	0f 86 99 00 00 00    	jbe    f0104b88 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0104aef:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0104af1:	89 d0                	mov    %edx,%eax
f0104af3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104af5:	83 c4 20             	add    $0x20,%esp
f0104af8:	5e                   	pop    %esi
f0104af9:	5f                   	pop    %edi
f0104afa:	c9                   	leave  
f0104afb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0104afc:	39 f7                	cmp    %esi,%edi
f0104afe:	0f 87 a4 00 00 00    	ja     f0104ba8 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0104b04:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f0104b07:	83 f0 1f             	xor    $0x1f,%eax
f0104b0a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104b0d:	0f 84 a1 00 00 00    	je     f0104bb4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0104b13:	89 f8                	mov    %edi,%eax
f0104b15:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104b18:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0104b1a:	bf 20 00 00 00       	mov    $0x20,%edi
f0104b1f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0104b22:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104b25:	89 f9                	mov    %edi,%ecx
f0104b27:	d3 ea                	shr    %cl,%edx
f0104b29:	09 c2                	or     %eax,%edx
f0104b2b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f0104b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104b31:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104b34:	d3 e0                	shl    %cl,%eax
f0104b36:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0104b39:	89 f2                	mov    %esi,%edx
f0104b3b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0104b3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104b40:	d3 e0                	shl    %cl,%eax
f0104b42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0104b45:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104b48:	89 f9                	mov    %edi,%ecx
f0104b4a:	d3 e8                	shr    %cl,%eax
f0104b4c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0104b4e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0104b50:	89 f2                	mov    %esi,%edx
f0104b52:	f7 75 f0             	divl   -0x10(%ebp)
f0104b55:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0104b57:	f7 65 f4             	mull   -0xc(%ebp)
f0104b5a:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0104b5d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104b5f:	39 d6                	cmp    %edx,%esi
f0104b61:	72 71                	jb     f0104bd4 <__umoddi3+0x110>
f0104b63:	74 7f                	je     f0104be4 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0104b65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b68:	29 c8                	sub    %ecx,%eax
f0104b6a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0104b6c:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104b6f:	d3 e8                	shr    %cl,%eax
f0104b71:	89 f2                	mov    %esi,%edx
f0104b73:	89 f9                	mov    %edi,%ecx
f0104b75:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0104b77:	09 d0                	or     %edx,%eax
f0104b79:	89 f2                	mov    %esi,%edx
f0104b7b:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104b7e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104b80:	83 c4 20             	add    $0x20,%esp
f0104b83:	5e                   	pop    %esi
f0104b84:	5f                   	pop    %edi
f0104b85:	c9                   	leave  
f0104b86:	c3                   	ret    
f0104b87:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0104b88:	85 c9                	test   %ecx,%ecx
f0104b8a:	75 0b                	jne    f0104b97 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0104b8c:	b8 01 00 00 00       	mov    $0x1,%eax
f0104b91:	31 d2                	xor    %edx,%edx
f0104b93:	f7 f1                	div    %ecx
f0104b95:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0104b97:	89 f0                	mov    %esi,%eax
f0104b99:	31 d2                	xor    %edx,%edx
f0104b9b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0104b9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104ba0:	f7 f1                	div    %ecx
f0104ba2:	e9 4a ff ff ff       	jmp    f0104af1 <__umoddi3+0x2d>
f0104ba7:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0104ba8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104baa:	83 c4 20             	add    $0x20,%esp
f0104bad:	5e                   	pop    %esi
f0104bae:	5f                   	pop    %edi
f0104baf:	c9                   	leave  
f0104bb0:	c3                   	ret    
f0104bb1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0104bb4:	39 f7                	cmp    %esi,%edi
f0104bb6:	72 05                	jb     f0104bbd <__umoddi3+0xf9>
f0104bb8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0104bbb:	77 0c                	ja     f0104bc9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0104bbd:	89 f2                	mov    %esi,%edx
f0104bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104bc2:	29 c8                	sub    %ecx,%eax
f0104bc4:	19 fa                	sbb    %edi,%edx
f0104bc6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0104bc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104bcc:	83 c4 20             	add    $0x20,%esp
f0104bcf:	5e                   	pop    %esi
f0104bd0:	5f                   	pop    %edi
f0104bd1:	c9                   	leave  
f0104bd2:	c3                   	ret    
f0104bd3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0104bd4:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104bd7:	89 c1                	mov    %eax,%ecx
f0104bd9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f0104bdc:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f0104bdf:	eb 84                	jmp    f0104b65 <__umoddi3+0xa1>
f0104be1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104be4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0104be7:	72 eb                	jb     f0104bd4 <__umoddi3+0x110>
f0104be9:	89 f2                	mov    %esi,%edx
f0104beb:	e9 75 ff ff ff       	jmp    f0104b65 <__umoddi3+0xa1>