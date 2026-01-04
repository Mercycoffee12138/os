
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	0000c297          	auipc	t0,0xc
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc020c000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	0000c297          	auipc	t0,0xc
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc020c008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)

    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c020b2b7          	lui	t0,0xc020b
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200034:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200038:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc020003c:	c020b137          	lui	sp,0xc020b

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200044:	04a28293          	addi	t0,t0,74 # ffffffffc020004a <kern_init>
    jr t0
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <kern_init>:
void grade_backtrace(void);

int kern_init(void)
{
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc020004a:	000ce517          	auipc	a0,0xce
ffffffffc020004e:	2be50513          	addi	a0,a0,702 # ffffffffc02ce308 <buf>
ffffffffc0200052:	000d2617          	auipc	a2,0xd2
ffffffffc0200056:	79e60613          	addi	a2,a2,1950 # ffffffffc02d27f0 <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	40d050ef          	jal	ra,ffffffffc0205c6e <memset>
    cons_init(); // init the console
ffffffffc0200066:	520000ef          	jal	ra,ffffffffc0200586 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006a:	00006597          	auipc	a1,0x6
ffffffffc020006e:	c2e58593          	addi	a1,a1,-978 # ffffffffc0205c98 <etext>
ffffffffc0200072:	00006517          	auipc	a0,0x6
ffffffffc0200076:	c4650513          	addi	a0,a0,-954 # ffffffffc0205cb8 <etext+0x20>
ffffffffc020007a:	11e000ef          	jal	ra,ffffffffc0200198 <cprintf>

    print_kerninfo();
ffffffffc020007e:	1a2000ef          	jal	ra,ffffffffc0200220 <print_kerninfo>

    // grade_backtrace();

    dtb_init(); // init dtb
ffffffffc0200082:	576000ef          	jal	ra,ffffffffc02005f8 <dtb_init>

    pmm_init(); // init physical memory management
ffffffffc0200086:	5fc020ef          	jal	ra,ffffffffc0202682 <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	12b000ef          	jal	ra,ffffffffc02009b4 <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	129000ef          	jal	ra,ffffffffc02009b6 <idt_init>

    vmm_init(); // init virtual memory management
ffffffffc0200092:	0c9030ef          	jal	ra,ffffffffc020395a <vmm_init>
    sched_init();
ffffffffc0200096:	46e050ef          	jal	ra,ffffffffc0205504 <sched_init>
    proc_init(); // init process table
ffffffffc020009a:	4e9040ef          	jal	ra,ffffffffc0204d82 <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009e:	4a0000ef          	jal	ra,ffffffffc020053e <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc02000a2:	107000ef          	jal	ra,ffffffffc02009a8 <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a6:	675040ef          	jal	ra,ffffffffc0204f1a <cpu_idle>

ffffffffc02000aa <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02000aa:	715d                	addi	sp,sp,-80
ffffffffc02000ac:	e486                	sd	ra,72(sp)
ffffffffc02000ae:	e0a6                	sd	s1,64(sp)
ffffffffc02000b0:	fc4a                	sd	s2,56(sp)
ffffffffc02000b2:	f84e                	sd	s3,48(sp)
ffffffffc02000b4:	f452                	sd	s4,40(sp)
ffffffffc02000b6:	f056                	sd	s5,32(sp)
ffffffffc02000b8:	ec5a                	sd	s6,24(sp)
ffffffffc02000ba:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02000bc:	c901                	beqz	a0,ffffffffc02000cc <readline+0x22>
ffffffffc02000be:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02000c0:	00006517          	auipc	a0,0x6
ffffffffc02000c4:	c0050513          	addi	a0,a0,-1024 # ffffffffc0205cc0 <etext+0x28>
ffffffffc02000c8:	0d0000ef          	jal	ra,ffffffffc0200198 <cprintf>
readline(const char *prompt) {
ffffffffc02000cc:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000ce:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000d0:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000d2:	4aa9                	li	s5,10
ffffffffc02000d4:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000d6:	000ceb97          	auipc	s7,0xce
ffffffffc02000da:	232b8b93          	addi	s7,s7,562 # ffffffffc02ce308 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000de:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000e2:	12e000ef          	jal	ra,ffffffffc0200210 <getchar>
        if (c < 0) {
ffffffffc02000e6:	00054a63          	bltz	a0,ffffffffc02000fa <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000ea:	00a95a63          	bge	s2,a0,ffffffffc02000fe <readline+0x54>
ffffffffc02000ee:	029a5263          	bge	s4,s1,ffffffffc0200112 <readline+0x68>
        c = getchar();
ffffffffc02000f2:	11e000ef          	jal	ra,ffffffffc0200210 <getchar>
        if (c < 0) {
ffffffffc02000f6:	fe055ae3          	bgez	a0,ffffffffc02000ea <readline+0x40>
            return NULL;
ffffffffc02000fa:	4501                	li	a0,0
ffffffffc02000fc:	a091                	j	ffffffffc0200140 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02000fe:	03351463          	bne	a0,s3,ffffffffc0200126 <readline+0x7c>
ffffffffc0200102:	e8a9                	bnez	s1,ffffffffc0200154 <readline+0xaa>
        c = getchar();
ffffffffc0200104:	10c000ef          	jal	ra,ffffffffc0200210 <getchar>
        if (c < 0) {
ffffffffc0200108:	fe0549e3          	bltz	a0,ffffffffc02000fa <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020010c:	fea959e3          	bge	s2,a0,ffffffffc02000fe <readline+0x54>
ffffffffc0200110:	4481                	li	s1,0
            cputchar(c);
ffffffffc0200112:	e42a                	sd	a0,8(sp)
ffffffffc0200114:	0ba000ef          	jal	ra,ffffffffc02001ce <cputchar>
            buf[i ++] = c;
ffffffffc0200118:	6522                	ld	a0,8(sp)
ffffffffc020011a:	009b87b3          	add	a5,s7,s1
ffffffffc020011e:	2485                	addiw	s1,s1,1
ffffffffc0200120:	00a78023          	sb	a0,0(a5)
ffffffffc0200124:	bf7d                	j	ffffffffc02000e2 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0200126:	01550463          	beq	a0,s5,ffffffffc020012e <readline+0x84>
ffffffffc020012a:	fb651ce3          	bne	a0,s6,ffffffffc02000e2 <readline+0x38>
            cputchar(c);
ffffffffc020012e:	0a0000ef          	jal	ra,ffffffffc02001ce <cputchar>
            buf[i] = '\0';
ffffffffc0200132:	000ce517          	auipc	a0,0xce
ffffffffc0200136:	1d650513          	addi	a0,a0,470 # ffffffffc02ce308 <buf>
ffffffffc020013a:	94aa                	add	s1,s1,a0
ffffffffc020013c:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200140:	60a6                	ld	ra,72(sp)
ffffffffc0200142:	6486                	ld	s1,64(sp)
ffffffffc0200144:	7962                	ld	s2,56(sp)
ffffffffc0200146:	79c2                	ld	s3,48(sp)
ffffffffc0200148:	7a22                	ld	s4,40(sp)
ffffffffc020014a:	7a82                	ld	s5,32(sp)
ffffffffc020014c:	6b62                	ld	s6,24(sp)
ffffffffc020014e:	6bc2                	ld	s7,16(sp)
ffffffffc0200150:	6161                	addi	sp,sp,80
ffffffffc0200152:	8082                	ret
            cputchar(c);
ffffffffc0200154:	4521                	li	a0,8
ffffffffc0200156:	078000ef          	jal	ra,ffffffffc02001ce <cputchar>
            i --;
ffffffffc020015a:	34fd                	addiw	s1,s1,-1
ffffffffc020015c:	b759                	j	ffffffffc02000e2 <readline+0x38>

ffffffffc020015e <cputch>:
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt)
{
ffffffffc020015e:	1141                	addi	sp,sp,-16
ffffffffc0200160:	e022                	sd	s0,0(sp)
ffffffffc0200162:	e406                	sd	ra,8(sp)
ffffffffc0200164:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200166:	422000ef          	jal	ra,ffffffffc0200588 <cons_putc>
    (*cnt)++;
ffffffffc020016a:	401c                	lw	a5,0(s0)
}
ffffffffc020016c:	60a2                	ld	ra,8(sp)
    (*cnt)++;
ffffffffc020016e:	2785                	addiw	a5,a5,1
ffffffffc0200170:	c01c                	sw	a5,0(s0)
}
ffffffffc0200172:	6402                	ld	s0,0(sp)
ffffffffc0200174:	0141                	addi	sp,sp,16
ffffffffc0200176:	8082                	ret

ffffffffc0200178 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int vcprintf(const char *fmt, va_list ap)
{
ffffffffc0200178:	1101                	addi	sp,sp,-32
ffffffffc020017a:	862a                	mv	a2,a0
ffffffffc020017c:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc020017e:	00000517          	auipc	a0,0x0
ffffffffc0200182:	fe050513          	addi	a0,a0,-32 # ffffffffc020015e <cputch>
ffffffffc0200186:	006c                	addi	a1,sp,12
{
ffffffffc0200188:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc020018a:	c602                	sw	zero,12(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc020018c:	6be050ef          	jal	ra,ffffffffc020584a <vprintfmt>
    return cnt;
}
ffffffffc0200190:	60e2                	ld	ra,24(sp)
ffffffffc0200192:	4532                	lw	a0,12(sp)
ffffffffc0200194:	6105                	addi	sp,sp,32
ffffffffc0200196:	8082                	ret

ffffffffc0200198 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...)
{
ffffffffc0200198:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc020019a:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
{
ffffffffc020019e:	8e2a                	mv	t3,a0
ffffffffc02001a0:	f42e                	sd	a1,40(sp)
ffffffffc02001a2:	f832                	sd	a2,48(sp)
ffffffffc02001a4:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02001a6:	00000517          	auipc	a0,0x0
ffffffffc02001aa:	fb850513          	addi	a0,a0,-72 # ffffffffc020015e <cputch>
ffffffffc02001ae:	004c                	addi	a1,sp,4
ffffffffc02001b0:	869a                	mv	a3,t1
ffffffffc02001b2:	8672                	mv	a2,t3
{
ffffffffc02001b4:	ec06                	sd	ra,24(sp)
ffffffffc02001b6:	e0ba                	sd	a4,64(sp)
ffffffffc02001b8:	e4be                	sd	a5,72(sp)
ffffffffc02001ba:	e8c2                	sd	a6,80(sp)
ffffffffc02001bc:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001be:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001c0:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02001c2:	688050ef          	jal	ra,ffffffffc020584a <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001c6:	60e2                	ld	ra,24(sp)
ffffffffc02001c8:	4512                	lw	a0,4(sp)
ffffffffc02001ca:	6125                	addi	sp,sp,96
ffffffffc02001cc:	8082                	ret

ffffffffc02001ce <cputchar>:

/* cputchar - writes a single character to stdout */
void cputchar(int c)
{
    cons_putc(c);
ffffffffc02001ce:	ae6d                	j	ffffffffc0200588 <cons_putc>

ffffffffc02001d0 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int cputs(const char *str)
{
ffffffffc02001d0:	1101                	addi	sp,sp,-32
ffffffffc02001d2:	e822                	sd	s0,16(sp)
ffffffffc02001d4:	ec06                	sd	ra,24(sp)
ffffffffc02001d6:	e426                	sd	s1,8(sp)
ffffffffc02001d8:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str++) != '\0')
ffffffffc02001da:	00054503          	lbu	a0,0(a0)
ffffffffc02001de:	c51d                	beqz	a0,ffffffffc020020c <cputs+0x3c>
ffffffffc02001e0:	0405                	addi	s0,s0,1
ffffffffc02001e2:	4485                	li	s1,1
ffffffffc02001e4:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02001e6:	3a2000ef          	jal	ra,ffffffffc0200588 <cons_putc>
    while ((c = *str++) != '\0')
ffffffffc02001ea:	00044503          	lbu	a0,0(s0)
ffffffffc02001ee:	008487bb          	addw	a5,s1,s0
ffffffffc02001f2:	0405                	addi	s0,s0,1
ffffffffc02001f4:	f96d                	bnez	a0,ffffffffc02001e6 <cputs+0x16>
    (*cnt)++;
ffffffffc02001f6:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001fa:	4529                	li	a0,10
ffffffffc02001fc:	38c000ef          	jal	ra,ffffffffc0200588 <cons_putc>
    {
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200200:	60e2                	ld	ra,24(sp)
ffffffffc0200202:	8522                	mv	a0,s0
ffffffffc0200204:	6442                	ld	s0,16(sp)
ffffffffc0200206:	64a2                	ld	s1,8(sp)
ffffffffc0200208:	6105                	addi	sp,sp,32
ffffffffc020020a:	8082                	ret
    while ((c = *str++) != '\0')
ffffffffc020020c:	4405                	li	s0,1
ffffffffc020020e:	b7f5                	j	ffffffffc02001fa <cputs+0x2a>

ffffffffc0200210 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int getchar(void)
{
ffffffffc0200210:	1141                	addi	sp,sp,-16
ffffffffc0200212:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200214:	3a8000ef          	jal	ra,ffffffffc02005bc <cons_getc>
ffffffffc0200218:	dd75                	beqz	a0,ffffffffc0200214 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020021a:	60a2                	ld	ra,8(sp)
ffffffffc020021c:	0141                	addi	sp,sp,16
ffffffffc020021e:	8082                	ret

ffffffffc0200220 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200220:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200222:	00006517          	auipc	a0,0x6
ffffffffc0200226:	aa650513          	addi	a0,a0,-1370 # ffffffffc0205cc8 <etext+0x30>
void print_kerninfo(void) {
ffffffffc020022a:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020022c:	f6dff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200230:	00000597          	auipc	a1,0x0
ffffffffc0200234:	e1a58593          	addi	a1,a1,-486 # ffffffffc020004a <kern_init>
ffffffffc0200238:	00006517          	auipc	a0,0x6
ffffffffc020023c:	ab050513          	addi	a0,a0,-1360 # ffffffffc0205ce8 <etext+0x50>
ffffffffc0200240:	f59ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200244:	00006597          	auipc	a1,0x6
ffffffffc0200248:	a5458593          	addi	a1,a1,-1452 # ffffffffc0205c98 <etext>
ffffffffc020024c:	00006517          	auipc	a0,0x6
ffffffffc0200250:	abc50513          	addi	a0,a0,-1348 # ffffffffc0205d08 <etext+0x70>
ffffffffc0200254:	f45ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200258:	000ce597          	auipc	a1,0xce
ffffffffc020025c:	0b058593          	addi	a1,a1,176 # ffffffffc02ce308 <buf>
ffffffffc0200260:	00006517          	auipc	a0,0x6
ffffffffc0200264:	ac850513          	addi	a0,a0,-1336 # ffffffffc0205d28 <etext+0x90>
ffffffffc0200268:	f31ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc020026c:	000d2597          	auipc	a1,0xd2
ffffffffc0200270:	58458593          	addi	a1,a1,1412 # ffffffffc02d27f0 <end>
ffffffffc0200274:	00006517          	auipc	a0,0x6
ffffffffc0200278:	ad450513          	addi	a0,a0,-1324 # ffffffffc0205d48 <etext+0xb0>
ffffffffc020027c:	f1dff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200280:	000d3597          	auipc	a1,0xd3
ffffffffc0200284:	96f58593          	addi	a1,a1,-1681 # ffffffffc02d2bef <end+0x3ff>
ffffffffc0200288:	00000797          	auipc	a5,0x0
ffffffffc020028c:	dc278793          	addi	a5,a5,-574 # ffffffffc020004a <kern_init>
ffffffffc0200290:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200294:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200298:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020029a:	3ff5f593          	andi	a1,a1,1023
ffffffffc020029e:	95be                	add	a1,a1,a5
ffffffffc02002a0:	85a9                	srai	a1,a1,0xa
ffffffffc02002a2:	00006517          	auipc	a0,0x6
ffffffffc02002a6:	ac650513          	addi	a0,a0,-1338 # ffffffffc0205d68 <etext+0xd0>
}
ffffffffc02002aa:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002ac:	b5f5                	j	ffffffffc0200198 <cprintf>

ffffffffc02002ae <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002ae:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002b0:	00006617          	auipc	a2,0x6
ffffffffc02002b4:	ae860613          	addi	a2,a2,-1304 # ffffffffc0205d98 <etext+0x100>
ffffffffc02002b8:	04d00593          	li	a1,77
ffffffffc02002bc:	00006517          	auipc	a0,0x6
ffffffffc02002c0:	af450513          	addi	a0,a0,-1292 # ffffffffc0205db0 <etext+0x118>
void print_stackframe(void) {
ffffffffc02002c4:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002c6:	1cc000ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02002ca <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002ca:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002cc:	00006617          	auipc	a2,0x6
ffffffffc02002d0:	afc60613          	addi	a2,a2,-1284 # ffffffffc0205dc8 <etext+0x130>
ffffffffc02002d4:	00006597          	auipc	a1,0x6
ffffffffc02002d8:	b1458593          	addi	a1,a1,-1260 # ffffffffc0205de8 <etext+0x150>
ffffffffc02002dc:	00006517          	auipc	a0,0x6
ffffffffc02002e0:	b1450513          	addi	a0,a0,-1260 # ffffffffc0205df0 <etext+0x158>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e4:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e6:	eb3ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
ffffffffc02002ea:	00006617          	auipc	a2,0x6
ffffffffc02002ee:	b1660613          	addi	a2,a2,-1258 # ffffffffc0205e00 <etext+0x168>
ffffffffc02002f2:	00006597          	auipc	a1,0x6
ffffffffc02002f6:	b3658593          	addi	a1,a1,-1226 # ffffffffc0205e28 <etext+0x190>
ffffffffc02002fa:	00006517          	auipc	a0,0x6
ffffffffc02002fe:	af650513          	addi	a0,a0,-1290 # ffffffffc0205df0 <etext+0x158>
ffffffffc0200302:	e97ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
ffffffffc0200306:	00006617          	auipc	a2,0x6
ffffffffc020030a:	b3260613          	addi	a2,a2,-1230 # ffffffffc0205e38 <etext+0x1a0>
ffffffffc020030e:	00006597          	auipc	a1,0x6
ffffffffc0200312:	b4a58593          	addi	a1,a1,-1206 # ffffffffc0205e58 <etext+0x1c0>
ffffffffc0200316:	00006517          	auipc	a0,0x6
ffffffffc020031a:	ada50513          	addi	a0,a0,-1318 # ffffffffc0205df0 <etext+0x158>
ffffffffc020031e:	e7bff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    }
    return 0;
}
ffffffffc0200322:	60a2                	ld	ra,8(sp)
ffffffffc0200324:	4501                	li	a0,0
ffffffffc0200326:	0141                	addi	sp,sp,16
ffffffffc0200328:	8082                	ret

ffffffffc020032a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020032a:	1141                	addi	sp,sp,-16
ffffffffc020032c:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020032e:	ef3ff0ef          	jal	ra,ffffffffc0200220 <print_kerninfo>
    return 0;
}
ffffffffc0200332:	60a2                	ld	ra,8(sp)
ffffffffc0200334:	4501                	li	a0,0
ffffffffc0200336:	0141                	addi	sp,sp,16
ffffffffc0200338:	8082                	ret

ffffffffc020033a <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020033a:	1141                	addi	sp,sp,-16
ffffffffc020033c:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020033e:	f71ff0ef          	jal	ra,ffffffffc02002ae <print_stackframe>
    return 0;
}
ffffffffc0200342:	60a2                	ld	ra,8(sp)
ffffffffc0200344:	4501                	li	a0,0
ffffffffc0200346:	0141                	addi	sp,sp,16
ffffffffc0200348:	8082                	ret

ffffffffc020034a <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020034a:	7115                	addi	sp,sp,-224
ffffffffc020034c:	ed5e                	sd	s7,152(sp)
ffffffffc020034e:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200350:	00006517          	auipc	a0,0x6
ffffffffc0200354:	b1850513          	addi	a0,a0,-1256 # ffffffffc0205e68 <etext+0x1d0>
kmonitor(struct trapframe *tf) {
ffffffffc0200358:	ed86                	sd	ra,216(sp)
ffffffffc020035a:	e9a2                	sd	s0,208(sp)
ffffffffc020035c:	e5a6                	sd	s1,200(sp)
ffffffffc020035e:	e1ca                	sd	s2,192(sp)
ffffffffc0200360:	fd4e                	sd	s3,184(sp)
ffffffffc0200362:	f952                	sd	s4,176(sp)
ffffffffc0200364:	f556                	sd	s5,168(sp)
ffffffffc0200366:	f15a                	sd	s6,160(sp)
ffffffffc0200368:	e962                	sd	s8,144(sp)
ffffffffc020036a:	e566                	sd	s9,136(sp)
ffffffffc020036c:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020036e:	e2bff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200372:	00006517          	auipc	a0,0x6
ffffffffc0200376:	b1e50513          	addi	a0,a0,-1250 # ffffffffc0205e90 <etext+0x1f8>
ffffffffc020037a:	e1fff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    if (tf != NULL) {
ffffffffc020037e:	000b8563          	beqz	s7,ffffffffc0200388 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200382:	855e                	mv	a0,s7
ffffffffc0200384:	01b000ef          	jal	ra,ffffffffc0200b9e <print_trapframe>
ffffffffc0200388:	00006c17          	auipc	s8,0x6
ffffffffc020038c:	b78c0c13          	addi	s8,s8,-1160 # ffffffffc0205f00 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200390:	00006917          	auipc	s2,0x6
ffffffffc0200394:	b2890913          	addi	s2,s2,-1240 # ffffffffc0205eb8 <etext+0x220>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200398:	00006497          	auipc	s1,0x6
ffffffffc020039c:	b2848493          	addi	s1,s1,-1240 # ffffffffc0205ec0 <etext+0x228>
        if (argc == MAXARGS - 1) {
ffffffffc02003a0:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003a2:	00006b17          	auipc	s6,0x6
ffffffffc02003a6:	b26b0b13          	addi	s6,s6,-1242 # ffffffffc0205ec8 <etext+0x230>
        argv[argc ++] = buf;
ffffffffc02003aa:	00006a17          	auipc	s4,0x6
ffffffffc02003ae:	a3ea0a13          	addi	s4,s4,-1474 # ffffffffc0205de8 <etext+0x150>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003b2:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003b4:	854a                	mv	a0,s2
ffffffffc02003b6:	cf5ff0ef          	jal	ra,ffffffffc02000aa <readline>
ffffffffc02003ba:	842a                	mv	s0,a0
ffffffffc02003bc:	dd65                	beqz	a0,ffffffffc02003b4 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003be:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003c2:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003c4:	e1bd                	bnez	a1,ffffffffc020042a <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02003c6:	fe0c87e3          	beqz	s9,ffffffffc02003b4 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003ca:	6582                	ld	a1,0(sp)
ffffffffc02003cc:	00006d17          	auipc	s10,0x6
ffffffffc02003d0:	b34d0d13          	addi	s10,s10,-1228 # ffffffffc0205f00 <commands>
        argv[argc ++] = buf;
ffffffffc02003d4:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003d6:	4401                	li	s0,0
ffffffffc02003d8:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003da:	03b050ef          	jal	ra,ffffffffc0205c14 <strcmp>
ffffffffc02003de:	c919                	beqz	a0,ffffffffc02003f4 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003e0:	2405                	addiw	s0,s0,1
ffffffffc02003e2:	0b540063          	beq	s0,s5,ffffffffc0200482 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003e6:	000d3503          	ld	a0,0(s10)
ffffffffc02003ea:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ec:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003ee:	027050ef          	jal	ra,ffffffffc0205c14 <strcmp>
ffffffffc02003f2:	f57d                	bnez	a0,ffffffffc02003e0 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003f4:	00141793          	slli	a5,s0,0x1
ffffffffc02003f8:	97a2                	add	a5,a5,s0
ffffffffc02003fa:	078e                	slli	a5,a5,0x3
ffffffffc02003fc:	97e2                	add	a5,a5,s8
ffffffffc02003fe:	6b9c                	ld	a5,16(a5)
ffffffffc0200400:	865e                	mv	a2,s7
ffffffffc0200402:	002c                	addi	a1,sp,8
ffffffffc0200404:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200408:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020040a:	fa0555e3          	bgez	a0,ffffffffc02003b4 <kmonitor+0x6a>
}
ffffffffc020040e:	60ee                	ld	ra,216(sp)
ffffffffc0200410:	644e                	ld	s0,208(sp)
ffffffffc0200412:	64ae                	ld	s1,200(sp)
ffffffffc0200414:	690e                	ld	s2,192(sp)
ffffffffc0200416:	79ea                	ld	s3,184(sp)
ffffffffc0200418:	7a4a                	ld	s4,176(sp)
ffffffffc020041a:	7aaa                	ld	s5,168(sp)
ffffffffc020041c:	7b0a                	ld	s6,160(sp)
ffffffffc020041e:	6bea                	ld	s7,152(sp)
ffffffffc0200420:	6c4a                	ld	s8,144(sp)
ffffffffc0200422:	6caa                	ld	s9,136(sp)
ffffffffc0200424:	6d0a                	ld	s10,128(sp)
ffffffffc0200426:	612d                	addi	sp,sp,224
ffffffffc0200428:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020042a:	8526                	mv	a0,s1
ffffffffc020042c:	02d050ef          	jal	ra,ffffffffc0205c58 <strchr>
ffffffffc0200430:	c901                	beqz	a0,ffffffffc0200440 <kmonitor+0xf6>
ffffffffc0200432:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200436:	00040023          	sb	zero,0(s0)
ffffffffc020043a:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020043c:	d5c9                	beqz	a1,ffffffffc02003c6 <kmonitor+0x7c>
ffffffffc020043e:	b7f5                	j	ffffffffc020042a <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc0200440:	00044783          	lbu	a5,0(s0)
ffffffffc0200444:	d3c9                	beqz	a5,ffffffffc02003c6 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200446:	033c8963          	beq	s9,s3,ffffffffc0200478 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc020044a:	003c9793          	slli	a5,s9,0x3
ffffffffc020044e:	0118                	addi	a4,sp,128
ffffffffc0200450:	97ba                	add	a5,a5,a4
ffffffffc0200452:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200456:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020045a:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020045c:	e591                	bnez	a1,ffffffffc0200468 <kmonitor+0x11e>
ffffffffc020045e:	b7b5                	j	ffffffffc02003ca <kmonitor+0x80>
ffffffffc0200460:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200464:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200466:	d1a5                	beqz	a1,ffffffffc02003c6 <kmonitor+0x7c>
ffffffffc0200468:	8526                	mv	a0,s1
ffffffffc020046a:	7ee050ef          	jal	ra,ffffffffc0205c58 <strchr>
ffffffffc020046e:	d96d                	beqz	a0,ffffffffc0200460 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200470:	00044583          	lbu	a1,0(s0)
ffffffffc0200474:	d9a9                	beqz	a1,ffffffffc02003c6 <kmonitor+0x7c>
ffffffffc0200476:	bf55                	j	ffffffffc020042a <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200478:	45c1                	li	a1,16
ffffffffc020047a:	855a                	mv	a0,s6
ffffffffc020047c:	d1dff0ef          	jal	ra,ffffffffc0200198 <cprintf>
ffffffffc0200480:	b7e9                	j	ffffffffc020044a <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200482:	6582                	ld	a1,0(sp)
ffffffffc0200484:	00006517          	auipc	a0,0x6
ffffffffc0200488:	a6450513          	addi	a0,a0,-1436 # ffffffffc0205ee8 <etext+0x250>
ffffffffc020048c:	d0dff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    return 0;
ffffffffc0200490:	b715                	j	ffffffffc02003b4 <kmonitor+0x6a>

ffffffffc0200492 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200492:	000d2317          	auipc	t1,0xd2
ffffffffc0200496:	2ce30313          	addi	t1,t1,718 # ffffffffc02d2760 <is_panic>
ffffffffc020049a:	00033e03          	ld	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020049e:	715d                	addi	sp,sp,-80
ffffffffc02004a0:	ec06                	sd	ra,24(sp)
ffffffffc02004a2:	e822                	sd	s0,16(sp)
ffffffffc02004a4:	f436                	sd	a3,40(sp)
ffffffffc02004a6:	f83a                	sd	a4,48(sp)
ffffffffc02004a8:	fc3e                	sd	a5,56(sp)
ffffffffc02004aa:	e0c2                	sd	a6,64(sp)
ffffffffc02004ac:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02004ae:	020e1a63          	bnez	t3,ffffffffc02004e2 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02004b2:	4785                	li	a5,1
ffffffffc02004b4:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004b8:	8432                	mv	s0,a2
ffffffffc02004ba:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004bc:	862e                	mv	a2,a1
ffffffffc02004be:	85aa                	mv	a1,a0
ffffffffc02004c0:	00006517          	auipc	a0,0x6
ffffffffc02004c4:	a8850513          	addi	a0,a0,-1400 # ffffffffc0205f48 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02004c8:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004ca:	ccfff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004ce:	65a2                	ld	a1,8(sp)
ffffffffc02004d0:	8522                	mv	a0,s0
ffffffffc02004d2:	ca7ff0ef          	jal	ra,ffffffffc0200178 <vcprintf>
    cprintf("\n");
ffffffffc02004d6:	00007517          	auipc	a0,0x7
ffffffffc02004da:	b7a50513          	addi	a0,a0,-1158 # ffffffffc0207050 <default_pmm_manager+0x578>
ffffffffc02004de:	cbbff0ef          	jal	ra,ffffffffc0200198 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004e2:	4501                	li	a0,0
ffffffffc02004e4:	4581                	li	a1,0
ffffffffc02004e6:	4601                	li	a2,0
ffffffffc02004e8:	48a1                	li	a7,8
ffffffffc02004ea:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004ee:	4c0000ef          	jal	ra,ffffffffc02009ae <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004f2:	4501                	li	a0,0
ffffffffc02004f4:	e57ff0ef          	jal	ra,ffffffffc020034a <kmonitor>
    while (1) {
ffffffffc02004f8:	bfed                	j	ffffffffc02004f2 <__panic+0x60>

ffffffffc02004fa <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004fa:	715d                	addi	sp,sp,-80
ffffffffc02004fc:	832e                	mv	t1,a1
ffffffffc02004fe:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200500:	85aa                	mv	a1,a0
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200502:	8432                	mv	s0,a2
ffffffffc0200504:	fc3e                	sd	a5,56(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200506:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc0200508:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020050a:	00006517          	auipc	a0,0x6
ffffffffc020050e:	a5e50513          	addi	a0,a0,-1442 # ffffffffc0205f68 <commands+0x68>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200512:	ec06                	sd	ra,24(sp)
ffffffffc0200514:	f436                	sd	a3,40(sp)
ffffffffc0200516:	f83a                	sd	a4,48(sp)
ffffffffc0200518:	e0c2                	sd	a6,64(sp)
ffffffffc020051a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020051c:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020051e:	c7bff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200522:	65a2                	ld	a1,8(sp)
ffffffffc0200524:	8522                	mv	a0,s0
ffffffffc0200526:	c53ff0ef          	jal	ra,ffffffffc0200178 <vcprintf>
    cprintf("\n");
ffffffffc020052a:	00007517          	auipc	a0,0x7
ffffffffc020052e:	b2650513          	addi	a0,a0,-1242 # ffffffffc0207050 <default_pmm_manager+0x578>
ffffffffc0200532:	c67ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    va_end(ap);
}
ffffffffc0200536:	60e2                	ld	ra,24(sp)
ffffffffc0200538:	6442                	ld	s0,16(sp)
ffffffffc020053a:	6161                	addi	sp,sp,80
ffffffffc020053c:	8082                	ret

ffffffffc020053e <clock_init>:
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void)
{
    set_csr(sie, MIP_STIP);
ffffffffc020053e:	02000793          	li	a5,32
ffffffffc0200542:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200546:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020054a:	67e1                	lui	a5,0x18
ffffffffc020054c:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_matrix_out_size+0xbf78>
ffffffffc0200550:	953e                	add	a0,a0,a5
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200552:	4581                	li	a1,0
ffffffffc0200554:	4601                	li	a2,0
ffffffffc0200556:	4881                	li	a7,0
ffffffffc0200558:	00000073          	ecall
    cprintf("++ setup timer interrupts\n");
ffffffffc020055c:	00006517          	auipc	a0,0x6
ffffffffc0200560:	a2c50513          	addi	a0,a0,-1492 # ffffffffc0205f88 <commands+0x88>
    ticks = 0;
ffffffffc0200564:	000d2797          	auipc	a5,0xd2
ffffffffc0200568:	2007b223          	sd	zero,516(a5) # ffffffffc02d2768 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020056c:	b135                	j	ffffffffc0200198 <cprintf>

ffffffffc020056e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020056e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200572:	67e1                	lui	a5,0x18
ffffffffc0200574:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_matrix_out_size+0xbf78>
ffffffffc0200578:	953e                	add	a0,a0,a5
ffffffffc020057a:	4581                	li	a1,0
ffffffffc020057c:	4601                	li	a2,0
ffffffffc020057e:	4881                	li	a7,0
ffffffffc0200580:	00000073          	ecall
ffffffffc0200584:	8082                	ret

ffffffffc0200586 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200586:	8082                	ret

ffffffffc0200588 <cons_putc>:
#include <assert.h>
#include <atomic.h>

static inline bool __intr_save(void)
{
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0200588:	100027f3          	csrr	a5,sstatus
ffffffffc020058c:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020058e:	0ff57513          	zext.b	a0,a0
ffffffffc0200592:	e799                	bnez	a5,ffffffffc02005a0 <cons_putc+0x18>
ffffffffc0200594:	4581                	li	a1,0
ffffffffc0200596:	4601                	li	a2,0
ffffffffc0200598:	4885                	li	a7,1
ffffffffc020059a:	00000073          	ecall
    return 0;
}

static inline void __intr_restore(bool flag)
{
    if (flag)
ffffffffc020059e:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005a0:	1101                	addi	sp,sp,-32
ffffffffc02005a2:	ec06                	sd	ra,24(sp)
ffffffffc02005a4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005a6:	408000ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc02005aa:	6522                	ld	a0,8(sp)
ffffffffc02005ac:	4581                	li	a1,0
ffffffffc02005ae:	4601                	li	a2,0
ffffffffc02005b0:	4885                	li	a7,1
ffffffffc02005b2:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005b6:	60e2                	ld	ra,24(sp)
ffffffffc02005b8:	6105                	addi	sp,sp,32
    {
        intr_enable();
ffffffffc02005ba:	a6fd                	j	ffffffffc02009a8 <intr_enable>

ffffffffc02005bc <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02005bc:	100027f3          	csrr	a5,sstatus
ffffffffc02005c0:	8b89                	andi	a5,a5,2
ffffffffc02005c2:	eb89                	bnez	a5,ffffffffc02005d4 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005c4:	4501                	li	a0,0
ffffffffc02005c6:	4581                	li	a1,0
ffffffffc02005c8:	4601                	li	a2,0
ffffffffc02005ca:	4889                	li	a7,2
ffffffffc02005cc:	00000073          	ecall
ffffffffc02005d0:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005d2:	8082                	ret
int cons_getc(void) {
ffffffffc02005d4:	1101                	addi	sp,sp,-32
ffffffffc02005d6:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005d8:	3d6000ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc02005dc:	4501                	li	a0,0
ffffffffc02005de:	4581                	li	a1,0
ffffffffc02005e0:	4601                	li	a2,0
ffffffffc02005e2:	4889                	li	a7,2
ffffffffc02005e4:	00000073          	ecall
ffffffffc02005e8:	2501                	sext.w	a0,a0
ffffffffc02005ea:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005ec:	3bc000ef          	jal	ra,ffffffffc02009a8 <intr_enable>
}
ffffffffc02005f0:	60e2                	ld	ra,24(sp)
ffffffffc02005f2:	6522                	ld	a0,8(sp)
ffffffffc02005f4:	6105                	addi	sp,sp,32
ffffffffc02005f6:	8082                	ret

ffffffffc02005f8 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc02005f8:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc02005fa:	00006517          	auipc	a0,0x6
ffffffffc02005fe:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0205fa8 <commands+0xa8>
void dtb_init(void) {
ffffffffc0200602:	fc86                	sd	ra,120(sp)
ffffffffc0200604:	f8a2                	sd	s0,112(sp)
ffffffffc0200606:	e8d2                	sd	s4,80(sp)
ffffffffc0200608:	f4a6                	sd	s1,104(sp)
ffffffffc020060a:	f0ca                	sd	s2,96(sp)
ffffffffc020060c:	ecce                	sd	s3,88(sp)
ffffffffc020060e:	e4d6                	sd	s5,72(sp)
ffffffffc0200610:	e0da                	sd	s6,64(sp)
ffffffffc0200612:	fc5e                	sd	s7,56(sp)
ffffffffc0200614:	f862                	sd	s8,48(sp)
ffffffffc0200616:	f466                	sd	s9,40(sp)
ffffffffc0200618:	f06a                	sd	s10,32(sp)
ffffffffc020061a:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc020061c:	b7dff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200620:	0000c597          	auipc	a1,0xc
ffffffffc0200624:	9e05b583          	ld	a1,-1568(a1) # ffffffffc020c000 <boot_hartid>
ffffffffc0200628:	00006517          	auipc	a0,0x6
ffffffffc020062c:	99050513          	addi	a0,a0,-1648 # ffffffffc0205fb8 <commands+0xb8>
ffffffffc0200630:	b69ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200634:	0000c417          	auipc	s0,0xc
ffffffffc0200638:	9d440413          	addi	s0,s0,-1580 # ffffffffc020c008 <boot_dtb>
ffffffffc020063c:	600c                	ld	a1,0(s0)
ffffffffc020063e:	00006517          	auipc	a0,0x6
ffffffffc0200642:	98a50513          	addi	a0,a0,-1654 # ffffffffc0205fc8 <commands+0xc8>
ffffffffc0200646:	b53ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc020064a:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc020064e:	00006517          	auipc	a0,0x6
ffffffffc0200652:	99250513          	addi	a0,a0,-1646 # ffffffffc0205fe0 <commands+0xe0>
    if (boot_dtb == 0) {
ffffffffc0200656:	120a0463          	beqz	s4,ffffffffc020077e <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc020065a:	57f5                	li	a5,-3
ffffffffc020065c:	07fa                	slli	a5,a5,0x1e
ffffffffc020065e:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc0200662:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200664:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200668:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020066a:	0087d59b          	srliw	a1,a5,0x8
ffffffffc020066e:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200672:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200676:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020067a:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020067e:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200680:	8ec9                	or	a3,a3,a0
ffffffffc0200682:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200686:	1b7d                	addi	s6,s6,-1
ffffffffc0200688:	0167f7b3          	and	a5,a5,s6
ffffffffc020068c:	8dd5                	or	a1,a1,a3
ffffffffc020068e:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc0200690:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200694:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc0200696:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfe0d6fd>
ffffffffc020069a:	10f59163          	bne	a1,a5,ffffffffc020079c <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc020069e:	471c                	lw	a5,8(a4)
ffffffffc02006a0:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc02006a2:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006a4:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02006a8:	0086d51b          	srliw	a0,a3,0x8
ffffffffc02006ac:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006b0:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006b4:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006b8:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006bc:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006c0:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006c4:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006c8:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006cc:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006ce:	01146433          	or	s0,s0,a7
ffffffffc02006d2:	0086969b          	slliw	a3,a3,0x8
ffffffffc02006d6:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006da:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006dc:	0087979b          	slliw	a5,a5,0x8
ffffffffc02006e0:	8c49                	or	s0,s0,a0
ffffffffc02006e2:	0166f6b3          	and	a3,a3,s6
ffffffffc02006e6:	00ca6a33          	or	s4,s4,a2
ffffffffc02006ea:	0167f7b3          	and	a5,a5,s6
ffffffffc02006ee:	8c55                	or	s0,s0,a3
ffffffffc02006f0:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02006f4:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02006f6:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02006f8:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02006fa:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02006fe:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200700:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200702:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc0200706:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200708:	00006917          	auipc	s2,0x6
ffffffffc020070c:	92890913          	addi	s2,s2,-1752 # ffffffffc0206030 <commands+0x130>
ffffffffc0200710:	49bd                	li	s3,15
        switch (token) {
ffffffffc0200712:	4d91                	li	s11,4
ffffffffc0200714:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200716:	00006497          	auipc	s1,0x6
ffffffffc020071a:	91248493          	addi	s1,s1,-1774 # ffffffffc0206028 <commands+0x128>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc020071e:	000a2703          	lw	a4,0(s4)
ffffffffc0200722:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200726:	0087569b          	srliw	a3,a4,0x8
ffffffffc020072a:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020072e:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200732:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200736:	0107571b          	srliw	a4,a4,0x10
ffffffffc020073a:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020073c:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200740:	0087171b          	slliw	a4,a4,0x8
ffffffffc0200744:	8fd5                	or	a5,a5,a3
ffffffffc0200746:	00eb7733          	and	a4,s6,a4
ffffffffc020074a:	8fd9                	or	a5,a5,a4
ffffffffc020074c:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc020074e:	09778c63          	beq	a5,s7,ffffffffc02007e6 <dtb_init+0x1ee>
ffffffffc0200752:	00fbea63          	bltu	s7,a5,ffffffffc0200766 <dtb_init+0x16e>
ffffffffc0200756:	07a78663          	beq	a5,s10,ffffffffc02007c2 <dtb_init+0x1ca>
ffffffffc020075a:	4709                	li	a4,2
ffffffffc020075c:	00e79763          	bne	a5,a4,ffffffffc020076a <dtb_init+0x172>
ffffffffc0200760:	4c81                	li	s9,0
ffffffffc0200762:	8a56                	mv	s4,s5
ffffffffc0200764:	bf6d                	j	ffffffffc020071e <dtb_init+0x126>
ffffffffc0200766:	ffb78ee3          	beq	a5,s11,ffffffffc0200762 <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc020076a:	00006517          	auipc	a0,0x6
ffffffffc020076e:	93e50513          	addi	a0,a0,-1730 # ffffffffc02060a8 <commands+0x1a8>
ffffffffc0200772:	a27ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc0200776:	00006517          	auipc	a0,0x6
ffffffffc020077a:	96a50513          	addi	a0,a0,-1686 # ffffffffc02060e0 <commands+0x1e0>
}
ffffffffc020077e:	7446                	ld	s0,112(sp)
ffffffffc0200780:	70e6                	ld	ra,120(sp)
ffffffffc0200782:	74a6                	ld	s1,104(sp)
ffffffffc0200784:	7906                	ld	s2,96(sp)
ffffffffc0200786:	69e6                	ld	s3,88(sp)
ffffffffc0200788:	6a46                	ld	s4,80(sp)
ffffffffc020078a:	6aa6                	ld	s5,72(sp)
ffffffffc020078c:	6b06                	ld	s6,64(sp)
ffffffffc020078e:	7be2                	ld	s7,56(sp)
ffffffffc0200790:	7c42                	ld	s8,48(sp)
ffffffffc0200792:	7ca2                	ld	s9,40(sp)
ffffffffc0200794:	7d02                	ld	s10,32(sp)
ffffffffc0200796:	6de2                	ld	s11,24(sp)
ffffffffc0200798:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc020079a:	bafd                	j	ffffffffc0200198 <cprintf>
}
ffffffffc020079c:	7446                	ld	s0,112(sp)
ffffffffc020079e:	70e6                	ld	ra,120(sp)
ffffffffc02007a0:	74a6                	ld	s1,104(sp)
ffffffffc02007a2:	7906                	ld	s2,96(sp)
ffffffffc02007a4:	69e6                	ld	s3,88(sp)
ffffffffc02007a6:	6a46                	ld	s4,80(sp)
ffffffffc02007a8:	6aa6                	ld	s5,72(sp)
ffffffffc02007aa:	6b06                	ld	s6,64(sp)
ffffffffc02007ac:	7be2                	ld	s7,56(sp)
ffffffffc02007ae:	7c42                	ld	s8,48(sp)
ffffffffc02007b0:	7ca2                	ld	s9,40(sp)
ffffffffc02007b2:	7d02                	ld	s10,32(sp)
ffffffffc02007b4:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02007b6:	00006517          	auipc	a0,0x6
ffffffffc02007ba:	84a50513          	addi	a0,a0,-1974 # ffffffffc0206000 <commands+0x100>
}
ffffffffc02007be:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02007c0:	bae1                	j	ffffffffc0200198 <cprintf>
                int name_len = strlen(name);
ffffffffc02007c2:	8556                	mv	a0,s5
ffffffffc02007c4:	408050ef          	jal	ra,ffffffffc0205bcc <strlen>
ffffffffc02007c8:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02007ca:	4619                	li	a2,6
ffffffffc02007cc:	85a6                	mv	a1,s1
ffffffffc02007ce:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02007d0:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02007d2:	460050ef          	jal	ra,ffffffffc0205c32 <strncmp>
ffffffffc02007d6:	e111                	bnez	a0,ffffffffc02007da <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc02007d8:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02007da:	0a91                	addi	s5,s5,4
ffffffffc02007dc:	9ad2                	add	s5,s5,s4
ffffffffc02007de:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc02007e2:	8a56                	mv	s4,s5
ffffffffc02007e4:	bf2d                	j	ffffffffc020071e <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc02007e6:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc02007ea:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007ee:	0087d71b          	srliw	a4,a5,0x8
ffffffffc02007f2:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007f6:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007fa:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007fe:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200802:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200806:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020080a:	0087979b          	slliw	a5,a5,0x8
ffffffffc020080e:	00eaeab3          	or	s5,s5,a4
ffffffffc0200812:	00fb77b3          	and	a5,s6,a5
ffffffffc0200816:	00faeab3          	or	s5,s5,a5
ffffffffc020081a:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020081c:	000c9c63          	bnez	s9,ffffffffc0200834 <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc0200820:	1a82                	slli	s5,s5,0x20
ffffffffc0200822:	00368793          	addi	a5,a3,3
ffffffffc0200826:	020ada93          	srli	s5,s5,0x20
ffffffffc020082a:	9abe                	add	s5,s5,a5
ffffffffc020082c:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc0200830:	8a56                	mv	s4,s5
ffffffffc0200832:	b5f5                	j	ffffffffc020071e <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200834:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200838:	85ca                	mv	a1,s2
ffffffffc020083a:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020083c:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200840:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200844:	0187971b          	slliw	a4,a5,0x18
ffffffffc0200848:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020084c:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200850:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200852:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200856:	0087979b          	slliw	a5,a5,0x8
ffffffffc020085a:	8d59                	or	a0,a0,a4
ffffffffc020085c:	00fb77b3          	and	a5,s6,a5
ffffffffc0200860:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc0200862:	1502                	slli	a0,a0,0x20
ffffffffc0200864:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200866:	9522                	add	a0,a0,s0
ffffffffc0200868:	3ac050ef          	jal	ra,ffffffffc0205c14 <strcmp>
ffffffffc020086c:	66a2                	ld	a3,8(sp)
ffffffffc020086e:	f94d                	bnez	a0,ffffffffc0200820 <dtb_init+0x228>
ffffffffc0200870:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200820 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200874:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc0200878:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc020087c:	00005517          	auipc	a0,0x5
ffffffffc0200880:	7bc50513          	addi	a0,a0,1980 # ffffffffc0206038 <commands+0x138>
           fdt32_to_cpu(x >> 32);
ffffffffc0200884:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200888:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc020088c:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200890:	0187de1b          	srliw	t3,a5,0x18
ffffffffc0200894:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200898:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020089c:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02008a0:	0187d693          	srli	a3,a5,0x18
ffffffffc02008a4:	01861f1b          	slliw	t5,a2,0x18
ffffffffc02008a8:	0087579b          	srliw	a5,a4,0x8
ffffffffc02008ac:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02008b0:	0106561b          	srliw	a2,a2,0x10
ffffffffc02008b4:	010f6f33          	or	t5,t5,a6
ffffffffc02008b8:	0187529b          	srliw	t0,a4,0x18
ffffffffc02008bc:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02008c0:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02008c4:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02008c8:	0186f6b3          	and	a3,a3,s8
ffffffffc02008cc:	01859e1b          	slliw	t3,a1,0x18
ffffffffc02008d0:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02008d4:	0107581b          	srliw	a6,a4,0x10
ffffffffc02008d8:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02008dc:	8361                	srli	a4,a4,0x18
ffffffffc02008de:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02008e2:	0105d59b          	srliw	a1,a1,0x10
ffffffffc02008e6:	01e6e6b3          	or	a3,a3,t5
ffffffffc02008ea:	00cb7633          	and	a2,s6,a2
ffffffffc02008ee:	0088181b          	slliw	a6,a6,0x8
ffffffffc02008f2:	0085959b          	slliw	a1,a1,0x8
ffffffffc02008f6:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02008fa:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02008fe:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200902:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200906:	0088989b          	slliw	a7,a7,0x8
ffffffffc020090a:	011b78b3          	and	a7,s6,a7
ffffffffc020090e:	005eeeb3          	or	t4,t4,t0
ffffffffc0200912:	00c6e733          	or	a4,a3,a2
ffffffffc0200916:	006c6c33          	or	s8,s8,t1
ffffffffc020091a:	010b76b3          	and	a3,s6,a6
ffffffffc020091e:	00bb7b33          	and	s6,s6,a1
ffffffffc0200922:	01d7e7b3          	or	a5,a5,t4
ffffffffc0200926:	016c6b33          	or	s6,s8,s6
ffffffffc020092a:	01146433          	or	s0,s0,a7
ffffffffc020092e:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc0200930:	1702                	slli	a4,a4,0x20
ffffffffc0200932:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200934:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200936:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200938:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc020093a:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020093e:	0167eb33          	or	s6,a5,s6
ffffffffc0200942:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200944:	855ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc0200948:	85a2                	mv	a1,s0
ffffffffc020094a:	00005517          	auipc	a0,0x5
ffffffffc020094e:	70e50513          	addi	a0,a0,1806 # ffffffffc0206058 <commands+0x158>
ffffffffc0200952:	847ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc0200956:	014b5613          	srli	a2,s6,0x14
ffffffffc020095a:	85da                	mv	a1,s6
ffffffffc020095c:	00005517          	auipc	a0,0x5
ffffffffc0200960:	71450513          	addi	a0,a0,1812 # ffffffffc0206070 <commands+0x170>
ffffffffc0200964:	835ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200968:	008b05b3          	add	a1,s6,s0
ffffffffc020096c:	15fd                	addi	a1,a1,-1
ffffffffc020096e:	00005517          	auipc	a0,0x5
ffffffffc0200972:	72250513          	addi	a0,a0,1826 # ffffffffc0206090 <commands+0x190>
ffffffffc0200976:	823ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("DTB init completed\n");
ffffffffc020097a:	00005517          	auipc	a0,0x5
ffffffffc020097e:	76650513          	addi	a0,a0,1894 # ffffffffc02060e0 <commands+0x1e0>
        memory_base = mem_base;
ffffffffc0200982:	000d2797          	auipc	a5,0xd2
ffffffffc0200986:	de87b723          	sd	s0,-530(a5) # ffffffffc02d2770 <memory_base>
        memory_size = mem_size;
ffffffffc020098a:	000d2797          	auipc	a5,0xd2
ffffffffc020098e:	df67b723          	sd	s6,-530(a5) # ffffffffc02d2778 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc0200992:	b3f5                	j	ffffffffc020077e <dtb_init+0x186>

ffffffffc0200994 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc0200994:	000d2517          	auipc	a0,0xd2
ffffffffc0200998:	ddc53503          	ld	a0,-548(a0) # ffffffffc02d2770 <memory_base>
ffffffffc020099c:	8082                	ret

ffffffffc020099e <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc020099e:	000d2517          	auipc	a0,0xd2
ffffffffc02009a2:	dda53503          	ld	a0,-550(a0) # ffffffffc02d2778 <memory_size>
ffffffffc02009a6:	8082                	ret

ffffffffc02009a8 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02009a8:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02009ac:	8082                	ret

ffffffffc02009ae <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02009ae:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02009b2:	8082                	ret

ffffffffc02009b4 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02009b4:	8082                	ret

ffffffffc02009b6 <idt_init>:
void idt_init(void)
{
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc02009b6:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc02009ba:	00000797          	auipc	a5,0x0
ffffffffc02009be:	49e78793          	addi	a5,a5,1182 # ffffffffc0200e58 <__alltraps>
ffffffffc02009c2:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc02009c6:	000407b7          	lui	a5,0x40
ffffffffc02009ca:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc02009ce:	8082                	ret

ffffffffc02009d0 <print_regs>:
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr)
{
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009d0:	610c                	ld	a1,0(a0)
{
ffffffffc02009d2:	1141                	addi	sp,sp,-16
ffffffffc02009d4:	e022                	sd	s0,0(sp)
ffffffffc02009d6:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009d8:	00005517          	auipc	a0,0x5
ffffffffc02009dc:	72050513          	addi	a0,a0,1824 # ffffffffc02060f8 <commands+0x1f8>
{
ffffffffc02009e0:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009e2:	fb6ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02009e6:	640c                	ld	a1,8(s0)
ffffffffc02009e8:	00005517          	auipc	a0,0x5
ffffffffc02009ec:	72850513          	addi	a0,a0,1832 # ffffffffc0206110 <commands+0x210>
ffffffffc02009f0:	fa8ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02009f4:	680c                	ld	a1,16(s0)
ffffffffc02009f6:	00005517          	auipc	a0,0x5
ffffffffc02009fa:	73250513          	addi	a0,a0,1842 # ffffffffc0206128 <commands+0x228>
ffffffffc02009fe:	f9aff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200a02:	6c0c                	ld	a1,24(s0)
ffffffffc0200a04:	00005517          	auipc	a0,0x5
ffffffffc0200a08:	73c50513          	addi	a0,a0,1852 # ffffffffc0206140 <commands+0x240>
ffffffffc0200a0c:	f8cff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200a10:	700c                	ld	a1,32(s0)
ffffffffc0200a12:	00005517          	auipc	a0,0x5
ffffffffc0200a16:	74650513          	addi	a0,a0,1862 # ffffffffc0206158 <commands+0x258>
ffffffffc0200a1a:	f7eff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200a1e:	740c                	ld	a1,40(s0)
ffffffffc0200a20:	00005517          	auipc	a0,0x5
ffffffffc0200a24:	75050513          	addi	a0,a0,1872 # ffffffffc0206170 <commands+0x270>
ffffffffc0200a28:	f70ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc0200a2c:	780c                	ld	a1,48(s0)
ffffffffc0200a2e:	00005517          	auipc	a0,0x5
ffffffffc0200a32:	75a50513          	addi	a0,a0,1882 # ffffffffc0206188 <commands+0x288>
ffffffffc0200a36:	f62ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200a3a:	7c0c                	ld	a1,56(s0)
ffffffffc0200a3c:	00005517          	auipc	a0,0x5
ffffffffc0200a40:	76450513          	addi	a0,a0,1892 # ffffffffc02061a0 <commands+0x2a0>
ffffffffc0200a44:	f54ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200a48:	602c                	ld	a1,64(s0)
ffffffffc0200a4a:	00005517          	auipc	a0,0x5
ffffffffc0200a4e:	76e50513          	addi	a0,a0,1902 # ffffffffc02061b8 <commands+0x2b8>
ffffffffc0200a52:	f46ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200a56:	642c                	ld	a1,72(s0)
ffffffffc0200a58:	00005517          	auipc	a0,0x5
ffffffffc0200a5c:	77850513          	addi	a0,a0,1912 # ffffffffc02061d0 <commands+0x2d0>
ffffffffc0200a60:	f38ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200a64:	682c                	ld	a1,80(s0)
ffffffffc0200a66:	00005517          	auipc	a0,0x5
ffffffffc0200a6a:	78250513          	addi	a0,a0,1922 # ffffffffc02061e8 <commands+0x2e8>
ffffffffc0200a6e:	f2aff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200a72:	6c2c                	ld	a1,88(s0)
ffffffffc0200a74:	00005517          	auipc	a0,0x5
ffffffffc0200a78:	78c50513          	addi	a0,a0,1932 # ffffffffc0206200 <commands+0x300>
ffffffffc0200a7c:	f1cff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200a80:	702c                	ld	a1,96(s0)
ffffffffc0200a82:	00005517          	auipc	a0,0x5
ffffffffc0200a86:	79650513          	addi	a0,a0,1942 # ffffffffc0206218 <commands+0x318>
ffffffffc0200a8a:	f0eff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200a8e:	742c                	ld	a1,104(s0)
ffffffffc0200a90:	00005517          	auipc	a0,0x5
ffffffffc0200a94:	7a050513          	addi	a0,a0,1952 # ffffffffc0206230 <commands+0x330>
ffffffffc0200a98:	f00ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200a9c:	782c                	ld	a1,112(s0)
ffffffffc0200a9e:	00005517          	auipc	a0,0x5
ffffffffc0200aa2:	7aa50513          	addi	a0,a0,1962 # ffffffffc0206248 <commands+0x348>
ffffffffc0200aa6:	ef2ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200aaa:	7c2c                	ld	a1,120(s0)
ffffffffc0200aac:	00005517          	auipc	a0,0x5
ffffffffc0200ab0:	7b450513          	addi	a0,a0,1972 # ffffffffc0206260 <commands+0x360>
ffffffffc0200ab4:	ee4ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200ab8:	604c                	ld	a1,128(s0)
ffffffffc0200aba:	00005517          	auipc	a0,0x5
ffffffffc0200abe:	7be50513          	addi	a0,a0,1982 # ffffffffc0206278 <commands+0x378>
ffffffffc0200ac2:	ed6ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200ac6:	644c                	ld	a1,136(s0)
ffffffffc0200ac8:	00005517          	auipc	a0,0x5
ffffffffc0200acc:	7c850513          	addi	a0,a0,1992 # ffffffffc0206290 <commands+0x390>
ffffffffc0200ad0:	ec8ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200ad4:	684c                	ld	a1,144(s0)
ffffffffc0200ad6:	00005517          	auipc	a0,0x5
ffffffffc0200ada:	7d250513          	addi	a0,a0,2002 # ffffffffc02062a8 <commands+0x3a8>
ffffffffc0200ade:	ebaff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200ae2:	6c4c                	ld	a1,152(s0)
ffffffffc0200ae4:	00005517          	auipc	a0,0x5
ffffffffc0200ae8:	7dc50513          	addi	a0,a0,2012 # ffffffffc02062c0 <commands+0x3c0>
ffffffffc0200aec:	eacff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200af0:	704c                	ld	a1,160(s0)
ffffffffc0200af2:	00005517          	auipc	a0,0x5
ffffffffc0200af6:	7e650513          	addi	a0,a0,2022 # ffffffffc02062d8 <commands+0x3d8>
ffffffffc0200afa:	e9eff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200afe:	744c                	ld	a1,168(s0)
ffffffffc0200b00:	00005517          	auipc	a0,0x5
ffffffffc0200b04:	7f050513          	addi	a0,a0,2032 # ffffffffc02062f0 <commands+0x3f0>
ffffffffc0200b08:	e90ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200b0c:	784c                	ld	a1,176(s0)
ffffffffc0200b0e:	00005517          	auipc	a0,0x5
ffffffffc0200b12:	7fa50513          	addi	a0,a0,2042 # ffffffffc0206308 <commands+0x408>
ffffffffc0200b16:	e82ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200b1a:	7c4c                	ld	a1,184(s0)
ffffffffc0200b1c:	00006517          	auipc	a0,0x6
ffffffffc0200b20:	80450513          	addi	a0,a0,-2044 # ffffffffc0206320 <commands+0x420>
ffffffffc0200b24:	e74ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200b28:	606c                	ld	a1,192(s0)
ffffffffc0200b2a:	00006517          	auipc	a0,0x6
ffffffffc0200b2e:	80e50513          	addi	a0,a0,-2034 # ffffffffc0206338 <commands+0x438>
ffffffffc0200b32:	e66ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200b36:	646c                	ld	a1,200(s0)
ffffffffc0200b38:	00006517          	auipc	a0,0x6
ffffffffc0200b3c:	81850513          	addi	a0,a0,-2024 # ffffffffc0206350 <commands+0x450>
ffffffffc0200b40:	e58ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200b44:	686c                	ld	a1,208(s0)
ffffffffc0200b46:	00006517          	auipc	a0,0x6
ffffffffc0200b4a:	82250513          	addi	a0,a0,-2014 # ffffffffc0206368 <commands+0x468>
ffffffffc0200b4e:	e4aff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200b52:	6c6c                	ld	a1,216(s0)
ffffffffc0200b54:	00006517          	auipc	a0,0x6
ffffffffc0200b58:	82c50513          	addi	a0,a0,-2004 # ffffffffc0206380 <commands+0x480>
ffffffffc0200b5c:	e3cff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200b60:	706c                	ld	a1,224(s0)
ffffffffc0200b62:	00006517          	auipc	a0,0x6
ffffffffc0200b66:	83650513          	addi	a0,a0,-1994 # ffffffffc0206398 <commands+0x498>
ffffffffc0200b6a:	e2eff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200b6e:	746c                	ld	a1,232(s0)
ffffffffc0200b70:	00006517          	auipc	a0,0x6
ffffffffc0200b74:	84050513          	addi	a0,a0,-1984 # ffffffffc02063b0 <commands+0x4b0>
ffffffffc0200b78:	e20ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200b7c:	786c                	ld	a1,240(s0)
ffffffffc0200b7e:	00006517          	auipc	a0,0x6
ffffffffc0200b82:	84a50513          	addi	a0,a0,-1974 # ffffffffc02063c8 <commands+0x4c8>
ffffffffc0200b86:	e12ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b8a:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200b8c:	6402                	ld	s0,0(sp)
ffffffffc0200b8e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b90:	00006517          	auipc	a0,0x6
ffffffffc0200b94:	85050513          	addi	a0,a0,-1968 # ffffffffc02063e0 <commands+0x4e0>
}
ffffffffc0200b98:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b9a:	dfeff06f          	j	ffffffffc0200198 <cprintf>

ffffffffc0200b9e <print_trapframe>:
{
ffffffffc0200b9e:	1141                	addi	sp,sp,-16
ffffffffc0200ba0:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200ba2:	85aa                	mv	a1,a0
{
ffffffffc0200ba4:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200ba6:	00006517          	auipc	a0,0x6
ffffffffc0200baa:	85250513          	addi	a0,a0,-1966 # ffffffffc02063f8 <commands+0x4f8>
{
ffffffffc0200bae:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200bb0:	de8ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200bb4:	8522                	mv	a0,s0
ffffffffc0200bb6:	e1bff0ef          	jal	ra,ffffffffc02009d0 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200bba:	10043583          	ld	a1,256(s0)
ffffffffc0200bbe:	00006517          	auipc	a0,0x6
ffffffffc0200bc2:	85250513          	addi	a0,a0,-1966 # ffffffffc0206410 <commands+0x510>
ffffffffc0200bc6:	dd2ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200bca:	10843583          	ld	a1,264(s0)
ffffffffc0200bce:	00006517          	auipc	a0,0x6
ffffffffc0200bd2:	85a50513          	addi	a0,a0,-1958 # ffffffffc0206428 <commands+0x528>
ffffffffc0200bd6:	dc2ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200bda:	11043583          	ld	a1,272(s0)
ffffffffc0200bde:	00006517          	auipc	a0,0x6
ffffffffc0200be2:	86250513          	addi	a0,a0,-1950 # ffffffffc0206440 <commands+0x540>
ffffffffc0200be6:	db2ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bea:	11843583          	ld	a1,280(s0)
}
ffffffffc0200bee:	6402                	ld	s0,0(sp)
ffffffffc0200bf0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bf2:	00006517          	auipc	a0,0x6
ffffffffc0200bf6:	85e50513          	addi	a0,a0,-1954 # ffffffffc0206450 <commands+0x550>
}
ffffffffc0200bfa:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bfc:	d9cff06f          	j	ffffffffc0200198 <cprintf>

ffffffffc0200c00 <interrupt_handler>:

extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf)
{
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200c00:	11853783          	ld	a5,280(a0)
ffffffffc0200c04:	472d                	li	a4,11
ffffffffc0200c06:	0786                	slli	a5,a5,0x1
ffffffffc0200c08:	8385                	srli	a5,a5,0x1
ffffffffc0200c0a:	08f76463          	bltu	a4,a5,ffffffffc0200c92 <interrupt_handler+0x92>
ffffffffc0200c0e:	00006717          	auipc	a4,0x6
ffffffffc0200c12:	90a70713          	addi	a4,a4,-1782 # ffffffffc0206518 <commands+0x618>
ffffffffc0200c16:	078a                	slli	a5,a5,0x2
ffffffffc0200c18:	97ba                	add	a5,a5,a4
ffffffffc0200c1a:	439c                	lw	a5,0(a5)
ffffffffc0200c1c:	97ba                	add	a5,a5,a4
ffffffffc0200c1e:	8782                	jr	a5
        break;
    case IRQ_H_SOFT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_SOFT:
        cprintf("Machine software interrupt\n");
ffffffffc0200c20:	00006517          	auipc	a0,0x6
ffffffffc0200c24:	8a850513          	addi	a0,a0,-1880 # ffffffffc02064c8 <commands+0x5c8>
ffffffffc0200c28:	d70ff06f          	j	ffffffffc0200198 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200c2c:	00006517          	auipc	a0,0x6
ffffffffc0200c30:	87c50513          	addi	a0,a0,-1924 # ffffffffc02064a8 <commands+0x5a8>
ffffffffc0200c34:	d64ff06f          	j	ffffffffc0200198 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200c38:	00006517          	auipc	a0,0x6
ffffffffc0200c3c:	83050513          	addi	a0,a0,-2000 # ffffffffc0206468 <commands+0x568>
ffffffffc0200c40:	d58ff06f          	j	ffffffffc0200198 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200c44:	00006517          	auipc	a0,0x6
ffffffffc0200c48:	84450513          	addi	a0,a0,-1980 # ffffffffc0206488 <commands+0x588>
ffffffffc0200c4c:	d4cff06f          	j	ffffffffc0200198 <cprintf>
{
ffffffffc0200c50:	1141                	addi	sp,sp,-16
ffffffffc0200c52:	e022                	sd	s0,0(sp)
ffffffffc0200c54:	e406                	sd	ra,8(sp)
ffffffffc0200c56:	842a                	mv	s0,a0
         *(2)计数器（ticks）加一
         *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
         * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
         */
         
        clock_set_next_event();//发生这次时钟中断的时候，我们要设置下一次时钟中断
ffffffffc0200c58:	917ff0ef          	jal	ra,ffffffffc020056e <clock_set_next_event>
        if (++ticks % TICK_NUM == 0) {
ffffffffc0200c5c:	000d2697          	auipc	a3,0xd2
ffffffffc0200c60:	b0c68693          	addi	a3,a3,-1268 # ffffffffc02d2768 <ticks>
ffffffffc0200c64:	629c                	ld	a5,0(a3)
ffffffffc0200c66:	06400713          	li	a4,100
ffffffffc0200c6a:	0785                	addi	a5,a5,1
ffffffffc0200c6c:	02e7f733          	remu	a4,a5,a4
ffffffffc0200c70:	e29c                	sd	a5,0(a3)
ffffffffc0200c72:	c30d                	beqz	a4,ffffffffc0200c94 <interrupt_handler+0x94>
            }
        }

        // lab6: 2310137  (update LAB3 steps)
        //  在时钟中断时调用调度器的 sched_class_proc_tick 函数
        if (current != NULL) {
ffffffffc0200c74:	000d2517          	auipc	a0,0xd2
ffffffffc0200c78:	b4c53503          	ld	a0,-1204(a0) # ffffffffc02d27c0 <current>
ffffffffc0200c7c:	e125                	bnez	a0,ffffffffc0200cdc <interrupt_handler+0xdc>
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200c7e:	60a2                	ld	ra,8(sp)
ffffffffc0200c80:	6402                	ld	s0,0(sp)
ffffffffc0200c82:	0141                	addi	sp,sp,16
ffffffffc0200c84:	8082                	ret
        cprintf("Supervisor external interrupt\n");
ffffffffc0200c86:	00006517          	auipc	a0,0x6
ffffffffc0200c8a:	87250513          	addi	a0,a0,-1934 # ffffffffc02064f8 <commands+0x5f8>
ffffffffc0200c8e:	d0aff06f          	j	ffffffffc0200198 <cprintf>
        print_trapframe(tf);
ffffffffc0200c92:	b731                	j	ffffffffc0200b9e <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200c94:	06400593          	li	a1,100
ffffffffc0200c98:	00006517          	auipc	a0,0x6
ffffffffc0200c9c:	85050513          	addi	a0,a0,-1968 # ffffffffc02064e8 <commands+0x5e8>
ffffffffc0200ca0:	cf8ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
            num++; // 打印次数加一
ffffffffc0200ca4:	000d2717          	auipc	a4,0xd2
ffffffffc0200ca8:	adc70713          	addi	a4,a4,-1316 # ffffffffc02d2780 <num>
ffffffffc0200cac:	631c                	ld	a5,0(a4)
            if (num == 30) {
ffffffffc0200cae:	46f9                	li	a3,30
            num++; // 打印次数加一
ffffffffc0200cb0:	0785                	addi	a5,a5,1
ffffffffc0200cb2:	e31c                	sd	a5,0(a4)
            if (num == 30) {
ffffffffc0200cb4:	00d79863          	bne	a5,a3,ffffffffc0200cc4 <interrupt_handler+0xc4>
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200cb8:	4501                	li	a0,0
ffffffffc0200cba:	4581                	li	a1,0
ffffffffc0200cbc:	4601                	li	a2,0
ffffffffc0200cbe:	48a1                	li	a7,8
ffffffffc0200cc0:	00000073          	ecall
            if(current != NULL && (tf->status & SSTATUS_SPP) == 0) {
ffffffffc0200cc4:	000d2517          	auipc	a0,0xd2
ffffffffc0200cc8:	afc53503          	ld	a0,-1284(a0) # ffffffffc02d27c0 <current>
ffffffffc0200ccc:	d94d                	beqz	a0,ffffffffc0200c7e <interrupt_handler+0x7e>
ffffffffc0200cce:	10043783          	ld	a5,256(s0)
ffffffffc0200cd2:	1007f793          	andi	a5,a5,256
ffffffffc0200cd6:	e399                	bnez	a5,ffffffffc0200cdc <interrupt_handler+0xdc>
                current->need_resched = 1;
ffffffffc0200cd8:	4785                	li	a5,1
ffffffffc0200cda:	ed1c                	sd	a5,24(a0)
}
ffffffffc0200cdc:	6402                	ld	s0,0(sp)
ffffffffc0200cde:	60a2                	ld	ra,8(sp)
ffffffffc0200ce0:	0141                	addi	sp,sp,16
            sched_class_proc_tick(current);
ffffffffc0200ce2:	7fa0406f          	j	ffffffffc02054dc <sched_class_proc_tick>

ffffffffc0200ce6 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf, uintptr_t kstacktop);
void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
ffffffffc0200ce6:	11853783          	ld	a5,280(a0)
{
ffffffffc0200cea:	1141                	addi	sp,sp,-16
ffffffffc0200cec:	e022                	sd	s0,0(sp)
ffffffffc0200cee:	e406                	sd	ra,8(sp)
ffffffffc0200cf0:	473d                	li	a4,15
ffffffffc0200cf2:	842a                	mv	s0,a0
ffffffffc0200cf4:	0af76b63          	bltu	a4,a5,ffffffffc0200daa <exception_handler+0xc4>
ffffffffc0200cf8:	00006717          	auipc	a4,0x6
ffffffffc0200cfc:	9e070713          	addi	a4,a4,-1568 # ffffffffc02066d8 <commands+0x7d8>
ffffffffc0200d00:	078a                	slli	a5,a5,0x2
ffffffffc0200d02:	97ba                	add	a5,a5,a4
ffffffffc0200d04:	439c                	lw	a5,0(a5)
ffffffffc0200d06:	97ba                	add	a5,a5,a4
ffffffffc0200d08:	8782                	jr	a5
        // cprintf("Environment call from U-mode\n");
        tf->epc += 4;
        syscall();
        break;
    case CAUSE_SUPERVISOR_ECALL:
        cprintf("Environment call from S-mode\n");
ffffffffc0200d0a:	00006517          	auipc	a0,0x6
ffffffffc0200d0e:	92650513          	addi	a0,a0,-1754 # ffffffffc0206630 <commands+0x730>
ffffffffc0200d12:	c86ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
        tf->epc += 4;
ffffffffc0200d16:	10843783          	ld	a5,264(s0)
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200d1a:	60a2                	ld	ra,8(sp)
        tf->epc += 4;
ffffffffc0200d1c:	0791                	addi	a5,a5,4
ffffffffc0200d1e:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200d22:	6402                	ld	s0,0(sp)
ffffffffc0200d24:	0141                	addi	sp,sp,16
        syscall();
ffffffffc0200d26:	2210406f          	j	ffffffffc0205746 <syscall>
        cprintf("Environment call from H-mode\n");
ffffffffc0200d2a:	00006517          	auipc	a0,0x6
ffffffffc0200d2e:	92650513          	addi	a0,a0,-1754 # ffffffffc0206650 <commands+0x750>
}
ffffffffc0200d32:	6402                	ld	s0,0(sp)
ffffffffc0200d34:	60a2                	ld	ra,8(sp)
ffffffffc0200d36:	0141                	addi	sp,sp,16
        cprintf("Instruction access fault\n");
ffffffffc0200d38:	c60ff06f          	j	ffffffffc0200198 <cprintf>
        cprintf("Environment call from M-mode\n");
ffffffffc0200d3c:	00006517          	auipc	a0,0x6
ffffffffc0200d40:	93450513          	addi	a0,a0,-1740 # ffffffffc0206670 <commands+0x770>
ffffffffc0200d44:	b7fd                	j	ffffffffc0200d32 <exception_handler+0x4c>
        cprintf("Instruction page fault\n");
ffffffffc0200d46:	00006517          	auipc	a0,0x6
ffffffffc0200d4a:	94a50513          	addi	a0,a0,-1718 # ffffffffc0206690 <commands+0x790>
ffffffffc0200d4e:	b7d5                	j	ffffffffc0200d32 <exception_handler+0x4c>
        cprintf("Load page fault\n");
ffffffffc0200d50:	00006517          	auipc	a0,0x6
ffffffffc0200d54:	95850513          	addi	a0,a0,-1704 # ffffffffc02066a8 <commands+0x7a8>
ffffffffc0200d58:	bfe9                	j	ffffffffc0200d32 <exception_handler+0x4c>
        cprintf("Store/AMO page fault\n");
ffffffffc0200d5a:	00006517          	auipc	a0,0x6
ffffffffc0200d5e:	96650513          	addi	a0,a0,-1690 # ffffffffc02066c0 <commands+0x7c0>
ffffffffc0200d62:	bfc1                	j	ffffffffc0200d32 <exception_handler+0x4c>
        cprintf("Instruction address misaligned\n");
ffffffffc0200d64:	00005517          	auipc	a0,0x5
ffffffffc0200d68:	7e450513          	addi	a0,a0,2020 # ffffffffc0206548 <commands+0x648>
ffffffffc0200d6c:	b7d9                	j	ffffffffc0200d32 <exception_handler+0x4c>
        cprintf("Instruction access fault\n");
ffffffffc0200d6e:	00005517          	auipc	a0,0x5
ffffffffc0200d72:	7fa50513          	addi	a0,a0,2042 # ffffffffc0206568 <commands+0x668>
ffffffffc0200d76:	bf75                	j	ffffffffc0200d32 <exception_handler+0x4c>
        cprintf("Illegal instruction\n");
ffffffffc0200d78:	00006517          	auipc	a0,0x6
ffffffffc0200d7c:	81050513          	addi	a0,a0,-2032 # ffffffffc0206588 <commands+0x688>
ffffffffc0200d80:	bf4d                	j	ffffffffc0200d32 <exception_handler+0x4c>
        cprintf("Breakpoint\n");
ffffffffc0200d82:	00006517          	auipc	a0,0x6
ffffffffc0200d86:	81e50513          	addi	a0,a0,-2018 # ffffffffc02065a0 <commands+0x6a0>
ffffffffc0200d8a:	b765                	j	ffffffffc0200d32 <exception_handler+0x4c>
        cprintf("Load address misaligned\n");
ffffffffc0200d8c:	00006517          	auipc	a0,0x6
ffffffffc0200d90:	82450513          	addi	a0,a0,-2012 # ffffffffc02065b0 <commands+0x6b0>
ffffffffc0200d94:	bf79                	j	ffffffffc0200d32 <exception_handler+0x4c>
        cprintf("Load access fault\n");
ffffffffc0200d96:	00006517          	auipc	a0,0x6
ffffffffc0200d9a:	83a50513          	addi	a0,a0,-1990 # ffffffffc02065d0 <commands+0x6d0>
ffffffffc0200d9e:	bf51                	j	ffffffffc0200d32 <exception_handler+0x4c>
        cprintf("Store/AMO access fault\n");
ffffffffc0200da0:	00006517          	auipc	a0,0x6
ffffffffc0200da4:	87850513          	addi	a0,a0,-1928 # ffffffffc0206618 <commands+0x718>
ffffffffc0200da8:	b769                	j	ffffffffc0200d32 <exception_handler+0x4c>
        print_trapframe(tf);
ffffffffc0200daa:	8522                	mv	a0,s0
}
ffffffffc0200dac:	6402                	ld	s0,0(sp)
ffffffffc0200dae:	60a2                	ld	ra,8(sp)
ffffffffc0200db0:	0141                	addi	sp,sp,16
        print_trapframe(tf);
ffffffffc0200db2:	b3f5                	j	ffffffffc0200b9e <print_trapframe>
        panic("AMO address misaligned\n");
ffffffffc0200db4:	00006617          	auipc	a2,0x6
ffffffffc0200db8:	83460613          	addi	a2,a2,-1996 # ffffffffc02065e8 <commands+0x6e8>
ffffffffc0200dbc:	0d100593          	li	a1,209
ffffffffc0200dc0:	00006517          	auipc	a0,0x6
ffffffffc0200dc4:	84050513          	addi	a0,a0,-1984 # ffffffffc0206600 <commands+0x700>
ffffffffc0200dc8:	ecaff0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0200dcc <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf)
{
ffffffffc0200dcc:	1101                	addi	sp,sp,-32
ffffffffc0200dce:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
    //    cputs("some trap");
    if (current == NULL)
ffffffffc0200dd0:	000d2417          	auipc	s0,0xd2
ffffffffc0200dd4:	9f040413          	addi	s0,s0,-1552 # ffffffffc02d27c0 <current>
ffffffffc0200dd8:	6018                	ld	a4,0(s0)
{
ffffffffc0200dda:	ec06                	sd	ra,24(sp)
ffffffffc0200ddc:	e426                	sd	s1,8(sp)
ffffffffc0200dde:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0)
ffffffffc0200de0:	11853683          	ld	a3,280(a0)
    if (current == NULL)
ffffffffc0200de4:	cf1d                	beqz	a4,ffffffffc0200e22 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200de6:	10053483          	ld	s1,256(a0)
    {
        trap_dispatch(tf);
    }
    else
    {
        struct trapframe *otf = current->tf;
ffffffffc0200dea:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200dee:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200df0:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0)
ffffffffc0200df4:	0206c463          	bltz	a3,ffffffffc0200e1c <trap+0x50>
        exception_handler(tf);
ffffffffc0200df8:	eefff0ef          	jal	ra,ffffffffc0200ce6 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200dfc:	601c                	ld	a5,0(s0)
ffffffffc0200dfe:	0b27b023          	sd	s2,160(a5) # 400a0 <_binary_obj___user_matrix_out_size+0x33978>
        if (!in_kernel)
ffffffffc0200e02:	e499                	bnez	s1,ffffffffc0200e10 <trap+0x44>
        {
            if (current->flags & PF_EXITING)
ffffffffc0200e04:	0b07a703          	lw	a4,176(a5)
ffffffffc0200e08:	8b05                	andi	a4,a4,1
ffffffffc0200e0a:	e329                	bnez	a4,ffffffffc0200e4c <trap+0x80>
            {
                do_exit(-E_KILLED);
            }
            if (current->need_resched)
ffffffffc0200e0c:	6f9c                	ld	a5,24(a5)
ffffffffc0200e0e:	eb85                	bnez	a5,ffffffffc0200e3e <trap+0x72>
            {
                schedule();
            }
        }
    }
}
ffffffffc0200e10:	60e2                	ld	ra,24(sp)
ffffffffc0200e12:	6442                	ld	s0,16(sp)
ffffffffc0200e14:	64a2                	ld	s1,8(sp)
ffffffffc0200e16:	6902                	ld	s2,0(sp)
ffffffffc0200e18:	6105                	addi	sp,sp,32
ffffffffc0200e1a:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200e1c:	de5ff0ef          	jal	ra,ffffffffc0200c00 <interrupt_handler>
ffffffffc0200e20:	bff1                	j	ffffffffc0200dfc <trap+0x30>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200e22:	0006c863          	bltz	a3,ffffffffc0200e32 <trap+0x66>
}
ffffffffc0200e26:	6442                	ld	s0,16(sp)
ffffffffc0200e28:	60e2                	ld	ra,24(sp)
ffffffffc0200e2a:	64a2                	ld	s1,8(sp)
ffffffffc0200e2c:	6902                	ld	s2,0(sp)
ffffffffc0200e2e:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200e30:	bd5d                	j	ffffffffc0200ce6 <exception_handler>
}
ffffffffc0200e32:	6442                	ld	s0,16(sp)
ffffffffc0200e34:	60e2                	ld	ra,24(sp)
ffffffffc0200e36:	64a2                	ld	s1,8(sp)
ffffffffc0200e38:	6902                	ld	s2,0(sp)
ffffffffc0200e3a:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200e3c:	b3d1                	j	ffffffffc0200c00 <interrupt_handler>
}
ffffffffc0200e3e:	6442                	ld	s0,16(sp)
ffffffffc0200e40:	60e2                	ld	ra,24(sp)
ffffffffc0200e42:	64a2                	ld	s1,8(sp)
ffffffffc0200e44:	6902                	ld	s2,0(sp)
ffffffffc0200e46:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200e48:	7c00406f          	j	ffffffffc0205608 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200e4c:	555d                	li	a0,-9
ffffffffc0200e4e:	480030ef          	jal	ra,ffffffffc02042ce <do_exit>
            if (current->need_resched)
ffffffffc0200e52:	601c                	ld	a5,0(s0)
ffffffffc0200e54:	bf65                	j	ffffffffc0200e0c <trap+0x40>
	...

ffffffffc0200e58 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200e58:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200e5c:	00011463          	bnez	sp,ffffffffc0200e64 <__alltraps+0xc>
ffffffffc0200e60:	14002173          	csrr	sp,sscratch
ffffffffc0200e64:	712d                	addi	sp,sp,-288
ffffffffc0200e66:	e002                	sd	zero,0(sp)
ffffffffc0200e68:	e406                	sd	ra,8(sp)
ffffffffc0200e6a:	ec0e                	sd	gp,24(sp)
ffffffffc0200e6c:	f012                	sd	tp,32(sp)
ffffffffc0200e6e:	f416                	sd	t0,40(sp)
ffffffffc0200e70:	f81a                	sd	t1,48(sp)
ffffffffc0200e72:	fc1e                	sd	t2,56(sp)
ffffffffc0200e74:	e0a2                	sd	s0,64(sp)
ffffffffc0200e76:	e4a6                	sd	s1,72(sp)
ffffffffc0200e78:	e8aa                	sd	a0,80(sp)
ffffffffc0200e7a:	ecae                	sd	a1,88(sp)
ffffffffc0200e7c:	f0b2                	sd	a2,96(sp)
ffffffffc0200e7e:	f4b6                	sd	a3,104(sp)
ffffffffc0200e80:	f8ba                	sd	a4,112(sp)
ffffffffc0200e82:	fcbe                	sd	a5,120(sp)
ffffffffc0200e84:	e142                	sd	a6,128(sp)
ffffffffc0200e86:	e546                	sd	a7,136(sp)
ffffffffc0200e88:	e94a                	sd	s2,144(sp)
ffffffffc0200e8a:	ed4e                	sd	s3,152(sp)
ffffffffc0200e8c:	f152                	sd	s4,160(sp)
ffffffffc0200e8e:	f556                	sd	s5,168(sp)
ffffffffc0200e90:	f95a                	sd	s6,176(sp)
ffffffffc0200e92:	fd5e                	sd	s7,184(sp)
ffffffffc0200e94:	e1e2                	sd	s8,192(sp)
ffffffffc0200e96:	e5e6                	sd	s9,200(sp)
ffffffffc0200e98:	e9ea                	sd	s10,208(sp)
ffffffffc0200e9a:	edee                	sd	s11,216(sp)
ffffffffc0200e9c:	f1f2                	sd	t3,224(sp)
ffffffffc0200e9e:	f5f6                	sd	t4,232(sp)
ffffffffc0200ea0:	f9fa                	sd	t5,240(sp)
ffffffffc0200ea2:	fdfe                	sd	t6,248(sp)
ffffffffc0200ea4:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200ea8:	100024f3          	csrr	s1,sstatus
ffffffffc0200eac:	14102973          	csrr	s2,sepc
ffffffffc0200eb0:	143029f3          	csrr	s3,stval
ffffffffc0200eb4:	14202a73          	csrr	s4,scause
ffffffffc0200eb8:	e822                	sd	s0,16(sp)
ffffffffc0200eba:	e226                	sd	s1,256(sp)
ffffffffc0200ebc:	e64a                	sd	s2,264(sp)
ffffffffc0200ebe:	ea4e                	sd	s3,272(sp)
ffffffffc0200ec0:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200ec2:	850a                	mv	a0,sp
    jal trap
ffffffffc0200ec4:	f09ff0ef          	jal	ra,ffffffffc0200dcc <trap>

ffffffffc0200ec8 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200ec8:	6492                	ld	s1,256(sp)
ffffffffc0200eca:	6932                	ld	s2,264(sp)
ffffffffc0200ecc:	1004f413          	andi	s0,s1,256
ffffffffc0200ed0:	e401                	bnez	s0,ffffffffc0200ed8 <__trapret+0x10>
ffffffffc0200ed2:	1200                	addi	s0,sp,288
ffffffffc0200ed4:	14041073          	csrw	sscratch,s0
ffffffffc0200ed8:	10049073          	csrw	sstatus,s1
ffffffffc0200edc:	14191073          	csrw	sepc,s2
ffffffffc0200ee0:	60a2                	ld	ra,8(sp)
ffffffffc0200ee2:	61e2                	ld	gp,24(sp)
ffffffffc0200ee4:	7202                	ld	tp,32(sp)
ffffffffc0200ee6:	72a2                	ld	t0,40(sp)
ffffffffc0200ee8:	7342                	ld	t1,48(sp)
ffffffffc0200eea:	73e2                	ld	t2,56(sp)
ffffffffc0200eec:	6406                	ld	s0,64(sp)
ffffffffc0200eee:	64a6                	ld	s1,72(sp)
ffffffffc0200ef0:	6546                	ld	a0,80(sp)
ffffffffc0200ef2:	65e6                	ld	a1,88(sp)
ffffffffc0200ef4:	7606                	ld	a2,96(sp)
ffffffffc0200ef6:	76a6                	ld	a3,104(sp)
ffffffffc0200ef8:	7746                	ld	a4,112(sp)
ffffffffc0200efa:	77e6                	ld	a5,120(sp)
ffffffffc0200efc:	680a                	ld	a6,128(sp)
ffffffffc0200efe:	68aa                	ld	a7,136(sp)
ffffffffc0200f00:	694a                	ld	s2,144(sp)
ffffffffc0200f02:	69ea                	ld	s3,152(sp)
ffffffffc0200f04:	7a0a                	ld	s4,160(sp)
ffffffffc0200f06:	7aaa                	ld	s5,168(sp)
ffffffffc0200f08:	7b4a                	ld	s6,176(sp)
ffffffffc0200f0a:	7bea                	ld	s7,184(sp)
ffffffffc0200f0c:	6c0e                	ld	s8,192(sp)
ffffffffc0200f0e:	6cae                	ld	s9,200(sp)
ffffffffc0200f10:	6d4e                	ld	s10,208(sp)
ffffffffc0200f12:	6dee                	ld	s11,216(sp)
ffffffffc0200f14:	7e0e                	ld	t3,224(sp)
ffffffffc0200f16:	7eae                	ld	t4,232(sp)
ffffffffc0200f18:	7f4e                	ld	t5,240(sp)
ffffffffc0200f1a:	7fee                	ld	t6,248(sp)
ffffffffc0200f1c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200f1e:	10200073          	sret

ffffffffc0200f22 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200f22:	812a                	mv	sp,a0
ffffffffc0200f24:	b755                	j	ffffffffc0200ec8 <__trapret>

ffffffffc0200f26 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200f26:	000cd797          	auipc	a5,0xcd
ffffffffc0200f2a:	7e278793          	addi	a5,a5,2018 # ffffffffc02ce708 <free_area>
ffffffffc0200f2e:	e79c                	sd	a5,8(a5)
ffffffffc0200f30:	e39c                	sd	a5,0(a5)

static void
default_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200f32:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200f36:	8082                	ret

ffffffffc0200f38 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc0200f38:	000cd517          	auipc	a0,0xcd
ffffffffc0200f3c:	7e056503          	lwu	a0,2016(a0) # ffffffffc02ce718 <free_area+0x10>
ffffffffc0200f40:	8082                	ret

ffffffffc0200f42 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
ffffffffc0200f42:	715d                	addi	sp,sp,-80
ffffffffc0200f44:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200f46:	000cd417          	auipc	s0,0xcd
ffffffffc0200f4a:	7c240413          	addi	s0,s0,1986 # ffffffffc02ce708 <free_area>
ffffffffc0200f4e:	641c                	ld	a5,8(s0)
ffffffffc0200f50:	e486                	sd	ra,72(sp)
ffffffffc0200f52:	fc26                	sd	s1,56(sp)
ffffffffc0200f54:	f84a                	sd	s2,48(sp)
ffffffffc0200f56:	f44e                	sd	s3,40(sp)
ffffffffc0200f58:	f052                	sd	s4,32(sp)
ffffffffc0200f5a:	ec56                	sd	s5,24(sp)
ffffffffc0200f5c:	e85a                	sd	s6,16(sp)
ffffffffc0200f5e:	e45e                	sd	s7,8(sp)
ffffffffc0200f60:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0200f62:	2a878d63          	beq	a5,s0,ffffffffc020121c <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0200f66:	4481                	li	s1,0
ffffffffc0200f68:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200f6a:	ff07b703          	ld	a4,-16(a5)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200f6e:	8b09                	andi	a4,a4,2
ffffffffc0200f70:	2a070a63          	beqz	a4,ffffffffc0201224 <default_check+0x2e2>
        count++, total += p->property;
ffffffffc0200f74:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200f78:	679c                	ld	a5,8(a5)
ffffffffc0200f7a:	2905                	addiw	s2,s2,1
ffffffffc0200f7c:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0200f7e:	fe8796e3          	bne	a5,s0,ffffffffc0200f6a <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200f82:	89a6                	mv	s3,s1
ffffffffc0200f84:	6df000ef          	jal	ra,ffffffffc0201e62 <nr_free_pages>
ffffffffc0200f88:	6f351e63          	bne	a0,s3,ffffffffc0201684 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f8c:	4505                	li	a0,1
ffffffffc0200f8e:	657000ef          	jal	ra,ffffffffc0201de4 <alloc_pages>
ffffffffc0200f92:	8aaa                	mv	s5,a0
ffffffffc0200f94:	42050863          	beqz	a0,ffffffffc02013c4 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f98:	4505                	li	a0,1
ffffffffc0200f9a:	64b000ef          	jal	ra,ffffffffc0201de4 <alloc_pages>
ffffffffc0200f9e:	89aa                	mv	s3,a0
ffffffffc0200fa0:	70050263          	beqz	a0,ffffffffc02016a4 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fa4:	4505                	li	a0,1
ffffffffc0200fa6:	63f000ef          	jal	ra,ffffffffc0201de4 <alloc_pages>
ffffffffc0200faa:	8a2a                	mv	s4,a0
ffffffffc0200fac:	48050c63          	beqz	a0,ffffffffc0201444 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200fb0:	293a8a63          	beq	s5,s3,ffffffffc0201244 <default_check+0x302>
ffffffffc0200fb4:	28aa8863          	beq	s5,a0,ffffffffc0201244 <default_check+0x302>
ffffffffc0200fb8:	28a98663          	beq	s3,a0,ffffffffc0201244 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200fbc:	000aa783          	lw	a5,0(s5)
ffffffffc0200fc0:	2a079263          	bnez	a5,ffffffffc0201264 <default_check+0x322>
ffffffffc0200fc4:	0009a783          	lw	a5,0(s3)
ffffffffc0200fc8:	28079e63          	bnez	a5,ffffffffc0201264 <default_check+0x322>
ffffffffc0200fcc:	411c                	lw	a5,0(a0)
ffffffffc0200fce:	28079b63          	bnez	a5,ffffffffc0201264 <default_check+0x322>
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page)
{
    return page - pages + nbase;
ffffffffc0200fd2:	000d1797          	auipc	a5,0xd1
ffffffffc0200fd6:	7d67b783          	ld	a5,2006(a5) # ffffffffc02d27a8 <pages>
ffffffffc0200fda:	40fa8733          	sub	a4,s5,a5
ffffffffc0200fde:	00007617          	auipc	a2,0x7
ffffffffc0200fe2:	55a63603          	ld	a2,1370(a2) # ffffffffc0208538 <nbase>
ffffffffc0200fe6:	8719                	srai	a4,a4,0x6
ffffffffc0200fe8:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200fea:	000d1697          	auipc	a3,0xd1
ffffffffc0200fee:	7b66b683          	ld	a3,1974(a3) # ffffffffc02d27a0 <npage>
ffffffffc0200ff2:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page)
{
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ff4:	0732                	slli	a4,a4,0xc
ffffffffc0200ff6:	28d77763          	bgeu	a4,a3,ffffffffc0201284 <default_check+0x342>
    return page - pages + nbase;
ffffffffc0200ffa:	40f98733          	sub	a4,s3,a5
ffffffffc0200ffe:	8719                	srai	a4,a4,0x6
ffffffffc0201000:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201002:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201004:	4cd77063          	bgeu	a4,a3,ffffffffc02014c4 <default_check+0x582>
    return page - pages + nbase;
ffffffffc0201008:	40f507b3          	sub	a5,a0,a5
ffffffffc020100c:	8799                	srai	a5,a5,0x6
ffffffffc020100e:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201010:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201012:	30d7f963          	bgeu	a5,a3,ffffffffc0201324 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0201016:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201018:	00043c03          	ld	s8,0(s0)
ffffffffc020101c:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0201020:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0201024:	e400                	sd	s0,8(s0)
ffffffffc0201026:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0201028:	000cd797          	auipc	a5,0xcd
ffffffffc020102c:	6e07a823          	sw	zero,1776(a5) # ffffffffc02ce718 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201030:	5b5000ef          	jal	ra,ffffffffc0201de4 <alloc_pages>
ffffffffc0201034:	2c051863          	bnez	a0,ffffffffc0201304 <default_check+0x3c2>
    free_page(p0);
ffffffffc0201038:	4585                	li	a1,1
ffffffffc020103a:	8556                	mv	a0,s5
ffffffffc020103c:	5e7000ef          	jal	ra,ffffffffc0201e22 <free_pages>
    free_page(p1);
ffffffffc0201040:	4585                	li	a1,1
ffffffffc0201042:	854e                	mv	a0,s3
ffffffffc0201044:	5df000ef          	jal	ra,ffffffffc0201e22 <free_pages>
    free_page(p2);
ffffffffc0201048:	4585                	li	a1,1
ffffffffc020104a:	8552                	mv	a0,s4
ffffffffc020104c:	5d7000ef          	jal	ra,ffffffffc0201e22 <free_pages>
    assert(nr_free == 3);
ffffffffc0201050:	4818                	lw	a4,16(s0)
ffffffffc0201052:	478d                	li	a5,3
ffffffffc0201054:	28f71863          	bne	a4,a5,ffffffffc02012e4 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201058:	4505                	li	a0,1
ffffffffc020105a:	58b000ef          	jal	ra,ffffffffc0201de4 <alloc_pages>
ffffffffc020105e:	89aa                	mv	s3,a0
ffffffffc0201060:	26050263          	beqz	a0,ffffffffc02012c4 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201064:	4505                	li	a0,1
ffffffffc0201066:	57f000ef          	jal	ra,ffffffffc0201de4 <alloc_pages>
ffffffffc020106a:	8aaa                	mv	s5,a0
ffffffffc020106c:	3a050c63          	beqz	a0,ffffffffc0201424 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201070:	4505                	li	a0,1
ffffffffc0201072:	573000ef          	jal	ra,ffffffffc0201de4 <alloc_pages>
ffffffffc0201076:	8a2a                	mv	s4,a0
ffffffffc0201078:	38050663          	beqz	a0,ffffffffc0201404 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc020107c:	4505                	li	a0,1
ffffffffc020107e:	567000ef          	jal	ra,ffffffffc0201de4 <alloc_pages>
ffffffffc0201082:	36051163          	bnez	a0,ffffffffc02013e4 <default_check+0x4a2>
    free_page(p0);
ffffffffc0201086:	4585                	li	a1,1
ffffffffc0201088:	854e                	mv	a0,s3
ffffffffc020108a:	599000ef          	jal	ra,ffffffffc0201e22 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc020108e:	641c                	ld	a5,8(s0)
ffffffffc0201090:	20878a63          	beq	a5,s0,ffffffffc02012a4 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0201094:	4505                	li	a0,1
ffffffffc0201096:	54f000ef          	jal	ra,ffffffffc0201de4 <alloc_pages>
ffffffffc020109a:	30a99563          	bne	s3,a0,ffffffffc02013a4 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc020109e:	4505                	li	a0,1
ffffffffc02010a0:	545000ef          	jal	ra,ffffffffc0201de4 <alloc_pages>
ffffffffc02010a4:	2e051063          	bnez	a0,ffffffffc0201384 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc02010a8:	481c                	lw	a5,16(s0)
ffffffffc02010aa:	2a079d63          	bnez	a5,ffffffffc0201364 <default_check+0x422>
    free_page(p);
ffffffffc02010ae:	854e                	mv	a0,s3
ffffffffc02010b0:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02010b2:	01843023          	sd	s8,0(s0)
ffffffffc02010b6:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc02010ba:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc02010be:	565000ef          	jal	ra,ffffffffc0201e22 <free_pages>
    free_page(p1);
ffffffffc02010c2:	4585                	li	a1,1
ffffffffc02010c4:	8556                	mv	a0,s5
ffffffffc02010c6:	55d000ef          	jal	ra,ffffffffc0201e22 <free_pages>
    free_page(p2);
ffffffffc02010ca:	4585                	li	a1,1
ffffffffc02010cc:	8552                	mv	a0,s4
ffffffffc02010ce:	555000ef          	jal	ra,ffffffffc0201e22 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02010d2:	4515                	li	a0,5
ffffffffc02010d4:	511000ef          	jal	ra,ffffffffc0201de4 <alloc_pages>
ffffffffc02010d8:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02010da:	26050563          	beqz	a0,ffffffffc0201344 <default_check+0x402>
ffffffffc02010de:	651c                	ld	a5,8(a0)
ffffffffc02010e0:	8385                	srli	a5,a5,0x1
ffffffffc02010e2:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc02010e4:	54079063          	bnez	a5,ffffffffc0201624 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02010e8:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02010ea:	00043b03          	ld	s6,0(s0)
ffffffffc02010ee:	00843a83          	ld	s5,8(s0)
ffffffffc02010f2:	e000                	sd	s0,0(s0)
ffffffffc02010f4:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc02010f6:	4ef000ef          	jal	ra,ffffffffc0201de4 <alloc_pages>
ffffffffc02010fa:	50051563          	bnez	a0,ffffffffc0201604 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02010fe:	08098a13          	addi	s4,s3,128
ffffffffc0201102:	8552                	mv	a0,s4
ffffffffc0201104:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201106:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc020110a:	000cd797          	auipc	a5,0xcd
ffffffffc020110e:	6007a723          	sw	zero,1550(a5) # ffffffffc02ce718 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201112:	511000ef          	jal	ra,ffffffffc0201e22 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201116:	4511                	li	a0,4
ffffffffc0201118:	4cd000ef          	jal	ra,ffffffffc0201de4 <alloc_pages>
ffffffffc020111c:	4c051463          	bnez	a0,ffffffffc02015e4 <default_check+0x6a2>
ffffffffc0201120:	0889b783          	ld	a5,136(s3)
ffffffffc0201124:	8385                	srli	a5,a5,0x1
ffffffffc0201126:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201128:	48078e63          	beqz	a5,ffffffffc02015c4 <default_check+0x682>
ffffffffc020112c:	0909a703          	lw	a4,144(s3)
ffffffffc0201130:	478d                	li	a5,3
ffffffffc0201132:	48f71963          	bne	a4,a5,ffffffffc02015c4 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201136:	450d                	li	a0,3
ffffffffc0201138:	4ad000ef          	jal	ra,ffffffffc0201de4 <alloc_pages>
ffffffffc020113c:	8c2a                	mv	s8,a0
ffffffffc020113e:	46050363          	beqz	a0,ffffffffc02015a4 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0201142:	4505                	li	a0,1
ffffffffc0201144:	4a1000ef          	jal	ra,ffffffffc0201de4 <alloc_pages>
ffffffffc0201148:	42051e63          	bnez	a0,ffffffffc0201584 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc020114c:	418a1c63          	bne	s4,s8,ffffffffc0201564 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201150:	4585                	li	a1,1
ffffffffc0201152:	854e                	mv	a0,s3
ffffffffc0201154:	4cf000ef          	jal	ra,ffffffffc0201e22 <free_pages>
    free_pages(p1, 3);
ffffffffc0201158:	458d                	li	a1,3
ffffffffc020115a:	8552                	mv	a0,s4
ffffffffc020115c:	4c7000ef          	jal	ra,ffffffffc0201e22 <free_pages>
ffffffffc0201160:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201164:	04098c13          	addi	s8,s3,64
ffffffffc0201168:	8385                	srli	a5,a5,0x1
ffffffffc020116a:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020116c:	3c078c63          	beqz	a5,ffffffffc0201544 <default_check+0x602>
ffffffffc0201170:	0109a703          	lw	a4,16(s3)
ffffffffc0201174:	4785                	li	a5,1
ffffffffc0201176:	3cf71763          	bne	a4,a5,ffffffffc0201544 <default_check+0x602>
ffffffffc020117a:	008a3783          	ld	a5,8(s4)
ffffffffc020117e:	8385                	srli	a5,a5,0x1
ffffffffc0201180:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201182:	3a078163          	beqz	a5,ffffffffc0201524 <default_check+0x5e2>
ffffffffc0201186:	010a2703          	lw	a4,16(s4)
ffffffffc020118a:	478d                	li	a5,3
ffffffffc020118c:	38f71c63          	bne	a4,a5,ffffffffc0201524 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201190:	4505                	li	a0,1
ffffffffc0201192:	453000ef          	jal	ra,ffffffffc0201de4 <alloc_pages>
ffffffffc0201196:	36a99763          	bne	s3,a0,ffffffffc0201504 <default_check+0x5c2>
    free_page(p0);
ffffffffc020119a:	4585                	li	a1,1
ffffffffc020119c:	487000ef          	jal	ra,ffffffffc0201e22 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02011a0:	4509                	li	a0,2
ffffffffc02011a2:	443000ef          	jal	ra,ffffffffc0201de4 <alloc_pages>
ffffffffc02011a6:	32aa1f63          	bne	s4,a0,ffffffffc02014e4 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc02011aa:	4589                	li	a1,2
ffffffffc02011ac:	477000ef          	jal	ra,ffffffffc0201e22 <free_pages>
    free_page(p2);
ffffffffc02011b0:	4585                	li	a1,1
ffffffffc02011b2:	8562                	mv	a0,s8
ffffffffc02011b4:	46f000ef          	jal	ra,ffffffffc0201e22 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02011b8:	4515                	li	a0,5
ffffffffc02011ba:	42b000ef          	jal	ra,ffffffffc0201de4 <alloc_pages>
ffffffffc02011be:	89aa                	mv	s3,a0
ffffffffc02011c0:	48050263          	beqz	a0,ffffffffc0201644 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc02011c4:	4505                	li	a0,1
ffffffffc02011c6:	41f000ef          	jal	ra,ffffffffc0201de4 <alloc_pages>
ffffffffc02011ca:	2c051d63          	bnez	a0,ffffffffc02014a4 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc02011ce:	481c                	lw	a5,16(s0)
ffffffffc02011d0:	2a079a63          	bnez	a5,ffffffffc0201484 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02011d4:	4595                	li	a1,5
ffffffffc02011d6:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02011d8:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02011dc:	01643023          	sd	s6,0(s0)
ffffffffc02011e0:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc02011e4:	43f000ef          	jal	ra,ffffffffc0201e22 <free_pages>
    return listelm->next;
ffffffffc02011e8:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc02011ea:	00878963          	beq	a5,s0,ffffffffc02011fc <default_check+0x2ba>
    {
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc02011ee:	ff87a703          	lw	a4,-8(a5)
ffffffffc02011f2:	679c                	ld	a5,8(a5)
ffffffffc02011f4:	397d                	addiw	s2,s2,-1
ffffffffc02011f6:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc02011f8:	fe879be3          	bne	a5,s0,ffffffffc02011ee <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc02011fc:	26091463          	bnez	s2,ffffffffc0201464 <default_check+0x522>
    assert(total == 0);
ffffffffc0201200:	46049263          	bnez	s1,ffffffffc0201664 <default_check+0x722>
}
ffffffffc0201204:	60a6                	ld	ra,72(sp)
ffffffffc0201206:	6406                	ld	s0,64(sp)
ffffffffc0201208:	74e2                	ld	s1,56(sp)
ffffffffc020120a:	7942                	ld	s2,48(sp)
ffffffffc020120c:	79a2                	ld	s3,40(sp)
ffffffffc020120e:	7a02                	ld	s4,32(sp)
ffffffffc0201210:	6ae2                	ld	s5,24(sp)
ffffffffc0201212:	6b42                	ld	s6,16(sp)
ffffffffc0201214:	6ba2                	ld	s7,8(sp)
ffffffffc0201216:	6c02                	ld	s8,0(sp)
ffffffffc0201218:	6161                	addi	sp,sp,80
ffffffffc020121a:	8082                	ret
    while ((le = list_next(le)) != &free_list)
ffffffffc020121c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020121e:	4481                	li	s1,0
ffffffffc0201220:	4901                	li	s2,0
ffffffffc0201222:	b38d                	j	ffffffffc0200f84 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0201224:	00005697          	auipc	a3,0x5
ffffffffc0201228:	4f468693          	addi	a3,a3,1268 # ffffffffc0206718 <commands+0x818>
ffffffffc020122c:	00005617          	auipc	a2,0x5
ffffffffc0201230:	4fc60613          	addi	a2,a2,1276 # ffffffffc0206728 <commands+0x828>
ffffffffc0201234:	11000593          	li	a1,272
ffffffffc0201238:	00005517          	auipc	a0,0x5
ffffffffc020123c:	50850513          	addi	a0,a0,1288 # ffffffffc0206740 <commands+0x840>
ffffffffc0201240:	a52ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201244:	00005697          	auipc	a3,0x5
ffffffffc0201248:	59468693          	addi	a3,a3,1428 # ffffffffc02067d8 <commands+0x8d8>
ffffffffc020124c:	00005617          	auipc	a2,0x5
ffffffffc0201250:	4dc60613          	addi	a2,a2,1244 # ffffffffc0206728 <commands+0x828>
ffffffffc0201254:	0db00593          	li	a1,219
ffffffffc0201258:	00005517          	auipc	a0,0x5
ffffffffc020125c:	4e850513          	addi	a0,a0,1256 # ffffffffc0206740 <commands+0x840>
ffffffffc0201260:	a32ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201264:	00005697          	auipc	a3,0x5
ffffffffc0201268:	59c68693          	addi	a3,a3,1436 # ffffffffc0206800 <commands+0x900>
ffffffffc020126c:	00005617          	auipc	a2,0x5
ffffffffc0201270:	4bc60613          	addi	a2,a2,1212 # ffffffffc0206728 <commands+0x828>
ffffffffc0201274:	0dc00593          	li	a1,220
ffffffffc0201278:	00005517          	auipc	a0,0x5
ffffffffc020127c:	4c850513          	addi	a0,a0,1224 # ffffffffc0206740 <commands+0x840>
ffffffffc0201280:	a12ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201284:	00005697          	auipc	a3,0x5
ffffffffc0201288:	5bc68693          	addi	a3,a3,1468 # ffffffffc0206840 <commands+0x940>
ffffffffc020128c:	00005617          	auipc	a2,0x5
ffffffffc0201290:	49c60613          	addi	a2,a2,1180 # ffffffffc0206728 <commands+0x828>
ffffffffc0201294:	0de00593          	li	a1,222
ffffffffc0201298:	00005517          	auipc	a0,0x5
ffffffffc020129c:	4a850513          	addi	a0,a0,1192 # ffffffffc0206740 <commands+0x840>
ffffffffc02012a0:	9f2ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(!list_empty(&free_list));
ffffffffc02012a4:	00005697          	auipc	a3,0x5
ffffffffc02012a8:	62468693          	addi	a3,a3,1572 # ffffffffc02068c8 <commands+0x9c8>
ffffffffc02012ac:	00005617          	auipc	a2,0x5
ffffffffc02012b0:	47c60613          	addi	a2,a2,1148 # ffffffffc0206728 <commands+0x828>
ffffffffc02012b4:	0f700593          	li	a1,247
ffffffffc02012b8:	00005517          	auipc	a0,0x5
ffffffffc02012bc:	48850513          	addi	a0,a0,1160 # ffffffffc0206740 <commands+0x840>
ffffffffc02012c0:	9d2ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02012c4:	00005697          	auipc	a3,0x5
ffffffffc02012c8:	4b468693          	addi	a3,a3,1204 # ffffffffc0206778 <commands+0x878>
ffffffffc02012cc:	00005617          	auipc	a2,0x5
ffffffffc02012d0:	45c60613          	addi	a2,a2,1116 # ffffffffc0206728 <commands+0x828>
ffffffffc02012d4:	0f000593          	li	a1,240
ffffffffc02012d8:	00005517          	auipc	a0,0x5
ffffffffc02012dc:	46850513          	addi	a0,a0,1128 # ffffffffc0206740 <commands+0x840>
ffffffffc02012e0:	9b2ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(nr_free == 3);
ffffffffc02012e4:	00005697          	auipc	a3,0x5
ffffffffc02012e8:	5d468693          	addi	a3,a3,1492 # ffffffffc02068b8 <commands+0x9b8>
ffffffffc02012ec:	00005617          	auipc	a2,0x5
ffffffffc02012f0:	43c60613          	addi	a2,a2,1084 # ffffffffc0206728 <commands+0x828>
ffffffffc02012f4:	0ee00593          	li	a1,238
ffffffffc02012f8:	00005517          	auipc	a0,0x5
ffffffffc02012fc:	44850513          	addi	a0,a0,1096 # ffffffffc0206740 <commands+0x840>
ffffffffc0201300:	992ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201304:	00005697          	auipc	a3,0x5
ffffffffc0201308:	59c68693          	addi	a3,a3,1436 # ffffffffc02068a0 <commands+0x9a0>
ffffffffc020130c:	00005617          	auipc	a2,0x5
ffffffffc0201310:	41c60613          	addi	a2,a2,1052 # ffffffffc0206728 <commands+0x828>
ffffffffc0201314:	0e900593          	li	a1,233
ffffffffc0201318:	00005517          	auipc	a0,0x5
ffffffffc020131c:	42850513          	addi	a0,a0,1064 # ffffffffc0206740 <commands+0x840>
ffffffffc0201320:	972ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201324:	00005697          	auipc	a3,0x5
ffffffffc0201328:	55c68693          	addi	a3,a3,1372 # ffffffffc0206880 <commands+0x980>
ffffffffc020132c:	00005617          	auipc	a2,0x5
ffffffffc0201330:	3fc60613          	addi	a2,a2,1020 # ffffffffc0206728 <commands+0x828>
ffffffffc0201334:	0e000593          	li	a1,224
ffffffffc0201338:	00005517          	auipc	a0,0x5
ffffffffc020133c:	40850513          	addi	a0,a0,1032 # ffffffffc0206740 <commands+0x840>
ffffffffc0201340:	952ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(p0 != NULL);
ffffffffc0201344:	00005697          	auipc	a3,0x5
ffffffffc0201348:	5cc68693          	addi	a3,a3,1484 # ffffffffc0206910 <commands+0xa10>
ffffffffc020134c:	00005617          	auipc	a2,0x5
ffffffffc0201350:	3dc60613          	addi	a2,a2,988 # ffffffffc0206728 <commands+0x828>
ffffffffc0201354:	11800593          	li	a1,280
ffffffffc0201358:	00005517          	auipc	a0,0x5
ffffffffc020135c:	3e850513          	addi	a0,a0,1000 # ffffffffc0206740 <commands+0x840>
ffffffffc0201360:	932ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(nr_free == 0);
ffffffffc0201364:	00005697          	auipc	a3,0x5
ffffffffc0201368:	59c68693          	addi	a3,a3,1436 # ffffffffc0206900 <commands+0xa00>
ffffffffc020136c:	00005617          	auipc	a2,0x5
ffffffffc0201370:	3bc60613          	addi	a2,a2,956 # ffffffffc0206728 <commands+0x828>
ffffffffc0201374:	0fd00593          	li	a1,253
ffffffffc0201378:	00005517          	auipc	a0,0x5
ffffffffc020137c:	3c850513          	addi	a0,a0,968 # ffffffffc0206740 <commands+0x840>
ffffffffc0201380:	912ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201384:	00005697          	auipc	a3,0x5
ffffffffc0201388:	51c68693          	addi	a3,a3,1308 # ffffffffc02068a0 <commands+0x9a0>
ffffffffc020138c:	00005617          	auipc	a2,0x5
ffffffffc0201390:	39c60613          	addi	a2,a2,924 # ffffffffc0206728 <commands+0x828>
ffffffffc0201394:	0fb00593          	li	a1,251
ffffffffc0201398:	00005517          	auipc	a0,0x5
ffffffffc020139c:	3a850513          	addi	a0,a0,936 # ffffffffc0206740 <commands+0x840>
ffffffffc02013a0:	8f2ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02013a4:	00005697          	auipc	a3,0x5
ffffffffc02013a8:	53c68693          	addi	a3,a3,1340 # ffffffffc02068e0 <commands+0x9e0>
ffffffffc02013ac:	00005617          	auipc	a2,0x5
ffffffffc02013b0:	37c60613          	addi	a2,a2,892 # ffffffffc0206728 <commands+0x828>
ffffffffc02013b4:	0fa00593          	li	a1,250
ffffffffc02013b8:	00005517          	auipc	a0,0x5
ffffffffc02013bc:	38850513          	addi	a0,a0,904 # ffffffffc0206740 <commands+0x840>
ffffffffc02013c0:	8d2ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02013c4:	00005697          	auipc	a3,0x5
ffffffffc02013c8:	3b468693          	addi	a3,a3,948 # ffffffffc0206778 <commands+0x878>
ffffffffc02013cc:	00005617          	auipc	a2,0x5
ffffffffc02013d0:	35c60613          	addi	a2,a2,860 # ffffffffc0206728 <commands+0x828>
ffffffffc02013d4:	0d700593          	li	a1,215
ffffffffc02013d8:	00005517          	auipc	a0,0x5
ffffffffc02013dc:	36850513          	addi	a0,a0,872 # ffffffffc0206740 <commands+0x840>
ffffffffc02013e0:	8b2ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013e4:	00005697          	auipc	a3,0x5
ffffffffc02013e8:	4bc68693          	addi	a3,a3,1212 # ffffffffc02068a0 <commands+0x9a0>
ffffffffc02013ec:	00005617          	auipc	a2,0x5
ffffffffc02013f0:	33c60613          	addi	a2,a2,828 # ffffffffc0206728 <commands+0x828>
ffffffffc02013f4:	0f400593          	li	a1,244
ffffffffc02013f8:	00005517          	auipc	a0,0x5
ffffffffc02013fc:	34850513          	addi	a0,a0,840 # ffffffffc0206740 <commands+0x840>
ffffffffc0201400:	892ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201404:	00005697          	auipc	a3,0x5
ffffffffc0201408:	3b468693          	addi	a3,a3,948 # ffffffffc02067b8 <commands+0x8b8>
ffffffffc020140c:	00005617          	auipc	a2,0x5
ffffffffc0201410:	31c60613          	addi	a2,a2,796 # ffffffffc0206728 <commands+0x828>
ffffffffc0201414:	0f200593          	li	a1,242
ffffffffc0201418:	00005517          	auipc	a0,0x5
ffffffffc020141c:	32850513          	addi	a0,a0,808 # ffffffffc0206740 <commands+0x840>
ffffffffc0201420:	872ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201424:	00005697          	auipc	a3,0x5
ffffffffc0201428:	37468693          	addi	a3,a3,884 # ffffffffc0206798 <commands+0x898>
ffffffffc020142c:	00005617          	auipc	a2,0x5
ffffffffc0201430:	2fc60613          	addi	a2,a2,764 # ffffffffc0206728 <commands+0x828>
ffffffffc0201434:	0f100593          	li	a1,241
ffffffffc0201438:	00005517          	auipc	a0,0x5
ffffffffc020143c:	30850513          	addi	a0,a0,776 # ffffffffc0206740 <commands+0x840>
ffffffffc0201440:	852ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201444:	00005697          	auipc	a3,0x5
ffffffffc0201448:	37468693          	addi	a3,a3,884 # ffffffffc02067b8 <commands+0x8b8>
ffffffffc020144c:	00005617          	auipc	a2,0x5
ffffffffc0201450:	2dc60613          	addi	a2,a2,732 # ffffffffc0206728 <commands+0x828>
ffffffffc0201454:	0d900593          	li	a1,217
ffffffffc0201458:	00005517          	auipc	a0,0x5
ffffffffc020145c:	2e850513          	addi	a0,a0,744 # ffffffffc0206740 <commands+0x840>
ffffffffc0201460:	832ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(count == 0);
ffffffffc0201464:	00005697          	auipc	a3,0x5
ffffffffc0201468:	5fc68693          	addi	a3,a3,1532 # ffffffffc0206a60 <commands+0xb60>
ffffffffc020146c:	00005617          	auipc	a2,0x5
ffffffffc0201470:	2bc60613          	addi	a2,a2,700 # ffffffffc0206728 <commands+0x828>
ffffffffc0201474:	14600593          	li	a1,326
ffffffffc0201478:	00005517          	auipc	a0,0x5
ffffffffc020147c:	2c850513          	addi	a0,a0,712 # ffffffffc0206740 <commands+0x840>
ffffffffc0201480:	812ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(nr_free == 0);
ffffffffc0201484:	00005697          	auipc	a3,0x5
ffffffffc0201488:	47c68693          	addi	a3,a3,1148 # ffffffffc0206900 <commands+0xa00>
ffffffffc020148c:	00005617          	auipc	a2,0x5
ffffffffc0201490:	29c60613          	addi	a2,a2,668 # ffffffffc0206728 <commands+0x828>
ffffffffc0201494:	13a00593          	li	a1,314
ffffffffc0201498:	00005517          	auipc	a0,0x5
ffffffffc020149c:	2a850513          	addi	a0,a0,680 # ffffffffc0206740 <commands+0x840>
ffffffffc02014a0:	ff3fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014a4:	00005697          	auipc	a3,0x5
ffffffffc02014a8:	3fc68693          	addi	a3,a3,1020 # ffffffffc02068a0 <commands+0x9a0>
ffffffffc02014ac:	00005617          	auipc	a2,0x5
ffffffffc02014b0:	27c60613          	addi	a2,a2,636 # ffffffffc0206728 <commands+0x828>
ffffffffc02014b4:	13800593          	li	a1,312
ffffffffc02014b8:	00005517          	auipc	a0,0x5
ffffffffc02014bc:	28850513          	addi	a0,a0,648 # ffffffffc0206740 <commands+0x840>
ffffffffc02014c0:	fd3fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02014c4:	00005697          	auipc	a3,0x5
ffffffffc02014c8:	39c68693          	addi	a3,a3,924 # ffffffffc0206860 <commands+0x960>
ffffffffc02014cc:	00005617          	auipc	a2,0x5
ffffffffc02014d0:	25c60613          	addi	a2,a2,604 # ffffffffc0206728 <commands+0x828>
ffffffffc02014d4:	0df00593          	li	a1,223
ffffffffc02014d8:	00005517          	auipc	a0,0x5
ffffffffc02014dc:	26850513          	addi	a0,a0,616 # ffffffffc0206740 <commands+0x840>
ffffffffc02014e0:	fb3fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02014e4:	00005697          	auipc	a3,0x5
ffffffffc02014e8:	53c68693          	addi	a3,a3,1340 # ffffffffc0206a20 <commands+0xb20>
ffffffffc02014ec:	00005617          	auipc	a2,0x5
ffffffffc02014f0:	23c60613          	addi	a2,a2,572 # ffffffffc0206728 <commands+0x828>
ffffffffc02014f4:	13200593          	li	a1,306
ffffffffc02014f8:	00005517          	auipc	a0,0x5
ffffffffc02014fc:	24850513          	addi	a0,a0,584 # ffffffffc0206740 <commands+0x840>
ffffffffc0201500:	f93fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201504:	00005697          	auipc	a3,0x5
ffffffffc0201508:	4fc68693          	addi	a3,a3,1276 # ffffffffc0206a00 <commands+0xb00>
ffffffffc020150c:	00005617          	auipc	a2,0x5
ffffffffc0201510:	21c60613          	addi	a2,a2,540 # ffffffffc0206728 <commands+0x828>
ffffffffc0201514:	13000593          	li	a1,304
ffffffffc0201518:	00005517          	auipc	a0,0x5
ffffffffc020151c:	22850513          	addi	a0,a0,552 # ffffffffc0206740 <commands+0x840>
ffffffffc0201520:	f73fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201524:	00005697          	auipc	a3,0x5
ffffffffc0201528:	4b468693          	addi	a3,a3,1204 # ffffffffc02069d8 <commands+0xad8>
ffffffffc020152c:	00005617          	auipc	a2,0x5
ffffffffc0201530:	1fc60613          	addi	a2,a2,508 # ffffffffc0206728 <commands+0x828>
ffffffffc0201534:	12e00593          	li	a1,302
ffffffffc0201538:	00005517          	auipc	a0,0x5
ffffffffc020153c:	20850513          	addi	a0,a0,520 # ffffffffc0206740 <commands+0x840>
ffffffffc0201540:	f53fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201544:	00005697          	auipc	a3,0x5
ffffffffc0201548:	46c68693          	addi	a3,a3,1132 # ffffffffc02069b0 <commands+0xab0>
ffffffffc020154c:	00005617          	auipc	a2,0x5
ffffffffc0201550:	1dc60613          	addi	a2,a2,476 # ffffffffc0206728 <commands+0x828>
ffffffffc0201554:	12d00593          	li	a1,301
ffffffffc0201558:	00005517          	auipc	a0,0x5
ffffffffc020155c:	1e850513          	addi	a0,a0,488 # ffffffffc0206740 <commands+0x840>
ffffffffc0201560:	f33fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201564:	00005697          	auipc	a3,0x5
ffffffffc0201568:	43c68693          	addi	a3,a3,1084 # ffffffffc02069a0 <commands+0xaa0>
ffffffffc020156c:	00005617          	auipc	a2,0x5
ffffffffc0201570:	1bc60613          	addi	a2,a2,444 # ffffffffc0206728 <commands+0x828>
ffffffffc0201574:	12800593          	li	a1,296
ffffffffc0201578:	00005517          	auipc	a0,0x5
ffffffffc020157c:	1c850513          	addi	a0,a0,456 # ffffffffc0206740 <commands+0x840>
ffffffffc0201580:	f13fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201584:	00005697          	auipc	a3,0x5
ffffffffc0201588:	31c68693          	addi	a3,a3,796 # ffffffffc02068a0 <commands+0x9a0>
ffffffffc020158c:	00005617          	auipc	a2,0x5
ffffffffc0201590:	19c60613          	addi	a2,a2,412 # ffffffffc0206728 <commands+0x828>
ffffffffc0201594:	12700593          	li	a1,295
ffffffffc0201598:	00005517          	auipc	a0,0x5
ffffffffc020159c:	1a850513          	addi	a0,a0,424 # ffffffffc0206740 <commands+0x840>
ffffffffc02015a0:	ef3fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02015a4:	00005697          	auipc	a3,0x5
ffffffffc02015a8:	3dc68693          	addi	a3,a3,988 # ffffffffc0206980 <commands+0xa80>
ffffffffc02015ac:	00005617          	auipc	a2,0x5
ffffffffc02015b0:	17c60613          	addi	a2,a2,380 # ffffffffc0206728 <commands+0x828>
ffffffffc02015b4:	12600593          	li	a1,294
ffffffffc02015b8:	00005517          	auipc	a0,0x5
ffffffffc02015bc:	18850513          	addi	a0,a0,392 # ffffffffc0206740 <commands+0x840>
ffffffffc02015c0:	ed3fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02015c4:	00005697          	auipc	a3,0x5
ffffffffc02015c8:	38c68693          	addi	a3,a3,908 # ffffffffc0206950 <commands+0xa50>
ffffffffc02015cc:	00005617          	auipc	a2,0x5
ffffffffc02015d0:	15c60613          	addi	a2,a2,348 # ffffffffc0206728 <commands+0x828>
ffffffffc02015d4:	12500593          	li	a1,293
ffffffffc02015d8:	00005517          	auipc	a0,0x5
ffffffffc02015dc:	16850513          	addi	a0,a0,360 # ffffffffc0206740 <commands+0x840>
ffffffffc02015e0:	eb3fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02015e4:	00005697          	auipc	a3,0x5
ffffffffc02015e8:	35468693          	addi	a3,a3,852 # ffffffffc0206938 <commands+0xa38>
ffffffffc02015ec:	00005617          	auipc	a2,0x5
ffffffffc02015f0:	13c60613          	addi	a2,a2,316 # ffffffffc0206728 <commands+0x828>
ffffffffc02015f4:	12400593          	li	a1,292
ffffffffc02015f8:	00005517          	auipc	a0,0x5
ffffffffc02015fc:	14850513          	addi	a0,a0,328 # ffffffffc0206740 <commands+0x840>
ffffffffc0201600:	e93fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201604:	00005697          	auipc	a3,0x5
ffffffffc0201608:	29c68693          	addi	a3,a3,668 # ffffffffc02068a0 <commands+0x9a0>
ffffffffc020160c:	00005617          	auipc	a2,0x5
ffffffffc0201610:	11c60613          	addi	a2,a2,284 # ffffffffc0206728 <commands+0x828>
ffffffffc0201614:	11e00593          	li	a1,286
ffffffffc0201618:	00005517          	auipc	a0,0x5
ffffffffc020161c:	12850513          	addi	a0,a0,296 # ffffffffc0206740 <commands+0x840>
ffffffffc0201620:	e73fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201624:	00005697          	auipc	a3,0x5
ffffffffc0201628:	2fc68693          	addi	a3,a3,764 # ffffffffc0206920 <commands+0xa20>
ffffffffc020162c:	00005617          	auipc	a2,0x5
ffffffffc0201630:	0fc60613          	addi	a2,a2,252 # ffffffffc0206728 <commands+0x828>
ffffffffc0201634:	11900593          	li	a1,281
ffffffffc0201638:	00005517          	auipc	a0,0x5
ffffffffc020163c:	10850513          	addi	a0,a0,264 # ffffffffc0206740 <commands+0x840>
ffffffffc0201640:	e53fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201644:	00005697          	auipc	a3,0x5
ffffffffc0201648:	3fc68693          	addi	a3,a3,1020 # ffffffffc0206a40 <commands+0xb40>
ffffffffc020164c:	00005617          	auipc	a2,0x5
ffffffffc0201650:	0dc60613          	addi	a2,a2,220 # ffffffffc0206728 <commands+0x828>
ffffffffc0201654:	13700593          	li	a1,311
ffffffffc0201658:	00005517          	auipc	a0,0x5
ffffffffc020165c:	0e850513          	addi	a0,a0,232 # ffffffffc0206740 <commands+0x840>
ffffffffc0201660:	e33fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(total == 0);
ffffffffc0201664:	00005697          	auipc	a3,0x5
ffffffffc0201668:	40c68693          	addi	a3,a3,1036 # ffffffffc0206a70 <commands+0xb70>
ffffffffc020166c:	00005617          	auipc	a2,0x5
ffffffffc0201670:	0bc60613          	addi	a2,a2,188 # ffffffffc0206728 <commands+0x828>
ffffffffc0201674:	14700593          	li	a1,327
ffffffffc0201678:	00005517          	auipc	a0,0x5
ffffffffc020167c:	0c850513          	addi	a0,a0,200 # ffffffffc0206740 <commands+0x840>
ffffffffc0201680:	e13fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201684:	00005697          	auipc	a3,0x5
ffffffffc0201688:	0d468693          	addi	a3,a3,212 # ffffffffc0206758 <commands+0x858>
ffffffffc020168c:	00005617          	auipc	a2,0x5
ffffffffc0201690:	09c60613          	addi	a2,a2,156 # ffffffffc0206728 <commands+0x828>
ffffffffc0201694:	11300593          	li	a1,275
ffffffffc0201698:	00005517          	auipc	a0,0x5
ffffffffc020169c:	0a850513          	addi	a0,a0,168 # ffffffffc0206740 <commands+0x840>
ffffffffc02016a0:	df3fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02016a4:	00005697          	auipc	a3,0x5
ffffffffc02016a8:	0f468693          	addi	a3,a3,244 # ffffffffc0206798 <commands+0x898>
ffffffffc02016ac:	00005617          	auipc	a2,0x5
ffffffffc02016b0:	07c60613          	addi	a2,a2,124 # ffffffffc0206728 <commands+0x828>
ffffffffc02016b4:	0d800593          	li	a1,216
ffffffffc02016b8:	00005517          	auipc	a0,0x5
ffffffffc02016bc:	08850513          	addi	a0,a0,136 # ffffffffc0206740 <commands+0x840>
ffffffffc02016c0:	dd3fe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02016c4 <default_free_pages>:
{
ffffffffc02016c4:	1141                	addi	sp,sp,-16
ffffffffc02016c6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02016c8:	14058463          	beqz	a1,ffffffffc0201810 <default_free_pages+0x14c>
    for (; p != base + n; p++)
ffffffffc02016cc:	00659693          	slli	a3,a1,0x6
ffffffffc02016d0:	96aa                	add	a3,a3,a0
ffffffffc02016d2:	87aa                	mv	a5,a0
ffffffffc02016d4:	02d50263          	beq	a0,a3,ffffffffc02016f8 <default_free_pages+0x34>
ffffffffc02016d8:	6798                	ld	a4,8(a5)
ffffffffc02016da:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02016dc:	10071a63          	bnez	a4,ffffffffc02017f0 <default_free_pages+0x12c>
ffffffffc02016e0:	6798                	ld	a4,8(a5)
ffffffffc02016e2:	8b09                	andi	a4,a4,2
ffffffffc02016e4:	10071663          	bnez	a4,ffffffffc02017f0 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc02016e8:	0007b423          	sd	zero,8(a5)
}

static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
ffffffffc02016ec:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02016f0:	04078793          	addi	a5,a5,64
ffffffffc02016f4:	fed792e3          	bne	a5,a3,ffffffffc02016d8 <default_free_pages+0x14>
    base->property = n;
ffffffffc02016f8:	2581                	sext.w	a1,a1
ffffffffc02016fa:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02016fc:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201700:	4789                	li	a5,2
ffffffffc0201702:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201706:	000cd697          	auipc	a3,0xcd
ffffffffc020170a:	00268693          	addi	a3,a3,2 # ffffffffc02ce708 <free_area>
ffffffffc020170e:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201710:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201712:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201716:	9db9                	addw	a1,a1,a4
ffffffffc0201718:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc020171a:	0ad78463          	beq	a5,a3,ffffffffc02017c2 <default_free_pages+0xfe>
            struct Page *page = le2page(le, page_link);
ffffffffc020171e:	fe878713          	addi	a4,a5,-24
ffffffffc0201722:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc0201726:	4581                	li	a1,0
            if (base < page)
ffffffffc0201728:	00e56a63          	bltu	a0,a4,ffffffffc020173c <default_free_pages+0x78>
    return listelm->next;
ffffffffc020172c:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc020172e:	04d70c63          	beq	a4,a3,ffffffffc0201786 <default_free_pages+0xc2>
    for (; p != base + n; p++)
ffffffffc0201732:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0201734:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0201738:	fee57ae3          	bgeu	a0,a4,ffffffffc020172c <default_free_pages+0x68>
ffffffffc020173c:	c199                	beqz	a1,ffffffffc0201742 <default_free_pages+0x7e>
ffffffffc020173e:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201742:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201744:	e390                	sd	a2,0(a5)
ffffffffc0201746:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201748:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020174a:	ed18                	sd	a4,24(a0)
    if (le != &free_list)
ffffffffc020174c:	00d70d63          	beq	a4,a3,ffffffffc0201766 <default_free_pages+0xa2>
        if (p + p->property == base)
ffffffffc0201750:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201754:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base)
ffffffffc0201758:	02059813          	slli	a6,a1,0x20
ffffffffc020175c:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201760:	97b2                	add	a5,a5,a2
ffffffffc0201762:	02f50c63          	beq	a0,a5,ffffffffc020179a <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0201766:	711c                	ld	a5,32(a0)
    if (le != &free_list)
ffffffffc0201768:	00d78c63          	beq	a5,a3,ffffffffc0201780 <default_free_pages+0xbc>
        if (base + base->property == p)
ffffffffc020176c:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc020176e:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p)
ffffffffc0201772:	02061593          	slli	a1,a2,0x20
ffffffffc0201776:	01a5d713          	srli	a4,a1,0x1a
ffffffffc020177a:	972a                	add	a4,a4,a0
ffffffffc020177c:	04e68a63          	beq	a3,a4,ffffffffc02017d0 <default_free_pages+0x10c>
}
ffffffffc0201780:	60a2                	ld	ra,8(sp)
ffffffffc0201782:	0141                	addi	sp,sp,16
ffffffffc0201784:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201786:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201788:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020178a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020178c:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc020178e:	02d70763          	beq	a4,a3,ffffffffc02017bc <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc0201792:	8832                	mv	a6,a2
ffffffffc0201794:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc0201796:	87ba                	mv	a5,a4
ffffffffc0201798:	bf71                	j	ffffffffc0201734 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc020179a:	491c                	lw	a5,16(a0)
ffffffffc020179c:	9dbd                	addw	a1,a1,a5
ffffffffc020179e:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02017a2:	57f5                	li	a5,-3
ffffffffc02017a4:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02017a8:	01853803          	ld	a6,24(a0)
ffffffffc02017ac:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc02017ae:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02017b0:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc02017b4:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc02017b6:	0105b023          	sd	a6,0(a1)
ffffffffc02017ba:	b77d                	j	ffffffffc0201768 <default_free_pages+0xa4>
ffffffffc02017bc:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list)
ffffffffc02017be:	873e                	mv	a4,a5
ffffffffc02017c0:	bf41                	j	ffffffffc0201750 <default_free_pages+0x8c>
}
ffffffffc02017c2:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02017c4:	e390                	sd	a2,0(a5)
ffffffffc02017c6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02017c8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02017ca:	ed1c                	sd	a5,24(a0)
ffffffffc02017cc:	0141                	addi	sp,sp,16
ffffffffc02017ce:	8082                	ret
            base->property += p->property;
ffffffffc02017d0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02017d4:	ff078693          	addi	a3,a5,-16
ffffffffc02017d8:	9e39                	addw	a2,a2,a4
ffffffffc02017da:	c910                	sw	a2,16(a0)
ffffffffc02017dc:	5775                	li	a4,-3
ffffffffc02017de:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02017e2:	6398                	ld	a4,0(a5)
ffffffffc02017e4:	679c                	ld	a5,8(a5)
}
ffffffffc02017e6:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02017e8:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02017ea:	e398                	sd	a4,0(a5)
ffffffffc02017ec:	0141                	addi	sp,sp,16
ffffffffc02017ee:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02017f0:	00005697          	auipc	a3,0x5
ffffffffc02017f4:	29868693          	addi	a3,a3,664 # ffffffffc0206a88 <commands+0xb88>
ffffffffc02017f8:	00005617          	auipc	a2,0x5
ffffffffc02017fc:	f3060613          	addi	a2,a2,-208 # ffffffffc0206728 <commands+0x828>
ffffffffc0201800:	09400593          	li	a1,148
ffffffffc0201804:	00005517          	auipc	a0,0x5
ffffffffc0201808:	f3c50513          	addi	a0,a0,-196 # ffffffffc0206740 <commands+0x840>
ffffffffc020180c:	c87fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(n > 0);
ffffffffc0201810:	00005697          	auipc	a3,0x5
ffffffffc0201814:	27068693          	addi	a3,a3,624 # ffffffffc0206a80 <commands+0xb80>
ffffffffc0201818:	00005617          	auipc	a2,0x5
ffffffffc020181c:	f1060613          	addi	a2,a2,-240 # ffffffffc0206728 <commands+0x828>
ffffffffc0201820:	09000593          	li	a1,144
ffffffffc0201824:	00005517          	auipc	a0,0x5
ffffffffc0201828:	f1c50513          	addi	a0,a0,-228 # ffffffffc0206740 <commands+0x840>
ffffffffc020182c:	c67fe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0201830 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201830:	c941                	beqz	a0,ffffffffc02018c0 <default_alloc_pages+0x90>
    if (n > nr_free)
ffffffffc0201832:	000cd597          	auipc	a1,0xcd
ffffffffc0201836:	ed658593          	addi	a1,a1,-298 # ffffffffc02ce708 <free_area>
ffffffffc020183a:	0105a803          	lw	a6,16(a1)
ffffffffc020183e:	872a                	mv	a4,a0
ffffffffc0201840:	02081793          	slli	a5,a6,0x20
ffffffffc0201844:	9381                	srli	a5,a5,0x20
ffffffffc0201846:	00a7ee63          	bltu	a5,a0,ffffffffc0201862 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc020184a:	87ae                	mv	a5,a1
ffffffffc020184c:	a801                	j	ffffffffc020185c <default_alloc_pages+0x2c>
        if (p->property >= n)
ffffffffc020184e:	ff87a683          	lw	a3,-8(a5)
ffffffffc0201852:	02069613          	slli	a2,a3,0x20
ffffffffc0201856:	9201                	srli	a2,a2,0x20
ffffffffc0201858:	00e67763          	bgeu	a2,a4,ffffffffc0201866 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc020185c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc020185e:	feb798e3          	bne	a5,a1,ffffffffc020184e <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201862:	4501                	li	a0,0
}
ffffffffc0201864:	8082                	ret
    return listelm->prev;
ffffffffc0201866:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020186a:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc020186e:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0201872:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0201876:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc020187a:	01133023          	sd	a7,0(t1)
        if (page->property > n)
ffffffffc020187e:	02c77863          	bgeu	a4,a2,ffffffffc02018ae <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc0201882:	071a                	slli	a4,a4,0x6
ffffffffc0201884:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201886:	41c686bb          	subw	a3,a3,t3
ffffffffc020188a:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020188c:	00870613          	addi	a2,a4,8
ffffffffc0201890:	4689                	li	a3,2
ffffffffc0201892:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201896:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020189a:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc020189e:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc02018a2:	e290                	sd	a2,0(a3)
ffffffffc02018a4:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02018a8:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc02018aa:	01173c23          	sd	a7,24(a4)
ffffffffc02018ae:	41c8083b          	subw	a6,a6,t3
ffffffffc02018b2:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02018b6:	5775                	li	a4,-3
ffffffffc02018b8:	17c1                	addi	a5,a5,-16
ffffffffc02018ba:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc02018be:	8082                	ret
{
ffffffffc02018c0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02018c2:	00005697          	auipc	a3,0x5
ffffffffc02018c6:	1be68693          	addi	a3,a3,446 # ffffffffc0206a80 <commands+0xb80>
ffffffffc02018ca:	00005617          	auipc	a2,0x5
ffffffffc02018ce:	e5e60613          	addi	a2,a2,-418 # ffffffffc0206728 <commands+0x828>
ffffffffc02018d2:	06c00593          	li	a1,108
ffffffffc02018d6:	00005517          	auipc	a0,0x5
ffffffffc02018da:	e6a50513          	addi	a0,a0,-406 # ffffffffc0206740 <commands+0x840>
{
ffffffffc02018de:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02018e0:	bb3fe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02018e4 <default_init_memmap>:
{
ffffffffc02018e4:	1141                	addi	sp,sp,-16
ffffffffc02018e6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02018e8:	c5f1                	beqz	a1,ffffffffc02019b4 <default_init_memmap+0xd0>
    for (; p != base + n; p++)
ffffffffc02018ea:	00659693          	slli	a3,a1,0x6
ffffffffc02018ee:	96aa                	add	a3,a3,a0
ffffffffc02018f0:	87aa                	mv	a5,a0
ffffffffc02018f2:	00d50f63          	beq	a0,a3,ffffffffc0201910 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02018f6:	6798                	ld	a4,8(a5)
ffffffffc02018f8:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc02018fa:	cf49                	beqz	a4,ffffffffc0201994 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc02018fc:	0007a823          	sw	zero,16(a5)
ffffffffc0201900:	0007b423          	sd	zero,8(a5)
ffffffffc0201904:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc0201908:	04078793          	addi	a5,a5,64
ffffffffc020190c:	fed795e3          	bne	a5,a3,ffffffffc02018f6 <default_init_memmap+0x12>
    base->property = n;
ffffffffc0201910:	2581                	sext.w	a1,a1
ffffffffc0201912:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201914:	4789                	li	a5,2
ffffffffc0201916:	00850713          	addi	a4,a0,8
ffffffffc020191a:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020191e:	000cd697          	auipc	a3,0xcd
ffffffffc0201922:	dea68693          	addi	a3,a3,-534 # ffffffffc02ce708 <free_area>
ffffffffc0201926:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201928:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020192a:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020192e:	9db9                	addw	a1,a1,a4
ffffffffc0201930:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc0201932:	04d78a63          	beq	a5,a3,ffffffffc0201986 <default_init_memmap+0xa2>
            struct Page *page = le2page(le, page_link);
ffffffffc0201936:	fe878713          	addi	a4,a5,-24
ffffffffc020193a:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc020193e:	4581                	li	a1,0
            if (base < page)
ffffffffc0201940:	00e56a63          	bltu	a0,a4,ffffffffc0201954 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0201944:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc0201946:	02d70263          	beq	a4,a3,ffffffffc020196a <default_init_memmap+0x86>
    for (; p != base + n; p++)
ffffffffc020194a:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc020194c:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0201950:	fee57ae3          	bgeu	a0,a4,ffffffffc0201944 <default_init_memmap+0x60>
ffffffffc0201954:	c199                	beqz	a1,ffffffffc020195a <default_init_memmap+0x76>
ffffffffc0201956:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020195a:	6398                	ld	a4,0(a5)
}
ffffffffc020195c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020195e:	e390                	sd	a2,0(a5)
ffffffffc0201960:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201962:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201964:	ed18                	sd	a4,24(a0)
ffffffffc0201966:	0141                	addi	sp,sp,16
ffffffffc0201968:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020196a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020196c:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020196e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201970:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc0201972:	00d70663          	beq	a4,a3,ffffffffc020197e <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0201976:	8832                	mv	a6,a2
ffffffffc0201978:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc020197a:	87ba                	mv	a5,a4
ffffffffc020197c:	bfc1                	j	ffffffffc020194c <default_init_memmap+0x68>
}
ffffffffc020197e:	60a2                	ld	ra,8(sp)
ffffffffc0201980:	e290                	sd	a2,0(a3)
ffffffffc0201982:	0141                	addi	sp,sp,16
ffffffffc0201984:	8082                	ret
ffffffffc0201986:	60a2                	ld	ra,8(sp)
ffffffffc0201988:	e390                	sd	a2,0(a5)
ffffffffc020198a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020198c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020198e:	ed1c                	sd	a5,24(a0)
ffffffffc0201990:	0141                	addi	sp,sp,16
ffffffffc0201992:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201994:	00005697          	auipc	a3,0x5
ffffffffc0201998:	11c68693          	addi	a3,a3,284 # ffffffffc0206ab0 <commands+0xbb0>
ffffffffc020199c:	00005617          	auipc	a2,0x5
ffffffffc02019a0:	d8c60613          	addi	a2,a2,-628 # ffffffffc0206728 <commands+0x828>
ffffffffc02019a4:	04b00593          	li	a1,75
ffffffffc02019a8:	00005517          	auipc	a0,0x5
ffffffffc02019ac:	d9850513          	addi	a0,a0,-616 # ffffffffc0206740 <commands+0x840>
ffffffffc02019b0:	ae3fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(n > 0);
ffffffffc02019b4:	00005697          	auipc	a3,0x5
ffffffffc02019b8:	0cc68693          	addi	a3,a3,204 # ffffffffc0206a80 <commands+0xb80>
ffffffffc02019bc:	00005617          	auipc	a2,0x5
ffffffffc02019c0:	d6c60613          	addi	a2,a2,-660 # ffffffffc0206728 <commands+0x828>
ffffffffc02019c4:	04700593          	li	a1,71
ffffffffc02019c8:	00005517          	auipc	a0,0x5
ffffffffc02019cc:	d7850513          	addi	a0,a0,-648 # ffffffffc0206740 <commands+0x840>
ffffffffc02019d0:	ac3fe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02019d4 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02019d4:	c94d                	beqz	a0,ffffffffc0201a86 <slob_free+0xb2>
{
ffffffffc02019d6:	1141                	addi	sp,sp,-16
ffffffffc02019d8:	e022                	sd	s0,0(sp)
ffffffffc02019da:	e406                	sd	ra,8(sp)
ffffffffc02019dc:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc02019de:	e9c1                	bnez	a1,ffffffffc0201a6e <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02019e0:	100027f3          	csrr	a5,sstatus
ffffffffc02019e4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02019e6:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02019e8:	ebd9                	bnez	a5,ffffffffc0201a7e <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019ea:	000cd617          	auipc	a2,0xcd
ffffffffc02019ee:	90e60613          	addi	a2,a2,-1778 # ffffffffc02ce2f8 <slobfree>
ffffffffc02019f2:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019f4:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019f6:	679c                	ld	a5,8(a5)
ffffffffc02019f8:	02877a63          	bgeu	a4,s0,ffffffffc0201a2c <slob_free+0x58>
ffffffffc02019fc:	00f46463          	bltu	s0,a5,ffffffffc0201a04 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a00:	fef76ae3          	bltu	a4,a5,ffffffffc02019f4 <slob_free+0x20>
			break;

	if (b + b->units == cur->next)
ffffffffc0201a04:	400c                	lw	a1,0(s0)
ffffffffc0201a06:	00459693          	slli	a3,a1,0x4
ffffffffc0201a0a:	96a2                	add	a3,a3,s0
ffffffffc0201a0c:	02d78a63          	beq	a5,a3,ffffffffc0201a40 <slob_free+0x6c>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc0201a10:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0201a12:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0201a14:	00469793          	slli	a5,a3,0x4
ffffffffc0201a18:	97ba                	add	a5,a5,a4
ffffffffc0201a1a:	02f40e63          	beq	s0,a5,ffffffffc0201a56 <slob_free+0x82>
	{
		cur->units += b->units;
		cur->next = b->next;
	}
	else
		cur->next = b;
ffffffffc0201a1e:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0201a20:	e218                	sd	a4,0(a2)
    if (flag)
ffffffffc0201a22:	e129                	bnez	a0,ffffffffc0201a64 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201a24:	60a2                	ld	ra,8(sp)
ffffffffc0201a26:	6402                	ld	s0,0(sp)
ffffffffc0201a28:	0141                	addi	sp,sp,16
ffffffffc0201a2a:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a2c:	fcf764e3          	bltu	a4,a5,ffffffffc02019f4 <slob_free+0x20>
ffffffffc0201a30:	fcf472e3          	bgeu	s0,a5,ffffffffc02019f4 <slob_free+0x20>
	if (b + b->units == cur->next)
ffffffffc0201a34:	400c                	lw	a1,0(s0)
ffffffffc0201a36:	00459693          	slli	a3,a1,0x4
ffffffffc0201a3a:	96a2                	add	a3,a3,s0
ffffffffc0201a3c:	fcd79ae3          	bne	a5,a3,ffffffffc0201a10 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0201a40:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201a42:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201a44:	9db5                	addw	a1,a1,a3
ffffffffc0201a46:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b)
ffffffffc0201a48:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a4a:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0201a4c:	00469793          	slli	a5,a3,0x4
ffffffffc0201a50:	97ba                	add	a5,a5,a4
ffffffffc0201a52:	fcf416e3          	bne	s0,a5,ffffffffc0201a1e <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0201a56:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201a58:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0201a5a:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201a5c:	9ebd                	addw	a3,a3,a5
ffffffffc0201a5e:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0201a60:	e70c                	sd	a1,8(a4)
ffffffffc0201a62:	d169                	beqz	a0,ffffffffc0201a24 <slob_free+0x50>
}
ffffffffc0201a64:	6402                	ld	s0,0(sp)
ffffffffc0201a66:	60a2                	ld	ra,8(sp)
ffffffffc0201a68:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201a6a:	f3ffe06f          	j	ffffffffc02009a8 <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0201a6e:	25bd                	addiw	a1,a1,15
ffffffffc0201a70:	8191                	srli	a1,a1,0x4
ffffffffc0201a72:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201a74:	100027f3          	csrr	a5,sstatus
ffffffffc0201a78:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201a7a:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201a7c:	d7bd                	beqz	a5,ffffffffc02019ea <slob_free+0x16>
        intr_disable();
ffffffffc0201a7e:	f31fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        return 1;
ffffffffc0201a82:	4505                	li	a0,1
ffffffffc0201a84:	b79d                	j	ffffffffc02019ea <slob_free+0x16>
ffffffffc0201a86:	8082                	ret

ffffffffc0201a88 <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201a88:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201a8a:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201a8c:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201a90:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201a92:	352000ef          	jal	ra,ffffffffc0201de4 <alloc_pages>
	if (!page)
ffffffffc0201a96:	c91d                	beqz	a0,ffffffffc0201acc <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201a98:	000d1697          	auipc	a3,0xd1
ffffffffc0201a9c:	d106b683          	ld	a3,-752(a3) # ffffffffc02d27a8 <pages>
ffffffffc0201aa0:	8d15                	sub	a0,a0,a3
ffffffffc0201aa2:	8519                	srai	a0,a0,0x6
ffffffffc0201aa4:	00007697          	auipc	a3,0x7
ffffffffc0201aa8:	a946b683          	ld	a3,-1388(a3) # ffffffffc0208538 <nbase>
ffffffffc0201aac:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201aae:	00c51793          	slli	a5,a0,0xc
ffffffffc0201ab2:	83b1                	srli	a5,a5,0xc
ffffffffc0201ab4:	000d1717          	auipc	a4,0xd1
ffffffffc0201ab8:	cec73703          	ld	a4,-788(a4) # ffffffffc02d27a0 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201abc:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201abe:	00e7fa63          	bgeu	a5,a4,ffffffffc0201ad2 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201ac2:	000d1697          	auipc	a3,0xd1
ffffffffc0201ac6:	cf66b683          	ld	a3,-778(a3) # ffffffffc02d27b8 <va_pa_offset>
ffffffffc0201aca:	9536                	add	a0,a0,a3
}
ffffffffc0201acc:	60a2                	ld	ra,8(sp)
ffffffffc0201ace:	0141                	addi	sp,sp,16
ffffffffc0201ad0:	8082                	ret
ffffffffc0201ad2:	86aa                	mv	a3,a0
ffffffffc0201ad4:	00005617          	auipc	a2,0x5
ffffffffc0201ad8:	03c60613          	addi	a2,a2,60 # ffffffffc0206b10 <default_pmm_manager+0x38>
ffffffffc0201adc:	07100593          	li	a1,113
ffffffffc0201ae0:	00005517          	auipc	a0,0x5
ffffffffc0201ae4:	05850513          	addi	a0,a0,88 # ffffffffc0206b38 <default_pmm_manager+0x60>
ffffffffc0201ae8:	9abfe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0201aec <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201aec:	1101                	addi	sp,sp,-32
ffffffffc0201aee:	ec06                	sd	ra,24(sp)
ffffffffc0201af0:	e822                	sd	s0,16(sp)
ffffffffc0201af2:	e426                	sd	s1,8(sp)
ffffffffc0201af4:	e04a                	sd	s2,0(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201af6:	01050713          	addi	a4,a0,16
ffffffffc0201afa:	6785                	lui	a5,0x1
ffffffffc0201afc:	0cf77363          	bgeu	a4,a5,ffffffffc0201bc2 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201b00:	00f50493          	addi	s1,a0,15
ffffffffc0201b04:	8091                	srli	s1,s1,0x4
ffffffffc0201b06:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b08:	10002673          	csrr	a2,sstatus
ffffffffc0201b0c:	8a09                	andi	a2,a2,2
ffffffffc0201b0e:	e25d                	bnez	a2,ffffffffc0201bb4 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201b10:	000cc917          	auipc	s2,0xcc
ffffffffc0201b14:	7e890913          	addi	s2,s2,2024 # ffffffffc02ce2f8 <slobfree>
ffffffffc0201b18:	00093683          	ld	a3,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201b1c:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta)
ffffffffc0201b1e:	4398                	lw	a4,0(a5)
ffffffffc0201b20:	08975e63          	bge	a4,s1,ffffffffc0201bbc <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree)
ffffffffc0201b24:	00f68b63          	beq	a3,a5,ffffffffc0201b3a <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201b28:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201b2a:	4018                	lw	a4,0(s0)
ffffffffc0201b2c:	02975a63          	bge	a4,s1,ffffffffc0201b60 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree)
ffffffffc0201b30:	00093683          	ld	a3,0(s2)
ffffffffc0201b34:	87a2                	mv	a5,s0
ffffffffc0201b36:	fef699e3          	bne	a3,a5,ffffffffc0201b28 <slob_alloc.constprop.0+0x3c>
    if (flag)
ffffffffc0201b3a:	ee31                	bnez	a2,ffffffffc0201b96 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201b3c:	4501                	li	a0,0
ffffffffc0201b3e:	f4bff0ef          	jal	ra,ffffffffc0201a88 <__slob_get_free_pages.constprop.0>
ffffffffc0201b42:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201b44:	cd05                	beqz	a0,ffffffffc0201b7c <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201b46:	6585                	lui	a1,0x1
ffffffffc0201b48:	e8dff0ef          	jal	ra,ffffffffc02019d4 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b4c:	10002673          	csrr	a2,sstatus
ffffffffc0201b50:	8a09                	andi	a2,a2,2
ffffffffc0201b52:	ee05                	bnez	a2,ffffffffc0201b8a <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201b54:	00093783          	ld	a5,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201b58:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201b5a:	4018                	lw	a4,0(s0)
ffffffffc0201b5c:	fc974ae3          	blt	a4,s1,ffffffffc0201b30 <slob_alloc.constprop.0+0x44>
			if (cur->units == units)	/* exact fit? */
ffffffffc0201b60:	04e48763          	beq	s1,a4,ffffffffc0201bae <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201b64:	00449693          	slli	a3,s1,0x4
ffffffffc0201b68:	96a2                	add	a3,a3,s0
ffffffffc0201b6a:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201b6c:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201b6e:	9f05                	subw	a4,a4,s1
ffffffffc0201b70:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201b72:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201b74:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201b76:	00f93023          	sd	a5,0(s2)
    if (flag)
ffffffffc0201b7a:	e20d                	bnez	a2,ffffffffc0201b9c <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201b7c:	60e2                	ld	ra,24(sp)
ffffffffc0201b7e:	8522                	mv	a0,s0
ffffffffc0201b80:	6442                	ld	s0,16(sp)
ffffffffc0201b82:	64a2                	ld	s1,8(sp)
ffffffffc0201b84:	6902                	ld	s2,0(sp)
ffffffffc0201b86:	6105                	addi	sp,sp,32
ffffffffc0201b88:	8082                	ret
        intr_disable();
ffffffffc0201b8a:	e25fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
			cur = slobfree;
ffffffffc0201b8e:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201b92:	4605                	li	a2,1
ffffffffc0201b94:	b7d1                	j	ffffffffc0201b58 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201b96:	e13fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0201b9a:	b74d                	j	ffffffffc0201b3c <slob_alloc.constprop.0+0x50>
ffffffffc0201b9c:	e0dfe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
}
ffffffffc0201ba0:	60e2                	ld	ra,24(sp)
ffffffffc0201ba2:	8522                	mv	a0,s0
ffffffffc0201ba4:	6442                	ld	s0,16(sp)
ffffffffc0201ba6:	64a2                	ld	s1,8(sp)
ffffffffc0201ba8:	6902                	ld	s2,0(sp)
ffffffffc0201baa:	6105                	addi	sp,sp,32
ffffffffc0201bac:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201bae:	6418                	ld	a4,8(s0)
ffffffffc0201bb0:	e798                	sd	a4,8(a5)
ffffffffc0201bb2:	b7d1                	j	ffffffffc0201b76 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201bb4:	dfbfe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        return 1;
ffffffffc0201bb8:	4605                	li	a2,1
ffffffffc0201bba:	bf99                	j	ffffffffc0201b10 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta)
ffffffffc0201bbc:	843e                	mv	s0,a5
ffffffffc0201bbe:	87b6                	mv	a5,a3
ffffffffc0201bc0:	b745                	j	ffffffffc0201b60 <slob_alloc.constprop.0+0x74>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201bc2:	00005697          	auipc	a3,0x5
ffffffffc0201bc6:	f8668693          	addi	a3,a3,-122 # ffffffffc0206b48 <default_pmm_manager+0x70>
ffffffffc0201bca:	00005617          	auipc	a2,0x5
ffffffffc0201bce:	b5e60613          	addi	a2,a2,-1186 # ffffffffc0206728 <commands+0x828>
ffffffffc0201bd2:	06300593          	li	a1,99
ffffffffc0201bd6:	00005517          	auipc	a0,0x5
ffffffffc0201bda:	f9250513          	addi	a0,a0,-110 # ffffffffc0206b68 <default_pmm_manager+0x90>
ffffffffc0201bde:	8b5fe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0201be2 <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc0201be2:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc0201be4:	00005517          	auipc	a0,0x5
ffffffffc0201be8:	f9c50513          	addi	a0,a0,-100 # ffffffffc0206b80 <default_pmm_manager+0xa8>
{
ffffffffc0201bec:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc0201bee:	daafe0ef          	jal	ra,ffffffffc0200198 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201bf2:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201bf4:	00005517          	auipc	a0,0x5
ffffffffc0201bf8:	fa450513          	addi	a0,a0,-92 # ffffffffc0206b98 <default_pmm_manager+0xc0>
}
ffffffffc0201bfc:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201bfe:	d9afe06f          	j	ffffffffc0200198 <cprintf>

ffffffffc0201c02 <kallocated>:

size_t
kallocated(void)
{
	return slob_allocated();
}
ffffffffc0201c02:	4501                	li	a0,0
ffffffffc0201c04:	8082                	ret

ffffffffc0201c06 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201c06:	1101                	addi	sp,sp,-32
ffffffffc0201c08:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201c0a:	6905                	lui	s2,0x1
{
ffffffffc0201c0c:	e822                	sd	s0,16(sp)
ffffffffc0201c0e:	ec06                	sd	ra,24(sp)
ffffffffc0201c10:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201c12:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8f61>
{
ffffffffc0201c16:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201c18:	04a7f963          	bgeu	a5,a0,ffffffffc0201c6a <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201c1c:	4561                	li	a0,24
ffffffffc0201c1e:	ecfff0ef          	jal	ra,ffffffffc0201aec <slob_alloc.constprop.0>
ffffffffc0201c22:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201c24:	c929                	beqz	a0,ffffffffc0201c76 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201c26:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201c2a:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc0201c2c:	00f95763          	bge	s2,a5,ffffffffc0201c3a <kmalloc+0x34>
ffffffffc0201c30:	6705                	lui	a4,0x1
ffffffffc0201c32:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201c34:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc0201c36:	fef74ee3          	blt	a4,a5,ffffffffc0201c32 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201c3a:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201c3c:	e4dff0ef          	jal	ra,ffffffffc0201a88 <__slob_get_free_pages.constprop.0>
ffffffffc0201c40:	e488                	sd	a0,8(s1)
ffffffffc0201c42:	842a                	mv	s0,a0
	if (bb->pages)
ffffffffc0201c44:	c525                	beqz	a0,ffffffffc0201cac <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201c46:	100027f3          	csrr	a5,sstatus
ffffffffc0201c4a:	8b89                	andi	a5,a5,2
ffffffffc0201c4c:	ef8d                	bnez	a5,ffffffffc0201c86 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201c4e:	000d1797          	auipc	a5,0xd1
ffffffffc0201c52:	b3a78793          	addi	a5,a5,-1222 # ffffffffc02d2788 <bigblocks>
ffffffffc0201c56:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201c58:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201c5a:	e898                	sd	a4,16(s1)
	return __kmalloc(size, 0);
}
ffffffffc0201c5c:	60e2                	ld	ra,24(sp)
ffffffffc0201c5e:	8522                	mv	a0,s0
ffffffffc0201c60:	6442                	ld	s0,16(sp)
ffffffffc0201c62:	64a2                	ld	s1,8(sp)
ffffffffc0201c64:	6902                	ld	s2,0(sp)
ffffffffc0201c66:	6105                	addi	sp,sp,32
ffffffffc0201c68:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201c6a:	0541                	addi	a0,a0,16
ffffffffc0201c6c:	e81ff0ef          	jal	ra,ffffffffc0201aec <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201c70:	01050413          	addi	s0,a0,16
ffffffffc0201c74:	f565                	bnez	a0,ffffffffc0201c5c <kmalloc+0x56>
ffffffffc0201c76:	4401                	li	s0,0
}
ffffffffc0201c78:	60e2                	ld	ra,24(sp)
ffffffffc0201c7a:	8522                	mv	a0,s0
ffffffffc0201c7c:	6442                	ld	s0,16(sp)
ffffffffc0201c7e:	64a2                	ld	s1,8(sp)
ffffffffc0201c80:	6902                	ld	s2,0(sp)
ffffffffc0201c82:	6105                	addi	sp,sp,32
ffffffffc0201c84:	8082                	ret
        intr_disable();
ffffffffc0201c86:	d29fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
		bb->next = bigblocks;
ffffffffc0201c8a:	000d1797          	auipc	a5,0xd1
ffffffffc0201c8e:	afe78793          	addi	a5,a5,-1282 # ffffffffc02d2788 <bigblocks>
ffffffffc0201c92:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201c94:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201c96:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201c98:	d11fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
		return bb->pages;
ffffffffc0201c9c:	6480                	ld	s0,8(s1)
}
ffffffffc0201c9e:	60e2                	ld	ra,24(sp)
ffffffffc0201ca0:	64a2                	ld	s1,8(sp)
ffffffffc0201ca2:	8522                	mv	a0,s0
ffffffffc0201ca4:	6442                	ld	s0,16(sp)
ffffffffc0201ca6:	6902                	ld	s2,0(sp)
ffffffffc0201ca8:	6105                	addi	sp,sp,32
ffffffffc0201caa:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201cac:	45e1                	li	a1,24
ffffffffc0201cae:	8526                	mv	a0,s1
ffffffffc0201cb0:	d25ff0ef          	jal	ra,ffffffffc02019d4 <slob_free>
	return __kmalloc(size, 0);
ffffffffc0201cb4:	b765                	j	ffffffffc0201c5c <kmalloc+0x56>

ffffffffc0201cb6 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201cb6:	c169                	beqz	a0,ffffffffc0201d78 <kfree+0xc2>
{
ffffffffc0201cb8:	1101                	addi	sp,sp,-32
ffffffffc0201cba:	e822                	sd	s0,16(sp)
ffffffffc0201cbc:	ec06                	sd	ra,24(sp)
ffffffffc0201cbe:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201cc0:	03451793          	slli	a5,a0,0x34
ffffffffc0201cc4:	842a                	mv	s0,a0
ffffffffc0201cc6:	e3d9                	bnez	a5,ffffffffc0201d4c <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201cc8:	100027f3          	csrr	a5,sstatus
ffffffffc0201ccc:	8b89                	andi	a5,a5,2
ffffffffc0201cce:	e7d9                	bnez	a5,ffffffffc0201d5c <kfree+0xa6>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201cd0:	000d1797          	auipc	a5,0xd1
ffffffffc0201cd4:	ab87b783          	ld	a5,-1352(a5) # ffffffffc02d2788 <bigblocks>
    return 0;
ffffffffc0201cd8:	4601                	li	a2,0
ffffffffc0201cda:	cbad                	beqz	a5,ffffffffc0201d4c <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201cdc:	000d1697          	auipc	a3,0xd1
ffffffffc0201ce0:	aac68693          	addi	a3,a3,-1364 # ffffffffc02d2788 <bigblocks>
ffffffffc0201ce4:	a021                	j	ffffffffc0201cec <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201ce6:	01048693          	addi	a3,s1,16
ffffffffc0201cea:	c3a5                	beqz	a5,ffffffffc0201d4a <kfree+0x94>
		{
			if (bb->pages == block)
ffffffffc0201cec:	6798                	ld	a4,8(a5)
ffffffffc0201cee:	84be                	mv	s1,a5
			{
				*last = bb->next;
ffffffffc0201cf0:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc0201cf2:	fe871ae3          	bne	a4,s0,ffffffffc0201ce6 <kfree+0x30>
				*last = bb->next;
ffffffffc0201cf6:	e29c                	sd	a5,0(a3)
    if (flag)
ffffffffc0201cf8:	ee2d                	bnez	a2,ffffffffc0201d72 <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201cfa:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201cfe:	4098                	lw	a4,0(s1)
ffffffffc0201d00:	08f46963          	bltu	s0,a5,ffffffffc0201d92 <kfree+0xdc>
ffffffffc0201d04:	000d1697          	auipc	a3,0xd1
ffffffffc0201d08:	ab46b683          	ld	a3,-1356(a3) # ffffffffc02d27b8 <va_pa_offset>
ffffffffc0201d0c:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage)
ffffffffc0201d0e:	8031                	srli	s0,s0,0xc
ffffffffc0201d10:	000d1797          	auipc	a5,0xd1
ffffffffc0201d14:	a907b783          	ld	a5,-1392(a5) # ffffffffc02d27a0 <npage>
ffffffffc0201d18:	06f47163          	bgeu	s0,a5,ffffffffc0201d7a <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d1c:	00007517          	auipc	a0,0x7
ffffffffc0201d20:	81c53503          	ld	a0,-2020(a0) # ffffffffc0208538 <nbase>
ffffffffc0201d24:	8c09                	sub	s0,s0,a0
ffffffffc0201d26:	041a                	slli	s0,s0,0x6
	free_pages(kva2page(kva), 1 << order);
ffffffffc0201d28:	000d1517          	auipc	a0,0xd1
ffffffffc0201d2c:	a8053503          	ld	a0,-1408(a0) # ffffffffc02d27a8 <pages>
ffffffffc0201d30:	4585                	li	a1,1
ffffffffc0201d32:	9522                	add	a0,a0,s0
ffffffffc0201d34:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201d38:	0ea000ef          	jal	ra,ffffffffc0201e22 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201d3c:	6442                	ld	s0,16(sp)
ffffffffc0201d3e:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d40:	8526                	mv	a0,s1
}
ffffffffc0201d42:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d44:	45e1                	li	a1,24
}
ffffffffc0201d46:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d48:	b171                	j	ffffffffc02019d4 <slob_free>
ffffffffc0201d4a:	e20d                	bnez	a2,ffffffffc0201d6c <kfree+0xb6>
ffffffffc0201d4c:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201d50:	6442                	ld	s0,16(sp)
ffffffffc0201d52:	60e2                	ld	ra,24(sp)
ffffffffc0201d54:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d56:	4581                	li	a1,0
}
ffffffffc0201d58:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d5a:	b9ad                	j	ffffffffc02019d4 <slob_free>
        intr_disable();
ffffffffc0201d5c:	c53fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201d60:	000d1797          	auipc	a5,0xd1
ffffffffc0201d64:	a287b783          	ld	a5,-1496(a5) # ffffffffc02d2788 <bigblocks>
        return 1;
ffffffffc0201d68:	4605                	li	a2,1
ffffffffc0201d6a:	fbad                	bnez	a5,ffffffffc0201cdc <kfree+0x26>
        intr_enable();
ffffffffc0201d6c:	c3dfe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0201d70:	bff1                	j	ffffffffc0201d4c <kfree+0x96>
ffffffffc0201d72:	c37fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0201d76:	b751                	j	ffffffffc0201cfa <kfree+0x44>
ffffffffc0201d78:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201d7a:	00005617          	auipc	a2,0x5
ffffffffc0201d7e:	e6660613          	addi	a2,a2,-410 # ffffffffc0206be0 <default_pmm_manager+0x108>
ffffffffc0201d82:	06900593          	li	a1,105
ffffffffc0201d86:	00005517          	auipc	a0,0x5
ffffffffc0201d8a:	db250513          	addi	a0,a0,-590 # ffffffffc0206b38 <default_pmm_manager+0x60>
ffffffffc0201d8e:	f04fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201d92:	86a2                	mv	a3,s0
ffffffffc0201d94:	00005617          	auipc	a2,0x5
ffffffffc0201d98:	e2460613          	addi	a2,a2,-476 # ffffffffc0206bb8 <default_pmm_manager+0xe0>
ffffffffc0201d9c:	07700593          	li	a1,119
ffffffffc0201da0:	00005517          	auipc	a0,0x5
ffffffffc0201da4:	d9850513          	addi	a0,a0,-616 # ffffffffc0206b38 <default_pmm_manager+0x60>
ffffffffc0201da8:	eeafe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0201dac <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc0201dac:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201dae:	00005617          	auipc	a2,0x5
ffffffffc0201db2:	e3260613          	addi	a2,a2,-462 # ffffffffc0206be0 <default_pmm_manager+0x108>
ffffffffc0201db6:	06900593          	li	a1,105
ffffffffc0201dba:	00005517          	auipc	a0,0x5
ffffffffc0201dbe:	d7e50513          	addi	a0,a0,-642 # ffffffffc0206b38 <default_pmm_manager+0x60>
pa2page(uintptr_t pa)
ffffffffc0201dc2:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201dc4:	ecefe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0201dc8 <pte2page.part.0>:
pte2page(pte_t pte)
ffffffffc0201dc8:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201dca:	00005617          	auipc	a2,0x5
ffffffffc0201dce:	e3660613          	addi	a2,a2,-458 # ffffffffc0206c00 <default_pmm_manager+0x128>
ffffffffc0201dd2:	07f00593          	li	a1,127
ffffffffc0201dd6:	00005517          	auipc	a0,0x5
ffffffffc0201dda:	d6250513          	addi	a0,a0,-670 # ffffffffc0206b38 <default_pmm_manager+0x60>
pte2page(pte_t pte)
ffffffffc0201dde:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201de0:	eb2fe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0201de4 <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201de4:	100027f3          	csrr	a5,sstatus
ffffffffc0201de8:	8b89                	andi	a5,a5,2
ffffffffc0201dea:	e799                	bnez	a5,ffffffffc0201df8 <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201dec:	000d1797          	auipc	a5,0xd1
ffffffffc0201df0:	9c47b783          	ld	a5,-1596(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0201df4:	6f9c                	ld	a5,24(a5)
ffffffffc0201df6:	8782                	jr	a5
{
ffffffffc0201df8:	1141                	addi	sp,sp,-16
ffffffffc0201dfa:	e406                	sd	ra,8(sp)
ffffffffc0201dfc:	e022                	sd	s0,0(sp)
ffffffffc0201dfe:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201e00:	baffe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201e04:	000d1797          	auipc	a5,0xd1
ffffffffc0201e08:	9ac7b783          	ld	a5,-1620(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0201e0c:	6f9c                	ld	a5,24(a5)
ffffffffc0201e0e:	8522                	mv	a0,s0
ffffffffc0201e10:	9782                	jalr	a5
ffffffffc0201e12:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201e14:	b95fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201e18:	60a2                	ld	ra,8(sp)
ffffffffc0201e1a:	8522                	mv	a0,s0
ffffffffc0201e1c:	6402                	ld	s0,0(sp)
ffffffffc0201e1e:	0141                	addi	sp,sp,16
ffffffffc0201e20:	8082                	ret

ffffffffc0201e22 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201e22:	100027f3          	csrr	a5,sstatus
ffffffffc0201e26:	8b89                	andi	a5,a5,2
ffffffffc0201e28:	e799                	bnez	a5,ffffffffc0201e36 <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201e2a:	000d1797          	auipc	a5,0xd1
ffffffffc0201e2e:	9867b783          	ld	a5,-1658(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0201e32:	739c                	ld	a5,32(a5)
ffffffffc0201e34:	8782                	jr	a5
{
ffffffffc0201e36:	1101                	addi	sp,sp,-32
ffffffffc0201e38:	ec06                	sd	ra,24(sp)
ffffffffc0201e3a:	e822                	sd	s0,16(sp)
ffffffffc0201e3c:	e426                	sd	s1,8(sp)
ffffffffc0201e3e:	842a                	mv	s0,a0
ffffffffc0201e40:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201e42:	b6dfe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201e46:	000d1797          	auipc	a5,0xd1
ffffffffc0201e4a:	96a7b783          	ld	a5,-1686(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0201e4e:	739c                	ld	a5,32(a5)
ffffffffc0201e50:	85a6                	mv	a1,s1
ffffffffc0201e52:	8522                	mv	a0,s0
ffffffffc0201e54:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201e56:	6442                	ld	s0,16(sp)
ffffffffc0201e58:	60e2                	ld	ra,24(sp)
ffffffffc0201e5a:	64a2                	ld	s1,8(sp)
ffffffffc0201e5c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201e5e:	b4bfe06f          	j	ffffffffc02009a8 <intr_enable>

ffffffffc0201e62 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201e62:	100027f3          	csrr	a5,sstatus
ffffffffc0201e66:	8b89                	andi	a5,a5,2
ffffffffc0201e68:	e799                	bnez	a5,ffffffffc0201e76 <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201e6a:	000d1797          	auipc	a5,0xd1
ffffffffc0201e6e:	9467b783          	ld	a5,-1722(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0201e72:	779c                	ld	a5,40(a5)
ffffffffc0201e74:	8782                	jr	a5
{
ffffffffc0201e76:	1141                	addi	sp,sp,-16
ffffffffc0201e78:	e406                	sd	ra,8(sp)
ffffffffc0201e7a:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201e7c:	b33fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201e80:	000d1797          	auipc	a5,0xd1
ffffffffc0201e84:	9307b783          	ld	a5,-1744(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0201e88:	779c                	ld	a5,40(a5)
ffffffffc0201e8a:	9782                	jalr	a5
ffffffffc0201e8c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201e8e:	b1bfe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201e92:	60a2                	ld	ra,8(sp)
ffffffffc0201e94:	8522                	mv	a0,s0
ffffffffc0201e96:	6402                	ld	s0,0(sp)
ffffffffc0201e98:	0141                	addi	sp,sp,16
ffffffffc0201e9a:	8082                	ret

ffffffffc0201e9c <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201e9c:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201ea0:	1ff7f793          	andi	a5,a5,511
{
ffffffffc0201ea4:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201ea6:	078e                	slli	a5,a5,0x3
{
ffffffffc0201ea8:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201eaa:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc0201eae:	6094                	ld	a3,0(s1)
{
ffffffffc0201eb0:	f04a                	sd	s2,32(sp)
ffffffffc0201eb2:	ec4e                	sd	s3,24(sp)
ffffffffc0201eb4:	e852                	sd	s4,16(sp)
ffffffffc0201eb6:	fc06                	sd	ra,56(sp)
ffffffffc0201eb8:	f822                	sd	s0,48(sp)
ffffffffc0201eba:	e456                	sd	s5,8(sp)
ffffffffc0201ebc:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc0201ebe:	0016f793          	andi	a5,a3,1
{
ffffffffc0201ec2:	892e                	mv	s2,a1
ffffffffc0201ec4:	8a32                	mv	s4,a2
ffffffffc0201ec6:	000d1997          	auipc	s3,0xd1
ffffffffc0201eca:	8da98993          	addi	s3,s3,-1830 # ffffffffc02d27a0 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc0201ece:	efbd                	bnez	a5,ffffffffc0201f4c <get_pte+0xb0>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201ed0:	14060c63          	beqz	a2,ffffffffc0202028 <get_pte+0x18c>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201ed4:	100027f3          	csrr	a5,sstatus
ffffffffc0201ed8:	8b89                	andi	a5,a5,2
ffffffffc0201eda:	14079963          	bnez	a5,ffffffffc020202c <get_pte+0x190>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201ede:	000d1797          	auipc	a5,0xd1
ffffffffc0201ee2:	8d27b783          	ld	a5,-1838(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0201ee6:	6f9c                	ld	a5,24(a5)
ffffffffc0201ee8:	4505                	li	a0,1
ffffffffc0201eea:	9782                	jalr	a5
ffffffffc0201eec:	842a                	mv	s0,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201eee:	12040d63          	beqz	s0,ffffffffc0202028 <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0201ef2:	000d1b17          	auipc	s6,0xd1
ffffffffc0201ef6:	8b6b0b13          	addi	s6,s6,-1866 # ffffffffc02d27a8 <pages>
ffffffffc0201efa:	000b3503          	ld	a0,0(s6)
ffffffffc0201efe:	00080ab7          	lui	s5,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f02:	000d1997          	auipc	s3,0xd1
ffffffffc0201f06:	89e98993          	addi	s3,s3,-1890 # ffffffffc02d27a0 <npage>
ffffffffc0201f0a:	40a40533          	sub	a0,s0,a0
ffffffffc0201f0e:	8519                	srai	a0,a0,0x6
ffffffffc0201f10:	9556                	add	a0,a0,s5
ffffffffc0201f12:	0009b703          	ld	a4,0(s3)
ffffffffc0201f16:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201f1a:	4685                	li	a3,1
ffffffffc0201f1c:	c014                	sw	a3,0(s0)
ffffffffc0201f1e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f20:	0532                	slli	a0,a0,0xc
ffffffffc0201f22:	16e7f763          	bgeu	a5,a4,ffffffffc0202090 <get_pte+0x1f4>
ffffffffc0201f26:	000d1797          	auipc	a5,0xd1
ffffffffc0201f2a:	8927b783          	ld	a5,-1902(a5) # ffffffffc02d27b8 <va_pa_offset>
ffffffffc0201f2e:	6605                	lui	a2,0x1
ffffffffc0201f30:	4581                	li	a1,0
ffffffffc0201f32:	953e                	add	a0,a0,a5
ffffffffc0201f34:	53b030ef          	jal	ra,ffffffffc0205c6e <memset>
    return page - pages + nbase;
ffffffffc0201f38:	000b3683          	ld	a3,0(s6)
ffffffffc0201f3c:	40d406b3          	sub	a3,s0,a3
ffffffffc0201f40:	8699                	srai	a3,a3,0x6
ffffffffc0201f42:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201f44:	06aa                	slli	a3,a3,0xa
ffffffffc0201f46:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201f4a:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201f4c:	77fd                	lui	a5,0xfffff
ffffffffc0201f4e:	068a                	slli	a3,a3,0x2
ffffffffc0201f50:	0009b703          	ld	a4,0(s3)
ffffffffc0201f54:	8efd                	and	a3,a3,a5
ffffffffc0201f56:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201f5a:	10e7ff63          	bgeu	a5,a4,ffffffffc0202078 <get_pte+0x1dc>
ffffffffc0201f5e:	000d1a97          	auipc	s5,0xd1
ffffffffc0201f62:	85aa8a93          	addi	s5,s5,-1958 # ffffffffc02d27b8 <va_pa_offset>
ffffffffc0201f66:	000ab403          	ld	s0,0(s5)
ffffffffc0201f6a:	01595793          	srli	a5,s2,0x15
ffffffffc0201f6e:	1ff7f793          	andi	a5,a5,511
ffffffffc0201f72:	96a2                	add	a3,a3,s0
ffffffffc0201f74:	00379413          	slli	s0,a5,0x3
ffffffffc0201f78:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V))
ffffffffc0201f7a:	6014                	ld	a3,0(s0)
ffffffffc0201f7c:	0016f793          	andi	a5,a3,1
ffffffffc0201f80:	ebad                	bnez	a5,ffffffffc0201ff2 <get_pte+0x156>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201f82:	0a0a0363          	beqz	s4,ffffffffc0202028 <get_pte+0x18c>
ffffffffc0201f86:	100027f3          	csrr	a5,sstatus
ffffffffc0201f8a:	8b89                	andi	a5,a5,2
ffffffffc0201f8c:	efcd                	bnez	a5,ffffffffc0202046 <get_pte+0x1aa>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201f8e:	000d1797          	auipc	a5,0xd1
ffffffffc0201f92:	8227b783          	ld	a5,-2014(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0201f96:	6f9c                	ld	a5,24(a5)
ffffffffc0201f98:	4505                	li	a0,1
ffffffffc0201f9a:	9782                	jalr	a5
ffffffffc0201f9c:	84aa                	mv	s1,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201f9e:	c4c9                	beqz	s1,ffffffffc0202028 <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0201fa0:	000d1b17          	auipc	s6,0xd1
ffffffffc0201fa4:	808b0b13          	addi	s6,s6,-2040 # ffffffffc02d27a8 <pages>
ffffffffc0201fa8:	000b3503          	ld	a0,0(s6)
ffffffffc0201fac:	00080a37          	lui	s4,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201fb0:	0009b703          	ld	a4,0(s3)
ffffffffc0201fb4:	40a48533          	sub	a0,s1,a0
ffffffffc0201fb8:	8519                	srai	a0,a0,0x6
ffffffffc0201fba:	9552                	add	a0,a0,s4
ffffffffc0201fbc:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201fc0:	4685                	li	a3,1
ffffffffc0201fc2:	c094                	sw	a3,0(s1)
ffffffffc0201fc4:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fc6:	0532                	slli	a0,a0,0xc
ffffffffc0201fc8:	0ee7f163          	bgeu	a5,a4,ffffffffc02020aa <get_pte+0x20e>
ffffffffc0201fcc:	000ab783          	ld	a5,0(s5)
ffffffffc0201fd0:	6605                	lui	a2,0x1
ffffffffc0201fd2:	4581                	li	a1,0
ffffffffc0201fd4:	953e                	add	a0,a0,a5
ffffffffc0201fd6:	499030ef          	jal	ra,ffffffffc0205c6e <memset>
    return page - pages + nbase;
ffffffffc0201fda:	000b3683          	ld	a3,0(s6)
ffffffffc0201fde:	40d486b3          	sub	a3,s1,a3
ffffffffc0201fe2:	8699                	srai	a3,a3,0x6
ffffffffc0201fe4:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201fe6:	06aa                	slli	a3,a3,0xa
ffffffffc0201fe8:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201fec:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201fee:	0009b703          	ld	a4,0(s3)
ffffffffc0201ff2:	068a                	slli	a3,a3,0x2
ffffffffc0201ff4:	757d                	lui	a0,0xfffff
ffffffffc0201ff6:	8ee9                	and	a3,a3,a0
ffffffffc0201ff8:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201ffc:	06e7f263          	bgeu	a5,a4,ffffffffc0202060 <get_pte+0x1c4>
ffffffffc0202000:	000ab503          	ld	a0,0(s5)
ffffffffc0202004:	00c95913          	srli	s2,s2,0xc
ffffffffc0202008:	1ff97913          	andi	s2,s2,511
ffffffffc020200c:	96aa                	add	a3,a3,a0
ffffffffc020200e:	00391513          	slli	a0,s2,0x3
ffffffffc0202012:	9536                	add	a0,a0,a3
}
ffffffffc0202014:	70e2                	ld	ra,56(sp)
ffffffffc0202016:	7442                	ld	s0,48(sp)
ffffffffc0202018:	74a2                	ld	s1,40(sp)
ffffffffc020201a:	7902                	ld	s2,32(sp)
ffffffffc020201c:	69e2                	ld	s3,24(sp)
ffffffffc020201e:	6a42                	ld	s4,16(sp)
ffffffffc0202020:	6aa2                	ld	s5,8(sp)
ffffffffc0202022:	6b02                	ld	s6,0(sp)
ffffffffc0202024:	6121                	addi	sp,sp,64
ffffffffc0202026:	8082                	ret
            return NULL;
ffffffffc0202028:	4501                	li	a0,0
ffffffffc020202a:	b7ed                	j	ffffffffc0202014 <get_pte+0x178>
        intr_disable();
ffffffffc020202c:	983fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202030:	000d0797          	auipc	a5,0xd0
ffffffffc0202034:	7807b783          	ld	a5,1920(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0202038:	6f9c                	ld	a5,24(a5)
ffffffffc020203a:	4505                	li	a0,1
ffffffffc020203c:	9782                	jalr	a5
ffffffffc020203e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202040:	969fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202044:	b56d                	j	ffffffffc0201eee <get_pte+0x52>
        intr_disable();
ffffffffc0202046:	969fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc020204a:	000d0797          	auipc	a5,0xd0
ffffffffc020204e:	7667b783          	ld	a5,1894(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0202052:	6f9c                	ld	a5,24(a5)
ffffffffc0202054:	4505                	li	a0,1
ffffffffc0202056:	9782                	jalr	a5
ffffffffc0202058:	84aa                	mv	s1,a0
        intr_enable();
ffffffffc020205a:	94ffe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc020205e:	b781                	j	ffffffffc0201f9e <get_pte+0x102>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202060:	00005617          	auipc	a2,0x5
ffffffffc0202064:	ab060613          	addi	a2,a2,-1360 # ffffffffc0206b10 <default_pmm_manager+0x38>
ffffffffc0202068:	0fa00593          	li	a1,250
ffffffffc020206c:	00005517          	auipc	a0,0x5
ffffffffc0202070:	bbc50513          	addi	a0,a0,-1092 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0202074:	c1efe0ef          	jal	ra,ffffffffc0200492 <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202078:	00005617          	auipc	a2,0x5
ffffffffc020207c:	a9860613          	addi	a2,a2,-1384 # ffffffffc0206b10 <default_pmm_manager+0x38>
ffffffffc0202080:	0ed00593          	li	a1,237
ffffffffc0202084:	00005517          	auipc	a0,0x5
ffffffffc0202088:	ba450513          	addi	a0,a0,-1116 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc020208c:	c06fe0ef          	jal	ra,ffffffffc0200492 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202090:	86aa                	mv	a3,a0
ffffffffc0202092:	00005617          	auipc	a2,0x5
ffffffffc0202096:	a7e60613          	addi	a2,a2,-1410 # ffffffffc0206b10 <default_pmm_manager+0x38>
ffffffffc020209a:	0e900593          	li	a1,233
ffffffffc020209e:	00005517          	auipc	a0,0x5
ffffffffc02020a2:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc02020a6:	becfe0ef          	jal	ra,ffffffffc0200492 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020aa:	86aa                	mv	a3,a0
ffffffffc02020ac:	00005617          	auipc	a2,0x5
ffffffffc02020b0:	a6460613          	addi	a2,a2,-1436 # ffffffffc0206b10 <default_pmm_manager+0x38>
ffffffffc02020b4:	0f700593          	li	a1,247
ffffffffc02020b8:	00005517          	auipc	a0,0x5
ffffffffc02020bc:	b7050513          	addi	a0,a0,-1168 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc02020c0:	bd2fe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02020c4 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc02020c4:	1141                	addi	sp,sp,-16
ffffffffc02020c6:	e022                	sd	s0,0(sp)
ffffffffc02020c8:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02020ca:	4601                	li	a2,0
{
ffffffffc02020cc:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02020ce:	dcfff0ef          	jal	ra,ffffffffc0201e9c <get_pte>
    if (ptep_store != NULL)
ffffffffc02020d2:	c011                	beqz	s0,ffffffffc02020d6 <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc02020d4:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc02020d6:	c511                	beqz	a0,ffffffffc02020e2 <get_page+0x1e>
ffffffffc02020d8:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02020da:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc02020dc:	0017f713          	andi	a4,a5,1
ffffffffc02020e0:	e709                	bnez	a4,ffffffffc02020ea <get_page+0x26>
}
ffffffffc02020e2:	60a2                	ld	ra,8(sp)
ffffffffc02020e4:	6402                	ld	s0,0(sp)
ffffffffc02020e6:	0141                	addi	sp,sp,16
ffffffffc02020e8:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02020ea:	078a                	slli	a5,a5,0x2
ffffffffc02020ec:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02020ee:	000d0717          	auipc	a4,0xd0
ffffffffc02020f2:	6b273703          	ld	a4,1714(a4) # ffffffffc02d27a0 <npage>
ffffffffc02020f6:	00e7ff63          	bgeu	a5,a4,ffffffffc0202114 <get_page+0x50>
ffffffffc02020fa:	60a2                	ld	ra,8(sp)
ffffffffc02020fc:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc02020fe:	fff80537          	lui	a0,0xfff80
ffffffffc0202102:	97aa                	add	a5,a5,a0
ffffffffc0202104:	079a                	slli	a5,a5,0x6
ffffffffc0202106:	000d0517          	auipc	a0,0xd0
ffffffffc020210a:	6a253503          	ld	a0,1698(a0) # ffffffffc02d27a8 <pages>
ffffffffc020210e:	953e                	add	a0,a0,a5
ffffffffc0202110:	0141                	addi	sp,sp,16
ffffffffc0202112:	8082                	ret
ffffffffc0202114:	c99ff0ef          	jal	ra,ffffffffc0201dac <pa2page.part.0>

ffffffffc0202118 <unmap_range>:
        tlb_invalidate(pgdir, la); //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc0202118:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020211a:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc020211e:	f486                	sd	ra,104(sp)
ffffffffc0202120:	f0a2                	sd	s0,96(sp)
ffffffffc0202122:	eca6                	sd	s1,88(sp)
ffffffffc0202124:	e8ca                	sd	s2,80(sp)
ffffffffc0202126:	e4ce                	sd	s3,72(sp)
ffffffffc0202128:	e0d2                	sd	s4,64(sp)
ffffffffc020212a:	fc56                	sd	s5,56(sp)
ffffffffc020212c:	f85a                	sd	s6,48(sp)
ffffffffc020212e:	f45e                	sd	s7,40(sp)
ffffffffc0202130:	f062                	sd	s8,32(sp)
ffffffffc0202132:	ec66                	sd	s9,24(sp)
ffffffffc0202134:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202136:	17d2                	slli	a5,a5,0x34
ffffffffc0202138:	e3ed                	bnez	a5,ffffffffc020221a <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc020213a:	002007b7          	lui	a5,0x200
ffffffffc020213e:	842e                	mv	s0,a1
ffffffffc0202140:	0ef5ed63          	bltu	a1,a5,ffffffffc020223a <unmap_range+0x122>
ffffffffc0202144:	8932                	mv	s2,a2
ffffffffc0202146:	0ec5fa63          	bgeu	a1,a2,ffffffffc020223a <unmap_range+0x122>
ffffffffc020214a:	4785                	li	a5,1
ffffffffc020214c:	07fe                	slli	a5,a5,0x1f
ffffffffc020214e:	0ec7e663          	bltu	a5,a2,ffffffffc020223a <unmap_range+0x122>
ffffffffc0202152:	89aa                	mv	s3,a0
        }
        if (*ptep != 0)
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0202154:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage)
ffffffffc0202156:	000d0c97          	auipc	s9,0xd0
ffffffffc020215a:	64ac8c93          	addi	s9,s9,1610 # ffffffffc02d27a0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020215e:	000d0c17          	auipc	s8,0xd0
ffffffffc0202162:	64ac0c13          	addi	s8,s8,1610 # ffffffffc02d27a8 <pages>
ffffffffc0202166:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc020216a:	000d0d17          	auipc	s10,0xd0
ffffffffc020216e:	646d0d13          	addi	s10,s10,1606 # ffffffffc02d27b0 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202172:	00200b37          	lui	s6,0x200
ffffffffc0202176:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc020217a:	4601                	li	a2,0
ffffffffc020217c:	85a2                	mv	a1,s0
ffffffffc020217e:	854e                	mv	a0,s3
ffffffffc0202180:	d1dff0ef          	jal	ra,ffffffffc0201e9c <get_pte>
ffffffffc0202184:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc0202186:	cd29                	beqz	a0,ffffffffc02021e0 <unmap_range+0xc8>
        if (*ptep != 0)
ffffffffc0202188:	611c                	ld	a5,0(a0)
ffffffffc020218a:	e395                	bnez	a5,ffffffffc02021ae <unmap_range+0x96>
        start += PGSIZE;
ffffffffc020218c:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc020218e:	ff2466e3          	bltu	s0,s2,ffffffffc020217a <unmap_range+0x62>
}
ffffffffc0202192:	70a6                	ld	ra,104(sp)
ffffffffc0202194:	7406                	ld	s0,96(sp)
ffffffffc0202196:	64e6                	ld	s1,88(sp)
ffffffffc0202198:	6946                	ld	s2,80(sp)
ffffffffc020219a:	69a6                	ld	s3,72(sp)
ffffffffc020219c:	6a06                	ld	s4,64(sp)
ffffffffc020219e:	7ae2                	ld	s5,56(sp)
ffffffffc02021a0:	7b42                	ld	s6,48(sp)
ffffffffc02021a2:	7ba2                	ld	s7,40(sp)
ffffffffc02021a4:	7c02                	ld	s8,32(sp)
ffffffffc02021a6:	6ce2                	ld	s9,24(sp)
ffffffffc02021a8:	6d42                	ld	s10,16(sp)
ffffffffc02021aa:	6165                	addi	sp,sp,112
ffffffffc02021ac:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc02021ae:	0017f713          	andi	a4,a5,1
ffffffffc02021b2:	df69                	beqz	a4,ffffffffc020218c <unmap_range+0x74>
    if (PPN(pa) >= npage)
ffffffffc02021b4:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc02021b8:	078a                	slli	a5,a5,0x2
ffffffffc02021ba:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02021bc:	08e7ff63          	bgeu	a5,a4,ffffffffc020225a <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc02021c0:	000c3503          	ld	a0,0(s8)
ffffffffc02021c4:	97de                	add	a5,a5,s7
ffffffffc02021c6:	079a                	slli	a5,a5,0x6
ffffffffc02021c8:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02021ca:	411c                	lw	a5,0(a0)
ffffffffc02021cc:	fff7871b          	addiw	a4,a5,-1
ffffffffc02021d0:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02021d2:	cf11                	beqz	a4,ffffffffc02021ee <unmap_range+0xd6>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc02021d4:	0004b023          	sd	zero,0(s1)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02021d8:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc02021dc:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02021de:	bf45                	j	ffffffffc020218e <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02021e0:	945a                	add	s0,s0,s6
ffffffffc02021e2:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc02021e6:	d455                	beqz	s0,ffffffffc0202192 <unmap_range+0x7a>
ffffffffc02021e8:	f92469e3          	bltu	s0,s2,ffffffffc020217a <unmap_range+0x62>
ffffffffc02021ec:	b75d                	j	ffffffffc0202192 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02021ee:	100027f3          	csrr	a5,sstatus
ffffffffc02021f2:	8b89                	andi	a5,a5,2
ffffffffc02021f4:	e799                	bnez	a5,ffffffffc0202202 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc02021f6:	000d3783          	ld	a5,0(s10)
ffffffffc02021fa:	4585                	li	a1,1
ffffffffc02021fc:	739c                	ld	a5,32(a5)
ffffffffc02021fe:	9782                	jalr	a5
    if (flag)
ffffffffc0202200:	bfd1                	j	ffffffffc02021d4 <unmap_range+0xbc>
ffffffffc0202202:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202204:	faafe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc0202208:	000d3783          	ld	a5,0(s10)
ffffffffc020220c:	6522                	ld	a0,8(sp)
ffffffffc020220e:	4585                	li	a1,1
ffffffffc0202210:	739c                	ld	a5,32(a5)
ffffffffc0202212:	9782                	jalr	a5
        intr_enable();
ffffffffc0202214:	f94fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202218:	bf75                	j	ffffffffc02021d4 <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020221a:	00005697          	auipc	a3,0x5
ffffffffc020221e:	a1e68693          	addi	a3,a3,-1506 # ffffffffc0206c38 <default_pmm_manager+0x160>
ffffffffc0202222:	00004617          	auipc	a2,0x4
ffffffffc0202226:	50660613          	addi	a2,a2,1286 # ffffffffc0206728 <commands+0x828>
ffffffffc020222a:	12200593          	li	a1,290
ffffffffc020222e:	00005517          	auipc	a0,0x5
ffffffffc0202232:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0202236:	a5cfe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020223a:	00005697          	auipc	a3,0x5
ffffffffc020223e:	a2e68693          	addi	a3,a3,-1490 # ffffffffc0206c68 <default_pmm_manager+0x190>
ffffffffc0202242:	00004617          	auipc	a2,0x4
ffffffffc0202246:	4e660613          	addi	a2,a2,1254 # ffffffffc0206728 <commands+0x828>
ffffffffc020224a:	12300593          	li	a1,291
ffffffffc020224e:	00005517          	auipc	a0,0x5
ffffffffc0202252:	9da50513          	addi	a0,a0,-1574 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0202256:	a3cfe0ef          	jal	ra,ffffffffc0200492 <__panic>
ffffffffc020225a:	b53ff0ef          	jal	ra,ffffffffc0201dac <pa2page.part.0>

ffffffffc020225e <exit_range>:
{
ffffffffc020225e:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202260:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0202264:	fc86                	sd	ra,120(sp)
ffffffffc0202266:	f8a2                	sd	s0,112(sp)
ffffffffc0202268:	f4a6                	sd	s1,104(sp)
ffffffffc020226a:	f0ca                	sd	s2,96(sp)
ffffffffc020226c:	ecce                	sd	s3,88(sp)
ffffffffc020226e:	e8d2                	sd	s4,80(sp)
ffffffffc0202270:	e4d6                	sd	s5,72(sp)
ffffffffc0202272:	e0da                	sd	s6,64(sp)
ffffffffc0202274:	fc5e                	sd	s7,56(sp)
ffffffffc0202276:	f862                	sd	s8,48(sp)
ffffffffc0202278:	f466                	sd	s9,40(sp)
ffffffffc020227a:	f06a                	sd	s10,32(sp)
ffffffffc020227c:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020227e:	17d2                	slli	a5,a5,0x34
ffffffffc0202280:	20079a63          	bnez	a5,ffffffffc0202494 <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc0202284:	002007b7          	lui	a5,0x200
ffffffffc0202288:	24f5e463          	bltu	a1,a5,ffffffffc02024d0 <exit_range+0x272>
ffffffffc020228c:	8ab2                	mv	s5,a2
ffffffffc020228e:	24c5f163          	bgeu	a1,a2,ffffffffc02024d0 <exit_range+0x272>
ffffffffc0202292:	4785                	li	a5,1
ffffffffc0202294:	07fe                	slli	a5,a5,0x1f
ffffffffc0202296:	22c7ed63          	bltu	a5,a2,ffffffffc02024d0 <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc020229a:	c00009b7          	lui	s3,0xc0000
ffffffffc020229e:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02022a2:	ffe00937          	lui	s2,0xffe00
ffffffffc02022a6:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc02022aa:	5cfd                	li	s9,-1
ffffffffc02022ac:	8c2a                	mv	s8,a0
ffffffffc02022ae:	0125f933          	and	s2,a1,s2
ffffffffc02022b2:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage)
ffffffffc02022b4:	000d0d17          	auipc	s10,0xd0
ffffffffc02022b8:	4ecd0d13          	addi	s10,s10,1260 # ffffffffc02d27a0 <npage>
    return KADDR(page2pa(page));
ffffffffc02022bc:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc02022c0:	000d0717          	auipc	a4,0xd0
ffffffffc02022c4:	4e870713          	addi	a4,a4,1256 # ffffffffc02d27a8 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc02022c8:	000d0d97          	auipc	s11,0xd0
ffffffffc02022cc:	4e8d8d93          	addi	s11,s11,1256 # ffffffffc02d27b0 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02022d0:	c0000437          	lui	s0,0xc0000
ffffffffc02022d4:	944e                	add	s0,s0,s3
ffffffffc02022d6:	8079                	srli	s0,s0,0x1e
ffffffffc02022d8:	1ff47413          	andi	s0,s0,511
ffffffffc02022dc:	040e                	slli	s0,s0,0x3
ffffffffc02022de:	9462                	add	s0,s0,s8
ffffffffc02022e0:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_matrix_out_size+0xffffffffbfff38d8>
        if (pde1 & PTE_V)
ffffffffc02022e4:	001a7793          	andi	a5,s4,1
ffffffffc02022e8:	eb99                	bnez	a5,ffffffffc02022fe <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc02022ea:	12098463          	beqz	s3,ffffffffc0202412 <exit_range+0x1b4>
ffffffffc02022ee:	400007b7          	lui	a5,0x40000
ffffffffc02022f2:	97ce                	add	a5,a5,s3
ffffffffc02022f4:	894e                	mv	s2,s3
ffffffffc02022f6:	1159fe63          	bgeu	s3,s5,ffffffffc0202412 <exit_range+0x1b4>
ffffffffc02022fa:	89be                	mv	s3,a5
ffffffffc02022fc:	bfd1                	j	ffffffffc02022d0 <exit_range+0x72>
    if (PPN(pa) >= npage)
ffffffffc02022fe:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202302:	0a0a                	slli	s4,s4,0x2
ffffffffc0202304:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage)
ffffffffc0202308:	1cfa7263          	bgeu	s4,a5,ffffffffc02024cc <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc020230c:	fff80637          	lui	a2,0xfff80
ffffffffc0202310:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc0202312:	000806b7          	lui	a3,0x80
ffffffffc0202316:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0202318:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc020231c:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc020231e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202320:	18f5fa63          	bgeu	a1,a5,ffffffffc02024b4 <exit_range+0x256>
ffffffffc0202324:	000d0817          	auipc	a6,0xd0
ffffffffc0202328:	49480813          	addi	a6,a6,1172 # ffffffffc02d27b8 <va_pa_offset>
ffffffffc020232c:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc0202330:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc0202332:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc0202336:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc0202338:	00080337          	lui	t1,0x80
ffffffffc020233c:	6885                	lui	a7,0x1
ffffffffc020233e:	a819                	j	ffffffffc0202354 <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc0202340:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc0202342:	002007b7          	lui	a5,0x200
ffffffffc0202346:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202348:	08090c63          	beqz	s2,ffffffffc02023e0 <exit_range+0x182>
ffffffffc020234c:	09397a63          	bgeu	s2,s3,ffffffffc02023e0 <exit_range+0x182>
ffffffffc0202350:	0f597063          	bgeu	s2,s5,ffffffffc0202430 <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0202354:	01595493          	srli	s1,s2,0x15
ffffffffc0202358:	1ff4f493          	andi	s1,s1,511
ffffffffc020235c:	048e                	slli	s1,s1,0x3
ffffffffc020235e:	94da                	add	s1,s1,s6
ffffffffc0202360:	609c                	ld	a5,0(s1)
                if (pde0 & PTE_V)
ffffffffc0202362:	0017f693          	andi	a3,a5,1
ffffffffc0202366:	dee9                	beqz	a3,ffffffffc0202340 <exit_range+0xe2>
    if (PPN(pa) >= npage)
ffffffffc0202368:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc020236c:	078a                	slli	a5,a5,0x2
ffffffffc020236e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202370:	14b7fe63          	bgeu	a5,a1,ffffffffc02024cc <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202374:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc0202376:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc020237a:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc020237e:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202382:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202384:	12bef863          	bgeu	t4,a1,ffffffffc02024b4 <exit_range+0x256>
ffffffffc0202388:	00083783          	ld	a5,0(a6)
ffffffffc020238c:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc020238e:	011685b3          	add	a1,a3,a7
                        if (pt[i] & PTE_V)
ffffffffc0202392:	629c                	ld	a5,0(a3)
ffffffffc0202394:	8b85                	andi	a5,a5,1
ffffffffc0202396:	f7d5                	bnez	a5,ffffffffc0202342 <exit_range+0xe4>
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc0202398:	06a1                	addi	a3,a3,8
ffffffffc020239a:	fed59ce3          	bne	a1,a3,ffffffffc0202392 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc020239e:	631c                	ld	a5,0(a4)
ffffffffc02023a0:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02023a2:	100027f3          	csrr	a5,sstatus
ffffffffc02023a6:	8b89                	andi	a5,a5,2
ffffffffc02023a8:	e7d9                	bnez	a5,ffffffffc0202436 <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc02023aa:	000db783          	ld	a5,0(s11)
ffffffffc02023ae:	4585                	li	a1,1
ffffffffc02023b0:	e032                	sd	a2,0(sp)
ffffffffc02023b2:	739c                	ld	a5,32(a5)
ffffffffc02023b4:	9782                	jalr	a5
    if (flag)
ffffffffc02023b6:	6602                	ld	a2,0(sp)
ffffffffc02023b8:	000d0817          	auipc	a6,0xd0
ffffffffc02023bc:	40080813          	addi	a6,a6,1024 # ffffffffc02d27b8 <va_pa_offset>
ffffffffc02023c0:	fff80e37          	lui	t3,0xfff80
ffffffffc02023c4:	00080337          	lui	t1,0x80
ffffffffc02023c8:	6885                	lui	a7,0x1
ffffffffc02023ca:	000d0717          	auipc	a4,0xd0
ffffffffc02023ce:	3de70713          	addi	a4,a4,990 # ffffffffc02d27a8 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc02023d2:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc02023d6:	002007b7          	lui	a5,0x200
ffffffffc02023da:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc02023dc:	f60918e3          	bnez	s2,ffffffffc020234c <exit_range+0xee>
            if (free_pd0)
ffffffffc02023e0:	f00b85e3          	beqz	s7,ffffffffc02022ea <exit_range+0x8c>
    if (PPN(pa) >= npage)
ffffffffc02023e4:	000d3783          	ld	a5,0(s10)
ffffffffc02023e8:	0efa7263          	bgeu	s4,a5,ffffffffc02024cc <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02023ec:	6308                	ld	a0,0(a4)
ffffffffc02023ee:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02023f0:	100027f3          	csrr	a5,sstatus
ffffffffc02023f4:	8b89                	andi	a5,a5,2
ffffffffc02023f6:	efad                	bnez	a5,ffffffffc0202470 <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc02023f8:	000db783          	ld	a5,0(s11)
ffffffffc02023fc:	4585                	li	a1,1
ffffffffc02023fe:	739c                	ld	a5,32(a5)
ffffffffc0202400:	9782                	jalr	a5
ffffffffc0202402:	000d0717          	auipc	a4,0xd0
ffffffffc0202406:	3a670713          	addi	a4,a4,934 # ffffffffc02d27a8 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc020240a:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc020240e:	ee0990e3          	bnez	s3,ffffffffc02022ee <exit_range+0x90>
}
ffffffffc0202412:	70e6                	ld	ra,120(sp)
ffffffffc0202414:	7446                	ld	s0,112(sp)
ffffffffc0202416:	74a6                	ld	s1,104(sp)
ffffffffc0202418:	7906                	ld	s2,96(sp)
ffffffffc020241a:	69e6                	ld	s3,88(sp)
ffffffffc020241c:	6a46                	ld	s4,80(sp)
ffffffffc020241e:	6aa6                	ld	s5,72(sp)
ffffffffc0202420:	6b06                	ld	s6,64(sp)
ffffffffc0202422:	7be2                	ld	s7,56(sp)
ffffffffc0202424:	7c42                	ld	s8,48(sp)
ffffffffc0202426:	7ca2                	ld	s9,40(sp)
ffffffffc0202428:	7d02                	ld	s10,32(sp)
ffffffffc020242a:	6de2                	ld	s11,24(sp)
ffffffffc020242c:	6109                	addi	sp,sp,128
ffffffffc020242e:	8082                	ret
            if (free_pd0)
ffffffffc0202430:	ea0b8fe3          	beqz	s7,ffffffffc02022ee <exit_range+0x90>
ffffffffc0202434:	bf45                	j	ffffffffc02023e4 <exit_range+0x186>
ffffffffc0202436:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc0202438:	e42a                	sd	a0,8(sp)
ffffffffc020243a:	d74fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020243e:	000db783          	ld	a5,0(s11)
ffffffffc0202442:	6522                	ld	a0,8(sp)
ffffffffc0202444:	4585                	li	a1,1
ffffffffc0202446:	739c                	ld	a5,32(a5)
ffffffffc0202448:	9782                	jalr	a5
        intr_enable();
ffffffffc020244a:	d5efe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc020244e:	6602                	ld	a2,0(sp)
ffffffffc0202450:	000d0717          	auipc	a4,0xd0
ffffffffc0202454:	35870713          	addi	a4,a4,856 # ffffffffc02d27a8 <pages>
ffffffffc0202458:	6885                	lui	a7,0x1
ffffffffc020245a:	00080337          	lui	t1,0x80
ffffffffc020245e:	fff80e37          	lui	t3,0xfff80
ffffffffc0202462:	000d0817          	auipc	a6,0xd0
ffffffffc0202466:	35680813          	addi	a6,a6,854 # ffffffffc02d27b8 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc020246a:	0004b023          	sd	zero,0(s1)
ffffffffc020246e:	b7a5                	j	ffffffffc02023d6 <exit_range+0x178>
ffffffffc0202470:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0202472:	d3cfe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202476:	000db783          	ld	a5,0(s11)
ffffffffc020247a:	6502                	ld	a0,0(sp)
ffffffffc020247c:	4585                	li	a1,1
ffffffffc020247e:	739c                	ld	a5,32(a5)
ffffffffc0202480:	9782                	jalr	a5
        intr_enable();
ffffffffc0202482:	d26fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202486:	000d0717          	auipc	a4,0xd0
ffffffffc020248a:	32270713          	addi	a4,a4,802 # ffffffffc02d27a8 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc020248e:	00043023          	sd	zero,0(s0)
ffffffffc0202492:	bfb5                	j	ffffffffc020240e <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202494:	00004697          	auipc	a3,0x4
ffffffffc0202498:	7a468693          	addi	a3,a3,1956 # ffffffffc0206c38 <default_pmm_manager+0x160>
ffffffffc020249c:	00004617          	auipc	a2,0x4
ffffffffc02024a0:	28c60613          	addi	a2,a2,652 # ffffffffc0206728 <commands+0x828>
ffffffffc02024a4:	13700593          	li	a1,311
ffffffffc02024a8:	00004517          	auipc	a0,0x4
ffffffffc02024ac:	78050513          	addi	a0,a0,1920 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc02024b0:	fe3fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    return KADDR(page2pa(page));
ffffffffc02024b4:	00004617          	auipc	a2,0x4
ffffffffc02024b8:	65c60613          	addi	a2,a2,1628 # ffffffffc0206b10 <default_pmm_manager+0x38>
ffffffffc02024bc:	07100593          	li	a1,113
ffffffffc02024c0:	00004517          	auipc	a0,0x4
ffffffffc02024c4:	67850513          	addi	a0,a0,1656 # ffffffffc0206b38 <default_pmm_manager+0x60>
ffffffffc02024c8:	fcbfd0ef          	jal	ra,ffffffffc0200492 <__panic>
ffffffffc02024cc:	8e1ff0ef          	jal	ra,ffffffffc0201dac <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc02024d0:	00004697          	auipc	a3,0x4
ffffffffc02024d4:	79868693          	addi	a3,a3,1944 # ffffffffc0206c68 <default_pmm_manager+0x190>
ffffffffc02024d8:	00004617          	auipc	a2,0x4
ffffffffc02024dc:	25060613          	addi	a2,a2,592 # ffffffffc0206728 <commands+0x828>
ffffffffc02024e0:	13800593          	li	a1,312
ffffffffc02024e4:	00004517          	auipc	a0,0x4
ffffffffc02024e8:	74450513          	addi	a0,a0,1860 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc02024ec:	fa7fd0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02024f0 <page_remove>:
{
ffffffffc02024f0:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02024f2:	4601                	li	a2,0
{
ffffffffc02024f4:	ec26                	sd	s1,24(sp)
ffffffffc02024f6:	f406                	sd	ra,40(sp)
ffffffffc02024f8:	f022                	sd	s0,32(sp)
ffffffffc02024fa:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02024fc:	9a1ff0ef          	jal	ra,ffffffffc0201e9c <get_pte>
    if (ptep != NULL)
ffffffffc0202500:	c511                	beqz	a0,ffffffffc020250c <page_remove+0x1c>
    if (*ptep & PTE_V)
ffffffffc0202502:	611c                	ld	a5,0(a0)
ffffffffc0202504:	842a                	mv	s0,a0
ffffffffc0202506:	0017f713          	andi	a4,a5,1
ffffffffc020250a:	e711                	bnez	a4,ffffffffc0202516 <page_remove+0x26>
}
ffffffffc020250c:	70a2                	ld	ra,40(sp)
ffffffffc020250e:	7402                	ld	s0,32(sp)
ffffffffc0202510:	64e2                	ld	s1,24(sp)
ffffffffc0202512:	6145                	addi	sp,sp,48
ffffffffc0202514:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202516:	078a                	slli	a5,a5,0x2
ffffffffc0202518:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020251a:	000d0717          	auipc	a4,0xd0
ffffffffc020251e:	28673703          	ld	a4,646(a4) # ffffffffc02d27a0 <npage>
ffffffffc0202522:	06e7f363          	bgeu	a5,a4,ffffffffc0202588 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0202526:	fff80537          	lui	a0,0xfff80
ffffffffc020252a:	97aa                	add	a5,a5,a0
ffffffffc020252c:	079a                	slli	a5,a5,0x6
ffffffffc020252e:	000d0517          	auipc	a0,0xd0
ffffffffc0202532:	27a53503          	ld	a0,634(a0) # ffffffffc02d27a8 <pages>
ffffffffc0202536:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202538:	411c                	lw	a5,0(a0)
ffffffffc020253a:	fff7871b          	addiw	a4,a5,-1
ffffffffc020253e:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202540:	cb11                	beqz	a4,ffffffffc0202554 <page_remove+0x64>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc0202542:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202546:	12048073          	sfence.vma	s1
}
ffffffffc020254a:	70a2                	ld	ra,40(sp)
ffffffffc020254c:	7402                	ld	s0,32(sp)
ffffffffc020254e:	64e2                	ld	s1,24(sp)
ffffffffc0202550:	6145                	addi	sp,sp,48
ffffffffc0202552:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202554:	100027f3          	csrr	a5,sstatus
ffffffffc0202558:	8b89                	andi	a5,a5,2
ffffffffc020255a:	eb89                	bnez	a5,ffffffffc020256c <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc020255c:	000d0797          	auipc	a5,0xd0
ffffffffc0202560:	2547b783          	ld	a5,596(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0202564:	739c                	ld	a5,32(a5)
ffffffffc0202566:	4585                	li	a1,1
ffffffffc0202568:	9782                	jalr	a5
    if (flag)
ffffffffc020256a:	bfe1                	j	ffffffffc0202542 <page_remove+0x52>
        intr_disable();
ffffffffc020256c:	e42a                	sd	a0,8(sp)
ffffffffc020256e:	c40fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc0202572:	000d0797          	auipc	a5,0xd0
ffffffffc0202576:	23e7b783          	ld	a5,574(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc020257a:	739c                	ld	a5,32(a5)
ffffffffc020257c:	6522                	ld	a0,8(sp)
ffffffffc020257e:	4585                	li	a1,1
ffffffffc0202580:	9782                	jalr	a5
        intr_enable();
ffffffffc0202582:	c26fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202586:	bf75                	j	ffffffffc0202542 <page_remove+0x52>
ffffffffc0202588:	825ff0ef          	jal	ra,ffffffffc0201dac <pa2page.part.0>

ffffffffc020258c <page_insert>:
{
ffffffffc020258c:	7139                	addi	sp,sp,-64
ffffffffc020258e:	e852                	sd	s4,16(sp)
ffffffffc0202590:	8a32                	mv	s4,a2
ffffffffc0202592:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202594:	4605                	li	a2,1
{
ffffffffc0202596:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202598:	85d2                	mv	a1,s4
{
ffffffffc020259a:	f426                	sd	s1,40(sp)
ffffffffc020259c:	fc06                	sd	ra,56(sp)
ffffffffc020259e:	f04a                	sd	s2,32(sp)
ffffffffc02025a0:	ec4e                	sd	s3,24(sp)
ffffffffc02025a2:	e456                	sd	s5,8(sp)
ffffffffc02025a4:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02025a6:	8f7ff0ef          	jal	ra,ffffffffc0201e9c <get_pte>
    if (ptep == NULL)
ffffffffc02025aa:	c961                	beqz	a0,ffffffffc020267a <page_insert+0xee>
    page->ref += 1;
ffffffffc02025ac:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V)
ffffffffc02025ae:	611c                	ld	a5,0(a0)
ffffffffc02025b0:	89aa                	mv	s3,a0
ffffffffc02025b2:	0016871b          	addiw	a4,a3,1
ffffffffc02025b6:	c018                	sw	a4,0(s0)
ffffffffc02025b8:	0017f713          	andi	a4,a5,1
ffffffffc02025bc:	ef05                	bnez	a4,ffffffffc02025f4 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc02025be:	000d0717          	auipc	a4,0xd0
ffffffffc02025c2:	1ea73703          	ld	a4,490(a4) # ffffffffc02d27a8 <pages>
ffffffffc02025c6:	8c19                	sub	s0,s0,a4
ffffffffc02025c8:	000807b7          	lui	a5,0x80
ffffffffc02025cc:	8419                	srai	s0,s0,0x6
ffffffffc02025ce:	943e                	add	s0,s0,a5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02025d0:	042a                	slli	s0,s0,0xa
ffffffffc02025d2:	8cc1                	or	s1,s1,s0
ffffffffc02025d4:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02025d8:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_matrix_out_size+0xffffffffbfff38d8>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025dc:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc02025e0:	4501                	li	a0,0
}
ffffffffc02025e2:	70e2                	ld	ra,56(sp)
ffffffffc02025e4:	7442                	ld	s0,48(sp)
ffffffffc02025e6:	74a2                	ld	s1,40(sp)
ffffffffc02025e8:	7902                	ld	s2,32(sp)
ffffffffc02025ea:	69e2                	ld	s3,24(sp)
ffffffffc02025ec:	6a42                	ld	s4,16(sp)
ffffffffc02025ee:	6aa2                	ld	s5,8(sp)
ffffffffc02025f0:	6121                	addi	sp,sp,64
ffffffffc02025f2:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02025f4:	078a                	slli	a5,a5,0x2
ffffffffc02025f6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02025f8:	000d0717          	auipc	a4,0xd0
ffffffffc02025fc:	1a873703          	ld	a4,424(a4) # ffffffffc02d27a0 <npage>
ffffffffc0202600:	06e7ff63          	bgeu	a5,a4,ffffffffc020267e <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0202604:	000d0a97          	auipc	s5,0xd0
ffffffffc0202608:	1a4a8a93          	addi	s5,s5,420 # ffffffffc02d27a8 <pages>
ffffffffc020260c:	000ab703          	ld	a4,0(s5)
ffffffffc0202610:	fff80937          	lui	s2,0xfff80
ffffffffc0202614:	993e                	add	s2,s2,a5
ffffffffc0202616:	091a                	slli	s2,s2,0x6
ffffffffc0202618:	993a                	add	s2,s2,a4
        if (p == page)
ffffffffc020261a:	01240c63          	beq	s0,s2,ffffffffc0202632 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc020261e:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fcad810>
ffffffffc0202622:	fff7869b          	addiw	a3,a5,-1
ffffffffc0202626:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc020262a:	c691                	beqz	a3,ffffffffc0202636 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020262c:	120a0073          	sfence.vma	s4
}
ffffffffc0202630:	bf59                	j	ffffffffc02025c6 <page_insert+0x3a>
ffffffffc0202632:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202634:	bf49                	j	ffffffffc02025c6 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202636:	100027f3          	csrr	a5,sstatus
ffffffffc020263a:	8b89                	andi	a5,a5,2
ffffffffc020263c:	ef91                	bnez	a5,ffffffffc0202658 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc020263e:	000d0797          	auipc	a5,0xd0
ffffffffc0202642:	1727b783          	ld	a5,370(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0202646:	739c                	ld	a5,32(a5)
ffffffffc0202648:	4585                	li	a1,1
ffffffffc020264a:	854a                	mv	a0,s2
ffffffffc020264c:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc020264e:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202652:	120a0073          	sfence.vma	s4
ffffffffc0202656:	bf85                	j	ffffffffc02025c6 <page_insert+0x3a>
        intr_disable();
ffffffffc0202658:	b56fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020265c:	000d0797          	auipc	a5,0xd0
ffffffffc0202660:	1547b783          	ld	a5,340(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0202664:	739c                	ld	a5,32(a5)
ffffffffc0202666:	4585                	li	a1,1
ffffffffc0202668:	854a                	mv	a0,s2
ffffffffc020266a:	9782                	jalr	a5
        intr_enable();
ffffffffc020266c:	b3cfe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202670:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202674:	120a0073          	sfence.vma	s4
ffffffffc0202678:	b7b9                	j	ffffffffc02025c6 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc020267a:	5571                	li	a0,-4
ffffffffc020267c:	b79d                	j	ffffffffc02025e2 <page_insert+0x56>
ffffffffc020267e:	f2eff0ef          	jal	ra,ffffffffc0201dac <pa2page.part.0>

ffffffffc0202682 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202682:	00004797          	auipc	a5,0x4
ffffffffc0202686:	45678793          	addi	a5,a5,1110 # ffffffffc0206ad8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020268a:	638c                	ld	a1,0(a5)
{
ffffffffc020268c:	7159                	addi	sp,sp,-112
ffffffffc020268e:	f85a                	sd	s6,48(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202690:	00004517          	auipc	a0,0x4
ffffffffc0202694:	5f050513          	addi	a0,a0,1520 # ffffffffc0206c80 <default_pmm_manager+0x1a8>
    pmm_manager = &default_pmm_manager;
ffffffffc0202698:	000d0b17          	auipc	s6,0xd0
ffffffffc020269c:	118b0b13          	addi	s6,s6,280 # ffffffffc02d27b0 <pmm_manager>
{
ffffffffc02026a0:	f486                	sd	ra,104(sp)
ffffffffc02026a2:	e8ca                	sd	s2,80(sp)
ffffffffc02026a4:	e4ce                	sd	s3,72(sp)
ffffffffc02026a6:	f0a2                	sd	s0,96(sp)
ffffffffc02026a8:	eca6                	sd	s1,88(sp)
ffffffffc02026aa:	e0d2                	sd	s4,64(sp)
ffffffffc02026ac:	fc56                	sd	s5,56(sp)
ffffffffc02026ae:	f45e                	sd	s7,40(sp)
ffffffffc02026b0:	f062                	sd	s8,32(sp)
ffffffffc02026b2:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02026b4:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02026b8:	ae1fd0ef          	jal	ra,ffffffffc0200198 <cprintf>
    pmm_manager->init();
ffffffffc02026bc:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02026c0:	000d0997          	auipc	s3,0xd0
ffffffffc02026c4:	0f898993          	addi	s3,s3,248 # ffffffffc02d27b8 <va_pa_offset>
    pmm_manager->init();
ffffffffc02026c8:	679c                	ld	a5,8(a5)
ffffffffc02026ca:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02026cc:	57f5                	li	a5,-3
ffffffffc02026ce:	07fa                	slli	a5,a5,0x1e
ffffffffc02026d0:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc02026d4:	ac0fe0ef          	jal	ra,ffffffffc0200994 <get_memory_base>
ffffffffc02026d8:	892a                	mv	s2,a0
    uint64_t mem_size = get_memory_size();
ffffffffc02026da:	ac4fe0ef          	jal	ra,ffffffffc020099e <get_memory_size>
    if (mem_size == 0)
ffffffffc02026de:	200505e3          	beqz	a0,ffffffffc02030e8 <pmm_init+0xa66>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc02026e2:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc02026e4:	00004517          	auipc	a0,0x4
ffffffffc02026e8:	5d450513          	addi	a0,a0,1492 # ffffffffc0206cb8 <default_pmm_manager+0x1e0>
ffffffffc02026ec:	aadfd0ef          	jal	ra,ffffffffc0200198 <cprintf>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc02026f0:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02026f4:	fff40693          	addi	a3,s0,-1
ffffffffc02026f8:	864a                	mv	a2,s2
ffffffffc02026fa:	85a6                	mv	a1,s1
ffffffffc02026fc:	00004517          	auipc	a0,0x4
ffffffffc0202700:	5d450513          	addi	a0,a0,1492 # ffffffffc0206cd0 <default_pmm_manager+0x1f8>
ffffffffc0202704:	a95fd0ef          	jal	ra,ffffffffc0200198 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0202708:	c8000737          	lui	a4,0xc8000
ffffffffc020270c:	87a2                	mv	a5,s0
ffffffffc020270e:	54876163          	bltu	a4,s0,ffffffffc0202c50 <pmm_init+0x5ce>
ffffffffc0202712:	757d                	lui	a0,0xfffff
ffffffffc0202714:	000d1617          	auipc	a2,0xd1
ffffffffc0202718:	0db60613          	addi	a2,a2,219 # ffffffffc02d37ef <end+0xfff>
ffffffffc020271c:	8e69                	and	a2,a2,a0
ffffffffc020271e:	000d0497          	auipc	s1,0xd0
ffffffffc0202722:	08248493          	addi	s1,s1,130 # ffffffffc02d27a0 <npage>
ffffffffc0202726:	00c7d513          	srli	a0,a5,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020272a:	000d0b97          	auipc	s7,0xd0
ffffffffc020272e:	07eb8b93          	addi	s7,s7,126 # ffffffffc02d27a8 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0202732:	e088                	sd	a0,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202734:	00cbb023          	sd	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202738:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020273c:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc020273e:	02f50863          	beq	a0,a5,ffffffffc020276e <pmm_init+0xec>
ffffffffc0202742:	4781                	li	a5,0
ffffffffc0202744:	4585                	li	a1,1
ffffffffc0202746:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc020274a:	00679513          	slli	a0,a5,0x6
ffffffffc020274e:	9532                	add	a0,a0,a2
ffffffffc0202750:	00850713          	addi	a4,a0,8 # fffffffffffff008 <end+0x3fd2c818>
ffffffffc0202754:	40b7302f          	amoor.d	zero,a1,(a4)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202758:	6088                	ld	a0,0(s1)
ffffffffc020275a:	0785                	addi	a5,a5,1
        SetPageReserved(pages + i);
ffffffffc020275c:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202760:	00d50733          	add	a4,a0,a3
ffffffffc0202764:	fee7e3e3          	bltu	a5,a4,ffffffffc020274a <pmm_init+0xc8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202768:	071a                	slli	a4,a4,0x6
ffffffffc020276a:	00e606b3          	add	a3,a2,a4
ffffffffc020276e:	c02007b7          	lui	a5,0xc0200
ffffffffc0202772:	2ef6ece3          	bltu	a3,a5,ffffffffc020326a <pmm_init+0xbe8>
ffffffffc0202776:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc020277a:	77fd                	lui	a5,0xfffff
ffffffffc020277c:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020277e:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc0202780:	5086eb63          	bltu	a3,s0,ffffffffc0202c96 <pmm_init+0x614>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202784:	00004517          	auipc	a0,0x4
ffffffffc0202788:	57450513          	addi	a0,a0,1396 # ffffffffc0206cf8 <default_pmm_manager+0x220>
ffffffffc020278c:	a0dfd0ef          	jal	ra,ffffffffc0200198 <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc0202790:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0202794:	000d0917          	auipc	s2,0xd0
ffffffffc0202798:	00490913          	addi	s2,s2,4 # ffffffffc02d2798 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc020279c:	7b9c                	ld	a5,48(a5)
ffffffffc020279e:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02027a0:	00004517          	auipc	a0,0x4
ffffffffc02027a4:	57050513          	addi	a0,a0,1392 # ffffffffc0206d10 <default_pmm_manager+0x238>
ffffffffc02027a8:	9f1fd0ef          	jal	ra,ffffffffc0200198 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc02027ac:	00009697          	auipc	a3,0x9
ffffffffc02027b0:	85468693          	addi	a3,a3,-1964 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc02027b4:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc02027b8:	c02007b7          	lui	a5,0xc0200
ffffffffc02027bc:	28f6ebe3          	bltu	a3,a5,ffffffffc0203252 <pmm_init+0xbd0>
ffffffffc02027c0:	0009b783          	ld	a5,0(s3)
ffffffffc02027c4:	8e9d                	sub	a3,a3,a5
ffffffffc02027c6:	000d0797          	auipc	a5,0xd0
ffffffffc02027ca:	fcd7b523          	sd	a3,-54(a5) # ffffffffc02d2790 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02027ce:	100027f3          	csrr	a5,sstatus
ffffffffc02027d2:	8b89                	andi	a5,a5,2
ffffffffc02027d4:	4a079763          	bnez	a5,ffffffffc0202c82 <pmm_init+0x600>
        ret = pmm_manager->nr_free_pages();
ffffffffc02027d8:	000b3783          	ld	a5,0(s6)
ffffffffc02027dc:	779c                	ld	a5,40(a5)
ffffffffc02027de:	9782                	jalr	a5
ffffffffc02027e0:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02027e2:	6098                	ld	a4,0(s1)
ffffffffc02027e4:	c80007b7          	lui	a5,0xc8000
ffffffffc02027e8:	83b1                	srli	a5,a5,0xc
ffffffffc02027ea:	66e7e363          	bltu	a5,a4,ffffffffc0202e50 <pmm_init+0x7ce>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc02027ee:	00093503          	ld	a0,0(s2)
ffffffffc02027f2:	62050f63          	beqz	a0,ffffffffc0202e30 <pmm_init+0x7ae>
ffffffffc02027f6:	03451793          	slli	a5,a0,0x34
ffffffffc02027fa:	62079b63          	bnez	a5,ffffffffc0202e30 <pmm_init+0x7ae>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc02027fe:	4601                	li	a2,0
ffffffffc0202800:	4581                	li	a1,0
ffffffffc0202802:	8c3ff0ef          	jal	ra,ffffffffc02020c4 <get_page>
ffffffffc0202806:	60051563          	bnez	a0,ffffffffc0202e10 <pmm_init+0x78e>
ffffffffc020280a:	100027f3          	csrr	a5,sstatus
ffffffffc020280e:	8b89                	andi	a5,a5,2
ffffffffc0202810:	44079e63          	bnez	a5,ffffffffc0202c6c <pmm_init+0x5ea>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202814:	000b3783          	ld	a5,0(s6)
ffffffffc0202818:	4505                	li	a0,1
ffffffffc020281a:	6f9c                	ld	a5,24(a5)
ffffffffc020281c:	9782                	jalr	a5
ffffffffc020281e:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0202820:	00093503          	ld	a0,0(s2)
ffffffffc0202824:	4681                	li	a3,0
ffffffffc0202826:	4601                	li	a2,0
ffffffffc0202828:	85d2                	mv	a1,s4
ffffffffc020282a:	d63ff0ef          	jal	ra,ffffffffc020258c <page_insert>
ffffffffc020282e:	26051ae3          	bnez	a0,ffffffffc02032a2 <pmm_init+0xc20>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0202832:	00093503          	ld	a0,0(s2)
ffffffffc0202836:	4601                	li	a2,0
ffffffffc0202838:	4581                	li	a1,0
ffffffffc020283a:	e62ff0ef          	jal	ra,ffffffffc0201e9c <get_pte>
ffffffffc020283e:	240502e3          	beqz	a0,ffffffffc0203282 <pmm_init+0xc00>
    assert(pte2page(*ptep) == p1);
ffffffffc0202842:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202844:	0017f713          	andi	a4,a5,1
ffffffffc0202848:	5a070263          	beqz	a4,ffffffffc0202dec <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc020284c:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020284e:	078a                	slli	a5,a5,0x2
ffffffffc0202850:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202852:	58e7fb63          	bgeu	a5,a4,ffffffffc0202de8 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202856:	000bb683          	ld	a3,0(s7)
ffffffffc020285a:	fff80637          	lui	a2,0xfff80
ffffffffc020285e:	97b2                	add	a5,a5,a2
ffffffffc0202860:	079a                	slli	a5,a5,0x6
ffffffffc0202862:	97b6                	add	a5,a5,a3
ffffffffc0202864:	14fa17e3          	bne	s4,a5,ffffffffc02031b2 <pmm_init+0xb30>
    assert(page_ref(p1) == 1);
ffffffffc0202868:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8f50>
ffffffffc020286c:	4785                	li	a5,1
ffffffffc020286e:	12f692e3          	bne	a3,a5,ffffffffc0203192 <pmm_init+0xb10>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0202872:	00093503          	ld	a0,0(s2)
ffffffffc0202876:	77fd                	lui	a5,0xfffff
ffffffffc0202878:	6114                	ld	a3,0(a0)
ffffffffc020287a:	068a                	slli	a3,a3,0x2
ffffffffc020287c:	8efd                	and	a3,a3,a5
ffffffffc020287e:	00c6d613          	srli	a2,a3,0xc
ffffffffc0202882:	0ee67ce3          	bgeu	a2,a4,ffffffffc020317a <pmm_init+0xaf8>
ffffffffc0202886:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020288a:	96e2                	add	a3,a3,s8
ffffffffc020288c:	0006ba83          	ld	s5,0(a3)
ffffffffc0202890:	0a8a                	slli	s5,s5,0x2
ffffffffc0202892:	00fafab3          	and	s5,s5,a5
ffffffffc0202896:	00cad793          	srli	a5,s5,0xc
ffffffffc020289a:	0ce7f3e3          	bgeu	a5,a4,ffffffffc0203160 <pmm_init+0xade>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc020289e:	4601                	li	a2,0
ffffffffc02028a0:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02028a2:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02028a4:	df8ff0ef          	jal	ra,ffffffffc0201e9c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02028a8:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02028aa:	55551363          	bne	a0,s5,ffffffffc0202df0 <pmm_init+0x76e>
ffffffffc02028ae:	100027f3          	csrr	a5,sstatus
ffffffffc02028b2:	8b89                	andi	a5,a5,2
ffffffffc02028b4:	3a079163          	bnez	a5,ffffffffc0202c56 <pmm_init+0x5d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc02028b8:	000b3783          	ld	a5,0(s6)
ffffffffc02028bc:	4505                	li	a0,1
ffffffffc02028be:	6f9c                	ld	a5,24(a5)
ffffffffc02028c0:	9782                	jalr	a5
ffffffffc02028c2:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02028c4:	00093503          	ld	a0,0(s2)
ffffffffc02028c8:	46d1                	li	a3,20
ffffffffc02028ca:	6605                	lui	a2,0x1
ffffffffc02028cc:	85e2                	mv	a1,s8
ffffffffc02028ce:	cbfff0ef          	jal	ra,ffffffffc020258c <page_insert>
ffffffffc02028d2:	060517e3          	bnez	a0,ffffffffc0203140 <pmm_init+0xabe>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02028d6:	00093503          	ld	a0,0(s2)
ffffffffc02028da:	4601                	li	a2,0
ffffffffc02028dc:	6585                	lui	a1,0x1
ffffffffc02028de:	dbeff0ef          	jal	ra,ffffffffc0201e9c <get_pte>
ffffffffc02028e2:	02050fe3          	beqz	a0,ffffffffc0203120 <pmm_init+0xa9e>
    assert(*ptep & PTE_U);
ffffffffc02028e6:	611c                	ld	a5,0(a0)
ffffffffc02028e8:	0107f713          	andi	a4,a5,16
ffffffffc02028ec:	7c070e63          	beqz	a4,ffffffffc02030c8 <pmm_init+0xa46>
    assert(*ptep & PTE_W);
ffffffffc02028f0:	8b91                	andi	a5,a5,4
ffffffffc02028f2:	7a078b63          	beqz	a5,ffffffffc02030a8 <pmm_init+0xa26>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc02028f6:	00093503          	ld	a0,0(s2)
ffffffffc02028fa:	611c                	ld	a5,0(a0)
ffffffffc02028fc:	8bc1                	andi	a5,a5,16
ffffffffc02028fe:	78078563          	beqz	a5,ffffffffc0203088 <pmm_init+0xa06>
    assert(page_ref(p2) == 1);
ffffffffc0202902:	000c2703          	lw	a4,0(s8)
ffffffffc0202906:	4785                	li	a5,1
ffffffffc0202908:	76f71063          	bne	a4,a5,ffffffffc0203068 <pmm_init+0x9e6>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc020290c:	4681                	li	a3,0
ffffffffc020290e:	6605                	lui	a2,0x1
ffffffffc0202910:	85d2                	mv	a1,s4
ffffffffc0202912:	c7bff0ef          	jal	ra,ffffffffc020258c <page_insert>
ffffffffc0202916:	72051963          	bnez	a0,ffffffffc0203048 <pmm_init+0x9c6>
    assert(page_ref(p1) == 2);
ffffffffc020291a:	000a2703          	lw	a4,0(s4)
ffffffffc020291e:	4789                	li	a5,2
ffffffffc0202920:	70f71463          	bne	a4,a5,ffffffffc0203028 <pmm_init+0x9a6>
    assert(page_ref(p2) == 0);
ffffffffc0202924:	000c2783          	lw	a5,0(s8)
ffffffffc0202928:	6e079063          	bnez	a5,ffffffffc0203008 <pmm_init+0x986>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc020292c:	00093503          	ld	a0,0(s2)
ffffffffc0202930:	4601                	li	a2,0
ffffffffc0202932:	6585                	lui	a1,0x1
ffffffffc0202934:	d68ff0ef          	jal	ra,ffffffffc0201e9c <get_pte>
ffffffffc0202938:	6a050863          	beqz	a0,ffffffffc0202fe8 <pmm_init+0x966>
    assert(pte2page(*ptep) == p1);
ffffffffc020293c:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc020293e:	00177793          	andi	a5,a4,1
ffffffffc0202942:	4a078563          	beqz	a5,ffffffffc0202dec <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc0202946:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202948:	00271793          	slli	a5,a4,0x2
ffffffffc020294c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020294e:	48d7fd63          	bgeu	a5,a3,ffffffffc0202de8 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202952:	000bb683          	ld	a3,0(s7)
ffffffffc0202956:	fff80ab7          	lui	s5,0xfff80
ffffffffc020295a:	97d6                	add	a5,a5,s5
ffffffffc020295c:	079a                	slli	a5,a5,0x6
ffffffffc020295e:	97b6                	add	a5,a5,a3
ffffffffc0202960:	66fa1463          	bne	s4,a5,ffffffffc0202fc8 <pmm_init+0x946>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202964:	8b41                	andi	a4,a4,16
ffffffffc0202966:	64071163          	bnez	a4,ffffffffc0202fa8 <pmm_init+0x926>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc020296a:	00093503          	ld	a0,0(s2)
ffffffffc020296e:	4581                	li	a1,0
ffffffffc0202970:	b81ff0ef          	jal	ra,ffffffffc02024f0 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202974:	000a2c83          	lw	s9,0(s4)
ffffffffc0202978:	4785                	li	a5,1
ffffffffc020297a:	60fc9763          	bne	s9,a5,ffffffffc0202f88 <pmm_init+0x906>
    assert(page_ref(p2) == 0);
ffffffffc020297e:	000c2783          	lw	a5,0(s8)
ffffffffc0202982:	5e079363          	bnez	a5,ffffffffc0202f68 <pmm_init+0x8e6>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc0202986:	00093503          	ld	a0,0(s2)
ffffffffc020298a:	6585                	lui	a1,0x1
ffffffffc020298c:	b65ff0ef          	jal	ra,ffffffffc02024f0 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202990:	000a2783          	lw	a5,0(s4)
ffffffffc0202994:	52079a63          	bnez	a5,ffffffffc0202ec8 <pmm_init+0x846>
    assert(page_ref(p2) == 0);
ffffffffc0202998:	000c2783          	lw	a5,0(s8)
ffffffffc020299c:	50079663          	bnez	a5,ffffffffc0202ea8 <pmm_init+0x826>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc02029a0:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc02029a4:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02029a6:	000a3683          	ld	a3,0(s4)
ffffffffc02029aa:	068a                	slli	a3,a3,0x2
ffffffffc02029ac:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc02029ae:	42b6fd63          	bgeu	a3,a1,ffffffffc0202de8 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02029b2:	000bb503          	ld	a0,0(s7)
ffffffffc02029b6:	96d6                	add	a3,a3,s5
ffffffffc02029b8:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc02029ba:	00d507b3          	add	a5,a0,a3
ffffffffc02029be:	439c                	lw	a5,0(a5)
ffffffffc02029c0:	4d979463          	bne	a5,s9,ffffffffc0202e88 <pmm_init+0x806>
    return page - pages + nbase;
ffffffffc02029c4:	8699                	srai	a3,a3,0x6
ffffffffc02029c6:	00080637          	lui	a2,0x80
ffffffffc02029ca:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc02029cc:	00c69713          	slli	a4,a3,0xc
ffffffffc02029d0:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02029d2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02029d4:	48b77e63          	bgeu	a4,a1,ffffffffc0202e70 <pmm_init+0x7ee>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02029d8:	0009b703          	ld	a4,0(s3)
ffffffffc02029dc:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc02029de:	629c                	ld	a5,0(a3)
ffffffffc02029e0:	078a                	slli	a5,a5,0x2
ffffffffc02029e2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02029e4:	40b7f263          	bgeu	a5,a1,ffffffffc0202de8 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02029e8:	8f91                	sub	a5,a5,a2
ffffffffc02029ea:	079a                	slli	a5,a5,0x6
ffffffffc02029ec:	953e                	add	a0,a0,a5
ffffffffc02029ee:	100027f3          	csrr	a5,sstatus
ffffffffc02029f2:	8b89                	andi	a5,a5,2
ffffffffc02029f4:	30079963          	bnez	a5,ffffffffc0202d06 <pmm_init+0x684>
        pmm_manager->free_pages(base, n);
ffffffffc02029f8:	000b3783          	ld	a5,0(s6)
ffffffffc02029fc:	4585                	li	a1,1
ffffffffc02029fe:	739c                	ld	a5,32(a5)
ffffffffc0202a00:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a02:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202a06:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a08:	078a                	slli	a5,a5,0x2
ffffffffc0202a0a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202a0c:	3ce7fe63          	bgeu	a5,a4,ffffffffc0202de8 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a10:	000bb503          	ld	a0,0(s7)
ffffffffc0202a14:	fff80737          	lui	a4,0xfff80
ffffffffc0202a18:	97ba                	add	a5,a5,a4
ffffffffc0202a1a:	079a                	slli	a5,a5,0x6
ffffffffc0202a1c:	953e                	add	a0,a0,a5
ffffffffc0202a1e:	100027f3          	csrr	a5,sstatus
ffffffffc0202a22:	8b89                	andi	a5,a5,2
ffffffffc0202a24:	2c079563          	bnez	a5,ffffffffc0202cee <pmm_init+0x66c>
ffffffffc0202a28:	000b3783          	ld	a5,0(s6)
ffffffffc0202a2c:	4585                	li	a1,1
ffffffffc0202a2e:	739c                	ld	a5,32(a5)
ffffffffc0202a30:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202a32:	00093783          	ld	a5,0(s2)
ffffffffc0202a36:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd2c810>
    asm volatile("sfence.vma");
ffffffffc0202a3a:	12000073          	sfence.vma
ffffffffc0202a3e:	100027f3          	csrr	a5,sstatus
ffffffffc0202a42:	8b89                	andi	a5,a5,2
ffffffffc0202a44:	28079b63          	bnez	a5,ffffffffc0202cda <pmm_init+0x658>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202a48:	000b3783          	ld	a5,0(s6)
ffffffffc0202a4c:	779c                	ld	a5,40(a5)
ffffffffc0202a4e:	9782                	jalr	a5
ffffffffc0202a50:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202a52:	4b441b63          	bne	s0,s4,ffffffffc0202f08 <pmm_init+0x886>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202a56:	00004517          	auipc	a0,0x4
ffffffffc0202a5a:	5e250513          	addi	a0,a0,1506 # ffffffffc0207038 <default_pmm_manager+0x560>
ffffffffc0202a5e:	f3afd0ef          	jal	ra,ffffffffc0200198 <cprintf>
ffffffffc0202a62:	100027f3          	csrr	a5,sstatus
ffffffffc0202a66:	8b89                	andi	a5,a5,2
ffffffffc0202a68:	24079f63          	bnez	a5,ffffffffc0202cc6 <pmm_init+0x644>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202a6c:	000b3783          	ld	a5,0(s6)
ffffffffc0202a70:	779c                	ld	a5,40(a5)
ffffffffc0202a72:	9782                	jalr	a5
ffffffffc0202a74:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202a76:	6098                	ld	a4,0(s1)
ffffffffc0202a78:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202a7c:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202a7e:	00c71793          	slli	a5,a4,0xc
ffffffffc0202a82:	6a05                	lui	s4,0x1
ffffffffc0202a84:	02f47c63          	bgeu	s0,a5,ffffffffc0202abc <pmm_init+0x43a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202a88:	00c45793          	srli	a5,s0,0xc
ffffffffc0202a8c:	00093503          	ld	a0,0(s2)
ffffffffc0202a90:	2ee7ff63          	bgeu	a5,a4,ffffffffc0202d8e <pmm_init+0x70c>
ffffffffc0202a94:	0009b583          	ld	a1,0(s3)
ffffffffc0202a98:	4601                	li	a2,0
ffffffffc0202a9a:	95a2                	add	a1,a1,s0
ffffffffc0202a9c:	c00ff0ef          	jal	ra,ffffffffc0201e9c <get_pte>
ffffffffc0202aa0:	32050463          	beqz	a0,ffffffffc0202dc8 <pmm_init+0x746>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202aa4:	611c                	ld	a5,0(a0)
ffffffffc0202aa6:	078a                	slli	a5,a5,0x2
ffffffffc0202aa8:	0157f7b3          	and	a5,a5,s5
ffffffffc0202aac:	2e879e63          	bne	a5,s0,ffffffffc0202da8 <pmm_init+0x726>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202ab0:	6098                	ld	a4,0(s1)
ffffffffc0202ab2:	9452                	add	s0,s0,s4
ffffffffc0202ab4:	00c71793          	slli	a5,a4,0xc
ffffffffc0202ab8:	fcf468e3          	bltu	s0,a5,ffffffffc0202a88 <pmm_init+0x406>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc0202abc:	00093783          	ld	a5,0(s2)
ffffffffc0202ac0:	639c                	ld	a5,0(a5)
ffffffffc0202ac2:	42079363          	bnez	a5,ffffffffc0202ee8 <pmm_init+0x866>
ffffffffc0202ac6:	100027f3          	csrr	a5,sstatus
ffffffffc0202aca:	8b89                	andi	a5,a5,2
ffffffffc0202acc:	24079963          	bnez	a5,ffffffffc0202d1e <pmm_init+0x69c>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202ad0:	000b3783          	ld	a5,0(s6)
ffffffffc0202ad4:	4505                	li	a0,1
ffffffffc0202ad6:	6f9c                	ld	a5,24(a5)
ffffffffc0202ad8:	9782                	jalr	a5
ffffffffc0202ada:	8a2a                	mv	s4,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202adc:	00093503          	ld	a0,0(s2)
ffffffffc0202ae0:	4699                	li	a3,6
ffffffffc0202ae2:	10000613          	li	a2,256
ffffffffc0202ae6:	85d2                	mv	a1,s4
ffffffffc0202ae8:	aa5ff0ef          	jal	ra,ffffffffc020258c <page_insert>
ffffffffc0202aec:	44051e63          	bnez	a0,ffffffffc0202f48 <pmm_init+0x8c6>
    assert(page_ref(p) == 1);
ffffffffc0202af0:	000a2703          	lw	a4,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8f50>
ffffffffc0202af4:	4785                	li	a5,1
ffffffffc0202af6:	42f71963          	bne	a4,a5,ffffffffc0202f28 <pmm_init+0x8a6>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202afa:	00093503          	ld	a0,0(s2)
ffffffffc0202afe:	6405                	lui	s0,0x1
ffffffffc0202b00:	4699                	li	a3,6
ffffffffc0202b02:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8e50>
ffffffffc0202b06:	85d2                	mv	a1,s4
ffffffffc0202b08:	a85ff0ef          	jal	ra,ffffffffc020258c <page_insert>
ffffffffc0202b0c:	72051363          	bnez	a0,ffffffffc0203232 <pmm_init+0xbb0>
    assert(page_ref(p) == 2);
ffffffffc0202b10:	000a2703          	lw	a4,0(s4)
ffffffffc0202b14:	4789                	li	a5,2
ffffffffc0202b16:	6ef71e63          	bne	a4,a5,ffffffffc0203212 <pmm_init+0xb90>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202b1a:	00004597          	auipc	a1,0x4
ffffffffc0202b1e:	66658593          	addi	a1,a1,1638 # ffffffffc0207180 <default_pmm_manager+0x6a8>
ffffffffc0202b22:	10000513          	li	a0,256
ffffffffc0202b26:	0dc030ef          	jal	ra,ffffffffc0205c02 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202b2a:	10040593          	addi	a1,s0,256
ffffffffc0202b2e:	10000513          	li	a0,256
ffffffffc0202b32:	0e2030ef          	jal	ra,ffffffffc0205c14 <strcmp>
ffffffffc0202b36:	6a051e63          	bnez	a0,ffffffffc02031f2 <pmm_init+0xb70>
    return page - pages + nbase;
ffffffffc0202b3a:	000bb683          	ld	a3,0(s7)
ffffffffc0202b3e:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202b42:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0202b44:	40da06b3          	sub	a3,s4,a3
ffffffffc0202b48:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202b4a:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202b4c:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202b4e:	8031                	srli	s0,s0,0xc
ffffffffc0202b50:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b54:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202b56:	30f77d63          	bgeu	a4,a5,ffffffffc0202e70 <pmm_init+0x7ee>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202b5a:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202b5e:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202b62:	96be                	add	a3,a3,a5
ffffffffc0202b64:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202b68:	064030ef          	jal	ra,ffffffffc0205bcc <strlen>
ffffffffc0202b6c:	66051363          	bnez	a0,ffffffffc02031d2 <pmm_init+0xb50>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0202b70:	00093a83          	ld	s5,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202b74:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b76:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fd2c810>
ffffffffc0202b7a:	068a                	slli	a3,a3,0x2
ffffffffc0202b7c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b7e:	26f6f563          	bgeu	a3,a5,ffffffffc0202de8 <pmm_init+0x766>
    return KADDR(page2pa(page));
ffffffffc0202b82:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b84:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202b86:	2ef47563          	bgeu	s0,a5,ffffffffc0202e70 <pmm_init+0x7ee>
ffffffffc0202b8a:	0009b403          	ld	s0,0(s3)
ffffffffc0202b8e:	9436                	add	s0,s0,a3
ffffffffc0202b90:	100027f3          	csrr	a5,sstatus
ffffffffc0202b94:	8b89                	andi	a5,a5,2
ffffffffc0202b96:	1e079163          	bnez	a5,ffffffffc0202d78 <pmm_init+0x6f6>
        pmm_manager->free_pages(base, n);
ffffffffc0202b9a:	000b3783          	ld	a5,0(s6)
ffffffffc0202b9e:	4585                	li	a1,1
ffffffffc0202ba0:	8552                	mv	a0,s4
ffffffffc0202ba2:	739c                	ld	a5,32(a5)
ffffffffc0202ba4:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ba6:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage)
ffffffffc0202ba8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202baa:	078a                	slli	a5,a5,0x2
ffffffffc0202bac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202bae:	22e7fd63          	bgeu	a5,a4,ffffffffc0202de8 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202bb2:	000bb503          	ld	a0,0(s7)
ffffffffc0202bb6:	fff80737          	lui	a4,0xfff80
ffffffffc0202bba:	97ba                	add	a5,a5,a4
ffffffffc0202bbc:	079a                	slli	a5,a5,0x6
ffffffffc0202bbe:	953e                	add	a0,a0,a5
ffffffffc0202bc0:	100027f3          	csrr	a5,sstatus
ffffffffc0202bc4:	8b89                	andi	a5,a5,2
ffffffffc0202bc6:	18079d63          	bnez	a5,ffffffffc0202d60 <pmm_init+0x6de>
ffffffffc0202bca:	000b3783          	ld	a5,0(s6)
ffffffffc0202bce:	4585                	li	a1,1
ffffffffc0202bd0:	739c                	ld	a5,32(a5)
ffffffffc0202bd2:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202bd4:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage)
ffffffffc0202bd8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202bda:	078a                	slli	a5,a5,0x2
ffffffffc0202bdc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202bde:	20e7f563          	bgeu	a5,a4,ffffffffc0202de8 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202be2:	000bb503          	ld	a0,0(s7)
ffffffffc0202be6:	fff80737          	lui	a4,0xfff80
ffffffffc0202bea:	97ba                	add	a5,a5,a4
ffffffffc0202bec:	079a                	slli	a5,a5,0x6
ffffffffc0202bee:	953e                	add	a0,a0,a5
ffffffffc0202bf0:	100027f3          	csrr	a5,sstatus
ffffffffc0202bf4:	8b89                	andi	a5,a5,2
ffffffffc0202bf6:	14079963          	bnez	a5,ffffffffc0202d48 <pmm_init+0x6c6>
ffffffffc0202bfa:	000b3783          	ld	a5,0(s6)
ffffffffc0202bfe:	4585                	li	a1,1
ffffffffc0202c00:	739c                	ld	a5,32(a5)
ffffffffc0202c02:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202c04:	00093783          	ld	a5,0(s2)
ffffffffc0202c08:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc0202c0c:	12000073          	sfence.vma
ffffffffc0202c10:	100027f3          	csrr	a5,sstatus
ffffffffc0202c14:	8b89                	andi	a5,a5,2
ffffffffc0202c16:	10079f63          	bnez	a5,ffffffffc0202d34 <pmm_init+0x6b2>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202c1a:	000b3783          	ld	a5,0(s6)
ffffffffc0202c1e:	779c                	ld	a5,40(a5)
ffffffffc0202c20:	9782                	jalr	a5
ffffffffc0202c22:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202c24:	4c8c1e63          	bne	s8,s0,ffffffffc0203100 <pmm_init+0xa7e>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202c28:	00004517          	auipc	a0,0x4
ffffffffc0202c2c:	5d050513          	addi	a0,a0,1488 # ffffffffc02071f8 <default_pmm_manager+0x720>
ffffffffc0202c30:	d68fd0ef          	jal	ra,ffffffffc0200198 <cprintf>
}
ffffffffc0202c34:	7406                	ld	s0,96(sp)
ffffffffc0202c36:	70a6                	ld	ra,104(sp)
ffffffffc0202c38:	64e6                	ld	s1,88(sp)
ffffffffc0202c3a:	6946                	ld	s2,80(sp)
ffffffffc0202c3c:	69a6                	ld	s3,72(sp)
ffffffffc0202c3e:	6a06                	ld	s4,64(sp)
ffffffffc0202c40:	7ae2                	ld	s5,56(sp)
ffffffffc0202c42:	7b42                	ld	s6,48(sp)
ffffffffc0202c44:	7ba2                	ld	s7,40(sp)
ffffffffc0202c46:	7c02                	ld	s8,32(sp)
ffffffffc0202c48:	6ce2                	ld	s9,24(sp)
ffffffffc0202c4a:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0202c4c:	f97fe06f          	j	ffffffffc0201be2 <kmalloc_init>
    npage = maxpa / PGSIZE;
ffffffffc0202c50:	c80007b7          	lui	a5,0xc8000
ffffffffc0202c54:	bc7d                	j	ffffffffc0202712 <pmm_init+0x90>
        intr_disable();
ffffffffc0202c56:	d59fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202c5a:	000b3783          	ld	a5,0(s6)
ffffffffc0202c5e:	4505                	li	a0,1
ffffffffc0202c60:	6f9c                	ld	a5,24(a5)
ffffffffc0202c62:	9782                	jalr	a5
ffffffffc0202c64:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202c66:	d43fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202c6a:	b9a9                	j	ffffffffc02028c4 <pmm_init+0x242>
        intr_disable();
ffffffffc0202c6c:	d43fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc0202c70:	000b3783          	ld	a5,0(s6)
ffffffffc0202c74:	4505                	li	a0,1
ffffffffc0202c76:	6f9c                	ld	a5,24(a5)
ffffffffc0202c78:	9782                	jalr	a5
ffffffffc0202c7a:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202c7c:	d2dfd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202c80:	b645                	j	ffffffffc0202820 <pmm_init+0x19e>
        intr_disable();
ffffffffc0202c82:	d2dfd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202c86:	000b3783          	ld	a5,0(s6)
ffffffffc0202c8a:	779c                	ld	a5,40(a5)
ffffffffc0202c8c:	9782                	jalr	a5
ffffffffc0202c8e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202c90:	d19fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202c94:	b6b9                	j	ffffffffc02027e2 <pmm_init+0x160>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202c96:	6705                	lui	a4,0x1
ffffffffc0202c98:	177d                	addi	a4,a4,-1
ffffffffc0202c9a:	96ba                	add	a3,a3,a4
ffffffffc0202c9c:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc0202c9e:	00c7d713          	srli	a4,a5,0xc
ffffffffc0202ca2:	14a77363          	bgeu	a4,a0,ffffffffc0202de8 <pmm_init+0x766>
    pmm_manager->init_memmap(base, n);
ffffffffc0202ca6:	000b3683          	ld	a3,0(s6)
    return &pages[PPN(pa) - nbase];
ffffffffc0202caa:	fff80537          	lui	a0,0xfff80
ffffffffc0202cae:	972a                	add	a4,a4,a0
ffffffffc0202cb0:	6a94                	ld	a3,16(a3)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202cb2:	8c1d                	sub	s0,s0,a5
ffffffffc0202cb4:	00671513          	slli	a0,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0202cb8:	00c45593          	srli	a1,s0,0xc
ffffffffc0202cbc:	9532                	add	a0,a0,a2
ffffffffc0202cbe:	9682                	jalr	a3
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202cc0:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202cc4:	b4c1                	j	ffffffffc0202784 <pmm_init+0x102>
        intr_disable();
ffffffffc0202cc6:	ce9fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202cca:	000b3783          	ld	a5,0(s6)
ffffffffc0202cce:	779c                	ld	a5,40(a5)
ffffffffc0202cd0:	9782                	jalr	a5
ffffffffc0202cd2:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202cd4:	cd5fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202cd8:	bb79                	j	ffffffffc0202a76 <pmm_init+0x3f4>
        intr_disable();
ffffffffc0202cda:	cd5fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc0202cde:	000b3783          	ld	a5,0(s6)
ffffffffc0202ce2:	779c                	ld	a5,40(a5)
ffffffffc0202ce4:	9782                	jalr	a5
ffffffffc0202ce6:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202ce8:	cc1fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202cec:	b39d                	j	ffffffffc0202a52 <pmm_init+0x3d0>
ffffffffc0202cee:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202cf0:	cbffd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202cf4:	000b3783          	ld	a5,0(s6)
ffffffffc0202cf8:	6522                	ld	a0,8(sp)
ffffffffc0202cfa:	4585                	li	a1,1
ffffffffc0202cfc:	739c                	ld	a5,32(a5)
ffffffffc0202cfe:	9782                	jalr	a5
        intr_enable();
ffffffffc0202d00:	ca9fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202d04:	b33d                	j	ffffffffc0202a32 <pmm_init+0x3b0>
ffffffffc0202d06:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202d08:	ca7fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc0202d0c:	000b3783          	ld	a5,0(s6)
ffffffffc0202d10:	6522                	ld	a0,8(sp)
ffffffffc0202d12:	4585                	li	a1,1
ffffffffc0202d14:	739c                	ld	a5,32(a5)
ffffffffc0202d16:	9782                	jalr	a5
        intr_enable();
ffffffffc0202d18:	c91fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202d1c:	b1dd                	j	ffffffffc0202a02 <pmm_init+0x380>
        intr_disable();
ffffffffc0202d1e:	c91fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202d22:	000b3783          	ld	a5,0(s6)
ffffffffc0202d26:	4505                	li	a0,1
ffffffffc0202d28:	6f9c                	ld	a5,24(a5)
ffffffffc0202d2a:	9782                	jalr	a5
ffffffffc0202d2c:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202d2e:	c7bfd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202d32:	b36d                	j	ffffffffc0202adc <pmm_init+0x45a>
        intr_disable();
ffffffffc0202d34:	c7bfd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202d38:	000b3783          	ld	a5,0(s6)
ffffffffc0202d3c:	779c                	ld	a5,40(a5)
ffffffffc0202d3e:	9782                	jalr	a5
ffffffffc0202d40:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202d42:	c67fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202d46:	bdf9                	j	ffffffffc0202c24 <pmm_init+0x5a2>
ffffffffc0202d48:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202d4a:	c65fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202d4e:	000b3783          	ld	a5,0(s6)
ffffffffc0202d52:	6522                	ld	a0,8(sp)
ffffffffc0202d54:	4585                	li	a1,1
ffffffffc0202d56:	739c                	ld	a5,32(a5)
ffffffffc0202d58:	9782                	jalr	a5
        intr_enable();
ffffffffc0202d5a:	c4ffd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202d5e:	b55d                	j	ffffffffc0202c04 <pmm_init+0x582>
ffffffffc0202d60:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202d62:	c4dfd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc0202d66:	000b3783          	ld	a5,0(s6)
ffffffffc0202d6a:	6522                	ld	a0,8(sp)
ffffffffc0202d6c:	4585                	li	a1,1
ffffffffc0202d6e:	739c                	ld	a5,32(a5)
ffffffffc0202d70:	9782                	jalr	a5
        intr_enable();
ffffffffc0202d72:	c37fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202d76:	bdb9                	j	ffffffffc0202bd4 <pmm_init+0x552>
        intr_disable();
ffffffffc0202d78:	c37fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc0202d7c:	000b3783          	ld	a5,0(s6)
ffffffffc0202d80:	4585                	li	a1,1
ffffffffc0202d82:	8552                	mv	a0,s4
ffffffffc0202d84:	739c                	ld	a5,32(a5)
ffffffffc0202d86:	9782                	jalr	a5
        intr_enable();
ffffffffc0202d88:	c21fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202d8c:	bd29                	j	ffffffffc0202ba6 <pmm_init+0x524>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202d8e:	86a2                	mv	a3,s0
ffffffffc0202d90:	00004617          	auipc	a2,0x4
ffffffffc0202d94:	d8060613          	addi	a2,a2,-640 # ffffffffc0206b10 <default_pmm_manager+0x38>
ffffffffc0202d98:	26500593          	li	a1,613
ffffffffc0202d9c:	00004517          	auipc	a0,0x4
ffffffffc0202da0:	e8c50513          	addi	a0,a0,-372 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0202da4:	eeefd0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202da8:	00004697          	auipc	a3,0x4
ffffffffc0202dac:	2f068693          	addi	a3,a3,752 # ffffffffc0207098 <default_pmm_manager+0x5c0>
ffffffffc0202db0:	00004617          	auipc	a2,0x4
ffffffffc0202db4:	97860613          	addi	a2,a2,-1672 # ffffffffc0206728 <commands+0x828>
ffffffffc0202db8:	26600593          	li	a1,614
ffffffffc0202dbc:	00004517          	auipc	a0,0x4
ffffffffc0202dc0:	e6c50513          	addi	a0,a0,-404 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0202dc4:	ecefd0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202dc8:	00004697          	auipc	a3,0x4
ffffffffc0202dcc:	29068693          	addi	a3,a3,656 # ffffffffc0207058 <default_pmm_manager+0x580>
ffffffffc0202dd0:	00004617          	auipc	a2,0x4
ffffffffc0202dd4:	95860613          	addi	a2,a2,-1704 # ffffffffc0206728 <commands+0x828>
ffffffffc0202dd8:	26500593          	li	a1,613
ffffffffc0202ddc:	00004517          	auipc	a0,0x4
ffffffffc0202de0:	e4c50513          	addi	a0,a0,-436 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0202de4:	eaefd0ef          	jal	ra,ffffffffc0200492 <__panic>
ffffffffc0202de8:	fc5fe0ef          	jal	ra,ffffffffc0201dac <pa2page.part.0>
ffffffffc0202dec:	fddfe0ef          	jal	ra,ffffffffc0201dc8 <pte2page.part.0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202df0:	00004697          	auipc	a3,0x4
ffffffffc0202df4:	06068693          	addi	a3,a3,96 # ffffffffc0206e50 <default_pmm_manager+0x378>
ffffffffc0202df8:	00004617          	auipc	a2,0x4
ffffffffc0202dfc:	93060613          	addi	a2,a2,-1744 # ffffffffc0206728 <commands+0x828>
ffffffffc0202e00:	23500593          	li	a1,565
ffffffffc0202e04:	00004517          	auipc	a0,0x4
ffffffffc0202e08:	e2450513          	addi	a0,a0,-476 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0202e0c:	e86fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0202e10:	00004697          	auipc	a3,0x4
ffffffffc0202e14:	f8068693          	addi	a3,a3,-128 # ffffffffc0206d90 <default_pmm_manager+0x2b8>
ffffffffc0202e18:	00004617          	auipc	a2,0x4
ffffffffc0202e1c:	91060613          	addi	a2,a2,-1776 # ffffffffc0206728 <commands+0x828>
ffffffffc0202e20:	22800593          	li	a1,552
ffffffffc0202e24:	00004517          	auipc	a0,0x4
ffffffffc0202e28:	e0450513          	addi	a0,a0,-508 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0202e2c:	e66fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202e30:	00004697          	auipc	a3,0x4
ffffffffc0202e34:	f2068693          	addi	a3,a3,-224 # ffffffffc0206d50 <default_pmm_manager+0x278>
ffffffffc0202e38:	00004617          	auipc	a2,0x4
ffffffffc0202e3c:	8f060613          	addi	a2,a2,-1808 # ffffffffc0206728 <commands+0x828>
ffffffffc0202e40:	22700593          	li	a1,551
ffffffffc0202e44:	00004517          	auipc	a0,0x4
ffffffffc0202e48:	de450513          	addi	a0,a0,-540 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0202e4c:	e46fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202e50:	00004697          	auipc	a3,0x4
ffffffffc0202e54:	ee068693          	addi	a3,a3,-288 # ffffffffc0206d30 <default_pmm_manager+0x258>
ffffffffc0202e58:	00004617          	auipc	a2,0x4
ffffffffc0202e5c:	8d060613          	addi	a2,a2,-1840 # ffffffffc0206728 <commands+0x828>
ffffffffc0202e60:	22600593          	li	a1,550
ffffffffc0202e64:	00004517          	auipc	a0,0x4
ffffffffc0202e68:	dc450513          	addi	a0,a0,-572 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0202e6c:	e26fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202e70:	00004617          	auipc	a2,0x4
ffffffffc0202e74:	ca060613          	addi	a2,a2,-864 # ffffffffc0206b10 <default_pmm_manager+0x38>
ffffffffc0202e78:	07100593          	li	a1,113
ffffffffc0202e7c:	00004517          	auipc	a0,0x4
ffffffffc0202e80:	cbc50513          	addi	a0,a0,-836 # ffffffffc0206b38 <default_pmm_manager+0x60>
ffffffffc0202e84:	e0efd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202e88:	00004697          	auipc	a3,0x4
ffffffffc0202e8c:	15868693          	addi	a3,a3,344 # ffffffffc0206fe0 <default_pmm_manager+0x508>
ffffffffc0202e90:	00004617          	auipc	a2,0x4
ffffffffc0202e94:	89860613          	addi	a2,a2,-1896 # ffffffffc0206728 <commands+0x828>
ffffffffc0202e98:	24e00593          	li	a1,590
ffffffffc0202e9c:	00004517          	auipc	a0,0x4
ffffffffc0202ea0:	d8c50513          	addi	a0,a0,-628 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0202ea4:	deefd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202ea8:	00004697          	auipc	a3,0x4
ffffffffc0202eac:	0f068693          	addi	a3,a3,240 # ffffffffc0206f98 <default_pmm_manager+0x4c0>
ffffffffc0202eb0:	00004617          	auipc	a2,0x4
ffffffffc0202eb4:	87860613          	addi	a2,a2,-1928 # ffffffffc0206728 <commands+0x828>
ffffffffc0202eb8:	24c00593          	li	a1,588
ffffffffc0202ebc:	00004517          	auipc	a0,0x4
ffffffffc0202ec0:	d6c50513          	addi	a0,a0,-660 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0202ec4:	dcefd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202ec8:	00004697          	auipc	a3,0x4
ffffffffc0202ecc:	10068693          	addi	a3,a3,256 # ffffffffc0206fc8 <default_pmm_manager+0x4f0>
ffffffffc0202ed0:	00004617          	auipc	a2,0x4
ffffffffc0202ed4:	85860613          	addi	a2,a2,-1960 # ffffffffc0206728 <commands+0x828>
ffffffffc0202ed8:	24b00593          	li	a1,587
ffffffffc0202edc:	00004517          	auipc	a0,0x4
ffffffffc0202ee0:	d4c50513          	addi	a0,a0,-692 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0202ee4:	daefd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc0202ee8:	00004697          	auipc	a3,0x4
ffffffffc0202eec:	1c868693          	addi	a3,a3,456 # ffffffffc02070b0 <default_pmm_manager+0x5d8>
ffffffffc0202ef0:	00004617          	auipc	a2,0x4
ffffffffc0202ef4:	83860613          	addi	a2,a2,-1992 # ffffffffc0206728 <commands+0x828>
ffffffffc0202ef8:	26900593          	li	a1,617
ffffffffc0202efc:	00004517          	auipc	a0,0x4
ffffffffc0202f00:	d2c50513          	addi	a0,a0,-724 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0202f04:	d8efd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0202f08:	00004697          	auipc	a3,0x4
ffffffffc0202f0c:	10868693          	addi	a3,a3,264 # ffffffffc0207010 <default_pmm_manager+0x538>
ffffffffc0202f10:	00004617          	auipc	a2,0x4
ffffffffc0202f14:	81860613          	addi	a2,a2,-2024 # ffffffffc0206728 <commands+0x828>
ffffffffc0202f18:	25600593          	li	a1,598
ffffffffc0202f1c:	00004517          	auipc	a0,0x4
ffffffffc0202f20:	d0c50513          	addi	a0,a0,-756 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0202f24:	d6efd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202f28:	00004697          	auipc	a3,0x4
ffffffffc0202f2c:	1e068693          	addi	a3,a3,480 # ffffffffc0207108 <default_pmm_manager+0x630>
ffffffffc0202f30:	00003617          	auipc	a2,0x3
ffffffffc0202f34:	7f860613          	addi	a2,a2,2040 # ffffffffc0206728 <commands+0x828>
ffffffffc0202f38:	26e00593          	li	a1,622
ffffffffc0202f3c:	00004517          	auipc	a0,0x4
ffffffffc0202f40:	cec50513          	addi	a0,a0,-788 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0202f44:	d4efd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202f48:	00004697          	auipc	a3,0x4
ffffffffc0202f4c:	18068693          	addi	a3,a3,384 # ffffffffc02070c8 <default_pmm_manager+0x5f0>
ffffffffc0202f50:	00003617          	auipc	a2,0x3
ffffffffc0202f54:	7d860613          	addi	a2,a2,2008 # ffffffffc0206728 <commands+0x828>
ffffffffc0202f58:	26d00593          	li	a1,621
ffffffffc0202f5c:	00004517          	auipc	a0,0x4
ffffffffc0202f60:	ccc50513          	addi	a0,a0,-820 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0202f64:	d2efd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f68:	00004697          	auipc	a3,0x4
ffffffffc0202f6c:	03068693          	addi	a3,a3,48 # ffffffffc0206f98 <default_pmm_manager+0x4c0>
ffffffffc0202f70:	00003617          	auipc	a2,0x3
ffffffffc0202f74:	7b860613          	addi	a2,a2,1976 # ffffffffc0206728 <commands+0x828>
ffffffffc0202f78:	24800593          	li	a1,584
ffffffffc0202f7c:	00004517          	auipc	a0,0x4
ffffffffc0202f80:	cac50513          	addi	a0,a0,-852 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0202f84:	d0efd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202f88:	00004697          	auipc	a3,0x4
ffffffffc0202f8c:	eb068693          	addi	a3,a3,-336 # ffffffffc0206e38 <default_pmm_manager+0x360>
ffffffffc0202f90:	00003617          	auipc	a2,0x3
ffffffffc0202f94:	79860613          	addi	a2,a2,1944 # ffffffffc0206728 <commands+0x828>
ffffffffc0202f98:	24700593          	li	a1,583
ffffffffc0202f9c:	00004517          	auipc	a0,0x4
ffffffffc0202fa0:	c8c50513          	addi	a0,a0,-884 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0202fa4:	ceefd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202fa8:	00004697          	auipc	a3,0x4
ffffffffc0202fac:	00868693          	addi	a3,a3,8 # ffffffffc0206fb0 <default_pmm_manager+0x4d8>
ffffffffc0202fb0:	00003617          	auipc	a2,0x3
ffffffffc0202fb4:	77860613          	addi	a2,a2,1912 # ffffffffc0206728 <commands+0x828>
ffffffffc0202fb8:	24400593          	li	a1,580
ffffffffc0202fbc:	00004517          	auipc	a0,0x4
ffffffffc0202fc0:	c6c50513          	addi	a0,a0,-916 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0202fc4:	ccefd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202fc8:	00004697          	auipc	a3,0x4
ffffffffc0202fcc:	e5868693          	addi	a3,a3,-424 # ffffffffc0206e20 <default_pmm_manager+0x348>
ffffffffc0202fd0:	00003617          	auipc	a2,0x3
ffffffffc0202fd4:	75860613          	addi	a2,a2,1880 # ffffffffc0206728 <commands+0x828>
ffffffffc0202fd8:	24300593          	li	a1,579
ffffffffc0202fdc:	00004517          	auipc	a0,0x4
ffffffffc0202fe0:	c4c50513          	addi	a0,a0,-948 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0202fe4:	caefd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202fe8:	00004697          	auipc	a3,0x4
ffffffffc0202fec:	ed868693          	addi	a3,a3,-296 # ffffffffc0206ec0 <default_pmm_manager+0x3e8>
ffffffffc0202ff0:	00003617          	auipc	a2,0x3
ffffffffc0202ff4:	73860613          	addi	a2,a2,1848 # ffffffffc0206728 <commands+0x828>
ffffffffc0202ff8:	24200593          	li	a1,578
ffffffffc0202ffc:	00004517          	auipc	a0,0x4
ffffffffc0203000:	c2c50513          	addi	a0,a0,-980 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0203004:	c8efd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203008:	00004697          	auipc	a3,0x4
ffffffffc020300c:	f9068693          	addi	a3,a3,-112 # ffffffffc0206f98 <default_pmm_manager+0x4c0>
ffffffffc0203010:	00003617          	auipc	a2,0x3
ffffffffc0203014:	71860613          	addi	a2,a2,1816 # ffffffffc0206728 <commands+0x828>
ffffffffc0203018:	24100593          	li	a1,577
ffffffffc020301c:	00004517          	auipc	a0,0x4
ffffffffc0203020:	c0c50513          	addi	a0,a0,-1012 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0203024:	c6efd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0203028:	00004697          	auipc	a3,0x4
ffffffffc020302c:	f5868693          	addi	a3,a3,-168 # ffffffffc0206f80 <default_pmm_manager+0x4a8>
ffffffffc0203030:	00003617          	auipc	a2,0x3
ffffffffc0203034:	6f860613          	addi	a2,a2,1784 # ffffffffc0206728 <commands+0x828>
ffffffffc0203038:	24000593          	li	a1,576
ffffffffc020303c:	00004517          	auipc	a0,0x4
ffffffffc0203040:	bec50513          	addi	a0,a0,-1044 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0203044:	c4efd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0203048:	00004697          	auipc	a3,0x4
ffffffffc020304c:	f0868693          	addi	a3,a3,-248 # ffffffffc0206f50 <default_pmm_manager+0x478>
ffffffffc0203050:	00003617          	auipc	a2,0x3
ffffffffc0203054:	6d860613          	addi	a2,a2,1752 # ffffffffc0206728 <commands+0x828>
ffffffffc0203058:	23f00593          	li	a1,575
ffffffffc020305c:	00004517          	auipc	a0,0x4
ffffffffc0203060:	bcc50513          	addi	a0,a0,-1076 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0203064:	c2efd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203068:	00004697          	auipc	a3,0x4
ffffffffc020306c:	ed068693          	addi	a3,a3,-304 # ffffffffc0206f38 <default_pmm_manager+0x460>
ffffffffc0203070:	00003617          	auipc	a2,0x3
ffffffffc0203074:	6b860613          	addi	a2,a2,1720 # ffffffffc0206728 <commands+0x828>
ffffffffc0203078:	23d00593          	li	a1,573
ffffffffc020307c:	00004517          	auipc	a0,0x4
ffffffffc0203080:	bac50513          	addi	a0,a0,-1108 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0203084:	c0efd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0203088:	00004697          	auipc	a3,0x4
ffffffffc020308c:	e9068693          	addi	a3,a3,-368 # ffffffffc0206f18 <default_pmm_manager+0x440>
ffffffffc0203090:	00003617          	auipc	a2,0x3
ffffffffc0203094:	69860613          	addi	a2,a2,1688 # ffffffffc0206728 <commands+0x828>
ffffffffc0203098:	23c00593          	li	a1,572
ffffffffc020309c:	00004517          	auipc	a0,0x4
ffffffffc02030a0:	b8c50513          	addi	a0,a0,-1140 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc02030a4:	beefd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02030a8:	00004697          	auipc	a3,0x4
ffffffffc02030ac:	e6068693          	addi	a3,a3,-416 # ffffffffc0206f08 <default_pmm_manager+0x430>
ffffffffc02030b0:	00003617          	auipc	a2,0x3
ffffffffc02030b4:	67860613          	addi	a2,a2,1656 # ffffffffc0206728 <commands+0x828>
ffffffffc02030b8:	23b00593          	li	a1,571
ffffffffc02030bc:	00004517          	auipc	a0,0x4
ffffffffc02030c0:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc02030c4:	bcefd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02030c8:	00004697          	auipc	a3,0x4
ffffffffc02030cc:	e3068693          	addi	a3,a3,-464 # ffffffffc0206ef8 <default_pmm_manager+0x420>
ffffffffc02030d0:	00003617          	auipc	a2,0x3
ffffffffc02030d4:	65860613          	addi	a2,a2,1624 # ffffffffc0206728 <commands+0x828>
ffffffffc02030d8:	23a00593          	li	a1,570
ffffffffc02030dc:	00004517          	auipc	a0,0x4
ffffffffc02030e0:	b4c50513          	addi	a0,a0,-1204 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc02030e4:	baefd0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("DTB memory info not available");
ffffffffc02030e8:	00004617          	auipc	a2,0x4
ffffffffc02030ec:	bb060613          	addi	a2,a2,-1104 # ffffffffc0206c98 <default_pmm_manager+0x1c0>
ffffffffc02030f0:	06500593          	li	a1,101
ffffffffc02030f4:	00004517          	auipc	a0,0x4
ffffffffc02030f8:	b3450513          	addi	a0,a0,-1228 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc02030fc:	b96fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0203100:	00004697          	auipc	a3,0x4
ffffffffc0203104:	f1068693          	addi	a3,a3,-240 # ffffffffc0207010 <default_pmm_manager+0x538>
ffffffffc0203108:	00003617          	auipc	a2,0x3
ffffffffc020310c:	62060613          	addi	a2,a2,1568 # ffffffffc0206728 <commands+0x828>
ffffffffc0203110:	28000593          	li	a1,640
ffffffffc0203114:	00004517          	auipc	a0,0x4
ffffffffc0203118:	b1450513          	addi	a0,a0,-1260 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc020311c:	b76fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0203120:	00004697          	auipc	a3,0x4
ffffffffc0203124:	da068693          	addi	a3,a3,-608 # ffffffffc0206ec0 <default_pmm_manager+0x3e8>
ffffffffc0203128:	00003617          	auipc	a2,0x3
ffffffffc020312c:	60060613          	addi	a2,a2,1536 # ffffffffc0206728 <commands+0x828>
ffffffffc0203130:	23900593          	li	a1,569
ffffffffc0203134:	00004517          	auipc	a0,0x4
ffffffffc0203138:	af450513          	addi	a0,a0,-1292 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc020313c:	b56fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203140:	00004697          	auipc	a3,0x4
ffffffffc0203144:	d4068693          	addi	a3,a3,-704 # ffffffffc0206e80 <default_pmm_manager+0x3a8>
ffffffffc0203148:	00003617          	auipc	a2,0x3
ffffffffc020314c:	5e060613          	addi	a2,a2,1504 # ffffffffc0206728 <commands+0x828>
ffffffffc0203150:	23800593          	li	a1,568
ffffffffc0203154:	00004517          	auipc	a0,0x4
ffffffffc0203158:	ad450513          	addi	a0,a0,-1324 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc020315c:	b36fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203160:	86d6                	mv	a3,s5
ffffffffc0203162:	00004617          	auipc	a2,0x4
ffffffffc0203166:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0206b10 <default_pmm_manager+0x38>
ffffffffc020316a:	23400593          	li	a1,564
ffffffffc020316e:	00004517          	auipc	a0,0x4
ffffffffc0203172:	aba50513          	addi	a0,a0,-1350 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0203176:	b1cfd0ef          	jal	ra,ffffffffc0200492 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc020317a:	00004617          	auipc	a2,0x4
ffffffffc020317e:	99660613          	addi	a2,a2,-1642 # ffffffffc0206b10 <default_pmm_manager+0x38>
ffffffffc0203182:	23300593          	li	a1,563
ffffffffc0203186:	00004517          	auipc	a0,0x4
ffffffffc020318a:	aa250513          	addi	a0,a0,-1374 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc020318e:	b04fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203192:	00004697          	auipc	a3,0x4
ffffffffc0203196:	ca668693          	addi	a3,a3,-858 # ffffffffc0206e38 <default_pmm_manager+0x360>
ffffffffc020319a:	00003617          	auipc	a2,0x3
ffffffffc020319e:	58e60613          	addi	a2,a2,1422 # ffffffffc0206728 <commands+0x828>
ffffffffc02031a2:	23100593          	li	a1,561
ffffffffc02031a6:	00004517          	auipc	a0,0x4
ffffffffc02031aa:	a8250513          	addi	a0,a0,-1406 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc02031ae:	ae4fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02031b2:	00004697          	auipc	a3,0x4
ffffffffc02031b6:	c6e68693          	addi	a3,a3,-914 # ffffffffc0206e20 <default_pmm_manager+0x348>
ffffffffc02031ba:	00003617          	auipc	a2,0x3
ffffffffc02031be:	56e60613          	addi	a2,a2,1390 # ffffffffc0206728 <commands+0x828>
ffffffffc02031c2:	23000593          	li	a1,560
ffffffffc02031c6:	00004517          	auipc	a0,0x4
ffffffffc02031ca:	a6250513          	addi	a0,a0,-1438 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc02031ce:	ac4fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02031d2:	00004697          	auipc	a3,0x4
ffffffffc02031d6:	ffe68693          	addi	a3,a3,-2 # ffffffffc02071d0 <default_pmm_manager+0x6f8>
ffffffffc02031da:	00003617          	auipc	a2,0x3
ffffffffc02031de:	54e60613          	addi	a2,a2,1358 # ffffffffc0206728 <commands+0x828>
ffffffffc02031e2:	27700593          	li	a1,631
ffffffffc02031e6:	00004517          	auipc	a0,0x4
ffffffffc02031ea:	a4250513          	addi	a0,a0,-1470 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc02031ee:	aa4fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02031f2:	00004697          	auipc	a3,0x4
ffffffffc02031f6:	fa668693          	addi	a3,a3,-90 # ffffffffc0207198 <default_pmm_manager+0x6c0>
ffffffffc02031fa:	00003617          	auipc	a2,0x3
ffffffffc02031fe:	52e60613          	addi	a2,a2,1326 # ffffffffc0206728 <commands+0x828>
ffffffffc0203202:	27400593          	li	a1,628
ffffffffc0203206:	00004517          	auipc	a0,0x4
ffffffffc020320a:	a2250513          	addi	a0,a0,-1502 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc020320e:	a84fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203212:	00004697          	auipc	a3,0x4
ffffffffc0203216:	f5668693          	addi	a3,a3,-170 # ffffffffc0207168 <default_pmm_manager+0x690>
ffffffffc020321a:	00003617          	auipc	a2,0x3
ffffffffc020321e:	50e60613          	addi	a2,a2,1294 # ffffffffc0206728 <commands+0x828>
ffffffffc0203222:	27000593          	li	a1,624
ffffffffc0203226:	00004517          	auipc	a0,0x4
ffffffffc020322a:	a0250513          	addi	a0,a0,-1534 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc020322e:	a64fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203232:	00004697          	auipc	a3,0x4
ffffffffc0203236:	eee68693          	addi	a3,a3,-274 # ffffffffc0207120 <default_pmm_manager+0x648>
ffffffffc020323a:	00003617          	auipc	a2,0x3
ffffffffc020323e:	4ee60613          	addi	a2,a2,1262 # ffffffffc0206728 <commands+0x828>
ffffffffc0203242:	26f00593          	li	a1,623
ffffffffc0203246:	00004517          	auipc	a0,0x4
ffffffffc020324a:	9e250513          	addi	a0,a0,-1566 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc020324e:	a44fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0203252:	00004617          	auipc	a2,0x4
ffffffffc0203256:	96660613          	addi	a2,a2,-1690 # ffffffffc0206bb8 <default_pmm_manager+0xe0>
ffffffffc020325a:	0c900593          	li	a1,201
ffffffffc020325e:	00004517          	auipc	a0,0x4
ffffffffc0203262:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0203266:	a2cfd0ef          	jal	ra,ffffffffc0200492 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020326a:	00004617          	auipc	a2,0x4
ffffffffc020326e:	94e60613          	addi	a2,a2,-1714 # ffffffffc0206bb8 <default_pmm_manager+0xe0>
ffffffffc0203272:	08100593          	li	a1,129
ffffffffc0203276:	00004517          	auipc	a0,0x4
ffffffffc020327a:	9b250513          	addi	a0,a0,-1614 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc020327e:	a14fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0203282:	00004697          	auipc	a3,0x4
ffffffffc0203286:	b6e68693          	addi	a3,a3,-1170 # ffffffffc0206df0 <default_pmm_manager+0x318>
ffffffffc020328a:	00003617          	auipc	a2,0x3
ffffffffc020328e:	49e60613          	addi	a2,a2,1182 # ffffffffc0206728 <commands+0x828>
ffffffffc0203292:	22f00593          	li	a1,559
ffffffffc0203296:	00004517          	auipc	a0,0x4
ffffffffc020329a:	99250513          	addi	a0,a0,-1646 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc020329e:	9f4fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc02032a2:	00004697          	auipc	a3,0x4
ffffffffc02032a6:	b1e68693          	addi	a3,a3,-1250 # ffffffffc0206dc0 <default_pmm_manager+0x2e8>
ffffffffc02032aa:	00003617          	auipc	a2,0x3
ffffffffc02032ae:	47e60613          	addi	a2,a2,1150 # ffffffffc0206728 <commands+0x828>
ffffffffc02032b2:	22c00593          	li	a1,556
ffffffffc02032b6:	00004517          	auipc	a0,0x4
ffffffffc02032ba:	97250513          	addi	a0,a0,-1678 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc02032be:	9d4fd0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02032c2 <copy_range>:
{
ffffffffc02032c2:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02032c4:	00d667b3          	or	a5,a2,a3
{
ffffffffc02032c8:	f486                	sd	ra,104(sp)
ffffffffc02032ca:	f0a2                	sd	s0,96(sp)
ffffffffc02032cc:	eca6                	sd	s1,88(sp)
ffffffffc02032ce:	e8ca                	sd	s2,80(sp)
ffffffffc02032d0:	e4ce                	sd	s3,72(sp)
ffffffffc02032d2:	e0d2                	sd	s4,64(sp)
ffffffffc02032d4:	fc56                	sd	s5,56(sp)
ffffffffc02032d6:	f85a                	sd	s6,48(sp)
ffffffffc02032d8:	f45e                	sd	s7,40(sp)
ffffffffc02032da:	f062                	sd	s8,32(sp)
ffffffffc02032dc:	ec66                	sd	s9,24(sp)
ffffffffc02032de:	e86a                	sd	s10,16(sp)
ffffffffc02032e0:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02032e2:	17d2                	slli	a5,a5,0x34
ffffffffc02032e4:	20079f63          	bnez	a5,ffffffffc0203502 <copy_range+0x240>
    assert(USER_ACCESS(start, end));
ffffffffc02032e8:	002007b7          	lui	a5,0x200
ffffffffc02032ec:	8432                	mv	s0,a2
ffffffffc02032ee:	1af66263          	bltu	a2,a5,ffffffffc0203492 <copy_range+0x1d0>
ffffffffc02032f2:	8936                	mv	s2,a3
ffffffffc02032f4:	18d67f63          	bgeu	a2,a3,ffffffffc0203492 <copy_range+0x1d0>
ffffffffc02032f8:	4785                	li	a5,1
ffffffffc02032fa:	07fe                	slli	a5,a5,0x1f
ffffffffc02032fc:	18d7eb63          	bltu	a5,a3,ffffffffc0203492 <copy_range+0x1d0>
ffffffffc0203300:	5b7d                	li	s6,-1
ffffffffc0203302:	8aaa                	mv	s5,a0
ffffffffc0203304:	89ae                	mv	s3,a1
        start += PGSIZE;
ffffffffc0203306:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage)
ffffffffc0203308:	000cfc17          	auipc	s8,0xcf
ffffffffc020330c:	498c0c13          	addi	s8,s8,1176 # ffffffffc02d27a0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203310:	000cfb97          	auipc	s7,0xcf
ffffffffc0203314:	498b8b93          	addi	s7,s7,1176 # ffffffffc02d27a8 <pages>
    return KADDR(page2pa(page));
ffffffffc0203318:	00cb5b13          	srli	s6,s6,0xc
        page = pmm_manager->alloc_pages(n);
ffffffffc020331c:	000cfc97          	auipc	s9,0xcf
ffffffffc0203320:	494c8c93          	addi	s9,s9,1172 # ffffffffc02d27b0 <pmm_manager>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0203324:	4601                	li	a2,0
ffffffffc0203326:	85a2                	mv	a1,s0
ffffffffc0203328:	854e                	mv	a0,s3
ffffffffc020332a:	b73fe0ef          	jal	ra,ffffffffc0201e9c <get_pte>
ffffffffc020332e:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc0203330:	0e050c63          	beqz	a0,ffffffffc0203428 <copy_range+0x166>
        if (*ptep & PTE_V)
ffffffffc0203334:	611c                	ld	a5,0(a0)
ffffffffc0203336:	8b85                	andi	a5,a5,1
ffffffffc0203338:	e785                	bnez	a5,ffffffffc0203360 <copy_range+0x9e>
        start += PGSIZE;
ffffffffc020333a:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc020333c:	ff2464e3          	bltu	s0,s2,ffffffffc0203324 <copy_range+0x62>
    return 0;
ffffffffc0203340:	4501                	li	a0,0
}
ffffffffc0203342:	70a6                	ld	ra,104(sp)
ffffffffc0203344:	7406                	ld	s0,96(sp)
ffffffffc0203346:	64e6                	ld	s1,88(sp)
ffffffffc0203348:	6946                	ld	s2,80(sp)
ffffffffc020334a:	69a6                	ld	s3,72(sp)
ffffffffc020334c:	6a06                	ld	s4,64(sp)
ffffffffc020334e:	7ae2                	ld	s5,56(sp)
ffffffffc0203350:	7b42                	ld	s6,48(sp)
ffffffffc0203352:	7ba2                	ld	s7,40(sp)
ffffffffc0203354:	7c02                	ld	s8,32(sp)
ffffffffc0203356:	6ce2                	ld	s9,24(sp)
ffffffffc0203358:	6d42                	ld	s10,16(sp)
ffffffffc020335a:	6da2                	ld	s11,8(sp)
ffffffffc020335c:	6165                	addi	sp,sp,112
ffffffffc020335e:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc0203360:	4605                	li	a2,1
ffffffffc0203362:	85a2                	mv	a1,s0
ffffffffc0203364:	8556                	mv	a0,s5
ffffffffc0203366:	b37fe0ef          	jal	ra,ffffffffc0201e9c <get_pte>
ffffffffc020336a:	c56d                	beqz	a0,ffffffffc0203454 <copy_range+0x192>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc020336c:	609c                	ld	a5,0(s1)
    if (!(pte & PTE_V))
ffffffffc020336e:	0017f713          	andi	a4,a5,1
ffffffffc0203372:	01f7f493          	andi	s1,a5,31
ffffffffc0203376:	16070a63          	beqz	a4,ffffffffc02034ea <copy_range+0x228>
    if (PPN(pa) >= npage)
ffffffffc020337a:	000c3683          	ld	a3,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc020337e:	078a                	slli	a5,a5,0x2
ffffffffc0203380:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0203384:	14d77763          	bgeu	a4,a3,ffffffffc02034d2 <copy_range+0x210>
    return &pages[PPN(pa) - nbase];
ffffffffc0203388:	000bb783          	ld	a5,0(s7)
ffffffffc020338c:	fff806b7          	lui	a3,0xfff80
ffffffffc0203390:	9736                	add	a4,a4,a3
ffffffffc0203392:	071a                	slli	a4,a4,0x6
ffffffffc0203394:	00e78db3          	add	s11,a5,a4
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203398:	10002773          	csrr	a4,sstatus
ffffffffc020339c:	8b09                	andi	a4,a4,2
ffffffffc020339e:	e345                	bnez	a4,ffffffffc020343e <copy_range+0x17c>
        page = pmm_manager->alloc_pages(n);
ffffffffc02033a0:	000cb703          	ld	a4,0(s9)
ffffffffc02033a4:	4505                	li	a0,1
ffffffffc02033a6:	6f18                	ld	a4,24(a4)
ffffffffc02033a8:	9702                	jalr	a4
ffffffffc02033aa:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc02033ac:	0c0d8363          	beqz	s11,ffffffffc0203472 <copy_range+0x1b0>
            assert(npage != NULL);
ffffffffc02033b0:	100d0163          	beqz	s10,ffffffffc02034b2 <copy_range+0x1f0>
    return page - pages + nbase;
ffffffffc02033b4:	000bb703          	ld	a4,0(s7)
ffffffffc02033b8:	000805b7          	lui	a1,0x80
    return KADDR(page2pa(page));
ffffffffc02033bc:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc02033c0:	40ed86b3          	sub	a3,s11,a4
ffffffffc02033c4:	8699                	srai	a3,a3,0x6
ffffffffc02033c6:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc02033c8:	0166f7b3          	and	a5,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02033cc:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02033ce:	08c7f663          	bgeu	a5,a2,ffffffffc020345a <copy_range+0x198>
    return page - pages + nbase;
ffffffffc02033d2:	40ed07b3          	sub	a5,s10,a4
    return KADDR(page2pa(page));
ffffffffc02033d6:	000cf717          	auipc	a4,0xcf
ffffffffc02033da:	3e270713          	addi	a4,a4,994 # ffffffffc02d27b8 <va_pa_offset>
ffffffffc02033de:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc02033e0:	8799                	srai	a5,a5,0x6
ffffffffc02033e2:	97ae                	add	a5,a5,a1
    return KADDR(page2pa(page));
ffffffffc02033e4:	0167f733          	and	a4,a5,s6
ffffffffc02033e8:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02033ec:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02033ee:	06c77563          	bgeu	a4,a2,ffffffffc0203458 <copy_range+0x196>
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ffffffffc02033f2:	6605                	lui	a2,0x1
ffffffffc02033f4:	953e                	add	a0,a0,a5
ffffffffc02033f6:	08b020ef          	jal	ra,ffffffffc0205c80 <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc02033fa:	86a6                	mv	a3,s1
ffffffffc02033fc:	8622                	mv	a2,s0
ffffffffc02033fe:	85ea                	mv	a1,s10
ffffffffc0203400:	8556                	mv	a0,s5
ffffffffc0203402:	98aff0ef          	jal	ra,ffffffffc020258c <page_insert>
            assert(ret == 0);
ffffffffc0203406:	d915                	beqz	a0,ffffffffc020333a <copy_range+0x78>
ffffffffc0203408:	00004697          	auipc	a3,0x4
ffffffffc020340c:	e3068693          	addi	a3,a3,-464 # ffffffffc0207238 <default_pmm_manager+0x760>
ffffffffc0203410:	00003617          	auipc	a2,0x3
ffffffffc0203414:	31860613          	addi	a2,a2,792 # ffffffffc0206728 <commands+0x828>
ffffffffc0203418:	1c400593          	li	a1,452
ffffffffc020341c:	00004517          	auipc	a0,0x4
ffffffffc0203420:	80c50513          	addi	a0,a0,-2036 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc0203424:	86efd0ef          	jal	ra,ffffffffc0200492 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203428:	00200637          	lui	a2,0x200
ffffffffc020342c:	9432                	add	s0,s0,a2
ffffffffc020342e:	ffe00637          	lui	a2,0xffe00
ffffffffc0203432:	8c71                	and	s0,s0,a2
    } while (start != 0 && start < end);
ffffffffc0203434:	f00406e3          	beqz	s0,ffffffffc0203340 <copy_range+0x7e>
ffffffffc0203438:	ef2466e3          	bltu	s0,s2,ffffffffc0203324 <copy_range+0x62>
ffffffffc020343c:	b711                	j	ffffffffc0203340 <copy_range+0x7e>
        intr_disable();
ffffffffc020343e:	d70fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203442:	000cb703          	ld	a4,0(s9)
ffffffffc0203446:	4505                	li	a0,1
ffffffffc0203448:	6f18                	ld	a4,24(a4)
ffffffffc020344a:	9702                	jalr	a4
ffffffffc020344c:	8d2a                	mv	s10,a0
        intr_enable();
ffffffffc020344e:	d5afd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0203452:	bfa9                	j	ffffffffc02033ac <copy_range+0xea>
                return -E_NO_MEM;
ffffffffc0203454:	5571                	li	a0,-4
ffffffffc0203456:	b5f5                	j	ffffffffc0203342 <copy_range+0x80>
ffffffffc0203458:	86be                	mv	a3,a5
ffffffffc020345a:	00003617          	auipc	a2,0x3
ffffffffc020345e:	6b660613          	addi	a2,a2,1718 # ffffffffc0206b10 <default_pmm_manager+0x38>
ffffffffc0203462:	07100593          	li	a1,113
ffffffffc0203466:	00003517          	auipc	a0,0x3
ffffffffc020346a:	6d250513          	addi	a0,a0,1746 # ffffffffc0206b38 <default_pmm_manager+0x60>
ffffffffc020346e:	824fd0ef          	jal	ra,ffffffffc0200492 <__panic>
            assert(page != NULL);
ffffffffc0203472:	00004697          	auipc	a3,0x4
ffffffffc0203476:	da668693          	addi	a3,a3,-602 # ffffffffc0207218 <default_pmm_manager+0x740>
ffffffffc020347a:	00003617          	auipc	a2,0x3
ffffffffc020347e:	2ae60613          	addi	a2,a2,686 # ffffffffc0206728 <commands+0x828>
ffffffffc0203482:	19600593          	li	a1,406
ffffffffc0203486:	00003517          	auipc	a0,0x3
ffffffffc020348a:	7a250513          	addi	a0,a0,1954 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc020348e:	804fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203492:	00003697          	auipc	a3,0x3
ffffffffc0203496:	7d668693          	addi	a3,a3,2006 # ffffffffc0206c68 <default_pmm_manager+0x190>
ffffffffc020349a:	00003617          	auipc	a2,0x3
ffffffffc020349e:	28e60613          	addi	a2,a2,654 # ffffffffc0206728 <commands+0x828>
ffffffffc02034a2:	17e00593          	li	a1,382
ffffffffc02034a6:	00003517          	auipc	a0,0x3
ffffffffc02034aa:	78250513          	addi	a0,a0,1922 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc02034ae:	fe5fc0ef          	jal	ra,ffffffffc0200492 <__panic>
            assert(npage != NULL);
ffffffffc02034b2:	00004697          	auipc	a3,0x4
ffffffffc02034b6:	d7668693          	addi	a3,a3,-650 # ffffffffc0207228 <default_pmm_manager+0x750>
ffffffffc02034ba:	00003617          	auipc	a2,0x3
ffffffffc02034be:	26e60613          	addi	a2,a2,622 # ffffffffc0206728 <commands+0x828>
ffffffffc02034c2:	1bb00593          	li	a1,443
ffffffffc02034c6:	00003517          	auipc	a0,0x3
ffffffffc02034ca:	76250513          	addi	a0,a0,1890 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc02034ce:	fc5fc0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02034d2:	00003617          	auipc	a2,0x3
ffffffffc02034d6:	70e60613          	addi	a2,a2,1806 # ffffffffc0206be0 <default_pmm_manager+0x108>
ffffffffc02034da:	06900593          	li	a1,105
ffffffffc02034de:	00003517          	auipc	a0,0x3
ffffffffc02034e2:	65a50513          	addi	a0,a0,1626 # ffffffffc0206b38 <default_pmm_manager+0x60>
ffffffffc02034e6:	fadfc0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02034ea:	00003617          	auipc	a2,0x3
ffffffffc02034ee:	71660613          	addi	a2,a2,1814 # ffffffffc0206c00 <default_pmm_manager+0x128>
ffffffffc02034f2:	07f00593          	li	a1,127
ffffffffc02034f6:	00003517          	auipc	a0,0x3
ffffffffc02034fa:	64250513          	addi	a0,a0,1602 # ffffffffc0206b38 <default_pmm_manager+0x60>
ffffffffc02034fe:	f95fc0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203502:	00003697          	auipc	a3,0x3
ffffffffc0203506:	73668693          	addi	a3,a3,1846 # ffffffffc0206c38 <default_pmm_manager+0x160>
ffffffffc020350a:	00003617          	auipc	a2,0x3
ffffffffc020350e:	21e60613          	addi	a2,a2,542 # ffffffffc0206728 <commands+0x828>
ffffffffc0203512:	17d00593          	li	a1,381
ffffffffc0203516:	00003517          	auipc	a0,0x3
ffffffffc020351a:	71250513          	addi	a0,a0,1810 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc020351e:	f75fc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0203522 <pgdir_alloc_page>:
{
ffffffffc0203522:	7179                	addi	sp,sp,-48
ffffffffc0203524:	ec26                	sd	s1,24(sp)
ffffffffc0203526:	e84a                	sd	s2,16(sp)
ffffffffc0203528:	e052                	sd	s4,0(sp)
ffffffffc020352a:	f406                	sd	ra,40(sp)
ffffffffc020352c:	f022                	sd	s0,32(sp)
ffffffffc020352e:	e44e                	sd	s3,8(sp)
ffffffffc0203530:	8a2a                	mv	s4,a0
ffffffffc0203532:	84ae                	mv	s1,a1
ffffffffc0203534:	8932                	mv	s2,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203536:	100027f3          	csrr	a5,sstatus
ffffffffc020353a:	8b89                	andi	a5,a5,2
        page = pmm_manager->alloc_pages(n);
ffffffffc020353c:	000cf997          	auipc	s3,0xcf
ffffffffc0203540:	27498993          	addi	s3,s3,628 # ffffffffc02d27b0 <pmm_manager>
ffffffffc0203544:	ef8d                	bnez	a5,ffffffffc020357e <pgdir_alloc_page+0x5c>
ffffffffc0203546:	0009b783          	ld	a5,0(s3)
ffffffffc020354a:	4505                	li	a0,1
ffffffffc020354c:	6f9c                	ld	a5,24(a5)
ffffffffc020354e:	9782                	jalr	a5
ffffffffc0203550:	842a                	mv	s0,a0
    if (page != NULL)
ffffffffc0203552:	cc09                	beqz	s0,ffffffffc020356c <pgdir_alloc_page+0x4a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc0203554:	86ca                	mv	a3,s2
ffffffffc0203556:	8626                	mv	a2,s1
ffffffffc0203558:	85a2                	mv	a1,s0
ffffffffc020355a:	8552                	mv	a0,s4
ffffffffc020355c:	830ff0ef          	jal	ra,ffffffffc020258c <page_insert>
ffffffffc0203560:	e915                	bnez	a0,ffffffffc0203594 <pgdir_alloc_page+0x72>
        assert(page_ref(page) == 1);
ffffffffc0203562:	4018                	lw	a4,0(s0)
        page->pra_vaddr = la;
ffffffffc0203564:	fc04                	sd	s1,56(s0)
        assert(page_ref(page) == 1);
ffffffffc0203566:	4785                	li	a5,1
ffffffffc0203568:	04f71e63          	bne	a4,a5,ffffffffc02035c4 <pgdir_alloc_page+0xa2>
}
ffffffffc020356c:	70a2                	ld	ra,40(sp)
ffffffffc020356e:	8522                	mv	a0,s0
ffffffffc0203570:	7402                	ld	s0,32(sp)
ffffffffc0203572:	64e2                	ld	s1,24(sp)
ffffffffc0203574:	6942                	ld	s2,16(sp)
ffffffffc0203576:	69a2                	ld	s3,8(sp)
ffffffffc0203578:	6a02                	ld	s4,0(sp)
ffffffffc020357a:	6145                	addi	sp,sp,48
ffffffffc020357c:	8082                	ret
        intr_disable();
ffffffffc020357e:	c30fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203582:	0009b783          	ld	a5,0(s3)
ffffffffc0203586:	4505                	li	a0,1
ffffffffc0203588:	6f9c                	ld	a5,24(a5)
ffffffffc020358a:	9782                	jalr	a5
ffffffffc020358c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020358e:	c1afd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0203592:	b7c1                	j	ffffffffc0203552 <pgdir_alloc_page+0x30>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203594:	100027f3          	csrr	a5,sstatus
ffffffffc0203598:	8b89                	andi	a5,a5,2
ffffffffc020359a:	eb89                	bnez	a5,ffffffffc02035ac <pgdir_alloc_page+0x8a>
        pmm_manager->free_pages(base, n);
ffffffffc020359c:	0009b783          	ld	a5,0(s3)
ffffffffc02035a0:	8522                	mv	a0,s0
ffffffffc02035a2:	4585                	li	a1,1
ffffffffc02035a4:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc02035a6:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc02035a8:	9782                	jalr	a5
    if (flag)
ffffffffc02035aa:	b7c9                	j	ffffffffc020356c <pgdir_alloc_page+0x4a>
        intr_disable();
ffffffffc02035ac:	c02fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc02035b0:	0009b783          	ld	a5,0(s3)
ffffffffc02035b4:	8522                	mv	a0,s0
ffffffffc02035b6:	4585                	li	a1,1
ffffffffc02035b8:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc02035ba:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc02035bc:	9782                	jalr	a5
        intr_enable();
ffffffffc02035be:	beafd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc02035c2:	b76d                	j	ffffffffc020356c <pgdir_alloc_page+0x4a>
        assert(page_ref(page) == 1);
ffffffffc02035c4:	00004697          	auipc	a3,0x4
ffffffffc02035c8:	c8468693          	addi	a3,a3,-892 # ffffffffc0207248 <default_pmm_manager+0x770>
ffffffffc02035cc:	00003617          	auipc	a2,0x3
ffffffffc02035d0:	15c60613          	addi	a2,a2,348 # ffffffffc0206728 <commands+0x828>
ffffffffc02035d4:	20d00593          	li	a1,525
ffffffffc02035d8:	00003517          	auipc	a0,0x3
ffffffffc02035dc:	65050513          	addi	a0,a0,1616 # ffffffffc0206c28 <default_pmm_manager+0x150>
ffffffffc02035e0:	eb3fc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02035e4 <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02035e4:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02035e6:	00004697          	auipc	a3,0x4
ffffffffc02035ea:	c7a68693          	addi	a3,a3,-902 # ffffffffc0207260 <default_pmm_manager+0x788>
ffffffffc02035ee:	00003617          	auipc	a2,0x3
ffffffffc02035f2:	13a60613          	addi	a2,a2,314 # ffffffffc0206728 <commands+0x828>
ffffffffc02035f6:	07400593          	li	a1,116
ffffffffc02035fa:	00004517          	auipc	a0,0x4
ffffffffc02035fe:	c8650513          	addi	a0,a0,-890 # ffffffffc0207280 <default_pmm_manager+0x7a8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0203602:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0203604:	e8ffc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0203608 <mm_create>:
{
ffffffffc0203608:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020360a:	04000513          	li	a0,64
{
ffffffffc020360e:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203610:	df6fe0ef          	jal	ra,ffffffffc0201c06 <kmalloc>
    if (mm != NULL)
ffffffffc0203614:	cd19                	beqz	a0,ffffffffc0203632 <mm_create+0x2a>
    elm->prev = elm->next = elm;
ffffffffc0203616:	e508                	sd	a0,8(a0)
ffffffffc0203618:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc020361a:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020361e:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203622:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0203626:	02053423          	sd	zero,40(a0)
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc020362a:	02052823          	sw	zero,48(a0)
typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
ffffffffc020362e:	02053c23          	sd	zero,56(a0)
}
ffffffffc0203632:	60a2                	ld	ra,8(sp)
ffffffffc0203634:	0141                	addi	sp,sp,16
ffffffffc0203636:	8082                	ret

ffffffffc0203638 <find_vma>:
{
ffffffffc0203638:	86aa                	mv	a3,a0
    if (mm != NULL)
ffffffffc020363a:	c505                	beqz	a0,ffffffffc0203662 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc020363c:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc020363e:	c501                	beqz	a0,ffffffffc0203646 <find_vma+0xe>
ffffffffc0203640:	651c                	ld	a5,8(a0)
ffffffffc0203642:	02f5f263          	bgeu	a1,a5,ffffffffc0203666 <find_vma+0x2e>
    return listelm->next;
ffffffffc0203646:	669c                	ld	a5,8(a3)
            while ((le = list_next(le)) != list)
ffffffffc0203648:	00f68d63          	beq	a3,a5,ffffffffc0203662 <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc020364c:	fe87b703          	ld	a4,-24(a5) # 1fffe8 <_binary_obj___user_matrix_out_size+0x1f38c0>
ffffffffc0203650:	00e5e663          	bltu	a1,a4,ffffffffc020365c <find_vma+0x24>
ffffffffc0203654:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203658:	00e5ec63          	bltu	a1,a4,ffffffffc0203670 <find_vma+0x38>
ffffffffc020365c:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc020365e:	fef697e3          	bne	a3,a5,ffffffffc020364c <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0203662:	4501                	li	a0,0
}
ffffffffc0203664:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0203666:	691c                	ld	a5,16(a0)
ffffffffc0203668:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0203646 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc020366c:	ea88                	sd	a0,16(a3)
ffffffffc020366e:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc0203670:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0203674:	ea88                	sd	a0,16(a3)
ffffffffc0203676:	8082                	ret

ffffffffc0203678 <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203678:	6590                	ld	a2,8(a1)
ffffffffc020367a:	0105b803          	ld	a6,16(a1) # 80010 <_binary_obj___user_matrix_out_size+0x738e8>
{
ffffffffc020367e:	1141                	addi	sp,sp,-16
ffffffffc0203680:	e406                	sd	ra,8(sp)
ffffffffc0203682:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203684:	01066763          	bltu	a2,a6,ffffffffc0203692 <insert_vma_struct+0x1a>
ffffffffc0203688:	a085                	j	ffffffffc02036e8 <insert_vma_struct+0x70>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc020368a:	fe87b703          	ld	a4,-24(a5)
ffffffffc020368e:	04e66863          	bltu	a2,a4,ffffffffc02036de <insert_vma_struct+0x66>
ffffffffc0203692:	86be                	mv	a3,a5
ffffffffc0203694:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc0203696:	fef51ae3          	bne	a0,a5,ffffffffc020368a <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc020369a:	02a68463          	beq	a3,a0,ffffffffc02036c2 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc020369e:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02036a2:	fe86b883          	ld	a7,-24(a3)
ffffffffc02036a6:	08e8f163          	bgeu	a7,a4,ffffffffc0203728 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02036aa:	04e66f63          	bltu	a2,a4,ffffffffc0203708 <insert_vma_struct+0x90>
    }
    if (le_next != list)
ffffffffc02036ae:	00f50a63          	beq	a0,a5,ffffffffc02036c2 <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc02036b2:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02036b6:	05076963          	bltu	a4,a6,ffffffffc0203708 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02036ba:	ff07b603          	ld	a2,-16(a5)
ffffffffc02036be:	02c77363          	bgeu	a4,a2,ffffffffc02036e4 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc02036c2:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02036c4:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02036c6:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02036ca:	e390                	sd	a2,0(a5)
ffffffffc02036cc:	e690                	sd	a2,8(a3)
}
ffffffffc02036ce:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02036d0:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02036d2:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc02036d4:	0017079b          	addiw	a5,a4,1
ffffffffc02036d8:	d11c                	sw	a5,32(a0)
}
ffffffffc02036da:	0141                	addi	sp,sp,16
ffffffffc02036dc:	8082                	ret
    if (le_prev != list)
ffffffffc02036de:	fca690e3          	bne	a3,a0,ffffffffc020369e <insert_vma_struct+0x26>
ffffffffc02036e2:	bfd1                	j	ffffffffc02036b6 <insert_vma_struct+0x3e>
ffffffffc02036e4:	f01ff0ef          	jal	ra,ffffffffc02035e4 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02036e8:	00004697          	auipc	a3,0x4
ffffffffc02036ec:	ba868693          	addi	a3,a3,-1112 # ffffffffc0207290 <default_pmm_manager+0x7b8>
ffffffffc02036f0:	00003617          	auipc	a2,0x3
ffffffffc02036f4:	03860613          	addi	a2,a2,56 # ffffffffc0206728 <commands+0x828>
ffffffffc02036f8:	07a00593          	li	a1,122
ffffffffc02036fc:	00004517          	auipc	a0,0x4
ffffffffc0203700:	b8450513          	addi	a0,a0,-1148 # ffffffffc0207280 <default_pmm_manager+0x7a8>
ffffffffc0203704:	d8ffc0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203708:	00004697          	auipc	a3,0x4
ffffffffc020370c:	bc868693          	addi	a3,a3,-1080 # ffffffffc02072d0 <default_pmm_manager+0x7f8>
ffffffffc0203710:	00003617          	auipc	a2,0x3
ffffffffc0203714:	01860613          	addi	a2,a2,24 # ffffffffc0206728 <commands+0x828>
ffffffffc0203718:	07300593          	li	a1,115
ffffffffc020371c:	00004517          	auipc	a0,0x4
ffffffffc0203720:	b6450513          	addi	a0,a0,-1180 # ffffffffc0207280 <default_pmm_manager+0x7a8>
ffffffffc0203724:	d6ffc0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203728:	00004697          	auipc	a3,0x4
ffffffffc020372c:	b8868693          	addi	a3,a3,-1144 # ffffffffc02072b0 <default_pmm_manager+0x7d8>
ffffffffc0203730:	00003617          	auipc	a2,0x3
ffffffffc0203734:	ff860613          	addi	a2,a2,-8 # ffffffffc0206728 <commands+0x828>
ffffffffc0203738:	07200593          	li	a1,114
ffffffffc020373c:	00004517          	auipc	a0,0x4
ffffffffc0203740:	b4450513          	addi	a0,a0,-1212 # ffffffffc0207280 <default_pmm_manager+0x7a8>
ffffffffc0203744:	d4ffc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0203748 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc0203748:	591c                	lw	a5,48(a0)
{
ffffffffc020374a:	1141                	addi	sp,sp,-16
ffffffffc020374c:	e406                	sd	ra,8(sp)
ffffffffc020374e:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0203750:	e78d                	bnez	a5,ffffffffc020377a <mm_destroy+0x32>
ffffffffc0203752:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203754:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc0203756:	00a40c63          	beq	s0,a0,ffffffffc020376e <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020375a:	6118                	ld	a4,0(a0)
ffffffffc020375c:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc020375e:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203760:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203762:	e398                	sd	a4,0(a5)
ffffffffc0203764:	d52fe0ef          	jal	ra,ffffffffc0201cb6 <kfree>
    return listelm->next;
ffffffffc0203768:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc020376a:	fea418e3          	bne	s0,a0,ffffffffc020375a <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc020376e:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc0203770:	6402                	ld	s0,0(sp)
ffffffffc0203772:	60a2                	ld	ra,8(sp)
ffffffffc0203774:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc0203776:	d40fe06f          	j	ffffffffc0201cb6 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc020377a:	00004697          	auipc	a3,0x4
ffffffffc020377e:	b7668693          	addi	a3,a3,-1162 # ffffffffc02072f0 <default_pmm_manager+0x818>
ffffffffc0203782:	00003617          	auipc	a2,0x3
ffffffffc0203786:	fa660613          	addi	a2,a2,-90 # ffffffffc0206728 <commands+0x828>
ffffffffc020378a:	09e00593          	li	a1,158
ffffffffc020378e:	00004517          	auipc	a0,0x4
ffffffffc0203792:	af250513          	addi	a0,a0,-1294 # ffffffffc0207280 <default_pmm_manager+0x7a8>
ffffffffc0203796:	cfdfc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc020379a <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
ffffffffc020379a:	7139                	addi	sp,sp,-64
ffffffffc020379c:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020379e:	6405                	lui	s0,0x1
ffffffffc02037a0:	147d                	addi	s0,s0,-1
ffffffffc02037a2:	77fd                	lui	a5,0xfffff
ffffffffc02037a4:	9622                	add	a2,a2,s0
ffffffffc02037a6:	962e                	add	a2,a2,a1
{
ffffffffc02037a8:	f426                	sd	s1,40(sp)
ffffffffc02037aa:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02037ac:	00f5f4b3          	and	s1,a1,a5
{
ffffffffc02037b0:	f04a                	sd	s2,32(sp)
ffffffffc02037b2:	ec4e                	sd	s3,24(sp)
ffffffffc02037b4:	e852                	sd	s4,16(sp)
ffffffffc02037b6:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end))
ffffffffc02037b8:	002005b7          	lui	a1,0x200
ffffffffc02037bc:	00f67433          	and	s0,a2,a5
ffffffffc02037c0:	06b4e363          	bltu	s1,a1,ffffffffc0203826 <mm_map+0x8c>
ffffffffc02037c4:	0684f163          	bgeu	s1,s0,ffffffffc0203826 <mm_map+0x8c>
ffffffffc02037c8:	4785                	li	a5,1
ffffffffc02037ca:	07fe                	slli	a5,a5,0x1f
ffffffffc02037cc:	0487ed63          	bltu	a5,s0,ffffffffc0203826 <mm_map+0x8c>
ffffffffc02037d0:	89aa                	mv	s3,a0
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02037d2:	cd21                	beqz	a0,ffffffffc020382a <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc02037d4:	85a6                	mv	a1,s1
ffffffffc02037d6:	8ab6                	mv	s5,a3
ffffffffc02037d8:	8a3a                	mv	s4,a4
ffffffffc02037da:	e5fff0ef          	jal	ra,ffffffffc0203638 <find_vma>
ffffffffc02037de:	c501                	beqz	a0,ffffffffc02037e6 <mm_map+0x4c>
ffffffffc02037e0:	651c                	ld	a5,8(a0)
ffffffffc02037e2:	0487e263          	bltu	a5,s0,ffffffffc0203826 <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02037e6:	03000513          	li	a0,48
ffffffffc02037ea:	c1cfe0ef          	jal	ra,ffffffffc0201c06 <kmalloc>
ffffffffc02037ee:	892a                	mv	s2,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02037f0:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc02037f2:	02090163          	beqz	s2,ffffffffc0203814 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02037f6:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02037f8:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc02037fc:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0203800:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0203804:	85ca                	mv	a1,s2
ffffffffc0203806:	e73ff0ef          	jal	ra,ffffffffc0203678 <insert_vma_struct>
    if (vma_store != NULL)
    {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc020380a:	4501                	li	a0,0
    if (vma_store != NULL)
ffffffffc020380c:	000a0463          	beqz	s4,ffffffffc0203814 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc0203810:	012a3023          	sd	s2,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8f50>

out:
    return ret;
}
ffffffffc0203814:	70e2                	ld	ra,56(sp)
ffffffffc0203816:	7442                	ld	s0,48(sp)
ffffffffc0203818:	74a2                	ld	s1,40(sp)
ffffffffc020381a:	7902                	ld	s2,32(sp)
ffffffffc020381c:	69e2                	ld	s3,24(sp)
ffffffffc020381e:	6a42                	ld	s4,16(sp)
ffffffffc0203820:	6aa2                	ld	s5,8(sp)
ffffffffc0203822:	6121                	addi	sp,sp,64
ffffffffc0203824:	8082                	ret
        return -E_INVAL;
ffffffffc0203826:	5575                	li	a0,-3
ffffffffc0203828:	b7f5                	j	ffffffffc0203814 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc020382a:	00004697          	auipc	a3,0x4
ffffffffc020382e:	ade68693          	addi	a3,a3,-1314 # ffffffffc0207308 <default_pmm_manager+0x830>
ffffffffc0203832:	00003617          	auipc	a2,0x3
ffffffffc0203836:	ef660613          	addi	a2,a2,-266 # ffffffffc0206728 <commands+0x828>
ffffffffc020383a:	0b300593          	li	a1,179
ffffffffc020383e:	00004517          	auipc	a0,0x4
ffffffffc0203842:	a4250513          	addi	a0,a0,-1470 # ffffffffc0207280 <default_pmm_manager+0x7a8>
ffffffffc0203846:	c4dfc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc020384a <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc020384a:	7139                	addi	sp,sp,-64
ffffffffc020384c:	fc06                	sd	ra,56(sp)
ffffffffc020384e:	f822                	sd	s0,48(sp)
ffffffffc0203850:	f426                	sd	s1,40(sp)
ffffffffc0203852:	f04a                	sd	s2,32(sp)
ffffffffc0203854:	ec4e                	sd	s3,24(sp)
ffffffffc0203856:	e852                	sd	s4,16(sp)
ffffffffc0203858:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc020385a:	c52d                	beqz	a0,ffffffffc02038c4 <dup_mmap+0x7a>
ffffffffc020385c:	892a                	mv	s2,a0
ffffffffc020385e:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0203860:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0203862:	e595                	bnez	a1,ffffffffc020388e <dup_mmap+0x44>
ffffffffc0203864:	a085                	j	ffffffffc02038c4 <dup_mmap+0x7a>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0203866:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc0203868:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_matrix_out_size+0x1f38e0>
        vma->vm_end = vm_end;
ffffffffc020386c:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0203870:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc0203874:	e05ff0ef          	jal	ra,ffffffffc0203678 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc0203878:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8f60>
ffffffffc020387c:	fe843603          	ld	a2,-24(s0)
ffffffffc0203880:	6c8c                	ld	a1,24(s1)
ffffffffc0203882:	01893503          	ld	a0,24(s2)
ffffffffc0203886:	4701                	li	a4,0
ffffffffc0203888:	a3bff0ef          	jal	ra,ffffffffc02032c2 <copy_range>
ffffffffc020388c:	e105                	bnez	a0,ffffffffc02038ac <dup_mmap+0x62>
    return listelm->prev;
ffffffffc020388e:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc0203890:	02848863          	beq	s1,s0,ffffffffc02038c0 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203894:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0203898:	fe843a83          	ld	s5,-24(s0)
ffffffffc020389c:	ff043a03          	ld	s4,-16(s0)
ffffffffc02038a0:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02038a4:	b62fe0ef          	jal	ra,ffffffffc0201c06 <kmalloc>
ffffffffc02038a8:	85aa                	mv	a1,a0
    if (vma != NULL)
ffffffffc02038aa:	fd55                	bnez	a0,ffffffffc0203866 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc02038ac:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02038ae:	70e2                	ld	ra,56(sp)
ffffffffc02038b0:	7442                	ld	s0,48(sp)
ffffffffc02038b2:	74a2                	ld	s1,40(sp)
ffffffffc02038b4:	7902                	ld	s2,32(sp)
ffffffffc02038b6:	69e2                	ld	s3,24(sp)
ffffffffc02038b8:	6a42                	ld	s4,16(sp)
ffffffffc02038ba:	6aa2                	ld	s5,8(sp)
ffffffffc02038bc:	6121                	addi	sp,sp,64
ffffffffc02038be:	8082                	ret
    return 0;
ffffffffc02038c0:	4501                	li	a0,0
ffffffffc02038c2:	b7f5                	j	ffffffffc02038ae <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc02038c4:	00004697          	auipc	a3,0x4
ffffffffc02038c8:	a5468693          	addi	a3,a3,-1452 # ffffffffc0207318 <default_pmm_manager+0x840>
ffffffffc02038cc:	00003617          	auipc	a2,0x3
ffffffffc02038d0:	e5c60613          	addi	a2,a2,-420 # ffffffffc0206728 <commands+0x828>
ffffffffc02038d4:	0cf00593          	li	a1,207
ffffffffc02038d8:	00004517          	auipc	a0,0x4
ffffffffc02038dc:	9a850513          	addi	a0,a0,-1624 # ffffffffc0207280 <default_pmm_manager+0x7a8>
ffffffffc02038e0:	bb3fc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02038e4 <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc02038e4:	1101                	addi	sp,sp,-32
ffffffffc02038e6:	ec06                	sd	ra,24(sp)
ffffffffc02038e8:	e822                	sd	s0,16(sp)
ffffffffc02038ea:	e426                	sd	s1,8(sp)
ffffffffc02038ec:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02038ee:	c531                	beqz	a0,ffffffffc020393a <exit_mmap+0x56>
ffffffffc02038f0:	591c                	lw	a5,48(a0)
ffffffffc02038f2:	84aa                	mv	s1,a0
ffffffffc02038f4:	e3b9                	bnez	a5,ffffffffc020393a <exit_mmap+0x56>
    return listelm->next;
ffffffffc02038f6:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02038f8:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc02038fc:	02850663          	beq	a0,s0,ffffffffc0203928 <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0203900:	ff043603          	ld	a2,-16(s0)
ffffffffc0203904:	fe843583          	ld	a1,-24(s0)
ffffffffc0203908:	854a                	mv	a0,s2
ffffffffc020390a:	80ffe0ef          	jal	ra,ffffffffc0202118 <unmap_range>
ffffffffc020390e:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0203910:	fe8498e3          	bne	s1,s0,ffffffffc0203900 <exit_mmap+0x1c>
ffffffffc0203914:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc0203916:	00848c63          	beq	s1,s0,ffffffffc020392e <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020391a:	ff043603          	ld	a2,-16(s0)
ffffffffc020391e:	fe843583          	ld	a1,-24(s0)
ffffffffc0203922:	854a                	mv	a0,s2
ffffffffc0203924:	93bfe0ef          	jal	ra,ffffffffc020225e <exit_range>
ffffffffc0203928:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc020392a:	fe8498e3          	bne	s1,s0,ffffffffc020391a <exit_mmap+0x36>
    }
}
ffffffffc020392e:	60e2                	ld	ra,24(sp)
ffffffffc0203930:	6442                	ld	s0,16(sp)
ffffffffc0203932:	64a2                	ld	s1,8(sp)
ffffffffc0203934:	6902                	ld	s2,0(sp)
ffffffffc0203936:	6105                	addi	sp,sp,32
ffffffffc0203938:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc020393a:	00004697          	auipc	a3,0x4
ffffffffc020393e:	9fe68693          	addi	a3,a3,-1538 # ffffffffc0207338 <default_pmm_manager+0x860>
ffffffffc0203942:	00003617          	auipc	a2,0x3
ffffffffc0203946:	de660613          	addi	a2,a2,-538 # ffffffffc0206728 <commands+0x828>
ffffffffc020394a:	0e800593          	li	a1,232
ffffffffc020394e:	00004517          	auipc	a0,0x4
ffffffffc0203952:	93250513          	addi	a0,a0,-1742 # ffffffffc0207280 <default_pmm_manager+0x7a8>
ffffffffc0203956:	b3dfc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc020395a <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc020395a:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020395c:	04000513          	li	a0,64
{
ffffffffc0203960:	fc06                	sd	ra,56(sp)
ffffffffc0203962:	f822                	sd	s0,48(sp)
ffffffffc0203964:	f426                	sd	s1,40(sp)
ffffffffc0203966:	f04a                	sd	s2,32(sp)
ffffffffc0203968:	ec4e                	sd	s3,24(sp)
ffffffffc020396a:	e852                	sd	s4,16(sp)
ffffffffc020396c:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020396e:	a98fe0ef          	jal	ra,ffffffffc0201c06 <kmalloc>
    if (mm != NULL)
ffffffffc0203972:	2e050663          	beqz	a0,ffffffffc0203c5e <vmm_init+0x304>
ffffffffc0203976:	84aa                	mv	s1,a0
    elm->prev = elm->next = elm;
ffffffffc0203978:	e508                	sd	a0,8(a0)
ffffffffc020397a:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc020397c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203980:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203984:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0203988:	02053423          	sd	zero,40(a0)
ffffffffc020398c:	02052823          	sw	zero,48(a0)
ffffffffc0203990:	02053c23          	sd	zero,56(a0)
ffffffffc0203994:	03200413          	li	s0,50
ffffffffc0203998:	a811                	j	ffffffffc02039ac <vmm_init+0x52>
        vma->vm_start = vm_start;
ffffffffc020399a:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc020399c:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020399e:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
ffffffffc02039a2:	146d                	addi	s0,s0,-5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02039a4:	8526                	mv	a0,s1
ffffffffc02039a6:	cd3ff0ef          	jal	ra,ffffffffc0203678 <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc02039aa:	c80d                	beqz	s0,ffffffffc02039dc <vmm_init+0x82>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02039ac:	03000513          	li	a0,48
ffffffffc02039b0:	a56fe0ef          	jal	ra,ffffffffc0201c06 <kmalloc>
ffffffffc02039b4:	85aa                	mv	a1,a0
ffffffffc02039b6:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc02039ba:	f165                	bnez	a0,ffffffffc020399a <vmm_init+0x40>
        assert(vma != NULL);
ffffffffc02039bc:	00004697          	auipc	a3,0x4
ffffffffc02039c0:	b1468693          	addi	a3,a3,-1260 # ffffffffc02074d0 <default_pmm_manager+0x9f8>
ffffffffc02039c4:	00003617          	auipc	a2,0x3
ffffffffc02039c8:	d6460613          	addi	a2,a2,-668 # ffffffffc0206728 <commands+0x828>
ffffffffc02039cc:	12c00593          	li	a1,300
ffffffffc02039d0:	00004517          	auipc	a0,0x4
ffffffffc02039d4:	8b050513          	addi	a0,a0,-1872 # ffffffffc0207280 <default_pmm_manager+0x7a8>
ffffffffc02039d8:	abbfc0ef          	jal	ra,ffffffffc0200492 <__panic>
ffffffffc02039dc:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc02039e0:	1f900913          	li	s2,505
ffffffffc02039e4:	a819                	j	ffffffffc02039fa <vmm_init+0xa0>
        vma->vm_start = vm_start;
ffffffffc02039e6:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02039e8:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02039ea:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++)
ffffffffc02039ee:	0415                	addi	s0,s0,5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02039f0:	8526                	mv	a0,s1
ffffffffc02039f2:	c87ff0ef          	jal	ra,ffffffffc0203678 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc02039f6:	03240a63          	beq	s0,s2,ffffffffc0203a2a <vmm_init+0xd0>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02039fa:	03000513          	li	a0,48
ffffffffc02039fe:	a08fe0ef          	jal	ra,ffffffffc0201c06 <kmalloc>
ffffffffc0203a02:	85aa                	mv	a1,a0
ffffffffc0203a04:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0203a08:	fd79                	bnez	a0,ffffffffc02039e6 <vmm_init+0x8c>
        assert(vma != NULL);
ffffffffc0203a0a:	00004697          	auipc	a3,0x4
ffffffffc0203a0e:	ac668693          	addi	a3,a3,-1338 # ffffffffc02074d0 <default_pmm_manager+0x9f8>
ffffffffc0203a12:	00003617          	auipc	a2,0x3
ffffffffc0203a16:	d1660613          	addi	a2,a2,-746 # ffffffffc0206728 <commands+0x828>
ffffffffc0203a1a:	13300593          	li	a1,307
ffffffffc0203a1e:	00004517          	auipc	a0,0x4
ffffffffc0203a22:	86250513          	addi	a0,a0,-1950 # ffffffffc0207280 <default_pmm_manager+0x7a8>
ffffffffc0203a26:	a6dfc0ef          	jal	ra,ffffffffc0200492 <__panic>
    return listelm->next;
ffffffffc0203a2a:	649c                	ld	a5,8(s1)
ffffffffc0203a2c:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0203a2e:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0203a32:	16f48663          	beq	s1,a5,ffffffffc0203b9e <vmm_init+0x244>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203a36:	fe87b603          	ld	a2,-24(a5) # ffffffffffffefe8 <end+0x3fd2c7f8>
ffffffffc0203a3a:	ffe70693          	addi	a3,a4,-2
ffffffffc0203a3e:	10d61063          	bne	a2,a3,ffffffffc0203b3e <vmm_init+0x1e4>
ffffffffc0203a42:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203a46:	0ed71c63          	bne	a4,a3,ffffffffc0203b3e <vmm_init+0x1e4>
    for (i = 1; i <= step2; i++)
ffffffffc0203a4a:	0715                	addi	a4,a4,5
ffffffffc0203a4c:	679c                	ld	a5,8(a5)
ffffffffc0203a4e:	feb712e3          	bne	a4,a1,ffffffffc0203a32 <vmm_init+0xd8>
ffffffffc0203a52:	4a1d                	li	s4,7
ffffffffc0203a54:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203a56:	1f900a93          	li	s5,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203a5a:	85a2                	mv	a1,s0
ffffffffc0203a5c:	8526                	mv	a0,s1
ffffffffc0203a5e:	bdbff0ef          	jal	ra,ffffffffc0203638 <find_vma>
ffffffffc0203a62:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0203a64:	16050d63          	beqz	a0,ffffffffc0203bde <vmm_init+0x284>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0203a68:	00140593          	addi	a1,s0,1
ffffffffc0203a6c:	8526                	mv	a0,s1
ffffffffc0203a6e:	bcbff0ef          	jal	ra,ffffffffc0203638 <find_vma>
ffffffffc0203a72:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203a74:	14050563          	beqz	a0,ffffffffc0203bbe <vmm_init+0x264>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0203a78:	85d2                	mv	a1,s4
ffffffffc0203a7a:	8526                	mv	a0,s1
ffffffffc0203a7c:	bbdff0ef          	jal	ra,ffffffffc0203638 <find_vma>
        assert(vma3 == NULL);
ffffffffc0203a80:	16051f63          	bnez	a0,ffffffffc0203bfe <vmm_init+0x2a4>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0203a84:	00340593          	addi	a1,s0,3
ffffffffc0203a88:	8526                	mv	a0,s1
ffffffffc0203a8a:	bafff0ef          	jal	ra,ffffffffc0203638 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203a8e:	1a051863          	bnez	a0,ffffffffc0203c3e <vmm_init+0x2e4>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0203a92:	00440593          	addi	a1,s0,4
ffffffffc0203a96:	8526                	mv	a0,s1
ffffffffc0203a98:	ba1ff0ef          	jal	ra,ffffffffc0203638 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203a9c:	18051163          	bnez	a0,ffffffffc0203c1e <vmm_init+0x2c4>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203aa0:	00893783          	ld	a5,8(s2)
ffffffffc0203aa4:	0a879d63          	bne	a5,s0,ffffffffc0203b5e <vmm_init+0x204>
ffffffffc0203aa8:	01093783          	ld	a5,16(s2)
ffffffffc0203aac:	0b479963          	bne	a5,s4,ffffffffc0203b5e <vmm_init+0x204>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203ab0:	0089b783          	ld	a5,8(s3)
ffffffffc0203ab4:	0c879563          	bne	a5,s0,ffffffffc0203b7e <vmm_init+0x224>
ffffffffc0203ab8:	0109b783          	ld	a5,16(s3)
ffffffffc0203abc:	0d479163          	bne	a5,s4,ffffffffc0203b7e <vmm_init+0x224>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203ac0:	0415                	addi	s0,s0,5
ffffffffc0203ac2:	0a15                	addi	s4,s4,5
ffffffffc0203ac4:	f9541be3          	bne	s0,s5,ffffffffc0203a5a <vmm_init+0x100>
ffffffffc0203ac8:	4411                	li	s0,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0203aca:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0203acc:	85a2                	mv	a1,s0
ffffffffc0203ace:	8526                	mv	a0,s1
ffffffffc0203ad0:	b69ff0ef          	jal	ra,ffffffffc0203638 <find_vma>
ffffffffc0203ad4:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL)
ffffffffc0203ad8:	c90d                	beqz	a0,ffffffffc0203b0a <vmm_init+0x1b0>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0203ada:	6914                	ld	a3,16(a0)
ffffffffc0203adc:	6510                	ld	a2,8(a0)
ffffffffc0203ade:	00004517          	auipc	a0,0x4
ffffffffc0203ae2:	97a50513          	addi	a0,a0,-1670 # ffffffffc0207458 <default_pmm_manager+0x980>
ffffffffc0203ae6:	eb2fc0ef          	jal	ra,ffffffffc0200198 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203aea:	00004697          	auipc	a3,0x4
ffffffffc0203aee:	99668693          	addi	a3,a3,-1642 # ffffffffc0207480 <default_pmm_manager+0x9a8>
ffffffffc0203af2:	00003617          	auipc	a2,0x3
ffffffffc0203af6:	c3660613          	addi	a2,a2,-970 # ffffffffc0206728 <commands+0x828>
ffffffffc0203afa:	15900593          	li	a1,345
ffffffffc0203afe:	00003517          	auipc	a0,0x3
ffffffffc0203b02:	78250513          	addi	a0,a0,1922 # ffffffffc0207280 <default_pmm_manager+0x7a8>
ffffffffc0203b06:	98dfc0ef          	jal	ra,ffffffffc0200492 <__panic>
    for (i = 4; i >= 0; i--)
ffffffffc0203b0a:	147d                	addi	s0,s0,-1
ffffffffc0203b0c:	fd2410e3          	bne	s0,s2,ffffffffc0203acc <vmm_init+0x172>
    }

    mm_destroy(mm);
ffffffffc0203b10:	8526                	mv	a0,s1
ffffffffc0203b12:	c37ff0ef          	jal	ra,ffffffffc0203748 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203b16:	00004517          	auipc	a0,0x4
ffffffffc0203b1a:	98250513          	addi	a0,a0,-1662 # ffffffffc0207498 <default_pmm_manager+0x9c0>
ffffffffc0203b1e:	e7afc0ef          	jal	ra,ffffffffc0200198 <cprintf>
}
ffffffffc0203b22:	7442                	ld	s0,48(sp)
ffffffffc0203b24:	70e2                	ld	ra,56(sp)
ffffffffc0203b26:	74a2                	ld	s1,40(sp)
ffffffffc0203b28:	7902                	ld	s2,32(sp)
ffffffffc0203b2a:	69e2                	ld	s3,24(sp)
ffffffffc0203b2c:	6a42                	ld	s4,16(sp)
ffffffffc0203b2e:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203b30:	00004517          	auipc	a0,0x4
ffffffffc0203b34:	98850513          	addi	a0,a0,-1656 # ffffffffc02074b8 <default_pmm_manager+0x9e0>
}
ffffffffc0203b38:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203b3a:	e5efc06f          	j	ffffffffc0200198 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203b3e:	00004697          	auipc	a3,0x4
ffffffffc0203b42:	83268693          	addi	a3,a3,-1998 # ffffffffc0207370 <default_pmm_manager+0x898>
ffffffffc0203b46:	00003617          	auipc	a2,0x3
ffffffffc0203b4a:	be260613          	addi	a2,a2,-1054 # ffffffffc0206728 <commands+0x828>
ffffffffc0203b4e:	13d00593          	li	a1,317
ffffffffc0203b52:	00003517          	auipc	a0,0x3
ffffffffc0203b56:	72e50513          	addi	a0,a0,1838 # ffffffffc0207280 <default_pmm_manager+0x7a8>
ffffffffc0203b5a:	939fc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203b5e:	00004697          	auipc	a3,0x4
ffffffffc0203b62:	89a68693          	addi	a3,a3,-1894 # ffffffffc02073f8 <default_pmm_manager+0x920>
ffffffffc0203b66:	00003617          	auipc	a2,0x3
ffffffffc0203b6a:	bc260613          	addi	a2,a2,-1086 # ffffffffc0206728 <commands+0x828>
ffffffffc0203b6e:	14e00593          	li	a1,334
ffffffffc0203b72:	00003517          	auipc	a0,0x3
ffffffffc0203b76:	70e50513          	addi	a0,a0,1806 # ffffffffc0207280 <default_pmm_manager+0x7a8>
ffffffffc0203b7a:	919fc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203b7e:	00004697          	auipc	a3,0x4
ffffffffc0203b82:	8aa68693          	addi	a3,a3,-1878 # ffffffffc0207428 <default_pmm_manager+0x950>
ffffffffc0203b86:	00003617          	auipc	a2,0x3
ffffffffc0203b8a:	ba260613          	addi	a2,a2,-1118 # ffffffffc0206728 <commands+0x828>
ffffffffc0203b8e:	14f00593          	li	a1,335
ffffffffc0203b92:	00003517          	auipc	a0,0x3
ffffffffc0203b96:	6ee50513          	addi	a0,a0,1774 # ffffffffc0207280 <default_pmm_manager+0x7a8>
ffffffffc0203b9a:	8f9fc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203b9e:	00003697          	auipc	a3,0x3
ffffffffc0203ba2:	7ba68693          	addi	a3,a3,1978 # ffffffffc0207358 <default_pmm_manager+0x880>
ffffffffc0203ba6:	00003617          	auipc	a2,0x3
ffffffffc0203baa:	b8260613          	addi	a2,a2,-1150 # ffffffffc0206728 <commands+0x828>
ffffffffc0203bae:	13b00593          	li	a1,315
ffffffffc0203bb2:	00003517          	auipc	a0,0x3
ffffffffc0203bb6:	6ce50513          	addi	a0,a0,1742 # ffffffffc0207280 <default_pmm_manager+0x7a8>
ffffffffc0203bba:	8d9fc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(vma2 != NULL);
ffffffffc0203bbe:	00003697          	auipc	a3,0x3
ffffffffc0203bc2:	7fa68693          	addi	a3,a3,2042 # ffffffffc02073b8 <default_pmm_manager+0x8e0>
ffffffffc0203bc6:	00003617          	auipc	a2,0x3
ffffffffc0203bca:	b6260613          	addi	a2,a2,-1182 # ffffffffc0206728 <commands+0x828>
ffffffffc0203bce:	14600593          	li	a1,326
ffffffffc0203bd2:	00003517          	auipc	a0,0x3
ffffffffc0203bd6:	6ae50513          	addi	a0,a0,1710 # ffffffffc0207280 <default_pmm_manager+0x7a8>
ffffffffc0203bda:	8b9fc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(vma1 != NULL);
ffffffffc0203bde:	00003697          	auipc	a3,0x3
ffffffffc0203be2:	7ca68693          	addi	a3,a3,1994 # ffffffffc02073a8 <default_pmm_manager+0x8d0>
ffffffffc0203be6:	00003617          	auipc	a2,0x3
ffffffffc0203bea:	b4260613          	addi	a2,a2,-1214 # ffffffffc0206728 <commands+0x828>
ffffffffc0203bee:	14400593          	li	a1,324
ffffffffc0203bf2:	00003517          	auipc	a0,0x3
ffffffffc0203bf6:	68e50513          	addi	a0,a0,1678 # ffffffffc0207280 <default_pmm_manager+0x7a8>
ffffffffc0203bfa:	899fc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(vma3 == NULL);
ffffffffc0203bfe:	00003697          	auipc	a3,0x3
ffffffffc0203c02:	7ca68693          	addi	a3,a3,1994 # ffffffffc02073c8 <default_pmm_manager+0x8f0>
ffffffffc0203c06:	00003617          	auipc	a2,0x3
ffffffffc0203c0a:	b2260613          	addi	a2,a2,-1246 # ffffffffc0206728 <commands+0x828>
ffffffffc0203c0e:	14800593          	li	a1,328
ffffffffc0203c12:	00003517          	auipc	a0,0x3
ffffffffc0203c16:	66e50513          	addi	a0,a0,1646 # ffffffffc0207280 <default_pmm_manager+0x7a8>
ffffffffc0203c1a:	879fc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(vma5 == NULL);
ffffffffc0203c1e:	00003697          	auipc	a3,0x3
ffffffffc0203c22:	7ca68693          	addi	a3,a3,1994 # ffffffffc02073e8 <default_pmm_manager+0x910>
ffffffffc0203c26:	00003617          	auipc	a2,0x3
ffffffffc0203c2a:	b0260613          	addi	a2,a2,-1278 # ffffffffc0206728 <commands+0x828>
ffffffffc0203c2e:	14c00593          	li	a1,332
ffffffffc0203c32:	00003517          	auipc	a0,0x3
ffffffffc0203c36:	64e50513          	addi	a0,a0,1614 # ffffffffc0207280 <default_pmm_manager+0x7a8>
ffffffffc0203c3a:	859fc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(vma4 == NULL);
ffffffffc0203c3e:	00003697          	auipc	a3,0x3
ffffffffc0203c42:	79a68693          	addi	a3,a3,1946 # ffffffffc02073d8 <default_pmm_manager+0x900>
ffffffffc0203c46:	00003617          	auipc	a2,0x3
ffffffffc0203c4a:	ae260613          	addi	a2,a2,-1310 # ffffffffc0206728 <commands+0x828>
ffffffffc0203c4e:	14a00593          	li	a1,330
ffffffffc0203c52:	00003517          	auipc	a0,0x3
ffffffffc0203c56:	62e50513          	addi	a0,a0,1582 # ffffffffc0207280 <default_pmm_manager+0x7a8>
ffffffffc0203c5a:	839fc0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(mm != NULL);
ffffffffc0203c5e:	00003697          	auipc	a3,0x3
ffffffffc0203c62:	6aa68693          	addi	a3,a3,1706 # ffffffffc0207308 <default_pmm_manager+0x830>
ffffffffc0203c66:	00003617          	auipc	a2,0x3
ffffffffc0203c6a:	ac260613          	addi	a2,a2,-1342 # ffffffffc0206728 <commands+0x828>
ffffffffc0203c6e:	12400593          	li	a1,292
ffffffffc0203c72:	00003517          	auipc	a0,0x3
ffffffffc0203c76:	60e50513          	addi	a0,a0,1550 # ffffffffc0207280 <default_pmm_manager+0x7a8>
ffffffffc0203c7a:	819fc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0203c7e <user_mem_check>:
}
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc0203c7e:	7179                	addi	sp,sp,-48
ffffffffc0203c80:	f022                	sd	s0,32(sp)
ffffffffc0203c82:	f406                	sd	ra,40(sp)
ffffffffc0203c84:	ec26                	sd	s1,24(sp)
ffffffffc0203c86:	e84a                	sd	s2,16(sp)
ffffffffc0203c88:	e44e                	sd	s3,8(sp)
ffffffffc0203c8a:	e052                	sd	s4,0(sp)
ffffffffc0203c8c:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc0203c8e:	c135                	beqz	a0,ffffffffc0203cf2 <user_mem_check+0x74>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc0203c90:	002007b7          	lui	a5,0x200
ffffffffc0203c94:	04f5e663          	bltu	a1,a5,ffffffffc0203ce0 <user_mem_check+0x62>
ffffffffc0203c98:	00c584b3          	add	s1,a1,a2
ffffffffc0203c9c:	0495f263          	bgeu	a1,s1,ffffffffc0203ce0 <user_mem_check+0x62>
ffffffffc0203ca0:	4785                	li	a5,1
ffffffffc0203ca2:	07fe                	slli	a5,a5,0x1f
ffffffffc0203ca4:	0297ee63          	bltu	a5,s1,ffffffffc0203ce0 <user_mem_check+0x62>
ffffffffc0203ca8:	892a                	mv	s2,a0
ffffffffc0203caa:	89b6                	mv	s3,a3
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203cac:	6a05                	lui	s4,0x1
ffffffffc0203cae:	a821                	j	ffffffffc0203cc6 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203cb0:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203cb4:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203cb6:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203cb8:	c685                	beqz	a3,ffffffffc0203ce0 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203cba:	c399                	beqz	a5,ffffffffc0203cc0 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203cbc:	02e46263          	bltu	s0,a4,ffffffffc0203ce0 <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0203cc0:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc0203cc2:	04947663          	bgeu	s0,s1,ffffffffc0203d0e <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc0203cc6:	85a2                	mv	a1,s0
ffffffffc0203cc8:	854a                	mv	a0,s2
ffffffffc0203cca:	96fff0ef          	jal	ra,ffffffffc0203638 <find_vma>
ffffffffc0203cce:	c909                	beqz	a0,ffffffffc0203ce0 <user_mem_check+0x62>
ffffffffc0203cd0:	6518                	ld	a4,8(a0)
ffffffffc0203cd2:	00e46763          	bltu	s0,a4,ffffffffc0203ce0 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203cd6:	4d1c                	lw	a5,24(a0)
ffffffffc0203cd8:	fc099ce3          	bnez	s3,ffffffffc0203cb0 <user_mem_check+0x32>
ffffffffc0203cdc:	8b85                	andi	a5,a5,1
ffffffffc0203cde:	f3ed                	bnez	a5,ffffffffc0203cc0 <user_mem_check+0x42>
            return 0;
ffffffffc0203ce0:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0203ce2:	70a2                	ld	ra,40(sp)
ffffffffc0203ce4:	7402                	ld	s0,32(sp)
ffffffffc0203ce6:	64e2                	ld	s1,24(sp)
ffffffffc0203ce8:	6942                	ld	s2,16(sp)
ffffffffc0203cea:	69a2                	ld	s3,8(sp)
ffffffffc0203cec:	6a02                	ld	s4,0(sp)
ffffffffc0203cee:	6145                	addi	sp,sp,48
ffffffffc0203cf0:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203cf2:	c02007b7          	lui	a5,0xc0200
ffffffffc0203cf6:	4501                	li	a0,0
ffffffffc0203cf8:	fef5e5e3          	bltu	a1,a5,ffffffffc0203ce2 <user_mem_check+0x64>
ffffffffc0203cfc:	962e                	add	a2,a2,a1
ffffffffc0203cfe:	fec5f2e3          	bgeu	a1,a2,ffffffffc0203ce2 <user_mem_check+0x64>
ffffffffc0203d02:	c8000537          	lui	a0,0xc8000
ffffffffc0203d06:	0505                	addi	a0,a0,1
ffffffffc0203d08:	00a63533          	sltu	a0,a2,a0
ffffffffc0203d0c:	bfd9                	j	ffffffffc0203ce2 <user_mem_check+0x64>
        return 1;
ffffffffc0203d0e:	4505                	li	a0,1
ffffffffc0203d10:	bfc9                	j	ffffffffc0203ce2 <user_mem_check+0x64>

ffffffffc0203d12 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0203d12:	8526                	mv	a0,s1
	jalr s0
ffffffffc0203d14:	9402                	jalr	s0

	jal do_exit
ffffffffc0203d16:	5b8000ef          	jal	ra,ffffffffc02042ce <do_exit>

ffffffffc0203d1a <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc0203d1a:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203d1c:	14800513          	li	a0,328
{
ffffffffc0203d20:	e022                	sd	s0,0(sp)
ffffffffc0203d22:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203d24:	ee3fd0ef          	jal	ra,ffffffffc0201c06 <kmalloc>
ffffffffc0203d28:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc0203d2a:	cd35                	beqz	a0,ffffffffc0203da6 <alloc_proc+0x8c>
         *       uint32_t flags;                             // Process flag
         *       char name[PROC_NAME_LEN + 1];               // Process name
         */

        /* 初始化一个新的进程控制块的最基本字段，不进行资源分配 */
        proc->state = PROC_UNINIT;        // 尚未进入就绪态
ffffffffc0203d2c:	57fd                	li	a5,-1
ffffffffc0203d2e:	1782                	slli	a5,a5,0x20
ffffffffc0203d30:	e11c                	sd	a5,0(a0)
        proc->runs = 0;                   // 运行次数计数器清零
        proc->kstack = 0;                 // 还未分配内核栈
        proc->need_resched = 0;           // 默认不请求调度
        proc->parent = NULL;              // 父进程待后续设置
        proc->mm = NULL;                  // 地址空间后续 copy/share
        memset(&proc->context, 0, sizeof(struct context)); // 确保首次 switch_to 有确定值
ffffffffc0203d32:	07000613          	li	a2,112
ffffffffc0203d36:	4581                	li	a1,0
        proc->runs = 0;                   // 运行次数计数器清零
ffffffffc0203d38:	00052423          	sw	zero,8(a0) # ffffffffc8000008 <end+0x7d2d818>
        proc->kstack = 0;                 // 还未分配内核栈
ffffffffc0203d3c:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;           // 默认不请求调度
ffffffffc0203d40:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;              // 父进程待后续设置
ffffffffc0203d44:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;                  // 地址空间后续 copy/share
ffffffffc0203d48:	02053423          	sd	zero,40(a0)
        memset(&proc->context, 0, sizeof(struct context)); // 确保首次 switch_to 有确定值
ffffffffc0203d4c:	03050513          	addi	a0,a0,48
ffffffffc0203d50:	71f010ef          	jal	ra,ffffffffc0205c6e <memset>
        proc->tf = NULL;                  // trapframe 等栈建立后 copy_thread 设置
        proc->pgdir = boot_pgdir_pa;      // 先使用内核页表基址
ffffffffc0203d54:	000cf797          	auipc	a5,0xcf
ffffffffc0203d58:	a3c7b783          	ld	a5,-1476(a5) # ffffffffc02d2790 <boot_pgdir_pa>
ffffffffc0203d5c:	f45c                	sd	a5,168(s0)
        proc->tf = NULL;                  // trapframe 等栈建立后 copy_thread 设置
ffffffffc0203d5e:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;                  // 初始无标志
ffffffffc0203d62:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, sizeof(proc->name)); // 进程名清零，后续 set_proc_name
ffffffffc0203d66:	4641                	li	a2,16
ffffffffc0203d68:	4581                	li	a1,0
ffffffffc0203d6a:	0b440513          	addi	a0,s0,180
ffffffffc0203d6e:	701010ef          	jal	ra,ffffffffc0205c6e <memset>
         *       skew_heap_entry_t lab6_run_pool;            // entry in the run pool (lab6 stride)
         *       uint32_t lab6_stride;                       // stride value (lab6 stride)
         *       uint32_t lab6_priority;                     // priority value (lab6 stride)
         */
        proc->rq = NULL;                  // 运行队列指针
        list_init(&proc->run_link);       // 初始化运行链表项
ffffffffc0203d72:	11040793          	addi	a5,s0,272
        proc->exit_code = 0;              // 退出码初始化为0
ffffffffc0203d76:	0e043423          	sd	zero,232(s0)
        proc->cptr = proc->yptr = proc->optr = NULL; // 进程关系指针初始化为NULL
ffffffffc0203d7a:	0e043823          	sd	zero,240(s0)
ffffffffc0203d7e:	0e043c23          	sd	zero,248(s0)
ffffffffc0203d82:	10043023          	sd	zero,256(s0)
        proc->rq = NULL;                  // 运行队列指针
ffffffffc0203d86:	10043423          	sd	zero,264(s0)
    elm->prev = elm->next = elm;
ffffffffc0203d8a:	10f43c23          	sd	a5,280(s0)
ffffffffc0203d8e:	10f43823          	sd	a5,272(s0)
        proc->time_slice = 0;             // 时间片初始化为0
ffffffffc0203d92:	12042023          	sw	zero,288(s0)
        proc->lab6_run_pool.left = NULL;  // Stride堆池左孩子
        proc->lab6_run_pool.right = NULL; // Stride堆池右孩子
        proc->lab6_run_pool.parent = NULL; // Stride堆池父节点
ffffffffc0203d96:	12043423          	sd	zero,296(s0)
        proc->lab6_run_pool.left = NULL;  // Stride堆池左孩子
ffffffffc0203d9a:	12043823          	sd	zero,304(s0)
        proc->lab6_run_pool.right = NULL; // Stride堆池右孩子
ffffffffc0203d9e:	12043c23          	sd	zero,312(s0)
        proc->lab6_stride = 0;            // Stride值初始化为0
ffffffffc0203da2:	14043023          	sd	zero,320(s0)
        proc->lab6_priority = 0;          // 优先级初始化为0
    }
    return proc;
}
ffffffffc0203da6:	60a2                	ld	ra,8(sp)
ffffffffc0203da8:	8522                	mv	a0,s0
ffffffffc0203daa:	6402                	ld	s0,0(sp)
ffffffffc0203dac:	0141                	addi	sp,sp,16
ffffffffc0203dae:	8082                	ret

ffffffffc0203db0 <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc0203db0:	000cf797          	auipc	a5,0xcf
ffffffffc0203db4:	a107b783          	ld	a5,-1520(a5) # ffffffffc02d27c0 <current>
ffffffffc0203db8:	73c8                	ld	a0,160(a5)
ffffffffc0203dba:	968fd06f          	j	ffffffffc0200f22 <forkrets>

ffffffffc0203dbe <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0203dbe:	6d14                	ld	a3,24(a0)
}

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm)
{
ffffffffc0203dc0:	1141                	addi	sp,sp,-16
ffffffffc0203dc2:	e406                	sd	ra,8(sp)
ffffffffc0203dc4:	c02007b7          	lui	a5,0xc0200
ffffffffc0203dc8:	02f6ee63          	bltu	a3,a5,ffffffffc0203e04 <put_pgdir+0x46>
ffffffffc0203dcc:	000cf517          	auipc	a0,0xcf
ffffffffc0203dd0:	9ec53503          	ld	a0,-1556(a0) # ffffffffc02d27b8 <va_pa_offset>
ffffffffc0203dd4:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage)
ffffffffc0203dd6:	82b1                	srli	a3,a3,0xc
ffffffffc0203dd8:	000cf797          	auipc	a5,0xcf
ffffffffc0203ddc:	9c87b783          	ld	a5,-1592(a5) # ffffffffc02d27a0 <npage>
ffffffffc0203de0:	02f6fe63          	bgeu	a3,a5,ffffffffc0203e1c <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203de4:	00004517          	auipc	a0,0x4
ffffffffc0203de8:	75453503          	ld	a0,1876(a0) # ffffffffc0208538 <nbase>
    free_page(kva2page(mm->pgdir));
}
ffffffffc0203dec:	60a2                	ld	ra,8(sp)
ffffffffc0203dee:	8e89                	sub	a3,a3,a0
ffffffffc0203df0:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0203df2:	000cf517          	auipc	a0,0xcf
ffffffffc0203df6:	9b653503          	ld	a0,-1610(a0) # ffffffffc02d27a8 <pages>
ffffffffc0203dfa:	4585                	li	a1,1
ffffffffc0203dfc:	9536                	add	a0,a0,a3
}
ffffffffc0203dfe:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0203e00:	822fe06f          	j	ffffffffc0201e22 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0203e04:	00003617          	auipc	a2,0x3
ffffffffc0203e08:	db460613          	addi	a2,a2,-588 # ffffffffc0206bb8 <default_pmm_manager+0xe0>
ffffffffc0203e0c:	07700593          	li	a1,119
ffffffffc0203e10:	00003517          	auipc	a0,0x3
ffffffffc0203e14:	d2850513          	addi	a0,a0,-728 # ffffffffc0206b38 <default_pmm_manager+0x60>
ffffffffc0203e18:	e7afc0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203e1c:	00003617          	auipc	a2,0x3
ffffffffc0203e20:	dc460613          	addi	a2,a2,-572 # ffffffffc0206be0 <default_pmm_manager+0x108>
ffffffffc0203e24:	06900593          	li	a1,105
ffffffffc0203e28:	00003517          	auipc	a0,0x3
ffffffffc0203e2c:	d1050513          	addi	a0,a0,-752 # ffffffffc0206b38 <default_pmm_manager+0x60>
ffffffffc0203e30:	e62fc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0203e34 <proc_run>:
{
ffffffffc0203e34:	7179                	addi	sp,sp,-48
ffffffffc0203e36:	f026                	sd	s1,32(sp)
    if (proc != current)
ffffffffc0203e38:	000cf497          	auipc	s1,0xcf
ffffffffc0203e3c:	98848493          	addi	s1,s1,-1656 # ffffffffc02d27c0 <current>
ffffffffc0203e40:	6098                	ld	a4,0(s1)
{
ffffffffc0203e42:	f406                	sd	ra,40(sp)
ffffffffc0203e44:	ec4a                	sd	s2,24(sp)
    if (proc != current)
ffffffffc0203e46:	02a70763          	beq	a4,a0,ffffffffc0203e74 <proc_run+0x40>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203e4a:	100027f3          	csrr	a5,sstatus
ffffffffc0203e4e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203e50:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203e52:	ef85                	bnez	a5,ffffffffc0203e8a <proc_run+0x56>
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned long pgdir)
{
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc0203e54:	755c                	ld	a5,168(a0)
ffffffffc0203e56:	56fd                	li	a3,-1
ffffffffc0203e58:	16fe                	slli	a3,a3,0x3f
ffffffffc0203e5a:	83b1                	srli	a5,a5,0xc
            current = proc;
ffffffffc0203e5c:	e088                	sd	a0,0(s1)
ffffffffc0203e5e:	8fd5                	or	a5,a5,a3
ffffffffc0203e60:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(proc->context));
ffffffffc0203e64:	03050593          	addi	a1,a0,48
ffffffffc0203e68:	03070513          	addi	a0,a4,48
ffffffffc0203e6c:	102010ef          	jal	ra,ffffffffc0204f6e <switch_to>
    if (flag)
ffffffffc0203e70:	00091763          	bnez	s2,ffffffffc0203e7e <proc_run+0x4a>
}
ffffffffc0203e74:	70a2                	ld	ra,40(sp)
ffffffffc0203e76:	7482                	ld	s1,32(sp)
ffffffffc0203e78:	6962                	ld	s2,24(sp)
ffffffffc0203e7a:	6145                	addi	sp,sp,48
ffffffffc0203e7c:	8082                	ret
ffffffffc0203e7e:	70a2                	ld	ra,40(sp)
ffffffffc0203e80:	7482                	ld	s1,32(sp)
ffffffffc0203e82:	6962                	ld	s2,24(sp)
ffffffffc0203e84:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0203e86:	b23fc06f          	j	ffffffffc02009a8 <intr_enable>
ffffffffc0203e8a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203e8c:	b23fc0ef          	jal	ra,ffffffffc02009ae <intr_disable>
            struct proc_struct *prev = current;
ffffffffc0203e90:	6098                	ld	a4,0(s1)
        return 1;
ffffffffc0203e92:	6522                	ld	a0,8(sp)
ffffffffc0203e94:	4905                	li	s2,1
ffffffffc0203e96:	bf7d                	j	ffffffffc0203e54 <proc_run+0x20>

ffffffffc0203e98 <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf)
{
ffffffffc0203e98:	7119                	addi	sp,sp,-128
ffffffffc0203e9a:	f4a6                	sd	s1,104(sp)
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS)
ffffffffc0203e9c:	000cf497          	auipc	s1,0xcf
ffffffffc0203ea0:	93c48493          	addi	s1,s1,-1732 # ffffffffc02d27d8 <nr_process>
ffffffffc0203ea4:	4098                	lw	a4,0(s1)
{
ffffffffc0203ea6:	fc86                	sd	ra,120(sp)
ffffffffc0203ea8:	f8a2                	sd	s0,112(sp)
ffffffffc0203eaa:	f0ca                	sd	s2,96(sp)
ffffffffc0203eac:	ecce                	sd	s3,88(sp)
ffffffffc0203eae:	e8d2                	sd	s4,80(sp)
ffffffffc0203eb0:	e4d6                	sd	s5,72(sp)
ffffffffc0203eb2:	e0da                	sd	s6,64(sp)
ffffffffc0203eb4:	fc5e                	sd	s7,56(sp)
ffffffffc0203eb6:	f862                	sd	s8,48(sp)
ffffffffc0203eb8:	f466                	sd	s9,40(sp)
ffffffffc0203eba:	f06a                	sd	s10,32(sp)
ffffffffc0203ebc:	ec6e                	sd	s11,24(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0203ebe:	6785                	lui	a5,0x1
ffffffffc0203ec0:	30f75463          	bge	a4,a5,ffffffffc02041c8 <do_fork+0x330>
ffffffffc0203ec4:	8a2a                	mv	s4,a0
ffffffffc0203ec6:	892e                	mv	s2,a1
ffffffffc0203ec8:	89b2                	mv	s3,a2
     *    set_links:  set the relation links of process.  ALSO SEE: remove_links:  lean the relation links of process
     *    -------------------
     *    update step 1: set child proc's parent to current process, make sure current process's wait_state is 0
     *    update step 5: insert proc_struct into hash_list && proc_list, set the relation links of process
     */
    if ((proc = alloc_proc()) == NULL)
ffffffffc0203eca:	e51ff0ef          	jal	ra,ffffffffc0203d1a <alloc_proc>
ffffffffc0203ece:	842a                	mv	s0,a0
ffffffffc0203ed0:	30050363          	beqz	a0,ffffffffc02041d6 <do_fork+0x33e>
    {
        goto fork_out;
    }

    proc->parent = current;
ffffffffc0203ed4:	000cfb97          	auipc	s7,0xcf
ffffffffc0203ed8:	8ecb8b93          	addi	s7,s7,-1812 # ffffffffc02d27c0 <current>
ffffffffc0203edc:	000bb783          	ld	a5,0(s7)
    // LAB5: 确保父进程的wait_state为0
    assert(current->wait_state == 0);
ffffffffc0203ee0:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8e64>
    proc->parent = current;
ffffffffc0203ee4:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc0203ee6:	2e071f63          	bnez	a4,ffffffffc02041e4 <do_fork+0x34c>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0203eea:	4509                	li	a0,2
ffffffffc0203eec:	ef9fd0ef          	jal	ra,ffffffffc0201de4 <alloc_pages>
    if (page != NULL)
ffffffffc0203ef0:	2c050a63          	beqz	a0,ffffffffc02041c4 <do_fork+0x32c>
    return page - pages + nbase;
ffffffffc0203ef4:	000cfc97          	auipc	s9,0xcf
ffffffffc0203ef8:	8b4c8c93          	addi	s9,s9,-1868 # ffffffffc02d27a8 <pages>
ffffffffc0203efc:	000cb683          	ld	a3,0(s9)
ffffffffc0203f00:	00004a97          	auipc	s5,0x4
ffffffffc0203f04:	638a8a93          	addi	s5,s5,1592 # ffffffffc0208538 <nbase>
ffffffffc0203f08:	000ab703          	ld	a4,0(s5)
ffffffffc0203f0c:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0203f10:	000cfd17          	auipc	s10,0xcf
ffffffffc0203f14:	890d0d13          	addi	s10,s10,-1904 # ffffffffc02d27a0 <npage>
    return page - pages + nbase;
ffffffffc0203f18:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0203f1a:	5b7d                	li	s6,-1
ffffffffc0203f1c:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc0203f20:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0203f22:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0203f26:	0166f633          	and	a2,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0203f2a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203f2c:	2cf67c63          	bgeu	a2,a5,ffffffffc0204204 <do_fork+0x36c>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0203f30:	000bb603          	ld	a2,0(s7)
ffffffffc0203f34:	000cfd97          	auipc	s11,0xcf
ffffffffc0203f38:	884d8d93          	addi	s11,s11,-1916 # ffffffffc02d27b8 <va_pa_offset>
ffffffffc0203f3c:	000db783          	ld	a5,0(s11)
ffffffffc0203f40:	02863b83          	ld	s7,40(a2)
ffffffffc0203f44:	e43a                	sd	a4,8(sp)
ffffffffc0203f46:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0203f48:	e814                	sd	a3,16(s0)
    if (oldmm == NULL)
ffffffffc0203f4a:	020b8863          	beqz	s7,ffffffffc0203f7a <do_fork+0xe2>
    if (clone_flags & CLONE_VM)
ffffffffc0203f4e:	100a7a13          	andi	s4,s4,256
ffffffffc0203f52:	180a0963          	beqz	s4,ffffffffc02040e4 <do_fork+0x24c>
}

static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
ffffffffc0203f56:	030ba703          	lw	a4,48(s7)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0203f5a:	018bb783          	ld	a5,24(s7)
ffffffffc0203f5e:	c02006b7          	lui	a3,0xc0200
ffffffffc0203f62:	2705                	addiw	a4,a4,1
ffffffffc0203f64:	02eba823          	sw	a4,48(s7)
    proc->mm = mm;
ffffffffc0203f68:	03743423          	sd	s7,40(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0203f6c:	2ed7ec63          	bltu	a5,a3,ffffffffc0204264 <do_fork+0x3cc>
ffffffffc0203f70:	000db703          	ld	a4,0(s11)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0203f74:	6814                	ld	a3,16(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0203f76:	8f99                	sub	a5,a5,a4
ffffffffc0203f78:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0203f7a:	6789                	lui	a5,0x2
ffffffffc0203f7c:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x8070>
ffffffffc0203f80:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0203f82:	864e                	mv	a2,s3
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0203f84:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0203f86:	87b6                	mv	a5,a3
ffffffffc0203f88:	12098893          	addi	a7,s3,288
ffffffffc0203f8c:	00063803          	ld	a6,0(a2)
ffffffffc0203f90:	6608                	ld	a0,8(a2)
ffffffffc0203f92:	6a0c                	ld	a1,16(a2)
ffffffffc0203f94:	6e18                	ld	a4,24(a2)
ffffffffc0203f96:	0107b023          	sd	a6,0(a5)
ffffffffc0203f9a:	e788                	sd	a0,8(a5)
ffffffffc0203f9c:	eb8c                	sd	a1,16(a5)
ffffffffc0203f9e:	ef98                	sd	a4,24(a5)
ffffffffc0203fa0:	02060613          	addi	a2,a2,32
ffffffffc0203fa4:	02078793          	addi	a5,a5,32
ffffffffc0203fa8:	ff1612e3          	bne	a2,a7,ffffffffc0203f8c <do_fork+0xf4>
    proc->tf->gpr.a0 = 0;
ffffffffc0203fac:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x6>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0203fb0:	1c090463          	beqz	s2,ffffffffc0204178 <do_fork+0x2e0>
    if (++last_pid >= MAX_PID)
ffffffffc0203fb4:	000ca817          	auipc	a6,0xca
ffffffffc0203fb8:	34c80813          	addi	a6,a6,844 # ffffffffc02ce300 <last_pid.1>
ffffffffc0203fbc:	00082783          	lw	a5,0(a6)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0203fc0:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0203fc4:	00000717          	auipc	a4,0x0
ffffffffc0203fc8:	dec70713          	addi	a4,a4,-532 # ffffffffc0203db0 <forkret>
    if (++last_pid >= MAX_PID)
ffffffffc0203fcc:	0017851b          	addiw	a0,a5,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0203fd0:	f818                	sd	a4,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0203fd2:	fc14                	sd	a3,56(s0)
    if (++last_pid >= MAX_PID)
ffffffffc0203fd4:	00a82023          	sw	a0,0(a6)
ffffffffc0203fd8:	6789                	lui	a5,0x2
ffffffffc0203fda:	08f55e63          	bge	a0,a5,ffffffffc0204076 <do_fork+0x1de>
    if (last_pid >= next_safe)
ffffffffc0203fde:	000ca317          	auipc	t1,0xca
ffffffffc0203fe2:	32630313          	addi	t1,t1,806 # ffffffffc02ce304 <next_safe.0>
ffffffffc0203fe6:	00032783          	lw	a5,0(t1)
ffffffffc0203fea:	000ce917          	auipc	s2,0xce
ffffffffc0203fee:	73690913          	addi	s2,s2,1846 # ffffffffc02d2720 <proc_list>
ffffffffc0203ff2:	08f55a63          	bge	a0,a5,ffffffffc0204086 <do_fork+0x1ee>
        goto bad_fork_cleanup_kstack;
    }

    copy_thread(proc, stack, tf);

    proc->pid = get_pid();
ffffffffc0203ff6:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0203ff8:	45a9                	li	a1,10
ffffffffc0203ffa:	2501                	sext.w	a0,a0
ffffffffc0203ffc:	7cc010ef          	jal	ra,ffffffffc02057c8 <hash32>
ffffffffc0204000:	02051793          	slli	a5,a0,0x20
ffffffffc0204004:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204008:	000ca797          	auipc	a5,0xca
ffffffffc020400c:	71878793          	addi	a5,a5,1816 # ffffffffc02ce720 <hash_list>
ffffffffc0204010:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204012:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204014:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204016:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc020401a:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc020401c:	00893603          	ld	a2,8(s2)
    prev->next = next->prev = elm;
ffffffffc0204020:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204022:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0204024:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc0204028:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc020402a:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc020402c:	e21c                	sd	a5,0(a2)
ffffffffc020402e:	00f93423          	sd	a5,8(s2)
    elm->next = next;
ffffffffc0204032:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc0204034:	0d243423          	sd	s2,200(s0)
    proc->yptr = NULL;
ffffffffc0204038:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc020403c:	10e43023          	sd	a4,256(s0)
ffffffffc0204040:	c311                	beqz	a4,ffffffffc0204044 <do_fork+0x1ac>
        proc->optr->yptr = proc;
ffffffffc0204042:	ff60                	sd	s0,248(a4)
    nr_process++;
ffffffffc0204044:	409c                	lw	a5,0(s1)
    proc->parent->cptr = proc;
ffffffffc0204046:	fae0                	sd	s0,240(a3)
    hash_proc(proc);
    // LAB5: 使用set_links来设置进程关系链表
    set_links(proc);

    wakeup_proc(proc);
ffffffffc0204048:	8522                	mv	a0,s0
    nr_process++;
ffffffffc020404a:	2785                	addiw	a5,a5,1
ffffffffc020404c:	c09c                	sw	a5,0(s1)
    wakeup_proc(proc);
ffffffffc020404e:	508010ef          	jal	ra,ffffffffc0205556 <wakeup_proc>

    ret = proc->pid;
ffffffffc0204052:	00442a03          	lw	s4,4(s0)
bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
ffffffffc0204056:	70e6                	ld	ra,120(sp)
ffffffffc0204058:	7446                	ld	s0,112(sp)
ffffffffc020405a:	74a6                	ld	s1,104(sp)
ffffffffc020405c:	7906                	ld	s2,96(sp)
ffffffffc020405e:	69e6                	ld	s3,88(sp)
ffffffffc0204060:	6aa6                	ld	s5,72(sp)
ffffffffc0204062:	6b06                	ld	s6,64(sp)
ffffffffc0204064:	7be2                	ld	s7,56(sp)
ffffffffc0204066:	7c42                	ld	s8,48(sp)
ffffffffc0204068:	7ca2                	ld	s9,40(sp)
ffffffffc020406a:	7d02                	ld	s10,32(sp)
ffffffffc020406c:	6de2                	ld	s11,24(sp)
ffffffffc020406e:	8552                	mv	a0,s4
ffffffffc0204070:	6a46                	ld	s4,80(sp)
ffffffffc0204072:	6109                	addi	sp,sp,128
ffffffffc0204074:	8082                	ret
        last_pid = 1;
ffffffffc0204076:	4785                	li	a5,1
ffffffffc0204078:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc020407c:	4505                	li	a0,1
ffffffffc020407e:	000ca317          	auipc	t1,0xca
ffffffffc0204082:	28630313          	addi	t1,t1,646 # ffffffffc02ce304 <next_safe.0>
    return listelm->next;
ffffffffc0204086:	000ce917          	auipc	s2,0xce
ffffffffc020408a:	69a90913          	addi	s2,s2,1690 # ffffffffc02d2720 <proc_list>
ffffffffc020408e:	00893e03          	ld	t3,8(s2)
        next_safe = MAX_PID;
ffffffffc0204092:	6789                	lui	a5,0x2
ffffffffc0204094:	00f32023          	sw	a5,0(t1)
ffffffffc0204098:	86aa                	mv	a3,a0
ffffffffc020409a:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc020409c:	6e89                	lui	t4,0x2
ffffffffc020409e:	132e0763          	beq	t3,s2,ffffffffc02041cc <do_fork+0x334>
ffffffffc02040a2:	88ae                	mv	a7,a1
ffffffffc02040a4:	87f2                	mv	a5,t3
ffffffffc02040a6:	6609                	lui	a2,0x2
ffffffffc02040a8:	a811                	j	ffffffffc02040bc <do_fork+0x224>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc02040aa:	00e6d663          	bge	a3,a4,ffffffffc02040b6 <do_fork+0x21e>
ffffffffc02040ae:	00c75463          	bge	a4,a2,ffffffffc02040b6 <do_fork+0x21e>
ffffffffc02040b2:	863a                	mv	a2,a4
ffffffffc02040b4:	4885                	li	a7,1
ffffffffc02040b6:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02040b8:	01278d63          	beq	a5,s2,ffffffffc02040d2 <do_fork+0x23a>
            if (proc->pid == last_pid)
ffffffffc02040bc:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x8014>
ffffffffc02040c0:	fed715e3          	bne	a4,a3,ffffffffc02040aa <do_fork+0x212>
                if (++last_pid >= next_safe)
ffffffffc02040c4:	2685                	addiw	a3,a3,1
ffffffffc02040c6:	0ec6da63          	bge	a3,a2,ffffffffc02041ba <do_fork+0x322>
ffffffffc02040ca:	679c                	ld	a5,8(a5)
ffffffffc02040cc:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc02040ce:	ff2797e3          	bne	a5,s2,ffffffffc02040bc <do_fork+0x224>
ffffffffc02040d2:	c581                	beqz	a1,ffffffffc02040da <do_fork+0x242>
ffffffffc02040d4:	00d82023          	sw	a3,0(a6)
ffffffffc02040d8:	8536                	mv	a0,a3
ffffffffc02040da:	f0088ee3          	beqz	a7,ffffffffc0203ff6 <do_fork+0x15e>
ffffffffc02040de:	00c32023          	sw	a2,0(t1)
ffffffffc02040e2:	bf11                	j	ffffffffc0203ff6 <do_fork+0x15e>
    if ((mm = mm_create()) == NULL)
ffffffffc02040e4:	d24ff0ef          	jal	ra,ffffffffc0203608 <mm_create>
ffffffffc02040e8:	8c2a                	mv	s8,a0
ffffffffc02040ea:	0e050b63          	beqz	a0,ffffffffc02041e0 <do_fork+0x348>
    if ((page = alloc_page()) == NULL)
ffffffffc02040ee:	4505                	li	a0,1
ffffffffc02040f0:	cf5fd0ef          	jal	ra,ffffffffc0201de4 <alloc_pages>
ffffffffc02040f4:	c541                	beqz	a0,ffffffffc020417c <do_fork+0x2e4>
    return page - pages + nbase;
ffffffffc02040f6:	000cb683          	ld	a3,0(s9)
ffffffffc02040fa:	6722                	ld	a4,8(sp)
    return KADDR(page2pa(page));
ffffffffc02040fc:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc0204100:	40d506b3          	sub	a3,a0,a3
ffffffffc0204104:	8699                	srai	a3,a3,0x6
ffffffffc0204106:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0204108:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc020410c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020410e:	0efb7b63          	bgeu	s6,a5,ffffffffc0204204 <do_fork+0x36c>
ffffffffc0204112:	000dba03          	ld	s4,0(s11)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204116:	6605                	lui	a2,0x1
ffffffffc0204118:	000ce597          	auipc	a1,0xce
ffffffffc020411c:	6805b583          	ld	a1,1664(a1) # ffffffffc02d2798 <boot_pgdir_va>
ffffffffc0204120:	9a36                	add	s4,s4,a3
ffffffffc0204122:	8552                	mv	a0,s4
ffffffffc0204124:	35d010ef          	jal	ra,ffffffffc0205c80 <memcpy>
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
ffffffffc0204128:	038b8b13          	addi	s6,s7,56
    mm->pgdir = pgdir;
ffffffffc020412c:	014c3c23          	sd	s4,24(s8)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204130:	4785                	li	a5,1
ffffffffc0204132:	40fb37af          	amoor.d	a5,a5,(s6)
}

static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))
ffffffffc0204136:	8b85                	andi	a5,a5,1
ffffffffc0204138:	4a05                	li	s4,1
ffffffffc020413a:	c799                	beqz	a5,ffffffffc0204148 <do_fork+0x2b0>
    {
        schedule();
ffffffffc020413c:	4cc010ef          	jal	ra,ffffffffc0205608 <schedule>
ffffffffc0204140:	414b37af          	amoor.d	a5,s4,(s6)
    while (!try_lock(lock))
ffffffffc0204144:	8b85                	andi	a5,a5,1
ffffffffc0204146:	fbfd                	bnez	a5,ffffffffc020413c <do_fork+0x2a4>
        ret = dup_mmap(mm, oldmm);
ffffffffc0204148:	85de                	mv	a1,s7
ffffffffc020414a:	8562                	mv	a0,s8
ffffffffc020414c:	efeff0ef          	jal	ra,ffffffffc020384a <dup_mmap>
ffffffffc0204150:	8a2a                	mv	s4,a0
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0204152:	57f9                	li	a5,-2
ffffffffc0204154:	60fb37af          	amoand.d	a5,a5,(s6)
ffffffffc0204158:	8b85                	andi	a5,a5,1
}

static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))
ffffffffc020415a:	0e078963          	beqz	a5,ffffffffc020424c <do_fork+0x3b4>
good_mm:
ffffffffc020415e:	8be2                	mv	s7,s8
    if (ret != 0)
ffffffffc0204160:	de050be3          	beqz	a0,ffffffffc0203f56 <do_fork+0xbe>
    exit_mmap(mm);
ffffffffc0204164:	8562                	mv	a0,s8
ffffffffc0204166:	f7eff0ef          	jal	ra,ffffffffc02038e4 <exit_mmap>
    put_pgdir(mm);
ffffffffc020416a:	8562                	mv	a0,s8
ffffffffc020416c:	c53ff0ef          	jal	ra,ffffffffc0203dbe <put_pgdir>
    mm_destroy(mm);
ffffffffc0204170:	8562                	mv	a0,s8
ffffffffc0204172:	dd6ff0ef          	jal	ra,ffffffffc0203748 <mm_destroy>
ffffffffc0204176:	a039                	j	ffffffffc0204184 <do_fork+0x2ec>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204178:	8936                	mv	s2,a3
ffffffffc020417a:	bd2d                	j	ffffffffc0203fb4 <do_fork+0x11c>
    mm_destroy(mm);
ffffffffc020417c:	8562                	mv	a0,s8
ffffffffc020417e:	dcaff0ef          	jal	ra,ffffffffc0203748 <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0204182:	5a71                	li	s4,-4
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204184:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0204186:	c02007b7          	lui	a5,0xc0200
ffffffffc020418a:	0af6e563          	bltu	a3,a5,ffffffffc0204234 <do_fork+0x39c>
ffffffffc020418e:	000db703          	ld	a4,0(s11)
    if (PPN(pa) >= npage)
ffffffffc0204192:	000d3783          	ld	a5,0(s10)
    return pa2page(PADDR(kva));
ffffffffc0204196:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage)
ffffffffc0204198:	82b1                	srli	a3,a3,0xc
ffffffffc020419a:	08f6f163          	bgeu	a3,a5,ffffffffc020421c <do_fork+0x384>
    return &pages[PPN(pa) - nbase];
ffffffffc020419e:	000ab783          	ld	a5,0(s5)
ffffffffc02041a2:	000cb503          	ld	a0,0(s9)
ffffffffc02041a6:	4589                	li	a1,2
ffffffffc02041a8:	8e9d                	sub	a3,a3,a5
ffffffffc02041aa:	069a                	slli	a3,a3,0x6
ffffffffc02041ac:	9536                	add	a0,a0,a3
ffffffffc02041ae:	c75fd0ef          	jal	ra,ffffffffc0201e22 <free_pages>
    kfree(proc);
ffffffffc02041b2:	8522                	mv	a0,s0
ffffffffc02041b4:	b03fd0ef          	jal	ra,ffffffffc0201cb6 <kfree>
    return ret;
ffffffffc02041b8:	bd79                	j	ffffffffc0204056 <do_fork+0x1be>
                    if (last_pid >= MAX_PID)
ffffffffc02041ba:	01d6c363          	blt	a3,t4,ffffffffc02041c0 <do_fork+0x328>
                        last_pid = 1;
ffffffffc02041be:	4685                	li	a3,1
                    goto repeat;
ffffffffc02041c0:	4585                	li	a1,1
ffffffffc02041c2:	bdf1                	j	ffffffffc020409e <do_fork+0x206>
    return -E_NO_MEM;
ffffffffc02041c4:	5a71                	li	s4,-4
ffffffffc02041c6:	b7f5                	j	ffffffffc02041b2 <do_fork+0x31a>
    int ret = -E_NO_FREE_PROC;
ffffffffc02041c8:	5a6d                	li	s4,-5
ffffffffc02041ca:	b571                	j	ffffffffc0204056 <do_fork+0x1be>
ffffffffc02041cc:	c599                	beqz	a1,ffffffffc02041da <do_fork+0x342>
ffffffffc02041ce:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc02041d2:	8536                	mv	a0,a3
ffffffffc02041d4:	b50d                	j	ffffffffc0203ff6 <do_fork+0x15e>
    ret = -E_NO_MEM;
ffffffffc02041d6:	5a71                	li	s4,-4
ffffffffc02041d8:	bdbd                	j	ffffffffc0204056 <do_fork+0x1be>
    return last_pid;
ffffffffc02041da:	00082503          	lw	a0,0(a6)
ffffffffc02041de:	bd21                	j	ffffffffc0203ff6 <do_fork+0x15e>
    int ret = -E_NO_MEM;
ffffffffc02041e0:	5a71                	li	s4,-4
ffffffffc02041e2:	b74d                	j	ffffffffc0204184 <do_fork+0x2ec>
    assert(current->wait_state == 0);
ffffffffc02041e4:	00003697          	auipc	a3,0x3
ffffffffc02041e8:	2fc68693          	addi	a3,a3,764 # ffffffffc02074e0 <default_pmm_manager+0xa08>
ffffffffc02041ec:	00002617          	auipc	a2,0x2
ffffffffc02041f0:	53c60613          	addi	a2,a2,1340 # ffffffffc0206728 <commands+0x828>
ffffffffc02041f4:	1f500593          	li	a1,501
ffffffffc02041f8:	00003517          	auipc	a0,0x3
ffffffffc02041fc:	30850513          	addi	a0,a0,776 # ffffffffc0207500 <default_pmm_manager+0xa28>
ffffffffc0204200:	a92fc0ef          	jal	ra,ffffffffc0200492 <__panic>
    return KADDR(page2pa(page));
ffffffffc0204204:	00003617          	auipc	a2,0x3
ffffffffc0204208:	90c60613          	addi	a2,a2,-1780 # ffffffffc0206b10 <default_pmm_manager+0x38>
ffffffffc020420c:	07100593          	li	a1,113
ffffffffc0204210:	00003517          	auipc	a0,0x3
ffffffffc0204214:	92850513          	addi	a0,a0,-1752 # ffffffffc0206b38 <default_pmm_manager+0x60>
ffffffffc0204218:	a7afc0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020421c:	00003617          	auipc	a2,0x3
ffffffffc0204220:	9c460613          	addi	a2,a2,-1596 # ffffffffc0206be0 <default_pmm_manager+0x108>
ffffffffc0204224:	06900593          	li	a1,105
ffffffffc0204228:	00003517          	auipc	a0,0x3
ffffffffc020422c:	91050513          	addi	a0,a0,-1776 # ffffffffc0206b38 <default_pmm_manager+0x60>
ffffffffc0204230:	a62fc0ef          	jal	ra,ffffffffc0200492 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0204234:	00003617          	auipc	a2,0x3
ffffffffc0204238:	98460613          	addi	a2,a2,-1660 # ffffffffc0206bb8 <default_pmm_manager+0xe0>
ffffffffc020423c:	07700593          	li	a1,119
ffffffffc0204240:	00003517          	auipc	a0,0x3
ffffffffc0204244:	8f850513          	addi	a0,a0,-1800 # ffffffffc0206b38 <default_pmm_manager+0x60>
ffffffffc0204248:	a4afc0ef          	jal	ra,ffffffffc0200492 <__panic>
    {
        panic("Unlock failed.\n");
ffffffffc020424c:	00003617          	auipc	a2,0x3
ffffffffc0204250:	2cc60613          	addi	a2,a2,716 # ffffffffc0207518 <default_pmm_manager+0xa40>
ffffffffc0204254:	04000593          	li	a1,64
ffffffffc0204258:	00003517          	auipc	a0,0x3
ffffffffc020425c:	2d050513          	addi	a0,a0,720 # ffffffffc0207528 <default_pmm_manager+0xa50>
ffffffffc0204260:	a32fc0ef          	jal	ra,ffffffffc0200492 <__panic>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204264:	86be                	mv	a3,a5
ffffffffc0204266:	00003617          	auipc	a2,0x3
ffffffffc020426a:	95260613          	addi	a2,a2,-1710 # ffffffffc0206bb8 <default_pmm_manager+0xe0>
ffffffffc020426e:	1a400593          	li	a1,420
ffffffffc0204272:	00003517          	auipc	a0,0x3
ffffffffc0204276:	28e50513          	addi	a0,a0,654 # ffffffffc0207500 <default_pmm_manager+0xa28>
ffffffffc020427a:	a18fc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc020427e <kernel_thread>:
{
ffffffffc020427e:	7129                	addi	sp,sp,-320
ffffffffc0204280:	fa22                	sd	s0,304(sp)
ffffffffc0204282:	f626                	sd	s1,296(sp)
ffffffffc0204284:	f24a                	sd	s2,288(sp)
ffffffffc0204286:	84ae                	mv	s1,a1
ffffffffc0204288:	892a                	mv	s2,a0
ffffffffc020428a:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020428c:	4581                	li	a1,0
ffffffffc020428e:	12000613          	li	a2,288
ffffffffc0204292:	850a                	mv	a0,sp
{
ffffffffc0204294:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204296:	1d9010ef          	jal	ra,ffffffffc0205c6e <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc020429a:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc020429c:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc020429e:	100027f3          	csrr	a5,sstatus
ffffffffc02042a2:	edd7f793          	andi	a5,a5,-291
ffffffffc02042a6:	1207e793          	ori	a5,a5,288
ffffffffc02042aa:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02042ac:	860a                	mv	a2,sp
ffffffffc02042ae:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02042b2:	00000797          	auipc	a5,0x0
ffffffffc02042b6:	a6078793          	addi	a5,a5,-1440 # ffffffffc0203d12 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02042ba:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02042bc:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02042be:	bdbff0ef          	jal	ra,ffffffffc0203e98 <do_fork>
}
ffffffffc02042c2:	70f2                	ld	ra,312(sp)
ffffffffc02042c4:	7452                	ld	s0,304(sp)
ffffffffc02042c6:	74b2                	ld	s1,296(sp)
ffffffffc02042c8:	7912                	ld	s2,288(sp)
ffffffffc02042ca:	6131                	addi	sp,sp,320
ffffffffc02042cc:	8082                	ret

ffffffffc02042ce <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int do_exit(int error_code)
{
ffffffffc02042ce:	7179                	addi	sp,sp,-48
ffffffffc02042d0:	f022                	sd	s0,32(sp)
    if (current == idleproc)
ffffffffc02042d2:	000ce417          	auipc	s0,0xce
ffffffffc02042d6:	4ee40413          	addi	s0,s0,1262 # ffffffffc02d27c0 <current>
ffffffffc02042da:	601c                	ld	a5,0(s0)
{
ffffffffc02042dc:	f406                	sd	ra,40(sp)
ffffffffc02042de:	ec26                	sd	s1,24(sp)
ffffffffc02042e0:	e84a                	sd	s2,16(sp)
ffffffffc02042e2:	e44e                	sd	s3,8(sp)
ffffffffc02042e4:	e052                	sd	s4,0(sp)
    if (current == idleproc)
ffffffffc02042e6:	000ce717          	auipc	a4,0xce
ffffffffc02042ea:	4e273703          	ld	a4,1250(a4) # ffffffffc02d27c8 <idleproc>
ffffffffc02042ee:	0ce78c63          	beq	a5,a4,ffffffffc02043c6 <do_exit+0xf8>
    {
        panic("idleproc exit.\n");
    }
    if (current == initproc)
ffffffffc02042f2:	000ce497          	auipc	s1,0xce
ffffffffc02042f6:	4de48493          	addi	s1,s1,1246 # ffffffffc02d27d0 <initproc>
ffffffffc02042fa:	6098                	ld	a4,0(s1)
ffffffffc02042fc:	0ee78b63          	beq	a5,a4,ffffffffc02043f2 <do_exit+0x124>
    {
        panic("initproc exit.\n");
    }
    struct mm_struct *mm = current->mm;
ffffffffc0204300:	0287b983          	ld	s3,40(a5)
ffffffffc0204304:	892a                	mv	s2,a0
    if (mm != NULL)
ffffffffc0204306:	02098663          	beqz	s3,ffffffffc0204332 <do_exit+0x64>
ffffffffc020430a:	000ce797          	auipc	a5,0xce
ffffffffc020430e:	4867b783          	ld	a5,1158(a5) # ffffffffc02d2790 <boot_pgdir_pa>
ffffffffc0204312:	577d                	li	a4,-1
ffffffffc0204314:	177e                	slli	a4,a4,0x3f
ffffffffc0204316:	83b1                	srli	a5,a5,0xc
ffffffffc0204318:	8fd9                	or	a5,a5,a4
ffffffffc020431a:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc020431e:	0309a783          	lw	a5,48(s3)
ffffffffc0204322:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204326:	02e9a823          	sw	a4,48(s3)
    {
        lsatp(boot_pgdir_pa);
        if (mm_count_dec(mm) == 0)
ffffffffc020432a:	cb55                	beqz	a4,ffffffffc02043de <do_exit+0x110>
        {
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);
        }
        current->mm = NULL;
ffffffffc020432c:	601c                	ld	a5,0(s0)
ffffffffc020432e:	0207b423          	sd	zero,40(a5)
    }
    current->state = PROC_ZOMBIE;
ffffffffc0204332:	601c                	ld	a5,0(s0)
ffffffffc0204334:	470d                	li	a4,3
ffffffffc0204336:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0204338:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020433c:	100027f3          	csrr	a5,sstatus
ffffffffc0204340:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204342:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204344:	e3f9                	bnez	a5,ffffffffc020440a <do_exit+0x13c>
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
    {
        proc = current->parent;
ffffffffc0204346:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204348:	800007b7          	lui	a5,0x80000
ffffffffc020434c:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc020434e:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204350:	0ec52703          	lw	a4,236(a0)
ffffffffc0204354:	0af70f63          	beq	a4,a5,ffffffffc0204412 <do_exit+0x144>
        {
            wakeup_proc(proc);
        }
        while (current->cptr != NULL)
ffffffffc0204358:	6018                	ld	a4,0(s0)
ffffffffc020435a:	7b7c                	ld	a5,240(a4)
ffffffffc020435c:	c3a1                	beqz	a5,ffffffffc020439c <do_exit+0xce>
            }
            proc->parent = initproc;
            initproc->cptr = proc;
            if (proc->state == PROC_ZOMBIE)
            {
                if (initproc->wait_state == WT_CHILD)
ffffffffc020435e:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204362:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204364:	0985                	addi	s3,s3,1
ffffffffc0204366:	a021                	j	ffffffffc020436e <do_exit+0xa0>
        while (current->cptr != NULL)
ffffffffc0204368:	6018                	ld	a4,0(s0)
ffffffffc020436a:	7b7c                	ld	a5,240(a4)
ffffffffc020436c:	cb85                	beqz	a5,ffffffffc020439c <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc020436e:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_matrix_out_size+0xffffffff7fff39d8>
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204372:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc0204374:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204376:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0204378:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc020437c:	10e7b023          	sd	a4,256(a5)
ffffffffc0204380:	c311                	beqz	a4,ffffffffc0204384 <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc0204382:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204384:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0204386:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0204388:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc020438a:	fd271fe3          	bne	a4,s2,ffffffffc0204368 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc020438e:	0ec52783          	lw	a5,236(a0)
ffffffffc0204392:	fd379be3          	bne	a5,s3,ffffffffc0204368 <do_exit+0x9a>
                {
                    wakeup_proc(initproc);
ffffffffc0204396:	1c0010ef          	jal	ra,ffffffffc0205556 <wakeup_proc>
ffffffffc020439a:	b7f9                	j	ffffffffc0204368 <do_exit+0x9a>
    if (flag)
ffffffffc020439c:	020a1263          	bnez	s4,ffffffffc02043c0 <do_exit+0xf2>
                }
            }
        }
    }
    local_intr_restore(intr_flag);
    schedule();
ffffffffc02043a0:	268010ef          	jal	ra,ffffffffc0205608 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc02043a4:	601c                	ld	a5,0(s0)
ffffffffc02043a6:	00003617          	auipc	a2,0x3
ffffffffc02043aa:	1ba60613          	addi	a2,a2,442 # ffffffffc0207560 <default_pmm_manager+0xa88>
ffffffffc02043ae:	25300593          	li	a1,595
ffffffffc02043b2:	43d4                	lw	a3,4(a5)
ffffffffc02043b4:	00003517          	auipc	a0,0x3
ffffffffc02043b8:	14c50513          	addi	a0,a0,332 # ffffffffc0207500 <default_pmm_manager+0xa28>
ffffffffc02043bc:	8d6fc0ef          	jal	ra,ffffffffc0200492 <__panic>
        intr_enable();
ffffffffc02043c0:	de8fc0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc02043c4:	bff1                	j	ffffffffc02043a0 <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc02043c6:	00003617          	auipc	a2,0x3
ffffffffc02043ca:	17a60613          	addi	a2,a2,378 # ffffffffc0207540 <default_pmm_manager+0xa68>
ffffffffc02043ce:	21f00593          	li	a1,543
ffffffffc02043d2:	00003517          	auipc	a0,0x3
ffffffffc02043d6:	12e50513          	addi	a0,a0,302 # ffffffffc0207500 <default_pmm_manager+0xa28>
ffffffffc02043da:	8b8fc0ef          	jal	ra,ffffffffc0200492 <__panic>
            exit_mmap(mm);
ffffffffc02043de:	854e                	mv	a0,s3
ffffffffc02043e0:	d04ff0ef          	jal	ra,ffffffffc02038e4 <exit_mmap>
            put_pgdir(mm);
ffffffffc02043e4:	854e                	mv	a0,s3
ffffffffc02043e6:	9d9ff0ef          	jal	ra,ffffffffc0203dbe <put_pgdir>
            mm_destroy(mm);
ffffffffc02043ea:	854e                	mv	a0,s3
ffffffffc02043ec:	b5cff0ef          	jal	ra,ffffffffc0203748 <mm_destroy>
ffffffffc02043f0:	bf35                	j	ffffffffc020432c <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc02043f2:	00003617          	auipc	a2,0x3
ffffffffc02043f6:	15e60613          	addi	a2,a2,350 # ffffffffc0207550 <default_pmm_manager+0xa78>
ffffffffc02043fa:	22300593          	li	a1,547
ffffffffc02043fe:	00003517          	auipc	a0,0x3
ffffffffc0204402:	10250513          	addi	a0,a0,258 # ffffffffc0207500 <default_pmm_manager+0xa28>
ffffffffc0204406:	88cfc0ef          	jal	ra,ffffffffc0200492 <__panic>
        intr_disable();
ffffffffc020440a:	da4fc0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        return 1;
ffffffffc020440e:	4a05                	li	s4,1
ffffffffc0204410:	bf1d                	j	ffffffffc0204346 <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc0204412:	144010ef          	jal	ra,ffffffffc0205556 <wakeup_proc>
ffffffffc0204416:	b789                	j	ffffffffc0204358 <do_exit+0x8a>

ffffffffc0204418 <do_wait.part.0>:
}

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int do_wait(int pid, int *code_store)
ffffffffc0204418:	715d                	addi	sp,sp,-80
ffffffffc020441a:	f84a                	sd	s2,48(sp)
ffffffffc020441c:	f44e                	sd	s3,40(sp)
        }
    }
    if (haskid)
    {
        current->state = PROC_SLEEPING;
        current->wait_state = WT_CHILD;
ffffffffc020441e:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID)
ffffffffc0204422:	6989                	lui	s3,0x2
int do_wait(int pid, int *code_store)
ffffffffc0204424:	fc26                	sd	s1,56(sp)
ffffffffc0204426:	f052                	sd	s4,32(sp)
ffffffffc0204428:	ec56                	sd	s5,24(sp)
ffffffffc020442a:	e85a                	sd	s6,16(sp)
ffffffffc020442c:	e45e                	sd	s7,8(sp)
ffffffffc020442e:	e486                	sd	ra,72(sp)
ffffffffc0204430:	e0a2                	sd	s0,64(sp)
ffffffffc0204432:	84aa                	mv	s1,a0
ffffffffc0204434:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc0204436:	000ceb97          	auipc	s7,0xce
ffffffffc020443a:	38ab8b93          	addi	s7,s7,906 # ffffffffc02d27c0 <current>
    if (0 < pid && pid < MAX_PID)
ffffffffc020443e:	00050b1b          	sext.w	s6,a0
ffffffffc0204442:	fff50a9b          	addiw	s5,a0,-1
ffffffffc0204446:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc0204448:	0905                	addi	s2,s2,1
    if (pid != 0)
ffffffffc020444a:	ccbd                	beqz	s1,ffffffffc02044c8 <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID)
ffffffffc020444c:	0359e863          	bltu	s3,s5,ffffffffc020447c <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204450:	45a9                	li	a1,10
ffffffffc0204452:	855a                	mv	a0,s6
ffffffffc0204454:	374010ef          	jal	ra,ffffffffc02057c8 <hash32>
ffffffffc0204458:	02051793          	slli	a5,a0,0x20
ffffffffc020445c:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204460:	000ca797          	auipc	a5,0xca
ffffffffc0204464:	2c078793          	addi	a5,a5,704 # ffffffffc02ce720 <hash_list>
ffffffffc0204468:	953e                	add	a0,a0,a5
ffffffffc020446a:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list)
ffffffffc020446c:	a029                	j	ffffffffc0204476 <do_wait.part.0+0x5e>
            if (proc->pid == pid)
ffffffffc020446e:	f2c42783          	lw	a5,-212(s0)
ffffffffc0204472:	02978163          	beq	a5,s1,ffffffffc0204494 <do_wait.part.0+0x7c>
ffffffffc0204476:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list)
ffffffffc0204478:	fe851be3          	bne	a0,s0,ffffffffc020446e <do_wait.part.0+0x56>
        {
            do_exit(-E_KILLED);
        }
        goto repeat;
    }
    return -E_BAD_PROC;
ffffffffc020447c:	5579                	li	a0,-2
    }
    local_intr_restore(intr_flag);
    put_kstack(proc);
    kfree(proc);
    return 0;
}
ffffffffc020447e:	60a6                	ld	ra,72(sp)
ffffffffc0204480:	6406                	ld	s0,64(sp)
ffffffffc0204482:	74e2                	ld	s1,56(sp)
ffffffffc0204484:	7942                	ld	s2,48(sp)
ffffffffc0204486:	79a2                	ld	s3,40(sp)
ffffffffc0204488:	7a02                	ld	s4,32(sp)
ffffffffc020448a:	6ae2                	ld	s5,24(sp)
ffffffffc020448c:	6b42                	ld	s6,16(sp)
ffffffffc020448e:	6ba2                	ld	s7,8(sp)
ffffffffc0204490:	6161                	addi	sp,sp,80
ffffffffc0204492:	8082                	ret
        if (proc != NULL && proc->parent == current)
ffffffffc0204494:	000bb683          	ld	a3,0(s7)
ffffffffc0204498:	f4843783          	ld	a5,-184(s0)
ffffffffc020449c:	fed790e3          	bne	a5,a3,ffffffffc020447c <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02044a0:	f2842703          	lw	a4,-216(s0)
ffffffffc02044a4:	478d                	li	a5,3
ffffffffc02044a6:	0ef70b63          	beq	a4,a5,ffffffffc020459c <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc02044aa:	4785                	li	a5,1
ffffffffc02044ac:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc02044ae:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc02044b2:	156010ef          	jal	ra,ffffffffc0205608 <schedule>
        if (current->flags & PF_EXITING)
ffffffffc02044b6:	000bb783          	ld	a5,0(s7)
ffffffffc02044ba:	0b07a783          	lw	a5,176(a5)
ffffffffc02044be:	8b85                	andi	a5,a5,1
ffffffffc02044c0:	d7c9                	beqz	a5,ffffffffc020444a <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc02044c2:	555d                	li	a0,-9
ffffffffc02044c4:	e0bff0ef          	jal	ra,ffffffffc02042ce <do_exit>
        proc = current->cptr;
ffffffffc02044c8:	000bb683          	ld	a3,0(s7)
ffffffffc02044cc:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr)
ffffffffc02044ce:	d45d                	beqz	s0,ffffffffc020447c <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02044d0:	470d                	li	a4,3
ffffffffc02044d2:	a021                	j	ffffffffc02044da <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr)
ffffffffc02044d4:	10043403          	ld	s0,256(s0)
ffffffffc02044d8:	d869                	beqz	s0,ffffffffc02044aa <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02044da:	401c                	lw	a5,0(s0)
ffffffffc02044dc:	fee79ce3          	bne	a5,a4,ffffffffc02044d4 <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc)
ffffffffc02044e0:	000ce797          	auipc	a5,0xce
ffffffffc02044e4:	2e87b783          	ld	a5,744(a5) # ffffffffc02d27c8 <idleproc>
ffffffffc02044e8:	0c878963          	beq	a5,s0,ffffffffc02045ba <do_wait.part.0+0x1a2>
ffffffffc02044ec:	000ce797          	auipc	a5,0xce
ffffffffc02044f0:	2e47b783          	ld	a5,740(a5) # ffffffffc02d27d0 <initproc>
ffffffffc02044f4:	0cf40363          	beq	s0,a5,ffffffffc02045ba <do_wait.part.0+0x1a2>
    if (code_store != NULL)
ffffffffc02044f8:	000a0663          	beqz	s4,ffffffffc0204504 <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc02044fc:	0e842783          	lw	a5,232(s0)
ffffffffc0204500:	00fa2023          	sw	a5,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8f50>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204504:	100027f3          	csrr	a5,sstatus
ffffffffc0204508:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020450a:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020450c:	e7c1                	bnez	a5,ffffffffc0204594 <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc020450e:	6c70                	ld	a2,216(s0)
ffffffffc0204510:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL)
ffffffffc0204512:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc0204516:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0204518:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020451a:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020451c:	6470                	ld	a2,200(s0)
ffffffffc020451e:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0204520:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0204522:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL)
ffffffffc0204524:	c319                	beqz	a4,ffffffffc020452a <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc0204526:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL)
ffffffffc0204528:	7c7c                	ld	a5,248(s0)
ffffffffc020452a:	c3b5                	beqz	a5,ffffffffc020458e <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc020452c:	10e7b023          	sd	a4,256(a5)
    nr_process--;
ffffffffc0204530:	000ce717          	auipc	a4,0xce
ffffffffc0204534:	2a870713          	addi	a4,a4,680 # ffffffffc02d27d8 <nr_process>
ffffffffc0204538:	431c                	lw	a5,0(a4)
ffffffffc020453a:	37fd                	addiw	a5,a5,-1
ffffffffc020453c:	c31c                	sw	a5,0(a4)
    if (flag)
ffffffffc020453e:	e5a9                	bnez	a1,ffffffffc0204588 <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204540:	6814                	ld	a3,16(s0)
ffffffffc0204542:	c02007b7          	lui	a5,0xc0200
ffffffffc0204546:	04f6ee63          	bltu	a3,a5,ffffffffc02045a2 <do_wait.part.0+0x18a>
ffffffffc020454a:	000ce797          	auipc	a5,0xce
ffffffffc020454e:	26e7b783          	ld	a5,622(a5) # ffffffffc02d27b8 <va_pa_offset>
ffffffffc0204552:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage)
ffffffffc0204554:	82b1                	srli	a3,a3,0xc
ffffffffc0204556:	000ce797          	auipc	a5,0xce
ffffffffc020455a:	24a7b783          	ld	a5,586(a5) # ffffffffc02d27a0 <npage>
ffffffffc020455e:	06f6fa63          	bgeu	a3,a5,ffffffffc02045d2 <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0204562:	00004517          	auipc	a0,0x4
ffffffffc0204566:	fd653503          	ld	a0,-42(a0) # ffffffffc0208538 <nbase>
ffffffffc020456a:	8e89                	sub	a3,a3,a0
ffffffffc020456c:	069a                	slli	a3,a3,0x6
ffffffffc020456e:	000ce517          	auipc	a0,0xce
ffffffffc0204572:	23a53503          	ld	a0,570(a0) # ffffffffc02d27a8 <pages>
ffffffffc0204576:	9536                	add	a0,a0,a3
ffffffffc0204578:	4589                	li	a1,2
ffffffffc020457a:	8a9fd0ef          	jal	ra,ffffffffc0201e22 <free_pages>
    kfree(proc);
ffffffffc020457e:	8522                	mv	a0,s0
ffffffffc0204580:	f36fd0ef          	jal	ra,ffffffffc0201cb6 <kfree>
    return 0;
ffffffffc0204584:	4501                	li	a0,0
ffffffffc0204586:	bde5                	j	ffffffffc020447e <do_wait.part.0+0x66>
        intr_enable();
ffffffffc0204588:	c20fc0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc020458c:	bf55                	j	ffffffffc0204540 <do_wait.part.0+0x128>
        proc->parent->cptr = proc->optr;
ffffffffc020458e:	701c                	ld	a5,32(s0)
ffffffffc0204590:	fbf8                	sd	a4,240(a5)
ffffffffc0204592:	bf79                	j	ffffffffc0204530 <do_wait.part.0+0x118>
        intr_disable();
ffffffffc0204594:	c1afc0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        return 1;
ffffffffc0204598:	4585                	li	a1,1
ffffffffc020459a:	bf95                	j	ffffffffc020450e <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020459c:	f2840413          	addi	s0,s0,-216
ffffffffc02045a0:	b781                	j	ffffffffc02044e0 <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc02045a2:	00002617          	auipc	a2,0x2
ffffffffc02045a6:	61660613          	addi	a2,a2,1558 # ffffffffc0206bb8 <default_pmm_manager+0xe0>
ffffffffc02045aa:	07700593          	li	a1,119
ffffffffc02045ae:	00002517          	auipc	a0,0x2
ffffffffc02045b2:	58a50513          	addi	a0,a0,1418 # ffffffffc0206b38 <default_pmm_manager+0x60>
ffffffffc02045b6:	eddfb0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc02045ba:	00003617          	auipc	a2,0x3
ffffffffc02045be:	fc660613          	addi	a2,a2,-58 # ffffffffc0207580 <default_pmm_manager+0xaa8>
ffffffffc02045c2:	37700593          	li	a1,887
ffffffffc02045c6:	00003517          	auipc	a0,0x3
ffffffffc02045ca:	f3a50513          	addi	a0,a0,-198 # ffffffffc0207500 <default_pmm_manager+0xa28>
ffffffffc02045ce:	ec5fb0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02045d2:	00002617          	auipc	a2,0x2
ffffffffc02045d6:	60e60613          	addi	a2,a2,1550 # ffffffffc0206be0 <default_pmm_manager+0x108>
ffffffffc02045da:	06900593          	li	a1,105
ffffffffc02045de:	00002517          	auipc	a0,0x2
ffffffffc02045e2:	55a50513          	addi	a0,a0,1370 # ffffffffc0206b38 <default_pmm_manager+0x60>
ffffffffc02045e6:	eadfb0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02045ea <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc02045ea:	1141                	addi	sp,sp,-16
ffffffffc02045ec:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02045ee:	875fd0ef          	jal	ra,ffffffffc0201e62 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02045f2:	e10fd0ef          	jal	ra,ffffffffc0201c02 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02045f6:	4601                	li	a2,0
ffffffffc02045f8:	4581                	li	a1,0
ffffffffc02045fa:	00000517          	auipc	a0,0x0
ffffffffc02045fe:	62850513          	addi	a0,a0,1576 # ffffffffc0204c22 <user_main>
ffffffffc0204602:	c7dff0ef          	jal	ra,ffffffffc020427e <kernel_thread>
    if (pid <= 0)
ffffffffc0204606:	00a04563          	bgtz	a0,ffffffffc0204610 <init_main+0x26>
ffffffffc020460a:	a071                	j	ffffffffc0204696 <init_main+0xac>
    }

    int wait_result;
    while ((wait_result = do_wait(0, NULL)) == 0)
    {
        schedule();
ffffffffc020460c:	7fd000ef          	jal	ra,ffffffffc0205608 <schedule>
    if (code_store != NULL)
ffffffffc0204610:	4581                	li	a1,0
ffffffffc0204612:	4501                	li	a0,0
ffffffffc0204614:	e05ff0ef          	jal	ra,ffffffffc0204418 <do_wait.part.0>
    while ((wait_result = do_wait(0, NULL)) == 0)
ffffffffc0204618:	d975                	beqz	a0,ffffffffc020460c <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc020461a:	00003517          	auipc	a0,0x3
ffffffffc020461e:	fa650513          	addi	a0,a0,-90 # ffffffffc02075c0 <default_pmm_manager+0xae8>
ffffffffc0204622:	b77fb0ef          	jal	ra,ffffffffc0200198 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204626:	000ce797          	auipc	a5,0xce
ffffffffc020462a:	1aa7b783          	ld	a5,426(a5) # ffffffffc02d27d0 <initproc>
ffffffffc020462e:	7bf8                	ld	a4,240(a5)
ffffffffc0204630:	e339                	bnez	a4,ffffffffc0204676 <init_main+0x8c>
ffffffffc0204632:	7ff8                	ld	a4,248(a5)
ffffffffc0204634:	e329                	bnez	a4,ffffffffc0204676 <init_main+0x8c>
ffffffffc0204636:	1007b703          	ld	a4,256(a5)
ffffffffc020463a:	ef15                	bnez	a4,ffffffffc0204676 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc020463c:	000ce697          	auipc	a3,0xce
ffffffffc0204640:	19c6a683          	lw	a3,412(a3) # ffffffffc02d27d8 <nr_process>
ffffffffc0204644:	4709                	li	a4,2
ffffffffc0204646:	0ae69463          	bne	a3,a4,ffffffffc02046ee <init_main+0x104>
    return listelm->next;
ffffffffc020464a:	000ce697          	auipc	a3,0xce
ffffffffc020464e:	0d668693          	addi	a3,a3,214 # ffffffffc02d2720 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204652:	6698                	ld	a4,8(a3)
ffffffffc0204654:	0c878793          	addi	a5,a5,200
ffffffffc0204658:	06f71b63          	bne	a4,a5,ffffffffc02046ce <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020465c:	629c                	ld	a5,0(a3)
ffffffffc020465e:	04f71863          	bne	a4,a5,ffffffffc02046ae <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc0204662:	00003517          	auipc	a0,0x3
ffffffffc0204666:	04650513          	addi	a0,a0,70 # ffffffffc02076a8 <default_pmm_manager+0xbd0>
ffffffffc020466a:	b2ffb0ef          	jal	ra,ffffffffc0200198 <cprintf>
    return 0;
}
ffffffffc020466e:	60a2                	ld	ra,8(sp)
ffffffffc0204670:	4501                	li	a0,0
ffffffffc0204672:	0141                	addi	sp,sp,16
ffffffffc0204674:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204676:	00003697          	auipc	a3,0x3
ffffffffc020467a:	f7268693          	addi	a3,a3,-142 # ffffffffc02075e8 <default_pmm_manager+0xb10>
ffffffffc020467e:	00002617          	auipc	a2,0x2
ffffffffc0204682:	0aa60613          	addi	a2,a2,170 # ffffffffc0206728 <commands+0x828>
ffffffffc0204686:	3e400593          	li	a1,996
ffffffffc020468a:	00003517          	auipc	a0,0x3
ffffffffc020468e:	e7650513          	addi	a0,a0,-394 # ffffffffc0207500 <default_pmm_manager+0xa28>
ffffffffc0204692:	e01fb0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("create user_main failed.\n");
ffffffffc0204696:	00003617          	auipc	a2,0x3
ffffffffc020469a:	f0a60613          	addi	a2,a2,-246 # ffffffffc02075a0 <default_pmm_manager+0xac8>
ffffffffc020469e:	3da00593          	li	a1,986
ffffffffc02046a2:	00003517          	auipc	a0,0x3
ffffffffc02046a6:	e5e50513          	addi	a0,a0,-418 # ffffffffc0207500 <default_pmm_manager+0xa28>
ffffffffc02046aa:	de9fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02046ae:	00003697          	auipc	a3,0x3
ffffffffc02046b2:	fca68693          	addi	a3,a3,-54 # ffffffffc0207678 <default_pmm_manager+0xba0>
ffffffffc02046b6:	00002617          	auipc	a2,0x2
ffffffffc02046ba:	07260613          	addi	a2,a2,114 # ffffffffc0206728 <commands+0x828>
ffffffffc02046be:	3e700593          	li	a1,999
ffffffffc02046c2:	00003517          	auipc	a0,0x3
ffffffffc02046c6:	e3e50513          	addi	a0,a0,-450 # ffffffffc0207500 <default_pmm_manager+0xa28>
ffffffffc02046ca:	dc9fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02046ce:	00003697          	auipc	a3,0x3
ffffffffc02046d2:	f7a68693          	addi	a3,a3,-134 # ffffffffc0207648 <default_pmm_manager+0xb70>
ffffffffc02046d6:	00002617          	auipc	a2,0x2
ffffffffc02046da:	05260613          	addi	a2,a2,82 # ffffffffc0206728 <commands+0x828>
ffffffffc02046de:	3e600593          	li	a1,998
ffffffffc02046e2:	00003517          	auipc	a0,0x3
ffffffffc02046e6:	e1e50513          	addi	a0,a0,-482 # ffffffffc0207500 <default_pmm_manager+0xa28>
ffffffffc02046ea:	da9fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(nr_process == 2);
ffffffffc02046ee:	00003697          	auipc	a3,0x3
ffffffffc02046f2:	f4a68693          	addi	a3,a3,-182 # ffffffffc0207638 <default_pmm_manager+0xb60>
ffffffffc02046f6:	00002617          	auipc	a2,0x2
ffffffffc02046fa:	03260613          	addi	a2,a2,50 # ffffffffc0206728 <commands+0x828>
ffffffffc02046fe:	3e500593          	li	a1,997
ffffffffc0204702:	00003517          	auipc	a0,0x3
ffffffffc0204706:	dfe50513          	addi	a0,a0,-514 # ffffffffc0207500 <default_pmm_manager+0xa28>
ffffffffc020470a:	d89fb0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc020470e <do_execve>:
{
ffffffffc020470e:	7171                	addi	sp,sp,-176
ffffffffc0204710:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204712:	000ced97          	auipc	s11,0xce
ffffffffc0204716:	0aed8d93          	addi	s11,s11,174 # ffffffffc02d27c0 <current>
ffffffffc020471a:	000db783          	ld	a5,0(s11)
{
ffffffffc020471e:	e54e                	sd	s3,136(sp)
ffffffffc0204720:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204722:	0287b983          	ld	s3,40(a5)
{
ffffffffc0204726:	e94a                	sd	s2,144(sp)
ffffffffc0204728:	f4de                	sd	s7,104(sp)
ffffffffc020472a:	892a                	mv	s2,a0
ffffffffc020472c:	8bb2                	mv	s7,a2
ffffffffc020472e:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204730:	862e                	mv	a2,a1
ffffffffc0204732:	4681                	li	a3,0
ffffffffc0204734:	85aa                	mv	a1,a0
ffffffffc0204736:	854e                	mv	a0,s3
{
ffffffffc0204738:	f506                	sd	ra,168(sp)
ffffffffc020473a:	f122                	sd	s0,160(sp)
ffffffffc020473c:	e152                	sd	s4,128(sp)
ffffffffc020473e:	fcd6                	sd	s5,120(sp)
ffffffffc0204740:	f8da                	sd	s6,112(sp)
ffffffffc0204742:	f0e2                	sd	s8,96(sp)
ffffffffc0204744:	ece6                	sd	s9,88(sp)
ffffffffc0204746:	e8ea                	sd	s10,80(sp)
ffffffffc0204748:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc020474a:	d34ff0ef          	jal	ra,ffffffffc0203c7e <user_mem_check>
ffffffffc020474e:	40050a63          	beqz	a0,ffffffffc0204b62 <do_execve+0x454>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0204752:	4641                	li	a2,16
ffffffffc0204754:	4581                	li	a1,0
ffffffffc0204756:	1808                	addi	a0,sp,48
ffffffffc0204758:	516010ef          	jal	ra,ffffffffc0205c6e <memset>
    memcpy(local_name, name, len);
ffffffffc020475c:	47bd                	li	a5,15
ffffffffc020475e:	8626                	mv	a2,s1
ffffffffc0204760:	1e97e263          	bltu	a5,s1,ffffffffc0204944 <do_execve+0x236>
ffffffffc0204764:	85ca                	mv	a1,s2
ffffffffc0204766:	1808                	addi	a0,sp,48
ffffffffc0204768:	518010ef          	jal	ra,ffffffffc0205c80 <memcpy>
    if (mm != NULL)
ffffffffc020476c:	1e098363          	beqz	s3,ffffffffc0204952 <do_execve+0x244>
        cputs("mm != NULL");
ffffffffc0204770:	00003517          	auipc	a0,0x3
ffffffffc0204774:	b9850513          	addi	a0,a0,-1128 # ffffffffc0207308 <default_pmm_manager+0x830>
ffffffffc0204778:	a59fb0ef          	jal	ra,ffffffffc02001d0 <cputs>
ffffffffc020477c:	000ce797          	auipc	a5,0xce
ffffffffc0204780:	0147b783          	ld	a5,20(a5) # ffffffffc02d2790 <boot_pgdir_pa>
ffffffffc0204784:	577d                	li	a4,-1
ffffffffc0204786:	177e                	slli	a4,a4,0x3f
ffffffffc0204788:	83b1                	srli	a5,a5,0xc
ffffffffc020478a:	8fd9                	or	a5,a5,a4
ffffffffc020478c:	18079073          	csrw	satp,a5
ffffffffc0204790:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7f20>
ffffffffc0204794:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204798:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0)
ffffffffc020479c:	2c070463          	beqz	a4,ffffffffc0204a64 <do_execve+0x356>
        current->mm = NULL;
ffffffffc02047a0:	000db783          	ld	a5,0(s11)
ffffffffc02047a4:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc02047a8:	e61fe0ef          	jal	ra,ffffffffc0203608 <mm_create>
ffffffffc02047ac:	84aa                	mv	s1,a0
ffffffffc02047ae:	1c050d63          	beqz	a0,ffffffffc0204988 <do_execve+0x27a>
    if ((page = alloc_page()) == NULL)
ffffffffc02047b2:	4505                	li	a0,1
ffffffffc02047b4:	e30fd0ef          	jal	ra,ffffffffc0201de4 <alloc_pages>
ffffffffc02047b8:	3a050963          	beqz	a0,ffffffffc0204b6a <do_execve+0x45c>
    return page - pages + nbase;
ffffffffc02047bc:	000cec97          	auipc	s9,0xce
ffffffffc02047c0:	fecc8c93          	addi	s9,s9,-20 # ffffffffc02d27a8 <pages>
ffffffffc02047c4:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc02047c8:	000cec17          	auipc	s8,0xce
ffffffffc02047cc:	fd8c0c13          	addi	s8,s8,-40 # ffffffffc02d27a0 <npage>
    return page - pages + nbase;
ffffffffc02047d0:	00004717          	auipc	a4,0x4
ffffffffc02047d4:	d6873703          	ld	a4,-664(a4) # ffffffffc0208538 <nbase>
ffffffffc02047d8:	40d506b3          	sub	a3,a0,a3
ffffffffc02047dc:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02047de:	5afd                	li	s5,-1
ffffffffc02047e0:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc02047e4:	96ba                	add	a3,a3,a4
ffffffffc02047e6:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc02047e8:	00cad713          	srli	a4,s5,0xc
ffffffffc02047ec:	ec3a                	sd	a4,24(sp)
ffffffffc02047ee:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02047f0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02047f2:	38f77063          	bgeu	a4,a5,ffffffffc0204b72 <do_execve+0x464>
ffffffffc02047f6:	000ceb17          	auipc	s6,0xce
ffffffffc02047fa:	fc2b0b13          	addi	s6,s6,-62 # ffffffffc02d27b8 <va_pa_offset>
ffffffffc02047fe:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204802:	6605                	lui	a2,0x1
ffffffffc0204804:	000ce597          	auipc	a1,0xce
ffffffffc0204808:	f945b583          	ld	a1,-108(a1) # ffffffffc02d2798 <boot_pgdir_va>
ffffffffc020480c:	9936                	add	s2,s2,a3
ffffffffc020480e:	854a                	mv	a0,s2
ffffffffc0204810:	470010ef          	jal	ra,ffffffffc0205c80 <memcpy>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204814:	7782                	ld	a5,32(sp)
ffffffffc0204816:	4398                	lw	a4,0(a5)
ffffffffc0204818:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc020481c:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204820:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_matrix_out_size+0x464b7e57>
ffffffffc0204824:	14f71863          	bne	a4,a5,ffffffffc0204974 <do_execve+0x266>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204828:	7682                	ld	a3,32(sp)
ffffffffc020482a:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020482e:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204832:	00371793          	slli	a5,a4,0x3
ffffffffc0204836:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204838:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020483a:	078e                	slli	a5,a5,0x3
ffffffffc020483c:	97ce                	add	a5,a5,s3
ffffffffc020483e:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph++)
ffffffffc0204840:	00f9fc63          	bgeu	s3,a5,ffffffffc0204858 <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc0204844:	0009a783          	lw	a5,0(s3)
ffffffffc0204848:	4705                	li	a4,1
ffffffffc020484a:	14e78163          	beq	a5,a4,ffffffffc020498c <do_execve+0x27e>
    for (; ph < ph_end; ph++)
ffffffffc020484e:	77a2                	ld	a5,40(sp)
ffffffffc0204850:	03898993          	addi	s3,s3,56
ffffffffc0204854:	fef9e8e3          	bltu	s3,a5,ffffffffc0204844 <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc0204858:	4701                	li	a4,0
ffffffffc020485a:	46ad                	li	a3,11
ffffffffc020485c:	00100637          	lui	a2,0x100
ffffffffc0204860:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0204864:	8526                	mv	a0,s1
ffffffffc0204866:	f35fe0ef          	jal	ra,ffffffffc020379a <mm_map>
ffffffffc020486a:	8a2a                	mv	s4,a0
ffffffffc020486c:	1e051263          	bnez	a0,ffffffffc0204a50 <do_execve+0x342>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204870:	6c88                	ld	a0,24(s1)
ffffffffc0204872:	467d                	li	a2,31
ffffffffc0204874:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0204878:	cabfe0ef          	jal	ra,ffffffffc0203522 <pgdir_alloc_page>
ffffffffc020487c:	38050363          	beqz	a0,ffffffffc0204c02 <do_execve+0x4f4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204880:	6c88                	ld	a0,24(s1)
ffffffffc0204882:	467d                	li	a2,31
ffffffffc0204884:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0204888:	c9bfe0ef          	jal	ra,ffffffffc0203522 <pgdir_alloc_page>
ffffffffc020488c:	34050b63          	beqz	a0,ffffffffc0204be2 <do_execve+0x4d4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204890:	6c88                	ld	a0,24(s1)
ffffffffc0204892:	467d                	li	a2,31
ffffffffc0204894:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0204898:	c8bfe0ef          	jal	ra,ffffffffc0203522 <pgdir_alloc_page>
ffffffffc020489c:	32050363          	beqz	a0,ffffffffc0204bc2 <do_execve+0x4b4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc02048a0:	6c88                	ld	a0,24(s1)
ffffffffc02048a2:	467d                	li	a2,31
ffffffffc02048a4:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc02048a8:	c7bfe0ef          	jal	ra,ffffffffc0203522 <pgdir_alloc_page>
ffffffffc02048ac:	2e050b63          	beqz	a0,ffffffffc0204ba2 <do_execve+0x494>
    mm->mm_count += 1;
ffffffffc02048b0:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc02048b2:	000db603          	ld	a2,0(s11)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc02048b6:	6c94                	ld	a3,24(s1)
ffffffffc02048b8:	2785                	addiw	a5,a5,1
ffffffffc02048ba:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc02048bc:	f604                	sd	s1,40(a2)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc02048be:	c02007b7          	lui	a5,0xc0200
ffffffffc02048c2:	2cf6e463          	bltu	a3,a5,ffffffffc0204b8a <do_execve+0x47c>
ffffffffc02048c6:	000b3783          	ld	a5,0(s6)
ffffffffc02048ca:	577d                	li	a4,-1
ffffffffc02048cc:	177e                	slli	a4,a4,0x3f
ffffffffc02048ce:	8e9d                	sub	a3,a3,a5
ffffffffc02048d0:	00c6d793          	srli	a5,a3,0xc
ffffffffc02048d4:	f654                	sd	a3,168(a2)
ffffffffc02048d6:	8fd9                	or	a5,a5,a4
ffffffffc02048d8:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc02048dc:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02048de:	4581                	li	a1,0
ffffffffc02048e0:	12000613          	li	a2,288
ffffffffc02048e4:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc02048e6:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02048ea:	384010ef          	jal	ra,ffffffffc0205c6e <memset>
    tf->epc = elf->e_entry;
ffffffffc02048ee:	7782                	ld	a5,32(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02048f0:	000db903          	ld	s2,0(s11)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc02048f4:	edf4f493          	andi	s1,s1,-289
    tf->epc = elf->e_entry;
ffffffffc02048f8:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc02048fa:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02048fc:	0b490913          	addi	s2,s2,180 # ffffffff800000b4 <_binary_obj___user_matrix_out_size+0xffffffff7fff398c>
    tf->gpr.sp = USTACKTOP;
ffffffffc0204900:	07fe                	slli	a5,a5,0x1f
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204902:	0204e493          	ori	s1,s1,32
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204906:	4641                	li	a2,16
ffffffffc0204908:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP;
ffffffffc020490a:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc020490c:	10e43423          	sd	a4,264(s0)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204910:	10943023          	sd	s1,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204914:	854a                	mv	a0,s2
ffffffffc0204916:	358010ef          	jal	ra,ffffffffc0205c6e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020491a:	463d                	li	a2,15
ffffffffc020491c:	180c                	addi	a1,sp,48
ffffffffc020491e:	854a                	mv	a0,s2
ffffffffc0204920:	360010ef          	jal	ra,ffffffffc0205c80 <memcpy>
}
ffffffffc0204924:	70aa                	ld	ra,168(sp)
ffffffffc0204926:	740a                	ld	s0,160(sp)
ffffffffc0204928:	64ea                	ld	s1,152(sp)
ffffffffc020492a:	694a                	ld	s2,144(sp)
ffffffffc020492c:	69aa                	ld	s3,136(sp)
ffffffffc020492e:	7ae6                	ld	s5,120(sp)
ffffffffc0204930:	7b46                	ld	s6,112(sp)
ffffffffc0204932:	7ba6                	ld	s7,104(sp)
ffffffffc0204934:	7c06                	ld	s8,96(sp)
ffffffffc0204936:	6ce6                	ld	s9,88(sp)
ffffffffc0204938:	6d46                	ld	s10,80(sp)
ffffffffc020493a:	6da6                	ld	s11,72(sp)
ffffffffc020493c:	8552                	mv	a0,s4
ffffffffc020493e:	6a0a                	ld	s4,128(sp)
ffffffffc0204940:	614d                	addi	sp,sp,176
ffffffffc0204942:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc0204944:	463d                	li	a2,15
ffffffffc0204946:	85ca                	mv	a1,s2
ffffffffc0204948:	1808                	addi	a0,sp,48
ffffffffc020494a:	336010ef          	jal	ra,ffffffffc0205c80 <memcpy>
    if (mm != NULL)
ffffffffc020494e:	e20991e3          	bnez	s3,ffffffffc0204770 <do_execve+0x62>
    if (current->mm != NULL)
ffffffffc0204952:	000db783          	ld	a5,0(s11)
ffffffffc0204956:	779c                	ld	a5,40(a5)
ffffffffc0204958:	e40788e3          	beqz	a5,ffffffffc02047a8 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc020495c:	00003617          	auipc	a2,0x3
ffffffffc0204960:	d6c60613          	addi	a2,a2,-660 # ffffffffc02076c8 <default_pmm_manager+0xbf0>
ffffffffc0204964:	25f00593          	li	a1,607
ffffffffc0204968:	00003517          	auipc	a0,0x3
ffffffffc020496c:	b9850513          	addi	a0,a0,-1128 # ffffffffc0207500 <default_pmm_manager+0xa28>
ffffffffc0204970:	b23fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    put_pgdir(mm);
ffffffffc0204974:	8526                	mv	a0,s1
ffffffffc0204976:	c48ff0ef          	jal	ra,ffffffffc0203dbe <put_pgdir>
    mm_destroy(mm);
ffffffffc020497a:	8526                	mv	a0,s1
ffffffffc020497c:	dcdfe0ef          	jal	ra,ffffffffc0203748 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0204980:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc0204982:	8552                	mv	a0,s4
ffffffffc0204984:	94bff0ef          	jal	ra,ffffffffc02042ce <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0204988:	5a71                	li	s4,-4
ffffffffc020498a:	bfe5                	j	ffffffffc0204982 <do_execve+0x274>
        if (ph->p_filesz > ph->p_memsz)
ffffffffc020498c:	0289b603          	ld	a2,40(s3)
ffffffffc0204990:	0209b783          	ld	a5,32(s3)
ffffffffc0204994:	1cf66d63          	bltu	a2,a5,ffffffffc0204b6e <do_execve+0x460>
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204998:	0049a783          	lw	a5,4(s3)
ffffffffc020499c:	0017f693          	andi	a3,a5,1
ffffffffc02049a0:	c291                	beqz	a3,ffffffffc02049a4 <do_execve+0x296>
            vm_flags |= VM_EXEC;
ffffffffc02049a2:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc02049a4:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc02049a8:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc02049aa:	e779                	bnez	a4,ffffffffc0204a78 <do_execve+0x36a>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc02049ac:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc02049ae:	c781                	beqz	a5,ffffffffc02049b6 <do_execve+0x2a8>
            vm_flags |= VM_READ;
ffffffffc02049b0:	0016e693          	ori	a3,a3,1
            perm |= PTE_R;
ffffffffc02049b4:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE)
ffffffffc02049b6:	0026f793          	andi	a5,a3,2
ffffffffc02049ba:	e3f1                	bnez	a5,ffffffffc0204a7e <do_execve+0x370>
        if (vm_flags & VM_EXEC)
ffffffffc02049bc:	0046f793          	andi	a5,a3,4
ffffffffc02049c0:	c399                	beqz	a5,ffffffffc02049c6 <do_execve+0x2b8>
            perm |= PTE_X;
ffffffffc02049c2:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc02049c6:	0109b583          	ld	a1,16(s3)
ffffffffc02049ca:	4701                	li	a4,0
ffffffffc02049cc:	8526                	mv	a0,s1
ffffffffc02049ce:	dcdfe0ef          	jal	ra,ffffffffc020379a <mm_map>
ffffffffc02049d2:	8a2a                	mv	s4,a0
ffffffffc02049d4:	ed35                	bnez	a0,ffffffffc0204a50 <do_execve+0x342>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02049d6:	0109bb83          	ld	s7,16(s3)
ffffffffc02049da:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc02049dc:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc02049e0:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02049e4:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc02049e8:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc02049ea:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc02049ec:	993e                	add	s2,s2,a5
        while (start < end)
ffffffffc02049ee:	054be963          	bltu	s7,s4,ffffffffc0204a40 <do_execve+0x332>
ffffffffc02049f2:	aa95                	j	ffffffffc0204b66 <do_execve+0x458>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc02049f4:	6785                	lui	a5,0x1
ffffffffc02049f6:	415b8533          	sub	a0,s7,s5
ffffffffc02049fa:	9abe                	add	s5,s5,a5
ffffffffc02049fc:	417a8633          	sub	a2,s5,s7
            if (end < la)
ffffffffc0204a00:	015a7463          	bgeu	s4,s5,ffffffffc0204a08 <do_execve+0x2fa>
                size -= la - end;
ffffffffc0204a04:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc0204a08:	000cb683          	ld	a3,0(s9)
ffffffffc0204a0c:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204a0e:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204a12:	40d406b3          	sub	a3,s0,a3
ffffffffc0204a16:	8699                	srai	a3,a3,0x6
ffffffffc0204a18:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204a1a:	67e2                	ld	a5,24(sp)
ffffffffc0204a1c:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204a20:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204a22:	14b87863          	bgeu	a6,a1,ffffffffc0204b72 <do_execve+0x464>
ffffffffc0204a26:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204a2a:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0204a2c:	9bb2                	add	s7,s7,a2
ffffffffc0204a2e:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204a30:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0204a32:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204a34:	24c010ef          	jal	ra,ffffffffc0205c80 <memcpy>
            start += size, from += size;
ffffffffc0204a38:	6622                	ld	a2,8(sp)
ffffffffc0204a3a:	9932                	add	s2,s2,a2
        while (start < end)
ffffffffc0204a3c:	054bf363          	bgeu	s7,s4,ffffffffc0204a82 <do_execve+0x374>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204a40:	6c88                	ld	a0,24(s1)
ffffffffc0204a42:	866a                	mv	a2,s10
ffffffffc0204a44:	85d6                	mv	a1,s5
ffffffffc0204a46:	addfe0ef          	jal	ra,ffffffffc0203522 <pgdir_alloc_page>
ffffffffc0204a4a:	842a                	mv	s0,a0
ffffffffc0204a4c:	f545                	bnez	a0,ffffffffc02049f4 <do_execve+0x2e6>
        ret = -E_NO_MEM;
ffffffffc0204a4e:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0204a50:	8526                	mv	a0,s1
ffffffffc0204a52:	e93fe0ef          	jal	ra,ffffffffc02038e4 <exit_mmap>
    put_pgdir(mm);
ffffffffc0204a56:	8526                	mv	a0,s1
ffffffffc0204a58:	b66ff0ef          	jal	ra,ffffffffc0203dbe <put_pgdir>
    mm_destroy(mm);
ffffffffc0204a5c:	8526                	mv	a0,s1
ffffffffc0204a5e:	cebfe0ef          	jal	ra,ffffffffc0203748 <mm_destroy>
    return ret;
ffffffffc0204a62:	b705                	j	ffffffffc0204982 <do_execve+0x274>
            exit_mmap(mm);
ffffffffc0204a64:	854e                	mv	a0,s3
ffffffffc0204a66:	e7ffe0ef          	jal	ra,ffffffffc02038e4 <exit_mmap>
            put_pgdir(mm);
ffffffffc0204a6a:	854e                	mv	a0,s3
ffffffffc0204a6c:	b52ff0ef          	jal	ra,ffffffffc0203dbe <put_pgdir>
            mm_destroy(mm);
ffffffffc0204a70:	854e                	mv	a0,s3
ffffffffc0204a72:	cd7fe0ef          	jal	ra,ffffffffc0203748 <mm_destroy>
ffffffffc0204a76:	b32d                	j	ffffffffc02047a0 <do_execve+0x92>
            vm_flags |= VM_WRITE;
ffffffffc0204a78:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204a7c:	fb95                	bnez	a5,ffffffffc02049b0 <do_execve+0x2a2>
            perm |= (PTE_W | PTE_R);
ffffffffc0204a7e:	4d5d                	li	s10,23
ffffffffc0204a80:	bf35                	j	ffffffffc02049bc <do_execve+0x2ae>
        end = ph->p_va + ph->p_memsz;
ffffffffc0204a82:	0109b683          	ld	a3,16(s3)
ffffffffc0204a86:	0289b903          	ld	s2,40(s3)
ffffffffc0204a8a:	9936                	add	s2,s2,a3
        if (start < la)
ffffffffc0204a8c:	075bfd63          	bgeu	s7,s5,ffffffffc0204b06 <do_execve+0x3f8>
            if (start == end)
ffffffffc0204a90:	db790fe3          	beq	s2,s7,ffffffffc020484e <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204a94:	6785                	lui	a5,0x1
ffffffffc0204a96:	00fb8533          	add	a0,s7,a5
ffffffffc0204a9a:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0204a9e:	41790a33          	sub	s4,s2,s7
            if (end < la)
ffffffffc0204aa2:	0b597d63          	bgeu	s2,s5,ffffffffc0204b5c <do_execve+0x44e>
    return page - pages + nbase;
ffffffffc0204aa6:	000cb683          	ld	a3,0(s9)
ffffffffc0204aaa:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204aac:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0204ab0:	40d406b3          	sub	a3,s0,a3
ffffffffc0204ab4:	8699                	srai	a3,a3,0x6
ffffffffc0204ab6:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204ab8:	67e2                	ld	a5,24(sp)
ffffffffc0204aba:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204abe:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204ac0:	0ac5f963          	bgeu	a1,a2,ffffffffc0204b72 <do_execve+0x464>
ffffffffc0204ac4:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204ac8:	8652                	mv	a2,s4
ffffffffc0204aca:	4581                	li	a1,0
ffffffffc0204acc:	96c2                	add	a3,a3,a6
ffffffffc0204ace:	9536                	add	a0,a0,a3
ffffffffc0204ad0:	19e010ef          	jal	ra,ffffffffc0205c6e <memset>
            start += size;
ffffffffc0204ad4:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0204ad8:	03597463          	bgeu	s2,s5,ffffffffc0204b00 <do_execve+0x3f2>
ffffffffc0204adc:	d6e909e3          	beq	s2,a4,ffffffffc020484e <do_execve+0x140>
ffffffffc0204ae0:	00003697          	auipc	a3,0x3
ffffffffc0204ae4:	c1068693          	addi	a3,a3,-1008 # ffffffffc02076f0 <default_pmm_manager+0xc18>
ffffffffc0204ae8:	00002617          	auipc	a2,0x2
ffffffffc0204aec:	c4060613          	addi	a2,a2,-960 # ffffffffc0206728 <commands+0x828>
ffffffffc0204af0:	2c800593          	li	a1,712
ffffffffc0204af4:	00003517          	auipc	a0,0x3
ffffffffc0204af8:	a0c50513          	addi	a0,a0,-1524 # ffffffffc0207500 <default_pmm_manager+0xa28>
ffffffffc0204afc:	997fb0ef          	jal	ra,ffffffffc0200492 <__panic>
ffffffffc0204b00:	ff5710e3          	bne	a4,s5,ffffffffc0204ae0 <do_execve+0x3d2>
ffffffffc0204b04:	8bd6                	mv	s7,s5
        while (start < end)
ffffffffc0204b06:	d52bf4e3          	bgeu	s7,s2,ffffffffc020484e <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204b0a:	6c88                	ld	a0,24(s1)
ffffffffc0204b0c:	866a                	mv	a2,s10
ffffffffc0204b0e:	85d6                	mv	a1,s5
ffffffffc0204b10:	a13fe0ef          	jal	ra,ffffffffc0203522 <pgdir_alloc_page>
ffffffffc0204b14:	842a                	mv	s0,a0
ffffffffc0204b16:	dd05                	beqz	a0,ffffffffc0204a4e <do_execve+0x340>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204b18:	6785                	lui	a5,0x1
ffffffffc0204b1a:	415b8533          	sub	a0,s7,s5
ffffffffc0204b1e:	9abe                	add	s5,s5,a5
ffffffffc0204b20:	417a8633          	sub	a2,s5,s7
            if (end < la)
ffffffffc0204b24:	01597463          	bgeu	s2,s5,ffffffffc0204b2c <do_execve+0x41e>
                size -= la - end;
ffffffffc0204b28:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0204b2c:	000cb683          	ld	a3,0(s9)
ffffffffc0204b30:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204b32:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204b36:	40d406b3          	sub	a3,s0,a3
ffffffffc0204b3a:	8699                	srai	a3,a3,0x6
ffffffffc0204b3c:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204b3e:	67e2                	ld	a5,24(sp)
ffffffffc0204b40:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b44:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204b46:	02b87663          	bgeu	a6,a1,ffffffffc0204b72 <do_execve+0x464>
ffffffffc0204b4a:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204b4e:	4581                	li	a1,0
            start += size;
ffffffffc0204b50:	9bb2                	add	s7,s7,a2
ffffffffc0204b52:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0204b54:	9536                	add	a0,a0,a3
ffffffffc0204b56:	118010ef          	jal	ra,ffffffffc0205c6e <memset>
ffffffffc0204b5a:	b775                	j	ffffffffc0204b06 <do_execve+0x3f8>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204b5c:	417a8a33          	sub	s4,s5,s7
ffffffffc0204b60:	b799                	j	ffffffffc0204aa6 <do_execve+0x398>
        return -E_INVAL;
ffffffffc0204b62:	5a75                	li	s4,-3
ffffffffc0204b64:	b3c1                	j	ffffffffc0204924 <do_execve+0x216>
        while (start < end)
ffffffffc0204b66:	86de                	mv	a3,s7
ffffffffc0204b68:	bf39                	j	ffffffffc0204a86 <do_execve+0x378>
    int ret = -E_NO_MEM;
ffffffffc0204b6a:	5a71                	li	s4,-4
ffffffffc0204b6c:	bdc5                	j	ffffffffc0204a5c <do_execve+0x34e>
            ret = -E_INVAL_ELF;
ffffffffc0204b6e:	5a61                	li	s4,-8
ffffffffc0204b70:	b5c5                	j	ffffffffc0204a50 <do_execve+0x342>
ffffffffc0204b72:	00002617          	auipc	a2,0x2
ffffffffc0204b76:	f9e60613          	addi	a2,a2,-98 # ffffffffc0206b10 <default_pmm_manager+0x38>
ffffffffc0204b7a:	07100593          	li	a1,113
ffffffffc0204b7e:	00002517          	auipc	a0,0x2
ffffffffc0204b82:	fba50513          	addi	a0,a0,-70 # ffffffffc0206b38 <default_pmm_manager+0x60>
ffffffffc0204b86:	90dfb0ef          	jal	ra,ffffffffc0200492 <__panic>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204b8a:	00002617          	auipc	a2,0x2
ffffffffc0204b8e:	02e60613          	addi	a2,a2,46 # ffffffffc0206bb8 <default_pmm_manager+0xe0>
ffffffffc0204b92:	2e700593          	li	a1,743
ffffffffc0204b96:	00003517          	auipc	a0,0x3
ffffffffc0204b9a:	96a50513          	addi	a0,a0,-1686 # ffffffffc0207500 <default_pmm_manager+0xa28>
ffffffffc0204b9e:	8f5fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204ba2:	00003697          	auipc	a3,0x3
ffffffffc0204ba6:	c6668693          	addi	a3,a3,-922 # ffffffffc0207808 <default_pmm_manager+0xd30>
ffffffffc0204baa:	00002617          	auipc	a2,0x2
ffffffffc0204bae:	b7e60613          	addi	a2,a2,-1154 # ffffffffc0206728 <commands+0x828>
ffffffffc0204bb2:	2e200593          	li	a1,738
ffffffffc0204bb6:	00003517          	auipc	a0,0x3
ffffffffc0204bba:	94a50513          	addi	a0,a0,-1718 # ffffffffc0207500 <default_pmm_manager+0xa28>
ffffffffc0204bbe:	8d5fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204bc2:	00003697          	auipc	a3,0x3
ffffffffc0204bc6:	bfe68693          	addi	a3,a3,-1026 # ffffffffc02077c0 <default_pmm_manager+0xce8>
ffffffffc0204bca:	00002617          	auipc	a2,0x2
ffffffffc0204bce:	b5e60613          	addi	a2,a2,-1186 # ffffffffc0206728 <commands+0x828>
ffffffffc0204bd2:	2e100593          	li	a1,737
ffffffffc0204bd6:	00003517          	auipc	a0,0x3
ffffffffc0204bda:	92a50513          	addi	a0,a0,-1750 # ffffffffc0207500 <default_pmm_manager+0xa28>
ffffffffc0204bde:	8b5fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204be2:	00003697          	auipc	a3,0x3
ffffffffc0204be6:	b9668693          	addi	a3,a3,-1130 # ffffffffc0207778 <default_pmm_manager+0xca0>
ffffffffc0204bea:	00002617          	auipc	a2,0x2
ffffffffc0204bee:	b3e60613          	addi	a2,a2,-1218 # ffffffffc0206728 <commands+0x828>
ffffffffc0204bf2:	2e000593          	li	a1,736
ffffffffc0204bf6:	00003517          	auipc	a0,0x3
ffffffffc0204bfa:	90a50513          	addi	a0,a0,-1782 # ffffffffc0207500 <default_pmm_manager+0xa28>
ffffffffc0204bfe:	895fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204c02:	00003697          	auipc	a3,0x3
ffffffffc0204c06:	b2e68693          	addi	a3,a3,-1234 # ffffffffc0207730 <default_pmm_manager+0xc58>
ffffffffc0204c0a:	00002617          	auipc	a2,0x2
ffffffffc0204c0e:	b1e60613          	addi	a2,a2,-1250 # ffffffffc0206728 <commands+0x828>
ffffffffc0204c12:	2df00593          	li	a1,735
ffffffffc0204c16:	00003517          	auipc	a0,0x3
ffffffffc0204c1a:	8ea50513          	addi	a0,a0,-1814 # ffffffffc0207500 <default_pmm_manager+0xa28>
ffffffffc0204c1e:	875fb0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0204c22 <user_main>:
{
ffffffffc0204c22:	1101                	addi	sp,sp,-32
ffffffffc0204c24:	e04a                	sd	s2,0(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204c26:	000ce917          	auipc	s2,0xce
ffffffffc0204c2a:	b9a90913          	addi	s2,s2,-1126 # ffffffffc02d27c0 <current>
ffffffffc0204c2e:	00093783          	ld	a5,0(s2)
ffffffffc0204c32:	00003617          	auipc	a2,0x3
ffffffffc0204c36:	c1e60613          	addi	a2,a2,-994 # ffffffffc0207850 <default_pmm_manager+0xd78>
ffffffffc0204c3a:	00003517          	auipc	a0,0x3
ffffffffc0204c3e:	c2650513          	addi	a0,a0,-986 # ffffffffc0207860 <default_pmm_manager+0xd88>
ffffffffc0204c42:	43cc                	lw	a1,4(a5)
{
ffffffffc0204c44:	ec06                	sd	ra,24(sp)
ffffffffc0204c46:	e822                	sd	s0,16(sp)
ffffffffc0204c48:	e426                	sd	s1,8(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204c4a:	d4efb0ef          	jal	ra,ffffffffc0200198 <cprintf>
    size_t len = strlen(name);
ffffffffc0204c4e:	00003517          	auipc	a0,0x3
ffffffffc0204c52:	c0250513          	addi	a0,a0,-1022 # ffffffffc0207850 <default_pmm_manager+0xd78>
ffffffffc0204c56:	777000ef          	jal	ra,ffffffffc0205bcc <strlen>
    struct trapframe *old_tf = current->tf;
ffffffffc0204c5a:	00093783          	ld	a5,0(s2)
    size_t len = strlen(name);
ffffffffc0204c5e:	84aa                	mv	s1,a0
    memcpy(new_tf, old_tf, sizeof(struct trapframe));
ffffffffc0204c60:	12000613          	li	a2,288
    struct trapframe *new_tf = (struct trapframe *)(current->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204c64:	6b80                	ld	s0,16(a5)
    memcpy(new_tf, old_tf, sizeof(struct trapframe));
ffffffffc0204c66:	73cc                	ld	a1,160(a5)
    struct trapframe *new_tf = (struct trapframe *)(current->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204c68:	6789                	lui	a5,0x2
ffffffffc0204c6a:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x8070>
ffffffffc0204c6e:	943e                	add	s0,s0,a5
    memcpy(new_tf, old_tf, sizeof(struct trapframe));
ffffffffc0204c70:	8522                	mv	a0,s0
ffffffffc0204c72:	00e010ef          	jal	ra,ffffffffc0205c80 <memcpy>
    current->tf = new_tf;
ffffffffc0204c76:	00093783          	ld	a5,0(s2)
    ret = do_execve(name, len, binary, size);
ffffffffc0204c7a:	3fe07697          	auipc	a3,0x3fe07
ffffffffc0204c7e:	de668693          	addi	a3,a3,-538 # ba60 <_binary_obj___user_sched_test_out_size>
ffffffffc0204c82:	00089617          	auipc	a2,0x89
ffffffffc0204c86:	8e660613          	addi	a2,a2,-1818 # ffffffffc028d568 <_binary_obj___user_sched_test_out_start>
    current->tf = new_tf;
ffffffffc0204c8a:	f3c0                	sd	s0,160(a5)
    ret = do_execve(name, len, binary, size);
ffffffffc0204c8c:	85a6                	mv	a1,s1
ffffffffc0204c8e:	00003517          	auipc	a0,0x3
ffffffffc0204c92:	bc250513          	addi	a0,a0,-1086 # ffffffffc0207850 <default_pmm_manager+0xd78>
ffffffffc0204c96:	a79ff0ef          	jal	ra,ffffffffc020470e <do_execve>
    asm volatile(
ffffffffc0204c9a:	8122                	mv	sp,s0
ffffffffc0204c9c:	a2cfc06f          	j	ffffffffc0200ec8 <__trapret>
    panic("user_main execve failed.\n");
ffffffffc0204ca0:	00003617          	auipc	a2,0x3
ffffffffc0204ca4:	be860613          	addi	a2,a2,-1048 # ffffffffc0207888 <default_pmm_manager+0xdb0>
ffffffffc0204ca8:	3cd00593          	li	a1,973
ffffffffc0204cac:	00003517          	auipc	a0,0x3
ffffffffc0204cb0:	85450513          	addi	a0,a0,-1964 # ffffffffc0207500 <default_pmm_manager+0xa28>
ffffffffc0204cb4:	fdefb0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0204cb8 <do_yield>:
    current->need_resched = 1;
ffffffffc0204cb8:	000ce797          	auipc	a5,0xce
ffffffffc0204cbc:	b087b783          	ld	a5,-1272(a5) # ffffffffc02d27c0 <current>
ffffffffc0204cc0:	4705                	li	a4,1
ffffffffc0204cc2:	ef98                	sd	a4,24(a5)
}
ffffffffc0204cc4:	4501                	li	a0,0
ffffffffc0204cc6:	8082                	ret

ffffffffc0204cc8 <do_wait>:
{
ffffffffc0204cc8:	1101                	addi	sp,sp,-32
ffffffffc0204cca:	e822                	sd	s0,16(sp)
ffffffffc0204ccc:	e426                	sd	s1,8(sp)
ffffffffc0204cce:	ec06                	sd	ra,24(sp)
ffffffffc0204cd0:	842e                	mv	s0,a1
ffffffffc0204cd2:	84aa                	mv	s1,a0
    if (code_store != NULL)
ffffffffc0204cd4:	c999                	beqz	a1,ffffffffc0204cea <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0204cd6:	000ce797          	auipc	a5,0xce
ffffffffc0204cda:	aea7b783          	ld	a5,-1302(a5) # ffffffffc02d27c0 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0204cde:	7788                	ld	a0,40(a5)
ffffffffc0204ce0:	4685                	li	a3,1
ffffffffc0204ce2:	4611                	li	a2,4
ffffffffc0204ce4:	f9bfe0ef          	jal	ra,ffffffffc0203c7e <user_mem_check>
ffffffffc0204ce8:	c909                	beqz	a0,ffffffffc0204cfa <do_wait+0x32>
ffffffffc0204cea:	85a2                	mv	a1,s0
}
ffffffffc0204cec:	6442                	ld	s0,16(sp)
ffffffffc0204cee:	60e2                	ld	ra,24(sp)
ffffffffc0204cf0:	8526                	mv	a0,s1
ffffffffc0204cf2:	64a2                	ld	s1,8(sp)
ffffffffc0204cf4:	6105                	addi	sp,sp,32
ffffffffc0204cf6:	f22ff06f          	j	ffffffffc0204418 <do_wait.part.0>
ffffffffc0204cfa:	60e2                	ld	ra,24(sp)
ffffffffc0204cfc:	6442                	ld	s0,16(sp)
ffffffffc0204cfe:	64a2                	ld	s1,8(sp)
ffffffffc0204d00:	5575                	li	a0,-3
ffffffffc0204d02:	6105                	addi	sp,sp,32
ffffffffc0204d04:	8082                	ret

ffffffffc0204d06 <do_kill>:
{
ffffffffc0204d06:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID)
ffffffffc0204d08:	6789                	lui	a5,0x2
{
ffffffffc0204d0a:	e406                	sd	ra,8(sp)
ffffffffc0204d0c:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID)
ffffffffc0204d0e:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204d12:	17f9                	addi	a5,a5,-2
ffffffffc0204d14:	02e7e963          	bltu	a5,a4,ffffffffc0204d46 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204d18:	842a                	mv	s0,a0
ffffffffc0204d1a:	45a9                	li	a1,10
ffffffffc0204d1c:	2501                	sext.w	a0,a0
ffffffffc0204d1e:	2ab000ef          	jal	ra,ffffffffc02057c8 <hash32>
ffffffffc0204d22:	02051793          	slli	a5,a0,0x20
ffffffffc0204d26:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204d2a:	000ca797          	auipc	a5,0xca
ffffffffc0204d2e:	9f678793          	addi	a5,a5,-1546 # ffffffffc02ce720 <hash_list>
ffffffffc0204d32:	953e                	add	a0,a0,a5
ffffffffc0204d34:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list)
ffffffffc0204d36:	a029                	j	ffffffffc0204d40 <do_kill+0x3a>
            if (proc->pid == pid)
ffffffffc0204d38:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0204d3c:	00870b63          	beq	a4,s0,ffffffffc0204d52 <do_kill+0x4c>
ffffffffc0204d40:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204d42:	fef51be3          	bne	a0,a5,ffffffffc0204d38 <do_kill+0x32>
    return -E_INVAL;
ffffffffc0204d46:	5475                	li	s0,-3
}
ffffffffc0204d48:	60a2                	ld	ra,8(sp)
ffffffffc0204d4a:	8522                	mv	a0,s0
ffffffffc0204d4c:	6402                	ld	s0,0(sp)
ffffffffc0204d4e:	0141                	addi	sp,sp,16
ffffffffc0204d50:	8082                	ret
        if (!(proc->flags & PF_EXITING))
ffffffffc0204d52:	fd87a703          	lw	a4,-40(a5)
ffffffffc0204d56:	00177693          	andi	a3,a4,1
ffffffffc0204d5a:	e295                	bnez	a3,ffffffffc0204d7e <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0204d5c:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0204d5e:	00176713          	ori	a4,a4,1
ffffffffc0204d62:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0204d66:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0204d68:	fe06d0e3          	bgez	a3,ffffffffc0204d48 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0204d6c:	f2878513          	addi	a0,a5,-216
ffffffffc0204d70:	7e6000ef          	jal	ra,ffffffffc0205556 <wakeup_proc>
}
ffffffffc0204d74:	60a2                	ld	ra,8(sp)
ffffffffc0204d76:	8522                	mv	a0,s0
ffffffffc0204d78:	6402                	ld	s0,0(sp)
ffffffffc0204d7a:	0141                	addi	sp,sp,16
ffffffffc0204d7c:	8082                	ret
        return -E_KILLED;
ffffffffc0204d7e:	545d                	li	s0,-9
ffffffffc0204d80:	b7e1                	j	ffffffffc0204d48 <do_kill+0x42>

ffffffffc0204d82 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc0204d82:	1101                	addi	sp,sp,-32
ffffffffc0204d84:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0204d86:	000ce797          	auipc	a5,0xce
ffffffffc0204d8a:	99a78793          	addi	a5,a5,-1638 # ffffffffc02d2720 <proc_list>
ffffffffc0204d8e:	ec06                	sd	ra,24(sp)
ffffffffc0204d90:	e822                	sd	s0,16(sp)
ffffffffc0204d92:	e04a                	sd	s2,0(sp)
ffffffffc0204d94:	000ca497          	auipc	s1,0xca
ffffffffc0204d98:	98c48493          	addi	s1,s1,-1652 # ffffffffc02ce720 <hash_list>
ffffffffc0204d9c:	e79c                	sd	a5,8(a5)
ffffffffc0204d9e:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0204da0:	000ce717          	auipc	a4,0xce
ffffffffc0204da4:	98070713          	addi	a4,a4,-1664 # ffffffffc02d2720 <proc_list>
ffffffffc0204da8:	87a6                	mv	a5,s1
ffffffffc0204daa:	e79c                	sd	a5,8(a5)
ffffffffc0204dac:	e39c                	sd	a5,0(a5)
ffffffffc0204dae:	07c1                	addi	a5,a5,16
ffffffffc0204db0:	fef71de3          	bne	a4,a5,ffffffffc0204daa <proc_init+0x28>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc0204db4:	f67fe0ef          	jal	ra,ffffffffc0203d1a <alloc_proc>
ffffffffc0204db8:	000ce917          	auipc	s2,0xce
ffffffffc0204dbc:	a1090913          	addi	s2,s2,-1520 # ffffffffc02d27c8 <idleproc>
ffffffffc0204dc0:	00a93023          	sd	a0,0(s2)
ffffffffc0204dc4:	0e050f63          	beqz	a0,ffffffffc0204ec2 <proc_init+0x140>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0204dc8:	4789                	li	a5,2
ffffffffc0204dca:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204dcc:	00004797          	auipc	a5,0x4
ffffffffc0204dd0:	23478793          	addi	a5,a5,564 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204dd4:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204dd8:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0204dda:	4785                	li	a5,1
ffffffffc0204ddc:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204dde:	4641                	li	a2,16
ffffffffc0204de0:	4581                	li	a1,0
ffffffffc0204de2:	8522                	mv	a0,s0
ffffffffc0204de4:	68b000ef          	jal	ra,ffffffffc0205c6e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204de8:	463d                	li	a2,15
ffffffffc0204dea:	00003597          	auipc	a1,0x3
ffffffffc0204dee:	ad658593          	addi	a1,a1,-1322 # ffffffffc02078c0 <default_pmm_manager+0xde8>
ffffffffc0204df2:	8522                	mv	a0,s0
ffffffffc0204df4:	68d000ef          	jal	ra,ffffffffc0205c80 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process++;
ffffffffc0204df8:	000ce717          	auipc	a4,0xce
ffffffffc0204dfc:	9e070713          	addi	a4,a4,-1568 # ffffffffc02d27d8 <nr_process>
ffffffffc0204e00:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0204e02:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0204e06:	4601                	li	a2,0
    nr_process++;
ffffffffc0204e08:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0204e0a:	4581                	li	a1,0
ffffffffc0204e0c:	fffff517          	auipc	a0,0xfffff
ffffffffc0204e10:	7de50513          	addi	a0,a0,2014 # ffffffffc02045ea <init_main>
    nr_process++;
ffffffffc0204e14:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0204e16:	000ce797          	auipc	a5,0xce
ffffffffc0204e1a:	9ad7b523          	sd	a3,-1622(a5) # ffffffffc02d27c0 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0204e1e:	c60ff0ef          	jal	ra,ffffffffc020427e <kernel_thread>
ffffffffc0204e22:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc0204e24:	08a05363          	blez	a0,ffffffffc0204eaa <proc_init+0x128>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204e28:	6789                	lui	a5,0x2
ffffffffc0204e2a:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204e2e:	17f9                	addi	a5,a5,-2
ffffffffc0204e30:	2501                	sext.w	a0,a0
ffffffffc0204e32:	02e7e363          	bltu	a5,a4,ffffffffc0204e58 <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204e36:	45a9                	li	a1,10
ffffffffc0204e38:	191000ef          	jal	ra,ffffffffc02057c8 <hash32>
ffffffffc0204e3c:	02051793          	slli	a5,a0,0x20
ffffffffc0204e40:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0204e44:	96a6                	add	a3,a3,s1
ffffffffc0204e46:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0204e48:	a029                	j	ffffffffc0204e52 <proc_init+0xd0>
            if (proc->pid == pid)
ffffffffc0204e4a:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x8024>
ffffffffc0204e4e:	04870b63          	beq	a4,s0,ffffffffc0204ea4 <proc_init+0x122>
    return listelm->next;
ffffffffc0204e52:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204e54:	fef69be3          	bne	a3,a5,ffffffffc0204e4a <proc_init+0xc8>
    return NULL;
ffffffffc0204e58:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e5a:	0b478493          	addi	s1,a5,180
ffffffffc0204e5e:	4641                	li	a2,16
ffffffffc0204e60:	4581                	li	a1,0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0204e62:	000ce417          	auipc	s0,0xce
ffffffffc0204e66:	96e40413          	addi	s0,s0,-1682 # ffffffffc02d27d0 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e6a:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0204e6c:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e6e:	601000ef          	jal	ra,ffffffffc0205c6e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204e72:	463d                	li	a2,15
ffffffffc0204e74:	00003597          	auipc	a1,0x3
ffffffffc0204e78:	a7458593          	addi	a1,a1,-1420 # ffffffffc02078e8 <default_pmm_manager+0xe10>
ffffffffc0204e7c:	8526                	mv	a0,s1
ffffffffc0204e7e:	603000ef          	jal	ra,ffffffffc0205c80 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204e82:	00093783          	ld	a5,0(s2)
ffffffffc0204e86:	cbb5                	beqz	a5,ffffffffc0204efa <proc_init+0x178>
ffffffffc0204e88:	43dc                	lw	a5,4(a5)
ffffffffc0204e8a:	eba5                	bnez	a5,ffffffffc0204efa <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204e8c:	601c                	ld	a5,0(s0)
ffffffffc0204e8e:	c7b1                	beqz	a5,ffffffffc0204eda <proc_init+0x158>
ffffffffc0204e90:	43d8                	lw	a4,4(a5)
ffffffffc0204e92:	4785                	li	a5,1
ffffffffc0204e94:	04f71363          	bne	a4,a5,ffffffffc0204eda <proc_init+0x158>
}
ffffffffc0204e98:	60e2                	ld	ra,24(sp)
ffffffffc0204e9a:	6442                	ld	s0,16(sp)
ffffffffc0204e9c:	64a2                	ld	s1,8(sp)
ffffffffc0204e9e:	6902                	ld	s2,0(sp)
ffffffffc0204ea0:	6105                	addi	sp,sp,32
ffffffffc0204ea2:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204ea4:	f2878793          	addi	a5,a5,-216
ffffffffc0204ea8:	bf4d                	j	ffffffffc0204e5a <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0204eaa:	00003617          	auipc	a2,0x3
ffffffffc0204eae:	a1e60613          	addi	a2,a2,-1506 # ffffffffc02078c8 <default_pmm_manager+0xdf0>
ffffffffc0204eb2:	40a00593          	li	a1,1034
ffffffffc0204eb6:	00002517          	auipc	a0,0x2
ffffffffc0204eba:	64a50513          	addi	a0,a0,1610 # ffffffffc0207500 <default_pmm_manager+0xa28>
ffffffffc0204ebe:	dd4fb0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0204ec2:	00003617          	auipc	a2,0x3
ffffffffc0204ec6:	9e660613          	addi	a2,a2,-1562 # ffffffffc02078a8 <default_pmm_manager+0xdd0>
ffffffffc0204eca:	3fb00593          	li	a1,1019
ffffffffc0204ece:	00002517          	auipc	a0,0x2
ffffffffc0204ed2:	63250513          	addi	a0,a0,1586 # ffffffffc0207500 <default_pmm_manager+0xa28>
ffffffffc0204ed6:	dbcfb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204eda:	00003697          	auipc	a3,0x3
ffffffffc0204ede:	a3e68693          	addi	a3,a3,-1474 # ffffffffc0207918 <default_pmm_manager+0xe40>
ffffffffc0204ee2:	00002617          	auipc	a2,0x2
ffffffffc0204ee6:	84660613          	addi	a2,a2,-1978 # ffffffffc0206728 <commands+0x828>
ffffffffc0204eea:	41100593          	li	a1,1041
ffffffffc0204eee:	00002517          	auipc	a0,0x2
ffffffffc0204ef2:	61250513          	addi	a0,a0,1554 # ffffffffc0207500 <default_pmm_manager+0xa28>
ffffffffc0204ef6:	d9cfb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204efa:	00003697          	auipc	a3,0x3
ffffffffc0204efe:	9f668693          	addi	a3,a3,-1546 # ffffffffc02078f0 <default_pmm_manager+0xe18>
ffffffffc0204f02:	00002617          	auipc	a2,0x2
ffffffffc0204f06:	82660613          	addi	a2,a2,-2010 # ffffffffc0206728 <commands+0x828>
ffffffffc0204f0a:	41000593          	li	a1,1040
ffffffffc0204f0e:	00002517          	auipc	a0,0x2
ffffffffc0204f12:	5f250513          	addi	a0,a0,1522 # ffffffffc0207500 <default_pmm_manager+0xa28>
ffffffffc0204f16:	d7cfb0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0204f1a <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc0204f1a:	1141                	addi	sp,sp,-16
ffffffffc0204f1c:	e022                	sd	s0,0(sp)
ffffffffc0204f1e:	e406                	sd	ra,8(sp)
ffffffffc0204f20:	000ce417          	auipc	s0,0xce
ffffffffc0204f24:	8a040413          	addi	s0,s0,-1888 # ffffffffc02d27c0 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc0204f28:	6018                	ld	a4,0(s0)
ffffffffc0204f2a:	6f1c                	ld	a5,24(a4)
ffffffffc0204f2c:	dffd                	beqz	a5,ffffffffc0204f2a <cpu_idle+0x10>
        {
            schedule();
ffffffffc0204f2e:	6da000ef          	jal	ra,ffffffffc0205608 <schedule>
ffffffffc0204f32:	bfdd                	j	ffffffffc0204f28 <cpu_idle+0xe>

ffffffffc0204f34 <lab6_set_priority>:
        }
    }
}
// FOR LAB6, set the process's priority (bigger value will get more CPU time)
void lab6_set_priority(uint32_t priority)
{
ffffffffc0204f34:	1141                	addi	sp,sp,-16
ffffffffc0204f36:	e022                	sd	s0,0(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc0204f38:	85aa                	mv	a1,a0
{
ffffffffc0204f3a:	842a                	mv	s0,a0
    cprintf("set priority to %d\n", priority);
ffffffffc0204f3c:	00003517          	auipc	a0,0x3
ffffffffc0204f40:	a0450513          	addi	a0,a0,-1532 # ffffffffc0207940 <default_pmm_manager+0xe68>
{
ffffffffc0204f44:	e406                	sd	ra,8(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc0204f46:	a52fb0ef          	jal	ra,ffffffffc0200198 <cprintf>
    if (priority == 0)
        current->lab6_priority = 1;
ffffffffc0204f4a:	000ce797          	auipc	a5,0xce
ffffffffc0204f4e:	8767b783          	ld	a5,-1930(a5) # ffffffffc02d27c0 <current>
    if (priority == 0)
ffffffffc0204f52:	e801                	bnez	s0,ffffffffc0204f62 <lab6_set_priority+0x2e>
    else
        current->lab6_priority = priority;
}
ffffffffc0204f54:	60a2                	ld	ra,8(sp)
ffffffffc0204f56:	6402                	ld	s0,0(sp)
        current->lab6_priority = 1;
ffffffffc0204f58:	4705                	li	a4,1
ffffffffc0204f5a:	14e7a223          	sw	a4,324(a5)
}
ffffffffc0204f5e:	0141                	addi	sp,sp,16
ffffffffc0204f60:	8082                	ret
ffffffffc0204f62:	60a2                	ld	ra,8(sp)
        current->lab6_priority = priority;
ffffffffc0204f64:	1487a223          	sw	s0,324(a5)
}
ffffffffc0204f68:	6402                	ld	s0,0(sp)
ffffffffc0204f6a:	0141                	addi	sp,sp,16
ffffffffc0204f6c:	8082                	ret

ffffffffc0204f6e <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204f6e:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204f72:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204f76:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204f78:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204f7a:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204f7e:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204f82:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204f86:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204f8a:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204f8e:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204f92:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204f96:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204f9a:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204f9e:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204fa2:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204fa6:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204faa:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204fac:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204fae:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204fb2:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204fb6:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204fba:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204fbe:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204fc2:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204fc6:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204fca:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204fce:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204fd2:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204fd6:	8082                	ret

ffffffffc0204fd8 <stride_init>:
    elm->prev = elm->next = elm;
ffffffffc0204fd8:	e508                	sd	a0,8(a0)
ffffffffc0204fda:	e108                	sd	a0,0(a0)
      * (1) init the ready process list: rq->run_list
      * (2) init the run pool: rq->lab6_run_pool
      * (3) set number of process: rq->proc_num to 0
      */
     list_init(&(rq->run_list));
     rq->lab6_run_pool = NULL;
ffffffffc0204fdc:	00053c23          	sd	zero,24(a0)
     rq->proc_num = 0;
ffffffffc0204fe0:	00052823          	sw	zero,16(a0)
}
ffffffffc0204fe4:	8082                	ret

ffffffffc0204fe6 <stride_pick_next>:
      * (2) update p's stride value: p->lab6_stride
      * (3) return p
      */
#if USE_SKEW_HEAP
     // 斜堆的根节点就是stride最小的进程
     if (rq->lab6_run_pool == NULL) {
ffffffffc0204fe6:	6d1c                	ld	a5,24(a0)
ffffffffc0204fe8:	c395                	beqz	a5,ffffffffc020500c <stride_pick_next+0x26>
          }
     }
#endif
     // 更新stride值: stride += BIG_STRIDE / priority
     // priority为0时当作1处理，防止除零错误
     if (p->lab6_priority == 0) {
ffffffffc0204fea:	4fd0                	lw	a2,28(a5)
          p->lab6_stride += BIG_STRIDE;
ffffffffc0204fec:	80000737          	lui	a4,0x80000
ffffffffc0204ff0:	4f94                	lw	a3,24(a5)
     struct proc_struct *p = le2proc(rq->lab6_run_pool, lab6_run_pool);
ffffffffc0204ff2:	ed878513          	addi	a0,a5,-296
          p->lab6_stride += BIG_STRIDE;
ffffffffc0204ff6:	fff74713          	not	a4,a4
     if (p->lab6_priority == 0) {
ffffffffc0204ffa:	e601                	bnez	a2,ffffffffc0205002 <stride_pick_next+0x1c>
     } else {
          p->lab6_stride += BIG_STRIDE / p->lab6_priority;
ffffffffc0204ffc:	9f35                	addw	a4,a4,a3
ffffffffc0204ffe:	cf98                	sw	a4,24(a5)
ffffffffc0205000:	8082                	ret
ffffffffc0205002:	02c7573b          	divuw	a4,a4,a2
ffffffffc0205006:	9f35                	addw	a4,a4,a3
ffffffffc0205008:	cf98                	sw	a4,24(a5)
ffffffffc020500a:	8082                	ret
          return NULL;
ffffffffc020500c:	4501                	li	a0,0
     }
     return p;
}
ffffffffc020500e:	8082                	ret

ffffffffc0205010 <stride_proc_tick>:
     /* LAB6 CHALLENGE 1: 2310137
      * 时钟中断处理，与RR相同
      * (1) 如果进程的时间片time_slice大于0，则递减
      * (2) 如果时间片减到0，设置need_resched为1，表示需要重新调度
      */
     if (proc->time_slice > 0) {
ffffffffc0205010:	1205a783          	lw	a5,288(a1)
ffffffffc0205014:	00f05563          	blez	a5,ffffffffc020501e <stride_proc_tick+0xe>
          proc->time_slice--;
ffffffffc0205018:	37fd                	addiw	a5,a5,-1
ffffffffc020501a:	12f5a023          	sw	a5,288(a1)
     }
     if (proc->time_slice == 0) {
ffffffffc020501e:	e399                	bnez	a5,ffffffffc0205024 <stride_proc_tick+0x14>
          proc->need_resched = 1;
ffffffffc0205020:	4785                	li	a5,1
ffffffffc0205022:	ed9c                	sd	a5,24(a1)
     }
}
ffffffffc0205024:	8082                	ret

ffffffffc0205026 <skew_heap_merge.constprop.0>:
{
     a->left = a->right = a->parent = NULL;
}

static inline skew_heap_entry_t *
skew_heap_merge(skew_heap_entry_t *a, skew_heap_entry_t *b,
ffffffffc0205026:	7139                	addi	sp,sp,-64
ffffffffc0205028:	f822                	sd	s0,48(sp)
ffffffffc020502a:	fc06                	sd	ra,56(sp)
ffffffffc020502c:	f426                	sd	s1,40(sp)
ffffffffc020502e:	f04a                	sd	s2,32(sp)
ffffffffc0205030:	ec4e                	sd	s3,24(sp)
ffffffffc0205032:	e852                	sd	s4,16(sp)
ffffffffc0205034:	e456                	sd	s5,8(sp)
ffffffffc0205036:	e05a                	sd	s6,0(sp)
ffffffffc0205038:	842e                	mv	s0,a1
                compare_f comp)
{
     if (a == NULL) return b;
ffffffffc020503a:	c925                	beqz	a0,ffffffffc02050aa <skew_heap_merge.constprop.0+0x84>
ffffffffc020503c:	84aa                	mv	s1,a0
     else if (b == NULL) return a;
ffffffffc020503e:	c1ed                	beqz	a1,ffffffffc0205120 <skew_heap_merge.constprop.0+0xfa>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc0205040:	4d1c                	lw	a5,24(a0)
ffffffffc0205042:	4d98                	lw	a4,24(a1)
     else if (c == 0)
ffffffffc0205044:	40e786bb          	subw	a3,a5,a4
ffffffffc0205048:	0606cc63          	bltz	a3,ffffffffc02050c0 <skew_heap_merge.constprop.0+0x9a>
          return a;
     }
     else
     {
          r = b->left;
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020504c:	0105b903          	ld	s2,16(a1)
          r = b->left;
ffffffffc0205050:	0085ba03          	ld	s4,8(a1)
     else if (b == NULL) return a;
ffffffffc0205054:	04090763          	beqz	s2,ffffffffc02050a2 <skew_heap_merge.constprop.0+0x7c>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc0205058:	01892703          	lw	a4,24(s2)
     else if (c == 0)
ffffffffc020505c:	40e786bb          	subw	a3,a5,a4
ffffffffc0205060:	0c06c263          	bltz	a3,ffffffffc0205124 <skew_heap_merge.constprop.0+0xfe>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0205064:	01093983          	ld	s3,16(s2)
          r = b->left;
ffffffffc0205068:	00893a83          	ld	s5,8(s2)
     else if (b == NULL) return a;
ffffffffc020506c:	10098c63          	beqz	s3,ffffffffc0205184 <skew_heap_merge.constprop.0+0x15e>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc0205070:	0189a703          	lw	a4,24(s3)
     else if (c == 0)
ffffffffc0205074:	9f99                	subw	a5,a5,a4
ffffffffc0205076:	1407c863          	bltz	a5,ffffffffc02051c6 <skew_heap_merge.constprop.0+0x1a0>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020507a:	0109b583          	ld	a1,16(s3)
          r = b->left;
ffffffffc020507e:	0089b483          	ld	s1,8(s3)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0205082:	fa5ff0ef          	jal	ra,ffffffffc0205026 <skew_heap_merge.constprop.0>
          
          b->left = l;
ffffffffc0205086:	00a9b423          	sd	a0,8(s3)
          b->right = r;
ffffffffc020508a:	0099b823          	sd	s1,16(s3)
          if (l) l->parent = b;
ffffffffc020508e:	c119                	beqz	a0,ffffffffc0205094 <skew_heap_merge.constprop.0+0x6e>
ffffffffc0205090:	01353023          	sd	s3,0(a0)
          b->left = l;
ffffffffc0205094:	01393423          	sd	s3,8(s2)
          b->right = r;
ffffffffc0205098:	01593823          	sd	s5,16(s2)
          if (l) l->parent = b;
ffffffffc020509c:	0129b023          	sd	s2,0(s3)
ffffffffc02050a0:	84ca                	mv	s1,s2
          b->left = l;
ffffffffc02050a2:	e404                	sd	s1,8(s0)
          b->right = r;
ffffffffc02050a4:	01443823          	sd	s4,16(s0)
          if (l) l->parent = b;
ffffffffc02050a8:	e080                	sd	s0,0(s1)
ffffffffc02050aa:	8522                	mv	a0,s0

          return b;
     }
}
ffffffffc02050ac:	70e2                	ld	ra,56(sp)
ffffffffc02050ae:	7442                	ld	s0,48(sp)
ffffffffc02050b0:	74a2                	ld	s1,40(sp)
ffffffffc02050b2:	7902                	ld	s2,32(sp)
ffffffffc02050b4:	69e2                	ld	s3,24(sp)
ffffffffc02050b6:	6a42                	ld	s4,16(sp)
ffffffffc02050b8:	6aa2                	ld	s5,8(sp)
ffffffffc02050ba:	6b02                	ld	s6,0(sp)
ffffffffc02050bc:	6121                	addi	sp,sp,64
ffffffffc02050be:	8082                	ret
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02050c0:	01053903          	ld	s2,16(a0)
          r = a->left;
ffffffffc02050c4:	00853a03          	ld	s4,8(a0)
     if (a == NULL) return b;
ffffffffc02050c8:	04090863          	beqz	s2,ffffffffc0205118 <skew_heap_merge.constprop.0+0xf2>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc02050cc:	01892783          	lw	a5,24(s2)
     else if (c == 0)
ffffffffc02050d0:	40e7873b          	subw	a4,a5,a4
ffffffffc02050d4:	08074963          	bltz	a4,ffffffffc0205166 <skew_heap_merge.constprop.0+0x140>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02050d8:	0105b983          	ld	s3,16(a1)
          r = b->left;
ffffffffc02050dc:	0085ba83          	ld	s5,8(a1)
     else if (b == NULL) return a;
ffffffffc02050e0:	02098663          	beqz	s3,ffffffffc020510c <skew_heap_merge.constprop.0+0xe6>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc02050e4:	0189a703          	lw	a4,24(s3)
     else if (c == 0)
ffffffffc02050e8:	9f99                	subw	a5,a5,a4
ffffffffc02050ea:	0a07cf63          	bltz	a5,ffffffffc02051a8 <skew_heap_merge.constprop.0+0x182>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02050ee:	0109b583          	ld	a1,16(s3)
          r = b->left;
ffffffffc02050f2:	0089bb03          	ld	s6,8(s3)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02050f6:	854a                	mv	a0,s2
ffffffffc02050f8:	f2fff0ef          	jal	ra,ffffffffc0205026 <skew_heap_merge.constprop.0>
          b->left = l;
ffffffffc02050fc:	00a9b423          	sd	a0,8(s3)
          b->right = r;
ffffffffc0205100:	0169b823          	sd	s6,16(s3)
          if (l) l->parent = b;
ffffffffc0205104:	894e                	mv	s2,s3
ffffffffc0205106:	c119                	beqz	a0,ffffffffc020510c <skew_heap_merge.constprop.0+0xe6>
ffffffffc0205108:	01253023          	sd	s2,0(a0)
          b->left = l;
ffffffffc020510c:	01243423          	sd	s2,8(s0)
          b->right = r;
ffffffffc0205110:	01543823          	sd	s5,16(s0)
          if (l) l->parent = b;
ffffffffc0205114:	00893023          	sd	s0,0(s2)
          a->left = l;
ffffffffc0205118:	e480                	sd	s0,8(s1)
          a->right = r;
ffffffffc020511a:	0144b823          	sd	s4,16(s1)
          if (l) l->parent = a;
ffffffffc020511e:	e004                	sd	s1,0(s0)
ffffffffc0205120:	8526                	mv	a0,s1
ffffffffc0205122:	b769                	j	ffffffffc02050ac <skew_heap_merge.constprop.0+0x86>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0205124:	01053983          	ld	s3,16(a0)
          r = a->left;
ffffffffc0205128:	00853a83          	ld	s5,8(a0)
     if (a == NULL) return b;
ffffffffc020512c:	02098663          	beqz	s3,ffffffffc0205158 <skew_heap_merge.constprop.0+0x132>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc0205130:	0189a783          	lw	a5,24(s3)
     else if (c == 0)
ffffffffc0205134:	40e7873b          	subw	a4,a5,a4
ffffffffc0205138:	04074863          	bltz	a4,ffffffffc0205188 <skew_heap_merge.constprop.0+0x162>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020513c:	01093583          	ld	a1,16(s2)
          r = b->left;
ffffffffc0205140:	00893b03          	ld	s6,8(s2)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0205144:	854e                	mv	a0,s3
ffffffffc0205146:	ee1ff0ef          	jal	ra,ffffffffc0205026 <skew_heap_merge.constprop.0>
          b->left = l;
ffffffffc020514a:	00a93423          	sd	a0,8(s2)
          b->right = r;
ffffffffc020514e:	01693823          	sd	s6,16(s2)
          if (l) l->parent = b;
ffffffffc0205152:	c119                	beqz	a0,ffffffffc0205158 <skew_heap_merge.constprop.0+0x132>
ffffffffc0205154:	01253023          	sd	s2,0(a0)
          a->left = l;
ffffffffc0205158:	0124b423          	sd	s2,8(s1)
          a->right = r;
ffffffffc020515c:	0154b823          	sd	s5,16(s1)
          if (l) l->parent = a;
ffffffffc0205160:	00993023          	sd	s1,0(s2)
ffffffffc0205164:	bf3d                	j	ffffffffc02050a2 <skew_heap_merge.constprop.0+0x7c>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0205166:	01093503          	ld	a0,16(s2)
          r = a->left;
ffffffffc020516a:	00893983          	ld	s3,8(s2)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020516e:	844a                	mv	s0,s2
ffffffffc0205170:	eb7ff0ef          	jal	ra,ffffffffc0205026 <skew_heap_merge.constprop.0>
          a->left = l;
ffffffffc0205174:	00a93423          	sd	a0,8(s2)
          a->right = r;
ffffffffc0205178:	01393823          	sd	s3,16(s2)
          if (l) l->parent = a;
ffffffffc020517c:	dd51                	beqz	a0,ffffffffc0205118 <skew_heap_merge.constprop.0+0xf2>
ffffffffc020517e:	01253023          	sd	s2,0(a0)
ffffffffc0205182:	bf59                	j	ffffffffc0205118 <skew_heap_merge.constprop.0+0xf2>
          if (l) l->parent = b;
ffffffffc0205184:	89a6                	mv	s3,s1
ffffffffc0205186:	b739                	j	ffffffffc0205094 <skew_heap_merge.constprop.0+0x6e>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0205188:	0109b503          	ld	a0,16(s3)
          r = a->left;
ffffffffc020518c:	0089bb03          	ld	s6,8(s3)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0205190:	85ca                	mv	a1,s2
ffffffffc0205192:	e95ff0ef          	jal	ra,ffffffffc0205026 <skew_heap_merge.constprop.0>
          a->left = l;
ffffffffc0205196:	00a9b423          	sd	a0,8(s3)
          a->right = r;
ffffffffc020519a:	0169b823          	sd	s6,16(s3)
          if (l) l->parent = a;
ffffffffc020519e:	894e                	mv	s2,s3
ffffffffc02051a0:	dd45                	beqz	a0,ffffffffc0205158 <skew_heap_merge.constprop.0+0x132>
          if (l) l->parent = b;
ffffffffc02051a2:	01253023          	sd	s2,0(a0)
ffffffffc02051a6:	bf4d                	j	ffffffffc0205158 <skew_heap_merge.constprop.0+0x132>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02051a8:	01093503          	ld	a0,16(s2)
          r = a->left;
ffffffffc02051ac:	00893b03          	ld	s6,8(s2)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02051b0:	85ce                	mv	a1,s3
ffffffffc02051b2:	e75ff0ef          	jal	ra,ffffffffc0205026 <skew_heap_merge.constprop.0>
          a->left = l;
ffffffffc02051b6:	00a93423          	sd	a0,8(s2)
          a->right = r;
ffffffffc02051ba:	01693823          	sd	s6,16(s2)
          if (l) l->parent = a;
ffffffffc02051be:	d539                	beqz	a0,ffffffffc020510c <skew_heap_merge.constprop.0+0xe6>
          if (l) l->parent = b;
ffffffffc02051c0:	01253023          	sd	s2,0(a0)
ffffffffc02051c4:	b7a1                	j	ffffffffc020510c <skew_heap_merge.constprop.0+0xe6>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02051c6:	6908                	ld	a0,16(a0)
          r = a->left;
ffffffffc02051c8:	0084bb03          	ld	s6,8(s1)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02051cc:	85ce                	mv	a1,s3
ffffffffc02051ce:	e59ff0ef          	jal	ra,ffffffffc0205026 <skew_heap_merge.constprop.0>
          a->left = l;
ffffffffc02051d2:	e488                	sd	a0,8(s1)
          a->right = r;
ffffffffc02051d4:	0164b823          	sd	s6,16(s1)
          if (l) l->parent = a;
ffffffffc02051d8:	d555                	beqz	a0,ffffffffc0205184 <skew_heap_merge.constprop.0+0x15e>
ffffffffc02051da:	e104                	sd	s1,0(a0)
ffffffffc02051dc:	89a6                	mv	s3,s1
ffffffffc02051de:	bd5d                	j	ffffffffc0205094 <skew_heap_merge.constprop.0+0x6e>

ffffffffc02051e0 <stride_dequeue>:
{
ffffffffc02051e0:	711d                	addi	sp,sp,-96
ffffffffc02051e2:	fc4e                	sd	s3,56(sp)
static inline skew_heap_entry_t *
skew_heap_remove(skew_heap_entry_t *a, skew_heap_entry_t *b,
                 compare_f comp)
{
     skew_heap_entry_t *p   = b->parent;
     skew_heap_entry_t *rep = skew_heap_merge(b->left, b->right, comp);
ffffffffc02051e4:	1305b983          	ld	s3,304(a1)
ffffffffc02051e8:	e8a2                	sd	s0,80(sp)
ffffffffc02051ea:	e4a6                	sd	s1,72(sp)
ffffffffc02051ec:	e0ca                	sd	s2,64(sp)
ffffffffc02051ee:	f852                	sd	s4,48(sp)
ffffffffc02051f0:	f05a                	sd	s6,32(sp)
ffffffffc02051f2:	ec86                	sd	ra,88(sp)
ffffffffc02051f4:	f456                	sd	s5,40(sp)
ffffffffc02051f6:	ec5e                	sd	s7,24(sp)
ffffffffc02051f8:	e862                	sd	s8,16(sp)
ffffffffc02051fa:	e466                	sd	s9,8(sp)
ffffffffc02051fc:	e06a                	sd	s10,0(sp)
     rq->lab6_run_pool = skew_heap_remove(rq->lab6_run_pool, 
ffffffffc02051fe:	01853b03          	ld	s6,24(a0)
     skew_heap_entry_t *p   = b->parent;
ffffffffc0205202:	1285ba03          	ld	s4,296(a1)
     skew_heap_entry_t *rep = skew_heap_merge(b->left, b->right, comp);
ffffffffc0205206:	1385b483          	ld	s1,312(a1)
{
ffffffffc020520a:	842e                	mv	s0,a1
ffffffffc020520c:	892a                	mv	s2,a0
     if (a == NULL) return b;
ffffffffc020520e:	12098763          	beqz	s3,ffffffffc020533c <stride_dequeue+0x15c>
     else if (b == NULL) return a;
ffffffffc0205212:	12048d63          	beqz	s1,ffffffffc020534c <stride_dequeue+0x16c>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc0205216:	0189a783          	lw	a5,24(s3)
ffffffffc020521a:	4c98                	lw	a4,24(s1)
     else if (c == 0)
ffffffffc020521c:	40e786bb          	subw	a3,a5,a4
ffffffffc0205220:	0a06c863          	bltz	a3,ffffffffc02052d0 <stride_dequeue+0xf0>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0205224:	0104ba83          	ld	s5,16(s1)
          r = b->left;
ffffffffc0205228:	0084bc03          	ld	s8,8(s1)
     else if (b == NULL) return a;
ffffffffc020522c:	040a8963          	beqz	s5,ffffffffc020527e <stride_dequeue+0x9e>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc0205230:	018aa703          	lw	a4,24(s5)
     else if (c == 0)
ffffffffc0205234:	40e786bb          	subw	a3,a5,a4
ffffffffc0205238:	1006ce63          	bltz	a3,ffffffffc0205354 <stride_dequeue+0x174>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020523c:	010abb83          	ld	s7,16(s5)
          r = b->left;
ffffffffc0205240:	008abc83          	ld	s9,8(s5)
     else if (b == NULL) return a;
ffffffffc0205244:	020b8663          	beqz	s7,ffffffffc0205270 <stride_dequeue+0x90>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc0205248:	018ba703          	lw	a4,24(s7)
     else if (c == 0)
ffffffffc020524c:	9f99                	subw	a5,a5,a4
ffffffffc020524e:	1a07c363          	bltz	a5,ffffffffc02053f4 <stride_dequeue+0x214>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0205252:	010bb583          	ld	a1,16(s7)
          r = b->left;
ffffffffc0205256:	008bbd03          	ld	s10,8(s7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020525a:	854e                	mv	a0,s3
ffffffffc020525c:	dcbff0ef          	jal	ra,ffffffffc0205026 <skew_heap_merge.constprop.0>
          b->left = l;
ffffffffc0205260:	00abb423          	sd	a0,8(s7)
          b->right = r;
ffffffffc0205264:	01abb823          	sd	s10,16(s7)
          if (l) l->parent = b;
ffffffffc0205268:	89de                	mv	s3,s7
ffffffffc020526a:	c119                	beqz	a0,ffffffffc0205270 <stride_dequeue+0x90>
ffffffffc020526c:	01353023          	sd	s3,0(a0)
          b->left = l;
ffffffffc0205270:	013ab423          	sd	s3,8(s5)
          b->right = r;
ffffffffc0205274:	019ab823          	sd	s9,16(s5)
          if (l) l->parent = b;
ffffffffc0205278:	0159b023          	sd	s5,0(s3)
ffffffffc020527c:	89d6                	mv	s3,s5
          b->left = l;
ffffffffc020527e:	0134b423          	sd	s3,8(s1)
          b->right = r;
ffffffffc0205282:	0184b823          	sd	s8,16(s1)
          if (l) l->parent = b;
ffffffffc0205286:	0099b023          	sd	s1,0(s3)
     if (rep) rep->parent = p;
ffffffffc020528a:	0144b023          	sd	s4,0(s1)
     
     if (p)
ffffffffc020528e:	0a0a0a63          	beqz	s4,ffffffffc0205342 <stride_dequeue+0x162>
     {
          if (p->left == b)
ffffffffc0205292:	008a3703          	ld	a4,8(s4)
     rq->lab6_run_pool = skew_heap_remove(rq->lab6_run_pool, 
ffffffffc0205296:	12840793          	addi	a5,s0,296
ffffffffc020529a:	0af70663          	beq	a4,a5,ffffffffc0205346 <stride_dequeue+0x166>
               p->left = rep;
          else p->right = rep;
ffffffffc020529e:	009a3823          	sd	s1,16(s4)
     rq->proc_num--;
ffffffffc02052a2:	01092783          	lw	a5,16(s2)
     rq->lab6_run_pool = skew_heap_remove(rq->lab6_run_pool, 
ffffffffc02052a6:	01693c23          	sd	s6,24(s2)
     proc->rq = NULL;
ffffffffc02052aa:	10043423          	sd	zero,264(s0)
}
ffffffffc02052ae:	60e6                	ld	ra,88(sp)
ffffffffc02052b0:	6446                	ld	s0,80(sp)
     rq->proc_num--;
ffffffffc02052b2:	37fd                	addiw	a5,a5,-1
ffffffffc02052b4:	00f92823          	sw	a5,16(s2)
}
ffffffffc02052b8:	64a6                	ld	s1,72(sp)
ffffffffc02052ba:	6906                	ld	s2,64(sp)
ffffffffc02052bc:	79e2                	ld	s3,56(sp)
ffffffffc02052be:	7a42                	ld	s4,48(sp)
ffffffffc02052c0:	7aa2                	ld	s5,40(sp)
ffffffffc02052c2:	7b02                	ld	s6,32(sp)
ffffffffc02052c4:	6be2                	ld	s7,24(sp)
ffffffffc02052c6:	6c42                	ld	s8,16(sp)
ffffffffc02052c8:	6ca2                	ld	s9,8(sp)
ffffffffc02052ca:	6d02                	ld	s10,0(sp)
ffffffffc02052cc:	6125                	addi	sp,sp,96
ffffffffc02052ce:	8082                	ret
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02052d0:	0109ba83          	ld	s5,16(s3)
          r = a->left;
ffffffffc02052d4:	0089bc03          	ld	s8,8(s3)
     if (a == NULL) return b;
ffffffffc02052d8:	040a8863          	beqz	s5,ffffffffc0205328 <stride_dequeue+0x148>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc02052dc:	018aa783          	lw	a5,24(s5)
     else if (c == 0)
ffffffffc02052e0:	40e7873b          	subw	a4,a5,a4
ffffffffc02052e4:	0a074963          	bltz	a4,ffffffffc0205396 <stride_dequeue+0x1b6>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02052e8:	0104bb83          	ld	s7,16(s1)
          r = b->left;
ffffffffc02052ec:	0084bc83          	ld	s9,8(s1)
     else if (b == NULL) return a;
ffffffffc02052f0:	020b8663          	beqz	s7,ffffffffc020531c <stride_dequeue+0x13c>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc02052f4:	018ba703          	lw	a4,24(s7)
     else if (c == 0)
ffffffffc02052f8:	9f99                	subw	a5,a5,a4
ffffffffc02052fa:	0c07ce63          	bltz	a5,ffffffffc02053d6 <stride_dequeue+0x1f6>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02052fe:	010bb583          	ld	a1,16(s7)
          r = b->left;
ffffffffc0205302:	008bbd03          	ld	s10,8(s7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0205306:	8556                	mv	a0,s5
ffffffffc0205308:	d1fff0ef          	jal	ra,ffffffffc0205026 <skew_heap_merge.constprop.0>
          b->left = l;
ffffffffc020530c:	00abb423          	sd	a0,8(s7)
          b->right = r;
ffffffffc0205310:	01abb823          	sd	s10,16(s7)
          if (l) l->parent = b;
ffffffffc0205314:	8ade                	mv	s5,s7
ffffffffc0205316:	c119                	beqz	a0,ffffffffc020531c <stride_dequeue+0x13c>
ffffffffc0205318:	01553023          	sd	s5,0(a0)
          b->left = l;
ffffffffc020531c:	0154b423          	sd	s5,8(s1)
          b->right = r;
ffffffffc0205320:	0194b823          	sd	s9,16(s1)
          if (l) l->parent = b;
ffffffffc0205324:	009ab023          	sd	s1,0(s5)
          a->left = l;
ffffffffc0205328:	0099b423          	sd	s1,8(s3)
          a->right = r;
ffffffffc020532c:	0189b823          	sd	s8,16(s3)
          if (l) l->parent = a;
ffffffffc0205330:	0134b023          	sd	s3,0(s1)
ffffffffc0205334:	84ce                	mv	s1,s3
     if (rep) rep->parent = p;
ffffffffc0205336:	0144b023          	sd	s4,0(s1)
ffffffffc020533a:	bf91                	j	ffffffffc020528e <stride_dequeue+0xae>
ffffffffc020533c:	f4b9                	bnez	s1,ffffffffc020528a <stride_dequeue+0xaa>
     if (p)
ffffffffc020533e:	f40a1ae3          	bnez	s4,ffffffffc0205292 <stride_dequeue+0xb2>
ffffffffc0205342:	8b26                	mv	s6,s1
ffffffffc0205344:	bfb9                	j	ffffffffc02052a2 <stride_dequeue+0xc2>
               p->left = rep;
ffffffffc0205346:	009a3423          	sd	s1,8(s4)
ffffffffc020534a:	bfa1                	j	ffffffffc02052a2 <stride_dequeue+0xc2>
ffffffffc020534c:	84ce                	mv	s1,s3
     if (rep) rep->parent = p;
ffffffffc020534e:	0144b023          	sd	s4,0(s1)
ffffffffc0205352:	bf35                	j	ffffffffc020528e <stride_dequeue+0xae>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0205354:	0109bb83          	ld	s7,16(s3)
          r = a->left;
ffffffffc0205358:	0089bc83          	ld	s9,8(s3)
     if (a == NULL) return b;
ffffffffc020535c:	020b8663          	beqz	s7,ffffffffc0205388 <stride_dequeue+0x1a8>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc0205360:	018ba783          	lw	a5,24(s7)
     else if (c == 0)
ffffffffc0205364:	40e7873b          	subw	a4,a5,a4
ffffffffc0205368:	04074763          	bltz	a4,ffffffffc02053b6 <stride_dequeue+0x1d6>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020536c:	010ab583          	ld	a1,16(s5)
          r = b->left;
ffffffffc0205370:	008abd03          	ld	s10,8(s5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0205374:	855e                	mv	a0,s7
ffffffffc0205376:	cb1ff0ef          	jal	ra,ffffffffc0205026 <skew_heap_merge.constprop.0>
          b->left = l;
ffffffffc020537a:	00aab423          	sd	a0,8(s5)
          b->right = r;
ffffffffc020537e:	01aab823          	sd	s10,16(s5)
          if (l) l->parent = b;
ffffffffc0205382:	c119                	beqz	a0,ffffffffc0205388 <stride_dequeue+0x1a8>
ffffffffc0205384:	01553023          	sd	s5,0(a0)
          a->left = l;
ffffffffc0205388:	0159b423          	sd	s5,8(s3)
          a->right = r;
ffffffffc020538c:	0199b823          	sd	s9,16(s3)
          if (l) l->parent = a;
ffffffffc0205390:	013ab023          	sd	s3,0(s5)
ffffffffc0205394:	b5ed                	j	ffffffffc020527e <stride_dequeue+0x9e>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0205396:	010ab503          	ld	a0,16(s5)
          r = a->left;
ffffffffc020539a:	008abb83          	ld	s7,8(s5)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020539e:	85a6                	mv	a1,s1
ffffffffc02053a0:	c87ff0ef          	jal	ra,ffffffffc0205026 <skew_heap_merge.constprop.0>
          a->left = l;
ffffffffc02053a4:	00aab423          	sd	a0,8(s5)
          a->right = r;
ffffffffc02053a8:	017ab823          	sd	s7,16(s5)
          if (l) l->parent = a;
ffffffffc02053ac:	84d6                	mv	s1,s5
ffffffffc02053ae:	dd2d                	beqz	a0,ffffffffc0205328 <stride_dequeue+0x148>
ffffffffc02053b0:	01553023          	sd	s5,0(a0)
ffffffffc02053b4:	bf95                	j	ffffffffc0205328 <stride_dequeue+0x148>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02053b6:	010bb503          	ld	a0,16(s7)
          r = a->left;
ffffffffc02053ba:	008bbd03          	ld	s10,8(s7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02053be:	85d6                	mv	a1,s5
ffffffffc02053c0:	c67ff0ef          	jal	ra,ffffffffc0205026 <skew_heap_merge.constprop.0>
          a->left = l;
ffffffffc02053c4:	00abb423          	sd	a0,8(s7)
          a->right = r;
ffffffffc02053c8:	01abb823          	sd	s10,16(s7)
          if (l) l->parent = a;
ffffffffc02053cc:	8ade                	mv	s5,s7
ffffffffc02053ce:	dd4d                	beqz	a0,ffffffffc0205388 <stride_dequeue+0x1a8>
          if (l) l->parent = b;
ffffffffc02053d0:	01553023          	sd	s5,0(a0)
ffffffffc02053d4:	bf55                	j	ffffffffc0205388 <stride_dequeue+0x1a8>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02053d6:	010ab503          	ld	a0,16(s5)
          r = a->left;
ffffffffc02053da:	008abd03          	ld	s10,8(s5)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02053de:	85de                	mv	a1,s7
ffffffffc02053e0:	c47ff0ef          	jal	ra,ffffffffc0205026 <skew_heap_merge.constprop.0>
          a->left = l;
ffffffffc02053e4:	00aab423          	sd	a0,8(s5)
          a->right = r;
ffffffffc02053e8:	01aab823          	sd	s10,16(s5)
          if (l) l->parent = a;
ffffffffc02053ec:	d905                	beqz	a0,ffffffffc020531c <stride_dequeue+0x13c>
          if (l) l->parent = b;
ffffffffc02053ee:	01553023          	sd	s5,0(a0)
ffffffffc02053f2:	b72d                	j	ffffffffc020531c <stride_dequeue+0x13c>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02053f4:	0109b503          	ld	a0,16(s3)
          r = a->left;
ffffffffc02053f8:	0089bd03          	ld	s10,8(s3)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02053fc:	85de                	mv	a1,s7
ffffffffc02053fe:	c29ff0ef          	jal	ra,ffffffffc0205026 <skew_heap_merge.constprop.0>
          a->left = l;
ffffffffc0205402:	00a9b423          	sd	a0,8(s3)
          a->right = r;
ffffffffc0205406:	01a9b823          	sd	s10,16(s3)
          if (l) l->parent = a;
ffffffffc020540a:	e60511e3          	bnez	a0,ffffffffc020526c <stride_dequeue+0x8c>
ffffffffc020540e:	b58d                	j	ffffffffc0205270 <stride_dequeue+0x90>

ffffffffc0205410 <stride_enqueue>:
{
ffffffffc0205410:	7139                	addi	sp,sp,-64
ffffffffc0205412:	f04a                	sd	s2,32(sp)
     rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, 
ffffffffc0205414:	01853903          	ld	s2,24(a0)
{
ffffffffc0205418:	f822                	sd	s0,48(sp)
ffffffffc020541a:	f426                	sd	s1,40(sp)
ffffffffc020541c:	fc06                	sd	ra,56(sp)
ffffffffc020541e:	ec4e                	sd	s3,24(sp)
ffffffffc0205420:	e852                	sd	s4,16(sp)
ffffffffc0205422:	e456                	sd	s5,8(sp)
     proc->lab6_run_pool.left = proc->lab6_run_pool.right = proc->lab6_run_pool.parent = NULL;
ffffffffc0205424:	1205b423          	sd	zero,296(a1)
ffffffffc0205428:	1205bc23          	sd	zero,312(a1)
ffffffffc020542c:	1205b823          	sd	zero,304(a1)
{
ffffffffc0205430:	842e                	mv	s0,a1
ffffffffc0205432:	84aa                	mv	s1,a0
     rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, 
ffffffffc0205434:	12858593          	addi	a1,a1,296
     if (a == NULL) return b;
ffffffffc0205438:	00090d63          	beqz	s2,ffffffffc0205452 <stride_enqueue+0x42>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc020543c:	14042703          	lw	a4,320(s0)
ffffffffc0205440:	01892783          	lw	a5,24(s2)
     else if (c == 0)
ffffffffc0205444:	9f99                	subw	a5,a5,a4
ffffffffc0205446:	0407c463          	bltz	a5,ffffffffc020548e <stride_enqueue+0x7e>
          b->left = l;
ffffffffc020544a:	13243823          	sd	s2,304(s0)
          if (l) l->parent = b;
ffffffffc020544e:	00b93023          	sd	a1,0(s2)
     if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc0205452:	12042783          	lw	a5,288(s0)
     rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, 
ffffffffc0205456:	ec8c                	sd	a1,24(s1)
     if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc0205458:	48d8                	lw	a4,20(s1)
ffffffffc020545a:	c79d                	beqz	a5,ffffffffc0205488 <stride_enqueue+0x78>
ffffffffc020545c:	02f74663          	blt	a4,a5,ffffffffc0205488 <stride_enqueue+0x78>
     if (proc->lab6_priority == 0) {
ffffffffc0205460:	14442783          	lw	a5,324(s0)
ffffffffc0205464:	e781                	bnez	a5,ffffffffc020546c <stride_enqueue+0x5c>
          proc->lab6_priority = 1;
ffffffffc0205466:	4785                	li	a5,1
ffffffffc0205468:	14f42223          	sw	a5,324(s0)
     rq->proc_num++;
ffffffffc020546c:	489c                	lw	a5,16(s1)
}
ffffffffc020546e:	70e2                	ld	ra,56(sp)
     proc->rq = rq;
ffffffffc0205470:	10943423          	sd	s1,264(s0)
}
ffffffffc0205474:	7442                	ld	s0,48(sp)
     rq->proc_num++;
ffffffffc0205476:	2785                	addiw	a5,a5,1
ffffffffc0205478:	c89c                	sw	a5,16(s1)
}
ffffffffc020547a:	7902                	ld	s2,32(sp)
ffffffffc020547c:	74a2                	ld	s1,40(sp)
ffffffffc020547e:	69e2                	ld	s3,24(sp)
ffffffffc0205480:	6a42                	ld	s4,16(sp)
ffffffffc0205482:	6aa2                	ld	s5,8(sp)
ffffffffc0205484:	6121                	addi	sp,sp,64
ffffffffc0205486:	8082                	ret
          proc->time_slice = rq->max_time_slice;
ffffffffc0205488:	12e42023          	sw	a4,288(s0)
ffffffffc020548c:	bfd1                	j	ffffffffc0205460 <stride_enqueue+0x50>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020548e:	01093983          	ld	s3,16(s2)
          r = a->left;
ffffffffc0205492:	00893a03          	ld	s4,8(s2)
     if (a == NULL) return b;
ffffffffc0205496:	00098c63          	beqz	s3,ffffffffc02054ae <stride_enqueue+0x9e>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc020549a:	0189a783          	lw	a5,24(s3)
     else if (c == 0)
ffffffffc020549e:	40e7873b          	subw	a4,a5,a4
ffffffffc02054a2:	00074e63          	bltz	a4,ffffffffc02054be <stride_enqueue+0xae>
          b->left = l;
ffffffffc02054a6:	13343823          	sd	s3,304(s0)
          if (l) l->parent = b;
ffffffffc02054aa:	00b9b023          	sd	a1,0(s3)
          a->left = l;
ffffffffc02054ae:	00b93423          	sd	a1,8(s2)
          a->right = r;
ffffffffc02054b2:	01493823          	sd	s4,16(s2)
          if (l) l->parent = a;
ffffffffc02054b6:	0125b023          	sd	s2,0(a1)
ffffffffc02054ba:	85ca                	mv	a1,s2
ffffffffc02054bc:	bf59                	j	ffffffffc0205452 <stride_enqueue+0x42>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02054be:	0109b503          	ld	a0,16(s3)
          r = a->left;
ffffffffc02054c2:	0089ba83          	ld	s5,8(s3)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02054c6:	b61ff0ef          	jal	ra,ffffffffc0205026 <skew_heap_merge.constprop.0>
          a->left = l;
ffffffffc02054ca:	00a9b423          	sd	a0,8(s3)
          a->right = r;
ffffffffc02054ce:	0159b823          	sd	s5,16(s3)
          if (l) l->parent = a;
ffffffffc02054d2:	85ce                	mv	a1,s3
ffffffffc02054d4:	dd69                	beqz	a0,ffffffffc02054ae <stride_enqueue+0x9e>
ffffffffc02054d6:	01353023          	sd	s3,0(a0)
ffffffffc02054da:	bfd1                	j	ffffffffc02054ae <stride_enqueue+0x9e>

ffffffffc02054dc <sched_class_proc_tick>:
    return sched_class->pick_next(rq);
}

void sched_class_proc_tick(struct proc_struct *proc)
{
    if (proc != idleproc)
ffffffffc02054dc:	000cd797          	auipc	a5,0xcd
ffffffffc02054e0:	2ec7b783          	ld	a5,748(a5) # ffffffffc02d27c8 <idleproc>
{
ffffffffc02054e4:	85aa                	mv	a1,a0
    if (proc != idleproc)
ffffffffc02054e6:	00a78c63          	beq	a5,a0,ffffffffc02054fe <sched_class_proc_tick+0x22>
    {
        sched_class->proc_tick(rq, proc);
ffffffffc02054ea:	000cd797          	auipc	a5,0xcd
ffffffffc02054ee:	2fe7b783          	ld	a5,766(a5) # ffffffffc02d27e8 <sched_class>
ffffffffc02054f2:	779c                	ld	a5,40(a5)
ffffffffc02054f4:	000cd517          	auipc	a0,0xcd
ffffffffc02054f8:	2ec53503          	ld	a0,748(a0) # ffffffffc02d27e0 <rq>
ffffffffc02054fc:	8782                	jr	a5
    }
    else
    {
        proc->need_resched = 1;
ffffffffc02054fe:	4705                	li	a4,1
ffffffffc0205500:	ef98                	sd	a4,24(a5)
    }
}
ffffffffc0205502:	8082                	ret

ffffffffc0205504 <sched_init>:

static struct run_queue __rq;

void sched_init(void)
{
ffffffffc0205504:	1141                	addi	sp,sp,-16

    // LAB6 CHALLENGE 2: 根据SCHED_ALGORITHM选择调度算法
#if SCHED_ALGORITHM == 0
    sched_class = &default_sched_class;     // RR调度器
#elif SCHED_ALGORITHM == 1
    sched_class = &stride_sched_class;      // Stride调度器
ffffffffc0205506:	000c9717          	auipc	a4,0xc9
ffffffffc020550a:	dc270713          	addi	a4,a4,-574 # ffffffffc02ce2c8 <stride_sched_class>
{
ffffffffc020550e:	e022                	sd	s0,0(sp)
ffffffffc0205510:	e406                	sd	ra,8(sp)
ffffffffc0205512:	000cd797          	auipc	a5,0xcd
ffffffffc0205516:	23e78793          	addi	a5,a5,574 # ffffffffc02d2750 <timer_list>
    sched_class = &default_sched_class;     // 默认使用RR
#endif

    rq = &__rq;
    rq->max_time_slice = MAX_TIME_SLICE;
    sched_class->init(rq);
ffffffffc020551a:	6714                	ld	a3,8(a4)
    rq = &__rq;
ffffffffc020551c:	000cd517          	auipc	a0,0xcd
ffffffffc0205520:	21450513          	addi	a0,a0,532 # ffffffffc02d2730 <__rq>
ffffffffc0205524:	e79c                	sd	a5,8(a5)
ffffffffc0205526:	e39c                	sd	a5,0(a5)
    rq->max_time_slice = MAX_TIME_SLICE;
ffffffffc0205528:	4795                	li	a5,5
ffffffffc020552a:	c95c                	sw	a5,20(a0)
    sched_class = &stride_sched_class;      // Stride调度器
ffffffffc020552c:	000cd417          	auipc	s0,0xcd
ffffffffc0205530:	2bc40413          	addi	s0,s0,700 # ffffffffc02d27e8 <sched_class>
    rq = &__rq;
ffffffffc0205534:	000cd797          	auipc	a5,0xcd
ffffffffc0205538:	2aa7b623          	sd	a0,684(a5) # ffffffffc02d27e0 <rq>
    sched_class = &stride_sched_class;      // Stride调度器
ffffffffc020553c:	e018                	sd	a4,0(s0)
    sched_class->init(rq);
ffffffffc020553e:	9682                	jalr	a3

    cprintf("sched class: %s\n", sched_class->name);
ffffffffc0205540:	601c                	ld	a5,0(s0)
}
ffffffffc0205542:	6402                	ld	s0,0(sp)
ffffffffc0205544:	60a2                	ld	ra,8(sp)
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc0205546:	638c                	ld	a1,0(a5)
ffffffffc0205548:	00002517          	auipc	a0,0x2
ffffffffc020554c:	42850513          	addi	a0,a0,1064 # ffffffffc0207970 <default_pmm_manager+0xe98>
}
ffffffffc0205550:	0141                	addi	sp,sp,16
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc0205552:	c47fa06f          	j	ffffffffc0200198 <cprintf>

ffffffffc0205556 <wakeup_proc>:

void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205556:	4118                	lw	a4,0(a0)
{
ffffffffc0205558:	1101                	addi	sp,sp,-32
ffffffffc020555a:	ec06                	sd	ra,24(sp)
ffffffffc020555c:	e822                	sd	s0,16(sp)
ffffffffc020555e:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205560:	478d                	li	a5,3
ffffffffc0205562:	08f70363          	beq	a4,a5,ffffffffc02055e8 <wakeup_proc+0x92>
ffffffffc0205566:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0205568:	100027f3          	csrr	a5,sstatus
ffffffffc020556c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020556e:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0205570:	e7bd                	bnez	a5,ffffffffc02055de <wakeup_proc+0x88>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
ffffffffc0205572:	4789                	li	a5,2
ffffffffc0205574:	04f70863          	beq	a4,a5,ffffffffc02055c4 <wakeup_proc+0x6e>
        {
            proc->state = PROC_RUNNABLE;
ffffffffc0205578:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc020557a:	0e042623          	sw	zero,236(s0)
            if (proc != current)
ffffffffc020557e:	000cd797          	auipc	a5,0xcd
ffffffffc0205582:	2427b783          	ld	a5,578(a5) # ffffffffc02d27c0 <current>
ffffffffc0205586:	02878363          	beq	a5,s0,ffffffffc02055ac <wakeup_proc+0x56>
    if (proc != idleproc)
ffffffffc020558a:	000cd797          	auipc	a5,0xcd
ffffffffc020558e:	23e7b783          	ld	a5,574(a5) # ffffffffc02d27c8 <idleproc>
ffffffffc0205592:	00f40d63          	beq	s0,a5,ffffffffc02055ac <wakeup_proc+0x56>
        sched_class->enqueue(rq, proc);
ffffffffc0205596:	000cd797          	auipc	a5,0xcd
ffffffffc020559a:	2527b783          	ld	a5,594(a5) # ffffffffc02d27e8 <sched_class>
ffffffffc020559e:	6b9c                	ld	a5,16(a5)
ffffffffc02055a0:	85a2                	mv	a1,s0
ffffffffc02055a2:	000cd517          	auipc	a0,0xcd
ffffffffc02055a6:	23e53503          	ld	a0,574(a0) # ffffffffc02d27e0 <rq>
ffffffffc02055aa:	9782                	jalr	a5
    if (flag)
ffffffffc02055ac:	e491                	bnez	s1,ffffffffc02055b8 <wakeup_proc+0x62>
        {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02055ae:	60e2                	ld	ra,24(sp)
ffffffffc02055b0:	6442                	ld	s0,16(sp)
ffffffffc02055b2:	64a2                	ld	s1,8(sp)
ffffffffc02055b4:	6105                	addi	sp,sp,32
ffffffffc02055b6:	8082                	ret
ffffffffc02055b8:	6442                	ld	s0,16(sp)
ffffffffc02055ba:	60e2                	ld	ra,24(sp)
ffffffffc02055bc:	64a2                	ld	s1,8(sp)
ffffffffc02055be:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02055c0:	be8fb06f          	j	ffffffffc02009a8 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc02055c4:	00002617          	auipc	a2,0x2
ffffffffc02055c8:	3fc60613          	addi	a2,a2,1020 # ffffffffc02079c0 <default_pmm_manager+0xee8>
ffffffffc02055cc:	06700593          	li	a1,103
ffffffffc02055d0:	00002517          	auipc	a0,0x2
ffffffffc02055d4:	3d850513          	addi	a0,a0,984 # ffffffffc02079a8 <default_pmm_manager+0xed0>
ffffffffc02055d8:	f23fa0ef          	jal	ra,ffffffffc02004fa <__warn>
ffffffffc02055dc:	bfc1                	j	ffffffffc02055ac <wakeup_proc+0x56>
        intr_disable();
ffffffffc02055de:	bd0fb0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        if (proc->state != PROC_RUNNABLE)
ffffffffc02055e2:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc02055e4:	4485                	li	s1,1
ffffffffc02055e6:	b771                	j	ffffffffc0205572 <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02055e8:	00002697          	auipc	a3,0x2
ffffffffc02055ec:	3a068693          	addi	a3,a3,928 # ffffffffc0207988 <default_pmm_manager+0xeb0>
ffffffffc02055f0:	00001617          	auipc	a2,0x1
ffffffffc02055f4:	13860613          	addi	a2,a2,312 # ffffffffc0206728 <commands+0x828>
ffffffffc02055f8:	05800593          	li	a1,88
ffffffffc02055fc:	00002517          	auipc	a0,0x2
ffffffffc0205600:	3ac50513          	addi	a0,a0,940 # ffffffffc02079a8 <default_pmm_manager+0xed0>
ffffffffc0205604:	e8ffa0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0205608 <schedule>:

void schedule(void)
{
ffffffffc0205608:	7179                	addi	sp,sp,-48
ffffffffc020560a:	f406                	sd	ra,40(sp)
ffffffffc020560c:	f022                	sd	s0,32(sp)
ffffffffc020560e:	ec26                	sd	s1,24(sp)
ffffffffc0205610:	e84a                	sd	s2,16(sp)
ffffffffc0205612:	e44e                	sd	s3,8(sp)
ffffffffc0205614:	e052                	sd	s4,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0205616:	100027f3          	csrr	a5,sstatus
ffffffffc020561a:	8b89                	andi	a5,a5,2
ffffffffc020561c:	4a01                	li	s4,0
ffffffffc020561e:	e3cd                	bnez	a5,ffffffffc02056c0 <schedule+0xb8>
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205620:	000cd497          	auipc	s1,0xcd
ffffffffc0205624:	1a048493          	addi	s1,s1,416 # ffffffffc02d27c0 <current>
ffffffffc0205628:	608c                	ld	a1,0(s1)
        sched_class->enqueue(rq, proc);
ffffffffc020562a:	000cd997          	auipc	s3,0xcd
ffffffffc020562e:	1be98993          	addi	s3,s3,446 # ffffffffc02d27e8 <sched_class>
ffffffffc0205632:	000cd917          	auipc	s2,0xcd
ffffffffc0205636:	1ae90913          	addi	s2,s2,430 # ffffffffc02d27e0 <rq>
        if (current->state == PROC_RUNNABLE)
ffffffffc020563a:	4194                	lw	a3,0(a1)
        current->need_resched = 0;
ffffffffc020563c:	0005bc23          	sd	zero,24(a1)
        if (current->state == PROC_RUNNABLE)
ffffffffc0205640:	4709                	li	a4,2
        sched_class->enqueue(rq, proc);
ffffffffc0205642:	0009b783          	ld	a5,0(s3)
ffffffffc0205646:	00093503          	ld	a0,0(s2)
        if (current->state == PROC_RUNNABLE)
ffffffffc020564a:	04e68e63          	beq	a3,a4,ffffffffc02056a6 <schedule+0x9e>
    return sched_class->pick_next(rq);
ffffffffc020564e:	739c                	ld	a5,32(a5)
ffffffffc0205650:	9782                	jalr	a5
ffffffffc0205652:	842a                	mv	s0,a0
        {
            sched_class_enqueue(current);
        }
        if ((next = sched_class_pick_next()) != NULL)
ffffffffc0205654:	c521                	beqz	a0,ffffffffc020569c <schedule+0x94>
    sched_class->dequeue(rq, proc);
ffffffffc0205656:	0009b783          	ld	a5,0(s3)
ffffffffc020565a:	00093503          	ld	a0,0(s2)
ffffffffc020565e:	85a2                	mv	a1,s0
ffffffffc0205660:	6f9c                	ld	a5,24(a5)
ffffffffc0205662:	9782                	jalr	a5
        }
        if (next == NULL)
        {
            next = idleproc;
        }
        next->runs++;
ffffffffc0205664:	441c                	lw	a5,8(s0)
        if (next != current)
ffffffffc0205666:	6098                	ld	a4,0(s1)
        next->runs++;
ffffffffc0205668:	2785                	addiw	a5,a5,1
ffffffffc020566a:	c41c                	sw	a5,8(s0)
        if (next != current)
ffffffffc020566c:	00870563          	beq	a4,s0,ffffffffc0205676 <schedule+0x6e>
        {
            proc_run(next);
ffffffffc0205670:	8522                	mv	a0,s0
ffffffffc0205672:	fc2fe0ef          	jal	ra,ffffffffc0203e34 <proc_run>
    if (flag)
ffffffffc0205676:	000a1a63          	bnez	s4,ffffffffc020568a <schedule+0x82>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020567a:	70a2                	ld	ra,40(sp)
ffffffffc020567c:	7402                	ld	s0,32(sp)
ffffffffc020567e:	64e2                	ld	s1,24(sp)
ffffffffc0205680:	6942                	ld	s2,16(sp)
ffffffffc0205682:	69a2                	ld	s3,8(sp)
ffffffffc0205684:	6a02                	ld	s4,0(sp)
ffffffffc0205686:	6145                	addi	sp,sp,48
ffffffffc0205688:	8082                	ret
ffffffffc020568a:	7402                	ld	s0,32(sp)
ffffffffc020568c:	70a2                	ld	ra,40(sp)
ffffffffc020568e:	64e2                	ld	s1,24(sp)
ffffffffc0205690:	6942                	ld	s2,16(sp)
ffffffffc0205692:	69a2                	ld	s3,8(sp)
ffffffffc0205694:	6a02                	ld	s4,0(sp)
ffffffffc0205696:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0205698:	b10fb06f          	j	ffffffffc02009a8 <intr_enable>
            next = idleproc;
ffffffffc020569c:	000cd417          	auipc	s0,0xcd
ffffffffc02056a0:	12c43403          	ld	s0,300(s0) # ffffffffc02d27c8 <idleproc>
ffffffffc02056a4:	b7c1                	j	ffffffffc0205664 <schedule+0x5c>
    if (proc != idleproc)
ffffffffc02056a6:	000cd717          	auipc	a4,0xcd
ffffffffc02056aa:	12273703          	ld	a4,290(a4) # ffffffffc02d27c8 <idleproc>
ffffffffc02056ae:	fae580e3          	beq	a1,a4,ffffffffc020564e <schedule+0x46>
        sched_class->enqueue(rq, proc);
ffffffffc02056b2:	6b9c                	ld	a5,16(a5)
ffffffffc02056b4:	9782                	jalr	a5
    return sched_class->pick_next(rq);
ffffffffc02056b6:	0009b783          	ld	a5,0(s3)
ffffffffc02056ba:	00093503          	ld	a0,0(s2)
ffffffffc02056be:	bf41                	j	ffffffffc020564e <schedule+0x46>
        intr_disable();
ffffffffc02056c0:	aeefb0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        return 1;
ffffffffc02056c4:	4a05                	li	s4,1
ffffffffc02056c6:	bfa9                	j	ffffffffc0205620 <schedule+0x18>

ffffffffc02056c8 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc02056c8:	000cd797          	auipc	a5,0xcd
ffffffffc02056cc:	0f87b783          	ld	a5,248(a5) # ffffffffc02d27c0 <current>
}
ffffffffc02056d0:	43c8                	lw	a0,4(a5)
ffffffffc02056d2:	8082                	ret

ffffffffc02056d4 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc02056d4:	4501                	li	a0,0
ffffffffc02056d6:	8082                	ret

ffffffffc02056d8 <sys_gettime>:
static int sys_gettime(uint64_t arg[]){
    return (int)ticks*10;
ffffffffc02056d8:	000cd797          	auipc	a5,0xcd
ffffffffc02056dc:	0907b783          	ld	a5,144(a5) # ffffffffc02d2768 <ticks>
ffffffffc02056e0:	0027951b          	slliw	a0,a5,0x2
ffffffffc02056e4:	9d3d                	addw	a0,a0,a5
}
ffffffffc02056e6:	0015151b          	slliw	a0,a0,0x1
ffffffffc02056ea:	8082                	ret

ffffffffc02056ec <sys_lab6_set_priority>:
static int sys_lab6_set_priority(uint64_t arg[]){
    uint64_t priority = (uint64_t)arg[0];
    lab6_set_priority(priority);
ffffffffc02056ec:	4108                	lw	a0,0(a0)
static int sys_lab6_set_priority(uint64_t arg[]){
ffffffffc02056ee:	1141                	addi	sp,sp,-16
ffffffffc02056f0:	e406                	sd	ra,8(sp)
    lab6_set_priority(priority);
ffffffffc02056f2:	843ff0ef          	jal	ra,ffffffffc0204f34 <lab6_set_priority>
    return 0;
}
ffffffffc02056f6:	60a2                	ld	ra,8(sp)
ffffffffc02056f8:	4501                	li	a0,0
ffffffffc02056fa:	0141                	addi	sp,sp,16
ffffffffc02056fc:	8082                	ret

ffffffffc02056fe <sys_putc>:
    cputchar(c);
ffffffffc02056fe:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0205700:	1141                	addi	sp,sp,-16
ffffffffc0205702:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0205704:	acbfa0ef          	jal	ra,ffffffffc02001ce <cputchar>
}
ffffffffc0205708:	60a2                	ld	ra,8(sp)
ffffffffc020570a:	4501                	li	a0,0
ffffffffc020570c:	0141                	addi	sp,sp,16
ffffffffc020570e:	8082                	ret

ffffffffc0205710 <sys_kill>:
    return do_kill(pid);
ffffffffc0205710:	4108                	lw	a0,0(a0)
ffffffffc0205712:	df4ff06f          	j	ffffffffc0204d06 <do_kill>

ffffffffc0205716 <sys_yield>:
    return do_yield();
ffffffffc0205716:	da2ff06f          	j	ffffffffc0204cb8 <do_yield>

ffffffffc020571a <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc020571a:	6d14                	ld	a3,24(a0)
ffffffffc020571c:	6910                	ld	a2,16(a0)
ffffffffc020571e:	650c                	ld	a1,8(a0)
ffffffffc0205720:	6108                	ld	a0,0(a0)
ffffffffc0205722:	fedfe06f          	j	ffffffffc020470e <do_execve>

ffffffffc0205726 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0205726:	650c                	ld	a1,8(a0)
ffffffffc0205728:	4108                	lw	a0,0(a0)
ffffffffc020572a:	d9eff06f          	j	ffffffffc0204cc8 <do_wait>

ffffffffc020572e <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc020572e:	000cd797          	auipc	a5,0xcd
ffffffffc0205732:	0927b783          	ld	a5,146(a5) # ffffffffc02d27c0 <current>
ffffffffc0205736:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0205738:	4501                	li	a0,0
ffffffffc020573a:	6a0c                	ld	a1,16(a2)
ffffffffc020573c:	f5cfe06f          	j	ffffffffc0203e98 <do_fork>

ffffffffc0205740 <sys_exit>:
    return do_exit(error_code);
ffffffffc0205740:	4108                	lw	a0,0(a0)
ffffffffc0205742:	b8dfe06f          	j	ffffffffc02042ce <do_exit>

ffffffffc0205746 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0205746:	715d                	addi	sp,sp,-80
ffffffffc0205748:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc020574a:	000cd497          	auipc	s1,0xcd
ffffffffc020574e:	07648493          	addi	s1,s1,118 # ffffffffc02d27c0 <current>
ffffffffc0205752:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0205754:	e0a2                	sd	s0,64(sp)
ffffffffc0205756:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205758:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc020575a:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc020575c:	0ff00793          	li	a5,255
    int num = tf->gpr.a0;
ffffffffc0205760:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205764:	0327ee63          	bltu	a5,s2,ffffffffc02057a0 <syscall+0x5a>
        if (syscalls[num] != NULL) {
ffffffffc0205768:	00391713          	slli	a4,s2,0x3
ffffffffc020576c:	00002797          	auipc	a5,0x2
ffffffffc0205770:	2bc78793          	addi	a5,a5,700 # ffffffffc0207a28 <syscalls>
ffffffffc0205774:	97ba                	add	a5,a5,a4
ffffffffc0205776:	639c                	ld	a5,0(a5)
ffffffffc0205778:	c785                	beqz	a5,ffffffffc02057a0 <syscall+0x5a>
            arg[0] = tf->gpr.a1;
ffffffffc020577a:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc020577c:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc020577e:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0205780:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0205782:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0205784:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0205786:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0205788:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc020578a:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc020578c:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc020578e:	0028                	addi	a0,sp,8
ffffffffc0205790:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0205792:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205794:	e828                	sd	a0,80(s0)
}
ffffffffc0205796:	6406                	ld	s0,64(sp)
ffffffffc0205798:	74e2                	ld	s1,56(sp)
ffffffffc020579a:	7942                	ld	s2,48(sp)
ffffffffc020579c:	6161                	addi	sp,sp,80
ffffffffc020579e:	8082                	ret
    print_trapframe(tf);
ffffffffc02057a0:	8522                	mv	a0,s0
ffffffffc02057a2:	bfcfb0ef          	jal	ra,ffffffffc0200b9e <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc02057a6:	609c                	ld	a5,0(s1)
ffffffffc02057a8:	86ca                	mv	a3,s2
ffffffffc02057aa:	00002617          	auipc	a2,0x2
ffffffffc02057ae:	23660613          	addi	a2,a2,566 # ffffffffc02079e0 <default_pmm_manager+0xf08>
ffffffffc02057b2:	43d8                	lw	a4,4(a5)
ffffffffc02057b4:	06c00593          	li	a1,108
ffffffffc02057b8:	0b478793          	addi	a5,a5,180
ffffffffc02057bc:	00002517          	auipc	a0,0x2
ffffffffc02057c0:	25450513          	addi	a0,a0,596 # ffffffffc0207a10 <default_pmm_manager+0xf38>
ffffffffc02057c4:	ccffa0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02057c8 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02057c8:	9e3707b7          	lui	a5,0x9e370
ffffffffc02057cc:	2785                	addiw	a5,a5,1
ffffffffc02057ce:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc02057d2:	02000793          	li	a5,32
ffffffffc02057d6:	9f8d                	subw	a5,a5,a1
}
ffffffffc02057d8:	00f5553b          	srlw	a0,a0,a5
ffffffffc02057dc:	8082                	ret

ffffffffc02057de <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02057de:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02057e2:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02057e4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02057e8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02057ea:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02057ee:	f022                	sd	s0,32(sp)
ffffffffc02057f0:	ec26                	sd	s1,24(sp)
ffffffffc02057f2:	e84a                	sd	s2,16(sp)
ffffffffc02057f4:	f406                	sd	ra,40(sp)
ffffffffc02057f6:	e44e                	sd	s3,8(sp)
ffffffffc02057f8:	84aa                	mv	s1,a0
ffffffffc02057fa:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02057fc:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0205800:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0205802:	03067e63          	bgeu	a2,a6,ffffffffc020583e <printnum+0x60>
ffffffffc0205806:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0205808:	00805763          	blez	s0,ffffffffc0205816 <printnum+0x38>
ffffffffc020580c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020580e:	85ca                	mv	a1,s2
ffffffffc0205810:	854e                	mv	a0,s3
ffffffffc0205812:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0205814:	fc65                	bnez	s0,ffffffffc020580c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205816:	1a02                	slli	s4,s4,0x20
ffffffffc0205818:	00003797          	auipc	a5,0x3
ffffffffc020581c:	a1078793          	addi	a5,a5,-1520 # ffffffffc0208228 <syscalls+0x800>
ffffffffc0205820:	020a5a13          	srli	s4,s4,0x20
ffffffffc0205824:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0205826:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205828:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020582c:	70a2                	ld	ra,40(sp)
ffffffffc020582e:	69a2                	ld	s3,8(sp)
ffffffffc0205830:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205832:	85ca                	mv	a1,s2
ffffffffc0205834:	87a6                	mv	a5,s1
}
ffffffffc0205836:	6942                	ld	s2,16(sp)
ffffffffc0205838:	64e2                	ld	s1,24(sp)
ffffffffc020583a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020583c:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020583e:	03065633          	divu	a2,a2,a6
ffffffffc0205842:	8722                	mv	a4,s0
ffffffffc0205844:	f9bff0ef          	jal	ra,ffffffffc02057de <printnum>
ffffffffc0205848:	b7f9                	j	ffffffffc0205816 <printnum+0x38>

ffffffffc020584a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020584a:	7119                	addi	sp,sp,-128
ffffffffc020584c:	f4a6                	sd	s1,104(sp)
ffffffffc020584e:	f0ca                	sd	s2,96(sp)
ffffffffc0205850:	ecce                	sd	s3,88(sp)
ffffffffc0205852:	e8d2                	sd	s4,80(sp)
ffffffffc0205854:	e4d6                	sd	s5,72(sp)
ffffffffc0205856:	e0da                	sd	s6,64(sp)
ffffffffc0205858:	fc5e                	sd	s7,56(sp)
ffffffffc020585a:	f06a                	sd	s10,32(sp)
ffffffffc020585c:	fc86                	sd	ra,120(sp)
ffffffffc020585e:	f8a2                	sd	s0,112(sp)
ffffffffc0205860:	f862                	sd	s8,48(sp)
ffffffffc0205862:	f466                	sd	s9,40(sp)
ffffffffc0205864:	ec6e                	sd	s11,24(sp)
ffffffffc0205866:	892a                	mv	s2,a0
ffffffffc0205868:	84ae                	mv	s1,a1
ffffffffc020586a:	8d32                	mv	s10,a2
ffffffffc020586c:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020586e:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0205872:	5b7d                	li	s6,-1
ffffffffc0205874:	00003a97          	auipc	s5,0x3
ffffffffc0205878:	9e0a8a93          	addi	s5,s5,-1568 # ffffffffc0208254 <syscalls+0x82c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020587c:	00003b97          	auipc	s7,0x3
ffffffffc0205880:	bf4b8b93          	addi	s7,s7,-1036 # ffffffffc0208470 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205884:	000d4503          	lbu	a0,0(s10)
ffffffffc0205888:	001d0413          	addi	s0,s10,1
ffffffffc020588c:	01350a63          	beq	a0,s3,ffffffffc02058a0 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0205890:	c121                	beqz	a0,ffffffffc02058d0 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0205892:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205894:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0205896:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205898:	fff44503          	lbu	a0,-1(s0)
ffffffffc020589c:	ff351ae3          	bne	a0,s3,ffffffffc0205890 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02058a0:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02058a4:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02058a8:	4c81                	li	s9,0
ffffffffc02058aa:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02058ac:	5c7d                	li	s8,-1
ffffffffc02058ae:	5dfd                	li	s11,-1
ffffffffc02058b0:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02058b4:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02058b6:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02058ba:	0ff5f593          	zext.b	a1,a1
ffffffffc02058be:	00140d13          	addi	s10,s0,1
ffffffffc02058c2:	04b56263          	bltu	a0,a1,ffffffffc0205906 <vprintfmt+0xbc>
ffffffffc02058c6:	058a                	slli	a1,a1,0x2
ffffffffc02058c8:	95d6                	add	a1,a1,s5
ffffffffc02058ca:	4194                	lw	a3,0(a1)
ffffffffc02058cc:	96d6                	add	a3,a3,s5
ffffffffc02058ce:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02058d0:	70e6                	ld	ra,120(sp)
ffffffffc02058d2:	7446                	ld	s0,112(sp)
ffffffffc02058d4:	74a6                	ld	s1,104(sp)
ffffffffc02058d6:	7906                	ld	s2,96(sp)
ffffffffc02058d8:	69e6                	ld	s3,88(sp)
ffffffffc02058da:	6a46                	ld	s4,80(sp)
ffffffffc02058dc:	6aa6                	ld	s5,72(sp)
ffffffffc02058de:	6b06                	ld	s6,64(sp)
ffffffffc02058e0:	7be2                	ld	s7,56(sp)
ffffffffc02058e2:	7c42                	ld	s8,48(sp)
ffffffffc02058e4:	7ca2                	ld	s9,40(sp)
ffffffffc02058e6:	7d02                	ld	s10,32(sp)
ffffffffc02058e8:	6de2                	ld	s11,24(sp)
ffffffffc02058ea:	6109                	addi	sp,sp,128
ffffffffc02058ec:	8082                	ret
            padc = '0';
ffffffffc02058ee:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02058f0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02058f4:	846a                	mv	s0,s10
ffffffffc02058f6:	00140d13          	addi	s10,s0,1
ffffffffc02058fa:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02058fe:	0ff5f593          	zext.b	a1,a1
ffffffffc0205902:	fcb572e3          	bgeu	a0,a1,ffffffffc02058c6 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0205906:	85a6                	mv	a1,s1
ffffffffc0205908:	02500513          	li	a0,37
ffffffffc020590c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020590e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0205912:	8d22                	mv	s10,s0
ffffffffc0205914:	f73788e3          	beq	a5,s3,ffffffffc0205884 <vprintfmt+0x3a>
ffffffffc0205918:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020591c:	1d7d                	addi	s10,s10,-1
ffffffffc020591e:	ff379de3          	bne	a5,s3,ffffffffc0205918 <vprintfmt+0xce>
ffffffffc0205922:	b78d                	j	ffffffffc0205884 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0205924:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0205928:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020592c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020592e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0205932:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0205936:	02d86463          	bltu	a6,a3,ffffffffc020595e <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020593a:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020593e:	002c169b          	slliw	a3,s8,0x2
ffffffffc0205942:	0186873b          	addw	a4,a3,s8
ffffffffc0205946:	0017171b          	slliw	a4,a4,0x1
ffffffffc020594a:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020594c:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0205950:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0205952:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0205956:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020595a:	fed870e3          	bgeu	a6,a3,ffffffffc020593a <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020595e:	f40ddce3          	bgez	s11,ffffffffc02058b6 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0205962:	8de2                	mv	s11,s8
ffffffffc0205964:	5c7d                	li	s8,-1
ffffffffc0205966:	bf81                	j	ffffffffc02058b6 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0205968:	fffdc693          	not	a3,s11
ffffffffc020596c:	96fd                	srai	a3,a3,0x3f
ffffffffc020596e:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205972:	00144603          	lbu	a2,1(s0)
ffffffffc0205976:	2d81                	sext.w	s11,s11
ffffffffc0205978:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020597a:	bf35                	j	ffffffffc02058b6 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020597c:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205980:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0205984:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205986:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0205988:	bfd9                	j	ffffffffc020595e <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020598a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020598c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205990:	01174463          	blt	a4,a7,ffffffffc0205998 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0205994:	1a088e63          	beqz	a7,ffffffffc0205b50 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0205998:	000a3603          	ld	a2,0(s4)
ffffffffc020599c:	46c1                	li	a3,16
ffffffffc020599e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02059a0:	2781                	sext.w	a5,a5
ffffffffc02059a2:	876e                	mv	a4,s11
ffffffffc02059a4:	85a6                	mv	a1,s1
ffffffffc02059a6:	854a                	mv	a0,s2
ffffffffc02059a8:	e37ff0ef          	jal	ra,ffffffffc02057de <printnum>
            break;
ffffffffc02059ac:	bde1                	j	ffffffffc0205884 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02059ae:	000a2503          	lw	a0,0(s4)
ffffffffc02059b2:	85a6                	mv	a1,s1
ffffffffc02059b4:	0a21                	addi	s4,s4,8
ffffffffc02059b6:	9902                	jalr	s2
            break;
ffffffffc02059b8:	b5f1                	j	ffffffffc0205884 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02059ba:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02059bc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02059c0:	01174463          	blt	a4,a7,ffffffffc02059c8 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02059c4:	18088163          	beqz	a7,ffffffffc0205b46 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02059c8:	000a3603          	ld	a2,0(s4)
ffffffffc02059cc:	46a9                	li	a3,10
ffffffffc02059ce:	8a2e                	mv	s4,a1
ffffffffc02059d0:	bfc1                	j	ffffffffc02059a0 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02059d2:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02059d6:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02059d8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02059da:	bdf1                	j	ffffffffc02058b6 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02059dc:	85a6                	mv	a1,s1
ffffffffc02059de:	02500513          	li	a0,37
ffffffffc02059e2:	9902                	jalr	s2
            break;
ffffffffc02059e4:	b545                	j	ffffffffc0205884 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02059e6:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02059ea:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02059ec:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02059ee:	b5e1                	j	ffffffffc02058b6 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02059f0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02059f2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02059f6:	01174463          	blt	a4,a7,ffffffffc02059fe <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02059fa:	14088163          	beqz	a7,ffffffffc0205b3c <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02059fe:	000a3603          	ld	a2,0(s4)
ffffffffc0205a02:	46a1                	li	a3,8
ffffffffc0205a04:	8a2e                	mv	s4,a1
ffffffffc0205a06:	bf69                	j	ffffffffc02059a0 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0205a08:	03000513          	li	a0,48
ffffffffc0205a0c:	85a6                	mv	a1,s1
ffffffffc0205a0e:	e03e                	sd	a5,0(sp)
ffffffffc0205a10:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0205a12:	85a6                	mv	a1,s1
ffffffffc0205a14:	07800513          	li	a0,120
ffffffffc0205a18:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0205a1a:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0205a1c:	6782                	ld	a5,0(sp)
ffffffffc0205a1e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0205a20:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0205a24:	bfb5                	j	ffffffffc02059a0 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0205a26:	000a3403          	ld	s0,0(s4)
ffffffffc0205a2a:	008a0713          	addi	a4,s4,8
ffffffffc0205a2e:	e03a                	sd	a4,0(sp)
ffffffffc0205a30:	14040263          	beqz	s0,ffffffffc0205b74 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0205a34:	0fb05763          	blez	s11,ffffffffc0205b22 <vprintfmt+0x2d8>
ffffffffc0205a38:	02d00693          	li	a3,45
ffffffffc0205a3c:	0cd79163          	bne	a5,a3,ffffffffc0205afe <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205a40:	00044783          	lbu	a5,0(s0)
ffffffffc0205a44:	0007851b          	sext.w	a0,a5
ffffffffc0205a48:	cf85                	beqz	a5,ffffffffc0205a80 <vprintfmt+0x236>
ffffffffc0205a4a:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205a4e:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205a52:	000c4563          	bltz	s8,ffffffffc0205a5c <vprintfmt+0x212>
ffffffffc0205a56:	3c7d                	addiw	s8,s8,-1
ffffffffc0205a58:	036c0263          	beq	s8,s6,ffffffffc0205a7c <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0205a5c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205a5e:	0e0c8e63          	beqz	s9,ffffffffc0205b5a <vprintfmt+0x310>
ffffffffc0205a62:	3781                	addiw	a5,a5,-32
ffffffffc0205a64:	0ef47b63          	bgeu	s0,a5,ffffffffc0205b5a <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0205a68:	03f00513          	li	a0,63
ffffffffc0205a6c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205a6e:	000a4783          	lbu	a5,0(s4)
ffffffffc0205a72:	3dfd                	addiw	s11,s11,-1
ffffffffc0205a74:	0a05                	addi	s4,s4,1
ffffffffc0205a76:	0007851b          	sext.w	a0,a5
ffffffffc0205a7a:	ffe1                	bnez	a5,ffffffffc0205a52 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0205a7c:	01b05963          	blez	s11,ffffffffc0205a8e <vprintfmt+0x244>
ffffffffc0205a80:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0205a82:	85a6                	mv	a1,s1
ffffffffc0205a84:	02000513          	li	a0,32
ffffffffc0205a88:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0205a8a:	fe0d9be3          	bnez	s11,ffffffffc0205a80 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0205a8e:	6a02                	ld	s4,0(sp)
ffffffffc0205a90:	bbd5                	j	ffffffffc0205884 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0205a92:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205a94:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0205a98:	01174463          	blt	a4,a7,ffffffffc0205aa0 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0205a9c:	08088d63          	beqz	a7,ffffffffc0205b36 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0205aa0:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0205aa4:	0a044d63          	bltz	s0,ffffffffc0205b5e <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0205aa8:	8622                	mv	a2,s0
ffffffffc0205aaa:	8a66                	mv	s4,s9
ffffffffc0205aac:	46a9                	li	a3,10
ffffffffc0205aae:	bdcd                	j	ffffffffc02059a0 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0205ab0:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205ab4:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0205ab6:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0205ab8:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0205abc:	8fb5                	xor	a5,a5,a3
ffffffffc0205abe:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205ac2:	02d74163          	blt	a4,a3,ffffffffc0205ae4 <vprintfmt+0x29a>
ffffffffc0205ac6:	00369793          	slli	a5,a3,0x3
ffffffffc0205aca:	97de                	add	a5,a5,s7
ffffffffc0205acc:	639c                	ld	a5,0(a5)
ffffffffc0205ace:	cb99                	beqz	a5,ffffffffc0205ae4 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0205ad0:	86be                	mv	a3,a5
ffffffffc0205ad2:	00000617          	auipc	a2,0x0
ffffffffc0205ad6:	1ee60613          	addi	a2,a2,494 # ffffffffc0205cc0 <etext+0x28>
ffffffffc0205ada:	85a6                	mv	a1,s1
ffffffffc0205adc:	854a                	mv	a0,s2
ffffffffc0205ade:	0ce000ef          	jal	ra,ffffffffc0205bac <printfmt>
ffffffffc0205ae2:	b34d                	j	ffffffffc0205884 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0205ae4:	00002617          	auipc	a2,0x2
ffffffffc0205ae8:	76460613          	addi	a2,a2,1892 # ffffffffc0208248 <syscalls+0x820>
ffffffffc0205aec:	85a6                	mv	a1,s1
ffffffffc0205aee:	854a                	mv	a0,s2
ffffffffc0205af0:	0bc000ef          	jal	ra,ffffffffc0205bac <printfmt>
ffffffffc0205af4:	bb41                	j	ffffffffc0205884 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0205af6:	00002417          	auipc	s0,0x2
ffffffffc0205afa:	74a40413          	addi	s0,s0,1866 # ffffffffc0208240 <syscalls+0x818>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205afe:	85e2                	mv	a1,s8
ffffffffc0205b00:	8522                	mv	a0,s0
ffffffffc0205b02:	e43e                	sd	a5,8(sp)
ffffffffc0205b04:	0e2000ef          	jal	ra,ffffffffc0205be6 <strnlen>
ffffffffc0205b08:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0205b0c:	01b05b63          	blez	s11,ffffffffc0205b22 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0205b10:	67a2                	ld	a5,8(sp)
ffffffffc0205b12:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205b16:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0205b18:	85a6                	mv	a1,s1
ffffffffc0205b1a:	8552                	mv	a0,s4
ffffffffc0205b1c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205b1e:	fe0d9ce3          	bnez	s11,ffffffffc0205b16 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205b22:	00044783          	lbu	a5,0(s0)
ffffffffc0205b26:	00140a13          	addi	s4,s0,1
ffffffffc0205b2a:	0007851b          	sext.w	a0,a5
ffffffffc0205b2e:	d3a5                	beqz	a5,ffffffffc0205a8e <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205b30:	05e00413          	li	s0,94
ffffffffc0205b34:	bf39                	j	ffffffffc0205a52 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0205b36:	000a2403          	lw	s0,0(s4)
ffffffffc0205b3a:	b7ad                	j	ffffffffc0205aa4 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0205b3c:	000a6603          	lwu	a2,0(s4)
ffffffffc0205b40:	46a1                	li	a3,8
ffffffffc0205b42:	8a2e                	mv	s4,a1
ffffffffc0205b44:	bdb1                	j	ffffffffc02059a0 <vprintfmt+0x156>
ffffffffc0205b46:	000a6603          	lwu	a2,0(s4)
ffffffffc0205b4a:	46a9                	li	a3,10
ffffffffc0205b4c:	8a2e                	mv	s4,a1
ffffffffc0205b4e:	bd89                	j	ffffffffc02059a0 <vprintfmt+0x156>
ffffffffc0205b50:	000a6603          	lwu	a2,0(s4)
ffffffffc0205b54:	46c1                	li	a3,16
ffffffffc0205b56:	8a2e                	mv	s4,a1
ffffffffc0205b58:	b5a1                	j	ffffffffc02059a0 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0205b5a:	9902                	jalr	s2
ffffffffc0205b5c:	bf09                	j	ffffffffc0205a6e <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0205b5e:	85a6                	mv	a1,s1
ffffffffc0205b60:	02d00513          	li	a0,45
ffffffffc0205b64:	e03e                	sd	a5,0(sp)
ffffffffc0205b66:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0205b68:	6782                	ld	a5,0(sp)
ffffffffc0205b6a:	8a66                	mv	s4,s9
ffffffffc0205b6c:	40800633          	neg	a2,s0
ffffffffc0205b70:	46a9                	li	a3,10
ffffffffc0205b72:	b53d                	j	ffffffffc02059a0 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0205b74:	03b05163          	blez	s11,ffffffffc0205b96 <vprintfmt+0x34c>
ffffffffc0205b78:	02d00693          	li	a3,45
ffffffffc0205b7c:	f6d79de3          	bne	a5,a3,ffffffffc0205af6 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0205b80:	00002417          	auipc	s0,0x2
ffffffffc0205b84:	6c040413          	addi	s0,s0,1728 # ffffffffc0208240 <syscalls+0x818>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205b88:	02800793          	li	a5,40
ffffffffc0205b8c:	02800513          	li	a0,40
ffffffffc0205b90:	00140a13          	addi	s4,s0,1
ffffffffc0205b94:	bd6d                	j	ffffffffc0205a4e <vprintfmt+0x204>
ffffffffc0205b96:	00002a17          	auipc	s4,0x2
ffffffffc0205b9a:	6aba0a13          	addi	s4,s4,1707 # ffffffffc0208241 <syscalls+0x819>
ffffffffc0205b9e:	02800513          	li	a0,40
ffffffffc0205ba2:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205ba6:	05e00413          	li	s0,94
ffffffffc0205baa:	b565                	j	ffffffffc0205a52 <vprintfmt+0x208>

ffffffffc0205bac <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205bac:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0205bae:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205bb2:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205bb4:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205bb6:	ec06                	sd	ra,24(sp)
ffffffffc0205bb8:	f83a                	sd	a4,48(sp)
ffffffffc0205bba:	fc3e                	sd	a5,56(sp)
ffffffffc0205bbc:	e0c2                	sd	a6,64(sp)
ffffffffc0205bbe:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0205bc0:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205bc2:	c89ff0ef          	jal	ra,ffffffffc020584a <vprintfmt>
}
ffffffffc0205bc6:	60e2                	ld	ra,24(sp)
ffffffffc0205bc8:	6161                	addi	sp,sp,80
ffffffffc0205bca:	8082                	ret

ffffffffc0205bcc <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0205bcc:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0205bd0:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0205bd2:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0205bd4:	cb81                	beqz	a5,ffffffffc0205be4 <strlen+0x18>
        cnt ++;
ffffffffc0205bd6:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0205bd8:	00a707b3          	add	a5,a4,a0
ffffffffc0205bdc:	0007c783          	lbu	a5,0(a5)
ffffffffc0205be0:	fbfd                	bnez	a5,ffffffffc0205bd6 <strlen+0xa>
ffffffffc0205be2:	8082                	ret
    }
    return cnt;
}
ffffffffc0205be4:	8082                	ret

ffffffffc0205be6 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0205be6:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205be8:	e589                	bnez	a1,ffffffffc0205bf2 <strnlen+0xc>
ffffffffc0205bea:	a811                	j	ffffffffc0205bfe <strnlen+0x18>
        cnt ++;
ffffffffc0205bec:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205bee:	00f58863          	beq	a1,a5,ffffffffc0205bfe <strnlen+0x18>
ffffffffc0205bf2:	00f50733          	add	a4,a0,a5
ffffffffc0205bf6:	00074703          	lbu	a4,0(a4)
ffffffffc0205bfa:	fb6d                	bnez	a4,ffffffffc0205bec <strnlen+0x6>
ffffffffc0205bfc:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0205bfe:	852e                	mv	a0,a1
ffffffffc0205c00:	8082                	ret

ffffffffc0205c02 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0205c02:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0205c04:	0005c703          	lbu	a4,0(a1)
ffffffffc0205c08:	0785                	addi	a5,a5,1
ffffffffc0205c0a:	0585                	addi	a1,a1,1
ffffffffc0205c0c:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0205c10:	fb75                	bnez	a4,ffffffffc0205c04 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0205c12:	8082                	ret

ffffffffc0205c14 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205c14:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205c18:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205c1c:	cb89                	beqz	a5,ffffffffc0205c2e <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0205c1e:	0505                	addi	a0,a0,1
ffffffffc0205c20:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205c22:	fee789e3          	beq	a5,a4,ffffffffc0205c14 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205c26:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0205c2a:	9d19                	subw	a0,a0,a4
ffffffffc0205c2c:	8082                	ret
ffffffffc0205c2e:	4501                	li	a0,0
ffffffffc0205c30:	bfed                	j	ffffffffc0205c2a <strcmp+0x16>

ffffffffc0205c32 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205c32:	c20d                	beqz	a2,ffffffffc0205c54 <strncmp+0x22>
ffffffffc0205c34:	962e                	add	a2,a2,a1
ffffffffc0205c36:	a031                	j	ffffffffc0205c42 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0205c38:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205c3a:	00e79a63          	bne	a5,a4,ffffffffc0205c4e <strncmp+0x1c>
ffffffffc0205c3e:	00b60b63          	beq	a2,a1,ffffffffc0205c54 <strncmp+0x22>
ffffffffc0205c42:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0205c46:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205c48:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0205c4c:	f7f5                	bnez	a5,ffffffffc0205c38 <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205c4e:	40e7853b          	subw	a0,a5,a4
}
ffffffffc0205c52:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205c54:	4501                	li	a0,0
ffffffffc0205c56:	8082                	ret

ffffffffc0205c58 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0205c58:	00054783          	lbu	a5,0(a0)
ffffffffc0205c5c:	c799                	beqz	a5,ffffffffc0205c6a <strchr+0x12>
        if (*s == c) {
ffffffffc0205c5e:	00f58763          	beq	a1,a5,ffffffffc0205c6c <strchr+0x14>
    while (*s != '\0') {
ffffffffc0205c62:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0205c66:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0205c68:	fbfd                	bnez	a5,ffffffffc0205c5e <strchr+0x6>
    }
    return NULL;
ffffffffc0205c6a:	4501                	li	a0,0
}
ffffffffc0205c6c:	8082                	ret

ffffffffc0205c6e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0205c6e:	ca01                	beqz	a2,ffffffffc0205c7e <memset+0x10>
ffffffffc0205c70:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0205c72:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0205c74:	0785                	addi	a5,a5,1
ffffffffc0205c76:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0205c7a:	fec79de3          	bne	a5,a2,ffffffffc0205c74 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0205c7e:	8082                	ret

ffffffffc0205c80 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0205c80:	ca19                	beqz	a2,ffffffffc0205c96 <memcpy+0x16>
ffffffffc0205c82:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0205c84:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0205c86:	0005c703          	lbu	a4,0(a1)
ffffffffc0205c8a:	0585                	addi	a1,a1,1
ffffffffc0205c8c:	0785                	addi	a5,a5,1
ffffffffc0205c8e:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0205c92:	fec59ae3          	bne	a1,a2,ffffffffc0205c86 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0205c96:	8082                	ret
