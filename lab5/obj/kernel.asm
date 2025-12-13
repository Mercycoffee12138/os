
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	0000b297          	auipc	t0,0xb
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc020b000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	0000b297          	auipc	t0,0xb
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc020b008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c020a2b7          	lui	t0,0xc020a
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
ffffffffc020003c:	c020a137          	lui	sp,0xc020a

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
ffffffffc020004a:	000b3517          	auipc	a0,0xb3
ffffffffc020004e:	31e50513          	addi	a0,a0,798 # ffffffffc02b3368 <buf>
ffffffffc0200052:	000b7617          	auipc	a2,0xb7
ffffffffc0200056:	7c260613          	addi	a2,a2,1986 # ffffffffc02b7814 <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	1ff050ef          	jal	ra,ffffffffc0205a60 <memset>
    dtb_init();
ffffffffc0200066:	598000ef          	jal	ra,ffffffffc02005fe <dtb_init>
    cons_init(); // init the console
ffffffffc020006a:	522000ef          	jal	ra,ffffffffc020058c <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006e:	00006597          	auipc	a1,0x6
ffffffffc0200072:	a2258593          	addi	a1,a1,-1502 # ffffffffc0205a90 <etext+0x6>
ffffffffc0200076:	00006517          	auipc	a0,0x6
ffffffffc020007a:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0205ab0 <etext+0x26>
ffffffffc020007e:	116000ef          	jal	ra,ffffffffc0200194 <cprintf>

    print_kerninfo();
ffffffffc0200082:	19a000ef          	jal	ra,ffffffffc020021c <print_kerninfo>

    // grade_backtrace();

    pmm_init(); // init physical memory management
ffffffffc0200086:	17f020ef          	jal	ra,ffffffffc0202a04 <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	131000ef          	jal	ra,ffffffffc02009ba <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	12f000ef          	jal	ra,ffffffffc02009bc <idt_init>

    vmm_init();  // init virtual memory management
ffffffffc0200092:	4c3030ef          	jal	ra,ffffffffc0203d54 <vmm_init>
    proc_init(); // init process table
ffffffffc0200096:	0f4050ef          	jal	ra,ffffffffc020518a <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009a:	4a0000ef          	jal	ra,ffffffffc020053a <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc020009e:	111000ef          	jal	ra,ffffffffc02009ae <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a2:	280050ef          	jal	ra,ffffffffc0205322 <cpu_idle>

ffffffffc02000a6 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02000a6:	715d                	addi	sp,sp,-80
ffffffffc02000a8:	e486                	sd	ra,72(sp)
ffffffffc02000aa:	e0a6                	sd	s1,64(sp)
ffffffffc02000ac:	fc4a                	sd	s2,56(sp)
ffffffffc02000ae:	f84e                	sd	s3,48(sp)
ffffffffc02000b0:	f452                	sd	s4,40(sp)
ffffffffc02000b2:	f056                	sd	s5,32(sp)
ffffffffc02000b4:	ec5a                	sd	s6,24(sp)
ffffffffc02000b6:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02000b8:	c901                	beqz	a0,ffffffffc02000c8 <readline+0x22>
ffffffffc02000ba:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02000bc:	00006517          	auipc	a0,0x6
ffffffffc02000c0:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0205ab8 <etext+0x2e>
ffffffffc02000c4:	0d0000ef          	jal	ra,ffffffffc0200194 <cprintf>
readline(const char *prompt) {
ffffffffc02000c8:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000ca:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000cc:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000ce:	4aa9                	li	s5,10
ffffffffc02000d0:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000d2:	000b3b97          	auipc	s7,0xb3
ffffffffc02000d6:	296b8b93          	addi	s7,s7,662 # ffffffffc02b3368 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000da:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000de:	12e000ef          	jal	ra,ffffffffc020020c <getchar>
        if (c < 0) {
ffffffffc02000e2:	00054a63          	bltz	a0,ffffffffc02000f6 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000e6:	00a95a63          	bge	s2,a0,ffffffffc02000fa <readline+0x54>
ffffffffc02000ea:	029a5263          	bge	s4,s1,ffffffffc020010e <readline+0x68>
        c = getchar();
ffffffffc02000ee:	11e000ef          	jal	ra,ffffffffc020020c <getchar>
        if (c < 0) {
ffffffffc02000f2:	fe055ae3          	bgez	a0,ffffffffc02000e6 <readline+0x40>
            return NULL;
ffffffffc02000f6:	4501                	li	a0,0
ffffffffc02000f8:	a091                	j	ffffffffc020013c <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02000fa:	03351463          	bne	a0,s3,ffffffffc0200122 <readline+0x7c>
ffffffffc02000fe:	e8a9                	bnez	s1,ffffffffc0200150 <readline+0xaa>
        c = getchar();
ffffffffc0200100:	10c000ef          	jal	ra,ffffffffc020020c <getchar>
        if (c < 0) {
ffffffffc0200104:	fe0549e3          	bltz	a0,ffffffffc02000f6 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200108:	fea959e3          	bge	s2,a0,ffffffffc02000fa <readline+0x54>
ffffffffc020010c:	4481                	li	s1,0
            cputchar(c);
ffffffffc020010e:	e42a                	sd	a0,8(sp)
ffffffffc0200110:	0ba000ef          	jal	ra,ffffffffc02001ca <cputchar>
            buf[i ++] = c;
ffffffffc0200114:	6522                	ld	a0,8(sp)
ffffffffc0200116:	009b87b3          	add	a5,s7,s1
ffffffffc020011a:	2485                	addiw	s1,s1,1
ffffffffc020011c:	00a78023          	sb	a0,0(a5)
ffffffffc0200120:	bf7d                	j	ffffffffc02000de <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0200122:	01550463          	beq	a0,s5,ffffffffc020012a <readline+0x84>
ffffffffc0200126:	fb651ce3          	bne	a0,s6,ffffffffc02000de <readline+0x38>
            cputchar(c);
ffffffffc020012a:	0a0000ef          	jal	ra,ffffffffc02001ca <cputchar>
            buf[i] = '\0';
ffffffffc020012e:	000b3517          	auipc	a0,0xb3
ffffffffc0200132:	23a50513          	addi	a0,a0,570 # ffffffffc02b3368 <buf>
ffffffffc0200136:	94aa                	add	s1,s1,a0
ffffffffc0200138:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020013c:	60a6                	ld	ra,72(sp)
ffffffffc020013e:	6486                	ld	s1,64(sp)
ffffffffc0200140:	7962                	ld	s2,56(sp)
ffffffffc0200142:	79c2                	ld	s3,48(sp)
ffffffffc0200144:	7a22                	ld	s4,40(sp)
ffffffffc0200146:	7a82                	ld	s5,32(sp)
ffffffffc0200148:	6b62                	ld	s6,24(sp)
ffffffffc020014a:	6bc2                	ld	s7,16(sp)
ffffffffc020014c:	6161                	addi	sp,sp,80
ffffffffc020014e:	8082                	ret
            cputchar(c);
ffffffffc0200150:	4521                	li	a0,8
ffffffffc0200152:	078000ef          	jal	ra,ffffffffc02001ca <cputchar>
            i --;
ffffffffc0200156:	34fd                	addiw	s1,s1,-1
ffffffffc0200158:	b759                	j	ffffffffc02000de <readline+0x38>

ffffffffc020015a <cputch>:
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt)
{
ffffffffc020015a:	1141                	addi	sp,sp,-16
ffffffffc020015c:	e022                	sd	s0,0(sp)
ffffffffc020015e:	e406                	sd	ra,8(sp)
ffffffffc0200160:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200162:	42c000ef          	jal	ra,ffffffffc020058e <cons_putc>
    (*cnt)++;
ffffffffc0200166:	401c                	lw	a5,0(s0)
}
ffffffffc0200168:	60a2                	ld	ra,8(sp)
    (*cnt)++;
ffffffffc020016a:	2785                	addiw	a5,a5,1
ffffffffc020016c:	c01c                	sw	a5,0(s0)
}
ffffffffc020016e:	6402                	ld	s0,0(sp)
ffffffffc0200170:	0141                	addi	sp,sp,16
ffffffffc0200172:	8082                	ret

ffffffffc0200174 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int vcprintf(const char *fmt, va_list ap)
{
ffffffffc0200174:	1101                	addi	sp,sp,-32
ffffffffc0200176:	862a                	mv	a2,a0
ffffffffc0200178:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc020017a:	00000517          	auipc	a0,0x0
ffffffffc020017e:	fe050513          	addi	a0,a0,-32 # ffffffffc020015a <cputch>
ffffffffc0200182:	006c                	addi	a1,sp,12
{
ffffffffc0200184:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200186:	c602                	sw	zero,12(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc0200188:	4b4050ef          	jal	ra,ffffffffc020563c <vprintfmt>
    return cnt;
}
ffffffffc020018c:	60e2                	ld	ra,24(sp)
ffffffffc020018e:	4532                	lw	a0,12(sp)
ffffffffc0200190:	6105                	addi	sp,sp,32
ffffffffc0200192:	8082                	ret

ffffffffc0200194 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...)
{
ffffffffc0200194:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200196:	02810313          	addi	t1,sp,40 # ffffffffc020a028 <boot_page_table_sv39+0x28>
{
ffffffffc020019a:	8e2a                	mv	t3,a0
ffffffffc020019c:	f42e                	sd	a1,40(sp)
ffffffffc020019e:	f832                	sd	a2,48(sp)
ffffffffc02001a0:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02001a2:	00000517          	auipc	a0,0x0
ffffffffc02001a6:	fb850513          	addi	a0,a0,-72 # ffffffffc020015a <cputch>
ffffffffc02001aa:	004c                	addi	a1,sp,4
ffffffffc02001ac:	869a                	mv	a3,t1
ffffffffc02001ae:	8672                	mv	a2,t3
{
ffffffffc02001b0:	ec06                	sd	ra,24(sp)
ffffffffc02001b2:	e0ba                	sd	a4,64(sp)
ffffffffc02001b4:	e4be                	sd	a5,72(sp)
ffffffffc02001b6:	e8c2                	sd	a6,80(sp)
ffffffffc02001b8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001ba:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001bc:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02001be:	47e050ef          	jal	ra,ffffffffc020563c <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001c2:	60e2                	ld	ra,24(sp)
ffffffffc02001c4:	4512                	lw	a0,4(sp)
ffffffffc02001c6:	6125                	addi	sp,sp,96
ffffffffc02001c8:	8082                	ret

ffffffffc02001ca <cputchar>:

/* cputchar - writes a single character to stdout */
void cputchar(int c)
{
    cons_putc(c);
ffffffffc02001ca:	a6d1                	j	ffffffffc020058e <cons_putc>

ffffffffc02001cc <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int cputs(const char *str)
{
ffffffffc02001cc:	1101                	addi	sp,sp,-32
ffffffffc02001ce:	e822                	sd	s0,16(sp)
ffffffffc02001d0:	ec06                	sd	ra,24(sp)
ffffffffc02001d2:	e426                	sd	s1,8(sp)
ffffffffc02001d4:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str++) != '\0')
ffffffffc02001d6:	00054503          	lbu	a0,0(a0)
ffffffffc02001da:	c51d                	beqz	a0,ffffffffc0200208 <cputs+0x3c>
ffffffffc02001dc:	0405                	addi	s0,s0,1
ffffffffc02001de:	4485                	li	s1,1
ffffffffc02001e0:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02001e2:	3ac000ef          	jal	ra,ffffffffc020058e <cons_putc>
    while ((c = *str++) != '\0')
ffffffffc02001e6:	00044503          	lbu	a0,0(s0)
ffffffffc02001ea:	008487bb          	addw	a5,s1,s0
ffffffffc02001ee:	0405                	addi	s0,s0,1
ffffffffc02001f0:	f96d                	bnez	a0,ffffffffc02001e2 <cputs+0x16>
    (*cnt)++;
ffffffffc02001f2:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001f6:	4529                	li	a0,10
ffffffffc02001f8:	396000ef          	jal	ra,ffffffffc020058e <cons_putc>
    {
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001fc:	60e2                	ld	ra,24(sp)
ffffffffc02001fe:	8522                	mv	a0,s0
ffffffffc0200200:	6442                	ld	s0,16(sp)
ffffffffc0200202:	64a2                	ld	s1,8(sp)
ffffffffc0200204:	6105                	addi	sp,sp,32
ffffffffc0200206:	8082                	ret
    while ((c = *str++) != '\0')
ffffffffc0200208:	4405                	li	s0,1
ffffffffc020020a:	b7f5                	j	ffffffffc02001f6 <cputs+0x2a>

ffffffffc020020c <getchar>:

/* getchar - reads a single non-zero character from stdin */
int getchar(void)
{
ffffffffc020020c:	1141                	addi	sp,sp,-16
ffffffffc020020e:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200210:	3b2000ef          	jal	ra,ffffffffc02005c2 <cons_getc>
ffffffffc0200214:	dd75                	beqz	a0,ffffffffc0200210 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200216:	60a2                	ld	ra,8(sp)
ffffffffc0200218:	0141                	addi	sp,sp,16
ffffffffc020021a:	8082                	ret

ffffffffc020021c <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void)
{
ffffffffc020021c:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020021e:	00006517          	auipc	a0,0x6
ffffffffc0200222:	8a250513          	addi	a0,a0,-1886 # ffffffffc0205ac0 <etext+0x36>
{
ffffffffc0200226:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200228:	f6dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020022c:	00000597          	auipc	a1,0x0
ffffffffc0200230:	e1e58593          	addi	a1,a1,-482 # ffffffffc020004a <kern_init>
ffffffffc0200234:	00006517          	auipc	a0,0x6
ffffffffc0200238:	8ac50513          	addi	a0,a0,-1876 # ffffffffc0205ae0 <etext+0x56>
ffffffffc020023c:	f59ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200240:	00006597          	auipc	a1,0x6
ffffffffc0200244:	84a58593          	addi	a1,a1,-1974 # ffffffffc0205a8a <etext>
ffffffffc0200248:	00006517          	auipc	a0,0x6
ffffffffc020024c:	8b850513          	addi	a0,a0,-1864 # ffffffffc0205b00 <etext+0x76>
ffffffffc0200250:	f45ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200254:	000b3597          	auipc	a1,0xb3
ffffffffc0200258:	11458593          	addi	a1,a1,276 # ffffffffc02b3368 <buf>
ffffffffc020025c:	00006517          	auipc	a0,0x6
ffffffffc0200260:	8c450513          	addi	a0,a0,-1852 # ffffffffc0205b20 <etext+0x96>
ffffffffc0200264:	f31ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200268:	000b7597          	auipc	a1,0xb7
ffffffffc020026c:	5ac58593          	addi	a1,a1,1452 # ffffffffc02b7814 <end>
ffffffffc0200270:	00006517          	auipc	a0,0x6
ffffffffc0200274:	8d050513          	addi	a0,a0,-1840 # ffffffffc0205b40 <etext+0xb6>
ffffffffc0200278:	f1dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020027c:	000b8597          	auipc	a1,0xb8
ffffffffc0200280:	99758593          	addi	a1,a1,-1641 # ffffffffc02b7c13 <end+0x3ff>
ffffffffc0200284:	00000797          	auipc	a5,0x0
ffffffffc0200288:	dc678793          	addi	a5,a5,-570 # ffffffffc020004a <kern_init>
ffffffffc020028c:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200290:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200294:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200296:	3ff5f593          	andi	a1,a1,1023
ffffffffc020029a:	95be                	add	a1,a1,a5
ffffffffc020029c:	85a9                	srai	a1,a1,0xa
ffffffffc020029e:	00006517          	auipc	a0,0x6
ffffffffc02002a2:	8c250513          	addi	a0,a0,-1854 # ffffffffc0205b60 <etext+0xd6>
}
ffffffffc02002a6:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002a8:	b5f5                	j	ffffffffc0200194 <cprintf>

ffffffffc02002aa <print_stackframe>:
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void)
{
ffffffffc02002aa:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002ac:	00006617          	auipc	a2,0x6
ffffffffc02002b0:	8e460613          	addi	a2,a2,-1820 # ffffffffc0205b90 <etext+0x106>
ffffffffc02002b4:	04f00593          	li	a1,79
ffffffffc02002b8:	00006517          	auipc	a0,0x6
ffffffffc02002bc:	8f050513          	addi	a0,a0,-1808 # ffffffffc0205ba8 <etext+0x11e>
{
ffffffffc02002c0:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002c2:	1cc000ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02002c6 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int mon_help(int argc, char **argv, struct trapframe *tf)
{
ffffffffc02002c6:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i++)
    {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002c8:	00006617          	auipc	a2,0x6
ffffffffc02002cc:	8f860613          	addi	a2,a2,-1800 # ffffffffc0205bc0 <etext+0x136>
ffffffffc02002d0:	00006597          	auipc	a1,0x6
ffffffffc02002d4:	91058593          	addi	a1,a1,-1776 # ffffffffc0205be0 <etext+0x156>
ffffffffc02002d8:	00006517          	auipc	a0,0x6
ffffffffc02002dc:	91050513          	addi	a0,a0,-1776 # ffffffffc0205be8 <etext+0x15e>
{
ffffffffc02002e0:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e2:	eb3ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02002e6:	00006617          	auipc	a2,0x6
ffffffffc02002ea:	91260613          	addi	a2,a2,-1774 # ffffffffc0205bf8 <etext+0x16e>
ffffffffc02002ee:	00006597          	auipc	a1,0x6
ffffffffc02002f2:	93258593          	addi	a1,a1,-1742 # ffffffffc0205c20 <etext+0x196>
ffffffffc02002f6:	00006517          	auipc	a0,0x6
ffffffffc02002fa:	8f250513          	addi	a0,a0,-1806 # ffffffffc0205be8 <etext+0x15e>
ffffffffc02002fe:	e97ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200302:	00006617          	auipc	a2,0x6
ffffffffc0200306:	92e60613          	addi	a2,a2,-1746 # ffffffffc0205c30 <etext+0x1a6>
ffffffffc020030a:	00006597          	auipc	a1,0x6
ffffffffc020030e:	94658593          	addi	a1,a1,-1722 # ffffffffc0205c50 <etext+0x1c6>
ffffffffc0200312:	00006517          	auipc	a0,0x6
ffffffffc0200316:	8d650513          	addi	a0,a0,-1834 # ffffffffc0205be8 <etext+0x15e>
ffffffffc020031a:	e7bff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    }
    return 0;
}
ffffffffc020031e:	60a2                	ld	ra,8(sp)
ffffffffc0200320:	4501                	li	a0,0
ffffffffc0200322:	0141                	addi	sp,sp,16
ffffffffc0200324:	8082                	ret

ffffffffc0200326 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int mon_kerninfo(int argc, char **argv, struct trapframe *tf)
{
ffffffffc0200326:	1141                	addi	sp,sp,-16
ffffffffc0200328:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020032a:	ef3ff0ef          	jal	ra,ffffffffc020021c <print_kerninfo>
    return 0;
}
ffffffffc020032e:	60a2                	ld	ra,8(sp)
ffffffffc0200330:	4501                	li	a0,0
ffffffffc0200332:	0141                	addi	sp,sp,16
ffffffffc0200334:	8082                	ret

ffffffffc0200336 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int mon_backtrace(int argc, char **argv, struct trapframe *tf)
{
ffffffffc0200336:	1141                	addi	sp,sp,-16
ffffffffc0200338:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020033a:	f71ff0ef          	jal	ra,ffffffffc02002aa <print_stackframe>
    return 0;
}
ffffffffc020033e:	60a2                	ld	ra,8(sp)
ffffffffc0200340:	4501                	li	a0,0
ffffffffc0200342:	0141                	addi	sp,sp,16
ffffffffc0200344:	8082                	ret

ffffffffc0200346 <kmonitor>:
{
ffffffffc0200346:	7115                	addi	sp,sp,-224
ffffffffc0200348:	ed5e                	sd	s7,152(sp)
ffffffffc020034a:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020034c:	00006517          	auipc	a0,0x6
ffffffffc0200350:	91450513          	addi	a0,a0,-1772 # ffffffffc0205c60 <etext+0x1d6>
{
ffffffffc0200354:	ed86                	sd	ra,216(sp)
ffffffffc0200356:	e9a2                	sd	s0,208(sp)
ffffffffc0200358:	e5a6                	sd	s1,200(sp)
ffffffffc020035a:	e1ca                	sd	s2,192(sp)
ffffffffc020035c:	fd4e                	sd	s3,184(sp)
ffffffffc020035e:	f952                	sd	s4,176(sp)
ffffffffc0200360:	f556                	sd	s5,168(sp)
ffffffffc0200362:	f15a                	sd	s6,160(sp)
ffffffffc0200364:	e962                	sd	s8,144(sp)
ffffffffc0200366:	e566                	sd	s9,136(sp)
ffffffffc0200368:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020036a:	e2bff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020036e:	00006517          	auipc	a0,0x6
ffffffffc0200372:	91a50513          	addi	a0,a0,-1766 # ffffffffc0205c88 <etext+0x1fe>
ffffffffc0200376:	e1fff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    if (tf != NULL)
ffffffffc020037a:	000b8563          	beqz	s7,ffffffffc0200384 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020037e:	855e                	mv	a0,s7
ffffffffc0200380:	025000ef          	jal	ra,ffffffffc0200ba4 <print_trapframe>
ffffffffc0200384:	00006c17          	auipc	s8,0x6
ffffffffc0200388:	974c0c13          	addi	s8,s8,-1676 # ffffffffc0205cf8 <commands>
        if ((buf = readline("K> ")) != NULL)
ffffffffc020038c:	00006917          	auipc	s2,0x6
ffffffffc0200390:	92490913          	addi	s2,s2,-1756 # ffffffffc0205cb0 <etext+0x226>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200394:	00006497          	auipc	s1,0x6
ffffffffc0200398:	92448493          	addi	s1,s1,-1756 # ffffffffc0205cb8 <etext+0x22e>
        if (argc == MAXARGS - 1)
ffffffffc020039c:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020039e:	00006b17          	auipc	s6,0x6
ffffffffc02003a2:	922b0b13          	addi	s6,s6,-1758 # ffffffffc0205cc0 <etext+0x236>
        argv[argc++] = buf;
ffffffffc02003a6:	00006a17          	auipc	s4,0x6
ffffffffc02003aa:	83aa0a13          	addi	s4,s4,-1990 # ffffffffc0205be0 <etext+0x156>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc02003ae:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL)
ffffffffc02003b0:	854a                	mv	a0,s2
ffffffffc02003b2:	cf5ff0ef          	jal	ra,ffffffffc02000a6 <readline>
ffffffffc02003b6:	842a                	mv	s0,a0
ffffffffc02003b8:	dd65                	beqz	a0,ffffffffc02003b0 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc02003ba:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003be:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc02003c0:	e1bd                	bnez	a1,ffffffffc0200426 <kmonitor+0xe0>
    if (argc == 0)
ffffffffc02003c2:	fe0c87e3          	beqz	s9,ffffffffc02003b0 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc02003c6:	6582                	ld	a1,0(sp)
ffffffffc02003c8:	00006d17          	auipc	s10,0x6
ffffffffc02003cc:	930d0d13          	addi	s10,s10,-1744 # ffffffffc0205cf8 <commands>
        argv[argc++] = buf;
ffffffffc02003d0:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc02003d2:	4401                	li	s0,0
ffffffffc02003d4:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc02003d6:	630050ef          	jal	ra,ffffffffc0205a06 <strcmp>
ffffffffc02003da:	c919                	beqz	a0,ffffffffc02003f0 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc02003dc:	2405                	addiw	s0,s0,1
ffffffffc02003de:	0b540063          	beq	s0,s5,ffffffffc020047e <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc02003e2:	000d3503          	ld	a0,0(s10)
ffffffffc02003e6:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc02003e8:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc02003ea:	61c050ef          	jal	ra,ffffffffc0205a06 <strcmp>
ffffffffc02003ee:	f57d                	bnez	a0,ffffffffc02003dc <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003f0:	00141793          	slli	a5,s0,0x1
ffffffffc02003f4:	97a2                	add	a5,a5,s0
ffffffffc02003f6:	078e                	slli	a5,a5,0x3
ffffffffc02003f8:	97e2                	add	a5,a5,s8
ffffffffc02003fa:	6b9c                	ld	a5,16(a5)
ffffffffc02003fc:	865e                	mv	a2,s7
ffffffffc02003fe:	002c                	addi	a1,sp,8
ffffffffc0200400:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200404:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0)
ffffffffc0200406:	fa0555e3          	bgez	a0,ffffffffc02003b0 <kmonitor+0x6a>
}
ffffffffc020040a:	60ee                	ld	ra,216(sp)
ffffffffc020040c:	644e                	ld	s0,208(sp)
ffffffffc020040e:	64ae                	ld	s1,200(sp)
ffffffffc0200410:	690e                	ld	s2,192(sp)
ffffffffc0200412:	79ea                	ld	s3,184(sp)
ffffffffc0200414:	7a4a                	ld	s4,176(sp)
ffffffffc0200416:	7aaa                	ld	s5,168(sp)
ffffffffc0200418:	7b0a                	ld	s6,160(sp)
ffffffffc020041a:	6bea                	ld	s7,152(sp)
ffffffffc020041c:	6c4a                	ld	s8,144(sp)
ffffffffc020041e:	6caa                	ld	s9,136(sp)
ffffffffc0200420:	6d0a                	ld	s10,128(sp)
ffffffffc0200422:	612d                	addi	sp,sp,224
ffffffffc0200424:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200426:	8526                	mv	a0,s1
ffffffffc0200428:	622050ef          	jal	ra,ffffffffc0205a4a <strchr>
ffffffffc020042c:	c901                	beqz	a0,ffffffffc020043c <kmonitor+0xf6>
ffffffffc020042e:	00144583          	lbu	a1,1(s0)
            *buf++ = '\0';
ffffffffc0200432:	00040023          	sb	zero,0(s0)
ffffffffc0200436:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200438:	d5c9                	beqz	a1,ffffffffc02003c2 <kmonitor+0x7c>
ffffffffc020043a:	b7f5                	j	ffffffffc0200426 <kmonitor+0xe0>
        if (*buf == '\0')
ffffffffc020043c:	00044783          	lbu	a5,0(s0)
ffffffffc0200440:	d3c9                	beqz	a5,ffffffffc02003c2 <kmonitor+0x7c>
        if (argc == MAXARGS - 1)
ffffffffc0200442:	033c8963          	beq	s9,s3,ffffffffc0200474 <kmonitor+0x12e>
        argv[argc++] = buf;
ffffffffc0200446:	003c9793          	slli	a5,s9,0x3
ffffffffc020044a:	0118                	addi	a4,sp,128
ffffffffc020044c:	97ba                	add	a5,a5,a4
ffffffffc020044e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc0200452:	00044583          	lbu	a1,0(s0)
        argv[argc++] = buf;
ffffffffc0200456:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc0200458:	e591                	bnez	a1,ffffffffc0200464 <kmonitor+0x11e>
ffffffffc020045a:	b7b5                	j	ffffffffc02003c6 <kmonitor+0x80>
ffffffffc020045c:	00144583          	lbu	a1,1(s0)
            buf++;
ffffffffc0200460:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc0200462:	d1a5                	beqz	a1,ffffffffc02003c2 <kmonitor+0x7c>
ffffffffc0200464:	8526                	mv	a0,s1
ffffffffc0200466:	5e4050ef          	jal	ra,ffffffffc0205a4a <strchr>
ffffffffc020046a:	d96d                	beqz	a0,ffffffffc020045c <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc020046c:	00044583          	lbu	a1,0(s0)
ffffffffc0200470:	d9a9                	beqz	a1,ffffffffc02003c2 <kmonitor+0x7c>
ffffffffc0200472:	bf55                	j	ffffffffc0200426 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200474:	45c1                	li	a1,16
ffffffffc0200476:	855a                	mv	a0,s6
ffffffffc0200478:	d1dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc020047c:	b7e9                	j	ffffffffc0200446 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020047e:	6582                	ld	a1,0(sp)
ffffffffc0200480:	00006517          	auipc	a0,0x6
ffffffffc0200484:	86050513          	addi	a0,a0,-1952 # ffffffffc0205ce0 <etext+0x256>
ffffffffc0200488:	d0dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    return 0;
ffffffffc020048c:	b715                	j	ffffffffc02003b0 <kmonitor+0x6a>

ffffffffc020048e <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void __panic(const char *file, int line, const char *fmt, ...)
{
    if (is_panic)
ffffffffc020048e:	000b7317          	auipc	t1,0xb7
ffffffffc0200492:	30230313          	addi	t1,t1,770 # ffffffffc02b7790 <is_panic>
ffffffffc0200496:	00033e03          	ld	t3,0(t1)
{
ffffffffc020049a:	715d                	addi	sp,sp,-80
ffffffffc020049c:	ec06                	sd	ra,24(sp)
ffffffffc020049e:	e822                	sd	s0,16(sp)
ffffffffc02004a0:	f436                	sd	a3,40(sp)
ffffffffc02004a2:	f83a                	sd	a4,48(sp)
ffffffffc02004a4:	fc3e                	sd	a5,56(sp)
ffffffffc02004a6:	e0c2                	sd	a6,64(sp)
ffffffffc02004a8:	e4c6                	sd	a7,72(sp)
    if (is_panic)
ffffffffc02004aa:	020e1a63          	bnez	t3,ffffffffc02004de <__panic+0x50>
    {
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02004ae:	4785                	li	a5,1
ffffffffc02004b0:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004b4:	8432                	mv	s0,a2
ffffffffc02004b6:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b8:	862e                	mv	a2,a1
ffffffffc02004ba:	85aa                	mv	a1,a0
ffffffffc02004bc:	00006517          	auipc	a0,0x6
ffffffffc02004c0:	88450513          	addi	a0,a0,-1916 # ffffffffc0205d40 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02004c4:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004c6:	ccfff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004ca:	65a2                	ld	a1,8(sp)
ffffffffc02004cc:	8522                	mv	a0,s0
ffffffffc02004ce:	ca7ff0ef          	jal	ra,ffffffffc0200174 <vcprintf>
    cprintf("\n");
ffffffffc02004d2:	00007517          	auipc	a0,0x7
ffffffffc02004d6:	a1650513          	addi	a0,a0,-1514 # ffffffffc0206ee8 <default_pmm_manager+0x578>
ffffffffc02004da:	cbbff0ef          	jal	ra,ffffffffc0200194 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004de:	4501                	li	a0,0
ffffffffc02004e0:	4581                	li	a1,0
ffffffffc02004e2:	4601                	li	a2,0
ffffffffc02004e4:	48a1                	li	a7,8
ffffffffc02004e6:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004ea:	4ca000ef          	jal	ra,ffffffffc02009b4 <intr_disable>
    while (1)
    {
        kmonitor(NULL);
ffffffffc02004ee:	4501                	li	a0,0
ffffffffc02004f0:	e57ff0ef          	jal	ra,ffffffffc0200346 <kmonitor>
    while (1)
ffffffffc02004f4:	bfed                	j	ffffffffc02004ee <__panic+0x60>

ffffffffc02004f6 <__warn>:
    }
}

/* __warn - like panic, but don't */
void __warn(const char *file, int line, const char *fmt, ...)
{
ffffffffc02004f6:	715d                	addi	sp,sp,-80
ffffffffc02004f8:	832e                	mv	t1,a1
ffffffffc02004fa:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004fc:	85aa                	mv	a1,a0
{
ffffffffc02004fe:	8432                	mv	s0,a2
ffffffffc0200500:	fc3e                	sd	a5,56(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200502:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc0200504:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200506:	00006517          	auipc	a0,0x6
ffffffffc020050a:	85a50513          	addi	a0,a0,-1958 # ffffffffc0205d60 <commands+0x68>
{
ffffffffc020050e:	ec06                	sd	ra,24(sp)
ffffffffc0200510:	f436                	sd	a3,40(sp)
ffffffffc0200512:	f83a                	sd	a4,48(sp)
ffffffffc0200514:	e0c2                	sd	a6,64(sp)
ffffffffc0200516:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200518:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020051a:	c7bff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020051e:	65a2                	ld	a1,8(sp)
ffffffffc0200520:	8522                	mv	a0,s0
ffffffffc0200522:	c53ff0ef          	jal	ra,ffffffffc0200174 <vcprintf>
    cprintf("\n");
ffffffffc0200526:	00007517          	auipc	a0,0x7
ffffffffc020052a:	9c250513          	addi	a0,a0,-1598 # ffffffffc0206ee8 <default_pmm_manager+0x578>
ffffffffc020052e:	c67ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    va_end(ap);
}
ffffffffc0200532:	60e2                	ld	ra,24(sp)
ffffffffc0200534:	6442                	ld	s0,16(sp)
ffffffffc0200536:	6161                	addi	sp,sp,80
ffffffffc0200538:	8082                	ret

ffffffffc020053a <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020053a:	67e1                	lui	a5,0x18
ffffffffc020053c:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_cowtest_out_size+0xb600>
ffffffffc0200540:	000b7717          	auipc	a4,0xb7
ffffffffc0200544:	26f73023          	sd	a5,608(a4) # ffffffffc02b77a0 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200548:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020054c:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020054e:	953e                	add	a0,a0,a5
ffffffffc0200550:	4601                	li	a2,0
ffffffffc0200552:	4881                	li	a7,0
ffffffffc0200554:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200558:	02000793          	li	a5,32
ffffffffc020055c:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200560:	00006517          	auipc	a0,0x6
ffffffffc0200564:	82050513          	addi	a0,a0,-2016 # ffffffffc0205d80 <commands+0x88>
    ticks = 0;
ffffffffc0200568:	000b7797          	auipc	a5,0xb7
ffffffffc020056c:	2207b823          	sd	zero,560(a5) # ffffffffc02b7798 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200570:	b115                	j	ffffffffc0200194 <cprintf>

ffffffffc0200572 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200572:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200576:	000b7797          	auipc	a5,0xb7
ffffffffc020057a:	22a7b783          	ld	a5,554(a5) # ffffffffc02b77a0 <timebase>
ffffffffc020057e:	953e                	add	a0,a0,a5
ffffffffc0200580:	4581                	li	a1,0
ffffffffc0200582:	4601                	li	a2,0
ffffffffc0200584:	4881                	li	a7,0
ffffffffc0200586:	00000073          	ecall
ffffffffc020058a:	8082                	ret

ffffffffc020058c <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020058c:	8082                	ret

ffffffffc020058e <cons_putc>:
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void)
{
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020058e:	100027f3          	csrr	a5,sstatus
ffffffffc0200592:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200594:	0ff57513          	zext.b	a0,a0
ffffffffc0200598:	e799                	bnez	a5,ffffffffc02005a6 <cons_putc+0x18>
ffffffffc020059a:	4581                	li	a1,0
ffffffffc020059c:	4601                	li	a2,0
ffffffffc020059e:	4885                	li	a7,1
ffffffffc02005a0:	00000073          	ecall
    return 0;
}

static inline void __intr_restore(bool flag)
{
    if (flag)
ffffffffc02005a4:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005a6:	1101                	addi	sp,sp,-32
ffffffffc02005a8:	ec06                	sd	ra,24(sp)
ffffffffc02005aa:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005ac:	408000ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc02005b0:	6522                	ld	a0,8(sp)
ffffffffc02005b2:	4581                	li	a1,0
ffffffffc02005b4:	4601                	li	a2,0
ffffffffc02005b6:	4885                	li	a7,1
ffffffffc02005b8:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005bc:	60e2                	ld	ra,24(sp)
ffffffffc02005be:	6105                	addi	sp,sp,32
    {
        intr_enable();
ffffffffc02005c0:	a6fd                	j	ffffffffc02009ae <intr_enable>

ffffffffc02005c2 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02005c2:	100027f3          	csrr	a5,sstatus
ffffffffc02005c6:	8b89                	andi	a5,a5,2
ffffffffc02005c8:	eb89                	bnez	a5,ffffffffc02005da <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005ca:	4501                	li	a0,0
ffffffffc02005cc:	4581                	li	a1,0
ffffffffc02005ce:	4601                	li	a2,0
ffffffffc02005d0:	4889                	li	a7,2
ffffffffc02005d2:	00000073          	ecall
ffffffffc02005d6:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005d8:	8082                	ret
int cons_getc(void) {
ffffffffc02005da:	1101                	addi	sp,sp,-32
ffffffffc02005dc:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005de:	3d6000ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc02005e2:	4501                	li	a0,0
ffffffffc02005e4:	4581                	li	a1,0
ffffffffc02005e6:	4601                	li	a2,0
ffffffffc02005e8:	4889                	li	a7,2
ffffffffc02005ea:	00000073          	ecall
ffffffffc02005ee:	2501                	sext.w	a0,a0
ffffffffc02005f0:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005f2:	3bc000ef          	jal	ra,ffffffffc02009ae <intr_enable>
}
ffffffffc02005f6:	60e2                	ld	ra,24(sp)
ffffffffc02005f8:	6522                	ld	a0,8(sp)
ffffffffc02005fa:	6105                	addi	sp,sp,32
ffffffffc02005fc:	8082                	ret

ffffffffc02005fe <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc02005fe:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc0200600:	00005517          	auipc	a0,0x5
ffffffffc0200604:	7a050513          	addi	a0,a0,1952 # ffffffffc0205da0 <commands+0xa8>
void dtb_init(void) {
ffffffffc0200608:	fc86                	sd	ra,120(sp)
ffffffffc020060a:	f8a2                	sd	s0,112(sp)
ffffffffc020060c:	e8d2                	sd	s4,80(sp)
ffffffffc020060e:	f4a6                	sd	s1,104(sp)
ffffffffc0200610:	f0ca                	sd	s2,96(sp)
ffffffffc0200612:	ecce                	sd	s3,88(sp)
ffffffffc0200614:	e4d6                	sd	s5,72(sp)
ffffffffc0200616:	e0da                	sd	s6,64(sp)
ffffffffc0200618:	fc5e                	sd	s7,56(sp)
ffffffffc020061a:	f862                	sd	s8,48(sp)
ffffffffc020061c:	f466                	sd	s9,40(sp)
ffffffffc020061e:	f06a                	sd	s10,32(sp)
ffffffffc0200620:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc0200622:	b73ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200626:	0000b597          	auipc	a1,0xb
ffffffffc020062a:	9da5b583          	ld	a1,-1574(a1) # ffffffffc020b000 <boot_hartid>
ffffffffc020062e:	00005517          	auipc	a0,0x5
ffffffffc0200632:	78250513          	addi	a0,a0,1922 # ffffffffc0205db0 <commands+0xb8>
ffffffffc0200636:	b5fff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020063a:	0000b417          	auipc	s0,0xb
ffffffffc020063e:	9ce40413          	addi	s0,s0,-1586 # ffffffffc020b008 <boot_dtb>
ffffffffc0200642:	600c                	ld	a1,0(s0)
ffffffffc0200644:	00005517          	auipc	a0,0x5
ffffffffc0200648:	77c50513          	addi	a0,a0,1916 # ffffffffc0205dc0 <commands+0xc8>
ffffffffc020064c:	b49ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200650:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200654:	00005517          	auipc	a0,0x5
ffffffffc0200658:	78450513          	addi	a0,a0,1924 # ffffffffc0205dd8 <commands+0xe0>
    if (boot_dtb == 0) {
ffffffffc020065c:	120a0463          	beqz	s4,ffffffffc0200784 <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200660:	57f5                	li	a5,-3
ffffffffc0200662:	07fa                	slli	a5,a5,0x1e
ffffffffc0200664:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc0200668:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020066a:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020066e:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200670:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200674:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200678:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020067c:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200680:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200684:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200686:	8ec9                	or	a3,a3,a0
ffffffffc0200688:	0087979b          	slliw	a5,a5,0x8
ffffffffc020068c:	1b7d                	addi	s6,s6,-1
ffffffffc020068e:	0167f7b3          	and	a5,a5,s6
ffffffffc0200692:	8dd5                	or	a1,a1,a3
ffffffffc0200694:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc0200696:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020069a:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc020069c:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfe286d9>
ffffffffc02006a0:	10f59163          	bne	a1,a5,ffffffffc02007a2 <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc02006a4:	471c                	lw	a5,8(a4)
ffffffffc02006a6:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc02006a8:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006aa:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02006ae:	0086d51b          	srliw	a0,a3,0x8
ffffffffc02006b2:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006b6:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006ba:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006be:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006c2:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006c6:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006ca:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006ce:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006d2:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006d4:	01146433          	or	s0,s0,a7
ffffffffc02006d8:	0086969b          	slliw	a3,a3,0x8
ffffffffc02006dc:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006e0:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006e2:	0087979b          	slliw	a5,a5,0x8
ffffffffc02006e6:	8c49                	or	s0,s0,a0
ffffffffc02006e8:	0166f6b3          	and	a3,a3,s6
ffffffffc02006ec:	00ca6a33          	or	s4,s4,a2
ffffffffc02006f0:	0167f7b3          	and	a5,a5,s6
ffffffffc02006f4:	8c55                	or	s0,s0,a3
ffffffffc02006f6:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02006fa:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02006fc:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02006fe:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200700:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200704:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200706:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200708:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc020070c:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020070e:	00005917          	auipc	s2,0x5
ffffffffc0200712:	71a90913          	addi	s2,s2,1818 # ffffffffc0205e28 <commands+0x130>
ffffffffc0200716:	49bd                	li	s3,15
        switch (token) {
ffffffffc0200718:	4d91                	li	s11,4
ffffffffc020071a:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020071c:	00005497          	auipc	s1,0x5
ffffffffc0200720:	70448493          	addi	s1,s1,1796 # ffffffffc0205e20 <commands+0x128>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200724:	000a2703          	lw	a4,0(s4)
ffffffffc0200728:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020072c:	0087569b          	srliw	a3,a4,0x8
ffffffffc0200730:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200734:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200738:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020073c:	0107571b          	srliw	a4,a4,0x10
ffffffffc0200740:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200742:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200746:	0087171b          	slliw	a4,a4,0x8
ffffffffc020074a:	8fd5                	or	a5,a5,a3
ffffffffc020074c:	00eb7733          	and	a4,s6,a4
ffffffffc0200750:	8fd9                	or	a5,a5,a4
ffffffffc0200752:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc0200754:	09778c63          	beq	a5,s7,ffffffffc02007ec <dtb_init+0x1ee>
ffffffffc0200758:	00fbea63          	bltu	s7,a5,ffffffffc020076c <dtb_init+0x16e>
ffffffffc020075c:	07a78663          	beq	a5,s10,ffffffffc02007c8 <dtb_init+0x1ca>
ffffffffc0200760:	4709                	li	a4,2
ffffffffc0200762:	00e79763          	bne	a5,a4,ffffffffc0200770 <dtb_init+0x172>
ffffffffc0200766:	4c81                	li	s9,0
ffffffffc0200768:	8a56                	mv	s4,s5
ffffffffc020076a:	bf6d                	j	ffffffffc0200724 <dtb_init+0x126>
ffffffffc020076c:	ffb78ee3          	beq	a5,s11,ffffffffc0200768 <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc0200770:	00005517          	auipc	a0,0x5
ffffffffc0200774:	73050513          	addi	a0,a0,1840 # ffffffffc0205ea0 <commands+0x1a8>
ffffffffc0200778:	a1dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc020077c:	00005517          	auipc	a0,0x5
ffffffffc0200780:	75c50513          	addi	a0,a0,1884 # ffffffffc0205ed8 <commands+0x1e0>
}
ffffffffc0200784:	7446                	ld	s0,112(sp)
ffffffffc0200786:	70e6                	ld	ra,120(sp)
ffffffffc0200788:	74a6                	ld	s1,104(sp)
ffffffffc020078a:	7906                	ld	s2,96(sp)
ffffffffc020078c:	69e6                	ld	s3,88(sp)
ffffffffc020078e:	6a46                	ld	s4,80(sp)
ffffffffc0200790:	6aa6                	ld	s5,72(sp)
ffffffffc0200792:	6b06                	ld	s6,64(sp)
ffffffffc0200794:	7be2                	ld	s7,56(sp)
ffffffffc0200796:	7c42                	ld	s8,48(sp)
ffffffffc0200798:	7ca2                	ld	s9,40(sp)
ffffffffc020079a:	7d02                	ld	s10,32(sp)
ffffffffc020079c:	6de2                	ld	s11,24(sp)
ffffffffc020079e:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc02007a0:	bad5                	j	ffffffffc0200194 <cprintf>
}
ffffffffc02007a2:	7446                	ld	s0,112(sp)
ffffffffc02007a4:	70e6                	ld	ra,120(sp)
ffffffffc02007a6:	74a6                	ld	s1,104(sp)
ffffffffc02007a8:	7906                	ld	s2,96(sp)
ffffffffc02007aa:	69e6                	ld	s3,88(sp)
ffffffffc02007ac:	6a46                	ld	s4,80(sp)
ffffffffc02007ae:	6aa6                	ld	s5,72(sp)
ffffffffc02007b0:	6b06                	ld	s6,64(sp)
ffffffffc02007b2:	7be2                	ld	s7,56(sp)
ffffffffc02007b4:	7c42                	ld	s8,48(sp)
ffffffffc02007b6:	7ca2                	ld	s9,40(sp)
ffffffffc02007b8:	7d02                	ld	s10,32(sp)
ffffffffc02007ba:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02007bc:	00005517          	auipc	a0,0x5
ffffffffc02007c0:	63c50513          	addi	a0,a0,1596 # ffffffffc0205df8 <commands+0x100>
}
ffffffffc02007c4:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02007c6:	b2f9                	j	ffffffffc0200194 <cprintf>
                int name_len = strlen(name);
ffffffffc02007c8:	8556                	mv	a0,s5
ffffffffc02007ca:	1f4050ef          	jal	ra,ffffffffc02059be <strlen>
ffffffffc02007ce:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02007d0:	4619                	li	a2,6
ffffffffc02007d2:	85a6                	mv	a1,s1
ffffffffc02007d4:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02007d6:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02007d8:	24c050ef          	jal	ra,ffffffffc0205a24 <strncmp>
ffffffffc02007dc:	e111                	bnez	a0,ffffffffc02007e0 <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc02007de:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02007e0:	0a91                	addi	s5,s5,4
ffffffffc02007e2:	9ad2                	add	s5,s5,s4
ffffffffc02007e4:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc02007e8:	8a56                	mv	s4,s5
ffffffffc02007ea:	bf2d                	j	ffffffffc0200724 <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc02007ec:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc02007f0:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007f4:	0087d71b          	srliw	a4,a5,0x8
ffffffffc02007f8:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007fc:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200800:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200804:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200808:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020080c:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200810:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200814:	00eaeab3          	or	s5,s5,a4
ffffffffc0200818:	00fb77b3          	and	a5,s6,a5
ffffffffc020081c:	00faeab3          	or	s5,s5,a5
ffffffffc0200820:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200822:	000c9c63          	bnez	s9,ffffffffc020083a <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc0200826:	1a82                	slli	s5,s5,0x20
ffffffffc0200828:	00368793          	addi	a5,a3,3
ffffffffc020082c:	020ada93          	srli	s5,s5,0x20
ffffffffc0200830:	9abe                	add	s5,s5,a5
ffffffffc0200832:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc0200836:	8a56                	mv	s4,s5
ffffffffc0200838:	b5f5                	j	ffffffffc0200724 <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc020083a:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020083e:	85ca                	mv	a1,s2
ffffffffc0200840:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200842:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200846:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020084a:	0187971b          	slliw	a4,a5,0x18
ffffffffc020084e:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200852:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200856:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200858:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020085c:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200860:	8d59                	or	a0,a0,a4
ffffffffc0200862:	00fb77b3          	and	a5,s6,a5
ffffffffc0200866:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc0200868:	1502                	slli	a0,a0,0x20
ffffffffc020086a:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020086c:	9522                	add	a0,a0,s0
ffffffffc020086e:	198050ef          	jal	ra,ffffffffc0205a06 <strcmp>
ffffffffc0200872:	66a2                	ld	a3,8(sp)
ffffffffc0200874:	f94d                	bnez	a0,ffffffffc0200826 <dtb_init+0x228>
ffffffffc0200876:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200826 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc020087a:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc020087e:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200882:	00005517          	auipc	a0,0x5
ffffffffc0200886:	5ae50513          	addi	a0,a0,1454 # ffffffffc0205e30 <commands+0x138>
           fdt32_to_cpu(x >> 32);
ffffffffc020088a:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020088e:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc0200892:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200896:	0187de1b          	srliw	t3,a5,0x18
ffffffffc020089a:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020089e:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02008a2:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02008a6:	0187d693          	srli	a3,a5,0x18
ffffffffc02008aa:	01861f1b          	slliw	t5,a2,0x18
ffffffffc02008ae:	0087579b          	srliw	a5,a4,0x8
ffffffffc02008b2:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02008b6:	0106561b          	srliw	a2,a2,0x10
ffffffffc02008ba:	010f6f33          	or	t5,t5,a6
ffffffffc02008be:	0187529b          	srliw	t0,a4,0x18
ffffffffc02008c2:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02008c6:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02008ca:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02008ce:	0186f6b3          	and	a3,a3,s8
ffffffffc02008d2:	01859e1b          	slliw	t3,a1,0x18
ffffffffc02008d6:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02008da:	0107581b          	srliw	a6,a4,0x10
ffffffffc02008de:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02008e2:	8361                	srli	a4,a4,0x18
ffffffffc02008e4:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02008e8:	0105d59b          	srliw	a1,a1,0x10
ffffffffc02008ec:	01e6e6b3          	or	a3,a3,t5
ffffffffc02008f0:	00cb7633          	and	a2,s6,a2
ffffffffc02008f4:	0088181b          	slliw	a6,a6,0x8
ffffffffc02008f8:	0085959b          	slliw	a1,a1,0x8
ffffffffc02008fc:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200900:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200904:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200908:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020090c:	0088989b          	slliw	a7,a7,0x8
ffffffffc0200910:	011b78b3          	and	a7,s6,a7
ffffffffc0200914:	005eeeb3          	or	t4,t4,t0
ffffffffc0200918:	00c6e733          	or	a4,a3,a2
ffffffffc020091c:	006c6c33          	or	s8,s8,t1
ffffffffc0200920:	010b76b3          	and	a3,s6,a6
ffffffffc0200924:	00bb7b33          	and	s6,s6,a1
ffffffffc0200928:	01d7e7b3          	or	a5,a5,t4
ffffffffc020092c:	016c6b33          	or	s6,s8,s6
ffffffffc0200930:	01146433          	or	s0,s0,a7
ffffffffc0200934:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc0200936:	1702                	slli	a4,a4,0x20
ffffffffc0200938:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020093a:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc020093c:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020093e:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200940:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200944:	0167eb33          	or	s6,a5,s6
ffffffffc0200948:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc020094a:	84bff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc020094e:	85a2                	mv	a1,s0
ffffffffc0200950:	00005517          	auipc	a0,0x5
ffffffffc0200954:	50050513          	addi	a0,a0,1280 # ffffffffc0205e50 <commands+0x158>
ffffffffc0200958:	83dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020095c:	014b5613          	srli	a2,s6,0x14
ffffffffc0200960:	85da                	mv	a1,s6
ffffffffc0200962:	00005517          	auipc	a0,0x5
ffffffffc0200966:	50650513          	addi	a0,a0,1286 # ffffffffc0205e68 <commands+0x170>
ffffffffc020096a:	82bff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc020096e:	008b05b3          	add	a1,s6,s0
ffffffffc0200972:	15fd                	addi	a1,a1,-1
ffffffffc0200974:	00005517          	auipc	a0,0x5
ffffffffc0200978:	51450513          	addi	a0,a0,1300 # ffffffffc0205e88 <commands+0x190>
ffffffffc020097c:	819ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("DTB init completed\n");
ffffffffc0200980:	00005517          	auipc	a0,0x5
ffffffffc0200984:	55850513          	addi	a0,a0,1368 # ffffffffc0205ed8 <commands+0x1e0>
        memory_base = mem_base;
ffffffffc0200988:	000b7797          	auipc	a5,0xb7
ffffffffc020098c:	e287b023          	sd	s0,-480(a5) # ffffffffc02b77a8 <memory_base>
        memory_size = mem_size;
ffffffffc0200990:	000b7797          	auipc	a5,0xb7
ffffffffc0200994:	e367b023          	sd	s6,-480(a5) # ffffffffc02b77b0 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc0200998:	b3f5                	j	ffffffffc0200784 <dtb_init+0x186>

ffffffffc020099a <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc020099a:	000b7517          	auipc	a0,0xb7
ffffffffc020099e:	e0e53503          	ld	a0,-498(a0) # ffffffffc02b77a8 <memory_base>
ffffffffc02009a2:	8082                	ret

ffffffffc02009a4 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc02009a4:	000b7517          	auipc	a0,0xb7
ffffffffc02009a8:	e0c53503          	ld	a0,-500(a0) # ffffffffc02b77b0 <memory_size>
ffffffffc02009ac:	8082                	ret

ffffffffc02009ae <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02009ae:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02009b2:	8082                	ret

ffffffffc02009b4 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02009b4:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02009b8:	8082                	ret

ffffffffc02009ba <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02009ba:	8082                	ret

ffffffffc02009bc <idt_init>:
void idt_init(void)
{
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc02009bc:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc02009c0:	00000797          	auipc	a5,0x0
ffffffffc02009c4:	5c478793          	addi	a5,a5,1476 # ffffffffc0200f84 <__alltraps>
ffffffffc02009c8:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc02009cc:	000407b7          	lui	a5,0x40
ffffffffc02009d0:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc02009d4:	8082                	ret

ffffffffc02009d6 <print_regs>:
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr)
{
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009d6:	610c                	ld	a1,0(a0)
{
ffffffffc02009d8:	1141                	addi	sp,sp,-16
ffffffffc02009da:	e022                	sd	s0,0(sp)
ffffffffc02009dc:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009de:	00005517          	auipc	a0,0x5
ffffffffc02009e2:	51250513          	addi	a0,a0,1298 # ffffffffc0205ef0 <commands+0x1f8>
{
ffffffffc02009e6:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009e8:	facff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02009ec:	640c                	ld	a1,8(s0)
ffffffffc02009ee:	00005517          	auipc	a0,0x5
ffffffffc02009f2:	51a50513          	addi	a0,a0,1306 # ffffffffc0205f08 <commands+0x210>
ffffffffc02009f6:	f9eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02009fa:	680c                	ld	a1,16(s0)
ffffffffc02009fc:	00005517          	auipc	a0,0x5
ffffffffc0200a00:	52450513          	addi	a0,a0,1316 # ffffffffc0205f20 <commands+0x228>
ffffffffc0200a04:	f90ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200a08:	6c0c                	ld	a1,24(s0)
ffffffffc0200a0a:	00005517          	auipc	a0,0x5
ffffffffc0200a0e:	52e50513          	addi	a0,a0,1326 # ffffffffc0205f38 <commands+0x240>
ffffffffc0200a12:	f82ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200a16:	700c                	ld	a1,32(s0)
ffffffffc0200a18:	00005517          	auipc	a0,0x5
ffffffffc0200a1c:	53850513          	addi	a0,a0,1336 # ffffffffc0205f50 <commands+0x258>
ffffffffc0200a20:	f74ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200a24:	740c                	ld	a1,40(s0)
ffffffffc0200a26:	00005517          	auipc	a0,0x5
ffffffffc0200a2a:	54250513          	addi	a0,a0,1346 # ffffffffc0205f68 <commands+0x270>
ffffffffc0200a2e:	f66ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc0200a32:	780c                	ld	a1,48(s0)
ffffffffc0200a34:	00005517          	auipc	a0,0x5
ffffffffc0200a38:	54c50513          	addi	a0,a0,1356 # ffffffffc0205f80 <commands+0x288>
ffffffffc0200a3c:	f58ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200a40:	7c0c                	ld	a1,56(s0)
ffffffffc0200a42:	00005517          	auipc	a0,0x5
ffffffffc0200a46:	55650513          	addi	a0,a0,1366 # ffffffffc0205f98 <commands+0x2a0>
ffffffffc0200a4a:	f4aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200a4e:	602c                	ld	a1,64(s0)
ffffffffc0200a50:	00005517          	auipc	a0,0x5
ffffffffc0200a54:	56050513          	addi	a0,a0,1376 # ffffffffc0205fb0 <commands+0x2b8>
ffffffffc0200a58:	f3cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200a5c:	642c                	ld	a1,72(s0)
ffffffffc0200a5e:	00005517          	auipc	a0,0x5
ffffffffc0200a62:	56a50513          	addi	a0,a0,1386 # ffffffffc0205fc8 <commands+0x2d0>
ffffffffc0200a66:	f2eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200a6a:	682c                	ld	a1,80(s0)
ffffffffc0200a6c:	00005517          	auipc	a0,0x5
ffffffffc0200a70:	57450513          	addi	a0,a0,1396 # ffffffffc0205fe0 <commands+0x2e8>
ffffffffc0200a74:	f20ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200a78:	6c2c                	ld	a1,88(s0)
ffffffffc0200a7a:	00005517          	auipc	a0,0x5
ffffffffc0200a7e:	57e50513          	addi	a0,a0,1406 # ffffffffc0205ff8 <commands+0x300>
ffffffffc0200a82:	f12ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200a86:	702c                	ld	a1,96(s0)
ffffffffc0200a88:	00005517          	auipc	a0,0x5
ffffffffc0200a8c:	58850513          	addi	a0,a0,1416 # ffffffffc0206010 <commands+0x318>
ffffffffc0200a90:	f04ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200a94:	742c                	ld	a1,104(s0)
ffffffffc0200a96:	00005517          	auipc	a0,0x5
ffffffffc0200a9a:	59250513          	addi	a0,a0,1426 # ffffffffc0206028 <commands+0x330>
ffffffffc0200a9e:	ef6ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200aa2:	782c                	ld	a1,112(s0)
ffffffffc0200aa4:	00005517          	auipc	a0,0x5
ffffffffc0200aa8:	59c50513          	addi	a0,a0,1436 # ffffffffc0206040 <commands+0x348>
ffffffffc0200aac:	ee8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200ab0:	7c2c                	ld	a1,120(s0)
ffffffffc0200ab2:	00005517          	auipc	a0,0x5
ffffffffc0200ab6:	5a650513          	addi	a0,a0,1446 # ffffffffc0206058 <commands+0x360>
ffffffffc0200aba:	edaff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200abe:	604c                	ld	a1,128(s0)
ffffffffc0200ac0:	00005517          	auipc	a0,0x5
ffffffffc0200ac4:	5b050513          	addi	a0,a0,1456 # ffffffffc0206070 <commands+0x378>
ffffffffc0200ac8:	eccff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200acc:	644c                	ld	a1,136(s0)
ffffffffc0200ace:	00005517          	auipc	a0,0x5
ffffffffc0200ad2:	5ba50513          	addi	a0,a0,1466 # ffffffffc0206088 <commands+0x390>
ffffffffc0200ad6:	ebeff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200ada:	684c                	ld	a1,144(s0)
ffffffffc0200adc:	00005517          	auipc	a0,0x5
ffffffffc0200ae0:	5c450513          	addi	a0,a0,1476 # ffffffffc02060a0 <commands+0x3a8>
ffffffffc0200ae4:	eb0ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200ae8:	6c4c                	ld	a1,152(s0)
ffffffffc0200aea:	00005517          	auipc	a0,0x5
ffffffffc0200aee:	5ce50513          	addi	a0,a0,1486 # ffffffffc02060b8 <commands+0x3c0>
ffffffffc0200af2:	ea2ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200af6:	704c                	ld	a1,160(s0)
ffffffffc0200af8:	00005517          	auipc	a0,0x5
ffffffffc0200afc:	5d850513          	addi	a0,a0,1496 # ffffffffc02060d0 <commands+0x3d8>
ffffffffc0200b00:	e94ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200b04:	744c                	ld	a1,168(s0)
ffffffffc0200b06:	00005517          	auipc	a0,0x5
ffffffffc0200b0a:	5e250513          	addi	a0,a0,1506 # ffffffffc02060e8 <commands+0x3f0>
ffffffffc0200b0e:	e86ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200b12:	784c                	ld	a1,176(s0)
ffffffffc0200b14:	00005517          	auipc	a0,0x5
ffffffffc0200b18:	5ec50513          	addi	a0,a0,1516 # ffffffffc0206100 <commands+0x408>
ffffffffc0200b1c:	e78ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200b20:	7c4c                	ld	a1,184(s0)
ffffffffc0200b22:	00005517          	auipc	a0,0x5
ffffffffc0200b26:	5f650513          	addi	a0,a0,1526 # ffffffffc0206118 <commands+0x420>
ffffffffc0200b2a:	e6aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200b2e:	606c                	ld	a1,192(s0)
ffffffffc0200b30:	00005517          	auipc	a0,0x5
ffffffffc0200b34:	60050513          	addi	a0,a0,1536 # ffffffffc0206130 <commands+0x438>
ffffffffc0200b38:	e5cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200b3c:	646c                	ld	a1,200(s0)
ffffffffc0200b3e:	00005517          	auipc	a0,0x5
ffffffffc0200b42:	60a50513          	addi	a0,a0,1546 # ffffffffc0206148 <commands+0x450>
ffffffffc0200b46:	e4eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200b4a:	686c                	ld	a1,208(s0)
ffffffffc0200b4c:	00005517          	auipc	a0,0x5
ffffffffc0200b50:	61450513          	addi	a0,a0,1556 # ffffffffc0206160 <commands+0x468>
ffffffffc0200b54:	e40ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200b58:	6c6c                	ld	a1,216(s0)
ffffffffc0200b5a:	00005517          	auipc	a0,0x5
ffffffffc0200b5e:	61e50513          	addi	a0,a0,1566 # ffffffffc0206178 <commands+0x480>
ffffffffc0200b62:	e32ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200b66:	706c                	ld	a1,224(s0)
ffffffffc0200b68:	00005517          	auipc	a0,0x5
ffffffffc0200b6c:	62850513          	addi	a0,a0,1576 # ffffffffc0206190 <commands+0x498>
ffffffffc0200b70:	e24ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200b74:	746c                	ld	a1,232(s0)
ffffffffc0200b76:	00005517          	auipc	a0,0x5
ffffffffc0200b7a:	63250513          	addi	a0,a0,1586 # ffffffffc02061a8 <commands+0x4b0>
ffffffffc0200b7e:	e16ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200b82:	786c                	ld	a1,240(s0)
ffffffffc0200b84:	00005517          	auipc	a0,0x5
ffffffffc0200b88:	63c50513          	addi	a0,a0,1596 # ffffffffc02061c0 <commands+0x4c8>
ffffffffc0200b8c:	e08ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b90:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200b92:	6402                	ld	s0,0(sp)
ffffffffc0200b94:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b96:	00005517          	auipc	a0,0x5
ffffffffc0200b9a:	64250513          	addi	a0,a0,1602 # ffffffffc02061d8 <commands+0x4e0>
}
ffffffffc0200b9e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200ba0:	df4ff06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0200ba4 <print_trapframe>:
{
ffffffffc0200ba4:	1141                	addi	sp,sp,-16
ffffffffc0200ba6:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200ba8:	85aa                	mv	a1,a0
{
ffffffffc0200baa:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200bac:	00005517          	auipc	a0,0x5
ffffffffc0200bb0:	64450513          	addi	a0,a0,1604 # ffffffffc02061f0 <commands+0x4f8>
{
ffffffffc0200bb4:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200bb6:	ddeff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200bba:	8522                	mv	a0,s0
ffffffffc0200bbc:	e1bff0ef          	jal	ra,ffffffffc02009d6 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200bc0:	10043583          	ld	a1,256(s0)
ffffffffc0200bc4:	00005517          	auipc	a0,0x5
ffffffffc0200bc8:	64450513          	addi	a0,a0,1604 # ffffffffc0206208 <commands+0x510>
ffffffffc0200bcc:	dc8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200bd0:	10843583          	ld	a1,264(s0)
ffffffffc0200bd4:	00005517          	auipc	a0,0x5
ffffffffc0200bd8:	64c50513          	addi	a0,a0,1612 # ffffffffc0206220 <commands+0x528>
ffffffffc0200bdc:	db8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200be0:	11043583          	ld	a1,272(s0)
ffffffffc0200be4:	00005517          	auipc	a0,0x5
ffffffffc0200be8:	65450513          	addi	a0,a0,1620 # ffffffffc0206238 <commands+0x540>
ffffffffc0200bec:	da8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bf0:	11843583          	ld	a1,280(s0)
}
ffffffffc0200bf4:	6402                	ld	s0,0(sp)
ffffffffc0200bf6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bf8:	00005517          	auipc	a0,0x5
ffffffffc0200bfc:	65050513          	addi	a0,a0,1616 # ffffffffc0206248 <commands+0x550>
}
ffffffffc0200c00:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200c02:	d92ff06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0200c06 <interrupt_handler>:

extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf)
{
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200c06:	11853783          	ld	a5,280(a0)
ffffffffc0200c0a:	472d                	li	a4,11
ffffffffc0200c0c:	0786                	slli	a5,a5,0x1
ffffffffc0200c0e:	8385                	srli	a5,a5,0x1
ffffffffc0200c10:	06f76f63          	bltu	a4,a5,ffffffffc0200c8e <interrupt_handler+0x88>
ffffffffc0200c14:	00005717          	auipc	a4,0x5
ffffffffc0200c18:	6fc70713          	addi	a4,a4,1788 # ffffffffc0206310 <commands+0x618>
ffffffffc0200c1c:	078a                	slli	a5,a5,0x2
ffffffffc0200c1e:	97ba                	add	a5,a5,a4
ffffffffc0200c20:	439c                	lw	a5,0(a5)
ffffffffc0200c22:	97ba                	add	a5,a5,a4
ffffffffc0200c24:	8782                	jr	a5
        break;
    case IRQ_H_SOFT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_SOFT:
        cprintf("Machine software interrupt\n");
ffffffffc0200c26:	00005517          	auipc	a0,0x5
ffffffffc0200c2a:	69a50513          	addi	a0,a0,1690 # ffffffffc02062c0 <commands+0x5c8>
ffffffffc0200c2e:	d66ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200c32:	00005517          	auipc	a0,0x5
ffffffffc0200c36:	66e50513          	addi	a0,a0,1646 # ffffffffc02062a0 <commands+0x5a8>
ffffffffc0200c3a:	d5aff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200c3e:	00005517          	auipc	a0,0x5
ffffffffc0200c42:	62250513          	addi	a0,a0,1570 # ffffffffc0206260 <commands+0x568>
ffffffffc0200c46:	d4eff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200c4a:	00005517          	auipc	a0,0x5
ffffffffc0200c4e:	63650513          	addi	a0,a0,1590 # ffffffffc0206280 <commands+0x588>
ffffffffc0200c52:	d42ff06f          	j	ffffffffc0200194 <cprintf>
{
ffffffffc0200c56:	1141                	addi	sp,sp,-16
ffffffffc0200c58:	e022                	sd	s0,0(sp)
ffffffffc0200c5a:	e406                	sd	ra,8(sp)
ffffffffc0200c5c:	842a                	mv	s0,a0
        /* 时间片轮转： 
        *(1) 设置下一次时钟中断（clock_set_next_event）
        *(2) ticks 计数器自增
        *(3) 每 TICK_NUM 次中断（如 100 次），进行判断当前是否有进程正在运行，如果有则标记该进程需要被重新调度（current->need_resched）
        */
        clock_set_next_event();//发生这次时钟中断的时候，我们要设置下一次时钟中断
ffffffffc0200c5e:	915ff0ef          	jal	ra,ffffffffc0200572 <clock_set_next_event>
        if (++ticks % TICK_NUM == 0) {
ffffffffc0200c62:	000b7697          	auipc	a3,0xb7
ffffffffc0200c66:	b3668693          	addi	a3,a3,-1226 # ffffffffc02b7798 <ticks>
ffffffffc0200c6a:	629c                	ld	a5,0(a3)
ffffffffc0200c6c:	06400713          	li	a4,100
ffffffffc0200c70:	0785                	addi	a5,a5,1
ffffffffc0200c72:	02e7f733          	remu	a4,a5,a4
ffffffffc0200c76:	e29c                	sd	a5,0(a3)
ffffffffc0200c78:	cf01                	beqz	a4,ffffffffc0200c90 <interrupt_handler+0x8a>
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200c7a:	60a2                	ld	ra,8(sp)
ffffffffc0200c7c:	6402                	ld	s0,0(sp)
ffffffffc0200c7e:	0141                	addi	sp,sp,16
ffffffffc0200c80:	8082                	ret
        cprintf("Supervisor external interrupt\n");
ffffffffc0200c82:	00005517          	auipc	a0,0x5
ffffffffc0200c86:	66e50513          	addi	a0,a0,1646 # ffffffffc02062f0 <commands+0x5f8>
ffffffffc0200c8a:	d0aff06f          	j	ffffffffc0200194 <cprintf>
        print_trapframe(tf);
ffffffffc0200c8e:	bf19                	j	ffffffffc0200ba4 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200c90:	06400593          	li	a1,100
ffffffffc0200c94:	00005517          	auipc	a0,0x5
ffffffffc0200c98:	64c50513          	addi	a0,a0,1612 # ffffffffc02062e0 <commands+0x5e8>
ffffffffc0200c9c:	cf8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
            num++; // 打印次数加一
ffffffffc0200ca0:	000b7717          	auipc	a4,0xb7
ffffffffc0200ca4:	b1870713          	addi	a4,a4,-1256 # ffffffffc02b77b8 <num>
ffffffffc0200ca8:	431c                	lw	a5,0(a4)
            if (num == 10) {
ffffffffc0200caa:	46a9                	li	a3,10
            num++; // 打印次数加一
ffffffffc0200cac:	0017861b          	addiw	a2,a5,1
ffffffffc0200cb0:	c310                	sw	a2,0(a4)
            if (num == 10) {
ffffffffc0200cb2:	00d61863          	bne	a2,a3,ffffffffc0200cc2 <interrupt_handler+0xbc>
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200cb6:	4501                	li	a0,0
ffffffffc0200cb8:	4581                	li	a1,0
ffffffffc0200cba:	4601                	li	a2,0
ffffffffc0200cbc:	48a1                	li	a7,8
ffffffffc0200cbe:	00000073          	ecall
            if(current != NULL && (tf->status & SSTATUS_SPP) == 0) {
ffffffffc0200cc2:	000b7717          	auipc	a4,0xb7
ffffffffc0200cc6:	b3673703          	ld	a4,-1226(a4) # ffffffffc02b77f8 <current>
ffffffffc0200cca:	db45                	beqz	a4,ffffffffc0200c7a <interrupt_handler+0x74>
ffffffffc0200ccc:	10043783          	ld	a5,256(s0)
ffffffffc0200cd0:	1007f793          	andi	a5,a5,256
ffffffffc0200cd4:	f3dd                	bnez	a5,ffffffffc0200c7a <interrupt_handler+0x74>
                current->need_resched = 1;
ffffffffc0200cd6:	4785                	li	a5,1
ffffffffc0200cd8:	ef1c                	sd	a5,24(a4)
ffffffffc0200cda:	b745                	j	ffffffffc0200c7a <interrupt_handler+0x74>

ffffffffc0200cdc <exception_handler>:
void kernel_execve_ret(struct trapframe *tf, uintptr_t kstacktop);
void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
ffffffffc0200cdc:	11853783          	ld	a5,280(a0)
{
ffffffffc0200ce0:	7179                	addi	sp,sp,-48
ffffffffc0200ce2:	f022                	sd	s0,32(sp)
ffffffffc0200ce4:	f406                	sd	ra,40(sp)
ffffffffc0200ce6:	ec26                	sd	s1,24(sp)
ffffffffc0200ce8:	e84a                	sd	s2,16(sp)
ffffffffc0200cea:	e44e                	sd	s3,8(sp)
ffffffffc0200cec:	473d                	li	a4,15
ffffffffc0200cee:	842a                	mv	s0,a0
ffffffffc0200cf0:	16f76463          	bltu	a4,a5,ffffffffc0200e58 <exception_handler+0x17c>
ffffffffc0200cf4:	00006717          	auipc	a4,0x6
ffffffffc0200cf8:	87c70713          	addi	a4,a4,-1924 # ffffffffc0206570 <commands+0x878>
ffffffffc0200cfc:	078a                	slli	a5,a5,0x2
ffffffffc0200cfe:	97ba                	add	a5,a5,a4
ffffffffc0200d00:	439c                	lw	a5,0(a5)
ffffffffc0200d02:	97ba                	add	a5,a5,a4
ffffffffc0200d04:	8782                	jr	a5
        // cprintf("Environment call from U-mode\n");
        tf->epc += 4;
        syscall();
        break;
    case CAUSE_SUPERVISOR_ECALL:
        cprintf("Environment call from S-mode\n");
ffffffffc0200d06:	00005517          	auipc	a0,0x5
ffffffffc0200d0a:	72250513          	addi	a0,a0,1826 # ffffffffc0206428 <commands+0x730>
ffffffffc0200d0e:	c86ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        tf->epc += 4;
ffffffffc0200d12:	10843783          	ld	a5,264(s0)
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200d16:	70a2                	ld	ra,40(sp)
ffffffffc0200d18:	64e2                	ld	s1,24(sp)
        tf->epc += 4;
ffffffffc0200d1a:	0791                	addi	a5,a5,4
ffffffffc0200d1c:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200d20:	7402                	ld	s0,32(sp)
ffffffffc0200d22:	6942                	ld	s2,16(sp)
ffffffffc0200d24:	69a2                	ld	s3,8(sp)
ffffffffc0200d26:	6145                	addi	sp,sp,48
        syscall();
ffffffffc0200d28:	7ea0406f          	j	ffffffffc0205512 <syscall>
        cprintf("Environment call from H-mode\n");
ffffffffc0200d2c:	00005517          	auipc	a0,0x5
ffffffffc0200d30:	71c50513          	addi	a0,a0,1820 # ffffffffc0206448 <commands+0x750>
}
ffffffffc0200d34:	7402                	ld	s0,32(sp)
ffffffffc0200d36:	70a2                	ld	ra,40(sp)
ffffffffc0200d38:	64e2                	ld	s1,24(sp)
ffffffffc0200d3a:	6942                	ld	s2,16(sp)
ffffffffc0200d3c:	69a2                	ld	s3,8(sp)
ffffffffc0200d3e:	6145                	addi	sp,sp,48
        cprintf("Instruction access fault\n");
ffffffffc0200d40:	c54ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Environment call from M-mode\n");
ffffffffc0200d44:	00005517          	auipc	a0,0x5
ffffffffc0200d48:	72450513          	addi	a0,a0,1828 # ffffffffc0206468 <commands+0x770>
ffffffffc0200d4c:	b7e5                	j	ffffffffc0200d34 <exception_handler+0x58>
                tf->epc, tf->tval, current ? current->pid : -1);
ffffffffc0200d4e:	000b7797          	auipc	a5,0xb7
ffffffffc0200d52:	aaa7b783          	ld	a5,-1366(a5) # ffffffffc02b77f8 <current>
        cprintf("Instruction page fault at epc=0x%lx, tval=0x%lx, pid=%d\n",
ffffffffc0200d56:	10853583          	ld	a1,264(a0)
ffffffffc0200d5a:	11053603          	ld	a2,272(a0)
ffffffffc0200d5e:	56fd                	li	a3,-1
ffffffffc0200d60:	c391                	beqz	a5,ffffffffc0200d64 <exception_handler+0x88>
ffffffffc0200d62:	43d4                	lw	a3,4(a5)
ffffffffc0200d64:	00005517          	auipc	a0,0x5
ffffffffc0200d68:	72450513          	addi	a0,a0,1828 # ffffffffc0206488 <commands+0x790>
}
ffffffffc0200d6c:	7402                	ld	s0,32(sp)
ffffffffc0200d6e:	70a2                	ld	ra,40(sp)
ffffffffc0200d70:	64e2                	ld	s1,24(sp)
ffffffffc0200d72:	6942                	ld	s2,16(sp)
ffffffffc0200d74:	69a2                	ld	s3,8(sp)
ffffffffc0200d76:	6145                	addi	sp,sp,48
        cprintf("Load page fault at epc=0x%lx, tval=0x%lx, pid=%d\n",
ffffffffc0200d78:	c1cff06f          	j	ffffffffc0200194 <cprintf>
                tf->epc, tf->tval, current ? current->pid : -1);
ffffffffc0200d7c:	000b7797          	auipc	a5,0xb7
ffffffffc0200d80:	a7c7b783          	ld	a5,-1412(a5) # ffffffffc02b77f8 <current>
        cprintf("Load page fault at epc=0x%lx, tval=0x%lx, pid=%d\n",
ffffffffc0200d84:	10853583          	ld	a1,264(a0)
ffffffffc0200d88:	11053603          	ld	a2,272(a0)
ffffffffc0200d8c:	56fd                	li	a3,-1
ffffffffc0200d8e:	c391                	beqz	a5,ffffffffc0200d92 <exception_handler+0xb6>
ffffffffc0200d90:	43d4                	lw	a3,4(a5)
ffffffffc0200d92:	00005517          	auipc	a0,0x5
ffffffffc0200d96:	73650513          	addi	a0,a0,1846 # ffffffffc02064c8 <commands+0x7d0>
ffffffffc0200d9a:	bfc9                	j	ffffffffc0200d6c <exception_handler+0x90>
        if (current != NULL && current->mm != NULL) {
ffffffffc0200d9c:	000b7497          	auipc	s1,0xb7
ffffffffc0200da0:	a5c48493          	addi	s1,s1,-1444 # ffffffffc02b77f8 <current>
ffffffffc0200da4:	609c                	ld	a5,0(s1)
        cprintf("Instruction page fault at epc=0x%lx, tval=0x%lx, pid=%d\n",
ffffffffc0200da6:	11053903          	ld	s2,272(a0)
        if (current != NULL && current->mm != NULL) {
ffffffffc0200daa:	cbf9                	beqz	a5,ffffffffc0200e80 <exception_handler+0x1a4>
ffffffffc0200dac:	0287b983          	ld	s3,40(a5)
ffffffffc0200db0:	0c098c63          	beqz	s3,ffffffffc0200e88 <exception_handler+0x1ac>
            struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0200db4:	85ca                	mv	a1,s2
ffffffffc0200db6:	854e                	mv	a0,s3
ffffffffc0200db8:	47b020ef          	jal	ra,ffffffffc0203a32 <find_vma>
            if (vma != NULL && (vma->vm_flags & VM_WRITE)) {
ffffffffc0200dbc:	c509                	beqz	a0,ffffffffc0200dc6 <exception_handler+0xea>
ffffffffc0200dbe:	4d1c                	lw	a5,24(a0)
ffffffffc0200dc0:	8b89                	andi	a5,a5,2
ffffffffc0200dc2:	0e079c63          	bnez	a5,ffffffffc0200eba <exception_handler+0x1de>
                tf->epc, tf->tval, current ? current->pid : -1);
ffffffffc0200dc6:	609c                	ld	a5,0(s1)
        cprintf("Store/AMO page fault at epc=0x%lx, tval=0x%lx, pid=%d\n",
ffffffffc0200dc8:	10843583          	ld	a1,264(s0)
ffffffffc0200dcc:	11043903          	ld	s2,272(s0)
ffffffffc0200dd0:	12078363          	beqz	a5,ffffffffc0200ef6 <exception_handler+0x21a>
ffffffffc0200dd4:	43d4                	lw	a3,4(a5)
ffffffffc0200dd6:	864a                	mv	a2,s2
ffffffffc0200dd8:	00005517          	auipc	a0,0x5
ffffffffc0200ddc:	76050513          	addi	a0,a0,1888 # ffffffffc0206538 <commands+0x840>
ffffffffc0200de0:	bb4ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        if (current != NULL) {
ffffffffc0200de4:	609c                	ld	a5,0(s1)
ffffffffc0200de6:	c785                	beqz	a5,ffffffffc0200e0e <exception_handler+0x132>
}
ffffffffc0200de8:	7402                	ld	s0,32(sp)
ffffffffc0200dea:	70a2                	ld	ra,40(sp)
ffffffffc0200dec:	64e2                	ld	s1,24(sp)
ffffffffc0200dee:	6942                	ld	s2,16(sp)
ffffffffc0200df0:	69a2                	ld	s3,8(sp)
            do_exit(-E_KILLED);
ffffffffc0200df2:	555d                	li	a0,-9
}
ffffffffc0200df4:	6145                	addi	sp,sp,48
            do_exit(-E_KILLED);
ffffffffc0200df6:	1910306f          	j	ffffffffc0204786 <do_exit>
        cprintf("Breakpoint\n");
ffffffffc0200dfa:	00005517          	auipc	a0,0x5
ffffffffc0200dfe:	59e50513          	addi	a0,a0,1438 # ffffffffc0206398 <commands+0x6a0>
ffffffffc0200e02:	b92ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        if (tf->gpr.a7 == 10)
ffffffffc0200e06:	6458                	ld	a4,136(s0)
ffffffffc0200e08:	47a9                	li	a5,10
ffffffffc0200e0a:	08f70263          	beq	a4,a5,ffffffffc0200e8e <exception_handler+0x1b2>
}
ffffffffc0200e0e:	70a2                	ld	ra,40(sp)
ffffffffc0200e10:	7402                	ld	s0,32(sp)
ffffffffc0200e12:	64e2                	ld	s1,24(sp)
ffffffffc0200e14:	6942                	ld	s2,16(sp)
ffffffffc0200e16:	69a2                	ld	s3,8(sp)
ffffffffc0200e18:	6145                	addi	sp,sp,48
ffffffffc0200e1a:	8082                	ret
        cprintf("Load address misaligned\n");
ffffffffc0200e1c:	00005517          	auipc	a0,0x5
ffffffffc0200e20:	58c50513          	addi	a0,a0,1420 # ffffffffc02063a8 <commands+0x6b0>
ffffffffc0200e24:	bf01                	j	ffffffffc0200d34 <exception_handler+0x58>
        cprintf("Load access fault\n");
ffffffffc0200e26:	00005517          	auipc	a0,0x5
ffffffffc0200e2a:	5a250513          	addi	a0,a0,1442 # ffffffffc02063c8 <commands+0x6d0>
ffffffffc0200e2e:	b719                	j	ffffffffc0200d34 <exception_handler+0x58>
        cprintf("Store/AMO access fault\n");
ffffffffc0200e30:	00005517          	auipc	a0,0x5
ffffffffc0200e34:	5e050513          	addi	a0,a0,1504 # ffffffffc0206410 <commands+0x718>
ffffffffc0200e38:	bdf5                	j	ffffffffc0200d34 <exception_handler+0x58>
        cprintf("Instruction access fault\n");
ffffffffc0200e3a:	00005517          	auipc	a0,0x5
ffffffffc0200e3e:	52650513          	addi	a0,a0,1318 # ffffffffc0206360 <commands+0x668>
ffffffffc0200e42:	bdcd                	j	ffffffffc0200d34 <exception_handler+0x58>
        cprintf("Illegal instruction\n");
ffffffffc0200e44:	00005517          	auipc	a0,0x5
ffffffffc0200e48:	53c50513          	addi	a0,a0,1340 # ffffffffc0206380 <commands+0x688>
ffffffffc0200e4c:	b5e5                	j	ffffffffc0200d34 <exception_handler+0x58>
        cprintf("Instruction address misaligned\n");
ffffffffc0200e4e:	00005517          	auipc	a0,0x5
ffffffffc0200e52:	4f250513          	addi	a0,a0,1266 # ffffffffc0206340 <commands+0x648>
ffffffffc0200e56:	bdf9                	j	ffffffffc0200d34 <exception_handler+0x58>
        print_trapframe(tf);
ffffffffc0200e58:	8522                	mv	a0,s0
}
ffffffffc0200e5a:	7402                	ld	s0,32(sp)
ffffffffc0200e5c:	70a2                	ld	ra,40(sp)
ffffffffc0200e5e:	64e2                	ld	s1,24(sp)
ffffffffc0200e60:	6942                	ld	s2,16(sp)
ffffffffc0200e62:	69a2                	ld	s3,8(sp)
ffffffffc0200e64:	6145                	addi	sp,sp,48
        print_trapframe(tf);
ffffffffc0200e66:	bb3d                	j	ffffffffc0200ba4 <print_trapframe>
        panic("AMO address misaligned\n");
ffffffffc0200e68:	00005617          	auipc	a2,0x5
ffffffffc0200e6c:	57860613          	addi	a2,a2,1400 # ffffffffc02063e0 <commands+0x6e8>
ffffffffc0200e70:	0c100593          	li	a1,193
ffffffffc0200e74:	00005517          	auipc	a0,0x5
ffffffffc0200e78:	58450513          	addi	a0,a0,1412 # ffffffffc02063f8 <commands+0x700>
ffffffffc0200e7c:	e12ff0ef          	jal	ra,ffffffffc020048e <__panic>
        cprintf("Store/AMO page fault at epc=0x%lx, tval=0x%lx, pid=%d\n",
ffffffffc0200e80:	10853583          	ld	a1,264(a0)
ffffffffc0200e84:	56fd                	li	a3,-1
ffffffffc0200e86:	bf81                	j	ffffffffc0200dd6 <exception_handler+0xfa>
ffffffffc0200e88:	10853583          	ld	a1,264(a0)
ffffffffc0200e8c:	b7a1                	j	ffffffffc0200dd4 <exception_handler+0xf8>
            tf->epc += 4;
ffffffffc0200e8e:	10843783          	ld	a5,264(s0)
ffffffffc0200e92:	0791                	addi	a5,a5,4
ffffffffc0200e94:	10f43423          	sd	a5,264(s0)
            syscall();
ffffffffc0200e98:	67a040ef          	jal	ra,ffffffffc0205512 <syscall>
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200e9c:	000b7797          	auipc	a5,0xb7
ffffffffc0200ea0:	95c7b783          	ld	a5,-1700(a5) # ffffffffc02b77f8 <current>
ffffffffc0200ea4:	6b9c                	ld	a5,16(a5)
ffffffffc0200ea6:	8522                	mv	a0,s0
}
ffffffffc0200ea8:	7402                	ld	s0,32(sp)
ffffffffc0200eaa:	70a2                	ld	ra,40(sp)
ffffffffc0200eac:	64e2                	ld	s1,24(sp)
ffffffffc0200eae:	6942                	ld	s2,16(sp)
ffffffffc0200eb0:	69a2                	ld	s3,8(sp)
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200eb2:	6589                	lui	a1,0x2
ffffffffc0200eb4:	95be                	add	a1,a1,a5
}
ffffffffc0200eb6:	6145                	addi	sp,sp,48
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200eb8:	aa69                	j	ffffffffc0201052 <kernel_execve_ret>
                pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0200eba:	0189b503          	ld	a0,24(s3)
ffffffffc0200ebe:	4601                	li	a2,0
ffffffffc0200ec0:	85ca                	mv	a1,s2
ffffffffc0200ec2:	1ae010ef          	jal	ra,ffffffffc0202070 <get_pte>
                if (ptep != NULL && (*ptep & PTE_V) && (*ptep & PTE_COW)) {
ffffffffc0200ec6:	f00500e3          	beqz	a0,ffffffffc0200dc6 <exception_handler+0xea>
ffffffffc0200eca:	611c                	ld	a5,0(a0)
ffffffffc0200ecc:	10100713          	li	a4,257
ffffffffc0200ed0:	1017f793          	andi	a5,a5,257
ffffffffc0200ed4:	eee799e3          	bne	a5,a4,ffffffffc0200dc6 <exception_handler+0xea>
                    int ret = do_cow_fault(mm, addr, ptep);
ffffffffc0200ed8:	862a                	mv	a2,a0
ffffffffc0200eda:	85ca                	mv	a1,s2
ffffffffc0200edc:	854e                	mv	a0,s3
ffffffffc0200ede:	083010ef          	jal	ra,ffffffffc0202760 <do_cow_fault>
ffffffffc0200ee2:	862a                	mv	a2,a0
                    if (ret == 0) {
ffffffffc0200ee4:	d50d                	beqz	a0,ffffffffc0200e0e <exception_handler+0x132>
                    cprintf("COW fault handling failed at addr=0x%lx, ret=%d\n", addr, ret);
ffffffffc0200ee6:	85ca                	mv	a1,s2
ffffffffc0200ee8:	00005517          	auipc	a0,0x5
ffffffffc0200eec:	61850513          	addi	a0,a0,1560 # ffffffffc0206500 <commands+0x808>
ffffffffc0200ef0:	aa4ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200ef4:	bdc9                	j	ffffffffc0200dc6 <exception_handler+0xea>
        cprintf("Store/AMO page fault at epc=0x%lx, tval=0x%lx, pid=%d\n",
ffffffffc0200ef6:	56fd                	li	a3,-1
ffffffffc0200ef8:	bdf9                	j	ffffffffc0200dd6 <exception_handler+0xfa>

ffffffffc0200efa <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf)
{
ffffffffc0200efa:	1101                	addi	sp,sp,-32
ffffffffc0200efc:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
    //    cputs("some trap");
    if (current == NULL)
ffffffffc0200efe:	000b7417          	auipc	s0,0xb7
ffffffffc0200f02:	8fa40413          	addi	s0,s0,-1798 # ffffffffc02b77f8 <current>
ffffffffc0200f06:	6018                	ld	a4,0(s0)
{
ffffffffc0200f08:	ec06                	sd	ra,24(sp)
ffffffffc0200f0a:	e426                	sd	s1,8(sp)
ffffffffc0200f0c:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0)
ffffffffc0200f0e:	11853683          	ld	a3,280(a0)
    if (current == NULL)
ffffffffc0200f12:	cf1d                	beqz	a4,ffffffffc0200f50 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200f14:	10053483          	ld	s1,256(a0)
    {
        trap_dispatch(tf);
    }
    else
    {
        struct trapframe *otf = current->tf;
ffffffffc0200f18:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200f1c:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200f1e:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0)
ffffffffc0200f22:	0206c463          	bltz	a3,ffffffffc0200f4a <trap+0x50>
        exception_handler(tf);
ffffffffc0200f26:	db7ff0ef          	jal	ra,ffffffffc0200cdc <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200f2a:	601c                	ld	a5,0(s0)
ffffffffc0200f2c:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel)
ffffffffc0200f30:	e499                	bnez	s1,ffffffffc0200f3e <trap+0x44>
        {
            if (current->flags & PF_EXITING)
ffffffffc0200f32:	0b07a703          	lw	a4,176(a5)
ffffffffc0200f36:	8b05                	andi	a4,a4,1
ffffffffc0200f38:	e329                	bnez	a4,ffffffffc0200f7a <trap+0x80>
            {
                do_exit(-E_KILLED);
            }
            if (current->need_resched)
ffffffffc0200f3a:	6f9c                	ld	a5,24(a5)
ffffffffc0200f3c:	eb85                	bnez	a5,ffffffffc0200f6c <trap+0x72>
            {
                schedule();
            }
        }
    }
}
ffffffffc0200f3e:	60e2                	ld	ra,24(sp)
ffffffffc0200f40:	6442                	ld	s0,16(sp)
ffffffffc0200f42:	64a2                	ld	s1,8(sp)
ffffffffc0200f44:	6902                	ld	s2,0(sp)
ffffffffc0200f46:	6105                	addi	sp,sp,32
ffffffffc0200f48:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200f4a:	cbdff0ef          	jal	ra,ffffffffc0200c06 <interrupt_handler>
ffffffffc0200f4e:	bff1                	j	ffffffffc0200f2a <trap+0x30>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200f50:	0006c863          	bltz	a3,ffffffffc0200f60 <trap+0x66>
}
ffffffffc0200f54:	6442                	ld	s0,16(sp)
ffffffffc0200f56:	60e2                	ld	ra,24(sp)
ffffffffc0200f58:	64a2                	ld	s1,8(sp)
ffffffffc0200f5a:	6902                	ld	s2,0(sp)
ffffffffc0200f5c:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200f5e:	bbbd                	j	ffffffffc0200cdc <exception_handler>
}
ffffffffc0200f60:	6442                	ld	s0,16(sp)
ffffffffc0200f62:	60e2                	ld	ra,24(sp)
ffffffffc0200f64:	64a2                	ld	s1,8(sp)
ffffffffc0200f66:	6902                	ld	s2,0(sp)
ffffffffc0200f68:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200f6a:	b971                	j	ffffffffc0200c06 <interrupt_handler>
}
ffffffffc0200f6c:	6442                	ld	s0,16(sp)
ffffffffc0200f6e:	60e2                	ld	ra,24(sp)
ffffffffc0200f70:	64a2                	ld	s1,8(sp)
ffffffffc0200f72:	6902                	ld	s2,0(sp)
ffffffffc0200f74:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200f76:	4b00406f          	j	ffffffffc0205426 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200f7a:	555d                	li	a0,-9
ffffffffc0200f7c:	00b030ef          	jal	ra,ffffffffc0204786 <do_exit>
            if (current->need_resched)
ffffffffc0200f80:	601c                	ld	a5,0(s0)
ffffffffc0200f82:	bf65                	j	ffffffffc0200f3a <trap+0x40>

ffffffffc0200f84 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200f84:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200f88:	00011463          	bnez	sp,ffffffffc0200f90 <__alltraps+0xc>
ffffffffc0200f8c:	14002173          	csrr	sp,sscratch
ffffffffc0200f90:	712d                	addi	sp,sp,-288
ffffffffc0200f92:	e002                	sd	zero,0(sp)
ffffffffc0200f94:	e406                	sd	ra,8(sp)
ffffffffc0200f96:	ec0e                	sd	gp,24(sp)
ffffffffc0200f98:	f012                	sd	tp,32(sp)
ffffffffc0200f9a:	f416                	sd	t0,40(sp)
ffffffffc0200f9c:	f81a                	sd	t1,48(sp)
ffffffffc0200f9e:	fc1e                	sd	t2,56(sp)
ffffffffc0200fa0:	e0a2                	sd	s0,64(sp)
ffffffffc0200fa2:	e4a6                	sd	s1,72(sp)
ffffffffc0200fa4:	e8aa                	sd	a0,80(sp)
ffffffffc0200fa6:	ecae                	sd	a1,88(sp)
ffffffffc0200fa8:	f0b2                	sd	a2,96(sp)
ffffffffc0200faa:	f4b6                	sd	a3,104(sp)
ffffffffc0200fac:	f8ba                	sd	a4,112(sp)
ffffffffc0200fae:	fcbe                	sd	a5,120(sp)
ffffffffc0200fb0:	e142                	sd	a6,128(sp)
ffffffffc0200fb2:	e546                	sd	a7,136(sp)
ffffffffc0200fb4:	e94a                	sd	s2,144(sp)
ffffffffc0200fb6:	ed4e                	sd	s3,152(sp)
ffffffffc0200fb8:	f152                	sd	s4,160(sp)
ffffffffc0200fba:	f556                	sd	s5,168(sp)
ffffffffc0200fbc:	f95a                	sd	s6,176(sp)
ffffffffc0200fbe:	fd5e                	sd	s7,184(sp)
ffffffffc0200fc0:	e1e2                	sd	s8,192(sp)
ffffffffc0200fc2:	e5e6                	sd	s9,200(sp)
ffffffffc0200fc4:	e9ea                	sd	s10,208(sp)
ffffffffc0200fc6:	edee                	sd	s11,216(sp)
ffffffffc0200fc8:	f1f2                	sd	t3,224(sp)
ffffffffc0200fca:	f5f6                	sd	t4,232(sp)
ffffffffc0200fcc:	f9fa                	sd	t5,240(sp)
ffffffffc0200fce:	fdfe                	sd	t6,248(sp)
ffffffffc0200fd0:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200fd4:	100024f3          	csrr	s1,sstatus
ffffffffc0200fd8:	14102973          	csrr	s2,sepc
ffffffffc0200fdc:	143029f3          	csrr	s3,stval
ffffffffc0200fe0:	14202a73          	csrr	s4,scause
ffffffffc0200fe4:	e822                	sd	s0,16(sp)
ffffffffc0200fe6:	e226                	sd	s1,256(sp)
ffffffffc0200fe8:	e64a                	sd	s2,264(sp)
ffffffffc0200fea:	ea4e                	sd	s3,272(sp)
ffffffffc0200fec:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200fee:	850a                	mv	a0,sp
    jal trap
ffffffffc0200ff0:	f0bff0ef          	jal	ra,ffffffffc0200efa <trap>

ffffffffc0200ff4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200ff4:	6492                	ld	s1,256(sp)
ffffffffc0200ff6:	6932                	ld	s2,264(sp)
ffffffffc0200ff8:	1004f413          	andi	s0,s1,256
ffffffffc0200ffc:	e401                	bnez	s0,ffffffffc0201004 <__trapret+0x10>
ffffffffc0200ffe:	1200                	addi	s0,sp,288
ffffffffc0201000:	14041073          	csrw	sscratch,s0
ffffffffc0201004:	10049073          	csrw	sstatus,s1
ffffffffc0201008:	14191073          	csrw	sepc,s2
ffffffffc020100c:	60a2                	ld	ra,8(sp)
ffffffffc020100e:	61e2                	ld	gp,24(sp)
ffffffffc0201010:	7202                	ld	tp,32(sp)
ffffffffc0201012:	72a2                	ld	t0,40(sp)
ffffffffc0201014:	7342                	ld	t1,48(sp)
ffffffffc0201016:	73e2                	ld	t2,56(sp)
ffffffffc0201018:	6406                	ld	s0,64(sp)
ffffffffc020101a:	64a6                	ld	s1,72(sp)
ffffffffc020101c:	6546                	ld	a0,80(sp)
ffffffffc020101e:	65e6                	ld	a1,88(sp)
ffffffffc0201020:	7606                	ld	a2,96(sp)
ffffffffc0201022:	76a6                	ld	a3,104(sp)
ffffffffc0201024:	7746                	ld	a4,112(sp)
ffffffffc0201026:	77e6                	ld	a5,120(sp)
ffffffffc0201028:	680a                	ld	a6,128(sp)
ffffffffc020102a:	68aa                	ld	a7,136(sp)
ffffffffc020102c:	694a                	ld	s2,144(sp)
ffffffffc020102e:	69ea                	ld	s3,152(sp)
ffffffffc0201030:	7a0a                	ld	s4,160(sp)
ffffffffc0201032:	7aaa                	ld	s5,168(sp)
ffffffffc0201034:	7b4a                	ld	s6,176(sp)
ffffffffc0201036:	7bea                	ld	s7,184(sp)
ffffffffc0201038:	6c0e                	ld	s8,192(sp)
ffffffffc020103a:	6cae                	ld	s9,200(sp)
ffffffffc020103c:	6d4e                	ld	s10,208(sp)
ffffffffc020103e:	6dee                	ld	s11,216(sp)
ffffffffc0201040:	7e0e                	ld	t3,224(sp)
ffffffffc0201042:	7eae                	ld	t4,232(sp)
ffffffffc0201044:	7f4e                	ld	t5,240(sp)
ffffffffc0201046:	7fee                	ld	t6,248(sp)
ffffffffc0201048:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc020104a:	10200073          	sret

ffffffffc020104e <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc020104e:	812a                	mv	sp,a0
    j __trapret
ffffffffc0201050:	b755                	j	ffffffffc0200ff4 <__trapret>

ffffffffc0201052 <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0201052:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd0>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0201056:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc020105a:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc020105e:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0201062:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0201066:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc020106a:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc020106e:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0201072:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0201076:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0201078:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc020107a:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc020107c:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc020107e:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0201080:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0201082:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0201084:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0201086:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0201088:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc020108a:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc020108c:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc020108e:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0201090:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0201092:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0201094:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0201096:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0201098:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc020109a:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc020109c:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc020109e:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc02010a0:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc02010a2:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc02010a4:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc02010a6:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc02010a8:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc02010aa:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc02010ac:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc02010ae:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc02010b0:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc02010b2:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc02010b4:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc02010b6:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc02010b8:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc02010ba:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc02010bc:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc02010be:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc02010c0:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc02010c2:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc02010c4:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc02010c6:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc02010c8:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc02010ca:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc02010cc:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc02010ce:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc02010d0:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc02010d2:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc02010d4:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc02010d6:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc02010d8:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc02010da:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc02010dc:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc02010de:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc02010e0:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc02010e2:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc02010e4:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc02010e6:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc02010e8:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc02010ea:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc02010ec:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc02010ee:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc02010f0:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc02010f2:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc02010f4:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc02010f6:	812e                	mv	sp,a1
ffffffffc02010f8:	bdf5                	j	ffffffffc0200ff4 <__trapret>

ffffffffc02010fa <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02010fa:	000b2797          	auipc	a5,0xb2
ffffffffc02010fe:	66e78793          	addi	a5,a5,1646 # ffffffffc02b3768 <free_area>
ffffffffc0201102:	e79c                	sd	a5,8(a5)
ffffffffc0201104:	e39c                	sd	a5,0(a5)

static void
default_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc0201106:	0007a823          	sw	zero,16(a5)
}
ffffffffc020110a:	8082                	ret

ffffffffc020110c <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc020110c:	000b2517          	auipc	a0,0xb2
ffffffffc0201110:	66c56503          	lwu	a0,1644(a0) # ffffffffc02b3778 <free_area+0x10>
ffffffffc0201114:	8082                	ret

ffffffffc0201116 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
ffffffffc0201116:	715d                	addi	sp,sp,-80
ffffffffc0201118:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc020111a:	000b2417          	auipc	s0,0xb2
ffffffffc020111e:	64e40413          	addi	s0,s0,1614 # ffffffffc02b3768 <free_area>
ffffffffc0201122:	641c                	ld	a5,8(s0)
ffffffffc0201124:	e486                	sd	ra,72(sp)
ffffffffc0201126:	fc26                	sd	s1,56(sp)
ffffffffc0201128:	f84a                	sd	s2,48(sp)
ffffffffc020112a:	f44e                	sd	s3,40(sp)
ffffffffc020112c:	f052                	sd	s4,32(sp)
ffffffffc020112e:	ec56                	sd	s5,24(sp)
ffffffffc0201130:	e85a                	sd	s6,16(sp)
ffffffffc0201132:	e45e                	sd	s7,8(sp)
ffffffffc0201134:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0201136:	2a878d63          	beq	a5,s0,ffffffffc02013f0 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc020113a:	4481                	li	s1,0
ffffffffc020113c:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020113e:	ff07b703          	ld	a4,-16(a5)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201142:	8b09                	andi	a4,a4,2
ffffffffc0201144:	2a070a63          	beqz	a4,ffffffffc02013f8 <default_check+0x2e2>
        count++, total += p->property;
ffffffffc0201148:	ff87a703          	lw	a4,-8(a5)
ffffffffc020114c:	679c                	ld	a5,8(a5)
ffffffffc020114e:	2905                	addiw	s2,s2,1
ffffffffc0201150:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0201152:	fe8796e3          	bne	a5,s0,ffffffffc020113e <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0201156:	89a6                	mv	s3,s1
ffffffffc0201158:	6df000ef          	jal	ra,ffffffffc0202036 <nr_free_pages>
ffffffffc020115c:	6f351e63          	bne	a0,s3,ffffffffc0201858 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201160:	4505                	li	a0,1
ffffffffc0201162:	657000ef          	jal	ra,ffffffffc0201fb8 <alloc_pages>
ffffffffc0201166:	8aaa                	mv	s5,a0
ffffffffc0201168:	42050863          	beqz	a0,ffffffffc0201598 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020116c:	4505                	li	a0,1
ffffffffc020116e:	64b000ef          	jal	ra,ffffffffc0201fb8 <alloc_pages>
ffffffffc0201172:	89aa                	mv	s3,a0
ffffffffc0201174:	70050263          	beqz	a0,ffffffffc0201878 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201178:	4505                	li	a0,1
ffffffffc020117a:	63f000ef          	jal	ra,ffffffffc0201fb8 <alloc_pages>
ffffffffc020117e:	8a2a                	mv	s4,a0
ffffffffc0201180:	48050c63          	beqz	a0,ffffffffc0201618 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201184:	293a8a63          	beq	s5,s3,ffffffffc0201418 <default_check+0x302>
ffffffffc0201188:	28aa8863          	beq	s5,a0,ffffffffc0201418 <default_check+0x302>
ffffffffc020118c:	28a98663          	beq	s3,a0,ffffffffc0201418 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201190:	000aa783          	lw	a5,0(s5)
ffffffffc0201194:	2a079263          	bnez	a5,ffffffffc0201438 <default_check+0x322>
ffffffffc0201198:	0009a783          	lw	a5,0(s3)
ffffffffc020119c:	28079e63          	bnez	a5,ffffffffc0201438 <default_check+0x322>
ffffffffc02011a0:	411c                	lw	a5,0(a0)
ffffffffc02011a2:	28079b63          	bnez	a5,ffffffffc0201438 <default_check+0x322>
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page)
{
    return page - pages + nbase;
ffffffffc02011a6:	000b6797          	auipc	a5,0xb6
ffffffffc02011aa:	63a7b783          	ld	a5,1594(a5) # ffffffffc02b77e0 <pages>
ffffffffc02011ae:	40fa8733          	sub	a4,s5,a5
ffffffffc02011b2:	00007617          	auipc	a2,0x7
ffffffffc02011b6:	b6e63603          	ld	a2,-1170(a2) # ffffffffc0207d20 <nbase>
ffffffffc02011ba:	8719                	srai	a4,a4,0x6
ffffffffc02011bc:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02011be:	000b6697          	auipc	a3,0xb6
ffffffffc02011c2:	61a6b683          	ld	a3,1562(a3) # ffffffffc02b77d8 <npage>
ffffffffc02011c6:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page)
{
    return page2ppn(page) << PGSHIFT;
ffffffffc02011c8:	0732                	slli	a4,a4,0xc
ffffffffc02011ca:	28d77763          	bgeu	a4,a3,ffffffffc0201458 <default_check+0x342>
    return page - pages + nbase;
ffffffffc02011ce:	40f98733          	sub	a4,s3,a5
ffffffffc02011d2:	8719                	srai	a4,a4,0x6
ffffffffc02011d4:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02011d6:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02011d8:	4cd77063          	bgeu	a4,a3,ffffffffc0201698 <default_check+0x582>
    return page - pages + nbase;
ffffffffc02011dc:	40f507b3          	sub	a5,a0,a5
ffffffffc02011e0:	8799                	srai	a5,a5,0x6
ffffffffc02011e2:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02011e4:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02011e6:	30d7f963          	bgeu	a5,a3,ffffffffc02014f8 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc02011ea:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02011ec:	00043c03          	ld	s8,0(s0)
ffffffffc02011f0:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc02011f4:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc02011f8:	e400                	sd	s0,8(s0)
ffffffffc02011fa:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc02011fc:	000b2797          	auipc	a5,0xb2
ffffffffc0201200:	5607ae23          	sw	zero,1404(a5) # ffffffffc02b3778 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201204:	5b5000ef          	jal	ra,ffffffffc0201fb8 <alloc_pages>
ffffffffc0201208:	2c051863          	bnez	a0,ffffffffc02014d8 <default_check+0x3c2>
    free_page(p0);
ffffffffc020120c:	4585                	li	a1,1
ffffffffc020120e:	8556                	mv	a0,s5
ffffffffc0201210:	5e7000ef          	jal	ra,ffffffffc0201ff6 <free_pages>
    free_page(p1);
ffffffffc0201214:	4585                	li	a1,1
ffffffffc0201216:	854e                	mv	a0,s3
ffffffffc0201218:	5df000ef          	jal	ra,ffffffffc0201ff6 <free_pages>
    free_page(p2);
ffffffffc020121c:	4585                	li	a1,1
ffffffffc020121e:	8552                	mv	a0,s4
ffffffffc0201220:	5d7000ef          	jal	ra,ffffffffc0201ff6 <free_pages>
    assert(nr_free == 3);
ffffffffc0201224:	4818                	lw	a4,16(s0)
ffffffffc0201226:	478d                	li	a5,3
ffffffffc0201228:	28f71863          	bne	a4,a5,ffffffffc02014b8 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020122c:	4505                	li	a0,1
ffffffffc020122e:	58b000ef          	jal	ra,ffffffffc0201fb8 <alloc_pages>
ffffffffc0201232:	89aa                	mv	s3,a0
ffffffffc0201234:	26050263          	beqz	a0,ffffffffc0201498 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201238:	4505                	li	a0,1
ffffffffc020123a:	57f000ef          	jal	ra,ffffffffc0201fb8 <alloc_pages>
ffffffffc020123e:	8aaa                	mv	s5,a0
ffffffffc0201240:	3a050c63          	beqz	a0,ffffffffc02015f8 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201244:	4505                	li	a0,1
ffffffffc0201246:	573000ef          	jal	ra,ffffffffc0201fb8 <alloc_pages>
ffffffffc020124a:	8a2a                	mv	s4,a0
ffffffffc020124c:	38050663          	beqz	a0,ffffffffc02015d8 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0201250:	4505                	li	a0,1
ffffffffc0201252:	567000ef          	jal	ra,ffffffffc0201fb8 <alloc_pages>
ffffffffc0201256:	36051163          	bnez	a0,ffffffffc02015b8 <default_check+0x4a2>
    free_page(p0);
ffffffffc020125a:	4585                	li	a1,1
ffffffffc020125c:	854e                	mv	a0,s3
ffffffffc020125e:	599000ef          	jal	ra,ffffffffc0201ff6 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0201262:	641c                	ld	a5,8(s0)
ffffffffc0201264:	20878a63          	beq	a5,s0,ffffffffc0201478 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0201268:	4505                	li	a0,1
ffffffffc020126a:	54f000ef          	jal	ra,ffffffffc0201fb8 <alloc_pages>
ffffffffc020126e:	30a99563          	bne	s3,a0,ffffffffc0201578 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0201272:	4505                	li	a0,1
ffffffffc0201274:	545000ef          	jal	ra,ffffffffc0201fb8 <alloc_pages>
ffffffffc0201278:	2e051063          	bnez	a0,ffffffffc0201558 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc020127c:	481c                	lw	a5,16(s0)
ffffffffc020127e:	2a079d63          	bnez	a5,ffffffffc0201538 <default_check+0x422>
    free_page(p);
ffffffffc0201282:	854e                	mv	a0,s3
ffffffffc0201284:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201286:	01843023          	sd	s8,0(s0)
ffffffffc020128a:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc020128e:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0201292:	565000ef          	jal	ra,ffffffffc0201ff6 <free_pages>
    free_page(p1);
ffffffffc0201296:	4585                	li	a1,1
ffffffffc0201298:	8556                	mv	a0,s5
ffffffffc020129a:	55d000ef          	jal	ra,ffffffffc0201ff6 <free_pages>
    free_page(p2);
ffffffffc020129e:	4585                	li	a1,1
ffffffffc02012a0:	8552                	mv	a0,s4
ffffffffc02012a2:	555000ef          	jal	ra,ffffffffc0201ff6 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02012a6:	4515                	li	a0,5
ffffffffc02012a8:	511000ef          	jal	ra,ffffffffc0201fb8 <alloc_pages>
ffffffffc02012ac:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02012ae:	26050563          	beqz	a0,ffffffffc0201518 <default_check+0x402>
ffffffffc02012b2:	651c                	ld	a5,8(a0)
ffffffffc02012b4:	8385                	srli	a5,a5,0x1
ffffffffc02012b6:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc02012b8:	54079063          	bnez	a5,ffffffffc02017f8 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02012bc:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02012be:	00043b03          	ld	s6,0(s0)
ffffffffc02012c2:	00843a83          	ld	s5,8(s0)
ffffffffc02012c6:	e000                	sd	s0,0(s0)
ffffffffc02012c8:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc02012ca:	4ef000ef          	jal	ra,ffffffffc0201fb8 <alloc_pages>
ffffffffc02012ce:	50051563          	bnez	a0,ffffffffc02017d8 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02012d2:	08098a13          	addi	s4,s3,128
ffffffffc02012d6:	8552                	mv	a0,s4
ffffffffc02012d8:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02012da:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc02012de:	000b2797          	auipc	a5,0xb2
ffffffffc02012e2:	4807ad23          	sw	zero,1178(a5) # ffffffffc02b3778 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02012e6:	511000ef          	jal	ra,ffffffffc0201ff6 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02012ea:	4511                	li	a0,4
ffffffffc02012ec:	4cd000ef          	jal	ra,ffffffffc0201fb8 <alloc_pages>
ffffffffc02012f0:	4c051463          	bnez	a0,ffffffffc02017b8 <default_check+0x6a2>
ffffffffc02012f4:	0889b783          	ld	a5,136(s3)
ffffffffc02012f8:	8385                	srli	a5,a5,0x1
ffffffffc02012fa:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02012fc:	48078e63          	beqz	a5,ffffffffc0201798 <default_check+0x682>
ffffffffc0201300:	0909a703          	lw	a4,144(s3)
ffffffffc0201304:	478d                	li	a5,3
ffffffffc0201306:	48f71963          	bne	a4,a5,ffffffffc0201798 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020130a:	450d                	li	a0,3
ffffffffc020130c:	4ad000ef          	jal	ra,ffffffffc0201fb8 <alloc_pages>
ffffffffc0201310:	8c2a                	mv	s8,a0
ffffffffc0201312:	46050363          	beqz	a0,ffffffffc0201778 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0201316:	4505                	li	a0,1
ffffffffc0201318:	4a1000ef          	jal	ra,ffffffffc0201fb8 <alloc_pages>
ffffffffc020131c:	42051e63          	bnez	a0,ffffffffc0201758 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0201320:	418a1c63          	bne	s4,s8,ffffffffc0201738 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201324:	4585                	li	a1,1
ffffffffc0201326:	854e                	mv	a0,s3
ffffffffc0201328:	4cf000ef          	jal	ra,ffffffffc0201ff6 <free_pages>
    free_pages(p1, 3);
ffffffffc020132c:	458d                	li	a1,3
ffffffffc020132e:	8552                	mv	a0,s4
ffffffffc0201330:	4c7000ef          	jal	ra,ffffffffc0201ff6 <free_pages>
ffffffffc0201334:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201338:	04098c13          	addi	s8,s3,64
ffffffffc020133c:	8385                	srli	a5,a5,0x1
ffffffffc020133e:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201340:	3c078c63          	beqz	a5,ffffffffc0201718 <default_check+0x602>
ffffffffc0201344:	0109a703          	lw	a4,16(s3)
ffffffffc0201348:	4785                	li	a5,1
ffffffffc020134a:	3cf71763          	bne	a4,a5,ffffffffc0201718 <default_check+0x602>
ffffffffc020134e:	008a3783          	ld	a5,8(s4)
ffffffffc0201352:	8385                	srli	a5,a5,0x1
ffffffffc0201354:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201356:	3a078163          	beqz	a5,ffffffffc02016f8 <default_check+0x5e2>
ffffffffc020135a:	010a2703          	lw	a4,16(s4)
ffffffffc020135e:	478d                	li	a5,3
ffffffffc0201360:	38f71c63          	bne	a4,a5,ffffffffc02016f8 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201364:	4505                	li	a0,1
ffffffffc0201366:	453000ef          	jal	ra,ffffffffc0201fb8 <alloc_pages>
ffffffffc020136a:	36a99763          	bne	s3,a0,ffffffffc02016d8 <default_check+0x5c2>
    free_page(p0);
ffffffffc020136e:	4585                	li	a1,1
ffffffffc0201370:	487000ef          	jal	ra,ffffffffc0201ff6 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201374:	4509                	li	a0,2
ffffffffc0201376:	443000ef          	jal	ra,ffffffffc0201fb8 <alloc_pages>
ffffffffc020137a:	32aa1f63          	bne	s4,a0,ffffffffc02016b8 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc020137e:	4589                	li	a1,2
ffffffffc0201380:	477000ef          	jal	ra,ffffffffc0201ff6 <free_pages>
    free_page(p2);
ffffffffc0201384:	4585                	li	a1,1
ffffffffc0201386:	8562                	mv	a0,s8
ffffffffc0201388:	46f000ef          	jal	ra,ffffffffc0201ff6 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020138c:	4515                	li	a0,5
ffffffffc020138e:	42b000ef          	jal	ra,ffffffffc0201fb8 <alloc_pages>
ffffffffc0201392:	89aa                	mv	s3,a0
ffffffffc0201394:	48050263          	beqz	a0,ffffffffc0201818 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc0201398:	4505                	li	a0,1
ffffffffc020139a:	41f000ef          	jal	ra,ffffffffc0201fb8 <alloc_pages>
ffffffffc020139e:	2c051d63          	bnez	a0,ffffffffc0201678 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc02013a2:	481c                	lw	a5,16(s0)
ffffffffc02013a4:	2a079a63          	bnez	a5,ffffffffc0201658 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02013a8:	4595                	li	a1,5
ffffffffc02013aa:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02013ac:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02013b0:	01643023          	sd	s6,0(s0)
ffffffffc02013b4:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc02013b8:	43f000ef          	jal	ra,ffffffffc0201ff6 <free_pages>
    return listelm->next;
ffffffffc02013bc:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc02013be:	00878963          	beq	a5,s0,ffffffffc02013d0 <default_check+0x2ba>
    {
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc02013c2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02013c6:	679c                	ld	a5,8(a5)
ffffffffc02013c8:	397d                	addiw	s2,s2,-1
ffffffffc02013ca:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc02013cc:	fe879be3          	bne	a5,s0,ffffffffc02013c2 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc02013d0:	26091463          	bnez	s2,ffffffffc0201638 <default_check+0x522>
    assert(total == 0);
ffffffffc02013d4:	46049263          	bnez	s1,ffffffffc0201838 <default_check+0x722>
}
ffffffffc02013d8:	60a6                	ld	ra,72(sp)
ffffffffc02013da:	6406                	ld	s0,64(sp)
ffffffffc02013dc:	74e2                	ld	s1,56(sp)
ffffffffc02013de:	7942                	ld	s2,48(sp)
ffffffffc02013e0:	79a2                	ld	s3,40(sp)
ffffffffc02013e2:	7a02                	ld	s4,32(sp)
ffffffffc02013e4:	6ae2                	ld	s5,24(sp)
ffffffffc02013e6:	6b42                	ld	s6,16(sp)
ffffffffc02013e8:	6ba2                	ld	s7,8(sp)
ffffffffc02013ea:	6c02                	ld	s8,0(sp)
ffffffffc02013ec:	6161                	addi	sp,sp,80
ffffffffc02013ee:	8082                	ret
    while ((le = list_next(le)) != &free_list)
ffffffffc02013f0:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02013f2:	4481                	li	s1,0
ffffffffc02013f4:	4901                	li	s2,0
ffffffffc02013f6:	b38d                	j	ffffffffc0201158 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc02013f8:	00005697          	auipc	a3,0x5
ffffffffc02013fc:	1b868693          	addi	a3,a3,440 # ffffffffc02065b0 <commands+0x8b8>
ffffffffc0201400:	00005617          	auipc	a2,0x5
ffffffffc0201404:	1c060613          	addi	a2,a2,448 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201408:	11000593          	li	a1,272
ffffffffc020140c:	00005517          	auipc	a0,0x5
ffffffffc0201410:	1cc50513          	addi	a0,a0,460 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201414:	87aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201418:	00005697          	auipc	a3,0x5
ffffffffc020141c:	25868693          	addi	a3,a3,600 # ffffffffc0206670 <commands+0x978>
ffffffffc0201420:	00005617          	auipc	a2,0x5
ffffffffc0201424:	1a060613          	addi	a2,a2,416 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201428:	0db00593          	li	a1,219
ffffffffc020142c:	00005517          	auipc	a0,0x5
ffffffffc0201430:	1ac50513          	addi	a0,a0,428 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201434:	85aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201438:	00005697          	auipc	a3,0x5
ffffffffc020143c:	26068693          	addi	a3,a3,608 # ffffffffc0206698 <commands+0x9a0>
ffffffffc0201440:	00005617          	auipc	a2,0x5
ffffffffc0201444:	18060613          	addi	a2,a2,384 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201448:	0dc00593          	li	a1,220
ffffffffc020144c:	00005517          	auipc	a0,0x5
ffffffffc0201450:	18c50513          	addi	a0,a0,396 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201454:	83aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201458:	00005697          	auipc	a3,0x5
ffffffffc020145c:	28068693          	addi	a3,a3,640 # ffffffffc02066d8 <commands+0x9e0>
ffffffffc0201460:	00005617          	auipc	a2,0x5
ffffffffc0201464:	16060613          	addi	a2,a2,352 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201468:	0de00593          	li	a1,222
ffffffffc020146c:	00005517          	auipc	a0,0x5
ffffffffc0201470:	16c50513          	addi	a0,a0,364 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201474:	81aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201478:	00005697          	auipc	a3,0x5
ffffffffc020147c:	2e868693          	addi	a3,a3,744 # ffffffffc0206760 <commands+0xa68>
ffffffffc0201480:	00005617          	auipc	a2,0x5
ffffffffc0201484:	14060613          	addi	a2,a2,320 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201488:	0f700593          	li	a1,247
ffffffffc020148c:	00005517          	auipc	a0,0x5
ffffffffc0201490:	14c50513          	addi	a0,a0,332 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201494:	ffbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201498:	00005697          	auipc	a3,0x5
ffffffffc020149c:	17868693          	addi	a3,a3,376 # ffffffffc0206610 <commands+0x918>
ffffffffc02014a0:	00005617          	auipc	a2,0x5
ffffffffc02014a4:	12060613          	addi	a2,a2,288 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02014a8:	0f000593          	li	a1,240
ffffffffc02014ac:	00005517          	auipc	a0,0x5
ffffffffc02014b0:	12c50513          	addi	a0,a0,300 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc02014b4:	fdbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free == 3);
ffffffffc02014b8:	00005697          	auipc	a3,0x5
ffffffffc02014bc:	29868693          	addi	a3,a3,664 # ffffffffc0206750 <commands+0xa58>
ffffffffc02014c0:	00005617          	auipc	a2,0x5
ffffffffc02014c4:	10060613          	addi	a2,a2,256 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02014c8:	0ee00593          	li	a1,238
ffffffffc02014cc:	00005517          	auipc	a0,0x5
ffffffffc02014d0:	10c50513          	addi	a0,a0,268 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc02014d4:	fbbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014d8:	00005697          	auipc	a3,0x5
ffffffffc02014dc:	26068693          	addi	a3,a3,608 # ffffffffc0206738 <commands+0xa40>
ffffffffc02014e0:	00005617          	auipc	a2,0x5
ffffffffc02014e4:	0e060613          	addi	a2,a2,224 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02014e8:	0e900593          	li	a1,233
ffffffffc02014ec:	00005517          	auipc	a0,0x5
ffffffffc02014f0:	0ec50513          	addi	a0,a0,236 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc02014f4:	f9bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02014f8:	00005697          	auipc	a3,0x5
ffffffffc02014fc:	22068693          	addi	a3,a3,544 # ffffffffc0206718 <commands+0xa20>
ffffffffc0201500:	00005617          	auipc	a2,0x5
ffffffffc0201504:	0c060613          	addi	a2,a2,192 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201508:	0e000593          	li	a1,224
ffffffffc020150c:	00005517          	auipc	a0,0x5
ffffffffc0201510:	0cc50513          	addi	a0,a0,204 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201514:	f7bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(p0 != NULL);
ffffffffc0201518:	00005697          	auipc	a3,0x5
ffffffffc020151c:	29068693          	addi	a3,a3,656 # ffffffffc02067a8 <commands+0xab0>
ffffffffc0201520:	00005617          	auipc	a2,0x5
ffffffffc0201524:	0a060613          	addi	a2,a2,160 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201528:	11800593          	li	a1,280
ffffffffc020152c:	00005517          	auipc	a0,0x5
ffffffffc0201530:	0ac50513          	addi	a0,a0,172 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201534:	f5bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free == 0);
ffffffffc0201538:	00005697          	auipc	a3,0x5
ffffffffc020153c:	26068693          	addi	a3,a3,608 # ffffffffc0206798 <commands+0xaa0>
ffffffffc0201540:	00005617          	auipc	a2,0x5
ffffffffc0201544:	08060613          	addi	a2,a2,128 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201548:	0fd00593          	li	a1,253
ffffffffc020154c:	00005517          	auipc	a0,0x5
ffffffffc0201550:	08c50513          	addi	a0,a0,140 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201554:	f3bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201558:	00005697          	auipc	a3,0x5
ffffffffc020155c:	1e068693          	addi	a3,a3,480 # ffffffffc0206738 <commands+0xa40>
ffffffffc0201560:	00005617          	auipc	a2,0x5
ffffffffc0201564:	06060613          	addi	a2,a2,96 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201568:	0fb00593          	li	a1,251
ffffffffc020156c:	00005517          	auipc	a0,0x5
ffffffffc0201570:	06c50513          	addi	a0,a0,108 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201574:	f1bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201578:	00005697          	auipc	a3,0x5
ffffffffc020157c:	20068693          	addi	a3,a3,512 # ffffffffc0206778 <commands+0xa80>
ffffffffc0201580:	00005617          	auipc	a2,0x5
ffffffffc0201584:	04060613          	addi	a2,a2,64 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201588:	0fa00593          	li	a1,250
ffffffffc020158c:	00005517          	auipc	a0,0x5
ffffffffc0201590:	04c50513          	addi	a0,a0,76 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201594:	efbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201598:	00005697          	auipc	a3,0x5
ffffffffc020159c:	07868693          	addi	a3,a3,120 # ffffffffc0206610 <commands+0x918>
ffffffffc02015a0:	00005617          	auipc	a2,0x5
ffffffffc02015a4:	02060613          	addi	a2,a2,32 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02015a8:	0d700593          	li	a1,215
ffffffffc02015ac:	00005517          	auipc	a0,0x5
ffffffffc02015b0:	02c50513          	addi	a0,a0,44 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc02015b4:	edbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02015b8:	00005697          	auipc	a3,0x5
ffffffffc02015bc:	18068693          	addi	a3,a3,384 # ffffffffc0206738 <commands+0xa40>
ffffffffc02015c0:	00005617          	auipc	a2,0x5
ffffffffc02015c4:	00060613          	mv	a2,a2
ffffffffc02015c8:	0f400593          	li	a1,244
ffffffffc02015cc:	00005517          	auipc	a0,0x5
ffffffffc02015d0:	00c50513          	addi	a0,a0,12 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc02015d4:	ebbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02015d8:	00005697          	auipc	a3,0x5
ffffffffc02015dc:	07868693          	addi	a3,a3,120 # ffffffffc0206650 <commands+0x958>
ffffffffc02015e0:	00005617          	auipc	a2,0x5
ffffffffc02015e4:	fe060613          	addi	a2,a2,-32 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02015e8:	0f200593          	li	a1,242
ffffffffc02015ec:	00005517          	auipc	a0,0x5
ffffffffc02015f0:	fec50513          	addi	a0,a0,-20 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc02015f4:	e9bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02015f8:	00005697          	auipc	a3,0x5
ffffffffc02015fc:	03868693          	addi	a3,a3,56 # ffffffffc0206630 <commands+0x938>
ffffffffc0201600:	00005617          	auipc	a2,0x5
ffffffffc0201604:	fc060613          	addi	a2,a2,-64 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201608:	0f100593          	li	a1,241
ffffffffc020160c:	00005517          	auipc	a0,0x5
ffffffffc0201610:	fcc50513          	addi	a0,a0,-52 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201614:	e7bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201618:	00005697          	auipc	a3,0x5
ffffffffc020161c:	03868693          	addi	a3,a3,56 # ffffffffc0206650 <commands+0x958>
ffffffffc0201620:	00005617          	auipc	a2,0x5
ffffffffc0201624:	fa060613          	addi	a2,a2,-96 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201628:	0d900593          	li	a1,217
ffffffffc020162c:	00005517          	auipc	a0,0x5
ffffffffc0201630:	fac50513          	addi	a0,a0,-84 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201634:	e5bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(count == 0);
ffffffffc0201638:	00005697          	auipc	a3,0x5
ffffffffc020163c:	2c068693          	addi	a3,a3,704 # ffffffffc02068f8 <commands+0xc00>
ffffffffc0201640:	00005617          	auipc	a2,0x5
ffffffffc0201644:	f8060613          	addi	a2,a2,-128 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201648:	14600593          	li	a1,326
ffffffffc020164c:	00005517          	auipc	a0,0x5
ffffffffc0201650:	f8c50513          	addi	a0,a0,-116 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201654:	e3bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free == 0);
ffffffffc0201658:	00005697          	auipc	a3,0x5
ffffffffc020165c:	14068693          	addi	a3,a3,320 # ffffffffc0206798 <commands+0xaa0>
ffffffffc0201660:	00005617          	auipc	a2,0x5
ffffffffc0201664:	f6060613          	addi	a2,a2,-160 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201668:	13a00593          	li	a1,314
ffffffffc020166c:	00005517          	auipc	a0,0x5
ffffffffc0201670:	f6c50513          	addi	a0,a0,-148 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201674:	e1bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201678:	00005697          	auipc	a3,0x5
ffffffffc020167c:	0c068693          	addi	a3,a3,192 # ffffffffc0206738 <commands+0xa40>
ffffffffc0201680:	00005617          	auipc	a2,0x5
ffffffffc0201684:	f4060613          	addi	a2,a2,-192 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201688:	13800593          	li	a1,312
ffffffffc020168c:	00005517          	auipc	a0,0x5
ffffffffc0201690:	f4c50513          	addi	a0,a0,-180 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201694:	dfbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201698:	00005697          	auipc	a3,0x5
ffffffffc020169c:	06068693          	addi	a3,a3,96 # ffffffffc02066f8 <commands+0xa00>
ffffffffc02016a0:	00005617          	auipc	a2,0x5
ffffffffc02016a4:	f2060613          	addi	a2,a2,-224 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02016a8:	0df00593          	li	a1,223
ffffffffc02016ac:	00005517          	auipc	a0,0x5
ffffffffc02016b0:	f2c50513          	addi	a0,a0,-212 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc02016b4:	ddbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02016b8:	00005697          	auipc	a3,0x5
ffffffffc02016bc:	20068693          	addi	a3,a3,512 # ffffffffc02068b8 <commands+0xbc0>
ffffffffc02016c0:	00005617          	auipc	a2,0x5
ffffffffc02016c4:	f0060613          	addi	a2,a2,-256 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02016c8:	13200593          	li	a1,306
ffffffffc02016cc:	00005517          	auipc	a0,0x5
ffffffffc02016d0:	f0c50513          	addi	a0,a0,-244 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc02016d4:	dbbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02016d8:	00005697          	auipc	a3,0x5
ffffffffc02016dc:	1c068693          	addi	a3,a3,448 # ffffffffc0206898 <commands+0xba0>
ffffffffc02016e0:	00005617          	auipc	a2,0x5
ffffffffc02016e4:	ee060613          	addi	a2,a2,-288 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02016e8:	13000593          	li	a1,304
ffffffffc02016ec:	00005517          	auipc	a0,0x5
ffffffffc02016f0:	eec50513          	addi	a0,a0,-276 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc02016f4:	d9bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02016f8:	00005697          	auipc	a3,0x5
ffffffffc02016fc:	17868693          	addi	a3,a3,376 # ffffffffc0206870 <commands+0xb78>
ffffffffc0201700:	00005617          	auipc	a2,0x5
ffffffffc0201704:	ec060613          	addi	a2,a2,-320 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201708:	12e00593          	li	a1,302
ffffffffc020170c:	00005517          	auipc	a0,0x5
ffffffffc0201710:	ecc50513          	addi	a0,a0,-308 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201714:	d7bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201718:	00005697          	auipc	a3,0x5
ffffffffc020171c:	13068693          	addi	a3,a3,304 # ffffffffc0206848 <commands+0xb50>
ffffffffc0201720:	00005617          	auipc	a2,0x5
ffffffffc0201724:	ea060613          	addi	a2,a2,-352 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201728:	12d00593          	li	a1,301
ffffffffc020172c:	00005517          	auipc	a0,0x5
ffffffffc0201730:	eac50513          	addi	a0,a0,-340 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201734:	d5bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201738:	00005697          	auipc	a3,0x5
ffffffffc020173c:	10068693          	addi	a3,a3,256 # ffffffffc0206838 <commands+0xb40>
ffffffffc0201740:	00005617          	auipc	a2,0x5
ffffffffc0201744:	e8060613          	addi	a2,a2,-384 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201748:	12800593          	li	a1,296
ffffffffc020174c:	00005517          	auipc	a0,0x5
ffffffffc0201750:	e8c50513          	addi	a0,a0,-372 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201754:	d3bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201758:	00005697          	auipc	a3,0x5
ffffffffc020175c:	fe068693          	addi	a3,a3,-32 # ffffffffc0206738 <commands+0xa40>
ffffffffc0201760:	00005617          	auipc	a2,0x5
ffffffffc0201764:	e6060613          	addi	a2,a2,-416 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201768:	12700593          	li	a1,295
ffffffffc020176c:	00005517          	auipc	a0,0x5
ffffffffc0201770:	e6c50513          	addi	a0,a0,-404 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201774:	d1bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201778:	00005697          	auipc	a3,0x5
ffffffffc020177c:	0a068693          	addi	a3,a3,160 # ffffffffc0206818 <commands+0xb20>
ffffffffc0201780:	00005617          	auipc	a2,0x5
ffffffffc0201784:	e4060613          	addi	a2,a2,-448 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201788:	12600593          	li	a1,294
ffffffffc020178c:	00005517          	auipc	a0,0x5
ffffffffc0201790:	e4c50513          	addi	a0,a0,-436 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201794:	cfbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201798:	00005697          	auipc	a3,0x5
ffffffffc020179c:	05068693          	addi	a3,a3,80 # ffffffffc02067e8 <commands+0xaf0>
ffffffffc02017a0:	00005617          	auipc	a2,0x5
ffffffffc02017a4:	e2060613          	addi	a2,a2,-480 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02017a8:	12500593          	li	a1,293
ffffffffc02017ac:	00005517          	auipc	a0,0x5
ffffffffc02017b0:	e2c50513          	addi	a0,a0,-468 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc02017b4:	cdbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02017b8:	00005697          	auipc	a3,0x5
ffffffffc02017bc:	01868693          	addi	a3,a3,24 # ffffffffc02067d0 <commands+0xad8>
ffffffffc02017c0:	00005617          	auipc	a2,0x5
ffffffffc02017c4:	e0060613          	addi	a2,a2,-512 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02017c8:	12400593          	li	a1,292
ffffffffc02017cc:	00005517          	auipc	a0,0x5
ffffffffc02017d0:	e0c50513          	addi	a0,a0,-500 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc02017d4:	cbbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02017d8:	00005697          	auipc	a3,0x5
ffffffffc02017dc:	f6068693          	addi	a3,a3,-160 # ffffffffc0206738 <commands+0xa40>
ffffffffc02017e0:	00005617          	auipc	a2,0x5
ffffffffc02017e4:	de060613          	addi	a2,a2,-544 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02017e8:	11e00593          	li	a1,286
ffffffffc02017ec:	00005517          	auipc	a0,0x5
ffffffffc02017f0:	dec50513          	addi	a0,a0,-532 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc02017f4:	c9bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(!PageProperty(p0));
ffffffffc02017f8:	00005697          	auipc	a3,0x5
ffffffffc02017fc:	fc068693          	addi	a3,a3,-64 # ffffffffc02067b8 <commands+0xac0>
ffffffffc0201800:	00005617          	auipc	a2,0x5
ffffffffc0201804:	dc060613          	addi	a2,a2,-576 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201808:	11900593          	li	a1,281
ffffffffc020180c:	00005517          	auipc	a0,0x5
ffffffffc0201810:	dcc50513          	addi	a0,a0,-564 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201814:	c7bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201818:	00005697          	auipc	a3,0x5
ffffffffc020181c:	0c068693          	addi	a3,a3,192 # ffffffffc02068d8 <commands+0xbe0>
ffffffffc0201820:	00005617          	auipc	a2,0x5
ffffffffc0201824:	da060613          	addi	a2,a2,-608 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201828:	13700593          	li	a1,311
ffffffffc020182c:	00005517          	auipc	a0,0x5
ffffffffc0201830:	dac50513          	addi	a0,a0,-596 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201834:	c5bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(total == 0);
ffffffffc0201838:	00005697          	auipc	a3,0x5
ffffffffc020183c:	0d068693          	addi	a3,a3,208 # ffffffffc0206908 <commands+0xc10>
ffffffffc0201840:	00005617          	auipc	a2,0x5
ffffffffc0201844:	d8060613          	addi	a2,a2,-640 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201848:	14700593          	li	a1,327
ffffffffc020184c:	00005517          	auipc	a0,0x5
ffffffffc0201850:	d8c50513          	addi	a0,a0,-628 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201854:	c3bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(total == nr_free_pages());
ffffffffc0201858:	00005697          	auipc	a3,0x5
ffffffffc020185c:	d9868693          	addi	a3,a3,-616 # ffffffffc02065f0 <commands+0x8f8>
ffffffffc0201860:	00005617          	auipc	a2,0x5
ffffffffc0201864:	d6060613          	addi	a2,a2,-672 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201868:	11300593          	li	a1,275
ffffffffc020186c:	00005517          	auipc	a0,0x5
ffffffffc0201870:	d6c50513          	addi	a0,a0,-660 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201874:	c1bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201878:	00005697          	auipc	a3,0x5
ffffffffc020187c:	db868693          	addi	a3,a3,-584 # ffffffffc0206630 <commands+0x938>
ffffffffc0201880:	00005617          	auipc	a2,0x5
ffffffffc0201884:	d4060613          	addi	a2,a2,-704 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201888:	0d800593          	li	a1,216
ffffffffc020188c:	00005517          	auipc	a0,0x5
ffffffffc0201890:	d4c50513          	addi	a0,a0,-692 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201894:	bfbfe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201898 <default_free_pages>:
{
ffffffffc0201898:	1141                	addi	sp,sp,-16
ffffffffc020189a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020189c:	14058463          	beqz	a1,ffffffffc02019e4 <default_free_pages+0x14c>
    for (; p != base + n; p++)
ffffffffc02018a0:	00659693          	slli	a3,a1,0x6
ffffffffc02018a4:	96aa                	add	a3,a3,a0
ffffffffc02018a6:	87aa                	mv	a5,a0
ffffffffc02018a8:	02d50263          	beq	a0,a3,ffffffffc02018cc <default_free_pages+0x34>
ffffffffc02018ac:	6798                	ld	a4,8(a5)
ffffffffc02018ae:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02018b0:	10071a63          	bnez	a4,ffffffffc02019c4 <default_free_pages+0x12c>
ffffffffc02018b4:	6798                	ld	a4,8(a5)
ffffffffc02018b6:	8b09                	andi	a4,a4,2
ffffffffc02018b8:	10071663          	bnez	a4,ffffffffc02019c4 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc02018bc:	0007b423          	sd	zero,8(a5)
}

static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
ffffffffc02018c0:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02018c4:	04078793          	addi	a5,a5,64
ffffffffc02018c8:	fed792e3          	bne	a5,a3,ffffffffc02018ac <default_free_pages+0x14>
    base->property = n;
ffffffffc02018cc:	2581                	sext.w	a1,a1
ffffffffc02018ce:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02018d0:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02018d4:	4789                	li	a5,2
ffffffffc02018d6:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02018da:	000b2697          	auipc	a3,0xb2
ffffffffc02018de:	e8e68693          	addi	a3,a3,-370 # ffffffffc02b3768 <free_area>
ffffffffc02018e2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02018e4:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02018e6:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02018ea:	9db9                	addw	a1,a1,a4
ffffffffc02018ec:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc02018ee:	0ad78463          	beq	a5,a3,ffffffffc0201996 <default_free_pages+0xfe>
            struct Page *page = le2page(le, page_link);
ffffffffc02018f2:	fe878713          	addi	a4,a5,-24
ffffffffc02018f6:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc02018fa:	4581                	li	a1,0
            if (base < page)
ffffffffc02018fc:	00e56a63          	bltu	a0,a4,ffffffffc0201910 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0201900:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc0201902:	04d70c63          	beq	a4,a3,ffffffffc020195a <default_free_pages+0xc2>
    for (; p != base + n; p++)
ffffffffc0201906:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0201908:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc020190c:	fee57ae3          	bgeu	a0,a4,ffffffffc0201900 <default_free_pages+0x68>
ffffffffc0201910:	c199                	beqz	a1,ffffffffc0201916 <default_free_pages+0x7e>
ffffffffc0201912:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201916:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201918:	e390                	sd	a2,0(a5)
ffffffffc020191a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020191c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020191e:	ed18                	sd	a4,24(a0)
    if (le != &free_list)
ffffffffc0201920:	00d70d63          	beq	a4,a3,ffffffffc020193a <default_free_pages+0xa2>
        if (p + p->property == base)
ffffffffc0201924:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201928:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base)
ffffffffc020192c:	02059813          	slli	a6,a1,0x20
ffffffffc0201930:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201934:	97b2                	add	a5,a5,a2
ffffffffc0201936:	02f50c63          	beq	a0,a5,ffffffffc020196e <default_free_pages+0xd6>
    return listelm->next;
ffffffffc020193a:	711c                	ld	a5,32(a0)
    if (le != &free_list)
ffffffffc020193c:	00d78c63          	beq	a5,a3,ffffffffc0201954 <default_free_pages+0xbc>
        if (base + base->property == p)
ffffffffc0201940:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0201942:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p)
ffffffffc0201946:	02061593          	slli	a1,a2,0x20
ffffffffc020194a:	01a5d713          	srli	a4,a1,0x1a
ffffffffc020194e:	972a                	add	a4,a4,a0
ffffffffc0201950:	04e68a63          	beq	a3,a4,ffffffffc02019a4 <default_free_pages+0x10c>
}
ffffffffc0201954:	60a2                	ld	ra,8(sp)
ffffffffc0201956:	0141                	addi	sp,sp,16
ffffffffc0201958:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020195a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020195c:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020195e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201960:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc0201962:	02d70763          	beq	a4,a3,ffffffffc0201990 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc0201966:	8832                	mv	a6,a2
ffffffffc0201968:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc020196a:	87ba                	mv	a5,a4
ffffffffc020196c:	bf71                	j	ffffffffc0201908 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc020196e:	491c                	lw	a5,16(a0)
ffffffffc0201970:	9dbd                	addw	a1,a1,a5
ffffffffc0201972:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201976:	57f5                	li	a5,-3
ffffffffc0201978:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020197c:	01853803          	ld	a6,24(a0)
ffffffffc0201980:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0201982:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201984:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc0201988:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc020198a:	0105b023          	sd	a6,0(a1)
ffffffffc020198e:	b77d                	j	ffffffffc020193c <default_free_pages+0xa4>
ffffffffc0201990:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list)
ffffffffc0201992:	873e                	mv	a4,a5
ffffffffc0201994:	bf41                	j	ffffffffc0201924 <default_free_pages+0x8c>
}
ffffffffc0201996:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201998:	e390                	sd	a2,0(a5)
ffffffffc020199a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020199c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020199e:	ed1c                	sd	a5,24(a0)
ffffffffc02019a0:	0141                	addi	sp,sp,16
ffffffffc02019a2:	8082                	ret
            base->property += p->property;
ffffffffc02019a4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02019a8:	ff078693          	addi	a3,a5,-16
ffffffffc02019ac:	9e39                	addw	a2,a2,a4
ffffffffc02019ae:	c910                	sw	a2,16(a0)
ffffffffc02019b0:	5775                	li	a4,-3
ffffffffc02019b2:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02019b6:	6398                	ld	a4,0(a5)
ffffffffc02019b8:	679c                	ld	a5,8(a5)
}
ffffffffc02019ba:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02019bc:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02019be:	e398                	sd	a4,0(a5)
ffffffffc02019c0:	0141                	addi	sp,sp,16
ffffffffc02019c2:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02019c4:	00005697          	auipc	a3,0x5
ffffffffc02019c8:	f5c68693          	addi	a3,a3,-164 # ffffffffc0206920 <commands+0xc28>
ffffffffc02019cc:	00005617          	auipc	a2,0x5
ffffffffc02019d0:	bf460613          	addi	a2,a2,-1036 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02019d4:	09400593          	li	a1,148
ffffffffc02019d8:	00005517          	auipc	a0,0x5
ffffffffc02019dc:	c0050513          	addi	a0,a0,-1024 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc02019e0:	aaffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(n > 0);
ffffffffc02019e4:	00005697          	auipc	a3,0x5
ffffffffc02019e8:	f3468693          	addi	a3,a3,-204 # ffffffffc0206918 <commands+0xc20>
ffffffffc02019ec:	00005617          	auipc	a2,0x5
ffffffffc02019f0:	bd460613          	addi	a2,a2,-1068 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02019f4:	09000593          	li	a1,144
ffffffffc02019f8:	00005517          	auipc	a0,0x5
ffffffffc02019fc:	be050513          	addi	a0,a0,-1056 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201a00:	a8ffe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201a04 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201a04:	c941                	beqz	a0,ffffffffc0201a94 <default_alloc_pages+0x90>
    if (n > nr_free)
ffffffffc0201a06:	000b2597          	auipc	a1,0xb2
ffffffffc0201a0a:	d6258593          	addi	a1,a1,-670 # ffffffffc02b3768 <free_area>
ffffffffc0201a0e:	0105a803          	lw	a6,16(a1)
ffffffffc0201a12:	872a                	mv	a4,a0
ffffffffc0201a14:	02081793          	slli	a5,a6,0x20
ffffffffc0201a18:	9381                	srli	a5,a5,0x20
ffffffffc0201a1a:	00a7ee63          	bltu	a5,a0,ffffffffc0201a36 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201a1e:	87ae                	mv	a5,a1
ffffffffc0201a20:	a801                	j	ffffffffc0201a30 <default_alloc_pages+0x2c>
        if (p->property >= n)
ffffffffc0201a22:	ff87a683          	lw	a3,-8(a5)
ffffffffc0201a26:	02069613          	slli	a2,a3,0x20
ffffffffc0201a2a:	9201                	srli	a2,a2,0x20
ffffffffc0201a2c:	00e67763          	bgeu	a2,a4,ffffffffc0201a3a <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201a30:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc0201a32:	feb798e3          	bne	a5,a1,ffffffffc0201a22 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201a36:	4501                	li	a0,0
}
ffffffffc0201a38:	8082                	ret
    return listelm->prev;
ffffffffc0201a3a:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201a3e:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201a42:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0201a46:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0201a4a:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201a4e:	01133023          	sd	a7,0(t1)
        if (page->property > n)
ffffffffc0201a52:	02c77863          	bgeu	a4,a2,ffffffffc0201a82 <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc0201a56:	071a                	slli	a4,a4,0x6
ffffffffc0201a58:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201a5a:	41c686bb          	subw	a3,a3,t3
ffffffffc0201a5e:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201a60:	00870613          	addi	a2,a4,8
ffffffffc0201a64:	4689                	li	a3,2
ffffffffc0201a66:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201a6a:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201a6e:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0201a72:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201a76:	e290                	sd	a2,0(a3)
ffffffffc0201a78:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201a7c:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0201a7e:	01173c23          	sd	a7,24(a4)
ffffffffc0201a82:	41c8083b          	subw	a6,a6,t3
ffffffffc0201a86:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201a8a:	5775                	li	a4,-3
ffffffffc0201a8c:	17c1                	addi	a5,a5,-16
ffffffffc0201a8e:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201a92:	8082                	ret
{
ffffffffc0201a94:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201a96:	00005697          	auipc	a3,0x5
ffffffffc0201a9a:	e8268693          	addi	a3,a3,-382 # ffffffffc0206918 <commands+0xc20>
ffffffffc0201a9e:	00005617          	auipc	a2,0x5
ffffffffc0201aa2:	b2260613          	addi	a2,a2,-1246 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201aa6:	06c00593          	li	a1,108
ffffffffc0201aaa:	00005517          	auipc	a0,0x5
ffffffffc0201aae:	b2e50513          	addi	a0,a0,-1234 # ffffffffc02065d8 <commands+0x8e0>
{
ffffffffc0201ab2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201ab4:	9dbfe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201ab8 <default_init_memmap>:
{
ffffffffc0201ab8:	1141                	addi	sp,sp,-16
ffffffffc0201aba:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201abc:	c5f1                	beqz	a1,ffffffffc0201b88 <default_init_memmap+0xd0>
    for (; p != base + n; p++)
ffffffffc0201abe:	00659693          	slli	a3,a1,0x6
ffffffffc0201ac2:	96aa                	add	a3,a3,a0
ffffffffc0201ac4:	87aa                	mv	a5,a0
ffffffffc0201ac6:	00d50f63          	beq	a0,a3,ffffffffc0201ae4 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201aca:	6798                	ld	a4,8(a5)
ffffffffc0201acc:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc0201ace:	cf49                	beqz	a4,ffffffffc0201b68 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0201ad0:	0007a823          	sw	zero,16(a5)
ffffffffc0201ad4:	0007b423          	sd	zero,8(a5)
ffffffffc0201ad8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc0201adc:	04078793          	addi	a5,a5,64
ffffffffc0201ae0:	fed795e3          	bne	a5,a3,ffffffffc0201aca <default_init_memmap+0x12>
    base->property = n;
ffffffffc0201ae4:	2581                	sext.w	a1,a1
ffffffffc0201ae6:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201ae8:	4789                	li	a5,2
ffffffffc0201aea:	00850713          	addi	a4,a0,8
ffffffffc0201aee:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201af2:	000b2697          	auipc	a3,0xb2
ffffffffc0201af6:	c7668693          	addi	a3,a3,-906 # ffffffffc02b3768 <free_area>
ffffffffc0201afa:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201afc:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201afe:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201b02:	9db9                	addw	a1,a1,a4
ffffffffc0201b04:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc0201b06:	04d78a63          	beq	a5,a3,ffffffffc0201b5a <default_init_memmap+0xa2>
            struct Page *page = le2page(le, page_link);
ffffffffc0201b0a:	fe878713          	addi	a4,a5,-24
ffffffffc0201b0e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc0201b12:	4581                	li	a1,0
            if (base < page)
ffffffffc0201b14:	00e56a63          	bltu	a0,a4,ffffffffc0201b28 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0201b18:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc0201b1a:	02d70263          	beq	a4,a3,ffffffffc0201b3e <default_init_memmap+0x86>
    for (; p != base + n; p++)
ffffffffc0201b1e:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0201b20:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0201b24:	fee57ae3          	bgeu	a0,a4,ffffffffc0201b18 <default_init_memmap+0x60>
ffffffffc0201b28:	c199                	beqz	a1,ffffffffc0201b2e <default_init_memmap+0x76>
ffffffffc0201b2a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201b2e:	6398                	ld	a4,0(a5)
}
ffffffffc0201b30:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201b32:	e390                	sd	a2,0(a5)
ffffffffc0201b34:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201b36:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201b38:	ed18                	sd	a4,24(a0)
ffffffffc0201b3a:	0141                	addi	sp,sp,16
ffffffffc0201b3c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201b3e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201b40:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201b42:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201b44:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc0201b46:	00d70663          	beq	a4,a3,ffffffffc0201b52 <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0201b4a:	8832                	mv	a6,a2
ffffffffc0201b4c:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc0201b4e:	87ba                	mv	a5,a4
ffffffffc0201b50:	bfc1                	j	ffffffffc0201b20 <default_init_memmap+0x68>
}
ffffffffc0201b52:	60a2                	ld	ra,8(sp)
ffffffffc0201b54:	e290                	sd	a2,0(a3)
ffffffffc0201b56:	0141                	addi	sp,sp,16
ffffffffc0201b58:	8082                	ret
ffffffffc0201b5a:	60a2                	ld	ra,8(sp)
ffffffffc0201b5c:	e390                	sd	a2,0(a5)
ffffffffc0201b5e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201b60:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201b62:	ed1c                	sd	a5,24(a0)
ffffffffc0201b64:	0141                	addi	sp,sp,16
ffffffffc0201b66:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201b68:	00005697          	auipc	a3,0x5
ffffffffc0201b6c:	de068693          	addi	a3,a3,-544 # ffffffffc0206948 <commands+0xc50>
ffffffffc0201b70:	00005617          	auipc	a2,0x5
ffffffffc0201b74:	a5060613          	addi	a2,a2,-1456 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201b78:	04b00593          	li	a1,75
ffffffffc0201b7c:	00005517          	auipc	a0,0x5
ffffffffc0201b80:	a5c50513          	addi	a0,a0,-1444 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201b84:	90bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(n > 0);
ffffffffc0201b88:	00005697          	auipc	a3,0x5
ffffffffc0201b8c:	d9068693          	addi	a3,a3,-624 # ffffffffc0206918 <commands+0xc20>
ffffffffc0201b90:	00005617          	auipc	a2,0x5
ffffffffc0201b94:	a3060613          	addi	a2,a2,-1488 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201b98:	04700593          	li	a1,71
ffffffffc0201b9c:	00005517          	auipc	a0,0x5
ffffffffc0201ba0:	a3c50513          	addi	a0,a0,-1476 # ffffffffc02065d8 <commands+0x8e0>
ffffffffc0201ba4:	8ebfe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201ba8 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201ba8:	c94d                	beqz	a0,ffffffffc0201c5a <slob_free+0xb2>
{
ffffffffc0201baa:	1141                	addi	sp,sp,-16
ffffffffc0201bac:	e022                	sd	s0,0(sp)
ffffffffc0201bae:	e406                	sd	ra,8(sp)
ffffffffc0201bb0:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc0201bb2:	e9c1                	bnez	a1,ffffffffc0201c42 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201bb4:	100027f3          	csrr	a5,sstatus
ffffffffc0201bb8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201bba:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201bbc:	ebd9                	bnez	a5,ffffffffc0201c52 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201bbe:	000b1617          	auipc	a2,0xb1
ffffffffc0201bc2:	79a60613          	addi	a2,a2,1946 # ffffffffc02b3358 <slobfree>
ffffffffc0201bc6:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201bc8:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201bca:	679c                	ld	a5,8(a5)
ffffffffc0201bcc:	02877a63          	bgeu	a4,s0,ffffffffc0201c00 <slob_free+0x58>
ffffffffc0201bd0:	00f46463          	bltu	s0,a5,ffffffffc0201bd8 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201bd4:	fef76ae3          	bltu	a4,a5,ffffffffc0201bc8 <slob_free+0x20>
			break;

	if (b + b->units == cur->next)
ffffffffc0201bd8:	400c                	lw	a1,0(s0)
ffffffffc0201bda:	00459693          	slli	a3,a1,0x4
ffffffffc0201bde:	96a2                	add	a3,a3,s0
ffffffffc0201be0:	02d78a63          	beq	a5,a3,ffffffffc0201c14 <slob_free+0x6c>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc0201be4:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0201be6:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0201be8:	00469793          	slli	a5,a3,0x4
ffffffffc0201bec:	97ba                	add	a5,a5,a4
ffffffffc0201bee:	02f40e63          	beq	s0,a5,ffffffffc0201c2a <slob_free+0x82>
	{
		cur->units += b->units;
		cur->next = b->next;
	}
	else
		cur->next = b;
ffffffffc0201bf2:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0201bf4:	e218                	sd	a4,0(a2)
    if (flag)
ffffffffc0201bf6:	e129                	bnez	a0,ffffffffc0201c38 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201bf8:	60a2                	ld	ra,8(sp)
ffffffffc0201bfa:	6402                	ld	s0,0(sp)
ffffffffc0201bfc:	0141                	addi	sp,sp,16
ffffffffc0201bfe:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201c00:	fcf764e3          	bltu	a4,a5,ffffffffc0201bc8 <slob_free+0x20>
ffffffffc0201c04:	fcf472e3          	bgeu	s0,a5,ffffffffc0201bc8 <slob_free+0x20>
	if (b + b->units == cur->next)
ffffffffc0201c08:	400c                	lw	a1,0(s0)
ffffffffc0201c0a:	00459693          	slli	a3,a1,0x4
ffffffffc0201c0e:	96a2                	add	a3,a3,s0
ffffffffc0201c10:	fcd79ae3          	bne	a5,a3,ffffffffc0201be4 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0201c14:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201c16:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201c18:	9db5                	addw	a1,a1,a3
ffffffffc0201c1a:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b)
ffffffffc0201c1c:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201c1e:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0201c20:	00469793          	slli	a5,a3,0x4
ffffffffc0201c24:	97ba                	add	a5,a5,a4
ffffffffc0201c26:	fcf416e3          	bne	s0,a5,ffffffffc0201bf2 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0201c2a:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201c2c:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0201c2e:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201c30:	9ebd                	addw	a3,a3,a5
ffffffffc0201c32:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0201c34:	e70c                	sd	a1,8(a4)
ffffffffc0201c36:	d169                	beqz	a0,ffffffffc0201bf8 <slob_free+0x50>
}
ffffffffc0201c38:	6402                	ld	s0,0(sp)
ffffffffc0201c3a:	60a2                	ld	ra,8(sp)
ffffffffc0201c3c:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201c3e:	d71fe06f          	j	ffffffffc02009ae <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0201c42:	25bd                	addiw	a1,a1,15
ffffffffc0201c44:	8191                	srli	a1,a1,0x4
ffffffffc0201c46:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201c48:	100027f3          	csrr	a5,sstatus
ffffffffc0201c4c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201c4e:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201c50:	d7bd                	beqz	a5,ffffffffc0201bbe <slob_free+0x16>
        intr_disable();
ffffffffc0201c52:	d63fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc0201c56:	4505                	li	a0,1
ffffffffc0201c58:	b79d                	j	ffffffffc0201bbe <slob_free+0x16>
ffffffffc0201c5a:	8082                	ret

ffffffffc0201c5c <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201c5c:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201c5e:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201c60:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201c64:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201c66:	352000ef          	jal	ra,ffffffffc0201fb8 <alloc_pages>
	if (!page)
ffffffffc0201c6a:	c91d                	beqz	a0,ffffffffc0201ca0 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201c6c:	000b6697          	auipc	a3,0xb6
ffffffffc0201c70:	b746b683          	ld	a3,-1164(a3) # ffffffffc02b77e0 <pages>
ffffffffc0201c74:	8d15                	sub	a0,a0,a3
ffffffffc0201c76:	8519                	srai	a0,a0,0x6
ffffffffc0201c78:	00006697          	auipc	a3,0x6
ffffffffc0201c7c:	0a86b683          	ld	a3,168(a3) # ffffffffc0207d20 <nbase>
ffffffffc0201c80:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201c82:	00c51793          	slli	a5,a0,0xc
ffffffffc0201c86:	83b1                	srli	a5,a5,0xc
ffffffffc0201c88:	000b6717          	auipc	a4,0xb6
ffffffffc0201c8c:	b5073703          	ld	a4,-1200(a4) # ffffffffc02b77d8 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c90:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201c92:	00e7fa63          	bgeu	a5,a4,ffffffffc0201ca6 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201c96:	000b6697          	auipc	a3,0xb6
ffffffffc0201c9a:	b5a6b683          	ld	a3,-1190(a3) # ffffffffc02b77f0 <va_pa_offset>
ffffffffc0201c9e:	9536                	add	a0,a0,a3
}
ffffffffc0201ca0:	60a2                	ld	ra,8(sp)
ffffffffc0201ca2:	0141                	addi	sp,sp,16
ffffffffc0201ca4:	8082                	ret
ffffffffc0201ca6:	86aa                	mv	a3,a0
ffffffffc0201ca8:	00005617          	auipc	a2,0x5
ffffffffc0201cac:	d0060613          	addi	a2,a2,-768 # ffffffffc02069a8 <default_pmm_manager+0x38>
ffffffffc0201cb0:	07700593          	li	a1,119
ffffffffc0201cb4:	00005517          	auipc	a0,0x5
ffffffffc0201cb8:	d1c50513          	addi	a0,a0,-740 # ffffffffc02069d0 <default_pmm_manager+0x60>
ffffffffc0201cbc:	fd2fe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201cc0 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201cc0:	1101                	addi	sp,sp,-32
ffffffffc0201cc2:	ec06                	sd	ra,24(sp)
ffffffffc0201cc4:	e822                	sd	s0,16(sp)
ffffffffc0201cc6:	e426                	sd	s1,8(sp)
ffffffffc0201cc8:	e04a                	sd	s2,0(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201cca:	01050713          	addi	a4,a0,16
ffffffffc0201cce:	6785                	lui	a5,0x1
ffffffffc0201cd0:	0cf77363          	bgeu	a4,a5,ffffffffc0201d96 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201cd4:	00f50493          	addi	s1,a0,15
ffffffffc0201cd8:	8091                	srli	s1,s1,0x4
ffffffffc0201cda:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201cdc:	10002673          	csrr	a2,sstatus
ffffffffc0201ce0:	8a09                	andi	a2,a2,2
ffffffffc0201ce2:	e25d                	bnez	a2,ffffffffc0201d88 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201ce4:	000b1917          	auipc	s2,0xb1
ffffffffc0201ce8:	67490913          	addi	s2,s2,1652 # ffffffffc02b3358 <slobfree>
ffffffffc0201cec:	00093683          	ld	a3,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201cf0:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta)
ffffffffc0201cf2:	4398                	lw	a4,0(a5)
ffffffffc0201cf4:	08975e63          	bge	a4,s1,ffffffffc0201d90 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree)
ffffffffc0201cf8:	00f68b63          	beq	a3,a5,ffffffffc0201d0e <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201cfc:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201cfe:	4018                	lw	a4,0(s0)
ffffffffc0201d00:	02975a63          	bge	a4,s1,ffffffffc0201d34 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree)
ffffffffc0201d04:	00093683          	ld	a3,0(s2)
ffffffffc0201d08:	87a2                	mv	a5,s0
ffffffffc0201d0a:	fef699e3          	bne	a3,a5,ffffffffc0201cfc <slob_alloc.constprop.0+0x3c>
    if (flag)
ffffffffc0201d0e:	ee31                	bnez	a2,ffffffffc0201d6a <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201d10:	4501                	li	a0,0
ffffffffc0201d12:	f4bff0ef          	jal	ra,ffffffffc0201c5c <__slob_get_free_pages.constprop.0>
ffffffffc0201d16:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201d18:	cd05                	beqz	a0,ffffffffc0201d50 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201d1a:	6585                	lui	a1,0x1
ffffffffc0201d1c:	e8dff0ef          	jal	ra,ffffffffc0201ba8 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201d20:	10002673          	csrr	a2,sstatus
ffffffffc0201d24:	8a09                	andi	a2,a2,2
ffffffffc0201d26:	ee05                	bnez	a2,ffffffffc0201d5e <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201d28:	00093783          	ld	a5,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201d2c:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201d2e:	4018                	lw	a4,0(s0)
ffffffffc0201d30:	fc974ae3          	blt	a4,s1,ffffffffc0201d04 <slob_alloc.constprop.0+0x44>
			if (cur->units == units)	/* exact fit? */
ffffffffc0201d34:	04e48763          	beq	s1,a4,ffffffffc0201d82 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201d38:	00449693          	slli	a3,s1,0x4
ffffffffc0201d3c:	96a2                	add	a3,a3,s0
ffffffffc0201d3e:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201d40:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201d42:	9f05                	subw	a4,a4,s1
ffffffffc0201d44:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201d46:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201d48:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201d4a:	00f93023          	sd	a5,0(s2)
    if (flag)
ffffffffc0201d4e:	e20d                	bnez	a2,ffffffffc0201d70 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201d50:	60e2                	ld	ra,24(sp)
ffffffffc0201d52:	8522                	mv	a0,s0
ffffffffc0201d54:	6442                	ld	s0,16(sp)
ffffffffc0201d56:	64a2                	ld	s1,8(sp)
ffffffffc0201d58:	6902                	ld	s2,0(sp)
ffffffffc0201d5a:	6105                	addi	sp,sp,32
ffffffffc0201d5c:	8082                	ret
        intr_disable();
ffffffffc0201d5e:	c57fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
			cur = slobfree;
ffffffffc0201d62:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201d66:	4605                	li	a2,1
ffffffffc0201d68:	b7d1                	j	ffffffffc0201d2c <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201d6a:	c45fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0201d6e:	b74d                	j	ffffffffc0201d10 <slob_alloc.constprop.0+0x50>
ffffffffc0201d70:	c3ffe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
}
ffffffffc0201d74:	60e2                	ld	ra,24(sp)
ffffffffc0201d76:	8522                	mv	a0,s0
ffffffffc0201d78:	6442                	ld	s0,16(sp)
ffffffffc0201d7a:	64a2                	ld	s1,8(sp)
ffffffffc0201d7c:	6902                	ld	s2,0(sp)
ffffffffc0201d7e:	6105                	addi	sp,sp,32
ffffffffc0201d80:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201d82:	6418                	ld	a4,8(s0)
ffffffffc0201d84:	e798                	sd	a4,8(a5)
ffffffffc0201d86:	b7d1                	j	ffffffffc0201d4a <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201d88:	c2dfe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc0201d8c:	4605                	li	a2,1
ffffffffc0201d8e:	bf99                	j	ffffffffc0201ce4 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta)
ffffffffc0201d90:	843e                	mv	s0,a5
ffffffffc0201d92:	87b6                	mv	a5,a3
ffffffffc0201d94:	b745                	j	ffffffffc0201d34 <slob_alloc.constprop.0+0x74>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201d96:	00005697          	auipc	a3,0x5
ffffffffc0201d9a:	c4a68693          	addi	a3,a3,-950 # ffffffffc02069e0 <default_pmm_manager+0x70>
ffffffffc0201d9e:	00005617          	auipc	a2,0x5
ffffffffc0201da2:	82260613          	addi	a2,a2,-2014 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0201da6:	06300593          	li	a1,99
ffffffffc0201daa:	00005517          	auipc	a0,0x5
ffffffffc0201dae:	c5650513          	addi	a0,a0,-938 # ffffffffc0206a00 <default_pmm_manager+0x90>
ffffffffc0201db2:	edcfe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201db6 <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc0201db6:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc0201db8:	00005517          	auipc	a0,0x5
ffffffffc0201dbc:	c6050513          	addi	a0,a0,-928 # ffffffffc0206a18 <default_pmm_manager+0xa8>
{
ffffffffc0201dc0:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc0201dc2:	bd2fe0ef          	jal	ra,ffffffffc0200194 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201dc6:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201dc8:	00005517          	auipc	a0,0x5
ffffffffc0201dcc:	c6850513          	addi	a0,a0,-920 # ffffffffc0206a30 <default_pmm_manager+0xc0>
}
ffffffffc0201dd0:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201dd2:	bc2fe06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0201dd6 <kallocated>:

size_t
kallocated(void)
{
	return slob_allocated();
}
ffffffffc0201dd6:	4501                	li	a0,0
ffffffffc0201dd8:	8082                	ret

ffffffffc0201dda <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201dda:	1101                	addi	sp,sp,-32
ffffffffc0201ddc:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201dde:	6905                	lui	s2,0x1
{
ffffffffc0201de0:	e822                	sd	s0,16(sp)
ffffffffc0201de2:	ec06                	sd	ra,24(sp)
ffffffffc0201de4:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201de6:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bc1>
{
ffffffffc0201dea:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201dec:	04a7f963          	bgeu	a5,a0,ffffffffc0201e3e <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201df0:	4561                	li	a0,24
ffffffffc0201df2:	ecfff0ef          	jal	ra,ffffffffc0201cc0 <slob_alloc.constprop.0>
ffffffffc0201df6:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201df8:	c929                	beqz	a0,ffffffffc0201e4a <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201dfa:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201dfe:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc0201e00:	00f95763          	bge	s2,a5,ffffffffc0201e0e <kmalloc+0x34>
ffffffffc0201e04:	6705                	lui	a4,0x1
ffffffffc0201e06:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201e08:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc0201e0a:	fef74ee3          	blt	a4,a5,ffffffffc0201e06 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201e0e:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201e10:	e4dff0ef          	jal	ra,ffffffffc0201c5c <__slob_get_free_pages.constprop.0>
ffffffffc0201e14:	e488                	sd	a0,8(s1)
ffffffffc0201e16:	842a                	mv	s0,a0
	if (bb->pages)
ffffffffc0201e18:	c525                	beqz	a0,ffffffffc0201e80 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201e1a:	100027f3          	csrr	a5,sstatus
ffffffffc0201e1e:	8b89                	andi	a5,a5,2
ffffffffc0201e20:	ef8d                	bnez	a5,ffffffffc0201e5a <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201e22:	000b6797          	auipc	a5,0xb6
ffffffffc0201e26:	99e78793          	addi	a5,a5,-1634 # ffffffffc02b77c0 <bigblocks>
ffffffffc0201e2a:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201e2c:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201e2e:	e898                	sd	a4,16(s1)
	return __kmalloc(size, 0);
}
ffffffffc0201e30:	60e2                	ld	ra,24(sp)
ffffffffc0201e32:	8522                	mv	a0,s0
ffffffffc0201e34:	6442                	ld	s0,16(sp)
ffffffffc0201e36:	64a2                	ld	s1,8(sp)
ffffffffc0201e38:	6902                	ld	s2,0(sp)
ffffffffc0201e3a:	6105                	addi	sp,sp,32
ffffffffc0201e3c:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201e3e:	0541                	addi	a0,a0,16
ffffffffc0201e40:	e81ff0ef          	jal	ra,ffffffffc0201cc0 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201e44:	01050413          	addi	s0,a0,16
ffffffffc0201e48:	f565                	bnez	a0,ffffffffc0201e30 <kmalloc+0x56>
ffffffffc0201e4a:	4401                	li	s0,0
}
ffffffffc0201e4c:	60e2                	ld	ra,24(sp)
ffffffffc0201e4e:	8522                	mv	a0,s0
ffffffffc0201e50:	6442                	ld	s0,16(sp)
ffffffffc0201e52:	64a2                	ld	s1,8(sp)
ffffffffc0201e54:	6902                	ld	s2,0(sp)
ffffffffc0201e56:	6105                	addi	sp,sp,32
ffffffffc0201e58:	8082                	ret
        intr_disable();
ffffffffc0201e5a:	b5bfe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201e5e:	000b6797          	auipc	a5,0xb6
ffffffffc0201e62:	96278793          	addi	a5,a5,-1694 # ffffffffc02b77c0 <bigblocks>
ffffffffc0201e66:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201e68:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201e6a:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201e6c:	b43fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
		return bb->pages;
ffffffffc0201e70:	6480                	ld	s0,8(s1)
}
ffffffffc0201e72:	60e2                	ld	ra,24(sp)
ffffffffc0201e74:	64a2                	ld	s1,8(sp)
ffffffffc0201e76:	8522                	mv	a0,s0
ffffffffc0201e78:	6442                	ld	s0,16(sp)
ffffffffc0201e7a:	6902                	ld	s2,0(sp)
ffffffffc0201e7c:	6105                	addi	sp,sp,32
ffffffffc0201e7e:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201e80:	45e1                	li	a1,24
ffffffffc0201e82:	8526                	mv	a0,s1
ffffffffc0201e84:	d25ff0ef          	jal	ra,ffffffffc0201ba8 <slob_free>
	return __kmalloc(size, 0);
ffffffffc0201e88:	b765                	j	ffffffffc0201e30 <kmalloc+0x56>

ffffffffc0201e8a <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201e8a:	c169                	beqz	a0,ffffffffc0201f4c <kfree+0xc2>
{
ffffffffc0201e8c:	1101                	addi	sp,sp,-32
ffffffffc0201e8e:	e822                	sd	s0,16(sp)
ffffffffc0201e90:	ec06                	sd	ra,24(sp)
ffffffffc0201e92:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201e94:	03451793          	slli	a5,a0,0x34
ffffffffc0201e98:	842a                	mv	s0,a0
ffffffffc0201e9a:	e3d9                	bnez	a5,ffffffffc0201f20 <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201e9c:	100027f3          	csrr	a5,sstatus
ffffffffc0201ea0:	8b89                	andi	a5,a5,2
ffffffffc0201ea2:	e7d9                	bnez	a5,ffffffffc0201f30 <kfree+0xa6>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201ea4:	000b6797          	auipc	a5,0xb6
ffffffffc0201ea8:	91c7b783          	ld	a5,-1764(a5) # ffffffffc02b77c0 <bigblocks>
    return 0;
ffffffffc0201eac:	4601                	li	a2,0
ffffffffc0201eae:	cbad                	beqz	a5,ffffffffc0201f20 <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201eb0:	000b6697          	auipc	a3,0xb6
ffffffffc0201eb4:	91068693          	addi	a3,a3,-1776 # ffffffffc02b77c0 <bigblocks>
ffffffffc0201eb8:	a021                	j	ffffffffc0201ec0 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201eba:	01048693          	addi	a3,s1,16
ffffffffc0201ebe:	c3a5                	beqz	a5,ffffffffc0201f1e <kfree+0x94>
		{
			if (bb->pages == block)
ffffffffc0201ec0:	6798                	ld	a4,8(a5)
ffffffffc0201ec2:	84be                	mv	s1,a5
			{
				*last = bb->next;
ffffffffc0201ec4:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc0201ec6:	fe871ae3          	bne	a4,s0,ffffffffc0201eba <kfree+0x30>
				*last = bb->next;
ffffffffc0201eca:	e29c                	sd	a5,0(a3)
    if (flag)
ffffffffc0201ecc:	ee2d                	bnez	a2,ffffffffc0201f46 <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201ece:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201ed2:	4098                	lw	a4,0(s1)
ffffffffc0201ed4:	08f46963          	bltu	s0,a5,ffffffffc0201f66 <kfree+0xdc>
ffffffffc0201ed8:	000b6697          	auipc	a3,0xb6
ffffffffc0201edc:	9186b683          	ld	a3,-1768(a3) # ffffffffc02b77f0 <va_pa_offset>
ffffffffc0201ee0:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage)
ffffffffc0201ee2:	8031                	srli	s0,s0,0xc
ffffffffc0201ee4:	000b6797          	auipc	a5,0xb6
ffffffffc0201ee8:	8f47b783          	ld	a5,-1804(a5) # ffffffffc02b77d8 <npage>
ffffffffc0201eec:	06f47163          	bgeu	s0,a5,ffffffffc0201f4e <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ef0:	00006517          	auipc	a0,0x6
ffffffffc0201ef4:	e3053503          	ld	a0,-464(a0) # ffffffffc0207d20 <nbase>
ffffffffc0201ef8:	8c09                	sub	s0,s0,a0
ffffffffc0201efa:	041a                	slli	s0,s0,0x6
	free_pages(kva2page(kva), 1 << order);
ffffffffc0201efc:	000b6517          	auipc	a0,0xb6
ffffffffc0201f00:	8e453503          	ld	a0,-1820(a0) # ffffffffc02b77e0 <pages>
ffffffffc0201f04:	4585                	li	a1,1
ffffffffc0201f06:	9522                	add	a0,a0,s0
ffffffffc0201f08:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201f0c:	0ea000ef          	jal	ra,ffffffffc0201ff6 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201f10:	6442                	ld	s0,16(sp)
ffffffffc0201f12:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201f14:	8526                	mv	a0,s1
}
ffffffffc0201f16:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201f18:	45e1                	li	a1,24
}
ffffffffc0201f1a:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201f1c:	b171                	j	ffffffffc0201ba8 <slob_free>
ffffffffc0201f1e:	e20d                	bnez	a2,ffffffffc0201f40 <kfree+0xb6>
ffffffffc0201f20:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201f24:	6442                	ld	s0,16(sp)
ffffffffc0201f26:	60e2                	ld	ra,24(sp)
ffffffffc0201f28:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201f2a:	4581                	li	a1,0
}
ffffffffc0201f2c:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201f2e:	b9ad                	j	ffffffffc0201ba8 <slob_free>
        intr_disable();
ffffffffc0201f30:	a85fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201f34:	000b6797          	auipc	a5,0xb6
ffffffffc0201f38:	88c7b783          	ld	a5,-1908(a5) # ffffffffc02b77c0 <bigblocks>
        return 1;
ffffffffc0201f3c:	4605                	li	a2,1
ffffffffc0201f3e:	fbad                	bnez	a5,ffffffffc0201eb0 <kfree+0x26>
        intr_enable();
ffffffffc0201f40:	a6ffe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0201f44:	bff1                	j	ffffffffc0201f20 <kfree+0x96>
ffffffffc0201f46:	a69fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0201f4a:	b751                	j	ffffffffc0201ece <kfree+0x44>
ffffffffc0201f4c:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201f4e:	00005617          	auipc	a2,0x5
ffffffffc0201f52:	b2a60613          	addi	a2,a2,-1238 # ffffffffc0206a78 <default_pmm_manager+0x108>
ffffffffc0201f56:	06f00593          	li	a1,111
ffffffffc0201f5a:	00005517          	auipc	a0,0x5
ffffffffc0201f5e:	a7650513          	addi	a0,a0,-1418 # ffffffffc02069d0 <default_pmm_manager+0x60>
ffffffffc0201f62:	d2cfe0ef          	jal	ra,ffffffffc020048e <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201f66:	86a2                	mv	a3,s0
ffffffffc0201f68:	00005617          	auipc	a2,0x5
ffffffffc0201f6c:	ae860613          	addi	a2,a2,-1304 # ffffffffc0206a50 <default_pmm_manager+0xe0>
ffffffffc0201f70:	07d00593          	li	a1,125
ffffffffc0201f74:	00005517          	auipc	a0,0x5
ffffffffc0201f78:	a5c50513          	addi	a0,a0,-1444 # ffffffffc02069d0 <default_pmm_manager+0x60>
ffffffffc0201f7c:	d12fe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201f80 <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc0201f80:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201f82:	00005617          	auipc	a2,0x5
ffffffffc0201f86:	af660613          	addi	a2,a2,-1290 # ffffffffc0206a78 <default_pmm_manager+0x108>
ffffffffc0201f8a:	06f00593          	li	a1,111
ffffffffc0201f8e:	00005517          	auipc	a0,0x5
ffffffffc0201f92:	a4250513          	addi	a0,a0,-1470 # ffffffffc02069d0 <default_pmm_manager+0x60>
pa2page(uintptr_t pa)
ffffffffc0201f96:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201f98:	cf6fe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201f9c <pte2page.part.0>:
pte2page(pte_t pte)
ffffffffc0201f9c:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201f9e:	00005617          	auipc	a2,0x5
ffffffffc0201fa2:	afa60613          	addi	a2,a2,-1286 # ffffffffc0206a98 <default_pmm_manager+0x128>
ffffffffc0201fa6:	08500593          	li	a1,133
ffffffffc0201faa:	00005517          	auipc	a0,0x5
ffffffffc0201fae:	a2650513          	addi	a0,a0,-1498 # ffffffffc02069d0 <default_pmm_manager+0x60>
pte2page(pte_t pte)
ffffffffc0201fb2:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201fb4:	cdafe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201fb8 <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201fb8:	100027f3          	csrr	a5,sstatus
ffffffffc0201fbc:	8b89                	andi	a5,a5,2
ffffffffc0201fbe:	e799                	bnez	a5,ffffffffc0201fcc <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201fc0:	000b6797          	auipc	a5,0xb6
ffffffffc0201fc4:	8287b783          	ld	a5,-2008(a5) # ffffffffc02b77e8 <pmm_manager>
ffffffffc0201fc8:	6f9c                	ld	a5,24(a5)
ffffffffc0201fca:	8782                	jr	a5
{
ffffffffc0201fcc:	1141                	addi	sp,sp,-16
ffffffffc0201fce:	e406                	sd	ra,8(sp)
ffffffffc0201fd0:	e022                	sd	s0,0(sp)
ffffffffc0201fd2:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201fd4:	9e1fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201fd8:	000b6797          	auipc	a5,0xb6
ffffffffc0201fdc:	8107b783          	ld	a5,-2032(a5) # ffffffffc02b77e8 <pmm_manager>
ffffffffc0201fe0:	6f9c                	ld	a5,24(a5)
ffffffffc0201fe2:	8522                	mv	a0,s0
ffffffffc0201fe4:	9782                	jalr	a5
ffffffffc0201fe6:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201fe8:	9c7fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201fec:	60a2                	ld	ra,8(sp)
ffffffffc0201fee:	8522                	mv	a0,s0
ffffffffc0201ff0:	6402                	ld	s0,0(sp)
ffffffffc0201ff2:	0141                	addi	sp,sp,16
ffffffffc0201ff4:	8082                	ret

ffffffffc0201ff6 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201ff6:	100027f3          	csrr	a5,sstatus
ffffffffc0201ffa:	8b89                	andi	a5,a5,2
ffffffffc0201ffc:	e799                	bnez	a5,ffffffffc020200a <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201ffe:	000b5797          	auipc	a5,0xb5
ffffffffc0202002:	7ea7b783          	ld	a5,2026(a5) # ffffffffc02b77e8 <pmm_manager>
ffffffffc0202006:	739c                	ld	a5,32(a5)
ffffffffc0202008:	8782                	jr	a5
{
ffffffffc020200a:	1101                	addi	sp,sp,-32
ffffffffc020200c:	ec06                	sd	ra,24(sp)
ffffffffc020200e:	e822                	sd	s0,16(sp)
ffffffffc0202010:	e426                	sd	s1,8(sp)
ffffffffc0202012:	842a                	mv	s0,a0
ffffffffc0202014:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0202016:	99ffe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020201a:	000b5797          	auipc	a5,0xb5
ffffffffc020201e:	7ce7b783          	ld	a5,1998(a5) # ffffffffc02b77e8 <pmm_manager>
ffffffffc0202022:	739c                	ld	a5,32(a5)
ffffffffc0202024:	85a6                	mv	a1,s1
ffffffffc0202026:	8522                	mv	a0,s0
ffffffffc0202028:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020202a:	6442                	ld	s0,16(sp)
ffffffffc020202c:	60e2                	ld	ra,24(sp)
ffffffffc020202e:	64a2                	ld	s1,8(sp)
ffffffffc0202030:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202032:	97dfe06f          	j	ffffffffc02009ae <intr_enable>

ffffffffc0202036 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202036:	100027f3          	csrr	a5,sstatus
ffffffffc020203a:	8b89                	andi	a5,a5,2
ffffffffc020203c:	e799                	bnez	a5,ffffffffc020204a <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc020203e:	000b5797          	auipc	a5,0xb5
ffffffffc0202042:	7aa7b783          	ld	a5,1962(a5) # ffffffffc02b77e8 <pmm_manager>
ffffffffc0202046:	779c                	ld	a5,40(a5)
ffffffffc0202048:	8782                	jr	a5
{
ffffffffc020204a:	1141                	addi	sp,sp,-16
ffffffffc020204c:	e406                	sd	ra,8(sp)
ffffffffc020204e:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0202050:	965fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202054:	000b5797          	auipc	a5,0xb5
ffffffffc0202058:	7947b783          	ld	a5,1940(a5) # ffffffffc02b77e8 <pmm_manager>
ffffffffc020205c:	779c                	ld	a5,40(a5)
ffffffffc020205e:	9782                	jalr	a5
ffffffffc0202060:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202062:	94dfe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202066:	60a2                	ld	ra,8(sp)
ffffffffc0202068:	8522                	mv	a0,s0
ffffffffc020206a:	6402                	ld	s0,0(sp)
ffffffffc020206c:	0141                	addi	sp,sp,16
ffffffffc020206e:	8082                	ret

ffffffffc0202070 <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202070:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0202074:	1ff7f793          	andi	a5,a5,511
{
ffffffffc0202078:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020207a:	078e                	slli	a5,a5,0x3
{
ffffffffc020207c:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020207e:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc0202082:	6094                	ld	a3,0(s1)
{
ffffffffc0202084:	f04a                	sd	s2,32(sp)
ffffffffc0202086:	ec4e                	sd	s3,24(sp)
ffffffffc0202088:	e852                	sd	s4,16(sp)
ffffffffc020208a:	fc06                	sd	ra,56(sp)
ffffffffc020208c:	f822                	sd	s0,48(sp)
ffffffffc020208e:	e456                	sd	s5,8(sp)
ffffffffc0202090:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc0202092:	0016f793          	andi	a5,a3,1
{
ffffffffc0202096:	892e                	mv	s2,a1
ffffffffc0202098:	8a32                	mv	s4,a2
ffffffffc020209a:	000b5997          	auipc	s3,0xb5
ffffffffc020209e:	73e98993          	addi	s3,s3,1854 # ffffffffc02b77d8 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc02020a2:	efbd                	bnez	a5,ffffffffc0202120 <get_pte+0xb0>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc02020a4:	14060c63          	beqz	a2,ffffffffc02021fc <get_pte+0x18c>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02020a8:	100027f3          	csrr	a5,sstatus
ffffffffc02020ac:	8b89                	andi	a5,a5,2
ffffffffc02020ae:	14079963          	bnez	a5,ffffffffc0202200 <get_pte+0x190>
        page = pmm_manager->alloc_pages(n);
ffffffffc02020b2:	000b5797          	auipc	a5,0xb5
ffffffffc02020b6:	7367b783          	ld	a5,1846(a5) # ffffffffc02b77e8 <pmm_manager>
ffffffffc02020ba:	6f9c                	ld	a5,24(a5)
ffffffffc02020bc:	4505                	li	a0,1
ffffffffc02020be:	9782                	jalr	a5
ffffffffc02020c0:	842a                	mv	s0,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc02020c2:	12040d63          	beqz	s0,ffffffffc02021fc <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc02020c6:	000b5b17          	auipc	s6,0xb5
ffffffffc02020ca:	71ab0b13          	addi	s6,s6,1818 # ffffffffc02b77e0 <pages>
ffffffffc02020ce:	000b3503          	ld	a0,0(s6)
ffffffffc02020d2:	00080ab7          	lui	s5,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020d6:	000b5997          	auipc	s3,0xb5
ffffffffc02020da:	70298993          	addi	s3,s3,1794 # ffffffffc02b77d8 <npage>
ffffffffc02020de:	40a40533          	sub	a0,s0,a0
ffffffffc02020e2:	8519                	srai	a0,a0,0x6
ffffffffc02020e4:	9556                	add	a0,a0,s5
ffffffffc02020e6:	0009b703          	ld	a4,0(s3)
ffffffffc02020ea:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc02020ee:	4685                	li	a3,1
ffffffffc02020f0:	c014                	sw	a3,0(s0)
ffffffffc02020f2:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02020f4:	0532                	slli	a0,a0,0xc
ffffffffc02020f6:	16e7f763          	bgeu	a5,a4,ffffffffc0202264 <get_pte+0x1f4>
ffffffffc02020fa:	000b5797          	auipc	a5,0xb5
ffffffffc02020fe:	6f67b783          	ld	a5,1782(a5) # ffffffffc02b77f0 <va_pa_offset>
ffffffffc0202102:	6605                	lui	a2,0x1
ffffffffc0202104:	4581                	li	a1,0
ffffffffc0202106:	953e                	add	a0,a0,a5
ffffffffc0202108:	159030ef          	jal	ra,ffffffffc0205a60 <memset>
    return page - pages + nbase;
ffffffffc020210c:	000b3683          	ld	a3,0(s6)
ffffffffc0202110:	40d406b3          	sub	a3,s0,a3
ffffffffc0202114:	8699                	srai	a3,a3,0x6
ffffffffc0202116:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202118:	06aa                	slli	a3,a3,0xa
ffffffffc020211a:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020211e:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202120:	77fd                	lui	a5,0xfffff
ffffffffc0202122:	068a                	slli	a3,a3,0x2
ffffffffc0202124:	0009b703          	ld	a4,0(s3)
ffffffffc0202128:	8efd                	and	a3,a3,a5
ffffffffc020212a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020212e:	10e7ff63          	bgeu	a5,a4,ffffffffc020224c <get_pte+0x1dc>
ffffffffc0202132:	000b5a97          	auipc	s5,0xb5
ffffffffc0202136:	6bea8a93          	addi	s5,s5,1726 # ffffffffc02b77f0 <va_pa_offset>
ffffffffc020213a:	000ab403          	ld	s0,0(s5)
ffffffffc020213e:	01595793          	srli	a5,s2,0x15
ffffffffc0202142:	1ff7f793          	andi	a5,a5,511
ffffffffc0202146:	96a2                	add	a3,a3,s0
ffffffffc0202148:	00379413          	slli	s0,a5,0x3
ffffffffc020214c:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V))
ffffffffc020214e:	6014                	ld	a3,0(s0)
ffffffffc0202150:	0016f793          	andi	a5,a3,1
ffffffffc0202154:	ebad                	bnez	a5,ffffffffc02021c6 <get_pte+0x156>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202156:	0a0a0363          	beqz	s4,ffffffffc02021fc <get_pte+0x18c>
ffffffffc020215a:	100027f3          	csrr	a5,sstatus
ffffffffc020215e:	8b89                	andi	a5,a5,2
ffffffffc0202160:	efcd                	bnez	a5,ffffffffc020221a <get_pte+0x1aa>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202162:	000b5797          	auipc	a5,0xb5
ffffffffc0202166:	6867b783          	ld	a5,1670(a5) # ffffffffc02b77e8 <pmm_manager>
ffffffffc020216a:	6f9c                	ld	a5,24(a5)
ffffffffc020216c:	4505                	li	a0,1
ffffffffc020216e:	9782                	jalr	a5
ffffffffc0202170:	84aa                	mv	s1,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202172:	c4c9                	beqz	s1,ffffffffc02021fc <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0202174:	000b5b17          	auipc	s6,0xb5
ffffffffc0202178:	66cb0b13          	addi	s6,s6,1644 # ffffffffc02b77e0 <pages>
ffffffffc020217c:	000b3503          	ld	a0,0(s6)
ffffffffc0202180:	00080a37          	lui	s4,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202184:	0009b703          	ld	a4,0(s3)
ffffffffc0202188:	40a48533          	sub	a0,s1,a0
ffffffffc020218c:	8519                	srai	a0,a0,0x6
ffffffffc020218e:	9552                	add	a0,a0,s4
ffffffffc0202190:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0202194:	4685                	li	a3,1
ffffffffc0202196:	c094                	sw	a3,0(s1)
ffffffffc0202198:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020219a:	0532                	slli	a0,a0,0xc
ffffffffc020219c:	0ee7f163          	bgeu	a5,a4,ffffffffc020227e <get_pte+0x20e>
ffffffffc02021a0:	000ab783          	ld	a5,0(s5)
ffffffffc02021a4:	6605                	lui	a2,0x1
ffffffffc02021a6:	4581                	li	a1,0
ffffffffc02021a8:	953e                	add	a0,a0,a5
ffffffffc02021aa:	0b7030ef          	jal	ra,ffffffffc0205a60 <memset>
    return page - pages + nbase;
ffffffffc02021ae:	000b3683          	ld	a3,0(s6)
ffffffffc02021b2:	40d486b3          	sub	a3,s1,a3
ffffffffc02021b6:	8699                	srai	a3,a3,0x6
ffffffffc02021b8:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02021ba:	06aa                	slli	a3,a3,0xa
ffffffffc02021bc:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02021c0:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02021c2:	0009b703          	ld	a4,0(s3)
ffffffffc02021c6:	068a                	slli	a3,a3,0x2
ffffffffc02021c8:	757d                	lui	a0,0xfffff
ffffffffc02021ca:	8ee9                	and	a3,a3,a0
ffffffffc02021cc:	00c6d793          	srli	a5,a3,0xc
ffffffffc02021d0:	06e7f263          	bgeu	a5,a4,ffffffffc0202234 <get_pte+0x1c4>
ffffffffc02021d4:	000ab503          	ld	a0,0(s5)
ffffffffc02021d8:	00c95913          	srli	s2,s2,0xc
ffffffffc02021dc:	1ff97913          	andi	s2,s2,511
ffffffffc02021e0:	96aa                	add	a3,a3,a0
ffffffffc02021e2:	00391513          	slli	a0,s2,0x3
ffffffffc02021e6:	9536                	add	a0,a0,a3
}
ffffffffc02021e8:	70e2                	ld	ra,56(sp)
ffffffffc02021ea:	7442                	ld	s0,48(sp)
ffffffffc02021ec:	74a2                	ld	s1,40(sp)
ffffffffc02021ee:	7902                	ld	s2,32(sp)
ffffffffc02021f0:	69e2                	ld	s3,24(sp)
ffffffffc02021f2:	6a42                	ld	s4,16(sp)
ffffffffc02021f4:	6aa2                	ld	s5,8(sp)
ffffffffc02021f6:	6b02                	ld	s6,0(sp)
ffffffffc02021f8:	6121                	addi	sp,sp,64
ffffffffc02021fa:	8082                	ret
            return NULL;
ffffffffc02021fc:	4501                	li	a0,0
ffffffffc02021fe:	b7ed                	j	ffffffffc02021e8 <get_pte+0x178>
        intr_disable();
ffffffffc0202200:	fb4fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202204:	000b5797          	auipc	a5,0xb5
ffffffffc0202208:	5e47b783          	ld	a5,1508(a5) # ffffffffc02b77e8 <pmm_manager>
ffffffffc020220c:	6f9c                	ld	a5,24(a5)
ffffffffc020220e:	4505                	li	a0,1
ffffffffc0202210:	9782                	jalr	a5
ffffffffc0202212:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202214:	f9afe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202218:	b56d                	j	ffffffffc02020c2 <get_pte+0x52>
        intr_disable();
ffffffffc020221a:	f9afe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc020221e:	000b5797          	auipc	a5,0xb5
ffffffffc0202222:	5ca7b783          	ld	a5,1482(a5) # ffffffffc02b77e8 <pmm_manager>
ffffffffc0202226:	6f9c                	ld	a5,24(a5)
ffffffffc0202228:	4505                	li	a0,1
ffffffffc020222a:	9782                	jalr	a5
ffffffffc020222c:	84aa                	mv	s1,a0
        intr_enable();
ffffffffc020222e:	f80fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202232:	b781                	j	ffffffffc0202172 <get_pte+0x102>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202234:	00004617          	auipc	a2,0x4
ffffffffc0202238:	77460613          	addi	a2,a2,1908 # ffffffffc02069a8 <default_pmm_manager+0x38>
ffffffffc020223c:	0fa00593          	li	a1,250
ffffffffc0202240:	00005517          	auipc	a0,0x5
ffffffffc0202244:	88050513          	addi	a0,a0,-1920 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0202248:	a46fe0ef          	jal	ra,ffffffffc020048e <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020224c:	00004617          	auipc	a2,0x4
ffffffffc0202250:	75c60613          	addi	a2,a2,1884 # ffffffffc02069a8 <default_pmm_manager+0x38>
ffffffffc0202254:	0ed00593          	li	a1,237
ffffffffc0202258:	00005517          	auipc	a0,0x5
ffffffffc020225c:	86850513          	addi	a0,a0,-1944 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0202260:	a2efe0ef          	jal	ra,ffffffffc020048e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202264:	86aa                	mv	a3,a0
ffffffffc0202266:	00004617          	auipc	a2,0x4
ffffffffc020226a:	74260613          	addi	a2,a2,1858 # ffffffffc02069a8 <default_pmm_manager+0x38>
ffffffffc020226e:	0e900593          	li	a1,233
ffffffffc0202272:	00005517          	auipc	a0,0x5
ffffffffc0202276:	84e50513          	addi	a0,a0,-1970 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc020227a:	a14fe0ef          	jal	ra,ffffffffc020048e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020227e:	86aa                	mv	a3,a0
ffffffffc0202280:	00004617          	auipc	a2,0x4
ffffffffc0202284:	72860613          	addi	a2,a2,1832 # ffffffffc02069a8 <default_pmm_manager+0x38>
ffffffffc0202288:	0f700593          	li	a1,247
ffffffffc020228c:	00005517          	auipc	a0,0x5
ffffffffc0202290:	83450513          	addi	a0,a0,-1996 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0202294:	9fafe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0202298 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc0202298:	1141                	addi	sp,sp,-16
ffffffffc020229a:	e022                	sd	s0,0(sp)
ffffffffc020229c:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020229e:	4601                	li	a2,0
{
ffffffffc02022a0:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02022a2:	dcfff0ef          	jal	ra,ffffffffc0202070 <get_pte>
    if (ptep_store != NULL)
ffffffffc02022a6:	c011                	beqz	s0,ffffffffc02022aa <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc02022a8:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc02022aa:	c511                	beqz	a0,ffffffffc02022b6 <get_page+0x1e>
ffffffffc02022ac:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02022ae:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc02022b0:	0017f713          	andi	a4,a5,1
ffffffffc02022b4:	e709                	bnez	a4,ffffffffc02022be <get_page+0x26>
}
ffffffffc02022b6:	60a2                	ld	ra,8(sp)
ffffffffc02022b8:	6402                	ld	s0,0(sp)
ffffffffc02022ba:	0141                	addi	sp,sp,16
ffffffffc02022bc:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02022be:	078a                	slli	a5,a5,0x2
ffffffffc02022c0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02022c2:	000b5717          	auipc	a4,0xb5
ffffffffc02022c6:	51673703          	ld	a4,1302(a4) # ffffffffc02b77d8 <npage>
ffffffffc02022ca:	00e7ff63          	bgeu	a5,a4,ffffffffc02022e8 <get_page+0x50>
ffffffffc02022ce:	60a2                	ld	ra,8(sp)
ffffffffc02022d0:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc02022d2:	fff80537          	lui	a0,0xfff80
ffffffffc02022d6:	97aa                	add	a5,a5,a0
ffffffffc02022d8:	079a                	slli	a5,a5,0x6
ffffffffc02022da:	000b5517          	auipc	a0,0xb5
ffffffffc02022de:	50653503          	ld	a0,1286(a0) # ffffffffc02b77e0 <pages>
ffffffffc02022e2:	953e                	add	a0,a0,a5
ffffffffc02022e4:	0141                	addi	sp,sp,16
ffffffffc02022e6:	8082                	ret
ffffffffc02022e8:	c99ff0ef          	jal	ra,ffffffffc0201f80 <pa2page.part.0>

ffffffffc02022ec <unmap_range>:
        tlb_invalidate(pgdir, la);
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc02022ec:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022ee:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc02022f2:	f486                	sd	ra,104(sp)
ffffffffc02022f4:	f0a2                	sd	s0,96(sp)
ffffffffc02022f6:	eca6                	sd	s1,88(sp)
ffffffffc02022f8:	e8ca                	sd	s2,80(sp)
ffffffffc02022fa:	e4ce                	sd	s3,72(sp)
ffffffffc02022fc:	e0d2                	sd	s4,64(sp)
ffffffffc02022fe:	fc56                	sd	s5,56(sp)
ffffffffc0202300:	f85a                	sd	s6,48(sp)
ffffffffc0202302:	f45e                	sd	s7,40(sp)
ffffffffc0202304:	f062                	sd	s8,32(sp)
ffffffffc0202306:	ec66                	sd	s9,24(sp)
ffffffffc0202308:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020230a:	17d2                	slli	a5,a5,0x34
ffffffffc020230c:	e3ed                	bnez	a5,ffffffffc02023ee <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc020230e:	002007b7          	lui	a5,0x200
ffffffffc0202312:	842e                	mv	s0,a1
ffffffffc0202314:	0ef5ed63          	bltu	a1,a5,ffffffffc020240e <unmap_range+0x122>
ffffffffc0202318:	8932                	mv	s2,a2
ffffffffc020231a:	0ec5fa63          	bgeu	a1,a2,ffffffffc020240e <unmap_range+0x122>
ffffffffc020231e:	4785                	li	a5,1
ffffffffc0202320:	07fe                	slli	a5,a5,0x1f
ffffffffc0202322:	0ec7e663          	bltu	a5,a2,ffffffffc020240e <unmap_range+0x122>
ffffffffc0202326:	89aa                	mv	s3,a0
        }
        if (*ptep != 0)
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0202328:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage)
ffffffffc020232a:	000b5c97          	auipc	s9,0xb5
ffffffffc020232e:	4aec8c93          	addi	s9,s9,1198 # ffffffffc02b77d8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202332:	000b5c17          	auipc	s8,0xb5
ffffffffc0202336:	4aec0c13          	addi	s8,s8,1198 # ffffffffc02b77e0 <pages>
ffffffffc020233a:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc020233e:	000b5d17          	auipc	s10,0xb5
ffffffffc0202342:	4aad0d13          	addi	s10,s10,1194 # ffffffffc02b77e8 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202346:	00200b37          	lui	s6,0x200
ffffffffc020234a:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc020234e:	4601                	li	a2,0
ffffffffc0202350:	85a2                	mv	a1,s0
ffffffffc0202352:	854e                	mv	a0,s3
ffffffffc0202354:	d1dff0ef          	jal	ra,ffffffffc0202070 <get_pte>
ffffffffc0202358:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc020235a:	cd29                	beqz	a0,ffffffffc02023b4 <unmap_range+0xc8>
        if (*ptep != 0)
ffffffffc020235c:	611c                	ld	a5,0(a0)
ffffffffc020235e:	e395                	bnez	a5,ffffffffc0202382 <unmap_range+0x96>
        start += PGSIZE;
ffffffffc0202360:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0202362:	ff2466e3          	bltu	s0,s2,ffffffffc020234e <unmap_range+0x62>
}
ffffffffc0202366:	70a6                	ld	ra,104(sp)
ffffffffc0202368:	7406                	ld	s0,96(sp)
ffffffffc020236a:	64e6                	ld	s1,88(sp)
ffffffffc020236c:	6946                	ld	s2,80(sp)
ffffffffc020236e:	69a6                	ld	s3,72(sp)
ffffffffc0202370:	6a06                	ld	s4,64(sp)
ffffffffc0202372:	7ae2                	ld	s5,56(sp)
ffffffffc0202374:	7b42                	ld	s6,48(sp)
ffffffffc0202376:	7ba2                	ld	s7,40(sp)
ffffffffc0202378:	7c02                	ld	s8,32(sp)
ffffffffc020237a:	6ce2                	ld	s9,24(sp)
ffffffffc020237c:	6d42                	ld	s10,16(sp)
ffffffffc020237e:	6165                	addi	sp,sp,112
ffffffffc0202380:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc0202382:	0017f713          	andi	a4,a5,1
ffffffffc0202386:	df69                	beqz	a4,ffffffffc0202360 <unmap_range+0x74>
    if (PPN(pa) >= npage)
ffffffffc0202388:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020238c:	078a                	slli	a5,a5,0x2
ffffffffc020238e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202390:	08e7ff63          	bgeu	a5,a4,ffffffffc020242e <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc0202394:	000c3503          	ld	a0,0(s8)
ffffffffc0202398:	97de                	add	a5,a5,s7
ffffffffc020239a:	079a                	slli	a5,a5,0x6
ffffffffc020239c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020239e:	411c                	lw	a5,0(a0)
ffffffffc02023a0:	fff7871b          	addiw	a4,a5,-1
ffffffffc02023a4:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc02023a6:	cf11                	beqz	a4,ffffffffc02023c2 <unmap_range+0xd6>
        *ptep = 0;
ffffffffc02023a8:	0004b023          	sd	zero,0(s1)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02023ac:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc02023b0:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02023b2:	bf45                	j	ffffffffc0202362 <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02023b4:	945a                	add	s0,s0,s6
ffffffffc02023b6:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc02023ba:	d455                	beqz	s0,ffffffffc0202366 <unmap_range+0x7a>
ffffffffc02023bc:	f92469e3          	bltu	s0,s2,ffffffffc020234e <unmap_range+0x62>
ffffffffc02023c0:	b75d                	j	ffffffffc0202366 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02023c2:	100027f3          	csrr	a5,sstatus
ffffffffc02023c6:	8b89                	andi	a5,a5,2
ffffffffc02023c8:	e799                	bnez	a5,ffffffffc02023d6 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc02023ca:	000d3783          	ld	a5,0(s10)
ffffffffc02023ce:	4585                	li	a1,1
ffffffffc02023d0:	739c                	ld	a5,32(a5)
ffffffffc02023d2:	9782                	jalr	a5
    if (flag)
ffffffffc02023d4:	bfd1                	j	ffffffffc02023a8 <unmap_range+0xbc>
ffffffffc02023d6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02023d8:	ddcfe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc02023dc:	000d3783          	ld	a5,0(s10)
ffffffffc02023e0:	6522                	ld	a0,8(sp)
ffffffffc02023e2:	4585                	li	a1,1
ffffffffc02023e4:	739c                	ld	a5,32(a5)
ffffffffc02023e6:	9782                	jalr	a5
        intr_enable();
ffffffffc02023e8:	dc6fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02023ec:	bf75                	j	ffffffffc02023a8 <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02023ee:	00004697          	auipc	a3,0x4
ffffffffc02023f2:	6e268693          	addi	a3,a3,1762 # ffffffffc0206ad0 <default_pmm_manager+0x160>
ffffffffc02023f6:	00004617          	auipc	a2,0x4
ffffffffc02023fa:	1ca60613          	addi	a2,a2,458 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02023fe:	12000593          	li	a1,288
ffffffffc0202402:	00004517          	auipc	a0,0x4
ffffffffc0202406:	6be50513          	addi	a0,a0,1726 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc020240a:	884fe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020240e:	00004697          	auipc	a3,0x4
ffffffffc0202412:	6f268693          	addi	a3,a3,1778 # ffffffffc0206b00 <default_pmm_manager+0x190>
ffffffffc0202416:	00004617          	auipc	a2,0x4
ffffffffc020241a:	1aa60613          	addi	a2,a2,426 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc020241e:	12100593          	li	a1,289
ffffffffc0202422:	00004517          	auipc	a0,0x4
ffffffffc0202426:	69e50513          	addi	a0,a0,1694 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc020242a:	864fe0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc020242e:	b53ff0ef          	jal	ra,ffffffffc0201f80 <pa2page.part.0>

ffffffffc0202432 <exit_range>:
{
ffffffffc0202432:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202434:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0202438:	fc86                	sd	ra,120(sp)
ffffffffc020243a:	f8a2                	sd	s0,112(sp)
ffffffffc020243c:	f4a6                	sd	s1,104(sp)
ffffffffc020243e:	f0ca                	sd	s2,96(sp)
ffffffffc0202440:	ecce                	sd	s3,88(sp)
ffffffffc0202442:	e8d2                	sd	s4,80(sp)
ffffffffc0202444:	e4d6                	sd	s5,72(sp)
ffffffffc0202446:	e0da                	sd	s6,64(sp)
ffffffffc0202448:	fc5e                	sd	s7,56(sp)
ffffffffc020244a:	f862                	sd	s8,48(sp)
ffffffffc020244c:	f466                	sd	s9,40(sp)
ffffffffc020244e:	f06a                	sd	s10,32(sp)
ffffffffc0202450:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202452:	17d2                	slli	a5,a5,0x34
ffffffffc0202454:	20079a63          	bnez	a5,ffffffffc0202668 <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc0202458:	002007b7          	lui	a5,0x200
ffffffffc020245c:	24f5e463          	bltu	a1,a5,ffffffffc02026a4 <exit_range+0x272>
ffffffffc0202460:	8ab2                	mv	s5,a2
ffffffffc0202462:	24c5f163          	bgeu	a1,a2,ffffffffc02026a4 <exit_range+0x272>
ffffffffc0202466:	4785                	li	a5,1
ffffffffc0202468:	07fe                	slli	a5,a5,0x1f
ffffffffc020246a:	22c7ed63          	bltu	a5,a2,ffffffffc02026a4 <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc020246e:	c00009b7          	lui	s3,0xc0000
ffffffffc0202472:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202476:	ffe00937          	lui	s2,0xffe00
ffffffffc020247a:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc020247e:	5cfd                	li	s9,-1
ffffffffc0202480:	8c2a                	mv	s8,a0
ffffffffc0202482:	0125f933          	and	s2,a1,s2
ffffffffc0202486:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage)
ffffffffc0202488:	000b5d17          	auipc	s10,0xb5
ffffffffc020248c:	350d0d13          	addi	s10,s10,848 # ffffffffc02b77d8 <npage>
    return KADDR(page2pa(page));
ffffffffc0202490:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0202494:	000b5717          	auipc	a4,0xb5
ffffffffc0202498:	34c70713          	addi	a4,a4,844 # ffffffffc02b77e0 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc020249c:	000b5d97          	auipc	s11,0xb5
ffffffffc02024a0:	34cd8d93          	addi	s11,s11,844 # ffffffffc02b77e8 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02024a4:	c0000437          	lui	s0,0xc0000
ffffffffc02024a8:	944e                	add	s0,s0,s3
ffffffffc02024aa:	8079                	srli	s0,s0,0x1e
ffffffffc02024ac:	1ff47413          	andi	s0,s0,511
ffffffffc02024b0:	040e                	slli	s0,s0,0x3
ffffffffc02024b2:	9462                	add	s0,s0,s8
ffffffffc02024b4:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_cowtest_out_size+0xffffffffbfff2f60>
        if (pde1 & PTE_V)
ffffffffc02024b8:	001a7793          	andi	a5,s4,1
ffffffffc02024bc:	eb99                	bnez	a5,ffffffffc02024d2 <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc02024be:	12098463          	beqz	s3,ffffffffc02025e6 <exit_range+0x1b4>
ffffffffc02024c2:	400007b7          	lui	a5,0x40000
ffffffffc02024c6:	97ce                	add	a5,a5,s3
ffffffffc02024c8:	894e                	mv	s2,s3
ffffffffc02024ca:	1159fe63          	bgeu	s3,s5,ffffffffc02025e6 <exit_range+0x1b4>
ffffffffc02024ce:	89be                	mv	s3,a5
ffffffffc02024d0:	bfd1                	j	ffffffffc02024a4 <exit_range+0x72>
    if (PPN(pa) >= npage)
ffffffffc02024d2:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02024d6:	0a0a                	slli	s4,s4,0x2
ffffffffc02024d8:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage)
ffffffffc02024dc:	1cfa7263          	bgeu	s4,a5,ffffffffc02026a0 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02024e0:	fff80637          	lui	a2,0xfff80
ffffffffc02024e4:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc02024e6:	000806b7          	lui	a3,0x80
ffffffffc02024ea:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc02024ec:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc02024f0:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02024f2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02024f4:	18f5fa63          	bgeu	a1,a5,ffffffffc0202688 <exit_range+0x256>
ffffffffc02024f8:	000b5817          	auipc	a6,0xb5
ffffffffc02024fc:	2f880813          	addi	a6,a6,760 # ffffffffc02b77f0 <va_pa_offset>
ffffffffc0202500:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc0202504:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc0202506:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc020250a:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc020250c:	00080337          	lui	t1,0x80
ffffffffc0202510:	6885                	lui	a7,0x1
ffffffffc0202512:	a819                	j	ffffffffc0202528 <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc0202514:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc0202516:	002007b7          	lui	a5,0x200
ffffffffc020251a:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc020251c:	08090c63          	beqz	s2,ffffffffc02025b4 <exit_range+0x182>
ffffffffc0202520:	09397a63          	bgeu	s2,s3,ffffffffc02025b4 <exit_range+0x182>
ffffffffc0202524:	0f597063          	bgeu	s2,s5,ffffffffc0202604 <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0202528:	01595493          	srli	s1,s2,0x15
ffffffffc020252c:	1ff4f493          	andi	s1,s1,511
ffffffffc0202530:	048e                	slli	s1,s1,0x3
ffffffffc0202532:	94da                	add	s1,s1,s6
ffffffffc0202534:	609c                	ld	a5,0(s1)
                if (pde0 & PTE_V)
ffffffffc0202536:	0017f693          	andi	a3,a5,1
ffffffffc020253a:	dee9                	beqz	a3,ffffffffc0202514 <exit_range+0xe2>
    if (PPN(pa) >= npage)
ffffffffc020253c:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202540:	078a                	slli	a5,a5,0x2
ffffffffc0202542:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202544:	14b7fe63          	bgeu	a5,a1,ffffffffc02026a0 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202548:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc020254a:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc020254e:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0202552:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202556:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202558:	12bef863          	bgeu	t4,a1,ffffffffc0202688 <exit_range+0x256>
ffffffffc020255c:	00083783          	ld	a5,0(a6)
ffffffffc0202560:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc0202562:	011685b3          	add	a1,a3,a7
                        if (pt[i] & PTE_V)
ffffffffc0202566:	629c                	ld	a5,0(a3)
ffffffffc0202568:	8b85                	andi	a5,a5,1
ffffffffc020256a:	f7d5                	bnez	a5,ffffffffc0202516 <exit_range+0xe4>
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc020256c:	06a1                	addi	a3,a3,8
ffffffffc020256e:	fed59ce3          	bne	a1,a3,ffffffffc0202566 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc0202572:	631c                	ld	a5,0(a4)
ffffffffc0202574:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202576:	100027f3          	csrr	a5,sstatus
ffffffffc020257a:	8b89                	andi	a5,a5,2
ffffffffc020257c:	e7d9                	bnez	a5,ffffffffc020260a <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc020257e:	000db783          	ld	a5,0(s11)
ffffffffc0202582:	4585                	li	a1,1
ffffffffc0202584:	e032                	sd	a2,0(sp)
ffffffffc0202586:	739c                	ld	a5,32(a5)
ffffffffc0202588:	9782                	jalr	a5
    if (flag)
ffffffffc020258a:	6602                	ld	a2,0(sp)
ffffffffc020258c:	000b5817          	auipc	a6,0xb5
ffffffffc0202590:	26480813          	addi	a6,a6,612 # ffffffffc02b77f0 <va_pa_offset>
ffffffffc0202594:	fff80e37          	lui	t3,0xfff80
ffffffffc0202598:	00080337          	lui	t1,0x80
ffffffffc020259c:	6885                	lui	a7,0x1
ffffffffc020259e:	000b5717          	auipc	a4,0xb5
ffffffffc02025a2:	24270713          	addi	a4,a4,578 # ffffffffc02b77e0 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc02025a6:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc02025aa:	002007b7          	lui	a5,0x200
ffffffffc02025ae:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc02025b0:	f60918e3          	bnez	s2,ffffffffc0202520 <exit_range+0xee>
            if (free_pd0)
ffffffffc02025b4:	f00b85e3          	beqz	s7,ffffffffc02024be <exit_range+0x8c>
    if (PPN(pa) >= npage)
ffffffffc02025b8:	000d3783          	ld	a5,0(s10)
ffffffffc02025bc:	0efa7263          	bgeu	s4,a5,ffffffffc02026a0 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02025c0:	6308                	ld	a0,0(a4)
ffffffffc02025c2:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02025c4:	100027f3          	csrr	a5,sstatus
ffffffffc02025c8:	8b89                	andi	a5,a5,2
ffffffffc02025ca:	efad                	bnez	a5,ffffffffc0202644 <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc02025cc:	000db783          	ld	a5,0(s11)
ffffffffc02025d0:	4585                	li	a1,1
ffffffffc02025d2:	739c                	ld	a5,32(a5)
ffffffffc02025d4:	9782                	jalr	a5
ffffffffc02025d6:	000b5717          	auipc	a4,0xb5
ffffffffc02025da:	20a70713          	addi	a4,a4,522 # ffffffffc02b77e0 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc02025de:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc02025e2:	ee0990e3          	bnez	s3,ffffffffc02024c2 <exit_range+0x90>
}
ffffffffc02025e6:	70e6                	ld	ra,120(sp)
ffffffffc02025e8:	7446                	ld	s0,112(sp)
ffffffffc02025ea:	74a6                	ld	s1,104(sp)
ffffffffc02025ec:	7906                	ld	s2,96(sp)
ffffffffc02025ee:	69e6                	ld	s3,88(sp)
ffffffffc02025f0:	6a46                	ld	s4,80(sp)
ffffffffc02025f2:	6aa6                	ld	s5,72(sp)
ffffffffc02025f4:	6b06                	ld	s6,64(sp)
ffffffffc02025f6:	7be2                	ld	s7,56(sp)
ffffffffc02025f8:	7c42                	ld	s8,48(sp)
ffffffffc02025fa:	7ca2                	ld	s9,40(sp)
ffffffffc02025fc:	7d02                	ld	s10,32(sp)
ffffffffc02025fe:	6de2                	ld	s11,24(sp)
ffffffffc0202600:	6109                	addi	sp,sp,128
ffffffffc0202602:	8082                	ret
            if (free_pd0)
ffffffffc0202604:	ea0b8fe3          	beqz	s7,ffffffffc02024c2 <exit_range+0x90>
ffffffffc0202608:	bf45                	j	ffffffffc02025b8 <exit_range+0x186>
ffffffffc020260a:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc020260c:	e42a                	sd	a0,8(sp)
ffffffffc020260e:	ba6fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202612:	000db783          	ld	a5,0(s11)
ffffffffc0202616:	6522                	ld	a0,8(sp)
ffffffffc0202618:	4585                	li	a1,1
ffffffffc020261a:	739c                	ld	a5,32(a5)
ffffffffc020261c:	9782                	jalr	a5
        intr_enable();
ffffffffc020261e:	b90fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202622:	6602                	ld	a2,0(sp)
ffffffffc0202624:	000b5717          	auipc	a4,0xb5
ffffffffc0202628:	1bc70713          	addi	a4,a4,444 # ffffffffc02b77e0 <pages>
ffffffffc020262c:	6885                	lui	a7,0x1
ffffffffc020262e:	00080337          	lui	t1,0x80
ffffffffc0202632:	fff80e37          	lui	t3,0xfff80
ffffffffc0202636:	000b5817          	auipc	a6,0xb5
ffffffffc020263a:	1ba80813          	addi	a6,a6,442 # ffffffffc02b77f0 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc020263e:	0004b023          	sd	zero,0(s1)
ffffffffc0202642:	b7a5                	j	ffffffffc02025aa <exit_range+0x178>
ffffffffc0202644:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0202646:	b6efe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020264a:	000db783          	ld	a5,0(s11)
ffffffffc020264e:	6502                	ld	a0,0(sp)
ffffffffc0202650:	4585                	li	a1,1
ffffffffc0202652:	739c                	ld	a5,32(a5)
ffffffffc0202654:	9782                	jalr	a5
        intr_enable();
ffffffffc0202656:	b58fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020265a:	000b5717          	auipc	a4,0xb5
ffffffffc020265e:	18670713          	addi	a4,a4,390 # ffffffffc02b77e0 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202662:	00043023          	sd	zero,0(s0)
ffffffffc0202666:	bfb5                	j	ffffffffc02025e2 <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202668:	00004697          	auipc	a3,0x4
ffffffffc020266c:	46868693          	addi	a3,a3,1128 # ffffffffc0206ad0 <default_pmm_manager+0x160>
ffffffffc0202670:	00004617          	auipc	a2,0x4
ffffffffc0202674:	f5060613          	addi	a2,a2,-176 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0202678:	13500593          	li	a1,309
ffffffffc020267c:	00004517          	auipc	a0,0x4
ffffffffc0202680:	44450513          	addi	a0,a0,1092 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0202684:	e0bfd0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc0202688:	00004617          	auipc	a2,0x4
ffffffffc020268c:	32060613          	addi	a2,a2,800 # ffffffffc02069a8 <default_pmm_manager+0x38>
ffffffffc0202690:	07700593          	li	a1,119
ffffffffc0202694:	00004517          	auipc	a0,0x4
ffffffffc0202698:	33c50513          	addi	a0,a0,828 # ffffffffc02069d0 <default_pmm_manager+0x60>
ffffffffc020269c:	df3fd0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc02026a0:	8e1ff0ef          	jal	ra,ffffffffc0201f80 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc02026a4:	00004697          	auipc	a3,0x4
ffffffffc02026a8:	45c68693          	addi	a3,a3,1116 # ffffffffc0206b00 <default_pmm_manager+0x190>
ffffffffc02026ac:	00004617          	auipc	a2,0x4
ffffffffc02026b0:	f1460613          	addi	a2,a2,-236 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02026b4:	13600593          	li	a1,310
ffffffffc02026b8:	00004517          	auipc	a0,0x4
ffffffffc02026bc:	40850513          	addi	a0,a0,1032 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc02026c0:	dcffd0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02026c4 <page_remove>:
{
ffffffffc02026c4:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02026c6:	4601                	li	a2,0
{
ffffffffc02026c8:	ec26                	sd	s1,24(sp)
ffffffffc02026ca:	f406                	sd	ra,40(sp)
ffffffffc02026cc:	f022                	sd	s0,32(sp)
ffffffffc02026ce:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02026d0:	9a1ff0ef          	jal	ra,ffffffffc0202070 <get_pte>
    if (ptep != NULL)
ffffffffc02026d4:	c511                	beqz	a0,ffffffffc02026e0 <page_remove+0x1c>
    if (*ptep & PTE_V)
ffffffffc02026d6:	611c                	ld	a5,0(a0)
ffffffffc02026d8:	842a                	mv	s0,a0
ffffffffc02026da:	0017f713          	andi	a4,a5,1
ffffffffc02026de:	e711                	bnez	a4,ffffffffc02026ea <page_remove+0x26>
}
ffffffffc02026e0:	70a2                	ld	ra,40(sp)
ffffffffc02026e2:	7402                	ld	s0,32(sp)
ffffffffc02026e4:	64e2                	ld	s1,24(sp)
ffffffffc02026e6:	6145                	addi	sp,sp,48
ffffffffc02026e8:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02026ea:	078a                	slli	a5,a5,0x2
ffffffffc02026ec:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02026ee:	000b5717          	auipc	a4,0xb5
ffffffffc02026f2:	0ea73703          	ld	a4,234(a4) # ffffffffc02b77d8 <npage>
ffffffffc02026f6:	06e7f363          	bgeu	a5,a4,ffffffffc020275c <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc02026fa:	fff80537          	lui	a0,0xfff80
ffffffffc02026fe:	97aa                	add	a5,a5,a0
ffffffffc0202700:	079a                	slli	a5,a5,0x6
ffffffffc0202702:	000b5517          	auipc	a0,0xb5
ffffffffc0202706:	0de53503          	ld	a0,222(a0) # ffffffffc02b77e0 <pages>
ffffffffc020270a:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020270c:	411c                	lw	a5,0(a0)
ffffffffc020270e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202712:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc0202714:	cb11                	beqz	a4,ffffffffc0202728 <page_remove+0x64>
        *ptep = 0;
ffffffffc0202716:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020271a:	12048073          	sfence.vma	s1
}
ffffffffc020271e:	70a2                	ld	ra,40(sp)
ffffffffc0202720:	7402                	ld	s0,32(sp)
ffffffffc0202722:	64e2                	ld	s1,24(sp)
ffffffffc0202724:	6145                	addi	sp,sp,48
ffffffffc0202726:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202728:	100027f3          	csrr	a5,sstatus
ffffffffc020272c:	8b89                	andi	a5,a5,2
ffffffffc020272e:	eb89                	bnez	a5,ffffffffc0202740 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0202730:	000b5797          	auipc	a5,0xb5
ffffffffc0202734:	0b87b783          	ld	a5,184(a5) # ffffffffc02b77e8 <pmm_manager>
ffffffffc0202738:	739c                	ld	a5,32(a5)
ffffffffc020273a:	4585                	li	a1,1
ffffffffc020273c:	9782                	jalr	a5
    if (flag)
ffffffffc020273e:	bfe1                	j	ffffffffc0202716 <page_remove+0x52>
        intr_disable();
ffffffffc0202740:	e42a                	sd	a0,8(sp)
ffffffffc0202742:	a72fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202746:	000b5797          	auipc	a5,0xb5
ffffffffc020274a:	0a27b783          	ld	a5,162(a5) # ffffffffc02b77e8 <pmm_manager>
ffffffffc020274e:	739c                	ld	a5,32(a5)
ffffffffc0202750:	6522                	ld	a0,8(sp)
ffffffffc0202752:	4585                	li	a1,1
ffffffffc0202754:	9782                	jalr	a5
        intr_enable();
ffffffffc0202756:	a58fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020275a:	bf75                	j	ffffffffc0202716 <page_remove+0x52>
ffffffffc020275c:	825ff0ef          	jal	ra,ffffffffc0201f80 <pa2page.part.0>

ffffffffc0202760 <do_cow_fault>:
{
ffffffffc0202760:	715d                	addi	sp,sp,-80
ffffffffc0202762:	f84a                	sd	s2,48(sp)
    struct Page *old_page = pte2page(*ptep);
ffffffffc0202764:	00063903          	ld	s2,0(a2)
{
ffffffffc0202768:	e486                	sd	ra,72(sp)
ffffffffc020276a:	e0a2                	sd	s0,64(sp)
ffffffffc020276c:	fc26                	sd	s1,56(sp)
ffffffffc020276e:	f44e                	sd	s3,40(sp)
ffffffffc0202770:	f052                	sd	s4,32(sp)
ffffffffc0202772:	ec56                	sd	s5,24(sp)
ffffffffc0202774:	e85a                	sd	s6,16(sp)
ffffffffc0202776:	e45e                	sd	s7,8(sp)
    if (!(pte & PTE_V))
ffffffffc0202778:	00197793          	andi	a5,s2,1
ffffffffc020277c:	14078c63          	beqz	a5,ffffffffc02028d4 <do_cow_fault+0x174>
    if (PPN(pa) >= npage)
ffffffffc0202780:	000b5b97          	auipc	s7,0xb5
ffffffffc0202784:	058b8b93          	addi	s7,s7,88 # ffffffffc02b77d8 <npage>
ffffffffc0202788:	000bb703          	ld	a4,0(s7)
    return pa2page(PTE_ADDR(pte));
ffffffffc020278c:	00291793          	slli	a5,s2,0x2
ffffffffc0202790:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202792:	14e7f363          	bgeu	a5,a4,ffffffffc02028d8 <do_cow_fault+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc0202796:	000b5b17          	auipc	s6,0xb5
ffffffffc020279a:	04ab0b13          	addi	s6,s6,74 # ffffffffc02b77e0 <pages>
ffffffffc020279e:	fff80737          	lui	a4,0xfff80
ffffffffc02027a2:	000b3a03          	ld	s4,0(s6)
ffffffffc02027a6:	97ba                	add	a5,a5,a4
ffffffffc02027a8:	079a                	slli	a5,a5,0x6
ffffffffc02027aa:	9a3e                	add	s4,s4,a5
    if (page_ref(old_page) == 1) {
ffffffffc02027ac:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
    perm = (perm & ~PTE_COW) | PTE_W;  // Remove COW flag, add write permission
ffffffffc02027b0:	01b97913          	andi	s2,s2,27
    if (page_ref(old_page) == 1) {
ffffffffc02027b4:	4705                	li	a4,1
ffffffffc02027b6:	8432                	mv	s0,a2
ffffffffc02027b8:	84ae                	mv	s1,a1
    perm = (perm & ~PTE_COW) | PTE_W;  // Remove COW flag, add write permission
ffffffffc02027ba:	00496913          	ori	s2,s2,4
    if (page_ref(old_page) == 1) {
ffffffffc02027be:	0ce68563          	beq	a3,a4,ffffffffc0202888 <do_cow_fault+0x128>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02027c2:	100027f3          	csrr	a5,sstatus
ffffffffc02027c6:	8b89                	andi	a5,a5,2
        page = pmm_manager->alloc_pages(n);
ffffffffc02027c8:	000b5997          	auipc	s3,0xb5
ffffffffc02027cc:	02098993          	addi	s3,s3,32 # ffffffffc02b77e8 <pmm_manager>
ffffffffc02027d0:	ebf1                	bnez	a5,ffffffffc02028a4 <do_cow_fault+0x144>
ffffffffc02027d2:	0009b783          	ld	a5,0(s3)
ffffffffc02027d6:	4505                	li	a0,1
ffffffffc02027d8:	6f9c                	ld	a5,24(a5)
ffffffffc02027da:	9782                	jalr	a5
ffffffffc02027dc:	8aaa                	mv	s5,a0
    if (new_page == NULL) {
ffffffffc02027de:	0e0a8963          	beqz	s5,ffffffffc02028d0 <do_cow_fault+0x170>
    return page - pages + nbase;
ffffffffc02027e2:	000b3783          	ld	a5,0(s6)
ffffffffc02027e6:	00080537          	lui	a0,0x80
    return KADDR(page2pa(page));
ffffffffc02027ea:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc02027ec:	40fa05b3          	sub	a1,s4,a5
ffffffffc02027f0:	8599                	srai	a1,a1,0x6
    return KADDR(page2pa(page));
ffffffffc02027f2:	000bb603          	ld	a2,0(s7)
    return page - pages + nbase;
ffffffffc02027f6:	95aa                	add	a1,a1,a0
    return KADDR(page2pa(page));
ffffffffc02027f8:	8331                	srli	a4,a4,0xc
ffffffffc02027fa:	00e5f6b3          	and	a3,a1,a4
    return page2ppn(page) << PGSHIFT;
ffffffffc02027fe:	05b2                	slli	a1,a1,0xc
    return KADDR(page2pa(page));
ffffffffc0202800:	0ec6fa63          	bgeu	a3,a2,ffffffffc02028f4 <do_cow_fault+0x194>
    return page - pages + nbase;
ffffffffc0202804:	40fa86b3          	sub	a3,s5,a5
ffffffffc0202808:	8699                	srai	a3,a3,0x6
ffffffffc020280a:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc020280c:	8f75                	and	a4,a4,a3
ffffffffc020280e:	000b5517          	auipc	a0,0xb5
ffffffffc0202812:	fe253503          	ld	a0,-30(a0) # ffffffffc02b77f0 <va_pa_offset>
ffffffffc0202816:	95aa                	add	a1,a1,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202818:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020281a:	0cc77163          	bgeu	a4,a2,ffffffffc02028dc <do_cow_fault+0x17c>
    memcpy(dst, src, PGSIZE);
ffffffffc020281e:	6605                	lui	a2,0x1
ffffffffc0202820:	9536                	add	a0,a0,a3
ffffffffc0202822:	250030ef          	jal	ra,ffffffffc0205a72 <memcpy>
    page->ref -= 1;
ffffffffc0202826:	000a2783          	lw	a5,0(s4)
ffffffffc020282a:	fff7871b          	addiw	a4,a5,-1
ffffffffc020282e:	00ea2023          	sw	a4,0(s4)
    if (page_ref(old_page) == 0) {
ffffffffc0202832:	c321                	beqz	a4,ffffffffc0202872 <do_cow_fault+0x112>
    return page - pages + nbase;
ffffffffc0202834:	000b3783          	ld	a5,0(s6)
ffffffffc0202838:	00080737          	lui	a4,0x80
ffffffffc020283c:	40fa87b3          	sub	a5,s5,a5
ffffffffc0202840:	8799                	srai	a5,a5,0x6
ffffffffc0202842:	97ba                	add	a5,a5,a4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202844:	07aa                	slli	a5,a5,0xa
ffffffffc0202846:	0127e7b3          	or	a5,a5,s2
    page->ref = val;
ffffffffc020284a:	4705                	li	a4,1
ffffffffc020284c:	00eaa023          	sw	a4,0(s5) # ffffffffffe00000 <end+0x3fb487ec>
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202850:	0017e793          	ori	a5,a5,1
    *ptep = pte_create(page2ppn(new_page), perm);
ffffffffc0202854:	e01c                	sd	a5,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202856:	12048073          	sfence.vma	s1
    return 0;
ffffffffc020285a:	4501                	li	a0,0
}
ffffffffc020285c:	60a6                	ld	ra,72(sp)
ffffffffc020285e:	6406                	ld	s0,64(sp)
ffffffffc0202860:	74e2                	ld	s1,56(sp)
ffffffffc0202862:	7942                	ld	s2,48(sp)
ffffffffc0202864:	79a2                	ld	s3,40(sp)
ffffffffc0202866:	7a02                	ld	s4,32(sp)
ffffffffc0202868:	6ae2                	ld	s5,24(sp)
ffffffffc020286a:	6b42                	ld	s6,16(sp)
ffffffffc020286c:	6ba2                	ld	s7,8(sp)
ffffffffc020286e:	6161                	addi	sp,sp,80
ffffffffc0202870:	8082                	ret
ffffffffc0202872:	100027f3          	csrr	a5,sstatus
ffffffffc0202876:	8b89                	andi	a5,a5,2
ffffffffc0202878:	e3a9                	bnez	a5,ffffffffc02028ba <do_cow_fault+0x15a>
        pmm_manager->free_pages(base, n);
ffffffffc020287a:	0009b783          	ld	a5,0(s3)
ffffffffc020287e:	4585                	li	a1,1
ffffffffc0202880:	8552                	mv	a0,s4
ffffffffc0202882:	739c                	ld	a5,32(a5)
ffffffffc0202884:	9782                	jalr	a5
    if (flag)
ffffffffc0202886:	b77d                	j	ffffffffc0202834 <do_cow_fault+0xd4>
    return page - pages + nbase;
ffffffffc0202888:	00080737          	lui	a4,0x80
ffffffffc020288c:	8799                	srai	a5,a5,0x6
ffffffffc020288e:	97ba                	add	a5,a5,a4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202890:	07aa                	slli	a5,a5,0xa
ffffffffc0202892:	0127e7b3          	or	a5,a5,s2
ffffffffc0202896:	0017e793          	ori	a5,a5,1
        *ptep = pte_create(page2ppn(old_page), perm);
ffffffffc020289a:	e21c                	sd	a5,0(a2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020289c:	12058073          	sfence.vma	a1
        return 0;
ffffffffc02028a0:	4501                	li	a0,0
ffffffffc02028a2:	bf6d                	j	ffffffffc020285c <do_cow_fault+0xfc>
        intr_disable();
ffffffffc02028a4:	910fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02028a8:	0009b783          	ld	a5,0(s3)
ffffffffc02028ac:	4505                	li	a0,1
ffffffffc02028ae:	6f9c                	ld	a5,24(a5)
ffffffffc02028b0:	9782                	jalr	a5
ffffffffc02028b2:	8aaa                	mv	s5,a0
        intr_enable();
ffffffffc02028b4:	8fafe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02028b8:	b71d                	j	ffffffffc02027de <do_cow_fault+0x7e>
        intr_disable();
ffffffffc02028ba:	8fafe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02028be:	0009b783          	ld	a5,0(s3)
ffffffffc02028c2:	4585                	li	a1,1
ffffffffc02028c4:	8552                	mv	a0,s4
ffffffffc02028c6:	739c                	ld	a5,32(a5)
ffffffffc02028c8:	9782                	jalr	a5
        intr_enable();
ffffffffc02028ca:	8e4fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02028ce:	b79d                	j	ffffffffc0202834 <do_cow_fault+0xd4>
        return -E_NO_MEM;
ffffffffc02028d0:	5571                	li	a0,-4
ffffffffc02028d2:	b769                	j	ffffffffc020285c <do_cow_fault+0xfc>
ffffffffc02028d4:	ec8ff0ef          	jal	ra,ffffffffc0201f9c <pte2page.part.0>
ffffffffc02028d8:	ea8ff0ef          	jal	ra,ffffffffc0201f80 <pa2page.part.0>
    return KADDR(page2pa(page));
ffffffffc02028dc:	00004617          	auipc	a2,0x4
ffffffffc02028e0:	0cc60613          	addi	a2,a2,204 # ffffffffc02069a8 <default_pmm_manager+0x38>
ffffffffc02028e4:	07700593          	li	a1,119
ffffffffc02028e8:	00004517          	auipc	a0,0x4
ffffffffc02028ec:	0e850513          	addi	a0,a0,232 # ffffffffc02069d0 <default_pmm_manager+0x60>
ffffffffc02028f0:	b9ffd0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc02028f4:	86ae                	mv	a3,a1
ffffffffc02028f6:	00004617          	auipc	a2,0x4
ffffffffc02028fa:	0b260613          	addi	a2,a2,178 # ffffffffc02069a8 <default_pmm_manager+0x38>
ffffffffc02028fe:	07700593          	li	a1,119
ffffffffc0202902:	00004517          	auipc	a0,0x4
ffffffffc0202906:	0ce50513          	addi	a0,a0,206 # ffffffffc02069d0 <default_pmm_manager+0x60>
ffffffffc020290a:	b85fd0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020290e <page_insert>:
{
ffffffffc020290e:	7139                	addi	sp,sp,-64
ffffffffc0202910:	e852                	sd	s4,16(sp)
ffffffffc0202912:	8a32                	mv	s4,a2
ffffffffc0202914:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202916:	4605                	li	a2,1
{
ffffffffc0202918:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020291a:	85d2                	mv	a1,s4
{
ffffffffc020291c:	f426                	sd	s1,40(sp)
ffffffffc020291e:	fc06                	sd	ra,56(sp)
ffffffffc0202920:	f04a                	sd	s2,32(sp)
ffffffffc0202922:	ec4e                	sd	s3,24(sp)
ffffffffc0202924:	e456                	sd	s5,8(sp)
ffffffffc0202926:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202928:	f48ff0ef          	jal	ra,ffffffffc0202070 <get_pte>
    if (ptep == NULL)
ffffffffc020292c:	c961                	beqz	a0,ffffffffc02029fc <page_insert+0xee>
    page->ref += 1;
ffffffffc020292e:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V)
ffffffffc0202930:	611c                	ld	a5,0(a0)
ffffffffc0202932:	89aa                	mv	s3,a0
ffffffffc0202934:	0016871b          	addiw	a4,a3,1
ffffffffc0202938:	c018                	sw	a4,0(s0)
ffffffffc020293a:	0017f713          	andi	a4,a5,1
ffffffffc020293e:	ef05                	bnez	a4,ffffffffc0202976 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0202940:	000b5717          	auipc	a4,0xb5
ffffffffc0202944:	ea073703          	ld	a4,-352(a4) # ffffffffc02b77e0 <pages>
ffffffffc0202948:	8c19                	sub	s0,s0,a4
ffffffffc020294a:	000807b7          	lui	a5,0x80
ffffffffc020294e:	8419                	srai	s0,s0,0x6
ffffffffc0202950:	943e                	add	s0,s0,a5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202952:	042a                	slli	s0,s0,0xa
ffffffffc0202954:	8cc1                	or	s1,s1,s0
ffffffffc0202956:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc020295a:	0099b023          	sd	s1,0(s3)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020295e:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0202962:	4501                	li	a0,0
}
ffffffffc0202964:	70e2                	ld	ra,56(sp)
ffffffffc0202966:	7442                	ld	s0,48(sp)
ffffffffc0202968:	74a2                	ld	s1,40(sp)
ffffffffc020296a:	7902                	ld	s2,32(sp)
ffffffffc020296c:	69e2                	ld	s3,24(sp)
ffffffffc020296e:	6a42                	ld	s4,16(sp)
ffffffffc0202970:	6aa2                	ld	s5,8(sp)
ffffffffc0202972:	6121                	addi	sp,sp,64
ffffffffc0202974:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202976:	078a                	slli	a5,a5,0x2
ffffffffc0202978:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020297a:	000b5717          	auipc	a4,0xb5
ffffffffc020297e:	e5e73703          	ld	a4,-418(a4) # ffffffffc02b77d8 <npage>
ffffffffc0202982:	06e7ff63          	bgeu	a5,a4,ffffffffc0202a00 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0202986:	000b5a97          	auipc	s5,0xb5
ffffffffc020298a:	e5aa8a93          	addi	s5,s5,-422 # ffffffffc02b77e0 <pages>
ffffffffc020298e:	000ab703          	ld	a4,0(s5)
ffffffffc0202992:	fff80937          	lui	s2,0xfff80
ffffffffc0202996:	993e                	add	s2,s2,a5
ffffffffc0202998:	091a                	slli	s2,s2,0x6
ffffffffc020299a:	993a                	add	s2,s2,a4
        if (p == page)
ffffffffc020299c:	01240c63          	beq	s0,s2,ffffffffc02029b4 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc02029a0:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fcc87ec>
ffffffffc02029a4:	fff7869b          	addiw	a3,a5,-1
ffffffffc02029a8:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) == 0)
ffffffffc02029ac:	c691                	beqz	a3,ffffffffc02029b8 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02029ae:	120a0073          	sfence.vma	s4
}
ffffffffc02029b2:	bf59                	j	ffffffffc0202948 <page_insert+0x3a>
ffffffffc02029b4:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc02029b6:	bf49                	j	ffffffffc0202948 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02029b8:	100027f3          	csrr	a5,sstatus
ffffffffc02029bc:	8b89                	andi	a5,a5,2
ffffffffc02029be:	ef91                	bnez	a5,ffffffffc02029da <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc02029c0:	000b5797          	auipc	a5,0xb5
ffffffffc02029c4:	e287b783          	ld	a5,-472(a5) # ffffffffc02b77e8 <pmm_manager>
ffffffffc02029c8:	739c                	ld	a5,32(a5)
ffffffffc02029ca:	4585                	li	a1,1
ffffffffc02029cc:	854a                	mv	a0,s2
ffffffffc02029ce:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc02029d0:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02029d4:	120a0073          	sfence.vma	s4
ffffffffc02029d8:	bf85                	j	ffffffffc0202948 <page_insert+0x3a>
        intr_disable();
ffffffffc02029da:	fdbfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02029de:	000b5797          	auipc	a5,0xb5
ffffffffc02029e2:	e0a7b783          	ld	a5,-502(a5) # ffffffffc02b77e8 <pmm_manager>
ffffffffc02029e6:	739c                	ld	a5,32(a5)
ffffffffc02029e8:	4585                	li	a1,1
ffffffffc02029ea:	854a                	mv	a0,s2
ffffffffc02029ec:	9782                	jalr	a5
        intr_enable();
ffffffffc02029ee:	fc1fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02029f2:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02029f6:	120a0073          	sfence.vma	s4
ffffffffc02029fa:	b7b9                	j	ffffffffc0202948 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc02029fc:	5571                	li	a0,-4
ffffffffc02029fe:	b79d                	j	ffffffffc0202964 <page_insert+0x56>
ffffffffc0202a00:	d80ff0ef          	jal	ra,ffffffffc0201f80 <pa2page.part.0>

ffffffffc0202a04 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202a04:	00004797          	auipc	a5,0x4
ffffffffc0202a08:	f6c78793          	addi	a5,a5,-148 # ffffffffc0206970 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202a0c:	638c                	ld	a1,0(a5)
{
ffffffffc0202a0e:	7159                	addi	sp,sp,-112
ffffffffc0202a10:	f85a                	sd	s6,48(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202a12:	00004517          	auipc	a0,0x4
ffffffffc0202a16:	10650513          	addi	a0,a0,262 # ffffffffc0206b18 <default_pmm_manager+0x1a8>
    pmm_manager = &default_pmm_manager;
ffffffffc0202a1a:	000b5b17          	auipc	s6,0xb5
ffffffffc0202a1e:	dceb0b13          	addi	s6,s6,-562 # ffffffffc02b77e8 <pmm_manager>
{
ffffffffc0202a22:	f486                	sd	ra,104(sp)
ffffffffc0202a24:	e8ca                	sd	s2,80(sp)
ffffffffc0202a26:	e4ce                	sd	s3,72(sp)
ffffffffc0202a28:	f0a2                	sd	s0,96(sp)
ffffffffc0202a2a:	eca6                	sd	s1,88(sp)
ffffffffc0202a2c:	e0d2                	sd	s4,64(sp)
ffffffffc0202a2e:	fc56                	sd	s5,56(sp)
ffffffffc0202a30:	f45e                	sd	s7,40(sp)
ffffffffc0202a32:	f062                	sd	s8,32(sp)
ffffffffc0202a34:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202a36:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202a3a:	f5afd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    pmm_manager->init();
ffffffffc0202a3e:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0202a42:	000b5997          	auipc	s3,0xb5
ffffffffc0202a46:	dae98993          	addi	s3,s3,-594 # ffffffffc02b77f0 <va_pa_offset>
    pmm_manager->init();
ffffffffc0202a4a:	679c                	ld	a5,8(a5)
ffffffffc0202a4c:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0202a4e:	57f5                	li	a5,-3
ffffffffc0202a50:	07fa                	slli	a5,a5,0x1e
ffffffffc0202a52:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc0202a56:	f45fd0ef          	jal	ra,ffffffffc020099a <get_memory_base>
ffffffffc0202a5a:	892a                	mv	s2,a0
    uint64_t mem_size = get_memory_size();
ffffffffc0202a5c:	f49fd0ef          	jal	ra,ffffffffc02009a4 <get_memory_size>
    if (mem_size == 0)
ffffffffc0202a60:	200505e3          	beqz	a0,ffffffffc020346a <pmm_init+0xa66>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc0202a64:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc0202a66:	00004517          	auipc	a0,0x4
ffffffffc0202a6a:	0ea50513          	addi	a0,a0,234 # ffffffffc0206b50 <default_pmm_manager+0x1e0>
ffffffffc0202a6e:	f26fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc0202a72:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202a76:	fff40693          	addi	a3,s0,-1
ffffffffc0202a7a:	864a                	mv	a2,s2
ffffffffc0202a7c:	85a6                	mv	a1,s1
ffffffffc0202a7e:	00004517          	auipc	a0,0x4
ffffffffc0202a82:	0ea50513          	addi	a0,a0,234 # ffffffffc0206b68 <default_pmm_manager+0x1f8>
ffffffffc0202a86:	f0efd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0202a8a:	c8000737          	lui	a4,0xc8000
ffffffffc0202a8e:	87a2                	mv	a5,s0
ffffffffc0202a90:	54876163          	bltu	a4,s0,ffffffffc0202fd2 <pmm_init+0x5ce>
ffffffffc0202a94:	757d                	lui	a0,0xfffff
ffffffffc0202a96:	000b6617          	auipc	a2,0xb6
ffffffffc0202a9a:	d7d60613          	addi	a2,a2,-643 # ffffffffc02b8813 <end+0xfff>
ffffffffc0202a9e:	8e69                	and	a2,a2,a0
ffffffffc0202aa0:	000b5497          	auipc	s1,0xb5
ffffffffc0202aa4:	d3848493          	addi	s1,s1,-712 # ffffffffc02b77d8 <npage>
ffffffffc0202aa8:	00c7d513          	srli	a0,a5,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202aac:	000b5b97          	auipc	s7,0xb5
ffffffffc0202ab0:	d34b8b93          	addi	s7,s7,-716 # ffffffffc02b77e0 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0202ab4:	e088                	sd	a0,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202ab6:	00cbb023          	sd	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202aba:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202abe:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202ac0:	02f50863          	beq	a0,a5,ffffffffc0202af0 <pmm_init+0xec>
ffffffffc0202ac4:	4781                	li	a5,0
ffffffffc0202ac6:	4585                	li	a1,1
ffffffffc0202ac8:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc0202acc:	00679513          	slli	a0,a5,0x6
ffffffffc0202ad0:	9532                	add	a0,a0,a2
ffffffffc0202ad2:	00850713          	addi	a4,a0,8 # fffffffffffff008 <end+0x3fd477f4>
ffffffffc0202ad6:	40b7302f          	amoor.d	zero,a1,(a4)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202ada:	6088                	ld	a0,0(s1)
ffffffffc0202adc:	0785                	addi	a5,a5,1
        SetPageReserved(pages + i);
ffffffffc0202ade:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202ae2:	00d50733          	add	a4,a0,a3
ffffffffc0202ae6:	fee7e3e3          	bltu	a5,a4,ffffffffc0202acc <pmm_init+0xc8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202aea:	071a                	slli	a4,a4,0x6
ffffffffc0202aec:	00e606b3          	add	a3,a2,a4
ffffffffc0202af0:	c02007b7          	lui	a5,0xc0200
ffffffffc0202af4:	2ef6ece3          	bltu	a3,a5,ffffffffc02035ec <pmm_init+0xbe8>
ffffffffc0202af8:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0202afc:	77fd                	lui	a5,0xfffff
ffffffffc0202afe:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202b00:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc0202b02:	5086eb63          	bltu	a3,s0,ffffffffc0203018 <pmm_init+0x614>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202b06:	00004517          	auipc	a0,0x4
ffffffffc0202b0a:	08a50513          	addi	a0,a0,138 # ffffffffc0206b90 <default_pmm_manager+0x220>
ffffffffc0202b0e:	e86fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc0202b12:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0202b16:	000b5917          	auipc	s2,0xb5
ffffffffc0202b1a:	cba90913          	addi	s2,s2,-838 # ffffffffc02b77d0 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc0202b1e:	7b9c                	ld	a5,48(a5)
ffffffffc0202b20:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202b22:	00004517          	auipc	a0,0x4
ffffffffc0202b26:	08650513          	addi	a0,a0,134 # ffffffffc0206ba8 <default_pmm_manager+0x238>
ffffffffc0202b2a:	e6afd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0202b2e:	00007697          	auipc	a3,0x7
ffffffffc0202b32:	4d268693          	addi	a3,a3,1234 # ffffffffc020a000 <boot_page_table_sv39>
ffffffffc0202b36:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0202b3a:	c02007b7          	lui	a5,0xc0200
ffffffffc0202b3e:	28f6ebe3          	bltu	a3,a5,ffffffffc02035d4 <pmm_init+0xbd0>
ffffffffc0202b42:	0009b783          	ld	a5,0(s3)
ffffffffc0202b46:	8e9d                	sub	a3,a3,a5
ffffffffc0202b48:	000b5797          	auipc	a5,0xb5
ffffffffc0202b4c:	c8d7b023          	sd	a3,-896(a5) # ffffffffc02b77c8 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202b50:	100027f3          	csrr	a5,sstatus
ffffffffc0202b54:	8b89                	andi	a5,a5,2
ffffffffc0202b56:	4a079763          	bnez	a5,ffffffffc0203004 <pmm_init+0x600>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202b5a:	000b3783          	ld	a5,0(s6)
ffffffffc0202b5e:	779c                	ld	a5,40(a5)
ffffffffc0202b60:	9782                	jalr	a5
ffffffffc0202b62:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202b64:	6098                	ld	a4,0(s1)
ffffffffc0202b66:	c80007b7          	lui	a5,0xc8000
ffffffffc0202b6a:	83b1                	srli	a5,a5,0xc
ffffffffc0202b6c:	66e7e363          	bltu	a5,a4,ffffffffc02031d2 <pmm_init+0x7ce>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202b70:	00093503          	ld	a0,0(s2)
ffffffffc0202b74:	62050f63          	beqz	a0,ffffffffc02031b2 <pmm_init+0x7ae>
ffffffffc0202b78:	03451793          	slli	a5,a0,0x34
ffffffffc0202b7c:	62079b63          	bnez	a5,ffffffffc02031b2 <pmm_init+0x7ae>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0202b80:	4601                	li	a2,0
ffffffffc0202b82:	4581                	li	a1,0
ffffffffc0202b84:	f14ff0ef          	jal	ra,ffffffffc0202298 <get_page>
ffffffffc0202b88:	60051563          	bnez	a0,ffffffffc0203192 <pmm_init+0x78e>
ffffffffc0202b8c:	100027f3          	csrr	a5,sstatus
ffffffffc0202b90:	8b89                	andi	a5,a5,2
ffffffffc0202b92:	44079e63          	bnez	a5,ffffffffc0202fee <pmm_init+0x5ea>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202b96:	000b3783          	ld	a5,0(s6)
ffffffffc0202b9a:	4505                	li	a0,1
ffffffffc0202b9c:	6f9c                	ld	a5,24(a5)
ffffffffc0202b9e:	9782                	jalr	a5
ffffffffc0202ba0:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0202ba2:	00093503          	ld	a0,0(s2)
ffffffffc0202ba6:	4681                	li	a3,0
ffffffffc0202ba8:	4601                	li	a2,0
ffffffffc0202baa:	85d2                	mv	a1,s4
ffffffffc0202bac:	d63ff0ef          	jal	ra,ffffffffc020290e <page_insert>
ffffffffc0202bb0:	26051ae3          	bnez	a0,ffffffffc0203624 <pmm_init+0xc20>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0202bb4:	00093503          	ld	a0,0(s2)
ffffffffc0202bb8:	4601                	li	a2,0
ffffffffc0202bba:	4581                	li	a1,0
ffffffffc0202bbc:	cb4ff0ef          	jal	ra,ffffffffc0202070 <get_pte>
ffffffffc0202bc0:	240502e3          	beqz	a0,ffffffffc0203604 <pmm_init+0xc00>
    assert(pte2page(*ptep) == p1);
ffffffffc0202bc4:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202bc6:	0017f713          	andi	a4,a5,1
ffffffffc0202bca:	5a070263          	beqz	a4,ffffffffc020316e <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc0202bce:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202bd0:	078a                	slli	a5,a5,0x2
ffffffffc0202bd2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202bd4:	58e7fb63          	bgeu	a5,a4,ffffffffc020316a <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202bd8:	000bb683          	ld	a3,0(s7)
ffffffffc0202bdc:	fff80637          	lui	a2,0xfff80
ffffffffc0202be0:	97b2                	add	a5,a5,a2
ffffffffc0202be2:	079a                	slli	a5,a5,0x6
ffffffffc0202be4:	97b6                	add	a5,a5,a3
ffffffffc0202be6:	14fa17e3          	bne	s4,a5,ffffffffc0203534 <pmm_init+0xb30>
    assert(page_ref(p1) == 1);
ffffffffc0202bea:	000a2683          	lw	a3,0(s4)
ffffffffc0202bee:	4785                	li	a5,1
ffffffffc0202bf0:	12f692e3          	bne	a3,a5,ffffffffc0203514 <pmm_init+0xb10>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0202bf4:	00093503          	ld	a0,0(s2)
ffffffffc0202bf8:	77fd                	lui	a5,0xfffff
ffffffffc0202bfa:	6114                	ld	a3,0(a0)
ffffffffc0202bfc:	068a                	slli	a3,a3,0x2
ffffffffc0202bfe:	8efd                	and	a3,a3,a5
ffffffffc0202c00:	00c6d613          	srli	a2,a3,0xc
ffffffffc0202c04:	0ee67ce3          	bgeu	a2,a4,ffffffffc02034fc <pmm_init+0xaf8>
ffffffffc0202c08:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202c0c:	96e2                	add	a3,a3,s8
ffffffffc0202c0e:	0006ba83          	ld	s5,0(a3)
ffffffffc0202c12:	0a8a                	slli	s5,s5,0x2
ffffffffc0202c14:	00fafab3          	and	s5,s5,a5
ffffffffc0202c18:	00cad793          	srli	a5,s5,0xc
ffffffffc0202c1c:	0ce7f3e3          	bgeu	a5,a4,ffffffffc02034e2 <pmm_init+0xade>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202c20:	4601                	li	a2,0
ffffffffc0202c22:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202c24:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202c26:	c4aff0ef          	jal	ra,ffffffffc0202070 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202c2a:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202c2c:	55551363          	bne	a0,s5,ffffffffc0203172 <pmm_init+0x76e>
ffffffffc0202c30:	100027f3          	csrr	a5,sstatus
ffffffffc0202c34:	8b89                	andi	a5,a5,2
ffffffffc0202c36:	3a079163          	bnez	a5,ffffffffc0202fd8 <pmm_init+0x5d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202c3a:	000b3783          	ld	a5,0(s6)
ffffffffc0202c3e:	4505                	li	a0,1
ffffffffc0202c40:	6f9c                	ld	a5,24(a5)
ffffffffc0202c42:	9782                	jalr	a5
ffffffffc0202c44:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202c46:	00093503          	ld	a0,0(s2)
ffffffffc0202c4a:	46d1                	li	a3,20
ffffffffc0202c4c:	6605                	lui	a2,0x1
ffffffffc0202c4e:	85e2                	mv	a1,s8
ffffffffc0202c50:	cbfff0ef          	jal	ra,ffffffffc020290e <page_insert>
ffffffffc0202c54:	060517e3          	bnez	a0,ffffffffc02034c2 <pmm_init+0xabe>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202c58:	00093503          	ld	a0,0(s2)
ffffffffc0202c5c:	4601                	li	a2,0
ffffffffc0202c5e:	6585                	lui	a1,0x1
ffffffffc0202c60:	c10ff0ef          	jal	ra,ffffffffc0202070 <get_pte>
ffffffffc0202c64:	02050fe3          	beqz	a0,ffffffffc02034a2 <pmm_init+0xa9e>
    assert(*ptep & PTE_U);
ffffffffc0202c68:	611c                	ld	a5,0(a0)
ffffffffc0202c6a:	0107f713          	andi	a4,a5,16
ffffffffc0202c6e:	7c070e63          	beqz	a4,ffffffffc020344a <pmm_init+0xa46>
    assert(*ptep & PTE_W);
ffffffffc0202c72:	8b91                	andi	a5,a5,4
ffffffffc0202c74:	7a078b63          	beqz	a5,ffffffffc020342a <pmm_init+0xa26>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0202c78:	00093503          	ld	a0,0(s2)
ffffffffc0202c7c:	611c                	ld	a5,0(a0)
ffffffffc0202c7e:	8bc1                	andi	a5,a5,16
ffffffffc0202c80:	78078563          	beqz	a5,ffffffffc020340a <pmm_init+0xa06>
    assert(page_ref(p2) == 1);
ffffffffc0202c84:	000c2703          	lw	a4,0(s8)
ffffffffc0202c88:	4785                	li	a5,1
ffffffffc0202c8a:	76f71063          	bne	a4,a5,ffffffffc02033ea <pmm_init+0x9e6>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0202c8e:	4681                	li	a3,0
ffffffffc0202c90:	6605                	lui	a2,0x1
ffffffffc0202c92:	85d2                	mv	a1,s4
ffffffffc0202c94:	c7bff0ef          	jal	ra,ffffffffc020290e <page_insert>
ffffffffc0202c98:	72051963          	bnez	a0,ffffffffc02033ca <pmm_init+0x9c6>
    assert(page_ref(p1) == 2);
ffffffffc0202c9c:	000a2703          	lw	a4,0(s4)
ffffffffc0202ca0:	4789                	li	a5,2
ffffffffc0202ca2:	70f71463          	bne	a4,a5,ffffffffc02033aa <pmm_init+0x9a6>
    assert(page_ref(p2) == 0);
ffffffffc0202ca6:	000c2783          	lw	a5,0(s8)
ffffffffc0202caa:	6e079063          	bnez	a5,ffffffffc020338a <pmm_init+0x986>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202cae:	00093503          	ld	a0,0(s2)
ffffffffc0202cb2:	4601                	li	a2,0
ffffffffc0202cb4:	6585                	lui	a1,0x1
ffffffffc0202cb6:	bbaff0ef          	jal	ra,ffffffffc0202070 <get_pte>
ffffffffc0202cba:	6a050863          	beqz	a0,ffffffffc020336a <pmm_init+0x966>
    assert(pte2page(*ptep) == p1);
ffffffffc0202cbe:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202cc0:	00177793          	andi	a5,a4,1
ffffffffc0202cc4:	4a078563          	beqz	a5,ffffffffc020316e <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc0202cc8:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202cca:	00271793          	slli	a5,a4,0x2
ffffffffc0202cce:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202cd0:	48d7fd63          	bgeu	a5,a3,ffffffffc020316a <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202cd4:	000bb683          	ld	a3,0(s7)
ffffffffc0202cd8:	fff80ab7          	lui	s5,0xfff80
ffffffffc0202cdc:	97d6                	add	a5,a5,s5
ffffffffc0202cde:	079a                	slli	a5,a5,0x6
ffffffffc0202ce0:	97b6                	add	a5,a5,a3
ffffffffc0202ce2:	66fa1463          	bne	s4,a5,ffffffffc020334a <pmm_init+0x946>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202ce6:	8b41                	andi	a4,a4,16
ffffffffc0202ce8:	64071163          	bnez	a4,ffffffffc020332a <pmm_init+0x926>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc0202cec:	00093503          	ld	a0,0(s2)
ffffffffc0202cf0:	4581                	li	a1,0
ffffffffc0202cf2:	9d3ff0ef          	jal	ra,ffffffffc02026c4 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202cf6:	000a2c83          	lw	s9,0(s4)
ffffffffc0202cfa:	4785                	li	a5,1
ffffffffc0202cfc:	60fc9763          	bne	s9,a5,ffffffffc020330a <pmm_init+0x906>
    assert(page_ref(p2) == 0);
ffffffffc0202d00:	000c2783          	lw	a5,0(s8)
ffffffffc0202d04:	5e079363          	bnez	a5,ffffffffc02032ea <pmm_init+0x8e6>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc0202d08:	00093503          	ld	a0,0(s2)
ffffffffc0202d0c:	6585                	lui	a1,0x1
ffffffffc0202d0e:	9b7ff0ef          	jal	ra,ffffffffc02026c4 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202d12:	000a2783          	lw	a5,0(s4)
ffffffffc0202d16:	52079a63          	bnez	a5,ffffffffc020324a <pmm_init+0x846>
    assert(page_ref(p2) == 0);
ffffffffc0202d1a:	000c2783          	lw	a5,0(s8)
ffffffffc0202d1e:	50079663          	bnez	a5,ffffffffc020322a <pmm_init+0x826>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202d22:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202d26:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d28:	000a3683          	ld	a3,0(s4)
ffffffffc0202d2c:	068a                	slli	a3,a3,0x2
ffffffffc0202d2e:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0202d30:	42b6fd63          	bgeu	a3,a1,ffffffffc020316a <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d34:	000bb503          	ld	a0,0(s7)
ffffffffc0202d38:	96d6                	add	a3,a3,s5
ffffffffc0202d3a:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0202d3c:	00d507b3          	add	a5,a0,a3
ffffffffc0202d40:	439c                	lw	a5,0(a5)
ffffffffc0202d42:	4d979463          	bne	a5,s9,ffffffffc020320a <pmm_init+0x806>
    return page - pages + nbase;
ffffffffc0202d46:	8699                	srai	a3,a3,0x6
ffffffffc0202d48:	00080637          	lui	a2,0x80
ffffffffc0202d4c:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0202d4e:	00c69713          	slli	a4,a3,0xc
ffffffffc0202d52:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202d54:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202d56:	48b77e63          	bgeu	a4,a1,ffffffffc02031f2 <pmm_init+0x7ee>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202d5a:	0009b703          	ld	a4,0(s3)
ffffffffc0202d5e:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d60:	629c                	ld	a5,0(a3)
ffffffffc0202d62:	078a                	slli	a5,a5,0x2
ffffffffc0202d64:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202d66:	40b7f263          	bgeu	a5,a1,ffffffffc020316a <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d6a:	8f91                	sub	a5,a5,a2
ffffffffc0202d6c:	079a                	slli	a5,a5,0x6
ffffffffc0202d6e:	953e                	add	a0,a0,a5
ffffffffc0202d70:	100027f3          	csrr	a5,sstatus
ffffffffc0202d74:	8b89                	andi	a5,a5,2
ffffffffc0202d76:	30079963          	bnez	a5,ffffffffc0203088 <pmm_init+0x684>
        pmm_manager->free_pages(base, n);
ffffffffc0202d7a:	000b3783          	ld	a5,0(s6)
ffffffffc0202d7e:	4585                	li	a1,1
ffffffffc0202d80:	739c                	ld	a5,32(a5)
ffffffffc0202d82:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d84:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202d88:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d8a:	078a                	slli	a5,a5,0x2
ffffffffc0202d8c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202d8e:	3ce7fe63          	bgeu	a5,a4,ffffffffc020316a <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d92:	000bb503          	ld	a0,0(s7)
ffffffffc0202d96:	fff80737          	lui	a4,0xfff80
ffffffffc0202d9a:	97ba                	add	a5,a5,a4
ffffffffc0202d9c:	079a                	slli	a5,a5,0x6
ffffffffc0202d9e:	953e                	add	a0,a0,a5
ffffffffc0202da0:	100027f3          	csrr	a5,sstatus
ffffffffc0202da4:	8b89                	andi	a5,a5,2
ffffffffc0202da6:	2c079563          	bnez	a5,ffffffffc0203070 <pmm_init+0x66c>
ffffffffc0202daa:	000b3783          	ld	a5,0(s6)
ffffffffc0202dae:	4585                	li	a1,1
ffffffffc0202db0:	739c                	ld	a5,32(a5)
ffffffffc0202db2:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202db4:	00093783          	ld	a5,0(s2)
ffffffffc0202db8:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd477ec>
    asm volatile("sfence.vma");
ffffffffc0202dbc:	12000073          	sfence.vma
ffffffffc0202dc0:	100027f3          	csrr	a5,sstatus
ffffffffc0202dc4:	8b89                	andi	a5,a5,2
ffffffffc0202dc6:	28079b63          	bnez	a5,ffffffffc020305c <pmm_init+0x658>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202dca:	000b3783          	ld	a5,0(s6)
ffffffffc0202dce:	779c                	ld	a5,40(a5)
ffffffffc0202dd0:	9782                	jalr	a5
ffffffffc0202dd2:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202dd4:	4b441b63          	bne	s0,s4,ffffffffc020328a <pmm_init+0x886>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202dd8:	00004517          	auipc	a0,0x4
ffffffffc0202ddc:	0f850513          	addi	a0,a0,248 # ffffffffc0206ed0 <default_pmm_manager+0x560>
ffffffffc0202de0:	bb4fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0202de4:	100027f3          	csrr	a5,sstatus
ffffffffc0202de8:	8b89                	andi	a5,a5,2
ffffffffc0202dea:	24079f63          	bnez	a5,ffffffffc0203048 <pmm_init+0x644>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202dee:	000b3783          	ld	a5,0(s6)
ffffffffc0202df2:	779c                	ld	a5,40(a5)
ffffffffc0202df4:	9782                	jalr	a5
ffffffffc0202df6:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202df8:	6098                	ld	a4,0(s1)
ffffffffc0202dfa:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202dfe:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202e00:	00c71793          	slli	a5,a4,0xc
ffffffffc0202e04:	6a05                	lui	s4,0x1
ffffffffc0202e06:	02f47c63          	bgeu	s0,a5,ffffffffc0202e3e <pmm_init+0x43a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202e0a:	00c45793          	srli	a5,s0,0xc
ffffffffc0202e0e:	00093503          	ld	a0,0(s2)
ffffffffc0202e12:	2ee7ff63          	bgeu	a5,a4,ffffffffc0203110 <pmm_init+0x70c>
ffffffffc0202e16:	0009b583          	ld	a1,0(s3)
ffffffffc0202e1a:	4601                	li	a2,0
ffffffffc0202e1c:	95a2                	add	a1,a1,s0
ffffffffc0202e1e:	a52ff0ef          	jal	ra,ffffffffc0202070 <get_pte>
ffffffffc0202e22:	32050463          	beqz	a0,ffffffffc020314a <pmm_init+0x746>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202e26:	611c                	ld	a5,0(a0)
ffffffffc0202e28:	078a                	slli	a5,a5,0x2
ffffffffc0202e2a:	0157f7b3          	and	a5,a5,s5
ffffffffc0202e2e:	2e879e63          	bne	a5,s0,ffffffffc020312a <pmm_init+0x726>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202e32:	6098                	ld	a4,0(s1)
ffffffffc0202e34:	9452                	add	s0,s0,s4
ffffffffc0202e36:	00c71793          	slli	a5,a4,0xc
ffffffffc0202e3a:	fcf468e3          	bltu	s0,a5,ffffffffc0202e0a <pmm_init+0x406>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc0202e3e:	00093783          	ld	a5,0(s2)
ffffffffc0202e42:	639c                	ld	a5,0(a5)
ffffffffc0202e44:	42079363          	bnez	a5,ffffffffc020326a <pmm_init+0x866>
ffffffffc0202e48:	100027f3          	csrr	a5,sstatus
ffffffffc0202e4c:	8b89                	andi	a5,a5,2
ffffffffc0202e4e:	24079963          	bnez	a5,ffffffffc02030a0 <pmm_init+0x69c>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202e52:	000b3783          	ld	a5,0(s6)
ffffffffc0202e56:	4505                	li	a0,1
ffffffffc0202e58:	6f9c                	ld	a5,24(a5)
ffffffffc0202e5a:	9782                	jalr	a5
ffffffffc0202e5c:	8a2a                	mv	s4,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202e5e:	00093503          	ld	a0,0(s2)
ffffffffc0202e62:	4699                	li	a3,6
ffffffffc0202e64:	10000613          	li	a2,256
ffffffffc0202e68:	85d2                	mv	a1,s4
ffffffffc0202e6a:	aa5ff0ef          	jal	ra,ffffffffc020290e <page_insert>
ffffffffc0202e6e:	44051e63          	bnez	a0,ffffffffc02032ca <pmm_init+0x8c6>
    assert(page_ref(p) == 1);
ffffffffc0202e72:	000a2703          	lw	a4,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc0202e76:	4785                	li	a5,1
ffffffffc0202e78:	42f71963          	bne	a4,a5,ffffffffc02032aa <pmm_init+0x8a6>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202e7c:	00093503          	ld	a0,0(s2)
ffffffffc0202e80:	6405                	lui	s0,0x1
ffffffffc0202e82:	4699                	li	a3,6
ffffffffc0202e84:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8ab0>
ffffffffc0202e88:	85d2                	mv	a1,s4
ffffffffc0202e8a:	a85ff0ef          	jal	ra,ffffffffc020290e <page_insert>
ffffffffc0202e8e:	72051363          	bnez	a0,ffffffffc02035b4 <pmm_init+0xbb0>
    assert(page_ref(p) == 2);
ffffffffc0202e92:	000a2703          	lw	a4,0(s4)
ffffffffc0202e96:	4789                	li	a5,2
ffffffffc0202e98:	6ef71e63          	bne	a4,a5,ffffffffc0203594 <pmm_init+0xb90>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202e9c:	00004597          	auipc	a1,0x4
ffffffffc0202ea0:	17c58593          	addi	a1,a1,380 # ffffffffc0207018 <default_pmm_manager+0x6a8>
ffffffffc0202ea4:	10000513          	li	a0,256
ffffffffc0202ea8:	34d020ef          	jal	ra,ffffffffc02059f4 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202eac:	10040593          	addi	a1,s0,256
ffffffffc0202eb0:	10000513          	li	a0,256
ffffffffc0202eb4:	353020ef          	jal	ra,ffffffffc0205a06 <strcmp>
ffffffffc0202eb8:	6a051e63          	bnez	a0,ffffffffc0203574 <pmm_init+0xb70>
    return page - pages + nbase;
ffffffffc0202ebc:	000bb683          	ld	a3,0(s7)
ffffffffc0202ec0:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202ec4:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0202ec6:	40da06b3          	sub	a3,s4,a3
ffffffffc0202eca:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202ecc:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202ece:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202ed0:	8031                	srli	s0,s0,0xc
ffffffffc0202ed2:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ed6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202ed8:	30f77d63          	bgeu	a4,a5,ffffffffc02031f2 <pmm_init+0x7ee>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202edc:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202ee0:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202ee4:	96be                	add	a3,a3,a5
ffffffffc0202ee6:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202eea:	2d5020ef          	jal	ra,ffffffffc02059be <strlen>
ffffffffc0202eee:	66051363          	bnez	a0,ffffffffc0203554 <pmm_init+0xb50>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0202ef2:	00093a83          	ld	s5,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202ef6:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ef8:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fd477ec>
ffffffffc0202efc:	068a                	slli	a3,a3,0x2
ffffffffc0202efe:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0202f00:	26f6f563          	bgeu	a3,a5,ffffffffc020316a <pmm_init+0x766>
    return KADDR(page2pa(page));
ffffffffc0202f04:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202f06:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202f08:	2ef47563          	bgeu	s0,a5,ffffffffc02031f2 <pmm_init+0x7ee>
ffffffffc0202f0c:	0009b403          	ld	s0,0(s3)
ffffffffc0202f10:	9436                	add	s0,s0,a3
ffffffffc0202f12:	100027f3          	csrr	a5,sstatus
ffffffffc0202f16:	8b89                	andi	a5,a5,2
ffffffffc0202f18:	1e079163          	bnez	a5,ffffffffc02030fa <pmm_init+0x6f6>
        pmm_manager->free_pages(base, n);
ffffffffc0202f1c:	000b3783          	ld	a5,0(s6)
ffffffffc0202f20:	4585                	li	a1,1
ffffffffc0202f22:	8552                	mv	a0,s4
ffffffffc0202f24:	739c                	ld	a5,32(a5)
ffffffffc0202f26:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f28:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage)
ffffffffc0202f2a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f2c:	078a                	slli	a5,a5,0x2
ffffffffc0202f2e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202f30:	22e7fd63          	bgeu	a5,a4,ffffffffc020316a <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f34:	000bb503          	ld	a0,0(s7)
ffffffffc0202f38:	fff80737          	lui	a4,0xfff80
ffffffffc0202f3c:	97ba                	add	a5,a5,a4
ffffffffc0202f3e:	079a                	slli	a5,a5,0x6
ffffffffc0202f40:	953e                	add	a0,a0,a5
ffffffffc0202f42:	100027f3          	csrr	a5,sstatus
ffffffffc0202f46:	8b89                	andi	a5,a5,2
ffffffffc0202f48:	18079d63          	bnez	a5,ffffffffc02030e2 <pmm_init+0x6de>
ffffffffc0202f4c:	000b3783          	ld	a5,0(s6)
ffffffffc0202f50:	4585                	li	a1,1
ffffffffc0202f52:	739c                	ld	a5,32(a5)
ffffffffc0202f54:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f56:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage)
ffffffffc0202f5a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f5c:	078a                	slli	a5,a5,0x2
ffffffffc0202f5e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202f60:	20e7f563          	bgeu	a5,a4,ffffffffc020316a <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f64:	000bb503          	ld	a0,0(s7)
ffffffffc0202f68:	fff80737          	lui	a4,0xfff80
ffffffffc0202f6c:	97ba                	add	a5,a5,a4
ffffffffc0202f6e:	079a                	slli	a5,a5,0x6
ffffffffc0202f70:	953e                	add	a0,a0,a5
ffffffffc0202f72:	100027f3          	csrr	a5,sstatus
ffffffffc0202f76:	8b89                	andi	a5,a5,2
ffffffffc0202f78:	14079963          	bnez	a5,ffffffffc02030ca <pmm_init+0x6c6>
ffffffffc0202f7c:	000b3783          	ld	a5,0(s6)
ffffffffc0202f80:	4585                	li	a1,1
ffffffffc0202f82:	739c                	ld	a5,32(a5)
ffffffffc0202f84:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202f86:	00093783          	ld	a5,0(s2)
ffffffffc0202f8a:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc0202f8e:	12000073          	sfence.vma
ffffffffc0202f92:	100027f3          	csrr	a5,sstatus
ffffffffc0202f96:	8b89                	andi	a5,a5,2
ffffffffc0202f98:	10079f63          	bnez	a5,ffffffffc02030b6 <pmm_init+0x6b2>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202f9c:	000b3783          	ld	a5,0(s6)
ffffffffc0202fa0:	779c                	ld	a5,40(a5)
ffffffffc0202fa2:	9782                	jalr	a5
ffffffffc0202fa4:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202fa6:	4c8c1e63          	bne	s8,s0,ffffffffc0203482 <pmm_init+0xa7e>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202faa:	00004517          	auipc	a0,0x4
ffffffffc0202fae:	0e650513          	addi	a0,a0,230 # ffffffffc0207090 <default_pmm_manager+0x720>
ffffffffc0202fb2:	9e2fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
}
ffffffffc0202fb6:	7406                	ld	s0,96(sp)
ffffffffc0202fb8:	70a6                	ld	ra,104(sp)
ffffffffc0202fba:	64e6                	ld	s1,88(sp)
ffffffffc0202fbc:	6946                	ld	s2,80(sp)
ffffffffc0202fbe:	69a6                	ld	s3,72(sp)
ffffffffc0202fc0:	6a06                	ld	s4,64(sp)
ffffffffc0202fc2:	7ae2                	ld	s5,56(sp)
ffffffffc0202fc4:	7b42                	ld	s6,48(sp)
ffffffffc0202fc6:	7ba2                	ld	s7,40(sp)
ffffffffc0202fc8:	7c02                	ld	s8,32(sp)
ffffffffc0202fca:	6ce2                	ld	s9,24(sp)
ffffffffc0202fcc:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0202fce:	de9fe06f          	j	ffffffffc0201db6 <kmalloc_init>
    npage = maxpa / PGSIZE;
ffffffffc0202fd2:	c80007b7          	lui	a5,0xc8000
ffffffffc0202fd6:	bc7d                	j	ffffffffc0202a94 <pmm_init+0x90>
        intr_disable();
ffffffffc0202fd8:	9ddfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202fdc:	000b3783          	ld	a5,0(s6)
ffffffffc0202fe0:	4505                	li	a0,1
ffffffffc0202fe2:	6f9c                	ld	a5,24(a5)
ffffffffc0202fe4:	9782                	jalr	a5
ffffffffc0202fe6:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202fe8:	9c7fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202fec:	b9a9                	j	ffffffffc0202c46 <pmm_init+0x242>
        intr_disable();
ffffffffc0202fee:	9c7fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202ff2:	000b3783          	ld	a5,0(s6)
ffffffffc0202ff6:	4505                	li	a0,1
ffffffffc0202ff8:	6f9c                	ld	a5,24(a5)
ffffffffc0202ffa:	9782                	jalr	a5
ffffffffc0202ffc:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202ffe:	9b1fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0203002:	b645                	j	ffffffffc0202ba2 <pmm_init+0x19e>
        intr_disable();
ffffffffc0203004:	9b1fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203008:	000b3783          	ld	a5,0(s6)
ffffffffc020300c:	779c                	ld	a5,40(a5)
ffffffffc020300e:	9782                	jalr	a5
ffffffffc0203010:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203012:	99dfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0203016:	b6b9                	j	ffffffffc0202b64 <pmm_init+0x160>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0203018:	6705                	lui	a4,0x1
ffffffffc020301a:	177d                	addi	a4,a4,-1
ffffffffc020301c:	96ba                	add	a3,a3,a4
ffffffffc020301e:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc0203020:	00c7d713          	srli	a4,a5,0xc
ffffffffc0203024:	14a77363          	bgeu	a4,a0,ffffffffc020316a <pmm_init+0x766>
    pmm_manager->init_memmap(base, n);
ffffffffc0203028:	000b3683          	ld	a3,0(s6)
    return &pages[PPN(pa) - nbase];
ffffffffc020302c:	fff80537          	lui	a0,0xfff80
ffffffffc0203030:	972a                	add	a4,a4,a0
ffffffffc0203032:	6a94                	ld	a3,16(a3)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0203034:	8c1d                	sub	s0,s0,a5
ffffffffc0203036:	00671513          	slli	a0,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc020303a:	00c45593          	srli	a1,s0,0xc
ffffffffc020303e:	9532                	add	a0,a0,a2
ffffffffc0203040:	9682                	jalr	a3
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0203042:	0009b583          	ld	a1,0(s3)
}
ffffffffc0203046:	b4c1                	j	ffffffffc0202b06 <pmm_init+0x102>
        intr_disable();
ffffffffc0203048:	96dfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020304c:	000b3783          	ld	a5,0(s6)
ffffffffc0203050:	779c                	ld	a5,40(a5)
ffffffffc0203052:	9782                	jalr	a5
ffffffffc0203054:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0203056:	959fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020305a:	bb79                	j	ffffffffc0202df8 <pmm_init+0x3f4>
        intr_disable();
ffffffffc020305c:	959fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0203060:	000b3783          	ld	a5,0(s6)
ffffffffc0203064:	779c                	ld	a5,40(a5)
ffffffffc0203066:	9782                	jalr	a5
ffffffffc0203068:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc020306a:	945fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020306e:	b39d                	j	ffffffffc0202dd4 <pmm_init+0x3d0>
ffffffffc0203070:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203072:	943fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203076:	000b3783          	ld	a5,0(s6)
ffffffffc020307a:	6522                	ld	a0,8(sp)
ffffffffc020307c:	4585                	li	a1,1
ffffffffc020307e:	739c                	ld	a5,32(a5)
ffffffffc0203080:	9782                	jalr	a5
        intr_enable();
ffffffffc0203082:	92dfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0203086:	b33d                	j	ffffffffc0202db4 <pmm_init+0x3b0>
ffffffffc0203088:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020308a:	92bfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc020308e:	000b3783          	ld	a5,0(s6)
ffffffffc0203092:	6522                	ld	a0,8(sp)
ffffffffc0203094:	4585                	li	a1,1
ffffffffc0203096:	739c                	ld	a5,32(a5)
ffffffffc0203098:	9782                	jalr	a5
        intr_enable();
ffffffffc020309a:	915fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020309e:	b1dd                	j	ffffffffc0202d84 <pmm_init+0x380>
        intr_disable();
ffffffffc02030a0:	915fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02030a4:	000b3783          	ld	a5,0(s6)
ffffffffc02030a8:	4505                	li	a0,1
ffffffffc02030aa:	6f9c                	ld	a5,24(a5)
ffffffffc02030ac:	9782                	jalr	a5
ffffffffc02030ae:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc02030b0:	8fffd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02030b4:	b36d                	j	ffffffffc0202e5e <pmm_init+0x45a>
        intr_disable();
ffffffffc02030b6:	8fffd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02030ba:	000b3783          	ld	a5,0(s6)
ffffffffc02030be:	779c                	ld	a5,40(a5)
ffffffffc02030c0:	9782                	jalr	a5
ffffffffc02030c2:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02030c4:	8ebfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02030c8:	bdf9                	j	ffffffffc0202fa6 <pmm_init+0x5a2>
ffffffffc02030ca:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02030cc:	8e9fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02030d0:	000b3783          	ld	a5,0(s6)
ffffffffc02030d4:	6522                	ld	a0,8(sp)
ffffffffc02030d6:	4585                	li	a1,1
ffffffffc02030d8:	739c                	ld	a5,32(a5)
ffffffffc02030da:	9782                	jalr	a5
        intr_enable();
ffffffffc02030dc:	8d3fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02030e0:	b55d                	j	ffffffffc0202f86 <pmm_init+0x582>
ffffffffc02030e2:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02030e4:	8d1fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc02030e8:	000b3783          	ld	a5,0(s6)
ffffffffc02030ec:	6522                	ld	a0,8(sp)
ffffffffc02030ee:	4585                	li	a1,1
ffffffffc02030f0:	739c                	ld	a5,32(a5)
ffffffffc02030f2:	9782                	jalr	a5
        intr_enable();
ffffffffc02030f4:	8bbfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02030f8:	bdb9                	j	ffffffffc0202f56 <pmm_init+0x552>
        intr_disable();
ffffffffc02030fa:	8bbfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc02030fe:	000b3783          	ld	a5,0(s6)
ffffffffc0203102:	4585                	li	a1,1
ffffffffc0203104:	8552                	mv	a0,s4
ffffffffc0203106:	739c                	ld	a5,32(a5)
ffffffffc0203108:	9782                	jalr	a5
        intr_enable();
ffffffffc020310a:	8a5fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020310e:	bd29                	j	ffffffffc0202f28 <pmm_init+0x524>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203110:	86a2                	mv	a3,s0
ffffffffc0203112:	00004617          	auipc	a2,0x4
ffffffffc0203116:	89660613          	addi	a2,a2,-1898 # ffffffffc02069a8 <default_pmm_manager+0x38>
ffffffffc020311a:	28700593          	li	a1,647
ffffffffc020311e:	00004517          	auipc	a0,0x4
ffffffffc0203122:	9a250513          	addi	a0,a0,-1630 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203126:	b68fd0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020312a:	00004697          	auipc	a3,0x4
ffffffffc020312e:	e0668693          	addi	a3,a3,-506 # ffffffffc0206f30 <default_pmm_manager+0x5c0>
ffffffffc0203132:	00003617          	auipc	a2,0x3
ffffffffc0203136:	48e60613          	addi	a2,a2,1166 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc020313a:	28800593          	li	a1,648
ffffffffc020313e:	00004517          	auipc	a0,0x4
ffffffffc0203142:	98250513          	addi	a0,a0,-1662 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203146:	b48fd0ef          	jal	ra,ffffffffc020048e <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020314a:	00004697          	auipc	a3,0x4
ffffffffc020314e:	da668693          	addi	a3,a3,-602 # ffffffffc0206ef0 <default_pmm_manager+0x580>
ffffffffc0203152:	00003617          	auipc	a2,0x3
ffffffffc0203156:	46e60613          	addi	a2,a2,1134 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc020315a:	28700593          	li	a1,647
ffffffffc020315e:	00004517          	auipc	a0,0x4
ffffffffc0203162:	96250513          	addi	a0,a0,-1694 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203166:	b28fd0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc020316a:	e17fe0ef          	jal	ra,ffffffffc0201f80 <pa2page.part.0>
ffffffffc020316e:	e2ffe0ef          	jal	ra,ffffffffc0201f9c <pte2page.part.0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0203172:	00004697          	auipc	a3,0x4
ffffffffc0203176:	b7668693          	addi	a3,a3,-1162 # ffffffffc0206ce8 <default_pmm_manager+0x378>
ffffffffc020317a:	00003617          	auipc	a2,0x3
ffffffffc020317e:	44660613          	addi	a2,a2,1094 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203182:	25700593          	li	a1,599
ffffffffc0203186:	00004517          	auipc	a0,0x4
ffffffffc020318a:	93a50513          	addi	a0,a0,-1734 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc020318e:	b00fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0203192:	00004697          	auipc	a3,0x4
ffffffffc0203196:	a9668693          	addi	a3,a3,-1386 # ffffffffc0206c28 <default_pmm_manager+0x2b8>
ffffffffc020319a:	00003617          	auipc	a2,0x3
ffffffffc020319e:	42660613          	addi	a2,a2,1062 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02031a2:	24a00593          	li	a1,586
ffffffffc02031a6:	00004517          	auipc	a0,0x4
ffffffffc02031aa:	91a50513          	addi	a0,a0,-1766 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc02031ae:	ae0fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc02031b2:	00004697          	auipc	a3,0x4
ffffffffc02031b6:	a3668693          	addi	a3,a3,-1482 # ffffffffc0206be8 <default_pmm_manager+0x278>
ffffffffc02031ba:	00003617          	auipc	a2,0x3
ffffffffc02031be:	40660613          	addi	a2,a2,1030 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02031c2:	24900593          	li	a1,585
ffffffffc02031c6:	00004517          	auipc	a0,0x4
ffffffffc02031ca:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc02031ce:	ac0fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02031d2:	00004697          	auipc	a3,0x4
ffffffffc02031d6:	9f668693          	addi	a3,a3,-1546 # ffffffffc0206bc8 <default_pmm_manager+0x258>
ffffffffc02031da:	00003617          	auipc	a2,0x3
ffffffffc02031de:	3e660613          	addi	a2,a2,998 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02031e2:	24800593          	li	a1,584
ffffffffc02031e6:	00004517          	auipc	a0,0x4
ffffffffc02031ea:	8da50513          	addi	a0,a0,-1830 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc02031ee:	aa0fd0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc02031f2:	00003617          	auipc	a2,0x3
ffffffffc02031f6:	7b660613          	addi	a2,a2,1974 # ffffffffc02069a8 <default_pmm_manager+0x38>
ffffffffc02031fa:	07700593          	li	a1,119
ffffffffc02031fe:	00003517          	auipc	a0,0x3
ffffffffc0203202:	7d250513          	addi	a0,a0,2002 # ffffffffc02069d0 <default_pmm_manager+0x60>
ffffffffc0203206:	a88fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc020320a:	00004697          	auipc	a3,0x4
ffffffffc020320e:	c6e68693          	addi	a3,a3,-914 # ffffffffc0206e78 <default_pmm_manager+0x508>
ffffffffc0203212:	00003617          	auipc	a2,0x3
ffffffffc0203216:	3ae60613          	addi	a2,a2,942 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc020321a:	27000593          	li	a1,624
ffffffffc020321e:	00004517          	auipc	a0,0x4
ffffffffc0203222:	8a250513          	addi	a0,a0,-1886 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203226:	a68fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020322a:	00004697          	auipc	a3,0x4
ffffffffc020322e:	c0668693          	addi	a3,a3,-1018 # ffffffffc0206e30 <default_pmm_manager+0x4c0>
ffffffffc0203232:	00003617          	auipc	a2,0x3
ffffffffc0203236:	38e60613          	addi	a2,a2,910 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc020323a:	26e00593          	li	a1,622
ffffffffc020323e:	00004517          	auipc	a0,0x4
ffffffffc0203242:	88250513          	addi	a0,a0,-1918 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203246:	a48fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 0);
ffffffffc020324a:	00004697          	auipc	a3,0x4
ffffffffc020324e:	c1668693          	addi	a3,a3,-1002 # ffffffffc0206e60 <default_pmm_manager+0x4f0>
ffffffffc0203252:	00003617          	auipc	a2,0x3
ffffffffc0203256:	36e60613          	addi	a2,a2,878 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc020325a:	26d00593          	li	a1,621
ffffffffc020325e:	00004517          	auipc	a0,0x4
ffffffffc0203262:	86250513          	addi	a0,a0,-1950 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203266:	a28fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc020326a:	00004697          	auipc	a3,0x4
ffffffffc020326e:	cde68693          	addi	a3,a3,-802 # ffffffffc0206f48 <default_pmm_manager+0x5d8>
ffffffffc0203272:	00003617          	auipc	a2,0x3
ffffffffc0203276:	34e60613          	addi	a2,a2,846 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc020327a:	28b00593          	li	a1,651
ffffffffc020327e:	00004517          	auipc	a0,0x4
ffffffffc0203282:	84250513          	addi	a0,a0,-1982 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203286:	a08fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc020328a:	00004697          	auipc	a3,0x4
ffffffffc020328e:	c1e68693          	addi	a3,a3,-994 # ffffffffc0206ea8 <default_pmm_manager+0x538>
ffffffffc0203292:	00003617          	auipc	a2,0x3
ffffffffc0203296:	32e60613          	addi	a2,a2,814 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc020329a:	27800593          	li	a1,632
ffffffffc020329e:	00004517          	auipc	a0,0x4
ffffffffc02032a2:	82250513          	addi	a0,a0,-2014 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc02032a6:	9e8fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p) == 1);
ffffffffc02032aa:	00004697          	auipc	a3,0x4
ffffffffc02032ae:	cf668693          	addi	a3,a3,-778 # ffffffffc0206fa0 <default_pmm_manager+0x630>
ffffffffc02032b2:	00003617          	auipc	a2,0x3
ffffffffc02032b6:	30e60613          	addi	a2,a2,782 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02032ba:	29000593          	li	a1,656
ffffffffc02032be:	00004517          	auipc	a0,0x4
ffffffffc02032c2:	80250513          	addi	a0,a0,-2046 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc02032c6:	9c8fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02032ca:	00004697          	auipc	a3,0x4
ffffffffc02032ce:	c9668693          	addi	a3,a3,-874 # ffffffffc0206f60 <default_pmm_manager+0x5f0>
ffffffffc02032d2:	00003617          	auipc	a2,0x3
ffffffffc02032d6:	2ee60613          	addi	a2,a2,750 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02032da:	28f00593          	li	a1,655
ffffffffc02032de:	00003517          	auipc	a0,0x3
ffffffffc02032e2:	7e250513          	addi	a0,a0,2018 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc02032e6:	9a8fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02032ea:	00004697          	auipc	a3,0x4
ffffffffc02032ee:	b4668693          	addi	a3,a3,-1210 # ffffffffc0206e30 <default_pmm_manager+0x4c0>
ffffffffc02032f2:	00003617          	auipc	a2,0x3
ffffffffc02032f6:	2ce60613          	addi	a2,a2,718 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02032fa:	26a00593          	li	a1,618
ffffffffc02032fe:	00003517          	auipc	a0,0x3
ffffffffc0203302:	7c250513          	addi	a0,a0,1986 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203306:	988fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020330a:	00004697          	auipc	a3,0x4
ffffffffc020330e:	9c668693          	addi	a3,a3,-1594 # ffffffffc0206cd0 <default_pmm_manager+0x360>
ffffffffc0203312:	00003617          	auipc	a2,0x3
ffffffffc0203316:	2ae60613          	addi	a2,a2,686 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc020331a:	26900593          	li	a1,617
ffffffffc020331e:	00003517          	auipc	a0,0x3
ffffffffc0203322:	7a250513          	addi	a0,a0,1954 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203326:	968fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020332a:	00004697          	auipc	a3,0x4
ffffffffc020332e:	b1e68693          	addi	a3,a3,-1250 # ffffffffc0206e48 <default_pmm_manager+0x4d8>
ffffffffc0203332:	00003617          	auipc	a2,0x3
ffffffffc0203336:	28e60613          	addi	a2,a2,654 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc020333a:	26600593          	li	a1,614
ffffffffc020333e:	00003517          	auipc	a0,0x3
ffffffffc0203342:	78250513          	addi	a0,a0,1922 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203346:	948fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020334a:	00004697          	auipc	a3,0x4
ffffffffc020334e:	96e68693          	addi	a3,a3,-1682 # ffffffffc0206cb8 <default_pmm_manager+0x348>
ffffffffc0203352:	00003617          	auipc	a2,0x3
ffffffffc0203356:	26e60613          	addi	a2,a2,622 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc020335a:	26500593          	li	a1,613
ffffffffc020335e:	00003517          	auipc	a0,0x3
ffffffffc0203362:	76250513          	addi	a0,a0,1890 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203366:	928fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc020336a:	00004697          	auipc	a3,0x4
ffffffffc020336e:	9ee68693          	addi	a3,a3,-1554 # ffffffffc0206d58 <default_pmm_manager+0x3e8>
ffffffffc0203372:	00003617          	auipc	a2,0x3
ffffffffc0203376:	24e60613          	addi	a2,a2,590 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc020337a:	26400593          	li	a1,612
ffffffffc020337e:	00003517          	auipc	a0,0x3
ffffffffc0203382:	74250513          	addi	a0,a0,1858 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203386:	908fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020338a:	00004697          	auipc	a3,0x4
ffffffffc020338e:	aa668693          	addi	a3,a3,-1370 # ffffffffc0206e30 <default_pmm_manager+0x4c0>
ffffffffc0203392:	00003617          	auipc	a2,0x3
ffffffffc0203396:	22e60613          	addi	a2,a2,558 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc020339a:	26300593          	li	a1,611
ffffffffc020339e:	00003517          	auipc	a0,0x3
ffffffffc02033a2:	72250513          	addi	a0,a0,1826 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc02033a6:	8e8fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02033aa:	00004697          	auipc	a3,0x4
ffffffffc02033ae:	a6e68693          	addi	a3,a3,-1426 # ffffffffc0206e18 <default_pmm_manager+0x4a8>
ffffffffc02033b2:	00003617          	auipc	a2,0x3
ffffffffc02033b6:	20e60613          	addi	a2,a2,526 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02033ba:	26200593          	li	a1,610
ffffffffc02033be:	00003517          	auipc	a0,0x3
ffffffffc02033c2:	70250513          	addi	a0,a0,1794 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc02033c6:	8c8fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc02033ca:	00004697          	auipc	a3,0x4
ffffffffc02033ce:	a1e68693          	addi	a3,a3,-1506 # ffffffffc0206de8 <default_pmm_manager+0x478>
ffffffffc02033d2:	00003617          	auipc	a2,0x3
ffffffffc02033d6:	1ee60613          	addi	a2,a2,494 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02033da:	26100593          	li	a1,609
ffffffffc02033de:	00003517          	auipc	a0,0x3
ffffffffc02033e2:	6e250513          	addi	a0,a0,1762 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc02033e6:	8a8fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02033ea:	00004697          	auipc	a3,0x4
ffffffffc02033ee:	9e668693          	addi	a3,a3,-1562 # ffffffffc0206dd0 <default_pmm_manager+0x460>
ffffffffc02033f2:	00003617          	auipc	a2,0x3
ffffffffc02033f6:	1ce60613          	addi	a2,a2,462 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02033fa:	25f00593          	li	a1,607
ffffffffc02033fe:	00003517          	auipc	a0,0x3
ffffffffc0203402:	6c250513          	addi	a0,a0,1730 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203406:	888fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc020340a:	00004697          	auipc	a3,0x4
ffffffffc020340e:	9a668693          	addi	a3,a3,-1626 # ffffffffc0206db0 <default_pmm_manager+0x440>
ffffffffc0203412:	00003617          	auipc	a2,0x3
ffffffffc0203416:	1ae60613          	addi	a2,a2,430 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc020341a:	25e00593          	li	a1,606
ffffffffc020341e:	00003517          	auipc	a0,0x3
ffffffffc0203422:	6a250513          	addi	a0,a0,1698 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203426:	868fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(*ptep & PTE_W);
ffffffffc020342a:	00004697          	auipc	a3,0x4
ffffffffc020342e:	97668693          	addi	a3,a3,-1674 # ffffffffc0206da0 <default_pmm_manager+0x430>
ffffffffc0203432:	00003617          	auipc	a2,0x3
ffffffffc0203436:	18e60613          	addi	a2,a2,398 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc020343a:	25d00593          	li	a1,605
ffffffffc020343e:	00003517          	auipc	a0,0x3
ffffffffc0203442:	68250513          	addi	a0,a0,1666 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203446:	848fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(*ptep & PTE_U);
ffffffffc020344a:	00004697          	auipc	a3,0x4
ffffffffc020344e:	94668693          	addi	a3,a3,-1722 # ffffffffc0206d90 <default_pmm_manager+0x420>
ffffffffc0203452:	00003617          	auipc	a2,0x3
ffffffffc0203456:	16e60613          	addi	a2,a2,366 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc020345a:	25c00593          	li	a1,604
ffffffffc020345e:	00003517          	auipc	a0,0x3
ffffffffc0203462:	66250513          	addi	a0,a0,1634 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203466:	828fd0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("DTB memory info not available");
ffffffffc020346a:	00003617          	auipc	a2,0x3
ffffffffc020346e:	6c660613          	addi	a2,a2,1734 # ffffffffc0206b30 <default_pmm_manager+0x1c0>
ffffffffc0203472:	06500593          	li	a1,101
ffffffffc0203476:	00003517          	auipc	a0,0x3
ffffffffc020347a:	64a50513          	addi	a0,a0,1610 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc020347e:	810fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0203482:	00004697          	auipc	a3,0x4
ffffffffc0203486:	a2668693          	addi	a3,a3,-1498 # ffffffffc0206ea8 <default_pmm_manager+0x538>
ffffffffc020348a:	00003617          	auipc	a2,0x3
ffffffffc020348e:	13660613          	addi	a2,a2,310 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203492:	2a200593          	li	a1,674
ffffffffc0203496:	00003517          	auipc	a0,0x3
ffffffffc020349a:	62a50513          	addi	a0,a0,1578 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc020349e:	ff1fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02034a2:	00004697          	auipc	a3,0x4
ffffffffc02034a6:	8b668693          	addi	a3,a3,-1866 # ffffffffc0206d58 <default_pmm_manager+0x3e8>
ffffffffc02034aa:	00003617          	auipc	a2,0x3
ffffffffc02034ae:	11660613          	addi	a2,a2,278 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02034b2:	25b00593          	li	a1,603
ffffffffc02034b6:	00003517          	auipc	a0,0x3
ffffffffc02034ba:	60a50513          	addi	a0,a0,1546 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc02034be:	fd1fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02034c2:	00004697          	auipc	a3,0x4
ffffffffc02034c6:	85668693          	addi	a3,a3,-1962 # ffffffffc0206d18 <default_pmm_manager+0x3a8>
ffffffffc02034ca:	00003617          	auipc	a2,0x3
ffffffffc02034ce:	0f660613          	addi	a2,a2,246 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02034d2:	25a00593          	li	a1,602
ffffffffc02034d6:	00003517          	auipc	a0,0x3
ffffffffc02034da:	5ea50513          	addi	a0,a0,1514 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc02034de:	fb1fc0ef          	jal	ra,ffffffffc020048e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02034e2:	86d6                	mv	a3,s5
ffffffffc02034e4:	00003617          	auipc	a2,0x3
ffffffffc02034e8:	4c460613          	addi	a2,a2,1220 # ffffffffc02069a8 <default_pmm_manager+0x38>
ffffffffc02034ec:	25600593          	li	a1,598
ffffffffc02034f0:	00003517          	auipc	a0,0x3
ffffffffc02034f4:	5d050513          	addi	a0,a0,1488 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc02034f8:	f97fc0ef          	jal	ra,ffffffffc020048e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc02034fc:	00003617          	auipc	a2,0x3
ffffffffc0203500:	4ac60613          	addi	a2,a2,1196 # ffffffffc02069a8 <default_pmm_manager+0x38>
ffffffffc0203504:	25500593          	li	a1,597
ffffffffc0203508:	00003517          	auipc	a0,0x3
ffffffffc020350c:	5b850513          	addi	a0,a0,1464 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203510:	f7ffc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203514:	00003697          	auipc	a3,0x3
ffffffffc0203518:	7bc68693          	addi	a3,a3,1980 # ffffffffc0206cd0 <default_pmm_manager+0x360>
ffffffffc020351c:	00003617          	auipc	a2,0x3
ffffffffc0203520:	0a460613          	addi	a2,a2,164 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203524:	25300593          	li	a1,595
ffffffffc0203528:	00003517          	auipc	a0,0x3
ffffffffc020352c:	59850513          	addi	a0,a0,1432 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203530:	f5ffc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203534:	00003697          	auipc	a3,0x3
ffffffffc0203538:	78468693          	addi	a3,a3,1924 # ffffffffc0206cb8 <default_pmm_manager+0x348>
ffffffffc020353c:	00003617          	auipc	a2,0x3
ffffffffc0203540:	08460613          	addi	a2,a2,132 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203544:	25200593          	li	a1,594
ffffffffc0203548:	00003517          	auipc	a0,0x3
ffffffffc020354c:	57850513          	addi	a0,a0,1400 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203550:	f3ffc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203554:	00004697          	auipc	a3,0x4
ffffffffc0203558:	b1468693          	addi	a3,a3,-1260 # ffffffffc0207068 <default_pmm_manager+0x6f8>
ffffffffc020355c:	00003617          	auipc	a2,0x3
ffffffffc0203560:	06460613          	addi	a2,a2,100 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203564:	29900593          	li	a1,665
ffffffffc0203568:	00003517          	auipc	a0,0x3
ffffffffc020356c:	55850513          	addi	a0,a0,1368 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203570:	f1ffc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203574:	00004697          	auipc	a3,0x4
ffffffffc0203578:	abc68693          	addi	a3,a3,-1348 # ffffffffc0207030 <default_pmm_manager+0x6c0>
ffffffffc020357c:	00003617          	auipc	a2,0x3
ffffffffc0203580:	04460613          	addi	a2,a2,68 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203584:	29600593          	li	a1,662
ffffffffc0203588:	00003517          	auipc	a0,0x3
ffffffffc020358c:	53850513          	addi	a0,a0,1336 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203590:	efffc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203594:	00004697          	auipc	a3,0x4
ffffffffc0203598:	a6c68693          	addi	a3,a3,-1428 # ffffffffc0207000 <default_pmm_manager+0x690>
ffffffffc020359c:	00003617          	auipc	a2,0x3
ffffffffc02035a0:	02460613          	addi	a2,a2,36 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02035a4:	29200593          	li	a1,658
ffffffffc02035a8:	00003517          	auipc	a0,0x3
ffffffffc02035ac:	51850513          	addi	a0,a0,1304 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc02035b0:	edffc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02035b4:	00004697          	auipc	a3,0x4
ffffffffc02035b8:	a0468693          	addi	a3,a3,-1532 # ffffffffc0206fb8 <default_pmm_manager+0x648>
ffffffffc02035bc:	00003617          	auipc	a2,0x3
ffffffffc02035c0:	00460613          	addi	a2,a2,4 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02035c4:	29100593          	li	a1,657
ffffffffc02035c8:	00003517          	auipc	a0,0x3
ffffffffc02035cc:	4f850513          	addi	a0,a0,1272 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc02035d0:	ebffc0ef          	jal	ra,ffffffffc020048e <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc02035d4:	00003617          	auipc	a2,0x3
ffffffffc02035d8:	47c60613          	addi	a2,a2,1148 # ffffffffc0206a50 <default_pmm_manager+0xe0>
ffffffffc02035dc:	0c900593          	li	a1,201
ffffffffc02035e0:	00003517          	auipc	a0,0x3
ffffffffc02035e4:	4e050513          	addi	a0,a0,1248 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc02035e8:	ea7fc0ef          	jal	ra,ffffffffc020048e <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02035ec:	00003617          	auipc	a2,0x3
ffffffffc02035f0:	46460613          	addi	a2,a2,1124 # ffffffffc0206a50 <default_pmm_manager+0xe0>
ffffffffc02035f4:	08100593          	li	a1,129
ffffffffc02035f8:	00003517          	auipc	a0,0x3
ffffffffc02035fc:	4c850513          	addi	a0,a0,1224 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203600:	e8ffc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0203604:	00003697          	auipc	a3,0x3
ffffffffc0203608:	68468693          	addi	a3,a3,1668 # ffffffffc0206c88 <default_pmm_manager+0x318>
ffffffffc020360c:	00003617          	auipc	a2,0x3
ffffffffc0203610:	fb460613          	addi	a2,a2,-76 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203614:	25100593          	li	a1,593
ffffffffc0203618:	00003517          	auipc	a0,0x3
ffffffffc020361c:	4a850513          	addi	a0,a0,1192 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203620:	e6ffc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0203624:	00003697          	auipc	a3,0x3
ffffffffc0203628:	63468693          	addi	a3,a3,1588 # ffffffffc0206c58 <default_pmm_manager+0x2e8>
ffffffffc020362c:	00003617          	auipc	a2,0x3
ffffffffc0203630:	f9460613          	addi	a2,a2,-108 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203634:	24e00593          	li	a1,590
ffffffffc0203638:	00003517          	auipc	a0,0x3
ffffffffc020363c:	48850513          	addi	a0,a0,1160 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203640:	e4ffc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203644 <copy_range>:
{
ffffffffc0203644:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203646:	00d667b3          	or	a5,a2,a3
{
ffffffffc020364a:	fc86                	sd	ra,120(sp)
ffffffffc020364c:	f8a2                	sd	s0,112(sp)
ffffffffc020364e:	f4a6                	sd	s1,104(sp)
ffffffffc0203650:	f0ca                	sd	s2,96(sp)
ffffffffc0203652:	ecce                	sd	s3,88(sp)
ffffffffc0203654:	e8d2                	sd	s4,80(sp)
ffffffffc0203656:	e4d6                	sd	s5,72(sp)
ffffffffc0203658:	e0da                	sd	s6,64(sp)
ffffffffc020365a:	fc5e                	sd	s7,56(sp)
ffffffffc020365c:	f862                	sd	s8,48(sp)
ffffffffc020365e:	f466                	sd	s9,40(sp)
ffffffffc0203660:	f06a                	sd	s10,32(sp)
ffffffffc0203662:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203664:	17d2                	slli	a5,a5,0x34
ffffffffc0203666:	24079163          	bnez	a5,ffffffffc02038a8 <copy_range+0x264>
    assert(USER_ACCESS(start, end));
ffffffffc020366a:	002007b7          	lui	a5,0x200
ffffffffc020366e:	8432                	mv	s0,a2
ffffffffc0203670:	1ef66063          	bltu	a2,a5,ffffffffc0203850 <copy_range+0x20c>
ffffffffc0203674:	84b6                	mv	s1,a3
ffffffffc0203676:	1cd67d63          	bgeu	a2,a3,ffffffffc0203850 <copy_range+0x20c>
ffffffffc020367a:	4785                	li	a5,1
ffffffffc020367c:	07fe                	slli	a5,a5,0x1f
ffffffffc020367e:	1cd7e963          	bltu	a5,a3,ffffffffc0203850 <copy_range+0x20c>
ffffffffc0203682:	5c7d                	li	s8,-1
ffffffffc0203684:	00cc5793          	srli	a5,s8,0xc
ffffffffc0203688:	8a2a                	mv	s4,a0
ffffffffc020368a:	892e                	mv	s2,a1
ffffffffc020368c:	8aba                	mv	s5,a4
        start += PGSIZE;
ffffffffc020368e:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage)
ffffffffc0203690:	000b4b97          	auipc	s7,0xb4
ffffffffc0203694:	148b8b93          	addi	s7,s7,328 # ffffffffc02b77d8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203698:	fff80cb7          	lui	s9,0xfff80
ffffffffc020369c:	000b4b17          	auipc	s6,0xb4
ffffffffc02036a0:	144b0b13          	addi	s6,s6,324 # ffffffffc02b77e0 <pages>
    return KADDR(page2pa(page));
ffffffffc02036a4:	e03e                	sd	a5,0(sp)
        page = pmm_manager->alloc_pages(n);
ffffffffc02036a6:	000b4d17          	auipc	s10,0xb4
ffffffffc02036aa:	142d0d13          	addi	s10,s10,322 # ffffffffc02b77e8 <pmm_manager>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02036ae:	4601                	li	a2,0
ffffffffc02036b0:	85a2                	mv	a1,s0
ffffffffc02036b2:	854a                	mv	a0,s2
ffffffffc02036b4:	9bdfe0ef          	jal	ra,ffffffffc0202070 <get_pte>
ffffffffc02036b8:	8daa                	mv	s11,a0
        if (ptep == NULL)
ffffffffc02036ba:	c951                	beqz	a0,ffffffffc020374e <copy_range+0x10a>
        if (*ptep & PTE_V)
ffffffffc02036bc:	6118                	ld	a4,0(a0)
ffffffffc02036be:	8b05                	andi	a4,a4,1
ffffffffc02036c0:	e70d                	bnez	a4,ffffffffc02036ea <copy_range+0xa6>
        start += PGSIZE;
ffffffffc02036c2:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc02036c4:	fe9465e3          	bltu	s0,s1,ffffffffc02036ae <copy_range+0x6a>
    return 0;
ffffffffc02036c8:	4781                	li	a5,0
}
ffffffffc02036ca:	70e6                	ld	ra,120(sp)
ffffffffc02036cc:	7446                	ld	s0,112(sp)
ffffffffc02036ce:	74a6                	ld	s1,104(sp)
ffffffffc02036d0:	7906                	ld	s2,96(sp)
ffffffffc02036d2:	69e6                	ld	s3,88(sp)
ffffffffc02036d4:	6a46                	ld	s4,80(sp)
ffffffffc02036d6:	6aa6                	ld	s5,72(sp)
ffffffffc02036d8:	6b06                	ld	s6,64(sp)
ffffffffc02036da:	7be2                	ld	s7,56(sp)
ffffffffc02036dc:	7c42                	ld	s8,48(sp)
ffffffffc02036de:	7ca2                	ld	s9,40(sp)
ffffffffc02036e0:	7d02                	ld	s10,32(sp)
ffffffffc02036e2:	6de2                	ld	s11,24(sp)
ffffffffc02036e4:	853e                	mv	a0,a5
ffffffffc02036e6:	6109                	addi	sp,sp,128
ffffffffc02036e8:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc02036ea:	4605                	li	a2,1
ffffffffc02036ec:	85a2                	mv	a1,s0
ffffffffc02036ee:	8552                	mv	a0,s4
ffffffffc02036f0:	981fe0ef          	jal	ra,ffffffffc0202070 <get_pte>
ffffffffc02036f4:	12050463          	beqz	a0,ffffffffc020381c <copy_range+0x1d8>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc02036f8:	000db703          	ld	a4,0(s11)
    if (!(pte & PTE_V))
ffffffffc02036fc:	00177613          	andi	a2,a4,1
ffffffffc0203700:	00070c1b          	sext.w	s8,a4
ffffffffc0203704:	18060663          	beqz	a2,ffffffffc0203890 <copy_range+0x24c>
    if (PPN(pa) >= npage)
ffffffffc0203708:	000bb603          	ld	a2,0(s7)
    return pa2page(PTE_ADDR(pte));
ffffffffc020370c:	070a                	slli	a4,a4,0x2
ffffffffc020370e:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc0203710:	12c77463          	bgeu	a4,a2,ffffffffc0203838 <copy_range+0x1f4>
    return &pages[PPN(pa) - nbase];
ffffffffc0203714:	000b3603          	ld	a2,0(s6)
ffffffffc0203718:	9766                	add	a4,a4,s9
ffffffffc020371a:	071a                	slli	a4,a4,0x6
ffffffffc020371c:	963a                	add	a2,a2,a4
            assert(page != NULL);
ffffffffc020371e:	14060963          	beqz	a2,ffffffffc0203870 <copy_range+0x22c>
            if (share) {
ffffffffc0203722:	040a8063          	beqz	s5,ffffffffc0203762 <copy_range+0x11e>
    return page - pages + nbase;
ffffffffc0203726:	000805b7          	lui	a1,0x80
ffffffffc020372a:	8719                	srai	a4,a4,0x6
ffffffffc020372c:	972e                	add	a4,a4,a1
                uint32_t cow_perm = (perm & ~PTE_W) | PTE_COW;
ffffffffc020372e:	01bc7693          	andi	a3,s8,27
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0203732:	072a                	slli	a4,a4,0xa
ffffffffc0203734:	8f55                	or	a4,a4,a3
ffffffffc0203736:	10176713          	ori	a4,a4,257
                *ptep = pte_create(page2ppn(page), cow_perm);
ffffffffc020373a:	00edb023          	sd	a4,0(s11)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020373e:	12040073          	sfence.vma	s0
    page->ref += 1;
ffffffffc0203742:	421c                	lw	a5,0(a2)
                *nptep = pte_create(page2ppn(page), cow_perm);
ffffffffc0203744:	e118                	sd	a4,0(a0)
        start += PGSIZE;
ffffffffc0203746:	944e                	add	s0,s0,s3
ffffffffc0203748:	2785                	addiw	a5,a5,1
ffffffffc020374a:	c21c                	sw	a5,0(a2)
    } while (start != 0 && start < end);
ffffffffc020374c:	bfa5                	j	ffffffffc02036c4 <copy_range+0x80>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020374e:	00200637          	lui	a2,0x200
ffffffffc0203752:	9432                	add	s0,s0,a2
ffffffffc0203754:	ffe00637          	lui	a2,0xffe00
ffffffffc0203758:	8c71                	and	s0,s0,a2
    } while (start != 0 && start < end);
ffffffffc020375a:	d43d                	beqz	s0,ffffffffc02036c8 <copy_range+0x84>
ffffffffc020375c:	f49469e3          	bltu	s0,s1,ffffffffc02036ae <copy_range+0x6a>
ffffffffc0203760:	b7a5                	j	ffffffffc02036c8 <copy_range+0x84>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203762:	100027f3          	csrr	a5,sstatus
ffffffffc0203766:	8b89                	andi	a5,a5,2
ffffffffc0203768:	e432                	sd	a2,8(sp)
ffffffffc020376a:	efc9                	bnez	a5,ffffffffc0203804 <copy_range+0x1c0>
        page = pmm_manager->alloc_pages(n);
ffffffffc020376c:	000d3783          	ld	a5,0(s10)
ffffffffc0203770:	4505                	li	a0,1
ffffffffc0203772:	6f9c                	ld	a5,24(a5)
ffffffffc0203774:	9782                	jalr	a5
ffffffffc0203776:	6622                	ld	a2,8(sp)
ffffffffc0203778:	8daa                	mv	s11,a0
                assert(npage != NULL);
ffffffffc020377a:	180d8163          	beqz	s11,ffffffffc02038fc <copy_range+0x2b8>
    return page - pages + nbase;
ffffffffc020377e:	000b3783          	ld	a5,0(s6)
    return KADDR(page2pa(page));
ffffffffc0203782:	6702                	ld	a4,0(sp)
    return page - pages + nbase;
ffffffffc0203784:	000805b7          	lui	a1,0x80
ffffffffc0203788:	8e1d                	sub	a2,a2,a5
ffffffffc020378a:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc020378c:	000bb803          	ld	a6,0(s7)
    return page - pages + nbase;
ffffffffc0203790:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0203792:	00e67533          	and	a0,a2,a4
    return page2ppn(page) << PGSHIFT;
ffffffffc0203796:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0203798:	13057863          	bgeu	a0,a6,ffffffffc02038c8 <copy_range+0x284>
ffffffffc020379c:	000b4717          	auipc	a4,0xb4
ffffffffc02037a0:	05470713          	addi	a4,a4,84 # ffffffffc02b77f0 <va_pa_offset>
ffffffffc02037a4:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc02037a6:	40fd87b3          	sub	a5,s11,a5
    return KADDR(page2pa(page));
ffffffffc02037aa:	6702                	ld	a4,0(sp)
    return page - pages + nbase;
ffffffffc02037ac:	8799                	srai	a5,a5,0x6
ffffffffc02037ae:	97ae                	add	a5,a5,a1
    return KADDR(page2pa(page));
ffffffffc02037b0:	00e7f8b3          	and	a7,a5,a4
ffffffffc02037b4:	00a605b3          	add	a1,a2,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02037b8:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02037ba:	1308f463          	bgeu	a7,a6,ffffffffc02038e2 <copy_range+0x29e>
                memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ffffffffc02037be:	6605                	lui	a2,0x1
ffffffffc02037c0:	953e                	add	a0,a0,a5
ffffffffc02037c2:	2b0020ef          	jal	ra,ffffffffc0205a72 <memcpy>
                ret = page_insert(to, npage, start, perm);
ffffffffc02037c6:	01fc7693          	andi	a3,s8,31
ffffffffc02037ca:	8622                	mv	a2,s0
ffffffffc02037cc:	85ee                	mv	a1,s11
ffffffffc02037ce:	8552                	mv	a0,s4
ffffffffc02037d0:	93eff0ef          	jal	ra,ffffffffc020290e <page_insert>
                if (ret != 0) {
ffffffffc02037d4:	ee0507e3          	beqz	a0,ffffffffc02036c2 <copy_range+0x7e>
ffffffffc02037d8:	e02a                	sd	a0,0(sp)
                    cprintf("copy_range: page_insert failed at 0x%x\n", start);
ffffffffc02037da:	85a2                	mv	a1,s0
ffffffffc02037dc:	00004517          	auipc	a0,0x4
ffffffffc02037e0:	8f450513          	addi	a0,a0,-1804 # ffffffffc02070d0 <default_pmm_manager+0x760>
ffffffffc02037e4:	9b1fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02037e8:	100026f3          	csrr	a3,sstatus
ffffffffc02037ec:	8a89                	andi	a3,a3,2
ffffffffc02037ee:	6782                	ld	a5,0(sp)
ffffffffc02037f0:	ea85                	bnez	a3,ffffffffc0203820 <copy_range+0x1dc>
        pmm_manager->free_pages(base, n);
ffffffffc02037f2:	000d3683          	ld	a3,0(s10)
ffffffffc02037f6:	4585                	li	a1,1
ffffffffc02037f8:	856e                	mv	a0,s11
ffffffffc02037fa:	7298                	ld	a4,32(a3)
ffffffffc02037fc:	e03e                	sd	a5,0(sp)
ffffffffc02037fe:	9702                	jalr	a4
    if (flag)
ffffffffc0203800:	6782                	ld	a5,0(sp)
ffffffffc0203802:	b5e1                	j	ffffffffc02036ca <copy_range+0x86>
        intr_disable();
ffffffffc0203804:	9b0fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203808:	000d3783          	ld	a5,0(s10)
ffffffffc020380c:	4505                	li	a0,1
ffffffffc020380e:	6f9c                	ld	a5,24(a5)
ffffffffc0203810:	9782                	jalr	a5
ffffffffc0203812:	8daa                	mv	s11,a0
        intr_enable();
ffffffffc0203814:	99afd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0203818:	6622                	ld	a2,8(sp)
ffffffffc020381a:	b785                	j	ffffffffc020377a <copy_range+0x136>
                return -E_NO_MEM;
ffffffffc020381c:	57f1                	li	a5,-4
ffffffffc020381e:	b575                	j	ffffffffc02036ca <copy_range+0x86>
        intr_disable();
ffffffffc0203820:	994fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203824:	000d3683          	ld	a3,0(s10)
ffffffffc0203828:	4585                	li	a1,1
ffffffffc020382a:	856e                	mv	a0,s11
ffffffffc020382c:	7298                	ld	a4,32(a3)
ffffffffc020382e:	9702                	jalr	a4
        intr_enable();
ffffffffc0203830:	97efd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0203834:	6782                	ld	a5,0(sp)
ffffffffc0203836:	bd51                	j	ffffffffc02036ca <copy_range+0x86>
        panic("pa2page called with invalid pa");
ffffffffc0203838:	00003617          	auipc	a2,0x3
ffffffffc020383c:	24060613          	addi	a2,a2,576 # ffffffffc0206a78 <default_pmm_manager+0x108>
ffffffffc0203840:	06f00593          	li	a1,111
ffffffffc0203844:	00003517          	auipc	a0,0x3
ffffffffc0203848:	18c50513          	addi	a0,a0,396 # ffffffffc02069d0 <default_pmm_manager+0x60>
ffffffffc020384c:	c43fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203850:	00003697          	auipc	a3,0x3
ffffffffc0203854:	2b068693          	addi	a3,a3,688 # ffffffffc0206b00 <default_pmm_manager+0x190>
ffffffffc0203858:	00003617          	auipc	a2,0x3
ffffffffc020385c:	d6860613          	addi	a2,a2,-664 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203860:	17b00593          	li	a1,379
ffffffffc0203864:	00003517          	auipc	a0,0x3
ffffffffc0203868:	25c50513          	addi	a0,a0,604 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc020386c:	c23fc0ef          	jal	ra,ffffffffc020048e <__panic>
            assert(page != NULL);
ffffffffc0203870:	00004697          	auipc	a3,0x4
ffffffffc0203874:	84068693          	addi	a3,a3,-1984 # ffffffffc02070b0 <default_pmm_manager+0x740>
ffffffffc0203878:	00003617          	auipc	a2,0x3
ffffffffc020387c:	d4860613          	addi	a2,a2,-696 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203880:	19100593          	li	a1,401
ffffffffc0203884:	00003517          	auipc	a0,0x3
ffffffffc0203888:	23c50513          	addi	a0,a0,572 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc020388c:	c03fc0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203890:	00003617          	auipc	a2,0x3
ffffffffc0203894:	20860613          	addi	a2,a2,520 # ffffffffc0206a98 <default_pmm_manager+0x128>
ffffffffc0203898:	08500593          	li	a1,133
ffffffffc020389c:	00003517          	auipc	a0,0x3
ffffffffc02038a0:	13450513          	addi	a0,a0,308 # ffffffffc02069d0 <default_pmm_manager+0x60>
ffffffffc02038a4:	bebfc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02038a8:	00003697          	auipc	a3,0x3
ffffffffc02038ac:	22868693          	addi	a3,a3,552 # ffffffffc0206ad0 <default_pmm_manager+0x160>
ffffffffc02038b0:	00003617          	auipc	a2,0x3
ffffffffc02038b4:	d1060613          	addi	a2,a2,-752 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02038b8:	17a00593          	li	a1,378
ffffffffc02038bc:	00003517          	auipc	a0,0x3
ffffffffc02038c0:	20450513          	addi	a0,a0,516 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc02038c4:	bcbfc0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc02038c8:	86b2                	mv	a3,a2
ffffffffc02038ca:	07700593          	li	a1,119
ffffffffc02038ce:	00003617          	auipc	a2,0x3
ffffffffc02038d2:	0da60613          	addi	a2,a2,218 # ffffffffc02069a8 <default_pmm_manager+0x38>
ffffffffc02038d6:	00003517          	auipc	a0,0x3
ffffffffc02038da:	0fa50513          	addi	a0,a0,250 # ffffffffc02069d0 <default_pmm_manager+0x60>
ffffffffc02038de:	bb1fc0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc02038e2:	86be                	mv	a3,a5
ffffffffc02038e4:	00003617          	auipc	a2,0x3
ffffffffc02038e8:	0c460613          	addi	a2,a2,196 # ffffffffc02069a8 <default_pmm_manager+0x38>
ffffffffc02038ec:	07700593          	li	a1,119
ffffffffc02038f0:	00003517          	auipc	a0,0x3
ffffffffc02038f4:	0e050513          	addi	a0,a0,224 # ffffffffc02069d0 <default_pmm_manager+0x60>
ffffffffc02038f8:	b97fc0ef          	jal	ra,ffffffffc020048e <__panic>
                assert(npage != NULL);
ffffffffc02038fc:	00003697          	auipc	a3,0x3
ffffffffc0203900:	7c468693          	addi	a3,a3,1988 # ffffffffc02070c0 <default_pmm_manager+0x750>
ffffffffc0203904:	00003617          	auipc	a2,0x3
ffffffffc0203908:	cbc60613          	addi	a2,a2,-836 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc020390c:	1a700593          	li	a1,423
ffffffffc0203910:	00003517          	auipc	a0,0x3
ffffffffc0203914:	1b050513          	addi	a0,a0,432 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc0203918:	b77fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020391c <pgdir_alloc_page>:
{
ffffffffc020391c:	7179                	addi	sp,sp,-48
ffffffffc020391e:	ec26                	sd	s1,24(sp)
ffffffffc0203920:	e84a                	sd	s2,16(sp)
ffffffffc0203922:	e052                	sd	s4,0(sp)
ffffffffc0203924:	f406                	sd	ra,40(sp)
ffffffffc0203926:	f022                	sd	s0,32(sp)
ffffffffc0203928:	e44e                	sd	s3,8(sp)
ffffffffc020392a:	8a2a                	mv	s4,a0
ffffffffc020392c:	84ae                	mv	s1,a1
ffffffffc020392e:	8932                	mv	s2,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203930:	100027f3          	csrr	a5,sstatus
ffffffffc0203934:	8b89                	andi	a5,a5,2
        page = pmm_manager->alloc_pages(n);
ffffffffc0203936:	000b4997          	auipc	s3,0xb4
ffffffffc020393a:	eb298993          	addi	s3,s3,-334 # ffffffffc02b77e8 <pmm_manager>
ffffffffc020393e:	ef8d                	bnez	a5,ffffffffc0203978 <pgdir_alloc_page+0x5c>
ffffffffc0203940:	0009b783          	ld	a5,0(s3)
ffffffffc0203944:	4505                	li	a0,1
ffffffffc0203946:	6f9c                	ld	a5,24(a5)
ffffffffc0203948:	9782                	jalr	a5
ffffffffc020394a:	842a                	mv	s0,a0
    if (page != NULL)
ffffffffc020394c:	cc09                	beqz	s0,ffffffffc0203966 <pgdir_alloc_page+0x4a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc020394e:	86ca                	mv	a3,s2
ffffffffc0203950:	8626                	mv	a2,s1
ffffffffc0203952:	85a2                	mv	a1,s0
ffffffffc0203954:	8552                	mv	a0,s4
ffffffffc0203956:	fb9fe0ef          	jal	ra,ffffffffc020290e <page_insert>
ffffffffc020395a:	e915                	bnez	a0,ffffffffc020398e <pgdir_alloc_page+0x72>
        assert(page_ref(page) == 1);
ffffffffc020395c:	4018                	lw	a4,0(s0)
        page->pra_vaddr = la;
ffffffffc020395e:	fc04                	sd	s1,56(s0)
        assert(page_ref(page) == 1);
ffffffffc0203960:	4785                	li	a5,1
ffffffffc0203962:	04f71e63          	bne	a4,a5,ffffffffc02039be <pgdir_alloc_page+0xa2>
}
ffffffffc0203966:	70a2                	ld	ra,40(sp)
ffffffffc0203968:	8522                	mv	a0,s0
ffffffffc020396a:	7402                	ld	s0,32(sp)
ffffffffc020396c:	64e2                	ld	s1,24(sp)
ffffffffc020396e:	6942                	ld	s2,16(sp)
ffffffffc0203970:	69a2                	ld	s3,8(sp)
ffffffffc0203972:	6a02                	ld	s4,0(sp)
ffffffffc0203974:	6145                	addi	sp,sp,48
ffffffffc0203976:	8082                	ret
        intr_disable();
ffffffffc0203978:	83cfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020397c:	0009b783          	ld	a5,0(s3)
ffffffffc0203980:	4505                	li	a0,1
ffffffffc0203982:	6f9c                	ld	a5,24(a5)
ffffffffc0203984:	9782                	jalr	a5
ffffffffc0203986:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203988:	826fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020398c:	b7c1                	j	ffffffffc020394c <pgdir_alloc_page+0x30>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020398e:	100027f3          	csrr	a5,sstatus
ffffffffc0203992:	8b89                	andi	a5,a5,2
ffffffffc0203994:	eb89                	bnez	a5,ffffffffc02039a6 <pgdir_alloc_page+0x8a>
        pmm_manager->free_pages(base, n);
ffffffffc0203996:	0009b783          	ld	a5,0(s3)
ffffffffc020399a:	8522                	mv	a0,s0
ffffffffc020399c:	4585                	li	a1,1
ffffffffc020399e:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc02039a0:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc02039a2:	9782                	jalr	a5
    if (flag)
ffffffffc02039a4:	b7c9                	j	ffffffffc0203966 <pgdir_alloc_page+0x4a>
        intr_disable();
ffffffffc02039a6:	80efd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc02039aa:	0009b783          	ld	a5,0(s3)
ffffffffc02039ae:	8522                	mv	a0,s0
ffffffffc02039b0:	4585                	li	a1,1
ffffffffc02039b2:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc02039b4:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc02039b6:	9782                	jalr	a5
        intr_enable();
ffffffffc02039b8:	ff7fc0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02039bc:	b76d                	j	ffffffffc0203966 <pgdir_alloc_page+0x4a>
        assert(page_ref(page) == 1);
ffffffffc02039be:	00003697          	auipc	a3,0x3
ffffffffc02039c2:	73a68693          	addi	a3,a3,1850 # ffffffffc02070f8 <default_pmm_manager+0x788>
ffffffffc02039c6:	00003617          	auipc	a2,0x3
ffffffffc02039ca:	bfa60613          	addi	a2,a2,-1030 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02039ce:	22f00593          	li	a1,559
ffffffffc02039d2:	00003517          	auipc	a0,0x3
ffffffffc02039d6:	0ee50513          	addi	a0,a0,238 # ffffffffc0206ac0 <default_pmm_manager+0x150>
ffffffffc02039da:	ab5fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02039de <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02039de:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02039e0:	00003697          	auipc	a3,0x3
ffffffffc02039e4:	73068693          	addi	a3,a3,1840 # ffffffffc0207110 <default_pmm_manager+0x7a0>
ffffffffc02039e8:	00003617          	auipc	a2,0x3
ffffffffc02039ec:	bd860613          	addi	a2,a2,-1064 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02039f0:	07400593          	li	a1,116
ffffffffc02039f4:	00003517          	auipc	a0,0x3
ffffffffc02039f8:	73c50513          	addi	a0,a0,1852 # ffffffffc0207130 <default_pmm_manager+0x7c0>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02039fc:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02039fe:	a91fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203a02 <mm_create>:
{
ffffffffc0203a02:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203a04:	04000513          	li	a0,64
{
ffffffffc0203a08:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203a0a:	bd0fe0ef          	jal	ra,ffffffffc0201dda <kmalloc>
    if (mm != NULL)
ffffffffc0203a0e:	cd19                	beqz	a0,ffffffffc0203a2c <mm_create+0x2a>
    elm->prev = elm->next = elm;
ffffffffc0203a10:	e508                	sd	a0,8(a0)
ffffffffc0203a12:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203a14:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203a18:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203a1c:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0203a20:	02053423          	sd	zero,40(a0)
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc0203a24:	02052823          	sw	zero,48(a0)
typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
ffffffffc0203a28:	02053c23          	sd	zero,56(a0)
}
ffffffffc0203a2c:	60a2                	ld	ra,8(sp)
ffffffffc0203a2e:	0141                	addi	sp,sp,16
ffffffffc0203a30:	8082                	ret

ffffffffc0203a32 <find_vma>:
{
ffffffffc0203a32:	86aa                	mv	a3,a0
    if (mm != NULL)
ffffffffc0203a34:	c505                	beqz	a0,ffffffffc0203a5c <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0203a36:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0203a38:	c501                	beqz	a0,ffffffffc0203a40 <find_vma+0xe>
ffffffffc0203a3a:	651c                	ld	a5,8(a0)
ffffffffc0203a3c:	02f5f263          	bgeu	a1,a5,ffffffffc0203a60 <find_vma+0x2e>
    return listelm->next;
ffffffffc0203a40:	669c                	ld	a5,8(a3)
            while ((le = list_next(le)) != list)
ffffffffc0203a42:	00f68d63          	beq	a3,a5,ffffffffc0203a5c <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc0203a46:	fe87b703          	ld	a4,-24(a5) # 1fffe8 <_binary_obj___user_cowtest_out_size+0x1f2f48>
ffffffffc0203a4a:	00e5e663          	bltu	a1,a4,ffffffffc0203a56 <find_vma+0x24>
ffffffffc0203a4e:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203a52:	00e5ec63          	bltu	a1,a4,ffffffffc0203a6a <find_vma+0x38>
ffffffffc0203a56:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc0203a58:	fef697e3          	bne	a3,a5,ffffffffc0203a46 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0203a5c:	4501                	li	a0,0
}
ffffffffc0203a5e:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0203a60:	691c                	ld	a5,16(a0)
ffffffffc0203a62:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0203a40 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0203a66:	ea88                	sd	a0,16(a3)
ffffffffc0203a68:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc0203a6a:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0203a6e:	ea88                	sd	a0,16(a3)
ffffffffc0203a70:	8082                	ret

ffffffffc0203a72 <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203a72:	6590                	ld	a2,8(a1)
ffffffffc0203a74:	0105b803          	ld	a6,16(a1) # 80010 <_binary_obj___user_cowtest_out_size+0x72f70>
{
ffffffffc0203a78:	1141                	addi	sp,sp,-16
ffffffffc0203a7a:	e406                	sd	ra,8(sp)
ffffffffc0203a7c:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203a7e:	01066763          	bltu	a2,a6,ffffffffc0203a8c <insert_vma_struct+0x1a>
ffffffffc0203a82:	a085                	j	ffffffffc0203ae2 <insert_vma_struct+0x70>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0203a84:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203a88:	04e66863          	bltu	a2,a4,ffffffffc0203ad8 <insert_vma_struct+0x66>
ffffffffc0203a8c:	86be                	mv	a3,a5
ffffffffc0203a8e:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc0203a90:	fef51ae3          	bne	a0,a5,ffffffffc0203a84 <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc0203a94:	02a68463          	beq	a3,a0,ffffffffc0203abc <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203a98:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203a9c:	fe86b883          	ld	a7,-24(a3)
ffffffffc0203aa0:	08e8f163          	bgeu	a7,a4,ffffffffc0203b22 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203aa4:	04e66f63          	bltu	a2,a4,ffffffffc0203b02 <insert_vma_struct+0x90>
    }
    if (le_next != list)
ffffffffc0203aa8:	00f50a63          	beq	a0,a5,ffffffffc0203abc <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0203aac:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203ab0:	05076963          	bltu	a4,a6,ffffffffc0203b02 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0203ab4:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203ab8:	02c77363          	bgeu	a4,a2,ffffffffc0203ade <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc0203abc:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0203abe:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203ac0:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203ac4:	e390                	sd	a2,0(a5)
ffffffffc0203ac6:	e690                	sd	a2,8(a3)
}
ffffffffc0203ac8:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0203aca:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203acc:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc0203ace:	0017079b          	addiw	a5,a4,1
ffffffffc0203ad2:	d11c                	sw	a5,32(a0)
}
ffffffffc0203ad4:	0141                	addi	sp,sp,16
ffffffffc0203ad6:	8082                	ret
    if (le_prev != list)
ffffffffc0203ad8:	fca690e3          	bne	a3,a0,ffffffffc0203a98 <insert_vma_struct+0x26>
ffffffffc0203adc:	bfd1                	j	ffffffffc0203ab0 <insert_vma_struct+0x3e>
ffffffffc0203ade:	f01ff0ef          	jal	ra,ffffffffc02039de <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203ae2:	00003697          	auipc	a3,0x3
ffffffffc0203ae6:	65e68693          	addi	a3,a3,1630 # ffffffffc0207140 <default_pmm_manager+0x7d0>
ffffffffc0203aea:	00003617          	auipc	a2,0x3
ffffffffc0203aee:	ad660613          	addi	a2,a2,-1322 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203af2:	07a00593          	li	a1,122
ffffffffc0203af6:	00003517          	auipc	a0,0x3
ffffffffc0203afa:	63a50513          	addi	a0,a0,1594 # ffffffffc0207130 <default_pmm_manager+0x7c0>
ffffffffc0203afe:	991fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203b02:	00003697          	auipc	a3,0x3
ffffffffc0203b06:	67e68693          	addi	a3,a3,1662 # ffffffffc0207180 <default_pmm_manager+0x810>
ffffffffc0203b0a:	00003617          	auipc	a2,0x3
ffffffffc0203b0e:	ab660613          	addi	a2,a2,-1354 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203b12:	07300593          	li	a1,115
ffffffffc0203b16:	00003517          	auipc	a0,0x3
ffffffffc0203b1a:	61a50513          	addi	a0,a0,1562 # ffffffffc0207130 <default_pmm_manager+0x7c0>
ffffffffc0203b1e:	971fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203b22:	00003697          	auipc	a3,0x3
ffffffffc0203b26:	63e68693          	addi	a3,a3,1598 # ffffffffc0207160 <default_pmm_manager+0x7f0>
ffffffffc0203b2a:	00003617          	auipc	a2,0x3
ffffffffc0203b2e:	a9660613          	addi	a2,a2,-1386 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203b32:	07200593          	li	a1,114
ffffffffc0203b36:	00003517          	auipc	a0,0x3
ffffffffc0203b3a:	5fa50513          	addi	a0,a0,1530 # ffffffffc0207130 <default_pmm_manager+0x7c0>
ffffffffc0203b3e:	951fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203b42 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc0203b42:	591c                	lw	a5,48(a0)
{
ffffffffc0203b44:	1141                	addi	sp,sp,-16
ffffffffc0203b46:	e406                	sd	ra,8(sp)
ffffffffc0203b48:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0203b4a:	e78d                	bnez	a5,ffffffffc0203b74 <mm_destroy+0x32>
ffffffffc0203b4c:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203b4e:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc0203b50:	00a40c63          	beq	s0,a0,ffffffffc0203b68 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203b54:	6118                	ld	a4,0(a0)
ffffffffc0203b56:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc0203b58:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203b5a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203b5c:	e398                	sd	a4,0(a5)
ffffffffc0203b5e:	b2cfe0ef          	jal	ra,ffffffffc0201e8a <kfree>
    return listelm->next;
ffffffffc0203b62:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc0203b64:	fea418e3          	bne	s0,a0,ffffffffc0203b54 <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc0203b68:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc0203b6a:	6402                	ld	s0,0(sp)
ffffffffc0203b6c:	60a2                	ld	ra,8(sp)
ffffffffc0203b6e:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc0203b70:	b1afe06f          	j	ffffffffc0201e8a <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0203b74:	00003697          	auipc	a3,0x3
ffffffffc0203b78:	62c68693          	addi	a3,a3,1580 # ffffffffc02071a0 <default_pmm_manager+0x830>
ffffffffc0203b7c:	00003617          	auipc	a2,0x3
ffffffffc0203b80:	a4460613          	addi	a2,a2,-1468 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203b84:	09e00593          	li	a1,158
ffffffffc0203b88:	00003517          	auipc	a0,0x3
ffffffffc0203b8c:	5a850513          	addi	a0,a0,1448 # ffffffffc0207130 <default_pmm_manager+0x7c0>
ffffffffc0203b90:	8fffc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203b94 <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
ffffffffc0203b94:	7139                	addi	sp,sp,-64
ffffffffc0203b96:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0203b98:	6405                	lui	s0,0x1
ffffffffc0203b9a:	147d                	addi	s0,s0,-1
ffffffffc0203b9c:	77fd                	lui	a5,0xfffff
ffffffffc0203b9e:	9622                	add	a2,a2,s0
ffffffffc0203ba0:	962e                	add	a2,a2,a1
{
ffffffffc0203ba2:	f426                	sd	s1,40(sp)
ffffffffc0203ba4:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0203ba6:	00f5f4b3          	and	s1,a1,a5
{
ffffffffc0203baa:	f04a                	sd	s2,32(sp)
ffffffffc0203bac:	ec4e                	sd	s3,24(sp)
ffffffffc0203bae:	e852                	sd	s4,16(sp)
ffffffffc0203bb0:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end))
ffffffffc0203bb2:	002005b7          	lui	a1,0x200
ffffffffc0203bb6:	00f67433          	and	s0,a2,a5
ffffffffc0203bba:	06b4e363          	bltu	s1,a1,ffffffffc0203c20 <mm_map+0x8c>
ffffffffc0203bbe:	0684f163          	bgeu	s1,s0,ffffffffc0203c20 <mm_map+0x8c>
ffffffffc0203bc2:	4785                	li	a5,1
ffffffffc0203bc4:	07fe                	slli	a5,a5,0x1f
ffffffffc0203bc6:	0487ed63          	bltu	a5,s0,ffffffffc0203c20 <mm_map+0x8c>
ffffffffc0203bca:	89aa                	mv	s3,a0
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0203bcc:	cd21                	beqz	a0,ffffffffc0203c24 <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc0203bce:	85a6                	mv	a1,s1
ffffffffc0203bd0:	8ab6                	mv	s5,a3
ffffffffc0203bd2:	8a3a                	mv	s4,a4
ffffffffc0203bd4:	e5fff0ef          	jal	ra,ffffffffc0203a32 <find_vma>
ffffffffc0203bd8:	c501                	beqz	a0,ffffffffc0203be0 <mm_map+0x4c>
ffffffffc0203bda:	651c                	ld	a5,8(a0)
ffffffffc0203bdc:	0487e263          	bltu	a5,s0,ffffffffc0203c20 <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203be0:	03000513          	li	a0,48
ffffffffc0203be4:	9f6fe0ef          	jal	ra,ffffffffc0201dda <kmalloc>
ffffffffc0203be8:	892a                	mv	s2,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0203bea:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc0203bec:	02090163          	beqz	s2,ffffffffc0203c0e <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0203bf0:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc0203bf2:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0203bf6:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0203bfa:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0203bfe:	85ca                	mv	a1,s2
ffffffffc0203c00:	e73ff0ef          	jal	ra,ffffffffc0203a72 <insert_vma_struct>
    if (vma_store != NULL)
    {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0203c04:	4501                	li	a0,0
    if (vma_store != NULL)
ffffffffc0203c06:	000a0463          	beqz	s4,ffffffffc0203c0e <mm_map+0x7a>
        *vma_store = vma;
ffffffffc0203c0a:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0203c0e:	70e2                	ld	ra,56(sp)
ffffffffc0203c10:	7442                	ld	s0,48(sp)
ffffffffc0203c12:	74a2                	ld	s1,40(sp)
ffffffffc0203c14:	7902                	ld	s2,32(sp)
ffffffffc0203c16:	69e2                	ld	s3,24(sp)
ffffffffc0203c18:	6a42                	ld	s4,16(sp)
ffffffffc0203c1a:	6aa2                	ld	s5,8(sp)
ffffffffc0203c1c:	6121                	addi	sp,sp,64
ffffffffc0203c1e:	8082                	ret
        return -E_INVAL;
ffffffffc0203c20:	5575                	li	a0,-3
ffffffffc0203c22:	b7f5                	j	ffffffffc0203c0e <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc0203c24:	00003697          	auipc	a3,0x3
ffffffffc0203c28:	59468693          	addi	a3,a3,1428 # ffffffffc02071b8 <default_pmm_manager+0x848>
ffffffffc0203c2c:	00003617          	auipc	a2,0x3
ffffffffc0203c30:	99460613          	addi	a2,a2,-1644 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203c34:	0b300593          	li	a1,179
ffffffffc0203c38:	00003517          	auipc	a0,0x3
ffffffffc0203c3c:	4f850513          	addi	a0,a0,1272 # ffffffffc0207130 <default_pmm_manager+0x7c0>
ffffffffc0203c40:	84ffc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203c44 <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc0203c44:	7139                	addi	sp,sp,-64
ffffffffc0203c46:	fc06                	sd	ra,56(sp)
ffffffffc0203c48:	f822                	sd	s0,48(sp)
ffffffffc0203c4a:	f426                	sd	s1,40(sp)
ffffffffc0203c4c:	f04a                	sd	s2,32(sp)
ffffffffc0203c4e:	ec4e                	sd	s3,24(sp)
ffffffffc0203c50:	e852                	sd	s4,16(sp)
ffffffffc0203c52:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0203c54:	c52d                	beqz	a0,ffffffffc0203cbe <dup_mmap+0x7a>
ffffffffc0203c56:	892a                	mv	s2,a0
ffffffffc0203c58:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0203c5a:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0203c5c:	e595                	bnez	a1,ffffffffc0203c88 <dup_mmap+0x44>
ffffffffc0203c5e:	a085                	j	ffffffffc0203cbe <dup_mmap+0x7a>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0203c60:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc0203c62:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_cowtest_out_size+0x1f2f68>
        vma->vm_end = vm_end;
ffffffffc0203c66:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0203c6a:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc0203c6e:	e05ff0ef          	jal	ra,ffffffffc0203a72 <insert_vma_struct>

        // Enable COW (Copy-On-Write) for writable pages
        bool share = 1;  // Enable COW mechanism
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc0203c72:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc0203c76:	fe843603          	ld	a2,-24(s0)
ffffffffc0203c7a:	6c8c                	ld	a1,24(s1)
ffffffffc0203c7c:	01893503          	ld	a0,24(s2)
ffffffffc0203c80:	4705                	li	a4,1
ffffffffc0203c82:	9c3ff0ef          	jal	ra,ffffffffc0203644 <copy_range>
ffffffffc0203c86:	e105                	bnez	a0,ffffffffc0203ca6 <dup_mmap+0x62>
    return listelm->prev;
ffffffffc0203c88:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc0203c8a:	02848863          	beq	s1,s0,ffffffffc0203cba <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203c8e:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0203c92:	fe843a83          	ld	s5,-24(s0)
ffffffffc0203c96:	ff043a03          	ld	s4,-16(s0)
ffffffffc0203c9a:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203c9e:	93cfe0ef          	jal	ra,ffffffffc0201dda <kmalloc>
ffffffffc0203ca2:	85aa                	mv	a1,a0
    if (vma != NULL)
ffffffffc0203ca4:	fd55                	bnez	a0,ffffffffc0203c60 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0203ca6:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0203ca8:	70e2                	ld	ra,56(sp)
ffffffffc0203caa:	7442                	ld	s0,48(sp)
ffffffffc0203cac:	74a2                	ld	s1,40(sp)
ffffffffc0203cae:	7902                	ld	s2,32(sp)
ffffffffc0203cb0:	69e2                	ld	s3,24(sp)
ffffffffc0203cb2:	6a42                	ld	s4,16(sp)
ffffffffc0203cb4:	6aa2                	ld	s5,8(sp)
ffffffffc0203cb6:	6121                	addi	sp,sp,64
ffffffffc0203cb8:	8082                	ret
    return 0;
ffffffffc0203cba:	4501                	li	a0,0
ffffffffc0203cbc:	b7f5                	j	ffffffffc0203ca8 <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc0203cbe:	00003697          	auipc	a3,0x3
ffffffffc0203cc2:	50a68693          	addi	a3,a3,1290 # ffffffffc02071c8 <default_pmm_manager+0x858>
ffffffffc0203cc6:	00003617          	auipc	a2,0x3
ffffffffc0203cca:	8fa60613          	addi	a2,a2,-1798 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203cce:	0cf00593          	li	a1,207
ffffffffc0203cd2:	00003517          	auipc	a0,0x3
ffffffffc0203cd6:	45e50513          	addi	a0,a0,1118 # ffffffffc0207130 <default_pmm_manager+0x7c0>
ffffffffc0203cda:	fb4fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203cde <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc0203cde:	1101                	addi	sp,sp,-32
ffffffffc0203ce0:	ec06                	sd	ra,24(sp)
ffffffffc0203ce2:	e822                	sd	s0,16(sp)
ffffffffc0203ce4:	e426                	sd	s1,8(sp)
ffffffffc0203ce6:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203ce8:	c531                	beqz	a0,ffffffffc0203d34 <exit_mmap+0x56>
ffffffffc0203cea:	591c                	lw	a5,48(a0)
ffffffffc0203cec:	84aa                	mv	s1,a0
ffffffffc0203cee:	e3b9                	bnez	a5,ffffffffc0203d34 <exit_mmap+0x56>
    return listelm->next;
ffffffffc0203cf0:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0203cf2:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc0203cf6:	02850963          	beq	a0,s0,ffffffffc0203d28 <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0203cfa:	ff043603          	ld	a2,-16(s0)
ffffffffc0203cfe:	fe843583          	ld	a1,-24(s0)
ffffffffc0203d02:	854a                	mv	a0,s2
ffffffffc0203d04:	de8fe0ef          	jal	ra,ffffffffc02022ec <unmap_range>
ffffffffc0203d08:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0203d0a:	fe8498e3          	bne	s1,s0,ffffffffc0203cfa <exit_mmap+0x1c>
ffffffffc0203d0e:	6480                	ld	s0,8(s1)
    }
    le = list;
    while ((le = list_next(le)) != list)
ffffffffc0203d10:	00848c63          	beq	s1,s0,ffffffffc0203d28 <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0203d14:	ff043603          	ld	a2,-16(s0)
ffffffffc0203d18:	fe843583          	ld	a1,-24(s0)
ffffffffc0203d1c:	854a                	mv	a0,s2
ffffffffc0203d1e:	f14fe0ef          	jal	ra,ffffffffc0202432 <exit_range>
ffffffffc0203d22:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0203d24:	fe8498e3          	bne	s1,s0,ffffffffc0203d14 <exit_mmap+0x36>
    }
}
ffffffffc0203d28:	60e2                	ld	ra,24(sp)
ffffffffc0203d2a:	6442                	ld	s0,16(sp)
ffffffffc0203d2c:	64a2                	ld	s1,8(sp)
ffffffffc0203d2e:	6902                	ld	s2,0(sp)
ffffffffc0203d30:	6105                	addi	sp,sp,32
ffffffffc0203d32:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203d34:	00003697          	auipc	a3,0x3
ffffffffc0203d38:	4b468693          	addi	a3,a3,1204 # ffffffffc02071e8 <default_pmm_manager+0x878>
ffffffffc0203d3c:	00003617          	auipc	a2,0x3
ffffffffc0203d40:	88460613          	addi	a2,a2,-1916 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203d44:	0e900593          	li	a1,233
ffffffffc0203d48:	00003517          	auipc	a0,0x3
ffffffffc0203d4c:	3e850513          	addi	a0,a0,1000 # ffffffffc0207130 <default_pmm_manager+0x7c0>
ffffffffc0203d50:	f3efc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203d54 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0203d54:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203d56:	04000513          	li	a0,64
{
ffffffffc0203d5a:	fc06                	sd	ra,56(sp)
ffffffffc0203d5c:	f822                	sd	s0,48(sp)
ffffffffc0203d5e:	f426                	sd	s1,40(sp)
ffffffffc0203d60:	f04a                	sd	s2,32(sp)
ffffffffc0203d62:	ec4e                	sd	s3,24(sp)
ffffffffc0203d64:	e852                	sd	s4,16(sp)
ffffffffc0203d66:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203d68:	872fe0ef          	jal	ra,ffffffffc0201dda <kmalloc>
    if (mm != NULL)
ffffffffc0203d6c:	2e050663          	beqz	a0,ffffffffc0204058 <vmm_init+0x304>
ffffffffc0203d70:	84aa                	mv	s1,a0
    elm->prev = elm->next = elm;
ffffffffc0203d72:	e508                	sd	a0,8(a0)
ffffffffc0203d74:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203d76:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203d7a:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203d7e:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0203d82:	02053423          	sd	zero,40(a0)
ffffffffc0203d86:	02052823          	sw	zero,48(a0)
ffffffffc0203d8a:	02053c23          	sd	zero,56(a0)
ffffffffc0203d8e:	03200413          	li	s0,50
ffffffffc0203d92:	a811                	j	ffffffffc0203da6 <vmm_init+0x52>
        vma->vm_start = vm_start;
ffffffffc0203d94:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203d96:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203d98:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
ffffffffc0203d9c:	146d                	addi	s0,s0,-5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203d9e:	8526                	mv	a0,s1
ffffffffc0203da0:	cd3ff0ef          	jal	ra,ffffffffc0203a72 <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0203da4:	c80d                	beqz	s0,ffffffffc0203dd6 <vmm_init+0x82>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203da6:	03000513          	li	a0,48
ffffffffc0203daa:	830fe0ef          	jal	ra,ffffffffc0201dda <kmalloc>
ffffffffc0203dae:	85aa                	mv	a1,a0
ffffffffc0203db0:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0203db4:	f165                	bnez	a0,ffffffffc0203d94 <vmm_init+0x40>
        assert(vma != NULL);
ffffffffc0203db6:	00003697          	auipc	a3,0x3
ffffffffc0203dba:	5ca68693          	addi	a3,a3,1482 # ffffffffc0207380 <default_pmm_manager+0xa10>
ffffffffc0203dbe:	00003617          	auipc	a2,0x3
ffffffffc0203dc2:	80260613          	addi	a2,a2,-2046 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203dc6:	12e00593          	li	a1,302
ffffffffc0203dca:	00003517          	auipc	a0,0x3
ffffffffc0203dce:	36650513          	addi	a0,a0,870 # ffffffffc0207130 <default_pmm_manager+0x7c0>
ffffffffc0203dd2:	ebcfc0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc0203dd6:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203dda:	1f900913          	li	s2,505
ffffffffc0203dde:	a819                	j	ffffffffc0203df4 <vmm_init+0xa0>
        vma->vm_start = vm_start;
ffffffffc0203de0:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203de2:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203de4:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203de8:	0415                	addi	s0,s0,5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203dea:	8526                	mv	a0,s1
ffffffffc0203dec:	c87ff0ef          	jal	ra,ffffffffc0203a72 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203df0:	03240a63          	beq	s0,s2,ffffffffc0203e24 <vmm_init+0xd0>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203df4:	03000513          	li	a0,48
ffffffffc0203df8:	fe3fd0ef          	jal	ra,ffffffffc0201dda <kmalloc>
ffffffffc0203dfc:	85aa                	mv	a1,a0
ffffffffc0203dfe:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0203e02:	fd79                	bnez	a0,ffffffffc0203de0 <vmm_init+0x8c>
        assert(vma != NULL);
ffffffffc0203e04:	00003697          	auipc	a3,0x3
ffffffffc0203e08:	57c68693          	addi	a3,a3,1404 # ffffffffc0207380 <default_pmm_manager+0xa10>
ffffffffc0203e0c:	00002617          	auipc	a2,0x2
ffffffffc0203e10:	7b460613          	addi	a2,a2,1972 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203e14:	13500593          	li	a1,309
ffffffffc0203e18:	00003517          	auipc	a0,0x3
ffffffffc0203e1c:	31850513          	addi	a0,a0,792 # ffffffffc0207130 <default_pmm_manager+0x7c0>
ffffffffc0203e20:	e6efc0ef          	jal	ra,ffffffffc020048e <__panic>
    return listelm->next;
ffffffffc0203e24:	649c                	ld	a5,8(s1)
ffffffffc0203e26:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0203e28:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0203e2c:	16f48663          	beq	s1,a5,ffffffffc0203f98 <vmm_init+0x244>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203e30:	fe87b603          	ld	a2,-24(a5) # ffffffffffffefe8 <end+0x3fd477d4>
ffffffffc0203e34:	ffe70693          	addi	a3,a4,-2
ffffffffc0203e38:	10d61063          	bne	a2,a3,ffffffffc0203f38 <vmm_init+0x1e4>
ffffffffc0203e3c:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203e40:	0ed71c63          	bne	a4,a3,ffffffffc0203f38 <vmm_init+0x1e4>
    for (i = 1; i <= step2; i++)
ffffffffc0203e44:	0715                	addi	a4,a4,5
ffffffffc0203e46:	679c                	ld	a5,8(a5)
ffffffffc0203e48:	feb712e3          	bne	a4,a1,ffffffffc0203e2c <vmm_init+0xd8>
ffffffffc0203e4c:	4a1d                	li	s4,7
ffffffffc0203e4e:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203e50:	1f900a93          	li	s5,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203e54:	85a2                	mv	a1,s0
ffffffffc0203e56:	8526                	mv	a0,s1
ffffffffc0203e58:	bdbff0ef          	jal	ra,ffffffffc0203a32 <find_vma>
ffffffffc0203e5c:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0203e5e:	16050d63          	beqz	a0,ffffffffc0203fd8 <vmm_init+0x284>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0203e62:	00140593          	addi	a1,s0,1
ffffffffc0203e66:	8526                	mv	a0,s1
ffffffffc0203e68:	bcbff0ef          	jal	ra,ffffffffc0203a32 <find_vma>
ffffffffc0203e6c:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203e6e:	14050563          	beqz	a0,ffffffffc0203fb8 <vmm_init+0x264>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0203e72:	85d2                	mv	a1,s4
ffffffffc0203e74:	8526                	mv	a0,s1
ffffffffc0203e76:	bbdff0ef          	jal	ra,ffffffffc0203a32 <find_vma>
        assert(vma3 == NULL);
ffffffffc0203e7a:	16051f63          	bnez	a0,ffffffffc0203ff8 <vmm_init+0x2a4>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0203e7e:	00340593          	addi	a1,s0,3
ffffffffc0203e82:	8526                	mv	a0,s1
ffffffffc0203e84:	bafff0ef          	jal	ra,ffffffffc0203a32 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203e88:	1a051863          	bnez	a0,ffffffffc0204038 <vmm_init+0x2e4>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0203e8c:	00440593          	addi	a1,s0,4
ffffffffc0203e90:	8526                	mv	a0,s1
ffffffffc0203e92:	ba1ff0ef          	jal	ra,ffffffffc0203a32 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203e96:	18051163          	bnez	a0,ffffffffc0204018 <vmm_init+0x2c4>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203e9a:	00893783          	ld	a5,8(s2)
ffffffffc0203e9e:	0a879d63          	bne	a5,s0,ffffffffc0203f58 <vmm_init+0x204>
ffffffffc0203ea2:	01093783          	ld	a5,16(s2)
ffffffffc0203ea6:	0b479963          	bne	a5,s4,ffffffffc0203f58 <vmm_init+0x204>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203eaa:	0089b783          	ld	a5,8(s3)
ffffffffc0203eae:	0c879563          	bne	a5,s0,ffffffffc0203f78 <vmm_init+0x224>
ffffffffc0203eb2:	0109b783          	ld	a5,16(s3)
ffffffffc0203eb6:	0d479163          	bne	a5,s4,ffffffffc0203f78 <vmm_init+0x224>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203eba:	0415                	addi	s0,s0,5
ffffffffc0203ebc:	0a15                	addi	s4,s4,5
ffffffffc0203ebe:	f9541be3          	bne	s0,s5,ffffffffc0203e54 <vmm_init+0x100>
ffffffffc0203ec2:	4411                	li	s0,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0203ec4:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0203ec6:	85a2                	mv	a1,s0
ffffffffc0203ec8:	8526                	mv	a0,s1
ffffffffc0203eca:	b69ff0ef          	jal	ra,ffffffffc0203a32 <find_vma>
ffffffffc0203ece:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL)
ffffffffc0203ed2:	c90d                	beqz	a0,ffffffffc0203f04 <vmm_init+0x1b0>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0203ed4:	6914                	ld	a3,16(a0)
ffffffffc0203ed6:	6510                	ld	a2,8(a0)
ffffffffc0203ed8:	00003517          	auipc	a0,0x3
ffffffffc0203edc:	43050513          	addi	a0,a0,1072 # ffffffffc0207308 <default_pmm_manager+0x998>
ffffffffc0203ee0:	ab4fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203ee4:	00003697          	auipc	a3,0x3
ffffffffc0203ee8:	44c68693          	addi	a3,a3,1100 # ffffffffc0207330 <default_pmm_manager+0x9c0>
ffffffffc0203eec:	00002617          	auipc	a2,0x2
ffffffffc0203ef0:	6d460613          	addi	a2,a2,1748 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203ef4:	15b00593          	li	a1,347
ffffffffc0203ef8:	00003517          	auipc	a0,0x3
ffffffffc0203efc:	23850513          	addi	a0,a0,568 # ffffffffc0207130 <default_pmm_manager+0x7c0>
ffffffffc0203f00:	d8efc0ef          	jal	ra,ffffffffc020048e <__panic>
    for (i = 4; i >= 0; i--)
ffffffffc0203f04:	147d                	addi	s0,s0,-1
ffffffffc0203f06:	fd2410e3          	bne	s0,s2,ffffffffc0203ec6 <vmm_init+0x172>
    }

    mm_destroy(mm);
ffffffffc0203f0a:	8526                	mv	a0,s1
ffffffffc0203f0c:	c37ff0ef          	jal	ra,ffffffffc0203b42 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203f10:	00003517          	auipc	a0,0x3
ffffffffc0203f14:	43850513          	addi	a0,a0,1080 # ffffffffc0207348 <default_pmm_manager+0x9d8>
ffffffffc0203f18:	a7cfc0ef          	jal	ra,ffffffffc0200194 <cprintf>
}
ffffffffc0203f1c:	7442                	ld	s0,48(sp)
ffffffffc0203f1e:	70e2                	ld	ra,56(sp)
ffffffffc0203f20:	74a2                	ld	s1,40(sp)
ffffffffc0203f22:	7902                	ld	s2,32(sp)
ffffffffc0203f24:	69e2                	ld	s3,24(sp)
ffffffffc0203f26:	6a42                	ld	s4,16(sp)
ffffffffc0203f28:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203f2a:	00003517          	auipc	a0,0x3
ffffffffc0203f2e:	43e50513          	addi	a0,a0,1086 # ffffffffc0207368 <default_pmm_manager+0x9f8>
}
ffffffffc0203f32:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203f34:	a60fc06f          	j	ffffffffc0200194 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203f38:	00003697          	auipc	a3,0x3
ffffffffc0203f3c:	2e868693          	addi	a3,a3,744 # ffffffffc0207220 <default_pmm_manager+0x8b0>
ffffffffc0203f40:	00002617          	auipc	a2,0x2
ffffffffc0203f44:	68060613          	addi	a2,a2,1664 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203f48:	13f00593          	li	a1,319
ffffffffc0203f4c:	00003517          	auipc	a0,0x3
ffffffffc0203f50:	1e450513          	addi	a0,a0,484 # ffffffffc0207130 <default_pmm_manager+0x7c0>
ffffffffc0203f54:	d3afc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203f58:	00003697          	auipc	a3,0x3
ffffffffc0203f5c:	35068693          	addi	a3,a3,848 # ffffffffc02072a8 <default_pmm_manager+0x938>
ffffffffc0203f60:	00002617          	auipc	a2,0x2
ffffffffc0203f64:	66060613          	addi	a2,a2,1632 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203f68:	15000593          	li	a1,336
ffffffffc0203f6c:	00003517          	auipc	a0,0x3
ffffffffc0203f70:	1c450513          	addi	a0,a0,452 # ffffffffc0207130 <default_pmm_manager+0x7c0>
ffffffffc0203f74:	d1afc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203f78:	00003697          	auipc	a3,0x3
ffffffffc0203f7c:	36068693          	addi	a3,a3,864 # ffffffffc02072d8 <default_pmm_manager+0x968>
ffffffffc0203f80:	00002617          	auipc	a2,0x2
ffffffffc0203f84:	64060613          	addi	a2,a2,1600 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203f88:	15100593          	li	a1,337
ffffffffc0203f8c:	00003517          	auipc	a0,0x3
ffffffffc0203f90:	1a450513          	addi	a0,a0,420 # ffffffffc0207130 <default_pmm_manager+0x7c0>
ffffffffc0203f94:	cfafc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203f98:	00003697          	auipc	a3,0x3
ffffffffc0203f9c:	27068693          	addi	a3,a3,624 # ffffffffc0207208 <default_pmm_manager+0x898>
ffffffffc0203fa0:	00002617          	auipc	a2,0x2
ffffffffc0203fa4:	62060613          	addi	a2,a2,1568 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203fa8:	13d00593          	li	a1,317
ffffffffc0203fac:	00003517          	auipc	a0,0x3
ffffffffc0203fb0:	18450513          	addi	a0,a0,388 # ffffffffc0207130 <default_pmm_manager+0x7c0>
ffffffffc0203fb4:	cdafc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma2 != NULL);
ffffffffc0203fb8:	00003697          	auipc	a3,0x3
ffffffffc0203fbc:	2b068693          	addi	a3,a3,688 # ffffffffc0207268 <default_pmm_manager+0x8f8>
ffffffffc0203fc0:	00002617          	auipc	a2,0x2
ffffffffc0203fc4:	60060613          	addi	a2,a2,1536 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203fc8:	14800593          	li	a1,328
ffffffffc0203fcc:	00003517          	auipc	a0,0x3
ffffffffc0203fd0:	16450513          	addi	a0,a0,356 # ffffffffc0207130 <default_pmm_manager+0x7c0>
ffffffffc0203fd4:	cbafc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma1 != NULL);
ffffffffc0203fd8:	00003697          	auipc	a3,0x3
ffffffffc0203fdc:	28068693          	addi	a3,a3,640 # ffffffffc0207258 <default_pmm_manager+0x8e8>
ffffffffc0203fe0:	00002617          	auipc	a2,0x2
ffffffffc0203fe4:	5e060613          	addi	a2,a2,1504 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0203fe8:	14600593          	li	a1,326
ffffffffc0203fec:	00003517          	auipc	a0,0x3
ffffffffc0203ff0:	14450513          	addi	a0,a0,324 # ffffffffc0207130 <default_pmm_manager+0x7c0>
ffffffffc0203ff4:	c9afc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma3 == NULL);
ffffffffc0203ff8:	00003697          	auipc	a3,0x3
ffffffffc0203ffc:	28068693          	addi	a3,a3,640 # ffffffffc0207278 <default_pmm_manager+0x908>
ffffffffc0204000:	00002617          	auipc	a2,0x2
ffffffffc0204004:	5c060613          	addi	a2,a2,1472 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0204008:	14a00593          	li	a1,330
ffffffffc020400c:	00003517          	auipc	a0,0x3
ffffffffc0204010:	12450513          	addi	a0,a0,292 # ffffffffc0207130 <default_pmm_manager+0x7c0>
ffffffffc0204014:	c7afc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma5 == NULL);
ffffffffc0204018:	00003697          	auipc	a3,0x3
ffffffffc020401c:	28068693          	addi	a3,a3,640 # ffffffffc0207298 <default_pmm_manager+0x928>
ffffffffc0204020:	00002617          	auipc	a2,0x2
ffffffffc0204024:	5a060613          	addi	a2,a2,1440 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0204028:	14e00593          	li	a1,334
ffffffffc020402c:	00003517          	auipc	a0,0x3
ffffffffc0204030:	10450513          	addi	a0,a0,260 # ffffffffc0207130 <default_pmm_manager+0x7c0>
ffffffffc0204034:	c5afc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma4 == NULL);
ffffffffc0204038:	00003697          	auipc	a3,0x3
ffffffffc020403c:	25068693          	addi	a3,a3,592 # ffffffffc0207288 <default_pmm_manager+0x918>
ffffffffc0204040:	00002617          	auipc	a2,0x2
ffffffffc0204044:	58060613          	addi	a2,a2,1408 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0204048:	14c00593          	li	a1,332
ffffffffc020404c:	00003517          	auipc	a0,0x3
ffffffffc0204050:	0e450513          	addi	a0,a0,228 # ffffffffc0207130 <default_pmm_manager+0x7c0>
ffffffffc0204054:	c3afc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(mm != NULL);
ffffffffc0204058:	00003697          	auipc	a3,0x3
ffffffffc020405c:	16068693          	addi	a3,a3,352 # ffffffffc02071b8 <default_pmm_manager+0x848>
ffffffffc0204060:	00002617          	auipc	a2,0x2
ffffffffc0204064:	56060613          	addi	a2,a2,1376 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0204068:	12600593          	li	a1,294
ffffffffc020406c:	00003517          	auipc	a0,0x3
ffffffffc0204070:	0c450513          	addi	a0,a0,196 # ffffffffc0207130 <default_pmm_manager+0x7c0>
ffffffffc0204074:	c1afc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204078 <user_mem_check>:
}
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc0204078:	7179                	addi	sp,sp,-48
ffffffffc020407a:	f022                	sd	s0,32(sp)
ffffffffc020407c:	f406                	sd	ra,40(sp)
ffffffffc020407e:	ec26                	sd	s1,24(sp)
ffffffffc0204080:	e84a                	sd	s2,16(sp)
ffffffffc0204082:	e44e                	sd	s3,8(sp)
ffffffffc0204084:	e052                	sd	s4,0(sp)
ffffffffc0204086:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc0204088:	c135                	beqz	a0,ffffffffc02040ec <user_mem_check+0x74>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc020408a:	002007b7          	lui	a5,0x200
ffffffffc020408e:	04f5e663          	bltu	a1,a5,ffffffffc02040da <user_mem_check+0x62>
ffffffffc0204092:	00c584b3          	add	s1,a1,a2
ffffffffc0204096:	0495f263          	bgeu	a1,s1,ffffffffc02040da <user_mem_check+0x62>
ffffffffc020409a:	4785                	li	a5,1
ffffffffc020409c:	07fe                	slli	a5,a5,0x1f
ffffffffc020409e:	0297ee63          	bltu	a5,s1,ffffffffc02040da <user_mem_check+0x62>
ffffffffc02040a2:	892a                	mv	s2,a0
ffffffffc02040a4:	89b6                	mv	s3,a3
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc02040a6:	6a05                	lui	s4,0x1
ffffffffc02040a8:	a821                	j	ffffffffc02040c0 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc02040aa:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE)
ffffffffc02040ae:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc02040b0:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc02040b2:	c685                	beqz	a3,ffffffffc02040da <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc02040b4:	c399                	beqz	a5,ffffffffc02040ba <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc02040b6:	02e46263          	bltu	s0,a4,ffffffffc02040da <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc02040ba:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc02040bc:	04947663          	bgeu	s0,s1,ffffffffc0204108 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc02040c0:	85a2                	mv	a1,s0
ffffffffc02040c2:	854a                	mv	a0,s2
ffffffffc02040c4:	96fff0ef          	jal	ra,ffffffffc0203a32 <find_vma>
ffffffffc02040c8:	c909                	beqz	a0,ffffffffc02040da <user_mem_check+0x62>
ffffffffc02040ca:	6518                	ld	a4,8(a0)
ffffffffc02040cc:	00e46763          	bltu	s0,a4,ffffffffc02040da <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc02040d0:	4d1c                	lw	a5,24(a0)
ffffffffc02040d2:	fc099ce3          	bnez	s3,ffffffffc02040aa <user_mem_check+0x32>
ffffffffc02040d6:	8b85                	andi	a5,a5,1
ffffffffc02040d8:	f3ed                	bnez	a5,ffffffffc02040ba <user_mem_check+0x42>
            return 0;
ffffffffc02040da:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
ffffffffc02040dc:	70a2                	ld	ra,40(sp)
ffffffffc02040de:	7402                	ld	s0,32(sp)
ffffffffc02040e0:	64e2                	ld	s1,24(sp)
ffffffffc02040e2:	6942                	ld	s2,16(sp)
ffffffffc02040e4:	69a2                	ld	s3,8(sp)
ffffffffc02040e6:	6a02                	ld	s4,0(sp)
ffffffffc02040e8:	6145                	addi	sp,sp,48
ffffffffc02040ea:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc02040ec:	c02007b7          	lui	a5,0xc0200
ffffffffc02040f0:	4501                	li	a0,0
ffffffffc02040f2:	fef5e5e3          	bltu	a1,a5,ffffffffc02040dc <user_mem_check+0x64>
ffffffffc02040f6:	962e                	add	a2,a2,a1
ffffffffc02040f8:	fec5f2e3          	bgeu	a1,a2,ffffffffc02040dc <user_mem_check+0x64>
ffffffffc02040fc:	c8000537          	lui	a0,0xc8000
ffffffffc0204100:	0505                	addi	a0,a0,1
ffffffffc0204102:	00a63533          	sltu	a0,a2,a0
ffffffffc0204106:	bfd9                	j	ffffffffc02040dc <user_mem_check+0x64>
        return 1;
ffffffffc0204108:	4505                	li	a0,1
ffffffffc020410a:	bfc9                	j	ffffffffc02040dc <user_mem_check+0x64>

ffffffffc020410c <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc020410c:	8526                	mv	a0,s1
	jalr s0
ffffffffc020410e:	9402                	jalr	s0

	jal do_exit
ffffffffc0204110:	676000ef          	jal	ra,ffffffffc0204786 <do_exit>

ffffffffc0204114 <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc0204114:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204116:	10800513          	li	a0,264
{
ffffffffc020411a:	e022                	sd	s0,0(sp)
ffffffffc020411c:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc020411e:	cbdfd0ef          	jal	ra,ffffffffc0201dda <kmalloc>
ffffffffc0204122:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc0204124:	cd21                	beqz	a0,ffffffffc020417c <alloc_proc+0x68>
        /*
         * below fields(add in LAB5) in proc_struct need to be initialized
         *       uint32_t wait_state;                        // waiting state
         *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
         */
        proc->state = PROC_UNINIT;        // 尚未进入就绪态
ffffffffc0204126:	57fd                	li	a5,-1
ffffffffc0204128:	1782                	slli	a5,a5,0x20
ffffffffc020412a:	e11c                	sd	a5,0(a0)
        proc->runs = 0;                   // 运行次数计数器清零
        proc->kstack = 0;                 // 还未分配内核栈
        proc->need_resched = 0;           // 默认不请求调度
        proc->parent = NULL;              // 父进程待后续设置
        proc->mm = NULL;                  // 地址空间后续 copy/share
        memset(&proc->context, 0, sizeof(struct context)); // 确保首次 switch_to 有确定值
ffffffffc020412c:	07000613          	li	a2,112
ffffffffc0204130:	4581                	li	a1,0
        proc->runs = 0;                   // 运行次数计数器清零
ffffffffc0204132:	00052423          	sw	zero,8(a0) # ffffffffc8000008 <end+0x7d487f4>
        proc->kstack = 0;                 // 还未分配内核栈
ffffffffc0204136:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;           // 默认不请求调度
ffffffffc020413a:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;              // 父进程待后续设置
ffffffffc020413e:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;                  // 地址空间后续 copy/share
ffffffffc0204142:	02053423          	sd	zero,40(a0)
        memset(&proc->context, 0, sizeof(struct context)); // 确保首次 switch_to 有确定值
ffffffffc0204146:	03050513          	addi	a0,a0,48
ffffffffc020414a:	117010ef          	jal	ra,ffffffffc0205a60 <memset>
        proc->tf = NULL;                  // trapframe 等栈建立后 copy_thread 设置
        proc->pgdir = boot_pgdir_pa;      // 先使用内核页表基址
ffffffffc020414e:	000b3797          	auipc	a5,0xb3
ffffffffc0204152:	67a7b783          	ld	a5,1658(a5) # ffffffffc02b77c8 <boot_pgdir_pa>
        proc->tf = NULL;                  // trapframe 等栈建立后 copy_thread 设置
ffffffffc0204156:	0a043023          	sd	zero,160(s0)
        proc->pgdir = boot_pgdir_pa;      // 先使用内核页表基址
ffffffffc020415a:	f45c                	sd	a5,168(s0)
        proc->flags = 0;                  // 初始无标志
ffffffffc020415c:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, sizeof(proc->name)); // 进程名清零，后续 set_proc_name
ffffffffc0204160:	4641                	li	a2,16
ffffffffc0204162:	4581                	li	a1,0
ffffffffc0204164:	0b440513          	addi	a0,s0,180
ffffffffc0204168:	0f9010ef          	jal	ra,ffffffffc0205a60 <memset>

        // LAB5: 初始化新增字段
        proc->exit_code = 0;              // 退出码初始化为0
ffffffffc020416c:	0e043423          	sd	zero,232(s0)
        proc->wait_state = 0;             // 等待状态初始化为0
        proc->cptr = proc->yptr = proc->optr = NULL; // 进程关系指针初始化为NULL
ffffffffc0204170:	0e043823          	sd	zero,240(s0)
ffffffffc0204174:	0e043c23          	sd	zero,248(s0)
ffffffffc0204178:	10043023          	sd	zero,256(s0)
    }
    return proc;
}
ffffffffc020417c:	60a2                	ld	ra,8(sp)
ffffffffc020417e:	8522                	mv	a0,s0
ffffffffc0204180:	6402                	ld	s0,0(sp)
ffffffffc0204182:	0141                	addi	sp,sp,16
ffffffffc0204184:	8082                	ret

ffffffffc0204186 <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc0204186:	000b3797          	auipc	a5,0xb3
ffffffffc020418a:	6727b783          	ld	a5,1650(a5) # ffffffffc02b77f8 <current>
ffffffffc020418e:	73c8                	ld	a0,160(a5)
ffffffffc0204190:	ebffc06f          	j	ffffffffc020104e <forkrets>

ffffffffc0204194 <user_main>:
// user_main - kernel thread used to exec a user program
static int
user_main(void *arg)
{
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204194:	000b3797          	auipc	a5,0xb3
ffffffffc0204198:	6647b783          	ld	a5,1636(a5) # ffffffffc02b77f8 <current>
ffffffffc020419c:	43cc                	lw	a1,4(a5)
{
ffffffffc020419e:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc02041a0:	00003617          	auipc	a2,0x3
ffffffffc02041a4:	1f060613          	addi	a2,a2,496 # ffffffffc0207390 <default_pmm_manager+0xa20>
ffffffffc02041a8:	00003517          	auipc	a0,0x3
ffffffffc02041ac:	1f050513          	addi	a0,a0,496 # ffffffffc0207398 <default_pmm_manager+0xa28>
{
ffffffffc02041b0:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc02041b2:	fe3fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02041b6:	3fe09797          	auipc	a5,0x3fe09
ffffffffc02041ba:	eea78793          	addi	a5,a5,-278 # d0a0 <_binary_obj___user_cowtest_out_size>
ffffffffc02041be:	e43e                	sd	a5,8(sp)
ffffffffc02041c0:	00003517          	auipc	a0,0x3
ffffffffc02041c4:	1d050513          	addi	a0,a0,464 # ffffffffc0207390 <default_pmm_manager+0xa20>
ffffffffc02041c8:	0001c797          	auipc	a5,0x1c
ffffffffc02041cc:	dc078793          	addi	a5,a5,-576 # ffffffffc021ff88 <_binary_obj___user_cowtest_out_start>
ffffffffc02041d0:	f03e                	sd	a5,32(sp)
ffffffffc02041d2:	f42a                	sd	a0,40(sp)
    int64_t ret = 0, len = strlen(name);
ffffffffc02041d4:	e802                	sd	zero,16(sp)
ffffffffc02041d6:	7e8010ef          	jal	ra,ffffffffc02059be <strlen>
ffffffffc02041da:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc02041dc:	4511                	li	a0,4
ffffffffc02041de:	55a2                	lw	a1,40(sp)
ffffffffc02041e0:	4662                	lw	a2,24(sp)
ffffffffc02041e2:	5682                	lw	a3,32(sp)
ffffffffc02041e4:	4722                	lw	a4,8(sp)
ffffffffc02041e6:	48a9                	li	a7,10
ffffffffc02041e8:	9002                	ebreak
ffffffffc02041ea:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc02041ec:	65c2                	ld	a1,16(sp)
ffffffffc02041ee:	00003517          	auipc	a0,0x3
ffffffffc02041f2:	1d250513          	addi	a0,a0,466 # ffffffffc02073c0 <default_pmm_manager+0xa50>
ffffffffc02041f6:	f9ffb0ef          	jal	ra,ffffffffc0200194 <cprintf>
#else
    KERNEL_EXECVE(cowtest);
#endif
    panic("user_main execve failed.\n");
ffffffffc02041fa:	00003617          	auipc	a2,0x3
ffffffffc02041fe:	1d660613          	addi	a2,a2,470 # ffffffffc02073d0 <default_pmm_manager+0xa60>
ffffffffc0204202:	3bb00593          	li	a1,955
ffffffffc0204206:	00003517          	auipc	a0,0x3
ffffffffc020420a:	1ea50513          	addi	a0,a0,490 # ffffffffc02073f0 <default_pmm_manager+0xa80>
ffffffffc020420e:	a80fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204212 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204212:	6d14                	ld	a3,24(a0)
{
ffffffffc0204214:	1141                	addi	sp,sp,-16
ffffffffc0204216:	e406                	sd	ra,8(sp)
ffffffffc0204218:	c02007b7          	lui	a5,0xc0200
ffffffffc020421c:	02f6ee63          	bltu	a3,a5,ffffffffc0204258 <put_pgdir+0x46>
ffffffffc0204220:	000b3517          	auipc	a0,0xb3
ffffffffc0204224:	5d053503          	ld	a0,1488(a0) # ffffffffc02b77f0 <va_pa_offset>
ffffffffc0204228:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage)
ffffffffc020422a:	82b1                	srli	a3,a3,0xc
ffffffffc020422c:	000b3797          	auipc	a5,0xb3
ffffffffc0204230:	5ac7b783          	ld	a5,1452(a5) # ffffffffc02b77d8 <npage>
ffffffffc0204234:	02f6fe63          	bgeu	a3,a5,ffffffffc0204270 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0204238:	00004517          	auipc	a0,0x4
ffffffffc020423c:	ae853503          	ld	a0,-1304(a0) # ffffffffc0207d20 <nbase>
}
ffffffffc0204240:	60a2                	ld	ra,8(sp)
ffffffffc0204242:	8e89                	sub	a3,a3,a0
ffffffffc0204244:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204246:	000b3517          	auipc	a0,0xb3
ffffffffc020424a:	59a53503          	ld	a0,1434(a0) # ffffffffc02b77e0 <pages>
ffffffffc020424e:	4585                	li	a1,1
ffffffffc0204250:	9536                	add	a0,a0,a3
}
ffffffffc0204252:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204254:	da3fd06f          	j	ffffffffc0201ff6 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204258:	00002617          	auipc	a2,0x2
ffffffffc020425c:	7f860613          	addi	a2,a2,2040 # ffffffffc0206a50 <default_pmm_manager+0xe0>
ffffffffc0204260:	07d00593          	li	a1,125
ffffffffc0204264:	00002517          	auipc	a0,0x2
ffffffffc0204268:	76c50513          	addi	a0,a0,1900 # ffffffffc02069d0 <default_pmm_manager+0x60>
ffffffffc020426c:	a22fc0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204270:	00003617          	auipc	a2,0x3
ffffffffc0204274:	80860613          	addi	a2,a2,-2040 # ffffffffc0206a78 <default_pmm_manager+0x108>
ffffffffc0204278:	06f00593          	li	a1,111
ffffffffc020427c:	00002517          	auipc	a0,0x2
ffffffffc0204280:	75450513          	addi	a0,a0,1876 # ffffffffc02069d0 <default_pmm_manager+0x60>
ffffffffc0204284:	a0afc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204288 <setup_pgdir>:
{
ffffffffc0204288:	1101                	addi	sp,sp,-32
ffffffffc020428a:	e04a                	sd	s2,0(sp)
ffffffffc020428c:	892a                	mv	s2,a0
    if ((page = alloc_page()) == NULL)
ffffffffc020428e:	4505                	li	a0,1
{
ffffffffc0204290:	ec06                	sd	ra,24(sp)
ffffffffc0204292:	e822                	sd	s0,16(sp)
ffffffffc0204294:	e426                	sd	s1,8(sp)
    if ((page = alloc_page()) == NULL)
ffffffffc0204296:	d23fd0ef          	jal	ra,ffffffffc0201fb8 <alloc_pages>
ffffffffc020429a:	cd39                	beqz	a0,ffffffffc02042f8 <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc020429c:	000b3697          	auipc	a3,0xb3
ffffffffc02042a0:	5446b683          	ld	a3,1348(a3) # ffffffffc02b77e0 <pages>
ffffffffc02042a4:	40d506b3          	sub	a3,a0,a3
ffffffffc02042a8:	00004797          	auipc	a5,0x4
ffffffffc02042ac:	a787b783          	ld	a5,-1416(a5) # ffffffffc0207d20 <nbase>
ffffffffc02042b0:	8699                	srai	a3,a3,0x6
ffffffffc02042b2:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02042b4:	00c69793          	slli	a5,a3,0xc
ffffffffc02042b8:	83b1                	srli	a5,a5,0xc
ffffffffc02042ba:	000b3717          	auipc	a4,0xb3
ffffffffc02042be:	51e73703          	ld	a4,1310(a4) # ffffffffc02b77d8 <npage>
ffffffffc02042c2:	84aa                	mv	s1,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02042c4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02042c6:	04e7f763          	bgeu	a5,a4,ffffffffc0204314 <setup_pgdir+0x8c>
ffffffffc02042ca:	000b3417          	auipc	s0,0xb3
ffffffffc02042ce:	52643403          	ld	s0,1318(s0) # ffffffffc02b77f0 <va_pa_offset>
    if (boot_pgdir_va == NULL) {
ffffffffc02042d2:	000b3597          	auipc	a1,0xb3
ffffffffc02042d6:	4fe5b583          	ld	a1,1278(a1) # ffffffffc02b77d0 <boot_pgdir_va>
ffffffffc02042da:	9436                	add	s0,s0,a3
ffffffffc02042dc:	c185                	beqz	a1,ffffffffc02042fc <setup_pgdir+0x74>
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc02042de:	6605                	lui	a2,0x1
ffffffffc02042e0:	8522                	mv	a0,s0
ffffffffc02042e2:	790010ef          	jal	ra,ffffffffc0205a72 <memcpy>
    return 0;
ffffffffc02042e6:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc02042e8:	00893c23          	sd	s0,24(s2)
}
ffffffffc02042ec:	60e2                	ld	ra,24(sp)
ffffffffc02042ee:	6442                	ld	s0,16(sp)
ffffffffc02042f0:	64a2                	ld	s1,8(sp)
ffffffffc02042f2:	6902                	ld	s2,0(sp)
ffffffffc02042f4:	6105                	addi	sp,sp,32
ffffffffc02042f6:	8082                	ret
        return -E_NO_MEM;
ffffffffc02042f8:	5571                	li	a0,-4
ffffffffc02042fa:	bfcd                	j	ffffffffc02042ec <setup_pgdir+0x64>
        cprintf("[ERROR] setup_pgdir: boot_pgdir_va is NULL\n");
ffffffffc02042fc:	00003517          	auipc	a0,0x3
ffffffffc0204300:	10c50513          	addi	a0,a0,268 # ffffffffc0207408 <default_pmm_manager+0xa98>
ffffffffc0204304:	e91fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
        free_page(page);
ffffffffc0204308:	8526                	mv	a0,s1
ffffffffc020430a:	4585                	li	a1,1
ffffffffc020430c:	cebfd0ef          	jal	ra,ffffffffc0201ff6 <free_pages>
        return -E_INVAL;
ffffffffc0204310:	5575                	li	a0,-3
ffffffffc0204312:	bfe9                	j	ffffffffc02042ec <setup_pgdir+0x64>
ffffffffc0204314:	00002617          	auipc	a2,0x2
ffffffffc0204318:	69460613          	addi	a2,a2,1684 # ffffffffc02069a8 <default_pmm_manager+0x38>
ffffffffc020431c:	07700593          	li	a1,119
ffffffffc0204320:	00002517          	auipc	a0,0x2
ffffffffc0204324:	6b050513          	addi	a0,a0,1712 # ffffffffc02069d0 <default_pmm_manager+0x60>
ffffffffc0204328:	966fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020432c <proc_run>:
{
ffffffffc020432c:	7179                	addi	sp,sp,-48
ffffffffc020432e:	f026                	sd	s1,32(sp)
    if (proc != current)
ffffffffc0204330:	000b3497          	auipc	s1,0xb3
ffffffffc0204334:	4c848493          	addi	s1,s1,1224 # ffffffffc02b77f8 <current>
ffffffffc0204338:	6098                	ld	a4,0(s1)
{
ffffffffc020433a:	f406                	sd	ra,40(sp)
ffffffffc020433c:	ec4a                	sd	s2,24(sp)
    if (proc != current)
ffffffffc020433e:	02a70763          	beq	a4,a0,ffffffffc020436c <proc_run+0x40>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204342:	100027f3          	csrr	a5,sstatus
ffffffffc0204346:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204348:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020434a:	ef85                	bnez	a5,ffffffffc0204382 <proc_run+0x56>
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned long pgdir)
{
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc020434c:	755c                	ld	a5,168(a0)
ffffffffc020434e:	56fd                	li	a3,-1
ffffffffc0204350:	16fe                	slli	a3,a3,0x3f
ffffffffc0204352:	83b1                	srli	a5,a5,0xc
            current = proc;
ffffffffc0204354:	e088                	sd	a0,0(s1)
ffffffffc0204356:	8fd5                	or	a5,a5,a3
ffffffffc0204358:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(proc->context));
ffffffffc020435c:	03050593          	addi	a1,a0,48
ffffffffc0204360:	03070513          	addi	a0,a4,48
ffffffffc0204364:	7d9000ef          	jal	ra,ffffffffc020533c <switch_to>
    if (flag)
ffffffffc0204368:	00091763          	bnez	s2,ffffffffc0204376 <proc_run+0x4a>
}
ffffffffc020436c:	70a2                	ld	ra,40(sp)
ffffffffc020436e:	7482                	ld	s1,32(sp)
ffffffffc0204370:	6962                	ld	s2,24(sp)
ffffffffc0204372:	6145                	addi	sp,sp,48
ffffffffc0204374:	8082                	ret
ffffffffc0204376:	70a2                	ld	ra,40(sp)
ffffffffc0204378:	7482                	ld	s1,32(sp)
ffffffffc020437a:	6962                	ld	s2,24(sp)
ffffffffc020437c:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc020437e:	e30fc06f          	j	ffffffffc02009ae <intr_enable>
ffffffffc0204382:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204384:	e30fc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
            struct proc_struct *prev = current;
ffffffffc0204388:	6098                	ld	a4,0(s1)
        return 1;
ffffffffc020438a:	6522                	ld	a0,8(sp)
ffffffffc020438c:	4905                	li	s2,1
ffffffffc020438e:	bf7d                	j	ffffffffc020434c <proc_run+0x20>

ffffffffc0204390 <do_fork>:
{
ffffffffc0204390:	7159                	addi	sp,sp,-112
ffffffffc0204392:	eca6                	sd	s1,88(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0204394:	000b3497          	auipc	s1,0xb3
ffffffffc0204398:	47c48493          	addi	s1,s1,1148 # ffffffffc02b7810 <nr_process>
ffffffffc020439c:	4098                	lw	a4,0(s1)
{
ffffffffc020439e:	f486                	sd	ra,104(sp)
ffffffffc02043a0:	f0a2                	sd	s0,96(sp)
ffffffffc02043a2:	e8ca                	sd	s2,80(sp)
ffffffffc02043a4:	e4ce                	sd	s3,72(sp)
ffffffffc02043a6:	e0d2                	sd	s4,64(sp)
ffffffffc02043a8:	fc56                	sd	s5,56(sp)
ffffffffc02043aa:	f85a                	sd	s6,48(sp)
ffffffffc02043ac:	f45e                	sd	s7,40(sp)
ffffffffc02043ae:	f062                	sd	s8,32(sp)
ffffffffc02043b0:	ec66                	sd	s9,24(sp)
ffffffffc02043b2:	e86a                	sd	s10,16(sp)
ffffffffc02043b4:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc02043b6:	6785                	lui	a5,0x1
ffffffffc02043b8:	2cf75463          	bge	a4,a5,ffffffffc0204680 <do_fork+0x2f0>
ffffffffc02043bc:	8a2a                	mv	s4,a0
ffffffffc02043be:	892e                	mv	s2,a1
ffffffffc02043c0:	89b2                	mv	s3,a2
    if ((proc = alloc_proc()) == NULL)
ffffffffc02043c2:	d53ff0ef          	jal	ra,ffffffffc0204114 <alloc_proc>
ffffffffc02043c6:	842a                	mv	s0,a0
ffffffffc02043c8:	2c050363          	beqz	a0,ffffffffc020468e <do_fork+0x2fe>
    proc->parent = current;
ffffffffc02043cc:	000b3a97          	auipc	s5,0xb3
ffffffffc02043d0:	42ca8a93          	addi	s5,s5,1068 # ffffffffc02b77f8 <current>
ffffffffc02043d4:	000ab783          	ld	a5,0(s5)
    assert(current->wait_state == 0);
ffffffffc02043d8:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8ac4>
    proc->parent = current;
ffffffffc02043dc:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc02043de:	2a071f63          	bnez	a4,ffffffffc020469c <do_fork+0x30c>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02043e2:	4509                	li	a0,2
ffffffffc02043e4:	bd5fd0ef          	jal	ra,ffffffffc0201fb8 <alloc_pages>
    if (page != NULL)
ffffffffc02043e8:	28050a63          	beqz	a0,ffffffffc020467c <do_fork+0x2ec>
    return page - pages + nbase;
ffffffffc02043ec:	000b3b97          	auipc	s7,0xb3
ffffffffc02043f0:	3f4b8b93          	addi	s7,s7,1012 # ffffffffc02b77e0 <pages>
ffffffffc02043f4:	000bb683          	ld	a3,0(s7)
ffffffffc02043f8:	00004d17          	auipc	s10,0x4
ffffffffc02043fc:	928d0d13          	addi	s10,s10,-1752 # ffffffffc0207d20 <nbase>
ffffffffc0204400:	000d3703          	ld	a4,0(s10)
ffffffffc0204404:	40d506b3          	sub	a3,a0,a3
ffffffffc0204408:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020440a:	000b3d97          	auipc	s11,0xb3
ffffffffc020440e:	3ced8d93          	addi	s11,s11,974 # ffffffffc02b77d8 <npage>
    return page - pages + nbase;
ffffffffc0204412:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0204414:	000db703          	ld	a4,0(s11)
ffffffffc0204418:	00c69793          	slli	a5,a3,0xc
ffffffffc020441c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020441e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204420:	28e7fe63          	bgeu	a5,a4,ffffffffc02046bc <do_fork+0x32c>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204424:	000ab703          	ld	a4,0(s5)
ffffffffc0204428:	000b3b17          	auipc	s6,0xb3
ffffffffc020442c:	3c8b0b13          	addi	s6,s6,968 # ffffffffc02b77f0 <va_pa_offset>
ffffffffc0204430:	000b3783          	ld	a5,0(s6)
ffffffffc0204434:	02873a83          	ld	s5,40(a4)
ffffffffc0204438:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc020443a:	e814                	sd	a3,16(s0)
    if (oldmm == NULL)
ffffffffc020443c:	020a8863          	beqz	s5,ffffffffc020446c <do_fork+0xdc>
    if (clone_flags & CLONE_VM)
ffffffffc0204440:	100a7a13          	andi	s4,s4,256
ffffffffc0204444:	180a0963          	beqz	s4,ffffffffc02045d6 <do_fork+0x246>
}

static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
ffffffffc0204448:	030aa703          	lw	a4,48(s5)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc020444c:	018ab783          	ld	a5,24(s5)
ffffffffc0204450:	c02006b7          	lui	a3,0xc0200
ffffffffc0204454:	2705                	addiw	a4,a4,1
ffffffffc0204456:	02eaa823          	sw	a4,48(s5)
    proc->mm = mm;
ffffffffc020445a:	03543423          	sd	s5,40(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc020445e:	2ad7ef63          	bltu	a5,a3,ffffffffc020471c <do_fork+0x38c>
ffffffffc0204462:	000b3703          	ld	a4,0(s6)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204466:	6814                	ld	a3,16(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204468:	8f99                	sub	a5,a5,a4
ffffffffc020446a:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc020446c:	6789                	lui	a5,0x2
ffffffffc020446e:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd0>
ffffffffc0204472:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204474:	864e                	mv	a2,s3
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204476:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0204478:	87b6                	mv	a5,a3
ffffffffc020447a:	12098893          	addi	a7,s3,288
ffffffffc020447e:	00063803          	ld	a6,0(a2)
ffffffffc0204482:	6608                	ld	a0,8(a2)
ffffffffc0204484:	6a0c                	ld	a1,16(a2)
ffffffffc0204486:	6e18                	ld	a4,24(a2)
ffffffffc0204488:	0107b023          	sd	a6,0(a5)
ffffffffc020448c:	e788                	sd	a0,8(a5)
ffffffffc020448e:	eb8c                	sd	a1,16(a5)
ffffffffc0204490:	ef98                	sd	a4,24(a5)
ffffffffc0204492:	02060613          	addi	a2,a2,32
ffffffffc0204496:	02078793          	addi	a5,a5,32
ffffffffc020449a:	ff1612e3          	bne	a2,a7,ffffffffc020447e <do_fork+0xee>
    proc->tf->gpr.a0 = 0;
ffffffffc020449e:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x6>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02044a2:	18090763          	beqz	s2,ffffffffc0204630 <do_fork+0x2a0>
    if (++last_pid >= MAX_PID)
ffffffffc02044a6:	000af817          	auipc	a6,0xaf
ffffffffc02044aa:	eba80813          	addi	a6,a6,-326 # ffffffffc02b3360 <last_pid.1>
ffffffffc02044ae:	00082783          	lw	a5,0(a6)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02044b2:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02044b6:	00000717          	auipc	a4,0x0
ffffffffc02044ba:	cd070713          	addi	a4,a4,-816 # ffffffffc0204186 <forkret>
    if (++last_pid >= MAX_PID)
ffffffffc02044be:	0017851b          	addiw	a0,a5,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02044c2:	f818                	sd	a4,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02044c4:	fc14                	sd	a3,56(s0)
    if (++last_pid >= MAX_PID)
ffffffffc02044c6:	00a82023          	sw	a0,0(a6)
ffffffffc02044ca:	6789                	lui	a5,0x2
ffffffffc02044cc:	08f55e63          	bge	a0,a5,ffffffffc0204568 <do_fork+0x1d8>
    if (last_pid >= next_safe)
ffffffffc02044d0:	000af317          	auipc	t1,0xaf
ffffffffc02044d4:	e9430313          	addi	t1,t1,-364 # ffffffffc02b3364 <next_safe.0>
ffffffffc02044d8:	00032783          	lw	a5,0(t1)
ffffffffc02044dc:	000b3917          	auipc	s2,0xb3
ffffffffc02044e0:	2a490913          	addi	s2,s2,676 # ffffffffc02b7780 <proc_list>
ffffffffc02044e4:	08f55a63          	bge	a0,a5,ffffffffc0204578 <do_fork+0x1e8>
    proc->pid = get_pid();
ffffffffc02044e8:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02044ea:	45a9                	li	a1,10
ffffffffc02044ec:	2501                	sext.w	a0,a0
ffffffffc02044ee:	0cc010ef          	jal	ra,ffffffffc02055ba <hash32>
ffffffffc02044f2:	02051793          	slli	a5,a0,0x20
ffffffffc02044f6:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02044fa:	000af797          	auipc	a5,0xaf
ffffffffc02044fe:	28678793          	addi	a5,a5,646 # ffffffffc02b3780 <hash_list>
ffffffffc0204502:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204504:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204506:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204508:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc020450c:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc020450e:	00893603          	ld	a2,8(s2)
    prev->next = next->prev = elm;
ffffffffc0204512:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204514:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0204516:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc020451a:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc020451c:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc020451e:	e21c                	sd	a5,0(a2)
ffffffffc0204520:	00f93423          	sd	a5,8(s2)
    elm->next = next;
ffffffffc0204524:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc0204526:	0d243423          	sd	s2,200(s0)
    proc->yptr = NULL;
ffffffffc020452a:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc020452e:	10e43023          	sd	a4,256(s0)
ffffffffc0204532:	c311                	beqz	a4,ffffffffc0204536 <do_fork+0x1a6>
        proc->optr->yptr = proc;
ffffffffc0204534:	ff60                	sd	s0,248(a4)
    nr_process++;
ffffffffc0204536:	409c                	lw	a5,0(s1)
    proc->parent->cptr = proc;
ffffffffc0204538:	fae0                	sd	s0,240(a3)
    wakeup_proc(proc);
ffffffffc020453a:	8522                	mv	a0,s0
    nr_process++;
ffffffffc020453c:	2785                	addiw	a5,a5,1
ffffffffc020453e:	c09c                	sw	a5,0(s1)
    wakeup_proc(proc);
ffffffffc0204540:	667000ef          	jal	ra,ffffffffc02053a6 <wakeup_proc>
    ret = proc->pid;
ffffffffc0204544:	00442c03          	lw	s8,4(s0)
}
ffffffffc0204548:	70a6                	ld	ra,104(sp)
ffffffffc020454a:	7406                	ld	s0,96(sp)
ffffffffc020454c:	64e6                	ld	s1,88(sp)
ffffffffc020454e:	6946                	ld	s2,80(sp)
ffffffffc0204550:	69a6                	ld	s3,72(sp)
ffffffffc0204552:	6a06                	ld	s4,64(sp)
ffffffffc0204554:	7ae2                	ld	s5,56(sp)
ffffffffc0204556:	7b42                	ld	s6,48(sp)
ffffffffc0204558:	7ba2                	ld	s7,40(sp)
ffffffffc020455a:	6ce2                	ld	s9,24(sp)
ffffffffc020455c:	6d42                	ld	s10,16(sp)
ffffffffc020455e:	6da2                	ld	s11,8(sp)
ffffffffc0204560:	8562                	mv	a0,s8
ffffffffc0204562:	7c02                	ld	s8,32(sp)
ffffffffc0204564:	6165                	addi	sp,sp,112
ffffffffc0204566:	8082                	ret
        last_pid = 1;
ffffffffc0204568:	4785                	li	a5,1
ffffffffc020456a:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc020456e:	4505                	li	a0,1
ffffffffc0204570:	000af317          	auipc	t1,0xaf
ffffffffc0204574:	df430313          	addi	t1,t1,-524 # ffffffffc02b3364 <next_safe.0>
    return listelm->next;
ffffffffc0204578:	000b3917          	auipc	s2,0xb3
ffffffffc020457c:	20890913          	addi	s2,s2,520 # ffffffffc02b7780 <proc_list>
ffffffffc0204580:	00893e03          	ld	t3,8(s2)
        next_safe = MAX_PID;
ffffffffc0204584:	6789                	lui	a5,0x2
ffffffffc0204586:	00f32023          	sw	a5,0(t1)
ffffffffc020458a:	86aa                	mv	a3,a0
ffffffffc020458c:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc020458e:	6e89                	lui	t4,0x2
ffffffffc0204590:	0f2e0a63          	beq	t3,s2,ffffffffc0204684 <do_fork+0x2f4>
ffffffffc0204594:	88ae                	mv	a7,a1
ffffffffc0204596:	87f2                	mv	a5,t3
ffffffffc0204598:	6609                	lui	a2,0x2
ffffffffc020459a:	a811                	j	ffffffffc02045ae <do_fork+0x21e>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc020459c:	00e6d663          	bge	a3,a4,ffffffffc02045a8 <do_fork+0x218>
ffffffffc02045a0:	00c75463          	bge	a4,a2,ffffffffc02045a8 <do_fork+0x218>
ffffffffc02045a4:	863a                	mv	a2,a4
ffffffffc02045a6:	4885                	li	a7,1
ffffffffc02045a8:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02045aa:	01278d63          	beq	a5,s2,ffffffffc02045c4 <do_fork+0x234>
            if (proc->pid == last_pid)
ffffffffc02045ae:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c74>
ffffffffc02045b2:	fed715e3          	bne	a4,a3,ffffffffc020459c <do_fork+0x20c>
                if (++last_pid >= next_safe)
ffffffffc02045b6:	2685                	addiw	a3,a3,1
ffffffffc02045b8:	0ac6dd63          	bge	a3,a2,ffffffffc0204672 <do_fork+0x2e2>
ffffffffc02045bc:	679c                	ld	a5,8(a5)
ffffffffc02045be:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc02045c0:	ff2797e3          	bne	a5,s2,ffffffffc02045ae <do_fork+0x21e>
ffffffffc02045c4:	c581                	beqz	a1,ffffffffc02045cc <do_fork+0x23c>
ffffffffc02045c6:	00d82023          	sw	a3,0(a6)
ffffffffc02045ca:	8536                	mv	a0,a3
ffffffffc02045cc:	f0088ee3          	beqz	a7,ffffffffc02044e8 <do_fork+0x158>
ffffffffc02045d0:	00c32023          	sw	a2,0(t1)
ffffffffc02045d4:	bf11                	j	ffffffffc02044e8 <do_fork+0x158>
    if ((mm = mm_create()) == NULL)
ffffffffc02045d6:	c2cff0ef          	jal	ra,ffffffffc0203a02 <mm_create>
ffffffffc02045da:	8caa                	mv	s9,a0
ffffffffc02045dc:	cd55                	beqz	a0,ffffffffc0204698 <do_fork+0x308>
    if (setup_pgdir(mm) != 0)
ffffffffc02045de:	cabff0ef          	jal	ra,ffffffffc0204288 <setup_pgdir>
ffffffffc02045e2:	e929                	bnez	a0,ffffffffc0204634 <do_fork+0x2a4>
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
ffffffffc02045e4:	038a8a13          	addi	s4,s5,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02045e8:	4785                	li	a5,1
ffffffffc02045ea:	40fa37af          	amoor.d	a5,a5,(s4)
}

static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))
ffffffffc02045ee:	8b85                	andi	a5,a5,1
ffffffffc02045f0:	4c05                	li	s8,1
ffffffffc02045f2:	c799                	beqz	a5,ffffffffc0204600 <do_fork+0x270>
    {
        schedule();
ffffffffc02045f4:	633000ef          	jal	ra,ffffffffc0205426 <schedule>
ffffffffc02045f8:	418a37af          	amoor.d	a5,s8,(s4)
    while (!try_lock(lock))
ffffffffc02045fc:	8b85                	andi	a5,a5,1
ffffffffc02045fe:	fbfd                	bnez	a5,ffffffffc02045f4 <do_fork+0x264>
        ret = dup_mmap(mm, oldmm);
ffffffffc0204600:	85d6                	mv	a1,s5
ffffffffc0204602:	8566                	mv	a0,s9
ffffffffc0204604:	e40ff0ef          	jal	ra,ffffffffc0203c44 <dup_mmap>
ffffffffc0204608:	8c2a                	mv	s8,a0
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020460a:	57f9                	li	a5,-2
ffffffffc020460c:	60fa37af          	amoand.d	a5,a5,(s4)
ffffffffc0204610:	8b85                	andi	a5,a5,1
}

static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))
ffffffffc0204612:	0e078963          	beqz	a5,ffffffffc0204704 <do_fork+0x374>
good_mm:
ffffffffc0204616:	8ae6                	mv	s5,s9
    if (ret != 0)
ffffffffc0204618:	e20508e3          	beqz	a0,ffffffffc0204448 <do_fork+0xb8>
    exit_mmap(mm);
ffffffffc020461c:	8566                	mv	a0,s9
ffffffffc020461e:	ec0ff0ef          	jal	ra,ffffffffc0203cde <exit_mmap>
    put_pgdir(mm);
ffffffffc0204622:	8566                	mv	a0,s9
ffffffffc0204624:	befff0ef          	jal	ra,ffffffffc0204212 <put_pgdir>
    mm_destroy(mm);
ffffffffc0204628:	8566                	mv	a0,s9
ffffffffc020462a:	d18ff0ef          	jal	ra,ffffffffc0203b42 <mm_destroy>
ffffffffc020462e:	a039                	j	ffffffffc020463c <do_fork+0x2ac>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204630:	8936                	mv	s2,a3
ffffffffc0204632:	bd95                	j	ffffffffc02044a6 <do_fork+0x116>
    mm_destroy(mm);
ffffffffc0204634:	8566                	mv	a0,s9
ffffffffc0204636:	d0cff0ef          	jal	ra,ffffffffc0203b42 <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc020463a:	5c71                	li	s8,-4
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020463c:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc020463e:	c02007b7          	lui	a5,0xc0200
ffffffffc0204642:	0af6e563          	bltu	a3,a5,ffffffffc02046ec <do_fork+0x35c>
ffffffffc0204646:	000b3703          	ld	a4,0(s6)
    if (PPN(pa) >= npage)
ffffffffc020464a:	000db783          	ld	a5,0(s11)
    return pa2page(PADDR(kva));
ffffffffc020464e:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage)
ffffffffc0204650:	82b1                	srli	a3,a3,0xc
ffffffffc0204652:	08f6f163          	bgeu	a3,a5,ffffffffc02046d4 <do_fork+0x344>
    return &pages[PPN(pa) - nbase];
ffffffffc0204656:	000d3783          	ld	a5,0(s10)
ffffffffc020465a:	000bb503          	ld	a0,0(s7)
ffffffffc020465e:	4589                	li	a1,2
ffffffffc0204660:	8e9d                	sub	a3,a3,a5
ffffffffc0204662:	069a                	slli	a3,a3,0x6
ffffffffc0204664:	9536                	add	a0,a0,a3
ffffffffc0204666:	991fd0ef          	jal	ra,ffffffffc0201ff6 <free_pages>
    kfree(proc);
ffffffffc020466a:	8522                	mv	a0,s0
ffffffffc020466c:	81ffd0ef          	jal	ra,ffffffffc0201e8a <kfree>
    return ret;
ffffffffc0204670:	bde1                	j	ffffffffc0204548 <do_fork+0x1b8>
                    if (last_pid >= MAX_PID)
ffffffffc0204672:	01d6c363          	blt	a3,t4,ffffffffc0204678 <do_fork+0x2e8>
                        last_pid = 1;
ffffffffc0204676:	4685                	li	a3,1
                    goto repeat;
ffffffffc0204678:	4585                	li	a1,1
ffffffffc020467a:	bf19                	j	ffffffffc0204590 <do_fork+0x200>
    return -E_NO_MEM;
ffffffffc020467c:	5c71                	li	s8,-4
ffffffffc020467e:	b7f5                	j	ffffffffc020466a <do_fork+0x2da>
    int ret = -E_NO_FREE_PROC;
ffffffffc0204680:	5c6d                	li	s8,-5
ffffffffc0204682:	b5d9                	j	ffffffffc0204548 <do_fork+0x1b8>
ffffffffc0204684:	c599                	beqz	a1,ffffffffc0204692 <do_fork+0x302>
ffffffffc0204686:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc020468a:	8536                	mv	a0,a3
ffffffffc020468c:	bdb1                	j	ffffffffc02044e8 <do_fork+0x158>
    ret = -E_NO_MEM;
ffffffffc020468e:	5c71                	li	s8,-4
ffffffffc0204690:	bd65                	j	ffffffffc0204548 <do_fork+0x1b8>
    return last_pid;
ffffffffc0204692:	00082503          	lw	a0,0(a6)
ffffffffc0204696:	bd89                	j	ffffffffc02044e8 <do_fork+0x158>
    int ret = -E_NO_MEM;
ffffffffc0204698:	5c71                	li	s8,-4
ffffffffc020469a:	b74d                	j	ffffffffc020463c <do_fork+0x2ac>
    assert(current->wait_state == 0);
ffffffffc020469c:	00003697          	auipc	a3,0x3
ffffffffc02046a0:	d9c68693          	addi	a3,a3,-612 # ffffffffc0207438 <default_pmm_manager+0xac8>
ffffffffc02046a4:	00002617          	auipc	a2,0x2
ffffffffc02046a8:	f1c60613          	addi	a2,a2,-228 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02046ac:	1e600593          	li	a1,486
ffffffffc02046b0:	00003517          	auipc	a0,0x3
ffffffffc02046b4:	d4050513          	addi	a0,a0,-704 # ffffffffc02073f0 <default_pmm_manager+0xa80>
ffffffffc02046b8:	dd7fb0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc02046bc:	00002617          	auipc	a2,0x2
ffffffffc02046c0:	2ec60613          	addi	a2,a2,748 # ffffffffc02069a8 <default_pmm_manager+0x38>
ffffffffc02046c4:	07700593          	li	a1,119
ffffffffc02046c8:	00002517          	auipc	a0,0x2
ffffffffc02046cc:	30850513          	addi	a0,a0,776 # ffffffffc02069d0 <default_pmm_manager+0x60>
ffffffffc02046d0:	dbffb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02046d4:	00002617          	auipc	a2,0x2
ffffffffc02046d8:	3a460613          	addi	a2,a2,932 # ffffffffc0206a78 <default_pmm_manager+0x108>
ffffffffc02046dc:	06f00593          	li	a1,111
ffffffffc02046e0:	00002517          	auipc	a0,0x2
ffffffffc02046e4:	2f050513          	addi	a0,a0,752 # ffffffffc02069d0 <default_pmm_manager+0x60>
ffffffffc02046e8:	da7fb0ef          	jal	ra,ffffffffc020048e <__panic>
    return pa2page(PADDR(kva));
ffffffffc02046ec:	00002617          	auipc	a2,0x2
ffffffffc02046f0:	36460613          	addi	a2,a2,868 # ffffffffc0206a50 <default_pmm_manager+0xe0>
ffffffffc02046f4:	07d00593          	li	a1,125
ffffffffc02046f8:	00002517          	auipc	a0,0x2
ffffffffc02046fc:	2d850513          	addi	a0,a0,728 # ffffffffc02069d0 <default_pmm_manager+0x60>
ffffffffc0204700:	d8ffb0ef          	jal	ra,ffffffffc020048e <__panic>
    {
        panic("Unlock failed.\n");
ffffffffc0204704:	00003617          	auipc	a2,0x3
ffffffffc0204708:	d5460613          	addi	a2,a2,-684 # ffffffffc0207458 <default_pmm_manager+0xae8>
ffffffffc020470c:	03f00593          	li	a1,63
ffffffffc0204710:	00003517          	auipc	a0,0x3
ffffffffc0204714:	d5850513          	addi	a0,a0,-680 # ffffffffc0207468 <default_pmm_manager+0xaf8>
ffffffffc0204718:	d77fb0ef          	jal	ra,ffffffffc020048e <__panic>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc020471c:	86be                	mv	a3,a5
ffffffffc020471e:	00002617          	auipc	a2,0x2
ffffffffc0204722:	33260613          	addi	a2,a2,818 # ffffffffc0206a50 <default_pmm_manager+0xe0>
ffffffffc0204726:	19300593          	li	a1,403
ffffffffc020472a:	00003517          	auipc	a0,0x3
ffffffffc020472e:	cc650513          	addi	a0,a0,-826 # ffffffffc02073f0 <default_pmm_manager+0xa80>
ffffffffc0204732:	d5dfb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204736 <kernel_thread>:
{
ffffffffc0204736:	7129                	addi	sp,sp,-320
ffffffffc0204738:	fa22                	sd	s0,304(sp)
ffffffffc020473a:	f626                	sd	s1,296(sp)
ffffffffc020473c:	f24a                	sd	s2,288(sp)
ffffffffc020473e:	84ae                	mv	s1,a1
ffffffffc0204740:	892a                	mv	s2,a0
ffffffffc0204742:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204744:	4581                	li	a1,0
ffffffffc0204746:	12000613          	li	a2,288
ffffffffc020474a:	850a                	mv	a0,sp
{
ffffffffc020474c:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020474e:	312010ef          	jal	ra,ffffffffc0205a60 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0204752:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0204754:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204756:	100027f3          	csrr	a5,sstatus
ffffffffc020475a:	edd7f793          	andi	a5,a5,-291
ffffffffc020475e:	1207e793          	ori	a5,a5,288
ffffffffc0204762:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204764:	860a                	mv	a2,sp
ffffffffc0204766:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020476a:	00000797          	auipc	a5,0x0
ffffffffc020476e:	9a278793          	addi	a5,a5,-1630 # ffffffffc020410c <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204772:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204774:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204776:	c1bff0ef          	jal	ra,ffffffffc0204390 <do_fork>
}
ffffffffc020477a:	70f2                	ld	ra,312(sp)
ffffffffc020477c:	7452                	ld	s0,304(sp)
ffffffffc020477e:	74b2                	ld	s1,296(sp)
ffffffffc0204780:	7912                	ld	s2,288(sp)
ffffffffc0204782:	6131                	addi	sp,sp,320
ffffffffc0204784:	8082                	ret

ffffffffc0204786 <do_exit>:
{
ffffffffc0204786:	7179                	addi	sp,sp,-48
ffffffffc0204788:	f022                	sd	s0,32(sp)
    if (current == idleproc)
ffffffffc020478a:	000b3417          	auipc	s0,0xb3
ffffffffc020478e:	06e40413          	addi	s0,s0,110 # ffffffffc02b77f8 <current>
ffffffffc0204792:	601c                	ld	a5,0(s0)
{
ffffffffc0204794:	f406                	sd	ra,40(sp)
ffffffffc0204796:	ec26                	sd	s1,24(sp)
ffffffffc0204798:	e84a                	sd	s2,16(sp)
ffffffffc020479a:	e44e                	sd	s3,8(sp)
ffffffffc020479c:	e052                	sd	s4,0(sp)
    if (current == idleproc)
ffffffffc020479e:	000b3717          	auipc	a4,0xb3
ffffffffc02047a2:	06273703          	ld	a4,98(a4) # ffffffffc02b7800 <idleproc>
ffffffffc02047a6:	0ce78c63          	beq	a5,a4,ffffffffc020487e <do_exit+0xf8>
    if (current == initproc)
ffffffffc02047aa:	000b3497          	auipc	s1,0xb3
ffffffffc02047ae:	05e48493          	addi	s1,s1,94 # ffffffffc02b7808 <initproc>
ffffffffc02047b2:	6098                	ld	a4,0(s1)
ffffffffc02047b4:	0ee78b63          	beq	a5,a4,ffffffffc02048aa <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc02047b8:	0287b983          	ld	s3,40(a5)
ffffffffc02047bc:	892a                	mv	s2,a0
    if (mm != NULL)
ffffffffc02047be:	02098663          	beqz	s3,ffffffffc02047ea <do_exit+0x64>
ffffffffc02047c2:	000b3797          	auipc	a5,0xb3
ffffffffc02047c6:	0067b783          	ld	a5,6(a5) # ffffffffc02b77c8 <boot_pgdir_pa>
ffffffffc02047ca:	577d                	li	a4,-1
ffffffffc02047cc:	177e                	slli	a4,a4,0x3f
ffffffffc02047ce:	83b1                	srli	a5,a5,0xc
ffffffffc02047d0:	8fd9                	or	a5,a5,a4
ffffffffc02047d2:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02047d6:	0309a783          	lw	a5,48(s3)
ffffffffc02047da:	fff7871b          	addiw	a4,a5,-1
ffffffffc02047de:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0)
ffffffffc02047e2:	cb55                	beqz	a4,ffffffffc0204896 <do_exit+0x110>
        current->mm = NULL;
ffffffffc02047e4:	601c                	ld	a5,0(s0)
ffffffffc02047e6:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02047ea:	601c                	ld	a5,0(s0)
ffffffffc02047ec:	470d                	li	a4,3
ffffffffc02047ee:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc02047f0:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02047f4:	100027f3          	csrr	a5,sstatus
ffffffffc02047f8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02047fa:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02047fc:	e3f9                	bnez	a5,ffffffffc02048c2 <do_exit+0x13c>
        proc = current->parent;
ffffffffc02047fe:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204800:	800007b7          	lui	a5,0x80000
ffffffffc0204804:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc0204806:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204808:	0ec52703          	lw	a4,236(a0)
ffffffffc020480c:	0af70f63          	beq	a4,a5,ffffffffc02048ca <do_exit+0x144>
        while (current->cptr != NULL)
ffffffffc0204810:	6018                	ld	a4,0(s0)
ffffffffc0204812:	7b7c                	ld	a5,240(a4)
ffffffffc0204814:	c3a1                	beqz	a5,ffffffffc0204854 <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204816:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE)
ffffffffc020481a:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD)
ffffffffc020481c:	0985                	addi	s3,s3,1
ffffffffc020481e:	a021                	j	ffffffffc0204826 <do_exit+0xa0>
        while (current->cptr != NULL)
ffffffffc0204820:	6018                	ld	a4,0(s0)
ffffffffc0204822:	7b7c                	ld	a5,240(a4)
ffffffffc0204824:	cb85                	beqz	a5,ffffffffc0204854 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc0204826:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_cowtest_out_size+0xffffffff7fff3060>
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc020482a:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc020482c:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc020482e:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0204830:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204834:	10e7b023          	sd	a4,256(a5)
ffffffffc0204838:	c311                	beqz	a4,ffffffffc020483c <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc020483a:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc020483c:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc020483e:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0204840:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204842:	fd271fe3          	bne	a4,s2,ffffffffc0204820 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204846:	0ec52783          	lw	a5,236(a0)
ffffffffc020484a:	fd379be3          	bne	a5,s3,ffffffffc0204820 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc020484e:	359000ef          	jal	ra,ffffffffc02053a6 <wakeup_proc>
ffffffffc0204852:	b7f9                	j	ffffffffc0204820 <do_exit+0x9a>
    if (flag)
ffffffffc0204854:	020a1263          	bnez	s4,ffffffffc0204878 <do_exit+0xf2>
    schedule();
ffffffffc0204858:	3cf000ef          	jal	ra,ffffffffc0205426 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc020485c:	601c                	ld	a5,0(s0)
ffffffffc020485e:	00003617          	auipc	a2,0x3
ffffffffc0204862:	c4260613          	addi	a2,a2,-958 # ffffffffc02074a0 <default_pmm_manager+0xb30>
ffffffffc0204866:	24200593          	li	a1,578
ffffffffc020486a:	43d4                	lw	a3,4(a5)
ffffffffc020486c:	00003517          	auipc	a0,0x3
ffffffffc0204870:	b8450513          	addi	a0,a0,-1148 # ffffffffc02073f0 <default_pmm_manager+0xa80>
ffffffffc0204874:	c1bfb0ef          	jal	ra,ffffffffc020048e <__panic>
        intr_enable();
ffffffffc0204878:	936fc0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020487c:	bff1                	j	ffffffffc0204858 <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc020487e:	00003617          	auipc	a2,0x3
ffffffffc0204882:	c0260613          	addi	a2,a2,-1022 # ffffffffc0207480 <default_pmm_manager+0xb10>
ffffffffc0204886:	20e00593          	li	a1,526
ffffffffc020488a:	00003517          	auipc	a0,0x3
ffffffffc020488e:	b6650513          	addi	a0,a0,-1178 # ffffffffc02073f0 <default_pmm_manager+0xa80>
ffffffffc0204892:	bfdfb0ef          	jal	ra,ffffffffc020048e <__panic>
            exit_mmap(mm);
ffffffffc0204896:	854e                	mv	a0,s3
ffffffffc0204898:	c46ff0ef          	jal	ra,ffffffffc0203cde <exit_mmap>
            put_pgdir(mm);
ffffffffc020489c:	854e                	mv	a0,s3
ffffffffc020489e:	975ff0ef          	jal	ra,ffffffffc0204212 <put_pgdir>
            mm_destroy(mm);
ffffffffc02048a2:	854e                	mv	a0,s3
ffffffffc02048a4:	a9eff0ef          	jal	ra,ffffffffc0203b42 <mm_destroy>
ffffffffc02048a8:	bf35                	j	ffffffffc02047e4 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc02048aa:	00003617          	auipc	a2,0x3
ffffffffc02048ae:	be660613          	addi	a2,a2,-1050 # ffffffffc0207490 <default_pmm_manager+0xb20>
ffffffffc02048b2:	21200593          	li	a1,530
ffffffffc02048b6:	00003517          	auipc	a0,0x3
ffffffffc02048ba:	b3a50513          	addi	a0,a0,-1222 # ffffffffc02073f0 <default_pmm_manager+0xa80>
ffffffffc02048be:	bd1fb0ef          	jal	ra,ffffffffc020048e <__panic>
        intr_disable();
ffffffffc02048c2:	8f2fc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc02048c6:	4a05                	li	s4,1
ffffffffc02048c8:	bf1d                	j	ffffffffc02047fe <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc02048ca:	2dd000ef          	jal	ra,ffffffffc02053a6 <wakeup_proc>
ffffffffc02048ce:	b789                	j	ffffffffc0204810 <do_exit+0x8a>

ffffffffc02048d0 <do_wait.part.0>:
int do_wait(int pid, int *code_store)
ffffffffc02048d0:	715d                	addi	sp,sp,-80
ffffffffc02048d2:	f84a                	sd	s2,48(sp)
ffffffffc02048d4:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc02048d6:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID)
ffffffffc02048da:	6989                	lui	s3,0x2
int do_wait(int pid, int *code_store)
ffffffffc02048dc:	fc26                	sd	s1,56(sp)
ffffffffc02048de:	f052                	sd	s4,32(sp)
ffffffffc02048e0:	ec56                	sd	s5,24(sp)
ffffffffc02048e2:	e85a                	sd	s6,16(sp)
ffffffffc02048e4:	e45e                	sd	s7,8(sp)
ffffffffc02048e6:	e486                	sd	ra,72(sp)
ffffffffc02048e8:	e0a2                	sd	s0,64(sp)
ffffffffc02048ea:	84aa                	mv	s1,a0
ffffffffc02048ec:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc02048ee:	000b3b97          	auipc	s7,0xb3
ffffffffc02048f2:	f0ab8b93          	addi	s7,s7,-246 # ffffffffc02b77f8 <current>
    if (0 < pid && pid < MAX_PID)
ffffffffc02048f6:	00050b1b          	sext.w	s6,a0
ffffffffc02048fa:	fff50a9b          	addiw	s5,a0,-1
ffffffffc02048fe:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc0204900:	0905                	addi	s2,s2,1
    if (pid != 0)
ffffffffc0204902:	ccbd                	beqz	s1,ffffffffc0204980 <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204904:	0359e863          	bltu	s3,s5,ffffffffc0204934 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204908:	45a9                	li	a1,10
ffffffffc020490a:	855a                	mv	a0,s6
ffffffffc020490c:	4af000ef          	jal	ra,ffffffffc02055ba <hash32>
ffffffffc0204910:	02051793          	slli	a5,a0,0x20
ffffffffc0204914:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204918:	000af797          	auipc	a5,0xaf
ffffffffc020491c:	e6878793          	addi	a5,a5,-408 # ffffffffc02b3780 <hash_list>
ffffffffc0204920:	953e                	add	a0,a0,a5
ffffffffc0204922:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list)
ffffffffc0204924:	a029                	j	ffffffffc020492e <do_wait.part.0+0x5e>
            if (proc->pid == pid)
ffffffffc0204926:	f2c42783          	lw	a5,-212(s0)
ffffffffc020492a:	02978163          	beq	a5,s1,ffffffffc020494c <do_wait.part.0+0x7c>
ffffffffc020492e:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list)
ffffffffc0204930:	fe851be3          	bne	a0,s0,ffffffffc0204926 <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc0204934:	5579                	li	a0,-2
}
ffffffffc0204936:	60a6                	ld	ra,72(sp)
ffffffffc0204938:	6406                	ld	s0,64(sp)
ffffffffc020493a:	74e2                	ld	s1,56(sp)
ffffffffc020493c:	7942                	ld	s2,48(sp)
ffffffffc020493e:	79a2                	ld	s3,40(sp)
ffffffffc0204940:	7a02                	ld	s4,32(sp)
ffffffffc0204942:	6ae2                	ld	s5,24(sp)
ffffffffc0204944:	6b42                	ld	s6,16(sp)
ffffffffc0204946:	6ba2                	ld	s7,8(sp)
ffffffffc0204948:	6161                	addi	sp,sp,80
ffffffffc020494a:	8082                	ret
        if (proc != NULL && proc->parent == current)
ffffffffc020494c:	000bb683          	ld	a3,0(s7)
ffffffffc0204950:	f4843783          	ld	a5,-184(s0)
ffffffffc0204954:	fed790e3          	bne	a5,a3,ffffffffc0204934 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204958:	f2842703          	lw	a4,-216(s0)
ffffffffc020495c:	478d                	li	a5,3
ffffffffc020495e:	0ef70b63          	beq	a4,a5,ffffffffc0204a54 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc0204962:	4785                	li	a5,1
ffffffffc0204964:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc0204966:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc020496a:	2bd000ef          	jal	ra,ffffffffc0205426 <schedule>
        if (current->flags & PF_EXITING)
ffffffffc020496e:	000bb783          	ld	a5,0(s7)
ffffffffc0204972:	0b07a783          	lw	a5,176(a5)
ffffffffc0204976:	8b85                	andi	a5,a5,1
ffffffffc0204978:	d7c9                	beqz	a5,ffffffffc0204902 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc020497a:	555d                	li	a0,-9
ffffffffc020497c:	e0bff0ef          	jal	ra,ffffffffc0204786 <do_exit>
        proc = current->cptr;
ffffffffc0204980:	000bb683          	ld	a3,0(s7)
ffffffffc0204984:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr)
ffffffffc0204986:	d45d                	beqz	s0,ffffffffc0204934 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204988:	470d                	li	a4,3
ffffffffc020498a:	a021                	j	ffffffffc0204992 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr)
ffffffffc020498c:	10043403          	ld	s0,256(s0)
ffffffffc0204990:	d869                	beqz	s0,ffffffffc0204962 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204992:	401c                	lw	a5,0(s0)
ffffffffc0204994:	fee79ce3          	bne	a5,a4,ffffffffc020498c <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc)
ffffffffc0204998:	000b3797          	auipc	a5,0xb3
ffffffffc020499c:	e687b783          	ld	a5,-408(a5) # ffffffffc02b7800 <idleproc>
ffffffffc02049a0:	0c878963          	beq	a5,s0,ffffffffc0204a72 <do_wait.part.0+0x1a2>
ffffffffc02049a4:	000b3797          	auipc	a5,0xb3
ffffffffc02049a8:	e647b783          	ld	a5,-412(a5) # ffffffffc02b7808 <initproc>
ffffffffc02049ac:	0cf40363          	beq	s0,a5,ffffffffc0204a72 <do_wait.part.0+0x1a2>
    if (code_store != NULL)
ffffffffc02049b0:	000a0663          	beqz	s4,ffffffffc02049bc <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc02049b4:	0e842783          	lw	a5,232(s0)
ffffffffc02049b8:	00fa2023          	sw	a5,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02049bc:	100027f3          	csrr	a5,sstatus
ffffffffc02049c0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02049c2:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02049c4:	e7c1                	bnez	a5,ffffffffc0204a4c <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02049c6:	6c70                	ld	a2,216(s0)
ffffffffc02049c8:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL)
ffffffffc02049ca:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc02049ce:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02049d0:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02049d2:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02049d4:	6470                	ld	a2,200(s0)
ffffffffc02049d6:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc02049d8:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02049da:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL)
ffffffffc02049dc:	c319                	beqz	a4,ffffffffc02049e2 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc02049de:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL)
ffffffffc02049e0:	7c7c                	ld	a5,248(s0)
ffffffffc02049e2:	c3b5                	beqz	a5,ffffffffc0204a46 <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc02049e4:	10e7b023          	sd	a4,256(a5)
    nr_process--;
ffffffffc02049e8:	000b3717          	auipc	a4,0xb3
ffffffffc02049ec:	e2870713          	addi	a4,a4,-472 # ffffffffc02b7810 <nr_process>
ffffffffc02049f0:	431c                	lw	a5,0(a4)
ffffffffc02049f2:	37fd                	addiw	a5,a5,-1
ffffffffc02049f4:	c31c                	sw	a5,0(a4)
    if (flag)
ffffffffc02049f6:	e5a9                	bnez	a1,ffffffffc0204a40 <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02049f8:	6814                	ld	a3,16(s0)
ffffffffc02049fa:	c02007b7          	lui	a5,0xc0200
ffffffffc02049fe:	04f6ee63          	bltu	a3,a5,ffffffffc0204a5a <do_wait.part.0+0x18a>
ffffffffc0204a02:	000b3797          	auipc	a5,0xb3
ffffffffc0204a06:	dee7b783          	ld	a5,-530(a5) # ffffffffc02b77f0 <va_pa_offset>
ffffffffc0204a0a:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage)
ffffffffc0204a0c:	82b1                	srli	a3,a3,0xc
ffffffffc0204a0e:	000b3797          	auipc	a5,0xb3
ffffffffc0204a12:	dca7b783          	ld	a5,-566(a5) # ffffffffc02b77d8 <npage>
ffffffffc0204a16:	06f6fa63          	bgeu	a3,a5,ffffffffc0204a8a <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0204a1a:	00003517          	auipc	a0,0x3
ffffffffc0204a1e:	30653503          	ld	a0,774(a0) # ffffffffc0207d20 <nbase>
ffffffffc0204a22:	8e89                	sub	a3,a3,a0
ffffffffc0204a24:	069a                	slli	a3,a3,0x6
ffffffffc0204a26:	000b3517          	auipc	a0,0xb3
ffffffffc0204a2a:	dba53503          	ld	a0,-582(a0) # ffffffffc02b77e0 <pages>
ffffffffc0204a2e:	9536                	add	a0,a0,a3
ffffffffc0204a30:	4589                	li	a1,2
ffffffffc0204a32:	dc4fd0ef          	jal	ra,ffffffffc0201ff6 <free_pages>
    kfree(proc);
ffffffffc0204a36:	8522                	mv	a0,s0
ffffffffc0204a38:	c52fd0ef          	jal	ra,ffffffffc0201e8a <kfree>
    return 0;
ffffffffc0204a3c:	4501                	li	a0,0
ffffffffc0204a3e:	bde5                	j	ffffffffc0204936 <do_wait.part.0+0x66>
        intr_enable();
ffffffffc0204a40:	f6ffb0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0204a44:	bf55                	j	ffffffffc02049f8 <do_wait.part.0+0x128>
        proc->parent->cptr = proc->optr;
ffffffffc0204a46:	701c                	ld	a5,32(s0)
ffffffffc0204a48:	fbf8                	sd	a4,240(a5)
ffffffffc0204a4a:	bf79                	j	ffffffffc02049e8 <do_wait.part.0+0x118>
        intr_disable();
ffffffffc0204a4c:	f69fb0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc0204a50:	4585                	li	a1,1
ffffffffc0204a52:	bf95                	j	ffffffffc02049c6 <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204a54:	f2840413          	addi	s0,s0,-216
ffffffffc0204a58:	b781                	j	ffffffffc0204998 <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc0204a5a:	00002617          	auipc	a2,0x2
ffffffffc0204a5e:	ff660613          	addi	a2,a2,-10 # ffffffffc0206a50 <default_pmm_manager+0xe0>
ffffffffc0204a62:	07d00593          	li	a1,125
ffffffffc0204a66:	00002517          	auipc	a0,0x2
ffffffffc0204a6a:	f6a50513          	addi	a0,a0,-150 # ffffffffc02069d0 <default_pmm_manager+0x60>
ffffffffc0204a6e:	a21fb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc0204a72:	00003617          	auipc	a2,0x3
ffffffffc0204a76:	a4e60613          	addi	a2,a2,-1458 # ffffffffc02074c0 <default_pmm_manager+0xb50>
ffffffffc0204a7a:	36300593          	li	a1,867
ffffffffc0204a7e:	00003517          	auipc	a0,0x3
ffffffffc0204a82:	97250513          	addi	a0,a0,-1678 # ffffffffc02073f0 <default_pmm_manager+0xa80>
ffffffffc0204a86:	a09fb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204a8a:	00002617          	auipc	a2,0x2
ffffffffc0204a8e:	fee60613          	addi	a2,a2,-18 # ffffffffc0206a78 <default_pmm_manager+0x108>
ffffffffc0204a92:	06f00593          	li	a1,111
ffffffffc0204a96:	00002517          	auipc	a0,0x2
ffffffffc0204a9a:	f3a50513          	addi	a0,a0,-198 # ffffffffc02069d0 <default_pmm_manager+0x60>
ffffffffc0204a9e:	9f1fb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204aa2 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc0204aa2:	1141                	addi	sp,sp,-16
ffffffffc0204aa4:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0204aa6:	d90fd0ef          	jal	ra,ffffffffc0202036 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0204aaa:	b2cfd0ef          	jal	ra,ffffffffc0201dd6 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0204aae:	4601                	li	a2,0
ffffffffc0204ab0:	4581                	li	a1,0
ffffffffc0204ab2:	fffff517          	auipc	a0,0xfffff
ffffffffc0204ab6:	6e250513          	addi	a0,a0,1762 # ffffffffc0204194 <user_main>
ffffffffc0204aba:	c7dff0ef          	jal	ra,ffffffffc0204736 <kernel_thread>
    if (pid <= 0)
ffffffffc0204abe:	00a04563          	bgtz	a0,ffffffffc0204ac8 <init_main+0x26>
ffffffffc0204ac2:	a071                	j	ffffffffc0204b4e <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
ffffffffc0204ac4:	163000ef          	jal	ra,ffffffffc0205426 <schedule>
    if (code_store != NULL)
ffffffffc0204ac8:	4581                	li	a1,0
ffffffffc0204aca:	4501                	li	a0,0
ffffffffc0204acc:	e05ff0ef          	jal	ra,ffffffffc02048d0 <do_wait.part.0>
    while (do_wait(0, NULL) == 0)
ffffffffc0204ad0:	d975                	beqz	a0,ffffffffc0204ac4 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0204ad2:	00003517          	auipc	a0,0x3
ffffffffc0204ad6:	a2e50513          	addi	a0,a0,-1490 # ffffffffc0207500 <default_pmm_manager+0xb90>
ffffffffc0204ada:	ebafb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204ade:	000b3797          	auipc	a5,0xb3
ffffffffc0204ae2:	d2a7b783          	ld	a5,-726(a5) # ffffffffc02b7808 <initproc>
ffffffffc0204ae6:	7bf8                	ld	a4,240(a5)
ffffffffc0204ae8:	e339                	bnez	a4,ffffffffc0204b2e <init_main+0x8c>
ffffffffc0204aea:	7ff8                	ld	a4,248(a5)
ffffffffc0204aec:	e329                	bnez	a4,ffffffffc0204b2e <init_main+0x8c>
ffffffffc0204aee:	1007b703          	ld	a4,256(a5)
ffffffffc0204af2:	ef15                	bnez	a4,ffffffffc0204b2e <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc0204af4:	000b3697          	auipc	a3,0xb3
ffffffffc0204af8:	d1c6a683          	lw	a3,-740(a3) # ffffffffc02b7810 <nr_process>
ffffffffc0204afc:	4709                	li	a4,2
ffffffffc0204afe:	0ae69463          	bne	a3,a4,ffffffffc0204ba6 <init_main+0x104>
    return listelm->next;
ffffffffc0204b02:	000b3697          	auipc	a3,0xb3
ffffffffc0204b06:	c7e68693          	addi	a3,a3,-898 # ffffffffc02b7780 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204b0a:	6698                	ld	a4,8(a3)
ffffffffc0204b0c:	0c878793          	addi	a5,a5,200
ffffffffc0204b10:	06f71b63          	bne	a4,a5,ffffffffc0204b86 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204b14:	629c                	ld	a5,0(a3)
ffffffffc0204b16:	04f71863          	bne	a4,a5,ffffffffc0204b66 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc0204b1a:	00003517          	auipc	a0,0x3
ffffffffc0204b1e:	ace50513          	addi	a0,a0,-1330 # ffffffffc02075e8 <default_pmm_manager+0xc78>
ffffffffc0204b22:	e72fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    return 0;
}
ffffffffc0204b26:	60a2                	ld	ra,8(sp)
ffffffffc0204b28:	4501                	li	a0,0
ffffffffc0204b2a:	0141                	addi	sp,sp,16
ffffffffc0204b2c:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204b2e:	00003697          	auipc	a3,0x3
ffffffffc0204b32:	9fa68693          	addi	a3,a3,-1542 # ffffffffc0207528 <default_pmm_manager+0xbb8>
ffffffffc0204b36:	00002617          	auipc	a2,0x2
ffffffffc0204b3a:	a8a60613          	addi	a2,a2,-1398 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0204b3e:	3d100593          	li	a1,977
ffffffffc0204b42:	00003517          	auipc	a0,0x3
ffffffffc0204b46:	8ae50513          	addi	a0,a0,-1874 # ffffffffc02073f0 <default_pmm_manager+0xa80>
ffffffffc0204b4a:	945fb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("create user_main failed.\n");
ffffffffc0204b4e:	00003617          	auipc	a2,0x3
ffffffffc0204b52:	99260613          	addi	a2,a2,-1646 # ffffffffc02074e0 <default_pmm_manager+0xb70>
ffffffffc0204b56:	3c800593          	li	a1,968
ffffffffc0204b5a:	00003517          	auipc	a0,0x3
ffffffffc0204b5e:	89650513          	addi	a0,a0,-1898 # ffffffffc02073f0 <default_pmm_manager+0xa80>
ffffffffc0204b62:	92dfb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204b66:	00003697          	auipc	a3,0x3
ffffffffc0204b6a:	a5268693          	addi	a3,a3,-1454 # ffffffffc02075b8 <default_pmm_manager+0xc48>
ffffffffc0204b6e:	00002617          	auipc	a2,0x2
ffffffffc0204b72:	a5260613          	addi	a2,a2,-1454 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0204b76:	3d400593          	li	a1,980
ffffffffc0204b7a:	00003517          	auipc	a0,0x3
ffffffffc0204b7e:	87650513          	addi	a0,a0,-1930 # ffffffffc02073f0 <default_pmm_manager+0xa80>
ffffffffc0204b82:	90dfb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204b86:	00003697          	auipc	a3,0x3
ffffffffc0204b8a:	a0268693          	addi	a3,a3,-1534 # ffffffffc0207588 <default_pmm_manager+0xc18>
ffffffffc0204b8e:	00002617          	auipc	a2,0x2
ffffffffc0204b92:	a3260613          	addi	a2,a2,-1486 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0204b96:	3d300593          	li	a1,979
ffffffffc0204b9a:	00003517          	auipc	a0,0x3
ffffffffc0204b9e:	85650513          	addi	a0,a0,-1962 # ffffffffc02073f0 <default_pmm_manager+0xa80>
ffffffffc0204ba2:	8edfb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_process == 2);
ffffffffc0204ba6:	00003697          	auipc	a3,0x3
ffffffffc0204baa:	9d268693          	addi	a3,a3,-1582 # ffffffffc0207578 <default_pmm_manager+0xc08>
ffffffffc0204bae:	00002617          	auipc	a2,0x2
ffffffffc0204bb2:	a1260613          	addi	a2,a2,-1518 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0204bb6:	3d200593          	li	a1,978
ffffffffc0204bba:	00003517          	auipc	a0,0x3
ffffffffc0204bbe:	83650513          	addi	a0,a0,-1994 # ffffffffc02073f0 <default_pmm_manager+0xa80>
ffffffffc0204bc2:	8cdfb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204bc6 <do_execve>:
{
ffffffffc0204bc6:	7135                	addi	sp,sp,-160
ffffffffc0204bc8:	ecde                	sd	s7,88(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204bca:	000b3b97          	auipc	s7,0xb3
ffffffffc0204bce:	c2eb8b93          	addi	s7,s7,-978 # ffffffffc02b77f8 <current>
ffffffffc0204bd2:	000bb783          	ld	a5,0(s7)
{
ffffffffc0204bd6:	fcce                	sd	s3,120(sp)
ffffffffc0204bd8:	e526                	sd	s1,136(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204bda:	0287b983          	ld	s3,40(a5)
{
ffffffffc0204bde:	e14a                	sd	s2,128(sp)
ffffffffc0204be0:	f4d6                	sd	s5,104(sp)
ffffffffc0204be2:	892a                	mv	s2,a0
ffffffffc0204be4:	8ab2                	mv	s5,a2
ffffffffc0204be6:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204be8:	862e                	mv	a2,a1
ffffffffc0204bea:	4681                	li	a3,0
ffffffffc0204bec:	85aa                	mv	a1,a0
ffffffffc0204bee:	854e                	mv	a0,s3
{
ffffffffc0204bf0:	ed06                	sd	ra,152(sp)
ffffffffc0204bf2:	e922                	sd	s0,144(sp)
ffffffffc0204bf4:	f8d2                	sd	s4,112(sp)
ffffffffc0204bf6:	f0da                	sd	s6,96(sp)
ffffffffc0204bf8:	e8e2                	sd	s8,80(sp)
ffffffffc0204bfa:	e4e6                	sd	s9,72(sp)
ffffffffc0204bfc:	e0ea                	sd	s10,64(sp)
ffffffffc0204bfe:	fc6e                	sd	s11,56(sp)
ffffffffc0204c00:	e856                	sd	s5,16(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204c02:	c76ff0ef          	jal	ra,ffffffffc0204078 <user_mem_check>
ffffffffc0204c06:	3e050f63          	beqz	a0,ffffffffc0205004 <do_execve+0x43e>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0204c0a:	4641                	li	a2,16
ffffffffc0204c0c:	4581                	li	a1,0
ffffffffc0204c0e:	1008                	addi	a0,sp,32
ffffffffc0204c10:	651000ef          	jal	ra,ffffffffc0205a60 <memset>
    memcpy(local_name, name, len);
ffffffffc0204c14:	47bd                	li	a5,15
ffffffffc0204c16:	8626                	mv	a2,s1
ffffffffc0204c18:	0697ed63          	bltu	a5,s1,ffffffffc0204c92 <do_execve+0xcc>
ffffffffc0204c1c:	85ca                	mv	a1,s2
ffffffffc0204c1e:	1008                	addi	a0,sp,32
ffffffffc0204c20:	653000ef          	jal	ra,ffffffffc0205a72 <memcpy>
    if (mm != NULL)
ffffffffc0204c24:	06098e63          	beqz	s3,ffffffffc0204ca0 <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc0204c28:	00002517          	auipc	a0,0x2
ffffffffc0204c2c:	59050513          	addi	a0,a0,1424 # ffffffffc02071b8 <default_pmm_manager+0x848>
ffffffffc0204c30:	d9cfb0ef          	jal	ra,ffffffffc02001cc <cputs>
ffffffffc0204c34:	000b3797          	auipc	a5,0xb3
ffffffffc0204c38:	b947b783          	ld	a5,-1132(a5) # ffffffffc02b77c8 <boot_pgdir_pa>
ffffffffc0204c3c:	577d                	li	a4,-1
ffffffffc0204c3e:	177e                	slli	a4,a4,0x3f
ffffffffc0204c40:	83b1                	srli	a5,a5,0xc
ffffffffc0204c42:	8fd9                	or	a5,a5,a4
ffffffffc0204c44:	18079073          	csrw	satp,a5
ffffffffc0204c48:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7b80>
ffffffffc0204c4c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204c50:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0)
ffffffffc0204c54:	28070f63          	beqz	a4,ffffffffc0204ef2 <do_execve+0x32c>
        current->mm = NULL;
ffffffffc0204c58:	000bb783          	ld	a5,0(s7)
ffffffffc0204c5c:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc0204c60:	da3fe0ef          	jal	ra,ffffffffc0203a02 <mm_create>
ffffffffc0204c64:	84aa                	mv	s1,a0
ffffffffc0204c66:	c135                	beqz	a0,ffffffffc0204cca <do_execve+0x104>
    if (setup_pgdir(mm) != 0)
ffffffffc0204c68:	e20ff0ef          	jal	ra,ffffffffc0204288 <setup_pgdir>
ffffffffc0204c6c:	e931                	bnez	a0,ffffffffc0204cc0 <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204c6e:	67c2                	ld	a5,16(sp)
ffffffffc0204c70:	4398                	lw	a4,0(a5)
ffffffffc0204c72:	464c47b7          	lui	a5,0x464c4
ffffffffc0204c76:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_cowtest_out_size+0x464b74df>
ffffffffc0204c7a:	04f70a63          	beq	a4,a5,ffffffffc0204cce <do_execve+0x108>
    put_pgdir(mm);
ffffffffc0204c7e:	8526                	mv	a0,s1
ffffffffc0204c80:	d92ff0ef          	jal	ra,ffffffffc0204212 <put_pgdir>
    mm_destroy(mm);
ffffffffc0204c84:	8526                	mv	a0,s1
ffffffffc0204c86:	ebdfe0ef          	jal	ra,ffffffffc0203b42 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0204c8a:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc0204c8c:	8552                	mv	a0,s4
ffffffffc0204c8e:	af9ff0ef          	jal	ra,ffffffffc0204786 <do_exit>
    memcpy(local_name, name, len);
ffffffffc0204c92:	463d                	li	a2,15
ffffffffc0204c94:	85ca                	mv	a1,s2
ffffffffc0204c96:	1008                	addi	a0,sp,32
ffffffffc0204c98:	5db000ef          	jal	ra,ffffffffc0205a72 <memcpy>
    if (mm != NULL)
ffffffffc0204c9c:	f80996e3          	bnez	s3,ffffffffc0204c28 <do_execve+0x62>
    if (current->mm != NULL)
ffffffffc0204ca0:	000bb783          	ld	a5,0(s7)
ffffffffc0204ca4:	779c                	ld	a5,40(a5)
ffffffffc0204ca6:	dfcd                	beqz	a5,ffffffffc0204c60 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0204ca8:	00003617          	auipc	a2,0x3
ffffffffc0204cac:	96060613          	addi	a2,a2,-1696 # ffffffffc0207608 <default_pmm_manager+0xc98>
ffffffffc0204cb0:	24e00593          	li	a1,590
ffffffffc0204cb4:	00002517          	auipc	a0,0x2
ffffffffc0204cb8:	73c50513          	addi	a0,a0,1852 # ffffffffc02073f0 <default_pmm_manager+0xa80>
ffffffffc0204cbc:	fd2fb0ef          	jal	ra,ffffffffc020048e <__panic>
    mm_destroy(mm);
ffffffffc0204cc0:	8526                	mv	a0,s1
ffffffffc0204cc2:	e81fe0ef          	jal	ra,ffffffffc0203b42 <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0204cc6:	5a71                	li	s4,-4
ffffffffc0204cc8:	b7d1                	j	ffffffffc0204c8c <do_execve+0xc6>
ffffffffc0204cca:	5a71                	li	s4,-4
ffffffffc0204ccc:	b7c1                	j	ffffffffc0204c8c <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204cce:	66c2                	ld	a3,16(sp)
ffffffffc0204cd0:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204cd4:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204cd8:	00371793          	slli	a5,a4,0x3
ffffffffc0204cdc:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204cde:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204ce0:	078e                	slli	a5,a5,0x3
ffffffffc0204ce2:	97ce                	add	a5,a5,s3
ffffffffc0204ce4:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph++)
ffffffffc0204ce6:	02f9fb63          	bgeu	s3,a5,ffffffffc0204d1c <do_execve+0x156>
    return KADDR(page2pa(page));
ffffffffc0204cea:	57fd                	li	a5,-1
ffffffffc0204cec:	83b1                	srli	a5,a5,0xc
    return page - pages + nbase;
ffffffffc0204cee:	000b3d17          	auipc	s10,0xb3
ffffffffc0204cf2:	af2d0d13          	addi	s10,s10,-1294 # ffffffffc02b77e0 <pages>
ffffffffc0204cf6:	00003c97          	auipc	s9,0x3
ffffffffc0204cfa:	02ac8c93          	addi	s9,s9,42 # ffffffffc0207d20 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204cfe:	e43e                	sd	a5,8(sp)
ffffffffc0204d00:	000b3c17          	auipc	s8,0xb3
ffffffffc0204d04:	ad8c0c13          	addi	s8,s8,-1320 # ffffffffc02b77d8 <npage>
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc0204d08:	0009a703          	lw	a4,0(s3)
ffffffffc0204d0c:	4785                	li	a5,1
ffffffffc0204d0e:	10f70163          	beq	a4,a5,ffffffffc0204e10 <do_execve+0x24a>
    for (; ph < ph_end; ph++)
ffffffffc0204d12:	67e2                	ld	a5,24(sp)
ffffffffc0204d14:	03898993          	addi	s3,s3,56
ffffffffc0204d18:	fef9e8e3          	bltu	s3,a5,ffffffffc0204d08 <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc0204d1c:	4701                	li	a4,0
ffffffffc0204d1e:	46ad                	li	a3,11
ffffffffc0204d20:	00100637          	lui	a2,0x100
ffffffffc0204d24:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0204d28:	8526                	mv	a0,s1
ffffffffc0204d2a:	e6bfe0ef          	jal	ra,ffffffffc0203b94 <mm_map>
ffffffffc0204d2e:	8a2a                	mv	s4,a0
ffffffffc0204d30:	1a051763          	bnez	a0,ffffffffc0204ede <do_execve+0x318>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204d34:	6c88                	ld	a0,24(s1)
ffffffffc0204d36:	467d                	li	a2,31
ffffffffc0204d38:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0204d3c:	be1fe0ef          	jal	ra,ffffffffc020391c <pgdir_alloc_page>
ffffffffc0204d40:	36050063          	beqz	a0,ffffffffc02050a0 <do_execve+0x4da>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204d44:	6c88                	ld	a0,24(s1)
ffffffffc0204d46:	467d                	li	a2,31
ffffffffc0204d48:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0204d4c:	bd1fe0ef          	jal	ra,ffffffffc020391c <pgdir_alloc_page>
ffffffffc0204d50:	32050863          	beqz	a0,ffffffffc0205080 <do_execve+0x4ba>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204d54:	6c88                	ld	a0,24(s1)
ffffffffc0204d56:	467d                	li	a2,31
ffffffffc0204d58:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0204d5c:	bc1fe0ef          	jal	ra,ffffffffc020391c <pgdir_alloc_page>
ffffffffc0204d60:	30050063          	beqz	a0,ffffffffc0205060 <do_execve+0x49a>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204d64:	6c88                	ld	a0,24(s1)
ffffffffc0204d66:	467d                	li	a2,31
ffffffffc0204d68:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0204d6c:	bb1fe0ef          	jal	ra,ffffffffc020391c <pgdir_alloc_page>
ffffffffc0204d70:	2c050863          	beqz	a0,ffffffffc0205040 <do_execve+0x47a>
    mm->mm_count += 1;
ffffffffc0204d74:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0204d76:	000bb603          	ld	a2,0(s7)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204d7a:	6c94                	ld	a3,24(s1)
ffffffffc0204d7c:	2785                	addiw	a5,a5,1
ffffffffc0204d7e:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0204d80:	f604                	sd	s1,40(a2)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204d82:	c02007b7          	lui	a5,0xc0200
ffffffffc0204d86:	2af6e163          	bltu	a3,a5,ffffffffc0205028 <do_execve+0x462>
ffffffffc0204d8a:	000b3797          	auipc	a5,0xb3
ffffffffc0204d8e:	a667b783          	ld	a5,-1434(a5) # ffffffffc02b77f0 <va_pa_offset>
ffffffffc0204d92:	8e9d                	sub	a3,a3,a5
ffffffffc0204d94:	577d                	li	a4,-1
ffffffffc0204d96:	00c6d793          	srli	a5,a3,0xc
ffffffffc0204d9a:	177e                	slli	a4,a4,0x3f
ffffffffc0204d9c:	f654                	sd	a3,168(a2)
ffffffffc0204d9e:	8fd9                	or	a5,a5,a4
ffffffffc0204da0:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0204da4:	0a063903          	ld	s2,160(a2) # 1000a0 <_binary_obj___user_cowtest_out_size+0xf3000>
    uintptr_t sstatus = read_csr(sstatus);
ffffffffc0204da8:	10002473          	csrr	s0,sstatus
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204dac:	12000613          	li	a2,288
ffffffffc0204db0:	4581                	li	a1,0
ffffffffc0204db2:	854a                	mv	a0,s2
ffffffffc0204db4:	4ad000ef          	jal	ra,ffffffffc0205a60 <memset>
    tf->epc = elf->e_entry;
ffffffffc0204db8:	67c2                	ld	a5,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204dba:	000bb483          	ld	s1,0(s7)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204dbe:	edf47413          	andi	s0,s0,-289
    tf->epc = elf->e_entry;
ffffffffc0204dc2:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc0204dc4:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204dc6:	0b448493          	addi	s1,s1,180
    tf->gpr.sp = USTACKTOP;
ffffffffc0204dca:	07fe                	slli	a5,a5,0x1f
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204dcc:	02046413          	ori	s0,s0,32
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204dd0:	4641                	li	a2,16
ffffffffc0204dd2:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP;
ffffffffc0204dd4:	00f93823          	sd	a5,16(s2) # ffffffff80000010 <_binary_obj___user_cowtest_out_size+0xffffffff7fff2f70>
    tf->epc = elf->e_entry;
ffffffffc0204dd8:	10e93423          	sd	a4,264(s2)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204ddc:	10893023          	sd	s0,256(s2)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204de0:	8526                	mv	a0,s1
ffffffffc0204de2:	47f000ef          	jal	ra,ffffffffc0205a60 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204de6:	463d                	li	a2,15
ffffffffc0204de8:	100c                	addi	a1,sp,32
ffffffffc0204dea:	8526                	mv	a0,s1
ffffffffc0204dec:	487000ef          	jal	ra,ffffffffc0205a72 <memcpy>
}
ffffffffc0204df0:	60ea                	ld	ra,152(sp)
ffffffffc0204df2:	644a                	ld	s0,144(sp)
ffffffffc0204df4:	64aa                	ld	s1,136(sp)
ffffffffc0204df6:	690a                	ld	s2,128(sp)
ffffffffc0204df8:	79e6                	ld	s3,120(sp)
ffffffffc0204dfa:	7aa6                	ld	s5,104(sp)
ffffffffc0204dfc:	7b06                	ld	s6,96(sp)
ffffffffc0204dfe:	6be6                	ld	s7,88(sp)
ffffffffc0204e00:	6c46                	ld	s8,80(sp)
ffffffffc0204e02:	6ca6                	ld	s9,72(sp)
ffffffffc0204e04:	6d06                	ld	s10,64(sp)
ffffffffc0204e06:	7de2                	ld	s11,56(sp)
ffffffffc0204e08:	8552                	mv	a0,s4
ffffffffc0204e0a:	7a46                	ld	s4,112(sp)
ffffffffc0204e0c:	610d                	addi	sp,sp,160
ffffffffc0204e0e:	8082                	ret
        if (ph->p_filesz > ph->p_memsz)
ffffffffc0204e10:	0289b603          	ld	a2,40(s3)
ffffffffc0204e14:	0209b783          	ld	a5,32(s3)
ffffffffc0204e18:	1ef66a63          	bltu	a2,a5,ffffffffc020500c <do_execve+0x446>
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204e1c:	0049a783          	lw	a5,4(s3)
ffffffffc0204e20:	0017f693          	andi	a3,a5,1
ffffffffc0204e24:	c291                	beqz	a3,ffffffffc0204e28 <do_execve+0x262>
            vm_flags |= VM_EXEC;
ffffffffc0204e26:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204e28:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204e2c:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204e2e:	ef61                	bnez	a4,ffffffffc0204f06 <do_execve+0x340>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0204e30:	4b45                	li	s6,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204e32:	c781                	beqz	a5,ffffffffc0204e3a <do_execve+0x274>
            vm_flags |= VM_READ;
ffffffffc0204e34:	0016e693          	ori	a3,a3,1
            perm |= PTE_R;
ffffffffc0204e38:	4b4d                	li	s6,19
        if (vm_flags & VM_WRITE)
ffffffffc0204e3a:	0026f793          	andi	a5,a3,2
ffffffffc0204e3e:	e7f9                	bnez	a5,ffffffffc0204f0c <do_execve+0x346>
        if (vm_flags & VM_EXEC)
ffffffffc0204e40:	0046f793          	andi	a5,a3,4
ffffffffc0204e44:	c399                	beqz	a5,ffffffffc0204e4a <do_execve+0x284>
            perm |= PTE_X;
ffffffffc0204e46:	008b6b13          	ori	s6,s6,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc0204e4a:	0109b583          	ld	a1,16(s3)
ffffffffc0204e4e:	4701                	li	a4,0
ffffffffc0204e50:	8526                	mv	a0,s1
ffffffffc0204e52:	d43fe0ef          	jal	ra,ffffffffc0203b94 <mm_map>
ffffffffc0204e56:	8a2a                	mv	s4,a0
ffffffffc0204e58:	e159                	bnez	a0,ffffffffc0204ede <do_execve+0x318>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204e5a:	0109bd83          	ld	s11,16(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204e5e:	67c2                	ld	a5,16(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0204e60:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204e64:	0089b903          	ld	s2,8(s3)
        end = ph->p_va + ph->p_filesz;
ffffffffc0204e68:	9a6e                	add	s4,s4,s11
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204e6a:	993e                	add	s2,s2,a5
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204e6c:	77fd                	lui	a5,0xfffff
ffffffffc0204e6e:	00fdfab3          	and	s5,s11,a5
        while (start < end)
ffffffffc0204e72:	054dee63          	bltu	s11,s4,ffffffffc0204ece <do_execve+0x308>
ffffffffc0204e76:	aa49                	j	ffffffffc0205008 <do_execve+0x442>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204e78:	6785                	lui	a5,0x1
ffffffffc0204e7a:	415d8533          	sub	a0,s11,s5
ffffffffc0204e7e:	9abe                	add	s5,s5,a5
ffffffffc0204e80:	41ba8633          	sub	a2,s5,s11
            if (end < la)
ffffffffc0204e84:	015a7463          	bgeu	s4,s5,ffffffffc0204e8c <do_execve+0x2c6>
                size -= la - end;
ffffffffc0204e88:	41ba0633          	sub	a2,s4,s11
    return page - pages + nbase;
ffffffffc0204e8c:	000d3683          	ld	a3,0(s10)
ffffffffc0204e90:	000cb803          	ld	a6,0(s9)
    return KADDR(page2pa(page));
ffffffffc0204e94:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0204e96:	40d406b3          	sub	a3,s0,a3
ffffffffc0204e9a:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204e9c:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204ea0:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0204ea2:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ea6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204ea8:	16b87463          	bgeu	a6,a1,ffffffffc0205010 <do_execve+0x44a>
ffffffffc0204eac:	000b3797          	auipc	a5,0xb3
ffffffffc0204eb0:	94478793          	addi	a5,a5,-1724 # ffffffffc02b77f0 <va_pa_offset>
ffffffffc0204eb4:	0007b803          	ld	a6,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204eb8:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0204eba:	9db2                	add	s11,s11,a2
ffffffffc0204ebc:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204ebe:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0204ec0:	e032                	sd	a2,0(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204ec2:	3b1000ef          	jal	ra,ffffffffc0205a72 <memcpy>
            start += size, from += size;
ffffffffc0204ec6:	6602                	ld	a2,0(sp)
ffffffffc0204ec8:	9932                	add	s2,s2,a2
        while (start < end)
ffffffffc0204eca:	054df363          	bgeu	s11,s4,ffffffffc0204f10 <do_execve+0x34a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204ece:	6c88                	ld	a0,24(s1)
ffffffffc0204ed0:	865a                	mv	a2,s6
ffffffffc0204ed2:	85d6                	mv	a1,s5
ffffffffc0204ed4:	a49fe0ef          	jal	ra,ffffffffc020391c <pgdir_alloc_page>
ffffffffc0204ed8:	842a                	mv	s0,a0
ffffffffc0204eda:	fd59                	bnez	a0,ffffffffc0204e78 <do_execve+0x2b2>
        ret = -E_NO_MEM;
ffffffffc0204edc:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0204ede:	8526                	mv	a0,s1
ffffffffc0204ee0:	dfffe0ef          	jal	ra,ffffffffc0203cde <exit_mmap>
    put_pgdir(mm);
ffffffffc0204ee4:	8526                	mv	a0,s1
ffffffffc0204ee6:	b2cff0ef          	jal	ra,ffffffffc0204212 <put_pgdir>
    mm_destroy(mm);
ffffffffc0204eea:	8526                	mv	a0,s1
ffffffffc0204eec:	c57fe0ef          	jal	ra,ffffffffc0203b42 <mm_destroy>
    return ret;
ffffffffc0204ef0:	bb71                	j	ffffffffc0204c8c <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0204ef2:	854e                	mv	a0,s3
ffffffffc0204ef4:	debfe0ef          	jal	ra,ffffffffc0203cde <exit_mmap>
            put_pgdir(mm);
ffffffffc0204ef8:	854e                	mv	a0,s3
ffffffffc0204efa:	b18ff0ef          	jal	ra,ffffffffc0204212 <put_pgdir>
            mm_destroy(mm);
ffffffffc0204efe:	854e                	mv	a0,s3
ffffffffc0204f00:	c43fe0ef          	jal	ra,ffffffffc0203b42 <mm_destroy>
ffffffffc0204f04:	bb91                	j	ffffffffc0204c58 <do_execve+0x92>
            vm_flags |= VM_WRITE;
ffffffffc0204f06:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204f0a:	f78d                	bnez	a5,ffffffffc0204e34 <do_execve+0x26e>
            perm |= (PTE_W | PTE_R);
ffffffffc0204f0c:	4b5d                	li	s6,23
ffffffffc0204f0e:	bf0d                	j	ffffffffc0204e40 <do_execve+0x27a>
        end = ph->p_va + ph->p_memsz;
ffffffffc0204f10:	0109b903          	ld	s2,16(s3)
ffffffffc0204f14:	0289b683          	ld	a3,40(s3)
ffffffffc0204f18:	9936                	add	s2,s2,a3
        if (start < la)
ffffffffc0204f1a:	075dff63          	bgeu	s11,s5,ffffffffc0204f98 <do_execve+0x3d2>
            if (start == end)
ffffffffc0204f1e:	dfb90ae3          	beq	s2,s11,ffffffffc0204d12 <do_execve+0x14c>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204f22:	6505                	lui	a0,0x1
ffffffffc0204f24:	956e                	add	a0,a0,s11
ffffffffc0204f26:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0204f2a:	41b90a33          	sub	s4,s2,s11
            if (end < la)
ffffffffc0204f2e:	0d597863          	bgeu	s2,s5,ffffffffc0204ffe <do_execve+0x438>
    return page - pages + nbase;
ffffffffc0204f32:	000d3683          	ld	a3,0(s10)
ffffffffc0204f36:	000cb583          	ld	a1,0(s9)
    return KADDR(page2pa(page));
ffffffffc0204f3a:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0204f3c:	40d406b3          	sub	a3,s0,a3
ffffffffc0204f40:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204f42:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0204f46:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0204f48:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204f4c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204f4e:	0cc5f163          	bgeu	a1,a2,ffffffffc0205010 <do_execve+0x44a>
ffffffffc0204f52:	000b3617          	auipc	a2,0xb3
ffffffffc0204f56:	89e63603          	ld	a2,-1890(a2) # ffffffffc02b77f0 <va_pa_offset>
ffffffffc0204f5a:	96b2                	add	a3,a3,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0204f5c:	4581                	li	a1,0
ffffffffc0204f5e:	8652                	mv	a2,s4
ffffffffc0204f60:	9536                	add	a0,a0,a3
ffffffffc0204f62:	2ff000ef          	jal	ra,ffffffffc0205a60 <memset>
            start += size;
ffffffffc0204f66:	01ba0733          	add	a4,s4,s11
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0204f6a:	03597463          	bgeu	s2,s5,ffffffffc0204f92 <do_execve+0x3cc>
ffffffffc0204f6e:	dae902e3          	beq	s2,a4,ffffffffc0204d12 <do_execve+0x14c>
ffffffffc0204f72:	00002697          	auipc	a3,0x2
ffffffffc0204f76:	6be68693          	addi	a3,a3,1726 # ffffffffc0207630 <default_pmm_manager+0xcc0>
ffffffffc0204f7a:	00001617          	auipc	a2,0x1
ffffffffc0204f7e:	64660613          	addi	a2,a2,1606 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0204f82:	2b700593          	li	a1,695
ffffffffc0204f86:	00002517          	auipc	a0,0x2
ffffffffc0204f8a:	46a50513          	addi	a0,a0,1130 # ffffffffc02073f0 <default_pmm_manager+0xa80>
ffffffffc0204f8e:	d00fb0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc0204f92:	ff5710e3          	bne	a4,s5,ffffffffc0204f72 <do_execve+0x3ac>
ffffffffc0204f96:	8dd6                	mv	s11,s5
ffffffffc0204f98:	000b3a17          	auipc	s4,0xb3
ffffffffc0204f9c:	858a0a13          	addi	s4,s4,-1960 # ffffffffc02b77f0 <va_pa_offset>
        while (start < end)
ffffffffc0204fa0:	052de763          	bltu	s11,s2,ffffffffc0204fee <do_execve+0x428>
ffffffffc0204fa4:	b3bd                	j	ffffffffc0204d12 <do_execve+0x14c>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204fa6:	6785                	lui	a5,0x1
ffffffffc0204fa8:	415d8533          	sub	a0,s11,s5
ffffffffc0204fac:	9abe                	add	s5,s5,a5
ffffffffc0204fae:	41ba8633          	sub	a2,s5,s11
            if (end < la)
ffffffffc0204fb2:	01597463          	bgeu	s2,s5,ffffffffc0204fba <do_execve+0x3f4>
                size -= la - end;
ffffffffc0204fb6:	41b90633          	sub	a2,s2,s11
    return page - pages + nbase;
ffffffffc0204fba:	000d3683          	ld	a3,0(s10)
ffffffffc0204fbe:	000cb803          	ld	a6,0(s9)
    return KADDR(page2pa(page));
ffffffffc0204fc2:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0204fc4:	40d406b3          	sub	a3,s0,a3
ffffffffc0204fc8:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204fca:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204fce:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0204fd0:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204fd4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204fd6:	02b87d63          	bgeu	a6,a1,ffffffffc0205010 <do_execve+0x44a>
ffffffffc0204fda:	000a3803          	ld	a6,0(s4)
            start += size;
ffffffffc0204fde:	9db2                	add	s11,s11,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0204fe0:	4581                	li	a1,0
ffffffffc0204fe2:	96c2                	add	a3,a3,a6
ffffffffc0204fe4:	9536                	add	a0,a0,a3
ffffffffc0204fe6:	27b000ef          	jal	ra,ffffffffc0205a60 <memset>
        while (start < end)
ffffffffc0204fea:	d32df4e3          	bgeu	s11,s2,ffffffffc0204d12 <do_execve+0x14c>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204fee:	6c88                	ld	a0,24(s1)
ffffffffc0204ff0:	865a                	mv	a2,s6
ffffffffc0204ff2:	85d6                	mv	a1,s5
ffffffffc0204ff4:	929fe0ef          	jal	ra,ffffffffc020391c <pgdir_alloc_page>
ffffffffc0204ff8:	842a                	mv	s0,a0
ffffffffc0204ffa:	f555                	bnez	a0,ffffffffc0204fa6 <do_execve+0x3e0>
ffffffffc0204ffc:	b5c5                	j	ffffffffc0204edc <do_execve+0x316>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204ffe:	41ba8a33          	sub	s4,s5,s11
ffffffffc0205002:	bf05                	j	ffffffffc0204f32 <do_execve+0x36c>
        return -E_INVAL;
ffffffffc0205004:	5a75                	li	s4,-3
ffffffffc0205006:	b3ed                	j	ffffffffc0204df0 <do_execve+0x22a>
        while (start < end)
ffffffffc0205008:	896e                	mv	s2,s11
ffffffffc020500a:	b729                	j	ffffffffc0204f14 <do_execve+0x34e>
            ret = -E_INVAL_ELF;
ffffffffc020500c:	5a61                	li	s4,-8
ffffffffc020500e:	bdc1                	j	ffffffffc0204ede <do_execve+0x318>
ffffffffc0205010:	00002617          	auipc	a2,0x2
ffffffffc0205014:	99860613          	addi	a2,a2,-1640 # ffffffffc02069a8 <default_pmm_manager+0x38>
ffffffffc0205018:	07700593          	li	a1,119
ffffffffc020501c:	00002517          	auipc	a0,0x2
ffffffffc0205020:	9b450513          	addi	a0,a0,-1612 # ffffffffc02069d0 <default_pmm_manager+0x60>
ffffffffc0205024:	c6afb0ef          	jal	ra,ffffffffc020048e <__panic>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0205028:	00002617          	auipc	a2,0x2
ffffffffc020502c:	a2860613          	addi	a2,a2,-1496 # ffffffffc0206a50 <default_pmm_manager+0xe0>
ffffffffc0205030:	2d600593          	li	a1,726
ffffffffc0205034:	00002517          	auipc	a0,0x2
ffffffffc0205038:	3bc50513          	addi	a0,a0,956 # ffffffffc02073f0 <default_pmm_manager+0xa80>
ffffffffc020503c:	c52fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205040:	00002697          	auipc	a3,0x2
ffffffffc0205044:	70868693          	addi	a3,a3,1800 # ffffffffc0207748 <default_pmm_manager+0xdd8>
ffffffffc0205048:	00001617          	auipc	a2,0x1
ffffffffc020504c:	57860613          	addi	a2,a2,1400 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0205050:	2d100593          	li	a1,721
ffffffffc0205054:	00002517          	auipc	a0,0x2
ffffffffc0205058:	39c50513          	addi	a0,a0,924 # ffffffffc02073f0 <default_pmm_manager+0xa80>
ffffffffc020505c:	c32fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205060:	00002697          	auipc	a3,0x2
ffffffffc0205064:	6a068693          	addi	a3,a3,1696 # ffffffffc0207700 <default_pmm_manager+0xd90>
ffffffffc0205068:	00001617          	auipc	a2,0x1
ffffffffc020506c:	55860613          	addi	a2,a2,1368 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0205070:	2d000593          	li	a1,720
ffffffffc0205074:	00002517          	auipc	a0,0x2
ffffffffc0205078:	37c50513          	addi	a0,a0,892 # ffffffffc02073f0 <default_pmm_manager+0xa80>
ffffffffc020507c:	c12fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205080:	00002697          	auipc	a3,0x2
ffffffffc0205084:	63868693          	addi	a3,a3,1592 # ffffffffc02076b8 <default_pmm_manager+0xd48>
ffffffffc0205088:	00001617          	auipc	a2,0x1
ffffffffc020508c:	53860613          	addi	a2,a2,1336 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0205090:	2cf00593          	li	a1,719
ffffffffc0205094:	00002517          	auipc	a0,0x2
ffffffffc0205098:	35c50513          	addi	a0,a0,860 # ffffffffc02073f0 <default_pmm_manager+0xa80>
ffffffffc020509c:	bf2fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc02050a0:	00002697          	auipc	a3,0x2
ffffffffc02050a4:	5d068693          	addi	a3,a3,1488 # ffffffffc0207670 <default_pmm_manager+0xd00>
ffffffffc02050a8:	00001617          	auipc	a2,0x1
ffffffffc02050ac:	51860613          	addi	a2,a2,1304 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02050b0:	2ce00593          	li	a1,718
ffffffffc02050b4:	00002517          	auipc	a0,0x2
ffffffffc02050b8:	33c50513          	addi	a0,a0,828 # ffffffffc02073f0 <default_pmm_manager+0xa80>
ffffffffc02050bc:	bd2fb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02050c0 <do_yield>:
    current->need_resched = 1;
ffffffffc02050c0:	000b2797          	auipc	a5,0xb2
ffffffffc02050c4:	7387b783          	ld	a5,1848(a5) # ffffffffc02b77f8 <current>
ffffffffc02050c8:	4705                	li	a4,1
ffffffffc02050ca:	ef98                	sd	a4,24(a5)
}
ffffffffc02050cc:	4501                	li	a0,0
ffffffffc02050ce:	8082                	ret

ffffffffc02050d0 <do_wait>:
{
ffffffffc02050d0:	1101                	addi	sp,sp,-32
ffffffffc02050d2:	e822                	sd	s0,16(sp)
ffffffffc02050d4:	e426                	sd	s1,8(sp)
ffffffffc02050d6:	ec06                	sd	ra,24(sp)
ffffffffc02050d8:	842e                	mv	s0,a1
ffffffffc02050da:	84aa                	mv	s1,a0
    if (code_store != NULL)
ffffffffc02050dc:	c999                	beqz	a1,ffffffffc02050f2 <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc02050de:	000b2797          	auipc	a5,0xb2
ffffffffc02050e2:	71a7b783          	ld	a5,1818(a5) # ffffffffc02b77f8 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc02050e6:	7788                	ld	a0,40(a5)
ffffffffc02050e8:	4685                	li	a3,1
ffffffffc02050ea:	4611                	li	a2,4
ffffffffc02050ec:	f8dfe0ef          	jal	ra,ffffffffc0204078 <user_mem_check>
ffffffffc02050f0:	c909                	beqz	a0,ffffffffc0205102 <do_wait+0x32>
ffffffffc02050f2:	85a2                	mv	a1,s0
}
ffffffffc02050f4:	6442                	ld	s0,16(sp)
ffffffffc02050f6:	60e2                	ld	ra,24(sp)
ffffffffc02050f8:	8526                	mv	a0,s1
ffffffffc02050fa:	64a2                	ld	s1,8(sp)
ffffffffc02050fc:	6105                	addi	sp,sp,32
ffffffffc02050fe:	fd2ff06f          	j	ffffffffc02048d0 <do_wait.part.0>
ffffffffc0205102:	60e2                	ld	ra,24(sp)
ffffffffc0205104:	6442                	ld	s0,16(sp)
ffffffffc0205106:	64a2                	ld	s1,8(sp)
ffffffffc0205108:	5575                	li	a0,-3
ffffffffc020510a:	6105                	addi	sp,sp,32
ffffffffc020510c:	8082                	ret

ffffffffc020510e <do_kill>:
{
ffffffffc020510e:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID)
ffffffffc0205110:	6789                	lui	a5,0x2
{
ffffffffc0205112:	e406                	sd	ra,8(sp)
ffffffffc0205114:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID)
ffffffffc0205116:	fff5071b          	addiw	a4,a0,-1
ffffffffc020511a:	17f9                	addi	a5,a5,-2
ffffffffc020511c:	02e7e963          	bltu	a5,a4,ffffffffc020514e <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205120:	842a                	mv	s0,a0
ffffffffc0205122:	45a9                	li	a1,10
ffffffffc0205124:	2501                	sext.w	a0,a0
ffffffffc0205126:	494000ef          	jal	ra,ffffffffc02055ba <hash32>
ffffffffc020512a:	02051793          	slli	a5,a0,0x20
ffffffffc020512e:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205132:	000ae797          	auipc	a5,0xae
ffffffffc0205136:	64e78793          	addi	a5,a5,1614 # ffffffffc02b3780 <hash_list>
ffffffffc020513a:	953e                	add	a0,a0,a5
ffffffffc020513c:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list)
ffffffffc020513e:	a029                	j	ffffffffc0205148 <do_kill+0x3a>
            if (proc->pid == pid)
ffffffffc0205140:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205144:	00870b63          	beq	a4,s0,ffffffffc020515a <do_kill+0x4c>
ffffffffc0205148:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc020514a:	fef51be3          	bne	a0,a5,ffffffffc0205140 <do_kill+0x32>
    return -E_INVAL;
ffffffffc020514e:	5475                	li	s0,-3
}
ffffffffc0205150:	60a2                	ld	ra,8(sp)
ffffffffc0205152:	8522                	mv	a0,s0
ffffffffc0205154:	6402                	ld	s0,0(sp)
ffffffffc0205156:	0141                	addi	sp,sp,16
ffffffffc0205158:	8082                	ret
        if (!(proc->flags & PF_EXITING))
ffffffffc020515a:	fd87a703          	lw	a4,-40(a5)
ffffffffc020515e:	00177693          	andi	a3,a4,1
ffffffffc0205162:	e295                	bnez	a3,ffffffffc0205186 <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0205164:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0205166:	00176713          	ori	a4,a4,1
ffffffffc020516a:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc020516e:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0205170:	fe06d0e3          	bgez	a3,ffffffffc0205150 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0205174:	f2878513          	addi	a0,a5,-216
ffffffffc0205178:	22e000ef          	jal	ra,ffffffffc02053a6 <wakeup_proc>
}
ffffffffc020517c:	60a2                	ld	ra,8(sp)
ffffffffc020517e:	8522                	mv	a0,s0
ffffffffc0205180:	6402                	ld	s0,0(sp)
ffffffffc0205182:	0141                	addi	sp,sp,16
ffffffffc0205184:	8082                	ret
        return -E_KILLED;
ffffffffc0205186:	545d                	li	s0,-9
ffffffffc0205188:	b7e1                	j	ffffffffc0205150 <do_kill+0x42>

ffffffffc020518a <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc020518a:	1101                	addi	sp,sp,-32
ffffffffc020518c:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc020518e:	000b2797          	auipc	a5,0xb2
ffffffffc0205192:	5f278793          	addi	a5,a5,1522 # ffffffffc02b7780 <proc_list>
ffffffffc0205196:	ec06                	sd	ra,24(sp)
ffffffffc0205198:	e822                	sd	s0,16(sp)
ffffffffc020519a:	e04a                	sd	s2,0(sp)
ffffffffc020519c:	000ae497          	auipc	s1,0xae
ffffffffc02051a0:	5e448493          	addi	s1,s1,1508 # ffffffffc02b3780 <hash_list>
ffffffffc02051a4:	e79c                	sd	a5,8(a5)
ffffffffc02051a6:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc02051a8:	000b2717          	auipc	a4,0xb2
ffffffffc02051ac:	5d870713          	addi	a4,a4,1496 # ffffffffc02b7780 <proc_list>
ffffffffc02051b0:	87a6                	mv	a5,s1
ffffffffc02051b2:	e79c                	sd	a5,8(a5)
ffffffffc02051b4:	e39c                	sd	a5,0(a5)
ffffffffc02051b6:	07c1                	addi	a5,a5,16
ffffffffc02051b8:	fef71de3          	bne	a4,a5,ffffffffc02051b2 <proc_init+0x28>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc02051bc:	f59fe0ef          	jal	ra,ffffffffc0204114 <alloc_proc>
ffffffffc02051c0:	000b2917          	auipc	s2,0xb2
ffffffffc02051c4:	64090913          	addi	s2,s2,1600 # ffffffffc02b7800 <idleproc>
ffffffffc02051c8:	00a93023          	sd	a0,0(s2)
ffffffffc02051cc:	0e050f63          	beqz	a0,ffffffffc02052ca <proc_init+0x140>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc02051d0:	4789                	li	a5,2
ffffffffc02051d2:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02051d4:	00003797          	auipc	a5,0x3
ffffffffc02051d8:	e2c78793          	addi	a5,a5,-468 # ffffffffc0208000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02051dc:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02051e0:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc02051e2:	4785                	li	a5,1
ffffffffc02051e4:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02051e6:	4641                	li	a2,16
ffffffffc02051e8:	4581                	li	a1,0
ffffffffc02051ea:	8522                	mv	a0,s0
ffffffffc02051ec:	075000ef          	jal	ra,ffffffffc0205a60 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02051f0:	463d                	li	a2,15
ffffffffc02051f2:	00002597          	auipc	a1,0x2
ffffffffc02051f6:	5b658593          	addi	a1,a1,1462 # ffffffffc02077a8 <default_pmm_manager+0xe38>
ffffffffc02051fa:	8522                	mv	a0,s0
ffffffffc02051fc:	077000ef          	jal	ra,ffffffffc0205a72 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process++;
ffffffffc0205200:	000b2717          	auipc	a4,0xb2
ffffffffc0205204:	61070713          	addi	a4,a4,1552 # ffffffffc02b7810 <nr_process>
ffffffffc0205208:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc020520a:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc020520e:	4601                	li	a2,0
    nr_process++;
ffffffffc0205210:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205212:	4581                	li	a1,0
ffffffffc0205214:	00000517          	auipc	a0,0x0
ffffffffc0205218:	88e50513          	addi	a0,a0,-1906 # ffffffffc0204aa2 <init_main>
    nr_process++;
ffffffffc020521c:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc020521e:	000b2797          	auipc	a5,0xb2
ffffffffc0205222:	5cd7bd23          	sd	a3,1498(a5) # ffffffffc02b77f8 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205226:	d10ff0ef          	jal	ra,ffffffffc0204736 <kernel_thread>
ffffffffc020522a:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc020522c:	08a05363          	blez	a0,ffffffffc02052b2 <proc_init+0x128>
    if (0 < pid && pid < MAX_PID)
ffffffffc0205230:	6789                	lui	a5,0x2
ffffffffc0205232:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205236:	17f9                	addi	a5,a5,-2
ffffffffc0205238:	2501                	sext.w	a0,a0
ffffffffc020523a:	02e7e363          	bltu	a5,a4,ffffffffc0205260 <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020523e:	45a9                	li	a1,10
ffffffffc0205240:	37a000ef          	jal	ra,ffffffffc02055ba <hash32>
ffffffffc0205244:	02051793          	slli	a5,a0,0x20
ffffffffc0205248:	01c7d693          	srli	a3,a5,0x1c
ffffffffc020524c:	96a6                	add	a3,a3,s1
ffffffffc020524e:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0205250:	a029                	j	ffffffffc020525a <proc_init+0xd0>
            if (proc->pid == pid)
ffffffffc0205252:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c84>
ffffffffc0205256:	04870b63          	beq	a4,s0,ffffffffc02052ac <proc_init+0x122>
    return listelm->next;
ffffffffc020525a:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc020525c:	fef69be3          	bne	a3,a5,ffffffffc0205252 <proc_init+0xc8>
    return NULL;
ffffffffc0205260:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205262:	0b478493          	addi	s1,a5,180
ffffffffc0205266:	4641                	li	a2,16
ffffffffc0205268:	4581                	li	a1,0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc020526a:	000b2417          	auipc	s0,0xb2
ffffffffc020526e:	59e40413          	addi	s0,s0,1438 # ffffffffc02b7808 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205272:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0205274:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205276:	7ea000ef          	jal	ra,ffffffffc0205a60 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020527a:	463d                	li	a2,15
ffffffffc020527c:	00002597          	auipc	a1,0x2
ffffffffc0205280:	55458593          	addi	a1,a1,1364 # ffffffffc02077d0 <default_pmm_manager+0xe60>
ffffffffc0205284:	8526                	mv	a0,s1
ffffffffc0205286:	7ec000ef          	jal	ra,ffffffffc0205a72 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020528a:	00093783          	ld	a5,0(s2)
ffffffffc020528e:	cbb5                	beqz	a5,ffffffffc0205302 <proc_init+0x178>
ffffffffc0205290:	43dc                	lw	a5,4(a5)
ffffffffc0205292:	eba5                	bnez	a5,ffffffffc0205302 <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205294:	601c                	ld	a5,0(s0)
ffffffffc0205296:	c7b1                	beqz	a5,ffffffffc02052e2 <proc_init+0x158>
ffffffffc0205298:	43d8                	lw	a4,4(a5)
ffffffffc020529a:	4785                	li	a5,1
ffffffffc020529c:	04f71363          	bne	a4,a5,ffffffffc02052e2 <proc_init+0x158>
}
ffffffffc02052a0:	60e2                	ld	ra,24(sp)
ffffffffc02052a2:	6442                	ld	s0,16(sp)
ffffffffc02052a4:	64a2                	ld	s1,8(sp)
ffffffffc02052a6:	6902                	ld	s2,0(sp)
ffffffffc02052a8:	6105                	addi	sp,sp,32
ffffffffc02052aa:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02052ac:	f2878793          	addi	a5,a5,-216
ffffffffc02052b0:	bf4d                	j	ffffffffc0205262 <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc02052b2:	00002617          	auipc	a2,0x2
ffffffffc02052b6:	4fe60613          	addi	a2,a2,1278 # ffffffffc02077b0 <default_pmm_manager+0xe40>
ffffffffc02052ba:	3f700593          	li	a1,1015
ffffffffc02052be:	00002517          	auipc	a0,0x2
ffffffffc02052c2:	13250513          	addi	a0,a0,306 # ffffffffc02073f0 <default_pmm_manager+0xa80>
ffffffffc02052c6:	9c8fb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc02052ca:	00002617          	auipc	a2,0x2
ffffffffc02052ce:	4c660613          	addi	a2,a2,1222 # ffffffffc0207790 <default_pmm_manager+0xe20>
ffffffffc02052d2:	3e800593          	li	a1,1000
ffffffffc02052d6:	00002517          	auipc	a0,0x2
ffffffffc02052da:	11a50513          	addi	a0,a0,282 # ffffffffc02073f0 <default_pmm_manager+0xa80>
ffffffffc02052de:	9b0fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02052e2:	00002697          	auipc	a3,0x2
ffffffffc02052e6:	51e68693          	addi	a3,a3,1310 # ffffffffc0207800 <default_pmm_manager+0xe90>
ffffffffc02052ea:	00001617          	auipc	a2,0x1
ffffffffc02052ee:	2d660613          	addi	a2,a2,726 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc02052f2:	3fe00593          	li	a1,1022
ffffffffc02052f6:	00002517          	auipc	a0,0x2
ffffffffc02052fa:	0fa50513          	addi	a0,a0,250 # ffffffffc02073f0 <default_pmm_manager+0xa80>
ffffffffc02052fe:	990fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205302:	00002697          	auipc	a3,0x2
ffffffffc0205306:	4d668693          	addi	a3,a3,1238 # ffffffffc02077d8 <default_pmm_manager+0xe68>
ffffffffc020530a:	00001617          	auipc	a2,0x1
ffffffffc020530e:	2b660613          	addi	a2,a2,694 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0205312:	3fd00593          	li	a1,1021
ffffffffc0205316:	00002517          	auipc	a0,0x2
ffffffffc020531a:	0da50513          	addi	a0,a0,218 # ffffffffc02073f0 <default_pmm_manager+0xa80>
ffffffffc020531e:	970fb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0205322 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc0205322:	1141                	addi	sp,sp,-16
ffffffffc0205324:	e022                	sd	s0,0(sp)
ffffffffc0205326:	e406                	sd	ra,8(sp)
ffffffffc0205328:	000b2417          	auipc	s0,0xb2
ffffffffc020532c:	4d040413          	addi	s0,s0,1232 # ffffffffc02b77f8 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc0205330:	6018                	ld	a4,0(s0)
ffffffffc0205332:	6f1c                	ld	a5,24(a4)
ffffffffc0205334:	dffd                	beqz	a5,ffffffffc0205332 <cpu_idle+0x10>
        {
            schedule();
ffffffffc0205336:	0f0000ef          	jal	ra,ffffffffc0205426 <schedule>
ffffffffc020533a:	bfdd                	j	ffffffffc0205330 <cpu_idle+0xe>

ffffffffc020533c <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc020533c:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0205340:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0205344:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0205346:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0205348:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc020534c:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0205350:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0205354:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0205358:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc020535c:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0205360:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0205364:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0205368:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc020536c:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0205370:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0205374:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0205378:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc020537a:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc020537c:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0205380:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0205384:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0205388:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc020538c:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0205390:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0205394:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0205398:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc020539c:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc02053a0:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc02053a4:	8082                	ret

ffffffffc02053a6 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02053a6:	4118                	lw	a4,0(a0)
{
ffffffffc02053a8:	1101                	addi	sp,sp,-32
ffffffffc02053aa:	ec06                	sd	ra,24(sp)
ffffffffc02053ac:	e822                	sd	s0,16(sp)
ffffffffc02053ae:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02053b0:	478d                	li	a5,3
ffffffffc02053b2:	04f70b63          	beq	a4,a5,ffffffffc0205408 <wakeup_proc+0x62>
ffffffffc02053b6:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02053b8:	100027f3          	csrr	a5,sstatus
ffffffffc02053bc:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02053be:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02053c0:	ef9d                	bnez	a5,ffffffffc02053fe <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
ffffffffc02053c2:	4789                	li	a5,2
ffffffffc02053c4:	02f70163          	beq	a4,a5,ffffffffc02053e6 <wakeup_proc+0x40>
        {
            proc->state = PROC_RUNNABLE;
ffffffffc02053c8:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc02053ca:	0e042623          	sw	zero,236(s0)
    if (flag)
ffffffffc02053ce:	e491                	bnez	s1,ffffffffc02053da <wakeup_proc+0x34>
        {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02053d0:	60e2                	ld	ra,24(sp)
ffffffffc02053d2:	6442                	ld	s0,16(sp)
ffffffffc02053d4:	64a2                	ld	s1,8(sp)
ffffffffc02053d6:	6105                	addi	sp,sp,32
ffffffffc02053d8:	8082                	ret
ffffffffc02053da:	6442                	ld	s0,16(sp)
ffffffffc02053dc:	60e2                	ld	ra,24(sp)
ffffffffc02053de:	64a2                	ld	s1,8(sp)
ffffffffc02053e0:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02053e2:	dccfb06f          	j	ffffffffc02009ae <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc02053e6:	00002617          	auipc	a2,0x2
ffffffffc02053ea:	47a60613          	addi	a2,a2,1146 # ffffffffc0207860 <default_pmm_manager+0xef0>
ffffffffc02053ee:	45d1                	li	a1,20
ffffffffc02053f0:	00002517          	auipc	a0,0x2
ffffffffc02053f4:	45850513          	addi	a0,a0,1112 # ffffffffc0207848 <default_pmm_manager+0xed8>
ffffffffc02053f8:	8fefb0ef          	jal	ra,ffffffffc02004f6 <__warn>
ffffffffc02053fc:	bfc9                	j	ffffffffc02053ce <wakeup_proc+0x28>
        intr_disable();
ffffffffc02053fe:	db6fb0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        if (proc->state != PROC_RUNNABLE)
ffffffffc0205402:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc0205404:	4485                	li	s1,1
ffffffffc0205406:	bf75                	j	ffffffffc02053c2 <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205408:	00002697          	auipc	a3,0x2
ffffffffc020540c:	42068693          	addi	a3,a3,1056 # ffffffffc0207828 <default_pmm_manager+0xeb8>
ffffffffc0205410:	00001617          	auipc	a2,0x1
ffffffffc0205414:	1b060613          	addi	a2,a2,432 # ffffffffc02065c0 <commands+0x8c8>
ffffffffc0205418:	45a5                	li	a1,9
ffffffffc020541a:	00002517          	auipc	a0,0x2
ffffffffc020541e:	42e50513          	addi	a0,a0,1070 # ffffffffc0207848 <default_pmm_manager+0xed8>
ffffffffc0205422:	86cfb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0205426 <schedule>:

void schedule(void)
{
ffffffffc0205426:	1141                	addi	sp,sp,-16
ffffffffc0205428:	e406                	sd	ra,8(sp)
ffffffffc020542a:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020542c:	100027f3          	csrr	a5,sstatus
ffffffffc0205430:	8b89                	andi	a5,a5,2
ffffffffc0205432:	4401                	li	s0,0
ffffffffc0205434:	efbd                	bnez	a5,ffffffffc02054b2 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205436:	000b2897          	auipc	a7,0xb2
ffffffffc020543a:	3c28b883          	ld	a7,962(a7) # ffffffffc02b77f8 <current>
ffffffffc020543e:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205442:	000b2517          	auipc	a0,0xb2
ffffffffc0205446:	3be53503          	ld	a0,958(a0) # ffffffffc02b7800 <idleproc>
ffffffffc020544a:	04a88e63          	beq	a7,a0,ffffffffc02054a6 <schedule+0x80>
ffffffffc020544e:	0c888693          	addi	a3,a7,200
ffffffffc0205452:	000b2617          	auipc	a2,0xb2
ffffffffc0205456:	32e60613          	addi	a2,a2,814 # ffffffffc02b7780 <proc_list>
        le = last;
ffffffffc020545a:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc020545c:	4581                	li	a1,0
        do
        {
            if ((le = list_next(le)) != &proc_list)
            {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE)
ffffffffc020545e:	4809                	li	a6,2
ffffffffc0205460:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list)
ffffffffc0205462:	00c78863          	beq	a5,a2,ffffffffc0205472 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE)
ffffffffc0205466:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc020546a:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE)
ffffffffc020546e:	03070163          	beq	a4,a6,ffffffffc0205490 <schedule+0x6a>
                {
                    break;
                }
            }
        } while (le != last);
ffffffffc0205472:	fef697e3          	bne	a3,a5,ffffffffc0205460 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc0205476:	ed89                	bnez	a1,ffffffffc0205490 <schedule+0x6a>
        {
            next = idleproc;
        }
        next->runs++;
ffffffffc0205478:	451c                	lw	a5,8(a0)
ffffffffc020547a:	2785                	addiw	a5,a5,1
ffffffffc020547c:	c51c                	sw	a5,8(a0)
        if (next != current)
ffffffffc020547e:	00a88463          	beq	a7,a0,ffffffffc0205486 <schedule+0x60>
        {
            proc_run(next);
ffffffffc0205482:	eabfe0ef          	jal	ra,ffffffffc020432c <proc_run>
    if (flag)
ffffffffc0205486:	e819                	bnez	s0,ffffffffc020549c <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205488:	60a2                	ld	ra,8(sp)
ffffffffc020548a:	6402                	ld	s0,0(sp)
ffffffffc020548c:	0141                	addi	sp,sp,16
ffffffffc020548e:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc0205490:	4198                	lw	a4,0(a1)
ffffffffc0205492:	4789                	li	a5,2
ffffffffc0205494:	fef712e3          	bne	a4,a5,ffffffffc0205478 <schedule+0x52>
ffffffffc0205498:	852e                	mv	a0,a1
ffffffffc020549a:	bff9                	j	ffffffffc0205478 <schedule+0x52>
}
ffffffffc020549c:	6402                	ld	s0,0(sp)
ffffffffc020549e:	60a2                	ld	ra,8(sp)
ffffffffc02054a0:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02054a2:	d0cfb06f          	j	ffffffffc02009ae <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02054a6:	000b2617          	auipc	a2,0xb2
ffffffffc02054aa:	2da60613          	addi	a2,a2,730 # ffffffffc02b7780 <proc_list>
ffffffffc02054ae:	86b2                	mv	a3,a2
ffffffffc02054b0:	b76d                	j	ffffffffc020545a <schedule+0x34>
        intr_disable();
ffffffffc02054b2:	d02fb0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc02054b6:	4405                	li	s0,1
ffffffffc02054b8:	bfbd                	j	ffffffffc0205436 <schedule+0x10>

ffffffffc02054ba <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc02054ba:	000b2797          	auipc	a5,0xb2
ffffffffc02054be:	33e7b783          	ld	a5,830(a5) # ffffffffc02b77f8 <current>
}
ffffffffc02054c2:	43c8                	lw	a0,4(a5)
ffffffffc02054c4:	8082                	ret

ffffffffc02054c6 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc02054c6:	4501                	li	a0,0
ffffffffc02054c8:	8082                	ret

ffffffffc02054ca <sys_putc>:
    cputchar(c);
ffffffffc02054ca:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc02054cc:	1141                	addi	sp,sp,-16
ffffffffc02054ce:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc02054d0:	cfbfa0ef          	jal	ra,ffffffffc02001ca <cputchar>
}
ffffffffc02054d4:	60a2                	ld	ra,8(sp)
ffffffffc02054d6:	4501                	li	a0,0
ffffffffc02054d8:	0141                	addi	sp,sp,16
ffffffffc02054da:	8082                	ret

ffffffffc02054dc <sys_kill>:
    return do_kill(pid);
ffffffffc02054dc:	4108                	lw	a0,0(a0)
ffffffffc02054de:	c31ff06f          	j	ffffffffc020510e <do_kill>

ffffffffc02054e2 <sys_yield>:
    return do_yield();
ffffffffc02054e2:	bdfff06f          	j	ffffffffc02050c0 <do_yield>

ffffffffc02054e6 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc02054e6:	6d14                	ld	a3,24(a0)
ffffffffc02054e8:	6910                	ld	a2,16(a0)
ffffffffc02054ea:	650c                	ld	a1,8(a0)
ffffffffc02054ec:	6108                	ld	a0,0(a0)
ffffffffc02054ee:	ed8ff06f          	j	ffffffffc0204bc6 <do_execve>

ffffffffc02054f2 <sys_wait>:
    return do_wait(pid, store);
ffffffffc02054f2:	650c                	ld	a1,8(a0)
ffffffffc02054f4:	4108                	lw	a0,0(a0)
ffffffffc02054f6:	bdbff06f          	j	ffffffffc02050d0 <do_wait>

ffffffffc02054fa <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc02054fa:	000b2797          	auipc	a5,0xb2
ffffffffc02054fe:	2fe7b783          	ld	a5,766(a5) # ffffffffc02b77f8 <current>
ffffffffc0205502:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0205504:	4501                	li	a0,0
ffffffffc0205506:	6a0c                	ld	a1,16(a2)
ffffffffc0205508:	e89fe06f          	j	ffffffffc0204390 <do_fork>

ffffffffc020550c <sys_exit>:
    return do_exit(error_code);
ffffffffc020550c:	4108                	lw	a0,0(a0)
ffffffffc020550e:	a78ff06f          	j	ffffffffc0204786 <do_exit>

ffffffffc0205512 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0205512:	711d                	addi	sp,sp,-96
ffffffffc0205514:	e0ca                	sd	s2,64(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205516:	000b2917          	auipc	s2,0xb2
ffffffffc020551a:	2e290913          	addi	s2,s2,738 # ffffffffc02b77f8 <current>
ffffffffc020551e:	00093703          	ld	a4,0(s2)
syscall(void) {
ffffffffc0205522:	e8a2                	sd	s0,80(sp)
ffffffffc0205524:	e4a6                	sd	s1,72(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205526:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0205528:	fc4e                	sd	s3,56(sp)
ffffffffc020552a:	ec86                	sd	ra,88(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
ffffffffc020552c:	4824                	lw	s1,80(s0)
    // Debug: print epc before and after syscall
    uintptr_t epc_before = tf->epc;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc020552e:	47fd                	li	a5,31
    uintptr_t epc_before = tf->epc;
ffffffffc0205530:	10843983          	ld	s3,264(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205534:	0497ee63          	bltu	a5,s1,ffffffffc0205590 <syscall+0x7e>
        if (syscalls[num] != NULL) {
ffffffffc0205538:	00349713          	slli	a4,s1,0x3
ffffffffc020553c:	00002797          	auipc	a5,0x2
ffffffffc0205540:	3d478793          	addi	a5,a5,980 # ffffffffc0207910 <syscalls>
ffffffffc0205544:	97ba                	add	a5,a5,a4
ffffffffc0205546:	639c                	ld	a5,0(a5)
ffffffffc0205548:	c7a1                	beqz	a5,ffffffffc0205590 <syscall+0x7e>
            arg[0] = tf->gpr.a1;
ffffffffc020554a:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
            arg[2] = tf->gpr.a3;
ffffffffc020554c:	7430                	ld	a2,104(s0)
            arg[1] = tf->gpr.a2;
ffffffffc020554e:	702c                	ld	a1,96(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0205550:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0205552:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0205554:	e42a                	sd	a0,8(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0205556:	ec32                	sd	a2,24(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0205558:	e82e                	sd	a1,16(sp)
            arg[3] = tf->gpr.a4;
ffffffffc020555a:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc020555c:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc020555e:	0028                	addi	a0,sp,8
ffffffffc0205560:	9782                	jalr	a5
            // Debug: check if epc was corrupted
            if (tf->epc != epc_before) {
ffffffffc0205562:	10843603          	ld	a2,264(s0)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205566:	e828                	sd	a0,80(s0)
            if (tf->epc != epc_before) {
ffffffffc0205568:	01360d63          	beq	a2,s3,ffffffffc0205582 <syscall+0x70>
                cprintf("[BUG] epc changed! before=0x%lx, after=0x%lx, syscall=%d, pid=%d\n",
ffffffffc020556c:	00093783          	ld	a5,0(s2)
ffffffffc0205570:	86a6                	mv	a3,s1
ffffffffc0205572:	85ce                	mv	a1,s3
ffffffffc0205574:	43d8                	lw	a4,4(a5)
ffffffffc0205576:	00002517          	auipc	a0,0x2
ffffffffc020557a:	30a50513          	addi	a0,a0,778 # ffffffffc0207880 <default_pmm_manager+0xf10>
ffffffffc020557e:	c17fa0ef          	jal	ra,ffffffffc0200194 <cprintf>
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0205582:	60e6                	ld	ra,88(sp)
ffffffffc0205584:	6446                	ld	s0,80(sp)
ffffffffc0205586:	64a6                	ld	s1,72(sp)
ffffffffc0205588:	6906                	ld	s2,64(sp)
ffffffffc020558a:	79e2                	ld	s3,56(sp)
ffffffffc020558c:	6125                	addi	sp,sp,96
ffffffffc020558e:	8082                	ret
    print_trapframe(tf);
ffffffffc0205590:	8522                	mv	a0,s0
ffffffffc0205592:	e12fb0ef          	jal	ra,ffffffffc0200ba4 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0205596:	00093783          	ld	a5,0(s2)
ffffffffc020559a:	86a6                	mv	a3,s1
ffffffffc020559c:	00002617          	auipc	a2,0x2
ffffffffc02055a0:	32c60613          	addi	a2,a2,812 # ffffffffc02078c8 <default_pmm_manager+0xf58>
ffffffffc02055a4:	43d8                	lw	a4,4(a5)
ffffffffc02055a6:	06900593          	li	a1,105
ffffffffc02055aa:	0b478793          	addi	a5,a5,180
ffffffffc02055ae:	00002517          	auipc	a0,0x2
ffffffffc02055b2:	34a50513          	addi	a0,a0,842 # ffffffffc02078f8 <default_pmm_manager+0xf88>
ffffffffc02055b6:	ed9fa0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02055ba <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02055ba:	9e3707b7          	lui	a5,0x9e370
ffffffffc02055be:	2785                	addiw	a5,a5,1
ffffffffc02055c0:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc02055c4:	02000793          	li	a5,32
ffffffffc02055c8:	9f8d                	subw	a5,a5,a1
}
ffffffffc02055ca:	00f5553b          	srlw	a0,a0,a5
ffffffffc02055ce:	8082                	ret

ffffffffc02055d0 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02055d0:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02055d4:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02055d6:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02055da:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02055dc:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02055e0:	f022                	sd	s0,32(sp)
ffffffffc02055e2:	ec26                	sd	s1,24(sp)
ffffffffc02055e4:	e84a                	sd	s2,16(sp)
ffffffffc02055e6:	f406                	sd	ra,40(sp)
ffffffffc02055e8:	e44e                	sd	s3,8(sp)
ffffffffc02055ea:	84aa                	mv	s1,a0
ffffffffc02055ec:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02055ee:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02055f2:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02055f4:	03067e63          	bgeu	a2,a6,ffffffffc0205630 <printnum+0x60>
ffffffffc02055f8:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02055fa:	00805763          	blez	s0,ffffffffc0205608 <printnum+0x38>
ffffffffc02055fe:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0205600:	85ca                	mv	a1,s2
ffffffffc0205602:	854e                	mv	a0,s3
ffffffffc0205604:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0205606:	fc65                	bnez	s0,ffffffffc02055fe <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205608:	1a02                	slli	s4,s4,0x20
ffffffffc020560a:	00002797          	auipc	a5,0x2
ffffffffc020560e:	40678793          	addi	a5,a5,1030 # ffffffffc0207a10 <syscalls+0x100>
ffffffffc0205612:	020a5a13          	srli	s4,s4,0x20
ffffffffc0205616:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0205618:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020561a:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020561e:	70a2                	ld	ra,40(sp)
ffffffffc0205620:	69a2                	ld	s3,8(sp)
ffffffffc0205622:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205624:	85ca                	mv	a1,s2
ffffffffc0205626:	87a6                	mv	a5,s1
}
ffffffffc0205628:	6942                	ld	s2,16(sp)
ffffffffc020562a:	64e2                	ld	s1,24(sp)
ffffffffc020562c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020562e:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0205630:	03065633          	divu	a2,a2,a6
ffffffffc0205634:	8722                	mv	a4,s0
ffffffffc0205636:	f9bff0ef          	jal	ra,ffffffffc02055d0 <printnum>
ffffffffc020563a:	b7f9                	j	ffffffffc0205608 <printnum+0x38>

ffffffffc020563c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020563c:	7119                	addi	sp,sp,-128
ffffffffc020563e:	f4a6                	sd	s1,104(sp)
ffffffffc0205640:	f0ca                	sd	s2,96(sp)
ffffffffc0205642:	ecce                	sd	s3,88(sp)
ffffffffc0205644:	e8d2                	sd	s4,80(sp)
ffffffffc0205646:	e4d6                	sd	s5,72(sp)
ffffffffc0205648:	e0da                	sd	s6,64(sp)
ffffffffc020564a:	fc5e                	sd	s7,56(sp)
ffffffffc020564c:	f06a                	sd	s10,32(sp)
ffffffffc020564e:	fc86                	sd	ra,120(sp)
ffffffffc0205650:	f8a2                	sd	s0,112(sp)
ffffffffc0205652:	f862                	sd	s8,48(sp)
ffffffffc0205654:	f466                	sd	s9,40(sp)
ffffffffc0205656:	ec6e                	sd	s11,24(sp)
ffffffffc0205658:	892a                	mv	s2,a0
ffffffffc020565a:	84ae                	mv	s1,a1
ffffffffc020565c:	8d32                	mv	s10,a2
ffffffffc020565e:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205660:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0205664:	5b7d                	li	s6,-1
ffffffffc0205666:	00002a97          	auipc	s5,0x2
ffffffffc020566a:	3d6a8a93          	addi	s5,s5,982 # ffffffffc0207a3c <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020566e:	00002b97          	auipc	s7,0x2
ffffffffc0205672:	5eab8b93          	addi	s7,s7,1514 # ffffffffc0207c58 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205676:	000d4503          	lbu	a0,0(s10)
ffffffffc020567a:	001d0413          	addi	s0,s10,1
ffffffffc020567e:	01350a63          	beq	a0,s3,ffffffffc0205692 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0205682:	c121                	beqz	a0,ffffffffc02056c2 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0205684:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205686:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0205688:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020568a:	fff44503          	lbu	a0,-1(s0)
ffffffffc020568e:	ff351ae3          	bne	a0,s3,ffffffffc0205682 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205692:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0205696:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020569a:	4c81                	li	s9,0
ffffffffc020569c:	4881                	li	a7,0
        width = precision = -1;
ffffffffc020569e:	5c7d                	li	s8,-1
ffffffffc02056a0:	5dfd                	li	s11,-1
ffffffffc02056a2:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02056a6:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02056a8:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02056ac:	0ff5f593          	zext.b	a1,a1
ffffffffc02056b0:	00140d13          	addi	s10,s0,1
ffffffffc02056b4:	04b56263          	bltu	a0,a1,ffffffffc02056f8 <vprintfmt+0xbc>
ffffffffc02056b8:	058a                	slli	a1,a1,0x2
ffffffffc02056ba:	95d6                	add	a1,a1,s5
ffffffffc02056bc:	4194                	lw	a3,0(a1)
ffffffffc02056be:	96d6                	add	a3,a3,s5
ffffffffc02056c0:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02056c2:	70e6                	ld	ra,120(sp)
ffffffffc02056c4:	7446                	ld	s0,112(sp)
ffffffffc02056c6:	74a6                	ld	s1,104(sp)
ffffffffc02056c8:	7906                	ld	s2,96(sp)
ffffffffc02056ca:	69e6                	ld	s3,88(sp)
ffffffffc02056cc:	6a46                	ld	s4,80(sp)
ffffffffc02056ce:	6aa6                	ld	s5,72(sp)
ffffffffc02056d0:	6b06                	ld	s6,64(sp)
ffffffffc02056d2:	7be2                	ld	s7,56(sp)
ffffffffc02056d4:	7c42                	ld	s8,48(sp)
ffffffffc02056d6:	7ca2                	ld	s9,40(sp)
ffffffffc02056d8:	7d02                	ld	s10,32(sp)
ffffffffc02056da:	6de2                	ld	s11,24(sp)
ffffffffc02056dc:	6109                	addi	sp,sp,128
ffffffffc02056de:	8082                	ret
            padc = '0';
ffffffffc02056e0:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02056e2:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02056e6:	846a                	mv	s0,s10
ffffffffc02056e8:	00140d13          	addi	s10,s0,1
ffffffffc02056ec:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02056f0:	0ff5f593          	zext.b	a1,a1
ffffffffc02056f4:	fcb572e3          	bgeu	a0,a1,ffffffffc02056b8 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02056f8:	85a6                	mv	a1,s1
ffffffffc02056fa:	02500513          	li	a0,37
ffffffffc02056fe:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0205700:	fff44783          	lbu	a5,-1(s0)
ffffffffc0205704:	8d22                	mv	s10,s0
ffffffffc0205706:	f73788e3          	beq	a5,s3,ffffffffc0205676 <vprintfmt+0x3a>
ffffffffc020570a:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020570e:	1d7d                	addi	s10,s10,-1
ffffffffc0205710:	ff379de3          	bne	a5,s3,ffffffffc020570a <vprintfmt+0xce>
ffffffffc0205714:	b78d                	j	ffffffffc0205676 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0205716:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020571a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020571e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0205720:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0205724:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0205728:	02d86463          	bltu	a6,a3,ffffffffc0205750 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020572c:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0205730:	002c169b          	slliw	a3,s8,0x2
ffffffffc0205734:	0186873b          	addw	a4,a3,s8
ffffffffc0205738:	0017171b          	slliw	a4,a4,0x1
ffffffffc020573c:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020573e:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0205742:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0205744:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0205748:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020574c:	fed870e3          	bgeu	a6,a3,ffffffffc020572c <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0205750:	f40ddce3          	bgez	s11,ffffffffc02056a8 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0205754:	8de2                	mv	s11,s8
ffffffffc0205756:	5c7d                	li	s8,-1
ffffffffc0205758:	bf81                	j	ffffffffc02056a8 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020575a:	fffdc693          	not	a3,s11
ffffffffc020575e:	96fd                	srai	a3,a3,0x3f
ffffffffc0205760:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205764:	00144603          	lbu	a2,1(s0)
ffffffffc0205768:	2d81                	sext.w	s11,s11
ffffffffc020576a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020576c:	bf35                	j	ffffffffc02056a8 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020576e:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205772:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0205776:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205778:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020577a:	bfd9                	j	ffffffffc0205750 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020577c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020577e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205782:	01174463          	blt	a4,a7,ffffffffc020578a <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0205786:	1a088e63          	beqz	a7,ffffffffc0205942 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020578a:	000a3603          	ld	a2,0(s4)
ffffffffc020578e:	46c1                	li	a3,16
ffffffffc0205790:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0205792:	2781                	sext.w	a5,a5
ffffffffc0205794:	876e                	mv	a4,s11
ffffffffc0205796:	85a6                	mv	a1,s1
ffffffffc0205798:	854a                	mv	a0,s2
ffffffffc020579a:	e37ff0ef          	jal	ra,ffffffffc02055d0 <printnum>
            break;
ffffffffc020579e:	bde1                	j	ffffffffc0205676 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02057a0:	000a2503          	lw	a0,0(s4)
ffffffffc02057a4:	85a6                	mv	a1,s1
ffffffffc02057a6:	0a21                	addi	s4,s4,8
ffffffffc02057a8:	9902                	jalr	s2
            break;
ffffffffc02057aa:	b5f1                	j	ffffffffc0205676 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02057ac:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02057ae:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02057b2:	01174463          	blt	a4,a7,ffffffffc02057ba <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02057b6:	18088163          	beqz	a7,ffffffffc0205938 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02057ba:	000a3603          	ld	a2,0(s4)
ffffffffc02057be:	46a9                	li	a3,10
ffffffffc02057c0:	8a2e                	mv	s4,a1
ffffffffc02057c2:	bfc1                	j	ffffffffc0205792 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02057c4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02057c8:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02057ca:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02057cc:	bdf1                	j	ffffffffc02056a8 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02057ce:	85a6                	mv	a1,s1
ffffffffc02057d0:	02500513          	li	a0,37
ffffffffc02057d4:	9902                	jalr	s2
            break;
ffffffffc02057d6:	b545                	j	ffffffffc0205676 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02057d8:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02057dc:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02057de:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02057e0:	b5e1                	j	ffffffffc02056a8 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02057e2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02057e4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02057e8:	01174463          	blt	a4,a7,ffffffffc02057f0 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02057ec:	14088163          	beqz	a7,ffffffffc020592e <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02057f0:	000a3603          	ld	a2,0(s4)
ffffffffc02057f4:	46a1                	li	a3,8
ffffffffc02057f6:	8a2e                	mv	s4,a1
ffffffffc02057f8:	bf69                	j	ffffffffc0205792 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02057fa:	03000513          	li	a0,48
ffffffffc02057fe:	85a6                	mv	a1,s1
ffffffffc0205800:	e03e                	sd	a5,0(sp)
ffffffffc0205802:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0205804:	85a6                	mv	a1,s1
ffffffffc0205806:	07800513          	li	a0,120
ffffffffc020580a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020580c:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020580e:	6782                	ld	a5,0(sp)
ffffffffc0205810:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0205812:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0205816:	bfb5                	j	ffffffffc0205792 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0205818:	000a3403          	ld	s0,0(s4)
ffffffffc020581c:	008a0713          	addi	a4,s4,8
ffffffffc0205820:	e03a                	sd	a4,0(sp)
ffffffffc0205822:	14040263          	beqz	s0,ffffffffc0205966 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0205826:	0fb05763          	blez	s11,ffffffffc0205914 <vprintfmt+0x2d8>
ffffffffc020582a:	02d00693          	li	a3,45
ffffffffc020582e:	0cd79163          	bne	a5,a3,ffffffffc02058f0 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205832:	00044783          	lbu	a5,0(s0)
ffffffffc0205836:	0007851b          	sext.w	a0,a5
ffffffffc020583a:	cf85                	beqz	a5,ffffffffc0205872 <vprintfmt+0x236>
ffffffffc020583c:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205840:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205844:	000c4563          	bltz	s8,ffffffffc020584e <vprintfmt+0x212>
ffffffffc0205848:	3c7d                	addiw	s8,s8,-1
ffffffffc020584a:	036c0263          	beq	s8,s6,ffffffffc020586e <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020584e:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205850:	0e0c8e63          	beqz	s9,ffffffffc020594c <vprintfmt+0x310>
ffffffffc0205854:	3781                	addiw	a5,a5,-32
ffffffffc0205856:	0ef47b63          	bgeu	s0,a5,ffffffffc020594c <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020585a:	03f00513          	li	a0,63
ffffffffc020585e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205860:	000a4783          	lbu	a5,0(s4)
ffffffffc0205864:	3dfd                	addiw	s11,s11,-1
ffffffffc0205866:	0a05                	addi	s4,s4,1
ffffffffc0205868:	0007851b          	sext.w	a0,a5
ffffffffc020586c:	ffe1                	bnez	a5,ffffffffc0205844 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc020586e:	01b05963          	blez	s11,ffffffffc0205880 <vprintfmt+0x244>
ffffffffc0205872:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0205874:	85a6                	mv	a1,s1
ffffffffc0205876:	02000513          	li	a0,32
ffffffffc020587a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020587c:	fe0d9be3          	bnez	s11,ffffffffc0205872 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0205880:	6a02                	ld	s4,0(sp)
ffffffffc0205882:	bbd5                	j	ffffffffc0205676 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0205884:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205886:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020588a:	01174463          	blt	a4,a7,ffffffffc0205892 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc020588e:	08088d63          	beqz	a7,ffffffffc0205928 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0205892:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0205896:	0a044d63          	bltz	s0,ffffffffc0205950 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020589a:	8622                	mv	a2,s0
ffffffffc020589c:	8a66                	mv	s4,s9
ffffffffc020589e:	46a9                	li	a3,10
ffffffffc02058a0:	bdcd                	j	ffffffffc0205792 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02058a2:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02058a6:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02058a8:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02058aa:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02058ae:	8fb5                	xor	a5,a5,a3
ffffffffc02058b0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02058b4:	02d74163          	blt	a4,a3,ffffffffc02058d6 <vprintfmt+0x29a>
ffffffffc02058b8:	00369793          	slli	a5,a3,0x3
ffffffffc02058bc:	97de                	add	a5,a5,s7
ffffffffc02058be:	639c                	ld	a5,0(a5)
ffffffffc02058c0:	cb99                	beqz	a5,ffffffffc02058d6 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02058c2:	86be                	mv	a3,a5
ffffffffc02058c4:	00000617          	auipc	a2,0x0
ffffffffc02058c8:	1f460613          	addi	a2,a2,500 # ffffffffc0205ab8 <etext+0x2e>
ffffffffc02058cc:	85a6                	mv	a1,s1
ffffffffc02058ce:	854a                	mv	a0,s2
ffffffffc02058d0:	0ce000ef          	jal	ra,ffffffffc020599e <printfmt>
ffffffffc02058d4:	b34d                	j	ffffffffc0205676 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02058d6:	00002617          	auipc	a2,0x2
ffffffffc02058da:	15a60613          	addi	a2,a2,346 # ffffffffc0207a30 <syscalls+0x120>
ffffffffc02058de:	85a6                	mv	a1,s1
ffffffffc02058e0:	854a                	mv	a0,s2
ffffffffc02058e2:	0bc000ef          	jal	ra,ffffffffc020599e <printfmt>
ffffffffc02058e6:	bb41                	j	ffffffffc0205676 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02058e8:	00002417          	auipc	s0,0x2
ffffffffc02058ec:	14040413          	addi	s0,s0,320 # ffffffffc0207a28 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02058f0:	85e2                	mv	a1,s8
ffffffffc02058f2:	8522                	mv	a0,s0
ffffffffc02058f4:	e43e                	sd	a5,8(sp)
ffffffffc02058f6:	0e2000ef          	jal	ra,ffffffffc02059d8 <strnlen>
ffffffffc02058fa:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02058fe:	01b05b63          	blez	s11,ffffffffc0205914 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0205902:	67a2                	ld	a5,8(sp)
ffffffffc0205904:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205908:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020590a:	85a6                	mv	a1,s1
ffffffffc020590c:	8552                	mv	a0,s4
ffffffffc020590e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205910:	fe0d9ce3          	bnez	s11,ffffffffc0205908 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205914:	00044783          	lbu	a5,0(s0)
ffffffffc0205918:	00140a13          	addi	s4,s0,1
ffffffffc020591c:	0007851b          	sext.w	a0,a5
ffffffffc0205920:	d3a5                	beqz	a5,ffffffffc0205880 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205922:	05e00413          	li	s0,94
ffffffffc0205926:	bf39                	j	ffffffffc0205844 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0205928:	000a2403          	lw	s0,0(s4)
ffffffffc020592c:	b7ad                	j	ffffffffc0205896 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020592e:	000a6603          	lwu	a2,0(s4)
ffffffffc0205932:	46a1                	li	a3,8
ffffffffc0205934:	8a2e                	mv	s4,a1
ffffffffc0205936:	bdb1                	j	ffffffffc0205792 <vprintfmt+0x156>
ffffffffc0205938:	000a6603          	lwu	a2,0(s4)
ffffffffc020593c:	46a9                	li	a3,10
ffffffffc020593e:	8a2e                	mv	s4,a1
ffffffffc0205940:	bd89                	j	ffffffffc0205792 <vprintfmt+0x156>
ffffffffc0205942:	000a6603          	lwu	a2,0(s4)
ffffffffc0205946:	46c1                	li	a3,16
ffffffffc0205948:	8a2e                	mv	s4,a1
ffffffffc020594a:	b5a1                	j	ffffffffc0205792 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020594c:	9902                	jalr	s2
ffffffffc020594e:	bf09                	j	ffffffffc0205860 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0205950:	85a6                	mv	a1,s1
ffffffffc0205952:	02d00513          	li	a0,45
ffffffffc0205956:	e03e                	sd	a5,0(sp)
ffffffffc0205958:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020595a:	6782                	ld	a5,0(sp)
ffffffffc020595c:	8a66                	mv	s4,s9
ffffffffc020595e:	40800633          	neg	a2,s0
ffffffffc0205962:	46a9                	li	a3,10
ffffffffc0205964:	b53d                	j	ffffffffc0205792 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0205966:	03b05163          	blez	s11,ffffffffc0205988 <vprintfmt+0x34c>
ffffffffc020596a:	02d00693          	li	a3,45
ffffffffc020596e:	f6d79de3          	bne	a5,a3,ffffffffc02058e8 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0205972:	00002417          	auipc	s0,0x2
ffffffffc0205976:	0b640413          	addi	s0,s0,182 # ffffffffc0207a28 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020597a:	02800793          	li	a5,40
ffffffffc020597e:	02800513          	li	a0,40
ffffffffc0205982:	00140a13          	addi	s4,s0,1
ffffffffc0205986:	bd6d                	j	ffffffffc0205840 <vprintfmt+0x204>
ffffffffc0205988:	00002a17          	auipc	s4,0x2
ffffffffc020598c:	0a1a0a13          	addi	s4,s4,161 # ffffffffc0207a29 <syscalls+0x119>
ffffffffc0205990:	02800513          	li	a0,40
ffffffffc0205994:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205998:	05e00413          	li	s0,94
ffffffffc020599c:	b565                	j	ffffffffc0205844 <vprintfmt+0x208>

ffffffffc020599e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020599e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02059a0:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02059a4:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02059a6:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02059a8:	ec06                	sd	ra,24(sp)
ffffffffc02059aa:	f83a                	sd	a4,48(sp)
ffffffffc02059ac:	fc3e                	sd	a5,56(sp)
ffffffffc02059ae:	e0c2                	sd	a6,64(sp)
ffffffffc02059b0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02059b2:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02059b4:	c89ff0ef          	jal	ra,ffffffffc020563c <vprintfmt>
}
ffffffffc02059b8:	60e2                	ld	ra,24(sp)
ffffffffc02059ba:	6161                	addi	sp,sp,80
ffffffffc02059bc:	8082                	ret

ffffffffc02059be <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02059be:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02059c2:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02059c4:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02059c6:	cb81                	beqz	a5,ffffffffc02059d6 <strlen+0x18>
        cnt ++;
ffffffffc02059c8:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02059ca:	00a707b3          	add	a5,a4,a0
ffffffffc02059ce:	0007c783          	lbu	a5,0(a5)
ffffffffc02059d2:	fbfd                	bnez	a5,ffffffffc02059c8 <strlen+0xa>
ffffffffc02059d4:	8082                	ret
    }
    return cnt;
}
ffffffffc02059d6:	8082                	ret

ffffffffc02059d8 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02059d8:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02059da:	e589                	bnez	a1,ffffffffc02059e4 <strnlen+0xc>
ffffffffc02059dc:	a811                	j	ffffffffc02059f0 <strnlen+0x18>
        cnt ++;
ffffffffc02059de:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02059e0:	00f58863          	beq	a1,a5,ffffffffc02059f0 <strnlen+0x18>
ffffffffc02059e4:	00f50733          	add	a4,a0,a5
ffffffffc02059e8:	00074703          	lbu	a4,0(a4)
ffffffffc02059ec:	fb6d                	bnez	a4,ffffffffc02059de <strnlen+0x6>
ffffffffc02059ee:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02059f0:	852e                	mv	a0,a1
ffffffffc02059f2:	8082                	ret

ffffffffc02059f4 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02059f4:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02059f6:	0005c703          	lbu	a4,0(a1)
ffffffffc02059fa:	0785                	addi	a5,a5,1
ffffffffc02059fc:	0585                	addi	a1,a1,1
ffffffffc02059fe:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0205a02:	fb75                	bnez	a4,ffffffffc02059f6 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0205a04:	8082                	ret

ffffffffc0205a06 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205a06:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205a0a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205a0e:	cb89                	beqz	a5,ffffffffc0205a20 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0205a10:	0505                	addi	a0,a0,1
ffffffffc0205a12:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205a14:	fee789e3          	beq	a5,a4,ffffffffc0205a06 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205a18:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0205a1c:	9d19                	subw	a0,a0,a4
ffffffffc0205a1e:	8082                	ret
ffffffffc0205a20:	4501                	li	a0,0
ffffffffc0205a22:	bfed                	j	ffffffffc0205a1c <strcmp+0x16>

ffffffffc0205a24 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205a24:	c20d                	beqz	a2,ffffffffc0205a46 <strncmp+0x22>
ffffffffc0205a26:	962e                	add	a2,a2,a1
ffffffffc0205a28:	a031                	j	ffffffffc0205a34 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0205a2a:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205a2c:	00e79a63          	bne	a5,a4,ffffffffc0205a40 <strncmp+0x1c>
ffffffffc0205a30:	00b60b63          	beq	a2,a1,ffffffffc0205a46 <strncmp+0x22>
ffffffffc0205a34:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0205a38:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205a3a:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0205a3e:	f7f5                	bnez	a5,ffffffffc0205a2a <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205a40:	40e7853b          	subw	a0,a5,a4
}
ffffffffc0205a44:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205a46:	4501                	li	a0,0
ffffffffc0205a48:	8082                	ret

ffffffffc0205a4a <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0205a4a:	00054783          	lbu	a5,0(a0)
ffffffffc0205a4e:	c799                	beqz	a5,ffffffffc0205a5c <strchr+0x12>
        if (*s == c) {
ffffffffc0205a50:	00f58763          	beq	a1,a5,ffffffffc0205a5e <strchr+0x14>
    while (*s != '\0') {
ffffffffc0205a54:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0205a58:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0205a5a:	fbfd                	bnez	a5,ffffffffc0205a50 <strchr+0x6>
    }
    return NULL;
ffffffffc0205a5c:	4501                	li	a0,0
}
ffffffffc0205a5e:	8082                	ret

ffffffffc0205a60 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0205a60:	ca01                	beqz	a2,ffffffffc0205a70 <memset+0x10>
ffffffffc0205a62:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0205a64:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0205a66:	0785                	addi	a5,a5,1
ffffffffc0205a68:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0205a6c:	fec79de3          	bne	a5,a2,ffffffffc0205a66 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0205a70:	8082                	ret

ffffffffc0205a72 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0205a72:	ca19                	beqz	a2,ffffffffc0205a88 <memcpy+0x16>
ffffffffc0205a74:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0205a76:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0205a78:	0005c703          	lbu	a4,0(a1)
ffffffffc0205a7c:	0585                	addi	a1,a1,1
ffffffffc0205a7e:	0785                	addi	a5,a5,1
ffffffffc0205a80:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0205a84:	fec59ae3          	bne	a1,a2,ffffffffc0205a78 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0205a88:	8082                	ret
