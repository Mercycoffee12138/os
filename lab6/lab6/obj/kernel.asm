
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
ffffffffc020004a:	000c3517          	auipc	a0,0xc3
ffffffffc020004e:	85e50513          	addi	a0,a0,-1954 # ffffffffc02c28a8 <buf>
ffffffffc0200052:	000c7617          	auipc	a2,0xc7
ffffffffc0200056:	d3660613          	addi	a2,a2,-714 # ffffffffc02c6d88 <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	7b8050ef          	jal	ra,ffffffffc020581a <memset>
    cons_init(); // init the console
ffffffffc0200066:	520000ef          	jal	ra,ffffffffc0200586 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006a:	00005597          	auipc	a1,0x5
ffffffffc020006e:	7de58593          	addi	a1,a1,2014 # ffffffffc0205848 <etext+0x4>
ffffffffc0200072:	00005517          	auipc	a0,0x5
ffffffffc0200076:	7f650513          	addi	a0,a0,2038 # ffffffffc0205868 <etext+0x24>
ffffffffc020007a:	11e000ef          	jal	ra,ffffffffc0200198 <cprintf>

    print_kerninfo();
ffffffffc020007e:	1a2000ef          	jal	ra,ffffffffc0200220 <print_kerninfo>

    // grade_backtrace();

    dtb_init(); // init dtb
ffffffffc0200082:	576000ef          	jal	ra,ffffffffc02005f8 <dtb_init>

    pmm_init(); // init physical memory management
ffffffffc0200086:	5dc020ef          	jal	ra,ffffffffc0202662 <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	12b000ef          	jal	ra,ffffffffc02009b4 <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	129000ef          	jal	ra,ffffffffc02009b6 <idt_init>

    vmm_init(); // init virtual memory management
ffffffffc0200092:	0a9030ef          	jal	ra,ffffffffc020393a <vmm_init>
    sched_init();
ffffffffc0200096:	01a050ef          	jal	ra,ffffffffc02050b0 <sched_init>
    proc_init(); // init process table
ffffffffc020009a:	4c9040ef          	jal	ra,ffffffffc0204d62 <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009e:	4a0000ef          	jal	ra,ffffffffc020053e <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc02000a2:	107000ef          	jal	ra,ffffffffc02009a8 <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a6:	655040ef          	jal	ra,ffffffffc0204efa <cpu_idle>

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
ffffffffc02000c0:	00005517          	auipc	a0,0x5
ffffffffc02000c4:	7b050513          	addi	a0,a0,1968 # ffffffffc0205870 <etext+0x2c>
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
ffffffffc02000d6:	000c2b97          	auipc	s7,0xc2
ffffffffc02000da:	7d2b8b93          	addi	s7,s7,2002 # ffffffffc02c28a8 <buf>
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
ffffffffc0200132:	000c2517          	auipc	a0,0xc2
ffffffffc0200136:	77650513          	addi	a0,a0,1910 # ffffffffc02c28a8 <buf>
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
ffffffffc020018c:	26a050ef          	jal	ra,ffffffffc02053f6 <vprintfmt>
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
ffffffffc02001c2:	234050ef          	jal	ra,ffffffffc02053f6 <vprintfmt>
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
ffffffffc0200226:	65650513          	addi	a0,a0,1622 # ffffffffc0205878 <etext+0x34>
void print_kerninfo(void) {
ffffffffc020022a:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020022c:	f6dff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200230:	00000597          	auipc	a1,0x0
ffffffffc0200234:	e1a58593          	addi	a1,a1,-486 # ffffffffc020004a <kern_init>
ffffffffc0200238:	00005517          	auipc	a0,0x5
ffffffffc020023c:	66050513          	addi	a0,a0,1632 # ffffffffc0205898 <etext+0x54>
ffffffffc0200240:	f59ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200244:	00005597          	auipc	a1,0x5
ffffffffc0200248:	60058593          	addi	a1,a1,1536 # ffffffffc0205844 <etext>
ffffffffc020024c:	00005517          	auipc	a0,0x5
ffffffffc0200250:	66c50513          	addi	a0,a0,1644 # ffffffffc02058b8 <etext+0x74>
ffffffffc0200254:	f45ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200258:	000c2597          	auipc	a1,0xc2
ffffffffc020025c:	65058593          	addi	a1,a1,1616 # ffffffffc02c28a8 <buf>
ffffffffc0200260:	00005517          	auipc	a0,0x5
ffffffffc0200264:	67850513          	addi	a0,a0,1656 # ffffffffc02058d8 <etext+0x94>
ffffffffc0200268:	f31ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc020026c:	000c7597          	auipc	a1,0xc7
ffffffffc0200270:	b1c58593          	addi	a1,a1,-1252 # ffffffffc02c6d88 <end>
ffffffffc0200274:	00005517          	auipc	a0,0x5
ffffffffc0200278:	68450513          	addi	a0,a0,1668 # ffffffffc02058f8 <etext+0xb4>
ffffffffc020027c:	f1dff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200280:	000c7597          	auipc	a1,0xc7
ffffffffc0200284:	f0758593          	addi	a1,a1,-249 # ffffffffc02c7187 <end+0x3ff>
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
ffffffffc02002a6:	67650513          	addi	a0,a0,1654 # ffffffffc0205918 <etext+0xd4>
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
ffffffffc02002b4:	69860613          	addi	a2,a2,1688 # ffffffffc0205948 <etext+0x104>
ffffffffc02002b8:	04d00593          	li	a1,77
ffffffffc02002bc:	00005517          	auipc	a0,0x5
ffffffffc02002c0:	6a450513          	addi	a0,a0,1700 # ffffffffc0205960 <etext+0x11c>
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
ffffffffc02002d0:	6ac60613          	addi	a2,a2,1708 # ffffffffc0205978 <etext+0x134>
ffffffffc02002d4:	00005597          	auipc	a1,0x5
ffffffffc02002d8:	6c458593          	addi	a1,a1,1732 # ffffffffc0205998 <etext+0x154>
ffffffffc02002dc:	00005517          	auipc	a0,0x5
ffffffffc02002e0:	6c450513          	addi	a0,a0,1732 # ffffffffc02059a0 <etext+0x15c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e4:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e6:	eb3ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
ffffffffc02002ea:	00005617          	auipc	a2,0x5
ffffffffc02002ee:	6c660613          	addi	a2,a2,1734 # ffffffffc02059b0 <etext+0x16c>
ffffffffc02002f2:	00005597          	auipc	a1,0x5
ffffffffc02002f6:	6e658593          	addi	a1,a1,1766 # ffffffffc02059d8 <etext+0x194>
ffffffffc02002fa:	00005517          	auipc	a0,0x5
ffffffffc02002fe:	6a650513          	addi	a0,a0,1702 # ffffffffc02059a0 <etext+0x15c>
ffffffffc0200302:	e97ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
ffffffffc0200306:	00005617          	auipc	a2,0x5
ffffffffc020030a:	6e260613          	addi	a2,a2,1762 # ffffffffc02059e8 <etext+0x1a4>
ffffffffc020030e:	00005597          	auipc	a1,0x5
ffffffffc0200312:	6fa58593          	addi	a1,a1,1786 # ffffffffc0205a08 <etext+0x1c4>
ffffffffc0200316:	00005517          	auipc	a0,0x5
ffffffffc020031a:	68a50513          	addi	a0,a0,1674 # ffffffffc02059a0 <etext+0x15c>
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
ffffffffc0200354:	6c850513          	addi	a0,a0,1736 # ffffffffc0205a18 <etext+0x1d4>
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
ffffffffc0200376:	6ce50513          	addi	a0,a0,1742 # ffffffffc0205a40 <etext+0x1fc>
ffffffffc020037a:	e1fff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    if (tf != NULL) {
ffffffffc020037e:	000b8563          	beqz	s7,ffffffffc0200388 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200382:	855e                	mv	a0,s7
ffffffffc0200384:	01b000ef          	jal	ra,ffffffffc0200b9e <print_trapframe>
ffffffffc0200388:	00005c17          	auipc	s8,0x5
ffffffffc020038c:	728c0c13          	addi	s8,s8,1832 # ffffffffc0205ab0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200390:	00005917          	auipc	s2,0x5
ffffffffc0200394:	6d890913          	addi	s2,s2,1752 # ffffffffc0205a68 <etext+0x224>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200398:	00005497          	auipc	s1,0x5
ffffffffc020039c:	6d848493          	addi	s1,s1,1752 # ffffffffc0205a70 <etext+0x22c>
        if (argc == MAXARGS - 1) {
ffffffffc02003a0:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003a2:	00005b17          	auipc	s6,0x5
ffffffffc02003a6:	6d6b0b13          	addi	s6,s6,1750 # ffffffffc0205a78 <etext+0x234>
        argv[argc ++] = buf;
ffffffffc02003aa:	00005a17          	auipc	s4,0x5
ffffffffc02003ae:	5eea0a13          	addi	s4,s4,1518 # ffffffffc0205998 <etext+0x154>
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
ffffffffc02003d0:	6e4d0d13          	addi	s10,s10,1764 # ffffffffc0205ab0 <commands>
        argv[argc ++] = buf;
ffffffffc02003d4:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003d6:	4401                	li	s0,0
ffffffffc02003d8:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003da:	3e6050ef          	jal	ra,ffffffffc02057c0 <strcmp>
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
ffffffffc02003ee:	3d2050ef          	jal	ra,ffffffffc02057c0 <strcmp>
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
ffffffffc020042c:	3d8050ef          	jal	ra,ffffffffc0205804 <strchr>
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
ffffffffc020046a:	39a050ef          	jal	ra,ffffffffc0205804 <strchr>
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
ffffffffc0200488:	61450513          	addi	a0,a0,1556 # ffffffffc0205a98 <etext+0x254>
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
ffffffffc0200492:	000c7317          	auipc	t1,0xc7
ffffffffc0200496:	86e30313          	addi	t1,t1,-1938 # ffffffffc02c6d00 <is_panic>
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
ffffffffc02004c4:	63850513          	addi	a0,a0,1592 # ffffffffc0205af8 <commands+0x48>
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
ffffffffc02004da:	75250513          	addi	a0,a0,1874 # ffffffffc0206c28 <default_pmm_manager+0x578>
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
ffffffffc020050e:	60e50513          	addi	a0,a0,1550 # ffffffffc0205b18 <commands+0x68>
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
ffffffffc020052e:	6fe50513          	addi	a0,a0,1790 # ffffffffc0206c28 <default_pmm_manager+0x578>
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
ffffffffc0200560:	5dc50513          	addi	a0,a0,1500 # ffffffffc0205b38 <commands+0x88>
    ticks = 0;
ffffffffc0200564:	000c6797          	auipc	a5,0xc6
ffffffffc0200568:	7a07b223          	sd	zero,1956(a5) # ffffffffc02c6d08 <ticks>
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
ffffffffc02005fe:	55e50513          	addi	a0,a0,1374 # ffffffffc0205b58 <commands+0xa8>
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
ffffffffc020062c:	54050513          	addi	a0,a0,1344 # ffffffffc0205b68 <commands+0xb8>
ffffffffc0200630:	b69ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200634:	0000c417          	auipc	s0,0xc
ffffffffc0200638:	9d440413          	addi	s0,s0,-1580 # ffffffffc020c008 <boot_dtb>
ffffffffc020063c:	600c                	ld	a1,0(s0)
ffffffffc020063e:	00005517          	auipc	a0,0x5
ffffffffc0200642:	53a50513          	addi	a0,a0,1338 # ffffffffc0205b78 <commands+0xc8>
ffffffffc0200646:	b53ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc020064a:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc020064e:	00005517          	auipc	a0,0x5
ffffffffc0200652:	54250513          	addi	a0,a0,1346 # ffffffffc0205b90 <commands+0xe0>
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
ffffffffc0200696:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfe19165>
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
ffffffffc020070c:	4d890913          	addi	s2,s2,1240 # ffffffffc0205be0 <commands+0x130>
ffffffffc0200710:	49bd                	li	s3,15
        switch (token) {
ffffffffc0200712:	4d91                	li	s11,4
ffffffffc0200714:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200716:	00005497          	auipc	s1,0x5
ffffffffc020071a:	4c248493          	addi	s1,s1,1218 # ffffffffc0205bd8 <commands+0x128>
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
ffffffffc020076e:	4ee50513          	addi	a0,a0,1262 # ffffffffc0205c58 <commands+0x1a8>
ffffffffc0200772:	a27ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc0200776:	00005517          	auipc	a0,0x5
ffffffffc020077a:	51a50513          	addi	a0,a0,1306 # ffffffffc0205c90 <commands+0x1e0>
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
ffffffffc02007ba:	3fa50513          	addi	a0,a0,1018 # ffffffffc0205bb0 <commands+0x100>
}
ffffffffc02007be:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02007c0:	bae1                	j	ffffffffc0200198 <cprintf>
                int name_len = strlen(name);
ffffffffc02007c2:	8556                	mv	a0,s5
ffffffffc02007c4:	7b5040ef          	jal	ra,ffffffffc0205778 <strlen>
ffffffffc02007c8:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02007ca:	4619                	li	a2,6
ffffffffc02007cc:	85a6                	mv	a1,s1
ffffffffc02007ce:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02007d0:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02007d2:	00c050ef          	jal	ra,ffffffffc02057de <strncmp>
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
ffffffffc0200868:	759040ef          	jal	ra,ffffffffc02057c0 <strcmp>
ffffffffc020086c:	66a2                	ld	a3,8(sp)
ffffffffc020086e:	f94d                	bnez	a0,ffffffffc0200820 <dtb_init+0x228>
ffffffffc0200870:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200820 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200874:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc0200878:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc020087c:	00005517          	auipc	a0,0x5
ffffffffc0200880:	36c50513          	addi	a0,a0,876 # ffffffffc0205be8 <commands+0x138>
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
ffffffffc020094e:	2be50513          	addi	a0,a0,702 # ffffffffc0205c08 <commands+0x158>
ffffffffc0200952:	847ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc0200956:	014b5613          	srli	a2,s6,0x14
ffffffffc020095a:	85da                	mv	a1,s6
ffffffffc020095c:	00005517          	auipc	a0,0x5
ffffffffc0200960:	2c450513          	addi	a0,a0,708 # ffffffffc0205c20 <commands+0x170>
ffffffffc0200964:	835ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200968:	008b05b3          	add	a1,s6,s0
ffffffffc020096c:	15fd                	addi	a1,a1,-1
ffffffffc020096e:	00005517          	auipc	a0,0x5
ffffffffc0200972:	2d250513          	addi	a0,a0,722 # ffffffffc0205c40 <commands+0x190>
ffffffffc0200976:	823ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("DTB init completed\n");
ffffffffc020097a:	00005517          	auipc	a0,0x5
ffffffffc020097e:	31650513          	addi	a0,a0,790 # ffffffffc0205c90 <commands+0x1e0>
        memory_base = mem_base;
ffffffffc0200982:	000c6797          	auipc	a5,0xc6
ffffffffc0200986:	3887b723          	sd	s0,910(a5) # ffffffffc02c6d10 <memory_base>
        memory_size = mem_size;
ffffffffc020098a:	000c6797          	auipc	a5,0xc6
ffffffffc020098e:	3967b723          	sd	s6,910(a5) # ffffffffc02c6d18 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc0200992:	b3f5                	j	ffffffffc020077e <dtb_init+0x186>

ffffffffc0200994 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc0200994:	000c6517          	auipc	a0,0xc6
ffffffffc0200998:	37c53503          	ld	a0,892(a0) # ffffffffc02c6d10 <memory_base>
ffffffffc020099c:	8082                	ret

ffffffffc020099e <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc020099e:	000c6517          	auipc	a0,0xc6
ffffffffc02009a2:	37a53503          	ld	a0,890(a0) # ffffffffc02c6d18 <memory_size>
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
ffffffffc02009be:	47e78793          	addi	a5,a5,1150 # ffffffffc0200e38 <__alltraps>
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
ffffffffc02009dc:	2d050513          	addi	a0,a0,720 # ffffffffc0205ca8 <commands+0x1f8>
{
ffffffffc02009e0:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009e2:	fb6ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02009e6:	640c                	ld	a1,8(s0)
ffffffffc02009e8:	00005517          	auipc	a0,0x5
ffffffffc02009ec:	2d850513          	addi	a0,a0,728 # ffffffffc0205cc0 <commands+0x210>
ffffffffc02009f0:	fa8ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02009f4:	680c                	ld	a1,16(s0)
ffffffffc02009f6:	00005517          	auipc	a0,0x5
ffffffffc02009fa:	2e250513          	addi	a0,a0,738 # ffffffffc0205cd8 <commands+0x228>
ffffffffc02009fe:	f9aff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200a02:	6c0c                	ld	a1,24(s0)
ffffffffc0200a04:	00005517          	auipc	a0,0x5
ffffffffc0200a08:	2ec50513          	addi	a0,a0,748 # ffffffffc0205cf0 <commands+0x240>
ffffffffc0200a0c:	f8cff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200a10:	700c                	ld	a1,32(s0)
ffffffffc0200a12:	00005517          	auipc	a0,0x5
ffffffffc0200a16:	2f650513          	addi	a0,a0,758 # ffffffffc0205d08 <commands+0x258>
ffffffffc0200a1a:	f7eff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200a1e:	740c                	ld	a1,40(s0)
ffffffffc0200a20:	00005517          	auipc	a0,0x5
ffffffffc0200a24:	30050513          	addi	a0,a0,768 # ffffffffc0205d20 <commands+0x270>
ffffffffc0200a28:	f70ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc0200a2c:	780c                	ld	a1,48(s0)
ffffffffc0200a2e:	00005517          	auipc	a0,0x5
ffffffffc0200a32:	30a50513          	addi	a0,a0,778 # ffffffffc0205d38 <commands+0x288>
ffffffffc0200a36:	f62ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200a3a:	7c0c                	ld	a1,56(s0)
ffffffffc0200a3c:	00005517          	auipc	a0,0x5
ffffffffc0200a40:	31450513          	addi	a0,a0,788 # ffffffffc0205d50 <commands+0x2a0>
ffffffffc0200a44:	f54ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200a48:	602c                	ld	a1,64(s0)
ffffffffc0200a4a:	00005517          	auipc	a0,0x5
ffffffffc0200a4e:	31e50513          	addi	a0,a0,798 # ffffffffc0205d68 <commands+0x2b8>
ffffffffc0200a52:	f46ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200a56:	642c                	ld	a1,72(s0)
ffffffffc0200a58:	00005517          	auipc	a0,0x5
ffffffffc0200a5c:	32850513          	addi	a0,a0,808 # ffffffffc0205d80 <commands+0x2d0>
ffffffffc0200a60:	f38ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200a64:	682c                	ld	a1,80(s0)
ffffffffc0200a66:	00005517          	auipc	a0,0x5
ffffffffc0200a6a:	33250513          	addi	a0,a0,818 # ffffffffc0205d98 <commands+0x2e8>
ffffffffc0200a6e:	f2aff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200a72:	6c2c                	ld	a1,88(s0)
ffffffffc0200a74:	00005517          	auipc	a0,0x5
ffffffffc0200a78:	33c50513          	addi	a0,a0,828 # ffffffffc0205db0 <commands+0x300>
ffffffffc0200a7c:	f1cff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200a80:	702c                	ld	a1,96(s0)
ffffffffc0200a82:	00005517          	auipc	a0,0x5
ffffffffc0200a86:	34650513          	addi	a0,a0,838 # ffffffffc0205dc8 <commands+0x318>
ffffffffc0200a8a:	f0eff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200a8e:	742c                	ld	a1,104(s0)
ffffffffc0200a90:	00005517          	auipc	a0,0x5
ffffffffc0200a94:	35050513          	addi	a0,a0,848 # ffffffffc0205de0 <commands+0x330>
ffffffffc0200a98:	f00ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200a9c:	782c                	ld	a1,112(s0)
ffffffffc0200a9e:	00005517          	auipc	a0,0x5
ffffffffc0200aa2:	35a50513          	addi	a0,a0,858 # ffffffffc0205df8 <commands+0x348>
ffffffffc0200aa6:	ef2ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200aaa:	7c2c                	ld	a1,120(s0)
ffffffffc0200aac:	00005517          	auipc	a0,0x5
ffffffffc0200ab0:	36450513          	addi	a0,a0,868 # ffffffffc0205e10 <commands+0x360>
ffffffffc0200ab4:	ee4ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200ab8:	604c                	ld	a1,128(s0)
ffffffffc0200aba:	00005517          	auipc	a0,0x5
ffffffffc0200abe:	36e50513          	addi	a0,a0,878 # ffffffffc0205e28 <commands+0x378>
ffffffffc0200ac2:	ed6ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200ac6:	644c                	ld	a1,136(s0)
ffffffffc0200ac8:	00005517          	auipc	a0,0x5
ffffffffc0200acc:	37850513          	addi	a0,a0,888 # ffffffffc0205e40 <commands+0x390>
ffffffffc0200ad0:	ec8ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200ad4:	684c                	ld	a1,144(s0)
ffffffffc0200ad6:	00005517          	auipc	a0,0x5
ffffffffc0200ada:	38250513          	addi	a0,a0,898 # ffffffffc0205e58 <commands+0x3a8>
ffffffffc0200ade:	ebaff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200ae2:	6c4c                	ld	a1,152(s0)
ffffffffc0200ae4:	00005517          	auipc	a0,0x5
ffffffffc0200ae8:	38c50513          	addi	a0,a0,908 # ffffffffc0205e70 <commands+0x3c0>
ffffffffc0200aec:	eacff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200af0:	704c                	ld	a1,160(s0)
ffffffffc0200af2:	00005517          	auipc	a0,0x5
ffffffffc0200af6:	39650513          	addi	a0,a0,918 # ffffffffc0205e88 <commands+0x3d8>
ffffffffc0200afa:	e9eff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200afe:	744c                	ld	a1,168(s0)
ffffffffc0200b00:	00005517          	auipc	a0,0x5
ffffffffc0200b04:	3a050513          	addi	a0,a0,928 # ffffffffc0205ea0 <commands+0x3f0>
ffffffffc0200b08:	e90ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200b0c:	784c                	ld	a1,176(s0)
ffffffffc0200b0e:	00005517          	auipc	a0,0x5
ffffffffc0200b12:	3aa50513          	addi	a0,a0,938 # ffffffffc0205eb8 <commands+0x408>
ffffffffc0200b16:	e82ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200b1a:	7c4c                	ld	a1,184(s0)
ffffffffc0200b1c:	00005517          	auipc	a0,0x5
ffffffffc0200b20:	3b450513          	addi	a0,a0,948 # ffffffffc0205ed0 <commands+0x420>
ffffffffc0200b24:	e74ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200b28:	606c                	ld	a1,192(s0)
ffffffffc0200b2a:	00005517          	auipc	a0,0x5
ffffffffc0200b2e:	3be50513          	addi	a0,a0,958 # ffffffffc0205ee8 <commands+0x438>
ffffffffc0200b32:	e66ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200b36:	646c                	ld	a1,200(s0)
ffffffffc0200b38:	00005517          	auipc	a0,0x5
ffffffffc0200b3c:	3c850513          	addi	a0,a0,968 # ffffffffc0205f00 <commands+0x450>
ffffffffc0200b40:	e58ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200b44:	686c                	ld	a1,208(s0)
ffffffffc0200b46:	00005517          	auipc	a0,0x5
ffffffffc0200b4a:	3d250513          	addi	a0,a0,978 # ffffffffc0205f18 <commands+0x468>
ffffffffc0200b4e:	e4aff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200b52:	6c6c                	ld	a1,216(s0)
ffffffffc0200b54:	00005517          	auipc	a0,0x5
ffffffffc0200b58:	3dc50513          	addi	a0,a0,988 # ffffffffc0205f30 <commands+0x480>
ffffffffc0200b5c:	e3cff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200b60:	706c                	ld	a1,224(s0)
ffffffffc0200b62:	00005517          	auipc	a0,0x5
ffffffffc0200b66:	3e650513          	addi	a0,a0,998 # ffffffffc0205f48 <commands+0x498>
ffffffffc0200b6a:	e2eff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200b6e:	746c                	ld	a1,232(s0)
ffffffffc0200b70:	00005517          	auipc	a0,0x5
ffffffffc0200b74:	3f050513          	addi	a0,a0,1008 # ffffffffc0205f60 <commands+0x4b0>
ffffffffc0200b78:	e20ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200b7c:	786c                	ld	a1,240(s0)
ffffffffc0200b7e:	00005517          	auipc	a0,0x5
ffffffffc0200b82:	3fa50513          	addi	a0,a0,1018 # ffffffffc0205f78 <commands+0x4c8>
ffffffffc0200b86:	e12ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b8a:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200b8c:	6402                	ld	s0,0(sp)
ffffffffc0200b8e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b90:	00005517          	auipc	a0,0x5
ffffffffc0200b94:	40050513          	addi	a0,a0,1024 # ffffffffc0205f90 <commands+0x4e0>
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
ffffffffc0200baa:	40250513          	addi	a0,a0,1026 # ffffffffc0205fa8 <commands+0x4f8>
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
ffffffffc0200bc2:	40250513          	addi	a0,a0,1026 # ffffffffc0205fc0 <commands+0x510>
ffffffffc0200bc6:	dd2ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200bca:	10843583          	ld	a1,264(s0)
ffffffffc0200bce:	00005517          	auipc	a0,0x5
ffffffffc0200bd2:	40a50513          	addi	a0,a0,1034 # ffffffffc0205fd8 <commands+0x528>
ffffffffc0200bd6:	dc2ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200bda:	11043583          	ld	a1,272(s0)
ffffffffc0200bde:	00005517          	auipc	a0,0x5
ffffffffc0200be2:	41250513          	addi	a0,a0,1042 # ffffffffc0205ff0 <commands+0x540>
ffffffffc0200be6:	db2ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bea:	11843583          	ld	a1,280(s0)
}
ffffffffc0200bee:	6402                	ld	s0,0(sp)
ffffffffc0200bf0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bf2:	00005517          	auipc	a0,0x5
ffffffffc0200bf6:	40e50513          	addi	a0,a0,1038 # ffffffffc0206000 <commands+0x550>
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
ffffffffc0200c0a:	08f76263          	bltu	a4,a5,ffffffffc0200c8e <interrupt_handler+0x8e>
ffffffffc0200c0e:	00005717          	auipc	a4,0x5
ffffffffc0200c12:	4fa70713          	addi	a4,a4,1274 # ffffffffc0206108 <commands+0x658>
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
ffffffffc0200c24:	45850513          	addi	a0,a0,1112 # ffffffffc0206078 <commands+0x5c8>
ffffffffc0200c28:	d70ff06f          	j	ffffffffc0200198 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200c2c:	00005517          	auipc	a0,0x5
ffffffffc0200c30:	42c50513          	addi	a0,a0,1068 # ffffffffc0206058 <commands+0x5a8>
ffffffffc0200c34:	d64ff06f          	j	ffffffffc0200198 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200c38:	00005517          	auipc	a0,0x5
ffffffffc0200c3c:	3e050513          	addi	a0,a0,992 # ffffffffc0206018 <commands+0x568>
ffffffffc0200c40:	d58ff06f          	j	ffffffffc0200198 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200c44:	00005517          	auipc	a0,0x5
ffffffffc0200c48:	3f450513          	addi	a0,a0,1012 # ffffffffc0206038 <commands+0x588>
ffffffffc0200c4c:	d4cff06f          	j	ffffffffc0200198 <cprintf>
{
ffffffffc0200c50:	1141                	addi	sp,sp,-16
ffffffffc0200c52:	e406                	sd	ra,8(sp)
         *(2)计数器（ticks）加一
         *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
         * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
         */
         
        clock_set_next_event();//发生这次时钟中断的时候，我们要设置下一次时钟中断
ffffffffc0200c54:	91bff0ef          	jal	ra,ffffffffc020056e <clock_set_next_event>
        if (++ticks % TICK_NUM == 0) {
ffffffffc0200c58:	000c6697          	auipc	a3,0xc6
ffffffffc0200c5c:	0b068693          	addi	a3,a3,176 # ffffffffc02c6d08 <ticks>
ffffffffc0200c60:	629c                	ld	a5,0(a3)
ffffffffc0200c62:	06400713          	li	a4,100
ffffffffc0200c66:	0785                	addi	a5,a5,1
ffffffffc0200c68:	02e7f733          	remu	a4,a5,a4
ffffffffc0200c6c:	e29c                	sd	a5,0(a3)
ffffffffc0200c6e:	c705                	beqz	a4,ffffffffc0200c96 <interrupt_handler+0x96>
            }
        }

        // lab6: 2310137  (update LAB3 steps)
        //  在时钟中断时调用调度器的 sched_class_proc_tick 函数
        if (current != NULL) {
ffffffffc0200c70:	000c6517          	auipc	a0,0xc6
ffffffffc0200c74:	0e853503          	ld	a0,232(a0) # ffffffffc02c6d58 <current>
ffffffffc0200c78:	cd01                	beqz	a0,ffffffffc0200c90 <interrupt_handler+0x90>
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200c7a:	60a2                	ld	ra,8(sp)
ffffffffc0200c7c:	0141                	addi	sp,sp,16
            sched_class_proc_tick(current);
ffffffffc0200c7e:	40a0406f          	j	ffffffffc0205088 <sched_class_proc_tick>
        cprintf("Supervisor external interrupt\n");
ffffffffc0200c82:	00005517          	auipc	a0,0x5
ffffffffc0200c86:	46650513          	addi	a0,a0,1126 # ffffffffc02060e8 <commands+0x638>
ffffffffc0200c8a:	d0eff06f          	j	ffffffffc0200198 <cprintf>
        print_trapframe(tf);
ffffffffc0200c8e:	bf01                	j	ffffffffc0200b9e <print_trapframe>
}
ffffffffc0200c90:	60a2                	ld	ra,8(sp)
ffffffffc0200c92:	0141                	addi	sp,sp,16
ffffffffc0200c94:	8082                	ret
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200c96:	06400593          	li	a1,100
ffffffffc0200c9a:	00005517          	auipc	a0,0x5
ffffffffc0200c9e:	3fe50513          	addi	a0,a0,1022 # ffffffffc0206098 <commands+0x5e8>
ffffffffc0200ca2:	cf6ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    cprintf("End of Test.\n");
ffffffffc0200ca6:	00005517          	auipc	a0,0x5
ffffffffc0200caa:	40250513          	addi	a0,a0,1026 # ffffffffc02060a8 <commands+0x5f8>
ffffffffc0200cae:	ceaff0ef          	jal	ra,ffffffffc0200198 <cprintf>
    panic("EOT: kernel seems ok.");
ffffffffc0200cb2:	00005617          	auipc	a2,0x5
ffffffffc0200cb6:	40660613          	addi	a2,a2,1030 # ffffffffc02060b8 <commands+0x608>
ffffffffc0200cba:	45f5                	li	a1,29
ffffffffc0200cbc:	00005517          	auipc	a0,0x5
ffffffffc0200cc0:	41450513          	addi	a0,a0,1044 # ffffffffc02060d0 <commands+0x620>
ffffffffc0200cc4:	fceff0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0200cc8 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf, uintptr_t kstacktop);
void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
ffffffffc0200cc8:	11853783          	ld	a5,280(a0)
{
ffffffffc0200ccc:	1141                	addi	sp,sp,-16
ffffffffc0200cce:	e022                	sd	s0,0(sp)
ffffffffc0200cd0:	e406                	sd	ra,8(sp)
ffffffffc0200cd2:	473d                	li	a4,15
ffffffffc0200cd4:	842a                	mv	s0,a0
ffffffffc0200cd6:	0af76b63          	bltu	a4,a5,ffffffffc0200d8c <exception_handler+0xc4>
ffffffffc0200cda:	00005717          	auipc	a4,0x5
ffffffffc0200cde:	5d670713          	addi	a4,a4,1494 # ffffffffc02062b0 <commands+0x800>
ffffffffc0200ce2:	078a                	slli	a5,a5,0x2
ffffffffc0200ce4:	97ba                	add	a5,a5,a4
ffffffffc0200ce6:	439c                	lw	a5,0(a5)
ffffffffc0200ce8:	97ba                	add	a5,a5,a4
ffffffffc0200cea:	8782                	jr	a5
        // cprintf("Environment call from U-mode\n");
        tf->epc += 4;
        syscall();
        break;
    case CAUSE_SUPERVISOR_ECALL:
        cprintf("Environment call from S-mode\n");
ffffffffc0200cec:	00005517          	auipc	a0,0x5
ffffffffc0200cf0:	51c50513          	addi	a0,a0,1308 # ffffffffc0206208 <commands+0x758>
ffffffffc0200cf4:	ca4ff0ef          	jal	ra,ffffffffc0200198 <cprintf>
        tf->epc += 4;
ffffffffc0200cf8:	10843783          	ld	a5,264(s0)
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200cfc:	60a2                	ld	ra,8(sp)
        tf->epc += 4;
ffffffffc0200cfe:	0791                	addi	a5,a5,4
ffffffffc0200d00:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200d04:	6402                	ld	s0,0(sp)
ffffffffc0200d06:	0141                	addi	sp,sp,16
        syscall();
ffffffffc0200d08:	5ea0406f          	j	ffffffffc02052f2 <syscall>
        cprintf("Environment call from H-mode\n");
ffffffffc0200d0c:	00005517          	auipc	a0,0x5
ffffffffc0200d10:	51c50513          	addi	a0,a0,1308 # ffffffffc0206228 <commands+0x778>
}
ffffffffc0200d14:	6402                	ld	s0,0(sp)
ffffffffc0200d16:	60a2                	ld	ra,8(sp)
ffffffffc0200d18:	0141                	addi	sp,sp,16
        cprintf("Instruction access fault\n");
ffffffffc0200d1a:	c7eff06f          	j	ffffffffc0200198 <cprintf>
        cprintf("Environment call from M-mode\n");
ffffffffc0200d1e:	00005517          	auipc	a0,0x5
ffffffffc0200d22:	52a50513          	addi	a0,a0,1322 # ffffffffc0206248 <commands+0x798>
ffffffffc0200d26:	b7fd                	j	ffffffffc0200d14 <exception_handler+0x4c>
        cprintf("Instruction page fault\n");
ffffffffc0200d28:	00005517          	auipc	a0,0x5
ffffffffc0200d2c:	54050513          	addi	a0,a0,1344 # ffffffffc0206268 <commands+0x7b8>
ffffffffc0200d30:	b7d5                	j	ffffffffc0200d14 <exception_handler+0x4c>
        cprintf("Load page fault\n");
ffffffffc0200d32:	00005517          	auipc	a0,0x5
ffffffffc0200d36:	54e50513          	addi	a0,a0,1358 # ffffffffc0206280 <commands+0x7d0>
ffffffffc0200d3a:	bfe9                	j	ffffffffc0200d14 <exception_handler+0x4c>
        cprintf("Store/AMO page fault\n");
ffffffffc0200d3c:	00005517          	auipc	a0,0x5
ffffffffc0200d40:	55c50513          	addi	a0,a0,1372 # ffffffffc0206298 <commands+0x7e8>
ffffffffc0200d44:	bfc1                	j	ffffffffc0200d14 <exception_handler+0x4c>
        cprintf("Instruction address misaligned\n");
ffffffffc0200d46:	00005517          	auipc	a0,0x5
ffffffffc0200d4a:	3f250513          	addi	a0,a0,1010 # ffffffffc0206138 <commands+0x688>
ffffffffc0200d4e:	b7d9                	j	ffffffffc0200d14 <exception_handler+0x4c>
        cprintf("Instruction access fault\n");
ffffffffc0200d50:	00005517          	auipc	a0,0x5
ffffffffc0200d54:	40850513          	addi	a0,a0,1032 # ffffffffc0206158 <commands+0x6a8>
ffffffffc0200d58:	bf75                	j	ffffffffc0200d14 <exception_handler+0x4c>
        cprintf("Illegal instruction\n");
ffffffffc0200d5a:	00005517          	auipc	a0,0x5
ffffffffc0200d5e:	41e50513          	addi	a0,a0,1054 # ffffffffc0206178 <commands+0x6c8>
ffffffffc0200d62:	bf4d                	j	ffffffffc0200d14 <exception_handler+0x4c>
        cprintf("Breakpoint\n");
ffffffffc0200d64:	00005517          	auipc	a0,0x5
ffffffffc0200d68:	42c50513          	addi	a0,a0,1068 # ffffffffc0206190 <commands+0x6e0>
ffffffffc0200d6c:	b765                	j	ffffffffc0200d14 <exception_handler+0x4c>
        cprintf("Load address misaligned\n");
ffffffffc0200d6e:	00005517          	auipc	a0,0x5
ffffffffc0200d72:	43250513          	addi	a0,a0,1074 # ffffffffc02061a0 <commands+0x6f0>
ffffffffc0200d76:	bf79                	j	ffffffffc0200d14 <exception_handler+0x4c>
        cprintf("Load access fault\n");
ffffffffc0200d78:	00005517          	auipc	a0,0x5
ffffffffc0200d7c:	44850513          	addi	a0,a0,1096 # ffffffffc02061c0 <commands+0x710>
ffffffffc0200d80:	bf51                	j	ffffffffc0200d14 <exception_handler+0x4c>
        cprintf("Store/AMO access fault\n");
ffffffffc0200d82:	00005517          	auipc	a0,0x5
ffffffffc0200d86:	46e50513          	addi	a0,a0,1134 # ffffffffc02061f0 <commands+0x740>
ffffffffc0200d8a:	b769                	j	ffffffffc0200d14 <exception_handler+0x4c>
        print_trapframe(tf);
ffffffffc0200d8c:	8522                	mv	a0,s0
}
ffffffffc0200d8e:	6402                	ld	s0,0(sp)
ffffffffc0200d90:	60a2                	ld	ra,8(sp)
ffffffffc0200d92:	0141                	addi	sp,sp,16
        print_trapframe(tf);
ffffffffc0200d94:	b529                	j	ffffffffc0200b9e <print_trapframe>
        panic("AMO address misaligned\n");
ffffffffc0200d96:	00005617          	auipc	a2,0x5
ffffffffc0200d9a:	44260613          	addi	a2,a2,1090 # ffffffffc02061d8 <commands+0x728>
ffffffffc0200d9e:	0cc00593          	li	a1,204
ffffffffc0200da2:	00005517          	auipc	a0,0x5
ffffffffc0200da6:	32e50513          	addi	a0,a0,814 # ffffffffc02060d0 <commands+0x620>
ffffffffc0200daa:	ee8ff0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0200dae <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf)
{
ffffffffc0200dae:	1101                	addi	sp,sp,-32
ffffffffc0200db0:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
    //    cputs("some trap");
    if (current == NULL)
ffffffffc0200db2:	000c6417          	auipc	s0,0xc6
ffffffffc0200db6:	fa640413          	addi	s0,s0,-90 # ffffffffc02c6d58 <current>
ffffffffc0200dba:	6018                	ld	a4,0(s0)
{
ffffffffc0200dbc:	ec06                	sd	ra,24(sp)
ffffffffc0200dbe:	e426                	sd	s1,8(sp)
ffffffffc0200dc0:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0)
ffffffffc0200dc2:	11853683          	ld	a3,280(a0)
    if (current == NULL)
ffffffffc0200dc6:	cf1d                	beqz	a4,ffffffffc0200e04 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200dc8:	10053483          	ld	s1,256(a0)
    {
        trap_dispatch(tf);
    }
    else
    {
        struct trapframe *otf = current->tf;
ffffffffc0200dcc:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200dd0:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200dd2:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0)
ffffffffc0200dd6:	0206c463          	bltz	a3,ffffffffc0200dfe <trap+0x50>
        exception_handler(tf);
ffffffffc0200dda:	eefff0ef          	jal	ra,ffffffffc0200cc8 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200dde:	601c                	ld	a5,0(s0)
ffffffffc0200de0:	0b27b023          	sd	s2,160(a5) # 400a0 <_binary_obj___user_matrix_out_size+0x33978>
        if (!in_kernel)
ffffffffc0200de4:	e499                	bnez	s1,ffffffffc0200df2 <trap+0x44>
        {
            if (current->flags & PF_EXITING)
ffffffffc0200de6:	0b07a703          	lw	a4,176(a5)
ffffffffc0200dea:	8b05                	andi	a4,a4,1
ffffffffc0200dec:	e329                	bnez	a4,ffffffffc0200e2e <trap+0x80>
            {
                do_exit(-E_KILLED);
            }
            if (current->need_resched)
ffffffffc0200dee:	6f9c                	ld	a5,24(a5)
ffffffffc0200df0:	eb85                	bnez	a5,ffffffffc0200e20 <trap+0x72>
            {
                schedule();
            }
        }
    }
}
ffffffffc0200df2:	60e2                	ld	ra,24(sp)
ffffffffc0200df4:	6442                	ld	s0,16(sp)
ffffffffc0200df6:	64a2                	ld	s1,8(sp)
ffffffffc0200df8:	6902                	ld	s2,0(sp)
ffffffffc0200dfa:	6105                	addi	sp,sp,32
ffffffffc0200dfc:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200dfe:	e03ff0ef          	jal	ra,ffffffffc0200c00 <interrupt_handler>
ffffffffc0200e02:	bff1                	j	ffffffffc0200dde <trap+0x30>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200e04:	0006c863          	bltz	a3,ffffffffc0200e14 <trap+0x66>
}
ffffffffc0200e08:	6442                	ld	s0,16(sp)
ffffffffc0200e0a:	60e2                	ld	ra,24(sp)
ffffffffc0200e0c:	64a2                	ld	s1,8(sp)
ffffffffc0200e0e:	6902                	ld	s2,0(sp)
ffffffffc0200e10:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200e12:	bd5d                	j	ffffffffc0200cc8 <exception_handler>
}
ffffffffc0200e14:	6442                	ld	s0,16(sp)
ffffffffc0200e16:	60e2                	ld	ra,24(sp)
ffffffffc0200e18:	64a2                	ld	s1,8(sp)
ffffffffc0200e1a:	6902                	ld	s2,0(sp)
ffffffffc0200e1c:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200e1e:	b3cd                	j	ffffffffc0200c00 <interrupt_handler>
}
ffffffffc0200e20:	6442                	ld	s0,16(sp)
ffffffffc0200e22:	60e2                	ld	ra,24(sp)
ffffffffc0200e24:	64a2                	ld	s1,8(sp)
ffffffffc0200e26:	6902                	ld	s2,0(sp)
ffffffffc0200e28:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200e2a:	38a0406f          	j	ffffffffc02051b4 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200e2e:	555d                	li	a0,-9
ffffffffc0200e30:	47e030ef          	jal	ra,ffffffffc02042ae <do_exit>
            if (current->need_resched)
ffffffffc0200e34:	601c                	ld	a5,0(s0)
ffffffffc0200e36:	bf65                	j	ffffffffc0200dee <trap+0x40>

ffffffffc0200e38 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200e38:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200e3c:	00011463          	bnez	sp,ffffffffc0200e44 <__alltraps+0xc>
ffffffffc0200e40:	14002173          	csrr	sp,sscratch
ffffffffc0200e44:	712d                	addi	sp,sp,-288
ffffffffc0200e46:	e002                	sd	zero,0(sp)
ffffffffc0200e48:	e406                	sd	ra,8(sp)
ffffffffc0200e4a:	ec0e                	sd	gp,24(sp)
ffffffffc0200e4c:	f012                	sd	tp,32(sp)
ffffffffc0200e4e:	f416                	sd	t0,40(sp)
ffffffffc0200e50:	f81a                	sd	t1,48(sp)
ffffffffc0200e52:	fc1e                	sd	t2,56(sp)
ffffffffc0200e54:	e0a2                	sd	s0,64(sp)
ffffffffc0200e56:	e4a6                	sd	s1,72(sp)
ffffffffc0200e58:	e8aa                	sd	a0,80(sp)
ffffffffc0200e5a:	ecae                	sd	a1,88(sp)
ffffffffc0200e5c:	f0b2                	sd	a2,96(sp)
ffffffffc0200e5e:	f4b6                	sd	a3,104(sp)
ffffffffc0200e60:	f8ba                	sd	a4,112(sp)
ffffffffc0200e62:	fcbe                	sd	a5,120(sp)
ffffffffc0200e64:	e142                	sd	a6,128(sp)
ffffffffc0200e66:	e546                	sd	a7,136(sp)
ffffffffc0200e68:	e94a                	sd	s2,144(sp)
ffffffffc0200e6a:	ed4e                	sd	s3,152(sp)
ffffffffc0200e6c:	f152                	sd	s4,160(sp)
ffffffffc0200e6e:	f556                	sd	s5,168(sp)
ffffffffc0200e70:	f95a                	sd	s6,176(sp)
ffffffffc0200e72:	fd5e                	sd	s7,184(sp)
ffffffffc0200e74:	e1e2                	sd	s8,192(sp)
ffffffffc0200e76:	e5e6                	sd	s9,200(sp)
ffffffffc0200e78:	e9ea                	sd	s10,208(sp)
ffffffffc0200e7a:	edee                	sd	s11,216(sp)
ffffffffc0200e7c:	f1f2                	sd	t3,224(sp)
ffffffffc0200e7e:	f5f6                	sd	t4,232(sp)
ffffffffc0200e80:	f9fa                	sd	t5,240(sp)
ffffffffc0200e82:	fdfe                	sd	t6,248(sp)
ffffffffc0200e84:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200e88:	100024f3          	csrr	s1,sstatus
ffffffffc0200e8c:	14102973          	csrr	s2,sepc
ffffffffc0200e90:	143029f3          	csrr	s3,stval
ffffffffc0200e94:	14202a73          	csrr	s4,scause
ffffffffc0200e98:	e822                	sd	s0,16(sp)
ffffffffc0200e9a:	e226                	sd	s1,256(sp)
ffffffffc0200e9c:	e64a                	sd	s2,264(sp)
ffffffffc0200e9e:	ea4e                	sd	s3,272(sp)
ffffffffc0200ea0:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200ea2:	850a                	mv	a0,sp
    jal trap
ffffffffc0200ea4:	f0bff0ef          	jal	ra,ffffffffc0200dae <trap>

ffffffffc0200ea8 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200ea8:	6492                	ld	s1,256(sp)
ffffffffc0200eaa:	6932                	ld	s2,264(sp)
ffffffffc0200eac:	1004f413          	andi	s0,s1,256
ffffffffc0200eb0:	e401                	bnez	s0,ffffffffc0200eb8 <__trapret+0x10>
ffffffffc0200eb2:	1200                	addi	s0,sp,288
ffffffffc0200eb4:	14041073          	csrw	sscratch,s0
ffffffffc0200eb8:	10049073          	csrw	sstatus,s1
ffffffffc0200ebc:	14191073          	csrw	sepc,s2
ffffffffc0200ec0:	60a2                	ld	ra,8(sp)
ffffffffc0200ec2:	61e2                	ld	gp,24(sp)
ffffffffc0200ec4:	7202                	ld	tp,32(sp)
ffffffffc0200ec6:	72a2                	ld	t0,40(sp)
ffffffffc0200ec8:	7342                	ld	t1,48(sp)
ffffffffc0200eca:	73e2                	ld	t2,56(sp)
ffffffffc0200ecc:	6406                	ld	s0,64(sp)
ffffffffc0200ece:	64a6                	ld	s1,72(sp)
ffffffffc0200ed0:	6546                	ld	a0,80(sp)
ffffffffc0200ed2:	65e6                	ld	a1,88(sp)
ffffffffc0200ed4:	7606                	ld	a2,96(sp)
ffffffffc0200ed6:	76a6                	ld	a3,104(sp)
ffffffffc0200ed8:	7746                	ld	a4,112(sp)
ffffffffc0200eda:	77e6                	ld	a5,120(sp)
ffffffffc0200edc:	680a                	ld	a6,128(sp)
ffffffffc0200ede:	68aa                	ld	a7,136(sp)
ffffffffc0200ee0:	694a                	ld	s2,144(sp)
ffffffffc0200ee2:	69ea                	ld	s3,152(sp)
ffffffffc0200ee4:	7a0a                	ld	s4,160(sp)
ffffffffc0200ee6:	7aaa                	ld	s5,168(sp)
ffffffffc0200ee8:	7b4a                	ld	s6,176(sp)
ffffffffc0200eea:	7bea                	ld	s7,184(sp)
ffffffffc0200eec:	6c0e                	ld	s8,192(sp)
ffffffffc0200eee:	6cae                	ld	s9,200(sp)
ffffffffc0200ef0:	6d4e                	ld	s10,208(sp)
ffffffffc0200ef2:	6dee                	ld	s11,216(sp)
ffffffffc0200ef4:	7e0e                	ld	t3,224(sp)
ffffffffc0200ef6:	7eae                	ld	t4,232(sp)
ffffffffc0200ef8:	7f4e                	ld	t5,240(sp)
ffffffffc0200efa:	7fee                	ld	t6,248(sp)
ffffffffc0200efc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200efe:	10200073          	sret

ffffffffc0200f02 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200f02:	812a                	mv	sp,a0
ffffffffc0200f04:	b755                	j	ffffffffc0200ea8 <__trapret>

ffffffffc0200f06 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200f06:	000c2797          	auipc	a5,0xc2
ffffffffc0200f0a:	da278793          	addi	a5,a5,-606 # ffffffffc02c2ca8 <free_area>
ffffffffc0200f0e:	e79c                	sd	a5,8(a5)
ffffffffc0200f10:	e39c                	sd	a5,0(a5)

static void
default_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200f12:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200f16:	8082                	ret

ffffffffc0200f18 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc0200f18:	000c2517          	auipc	a0,0xc2
ffffffffc0200f1c:	da056503          	lwu	a0,-608(a0) # ffffffffc02c2cb8 <free_area+0x10>
ffffffffc0200f20:	8082                	ret

ffffffffc0200f22 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
ffffffffc0200f22:	715d                	addi	sp,sp,-80
ffffffffc0200f24:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200f26:	000c2417          	auipc	s0,0xc2
ffffffffc0200f2a:	d8240413          	addi	s0,s0,-638 # ffffffffc02c2ca8 <free_area>
ffffffffc0200f2e:	641c                	ld	a5,8(s0)
ffffffffc0200f30:	e486                	sd	ra,72(sp)
ffffffffc0200f32:	fc26                	sd	s1,56(sp)
ffffffffc0200f34:	f84a                	sd	s2,48(sp)
ffffffffc0200f36:	f44e                	sd	s3,40(sp)
ffffffffc0200f38:	f052                	sd	s4,32(sp)
ffffffffc0200f3a:	ec56                	sd	s5,24(sp)
ffffffffc0200f3c:	e85a                	sd	s6,16(sp)
ffffffffc0200f3e:	e45e                	sd	s7,8(sp)
ffffffffc0200f40:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0200f42:	2a878d63          	beq	a5,s0,ffffffffc02011fc <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0200f46:	4481                	li	s1,0
ffffffffc0200f48:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200f4a:	ff07b703          	ld	a4,-16(a5)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200f4e:	8b09                	andi	a4,a4,2
ffffffffc0200f50:	2a070a63          	beqz	a4,ffffffffc0201204 <default_check+0x2e2>
        count++, total += p->property;
ffffffffc0200f54:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200f58:	679c                	ld	a5,8(a5)
ffffffffc0200f5a:	2905                	addiw	s2,s2,1
ffffffffc0200f5c:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0200f5e:	fe8796e3          	bne	a5,s0,ffffffffc0200f4a <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200f62:	89a6                	mv	s3,s1
ffffffffc0200f64:	6df000ef          	jal	ra,ffffffffc0201e42 <nr_free_pages>
ffffffffc0200f68:	6f351e63          	bne	a0,s3,ffffffffc0201664 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f6c:	4505                	li	a0,1
ffffffffc0200f6e:	657000ef          	jal	ra,ffffffffc0201dc4 <alloc_pages>
ffffffffc0200f72:	8aaa                	mv	s5,a0
ffffffffc0200f74:	42050863          	beqz	a0,ffffffffc02013a4 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f78:	4505                	li	a0,1
ffffffffc0200f7a:	64b000ef          	jal	ra,ffffffffc0201dc4 <alloc_pages>
ffffffffc0200f7e:	89aa                	mv	s3,a0
ffffffffc0200f80:	70050263          	beqz	a0,ffffffffc0201684 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f84:	4505                	li	a0,1
ffffffffc0200f86:	63f000ef          	jal	ra,ffffffffc0201dc4 <alloc_pages>
ffffffffc0200f8a:	8a2a                	mv	s4,a0
ffffffffc0200f8c:	48050c63          	beqz	a0,ffffffffc0201424 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200f90:	293a8a63          	beq	s5,s3,ffffffffc0201224 <default_check+0x302>
ffffffffc0200f94:	28aa8863          	beq	s5,a0,ffffffffc0201224 <default_check+0x302>
ffffffffc0200f98:	28a98663          	beq	s3,a0,ffffffffc0201224 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200f9c:	000aa783          	lw	a5,0(s5)
ffffffffc0200fa0:	2a079263          	bnez	a5,ffffffffc0201244 <default_check+0x322>
ffffffffc0200fa4:	0009a783          	lw	a5,0(s3)
ffffffffc0200fa8:	28079e63          	bnez	a5,ffffffffc0201244 <default_check+0x322>
ffffffffc0200fac:	411c                	lw	a5,0(a0)
ffffffffc0200fae:	28079b63          	bnez	a5,ffffffffc0201244 <default_check+0x322>
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page)
{
    return page - pages + nbase;
ffffffffc0200fb2:	000c6797          	auipc	a5,0xc6
ffffffffc0200fb6:	d8e7b783          	ld	a5,-626(a5) # ffffffffc02c6d40 <pages>
ffffffffc0200fba:	40fa8733          	sub	a4,s5,a5
ffffffffc0200fbe:	00007617          	auipc	a2,0x7
ffffffffc0200fc2:	1aa63603          	ld	a2,426(a2) # ffffffffc0208168 <nbase>
ffffffffc0200fc6:	8719                	srai	a4,a4,0x6
ffffffffc0200fc8:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200fca:	000c6697          	auipc	a3,0xc6
ffffffffc0200fce:	d6e6b683          	ld	a3,-658(a3) # ffffffffc02c6d38 <npage>
ffffffffc0200fd2:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page)
{
    return page2ppn(page) << PGSHIFT;
ffffffffc0200fd4:	0732                	slli	a4,a4,0xc
ffffffffc0200fd6:	28d77763          	bgeu	a4,a3,ffffffffc0201264 <default_check+0x342>
    return page - pages + nbase;
ffffffffc0200fda:	40f98733          	sub	a4,s3,a5
ffffffffc0200fde:	8719                	srai	a4,a4,0x6
ffffffffc0200fe0:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200fe2:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200fe4:	4cd77063          	bgeu	a4,a3,ffffffffc02014a4 <default_check+0x582>
    return page - pages + nbase;
ffffffffc0200fe8:	40f507b3          	sub	a5,a0,a5
ffffffffc0200fec:	8799                	srai	a5,a5,0x6
ffffffffc0200fee:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ff0:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ff2:	30d7f963          	bgeu	a5,a3,ffffffffc0201304 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0200ff6:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200ff8:	00043c03          	ld	s8,0(s0)
ffffffffc0200ffc:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0201000:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0201004:	e400                	sd	s0,8(s0)
ffffffffc0201006:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0201008:	000c2797          	auipc	a5,0xc2
ffffffffc020100c:	ca07a823          	sw	zero,-848(a5) # ffffffffc02c2cb8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201010:	5b5000ef          	jal	ra,ffffffffc0201dc4 <alloc_pages>
ffffffffc0201014:	2c051863          	bnez	a0,ffffffffc02012e4 <default_check+0x3c2>
    free_page(p0);
ffffffffc0201018:	4585                	li	a1,1
ffffffffc020101a:	8556                	mv	a0,s5
ffffffffc020101c:	5e7000ef          	jal	ra,ffffffffc0201e02 <free_pages>
    free_page(p1);
ffffffffc0201020:	4585                	li	a1,1
ffffffffc0201022:	854e                	mv	a0,s3
ffffffffc0201024:	5df000ef          	jal	ra,ffffffffc0201e02 <free_pages>
    free_page(p2);
ffffffffc0201028:	4585                	li	a1,1
ffffffffc020102a:	8552                	mv	a0,s4
ffffffffc020102c:	5d7000ef          	jal	ra,ffffffffc0201e02 <free_pages>
    assert(nr_free == 3);
ffffffffc0201030:	4818                	lw	a4,16(s0)
ffffffffc0201032:	478d                	li	a5,3
ffffffffc0201034:	28f71863          	bne	a4,a5,ffffffffc02012c4 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201038:	4505                	li	a0,1
ffffffffc020103a:	58b000ef          	jal	ra,ffffffffc0201dc4 <alloc_pages>
ffffffffc020103e:	89aa                	mv	s3,a0
ffffffffc0201040:	26050263          	beqz	a0,ffffffffc02012a4 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201044:	4505                	li	a0,1
ffffffffc0201046:	57f000ef          	jal	ra,ffffffffc0201dc4 <alloc_pages>
ffffffffc020104a:	8aaa                	mv	s5,a0
ffffffffc020104c:	3a050c63          	beqz	a0,ffffffffc0201404 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201050:	4505                	li	a0,1
ffffffffc0201052:	573000ef          	jal	ra,ffffffffc0201dc4 <alloc_pages>
ffffffffc0201056:	8a2a                	mv	s4,a0
ffffffffc0201058:	38050663          	beqz	a0,ffffffffc02013e4 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc020105c:	4505                	li	a0,1
ffffffffc020105e:	567000ef          	jal	ra,ffffffffc0201dc4 <alloc_pages>
ffffffffc0201062:	36051163          	bnez	a0,ffffffffc02013c4 <default_check+0x4a2>
    free_page(p0);
ffffffffc0201066:	4585                	li	a1,1
ffffffffc0201068:	854e                	mv	a0,s3
ffffffffc020106a:	599000ef          	jal	ra,ffffffffc0201e02 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc020106e:	641c                	ld	a5,8(s0)
ffffffffc0201070:	20878a63          	beq	a5,s0,ffffffffc0201284 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0201074:	4505                	li	a0,1
ffffffffc0201076:	54f000ef          	jal	ra,ffffffffc0201dc4 <alloc_pages>
ffffffffc020107a:	30a99563          	bne	s3,a0,ffffffffc0201384 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc020107e:	4505                	li	a0,1
ffffffffc0201080:	545000ef          	jal	ra,ffffffffc0201dc4 <alloc_pages>
ffffffffc0201084:	2e051063          	bnez	a0,ffffffffc0201364 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0201088:	481c                	lw	a5,16(s0)
ffffffffc020108a:	2a079d63          	bnez	a5,ffffffffc0201344 <default_check+0x422>
    free_page(p);
ffffffffc020108e:	854e                	mv	a0,s3
ffffffffc0201090:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201092:	01843023          	sd	s8,0(s0)
ffffffffc0201096:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc020109a:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc020109e:	565000ef          	jal	ra,ffffffffc0201e02 <free_pages>
    free_page(p1);
ffffffffc02010a2:	4585                	li	a1,1
ffffffffc02010a4:	8556                	mv	a0,s5
ffffffffc02010a6:	55d000ef          	jal	ra,ffffffffc0201e02 <free_pages>
    free_page(p2);
ffffffffc02010aa:	4585                	li	a1,1
ffffffffc02010ac:	8552                	mv	a0,s4
ffffffffc02010ae:	555000ef          	jal	ra,ffffffffc0201e02 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02010b2:	4515                	li	a0,5
ffffffffc02010b4:	511000ef          	jal	ra,ffffffffc0201dc4 <alloc_pages>
ffffffffc02010b8:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02010ba:	26050563          	beqz	a0,ffffffffc0201324 <default_check+0x402>
ffffffffc02010be:	651c                	ld	a5,8(a0)
ffffffffc02010c0:	8385                	srli	a5,a5,0x1
ffffffffc02010c2:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc02010c4:	54079063          	bnez	a5,ffffffffc0201604 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02010c8:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02010ca:	00043b03          	ld	s6,0(s0)
ffffffffc02010ce:	00843a83          	ld	s5,8(s0)
ffffffffc02010d2:	e000                	sd	s0,0(s0)
ffffffffc02010d4:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc02010d6:	4ef000ef          	jal	ra,ffffffffc0201dc4 <alloc_pages>
ffffffffc02010da:	50051563          	bnez	a0,ffffffffc02015e4 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02010de:	08098a13          	addi	s4,s3,128
ffffffffc02010e2:	8552                	mv	a0,s4
ffffffffc02010e4:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02010e6:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc02010ea:	000c2797          	auipc	a5,0xc2
ffffffffc02010ee:	bc07a723          	sw	zero,-1074(a5) # ffffffffc02c2cb8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02010f2:	511000ef          	jal	ra,ffffffffc0201e02 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02010f6:	4511                	li	a0,4
ffffffffc02010f8:	4cd000ef          	jal	ra,ffffffffc0201dc4 <alloc_pages>
ffffffffc02010fc:	4c051463          	bnez	a0,ffffffffc02015c4 <default_check+0x6a2>
ffffffffc0201100:	0889b783          	ld	a5,136(s3)
ffffffffc0201104:	8385                	srli	a5,a5,0x1
ffffffffc0201106:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201108:	48078e63          	beqz	a5,ffffffffc02015a4 <default_check+0x682>
ffffffffc020110c:	0909a703          	lw	a4,144(s3)
ffffffffc0201110:	478d                	li	a5,3
ffffffffc0201112:	48f71963          	bne	a4,a5,ffffffffc02015a4 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201116:	450d                	li	a0,3
ffffffffc0201118:	4ad000ef          	jal	ra,ffffffffc0201dc4 <alloc_pages>
ffffffffc020111c:	8c2a                	mv	s8,a0
ffffffffc020111e:	46050363          	beqz	a0,ffffffffc0201584 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0201122:	4505                	li	a0,1
ffffffffc0201124:	4a1000ef          	jal	ra,ffffffffc0201dc4 <alloc_pages>
ffffffffc0201128:	42051e63          	bnez	a0,ffffffffc0201564 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc020112c:	418a1c63          	bne	s4,s8,ffffffffc0201544 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201130:	4585                	li	a1,1
ffffffffc0201132:	854e                	mv	a0,s3
ffffffffc0201134:	4cf000ef          	jal	ra,ffffffffc0201e02 <free_pages>
    free_pages(p1, 3);
ffffffffc0201138:	458d                	li	a1,3
ffffffffc020113a:	8552                	mv	a0,s4
ffffffffc020113c:	4c7000ef          	jal	ra,ffffffffc0201e02 <free_pages>
ffffffffc0201140:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201144:	04098c13          	addi	s8,s3,64
ffffffffc0201148:	8385                	srli	a5,a5,0x1
ffffffffc020114a:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020114c:	3c078c63          	beqz	a5,ffffffffc0201524 <default_check+0x602>
ffffffffc0201150:	0109a703          	lw	a4,16(s3)
ffffffffc0201154:	4785                	li	a5,1
ffffffffc0201156:	3cf71763          	bne	a4,a5,ffffffffc0201524 <default_check+0x602>
ffffffffc020115a:	008a3783          	ld	a5,8(s4)
ffffffffc020115e:	8385                	srli	a5,a5,0x1
ffffffffc0201160:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201162:	3a078163          	beqz	a5,ffffffffc0201504 <default_check+0x5e2>
ffffffffc0201166:	010a2703          	lw	a4,16(s4)
ffffffffc020116a:	478d                	li	a5,3
ffffffffc020116c:	38f71c63          	bne	a4,a5,ffffffffc0201504 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201170:	4505                	li	a0,1
ffffffffc0201172:	453000ef          	jal	ra,ffffffffc0201dc4 <alloc_pages>
ffffffffc0201176:	36a99763          	bne	s3,a0,ffffffffc02014e4 <default_check+0x5c2>
    free_page(p0);
ffffffffc020117a:	4585                	li	a1,1
ffffffffc020117c:	487000ef          	jal	ra,ffffffffc0201e02 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201180:	4509                	li	a0,2
ffffffffc0201182:	443000ef          	jal	ra,ffffffffc0201dc4 <alloc_pages>
ffffffffc0201186:	32aa1f63          	bne	s4,a0,ffffffffc02014c4 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc020118a:	4589                	li	a1,2
ffffffffc020118c:	477000ef          	jal	ra,ffffffffc0201e02 <free_pages>
    free_page(p2);
ffffffffc0201190:	4585                	li	a1,1
ffffffffc0201192:	8562                	mv	a0,s8
ffffffffc0201194:	46f000ef          	jal	ra,ffffffffc0201e02 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201198:	4515                	li	a0,5
ffffffffc020119a:	42b000ef          	jal	ra,ffffffffc0201dc4 <alloc_pages>
ffffffffc020119e:	89aa                	mv	s3,a0
ffffffffc02011a0:	48050263          	beqz	a0,ffffffffc0201624 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc02011a4:	4505                	li	a0,1
ffffffffc02011a6:	41f000ef          	jal	ra,ffffffffc0201dc4 <alloc_pages>
ffffffffc02011aa:	2c051d63          	bnez	a0,ffffffffc0201484 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc02011ae:	481c                	lw	a5,16(s0)
ffffffffc02011b0:	2a079a63          	bnez	a5,ffffffffc0201464 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02011b4:	4595                	li	a1,5
ffffffffc02011b6:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02011b8:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02011bc:	01643023          	sd	s6,0(s0)
ffffffffc02011c0:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc02011c4:	43f000ef          	jal	ra,ffffffffc0201e02 <free_pages>
    return listelm->next;
ffffffffc02011c8:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc02011ca:	00878963          	beq	a5,s0,ffffffffc02011dc <default_check+0x2ba>
    {
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc02011ce:	ff87a703          	lw	a4,-8(a5)
ffffffffc02011d2:	679c                	ld	a5,8(a5)
ffffffffc02011d4:	397d                	addiw	s2,s2,-1
ffffffffc02011d6:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc02011d8:	fe879be3          	bne	a5,s0,ffffffffc02011ce <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc02011dc:	26091463          	bnez	s2,ffffffffc0201444 <default_check+0x522>
    assert(total == 0);
ffffffffc02011e0:	46049263          	bnez	s1,ffffffffc0201644 <default_check+0x722>
}
ffffffffc02011e4:	60a6                	ld	ra,72(sp)
ffffffffc02011e6:	6406                	ld	s0,64(sp)
ffffffffc02011e8:	74e2                	ld	s1,56(sp)
ffffffffc02011ea:	7942                	ld	s2,48(sp)
ffffffffc02011ec:	79a2                	ld	s3,40(sp)
ffffffffc02011ee:	7a02                	ld	s4,32(sp)
ffffffffc02011f0:	6ae2                	ld	s5,24(sp)
ffffffffc02011f2:	6b42                	ld	s6,16(sp)
ffffffffc02011f4:	6ba2                	ld	s7,8(sp)
ffffffffc02011f6:	6c02                	ld	s8,0(sp)
ffffffffc02011f8:	6161                	addi	sp,sp,80
ffffffffc02011fa:	8082                	ret
    while ((le = list_next(le)) != &free_list)
ffffffffc02011fc:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02011fe:	4481                	li	s1,0
ffffffffc0201200:	4901                	li	s2,0
ffffffffc0201202:	b38d                	j	ffffffffc0200f64 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0201204:	00005697          	auipc	a3,0x5
ffffffffc0201208:	0ec68693          	addi	a3,a3,236 # ffffffffc02062f0 <commands+0x840>
ffffffffc020120c:	00005617          	auipc	a2,0x5
ffffffffc0201210:	0f460613          	addi	a2,a2,244 # ffffffffc0206300 <commands+0x850>
ffffffffc0201214:	11000593          	li	a1,272
ffffffffc0201218:	00005517          	auipc	a0,0x5
ffffffffc020121c:	10050513          	addi	a0,a0,256 # ffffffffc0206318 <commands+0x868>
ffffffffc0201220:	a72ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201224:	00005697          	auipc	a3,0x5
ffffffffc0201228:	18c68693          	addi	a3,a3,396 # ffffffffc02063b0 <commands+0x900>
ffffffffc020122c:	00005617          	auipc	a2,0x5
ffffffffc0201230:	0d460613          	addi	a2,a2,212 # ffffffffc0206300 <commands+0x850>
ffffffffc0201234:	0db00593          	li	a1,219
ffffffffc0201238:	00005517          	auipc	a0,0x5
ffffffffc020123c:	0e050513          	addi	a0,a0,224 # ffffffffc0206318 <commands+0x868>
ffffffffc0201240:	a52ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201244:	00005697          	auipc	a3,0x5
ffffffffc0201248:	19468693          	addi	a3,a3,404 # ffffffffc02063d8 <commands+0x928>
ffffffffc020124c:	00005617          	auipc	a2,0x5
ffffffffc0201250:	0b460613          	addi	a2,a2,180 # ffffffffc0206300 <commands+0x850>
ffffffffc0201254:	0dc00593          	li	a1,220
ffffffffc0201258:	00005517          	auipc	a0,0x5
ffffffffc020125c:	0c050513          	addi	a0,a0,192 # ffffffffc0206318 <commands+0x868>
ffffffffc0201260:	a32ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201264:	00005697          	auipc	a3,0x5
ffffffffc0201268:	1b468693          	addi	a3,a3,436 # ffffffffc0206418 <commands+0x968>
ffffffffc020126c:	00005617          	auipc	a2,0x5
ffffffffc0201270:	09460613          	addi	a2,a2,148 # ffffffffc0206300 <commands+0x850>
ffffffffc0201274:	0de00593          	li	a1,222
ffffffffc0201278:	00005517          	auipc	a0,0x5
ffffffffc020127c:	0a050513          	addi	a0,a0,160 # ffffffffc0206318 <commands+0x868>
ffffffffc0201280:	a12ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201284:	00005697          	auipc	a3,0x5
ffffffffc0201288:	21c68693          	addi	a3,a3,540 # ffffffffc02064a0 <commands+0x9f0>
ffffffffc020128c:	00005617          	auipc	a2,0x5
ffffffffc0201290:	07460613          	addi	a2,a2,116 # ffffffffc0206300 <commands+0x850>
ffffffffc0201294:	0f700593          	li	a1,247
ffffffffc0201298:	00005517          	auipc	a0,0x5
ffffffffc020129c:	08050513          	addi	a0,a0,128 # ffffffffc0206318 <commands+0x868>
ffffffffc02012a0:	9f2ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02012a4:	00005697          	auipc	a3,0x5
ffffffffc02012a8:	0ac68693          	addi	a3,a3,172 # ffffffffc0206350 <commands+0x8a0>
ffffffffc02012ac:	00005617          	auipc	a2,0x5
ffffffffc02012b0:	05460613          	addi	a2,a2,84 # ffffffffc0206300 <commands+0x850>
ffffffffc02012b4:	0f000593          	li	a1,240
ffffffffc02012b8:	00005517          	auipc	a0,0x5
ffffffffc02012bc:	06050513          	addi	a0,a0,96 # ffffffffc0206318 <commands+0x868>
ffffffffc02012c0:	9d2ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(nr_free == 3);
ffffffffc02012c4:	00005697          	auipc	a3,0x5
ffffffffc02012c8:	1cc68693          	addi	a3,a3,460 # ffffffffc0206490 <commands+0x9e0>
ffffffffc02012cc:	00005617          	auipc	a2,0x5
ffffffffc02012d0:	03460613          	addi	a2,a2,52 # ffffffffc0206300 <commands+0x850>
ffffffffc02012d4:	0ee00593          	li	a1,238
ffffffffc02012d8:	00005517          	auipc	a0,0x5
ffffffffc02012dc:	04050513          	addi	a0,a0,64 # ffffffffc0206318 <commands+0x868>
ffffffffc02012e0:	9b2ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012e4:	00005697          	auipc	a3,0x5
ffffffffc02012e8:	19468693          	addi	a3,a3,404 # ffffffffc0206478 <commands+0x9c8>
ffffffffc02012ec:	00005617          	auipc	a2,0x5
ffffffffc02012f0:	01460613          	addi	a2,a2,20 # ffffffffc0206300 <commands+0x850>
ffffffffc02012f4:	0e900593          	li	a1,233
ffffffffc02012f8:	00005517          	auipc	a0,0x5
ffffffffc02012fc:	02050513          	addi	a0,a0,32 # ffffffffc0206318 <commands+0x868>
ffffffffc0201300:	992ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201304:	00005697          	auipc	a3,0x5
ffffffffc0201308:	15468693          	addi	a3,a3,340 # ffffffffc0206458 <commands+0x9a8>
ffffffffc020130c:	00005617          	auipc	a2,0x5
ffffffffc0201310:	ff460613          	addi	a2,a2,-12 # ffffffffc0206300 <commands+0x850>
ffffffffc0201314:	0e000593          	li	a1,224
ffffffffc0201318:	00005517          	auipc	a0,0x5
ffffffffc020131c:	00050513          	mv	a0,a0
ffffffffc0201320:	972ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(p0 != NULL);
ffffffffc0201324:	00005697          	auipc	a3,0x5
ffffffffc0201328:	1c468693          	addi	a3,a3,452 # ffffffffc02064e8 <commands+0xa38>
ffffffffc020132c:	00005617          	auipc	a2,0x5
ffffffffc0201330:	fd460613          	addi	a2,a2,-44 # ffffffffc0206300 <commands+0x850>
ffffffffc0201334:	11800593          	li	a1,280
ffffffffc0201338:	00005517          	auipc	a0,0x5
ffffffffc020133c:	fe050513          	addi	a0,a0,-32 # ffffffffc0206318 <commands+0x868>
ffffffffc0201340:	952ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(nr_free == 0);
ffffffffc0201344:	00005697          	auipc	a3,0x5
ffffffffc0201348:	19468693          	addi	a3,a3,404 # ffffffffc02064d8 <commands+0xa28>
ffffffffc020134c:	00005617          	auipc	a2,0x5
ffffffffc0201350:	fb460613          	addi	a2,a2,-76 # ffffffffc0206300 <commands+0x850>
ffffffffc0201354:	0fd00593          	li	a1,253
ffffffffc0201358:	00005517          	auipc	a0,0x5
ffffffffc020135c:	fc050513          	addi	a0,a0,-64 # ffffffffc0206318 <commands+0x868>
ffffffffc0201360:	932ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201364:	00005697          	auipc	a3,0x5
ffffffffc0201368:	11468693          	addi	a3,a3,276 # ffffffffc0206478 <commands+0x9c8>
ffffffffc020136c:	00005617          	auipc	a2,0x5
ffffffffc0201370:	f9460613          	addi	a2,a2,-108 # ffffffffc0206300 <commands+0x850>
ffffffffc0201374:	0fb00593          	li	a1,251
ffffffffc0201378:	00005517          	auipc	a0,0x5
ffffffffc020137c:	fa050513          	addi	a0,a0,-96 # ffffffffc0206318 <commands+0x868>
ffffffffc0201380:	912ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201384:	00005697          	auipc	a3,0x5
ffffffffc0201388:	13468693          	addi	a3,a3,308 # ffffffffc02064b8 <commands+0xa08>
ffffffffc020138c:	00005617          	auipc	a2,0x5
ffffffffc0201390:	f7460613          	addi	a2,a2,-140 # ffffffffc0206300 <commands+0x850>
ffffffffc0201394:	0fa00593          	li	a1,250
ffffffffc0201398:	00005517          	auipc	a0,0x5
ffffffffc020139c:	f8050513          	addi	a0,a0,-128 # ffffffffc0206318 <commands+0x868>
ffffffffc02013a0:	8f2ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02013a4:	00005697          	auipc	a3,0x5
ffffffffc02013a8:	fac68693          	addi	a3,a3,-84 # ffffffffc0206350 <commands+0x8a0>
ffffffffc02013ac:	00005617          	auipc	a2,0x5
ffffffffc02013b0:	f5460613          	addi	a2,a2,-172 # ffffffffc0206300 <commands+0x850>
ffffffffc02013b4:	0d700593          	li	a1,215
ffffffffc02013b8:	00005517          	auipc	a0,0x5
ffffffffc02013bc:	f6050513          	addi	a0,a0,-160 # ffffffffc0206318 <commands+0x868>
ffffffffc02013c0:	8d2ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013c4:	00005697          	auipc	a3,0x5
ffffffffc02013c8:	0b468693          	addi	a3,a3,180 # ffffffffc0206478 <commands+0x9c8>
ffffffffc02013cc:	00005617          	auipc	a2,0x5
ffffffffc02013d0:	f3460613          	addi	a2,a2,-204 # ffffffffc0206300 <commands+0x850>
ffffffffc02013d4:	0f400593          	li	a1,244
ffffffffc02013d8:	00005517          	auipc	a0,0x5
ffffffffc02013dc:	f4050513          	addi	a0,a0,-192 # ffffffffc0206318 <commands+0x868>
ffffffffc02013e0:	8b2ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02013e4:	00005697          	auipc	a3,0x5
ffffffffc02013e8:	fac68693          	addi	a3,a3,-84 # ffffffffc0206390 <commands+0x8e0>
ffffffffc02013ec:	00005617          	auipc	a2,0x5
ffffffffc02013f0:	f1460613          	addi	a2,a2,-236 # ffffffffc0206300 <commands+0x850>
ffffffffc02013f4:	0f200593          	li	a1,242
ffffffffc02013f8:	00005517          	auipc	a0,0x5
ffffffffc02013fc:	f2050513          	addi	a0,a0,-224 # ffffffffc0206318 <commands+0x868>
ffffffffc0201400:	892ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201404:	00005697          	auipc	a3,0x5
ffffffffc0201408:	f6c68693          	addi	a3,a3,-148 # ffffffffc0206370 <commands+0x8c0>
ffffffffc020140c:	00005617          	auipc	a2,0x5
ffffffffc0201410:	ef460613          	addi	a2,a2,-268 # ffffffffc0206300 <commands+0x850>
ffffffffc0201414:	0f100593          	li	a1,241
ffffffffc0201418:	00005517          	auipc	a0,0x5
ffffffffc020141c:	f0050513          	addi	a0,a0,-256 # ffffffffc0206318 <commands+0x868>
ffffffffc0201420:	872ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201424:	00005697          	auipc	a3,0x5
ffffffffc0201428:	f6c68693          	addi	a3,a3,-148 # ffffffffc0206390 <commands+0x8e0>
ffffffffc020142c:	00005617          	auipc	a2,0x5
ffffffffc0201430:	ed460613          	addi	a2,a2,-300 # ffffffffc0206300 <commands+0x850>
ffffffffc0201434:	0d900593          	li	a1,217
ffffffffc0201438:	00005517          	auipc	a0,0x5
ffffffffc020143c:	ee050513          	addi	a0,a0,-288 # ffffffffc0206318 <commands+0x868>
ffffffffc0201440:	852ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(count == 0);
ffffffffc0201444:	00005697          	auipc	a3,0x5
ffffffffc0201448:	1f468693          	addi	a3,a3,500 # ffffffffc0206638 <commands+0xb88>
ffffffffc020144c:	00005617          	auipc	a2,0x5
ffffffffc0201450:	eb460613          	addi	a2,a2,-332 # ffffffffc0206300 <commands+0x850>
ffffffffc0201454:	14600593          	li	a1,326
ffffffffc0201458:	00005517          	auipc	a0,0x5
ffffffffc020145c:	ec050513          	addi	a0,a0,-320 # ffffffffc0206318 <commands+0x868>
ffffffffc0201460:	832ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(nr_free == 0);
ffffffffc0201464:	00005697          	auipc	a3,0x5
ffffffffc0201468:	07468693          	addi	a3,a3,116 # ffffffffc02064d8 <commands+0xa28>
ffffffffc020146c:	00005617          	auipc	a2,0x5
ffffffffc0201470:	e9460613          	addi	a2,a2,-364 # ffffffffc0206300 <commands+0x850>
ffffffffc0201474:	13a00593          	li	a1,314
ffffffffc0201478:	00005517          	auipc	a0,0x5
ffffffffc020147c:	ea050513          	addi	a0,a0,-352 # ffffffffc0206318 <commands+0x868>
ffffffffc0201480:	812ff0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201484:	00005697          	auipc	a3,0x5
ffffffffc0201488:	ff468693          	addi	a3,a3,-12 # ffffffffc0206478 <commands+0x9c8>
ffffffffc020148c:	00005617          	auipc	a2,0x5
ffffffffc0201490:	e7460613          	addi	a2,a2,-396 # ffffffffc0206300 <commands+0x850>
ffffffffc0201494:	13800593          	li	a1,312
ffffffffc0201498:	00005517          	auipc	a0,0x5
ffffffffc020149c:	e8050513          	addi	a0,a0,-384 # ffffffffc0206318 <commands+0x868>
ffffffffc02014a0:	ff3fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02014a4:	00005697          	auipc	a3,0x5
ffffffffc02014a8:	f9468693          	addi	a3,a3,-108 # ffffffffc0206438 <commands+0x988>
ffffffffc02014ac:	00005617          	auipc	a2,0x5
ffffffffc02014b0:	e5460613          	addi	a2,a2,-428 # ffffffffc0206300 <commands+0x850>
ffffffffc02014b4:	0df00593          	li	a1,223
ffffffffc02014b8:	00005517          	auipc	a0,0x5
ffffffffc02014bc:	e6050513          	addi	a0,a0,-416 # ffffffffc0206318 <commands+0x868>
ffffffffc02014c0:	fd3fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02014c4:	00005697          	auipc	a3,0x5
ffffffffc02014c8:	13468693          	addi	a3,a3,308 # ffffffffc02065f8 <commands+0xb48>
ffffffffc02014cc:	00005617          	auipc	a2,0x5
ffffffffc02014d0:	e3460613          	addi	a2,a2,-460 # ffffffffc0206300 <commands+0x850>
ffffffffc02014d4:	13200593          	li	a1,306
ffffffffc02014d8:	00005517          	auipc	a0,0x5
ffffffffc02014dc:	e4050513          	addi	a0,a0,-448 # ffffffffc0206318 <commands+0x868>
ffffffffc02014e0:	fb3fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02014e4:	00005697          	auipc	a3,0x5
ffffffffc02014e8:	0f468693          	addi	a3,a3,244 # ffffffffc02065d8 <commands+0xb28>
ffffffffc02014ec:	00005617          	auipc	a2,0x5
ffffffffc02014f0:	e1460613          	addi	a2,a2,-492 # ffffffffc0206300 <commands+0x850>
ffffffffc02014f4:	13000593          	li	a1,304
ffffffffc02014f8:	00005517          	auipc	a0,0x5
ffffffffc02014fc:	e2050513          	addi	a0,a0,-480 # ffffffffc0206318 <commands+0x868>
ffffffffc0201500:	f93fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201504:	00005697          	auipc	a3,0x5
ffffffffc0201508:	0ac68693          	addi	a3,a3,172 # ffffffffc02065b0 <commands+0xb00>
ffffffffc020150c:	00005617          	auipc	a2,0x5
ffffffffc0201510:	df460613          	addi	a2,a2,-524 # ffffffffc0206300 <commands+0x850>
ffffffffc0201514:	12e00593          	li	a1,302
ffffffffc0201518:	00005517          	auipc	a0,0x5
ffffffffc020151c:	e0050513          	addi	a0,a0,-512 # ffffffffc0206318 <commands+0x868>
ffffffffc0201520:	f73fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201524:	00005697          	auipc	a3,0x5
ffffffffc0201528:	06468693          	addi	a3,a3,100 # ffffffffc0206588 <commands+0xad8>
ffffffffc020152c:	00005617          	auipc	a2,0x5
ffffffffc0201530:	dd460613          	addi	a2,a2,-556 # ffffffffc0206300 <commands+0x850>
ffffffffc0201534:	12d00593          	li	a1,301
ffffffffc0201538:	00005517          	auipc	a0,0x5
ffffffffc020153c:	de050513          	addi	a0,a0,-544 # ffffffffc0206318 <commands+0x868>
ffffffffc0201540:	f53fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201544:	00005697          	auipc	a3,0x5
ffffffffc0201548:	03468693          	addi	a3,a3,52 # ffffffffc0206578 <commands+0xac8>
ffffffffc020154c:	00005617          	auipc	a2,0x5
ffffffffc0201550:	db460613          	addi	a2,a2,-588 # ffffffffc0206300 <commands+0x850>
ffffffffc0201554:	12800593          	li	a1,296
ffffffffc0201558:	00005517          	auipc	a0,0x5
ffffffffc020155c:	dc050513          	addi	a0,a0,-576 # ffffffffc0206318 <commands+0x868>
ffffffffc0201560:	f33fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201564:	00005697          	auipc	a3,0x5
ffffffffc0201568:	f1468693          	addi	a3,a3,-236 # ffffffffc0206478 <commands+0x9c8>
ffffffffc020156c:	00005617          	auipc	a2,0x5
ffffffffc0201570:	d9460613          	addi	a2,a2,-620 # ffffffffc0206300 <commands+0x850>
ffffffffc0201574:	12700593          	li	a1,295
ffffffffc0201578:	00005517          	auipc	a0,0x5
ffffffffc020157c:	da050513          	addi	a0,a0,-608 # ffffffffc0206318 <commands+0x868>
ffffffffc0201580:	f13fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201584:	00005697          	auipc	a3,0x5
ffffffffc0201588:	fd468693          	addi	a3,a3,-44 # ffffffffc0206558 <commands+0xaa8>
ffffffffc020158c:	00005617          	auipc	a2,0x5
ffffffffc0201590:	d7460613          	addi	a2,a2,-652 # ffffffffc0206300 <commands+0x850>
ffffffffc0201594:	12600593          	li	a1,294
ffffffffc0201598:	00005517          	auipc	a0,0x5
ffffffffc020159c:	d8050513          	addi	a0,a0,-640 # ffffffffc0206318 <commands+0x868>
ffffffffc02015a0:	ef3fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02015a4:	00005697          	auipc	a3,0x5
ffffffffc02015a8:	f8468693          	addi	a3,a3,-124 # ffffffffc0206528 <commands+0xa78>
ffffffffc02015ac:	00005617          	auipc	a2,0x5
ffffffffc02015b0:	d5460613          	addi	a2,a2,-684 # ffffffffc0206300 <commands+0x850>
ffffffffc02015b4:	12500593          	li	a1,293
ffffffffc02015b8:	00005517          	auipc	a0,0x5
ffffffffc02015bc:	d6050513          	addi	a0,a0,-672 # ffffffffc0206318 <commands+0x868>
ffffffffc02015c0:	ed3fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02015c4:	00005697          	auipc	a3,0x5
ffffffffc02015c8:	f4c68693          	addi	a3,a3,-180 # ffffffffc0206510 <commands+0xa60>
ffffffffc02015cc:	00005617          	auipc	a2,0x5
ffffffffc02015d0:	d3460613          	addi	a2,a2,-716 # ffffffffc0206300 <commands+0x850>
ffffffffc02015d4:	12400593          	li	a1,292
ffffffffc02015d8:	00005517          	auipc	a0,0x5
ffffffffc02015dc:	d4050513          	addi	a0,a0,-704 # ffffffffc0206318 <commands+0x868>
ffffffffc02015e0:	eb3fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02015e4:	00005697          	auipc	a3,0x5
ffffffffc02015e8:	e9468693          	addi	a3,a3,-364 # ffffffffc0206478 <commands+0x9c8>
ffffffffc02015ec:	00005617          	auipc	a2,0x5
ffffffffc02015f0:	d1460613          	addi	a2,a2,-748 # ffffffffc0206300 <commands+0x850>
ffffffffc02015f4:	11e00593          	li	a1,286
ffffffffc02015f8:	00005517          	auipc	a0,0x5
ffffffffc02015fc:	d2050513          	addi	a0,a0,-736 # ffffffffc0206318 <commands+0x868>
ffffffffc0201600:	e93fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201604:	00005697          	auipc	a3,0x5
ffffffffc0201608:	ef468693          	addi	a3,a3,-268 # ffffffffc02064f8 <commands+0xa48>
ffffffffc020160c:	00005617          	auipc	a2,0x5
ffffffffc0201610:	cf460613          	addi	a2,a2,-780 # ffffffffc0206300 <commands+0x850>
ffffffffc0201614:	11900593          	li	a1,281
ffffffffc0201618:	00005517          	auipc	a0,0x5
ffffffffc020161c:	d0050513          	addi	a0,a0,-768 # ffffffffc0206318 <commands+0x868>
ffffffffc0201620:	e73fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201624:	00005697          	auipc	a3,0x5
ffffffffc0201628:	ff468693          	addi	a3,a3,-12 # ffffffffc0206618 <commands+0xb68>
ffffffffc020162c:	00005617          	auipc	a2,0x5
ffffffffc0201630:	cd460613          	addi	a2,a2,-812 # ffffffffc0206300 <commands+0x850>
ffffffffc0201634:	13700593          	li	a1,311
ffffffffc0201638:	00005517          	auipc	a0,0x5
ffffffffc020163c:	ce050513          	addi	a0,a0,-800 # ffffffffc0206318 <commands+0x868>
ffffffffc0201640:	e53fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(total == 0);
ffffffffc0201644:	00005697          	auipc	a3,0x5
ffffffffc0201648:	00468693          	addi	a3,a3,4 # ffffffffc0206648 <commands+0xb98>
ffffffffc020164c:	00005617          	auipc	a2,0x5
ffffffffc0201650:	cb460613          	addi	a2,a2,-844 # ffffffffc0206300 <commands+0x850>
ffffffffc0201654:	14700593          	li	a1,327
ffffffffc0201658:	00005517          	auipc	a0,0x5
ffffffffc020165c:	cc050513          	addi	a0,a0,-832 # ffffffffc0206318 <commands+0x868>
ffffffffc0201660:	e33fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201664:	00005697          	auipc	a3,0x5
ffffffffc0201668:	ccc68693          	addi	a3,a3,-820 # ffffffffc0206330 <commands+0x880>
ffffffffc020166c:	00005617          	auipc	a2,0x5
ffffffffc0201670:	c9460613          	addi	a2,a2,-876 # ffffffffc0206300 <commands+0x850>
ffffffffc0201674:	11300593          	li	a1,275
ffffffffc0201678:	00005517          	auipc	a0,0x5
ffffffffc020167c:	ca050513          	addi	a0,a0,-864 # ffffffffc0206318 <commands+0x868>
ffffffffc0201680:	e13fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201684:	00005697          	auipc	a3,0x5
ffffffffc0201688:	cec68693          	addi	a3,a3,-788 # ffffffffc0206370 <commands+0x8c0>
ffffffffc020168c:	00005617          	auipc	a2,0x5
ffffffffc0201690:	c7460613          	addi	a2,a2,-908 # ffffffffc0206300 <commands+0x850>
ffffffffc0201694:	0d800593          	li	a1,216
ffffffffc0201698:	00005517          	auipc	a0,0x5
ffffffffc020169c:	c8050513          	addi	a0,a0,-896 # ffffffffc0206318 <commands+0x868>
ffffffffc02016a0:	df3fe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02016a4 <default_free_pages>:
{
ffffffffc02016a4:	1141                	addi	sp,sp,-16
ffffffffc02016a6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02016a8:	14058463          	beqz	a1,ffffffffc02017f0 <default_free_pages+0x14c>
    for (; p != base + n; p++)
ffffffffc02016ac:	00659693          	slli	a3,a1,0x6
ffffffffc02016b0:	96aa                	add	a3,a3,a0
ffffffffc02016b2:	87aa                	mv	a5,a0
ffffffffc02016b4:	02d50263          	beq	a0,a3,ffffffffc02016d8 <default_free_pages+0x34>
ffffffffc02016b8:	6798                	ld	a4,8(a5)
ffffffffc02016ba:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02016bc:	10071a63          	bnez	a4,ffffffffc02017d0 <default_free_pages+0x12c>
ffffffffc02016c0:	6798                	ld	a4,8(a5)
ffffffffc02016c2:	8b09                	andi	a4,a4,2
ffffffffc02016c4:	10071663          	bnez	a4,ffffffffc02017d0 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc02016c8:	0007b423          	sd	zero,8(a5)
}

static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
ffffffffc02016cc:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02016d0:	04078793          	addi	a5,a5,64
ffffffffc02016d4:	fed792e3          	bne	a5,a3,ffffffffc02016b8 <default_free_pages+0x14>
    base->property = n;
ffffffffc02016d8:	2581                	sext.w	a1,a1
ffffffffc02016da:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02016dc:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02016e0:	4789                	li	a5,2
ffffffffc02016e2:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02016e6:	000c1697          	auipc	a3,0xc1
ffffffffc02016ea:	5c268693          	addi	a3,a3,1474 # ffffffffc02c2ca8 <free_area>
ffffffffc02016ee:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02016f0:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02016f2:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02016f6:	9db9                	addw	a1,a1,a4
ffffffffc02016f8:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc02016fa:	0ad78463          	beq	a5,a3,ffffffffc02017a2 <default_free_pages+0xfe>
            struct Page *page = le2page(le, page_link);
ffffffffc02016fe:	fe878713          	addi	a4,a5,-24
ffffffffc0201702:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc0201706:	4581                	li	a1,0
            if (base < page)
ffffffffc0201708:	00e56a63          	bltu	a0,a4,ffffffffc020171c <default_free_pages+0x78>
    return listelm->next;
ffffffffc020170c:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc020170e:	04d70c63          	beq	a4,a3,ffffffffc0201766 <default_free_pages+0xc2>
    for (; p != base + n; p++)
ffffffffc0201712:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0201714:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0201718:	fee57ae3          	bgeu	a0,a4,ffffffffc020170c <default_free_pages+0x68>
ffffffffc020171c:	c199                	beqz	a1,ffffffffc0201722 <default_free_pages+0x7e>
ffffffffc020171e:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201722:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201724:	e390                	sd	a2,0(a5)
ffffffffc0201726:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201728:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020172a:	ed18                	sd	a4,24(a0)
    if (le != &free_list)
ffffffffc020172c:	00d70d63          	beq	a4,a3,ffffffffc0201746 <default_free_pages+0xa2>
        if (p + p->property == base)
ffffffffc0201730:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201734:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base)
ffffffffc0201738:	02059813          	slli	a6,a1,0x20
ffffffffc020173c:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201740:	97b2                	add	a5,a5,a2
ffffffffc0201742:	02f50c63          	beq	a0,a5,ffffffffc020177a <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0201746:	711c                	ld	a5,32(a0)
    if (le != &free_list)
ffffffffc0201748:	00d78c63          	beq	a5,a3,ffffffffc0201760 <default_free_pages+0xbc>
        if (base + base->property == p)
ffffffffc020174c:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc020174e:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p)
ffffffffc0201752:	02061593          	slli	a1,a2,0x20
ffffffffc0201756:	01a5d713          	srli	a4,a1,0x1a
ffffffffc020175a:	972a                	add	a4,a4,a0
ffffffffc020175c:	04e68a63          	beq	a3,a4,ffffffffc02017b0 <default_free_pages+0x10c>
}
ffffffffc0201760:	60a2                	ld	ra,8(sp)
ffffffffc0201762:	0141                	addi	sp,sp,16
ffffffffc0201764:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201766:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201768:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020176a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020176c:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc020176e:	02d70763          	beq	a4,a3,ffffffffc020179c <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc0201772:	8832                	mv	a6,a2
ffffffffc0201774:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc0201776:	87ba                	mv	a5,a4
ffffffffc0201778:	bf71                	j	ffffffffc0201714 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc020177a:	491c                	lw	a5,16(a0)
ffffffffc020177c:	9dbd                	addw	a1,a1,a5
ffffffffc020177e:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201782:	57f5                	li	a5,-3
ffffffffc0201784:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201788:	01853803          	ld	a6,24(a0)
ffffffffc020178c:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc020178e:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201790:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc0201794:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0201796:	0105b023          	sd	a6,0(a1)
ffffffffc020179a:	b77d                	j	ffffffffc0201748 <default_free_pages+0xa4>
ffffffffc020179c:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list)
ffffffffc020179e:	873e                	mv	a4,a5
ffffffffc02017a0:	bf41                	j	ffffffffc0201730 <default_free_pages+0x8c>
}
ffffffffc02017a2:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02017a4:	e390                	sd	a2,0(a5)
ffffffffc02017a6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02017a8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02017aa:	ed1c                	sd	a5,24(a0)
ffffffffc02017ac:	0141                	addi	sp,sp,16
ffffffffc02017ae:	8082                	ret
            base->property += p->property;
ffffffffc02017b0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02017b4:	ff078693          	addi	a3,a5,-16
ffffffffc02017b8:	9e39                	addw	a2,a2,a4
ffffffffc02017ba:	c910                	sw	a2,16(a0)
ffffffffc02017bc:	5775                	li	a4,-3
ffffffffc02017be:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02017c2:	6398                	ld	a4,0(a5)
ffffffffc02017c4:	679c                	ld	a5,8(a5)
}
ffffffffc02017c6:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02017c8:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02017ca:	e398                	sd	a4,0(a5)
ffffffffc02017cc:	0141                	addi	sp,sp,16
ffffffffc02017ce:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02017d0:	00005697          	auipc	a3,0x5
ffffffffc02017d4:	e9068693          	addi	a3,a3,-368 # ffffffffc0206660 <commands+0xbb0>
ffffffffc02017d8:	00005617          	auipc	a2,0x5
ffffffffc02017dc:	b2860613          	addi	a2,a2,-1240 # ffffffffc0206300 <commands+0x850>
ffffffffc02017e0:	09400593          	li	a1,148
ffffffffc02017e4:	00005517          	auipc	a0,0x5
ffffffffc02017e8:	b3450513          	addi	a0,a0,-1228 # ffffffffc0206318 <commands+0x868>
ffffffffc02017ec:	ca7fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(n > 0);
ffffffffc02017f0:	00005697          	auipc	a3,0x5
ffffffffc02017f4:	e6868693          	addi	a3,a3,-408 # ffffffffc0206658 <commands+0xba8>
ffffffffc02017f8:	00005617          	auipc	a2,0x5
ffffffffc02017fc:	b0860613          	addi	a2,a2,-1272 # ffffffffc0206300 <commands+0x850>
ffffffffc0201800:	09000593          	li	a1,144
ffffffffc0201804:	00005517          	auipc	a0,0x5
ffffffffc0201808:	b1450513          	addi	a0,a0,-1260 # ffffffffc0206318 <commands+0x868>
ffffffffc020180c:	c87fe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0201810 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201810:	c941                	beqz	a0,ffffffffc02018a0 <default_alloc_pages+0x90>
    if (n > nr_free)
ffffffffc0201812:	000c1597          	auipc	a1,0xc1
ffffffffc0201816:	49658593          	addi	a1,a1,1174 # ffffffffc02c2ca8 <free_area>
ffffffffc020181a:	0105a803          	lw	a6,16(a1)
ffffffffc020181e:	872a                	mv	a4,a0
ffffffffc0201820:	02081793          	slli	a5,a6,0x20
ffffffffc0201824:	9381                	srli	a5,a5,0x20
ffffffffc0201826:	00a7ee63          	bltu	a5,a0,ffffffffc0201842 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc020182a:	87ae                	mv	a5,a1
ffffffffc020182c:	a801                	j	ffffffffc020183c <default_alloc_pages+0x2c>
        if (p->property >= n)
ffffffffc020182e:	ff87a683          	lw	a3,-8(a5)
ffffffffc0201832:	02069613          	slli	a2,a3,0x20
ffffffffc0201836:	9201                	srli	a2,a2,0x20
ffffffffc0201838:	00e67763          	bgeu	a2,a4,ffffffffc0201846 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc020183c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc020183e:	feb798e3          	bne	a5,a1,ffffffffc020182e <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201842:	4501                	li	a0,0
}
ffffffffc0201844:	8082                	ret
    return listelm->prev;
ffffffffc0201846:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020184a:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc020184e:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0201852:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0201856:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc020185a:	01133023          	sd	a7,0(t1)
        if (page->property > n)
ffffffffc020185e:	02c77863          	bgeu	a4,a2,ffffffffc020188e <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc0201862:	071a                	slli	a4,a4,0x6
ffffffffc0201864:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201866:	41c686bb          	subw	a3,a3,t3
ffffffffc020186a:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020186c:	00870613          	addi	a2,a4,8
ffffffffc0201870:	4689                	li	a3,2
ffffffffc0201872:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201876:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020187a:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc020187e:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201882:	e290                	sd	a2,0(a3)
ffffffffc0201884:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201888:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc020188a:	01173c23          	sd	a7,24(a4)
ffffffffc020188e:	41c8083b          	subw	a6,a6,t3
ffffffffc0201892:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201896:	5775                	li	a4,-3
ffffffffc0201898:	17c1                	addi	a5,a5,-16
ffffffffc020189a:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc020189e:	8082                	ret
{
ffffffffc02018a0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02018a2:	00005697          	auipc	a3,0x5
ffffffffc02018a6:	db668693          	addi	a3,a3,-586 # ffffffffc0206658 <commands+0xba8>
ffffffffc02018aa:	00005617          	auipc	a2,0x5
ffffffffc02018ae:	a5660613          	addi	a2,a2,-1450 # ffffffffc0206300 <commands+0x850>
ffffffffc02018b2:	06c00593          	li	a1,108
ffffffffc02018b6:	00005517          	auipc	a0,0x5
ffffffffc02018ba:	a6250513          	addi	a0,a0,-1438 # ffffffffc0206318 <commands+0x868>
{
ffffffffc02018be:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02018c0:	bd3fe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02018c4 <default_init_memmap>:
{
ffffffffc02018c4:	1141                	addi	sp,sp,-16
ffffffffc02018c6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02018c8:	c5f1                	beqz	a1,ffffffffc0201994 <default_init_memmap+0xd0>
    for (; p != base + n; p++)
ffffffffc02018ca:	00659693          	slli	a3,a1,0x6
ffffffffc02018ce:	96aa                	add	a3,a3,a0
ffffffffc02018d0:	87aa                	mv	a5,a0
ffffffffc02018d2:	00d50f63          	beq	a0,a3,ffffffffc02018f0 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02018d6:	6798                	ld	a4,8(a5)
ffffffffc02018d8:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc02018da:	cf49                	beqz	a4,ffffffffc0201974 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc02018dc:	0007a823          	sw	zero,16(a5)
ffffffffc02018e0:	0007b423          	sd	zero,8(a5)
ffffffffc02018e4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02018e8:	04078793          	addi	a5,a5,64
ffffffffc02018ec:	fed795e3          	bne	a5,a3,ffffffffc02018d6 <default_init_memmap+0x12>
    base->property = n;
ffffffffc02018f0:	2581                	sext.w	a1,a1
ffffffffc02018f2:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02018f4:	4789                	li	a5,2
ffffffffc02018f6:	00850713          	addi	a4,a0,8
ffffffffc02018fa:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02018fe:	000c1697          	auipc	a3,0xc1
ffffffffc0201902:	3aa68693          	addi	a3,a3,938 # ffffffffc02c2ca8 <free_area>
ffffffffc0201906:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201908:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020190a:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020190e:	9db9                	addw	a1,a1,a4
ffffffffc0201910:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc0201912:	04d78a63          	beq	a5,a3,ffffffffc0201966 <default_init_memmap+0xa2>
            struct Page *page = le2page(le, page_link);
ffffffffc0201916:	fe878713          	addi	a4,a5,-24
ffffffffc020191a:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc020191e:	4581                	li	a1,0
            if (base < page)
ffffffffc0201920:	00e56a63          	bltu	a0,a4,ffffffffc0201934 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0201924:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc0201926:	02d70263          	beq	a4,a3,ffffffffc020194a <default_init_memmap+0x86>
    for (; p != base + n; p++)
ffffffffc020192a:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc020192c:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0201930:	fee57ae3          	bgeu	a0,a4,ffffffffc0201924 <default_init_memmap+0x60>
ffffffffc0201934:	c199                	beqz	a1,ffffffffc020193a <default_init_memmap+0x76>
ffffffffc0201936:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020193a:	6398                	ld	a4,0(a5)
}
ffffffffc020193c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020193e:	e390                	sd	a2,0(a5)
ffffffffc0201940:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201942:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201944:	ed18                	sd	a4,24(a0)
ffffffffc0201946:	0141                	addi	sp,sp,16
ffffffffc0201948:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020194a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020194c:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020194e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201950:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc0201952:	00d70663          	beq	a4,a3,ffffffffc020195e <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0201956:	8832                	mv	a6,a2
ffffffffc0201958:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc020195a:	87ba                	mv	a5,a4
ffffffffc020195c:	bfc1                	j	ffffffffc020192c <default_init_memmap+0x68>
}
ffffffffc020195e:	60a2                	ld	ra,8(sp)
ffffffffc0201960:	e290                	sd	a2,0(a3)
ffffffffc0201962:	0141                	addi	sp,sp,16
ffffffffc0201964:	8082                	ret
ffffffffc0201966:	60a2                	ld	ra,8(sp)
ffffffffc0201968:	e390                	sd	a2,0(a5)
ffffffffc020196a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020196c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020196e:	ed1c                	sd	a5,24(a0)
ffffffffc0201970:	0141                	addi	sp,sp,16
ffffffffc0201972:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201974:	00005697          	auipc	a3,0x5
ffffffffc0201978:	d1468693          	addi	a3,a3,-748 # ffffffffc0206688 <commands+0xbd8>
ffffffffc020197c:	00005617          	auipc	a2,0x5
ffffffffc0201980:	98460613          	addi	a2,a2,-1660 # ffffffffc0206300 <commands+0x850>
ffffffffc0201984:	04b00593          	li	a1,75
ffffffffc0201988:	00005517          	auipc	a0,0x5
ffffffffc020198c:	99050513          	addi	a0,a0,-1648 # ffffffffc0206318 <commands+0x868>
ffffffffc0201990:	b03fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(n > 0);
ffffffffc0201994:	00005697          	auipc	a3,0x5
ffffffffc0201998:	cc468693          	addi	a3,a3,-828 # ffffffffc0206658 <commands+0xba8>
ffffffffc020199c:	00005617          	auipc	a2,0x5
ffffffffc02019a0:	96460613          	addi	a2,a2,-1692 # ffffffffc0206300 <commands+0x850>
ffffffffc02019a4:	04700593          	li	a1,71
ffffffffc02019a8:	00005517          	auipc	a0,0x5
ffffffffc02019ac:	97050513          	addi	a0,a0,-1680 # ffffffffc0206318 <commands+0x868>
ffffffffc02019b0:	ae3fe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02019b4 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02019b4:	c94d                	beqz	a0,ffffffffc0201a66 <slob_free+0xb2>
{
ffffffffc02019b6:	1141                	addi	sp,sp,-16
ffffffffc02019b8:	e022                	sd	s0,0(sp)
ffffffffc02019ba:	e406                	sd	ra,8(sp)
ffffffffc02019bc:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc02019be:	e9c1                	bnez	a1,ffffffffc0201a4e <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02019c0:	100027f3          	csrr	a5,sstatus
ffffffffc02019c4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02019c6:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02019c8:	ebd9                	bnez	a5,ffffffffc0201a5e <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019ca:	000c1617          	auipc	a2,0xc1
ffffffffc02019ce:	ece60613          	addi	a2,a2,-306 # ffffffffc02c2898 <slobfree>
ffffffffc02019d2:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019d4:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019d6:	679c                	ld	a5,8(a5)
ffffffffc02019d8:	02877a63          	bgeu	a4,s0,ffffffffc0201a0c <slob_free+0x58>
ffffffffc02019dc:	00f46463          	bltu	s0,a5,ffffffffc02019e4 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019e0:	fef76ae3          	bltu	a4,a5,ffffffffc02019d4 <slob_free+0x20>
			break;

	if (b + b->units == cur->next)
ffffffffc02019e4:	400c                	lw	a1,0(s0)
ffffffffc02019e6:	00459693          	slli	a3,a1,0x4
ffffffffc02019ea:	96a2                	add	a3,a3,s0
ffffffffc02019ec:	02d78a63          	beq	a5,a3,ffffffffc0201a20 <slob_free+0x6c>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc02019f0:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc02019f2:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc02019f4:	00469793          	slli	a5,a3,0x4
ffffffffc02019f8:	97ba                	add	a5,a5,a4
ffffffffc02019fa:	02f40e63          	beq	s0,a5,ffffffffc0201a36 <slob_free+0x82>
	{
		cur->units += b->units;
		cur->next = b->next;
	}
	else
		cur->next = b;
ffffffffc02019fe:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0201a00:	e218                	sd	a4,0(a2)
    if (flag)
ffffffffc0201a02:	e129                	bnez	a0,ffffffffc0201a44 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201a04:	60a2                	ld	ra,8(sp)
ffffffffc0201a06:	6402                	ld	s0,0(sp)
ffffffffc0201a08:	0141                	addi	sp,sp,16
ffffffffc0201a0a:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a0c:	fcf764e3          	bltu	a4,a5,ffffffffc02019d4 <slob_free+0x20>
ffffffffc0201a10:	fcf472e3          	bgeu	s0,a5,ffffffffc02019d4 <slob_free+0x20>
	if (b + b->units == cur->next)
ffffffffc0201a14:	400c                	lw	a1,0(s0)
ffffffffc0201a16:	00459693          	slli	a3,a1,0x4
ffffffffc0201a1a:	96a2                	add	a3,a3,s0
ffffffffc0201a1c:	fcd79ae3          	bne	a5,a3,ffffffffc02019f0 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0201a20:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201a22:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201a24:	9db5                	addw	a1,a1,a3
ffffffffc0201a26:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b)
ffffffffc0201a28:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a2a:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0201a2c:	00469793          	slli	a5,a3,0x4
ffffffffc0201a30:	97ba                	add	a5,a5,a4
ffffffffc0201a32:	fcf416e3          	bne	s0,a5,ffffffffc02019fe <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0201a36:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201a38:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0201a3a:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201a3c:	9ebd                	addw	a3,a3,a5
ffffffffc0201a3e:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0201a40:	e70c                	sd	a1,8(a4)
ffffffffc0201a42:	d169                	beqz	a0,ffffffffc0201a04 <slob_free+0x50>
}
ffffffffc0201a44:	6402                	ld	s0,0(sp)
ffffffffc0201a46:	60a2                	ld	ra,8(sp)
ffffffffc0201a48:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201a4a:	f5ffe06f          	j	ffffffffc02009a8 <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0201a4e:	25bd                	addiw	a1,a1,15
ffffffffc0201a50:	8191                	srli	a1,a1,0x4
ffffffffc0201a52:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201a54:	100027f3          	csrr	a5,sstatus
ffffffffc0201a58:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201a5a:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201a5c:	d7bd                	beqz	a5,ffffffffc02019ca <slob_free+0x16>
        intr_disable();
ffffffffc0201a5e:	f51fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        return 1;
ffffffffc0201a62:	4505                	li	a0,1
ffffffffc0201a64:	b79d                	j	ffffffffc02019ca <slob_free+0x16>
ffffffffc0201a66:	8082                	ret

ffffffffc0201a68 <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201a68:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201a6a:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201a6c:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201a70:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201a72:	352000ef          	jal	ra,ffffffffc0201dc4 <alloc_pages>
	if (!page)
ffffffffc0201a76:	c91d                	beqz	a0,ffffffffc0201aac <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201a78:	000c5697          	auipc	a3,0xc5
ffffffffc0201a7c:	2c86b683          	ld	a3,712(a3) # ffffffffc02c6d40 <pages>
ffffffffc0201a80:	8d15                	sub	a0,a0,a3
ffffffffc0201a82:	8519                	srai	a0,a0,0x6
ffffffffc0201a84:	00006697          	auipc	a3,0x6
ffffffffc0201a88:	6e46b683          	ld	a3,1764(a3) # ffffffffc0208168 <nbase>
ffffffffc0201a8c:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201a8e:	00c51793          	slli	a5,a0,0xc
ffffffffc0201a92:	83b1                	srli	a5,a5,0xc
ffffffffc0201a94:	000c5717          	auipc	a4,0xc5
ffffffffc0201a98:	2a473703          	ld	a4,676(a4) # ffffffffc02c6d38 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201a9c:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201a9e:	00e7fa63          	bgeu	a5,a4,ffffffffc0201ab2 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201aa2:	000c5697          	auipc	a3,0xc5
ffffffffc0201aa6:	2ae6b683          	ld	a3,686(a3) # ffffffffc02c6d50 <va_pa_offset>
ffffffffc0201aaa:	9536                	add	a0,a0,a3
}
ffffffffc0201aac:	60a2                	ld	ra,8(sp)
ffffffffc0201aae:	0141                	addi	sp,sp,16
ffffffffc0201ab0:	8082                	ret
ffffffffc0201ab2:	86aa                	mv	a3,a0
ffffffffc0201ab4:	00005617          	auipc	a2,0x5
ffffffffc0201ab8:	c3460613          	addi	a2,a2,-972 # ffffffffc02066e8 <default_pmm_manager+0x38>
ffffffffc0201abc:	07100593          	li	a1,113
ffffffffc0201ac0:	00005517          	auipc	a0,0x5
ffffffffc0201ac4:	c5050513          	addi	a0,a0,-944 # ffffffffc0206710 <default_pmm_manager+0x60>
ffffffffc0201ac8:	9cbfe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0201acc <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201acc:	1101                	addi	sp,sp,-32
ffffffffc0201ace:	ec06                	sd	ra,24(sp)
ffffffffc0201ad0:	e822                	sd	s0,16(sp)
ffffffffc0201ad2:	e426                	sd	s1,8(sp)
ffffffffc0201ad4:	e04a                	sd	s2,0(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201ad6:	01050713          	addi	a4,a0,16
ffffffffc0201ada:	6785                	lui	a5,0x1
ffffffffc0201adc:	0cf77363          	bgeu	a4,a5,ffffffffc0201ba2 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201ae0:	00f50493          	addi	s1,a0,15
ffffffffc0201ae4:	8091                	srli	s1,s1,0x4
ffffffffc0201ae6:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201ae8:	10002673          	csrr	a2,sstatus
ffffffffc0201aec:	8a09                	andi	a2,a2,2
ffffffffc0201aee:	e25d                	bnez	a2,ffffffffc0201b94 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201af0:	000c1917          	auipc	s2,0xc1
ffffffffc0201af4:	da890913          	addi	s2,s2,-600 # ffffffffc02c2898 <slobfree>
ffffffffc0201af8:	00093683          	ld	a3,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201afc:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta)
ffffffffc0201afe:	4398                	lw	a4,0(a5)
ffffffffc0201b00:	08975e63          	bge	a4,s1,ffffffffc0201b9c <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree)
ffffffffc0201b04:	00f68b63          	beq	a3,a5,ffffffffc0201b1a <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201b08:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201b0a:	4018                	lw	a4,0(s0)
ffffffffc0201b0c:	02975a63          	bge	a4,s1,ffffffffc0201b40 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree)
ffffffffc0201b10:	00093683          	ld	a3,0(s2)
ffffffffc0201b14:	87a2                	mv	a5,s0
ffffffffc0201b16:	fef699e3          	bne	a3,a5,ffffffffc0201b08 <slob_alloc.constprop.0+0x3c>
    if (flag)
ffffffffc0201b1a:	ee31                	bnez	a2,ffffffffc0201b76 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201b1c:	4501                	li	a0,0
ffffffffc0201b1e:	f4bff0ef          	jal	ra,ffffffffc0201a68 <__slob_get_free_pages.constprop.0>
ffffffffc0201b22:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201b24:	cd05                	beqz	a0,ffffffffc0201b5c <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201b26:	6585                	lui	a1,0x1
ffffffffc0201b28:	e8dff0ef          	jal	ra,ffffffffc02019b4 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b2c:	10002673          	csrr	a2,sstatus
ffffffffc0201b30:	8a09                	andi	a2,a2,2
ffffffffc0201b32:	ee05                	bnez	a2,ffffffffc0201b6a <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201b34:	00093783          	ld	a5,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201b38:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201b3a:	4018                	lw	a4,0(s0)
ffffffffc0201b3c:	fc974ae3          	blt	a4,s1,ffffffffc0201b10 <slob_alloc.constprop.0+0x44>
			if (cur->units == units)	/* exact fit? */
ffffffffc0201b40:	04e48763          	beq	s1,a4,ffffffffc0201b8e <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201b44:	00449693          	slli	a3,s1,0x4
ffffffffc0201b48:	96a2                	add	a3,a3,s0
ffffffffc0201b4a:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201b4c:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201b4e:	9f05                	subw	a4,a4,s1
ffffffffc0201b50:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201b52:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201b54:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201b56:	00f93023          	sd	a5,0(s2)
    if (flag)
ffffffffc0201b5a:	e20d                	bnez	a2,ffffffffc0201b7c <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201b5c:	60e2                	ld	ra,24(sp)
ffffffffc0201b5e:	8522                	mv	a0,s0
ffffffffc0201b60:	6442                	ld	s0,16(sp)
ffffffffc0201b62:	64a2                	ld	s1,8(sp)
ffffffffc0201b64:	6902                	ld	s2,0(sp)
ffffffffc0201b66:	6105                	addi	sp,sp,32
ffffffffc0201b68:	8082                	ret
        intr_disable();
ffffffffc0201b6a:	e45fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
			cur = slobfree;
ffffffffc0201b6e:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201b72:	4605                	li	a2,1
ffffffffc0201b74:	b7d1                	j	ffffffffc0201b38 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201b76:	e33fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0201b7a:	b74d                	j	ffffffffc0201b1c <slob_alloc.constprop.0+0x50>
ffffffffc0201b7c:	e2dfe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
}
ffffffffc0201b80:	60e2                	ld	ra,24(sp)
ffffffffc0201b82:	8522                	mv	a0,s0
ffffffffc0201b84:	6442                	ld	s0,16(sp)
ffffffffc0201b86:	64a2                	ld	s1,8(sp)
ffffffffc0201b88:	6902                	ld	s2,0(sp)
ffffffffc0201b8a:	6105                	addi	sp,sp,32
ffffffffc0201b8c:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201b8e:	6418                	ld	a4,8(s0)
ffffffffc0201b90:	e798                	sd	a4,8(a5)
ffffffffc0201b92:	b7d1                	j	ffffffffc0201b56 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201b94:	e1bfe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        return 1;
ffffffffc0201b98:	4605                	li	a2,1
ffffffffc0201b9a:	bf99                	j	ffffffffc0201af0 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta)
ffffffffc0201b9c:	843e                	mv	s0,a5
ffffffffc0201b9e:	87b6                	mv	a5,a3
ffffffffc0201ba0:	b745                	j	ffffffffc0201b40 <slob_alloc.constprop.0+0x74>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201ba2:	00005697          	auipc	a3,0x5
ffffffffc0201ba6:	b7e68693          	addi	a3,a3,-1154 # ffffffffc0206720 <default_pmm_manager+0x70>
ffffffffc0201baa:	00004617          	auipc	a2,0x4
ffffffffc0201bae:	75660613          	addi	a2,a2,1878 # ffffffffc0206300 <commands+0x850>
ffffffffc0201bb2:	06300593          	li	a1,99
ffffffffc0201bb6:	00005517          	auipc	a0,0x5
ffffffffc0201bba:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0206740 <default_pmm_manager+0x90>
ffffffffc0201bbe:	8d5fe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0201bc2 <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc0201bc2:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc0201bc4:	00005517          	auipc	a0,0x5
ffffffffc0201bc8:	b9450513          	addi	a0,a0,-1132 # ffffffffc0206758 <default_pmm_manager+0xa8>
{
ffffffffc0201bcc:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc0201bce:	dcafe0ef          	jal	ra,ffffffffc0200198 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201bd2:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201bd4:	00005517          	auipc	a0,0x5
ffffffffc0201bd8:	b9c50513          	addi	a0,a0,-1124 # ffffffffc0206770 <default_pmm_manager+0xc0>
}
ffffffffc0201bdc:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201bde:	dbafe06f          	j	ffffffffc0200198 <cprintf>

ffffffffc0201be2 <kallocated>:

size_t
kallocated(void)
{
	return slob_allocated();
}
ffffffffc0201be2:	4501                	li	a0,0
ffffffffc0201be4:	8082                	ret

ffffffffc0201be6 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201be6:	1101                	addi	sp,sp,-32
ffffffffc0201be8:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201bea:	6905                	lui	s2,0x1
{
ffffffffc0201bec:	e822                	sd	s0,16(sp)
ffffffffc0201bee:	ec06                	sd	ra,24(sp)
ffffffffc0201bf0:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201bf2:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8f61>
{
ffffffffc0201bf6:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201bf8:	04a7f963          	bgeu	a5,a0,ffffffffc0201c4a <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201bfc:	4561                	li	a0,24
ffffffffc0201bfe:	ecfff0ef          	jal	ra,ffffffffc0201acc <slob_alloc.constprop.0>
ffffffffc0201c02:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201c04:	c929                	beqz	a0,ffffffffc0201c56 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201c06:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201c0a:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc0201c0c:	00f95763          	bge	s2,a5,ffffffffc0201c1a <kmalloc+0x34>
ffffffffc0201c10:	6705                	lui	a4,0x1
ffffffffc0201c12:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201c14:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc0201c16:	fef74ee3          	blt	a4,a5,ffffffffc0201c12 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201c1a:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201c1c:	e4dff0ef          	jal	ra,ffffffffc0201a68 <__slob_get_free_pages.constprop.0>
ffffffffc0201c20:	e488                	sd	a0,8(s1)
ffffffffc0201c22:	842a                	mv	s0,a0
	if (bb->pages)
ffffffffc0201c24:	c525                	beqz	a0,ffffffffc0201c8c <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201c26:	100027f3          	csrr	a5,sstatus
ffffffffc0201c2a:	8b89                	andi	a5,a5,2
ffffffffc0201c2c:	ef8d                	bnez	a5,ffffffffc0201c66 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201c2e:	000c5797          	auipc	a5,0xc5
ffffffffc0201c32:	0f278793          	addi	a5,a5,242 # ffffffffc02c6d20 <bigblocks>
ffffffffc0201c36:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201c38:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201c3a:	e898                	sd	a4,16(s1)
	return __kmalloc(size, 0);
}
ffffffffc0201c3c:	60e2                	ld	ra,24(sp)
ffffffffc0201c3e:	8522                	mv	a0,s0
ffffffffc0201c40:	6442                	ld	s0,16(sp)
ffffffffc0201c42:	64a2                	ld	s1,8(sp)
ffffffffc0201c44:	6902                	ld	s2,0(sp)
ffffffffc0201c46:	6105                	addi	sp,sp,32
ffffffffc0201c48:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201c4a:	0541                	addi	a0,a0,16
ffffffffc0201c4c:	e81ff0ef          	jal	ra,ffffffffc0201acc <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201c50:	01050413          	addi	s0,a0,16
ffffffffc0201c54:	f565                	bnez	a0,ffffffffc0201c3c <kmalloc+0x56>
ffffffffc0201c56:	4401                	li	s0,0
}
ffffffffc0201c58:	60e2                	ld	ra,24(sp)
ffffffffc0201c5a:	8522                	mv	a0,s0
ffffffffc0201c5c:	6442                	ld	s0,16(sp)
ffffffffc0201c5e:	64a2                	ld	s1,8(sp)
ffffffffc0201c60:	6902                	ld	s2,0(sp)
ffffffffc0201c62:	6105                	addi	sp,sp,32
ffffffffc0201c64:	8082                	ret
        intr_disable();
ffffffffc0201c66:	d49fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
		bb->next = bigblocks;
ffffffffc0201c6a:	000c5797          	auipc	a5,0xc5
ffffffffc0201c6e:	0b678793          	addi	a5,a5,182 # ffffffffc02c6d20 <bigblocks>
ffffffffc0201c72:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201c74:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201c76:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201c78:	d31fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
		return bb->pages;
ffffffffc0201c7c:	6480                	ld	s0,8(s1)
}
ffffffffc0201c7e:	60e2                	ld	ra,24(sp)
ffffffffc0201c80:	64a2                	ld	s1,8(sp)
ffffffffc0201c82:	8522                	mv	a0,s0
ffffffffc0201c84:	6442                	ld	s0,16(sp)
ffffffffc0201c86:	6902                	ld	s2,0(sp)
ffffffffc0201c88:	6105                	addi	sp,sp,32
ffffffffc0201c8a:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c8c:	45e1                	li	a1,24
ffffffffc0201c8e:	8526                	mv	a0,s1
ffffffffc0201c90:	d25ff0ef          	jal	ra,ffffffffc02019b4 <slob_free>
	return __kmalloc(size, 0);
ffffffffc0201c94:	b765                	j	ffffffffc0201c3c <kmalloc+0x56>

ffffffffc0201c96 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201c96:	c169                	beqz	a0,ffffffffc0201d58 <kfree+0xc2>
{
ffffffffc0201c98:	1101                	addi	sp,sp,-32
ffffffffc0201c9a:	e822                	sd	s0,16(sp)
ffffffffc0201c9c:	ec06                	sd	ra,24(sp)
ffffffffc0201c9e:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201ca0:	03451793          	slli	a5,a0,0x34
ffffffffc0201ca4:	842a                	mv	s0,a0
ffffffffc0201ca6:	e3d9                	bnez	a5,ffffffffc0201d2c <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201ca8:	100027f3          	csrr	a5,sstatus
ffffffffc0201cac:	8b89                	andi	a5,a5,2
ffffffffc0201cae:	e7d9                	bnez	a5,ffffffffc0201d3c <kfree+0xa6>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201cb0:	000c5797          	auipc	a5,0xc5
ffffffffc0201cb4:	0707b783          	ld	a5,112(a5) # ffffffffc02c6d20 <bigblocks>
    return 0;
ffffffffc0201cb8:	4601                	li	a2,0
ffffffffc0201cba:	cbad                	beqz	a5,ffffffffc0201d2c <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201cbc:	000c5697          	auipc	a3,0xc5
ffffffffc0201cc0:	06468693          	addi	a3,a3,100 # ffffffffc02c6d20 <bigblocks>
ffffffffc0201cc4:	a021                	j	ffffffffc0201ccc <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201cc6:	01048693          	addi	a3,s1,16
ffffffffc0201cca:	c3a5                	beqz	a5,ffffffffc0201d2a <kfree+0x94>
		{
			if (bb->pages == block)
ffffffffc0201ccc:	6798                	ld	a4,8(a5)
ffffffffc0201cce:	84be                	mv	s1,a5
			{
				*last = bb->next;
ffffffffc0201cd0:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc0201cd2:	fe871ae3          	bne	a4,s0,ffffffffc0201cc6 <kfree+0x30>
				*last = bb->next;
ffffffffc0201cd6:	e29c                	sd	a5,0(a3)
    if (flag)
ffffffffc0201cd8:	ee2d                	bnez	a2,ffffffffc0201d52 <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201cda:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201cde:	4098                	lw	a4,0(s1)
ffffffffc0201ce0:	08f46963          	bltu	s0,a5,ffffffffc0201d72 <kfree+0xdc>
ffffffffc0201ce4:	000c5697          	auipc	a3,0xc5
ffffffffc0201ce8:	06c6b683          	ld	a3,108(a3) # ffffffffc02c6d50 <va_pa_offset>
ffffffffc0201cec:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage)
ffffffffc0201cee:	8031                	srli	s0,s0,0xc
ffffffffc0201cf0:	000c5797          	auipc	a5,0xc5
ffffffffc0201cf4:	0487b783          	ld	a5,72(a5) # ffffffffc02c6d38 <npage>
ffffffffc0201cf8:	06f47163          	bgeu	s0,a5,ffffffffc0201d5a <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201cfc:	00006517          	auipc	a0,0x6
ffffffffc0201d00:	46c53503          	ld	a0,1132(a0) # ffffffffc0208168 <nbase>
ffffffffc0201d04:	8c09                	sub	s0,s0,a0
ffffffffc0201d06:	041a                	slli	s0,s0,0x6
	free_pages(kva2page(kva), 1 << order);
ffffffffc0201d08:	000c5517          	auipc	a0,0xc5
ffffffffc0201d0c:	03853503          	ld	a0,56(a0) # ffffffffc02c6d40 <pages>
ffffffffc0201d10:	4585                	li	a1,1
ffffffffc0201d12:	9522                	add	a0,a0,s0
ffffffffc0201d14:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201d18:	0ea000ef          	jal	ra,ffffffffc0201e02 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201d1c:	6442                	ld	s0,16(sp)
ffffffffc0201d1e:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d20:	8526                	mv	a0,s1
}
ffffffffc0201d22:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d24:	45e1                	li	a1,24
}
ffffffffc0201d26:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d28:	b171                	j	ffffffffc02019b4 <slob_free>
ffffffffc0201d2a:	e20d                	bnez	a2,ffffffffc0201d4c <kfree+0xb6>
ffffffffc0201d2c:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201d30:	6442                	ld	s0,16(sp)
ffffffffc0201d32:	60e2                	ld	ra,24(sp)
ffffffffc0201d34:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d36:	4581                	li	a1,0
}
ffffffffc0201d38:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d3a:	b9ad                	j	ffffffffc02019b4 <slob_free>
        intr_disable();
ffffffffc0201d3c:	c73fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201d40:	000c5797          	auipc	a5,0xc5
ffffffffc0201d44:	fe07b783          	ld	a5,-32(a5) # ffffffffc02c6d20 <bigblocks>
        return 1;
ffffffffc0201d48:	4605                	li	a2,1
ffffffffc0201d4a:	fbad                	bnez	a5,ffffffffc0201cbc <kfree+0x26>
        intr_enable();
ffffffffc0201d4c:	c5dfe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0201d50:	bff1                	j	ffffffffc0201d2c <kfree+0x96>
ffffffffc0201d52:	c57fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0201d56:	b751                	j	ffffffffc0201cda <kfree+0x44>
ffffffffc0201d58:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201d5a:	00005617          	auipc	a2,0x5
ffffffffc0201d5e:	a5e60613          	addi	a2,a2,-1442 # ffffffffc02067b8 <default_pmm_manager+0x108>
ffffffffc0201d62:	06900593          	li	a1,105
ffffffffc0201d66:	00005517          	auipc	a0,0x5
ffffffffc0201d6a:	9aa50513          	addi	a0,a0,-1622 # ffffffffc0206710 <default_pmm_manager+0x60>
ffffffffc0201d6e:	f24fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201d72:	86a2                	mv	a3,s0
ffffffffc0201d74:	00005617          	auipc	a2,0x5
ffffffffc0201d78:	a1c60613          	addi	a2,a2,-1508 # ffffffffc0206790 <default_pmm_manager+0xe0>
ffffffffc0201d7c:	07700593          	li	a1,119
ffffffffc0201d80:	00005517          	auipc	a0,0x5
ffffffffc0201d84:	99050513          	addi	a0,a0,-1648 # ffffffffc0206710 <default_pmm_manager+0x60>
ffffffffc0201d88:	f0afe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0201d8c <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc0201d8c:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201d8e:	00005617          	auipc	a2,0x5
ffffffffc0201d92:	a2a60613          	addi	a2,a2,-1494 # ffffffffc02067b8 <default_pmm_manager+0x108>
ffffffffc0201d96:	06900593          	li	a1,105
ffffffffc0201d9a:	00005517          	auipc	a0,0x5
ffffffffc0201d9e:	97650513          	addi	a0,a0,-1674 # ffffffffc0206710 <default_pmm_manager+0x60>
pa2page(uintptr_t pa)
ffffffffc0201da2:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201da4:	eeefe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0201da8 <pte2page.part.0>:
pte2page(pte_t pte)
ffffffffc0201da8:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201daa:	00005617          	auipc	a2,0x5
ffffffffc0201dae:	a2e60613          	addi	a2,a2,-1490 # ffffffffc02067d8 <default_pmm_manager+0x128>
ffffffffc0201db2:	07f00593          	li	a1,127
ffffffffc0201db6:	00005517          	auipc	a0,0x5
ffffffffc0201dba:	95a50513          	addi	a0,a0,-1702 # ffffffffc0206710 <default_pmm_manager+0x60>
pte2page(pte_t pte)
ffffffffc0201dbe:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201dc0:	ed2fe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0201dc4 <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201dc4:	100027f3          	csrr	a5,sstatus
ffffffffc0201dc8:	8b89                	andi	a5,a5,2
ffffffffc0201dca:	e799                	bnez	a5,ffffffffc0201dd8 <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201dcc:	000c5797          	auipc	a5,0xc5
ffffffffc0201dd0:	f7c7b783          	ld	a5,-132(a5) # ffffffffc02c6d48 <pmm_manager>
ffffffffc0201dd4:	6f9c                	ld	a5,24(a5)
ffffffffc0201dd6:	8782                	jr	a5
{
ffffffffc0201dd8:	1141                	addi	sp,sp,-16
ffffffffc0201dda:	e406                	sd	ra,8(sp)
ffffffffc0201ddc:	e022                	sd	s0,0(sp)
ffffffffc0201dde:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201de0:	bcffe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201de4:	000c5797          	auipc	a5,0xc5
ffffffffc0201de8:	f647b783          	ld	a5,-156(a5) # ffffffffc02c6d48 <pmm_manager>
ffffffffc0201dec:	6f9c                	ld	a5,24(a5)
ffffffffc0201dee:	8522                	mv	a0,s0
ffffffffc0201df0:	9782                	jalr	a5
ffffffffc0201df2:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201df4:	bb5fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201df8:	60a2                	ld	ra,8(sp)
ffffffffc0201dfa:	8522                	mv	a0,s0
ffffffffc0201dfc:	6402                	ld	s0,0(sp)
ffffffffc0201dfe:	0141                	addi	sp,sp,16
ffffffffc0201e00:	8082                	ret

ffffffffc0201e02 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201e02:	100027f3          	csrr	a5,sstatus
ffffffffc0201e06:	8b89                	andi	a5,a5,2
ffffffffc0201e08:	e799                	bnez	a5,ffffffffc0201e16 <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201e0a:	000c5797          	auipc	a5,0xc5
ffffffffc0201e0e:	f3e7b783          	ld	a5,-194(a5) # ffffffffc02c6d48 <pmm_manager>
ffffffffc0201e12:	739c                	ld	a5,32(a5)
ffffffffc0201e14:	8782                	jr	a5
{
ffffffffc0201e16:	1101                	addi	sp,sp,-32
ffffffffc0201e18:	ec06                	sd	ra,24(sp)
ffffffffc0201e1a:	e822                	sd	s0,16(sp)
ffffffffc0201e1c:	e426                	sd	s1,8(sp)
ffffffffc0201e1e:	842a                	mv	s0,a0
ffffffffc0201e20:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201e22:	b8dfe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201e26:	000c5797          	auipc	a5,0xc5
ffffffffc0201e2a:	f227b783          	ld	a5,-222(a5) # ffffffffc02c6d48 <pmm_manager>
ffffffffc0201e2e:	739c                	ld	a5,32(a5)
ffffffffc0201e30:	85a6                	mv	a1,s1
ffffffffc0201e32:	8522                	mv	a0,s0
ffffffffc0201e34:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201e36:	6442                	ld	s0,16(sp)
ffffffffc0201e38:	60e2                	ld	ra,24(sp)
ffffffffc0201e3a:	64a2                	ld	s1,8(sp)
ffffffffc0201e3c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201e3e:	b6bfe06f          	j	ffffffffc02009a8 <intr_enable>

ffffffffc0201e42 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201e42:	100027f3          	csrr	a5,sstatus
ffffffffc0201e46:	8b89                	andi	a5,a5,2
ffffffffc0201e48:	e799                	bnez	a5,ffffffffc0201e56 <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201e4a:	000c5797          	auipc	a5,0xc5
ffffffffc0201e4e:	efe7b783          	ld	a5,-258(a5) # ffffffffc02c6d48 <pmm_manager>
ffffffffc0201e52:	779c                	ld	a5,40(a5)
ffffffffc0201e54:	8782                	jr	a5
{
ffffffffc0201e56:	1141                	addi	sp,sp,-16
ffffffffc0201e58:	e406                	sd	ra,8(sp)
ffffffffc0201e5a:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201e5c:	b53fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201e60:	000c5797          	auipc	a5,0xc5
ffffffffc0201e64:	ee87b783          	ld	a5,-280(a5) # ffffffffc02c6d48 <pmm_manager>
ffffffffc0201e68:	779c                	ld	a5,40(a5)
ffffffffc0201e6a:	9782                	jalr	a5
ffffffffc0201e6c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201e6e:	b3bfe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201e72:	60a2                	ld	ra,8(sp)
ffffffffc0201e74:	8522                	mv	a0,s0
ffffffffc0201e76:	6402                	ld	s0,0(sp)
ffffffffc0201e78:	0141                	addi	sp,sp,16
ffffffffc0201e7a:	8082                	ret

ffffffffc0201e7c <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201e7c:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201e80:	1ff7f793          	andi	a5,a5,511
{
ffffffffc0201e84:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201e86:	078e                	slli	a5,a5,0x3
{
ffffffffc0201e88:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201e8a:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc0201e8e:	6094                	ld	a3,0(s1)
{
ffffffffc0201e90:	f04a                	sd	s2,32(sp)
ffffffffc0201e92:	ec4e                	sd	s3,24(sp)
ffffffffc0201e94:	e852                	sd	s4,16(sp)
ffffffffc0201e96:	fc06                	sd	ra,56(sp)
ffffffffc0201e98:	f822                	sd	s0,48(sp)
ffffffffc0201e9a:	e456                	sd	s5,8(sp)
ffffffffc0201e9c:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc0201e9e:	0016f793          	andi	a5,a3,1
{
ffffffffc0201ea2:	892e                	mv	s2,a1
ffffffffc0201ea4:	8a32                	mv	s4,a2
ffffffffc0201ea6:	000c5997          	auipc	s3,0xc5
ffffffffc0201eaa:	e9298993          	addi	s3,s3,-366 # ffffffffc02c6d38 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc0201eae:	efbd                	bnez	a5,ffffffffc0201f2c <get_pte+0xb0>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201eb0:	14060c63          	beqz	a2,ffffffffc0202008 <get_pte+0x18c>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201eb4:	100027f3          	csrr	a5,sstatus
ffffffffc0201eb8:	8b89                	andi	a5,a5,2
ffffffffc0201eba:	14079963          	bnez	a5,ffffffffc020200c <get_pte+0x190>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201ebe:	000c5797          	auipc	a5,0xc5
ffffffffc0201ec2:	e8a7b783          	ld	a5,-374(a5) # ffffffffc02c6d48 <pmm_manager>
ffffffffc0201ec6:	6f9c                	ld	a5,24(a5)
ffffffffc0201ec8:	4505                	li	a0,1
ffffffffc0201eca:	9782                	jalr	a5
ffffffffc0201ecc:	842a                	mv	s0,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201ece:	12040d63          	beqz	s0,ffffffffc0202008 <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0201ed2:	000c5b17          	auipc	s6,0xc5
ffffffffc0201ed6:	e6eb0b13          	addi	s6,s6,-402 # ffffffffc02c6d40 <pages>
ffffffffc0201eda:	000b3503          	ld	a0,0(s6)
ffffffffc0201ede:	00080ab7          	lui	s5,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201ee2:	000c5997          	auipc	s3,0xc5
ffffffffc0201ee6:	e5698993          	addi	s3,s3,-426 # ffffffffc02c6d38 <npage>
ffffffffc0201eea:	40a40533          	sub	a0,s0,a0
ffffffffc0201eee:	8519                	srai	a0,a0,0x6
ffffffffc0201ef0:	9556                	add	a0,a0,s5
ffffffffc0201ef2:	0009b703          	ld	a4,0(s3)
ffffffffc0201ef6:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201efa:	4685                	li	a3,1
ffffffffc0201efc:	c014                	sw	a3,0(s0)
ffffffffc0201efe:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f00:	0532                	slli	a0,a0,0xc
ffffffffc0201f02:	16e7f763          	bgeu	a5,a4,ffffffffc0202070 <get_pte+0x1f4>
ffffffffc0201f06:	000c5797          	auipc	a5,0xc5
ffffffffc0201f0a:	e4a7b783          	ld	a5,-438(a5) # ffffffffc02c6d50 <va_pa_offset>
ffffffffc0201f0e:	6605                	lui	a2,0x1
ffffffffc0201f10:	4581                	li	a1,0
ffffffffc0201f12:	953e                	add	a0,a0,a5
ffffffffc0201f14:	107030ef          	jal	ra,ffffffffc020581a <memset>
    return page - pages + nbase;
ffffffffc0201f18:	000b3683          	ld	a3,0(s6)
ffffffffc0201f1c:	40d406b3          	sub	a3,s0,a3
ffffffffc0201f20:	8699                	srai	a3,a3,0x6
ffffffffc0201f22:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201f24:	06aa                	slli	a3,a3,0xa
ffffffffc0201f26:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201f2a:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201f2c:	77fd                	lui	a5,0xfffff
ffffffffc0201f2e:	068a                	slli	a3,a3,0x2
ffffffffc0201f30:	0009b703          	ld	a4,0(s3)
ffffffffc0201f34:	8efd                	and	a3,a3,a5
ffffffffc0201f36:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201f3a:	10e7ff63          	bgeu	a5,a4,ffffffffc0202058 <get_pte+0x1dc>
ffffffffc0201f3e:	000c5a97          	auipc	s5,0xc5
ffffffffc0201f42:	e12a8a93          	addi	s5,s5,-494 # ffffffffc02c6d50 <va_pa_offset>
ffffffffc0201f46:	000ab403          	ld	s0,0(s5)
ffffffffc0201f4a:	01595793          	srli	a5,s2,0x15
ffffffffc0201f4e:	1ff7f793          	andi	a5,a5,511
ffffffffc0201f52:	96a2                	add	a3,a3,s0
ffffffffc0201f54:	00379413          	slli	s0,a5,0x3
ffffffffc0201f58:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V))
ffffffffc0201f5a:	6014                	ld	a3,0(s0)
ffffffffc0201f5c:	0016f793          	andi	a5,a3,1
ffffffffc0201f60:	ebad                	bnez	a5,ffffffffc0201fd2 <get_pte+0x156>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201f62:	0a0a0363          	beqz	s4,ffffffffc0202008 <get_pte+0x18c>
ffffffffc0201f66:	100027f3          	csrr	a5,sstatus
ffffffffc0201f6a:	8b89                	andi	a5,a5,2
ffffffffc0201f6c:	efcd                	bnez	a5,ffffffffc0202026 <get_pte+0x1aa>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201f6e:	000c5797          	auipc	a5,0xc5
ffffffffc0201f72:	dda7b783          	ld	a5,-550(a5) # ffffffffc02c6d48 <pmm_manager>
ffffffffc0201f76:	6f9c                	ld	a5,24(a5)
ffffffffc0201f78:	4505                	li	a0,1
ffffffffc0201f7a:	9782                	jalr	a5
ffffffffc0201f7c:	84aa                	mv	s1,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201f7e:	c4c9                	beqz	s1,ffffffffc0202008 <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0201f80:	000c5b17          	auipc	s6,0xc5
ffffffffc0201f84:	dc0b0b13          	addi	s6,s6,-576 # ffffffffc02c6d40 <pages>
ffffffffc0201f88:	000b3503          	ld	a0,0(s6)
ffffffffc0201f8c:	00080a37          	lui	s4,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f90:	0009b703          	ld	a4,0(s3)
ffffffffc0201f94:	40a48533          	sub	a0,s1,a0
ffffffffc0201f98:	8519                	srai	a0,a0,0x6
ffffffffc0201f9a:	9552                	add	a0,a0,s4
ffffffffc0201f9c:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201fa0:	4685                	li	a3,1
ffffffffc0201fa2:	c094                	sw	a3,0(s1)
ffffffffc0201fa4:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fa6:	0532                	slli	a0,a0,0xc
ffffffffc0201fa8:	0ee7f163          	bgeu	a5,a4,ffffffffc020208a <get_pte+0x20e>
ffffffffc0201fac:	000ab783          	ld	a5,0(s5)
ffffffffc0201fb0:	6605                	lui	a2,0x1
ffffffffc0201fb2:	4581                	li	a1,0
ffffffffc0201fb4:	953e                	add	a0,a0,a5
ffffffffc0201fb6:	065030ef          	jal	ra,ffffffffc020581a <memset>
    return page - pages + nbase;
ffffffffc0201fba:	000b3683          	ld	a3,0(s6)
ffffffffc0201fbe:	40d486b3          	sub	a3,s1,a3
ffffffffc0201fc2:	8699                	srai	a3,a3,0x6
ffffffffc0201fc4:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201fc6:	06aa                	slli	a3,a3,0xa
ffffffffc0201fc8:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201fcc:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201fce:	0009b703          	ld	a4,0(s3)
ffffffffc0201fd2:	068a                	slli	a3,a3,0x2
ffffffffc0201fd4:	757d                	lui	a0,0xfffff
ffffffffc0201fd6:	8ee9                	and	a3,a3,a0
ffffffffc0201fd8:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201fdc:	06e7f263          	bgeu	a5,a4,ffffffffc0202040 <get_pte+0x1c4>
ffffffffc0201fe0:	000ab503          	ld	a0,0(s5)
ffffffffc0201fe4:	00c95913          	srli	s2,s2,0xc
ffffffffc0201fe8:	1ff97913          	andi	s2,s2,511
ffffffffc0201fec:	96aa                	add	a3,a3,a0
ffffffffc0201fee:	00391513          	slli	a0,s2,0x3
ffffffffc0201ff2:	9536                	add	a0,a0,a3
}
ffffffffc0201ff4:	70e2                	ld	ra,56(sp)
ffffffffc0201ff6:	7442                	ld	s0,48(sp)
ffffffffc0201ff8:	74a2                	ld	s1,40(sp)
ffffffffc0201ffa:	7902                	ld	s2,32(sp)
ffffffffc0201ffc:	69e2                	ld	s3,24(sp)
ffffffffc0201ffe:	6a42                	ld	s4,16(sp)
ffffffffc0202000:	6aa2                	ld	s5,8(sp)
ffffffffc0202002:	6b02                	ld	s6,0(sp)
ffffffffc0202004:	6121                	addi	sp,sp,64
ffffffffc0202006:	8082                	ret
            return NULL;
ffffffffc0202008:	4501                	li	a0,0
ffffffffc020200a:	b7ed                	j	ffffffffc0201ff4 <get_pte+0x178>
        intr_disable();
ffffffffc020200c:	9a3fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202010:	000c5797          	auipc	a5,0xc5
ffffffffc0202014:	d387b783          	ld	a5,-712(a5) # ffffffffc02c6d48 <pmm_manager>
ffffffffc0202018:	6f9c                	ld	a5,24(a5)
ffffffffc020201a:	4505                	li	a0,1
ffffffffc020201c:	9782                	jalr	a5
ffffffffc020201e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202020:	989fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202024:	b56d                	j	ffffffffc0201ece <get_pte+0x52>
        intr_disable();
ffffffffc0202026:	989fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc020202a:	000c5797          	auipc	a5,0xc5
ffffffffc020202e:	d1e7b783          	ld	a5,-738(a5) # ffffffffc02c6d48 <pmm_manager>
ffffffffc0202032:	6f9c                	ld	a5,24(a5)
ffffffffc0202034:	4505                	li	a0,1
ffffffffc0202036:	9782                	jalr	a5
ffffffffc0202038:	84aa                	mv	s1,a0
        intr_enable();
ffffffffc020203a:	96ffe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc020203e:	b781                	j	ffffffffc0201f7e <get_pte+0x102>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202040:	00004617          	auipc	a2,0x4
ffffffffc0202044:	6a860613          	addi	a2,a2,1704 # ffffffffc02066e8 <default_pmm_manager+0x38>
ffffffffc0202048:	0fa00593          	li	a1,250
ffffffffc020204c:	00004517          	auipc	a0,0x4
ffffffffc0202050:	7b450513          	addi	a0,a0,1972 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202054:	c3efe0ef          	jal	ra,ffffffffc0200492 <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202058:	00004617          	auipc	a2,0x4
ffffffffc020205c:	69060613          	addi	a2,a2,1680 # ffffffffc02066e8 <default_pmm_manager+0x38>
ffffffffc0202060:	0ed00593          	li	a1,237
ffffffffc0202064:	00004517          	auipc	a0,0x4
ffffffffc0202068:	79c50513          	addi	a0,a0,1948 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc020206c:	c26fe0ef          	jal	ra,ffffffffc0200492 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202070:	86aa                	mv	a3,a0
ffffffffc0202072:	00004617          	auipc	a2,0x4
ffffffffc0202076:	67660613          	addi	a2,a2,1654 # ffffffffc02066e8 <default_pmm_manager+0x38>
ffffffffc020207a:	0e900593          	li	a1,233
ffffffffc020207e:	00004517          	auipc	a0,0x4
ffffffffc0202082:	78250513          	addi	a0,a0,1922 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202086:	c0cfe0ef          	jal	ra,ffffffffc0200492 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020208a:	86aa                	mv	a3,a0
ffffffffc020208c:	00004617          	auipc	a2,0x4
ffffffffc0202090:	65c60613          	addi	a2,a2,1628 # ffffffffc02066e8 <default_pmm_manager+0x38>
ffffffffc0202094:	0f700593          	li	a1,247
ffffffffc0202098:	00004517          	auipc	a0,0x4
ffffffffc020209c:	76850513          	addi	a0,a0,1896 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc02020a0:	bf2fe0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02020a4 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc02020a4:	1141                	addi	sp,sp,-16
ffffffffc02020a6:	e022                	sd	s0,0(sp)
ffffffffc02020a8:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02020aa:	4601                	li	a2,0
{
ffffffffc02020ac:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02020ae:	dcfff0ef          	jal	ra,ffffffffc0201e7c <get_pte>
    if (ptep_store != NULL)
ffffffffc02020b2:	c011                	beqz	s0,ffffffffc02020b6 <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc02020b4:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc02020b6:	c511                	beqz	a0,ffffffffc02020c2 <get_page+0x1e>
ffffffffc02020b8:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02020ba:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc02020bc:	0017f713          	andi	a4,a5,1
ffffffffc02020c0:	e709                	bnez	a4,ffffffffc02020ca <get_page+0x26>
}
ffffffffc02020c2:	60a2                	ld	ra,8(sp)
ffffffffc02020c4:	6402                	ld	s0,0(sp)
ffffffffc02020c6:	0141                	addi	sp,sp,16
ffffffffc02020c8:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02020ca:	078a                	slli	a5,a5,0x2
ffffffffc02020cc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02020ce:	000c5717          	auipc	a4,0xc5
ffffffffc02020d2:	c6a73703          	ld	a4,-918(a4) # ffffffffc02c6d38 <npage>
ffffffffc02020d6:	00e7ff63          	bgeu	a5,a4,ffffffffc02020f4 <get_page+0x50>
ffffffffc02020da:	60a2                	ld	ra,8(sp)
ffffffffc02020dc:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc02020de:	fff80537          	lui	a0,0xfff80
ffffffffc02020e2:	97aa                	add	a5,a5,a0
ffffffffc02020e4:	079a                	slli	a5,a5,0x6
ffffffffc02020e6:	000c5517          	auipc	a0,0xc5
ffffffffc02020ea:	c5a53503          	ld	a0,-934(a0) # ffffffffc02c6d40 <pages>
ffffffffc02020ee:	953e                	add	a0,a0,a5
ffffffffc02020f0:	0141                	addi	sp,sp,16
ffffffffc02020f2:	8082                	ret
ffffffffc02020f4:	c99ff0ef          	jal	ra,ffffffffc0201d8c <pa2page.part.0>

ffffffffc02020f8 <unmap_range>:
        tlb_invalidate(pgdir, la); //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc02020f8:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02020fa:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc02020fe:	f486                	sd	ra,104(sp)
ffffffffc0202100:	f0a2                	sd	s0,96(sp)
ffffffffc0202102:	eca6                	sd	s1,88(sp)
ffffffffc0202104:	e8ca                	sd	s2,80(sp)
ffffffffc0202106:	e4ce                	sd	s3,72(sp)
ffffffffc0202108:	e0d2                	sd	s4,64(sp)
ffffffffc020210a:	fc56                	sd	s5,56(sp)
ffffffffc020210c:	f85a                	sd	s6,48(sp)
ffffffffc020210e:	f45e                	sd	s7,40(sp)
ffffffffc0202110:	f062                	sd	s8,32(sp)
ffffffffc0202112:	ec66                	sd	s9,24(sp)
ffffffffc0202114:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202116:	17d2                	slli	a5,a5,0x34
ffffffffc0202118:	e3ed                	bnez	a5,ffffffffc02021fa <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc020211a:	002007b7          	lui	a5,0x200
ffffffffc020211e:	842e                	mv	s0,a1
ffffffffc0202120:	0ef5ed63          	bltu	a1,a5,ffffffffc020221a <unmap_range+0x122>
ffffffffc0202124:	8932                	mv	s2,a2
ffffffffc0202126:	0ec5fa63          	bgeu	a1,a2,ffffffffc020221a <unmap_range+0x122>
ffffffffc020212a:	4785                	li	a5,1
ffffffffc020212c:	07fe                	slli	a5,a5,0x1f
ffffffffc020212e:	0ec7e663          	bltu	a5,a2,ffffffffc020221a <unmap_range+0x122>
ffffffffc0202132:	89aa                	mv	s3,a0
        }
        if (*ptep != 0)
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0202134:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage)
ffffffffc0202136:	000c5c97          	auipc	s9,0xc5
ffffffffc020213a:	c02c8c93          	addi	s9,s9,-1022 # ffffffffc02c6d38 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020213e:	000c5c17          	auipc	s8,0xc5
ffffffffc0202142:	c02c0c13          	addi	s8,s8,-1022 # ffffffffc02c6d40 <pages>
ffffffffc0202146:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc020214a:	000c5d17          	auipc	s10,0xc5
ffffffffc020214e:	bfed0d13          	addi	s10,s10,-1026 # ffffffffc02c6d48 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202152:	00200b37          	lui	s6,0x200
ffffffffc0202156:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc020215a:	4601                	li	a2,0
ffffffffc020215c:	85a2                	mv	a1,s0
ffffffffc020215e:	854e                	mv	a0,s3
ffffffffc0202160:	d1dff0ef          	jal	ra,ffffffffc0201e7c <get_pte>
ffffffffc0202164:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc0202166:	cd29                	beqz	a0,ffffffffc02021c0 <unmap_range+0xc8>
        if (*ptep != 0)
ffffffffc0202168:	611c                	ld	a5,0(a0)
ffffffffc020216a:	e395                	bnez	a5,ffffffffc020218e <unmap_range+0x96>
        start += PGSIZE;
ffffffffc020216c:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc020216e:	ff2466e3          	bltu	s0,s2,ffffffffc020215a <unmap_range+0x62>
}
ffffffffc0202172:	70a6                	ld	ra,104(sp)
ffffffffc0202174:	7406                	ld	s0,96(sp)
ffffffffc0202176:	64e6                	ld	s1,88(sp)
ffffffffc0202178:	6946                	ld	s2,80(sp)
ffffffffc020217a:	69a6                	ld	s3,72(sp)
ffffffffc020217c:	6a06                	ld	s4,64(sp)
ffffffffc020217e:	7ae2                	ld	s5,56(sp)
ffffffffc0202180:	7b42                	ld	s6,48(sp)
ffffffffc0202182:	7ba2                	ld	s7,40(sp)
ffffffffc0202184:	7c02                	ld	s8,32(sp)
ffffffffc0202186:	6ce2                	ld	s9,24(sp)
ffffffffc0202188:	6d42                	ld	s10,16(sp)
ffffffffc020218a:	6165                	addi	sp,sp,112
ffffffffc020218c:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc020218e:	0017f713          	andi	a4,a5,1
ffffffffc0202192:	df69                	beqz	a4,ffffffffc020216c <unmap_range+0x74>
    if (PPN(pa) >= npage)
ffffffffc0202194:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202198:	078a                	slli	a5,a5,0x2
ffffffffc020219a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020219c:	08e7ff63          	bgeu	a5,a4,ffffffffc020223a <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc02021a0:	000c3503          	ld	a0,0(s8)
ffffffffc02021a4:	97de                	add	a5,a5,s7
ffffffffc02021a6:	079a                	slli	a5,a5,0x6
ffffffffc02021a8:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02021aa:	411c                	lw	a5,0(a0)
ffffffffc02021ac:	fff7871b          	addiw	a4,a5,-1
ffffffffc02021b0:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02021b2:	cf11                	beqz	a4,ffffffffc02021ce <unmap_range+0xd6>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc02021b4:	0004b023          	sd	zero,0(s1)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02021b8:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc02021bc:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02021be:	bf45                	j	ffffffffc020216e <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02021c0:	945a                	add	s0,s0,s6
ffffffffc02021c2:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc02021c6:	d455                	beqz	s0,ffffffffc0202172 <unmap_range+0x7a>
ffffffffc02021c8:	f92469e3          	bltu	s0,s2,ffffffffc020215a <unmap_range+0x62>
ffffffffc02021cc:	b75d                	j	ffffffffc0202172 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02021ce:	100027f3          	csrr	a5,sstatus
ffffffffc02021d2:	8b89                	andi	a5,a5,2
ffffffffc02021d4:	e799                	bnez	a5,ffffffffc02021e2 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc02021d6:	000d3783          	ld	a5,0(s10)
ffffffffc02021da:	4585                	li	a1,1
ffffffffc02021dc:	739c                	ld	a5,32(a5)
ffffffffc02021de:	9782                	jalr	a5
    if (flag)
ffffffffc02021e0:	bfd1                	j	ffffffffc02021b4 <unmap_range+0xbc>
ffffffffc02021e2:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02021e4:	fcafe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc02021e8:	000d3783          	ld	a5,0(s10)
ffffffffc02021ec:	6522                	ld	a0,8(sp)
ffffffffc02021ee:	4585                	li	a1,1
ffffffffc02021f0:	739c                	ld	a5,32(a5)
ffffffffc02021f2:	9782                	jalr	a5
        intr_enable();
ffffffffc02021f4:	fb4fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc02021f8:	bf75                	j	ffffffffc02021b4 <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02021fa:	00004697          	auipc	a3,0x4
ffffffffc02021fe:	61668693          	addi	a3,a3,1558 # ffffffffc0206810 <default_pmm_manager+0x160>
ffffffffc0202202:	00004617          	auipc	a2,0x4
ffffffffc0202206:	0fe60613          	addi	a2,a2,254 # ffffffffc0206300 <commands+0x850>
ffffffffc020220a:	12200593          	li	a1,290
ffffffffc020220e:	00004517          	auipc	a0,0x4
ffffffffc0202212:	5f250513          	addi	a0,a0,1522 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202216:	a7cfe0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020221a:	00004697          	auipc	a3,0x4
ffffffffc020221e:	62668693          	addi	a3,a3,1574 # ffffffffc0206840 <default_pmm_manager+0x190>
ffffffffc0202222:	00004617          	auipc	a2,0x4
ffffffffc0202226:	0de60613          	addi	a2,a2,222 # ffffffffc0206300 <commands+0x850>
ffffffffc020222a:	12300593          	li	a1,291
ffffffffc020222e:	00004517          	auipc	a0,0x4
ffffffffc0202232:	5d250513          	addi	a0,a0,1490 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202236:	a5cfe0ef          	jal	ra,ffffffffc0200492 <__panic>
ffffffffc020223a:	b53ff0ef          	jal	ra,ffffffffc0201d8c <pa2page.part.0>

ffffffffc020223e <exit_range>:
{
ffffffffc020223e:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202240:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0202244:	fc86                	sd	ra,120(sp)
ffffffffc0202246:	f8a2                	sd	s0,112(sp)
ffffffffc0202248:	f4a6                	sd	s1,104(sp)
ffffffffc020224a:	f0ca                	sd	s2,96(sp)
ffffffffc020224c:	ecce                	sd	s3,88(sp)
ffffffffc020224e:	e8d2                	sd	s4,80(sp)
ffffffffc0202250:	e4d6                	sd	s5,72(sp)
ffffffffc0202252:	e0da                	sd	s6,64(sp)
ffffffffc0202254:	fc5e                	sd	s7,56(sp)
ffffffffc0202256:	f862                	sd	s8,48(sp)
ffffffffc0202258:	f466                	sd	s9,40(sp)
ffffffffc020225a:	f06a                	sd	s10,32(sp)
ffffffffc020225c:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020225e:	17d2                	slli	a5,a5,0x34
ffffffffc0202260:	20079a63          	bnez	a5,ffffffffc0202474 <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc0202264:	002007b7          	lui	a5,0x200
ffffffffc0202268:	24f5e463          	bltu	a1,a5,ffffffffc02024b0 <exit_range+0x272>
ffffffffc020226c:	8ab2                	mv	s5,a2
ffffffffc020226e:	24c5f163          	bgeu	a1,a2,ffffffffc02024b0 <exit_range+0x272>
ffffffffc0202272:	4785                	li	a5,1
ffffffffc0202274:	07fe                	slli	a5,a5,0x1f
ffffffffc0202276:	22c7ed63          	bltu	a5,a2,ffffffffc02024b0 <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc020227a:	c00009b7          	lui	s3,0xc0000
ffffffffc020227e:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202282:	ffe00937          	lui	s2,0xffe00
ffffffffc0202286:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc020228a:	5cfd                	li	s9,-1
ffffffffc020228c:	8c2a                	mv	s8,a0
ffffffffc020228e:	0125f933          	and	s2,a1,s2
ffffffffc0202292:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage)
ffffffffc0202294:	000c5d17          	auipc	s10,0xc5
ffffffffc0202298:	aa4d0d13          	addi	s10,s10,-1372 # ffffffffc02c6d38 <npage>
    return KADDR(page2pa(page));
ffffffffc020229c:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc02022a0:	000c5717          	auipc	a4,0xc5
ffffffffc02022a4:	aa070713          	addi	a4,a4,-1376 # ffffffffc02c6d40 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc02022a8:	000c5d97          	auipc	s11,0xc5
ffffffffc02022ac:	aa0d8d93          	addi	s11,s11,-1376 # ffffffffc02c6d48 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02022b0:	c0000437          	lui	s0,0xc0000
ffffffffc02022b4:	944e                	add	s0,s0,s3
ffffffffc02022b6:	8079                	srli	s0,s0,0x1e
ffffffffc02022b8:	1ff47413          	andi	s0,s0,511
ffffffffc02022bc:	040e                	slli	s0,s0,0x3
ffffffffc02022be:	9462                	add	s0,s0,s8
ffffffffc02022c0:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_matrix_out_size+0xffffffffbfff38d8>
        if (pde1 & PTE_V)
ffffffffc02022c4:	001a7793          	andi	a5,s4,1
ffffffffc02022c8:	eb99                	bnez	a5,ffffffffc02022de <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc02022ca:	12098463          	beqz	s3,ffffffffc02023f2 <exit_range+0x1b4>
ffffffffc02022ce:	400007b7          	lui	a5,0x40000
ffffffffc02022d2:	97ce                	add	a5,a5,s3
ffffffffc02022d4:	894e                	mv	s2,s3
ffffffffc02022d6:	1159fe63          	bgeu	s3,s5,ffffffffc02023f2 <exit_range+0x1b4>
ffffffffc02022da:	89be                	mv	s3,a5
ffffffffc02022dc:	bfd1                	j	ffffffffc02022b0 <exit_range+0x72>
    if (PPN(pa) >= npage)
ffffffffc02022de:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02022e2:	0a0a                	slli	s4,s4,0x2
ffffffffc02022e4:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage)
ffffffffc02022e8:	1cfa7263          	bgeu	s4,a5,ffffffffc02024ac <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02022ec:	fff80637          	lui	a2,0xfff80
ffffffffc02022f0:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc02022f2:	000806b7          	lui	a3,0x80
ffffffffc02022f6:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc02022f8:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc02022fc:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02022fe:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202300:	18f5fa63          	bgeu	a1,a5,ffffffffc0202494 <exit_range+0x256>
ffffffffc0202304:	000c5817          	auipc	a6,0xc5
ffffffffc0202308:	a4c80813          	addi	a6,a6,-1460 # ffffffffc02c6d50 <va_pa_offset>
ffffffffc020230c:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc0202310:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc0202312:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc0202316:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc0202318:	00080337          	lui	t1,0x80
ffffffffc020231c:	6885                	lui	a7,0x1
ffffffffc020231e:	a819                	j	ffffffffc0202334 <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc0202320:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc0202322:	002007b7          	lui	a5,0x200
ffffffffc0202326:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202328:	08090c63          	beqz	s2,ffffffffc02023c0 <exit_range+0x182>
ffffffffc020232c:	09397a63          	bgeu	s2,s3,ffffffffc02023c0 <exit_range+0x182>
ffffffffc0202330:	0f597063          	bgeu	s2,s5,ffffffffc0202410 <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0202334:	01595493          	srli	s1,s2,0x15
ffffffffc0202338:	1ff4f493          	andi	s1,s1,511
ffffffffc020233c:	048e                	slli	s1,s1,0x3
ffffffffc020233e:	94da                	add	s1,s1,s6
ffffffffc0202340:	609c                	ld	a5,0(s1)
                if (pde0 & PTE_V)
ffffffffc0202342:	0017f693          	andi	a3,a5,1
ffffffffc0202346:	dee9                	beqz	a3,ffffffffc0202320 <exit_range+0xe2>
    if (PPN(pa) >= npage)
ffffffffc0202348:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc020234c:	078a                	slli	a5,a5,0x2
ffffffffc020234e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202350:	14b7fe63          	bgeu	a5,a1,ffffffffc02024ac <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202354:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc0202356:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc020235a:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc020235e:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202362:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202364:	12bef863          	bgeu	t4,a1,ffffffffc0202494 <exit_range+0x256>
ffffffffc0202368:	00083783          	ld	a5,0(a6)
ffffffffc020236c:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc020236e:	011685b3          	add	a1,a3,a7
                        if (pt[i] & PTE_V)
ffffffffc0202372:	629c                	ld	a5,0(a3)
ffffffffc0202374:	8b85                	andi	a5,a5,1
ffffffffc0202376:	f7d5                	bnez	a5,ffffffffc0202322 <exit_range+0xe4>
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc0202378:	06a1                	addi	a3,a3,8
ffffffffc020237a:	fed59ce3          	bne	a1,a3,ffffffffc0202372 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc020237e:	631c                	ld	a5,0(a4)
ffffffffc0202380:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202382:	100027f3          	csrr	a5,sstatus
ffffffffc0202386:	8b89                	andi	a5,a5,2
ffffffffc0202388:	e7d9                	bnez	a5,ffffffffc0202416 <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc020238a:	000db783          	ld	a5,0(s11)
ffffffffc020238e:	4585                	li	a1,1
ffffffffc0202390:	e032                	sd	a2,0(sp)
ffffffffc0202392:	739c                	ld	a5,32(a5)
ffffffffc0202394:	9782                	jalr	a5
    if (flag)
ffffffffc0202396:	6602                	ld	a2,0(sp)
ffffffffc0202398:	000c5817          	auipc	a6,0xc5
ffffffffc020239c:	9b880813          	addi	a6,a6,-1608 # ffffffffc02c6d50 <va_pa_offset>
ffffffffc02023a0:	fff80e37          	lui	t3,0xfff80
ffffffffc02023a4:	00080337          	lui	t1,0x80
ffffffffc02023a8:	6885                	lui	a7,0x1
ffffffffc02023aa:	000c5717          	auipc	a4,0xc5
ffffffffc02023ae:	99670713          	addi	a4,a4,-1642 # ffffffffc02c6d40 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc02023b2:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc02023b6:	002007b7          	lui	a5,0x200
ffffffffc02023ba:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc02023bc:	f60918e3          	bnez	s2,ffffffffc020232c <exit_range+0xee>
            if (free_pd0)
ffffffffc02023c0:	f00b85e3          	beqz	s7,ffffffffc02022ca <exit_range+0x8c>
    if (PPN(pa) >= npage)
ffffffffc02023c4:	000d3783          	ld	a5,0(s10)
ffffffffc02023c8:	0efa7263          	bgeu	s4,a5,ffffffffc02024ac <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02023cc:	6308                	ld	a0,0(a4)
ffffffffc02023ce:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02023d0:	100027f3          	csrr	a5,sstatus
ffffffffc02023d4:	8b89                	andi	a5,a5,2
ffffffffc02023d6:	efad                	bnez	a5,ffffffffc0202450 <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc02023d8:	000db783          	ld	a5,0(s11)
ffffffffc02023dc:	4585                	li	a1,1
ffffffffc02023de:	739c                	ld	a5,32(a5)
ffffffffc02023e0:	9782                	jalr	a5
ffffffffc02023e2:	000c5717          	auipc	a4,0xc5
ffffffffc02023e6:	95e70713          	addi	a4,a4,-1698 # ffffffffc02c6d40 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc02023ea:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc02023ee:	ee0990e3          	bnez	s3,ffffffffc02022ce <exit_range+0x90>
}
ffffffffc02023f2:	70e6                	ld	ra,120(sp)
ffffffffc02023f4:	7446                	ld	s0,112(sp)
ffffffffc02023f6:	74a6                	ld	s1,104(sp)
ffffffffc02023f8:	7906                	ld	s2,96(sp)
ffffffffc02023fa:	69e6                	ld	s3,88(sp)
ffffffffc02023fc:	6a46                	ld	s4,80(sp)
ffffffffc02023fe:	6aa6                	ld	s5,72(sp)
ffffffffc0202400:	6b06                	ld	s6,64(sp)
ffffffffc0202402:	7be2                	ld	s7,56(sp)
ffffffffc0202404:	7c42                	ld	s8,48(sp)
ffffffffc0202406:	7ca2                	ld	s9,40(sp)
ffffffffc0202408:	7d02                	ld	s10,32(sp)
ffffffffc020240a:	6de2                	ld	s11,24(sp)
ffffffffc020240c:	6109                	addi	sp,sp,128
ffffffffc020240e:	8082                	ret
            if (free_pd0)
ffffffffc0202410:	ea0b8fe3          	beqz	s7,ffffffffc02022ce <exit_range+0x90>
ffffffffc0202414:	bf45                	j	ffffffffc02023c4 <exit_range+0x186>
ffffffffc0202416:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc0202418:	e42a                	sd	a0,8(sp)
ffffffffc020241a:	d94fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020241e:	000db783          	ld	a5,0(s11)
ffffffffc0202422:	6522                	ld	a0,8(sp)
ffffffffc0202424:	4585                	li	a1,1
ffffffffc0202426:	739c                	ld	a5,32(a5)
ffffffffc0202428:	9782                	jalr	a5
        intr_enable();
ffffffffc020242a:	d7efe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc020242e:	6602                	ld	a2,0(sp)
ffffffffc0202430:	000c5717          	auipc	a4,0xc5
ffffffffc0202434:	91070713          	addi	a4,a4,-1776 # ffffffffc02c6d40 <pages>
ffffffffc0202438:	6885                	lui	a7,0x1
ffffffffc020243a:	00080337          	lui	t1,0x80
ffffffffc020243e:	fff80e37          	lui	t3,0xfff80
ffffffffc0202442:	000c5817          	auipc	a6,0xc5
ffffffffc0202446:	90e80813          	addi	a6,a6,-1778 # ffffffffc02c6d50 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc020244a:	0004b023          	sd	zero,0(s1)
ffffffffc020244e:	b7a5                	j	ffffffffc02023b6 <exit_range+0x178>
ffffffffc0202450:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0202452:	d5cfe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202456:	000db783          	ld	a5,0(s11)
ffffffffc020245a:	6502                	ld	a0,0(sp)
ffffffffc020245c:	4585                	li	a1,1
ffffffffc020245e:	739c                	ld	a5,32(a5)
ffffffffc0202460:	9782                	jalr	a5
        intr_enable();
ffffffffc0202462:	d46fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202466:	000c5717          	auipc	a4,0xc5
ffffffffc020246a:	8da70713          	addi	a4,a4,-1830 # ffffffffc02c6d40 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc020246e:	00043023          	sd	zero,0(s0)
ffffffffc0202472:	bfb5                	j	ffffffffc02023ee <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202474:	00004697          	auipc	a3,0x4
ffffffffc0202478:	39c68693          	addi	a3,a3,924 # ffffffffc0206810 <default_pmm_manager+0x160>
ffffffffc020247c:	00004617          	auipc	a2,0x4
ffffffffc0202480:	e8460613          	addi	a2,a2,-380 # ffffffffc0206300 <commands+0x850>
ffffffffc0202484:	13700593          	li	a1,311
ffffffffc0202488:	00004517          	auipc	a0,0x4
ffffffffc020248c:	37850513          	addi	a0,a0,888 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202490:	802fe0ef          	jal	ra,ffffffffc0200492 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202494:	00004617          	auipc	a2,0x4
ffffffffc0202498:	25460613          	addi	a2,a2,596 # ffffffffc02066e8 <default_pmm_manager+0x38>
ffffffffc020249c:	07100593          	li	a1,113
ffffffffc02024a0:	00004517          	auipc	a0,0x4
ffffffffc02024a4:	27050513          	addi	a0,a0,624 # ffffffffc0206710 <default_pmm_manager+0x60>
ffffffffc02024a8:	febfd0ef          	jal	ra,ffffffffc0200492 <__panic>
ffffffffc02024ac:	8e1ff0ef          	jal	ra,ffffffffc0201d8c <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc02024b0:	00004697          	auipc	a3,0x4
ffffffffc02024b4:	39068693          	addi	a3,a3,912 # ffffffffc0206840 <default_pmm_manager+0x190>
ffffffffc02024b8:	00004617          	auipc	a2,0x4
ffffffffc02024bc:	e4860613          	addi	a2,a2,-440 # ffffffffc0206300 <commands+0x850>
ffffffffc02024c0:	13800593          	li	a1,312
ffffffffc02024c4:	00004517          	auipc	a0,0x4
ffffffffc02024c8:	33c50513          	addi	a0,a0,828 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc02024cc:	fc7fd0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02024d0 <page_remove>:
{
ffffffffc02024d0:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02024d2:	4601                	li	a2,0
{
ffffffffc02024d4:	ec26                	sd	s1,24(sp)
ffffffffc02024d6:	f406                	sd	ra,40(sp)
ffffffffc02024d8:	f022                	sd	s0,32(sp)
ffffffffc02024da:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02024dc:	9a1ff0ef          	jal	ra,ffffffffc0201e7c <get_pte>
    if (ptep != NULL)
ffffffffc02024e0:	c511                	beqz	a0,ffffffffc02024ec <page_remove+0x1c>
    if (*ptep & PTE_V)
ffffffffc02024e2:	611c                	ld	a5,0(a0)
ffffffffc02024e4:	842a                	mv	s0,a0
ffffffffc02024e6:	0017f713          	andi	a4,a5,1
ffffffffc02024ea:	e711                	bnez	a4,ffffffffc02024f6 <page_remove+0x26>
}
ffffffffc02024ec:	70a2                	ld	ra,40(sp)
ffffffffc02024ee:	7402                	ld	s0,32(sp)
ffffffffc02024f0:	64e2                	ld	s1,24(sp)
ffffffffc02024f2:	6145                	addi	sp,sp,48
ffffffffc02024f4:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02024f6:	078a                	slli	a5,a5,0x2
ffffffffc02024f8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02024fa:	000c5717          	auipc	a4,0xc5
ffffffffc02024fe:	83e73703          	ld	a4,-1986(a4) # ffffffffc02c6d38 <npage>
ffffffffc0202502:	06e7f363          	bgeu	a5,a4,ffffffffc0202568 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0202506:	fff80537          	lui	a0,0xfff80
ffffffffc020250a:	97aa                	add	a5,a5,a0
ffffffffc020250c:	079a                	slli	a5,a5,0x6
ffffffffc020250e:	000c5517          	auipc	a0,0xc5
ffffffffc0202512:	83253503          	ld	a0,-1998(a0) # ffffffffc02c6d40 <pages>
ffffffffc0202516:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202518:	411c                	lw	a5,0(a0)
ffffffffc020251a:	fff7871b          	addiw	a4,a5,-1
ffffffffc020251e:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202520:	cb11                	beqz	a4,ffffffffc0202534 <page_remove+0x64>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc0202522:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202526:	12048073          	sfence.vma	s1
}
ffffffffc020252a:	70a2                	ld	ra,40(sp)
ffffffffc020252c:	7402                	ld	s0,32(sp)
ffffffffc020252e:	64e2                	ld	s1,24(sp)
ffffffffc0202530:	6145                	addi	sp,sp,48
ffffffffc0202532:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202534:	100027f3          	csrr	a5,sstatus
ffffffffc0202538:	8b89                	andi	a5,a5,2
ffffffffc020253a:	eb89                	bnez	a5,ffffffffc020254c <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc020253c:	000c5797          	auipc	a5,0xc5
ffffffffc0202540:	80c7b783          	ld	a5,-2036(a5) # ffffffffc02c6d48 <pmm_manager>
ffffffffc0202544:	739c                	ld	a5,32(a5)
ffffffffc0202546:	4585                	li	a1,1
ffffffffc0202548:	9782                	jalr	a5
    if (flag)
ffffffffc020254a:	bfe1                	j	ffffffffc0202522 <page_remove+0x52>
        intr_disable();
ffffffffc020254c:	e42a                	sd	a0,8(sp)
ffffffffc020254e:	c60fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc0202552:	000c4797          	auipc	a5,0xc4
ffffffffc0202556:	7f67b783          	ld	a5,2038(a5) # ffffffffc02c6d48 <pmm_manager>
ffffffffc020255a:	739c                	ld	a5,32(a5)
ffffffffc020255c:	6522                	ld	a0,8(sp)
ffffffffc020255e:	4585                	li	a1,1
ffffffffc0202560:	9782                	jalr	a5
        intr_enable();
ffffffffc0202562:	c46fe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202566:	bf75                	j	ffffffffc0202522 <page_remove+0x52>
ffffffffc0202568:	825ff0ef          	jal	ra,ffffffffc0201d8c <pa2page.part.0>

ffffffffc020256c <page_insert>:
{
ffffffffc020256c:	7139                	addi	sp,sp,-64
ffffffffc020256e:	e852                	sd	s4,16(sp)
ffffffffc0202570:	8a32                	mv	s4,a2
ffffffffc0202572:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202574:	4605                	li	a2,1
{
ffffffffc0202576:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202578:	85d2                	mv	a1,s4
{
ffffffffc020257a:	f426                	sd	s1,40(sp)
ffffffffc020257c:	fc06                	sd	ra,56(sp)
ffffffffc020257e:	f04a                	sd	s2,32(sp)
ffffffffc0202580:	ec4e                	sd	s3,24(sp)
ffffffffc0202582:	e456                	sd	s5,8(sp)
ffffffffc0202584:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202586:	8f7ff0ef          	jal	ra,ffffffffc0201e7c <get_pte>
    if (ptep == NULL)
ffffffffc020258a:	c961                	beqz	a0,ffffffffc020265a <page_insert+0xee>
    page->ref += 1;
ffffffffc020258c:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V)
ffffffffc020258e:	611c                	ld	a5,0(a0)
ffffffffc0202590:	89aa                	mv	s3,a0
ffffffffc0202592:	0016871b          	addiw	a4,a3,1
ffffffffc0202596:	c018                	sw	a4,0(s0)
ffffffffc0202598:	0017f713          	andi	a4,a5,1
ffffffffc020259c:	ef05                	bnez	a4,ffffffffc02025d4 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc020259e:	000c4717          	auipc	a4,0xc4
ffffffffc02025a2:	7a273703          	ld	a4,1954(a4) # ffffffffc02c6d40 <pages>
ffffffffc02025a6:	8c19                	sub	s0,s0,a4
ffffffffc02025a8:	000807b7          	lui	a5,0x80
ffffffffc02025ac:	8419                	srai	s0,s0,0x6
ffffffffc02025ae:	943e                	add	s0,s0,a5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02025b0:	042a                	slli	s0,s0,0xa
ffffffffc02025b2:	8cc1                	or	s1,s1,s0
ffffffffc02025b4:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02025b8:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_matrix_out_size+0xffffffffbfff38d8>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025bc:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc02025c0:	4501                	li	a0,0
}
ffffffffc02025c2:	70e2                	ld	ra,56(sp)
ffffffffc02025c4:	7442                	ld	s0,48(sp)
ffffffffc02025c6:	74a2                	ld	s1,40(sp)
ffffffffc02025c8:	7902                	ld	s2,32(sp)
ffffffffc02025ca:	69e2                	ld	s3,24(sp)
ffffffffc02025cc:	6a42                	ld	s4,16(sp)
ffffffffc02025ce:	6aa2                	ld	s5,8(sp)
ffffffffc02025d0:	6121                	addi	sp,sp,64
ffffffffc02025d2:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02025d4:	078a                	slli	a5,a5,0x2
ffffffffc02025d6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02025d8:	000c4717          	auipc	a4,0xc4
ffffffffc02025dc:	76073703          	ld	a4,1888(a4) # ffffffffc02c6d38 <npage>
ffffffffc02025e0:	06e7ff63          	bgeu	a5,a4,ffffffffc020265e <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc02025e4:	000c4a97          	auipc	s5,0xc4
ffffffffc02025e8:	75ca8a93          	addi	s5,s5,1884 # ffffffffc02c6d40 <pages>
ffffffffc02025ec:	000ab703          	ld	a4,0(s5)
ffffffffc02025f0:	fff80937          	lui	s2,0xfff80
ffffffffc02025f4:	993e                	add	s2,s2,a5
ffffffffc02025f6:	091a                	slli	s2,s2,0x6
ffffffffc02025f8:	993a                	add	s2,s2,a4
        if (p == page)
ffffffffc02025fa:	01240c63          	beq	s0,s2,ffffffffc0202612 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc02025fe:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fcb9278>
ffffffffc0202602:	fff7869b          	addiw	a3,a5,-1
ffffffffc0202606:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc020260a:	c691                	beqz	a3,ffffffffc0202616 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020260c:	120a0073          	sfence.vma	s4
}
ffffffffc0202610:	bf59                	j	ffffffffc02025a6 <page_insert+0x3a>
ffffffffc0202612:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202614:	bf49                	j	ffffffffc02025a6 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202616:	100027f3          	csrr	a5,sstatus
ffffffffc020261a:	8b89                	andi	a5,a5,2
ffffffffc020261c:	ef91                	bnez	a5,ffffffffc0202638 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc020261e:	000c4797          	auipc	a5,0xc4
ffffffffc0202622:	72a7b783          	ld	a5,1834(a5) # ffffffffc02c6d48 <pmm_manager>
ffffffffc0202626:	739c                	ld	a5,32(a5)
ffffffffc0202628:	4585                	li	a1,1
ffffffffc020262a:	854a                	mv	a0,s2
ffffffffc020262c:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc020262e:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202632:	120a0073          	sfence.vma	s4
ffffffffc0202636:	bf85                	j	ffffffffc02025a6 <page_insert+0x3a>
        intr_disable();
ffffffffc0202638:	b76fe0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020263c:	000c4797          	auipc	a5,0xc4
ffffffffc0202640:	70c7b783          	ld	a5,1804(a5) # ffffffffc02c6d48 <pmm_manager>
ffffffffc0202644:	739c                	ld	a5,32(a5)
ffffffffc0202646:	4585                	li	a1,1
ffffffffc0202648:	854a                	mv	a0,s2
ffffffffc020264a:	9782                	jalr	a5
        intr_enable();
ffffffffc020264c:	b5cfe0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202650:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202654:	120a0073          	sfence.vma	s4
ffffffffc0202658:	b7b9                	j	ffffffffc02025a6 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc020265a:	5571                	li	a0,-4
ffffffffc020265c:	b79d                	j	ffffffffc02025c2 <page_insert+0x56>
ffffffffc020265e:	f2eff0ef          	jal	ra,ffffffffc0201d8c <pa2page.part.0>

ffffffffc0202662 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202662:	00004797          	auipc	a5,0x4
ffffffffc0202666:	04e78793          	addi	a5,a5,78 # ffffffffc02066b0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020266a:	638c                	ld	a1,0(a5)
{
ffffffffc020266c:	7159                	addi	sp,sp,-112
ffffffffc020266e:	f85a                	sd	s6,48(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202670:	00004517          	auipc	a0,0x4
ffffffffc0202674:	1e850513          	addi	a0,a0,488 # ffffffffc0206858 <default_pmm_manager+0x1a8>
    pmm_manager = &default_pmm_manager;
ffffffffc0202678:	000c4b17          	auipc	s6,0xc4
ffffffffc020267c:	6d0b0b13          	addi	s6,s6,1744 # ffffffffc02c6d48 <pmm_manager>
{
ffffffffc0202680:	f486                	sd	ra,104(sp)
ffffffffc0202682:	e8ca                	sd	s2,80(sp)
ffffffffc0202684:	e4ce                	sd	s3,72(sp)
ffffffffc0202686:	f0a2                	sd	s0,96(sp)
ffffffffc0202688:	eca6                	sd	s1,88(sp)
ffffffffc020268a:	e0d2                	sd	s4,64(sp)
ffffffffc020268c:	fc56                	sd	s5,56(sp)
ffffffffc020268e:	f45e                	sd	s7,40(sp)
ffffffffc0202690:	f062                	sd	s8,32(sp)
ffffffffc0202692:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202694:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202698:	b01fd0ef          	jal	ra,ffffffffc0200198 <cprintf>
    pmm_manager->init();
ffffffffc020269c:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02026a0:	000c4997          	auipc	s3,0xc4
ffffffffc02026a4:	6b098993          	addi	s3,s3,1712 # ffffffffc02c6d50 <va_pa_offset>
    pmm_manager->init();
ffffffffc02026a8:	679c                	ld	a5,8(a5)
ffffffffc02026aa:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02026ac:	57f5                	li	a5,-3
ffffffffc02026ae:	07fa                	slli	a5,a5,0x1e
ffffffffc02026b0:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc02026b4:	ae0fe0ef          	jal	ra,ffffffffc0200994 <get_memory_base>
ffffffffc02026b8:	892a                	mv	s2,a0
    uint64_t mem_size = get_memory_size();
ffffffffc02026ba:	ae4fe0ef          	jal	ra,ffffffffc020099e <get_memory_size>
    if (mem_size == 0)
ffffffffc02026be:	200505e3          	beqz	a0,ffffffffc02030c8 <pmm_init+0xa66>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc02026c2:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc02026c4:	00004517          	auipc	a0,0x4
ffffffffc02026c8:	1cc50513          	addi	a0,a0,460 # ffffffffc0206890 <default_pmm_manager+0x1e0>
ffffffffc02026cc:	acdfd0ef          	jal	ra,ffffffffc0200198 <cprintf>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc02026d0:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02026d4:	fff40693          	addi	a3,s0,-1
ffffffffc02026d8:	864a                	mv	a2,s2
ffffffffc02026da:	85a6                	mv	a1,s1
ffffffffc02026dc:	00004517          	auipc	a0,0x4
ffffffffc02026e0:	1cc50513          	addi	a0,a0,460 # ffffffffc02068a8 <default_pmm_manager+0x1f8>
ffffffffc02026e4:	ab5fd0ef          	jal	ra,ffffffffc0200198 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc02026e8:	c8000737          	lui	a4,0xc8000
ffffffffc02026ec:	87a2                	mv	a5,s0
ffffffffc02026ee:	54876163          	bltu	a4,s0,ffffffffc0202c30 <pmm_init+0x5ce>
ffffffffc02026f2:	757d                	lui	a0,0xfffff
ffffffffc02026f4:	000c5617          	auipc	a2,0xc5
ffffffffc02026f8:	69360613          	addi	a2,a2,1683 # ffffffffc02c7d87 <end+0xfff>
ffffffffc02026fc:	8e69                	and	a2,a2,a0
ffffffffc02026fe:	000c4497          	auipc	s1,0xc4
ffffffffc0202702:	63a48493          	addi	s1,s1,1594 # ffffffffc02c6d38 <npage>
ffffffffc0202706:	00c7d513          	srli	a0,a5,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020270a:	000c4b97          	auipc	s7,0xc4
ffffffffc020270e:	636b8b93          	addi	s7,s7,1590 # ffffffffc02c6d40 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0202712:	e088                	sd	a0,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202714:	00cbb023          	sd	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202718:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020271c:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc020271e:	02f50863          	beq	a0,a5,ffffffffc020274e <pmm_init+0xec>
ffffffffc0202722:	4781                	li	a5,0
ffffffffc0202724:	4585                	li	a1,1
ffffffffc0202726:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc020272a:	00679513          	slli	a0,a5,0x6
ffffffffc020272e:	9532                	add	a0,a0,a2
ffffffffc0202730:	00850713          	addi	a4,a0,8 # fffffffffffff008 <end+0x3fd38280>
ffffffffc0202734:	40b7302f          	amoor.d	zero,a1,(a4)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202738:	6088                	ld	a0,0(s1)
ffffffffc020273a:	0785                	addi	a5,a5,1
        SetPageReserved(pages + i);
ffffffffc020273c:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202740:	00d50733          	add	a4,a0,a3
ffffffffc0202744:	fee7e3e3          	bltu	a5,a4,ffffffffc020272a <pmm_init+0xc8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202748:	071a                	slli	a4,a4,0x6
ffffffffc020274a:	00e606b3          	add	a3,a2,a4
ffffffffc020274e:	c02007b7          	lui	a5,0xc0200
ffffffffc0202752:	2ef6ece3          	bltu	a3,a5,ffffffffc020324a <pmm_init+0xbe8>
ffffffffc0202756:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc020275a:	77fd                	lui	a5,0xfffff
ffffffffc020275c:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020275e:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc0202760:	5086eb63          	bltu	a3,s0,ffffffffc0202c76 <pmm_init+0x614>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202764:	00004517          	auipc	a0,0x4
ffffffffc0202768:	16c50513          	addi	a0,a0,364 # ffffffffc02068d0 <default_pmm_manager+0x220>
ffffffffc020276c:	a2dfd0ef          	jal	ra,ffffffffc0200198 <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc0202770:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0202774:	000c4917          	auipc	s2,0xc4
ffffffffc0202778:	5bc90913          	addi	s2,s2,1468 # ffffffffc02c6d30 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc020277c:	7b9c                	ld	a5,48(a5)
ffffffffc020277e:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202780:	00004517          	auipc	a0,0x4
ffffffffc0202784:	16850513          	addi	a0,a0,360 # ffffffffc02068e8 <default_pmm_manager+0x238>
ffffffffc0202788:	a11fd0ef          	jal	ra,ffffffffc0200198 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc020278c:	00009697          	auipc	a3,0x9
ffffffffc0202790:	87468693          	addi	a3,a3,-1932 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0202794:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0202798:	c02007b7          	lui	a5,0xc0200
ffffffffc020279c:	28f6ebe3          	bltu	a3,a5,ffffffffc0203232 <pmm_init+0xbd0>
ffffffffc02027a0:	0009b783          	ld	a5,0(s3)
ffffffffc02027a4:	8e9d                	sub	a3,a3,a5
ffffffffc02027a6:	000c4797          	auipc	a5,0xc4
ffffffffc02027aa:	58d7b123          	sd	a3,1410(a5) # ffffffffc02c6d28 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02027ae:	100027f3          	csrr	a5,sstatus
ffffffffc02027b2:	8b89                	andi	a5,a5,2
ffffffffc02027b4:	4a079763          	bnez	a5,ffffffffc0202c62 <pmm_init+0x600>
        ret = pmm_manager->nr_free_pages();
ffffffffc02027b8:	000b3783          	ld	a5,0(s6)
ffffffffc02027bc:	779c                	ld	a5,40(a5)
ffffffffc02027be:	9782                	jalr	a5
ffffffffc02027c0:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02027c2:	6098                	ld	a4,0(s1)
ffffffffc02027c4:	c80007b7          	lui	a5,0xc8000
ffffffffc02027c8:	83b1                	srli	a5,a5,0xc
ffffffffc02027ca:	66e7e363          	bltu	a5,a4,ffffffffc0202e30 <pmm_init+0x7ce>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc02027ce:	00093503          	ld	a0,0(s2)
ffffffffc02027d2:	62050f63          	beqz	a0,ffffffffc0202e10 <pmm_init+0x7ae>
ffffffffc02027d6:	03451793          	slli	a5,a0,0x34
ffffffffc02027da:	62079b63          	bnez	a5,ffffffffc0202e10 <pmm_init+0x7ae>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc02027de:	4601                	li	a2,0
ffffffffc02027e0:	4581                	li	a1,0
ffffffffc02027e2:	8c3ff0ef          	jal	ra,ffffffffc02020a4 <get_page>
ffffffffc02027e6:	60051563          	bnez	a0,ffffffffc0202df0 <pmm_init+0x78e>
ffffffffc02027ea:	100027f3          	csrr	a5,sstatus
ffffffffc02027ee:	8b89                	andi	a5,a5,2
ffffffffc02027f0:	44079e63          	bnez	a5,ffffffffc0202c4c <pmm_init+0x5ea>
        page = pmm_manager->alloc_pages(n);
ffffffffc02027f4:	000b3783          	ld	a5,0(s6)
ffffffffc02027f8:	4505                	li	a0,1
ffffffffc02027fa:	6f9c                	ld	a5,24(a5)
ffffffffc02027fc:	9782                	jalr	a5
ffffffffc02027fe:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0202800:	00093503          	ld	a0,0(s2)
ffffffffc0202804:	4681                	li	a3,0
ffffffffc0202806:	4601                	li	a2,0
ffffffffc0202808:	85d2                	mv	a1,s4
ffffffffc020280a:	d63ff0ef          	jal	ra,ffffffffc020256c <page_insert>
ffffffffc020280e:	26051ae3          	bnez	a0,ffffffffc0203282 <pmm_init+0xc20>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0202812:	00093503          	ld	a0,0(s2)
ffffffffc0202816:	4601                	li	a2,0
ffffffffc0202818:	4581                	li	a1,0
ffffffffc020281a:	e62ff0ef          	jal	ra,ffffffffc0201e7c <get_pte>
ffffffffc020281e:	240502e3          	beqz	a0,ffffffffc0203262 <pmm_init+0xc00>
    assert(pte2page(*ptep) == p1);
ffffffffc0202822:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202824:	0017f713          	andi	a4,a5,1
ffffffffc0202828:	5a070263          	beqz	a4,ffffffffc0202dcc <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc020282c:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020282e:	078a                	slli	a5,a5,0x2
ffffffffc0202830:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202832:	58e7fb63          	bgeu	a5,a4,ffffffffc0202dc8 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202836:	000bb683          	ld	a3,0(s7)
ffffffffc020283a:	fff80637          	lui	a2,0xfff80
ffffffffc020283e:	97b2                	add	a5,a5,a2
ffffffffc0202840:	079a                	slli	a5,a5,0x6
ffffffffc0202842:	97b6                	add	a5,a5,a3
ffffffffc0202844:	14fa17e3          	bne	s4,a5,ffffffffc0203192 <pmm_init+0xb30>
    assert(page_ref(p1) == 1);
ffffffffc0202848:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8f50>
ffffffffc020284c:	4785                	li	a5,1
ffffffffc020284e:	12f692e3          	bne	a3,a5,ffffffffc0203172 <pmm_init+0xb10>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0202852:	00093503          	ld	a0,0(s2)
ffffffffc0202856:	77fd                	lui	a5,0xfffff
ffffffffc0202858:	6114                	ld	a3,0(a0)
ffffffffc020285a:	068a                	slli	a3,a3,0x2
ffffffffc020285c:	8efd                	and	a3,a3,a5
ffffffffc020285e:	00c6d613          	srli	a2,a3,0xc
ffffffffc0202862:	0ee67ce3          	bgeu	a2,a4,ffffffffc020315a <pmm_init+0xaf8>
ffffffffc0202866:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020286a:	96e2                	add	a3,a3,s8
ffffffffc020286c:	0006ba83          	ld	s5,0(a3)
ffffffffc0202870:	0a8a                	slli	s5,s5,0x2
ffffffffc0202872:	00fafab3          	and	s5,s5,a5
ffffffffc0202876:	00cad793          	srli	a5,s5,0xc
ffffffffc020287a:	0ce7f3e3          	bgeu	a5,a4,ffffffffc0203140 <pmm_init+0xade>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc020287e:	4601                	li	a2,0
ffffffffc0202880:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202882:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202884:	df8ff0ef          	jal	ra,ffffffffc0201e7c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202888:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc020288a:	55551363          	bne	a0,s5,ffffffffc0202dd0 <pmm_init+0x76e>
ffffffffc020288e:	100027f3          	csrr	a5,sstatus
ffffffffc0202892:	8b89                	andi	a5,a5,2
ffffffffc0202894:	3a079163          	bnez	a5,ffffffffc0202c36 <pmm_init+0x5d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202898:	000b3783          	ld	a5,0(s6)
ffffffffc020289c:	4505                	li	a0,1
ffffffffc020289e:	6f9c                	ld	a5,24(a5)
ffffffffc02028a0:	9782                	jalr	a5
ffffffffc02028a2:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02028a4:	00093503          	ld	a0,0(s2)
ffffffffc02028a8:	46d1                	li	a3,20
ffffffffc02028aa:	6605                	lui	a2,0x1
ffffffffc02028ac:	85e2                	mv	a1,s8
ffffffffc02028ae:	cbfff0ef          	jal	ra,ffffffffc020256c <page_insert>
ffffffffc02028b2:	060517e3          	bnez	a0,ffffffffc0203120 <pmm_init+0xabe>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02028b6:	00093503          	ld	a0,0(s2)
ffffffffc02028ba:	4601                	li	a2,0
ffffffffc02028bc:	6585                	lui	a1,0x1
ffffffffc02028be:	dbeff0ef          	jal	ra,ffffffffc0201e7c <get_pte>
ffffffffc02028c2:	02050fe3          	beqz	a0,ffffffffc0203100 <pmm_init+0xa9e>
    assert(*ptep & PTE_U);
ffffffffc02028c6:	611c                	ld	a5,0(a0)
ffffffffc02028c8:	0107f713          	andi	a4,a5,16
ffffffffc02028cc:	7c070e63          	beqz	a4,ffffffffc02030a8 <pmm_init+0xa46>
    assert(*ptep & PTE_W);
ffffffffc02028d0:	8b91                	andi	a5,a5,4
ffffffffc02028d2:	7a078b63          	beqz	a5,ffffffffc0203088 <pmm_init+0xa26>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc02028d6:	00093503          	ld	a0,0(s2)
ffffffffc02028da:	611c                	ld	a5,0(a0)
ffffffffc02028dc:	8bc1                	andi	a5,a5,16
ffffffffc02028de:	78078563          	beqz	a5,ffffffffc0203068 <pmm_init+0xa06>
    assert(page_ref(p2) == 1);
ffffffffc02028e2:	000c2703          	lw	a4,0(s8)
ffffffffc02028e6:	4785                	li	a5,1
ffffffffc02028e8:	76f71063          	bne	a4,a5,ffffffffc0203048 <pmm_init+0x9e6>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc02028ec:	4681                	li	a3,0
ffffffffc02028ee:	6605                	lui	a2,0x1
ffffffffc02028f0:	85d2                	mv	a1,s4
ffffffffc02028f2:	c7bff0ef          	jal	ra,ffffffffc020256c <page_insert>
ffffffffc02028f6:	72051963          	bnez	a0,ffffffffc0203028 <pmm_init+0x9c6>
    assert(page_ref(p1) == 2);
ffffffffc02028fa:	000a2703          	lw	a4,0(s4)
ffffffffc02028fe:	4789                	li	a5,2
ffffffffc0202900:	70f71463          	bne	a4,a5,ffffffffc0203008 <pmm_init+0x9a6>
    assert(page_ref(p2) == 0);
ffffffffc0202904:	000c2783          	lw	a5,0(s8)
ffffffffc0202908:	6e079063          	bnez	a5,ffffffffc0202fe8 <pmm_init+0x986>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc020290c:	00093503          	ld	a0,0(s2)
ffffffffc0202910:	4601                	li	a2,0
ffffffffc0202912:	6585                	lui	a1,0x1
ffffffffc0202914:	d68ff0ef          	jal	ra,ffffffffc0201e7c <get_pte>
ffffffffc0202918:	6a050863          	beqz	a0,ffffffffc0202fc8 <pmm_init+0x966>
    assert(pte2page(*ptep) == p1);
ffffffffc020291c:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc020291e:	00177793          	andi	a5,a4,1
ffffffffc0202922:	4a078563          	beqz	a5,ffffffffc0202dcc <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc0202926:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202928:	00271793          	slli	a5,a4,0x2
ffffffffc020292c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020292e:	48d7fd63          	bgeu	a5,a3,ffffffffc0202dc8 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202932:	000bb683          	ld	a3,0(s7)
ffffffffc0202936:	fff80ab7          	lui	s5,0xfff80
ffffffffc020293a:	97d6                	add	a5,a5,s5
ffffffffc020293c:	079a                	slli	a5,a5,0x6
ffffffffc020293e:	97b6                	add	a5,a5,a3
ffffffffc0202940:	66fa1463          	bne	s4,a5,ffffffffc0202fa8 <pmm_init+0x946>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202944:	8b41                	andi	a4,a4,16
ffffffffc0202946:	64071163          	bnez	a4,ffffffffc0202f88 <pmm_init+0x926>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc020294a:	00093503          	ld	a0,0(s2)
ffffffffc020294e:	4581                	li	a1,0
ffffffffc0202950:	b81ff0ef          	jal	ra,ffffffffc02024d0 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202954:	000a2c83          	lw	s9,0(s4)
ffffffffc0202958:	4785                	li	a5,1
ffffffffc020295a:	60fc9763          	bne	s9,a5,ffffffffc0202f68 <pmm_init+0x906>
    assert(page_ref(p2) == 0);
ffffffffc020295e:	000c2783          	lw	a5,0(s8)
ffffffffc0202962:	5e079363          	bnez	a5,ffffffffc0202f48 <pmm_init+0x8e6>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc0202966:	00093503          	ld	a0,0(s2)
ffffffffc020296a:	6585                	lui	a1,0x1
ffffffffc020296c:	b65ff0ef          	jal	ra,ffffffffc02024d0 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202970:	000a2783          	lw	a5,0(s4)
ffffffffc0202974:	52079a63          	bnez	a5,ffffffffc0202ea8 <pmm_init+0x846>
    assert(page_ref(p2) == 0);
ffffffffc0202978:	000c2783          	lw	a5,0(s8)
ffffffffc020297c:	50079663          	bnez	a5,ffffffffc0202e88 <pmm_init+0x826>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202980:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202984:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202986:	000a3683          	ld	a3,0(s4)
ffffffffc020298a:	068a                	slli	a3,a3,0x2
ffffffffc020298c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc020298e:	42b6fd63          	bgeu	a3,a1,ffffffffc0202dc8 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202992:	000bb503          	ld	a0,0(s7)
ffffffffc0202996:	96d6                	add	a3,a3,s5
ffffffffc0202998:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc020299a:	00d507b3          	add	a5,a0,a3
ffffffffc020299e:	439c                	lw	a5,0(a5)
ffffffffc02029a0:	4d979463          	bne	a5,s9,ffffffffc0202e68 <pmm_init+0x806>
    return page - pages + nbase;
ffffffffc02029a4:	8699                	srai	a3,a3,0x6
ffffffffc02029a6:	00080637          	lui	a2,0x80
ffffffffc02029aa:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc02029ac:	00c69713          	slli	a4,a3,0xc
ffffffffc02029b0:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02029b2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02029b4:	48b77e63          	bgeu	a4,a1,ffffffffc0202e50 <pmm_init+0x7ee>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02029b8:	0009b703          	ld	a4,0(s3)
ffffffffc02029bc:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc02029be:	629c                	ld	a5,0(a3)
ffffffffc02029c0:	078a                	slli	a5,a5,0x2
ffffffffc02029c2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02029c4:	40b7f263          	bgeu	a5,a1,ffffffffc0202dc8 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02029c8:	8f91                	sub	a5,a5,a2
ffffffffc02029ca:	079a                	slli	a5,a5,0x6
ffffffffc02029cc:	953e                	add	a0,a0,a5
ffffffffc02029ce:	100027f3          	csrr	a5,sstatus
ffffffffc02029d2:	8b89                	andi	a5,a5,2
ffffffffc02029d4:	30079963          	bnez	a5,ffffffffc0202ce6 <pmm_init+0x684>
        pmm_manager->free_pages(base, n);
ffffffffc02029d8:	000b3783          	ld	a5,0(s6)
ffffffffc02029dc:	4585                	li	a1,1
ffffffffc02029de:	739c                	ld	a5,32(a5)
ffffffffc02029e0:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02029e2:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc02029e6:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02029e8:	078a                	slli	a5,a5,0x2
ffffffffc02029ea:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02029ec:	3ce7fe63          	bgeu	a5,a4,ffffffffc0202dc8 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02029f0:	000bb503          	ld	a0,0(s7)
ffffffffc02029f4:	fff80737          	lui	a4,0xfff80
ffffffffc02029f8:	97ba                	add	a5,a5,a4
ffffffffc02029fa:	079a                	slli	a5,a5,0x6
ffffffffc02029fc:	953e                	add	a0,a0,a5
ffffffffc02029fe:	100027f3          	csrr	a5,sstatus
ffffffffc0202a02:	8b89                	andi	a5,a5,2
ffffffffc0202a04:	2c079563          	bnez	a5,ffffffffc0202cce <pmm_init+0x66c>
ffffffffc0202a08:	000b3783          	ld	a5,0(s6)
ffffffffc0202a0c:	4585                	li	a1,1
ffffffffc0202a0e:	739c                	ld	a5,32(a5)
ffffffffc0202a10:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202a12:	00093783          	ld	a5,0(s2)
ffffffffc0202a16:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd38278>
    asm volatile("sfence.vma");
ffffffffc0202a1a:	12000073          	sfence.vma
ffffffffc0202a1e:	100027f3          	csrr	a5,sstatus
ffffffffc0202a22:	8b89                	andi	a5,a5,2
ffffffffc0202a24:	28079b63          	bnez	a5,ffffffffc0202cba <pmm_init+0x658>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202a28:	000b3783          	ld	a5,0(s6)
ffffffffc0202a2c:	779c                	ld	a5,40(a5)
ffffffffc0202a2e:	9782                	jalr	a5
ffffffffc0202a30:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202a32:	4b441b63          	bne	s0,s4,ffffffffc0202ee8 <pmm_init+0x886>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202a36:	00004517          	auipc	a0,0x4
ffffffffc0202a3a:	1da50513          	addi	a0,a0,474 # ffffffffc0206c10 <default_pmm_manager+0x560>
ffffffffc0202a3e:	f5afd0ef          	jal	ra,ffffffffc0200198 <cprintf>
ffffffffc0202a42:	100027f3          	csrr	a5,sstatus
ffffffffc0202a46:	8b89                	andi	a5,a5,2
ffffffffc0202a48:	24079f63          	bnez	a5,ffffffffc0202ca6 <pmm_init+0x644>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202a4c:	000b3783          	ld	a5,0(s6)
ffffffffc0202a50:	779c                	ld	a5,40(a5)
ffffffffc0202a52:	9782                	jalr	a5
ffffffffc0202a54:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202a56:	6098                	ld	a4,0(s1)
ffffffffc0202a58:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202a5c:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202a5e:	00c71793          	slli	a5,a4,0xc
ffffffffc0202a62:	6a05                	lui	s4,0x1
ffffffffc0202a64:	02f47c63          	bgeu	s0,a5,ffffffffc0202a9c <pmm_init+0x43a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202a68:	00c45793          	srli	a5,s0,0xc
ffffffffc0202a6c:	00093503          	ld	a0,0(s2)
ffffffffc0202a70:	2ee7ff63          	bgeu	a5,a4,ffffffffc0202d6e <pmm_init+0x70c>
ffffffffc0202a74:	0009b583          	ld	a1,0(s3)
ffffffffc0202a78:	4601                	li	a2,0
ffffffffc0202a7a:	95a2                	add	a1,a1,s0
ffffffffc0202a7c:	c00ff0ef          	jal	ra,ffffffffc0201e7c <get_pte>
ffffffffc0202a80:	32050463          	beqz	a0,ffffffffc0202da8 <pmm_init+0x746>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202a84:	611c                	ld	a5,0(a0)
ffffffffc0202a86:	078a                	slli	a5,a5,0x2
ffffffffc0202a88:	0157f7b3          	and	a5,a5,s5
ffffffffc0202a8c:	2e879e63          	bne	a5,s0,ffffffffc0202d88 <pmm_init+0x726>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202a90:	6098                	ld	a4,0(s1)
ffffffffc0202a92:	9452                	add	s0,s0,s4
ffffffffc0202a94:	00c71793          	slli	a5,a4,0xc
ffffffffc0202a98:	fcf468e3          	bltu	s0,a5,ffffffffc0202a68 <pmm_init+0x406>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc0202a9c:	00093783          	ld	a5,0(s2)
ffffffffc0202aa0:	639c                	ld	a5,0(a5)
ffffffffc0202aa2:	42079363          	bnez	a5,ffffffffc0202ec8 <pmm_init+0x866>
ffffffffc0202aa6:	100027f3          	csrr	a5,sstatus
ffffffffc0202aaa:	8b89                	andi	a5,a5,2
ffffffffc0202aac:	24079963          	bnez	a5,ffffffffc0202cfe <pmm_init+0x69c>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202ab0:	000b3783          	ld	a5,0(s6)
ffffffffc0202ab4:	4505                	li	a0,1
ffffffffc0202ab6:	6f9c                	ld	a5,24(a5)
ffffffffc0202ab8:	9782                	jalr	a5
ffffffffc0202aba:	8a2a                	mv	s4,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202abc:	00093503          	ld	a0,0(s2)
ffffffffc0202ac0:	4699                	li	a3,6
ffffffffc0202ac2:	10000613          	li	a2,256
ffffffffc0202ac6:	85d2                	mv	a1,s4
ffffffffc0202ac8:	aa5ff0ef          	jal	ra,ffffffffc020256c <page_insert>
ffffffffc0202acc:	44051e63          	bnez	a0,ffffffffc0202f28 <pmm_init+0x8c6>
    assert(page_ref(p) == 1);
ffffffffc0202ad0:	000a2703          	lw	a4,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8f50>
ffffffffc0202ad4:	4785                	li	a5,1
ffffffffc0202ad6:	42f71963          	bne	a4,a5,ffffffffc0202f08 <pmm_init+0x8a6>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202ada:	00093503          	ld	a0,0(s2)
ffffffffc0202ade:	6405                	lui	s0,0x1
ffffffffc0202ae0:	4699                	li	a3,6
ffffffffc0202ae2:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8e50>
ffffffffc0202ae6:	85d2                	mv	a1,s4
ffffffffc0202ae8:	a85ff0ef          	jal	ra,ffffffffc020256c <page_insert>
ffffffffc0202aec:	72051363          	bnez	a0,ffffffffc0203212 <pmm_init+0xbb0>
    assert(page_ref(p) == 2);
ffffffffc0202af0:	000a2703          	lw	a4,0(s4)
ffffffffc0202af4:	4789                	li	a5,2
ffffffffc0202af6:	6ef71e63          	bne	a4,a5,ffffffffc02031f2 <pmm_init+0xb90>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202afa:	00004597          	auipc	a1,0x4
ffffffffc0202afe:	25e58593          	addi	a1,a1,606 # ffffffffc0206d58 <default_pmm_manager+0x6a8>
ffffffffc0202b02:	10000513          	li	a0,256
ffffffffc0202b06:	4a9020ef          	jal	ra,ffffffffc02057ae <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202b0a:	10040593          	addi	a1,s0,256
ffffffffc0202b0e:	10000513          	li	a0,256
ffffffffc0202b12:	4af020ef          	jal	ra,ffffffffc02057c0 <strcmp>
ffffffffc0202b16:	6a051e63          	bnez	a0,ffffffffc02031d2 <pmm_init+0xb70>
    return page - pages + nbase;
ffffffffc0202b1a:	000bb683          	ld	a3,0(s7)
ffffffffc0202b1e:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202b22:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0202b24:	40da06b3          	sub	a3,s4,a3
ffffffffc0202b28:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202b2a:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202b2c:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202b2e:	8031                	srli	s0,s0,0xc
ffffffffc0202b30:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b34:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202b36:	30f77d63          	bgeu	a4,a5,ffffffffc0202e50 <pmm_init+0x7ee>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202b3a:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202b3e:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202b42:	96be                	add	a3,a3,a5
ffffffffc0202b44:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202b48:	431020ef          	jal	ra,ffffffffc0205778 <strlen>
ffffffffc0202b4c:	66051363          	bnez	a0,ffffffffc02031b2 <pmm_init+0xb50>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0202b50:	00093a83          	ld	s5,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202b54:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b56:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fd38278>
ffffffffc0202b5a:	068a                	slli	a3,a3,0x2
ffffffffc0202b5c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b5e:	26f6f563          	bgeu	a3,a5,ffffffffc0202dc8 <pmm_init+0x766>
    return KADDR(page2pa(page));
ffffffffc0202b62:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b64:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202b66:	2ef47563          	bgeu	s0,a5,ffffffffc0202e50 <pmm_init+0x7ee>
ffffffffc0202b6a:	0009b403          	ld	s0,0(s3)
ffffffffc0202b6e:	9436                	add	s0,s0,a3
ffffffffc0202b70:	100027f3          	csrr	a5,sstatus
ffffffffc0202b74:	8b89                	andi	a5,a5,2
ffffffffc0202b76:	1e079163          	bnez	a5,ffffffffc0202d58 <pmm_init+0x6f6>
        pmm_manager->free_pages(base, n);
ffffffffc0202b7a:	000b3783          	ld	a5,0(s6)
ffffffffc0202b7e:	4585                	li	a1,1
ffffffffc0202b80:	8552                	mv	a0,s4
ffffffffc0202b82:	739c                	ld	a5,32(a5)
ffffffffc0202b84:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b86:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage)
ffffffffc0202b88:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b8a:	078a                	slli	a5,a5,0x2
ffffffffc0202b8c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b8e:	22e7fd63          	bgeu	a5,a4,ffffffffc0202dc8 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b92:	000bb503          	ld	a0,0(s7)
ffffffffc0202b96:	fff80737          	lui	a4,0xfff80
ffffffffc0202b9a:	97ba                	add	a5,a5,a4
ffffffffc0202b9c:	079a                	slli	a5,a5,0x6
ffffffffc0202b9e:	953e                	add	a0,a0,a5
ffffffffc0202ba0:	100027f3          	csrr	a5,sstatus
ffffffffc0202ba4:	8b89                	andi	a5,a5,2
ffffffffc0202ba6:	18079d63          	bnez	a5,ffffffffc0202d40 <pmm_init+0x6de>
ffffffffc0202baa:	000b3783          	ld	a5,0(s6)
ffffffffc0202bae:	4585                	li	a1,1
ffffffffc0202bb0:	739c                	ld	a5,32(a5)
ffffffffc0202bb2:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202bb4:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage)
ffffffffc0202bb8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202bba:	078a                	slli	a5,a5,0x2
ffffffffc0202bbc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202bbe:	20e7f563          	bgeu	a5,a4,ffffffffc0202dc8 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202bc2:	000bb503          	ld	a0,0(s7)
ffffffffc0202bc6:	fff80737          	lui	a4,0xfff80
ffffffffc0202bca:	97ba                	add	a5,a5,a4
ffffffffc0202bcc:	079a                	slli	a5,a5,0x6
ffffffffc0202bce:	953e                	add	a0,a0,a5
ffffffffc0202bd0:	100027f3          	csrr	a5,sstatus
ffffffffc0202bd4:	8b89                	andi	a5,a5,2
ffffffffc0202bd6:	14079963          	bnez	a5,ffffffffc0202d28 <pmm_init+0x6c6>
ffffffffc0202bda:	000b3783          	ld	a5,0(s6)
ffffffffc0202bde:	4585                	li	a1,1
ffffffffc0202be0:	739c                	ld	a5,32(a5)
ffffffffc0202be2:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202be4:	00093783          	ld	a5,0(s2)
ffffffffc0202be8:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc0202bec:	12000073          	sfence.vma
ffffffffc0202bf0:	100027f3          	csrr	a5,sstatus
ffffffffc0202bf4:	8b89                	andi	a5,a5,2
ffffffffc0202bf6:	10079f63          	bnez	a5,ffffffffc0202d14 <pmm_init+0x6b2>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202bfa:	000b3783          	ld	a5,0(s6)
ffffffffc0202bfe:	779c                	ld	a5,40(a5)
ffffffffc0202c00:	9782                	jalr	a5
ffffffffc0202c02:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202c04:	4c8c1e63          	bne	s8,s0,ffffffffc02030e0 <pmm_init+0xa7e>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202c08:	00004517          	auipc	a0,0x4
ffffffffc0202c0c:	1c850513          	addi	a0,a0,456 # ffffffffc0206dd0 <default_pmm_manager+0x720>
ffffffffc0202c10:	d88fd0ef          	jal	ra,ffffffffc0200198 <cprintf>
}
ffffffffc0202c14:	7406                	ld	s0,96(sp)
ffffffffc0202c16:	70a6                	ld	ra,104(sp)
ffffffffc0202c18:	64e6                	ld	s1,88(sp)
ffffffffc0202c1a:	6946                	ld	s2,80(sp)
ffffffffc0202c1c:	69a6                	ld	s3,72(sp)
ffffffffc0202c1e:	6a06                	ld	s4,64(sp)
ffffffffc0202c20:	7ae2                	ld	s5,56(sp)
ffffffffc0202c22:	7b42                	ld	s6,48(sp)
ffffffffc0202c24:	7ba2                	ld	s7,40(sp)
ffffffffc0202c26:	7c02                	ld	s8,32(sp)
ffffffffc0202c28:	6ce2                	ld	s9,24(sp)
ffffffffc0202c2a:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0202c2c:	f97fe06f          	j	ffffffffc0201bc2 <kmalloc_init>
    npage = maxpa / PGSIZE;
ffffffffc0202c30:	c80007b7          	lui	a5,0xc8000
ffffffffc0202c34:	bc7d                	j	ffffffffc02026f2 <pmm_init+0x90>
        intr_disable();
ffffffffc0202c36:	d79fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202c3a:	000b3783          	ld	a5,0(s6)
ffffffffc0202c3e:	4505                	li	a0,1
ffffffffc0202c40:	6f9c                	ld	a5,24(a5)
ffffffffc0202c42:	9782                	jalr	a5
ffffffffc0202c44:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202c46:	d63fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202c4a:	b9a9                	j	ffffffffc02028a4 <pmm_init+0x242>
        intr_disable();
ffffffffc0202c4c:	d63fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc0202c50:	000b3783          	ld	a5,0(s6)
ffffffffc0202c54:	4505                	li	a0,1
ffffffffc0202c56:	6f9c                	ld	a5,24(a5)
ffffffffc0202c58:	9782                	jalr	a5
ffffffffc0202c5a:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202c5c:	d4dfd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202c60:	b645                	j	ffffffffc0202800 <pmm_init+0x19e>
        intr_disable();
ffffffffc0202c62:	d4dfd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202c66:	000b3783          	ld	a5,0(s6)
ffffffffc0202c6a:	779c                	ld	a5,40(a5)
ffffffffc0202c6c:	9782                	jalr	a5
ffffffffc0202c6e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202c70:	d39fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202c74:	b6b9                	j	ffffffffc02027c2 <pmm_init+0x160>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202c76:	6705                	lui	a4,0x1
ffffffffc0202c78:	177d                	addi	a4,a4,-1
ffffffffc0202c7a:	96ba                	add	a3,a3,a4
ffffffffc0202c7c:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc0202c7e:	00c7d713          	srli	a4,a5,0xc
ffffffffc0202c82:	14a77363          	bgeu	a4,a0,ffffffffc0202dc8 <pmm_init+0x766>
    pmm_manager->init_memmap(base, n);
ffffffffc0202c86:	000b3683          	ld	a3,0(s6)
    return &pages[PPN(pa) - nbase];
ffffffffc0202c8a:	fff80537          	lui	a0,0xfff80
ffffffffc0202c8e:	972a                	add	a4,a4,a0
ffffffffc0202c90:	6a94                	ld	a3,16(a3)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202c92:	8c1d                	sub	s0,s0,a5
ffffffffc0202c94:	00671513          	slli	a0,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0202c98:	00c45593          	srli	a1,s0,0xc
ffffffffc0202c9c:	9532                	add	a0,a0,a2
ffffffffc0202c9e:	9682                	jalr	a3
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202ca0:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202ca4:	b4c1                	j	ffffffffc0202764 <pmm_init+0x102>
        intr_disable();
ffffffffc0202ca6:	d09fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202caa:	000b3783          	ld	a5,0(s6)
ffffffffc0202cae:	779c                	ld	a5,40(a5)
ffffffffc0202cb0:	9782                	jalr	a5
ffffffffc0202cb2:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202cb4:	cf5fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202cb8:	bb79                	j	ffffffffc0202a56 <pmm_init+0x3f4>
        intr_disable();
ffffffffc0202cba:	cf5fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc0202cbe:	000b3783          	ld	a5,0(s6)
ffffffffc0202cc2:	779c                	ld	a5,40(a5)
ffffffffc0202cc4:	9782                	jalr	a5
ffffffffc0202cc6:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202cc8:	ce1fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202ccc:	b39d                	j	ffffffffc0202a32 <pmm_init+0x3d0>
ffffffffc0202cce:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202cd0:	cdffd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202cd4:	000b3783          	ld	a5,0(s6)
ffffffffc0202cd8:	6522                	ld	a0,8(sp)
ffffffffc0202cda:	4585                	li	a1,1
ffffffffc0202cdc:	739c                	ld	a5,32(a5)
ffffffffc0202cde:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ce0:	cc9fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202ce4:	b33d                	j	ffffffffc0202a12 <pmm_init+0x3b0>
ffffffffc0202ce6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202ce8:	cc7fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc0202cec:	000b3783          	ld	a5,0(s6)
ffffffffc0202cf0:	6522                	ld	a0,8(sp)
ffffffffc0202cf2:	4585                	li	a1,1
ffffffffc0202cf4:	739c                	ld	a5,32(a5)
ffffffffc0202cf6:	9782                	jalr	a5
        intr_enable();
ffffffffc0202cf8:	cb1fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202cfc:	b1dd                	j	ffffffffc02029e2 <pmm_init+0x380>
        intr_disable();
ffffffffc0202cfe:	cb1fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202d02:	000b3783          	ld	a5,0(s6)
ffffffffc0202d06:	4505                	li	a0,1
ffffffffc0202d08:	6f9c                	ld	a5,24(a5)
ffffffffc0202d0a:	9782                	jalr	a5
ffffffffc0202d0c:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202d0e:	c9bfd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202d12:	b36d                	j	ffffffffc0202abc <pmm_init+0x45a>
        intr_disable();
ffffffffc0202d14:	c9bfd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202d18:	000b3783          	ld	a5,0(s6)
ffffffffc0202d1c:	779c                	ld	a5,40(a5)
ffffffffc0202d1e:	9782                	jalr	a5
ffffffffc0202d20:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202d22:	c87fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202d26:	bdf9                	j	ffffffffc0202c04 <pmm_init+0x5a2>
ffffffffc0202d28:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202d2a:	c85fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202d2e:	000b3783          	ld	a5,0(s6)
ffffffffc0202d32:	6522                	ld	a0,8(sp)
ffffffffc0202d34:	4585                	li	a1,1
ffffffffc0202d36:	739c                	ld	a5,32(a5)
ffffffffc0202d38:	9782                	jalr	a5
        intr_enable();
ffffffffc0202d3a:	c6ffd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202d3e:	b55d                	j	ffffffffc0202be4 <pmm_init+0x582>
ffffffffc0202d40:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202d42:	c6dfd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc0202d46:	000b3783          	ld	a5,0(s6)
ffffffffc0202d4a:	6522                	ld	a0,8(sp)
ffffffffc0202d4c:	4585                	li	a1,1
ffffffffc0202d4e:	739c                	ld	a5,32(a5)
ffffffffc0202d50:	9782                	jalr	a5
        intr_enable();
ffffffffc0202d52:	c57fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202d56:	bdb9                	j	ffffffffc0202bb4 <pmm_init+0x552>
        intr_disable();
ffffffffc0202d58:	c57fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc0202d5c:	000b3783          	ld	a5,0(s6)
ffffffffc0202d60:	4585                	li	a1,1
ffffffffc0202d62:	8552                	mv	a0,s4
ffffffffc0202d64:	739c                	ld	a5,32(a5)
ffffffffc0202d66:	9782                	jalr	a5
        intr_enable();
ffffffffc0202d68:	c41fd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0202d6c:	bd29                	j	ffffffffc0202b86 <pmm_init+0x524>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202d6e:	86a2                	mv	a3,s0
ffffffffc0202d70:	00004617          	auipc	a2,0x4
ffffffffc0202d74:	97860613          	addi	a2,a2,-1672 # ffffffffc02066e8 <default_pmm_manager+0x38>
ffffffffc0202d78:	24100593          	li	a1,577
ffffffffc0202d7c:	00004517          	auipc	a0,0x4
ffffffffc0202d80:	a8450513          	addi	a0,a0,-1404 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202d84:	f0efd0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202d88:	00004697          	auipc	a3,0x4
ffffffffc0202d8c:	ee868693          	addi	a3,a3,-280 # ffffffffc0206c70 <default_pmm_manager+0x5c0>
ffffffffc0202d90:	00003617          	auipc	a2,0x3
ffffffffc0202d94:	57060613          	addi	a2,a2,1392 # ffffffffc0206300 <commands+0x850>
ffffffffc0202d98:	24200593          	li	a1,578
ffffffffc0202d9c:	00004517          	auipc	a0,0x4
ffffffffc0202da0:	a6450513          	addi	a0,a0,-1436 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202da4:	eeefd0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202da8:	00004697          	auipc	a3,0x4
ffffffffc0202dac:	e8868693          	addi	a3,a3,-376 # ffffffffc0206c30 <default_pmm_manager+0x580>
ffffffffc0202db0:	00003617          	auipc	a2,0x3
ffffffffc0202db4:	55060613          	addi	a2,a2,1360 # ffffffffc0206300 <commands+0x850>
ffffffffc0202db8:	24100593          	li	a1,577
ffffffffc0202dbc:	00004517          	auipc	a0,0x4
ffffffffc0202dc0:	a4450513          	addi	a0,a0,-1468 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202dc4:	ecefd0ef          	jal	ra,ffffffffc0200492 <__panic>
ffffffffc0202dc8:	fc5fe0ef          	jal	ra,ffffffffc0201d8c <pa2page.part.0>
ffffffffc0202dcc:	fddfe0ef          	jal	ra,ffffffffc0201da8 <pte2page.part.0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202dd0:	00004697          	auipc	a3,0x4
ffffffffc0202dd4:	c5868693          	addi	a3,a3,-936 # ffffffffc0206a28 <default_pmm_manager+0x378>
ffffffffc0202dd8:	00003617          	auipc	a2,0x3
ffffffffc0202ddc:	52860613          	addi	a2,a2,1320 # ffffffffc0206300 <commands+0x850>
ffffffffc0202de0:	21100593          	li	a1,529
ffffffffc0202de4:	00004517          	auipc	a0,0x4
ffffffffc0202de8:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202dec:	ea6fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0202df0:	00004697          	auipc	a3,0x4
ffffffffc0202df4:	b7868693          	addi	a3,a3,-1160 # ffffffffc0206968 <default_pmm_manager+0x2b8>
ffffffffc0202df8:	00003617          	auipc	a2,0x3
ffffffffc0202dfc:	50860613          	addi	a2,a2,1288 # ffffffffc0206300 <commands+0x850>
ffffffffc0202e00:	20400593          	li	a1,516
ffffffffc0202e04:	00004517          	auipc	a0,0x4
ffffffffc0202e08:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202e0c:	e86fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202e10:	00004697          	auipc	a3,0x4
ffffffffc0202e14:	b1868693          	addi	a3,a3,-1256 # ffffffffc0206928 <default_pmm_manager+0x278>
ffffffffc0202e18:	00003617          	auipc	a2,0x3
ffffffffc0202e1c:	4e860613          	addi	a2,a2,1256 # ffffffffc0206300 <commands+0x850>
ffffffffc0202e20:	20300593          	li	a1,515
ffffffffc0202e24:	00004517          	auipc	a0,0x4
ffffffffc0202e28:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202e2c:	e66fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202e30:	00004697          	auipc	a3,0x4
ffffffffc0202e34:	ad868693          	addi	a3,a3,-1320 # ffffffffc0206908 <default_pmm_manager+0x258>
ffffffffc0202e38:	00003617          	auipc	a2,0x3
ffffffffc0202e3c:	4c860613          	addi	a2,a2,1224 # ffffffffc0206300 <commands+0x850>
ffffffffc0202e40:	20200593          	li	a1,514
ffffffffc0202e44:	00004517          	auipc	a0,0x4
ffffffffc0202e48:	9bc50513          	addi	a0,a0,-1604 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202e4c:	e46fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202e50:	00004617          	auipc	a2,0x4
ffffffffc0202e54:	89860613          	addi	a2,a2,-1896 # ffffffffc02066e8 <default_pmm_manager+0x38>
ffffffffc0202e58:	07100593          	li	a1,113
ffffffffc0202e5c:	00004517          	auipc	a0,0x4
ffffffffc0202e60:	8b450513          	addi	a0,a0,-1868 # ffffffffc0206710 <default_pmm_manager+0x60>
ffffffffc0202e64:	e2efd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202e68:	00004697          	auipc	a3,0x4
ffffffffc0202e6c:	d5068693          	addi	a3,a3,-688 # ffffffffc0206bb8 <default_pmm_manager+0x508>
ffffffffc0202e70:	00003617          	auipc	a2,0x3
ffffffffc0202e74:	49060613          	addi	a2,a2,1168 # ffffffffc0206300 <commands+0x850>
ffffffffc0202e78:	22a00593          	li	a1,554
ffffffffc0202e7c:	00004517          	auipc	a0,0x4
ffffffffc0202e80:	98450513          	addi	a0,a0,-1660 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202e84:	e0efd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202e88:	00004697          	auipc	a3,0x4
ffffffffc0202e8c:	ce868693          	addi	a3,a3,-792 # ffffffffc0206b70 <default_pmm_manager+0x4c0>
ffffffffc0202e90:	00003617          	auipc	a2,0x3
ffffffffc0202e94:	47060613          	addi	a2,a2,1136 # ffffffffc0206300 <commands+0x850>
ffffffffc0202e98:	22800593          	li	a1,552
ffffffffc0202e9c:	00004517          	auipc	a0,0x4
ffffffffc0202ea0:	96450513          	addi	a0,a0,-1692 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202ea4:	deefd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202ea8:	00004697          	auipc	a3,0x4
ffffffffc0202eac:	cf868693          	addi	a3,a3,-776 # ffffffffc0206ba0 <default_pmm_manager+0x4f0>
ffffffffc0202eb0:	00003617          	auipc	a2,0x3
ffffffffc0202eb4:	45060613          	addi	a2,a2,1104 # ffffffffc0206300 <commands+0x850>
ffffffffc0202eb8:	22700593          	li	a1,551
ffffffffc0202ebc:	00004517          	auipc	a0,0x4
ffffffffc0202ec0:	94450513          	addi	a0,a0,-1724 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202ec4:	dcefd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc0202ec8:	00004697          	auipc	a3,0x4
ffffffffc0202ecc:	dc068693          	addi	a3,a3,-576 # ffffffffc0206c88 <default_pmm_manager+0x5d8>
ffffffffc0202ed0:	00003617          	auipc	a2,0x3
ffffffffc0202ed4:	43060613          	addi	a2,a2,1072 # ffffffffc0206300 <commands+0x850>
ffffffffc0202ed8:	24500593          	li	a1,581
ffffffffc0202edc:	00004517          	auipc	a0,0x4
ffffffffc0202ee0:	92450513          	addi	a0,a0,-1756 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202ee4:	daefd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0202ee8:	00004697          	auipc	a3,0x4
ffffffffc0202eec:	d0068693          	addi	a3,a3,-768 # ffffffffc0206be8 <default_pmm_manager+0x538>
ffffffffc0202ef0:	00003617          	auipc	a2,0x3
ffffffffc0202ef4:	41060613          	addi	a2,a2,1040 # ffffffffc0206300 <commands+0x850>
ffffffffc0202ef8:	23200593          	li	a1,562
ffffffffc0202efc:	00004517          	auipc	a0,0x4
ffffffffc0202f00:	90450513          	addi	a0,a0,-1788 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202f04:	d8efd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202f08:	00004697          	auipc	a3,0x4
ffffffffc0202f0c:	dd868693          	addi	a3,a3,-552 # ffffffffc0206ce0 <default_pmm_manager+0x630>
ffffffffc0202f10:	00003617          	auipc	a2,0x3
ffffffffc0202f14:	3f060613          	addi	a2,a2,1008 # ffffffffc0206300 <commands+0x850>
ffffffffc0202f18:	24a00593          	li	a1,586
ffffffffc0202f1c:	00004517          	auipc	a0,0x4
ffffffffc0202f20:	8e450513          	addi	a0,a0,-1820 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202f24:	d6efd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202f28:	00004697          	auipc	a3,0x4
ffffffffc0202f2c:	d7868693          	addi	a3,a3,-648 # ffffffffc0206ca0 <default_pmm_manager+0x5f0>
ffffffffc0202f30:	00003617          	auipc	a2,0x3
ffffffffc0202f34:	3d060613          	addi	a2,a2,976 # ffffffffc0206300 <commands+0x850>
ffffffffc0202f38:	24900593          	li	a1,585
ffffffffc0202f3c:	00004517          	auipc	a0,0x4
ffffffffc0202f40:	8c450513          	addi	a0,a0,-1852 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202f44:	d4efd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f48:	00004697          	auipc	a3,0x4
ffffffffc0202f4c:	c2868693          	addi	a3,a3,-984 # ffffffffc0206b70 <default_pmm_manager+0x4c0>
ffffffffc0202f50:	00003617          	auipc	a2,0x3
ffffffffc0202f54:	3b060613          	addi	a2,a2,944 # ffffffffc0206300 <commands+0x850>
ffffffffc0202f58:	22400593          	li	a1,548
ffffffffc0202f5c:	00004517          	auipc	a0,0x4
ffffffffc0202f60:	8a450513          	addi	a0,a0,-1884 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202f64:	d2efd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202f68:	00004697          	auipc	a3,0x4
ffffffffc0202f6c:	aa868693          	addi	a3,a3,-1368 # ffffffffc0206a10 <default_pmm_manager+0x360>
ffffffffc0202f70:	00003617          	auipc	a2,0x3
ffffffffc0202f74:	39060613          	addi	a2,a2,912 # ffffffffc0206300 <commands+0x850>
ffffffffc0202f78:	22300593          	li	a1,547
ffffffffc0202f7c:	00004517          	auipc	a0,0x4
ffffffffc0202f80:	88450513          	addi	a0,a0,-1916 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202f84:	d0efd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202f88:	00004697          	auipc	a3,0x4
ffffffffc0202f8c:	c0068693          	addi	a3,a3,-1024 # ffffffffc0206b88 <default_pmm_manager+0x4d8>
ffffffffc0202f90:	00003617          	auipc	a2,0x3
ffffffffc0202f94:	37060613          	addi	a2,a2,880 # ffffffffc0206300 <commands+0x850>
ffffffffc0202f98:	22000593          	li	a1,544
ffffffffc0202f9c:	00004517          	auipc	a0,0x4
ffffffffc0202fa0:	86450513          	addi	a0,a0,-1948 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202fa4:	ceefd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202fa8:	00004697          	auipc	a3,0x4
ffffffffc0202fac:	a5068693          	addi	a3,a3,-1456 # ffffffffc02069f8 <default_pmm_manager+0x348>
ffffffffc0202fb0:	00003617          	auipc	a2,0x3
ffffffffc0202fb4:	35060613          	addi	a2,a2,848 # ffffffffc0206300 <commands+0x850>
ffffffffc0202fb8:	21f00593          	li	a1,543
ffffffffc0202fbc:	00004517          	auipc	a0,0x4
ffffffffc0202fc0:	84450513          	addi	a0,a0,-1980 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202fc4:	ccefd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202fc8:	00004697          	auipc	a3,0x4
ffffffffc0202fcc:	ad068693          	addi	a3,a3,-1328 # ffffffffc0206a98 <default_pmm_manager+0x3e8>
ffffffffc0202fd0:	00003617          	auipc	a2,0x3
ffffffffc0202fd4:	33060613          	addi	a2,a2,816 # ffffffffc0206300 <commands+0x850>
ffffffffc0202fd8:	21e00593          	li	a1,542
ffffffffc0202fdc:	00004517          	auipc	a0,0x4
ffffffffc0202fe0:	82450513          	addi	a0,a0,-2012 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0202fe4:	caefd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202fe8:	00004697          	auipc	a3,0x4
ffffffffc0202fec:	b8868693          	addi	a3,a3,-1144 # ffffffffc0206b70 <default_pmm_manager+0x4c0>
ffffffffc0202ff0:	00003617          	auipc	a2,0x3
ffffffffc0202ff4:	31060613          	addi	a2,a2,784 # ffffffffc0206300 <commands+0x850>
ffffffffc0202ff8:	21d00593          	li	a1,541
ffffffffc0202ffc:	00004517          	auipc	a0,0x4
ffffffffc0203000:	80450513          	addi	a0,a0,-2044 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0203004:	c8efd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0203008:	00004697          	auipc	a3,0x4
ffffffffc020300c:	b5068693          	addi	a3,a3,-1200 # ffffffffc0206b58 <default_pmm_manager+0x4a8>
ffffffffc0203010:	00003617          	auipc	a2,0x3
ffffffffc0203014:	2f060613          	addi	a2,a2,752 # ffffffffc0206300 <commands+0x850>
ffffffffc0203018:	21c00593          	li	a1,540
ffffffffc020301c:	00003517          	auipc	a0,0x3
ffffffffc0203020:	7e450513          	addi	a0,a0,2020 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0203024:	c6efd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0203028:	00004697          	auipc	a3,0x4
ffffffffc020302c:	b0068693          	addi	a3,a3,-1280 # ffffffffc0206b28 <default_pmm_manager+0x478>
ffffffffc0203030:	00003617          	auipc	a2,0x3
ffffffffc0203034:	2d060613          	addi	a2,a2,720 # ffffffffc0206300 <commands+0x850>
ffffffffc0203038:	21b00593          	li	a1,539
ffffffffc020303c:	00003517          	auipc	a0,0x3
ffffffffc0203040:	7c450513          	addi	a0,a0,1988 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0203044:	c4efd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203048:	00004697          	auipc	a3,0x4
ffffffffc020304c:	ac868693          	addi	a3,a3,-1336 # ffffffffc0206b10 <default_pmm_manager+0x460>
ffffffffc0203050:	00003617          	auipc	a2,0x3
ffffffffc0203054:	2b060613          	addi	a2,a2,688 # ffffffffc0206300 <commands+0x850>
ffffffffc0203058:	21900593          	li	a1,537
ffffffffc020305c:	00003517          	auipc	a0,0x3
ffffffffc0203060:	7a450513          	addi	a0,a0,1956 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0203064:	c2efd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0203068:	00004697          	auipc	a3,0x4
ffffffffc020306c:	a8868693          	addi	a3,a3,-1400 # ffffffffc0206af0 <default_pmm_manager+0x440>
ffffffffc0203070:	00003617          	auipc	a2,0x3
ffffffffc0203074:	29060613          	addi	a2,a2,656 # ffffffffc0206300 <commands+0x850>
ffffffffc0203078:	21800593          	li	a1,536
ffffffffc020307c:	00003517          	auipc	a0,0x3
ffffffffc0203080:	78450513          	addi	a0,a0,1924 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0203084:	c0efd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203088:	00004697          	auipc	a3,0x4
ffffffffc020308c:	a5868693          	addi	a3,a3,-1448 # ffffffffc0206ae0 <default_pmm_manager+0x430>
ffffffffc0203090:	00003617          	auipc	a2,0x3
ffffffffc0203094:	27060613          	addi	a2,a2,624 # ffffffffc0206300 <commands+0x850>
ffffffffc0203098:	21700593          	li	a1,535
ffffffffc020309c:	00003517          	auipc	a0,0x3
ffffffffc02030a0:	76450513          	addi	a0,a0,1892 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc02030a4:	beefd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02030a8:	00004697          	auipc	a3,0x4
ffffffffc02030ac:	a2868693          	addi	a3,a3,-1496 # ffffffffc0206ad0 <default_pmm_manager+0x420>
ffffffffc02030b0:	00003617          	auipc	a2,0x3
ffffffffc02030b4:	25060613          	addi	a2,a2,592 # ffffffffc0206300 <commands+0x850>
ffffffffc02030b8:	21600593          	li	a1,534
ffffffffc02030bc:	00003517          	auipc	a0,0x3
ffffffffc02030c0:	74450513          	addi	a0,a0,1860 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc02030c4:	bcefd0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("DTB memory info not available");
ffffffffc02030c8:	00003617          	auipc	a2,0x3
ffffffffc02030cc:	7a860613          	addi	a2,a2,1960 # ffffffffc0206870 <default_pmm_manager+0x1c0>
ffffffffc02030d0:	06500593          	li	a1,101
ffffffffc02030d4:	00003517          	auipc	a0,0x3
ffffffffc02030d8:	72c50513          	addi	a0,a0,1836 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc02030dc:	bb6fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc02030e0:	00004697          	auipc	a3,0x4
ffffffffc02030e4:	b0868693          	addi	a3,a3,-1272 # ffffffffc0206be8 <default_pmm_manager+0x538>
ffffffffc02030e8:	00003617          	auipc	a2,0x3
ffffffffc02030ec:	21860613          	addi	a2,a2,536 # ffffffffc0206300 <commands+0x850>
ffffffffc02030f0:	25c00593          	li	a1,604
ffffffffc02030f4:	00003517          	auipc	a0,0x3
ffffffffc02030f8:	70c50513          	addi	a0,a0,1804 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc02030fc:	b96fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0203100:	00004697          	auipc	a3,0x4
ffffffffc0203104:	99868693          	addi	a3,a3,-1640 # ffffffffc0206a98 <default_pmm_manager+0x3e8>
ffffffffc0203108:	00003617          	auipc	a2,0x3
ffffffffc020310c:	1f860613          	addi	a2,a2,504 # ffffffffc0206300 <commands+0x850>
ffffffffc0203110:	21500593          	li	a1,533
ffffffffc0203114:	00003517          	auipc	a0,0x3
ffffffffc0203118:	6ec50513          	addi	a0,a0,1772 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc020311c:	b76fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203120:	00004697          	auipc	a3,0x4
ffffffffc0203124:	93868693          	addi	a3,a3,-1736 # ffffffffc0206a58 <default_pmm_manager+0x3a8>
ffffffffc0203128:	00003617          	auipc	a2,0x3
ffffffffc020312c:	1d860613          	addi	a2,a2,472 # ffffffffc0206300 <commands+0x850>
ffffffffc0203130:	21400593          	li	a1,532
ffffffffc0203134:	00003517          	auipc	a0,0x3
ffffffffc0203138:	6cc50513          	addi	a0,a0,1740 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc020313c:	b56fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203140:	86d6                	mv	a3,s5
ffffffffc0203142:	00003617          	auipc	a2,0x3
ffffffffc0203146:	5a660613          	addi	a2,a2,1446 # ffffffffc02066e8 <default_pmm_manager+0x38>
ffffffffc020314a:	21000593          	li	a1,528
ffffffffc020314e:	00003517          	auipc	a0,0x3
ffffffffc0203152:	6b250513          	addi	a0,a0,1714 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0203156:	b3cfd0ef          	jal	ra,ffffffffc0200492 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc020315a:	00003617          	auipc	a2,0x3
ffffffffc020315e:	58e60613          	addi	a2,a2,1422 # ffffffffc02066e8 <default_pmm_manager+0x38>
ffffffffc0203162:	20f00593          	li	a1,527
ffffffffc0203166:	00003517          	auipc	a0,0x3
ffffffffc020316a:	69a50513          	addi	a0,a0,1690 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc020316e:	b24fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203172:	00004697          	auipc	a3,0x4
ffffffffc0203176:	89e68693          	addi	a3,a3,-1890 # ffffffffc0206a10 <default_pmm_manager+0x360>
ffffffffc020317a:	00003617          	auipc	a2,0x3
ffffffffc020317e:	18660613          	addi	a2,a2,390 # ffffffffc0206300 <commands+0x850>
ffffffffc0203182:	20d00593          	li	a1,525
ffffffffc0203186:	00003517          	auipc	a0,0x3
ffffffffc020318a:	67a50513          	addi	a0,a0,1658 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc020318e:	b04fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203192:	00004697          	auipc	a3,0x4
ffffffffc0203196:	86668693          	addi	a3,a3,-1946 # ffffffffc02069f8 <default_pmm_manager+0x348>
ffffffffc020319a:	00003617          	auipc	a2,0x3
ffffffffc020319e:	16660613          	addi	a2,a2,358 # ffffffffc0206300 <commands+0x850>
ffffffffc02031a2:	20c00593          	li	a1,524
ffffffffc02031a6:	00003517          	auipc	a0,0x3
ffffffffc02031aa:	65a50513          	addi	a0,a0,1626 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc02031ae:	ae4fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02031b2:	00004697          	auipc	a3,0x4
ffffffffc02031b6:	bf668693          	addi	a3,a3,-1034 # ffffffffc0206da8 <default_pmm_manager+0x6f8>
ffffffffc02031ba:	00003617          	auipc	a2,0x3
ffffffffc02031be:	14660613          	addi	a2,a2,326 # ffffffffc0206300 <commands+0x850>
ffffffffc02031c2:	25300593          	li	a1,595
ffffffffc02031c6:	00003517          	auipc	a0,0x3
ffffffffc02031ca:	63a50513          	addi	a0,a0,1594 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc02031ce:	ac4fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02031d2:	00004697          	auipc	a3,0x4
ffffffffc02031d6:	b9e68693          	addi	a3,a3,-1122 # ffffffffc0206d70 <default_pmm_manager+0x6c0>
ffffffffc02031da:	00003617          	auipc	a2,0x3
ffffffffc02031de:	12660613          	addi	a2,a2,294 # ffffffffc0206300 <commands+0x850>
ffffffffc02031e2:	25000593          	li	a1,592
ffffffffc02031e6:	00003517          	auipc	a0,0x3
ffffffffc02031ea:	61a50513          	addi	a0,a0,1562 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc02031ee:	aa4fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_ref(p) == 2);
ffffffffc02031f2:	00004697          	auipc	a3,0x4
ffffffffc02031f6:	b4e68693          	addi	a3,a3,-1202 # ffffffffc0206d40 <default_pmm_manager+0x690>
ffffffffc02031fa:	00003617          	auipc	a2,0x3
ffffffffc02031fe:	10660613          	addi	a2,a2,262 # ffffffffc0206300 <commands+0x850>
ffffffffc0203202:	24c00593          	li	a1,588
ffffffffc0203206:	00003517          	auipc	a0,0x3
ffffffffc020320a:	5fa50513          	addi	a0,a0,1530 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc020320e:	a84fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203212:	00004697          	auipc	a3,0x4
ffffffffc0203216:	ae668693          	addi	a3,a3,-1306 # ffffffffc0206cf8 <default_pmm_manager+0x648>
ffffffffc020321a:	00003617          	auipc	a2,0x3
ffffffffc020321e:	0e660613          	addi	a2,a2,230 # ffffffffc0206300 <commands+0x850>
ffffffffc0203222:	24b00593          	li	a1,587
ffffffffc0203226:	00003517          	auipc	a0,0x3
ffffffffc020322a:	5da50513          	addi	a0,a0,1498 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc020322e:	a64fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0203232:	00003617          	auipc	a2,0x3
ffffffffc0203236:	55e60613          	addi	a2,a2,1374 # ffffffffc0206790 <default_pmm_manager+0xe0>
ffffffffc020323a:	0c900593          	li	a1,201
ffffffffc020323e:	00003517          	auipc	a0,0x3
ffffffffc0203242:	5c250513          	addi	a0,a0,1474 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0203246:	a4cfd0ef          	jal	ra,ffffffffc0200492 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020324a:	00003617          	auipc	a2,0x3
ffffffffc020324e:	54660613          	addi	a2,a2,1350 # ffffffffc0206790 <default_pmm_manager+0xe0>
ffffffffc0203252:	08100593          	li	a1,129
ffffffffc0203256:	00003517          	auipc	a0,0x3
ffffffffc020325a:	5aa50513          	addi	a0,a0,1450 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc020325e:	a34fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0203262:	00003697          	auipc	a3,0x3
ffffffffc0203266:	76668693          	addi	a3,a3,1894 # ffffffffc02069c8 <default_pmm_manager+0x318>
ffffffffc020326a:	00003617          	auipc	a2,0x3
ffffffffc020326e:	09660613          	addi	a2,a2,150 # ffffffffc0206300 <commands+0x850>
ffffffffc0203272:	20b00593          	li	a1,523
ffffffffc0203276:	00003517          	auipc	a0,0x3
ffffffffc020327a:	58a50513          	addi	a0,a0,1418 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc020327e:	a14fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0203282:	00003697          	auipc	a3,0x3
ffffffffc0203286:	71668693          	addi	a3,a3,1814 # ffffffffc0206998 <default_pmm_manager+0x2e8>
ffffffffc020328a:	00003617          	auipc	a2,0x3
ffffffffc020328e:	07660613          	addi	a2,a2,118 # ffffffffc0206300 <commands+0x850>
ffffffffc0203292:	20800593          	li	a1,520
ffffffffc0203296:	00003517          	auipc	a0,0x3
ffffffffc020329a:	56a50513          	addi	a0,a0,1386 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc020329e:	9f4fd0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02032a2 <copy_range>:
{
ffffffffc02032a2:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02032a4:	00d667b3          	or	a5,a2,a3
{
ffffffffc02032a8:	f486                	sd	ra,104(sp)
ffffffffc02032aa:	f0a2                	sd	s0,96(sp)
ffffffffc02032ac:	eca6                	sd	s1,88(sp)
ffffffffc02032ae:	e8ca                	sd	s2,80(sp)
ffffffffc02032b0:	e4ce                	sd	s3,72(sp)
ffffffffc02032b2:	e0d2                	sd	s4,64(sp)
ffffffffc02032b4:	fc56                	sd	s5,56(sp)
ffffffffc02032b6:	f85a                	sd	s6,48(sp)
ffffffffc02032b8:	f45e                	sd	s7,40(sp)
ffffffffc02032ba:	f062                	sd	s8,32(sp)
ffffffffc02032bc:	ec66                	sd	s9,24(sp)
ffffffffc02032be:	e86a                	sd	s10,16(sp)
ffffffffc02032c0:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02032c2:	17d2                	slli	a5,a5,0x34
ffffffffc02032c4:	20079f63          	bnez	a5,ffffffffc02034e2 <copy_range+0x240>
    assert(USER_ACCESS(start, end));
ffffffffc02032c8:	002007b7          	lui	a5,0x200
ffffffffc02032cc:	8432                	mv	s0,a2
ffffffffc02032ce:	1af66263          	bltu	a2,a5,ffffffffc0203472 <copy_range+0x1d0>
ffffffffc02032d2:	8936                	mv	s2,a3
ffffffffc02032d4:	18d67f63          	bgeu	a2,a3,ffffffffc0203472 <copy_range+0x1d0>
ffffffffc02032d8:	4785                	li	a5,1
ffffffffc02032da:	07fe                	slli	a5,a5,0x1f
ffffffffc02032dc:	18d7eb63          	bltu	a5,a3,ffffffffc0203472 <copy_range+0x1d0>
ffffffffc02032e0:	5b7d                	li	s6,-1
ffffffffc02032e2:	8aaa                	mv	s5,a0
ffffffffc02032e4:	89ae                	mv	s3,a1
        start += PGSIZE;
ffffffffc02032e6:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage)
ffffffffc02032e8:	000c4c17          	auipc	s8,0xc4
ffffffffc02032ec:	a50c0c13          	addi	s8,s8,-1456 # ffffffffc02c6d38 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02032f0:	000c4b97          	auipc	s7,0xc4
ffffffffc02032f4:	a50b8b93          	addi	s7,s7,-1456 # ffffffffc02c6d40 <pages>
    return KADDR(page2pa(page));
ffffffffc02032f8:	00cb5b13          	srli	s6,s6,0xc
        page = pmm_manager->alloc_pages(n);
ffffffffc02032fc:	000c4c97          	auipc	s9,0xc4
ffffffffc0203300:	a4cc8c93          	addi	s9,s9,-1460 # ffffffffc02c6d48 <pmm_manager>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0203304:	4601                	li	a2,0
ffffffffc0203306:	85a2                	mv	a1,s0
ffffffffc0203308:	854e                	mv	a0,s3
ffffffffc020330a:	b73fe0ef          	jal	ra,ffffffffc0201e7c <get_pte>
ffffffffc020330e:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc0203310:	0e050c63          	beqz	a0,ffffffffc0203408 <copy_range+0x166>
        if (*ptep & PTE_V)
ffffffffc0203314:	611c                	ld	a5,0(a0)
ffffffffc0203316:	8b85                	andi	a5,a5,1
ffffffffc0203318:	e785                	bnez	a5,ffffffffc0203340 <copy_range+0x9e>
        start += PGSIZE;
ffffffffc020331a:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc020331c:	ff2464e3          	bltu	s0,s2,ffffffffc0203304 <copy_range+0x62>
    return 0;
ffffffffc0203320:	4501                	li	a0,0
}
ffffffffc0203322:	70a6                	ld	ra,104(sp)
ffffffffc0203324:	7406                	ld	s0,96(sp)
ffffffffc0203326:	64e6                	ld	s1,88(sp)
ffffffffc0203328:	6946                	ld	s2,80(sp)
ffffffffc020332a:	69a6                	ld	s3,72(sp)
ffffffffc020332c:	6a06                	ld	s4,64(sp)
ffffffffc020332e:	7ae2                	ld	s5,56(sp)
ffffffffc0203330:	7b42                	ld	s6,48(sp)
ffffffffc0203332:	7ba2                	ld	s7,40(sp)
ffffffffc0203334:	7c02                	ld	s8,32(sp)
ffffffffc0203336:	6ce2                	ld	s9,24(sp)
ffffffffc0203338:	6d42                	ld	s10,16(sp)
ffffffffc020333a:	6da2                	ld	s11,8(sp)
ffffffffc020333c:	6165                	addi	sp,sp,112
ffffffffc020333e:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc0203340:	4605                	li	a2,1
ffffffffc0203342:	85a2                	mv	a1,s0
ffffffffc0203344:	8556                	mv	a0,s5
ffffffffc0203346:	b37fe0ef          	jal	ra,ffffffffc0201e7c <get_pte>
ffffffffc020334a:	c56d                	beqz	a0,ffffffffc0203434 <copy_range+0x192>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc020334c:	609c                	ld	a5,0(s1)
    if (!(pte & PTE_V))
ffffffffc020334e:	0017f713          	andi	a4,a5,1
ffffffffc0203352:	01f7f493          	andi	s1,a5,31
ffffffffc0203356:	16070a63          	beqz	a4,ffffffffc02034ca <copy_range+0x228>
    if (PPN(pa) >= npage)
ffffffffc020335a:	000c3683          	ld	a3,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc020335e:	078a                	slli	a5,a5,0x2
ffffffffc0203360:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0203364:	14d77763          	bgeu	a4,a3,ffffffffc02034b2 <copy_range+0x210>
    return &pages[PPN(pa) - nbase];
ffffffffc0203368:	000bb783          	ld	a5,0(s7)
ffffffffc020336c:	fff806b7          	lui	a3,0xfff80
ffffffffc0203370:	9736                	add	a4,a4,a3
ffffffffc0203372:	071a                	slli	a4,a4,0x6
ffffffffc0203374:	00e78db3          	add	s11,a5,a4
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203378:	10002773          	csrr	a4,sstatus
ffffffffc020337c:	8b09                	andi	a4,a4,2
ffffffffc020337e:	e345                	bnez	a4,ffffffffc020341e <copy_range+0x17c>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203380:	000cb703          	ld	a4,0(s9)
ffffffffc0203384:	4505                	li	a0,1
ffffffffc0203386:	6f18                	ld	a4,24(a4)
ffffffffc0203388:	9702                	jalr	a4
ffffffffc020338a:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc020338c:	0c0d8363          	beqz	s11,ffffffffc0203452 <copy_range+0x1b0>
            assert(npage != NULL);
ffffffffc0203390:	100d0163          	beqz	s10,ffffffffc0203492 <copy_range+0x1f0>
    return page - pages + nbase;
ffffffffc0203394:	000bb703          	ld	a4,0(s7)
ffffffffc0203398:	000805b7          	lui	a1,0x80
    return KADDR(page2pa(page));
ffffffffc020339c:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc02033a0:	40ed86b3          	sub	a3,s11,a4
ffffffffc02033a4:	8699                	srai	a3,a3,0x6
ffffffffc02033a6:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc02033a8:	0166f7b3          	and	a5,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02033ac:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02033ae:	08c7f663          	bgeu	a5,a2,ffffffffc020343a <copy_range+0x198>
    return page - pages + nbase;
ffffffffc02033b2:	40ed07b3          	sub	a5,s10,a4
    return KADDR(page2pa(page));
ffffffffc02033b6:	000c4717          	auipc	a4,0xc4
ffffffffc02033ba:	99a70713          	addi	a4,a4,-1638 # ffffffffc02c6d50 <va_pa_offset>
ffffffffc02033be:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc02033c0:	8799                	srai	a5,a5,0x6
ffffffffc02033c2:	97ae                	add	a5,a5,a1
    return KADDR(page2pa(page));
ffffffffc02033c4:	0167f733          	and	a4,a5,s6
ffffffffc02033c8:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02033cc:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02033ce:	06c77563          	bgeu	a4,a2,ffffffffc0203438 <copy_range+0x196>
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ffffffffc02033d2:	6605                	lui	a2,0x1
ffffffffc02033d4:	953e                	add	a0,a0,a5
ffffffffc02033d6:	456020ef          	jal	ra,ffffffffc020582c <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc02033da:	86a6                	mv	a3,s1
ffffffffc02033dc:	8622                	mv	a2,s0
ffffffffc02033de:	85ea                	mv	a1,s10
ffffffffc02033e0:	8556                	mv	a0,s5
ffffffffc02033e2:	98aff0ef          	jal	ra,ffffffffc020256c <page_insert>
            assert(ret == 0);
ffffffffc02033e6:	d915                	beqz	a0,ffffffffc020331a <copy_range+0x78>
ffffffffc02033e8:	00004697          	auipc	a3,0x4
ffffffffc02033ec:	a2868693          	addi	a3,a3,-1496 # ffffffffc0206e10 <default_pmm_manager+0x760>
ffffffffc02033f0:	00003617          	auipc	a2,0x3
ffffffffc02033f4:	f1060613          	addi	a2,a2,-240 # ffffffffc0206300 <commands+0x850>
ffffffffc02033f8:	1a000593          	li	a1,416
ffffffffc02033fc:	00003517          	auipc	a0,0x3
ffffffffc0203400:	40450513          	addi	a0,a0,1028 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc0203404:	88efd0ef          	jal	ra,ffffffffc0200492 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203408:	00200637          	lui	a2,0x200
ffffffffc020340c:	9432                	add	s0,s0,a2
ffffffffc020340e:	ffe00637          	lui	a2,0xffe00
ffffffffc0203412:	8c71                	and	s0,s0,a2
    } while (start != 0 && start < end);
ffffffffc0203414:	f00406e3          	beqz	s0,ffffffffc0203320 <copy_range+0x7e>
ffffffffc0203418:	ef2466e3          	bltu	s0,s2,ffffffffc0203304 <copy_range+0x62>
ffffffffc020341c:	b711                	j	ffffffffc0203320 <copy_range+0x7e>
        intr_disable();
ffffffffc020341e:	d90fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203422:	000cb703          	ld	a4,0(s9)
ffffffffc0203426:	4505                	li	a0,1
ffffffffc0203428:	6f18                	ld	a4,24(a4)
ffffffffc020342a:	9702                	jalr	a4
ffffffffc020342c:	8d2a                	mv	s10,a0
        intr_enable();
ffffffffc020342e:	d7afd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0203432:	bfa9                	j	ffffffffc020338c <copy_range+0xea>
                return -E_NO_MEM;
ffffffffc0203434:	5571                	li	a0,-4
ffffffffc0203436:	b5f5                	j	ffffffffc0203322 <copy_range+0x80>
ffffffffc0203438:	86be                	mv	a3,a5
ffffffffc020343a:	00003617          	auipc	a2,0x3
ffffffffc020343e:	2ae60613          	addi	a2,a2,686 # ffffffffc02066e8 <default_pmm_manager+0x38>
ffffffffc0203442:	07100593          	li	a1,113
ffffffffc0203446:	00003517          	auipc	a0,0x3
ffffffffc020344a:	2ca50513          	addi	a0,a0,714 # ffffffffc0206710 <default_pmm_manager+0x60>
ffffffffc020344e:	844fd0ef          	jal	ra,ffffffffc0200492 <__panic>
            assert(page != NULL);
ffffffffc0203452:	00004697          	auipc	a3,0x4
ffffffffc0203456:	99e68693          	addi	a3,a3,-1634 # ffffffffc0206df0 <default_pmm_manager+0x740>
ffffffffc020345a:	00003617          	auipc	a2,0x3
ffffffffc020345e:	ea660613          	addi	a2,a2,-346 # ffffffffc0206300 <commands+0x850>
ffffffffc0203462:	19600593          	li	a1,406
ffffffffc0203466:	00003517          	auipc	a0,0x3
ffffffffc020346a:	39a50513          	addi	a0,a0,922 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc020346e:	824fd0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203472:	00003697          	auipc	a3,0x3
ffffffffc0203476:	3ce68693          	addi	a3,a3,974 # ffffffffc0206840 <default_pmm_manager+0x190>
ffffffffc020347a:	00003617          	auipc	a2,0x3
ffffffffc020347e:	e8660613          	addi	a2,a2,-378 # ffffffffc0206300 <commands+0x850>
ffffffffc0203482:	17e00593          	li	a1,382
ffffffffc0203486:	00003517          	auipc	a0,0x3
ffffffffc020348a:	37a50513          	addi	a0,a0,890 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc020348e:	804fd0ef          	jal	ra,ffffffffc0200492 <__panic>
            assert(npage != NULL);
ffffffffc0203492:	00004697          	auipc	a3,0x4
ffffffffc0203496:	96e68693          	addi	a3,a3,-1682 # ffffffffc0206e00 <default_pmm_manager+0x750>
ffffffffc020349a:	00003617          	auipc	a2,0x3
ffffffffc020349e:	e6660613          	addi	a2,a2,-410 # ffffffffc0206300 <commands+0x850>
ffffffffc02034a2:	19700593          	li	a1,407
ffffffffc02034a6:	00003517          	auipc	a0,0x3
ffffffffc02034aa:	35a50513          	addi	a0,a0,858 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc02034ae:	fe5fc0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02034b2:	00003617          	auipc	a2,0x3
ffffffffc02034b6:	30660613          	addi	a2,a2,774 # ffffffffc02067b8 <default_pmm_manager+0x108>
ffffffffc02034ba:	06900593          	li	a1,105
ffffffffc02034be:	00003517          	auipc	a0,0x3
ffffffffc02034c2:	25250513          	addi	a0,a0,594 # ffffffffc0206710 <default_pmm_manager+0x60>
ffffffffc02034c6:	fcdfc0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02034ca:	00003617          	auipc	a2,0x3
ffffffffc02034ce:	30e60613          	addi	a2,a2,782 # ffffffffc02067d8 <default_pmm_manager+0x128>
ffffffffc02034d2:	07f00593          	li	a1,127
ffffffffc02034d6:	00003517          	auipc	a0,0x3
ffffffffc02034da:	23a50513          	addi	a0,a0,570 # ffffffffc0206710 <default_pmm_manager+0x60>
ffffffffc02034de:	fb5fc0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02034e2:	00003697          	auipc	a3,0x3
ffffffffc02034e6:	32e68693          	addi	a3,a3,814 # ffffffffc0206810 <default_pmm_manager+0x160>
ffffffffc02034ea:	00003617          	auipc	a2,0x3
ffffffffc02034ee:	e1660613          	addi	a2,a2,-490 # ffffffffc0206300 <commands+0x850>
ffffffffc02034f2:	17d00593          	li	a1,381
ffffffffc02034f6:	00003517          	auipc	a0,0x3
ffffffffc02034fa:	30a50513          	addi	a0,a0,778 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc02034fe:	f95fc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0203502 <pgdir_alloc_page>:
{
ffffffffc0203502:	7179                	addi	sp,sp,-48
ffffffffc0203504:	ec26                	sd	s1,24(sp)
ffffffffc0203506:	e84a                	sd	s2,16(sp)
ffffffffc0203508:	e052                	sd	s4,0(sp)
ffffffffc020350a:	f406                	sd	ra,40(sp)
ffffffffc020350c:	f022                	sd	s0,32(sp)
ffffffffc020350e:	e44e                	sd	s3,8(sp)
ffffffffc0203510:	8a2a                	mv	s4,a0
ffffffffc0203512:	84ae                	mv	s1,a1
ffffffffc0203514:	8932                	mv	s2,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203516:	100027f3          	csrr	a5,sstatus
ffffffffc020351a:	8b89                	andi	a5,a5,2
        page = pmm_manager->alloc_pages(n);
ffffffffc020351c:	000c4997          	auipc	s3,0xc4
ffffffffc0203520:	82c98993          	addi	s3,s3,-2004 # ffffffffc02c6d48 <pmm_manager>
ffffffffc0203524:	ef8d                	bnez	a5,ffffffffc020355e <pgdir_alloc_page+0x5c>
ffffffffc0203526:	0009b783          	ld	a5,0(s3)
ffffffffc020352a:	4505                	li	a0,1
ffffffffc020352c:	6f9c                	ld	a5,24(a5)
ffffffffc020352e:	9782                	jalr	a5
ffffffffc0203530:	842a                	mv	s0,a0
    if (page != NULL)
ffffffffc0203532:	cc09                	beqz	s0,ffffffffc020354c <pgdir_alloc_page+0x4a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc0203534:	86ca                	mv	a3,s2
ffffffffc0203536:	8626                	mv	a2,s1
ffffffffc0203538:	85a2                	mv	a1,s0
ffffffffc020353a:	8552                	mv	a0,s4
ffffffffc020353c:	830ff0ef          	jal	ra,ffffffffc020256c <page_insert>
ffffffffc0203540:	e915                	bnez	a0,ffffffffc0203574 <pgdir_alloc_page+0x72>
        assert(page_ref(page) == 1);
ffffffffc0203542:	4018                	lw	a4,0(s0)
        page->pra_vaddr = la;
ffffffffc0203544:	fc04                	sd	s1,56(s0)
        assert(page_ref(page) == 1);
ffffffffc0203546:	4785                	li	a5,1
ffffffffc0203548:	04f71e63          	bne	a4,a5,ffffffffc02035a4 <pgdir_alloc_page+0xa2>
}
ffffffffc020354c:	70a2                	ld	ra,40(sp)
ffffffffc020354e:	8522                	mv	a0,s0
ffffffffc0203550:	7402                	ld	s0,32(sp)
ffffffffc0203552:	64e2                	ld	s1,24(sp)
ffffffffc0203554:	6942                	ld	s2,16(sp)
ffffffffc0203556:	69a2                	ld	s3,8(sp)
ffffffffc0203558:	6a02                	ld	s4,0(sp)
ffffffffc020355a:	6145                	addi	sp,sp,48
ffffffffc020355c:	8082                	ret
        intr_disable();
ffffffffc020355e:	c50fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203562:	0009b783          	ld	a5,0(s3)
ffffffffc0203566:	4505                	li	a0,1
ffffffffc0203568:	6f9c                	ld	a5,24(a5)
ffffffffc020356a:	9782                	jalr	a5
ffffffffc020356c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020356e:	c3afd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc0203572:	b7c1                	j	ffffffffc0203532 <pgdir_alloc_page+0x30>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203574:	100027f3          	csrr	a5,sstatus
ffffffffc0203578:	8b89                	andi	a5,a5,2
ffffffffc020357a:	eb89                	bnez	a5,ffffffffc020358c <pgdir_alloc_page+0x8a>
        pmm_manager->free_pages(base, n);
ffffffffc020357c:	0009b783          	ld	a5,0(s3)
ffffffffc0203580:	8522                	mv	a0,s0
ffffffffc0203582:	4585                	li	a1,1
ffffffffc0203584:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc0203586:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc0203588:	9782                	jalr	a5
    if (flag)
ffffffffc020358a:	b7c9                	j	ffffffffc020354c <pgdir_alloc_page+0x4a>
        intr_disable();
ffffffffc020358c:	c22fd0ef          	jal	ra,ffffffffc02009ae <intr_disable>
ffffffffc0203590:	0009b783          	ld	a5,0(s3)
ffffffffc0203594:	8522                	mv	a0,s0
ffffffffc0203596:	4585                	li	a1,1
ffffffffc0203598:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc020359a:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc020359c:	9782                	jalr	a5
        intr_enable();
ffffffffc020359e:	c0afd0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc02035a2:	b76d                	j	ffffffffc020354c <pgdir_alloc_page+0x4a>
        assert(page_ref(page) == 1);
ffffffffc02035a4:	00004697          	auipc	a3,0x4
ffffffffc02035a8:	87c68693          	addi	a3,a3,-1924 # ffffffffc0206e20 <default_pmm_manager+0x770>
ffffffffc02035ac:	00003617          	auipc	a2,0x3
ffffffffc02035b0:	d5460613          	addi	a2,a2,-684 # ffffffffc0206300 <commands+0x850>
ffffffffc02035b4:	1e900593          	li	a1,489
ffffffffc02035b8:	00003517          	auipc	a0,0x3
ffffffffc02035bc:	24850513          	addi	a0,a0,584 # ffffffffc0206800 <default_pmm_manager+0x150>
ffffffffc02035c0:	ed3fc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02035c4 <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02035c4:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02035c6:	00004697          	auipc	a3,0x4
ffffffffc02035ca:	87268693          	addi	a3,a3,-1934 # ffffffffc0206e38 <default_pmm_manager+0x788>
ffffffffc02035ce:	00003617          	auipc	a2,0x3
ffffffffc02035d2:	d3260613          	addi	a2,a2,-718 # ffffffffc0206300 <commands+0x850>
ffffffffc02035d6:	07400593          	li	a1,116
ffffffffc02035da:	00004517          	auipc	a0,0x4
ffffffffc02035de:	87e50513          	addi	a0,a0,-1922 # ffffffffc0206e58 <default_pmm_manager+0x7a8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02035e2:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02035e4:	eaffc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02035e8 <mm_create>:
{
ffffffffc02035e8:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02035ea:	04000513          	li	a0,64
{
ffffffffc02035ee:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02035f0:	df6fe0ef          	jal	ra,ffffffffc0201be6 <kmalloc>
    if (mm != NULL)
ffffffffc02035f4:	cd19                	beqz	a0,ffffffffc0203612 <mm_create+0x2a>
    elm->prev = elm->next = elm;
ffffffffc02035f6:	e508                	sd	a0,8(a0)
ffffffffc02035f8:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02035fa:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02035fe:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203602:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0203606:	02053423          	sd	zero,40(a0)
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc020360a:	02052823          	sw	zero,48(a0)
typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
ffffffffc020360e:	02053c23          	sd	zero,56(a0)
}
ffffffffc0203612:	60a2                	ld	ra,8(sp)
ffffffffc0203614:	0141                	addi	sp,sp,16
ffffffffc0203616:	8082                	ret

ffffffffc0203618 <find_vma>:
{
ffffffffc0203618:	86aa                	mv	a3,a0
    if (mm != NULL)
ffffffffc020361a:	c505                	beqz	a0,ffffffffc0203642 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc020361c:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc020361e:	c501                	beqz	a0,ffffffffc0203626 <find_vma+0xe>
ffffffffc0203620:	651c                	ld	a5,8(a0)
ffffffffc0203622:	02f5f263          	bgeu	a1,a5,ffffffffc0203646 <find_vma+0x2e>
    return listelm->next;
ffffffffc0203626:	669c                	ld	a5,8(a3)
            while ((le = list_next(le)) != list)
ffffffffc0203628:	00f68d63          	beq	a3,a5,ffffffffc0203642 <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc020362c:	fe87b703          	ld	a4,-24(a5) # 1fffe8 <_binary_obj___user_matrix_out_size+0x1f38c0>
ffffffffc0203630:	00e5e663          	bltu	a1,a4,ffffffffc020363c <find_vma+0x24>
ffffffffc0203634:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203638:	00e5ec63          	bltu	a1,a4,ffffffffc0203650 <find_vma+0x38>
ffffffffc020363c:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc020363e:	fef697e3          	bne	a3,a5,ffffffffc020362c <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0203642:	4501                	li	a0,0
}
ffffffffc0203644:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0203646:	691c                	ld	a5,16(a0)
ffffffffc0203648:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0203626 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc020364c:	ea88                	sd	a0,16(a3)
ffffffffc020364e:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc0203650:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0203654:	ea88                	sd	a0,16(a3)
ffffffffc0203656:	8082                	ret

ffffffffc0203658 <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203658:	6590                	ld	a2,8(a1)
ffffffffc020365a:	0105b803          	ld	a6,16(a1) # 80010 <_binary_obj___user_matrix_out_size+0x738e8>
{
ffffffffc020365e:	1141                	addi	sp,sp,-16
ffffffffc0203660:	e406                	sd	ra,8(sp)
ffffffffc0203662:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203664:	01066763          	bltu	a2,a6,ffffffffc0203672 <insert_vma_struct+0x1a>
ffffffffc0203668:	a085                	j	ffffffffc02036c8 <insert_vma_struct+0x70>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc020366a:	fe87b703          	ld	a4,-24(a5)
ffffffffc020366e:	04e66863          	bltu	a2,a4,ffffffffc02036be <insert_vma_struct+0x66>
ffffffffc0203672:	86be                	mv	a3,a5
ffffffffc0203674:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc0203676:	fef51ae3          	bne	a0,a5,ffffffffc020366a <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc020367a:	02a68463          	beq	a3,a0,ffffffffc02036a2 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc020367e:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203682:	fe86b883          	ld	a7,-24(a3)
ffffffffc0203686:	08e8f163          	bgeu	a7,a4,ffffffffc0203708 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020368a:	04e66f63          	bltu	a2,a4,ffffffffc02036e8 <insert_vma_struct+0x90>
    }
    if (le_next != list)
ffffffffc020368e:	00f50a63          	beq	a0,a5,ffffffffc02036a2 <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0203692:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203696:	05076963          	bltu	a4,a6,ffffffffc02036e8 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc020369a:	ff07b603          	ld	a2,-16(a5)
ffffffffc020369e:	02c77363          	bgeu	a4,a2,ffffffffc02036c4 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc02036a2:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02036a4:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02036a6:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02036aa:	e390                	sd	a2,0(a5)
ffffffffc02036ac:	e690                	sd	a2,8(a3)
}
ffffffffc02036ae:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02036b0:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02036b2:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc02036b4:	0017079b          	addiw	a5,a4,1
ffffffffc02036b8:	d11c                	sw	a5,32(a0)
}
ffffffffc02036ba:	0141                	addi	sp,sp,16
ffffffffc02036bc:	8082                	ret
    if (le_prev != list)
ffffffffc02036be:	fca690e3          	bne	a3,a0,ffffffffc020367e <insert_vma_struct+0x26>
ffffffffc02036c2:	bfd1                	j	ffffffffc0203696 <insert_vma_struct+0x3e>
ffffffffc02036c4:	f01ff0ef          	jal	ra,ffffffffc02035c4 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02036c8:	00003697          	auipc	a3,0x3
ffffffffc02036cc:	7a068693          	addi	a3,a3,1952 # ffffffffc0206e68 <default_pmm_manager+0x7b8>
ffffffffc02036d0:	00003617          	auipc	a2,0x3
ffffffffc02036d4:	c3060613          	addi	a2,a2,-976 # ffffffffc0206300 <commands+0x850>
ffffffffc02036d8:	07a00593          	li	a1,122
ffffffffc02036dc:	00003517          	auipc	a0,0x3
ffffffffc02036e0:	77c50513          	addi	a0,a0,1916 # ffffffffc0206e58 <default_pmm_manager+0x7a8>
ffffffffc02036e4:	daffc0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02036e8:	00003697          	auipc	a3,0x3
ffffffffc02036ec:	7c068693          	addi	a3,a3,1984 # ffffffffc0206ea8 <default_pmm_manager+0x7f8>
ffffffffc02036f0:	00003617          	auipc	a2,0x3
ffffffffc02036f4:	c1060613          	addi	a2,a2,-1008 # ffffffffc0206300 <commands+0x850>
ffffffffc02036f8:	07300593          	li	a1,115
ffffffffc02036fc:	00003517          	auipc	a0,0x3
ffffffffc0203700:	75c50513          	addi	a0,a0,1884 # ffffffffc0206e58 <default_pmm_manager+0x7a8>
ffffffffc0203704:	d8ffc0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203708:	00003697          	auipc	a3,0x3
ffffffffc020370c:	78068693          	addi	a3,a3,1920 # ffffffffc0206e88 <default_pmm_manager+0x7d8>
ffffffffc0203710:	00003617          	auipc	a2,0x3
ffffffffc0203714:	bf060613          	addi	a2,a2,-1040 # ffffffffc0206300 <commands+0x850>
ffffffffc0203718:	07200593          	li	a1,114
ffffffffc020371c:	00003517          	auipc	a0,0x3
ffffffffc0203720:	73c50513          	addi	a0,a0,1852 # ffffffffc0206e58 <default_pmm_manager+0x7a8>
ffffffffc0203724:	d6ffc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0203728 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc0203728:	591c                	lw	a5,48(a0)
{
ffffffffc020372a:	1141                	addi	sp,sp,-16
ffffffffc020372c:	e406                	sd	ra,8(sp)
ffffffffc020372e:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0203730:	e78d                	bnez	a5,ffffffffc020375a <mm_destroy+0x32>
ffffffffc0203732:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203734:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc0203736:	00a40c63          	beq	s0,a0,ffffffffc020374e <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020373a:	6118                	ld	a4,0(a0)
ffffffffc020373c:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc020373e:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203740:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203742:	e398                	sd	a4,0(a5)
ffffffffc0203744:	d52fe0ef          	jal	ra,ffffffffc0201c96 <kfree>
    return listelm->next;
ffffffffc0203748:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc020374a:	fea418e3          	bne	s0,a0,ffffffffc020373a <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc020374e:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc0203750:	6402                	ld	s0,0(sp)
ffffffffc0203752:	60a2                	ld	ra,8(sp)
ffffffffc0203754:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc0203756:	d40fe06f          	j	ffffffffc0201c96 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc020375a:	00003697          	auipc	a3,0x3
ffffffffc020375e:	76e68693          	addi	a3,a3,1902 # ffffffffc0206ec8 <default_pmm_manager+0x818>
ffffffffc0203762:	00003617          	auipc	a2,0x3
ffffffffc0203766:	b9e60613          	addi	a2,a2,-1122 # ffffffffc0206300 <commands+0x850>
ffffffffc020376a:	09e00593          	li	a1,158
ffffffffc020376e:	00003517          	auipc	a0,0x3
ffffffffc0203772:	6ea50513          	addi	a0,a0,1770 # ffffffffc0206e58 <default_pmm_manager+0x7a8>
ffffffffc0203776:	d1dfc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc020377a <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
ffffffffc020377a:	7139                	addi	sp,sp,-64
ffffffffc020377c:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020377e:	6405                	lui	s0,0x1
ffffffffc0203780:	147d                	addi	s0,s0,-1
ffffffffc0203782:	77fd                	lui	a5,0xfffff
ffffffffc0203784:	9622                	add	a2,a2,s0
ffffffffc0203786:	962e                	add	a2,a2,a1
{
ffffffffc0203788:	f426                	sd	s1,40(sp)
ffffffffc020378a:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020378c:	00f5f4b3          	and	s1,a1,a5
{
ffffffffc0203790:	f04a                	sd	s2,32(sp)
ffffffffc0203792:	ec4e                	sd	s3,24(sp)
ffffffffc0203794:	e852                	sd	s4,16(sp)
ffffffffc0203796:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end))
ffffffffc0203798:	002005b7          	lui	a1,0x200
ffffffffc020379c:	00f67433          	and	s0,a2,a5
ffffffffc02037a0:	06b4e363          	bltu	s1,a1,ffffffffc0203806 <mm_map+0x8c>
ffffffffc02037a4:	0684f163          	bgeu	s1,s0,ffffffffc0203806 <mm_map+0x8c>
ffffffffc02037a8:	4785                	li	a5,1
ffffffffc02037aa:	07fe                	slli	a5,a5,0x1f
ffffffffc02037ac:	0487ed63          	bltu	a5,s0,ffffffffc0203806 <mm_map+0x8c>
ffffffffc02037b0:	89aa                	mv	s3,a0
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02037b2:	cd21                	beqz	a0,ffffffffc020380a <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc02037b4:	85a6                	mv	a1,s1
ffffffffc02037b6:	8ab6                	mv	s5,a3
ffffffffc02037b8:	8a3a                	mv	s4,a4
ffffffffc02037ba:	e5fff0ef          	jal	ra,ffffffffc0203618 <find_vma>
ffffffffc02037be:	c501                	beqz	a0,ffffffffc02037c6 <mm_map+0x4c>
ffffffffc02037c0:	651c                	ld	a5,8(a0)
ffffffffc02037c2:	0487e263          	bltu	a5,s0,ffffffffc0203806 <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02037c6:	03000513          	li	a0,48
ffffffffc02037ca:	c1cfe0ef          	jal	ra,ffffffffc0201be6 <kmalloc>
ffffffffc02037ce:	892a                	mv	s2,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02037d0:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc02037d2:	02090163          	beqz	s2,ffffffffc02037f4 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02037d6:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02037d8:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc02037dc:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc02037e0:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc02037e4:	85ca                	mv	a1,s2
ffffffffc02037e6:	e73ff0ef          	jal	ra,ffffffffc0203658 <insert_vma_struct>
    if (vma_store != NULL)
    {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc02037ea:	4501                	li	a0,0
    if (vma_store != NULL)
ffffffffc02037ec:	000a0463          	beqz	s4,ffffffffc02037f4 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc02037f0:	012a3023          	sd	s2,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8f50>

out:
    return ret;
}
ffffffffc02037f4:	70e2                	ld	ra,56(sp)
ffffffffc02037f6:	7442                	ld	s0,48(sp)
ffffffffc02037f8:	74a2                	ld	s1,40(sp)
ffffffffc02037fa:	7902                	ld	s2,32(sp)
ffffffffc02037fc:	69e2                	ld	s3,24(sp)
ffffffffc02037fe:	6a42                	ld	s4,16(sp)
ffffffffc0203800:	6aa2                	ld	s5,8(sp)
ffffffffc0203802:	6121                	addi	sp,sp,64
ffffffffc0203804:	8082                	ret
        return -E_INVAL;
ffffffffc0203806:	5575                	li	a0,-3
ffffffffc0203808:	b7f5                	j	ffffffffc02037f4 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc020380a:	00003697          	auipc	a3,0x3
ffffffffc020380e:	6d668693          	addi	a3,a3,1750 # ffffffffc0206ee0 <default_pmm_manager+0x830>
ffffffffc0203812:	00003617          	auipc	a2,0x3
ffffffffc0203816:	aee60613          	addi	a2,a2,-1298 # ffffffffc0206300 <commands+0x850>
ffffffffc020381a:	0b300593          	li	a1,179
ffffffffc020381e:	00003517          	auipc	a0,0x3
ffffffffc0203822:	63a50513          	addi	a0,a0,1594 # ffffffffc0206e58 <default_pmm_manager+0x7a8>
ffffffffc0203826:	c6dfc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc020382a <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc020382a:	7139                	addi	sp,sp,-64
ffffffffc020382c:	fc06                	sd	ra,56(sp)
ffffffffc020382e:	f822                	sd	s0,48(sp)
ffffffffc0203830:	f426                	sd	s1,40(sp)
ffffffffc0203832:	f04a                	sd	s2,32(sp)
ffffffffc0203834:	ec4e                	sd	s3,24(sp)
ffffffffc0203836:	e852                	sd	s4,16(sp)
ffffffffc0203838:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc020383a:	c52d                	beqz	a0,ffffffffc02038a4 <dup_mmap+0x7a>
ffffffffc020383c:	892a                	mv	s2,a0
ffffffffc020383e:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0203840:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0203842:	e595                	bnez	a1,ffffffffc020386e <dup_mmap+0x44>
ffffffffc0203844:	a085                	j	ffffffffc02038a4 <dup_mmap+0x7a>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0203846:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc0203848:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_matrix_out_size+0x1f38e0>
        vma->vm_end = vm_end;
ffffffffc020384c:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0203850:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc0203854:	e05ff0ef          	jal	ra,ffffffffc0203658 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc0203858:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8f60>
ffffffffc020385c:	fe843603          	ld	a2,-24(s0)
ffffffffc0203860:	6c8c                	ld	a1,24(s1)
ffffffffc0203862:	01893503          	ld	a0,24(s2)
ffffffffc0203866:	4701                	li	a4,0
ffffffffc0203868:	a3bff0ef          	jal	ra,ffffffffc02032a2 <copy_range>
ffffffffc020386c:	e105                	bnez	a0,ffffffffc020388c <dup_mmap+0x62>
    return listelm->prev;
ffffffffc020386e:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc0203870:	02848863          	beq	s1,s0,ffffffffc02038a0 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203874:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0203878:	fe843a83          	ld	s5,-24(s0)
ffffffffc020387c:	ff043a03          	ld	s4,-16(s0)
ffffffffc0203880:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203884:	b62fe0ef          	jal	ra,ffffffffc0201be6 <kmalloc>
ffffffffc0203888:	85aa                	mv	a1,a0
    if (vma != NULL)
ffffffffc020388a:	fd55                	bnez	a0,ffffffffc0203846 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc020388c:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc020388e:	70e2                	ld	ra,56(sp)
ffffffffc0203890:	7442                	ld	s0,48(sp)
ffffffffc0203892:	74a2                	ld	s1,40(sp)
ffffffffc0203894:	7902                	ld	s2,32(sp)
ffffffffc0203896:	69e2                	ld	s3,24(sp)
ffffffffc0203898:	6a42                	ld	s4,16(sp)
ffffffffc020389a:	6aa2                	ld	s5,8(sp)
ffffffffc020389c:	6121                	addi	sp,sp,64
ffffffffc020389e:	8082                	ret
    return 0;
ffffffffc02038a0:	4501                	li	a0,0
ffffffffc02038a2:	b7f5                	j	ffffffffc020388e <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc02038a4:	00003697          	auipc	a3,0x3
ffffffffc02038a8:	64c68693          	addi	a3,a3,1612 # ffffffffc0206ef0 <default_pmm_manager+0x840>
ffffffffc02038ac:	00003617          	auipc	a2,0x3
ffffffffc02038b0:	a5460613          	addi	a2,a2,-1452 # ffffffffc0206300 <commands+0x850>
ffffffffc02038b4:	0cf00593          	li	a1,207
ffffffffc02038b8:	00003517          	auipc	a0,0x3
ffffffffc02038bc:	5a050513          	addi	a0,a0,1440 # ffffffffc0206e58 <default_pmm_manager+0x7a8>
ffffffffc02038c0:	bd3fc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02038c4 <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc02038c4:	1101                	addi	sp,sp,-32
ffffffffc02038c6:	ec06                	sd	ra,24(sp)
ffffffffc02038c8:	e822                	sd	s0,16(sp)
ffffffffc02038ca:	e426                	sd	s1,8(sp)
ffffffffc02038cc:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02038ce:	c531                	beqz	a0,ffffffffc020391a <exit_mmap+0x56>
ffffffffc02038d0:	591c                	lw	a5,48(a0)
ffffffffc02038d2:	84aa                	mv	s1,a0
ffffffffc02038d4:	e3b9                	bnez	a5,ffffffffc020391a <exit_mmap+0x56>
    return listelm->next;
ffffffffc02038d6:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02038d8:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc02038dc:	02850663          	beq	a0,s0,ffffffffc0203908 <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02038e0:	ff043603          	ld	a2,-16(s0)
ffffffffc02038e4:	fe843583          	ld	a1,-24(s0)
ffffffffc02038e8:	854a                	mv	a0,s2
ffffffffc02038ea:	80ffe0ef          	jal	ra,ffffffffc02020f8 <unmap_range>
ffffffffc02038ee:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc02038f0:	fe8498e3          	bne	s1,s0,ffffffffc02038e0 <exit_mmap+0x1c>
ffffffffc02038f4:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc02038f6:	00848c63          	beq	s1,s0,ffffffffc020390e <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02038fa:	ff043603          	ld	a2,-16(s0)
ffffffffc02038fe:	fe843583          	ld	a1,-24(s0)
ffffffffc0203902:	854a                	mv	a0,s2
ffffffffc0203904:	93bfe0ef          	jal	ra,ffffffffc020223e <exit_range>
ffffffffc0203908:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc020390a:	fe8498e3          	bne	s1,s0,ffffffffc02038fa <exit_mmap+0x36>
    }
}
ffffffffc020390e:	60e2                	ld	ra,24(sp)
ffffffffc0203910:	6442                	ld	s0,16(sp)
ffffffffc0203912:	64a2                	ld	s1,8(sp)
ffffffffc0203914:	6902                	ld	s2,0(sp)
ffffffffc0203916:	6105                	addi	sp,sp,32
ffffffffc0203918:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc020391a:	00003697          	auipc	a3,0x3
ffffffffc020391e:	5f668693          	addi	a3,a3,1526 # ffffffffc0206f10 <default_pmm_manager+0x860>
ffffffffc0203922:	00003617          	auipc	a2,0x3
ffffffffc0203926:	9de60613          	addi	a2,a2,-1570 # ffffffffc0206300 <commands+0x850>
ffffffffc020392a:	0e800593          	li	a1,232
ffffffffc020392e:	00003517          	auipc	a0,0x3
ffffffffc0203932:	52a50513          	addi	a0,a0,1322 # ffffffffc0206e58 <default_pmm_manager+0x7a8>
ffffffffc0203936:	b5dfc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc020393a <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc020393a:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020393c:	04000513          	li	a0,64
{
ffffffffc0203940:	fc06                	sd	ra,56(sp)
ffffffffc0203942:	f822                	sd	s0,48(sp)
ffffffffc0203944:	f426                	sd	s1,40(sp)
ffffffffc0203946:	f04a                	sd	s2,32(sp)
ffffffffc0203948:	ec4e                	sd	s3,24(sp)
ffffffffc020394a:	e852                	sd	s4,16(sp)
ffffffffc020394c:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020394e:	a98fe0ef          	jal	ra,ffffffffc0201be6 <kmalloc>
    if (mm != NULL)
ffffffffc0203952:	2e050663          	beqz	a0,ffffffffc0203c3e <vmm_init+0x304>
ffffffffc0203956:	84aa                	mv	s1,a0
    elm->prev = elm->next = elm;
ffffffffc0203958:	e508                	sd	a0,8(a0)
ffffffffc020395a:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc020395c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203960:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203964:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0203968:	02053423          	sd	zero,40(a0)
ffffffffc020396c:	02052823          	sw	zero,48(a0)
ffffffffc0203970:	02053c23          	sd	zero,56(a0)
ffffffffc0203974:	03200413          	li	s0,50
ffffffffc0203978:	a811                	j	ffffffffc020398c <vmm_init+0x52>
        vma->vm_start = vm_start;
ffffffffc020397a:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc020397c:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020397e:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
ffffffffc0203982:	146d                	addi	s0,s0,-5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203984:	8526                	mv	a0,s1
ffffffffc0203986:	cd3ff0ef          	jal	ra,ffffffffc0203658 <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc020398a:	c80d                	beqz	s0,ffffffffc02039bc <vmm_init+0x82>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020398c:	03000513          	li	a0,48
ffffffffc0203990:	a56fe0ef          	jal	ra,ffffffffc0201be6 <kmalloc>
ffffffffc0203994:	85aa                	mv	a1,a0
ffffffffc0203996:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc020399a:	f165                	bnez	a0,ffffffffc020397a <vmm_init+0x40>
        assert(vma != NULL);
ffffffffc020399c:	00003697          	auipc	a3,0x3
ffffffffc02039a0:	70c68693          	addi	a3,a3,1804 # ffffffffc02070a8 <default_pmm_manager+0x9f8>
ffffffffc02039a4:	00003617          	auipc	a2,0x3
ffffffffc02039a8:	95c60613          	addi	a2,a2,-1700 # ffffffffc0206300 <commands+0x850>
ffffffffc02039ac:	12c00593          	li	a1,300
ffffffffc02039b0:	00003517          	auipc	a0,0x3
ffffffffc02039b4:	4a850513          	addi	a0,a0,1192 # ffffffffc0206e58 <default_pmm_manager+0x7a8>
ffffffffc02039b8:	adbfc0ef          	jal	ra,ffffffffc0200492 <__panic>
ffffffffc02039bc:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc02039c0:	1f900913          	li	s2,505
ffffffffc02039c4:	a819                	j	ffffffffc02039da <vmm_init+0xa0>
        vma->vm_start = vm_start;
ffffffffc02039c6:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02039c8:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02039ca:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++)
ffffffffc02039ce:	0415                	addi	s0,s0,5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02039d0:	8526                	mv	a0,s1
ffffffffc02039d2:	c87ff0ef          	jal	ra,ffffffffc0203658 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc02039d6:	03240a63          	beq	s0,s2,ffffffffc0203a0a <vmm_init+0xd0>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02039da:	03000513          	li	a0,48
ffffffffc02039de:	a08fe0ef          	jal	ra,ffffffffc0201be6 <kmalloc>
ffffffffc02039e2:	85aa                	mv	a1,a0
ffffffffc02039e4:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc02039e8:	fd79                	bnez	a0,ffffffffc02039c6 <vmm_init+0x8c>
        assert(vma != NULL);
ffffffffc02039ea:	00003697          	auipc	a3,0x3
ffffffffc02039ee:	6be68693          	addi	a3,a3,1726 # ffffffffc02070a8 <default_pmm_manager+0x9f8>
ffffffffc02039f2:	00003617          	auipc	a2,0x3
ffffffffc02039f6:	90e60613          	addi	a2,a2,-1778 # ffffffffc0206300 <commands+0x850>
ffffffffc02039fa:	13300593          	li	a1,307
ffffffffc02039fe:	00003517          	auipc	a0,0x3
ffffffffc0203a02:	45a50513          	addi	a0,a0,1114 # ffffffffc0206e58 <default_pmm_manager+0x7a8>
ffffffffc0203a06:	a8dfc0ef          	jal	ra,ffffffffc0200492 <__panic>
    return listelm->next;
ffffffffc0203a0a:	649c                	ld	a5,8(s1)
ffffffffc0203a0c:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0203a0e:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0203a12:	16f48663          	beq	s1,a5,ffffffffc0203b7e <vmm_init+0x244>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203a16:	fe87b603          	ld	a2,-24(a5) # ffffffffffffefe8 <end+0x3fd38260>
ffffffffc0203a1a:	ffe70693          	addi	a3,a4,-2
ffffffffc0203a1e:	10d61063          	bne	a2,a3,ffffffffc0203b1e <vmm_init+0x1e4>
ffffffffc0203a22:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203a26:	0ed71c63          	bne	a4,a3,ffffffffc0203b1e <vmm_init+0x1e4>
    for (i = 1; i <= step2; i++)
ffffffffc0203a2a:	0715                	addi	a4,a4,5
ffffffffc0203a2c:	679c                	ld	a5,8(a5)
ffffffffc0203a2e:	feb712e3          	bne	a4,a1,ffffffffc0203a12 <vmm_init+0xd8>
ffffffffc0203a32:	4a1d                	li	s4,7
ffffffffc0203a34:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203a36:	1f900a93          	li	s5,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203a3a:	85a2                	mv	a1,s0
ffffffffc0203a3c:	8526                	mv	a0,s1
ffffffffc0203a3e:	bdbff0ef          	jal	ra,ffffffffc0203618 <find_vma>
ffffffffc0203a42:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0203a44:	16050d63          	beqz	a0,ffffffffc0203bbe <vmm_init+0x284>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0203a48:	00140593          	addi	a1,s0,1
ffffffffc0203a4c:	8526                	mv	a0,s1
ffffffffc0203a4e:	bcbff0ef          	jal	ra,ffffffffc0203618 <find_vma>
ffffffffc0203a52:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203a54:	14050563          	beqz	a0,ffffffffc0203b9e <vmm_init+0x264>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0203a58:	85d2                	mv	a1,s4
ffffffffc0203a5a:	8526                	mv	a0,s1
ffffffffc0203a5c:	bbdff0ef          	jal	ra,ffffffffc0203618 <find_vma>
        assert(vma3 == NULL);
ffffffffc0203a60:	16051f63          	bnez	a0,ffffffffc0203bde <vmm_init+0x2a4>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0203a64:	00340593          	addi	a1,s0,3
ffffffffc0203a68:	8526                	mv	a0,s1
ffffffffc0203a6a:	bafff0ef          	jal	ra,ffffffffc0203618 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203a6e:	1a051863          	bnez	a0,ffffffffc0203c1e <vmm_init+0x2e4>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0203a72:	00440593          	addi	a1,s0,4
ffffffffc0203a76:	8526                	mv	a0,s1
ffffffffc0203a78:	ba1ff0ef          	jal	ra,ffffffffc0203618 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203a7c:	18051163          	bnez	a0,ffffffffc0203bfe <vmm_init+0x2c4>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203a80:	00893783          	ld	a5,8(s2)
ffffffffc0203a84:	0a879d63          	bne	a5,s0,ffffffffc0203b3e <vmm_init+0x204>
ffffffffc0203a88:	01093783          	ld	a5,16(s2)
ffffffffc0203a8c:	0b479963          	bne	a5,s4,ffffffffc0203b3e <vmm_init+0x204>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203a90:	0089b783          	ld	a5,8(s3)
ffffffffc0203a94:	0c879563          	bne	a5,s0,ffffffffc0203b5e <vmm_init+0x224>
ffffffffc0203a98:	0109b783          	ld	a5,16(s3)
ffffffffc0203a9c:	0d479163          	bne	a5,s4,ffffffffc0203b5e <vmm_init+0x224>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203aa0:	0415                	addi	s0,s0,5
ffffffffc0203aa2:	0a15                	addi	s4,s4,5
ffffffffc0203aa4:	f9541be3          	bne	s0,s5,ffffffffc0203a3a <vmm_init+0x100>
ffffffffc0203aa8:	4411                	li	s0,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0203aaa:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0203aac:	85a2                	mv	a1,s0
ffffffffc0203aae:	8526                	mv	a0,s1
ffffffffc0203ab0:	b69ff0ef          	jal	ra,ffffffffc0203618 <find_vma>
ffffffffc0203ab4:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL)
ffffffffc0203ab8:	c90d                	beqz	a0,ffffffffc0203aea <vmm_init+0x1b0>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0203aba:	6914                	ld	a3,16(a0)
ffffffffc0203abc:	6510                	ld	a2,8(a0)
ffffffffc0203abe:	00003517          	auipc	a0,0x3
ffffffffc0203ac2:	57250513          	addi	a0,a0,1394 # ffffffffc0207030 <default_pmm_manager+0x980>
ffffffffc0203ac6:	ed2fc0ef          	jal	ra,ffffffffc0200198 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203aca:	00003697          	auipc	a3,0x3
ffffffffc0203ace:	58e68693          	addi	a3,a3,1422 # ffffffffc0207058 <default_pmm_manager+0x9a8>
ffffffffc0203ad2:	00003617          	auipc	a2,0x3
ffffffffc0203ad6:	82e60613          	addi	a2,a2,-2002 # ffffffffc0206300 <commands+0x850>
ffffffffc0203ada:	15900593          	li	a1,345
ffffffffc0203ade:	00003517          	auipc	a0,0x3
ffffffffc0203ae2:	37a50513          	addi	a0,a0,890 # ffffffffc0206e58 <default_pmm_manager+0x7a8>
ffffffffc0203ae6:	9adfc0ef          	jal	ra,ffffffffc0200492 <__panic>
    for (i = 4; i >= 0; i--)
ffffffffc0203aea:	147d                	addi	s0,s0,-1
ffffffffc0203aec:	fd2410e3          	bne	s0,s2,ffffffffc0203aac <vmm_init+0x172>
    }

    mm_destroy(mm);
ffffffffc0203af0:	8526                	mv	a0,s1
ffffffffc0203af2:	c37ff0ef          	jal	ra,ffffffffc0203728 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203af6:	00003517          	auipc	a0,0x3
ffffffffc0203afa:	57a50513          	addi	a0,a0,1402 # ffffffffc0207070 <default_pmm_manager+0x9c0>
ffffffffc0203afe:	e9afc0ef          	jal	ra,ffffffffc0200198 <cprintf>
}
ffffffffc0203b02:	7442                	ld	s0,48(sp)
ffffffffc0203b04:	70e2                	ld	ra,56(sp)
ffffffffc0203b06:	74a2                	ld	s1,40(sp)
ffffffffc0203b08:	7902                	ld	s2,32(sp)
ffffffffc0203b0a:	69e2                	ld	s3,24(sp)
ffffffffc0203b0c:	6a42                	ld	s4,16(sp)
ffffffffc0203b0e:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203b10:	00003517          	auipc	a0,0x3
ffffffffc0203b14:	58050513          	addi	a0,a0,1408 # ffffffffc0207090 <default_pmm_manager+0x9e0>
}
ffffffffc0203b18:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203b1a:	e7efc06f          	j	ffffffffc0200198 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203b1e:	00003697          	auipc	a3,0x3
ffffffffc0203b22:	42a68693          	addi	a3,a3,1066 # ffffffffc0206f48 <default_pmm_manager+0x898>
ffffffffc0203b26:	00002617          	auipc	a2,0x2
ffffffffc0203b2a:	7da60613          	addi	a2,a2,2010 # ffffffffc0206300 <commands+0x850>
ffffffffc0203b2e:	13d00593          	li	a1,317
ffffffffc0203b32:	00003517          	auipc	a0,0x3
ffffffffc0203b36:	32650513          	addi	a0,a0,806 # ffffffffc0206e58 <default_pmm_manager+0x7a8>
ffffffffc0203b3a:	959fc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203b3e:	00003697          	auipc	a3,0x3
ffffffffc0203b42:	49268693          	addi	a3,a3,1170 # ffffffffc0206fd0 <default_pmm_manager+0x920>
ffffffffc0203b46:	00002617          	auipc	a2,0x2
ffffffffc0203b4a:	7ba60613          	addi	a2,a2,1978 # ffffffffc0206300 <commands+0x850>
ffffffffc0203b4e:	14e00593          	li	a1,334
ffffffffc0203b52:	00003517          	auipc	a0,0x3
ffffffffc0203b56:	30650513          	addi	a0,a0,774 # ffffffffc0206e58 <default_pmm_manager+0x7a8>
ffffffffc0203b5a:	939fc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203b5e:	00003697          	auipc	a3,0x3
ffffffffc0203b62:	4a268693          	addi	a3,a3,1186 # ffffffffc0207000 <default_pmm_manager+0x950>
ffffffffc0203b66:	00002617          	auipc	a2,0x2
ffffffffc0203b6a:	79a60613          	addi	a2,a2,1946 # ffffffffc0206300 <commands+0x850>
ffffffffc0203b6e:	14f00593          	li	a1,335
ffffffffc0203b72:	00003517          	auipc	a0,0x3
ffffffffc0203b76:	2e650513          	addi	a0,a0,742 # ffffffffc0206e58 <default_pmm_manager+0x7a8>
ffffffffc0203b7a:	919fc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203b7e:	00003697          	auipc	a3,0x3
ffffffffc0203b82:	3b268693          	addi	a3,a3,946 # ffffffffc0206f30 <default_pmm_manager+0x880>
ffffffffc0203b86:	00002617          	auipc	a2,0x2
ffffffffc0203b8a:	77a60613          	addi	a2,a2,1914 # ffffffffc0206300 <commands+0x850>
ffffffffc0203b8e:	13b00593          	li	a1,315
ffffffffc0203b92:	00003517          	auipc	a0,0x3
ffffffffc0203b96:	2c650513          	addi	a0,a0,710 # ffffffffc0206e58 <default_pmm_manager+0x7a8>
ffffffffc0203b9a:	8f9fc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(vma2 != NULL);
ffffffffc0203b9e:	00003697          	auipc	a3,0x3
ffffffffc0203ba2:	3f268693          	addi	a3,a3,1010 # ffffffffc0206f90 <default_pmm_manager+0x8e0>
ffffffffc0203ba6:	00002617          	auipc	a2,0x2
ffffffffc0203baa:	75a60613          	addi	a2,a2,1882 # ffffffffc0206300 <commands+0x850>
ffffffffc0203bae:	14600593          	li	a1,326
ffffffffc0203bb2:	00003517          	auipc	a0,0x3
ffffffffc0203bb6:	2a650513          	addi	a0,a0,678 # ffffffffc0206e58 <default_pmm_manager+0x7a8>
ffffffffc0203bba:	8d9fc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(vma1 != NULL);
ffffffffc0203bbe:	00003697          	auipc	a3,0x3
ffffffffc0203bc2:	3c268693          	addi	a3,a3,962 # ffffffffc0206f80 <default_pmm_manager+0x8d0>
ffffffffc0203bc6:	00002617          	auipc	a2,0x2
ffffffffc0203bca:	73a60613          	addi	a2,a2,1850 # ffffffffc0206300 <commands+0x850>
ffffffffc0203bce:	14400593          	li	a1,324
ffffffffc0203bd2:	00003517          	auipc	a0,0x3
ffffffffc0203bd6:	28650513          	addi	a0,a0,646 # ffffffffc0206e58 <default_pmm_manager+0x7a8>
ffffffffc0203bda:	8b9fc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(vma3 == NULL);
ffffffffc0203bde:	00003697          	auipc	a3,0x3
ffffffffc0203be2:	3c268693          	addi	a3,a3,962 # ffffffffc0206fa0 <default_pmm_manager+0x8f0>
ffffffffc0203be6:	00002617          	auipc	a2,0x2
ffffffffc0203bea:	71a60613          	addi	a2,a2,1818 # ffffffffc0206300 <commands+0x850>
ffffffffc0203bee:	14800593          	li	a1,328
ffffffffc0203bf2:	00003517          	auipc	a0,0x3
ffffffffc0203bf6:	26650513          	addi	a0,a0,614 # ffffffffc0206e58 <default_pmm_manager+0x7a8>
ffffffffc0203bfa:	899fc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(vma5 == NULL);
ffffffffc0203bfe:	00003697          	auipc	a3,0x3
ffffffffc0203c02:	3c268693          	addi	a3,a3,962 # ffffffffc0206fc0 <default_pmm_manager+0x910>
ffffffffc0203c06:	00002617          	auipc	a2,0x2
ffffffffc0203c0a:	6fa60613          	addi	a2,a2,1786 # ffffffffc0206300 <commands+0x850>
ffffffffc0203c0e:	14c00593          	li	a1,332
ffffffffc0203c12:	00003517          	auipc	a0,0x3
ffffffffc0203c16:	24650513          	addi	a0,a0,582 # ffffffffc0206e58 <default_pmm_manager+0x7a8>
ffffffffc0203c1a:	879fc0ef          	jal	ra,ffffffffc0200492 <__panic>
        assert(vma4 == NULL);
ffffffffc0203c1e:	00003697          	auipc	a3,0x3
ffffffffc0203c22:	39268693          	addi	a3,a3,914 # ffffffffc0206fb0 <default_pmm_manager+0x900>
ffffffffc0203c26:	00002617          	auipc	a2,0x2
ffffffffc0203c2a:	6da60613          	addi	a2,a2,1754 # ffffffffc0206300 <commands+0x850>
ffffffffc0203c2e:	14a00593          	li	a1,330
ffffffffc0203c32:	00003517          	auipc	a0,0x3
ffffffffc0203c36:	22650513          	addi	a0,a0,550 # ffffffffc0206e58 <default_pmm_manager+0x7a8>
ffffffffc0203c3a:	859fc0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(mm != NULL);
ffffffffc0203c3e:	00003697          	auipc	a3,0x3
ffffffffc0203c42:	2a268693          	addi	a3,a3,674 # ffffffffc0206ee0 <default_pmm_manager+0x830>
ffffffffc0203c46:	00002617          	auipc	a2,0x2
ffffffffc0203c4a:	6ba60613          	addi	a2,a2,1722 # ffffffffc0206300 <commands+0x850>
ffffffffc0203c4e:	12400593          	li	a1,292
ffffffffc0203c52:	00003517          	auipc	a0,0x3
ffffffffc0203c56:	20650513          	addi	a0,a0,518 # ffffffffc0206e58 <default_pmm_manager+0x7a8>
ffffffffc0203c5a:	839fc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0203c5e <user_mem_check>:
}
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc0203c5e:	7179                	addi	sp,sp,-48
ffffffffc0203c60:	f022                	sd	s0,32(sp)
ffffffffc0203c62:	f406                	sd	ra,40(sp)
ffffffffc0203c64:	ec26                	sd	s1,24(sp)
ffffffffc0203c66:	e84a                	sd	s2,16(sp)
ffffffffc0203c68:	e44e                	sd	s3,8(sp)
ffffffffc0203c6a:	e052                	sd	s4,0(sp)
ffffffffc0203c6c:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc0203c6e:	c135                	beqz	a0,ffffffffc0203cd2 <user_mem_check+0x74>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc0203c70:	002007b7          	lui	a5,0x200
ffffffffc0203c74:	04f5e663          	bltu	a1,a5,ffffffffc0203cc0 <user_mem_check+0x62>
ffffffffc0203c78:	00c584b3          	add	s1,a1,a2
ffffffffc0203c7c:	0495f263          	bgeu	a1,s1,ffffffffc0203cc0 <user_mem_check+0x62>
ffffffffc0203c80:	4785                	li	a5,1
ffffffffc0203c82:	07fe                	slli	a5,a5,0x1f
ffffffffc0203c84:	0297ee63          	bltu	a5,s1,ffffffffc0203cc0 <user_mem_check+0x62>
ffffffffc0203c88:	892a                	mv	s2,a0
ffffffffc0203c8a:	89b6                	mv	s3,a3
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203c8c:	6a05                	lui	s4,0x1
ffffffffc0203c8e:	a821                	j	ffffffffc0203ca6 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203c90:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203c94:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203c96:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203c98:	c685                	beqz	a3,ffffffffc0203cc0 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203c9a:	c399                	beqz	a5,ffffffffc0203ca0 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203c9c:	02e46263          	bltu	s0,a4,ffffffffc0203cc0 <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0203ca0:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc0203ca2:	04947663          	bgeu	s0,s1,ffffffffc0203cee <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc0203ca6:	85a2                	mv	a1,s0
ffffffffc0203ca8:	854a                	mv	a0,s2
ffffffffc0203caa:	96fff0ef          	jal	ra,ffffffffc0203618 <find_vma>
ffffffffc0203cae:	c909                	beqz	a0,ffffffffc0203cc0 <user_mem_check+0x62>
ffffffffc0203cb0:	6518                	ld	a4,8(a0)
ffffffffc0203cb2:	00e46763          	bltu	s0,a4,ffffffffc0203cc0 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203cb6:	4d1c                	lw	a5,24(a0)
ffffffffc0203cb8:	fc099ce3          	bnez	s3,ffffffffc0203c90 <user_mem_check+0x32>
ffffffffc0203cbc:	8b85                	andi	a5,a5,1
ffffffffc0203cbe:	f3ed                	bnez	a5,ffffffffc0203ca0 <user_mem_check+0x42>
            return 0;
ffffffffc0203cc0:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0203cc2:	70a2                	ld	ra,40(sp)
ffffffffc0203cc4:	7402                	ld	s0,32(sp)
ffffffffc0203cc6:	64e2                	ld	s1,24(sp)
ffffffffc0203cc8:	6942                	ld	s2,16(sp)
ffffffffc0203cca:	69a2                	ld	s3,8(sp)
ffffffffc0203ccc:	6a02                	ld	s4,0(sp)
ffffffffc0203cce:	6145                	addi	sp,sp,48
ffffffffc0203cd0:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203cd2:	c02007b7          	lui	a5,0xc0200
ffffffffc0203cd6:	4501                	li	a0,0
ffffffffc0203cd8:	fef5e5e3          	bltu	a1,a5,ffffffffc0203cc2 <user_mem_check+0x64>
ffffffffc0203cdc:	962e                	add	a2,a2,a1
ffffffffc0203cde:	fec5f2e3          	bgeu	a1,a2,ffffffffc0203cc2 <user_mem_check+0x64>
ffffffffc0203ce2:	c8000537          	lui	a0,0xc8000
ffffffffc0203ce6:	0505                	addi	a0,a0,1
ffffffffc0203ce8:	00a63533          	sltu	a0,a2,a0
ffffffffc0203cec:	bfd9                	j	ffffffffc0203cc2 <user_mem_check+0x64>
        return 1;
ffffffffc0203cee:	4505                	li	a0,1
ffffffffc0203cf0:	bfc9                	j	ffffffffc0203cc2 <user_mem_check+0x64>

ffffffffc0203cf2 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0203cf2:	8526                	mv	a0,s1
	jalr s0
ffffffffc0203cf4:	9402                	jalr	s0

	jal do_exit
ffffffffc0203cf6:	5b8000ef          	jal	ra,ffffffffc02042ae <do_exit>

ffffffffc0203cfa <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc0203cfa:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203cfc:	14800513          	li	a0,328
{
ffffffffc0203d00:	e022                	sd	s0,0(sp)
ffffffffc0203d02:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203d04:	ee3fd0ef          	jal	ra,ffffffffc0201be6 <kmalloc>
ffffffffc0203d08:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc0203d0a:	cd35                	beqz	a0,ffffffffc0203d86 <alloc_proc+0x8c>
         *       uint32_t flags;                             // Process flag
         *       char name[PROC_NAME_LEN + 1];               // Process name
         */

        /* 初始化一个新的进程控制块的最基本字段，不进行资源分配 */
        proc->state = PROC_UNINIT;        // 尚未进入就绪态
ffffffffc0203d0c:	57fd                	li	a5,-1
ffffffffc0203d0e:	1782                	slli	a5,a5,0x20
ffffffffc0203d10:	e11c                	sd	a5,0(a0)
        proc->runs = 0;                   // 运行次数计数器清零
        proc->kstack = 0;                 // 还未分配内核栈
        proc->need_resched = 0;           // 默认不请求调度
        proc->parent = NULL;              // 父进程待后续设置
        proc->mm = NULL;                  // 地址空间后续 copy/share
        memset(&proc->context, 0, sizeof(struct context)); // 确保首次 switch_to 有确定值
ffffffffc0203d12:	07000613          	li	a2,112
ffffffffc0203d16:	4581                	li	a1,0
        proc->runs = 0;                   // 运行次数计数器清零
ffffffffc0203d18:	00052423          	sw	zero,8(a0) # ffffffffc8000008 <end+0x7d39280>
        proc->kstack = 0;                 // 还未分配内核栈
ffffffffc0203d1c:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;           // 默认不请求调度
ffffffffc0203d20:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;              // 父进程待后续设置
ffffffffc0203d24:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;                  // 地址空间后续 copy/share
ffffffffc0203d28:	02053423          	sd	zero,40(a0)
        memset(&proc->context, 0, sizeof(struct context)); // 确保首次 switch_to 有确定值
ffffffffc0203d2c:	03050513          	addi	a0,a0,48
ffffffffc0203d30:	2eb010ef          	jal	ra,ffffffffc020581a <memset>
        proc->tf = NULL;                  // trapframe 等栈建立后 copy_thread 设置
        proc->pgdir = boot_pgdir_pa;      // 先使用内核页表基址
ffffffffc0203d34:	000c3797          	auipc	a5,0xc3
ffffffffc0203d38:	ff47b783          	ld	a5,-12(a5) # ffffffffc02c6d28 <boot_pgdir_pa>
ffffffffc0203d3c:	f45c                	sd	a5,168(s0)
        proc->tf = NULL;                  // trapframe 等栈建立后 copy_thread 设置
ffffffffc0203d3e:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;                  // 初始无标志
ffffffffc0203d42:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, sizeof(proc->name)); // 进程名清零，后续 set_proc_name
ffffffffc0203d46:	4641                	li	a2,16
ffffffffc0203d48:	4581                	li	a1,0
ffffffffc0203d4a:	0b440513          	addi	a0,s0,180
ffffffffc0203d4e:	2cd010ef          	jal	ra,ffffffffc020581a <memset>
         *       skew_heap_entry_t lab6_run_pool;            // entry in the run pool (lab6 stride)
         *       uint32_t lab6_stride;                       // stride value (lab6 stride)
         *       uint32_t lab6_priority;                     // priority value (lab6 stride)
         */
        proc->rq = NULL;                  // 运行队列指针
        list_init(&proc->run_link);       // 初始化运行链表项
ffffffffc0203d52:	11040793          	addi	a5,s0,272
        proc->exit_code = 0;              // 退出码初始化为0
ffffffffc0203d56:	0e043423          	sd	zero,232(s0)
        proc->cptr = proc->yptr = proc->optr = NULL; // 进程关系指针初始化为NULL
ffffffffc0203d5a:	0e043823          	sd	zero,240(s0)
ffffffffc0203d5e:	0e043c23          	sd	zero,248(s0)
ffffffffc0203d62:	10043023          	sd	zero,256(s0)
        proc->rq = NULL;                  // 运行队列指针
ffffffffc0203d66:	10043423          	sd	zero,264(s0)
    elm->prev = elm->next = elm;
ffffffffc0203d6a:	10f43c23          	sd	a5,280(s0)
ffffffffc0203d6e:	10f43823          	sd	a5,272(s0)
        proc->time_slice = 0;             // 时间片初始化为0
ffffffffc0203d72:	12042023          	sw	zero,288(s0)
        proc->lab6_run_pool.left = NULL;  // Stride堆池左孩子
        proc->lab6_run_pool.right = NULL; // Stride堆池右孩子
        proc->lab6_run_pool.parent = NULL; // Stride堆池父节点
ffffffffc0203d76:	12043423          	sd	zero,296(s0)
        proc->lab6_run_pool.left = NULL;  // Stride堆池左孩子
ffffffffc0203d7a:	12043823          	sd	zero,304(s0)
        proc->lab6_run_pool.right = NULL; // Stride堆池右孩子
ffffffffc0203d7e:	12043c23          	sd	zero,312(s0)
        proc->lab6_stride = 0;            // Stride值初始化为0
ffffffffc0203d82:	14043023          	sd	zero,320(s0)
        proc->lab6_priority = 0;          // 优先级初始化为0
    }
    return proc;
}
ffffffffc0203d86:	60a2                	ld	ra,8(sp)
ffffffffc0203d88:	8522                	mv	a0,s0
ffffffffc0203d8a:	6402                	ld	s0,0(sp)
ffffffffc0203d8c:	0141                	addi	sp,sp,16
ffffffffc0203d8e:	8082                	ret

ffffffffc0203d90 <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc0203d90:	000c3797          	auipc	a5,0xc3
ffffffffc0203d94:	fc87b783          	ld	a5,-56(a5) # ffffffffc02c6d58 <current>
ffffffffc0203d98:	73c8                	ld	a0,160(a5)
ffffffffc0203d9a:	968fd06f          	j	ffffffffc0200f02 <forkrets>

ffffffffc0203d9e <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0203d9e:	6d14                	ld	a3,24(a0)
}

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm)
{
ffffffffc0203da0:	1141                	addi	sp,sp,-16
ffffffffc0203da2:	e406                	sd	ra,8(sp)
ffffffffc0203da4:	c02007b7          	lui	a5,0xc0200
ffffffffc0203da8:	02f6ee63          	bltu	a3,a5,ffffffffc0203de4 <put_pgdir+0x46>
ffffffffc0203dac:	000c3517          	auipc	a0,0xc3
ffffffffc0203db0:	fa453503          	ld	a0,-92(a0) # ffffffffc02c6d50 <va_pa_offset>
ffffffffc0203db4:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage)
ffffffffc0203db6:	82b1                	srli	a3,a3,0xc
ffffffffc0203db8:	000c3797          	auipc	a5,0xc3
ffffffffc0203dbc:	f807b783          	ld	a5,-128(a5) # ffffffffc02c6d38 <npage>
ffffffffc0203dc0:	02f6fe63          	bgeu	a3,a5,ffffffffc0203dfc <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203dc4:	00004517          	auipc	a0,0x4
ffffffffc0203dc8:	3a453503          	ld	a0,932(a0) # ffffffffc0208168 <nbase>
    free_page(kva2page(mm->pgdir));
}
ffffffffc0203dcc:	60a2                	ld	ra,8(sp)
ffffffffc0203dce:	8e89                	sub	a3,a3,a0
ffffffffc0203dd0:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0203dd2:	000c3517          	auipc	a0,0xc3
ffffffffc0203dd6:	f6e53503          	ld	a0,-146(a0) # ffffffffc02c6d40 <pages>
ffffffffc0203dda:	4585                	li	a1,1
ffffffffc0203ddc:	9536                	add	a0,a0,a3
}
ffffffffc0203dde:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0203de0:	822fe06f          	j	ffffffffc0201e02 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0203de4:	00003617          	auipc	a2,0x3
ffffffffc0203de8:	9ac60613          	addi	a2,a2,-1620 # ffffffffc0206790 <default_pmm_manager+0xe0>
ffffffffc0203dec:	07700593          	li	a1,119
ffffffffc0203df0:	00003517          	auipc	a0,0x3
ffffffffc0203df4:	92050513          	addi	a0,a0,-1760 # ffffffffc0206710 <default_pmm_manager+0x60>
ffffffffc0203df8:	e9afc0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203dfc:	00003617          	auipc	a2,0x3
ffffffffc0203e00:	9bc60613          	addi	a2,a2,-1604 # ffffffffc02067b8 <default_pmm_manager+0x108>
ffffffffc0203e04:	06900593          	li	a1,105
ffffffffc0203e08:	00003517          	auipc	a0,0x3
ffffffffc0203e0c:	90850513          	addi	a0,a0,-1784 # ffffffffc0206710 <default_pmm_manager+0x60>
ffffffffc0203e10:	e82fc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0203e14 <proc_run>:
{
ffffffffc0203e14:	7179                	addi	sp,sp,-48
ffffffffc0203e16:	f026                	sd	s1,32(sp)
    if (proc != current)
ffffffffc0203e18:	000c3497          	auipc	s1,0xc3
ffffffffc0203e1c:	f4048493          	addi	s1,s1,-192 # ffffffffc02c6d58 <current>
ffffffffc0203e20:	6098                	ld	a4,0(s1)
{
ffffffffc0203e22:	f406                	sd	ra,40(sp)
ffffffffc0203e24:	ec4a                	sd	s2,24(sp)
    if (proc != current)
ffffffffc0203e26:	02a70763          	beq	a4,a0,ffffffffc0203e54 <proc_run+0x40>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203e2a:	100027f3          	csrr	a5,sstatus
ffffffffc0203e2e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203e30:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203e32:	ef85                	bnez	a5,ffffffffc0203e6a <proc_run+0x56>
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned long pgdir)
{
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc0203e34:	755c                	ld	a5,168(a0)
ffffffffc0203e36:	56fd                	li	a3,-1
ffffffffc0203e38:	16fe                	slli	a3,a3,0x3f
ffffffffc0203e3a:	83b1                	srli	a5,a5,0xc
            current = proc;
ffffffffc0203e3c:	e088                	sd	a0,0(s1)
ffffffffc0203e3e:	8fd5                	or	a5,a5,a3
ffffffffc0203e40:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(proc->context));
ffffffffc0203e44:	03050593          	addi	a1,a0,48
ffffffffc0203e48:	03070513          	addi	a0,a4,48
ffffffffc0203e4c:	102010ef          	jal	ra,ffffffffc0204f4e <switch_to>
    if (flag)
ffffffffc0203e50:	00091763          	bnez	s2,ffffffffc0203e5e <proc_run+0x4a>
}
ffffffffc0203e54:	70a2                	ld	ra,40(sp)
ffffffffc0203e56:	7482                	ld	s1,32(sp)
ffffffffc0203e58:	6962                	ld	s2,24(sp)
ffffffffc0203e5a:	6145                	addi	sp,sp,48
ffffffffc0203e5c:	8082                	ret
ffffffffc0203e5e:	70a2                	ld	ra,40(sp)
ffffffffc0203e60:	7482                	ld	s1,32(sp)
ffffffffc0203e62:	6962                	ld	s2,24(sp)
ffffffffc0203e64:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0203e66:	b43fc06f          	j	ffffffffc02009a8 <intr_enable>
ffffffffc0203e6a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203e6c:	b43fc0ef          	jal	ra,ffffffffc02009ae <intr_disable>
            struct proc_struct *prev = current;
ffffffffc0203e70:	6098                	ld	a4,0(s1)
        return 1;
ffffffffc0203e72:	6522                	ld	a0,8(sp)
ffffffffc0203e74:	4905                	li	s2,1
ffffffffc0203e76:	bf7d                	j	ffffffffc0203e34 <proc_run+0x20>

ffffffffc0203e78 <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf)
{
ffffffffc0203e78:	7119                	addi	sp,sp,-128
ffffffffc0203e7a:	f4a6                	sd	s1,104(sp)
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS)
ffffffffc0203e7c:	000c3497          	auipc	s1,0xc3
ffffffffc0203e80:	ef448493          	addi	s1,s1,-268 # ffffffffc02c6d70 <nr_process>
ffffffffc0203e84:	4098                	lw	a4,0(s1)
{
ffffffffc0203e86:	fc86                	sd	ra,120(sp)
ffffffffc0203e88:	f8a2                	sd	s0,112(sp)
ffffffffc0203e8a:	f0ca                	sd	s2,96(sp)
ffffffffc0203e8c:	ecce                	sd	s3,88(sp)
ffffffffc0203e8e:	e8d2                	sd	s4,80(sp)
ffffffffc0203e90:	e4d6                	sd	s5,72(sp)
ffffffffc0203e92:	e0da                	sd	s6,64(sp)
ffffffffc0203e94:	fc5e                	sd	s7,56(sp)
ffffffffc0203e96:	f862                	sd	s8,48(sp)
ffffffffc0203e98:	f466                	sd	s9,40(sp)
ffffffffc0203e9a:	f06a                	sd	s10,32(sp)
ffffffffc0203e9c:	ec6e                	sd	s11,24(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0203e9e:	6785                	lui	a5,0x1
ffffffffc0203ea0:	30f75463          	bge	a4,a5,ffffffffc02041a8 <do_fork+0x330>
ffffffffc0203ea4:	8a2a                	mv	s4,a0
ffffffffc0203ea6:	892e                	mv	s2,a1
ffffffffc0203ea8:	89b2                	mv	s3,a2
     *    set_links:  set the relation links of process.  ALSO SEE: remove_links:  lean the relation links of process
     *    -------------------
     *    update step 1: set child proc's parent to current process, make sure current process's wait_state is 0
     *    update step 5: insert proc_struct into hash_list && proc_list, set the relation links of process
     */
    if ((proc = alloc_proc()) == NULL)
ffffffffc0203eaa:	e51ff0ef          	jal	ra,ffffffffc0203cfa <alloc_proc>
ffffffffc0203eae:	842a                	mv	s0,a0
ffffffffc0203eb0:	30050363          	beqz	a0,ffffffffc02041b6 <do_fork+0x33e>
    {
        goto fork_out;
    }

    proc->parent = current;
ffffffffc0203eb4:	000c3b97          	auipc	s7,0xc3
ffffffffc0203eb8:	ea4b8b93          	addi	s7,s7,-348 # ffffffffc02c6d58 <current>
ffffffffc0203ebc:	000bb783          	ld	a5,0(s7)
    // LAB5: 确保父进程的wait_state为0
    assert(current->wait_state == 0);
ffffffffc0203ec0:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8e64>
    proc->parent = current;
ffffffffc0203ec4:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc0203ec6:	2e071f63          	bnez	a4,ffffffffc02041c4 <do_fork+0x34c>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0203eca:	4509                	li	a0,2
ffffffffc0203ecc:	ef9fd0ef          	jal	ra,ffffffffc0201dc4 <alloc_pages>
    if (page != NULL)
ffffffffc0203ed0:	2c050a63          	beqz	a0,ffffffffc02041a4 <do_fork+0x32c>
    return page - pages + nbase;
ffffffffc0203ed4:	000c3c97          	auipc	s9,0xc3
ffffffffc0203ed8:	e6cc8c93          	addi	s9,s9,-404 # ffffffffc02c6d40 <pages>
ffffffffc0203edc:	000cb683          	ld	a3,0(s9)
ffffffffc0203ee0:	00004a97          	auipc	s5,0x4
ffffffffc0203ee4:	288a8a93          	addi	s5,s5,648 # ffffffffc0208168 <nbase>
ffffffffc0203ee8:	000ab703          	ld	a4,0(s5)
ffffffffc0203eec:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0203ef0:	000c3d17          	auipc	s10,0xc3
ffffffffc0203ef4:	e48d0d13          	addi	s10,s10,-440 # ffffffffc02c6d38 <npage>
    return page - pages + nbase;
ffffffffc0203ef8:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0203efa:	5b7d                	li	s6,-1
ffffffffc0203efc:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc0203f00:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0203f02:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0203f06:	0166f633          	and	a2,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0203f0a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203f0c:	2cf67c63          	bgeu	a2,a5,ffffffffc02041e4 <do_fork+0x36c>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0203f10:	000bb603          	ld	a2,0(s7)
ffffffffc0203f14:	000c3d97          	auipc	s11,0xc3
ffffffffc0203f18:	e3cd8d93          	addi	s11,s11,-452 # ffffffffc02c6d50 <va_pa_offset>
ffffffffc0203f1c:	000db783          	ld	a5,0(s11)
ffffffffc0203f20:	02863b83          	ld	s7,40(a2)
ffffffffc0203f24:	e43a                	sd	a4,8(sp)
ffffffffc0203f26:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0203f28:	e814                	sd	a3,16(s0)
    if (oldmm == NULL)
ffffffffc0203f2a:	020b8863          	beqz	s7,ffffffffc0203f5a <do_fork+0xe2>
    if (clone_flags & CLONE_VM)
ffffffffc0203f2e:	100a7a13          	andi	s4,s4,256
ffffffffc0203f32:	180a0963          	beqz	s4,ffffffffc02040c4 <do_fork+0x24c>
}

static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
ffffffffc0203f36:	030ba703          	lw	a4,48(s7)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0203f3a:	018bb783          	ld	a5,24(s7)
ffffffffc0203f3e:	c02006b7          	lui	a3,0xc0200
ffffffffc0203f42:	2705                	addiw	a4,a4,1
ffffffffc0203f44:	02eba823          	sw	a4,48(s7)
    proc->mm = mm;
ffffffffc0203f48:	03743423          	sd	s7,40(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0203f4c:	2ed7ec63          	bltu	a5,a3,ffffffffc0204244 <do_fork+0x3cc>
ffffffffc0203f50:	000db703          	ld	a4,0(s11)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0203f54:	6814                	ld	a3,16(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0203f56:	8f99                	sub	a5,a5,a4
ffffffffc0203f58:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0203f5a:	6789                	lui	a5,0x2
ffffffffc0203f5c:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x8070>
ffffffffc0203f60:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0203f62:	864e                	mv	a2,s3
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0203f64:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0203f66:	87b6                	mv	a5,a3
ffffffffc0203f68:	12098893          	addi	a7,s3,288
ffffffffc0203f6c:	00063803          	ld	a6,0(a2)
ffffffffc0203f70:	6608                	ld	a0,8(a2)
ffffffffc0203f72:	6a0c                	ld	a1,16(a2)
ffffffffc0203f74:	6e18                	ld	a4,24(a2)
ffffffffc0203f76:	0107b023          	sd	a6,0(a5)
ffffffffc0203f7a:	e788                	sd	a0,8(a5)
ffffffffc0203f7c:	eb8c                	sd	a1,16(a5)
ffffffffc0203f7e:	ef98                	sd	a4,24(a5)
ffffffffc0203f80:	02060613          	addi	a2,a2,32
ffffffffc0203f84:	02078793          	addi	a5,a5,32
ffffffffc0203f88:	ff1612e3          	bne	a2,a7,ffffffffc0203f6c <do_fork+0xf4>
    proc->tf->gpr.a0 = 0;
ffffffffc0203f8c:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x6>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0203f90:	1c090463          	beqz	s2,ffffffffc0204158 <do_fork+0x2e0>
    if (++last_pid >= MAX_PID)
ffffffffc0203f94:	000bf817          	auipc	a6,0xbf
ffffffffc0203f98:	90c80813          	addi	a6,a6,-1780 # ffffffffc02c28a0 <last_pid.1>
ffffffffc0203f9c:	00082783          	lw	a5,0(a6)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0203fa0:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0203fa4:	00000717          	auipc	a4,0x0
ffffffffc0203fa8:	dec70713          	addi	a4,a4,-532 # ffffffffc0203d90 <forkret>
    if (++last_pid >= MAX_PID)
ffffffffc0203fac:	0017851b          	addiw	a0,a5,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0203fb0:	f818                	sd	a4,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0203fb2:	fc14                	sd	a3,56(s0)
    if (++last_pid >= MAX_PID)
ffffffffc0203fb4:	00a82023          	sw	a0,0(a6)
ffffffffc0203fb8:	6789                	lui	a5,0x2
ffffffffc0203fba:	08f55e63          	bge	a0,a5,ffffffffc0204056 <do_fork+0x1de>
    if (last_pid >= next_safe)
ffffffffc0203fbe:	000bf317          	auipc	t1,0xbf
ffffffffc0203fc2:	8e630313          	addi	t1,t1,-1818 # ffffffffc02c28a4 <next_safe.0>
ffffffffc0203fc6:	00032783          	lw	a5,0(t1)
ffffffffc0203fca:	000c3917          	auipc	s2,0xc3
ffffffffc0203fce:	cf690913          	addi	s2,s2,-778 # ffffffffc02c6cc0 <proc_list>
ffffffffc0203fd2:	08f55a63          	bge	a0,a5,ffffffffc0204066 <do_fork+0x1ee>
        goto bad_fork_cleanup_kstack;
    }

    copy_thread(proc, stack, tf);

    proc->pid = get_pid();
ffffffffc0203fd6:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0203fd8:	45a9                	li	a1,10
ffffffffc0203fda:	2501                	sext.w	a0,a0
ffffffffc0203fdc:	398010ef          	jal	ra,ffffffffc0205374 <hash32>
ffffffffc0203fe0:	02051793          	slli	a5,a0,0x20
ffffffffc0203fe4:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0203fe8:	000bf797          	auipc	a5,0xbf
ffffffffc0203fec:	cd878793          	addi	a5,a5,-808 # ffffffffc02c2cc0 <hash_list>
ffffffffc0203ff0:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0203ff2:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0203ff4:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0203ff6:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc0203ffa:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203ffc:	00893603          	ld	a2,8(s2)
    prev->next = next->prev = elm;
ffffffffc0204000:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204002:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0204004:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc0204008:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc020400a:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc020400c:	e21c                	sd	a5,0(a2)
ffffffffc020400e:	00f93423          	sd	a5,8(s2)
    elm->next = next;
ffffffffc0204012:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc0204014:	0d243423          	sd	s2,200(s0)
    proc->yptr = NULL;
ffffffffc0204018:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc020401c:	10e43023          	sd	a4,256(s0)
ffffffffc0204020:	c311                	beqz	a4,ffffffffc0204024 <do_fork+0x1ac>
        proc->optr->yptr = proc;
ffffffffc0204022:	ff60                	sd	s0,248(a4)
    nr_process++;
ffffffffc0204024:	409c                	lw	a5,0(s1)
    proc->parent->cptr = proc;
ffffffffc0204026:	fae0                	sd	s0,240(a3)
    hash_proc(proc);
    // LAB5: 使用set_links来设置进程关系链表
    set_links(proc);

    wakeup_proc(proc);
ffffffffc0204028:	8522                	mv	a0,s0
    nr_process++;
ffffffffc020402a:	2785                	addiw	a5,a5,1
ffffffffc020402c:	c09c                	sw	a5,0(s1)
    wakeup_proc(proc);
ffffffffc020402e:	0d4010ef          	jal	ra,ffffffffc0205102 <wakeup_proc>

    ret = proc->pid;
ffffffffc0204032:	00442a03          	lw	s4,4(s0)
bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
ffffffffc0204036:	70e6                	ld	ra,120(sp)
ffffffffc0204038:	7446                	ld	s0,112(sp)
ffffffffc020403a:	74a6                	ld	s1,104(sp)
ffffffffc020403c:	7906                	ld	s2,96(sp)
ffffffffc020403e:	69e6                	ld	s3,88(sp)
ffffffffc0204040:	6aa6                	ld	s5,72(sp)
ffffffffc0204042:	6b06                	ld	s6,64(sp)
ffffffffc0204044:	7be2                	ld	s7,56(sp)
ffffffffc0204046:	7c42                	ld	s8,48(sp)
ffffffffc0204048:	7ca2                	ld	s9,40(sp)
ffffffffc020404a:	7d02                	ld	s10,32(sp)
ffffffffc020404c:	6de2                	ld	s11,24(sp)
ffffffffc020404e:	8552                	mv	a0,s4
ffffffffc0204050:	6a46                	ld	s4,80(sp)
ffffffffc0204052:	6109                	addi	sp,sp,128
ffffffffc0204054:	8082                	ret
        last_pid = 1;
ffffffffc0204056:	4785                	li	a5,1
ffffffffc0204058:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc020405c:	4505                	li	a0,1
ffffffffc020405e:	000bf317          	auipc	t1,0xbf
ffffffffc0204062:	84630313          	addi	t1,t1,-1978 # ffffffffc02c28a4 <next_safe.0>
    return listelm->next;
ffffffffc0204066:	000c3917          	auipc	s2,0xc3
ffffffffc020406a:	c5a90913          	addi	s2,s2,-934 # ffffffffc02c6cc0 <proc_list>
ffffffffc020406e:	00893e03          	ld	t3,8(s2)
        next_safe = MAX_PID;
ffffffffc0204072:	6789                	lui	a5,0x2
ffffffffc0204074:	00f32023          	sw	a5,0(t1)
ffffffffc0204078:	86aa                	mv	a3,a0
ffffffffc020407a:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc020407c:	6e89                	lui	t4,0x2
ffffffffc020407e:	132e0763          	beq	t3,s2,ffffffffc02041ac <do_fork+0x334>
ffffffffc0204082:	88ae                	mv	a7,a1
ffffffffc0204084:	87f2                	mv	a5,t3
ffffffffc0204086:	6609                	lui	a2,0x2
ffffffffc0204088:	a811                	j	ffffffffc020409c <do_fork+0x224>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc020408a:	00e6d663          	bge	a3,a4,ffffffffc0204096 <do_fork+0x21e>
ffffffffc020408e:	00c75463          	bge	a4,a2,ffffffffc0204096 <do_fork+0x21e>
ffffffffc0204092:	863a                	mv	a2,a4
ffffffffc0204094:	4885                	li	a7,1
ffffffffc0204096:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204098:	01278d63          	beq	a5,s2,ffffffffc02040b2 <do_fork+0x23a>
            if (proc->pid == last_pid)
ffffffffc020409c:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x8014>
ffffffffc02040a0:	fed715e3          	bne	a4,a3,ffffffffc020408a <do_fork+0x212>
                if (++last_pid >= next_safe)
ffffffffc02040a4:	2685                	addiw	a3,a3,1
ffffffffc02040a6:	0ec6da63          	bge	a3,a2,ffffffffc020419a <do_fork+0x322>
ffffffffc02040aa:	679c                	ld	a5,8(a5)
ffffffffc02040ac:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc02040ae:	ff2797e3          	bne	a5,s2,ffffffffc020409c <do_fork+0x224>
ffffffffc02040b2:	c581                	beqz	a1,ffffffffc02040ba <do_fork+0x242>
ffffffffc02040b4:	00d82023          	sw	a3,0(a6)
ffffffffc02040b8:	8536                	mv	a0,a3
ffffffffc02040ba:	f0088ee3          	beqz	a7,ffffffffc0203fd6 <do_fork+0x15e>
ffffffffc02040be:	00c32023          	sw	a2,0(t1)
ffffffffc02040c2:	bf11                	j	ffffffffc0203fd6 <do_fork+0x15e>
    if ((mm = mm_create()) == NULL)
ffffffffc02040c4:	d24ff0ef          	jal	ra,ffffffffc02035e8 <mm_create>
ffffffffc02040c8:	8c2a                	mv	s8,a0
ffffffffc02040ca:	0e050b63          	beqz	a0,ffffffffc02041c0 <do_fork+0x348>
    if ((page = alloc_page()) == NULL)
ffffffffc02040ce:	4505                	li	a0,1
ffffffffc02040d0:	cf5fd0ef          	jal	ra,ffffffffc0201dc4 <alloc_pages>
ffffffffc02040d4:	c541                	beqz	a0,ffffffffc020415c <do_fork+0x2e4>
    return page - pages + nbase;
ffffffffc02040d6:	000cb683          	ld	a3,0(s9)
ffffffffc02040da:	6722                	ld	a4,8(sp)
    return KADDR(page2pa(page));
ffffffffc02040dc:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc02040e0:	40d506b3          	sub	a3,a0,a3
ffffffffc02040e4:	8699                	srai	a3,a3,0x6
ffffffffc02040e6:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02040e8:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02040ec:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02040ee:	0efb7b63          	bgeu	s6,a5,ffffffffc02041e4 <do_fork+0x36c>
ffffffffc02040f2:	000dba03          	ld	s4,0(s11)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc02040f6:	6605                	lui	a2,0x1
ffffffffc02040f8:	000c3597          	auipc	a1,0xc3
ffffffffc02040fc:	c385b583          	ld	a1,-968(a1) # ffffffffc02c6d30 <boot_pgdir_va>
ffffffffc0204100:	9a36                	add	s4,s4,a3
ffffffffc0204102:	8552                	mv	a0,s4
ffffffffc0204104:	728010ef          	jal	ra,ffffffffc020582c <memcpy>
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
ffffffffc0204108:	038b8b13          	addi	s6,s7,56
    mm->pgdir = pgdir;
ffffffffc020410c:	014c3c23          	sd	s4,24(s8)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204110:	4785                	li	a5,1
ffffffffc0204112:	40fb37af          	amoor.d	a5,a5,(s6)
}

static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))
ffffffffc0204116:	8b85                	andi	a5,a5,1
ffffffffc0204118:	4a05                	li	s4,1
ffffffffc020411a:	c799                	beqz	a5,ffffffffc0204128 <do_fork+0x2b0>
    {
        schedule();
ffffffffc020411c:	098010ef          	jal	ra,ffffffffc02051b4 <schedule>
ffffffffc0204120:	414b37af          	amoor.d	a5,s4,(s6)
    while (!try_lock(lock))
ffffffffc0204124:	8b85                	andi	a5,a5,1
ffffffffc0204126:	fbfd                	bnez	a5,ffffffffc020411c <do_fork+0x2a4>
        ret = dup_mmap(mm, oldmm);
ffffffffc0204128:	85de                	mv	a1,s7
ffffffffc020412a:	8562                	mv	a0,s8
ffffffffc020412c:	efeff0ef          	jal	ra,ffffffffc020382a <dup_mmap>
ffffffffc0204130:	8a2a                	mv	s4,a0
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0204132:	57f9                	li	a5,-2
ffffffffc0204134:	60fb37af          	amoand.d	a5,a5,(s6)
ffffffffc0204138:	8b85                	andi	a5,a5,1
}

static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))
ffffffffc020413a:	0e078963          	beqz	a5,ffffffffc020422c <do_fork+0x3b4>
good_mm:
ffffffffc020413e:	8be2                	mv	s7,s8
    if (ret != 0)
ffffffffc0204140:	de050be3          	beqz	a0,ffffffffc0203f36 <do_fork+0xbe>
    exit_mmap(mm);
ffffffffc0204144:	8562                	mv	a0,s8
ffffffffc0204146:	f7eff0ef          	jal	ra,ffffffffc02038c4 <exit_mmap>
    put_pgdir(mm);
ffffffffc020414a:	8562                	mv	a0,s8
ffffffffc020414c:	c53ff0ef          	jal	ra,ffffffffc0203d9e <put_pgdir>
    mm_destroy(mm);
ffffffffc0204150:	8562                	mv	a0,s8
ffffffffc0204152:	dd6ff0ef          	jal	ra,ffffffffc0203728 <mm_destroy>
ffffffffc0204156:	a039                	j	ffffffffc0204164 <do_fork+0x2ec>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204158:	8936                	mv	s2,a3
ffffffffc020415a:	bd2d                	j	ffffffffc0203f94 <do_fork+0x11c>
    mm_destroy(mm);
ffffffffc020415c:	8562                	mv	a0,s8
ffffffffc020415e:	dcaff0ef          	jal	ra,ffffffffc0203728 <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0204162:	5a71                	li	s4,-4
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204164:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0204166:	c02007b7          	lui	a5,0xc0200
ffffffffc020416a:	0af6e563          	bltu	a3,a5,ffffffffc0204214 <do_fork+0x39c>
ffffffffc020416e:	000db703          	ld	a4,0(s11)
    if (PPN(pa) >= npage)
ffffffffc0204172:	000d3783          	ld	a5,0(s10)
    return pa2page(PADDR(kva));
ffffffffc0204176:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage)
ffffffffc0204178:	82b1                	srli	a3,a3,0xc
ffffffffc020417a:	08f6f163          	bgeu	a3,a5,ffffffffc02041fc <do_fork+0x384>
    return &pages[PPN(pa) - nbase];
ffffffffc020417e:	000ab783          	ld	a5,0(s5)
ffffffffc0204182:	000cb503          	ld	a0,0(s9)
ffffffffc0204186:	4589                	li	a1,2
ffffffffc0204188:	8e9d                	sub	a3,a3,a5
ffffffffc020418a:	069a                	slli	a3,a3,0x6
ffffffffc020418c:	9536                	add	a0,a0,a3
ffffffffc020418e:	c75fd0ef          	jal	ra,ffffffffc0201e02 <free_pages>
    kfree(proc);
ffffffffc0204192:	8522                	mv	a0,s0
ffffffffc0204194:	b03fd0ef          	jal	ra,ffffffffc0201c96 <kfree>
    return ret;
ffffffffc0204198:	bd79                	j	ffffffffc0204036 <do_fork+0x1be>
                    if (last_pid >= MAX_PID)
ffffffffc020419a:	01d6c363          	blt	a3,t4,ffffffffc02041a0 <do_fork+0x328>
                        last_pid = 1;
ffffffffc020419e:	4685                	li	a3,1
                    goto repeat;
ffffffffc02041a0:	4585                	li	a1,1
ffffffffc02041a2:	bdf1                	j	ffffffffc020407e <do_fork+0x206>
    return -E_NO_MEM;
ffffffffc02041a4:	5a71                	li	s4,-4
ffffffffc02041a6:	b7f5                	j	ffffffffc0204192 <do_fork+0x31a>
    int ret = -E_NO_FREE_PROC;
ffffffffc02041a8:	5a6d                	li	s4,-5
ffffffffc02041aa:	b571                	j	ffffffffc0204036 <do_fork+0x1be>
ffffffffc02041ac:	c599                	beqz	a1,ffffffffc02041ba <do_fork+0x342>
ffffffffc02041ae:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc02041b2:	8536                	mv	a0,a3
ffffffffc02041b4:	b50d                	j	ffffffffc0203fd6 <do_fork+0x15e>
    ret = -E_NO_MEM;
ffffffffc02041b6:	5a71                	li	s4,-4
ffffffffc02041b8:	bdbd                	j	ffffffffc0204036 <do_fork+0x1be>
    return last_pid;
ffffffffc02041ba:	00082503          	lw	a0,0(a6)
ffffffffc02041be:	bd21                	j	ffffffffc0203fd6 <do_fork+0x15e>
    int ret = -E_NO_MEM;
ffffffffc02041c0:	5a71                	li	s4,-4
ffffffffc02041c2:	b74d                	j	ffffffffc0204164 <do_fork+0x2ec>
    assert(current->wait_state == 0);
ffffffffc02041c4:	00003697          	auipc	a3,0x3
ffffffffc02041c8:	ef468693          	addi	a3,a3,-268 # ffffffffc02070b8 <default_pmm_manager+0xa08>
ffffffffc02041cc:	00002617          	auipc	a2,0x2
ffffffffc02041d0:	13460613          	addi	a2,a2,308 # ffffffffc0206300 <commands+0x850>
ffffffffc02041d4:	1f500593          	li	a1,501
ffffffffc02041d8:	00003517          	auipc	a0,0x3
ffffffffc02041dc:	f0050513          	addi	a0,a0,-256 # ffffffffc02070d8 <default_pmm_manager+0xa28>
ffffffffc02041e0:	ab2fc0ef          	jal	ra,ffffffffc0200492 <__panic>
    return KADDR(page2pa(page));
ffffffffc02041e4:	00002617          	auipc	a2,0x2
ffffffffc02041e8:	50460613          	addi	a2,a2,1284 # ffffffffc02066e8 <default_pmm_manager+0x38>
ffffffffc02041ec:	07100593          	li	a1,113
ffffffffc02041f0:	00002517          	auipc	a0,0x2
ffffffffc02041f4:	52050513          	addi	a0,a0,1312 # ffffffffc0206710 <default_pmm_manager+0x60>
ffffffffc02041f8:	a9afc0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02041fc:	00002617          	auipc	a2,0x2
ffffffffc0204200:	5bc60613          	addi	a2,a2,1468 # ffffffffc02067b8 <default_pmm_manager+0x108>
ffffffffc0204204:	06900593          	li	a1,105
ffffffffc0204208:	00002517          	auipc	a0,0x2
ffffffffc020420c:	50850513          	addi	a0,a0,1288 # ffffffffc0206710 <default_pmm_manager+0x60>
ffffffffc0204210:	a82fc0ef          	jal	ra,ffffffffc0200492 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0204214:	00002617          	auipc	a2,0x2
ffffffffc0204218:	57c60613          	addi	a2,a2,1404 # ffffffffc0206790 <default_pmm_manager+0xe0>
ffffffffc020421c:	07700593          	li	a1,119
ffffffffc0204220:	00002517          	auipc	a0,0x2
ffffffffc0204224:	4f050513          	addi	a0,a0,1264 # ffffffffc0206710 <default_pmm_manager+0x60>
ffffffffc0204228:	a6afc0ef          	jal	ra,ffffffffc0200492 <__panic>
    {
        panic("Unlock failed.\n");
ffffffffc020422c:	00003617          	auipc	a2,0x3
ffffffffc0204230:	ec460613          	addi	a2,a2,-316 # ffffffffc02070f0 <default_pmm_manager+0xa40>
ffffffffc0204234:	04000593          	li	a1,64
ffffffffc0204238:	00003517          	auipc	a0,0x3
ffffffffc020423c:	ec850513          	addi	a0,a0,-312 # ffffffffc0207100 <default_pmm_manager+0xa50>
ffffffffc0204240:	a52fc0ef          	jal	ra,ffffffffc0200492 <__panic>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204244:	86be                	mv	a3,a5
ffffffffc0204246:	00002617          	auipc	a2,0x2
ffffffffc020424a:	54a60613          	addi	a2,a2,1354 # ffffffffc0206790 <default_pmm_manager+0xe0>
ffffffffc020424e:	1a400593          	li	a1,420
ffffffffc0204252:	00003517          	auipc	a0,0x3
ffffffffc0204256:	e8650513          	addi	a0,a0,-378 # ffffffffc02070d8 <default_pmm_manager+0xa28>
ffffffffc020425a:	a38fc0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc020425e <kernel_thread>:
{
ffffffffc020425e:	7129                	addi	sp,sp,-320
ffffffffc0204260:	fa22                	sd	s0,304(sp)
ffffffffc0204262:	f626                	sd	s1,296(sp)
ffffffffc0204264:	f24a                	sd	s2,288(sp)
ffffffffc0204266:	84ae                	mv	s1,a1
ffffffffc0204268:	892a                	mv	s2,a0
ffffffffc020426a:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020426c:	4581                	li	a1,0
ffffffffc020426e:	12000613          	li	a2,288
ffffffffc0204272:	850a                	mv	a0,sp
{
ffffffffc0204274:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204276:	5a4010ef          	jal	ra,ffffffffc020581a <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc020427a:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc020427c:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc020427e:	100027f3          	csrr	a5,sstatus
ffffffffc0204282:	edd7f793          	andi	a5,a5,-291
ffffffffc0204286:	1207e793          	ori	a5,a5,288
ffffffffc020428a:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020428c:	860a                	mv	a2,sp
ffffffffc020428e:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204292:	00000797          	auipc	a5,0x0
ffffffffc0204296:	a6078793          	addi	a5,a5,-1440 # ffffffffc0203cf2 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020429a:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020429c:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020429e:	bdbff0ef          	jal	ra,ffffffffc0203e78 <do_fork>
}
ffffffffc02042a2:	70f2                	ld	ra,312(sp)
ffffffffc02042a4:	7452                	ld	s0,304(sp)
ffffffffc02042a6:	74b2                	ld	s1,296(sp)
ffffffffc02042a8:	7912                	ld	s2,288(sp)
ffffffffc02042aa:	6131                	addi	sp,sp,320
ffffffffc02042ac:	8082                	ret

ffffffffc02042ae <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int do_exit(int error_code)
{
ffffffffc02042ae:	7179                	addi	sp,sp,-48
ffffffffc02042b0:	f022                	sd	s0,32(sp)
    if (current == idleproc)
ffffffffc02042b2:	000c3417          	auipc	s0,0xc3
ffffffffc02042b6:	aa640413          	addi	s0,s0,-1370 # ffffffffc02c6d58 <current>
ffffffffc02042ba:	601c                	ld	a5,0(s0)
{
ffffffffc02042bc:	f406                	sd	ra,40(sp)
ffffffffc02042be:	ec26                	sd	s1,24(sp)
ffffffffc02042c0:	e84a                	sd	s2,16(sp)
ffffffffc02042c2:	e44e                	sd	s3,8(sp)
ffffffffc02042c4:	e052                	sd	s4,0(sp)
    if (current == idleproc)
ffffffffc02042c6:	000c3717          	auipc	a4,0xc3
ffffffffc02042ca:	a9a73703          	ld	a4,-1382(a4) # ffffffffc02c6d60 <idleproc>
ffffffffc02042ce:	0ce78c63          	beq	a5,a4,ffffffffc02043a6 <do_exit+0xf8>
    {
        panic("idleproc exit.\n");
    }
    if (current == initproc)
ffffffffc02042d2:	000c3497          	auipc	s1,0xc3
ffffffffc02042d6:	a9648493          	addi	s1,s1,-1386 # ffffffffc02c6d68 <initproc>
ffffffffc02042da:	6098                	ld	a4,0(s1)
ffffffffc02042dc:	0ee78b63          	beq	a5,a4,ffffffffc02043d2 <do_exit+0x124>
    {
        panic("initproc exit.\n");
    }
    struct mm_struct *mm = current->mm;
ffffffffc02042e0:	0287b983          	ld	s3,40(a5)
ffffffffc02042e4:	892a                	mv	s2,a0
    if (mm != NULL)
ffffffffc02042e6:	02098663          	beqz	s3,ffffffffc0204312 <do_exit+0x64>
ffffffffc02042ea:	000c3797          	auipc	a5,0xc3
ffffffffc02042ee:	a3e7b783          	ld	a5,-1474(a5) # ffffffffc02c6d28 <boot_pgdir_pa>
ffffffffc02042f2:	577d                	li	a4,-1
ffffffffc02042f4:	177e                	slli	a4,a4,0x3f
ffffffffc02042f6:	83b1                	srli	a5,a5,0xc
ffffffffc02042f8:	8fd9                	or	a5,a5,a4
ffffffffc02042fa:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02042fe:	0309a783          	lw	a5,48(s3)
ffffffffc0204302:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204306:	02e9a823          	sw	a4,48(s3)
    {
        lsatp(boot_pgdir_pa);
        if (mm_count_dec(mm) == 0)
ffffffffc020430a:	cb55                	beqz	a4,ffffffffc02043be <do_exit+0x110>
        {
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);
        }
        current->mm = NULL;
ffffffffc020430c:	601c                	ld	a5,0(s0)
ffffffffc020430e:	0207b423          	sd	zero,40(a5)
    }
    current->state = PROC_ZOMBIE;
ffffffffc0204312:	601c                	ld	a5,0(s0)
ffffffffc0204314:	470d                	li	a4,3
ffffffffc0204316:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0204318:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020431c:	100027f3          	csrr	a5,sstatus
ffffffffc0204320:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204322:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204324:	e3f9                	bnez	a5,ffffffffc02043ea <do_exit+0x13c>
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
    {
        proc = current->parent;
ffffffffc0204326:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204328:	800007b7          	lui	a5,0x80000
ffffffffc020432c:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc020432e:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204330:	0ec52703          	lw	a4,236(a0)
ffffffffc0204334:	0af70f63          	beq	a4,a5,ffffffffc02043f2 <do_exit+0x144>
        {
            wakeup_proc(proc);
        }
        while (current->cptr != NULL)
ffffffffc0204338:	6018                	ld	a4,0(s0)
ffffffffc020433a:	7b7c                	ld	a5,240(a4)
ffffffffc020433c:	c3a1                	beqz	a5,ffffffffc020437c <do_exit+0xce>
            }
            proc->parent = initproc;
            initproc->cptr = proc;
            if (proc->state == PROC_ZOMBIE)
            {
                if (initproc->wait_state == WT_CHILD)
ffffffffc020433e:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204342:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204344:	0985                	addi	s3,s3,1
ffffffffc0204346:	a021                	j	ffffffffc020434e <do_exit+0xa0>
        while (current->cptr != NULL)
ffffffffc0204348:	6018                	ld	a4,0(s0)
ffffffffc020434a:	7b7c                	ld	a5,240(a4)
ffffffffc020434c:	cb85                	beqz	a5,ffffffffc020437c <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc020434e:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_matrix_out_size+0xffffffff7fff39d8>
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204352:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc0204354:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204356:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0204358:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc020435c:	10e7b023          	sd	a4,256(a5)
ffffffffc0204360:	c311                	beqz	a4,ffffffffc0204364 <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc0204362:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204364:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0204366:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0204368:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc020436a:	fd271fe3          	bne	a4,s2,ffffffffc0204348 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc020436e:	0ec52783          	lw	a5,236(a0)
ffffffffc0204372:	fd379be3          	bne	a5,s3,ffffffffc0204348 <do_exit+0x9a>
                {
                    wakeup_proc(initproc);
ffffffffc0204376:	58d000ef          	jal	ra,ffffffffc0205102 <wakeup_proc>
ffffffffc020437a:	b7f9                	j	ffffffffc0204348 <do_exit+0x9a>
    if (flag)
ffffffffc020437c:	020a1263          	bnez	s4,ffffffffc02043a0 <do_exit+0xf2>
                }
            }
        }
    }
    local_intr_restore(intr_flag);
    schedule();
ffffffffc0204380:	635000ef          	jal	ra,ffffffffc02051b4 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0204384:	601c                	ld	a5,0(s0)
ffffffffc0204386:	00003617          	auipc	a2,0x3
ffffffffc020438a:	db260613          	addi	a2,a2,-590 # ffffffffc0207138 <default_pmm_manager+0xa88>
ffffffffc020438e:	25300593          	li	a1,595
ffffffffc0204392:	43d4                	lw	a3,4(a5)
ffffffffc0204394:	00003517          	auipc	a0,0x3
ffffffffc0204398:	d4450513          	addi	a0,a0,-700 # ffffffffc02070d8 <default_pmm_manager+0xa28>
ffffffffc020439c:	8f6fc0ef          	jal	ra,ffffffffc0200492 <__panic>
        intr_enable();
ffffffffc02043a0:	e08fc0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc02043a4:	bff1                	j	ffffffffc0204380 <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc02043a6:	00003617          	auipc	a2,0x3
ffffffffc02043aa:	d7260613          	addi	a2,a2,-654 # ffffffffc0207118 <default_pmm_manager+0xa68>
ffffffffc02043ae:	21f00593          	li	a1,543
ffffffffc02043b2:	00003517          	auipc	a0,0x3
ffffffffc02043b6:	d2650513          	addi	a0,a0,-730 # ffffffffc02070d8 <default_pmm_manager+0xa28>
ffffffffc02043ba:	8d8fc0ef          	jal	ra,ffffffffc0200492 <__panic>
            exit_mmap(mm);
ffffffffc02043be:	854e                	mv	a0,s3
ffffffffc02043c0:	d04ff0ef          	jal	ra,ffffffffc02038c4 <exit_mmap>
            put_pgdir(mm);
ffffffffc02043c4:	854e                	mv	a0,s3
ffffffffc02043c6:	9d9ff0ef          	jal	ra,ffffffffc0203d9e <put_pgdir>
            mm_destroy(mm);
ffffffffc02043ca:	854e                	mv	a0,s3
ffffffffc02043cc:	b5cff0ef          	jal	ra,ffffffffc0203728 <mm_destroy>
ffffffffc02043d0:	bf35                	j	ffffffffc020430c <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc02043d2:	00003617          	auipc	a2,0x3
ffffffffc02043d6:	d5660613          	addi	a2,a2,-682 # ffffffffc0207128 <default_pmm_manager+0xa78>
ffffffffc02043da:	22300593          	li	a1,547
ffffffffc02043de:	00003517          	auipc	a0,0x3
ffffffffc02043e2:	cfa50513          	addi	a0,a0,-774 # ffffffffc02070d8 <default_pmm_manager+0xa28>
ffffffffc02043e6:	8acfc0ef          	jal	ra,ffffffffc0200492 <__panic>
        intr_disable();
ffffffffc02043ea:	dc4fc0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        return 1;
ffffffffc02043ee:	4a05                	li	s4,1
ffffffffc02043f0:	bf1d                	j	ffffffffc0204326 <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc02043f2:	511000ef          	jal	ra,ffffffffc0205102 <wakeup_proc>
ffffffffc02043f6:	b789                	j	ffffffffc0204338 <do_exit+0x8a>

ffffffffc02043f8 <do_wait.part.0>:
}

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int do_wait(int pid, int *code_store)
ffffffffc02043f8:	715d                	addi	sp,sp,-80
ffffffffc02043fa:	f84a                	sd	s2,48(sp)
ffffffffc02043fc:	f44e                	sd	s3,40(sp)
        }
    }
    if (haskid)
    {
        current->state = PROC_SLEEPING;
        current->wait_state = WT_CHILD;
ffffffffc02043fe:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID)
ffffffffc0204402:	6989                	lui	s3,0x2
int do_wait(int pid, int *code_store)
ffffffffc0204404:	fc26                	sd	s1,56(sp)
ffffffffc0204406:	f052                	sd	s4,32(sp)
ffffffffc0204408:	ec56                	sd	s5,24(sp)
ffffffffc020440a:	e85a                	sd	s6,16(sp)
ffffffffc020440c:	e45e                	sd	s7,8(sp)
ffffffffc020440e:	e486                	sd	ra,72(sp)
ffffffffc0204410:	e0a2                	sd	s0,64(sp)
ffffffffc0204412:	84aa                	mv	s1,a0
ffffffffc0204414:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc0204416:	000c3b97          	auipc	s7,0xc3
ffffffffc020441a:	942b8b93          	addi	s7,s7,-1726 # ffffffffc02c6d58 <current>
    if (0 < pid && pid < MAX_PID)
ffffffffc020441e:	00050b1b          	sext.w	s6,a0
ffffffffc0204422:	fff50a9b          	addiw	s5,a0,-1
ffffffffc0204426:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc0204428:	0905                	addi	s2,s2,1
    if (pid != 0)
ffffffffc020442a:	ccbd                	beqz	s1,ffffffffc02044a8 <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID)
ffffffffc020442c:	0359e863          	bltu	s3,s5,ffffffffc020445c <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204430:	45a9                	li	a1,10
ffffffffc0204432:	855a                	mv	a0,s6
ffffffffc0204434:	741000ef          	jal	ra,ffffffffc0205374 <hash32>
ffffffffc0204438:	02051793          	slli	a5,a0,0x20
ffffffffc020443c:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204440:	000bf797          	auipc	a5,0xbf
ffffffffc0204444:	88078793          	addi	a5,a5,-1920 # ffffffffc02c2cc0 <hash_list>
ffffffffc0204448:	953e                	add	a0,a0,a5
ffffffffc020444a:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list)
ffffffffc020444c:	a029                	j	ffffffffc0204456 <do_wait.part.0+0x5e>
            if (proc->pid == pid)
ffffffffc020444e:	f2c42783          	lw	a5,-212(s0)
ffffffffc0204452:	02978163          	beq	a5,s1,ffffffffc0204474 <do_wait.part.0+0x7c>
ffffffffc0204456:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list)
ffffffffc0204458:	fe851be3          	bne	a0,s0,ffffffffc020444e <do_wait.part.0+0x56>
        {
            do_exit(-E_KILLED);
        }
        goto repeat;
    }
    return -E_BAD_PROC;
ffffffffc020445c:	5579                	li	a0,-2
    }
    local_intr_restore(intr_flag);
    put_kstack(proc);
    kfree(proc);
    return 0;
}
ffffffffc020445e:	60a6                	ld	ra,72(sp)
ffffffffc0204460:	6406                	ld	s0,64(sp)
ffffffffc0204462:	74e2                	ld	s1,56(sp)
ffffffffc0204464:	7942                	ld	s2,48(sp)
ffffffffc0204466:	79a2                	ld	s3,40(sp)
ffffffffc0204468:	7a02                	ld	s4,32(sp)
ffffffffc020446a:	6ae2                	ld	s5,24(sp)
ffffffffc020446c:	6b42                	ld	s6,16(sp)
ffffffffc020446e:	6ba2                	ld	s7,8(sp)
ffffffffc0204470:	6161                	addi	sp,sp,80
ffffffffc0204472:	8082                	ret
        if (proc != NULL && proc->parent == current)
ffffffffc0204474:	000bb683          	ld	a3,0(s7)
ffffffffc0204478:	f4843783          	ld	a5,-184(s0)
ffffffffc020447c:	fed790e3          	bne	a5,a3,ffffffffc020445c <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204480:	f2842703          	lw	a4,-216(s0)
ffffffffc0204484:	478d                	li	a5,3
ffffffffc0204486:	0ef70b63          	beq	a4,a5,ffffffffc020457c <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc020448a:	4785                	li	a5,1
ffffffffc020448c:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc020448e:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc0204492:	523000ef          	jal	ra,ffffffffc02051b4 <schedule>
        if (current->flags & PF_EXITING)
ffffffffc0204496:	000bb783          	ld	a5,0(s7)
ffffffffc020449a:	0b07a783          	lw	a5,176(a5)
ffffffffc020449e:	8b85                	andi	a5,a5,1
ffffffffc02044a0:	d7c9                	beqz	a5,ffffffffc020442a <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc02044a2:	555d                	li	a0,-9
ffffffffc02044a4:	e0bff0ef          	jal	ra,ffffffffc02042ae <do_exit>
        proc = current->cptr;
ffffffffc02044a8:	000bb683          	ld	a3,0(s7)
ffffffffc02044ac:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr)
ffffffffc02044ae:	d45d                	beqz	s0,ffffffffc020445c <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02044b0:	470d                	li	a4,3
ffffffffc02044b2:	a021                	j	ffffffffc02044ba <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr)
ffffffffc02044b4:	10043403          	ld	s0,256(s0)
ffffffffc02044b8:	d869                	beqz	s0,ffffffffc020448a <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02044ba:	401c                	lw	a5,0(s0)
ffffffffc02044bc:	fee79ce3          	bne	a5,a4,ffffffffc02044b4 <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc)
ffffffffc02044c0:	000c3797          	auipc	a5,0xc3
ffffffffc02044c4:	8a07b783          	ld	a5,-1888(a5) # ffffffffc02c6d60 <idleproc>
ffffffffc02044c8:	0c878963          	beq	a5,s0,ffffffffc020459a <do_wait.part.0+0x1a2>
ffffffffc02044cc:	000c3797          	auipc	a5,0xc3
ffffffffc02044d0:	89c7b783          	ld	a5,-1892(a5) # ffffffffc02c6d68 <initproc>
ffffffffc02044d4:	0cf40363          	beq	s0,a5,ffffffffc020459a <do_wait.part.0+0x1a2>
    if (code_store != NULL)
ffffffffc02044d8:	000a0663          	beqz	s4,ffffffffc02044e4 <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc02044dc:	0e842783          	lw	a5,232(s0)
ffffffffc02044e0:	00fa2023          	sw	a5,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8f50>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02044e4:	100027f3          	csrr	a5,sstatus
ffffffffc02044e8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02044ea:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02044ec:	e7c1                	bnez	a5,ffffffffc0204574 <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02044ee:	6c70                	ld	a2,216(s0)
ffffffffc02044f0:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL)
ffffffffc02044f2:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc02044f6:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02044f8:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02044fa:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02044fc:	6470                	ld	a2,200(s0)
ffffffffc02044fe:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0204500:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0204502:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL)
ffffffffc0204504:	c319                	beqz	a4,ffffffffc020450a <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc0204506:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL)
ffffffffc0204508:	7c7c                	ld	a5,248(s0)
ffffffffc020450a:	c3b5                	beqz	a5,ffffffffc020456e <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc020450c:	10e7b023          	sd	a4,256(a5)
    nr_process--;
ffffffffc0204510:	000c3717          	auipc	a4,0xc3
ffffffffc0204514:	86070713          	addi	a4,a4,-1952 # ffffffffc02c6d70 <nr_process>
ffffffffc0204518:	431c                	lw	a5,0(a4)
ffffffffc020451a:	37fd                	addiw	a5,a5,-1
ffffffffc020451c:	c31c                	sw	a5,0(a4)
    if (flag)
ffffffffc020451e:	e5a9                	bnez	a1,ffffffffc0204568 <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204520:	6814                	ld	a3,16(s0)
ffffffffc0204522:	c02007b7          	lui	a5,0xc0200
ffffffffc0204526:	04f6ee63          	bltu	a3,a5,ffffffffc0204582 <do_wait.part.0+0x18a>
ffffffffc020452a:	000c3797          	auipc	a5,0xc3
ffffffffc020452e:	8267b783          	ld	a5,-2010(a5) # ffffffffc02c6d50 <va_pa_offset>
ffffffffc0204532:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage)
ffffffffc0204534:	82b1                	srli	a3,a3,0xc
ffffffffc0204536:	000c3797          	auipc	a5,0xc3
ffffffffc020453a:	8027b783          	ld	a5,-2046(a5) # ffffffffc02c6d38 <npage>
ffffffffc020453e:	06f6fa63          	bgeu	a3,a5,ffffffffc02045b2 <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0204542:	00004517          	auipc	a0,0x4
ffffffffc0204546:	c2653503          	ld	a0,-986(a0) # ffffffffc0208168 <nbase>
ffffffffc020454a:	8e89                	sub	a3,a3,a0
ffffffffc020454c:	069a                	slli	a3,a3,0x6
ffffffffc020454e:	000c2517          	auipc	a0,0xc2
ffffffffc0204552:	7f253503          	ld	a0,2034(a0) # ffffffffc02c6d40 <pages>
ffffffffc0204556:	9536                	add	a0,a0,a3
ffffffffc0204558:	4589                	li	a1,2
ffffffffc020455a:	8a9fd0ef          	jal	ra,ffffffffc0201e02 <free_pages>
    kfree(proc);
ffffffffc020455e:	8522                	mv	a0,s0
ffffffffc0204560:	f36fd0ef          	jal	ra,ffffffffc0201c96 <kfree>
    return 0;
ffffffffc0204564:	4501                	li	a0,0
ffffffffc0204566:	bde5                	j	ffffffffc020445e <do_wait.part.0+0x66>
        intr_enable();
ffffffffc0204568:	c40fc0ef          	jal	ra,ffffffffc02009a8 <intr_enable>
ffffffffc020456c:	bf55                	j	ffffffffc0204520 <do_wait.part.0+0x128>
        proc->parent->cptr = proc->optr;
ffffffffc020456e:	701c                	ld	a5,32(s0)
ffffffffc0204570:	fbf8                	sd	a4,240(a5)
ffffffffc0204572:	bf79                	j	ffffffffc0204510 <do_wait.part.0+0x118>
        intr_disable();
ffffffffc0204574:	c3afc0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        return 1;
ffffffffc0204578:	4585                	li	a1,1
ffffffffc020457a:	bf95                	j	ffffffffc02044ee <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020457c:	f2840413          	addi	s0,s0,-216
ffffffffc0204580:	b781                	j	ffffffffc02044c0 <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc0204582:	00002617          	auipc	a2,0x2
ffffffffc0204586:	20e60613          	addi	a2,a2,526 # ffffffffc0206790 <default_pmm_manager+0xe0>
ffffffffc020458a:	07700593          	li	a1,119
ffffffffc020458e:	00002517          	auipc	a0,0x2
ffffffffc0204592:	18250513          	addi	a0,a0,386 # ffffffffc0206710 <default_pmm_manager+0x60>
ffffffffc0204596:	efdfb0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc020459a:	00003617          	auipc	a2,0x3
ffffffffc020459e:	bbe60613          	addi	a2,a2,-1090 # ffffffffc0207158 <default_pmm_manager+0xaa8>
ffffffffc02045a2:	37700593          	li	a1,887
ffffffffc02045a6:	00003517          	auipc	a0,0x3
ffffffffc02045aa:	b3250513          	addi	a0,a0,-1230 # ffffffffc02070d8 <default_pmm_manager+0xa28>
ffffffffc02045ae:	ee5fb0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02045b2:	00002617          	auipc	a2,0x2
ffffffffc02045b6:	20660613          	addi	a2,a2,518 # ffffffffc02067b8 <default_pmm_manager+0x108>
ffffffffc02045ba:	06900593          	li	a1,105
ffffffffc02045be:	00002517          	auipc	a0,0x2
ffffffffc02045c2:	15250513          	addi	a0,a0,338 # ffffffffc0206710 <default_pmm_manager+0x60>
ffffffffc02045c6:	ecdfb0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02045ca <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc02045ca:	1141                	addi	sp,sp,-16
ffffffffc02045cc:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02045ce:	875fd0ef          	jal	ra,ffffffffc0201e42 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02045d2:	e10fd0ef          	jal	ra,ffffffffc0201be2 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02045d6:	4601                	li	a2,0
ffffffffc02045d8:	4581                	li	a1,0
ffffffffc02045da:	00000517          	auipc	a0,0x0
ffffffffc02045de:	62850513          	addi	a0,a0,1576 # ffffffffc0204c02 <user_main>
ffffffffc02045e2:	c7dff0ef          	jal	ra,ffffffffc020425e <kernel_thread>
    if (pid <= 0)
ffffffffc02045e6:	00a04563          	bgtz	a0,ffffffffc02045f0 <init_main+0x26>
ffffffffc02045ea:	a071                	j	ffffffffc0204676 <init_main+0xac>
    }

    int wait_result;
    while ((wait_result = do_wait(0, NULL)) == 0)
    {
        schedule();
ffffffffc02045ec:	3c9000ef          	jal	ra,ffffffffc02051b4 <schedule>
    if (code_store != NULL)
ffffffffc02045f0:	4581                	li	a1,0
ffffffffc02045f2:	4501                	li	a0,0
ffffffffc02045f4:	e05ff0ef          	jal	ra,ffffffffc02043f8 <do_wait.part.0>
    while ((wait_result = do_wait(0, NULL)) == 0)
ffffffffc02045f8:	d975                	beqz	a0,ffffffffc02045ec <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc02045fa:	00003517          	auipc	a0,0x3
ffffffffc02045fe:	b9e50513          	addi	a0,a0,-1122 # ffffffffc0207198 <default_pmm_manager+0xae8>
ffffffffc0204602:	b97fb0ef          	jal	ra,ffffffffc0200198 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204606:	000c2797          	auipc	a5,0xc2
ffffffffc020460a:	7627b783          	ld	a5,1890(a5) # ffffffffc02c6d68 <initproc>
ffffffffc020460e:	7bf8                	ld	a4,240(a5)
ffffffffc0204610:	e339                	bnez	a4,ffffffffc0204656 <init_main+0x8c>
ffffffffc0204612:	7ff8                	ld	a4,248(a5)
ffffffffc0204614:	e329                	bnez	a4,ffffffffc0204656 <init_main+0x8c>
ffffffffc0204616:	1007b703          	ld	a4,256(a5)
ffffffffc020461a:	ef15                	bnez	a4,ffffffffc0204656 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc020461c:	000c2697          	auipc	a3,0xc2
ffffffffc0204620:	7546a683          	lw	a3,1876(a3) # ffffffffc02c6d70 <nr_process>
ffffffffc0204624:	4709                	li	a4,2
ffffffffc0204626:	0ae69463          	bne	a3,a4,ffffffffc02046ce <init_main+0x104>
    return listelm->next;
ffffffffc020462a:	000c2697          	auipc	a3,0xc2
ffffffffc020462e:	69668693          	addi	a3,a3,1686 # ffffffffc02c6cc0 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204632:	6698                	ld	a4,8(a3)
ffffffffc0204634:	0c878793          	addi	a5,a5,200
ffffffffc0204638:	06f71b63          	bne	a4,a5,ffffffffc02046ae <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020463c:	629c                	ld	a5,0(a3)
ffffffffc020463e:	04f71863          	bne	a4,a5,ffffffffc020468e <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc0204642:	00003517          	auipc	a0,0x3
ffffffffc0204646:	c3e50513          	addi	a0,a0,-962 # ffffffffc0207280 <default_pmm_manager+0xbd0>
ffffffffc020464a:	b4ffb0ef          	jal	ra,ffffffffc0200198 <cprintf>
    return 0;
}
ffffffffc020464e:	60a2                	ld	ra,8(sp)
ffffffffc0204650:	4501                	li	a0,0
ffffffffc0204652:	0141                	addi	sp,sp,16
ffffffffc0204654:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204656:	00003697          	auipc	a3,0x3
ffffffffc020465a:	b6a68693          	addi	a3,a3,-1174 # ffffffffc02071c0 <default_pmm_manager+0xb10>
ffffffffc020465e:	00002617          	auipc	a2,0x2
ffffffffc0204662:	ca260613          	addi	a2,a2,-862 # ffffffffc0206300 <commands+0x850>
ffffffffc0204666:	3e400593          	li	a1,996
ffffffffc020466a:	00003517          	auipc	a0,0x3
ffffffffc020466e:	a6e50513          	addi	a0,a0,-1426 # ffffffffc02070d8 <default_pmm_manager+0xa28>
ffffffffc0204672:	e21fb0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("create user_main failed.\n");
ffffffffc0204676:	00003617          	auipc	a2,0x3
ffffffffc020467a:	b0260613          	addi	a2,a2,-1278 # ffffffffc0207178 <default_pmm_manager+0xac8>
ffffffffc020467e:	3da00593          	li	a1,986
ffffffffc0204682:	00003517          	auipc	a0,0x3
ffffffffc0204686:	a5650513          	addi	a0,a0,-1450 # ffffffffc02070d8 <default_pmm_manager+0xa28>
ffffffffc020468a:	e09fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020468e:	00003697          	auipc	a3,0x3
ffffffffc0204692:	bc268693          	addi	a3,a3,-1086 # ffffffffc0207250 <default_pmm_manager+0xba0>
ffffffffc0204696:	00002617          	auipc	a2,0x2
ffffffffc020469a:	c6a60613          	addi	a2,a2,-918 # ffffffffc0206300 <commands+0x850>
ffffffffc020469e:	3e700593          	li	a1,999
ffffffffc02046a2:	00003517          	auipc	a0,0x3
ffffffffc02046a6:	a3650513          	addi	a0,a0,-1482 # ffffffffc02070d8 <default_pmm_manager+0xa28>
ffffffffc02046aa:	de9fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02046ae:	00003697          	auipc	a3,0x3
ffffffffc02046b2:	b7268693          	addi	a3,a3,-1166 # ffffffffc0207220 <default_pmm_manager+0xb70>
ffffffffc02046b6:	00002617          	auipc	a2,0x2
ffffffffc02046ba:	c4a60613          	addi	a2,a2,-950 # ffffffffc0206300 <commands+0x850>
ffffffffc02046be:	3e600593          	li	a1,998
ffffffffc02046c2:	00003517          	auipc	a0,0x3
ffffffffc02046c6:	a1650513          	addi	a0,a0,-1514 # ffffffffc02070d8 <default_pmm_manager+0xa28>
ffffffffc02046ca:	dc9fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(nr_process == 2);
ffffffffc02046ce:	00003697          	auipc	a3,0x3
ffffffffc02046d2:	b4268693          	addi	a3,a3,-1214 # ffffffffc0207210 <default_pmm_manager+0xb60>
ffffffffc02046d6:	00002617          	auipc	a2,0x2
ffffffffc02046da:	c2a60613          	addi	a2,a2,-982 # ffffffffc0206300 <commands+0x850>
ffffffffc02046de:	3e500593          	li	a1,997
ffffffffc02046e2:	00003517          	auipc	a0,0x3
ffffffffc02046e6:	9f650513          	addi	a0,a0,-1546 # ffffffffc02070d8 <default_pmm_manager+0xa28>
ffffffffc02046ea:	da9fb0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02046ee <do_execve>:
{
ffffffffc02046ee:	7171                	addi	sp,sp,-176
ffffffffc02046f0:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02046f2:	000c2d97          	auipc	s11,0xc2
ffffffffc02046f6:	666d8d93          	addi	s11,s11,1638 # ffffffffc02c6d58 <current>
ffffffffc02046fa:	000db783          	ld	a5,0(s11)
{
ffffffffc02046fe:	e54e                	sd	s3,136(sp)
ffffffffc0204700:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204702:	0287b983          	ld	s3,40(a5)
{
ffffffffc0204706:	e94a                	sd	s2,144(sp)
ffffffffc0204708:	f4de                	sd	s7,104(sp)
ffffffffc020470a:	892a                	mv	s2,a0
ffffffffc020470c:	8bb2                	mv	s7,a2
ffffffffc020470e:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204710:	862e                	mv	a2,a1
ffffffffc0204712:	4681                	li	a3,0
ffffffffc0204714:	85aa                	mv	a1,a0
ffffffffc0204716:	854e                	mv	a0,s3
{
ffffffffc0204718:	f506                	sd	ra,168(sp)
ffffffffc020471a:	f122                	sd	s0,160(sp)
ffffffffc020471c:	e152                	sd	s4,128(sp)
ffffffffc020471e:	fcd6                	sd	s5,120(sp)
ffffffffc0204720:	f8da                	sd	s6,112(sp)
ffffffffc0204722:	f0e2                	sd	s8,96(sp)
ffffffffc0204724:	ece6                	sd	s9,88(sp)
ffffffffc0204726:	e8ea                	sd	s10,80(sp)
ffffffffc0204728:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc020472a:	d34ff0ef          	jal	ra,ffffffffc0203c5e <user_mem_check>
ffffffffc020472e:	40050a63          	beqz	a0,ffffffffc0204b42 <do_execve+0x454>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0204732:	4641                	li	a2,16
ffffffffc0204734:	4581                	li	a1,0
ffffffffc0204736:	1808                	addi	a0,sp,48
ffffffffc0204738:	0e2010ef          	jal	ra,ffffffffc020581a <memset>
    memcpy(local_name, name, len);
ffffffffc020473c:	47bd                	li	a5,15
ffffffffc020473e:	8626                	mv	a2,s1
ffffffffc0204740:	1e97e263          	bltu	a5,s1,ffffffffc0204924 <do_execve+0x236>
ffffffffc0204744:	85ca                	mv	a1,s2
ffffffffc0204746:	1808                	addi	a0,sp,48
ffffffffc0204748:	0e4010ef          	jal	ra,ffffffffc020582c <memcpy>
    if (mm != NULL)
ffffffffc020474c:	1e098363          	beqz	s3,ffffffffc0204932 <do_execve+0x244>
        cputs("mm != NULL");
ffffffffc0204750:	00002517          	auipc	a0,0x2
ffffffffc0204754:	79050513          	addi	a0,a0,1936 # ffffffffc0206ee0 <default_pmm_manager+0x830>
ffffffffc0204758:	a79fb0ef          	jal	ra,ffffffffc02001d0 <cputs>
ffffffffc020475c:	000c2797          	auipc	a5,0xc2
ffffffffc0204760:	5cc7b783          	ld	a5,1484(a5) # ffffffffc02c6d28 <boot_pgdir_pa>
ffffffffc0204764:	577d                	li	a4,-1
ffffffffc0204766:	177e                	slli	a4,a4,0x3f
ffffffffc0204768:	83b1                	srli	a5,a5,0xc
ffffffffc020476a:	8fd9                	or	a5,a5,a4
ffffffffc020476c:	18079073          	csrw	satp,a5
ffffffffc0204770:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7f20>
ffffffffc0204774:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204778:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0)
ffffffffc020477c:	2c070463          	beqz	a4,ffffffffc0204a44 <do_execve+0x356>
        current->mm = NULL;
ffffffffc0204780:	000db783          	ld	a5,0(s11)
ffffffffc0204784:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc0204788:	e61fe0ef          	jal	ra,ffffffffc02035e8 <mm_create>
ffffffffc020478c:	84aa                	mv	s1,a0
ffffffffc020478e:	1c050d63          	beqz	a0,ffffffffc0204968 <do_execve+0x27a>
    if ((page = alloc_page()) == NULL)
ffffffffc0204792:	4505                	li	a0,1
ffffffffc0204794:	e30fd0ef          	jal	ra,ffffffffc0201dc4 <alloc_pages>
ffffffffc0204798:	3a050963          	beqz	a0,ffffffffc0204b4a <do_execve+0x45c>
    return page - pages + nbase;
ffffffffc020479c:	000c2c97          	auipc	s9,0xc2
ffffffffc02047a0:	5a4c8c93          	addi	s9,s9,1444 # ffffffffc02c6d40 <pages>
ffffffffc02047a4:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc02047a8:	000c2c17          	auipc	s8,0xc2
ffffffffc02047ac:	590c0c13          	addi	s8,s8,1424 # ffffffffc02c6d38 <npage>
    return page - pages + nbase;
ffffffffc02047b0:	00004717          	auipc	a4,0x4
ffffffffc02047b4:	9b873703          	ld	a4,-1608(a4) # ffffffffc0208168 <nbase>
ffffffffc02047b8:	40d506b3          	sub	a3,a0,a3
ffffffffc02047bc:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02047be:	5afd                	li	s5,-1
ffffffffc02047c0:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc02047c4:	96ba                	add	a3,a3,a4
ffffffffc02047c6:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc02047c8:	00cad713          	srli	a4,s5,0xc
ffffffffc02047cc:	ec3a                	sd	a4,24(sp)
ffffffffc02047ce:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02047d0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02047d2:	38f77063          	bgeu	a4,a5,ffffffffc0204b52 <do_execve+0x464>
ffffffffc02047d6:	000c2b17          	auipc	s6,0xc2
ffffffffc02047da:	57ab0b13          	addi	s6,s6,1402 # ffffffffc02c6d50 <va_pa_offset>
ffffffffc02047de:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc02047e2:	6605                	lui	a2,0x1
ffffffffc02047e4:	000c2597          	auipc	a1,0xc2
ffffffffc02047e8:	54c5b583          	ld	a1,1356(a1) # ffffffffc02c6d30 <boot_pgdir_va>
ffffffffc02047ec:	9936                	add	s2,s2,a3
ffffffffc02047ee:	854a                	mv	a0,s2
ffffffffc02047f0:	03c010ef          	jal	ra,ffffffffc020582c <memcpy>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc02047f4:	7782                	ld	a5,32(sp)
ffffffffc02047f6:	4398                	lw	a4,0(a5)
ffffffffc02047f8:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc02047fc:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204800:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_matrix_out_size+0x464b7e57>
ffffffffc0204804:	14f71863          	bne	a4,a5,ffffffffc0204954 <do_execve+0x266>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204808:	7682                	ld	a3,32(sp)
ffffffffc020480a:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020480e:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204812:	00371793          	slli	a5,a4,0x3
ffffffffc0204816:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204818:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020481a:	078e                	slli	a5,a5,0x3
ffffffffc020481c:	97ce                	add	a5,a5,s3
ffffffffc020481e:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph++)
ffffffffc0204820:	00f9fc63          	bgeu	s3,a5,ffffffffc0204838 <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc0204824:	0009a783          	lw	a5,0(s3)
ffffffffc0204828:	4705                	li	a4,1
ffffffffc020482a:	14e78163          	beq	a5,a4,ffffffffc020496c <do_execve+0x27e>
    for (; ph < ph_end; ph++)
ffffffffc020482e:	77a2                	ld	a5,40(sp)
ffffffffc0204830:	03898993          	addi	s3,s3,56
ffffffffc0204834:	fef9e8e3          	bltu	s3,a5,ffffffffc0204824 <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc0204838:	4701                	li	a4,0
ffffffffc020483a:	46ad                	li	a3,11
ffffffffc020483c:	00100637          	lui	a2,0x100
ffffffffc0204840:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0204844:	8526                	mv	a0,s1
ffffffffc0204846:	f35fe0ef          	jal	ra,ffffffffc020377a <mm_map>
ffffffffc020484a:	8a2a                	mv	s4,a0
ffffffffc020484c:	1e051263          	bnez	a0,ffffffffc0204a30 <do_execve+0x342>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204850:	6c88                	ld	a0,24(s1)
ffffffffc0204852:	467d                	li	a2,31
ffffffffc0204854:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0204858:	cabfe0ef          	jal	ra,ffffffffc0203502 <pgdir_alloc_page>
ffffffffc020485c:	38050363          	beqz	a0,ffffffffc0204be2 <do_execve+0x4f4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204860:	6c88                	ld	a0,24(s1)
ffffffffc0204862:	467d                	li	a2,31
ffffffffc0204864:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0204868:	c9bfe0ef          	jal	ra,ffffffffc0203502 <pgdir_alloc_page>
ffffffffc020486c:	34050b63          	beqz	a0,ffffffffc0204bc2 <do_execve+0x4d4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204870:	6c88                	ld	a0,24(s1)
ffffffffc0204872:	467d                	li	a2,31
ffffffffc0204874:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0204878:	c8bfe0ef          	jal	ra,ffffffffc0203502 <pgdir_alloc_page>
ffffffffc020487c:	32050363          	beqz	a0,ffffffffc0204ba2 <do_execve+0x4b4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204880:	6c88                	ld	a0,24(s1)
ffffffffc0204882:	467d                	li	a2,31
ffffffffc0204884:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0204888:	c7bfe0ef          	jal	ra,ffffffffc0203502 <pgdir_alloc_page>
ffffffffc020488c:	2e050b63          	beqz	a0,ffffffffc0204b82 <do_execve+0x494>
    mm->mm_count += 1;
ffffffffc0204890:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0204892:	000db603          	ld	a2,0(s11)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204896:	6c94                	ld	a3,24(s1)
ffffffffc0204898:	2785                	addiw	a5,a5,1
ffffffffc020489a:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc020489c:	f604                	sd	s1,40(a2)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc020489e:	c02007b7          	lui	a5,0xc0200
ffffffffc02048a2:	2cf6e463          	bltu	a3,a5,ffffffffc0204b6a <do_execve+0x47c>
ffffffffc02048a6:	000b3783          	ld	a5,0(s6)
ffffffffc02048aa:	577d                	li	a4,-1
ffffffffc02048ac:	177e                	slli	a4,a4,0x3f
ffffffffc02048ae:	8e9d                	sub	a3,a3,a5
ffffffffc02048b0:	00c6d793          	srli	a5,a3,0xc
ffffffffc02048b4:	f654                	sd	a3,168(a2)
ffffffffc02048b6:	8fd9                	or	a5,a5,a4
ffffffffc02048b8:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc02048bc:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02048be:	4581                	li	a1,0
ffffffffc02048c0:	12000613          	li	a2,288
ffffffffc02048c4:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc02048c6:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02048ca:	751000ef          	jal	ra,ffffffffc020581a <memset>
    tf->epc = elf->e_entry;
ffffffffc02048ce:	7782                	ld	a5,32(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02048d0:	000db903          	ld	s2,0(s11)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc02048d4:	edf4f493          	andi	s1,s1,-289
    tf->epc = elf->e_entry;
ffffffffc02048d8:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc02048da:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02048dc:	0b490913          	addi	s2,s2,180 # ffffffff800000b4 <_binary_obj___user_matrix_out_size+0xffffffff7fff398c>
    tf->gpr.sp = USTACKTOP;
ffffffffc02048e0:	07fe                	slli	a5,a5,0x1f
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc02048e2:	0204e493          	ori	s1,s1,32
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02048e6:	4641                	li	a2,16
ffffffffc02048e8:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP;
ffffffffc02048ea:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc02048ec:	10e43423          	sd	a4,264(s0)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc02048f0:	10943023          	sd	s1,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02048f4:	854a                	mv	a0,s2
ffffffffc02048f6:	725000ef          	jal	ra,ffffffffc020581a <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02048fa:	463d                	li	a2,15
ffffffffc02048fc:	180c                	addi	a1,sp,48
ffffffffc02048fe:	854a                	mv	a0,s2
ffffffffc0204900:	72d000ef          	jal	ra,ffffffffc020582c <memcpy>
}
ffffffffc0204904:	70aa                	ld	ra,168(sp)
ffffffffc0204906:	740a                	ld	s0,160(sp)
ffffffffc0204908:	64ea                	ld	s1,152(sp)
ffffffffc020490a:	694a                	ld	s2,144(sp)
ffffffffc020490c:	69aa                	ld	s3,136(sp)
ffffffffc020490e:	7ae6                	ld	s5,120(sp)
ffffffffc0204910:	7b46                	ld	s6,112(sp)
ffffffffc0204912:	7ba6                	ld	s7,104(sp)
ffffffffc0204914:	7c06                	ld	s8,96(sp)
ffffffffc0204916:	6ce6                	ld	s9,88(sp)
ffffffffc0204918:	6d46                	ld	s10,80(sp)
ffffffffc020491a:	6da6                	ld	s11,72(sp)
ffffffffc020491c:	8552                	mv	a0,s4
ffffffffc020491e:	6a0a                	ld	s4,128(sp)
ffffffffc0204920:	614d                	addi	sp,sp,176
ffffffffc0204922:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc0204924:	463d                	li	a2,15
ffffffffc0204926:	85ca                	mv	a1,s2
ffffffffc0204928:	1808                	addi	a0,sp,48
ffffffffc020492a:	703000ef          	jal	ra,ffffffffc020582c <memcpy>
    if (mm != NULL)
ffffffffc020492e:	e20991e3          	bnez	s3,ffffffffc0204750 <do_execve+0x62>
    if (current->mm != NULL)
ffffffffc0204932:	000db783          	ld	a5,0(s11)
ffffffffc0204936:	779c                	ld	a5,40(a5)
ffffffffc0204938:	e40788e3          	beqz	a5,ffffffffc0204788 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc020493c:	00003617          	auipc	a2,0x3
ffffffffc0204940:	96460613          	addi	a2,a2,-1692 # ffffffffc02072a0 <default_pmm_manager+0xbf0>
ffffffffc0204944:	25f00593          	li	a1,607
ffffffffc0204948:	00002517          	auipc	a0,0x2
ffffffffc020494c:	79050513          	addi	a0,a0,1936 # ffffffffc02070d8 <default_pmm_manager+0xa28>
ffffffffc0204950:	b43fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    put_pgdir(mm);
ffffffffc0204954:	8526                	mv	a0,s1
ffffffffc0204956:	c48ff0ef          	jal	ra,ffffffffc0203d9e <put_pgdir>
    mm_destroy(mm);
ffffffffc020495a:	8526                	mv	a0,s1
ffffffffc020495c:	dcdfe0ef          	jal	ra,ffffffffc0203728 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0204960:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc0204962:	8552                	mv	a0,s4
ffffffffc0204964:	94bff0ef          	jal	ra,ffffffffc02042ae <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0204968:	5a71                	li	s4,-4
ffffffffc020496a:	bfe5                	j	ffffffffc0204962 <do_execve+0x274>
        if (ph->p_filesz > ph->p_memsz)
ffffffffc020496c:	0289b603          	ld	a2,40(s3)
ffffffffc0204970:	0209b783          	ld	a5,32(s3)
ffffffffc0204974:	1cf66d63          	bltu	a2,a5,ffffffffc0204b4e <do_execve+0x460>
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204978:	0049a783          	lw	a5,4(s3)
ffffffffc020497c:	0017f693          	andi	a3,a5,1
ffffffffc0204980:	c291                	beqz	a3,ffffffffc0204984 <do_execve+0x296>
            vm_flags |= VM_EXEC;
ffffffffc0204982:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204984:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204988:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc020498a:	e779                	bnez	a4,ffffffffc0204a58 <do_execve+0x36a>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc020498c:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc020498e:	c781                	beqz	a5,ffffffffc0204996 <do_execve+0x2a8>
            vm_flags |= VM_READ;
ffffffffc0204990:	0016e693          	ori	a3,a3,1
            perm |= PTE_R;
ffffffffc0204994:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE)
ffffffffc0204996:	0026f793          	andi	a5,a3,2
ffffffffc020499a:	e3f1                	bnez	a5,ffffffffc0204a5e <do_execve+0x370>
        if (vm_flags & VM_EXEC)
ffffffffc020499c:	0046f793          	andi	a5,a3,4
ffffffffc02049a0:	c399                	beqz	a5,ffffffffc02049a6 <do_execve+0x2b8>
            perm |= PTE_X;
ffffffffc02049a2:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc02049a6:	0109b583          	ld	a1,16(s3)
ffffffffc02049aa:	4701                	li	a4,0
ffffffffc02049ac:	8526                	mv	a0,s1
ffffffffc02049ae:	dcdfe0ef          	jal	ra,ffffffffc020377a <mm_map>
ffffffffc02049b2:	8a2a                	mv	s4,a0
ffffffffc02049b4:	ed35                	bnez	a0,ffffffffc0204a30 <do_execve+0x342>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02049b6:	0109bb83          	ld	s7,16(s3)
ffffffffc02049ba:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc02049bc:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc02049c0:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02049c4:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc02049c8:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc02049ca:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc02049cc:	993e                	add	s2,s2,a5
        while (start < end)
ffffffffc02049ce:	054be963          	bltu	s7,s4,ffffffffc0204a20 <do_execve+0x332>
ffffffffc02049d2:	aa95                	j	ffffffffc0204b46 <do_execve+0x458>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc02049d4:	6785                	lui	a5,0x1
ffffffffc02049d6:	415b8533          	sub	a0,s7,s5
ffffffffc02049da:	9abe                	add	s5,s5,a5
ffffffffc02049dc:	417a8633          	sub	a2,s5,s7
            if (end < la)
ffffffffc02049e0:	015a7463          	bgeu	s4,s5,ffffffffc02049e8 <do_execve+0x2fa>
                size -= la - end;
ffffffffc02049e4:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc02049e8:	000cb683          	ld	a3,0(s9)
ffffffffc02049ec:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc02049ee:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc02049f2:	40d406b3          	sub	a3,s0,a3
ffffffffc02049f6:	8699                	srai	a3,a3,0x6
ffffffffc02049f8:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02049fa:	67e2                	ld	a5,24(sp)
ffffffffc02049fc:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204a00:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204a02:	14b87863          	bgeu	a6,a1,ffffffffc0204b52 <do_execve+0x464>
ffffffffc0204a06:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204a0a:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0204a0c:	9bb2                	add	s7,s7,a2
ffffffffc0204a0e:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204a10:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0204a12:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204a14:	619000ef          	jal	ra,ffffffffc020582c <memcpy>
            start += size, from += size;
ffffffffc0204a18:	6622                	ld	a2,8(sp)
ffffffffc0204a1a:	9932                	add	s2,s2,a2
        while (start < end)
ffffffffc0204a1c:	054bf363          	bgeu	s7,s4,ffffffffc0204a62 <do_execve+0x374>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204a20:	6c88                	ld	a0,24(s1)
ffffffffc0204a22:	866a                	mv	a2,s10
ffffffffc0204a24:	85d6                	mv	a1,s5
ffffffffc0204a26:	addfe0ef          	jal	ra,ffffffffc0203502 <pgdir_alloc_page>
ffffffffc0204a2a:	842a                	mv	s0,a0
ffffffffc0204a2c:	f545                	bnez	a0,ffffffffc02049d4 <do_execve+0x2e6>
        ret = -E_NO_MEM;
ffffffffc0204a2e:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0204a30:	8526                	mv	a0,s1
ffffffffc0204a32:	e93fe0ef          	jal	ra,ffffffffc02038c4 <exit_mmap>
    put_pgdir(mm);
ffffffffc0204a36:	8526                	mv	a0,s1
ffffffffc0204a38:	b66ff0ef          	jal	ra,ffffffffc0203d9e <put_pgdir>
    mm_destroy(mm);
ffffffffc0204a3c:	8526                	mv	a0,s1
ffffffffc0204a3e:	cebfe0ef          	jal	ra,ffffffffc0203728 <mm_destroy>
    return ret;
ffffffffc0204a42:	b705                	j	ffffffffc0204962 <do_execve+0x274>
            exit_mmap(mm);
ffffffffc0204a44:	854e                	mv	a0,s3
ffffffffc0204a46:	e7ffe0ef          	jal	ra,ffffffffc02038c4 <exit_mmap>
            put_pgdir(mm);
ffffffffc0204a4a:	854e                	mv	a0,s3
ffffffffc0204a4c:	b52ff0ef          	jal	ra,ffffffffc0203d9e <put_pgdir>
            mm_destroy(mm);
ffffffffc0204a50:	854e                	mv	a0,s3
ffffffffc0204a52:	cd7fe0ef          	jal	ra,ffffffffc0203728 <mm_destroy>
ffffffffc0204a56:	b32d                	j	ffffffffc0204780 <do_execve+0x92>
            vm_flags |= VM_WRITE;
ffffffffc0204a58:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204a5c:	fb95                	bnez	a5,ffffffffc0204990 <do_execve+0x2a2>
            perm |= (PTE_W | PTE_R);
ffffffffc0204a5e:	4d5d                	li	s10,23
ffffffffc0204a60:	bf35                	j	ffffffffc020499c <do_execve+0x2ae>
        end = ph->p_va + ph->p_memsz;
ffffffffc0204a62:	0109b683          	ld	a3,16(s3)
ffffffffc0204a66:	0289b903          	ld	s2,40(s3)
ffffffffc0204a6a:	9936                	add	s2,s2,a3
        if (start < la)
ffffffffc0204a6c:	075bfd63          	bgeu	s7,s5,ffffffffc0204ae6 <do_execve+0x3f8>
            if (start == end)
ffffffffc0204a70:	db790fe3          	beq	s2,s7,ffffffffc020482e <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204a74:	6785                	lui	a5,0x1
ffffffffc0204a76:	00fb8533          	add	a0,s7,a5
ffffffffc0204a7a:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0204a7e:	41790a33          	sub	s4,s2,s7
            if (end < la)
ffffffffc0204a82:	0b597d63          	bgeu	s2,s5,ffffffffc0204b3c <do_execve+0x44e>
    return page - pages + nbase;
ffffffffc0204a86:	000cb683          	ld	a3,0(s9)
ffffffffc0204a8a:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204a8c:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0204a90:	40d406b3          	sub	a3,s0,a3
ffffffffc0204a94:	8699                	srai	a3,a3,0x6
ffffffffc0204a96:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204a98:	67e2                	ld	a5,24(sp)
ffffffffc0204a9a:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204a9e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204aa0:	0ac5f963          	bgeu	a1,a2,ffffffffc0204b52 <do_execve+0x464>
ffffffffc0204aa4:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204aa8:	8652                	mv	a2,s4
ffffffffc0204aaa:	4581                	li	a1,0
ffffffffc0204aac:	96c2                	add	a3,a3,a6
ffffffffc0204aae:	9536                	add	a0,a0,a3
ffffffffc0204ab0:	56b000ef          	jal	ra,ffffffffc020581a <memset>
            start += size;
ffffffffc0204ab4:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0204ab8:	03597463          	bgeu	s2,s5,ffffffffc0204ae0 <do_execve+0x3f2>
ffffffffc0204abc:	d6e909e3          	beq	s2,a4,ffffffffc020482e <do_execve+0x140>
ffffffffc0204ac0:	00003697          	auipc	a3,0x3
ffffffffc0204ac4:	80868693          	addi	a3,a3,-2040 # ffffffffc02072c8 <default_pmm_manager+0xc18>
ffffffffc0204ac8:	00002617          	auipc	a2,0x2
ffffffffc0204acc:	83860613          	addi	a2,a2,-1992 # ffffffffc0206300 <commands+0x850>
ffffffffc0204ad0:	2c800593          	li	a1,712
ffffffffc0204ad4:	00002517          	auipc	a0,0x2
ffffffffc0204ad8:	60450513          	addi	a0,a0,1540 # ffffffffc02070d8 <default_pmm_manager+0xa28>
ffffffffc0204adc:	9b7fb0ef          	jal	ra,ffffffffc0200492 <__panic>
ffffffffc0204ae0:	ff5710e3          	bne	a4,s5,ffffffffc0204ac0 <do_execve+0x3d2>
ffffffffc0204ae4:	8bd6                	mv	s7,s5
        while (start < end)
ffffffffc0204ae6:	d52bf4e3          	bgeu	s7,s2,ffffffffc020482e <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204aea:	6c88                	ld	a0,24(s1)
ffffffffc0204aec:	866a                	mv	a2,s10
ffffffffc0204aee:	85d6                	mv	a1,s5
ffffffffc0204af0:	a13fe0ef          	jal	ra,ffffffffc0203502 <pgdir_alloc_page>
ffffffffc0204af4:	842a                	mv	s0,a0
ffffffffc0204af6:	dd05                	beqz	a0,ffffffffc0204a2e <do_execve+0x340>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204af8:	6785                	lui	a5,0x1
ffffffffc0204afa:	415b8533          	sub	a0,s7,s5
ffffffffc0204afe:	9abe                	add	s5,s5,a5
ffffffffc0204b00:	417a8633          	sub	a2,s5,s7
            if (end < la)
ffffffffc0204b04:	01597463          	bgeu	s2,s5,ffffffffc0204b0c <do_execve+0x41e>
                size -= la - end;
ffffffffc0204b08:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0204b0c:	000cb683          	ld	a3,0(s9)
ffffffffc0204b10:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204b12:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204b16:	40d406b3          	sub	a3,s0,a3
ffffffffc0204b1a:	8699                	srai	a3,a3,0x6
ffffffffc0204b1c:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204b1e:	67e2                	ld	a5,24(sp)
ffffffffc0204b20:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b24:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204b26:	02b87663          	bgeu	a6,a1,ffffffffc0204b52 <do_execve+0x464>
ffffffffc0204b2a:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204b2e:	4581                	li	a1,0
            start += size;
ffffffffc0204b30:	9bb2                	add	s7,s7,a2
ffffffffc0204b32:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0204b34:	9536                	add	a0,a0,a3
ffffffffc0204b36:	4e5000ef          	jal	ra,ffffffffc020581a <memset>
ffffffffc0204b3a:	b775                	j	ffffffffc0204ae6 <do_execve+0x3f8>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204b3c:	417a8a33          	sub	s4,s5,s7
ffffffffc0204b40:	b799                	j	ffffffffc0204a86 <do_execve+0x398>
        return -E_INVAL;
ffffffffc0204b42:	5a75                	li	s4,-3
ffffffffc0204b44:	b3c1                	j	ffffffffc0204904 <do_execve+0x216>
        while (start < end)
ffffffffc0204b46:	86de                	mv	a3,s7
ffffffffc0204b48:	bf39                	j	ffffffffc0204a66 <do_execve+0x378>
    int ret = -E_NO_MEM;
ffffffffc0204b4a:	5a71                	li	s4,-4
ffffffffc0204b4c:	bdc5                	j	ffffffffc0204a3c <do_execve+0x34e>
            ret = -E_INVAL_ELF;
ffffffffc0204b4e:	5a61                	li	s4,-8
ffffffffc0204b50:	b5c5                	j	ffffffffc0204a30 <do_execve+0x342>
ffffffffc0204b52:	00002617          	auipc	a2,0x2
ffffffffc0204b56:	b9660613          	addi	a2,a2,-1130 # ffffffffc02066e8 <default_pmm_manager+0x38>
ffffffffc0204b5a:	07100593          	li	a1,113
ffffffffc0204b5e:	00002517          	auipc	a0,0x2
ffffffffc0204b62:	bb250513          	addi	a0,a0,-1102 # ffffffffc0206710 <default_pmm_manager+0x60>
ffffffffc0204b66:	92dfb0ef          	jal	ra,ffffffffc0200492 <__panic>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204b6a:	00002617          	auipc	a2,0x2
ffffffffc0204b6e:	c2660613          	addi	a2,a2,-986 # ffffffffc0206790 <default_pmm_manager+0xe0>
ffffffffc0204b72:	2e700593          	li	a1,743
ffffffffc0204b76:	00002517          	auipc	a0,0x2
ffffffffc0204b7a:	56250513          	addi	a0,a0,1378 # ffffffffc02070d8 <default_pmm_manager+0xa28>
ffffffffc0204b7e:	915fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204b82:	00003697          	auipc	a3,0x3
ffffffffc0204b86:	85e68693          	addi	a3,a3,-1954 # ffffffffc02073e0 <default_pmm_manager+0xd30>
ffffffffc0204b8a:	00001617          	auipc	a2,0x1
ffffffffc0204b8e:	77660613          	addi	a2,a2,1910 # ffffffffc0206300 <commands+0x850>
ffffffffc0204b92:	2e200593          	li	a1,738
ffffffffc0204b96:	00002517          	auipc	a0,0x2
ffffffffc0204b9a:	54250513          	addi	a0,a0,1346 # ffffffffc02070d8 <default_pmm_manager+0xa28>
ffffffffc0204b9e:	8f5fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204ba2:	00002697          	auipc	a3,0x2
ffffffffc0204ba6:	7f668693          	addi	a3,a3,2038 # ffffffffc0207398 <default_pmm_manager+0xce8>
ffffffffc0204baa:	00001617          	auipc	a2,0x1
ffffffffc0204bae:	75660613          	addi	a2,a2,1878 # ffffffffc0206300 <commands+0x850>
ffffffffc0204bb2:	2e100593          	li	a1,737
ffffffffc0204bb6:	00002517          	auipc	a0,0x2
ffffffffc0204bba:	52250513          	addi	a0,a0,1314 # ffffffffc02070d8 <default_pmm_manager+0xa28>
ffffffffc0204bbe:	8d5fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204bc2:	00002697          	auipc	a3,0x2
ffffffffc0204bc6:	78e68693          	addi	a3,a3,1934 # ffffffffc0207350 <default_pmm_manager+0xca0>
ffffffffc0204bca:	00001617          	auipc	a2,0x1
ffffffffc0204bce:	73660613          	addi	a2,a2,1846 # ffffffffc0206300 <commands+0x850>
ffffffffc0204bd2:	2e000593          	li	a1,736
ffffffffc0204bd6:	00002517          	auipc	a0,0x2
ffffffffc0204bda:	50250513          	addi	a0,a0,1282 # ffffffffc02070d8 <default_pmm_manager+0xa28>
ffffffffc0204bde:	8b5fb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204be2:	00002697          	auipc	a3,0x2
ffffffffc0204be6:	72668693          	addi	a3,a3,1830 # ffffffffc0207308 <default_pmm_manager+0xc58>
ffffffffc0204bea:	00001617          	auipc	a2,0x1
ffffffffc0204bee:	71660613          	addi	a2,a2,1814 # ffffffffc0206300 <commands+0x850>
ffffffffc0204bf2:	2df00593          	li	a1,735
ffffffffc0204bf6:	00002517          	auipc	a0,0x2
ffffffffc0204bfa:	4e250513          	addi	a0,a0,1250 # ffffffffc02070d8 <default_pmm_manager+0xa28>
ffffffffc0204bfe:	895fb0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0204c02 <user_main>:
{
ffffffffc0204c02:	1101                	addi	sp,sp,-32
ffffffffc0204c04:	e04a                	sd	s2,0(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204c06:	000c2917          	auipc	s2,0xc2
ffffffffc0204c0a:	15290913          	addi	s2,s2,338 # ffffffffc02c6d58 <current>
ffffffffc0204c0e:	00093783          	ld	a5,0(s2)
ffffffffc0204c12:	00003617          	auipc	a2,0x3
ffffffffc0204c16:	81660613          	addi	a2,a2,-2026 # ffffffffc0207428 <default_pmm_manager+0xd78>
ffffffffc0204c1a:	00003517          	auipc	a0,0x3
ffffffffc0204c1e:	81e50513          	addi	a0,a0,-2018 # ffffffffc0207438 <default_pmm_manager+0xd88>
ffffffffc0204c22:	43cc                	lw	a1,4(a5)
{
ffffffffc0204c24:	ec06                	sd	ra,24(sp)
ffffffffc0204c26:	e822                	sd	s0,16(sp)
ffffffffc0204c28:	e426                	sd	s1,8(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204c2a:	d6efb0ef          	jal	ra,ffffffffc0200198 <cprintf>
    size_t len = strlen(name);
ffffffffc0204c2e:	00002517          	auipc	a0,0x2
ffffffffc0204c32:	7fa50513          	addi	a0,a0,2042 # ffffffffc0207428 <default_pmm_manager+0xd78>
ffffffffc0204c36:	343000ef          	jal	ra,ffffffffc0205778 <strlen>
    struct trapframe *old_tf = current->tf;
ffffffffc0204c3a:	00093783          	ld	a5,0(s2)
    size_t len = strlen(name);
ffffffffc0204c3e:	84aa                	mv	s1,a0
    memcpy(new_tf, old_tf, sizeof(struct trapframe));
ffffffffc0204c40:	12000613          	li	a2,288
    struct trapframe *new_tf = (struct trapframe *)(current->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204c44:	6b80                	ld	s0,16(a5)
    memcpy(new_tf, old_tf, sizeof(struct trapframe));
ffffffffc0204c46:	73cc                	ld	a1,160(a5)
    struct trapframe *new_tf = (struct trapframe *)(current->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204c48:	6789                	lui	a5,0x2
ffffffffc0204c4a:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x8070>
ffffffffc0204c4e:	943e                	add	s0,s0,a5
    memcpy(new_tf, old_tf, sizeof(struct trapframe));
ffffffffc0204c50:	8522                	mv	a0,s0
ffffffffc0204c52:	3db000ef          	jal	ra,ffffffffc020582c <memcpy>
    current->tf = new_tf;
ffffffffc0204c56:	00093783          	ld	a5,0(s2)
    ret = do_execve(name, len, binary, size);
ffffffffc0204c5a:	3fe07697          	auipc	a3,0x3fe07
ffffffffc0204c5e:	afe68693          	addi	a3,a3,-1282 # b758 <_binary_obj___user_priority_out_size>
ffffffffc0204c62:	0007d617          	auipc	a2,0x7d
ffffffffc0204c66:	1ae60613          	addi	a2,a2,430 # ffffffffc0281e10 <_binary_obj___user_priority_out_start>
    current->tf = new_tf;
ffffffffc0204c6a:	f3c0                	sd	s0,160(a5)
    ret = do_execve(name, len, binary, size);
ffffffffc0204c6c:	85a6                	mv	a1,s1
ffffffffc0204c6e:	00002517          	auipc	a0,0x2
ffffffffc0204c72:	7ba50513          	addi	a0,a0,1978 # ffffffffc0207428 <default_pmm_manager+0xd78>
ffffffffc0204c76:	a79ff0ef          	jal	ra,ffffffffc02046ee <do_execve>
    asm volatile(
ffffffffc0204c7a:	8122                	mv	sp,s0
ffffffffc0204c7c:	a2cfc06f          	j	ffffffffc0200ea8 <__trapret>
    panic("user_main execve failed.\n");
ffffffffc0204c80:	00002617          	auipc	a2,0x2
ffffffffc0204c84:	7e060613          	addi	a2,a2,2016 # ffffffffc0207460 <default_pmm_manager+0xdb0>
ffffffffc0204c88:	3cd00593          	li	a1,973
ffffffffc0204c8c:	00002517          	auipc	a0,0x2
ffffffffc0204c90:	44c50513          	addi	a0,a0,1100 # ffffffffc02070d8 <default_pmm_manager+0xa28>
ffffffffc0204c94:	ffefb0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0204c98 <do_yield>:
    current->need_resched = 1;
ffffffffc0204c98:	000c2797          	auipc	a5,0xc2
ffffffffc0204c9c:	0c07b783          	ld	a5,192(a5) # ffffffffc02c6d58 <current>
ffffffffc0204ca0:	4705                	li	a4,1
ffffffffc0204ca2:	ef98                	sd	a4,24(a5)
}
ffffffffc0204ca4:	4501                	li	a0,0
ffffffffc0204ca6:	8082                	ret

ffffffffc0204ca8 <do_wait>:
{
ffffffffc0204ca8:	1101                	addi	sp,sp,-32
ffffffffc0204caa:	e822                	sd	s0,16(sp)
ffffffffc0204cac:	e426                	sd	s1,8(sp)
ffffffffc0204cae:	ec06                	sd	ra,24(sp)
ffffffffc0204cb0:	842e                	mv	s0,a1
ffffffffc0204cb2:	84aa                	mv	s1,a0
    if (code_store != NULL)
ffffffffc0204cb4:	c999                	beqz	a1,ffffffffc0204cca <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0204cb6:	000c2797          	auipc	a5,0xc2
ffffffffc0204cba:	0a27b783          	ld	a5,162(a5) # ffffffffc02c6d58 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0204cbe:	7788                	ld	a0,40(a5)
ffffffffc0204cc0:	4685                	li	a3,1
ffffffffc0204cc2:	4611                	li	a2,4
ffffffffc0204cc4:	f9bfe0ef          	jal	ra,ffffffffc0203c5e <user_mem_check>
ffffffffc0204cc8:	c909                	beqz	a0,ffffffffc0204cda <do_wait+0x32>
ffffffffc0204cca:	85a2                	mv	a1,s0
}
ffffffffc0204ccc:	6442                	ld	s0,16(sp)
ffffffffc0204cce:	60e2                	ld	ra,24(sp)
ffffffffc0204cd0:	8526                	mv	a0,s1
ffffffffc0204cd2:	64a2                	ld	s1,8(sp)
ffffffffc0204cd4:	6105                	addi	sp,sp,32
ffffffffc0204cd6:	f22ff06f          	j	ffffffffc02043f8 <do_wait.part.0>
ffffffffc0204cda:	60e2                	ld	ra,24(sp)
ffffffffc0204cdc:	6442                	ld	s0,16(sp)
ffffffffc0204cde:	64a2                	ld	s1,8(sp)
ffffffffc0204ce0:	5575                	li	a0,-3
ffffffffc0204ce2:	6105                	addi	sp,sp,32
ffffffffc0204ce4:	8082                	ret

ffffffffc0204ce6 <do_kill>:
{
ffffffffc0204ce6:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID)
ffffffffc0204ce8:	6789                	lui	a5,0x2
{
ffffffffc0204cea:	e406                	sd	ra,8(sp)
ffffffffc0204cec:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID)
ffffffffc0204cee:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204cf2:	17f9                	addi	a5,a5,-2
ffffffffc0204cf4:	02e7e963          	bltu	a5,a4,ffffffffc0204d26 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204cf8:	842a                	mv	s0,a0
ffffffffc0204cfa:	45a9                	li	a1,10
ffffffffc0204cfc:	2501                	sext.w	a0,a0
ffffffffc0204cfe:	676000ef          	jal	ra,ffffffffc0205374 <hash32>
ffffffffc0204d02:	02051793          	slli	a5,a0,0x20
ffffffffc0204d06:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204d0a:	000be797          	auipc	a5,0xbe
ffffffffc0204d0e:	fb678793          	addi	a5,a5,-74 # ffffffffc02c2cc0 <hash_list>
ffffffffc0204d12:	953e                	add	a0,a0,a5
ffffffffc0204d14:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list)
ffffffffc0204d16:	a029                	j	ffffffffc0204d20 <do_kill+0x3a>
            if (proc->pid == pid)
ffffffffc0204d18:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0204d1c:	00870b63          	beq	a4,s0,ffffffffc0204d32 <do_kill+0x4c>
ffffffffc0204d20:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204d22:	fef51be3          	bne	a0,a5,ffffffffc0204d18 <do_kill+0x32>
    return -E_INVAL;
ffffffffc0204d26:	5475                	li	s0,-3
}
ffffffffc0204d28:	60a2                	ld	ra,8(sp)
ffffffffc0204d2a:	8522                	mv	a0,s0
ffffffffc0204d2c:	6402                	ld	s0,0(sp)
ffffffffc0204d2e:	0141                	addi	sp,sp,16
ffffffffc0204d30:	8082                	ret
        if (!(proc->flags & PF_EXITING))
ffffffffc0204d32:	fd87a703          	lw	a4,-40(a5)
ffffffffc0204d36:	00177693          	andi	a3,a4,1
ffffffffc0204d3a:	e295                	bnez	a3,ffffffffc0204d5e <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0204d3c:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0204d3e:	00176713          	ori	a4,a4,1
ffffffffc0204d42:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0204d46:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0204d48:	fe06d0e3          	bgez	a3,ffffffffc0204d28 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0204d4c:	f2878513          	addi	a0,a5,-216
ffffffffc0204d50:	3b2000ef          	jal	ra,ffffffffc0205102 <wakeup_proc>
}
ffffffffc0204d54:	60a2                	ld	ra,8(sp)
ffffffffc0204d56:	8522                	mv	a0,s0
ffffffffc0204d58:	6402                	ld	s0,0(sp)
ffffffffc0204d5a:	0141                	addi	sp,sp,16
ffffffffc0204d5c:	8082                	ret
        return -E_KILLED;
ffffffffc0204d5e:	545d                	li	s0,-9
ffffffffc0204d60:	b7e1                	j	ffffffffc0204d28 <do_kill+0x42>

ffffffffc0204d62 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc0204d62:	1101                	addi	sp,sp,-32
ffffffffc0204d64:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0204d66:	000c2797          	auipc	a5,0xc2
ffffffffc0204d6a:	f5a78793          	addi	a5,a5,-166 # ffffffffc02c6cc0 <proc_list>
ffffffffc0204d6e:	ec06                	sd	ra,24(sp)
ffffffffc0204d70:	e822                	sd	s0,16(sp)
ffffffffc0204d72:	e04a                	sd	s2,0(sp)
ffffffffc0204d74:	000be497          	auipc	s1,0xbe
ffffffffc0204d78:	f4c48493          	addi	s1,s1,-180 # ffffffffc02c2cc0 <hash_list>
ffffffffc0204d7c:	e79c                	sd	a5,8(a5)
ffffffffc0204d7e:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0204d80:	000c2717          	auipc	a4,0xc2
ffffffffc0204d84:	f4070713          	addi	a4,a4,-192 # ffffffffc02c6cc0 <proc_list>
ffffffffc0204d88:	87a6                	mv	a5,s1
ffffffffc0204d8a:	e79c                	sd	a5,8(a5)
ffffffffc0204d8c:	e39c                	sd	a5,0(a5)
ffffffffc0204d8e:	07c1                	addi	a5,a5,16
ffffffffc0204d90:	fef71de3          	bne	a4,a5,ffffffffc0204d8a <proc_init+0x28>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc0204d94:	f67fe0ef          	jal	ra,ffffffffc0203cfa <alloc_proc>
ffffffffc0204d98:	000c2917          	auipc	s2,0xc2
ffffffffc0204d9c:	fc890913          	addi	s2,s2,-56 # ffffffffc02c6d60 <idleproc>
ffffffffc0204da0:	00a93023          	sd	a0,0(s2)
ffffffffc0204da4:	0e050f63          	beqz	a0,ffffffffc0204ea2 <proc_init+0x140>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0204da8:	4789                	li	a5,2
ffffffffc0204daa:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204dac:	00004797          	auipc	a5,0x4
ffffffffc0204db0:	25478793          	addi	a5,a5,596 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204db4:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204db8:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0204dba:	4785                	li	a5,1
ffffffffc0204dbc:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204dbe:	4641                	li	a2,16
ffffffffc0204dc0:	4581                	li	a1,0
ffffffffc0204dc2:	8522                	mv	a0,s0
ffffffffc0204dc4:	257000ef          	jal	ra,ffffffffc020581a <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204dc8:	463d                	li	a2,15
ffffffffc0204dca:	00002597          	auipc	a1,0x2
ffffffffc0204dce:	6ce58593          	addi	a1,a1,1742 # ffffffffc0207498 <default_pmm_manager+0xde8>
ffffffffc0204dd2:	8522                	mv	a0,s0
ffffffffc0204dd4:	259000ef          	jal	ra,ffffffffc020582c <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process++;
ffffffffc0204dd8:	000c2717          	auipc	a4,0xc2
ffffffffc0204ddc:	f9870713          	addi	a4,a4,-104 # ffffffffc02c6d70 <nr_process>
ffffffffc0204de0:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0204de2:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0204de6:	4601                	li	a2,0
    nr_process++;
ffffffffc0204de8:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0204dea:	4581                	li	a1,0
ffffffffc0204dec:	fffff517          	auipc	a0,0xfffff
ffffffffc0204df0:	7de50513          	addi	a0,a0,2014 # ffffffffc02045ca <init_main>
    nr_process++;
ffffffffc0204df4:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0204df6:	000c2797          	auipc	a5,0xc2
ffffffffc0204dfa:	f6d7b123          	sd	a3,-158(a5) # ffffffffc02c6d58 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0204dfe:	c60ff0ef          	jal	ra,ffffffffc020425e <kernel_thread>
ffffffffc0204e02:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc0204e04:	08a05363          	blez	a0,ffffffffc0204e8a <proc_init+0x128>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204e08:	6789                	lui	a5,0x2
ffffffffc0204e0a:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204e0e:	17f9                	addi	a5,a5,-2
ffffffffc0204e10:	2501                	sext.w	a0,a0
ffffffffc0204e12:	02e7e363          	bltu	a5,a4,ffffffffc0204e38 <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204e16:	45a9                	li	a1,10
ffffffffc0204e18:	55c000ef          	jal	ra,ffffffffc0205374 <hash32>
ffffffffc0204e1c:	02051793          	slli	a5,a0,0x20
ffffffffc0204e20:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0204e24:	96a6                	add	a3,a3,s1
ffffffffc0204e26:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0204e28:	a029                	j	ffffffffc0204e32 <proc_init+0xd0>
            if (proc->pid == pid)
ffffffffc0204e2a:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x8024>
ffffffffc0204e2e:	04870b63          	beq	a4,s0,ffffffffc0204e84 <proc_init+0x122>
    return listelm->next;
ffffffffc0204e32:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204e34:	fef69be3          	bne	a3,a5,ffffffffc0204e2a <proc_init+0xc8>
    return NULL;
ffffffffc0204e38:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e3a:	0b478493          	addi	s1,a5,180
ffffffffc0204e3e:	4641                	li	a2,16
ffffffffc0204e40:	4581                	li	a1,0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0204e42:	000c2417          	auipc	s0,0xc2
ffffffffc0204e46:	f2640413          	addi	s0,s0,-218 # ffffffffc02c6d68 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e4a:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0204e4c:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e4e:	1cd000ef          	jal	ra,ffffffffc020581a <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204e52:	463d                	li	a2,15
ffffffffc0204e54:	00002597          	auipc	a1,0x2
ffffffffc0204e58:	66c58593          	addi	a1,a1,1644 # ffffffffc02074c0 <default_pmm_manager+0xe10>
ffffffffc0204e5c:	8526                	mv	a0,s1
ffffffffc0204e5e:	1cf000ef          	jal	ra,ffffffffc020582c <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204e62:	00093783          	ld	a5,0(s2)
ffffffffc0204e66:	cbb5                	beqz	a5,ffffffffc0204eda <proc_init+0x178>
ffffffffc0204e68:	43dc                	lw	a5,4(a5)
ffffffffc0204e6a:	eba5                	bnez	a5,ffffffffc0204eda <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204e6c:	601c                	ld	a5,0(s0)
ffffffffc0204e6e:	c7b1                	beqz	a5,ffffffffc0204eba <proc_init+0x158>
ffffffffc0204e70:	43d8                	lw	a4,4(a5)
ffffffffc0204e72:	4785                	li	a5,1
ffffffffc0204e74:	04f71363          	bne	a4,a5,ffffffffc0204eba <proc_init+0x158>
}
ffffffffc0204e78:	60e2                	ld	ra,24(sp)
ffffffffc0204e7a:	6442                	ld	s0,16(sp)
ffffffffc0204e7c:	64a2                	ld	s1,8(sp)
ffffffffc0204e7e:	6902                	ld	s2,0(sp)
ffffffffc0204e80:	6105                	addi	sp,sp,32
ffffffffc0204e82:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204e84:	f2878793          	addi	a5,a5,-216
ffffffffc0204e88:	bf4d                	j	ffffffffc0204e3a <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0204e8a:	00002617          	auipc	a2,0x2
ffffffffc0204e8e:	61660613          	addi	a2,a2,1558 # ffffffffc02074a0 <default_pmm_manager+0xdf0>
ffffffffc0204e92:	40a00593          	li	a1,1034
ffffffffc0204e96:	00002517          	auipc	a0,0x2
ffffffffc0204e9a:	24250513          	addi	a0,a0,578 # ffffffffc02070d8 <default_pmm_manager+0xa28>
ffffffffc0204e9e:	df4fb0ef          	jal	ra,ffffffffc0200492 <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0204ea2:	00002617          	auipc	a2,0x2
ffffffffc0204ea6:	5de60613          	addi	a2,a2,1502 # ffffffffc0207480 <default_pmm_manager+0xdd0>
ffffffffc0204eaa:	3fb00593          	li	a1,1019
ffffffffc0204eae:	00002517          	auipc	a0,0x2
ffffffffc0204eb2:	22a50513          	addi	a0,a0,554 # ffffffffc02070d8 <default_pmm_manager+0xa28>
ffffffffc0204eb6:	ddcfb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204eba:	00002697          	auipc	a3,0x2
ffffffffc0204ebe:	63668693          	addi	a3,a3,1590 # ffffffffc02074f0 <default_pmm_manager+0xe40>
ffffffffc0204ec2:	00001617          	auipc	a2,0x1
ffffffffc0204ec6:	43e60613          	addi	a2,a2,1086 # ffffffffc0206300 <commands+0x850>
ffffffffc0204eca:	41100593          	li	a1,1041
ffffffffc0204ece:	00002517          	auipc	a0,0x2
ffffffffc0204ed2:	20a50513          	addi	a0,a0,522 # ffffffffc02070d8 <default_pmm_manager+0xa28>
ffffffffc0204ed6:	dbcfb0ef          	jal	ra,ffffffffc0200492 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204eda:	00002697          	auipc	a3,0x2
ffffffffc0204ede:	5ee68693          	addi	a3,a3,1518 # ffffffffc02074c8 <default_pmm_manager+0xe18>
ffffffffc0204ee2:	00001617          	auipc	a2,0x1
ffffffffc0204ee6:	41e60613          	addi	a2,a2,1054 # ffffffffc0206300 <commands+0x850>
ffffffffc0204eea:	41000593          	li	a1,1040
ffffffffc0204eee:	00002517          	auipc	a0,0x2
ffffffffc0204ef2:	1ea50513          	addi	a0,a0,490 # ffffffffc02070d8 <default_pmm_manager+0xa28>
ffffffffc0204ef6:	d9cfb0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0204efa <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc0204efa:	1141                	addi	sp,sp,-16
ffffffffc0204efc:	e022                	sd	s0,0(sp)
ffffffffc0204efe:	e406                	sd	ra,8(sp)
ffffffffc0204f00:	000c2417          	auipc	s0,0xc2
ffffffffc0204f04:	e5840413          	addi	s0,s0,-424 # ffffffffc02c6d58 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc0204f08:	6018                	ld	a4,0(s0)
ffffffffc0204f0a:	6f1c                	ld	a5,24(a4)
ffffffffc0204f0c:	dffd                	beqz	a5,ffffffffc0204f0a <cpu_idle+0x10>
        {
            schedule();
ffffffffc0204f0e:	2a6000ef          	jal	ra,ffffffffc02051b4 <schedule>
ffffffffc0204f12:	bfdd                	j	ffffffffc0204f08 <cpu_idle+0xe>

ffffffffc0204f14 <lab6_set_priority>:
        }
    }
}
// FOR LAB6, set the process's priority (bigger value will get more CPU time)
void lab6_set_priority(uint32_t priority)
{
ffffffffc0204f14:	1141                	addi	sp,sp,-16
ffffffffc0204f16:	e022                	sd	s0,0(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc0204f18:	85aa                	mv	a1,a0
{
ffffffffc0204f1a:	842a                	mv	s0,a0
    cprintf("set priority to %d\n", priority);
ffffffffc0204f1c:	00002517          	auipc	a0,0x2
ffffffffc0204f20:	5fc50513          	addi	a0,a0,1532 # ffffffffc0207518 <default_pmm_manager+0xe68>
{
ffffffffc0204f24:	e406                	sd	ra,8(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc0204f26:	a72fb0ef          	jal	ra,ffffffffc0200198 <cprintf>
    if (priority == 0)
        current->lab6_priority = 1;
ffffffffc0204f2a:	000c2797          	auipc	a5,0xc2
ffffffffc0204f2e:	e2e7b783          	ld	a5,-466(a5) # ffffffffc02c6d58 <current>
    if (priority == 0)
ffffffffc0204f32:	e801                	bnez	s0,ffffffffc0204f42 <lab6_set_priority+0x2e>
    else
        current->lab6_priority = priority;
}
ffffffffc0204f34:	60a2                	ld	ra,8(sp)
ffffffffc0204f36:	6402                	ld	s0,0(sp)
        current->lab6_priority = 1;
ffffffffc0204f38:	4705                	li	a4,1
ffffffffc0204f3a:	14e7a223          	sw	a4,324(a5)
}
ffffffffc0204f3e:	0141                	addi	sp,sp,16
ffffffffc0204f40:	8082                	ret
ffffffffc0204f42:	60a2                	ld	ra,8(sp)
        current->lab6_priority = priority;
ffffffffc0204f44:	1487a223          	sw	s0,324(a5)
}
ffffffffc0204f48:	6402                	ld	s0,0(sp)
ffffffffc0204f4a:	0141                	addi	sp,sp,16
ffffffffc0204f4c:	8082                	ret

ffffffffc0204f4e <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204f4e:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204f52:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204f56:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204f58:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204f5a:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204f5e:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204f62:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204f66:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204f6a:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204f6e:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204f72:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204f76:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204f7a:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204f7e:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204f82:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204f86:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204f8a:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204f8c:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204f8e:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204f92:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204f96:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204f9a:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204f9e:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204fa2:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204fa6:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204faa:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204fae:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204fb2:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204fb6:	8082                	ret

ffffffffc0204fb8 <RR_init>:
    elm->prev = elm->next = elm;
ffffffffc0204fb8:	e508                	sd	a0,8(a0)
ffffffffc0204fba:	e108                	sd	a0,0(a0)
static void
RR_init(struct run_queue *rq)
{
    // LAB6: YOUR CODE
    list_init(&(rq->run_list));
    rq->proc_num = 0;
ffffffffc0204fbc:	00052823          	sw	zero,16(a0)
}
ffffffffc0204fc0:	8082                	ret

ffffffffc0204fc2 <RR_pick_next>:
    return list->next == list;
ffffffffc0204fc2:	651c                	ld	a5,8(a0)
 */
static struct proc_struct *
RR_pick_next(struct run_queue *rq)
{
    // LAB6: YOUR CODE
    if (list_empty(&(rq->run_list))) {
ffffffffc0204fc4:	00f50563          	beq	a0,a5,ffffffffc0204fce <RR_pick_next+0xc>
        return NULL;
    }
    list_entry_t *le = list_next(&(rq->run_list));
    return le2proc(le, run_link);
ffffffffc0204fc8:	ef078513          	addi	a0,a5,-272
ffffffffc0204fcc:	8082                	ret
        return NULL;
ffffffffc0204fce:	4501                	li	a0,0
}
ffffffffc0204fd0:	8082                	ret

ffffffffc0204fd2 <RR_proc_tick>:
 */
static void
RR_proc_tick(struct run_queue *rq, struct proc_struct *proc)
{
    // LAB6: YOUR CODE
    if (proc->time_slice > 0) {
ffffffffc0204fd2:	1205a783          	lw	a5,288(a1)
ffffffffc0204fd6:	00f05563          	blez	a5,ffffffffc0204fe0 <RR_proc_tick+0xe>
        proc->time_slice --;
ffffffffc0204fda:	37fd                	addiw	a5,a5,-1
ffffffffc0204fdc:	12f5a023          	sw	a5,288(a1)
    }
    if (proc->time_slice == 0) {
ffffffffc0204fe0:	e399                	bnez	a5,ffffffffc0204fe6 <RR_proc_tick+0x14>
        proc->need_resched = 1;
ffffffffc0204fe2:	4785                	li	a5,1
ffffffffc0204fe4:	ed9c                	sd	a5,24(a1)
    }
}
ffffffffc0204fe6:	8082                	ret

ffffffffc0204fe8 <RR_dequeue>:
ffffffffc0204fe8:	1185b703          	ld	a4,280(a1)
    assert(!list_empty(&(proc->run_link)));
ffffffffc0204fec:	11058793          	addi	a5,a1,272
ffffffffc0204ff0:	02e78163          	beq	a5,a4,ffffffffc0205012 <RR_dequeue+0x2a>
    __list_del(listelm->prev, listelm->next);
ffffffffc0204ff4:	1105b603          	ld	a2,272(a1)
    rq->proc_num --;
ffffffffc0204ff8:	4914                	lw	a3,16(a0)
    prev->next = next;
ffffffffc0204ffa:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc0204ffc:	e310                	sd	a2,0(a4)
    elm->prev = elm->next = elm;
ffffffffc0204ffe:	10f5bc23          	sd	a5,280(a1)
ffffffffc0205002:	10f5b823          	sd	a5,272(a1)
    proc->rq = NULL;
ffffffffc0205006:	1005b423          	sd	zero,264(a1)
    rq->proc_num --;
ffffffffc020500a:	fff6879b          	addiw	a5,a3,-1
ffffffffc020500e:	c91c                	sw	a5,16(a0)
ffffffffc0205010:	8082                	ret
{
ffffffffc0205012:	1141                	addi	sp,sp,-16
    assert(!list_empty(&(proc->run_link)));
ffffffffc0205014:	00002697          	auipc	a3,0x2
ffffffffc0205018:	51c68693          	addi	a3,a3,1308 # ffffffffc0207530 <default_pmm_manager+0xe80>
ffffffffc020501c:	00001617          	auipc	a2,0x1
ffffffffc0205020:	2e460613          	addi	a2,a2,740 # ffffffffc0206300 <commands+0x850>
ffffffffc0205024:	03a00593          	li	a1,58
ffffffffc0205028:	00002517          	auipc	a0,0x2
ffffffffc020502c:	52850513          	addi	a0,a0,1320 # ffffffffc0207550 <default_pmm_manager+0xea0>
{
ffffffffc0205030:	e406                	sd	ra,8(sp)
    assert(!list_empty(&(proc->run_link)));
ffffffffc0205032:	c60fb0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0205036 <RR_enqueue>:
    assert(list_empty(&(proc->run_link)));
ffffffffc0205036:	1185b703          	ld	a4,280(a1)
ffffffffc020503a:	11058793          	addi	a5,a1,272
ffffffffc020503e:	02e79363          	bne	a5,a4,ffffffffc0205064 <RR_enqueue+0x2e>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0205042:	6114                	ld	a3,0(a0)
    rq->proc_num ++;
ffffffffc0205044:	4918                	lw	a4,16(a0)
    prev->next = next->prev = elm;
ffffffffc0205046:	e11c                	sd	a5,0(a0)
ffffffffc0205048:	e69c                	sd	a5,8(a3)
    proc->time_slice = rq->max_time_slice;
ffffffffc020504a:	4950                	lw	a2,20(a0)
    rq->proc_num ++;
ffffffffc020504c:	0017079b          	addiw	a5,a4,1
    elm->next = next;
ffffffffc0205050:	10a5bc23          	sd	a0,280(a1)
    elm->prev = prev;
ffffffffc0205054:	10d5b823          	sd	a3,272(a1)
    proc->rq = rq;
ffffffffc0205058:	10a5b423          	sd	a0,264(a1)
    rq->proc_num ++;
ffffffffc020505c:	c91c                	sw	a5,16(a0)
    proc->time_slice = rq->max_time_slice;
ffffffffc020505e:	12c5a023          	sw	a2,288(a1)
ffffffffc0205062:	8082                	ret
{
ffffffffc0205064:	1141                	addi	sp,sp,-16
    assert(list_empty(&(proc->run_link)));
ffffffffc0205066:	00002697          	auipc	a3,0x2
ffffffffc020506a:	50a68693          	addi	a3,a3,1290 # ffffffffc0207570 <default_pmm_manager+0xec0>
ffffffffc020506e:	00001617          	auipc	a2,0x1
ffffffffc0205072:	29260613          	addi	a2,a2,658 # ffffffffc0206300 <commands+0x850>
ffffffffc0205076:	02800593          	li	a1,40
ffffffffc020507a:	00002517          	auipc	a0,0x2
ffffffffc020507e:	4d650513          	addi	a0,a0,1238 # ffffffffc0207550 <default_pmm_manager+0xea0>
{
ffffffffc0205082:	e406                	sd	ra,8(sp)
    assert(list_empty(&(proc->run_link)));
ffffffffc0205084:	c0efb0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0205088 <sched_class_proc_tick>:
    return sched_class->pick_next(rq);
}

void sched_class_proc_tick(struct proc_struct *proc)
{
    if (proc != idleproc)
ffffffffc0205088:	000c2797          	auipc	a5,0xc2
ffffffffc020508c:	cd87b783          	ld	a5,-808(a5) # ffffffffc02c6d60 <idleproc>
{
ffffffffc0205090:	85aa                	mv	a1,a0
    if (proc != idleproc)
ffffffffc0205092:	00a78c63          	beq	a5,a0,ffffffffc02050aa <sched_class_proc_tick+0x22>
    {
        sched_class->proc_tick(rq, proc);
ffffffffc0205096:	000c2797          	auipc	a5,0xc2
ffffffffc020509a:	cea7b783          	ld	a5,-790(a5) # ffffffffc02c6d80 <sched_class>
ffffffffc020509e:	779c                	ld	a5,40(a5)
ffffffffc02050a0:	000c2517          	auipc	a0,0xc2
ffffffffc02050a4:	cd853503          	ld	a0,-808(a0) # ffffffffc02c6d78 <rq>
ffffffffc02050a8:	8782                	jr	a5
    }
    else
    {
        proc->need_resched = 1;
ffffffffc02050aa:	4705                	li	a4,1
ffffffffc02050ac:	ef98                	sd	a4,24(a5)
    }
}
ffffffffc02050ae:	8082                	ret

ffffffffc02050b0 <sched_init>:

static struct run_queue __rq;

void sched_init(void)
{
ffffffffc02050b0:	1141                	addi	sp,sp,-16
    list_init(&timer_list);

    sched_class = &default_sched_class;
ffffffffc02050b2:	000bd717          	auipc	a4,0xbd
ffffffffc02050b6:	7b670713          	addi	a4,a4,1974 # ffffffffc02c2868 <default_sched_class>
{
ffffffffc02050ba:	e022                	sd	s0,0(sp)
ffffffffc02050bc:	e406                	sd	ra,8(sp)
    elm->prev = elm->next = elm;
ffffffffc02050be:	000c2797          	auipc	a5,0xc2
ffffffffc02050c2:	c3278793          	addi	a5,a5,-974 # ffffffffc02c6cf0 <timer_list>

    rq = &__rq;
    rq->max_time_slice = MAX_TIME_SLICE;
    sched_class->init(rq);
ffffffffc02050c6:	6714                	ld	a3,8(a4)
    rq = &__rq;
ffffffffc02050c8:	000c2517          	auipc	a0,0xc2
ffffffffc02050cc:	c0850513          	addi	a0,a0,-1016 # ffffffffc02c6cd0 <__rq>
ffffffffc02050d0:	e79c                	sd	a5,8(a5)
ffffffffc02050d2:	e39c                	sd	a5,0(a5)
    rq->max_time_slice = MAX_TIME_SLICE;
ffffffffc02050d4:	4795                	li	a5,5
ffffffffc02050d6:	c95c                	sw	a5,20(a0)
    sched_class = &default_sched_class;
ffffffffc02050d8:	000c2417          	auipc	s0,0xc2
ffffffffc02050dc:	ca840413          	addi	s0,s0,-856 # ffffffffc02c6d80 <sched_class>
    rq = &__rq;
ffffffffc02050e0:	000c2797          	auipc	a5,0xc2
ffffffffc02050e4:	c8a7bc23          	sd	a0,-872(a5) # ffffffffc02c6d78 <rq>
    sched_class = &default_sched_class;
ffffffffc02050e8:	e018                	sd	a4,0(s0)
    sched_class->init(rq);
ffffffffc02050ea:	9682                	jalr	a3

    cprintf("sched class: %s\n", sched_class->name);
ffffffffc02050ec:	601c                	ld	a5,0(s0)
}
ffffffffc02050ee:	6402                	ld	s0,0(sp)
ffffffffc02050f0:	60a2                	ld	ra,8(sp)
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc02050f2:	638c                	ld	a1,0(a5)
ffffffffc02050f4:	00002517          	auipc	a0,0x2
ffffffffc02050f8:	4ac50513          	addi	a0,a0,1196 # ffffffffc02075a0 <default_pmm_manager+0xef0>
}
ffffffffc02050fc:	0141                	addi	sp,sp,16
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc02050fe:	89afb06f          	j	ffffffffc0200198 <cprintf>

ffffffffc0205102 <wakeup_proc>:

void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205102:	4118                	lw	a4,0(a0)
{
ffffffffc0205104:	1101                	addi	sp,sp,-32
ffffffffc0205106:	ec06                	sd	ra,24(sp)
ffffffffc0205108:	e822                	sd	s0,16(sp)
ffffffffc020510a:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020510c:	478d                	li	a5,3
ffffffffc020510e:	08f70363          	beq	a4,a5,ffffffffc0205194 <wakeup_proc+0x92>
ffffffffc0205112:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0205114:	100027f3          	csrr	a5,sstatus
ffffffffc0205118:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020511a:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020511c:	e7bd                	bnez	a5,ffffffffc020518a <wakeup_proc+0x88>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
ffffffffc020511e:	4789                	li	a5,2
ffffffffc0205120:	04f70863          	beq	a4,a5,ffffffffc0205170 <wakeup_proc+0x6e>
        {
            proc->state = PROC_RUNNABLE;
ffffffffc0205124:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0205126:	0e042623          	sw	zero,236(s0)
            if (proc != current)
ffffffffc020512a:	000c2797          	auipc	a5,0xc2
ffffffffc020512e:	c2e7b783          	ld	a5,-978(a5) # ffffffffc02c6d58 <current>
ffffffffc0205132:	02878363          	beq	a5,s0,ffffffffc0205158 <wakeup_proc+0x56>
    if (proc != idleproc)
ffffffffc0205136:	000c2797          	auipc	a5,0xc2
ffffffffc020513a:	c2a7b783          	ld	a5,-982(a5) # ffffffffc02c6d60 <idleproc>
ffffffffc020513e:	00f40d63          	beq	s0,a5,ffffffffc0205158 <wakeup_proc+0x56>
        sched_class->enqueue(rq, proc);
ffffffffc0205142:	000c2797          	auipc	a5,0xc2
ffffffffc0205146:	c3e7b783          	ld	a5,-962(a5) # ffffffffc02c6d80 <sched_class>
ffffffffc020514a:	6b9c                	ld	a5,16(a5)
ffffffffc020514c:	85a2                	mv	a1,s0
ffffffffc020514e:	000c2517          	auipc	a0,0xc2
ffffffffc0205152:	c2a53503          	ld	a0,-982(a0) # ffffffffc02c6d78 <rq>
ffffffffc0205156:	9782                	jalr	a5
    if (flag)
ffffffffc0205158:	e491                	bnez	s1,ffffffffc0205164 <wakeup_proc+0x62>
        {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020515a:	60e2                	ld	ra,24(sp)
ffffffffc020515c:	6442                	ld	s0,16(sp)
ffffffffc020515e:	64a2                	ld	s1,8(sp)
ffffffffc0205160:	6105                	addi	sp,sp,32
ffffffffc0205162:	8082                	ret
ffffffffc0205164:	6442                	ld	s0,16(sp)
ffffffffc0205166:	60e2                	ld	ra,24(sp)
ffffffffc0205168:	64a2                	ld	s1,8(sp)
ffffffffc020516a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020516c:	83dfb06f          	j	ffffffffc02009a8 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205170:	00002617          	auipc	a2,0x2
ffffffffc0205174:	48060613          	addi	a2,a2,1152 # ffffffffc02075f0 <default_pmm_manager+0xf40>
ffffffffc0205178:	05100593          	li	a1,81
ffffffffc020517c:	00002517          	auipc	a0,0x2
ffffffffc0205180:	45c50513          	addi	a0,a0,1116 # ffffffffc02075d8 <default_pmm_manager+0xf28>
ffffffffc0205184:	b76fb0ef          	jal	ra,ffffffffc02004fa <__warn>
ffffffffc0205188:	bfc1                	j	ffffffffc0205158 <wakeup_proc+0x56>
        intr_disable();
ffffffffc020518a:	825fb0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        if (proc->state != PROC_RUNNABLE)
ffffffffc020518e:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc0205190:	4485                	li	s1,1
ffffffffc0205192:	b771                	j	ffffffffc020511e <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205194:	00002697          	auipc	a3,0x2
ffffffffc0205198:	42468693          	addi	a3,a3,1060 # ffffffffc02075b8 <default_pmm_manager+0xf08>
ffffffffc020519c:	00001617          	auipc	a2,0x1
ffffffffc02051a0:	16460613          	addi	a2,a2,356 # ffffffffc0206300 <commands+0x850>
ffffffffc02051a4:	04200593          	li	a1,66
ffffffffc02051a8:	00002517          	auipc	a0,0x2
ffffffffc02051ac:	43050513          	addi	a0,a0,1072 # ffffffffc02075d8 <default_pmm_manager+0xf28>
ffffffffc02051b0:	ae2fb0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc02051b4 <schedule>:

void schedule(void)
{
ffffffffc02051b4:	7179                	addi	sp,sp,-48
ffffffffc02051b6:	f406                	sd	ra,40(sp)
ffffffffc02051b8:	f022                	sd	s0,32(sp)
ffffffffc02051ba:	ec26                	sd	s1,24(sp)
ffffffffc02051bc:	e84a                	sd	s2,16(sp)
ffffffffc02051be:	e44e                	sd	s3,8(sp)
ffffffffc02051c0:	e052                	sd	s4,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02051c2:	100027f3          	csrr	a5,sstatus
ffffffffc02051c6:	8b89                	andi	a5,a5,2
ffffffffc02051c8:	4a01                	li	s4,0
ffffffffc02051ca:	e3cd                	bnez	a5,ffffffffc020526c <schedule+0xb8>
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02051cc:	000c2497          	auipc	s1,0xc2
ffffffffc02051d0:	b8c48493          	addi	s1,s1,-1140 # ffffffffc02c6d58 <current>
ffffffffc02051d4:	608c                	ld	a1,0(s1)
        sched_class->enqueue(rq, proc);
ffffffffc02051d6:	000c2997          	auipc	s3,0xc2
ffffffffc02051da:	baa98993          	addi	s3,s3,-1110 # ffffffffc02c6d80 <sched_class>
ffffffffc02051de:	000c2917          	auipc	s2,0xc2
ffffffffc02051e2:	b9a90913          	addi	s2,s2,-1126 # ffffffffc02c6d78 <rq>
        if (current->state == PROC_RUNNABLE)
ffffffffc02051e6:	4194                	lw	a3,0(a1)
        current->need_resched = 0;
ffffffffc02051e8:	0005bc23          	sd	zero,24(a1)
        if (current->state == PROC_RUNNABLE)
ffffffffc02051ec:	4709                	li	a4,2
        sched_class->enqueue(rq, proc);
ffffffffc02051ee:	0009b783          	ld	a5,0(s3)
ffffffffc02051f2:	00093503          	ld	a0,0(s2)
        if (current->state == PROC_RUNNABLE)
ffffffffc02051f6:	04e68e63          	beq	a3,a4,ffffffffc0205252 <schedule+0x9e>
    return sched_class->pick_next(rq);
ffffffffc02051fa:	739c                	ld	a5,32(a5)
ffffffffc02051fc:	9782                	jalr	a5
ffffffffc02051fe:	842a                	mv	s0,a0
        {
            sched_class_enqueue(current);
        }
        if ((next = sched_class_pick_next()) != NULL)
ffffffffc0205200:	c521                	beqz	a0,ffffffffc0205248 <schedule+0x94>
    sched_class->dequeue(rq, proc);
ffffffffc0205202:	0009b783          	ld	a5,0(s3)
ffffffffc0205206:	00093503          	ld	a0,0(s2)
ffffffffc020520a:	85a2                	mv	a1,s0
ffffffffc020520c:	6f9c                	ld	a5,24(a5)
ffffffffc020520e:	9782                	jalr	a5
        }
        if (next == NULL)
        {
            next = idleproc;
        }
        next->runs++;
ffffffffc0205210:	441c                	lw	a5,8(s0)
        if (next != current)
ffffffffc0205212:	6098                	ld	a4,0(s1)
        next->runs++;
ffffffffc0205214:	2785                	addiw	a5,a5,1
ffffffffc0205216:	c41c                	sw	a5,8(s0)
        if (next != current)
ffffffffc0205218:	00870563          	beq	a4,s0,ffffffffc0205222 <schedule+0x6e>
        {
            proc_run(next);
ffffffffc020521c:	8522                	mv	a0,s0
ffffffffc020521e:	bf7fe0ef          	jal	ra,ffffffffc0203e14 <proc_run>
    if (flag)
ffffffffc0205222:	000a1a63          	bnez	s4,ffffffffc0205236 <schedule+0x82>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205226:	70a2                	ld	ra,40(sp)
ffffffffc0205228:	7402                	ld	s0,32(sp)
ffffffffc020522a:	64e2                	ld	s1,24(sp)
ffffffffc020522c:	6942                	ld	s2,16(sp)
ffffffffc020522e:	69a2                	ld	s3,8(sp)
ffffffffc0205230:	6a02                	ld	s4,0(sp)
ffffffffc0205232:	6145                	addi	sp,sp,48
ffffffffc0205234:	8082                	ret
ffffffffc0205236:	7402                	ld	s0,32(sp)
ffffffffc0205238:	70a2                	ld	ra,40(sp)
ffffffffc020523a:	64e2                	ld	s1,24(sp)
ffffffffc020523c:	6942                	ld	s2,16(sp)
ffffffffc020523e:	69a2                	ld	s3,8(sp)
ffffffffc0205240:	6a02                	ld	s4,0(sp)
ffffffffc0205242:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0205244:	f64fb06f          	j	ffffffffc02009a8 <intr_enable>
            next = idleproc;
ffffffffc0205248:	000c2417          	auipc	s0,0xc2
ffffffffc020524c:	b1843403          	ld	s0,-1256(s0) # ffffffffc02c6d60 <idleproc>
ffffffffc0205250:	b7c1                	j	ffffffffc0205210 <schedule+0x5c>
    if (proc != idleproc)
ffffffffc0205252:	000c2717          	auipc	a4,0xc2
ffffffffc0205256:	b0e73703          	ld	a4,-1266(a4) # ffffffffc02c6d60 <idleproc>
ffffffffc020525a:	fae580e3          	beq	a1,a4,ffffffffc02051fa <schedule+0x46>
        sched_class->enqueue(rq, proc);
ffffffffc020525e:	6b9c                	ld	a5,16(a5)
ffffffffc0205260:	9782                	jalr	a5
    return sched_class->pick_next(rq);
ffffffffc0205262:	0009b783          	ld	a5,0(s3)
ffffffffc0205266:	00093503          	ld	a0,0(s2)
ffffffffc020526a:	bf41                	j	ffffffffc02051fa <schedule+0x46>
        intr_disable();
ffffffffc020526c:	f42fb0ef          	jal	ra,ffffffffc02009ae <intr_disable>
        return 1;
ffffffffc0205270:	4a05                	li	s4,1
ffffffffc0205272:	bfa9                	j	ffffffffc02051cc <schedule+0x18>

ffffffffc0205274 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0205274:	000c2797          	auipc	a5,0xc2
ffffffffc0205278:	ae47b783          	ld	a5,-1308(a5) # ffffffffc02c6d58 <current>
}
ffffffffc020527c:	43c8                	lw	a0,4(a5)
ffffffffc020527e:	8082                	ret

ffffffffc0205280 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0205280:	4501                	li	a0,0
ffffffffc0205282:	8082                	ret

ffffffffc0205284 <sys_gettime>:
static int sys_gettime(uint64_t arg[]){
    return (int)ticks*10;
ffffffffc0205284:	000c2797          	auipc	a5,0xc2
ffffffffc0205288:	a847b783          	ld	a5,-1404(a5) # ffffffffc02c6d08 <ticks>
ffffffffc020528c:	0027951b          	slliw	a0,a5,0x2
ffffffffc0205290:	9d3d                	addw	a0,a0,a5
}
ffffffffc0205292:	0015151b          	slliw	a0,a0,0x1
ffffffffc0205296:	8082                	ret

ffffffffc0205298 <sys_lab6_set_priority>:
static int sys_lab6_set_priority(uint64_t arg[]){
    uint64_t priority = (uint64_t)arg[0];
    lab6_set_priority(priority);
ffffffffc0205298:	4108                	lw	a0,0(a0)
static int sys_lab6_set_priority(uint64_t arg[]){
ffffffffc020529a:	1141                	addi	sp,sp,-16
ffffffffc020529c:	e406                	sd	ra,8(sp)
    lab6_set_priority(priority);
ffffffffc020529e:	c77ff0ef          	jal	ra,ffffffffc0204f14 <lab6_set_priority>
    return 0;
}
ffffffffc02052a2:	60a2                	ld	ra,8(sp)
ffffffffc02052a4:	4501                	li	a0,0
ffffffffc02052a6:	0141                	addi	sp,sp,16
ffffffffc02052a8:	8082                	ret

ffffffffc02052aa <sys_putc>:
    cputchar(c);
ffffffffc02052aa:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc02052ac:	1141                	addi	sp,sp,-16
ffffffffc02052ae:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc02052b0:	f1ffa0ef          	jal	ra,ffffffffc02001ce <cputchar>
}
ffffffffc02052b4:	60a2                	ld	ra,8(sp)
ffffffffc02052b6:	4501                	li	a0,0
ffffffffc02052b8:	0141                	addi	sp,sp,16
ffffffffc02052ba:	8082                	ret

ffffffffc02052bc <sys_kill>:
    return do_kill(pid);
ffffffffc02052bc:	4108                	lw	a0,0(a0)
ffffffffc02052be:	a29ff06f          	j	ffffffffc0204ce6 <do_kill>

ffffffffc02052c2 <sys_yield>:
    return do_yield();
ffffffffc02052c2:	9d7ff06f          	j	ffffffffc0204c98 <do_yield>

ffffffffc02052c6 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc02052c6:	6d14                	ld	a3,24(a0)
ffffffffc02052c8:	6910                	ld	a2,16(a0)
ffffffffc02052ca:	650c                	ld	a1,8(a0)
ffffffffc02052cc:	6108                	ld	a0,0(a0)
ffffffffc02052ce:	c20ff06f          	j	ffffffffc02046ee <do_execve>

ffffffffc02052d2 <sys_wait>:
    return do_wait(pid, store);
ffffffffc02052d2:	650c                	ld	a1,8(a0)
ffffffffc02052d4:	4108                	lw	a0,0(a0)
ffffffffc02052d6:	9d3ff06f          	j	ffffffffc0204ca8 <do_wait>

ffffffffc02052da <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc02052da:	000c2797          	auipc	a5,0xc2
ffffffffc02052de:	a7e7b783          	ld	a5,-1410(a5) # ffffffffc02c6d58 <current>
ffffffffc02052e2:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02052e4:	4501                	li	a0,0
ffffffffc02052e6:	6a0c                	ld	a1,16(a2)
ffffffffc02052e8:	b91fe06f          	j	ffffffffc0203e78 <do_fork>

ffffffffc02052ec <sys_exit>:
    return do_exit(error_code);
ffffffffc02052ec:	4108                	lw	a0,0(a0)
ffffffffc02052ee:	fc1fe06f          	j	ffffffffc02042ae <do_exit>

ffffffffc02052f2 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc02052f2:	715d                	addi	sp,sp,-80
ffffffffc02052f4:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02052f6:	000c2497          	auipc	s1,0xc2
ffffffffc02052fa:	a6248493          	addi	s1,s1,-1438 # ffffffffc02c6d58 <current>
ffffffffc02052fe:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0205300:	e0a2                	sd	s0,64(sp)
ffffffffc0205302:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205304:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0205306:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205308:	0ff00793          	li	a5,255
    int num = tf->gpr.a0;
ffffffffc020530c:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205310:	0327ee63          	bltu	a5,s2,ffffffffc020534c <syscall+0x5a>
        if (syscalls[num] != NULL) {
ffffffffc0205314:	00391713          	slli	a4,s2,0x3
ffffffffc0205318:	00002797          	auipc	a5,0x2
ffffffffc020531c:	34078793          	addi	a5,a5,832 # ffffffffc0207658 <syscalls>
ffffffffc0205320:	97ba                	add	a5,a5,a4
ffffffffc0205322:	639c                	ld	a5,0(a5)
ffffffffc0205324:	c785                	beqz	a5,ffffffffc020534c <syscall+0x5a>
            arg[0] = tf->gpr.a1;
ffffffffc0205326:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0205328:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc020532a:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc020532c:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc020532e:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0205330:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0205332:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0205334:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0205336:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0205338:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc020533a:	0028                	addi	a0,sp,8
ffffffffc020533c:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc020533e:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205340:	e828                	sd	a0,80(s0)
}
ffffffffc0205342:	6406                	ld	s0,64(sp)
ffffffffc0205344:	74e2                	ld	s1,56(sp)
ffffffffc0205346:	7942                	ld	s2,48(sp)
ffffffffc0205348:	6161                	addi	sp,sp,80
ffffffffc020534a:	8082                	ret
    print_trapframe(tf);
ffffffffc020534c:	8522                	mv	a0,s0
ffffffffc020534e:	851fb0ef          	jal	ra,ffffffffc0200b9e <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0205352:	609c                	ld	a5,0(s1)
ffffffffc0205354:	86ca                	mv	a3,s2
ffffffffc0205356:	00002617          	auipc	a2,0x2
ffffffffc020535a:	2ba60613          	addi	a2,a2,698 # ffffffffc0207610 <default_pmm_manager+0xf60>
ffffffffc020535e:	43d8                	lw	a4,4(a5)
ffffffffc0205360:	06c00593          	li	a1,108
ffffffffc0205364:	0b478793          	addi	a5,a5,180
ffffffffc0205368:	00002517          	auipc	a0,0x2
ffffffffc020536c:	2d850513          	addi	a0,a0,728 # ffffffffc0207640 <default_pmm_manager+0xf90>
ffffffffc0205370:	922fb0ef          	jal	ra,ffffffffc0200492 <__panic>

ffffffffc0205374 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0205374:	9e3707b7          	lui	a5,0x9e370
ffffffffc0205378:	2785                	addiw	a5,a5,1
ffffffffc020537a:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc020537e:	02000793          	li	a5,32
ffffffffc0205382:	9f8d                	subw	a5,a5,a1
}
ffffffffc0205384:	00f5553b          	srlw	a0,a0,a5
ffffffffc0205388:	8082                	ret

ffffffffc020538a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020538a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020538e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0205390:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205394:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0205396:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020539a:	f022                	sd	s0,32(sp)
ffffffffc020539c:	ec26                	sd	s1,24(sp)
ffffffffc020539e:	e84a                	sd	s2,16(sp)
ffffffffc02053a0:	f406                	sd	ra,40(sp)
ffffffffc02053a2:	e44e                	sd	s3,8(sp)
ffffffffc02053a4:	84aa                	mv	s1,a0
ffffffffc02053a6:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02053a8:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02053ac:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02053ae:	03067e63          	bgeu	a2,a6,ffffffffc02053ea <printnum+0x60>
ffffffffc02053b2:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02053b4:	00805763          	blez	s0,ffffffffc02053c2 <printnum+0x38>
ffffffffc02053b8:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02053ba:	85ca                	mv	a1,s2
ffffffffc02053bc:	854e                	mv	a0,s3
ffffffffc02053be:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02053c0:	fc65                	bnez	s0,ffffffffc02053b8 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02053c2:	1a02                	slli	s4,s4,0x20
ffffffffc02053c4:	00003797          	auipc	a5,0x3
ffffffffc02053c8:	a9478793          	addi	a5,a5,-1388 # ffffffffc0207e58 <syscalls+0x800>
ffffffffc02053cc:	020a5a13          	srli	s4,s4,0x20
ffffffffc02053d0:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02053d2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02053d4:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02053d8:	70a2                	ld	ra,40(sp)
ffffffffc02053da:	69a2                	ld	s3,8(sp)
ffffffffc02053dc:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02053de:	85ca                	mv	a1,s2
ffffffffc02053e0:	87a6                	mv	a5,s1
}
ffffffffc02053e2:	6942                	ld	s2,16(sp)
ffffffffc02053e4:	64e2                	ld	s1,24(sp)
ffffffffc02053e6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02053e8:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02053ea:	03065633          	divu	a2,a2,a6
ffffffffc02053ee:	8722                	mv	a4,s0
ffffffffc02053f0:	f9bff0ef          	jal	ra,ffffffffc020538a <printnum>
ffffffffc02053f4:	b7f9                	j	ffffffffc02053c2 <printnum+0x38>

ffffffffc02053f6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02053f6:	7119                	addi	sp,sp,-128
ffffffffc02053f8:	f4a6                	sd	s1,104(sp)
ffffffffc02053fa:	f0ca                	sd	s2,96(sp)
ffffffffc02053fc:	ecce                	sd	s3,88(sp)
ffffffffc02053fe:	e8d2                	sd	s4,80(sp)
ffffffffc0205400:	e4d6                	sd	s5,72(sp)
ffffffffc0205402:	e0da                	sd	s6,64(sp)
ffffffffc0205404:	fc5e                	sd	s7,56(sp)
ffffffffc0205406:	f06a                	sd	s10,32(sp)
ffffffffc0205408:	fc86                	sd	ra,120(sp)
ffffffffc020540a:	f8a2                	sd	s0,112(sp)
ffffffffc020540c:	f862                	sd	s8,48(sp)
ffffffffc020540e:	f466                	sd	s9,40(sp)
ffffffffc0205410:	ec6e                	sd	s11,24(sp)
ffffffffc0205412:	892a                	mv	s2,a0
ffffffffc0205414:	84ae                	mv	s1,a1
ffffffffc0205416:	8d32                	mv	s10,a2
ffffffffc0205418:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020541a:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020541e:	5b7d                	li	s6,-1
ffffffffc0205420:	00003a97          	auipc	s5,0x3
ffffffffc0205424:	a64a8a93          	addi	s5,s5,-1436 # ffffffffc0207e84 <syscalls+0x82c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205428:	00003b97          	auipc	s7,0x3
ffffffffc020542c:	c78b8b93          	addi	s7,s7,-904 # ffffffffc02080a0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205430:	000d4503          	lbu	a0,0(s10)
ffffffffc0205434:	001d0413          	addi	s0,s10,1
ffffffffc0205438:	01350a63          	beq	a0,s3,ffffffffc020544c <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc020543c:	c121                	beqz	a0,ffffffffc020547c <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020543e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205440:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0205442:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205444:	fff44503          	lbu	a0,-1(s0)
ffffffffc0205448:	ff351ae3          	bne	a0,s3,ffffffffc020543c <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020544c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0205450:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0205454:	4c81                	li	s9,0
ffffffffc0205456:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0205458:	5c7d                	li	s8,-1
ffffffffc020545a:	5dfd                	li	s11,-1
ffffffffc020545c:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0205460:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205462:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0205466:	0ff5f593          	zext.b	a1,a1
ffffffffc020546a:	00140d13          	addi	s10,s0,1
ffffffffc020546e:	04b56263          	bltu	a0,a1,ffffffffc02054b2 <vprintfmt+0xbc>
ffffffffc0205472:	058a                	slli	a1,a1,0x2
ffffffffc0205474:	95d6                	add	a1,a1,s5
ffffffffc0205476:	4194                	lw	a3,0(a1)
ffffffffc0205478:	96d6                	add	a3,a3,s5
ffffffffc020547a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020547c:	70e6                	ld	ra,120(sp)
ffffffffc020547e:	7446                	ld	s0,112(sp)
ffffffffc0205480:	74a6                	ld	s1,104(sp)
ffffffffc0205482:	7906                	ld	s2,96(sp)
ffffffffc0205484:	69e6                	ld	s3,88(sp)
ffffffffc0205486:	6a46                	ld	s4,80(sp)
ffffffffc0205488:	6aa6                	ld	s5,72(sp)
ffffffffc020548a:	6b06                	ld	s6,64(sp)
ffffffffc020548c:	7be2                	ld	s7,56(sp)
ffffffffc020548e:	7c42                	ld	s8,48(sp)
ffffffffc0205490:	7ca2                	ld	s9,40(sp)
ffffffffc0205492:	7d02                	ld	s10,32(sp)
ffffffffc0205494:	6de2                	ld	s11,24(sp)
ffffffffc0205496:	6109                	addi	sp,sp,128
ffffffffc0205498:	8082                	ret
            padc = '0';
ffffffffc020549a:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020549c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02054a0:	846a                	mv	s0,s10
ffffffffc02054a2:	00140d13          	addi	s10,s0,1
ffffffffc02054a6:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02054aa:	0ff5f593          	zext.b	a1,a1
ffffffffc02054ae:	fcb572e3          	bgeu	a0,a1,ffffffffc0205472 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02054b2:	85a6                	mv	a1,s1
ffffffffc02054b4:	02500513          	li	a0,37
ffffffffc02054b8:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02054ba:	fff44783          	lbu	a5,-1(s0)
ffffffffc02054be:	8d22                	mv	s10,s0
ffffffffc02054c0:	f73788e3          	beq	a5,s3,ffffffffc0205430 <vprintfmt+0x3a>
ffffffffc02054c4:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02054c8:	1d7d                	addi	s10,s10,-1
ffffffffc02054ca:	ff379de3          	bne	a5,s3,ffffffffc02054c4 <vprintfmt+0xce>
ffffffffc02054ce:	b78d                	j	ffffffffc0205430 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02054d0:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02054d4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02054d8:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02054da:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02054de:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02054e2:	02d86463          	bltu	a6,a3,ffffffffc020550a <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02054e6:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02054ea:	002c169b          	slliw	a3,s8,0x2
ffffffffc02054ee:	0186873b          	addw	a4,a3,s8
ffffffffc02054f2:	0017171b          	slliw	a4,a4,0x1
ffffffffc02054f6:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02054f8:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02054fc:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02054fe:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0205502:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0205506:	fed870e3          	bgeu	a6,a3,ffffffffc02054e6 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020550a:	f40ddce3          	bgez	s11,ffffffffc0205462 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020550e:	8de2                	mv	s11,s8
ffffffffc0205510:	5c7d                	li	s8,-1
ffffffffc0205512:	bf81                	j	ffffffffc0205462 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0205514:	fffdc693          	not	a3,s11
ffffffffc0205518:	96fd                	srai	a3,a3,0x3f
ffffffffc020551a:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020551e:	00144603          	lbu	a2,1(s0)
ffffffffc0205522:	2d81                	sext.w	s11,s11
ffffffffc0205524:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0205526:	bf35                	j	ffffffffc0205462 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0205528:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020552c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0205530:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205532:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0205534:	bfd9                	j	ffffffffc020550a <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0205536:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205538:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020553c:	01174463          	blt	a4,a7,ffffffffc0205544 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0205540:	1a088e63          	beqz	a7,ffffffffc02056fc <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0205544:	000a3603          	ld	a2,0(s4)
ffffffffc0205548:	46c1                	li	a3,16
ffffffffc020554a:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020554c:	2781                	sext.w	a5,a5
ffffffffc020554e:	876e                	mv	a4,s11
ffffffffc0205550:	85a6                	mv	a1,s1
ffffffffc0205552:	854a                	mv	a0,s2
ffffffffc0205554:	e37ff0ef          	jal	ra,ffffffffc020538a <printnum>
            break;
ffffffffc0205558:	bde1                	j	ffffffffc0205430 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020555a:	000a2503          	lw	a0,0(s4)
ffffffffc020555e:	85a6                	mv	a1,s1
ffffffffc0205560:	0a21                	addi	s4,s4,8
ffffffffc0205562:	9902                	jalr	s2
            break;
ffffffffc0205564:	b5f1                	j	ffffffffc0205430 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0205566:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205568:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020556c:	01174463          	blt	a4,a7,ffffffffc0205574 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0205570:	18088163          	beqz	a7,ffffffffc02056f2 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0205574:	000a3603          	ld	a2,0(s4)
ffffffffc0205578:	46a9                	li	a3,10
ffffffffc020557a:	8a2e                	mv	s4,a1
ffffffffc020557c:	bfc1                	j	ffffffffc020554c <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020557e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0205582:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205584:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0205586:	bdf1                	j	ffffffffc0205462 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0205588:	85a6                	mv	a1,s1
ffffffffc020558a:	02500513          	li	a0,37
ffffffffc020558e:	9902                	jalr	s2
            break;
ffffffffc0205590:	b545                	j	ffffffffc0205430 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205592:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0205596:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205598:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020559a:	b5e1                	j	ffffffffc0205462 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020559c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020559e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02055a2:	01174463          	blt	a4,a7,ffffffffc02055aa <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02055a6:	14088163          	beqz	a7,ffffffffc02056e8 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02055aa:	000a3603          	ld	a2,0(s4)
ffffffffc02055ae:	46a1                	li	a3,8
ffffffffc02055b0:	8a2e                	mv	s4,a1
ffffffffc02055b2:	bf69                	j	ffffffffc020554c <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02055b4:	03000513          	li	a0,48
ffffffffc02055b8:	85a6                	mv	a1,s1
ffffffffc02055ba:	e03e                	sd	a5,0(sp)
ffffffffc02055bc:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02055be:	85a6                	mv	a1,s1
ffffffffc02055c0:	07800513          	li	a0,120
ffffffffc02055c4:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02055c6:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02055c8:	6782                	ld	a5,0(sp)
ffffffffc02055ca:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02055cc:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02055d0:	bfb5                	j	ffffffffc020554c <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02055d2:	000a3403          	ld	s0,0(s4)
ffffffffc02055d6:	008a0713          	addi	a4,s4,8
ffffffffc02055da:	e03a                	sd	a4,0(sp)
ffffffffc02055dc:	14040263          	beqz	s0,ffffffffc0205720 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02055e0:	0fb05763          	blez	s11,ffffffffc02056ce <vprintfmt+0x2d8>
ffffffffc02055e4:	02d00693          	li	a3,45
ffffffffc02055e8:	0cd79163          	bne	a5,a3,ffffffffc02056aa <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02055ec:	00044783          	lbu	a5,0(s0)
ffffffffc02055f0:	0007851b          	sext.w	a0,a5
ffffffffc02055f4:	cf85                	beqz	a5,ffffffffc020562c <vprintfmt+0x236>
ffffffffc02055f6:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02055fa:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02055fe:	000c4563          	bltz	s8,ffffffffc0205608 <vprintfmt+0x212>
ffffffffc0205602:	3c7d                	addiw	s8,s8,-1
ffffffffc0205604:	036c0263          	beq	s8,s6,ffffffffc0205628 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0205608:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020560a:	0e0c8e63          	beqz	s9,ffffffffc0205706 <vprintfmt+0x310>
ffffffffc020560e:	3781                	addiw	a5,a5,-32
ffffffffc0205610:	0ef47b63          	bgeu	s0,a5,ffffffffc0205706 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0205614:	03f00513          	li	a0,63
ffffffffc0205618:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020561a:	000a4783          	lbu	a5,0(s4)
ffffffffc020561e:	3dfd                	addiw	s11,s11,-1
ffffffffc0205620:	0a05                	addi	s4,s4,1
ffffffffc0205622:	0007851b          	sext.w	a0,a5
ffffffffc0205626:	ffe1                	bnez	a5,ffffffffc02055fe <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0205628:	01b05963          	blez	s11,ffffffffc020563a <vprintfmt+0x244>
ffffffffc020562c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020562e:	85a6                	mv	a1,s1
ffffffffc0205630:	02000513          	li	a0,32
ffffffffc0205634:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0205636:	fe0d9be3          	bnez	s11,ffffffffc020562c <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020563a:	6a02                	ld	s4,0(sp)
ffffffffc020563c:	bbd5                	j	ffffffffc0205430 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020563e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205640:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0205644:	01174463          	blt	a4,a7,ffffffffc020564c <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0205648:	08088d63          	beqz	a7,ffffffffc02056e2 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc020564c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0205650:	0a044d63          	bltz	s0,ffffffffc020570a <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0205654:	8622                	mv	a2,s0
ffffffffc0205656:	8a66                	mv	s4,s9
ffffffffc0205658:	46a9                	li	a3,10
ffffffffc020565a:	bdcd                	j	ffffffffc020554c <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc020565c:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205660:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0205662:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0205664:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0205668:	8fb5                	xor	a5,a5,a3
ffffffffc020566a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020566e:	02d74163          	blt	a4,a3,ffffffffc0205690 <vprintfmt+0x29a>
ffffffffc0205672:	00369793          	slli	a5,a3,0x3
ffffffffc0205676:	97de                	add	a5,a5,s7
ffffffffc0205678:	639c                	ld	a5,0(a5)
ffffffffc020567a:	cb99                	beqz	a5,ffffffffc0205690 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020567c:	86be                	mv	a3,a5
ffffffffc020567e:	00000617          	auipc	a2,0x0
ffffffffc0205682:	1f260613          	addi	a2,a2,498 # ffffffffc0205870 <etext+0x2c>
ffffffffc0205686:	85a6                	mv	a1,s1
ffffffffc0205688:	854a                	mv	a0,s2
ffffffffc020568a:	0ce000ef          	jal	ra,ffffffffc0205758 <printfmt>
ffffffffc020568e:	b34d                	j	ffffffffc0205430 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0205690:	00002617          	auipc	a2,0x2
ffffffffc0205694:	7e860613          	addi	a2,a2,2024 # ffffffffc0207e78 <syscalls+0x820>
ffffffffc0205698:	85a6                	mv	a1,s1
ffffffffc020569a:	854a                	mv	a0,s2
ffffffffc020569c:	0bc000ef          	jal	ra,ffffffffc0205758 <printfmt>
ffffffffc02056a0:	bb41                	j	ffffffffc0205430 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02056a2:	00002417          	auipc	s0,0x2
ffffffffc02056a6:	7ce40413          	addi	s0,s0,1998 # ffffffffc0207e70 <syscalls+0x818>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02056aa:	85e2                	mv	a1,s8
ffffffffc02056ac:	8522                	mv	a0,s0
ffffffffc02056ae:	e43e                	sd	a5,8(sp)
ffffffffc02056b0:	0e2000ef          	jal	ra,ffffffffc0205792 <strnlen>
ffffffffc02056b4:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02056b8:	01b05b63          	blez	s11,ffffffffc02056ce <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02056bc:	67a2                	ld	a5,8(sp)
ffffffffc02056be:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02056c2:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02056c4:	85a6                	mv	a1,s1
ffffffffc02056c6:	8552                	mv	a0,s4
ffffffffc02056c8:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02056ca:	fe0d9ce3          	bnez	s11,ffffffffc02056c2 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02056ce:	00044783          	lbu	a5,0(s0)
ffffffffc02056d2:	00140a13          	addi	s4,s0,1
ffffffffc02056d6:	0007851b          	sext.w	a0,a5
ffffffffc02056da:	d3a5                	beqz	a5,ffffffffc020563a <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02056dc:	05e00413          	li	s0,94
ffffffffc02056e0:	bf39                	j	ffffffffc02055fe <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02056e2:	000a2403          	lw	s0,0(s4)
ffffffffc02056e6:	b7ad                	j	ffffffffc0205650 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02056e8:	000a6603          	lwu	a2,0(s4)
ffffffffc02056ec:	46a1                	li	a3,8
ffffffffc02056ee:	8a2e                	mv	s4,a1
ffffffffc02056f0:	bdb1                	j	ffffffffc020554c <vprintfmt+0x156>
ffffffffc02056f2:	000a6603          	lwu	a2,0(s4)
ffffffffc02056f6:	46a9                	li	a3,10
ffffffffc02056f8:	8a2e                	mv	s4,a1
ffffffffc02056fa:	bd89                	j	ffffffffc020554c <vprintfmt+0x156>
ffffffffc02056fc:	000a6603          	lwu	a2,0(s4)
ffffffffc0205700:	46c1                	li	a3,16
ffffffffc0205702:	8a2e                	mv	s4,a1
ffffffffc0205704:	b5a1                	j	ffffffffc020554c <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0205706:	9902                	jalr	s2
ffffffffc0205708:	bf09                	j	ffffffffc020561a <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020570a:	85a6                	mv	a1,s1
ffffffffc020570c:	02d00513          	li	a0,45
ffffffffc0205710:	e03e                	sd	a5,0(sp)
ffffffffc0205712:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0205714:	6782                	ld	a5,0(sp)
ffffffffc0205716:	8a66                	mv	s4,s9
ffffffffc0205718:	40800633          	neg	a2,s0
ffffffffc020571c:	46a9                	li	a3,10
ffffffffc020571e:	b53d                	j	ffffffffc020554c <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0205720:	03b05163          	blez	s11,ffffffffc0205742 <vprintfmt+0x34c>
ffffffffc0205724:	02d00693          	li	a3,45
ffffffffc0205728:	f6d79de3          	bne	a5,a3,ffffffffc02056a2 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc020572c:	00002417          	auipc	s0,0x2
ffffffffc0205730:	74440413          	addi	s0,s0,1860 # ffffffffc0207e70 <syscalls+0x818>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205734:	02800793          	li	a5,40
ffffffffc0205738:	02800513          	li	a0,40
ffffffffc020573c:	00140a13          	addi	s4,s0,1
ffffffffc0205740:	bd6d                	j	ffffffffc02055fa <vprintfmt+0x204>
ffffffffc0205742:	00002a17          	auipc	s4,0x2
ffffffffc0205746:	72fa0a13          	addi	s4,s4,1839 # ffffffffc0207e71 <syscalls+0x819>
ffffffffc020574a:	02800513          	li	a0,40
ffffffffc020574e:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205752:	05e00413          	li	s0,94
ffffffffc0205756:	b565                	j	ffffffffc02055fe <vprintfmt+0x208>

ffffffffc0205758 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205758:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020575a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020575e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205760:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205762:	ec06                	sd	ra,24(sp)
ffffffffc0205764:	f83a                	sd	a4,48(sp)
ffffffffc0205766:	fc3e                	sd	a5,56(sp)
ffffffffc0205768:	e0c2                	sd	a6,64(sp)
ffffffffc020576a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020576c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020576e:	c89ff0ef          	jal	ra,ffffffffc02053f6 <vprintfmt>
}
ffffffffc0205772:	60e2                	ld	ra,24(sp)
ffffffffc0205774:	6161                	addi	sp,sp,80
ffffffffc0205776:	8082                	ret

ffffffffc0205778 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0205778:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc020577c:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc020577e:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0205780:	cb81                	beqz	a5,ffffffffc0205790 <strlen+0x18>
        cnt ++;
ffffffffc0205782:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0205784:	00a707b3          	add	a5,a4,a0
ffffffffc0205788:	0007c783          	lbu	a5,0(a5)
ffffffffc020578c:	fbfd                	bnez	a5,ffffffffc0205782 <strlen+0xa>
ffffffffc020578e:	8082                	ret
    }
    return cnt;
}
ffffffffc0205790:	8082                	ret

ffffffffc0205792 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0205792:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205794:	e589                	bnez	a1,ffffffffc020579e <strnlen+0xc>
ffffffffc0205796:	a811                	j	ffffffffc02057aa <strnlen+0x18>
        cnt ++;
ffffffffc0205798:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020579a:	00f58863          	beq	a1,a5,ffffffffc02057aa <strnlen+0x18>
ffffffffc020579e:	00f50733          	add	a4,a0,a5
ffffffffc02057a2:	00074703          	lbu	a4,0(a4)
ffffffffc02057a6:	fb6d                	bnez	a4,ffffffffc0205798 <strnlen+0x6>
ffffffffc02057a8:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02057aa:	852e                	mv	a0,a1
ffffffffc02057ac:	8082                	ret

ffffffffc02057ae <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02057ae:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02057b0:	0005c703          	lbu	a4,0(a1)
ffffffffc02057b4:	0785                	addi	a5,a5,1
ffffffffc02057b6:	0585                	addi	a1,a1,1
ffffffffc02057b8:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02057bc:	fb75                	bnez	a4,ffffffffc02057b0 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02057be:	8082                	ret

ffffffffc02057c0 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02057c0:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02057c4:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02057c8:	cb89                	beqz	a5,ffffffffc02057da <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02057ca:	0505                	addi	a0,a0,1
ffffffffc02057cc:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02057ce:	fee789e3          	beq	a5,a4,ffffffffc02057c0 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02057d2:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02057d6:	9d19                	subw	a0,a0,a4
ffffffffc02057d8:	8082                	ret
ffffffffc02057da:	4501                	li	a0,0
ffffffffc02057dc:	bfed                	j	ffffffffc02057d6 <strcmp+0x16>

ffffffffc02057de <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02057de:	c20d                	beqz	a2,ffffffffc0205800 <strncmp+0x22>
ffffffffc02057e0:	962e                	add	a2,a2,a1
ffffffffc02057e2:	a031                	j	ffffffffc02057ee <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc02057e4:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02057e6:	00e79a63          	bne	a5,a4,ffffffffc02057fa <strncmp+0x1c>
ffffffffc02057ea:	00b60b63          	beq	a2,a1,ffffffffc0205800 <strncmp+0x22>
ffffffffc02057ee:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc02057f2:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02057f4:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02057f8:	f7f5                	bnez	a5,ffffffffc02057e4 <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02057fa:	40e7853b          	subw	a0,a5,a4
}
ffffffffc02057fe:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205800:	4501                	li	a0,0
ffffffffc0205802:	8082                	ret

ffffffffc0205804 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0205804:	00054783          	lbu	a5,0(a0)
ffffffffc0205808:	c799                	beqz	a5,ffffffffc0205816 <strchr+0x12>
        if (*s == c) {
ffffffffc020580a:	00f58763          	beq	a1,a5,ffffffffc0205818 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020580e:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0205812:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0205814:	fbfd                	bnez	a5,ffffffffc020580a <strchr+0x6>
    }
    return NULL;
ffffffffc0205816:	4501                	li	a0,0
}
ffffffffc0205818:	8082                	ret

ffffffffc020581a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020581a:	ca01                	beqz	a2,ffffffffc020582a <memset+0x10>
ffffffffc020581c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020581e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0205820:	0785                	addi	a5,a5,1
ffffffffc0205822:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0205826:	fec79de3          	bne	a5,a2,ffffffffc0205820 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020582a:	8082                	ret

ffffffffc020582c <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020582c:	ca19                	beqz	a2,ffffffffc0205842 <memcpy+0x16>
ffffffffc020582e:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0205830:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0205832:	0005c703          	lbu	a4,0(a1)
ffffffffc0205836:	0585                	addi	a1,a1,1
ffffffffc0205838:	0785                	addi	a5,a5,1
ffffffffc020583a:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020583e:	fec59ae3          	bne	a1,a2,ffffffffc0205832 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0205842:	8082                	ret
