
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
ffffffffc0200062:	015050ef          	jal	ra,ffffffffc0205876 <memset>
    cons_init(); // init the console
ffffffffc0200066:	520000ef          	jal	ra,ffffffffc0200586 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006a:	00006597          	auipc	a1,0x6
ffffffffc020006e:	83658593          	addi	a1,a1,-1994 # ffffffffc02058a0 <etext>
ffffffffc0200072:	00006517          	auipc	a0,0x6
ffffffffc0200076:	84e50513          	addi	a0,a0,-1970 # ffffffffc02058c0 <etext+0x20>
ffffffffc020007a:	11e000ef          	jal	ra,ffffffffc0200198 <cprintf>

    print_kerninfo();
ffffffffc020007e:	1a2000ef          	jal	ra,ffffffffc0200220 <print_kerninfo>

    // grade_backtrace();

    dtb_init(); // init dtb
ffffffffc0200082:	576000ef          	jal	ra,ffffffffc02005f8 <dtb_init>

    pmm_init(); // init physical memory management
ffffffffc0200086:	628020ef          	jal	ra,ffffffffc02026ae <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	12b000ef          	jal	ra,ffffffffc02009b4 <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	129000ef          	jal	ra,ffffffffc02009b6 <idt_init>

    vmm_init(); // init virtual memory management
ffffffffc0200092:	0f5030ef          	jal	ra,ffffffffc0203986 <vmm_init>
    sched_init();
ffffffffc0200096:	076050ef          	jal	ra,ffffffffc020510c <sched_init>
    proc_init(); // init process table
ffffffffc020009a:	515040ef          	jal	ra,ffffffffc0204dae <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009e:	4a0000ef          	jal	ra,ffffffffc020053e <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc02000a2:	107000ef          	jal	ra,ffffffffc02009a8 <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a6:	6a1040ef          	jal	ra,ffffffffc0204f46 <cpu_idle>

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
ffffffffc02000c4:	80850513          	addi	a0,a0,-2040 # ffffffffc02058c8 <etext+0x28>
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
ffffffffc020018c:	2c6050ef          	jal	ra,ffffffffc0205452 <vprintfmt>
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
ffffffffc02001c2:	290050ef          	jal	ra,ffffffffc0205452 <vprintfmt>
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
ffffffffc0200222:	00005517          	auipc	a0,0x5
ffffffffc0200226:	6ae50513          	addi	a0,a0,1710 # ffffffffc02058d0 <etext+0x30>
void print_kerninfo(void) {
ffffffffc020022a:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020022c:	f6dff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200230:	00000597          	auipc	a1,0x0
ffffffffc0200234:	e1a58593          	addi	a1,a1,-486 # ffffffffc020004a <kern_init>
ffffffffc0200238:	00005517          	auipc	a0,0x5
ffffffffc020023c:	6b850513          	addi	a0,a0,1720 # ffffffffc02058f0 <etext+0x50>
ffffffffc0200240:	f59ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200244:	00005597          	auipc	a1,0x5
ffffffffc0200248:	65c58593          	addi	a1,a1,1628 # ffffffffc02058a0 <etext>
ffffffffc020024c:	00005517          	auipc	a0,0x5
ffffffffc0200250:	6c450513          	addi	a0,a0,1732 # ffffffffc0205910 <etext+0x70>
ffffffffc0200254:	f45ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200258:	000ce597          	auipc	a1,0xce
ffffffffc020025c:	0b058593          	addi	a1,a1,176 # ffffffffc02ce308 <buf>
ffffffffc0200260:	00005517          	auipc	a0,0x5
ffffffffc0200264:	6d050513          	addi	a0,a0,1744 # ffffffffc0205930 <etext+0x90>
ffffffffc0200268:	f31ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc020026c:	000d2597          	auipc	a1,0xd2
ffffffffc0200270:	58458593          	addi	a1,a1,1412 # ffffffffc02d27f0 <end>
ffffffffc0200274:	00005517          	auipc	a0,0x5
ffffffffc0200278:	6dc50513          	addi	a0,a0,1756 # ffffffffc0205950 <etext+0xb0>
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
ffffffffc02002a2:	00005517          	auipc	a0,0x5
ffffffffc02002a6:	6ce50513          	addi	a0,a0,1742 # ffffffffc0205970 <etext+0xd0>
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
ffffffffc02002b0:	00005617          	auipc	a2,0x5
ffffffffc02002b4:	6f060613          	addi	a2,a2,1776 # ffffffffc02059a0 <etext+0x100>
ffffffffc02002b8:	04d00593          	li	a1,77
ffffffffc02002bc:	00005517          	auipc	a0,0x5
ffffffffc02002c0:	6fc50513          	addi	a0,a0,1788 # ffffffffc02059b8 <etext+0x118>
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
ffffffffc02002cc:	00005617          	auipc	a2,0x5
ffffffffc02002d0:	70460613          	addi	a2,a2,1796 # ffffffffc02059d0 <etext+0x130>
ffffffffc02002d4:	00005597          	auipc	a1,0x5
ffffffffc02002d8:	71c58593          	addi	a1,a1,1820 # ffffffffc02059f0 <etext+0x150>
ffffffffc02002dc:	00005517          	auipc	a0,0x5
ffffffffc02002e0:	71c50513          	addi	a0,a0,1820 # ffffffffc02059f8 <etext+0x158>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e4:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e6:	eb3ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
ffffffffc02002ea:	00005617          	auipc	a2,0x5
ffffffffc02002ee:	71e60613          	addi	a2,a2,1822 # ffffffffc0205a08 <etext+0x168>
ffffffffc02002f2:	00005597          	auipc	a1,0x5
ffffffffc02002f6:	73e58593          	addi	a1,a1,1854 # ffffffffc0205a30 <etext+0x190>
ffffffffc02002fa:	00005517          	auipc	a0,0x5
ffffffffc02002fe:	6fe50513          	addi	a0,a0,1790 # ffffffffc02059f8 <etext+0x158>
ffffffffc0200302:	e97ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
ffffffffc0200306:	00005617          	auipc	a2,0x5
ffffffffc020030a:	73a60613          	addi	a2,a2,1850 # ffffffffc0205a40 <etext+0x1a0>
ffffffffc020030e:	00005597          	auipc	a1,0x5
ffffffffc0200312:	75258593          	addi	a1,a1,1874 # ffffffffc0205a60 <etext+0x1c0>
ffffffffc0200316:	00005517          	auipc	a0,0x5
ffffffffc020031a:	6e250513          	addi	a0,a0,1762 # ffffffffc02059f8 <etext+0x158>
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
ffffffffc0200350:	00005517          	auipc	a0,0x5
ffffffffc0200354:	72050513          	addi	a0,a0,1824 # ffffffffc0205a70 <etext+0x1d0>
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
ffffffffc0200372:	00005517          	auipc	a0,0x5
ffffffffc0200376:	72650513          	addi	a0,a0,1830 # ffffffffc0205a98 <etext+0x1f8>
ffffffffc020037a:	e1fff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    if (tf != NULL) {
ffffffffc020037e:	000b8563          	beqz	s7,ffffffffc0200388 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200382:	855e                	mv	a0,s7
ffffffffc0200384:	01b000ef          	jal	ra,ffffffffc0200b9e <print_trapframe>
ffffffffc0200388:	00005c17          	auipc	s8,0x5
ffffffffc020038c:	780c0c13          	addi	s8,s8,1920 # ffffffffc0205b08 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200390:	00005917          	auipc	s2,0x5
ffffffffc0200394:	73090913          	addi	s2,s2,1840 # ffffffffc0205ac0 <etext+0x220>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200398:	00005497          	auipc	s1,0x5
ffffffffc020039c:	73048493          	addi	s1,s1,1840 # ffffffffc0205ac8 <etext+0x228>
        if (argc == MAXARGS - 1) {
ffffffffc02003a0:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003a2:	00005b17          	auipc	s6,0x5
ffffffffc02003a6:	72eb0b13          	addi	s6,s6,1838 # ffffffffc0205ad0 <etext+0x230>
        argv[argc ++] = buf;
ffffffffc02003aa:	00005a17          	auipc	s4,0x5
ffffffffc02003ae:	646a0a13          	addi	s4,s4,1606 # ffffffffc02059f0 <etext+0x150>
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
ffffffffc02003cc:	00005d17          	auipc	s10,0x5
ffffffffc02003d0:	73cd0d13          	addi	s10,s10,1852 # ffffffffc0205b08 <commands>
        argv[argc ++] = buf;
ffffffffc02003d4:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003d6:	4401                	li	s0,0
ffffffffc02003d8:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003da:	442050ef          	jal	ra,ffffffffc020581c <strcmp>
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
ffffffffc02003ee:	42e050ef          	jal	ra,ffffffffc020581c <strcmp>
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
ffffffffc020042c:	434050ef          	jal	ra,ffffffffc0205860 <strchr>
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
ffffffffc020046a:	3f6050ef          	jal	ra,ffffffffc0205860 <strchr>
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
ffffffffc0200484:	00005517          	auipc	a0,0x5
ffffffffc0200488:	66c50513          	addi	a0,a0,1644 # ffffffffc0205af0 <etext+0x250>
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
ffffffffc02004c0:	00005517          	auipc	a0,0x5
ffffffffc02004c4:	69050513          	addi	a0,a0,1680 # ffffffffc0205b50 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02004c8:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004ca:	ccfff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004ce:	65a2                	ld	a1,8(sp)
ffffffffc02004d0:	8522                	mv	a0,s0
ffffffffc02004d2:	ca7ff0ef          	jal	ra,ffffffffc0200178 <vcprintf>
    cprintf("\n");
ffffffffc02004d6:	00006517          	auipc	a0,0x6
ffffffffc02004da:	7aa50513          	addi	a0,a0,1962 # ffffffffc0206c80 <default_pmm_manager+0x578>
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
ffffffffc020050a:	00005517          	auipc	a0,0x5
ffffffffc020050e:	66650513          	addi	a0,a0,1638 # ffffffffc0205b70 <commands+0x68>
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
ffffffffc020052a:	00006517          	auipc	a0,0x6
ffffffffc020052e:	75650513          	addi	a0,a0,1878 # ffffffffc0206c80 <default_pmm_manager+0x578>
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
ffffffffc020055c:	00005517          	auipc	a0,0x5
ffffffffc0200560:	63450513          	addi	a0,a0,1588 # ffffffffc0205b90 <commands+0x88>
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
ffffffffc02005fa:	00005517          	auipc	a0,0x5
ffffffffc02005fe:	5b650513          	addi	a0,a0,1462 # ffffffffc0205bb0 <commands+0xa8>
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
ffffffffc0200628:	00005517          	auipc	a0,0x5
ffffffffc020062c:	59850513          	addi	a0,a0,1432 # ffffffffc0205bc0 <commands+0xb8>
ffffffffc0200630:	b69ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200634:	0000c417          	auipc	s0,0xc
ffffffffc0200638:	9d440413          	addi	s0,s0,-1580 # ffffffffc020c008 <boot_dtb>
ffffffffc020063c:	600c                	ld	a1,0(s0)
ffffffffc020063e:	00005517          	auipc	a0,0x5
ffffffffc0200642:	59250513          	addi	a0,a0,1426 # ffffffffc0205bd0 <commands+0xc8>
ffffffffc0200646:	b53ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc020064a:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc020064e:	00005517          	auipc	a0,0x5
ffffffffc0200652:	59a50513          	addi	a0,a0,1434 # ffffffffc0205be8 <commands+0xe0>
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
ffffffffc0200708:	00005917          	auipc	s2,0x5
ffffffffc020070c:	53090913          	addi	s2,s2,1328 # ffffffffc0205c38 <commands+0x130>
ffffffffc0200710:	49bd                	li	s3,15
        switch (token) {
ffffffffc0200712:	4d91                	li	s11,4
ffffffffc0200714:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200716:	00005497          	auipc	s1,0x5
ffffffffc020071a:	51a48493          	addi	s1,s1,1306 # ffffffffc0205c30 <commands+0x128>
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
ffffffffc020076a:	00005517          	auipc	a0,0x5
ffffffffc020076e:	54650513          	addi	a0,a0,1350 # ffffffffc0205cb0 <commands+0x1a8>
ffffffffc0200772:	a27ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc0200776:	00005517          	auipc	a0,0x5
ffffffffc020077a:	57250513          	addi	a0,a0,1394 # ffffffffc0205ce8 <commands+0x1e0>
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
ffffffffc02007b6:	00005517          	auipc	a0,0x5
ffffffffc02007ba:	45250513          	addi	a0,a0,1106 # ffffffffc0205c08 <commands+0x100>
}
ffffffffc02007be:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02007c0:	bae1                	j	ffffffffc0200198 <cprintf>
                int name_len = strlen(name);
ffffffffc02007c2:	8556                	mv	a0,s5
ffffffffc02007c4:	010050ef          	jal	ra,ffffffffc02057d4 <strlen>
ffffffffc02007c8:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02007ca:	4619                	li	a2,6
ffffffffc02007cc:	85a6                	mv	a1,s1
ffffffffc02007ce:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02007d0:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02007d2:	068050ef          	jal	ra,ffffffffc020583a <strncmp>
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
ffffffffc0200868:	7b5040ef          	jal	ra,ffffffffc020581c <strcmp>
ffffffffc020086c:	66a2                	ld	a3,8(sp)
ffffffffc020086e:	f94d                	bnez	a0,ffffffffc0200820 <dtb_init+0x228>
ffffffffc0200870:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200820 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200874:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc0200878:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc020087c:	00005517          	auipc	a0,0x5
ffffffffc0200880:	3c450513          	addi	a0,a0,964 # ffffffffc0205c40 <commands+0x138>
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
ffffffffc020094e:	31650513          	addi	a0,a0,790 # ffffffffc0205c60 <commands+0x158>
ffffffffc0200952:	847ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc0200956:	014b5613          	srli	a2,s6,0x14
ffffffffc020095a:	85da                	mv	a1,s6
ffffffffc020095c:	00005517          	auipc	a0,0x5
ffffffffc0200960:	31c50513          	addi	a0,a0,796 # ffffffffc0205c78 <commands+0x170>
ffffffffc0200964:	835ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200968:	008b05b3          	add	a1,s6,s0
ffffffffc020096c:	15fd                	addi	a1,a1,-1
ffffffffc020096e:	00005517          	auipc	a0,0x5
ffffffffc0200972:	32a50513          	addi	a0,a0,810 # ffffffffc0205c98 <commands+0x190>
ffffffffc0200976:	823ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("DTB init completed\n");
ffffffffc020097a:	00005517          	auipc	a0,0x5
ffffffffc020097e:	36e50513          	addi	a0,a0,878 # ffffffffc0205ce8 <commands+0x1e0>
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
ffffffffc02009be:	4ca78793          	addi	a5,a5,1226 # ffffffffc0200e84 <__alltraps>
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
ffffffffc02009dc:	32850513          	addi	a0,a0,808 # ffffffffc0205d00 <commands+0x1f8>
{
ffffffffc02009e0:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009e2:	fb6ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02009e6:	640c                	ld	a1,8(s0)
ffffffffc02009e8:	00005517          	auipc	a0,0x5
ffffffffc02009ec:	33050513          	addi	a0,a0,816 # ffffffffc0205d18 <commands+0x210>
ffffffffc02009f0:	fa8ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02009f4:	680c                	ld	a1,16(s0)
ffffffffc02009f6:	00005517          	auipc	a0,0x5
ffffffffc02009fa:	33a50513          	addi	a0,a0,826 # ffffffffc0205d30 <commands+0x228>
ffffffffc02009fe:	f9aff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200a02:	6c0c                	ld	a1,24(s0)
ffffffffc0200a04:	00005517          	auipc	a0,0x5
ffffffffc0200a08:	34450513          	addi	a0,a0,836 # ffffffffc0205d48 <commands+0x240>
ffffffffc0200a0c:	f8cff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200a10:	700c                	ld	a1,32(s0)
ffffffffc0200a12:	00005517          	auipc	a0,0x5
ffffffffc0200a16:	34e50513          	addi	a0,a0,846 # ffffffffc0205d60 <commands+0x258>
ffffffffc0200a1a:	f7eff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200a1e:	740c                	ld	a1,40(s0)
ffffffffc0200a20:	00005517          	auipc	a0,0x5
ffffffffc0200a24:	35850513          	addi	a0,a0,856 # ffffffffc0205d78 <commands+0x270>
ffffffffc0200a28:	f70ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc0200a2c:	780c                	ld	a1,48(s0)
ffffffffc0200a2e:	00005517          	auipc	a0,0x5
ffffffffc0200a32:	36250513          	addi	a0,a0,866 # ffffffffc0205d90 <commands+0x288>
ffffffffc0200a36:	f62ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200a3a:	7c0c                	ld	a1,56(s0)
ffffffffc0200a3c:	00005517          	auipc	a0,0x5
ffffffffc0200a40:	36c50513          	addi	a0,a0,876 # ffffffffc0205da8 <commands+0x2a0>
ffffffffc0200a44:	f54ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200a48:	602c                	ld	a1,64(s0)
ffffffffc0200a4a:	00005517          	auipc	a0,0x5
ffffffffc0200a4e:	37650513          	addi	a0,a0,886 # ffffffffc0205dc0 <commands+0x2b8>
ffffffffc0200a52:	f46ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200a56:	642c                	ld	a1,72(s0)
ffffffffc0200a58:	00005517          	auipc	a0,0x5
ffffffffc0200a5c:	38050513          	addi	a0,a0,896 # ffffffffc0205dd8 <commands+0x2d0>
ffffffffc0200a60:	f38ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200a64:	682c                	ld	a1,80(s0)
ffffffffc0200a66:	00005517          	auipc	a0,0x5
ffffffffc0200a6a:	38a50513          	addi	a0,a0,906 # ffffffffc0205df0 <commands+0x2e8>
ffffffffc0200a6e:	f2aff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200a72:	6c2c                	ld	a1,88(s0)
ffffffffc0200a74:	00005517          	auipc	a0,0x5
ffffffffc0200a78:	39450513          	addi	a0,a0,916 # ffffffffc0205e08 <commands+0x300>
ffffffffc0200a7c:	f1cff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200a80:	702c                	ld	a1,96(s0)
ffffffffc0200a82:	00005517          	auipc	a0,0x5
ffffffffc0200a86:	39e50513          	addi	a0,a0,926 # ffffffffc0205e20 <commands+0x318>
ffffffffc0200a8a:	f0eff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200a8e:	742c                	ld	a1,104(s0)
ffffffffc0200a90:	00005517          	auipc	a0,0x5
ffffffffc0200a94:	3a850513          	addi	a0,a0,936 # ffffffffc0205e38 <commands+0x330>
ffffffffc0200a98:	f00ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200a9c:	782c                	ld	a1,112(s0)
ffffffffc0200a9e:	00005517          	auipc	a0,0x5
ffffffffc0200aa2:	3b250513          	addi	a0,a0,946 # ffffffffc0205e50 <commands+0x348>
ffffffffc0200aa6:	ef2ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200aaa:	7c2c                	ld	a1,120(s0)
ffffffffc0200aac:	00005517          	auipc	a0,0x5
ffffffffc0200ab0:	3bc50513          	addi	a0,a0,956 # ffffffffc0205e68 <commands+0x360>
ffffffffc0200ab4:	ee4ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200ab8:	604c                	ld	a1,128(s0)
ffffffffc0200aba:	00005517          	auipc	a0,0x5
ffffffffc0200abe:	3c650513          	addi	a0,a0,966 # ffffffffc0205e80 <commands+0x378>
ffffffffc0200ac2:	ed6ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200ac6:	644c                	ld	a1,136(s0)
ffffffffc0200ac8:	00005517          	auipc	a0,0x5
ffffffffc0200acc:	3d050513          	addi	a0,a0,976 # ffffffffc0205e98 <commands+0x390>
ffffffffc0200ad0:	ec8ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200ad4:	684c                	ld	a1,144(s0)
ffffffffc0200ad6:	00005517          	auipc	a0,0x5
ffffffffc0200ada:	3da50513          	addi	a0,a0,986 # ffffffffc0205eb0 <commands+0x3a8>
ffffffffc0200ade:	ebaff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200ae2:	6c4c                	ld	a1,152(s0)
ffffffffc0200ae4:	00005517          	auipc	a0,0x5
ffffffffc0200ae8:	3e450513          	addi	a0,a0,996 # ffffffffc0205ec8 <commands+0x3c0>
ffffffffc0200aec:	eacff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200af0:	704c                	ld	a1,160(s0)
ffffffffc0200af2:	00005517          	auipc	a0,0x5
ffffffffc0200af6:	3ee50513          	addi	a0,a0,1006 # ffffffffc0205ee0 <commands+0x3d8>
ffffffffc0200afa:	e9eff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200afe:	744c                	ld	a1,168(s0)
ffffffffc0200b00:	00005517          	auipc	a0,0x5
ffffffffc0200b04:	3f850513          	addi	a0,a0,1016 # ffffffffc0205ef8 <commands+0x3f0>
ffffffffc0200b08:	e90ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200b0c:	784c                	ld	a1,176(s0)
ffffffffc0200b0e:	00005517          	auipc	a0,0x5
ffffffffc0200b12:	40250513          	addi	a0,a0,1026 # ffffffffc0205f10 <commands+0x408>
ffffffffc0200b16:	e82ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200b1a:	7c4c                	ld	a1,184(s0)
ffffffffc0200b1c:	00005517          	auipc	a0,0x5
ffffffffc0200b20:	40c50513          	addi	a0,a0,1036 # ffffffffc0205f28 <commands+0x420>
ffffffffc0200b24:	e74ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200b28:	606c                	ld	a1,192(s0)
ffffffffc0200b2a:	00005517          	auipc	a0,0x5
ffffffffc0200b2e:	41650513          	addi	a0,a0,1046 # ffffffffc0205f40 <commands+0x438>
ffffffffc0200b32:	e66ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200b36:	646c                	ld	a1,200(s0)
ffffffffc0200b38:	00005517          	auipc	a0,0x5
ffffffffc0200b3c:	42050513          	addi	a0,a0,1056 # ffffffffc0205f58 <commands+0x450>
ffffffffc0200b40:	e58ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200b44:	686c                	ld	a1,208(s0)
ffffffffc0200b46:	00005517          	auipc	a0,0x5
ffffffffc0200b4a:	42a50513          	addi	a0,a0,1066 # ffffffffc0205f70 <commands+0x468>
ffffffffc0200b4e:	e4aff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200b52:	6c6c                	ld	a1,216(s0)
ffffffffc0200b54:	00005517          	auipc	a0,0x5
ffffffffc0200b58:	43450513          	addi	a0,a0,1076 # ffffffffc0205f88 <commands+0x480>
ffffffffc0200b5c:	e3cff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200b60:	706c                	ld	a1,224(s0)
ffffffffc0200b62:	00005517          	auipc	a0,0x5
ffffffffc0200b66:	43e50513          	addi	a0,a0,1086 # ffffffffc0205fa0 <commands+0x498>
ffffffffc0200b6a:	e2eff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200b6e:	746c                	ld	a1,232(s0)
ffffffffc0200b70:	00005517          	auipc	a0,0x5
ffffffffc0200b74:	44850513          	addi	a0,a0,1096 # ffffffffc0205fb8 <commands+0x4b0>
ffffffffc0200b78:	e20ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200b7c:	786c                	ld	a1,240(s0)
ffffffffc0200b7e:	00005517          	auipc	a0,0x5
ffffffffc0200b82:	45250513          	addi	a0,a0,1106 # ffffffffc0205fd0 <commands+0x4c8>
ffffffffc0200b86:	e12ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b8a:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200b8c:	6402                	ld	s0,0(sp)
ffffffffc0200b8e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b90:	00005517          	auipc	a0,0x5
ffffffffc0200b94:	45850513          	addi	a0,a0,1112 # ffffffffc0205fe8 <commands+0x4e0>
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
ffffffffc0200ba6:	00005517          	auipc	a0,0x5
ffffffffc0200baa:	45a50513          	addi	a0,a0,1114 # ffffffffc0206000 <commands+0x4f8>
{
ffffffffc0200bae:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200bb0:	de8ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200bb4:	8522                	mv	a0,s0
ffffffffc0200bb6:	e1bff0ef          	jal	ra,ffffffffc02009d0 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200bba:	10043583          	ld	a1,256(s0)
ffffffffc0200bbe:	00005517          	auipc	a0,0x5
ffffffffc0200bc2:	45a50513          	addi	a0,a0,1114 # ffffffffc0206018 <commands+0x510>
ffffffffc0200bc6:	dd2ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200bca:	10843583          	ld	a1,264(s0)
ffffffffc0200bce:	00005517          	auipc	a0,0x5
ffffffffc0200bd2:	46250513          	addi	a0,a0,1122 # ffffffffc0206030 <commands+0x528>
ffffffffc0200bd6:	dc2ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200bda:	11043583          	ld	a1,272(s0)
ffffffffc0200bde:	00005517          	auipc	a0,0x5
ffffffffc0200be2:	46a50513          	addi	a0,a0,1130 # ffffffffc0206048 <commands+0x540>
ffffffffc0200be6:	db2ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bea:	11843583          	ld	a1,280(s0)
}
ffffffffc0200bee:	6402                	ld	s0,0(sp)
ffffffffc0200bf0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bf2:	00005517          	auipc	a0,0x5
ffffffffc0200bf6:	46650513          	addi	a0,a0,1126 # ffffffffc0206058 <commands+0x550>
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
ffffffffc0200c0e:	00005717          	auipc	a4,0x5
ffffffffc0200c12:	55270713          	addi	a4,a4,1362 # ffffffffc0206160 <commands+0x658>
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
ffffffffc0200c20:	00005517          	auipc	a0,0x5
ffffffffc0200c24:	4b050513          	addi	a0,a0,1200 # ffffffffc02060d0 <commands+0x5c8>
ffffffffc0200c28:	d70ff06f          	j	ffffffffc0200198 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200c2c:	00005517          	auipc	a0,0x5
ffffffffc0200c30:	48450513          	addi	a0,a0,1156 # ffffffffc02060b0 <commands+0x5a8>
ffffffffc0200c34:	d64ff06f          	j	ffffffffc0200198 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200c38:	00005517          	auipc	a0,0x5
ffffffffc0200c3c:	43850513          	addi	a0,a0,1080 # ffffffffc0206070 <commands+0x568>
ffffffffc0200c40:	d58ff06f          	j	ffffffffc0200198 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200c44:	00005517          	auipc	a0,0x5
ffffffffc0200c48:	44c50513          	addi	a0,a0,1100 # ffffffffc0206090 <commands+0x588>
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
ffffffffc0200c7c:	e525                	bnez	a0,ffffffffc0200ce4 <interrupt_handler+0xe4>
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
ffffffffc0200c86:	00005517          	auipc	a0,0x5
ffffffffc0200c8a:	4ba50513          	addi	a0,a0,1210 # ffffffffc0206140 <commands+0x638>
ffffffffc0200c8e:	d0aff06f          	j	ffffffffc0200198 <cprintf>
        print_trapframe(tf);
ffffffffc0200c92:	b731                	j	ffffffffc0200b9e <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200c94:	06400593          	li	a1,100
ffffffffc0200c98:	00005517          	auipc	a0,0x5
ffffffffc0200c9c:	45850513          	addi	a0,a0,1112 # ffffffffc02060f0 <commands+0x5e8>
ffffffffc0200ca0:	cf8ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    if (num >= 50) {
ffffffffc0200ca4:	000d2717          	auipc	a4,0xd2
ffffffffc0200ca8:	adc70713          	addi	a4,a4,-1316 # ffffffffc02d2780 <num>
ffffffffc0200cac:	631c                	ld	a5,0(a4)
ffffffffc0200cae:	03100693          	li	a3,49
ffffffffc0200cb2:	02f6ee63          	bltu	a3,a5,ffffffffc0200cee <interrupt_handler+0xee>
            num++; // 打印次数加一
ffffffffc0200cb6:	0785                	addi	a5,a5,1
ffffffffc0200cb8:	e31c                	sd	a5,0(a4)
            if (num == 30) {
ffffffffc0200cba:	4779                	li	a4,30
ffffffffc0200cbc:	00e79863          	bne	a5,a4,ffffffffc0200ccc <interrupt_handler+0xcc>
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200cc0:	4501                	li	a0,0
ffffffffc0200cc2:	4581                	li	a1,0
ffffffffc0200cc4:	4601                	li	a2,0
ffffffffc0200cc6:	48a1                	li	a7,8
ffffffffc0200cc8:	00000073          	ecall
            if(current != NULL && (tf->status & SSTATUS_SPP) == 0) {
ffffffffc0200ccc:	000d2517          	auipc	a0,0xd2
ffffffffc0200cd0:	af453503          	ld	a0,-1292(a0) # ffffffffc02d27c0 <current>
ffffffffc0200cd4:	d54d                	beqz	a0,ffffffffc0200c7e <interrupt_handler+0x7e>
ffffffffc0200cd6:	10043783          	ld	a5,256(s0)
ffffffffc0200cda:	1007f793          	andi	a5,a5,256
ffffffffc0200cde:	e399                	bnez	a5,ffffffffc0200ce4 <interrupt_handler+0xe4>
                current->need_resched = 1;
ffffffffc0200ce0:	4785                	li	a5,1
ffffffffc0200ce2:	ed1c                	sd	a5,24(a0)
}
ffffffffc0200ce4:	6402                	ld	s0,0(sp)
ffffffffc0200ce6:	60a2                	ld	ra,8(sp)
ffffffffc0200ce8:	0141                	addi	sp,sp,16
            sched_class_proc_tick(current);
ffffffffc0200cea:	3fa0406f          	j	ffffffffc02050e4 <sched_class_proc_tick>
        cprintf("End of Test.\n");
ffffffffc0200cee:	00005517          	auipc	a0,0x5
ffffffffc0200cf2:	41250513          	addi	a0,a0,1042 # ffffffffc0206100 <commands+0x5f8>
ffffffffc0200cf6:	ca2ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
        panic("EOT: kernel seems ok.");
ffffffffc0200cfa:	00005617          	auipc	a2,0x5
ffffffffc0200cfe:	41660613          	addi	a2,a2,1046 # ffffffffc0206110 <commands+0x608>
ffffffffc0200d02:	02200593          	li	a1,34
ffffffffc0200d06:	00005517          	auipc	a0,0x5
ffffffffc0200d0a:	42250513          	addi	a0,a0,1058 # ffffffffc0206128 <commands+0x620>
ffffffffc0200d0e:	f84ff0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0200d12 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf, uintptr_t kstacktop);
void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
ffffffffc0200d12:	11853783          	ld	a5,280(a0)
{
ffffffffc0200d16:	1141                	addi	sp,sp,-16
ffffffffc0200d18:	e022                	sd	s0,0(sp)
ffffffffc0200d1a:	e406                	sd	ra,8(sp)
ffffffffc0200d1c:	473d                	li	a4,15
ffffffffc0200d1e:	842a                	mv	s0,a0
ffffffffc0200d20:	0af76b63          	bltu	a4,a5,ffffffffc0200dd6 <exception_handler+0xc4>
ffffffffc0200d24:	00005717          	auipc	a4,0x5
ffffffffc0200d28:	5e470713          	addi	a4,a4,1508 # ffffffffc0206308 <commands+0x800>
ffffffffc0200d2c:	078a                	slli	a5,a5,0x2
ffffffffc0200d2e:	97ba                	add	a5,a5,a4
ffffffffc0200d30:	439c                	lw	a5,0(a5)
ffffffffc0200d32:	97ba                	add	a5,a5,a4
ffffffffc0200d34:	8782                	jr	a5
        // cprintf("Environment call from U-mode\n");
        tf->epc += 4;
        syscall();
        break;
    case CAUSE_SUPERVISOR_ECALL:
        cprintf("Environment call from S-mode\n");
ffffffffc0200d36:	00005517          	auipc	a0,0x5
ffffffffc0200d3a:	52a50513          	addi	a0,a0,1322 # ffffffffc0206260 <commands+0x758>
ffffffffc0200d3e:	c5aff0ef          	jal	ra,ffffffffc0200198 <cprintf>
        tf->epc += 4;
ffffffffc0200d42:	10843783          	ld	a5,264(s0)
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200d46:	60a2                	ld	ra,8(sp)
        tf->epc += 4;
ffffffffc0200d48:	0791                	addi	a5,a5,4
ffffffffc0200d4a:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200d4e:	6402                	ld	s0,0(sp)
ffffffffc0200d50:	0141                	addi	sp,sp,16
        syscall();
ffffffffc0200d52:	5fc0406f          	j	ffffffffc020534e <syscall>
        cprintf("Environment call from H-mode\n");
ffffffffc0200d56:	00005517          	auipc	a0,0x5
ffffffffc0200d5a:	52a50513          	addi	a0,a0,1322 # ffffffffc0206280 <commands+0x778>
}
ffffffffc0200d5e:	6402                	ld	s0,0(sp)
ffffffffc0200d60:	60a2                	ld	ra,8(sp)
ffffffffc0200d62:	0141                	addi	sp,sp,16
        cprintf("Instruction access fault\n");
ffffffffc0200d64:	c34ff06f          	j	ffffffffc0200198 <cprintf>
        cprintf("Environment call from M-mode\n");
ffffffffc0200d68:	00005517          	auipc	a0,0x5
ffffffffc0200d6c:	53850513          	addi	a0,a0,1336 # ffffffffc02062a0 <commands+0x798>
ffffffffc0200d70:	b7fd                	j	ffffffffc0200d5e <exception_handler+0x4c>
        cprintf("Instruction page fault\n");
ffffffffc0200d72:	00005517          	auipc	a0,0x5
ffffffffc0200d76:	54e50513          	addi	a0,a0,1358 # ffffffffc02062c0 <commands+0x7b8>
ffffffffc0200d7a:	b7d5                	j	ffffffffc0200d5e <exception_handler+0x4c>
        cprintf("Load page fault\n");
ffffffffc0200d7c:	00005517          	auipc	a0,0x5
ffffffffc0200d80:	55c50513          	addi	a0,a0,1372 # ffffffffc02062d8 <commands+0x7d0>
ffffffffc0200d84:	bfe9                	j	ffffffffc0200d5e <exception_handler+0x4c>
        cprintf("Store/AMO page fault\n");
ffffffffc0200d86:	00005517          	auipc	a0,0x5
ffffffffc0200d8a:	56a50513          	addi	a0,a0,1386 # ffffffffc02062f0 <commands+0x7e8>
ffffffffc0200d8e:	bfc1                	j	ffffffffc0200d5e <exception_handler+0x4c>
        cprintf("Instruction address misaligned\n");
ffffffffc0200d90:	00005517          	auipc	a0,0x5
ffffffffc0200d94:	40050513          	addi	a0,a0,1024 # ffffffffc0206190 <commands+0x688>
ffffffffc0200d98:	b7d9                	j	ffffffffc0200d5e <exception_handler+0x4c>
        cprintf("Instruction access fault\n");
ffffffffc0200d9a:	00005517          	auipc	a0,0x5
ffffffffc0200d9e:	41650513          	addi	a0,a0,1046 # ffffffffc02061b0 <commands+0x6a8>
ffffffffc0200da2:	bf75                	j	ffffffffc0200d5e <exception_handler+0x4c>
        cprintf("Illegal instruction\n");
ffffffffc0200da4:	00005517          	auipc	a0,0x5
ffffffffc0200da8:	42c50513          	addi	a0,a0,1068 # ffffffffc02061d0 <commands+0x6c8>
ffffffffc0200dac:	bf4d                	j	ffffffffc0200d5e <exception_handler+0x4c>
        cprintf("Breakpoint\n");
ffffffffc0200dae:	00005517          	auipc	a0,0x5
ffffffffc0200db2:	43a50513          	addi	a0,a0,1082 # ffffffffc02061e8 <commands+0x6e0>
ffffffffc0200db6:	b765                	j	ffffffffc0200d5e <exception_handler+0x4c>
        cprintf("Load address misaligned\n");
ffffffffc0200db8:	00005517          	auipc	a0,0x5
ffffffffc0200dbc:	44050513          	addi	a0,a0,1088 # ffffffffc02061f8 <commands+0x6f0>
ffffffffc0200dc0:	bf79                	j	ffffffffc0200d5e <exception_handler+0x4c>
        cprintf("Load access fault\n");
ffffffffc0200dc2:	00005517          	auipc	a0,0x5
ffffffffc0200dc6:	45650513          	addi	a0,a0,1110 # ffffffffc0206218 <commands+0x710>
ffffffffc0200dca:	bf51                	j	ffffffffc0200d5e <exception_handler+0x4c>
        cprintf("Store/AMO access fault\n");
ffffffffc0200dcc:	00005517          	auipc	a0,0x5
ffffffffc0200dd0:	47c50513          	addi	a0,a0,1148 # ffffffffc0206248 <commands+0x740>
ffffffffc0200dd4:	b769                	j	ffffffffc0200d5e <exception_handler+0x4c>
        print_trapframe(tf);
ffffffffc0200dd6:	8522                	mv	a0,s0
}
ffffffffc0200dd8:	6402                	ld	s0,0(sp)
ffffffffc0200dda:	60a2                	ld	ra,8(sp)
ffffffffc0200ddc:	0141                	addi	sp,sp,16
        print_trapframe(tf);
ffffffffc0200dde:	b3c1                	j	ffffffffc0200b9e <print_trapframe>
        panic("AMO address misaligned\n");
ffffffffc0200de0:	00005617          	auipc	a2,0x5
ffffffffc0200de4:	45060613          	addi	a2,a2,1104 # ffffffffc0206230 <commands+0x728>
ffffffffc0200de8:	0d100593          	li	a1,209
ffffffffc0200dec:	00005517          	auipc	a0,0x5
ffffffffc0200df0:	33c50513          	addi	a0,a0,828 # ffffffffc0206128 <commands+0x620>
ffffffffc0200df4:	e9eff0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0200df8 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf)
{
ffffffffc0200df8:	1101                	addi	sp,sp,-32
ffffffffc0200dfa:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
    //    cputs("some trap");
    if (current == NULL)
ffffffffc0200dfc:	000d2417          	auipc	s0,0xd2
ffffffffc0200e00:	9c440413          	addi	s0,s0,-1596 # ffffffffc02d27c0 <current>
ffffffffc0200e04:	6018                	ld	a4,0(s0)
{
ffffffffc0200e06:	ec06                	sd	ra,24(sp)
ffffffffc0200e08:	e426                	sd	s1,8(sp)
ffffffffc0200e0a:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0)
ffffffffc0200e0c:	11853683          	ld	a3,280(a0)
    if (current == NULL)
ffffffffc0200e10:	cf1d                	beqz	a4,ffffffffc0200e4e <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200e12:	10053483          	ld	s1,256(a0)
    {
        trap_dispatch(tf);
    }
    else
    {
        struct trapframe *otf = current->tf;
ffffffffc0200e16:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200e1a:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200e1c:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0)
ffffffffc0200e20:	0206c463          	bltz	a3,ffffffffc0200e48 <trap+0x50>
        exception_handler(tf);
ffffffffc0200e24:	eefff0ef          	jal	ra,ffffffffc0200d12 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200e28:	601c                	ld	a5,0(s0)
ffffffffc0200e2a:	0b27b023          	sd	s2,160(a5) # 400a0 <_binary_obj___user_matrix_out_size+0x33978>
        if (!in_kernel)
ffffffffc0200e2e:	e499                	bnez	s1,ffffffffc0200e3c <trap+0x44>
        {
            if (current->flags & PF_EXITING)
ffffffffc0200e30:	0b07a703          	lw	a4,176(a5)
ffffffffc0200e34:	8b05                	andi	a4,a4,1
ffffffffc0200e36:	e329                	bnez	a4,ffffffffc0200e78 <trap+0x80>
            {
                do_exit(-E_KILLED);
            }
            if (current->need_resched)
ffffffffc0200e38:	6f9c                	ld	a5,24(a5)
ffffffffc0200e3a:	eb85                	bnez	a5,ffffffffc0200e6a <trap+0x72>
            {
                schedule();
            }
        }
    }
}
ffffffffc0200e3c:	60e2                	ld	ra,24(sp)
ffffffffc0200e3e:	6442                	ld	s0,16(sp)
ffffffffc0200e40:	64a2                	ld	s1,8(sp)
ffffffffc0200e42:	6902                	ld	s2,0(sp)
ffffffffc0200e44:	6105                	addi	sp,sp,32
ffffffffc0200e46:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200e48:	db9ff0ef          	jal	ra,ffffffffc0200c00 <interrupt_handler>
ffffffffc0200e4c:	bff1                	j	ffffffffc0200e28 <trap+0x30>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200e4e:	0006c863          	bltz	a3,ffffffffc0200e5e <trap+0x66>
}
ffffffffc0200e52:	6442                	ld	s0,16(sp)
ffffffffc0200e54:	60e2                	ld	ra,24(sp)
ffffffffc0200e56:	64a2                	ld	s1,8(sp)
ffffffffc0200e58:	6902                	ld	s2,0(sp)
ffffffffc0200e5a:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200e5c:	bd5d                	j	ffffffffc0200d12 <exception_handler>
}
ffffffffc0200e5e:	6442                	ld	s0,16(sp)
ffffffffc0200e60:	60e2                	ld	ra,24(sp)
ffffffffc0200e62:	64a2                	ld	s1,8(sp)
ffffffffc0200e64:	6902                	ld	s2,0(sp)
ffffffffc0200e66:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200e68:	bb61                	j	ffffffffc0200c00 <interrupt_handler>
}
ffffffffc0200e6a:	6442                	ld	s0,16(sp)
ffffffffc0200e6c:	60e2                	ld	ra,24(sp)
ffffffffc0200e6e:	64a2                	ld	s1,8(sp)
ffffffffc0200e70:	6902                	ld	s2,0(sp)
ffffffffc0200e72:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200e74:	39c0406f          	j	ffffffffc0205210 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200e78:	555d                	li	a0,-9
ffffffffc0200e7a:	480030ef          	jal	ra,ffffffffc02042fa <do_exit>
            if (current->need_resched)
ffffffffc0200e7e:	601c                	ld	a5,0(s0)
ffffffffc0200e80:	bf65                	j	ffffffffc0200e38 <trap+0x40>
	...

ffffffffc0200e84 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200e84:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200e88:	00011463          	bnez	sp,ffffffffc0200e90 <__alltraps+0xc>
ffffffffc0200e8c:	14002173          	csrr	sp,sscratch
ffffffffc0200e90:	712d                	addi	sp,sp,-288
ffffffffc0200e92:	e002                	sd	zero,0(sp)
ffffffffc0200e94:	e406                	sd	ra,8(sp)
ffffffffc0200e96:	ec0e                	sd	gp,24(sp)
ffffffffc0200e98:	f012                	sd	tp,32(sp)
ffffffffc0200e9a:	f416                	sd	t0,40(sp)
ffffffffc0200e9c:	f81a                	sd	t1,48(sp)
ffffffffc0200e9e:	fc1e                	sd	t2,56(sp)
ffffffffc0200ea0:	e0a2                	sd	s0,64(sp)
ffffffffc0200ea2:	e4a6                	sd	s1,72(sp)
ffffffffc0200ea4:	e8aa                	sd	a0,80(sp)
ffffffffc0200ea6:	ecae                	sd	a1,88(sp)
ffffffffc0200ea8:	f0b2                	sd	a2,96(sp)
ffffffffc0200eaa:	f4b6                	sd	a3,104(sp)
ffffffffc0200eac:	f8ba                	sd	a4,112(sp)
ffffffffc0200eae:	fcbe                	sd	a5,120(sp)
ffffffffc0200eb0:	e142                	sd	a6,128(sp)
ffffffffc0200eb2:	e546                	sd	a7,136(sp)
ffffffffc0200eb4:	e94a                	sd	s2,144(sp)
ffffffffc0200eb6:	ed4e                	sd	s3,152(sp)
ffffffffc0200eb8:	f152                	sd	s4,160(sp)
ffffffffc0200eba:	f556                	sd	s5,168(sp)
ffffffffc0200ebc:	f95a                	sd	s6,176(sp)
ffffffffc0200ebe:	fd5e                	sd	s7,184(sp)
ffffffffc0200ec0:	e1e2                	sd	s8,192(sp)
ffffffffc0200ec2:	e5e6                	sd	s9,200(sp)
ffffffffc0200ec4:	e9ea                	sd	s10,208(sp)
ffffffffc0200ec6:	edee                	sd	s11,216(sp)
ffffffffc0200ec8:	f1f2                	sd	t3,224(sp)
ffffffffc0200eca:	f5f6                	sd	t4,232(sp)
ffffffffc0200ecc:	f9fa                	sd	t5,240(sp)
ffffffffc0200ece:	fdfe                	sd	t6,248(sp)
ffffffffc0200ed0:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200ed4:	100024f3          	csrr	s1,sstatus
ffffffffc0200ed8:	14102973          	csrr	s2,sepc
ffffffffc0200edc:	143029f3          	csrr	s3,stval
ffffffffc0200ee0:	14202a73          	csrr	s4,scause
ffffffffc0200ee4:	e822                	sd	s0,16(sp)
ffffffffc0200ee6:	e226                	sd	s1,256(sp)
ffffffffc0200ee8:	e64a                	sd	s2,264(sp)
ffffffffc0200eea:	ea4e                	sd	s3,272(sp)
ffffffffc0200eec:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200eee:	850a                	mv	a0,sp
    jal trap
ffffffffc0200ef0:	f09ff0ef          	jal	ra,ffffffffc0200df8 <trap>

ffffffffc0200ef4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200ef4:	6492                	ld	s1,256(sp)
ffffffffc0200ef6:	6932                	ld	s2,264(sp)
ffffffffc0200ef8:	1004f413          	andi	s0,s1,256
ffffffffc0200efc:	e401                	bnez	s0,ffffffffc0200f04 <__trapret+0x10>
ffffffffc0200efe:	1200                	addi	s0,sp,288
ffffffffc0200f00:	14041073          	csrw	sscratch,s0
ffffffffc0200f04:	10049073          	csrw	sstatus,s1
ffffffffc0200f08:	14191073          	csrw	sepc,s2
ffffffffc0200f0c:	60a2                	ld	ra,8(sp)
ffffffffc0200f0e:	61e2                	ld	gp,24(sp)
ffffffffc0200f10:	7202                	ld	tp,32(sp)
ffffffffc0200f12:	72a2                	ld	t0,40(sp)
ffffffffc0200f14:	7342                	ld	t1,48(sp)
ffffffffc0200f16:	73e2                	ld	t2,56(sp)
ffffffffc0200f18:	6406                	ld	s0,64(sp)
ffffffffc0200f1a:	64a6                	ld	s1,72(sp)
ffffffffc0200f1c:	6546                	ld	a0,80(sp)
ffffffffc0200f1e:	65e6                	ld	a1,88(sp)
ffffffffc0200f20:	7606                	ld	a2,96(sp)
ffffffffc0200f22:	76a6                	ld	a3,104(sp)
ffffffffc0200f24:	7746                	ld	a4,112(sp)
ffffffffc0200f26:	77e6                	ld	a5,120(sp)
ffffffffc0200f28:	680a                	ld	a6,128(sp)
ffffffffc0200f2a:	68aa                	ld	a7,136(sp)
ffffffffc0200f2c:	694a                	ld	s2,144(sp)
ffffffffc0200f2e:	69ea                	ld	s3,152(sp)
ffffffffc0200f30:	7a0a                	ld	s4,160(sp)
ffffffffc0200f32:	7aaa                	ld	s5,168(sp)
ffffffffc0200f34:	7b4a                	ld	s6,176(sp)
ffffffffc0200f36:	7bea                	ld	s7,184(sp)
ffffffffc0200f38:	6c0e                	ld	s8,192(sp)
ffffffffc0200f3a:	6cae                	ld	s9,200(sp)
ffffffffc0200f3c:	6d4e                	ld	s10,208(sp)
ffffffffc0200f3e:	6dee                	ld	s11,216(sp)
ffffffffc0200f40:	7e0e                	ld	t3,224(sp)
ffffffffc0200f42:	7eae                	ld	t4,232(sp)
ffffffffc0200f44:	7f4e                	ld	t5,240(sp)
ffffffffc0200f46:	7fee                	ld	t6,248(sp)
ffffffffc0200f48:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200f4a:	10200073          	sret

ffffffffc0200f4e <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200f4e:	812a                	mv	sp,a0
ffffffffc0200f50:	b755                	j	ffffffffc0200ef4 <__trapret>

ffffffffc0200f52 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200f52:	000cd797          	auipc	a5,0xcd
ffffffffc0200f56:	7b678793          	addi	a5,a5,1974 # ffffffffc02ce708 <free_area>
ffffffffc0200f5a:	e79c                	sd	a5,8(a5)
ffffffffc0200f5c:	e39c                	sd	a5,0(a5)

static void
default_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200f5e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200f62:	8082                	ret

ffffffffc0200f64 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc0200f64:	000cd517          	auipc	a0,0xcd
ffffffffc0200f68:	7b456503          	lwu	a0,1972(a0) # ffffffffc02ce718 <free_area+0x10>
ffffffffc0200f6c:	8082                	ret

ffffffffc0200f6e <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
ffffffffc0200f6e:	715d                	addi	sp,sp,-80
ffffffffc0200f70:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200f72:	000cd417          	auipc	s0,0xcd
ffffffffc0200f76:	79640413          	addi	s0,s0,1942 # ffffffffc02ce708 <free_area>
ffffffffc0200f7a:	641c                	ld	a5,8(s0)
ffffffffc0200f7c:	e486                	sd	ra,72(sp)
ffffffffc0200f7e:	fc26                	sd	s1,56(sp)
ffffffffc0200f80:	f84a                	sd	s2,48(sp)
ffffffffc0200f82:	f44e                	sd	s3,40(sp)
ffffffffc0200f84:	f052                	sd	s4,32(sp)
ffffffffc0200f86:	ec56                	sd	s5,24(sp)
ffffffffc0200f88:	e85a                	sd	s6,16(sp)
ffffffffc0200f8a:	e45e                	sd	s7,8(sp)
ffffffffc0200f8c:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0200f8e:	2a878d63          	beq	a5,s0,ffffffffc0201248 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0200f92:	4481                	li	s1,0
ffffffffc0200f94:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200f96:	ff07b703          	ld	a4,-16(a5)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200f9a:	8b09                	andi	a4,a4,2
ffffffffc0200f9c:	2a070a63          	beqz	a4,ffffffffc0201250 <default_check+0x2e2>
        count++, total += p->property;
ffffffffc0200fa0:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200fa4:	679c                	ld	a5,8(a5)
ffffffffc0200fa6:	2905                	addiw	s2,s2,1
ffffffffc0200fa8:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0200faa:	fe8796e3          	bne	a5,s0,ffffffffc0200f96 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200fae:	89a6                	mv	s3,s1
ffffffffc0200fb0:	6df000ef          	jal	ra,ffffffffc0201e8e <nr_free_pages>
ffffffffc0200fb4:	6f351e63          	bne	a0,s3,ffffffffc02016b0 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200fb8:	4505                	li	a0,1
ffffffffc0200fba:	657000ef          	jal	ra,ffffffffc0201e10 <alloc_pages>
ffffffffc0200fbe:	8aaa                	mv	s5,a0
ffffffffc0200fc0:	42050863          	beqz	a0,ffffffffc02013f0 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200fc4:	4505                	li	a0,1
ffffffffc0200fc6:	64b000ef          	jal	ra,ffffffffc0201e10 <alloc_pages>
ffffffffc0200fca:	89aa                	mv	s3,a0
ffffffffc0200fcc:	70050263          	beqz	a0,ffffffffc02016d0 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fd0:	4505                	li	a0,1
ffffffffc0200fd2:	63f000ef          	jal	ra,ffffffffc0201e10 <alloc_pages>
ffffffffc0200fd6:	8a2a                	mv	s4,a0
ffffffffc0200fd8:	48050c63          	beqz	a0,ffffffffc0201470 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200fdc:	293a8a63          	beq	s5,s3,ffffffffc0201270 <default_check+0x302>
ffffffffc0200fe0:	28aa8863          	beq	s5,a0,ffffffffc0201270 <default_check+0x302>
ffffffffc0200fe4:	28a98663          	beq	s3,a0,ffffffffc0201270 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200fe8:	000aa783          	lw	a5,0(s5)
ffffffffc0200fec:	2a079263          	bnez	a5,ffffffffc0201290 <default_check+0x322>
ffffffffc0200ff0:	0009a783          	lw	a5,0(s3)
ffffffffc0200ff4:	28079e63          	bnez	a5,ffffffffc0201290 <default_check+0x322>
ffffffffc0200ff8:	411c                	lw	a5,0(a0)
ffffffffc0200ffa:	28079b63          	bnez	a5,ffffffffc0201290 <default_check+0x322>
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page)
{
    return page - pages + nbase;
ffffffffc0200ffe:	000d1797          	auipc	a5,0xd1
ffffffffc0201002:	7aa7b783          	ld	a5,1962(a5) # ffffffffc02d27a8 <pages>
ffffffffc0201006:	40fa8733          	sub	a4,s5,a5
ffffffffc020100a:	00007617          	auipc	a2,0x7
ffffffffc020100e:	1b663603          	ld	a2,438(a2) # ffffffffc02081c0 <nbase>
ffffffffc0201012:	8719                	srai	a4,a4,0x6
ffffffffc0201014:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201016:	000d1697          	auipc	a3,0xd1
ffffffffc020101a:	78a6b683          	ld	a3,1930(a3) # ffffffffc02d27a0 <npage>
ffffffffc020101e:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page)
{
    return page2ppn(page) << PGSHIFT;
ffffffffc0201020:	0732                	slli	a4,a4,0xc
ffffffffc0201022:	28d77763          	bgeu	a4,a3,ffffffffc02012b0 <default_check+0x342>
    return page - pages + nbase;
ffffffffc0201026:	40f98733          	sub	a4,s3,a5
ffffffffc020102a:	8719                	srai	a4,a4,0x6
ffffffffc020102c:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020102e:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201030:	4cd77063          	bgeu	a4,a3,ffffffffc02014f0 <default_check+0x582>
    return page - pages + nbase;
ffffffffc0201034:	40f507b3          	sub	a5,a0,a5
ffffffffc0201038:	8799                	srai	a5,a5,0x6
ffffffffc020103a:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020103c:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020103e:	30d7f963          	bgeu	a5,a3,ffffffffc0201350 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0201042:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201044:	00043c03          	ld	s8,0(s0)
ffffffffc0201048:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc020104c:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0201050:	e400                	sd	s0,8(s0)
ffffffffc0201052:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0201054:	000cd797          	auipc	a5,0xcd
ffffffffc0201058:	6c07a223          	sw	zero,1732(a5) # ffffffffc02ce718 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc020105c:	5b5000ef          	jal	ra,ffffffffc0201e10 <alloc_pages>
ffffffffc0201060:	2c051863          	bnez	a0,ffffffffc0201330 <default_check+0x3c2>
    free_page(p0);
ffffffffc0201064:	4585                	li	a1,1
ffffffffc0201066:	8556                	mv	a0,s5
ffffffffc0201068:	5e7000ef          	jal	ra,ffffffffc0201e4e <free_pages>
    free_page(p1);
ffffffffc020106c:	4585                	li	a1,1
ffffffffc020106e:	854e                	mv	a0,s3
ffffffffc0201070:	5df000ef          	jal	ra,ffffffffc0201e4e <free_pages>
    free_page(p2);
ffffffffc0201074:	4585                	li	a1,1
ffffffffc0201076:	8552                	mv	a0,s4
ffffffffc0201078:	5d7000ef          	jal	ra,ffffffffc0201e4e <free_pages>
    assert(nr_free == 3);
ffffffffc020107c:	4818                	lw	a4,16(s0)
ffffffffc020107e:	478d                	li	a5,3
ffffffffc0201080:	28f71863          	bne	a4,a5,ffffffffc0201310 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201084:	4505                	li	a0,1
ffffffffc0201086:	58b000ef          	jal	ra,ffffffffc0201e10 <alloc_pages>
ffffffffc020108a:	89aa                	mv	s3,a0
ffffffffc020108c:	26050263          	beqz	a0,ffffffffc02012f0 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201090:	4505                	li	a0,1
ffffffffc0201092:	57f000ef          	jal	ra,ffffffffc0201e10 <alloc_pages>
ffffffffc0201096:	8aaa                	mv	s5,a0
ffffffffc0201098:	3a050c63          	beqz	a0,ffffffffc0201450 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020109c:	4505                	li	a0,1
ffffffffc020109e:	573000ef          	jal	ra,ffffffffc0201e10 <alloc_pages>
ffffffffc02010a2:	8a2a                	mv	s4,a0
ffffffffc02010a4:	38050663          	beqz	a0,ffffffffc0201430 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc02010a8:	4505                	li	a0,1
ffffffffc02010aa:	567000ef          	jal	ra,ffffffffc0201e10 <alloc_pages>
ffffffffc02010ae:	36051163          	bnez	a0,ffffffffc0201410 <default_check+0x4a2>
    free_page(p0);
ffffffffc02010b2:	4585                	li	a1,1
ffffffffc02010b4:	854e                	mv	a0,s3
ffffffffc02010b6:	599000ef          	jal	ra,ffffffffc0201e4e <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02010ba:	641c                	ld	a5,8(s0)
ffffffffc02010bc:	20878a63          	beq	a5,s0,ffffffffc02012d0 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc02010c0:	4505                	li	a0,1
ffffffffc02010c2:	54f000ef          	jal	ra,ffffffffc0201e10 <alloc_pages>
ffffffffc02010c6:	30a99563          	bne	s3,a0,ffffffffc02013d0 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc02010ca:	4505                	li	a0,1
ffffffffc02010cc:	545000ef          	jal	ra,ffffffffc0201e10 <alloc_pages>
ffffffffc02010d0:	2e051063          	bnez	a0,ffffffffc02013b0 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc02010d4:	481c                	lw	a5,16(s0)
ffffffffc02010d6:	2a079d63          	bnez	a5,ffffffffc0201390 <default_check+0x422>
    free_page(p);
ffffffffc02010da:	854e                	mv	a0,s3
ffffffffc02010dc:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02010de:	01843023          	sd	s8,0(s0)
ffffffffc02010e2:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc02010e6:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc02010ea:	565000ef          	jal	ra,ffffffffc0201e4e <free_pages>
    free_page(p1);
ffffffffc02010ee:	4585                	li	a1,1
ffffffffc02010f0:	8556                	mv	a0,s5
ffffffffc02010f2:	55d000ef          	jal	ra,ffffffffc0201e4e <free_pages>
    free_page(p2);
ffffffffc02010f6:	4585                	li	a1,1
ffffffffc02010f8:	8552                	mv	a0,s4
ffffffffc02010fa:	555000ef          	jal	ra,ffffffffc0201e4e <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02010fe:	4515                	li	a0,5
ffffffffc0201100:	511000ef          	jal	ra,ffffffffc0201e10 <alloc_pages>
ffffffffc0201104:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201106:	26050563          	beqz	a0,ffffffffc0201370 <default_check+0x402>
ffffffffc020110a:	651c                	ld	a5,8(a0)
ffffffffc020110c:	8385                	srli	a5,a5,0x1
ffffffffc020110e:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0201110:	54079063          	bnez	a5,ffffffffc0201650 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201114:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201116:	00043b03          	ld	s6,0(s0)
ffffffffc020111a:	00843a83          	ld	s5,8(s0)
ffffffffc020111e:	e000                	sd	s0,0(s0)
ffffffffc0201120:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0201122:	4ef000ef          	jal	ra,ffffffffc0201e10 <alloc_pages>
ffffffffc0201126:	50051563          	bnez	a0,ffffffffc0201630 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020112a:	08098a13          	addi	s4,s3,128
ffffffffc020112e:	8552                	mv	a0,s4
ffffffffc0201130:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201132:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0201136:	000cd797          	auipc	a5,0xcd
ffffffffc020113a:	5e07a123          	sw	zero,1506(a5) # ffffffffc02ce718 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc020113e:	511000ef          	jal	ra,ffffffffc0201e4e <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201142:	4511                	li	a0,4
ffffffffc0201144:	4cd000ef          	jal	ra,ffffffffc0201e10 <alloc_pages>
ffffffffc0201148:	4c051463          	bnez	a0,ffffffffc0201610 <default_check+0x6a2>
ffffffffc020114c:	0889b783          	ld	a5,136(s3)
ffffffffc0201150:	8385                	srli	a5,a5,0x1
ffffffffc0201152:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201154:	48078e63          	beqz	a5,ffffffffc02015f0 <default_check+0x682>
ffffffffc0201158:	0909a703          	lw	a4,144(s3)
ffffffffc020115c:	478d                	li	a5,3
ffffffffc020115e:	48f71963          	bne	a4,a5,ffffffffc02015f0 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201162:	450d                	li	a0,3
ffffffffc0201164:	4ad000ef          	jal	ra,ffffffffc0201e10 <alloc_pages>
ffffffffc0201168:	8c2a                	mv	s8,a0
ffffffffc020116a:	46050363          	beqz	a0,ffffffffc02015d0 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc020116e:	4505                	li	a0,1
ffffffffc0201170:	4a1000ef          	jal	ra,ffffffffc0201e10 <alloc_pages>
ffffffffc0201174:	42051e63          	bnez	a0,ffffffffc02015b0 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0201178:	418a1c63          	bne	s4,s8,ffffffffc0201590 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc020117c:	4585                	li	a1,1
ffffffffc020117e:	854e                	mv	a0,s3
ffffffffc0201180:	4cf000ef          	jal	ra,ffffffffc0201e4e <free_pages>
    free_pages(p1, 3);
ffffffffc0201184:	458d                	li	a1,3
ffffffffc0201186:	8552                	mv	a0,s4
ffffffffc0201188:	4c7000ef          	jal	ra,ffffffffc0201e4e <free_pages>
ffffffffc020118c:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201190:	04098c13          	addi	s8,s3,64
ffffffffc0201194:	8385                	srli	a5,a5,0x1
ffffffffc0201196:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201198:	3c078c63          	beqz	a5,ffffffffc0201570 <default_check+0x602>
ffffffffc020119c:	0109a703          	lw	a4,16(s3)
ffffffffc02011a0:	4785                	li	a5,1
ffffffffc02011a2:	3cf71763          	bne	a4,a5,ffffffffc0201570 <default_check+0x602>
ffffffffc02011a6:	008a3783          	ld	a5,8(s4)
ffffffffc02011aa:	8385                	srli	a5,a5,0x1
ffffffffc02011ac:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02011ae:	3a078163          	beqz	a5,ffffffffc0201550 <default_check+0x5e2>
ffffffffc02011b2:	010a2703          	lw	a4,16(s4)
ffffffffc02011b6:	478d                	li	a5,3
ffffffffc02011b8:	38f71c63          	bne	a4,a5,ffffffffc0201550 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02011bc:	4505                	li	a0,1
ffffffffc02011be:	453000ef          	jal	ra,ffffffffc0201e10 <alloc_pages>
ffffffffc02011c2:	36a99763          	bne	s3,a0,ffffffffc0201530 <default_check+0x5c2>
    free_page(p0);
ffffffffc02011c6:	4585                	li	a1,1
ffffffffc02011c8:	487000ef          	jal	ra,ffffffffc0201e4e <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02011cc:	4509                	li	a0,2
ffffffffc02011ce:	443000ef          	jal	ra,ffffffffc0201e10 <alloc_pages>
ffffffffc02011d2:	32aa1f63          	bne	s4,a0,ffffffffc0201510 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc02011d6:	4589                	li	a1,2
ffffffffc02011d8:	477000ef          	jal	ra,ffffffffc0201e4e <free_pages>
    free_page(p2);
ffffffffc02011dc:	4585                	li	a1,1
ffffffffc02011de:	8562                	mv	a0,s8
ffffffffc02011e0:	46f000ef          	jal	ra,ffffffffc0201e4e <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02011e4:	4515                	li	a0,5
ffffffffc02011e6:	42b000ef          	jal	ra,ffffffffc0201e10 <alloc_pages>
ffffffffc02011ea:	89aa                	mv	s3,a0
ffffffffc02011ec:	48050263          	beqz	a0,ffffffffc0201670 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc02011f0:	4505                	li	a0,1
ffffffffc02011f2:	41f000ef          	jal	ra,ffffffffc0201e10 <alloc_pages>
ffffffffc02011f6:	2c051d63          	bnez	a0,ffffffffc02014d0 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc02011fa:	481c                	lw	a5,16(s0)
ffffffffc02011fc:	2a079a63          	bnez	a5,ffffffffc02014b0 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201200:	4595                	li	a1,5
ffffffffc0201202:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0201204:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0201208:	01643023          	sd	s6,0(s0)
ffffffffc020120c:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0201210:	43f000ef          	jal	ra,ffffffffc0201e4e <free_pages>
    return listelm->next;
ffffffffc0201214:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0201216:	00878963          	beq	a5,s0,ffffffffc0201228 <default_check+0x2ba>
    {
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc020121a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020121e:	679c                	ld	a5,8(a5)
ffffffffc0201220:	397d                	addiw	s2,s2,-1
ffffffffc0201222:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0201224:	fe879be3          	bne	a5,s0,ffffffffc020121a <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc0201228:	26091463          	bnez	s2,ffffffffc0201490 <default_check+0x522>
    assert(total == 0);
ffffffffc020122c:	46049263          	bnez	s1,ffffffffc0201690 <default_check+0x722>
}
ffffffffc0201230:	60a6                	ld	ra,72(sp)
ffffffffc0201232:	6406                	ld	s0,64(sp)
ffffffffc0201234:	74e2                	ld	s1,56(sp)
ffffffffc0201236:	7942                	ld	s2,48(sp)
ffffffffc0201238:	79a2                	ld	s3,40(sp)
ffffffffc020123a:	7a02                	ld	s4,32(sp)
ffffffffc020123c:	6ae2                	ld	s5,24(sp)
ffffffffc020123e:	6b42                	ld	s6,16(sp)
ffffffffc0201240:	6ba2                	ld	s7,8(sp)
ffffffffc0201242:	6c02                	ld	s8,0(sp)
ffffffffc0201244:	6161                	addi	sp,sp,80
ffffffffc0201246:	8082                	ret
    while ((le = list_next(le)) != &free_list)
ffffffffc0201248:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020124a:	4481                	li	s1,0
ffffffffc020124c:	4901                	li	s2,0
ffffffffc020124e:	b38d                	j	ffffffffc0200fb0 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0201250:	00005697          	auipc	a3,0x5
ffffffffc0201254:	0f868693          	addi	a3,a3,248 # ffffffffc0206348 <commands+0x840>
ffffffffc0201258:	00005617          	auipc	a2,0x5
ffffffffc020125c:	10060613          	addi	a2,a2,256 # ffffffffc0206358 <commands+0x850>
ffffffffc0201260:	11000593          	li	a1,272
ffffffffc0201264:	00005517          	auipc	a0,0x5
ffffffffc0201268:	10c50513          	addi	a0,a0,268 # ffffffffc0206370 <commands+0x868>
ffffffffc020126c:	a26ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201270:	00005697          	auipc	a3,0x5
ffffffffc0201274:	19868693          	addi	a3,a3,408 # ffffffffc0206408 <commands+0x900>
ffffffffc0201278:	00005617          	auipc	a2,0x5
ffffffffc020127c:	0e060613          	addi	a2,a2,224 # ffffffffc0206358 <commands+0x850>
ffffffffc0201280:	0db00593          	li	a1,219
ffffffffc0201284:	00005517          	auipc	a0,0x5
ffffffffc0201288:	0ec50513          	addi	a0,a0,236 # ffffffffc0206370 <commands+0x868>
ffffffffc020128c:	a06ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201290:	00005697          	auipc	a3,0x5
ffffffffc0201294:	1a068693          	addi	a3,a3,416 # ffffffffc0206430 <commands+0x928>
ffffffffc0201298:	00005617          	auipc	a2,0x5
ffffffffc020129c:	0c060613          	addi	a2,a2,192 # ffffffffc0206358 <commands+0x850>
ffffffffc02012a0:	0dc00593          	li	a1,220
ffffffffc02012a4:	00005517          	auipc	a0,0x5
ffffffffc02012a8:	0cc50513          	addi	a0,a0,204 # ffffffffc0206370 <commands+0x868>
ffffffffc02012ac:	9e6ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02012b0:	00005697          	auipc	a3,0x5
ffffffffc02012b4:	1c068693          	addi	a3,a3,448 # ffffffffc0206470 <commands+0x968>
ffffffffc02012b8:	00005617          	auipc	a2,0x5
ffffffffc02012bc:	0a060613          	addi	a2,a2,160 # ffffffffc0206358 <commands+0x850>
ffffffffc02012c0:	0de00593          	li	a1,222
ffffffffc02012c4:	00005517          	auipc	a0,0x5
ffffffffc02012c8:	0ac50513          	addi	a0,a0,172 # ffffffffc0206370 <commands+0x868>
ffffffffc02012cc:	9c6ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(!list_empty(&free_list));
ffffffffc02012d0:	00005697          	auipc	a3,0x5
ffffffffc02012d4:	22868693          	addi	a3,a3,552 # ffffffffc02064f8 <commands+0x9f0>
ffffffffc02012d8:	00005617          	auipc	a2,0x5
ffffffffc02012dc:	08060613          	addi	a2,a2,128 # ffffffffc0206358 <commands+0x850>
ffffffffc02012e0:	0f700593          	li	a1,247
ffffffffc02012e4:	00005517          	auipc	a0,0x5
ffffffffc02012e8:	08c50513          	addi	a0,a0,140 # ffffffffc0206370 <commands+0x868>
ffffffffc02012ec:	9a6ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02012f0:	00005697          	auipc	a3,0x5
ffffffffc02012f4:	0b868693          	addi	a3,a3,184 # ffffffffc02063a8 <commands+0x8a0>
ffffffffc02012f8:	00005617          	auipc	a2,0x5
ffffffffc02012fc:	06060613          	addi	a2,a2,96 # ffffffffc0206358 <commands+0x850>
ffffffffc0201300:	0f000593          	li	a1,240
ffffffffc0201304:	00005517          	auipc	a0,0x5
ffffffffc0201308:	06c50513          	addi	a0,a0,108 # ffffffffc0206370 <commands+0x868>
ffffffffc020130c:	986ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(nr_free == 3);
ffffffffc0201310:	00005697          	auipc	a3,0x5
ffffffffc0201314:	1d868693          	addi	a3,a3,472 # ffffffffc02064e8 <commands+0x9e0>
ffffffffc0201318:	00005617          	auipc	a2,0x5
ffffffffc020131c:	04060613          	addi	a2,a2,64 # ffffffffc0206358 <commands+0x850>
ffffffffc0201320:	0ee00593          	li	a1,238
ffffffffc0201324:	00005517          	auipc	a0,0x5
ffffffffc0201328:	04c50513          	addi	a0,a0,76 # ffffffffc0206370 <commands+0x868>
ffffffffc020132c:	966ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201330:	00005697          	auipc	a3,0x5
ffffffffc0201334:	1a068693          	addi	a3,a3,416 # ffffffffc02064d0 <commands+0x9c8>
ffffffffc0201338:	00005617          	auipc	a2,0x5
ffffffffc020133c:	02060613          	addi	a2,a2,32 # ffffffffc0206358 <commands+0x850>
ffffffffc0201340:	0e900593          	li	a1,233
ffffffffc0201344:	00005517          	auipc	a0,0x5
ffffffffc0201348:	02c50513          	addi	a0,a0,44 # ffffffffc0206370 <commands+0x868>
ffffffffc020134c:	946ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201350:	00005697          	auipc	a3,0x5
ffffffffc0201354:	16068693          	addi	a3,a3,352 # ffffffffc02064b0 <commands+0x9a8>
ffffffffc0201358:	00005617          	auipc	a2,0x5
ffffffffc020135c:	00060613          	mv	a2,a2
ffffffffc0201360:	0e000593          	li	a1,224
ffffffffc0201364:	00005517          	auipc	a0,0x5
ffffffffc0201368:	00c50513          	addi	a0,a0,12 # ffffffffc0206370 <commands+0x868>
ffffffffc020136c:	926ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(p0 != NULL);
ffffffffc0201370:	00005697          	auipc	a3,0x5
ffffffffc0201374:	1d068693          	addi	a3,a3,464 # ffffffffc0206540 <commands+0xa38>
ffffffffc0201378:	00005617          	auipc	a2,0x5
ffffffffc020137c:	fe060613          	addi	a2,a2,-32 # ffffffffc0206358 <commands+0x850>
ffffffffc0201380:	11800593          	li	a1,280
ffffffffc0201384:	00005517          	auipc	a0,0x5
ffffffffc0201388:	fec50513          	addi	a0,a0,-20 # ffffffffc0206370 <commands+0x868>
ffffffffc020138c:	906ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(nr_free == 0);
ffffffffc0201390:	00005697          	auipc	a3,0x5
ffffffffc0201394:	1a068693          	addi	a3,a3,416 # ffffffffc0206530 <commands+0xa28>
ffffffffc0201398:	00005617          	auipc	a2,0x5
ffffffffc020139c:	fc060613          	addi	a2,a2,-64 # ffffffffc0206358 <commands+0x850>
ffffffffc02013a0:	0fd00593          	li	a1,253
ffffffffc02013a4:	00005517          	auipc	a0,0x5
ffffffffc02013a8:	fcc50513          	addi	a0,a0,-52 # ffffffffc0206370 <commands+0x868>
ffffffffc02013ac:	8e6ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013b0:	00005697          	auipc	a3,0x5
ffffffffc02013b4:	12068693          	addi	a3,a3,288 # ffffffffc02064d0 <commands+0x9c8>
ffffffffc02013b8:	00005617          	auipc	a2,0x5
ffffffffc02013bc:	fa060613          	addi	a2,a2,-96 # ffffffffc0206358 <commands+0x850>
ffffffffc02013c0:	0fb00593          	li	a1,251
ffffffffc02013c4:	00005517          	auipc	a0,0x5
ffffffffc02013c8:	fac50513          	addi	a0,a0,-84 # ffffffffc0206370 <commands+0x868>
ffffffffc02013cc:	8c6ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02013d0:	00005697          	auipc	a3,0x5
ffffffffc02013d4:	14068693          	addi	a3,a3,320 # ffffffffc0206510 <commands+0xa08>
ffffffffc02013d8:	00005617          	auipc	a2,0x5
ffffffffc02013dc:	f8060613          	addi	a2,a2,-128 # ffffffffc0206358 <commands+0x850>
ffffffffc02013e0:	0fa00593          	li	a1,250
ffffffffc02013e4:	00005517          	auipc	a0,0x5
ffffffffc02013e8:	f8c50513          	addi	a0,a0,-116 # ffffffffc0206370 <commands+0x868>
ffffffffc02013ec:	8a6ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02013f0:	00005697          	auipc	a3,0x5
ffffffffc02013f4:	fb868693          	addi	a3,a3,-72 # ffffffffc02063a8 <commands+0x8a0>
ffffffffc02013f8:	00005617          	auipc	a2,0x5
ffffffffc02013fc:	f6060613          	addi	a2,a2,-160 # ffffffffc0206358 <commands+0x850>
ffffffffc0201400:	0d700593          	li	a1,215
ffffffffc0201404:	00005517          	auipc	a0,0x5
ffffffffc0201408:	f6c50513          	addi	a0,a0,-148 # ffffffffc0206370 <commands+0x868>
ffffffffc020140c:	886ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201410:	00005697          	auipc	a3,0x5
ffffffffc0201414:	0c068693          	addi	a3,a3,192 # ffffffffc02064d0 <commands+0x9c8>
ffffffffc0201418:	00005617          	auipc	a2,0x5
ffffffffc020141c:	f4060613          	addi	a2,a2,-192 # ffffffffc0206358 <commands+0x850>
ffffffffc0201420:	0f400593          	li	a1,244
ffffffffc0201424:	00005517          	auipc	a0,0x5
ffffffffc0201428:	f4c50513          	addi	a0,a0,-180 # ffffffffc0206370 <commands+0x868>
ffffffffc020142c:	866ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201430:	00005697          	auipc	a3,0x5
ffffffffc0201434:	fb868693          	addi	a3,a3,-72 # ffffffffc02063e8 <commands+0x8e0>
ffffffffc0201438:	00005617          	auipc	a2,0x5
ffffffffc020143c:	f2060613          	addi	a2,a2,-224 # ffffffffc0206358 <commands+0x850>
ffffffffc0201440:	0f200593          	li	a1,242
ffffffffc0201444:	00005517          	auipc	a0,0x5
ffffffffc0201448:	f2c50513          	addi	a0,a0,-212 # ffffffffc0206370 <commands+0x868>
ffffffffc020144c:	846ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201450:	00005697          	auipc	a3,0x5
ffffffffc0201454:	f7868693          	addi	a3,a3,-136 # ffffffffc02063c8 <commands+0x8c0>
ffffffffc0201458:	00005617          	auipc	a2,0x5
ffffffffc020145c:	f0060613          	addi	a2,a2,-256 # ffffffffc0206358 <commands+0x850>
ffffffffc0201460:	0f100593          	li	a1,241
ffffffffc0201464:	00005517          	auipc	a0,0x5
ffffffffc0201468:	f0c50513          	addi	a0,a0,-244 # ffffffffc0206370 <commands+0x868>
ffffffffc020146c:	826ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201470:	00005697          	auipc	a3,0x5
ffffffffc0201474:	f7868693          	addi	a3,a3,-136 # ffffffffc02063e8 <commands+0x8e0>
ffffffffc0201478:	00005617          	auipc	a2,0x5
ffffffffc020147c:	ee060613          	addi	a2,a2,-288 # ffffffffc0206358 <commands+0x850>
ffffffffc0201480:	0d900593          	li	a1,217
ffffffffc0201484:	00005517          	auipc	a0,0x5
ffffffffc0201488:	eec50513          	addi	a0,a0,-276 # ffffffffc0206370 <commands+0x868>
ffffffffc020148c:	806ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(count == 0);
ffffffffc0201490:	00005697          	auipc	a3,0x5
ffffffffc0201494:	20068693          	addi	a3,a3,512 # ffffffffc0206690 <commands+0xb88>
ffffffffc0201498:	00005617          	auipc	a2,0x5
ffffffffc020149c:	ec060613          	addi	a2,a2,-320 # ffffffffc0206358 <commands+0x850>
ffffffffc02014a0:	14600593          	li	a1,326
ffffffffc02014a4:	00005517          	auipc	a0,0x5
ffffffffc02014a8:	ecc50513          	addi	a0,a0,-308 # ffffffffc0206370 <commands+0x868>
ffffffffc02014ac:	fe7fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(nr_free == 0);
ffffffffc02014b0:	00005697          	auipc	a3,0x5
ffffffffc02014b4:	08068693          	addi	a3,a3,128 # ffffffffc0206530 <commands+0xa28>
ffffffffc02014b8:	00005617          	auipc	a2,0x5
ffffffffc02014bc:	ea060613          	addi	a2,a2,-352 # ffffffffc0206358 <commands+0x850>
ffffffffc02014c0:	13a00593          	li	a1,314
ffffffffc02014c4:	00005517          	auipc	a0,0x5
ffffffffc02014c8:	eac50513          	addi	a0,a0,-340 # ffffffffc0206370 <commands+0x868>
ffffffffc02014cc:	fc7fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014d0:	00005697          	auipc	a3,0x5
ffffffffc02014d4:	00068693          	mv	a3,a3
ffffffffc02014d8:	00005617          	auipc	a2,0x5
ffffffffc02014dc:	e8060613          	addi	a2,a2,-384 # ffffffffc0206358 <commands+0x850>
ffffffffc02014e0:	13800593          	li	a1,312
ffffffffc02014e4:	00005517          	auipc	a0,0x5
ffffffffc02014e8:	e8c50513          	addi	a0,a0,-372 # ffffffffc0206370 <commands+0x868>
ffffffffc02014ec:	fa7fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02014f0:	00005697          	auipc	a3,0x5
ffffffffc02014f4:	fa068693          	addi	a3,a3,-96 # ffffffffc0206490 <commands+0x988>
ffffffffc02014f8:	00005617          	auipc	a2,0x5
ffffffffc02014fc:	e6060613          	addi	a2,a2,-416 # ffffffffc0206358 <commands+0x850>
ffffffffc0201500:	0df00593          	li	a1,223
ffffffffc0201504:	00005517          	auipc	a0,0x5
ffffffffc0201508:	e6c50513          	addi	a0,a0,-404 # ffffffffc0206370 <commands+0x868>
ffffffffc020150c:	f87fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201510:	00005697          	auipc	a3,0x5
ffffffffc0201514:	14068693          	addi	a3,a3,320 # ffffffffc0206650 <commands+0xb48>
ffffffffc0201518:	00005617          	auipc	a2,0x5
ffffffffc020151c:	e4060613          	addi	a2,a2,-448 # ffffffffc0206358 <commands+0x850>
ffffffffc0201520:	13200593          	li	a1,306
ffffffffc0201524:	00005517          	auipc	a0,0x5
ffffffffc0201528:	e4c50513          	addi	a0,a0,-436 # ffffffffc0206370 <commands+0x868>
ffffffffc020152c:	f67fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201530:	00005697          	auipc	a3,0x5
ffffffffc0201534:	10068693          	addi	a3,a3,256 # ffffffffc0206630 <commands+0xb28>
ffffffffc0201538:	00005617          	auipc	a2,0x5
ffffffffc020153c:	e2060613          	addi	a2,a2,-480 # ffffffffc0206358 <commands+0x850>
ffffffffc0201540:	13000593          	li	a1,304
ffffffffc0201544:	00005517          	auipc	a0,0x5
ffffffffc0201548:	e2c50513          	addi	a0,a0,-468 # ffffffffc0206370 <commands+0x868>
ffffffffc020154c:	f47fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201550:	00005697          	auipc	a3,0x5
ffffffffc0201554:	0b868693          	addi	a3,a3,184 # ffffffffc0206608 <commands+0xb00>
ffffffffc0201558:	00005617          	auipc	a2,0x5
ffffffffc020155c:	e0060613          	addi	a2,a2,-512 # ffffffffc0206358 <commands+0x850>
ffffffffc0201560:	12e00593          	li	a1,302
ffffffffc0201564:	00005517          	auipc	a0,0x5
ffffffffc0201568:	e0c50513          	addi	a0,a0,-500 # ffffffffc0206370 <commands+0x868>
ffffffffc020156c:	f27fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201570:	00005697          	auipc	a3,0x5
ffffffffc0201574:	07068693          	addi	a3,a3,112 # ffffffffc02065e0 <commands+0xad8>
ffffffffc0201578:	00005617          	auipc	a2,0x5
ffffffffc020157c:	de060613          	addi	a2,a2,-544 # ffffffffc0206358 <commands+0x850>
ffffffffc0201580:	12d00593          	li	a1,301
ffffffffc0201584:	00005517          	auipc	a0,0x5
ffffffffc0201588:	dec50513          	addi	a0,a0,-532 # ffffffffc0206370 <commands+0x868>
ffffffffc020158c:	f07fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201590:	00005697          	auipc	a3,0x5
ffffffffc0201594:	04068693          	addi	a3,a3,64 # ffffffffc02065d0 <commands+0xac8>
ffffffffc0201598:	00005617          	auipc	a2,0x5
ffffffffc020159c:	dc060613          	addi	a2,a2,-576 # ffffffffc0206358 <commands+0x850>
ffffffffc02015a0:	12800593          	li	a1,296
ffffffffc02015a4:	00005517          	auipc	a0,0x5
ffffffffc02015a8:	dcc50513          	addi	a0,a0,-564 # ffffffffc0206370 <commands+0x868>
ffffffffc02015ac:	ee7fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02015b0:	00005697          	auipc	a3,0x5
ffffffffc02015b4:	f2068693          	addi	a3,a3,-224 # ffffffffc02064d0 <commands+0x9c8>
ffffffffc02015b8:	00005617          	auipc	a2,0x5
ffffffffc02015bc:	da060613          	addi	a2,a2,-608 # ffffffffc0206358 <commands+0x850>
ffffffffc02015c0:	12700593          	li	a1,295
ffffffffc02015c4:	00005517          	auipc	a0,0x5
ffffffffc02015c8:	dac50513          	addi	a0,a0,-596 # ffffffffc0206370 <commands+0x868>
ffffffffc02015cc:	ec7fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02015d0:	00005697          	auipc	a3,0x5
ffffffffc02015d4:	fe068693          	addi	a3,a3,-32 # ffffffffc02065b0 <commands+0xaa8>
ffffffffc02015d8:	00005617          	auipc	a2,0x5
ffffffffc02015dc:	d8060613          	addi	a2,a2,-640 # ffffffffc0206358 <commands+0x850>
ffffffffc02015e0:	12600593          	li	a1,294
ffffffffc02015e4:	00005517          	auipc	a0,0x5
ffffffffc02015e8:	d8c50513          	addi	a0,a0,-628 # ffffffffc0206370 <commands+0x868>
ffffffffc02015ec:	ea7fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02015f0:	00005697          	auipc	a3,0x5
ffffffffc02015f4:	f9068693          	addi	a3,a3,-112 # ffffffffc0206580 <commands+0xa78>
ffffffffc02015f8:	00005617          	auipc	a2,0x5
ffffffffc02015fc:	d6060613          	addi	a2,a2,-672 # ffffffffc0206358 <commands+0x850>
ffffffffc0201600:	12500593          	li	a1,293
ffffffffc0201604:	00005517          	auipc	a0,0x5
ffffffffc0201608:	d6c50513          	addi	a0,a0,-660 # ffffffffc0206370 <commands+0x868>
ffffffffc020160c:	e87fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201610:	00005697          	auipc	a3,0x5
ffffffffc0201614:	f5868693          	addi	a3,a3,-168 # ffffffffc0206568 <commands+0xa60>
ffffffffc0201618:	00005617          	auipc	a2,0x5
ffffffffc020161c:	d4060613          	addi	a2,a2,-704 # ffffffffc0206358 <commands+0x850>
ffffffffc0201620:	12400593          	li	a1,292
ffffffffc0201624:	00005517          	auipc	a0,0x5
ffffffffc0201628:	d4c50513          	addi	a0,a0,-692 # ffffffffc0206370 <commands+0x868>
ffffffffc020162c:	e67fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201630:	00005697          	auipc	a3,0x5
ffffffffc0201634:	ea068693          	addi	a3,a3,-352 # ffffffffc02064d0 <commands+0x9c8>
ffffffffc0201638:	00005617          	auipc	a2,0x5
ffffffffc020163c:	d2060613          	addi	a2,a2,-736 # ffffffffc0206358 <commands+0x850>
ffffffffc0201640:	11e00593          	li	a1,286
ffffffffc0201644:	00005517          	auipc	a0,0x5
ffffffffc0201648:	d2c50513          	addi	a0,a0,-724 # ffffffffc0206370 <commands+0x868>
ffffffffc020164c:	e47fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201650:	00005697          	auipc	a3,0x5
ffffffffc0201654:	f0068693          	addi	a3,a3,-256 # ffffffffc0206550 <commands+0xa48>
ffffffffc0201658:	00005617          	auipc	a2,0x5
ffffffffc020165c:	d0060613          	addi	a2,a2,-768 # ffffffffc0206358 <commands+0x850>
ffffffffc0201660:	11900593          	li	a1,281
ffffffffc0201664:	00005517          	auipc	a0,0x5
ffffffffc0201668:	d0c50513          	addi	a0,a0,-756 # ffffffffc0206370 <commands+0x868>
ffffffffc020166c:	e27fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201670:	00005697          	auipc	a3,0x5
ffffffffc0201674:	00068693          	mv	a3,a3
ffffffffc0201678:	00005617          	auipc	a2,0x5
ffffffffc020167c:	ce060613          	addi	a2,a2,-800 # ffffffffc0206358 <commands+0x850>
ffffffffc0201680:	13700593          	li	a1,311
ffffffffc0201684:	00005517          	auipc	a0,0x5
ffffffffc0201688:	cec50513          	addi	a0,a0,-788 # ffffffffc0206370 <commands+0x868>
ffffffffc020168c:	e07fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(total == 0);
ffffffffc0201690:	00005697          	auipc	a3,0x5
ffffffffc0201694:	01068693          	addi	a3,a3,16 # ffffffffc02066a0 <commands+0xb98>
ffffffffc0201698:	00005617          	auipc	a2,0x5
ffffffffc020169c:	cc060613          	addi	a2,a2,-832 # ffffffffc0206358 <commands+0x850>
ffffffffc02016a0:	14700593          	li	a1,327
ffffffffc02016a4:	00005517          	auipc	a0,0x5
ffffffffc02016a8:	ccc50513          	addi	a0,a0,-820 # ffffffffc0206370 <commands+0x868>
ffffffffc02016ac:	de7fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(total == nr_free_pages());
ffffffffc02016b0:	00005697          	auipc	a3,0x5
ffffffffc02016b4:	cd868693          	addi	a3,a3,-808 # ffffffffc0206388 <commands+0x880>
ffffffffc02016b8:	00005617          	auipc	a2,0x5
ffffffffc02016bc:	ca060613          	addi	a2,a2,-864 # ffffffffc0206358 <commands+0x850>
ffffffffc02016c0:	11300593          	li	a1,275
ffffffffc02016c4:	00005517          	auipc	a0,0x5
ffffffffc02016c8:	cac50513          	addi	a0,a0,-852 # ffffffffc0206370 <commands+0x868>
ffffffffc02016cc:	dc7fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02016d0:	00005697          	auipc	a3,0x5
ffffffffc02016d4:	cf868693          	addi	a3,a3,-776 # ffffffffc02063c8 <commands+0x8c0>
ffffffffc02016d8:	00005617          	auipc	a2,0x5
ffffffffc02016dc:	c8060613          	addi	a2,a2,-896 # ffffffffc0206358 <commands+0x850>
ffffffffc02016e0:	0d800593          	li	a1,216
ffffffffc02016e4:	00005517          	auipc	a0,0x5
ffffffffc02016e8:	c8c50513          	addi	a0,a0,-884 # ffffffffc0206370 <commands+0x868>
ffffffffc02016ec:	da7fe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02016f0 <default_free_pages>:
{
ffffffffc02016f0:	1141                	addi	sp,sp,-16
ffffffffc02016f2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02016f4:	14058463          	beqz	a1,ffffffffc020183c <default_free_pages+0x14c>
    for (; p != base + n; p++)
ffffffffc02016f8:	00659693          	slli	a3,a1,0x6
ffffffffc02016fc:	96aa                	add	a3,a3,a0
ffffffffc02016fe:	87aa                	mv	a5,a0
ffffffffc0201700:	02d50263          	beq	a0,a3,ffffffffc0201724 <default_free_pages+0x34>
ffffffffc0201704:	6798                	ld	a4,8(a5)
ffffffffc0201706:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201708:	10071a63          	bnez	a4,ffffffffc020181c <default_free_pages+0x12c>
ffffffffc020170c:	6798                	ld	a4,8(a5)
ffffffffc020170e:	8b09                	andi	a4,a4,2
ffffffffc0201710:	10071663          	bnez	a4,ffffffffc020181c <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0201714:	0007b423          	sd	zero,8(a5)
}

static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
ffffffffc0201718:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc020171c:	04078793          	addi	a5,a5,64
ffffffffc0201720:	fed792e3          	bne	a5,a3,ffffffffc0201704 <default_free_pages+0x14>
    base->property = n;
ffffffffc0201724:	2581                	sext.w	a1,a1
ffffffffc0201726:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201728:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020172c:	4789                	li	a5,2
ffffffffc020172e:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201732:	000cd697          	auipc	a3,0xcd
ffffffffc0201736:	fd668693          	addi	a3,a3,-42 # ffffffffc02ce708 <free_area>
ffffffffc020173a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020173c:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020173e:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201742:	9db9                	addw	a1,a1,a4
ffffffffc0201744:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc0201746:	0ad78463          	beq	a5,a3,ffffffffc02017ee <default_free_pages+0xfe>
            struct Page *page = le2page(le, page_link);
ffffffffc020174a:	fe878713          	addi	a4,a5,-24
ffffffffc020174e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc0201752:	4581                	li	a1,0
            if (base < page)
ffffffffc0201754:	00e56a63          	bltu	a0,a4,ffffffffc0201768 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0201758:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc020175a:	04d70c63          	beq	a4,a3,ffffffffc02017b2 <default_free_pages+0xc2>
    for (; p != base + n; p++)
ffffffffc020175e:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0201760:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0201764:	fee57ae3          	bgeu	a0,a4,ffffffffc0201758 <default_free_pages+0x68>
ffffffffc0201768:	c199                	beqz	a1,ffffffffc020176e <default_free_pages+0x7e>
ffffffffc020176a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020176e:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201770:	e390                	sd	a2,0(a5)
ffffffffc0201772:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201774:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201776:	ed18                	sd	a4,24(a0)
    if (le != &free_list)
ffffffffc0201778:	00d70d63          	beq	a4,a3,ffffffffc0201792 <default_free_pages+0xa2>
        if (p + p->property == base)
ffffffffc020177c:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201780:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base)
ffffffffc0201784:	02059813          	slli	a6,a1,0x20
ffffffffc0201788:	01a85793          	srli	a5,a6,0x1a
ffffffffc020178c:	97b2                	add	a5,a5,a2
ffffffffc020178e:	02f50c63          	beq	a0,a5,ffffffffc02017c6 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0201792:	711c                	ld	a5,32(a0)
    if (le != &free_list)
ffffffffc0201794:	00d78c63          	beq	a5,a3,ffffffffc02017ac <default_free_pages+0xbc>
        if (base + base->property == p)
ffffffffc0201798:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc020179a:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p)
ffffffffc020179e:	02061593          	slli	a1,a2,0x20
ffffffffc02017a2:	01a5d713          	srli	a4,a1,0x1a
ffffffffc02017a6:	972a                	add	a4,a4,a0
ffffffffc02017a8:	04e68a63          	beq	a3,a4,ffffffffc02017fc <default_free_pages+0x10c>
}
ffffffffc02017ac:	60a2                	ld	ra,8(sp)
ffffffffc02017ae:	0141                	addi	sp,sp,16
ffffffffc02017b0:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02017b2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02017b4:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02017b6:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02017b8:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc02017ba:	02d70763          	beq	a4,a3,ffffffffc02017e8 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc02017be:	8832                	mv	a6,a2
ffffffffc02017c0:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc02017c2:	87ba                	mv	a5,a4
ffffffffc02017c4:	bf71                	j	ffffffffc0201760 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc02017c6:	491c                	lw	a5,16(a0)
ffffffffc02017c8:	9dbd                	addw	a1,a1,a5
ffffffffc02017ca:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02017ce:	57f5                	li	a5,-3
ffffffffc02017d0:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02017d4:	01853803          	ld	a6,24(a0)
ffffffffc02017d8:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc02017da:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02017dc:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc02017e0:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc02017e2:	0105b023          	sd	a6,0(a1)
ffffffffc02017e6:	b77d                	j	ffffffffc0201794 <default_free_pages+0xa4>
ffffffffc02017e8:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list)
ffffffffc02017ea:	873e                	mv	a4,a5
ffffffffc02017ec:	bf41                	j	ffffffffc020177c <default_free_pages+0x8c>
}
ffffffffc02017ee:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02017f0:	e390                	sd	a2,0(a5)
ffffffffc02017f2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02017f4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02017f6:	ed1c                	sd	a5,24(a0)
ffffffffc02017f8:	0141                	addi	sp,sp,16
ffffffffc02017fa:	8082                	ret
            base->property += p->property;
ffffffffc02017fc:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201800:	ff078693          	addi	a3,a5,-16
ffffffffc0201804:	9e39                	addw	a2,a2,a4
ffffffffc0201806:	c910                	sw	a2,16(a0)
ffffffffc0201808:	5775                	li	a4,-3
ffffffffc020180a:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020180e:	6398                	ld	a4,0(a5)
ffffffffc0201810:	679c                	ld	a5,8(a5)
}
ffffffffc0201812:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201814:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201816:	e398                	sd	a4,0(a5)
ffffffffc0201818:	0141                	addi	sp,sp,16
ffffffffc020181a:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020181c:	00005697          	auipc	a3,0x5
ffffffffc0201820:	e9c68693          	addi	a3,a3,-356 # ffffffffc02066b8 <commands+0xbb0>
ffffffffc0201824:	00005617          	auipc	a2,0x5
ffffffffc0201828:	b3460613          	addi	a2,a2,-1228 # ffffffffc0206358 <commands+0x850>
ffffffffc020182c:	09400593          	li	a1,148
ffffffffc0201830:	00005517          	auipc	a0,0x5
ffffffffc0201834:	b4050513          	addi	a0,a0,-1216 # ffffffffc0206370 <commands+0x868>
ffffffffc0201838:	c5bfe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(n > 0);
ffffffffc020183c:	00005697          	auipc	a3,0x5
ffffffffc0201840:	e7468693          	addi	a3,a3,-396 # ffffffffc02066b0 <commands+0xba8>
ffffffffc0201844:	00005617          	auipc	a2,0x5
ffffffffc0201848:	b1460613          	addi	a2,a2,-1260 # ffffffffc0206358 <commands+0x850>
ffffffffc020184c:	09000593          	li	a1,144
ffffffffc0201850:	00005517          	auipc	a0,0x5
ffffffffc0201854:	b2050513          	addi	a0,a0,-1248 # ffffffffc0206370 <commands+0x868>
ffffffffc0201858:	c3bfe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc020185c <default_alloc_pages>:
    assert(n > 0);
ffffffffc020185c:	c941                	beqz	a0,ffffffffc02018ec <default_alloc_pages+0x90>
    if (n > nr_free)
ffffffffc020185e:	000cd597          	auipc	a1,0xcd
ffffffffc0201862:	eaa58593          	addi	a1,a1,-342 # ffffffffc02ce708 <free_area>
ffffffffc0201866:	0105a803          	lw	a6,16(a1)
ffffffffc020186a:	872a                	mv	a4,a0
ffffffffc020186c:	02081793          	slli	a5,a6,0x20
ffffffffc0201870:	9381                	srli	a5,a5,0x20
ffffffffc0201872:	00a7ee63          	bltu	a5,a0,ffffffffc020188e <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201876:	87ae                	mv	a5,a1
ffffffffc0201878:	a801                	j	ffffffffc0201888 <default_alloc_pages+0x2c>
        if (p->property >= n)
ffffffffc020187a:	ff87a683          	lw	a3,-8(a5)
ffffffffc020187e:	02069613          	slli	a2,a3,0x20
ffffffffc0201882:	9201                	srli	a2,a2,0x20
ffffffffc0201884:	00e67763          	bgeu	a2,a4,ffffffffc0201892 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201888:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc020188a:	feb798e3          	bne	a5,a1,ffffffffc020187a <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020188e:	4501                	li	a0,0
}
ffffffffc0201890:	8082                	ret
    return listelm->prev;
ffffffffc0201892:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201896:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc020189a:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc020189e:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc02018a2:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02018a6:	01133023          	sd	a7,0(t1)
        if (page->property > n)
ffffffffc02018aa:	02c77863          	bgeu	a4,a2,ffffffffc02018da <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc02018ae:	071a                	slli	a4,a4,0x6
ffffffffc02018b0:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc02018b2:	41c686bb          	subw	a3,a3,t3
ffffffffc02018b6:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02018b8:	00870613          	addi	a2,a4,8
ffffffffc02018bc:	4689                	li	a3,2
ffffffffc02018be:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02018c2:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02018c6:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc02018ca:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc02018ce:	e290                	sd	a2,0(a3)
ffffffffc02018d0:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02018d4:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc02018d6:	01173c23          	sd	a7,24(a4)
ffffffffc02018da:	41c8083b          	subw	a6,a6,t3
ffffffffc02018de:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02018e2:	5775                	li	a4,-3
ffffffffc02018e4:	17c1                	addi	a5,a5,-16
ffffffffc02018e6:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc02018ea:	8082                	ret
{
ffffffffc02018ec:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02018ee:	00005697          	auipc	a3,0x5
ffffffffc02018f2:	dc268693          	addi	a3,a3,-574 # ffffffffc02066b0 <commands+0xba8>
ffffffffc02018f6:	00005617          	auipc	a2,0x5
ffffffffc02018fa:	a6260613          	addi	a2,a2,-1438 # ffffffffc0206358 <commands+0x850>
ffffffffc02018fe:	06c00593          	li	a1,108
ffffffffc0201902:	00005517          	auipc	a0,0x5
ffffffffc0201906:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0206370 <commands+0x868>
{
ffffffffc020190a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020190c:	b87fe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0201910 <default_init_memmap>:
{
ffffffffc0201910:	1141                	addi	sp,sp,-16
ffffffffc0201912:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201914:	c5f1                	beqz	a1,ffffffffc02019e0 <default_init_memmap+0xd0>
    for (; p != base + n; p++)
ffffffffc0201916:	00659693          	slli	a3,a1,0x6
ffffffffc020191a:	96aa                	add	a3,a3,a0
ffffffffc020191c:	87aa                	mv	a5,a0
ffffffffc020191e:	00d50f63          	beq	a0,a3,ffffffffc020193c <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201922:	6798                	ld	a4,8(a5)
ffffffffc0201924:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc0201926:	cf49                	beqz	a4,ffffffffc02019c0 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0201928:	0007a823          	sw	zero,16(a5)
ffffffffc020192c:	0007b423          	sd	zero,8(a5)
ffffffffc0201930:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc0201934:	04078793          	addi	a5,a5,64
ffffffffc0201938:	fed795e3          	bne	a5,a3,ffffffffc0201922 <default_init_memmap+0x12>
    base->property = n;
ffffffffc020193c:	2581                	sext.w	a1,a1
ffffffffc020193e:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201940:	4789                	li	a5,2
ffffffffc0201942:	00850713          	addi	a4,a0,8
ffffffffc0201946:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020194a:	000cd697          	auipc	a3,0xcd
ffffffffc020194e:	dbe68693          	addi	a3,a3,-578 # ffffffffc02ce708 <free_area>
ffffffffc0201952:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201954:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201956:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020195a:	9db9                	addw	a1,a1,a4
ffffffffc020195c:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc020195e:	04d78a63          	beq	a5,a3,ffffffffc02019b2 <default_init_memmap+0xa2>
            struct Page *page = le2page(le, page_link);
ffffffffc0201962:	fe878713          	addi	a4,a5,-24
ffffffffc0201966:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc020196a:	4581                	li	a1,0
            if (base < page)
ffffffffc020196c:	00e56a63          	bltu	a0,a4,ffffffffc0201980 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0201970:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc0201972:	02d70263          	beq	a4,a3,ffffffffc0201996 <default_init_memmap+0x86>
    for (; p != base + n; p++)
ffffffffc0201976:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0201978:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc020197c:	fee57ae3          	bgeu	a0,a4,ffffffffc0201970 <default_init_memmap+0x60>
ffffffffc0201980:	c199                	beqz	a1,ffffffffc0201986 <default_init_memmap+0x76>
ffffffffc0201982:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201986:	6398                	ld	a4,0(a5)
}
ffffffffc0201988:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020198a:	e390                	sd	a2,0(a5)
ffffffffc020198c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020198e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201990:	ed18                	sd	a4,24(a0)
ffffffffc0201992:	0141                	addi	sp,sp,16
ffffffffc0201994:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201996:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201998:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020199a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020199c:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc020199e:	00d70663          	beq	a4,a3,ffffffffc02019aa <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc02019a2:	8832                	mv	a6,a2
ffffffffc02019a4:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc02019a6:	87ba                	mv	a5,a4
ffffffffc02019a8:	bfc1                	j	ffffffffc0201978 <default_init_memmap+0x68>
}
ffffffffc02019aa:	60a2                	ld	ra,8(sp)
ffffffffc02019ac:	e290                	sd	a2,0(a3)
ffffffffc02019ae:	0141                	addi	sp,sp,16
ffffffffc02019b0:	8082                	ret
ffffffffc02019b2:	60a2                	ld	ra,8(sp)
ffffffffc02019b4:	e390                	sd	a2,0(a5)
ffffffffc02019b6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02019b8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02019ba:	ed1c                	sd	a5,24(a0)
ffffffffc02019bc:	0141                	addi	sp,sp,16
ffffffffc02019be:	8082                	ret
        assert(PageReserved(p));
ffffffffc02019c0:	00005697          	auipc	a3,0x5
ffffffffc02019c4:	d2068693          	addi	a3,a3,-736 # ffffffffc02066e0 <commands+0xbd8>
ffffffffc02019c8:	00005617          	auipc	a2,0x5
ffffffffc02019cc:	99060613          	addi	a2,a2,-1648 # ffffffffc0206358 <commands+0x850>
ffffffffc02019d0:	04b00593          	li	a1,75
ffffffffc02019d4:	00005517          	auipc	a0,0x5
ffffffffc02019d8:	99c50513          	addi	a0,a0,-1636 # ffffffffc0206370 <commands+0x868>
ffffffffc02019dc:	ab7fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(n > 0);
ffffffffc02019e0:	00005697          	auipc	a3,0x5
ffffffffc02019e4:	cd068693          	addi	a3,a3,-816 # ffffffffc02066b0 <commands+0xba8>
ffffffffc02019e8:	00005617          	auipc	a2,0x5
ffffffffc02019ec:	97060613          	addi	a2,a2,-1680 # ffffffffc0206358 <commands+0x850>
ffffffffc02019f0:	04700593          	li	a1,71
ffffffffc02019f4:	00005517          	auipc	a0,0x5
ffffffffc02019f8:	97c50513          	addi	a0,a0,-1668 # ffffffffc0206370 <commands+0x868>
ffffffffc02019fc:	a97fe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0201a00 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201a00:	c94d                	beqz	a0,ffffffffc0201ab2 <slob_free+0xb2>
{
ffffffffc0201a02:	1141                	addi	sp,sp,-16
ffffffffc0201a04:	e022                	sd	s0,0(sp)
ffffffffc0201a06:	e406                	sd	ra,8(sp)
ffffffffc0201a08:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc0201a0a:	e9c1                	bnez	a1,ffffffffc0201a9a <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201a0c:	100027f3          	csrr	a5,sstatus
ffffffffc0201a10:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201a12:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201a14:	ebd9                	bnez	a5,ffffffffc0201aaa <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a16:	000cd617          	auipc	a2,0xcd
ffffffffc0201a1a:	8e260613          	addi	a2,a2,-1822 # ffffffffc02ce2f8 <slobfree>
ffffffffc0201a1e:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a20:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a22:	679c                	ld	a5,8(a5)
ffffffffc0201a24:	02877a63          	bgeu	a4,s0,ffffffffc0201a58 <slob_free+0x58>
ffffffffc0201a28:	00f46463          	bltu	s0,a5,ffffffffc0201a30 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a2c:	fef76ae3          	bltu	a4,a5,ffffffffc0201a20 <slob_free+0x20>
			break;

	if (b + b->units == cur->next)
ffffffffc0201a30:	400c                	lw	a1,0(s0)
ffffffffc0201a32:	00459693          	slli	a3,a1,0x4
ffffffffc0201a36:	96a2                	add	a3,a3,s0
ffffffffc0201a38:	02d78a63          	beq	a5,a3,ffffffffc0201a6c <slob_free+0x6c>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc0201a3c:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0201a3e:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0201a40:	00469793          	slli	a5,a3,0x4
ffffffffc0201a44:	97ba                	add	a5,a5,a4
ffffffffc0201a46:	02f40e63          	beq	s0,a5,ffffffffc0201a82 <slob_free+0x82>
	{
		cur->units += b->units;
		cur->next = b->next;
	}
	else
		cur->next = b;
ffffffffc0201a4a:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0201a4c:	e218                	sd	a4,0(a2)
    if (flag)
ffffffffc0201a4e:	e129                	bnez	a0,ffffffffc0201a90 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201a50:	60a2                	ld	ra,8(sp)
ffffffffc0201a52:	6402                	ld	s0,0(sp)
ffffffffc0201a54:	0141                	addi	sp,sp,16
ffffffffc0201a56:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a58:	fcf764e3          	bltu	a4,a5,ffffffffc0201a20 <slob_free+0x20>
ffffffffc0201a5c:	fcf472e3          	bgeu	s0,a5,ffffffffc0201a20 <slob_free+0x20>
	if (b + b->units == cur->next)
ffffffffc0201a60:	400c                	lw	a1,0(s0)
ffffffffc0201a62:	00459693          	slli	a3,a1,0x4
ffffffffc0201a66:	96a2                	add	a3,a3,s0
ffffffffc0201a68:	fcd79ae3          	bne	a5,a3,ffffffffc0201a3c <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0201a6c:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201a6e:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201a70:	9db5                	addw	a1,a1,a3
ffffffffc0201a72:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b)
ffffffffc0201a74:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a76:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0201a78:	00469793          	slli	a5,a3,0x4
ffffffffc0201a7c:	97ba                	add	a5,a5,a4
ffffffffc0201a7e:	fcf416e3          	bne	s0,a5,ffffffffc0201a4a <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0201a82:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201a84:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0201a86:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201a88:	9ebd                	addw	a3,a3,a5
ffffffffc0201a8a:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0201a8c:	e70c                	sd	a1,8(a4)
ffffffffc0201a8e:	d169                	beqz	a0,ffffffffc0201a50 <slob_free+0x50>
}
ffffffffc0201a90:	6402                	ld	s0,0(sp)
ffffffffc0201a92:	60a2                	ld	ra,8(sp)
ffffffffc0201a94:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201a96:	f13fe06f          	j	ffffffffc02009a8 <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0201a9a:	25bd                	addiw	a1,a1,15
ffffffffc0201a9c:	8191                	srli	a1,a1,0x4
ffffffffc0201a9e:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201aa0:	100027f3          	csrr	a5,sstatus
ffffffffc0201aa4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201aa6:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201aa8:	d7bd                	beqz	a5,ffffffffc0201a16 <slob_free+0x16>
        intr_disable();
ffffffffc0201aaa:	f05fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        return 1;
ffffffffc0201aae:	4505                	li	a0,1
ffffffffc0201ab0:	b79d                	j	ffffffffc0201a16 <slob_free+0x16>
ffffffffc0201ab2:	8082                	ret

ffffffffc0201ab4 <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201ab4:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201ab6:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201ab8:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201abc:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201abe:	352000ef          	jal	ra,ffffffffc0201e10 <alloc_pages>
	if (!page)
ffffffffc0201ac2:	c91d                	beqz	a0,ffffffffc0201af8 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201ac4:	000d1697          	auipc	a3,0xd1
ffffffffc0201ac8:	ce46b683          	ld	a3,-796(a3) # ffffffffc02d27a8 <pages>
ffffffffc0201acc:	8d15                	sub	a0,a0,a3
ffffffffc0201ace:	8519                	srai	a0,a0,0x6
ffffffffc0201ad0:	00006697          	auipc	a3,0x6
ffffffffc0201ad4:	6f06b683          	ld	a3,1776(a3) # ffffffffc02081c0 <nbase>
ffffffffc0201ad8:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201ada:	00c51793          	slli	a5,a0,0xc
ffffffffc0201ade:	83b1                	srli	a5,a5,0xc
ffffffffc0201ae0:	000d1717          	auipc	a4,0xd1
ffffffffc0201ae4:	cc073703          	ld	a4,-832(a4) # ffffffffc02d27a0 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ae8:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201aea:	00e7fa63          	bgeu	a5,a4,ffffffffc0201afe <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201aee:	000d1697          	auipc	a3,0xd1
ffffffffc0201af2:	cca6b683          	ld	a3,-822(a3) # ffffffffc02d27b8 <va_pa_offset>
ffffffffc0201af6:	9536                	add	a0,a0,a3
}
ffffffffc0201af8:	60a2                	ld	ra,8(sp)
ffffffffc0201afa:	0141                	addi	sp,sp,16
ffffffffc0201afc:	8082                	ret
ffffffffc0201afe:	86aa                	mv	a3,a0
ffffffffc0201b00:	00005617          	auipc	a2,0x5
ffffffffc0201b04:	c4060613          	addi	a2,a2,-960 # ffffffffc0206740 <default_pmm_manager+0x38>
ffffffffc0201b08:	07100593          	li	a1,113
ffffffffc0201b0c:	00005517          	auipc	a0,0x5
ffffffffc0201b10:	c5c50513          	addi	a0,a0,-932 # ffffffffc0206768 <default_pmm_manager+0x60>
ffffffffc0201b14:	97ffe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0201b18 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201b18:	1101                	addi	sp,sp,-32
ffffffffc0201b1a:	ec06                	sd	ra,24(sp)
ffffffffc0201b1c:	e822                	sd	s0,16(sp)
ffffffffc0201b1e:	e426                	sd	s1,8(sp)
ffffffffc0201b20:	e04a                	sd	s2,0(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201b22:	01050713          	addi	a4,a0,16
ffffffffc0201b26:	6785                	lui	a5,0x1
ffffffffc0201b28:	0cf77363          	bgeu	a4,a5,ffffffffc0201bee <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201b2c:	00f50493          	addi	s1,a0,15
ffffffffc0201b30:	8091                	srli	s1,s1,0x4
ffffffffc0201b32:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b34:	10002673          	csrr	a2,sstatus
ffffffffc0201b38:	8a09                	andi	a2,a2,2
ffffffffc0201b3a:	e25d                	bnez	a2,ffffffffc0201be0 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201b3c:	000cc917          	auipc	s2,0xcc
ffffffffc0201b40:	7bc90913          	addi	s2,s2,1980 # ffffffffc02ce2f8 <slobfree>
ffffffffc0201b44:	00093683          	ld	a3,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201b48:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta)
ffffffffc0201b4a:	4398                	lw	a4,0(a5)
ffffffffc0201b4c:	08975e63          	bge	a4,s1,ffffffffc0201be8 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree)
ffffffffc0201b50:	00f68b63          	beq	a3,a5,ffffffffc0201b66 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201b54:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201b56:	4018                	lw	a4,0(s0)
ffffffffc0201b58:	02975a63          	bge	a4,s1,ffffffffc0201b8c <slob_alloc.constprop.0+0x74>
		if (cur == slobfree)
ffffffffc0201b5c:	00093683          	ld	a3,0(s2)
ffffffffc0201b60:	87a2                	mv	a5,s0
ffffffffc0201b62:	fef699e3          	bne	a3,a5,ffffffffc0201b54 <slob_alloc.constprop.0+0x3c>
    if (flag)
ffffffffc0201b66:	ee31                	bnez	a2,ffffffffc0201bc2 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201b68:	4501                	li	a0,0
ffffffffc0201b6a:	f4bff0ef          	jal	ra,ffffffffc0201ab4 <__slob_get_free_pages.constprop.0>
ffffffffc0201b6e:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201b70:	cd05                	beqz	a0,ffffffffc0201ba8 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201b72:	6585                	lui	a1,0x1
ffffffffc0201b74:	e8dff0ef          	jal	ra,ffffffffc0201a00 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b78:	10002673          	csrr	a2,sstatus
ffffffffc0201b7c:	8a09                	andi	a2,a2,2
ffffffffc0201b7e:	ee05                	bnez	a2,ffffffffc0201bb6 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201b80:	00093783          	ld	a5,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201b84:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201b86:	4018                	lw	a4,0(s0)
ffffffffc0201b88:	fc974ae3          	blt	a4,s1,ffffffffc0201b5c <slob_alloc.constprop.0+0x44>
			if (cur->units == units)	/* exact fit? */
ffffffffc0201b8c:	04e48763          	beq	s1,a4,ffffffffc0201bda <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201b90:	00449693          	slli	a3,s1,0x4
ffffffffc0201b94:	96a2                	add	a3,a3,s0
ffffffffc0201b96:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201b98:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201b9a:	9f05                	subw	a4,a4,s1
ffffffffc0201b9c:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201b9e:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201ba0:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201ba2:	00f93023          	sd	a5,0(s2)
    if (flag)
ffffffffc0201ba6:	e20d                	bnez	a2,ffffffffc0201bc8 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201ba8:	60e2                	ld	ra,24(sp)
ffffffffc0201baa:	8522                	mv	a0,s0
ffffffffc0201bac:	6442                	ld	s0,16(sp)
ffffffffc0201bae:	64a2                	ld	s1,8(sp)
ffffffffc0201bb0:	6902                	ld	s2,0(sp)
ffffffffc0201bb2:	6105                	addi	sp,sp,32
ffffffffc0201bb4:	8082                	ret
        intr_disable();
ffffffffc0201bb6:	df9fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
			cur = slobfree;
ffffffffc0201bba:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201bbe:	4605                	li	a2,1
ffffffffc0201bc0:	b7d1                	j	ffffffffc0201b84 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201bc2:	de7fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0201bc6:	b74d                	j	ffffffffc0201b68 <slob_alloc.constprop.0+0x50>
ffffffffc0201bc8:	de1fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
}
ffffffffc0201bcc:	60e2                	ld	ra,24(sp)
ffffffffc0201bce:	8522                	mv	a0,s0
ffffffffc0201bd0:	6442                	ld	s0,16(sp)
ffffffffc0201bd2:	64a2                	ld	s1,8(sp)
ffffffffc0201bd4:	6902                	ld	s2,0(sp)
ffffffffc0201bd6:	6105                	addi	sp,sp,32
ffffffffc0201bd8:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201bda:	6418                	ld	a4,8(s0)
ffffffffc0201bdc:	e798                	sd	a4,8(a5)
ffffffffc0201bde:	b7d1                	j	ffffffffc0201ba2 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201be0:	dcffe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        return 1;
ffffffffc0201be4:	4605                	li	a2,1
ffffffffc0201be6:	bf99                	j	ffffffffc0201b3c <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta)
ffffffffc0201be8:	843e                	mv	s0,a5
ffffffffc0201bea:	87b6                	mv	a5,a3
ffffffffc0201bec:	b745                	j	ffffffffc0201b8c <slob_alloc.constprop.0+0x74>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201bee:	00005697          	auipc	a3,0x5
ffffffffc0201bf2:	b8a68693          	addi	a3,a3,-1142 # ffffffffc0206778 <default_pmm_manager+0x70>
ffffffffc0201bf6:	00004617          	auipc	a2,0x4
ffffffffc0201bfa:	76260613          	addi	a2,a2,1890 # ffffffffc0206358 <commands+0x850>
ffffffffc0201bfe:	06300593          	li	a1,99
ffffffffc0201c02:	00005517          	auipc	a0,0x5
ffffffffc0201c06:	b9650513          	addi	a0,a0,-1130 # ffffffffc0206798 <default_pmm_manager+0x90>
ffffffffc0201c0a:	889fe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0201c0e <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc0201c0e:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc0201c10:	00005517          	auipc	a0,0x5
ffffffffc0201c14:	ba050513          	addi	a0,a0,-1120 # ffffffffc02067b0 <default_pmm_manager+0xa8>
{
ffffffffc0201c18:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc0201c1a:	d7efe0ef          	jal	ra,ffffffffc0200198 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201c1e:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c20:	00005517          	auipc	a0,0x5
ffffffffc0201c24:	ba850513          	addi	a0,a0,-1112 # ffffffffc02067c8 <default_pmm_manager+0xc0>
}
ffffffffc0201c28:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c2a:	d6efe06f          	j	ffffffffc0200198 <cprintf>

ffffffffc0201c2e <kallocated>:

size_t
kallocated(void)
{
	return slob_allocated();
}
ffffffffc0201c2e:	4501                	li	a0,0
ffffffffc0201c30:	8082                	ret

ffffffffc0201c32 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201c32:	1101                	addi	sp,sp,-32
ffffffffc0201c34:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201c36:	6905                	lui	s2,0x1
{
ffffffffc0201c38:	e822                	sd	s0,16(sp)
ffffffffc0201c3a:	ec06                	sd	ra,24(sp)
ffffffffc0201c3c:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201c3e:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8f61>
{
ffffffffc0201c42:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201c44:	04a7f963          	bgeu	a5,a0,ffffffffc0201c96 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201c48:	4561                	li	a0,24
ffffffffc0201c4a:	ecfff0ef          	jal	ra,ffffffffc0201b18 <slob_alloc.constprop.0>
ffffffffc0201c4e:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201c50:	c929                	beqz	a0,ffffffffc0201ca2 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201c52:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201c56:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc0201c58:	00f95763          	bge	s2,a5,ffffffffc0201c66 <kmalloc+0x34>
ffffffffc0201c5c:	6705                	lui	a4,0x1
ffffffffc0201c5e:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201c60:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc0201c62:	fef74ee3          	blt	a4,a5,ffffffffc0201c5e <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201c66:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201c68:	e4dff0ef          	jal	ra,ffffffffc0201ab4 <__slob_get_free_pages.constprop.0>
ffffffffc0201c6c:	e488                	sd	a0,8(s1)
ffffffffc0201c6e:	842a                	mv	s0,a0
	if (bb->pages)
ffffffffc0201c70:	c525                	beqz	a0,ffffffffc0201cd8 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201c72:	100027f3          	csrr	a5,sstatus
ffffffffc0201c76:	8b89                	andi	a5,a5,2
ffffffffc0201c78:	ef8d                	bnez	a5,ffffffffc0201cb2 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201c7a:	000d1797          	auipc	a5,0xd1
ffffffffc0201c7e:	b0e78793          	addi	a5,a5,-1266 # ffffffffc02d2788 <bigblocks>
ffffffffc0201c82:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201c84:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201c86:	e898                	sd	a4,16(s1)
	return __kmalloc(size, 0);
}
ffffffffc0201c88:	60e2                	ld	ra,24(sp)
ffffffffc0201c8a:	8522                	mv	a0,s0
ffffffffc0201c8c:	6442                	ld	s0,16(sp)
ffffffffc0201c8e:	64a2                	ld	s1,8(sp)
ffffffffc0201c90:	6902                	ld	s2,0(sp)
ffffffffc0201c92:	6105                	addi	sp,sp,32
ffffffffc0201c94:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201c96:	0541                	addi	a0,a0,16
ffffffffc0201c98:	e81ff0ef          	jal	ra,ffffffffc0201b18 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201c9c:	01050413          	addi	s0,a0,16
ffffffffc0201ca0:	f565                	bnez	a0,ffffffffc0201c88 <kmalloc+0x56>
ffffffffc0201ca2:	4401                	li	s0,0
}
ffffffffc0201ca4:	60e2                	ld	ra,24(sp)
ffffffffc0201ca6:	8522                	mv	a0,s0
ffffffffc0201ca8:	6442                	ld	s0,16(sp)
ffffffffc0201caa:	64a2                	ld	s1,8(sp)
ffffffffc0201cac:	6902                	ld	s2,0(sp)
ffffffffc0201cae:	6105                	addi	sp,sp,32
ffffffffc0201cb0:	8082                	ret
        intr_disable();
ffffffffc0201cb2:	cfdfe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
		bb->next = bigblocks;
ffffffffc0201cb6:	000d1797          	auipc	a5,0xd1
ffffffffc0201cba:	ad278793          	addi	a5,a5,-1326 # ffffffffc02d2788 <bigblocks>
ffffffffc0201cbe:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201cc0:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201cc2:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201cc4:	ce5fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
		return bb->pages;
ffffffffc0201cc8:	6480                	ld	s0,8(s1)
}
ffffffffc0201cca:	60e2                	ld	ra,24(sp)
ffffffffc0201ccc:	64a2                	ld	s1,8(sp)
ffffffffc0201cce:	8522                	mv	a0,s0
ffffffffc0201cd0:	6442                	ld	s0,16(sp)
ffffffffc0201cd2:	6902                	ld	s2,0(sp)
ffffffffc0201cd4:	6105                	addi	sp,sp,32
ffffffffc0201cd6:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201cd8:	45e1                	li	a1,24
ffffffffc0201cda:	8526                	mv	a0,s1
ffffffffc0201cdc:	d25ff0ef          	jal	ra,ffffffffc0201a00 <slob_free>
	return __kmalloc(size, 0);
ffffffffc0201ce0:	b765                	j	ffffffffc0201c88 <kmalloc+0x56>

ffffffffc0201ce2 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201ce2:	c169                	beqz	a0,ffffffffc0201da4 <kfree+0xc2>
{
ffffffffc0201ce4:	1101                	addi	sp,sp,-32
ffffffffc0201ce6:	e822                	sd	s0,16(sp)
ffffffffc0201ce8:	ec06                	sd	ra,24(sp)
ffffffffc0201cea:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201cec:	03451793          	slli	a5,a0,0x34
ffffffffc0201cf0:	842a                	mv	s0,a0
ffffffffc0201cf2:	e3d9                	bnez	a5,ffffffffc0201d78 <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201cf4:	100027f3          	csrr	a5,sstatus
ffffffffc0201cf8:	8b89                	andi	a5,a5,2
ffffffffc0201cfa:	e7d9                	bnez	a5,ffffffffc0201d88 <kfree+0xa6>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201cfc:	000d1797          	auipc	a5,0xd1
ffffffffc0201d00:	a8c7b783          	ld	a5,-1396(a5) # ffffffffc02d2788 <bigblocks>
    return 0;
ffffffffc0201d04:	4601                	li	a2,0
ffffffffc0201d06:	cbad                	beqz	a5,ffffffffc0201d78 <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201d08:	000d1697          	auipc	a3,0xd1
ffffffffc0201d0c:	a8068693          	addi	a3,a3,-1408 # ffffffffc02d2788 <bigblocks>
ffffffffc0201d10:	a021                	j	ffffffffc0201d18 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201d12:	01048693          	addi	a3,s1,16
ffffffffc0201d16:	c3a5                	beqz	a5,ffffffffc0201d76 <kfree+0x94>
		{
			if (bb->pages == block)
ffffffffc0201d18:	6798                	ld	a4,8(a5)
ffffffffc0201d1a:	84be                	mv	s1,a5
			{
				*last = bb->next;
ffffffffc0201d1c:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc0201d1e:	fe871ae3          	bne	a4,s0,ffffffffc0201d12 <kfree+0x30>
				*last = bb->next;
ffffffffc0201d22:	e29c                	sd	a5,0(a3)
    if (flag)
ffffffffc0201d24:	ee2d                	bnez	a2,ffffffffc0201d9e <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201d26:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201d2a:	4098                	lw	a4,0(s1)
ffffffffc0201d2c:	08f46963          	bltu	s0,a5,ffffffffc0201dbe <kfree+0xdc>
ffffffffc0201d30:	000d1697          	auipc	a3,0xd1
ffffffffc0201d34:	a886b683          	ld	a3,-1400(a3) # ffffffffc02d27b8 <va_pa_offset>
ffffffffc0201d38:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage)
ffffffffc0201d3a:	8031                	srli	s0,s0,0xc
ffffffffc0201d3c:	000d1797          	auipc	a5,0xd1
ffffffffc0201d40:	a647b783          	ld	a5,-1436(a5) # ffffffffc02d27a0 <npage>
ffffffffc0201d44:	06f47163          	bgeu	s0,a5,ffffffffc0201da6 <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d48:	00006517          	auipc	a0,0x6
ffffffffc0201d4c:	47853503          	ld	a0,1144(a0) # ffffffffc02081c0 <nbase>
ffffffffc0201d50:	8c09                	sub	s0,s0,a0
ffffffffc0201d52:	041a                	slli	s0,s0,0x6
	free_pages(kva2page(kva), 1 << order);
ffffffffc0201d54:	000d1517          	auipc	a0,0xd1
ffffffffc0201d58:	a5453503          	ld	a0,-1452(a0) # ffffffffc02d27a8 <pages>
ffffffffc0201d5c:	4585                	li	a1,1
ffffffffc0201d5e:	9522                	add	a0,a0,s0
ffffffffc0201d60:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201d64:	0ea000ef          	jal	ra,ffffffffc0201e4e <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201d68:	6442                	ld	s0,16(sp)
ffffffffc0201d6a:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d6c:	8526                	mv	a0,s1
}
ffffffffc0201d6e:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d70:	45e1                	li	a1,24
}
ffffffffc0201d72:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d74:	b171                	j	ffffffffc0201a00 <slob_free>
ffffffffc0201d76:	e20d                	bnez	a2,ffffffffc0201d98 <kfree+0xb6>
ffffffffc0201d78:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201d7c:	6442                	ld	s0,16(sp)
ffffffffc0201d7e:	60e2                	ld	ra,24(sp)
ffffffffc0201d80:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d82:	4581                	li	a1,0
}
ffffffffc0201d84:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d86:	b9ad                	j	ffffffffc0201a00 <slob_free>
        intr_disable();
ffffffffc0201d88:	c27fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201d8c:	000d1797          	auipc	a5,0xd1
ffffffffc0201d90:	9fc7b783          	ld	a5,-1540(a5) # ffffffffc02d2788 <bigblocks>
        return 1;
ffffffffc0201d94:	4605                	li	a2,1
ffffffffc0201d96:	fbad                	bnez	a5,ffffffffc0201d08 <kfree+0x26>
        intr_enable();
ffffffffc0201d98:	c11fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0201d9c:	bff1                	j	ffffffffc0201d78 <kfree+0x96>
ffffffffc0201d9e:	c0bfe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0201da2:	b751                	j	ffffffffc0201d26 <kfree+0x44>
ffffffffc0201da4:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201da6:	00005617          	auipc	a2,0x5
ffffffffc0201daa:	a6a60613          	addi	a2,a2,-1430 # ffffffffc0206810 <default_pmm_manager+0x108>
ffffffffc0201dae:	06900593          	li	a1,105
ffffffffc0201db2:	00005517          	auipc	a0,0x5
ffffffffc0201db6:	9b650513          	addi	a0,a0,-1610 # ffffffffc0206768 <default_pmm_manager+0x60>
ffffffffc0201dba:	ed8fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201dbe:	86a2                	mv	a3,s0
ffffffffc0201dc0:	00005617          	auipc	a2,0x5
ffffffffc0201dc4:	a2860613          	addi	a2,a2,-1496 # ffffffffc02067e8 <default_pmm_manager+0xe0>
ffffffffc0201dc8:	07700593          	li	a1,119
ffffffffc0201dcc:	00005517          	auipc	a0,0x5
ffffffffc0201dd0:	99c50513          	addi	a0,a0,-1636 # ffffffffc0206768 <default_pmm_manager+0x60>
ffffffffc0201dd4:	ebefe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0201dd8 <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc0201dd8:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201dda:	00005617          	auipc	a2,0x5
ffffffffc0201dde:	a3660613          	addi	a2,a2,-1482 # ffffffffc0206810 <default_pmm_manager+0x108>
ffffffffc0201de2:	06900593          	li	a1,105
ffffffffc0201de6:	00005517          	auipc	a0,0x5
ffffffffc0201dea:	98250513          	addi	a0,a0,-1662 # ffffffffc0206768 <default_pmm_manager+0x60>
pa2page(uintptr_t pa)
ffffffffc0201dee:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201df0:	ea2fe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0201df4 <pte2page.part.0>:
pte2page(pte_t pte)
ffffffffc0201df4:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201df6:	00005617          	auipc	a2,0x5
ffffffffc0201dfa:	a3a60613          	addi	a2,a2,-1478 # ffffffffc0206830 <default_pmm_manager+0x128>
ffffffffc0201dfe:	07f00593          	li	a1,127
ffffffffc0201e02:	00005517          	auipc	a0,0x5
ffffffffc0201e06:	96650513          	addi	a0,a0,-1690 # ffffffffc0206768 <default_pmm_manager+0x60>
pte2page(pte_t pte)
ffffffffc0201e0a:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201e0c:	e86fe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0201e10 <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201e10:	100027f3          	csrr	a5,sstatus
ffffffffc0201e14:	8b89                	andi	a5,a5,2
ffffffffc0201e16:	e799                	bnez	a5,ffffffffc0201e24 <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201e18:	000d1797          	auipc	a5,0xd1
ffffffffc0201e1c:	9987b783          	ld	a5,-1640(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0201e20:	6f9c                	ld	a5,24(a5)
ffffffffc0201e22:	8782                	jr	a5
{
ffffffffc0201e24:	1141                	addi	sp,sp,-16
ffffffffc0201e26:	e406                	sd	ra,8(sp)
ffffffffc0201e28:	e022                	sd	s0,0(sp)
ffffffffc0201e2a:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201e2c:	b83fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201e30:	000d1797          	auipc	a5,0xd1
ffffffffc0201e34:	9807b783          	ld	a5,-1664(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0201e38:	6f9c                	ld	a5,24(a5)
ffffffffc0201e3a:	8522                	mv	a0,s0
ffffffffc0201e3c:	9782                	jalr	a5
ffffffffc0201e3e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201e40:	b69fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201e44:	60a2                	ld	ra,8(sp)
ffffffffc0201e46:	8522                	mv	a0,s0
ffffffffc0201e48:	6402                	ld	s0,0(sp)
ffffffffc0201e4a:	0141                	addi	sp,sp,16
ffffffffc0201e4c:	8082                	ret

ffffffffc0201e4e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201e4e:	100027f3          	csrr	a5,sstatus
ffffffffc0201e52:	8b89                	andi	a5,a5,2
ffffffffc0201e54:	e799                	bnez	a5,ffffffffc0201e62 <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201e56:	000d1797          	auipc	a5,0xd1
ffffffffc0201e5a:	95a7b783          	ld	a5,-1702(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0201e5e:	739c                	ld	a5,32(a5)
ffffffffc0201e60:	8782                	jr	a5
{
ffffffffc0201e62:	1101                	addi	sp,sp,-32
ffffffffc0201e64:	ec06                	sd	ra,24(sp)
ffffffffc0201e66:	e822                	sd	s0,16(sp)
ffffffffc0201e68:	e426                	sd	s1,8(sp)
ffffffffc0201e6a:	842a                	mv	s0,a0
ffffffffc0201e6c:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201e6e:	b41fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201e72:	000d1797          	auipc	a5,0xd1
ffffffffc0201e76:	93e7b783          	ld	a5,-1730(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0201e7a:	739c                	ld	a5,32(a5)
ffffffffc0201e7c:	85a6                	mv	a1,s1
ffffffffc0201e7e:	8522                	mv	a0,s0
ffffffffc0201e80:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201e82:	6442                	ld	s0,16(sp)
ffffffffc0201e84:	60e2                	ld	ra,24(sp)
ffffffffc0201e86:	64a2                	ld	s1,8(sp)
ffffffffc0201e88:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201e8a:	b1ffe06f          	j	ffffffffc02009a8 <intr_enable>

ffffffffc0201e8e <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201e8e:	100027f3          	csrr	a5,sstatus
ffffffffc0201e92:	8b89                	andi	a5,a5,2
ffffffffc0201e94:	e799                	bnez	a5,ffffffffc0201ea2 <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201e96:	000d1797          	auipc	a5,0xd1
ffffffffc0201e9a:	91a7b783          	ld	a5,-1766(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0201e9e:	779c                	ld	a5,40(a5)
ffffffffc0201ea0:	8782                	jr	a5
{
ffffffffc0201ea2:	1141                	addi	sp,sp,-16
ffffffffc0201ea4:	e406                	sd	ra,8(sp)
ffffffffc0201ea6:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201ea8:	b07fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201eac:	000d1797          	auipc	a5,0xd1
ffffffffc0201eb0:	9047b783          	ld	a5,-1788(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0201eb4:	779c                	ld	a5,40(a5)
ffffffffc0201eb6:	9782                	jalr	a5
ffffffffc0201eb8:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201eba:	aeffe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201ebe:	60a2                	ld	ra,8(sp)
ffffffffc0201ec0:	8522                	mv	a0,s0
ffffffffc0201ec2:	6402                	ld	s0,0(sp)
ffffffffc0201ec4:	0141                	addi	sp,sp,16
ffffffffc0201ec6:	8082                	ret

ffffffffc0201ec8 <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201ec8:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201ecc:	1ff7f793          	andi	a5,a5,511
{
ffffffffc0201ed0:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201ed2:	078e                	slli	a5,a5,0x3
{
ffffffffc0201ed4:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201ed6:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc0201eda:	6094                	ld	a3,0(s1)
{
ffffffffc0201edc:	f04a                	sd	s2,32(sp)
ffffffffc0201ede:	ec4e                	sd	s3,24(sp)
ffffffffc0201ee0:	e852                	sd	s4,16(sp)
ffffffffc0201ee2:	fc06                	sd	ra,56(sp)
ffffffffc0201ee4:	f822                	sd	s0,48(sp)
ffffffffc0201ee6:	e456                	sd	s5,8(sp)
ffffffffc0201ee8:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc0201eea:	0016f793          	andi	a5,a3,1
{
ffffffffc0201eee:	892e                	mv	s2,a1
ffffffffc0201ef0:	8a32                	mv	s4,a2
ffffffffc0201ef2:	000d1997          	auipc	s3,0xd1
ffffffffc0201ef6:	8ae98993          	addi	s3,s3,-1874 # ffffffffc02d27a0 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc0201efa:	efbd                	bnez	a5,ffffffffc0201f78 <get_pte+0xb0>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201efc:	14060c63          	beqz	a2,ffffffffc0202054 <get_pte+0x18c>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201f00:	100027f3          	csrr	a5,sstatus
ffffffffc0201f04:	8b89                	andi	a5,a5,2
ffffffffc0201f06:	14079963          	bnez	a5,ffffffffc0202058 <get_pte+0x190>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201f0a:	000d1797          	auipc	a5,0xd1
ffffffffc0201f0e:	8a67b783          	ld	a5,-1882(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0201f12:	6f9c                	ld	a5,24(a5)
ffffffffc0201f14:	4505                	li	a0,1
ffffffffc0201f16:	9782                	jalr	a5
ffffffffc0201f18:	842a                	mv	s0,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201f1a:	12040d63          	beqz	s0,ffffffffc0202054 <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0201f1e:	000d1b17          	auipc	s6,0xd1
ffffffffc0201f22:	88ab0b13          	addi	s6,s6,-1910 # ffffffffc02d27a8 <pages>
ffffffffc0201f26:	000b3503          	ld	a0,0(s6)
ffffffffc0201f2a:	00080ab7          	lui	s5,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f2e:	000d1997          	auipc	s3,0xd1
ffffffffc0201f32:	87298993          	addi	s3,s3,-1934 # ffffffffc02d27a0 <npage>
ffffffffc0201f36:	40a40533          	sub	a0,s0,a0
ffffffffc0201f3a:	8519                	srai	a0,a0,0x6
ffffffffc0201f3c:	9556                	add	a0,a0,s5
ffffffffc0201f3e:	0009b703          	ld	a4,0(s3)
ffffffffc0201f42:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201f46:	4685                	li	a3,1
ffffffffc0201f48:	c014                	sw	a3,0(s0)
ffffffffc0201f4a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f4c:	0532                	slli	a0,a0,0xc
ffffffffc0201f4e:	16e7f763          	bgeu	a5,a4,ffffffffc02020bc <get_pte+0x1f4>
ffffffffc0201f52:	000d1797          	auipc	a5,0xd1
ffffffffc0201f56:	8667b783          	ld	a5,-1946(a5) # ffffffffc02d27b8 <va_pa_offset>
ffffffffc0201f5a:	6605                	lui	a2,0x1
ffffffffc0201f5c:	4581                	li	a1,0
ffffffffc0201f5e:	953e                	add	a0,a0,a5
ffffffffc0201f60:	117030ef          	jal	ra,ffffffffc0205876 <memset>
    return page - pages + nbase;
ffffffffc0201f64:	000b3683          	ld	a3,0(s6)
ffffffffc0201f68:	40d406b3          	sub	a3,s0,a3
ffffffffc0201f6c:	8699                	srai	a3,a3,0x6
ffffffffc0201f6e:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201f70:	06aa                	slli	a3,a3,0xa
ffffffffc0201f72:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201f76:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201f78:	77fd                	lui	a5,0xfffff
ffffffffc0201f7a:	068a                	slli	a3,a3,0x2
ffffffffc0201f7c:	0009b703          	ld	a4,0(s3)
ffffffffc0201f80:	8efd                	and	a3,a3,a5
ffffffffc0201f82:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201f86:	10e7ff63          	bgeu	a5,a4,ffffffffc02020a4 <get_pte+0x1dc>
ffffffffc0201f8a:	000d1a97          	auipc	s5,0xd1
ffffffffc0201f8e:	82ea8a93          	addi	s5,s5,-2002 # ffffffffc02d27b8 <va_pa_offset>
ffffffffc0201f92:	000ab403          	ld	s0,0(s5)
ffffffffc0201f96:	01595793          	srli	a5,s2,0x15
ffffffffc0201f9a:	1ff7f793          	andi	a5,a5,511
ffffffffc0201f9e:	96a2                	add	a3,a3,s0
ffffffffc0201fa0:	00379413          	slli	s0,a5,0x3
ffffffffc0201fa4:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V))
ffffffffc0201fa6:	6014                	ld	a3,0(s0)
ffffffffc0201fa8:	0016f793          	andi	a5,a3,1
ffffffffc0201fac:	ebad                	bnez	a5,ffffffffc020201e <get_pte+0x156>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201fae:	0a0a0363          	beqz	s4,ffffffffc0202054 <get_pte+0x18c>
ffffffffc0201fb2:	100027f3          	csrr	a5,sstatus
ffffffffc0201fb6:	8b89                	andi	a5,a5,2
ffffffffc0201fb8:	efcd                	bnez	a5,ffffffffc0202072 <get_pte+0x1aa>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201fba:	000d0797          	auipc	a5,0xd0
ffffffffc0201fbe:	7f67b783          	ld	a5,2038(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0201fc2:	6f9c                	ld	a5,24(a5)
ffffffffc0201fc4:	4505                	li	a0,1
ffffffffc0201fc6:	9782                	jalr	a5
ffffffffc0201fc8:	84aa                	mv	s1,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201fca:	c4c9                	beqz	s1,ffffffffc0202054 <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0201fcc:	000d0b17          	auipc	s6,0xd0
ffffffffc0201fd0:	7dcb0b13          	addi	s6,s6,2012 # ffffffffc02d27a8 <pages>
ffffffffc0201fd4:	000b3503          	ld	a0,0(s6)
ffffffffc0201fd8:	00080a37          	lui	s4,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201fdc:	0009b703          	ld	a4,0(s3)
ffffffffc0201fe0:	40a48533          	sub	a0,s1,a0
ffffffffc0201fe4:	8519                	srai	a0,a0,0x6
ffffffffc0201fe6:	9552                	add	a0,a0,s4
ffffffffc0201fe8:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201fec:	4685                	li	a3,1
ffffffffc0201fee:	c094                	sw	a3,0(s1)
ffffffffc0201ff0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ff2:	0532                	slli	a0,a0,0xc
ffffffffc0201ff4:	0ee7f163          	bgeu	a5,a4,ffffffffc02020d6 <get_pte+0x20e>
ffffffffc0201ff8:	000ab783          	ld	a5,0(s5)
ffffffffc0201ffc:	6605                	lui	a2,0x1
ffffffffc0201ffe:	4581                	li	a1,0
ffffffffc0202000:	953e                	add	a0,a0,a5
ffffffffc0202002:	075030ef          	jal	ra,ffffffffc0205876 <memset>
    return page - pages + nbase;
ffffffffc0202006:	000b3683          	ld	a3,0(s6)
ffffffffc020200a:	40d486b3          	sub	a3,s1,a3
ffffffffc020200e:	8699                	srai	a3,a3,0x6
ffffffffc0202010:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202012:	06aa                	slli	a3,a3,0xa
ffffffffc0202014:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202018:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020201a:	0009b703          	ld	a4,0(s3)
ffffffffc020201e:	068a                	slli	a3,a3,0x2
ffffffffc0202020:	757d                	lui	a0,0xfffff
ffffffffc0202022:	8ee9                	and	a3,a3,a0
ffffffffc0202024:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202028:	06e7f263          	bgeu	a5,a4,ffffffffc020208c <get_pte+0x1c4>
ffffffffc020202c:	000ab503          	ld	a0,0(s5)
ffffffffc0202030:	00c95913          	srli	s2,s2,0xc
ffffffffc0202034:	1ff97913          	andi	s2,s2,511
ffffffffc0202038:	96aa                	add	a3,a3,a0
ffffffffc020203a:	00391513          	slli	a0,s2,0x3
ffffffffc020203e:	9536                	add	a0,a0,a3
}
ffffffffc0202040:	70e2                	ld	ra,56(sp)
ffffffffc0202042:	7442                	ld	s0,48(sp)
ffffffffc0202044:	74a2                	ld	s1,40(sp)
ffffffffc0202046:	7902                	ld	s2,32(sp)
ffffffffc0202048:	69e2                	ld	s3,24(sp)
ffffffffc020204a:	6a42                	ld	s4,16(sp)
ffffffffc020204c:	6aa2                	ld	s5,8(sp)
ffffffffc020204e:	6b02                	ld	s6,0(sp)
ffffffffc0202050:	6121                	addi	sp,sp,64
ffffffffc0202052:	8082                	ret
            return NULL;
ffffffffc0202054:	4501                	li	a0,0
ffffffffc0202056:	b7ed                	j	ffffffffc0202040 <get_pte+0x178>
        intr_disable();
ffffffffc0202058:	957fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020205c:	000d0797          	auipc	a5,0xd0
ffffffffc0202060:	7547b783          	ld	a5,1876(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0202064:	6f9c                	ld	a5,24(a5)
ffffffffc0202066:	4505                	li	a0,1
ffffffffc0202068:	9782                	jalr	a5
ffffffffc020206a:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020206c:	93dfe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202070:	b56d                	j	ffffffffc0201f1a <get_pte+0x52>
        intr_disable();
ffffffffc0202072:	93dfe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc0202076:	000d0797          	auipc	a5,0xd0
ffffffffc020207a:	73a7b783          	ld	a5,1850(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc020207e:	6f9c                	ld	a5,24(a5)
ffffffffc0202080:	4505                	li	a0,1
ffffffffc0202082:	9782                	jalr	a5
ffffffffc0202084:	84aa                	mv	s1,a0
        intr_enable();
ffffffffc0202086:	923fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc020208a:	b781                	j	ffffffffc0201fca <get_pte+0x102>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020208c:	00004617          	auipc	a2,0x4
ffffffffc0202090:	6b460613          	addi	a2,a2,1716 # ffffffffc0206740 <default_pmm_manager+0x38>
ffffffffc0202094:	0fa00593          	li	a1,250
ffffffffc0202098:	00004517          	auipc	a0,0x4
ffffffffc020209c:	7c050513          	addi	a0,a0,1984 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc02020a0:	bf2fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02020a4:	00004617          	auipc	a2,0x4
ffffffffc02020a8:	69c60613          	addi	a2,a2,1692 # ffffffffc0206740 <default_pmm_manager+0x38>
ffffffffc02020ac:	0ed00593          	li	a1,237
ffffffffc02020b0:	00004517          	auipc	a0,0x4
ffffffffc02020b4:	7a850513          	addi	a0,a0,1960 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc02020b8:	bdafe0ef          	jal	ra,ffffffffc0200492 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020bc:	86aa                	mv	a3,a0
ffffffffc02020be:	00004617          	auipc	a2,0x4
ffffffffc02020c2:	68260613          	addi	a2,a2,1666 # ffffffffc0206740 <default_pmm_manager+0x38>
ffffffffc02020c6:	0e900593          	li	a1,233
ffffffffc02020ca:	00004517          	auipc	a0,0x4
ffffffffc02020ce:	78e50513          	addi	a0,a0,1934 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc02020d2:	bc0fe0ef          	jal	ra,ffffffffc0200492 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020d6:	86aa                	mv	a3,a0
ffffffffc02020d8:	00004617          	auipc	a2,0x4
ffffffffc02020dc:	66860613          	addi	a2,a2,1640 # ffffffffc0206740 <default_pmm_manager+0x38>
ffffffffc02020e0:	0f700593          	li	a1,247
ffffffffc02020e4:	00004517          	auipc	a0,0x4
ffffffffc02020e8:	77450513          	addi	a0,a0,1908 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc02020ec:	ba6fe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02020f0 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc02020f0:	1141                	addi	sp,sp,-16
ffffffffc02020f2:	e022                	sd	s0,0(sp)
ffffffffc02020f4:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02020f6:	4601                	li	a2,0
{
ffffffffc02020f8:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02020fa:	dcfff0ef          	jal	ra,ffffffffc0201ec8 <get_pte>
    if (ptep_store != NULL)
ffffffffc02020fe:	c011                	beqz	s0,ffffffffc0202102 <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc0202100:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202102:	c511                	beqz	a0,ffffffffc020210e <get_page+0x1e>
ffffffffc0202104:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202106:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202108:	0017f713          	andi	a4,a5,1
ffffffffc020210c:	e709                	bnez	a4,ffffffffc0202116 <get_page+0x26>
}
ffffffffc020210e:	60a2                	ld	ra,8(sp)
ffffffffc0202110:	6402                	ld	s0,0(sp)
ffffffffc0202112:	0141                	addi	sp,sp,16
ffffffffc0202114:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202116:	078a                	slli	a5,a5,0x2
ffffffffc0202118:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020211a:	000d0717          	auipc	a4,0xd0
ffffffffc020211e:	68673703          	ld	a4,1670(a4) # ffffffffc02d27a0 <npage>
ffffffffc0202122:	00e7ff63          	bgeu	a5,a4,ffffffffc0202140 <get_page+0x50>
ffffffffc0202126:	60a2                	ld	ra,8(sp)
ffffffffc0202128:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc020212a:	fff80537          	lui	a0,0xfff80
ffffffffc020212e:	97aa                	add	a5,a5,a0
ffffffffc0202130:	079a                	slli	a5,a5,0x6
ffffffffc0202132:	000d0517          	auipc	a0,0xd0
ffffffffc0202136:	67653503          	ld	a0,1654(a0) # ffffffffc02d27a8 <pages>
ffffffffc020213a:	953e                	add	a0,a0,a5
ffffffffc020213c:	0141                	addi	sp,sp,16
ffffffffc020213e:	8082                	ret
ffffffffc0202140:	c99ff0ef          	jal	ra,ffffffffc0201dd8 <pa2page.part.0>

ffffffffc0202144 <unmap_range>:
        tlb_invalidate(pgdir, la); //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc0202144:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202146:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc020214a:	f486                	sd	ra,104(sp)
ffffffffc020214c:	f0a2                	sd	s0,96(sp)
ffffffffc020214e:	eca6                	sd	s1,88(sp)
ffffffffc0202150:	e8ca                	sd	s2,80(sp)
ffffffffc0202152:	e4ce                	sd	s3,72(sp)
ffffffffc0202154:	e0d2                	sd	s4,64(sp)
ffffffffc0202156:	fc56                	sd	s5,56(sp)
ffffffffc0202158:	f85a                	sd	s6,48(sp)
ffffffffc020215a:	f45e                	sd	s7,40(sp)
ffffffffc020215c:	f062                	sd	s8,32(sp)
ffffffffc020215e:	ec66                	sd	s9,24(sp)
ffffffffc0202160:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202162:	17d2                	slli	a5,a5,0x34
ffffffffc0202164:	e3ed                	bnez	a5,ffffffffc0202246 <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc0202166:	002007b7          	lui	a5,0x200
ffffffffc020216a:	842e                	mv	s0,a1
ffffffffc020216c:	0ef5ed63          	bltu	a1,a5,ffffffffc0202266 <unmap_range+0x122>
ffffffffc0202170:	8932                	mv	s2,a2
ffffffffc0202172:	0ec5fa63          	bgeu	a1,a2,ffffffffc0202266 <unmap_range+0x122>
ffffffffc0202176:	4785                	li	a5,1
ffffffffc0202178:	07fe                	slli	a5,a5,0x1f
ffffffffc020217a:	0ec7e663          	bltu	a5,a2,ffffffffc0202266 <unmap_range+0x122>
ffffffffc020217e:	89aa                	mv	s3,a0
        }
        if (*ptep != 0)
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0202180:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage)
ffffffffc0202182:	000d0c97          	auipc	s9,0xd0
ffffffffc0202186:	61ec8c93          	addi	s9,s9,1566 # ffffffffc02d27a0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020218a:	000d0c17          	auipc	s8,0xd0
ffffffffc020218e:	61ec0c13          	addi	s8,s8,1566 # ffffffffc02d27a8 <pages>
ffffffffc0202192:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc0202196:	000d0d17          	auipc	s10,0xd0
ffffffffc020219a:	61ad0d13          	addi	s10,s10,1562 # ffffffffc02d27b0 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020219e:	00200b37          	lui	s6,0x200
ffffffffc02021a2:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02021a6:	4601                	li	a2,0
ffffffffc02021a8:	85a2                	mv	a1,s0
ffffffffc02021aa:	854e                	mv	a0,s3
ffffffffc02021ac:	d1dff0ef          	jal	ra,ffffffffc0201ec8 <get_pte>
ffffffffc02021b0:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc02021b2:	cd29                	beqz	a0,ffffffffc020220c <unmap_range+0xc8>
        if (*ptep != 0)
ffffffffc02021b4:	611c                	ld	a5,0(a0)
ffffffffc02021b6:	e395                	bnez	a5,ffffffffc02021da <unmap_range+0x96>
        start += PGSIZE;
ffffffffc02021b8:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02021ba:	ff2466e3          	bltu	s0,s2,ffffffffc02021a6 <unmap_range+0x62>
}
ffffffffc02021be:	70a6                	ld	ra,104(sp)
ffffffffc02021c0:	7406                	ld	s0,96(sp)
ffffffffc02021c2:	64e6                	ld	s1,88(sp)
ffffffffc02021c4:	6946                	ld	s2,80(sp)
ffffffffc02021c6:	69a6                	ld	s3,72(sp)
ffffffffc02021c8:	6a06                	ld	s4,64(sp)
ffffffffc02021ca:	7ae2                	ld	s5,56(sp)
ffffffffc02021cc:	7b42                	ld	s6,48(sp)
ffffffffc02021ce:	7ba2                	ld	s7,40(sp)
ffffffffc02021d0:	7c02                	ld	s8,32(sp)
ffffffffc02021d2:	6ce2                	ld	s9,24(sp)
ffffffffc02021d4:	6d42                	ld	s10,16(sp)
ffffffffc02021d6:	6165                	addi	sp,sp,112
ffffffffc02021d8:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc02021da:	0017f713          	andi	a4,a5,1
ffffffffc02021de:	df69                	beqz	a4,ffffffffc02021b8 <unmap_range+0x74>
    if (PPN(pa) >= npage)
ffffffffc02021e0:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc02021e4:	078a                	slli	a5,a5,0x2
ffffffffc02021e6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02021e8:	08e7ff63          	bgeu	a5,a4,ffffffffc0202286 <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc02021ec:	000c3503          	ld	a0,0(s8)
ffffffffc02021f0:	97de                	add	a5,a5,s7
ffffffffc02021f2:	079a                	slli	a5,a5,0x6
ffffffffc02021f4:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02021f6:	411c                	lw	a5,0(a0)
ffffffffc02021f8:	fff7871b          	addiw	a4,a5,-1
ffffffffc02021fc:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02021fe:	cf11                	beqz	a4,ffffffffc020221a <unmap_range+0xd6>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc0202200:	0004b023          	sd	zero,0(s1)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202204:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0202208:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc020220a:	bf45                	j	ffffffffc02021ba <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020220c:	945a                	add	s0,s0,s6
ffffffffc020220e:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0202212:	d455                	beqz	s0,ffffffffc02021be <unmap_range+0x7a>
ffffffffc0202214:	f92469e3          	bltu	s0,s2,ffffffffc02021a6 <unmap_range+0x62>
ffffffffc0202218:	b75d                	j	ffffffffc02021be <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020221a:	100027f3          	csrr	a5,sstatus
ffffffffc020221e:	8b89                	andi	a5,a5,2
ffffffffc0202220:	e799                	bnez	a5,ffffffffc020222e <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc0202222:	000d3783          	ld	a5,0(s10)
ffffffffc0202226:	4585                	li	a1,1
ffffffffc0202228:	739c                	ld	a5,32(a5)
ffffffffc020222a:	9782                	jalr	a5
    if (flag)
ffffffffc020222c:	bfd1                	j	ffffffffc0202200 <unmap_range+0xbc>
ffffffffc020222e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202230:	f7efe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc0202234:	000d3783          	ld	a5,0(s10)
ffffffffc0202238:	6522                	ld	a0,8(sp)
ffffffffc020223a:	4585                	li	a1,1
ffffffffc020223c:	739c                	ld	a5,32(a5)
ffffffffc020223e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202240:	f68fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202244:	bf75                	j	ffffffffc0202200 <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202246:	00004697          	auipc	a3,0x4
ffffffffc020224a:	62268693          	addi	a3,a3,1570 # ffffffffc0206868 <default_pmm_manager+0x160>
ffffffffc020224e:	00004617          	auipc	a2,0x4
ffffffffc0202252:	10a60613          	addi	a2,a2,266 # ffffffffc0206358 <commands+0x850>
ffffffffc0202256:	12200593          	li	a1,290
ffffffffc020225a:	00004517          	auipc	a0,0x4
ffffffffc020225e:	5fe50513          	addi	a0,a0,1534 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0202262:	a30fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202266:	00004697          	auipc	a3,0x4
ffffffffc020226a:	63268693          	addi	a3,a3,1586 # ffffffffc0206898 <default_pmm_manager+0x190>
ffffffffc020226e:	00004617          	auipc	a2,0x4
ffffffffc0202272:	0ea60613          	addi	a2,a2,234 # ffffffffc0206358 <commands+0x850>
ffffffffc0202276:	12300593          	li	a1,291
ffffffffc020227a:	00004517          	auipc	a0,0x4
ffffffffc020227e:	5de50513          	addi	a0,a0,1502 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0202282:	a10fe0ef          	jal	ra,ffffffffc0200492 <__panic>
ffffffffc0202286:	b53ff0ef          	jal	ra,ffffffffc0201dd8 <pa2page.part.0>

ffffffffc020228a <exit_range>:
{
ffffffffc020228a:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020228c:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0202290:	fc86                	sd	ra,120(sp)
ffffffffc0202292:	f8a2                	sd	s0,112(sp)
ffffffffc0202294:	f4a6                	sd	s1,104(sp)
ffffffffc0202296:	f0ca                	sd	s2,96(sp)
ffffffffc0202298:	ecce                	sd	s3,88(sp)
ffffffffc020229a:	e8d2                	sd	s4,80(sp)
ffffffffc020229c:	e4d6                	sd	s5,72(sp)
ffffffffc020229e:	e0da                	sd	s6,64(sp)
ffffffffc02022a0:	fc5e                	sd	s7,56(sp)
ffffffffc02022a2:	f862                	sd	s8,48(sp)
ffffffffc02022a4:	f466                	sd	s9,40(sp)
ffffffffc02022a6:	f06a                	sd	s10,32(sp)
ffffffffc02022a8:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022aa:	17d2                	slli	a5,a5,0x34
ffffffffc02022ac:	20079a63          	bnez	a5,ffffffffc02024c0 <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc02022b0:	002007b7          	lui	a5,0x200
ffffffffc02022b4:	24f5e463          	bltu	a1,a5,ffffffffc02024fc <exit_range+0x272>
ffffffffc02022b8:	8ab2                	mv	s5,a2
ffffffffc02022ba:	24c5f163          	bgeu	a1,a2,ffffffffc02024fc <exit_range+0x272>
ffffffffc02022be:	4785                	li	a5,1
ffffffffc02022c0:	07fe                	slli	a5,a5,0x1f
ffffffffc02022c2:	22c7ed63          	bltu	a5,a2,ffffffffc02024fc <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02022c6:	c00009b7          	lui	s3,0xc0000
ffffffffc02022ca:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02022ce:	ffe00937          	lui	s2,0xffe00
ffffffffc02022d2:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc02022d6:	5cfd                	li	s9,-1
ffffffffc02022d8:	8c2a                	mv	s8,a0
ffffffffc02022da:	0125f933          	and	s2,a1,s2
ffffffffc02022de:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage)
ffffffffc02022e0:	000d0d17          	auipc	s10,0xd0
ffffffffc02022e4:	4c0d0d13          	addi	s10,s10,1216 # ffffffffc02d27a0 <npage>
    return KADDR(page2pa(page));
ffffffffc02022e8:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc02022ec:	000d0717          	auipc	a4,0xd0
ffffffffc02022f0:	4bc70713          	addi	a4,a4,1212 # ffffffffc02d27a8 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc02022f4:	000d0d97          	auipc	s11,0xd0
ffffffffc02022f8:	4bcd8d93          	addi	s11,s11,1212 # ffffffffc02d27b0 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02022fc:	c0000437          	lui	s0,0xc0000
ffffffffc0202300:	944e                	add	s0,s0,s3
ffffffffc0202302:	8079                	srli	s0,s0,0x1e
ffffffffc0202304:	1ff47413          	andi	s0,s0,511
ffffffffc0202308:	040e                	slli	s0,s0,0x3
ffffffffc020230a:	9462                	add	s0,s0,s8
ffffffffc020230c:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_matrix_out_size+0xffffffffbfff38d8>
        if (pde1 & PTE_V)
ffffffffc0202310:	001a7793          	andi	a5,s4,1
ffffffffc0202314:	eb99                	bnez	a5,ffffffffc020232a <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc0202316:	12098463          	beqz	s3,ffffffffc020243e <exit_range+0x1b4>
ffffffffc020231a:	400007b7          	lui	a5,0x40000
ffffffffc020231e:	97ce                	add	a5,a5,s3
ffffffffc0202320:	894e                	mv	s2,s3
ffffffffc0202322:	1159fe63          	bgeu	s3,s5,ffffffffc020243e <exit_range+0x1b4>
ffffffffc0202326:	89be                	mv	s3,a5
ffffffffc0202328:	bfd1                	j	ffffffffc02022fc <exit_range+0x72>
    if (PPN(pa) >= npage)
ffffffffc020232a:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc020232e:	0a0a                	slli	s4,s4,0x2
ffffffffc0202330:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage)
ffffffffc0202334:	1cfa7263          	bgeu	s4,a5,ffffffffc02024f8 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202338:	fff80637          	lui	a2,0xfff80
ffffffffc020233c:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc020233e:	000806b7          	lui	a3,0x80
ffffffffc0202342:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0202344:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0202348:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc020234a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020234c:	18f5fa63          	bgeu	a1,a5,ffffffffc02024e0 <exit_range+0x256>
ffffffffc0202350:	000d0817          	auipc	a6,0xd0
ffffffffc0202354:	46880813          	addi	a6,a6,1128 # ffffffffc02d27b8 <va_pa_offset>
ffffffffc0202358:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc020235c:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc020235e:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc0202362:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc0202364:	00080337          	lui	t1,0x80
ffffffffc0202368:	6885                	lui	a7,0x1
ffffffffc020236a:	a819                	j	ffffffffc0202380 <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc020236c:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc020236e:	002007b7          	lui	a5,0x200
ffffffffc0202372:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202374:	08090c63          	beqz	s2,ffffffffc020240c <exit_range+0x182>
ffffffffc0202378:	09397a63          	bgeu	s2,s3,ffffffffc020240c <exit_range+0x182>
ffffffffc020237c:	0f597063          	bgeu	s2,s5,ffffffffc020245c <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0202380:	01595493          	srli	s1,s2,0x15
ffffffffc0202384:	1ff4f493          	andi	s1,s1,511
ffffffffc0202388:	048e                	slli	s1,s1,0x3
ffffffffc020238a:	94da                	add	s1,s1,s6
ffffffffc020238c:	609c                	ld	a5,0(s1)
                if (pde0 & PTE_V)
ffffffffc020238e:	0017f693          	andi	a3,a5,1
ffffffffc0202392:	dee9                	beqz	a3,ffffffffc020236c <exit_range+0xe2>
    if (PPN(pa) >= npage)
ffffffffc0202394:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202398:	078a                	slli	a5,a5,0x2
ffffffffc020239a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020239c:	14b7fe63          	bgeu	a5,a1,ffffffffc02024f8 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02023a0:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc02023a2:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc02023a6:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc02023aa:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02023ae:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02023b0:	12bef863          	bgeu	t4,a1,ffffffffc02024e0 <exit_range+0x256>
ffffffffc02023b4:	00083783          	ld	a5,0(a6)
ffffffffc02023b8:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc02023ba:	011685b3          	add	a1,a3,a7
                        if (pt[i] & PTE_V)
ffffffffc02023be:	629c                	ld	a5,0(a3)
ffffffffc02023c0:	8b85                	andi	a5,a5,1
ffffffffc02023c2:	f7d5                	bnez	a5,ffffffffc020236e <exit_range+0xe4>
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc02023c4:	06a1                	addi	a3,a3,8
ffffffffc02023c6:	fed59ce3          	bne	a1,a3,ffffffffc02023be <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc02023ca:	631c                	ld	a5,0(a4)
ffffffffc02023cc:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02023ce:	100027f3          	csrr	a5,sstatus
ffffffffc02023d2:	8b89                	andi	a5,a5,2
ffffffffc02023d4:	e7d9                	bnez	a5,ffffffffc0202462 <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc02023d6:	000db783          	ld	a5,0(s11)
ffffffffc02023da:	4585                	li	a1,1
ffffffffc02023dc:	e032                	sd	a2,0(sp)
ffffffffc02023de:	739c                	ld	a5,32(a5)
ffffffffc02023e0:	9782                	jalr	a5
    if (flag)
ffffffffc02023e2:	6602                	ld	a2,0(sp)
ffffffffc02023e4:	000d0817          	auipc	a6,0xd0
ffffffffc02023e8:	3d480813          	addi	a6,a6,980 # ffffffffc02d27b8 <va_pa_offset>
ffffffffc02023ec:	fff80e37          	lui	t3,0xfff80
ffffffffc02023f0:	00080337          	lui	t1,0x80
ffffffffc02023f4:	6885                	lui	a7,0x1
ffffffffc02023f6:	000d0717          	auipc	a4,0xd0
ffffffffc02023fa:	3b270713          	addi	a4,a4,946 # ffffffffc02d27a8 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc02023fe:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc0202402:	002007b7          	lui	a5,0x200
ffffffffc0202406:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202408:	f60918e3          	bnez	s2,ffffffffc0202378 <exit_range+0xee>
            if (free_pd0)
ffffffffc020240c:	f00b85e3          	beqz	s7,ffffffffc0202316 <exit_range+0x8c>
    if (PPN(pa) >= npage)
ffffffffc0202410:	000d3783          	ld	a5,0(s10)
ffffffffc0202414:	0efa7263          	bgeu	s4,a5,ffffffffc02024f8 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202418:	6308                	ld	a0,0(a4)
ffffffffc020241a:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020241c:	100027f3          	csrr	a5,sstatus
ffffffffc0202420:	8b89                	andi	a5,a5,2
ffffffffc0202422:	efad                	bnez	a5,ffffffffc020249c <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc0202424:	000db783          	ld	a5,0(s11)
ffffffffc0202428:	4585                	li	a1,1
ffffffffc020242a:	739c                	ld	a5,32(a5)
ffffffffc020242c:	9782                	jalr	a5
ffffffffc020242e:	000d0717          	auipc	a4,0xd0
ffffffffc0202432:	37a70713          	addi	a4,a4,890 # ffffffffc02d27a8 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202436:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc020243a:	ee0990e3          	bnez	s3,ffffffffc020231a <exit_range+0x90>
}
ffffffffc020243e:	70e6                	ld	ra,120(sp)
ffffffffc0202440:	7446                	ld	s0,112(sp)
ffffffffc0202442:	74a6                	ld	s1,104(sp)
ffffffffc0202444:	7906                	ld	s2,96(sp)
ffffffffc0202446:	69e6                	ld	s3,88(sp)
ffffffffc0202448:	6a46                	ld	s4,80(sp)
ffffffffc020244a:	6aa6                	ld	s5,72(sp)
ffffffffc020244c:	6b06                	ld	s6,64(sp)
ffffffffc020244e:	7be2                	ld	s7,56(sp)
ffffffffc0202450:	7c42                	ld	s8,48(sp)
ffffffffc0202452:	7ca2                	ld	s9,40(sp)
ffffffffc0202454:	7d02                	ld	s10,32(sp)
ffffffffc0202456:	6de2                	ld	s11,24(sp)
ffffffffc0202458:	6109                	addi	sp,sp,128
ffffffffc020245a:	8082                	ret
            if (free_pd0)
ffffffffc020245c:	ea0b8fe3          	beqz	s7,ffffffffc020231a <exit_range+0x90>
ffffffffc0202460:	bf45                	j	ffffffffc0202410 <exit_range+0x186>
ffffffffc0202462:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc0202464:	e42a                	sd	a0,8(sp)
ffffffffc0202466:	d48fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020246a:	000db783          	ld	a5,0(s11)
ffffffffc020246e:	6522                	ld	a0,8(sp)
ffffffffc0202470:	4585                	li	a1,1
ffffffffc0202472:	739c                	ld	a5,32(a5)
ffffffffc0202474:	9782                	jalr	a5
        intr_enable();
ffffffffc0202476:	d32fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc020247a:	6602                	ld	a2,0(sp)
ffffffffc020247c:	000d0717          	auipc	a4,0xd0
ffffffffc0202480:	32c70713          	addi	a4,a4,812 # ffffffffc02d27a8 <pages>
ffffffffc0202484:	6885                	lui	a7,0x1
ffffffffc0202486:	00080337          	lui	t1,0x80
ffffffffc020248a:	fff80e37          	lui	t3,0xfff80
ffffffffc020248e:	000d0817          	auipc	a6,0xd0
ffffffffc0202492:	32a80813          	addi	a6,a6,810 # ffffffffc02d27b8 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202496:	0004b023          	sd	zero,0(s1)
ffffffffc020249a:	b7a5                	j	ffffffffc0202402 <exit_range+0x178>
ffffffffc020249c:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc020249e:	d10fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02024a2:	000db783          	ld	a5,0(s11)
ffffffffc02024a6:	6502                	ld	a0,0(sp)
ffffffffc02024a8:	4585                	li	a1,1
ffffffffc02024aa:	739c                	ld	a5,32(a5)
ffffffffc02024ac:	9782                	jalr	a5
        intr_enable();
ffffffffc02024ae:	cfafe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc02024b2:	000d0717          	auipc	a4,0xd0
ffffffffc02024b6:	2f670713          	addi	a4,a4,758 # ffffffffc02d27a8 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc02024ba:	00043023          	sd	zero,0(s0)
ffffffffc02024be:	bfb5                	j	ffffffffc020243a <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02024c0:	00004697          	auipc	a3,0x4
ffffffffc02024c4:	3a868693          	addi	a3,a3,936 # ffffffffc0206868 <default_pmm_manager+0x160>
ffffffffc02024c8:	00004617          	auipc	a2,0x4
ffffffffc02024cc:	e9060613          	addi	a2,a2,-368 # ffffffffc0206358 <commands+0x850>
ffffffffc02024d0:	13700593          	li	a1,311
ffffffffc02024d4:	00004517          	auipc	a0,0x4
ffffffffc02024d8:	38450513          	addi	a0,a0,900 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc02024dc:	fb7fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    return KADDR(page2pa(page));
ffffffffc02024e0:	00004617          	auipc	a2,0x4
ffffffffc02024e4:	26060613          	addi	a2,a2,608 # ffffffffc0206740 <default_pmm_manager+0x38>
ffffffffc02024e8:	07100593          	li	a1,113
ffffffffc02024ec:	00004517          	auipc	a0,0x4
ffffffffc02024f0:	27c50513          	addi	a0,a0,636 # ffffffffc0206768 <default_pmm_manager+0x60>
ffffffffc02024f4:	f9ffd0ef          	jal	ra,ffffffffc0200492 <__panic>
ffffffffc02024f8:	8e1ff0ef          	jal	ra,ffffffffc0201dd8 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc02024fc:	00004697          	auipc	a3,0x4
ffffffffc0202500:	39c68693          	addi	a3,a3,924 # ffffffffc0206898 <default_pmm_manager+0x190>
ffffffffc0202504:	00004617          	auipc	a2,0x4
ffffffffc0202508:	e5460613          	addi	a2,a2,-428 # ffffffffc0206358 <commands+0x850>
ffffffffc020250c:	13800593          	li	a1,312
ffffffffc0202510:	00004517          	auipc	a0,0x4
ffffffffc0202514:	34850513          	addi	a0,a0,840 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0202518:	f7bfd0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc020251c <page_remove>:
{
ffffffffc020251c:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020251e:	4601                	li	a2,0
{
ffffffffc0202520:	ec26                	sd	s1,24(sp)
ffffffffc0202522:	f406                	sd	ra,40(sp)
ffffffffc0202524:	f022                	sd	s0,32(sp)
ffffffffc0202526:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202528:	9a1ff0ef          	jal	ra,ffffffffc0201ec8 <get_pte>
    if (ptep != NULL)
ffffffffc020252c:	c511                	beqz	a0,ffffffffc0202538 <page_remove+0x1c>
    if (*ptep & PTE_V)
ffffffffc020252e:	611c                	ld	a5,0(a0)
ffffffffc0202530:	842a                	mv	s0,a0
ffffffffc0202532:	0017f713          	andi	a4,a5,1
ffffffffc0202536:	e711                	bnez	a4,ffffffffc0202542 <page_remove+0x26>
}
ffffffffc0202538:	70a2                	ld	ra,40(sp)
ffffffffc020253a:	7402                	ld	s0,32(sp)
ffffffffc020253c:	64e2                	ld	s1,24(sp)
ffffffffc020253e:	6145                	addi	sp,sp,48
ffffffffc0202540:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202542:	078a                	slli	a5,a5,0x2
ffffffffc0202544:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202546:	000d0717          	auipc	a4,0xd0
ffffffffc020254a:	25a73703          	ld	a4,602(a4) # ffffffffc02d27a0 <npage>
ffffffffc020254e:	06e7f363          	bgeu	a5,a4,ffffffffc02025b4 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0202552:	fff80537          	lui	a0,0xfff80
ffffffffc0202556:	97aa                	add	a5,a5,a0
ffffffffc0202558:	079a                	slli	a5,a5,0x6
ffffffffc020255a:	000d0517          	auipc	a0,0xd0
ffffffffc020255e:	24e53503          	ld	a0,590(a0) # ffffffffc02d27a8 <pages>
ffffffffc0202562:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202564:	411c                	lw	a5,0(a0)
ffffffffc0202566:	fff7871b          	addiw	a4,a5,-1
ffffffffc020256a:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020256c:	cb11                	beqz	a4,ffffffffc0202580 <page_remove+0x64>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc020256e:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202572:	12048073          	sfence.vma	s1
}
ffffffffc0202576:	70a2                	ld	ra,40(sp)
ffffffffc0202578:	7402                	ld	s0,32(sp)
ffffffffc020257a:	64e2                	ld	s1,24(sp)
ffffffffc020257c:	6145                	addi	sp,sp,48
ffffffffc020257e:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202580:	100027f3          	csrr	a5,sstatus
ffffffffc0202584:	8b89                	andi	a5,a5,2
ffffffffc0202586:	eb89                	bnez	a5,ffffffffc0202598 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0202588:	000d0797          	auipc	a5,0xd0
ffffffffc020258c:	2287b783          	ld	a5,552(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0202590:	739c                	ld	a5,32(a5)
ffffffffc0202592:	4585                	li	a1,1
ffffffffc0202594:	9782                	jalr	a5
    if (flag)
ffffffffc0202596:	bfe1                	j	ffffffffc020256e <page_remove+0x52>
        intr_disable();
ffffffffc0202598:	e42a                	sd	a0,8(sp)
ffffffffc020259a:	c14fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc020259e:	000d0797          	auipc	a5,0xd0
ffffffffc02025a2:	2127b783          	ld	a5,530(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc02025a6:	739c                	ld	a5,32(a5)
ffffffffc02025a8:	6522                	ld	a0,8(sp)
ffffffffc02025aa:	4585                	li	a1,1
ffffffffc02025ac:	9782                	jalr	a5
        intr_enable();
ffffffffc02025ae:	bfafe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc02025b2:	bf75                	j	ffffffffc020256e <page_remove+0x52>
ffffffffc02025b4:	825ff0ef          	jal	ra,ffffffffc0201dd8 <pa2page.part.0>

ffffffffc02025b8 <page_insert>:
{
ffffffffc02025b8:	7139                	addi	sp,sp,-64
ffffffffc02025ba:	e852                	sd	s4,16(sp)
ffffffffc02025bc:	8a32                	mv	s4,a2
ffffffffc02025be:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02025c0:	4605                	li	a2,1
{
ffffffffc02025c2:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02025c4:	85d2                	mv	a1,s4
{
ffffffffc02025c6:	f426                	sd	s1,40(sp)
ffffffffc02025c8:	fc06                	sd	ra,56(sp)
ffffffffc02025ca:	f04a                	sd	s2,32(sp)
ffffffffc02025cc:	ec4e                	sd	s3,24(sp)
ffffffffc02025ce:	e456                	sd	s5,8(sp)
ffffffffc02025d0:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02025d2:	8f7ff0ef          	jal	ra,ffffffffc0201ec8 <get_pte>
    if (ptep == NULL)
ffffffffc02025d6:	c961                	beqz	a0,ffffffffc02026a6 <page_insert+0xee>
    page->ref += 1;
ffffffffc02025d8:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V)
ffffffffc02025da:	611c                	ld	a5,0(a0)
ffffffffc02025dc:	89aa                	mv	s3,a0
ffffffffc02025de:	0016871b          	addiw	a4,a3,1
ffffffffc02025e2:	c018                	sw	a4,0(s0)
ffffffffc02025e4:	0017f713          	andi	a4,a5,1
ffffffffc02025e8:	ef05                	bnez	a4,ffffffffc0202620 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc02025ea:	000d0717          	auipc	a4,0xd0
ffffffffc02025ee:	1be73703          	ld	a4,446(a4) # ffffffffc02d27a8 <pages>
ffffffffc02025f2:	8c19                	sub	s0,s0,a4
ffffffffc02025f4:	000807b7          	lui	a5,0x80
ffffffffc02025f8:	8419                	srai	s0,s0,0x6
ffffffffc02025fa:	943e                	add	s0,s0,a5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02025fc:	042a                	slli	s0,s0,0xa
ffffffffc02025fe:	8cc1                	or	s1,s1,s0
ffffffffc0202600:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202604:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_matrix_out_size+0xffffffffbfff38d8>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202608:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc020260c:	4501                	li	a0,0
}
ffffffffc020260e:	70e2                	ld	ra,56(sp)
ffffffffc0202610:	7442                	ld	s0,48(sp)
ffffffffc0202612:	74a2                	ld	s1,40(sp)
ffffffffc0202614:	7902                	ld	s2,32(sp)
ffffffffc0202616:	69e2                	ld	s3,24(sp)
ffffffffc0202618:	6a42                	ld	s4,16(sp)
ffffffffc020261a:	6aa2                	ld	s5,8(sp)
ffffffffc020261c:	6121                	addi	sp,sp,64
ffffffffc020261e:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202620:	078a                	slli	a5,a5,0x2
ffffffffc0202622:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202624:	000d0717          	auipc	a4,0xd0
ffffffffc0202628:	17c73703          	ld	a4,380(a4) # ffffffffc02d27a0 <npage>
ffffffffc020262c:	06e7ff63          	bgeu	a5,a4,ffffffffc02026aa <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0202630:	000d0a97          	auipc	s5,0xd0
ffffffffc0202634:	178a8a93          	addi	s5,s5,376 # ffffffffc02d27a8 <pages>
ffffffffc0202638:	000ab703          	ld	a4,0(s5)
ffffffffc020263c:	fff80937          	lui	s2,0xfff80
ffffffffc0202640:	993e                	add	s2,s2,a5
ffffffffc0202642:	091a                	slli	s2,s2,0x6
ffffffffc0202644:	993a                	add	s2,s2,a4
        if (p == page)
ffffffffc0202646:	01240c63          	beq	s0,s2,ffffffffc020265e <page_insert+0xa6>
    page->ref -= 1;
ffffffffc020264a:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fcad810>
ffffffffc020264e:	fff7869b          	addiw	a3,a5,-1
ffffffffc0202652:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0202656:	c691                	beqz	a3,ffffffffc0202662 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202658:	120a0073          	sfence.vma	s4
}
ffffffffc020265c:	bf59                	j	ffffffffc02025f2 <page_insert+0x3a>
ffffffffc020265e:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202660:	bf49                	j	ffffffffc02025f2 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202662:	100027f3          	csrr	a5,sstatus
ffffffffc0202666:	8b89                	andi	a5,a5,2
ffffffffc0202668:	ef91                	bnez	a5,ffffffffc0202684 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc020266a:	000d0797          	auipc	a5,0xd0
ffffffffc020266e:	1467b783          	ld	a5,326(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0202672:	739c                	ld	a5,32(a5)
ffffffffc0202674:	4585                	li	a1,1
ffffffffc0202676:	854a                	mv	a0,s2
ffffffffc0202678:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc020267a:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020267e:	120a0073          	sfence.vma	s4
ffffffffc0202682:	bf85                	j	ffffffffc02025f2 <page_insert+0x3a>
        intr_disable();
ffffffffc0202684:	b2afe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202688:	000d0797          	auipc	a5,0xd0
ffffffffc020268c:	1287b783          	ld	a5,296(a5) # ffffffffc02d27b0 <pmm_manager>
ffffffffc0202690:	739c                	ld	a5,32(a5)
ffffffffc0202692:	4585                	li	a1,1
ffffffffc0202694:	854a                	mv	a0,s2
ffffffffc0202696:	9782                	jalr	a5
        intr_enable();
ffffffffc0202698:	b10fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc020269c:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02026a0:	120a0073          	sfence.vma	s4
ffffffffc02026a4:	b7b9                	j	ffffffffc02025f2 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc02026a6:	5571                	li	a0,-4
ffffffffc02026a8:	b79d                	j	ffffffffc020260e <page_insert+0x56>
ffffffffc02026aa:	f2eff0ef          	jal	ra,ffffffffc0201dd8 <pa2page.part.0>

ffffffffc02026ae <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc02026ae:	00004797          	auipc	a5,0x4
ffffffffc02026b2:	05a78793          	addi	a5,a5,90 # ffffffffc0206708 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02026b6:	638c                	ld	a1,0(a5)
{
ffffffffc02026b8:	7159                	addi	sp,sp,-112
ffffffffc02026ba:	f85a                	sd	s6,48(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02026bc:	00004517          	auipc	a0,0x4
ffffffffc02026c0:	1f450513          	addi	a0,a0,500 # ffffffffc02068b0 <default_pmm_manager+0x1a8>
    pmm_manager = &default_pmm_manager;
ffffffffc02026c4:	000d0b17          	auipc	s6,0xd0
ffffffffc02026c8:	0ecb0b13          	addi	s6,s6,236 # ffffffffc02d27b0 <pmm_manager>
{
ffffffffc02026cc:	f486                	sd	ra,104(sp)
ffffffffc02026ce:	e8ca                	sd	s2,80(sp)
ffffffffc02026d0:	e4ce                	sd	s3,72(sp)
ffffffffc02026d2:	f0a2                	sd	s0,96(sp)
ffffffffc02026d4:	eca6                	sd	s1,88(sp)
ffffffffc02026d6:	e0d2                	sd	s4,64(sp)
ffffffffc02026d8:	fc56                	sd	s5,56(sp)
ffffffffc02026da:	f45e                	sd	s7,40(sp)
ffffffffc02026dc:	f062                	sd	s8,32(sp)
ffffffffc02026de:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02026e0:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02026e4:	ab5fd0ef          	jal	ra,ffffffffc0200198 <cprintf>
    pmm_manager->init();
ffffffffc02026e8:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02026ec:	000d0997          	auipc	s3,0xd0
ffffffffc02026f0:	0cc98993          	addi	s3,s3,204 # ffffffffc02d27b8 <va_pa_offset>
    pmm_manager->init();
ffffffffc02026f4:	679c                	ld	a5,8(a5)
ffffffffc02026f6:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02026f8:	57f5                	li	a5,-3
ffffffffc02026fa:	07fa                	slli	a5,a5,0x1e
ffffffffc02026fc:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc0202700:	a94fe0ef          	jal	ra,ffffffffc0200994 <get_memory_base>
ffffffffc0202704:	892a                	mv	s2,a0
    uint64_t mem_size = get_memory_size();
ffffffffc0202706:	a98fe0ef          	jal	ra,ffffffffc020099e <get_memory_size>
    if (mem_size == 0)
ffffffffc020270a:	200505e3          	beqz	a0,ffffffffc0203114 <pmm_init+0xa66>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc020270e:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc0202710:	00004517          	auipc	a0,0x4
ffffffffc0202714:	1d850513          	addi	a0,a0,472 # ffffffffc02068e8 <default_pmm_manager+0x1e0>
ffffffffc0202718:	a81fd0ef          	jal	ra,ffffffffc0200198 <cprintf>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc020271c:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202720:	fff40693          	addi	a3,s0,-1
ffffffffc0202724:	864a                	mv	a2,s2
ffffffffc0202726:	85a6                	mv	a1,s1
ffffffffc0202728:	00004517          	auipc	a0,0x4
ffffffffc020272c:	1d850513          	addi	a0,a0,472 # ffffffffc0206900 <default_pmm_manager+0x1f8>
ffffffffc0202730:	a69fd0ef          	jal	ra,ffffffffc0200198 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0202734:	c8000737          	lui	a4,0xc8000
ffffffffc0202738:	87a2                	mv	a5,s0
ffffffffc020273a:	54876163          	bltu	a4,s0,ffffffffc0202c7c <pmm_init+0x5ce>
ffffffffc020273e:	757d                	lui	a0,0xfffff
ffffffffc0202740:	000d1617          	auipc	a2,0xd1
ffffffffc0202744:	0af60613          	addi	a2,a2,175 # ffffffffc02d37ef <end+0xfff>
ffffffffc0202748:	8e69                	and	a2,a2,a0
ffffffffc020274a:	000d0497          	auipc	s1,0xd0
ffffffffc020274e:	05648493          	addi	s1,s1,86 # ffffffffc02d27a0 <npage>
ffffffffc0202752:	00c7d513          	srli	a0,a5,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202756:	000d0b97          	auipc	s7,0xd0
ffffffffc020275a:	052b8b93          	addi	s7,s7,82 # ffffffffc02d27a8 <pages>
    npage = maxpa / PGSIZE;
ffffffffc020275e:	e088                	sd	a0,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202760:	00cbb023          	sd	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202764:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202768:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc020276a:	02f50863          	beq	a0,a5,ffffffffc020279a <pmm_init+0xec>
ffffffffc020276e:	4781                	li	a5,0
ffffffffc0202770:	4585                	li	a1,1
ffffffffc0202772:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc0202776:	00679513          	slli	a0,a5,0x6
ffffffffc020277a:	9532                	add	a0,a0,a2
ffffffffc020277c:	00850713          	addi	a4,a0,8 # fffffffffffff008 <end+0x3fd2c818>
ffffffffc0202780:	40b7302f          	amoor.d	zero,a1,(a4)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202784:	6088                	ld	a0,0(s1)
ffffffffc0202786:	0785                	addi	a5,a5,1
        SetPageReserved(pages + i);
ffffffffc0202788:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc020278c:	00d50733          	add	a4,a0,a3
ffffffffc0202790:	fee7e3e3          	bltu	a5,a4,ffffffffc0202776 <pmm_init+0xc8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202794:	071a                	slli	a4,a4,0x6
ffffffffc0202796:	00e606b3          	add	a3,a2,a4
ffffffffc020279a:	c02007b7          	lui	a5,0xc0200
ffffffffc020279e:	2ef6ece3          	bltu	a3,a5,ffffffffc0203296 <pmm_init+0xbe8>
ffffffffc02027a2:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc02027a6:	77fd                	lui	a5,0xfffff
ffffffffc02027a8:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02027aa:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc02027ac:	5086eb63          	bltu	a3,s0,ffffffffc0202cc2 <pmm_init+0x614>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc02027b0:	00004517          	auipc	a0,0x4
ffffffffc02027b4:	17850513          	addi	a0,a0,376 # ffffffffc0206928 <default_pmm_manager+0x220>
ffffffffc02027b8:	9e1fd0ef          	jal	ra,ffffffffc0200198 <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc02027bc:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc02027c0:	000d0917          	auipc	s2,0xd0
ffffffffc02027c4:	fd890913          	addi	s2,s2,-40 # ffffffffc02d2798 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc02027c8:	7b9c                	ld	a5,48(a5)
ffffffffc02027ca:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02027cc:	00004517          	auipc	a0,0x4
ffffffffc02027d0:	17450513          	addi	a0,a0,372 # ffffffffc0206940 <default_pmm_manager+0x238>
ffffffffc02027d4:	9c5fd0ef          	jal	ra,ffffffffc0200198 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc02027d8:	00009697          	auipc	a3,0x9
ffffffffc02027dc:	82868693          	addi	a3,a3,-2008 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc02027e0:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc02027e4:	c02007b7          	lui	a5,0xc0200
ffffffffc02027e8:	28f6ebe3          	bltu	a3,a5,ffffffffc020327e <pmm_init+0xbd0>
ffffffffc02027ec:	0009b783          	ld	a5,0(s3)
ffffffffc02027f0:	8e9d                	sub	a3,a3,a5
ffffffffc02027f2:	000d0797          	auipc	a5,0xd0
ffffffffc02027f6:	f8d7bf23          	sd	a3,-98(a5) # ffffffffc02d2790 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02027fa:	100027f3          	csrr	a5,sstatus
ffffffffc02027fe:	8b89                	andi	a5,a5,2
ffffffffc0202800:	4a079763          	bnez	a5,ffffffffc0202cae <pmm_init+0x600>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202804:	000b3783          	ld	a5,0(s6)
ffffffffc0202808:	779c                	ld	a5,40(a5)
ffffffffc020280a:	9782                	jalr	a5
ffffffffc020280c:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020280e:	6098                	ld	a4,0(s1)
ffffffffc0202810:	c80007b7          	lui	a5,0xc8000
ffffffffc0202814:	83b1                	srli	a5,a5,0xc
ffffffffc0202816:	66e7e363          	bltu	a5,a4,ffffffffc0202e7c <pmm_init+0x7ce>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc020281a:	00093503          	ld	a0,0(s2)
ffffffffc020281e:	62050f63          	beqz	a0,ffffffffc0202e5c <pmm_init+0x7ae>
ffffffffc0202822:	03451793          	slli	a5,a0,0x34
ffffffffc0202826:	62079b63          	bnez	a5,ffffffffc0202e5c <pmm_init+0x7ae>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc020282a:	4601                	li	a2,0
ffffffffc020282c:	4581                	li	a1,0
ffffffffc020282e:	8c3ff0ef          	jal	ra,ffffffffc02020f0 <get_page>
ffffffffc0202832:	60051563          	bnez	a0,ffffffffc0202e3c <pmm_init+0x78e>
ffffffffc0202836:	100027f3          	csrr	a5,sstatus
ffffffffc020283a:	8b89                	andi	a5,a5,2
ffffffffc020283c:	44079e63          	bnez	a5,ffffffffc0202c98 <pmm_init+0x5ea>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202840:	000b3783          	ld	a5,0(s6)
ffffffffc0202844:	4505                	li	a0,1
ffffffffc0202846:	6f9c                	ld	a5,24(a5)
ffffffffc0202848:	9782                	jalr	a5
ffffffffc020284a:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc020284c:	00093503          	ld	a0,0(s2)
ffffffffc0202850:	4681                	li	a3,0
ffffffffc0202852:	4601                	li	a2,0
ffffffffc0202854:	85d2                	mv	a1,s4
ffffffffc0202856:	d63ff0ef          	jal	ra,ffffffffc02025b8 <page_insert>
ffffffffc020285a:	26051ae3          	bnez	a0,ffffffffc02032ce <pmm_init+0xc20>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc020285e:	00093503          	ld	a0,0(s2)
ffffffffc0202862:	4601                	li	a2,0
ffffffffc0202864:	4581                	li	a1,0
ffffffffc0202866:	e62ff0ef          	jal	ra,ffffffffc0201ec8 <get_pte>
ffffffffc020286a:	240502e3          	beqz	a0,ffffffffc02032ae <pmm_init+0xc00>
    assert(pte2page(*ptep) == p1);
ffffffffc020286e:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202870:	0017f713          	andi	a4,a5,1
ffffffffc0202874:	5a070263          	beqz	a4,ffffffffc0202e18 <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc0202878:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020287a:	078a                	slli	a5,a5,0x2
ffffffffc020287c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020287e:	58e7fb63          	bgeu	a5,a4,ffffffffc0202e14 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202882:	000bb683          	ld	a3,0(s7)
ffffffffc0202886:	fff80637          	lui	a2,0xfff80
ffffffffc020288a:	97b2                	add	a5,a5,a2
ffffffffc020288c:	079a                	slli	a5,a5,0x6
ffffffffc020288e:	97b6                	add	a5,a5,a3
ffffffffc0202890:	14fa17e3          	bne	s4,a5,ffffffffc02031de <pmm_init+0xb30>
    assert(page_ref(p1) == 1);
ffffffffc0202894:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8f50>
ffffffffc0202898:	4785                	li	a5,1
ffffffffc020289a:	12f692e3          	bne	a3,a5,ffffffffc02031be <pmm_init+0xb10>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc020289e:	00093503          	ld	a0,0(s2)
ffffffffc02028a2:	77fd                	lui	a5,0xfffff
ffffffffc02028a4:	6114                	ld	a3,0(a0)
ffffffffc02028a6:	068a                	slli	a3,a3,0x2
ffffffffc02028a8:	8efd                	and	a3,a3,a5
ffffffffc02028aa:	00c6d613          	srli	a2,a3,0xc
ffffffffc02028ae:	0ee67ce3          	bgeu	a2,a4,ffffffffc02031a6 <pmm_init+0xaf8>
ffffffffc02028b2:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02028b6:	96e2                	add	a3,a3,s8
ffffffffc02028b8:	0006ba83          	ld	s5,0(a3)
ffffffffc02028bc:	0a8a                	slli	s5,s5,0x2
ffffffffc02028be:	00fafab3          	and	s5,s5,a5
ffffffffc02028c2:	00cad793          	srli	a5,s5,0xc
ffffffffc02028c6:	0ce7f3e3          	bgeu	a5,a4,ffffffffc020318c <pmm_init+0xade>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02028ca:	4601                	li	a2,0
ffffffffc02028cc:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02028ce:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02028d0:	df8ff0ef          	jal	ra,ffffffffc0201ec8 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02028d4:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02028d6:	55551363          	bne	a0,s5,ffffffffc0202e1c <pmm_init+0x76e>
ffffffffc02028da:	100027f3          	csrr	a5,sstatus
ffffffffc02028de:	8b89                	andi	a5,a5,2
ffffffffc02028e0:	3a079163          	bnez	a5,ffffffffc0202c82 <pmm_init+0x5d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc02028e4:	000b3783          	ld	a5,0(s6)
ffffffffc02028e8:	4505                	li	a0,1
ffffffffc02028ea:	6f9c                	ld	a5,24(a5)
ffffffffc02028ec:	9782                	jalr	a5
ffffffffc02028ee:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02028f0:	00093503          	ld	a0,0(s2)
ffffffffc02028f4:	46d1                	li	a3,20
ffffffffc02028f6:	6605                	lui	a2,0x1
ffffffffc02028f8:	85e2                	mv	a1,s8
ffffffffc02028fa:	cbfff0ef          	jal	ra,ffffffffc02025b8 <page_insert>
ffffffffc02028fe:	060517e3          	bnez	a0,ffffffffc020316c <pmm_init+0xabe>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202902:	00093503          	ld	a0,0(s2)
ffffffffc0202906:	4601                	li	a2,0
ffffffffc0202908:	6585                	lui	a1,0x1
ffffffffc020290a:	dbeff0ef          	jal	ra,ffffffffc0201ec8 <get_pte>
ffffffffc020290e:	02050fe3          	beqz	a0,ffffffffc020314c <pmm_init+0xa9e>
    assert(*ptep & PTE_U);
ffffffffc0202912:	611c                	ld	a5,0(a0)
ffffffffc0202914:	0107f713          	andi	a4,a5,16
ffffffffc0202918:	7c070e63          	beqz	a4,ffffffffc02030f4 <pmm_init+0xa46>
    assert(*ptep & PTE_W);
ffffffffc020291c:	8b91                	andi	a5,a5,4
ffffffffc020291e:	7a078b63          	beqz	a5,ffffffffc02030d4 <pmm_init+0xa26>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0202922:	00093503          	ld	a0,0(s2)
ffffffffc0202926:	611c                	ld	a5,0(a0)
ffffffffc0202928:	8bc1                	andi	a5,a5,16
ffffffffc020292a:	78078563          	beqz	a5,ffffffffc02030b4 <pmm_init+0xa06>
    assert(page_ref(p2) == 1);
ffffffffc020292e:	000c2703          	lw	a4,0(s8)
ffffffffc0202932:	4785                	li	a5,1
ffffffffc0202934:	76f71063          	bne	a4,a5,ffffffffc0203094 <pmm_init+0x9e6>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0202938:	4681                	li	a3,0
ffffffffc020293a:	6605                	lui	a2,0x1
ffffffffc020293c:	85d2                	mv	a1,s4
ffffffffc020293e:	c7bff0ef          	jal	ra,ffffffffc02025b8 <page_insert>
ffffffffc0202942:	72051963          	bnez	a0,ffffffffc0203074 <pmm_init+0x9c6>
    assert(page_ref(p1) == 2);
ffffffffc0202946:	000a2703          	lw	a4,0(s4)
ffffffffc020294a:	4789                	li	a5,2
ffffffffc020294c:	70f71463          	bne	a4,a5,ffffffffc0203054 <pmm_init+0x9a6>
    assert(page_ref(p2) == 0);
ffffffffc0202950:	000c2783          	lw	a5,0(s8)
ffffffffc0202954:	6e079063          	bnez	a5,ffffffffc0203034 <pmm_init+0x986>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202958:	00093503          	ld	a0,0(s2)
ffffffffc020295c:	4601                	li	a2,0
ffffffffc020295e:	6585                	lui	a1,0x1
ffffffffc0202960:	d68ff0ef          	jal	ra,ffffffffc0201ec8 <get_pte>
ffffffffc0202964:	6a050863          	beqz	a0,ffffffffc0203014 <pmm_init+0x966>
    assert(pte2page(*ptep) == p1);
ffffffffc0202968:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc020296a:	00177793          	andi	a5,a4,1
ffffffffc020296e:	4a078563          	beqz	a5,ffffffffc0202e18 <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc0202972:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202974:	00271793          	slli	a5,a4,0x2
ffffffffc0202978:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020297a:	48d7fd63          	bgeu	a5,a3,ffffffffc0202e14 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc020297e:	000bb683          	ld	a3,0(s7)
ffffffffc0202982:	fff80ab7          	lui	s5,0xfff80
ffffffffc0202986:	97d6                	add	a5,a5,s5
ffffffffc0202988:	079a                	slli	a5,a5,0x6
ffffffffc020298a:	97b6                	add	a5,a5,a3
ffffffffc020298c:	66fa1463          	bne	s4,a5,ffffffffc0202ff4 <pmm_init+0x946>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202990:	8b41                	andi	a4,a4,16
ffffffffc0202992:	64071163          	bnez	a4,ffffffffc0202fd4 <pmm_init+0x926>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc0202996:	00093503          	ld	a0,0(s2)
ffffffffc020299a:	4581                	li	a1,0
ffffffffc020299c:	b81ff0ef          	jal	ra,ffffffffc020251c <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02029a0:	000a2c83          	lw	s9,0(s4)
ffffffffc02029a4:	4785                	li	a5,1
ffffffffc02029a6:	60fc9763          	bne	s9,a5,ffffffffc0202fb4 <pmm_init+0x906>
    assert(page_ref(p2) == 0);
ffffffffc02029aa:	000c2783          	lw	a5,0(s8)
ffffffffc02029ae:	5e079363          	bnez	a5,ffffffffc0202f94 <pmm_init+0x8e6>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc02029b2:	00093503          	ld	a0,0(s2)
ffffffffc02029b6:	6585                	lui	a1,0x1
ffffffffc02029b8:	b65ff0ef          	jal	ra,ffffffffc020251c <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02029bc:	000a2783          	lw	a5,0(s4)
ffffffffc02029c0:	52079a63          	bnez	a5,ffffffffc0202ef4 <pmm_init+0x846>
    assert(page_ref(p2) == 0);
ffffffffc02029c4:	000c2783          	lw	a5,0(s8)
ffffffffc02029c8:	50079663          	bnez	a5,ffffffffc0202ed4 <pmm_init+0x826>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc02029cc:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc02029d0:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02029d2:	000a3683          	ld	a3,0(s4)
ffffffffc02029d6:	068a                	slli	a3,a3,0x2
ffffffffc02029d8:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc02029da:	42b6fd63          	bgeu	a3,a1,ffffffffc0202e14 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02029de:	000bb503          	ld	a0,0(s7)
ffffffffc02029e2:	96d6                	add	a3,a3,s5
ffffffffc02029e4:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc02029e6:	00d507b3          	add	a5,a0,a3
ffffffffc02029ea:	439c                	lw	a5,0(a5)
ffffffffc02029ec:	4d979463          	bne	a5,s9,ffffffffc0202eb4 <pmm_init+0x806>
    return page - pages + nbase;
ffffffffc02029f0:	8699                	srai	a3,a3,0x6
ffffffffc02029f2:	00080637          	lui	a2,0x80
ffffffffc02029f6:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc02029f8:	00c69713          	slli	a4,a3,0xc
ffffffffc02029fc:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02029fe:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202a00:	48b77e63          	bgeu	a4,a1,ffffffffc0202e9c <pmm_init+0x7ee>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202a04:	0009b703          	ld	a4,0(s3)
ffffffffc0202a08:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a0a:	629c                	ld	a5,0(a3)
ffffffffc0202a0c:	078a                	slli	a5,a5,0x2
ffffffffc0202a0e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202a10:	40b7f263          	bgeu	a5,a1,ffffffffc0202e14 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a14:	8f91                	sub	a5,a5,a2
ffffffffc0202a16:	079a                	slli	a5,a5,0x6
ffffffffc0202a18:	953e                	add	a0,a0,a5
ffffffffc0202a1a:	100027f3          	csrr	a5,sstatus
ffffffffc0202a1e:	8b89                	andi	a5,a5,2
ffffffffc0202a20:	30079963          	bnez	a5,ffffffffc0202d32 <pmm_init+0x684>
        pmm_manager->free_pages(base, n);
ffffffffc0202a24:	000b3783          	ld	a5,0(s6)
ffffffffc0202a28:	4585                	li	a1,1
ffffffffc0202a2a:	739c                	ld	a5,32(a5)
ffffffffc0202a2c:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a2e:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202a32:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a34:	078a                	slli	a5,a5,0x2
ffffffffc0202a36:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202a38:	3ce7fe63          	bgeu	a5,a4,ffffffffc0202e14 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a3c:	000bb503          	ld	a0,0(s7)
ffffffffc0202a40:	fff80737          	lui	a4,0xfff80
ffffffffc0202a44:	97ba                	add	a5,a5,a4
ffffffffc0202a46:	079a                	slli	a5,a5,0x6
ffffffffc0202a48:	953e                	add	a0,a0,a5
ffffffffc0202a4a:	100027f3          	csrr	a5,sstatus
ffffffffc0202a4e:	8b89                	andi	a5,a5,2
ffffffffc0202a50:	2c079563          	bnez	a5,ffffffffc0202d1a <pmm_init+0x66c>
ffffffffc0202a54:	000b3783          	ld	a5,0(s6)
ffffffffc0202a58:	4585                	li	a1,1
ffffffffc0202a5a:	739c                	ld	a5,32(a5)
ffffffffc0202a5c:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202a5e:	00093783          	ld	a5,0(s2)
ffffffffc0202a62:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd2c810>
    asm volatile("sfence.vma");
ffffffffc0202a66:	12000073          	sfence.vma
ffffffffc0202a6a:	100027f3          	csrr	a5,sstatus
ffffffffc0202a6e:	8b89                	andi	a5,a5,2
ffffffffc0202a70:	28079b63          	bnez	a5,ffffffffc0202d06 <pmm_init+0x658>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202a74:	000b3783          	ld	a5,0(s6)
ffffffffc0202a78:	779c                	ld	a5,40(a5)
ffffffffc0202a7a:	9782                	jalr	a5
ffffffffc0202a7c:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202a7e:	4b441b63          	bne	s0,s4,ffffffffc0202f34 <pmm_init+0x886>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202a82:	00004517          	auipc	a0,0x4
ffffffffc0202a86:	1e650513          	addi	a0,a0,486 # ffffffffc0206c68 <default_pmm_manager+0x560>
ffffffffc0202a8a:	f0efd0ef          	jal	ra,ffffffffc0200198 <cprintf>
ffffffffc0202a8e:	100027f3          	csrr	a5,sstatus
ffffffffc0202a92:	8b89                	andi	a5,a5,2
ffffffffc0202a94:	24079f63          	bnez	a5,ffffffffc0202cf2 <pmm_init+0x644>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202a98:	000b3783          	ld	a5,0(s6)
ffffffffc0202a9c:	779c                	ld	a5,40(a5)
ffffffffc0202a9e:	9782                	jalr	a5
ffffffffc0202aa0:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202aa2:	6098                	ld	a4,0(s1)
ffffffffc0202aa4:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202aa8:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202aaa:	00c71793          	slli	a5,a4,0xc
ffffffffc0202aae:	6a05                	lui	s4,0x1
ffffffffc0202ab0:	02f47c63          	bgeu	s0,a5,ffffffffc0202ae8 <pmm_init+0x43a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202ab4:	00c45793          	srli	a5,s0,0xc
ffffffffc0202ab8:	00093503          	ld	a0,0(s2)
ffffffffc0202abc:	2ee7ff63          	bgeu	a5,a4,ffffffffc0202dba <pmm_init+0x70c>
ffffffffc0202ac0:	0009b583          	ld	a1,0(s3)
ffffffffc0202ac4:	4601                	li	a2,0
ffffffffc0202ac6:	95a2                	add	a1,a1,s0
ffffffffc0202ac8:	c00ff0ef          	jal	ra,ffffffffc0201ec8 <get_pte>
ffffffffc0202acc:	32050463          	beqz	a0,ffffffffc0202df4 <pmm_init+0x746>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202ad0:	611c                	ld	a5,0(a0)
ffffffffc0202ad2:	078a                	slli	a5,a5,0x2
ffffffffc0202ad4:	0157f7b3          	and	a5,a5,s5
ffffffffc0202ad8:	2e879e63          	bne	a5,s0,ffffffffc0202dd4 <pmm_init+0x726>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202adc:	6098                	ld	a4,0(s1)
ffffffffc0202ade:	9452                	add	s0,s0,s4
ffffffffc0202ae0:	00c71793          	slli	a5,a4,0xc
ffffffffc0202ae4:	fcf468e3          	bltu	s0,a5,ffffffffc0202ab4 <pmm_init+0x406>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc0202ae8:	00093783          	ld	a5,0(s2)
ffffffffc0202aec:	639c                	ld	a5,0(a5)
ffffffffc0202aee:	42079363          	bnez	a5,ffffffffc0202f14 <pmm_init+0x866>
ffffffffc0202af2:	100027f3          	csrr	a5,sstatus
ffffffffc0202af6:	8b89                	andi	a5,a5,2
ffffffffc0202af8:	24079963          	bnez	a5,ffffffffc0202d4a <pmm_init+0x69c>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202afc:	000b3783          	ld	a5,0(s6)
ffffffffc0202b00:	4505                	li	a0,1
ffffffffc0202b02:	6f9c                	ld	a5,24(a5)
ffffffffc0202b04:	9782                	jalr	a5
ffffffffc0202b06:	8a2a                	mv	s4,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202b08:	00093503          	ld	a0,0(s2)
ffffffffc0202b0c:	4699                	li	a3,6
ffffffffc0202b0e:	10000613          	li	a2,256
ffffffffc0202b12:	85d2                	mv	a1,s4
ffffffffc0202b14:	aa5ff0ef          	jal	ra,ffffffffc02025b8 <page_insert>
ffffffffc0202b18:	44051e63          	bnez	a0,ffffffffc0202f74 <pmm_init+0x8c6>
    assert(page_ref(p) == 1);
ffffffffc0202b1c:	000a2703          	lw	a4,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8f50>
ffffffffc0202b20:	4785                	li	a5,1
ffffffffc0202b22:	42f71963          	bne	a4,a5,ffffffffc0202f54 <pmm_init+0x8a6>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202b26:	00093503          	ld	a0,0(s2)
ffffffffc0202b2a:	6405                	lui	s0,0x1
ffffffffc0202b2c:	4699                	li	a3,6
ffffffffc0202b2e:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8e50>
ffffffffc0202b32:	85d2                	mv	a1,s4
ffffffffc0202b34:	a85ff0ef          	jal	ra,ffffffffc02025b8 <page_insert>
ffffffffc0202b38:	72051363          	bnez	a0,ffffffffc020325e <pmm_init+0xbb0>
    assert(page_ref(p) == 2);
ffffffffc0202b3c:	000a2703          	lw	a4,0(s4)
ffffffffc0202b40:	4789                	li	a5,2
ffffffffc0202b42:	6ef71e63          	bne	a4,a5,ffffffffc020323e <pmm_init+0xb90>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202b46:	00004597          	auipc	a1,0x4
ffffffffc0202b4a:	26a58593          	addi	a1,a1,618 # ffffffffc0206db0 <default_pmm_manager+0x6a8>
ffffffffc0202b4e:	10000513          	li	a0,256
ffffffffc0202b52:	4b9020ef          	jal	ra,ffffffffc020580a <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202b56:	10040593          	addi	a1,s0,256
ffffffffc0202b5a:	10000513          	li	a0,256
ffffffffc0202b5e:	4bf020ef          	jal	ra,ffffffffc020581c <strcmp>
ffffffffc0202b62:	6a051e63          	bnez	a0,ffffffffc020321e <pmm_init+0xb70>
    return page - pages + nbase;
ffffffffc0202b66:	000bb683          	ld	a3,0(s7)
ffffffffc0202b6a:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202b6e:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0202b70:	40da06b3          	sub	a3,s4,a3
ffffffffc0202b74:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202b76:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202b78:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202b7a:	8031                	srli	s0,s0,0xc
ffffffffc0202b7c:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b80:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202b82:	30f77d63          	bgeu	a4,a5,ffffffffc0202e9c <pmm_init+0x7ee>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202b86:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202b8a:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202b8e:	96be                	add	a3,a3,a5
ffffffffc0202b90:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202b94:	441020ef          	jal	ra,ffffffffc02057d4 <strlen>
ffffffffc0202b98:	66051363          	bnez	a0,ffffffffc02031fe <pmm_init+0xb50>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0202b9c:	00093a83          	ld	s5,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202ba0:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ba2:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fd2c810>
ffffffffc0202ba6:	068a                	slli	a3,a3,0x2
ffffffffc0202ba8:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0202baa:	26f6f563          	bgeu	a3,a5,ffffffffc0202e14 <pmm_init+0x766>
    return KADDR(page2pa(page));
ffffffffc0202bae:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202bb0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202bb2:	2ef47563          	bgeu	s0,a5,ffffffffc0202e9c <pmm_init+0x7ee>
ffffffffc0202bb6:	0009b403          	ld	s0,0(s3)
ffffffffc0202bba:	9436                	add	s0,s0,a3
ffffffffc0202bbc:	100027f3          	csrr	a5,sstatus
ffffffffc0202bc0:	8b89                	andi	a5,a5,2
ffffffffc0202bc2:	1e079163          	bnez	a5,ffffffffc0202da4 <pmm_init+0x6f6>
        pmm_manager->free_pages(base, n);
ffffffffc0202bc6:	000b3783          	ld	a5,0(s6)
ffffffffc0202bca:	4585                	li	a1,1
ffffffffc0202bcc:	8552                	mv	a0,s4
ffffffffc0202bce:	739c                	ld	a5,32(a5)
ffffffffc0202bd0:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202bd2:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage)
ffffffffc0202bd4:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202bd6:	078a                	slli	a5,a5,0x2
ffffffffc0202bd8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202bda:	22e7fd63          	bgeu	a5,a4,ffffffffc0202e14 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202bde:	000bb503          	ld	a0,0(s7)
ffffffffc0202be2:	fff80737          	lui	a4,0xfff80
ffffffffc0202be6:	97ba                	add	a5,a5,a4
ffffffffc0202be8:	079a                	slli	a5,a5,0x6
ffffffffc0202bea:	953e                	add	a0,a0,a5
ffffffffc0202bec:	100027f3          	csrr	a5,sstatus
ffffffffc0202bf0:	8b89                	andi	a5,a5,2
ffffffffc0202bf2:	18079d63          	bnez	a5,ffffffffc0202d8c <pmm_init+0x6de>
ffffffffc0202bf6:	000b3783          	ld	a5,0(s6)
ffffffffc0202bfa:	4585                	li	a1,1
ffffffffc0202bfc:	739c                	ld	a5,32(a5)
ffffffffc0202bfe:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202c00:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage)
ffffffffc0202c04:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202c06:	078a                	slli	a5,a5,0x2
ffffffffc0202c08:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202c0a:	20e7f563          	bgeu	a5,a4,ffffffffc0202e14 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c0e:	000bb503          	ld	a0,0(s7)
ffffffffc0202c12:	fff80737          	lui	a4,0xfff80
ffffffffc0202c16:	97ba                	add	a5,a5,a4
ffffffffc0202c18:	079a                	slli	a5,a5,0x6
ffffffffc0202c1a:	953e                	add	a0,a0,a5
ffffffffc0202c1c:	100027f3          	csrr	a5,sstatus
ffffffffc0202c20:	8b89                	andi	a5,a5,2
ffffffffc0202c22:	14079963          	bnez	a5,ffffffffc0202d74 <pmm_init+0x6c6>
ffffffffc0202c26:	000b3783          	ld	a5,0(s6)
ffffffffc0202c2a:	4585                	li	a1,1
ffffffffc0202c2c:	739c                	ld	a5,32(a5)
ffffffffc0202c2e:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202c30:	00093783          	ld	a5,0(s2)
ffffffffc0202c34:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc0202c38:	12000073          	sfence.vma
ffffffffc0202c3c:	100027f3          	csrr	a5,sstatus
ffffffffc0202c40:	8b89                	andi	a5,a5,2
ffffffffc0202c42:	10079f63          	bnez	a5,ffffffffc0202d60 <pmm_init+0x6b2>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202c46:	000b3783          	ld	a5,0(s6)
ffffffffc0202c4a:	779c                	ld	a5,40(a5)
ffffffffc0202c4c:	9782                	jalr	a5
ffffffffc0202c4e:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202c50:	4c8c1e63          	bne	s8,s0,ffffffffc020312c <pmm_init+0xa7e>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202c54:	00004517          	auipc	a0,0x4
ffffffffc0202c58:	1d450513          	addi	a0,a0,468 # ffffffffc0206e28 <default_pmm_manager+0x720>
ffffffffc0202c5c:	d3cfd0ef          	jal	ra,ffffffffc0200198 <cprintf>
}
ffffffffc0202c60:	7406                	ld	s0,96(sp)
ffffffffc0202c62:	70a6                	ld	ra,104(sp)
ffffffffc0202c64:	64e6                	ld	s1,88(sp)
ffffffffc0202c66:	6946                	ld	s2,80(sp)
ffffffffc0202c68:	69a6                	ld	s3,72(sp)
ffffffffc0202c6a:	6a06                	ld	s4,64(sp)
ffffffffc0202c6c:	7ae2                	ld	s5,56(sp)
ffffffffc0202c6e:	7b42                	ld	s6,48(sp)
ffffffffc0202c70:	7ba2                	ld	s7,40(sp)
ffffffffc0202c72:	7c02                	ld	s8,32(sp)
ffffffffc0202c74:	6ce2                	ld	s9,24(sp)
ffffffffc0202c76:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0202c78:	f97fe06f          	j	ffffffffc0201c0e <kmalloc_init>
    npage = maxpa / PGSIZE;
ffffffffc0202c7c:	c80007b7          	lui	a5,0xc8000
ffffffffc0202c80:	bc7d                	j	ffffffffc020273e <pmm_init+0x90>
        intr_disable();
ffffffffc0202c82:	d2dfd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202c86:	000b3783          	ld	a5,0(s6)
ffffffffc0202c8a:	4505                	li	a0,1
ffffffffc0202c8c:	6f9c                	ld	a5,24(a5)
ffffffffc0202c8e:	9782                	jalr	a5
ffffffffc0202c90:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202c92:	d17fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202c96:	b9a9                	j	ffffffffc02028f0 <pmm_init+0x242>
        intr_disable();
ffffffffc0202c98:	d17fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc0202c9c:	000b3783          	ld	a5,0(s6)
ffffffffc0202ca0:	4505                	li	a0,1
ffffffffc0202ca2:	6f9c                	ld	a5,24(a5)
ffffffffc0202ca4:	9782                	jalr	a5
ffffffffc0202ca6:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202ca8:	d01fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202cac:	b645                	j	ffffffffc020284c <pmm_init+0x19e>
        intr_disable();
ffffffffc0202cae:	d01fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202cb2:	000b3783          	ld	a5,0(s6)
ffffffffc0202cb6:	779c                	ld	a5,40(a5)
ffffffffc0202cb8:	9782                	jalr	a5
ffffffffc0202cba:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202cbc:	cedfd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202cc0:	b6b9                	j	ffffffffc020280e <pmm_init+0x160>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202cc2:	6705                	lui	a4,0x1
ffffffffc0202cc4:	177d                	addi	a4,a4,-1
ffffffffc0202cc6:	96ba                	add	a3,a3,a4
ffffffffc0202cc8:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc0202cca:	00c7d713          	srli	a4,a5,0xc
ffffffffc0202cce:	14a77363          	bgeu	a4,a0,ffffffffc0202e14 <pmm_init+0x766>
    pmm_manager->init_memmap(base, n);
ffffffffc0202cd2:	000b3683          	ld	a3,0(s6)
    return &pages[PPN(pa) - nbase];
ffffffffc0202cd6:	fff80537          	lui	a0,0xfff80
ffffffffc0202cda:	972a                	add	a4,a4,a0
ffffffffc0202cdc:	6a94                	ld	a3,16(a3)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202cde:	8c1d                	sub	s0,s0,a5
ffffffffc0202ce0:	00671513          	slli	a0,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0202ce4:	00c45593          	srli	a1,s0,0xc
ffffffffc0202ce8:	9532                	add	a0,a0,a2
ffffffffc0202cea:	9682                	jalr	a3
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202cec:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202cf0:	b4c1                	j	ffffffffc02027b0 <pmm_init+0x102>
        intr_disable();
ffffffffc0202cf2:	cbdfd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202cf6:	000b3783          	ld	a5,0(s6)
ffffffffc0202cfa:	779c                	ld	a5,40(a5)
ffffffffc0202cfc:	9782                	jalr	a5
ffffffffc0202cfe:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202d00:	ca9fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202d04:	bb79                	j	ffffffffc0202aa2 <pmm_init+0x3f4>
        intr_disable();
ffffffffc0202d06:	ca9fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc0202d0a:	000b3783          	ld	a5,0(s6)
ffffffffc0202d0e:	779c                	ld	a5,40(a5)
ffffffffc0202d10:	9782                	jalr	a5
ffffffffc0202d12:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202d14:	c95fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202d18:	b39d                	j	ffffffffc0202a7e <pmm_init+0x3d0>
ffffffffc0202d1a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202d1c:	c93fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202d20:	000b3783          	ld	a5,0(s6)
ffffffffc0202d24:	6522                	ld	a0,8(sp)
ffffffffc0202d26:	4585                	li	a1,1
ffffffffc0202d28:	739c                	ld	a5,32(a5)
ffffffffc0202d2a:	9782                	jalr	a5
        intr_enable();
ffffffffc0202d2c:	c7dfd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202d30:	b33d                	j	ffffffffc0202a5e <pmm_init+0x3b0>
ffffffffc0202d32:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202d34:	c7bfd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc0202d38:	000b3783          	ld	a5,0(s6)
ffffffffc0202d3c:	6522                	ld	a0,8(sp)
ffffffffc0202d3e:	4585                	li	a1,1
ffffffffc0202d40:	739c                	ld	a5,32(a5)
ffffffffc0202d42:	9782                	jalr	a5
        intr_enable();
ffffffffc0202d44:	c65fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202d48:	b1dd                	j	ffffffffc0202a2e <pmm_init+0x380>
        intr_disable();
ffffffffc0202d4a:	c65fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202d4e:	000b3783          	ld	a5,0(s6)
ffffffffc0202d52:	4505                	li	a0,1
ffffffffc0202d54:	6f9c                	ld	a5,24(a5)
ffffffffc0202d56:	9782                	jalr	a5
ffffffffc0202d58:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202d5a:	c4ffd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202d5e:	b36d                	j	ffffffffc0202b08 <pmm_init+0x45a>
        intr_disable();
ffffffffc0202d60:	c4ffd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202d64:	000b3783          	ld	a5,0(s6)
ffffffffc0202d68:	779c                	ld	a5,40(a5)
ffffffffc0202d6a:	9782                	jalr	a5
ffffffffc0202d6c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202d6e:	c3bfd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202d72:	bdf9                	j	ffffffffc0202c50 <pmm_init+0x5a2>
ffffffffc0202d74:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202d76:	c39fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202d7a:	000b3783          	ld	a5,0(s6)
ffffffffc0202d7e:	6522                	ld	a0,8(sp)
ffffffffc0202d80:	4585                	li	a1,1
ffffffffc0202d82:	739c                	ld	a5,32(a5)
ffffffffc0202d84:	9782                	jalr	a5
        intr_enable();
ffffffffc0202d86:	c23fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202d8a:	b55d                	j	ffffffffc0202c30 <pmm_init+0x582>
ffffffffc0202d8c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202d8e:	c21fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc0202d92:	000b3783          	ld	a5,0(s6)
ffffffffc0202d96:	6522                	ld	a0,8(sp)
ffffffffc0202d98:	4585                	li	a1,1
ffffffffc0202d9a:	739c                	ld	a5,32(a5)
ffffffffc0202d9c:	9782                	jalr	a5
        intr_enable();
ffffffffc0202d9e:	c0bfd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202da2:	bdb9                	j	ffffffffc0202c00 <pmm_init+0x552>
        intr_disable();
ffffffffc0202da4:	c0bfd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc0202da8:	000b3783          	ld	a5,0(s6)
ffffffffc0202dac:	4585                	li	a1,1
ffffffffc0202dae:	8552                	mv	a0,s4
ffffffffc0202db0:	739c                	ld	a5,32(a5)
ffffffffc0202db2:	9782                	jalr	a5
        intr_enable();
ffffffffc0202db4:	bf5fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202db8:	bd29                	j	ffffffffc0202bd2 <pmm_init+0x524>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202dba:	86a2                	mv	a3,s0
ffffffffc0202dbc:	00004617          	auipc	a2,0x4
ffffffffc0202dc0:	98460613          	addi	a2,a2,-1660 # ffffffffc0206740 <default_pmm_manager+0x38>
ffffffffc0202dc4:	26500593          	li	a1,613
ffffffffc0202dc8:	00004517          	auipc	a0,0x4
ffffffffc0202dcc:	a9050513          	addi	a0,a0,-1392 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0202dd0:	ec2fd0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202dd4:	00004697          	auipc	a3,0x4
ffffffffc0202dd8:	ef468693          	addi	a3,a3,-268 # ffffffffc0206cc8 <default_pmm_manager+0x5c0>
ffffffffc0202ddc:	00003617          	auipc	a2,0x3
ffffffffc0202de0:	57c60613          	addi	a2,a2,1404 # ffffffffc0206358 <commands+0x850>
ffffffffc0202de4:	26600593          	li	a1,614
ffffffffc0202de8:	00004517          	auipc	a0,0x4
ffffffffc0202dec:	a7050513          	addi	a0,a0,-1424 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0202df0:	ea2fd0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202df4:	00004697          	auipc	a3,0x4
ffffffffc0202df8:	e9468693          	addi	a3,a3,-364 # ffffffffc0206c88 <default_pmm_manager+0x580>
ffffffffc0202dfc:	00003617          	auipc	a2,0x3
ffffffffc0202e00:	55c60613          	addi	a2,a2,1372 # ffffffffc0206358 <commands+0x850>
ffffffffc0202e04:	26500593          	li	a1,613
ffffffffc0202e08:	00004517          	auipc	a0,0x4
ffffffffc0202e0c:	a5050513          	addi	a0,a0,-1456 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0202e10:	e82fd0ef          	jal	ra,ffffffffc0200492 <__panic>
ffffffffc0202e14:	fc5fe0ef          	jal	ra,ffffffffc0201dd8 <pa2page.part.0>
ffffffffc0202e18:	fddfe0ef          	jal	ra,ffffffffc0201df4 <pte2page.part.0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202e1c:	00004697          	auipc	a3,0x4
ffffffffc0202e20:	c6468693          	addi	a3,a3,-924 # ffffffffc0206a80 <default_pmm_manager+0x378>
ffffffffc0202e24:	00003617          	auipc	a2,0x3
ffffffffc0202e28:	53460613          	addi	a2,a2,1332 # ffffffffc0206358 <commands+0x850>
ffffffffc0202e2c:	23500593          	li	a1,565
ffffffffc0202e30:	00004517          	auipc	a0,0x4
ffffffffc0202e34:	a2850513          	addi	a0,a0,-1496 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0202e38:	e5afd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0202e3c:	00004697          	auipc	a3,0x4
ffffffffc0202e40:	b8468693          	addi	a3,a3,-1148 # ffffffffc02069c0 <default_pmm_manager+0x2b8>
ffffffffc0202e44:	00003617          	auipc	a2,0x3
ffffffffc0202e48:	51460613          	addi	a2,a2,1300 # ffffffffc0206358 <commands+0x850>
ffffffffc0202e4c:	22800593          	li	a1,552
ffffffffc0202e50:	00004517          	auipc	a0,0x4
ffffffffc0202e54:	a0850513          	addi	a0,a0,-1528 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0202e58:	e3afd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202e5c:	00004697          	auipc	a3,0x4
ffffffffc0202e60:	b2468693          	addi	a3,a3,-1244 # ffffffffc0206980 <default_pmm_manager+0x278>
ffffffffc0202e64:	00003617          	auipc	a2,0x3
ffffffffc0202e68:	4f460613          	addi	a2,a2,1268 # ffffffffc0206358 <commands+0x850>
ffffffffc0202e6c:	22700593          	li	a1,551
ffffffffc0202e70:	00004517          	auipc	a0,0x4
ffffffffc0202e74:	9e850513          	addi	a0,a0,-1560 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0202e78:	e1afd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202e7c:	00004697          	auipc	a3,0x4
ffffffffc0202e80:	ae468693          	addi	a3,a3,-1308 # ffffffffc0206960 <default_pmm_manager+0x258>
ffffffffc0202e84:	00003617          	auipc	a2,0x3
ffffffffc0202e88:	4d460613          	addi	a2,a2,1236 # ffffffffc0206358 <commands+0x850>
ffffffffc0202e8c:	22600593          	li	a1,550
ffffffffc0202e90:	00004517          	auipc	a0,0x4
ffffffffc0202e94:	9c850513          	addi	a0,a0,-1592 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0202e98:	dfafd0ef          	jal	ra,ffffffffc0200492 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202e9c:	00004617          	auipc	a2,0x4
ffffffffc0202ea0:	8a460613          	addi	a2,a2,-1884 # ffffffffc0206740 <default_pmm_manager+0x38>
ffffffffc0202ea4:	07100593          	li	a1,113
ffffffffc0202ea8:	00004517          	auipc	a0,0x4
ffffffffc0202eac:	8c050513          	addi	a0,a0,-1856 # ffffffffc0206768 <default_pmm_manager+0x60>
ffffffffc0202eb0:	de2fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202eb4:	00004697          	auipc	a3,0x4
ffffffffc0202eb8:	d5c68693          	addi	a3,a3,-676 # ffffffffc0206c10 <default_pmm_manager+0x508>
ffffffffc0202ebc:	00003617          	auipc	a2,0x3
ffffffffc0202ec0:	49c60613          	addi	a2,a2,1180 # ffffffffc0206358 <commands+0x850>
ffffffffc0202ec4:	24e00593          	li	a1,590
ffffffffc0202ec8:	00004517          	auipc	a0,0x4
ffffffffc0202ecc:	99050513          	addi	a0,a0,-1648 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0202ed0:	dc2fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202ed4:	00004697          	auipc	a3,0x4
ffffffffc0202ed8:	cf468693          	addi	a3,a3,-780 # ffffffffc0206bc8 <default_pmm_manager+0x4c0>
ffffffffc0202edc:	00003617          	auipc	a2,0x3
ffffffffc0202ee0:	47c60613          	addi	a2,a2,1148 # ffffffffc0206358 <commands+0x850>
ffffffffc0202ee4:	24c00593          	li	a1,588
ffffffffc0202ee8:	00004517          	auipc	a0,0x4
ffffffffc0202eec:	97050513          	addi	a0,a0,-1680 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0202ef0:	da2fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202ef4:	00004697          	auipc	a3,0x4
ffffffffc0202ef8:	d0468693          	addi	a3,a3,-764 # ffffffffc0206bf8 <default_pmm_manager+0x4f0>
ffffffffc0202efc:	00003617          	auipc	a2,0x3
ffffffffc0202f00:	45c60613          	addi	a2,a2,1116 # ffffffffc0206358 <commands+0x850>
ffffffffc0202f04:	24b00593          	li	a1,587
ffffffffc0202f08:	00004517          	auipc	a0,0x4
ffffffffc0202f0c:	95050513          	addi	a0,a0,-1712 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0202f10:	d82fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc0202f14:	00004697          	auipc	a3,0x4
ffffffffc0202f18:	dcc68693          	addi	a3,a3,-564 # ffffffffc0206ce0 <default_pmm_manager+0x5d8>
ffffffffc0202f1c:	00003617          	auipc	a2,0x3
ffffffffc0202f20:	43c60613          	addi	a2,a2,1084 # ffffffffc0206358 <commands+0x850>
ffffffffc0202f24:	26900593          	li	a1,617
ffffffffc0202f28:	00004517          	auipc	a0,0x4
ffffffffc0202f2c:	93050513          	addi	a0,a0,-1744 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0202f30:	d62fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0202f34:	00004697          	auipc	a3,0x4
ffffffffc0202f38:	d0c68693          	addi	a3,a3,-756 # ffffffffc0206c40 <default_pmm_manager+0x538>
ffffffffc0202f3c:	00003617          	auipc	a2,0x3
ffffffffc0202f40:	41c60613          	addi	a2,a2,1052 # ffffffffc0206358 <commands+0x850>
ffffffffc0202f44:	25600593          	li	a1,598
ffffffffc0202f48:	00004517          	auipc	a0,0x4
ffffffffc0202f4c:	91050513          	addi	a0,a0,-1776 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0202f50:	d42fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202f54:	00004697          	auipc	a3,0x4
ffffffffc0202f58:	de468693          	addi	a3,a3,-540 # ffffffffc0206d38 <default_pmm_manager+0x630>
ffffffffc0202f5c:	00003617          	auipc	a2,0x3
ffffffffc0202f60:	3fc60613          	addi	a2,a2,1020 # ffffffffc0206358 <commands+0x850>
ffffffffc0202f64:	26e00593          	li	a1,622
ffffffffc0202f68:	00004517          	auipc	a0,0x4
ffffffffc0202f6c:	8f050513          	addi	a0,a0,-1808 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0202f70:	d22fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202f74:	00004697          	auipc	a3,0x4
ffffffffc0202f78:	d8468693          	addi	a3,a3,-636 # ffffffffc0206cf8 <default_pmm_manager+0x5f0>
ffffffffc0202f7c:	00003617          	auipc	a2,0x3
ffffffffc0202f80:	3dc60613          	addi	a2,a2,988 # ffffffffc0206358 <commands+0x850>
ffffffffc0202f84:	26d00593          	li	a1,621
ffffffffc0202f88:	00004517          	auipc	a0,0x4
ffffffffc0202f8c:	8d050513          	addi	a0,a0,-1840 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0202f90:	d02fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f94:	00004697          	auipc	a3,0x4
ffffffffc0202f98:	c3468693          	addi	a3,a3,-972 # ffffffffc0206bc8 <default_pmm_manager+0x4c0>
ffffffffc0202f9c:	00003617          	auipc	a2,0x3
ffffffffc0202fa0:	3bc60613          	addi	a2,a2,956 # ffffffffc0206358 <commands+0x850>
ffffffffc0202fa4:	24800593          	li	a1,584
ffffffffc0202fa8:	00004517          	auipc	a0,0x4
ffffffffc0202fac:	8b050513          	addi	a0,a0,-1872 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0202fb0:	ce2fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202fb4:	00004697          	auipc	a3,0x4
ffffffffc0202fb8:	ab468693          	addi	a3,a3,-1356 # ffffffffc0206a68 <default_pmm_manager+0x360>
ffffffffc0202fbc:	00003617          	auipc	a2,0x3
ffffffffc0202fc0:	39c60613          	addi	a2,a2,924 # ffffffffc0206358 <commands+0x850>
ffffffffc0202fc4:	24700593          	li	a1,583
ffffffffc0202fc8:	00004517          	auipc	a0,0x4
ffffffffc0202fcc:	89050513          	addi	a0,a0,-1904 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0202fd0:	cc2fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202fd4:	00004697          	auipc	a3,0x4
ffffffffc0202fd8:	c0c68693          	addi	a3,a3,-1012 # ffffffffc0206be0 <default_pmm_manager+0x4d8>
ffffffffc0202fdc:	00003617          	auipc	a2,0x3
ffffffffc0202fe0:	37c60613          	addi	a2,a2,892 # ffffffffc0206358 <commands+0x850>
ffffffffc0202fe4:	24400593          	li	a1,580
ffffffffc0202fe8:	00004517          	auipc	a0,0x4
ffffffffc0202fec:	87050513          	addi	a0,a0,-1936 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0202ff0:	ca2fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202ff4:	00004697          	auipc	a3,0x4
ffffffffc0202ff8:	a5c68693          	addi	a3,a3,-1444 # ffffffffc0206a50 <default_pmm_manager+0x348>
ffffffffc0202ffc:	00003617          	auipc	a2,0x3
ffffffffc0203000:	35c60613          	addi	a2,a2,860 # ffffffffc0206358 <commands+0x850>
ffffffffc0203004:	24300593          	li	a1,579
ffffffffc0203008:	00004517          	auipc	a0,0x4
ffffffffc020300c:	85050513          	addi	a0,a0,-1968 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0203010:	c82fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0203014:	00004697          	auipc	a3,0x4
ffffffffc0203018:	adc68693          	addi	a3,a3,-1316 # ffffffffc0206af0 <default_pmm_manager+0x3e8>
ffffffffc020301c:	00003617          	auipc	a2,0x3
ffffffffc0203020:	33c60613          	addi	a2,a2,828 # ffffffffc0206358 <commands+0x850>
ffffffffc0203024:	24200593          	li	a1,578
ffffffffc0203028:	00004517          	auipc	a0,0x4
ffffffffc020302c:	83050513          	addi	a0,a0,-2000 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0203030:	c62fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203034:	00004697          	auipc	a3,0x4
ffffffffc0203038:	b9468693          	addi	a3,a3,-1132 # ffffffffc0206bc8 <default_pmm_manager+0x4c0>
ffffffffc020303c:	00003617          	auipc	a2,0x3
ffffffffc0203040:	31c60613          	addi	a2,a2,796 # ffffffffc0206358 <commands+0x850>
ffffffffc0203044:	24100593          	li	a1,577
ffffffffc0203048:	00004517          	auipc	a0,0x4
ffffffffc020304c:	81050513          	addi	a0,a0,-2032 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0203050:	c42fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0203054:	00004697          	auipc	a3,0x4
ffffffffc0203058:	b5c68693          	addi	a3,a3,-1188 # ffffffffc0206bb0 <default_pmm_manager+0x4a8>
ffffffffc020305c:	00003617          	auipc	a2,0x3
ffffffffc0203060:	2fc60613          	addi	a2,a2,764 # ffffffffc0206358 <commands+0x850>
ffffffffc0203064:	24000593          	li	a1,576
ffffffffc0203068:	00003517          	auipc	a0,0x3
ffffffffc020306c:	7f050513          	addi	a0,a0,2032 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0203070:	c22fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0203074:	00004697          	auipc	a3,0x4
ffffffffc0203078:	b0c68693          	addi	a3,a3,-1268 # ffffffffc0206b80 <default_pmm_manager+0x478>
ffffffffc020307c:	00003617          	auipc	a2,0x3
ffffffffc0203080:	2dc60613          	addi	a2,a2,732 # ffffffffc0206358 <commands+0x850>
ffffffffc0203084:	23f00593          	li	a1,575
ffffffffc0203088:	00003517          	auipc	a0,0x3
ffffffffc020308c:	7d050513          	addi	a0,a0,2000 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0203090:	c02fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203094:	00004697          	auipc	a3,0x4
ffffffffc0203098:	ad468693          	addi	a3,a3,-1324 # ffffffffc0206b68 <default_pmm_manager+0x460>
ffffffffc020309c:	00003617          	auipc	a2,0x3
ffffffffc02030a0:	2bc60613          	addi	a2,a2,700 # ffffffffc0206358 <commands+0x850>
ffffffffc02030a4:	23d00593          	li	a1,573
ffffffffc02030a8:	00003517          	auipc	a0,0x3
ffffffffc02030ac:	7b050513          	addi	a0,a0,1968 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc02030b0:	be2fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc02030b4:	00004697          	auipc	a3,0x4
ffffffffc02030b8:	a9468693          	addi	a3,a3,-1388 # ffffffffc0206b48 <default_pmm_manager+0x440>
ffffffffc02030bc:	00003617          	auipc	a2,0x3
ffffffffc02030c0:	29c60613          	addi	a2,a2,668 # ffffffffc0206358 <commands+0x850>
ffffffffc02030c4:	23c00593          	li	a1,572
ffffffffc02030c8:	00003517          	auipc	a0,0x3
ffffffffc02030cc:	79050513          	addi	a0,a0,1936 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc02030d0:	bc2fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02030d4:	00004697          	auipc	a3,0x4
ffffffffc02030d8:	a6468693          	addi	a3,a3,-1436 # ffffffffc0206b38 <default_pmm_manager+0x430>
ffffffffc02030dc:	00003617          	auipc	a2,0x3
ffffffffc02030e0:	27c60613          	addi	a2,a2,636 # ffffffffc0206358 <commands+0x850>
ffffffffc02030e4:	23b00593          	li	a1,571
ffffffffc02030e8:	00003517          	auipc	a0,0x3
ffffffffc02030ec:	77050513          	addi	a0,a0,1904 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc02030f0:	ba2fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02030f4:	00004697          	auipc	a3,0x4
ffffffffc02030f8:	a3468693          	addi	a3,a3,-1484 # ffffffffc0206b28 <default_pmm_manager+0x420>
ffffffffc02030fc:	00003617          	auipc	a2,0x3
ffffffffc0203100:	25c60613          	addi	a2,a2,604 # ffffffffc0206358 <commands+0x850>
ffffffffc0203104:	23a00593          	li	a1,570
ffffffffc0203108:	00003517          	auipc	a0,0x3
ffffffffc020310c:	75050513          	addi	a0,a0,1872 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0203110:	b82fd0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("DTB memory info not available");
ffffffffc0203114:	00003617          	auipc	a2,0x3
ffffffffc0203118:	7b460613          	addi	a2,a2,1972 # ffffffffc02068c8 <default_pmm_manager+0x1c0>
ffffffffc020311c:	06500593          	li	a1,101
ffffffffc0203120:	00003517          	auipc	a0,0x3
ffffffffc0203124:	73850513          	addi	a0,a0,1848 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0203128:	b6afd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc020312c:	00004697          	auipc	a3,0x4
ffffffffc0203130:	b1468693          	addi	a3,a3,-1260 # ffffffffc0206c40 <default_pmm_manager+0x538>
ffffffffc0203134:	00003617          	auipc	a2,0x3
ffffffffc0203138:	22460613          	addi	a2,a2,548 # ffffffffc0206358 <commands+0x850>
ffffffffc020313c:	28000593          	li	a1,640
ffffffffc0203140:	00003517          	auipc	a0,0x3
ffffffffc0203144:	71850513          	addi	a0,a0,1816 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0203148:	b4afd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc020314c:	00004697          	auipc	a3,0x4
ffffffffc0203150:	9a468693          	addi	a3,a3,-1628 # ffffffffc0206af0 <default_pmm_manager+0x3e8>
ffffffffc0203154:	00003617          	auipc	a2,0x3
ffffffffc0203158:	20460613          	addi	a2,a2,516 # ffffffffc0206358 <commands+0x850>
ffffffffc020315c:	23900593          	li	a1,569
ffffffffc0203160:	00003517          	auipc	a0,0x3
ffffffffc0203164:	6f850513          	addi	a0,a0,1784 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0203168:	b2afd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020316c:	00004697          	auipc	a3,0x4
ffffffffc0203170:	94468693          	addi	a3,a3,-1724 # ffffffffc0206ab0 <default_pmm_manager+0x3a8>
ffffffffc0203174:	00003617          	auipc	a2,0x3
ffffffffc0203178:	1e460613          	addi	a2,a2,484 # ffffffffc0206358 <commands+0x850>
ffffffffc020317c:	23800593          	li	a1,568
ffffffffc0203180:	00003517          	auipc	a0,0x3
ffffffffc0203184:	6d850513          	addi	a0,a0,1752 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0203188:	b0afd0ef          	jal	ra,ffffffffc0200492 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020318c:	86d6                	mv	a3,s5
ffffffffc020318e:	00003617          	auipc	a2,0x3
ffffffffc0203192:	5b260613          	addi	a2,a2,1458 # ffffffffc0206740 <default_pmm_manager+0x38>
ffffffffc0203196:	23400593          	li	a1,564
ffffffffc020319a:	00003517          	auipc	a0,0x3
ffffffffc020319e:	6be50513          	addi	a0,a0,1726 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc02031a2:	af0fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc02031a6:	00003617          	auipc	a2,0x3
ffffffffc02031aa:	59a60613          	addi	a2,a2,1434 # ffffffffc0206740 <default_pmm_manager+0x38>
ffffffffc02031ae:	23300593          	li	a1,563
ffffffffc02031b2:	00003517          	auipc	a0,0x3
ffffffffc02031b6:	6a650513          	addi	a0,a0,1702 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc02031ba:	ad8fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02031be:	00004697          	auipc	a3,0x4
ffffffffc02031c2:	8aa68693          	addi	a3,a3,-1878 # ffffffffc0206a68 <default_pmm_manager+0x360>
ffffffffc02031c6:	00003617          	auipc	a2,0x3
ffffffffc02031ca:	19260613          	addi	a2,a2,402 # ffffffffc0206358 <commands+0x850>
ffffffffc02031ce:	23100593          	li	a1,561
ffffffffc02031d2:	00003517          	auipc	a0,0x3
ffffffffc02031d6:	68650513          	addi	a0,a0,1670 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc02031da:	ab8fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02031de:	00004697          	auipc	a3,0x4
ffffffffc02031e2:	87268693          	addi	a3,a3,-1934 # ffffffffc0206a50 <default_pmm_manager+0x348>
ffffffffc02031e6:	00003617          	auipc	a2,0x3
ffffffffc02031ea:	17260613          	addi	a2,a2,370 # ffffffffc0206358 <commands+0x850>
ffffffffc02031ee:	23000593          	li	a1,560
ffffffffc02031f2:	00003517          	auipc	a0,0x3
ffffffffc02031f6:	66650513          	addi	a0,a0,1638 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc02031fa:	a98fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02031fe:	00004697          	auipc	a3,0x4
ffffffffc0203202:	c0268693          	addi	a3,a3,-1022 # ffffffffc0206e00 <default_pmm_manager+0x6f8>
ffffffffc0203206:	00003617          	auipc	a2,0x3
ffffffffc020320a:	15260613          	addi	a2,a2,338 # ffffffffc0206358 <commands+0x850>
ffffffffc020320e:	27700593          	li	a1,631
ffffffffc0203212:	00003517          	auipc	a0,0x3
ffffffffc0203216:	64650513          	addi	a0,a0,1606 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc020321a:	a78fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020321e:	00004697          	auipc	a3,0x4
ffffffffc0203222:	baa68693          	addi	a3,a3,-1110 # ffffffffc0206dc8 <default_pmm_manager+0x6c0>
ffffffffc0203226:	00003617          	auipc	a2,0x3
ffffffffc020322a:	13260613          	addi	a2,a2,306 # ffffffffc0206358 <commands+0x850>
ffffffffc020322e:	27400593          	li	a1,628
ffffffffc0203232:	00003517          	auipc	a0,0x3
ffffffffc0203236:	62650513          	addi	a0,a0,1574 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc020323a:	a58fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020323e:	00004697          	auipc	a3,0x4
ffffffffc0203242:	b5a68693          	addi	a3,a3,-1190 # ffffffffc0206d98 <default_pmm_manager+0x690>
ffffffffc0203246:	00003617          	auipc	a2,0x3
ffffffffc020324a:	11260613          	addi	a2,a2,274 # ffffffffc0206358 <commands+0x850>
ffffffffc020324e:	27000593          	li	a1,624
ffffffffc0203252:	00003517          	auipc	a0,0x3
ffffffffc0203256:	60650513          	addi	a0,a0,1542 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc020325a:	a38fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020325e:	00004697          	auipc	a3,0x4
ffffffffc0203262:	af268693          	addi	a3,a3,-1294 # ffffffffc0206d50 <default_pmm_manager+0x648>
ffffffffc0203266:	00003617          	auipc	a2,0x3
ffffffffc020326a:	0f260613          	addi	a2,a2,242 # ffffffffc0206358 <commands+0x850>
ffffffffc020326e:	26f00593          	li	a1,623
ffffffffc0203272:	00003517          	auipc	a0,0x3
ffffffffc0203276:	5e650513          	addi	a0,a0,1510 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc020327a:	a18fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc020327e:	00003617          	auipc	a2,0x3
ffffffffc0203282:	56a60613          	addi	a2,a2,1386 # ffffffffc02067e8 <default_pmm_manager+0xe0>
ffffffffc0203286:	0c900593          	li	a1,201
ffffffffc020328a:	00003517          	auipc	a0,0x3
ffffffffc020328e:	5ce50513          	addi	a0,a0,1486 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0203292:	a00fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203296:	00003617          	auipc	a2,0x3
ffffffffc020329a:	55260613          	addi	a2,a2,1362 # ffffffffc02067e8 <default_pmm_manager+0xe0>
ffffffffc020329e:	08100593          	li	a1,129
ffffffffc02032a2:	00003517          	auipc	a0,0x3
ffffffffc02032a6:	5b650513          	addi	a0,a0,1462 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc02032aa:	9e8fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc02032ae:	00003697          	auipc	a3,0x3
ffffffffc02032b2:	77268693          	addi	a3,a3,1906 # ffffffffc0206a20 <default_pmm_manager+0x318>
ffffffffc02032b6:	00003617          	auipc	a2,0x3
ffffffffc02032ba:	0a260613          	addi	a2,a2,162 # ffffffffc0206358 <commands+0x850>
ffffffffc02032be:	22f00593          	li	a1,559
ffffffffc02032c2:	00003517          	auipc	a0,0x3
ffffffffc02032c6:	59650513          	addi	a0,a0,1430 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc02032ca:	9c8fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc02032ce:	00003697          	auipc	a3,0x3
ffffffffc02032d2:	72268693          	addi	a3,a3,1826 # ffffffffc02069f0 <default_pmm_manager+0x2e8>
ffffffffc02032d6:	00003617          	auipc	a2,0x3
ffffffffc02032da:	08260613          	addi	a2,a2,130 # ffffffffc0206358 <commands+0x850>
ffffffffc02032de:	22c00593          	li	a1,556
ffffffffc02032e2:	00003517          	auipc	a0,0x3
ffffffffc02032e6:	57650513          	addi	a0,a0,1398 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc02032ea:	9a8fd0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02032ee <copy_range>:
{
ffffffffc02032ee:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02032f0:	00d667b3          	or	a5,a2,a3
{
ffffffffc02032f4:	f486                	sd	ra,104(sp)
ffffffffc02032f6:	f0a2                	sd	s0,96(sp)
ffffffffc02032f8:	eca6                	sd	s1,88(sp)
ffffffffc02032fa:	e8ca                	sd	s2,80(sp)
ffffffffc02032fc:	e4ce                	sd	s3,72(sp)
ffffffffc02032fe:	e0d2                	sd	s4,64(sp)
ffffffffc0203300:	fc56                	sd	s5,56(sp)
ffffffffc0203302:	f85a                	sd	s6,48(sp)
ffffffffc0203304:	f45e                	sd	s7,40(sp)
ffffffffc0203306:	f062                	sd	s8,32(sp)
ffffffffc0203308:	ec66                	sd	s9,24(sp)
ffffffffc020330a:	e86a                	sd	s10,16(sp)
ffffffffc020330c:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020330e:	17d2                	slli	a5,a5,0x34
ffffffffc0203310:	20079f63          	bnez	a5,ffffffffc020352e <copy_range+0x240>
    assert(USER_ACCESS(start, end));
ffffffffc0203314:	002007b7          	lui	a5,0x200
ffffffffc0203318:	8432                	mv	s0,a2
ffffffffc020331a:	1af66263          	bltu	a2,a5,ffffffffc02034be <copy_range+0x1d0>
ffffffffc020331e:	8936                	mv	s2,a3
ffffffffc0203320:	18d67f63          	bgeu	a2,a3,ffffffffc02034be <copy_range+0x1d0>
ffffffffc0203324:	4785                	li	a5,1
ffffffffc0203326:	07fe                	slli	a5,a5,0x1f
ffffffffc0203328:	18d7eb63          	bltu	a5,a3,ffffffffc02034be <copy_range+0x1d0>
ffffffffc020332c:	5b7d                	li	s6,-1
ffffffffc020332e:	8aaa                	mv	s5,a0
ffffffffc0203330:	89ae                	mv	s3,a1
        start += PGSIZE;
ffffffffc0203332:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage)
ffffffffc0203334:	000cfc17          	auipc	s8,0xcf
ffffffffc0203338:	46cc0c13          	addi	s8,s8,1132 # ffffffffc02d27a0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020333c:	000cfb97          	auipc	s7,0xcf
ffffffffc0203340:	46cb8b93          	addi	s7,s7,1132 # ffffffffc02d27a8 <pages>
    return KADDR(page2pa(page));
ffffffffc0203344:	00cb5b13          	srli	s6,s6,0xc
        page = pmm_manager->alloc_pages(n);
ffffffffc0203348:	000cfc97          	auipc	s9,0xcf
ffffffffc020334c:	468c8c93          	addi	s9,s9,1128 # ffffffffc02d27b0 <pmm_manager>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0203350:	4601                	li	a2,0
ffffffffc0203352:	85a2                	mv	a1,s0
ffffffffc0203354:	854e                	mv	a0,s3
ffffffffc0203356:	b73fe0ef          	jal	ra,ffffffffc0201ec8 <get_pte>
ffffffffc020335a:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc020335c:	0e050c63          	beqz	a0,ffffffffc0203454 <copy_range+0x166>
        if (*ptep & PTE_V)
ffffffffc0203360:	611c                	ld	a5,0(a0)
ffffffffc0203362:	8b85                	andi	a5,a5,1
ffffffffc0203364:	e785                	bnez	a5,ffffffffc020338c <copy_range+0x9e>
        start += PGSIZE;
ffffffffc0203366:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0203368:	ff2464e3          	bltu	s0,s2,ffffffffc0203350 <copy_range+0x62>
    return 0;
ffffffffc020336c:	4501                	li	a0,0
}
ffffffffc020336e:	70a6                	ld	ra,104(sp)
ffffffffc0203370:	7406                	ld	s0,96(sp)
ffffffffc0203372:	64e6                	ld	s1,88(sp)
ffffffffc0203374:	6946                	ld	s2,80(sp)
ffffffffc0203376:	69a6                	ld	s3,72(sp)
ffffffffc0203378:	6a06                	ld	s4,64(sp)
ffffffffc020337a:	7ae2                	ld	s5,56(sp)
ffffffffc020337c:	7b42                	ld	s6,48(sp)
ffffffffc020337e:	7ba2                	ld	s7,40(sp)
ffffffffc0203380:	7c02                	ld	s8,32(sp)
ffffffffc0203382:	6ce2                	ld	s9,24(sp)
ffffffffc0203384:	6d42                	ld	s10,16(sp)
ffffffffc0203386:	6da2                	ld	s11,8(sp)
ffffffffc0203388:	6165                	addi	sp,sp,112
ffffffffc020338a:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc020338c:	4605                	li	a2,1
ffffffffc020338e:	85a2                	mv	a1,s0
ffffffffc0203390:	8556                	mv	a0,s5
ffffffffc0203392:	b37fe0ef          	jal	ra,ffffffffc0201ec8 <get_pte>
ffffffffc0203396:	c56d                	beqz	a0,ffffffffc0203480 <copy_range+0x192>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0203398:	609c                	ld	a5,0(s1)
    if (!(pte & PTE_V))
ffffffffc020339a:	0017f713          	andi	a4,a5,1
ffffffffc020339e:	01f7f493          	andi	s1,a5,31
ffffffffc02033a2:	16070a63          	beqz	a4,ffffffffc0203516 <copy_range+0x228>
    if (PPN(pa) >= npage)
ffffffffc02033a6:	000c3683          	ld	a3,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc02033aa:	078a                	slli	a5,a5,0x2
ffffffffc02033ac:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02033b0:	14d77763          	bgeu	a4,a3,ffffffffc02034fe <copy_range+0x210>
    return &pages[PPN(pa) - nbase];
ffffffffc02033b4:	000bb783          	ld	a5,0(s7)
ffffffffc02033b8:	fff806b7          	lui	a3,0xfff80
ffffffffc02033bc:	9736                	add	a4,a4,a3
ffffffffc02033be:	071a                	slli	a4,a4,0x6
ffffffffc02033c0:	00e78db3          	add	s11,a5,a4
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02033c4:	10002773          	csrr	a4,sstatus
ffffffffc02033c8:	8b09                	andi	a4,a4,2
ffffffffc02033ca:	e345                	bnez	a4,ffffffffc020346a <copy_range+0x17c>
        page = pmm_manager->alloc_pages(n);
ffffffffc02033cc:	000cb703          	ld	a4,0(s9)
ffffffffc02033d0:	4505                	li	a0,1
ffffffffc02033d2:	6f18                	ld	a4,24(a4)
ffffffffc02033d4:	9702                	jalr	a4
ffffffffc02033d6:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc02033d8:	0c0d8363          	beqz	s11,ffffffffc020349e <copy_range+0x1b0>
            assert(npage != NULL);
ffffffffc02033dc:	100d0163          	beqz	s10,ffffffffc02034de <copy_range+0x1f0>
    return page - pages + nbase;
ffffffffc02033e0:	000bb703          	ld	a4,0(s7)
ffffffffc02033e4:	000805b7          	lui	a1,0x80
    return KADDR(page2pa(page));
ffffffffc02033e8:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc02033ec:	40ed86b3          	sub	a3,s11,a4
ffffffffc02033f0:	8699                	srai	a3,a3,0x6
ffffffffc02033f2:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc02033f4:	0166f7b3          	and	a5,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02033f8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02033fa:	08c7f663          	bgeu	a5,a2,ffffffffc0203486 <copy_range+0x198>
    return page - pages + nbase;
ffffffffc02033fe:	40ed07b3          	sub	a5,s10,a4
    return KADDR(page2pa(page));
ffffffffc0203402:	000cf717          	auipc	a4,0xcf
ffffffffc0203406:	3b670713          	addi	a4,a4,950 # ffffffffc02d27b8 <va_pa_offset>
ffffffffc020340a:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc020340c:	8799                	srai	a5,a5,0x6
ffffffffc020340e:	97ae                	add	a5,a5,a1
    return KADDR(page2pa(page));
ffffffffc0203410:	0167f733          	and	a4,a5,s6
ffffffffc0203414:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203418:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc020341a:	06c77563          	bgeu	a4,a2,ffffffffc0203484 <copy_range+0x196>
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ffffffffc020341e:	6605                	lui	a2,0x1
ffffffffc0203420:	953e                	add	a0,a0,a5
ffffffffc0203422:	466020ef          	jal	ra,ffffffffc0205888 <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc0203426:	86a6                	mv	a3,s1
ffffffffc0203428:	8622                	mv	a2,s0
ffffffffc020342a:	85ea                	mv	a1,s10
ffffffffc020342c:	8556                	mv	a0,s5
ffffffffc020342e:	98aff0ef          	jal	ra,ffffffffc02025b8 <page_insert>
            assert(ret == 0);
ffffffffc0203432:	d915                	beqz	a0,ffffffffc0203366 <copy_range+0x78>
ffffffffc0203434:	00004697          	auipc	a3,0x4
ffffffffc0203438:	a3468693          	addi	a3,a3,-1484 # ffffffffc0206e68 <default_pmm_manager+0x760>
ffffffffc020343c:	00003617          	auipc	a2,0x3
ffffffffc0203440:	f1c60613          	addi	a2,a2,-228 # ffffffffc0206358 <commands+0x850>
ffffffffc0203444:	1c400593          	li	a1,452
ffffffffc0203448:	00003517          	auipc	a0,0x3
ffffffffc020344c:	41050513          	addi	a0,a0,1040 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc0203450:	842fd0ef          	jal	ra,ffffffffc0200492 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203454:	00200637          	lui	a2,0x200
ffffffffc0203458:	9432                	add	s0,s0,a2
ffffffffc020345a:	ffe00637          	lui	a2,0xffe00
ffffffffc020345e:	8c71                	and	s0,s0,a2
    } while (start != 0 && start < end);
ffffffffc0203460:	f00406e3          	beqz	s0,ffffffffc020336c <copy_range+0x7e>
ffffffffc0203464:	ef2466e3          	bltu	s0,s2,ffffffffc0203350 <copy_range+0x62>
ffffffffc0203468:	b711                	j	ffffffffc020336c <copy_range+0x7e>
        intr_disable();
ffffffffc020346a:	d44fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020346e:	000cb703          	ld	a4,0(s9)
ffffffffc0203472:	4505                	li	a0,1
ffffffffc0203474:	6f18                	ld	a4,24(a4)
ffffffffc0203476:	9702                	jalr	a4
ffffffffc0203478:	8d2a                	mv	s10,a0
        intr_enable();
ffffffffc020347a:	d2efd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc020347e:	bfa9                	j	ffffffffc02033d8 <copy_range+0xea>
                return -E_NO_MEM;
ffffffffc0203480:	5571                	li	a0,-4
ffffffffc0203482:	b5f5                	j	ffffffffc020336e <copy_range+0x80>
ffffffffc0203484:	86be                	mv	a3,a5
ffffffffc0203486:	00003617          	auipc	a2,0x3
ffffffffc020348a:	2ba60613          	addi	a2,a2,698 # ffffffffc0206740 <default_pmm_manager+0x38>
ffffffffc020348e:	07100593          	li	a1,113
ffffffffc0203492:	00003517          	auipc	a0,0x3
ffffffffc0203496:	2d650513          	addi	a0,a0,726 # ffffffffc0206768 <default_pmm_manager+0x60>
ffffffffc020349a:	ff9fc0ef          	jal	ra,ffffffffc0200492 <__panic>
            assert(page != NULL);
ffffffffc020349e:	00004697          	auipc	a3,0x4
ffffffffc02034a2:	9aa68693          	addi	a3,a3,-1622 # ffffffffc0206e48 <default_pmm_manager+0x740>
ffffffffc02034a6:	00003617          	auipc	a2,0x3
ffffffffc02034aa:	eb260613          	addi	a2,a2,-334 # ffffffffc0206358 <commands+0x850>
ffffffffc02034ae:	19600593          	li	a1,406
ffffffffc02034b2:	00003517          	auipc	a0,0x3
ffffffffc02034b6:	3a650513          	addi	a0,a0,934 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc02034ba:	fd9fc0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02034be:	00003697          	auipc	a3,0x3
ffffffffc02034c2:	3da68693          	addi	a3,a3,986 # ffffffffc0206898 <default_pmm_manager+0x190>
ffffffffc02034c6:	00003617          	auipc	a2,0x3
ffffffffc02034ca:	e9260613          	addi	a2,a2,-366 # ffffffffc0206358 <commands+0x850>
ffffffffc02034ce:	17e00593          	li	a1,382
ffffffffc02034d2:	00003517          	auipc	a0,0x3
ffffffffc02034d6:	38650513          	addi	a0,a0,902 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc02034da:	fb9fc0ef          	jal	ra,ffffffffc0200492 <__panic>
            assert(npage != NULL);
ffffffffc02034de:	00004697          	auipc	a3,0x4
ffffffffc02034e2:	97a68693          	addi	a3,a3,-1670 # ffffffffc0206e58 <default_pmm_manager+0x750>
ffffffffc02034e6:	00003617          	auipc	a2,0x3
ffffffffc02034ea:	e7260613          	addi	a2,a2,-398 # ffffffffc0206358 <commands+0x850>
ffffffffc02034ee:	1bb00593          	li	a1,443
ffffffffc02034f2:	00003517          	auipc	a0,0x3
ffffffffc02034f6:	36650513          	addi	a0,a0,870 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc02034fa:	f99fc0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02034fe:	00003617          	auipc	a2,0x3
ffffffffc0203502:	31260613          	addi	a2,a2,786 # ffffffffc0206810 <default_pmm_manager+0x108>
ffffffffc0203506:	06900593          	li	a1,105
ffffffffc020350a:	00003517          	auipc	a0,0x3
ffffffffc020350e:	25e50513          	addi	a0,a0,606 # ffffffffc0206768 <default_pmm_manager+0x60>
ffffffffc0203512:	f81fc0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203516:	00003617          	auipc	a2,0x3
ffffffffc020351a:	31a60613          	addi	a2,a2,794 # ffffffffc0206830 <default_pmm_manager+0x128>
ffffffffc020351e:	07f00593          	li	a1,127
ffffffffc0203522:	00003517          	auipc	a0,0x3
ffffffffc0203526:	24650513          	addi	a0,a0,582 # ffffffffc0206768 <default_pmm_manager+0x60>
ffffffffc020352a:	f69fc0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020352e:	00003697          	auipc	a3,0x3
ffffffffc0203532:	33a68693          	addi	a3,a3,826 # ffffffffc0206868 <default_pmm_manager+0x160>
ffffffffc0203536:	00003617          	auipc	a2,0x3
ffffffffc020353a:	e2260613          	addi	a2,a2,-478 # ffffffffc0206358 <commands+0x850>
ffffffffc020353e:	17d00593          	li	a1,381
ffffffffc0203542:	00003517          	auipc	a0,0x3
ffffffffc0203546:	31650513          	addi	a0,a0,790 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc020354a:	f49fc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc020354e <pgdir_alloc_page>:
{
ffffffffc020354e:	7179                	addi	sp,sp,-48
ffffffffc0203550:	ec26                	sd	s1,24(sp)
ffffffffc0203552:	e84a                	sd	s2,16(sp)
ffffffffc0203554:	e052                	sd	s4,0(sp)
ffffffffc0203556:	f406                	sd	ra,40(sp)
ffffffffc0203558:	f022                	sd	s0,32(sp)
ffffffffc020355a:	e44e                	sd	s3,8(sp)
ffffffffc020355c:	8a2a                	mv	s4,a0
ffffffffc020355e:	84ae                	mv	s1,a1
ffffffffc0203560:	8932                	mv	s2,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203562:	100027f3          	csrr	a5,sstatus
ffffffffc0203566:	8b89                	andi	a5,a5,2
        page = pmm_manager->alloc_pages(n);
ffffffffc0203568:	000cf997          	auipc	s3,0xcf
ffffffffc020356c:	24898993          	addi	s3,s3,584 # ffffffffc02d27b0 <pmm_manager>
ffffffffc0203570:	ef8d                	bnez	a5,ffffffffc02035aa <pgdir_alloc_page+0x5c>
ffffffffc0203572:	0009b783          	ld	a5,0(s3)
ffffffffc0203576:	4505                	li	a0,1
ffffffffc0203578:	6f9c                	ld	a5,24(a5)
ffffffffc020357a:	9782                	jalr	a5
ffffffffc020357c:	842a                	mv	s0,a0
    if (page != NULL)
ffffffffc020357e:	cc09                	beqz	s0,ffffffffc0203598 <pgdir_alloc_page+0x4a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc0203580:	86ca                	mv	a3,s2
ffffffffc0203582:	8626                	mv	a2,s1
ffffffffc0203584:	85a2                	mv	a1,s0
ffffffffc0203586:	8552                	mv	a0,s4
ffffffffc0203588:	830ff0ef          	jal	ra,ffffffffc02025b8 <page_insert>
ffffffffc020358c:	e915                	bnez	a0,ffffffffc02035c0 <pgdir_alloc_page+0x72>
        assert(page_ref(page) == 1);
ffffffffc020358e:	4018                	lw	a4,0(s0)
        page->pra_vaddr = la;
ffffffffc0203590:	fc04                	sd	s1,56(s0)
        assert(page_ref(page) == 1);
ffffffffc0203592:	4785                	li	a5,1
ffffffffc0203594:	04f71e63          	bne	a4,a5,ffffffffc02035f0 <pgdir_alloc_page+0xa2>
}
ffffffffc0203598:	70a2                	ld	ra,40(sp)
ffffffffc020359a:	8522                	mv	a0,s0
ffffffffc020359c:	7402                	ld	s0,32(sp)
ffffffffc020359e:	64e2                	ld	s1,24(sp)
ffffffffc02035a0:	6942                	ld	s2,16(sp)
ffffffffc02035a2:	69a2                	ld	s3,8(sp)
ffffffffc02035a4:	6a02                	ld	s4,0(sp)
ffffffffc02035a6:	6145                	addi	sp,sp,48
ffffffffc02035a8:	8082                	ret
        intr_disable();
ffffffffc02035aa:	c04fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02035ae:	0009b783          	ld	a5,0(s3)
ffffffffc02035b2:	4505                	li	a0,1
ffffffffc02035b4:	6f9c                	ld	a5,24(a5)
ffffffffc02035b6:	9782                	jalr	a5
ffffffffc02035b8:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02035ba:	beefd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc02035be:	b7c1                	j	ffffffffc020357e <pgdir_alloc_page+0x30>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02035c0:	100027f3          	csrr	a5,sstatus
ffffffffc02035c4:	8b89                	andi	a5,a5,2
ffffffffc02035c6:	eb89                	bnez	a5,ffffffffc02035d8 <pgdir_alloc_page+0x8a>
        pmm_manager->free_pages(base, n);
ffffffffc02035c8:	0009b783          	ld	a5,0(s3)
ffffffffc02035cc:	8522                	mv	a0,s0
ffffffffc02035ce:	4585                	li	a1,1
ffffffffc02035d0:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc02035d2:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc02035d4:	9782                	jalr	a5
    if (flag)
ffffffffc02035d6:	b7c9                	j	ffffffffc0203598 <pgdir_alloc_page+0x4a>
        intr_disable();
ffffffffc02035d8:	bd6fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc02035dc:	0009b783          	ld	a5,0(s3)
ffffffffc02035e0:	8522                	mv	a0,s0
ffffffffc02035e2:	4585                	li	a1,1
ffffffffc02035e4:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc02035e6:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc02035e8:	9782                	jalr	a5
        intr_enable();
ffffffffc02035ea:	bbefd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc02035ee:	b76d                	j	ffffffffc0203598 <pgdir_alloc_page+0x4a>
        assert(page_ref(page) == 1);
ffffffffc02035f0:	00004697          	auipc	a3,0x4
ffffffffc02035f4:	88868693          	addi	a3,a3,-1912 # ffffffffc0206e78 <default_pmm_manager+0x770>
ffffffffc02035f8:	00003617          	auipc	a2,0x3
ffffffffc02035fc:	d6060613          	addi	a2,a2,-672 # ffffffffc0206358 <commands+0x850>
ffffffffc0203600:	20d00593          	li	a1,525
ffffffffc0203604:	00003517          	auipc	a0,0x3
ffffffffc0203608:	25450513          	addi	a0,a0,596 # ffffffffc0206858 <default_pmm_manager+0x150>
ffffffffc020360c:	e87fc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0203610 <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0203610:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203612:	00004697          	auipc	a3,0x4
ffffffffc0203616:	87e68693          	addi	a3,a3,-1922 # ffffffffc0206e90 <default_pmm_manager+0x788>
ffffffffc020361a:	00003617          	auipc	a2,0x3
ffffffffc020361e:	d3e60613          	addi	a2,a2,-706 # ffffffffc0206358 <commands+0x850>
ffffffffc0203622:	07400593          	li	a1,116
ffffffffc0203626:	00004517          	auipc	a0,0x4
ffffffffc020362a:	88a50513          	addi	a0,a0,-1910 # ffffffffc0206eb0 <default_pmm_manager+0x7a8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc020362e:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0203630:	e63fc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0203634 <mm_create>:
{
ffffffffc0203634:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203636:	04000513          	li	a0,64
{
ffffffffc020363a:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020363c:	df6fe0ef          	jal	ra,ffffffffc0201c32 <kmalloc>
    if (mm != NULL)
ffffffffc0203640:	cd19                	beqz	a0,ffffffffc020365e <mm_create+0x2a>
    elm->prev = elm->next = elm;
ffffffffc0203642:	e508                	sd	a0,8(a0)
ffffffffc0203644:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203646:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020364a:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020364e:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0203652:	02053423          	sd	zero,40(a0)
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc0203656:	02052823          	sw	zero,48(a0)
typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
ffffffffc020365a:	02053c23          	sd	zero,56(a0)
}
ffffffffc020365e:	60a2                	ld	ra,8(sp)
ffffffffc0203660:	0141                	addi	sp,sp,16
ffffffffc0203662:	8082                	ret

ffffffffc0203664 <find_vma>:
{
ffffffffc0203664:	86aa                	mv	a3,a0
    if (mm != NULL)
ffffffffc0203666:	c505                	beqz	a0,ffffffffc020368e <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0203668:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc020366a:	c501                	beqz	a0,ffffffffc0203672 <find_vma+0xe>
ffffffffc020366c:	651c                	ld	a5,8(a0)
ffffffffc020366e:	02f5f263          	bgeu	a1,a5,ffffffffc0203692 <find_vma+0x2e>
    return listelm->next;
ffffffffc0203672:	669c                	ld	a5,8(a3)
            while ((le = list_next(le)) != list)
ffffffffc0203674:	00f68d63          	beq	a3,a5,ffffffffc020368e <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc0203678:	fe87b703          	ld	a4,-24(a5) # 1fffe8 <_binary_obj___user_matrix_out_size+0x1f38c0>
ffffffffc020367c:	00e5e663          	bltu	a1,a4,ffffffffc0203688 <find_vma+0x24>
ffffffffc0203680:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203684:	00e5ec63          	bltu	a1,a4,ffffffffc020369c <find_vma+0x38>
ffffffffc0203688:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc020368a:	fef697e3          	bne	a3,a5,ffffffffc0203678 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc020368e:	4501                	li	a0,0
}
ffffffffc0203690:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0203692:	691c                	ld	a5,16(a0)
ffffffffc0203694:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0203672 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0203698:	ea88                	sd	a0,16(a3)
ffffffffc020369a:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc020369c:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc02036a0:	ea88                	sd	a0,16(a3)
ffffffffc02036a2:	8082                	ret

ffffffffc02036a4 <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc02036a4:	6590                	ld	a2,8(a1)
ffffffffc02036a6:	0105b803          	ld	a6,16(a1) # 80010 <_binary_obj___user_matrix_out_size+0x738e8>
{
ffffffffc02036aa:	1141                	addi	sp,sp,-16
ffffffffc02036ac:	e406                	sd	ra,8(sp)
ffffffffc02036ae:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02036b0:	01066763          	bltu	a2,a6,ffffffffc02036be <insert_vma_struct+0x1a>
ffffffffc02036b4:	a085                	j	ffffffffc0203714 <insert_vma_struct+0x70>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc02036b6:	fe87b703          	ld	a4,-24(a5)
ffffffffc02036ba:	04e66863          	bltu	a2,a4,ffffffffc020370a <insert_vma_struct+0x66>
ffffffffc02036be:	86be                	mv	a3,a5
ffffffffc02036c0:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc02036c2:	fef51ae3          	bne	a0,a5,ffffffffc02036b6 <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc02036c6:	02a68463          	beq	a3,a0,ffffffffc02036ee <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02036ca:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02036ce:	fe86b883          	ld	a7,-24(a3)
ffffffffc02036d2:	08e8f163          	bgeu	a7,a4,ffffffffc0203754 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02036d6:	04e66f63          	bltu	a2,a4,ffffffffc0203734 <insert_vma_struct+0x90>
    }
    if (le_next != list)
ffffffffc02036da:	00f50a63          	beq	a0,a5,ffffffffc02036ee <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc02036de:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02036e2:	05076963          	bltu	a4,a6,ffffffffc0203734 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02036e6:	ff07b603          	ld	a2,-16(a5)
ffffffffc02036ea:	02c77363          	bgeu	a4,a2,ffffffffc0203710 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc02036ee:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02036f0:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02036f2:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02036f6:	e390                	sd	a2,0(a5)
ffffffffc02036f8:	e690                	sd	a2,8(a3)
}
ffffffffc02036fa:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02036fc:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02036fe:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc0203700:	0017079b          	addiw	a5,a4,1
ffffffffc0203704:	d11c                	sw	a5,32(a0)
}
ffffffffc0203706:	0141                	addi	sp,sp,16
ffffffffc0203708:	8082                	ret
    if (le_prev != list)
ffffffffc020370a:	fca690e3          	bne	a3,a0,ffffffffc02036ca <insert_vma_struct+0x26>
ffffffffc020370e:	bfd1                	j	ffffffffc02036e2 <insert_vma_struct+0x3e>
ffffffffc0203710:	f01ff0ef          	jal	ra,ffffffffc0203610 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203714:	00003697          	auipc	a3,0x3
ffffffffc0203718:	7ac68693          	addi	a3,a3,1964 # ffffffffc0206ec0 <default_pmm_manager+0x7b8>
ffffffffc020371c:	00003617          	auipc	a2,0x3
ffffffffc0203720:	c3c60613          	addi	a2,a2,-964 # ffffffffc0206358 <commands+0x850>
ffffffffc0203724:	07a00593          	li	a1,122
ffffffffc0203728:	00003517          	auipc	a0,0x3
ffffffffc020372c:	78850513          	addi	a0,a0,1928 # ffffffffc0206eb0 <default_pmm_manager+0x7a8>
ffffffffc0203730:	d63fc0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203734:	00003697          	auipc	a3,0x3
ffffffffc0203738:	7cc68693          	addi	a3,a3,1996 # ffffffffc0206f00 <default_pmm_manager+0x7f8>
ffffffffc020373c:	00003617          	auipc	a2,0x3
ffffffffc0203740:	c1c60613          	addi	a2,a2,-996 # ffffffffc0206358 <commands+0x850>
ffffffffc0203744:	07300593          	li	a1,115
ffffffffc0203748:	00003517          	auipc	a0,0x3
ffffffffc020374c:	76850513          	addi	a0,a0,1896 # ffffffffc0206eb0 <default_pmm_manager+0x7a8>
ffffffffc0203750:	d43fc0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203754:	00003697          	auipc	a3,0x3
ffffffffc0203758:	78c68693          	addi	a3,a3,1932 # ffffffffc0206ee0 <default_pmm_manager+0x7d8>
ffffffffc020375c:	00003617          	auipc	a2,0x3
ffffffffc0203760:	bfc60613          	addi	a2,a2,-1028 # ffffffffc0206358 <commands+0x850>
ffffffffc0203764:	07200593          	li	a1,114
ffffffffc0203768:	00003517          	auipc	a0,0x3
ffffffffc020376c:	74850513          	addi	a0,a0,1864 # ffffffffc0206eb0 <default_pmm_manager+0x7a8>
ffffffffc0203770:	d23fc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0203774 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc0203774:	591c                	lw	a5,48(a0)
{
ffffffffc0203776:	1141                	addi	sp,sp,-16
ffffffffc0203778:	e406                	sd	ra,8(sp)
ffffffffc020377a:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc020377c:	e78d                	bnez	a5,ffffffffc02037a6 <mm_destroy+0x32>
ffffffffc020377e:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203780:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc0203782:	00a40c63          	beq	s0,a0,ffffffffc020379a <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203786:	6118                	ld	a4,0(a0)
ffffffffc0203788:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc020378a:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc020378c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020378e:	e398                	sd	a4,0(a5)
ffffffffc0203790:	d52fe0ef          	jal	ra,ffffffffc0201ce2 <kfree>
    return listelm->next;
ffffffffc0203794:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc0203796:	fea418e3          	bne	s0,a0,ffffffffc0203786 <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc020379a:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc020379c:	6402                	ld	s0,0(sp)
ffffffffc020379e:	60a2                	ld	ra,8(sp)
ffffffffc02037a0:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc02037a2:	d40fe06f          	j	ffffffffc0201ce2 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc02037a6:	00003697          	auipc	a3,0x3
ffffffffc02037aa:	77a68693          	addi	a3,a3,1914 # ffffffffc0206f20 <default_pmm_manager+0x818>
ffffffffc02037ae:	00003617          	auipc	a2,0x3
ffffffffc02037b2:	baa60613          	addi	a2,a2,-1110 # ffffffffc0206358 <commands+0x850>
ffffffffc02037b6:	09e00593          	li	a1,158
ffffffffc02037ba:	00003517          	auipc	a0,0x3
ffffffffc02037be:	6f650513          	addi	a0,a0,1782 # ffffffffc0206eb0 <default_pmm_manager+0x7a8>
ffffffffc02037c2:	cd1fc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02037c6 <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
ffffffffc02037c6:	7139                	addi	sp,sp,-64
ffffffffc02037c8:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02037ca:	6405                	lui	s0,0x1
ffffffffc02037cc:	147d                	addi	s0,s0,-1
ffffffffc02037ce:	77fd                	lui	a5,0xfffff
ffffffffc02037d0:	9622                	add	a2,a2,s0
ffffffffc02037d2:	962e                	add	a2,a2,a1
{
ffffffffc02037d4:	f426                	sd	s1,40(sp)
ffffffffc02037d6:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02037d8:	00f5f4b3          	and	s1,a1,a5
{
ffffffffc02037dc:	f04a                	sd	s2,32(sp)
ffffffffc02037de:	ec4e                	sd	s3,24(sp)
ffffffffc02037e0:	e852                	sd	s4,16(sp)
ffffffffc02037e2:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end))
ffffffffc02037e4:	002005b7          	lui	a1,0x200
ffffffffc02037e8:	00f67433          	and	s0,a2,a5
ffffffffc02037ec:	06b4e363          	bltu	s1,a1,ffffffffc0203852 <mm_map+0x8c>
ffffffffc02037f0:	0684f163          	bgeu	s1,s0,ffffffffc0203852 <mm_map+0x8c>
ffffffffc02037f4:	4785                	li	a5,1
ffffffffc02037f6:	07fe                	slli	a5,a5,0x1f
ffffffffc02037f8:	0487ed63          	bltu	a5,s0,ffffffffc0203852 <mm_map+0x8c>
ffffffffc02037fc:	89aa                	mv	s3,a0
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02037fe:	cd21                	beqz	a0,ffffffffc0203856 <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc0203800:	85a6                	mv	a1,s1
ffffffffc0203802:	8ab6                	mv	s5,a3
ffffffffc0203804:	8a3a                	mv	s4,a4
ffffffffc0203806:	e5fff0ef          	jal	ra,ffffffffc0203664 <find_vma>
ffffffffc020380a:	c501                	beqz	a0,ffffffffc0203812 <mm_map+0x4c>
ffffffffc020380c:	651c                	ld	a5,8(a0)
ffffffffc020380e:	0487e263          	bltu	a5,s0,ffffffffc0203852 <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203812:	03000513          	li	a0,48
ffffffffc0203816:	c1cfe0ef          	jal	ra,ffffffffc0201c32 <kmalloc>
ffffffffc020381a:	892a                	mv	s2,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc020381c:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc020381e:	02090163          	beqz	s2,ffffffffc0203840 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0203822:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc0203824:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0203828:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc020382c:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0203830:	85ca                	mv	a1,s2
ffffffffc0203832:	e73ff0ef          	jal	ra,ffffffffc02036a4 <insert_vma_struct>
    if (vma_store != NULL)
    {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0203836:	4501                	li	a0,0
    if (vma_store != NULL)
ffffffffc0203838:	000a0463          	beqz	s4,ffffffffc0203840 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc020383c:	012a3023          	sd	s2,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8f50>

out:
    return ret;
}
ffffffffc0203840:	70e2                	ld	ra,56(sp)
ffffffffc0203842:	7442                	ld	s0,48(sp)
ffffffffc0203844:	74a2                	ld	s1,40(sp)
ffffffffc0203846:	7902                	ld	s2,32(sp)
ffffffffc0203848:	69e2                	ld	s3,24(sp)
ffffffffc020384a:	6a42                	ld	s4,16(sp)
ffffffffc020384c:	6aa2                	ld	s5,8(sp)
ffffffffc020384e:	6121                	addi	sp,sp,64
ffffffffc0203850:	8082                	ret
        return -E_INVAL;
ffffffffc0203852:	5575                	li	a0,-3
ffffffffc0203854:	b7f5                	j	ffffffffc0203840 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc0203856:	00003697          	auipc	a3,0x3
ffffffffc020385a:	6e268693          	addi	a3,a3,1762 # ffffffffc0206f38 <default_pmm_manager+0x830>
ffffffffc020385e:	00003617          	auipc	a2,0x3
ffffffffc0203862:	afa60613          	addi	a2,a2,-1286 # ffffffffc0206358 <commands+0x850>
ffffffffc0203866:	0b300593          	li	a1,179
ffffffffc020386a:	00003517          	auipc	a0,0x3
ffffffffc020386e:	64650513          	addi	a0,a0,1606 # ffffffffc0206eb0 <default_pmm_manager+0x7a8>
ffffffffc0203872:	c21fc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0203876 <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc0203876:	7139                	addi	sp,sp,-64
ffffffffc0203878:	fc06                	sd	ra,56(sp)
ffffffffc020387a:	f822                	sd	s0,48(sp)
ffffffffc020387c:	f426                	sd	s1,40(sp)
ffffffffc020387e:	f04a                	sd	s2,32(sp)
ffffffffc0203880:	ec4e                	sd	s3,24(sp)
ffffffffc0203882:	e852                	sd	s4,16(sp)
ffffffffc0203884:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0203886:	c52d                	beqz	a0,ffffffffc02038f0 <dup_mmap+0x7a>
ffffffffc0203888:	892a                	mv	s2,a0
ffffffffc020388a:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc020388c:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc020388e:	e595                	bnez	a1,ffffffffc02038ba <dup_mmap+0x44>
ffffffffc0203890:	a085                	j	ffffffffc02038f0 <dup_mmap+0x7a>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0203892:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc0203894:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_matrix_out_size+0x1f38e0>
        vma->vm_end = vm_end;
ffffffffc0203898:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc020389c:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc02038a0:	e05ff0ef          	jal	ra,ffffffffc02036a4 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc02038a4:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8f60>
ffffffffc02038a8:	fe843603          	ld	a2,-24(s0)
ffffffffc02038ac:	6c8c                	ld	a1,24(s1)
ffffffffc02038ae:	01893503          	ld	a0,24(s2)
ffffffffc02038b2:	4701                	li	a4,0
ffffffffc02038b4:	a3bff0ef          	jal	ra,ffffffffc02032ee <copy_range>
ffffffffc02038b8:	e105                	bnez	a0,ffffffffc02038d8 <dup_mmap+0x62>
    return listelm->prev;
ffffffffc02038ba:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc02038bc:	02848863          	beq	s1,s0,ffffffffc02038ec <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02038c0:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02038c4:	fe843a83          	ld	s5,-24(s0)
ffffffffc02038c8:	ff043a03          	ld	s4,-16(s0)
ffffffffc02038cc:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02038d0:	b62fe0ef          	jal	ra,ffffffffc0201c32 <kmalloc>
ffffffffc02038d4:	85aa                	mv	a1,a0
    if (vma != NULL)
ffffffffc02038d6:	fd55                	bnez	a0,ffffffffc0203892 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc02038d8:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02038da:	70e2                	ld	ra,56(sp)
ffffffffc02038dc:	7442                	ld	s0,48(sp)
ffffffffc02038de:	74a2                	ld	s1,40(sp)
ffffffffc02038e0:	7902                	ld	s2,32(sp)
ffffffffc02038e2:	69e2                	ld	s3,24(sp)
ffffffffc02038e4:	6a42                	ld	s4,16(sp)
ffffffffc02038e6:	6aa2                	ld	s5,8(sp)
ffffffffc02038e8:	6121                	addi	sp,sp,64
ffffffffc02038ea:	8082                	ret
    return 0;
ffffffffc02038ec:	4501                	li	a0,0
ffffffffc02038ee:	b7f5                	j	ffffffffc02038da <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc02038f0:	00003697          	auipc	a3,0x3
ffffffffc02038f4:	65868693          	addi	a3,a3,1624 # ffffffffc0206f48 <default_pmm_manager+0x840>
ffffffffc02038f8:	00003617          	auipc	a2,0x3
ffffffffc02038fc:	a6060613          	addi	a2,a2,-1440 # ffffffffc0206358 <commands+0x850>
ffffffffc0203900:	0cf00593          	li	a1,207
ffffffffc0203904:	00003517          	auipc	a0,0x3
ffffffffc0203908:	5ac50513          	addi	a0,a0,1452 # ffffffffc0206eb0 <default_pmm_manager+0x7a8>
ffffffffc020390c:	b87fc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0203910 <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc0203910:	1101                	addi	sp,sp,-32
ffffffffc0203912:	ec06                	sd	ra,24(sp)
ffffffffc0203914:	e822                	sd	s0,16(sp)
ffffffffc0203916:	e426                	sd	s1,8(sp)
ffffffffc0203918:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc020391a:	c531                	beqz	a0,ffffffffc0203966 <exit_mmap+0x56>
ffffffffc020391c:	591c                	lw	a5,48(a0)
ffffffffc020391e:	84aa                	mv	s1,a0
ffffffffc0203920:	e3b9                	bnez	a5,ffffffffc0203966 <exit_mmap+0x56>
    return listelm->next;
ffffffffc0203922:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0203924:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc0203928:	02850663          	beq	a0,s0,ffffffffc0203954 <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020392c:	ff043603          	ld	a2,-16(s0)
ffffffffc0203930:	fe843583          	ld	a1,-24(s0)
ffffffffc0203934:	854a                	mv	a0,s2
ffffffffc0203936:	80ffe0ef          	jal	ra,ffffffffc0202144 <unmap_range>
ffffffffc020393a:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc020393c:	fe8498e3          	bne	s1,s0,ffffffffc020392c <exit_mmap+0x1c>
ffffffffc0203940:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc0203942:	00848c63          	beq	s1,s0,ffffffffc020395a <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0203946:	ff043603          	ld	a2,-16(s0)
ffffffffc020394a:	fe843583          	ld	a1,-24(s0)
ffffffffc020394e:	854a                	mv	a0,s2
ffffffffc0203950:	93bfe0ef          	jal	ra,ffffffffc020228a <exit_range>
ffffffffc0203954:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0203956:	fe8498e3          	bne	s1,s0,ffffffffc0203946 <exit_mmap+0x36>
    }
}
ffffffffc020395a:	60e2                	ld	ra,24(sp)
ffffffffc020395c:	6442                	ld	s0,16(sp)
ffffffffc020395e:	64a2                	ld	s1,8(sp)
ffffffffc0203960:	6902                	ld	s2,0(sp)
ffffffffc0203962:	6105                	addi	sp,sp,32
ffffffffc0203964:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203966:	00003697          	auipc	a3,0x3
ffffffffc020396a:	60268693          	addi	a3,a3,1538 # ffffffffc0206f68 <default_pmm_manager+0x860>
ffffffffc020396e:	00003617          	auipc	a2,0x3
ffffffffc0203972:	9ea60613          	addi	a2,a2,-1558 # ffffffffc0206358 <commands+0x850>
ffffffffc0203976:	0e800593          	li	a1,232
ffffffffc020397a:	00003517          	auipc	a0,0x3
ffffffffc020397e:	53650513          	addi	a0,a0,1334 # ffffffffc0206eb0 <default_pmm_manager+0x7a8>
ffffffffc0203982:	b11fc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0203986 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0203986:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203988:	04000513          	li	a0,64
{
ffffffffc020398c:	fc06                	sd	ra,56(sp)
ffffffffc020398e:	f822                	sd	s0,48(sp)
ffffffffc0203990:	f426                	sd	s1,40(sp)
ffffffffc0203992:	f04a                	sd	s2,32(sp)
ffffffffc0203994:	ec4e                	sd	s3,24(sp)
ffffffffc0203996:	e852                	sd	s4,16(sp)
ffffffffc0203998:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020399a:	a98fe0ef          	jal	ra,ffffffffc0201c32 <kmalloc>
    if (mm != NULL)
ffffffffc020399e:	2e050663          	beqz	a0,ffffffffc0203c8a <vmm_init+0x304>
ffffffffc02039a2:	84aa                	mv	s1,a0
    elm->prev = elm->next = elm;
ffffffffc02039a4:	e508                	sd	a0,8(a0)
ffffffffc02039a6:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02039a8:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02039ac:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02039b0:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc02039b4:	02053423          	sd	zero,40(a0)
ffffffffc02039b8:	02052823          	sw	zero,48(a0)
ffffffffc02039bc:	02053c23          	sd	zero,56(a0)
ffffffffc02039c0:	03200413          	li	s0,50
ffffffffc02039c4:	a811                	j	ffffffffc02039d8 <vmm_init+0x52>
        vma->vm_start = vm_start;
ffffffffc02039c6:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02039c8:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02039ca:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
ffffffffc02039ce:	146d                	addi	s0,s0,-5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02039d0:	8526                	mv	a0,s1
ffffffffc02039d2:	cd3ff0ef          	jal	ra,ffffffffc02036a4 <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc02039d6:	c80d                	beqz	s0,ffffffffc0203a08 <vmm_init+0x82>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02039d8:	03000513          	li	a0,48
ffffffffc02039dc:	a56fe0ef          	jal	ra,ffffffffc0201c32 <kmalloc>
ffffffffc02039e0:	85aa                	mv	a1,a0
ffffffffc02039e2:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc02039e6:	f165                	bnez	a0,ffffffffc02039c6 <vmm_init+0x40>
        assert(vma != NULL);
ffffffffc02039e8:	00003697          	auipc	a3,0x3
ffffffffc02039ec:	71868693          	addi	a3,a3,1816 # ffffffffc0207100 <default_pmm_manager+0x9f8>
ffffffffc02039f0:	00003617          	auipc	a2,0x3
ffffffffc02039f4:	96860613          	addi	a2,a2,-1688 # ffffffffc0206358 <commands+0x850>
ffffffffc02039f8:	12c00593          	li	a1,300
ffffffffc02039fc:	00003517          	auipc	a0,0x3
ffffffffc0203a00:	4b450513          	addi	a0,a0,1204 # ffffffffc0206eb0 <default_pmm_manager+0x7a8>
ffffffffc0203a04:	a8ffc0ef          	jal	ra,ffffffffc0200492 <__panic>
ffffffffc0203a08:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203a0c:	1f900913          	li	s2,505
ffffffffc0203a10:	a819                	j	ffffffffc0203a26 <vmm_init+0xa0>
        vma->vm_start = vm_start;
ffffffffc0203a12:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203a14:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203a16:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203a1a:	0415                	addi	s0,s0,5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203a1c:	8526                	mv	a0,s1
ffffffffc0203a1e:	c87ff0ef          	jal	ra,ffffffffc02036a4 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203a22:	03240a63          	beq	s0,s2,ffffffffc0203a56 <vmm_init+0xd0>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a26:	03000513          	li	a0,48
ffffffffc0203a2a:	a08fe0ef          	jal	ra,ffffffffc0201c32 <kmalloc>
ffffffffc0203a2e:	85aa                	mv	a1,a0
ffffffffc0203a30:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0203a34:	fd79                	bnez	a0,ffffffffc0203a12 <vmm_init+0x8c>
        assert(vma != NULL);
ffffffffc0203a36:	00003697          	auipc	a3,0x3
ffffffffc0203a3a:	6ca68693          	addi	a3,a3,1738 # ffffffffc0207100 <default_pmm_manager+0x9f8>
ffffffffc0203a3e:	00003617          	auipc	a2,0x3
ffffffffc0203a42:	91a60613          	addi	a2,a2,-1766 # ffffffffc0206358 <commands+0x850>
ffffffffc0203a46:	13300593          	li	a1,307
ffffffffc0203a4a:	00003517          	auipc	a0,0x3
ffffffffc0203a4e:	46650513          	addi	a0,a0,1126 # ffffffffc0206eb0 <default_pmm_manager+0x7a8>
ffffffffc0203a52:	a41fc0ef          	jal	ra,ffffffffc0200492 <__panic>
    return listelm->next;
ffffffffc0203a56:	649c                	ld	a5,8(s1)
ffffffffc0203a58:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0203a5a:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0203a5e:	16f48663          	beq	s1,a5,ffffffffc0203bca <vmm_init+0x244>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203a62:	fe87b603          	ld	a2,-24(a5) # ffffffffffffefe8 <end+0x3fd2c7f8>
ffffffffc0203a66:	ffe70693          	addi	a3,a4,-2
ffffffffc0203a6a:	10d61063          	bne	a2,a3,ffffffffc0203b6a <vmm_init+0x1e4>
ffffffffc0203a6e:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203a72:	0ed71c63          	bne	a4,a3,ffffffffc0203b6a <vmm_init+0x1e4>
    for (i = 1; i <= step2; i++)
ffffffffc0203a76:	0715                	addi	a4,a4,5
ffffffffc0203a78:	679c                	ld	a5,8(a5)
ffffffffc0203a7a:	feb712e3          	bne	a4,a1,ffffffffc0203a5e <vmm_init+0xd8>
ffffffffc0203a7e:	4a1d                	li	s4,7
ffffffffc0203a80:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203a82:	1f900a93          	li	s5,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203a86:	85a2                	mv	a1,s0
ffffffffc0203a88:	8526                	mv	a0,s1
ffffffffc0203a8a:	bdbff0ef          	jal	ra,ffffffffc0203664 <find_vma>
ffffffffc0203a8e:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0203a90:	16050d63          	beqz	a0,ffffffffc0203c0a <vmm_init+0x284>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0203a94:	00140593          	addi	a1,s0,1
ffffffffc0203a98:	8526                	mv	a0,s1
ffffffffc0203a9a:	bcbff0ef          	jal	ra,ffffffffc0203664 <find_vma>
ffffffffc0203a9e:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203aa0:	14050563          	beqz	a0,ffffffffc0203bea <vmm_init+0x264>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0203aa4:	85d2                	mv	a1,s4
ffffffffc0203aa6:	8526                	mv	a0,s1
ffffffffc0203aa8:	bbdff0ef          	jal	ra,ffffffffc0203664 <find_vma>
        assert(vma3 == NULL);
ffffffffc0203aac:	16051f63          	bnez	a0,ffffffffc0203c2a <vmm_init+0x2a4>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0203ab0:	00340593          	addi	a1,s0,3
ffffffffc0203ab4:	8526                	mv	a0,s1
ffffffffc0203ab6:	bafff0ef          	jal	ra,ffffffffc0203664 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203aba:	1a051863          	bnez	a0,ffffffffc0203c6a <vmm_init+0x2e4>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0203abe:	00440593          	addi	a1,s0,4
ffffffffc0203ac2:	8526                	mv	a0,s1
ffffffffc0203ac4:	ba1ff0ef          	jal	ra,ffffffffc0203664 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203ac8:	18051163          	bnez	a0,ffffffffc0203c4a <vmm_init+0x2c4>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203acc:	00893783          	ld	a5,8(s2)
ffffffffc0203ad0:	0a879d63          	bne	a5,s0,ffffffffc0203b8a <vmm_init+0x204>
ffffffffc0203ad4:	01093783          	ld	a5,16(s2)
ffffffffc0203ad8:	0b479963          	bne	a5,s4,ffffffffc0203b8a <vmm_init+0x204>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203adc:	0089b783          	ld	a5,8(s3)
ffffffffc0203ae0:	0c879563          	bne	a5,s0,ffffffffc0203baa <vmm_init+0x224>
ffffffffc0203ae4:	0109b783          	ld	a5,16(s3)
ffffffffc0203ae8:	0d479163          	bne	a5,s4,ffffffffc0203baa <vmm_init+0x224>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203aec:	0415                	addi	s0,s0,5
ffffffffc0203aee:	0a15                	addi	s4,s4,5
ffffffffc0203af0:	f9541be3          	bne	s0,s5,ffffffffc0203a86 <vmm_init+0x100>
ffffffffc0203af4:	4411                	li	s0,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0203af6:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0203af8:	85a2                	mv	a1,s0
ffffffffc0203afa:	8526                	mv	a0,s1
ffffffffc0203afc:	b69ff0ef          	jal	ra,ffffffffc0203664 <find_vma>
ffffffffc0203b00:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL)
ffffffffc0203b04:	c90d                	beqz	a0,ffffffffc0203b36 <vmm_init+0x1b0>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0203b06:	6914                	ld	a3,16(a0)
ffffffffc0203b08:	6510                	ld	a2,8(a0)
ffffffffc0203b0a:	00003517          	auipc	a0,0x3
ffffffffc0203b0e:	57e50513          	addi	a0,a0,1406 # ffffffffc0207088 <default_pmm_manager+0x980>
ffffffffc0203b12:	e86fc0ef          	jal	ra,ffffffffc0200198 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203b16:	00003697          	auipc	a3,0x3
ffffffffc0203b1a:	59a68693          	addi	a3,a3,1434 # ffffffffc02070b0 <default_pmm_manager+0x9a8>
ffffffffc0203b1e:	00003617          	auipc	a2,0x3
ffffffffc0203b22:	83a60613          	addi	a2,a2,-1990 # ffffffffc0206358 <commands+0x850>
ffffffffc0203b26:	15900593          	li	a1,345
ffffffffc0203b2a:	00003517          	auipc	a0,0x3
ffffffffc0203b2e:	38650513          	addi	a0,a0,902 # ffffffffc0206eb0 <default_pmm_manager+0x7a8>
ffffffffc0203b32:	961fc0ef          	jal	ra,ffffffffc0200492 <__panic>
    for (i = 4; i >= 0; i--)
ffffffffc0203b36:	147d                	addi	s0,s0,-1
ffffffffc0203b38:	fd2410e3          	bne	s0,s2,ffffffffc0203af8 <vmm_init+0x172>
    }

    mm_destroy(mm);
ffffffffc0203b3c:	8526                	mv	a0,s1
ffffffffc0203b3e:	c37ff0ef          	jal	ra,ffffffffc0203774 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203b42:	00003517          	auipc	a0,0x3
ffffffffc0203b46:	58650513          	addi	a0,a0,1414 # ffffffffc02070c8 <default_pmm_manager+0x9c0>
ffffffffc0203b4a:	e4efc0ef          	jal	ra,ffffffffc0200198 <cprintf>
}
ffffffffc0203b4e:	7442                	ld	s0,48(sp)
ffffffffc0203b50:	70e2                	ld	ra,56(sp)
ffffffffc0203b52:	74a2                	ld	s1,40(sp)
ffffffffc0203b54:	7902                	ld	s2,32(sp)
ffffffffc0203b56:	69e2                	ld	s3,24(sp)
ffffffffc0203b58:	6a42                	ld	s4,16(sp)
ffffffffc0203b5a:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203b5c:	00003517          	auipc	a0,0x3
ffffffffc0203b60:	58c50513          	addi	a0,a0,1420 # ffffffffc02070e8 <default_pmm_manager+0x9e0>
}
ffffffffc0203b64:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203b66:	e32fc06f          	j	ffffffffc0200198 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203b6a:	00003697          	auipc	a3,0x3
ffffffffc0203b6e:	43668693          	addi	a3,a3,1078 # ffffffffc0206fa0 <default_pmm_manager+0x898>
ffffffffc0203b72:	00002617          	auipc	a2,0x2
ffffffffc0203b76:	7e660613          	addi	a2,a2,2022 # ffffffffc0206358 <commands+0x850>
ffffffffc0203b7a:	13d00593          	li	a1,317
ffffffffc0203b7e:	00003517          	auipc	a0,0x3
ffffffffc0203b82:	33250513          	addi	a0,a0,818 # ffffffffc0206eb0 <default_pmm_manager+0x7a8>
ffffffffc0203b86:	90dfc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203b8a:	00003697          	auipc	a3,0x3
ffffffffc0203b8e:	49e68693          	addi	a3,a3,1182 # ffffffffc0207028 <default_pmm_manager+0x920>
ffffffffc0203b92:	00002617          	auipc	a2,0x2
ffffffffc0203b96:	7c660613          	addi	a2,a2,1990 # ffffffffc0206358 <commands+0x850>
ffffffffc0203b9a:	14e00593          	li	a1,334
ffffffffc0203b9e:	00003517          	auipc	a0,0x3
ffffffffc0203ba2:	31250513          	addi	a0,a0,786 # ffffffffc0206eb0 <default_pmm_manager+0x7a8>
ffffffffc0203ba6:	8edfc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203baa:	00003697          	auipc	a3,0x3
ffffffffc0203bae:	4ae68693          	addi	a3,a3,1198 # ffffffffc0207058 <default_pmm_manager+0x950>
ffffffffc0203bb2:	00002617          	auipc	a2,0x2
ffffffffc0203bb6:	7a660613          	addi	a2,a2,1958 # ffffffffc0206358 <commands+0x850>
ffffffffc0203bba:	14f00593          	li	a1,335
ffffffffc0203bbe:	00003517          	auipc	a0,0x3
ffffffffc0203bc2:	2f250513          	addi	a0,a0,754 # ffffffffc0206eb0 <default_pmm_manager+0x7a8>
ffffffffc0203bc6:	8cdfc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203bca:	00003697          	auipc	a3,0x3
ffffffffc0203bce:	3be68693          	addi	a3,a3,958 # ffffffffc0206f88 <default_pmm_manager+0x880>
ffffffffc0203bd2:	00002617          	auipc	a2,0x2
ffffffffc0203bd6:	78660613          	addi	a2,a2,1926 # ffffffffc0206358 <commands+0x850>
ffffffffc0203bda:	13b00593          	li	a1,315
ffffffffc0203bde:	00003517          	auipc	a0,0x3
ffffffffc0203be2:	2d250513          	addi	a0,a0,722 # ffffffffc0206eb0 <default_pmm_manager+0x7a8>
ffffffffc0203be6:	8adfc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(vma2 != NULL);
ffffffffc0203bea:	00003697          	auipc	a3,0x3
ffffffffc0203bee:	3fe68693          	addi	a3,a3,1022 # ffffffffc0206fe8 <default_pmm_manager+0x8e0>
ffffffffc0203bf2:	00002617          	auipc	a2,0x2
ffffffffc0203bf6:	76660613          	addi	a2,a2,1894 # ffffffffc0206358 <commands+0x850>
ffffffffc0203bfa:	14600593          	li	a1,326
ffffffffc0203bfe:	00003517          	auipc	a0,0x3
ffffffffc0203c02:	2b250513          	addi	a0,a0,690 # ffffffffc0206eb0 <default_pmm_manager+0x7a8>
ffffffffc0203c06:	88dfc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(vma1 != NULL);
ffffffffc0203c0a:	00003697          	auipc	a3,0x3
ffffffffc0203c0e:	3ce68693          	addi	a3,a3,974 # ffffffffc0206fd8 <default_pmm_manager+0x8d0>
ffffffffc0203c12:	00002617          	auipc	a2,0x2
ffffffffc0203c16:	74660613          	addi	a2,a2,1862 # ffffffffc0206358 <commands+0x850>
ffffffffc0203c1a:	14400593          	li	a1,324
ffffffffc0203c1e:	00003517          	auipc	a0,0x3
ffffffffc0203c22:	29250513          	addi	a0,a0,658 # ffffffffc0206eb0 <default_pmm_manager+0x7a8>
ffffffffc0203c26:	86dfc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(vma3 == NULL);
ffffffffc0203c2a:	00003697          	auipc	a3,0x3
ffffffffc0203c2e:	3ce68693          	addi	a3,a3,974 # ffffffffc0206ff8 <default_pmm_manager+0x8f0>
ffffffffc0203c32:	00002617          	auipc	a2,0x2
ffffffffc0203c36:	72660613          	addi	a2,a2,1830 # ffffffffc0206358 <commands+0x850>
ffffffffc0203c3a:	14800593          	li	a1,328
ffffffffc0203c3e:	00003517          	auipc	a0,0x3
ffffffffc0203c42:	27250513          	addi	a0,a0,626 # ffffffffc0206eb0 <default_pmm_manager+0x7a8>
ffffffffc0203c46:	84dfc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(vma5 == NULL);
ffffffffc0203c4a:	00003697          	auipc	a3,0x3
ffffffffc0203c4e:	3ce68693          	addi	a3,a3,974 # ffffffffc0207018 <default_pmm_manager+0x910>
ffffffffc0203c52:	00002617          	auipc	a2,0x2
ffffffffc0203c56:	70660613          	addi	a2,a2,1798 # ffffffffc0206358 <commands+0x850>
ffffffffc0203c5a:	14c00593          	li	a1,332
ffffffffc0203c5e:	00003517          	auipc	a0,0x3
ffffffffc0203c62:	25250513          	addi	a0,a0,594 # ffffffffc0206eb0 <default_pmm_manager+0x7a8>
ffffffffc0203c66:	82dfc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(vma4 == NULL);
ffffffffc0203c6a:	00003697          	auipc	a3,0x3
ffffffffc0203c6e:	39e68693          	addi	a3,a3,926 # ffffffffc0207008 <default_pmm_manager+0x900>
ffffffffc0203c72:	00002617          	auipc	a2,0x2
ffffffffc0203c76:	6e660613          	addi	a2,a2,1766 # ffffffffc0206358 <commands+0x850>
ffffffffc0203c7a:	14a00593          	li	a1,330
ffffffffc0203c7e:	00003517          	auipc	a0,0x3
ffffffffc0203c82:	23250513          	addi	a0,a0,562 # ffffffffc0206eb0 <default_pmm_manager+0x7a8>
ffffffffc0203c86:	80dfc0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(mm != NULL);
ffffffffc0203c8a:	00003697          	auipc	a3,0x3
ffffffffc0203c8e:	2ae68693          	addi	a3,a3,686 # ffffffffc0206f38 <default_pmm_manager+0x830>
ffffffffc0203c92:	00002617          	auipc	a2,0x2
ffffffffc0203c96:	6c660613          	addi	a2,a2,1734 # ffffffffc0206358 <commands+0x850>
ffffffffc0203c9a:	12400593          	li	a1,292
ffffffffc0203c9e:	00003517          	auipc	a0,0x3
ffffffffc0203ca2:	21250513          	addi	a0,a0,530 # ffffffffc0206eb0 <default_pmm_manager+0x7a8>
ffffffffc0203ca6:	fecfc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0203caa <user_mem_check>:
}
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc0203caa:	7179                	addi	sp,sp,-48
ffffffffc0203cac:	f022                	sd	s0,32(sp)
ffffffffc0203cae:	f406                	sd	ra,40(sp)
ffffffffc0203cb0:	ec26                	sd	s1,24(sp)
ffffffffc0203cb2:	e84a                	sd	s2,16(sp)
ffffffffc0203cb4:	e44e                	sd	s3,8(sp)
ffffffffc0203cb6:	e052                	sd	s4,0(sp)
ffffffffc0203cb8:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc0203cba:	c135                	beqz	a0,ffffffffc0203d1e <user_mem_check+0x74>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc0203cbc:	002007b7          	lui	a5,0x200
ffffffffc0203cc0:	04f5e663          	bltu	a1,a5,ffffffffc0203d0c <user_mem_check+0x62>
ffffffffc0203cc4:	00c584b3          	add	s1,a1,a2
ffffffffc0203cc8:	0495f263          	bgeu	a1,s1,ffffffffc0203d0c <user_mem_check+0x62>
ffffffffc0203ccc:	4785                	li	a5,1
ffffffffc0203cce:	07fe                	slli	a5,a5,0x1f
ffffffffc0203cd0:	0297ee63          	bltu	a5,s1,ffffffffc0203d0c <user_mem_check+0x62>
ffffffffc0203cd4:	892a                	mv	s2,a0
ffffffffc0203cd6:	89b6                	mv	s3,a3
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203cd8:	6a05                	lui	s4,0x1
ffffffffc0203cda:	a821                	j	ffffffffc0203cf2 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203cdc:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203ce0:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203ce2:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203ce4:	c685                	beqz	a3,ffffffffc0203d0c <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203ce6:	c399                	beqz	a5,ffffffffc0203cec <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203ce8:	02e46263          	bltu	s0,a4,ffffffffc0203d0c <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0203cec:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc0203cee:	04947663          	bgeu	s0,s1,ffffffffc0203d3a <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc0203cf2:	85a2                	mv	a1,s0
ffffffffc0203cf4:	854a                	mv	a0,s2
ffffffffc0203cf6:	96fff0ef          	jal	ra,ffffffffc0203664 <find_vma>
ffffffffc0203cfa:	c909                	beqz	a0,ffffffffc0203d0c <user_mem_check+0x62>
ffffffffc0203cfc:	6518                	ld	a4,8(a0)
ffffffffc0203cfe:	00e46763          	bltu	s0,a4,ffffffffc0203d0c <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203d02:	4d1c                	lw	a5,24(a0)
ffffffffc0203d04:	fc099ce3          	bnez	s3,ffffffffc0203cdc <user_mem_check+0x32>
ffffffffc0203d08:	8b85                	andi	a5,a5,1
ffffffffc0203d0a:	f3ed                	bnez	a5,ffffffffc0203cec <user_mem_check+0x42>
            return 0;
ffffffffc0203d0c:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0203d0e:	70a2                	ld	ra,40(sp)
ffffffffc0203d10:	7402                	ld	s0,32(sp)
ffffffffc0203d12:	64e2                	ld	s1,24(sp)
ffffffffc0203d14:	6942                	ld	s2,16(sp)
ffffffffc0203d16:	69a2                	ld	s3,8(sp)
ffffffffc0203d18:	6a02                	ld	s4,0(sp)
ffffffffc0203d1a:	6145                	addi	sp,sp,48
ffffffffc0203d1c:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203d1e:	c02007b7          	lui	a5,0xc0200
ffffffffc0203d22:	4501                	li	a0,0
ffffffffc0203d24:	fef5e5e3          	bltu	a1,a5,ffffffffc0203d0e <user_mem_check+0x64>
ffffffffc0203d28:	962e                	add	a2,a2,a1
ffffffffc0203d2a:	fec5f2e3          	bgeu	a1,a2,ffffffffc0203d0e <user_mem_check+0x64>
ffffffffc0203d2e:	c8000537          	lui	a0,0xc8000
ffffffffc0203d32:	0505                	addi	a0,a0,1
ffffffffc0203d34:	00a63533          	sltu	a0,a2,a0
ffffffffc0203d38:	bfd9                	j	ffffffffc0203d0e <user_mem_check+0x64>
        return 1;
ffffffffc0203d3a:	4505                	li	a0,1
ffffffffc0203d3c:	bfc9                	j	ffffffffc0203d0e <user_mem_check+0x64>

ffffffffc0203d3e <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0203d3e:	8526                	mv	a0,s1
	jalr s0
ffffffffc0203d40:	9402                	jalr	s0

	jal do_exit
ffffffffc0203d42:	5b8000ef          	jal	ra,ffffffffc02042fa <do_exit>

ffffffffc0203d46 <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc0203d46:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203d48:	14800513          	li	a0,328
{
ffffffffc0203d4c:	e022                	sd	s0,0(sp)
ffffffffc0203d4e:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203d50:	ee3fd0ef          	jal	ra,ffffffffc0201c32 <kmalloc>
ffffffffc0203d54:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc0203d56:	cd35                	beqz	a0,ffffffffc0203dd2 <alloc_proc+0x8c>
         *       uint32_t flags;                             // Process flag
         *       char name[PROC_NAME_LEN + 1];               // Process name
         */

        /* 初始化一个新的进程控制块的最基本字段，不进行资源分配 */
        proc->state = PROC_UNINIT;        // 尚未进入就绪态
ffffffffc0203d58:	57fd                	li	a5,-1
ffffffffc0203d5a:	1782                	slli	a5,a5,0x20
ffffffffc0203d5c:	e11c                	sd	a5,0(a0)
        proc->runs = 0;                   // 运行次数计数器清零
        proc->kstack = 0;                 // 还未分配内核栈
        proc->need_resched = 0;           // 默认不请求调度
        proc->parent = NULL;              // 父进程待后续设置
        proc->mm = NULL;                  // 地址空间后续 copy/share
        memset(&proc->context, 0, sizeof(struct context)); // 确保首次 switch_to 有确定值
ffffffffc0203d5e:	07000613          	li	a2,112
ffffffffc0203d62:	4581                	li	a1,0
        proc->runs = 0;                   // 运行次数计数器清零
ffffffffc0203d64:	00052423          	sw	zero,8(a0) # ffffffffc8000008 <end+0x7d2d818>
        proc->kstack = 0;                 // 还未分配内核栈
ffffffffc0203d68:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;           // 默认不请求调度
ffffffffc0203d6c:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;              // 父进程待后续设置
ffffffffc0203d70:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;                  // 地址空间后续 copy/share
ffffffffc0203d74:	02053423          	sd	zero,40(a0)
        memset(&proc->context, 0, sizeof(struct context)); // 确保首次 switch_to 有确定值
ffffffffc0203d78:	03050513          	addi	a0,a0,48
ffffffffc0203d7c:	2fb010ef          	jal	ra,ffffffffc0205876 <memset>
        proc->tf = NULL;                  // trapframe 等栈建立后 copy_thread 设置
        proc->pgdir = boot_pgdir_pa;      // 先使用内核页表基址
ffffffffc0203d80:	000cf797          	auipc	a5,0xcf
ffffffffc0203d84:	a107b783          	ld	a5,-1520(a5) # ffffffffc02d2790 <boot_pgdir_pa>
ffffffffc0203d88:	f45c                	sd	a5,168(s0)
        proc->tf = NULL;                  // trapframe 等栈建立后 copy_thread 设置
ffffffffc0203d8a:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;                  // 初始无标志
ffffffffc0203d8e:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, sizeof(proc->name)); // 进程名清零，后续 set_proc_name
ffffffffc0203d92:	4641                	li	a2,16
ffffffffc0203d94:	4581                	li	a1,0
ffffffffc0203d96:	0b440513          	addi	a0,s0,180
ffffffffc0203d9a:	2dd010ef          	jal	ra,ffffffffc0205876 <memset>
         *       skew_heap_entry_t lab6_run_pool;            // entry in the run pool (lab6 stride)
         *       uint32_t lab6_stride;                       // stride value (lab6 stride)
         *       uint32_t lab6_priority;                     // priority value (lab6 stride)
         */
        proc->rq = NULL;                  // 运行队列指针
        list_init(&proc->run_link);       // 初始化运行链表项
ffffffffc0203d9e:	11040793          	addi	a5,s0,272
        proc->exit_code = 0;              // 退出码初始化为0
ffffffffc0203da2:	0e043423          	sd	zero,232(s0)
        proc->cptr = proc->yptr = proc->optr = NULL; // 进程关系指针初始化为NULL
ffffffffc0203da6:	0e043823          	sd	zero,240(s0)
ffffffffc0203daa:	0e043c23          	sd	zero,248(s0)
ffffffffc0203dae:	10043023          	sd	zero,256(s0)
        proc->rq = NULL;                  // 运行队列指针
ffffffffc0203db2:	10043423          	sd	zero,264(s0)
    elm->prev = elm->next = elm;
ffffffffc0203db6:	10f43c23          	sd	a5,280(s0)
ffffffffc0203dba:	10f43823          	sd	a5,272(s0)
        proc->time_slice = 0;             // 时间片初始化为0
ffffffffc0203dbe:	12042023          	sw	zero,288(s0)
        proc->lab6_run_pool.left = NULL;  // Stride堆池左孩子
        proc->lab6_run_pool.right = NULL; // Stride堆池右孩子
        proc->lab6_run_pool.parent = NULL; // Stride堆池父节点
ffffffffc0203dc2:	12043423          	sd	zero,296(s0)
        proc->lab6_run_pool.left = NULL;  // Stride堆池左孩子
ffffffffc0203dc6:	12043823          	sd	zero,304(s0)
        proc->lab6_run_pool.right = NULL; // Stride堆池右孩子
ffffffffc0203dca:	12043c23          	sd	zero,312(s0)
        proc->lab6_stride = 0;            // Stride值初始化为0
ffffffffc0203dce:	14043023          	sd	zero,320(s0)
        proc->lab6_priority = 0;          // 优先级初始化为0
    }
    return proc;
}
ffffffffc0203dd2:	60a2                	ld	ra,8(sp)
ffffffffc0203dd4:	8522                	mv	a0,s0
ffffffffc0203dd6:	6402                	ld	s0,0(sp)
ffffffffc0203dd8:	0141                	addi	sp,sp,16
ffffffffc0203dda:	8082                	ret

ffffffffc0203ddc <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc0203ddc:	000cf797          	auipc	a5,0xcf
ffffffffc0203de0:	9e47b783          	ld	a5,-1564(a5) # ffffffffc02d27c0 <current>
ffffffffc0203de4:	73c8                	ld	a0,160(a5)
ffffffffc0203de6:	968fd06f          	j	ffffffffc0200f4e <forkrets>

ffffffffc0203dea <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0203dea:	6d14                	ld	a3,24(a0)
}

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm)
{
ffffffffc0203dec:	1141                	addi	sp,sp,-16
ffffffffc0203dee:	e406                	sd	ra,8(sp)
ffffffffc0203df0:	c02007b7          	lui	a5,0xc0200
ffffffffc0203df4:	02f6ee63          	bltu	a3,a5,ffffffffc0203e30 <put_pgdir+0x46>
ffffffffc0203df8:	000cf517          	auipc	a0,0xcf
ffffffffc0203dfc:	9c053503          	ld	a0,-1600(a0) # ffffffffc02d27b8 <va_pa_offset>
ffffffffc0203e00:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage)
ffffffffc0203e02:	82b1                	srli	a3,a3,0xc
ffffffffc0203e04:	000cf797          	auipc	a5,0xcf
ffffffffc0203e08:	99c7b783          	ld	a5,-1636(a5) # ffffffffc02d27a0 <npage>
ffffffffc0203e0c:	02f6fe63          	bgeu	a3,a5,ffffffffc0203e48 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203e10:	00004517          	auipc	a0,0x4
ffffffffc0203e14:	3b053503          	ld	a0,944(a0) # ffffffffc02081c0 <nbase>
    free_page(kva2page(mm->pgdir));
}
ffffffffc0203e18:	60a2                	ld	ra,8(sp)
ffffffffc0203e1a:	8e89                	sub	a3,a3,a0
ffffffffc0203e1c:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0203e1e:	000cf517          	auipc	a0,0xcf
ffffffffc0203e22:	98a53503          	ld	a0,-1654(a0) # ffffffffc02d27a8 <pages>
ffffffffc0203e26:	4585                	li	a1,1
ffffffffc0203e28:	9536                	add	a0,a0,a3
}
ffffffffc0203e2a:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0203e2c:	822fe06f          	j	ffffffffc0201e4e <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0203e30:	00003617          	auipc	a2,0x3
ffffffffc0203e34:	9b860613          	addi	a2,a2,-1608 # ffffffffc02067e8 <default_pmm_manager+0xe0>
ffffffffc0203e38:	07700593          	li	a1,119
ffffffffc0203e3c:	00003517          	auipc	a0,0x3
ffffffffc0203e40:	92c50513          	addi	a0,a0,-1748 # ffffffffc0206768 <default_pmm_manager+0x60>
ffffffffc0203e44:	e4efc0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203e48:	00003617          	auipc	a2,0x3
ffffffffc0203e4c:	9c860613          	addi	a2,a2,-1592 # ffffffffc0206810 <default_pmm_manager+0x108>
ffffffffc0203e50:	06900593          	li	a1,105
ffffffffc0203e54:	00003517          	auipc	a0,0x3
ffffffffc0203e58:	91450513          	addi	a0,a0,-1772 # ffffffffc0206768 <default_pmm_manager+0x60>
ffffffffc0203e5c:	e36fc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0203e60 <proc_run>:
{
ffffffffc0203e60:	7179                	addi	sp,sp,-48
ffffffffc0203e62:	f026                	sd	s1,32(sp)
    if (proc != current)
ffffffffc0203e64:	000cf497          	auipc	s1,0xcf
ffffffffc0203e68:	95c48493          	addi	s1,s1,-1700 # ffffffffc02d27c0 <current>
ffffffffc0203e6c:	6098                	ld	a4,0(s1)
{
ffffffffc0203e6e:	f406                	sd	ra,40(sp)
ffffffffc0203e70:	ec4a                	sd	s2,24(sp)
    if (proc != current)
ffffffffc0203e72:	02a70763          	beq	a4,a0,ffffffffc0203ea0 <proc_run+0x40>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203e76:	100027f3          	csrr	a5,sstatus
ffffffffc0203e7a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203e7c:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203e7e:	ef85                	bnez	a5,ffffffffc0203eb6 <proc_run+0x56>
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned long pgdir)
{
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc0203e80:	755c                	ld	a5,168(a0)
ffffffffc0203e82:	56fd                	li	a3,-1
ffffffffc0203e84:	16fe                	slli	a3,a3,0x3f
ffffffffc0203e86:	83b1                	srli	a5,a5,0xc
            current = proc;
ffffffffc0203e88:	e088                	sd	a0,0(s1)
ffffffffc0203e8a:	8fd5                	or	a5,a5,a3
ffffffffc0203e8c:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(proc->context));
ffffffffc0203e90:	03050593          	addi	a1,a0,48
ffffffffc0203e94:	03070513          	addi	a0,a4,48
ffffffffc0203e98:	102010ef          	jal	ra,ffffffffc0204f9a <switch_to>
    if (flag)
ffffffffc0203e9c:	00091763          	bnez	s2,ffffffffc0203eaa <proc_run+0x4a>
}
ffffffffc0203ea0:	70a2                	ld	ra,40(sp)
ffffffffc0203ea2:	7482                	ld	s1,32(sp)
ffffffffc0203ea4:	6962                	ld	s2,24(sp)
ffffffffc0203ea6:	6145                	addi	sp,sp,48
ffffffffc0203ea8:	8082                	ret
ffffffffc0203eaa:	70a2                	ld	ra,40(sp)
ffffffffc0203eac:	7482                	ld	s1,32(sp)
ffffffffc0203eae:	6962                	ld	s2,24(sp)
ffffffffc0203eb0:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0203eb2:	af7fc06f          	j	ffffffffc02009a8 <intr_enable>
ffffffffc0203eb6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203eb8:	af7fc0ef          	jal	ra,ffffffffc02009ae <intr_disable>
            struct proc_struct *prev = current;
ffffffffc0203ebc:	6098                	ld	a4,0(s1)
        return 1;
ffffffffc0203ebe:	6522                	ld	a0,8(sp)
ffffffffc0203ec0:	4905                	li	s2,1
ffffffffc0203ec2:	bf7d                	j	ffffffffc0203e80 <proc_run+0x20>

ffffffffc0203ec4 <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf)
{
ffffffffc0203ec4:	7119                	addi	sp,sp,-128
ffffffffc0203ec6:	f4a6                	sd	s1,104(sp)
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS)
ffffffffc0203ec8:	000cf497          	auipc	s1,0xcf
ffffffffc0203ecc:	91048493          	addi	s1,s1,-1776 # ffffffffc02d27d8 <nr_process>
ffffffffc0203ed0:	4098                	lw	a4,0(s1)
{
ffffffffc0203ed2:	fc86                	sd	ra,120(sp)
ffffffffc0203ed4:	f8a2                	sd	s0,112(sp)
ffffffffc0203ed6:	f0ca                	sd	s2,96(sp)
ffffffffc0203ed8:	ecce                	sd	s3,88(sp)
ffffffffc0203eda:	e8d2                	sd	s4,80(sp)
ffffffffc0203edc:	e4d6                	sd	s5,72(sp)
ffffffffc0203ede:	e0da                	sd	s6,64(sp)
ffffffffc0203ee0:	fc5e                	sd	s7,56(sp)
ffffffffc0203ee2:	f862                	sd	s8,48(sp)
ffffffffc0203ee4:	f466                	sd	s9,40(sp)
ffffffffc0203ee6:	f06a                	sd	s10,32(sp)
ffffffffc0203ee8:	ec6e                	sd	s11,24(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0203eea:	6785                	lui	a5,0x1
ffffffffc0203eec:	30f75463          	bge	a4,a5,ffffffffc02041f4 <do_fork+0x330>
ffffffffc0203ef0:	8a2a                	mv	s4,a0
ffffffffc0203ef2:	892e                	mv	s2,a1
ffffffffc0203ef4:	89b2                	mv	s3,a2
     *    set_links:  set the relation links of process.  ALSO SEE: remove_links:  lean the relation links of process
     *    -------------------
     *    update step 1: set child proc's parent to current process, make sure current process's wait_state is 0
     *    update step 5: insert proc_struct into hash_list && proc_list, set the relation links of process
     */
    if ((proc = alloc_proc()) == NULL)
ffffffffc0203ef6:	e51ff0ef          	jal	ra,ffffffffc0203d46 <alloc_proc>
ffffffffc0203efa:	842a                	mv	s0,a0
ffffffffc0203efc:	30050363          	beqz	a0,ffffffffc0204202 <do_fork+0x33e>
    {
        goto fork_out;
    }

    proc->parent = current;
ffffffffc0203f00:	000cfb97          	auipc	s7,0xcf
ffffffffc0203f04:	8c0b8b93          	addi	s7,s7,-1856 # ffffffffc02d27c0 <current>
ffffffffc0203f08:	000bb783          	ld	a5,0(s7)
    // LAB5: 确保父进程的wait_state为0
    assert(current->wait_state == 0);
ffffffffc0203f0c:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8e64>
    proc->parent = current;
ffffffffc0203f10:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc0203f12:	2e071f63          	bnez	a4,ffffffffc0204210 <do_fork+0x34c>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0203f16:	4509                	li	a0,2
ffffffffc0203f18:	ef9fd0ef          	jal	ra,ffffffffc0201e10 <alloc_pages>
    if (page != NULL)
ffffffffc0203f1c:	2c050a63          	beqz	a0,ffffffffc02041f0 <do_fork+0x32c>
    return page - pages + nbase;
ffffffffc0203f20:	000cfc97          	auipc	s9,0xcf
ffffffffc0203f24:	888c8c93          	addi	s9,s9,-1912 # ffffffffc02d27a8 <pages>
ffffffffc0203f28:	000cb683          	ld	a3,0(s9)
ffffffffc0203f2c:	00004a97          	auipc	s5,0x4
ffffffffc0203f30:	294a8a93          	addi	s5,s5,660 # ffffffffc02081c0 <nbase>
ffffffffc0203f34:	000ab703          	ld	a4,0(s5)
ffffffffc0203f38:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0203f3c:	000cfd17          	auipc	s10,0xcf
ffffffffc0203f40:	864d0d13          	addi	s10,s10,-1948 # ffffffffc02d27a0 <npage>
    return page - pages + nbase;
ffffffffc0203f44:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0203f46:	5b7d                	li	s6,-1
ffffffffc0203f48:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc0203f4c:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0203f4e:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0203f52:	0166f633          	and	a2,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0203f56:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203f58:	2cf67c63          	bgeu	a2,a5,ffffffffc0204230 <do_fork+0x36c>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0203f5c:	000bb603          	ld	a2,0(s7)
ffffffffc0203f60:	000cfd97          	auipc	s11,0xcf
ffffffffc0203f64:	858d8d93          	addi	s11,s11,-1960 # ffffffffc02d27b8 <va_pa_offset>
ffffffffc0203f68:	000db783          	ld	a5,0(s11)
ffffffffc0203f6c:	02863b83          	ld	s7,40(a2)
ffffffffc0203f70:	e43a                	sd	a4,8(sp)
ffffffffc0203f72:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0203f74:	e814                	sd	a3,16(s0)
    if (oldmm == NULL)
ffffffffc0203f76:	020b8863          	beqz	s7,ffffffffc0203fa6 <do_fork+0xe2>
    if (clone_flags & CLONE_VM)
ffffffffc0203f7a:	100a7a13          	andi	s4,s4,256
ffffffffc0203f7e:	180a0963          	beqz	s4,ffffffffc0204110 <do_fork+0x24c>
}

static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
ffffffffc0203f82:	030ba703          	lw	a4,48(s7)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0203f86:	018bb783          	ld	a5,24(s7)
ffffffffc0203f8a:	c02006b7          	lui	a3,0xc0200
ffffffffc0203f8e:	2705                	addiw	a4,a4,1
ffffffffc0203f90:	02eba823          	sw	a4,48(s7)
    proc->mm = mm;
ffffffffc0203f94:	03743423          	sd	s7,40(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0203f98:	2ed7ec63          	bltu	a5,a3,ffffffffc0204290 <do_fork+0x3cc>
ffffffffc0203f9c:	000db703          	ld	a4,0(s11)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0203fa0:	6814                	ld	a3,16(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0203fa2:	8f99                	sub	a5,a5,a4
ffffffffc0203fa4:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0203fa6:	6789                	lui	a5,0x2
ffffffffc0203fa8:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x8070>
ffffffffc0203fac:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0203fae:	864e                	mv	a2,s3
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0203fb0:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0203fb2:	87b6                	mv	a5,a3
ffffffffc0203fb4:	12098893          	addi	a7,s3,288
ffffffffc0203fb8:	00063803          	ld	a6,0(a2)
ffffffffc0203fbc:	6608                	ld	a0,8(a2)
ffffffffc0203fbe:	6a0c                	ld	a1,16(a2)
ffffffffc0203fc0:	6e18                	ld	a4,24(a2)
ffffffffc0203fc2:	0107b023          	sd	a6,0(a5)
ffffffffc0203fc6:	e788                	sd	a0,8(a5)
ffffffffc0203fc8:	eb8c                	sd	a1,16(a5)
ffffffffc0203fca:	ef98                	sd	a4,24(a5)
ffffffffc0203fcc:	02060613          	addi	a2,a2,32
ffffffffc0203fd0:	02078793          	addi	a5,a5,32
ffffffffc0203fd4:	ff1612e3          	bne	a2,a7,ffffffffc0203fb8 <do_fork+0xf4>
    proc->tf->gpr.a0 = 0;
ffffffffc0203fd8:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x6>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0203fdc:	1c090463          	beqz	s2,ffffffffc02041a4 <do_fork+0x2e0>
    if (++last_pid >= MAX_PID)
ffffffffc0203fe0:	000ca817          	auipc	a6,0xca
ffffffffc0203fe4:	32080813          	addi	a6,a6,800 # ffffffffc02ce300 <last_pid.1>
ffffffffc0203fe8:	00082783          	lw	a5,0(a6)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0203fec:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0203ff0:	00000717          	auipc	a4,0x0
ffffffffc0203ff4:	dec70713          	addi	a4,a4,-532 # ffffffffc0203ddc <forkret>
    if (++last_pid >= MAX_PID)
ffffffffc0203ff8:	0017851b          	addiw	a0,a5,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0203ffc:	f818                	sd	a4,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0203ffe:	fc14                	sd	a3,56(s0)
    if (++last_pid >= MAX_PID)
ffffffffc0204000:	00a82023          	sw	a0,0(a6)
ffffffffc0204004:	6789                	lui	a5,0x2
ffffffffc0204006:	08f55e63          	bge	a0,a5,ffffffffc02040a2 <do_fork+0x1de>
    if (last_pid >= next_safe)
ffffffffc020400a:	000ca317          	auipc	t1,0xca
ffffffffc020400e:	2fa30313          	addi	t1,t1,762 # ffffffffc02ce304 <next_safe.0>
ffffffffc0204012:	00032783          	lw	a5,0(t1)
ffffffffc0204016:	000ce917          	auipc	s2,0xce
ffffffffc020401a:	70a90913          	addi	s2,s2,1802 # ffffffffc02d2720 <proc_list>
ffffffffc020401e:	08f55a63          	bge	a0,a5,ffffffffc02040b2 <do_fork+0x1ee>
        goto bad_fork_cleanup_kstack;
    }

    copy_thread(proc, stack, tf);

    proc->pid = get_pid();
ffffffffc0204022:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204024:	45a9                	li	a1,10
ffffffffc0204026:	2501                	sext.w	a0,a0
ffffffffc0204028:	3a8010ef          	jal	ra,ffffffffc02053d0 <hash32>
ffffffffc020402c:	02051793          	slli	a5,a0,0x20
ffffffffc0204030:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204034:	000ca797          	auipc	a5,0xca
ffffffffc0204038:	6ec78793          	addi	a5,a5,1772 # ffffffffc02ce720 <hash_list>
ffffffffc020403c:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc020403e:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204040:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204042:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc0204046:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0204048:	00893603          	ld	a2,8(s2)
    prev->next = next->prev = elm;
ffffffffc020404c:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc020404e:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0204050:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc0204054:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc0204056:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc0204058:	e21c                	sd	a5,0(a2)
ffffffffc020405a:	00f93423          	sd	a5,8(s2)
    elm->next = next;
ffffffffc020405e:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc0204060:	0d243423          	sd	s2,200(s0)
    proc->yptr = NULL;
ffffffffc0204064:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204068:	10e43023          	sd	a4,256(s0)
ffffffffc020406c:	c311                	beqz	a4,ffffffffc0204070 <do_fork+0x1ac>
        proc->optr->yptr = proc;
ffffffffc020406e:	ff60                	sd	s0,248(a4)
    nr_process++;
ffffffffc0204070:	409c                	lw	a5,0(s1)
    proc->parent->cptr = proc;
ffffffffc0204072:	fae0                	sd	s0,240(a3)
    hash_proc(proc);
    // LAB5: 使用set_links来设置进程关系链表
    set_links(proc);

    wakeup_proc(proc);
ffffffffc0204074:	8522                	mv	a0,s0
    nr_process++;
ffffffffc0204076:	2785                	addiw	a5,a5,1
ffffffffc0204078:	c09c                	sw	a5,0(s1)
    wakeup_proc(proc);
ffffffffc020407a:	0e4010ef          	jal	ra,ffffffffc020515e <wakeup_proc>

    ret = proc->pid;
ffffffffc020407e:	00442a03          	lw	s4,4(s0)
bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
ffffffffc0204082:	70e6                	ld	ra,120(sp)
ffffffffc0204084:	7446                	ld	s0,112(sp)
ffffffffc0204086:	74a6                	ld	s1,104(sp)
ffffffffc0204088:	7906                	ld	s2,96(sp)
ffffffffc020408a:	69e6                	ld	s3,88(sp)
ffffffffc020408c:	6aa6                	ld	s5,72(sp)
ffffffffc020408e:	6b06                	ld	s6,64(sp)
ffffffffc0204090:	7be2                	ld	s7,56(sp)
ffffffffc0204092:	7c42                	ld	s8,48(sp)
ffffffffc0204094:	7ca2                	ld	s9,40(sp)
ffffffffc0204096:	7d02                	ld	s10,32(sp)
ffffffffc0204098:	6de2                	ld	s11,24(sp)
ffffffffc020409a:	8552                	mv	a0,s4
ffffffffc020409c:	6a46                	ld	s4,80(sp)
ffffffffc020409e:	6109                	addi	sp,sp,128
ffffffffc02040a0:	8082                	ret
        last_pid = 1;
ffffffffc02040a2:	4785                	li	a5,1
ffffffffc02040a4:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc02040a8:	4505                	li	a0,1
ffffffffc02040aa:	000ca317          	auipc	t1,0xca
ffffffffc02040ae:	25a30313          	addi	t1,t1,602 # ffffffffc02ce304 <next_safe.0>
    return listelm->next;
ffffffffc02040b2:	000ce917          	auipc	s2,0xce
ffffffffc02040b6:	66e90913          	addi	s2,s2,1646 # ffffffffc02d2720 <proc_list>
ffffffffc02040ba:	00893e03          	ld	t3,8(s2)
        next_safe = MAX_PID;
ffffffffc02040be:	6789                	lui	a5,0x2
ffffffffc02040c0:	00f32023          	sw	a5,0(t1)
ffffffffc02040c4:	86aa                	mv	a3,a0
ffffffffc02040c6:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc02040c8:	6e89                	lui	t4,0x2
ffffffffc02040ca:	132e0763          	beq	t3,s2,ffffffffc02041f8 <do_fork+0x334>
ffffffffc02040ce:	88ae                	mv	a7,a1
ffffffffc02040d0:	87f2                	mv	a5,t3
ffffffffc02040d2:	6609                	lui	a2,0x2
ffffffffc02040d4:	a811                	j	ffffffffc02040e8 <do_fork+0x224>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc02040d6:	00e6d663          	bge	a3,a4,ffffffffc02040e2 <do_fork+0x21e>
ffffffffc02040da:	00c75463          	bge	a4,a2,ffffffffc02040e2 <do_fork+0x21e>
ffffffffc02040de:	863a                	mv	a2,a4
ffffffffc02040e0:	4885                	li	a7,1
ffffffffc02040e2:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02040e4:	01278d63          	beq	a5,s2,ffffffffc02040fe <do_fork+0x23a>
            if (proc->pid == last_pid)
ffffffffc02040e8:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x8014>
ffffffffc02040ec:	fed715e3          	bne	a4,a3,ffffffffc02040d6 <do_fork+0x212>
                if (++last_pid >= next_safe)
ffffffffc02040f0:	2685                	addiw	a3,a3,1
ffffffffc02040f2:	0ec6da63          	bge	a3,a2,ffffffffc02041e6 <do_fork+0x322>
ffffffffc02040f6:	679c                	ld	a5,8(a5)
ffffffffc02040f8:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc02040fa:	ff2797e3          	bne	a5,s2,ffffffffc02040e8 <do_fork+0x224>
ffffffffc02040fe:	c581                	beqz	a1,ffffffffc0204106 <do_fork+0x242>
ffffffffc0204100:	00d82023          	sw	a3,0(a6)
ffffffffc0204104:	8536                	mv	a0,a3
ffffffffc0204106:	f0088ee3          	beqz	a7,ffffffffc0204022 <do_fork+0x15e>
ffffffffc020410a:	00c32023          	sw	a2,0(t1)
ffffffffc020410e:	bf11                	j	ffffffffc0204022 <do_fork+0x15e>
    if ((mm = mm_create()) == NULL)
ffffffffc0204110:	d24ff0ef          	jal	ra,ffffffffc0203634 <mm_create>
ffffffffc0204114:	8c2a                	mv	s8,a0
ffffffffc0204116:	0e050b63          	beqz	a0,ffffffffc020420c <do_fork+0x348>
    if ((page = alloc_page()) == NULL)
ffffffffc020411a:	4505                	li	a0,1
ffffffffc020411c:	cf5fd0ef          	jal	ra,ffffffffc0201e10 <alloc_pages>
ffffffffc0204120:	c541                	beqz	a0,ffffffffc02041a8 <do_fork+0x2e4>
    return page - pages + nbase;
ffffffffc0204122:	000cb683          	ld	a3,0(s9)
ffffffffc0204126:	6722                	ld	a4,8(sp)
    return KADDR(page2pa(page));
ffffffffc0204128:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc020412c:	40d506b3          	sub	a3,a0,a3
ffffffffc0204130:	8699                	srai	a3,a3,0x6
ffffffffc0204132:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0204134:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0204138:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020413a:	0efb7b63          	bgeu	s6,a5,ffffffffc0204230 <do_fork+0x36c>
ffffffffc020413e:	000dba03          	ld	s4,0(s11)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204142:	6605                	lui	a2,0x1
ffffffffc0204144:	000ce597          	auipc	a1,0xce
ffffffffc0204148:	6545b583          	ld	a1,1620(a1) # ffffffffc02d2798 <boot_pgdir_va>
ffffffffc020414c:	9a36                	add	s4,s4,a3
ffffffffc020414e:	8552                	mv	a0,s4
ffffffffc0204150:	738010ef          	jal	ra,ffffffffc0205888 <memcpy>
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
ffffffffc0204154:	038b8b13          	addi	s6,s7,56
    mm->pgdir = pgdir;
ffffffffc0204158:	014c3c23          	sd	s4,24(s8)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020415c:	4785                	li	a5,1
ffffffffc020415e:	40fb37af          	amoor.d	a5,a5,(s6)
}

static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))
ffffffffc0204162:	8b85                	andi	a5,a5,1
ffffffffc0204164:	4a05                	li	s4,1
ffffffffc0204166:	c799                	beqz	a5,ffffffffc0204174 <do_fork+0x2b0>
    {
        schedule();
ffffffffc0204168:	0a8010ef          	jal	ra,ffffffffc0205210 <schedule>
ffffffffc020416c:	414b37af          	amoor.d	a5,s4,(s6)
    while (!try_lock(lock))
ffffffffc0204170:	8b85                	andi	a5,a5,1
ffffffffc0204172:	fbfd                	bnez	a5,ffffffffc0204168 <do_fork+0x2a4>
        ret = dup_mmap(mm, oldmm);
ffffffffc0204174:	85de                	mv	a1,s7
ffffffffc0204176:	8562                	mv	a0,s8
ffffffffc0204178:	efeff0ef          	jal	ra,ffffffffc0203876 <dup_mmap>
ffffffffc020417c:	8a2a                	mv	s4,a0
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020417e:	57f9                	li	a5,-2
ffffffffc0204180:	60fb37af          	amoand.d	a5,a5,(s6)
ffffffffc0204184:	8b85                	andi	a5,a5,1
}

static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))
ffffffffc0204186:	0e078963          	beqz	a5,ffffffffc0204278 <do_fork+0x3b4>
good_mm:
ffffffffc020418a:	8be2                	mv	s7,s8
    if (ret != 0)
ffffffffc020418c:	de050be3          	beqz	a0,ffffffffc0203f82 <do_fork+0xbe>
    exit_mmap(mm);
ffffffffc0204190:	8562                	mv	a0,s8
ffffffffc0204192:	f7eff0ef          	jal	ra,ffffffffc0203910 <exit_mmap>
    put_pgdir(mm);
ffffffffc0204196:	8562                	mv	a0,s8
ffffffffc0204198:	c53ff0ef          	jal	ra,ffffffffc0203dea <put_pgdir>
    mm_destroy(mm);
ffffffffc020419c:	8562                	mv	a0,s8
ffffffffc020419e:	dd6ff0ef          	jal	ra,ffffffffc0203774 <mm_destroy>
ffffffffc02041a2:	a039                	j	ffffffffc02041b0 <do_fork+0x2ec>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02041a4:	8936                	mv	s2,a3
ffffffffc02041a6:	bd2d                	j	ffffffffc0203fe0 <do_fork+0x11c>
    mm_destroy(mm);
ffffffffc02041a8:	8562                	mv	a0,s8
ffffffffc02041aa:	dcaff0ef          	jal	ra,ffffffffc0203774 <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc02041ae:	5a71                	li	s4,-4
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02041b0:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02041b2:	c02007b7          	lui	a5,0xc0200
ffffffffc02041b6:	0af6e563          	bltu	a3,a5,ffffffffc0204260 <do_fork+0x39c>
ffffffffc02041ba:	000db703          	ld	a4,0(s11)
    if (PPN(pa) >= npage)
ffffffffc02041be:	000d3783          	ld	a5,0(s10)
    return pa2page(PADDR(kva));
ffffffffc02041c2:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage)
ffffffffc02041c4:	82b1                	srli	a3,a3,0xc
ffffffffc02041c6:	08f6f163          	bgeu	a3,a5,ffffffffc0204248 <do_fork+0x384>
    return &pages[PPN(pa) - nbase];
ffffffffc02041ca:	000ab783          	ld	a5,0(s5)
ffffffffc02041ce:	000cb503          	ld	a0,0(s9)
ffffffffc02041d2:	4589                	li	a1,2
ffffffffc02041d4:	8e9d                	sub	a3,a3,a5
ffffffffc02041d6:	069a                	slli	a3,a3,0x6
ffffffffc02041d8:	9536                	add	a0,a0,a3
ffffffffc02041da:	c75fd0ef          	jal	ra,ffffffffc0201e4e <free_pages>
    kfree(proc);
ffffffffc02041de:	8522                	mv	a0,s0
ffffffffc02041e0:	b03fd0ef          	jal	ra,ffffffffc0201ce2 <kfree>
    return ret;
ffffffffc02041e4:	bd79                	j	ffffffffc0204082 <do_fork+0x1be>
                    if (last_pid >= MAX_PID)
ffffffffc02041e6:	01d6c363          	blt	a3,t4,ffffffffc02041ec <do_fork+0x328>
                        last_pid = 1;
ffffffffc02041ea:	4685                	li	a3,1
                    goto repeat;
ffffffffc02041ec:	4585                	li	a1,1
ffffffffc02041ee:	bdf1                	j	ffffffffc02040ca <do_fork+0x206>
    return -E_NO_MEM;
ffffffffc02041f0:	5a71                	li	s4,-4
ffffffffc02041f2:	b7f5                	j	ffffffffc02041de <do_fork+0x31a>
    int ret = -E_NO_FREE_PROC;
ffffffffc02041f4:	5a6d                	li	s4,-5
ffffffffc02041f6:	b571                	j	ffffffffc0204082 <do_fork+0x1be>
ffffffffc02041f8:	c599                	beqz	a1,ffffffffc0204206 <do_fork+0x342>
ffffffffc02041fa:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc02041fe:	8536                	mv	a0,a3
ffffffffc0204200:	b50d                	j	ffffffffc0204022 <do_fork+0x15e>
    ret = -E_NO_MEM;
ffffffffc0204202:	5a71                	li	s4,-4
ffffffffc0204204:	bdbd                	j	ffffffffc0204082 <do_fork+0x1be>
    return last_pid;
ffffffffc0204206:	00082503          	lw	a0,0(a6)
ffffffffc020420a:	bd21                	j	ffffffffc0204022 <do_fork+0x15e>
    int ret = -E_NO_MEM;
ffffffffc020420c:	5a71                	li	s4,-4
ffffffffc020420e:	b74d                	j	ffffffffc02041b0 <do_fork+0x2ec>
    assert(current->wait_state == 0);
ffffffffc0204210:	00003697          	auipc	a3,0x3
ffffffffc0204214:	f0068693          	addi	a3,a3,-256 # ffffffffc0207110 <default_pmm_manager+0xa08>
ffffffffc0204218:	00002617          	auipc	a2,0x2
ffffffffc020421c:	14060613          	addi	a2,a2,320 # ffffffffc0206358 <commands+0x850>
ffffffffc0204220:	1f500593          	li	a1,501
ffffffffc0204224:	00003517          	auipc	a0,0x3
ffffffffc0204228:	f0c50513          	addi	a0,a0,-244 # ffffffffc0207130 <default_pmm_manager+0xa28>
ffffffffc020422c:	a66fc0ef          	jal	ra,ffffffffc0200492 <__panic>
    return KADDR(page2pa(page));
ffffffffc0204230:	00002617          	auipc	a2,0x2
ffffffffc0204234:	51060613          	addi	a2,a2,1296 # ffffffffc0206740 <default_pmm_manager+0x38>
ffffffffc0204238:	07100593          	li	a1,113
ffffffffc020423c:	00002517          	auipc	a0,0x2
ffffffffc0204240:	52c50513          	addi	a0,a0,1324 # ffffffffc0206768 <default_pmm_manager+0x60>
ffffffffc0204244:	a4efc0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204248:	00002617          	auipc	a2,0x2
ffffffffc020424c:	5c860613          	addi	a2,a2,1480 # ffffffffc0206810 <default_pmm_manager+0x108>
ffffffffc0204250:	06900593          	li	a1,105
ffffffffc0204254:	00002517          	auipc	a0,0x2
ffffffffc0204258:	51450513          	addi	a0,a0,1300 # ffffffffc0206768 <default_pmm_manager+0x60>
ffffffffc020425c:	a36fc0ef          	jal	ra,ffffffffc0200492 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0204260:	00002617          	auipc	a2,0x2
ffffffffc0204264:	58860613          	addi	a2,a2,1416 # ffffffffc02067e8 <default_pmm_manager+0xe0>
ffffffffc0204268:	07700593          	li	a1,119
ffffffffc020426c:	00002517          	auipc	a0,0x2
ffffffffc0204270:	4fc50513          	addi	a0,a0,1276 # ffffffffc0206768 <default_pmm_manager+0x60>
ffffffffc0204274:	a1efc0ef          	jal	ra,ffffffffc0200492 <__panic>
    {
        panic("Unlock failed.\n");
ffffffffc0204278:	00003617          	auipc	a2,0x3
ffffffffc020427c:	ed060613          	addi	a2,a2,-304 # ffffffffc0207148 <default_pmm_manager+0xa40>
ffffffffc0204280:	04000593          	li	a1,64
ffffffffc0204284:	00003517          	auipc	a0,0x3
ffffffffc0204288:	ed450513          	addi	a0,a0,-300 # ffffffffc0207158 <default_pmm_manager+0xa50>
ffffffffc020428c:	a06fc0ef          	jal	ra,ffffffffc0200492 <__panic>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204290:	86be                	mv	a3,a5
ffffffffc0204292:	00002617          	auipc	a2,0x2
ffffffffc0204296:	55660613          	addi	a2,a2,1366 # ffffffffc02067e8 <default_pmm_manager+0xe0>
ffffffffc020429a:	1a400593          	li	a1,420
ffffffffc020429e:	00003517          	auipc	a0,0x3
ffffffffc02042a2:	e9250513          	addi	a0,a0,-366 # ffffffffc0207130 <default_pmm_manager+0xa28>
ffffffffc02042a6:	9ecfc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02042aa <kernel_thread>:
{
ffffffffc02042aa:	7129                	addi	sp,sp,-320
ffffffffc02042ac:	fa22                	sd	s0,304(sp)
ffffffffc02042ae:	f626                	sd	s1,296(sp)
ffffffffc02042b0:	f24a                	sd	s2,288(sp)
ffffffffc02042b2:	84ae                	mv	s1,a1
ffffffffc02042b4:	892a                	mv	s2,a0
ffffffffc02042b6:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02042b8:	4581                	li	a1,0
ffffffffc02042ba:	12000613          	li	a2,288
ffffffffc02042be:	850a                	mv	a0,sp
{
ffffffffc02042c0:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02042c2:	5b4010ef          	jal	ra,ffffffffc0205876 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02042c6:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02042c8:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02042ca:	100027f3          	csrr	a5,sstatus
ffffffffc02042ce:	edd7f793          	andi	a5,a5,-291
ffffffffc02042d2:	1207e793          	ori	a5,a5,288
ffffffffc02042d6:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02042d8:	860a                	mv	a2,sp
ffffffffc02042da:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02042de:	00000797          	auipc	a5,0x0
ffffffffc02042e2:	a6078793          	addi	a5,a5,-1440 # ffffffffc0203d3e <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02042e6:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02042e8:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02042ea:	bdbff0ef          	jal	ra,ffffffffc0203ec4 <do_fork>
}
ffffffffc02042ee:	70f2                	ld	ra,312(sp)
ffffffffc02042f0:	7452                	ld	s0,304(sp)
ffffffffc02042f2:	74b2                	ld	s1,296(sp)
ffffffffc02042f4:	7912                	ld	s2,288(sp)
ffffffffc02042f6:	6131                	addi	sp,sp,320
ffffffffc02042f8:	8082                	ret

ffffffffc02042fa <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int do_exit(int error_code)
{
ffffffffc02042fa:	7179                	addi	sp,sp,-48
ffffffffc02042fc:	f022                	sd	s0,32(sp)
    if (current == idleproc)
ffffffffc02042fe:	000ce417          	auipc	s0,0xce
ffffffffc0204302:	4c240413          	addi	s0,s0,1218 # ffffffffc02d27c0 <current>
ffffffffc0204306:	601c                	ld	a5,0(s0)
{
ffffffffc0204308:	f406                	sd	ra,40(sp)
ffffffffc020430a:	ec26                	sd	s1,24(sp)
ffffffffc020430c:	e84a                	sd	s2,16(sp)
ffffffffc020430e:	e44e                	sd	s3,8(sp)
ffffffffc0204310:	e052                	sd	s4,0(sp)
    if (current == idleproc)
ffffffffc0204312:	000ce717          	auipc	a4,0xce
ffffffffc0204316:	4b673703          	ld	a4,1206(a4) # ffffffffc02d27c8 <idleproc>
ffffffffc020431a:	0ce78c63          	beq	a5,a4,ffffffffc02043f2 <do_exit+0xf8>
    {
        panic("idleproc exit.\n");
    }
    if (current == initproc)
ffffffffc020431e:	000ce497          	auipc	s1,0xce
ffffffffc0204322:	4b248493          	addi	s1,s1,1202 # ffffffffc02d27d0 <initproc>
ffffffffc0204326:	6098                	ld	a4,0(s1)
ffffffffc0204328:	0ee78b63          	beq	a5,a4,ffffffffc020441e <do_exit+0x124>
    {
        panic("initproc exit.\n");
    }
    struct mm_struct *mm = current->mm;
ffffffffc020432c:	0287b983          	ld	s3,40(a5)
ffffffffc0204330:	892a                	mv	s2,a0
    if (mm != NULL)
ffffffffc0204332:	02098663          	beqz	s3,ffffffffc020435e <do_exit+0x64>
ffffffffc0204336:	000ce797          	auipc	a5,0xce
ffffffffc020433a:	45a7b783          	ld	a5,1114(a5) # ffffffffc02d2790 <boot_pgdir_pa>
ffffffffc020433e:	577d                	li	a4,-1
ffffffffc0204340:	177e                	slli	a4,a4,0x3f
ffffffffc0204342:	83b1                	srli	a5,a5,0xc
ffffffffc0204344:	8fd9                	or	a5,a5,a4
ffffffffc0204346:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc020434a:	0309a783          	lw	a5,48(s3)
ffffffffc020434e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204352:	02e9a823          	sw	a4,48(s3)
    {
        lsatp(boot_pgdir_pa);
        if (mm_count_dec(mm) == 0)
ffffffffc0204356:	cb55                	beqz	a4,ffffffffc020440a <do_exit+0x110>
        {
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);
        }
        current->mm = NULL;
ffffffffc0204358:	601c                	ld	a5,0(s0)
ffffffffc020435a:	0207b423          	sd	zero,40(a5)
    }
    current->state = PROC_ZOMBIE;
ffffffffc020435e:	601c                	ld	a5,0(s0)
ffffffffc0204360:	470d                	li	a4,3
ffffffffc0204362:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0204364:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204368:	100027f3          	csrr	a5,sstatus
ffffffffc020436c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020436e:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204370:	e3f9                	bnez	a5,ffffffffc0204436 <do_exit+0x13c>
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
    {
        proc = current->parent;
ffffffffc0204372:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204374:	800007b7          	lui	a5,0x80000
ffffffffc0204378:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc020437a:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc020437c:	0ec52703          	lw	a4,236(a0)
ffffffffc0204380:	0af70f63          	beq	a4,a5,ffffffffc020443e <do_exit+0x144>
        {
            wakeup_proc(proc);
        }
        while (current->cptr != NULL)
ffffffffc0204384:	6018                	ld	a4,0(s0)
ffffffffc0204386:	7b7c                	ld	a5,240(a4)
ffffffffc0204388:	c3a1                	beqz	a5,ffffffffc02043c8 <do_exit+0xce>
            }
            proc->parent = initproc;
            initproc->cptr = proc;
            if (proc->state == PROC_ZOMBIE)
            {
                if (initproc->wait_state == WT_CHILD)
ffffffffc020438a:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE)
ffffffffc020438e:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204390:	0985                	addi	s3,s3,1
ffffffffc0204392:	a021                	j	ffffffffc020439a <do_exit+0xa0>
        while (current->cptr != NULL)
ffffffffc0204394:	6018                	ld	a4,0(s0)
ffffffffc0204396:	7b7c                	ld	a5,240(a4)
ffffffffc0204398:	cb85                	beqz	a5,ffffffffc02043c8 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc020439a:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_matrix_out_size+0xffffffff7fff39d8>
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc020439e:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc02043a0:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc02043a2:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc02043a4:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc02043a8:	10e7b023          	sd	a4,256(a5)
ffffffffc02043ac:	c311                	beqz	a4,ffffffffc02043b0 <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc02043ae:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc02043b0:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02043b2:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02043b4:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc02043b6:	fd271fe3          	bne	a4,s2,ffffffffc0204394 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc02043ba:	0ec52783          	lw	a5,236(a0)
ffffffffc02043be:	fd379be3          	bne	a5,s3,ffffffffc0204394 <do_exit+0x9a>
                {
                    wakeup_proc(initproc);
ffffffffc02043c2:	59d000ef          	jal	ra,ffffffffc020515e <wakeup_proc>
ffffffffc02043c6:	b7f9                	j	ffffffffc0204394 <do_exit+0x9a>
    if (flag)
ffffffffc02043c8:	020a1263          	bnez	s4,ffffffffc02043ec <do_exit+0xf2>
                }
            }
        }
    }
    local_intr_restore(intr_flag);
    schedule();
ffffffffc02043cc:	645000ef          	jal	ra,ffffffffc0205210 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc02043d0:	601c                	ld	a5,0(s0)
ffffffffc02043d2:	00003617          	auipc	a2,0x3
ffffffffc02043d6:	dbe60613          	addi	a2,a2,-578 # ffffffffc0207190 <default_pmm_manager+0xa88>
ffffffffc02043da:	25300593          	li	a1,595
ffffffffc02043de:	43d4                	lw	a3,4(a5)
ffffffffc02043e0:	00003517          	auipc	a0,0x3
ffffffffc02043e4:	d5050513          	addi	a0,a0,-688 # ffffffffc0207130 <default_pmm_manager+0xa28>
ffffffffc02043e8:	8aafc0ef          	jal	ra,ffffffffc0200492 <__panic>
        intr_enable();
ffffffffc02043ec:	dbcfc0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc02043f0:	bff1                	j	ffffffffc02043cc <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc02043f2:	00003617          	auipc	a2,0x3
ffffffffc02043f6:	d7e60613          	addi	a2,a2,-642 # ffffffffc0207170 <default_pmm_manager+0xa68>
ffffffffc02043fa:	21f00593          	li	a1,543
ffffffffc02043fe:	00003517          	auipc	a0,0x3
ffffffffc0204402:	d3250513          	addi	a0,a0,-718 # ffffffffc0207130 <default_pmm_manager+0xa28>
ffffffffc0204406:	88cfc0ef          	jal	ra,ffffffffc0200492 <__panic>
            exit_mmap(mm);
ffffffffc020440a:	854e                	mv	a0,s3
ffffffffc020440c:	d04ff0ef          	jal	ra,ffffffffc0203910 <exit_mmap>
            put_pgdir(mm);
ffffffffc0204410:	854e                	mv	a0,s3
ffffffffc0204412:	9d9ff0ef          	jal	ra,ffffffffc0203dea <put_pgdir>
            mm_destroy(mm);
ffffffffc0204416:	854e                	mv	a0,s3
ffffffffc0204418:	b5cff0ef          	jal	ra,ffffffffc0203774 <mm_destroy>
ffffffffc020441c:	bf35                	j	ffffffffc0204358 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc020441e:	00003617          	auipc	a2,0x3
ffffffffc0204422:	d6260613          	addi	a2,a2,-670 # ffffffffc0207180 <default_pmm_manager+0xa78>
ffffffffc0204426:	22300593          	li	a1,547
ffffffffc020442a:	00003517          	auipc	a0,0x3
ffffffffc020442e:	d0650513          	addi	a0,a0,-762 # ffffffffc0207130 <default_pmm_manager+0xa28>
ffffffffc0204432:	860fc0ef          	jal	ra,ffffffffc0200492 <__panic>
        intr_disable();
ffffffffc0204436:	d78fc0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        return 1;
ffffffffc020443a:	4a05                	li	s4,1
ffffffffc020443c:	bf1d                	j	ffffffffc0204372 <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc020443e:	521000ef          	jal	ra,ffffffffc020515e <wakeup_proc>
ffffffffc0204442:	b789                	j	ffffffffc0204384 <do_exit+0x8a>

ffffffffc0204444 <do_wait.part.0>:
}

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int do_wait(int pid, int *code_store)
ffffffffc0204444:	715d                	addi	sp,sp,-80
ffffffffc0204446:	f84a                	sd	s2,48(sp)
ffffffffc0204448:	f44e                	sd	s3,40(sp)
        }
    }
    if (haskid)
    {
        current->state = PROC_SLEEPING;
        current->wait_state = WT_CHILD;
ffffffffc020444a:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID)
ffffffffc020444e:	6989                	lui	s3,0x2
int do_wait(int pid, int *code_store)
ffffffffc0204450:	fc26                	sd	s1,56(sp)
ffffffffc0204452:	f052                	sd	s4,32(sp)
ffffffffc0204454:	ec56                	sd	s5,24(sp)
ffffffffc0204456:	e85a                	sd	s6,16(sp)
ffffffffc0204458:	e45e                	sd	s7,8(sp)
ffffffffc020445a:	e486                	sd	ra,72(sp)
ffffffffc020445c:	e0a2                	sd	s0,64(sp)
ffffffffc020445e:	84aa                	mv	s1,a0
ffffffffc0204460:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc0204462:	000ceb97          	auipc	s7,0xce
ffffffffc0204466:	35eb8b93          	addi	s7,s7,862 # ffffffffc02d27c0 <current>
    if (0 < pid && pid < MAX_PID)
ffffffffc020446a:	00050b1b          	sext.w	s6,a0
ffffffffc020446e:	fff50a9b          	addiw	s5,a0,-1
ffffffffc0204472:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc0204474:	0905                	addi	s2,s2,1
    if (pid != 0)
ffffffffc0204476:	ccbd                	beqz	s1,ffffffffc02044f4 <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204478:	0359e863          	bltu	s3,s5,ffffffffc02044a8 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020447c:	45a9                	li	a1,10
ffffffffc020447e:	855a                	mv	a0,s6
ffffffffc0204480:	751000ef          	jal	ra,ffffffffc02053d0 <hash32>
ffffffffc0204484:	02051793          	slli	a5,a0,0x20
ffffffffc0204488:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020448c:	000ca797          	auipc	a5,0xca
ffffffffc0204490:	29478793          	addi	a5,a5,660 # ffffffffc02ce720 <hash_list>
ffffffffc0204494:	953e                	add	a0,a0,a5
ffffffffc0204496:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list)
ffffffffc0204498:	a029                	j	ffffffffc02044a2 <do_wait.part.0+0x5e>
            if (proc->pid == pid)
ffffffffc020449a:	f2c42783          	lw	a5,-212(s0)
ffffffffc020449e:	02978163          	beq	a5,s1,ffffffffc02044c0 <do_wait.part.0+0x7c>
ffffffffc02044a2:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list)
ffffffffc02044a4:	fe851be3          	bne	a0,s0,ffffffffc020449a <do_wait.part.0+0x56>
        {
            do_exit(-E_KILLED);
        }
        goto repeat;
    }
    return -E_BAD_PROC;
ffffffffc02044a8:	5579                	li	a0,-2
    }
    local_intr_restore(intr_flag);
    put_kstack(proc);
    kfree(proc);
    return 0;
}
ffffffffc02044aa:	60a6                	ld	ra,72(sp)
ffffffffc02044ac:	6406                	ld	s0,64(sp)
ffffffffc02044ae:	74e2                	ld	s1,56(sp)
ffffffffc02044b0:	7942                	ld	s2,48(sp)
ffffffffc02044b2:	79a2                	ld	s3,40(sp)
ffffffffc02044b4:	7a02                	ld	s4,32(sp)
ffffffffc02044b6:	6ae2                	ld	s5,24(sp)
ffffffffc02044b8:	6b42                	ld	s6,16(sp)
ffffffffc02044ba:	6ba2                	ld	s7,8(sp)
ffffffffc02044bc:	6161                	addi	sp,sp,80
ffffffffc02044be:	8082                	ret
        if (proc != NULL && proc->parent == current)
ffffffffc02044c0:	000bb683          	ld	a3,0(s7)
ffffffffc02044c4:	f4843783          	ld	a5,-184(s0)
ffffffffc02044c8:	fed790e3          	bne	a5,a3,ffffffffc02044a8 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02044cc:	f2842703          	lw	a4,-216(s0)
ffffffffc02044d0:	478d                	li	a5,3
ffffffffc02044d2:	0ef70b63          	beq	a4,a5,ffffffffc02045c8 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc02044d6:	4785                	li	a5,1
ffffffffc02044d8:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc02044da:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc02044de:	533000ef          	jal	ra,ffffffffc0205210 <schedule>
        if (current->flags & PF_EXITING)
ffffffffc02044e2:	000bb783          	ld	a5,0(s7)
ffffffffc02044e6:	0b07a783          	lw	a5,176(a5)
ffffffffc02044ea:	8b85                	andi	a5,a5,1
ffffffffc02044ec:	d7c9                	beqz	a5,ffffffffc0204476 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc02044ee:	555d                	li	a0,-9
ffffffffc02044f0:	e0bff0ef          	jal	ra,ffffffffc02042fa <do_exit>
        proc = current->cptr;
ffffffffc02044f4:	000bb683          	ld	a3,0(s7)
ffffffffc02044f8:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr)
ffffffffc02044fa:	d45d                	beqz	s0,ffffffffc02044a8 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02044fc:	470d                	li	a4,3
ffffffffc02044fe:	a021                	j	ffffffffc0204506 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr)
ffffffffc0204500:	10043403          	ld	s0,256(s0)
ffffffffc0204504:	d869                	beqz	s0,ffffffffc02044d6 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204506:	401c                	lw	a5,0(s0)
ffffffffc0204508:	fee79ce3          	bne	a5,a4,ffffffffc0204500 <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc)
ffffffffc020450c:	000ce797          	auipc	a5,0xce
ffffffffc0204510:	2bc7b783          	ld	a5,700(a5) # ffffffffc02d27c8 <idleproc>
ffffffffc0204514:	0c878963          	beq	a5,s0,ffffffffc02045e6 <do_wait.part.0+0x1a2>
ffffffffc0204518:	000ce797          	auipc	a5,0xce
ffffffffc020451c:	2b87b783          	ld	a5,696(a5) # ffffffffc02d27d0 <initproc>
ffffffffc0204520:	0cf40363          	beq	s0,a5,ffffffffc02045e6 <do_wait.part.0+0x1a2>
    if (code_store != NULL)
ffffffffc0204524:	000a0663          	beqz	s4,ffffffffc0204530 <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc0204528:	0e842783          	lw	a5,232(s0)
ffffffffc020452c:	00fa2023          	sw	a5,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8f50>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204530:	100027f3          	csrr	a5,sstatus
ffffffffc0204534:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204536:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204538:	e7c1                	bnez	a5,ffffffffc02045c0 <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc020453a:	6c70                	ld	a2,216(s0)
ffffffffc020453c:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL)
ffffffffc020453e:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc0204542:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0204544:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0204546:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204548:	6470                	ld	a2,200(s0)
ffffffffc020454a:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc020454c:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020454e:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL)
ffffffffc0204550:	c319                	beqz	a4,ffffffffc0204556 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc0204552:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL)
ffffffffc0204554:	7c7c                	ld	a5,248(s0)
ffffffffc0204556:	c3b5                	beqz	a5,ffffffffc02045ba <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc0204558:	10e7b023          	sd	a4,256(a5)
    nr_process--;
ffffffffc020455c:	000ce717          	auipc	a4,0xce
ffffffffc0204560:	27c70713          	addi	a4,a4,636 # ffffffffc02d27d8 <nr_process>
ffffffffc0204564:	431c                	lw	a5,0(a4)
ffffffffc0204566:	37fd                	addiw	a5,a5,-1
ffffffffc0204568:	c31c                	sw	a5,0(a4)
    if (flag)
ffffffffc020456a:	e5a9                	bnez	a1,ffffffffc02045b4 <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020456c:	6814                	ld	a3,16(s0)
ffffffffc020456e:	c02007b7          	lui	a5,0xc0200
ffffffffc0204572:	04f6ee63          	bltu	a3,a5,ffffffffc02045ce <do_wait.part.0+0x18a>
ffffffffc0204576:	000ce797          	auipc	a5,0xce
ffffffffc020457a:	2427b783          	ld	a5,578(a5) # ffffffffc02d27b8 <va_pa_offset>
ffffffffc020457e:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage)
ffffffffc0204580:	82b1                	srli	a3,a3,0xc
ffffffffc0204582:	000ce797          	auipc	a5,0xce
ffffffffc0204586:	21e7b783          	ld	a5,542(a5) # ffffffffc02d27a0 <npage>
ffffffffc020458a:	06f6fa63          	bgeu	a3,a5,ffffffffc02045fe <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc020458e:	00004517          	auipc	a0,0x4
ffffffffc0204592:	c3253503          	ld	a0,-974(a0) # ffffffffc02081c0 <nbase>
ffffffffc0204596:	8e89                	sub	a3,a3,a0
ffffffffc0204598:	069a                	slli	a3,a3,0x6
ffffffffc020459a:	000ce517          	auipc	a0,0xce
ffffffffc020459e:	20e53503          	ld	a0,526(a0) # ffffffffc02d27a8 <pages>
ffffffffc02045a2:	9536                	add	a0,a0,a3
ffffffffc02045a4:	4589                	li	a1,2
ffffffffc02045a6:	8a9fd0ef          	jal	ra,ffffffffc0201e4e <free_pages>
    kfree(proc);
ffffffffc02045aa:	8522                	mv	a0,s0
ffffffffc02045ac:	f36fd0ef          	jal	ra,ffffffffc0201ce2 <kfree>
    return 0;
ffffffffc02045b0:	4501                	li	a0,0
ffffffffc02045b2:	bde5                	j	ffffffffc02044aa <do_wait.part.0+0x66>
        intr_enable();
ffffffffc02045b4:	bf4fc0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc02045b8:	bf55                	j	ffffffffc020456c <do_wait.part.0+0x128>
        proc->parent->cptr = proc->optr;
ffffffffc02045ba:	701c                	ld	a5,32(s0)
ffffffffc02045bc:	fbf8                	sd	a4,240(a5)
ffffffffc02045be:	bf79                	j	ffffffffc020455c <do_wait.part.0+0x118>
        intr_disable();
ffffffffc02045c0:	beefc0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        return 1;
ffffffffc02045c4:	4585                	li	a1,1
ffffffffc02045c6:	bf95                	j	ffffffffc020453a <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02045c8:	f2840413          	addi	s0,s0,-216
ffffffffc02045cc:	b781                	j	ffffffffc020450c <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc02045ce:	00002617          	auipc	a2,0x2
ffffffffc02045d2:	21a60613          	addi	a2,a2,538 # ffffffffc02067e8 <default_pmm_manager+0xe0>
ffffffffc02045d6:	07700593          	li	a1,119
ffffffffc02045da:	00002517          	auipc	a0,0x2
ffffffffc02045de:	18e50513          	addi	a0,a0,398 # ffffffffc0206768 <default_pmm_manager+0x60>
ffffffffc02045e2:	eb1fb0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc02045e6:	00003617          	auipc	a2,0x3
ffffffffc02045ea:	bca60613          	addi	a2,a2,-1078 # ffffffffc02071b0 <default_pmm_manager+0xaa8>
ffffffffc02045ee:	37700593          	li	a1,887
ffffffffc02045f2:	00003517          	auipc	a0,0x3
ffffffffc02045f6:	b3e50513          	addi	a0,a0,-1218 # ffffffffc0207130 <default_pmm_manager+0xa28>
ffffffffc02045fa:	e99fb0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02045fe:	00002617          	auipc	a2,0x2
ffffffffc0204602:	21260613          	addi	a2,a2,530 # ffffffffc0206810 <default_pmm_manager+0x108>
ffffffffc0204606:	06900593          	li	a1,105
ffffffffc020460a:	00002517          	auipc	a0,0x2
ffffffffc020460e:	15e50513          	addi	a0,a0,350 # ffffffffc0206768 <default_pmm_manager+0x60>
ffffffffc0204612:	e81fb0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0204616 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc0204616:	1141                	addi	sp,sp,-16
ffffffffc0204618:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020461a:	875fd0ef          	jal	ra,ffffffffc0201e8e <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc020461e:	e10fd0ef          	jal	ra,ffffffffc0201c2e <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0204622:	4601                	li	a2,0
ffffffffc0204624:	4581                	li	a1,0
ffffffffc0204626:	00000517          	auipc	a0,0x0
ffffffffc020462a:	62850513          	addi	a0,a0,1576 # ffffffffc0204c4e <user_main>
ffffffffc020462e:	c7dff0ef          	jal	ra,ffffffffc02042aa <kernel_thread>
    if (pid <= 0)
ffffffffc0204632:	00a04563          	bgtz	a0,ffffffffc020463c <init_main+0x26>
ffffffffc0204636:	a071                	j	ffffffffc02046c2 <init_main+0xac>
    }

    int wait_result;
    while ((wait_result = do_wait(0, NULL)) == 0)
    {
        schedule();
ffffffffc0204638:	3d9000ef          	jal	ra,ffffffffc0205210 <schedule>
    if (code_store != NULL)
ffffffffc020463c:	4581                	li	a1,0
ffffffffc020463e:	4501                	li	a0,0
ffffffffc0204640:	e05ff0ef          	jal	ra,ffffffffc0204444 <do_wait.part.0>
    while ((wait_result = do_wait(0, NULL)) == 0)
ffffffffc0204644:	d975                	beqz	a0,ffffffffc0204638 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0204646:	00003517          	auipc	a0,0x3
ffffffffc020464a:	baa50513          	addi	a0,a0,-1110 # ffffffffc02071f0 <default_pmm_manager+0xae8>
ffffffffc020464e:	b4bfb0ef          	jal	ra,ffffffffc0200198 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204652:	000ce797          	auipc	a5,0xce
ffffffffc0204656:	17e7b783          	ld	a5,382(a5) # ffffffffc02d27d0 <initproc>
ffffffffc020465a:	7bf8                	ld	a4,240(a5)
ffffffffc020465c:	e339                	bnez	a4,ffffffffc02046a2 <init_main+0x8c>
ffffffffc020465e:	7ff8                	ld	a4,248(a5)
ffffffffc0204660:	e329                	bnez	a4,ffffffffc02046a2 <init_main+0x8c>
ffffffffc0204662:	1007b703          	ld	a4,256(a5)
ffffffffc0204666:	ef15                	bnez	a4,ffffffffc02046a2 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc0204668:	000ce697          	auipc	a3,0xce
ffffffffc020466c:	1706a683          	lw	a3,368(a3) # ffffffffc02d27d8 <nr_process>
ffffffffc0204670:	4709                	li	a4,2
ffffffffc0204672:	0ae69463          	bne	a3,a4,ffffffffc020471a <init_main+0x104>
    return listelm->next;
ffffffffc0204676:	000ce697          	auipc	a3,0xce
ffffffffc020467a:	0aa68693          	addi	a3,a3,170 # ffffffffc02d2720 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020467e:	6698                	ld	a4,8(a3)
ffffffffc0204680:	0c878793          	addi	a5,a5,200
ffffffffc0204684:	06f71b63          	bne	a4,a5,ffffffffc02046fa <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204688:	629c                	ld	a5,0(a3)
ffffffffc020468a:	04f71863          	bne	a4,a5,ffffffffc02046da <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc020468e:	00003517          	auipc	a0,0x3
ffffffffc0204692:	c4a50513          	addi	a0,a0,-950 # ffffffffc02072d8 <default_pmm_manager+0xbd0>
ffffffffc0204696:	b03fb0ef          	jal	ra,ffffffffc0200198 <cprintf>
    return 0;
}
ffffffffc020469a:	60a2                	ld	ra,8(sp)
ffffffffc020469c:	4501                	li	a0,0
ffffffffc020469e:	0141                	addi	sp,sp,16
ffffffffc02046a0:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02046a2:	00003697          	auipc	a3,0x3
ffffffffc02046a6:	b7668693          	addi	a3,a3,-1162 # ffffffffc0207218 <default_pmm_manager+0xb10>
ffffffffc02046aa:	00002617          	auipc	a2,0x2
ffffffffc02046ae:	cae60613          	addi	a2,a2,-850 # ffffffffc0206358 <commands+0x850>
ffffffffc02046b2:	3e400593          	li	a1,996
ffffffffc02046b6:	00003517          	auipc	a0,0x3
ffffffffc02046ba:	a7a50513          	addi	a0,a0,-1414 # ffffffffc0207130 <default_pmm_manager+0xa28>
ffffffffc02046be:	dd5fb0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("create user_main failed.\n");
ffffffffc02046c2:	00003617          	auipc	a2,0x3
ffffffffc02046c6:	b0e60613          	addi	a2,a2,-1266 # ffffffffc02071d0 <default_pmm_manager+0xac8>
ffffffffc02046ca:	3da00593          	li	a1,986
ffffffffc02046ce:	00003517          	auipc	a0,0x3
ffffffffc02046d2:	a6250513          	addi	a0,a0,-1438 # ffffffffc0207130 <default_pmm_manager+0xa28>
ffffffffc02046d6:	dbdfb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02046da:	00003697          	auipc	a3,0x3
ffffffffc02046de:	bce68693          	addi	a3,a3,-1074 # ffffffffc02072a8 <default_pmm_manager+0xba0>
ffffffffc02046e2:	00002617          	auipc	a2,0x2
ffffffffc02046e6:	c7660613          	addi	a2,a2,-906 # ffffffffc0206358 <commands+0x850>
ffffffffc02046ea:	3e700593          	li	a1,999
ffffffffc02046ee:	00003517          	auipc	a0,0x3
ffffffffc02046f2:	a4250513          	addi	a0,a0,-1470 # ffffffffc0207130 <default_pmm_manager+0xa28>
ffffffffc02046f6:	d9dfb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02046fa:	00003697          	auipc	a3,0x3
ffffffffc02046fe:	b7e68693          	addi	a3,a3,-1154 # ffffffffc0207278 <default_pmm_manager+0xb70>
ffffffffc0204702:	00002617          	auipc	a2,0x2
ffffffffc0204706:	c5660613          	addi	a2,a2,-938 # ffffffffc0206358 <commands+0x850>
ffffffffc020470a:	3e600593          	li	a1,998
ffffffffc020470e:	00003517          	auipc	a0,0x3
ffffffffc0204712:	a2250513          	addi	a0,a0,-1502 # ffffffffc0207130 <default_pmm_manager+0xa28>
ffffffffc0204716:	d7dfb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(nr_process == 2);
ffffffffc020471a:	00003697          	auipc	a3,0x3
ffffffffc020471e:	b4e68693          	addi	a3,a3,-1202 # ffffffffc0207268 <default_pmm_manager+0xb60>
ffffffffc0204722:	00002617          	auipc	a2,0x2
ffffffffc0204726:	c3660613          	addi	a2,a2,-970 # ffffffffc0206358 <commands+0x850>
ffffffffc020472a:	3e500593          	li	a1,997
ffffffffc020472e:	00003517          	auipc	a0,0x3
ffffffffc0204732:	a0250513          	addi	a0,a0,-1534 # ffffffffc0207130 <default_pmm_manager+0xa28>
ffffffffc0204736:	d5dfb0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc020473a <do_execve>:
{
ffffffffc020473a:	7171                	addi	sp,sp,-176
ffffffffc020473c:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020473e:	000ced97          	auipc	s11,0xce
ffffffffc0204742:	082d8d93          	addi	s11,s11,130 # ffffffffc02d27c0 <current>
ffffffffc0204746:	000db783          	ld	a5,0(s11)
{
ffffffffc020474a:	e54e                	sd	s3,136(sp)
ffffffffc020474c:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020474e:	0287b983          	ld	s3,40(a5)
{
ffffffffc0204752:	e94a                	sd	s2,144(sp)
ffffffffc0204754:	f4de                	sd	s7,104(sp)
ffffffffc0204756:	892a                	mv	s2,a0
ffffffffc0204758:	8bb2                	mv	s7,a2
ffffffffc020475a:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc020475c:	862e                	mv	a2,a1
ffffffffc020475e:	4681                	li	a3,0
ffffffffc0204760:	85aa                	mv	a1,a0
ffffffffc0204762:	854e                	mv	a0,s3
{
ffffffffc0204764:	f506                	sd	ra,168(sp)
ffffffffc0204766:	f122                	sd	s0,160(sp)
ffffffffc0204768:	e152                	sd	s4,128(sp)
ffffffffc020476a:	fcd6                	sd	s5,120(sp)
ffffffffc020476c:	f8da                	sd	s6,112(sp)
ffffffffc020476e:	f0e2                	sd	s8,96(sp)
ffffffffc0204770:	ece6                	sd	s9,88(sp)
ffffffffc0204772:	e8ea                	sd	s10,80(sp)
ffffffffc0204774:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204776:	d34ff0ef          	jal	ra,ffffffffc0203caa <user_mem_check>
ffffffffc020477a:	40050a63          	beqz	a0,ffffffffc0204b8e <do_execve+0x454>
    memset(local_name, 0, sizeof(local_name));
ffffffffc020477e:	4641                	li	a2,16
ffffffffc0204780:	4581                	li	a1,0
ffffffffc0204782:	1808                	addi	a0,sp,48
ffffffffc0204784:	0f2010ef          	jal	ra,ffffffffc0205876 <memset>
    memcpy(local_name, name, len);
ffffffffc0204788:	47bd                	li	a5,15
ffffffffc020478a:	8626                	mv	a2,s1
ffffffffc020478c:	1e97e263          	bltu	a5,s1,ffffffffc0204970 <do_execve+0x236>
ffffffffc0204790:	85ca                	mv	a1,s2
ffffffffc0204792:	1808                	addi	a0,sp,48
ffffffffc0204794:	0f4010ef          	jal	ra,ffffffffc0205888 <memcpy>
    if (mm != NULL)
ffffffffc0204798:	1e098363          	beqz	s3,ffffffffc020497e <do_execve+0x244>
        cputs("mm != NULL");
ffffffffc020479c:	00002517          	auipc	a0,0x2
ffffffffc02047a0:	79c50513          	addi	a0,a0,1948 # ffffffffc0206f38 <default_pmm_manager+0x830>
ffffffffc02047a4:	a2dfb0ef          	jal	ra,ffffffffc02001d0 <cputs>
ffffffffc02047a8:	000ce797          	auipc	a5,0xce
ffffffffc02047ac:	fe87b783          	ld	a5,-24(a5) # ffffffffc02d2790 <boot_pgdir_pa>
ffffffffc02047b0:	577d                	li	a4,-1
ffffffffc02047b2:	177e                	slli	a4,a4,0x3f
ffffffffc02047b4:	83b1                	srli	a5,a5,0xc
ffffffffc02047b6:	8fd9                	or	a5,a5,a4
ffffffffc02047b8:	18079073          	csrw	satp,a5
ffffffffc02047bc:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7f20>
ffffffffc02047c0:	fff7871b          	addiw	a4,a5,-1
ffffffffc02047c4:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0)
ffffffffc02047c8:	2c070463          	beqz	a4,ffffffffc0204a90 <do_execve+0x356>
        current->mm = NULL;
ffffffffc02047cc:	000db783          	ld	a5,0(s11)
ffffffffc02047d0:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc02047d4:	e61fe0ef          	jal	ra,ffffffffc0203634 <mm_create>
ffffffffc02047d8:	84aa                	mv	s1,a0
ffffffffc02047da:	1c050d63          	beqz	a0,ffffffffc02049b4 <do_execve+0x27a>
    if ((page = alloc_page()) == NULL)
ffffffffc02047de:	4505                	li	a0,1
ffffffffc02047e0:	e30fd0ef          	jal	ra,ffffffffc0201e10 <alloc_pages>
ffffffffc02047e4:	3a050963          	beqz	a0,ffffffffc0204b96 <do_execve+0x45c>
    return page - pages + nbase;
ffffffffc02047e8:	000cec97          	auipc	s9,0xce
ffffffffc02047ec:	fc0c8c93          	addi	s9,s9,-64 # ffffffffc02d27a8 <pages>
ffffffffc02047f0:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc02047f4:	000cec17          	auipc	s8,0xce
ffffffffc02047f8:	facc0c13          	addi	s8,s8,-84 # ffffffffc02d27a0 <npage>
    return page - pages + nbase;
ffffffffc02047fc:	00004717          	auipc	a4,0x4
ffffffffc0204800:	9c473703          	ld	a4,-1596(a4) # ffffffffc02081c0 <nbase>
ffffffffc0204804:	40d506b3          	sub	a3,a0,a3
ffffffffc0204808:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020480a:	5afd                	li	s5,-1
ffffffffc020480c:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc0204810:	96ba                	add	a3,a3,a4
ffffffffc0204812:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204814:	00cad713          	srli	a4,s5,0xc
ffffffffc0204818:	ec3a                	sd	a4,24(sp)
ffffffffc020481a:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020481c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020481e:	38f77063          	bgeu	a4,a5,ffffffffc0204b9e <do_execve+0x464>
ffffffffc0204822:	000ceb17          	auipc	s6,0xce
ffffffffc0204826:	f96b0b13          	addi	s6,s6,-106 # ffffffffc02d27b8 <va_pa_offset>
ffffffffc020482a:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc020482e:	6605                	lui	a2,0x1
ffffffffc0204830:	000ce597          	auipc	a1,0xce
ffffffffc0204834:	f685b583          	ld	a1,-152(a1) # ffffffffc02d2798 <boot_pgdir_va>
ffffffffc0204838:	9936                	add	s2,s2,a3
ffffffffc020483a:	854a                	mv	a0,s2
ffffffffc020483c:	04c010ef          	jal	ra,ffffffffc0205888 <memcpy>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204840:	7782                	ld	a5,32(sp)
ffffffffc0204842:	4398                	lw	a4,0(a5)
ffffffffc0204844:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0204848:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC)
ffffffffc020484c:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_matrix_out_size+0x464b7e57>
ffffffffc0204850:	14f71863          	bne	a4,a5,ffffffffc02049a0 <do_execve+0x266>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204854:	7682                	ld	a3,32(sp)
ffffffffc0204856:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020485a:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020485e:	00371793          	slli	a5,a4,0x3
ffffffffc0204862:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204864:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204866:	078e                	slli	a5,a5,0x3
ffffffffc0204868:	97ce                	add	a5,a5,s3
ffffffffc020486a:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph++)
ffffffffc020486c:	00f9fc63          	bgeu	s3,a5,ffffffffc0204884 <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc0204870:	0009a783          	lw	a5,0(s3)
ffffffffc0204874:	4705                	li	a4,1
ffffffffc0204876:	14e78163          	beq	a5,a4,ffffffffc02049b8 <do_execve+0x27e>
    for (; ph < ph_end; ph++)
ffffffffc020487a:	77a2                	ld	a5,40(sp)
ffffffffc020487c:	03898993          	addi	s3,s3,56
ffffffffc0204880:	fef9e8e3          	bltu	s3,a5,ffffffffc0204870 <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc0204884:	4701                	li	a4,0
ffffffffc0204886:	46ad                	li	a3,11
ffffffffc0204888:	00100637          	lui	a2,0x100
ffffffffc020488c:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0204890:	8526                	mv	a0,s1
ffffffffc0204892:	f35fe0ef          	jal	ra,ffffffffc02037c6 <mm_map>
ffffffffc0204896:	8a2a                	mv	s4,a0
ffffffffc0204898:	1e051263          	bnez	a0,ffffffffc0204a7c <do_execve+0x342>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc020489c:	6c88                	ld	a0,24(s1)
ffffffffc020489e:	467d                	li	a2,31
ffffffffc02048a0:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc02048a4:	cabfe0ef          	jal	ra,ffffffffc020354e <pgdir_alloc_page>
ffffffffc02048a8:	38050363          	beqz	a0,ffffffffc0204c2e <do_execve+0x4f4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc02048ac:	6c88                	ld	a0,24(s1)
ffffffffc02048ae:	467d                	li	a2,31
ffffffffc02048b0:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc02048b4:	c9bfe0ef          	jal	ra,ffffffffc020354e <pgdir_alloc_page>
ffffffffc02048b8:	34050b63          	beqz	a0,ffffffffc0204c0e <do_execve+0x4d4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc02048bc:	6c88                	ld	a0,24(s1)
ffffffffc02048be:	467d                	li	a2,31
ffffffffc02048c0:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc02048c4:	c8bfe0ef          	jal	ra,ffffffffc020354e <pgdir_alloc_page>
ffffffffc02048c8:	32050363          	beqz	a0,ffffffffc0204bee <do_execve+0x4b4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc02048cc:	6c88                	ld	a0,24(s1)
ffffffffc02048ce:	467d                	li	a2,31
ffffffffc02048d0:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc02048d4:	c7bfe0ef          	jal	ra,ffffffffc020354e <pgdir_alloc_page>
ffffffffc02048d8:	2e050b63          	beqz	a0,ffffffffc0204bce <do_execve+0x494>
    mm->mm_count += 1;
ffffffffc02048dc:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc02048de:	000db603          	ld	a2,0(s11)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc02048e2:	6c94                	ld	a3,24(s1)
ffffffffc02048e4:	2785                	addiw	a5,a5,1
ffffffffc02048e6:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc02048e8:	f604                	sd	s1,40(a2)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc02048ea:	c02007b7          	lui	a5,0xc0200
ffffffffc02048ee:	2cf6e463          	bltu	a3,a5,ffffffffc0204bb6 <do_execve+0x47c>
ffffffffc02048f2:	000b3783          	ld	a5,0(s6)
ffffffffc02048f6:	577d                	li	a4,-1
ffffffffc02048f8:	177e                	slli	a4,a4,0x3f
ffffffffc02048fa:	8e9d                	sub	a3,a3,a5
ffffffffc02048fc:	00c6d793          	srli	a5,a3,0xc
ffffffffc0204900:	f654                	sd	a3,168(a2)
ffffffffc0204902:	8fd9                	or	a5,a5,a4
ffffffffc0204904:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0204908:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc020490a:	4581                	li	a1,0
ffffffffc020490c:	12000613          	li	a2,288
ffffffffc0204910:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0204912:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204916:	761000ef          	jal	ra,ffffffffc0205876 <memset>
    tf->epc = elf->e_entry;
ffffffffc020491a:	7782                	ld	a5,32(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020491c:	000db903          	ld	s2,0(s11)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204920:	edf4f493          	andi	s1,s1,-289
    tf->epc = elf->e_entry;
ffffffffc0204924:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc0204926:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204928:	0b490913          	addi	s2,s2,180 # ffffffff800000b4 <_binary_obj___user_matrix_out_size+0xffffffff7fff398c>
    tf->gpr.sp = USTACKTOP;
ffffffffc020492c:	07fe                	slli	a5,a5,0x1f
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc020492e:	0204e493          	ori	s1,s1,32
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204932:	4641                	li	a2,16
ffffffffc0204934:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP;
ffffffffc0204936:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0204938:	10e43423          	sd	a4,264(s0)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc020493c:	10943023          	sd	s1,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204940:	854a                	mv	a0,s2
ffffffffc0204942:	735000ef          	jal	ra,ffffffffc0205876 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204946:	463d                	li	a2,15
ffffffffc0204948:	180c                	addi	a1,sp,48
ffffffffc020494a:	854a                	mv	a0,s2
ffffffffc020494c:	73d000ef          	jal	ra,ffffffffc0205888 <memcpy>
}
ffffffffc0204950:	70aa                	ld	ra,168(sp)
ffffffffc0204952:	740a                	ld	s0,160(sp)
ffffffffc0204954:	64ea                	ld	s1,152(sp)
ffffffffc0204956:	694a                	ld	s2,144(sp)
ffffffffc0204958:	69aa                	ld	s3,136(sp)
ffffffffc020495a:	7ae6                	ld	s5,120(sp)
ffffffffc020495c:	7b46                	ld	s6,112(sp)
ffffffffc020495e:	7ba6                	ld	s7,104(sp)
ffffffffc0204960:	7c06                	ld	s8,96(sp)
ffffffffc0204962:	6ce6                	ld	s9,88(sp)
ffffffffc0204964:	6d46                	ld	s10,80(sp)
ffffffffc0204966:	6da6                	ld	s11,72(sp)
ffffffffc0204968:	8552                	mv	a0,s4
ffffffffc020496a:	6a0a                	ld	s4,128(sp)
ffffffffc020496c:	614d                	addi	sp,sp,176
ffffffffc020496e:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc0204970:	463d                	li	a2,15
ffffffffc0204972:	85ca                	mv	a1,s2
ffffffffc0204974:	1808                	addi	a0,sp,48
ffffffffc0204976:	713000ef          	jal	ra,ffffffffc0205888 <memcpy>
    if (mm != NULL)
ffffffffc020497a:	e20991e3          	bnez	s3,ffffffffc020479c <do_execve+0x62>
    if (current->mm != NULL)
ffffffffc020497e:	000db783          	ld	a5,0(s11)
ffffffffc0204982:	779c                	ld	a5,40(a5)
ffffffffc0204984:	e40788e3          	beqz	a5,ffffffffc02047d4 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0204988:	00003617          	auipc	a2,0x3
ffffffffc020498c:	97060613          	addi	a2,a2,-1680 # ffffffffc02072f8 <default_pmm_manager+0xbf0>
ffffffffc0204990:	25f00593          	li	a1,607
ffffffffc0204994:	00002517          	auipc	a0,0x2
ffffffffc0204998:	79c50513          	addi	a0,a0,1948 # ffffffffc0207130 <default_pmm_manager+0xa28>
ffffffffc020499c:	af7fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    put_pgdir(mm);
ffffffffc02049a0:	8526                	mv	a0,s1
ffffffffc02049a2:	c48ff0ef          	jal	ra,ffffffffc0203dea <put_pgdir>
    mm_destroy(mm);
ffffffffc02049a6:	8526                	mv	a0,s1
ffffffffc02049a8:	dcdfe0ef          	jal	ra,ffffffffc0203774 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc02049ac:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc02049ae:	8552                	mv	a0,s4
ffffffffc02049b0:	94bff0ef          	jal	ra,ffffffffc02042fa <do_exit>
    int ret = -E_NO_MEM;
ffffffffc02049b4:	5a71                	li	s4,-4
ffffffffc02049b6:	bfe5                	j	ffffffffc02049ae <do_execve+0x274>
        if (ph->p_filesz > ph->p_memsz)
ffffffffc02049b8:	0289b603          	ld	a2,40(s3)
ffffffffc02049bc:	0209b783          	ld	a5,32(s3)
ffffffffc02049c0:	1cf66d63          	bltu	a2,a5,ffffffffc0204b9a <do_execve+0x460>
        if (ph->p_flags & ELF_PF_X)
ffffffffc02049c4:	0049a783          	lw	a5,4(s3)
ffffffffc02049c8:	0017f693          	andi	a3,a5,1
ffffffffc02049cc:	c291                	beqz	a3,ffffffffc02049d0 <do_execve+0x296>
            vm_flags |= VM_EXEC;
ffffffffc02049ce:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc02049d0:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc02049d4:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc02049d6:	e779                	bnez	a4,ffffffffc0204aa4 <do_execve+0x36a>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc02049d8:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc02049da:	c781                	beqz	a5,ffffffffc02049e2 <do_execve+0x2a8>
            vm_flags |= VM_READ;
ffffffffc02049dc:	0016e693          	ori	a3,a3,1
            perm |= PTE_R;
ffffffffc02049e0:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE)
ffffffffc02049e2:	0026f793          	andi	a5,a3,2
ffffffffc02049e6:	e3f1                	bnez	a5,ffffffffc0204aaa <do_execve+0x370>
        if (vm_flags & VM_EXEC)
ffffffffc02049e8:	0046f793          	andi	a5,a3,4
ffffffffc02049ec:	c399                	beqz	a5,ffffffffc02049f2 <do_execve+0x2b8>
            perm |= PTE_X;
ffffffffc02049ee:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc02049f2:	0109b583          	ld	a1,16(s3)
ffffffffc02049f6:	4701                	li	a4,0
ffffffffc02049f8:	8526                	mv	a0,s1
ffffffffc02049fa:	dcdfe0ef          	jal	ra,ffffffffc02037c6 <mm_map>
ffffffffc02049fe:	8a2a                	mv	s4,a0
ffffffffc0204a00:	ed35                	bnez	a0,ffffffffc0204a7c <do_execve+0x342>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204a02:	0109bb83          	ld	s7,16(s3)
ffffffffc0204a06:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0204a08:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204a0c:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204a10:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204a14:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0204a16:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204a18:	993e                	add	s2,s2,a5
        while (start < end)
ffffffffc0204a1a:	054be963          	bltu	s7,s4,ffffffffc0204a6c <do_execve+0x332>
ffffffffc0204a1e:	aa95                	j	ffffffffc0204b92 <do_execve+0x458>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204a20:	6785                	lui	a5,0x1
ffffffffc0204a22:	415b8533          	sub	a0,s7,s5
ffffffffc0204a26:	9abe                	add	s5,s5,a5
ffffffffc0204a28:	417a8633          	sub	a2,s5,s7
            if (end < la)
ffffffffc0204a2c:	015a7463          	bgeu	s4,s5,ffffffffc0204a34 <do_execve+0x2fa>
                size -= la - end;
ffffffffc0204a30:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc0204a34:	000cb683          	ld	a3,0(s9)
ffffffffc0204a38:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204a3a:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204a3e:	40d406b3          	sub	a3,s0,a3
ffffffffc0204a42:	8699                	srai	a3,a3,0x6
ffffffffc0204a44:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204a46:	67e2                	ld	a5,24(sp)
ffffffffc0204a48:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204a4c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204a4e:	14b87863          	bgeu	a6,a1,ffffffffc0204b9e <do_execve+0x464>
ffffffffc0204a52:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204a56:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0204a58:	9bb2                	add	s7,s7,a2
ffffffffc0204a5a:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204a5c:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0204a5e:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204a60:	629000ef          	jal	ra,ffffffffc0205888 <memcpy>
            start += size, from += size;
ffffffffc0204a64:	6622                	ld	a2,8(sp)
ffffffffc0204a66:	9932                	add	s2,s2,a2
        while (start < end)
ffffffffc0204a68:	054bf363          	bgeu	s7,s4,ffffffffc0204aae <do_execve+0x374>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204a6c:	6c88                	ld	a0,24(s1)
ffffffffc0204a6e:	866a                	mv	a2,s10
ffffffffc0204a70:	85d6                	mv	a1,s5
ffffffffc0204a72:	addfe0ef          	jal	ra,ffffffffc020354e <pgdir_alloc_page>
ffffffffc0204a76:	842a                	mv	s0,a0
ffffffffc0204a78:	f545                	bnez	a0,ffffffffc0204a20 <do_execve+0x2e6>
        ret = -E_NO_MEM;
ffffffffc0204a7a:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0204a7c:	8526                	mv	a0,s1
ffffffffc0204a7e:	e93fe0ef          	jal	ra,ffffffffc0203910 <exit_mmap>
    put_pgdir(mm);
ffffffffc0204a82:	8526                	mv	a0,s1
ffffffffc0204a84:	b66ff0ef          	jal	ra,ffffffffc0203dea <put_pgdir>
    mm_destroy(mm);
ffffffffc0204a88:	8526                	mv	a0,s1
ffffffffc0204a8a:	cebfe0ef          	jal	ra,ffffffffc0203774 <mm_destroy>
    return ret;
ffffffffc0204a8e:	b705                	j	ffffffffc02049ae <do_execve+0x274>
            exit_mmap(mm);
ffffffffc0204a90:	854e                	mv	a0,s3
ffffffffc0204a92:	e7ffe0ef          	jal	ra,ffffffffc0203910 <exit_mmap>
            put_pgdir(mm);
ffffffffc0204a96:	854e                	mv	a0,s3
ffffffffc0204a98:	b52ff0ef          	jal	ra,ffffffffc0203dea <put_pgdir>
            mm_destroy(mm);
ffffffffc0204a9c:	854e                	mv	a0,s3
ffffffffc0204a9e:	cd7fe0ef          	jal	ra,ffffffffc0203774 <mm_destroy>
ffffffffc0204aa2:	b32d                	j	ffffffffc02047cc <do_execve+0x92>
            vm_flags |= VM_WRITE;
ffffffffc0204aa4:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204aa8:	fb95                	bnez	a5,ffffffffc02049dc <do_execve+0x2a2>
            perm |= (PTE_W | PTE_R);
ffffffffc0204aaa:	4d5d                	li	s10,23
ffffffffc0204aac:	bf35                	j	ffffffffc02049e8 <do_execve+0x2ae>
        end = ph->p_va + ph->p_memsz;
ffffffffc0204aae:	0109b683          	ld	a3,16(s3)
ffffffffc0204ab2:	0289b903          	ld	s2,40(s3)
ffffffffc0204ab6:	9936                	add	s2,s2,a3
        if (start < la)
ffffffffc0204ab8:	075bfd63          	bgeu	s7,s5,ffffffffc0204b32 <do_execve+0x3f8>
            if (start == end)
ffffffffc0204abc:	db790fe3          	beq	s2,s7,ffffffffc020487a <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204ac0:	6785                	lui	a5,0x1
ffffffffc0204ac2:	00fb8533          	add	a0,s7,a5
ffffffffc0204ac6:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0204aca:	41790a33          	sub	s4,s2,s7
            if (end < la)
ffffffffc0204ace:	0b597d63          	bgeu	s2,s5,ffffffffc0204b88 <do_execve+0x44e>
    return page - pages + nbase;
ffffffffc0204ad2:	000cb683          	ld	a3,0(s9)
ffffffffc0204ad6:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204ad8:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0204adc:	40d406b3          	sub	a3,s0,a3
ffffffffc0204ae0:	8699                	srai	a3,a3,0x6
ffffffffc0204ae2:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204ae4:	67e2                	ld	a5,24(sp)
ffffffffc0204ae6:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204aea:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204aec:	0ac5f963          	bgeu	a1,a2,ffffffffc0204b9e <do_execve+0x464>
ffffffffc0204af0:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204af4:	8652                	mv	a2,s4
ffffffffc0204af6:	4581                	li	a1,0
ffffffffc0204af8:	96c2                	add	a3,a3,a6
ffffffffc0204afa:	9536                	add	a0,a0,a3
ffffffffc0204afc:	57b000ef          	jal	ra,ffffffffc0205876 <memset>
            start += size;
ffffffffc0204b00:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0204b04:	03597463          	bgeu	s2,s5,ffffffffc0204b2c <do_execve+0x3f2>
ffffffffc0204b08:	d6e909e3          	beq	s2,a4,ffffffffc020487a <do_execve+0x140>
ffffffffc0204b0c:	00003697          	auipc	a3,0x3
ffffffffc0204b10:	81468693          	addi	a3,a3,-2028 # ffffffffc0207320 <default_pmm_manager+0xc18>
ffffffffc0204b14:	00002617          	auipc	a2,0x2
ffffffffc0204b18:	84460613          	addi	a2,a2,-1980 # ffffffffc0206358 <commands+0x850>
ffffffffc0204b1c:	2c800593          	li	a1,712
ffffffffc0204b20:	00002517          	auipc	a0,0x2
ffffffffc0204b24:	61050513          	addi	a0,a0,1552 # ffffffffc0207130 <default_pmm_manager+0xa28>
ffffffffc0204b28:	96bfb0ef          	jal	ra,ffffffffc0200492 <__panic>
ffffffffc0204b2c:	ff5710e3          	bne	a4,s5,ffffffffc0204b0c <do_execve+0x3d2>
ffffffffc0204b30:	8bd6                	mv	s7,s5
        while (start < end)
ffffffffc0204b32:	d52bf4e3          	bgeu	s7,s2,ffffffffc020487a <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204b36:	6c88                	ld	a0,24(s1)
ffffffffc0204b38:	866a                	mv	a2,s10
ffffffffc0204b3a:	85d6                	mv	a1,s5
ffffffffc0204b3c:	a13fe0ef          	jal	ra,ffffffffc020354e <pgdir_alloc_page>
ffffffffc0204b40:	842a                	mv	s0,a0
ffffffffc0204b42:	dd05                	beqz	a0,ffffffffc0204a7a <do_execve+0x340>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204b44:	6785                	lui	a5,0x1
ffffffffc0204b46:	415b8533          	sub	a0,s7,s5
ffffffffc0204b4a:	9abe                	add	s5,s5,a5
ffffffffc0204b4c:	417a8633          	sub	a2,s5,s7
            if (end < la)
ffffffffc0204b50:	01597463          	bgeu	s2,s5,ffffffffc0204b58 <do_execve+0x41e>
                size -= la - end;
ffffffffc0204b54:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0204b58:	000cb683          	ld	a3,0(s9)
ffffffffc0204b5c:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204b5e:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204b62:	40d406b3          	sub	a3,s0,a3
ffffffffc0204b66:	8699                	srai	a3,a3,0x6
ffffffffc0204b68:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204b6a:	67e2                	ld	a5,24(sp)
ffffffffc0204b6c:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b70:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204b72:	02b87663          	bgeu	a6,a1,ffffffffc0204b9e <do_execve+0x464>
ffffffffc0204b76:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204b7a:	4581                	li	a1,0
            start += size;
ffffffffc0204b7c:	9bb2                	add	s7,s7,a2
ffffffffc0204b7e:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0204b80:	9536                	add	a0,a0,a3
ffffffffc0204b82:	4f5000ef          	jal	ra,ffffffffc0205876 <memset>
ffffffffc0204b86:	b775                	j	ffffffffc0204b32 <do_execve+0x3f8>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204b88:	417a8a33          	sub	s4,s5,s7
ffffffffc0204b8c:	b799                	j	ffffffffc0204ad2 <do_execve+0x398>
        return -E_INVAL;
ffffffffc0204b8e:	5a75                	li	s4,-3
ffffffffc0204b90:	b3c1                	j	ffffffffc0204950 <do_execve+0x216>
        while (start < end)
ffffffffc0204b92:	86de                	mv	a3,s7
ffffffffc0204b94:	bf39                	j	ffffffffc0204ab2 <do_execve+0x378>
    int ret = -E_NO_MEM;
ffffffffc0204b96:	5a71                	li	s4,-4
ffffffffc0204b98:	bdc5                	j	ffffffffc0204a88 <do_execve+0x34e>
            ret = -E_INVAL_ELF;
ffffffffc0204b9a:	5a61                	li	s4,-8
ffffffffc0204b9c:	b5c5                	j	ffffffffc0204a7c <do_execve+0x342>
ffffffffc0204b9e:	00002617          	auipc	a2,0x2
ffffffffc0204ba2:	ba260613          	addi	a2,a2,-1118 # ffffffffc0206740 <default_pmm_manager+0x38>
ffffffffc0204ba6:	07100593          	li	a1,113
ffffffffc0204baa:	00002517          	auipc	a0,0x2
ffffffffc0204bae:	bbe50513          	addi	a0,a0,-1090 # ffffffffc0206768 <default_pmm_manager+0x60>
ffffffffc0204bb2:	8e1fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204bb6:	00002617          	auipc	a2,0x2
ffffffffc0204bba:	c3260613          	addi	a2,a2,-974 # ffffffffc02067e8 <default_pmm_manager+0xe0>
ffffffffc0204bbe:	2e700593          	li	a1,743
ffffffffc0204bc2:	00002517          	auipc	a0,0x2
ffffffffc0204bc6:	56e50513          	addi	a0,a0,1390 # ffffffffc0207130 <default_pmm_manager+0xa28>
ffffffffc0204bca:	8c9fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204bce:	00003697          	auipc	a3,0x3
ffffffffc0204bd2:	86a68693          	addi	a3,a3,-1942 # ffffffffc0207438 <default_pmm_manager+0xd30>
ffffffffc0204bd6:	00001617          	auipc	a2,0x1
ffffffffc0204bda:	78260613          	addi	a2,a2,1922 # ffffffffc0206358 <commands+0x850>
ffffffffc0204bde:	2e200593          	li	a1,738
ffffffffc0204be2:	00002517          	auipc	a0,0x2
ffffffffc0204be6:	54e50513          	addi	a0,a0,1358 # ffffffffc0207130 <default_pmm_manager+0xa28>
ffffffffc0204bea:	8a9fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204bee:	00003697          	auipc	a3,0x3
ffffffffc0204bf2:	80268693          	addi	a3,a3,-2046 # ffffffffc02073f0 <default_pmm_manager+0xce8>
ffffffffc0204bf6:	00001617          	auipc	a2,0x1
ffffffffc0204bfa:	76260613          	addi	a2,a2,1890 # ffffffffc0206358 <commands+0x850>
ffffffffc0204bfe:	2e100593          	li	a1,737
ffffffffc0204c02:	00002517          	auipc	a0,0x2
ffffffffc0204c06:	52e50513          	addi	a0,a0,1326 # ffffffffc0207130 <default_pmm_manager+0xa28>
ffffffffc0204c0a:	889fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204c0e:	00002697          	auipc	a3,0x2
ffffffffc0204c12:	79a68693          	addi	a3,a3,1946 # ffffffffc02073a8 <default_pmm_manager+0xca0>
ffffffffc0204c16:	00001617          	auipc	a2,0x1
ffffffffc0204c1a:	74260613          	addi	a2,a2,1858 # ffffffffc0206358 <commands+0x850>
ffffffffc0204c1e:	2e000593          	li	a1,736
ffffffffc0204c22:	00002517          	auipc	a0,0x2
ffffffffc0204c26:	50e50513          	addi	a0,a0,1294 # ffffffffc0207130 <default_pmm_manager+0xa28>
ffffffffc0204c2a:	869fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204c2e:	00002697          	auipc	a3,0x2
ffffffffc0204c32:	73268693          	addi	a3,a3,1842 # ffffffffc0207360 <default_pmm_manager+0xc58>
ffffffffc0204c36:	00001617          	auipc	a2,0x1
ffffffffc0204c3a:	72260613          	addi	a2,a2,1826 # ffffffffc0206358 <commands+0x850>
ffffffffc0204c3e:	2df00593          	li	a1,735
ffffffffc0204c42:	00002517          	auipc	a0,0x2
ffffffffc0204c46:	4ee50513          	addi	a0,a0,1262 # ffffffffc0207130 <default_pmm_manager+0xa28>
ffffffffc0204c4a:	849fb0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0204c4e <user_main>:
{
ffffffffc0204c4e:	1101                	addi	sp,sp,-32
ffffffffc0204c50:	e04a                	sd	s2,0(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204c52:	000ce917          	auipc	s2,0xce
ffffffffc0204c56:	b6e90913          	addi	s2,s2,-1170 # ffffffffc02d27c0 <current>
ffffffffc0204c5a:	00093783          	ld	a5,0(s2)
ffffffffc0204c5e:	00003617          	auipc	a2,0x3
ffffffffc0204c62:	82260613          	addi	a2,a2,-2014 # ffffffffc0207480 <default_pmm_manager+0xd78>
ffffffffc0204c66:	00003517          	auipc	a0,0x3
ffffffffc0204c6a:	82a50513          	addi	a0,a0,-2006 # ffffffffc0207490 <default_pmm_manager+0xd88>
ffffffffc0204c6e:	43cc                	lw	a1,4(a5)
{
ffffffffc0204c70:	ec06                	sd	ra,24(sp)
ffffffffc0204c72:	e822                	sd	s0,16(sp)
ffffffffc0204c74:	e426                	sd	s1,8(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204c76:	d22fb0ef          	jal	ra,ffffffffc0200198 <cprintf>
    size_t len = strlen(name);
ffffffffc0204c7a:	00003517          	auipc	a0,0x3
ffffffffc0204c7e:	80650513          	addi	a0,a0,-2042 # ffffffffc0207480 <default_pmm_manager+0xd78>
ffffffffc0204c82:	353000ef          	jal	ra,ffffffffc02057d4 <strlen>
    struct trapframe *old_tf = current->tf;
ffffffffc0204c86:	00093783          	ld	a5,0(s2)
    size_t len = strlen(name);
ffffffffc0204c8a:	84aa                	mv	s1,a0
    memcpy(new_tf, old_tf, sizeof(struct trapframe));
ffffffffc0204c8c:	12000613          	li	a2,288
    struct trapframe *new_tf = (struct trapframe *)(current->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204c90:	6b80                	ld	s0,16(a5)
    memcpy(new_tf, old_tf, sizeof(struct trapframe));
ffffffffc0204c92:	73cc                	ld	a1,160(a5)
    struct trapframe *new_tf = (struct trapframe *)(current->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204c94:	6789                	lui	a5,0x2
ffffffffc0204c96:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x8070>
ffffffffc0204c9a:	943e                	add	s0,s0,a5
    memcpy(new_tf, old_tf, sizeof(struct trapframe));
ffffffffc0204c9c:	8522                	mv	a0,s0
ffffffffc0204c9e:	3eb000ef          	jal	ra,ffffffffc0205888 <memcpy>
    current->tf = new_tf;
ffffffffc0204ca2:	00093783          	ld	a5,0(s2)
    ret = do_execve(name, len, binary, size);
ffffffffc0204ca6:	3fe07697          	auipc	a3,0x3fe07
ffffffffc0204caa:	ab268693          	addi	a3,a3,-1358 # b758 <_binary_obj___user_priority_out_size>
ffffffffc0204cae:	0007d617          	auipc	a2,0x7d
ffffffffc0204cb2:	16260613          	addi	a2,a2,354 # ffffffffc0281e10 <_binary_obj___user_priority_out_start>
    current->tf = new_tf;
ffffffffc0204cb6:	f3c0                	sd	s0,160(a5)
    ret = do_execve(name, len, binary, size);
ffffffffc0204cb8:	85a6                	mv	a1,s1
ffffffffc0204cba:	00002517          	auipc	a0,0x2
ffffffffc0204cbe:	7c650513          	addi	a0,a0,1990 # ffffffffc0207480 <default_pmm_manager+0xd78>
ffffffffc0204cc2:	a79ff0ef          	jal	ra,ffffffffc020473a <do_execve>
    asm volatile(
ffffffffc0204cc6:	8122                	mv	sp,s0
ffffffffc0204cc8:	a2cfc06f          	j	ffffffffc0200ef4 <__trapret>
    panic("user_main execve failed.\n");
ffffffffc0204ccc:	00002617          	auipc	a2,0x2
ffffffffc0204cd0:	7ec60613          	addi	a2,a2,2028 # ffffffffc02074b8 <default_pmm_manager+0xdb0>
ffffffffc0204cd4:	3cd00593          	li	a1,973
ffffffffc0204cd8:	00002517          	auipc	a0,0x2
ffffffffc0204cdc:	45850513          	addi	a0,a0,1112 # ffffffffc0207130 <default_pmm_manager+0xa28>
ffffffffc0204ce0:	fb2fb0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0204ce4 <do_yield>:
    current->need_resched = 1;
ffffffffc0204ce4:	000ce797          	auipc	a5,0xce
ffffffffc0204ce8:	adc7b783          	ld	a5,-1316(a5) # ffffffffc02d27c0 <current>
ffffffffc0204cec:	4705                	li	a4,1
ffffffffc0204cee:	ef98                	sd	a4,24(a5)
}
ffffffffc0204cf0:	4501                	li	a0,0
ffffffffc0204cf2:	8082                	ret

ffffffffc0204cf4 <do_wait>:
{
ffffffffc0204cf4:	1101                	addi	sp,sp,-32
ffffffffc0204cf6:	e822                	sd	s0,16(sp)
ffffffffc0204cf8:	e426                	sd	s1,8(sp)
ffffffffc0204cfa:	ec06                	sd	ra,24(sp)
ffffffffc0204cfc:	842e                	mv	s0,a1
ffffffffc0204cfe:	84aa                	mv	s1,a0
    if (code_store != NULL)
ffffffffc0204d00:	c999                	beqz	a1,ffffffffc0204d16 <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0204d02:	000ce797          	auipc	a5,0xce
ffffffffc0204d06:	abe7b783          	ld	a5,-1346(a5) # ffffffffc02d27c0 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0204d0a:	7788                	ld	a0,40(a5)
ffffffffc0204d0c:	4685                	li	a3,1
ffffffffc0204d0e:	4611                	li	a2,4
ffffffffc0204d10:	f9bfe0ef          	jal	ra,ffffffffc0203caa <user_mem_check>
ffffffffc0204d14:	c909                	beqz	a0,ffffffffc0204d26 <do_wait+0x32>
ffffffffc0204d16:	85a2                	mv	a1,s0
}
ffffffffc0204d18:	6442                	ld	s0,16(sp)
ffffffffc0204d1a:	60e2                	ld	ra,24(sp)
ffffffffc0204d1c:	8526                	mv	a0,s1
ffffffffc0204d1e:	64a2                	ld	s1,8(sp)
ffffffffc0204d20:	6105                	addi	sp,sp,32
ffffffffc0204d22:	f22ff06f          	j	ffffffffc0204444 <do_wait.part.0>
ffffffffc0204d26:	60e2                	ld	ra,24(sp)
ffffffffc0204d28:	6442                	ld	s0,16(sp)
ffffffffc0204d2a:	64a2                	ld	s1,8(sp)
ffffffffc0204d2c:	5575                	li	a0,-3
ffffffffc0204d2e:	6105                	addi	sp,sp,32
ffffffffc0204d30:	8082                	ret

ffffffffc0204d32 <do_kill>:
{
ffffffffc0204d32:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID)
ffffffffc0204d34:	6789                	lui	a5,0x2
{
ffffffffc0204d36:	e406                	sd	ra,8(sp)
ffffffffc0204d38:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID)
ffffffffc0204d3a:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204d3e:	17f9                	addi	a5,a5,-2
ffffffffc0204d40:	02e7e963          	bltu	a5,a4,ffffffffc0204d72 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204d44:	842a                	mv	s0,a0
ffffffffc0204d46:	45a9                	li	a1,10
ffffffffc0204d48:	2501                	sext.w	a0,a0
ffffffffc0204d4a:	686000ef          	jal	ra,ffffffffc02053d0 <hash32>
ffffffffc0204d4e:	02051793          	slli	a5,a0,0x20
ffffffffc0204d52:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204d56:	000ca797          	auipc	a5,0xca
ffffffffc0204d5a:	9ca78793          	addi	a5,a5,-1590 # ffffffffc02ce720 <hash_list>
ffffffffc0204d5e:	953e                	add	a0,a0,a5
ffffffffc0204d60:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list)
ffffffffc0204d62:	a029                	j	ffffffffc0204d6c <do_kill+0x3a>
            if (proc->pid == pid)
ffffffffc0204d64:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0204d68:	00870b63          	beq	a4,s0,ffffffffc0204d7e <do_kill+0x4c>
ffffffffc0204d6c:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204d6e:	fef51be3          	bne	a0,a5,ffffffffc0204d64 <do_kill+0x32>
    return -E_INVAL;
ffffffffc0204d72:	5475                	li	s0,-3
}
ffffffffc0204d74:	60a2                	ld	ra,8(sp)
ffffffffc0204d76:	8522                	mv	a0,s0
ffffffffc0204d78:	6402                	ld	s0,0(sp)
ffffffffc0204d7a:	0141                	addi	sp,sp,16
ffffffffc0204d7c:	8082                	ret
        if (!(proc->flags & PF_EXITING))
ffffffffc0204d7e:	fd87a703          	lw	a4,-40(a5)
ffffffffc0204d82:	00177693          	andi	a3,a4,1
ffffffffc0204d86:	e295                	bnez	a3,ffffffffc0204daa <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0204d88:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0204d8a:	00176713          	ori	a4,a4,1
ffffffffc0204d8e:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0204d92:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0204d94:	fe06d0e3          	bgez	a3,ffffffffc0204d74 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0204d98:	f2878513          	addi	a0,a5,-216
ffffffffc0204d9c:	3c2000ef          	jal	ra,ffffffffc020515e <wakeup_proc>
}
ffffffffc0204da0:	60a2                	ld	ra,8(sp)
ffffffffc0204da2:	8522                	mv	a0,s0
ffffffffc0204da4:	6402                	ld	s0,0(sp)
ffffffffc0204da6:	0141                	addi	sp,sp,16
ffffffffc0204da8:	8082                	ret
        return -E_KILLED;
ffffffffc0204daa:	545d                	li	s0,-9
ffffffffc0204dac:	b7e1                	j	ffffffffc0204d74 <do_kill+0x42>

ffffffffc0204dae <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc0204dae:	1101                	addi	sp,sp,-32
ffffffffc0204db0:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0204db2:	000ce797          	auipc	a5,0xce
ffffffffc0204db6:	96e78793          	addi	a5,a5,-1682 # ffffffffc02d2720 <proc_list>
ffffffffc0204dba:	ec06                	sd	ra,24(sp)
ffffffffc0204dbc:	e822                	sd	s0,16(sp)
ffffffffc0204dbe:	e04a                	sd	s2,0(sp)
ffffffffc0204dc0:	000ca497          	auipc	s1,0xca
ffffffffc0204dc4:	96048493          	addi	s1,s1,-1696 # ffffffffc02ce720 <hash_list>
ffffffffc0204dc8:	e79c                	sd	a5,8(a5)
ffffffffc0204dca:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0204dcc:	000ce717          	auipc	a4,0xce
ffffffffc0204dd0:	95470713          	addi	a4,a4,-1708 # ffffffffc02d2720 <proc_list>
ffffffffc0204dd4:	87a6                	mv	a5,s1
ffffffffc0204dd6:	e79c                	sd	a5,8(a5)
ffffffffc0204dd8:	e39c                	sd	a5,0(a5)
ffffffffc0204dda:	07c1                	addi	a5,a5,16
ffffffffc0204ddc:	fef71de3          	bne	a4,a5,ffffffffc0204dd6 <proc_init+0x28>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc0204de0:	f67fe0ef          	jal	ra,ffffffffc0203d46 <alloc_proc>
ffffffffc0204de4:	000ce917          	auipc	s2,0xce
ffffffffc0204de8:	9e490913          	addi	s2,s2,-1564 # ffffffffc02d27c8 <idleproc>
ffffffffc0204dec:	00a93023          	sd	a0,0(s2)
ffffffffc0204df0:	0e050f63          	beqz	a0,ffffffffc0204eee <proc_init+0x140>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0204df4:	4789                	li	a5,2
ffffffffc0204df6:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204df8:	00004797          	auipc	a5,0x4
ffffffffc0204dfc:	20878793          	addi	a5,a5,520 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e00:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204e04:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0204e06:	4785                	li	a5,1
ffffffffc0204e08:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e0a:	4641                	li	a2,16
ffffffffc0204e0c:	4581                	li	a1,0
ffffffffc0204e0e:	8522                	mv	a0,s0
ffffffffc0204e10:	267000ef          	jal	ra,ffffffffc0205876 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204e14:	463d                	li	a2,15
ffffffffc0204e16:	00002597          	auipc	a1,0x2
ffffffffc0204e1a:	6da58593          	addi	a1,a1,1754 # ffffffffc02074f0 <default_pmm_manager+0xde8>
ffffffffc0204e1e:	8522                	mv	a0,s0
ffffffffc0204e20:	269000ef          	jal	ra,ffffffffc0205888 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process++;
ffffffffc0204e24:	000ce717          	auipc	a4,0xce
ffffffffc0204e28:	9b470713          	addi	a4,a4,-1612 # ffffffffc02d27d8 <nr_process>
ffffffffc0204e2c:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0204e2e:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0204e32:	4601                	li	a2,0
    nr_process++;
ffffffffc0204e34:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0204e36:	4581                	li	a1,0
ffffffffc0204e38:	fffff517          	auipc	a0,0xfffff
ffffffffc0204e3c:	7de50513          	addi	a0,a0,2014 # ffffffffc0204616 <init_main>
    nr_process++;
ffffffffc0204e40:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0204e42:	000ce797          	auipc	a5,0xce
ffffffffc0204e46:	96d7bf23          	sd	a3,-1666(a5) # ffffffffc02d27c0 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0204e4a:	c60ff0ef          	jal	ra,ffffffffc02042aa <kernel_thread>
ffffffffc0204e4e:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc0204e50:	08a05363          	blez	a0,ffffffffc0204ed6 <proc_init+0x128>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204e54:	6789                	lui	a5,0x2
ffffffffc0204e56:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204e5a:	17f9                	addi	a5,a5,-2
ffffffffc0204e5c:	2501                	sext.w	a0,a0
ffffffffc0204e5e:	02e7e363          	bltu	a5,a4,ffffffffc0204e84 <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204e62:	45a9                	li	a1,10
ffffffffc0204e64:	56c000ef          	jal	ra,ffffffffc02053d0 <hash32>
ffffffffc0204e68:	02051793          	slli	a5,a0,0x20
ffffffffc0204e6c:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0204e70:	96a6                	add	a3,a3,s1
ffffffffc0204e72:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0204e74:	a029                	j	ffffffffc0204e7e <proc_init+0xd0>
            if (proc->pid == pid)
ffffffffc0204e76:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x8024>
ffffffffc0204e7a:	04870b63          	beq	a4,s0,ffffffffc0204ed0 <proc_init+0x122>
    return listelm->next;
ffffffffc0204e7e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204e80:	fef69be3          	bne	a3,a5,ffffffffc0204e76 <proc_init+0xc8>
    return NULL;
ffffffffc0204e84:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e86:	0b478493          	addi	s1,a5,180
ffffffffc0204e8a:	4641                	li	a2,16
ffffffffc0204e8c:	4581                	li	a1,0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0204e8e:	000ce417          	auipc	s0,0xce
ffffffffc0204e92:	94240413          	addi	s0,s0,-1726 # ffffffffc02d27d0 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e96:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0204e98:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e9a:	1dd000ef          	jal	ra,ffffffffc0205876 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204e9e:	463d                	li	a2,15
ffffffffc0204ea0:	00002597          	auipc	a1,0x2
ffffffffc0204ea4:	67858593          	addi	a1,a1,1656 # ffffffffc0207518 <default_pmm_manager+0xe10>
ffffffffc0204ea8:	8526                	mv	a0,s1
ffffffffc0204eaa:	1df000ef          	jal	ra,ffffffffc0205888 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204eae:	00093783          	ld	a5,0(s2)
ffffffffc0204eb2:	cbb5                	beqz	a5,ffffffffc0204f26 <proc_init+0x178>
ffffffffc0204eb4:	43dc                	lw	a5,4(a5)
ffffffffc0204eb6:	eba5                	bnez	a5,ffffffffc0204f26 <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204eb8:	601c                	ld	a5,0(s0)
ffffffffc0204eba:	c7b1                	beqz	a5,ffffffffc0204f06 <proc_init+0x158>
ffffffffc0204ebc:	43d8                	lw	a4,4(a5)
ffffffffc0204ebe:	4785                	li	a5,1
ffffffffc0204ec0:	04f71363          	bne	a4,a5,ffffffffc0204f06 <proc_init+0x158>
}
ffffffffc0204ec4:	60e2                	ld	ra,24(sp)
ffffffffc0204ec6:	6442                	ld	s0,16(sp)
ffffffffc0204ec8:	64a2                	ld	s1,8(sp)
ffffffffc0204eca:	6902                	ld	s2,0(sp)
ffffffffc0204ecc:	6105                	addi	sp,sp,32
ffffffffc0204ece:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204ed0:	f2878793          	addi	a5,a5,-216
ffffffffc0204ed4:	bf4d                	j	ffffffffc0204e86 <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0204ed6:	00002617          	auipc	a2,0x2
ffffffffc0204eda:	62260613          	addi	a2,a2,1570 # ffffffffc02074f8 <default_pmm_manager+0xdf0>
ffffffffc0204ede:	40a00593          	li	a1,1034
ffffffffc0204ee2:	00002517          	auipc	a0,0x2
ffffffffc0204ee6:	24e50513          	addi	a0,a0,590 # ffffffffc0207130 <default_pmm_manager+0xa28>
ffffffffc0204eea:	da8fb0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0204eee:	00002617          	auipc	a2,0x2
ffffffffc0204ef2:	5ea60613          	addi	a2,a2,1514 # ffffffffc02074d8 <default_pmm_manager+0xdd0>
ffffffffc0204ef6:	3fb00593          	li	a1,1019
ffffffffc0204efa:	00002517          	auipc	a0,0x2
ffffffffc0204efe:	23650513          	addi	a0,a0,566 # ffffffffc0207130 <default_pmm_manager+0xa28>
ffffffffc0204f02:	d90fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204f06:	00002697          	auipc	a3,0x2
ffffffffc0204f0a:	64268693          	addi	a3,a3,1602 # ffffffffc0207548 <default_pmm_manager+0xe40>
ffffffffc0204f0e:	00001617          	auipc	a2,0x1
ffffffffc0204f12:	44a60613          	addi	a2,a2,1098 # ffffffffc0206358 <commands+0x850>
ffffffffc0204f16:	41100593          	li	a1,1041
ffffffffc0204f1a:	00002517          	auipc	a0,0x2
ffffffffc0204f1e:	21650513          	addi	a0,a0,534 # ffffffffc0207130 <default_pmm_manager+0xa28>
ffffffffc0204f22:	d70fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204f26:	00002697          	auipc	a3,0x2
ffffffffc0204f2a:	5fa68693          	addi	a3,a3,1530 # ffffffffc0207520 <default_pmm_manager+0xe18>
ffffffffc0204f2e:	00001617          	auipc	a2,0x1
ffffffffc0204f32:	42a60613          	addi	a2,a2,1066 # ffffffffc0206358 <commands+0x850>
ffffffffc0204f36:	41000593          	li	a1,1040
ffffffffc0204f3a:	00002517          	auipc	a0,0x2
ffffffffc0204f3e:	1f650513          	addi	a0,a0,502 # ffffffffc0207130 <default_pmm_manager+0xa28>
ffffffffc0204f42:	d50fb0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0204f46 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc0204f46:	1141                	addi	sp,sp,-16
ffffffffc0204f48:	e022                	sd	s0,0(sp)
ffffffffc0204f4a:	e406                	sd	ra,8(sp)
ffffffffc0204f4c:	000ce417          	auipc	s0,0xce
ffffffffc0204f50:	87440413          	addi	s0,s0,-1932 # ffffffffc02d27c0 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc0204f54:	6018                	ld	a4,0(s0)
ffffffffc0204f56:	6f1c                	ld	a5,24(a4)
ffffffffc0204f58:	dffd                	beqz	a5,ffffffffc0204f56 <cpu_idle+0x10>
        {
            schedule();
ffffffffc0204f5a:	2b6000ef          	jal	ra,ffffffffc0205210 <schedule>
ffffffffc0204f5e:	bfdd                	j	ffffffffc0204f54 <cpu_idle+0xe>

ffffffffc0204f60 <lab6_set_priority>:
        }
    }
}
// FOR LAB6, set the process's priority (bigger value will get more CPU time)
void lab6_set_priority(uint32_t priority)
{
ffffffffc0204f60:	1141                	addi	sp,sp,-16
ffffffffc0204f62:	e022                	sd	s0,0(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc0204f64:	85aa                	mv	a1,a0
{
ffffffffc0204f66:	842a                	mv	s0,a0
    cprintf("set priority to %d\n", priority);
ffffffffc0204f68:	00002517          	auipc	a0,0x2
ffffffffc0204f6c:	60850513          	addi	a0,a0,1544 # ffffffffc0207570 <default_pmm_manager+0xe68>
{
ffffffffc0204f70:	e406                	sd	ra,8(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc0204f72:	a26fb0ef          	jal	ra,ffffffffc0200198 <cprintf>
    if (priority == 0)
        current->lab6_priority = 1;
ffffffffc0204f76:	000ce797          	auipc	a5,0xce
ffffffffc0204f7a:	84a7b783          	ld	a5,-1974(a5) # ffffffffc02d27c0 <current>
    if (priority == 0)
ffffffffc0204f7e:	e801                	bnez	s0,ffffffffc0204f8e <lab6_set_priority+0x2e>
    else
        current->lab6_priority = priority;
}
ffffffffc0204f80:	60a2                	ld	ra,8(sp)
ffffffffc0204f82:	6402                	ld	s0,0(sp)
        current->lab6_priority = 1;
ffffffffc0204f84:	4705                	li	a4,1
ffffffffc0204f86:	14e7a223          	sw	a4,324(a5)
}
ffffffffc0204f8a:	0141                	addi	sp,sp,16
ffffffffc0204f8c:	8082                	ret
ffffffffc0204f8e:	60a2                	ld	ra,8(sp)
        current->lab6_priority = priority;
ffffffffc0204f90:	1487a223          	sw	s0,324(a5)
}
ffffffffc0204f94:	6402                	ld	s0,0(sp)
ffffffffc0204f96:	0141                	addi	sp,sp,16
ffffffffc0204f98:	8082                	ret

ffffffffc0204f9a <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204f9a:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204f9e:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204fa2:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204fa4:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204fa6:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204faa:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204fae:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204fb2:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204fb6:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204fba:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204fbe:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204fc2:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204fc6:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204fca:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204fce:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204fd2:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204fd6:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204fd8:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204fda:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204fde:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204fe2:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204fe6:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204fea:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204fee:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204ff2:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204ff6:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204ffa:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204ffe:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0205002:	8082                	ret

ffffffffc0205004 <RR_init>:
    elm->prev = elm->next = elm;
ffffffffc0205004:	e508                	sd	a0,8(a0)
ffffffffc0205006:	e108                	sd	a0,0(a0)
{
    // LAB6: 2310137
    // (1) 初始化rq->run_list为空链表
    // (2) 设置rq->proc_num为0
    list_init(&(rq->run_list));
    rq->proc_num = 0;
ffffffffc0205008:	00052823          	sw	zero,16(a0)
}
ffffffffc020500c:	8082                	ret

ffffffffc020500e <RR_pick_next>:
    return list->next == list;
ffffffffc020500e:	651c                	ld	a5,8(a0)
{
    // LAB6: 2310137
    // (1) 如果运行队列为空，返回NULL
    // (2) 否则获取队列头部的进程（list_next获取run_list的下一个节点）
    // (3) 使用le2proc宏将list_entry转换为proc_struct指针
    if (list_empty(&(rq->run_list))) {
ffffffffc0205010:	00f50563          	beq	a0,a5,ffffffffc020501a <RR_pick_next+0xc>
        return NULL;
    }
    list_entry_t *le = list_next(&(rq->run_list));
    return le2proc(le, run_link);
ffffffffc0205014:	ef078513          	addi	a0,a5,-272
ffffffffc0205018:	8082                	ret
        return NULL;
ffffffffc020501a:	4501                	li	a0,0
}
ffffffffc020501c:	8082                	ret

ffffffffc020501e <RR_proc_tick>:
RR_proc_tick(struct run_queue *rq, struct proc_struct *proc)
{
    // LAB6: 2310137
    // (1) 如果进程的时间片time_slice大于0，则递减
    // (2) 如果时间片减到0，设置need_resched为1，表示需要重新调度
    if (proc->time_slice > 0) {
ffffffffc020501e:	1205a783          	lw	a5,288(a1)
ffffffffc0205022:	00f05563          	blez	a5,ffffffffc020502c <RR_proc_tick+0xe>
        proc->time_slice--;
ffffffffc0205026:	37fd                	addiw	a5,a5,-1
ffffffffc0205028:	12f5a023          	sw	a5,288(a1)
    }
    if (proc->time_slice == 0) {
ffffffffc020502c:	e399                	bnez	a5,ffffffffc0205032 <RR_proc_tick+0x14>
        proc->need_resched = 1;
ffffffffc020502e:	4785                	li	a5,1
ffffffffc0205030:	ed9c                	sd	a5,24(a1)
    }
}
ffffffffc0205032:	8082                	ret

ffffffffc0205034 <RR_dequeue>:
ffffffffc0205034:	1185b703          	ld	a4,280(a1)
    assert(!list_empty(&(proc->run_link)));
ffffffffc0205038:	11058793          	addi	a5,a1,272
ffffffffc020503c:	02e78163          	beq	a5,a4,ffffffffc020505e <RR_dequeue+0x2a>
    __list_del(listelm->prev, listelm->next);
ffffffffc0205040:	1105b603          	ld	a2,272(a1)
    rq->proc_num--;
ffffffffc0205044:	4914                	lw	a3,16(a0)
    prev->next = next;
ffffffffc0205046:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc0205048:	e310                	sd	a2,0(a4)
    elm->prev = elm->next = elm;
ffffffffc020504a:	10f5bc23          	sd	a5,280(a1)
ffffffffc020504e:	10f5b823          	sd	a5,272(a1)
    proc->rq = NULL;
ffffffffc0205052:	1005b423          	sd	zero,264(a1)
    rq->proc_num--;
ffffffffc0205056:	fff6879b          	addiw	a5,a3,-1
ffffffffc020505a:	c91c                	sw	a5,16(a0)
ffffffffc020505c:	8082                	ret
{
ffffffffc020505e:	1141                	addi	sp,sp,-16
    assert(!list_empty(&(proc->run_link)));
ffffffffc0205060:	00002697          	auipc	a3,0x2
ffffffffc0205064:	52868693          	addi	a3,a3,1320 # ffffffffc0207588 <default_pmm_manager+0xe80>
ffffffffc0205068:	00001617          	auipc	a2,0x1
ffffffffc020506c:	2f060613          	addi	a2,a2,752 # ffffffffc0206358 <commands+0x850>
ffffffffc0205070:	04600593          	li	a1,70
ffffffffc0205074:	00002517          	auipc	a0,0x2
ffffffffc0205078:	53450513          	addi	a0,a0,1332 # ffffffffc02075a8 <default_pmm_manager+0xea0>
{
ffffffffc020507c:	e406                	sd	ra,8(sp)
    assert(!list_empty(&(proc->run_link)));
ffffffffc020507e:	c14fb0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0205082 <RR_enqueue>:
    assert(list_empty(&(proc->run_link)));
ffffffffc0205082:	1185b703          	ld	a4,280(a1)
ffffffffc0205086:	11058793          	addi	a5,a1,272
ffffffffc020508a:	02e79b63          	bne	a5,a4,ffffffffc02050c0 <RR_enqueue+0x3e>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020508e:	6114                	ld	a3,0(a0)
    rq->proc_num++;
ffffffffc0205090:	4918                	lw	a4,16(a0)
    prev->next = next->prev = elm;
ffffffffc0205092:	e11c                	sd	a5,0(a0)
ffffffffc0205094:	e69c                	sd	a5,8(a3)
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc0205096:	1205a603          	lw	a2,288(a1)
    rq->proc_num++;
ffffffffc020509a:	0017079b          	addiw	a5,a4,1
    elm->next = next;
ffffffffc020509e:	10a5bc23          	sd	a0,280(a1)
    elm->prev = prev;
ffffffffc02050a2:	10d5b823          	sd	a3,272(a1)
    proc->rq = rq;
ffffffffc02050a6:	10a5b423          	sd	a0,264(a1)
    rq->proc_num++;
ffffffffc02050aa:	c91c                	sw	a5,16(a0)
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc02050ac:	495c                	lw	a5,20(a0)
ffffffffc02050ae:	e601                	bnez	a2,ffffffffc02050b6 <RR_enqueue+0x34>
        proc->time_slice = rq->max_time_slice;
ffffffffc02050b0:	12f5a023          	sw	a5,288(a1)
ffffffffc02050b4:	8082                	ret
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc02050b6:	fec7dfe3          	bge	a5,a2,ffffffffc02050b4 <RR_enqueue+0x32>
        proc->time_slice = rq->max_time_slice;
ffffffffc02050ba:	12f5a023          	sw	a5,288(a1)
ffffffffc02050be:	bfdd                	j	ffffffffc02050b4 <RR_enqueue+0x32>
{
ffffffffc02050c0:	1141                	addi	sp,sp,-16
    assert(list_empty(&(proc->run_link)));
ffffffffc02050c2:	00002697          	auipc	a3,0x2
ffffffffc02050c6:	50668693          	addi	a3,a3,1286 # ffffffffc02075c8 <default_pmm_manager+0xec0>
ffffffffc02050ca:	00001617          	auipc	a2,0x1
ffffffffc02050ce:	28e60613          	addi	a2,a2,654 # ffffffffc0206358 <commands+0x850>
ffffffffc02050d2:	02e00593          	li	a1,46
ffffffffc02050d6:	00002517          	auipc	a0,0x2
ffffffffc02050da:	4d250513          	addi	a0,a0,1234 # ffffffffc02075a8 <default_pmm_manager+0xea0>
{
ffffffffc02050de:	e406                	sd	ra,8(sp)
    assert(list_empty(&(proc->run_link)));
ffffffffc02050e0:	bb2fb0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02050e4 <sched_class_proc_tick>:
    return sched_class->pick_next(rq);
}

void sched_class_proc_tick(struct proc_struct *proc)
{
    if (proc != idleproc)
ffffffffc02050e4:	000cd797          	auipc	a5,0xcd
ffffffffc02050e8:	6e47b783          	ld	a5,1764(a5) # ffffffffc02d27c8 <idleproc>
{
ffffffffc02050ec:	85aa                	mv	a1,a0
    if (proc != idleproc)
ffffffffc02050ee:	00a78c63          	beq	a5,a0,ffffffffc0205106 <sched_class_proc_tick+0x22>
    {
        sched_class->proc_tick(rq, proc);
ffffffffc02050f2:	000cd797          	auipc	a5,0xcd
ffffffffc02050f6:	6f67b783          	ld	a5,1782(a5) # ffffffffc02d27e8 <sched_class>
ffffffffc02050fa:	779c                	ld	a5,40(a5)
ffffffffc02050fc:	000cd517          	auipc	a0,0xcd
ffffffffc0205100:	6e453503          	ld	a0,1764(a0) # ffffffffc02d27e0 <rq>
ffffffffc0205104:	8782                	jr	a5
    }
    else
    {
        proc->need_resched = 1;
ffffffffc0205106:	4705                	li	a4,1
ffffffffc0205108:	ef98                	sd	a4,24(a5)
    }
}
ffffffffc020510a:	8082                	ret

ffffffffc020510c <sched_init>:

static struct run_queue __rq;

void sched_init(void)
{
ffffffffc020510c:	1141                	addi	sp,sp,-16
    list_init(&timer_list);

    // LAB6 CHALLENGE 2: 根据SCHED_ALGORITHM选择调度算法
#if SCHED_ALGORITHM == 0
    sched_class = &default_sched_class;     // RR调度器
ffffffffc020510e:	000c9717          	auipc	a4,0xc9
ffffffffc0205112:	1ba70713          	addi	a4,a4,442 # ffffffffc02ce2c8 <default_sched_class>
{
ffffffffc0205116:	e022                	sd	s0,0(sp)
ffffffffc0205118:	e406                	sd	ra,8(sp)
    elm->prev = elm->next = elm;
ffffffffc020511a:	000cd797          	auipc	a5,0xcd
ffffffffc020511e:	63678793          	addi	a5,a5,1590 # ffffffffc02d2750 <timer_list>
    sched_class = &default_sched_class;     // 默认使用RR
#endif

    rq = &__rq;
    rq->max_time_slice = MAX_TIME_SLICE;
    sched_class->init(rq);
ffffffffc0205122:	6714                	ld	a3,8(a4)
    rq = &__rq;
ffffffffc0205124:	000cd517          	auipc	a0,0xcd
ffffffffc0205128:	60c50513          	addi	a0,a0,1548 # ffffffffc02d2730 <__rq>
ffffffffc020512c:	e79c                	sd	a5,8(a5)
ffffffffc020512e:	e39c                	sd	a5,0(a5)
    rq->max_time_slice = MAX_TIME_SLICE;
ffffffffc0205130:	4795                	li	a5,5
ffffffffc0205132:	c95c                	sw	a5,20(a0)
    sched_class = &default_sched_class;     // RR调度器
ffffffffc0205134:	000cd417          	auipc	s0,0xcd
ffffffffc0205138:	6b440413          	addi	s0,s0,1716 # ffffffffc02d27e8 <sched_class>
    rq = &__rq;
ffffffffc020513c:	000cd797          	auipc	a5,0xcd
ffffffffc0205140:	6aa7b223          	sd	a0,1700(a5) # ffffffffc02d27e0 <rq>
    sched_class = &default_sched_class;     // RR调度器
ffffffffc0205144:	e018                	sd	a4,0(s0)
    sched_class->init(rq);
ffffffffc0205146:	9682                	jalr	a3

    cprintf("sched class: %s\n", sched_class->name);
ffffffffc0205148:	601c                	ld	a5,0(s0)
}
ffffffffc020514a:	6402                	ld	s0,0(sp)
ffffffffc020514c:	60a2                	ld	ra,8(sp)
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc020514e:	638c                	ld	a1,0(a5)
ffffffffc0205150:	00002517          	auipc	a0,0x2
ffffffffc0205154:	4a850513          	addi	a0,a0,1192 # ffffffffc02075f8 <default_pmm_manager+0xef0>
}
ffffffffc0205158:	0141                	addi	sp,sp,16
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc020515a:	83efb06f          	j	ffffffffc0200198 <cprintf>

ffffffffc020515e <wakeup_proc>:

void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020515e:	4118                	lw	a4,0(a0)
{
ffffffffc0205160:	1101                	addi	sp,sp,-32
ffffffffc0205162:	ec06                	sd	ra,24(sp)
ffffffffc0205164:	e822                	sd	s0,16(sp)
ffffffffc0205166:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205168:	478d                	li	a5,3
ffffffffc020516a:	08f70363          	beq	a4,a5,ffffffffc02051f0 <wakeup_proc+0x92>
ffffffffc020516e:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0205170:	100027f3          	csrr	a5,sstatus
ffffffffc0205174:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205176:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0205178:	e7bd                	bnez	a5,ffffffffc02051e6 <wakeup_proc+0x88>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
ffffffffc020517a:	4789                	li	a5,2
ffffffffc020517c:	04f70863          	beq	a4,a5,ffffffffc02051cc <wakeup_proc+0x6e>
        {
            proc->state = PROC_RUNNABLE;
ffffffffc0205180:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0205182:	0e042623          	sw	zero,236(s0)
            if (proc != current)
ffffffffc0205186:	000cd797          	auipc	a5,0xcd
ffffffffc020518a:	63a7b783          	ld	a5,1594(a5) # ffffffffc02d27c0 <current>
ffffffffc020518e:	02878363          	beq	a5,s0,ffffffffc02051b4 <wakeup_proc+0x56>
    if (proc != idleproc)
ffffffffc0205192:	000cd797          	auipc	a5,0xcd
ffffffffc0205196:	6367b783          	ld	a5,1590(a5) # ffffffffc02d27c8 <idleproc>
ffffffffc020519a:	00f40d63          	beq	s0,a5,ffffffffc02051b4 <wakeup_proc+0x56>
        sched_class->enqueue(rq, proc);
ffffffffc020519e:	000cd797          	auipc	a5,0xcd
ffffffffc02051a2:	64a7b783          	ld	a5,1610(a5) # ffffffffc02d27e8 <sched_class>
ffffffffc02051a6:	6b9c                	ld	a5,16(a5)
ffffffffc02051a8:	85a2                	mv	a1,s0
ffffffffc02051aa:	000cd517          	auipc	a0,0xcd
ffffffffc02051ae:	63653503          	ld	a0,1590(a0) # ffffffffc02d27e0 <rq>
ffffffffc02051b2:	9782                	jalr	a5
    if (flag)
ffffffffc02051b4:	e491                	bnez	s1,ffffffffc02051c0 <wakeup_proc+0x62>
        {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02051b6:	60e2                	ld	ra,24(sp)
ffffffffc02051b8:	6442                	ld	s0,16(sp)
ffffffffc02051ba:	64a2                	ld	s1,8(sp)
ffffffffc02051bc:	6105                	addi	sp,sp,32
ffffffffc02051be:	8082                	ret
ffffffffc02051c0:	6442                	ld	s0,16(sp)
ffffffffc02051c2:	60e2                	ld	ra,24(sp)
ffffffffc02051c4:	64a2                	ld	s1,8(sp)
ffffffffc02051c6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02051c8:	fe0fb06f          	j	ffffffffc02009a8 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc02051cc:	00002617          	auipc	a2,0x2
ffffffffc02051d0:	47c60613          	addi	a2,a2,1148 # ffffffffc0207648 <default_pmm_manager+0xf40>
ffffffffc02051d4:	06700593          	li	a1,103
ffffffffc02051d8:	00002517          	auipc	a0,0x2
ffffffffc02051dc:	45850513          	addi	a0,a0,1112 # ffffffffc0207630 <default_pmm_manager+0xf28>
ffffffffc02051e0:	b1afb0ef          	jal	ra,ffffffffc02004fa <__warn>
ffffffffc02051e4:	bfc1                	j	ffffffffc02051b4 <wakeup_proc+0x56>
        intr_disable();
ffffffffc02051e6:	fc8fb0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        if (proc->state != PROC_RUNNABLE)
ffffffffc02051ea:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc02051ec:	4485                	li	s1,1
ffffffffc02051ee:	b771                	j	ffffffffc020517a <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02051f0:	00002697          	auipc	a3,0x2
ffffffffc02051f4:	42068693          	addi	a3,a3,1056 # ffffffffc0207610 <default_pmm_manager+0xf08>
ffffffffc02051f8:	00001617          	auipc	a2,0x1
ffffffffc02051fc:	16060613          	addi	a2,a2,352 # ffffffffc0206358 <commands+0x850>
ffffffffc0205200:	05800593          	li	a1,88
ffffffffc0205204:	00002517          	auipc	a0,0x2
ffffffffc0205208:	42c50513          	addi	a0,a0,1068 # ffffffffc0207630 <default_pmm_manager+0xf28>
ffffffffc020520c:	a86fb0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0205210 <schedule>:

void schedule(void)
{
ffffffffc0205210:	7179                	addi	sp,sp,-48
ffffffffc0205212:	f406                	sd	ra,40(sp)
ffffffffc0205214:	f022                	sd	s0,32(sp)
ffffffffc0205216:	ec26                	sd	s1,24(sp)
ffffffffc0205218:	e84a                	sd	s2,16(sp)
ffffffffc020521a:	e44e                	sd	s3,8(sp)
ffffffffc020521c:	e052                	sd	s4,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020521e:	100027f3          	csrr	a5,sstatus
ffffffffc0205222:	8b89                	andi	a5,a5,2
ffffffffc0205224:	4a01                	li	s4,0
ffffffffc0205226:	e3cd                	bnez	a5,ffffffffc02052c8 <schedule+0xb8>
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205228:	000cd497          	auipc	s1,0xcd
ffffffffc020522c:	59848493          	addi	s1,s1,1432 # ffffffffc02d27c0 <current>
ffffffffc0205230:	608c                	ld	a1,0(s1)
        sched_class->enqueue(rq, proc);
ffffffffc0205232:	000cd997          	auipc	s3,0xcd
ffffffffc0205236:	5b698993          	addi	s3,s3,1462 # ffffffffc02d27e8 <sched_class>
ffffffffc020523a:	000cd917          	auipc	s2,0xcd
ffffffffc020523e:	5a690913          	addi	s2,s2,1446 # ffffffffc02d27e0 <rq>
        if (current->state == PROC_RUNNABLE)
ffffffffc0205242:	4194                	lw	a3,0(a1)
        current->need_resched = 0;
ffffffffc0205244:	0005bc23          	sd	zero,24(a1)
        if (current->state == PROC_RUNNABLE)
ffffffffc0205248:	4709                	li	a4,2
        sched_class->enqueue(rq, proc);
ffffffffc020524a:	0009b783          	ld	a5,0(s3)
ffffffffc020524e:	00093503          	ld	a0,0(s2)
        if (current->state == PROC_RUNNABLE)
ffffffffc0205252:	04e68e63          	beq	a3,a4,ffffffffc02052ae <schedule+0x9e>
    return sched_class->pick_next(rq);
ffffffffc0205256:	739c                	ld	a5,32(a5)
ffffffffc0205258:	9782                	jalr	a5
ffffffffc020525a:	842a                	mv	s0,a0
        {
            sched_class_enqueue(current);
        }
        if ((next = sched_class_pick_next()) != NULL)
ffffffffc020525c:	c521                	beqz	a0,ffffffffc02052a4 <schedule+0x94>
    sched_class->dequeue(rq, proc);
ffffffffc020525e:	0009b783          	ld	a5,0(s3)
ffffffffc0205262:	00093503          	ld	a0,0(s2)
ffffffffc0205266:	85a2                	mv	a1,s0
ffffffffc0205268:	6f9c                	ld	a5,24(a5)
ffffffffc020526a:	9782                	jalr	a5
        }
        if (next == NULL)
        {
            next = idleproc;
        }
        next->runs++;
ffffffffc020526c:	441c                	lw	a5,8(s0)
        if (next != current)
ffffffffc020526e:	6098                	ld	a4,0(s1)
        next->runs++;
ffffffffc0205270:	2785                	addiw	a5,a5,1
ffffffffc0205272:	c41c                	sw	a5,8(s0)
        if (next != current)
ffffffffc0205274:	00870563          	beq	a4,s0,ffffffffc020527e <schedule+0x6e>
        {
            proc_run(next);
ffffffffc0205278:	8522                	mv	a0,s0
ffffffffc020527a:	be7fe0ef          	jal	ra,ffffffffc0203e60 <proc_run>
    if (flag)
ffffffffc020527e:	000a1a63          	bnez	s4,ffffffffc0205292 <schedule+0x82>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205282:	70a2                	ld	ra,40(sp)
ffffffffc0205284:	7402                	ld	s0,32(sp)
ffffffffc0205286:	64e2                	ld	s1,24(sp)
ffffffffc0205288:	6942                	ld	s2,16(sp)
ffffffffc020528a:	69a2                	ld	s3,8(sp)
ffffffffc020528c:	6a02                	ld	s4,0(sp)
ffffffffc020528e:	6145                	addi	sp,sp,48
ffffffffc0205290:	8082                	ret
ffffffffc0205292:	7402                	ld	s0,32(sp)
ffffffffc0205294:	70a2                	ld	ra,40(sp)
ffffffffc0205296:	64e2                	ld	s1,24(sp)
ffffffffc0205298:	6942                	ld	s2,16(sp)
ffffffffc020529a:	69a2                	ld	s3,8(sp)
ffffffffc020529c:	6a02                	ld	s4,0(sp)
ffffffffc020529e:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc02052a0:	f08fb06f          	j	ffffffffc02009a8 <intr_enable>
            next = idleproc;
ffffffffc02052a4:	000cd417          	auipc	s0,0xcd
ffffffffc02052a8:	52443403          	ld	s0,1316(s0) # ffffffffc02d27c8 <idleproc>
ffffffffc02052ac:	b7c1                	j	ffffffffc020526c <schedule+0x5c>
    if (proc != idleproc)
ffffffffc02052ae:	000cd717          	auipc	a4,0xcd
ffffffffc02052b2:	51a73703          	ld	a4,1306(a4) # ffffffffc02d27c8 <idleproc>
ffffffffc02052b6:	fae580e3          	beq	a1,a4,ffffffffc0205256 <schedule+0x46>
        sched_class->enqueue(rq, proc);
ffffffffc02052ba:	6b9c                	ld	a5,16(a5)
ffffffffc02052bc:	9782                	jalr	a5
    return sched_class->pick_next(rq);
ffffffffc02052be:	0009b783          	ld	a5,0(s3)
ffffffffc02052c2:	00093503          	ld	a0,0(s2)
ffffffffc02052c6:	bf41                	j	ffffffffc0205256 <schedule+0x46>
        intr_disable();
ffffffffc02052c8:	ee6fb0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        return 1;
ffffffffc02052cc:	4a05                	li	s4,1
ffffffffc02052ce:	bfa9                	j	ffffffffc0205228 <schedule+0x18>

ffffffffc02052d0 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc02052d0:	000cd797          	auipc	a5,0xcd
ffffffffc02052d4:	4f07b783          	ld	a5,1264(a5) # ffffffffc02d27c0 <current>
}
ffffffffc02052d8:	43c8                	lw	a0,4(a5)
ffffffffc02052da:	8082                	ret

ffffffffc02052dc <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc02052dc:	4501                	li	a0,0
ffffffffc02052de:	8082                	ret

ffffffffc02052e0 <sys_gettime>:
static int sys_gettime(uint64_t arg[]){
    return (int)ticks*10;
ffffffffc02052e0:	000cd797          	auipc	a5,0xcd
ffffffffc02052e4:	4887b783          	ld	a5,1160(a5) # ffffffffc02d2768 <ticks>
ffffffffc02052e8:	0027951b          	slliw	a0,a5,0x2
ffffffffc02052ec:	9d3d                	addw	a0,a0,a5
}
ffffffffc02052ee:	0015151b          	slliw	a0,a0,0x1
ffffffffc02052f2:	8082                	ret

ffffffffc02052f4 <sys_lab6_set_priority>:
static int sys_lab6_set_priority(uint64_t arg[]){
    uint64_t priority = (uint64_t)arg[0];
    lab6_set_priority(priority);
ffffffffc02052f4:	4108                	lw	a0,0(a0)
static int sys_lab6_set_priority(uint64_t arg[]){
ffffffffc02052f6:	1141                	addi	sp,sp,-16
ffffffffc02052f8:	e406                	sd	ra,8(sp)
    lab6_set_priority(priority);
ffffffffc02052fa:	c67ff0ef          	jal	ra,ffffffffc0204f60 <lab6_set_priority>
    return 0;
}
ffffffffc02052fe:	60a2                	ld	ra,8(sp)
ffffffffc0205300:	4501                	li	a0,0
ffffffffc0205302:	0141                	addi	sp,sp,16
ffffffffc0205304:	8082                	ret

ffffffffc0205306 <sys_putc>:
    cputchar(c);
ffffffffc0205306:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0205308:	1141                	addi	sp,sp,-16
ffffffffc020530a:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc020530c:	ec3fa0ef          	jal	ra,ffffffffc02001ce <cputchar>
}
ffffffffc0205310:	60a2                	ld	ra,8(sp)
ffffffffc0205312:	4501                	li	a0,0
ffffffffc0205314:	0141                	addi	sp,sp,16
ffffffffc0205316:	8082                	ret

ffffffffc0205318 <sys_kill>:
    return do_kill(pid);
ffffffffc0205318:	4108                	lw	a0,0(a0)
ffffffffc020531a:	a19ff06f          	j	ffffffffc0204d32 <do_kill>

ffffffffc020531e <sys_yield>:
    return do_yield();
ffffffffc020531e:	9c7ff06f          	j	ffffffffc0204ce4 <do_yield>

ffffffffc0205322 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0205322:	6d14                	ld	a3,24(a0)
ffffffffc0205324:	6910                	ld	a2,16(a0)
ffffffffc0205326:	650c                	ld	a1,8(a0)
ffffffffc0205328:	6108                	ld	a0,0(a0)
ffffffffc020532a:	c10ff06f          	j	ffffffffc020473a <do_execve>

ffffffffc020532e <sys_wait>:
    return do_wait(pid, store);
ffffffffc020532e:	650c                	ld	a1,8(a0)
ffffffffc0205330:	4108                	lw	a0,0(a0)
ffffffffc0205332:	9c3ff06f          	j	ffffffffc0204cf4 <do_wait>

ffffffffc0205336 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0205336:	000cd797          	auipc	a5,0xcd
ffffffffc020533a:	48a7b783          	ld	a5,1162(a5) # ffffffffc02d27c0 <current>
ffffffffc020533e:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0205340:	4501                	li	a0,0
ffffffffc0205342:	6a0c                	ld	a1,16(a2)
ffffffffc0205344:	b81fe06f          	j	ffffffffc0203ec4 <do_fork>

ffffffffc0205348 <sys_exit>:
    return do_exit(error_code);
ffffffffc0205348:	4108                	lw	a0,0(a0)
ffffffffc020534a:	fb1fe06f          	j	ffffffffc02042fa <do_exit>

ffffffffc020534e <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc020534e:	715d                	addi	sp,sp,-80
ffffffffc0205350:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205352:	000cd497          	auipc	s1,0xcd
ffffffffc0205356:	46e48493          	addi	s1,s1,1134 # ffffffffc02d27c0 <current>
ffffffffc020535a:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc020535c:	e0a2                	sd	s0,64(sp)
ffffffffc020535e:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205360:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0205362:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205364:	0ff00793          	li	a5,255
    int num = tf->gpr.a0;
ffffffffc0205368:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc020536c:	0327ee63          	bltu	a5,s2,ffffffffc02053a8 <syscall+0x5a>
        if (syscalls[num] != NULL) {
ffffffffc0205370:	00391713          	slli	a4,s2,0x3
ffffffffc0205374:	00002797          	auipc	a5,0x2
ffffffffc0205378:	33c78793          	addi	a5,a5,828 # ffffffffc02076b0 <syscalls>
ffffffffc020537c:	97ba                	add	a5,a5,a4
ffffffffc020537e:	639c                	ld	a5,0(a5)
ffffffffc0205380:	c785                	beqz	a5,ffffffffc02053a8 <syscall+0x5a>
            arg[0] = tf->gpr.a1;
ffffffffc0205382:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0205384:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0205386:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0205388:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc020538a:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc020538c:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc020538e:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0205390:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0205392:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0205394:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205396:	0028                	addi	a0,sp,8
ffffffffc0205398:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc020539a:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc020539c:	e828                	sd	a0,80(s0)
}
ffffffffc020539e:	6406                	ld	s0,64(sp)
ffffffffc02053a0:	74e2                	ld	s1,56(sp)
ffffffffc02053a2:	7942                	ld	s2,48(sp)
ffffffffc02053a4:	6161                	addi	sp,sp,80
ffffffffc02053a6:	8082                	ret
    print_trapframe(tf);
ffffffffc02053a8:	8522                	mv	a0,s0
ffffffffc02053aa:	ff4fb0ef          	jal	ra,ffffffffc0200b9e <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc02053ae:	609c                	ld	a5,0(s1)
ffffffffc02053b0:	86ca                	mv	a3,s2
ffffffffc02053b2:	00002617          	auipc	a2,0x2
ffffffffc02053b6:	2b660613          	addi	a2,a2,694 # ffffffffc0207668 <default_pmm_manager+0xf60>
ffffffffc02053ba:	43d8                	lw	a4,4(a5)
ffffffffc02053bc:	06c00593          	li	a1,108
ffffffffc02053c0:	0b478793          	addi	a5,a5,180
ffffffffc02053c4:	00002517          	auipc	a0,0x2
ffffffffc02053c8:	2d450513          	addi	a0,a0,724 # ffffffffc0207698 <default_pmm_manager+0xf90>
ffffffffc02053cc:	8c6fb0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02053d0 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02053d0:	9e3707b7          	lui	a5,0x9e370
ffffffffc02053d4:	2785                	addiw	a5,a5,1
ffffffffc02053d6:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc02053da:	02000793          	li	a5,32
ffffffffc02053de:	9f8d                	subw	a5,a5,a1
}
ffffffffc02053e0:	00f5553b          	srlw	a0,a0,a5
ffffffffc02053e4:	8082                	ret

ffffffffc02053e6 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02053e6:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02053ea:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02053ec:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02053f0:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02053f2:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02053f6:	f022                	sd	s0,32(sp)
ffffffffc02053f8:	ec26                	sd	s1,24(sp)
ffffffffc02053fa:	e84a                	sd	s2,16(sp)
ffffffffc02053fc:	f406                	sd	ra,40(sp)
ffffffffc02053fe:	e44e                	sd	s3,8(sp)
ffffffffc0205400:	84aa                	mv	s1,a0
ffffffffc0205402:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0205404:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0205408:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020540a:	03067e63          	bgeu	a2,a6,ffffffffc0205446 <printnum+0x60>
ffffffffc020540e:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0205410:	00805763          	blez	s0,ffffffffc020541e <printnum+0x38>
ffffffffc0205414:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0205416:	85ca                	mv	a1,s2
ffffffffc0205418:	854e                	mv	a0,s3
ffffffffc020541a:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020541c:	fc65                	bnez	s0,ffffffffc0205414 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020541e:	1a02                	slli	s4,s4,0x20
ffffffffc0205420:	00003797          	auipc	a5,0x3
ffffffffc0205424:	a9078793          	addi	a5,a5,-1392 # ffffffffc0207eb0 <syscalls+0x800>
ffffffffc0205428:	020a5a13          	srli	s4,s4,0x20
ffffffffc020542c:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc020542e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205430:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0205434:	70a2                	ld	ra,40(sp)
ffffffffc0205436:	69a2                	ld	s3,8(sp)
ffffffffc0205438:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020543a:	85ca                	mv	a1,s2
ffffffffc020543c:	87a6                	mv	a5,s1
}
ffffffffc020543e:	6942                	ld	s2,16(sp)
ffffffffc0205440:	64e2                	ld	s1,24(sp)
ffffffffc0205442:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205444:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0205446:	03065633          	divu	a2,a2,a6
ffffffffc020544a:	8722                	mv	a4,s0
ffffffffc020544c:	f9bff0ef          	jal	ra,ffffffffc02053e6 <printnum>
ffffffffc0205450:	b7f9                	j	ffffffffc020541e <printnum+0x38>

ffffffffc0205452 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0205452:	7119                	addi	sp,sp,-128
ffffffffc0205454:	f4a6                	sd	s1,104(sp)
ffffffffc0205456:	f0ca                	sd	s2,96(sp)
ffffffffc0205458:	ecce                	sd	s3,88(sp)
ffffffffc020545a:	e8d2                	sd	s4,80(sp)
ffffffffc020545c:	e4d6                	sd	s5,72(sp)
ffffffffc020545e:	e0da                	sd	s6,64(sp)
ffffffffc0205460:	fc5e                	sd	s7,56(sp)
ffffffffc0205462:	f06a                	sd	s10,32(sp)
ffffffffc0205464:	fc86                	sd	ra,120(sp)
ffffffffc0205466:	f8a2                	sd	s0,112(sp)
ffffffffc0205468:	f862                	sd	s8,48(sp)
ffffffffc020546a:	f466                	sd	s9,40(sp)
ffffffffc020546c:	ec6e                	sd	s11,24(sp)
ffffffffc020546e:	892a                	mv	s2,a0
ffffffffc0205470:	84ae                	mv	s1,a1
ffffffffc0205472:	8d32                	mv	s10,a2
ffffffffc0205474:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205476:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020547a:	5b7d                	li	s6,-1
ffffffffc020547c:	00003a97          	auipc	s5,0x3
ffffffffc0205480:	a60a8a93          	addi	s5,s5,-1440 # ffffffffc0207edc <syscalls+0x82c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205484:	00003b97          	auipc	s7,0x3
ffffffffc0205488:	c74b8b93          	addi	s7,s7,-908 # ffffffffc02080f8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020548c:	000d4503          	lbu	a0,0(s10)
ffffffffc0205490:	001d0413          	addi	s0,s10,1
ffffffffc0205494:	01350a63          	beq	a0,s3,ffffffffc02054a8 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0205498:	c121                	beqz	a0,ffffffffc02054d8 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020549a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020549c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020549e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02054a0:	fff44503          	lbu	a0,-1(s0)
ffffffffc02054a4:	ff351ae3          	bne	a0,s3,ffffffffc0205498 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02054a8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02054ac:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02054b0:	4c81                	li	s9,0
ffffffffc02054b2:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02054b4:	5c7d                	li	s8,-1
ffffffffc02054b6:	5dfd                	li	s11,-1
ffffffffc02054b8:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02054bc:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02054be:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02054c2:	0ff5f593          	zext.b	a1,a1
ffffffffc02054c6:	00140d13          	addi	s10,s0,1
ffffffffc02054ca:	04b56263          	bltu	a0,a1,ffffffffc020550e <vprintfmt+0xbc>
ffffffffc02054ce:	058a                	slli	a1,a1,0x2
ffffffffc02054d0:	95d6                	add	a1,a1,s5
ffffffffc02054d2:	4194                	lw	a3,0(a1)
ffffffffc02054d4:	96d6                	add	a3,a3,s5
ffffffffc02054d6:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02054d8:	70e6                	ld	ra,120(sp)
ffffffffc02054da:	7446                	ld	s0,112(sp)
ffffffffc02054dc:	74a6                	ld	s1,104(sp)
ffffffffc02054de:	7906                	ld	s2,96(sp)
ffffffffc02054e0:	69e6                	ld	s3,88(sp)
ffffffffc02054e2:	6a46                	ld	s4,80(sp)
ffffffffc02054e4:	6aa6                	ld	s5,72(sp)
ffffffffc02054e6:	6b06                	ld	s6,64(sp)
ffffffffc02054e8:	7be2                	ld	s7,56(sp)
ffffffffc02054ea:	7c42                	ld	s8,48(sp)
ffffffffc02054ec:	7ca2                	ld	s9,40(sp)
ffffffffc02054ee:	7d02                	ld	s10,32(sp)
ffffffffc02054f0:	6de2                	ld	s11,24(sp)
ffffffffc02054f2:	6109                	addi	sp,sp,128
ffffffffc02054f4:	8082                	ret
            padc = '0';
ffffffffc02054f6:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02054f8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02054fc:	846a                	mv	s0,s10
ffffffffc02054fe:	00140d13          	addi	s10,s0,1
ffffffffc0205502:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0205506:	0ff5f593          	zext.b	a1,a1
ffffffffc020550a:	fcb572e3          	bgeu	a0,a1,ffffffffc02054ce <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020550e:	85a6                	mv	a1,s1
ffffffffc0205510:	02500513          	li	a0,37
ffffffffc0205514:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0205516:	fff44783          	lbu	a5,-1(s0)
ffffffffc020551a:	8d22                	mv	s10,s0
ffffffffc020551c:	f73788e3          	beq	a5,s3,ffffffffc020548c <vprintfmt+0x3a>
ffffffffc0205520:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0205524:	1d7d                	addi	s10,s10,-1
ffffffffc0205526:	ff379de3          	bne	a5,s3,ffffffffc0205520 <vprintfmt+0xce>
ffffffffc020552a:	b78d                	j	ffffffffc020548c <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020552c:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0205530:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205534:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0205536:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020553a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020553e:	02d86463          	bltu	a6,a3,ffffffffc0205566 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0205542:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0205546:	002c169b          	slliw	a3,s8,0x2
ffffffffc020554a:	0186873b          	addw	a4,a3,s8
ffffffffc020554e:	0017171b          	slliw	a4,a4,0x1
ffffffffc0205552:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0205554:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0205558:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020555a:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020555e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0205562:	fed870e3          	bgeu	a6,a3,ffffffffc0205542 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0205566:	f40ddce3          	bgez	s11,ffffffffc02054be <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020556a:	8de2                	mv	s11,s8
ffffffffc020556c:	5c7d                	li	s8,-1
ffffffffc020556e:	bf81                	j	ffffffffc02054be <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0205570:	fffdc693          	not	a3,s11
ffffffffc0205574:	96fd                	srai	a3,a3,0x3f
ffffffffc0205576:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020557a:	00144603          	lbu	a2,1(s0)
ffffffffc020557e:	2d81                	sext.w	s11,s11
ffffffffc0205580:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0205582:	bf35                	j	ffffffffc02054be <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0205584:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205588:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020558c:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020558e:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0205590:	bfd9                	j	ffffffffc0205566 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0205592:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205594:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205598:	01174463          	blt	a4,a7,ffffffffc02055a0 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020559c:	1a088e63          	beqz	a7,ffffffffc0205758 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02055a0:	000a3603          	ld	a2,0(s4)
ffffffffc02055a4:	46c1                	li	a3,16
ffffffffc02055a6:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02055a8:	2781                	sext.w	a5,a5
ffffffffc02055aa:	876e                	mv	a4,s11
ffffffffc02055ac:	85a6                	mv	a1,s1
ffffffffc02055ae:	854a                	mv	a0,s2
ffffffffc02055b0:	e37ff0ef          	jal	ra,ffffffffc02053e6 <printnum>
            break;
ffffffffc02055b4:	bde1                	j	ffffffffc020548c <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02055b6:	000a2503          	lw	a0,0(s4)
ffffffffc02055ba:	85a6                	mv	a1,s1
ffffffffc02055bc:	0a21                	addi	s4,s4,8
ffffffffc02055be:	9902                	jalr	s2
            break;
ffffffffc02055c0:	b5f1                	j	ffffffffc020548c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02055c2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02055c4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02055c8:	01174463          	blt	a4,a7,ffffffffc02055d0 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02055cc:	18088163          	beqz	a7,ffffffffc020574e <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02055d0:	000a3603          	ld	a2,0(s4)
ffffffffc02055d4:	46a9                	li	a3,10
ffffffffc02055d6:	8a2e                	mv	s4,a1
ffffffffc02055d8:	bfc1                	j	ffffffffc02055a8 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02055da:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02055de:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02055e0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02055e2:	bdf1                	j	ffffffffc02054be <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02055e4:	85a6                	mv	a1,s1
ffffffffc02055e6:	02500513          	li	a0,37
ffffffffc02055ea:	9902                	jalr	s2
            break;
ffffffffc02055ec:	b545                	j	ffffffffc020548c <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02055ee:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02055f2:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02055f4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02055f6:	b5e1                	j	ffffffffc02054be <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02055f8:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02055fa:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02055fe:	01174463          	blt	a4,a7,ffffffffc0205606 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0205602:	14088163          	beqz	a7,ffffffffc0205744 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0205606:	000a3603          	ld	a2,0(s4)
ffffffffc020560a:	46a1                	li	a3,8
ffffffffc020560c:	8a2e                	mv	s4,a1
ffffffffc020560e:	bf69                	j	ffffffffc02055a8 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0205610:	03000513          	li	a0,48
ffffffffc0205614:	85a6                	mv	a1,s1
ffffffffc0205616:	e03e                	sd	a5,0(sp)
ffffffffc0205618:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020561a:	85a6                	mv	a1,s1
ffffffffc020561c:	07800513          	li	a0,120
ffffffffc0205620:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0205622:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0205624:	6782                	ld	a5,0(sp)
ffffffffc0205626:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0205628:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020562c:	bfb5                	j	ffffffffc02055a8 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020562e:	000a3403          	ld	s0,0(s4)
ffffffffc0205632:	008a0713          	addi	a4,s4,8
ffffffffc0205636:	e03a                	sd	a4,0(sp)
ffffffffc0205638:	14040263          	beqz	s0,ffffffffc020577c <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020563c:	0fb05763          	blez	s11,ffffffffc020572a <vprintfmt+0x2d8>
ffffffffc0205640:	02d00693          	li	a3,45
ffffffffc0205644:	0cd79163          	bne	a5,a3,ffffffffc0205706 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205648:	00044783          	lbu	a5,0(s0)
ffffffffc020564c:	0007851b          	sext.w	a0,a5
ffffffffc0205650:	cf85                	beqz	a5,ffffffffc0205688 <vprintfmt+0x236>
ffffffffc0205652:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205656:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020565a:	000c4563          	bltz	s8,ffffffffc0205664 <vprintfmt+0x212>
ffffffffc020565e:	3c7d                	addiw	s8,s8,-1
ffffffffc0205660:	036c0263          	beq	s8,s6,ffffffffc0205684 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0205664:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205666:	0e0c8e63          	beqz	s9,ffffffffc0205762 <vprintfmt+0x310>
ffffffffc020566a:	3781                	addiw	a5,a5,-32
ffffffffc020566c:	0ef47b63          	bgeu	s0,a5,ffffffffc0205762 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0205670:	03f00513          	li	a0,63
ffffffffc0205674:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205676:	000a4783          	lbu	a5,0(s4)
ffffffffc020567a:	3dfd                	addiw	s11,s11,-1
ffffffffc020567c:	0a05                	addi	s4,s4,1
ffffffffc020567e:	0007851b          	sext.w	a0,a5
ffffffffc0205682:	ffe1                	bnez	a5,ffffffffc020565a <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0205684:	01b05963          	blez	s11,ffffffffc0205696 <vprintfmt+0x244>
ffffffffc0205688:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020568a:	85a6                	mv	a1,s1
ffffffffc020568c:	02000513          	li	a0,32
ffffffffc0205690:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0205692:	fe0d9be3          	bnez	s11,ffffffffc0205688 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0205696:	6a02                	ld	s4,0(sp)
ffffffffc0205698:	bbd5                	j	ffffffffc020548c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020569a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020569c:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02056a0:	01174463          	blt	a4,a7,ffffffffc02056a8 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02056a4:	08088d63          	beqz	a7,ffffffffc020573e <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02056a8:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02056ac:	0a044d63          	bltz	s0,ffffffffc0205766 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02056b0:	8622                	mv	a2,s0
ffffffffc02056b2:	8a66                	mv	s4,s9
ffffffffc02056b4:	46a9                	li	a3,10
ffffffffc02056b6:	bdcd                	j	ffffffffc02055a8 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02056b8:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02056bc:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02056be:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02056c0:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02056c4:	8fb5                	xor	a5,a5,a3
ffffffffc02056c6:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02056ca:	02d74163          	blt	a4,a3,ffffffffc02056ec <vprintfmt+0x29a>
ffffffffc02056ce:	00369793          	slli	a5,a3,0x3
ffffffffc02056d2:	97de                	add	a5,a5,s7
ffffffffc02056d4:	639c                	ld	a5,0(a5)
ffffffffc02056d6:	cb99                	beqz	a5,ffffffffc02056ec <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02056d8:	86be                	mv	a3,a5
ffffffffc02056da:	00000617          	auipc	a2,0x0
ffffffffc02056de:	1ee60613          	addi	a2,a2,494 # ffffffffc02058c8 <etext+0x28>
ffffffffc02056e2:	85a6                	mv	a1,s1
ffffffffc02056e4:	854a                	mv	a0,s2
ffffffffc02056e6:	0ce000ef          	jal	ra,ffffffffc02057b4 <printfmt>
ffffffffc02056ea:	b34d                	j	ffffffffc020548c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02056ec:	00002617          	auipc	a2,0x2
ffffffffc02056f0:	7e460613          	addi	a2,a2,2020 # ffffffffc0207ed0 <syscalls+0x820>
ffffffffc02056f4:	85a6                	mv	a1,s1
ffffffffc02056f6:	854a                	mv	a0,s2
ffffffffc02056f8:	0bc000ef          	jal	ra,ffffffffc02057b4 <printfmt>
ffffffffc02056fc:	bb41                	j	ffffffffc020548c <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02056fe:	00002417          	auipc	s0,0x2
ffffffffc0205702:	7ca40413          	addi	s0,s0,1994 # ffffffffc0207ec8 <syscalls+0x818>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205706:	85e2                	mv	a1,s8
ffffffffc0205708:	8522                	mv	a0,s0
ffffffffc020570a:	e43e                	sd	a5,8(sp)
ffffffffc020570c:	0e2000ef          	jal	ra,ffffffffc02057ee <strnlen>
ffffffffc0205710:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0205714:	01b05b63          	blez	s11,ffffffffc020572a <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0205718:	67a2                	ld	a5,8(sp)
ffffffffc020571a:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020571e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0205720:	85a6                	mv	a1,s1
ffffffffc0205722:	8552                	mv	a0,s4
ffffffffc0205724:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205726:	fe0d9ce3          	bnez	s11,ffffffffc020571e <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020572a:	00044783          	lbu	a5,0(s0)
ffffffffc020572e:	00140a13          	addi	s4,s0,1
ffffffffc0205732:	0007851b          	sext.w	a0,a5
ffffffffc0205736:	d3a5                	beqz	a5,ffffffffc0205696 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205738:	05e00413          	li	s0,94
ffffffffc020573c:	bf39                	j	ffffffffc020565a <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020573e:	000a2403          	lw	s0,0(s4)
ffffffffc0205742:	b7ad                	j	ffffffffc02056ac <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0205744:	000a6603          	lwu	a2,0(s4)
ffffffffc0205748:	46a1                	li	a3,8
ffffffffc020574a:	8a2e                	mv	s4,a1
ffffffffc020574c:	bdb1                	j	ffffffffc02055a8 <vprintfmt+0x156>
ffffffffc020574e:	000a6603          	lwu	a2,0(s4)
ffffffffc0205752:	46a9                	li	a3,10
ffffffffc0205754:	8a2e                	mv	s4,a1
ffffffffc0205756:	bd89                	j	ffffffffc02055a8 <vprintfmt+0x156>
ffffffffc0205758:	000a6603          	lwu	a2,0(s4)
ffffffffc020575c:	46c1                	li	a3,16
ffffffffc020575e:	8a2e                	mv	s4,a1
ffffffffc0205760:	b5a1                	j	ffffffffc02055a8 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0205762:	9902                	jalr	s2
ffffffffc0205764:	bf09                	j	ffffffffc0205676 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0205766:	85a6                	mv	a1,s1
ffffffffc0205768:	02d00513          	li	a0,45
ffffffffc020576c:	e03e                	sd	a5,0(sp)
ffffffffc020576e:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0205770:	6782                	ld	a5,0(sp)
ffffffffc0205772:	8a66                	mv	s4,s9
ffffffffc0205774:	40800633          	neg	a2,s0
ffffffffc0205778:	46a9                	li	a3,10
ffffffffc020577a:	b53d                	j	ffffffffc02055a8 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020577c:	03b05163          	blez	s11,ffffffffc020579e <vprintfmt+0x34c>
ffffffffc0205780:	02d00693          	li	a3,45
ffffffffc0205784:	f6d79de3          	bne	a5,a3,ffffffffc02056fe <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0205788:	00002417          	auipc	s0,0x2
ffffffffc020578c:	74040413          	addi	s0,s0,1856 # ffffffffc0207ec8 <syscalls+0x818>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205790:	02800793          	li	a5,40
ffffffffc0205794:	02800513          	li	a0,40
ffffffffc0205798:	00140a13          	addi	s4,s0,1
ffffffffc020579c:	bd6d                	j	ffffffffc0205656 <vprintfmt+0x204>
ffffffffc020579e:	00002a17          	auipc	s4,0x2
ffffffffc02057a2:	72ba0a13          	addi	s4,s4,1835 # ffffffffc0207ec9 <syscalls+0x819>
ffffffffc02057a6:	02800513          	li	a0,40
ffffffffc02057aa:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02057ae:	05e00413          	li	s0,94
ffffffffc02057b2:	b565                	j	ffffffffc020565a <vprintfmt+0x208>

ffffffffc02057b4 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02057b4:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02057b6:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02057ba:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02057bc:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02057be:	ec06                	sd	ra,24(sp)
ffffffffc02057c0:	f83a                	sd	a4,48(sp)
ffffffffc02057c2:	fc3e                	sd	a5,56(sp)
ffffffffc02057c4:	e0c2                	sd	a6,64(sp)
ffffffffc02057c6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02057c8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02057ca:	c89ff0ef          	jal	ra,ffffffffc0205452 <vprintfmt>
}
ffffffffc02057ce:	60e2                	ld	ra,24(sp)
ffffffffc02057d0:	6161                	addi	sp,sp,80
ffffffffc02057d2:	8082                	ret

ffffffffc02057d4 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02057d4:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02057d8:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02057da:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02057dc:	cb81                	beqz	a5,ffffffffc02057ec <strlen+0x18>
        cnt ++;
ffffffffc02057de:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02057e0:	00a707b3          	add	a5,a4,a0
ffffffffc02057e4:	0007c783          	lbu	a5,0(a5)
ffffffffc02057e8:	fbfd                	bnez	a5,ffffffffc02057de <strlen+0xa>
ffffffffc02057ea:	8082                	ret
    }
    return cnt;
}
ffffffffc02057ec:	8082                	ret

ffffffffc02057ee <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02057ee:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02057f0:	e589                	bnez	a1,ffffffffc02057fa <strnlen+0xc>
ffffffffc02057f2:	a811                	j	ffffffffc0205806 <strnlen+0x18>
        cnt ++;
ffffffffc02057f4:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02057f6:	00f58863          	beq	a1,a5,ffffffffc0205806 <strnlen+0x18>
ffffffffc02057fa:	00f50733          	add	a4,a0,a5
ffffffffc02057fe:	00074703          	lbu	a4,0(a4)
ffffffffc0205802:	fb6d                	bnez	a4,ffffffffc02057f4 <strnlen+0x6>
ffffffffc0205804:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0205806:	852e                	mv	a0,a1
ffffffffc0205808:	8082                	ret

ffffffffc020580a <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020580a:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020580c:	0005c703          	lbu	a4,0(a1)
ffffffffc0205810:	0785                	addi	a5,a5,1
ffffffffc0205812:	0585                	addi	a1,a1,1
ffffffffc0205814:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0205818:	fb75                	bnez	a4,ffffffffc020580c <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020581a:	8082                	ret

ffffffffc020581c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020581c:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205820:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205824:	cb89                	beqz	a5,ffffffffc0205836 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0205826:	0505                	addi	a0,a0,1
ffffffffc0205828:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020582a:	fee789e3          	beq	a5,a4,ffffffffc020581c <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020582e:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0205832:	9d19                	subw	a0,a0,a4
ffffffffc0205834:	8082                	ret
ffffffffc0205836:	4501                	li	a0,0
ffffffffc0205838:	bfed                	j	ffffffffc0205832 <strcmp+0x16>

ffffffffc020583a <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020583a:	c20d                	beqz	a2,ffffffffc020585c <strncmp+0x22>
ffffffffc020583c:	962e                	add	a2,a2,a1
ffffffffc020583e:	a031                	j	ffffffffc020584a <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0205840:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205842:	00e79a63          	bne	a5,a4,ffffffffc0205856 <strncmp+0x1c>
ffffffffc0205846:	00b60b63          	beq	a2,a1,ffffffffc020585c <strncmp+0x22>
ffffffffc020584a:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc020584e:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205850:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0205854:	f7f5                	bnez	a5,ffffffffc0205840 <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205856:	40e7853b          	subw	a0,a5,a4
}
ffffffffc020585a:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020585c:	4501                	li	a0,0
ffffffffc020585e:	8082                	ret

ffffffffc0205860 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0205860:	00054783          	lbu	a5,0(a0)
ffffffffc0205864:	c799                	beqz	a5,ffffffffc0205872 <strchr+0x12>
        if (*s == c) {
ffffffffc0205866:	00f58763          	beq	a1,a5,ffffffffc0205874 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020586a:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc020586e:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0205870:	fbfd                	bnez	a5,ffffffffc0205866 <strchr+0x6>
    }
    return NULL;
ffffffffc0205872:	4501                	li	a0,0
}
ffffffffc0205874:	8082                	ret

ffffffffc0205876 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0205876:	ca01                	beqz	a2,ffffffffc0205886 <memset+0x10>
ffffffffc0205878:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020587a:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020587c:	0785                	addi	a5,a5,1
ffffffffc020587e:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0205882:	fec79de3          	bne	a5,a2,ffffffffc020587c <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0205886:	8082                	ret

ffffffffc0205888 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0205888:	ca19                	beqz	a2,ffffffffc020589e <memcpy+0x16>
ffffffffc020588a:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020588c:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020588e:	0005c703          	lbu	a4,0(a1)
ffffffffc0205892:	0585                	addi	a1,a1,1
ffffffffc0205894:	0785                	addi	a5,a5,1
ffffffffc0205896:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020589a:	fec59ae3          	bne	a1,a2,ffffffffc020588e <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020589e:	8082                	ret
