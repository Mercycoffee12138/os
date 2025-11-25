
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
ffffffffc020004a:	000a6517          	auipc	a0,0xa6
ffffffffc020004e:	3ae50513          	addi	a0,a0,942 # ffffffffc02a63f8 <buf>
ffffffffc0200052:	000ab617          	auipc	a2,0xab
ffffffffc0200056:	85260613          	addi	a2,a2,-1966 # ffffffffc02aa8a4 <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	76a050ef          	jal	ra,ffffffffc02057cc <memset>
    dtb_init();
ffffffffc0200066:	598000ef          	jal	ra,ffffffffc02005fe <dtb_init>
    cons_init(); // init the console
ffffffffc020006a:	522000ef          	jal	ra,ffffffffc020058c <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006e:	00005597          	auipc	a1,0x5
ffffffffc0200072:	78a58593          	addi	a1,a1,1930 # ffffffffc02057f8 <etext+0x2>
ffffffffc0200076:	00005517          	auipc	a0,0x5
ffffffffc020007a:	7a250513          	addi	a0,a0,1954 # ffffffffc0205818 <etext+0x22>
ffffffffc020007e:	116000ef          	jal	ra,ffffffffc0200194 <cprintf>

    print_kerninfo();
ffffffffc0200082:	19a000ef          	jal	ra,ffffffffc020021c <print_kerninfo>

    // grade_backtrace();

    pmm_init(); // init physical memory management
ffffffffc0200086:	6d0020ef          	jal	ra,ffffffffc0202756 <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	131000ef          	jal	ra,ffffffffc02009ba <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	12f000ef          	jal	ra,ffffffffc02009bc <idt_init>

    vmm_init();  // init virtual memory management
ffffffffc0200092:	1bd030ef          	jal	ra,ffffffffc0203a4e <vmm_init>
    proc_init(); // init process table
ffffffffc0200096:	689040ef          	jal	ra,ffffffffc0204f1e <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009a:	4a0000ef          	jal	ra,ffffffffc020053a <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc020009e:	111000ef          	jal	ra,ffffffffc02009ae <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a2:	014050ef          	jal	ra,ffffffffc02050b6 <cpu_idle>

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
ffffffffc02000bc:	00005517          	auipc	a0,0x5
ffffffffc02000c0:	76450513          	addi	a0,a0,1892 # ffffffffc0205820 <etext+0x2a>
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
ffffffffc02000d2:	000a6b97          	auipc	s7,0xa6
ffffffffc02000d6:	326b8b93          	addi	s7,s7,806 # ffffffffc02a63f8 <buf>
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
ffffffffc020012e:	000a6517          	auipc	a0,0xa6
ffffffffc0200132:	2ca50513          	addi	a0,a0,714 # ffffffffc02a63f8 <buf>
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
ffffffffc0200188:	220050ef          	jal	ra,ffffffffc02053a8 <vprintfmt>
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
ffffffffc02001be:	1ea050ef          	jal	ra,ffffffffc02053a8 <vprintfmt>
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
ffffffffc020021e:	00005517          	auipc	a0,0x5
ffffffffc0200222:	60a50513          	addi	a0,a0,1546 # ffffffffc0205828 <etext+0x32>
{
ffffffffc0200226:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200228:	f6dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020022c:	00000597          	auipc	a1,0x0
ffffffffc0200230:	e1e58593          	addi	a1,a1,-482 # ffffffffc020004a <kern_init>
ffffffffc0200234:	00005517          	auipc	a0,0x5
ffffffffc0200238:	61450513          	addi	a0,a0,1556 # ffffffffc0205848 <etext+0x52>
ffffffffc020023c:	f59ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200240:	00005597          	auipc	a1,0x5
ffffffffc0200244:	5b658593          	addi	a1,a1,1462 # ffffffffc02057f6 <etext>
ffffffffc0200248:	00005517          	auipc	a0,0x5
ffffffffc020024c:	62050513          	addi	a0,a0,1568 # ffffffffc0205868 <etext+0x72>
ffffffffc0200250:	f45ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200254:	000a6597          	auipc	a1,0xa6
ffffffffc0200258:	1a458593          	addi	a1,a1,420 # ffffffffc02a63f8 <buf>
ffffffffc020025c:	00005517          	auipc	a0,0x5
ffffffffc0200260:	62c50513          	addi	a0,a0,1580 # ffffffffc0205888 <etext+0x92>
ffffffffc0200264:	f31ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200268:	000aa597          	auipc	a1,0xaa
ffffffffc020026c:	63c58593          	addi	a1,a1,1596 # ffffffffc02aa8a4 <end>
ffffffffc0200270:	00005517          	auipc	a0,0x5
ffffffffc0200274:	63850513          	addi	a0,a0,1592 # ffffffffc02058a8 <etext+0xb2>
ffffffffc0200278:	f1dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020027c:	000ab597          	auipc	a1,0xab
ffffffffc0200280:	a2758593          	addi	a1,a1,-1497 # ffffffffc02aaca3 <end+0x3ff>
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
ffffffffc020029e:	00005517          	auipc	a0,0x5
ffffffffc02002a2:	62a50513          	addi	a0,a0,1578 # ffffffffc02058c8 <etext+0xd2>
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
ffffffffc02002ac:	00005617          	auipc	a2,0x5
ffffffffc02002b0:	64c60613          	addi	a2,a2,1612 # ffffffffc02058f8 <etext+0x102>
ffffffffc02002b4:	04f00593          	li	a1,79
ffffffffc02002b8:	00005517          	auipc	a0,0x5
ffffffffc02002bc:	65850513          	addi	a0,a0,1624 # ffffffffc0205910 <etext+0x11a>
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
ffffffffc02002c8:	00005617          	auipc	a2,0x5
ffffffffc02002cc:	66060613          	addi	a2,a2,1632 # ffffffffc0205928 <etext+0x132>
ffffffffc02002d0:	00005597          	auipc	a1,0x5
ffffffffc02002d4:	67858593          	addi	a1,a1,1656 # ffffffffc0205948 <etext+0x152>
ffffffffc02002d8:	00005517          	auipc	a0,0x5
ffffffffc02002dc:	67850513          	addi	a0,a0,1656 # ffffffffc0205950 <etext+0x15a>
{
ffffffffc02002e0:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e2:	eb3ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02002e6:	00005617          	auipc	a2,0x5
ffffffffc02002ea:	67a60613          	addi	a2,a2,1658 # ffffffffc0205960 <etext+0x16a>
ffffffffc02002ee:	00005597          	auipc	a1,0x5
ffffffffc02002f2:	69a58593          	addi	a1,a1,1690 # ffffffffc0205988 <etext+0x192>
ffffffffc02002f6:	00005517          	auipc	a0,0x5
ffffffffc02002fa:	65a50513          	addi	a0,a0,1626 # ffffffffc0205950 <etext+0x15a>
ffffffffc02002fe:	e97ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200302:	00005617          	auipc	a2,0x5
ffffffffc0200306:	69660613          	addi	a2,a2,1686 # ffffffffc0205998 <etext+0x1a2>
ffffffffc020030a:	00005597          	auipc	a1,0x5
ffffffffc020030e:	6ae58593          	addi	a1,a1,1710 # ffffffffc02059b8 <etext+0x1c2>
ffffffffc0200312:	00005517          	auipc	a0,0x5
ffffffffc0200316:	63e50513          	addi	a0,a0,1598 # ffffffffc0205950 <etext+0x15a>
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
ffffffffc020034c:	00005517          	auipc	a0,0x5
ffffffffc0200350:	67c50513          	addi	a0,a0,1660 # ffffffffc02059c8 <etext+0x1d2>
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
ffffffffc020036e:	00005517          	auipc	a0,0x5
ffffffffc0200372:	68250513          	addi	a0,a0,1666 # ffffffffc02059f0 <etext+0x1fa>
ffffffffc0200376:	e1fff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    if (tf != NULL)
ffffffffc020037a:	000b8563          	beqz	s7,ffffffffc0200384 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020037e:	855e                	mv	a0,s7
ffffffffc0200380:	025000ef          	jal	ra,ffffffffc0200ba4 <print_trapframe>
ffffffffc0200384:	00005c17          	auipc	s8,0x5
ffffffffc0200388:	6dcc0c13          	addi	s8,s8,1756 # ffffffffc0205a60 <commands>
        if ((buf = readline("K> ")) != NULL)
ffffffffc020038c:	00005917          	auipc	s2,0x5
ffffffffc0200390:	68c90913          	addi	s2,s2,1676 # ffffffffc0205a18 <etext+0x222>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200394:	00005497          	auipc	s1,0x5
ffffffffc0200398:	68c48493          	addi	s1,s1,1676 # ffffffffc0205a20 <etext+0x22a>
        if (argc == MAXARGS - 1)
ffffffffc020039c:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020039e:	00005b17          	auipc	s6,0x5
ffffffffc02003a2:	68ab0b13          	addi	s6,s6,1674 # ffffffffc0205a28 <etext+0x232>
        argv[argc++] = buf;
ffffffffc02003a6:	00005a17          	auipc	s4,0x5
ffffffffc02003aa:	5a2a0a13          	addi	s4,s4,1442 # ffffffffc0205948 <etext+0x152>
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
ffffffffc02003c8:	00005d17          	auipc	s10,0x5
ffffffffc02003cc:	698d0d13          	addi	s10,s10,1688 # ffffffffc0205a60 <commands>
        argv[argc++] = buf;
ffffffffc02003d0:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc02003d2:	4401                	li	s0,0
ffffffffc02003d4:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc02003d6:	39c050ef          	jal	ra,ffffffffc0205772 <strcmp>
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
ffffffffc02003ea:	388050ef          	jal	ra,ffffffffc0205772 <strcmp>
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
ffffffffc0200428:	38e050ef          	jal	ra,ffffffffc02057b6 <strchr>
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
ffffffffc0200466:	350050ef          	jal	ra,ffffffffc02057b6 <strchr>
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
ffffffffc0200480:	00005517          	auipc	a0,0x5
ffffffffc0200484:	5c850513          	addi	a0,a0,1480 # ffffffffc0205a48 <etext+0x252>
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
ffffffffc020048e:	000aa317          	auipc	t1,0xaa
ffffffffc0200492:	39230313          	addi	t1,t1,914 # ffffffffc02aa820 <is_panic>
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
ffffffffc02004bc:	00005517          	auipc	a0,0x5
ffffffffc02004c0:	5ec50513          	addi	a0,a0,1516 # ffffffffc0205aa8 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02004c4:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004c6:	ccfff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004ca:	65a2                	ld	a1,8(sp)
ffffffffc02004cc:	8522                	mv	a0,s0
ffffffffc02004ce:	ca7ff0ef          	jal	ra,ffffffffc0200174 <vcprintf>
    cprintf("\n");
ffffffffc02004d2:	00006517          	auipc	a0,0x6
ffffffffc02004d6:	6de50513          	addi	a0,a0,1758 # ffffffffc0206bb0 <default_pmm_manager+0x578>
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
ffffffffc0200506:	00005517          	auipc	a0,0x5
ffffffffc020050a:	5c250513          	addi	a0,a0,1474 # ffffffffc0205ac8 <commands+0x68>
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
ffffffffc0200526:	00006517          	auipc	a0,0x6
ffffffffc020052a:	68a50513          	addi	a0,a0,1674 # ffffffffc0206bb0 <default_pmm_manager+0x578>
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
ffffffffc020053c:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd568>
ffffffffc0200540:	000aa717          	auipc	a4,0xaa
ffffffffc0200544:	2ef73823          	sd	a5,752(a4) # ffffffffc02aa830 <timebase>
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
ffffffffc0200560:	00005517          	auipc	a0,0x5
ffffffffc0200564:	58850513          	addi	a0,a0,1416 # ffffffffc0205ae8 <commands+0x88>
    ticks = 0;
ffffffffc0200568:	000aa797          	auipc	a5,0xaa
ffffffffc020056c:	2c07b023          	sd	zero,704(a5) # ffffffffc02aa828 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200570:	b115                	j	ffffffffc0200194 <cprintf>

ffffffffc0200572 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200572:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200576:	000aa797          	auipc	a5,0xaa
ffffffffc020057a:	2ba7b783          	ld	a5,698(a5) # ffffffffc02aa830 <timebase>
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
ffffffffc0200604:	50850513          	addi	a0,a0,1288 # ffffffffc0205b08 <commands+0xa8>
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
ffffffffc0200632:	4ea50513          	addi	a0,a0,1258 # ffffffffc0205b18 <commands+0xb8>
ffffffffc0200636:	b5fff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020063a:	0000b417          	auipc	s0,0xb
ffffffffc020063e:	9ce40413          	addi	s0,s0,-1586 # ffffffffc020b008 <boot_dtb>
ffffffffc0200642:	600c                	ld	a1,0(s0)
ffffffffc0200644:	00005517          	auipc	a0,0x5
ffffffffc0200648:	4e450513          	addi	a0,a0,1252 # ffffffffc0205b28 <commands+0xc8>
ffffffffc020064c:	b49ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200650:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200654:	00005517          	auipc	a0,0x5
ffffffffc0200658:	4ec50513          	addi	a0,a0,1260 # ffffffffc0205b40 <commands+0xe0>
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
ffffffffc020069c:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfe35649>
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
ffffffffc0200712:	48290913          	addi	s2,s2,1154 # ffffffffc0205b90 <commands+0x130>
ffffffffc0200716:	49bd                	li	s3,15
        switch (token) {
ffffffffc0200718:	4d91                	li	s11,4
ffffffffc020071a:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020071c:	00005497          	auipc	s1,0x5
ffffffffc0200720:	46c48493          	addi	s1,s1,1132 # ffffffffc0205b88 <commands+0x128>
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
ffffffffc0200774:	49850513          	addi	a0,a0,1176 # ffffffffc0205c08 <commands+0x1a8>
ffffffffc0200778:	a1dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc020077c:	00005517          	auipc	a0,0x5
ffffffffc0200780:	4c450513          	addi	a0,a0,1220 # ffffffffc0205c40 <commands+0x1e0>
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
ffffffffc02007c0:	3a450513          	addi	a0,a0,932 # ffffffffc0205b60 <commands+0x100>
}
ffffffffc02007c4:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02007c6:	b2f9                	j	ffffffffc0200194 <cprintf>
                int name_len = strlen(name);
ffffffffc02007c8:	8556                	mv	a0,s5
ffffffffc02007ca:	761040ef          	jal	ra,ffffffffc020572a <strlen>
ffffffffc02007ce:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02007d0:	4619                	li	a2,6
ffffffffc02007d2:	85a6                	mv	a1,s1
ffffffffc02007d4:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02007d6:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02007d8:	7b9040ef          	jal	ra,ffffffffc0205790 <strncmp>
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
ffffffffc020086e:	705040ef          	jal	ra,ffffffffc0205772 <strcmp>
ffffffffc0200872:	66a2                	ld	a3,8(sp)
ffffffffc0200874:	f94d                	bnez	a0,ffffffffc0200826 <dtb_init+0x228>
ffffffffc0200876:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200826 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc020087a:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc020087e:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200882:	00005517          	auipc	a0,0x5
ffffffffc0200886:	31650513          	addi	a0,a0,790 # ffffffffc0205b98 <commands+0x138>
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
ffffffffc0200954:	26850513          	addi	a0,a0,616 # ffffffffc0205bb8 <commands+0x158>
ffffffffc0200958:	83dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020095c:	014b5613          	srli	a2,s6,0x14
ffffffffc0200960:	85da                	mv	a1,s6
ffffffffc0200962:	00005517          	auipc	a0,0x5
ffffffffc0200966:	26e50513          	addi	a0,a0,622 # ffffffffc0205bd0 <commands+0x170>
ffffffffc020096a:	82bff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc020096e:	008b05b3          	add	a1,s6,s0
ffffffffc0200972:	15fd                	addi	a1,a1,-1
ffffffffc0200974:	00005517          	auipc	a0,0x5
ffffffffc0200978:	27c50513          	addi	a0,a0,636 # ffffffffc0205bf0 <commands+0x190>
ffffffffc020097c:	819ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("DTB init completed\n");
ffffffffc0200980:	00005517          	auipc	a0,0x5
ffffffffc0200984:	2c050513          	addi	a0,a0,704 # ffffffffc0205c40 <commands+0x1e0>
        memory_base = mem_base;
ffffffffc0200988:	000aa797          	auipc	a5,0xaa
ffffffffc020098c:	ea87b823          	sd	s0,-336(a5) # ffffffffc02aa838 <memory_base>
        memory_size = mem_size;
ffffffffc0200990:	000aa797          	auipc	a5,0xaa
ffffffffc0200994:	eb67b823          	sd	s6,-336(a5) # ffffffffc02aa840 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc0200998:	b3f5                	j	ffffffffc0200784 <dtb_init+0x186>

ffffffffc020099a <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc020099a:	000aa517          	auipc	a0,0xaa
ffffffffc020099e:	e9e53503          	ld	a0,-354(a0) # ffffffffc02aa838 <memory_base>
ffffffffc02009a2:	8082                	ret

ffffffffc02009a4 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc02009a4:	000aa517          	auipc	a0,0xaa
ffffffffc02009a8:	e9c53503          	ld	a0,-356(a0) # ffffffffc02aa840 <memory_size>
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
ffffffffc02009c4:	4c478793          	addi	a5,a5,1220 # ffffffffc0200e84 <__alltraps>
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
ffffffffc02009e2:	27a50513          	addi	a0,a0,634 # ffffffffc0205c58 <commands+0x1f8>
{
ffffffffc02009e6:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009e8:	facff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02009ec:	640c                	ld	a1,8(s0)
ffffffffc02009ee:	00005517          	auipc	a0,0x5
ffffffffc02009f2:	28250513          	addi	a0,a0,642 # ffffffffc0205c70 <commands+0x210>
ffffffffc02009f6:	f9eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02009fa:	680c                	ld	a1,16(s0)
ffffffffc02009fc:	00005517          	auipc	a0,0x5
ffffffffc0200a00:	28c50513          	addi	a0,a0,652 # ffffffffc0205c88 <commands+0x228>
ffffffffc0200a04:	f90ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200a08:	6c0c                	ld	a1,24(s0)
ffffffffc0200a0a:	00005517          	auipc	a0,0x5
ffffffffc0200a0e:	29650513          	addi	a0,a0,662 # ffffffffc0205ca0 <commands+0x240>
ffffffffc0200a12:	f82ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200a16:	700c                	ld	a1,32(s0)
ffffffffc0200a18:	00005517          	auipc	a0,0x5
ffffffffc0200a1c:	2a050513          	addi	a0,a0,672 # ffffffffc0205cb8 <commands+0x258>
ffffffffc0200a20:	f74ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200a24:	740c                	ld	a1,40(s0)
ffffffffc0200a26:	00005517          	auipc	a0,0x5
ffffffffc0200a2a:	2aa50513          	addi	a0,a0,682 # ffffffffc0205cd0 <commands+0x270>
ffffffffc0200a2e:	f66ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc0200a32:	780c                	ld	a1,48(s0)
ffffffffc0200a34:	00005517          	auipc	a0,0x5
ffffffffc0200a38:	2b450513          	addi	a0,a0,692 # ffffffffc0205ce8 <commands+0x288>
ffffffffc0200a3c:	f58ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200a40:	7c0c                	ld	a1,56(s0)
ffffffffc0200a42:	00005517          	auipc	a0,0x5
ffffffffc0200a46:	2be50513          	addi	a0,a0,702 # ffffffffc0205d00 <commands+0x2a0>
ffffffffc0200a4a:	f4aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200a4e:	602c                	ld	a1,64(s0)
ffffffffc0200a50:	00005517          	auipc	a0,0x5
ffffffffc0200a54:	2c850513          	addi	a0,a0,712 # ffffffffc0205d18 <commands+0x2b8>
ffffffffc0200a58:	f3cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200a5c:	642c                	ld	a1,72(s0)
ffffffffc0200a5e:	00005517          	auipc	a0,0x5
ffffffffc0200a62:	2d250513          	addi	a0,a0,722 # ffffffffc0205d30 <commands+0x2d0>
ffffffffc0200a66:	f2eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200a6a:	682c                	ld	a1,80(s0)
ffffffffc0200a6c:	00005517          	auipc	a0,0x5
ffffffffc0200a70:	2dc50513          	addi	a0,a0,732 # ffffffffc0205d48 <commands+0x2e8>
ffffffffc0200a74:	f20ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200a78:	6c2c                	ld	a1,88(s0)
ffffffffc0200a7a:	00005517          	auipc	a0,0x5
ffffffffc0200a7e:	2e650513          	addi	a0,a0,742 # ffffffffc0205d60 <commands+0x300>
ffffffffc0200a82:	f12ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200a86:	702c                	ld	a1,96(s0)
ffffffffc0200a88:	00005517          	auipc	a0,0x5
ffffffffc0200a8c:	2f050513          	addi	a0,a0,752 # ffffffffc0205d78 <commands+0x318>
ffffffffc0200a90:	f04ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200a94:	742c                	ld	a1,104(s0)
ffffffffc0200a96:	00005517          	auipc	a0,0x5
ffffffffc0200a9a:	2fa50513          	addi	a0,a0,762 # ffffffffc0205d90 <commands+0x330>
ffffffffc0200a9e:	ef6ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200aa2:	782c                	ld	a1,112(s0)
ffffffffc0200aa4:	00005517          	auipc	a0,0x5
ffffffffc0200aa8:	30450513          	addi	a0,a0,772 # ffffffffc0205da8 <commands+0x348>
ffffffffc0200aac:	ee8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200ab0:	7c2c                	ld	a1,120(s0)
ffffffffc0200ab2:	00005517          	auipc	a0,0x5
ffffffffc0200ab6:	30e50513          	addi	a0,a0,782 # ffffffffc0205dc0 <commands+0x360>
ffffffffc0200aba:	edaff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200abe:	604c                	ld	a1,128(s0)
ffffffffc0200ac0:	00005517          	auipc	a0,0x5
ffffffffc0200ac4:	31850513          	addi	a0,a0,792 # ffffffffc0205dd8 <commands+0x378>
ffffffffc0200ac8:	eccff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200acc:	644c                	ld	a1,136(s0)
ffffffffc0200ace:	00005517          	auipc	a0,0x5
ffffffffc0200ad2:	32250513          	addi	a0,a0,802 # ffffffffc0205df0 <commands+0x390>
ffffffffc0200ad6:	ebeff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200ada:	684c                	ld	a1,144(s0)
ffffffffc0200adc:	00005517          	auipc	a0,0x5
ffffffffc0200ae0:	32c50513          	addi	a0,a0,812 # ffffffffc0205e08 <commands+0x3a8>
ffffffffc0200ae4:	eb0ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200ae8:	6c4c                	ld	a1,152(s0)
ffffffffc0200aea:	00005517          	auipc	a0,0x5
ffffffffc0200aee:	33650513          	addi	a0,a0,822 # ffffffffc0205e20 <commands+0x3c0>
ffffffffc0200af2:	ea2ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200af6:	704c                	ld	a1,160(s0)
ffffffffc0200af8:	00005517          	auipc	a0,0x5
ffffffffc0200afc:	34050513          	addi	a0,a0,832 # ffffffffc0205e38 <commands+0x3d8>
ffffffffc0200b00:	e94ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200b04:	744c                	ld	a1,168(s0)
ffffffffc0200b06:	00005517          	auipc	a0,0x5
ffffffffc0200b0a:	34a50513          	addi	a0,a0,842 # ffffffffc0205e50 <commands+0x3f0>
ffffffffc0200b0e:	e86ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200b12:	784c                	ld	a1,176(s0)
ffffffffc0200b14:	00005517          	auipc	a0,0x5
ffffffffc0200b18:	35450513          	addi	a0,a0,852 # ffffffffc0205e68 <commands+0x408>
ffffffffc0200b1c:	e78ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200b20:	7c4c                	ld	a1,184(s0)
ffffffffc0200b22:	00005517          	auipc	a0,0x5
ffffffffc0200b26:	35e50513          	addi	a0,a0,862 # ffffffffc0205e80 <commands+0x420>
ffffffffc0200b2a:	e6aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200b2e:	606c                	ld	a1,192(s0)
ffffffffc0200b30:	00005517          	auipc	a0,0x5
ffffffffc0200b34:	36850513          	addi	a0,a0,872 # ffffffffc0205e98 <commands+0x438>
ffffffffc0200b38:	e5cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200b3c:	646c                	ld	a1,200(s0)
ffffffffc0200b3e:	00005517          	auipc	a0,0x5
ffffffffc0200b42:	37250513          	addi	a0,a0,882 # ffffffffc0205eb0 <commands+0x450>
ffffffffc0200b46:	e4eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200b4a:	686c                	ld	a1,208(s0)
ffffffffc0200b4c:	00005517          	auipc	a0,0x5
ffffffffc0200b50:	37c50513          	addi	a0,a0,892 # ffffffffc0205ec8 <commands+0x468>
ffffffffc0200b54:	e40ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200b58:	6c6c                	ld	a1,216(s0)
ffffffffc0200b5a:	00005517          	auipc	a0,0x5
ffffffffc0200b5e:	38650513          	addi	a0,a0,902 # ffffffffc0205ee0 <commands+0x480>
ffffffffc0200b62:	e32ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200b66:	706c                	ld	a1,224(s0)
ffffffffc0200b68:	00005517          	auipc	a0,0x5
ffffffffc0200b6c:	39050513          	addi	a0,a0,912 # ffffffffc0205ef8 <commands+0x498>
ffffffffc0200b70:	e24ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200b74:	746c                	ld	a1,232(s0)
ffffffffc0200b76:	00005517          	auipc	a0,0x5
ffffffffc0200b7a:	39a50513          	addi	a0,a0,922 # ffffffffc0205f10 <commands+0x4b0>
ffffffffc0200b7e:	e16ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200b82:	786c                	ld	a1,240(s0)
ffffffffc0200b84:	00005517          	auipc	a0,0x5
ffffffffc0200b88:	3a450513          	addi	a0,a0,932 # ffffffffc0205f28 <commands+0x4c8>
ffffffffc0200b8c:	e08ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b90:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200b92:	6402                	ld	s0,0(sp)
ffffffffc0200b94:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b96:	00005517          	auipc	a0,0x5
ffffffffc0200b9a:	3aa50513          	addi	a0,a0,938 # ffffffffc0205f40 <commands+0x4e0>
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
ffffffffc0200bb0:	3ac50513          	addi	a0,a0,940 # ffffffffc0205f58 <commands+0x4f8>
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
ffffffffc0200bc8:	3ac50513          	addi	a0,a0,940 # ffffffffc0205f70 <commands+0x510>
ffffffffc0200bcc:	dc8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200bd0:	10843583          	ld	a1,264(s0)
ffffffffc0200bd4:	00005517          	auipc	a0,0x5
ffffffffc0200bd8:	3b450513          	addi	a0,a0,948 # ffffffffc0205f88 <commands+0x528>
ffffffffc0200bdc:	db8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200be0:	11043583          	ld	a1,272(s0)
ffffffffc0200be4:	00005517          	auipc	a0,0x5
ffffffffc0200be8:	3bc50513          	addi	a0,a0,956 # ffffffffc0205fa0 <commands+0x540>
ffffffffc0200bec:	da8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bf0:	11843583          	ld	a1,280(s0)
}
ffffffffc0200bf4:	6402                	ld	s0,0(sp)
ffffffffc0200bf6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bf8:	00005517          	auipc	a0,0x5
ffffffffc0200bfc:	3b850513          	addi	a0,a0,952 # ffffffffc0205fb0 <commands+0x550>
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
ffffffffc0200c10:	08f76b63          	bltu	a4,a5,ffffffffc0200ca6 <interrupt_handler+0xa0>
ffffffffc0200c14:	00005717          	auipc	a4,0x5
ffffffffc0200c18:	46470713          	addi	a4,a4,1124 # ffffffffc0206078 <commands+0x618>
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
ffffffffc0200c2a:	40250513          	addi	a0,a0,1026 # ffffffffc0206028 <commands+0x5c8>
ffffffffc0200c2e:	d66ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200c32:	00005517          	auipc	a0,0x5
ffffffffc0200c36:	3d650513          	addi	a0,a0,982 # ffffffffc0206008 <commands+0x5a8>
ffffffffc0200c3a:	d5aff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200c3e:	00005517          	auipc	a0,0x5
ffffffffc0200c42:	38a50513          	addi	a0,a0,906 # ffffffffc0205fc8 <commands+0x568>
ffffffffc0200c46:	d4eff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200c4a:	00005517          	auipc	a0,0x5
ffffffffc0200c4e:	39e50513          	addi	a0,a0,926 # ffffffffc0205fe8 <commands+0x588>
ffffffffc0200c52:	d42ff06f          	j	ffffffffc0200194 <cprintf>
{
ffffffffc0200c56:	1141                	addi	sp,sp,-16
ffffffffc0200c58:	e022                	sd	s0,0(sp)
ffffffffc0200c5a:	e406                	sd	ra,8(sp)
ffffffffc0200c5c:	842a                	mv	s0,a0
        /*(1)设置下次时钟中断- clock_set_next_event()
         *(2)计数器（ticks）加一
         *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
         * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
         */
        clock_set_next_event();//发生这次时钟中断的时候，我们要设置下一次时钟中断
ffffffffc0200c5e:	915ff0ef          	jal	ra,ffffffffc0200572 <clock_set_next_event>
        if (++ticks % TICK_NUM == 0) {
ffffffffc0200c62:	000aa697          	auipc	a3,0xaa
ffffffffc0200c66:	bc668693          	addi	a3,a3,-1082 # ffffffffc02aa828 <ticks>
ffffffffc0200c6a:	629c                	ld	a5,0(a3)
ffffffffc0200c6c:	06400713          	li	a4,100
ffffffffc0200c70:	0785                	addi	a5,a5,1
ffffffffc0200c72:	02e7f733          	remu	a4,a5,a4
ffffffffc0200c76:	e29c                	sd	a5,0(a3)
ffffffffc0200c78:	cb05                	beqz	a4,ffffffffc0200ca8 <interrupt_handler+0xa2>
            num++; // 打印次数加一
            if (num == 10) {
                sbi_shutdown(); // 关机
            }
        }
        if(current !=NULL && (tf->status & SSTATUS_SPP)==0 ){
ffffffffc0200c7a:	000aa717          	auipc	a4,0xaa
ffffffffc0200c7e:	c0e73703          	ld	a4,-1010(a4) # ffffffffc02aa888 <current>
ffffffffc0200c82:	cb01                	beqz	a4,ffffffffc0200c92 <interrupt_handler+0x8c>
ffffffffc0200c84:	10043783          	ld	a5,256(s0)
ffffffffc0200c88:	1007f793          	andi	a5,a5,256
ffffffffc0200c8c:	e399                	bnez	a5,ffffffffc0200c92 <interrupt_handler+0x8c>
            current->need_resched = 1;
ffffffffc0200c8e:	4785                	li	a5,1
ffffffffc0200c90:	ef1c                	sd	a5,24(a4)
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200c92:	60a2                	ld	ra,8(sp)
ffffffffc0200c94:	6402                	ld	s0,0(sp)
ffffffffc0200c96:	0141                	addi	sp,sp,16
ffffffffc0200c98:	8082                	ret
        cprintf("Supervisor external interrupt\n");
ffffffffc0200c9a:	00005517          	auipc	a0,0x5
ffffffffc0200c9e:	3be50513          	addi	a0,a0,958 # ffffffffc0206058 <commands+0x5f8>
ffffffffc0200ca2:	cf2ff06f          	j	ffffffffc0200194 <cprintf>
        print_trapframe(tf);
ffffffffc0200ca6:	bdfd                	j	ffffffffc0200ba4 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200ca8:	06400593          	li	a1,100
ffffffffc0200cac:	00005517          	auipc	a0,0x5
ffffffffc0200cb0:	39c50513          	addi	a0,a0,924 # ffffffffc0206048 <commands+0x5e8>
ffffffffc0200cb4:	ce0ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
            num++; // 打印次数加一
ffffffffc0200cb8:	000aa717          	auipc	a4,0xaa
ffffffffc0200cbc:	b9070713          	addi	a4,a4,-1136 # ffffffffc02aa848 <num>
ffffffffc0200cc0:	431c                	lw	a5,0(a4)
            if (num == 10) {
ffffffffc0200cc2:	46a9                	li	a3,10
            num++; // 打印次数加一
ffffffffc0200cc4:	0017861b          	addiw	a2,a5,1
ffffffffc0200cc8:	c310                	sw	a2,0(a4)
            if (num == 10) {
ffffffffc0200cca:	fad618e3          	bne	a2,a3,ffffffffc0200c7a <interrupt_handler+0x74>
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200cce:	4501                	li	a0,0
ffffffffc0200cd0:	4581                	li	a1,0
ffffffffc0200cd2:	4601                	li	a2,0
ffffffffc0200cd4:	48a1                	li	a7,8
ffffffffc0200cd6:	00000073          	ecall
}
ffffffffc0200cda:	b745                	j	ffffffffc0200c7a <interrupt_handler+0x74>

ffffffffc0200cdc <exception_handler>:
void kernel_execve_ret(struct trapframe *tf, uintptr_t kstacktop);
void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
ffffffffc0200cdc:	11853783          	ld	a5,280(a0)
{
ffffffffc0200ce0:	1141                	addi	sp,sp,-16
ffffffffc0200ce2:	e022                	sd	s0,0(sp)
ffffffffc0200ce4:	e406                	sd	ra,8(sp)
ffffffffc0200ce6:	473d                	li	a4,15
ffffffffc0200ce8:	842a                	mv	s0,a0
ffffffffc0200cea:	0cf76463          	bltu	a4,a5,ffffffffc0200db2 <exception_handler+0xd6>
ffffffffc0200cee:	00005717          	auipc	a4,0x5
ffffffffc0200cf2:	54a70713          	addi	a4,a4,1354 # ffffffffc0206238 <commands+0x7d8>
ffffffffc0200cf6:	078a                	slli	a5,a5,0x2
ffffffffc0200cf8:	97ba                	add	a5,a5,a4
ffffffffc0200cfa:	439c                	lw	a5,0(a5)
ffffffffc0200cfc:	97ba                	add	a5,a5,a4
ffffffffc0200cfe:	8782                	jr	a5
        // cprintf("Environment call from U-mode\n");
        tf->epc += 4;
        syscall();
        break;
    case CAUSE_SUPERVISOR_ECALL:
        cprintf("Environment call from S-mode\n");
ffffffffc0200d00:	00005517          	auipc	a0,0x5
ffffffffc0200d04:	49050513          	addi	a0,a0,1168 # ffffffffc0206190 <commands+0x730>
ffffffffc0200d08:	c8cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        tf->epc += 4;
ffffffffc0200d0c:	10843783          	ld	a5,264(s0)
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200d10:	60a2                	ld	ra,8(sp)
        tf->epc += 4;
ffffffffc0200d12:	0791                	addi	a5,a5,4
ffffffffc0200d14:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200d18:	6402                	ld	s0,0(sp)
ffffffffc0200d1a:	0141                	addi	sp,sp,16
        syscall();
ffffffffc0200d1c:	58a0406f          	j	ffffffffc02052a6 <syscall>
        cprintf("Environment call from H-mode\n");
ffffffffc0200d20:	00005517          	auipc	a0,0x5
ffffffffc0200d24:	49050513          	addi	a0,a0,1168 # ffffffffc02061b0 <commands+0x750>
}
ffffffffc0200d28:	6402                	ld	s0,0(sp)
ffffffffc0200d2a:	60a2                	ld	ra,8(sp)
ffffffffc0200d2c:	0141                	addi	sp,sp,16
        cprintf("Instruction access fault\n");
ffffffffc0200d2e:	c66ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Environment call from M-mode\n");
ffffffffc0200d32:	00005517          	auipc	a0,0x5
ffffffffc0200d36:	49e50513          	addi	a0,a0,1182 # ffffffffc02061d0 <commands+0x770>
ffffffffc0200d3a:	b7fd                	j	ffffffffc0200d28 <exception_handler+0x4c>
        cprintf("Instruction page fault\n");
ffffffffc0200d3c:	00005517          	auipc	a0,0x5
ffffffffc0200d40:	4b450513          	addi	a0,a0,1204 # ffffffffc02061f0 <commands+0x790>
ffffffffc0200d44:	b7d5                	j	ffffffffc0200d28 <exception_handler+0x4c>
        cprintf("Load page fault\n");
ffffffffc0200d46:	00005517          	auipc	a0,0x5
ffffffffc0200d4a:	4c250513          	addi	a0,a0,1218 # ffffffffc0206208 <commands+0x7a8>
ffffffffc0200d4e:	bfe9                	j	ffffffffc0200d28 <exception_handler+0x4c>
        cprintf("Store/AMO page fault\n");
ffffffffc0200d50:	00005517          	auipc	a0,0x5
ffffffffc0200d54:	4d050513          	addi	a0,a0,1232 # ffffffffc0206220 <commands+0x7c0>
ffffffffc0200d58:	bfc1                	j	ffffffffc0200d28 <exception_handler+0x4c>
        cprintf("Instruction address misaligned\n");
ffffffffc0200d5a:	00005517          	auipc	a0,0x5
ffffffffc0200d5e:	34e50513          	addi	a0,a0,846 # ffffffffc02060a8 <commands+0x648>
ffffffffc0200d62:	b7d9                	j	ffffffffc0200d28 <exception_handler+0x4c>
        cprintf("Instruction access fault\n");
ffffffffc0200d64:	00005517          	auipc	a0,0x5
ffffffffc0200d68:	36450513          	addi	a0,a0,868 # ffffffffc02060c8 <commands+0x668>
ffffffffc0200d6c:	bf75                	j	ffffffffc0200d28 <exception_handler+0x4c>
        cprintf("Illegal instruction\n");
ffffffffc0200d6e:	00005517          	auipc	a0,0x5
ffffffffc0200d72:	37a50513          	addi	a0,a0,890 # ffffffffc02060e8 <commands+0x688>
ffffffffc0200d76:	bf4d                	j	ffffffffc0200d28 <exception_handler+0x4c>
        cprintf("Breakpoint\n");
ffffffffc0200d78:	00005517          	auipc	a0,0x5
ffffffffc0200d7c:	38850513          	addi	a0,a0,904 # ffffffffc0206100 <commands+0x6a0>
ffffffffc0200d80:	c14ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        if (tf->gpr.a7 == 10)
ffffffffc0200d84:	6458                	ld	a4,136(s0)
ffffffffc0200d86:	47a9                	li	a5,10
ffffffffc0200d88:	04f70663          	beq	a4,a5,ffffffffc0200dd4 <exception_handler+0xf8>
}
ffffffffc0200d8c:	60a2                	ld	ra,8(sp)
ffffffffc0200d8e:	6402                	ld	s0,0(sp)
ffffffffc0200d90:	0141                	addi	sp,sp,16
ffffffffc0200d92:	8082                	ret
        cprintf("Load address misaligned\n");
ffffffffc0200d94:	00005517          	auipc	a0,0x5
ffffffffc0200d98:	37c50513          	addi	a0,a0,892 # ffffffffc0206110 <commands+0x6b0>
ffffffffc0200d9c:	b771                	j	ffffffffc0200d28 <exception_handler+0x4c>
        cprintf("Load access fault\n");
ffffffffc0200d9e:	00005517          	auipc	a0,0x5
ffffffffc0200da2:	39250513          	addi	a0,a0,914 # ffffffffc0206130 <commands+0x6d0>
ffffffffc0200da6:	b749                	j	ffffffffc0200d28 <exception_handler+0x4c>
        cprintf("Store/AMO access fault\n");
ffffffffc0200da8:	00005517          	auipc	a0,0x5
ffffffffc0200dac:	3d050513          	addi	a0,a0,976 # ffffffffc0206178 <commands+0x718>
ffffffffc0200db0:	bfa5                	j	ffffffffc0200d28 <exception_handler+0x4c>
        print_trapframe(tf);
ffffffffc0200db2:	8522                	mv	a0,s0
}
ffffffffc0200db4:	6402                	ld	s0,0(sp)
ffffffffc0200db6:	60a2                	ld	ra,8(sp)
ffffffffc0200db8:	0141                	addi	sp,sp,16
        print_trapframe(tf);
ffffffffc0200dba:	b3ed                	j	ffffffffc0200ba4 <print_trapframe>
        panic("AMO address misaligned\n");
ffffffffc0200dbc:	00005617          	auipc	a2,0x5
ffffffffc0200dc0:	38c60613          	addi	a2,a2,908 # ffffffffc0206148 <commands+0x6e8>
ffffffffc0200dc4:	0c400593          	li	a1,196
ffffffffc0200dc8:	00005517          	auipc	a0,0x5
ffffffffc0200dcc:	39850513          	addi	a0,a0,920 # ffffffffc0206160 <commands+0x700>
ffffffffc0200dd0:	ebeff0ef          	jal	ra,ffffffffc020048e <__panic>
            tf->epc += 4;
ffffffffc0200dd4:	10843783          	ld	a5,264(s0)
ffffffffc0200dd8:	0791                	addi	a5,a5,4
ffffffffc0200dda:	10f43423          	sd	a5,264(s0)
            syscall();
ffffffffc0200dde:	4c8040ef          	jal	ra,ffffffffc02052a6 <syscall>
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200de2:	000aa797          	auipc	a5,0xaa
ffffffffc0200de6:	aa67b783          	ld	a5,-1370(a5) # ffffffffc02aa888 <current>
ffffffffc0200dea:	6b9c                	ld	a5,16(a5)
ffffffffc0200dec:	8522                	mv	a0,s0
}
ffffffffc0200dee:	6402                	ld	s0,0(sp)
ffffffffc0200df0:	60a2                	ld	ra,8(sp)
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200df2:	6589                	lui	a1,0x2
ffffffffc0200df4:	95be                	add	a1,a1,a5
}
ffffffffc0200df6:	0141                	addi	sp,sp,16
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200df8:	aaa9                	j	ffffffffc0200f52 <kernel_execve_ret>

ffffffffc0200dfa <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf)
{
ffffffffc0200dfa:	1101                	addi	sp,sp,-32
ffffffffc0200dfc:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
    //    cputs("some trap");
    if (current == NULL)
ffffffffc0200dfe:	000aa417          	auipc	s0,0xaa
ffffffffc0200e02:	a8a40413          	addi	s0,s0,-1398 # ffffffffc02aa888 <current>
ffffffffc0200e06:	6018                	ld	a4,0(s0)
{
ffffffffc0200e08:	ec06                	sd	ra,24(sp)
ffffffffc0200e0a:	e426                	sd	s1,8(sp)
ffffffffc0200e0c:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0)
ffffffffc0200e0e:	11853683          	ld	a3,280(a0)
    if (current == NULL)
ffffffffc0200e12:	cf1d                	beqz	a4,ffffffffc0200e50 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200e14:	10053483          	ld	s1,256(a0)
    {
        trap_dispatch(tf);
    }
    else
    {
        struct trapframe *otf = current->tf;
ffffffffc0200e18:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200e1c:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200e1e:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0)
ffffffffc0200e22:	0206c463          	bltz	a3,ffffffffc0200e4a <trap+0x50>
        exception_handler(tf);
ffffffffc0200e26:	eb7ff0ef          	jal	ra,ffffffffc0200cdc <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200e2a:	601c                	ld	a5,0(s0)
ffffffffc0200e2c:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel)
ffffffffc0200e30:	e499                	bnez	s1,ffffffffc0200e3e <trap+0x44>
        {
            if (current->flags & PF_EXITING)
ffffffffc0200e32:	0b07a703          	lw	a4,176(a5)
ffffffffc0200e36:	8b05                	andi	a4,a4,1
ffffffffc0200e38:	e329                	bnez	a4,ffffffffc0200e7a <trap+0x80>
            {
                do_exit(-E_KILLED);
            }
            if (current->need_resched)
ffffffffc0200e3a:	6f9c                	ld	a5,24(a5)
ffffffffc0200e3c:	eb85                	bnez	a5,ffffffffc0200e6c <trap+0x72>
            {
                schedule();
            }
        }
    }
}
ffffffffc0200e3e:	60e2                	ld	ra,24(sp)
ffffffffc0200e40:	6442                	ld	s0,16(sp)
ffffffffc0200e42:	64a2                	ld	s1,8(sp)
ffffffffc0200e44:	6902                	ld	s2,0(sp)
ffffffffc0200e46:	6105                	addi	sp,sp,32
ffffffffc0200e48:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200e4a:	dbdff0ef          	jal	ra,ffffffffc0200c06 <interrupt_handler>
ffffffffc0200e4e:	bff1                	j	ffffffffc0200e2a <trap+0x30>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200e50:	0006c863          	bltz	a3,ffffffffc0200e60 <trap+0x66>
}
ffffffffc0200e54:	6442                	ld	s0,16(sp)
ffffffffc0200e56:	60e2                	ld	ra,24(sp)
ffffffffc0200e58:	64a2                	ld	s1,8(sp)
ffffffffc0200e5a:	6902                	ld	s2,0(sp)
ffffffffc0200e5c:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200e5e:	bdbd                	j	ffffffffc0200cdc <exception_handler>
}
ffffffffc0200e60:	6442                	ld	s0,16(sp)
ffffffffc0200e62:	60e2                	ld	ra,24(sp)
ffffffffc0200e64:	64a2                	ld	s1,8(sp)
ffffffffc0200e66:	6902                	ld	s2,0(sp)
ffffffffc0200e68:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200e6a:	bb71                	j	ffffffffc0200c06 <interrupt_handler>
}
ffffffffc0200e6c:	6442                	ld	s0,16(sp)
ffffffffc0200e6e:	60e2                	ld	ra,24(sp)
ffffffffc0200e70:	64a2                	ld	s1,8(sp)
ffffffffc0200e72:	6902                	ld	s2,0(sp)
ffffffffc0200e74:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200e76:	3440406f          	j	ffffffffc02051ba <schedule>
                do_exit(-E_KILLED);
ffffffffc0200e7a:	555d                	li	a0,-9
ffffffffc0200e7c:	658030ef          	jal	ra,ffffffffc02044d4 <do_exit>
            if (current->need_resched)
ffffffffc0200e80:	601c                	ld	a5,0(s0)
ffffffffc0200e82:	bf65                	j	ffffffffc0200e3a <trap+0x40>

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
ffffffffc0200ef0:	f0bff0ef          	jal	ra,ffffffffc0200dfa <trap>

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
    j __trapret
ffffffffc0200f50:	b755                	j	ffffffffc0200ef4 <__trapret>

ffffffffc0200f52 <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200f52:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7ce0>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200f56:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200f5a:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200f5e:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200f62:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200f66:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200f6a:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200f6e:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200f72:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200f76:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200f78:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200f7a:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200f7c:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200f7e:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200f80:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200f82:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200f84:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200f86:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200f88:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200f8a:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200f8c:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200f8e:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200f90:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200f92:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200f94:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200f96:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200f98:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200f9a:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200f9c:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200f9e:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200fa0:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200fa2:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200fa4:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200fa6:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200fa8:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200faa:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200fac:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200fae:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200fb0:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200fb2:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200fb4:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200fb6:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200fb8:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200fba:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200fbc:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200fbe:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200fc0:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200fc2:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200fc4:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200fc6:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200fc8:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200fca:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200fcc:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200fce:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200fd0:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200fd2:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200fd4:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200fd6:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200fd8:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200fda:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200fdc:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200fde:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200fe0:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200fe2:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200fe4:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200fe6:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200fe8:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200fea:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200fec:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200fee:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200ff0:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200ff2:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200ff4:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200ff6:	812e                	mv	sp,a1
ffffffffc0200ff8:	bdf5                	j	ffffffffc0200ef4 <__trapret>

ffffffffc0200ffa <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200ffa:	000a5797          	auipc	a5,0xa5
ffffffffc0200ffe:	7fe78793          	addi	a5,a5,2046 # ffffffffc02a67f8 <free_area>
ffffffffc0201002:	e79c                	sd	a5,8(a5)
ffffffffc0201004:	e39c                	sd	a5,0(a5)

static void
default_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc0201006:	0007a823          	sw	zero,16(a5)
}
ffffffffc020100a:	8082                	ret

ffffffffc020100c <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc020100c:	000a5517          	auipc	a0,0xa5
ffffffffc0201010:	7fc56503          	lwu	a0,2044(a0) # ffffffffc02a6808 <free_area+0x10>
ffffffffc0201014:	8082                	ret

ffffffffc0201016 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
ffffffffc0201016:	715d                	addi	sp,sp,-80
ffffffffc0201018:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc020101a:	000a5417          	auipc	s0,0xa5
ffffffffc020101e:	7de40413          	addi	s0,s0,2014 # ffffffffc02a67f8 <free_area>
ffffffffc0201022:	641c                	ld	a5,8(s0)
ffffffffc0201024:	e486                	sd	ra,72(sp)
ffffffffc0201026:	fc26                	sd	s1,56(sp)
ffffffffc0201028:	f84a                	sd	s2,48(sp)
ffffffffc020102a:	f44e                	sd	s3,40(sp)
ffffffffc020102c:	f052                	sd	s4,32(sp)
ffffffffc020102e:	ec56                	sd	s5,24(sp)
ffffffffc0201030:	e85a                	sd	s6,16(sp)
ffffffffc0201032:	e45e                	sd	s7,8(sp)
ffffffffc0201034:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0201036:	2a878d63          	beq	a5,s0,ffffffffc02012f0 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc020103a:	4481                	li	s1,0
ffffffffc020103c:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020103e:	ff07b703          	ld	a4,-16(a5)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201042:	8b09                	andi	a4,a4,2
ffffffffc0201044:	2a070a63          	beqz	a4,ffffffffc02012f8 <default_check+0x2e2>
        count++, total += p->property;
ffffffffc0201048:	ff87a703          	lw	a4,-8(a5)
ffffffffc020104c:	679c                	ld	a5,8(a5)
ffffffffc020104e:	2905                	addiw	s2,s2,1
ffffffffc0201050:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0201052:	fe8796e3          	bne	a5,s0,ffffffffc020103e <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0201056:	89a6                	mv	s3,s1
ffffffffc0201058:	6df000ef          	jal	ra,ffffffffc0201f36 <nr_free_pages>
ffffffffc020105c:	6f351e63          	bne	a0,s3,ffffffffc0201758 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201060:	4505                	li	a0,1
ffffffffc0201062:	657000ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
ffffffffc0201066:	8aaa                	mv	s5,a0
ffffffffc0201068:	42050863          	beqz	a0,ffffffffc0201498 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020106c:	4505                	li	a0,1
ffffffffc020106e:	64b000ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
ffffffffc0201072:	89aa                	mv	s3,a0
ffffffffc0201074:	70050263          	beqz	a0,ffffffffc0201778 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201078:	4505                	li	a0,1
ffffffffc020107a:	63f000ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
ffffffffc020107e:	8a2a                	mv	s4,a0
ffffffffc0201080:	48050c63          	beqz	a0,ffffffffc0201518 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201084:	293a8a63          	beq	s5,s3,ffffffffc0201318 <default_check+0x302>
ffffffffc0201088:	28aa8863          	beq	s5,a0,ffffffffc0201318 <default_check+0x302>
ffffffffc020108c:	28a98663          	beq	s3,a0,ffffffffc0201318 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201090:	000aa783          	lw	a5,0(s5)
ffffffffc0201094:	2a079263          	bnez	a5,ffffffffc0201338 <default_check+0x322>
ffffffffc0201098:	0009a783          	lw	a5,0(s3)
ffffffffc020109c:	28079e63          	bnez	a5,ffffffffc0201338 <default_check+0x322>
ffffffffc02010a0:	411c                	lw	a5,0(a0)
ffffffffc02010a2:	28079b63          	bnez	a5,ffffffffc0201338 <default_check+0x322>
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page)
{
    return page - pages + nbase;
ffffffffc02010a6:	000a9797          	auipc	a5,0xa9
ffffffffc02010aa:	7ca7b783          	ld	a5,1994(a5) # ffffffffc02aa870 <pages>
ffffffffc02010ae:	40fa8733          	sub	a4,s5,a5
ffffffffc02010b2:	00007617          	auipc	a2,0x7
ffffffffc02010b6:	a3663603          	ld	a2,-1482(a2) # ffffffffc0207ae8 <nbase>
ffffffffc02010ba:	8719                	srai	a4,a4,0x6
ffffffffc02010bc:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02010be:	000a9697          	auipc	a3,0xa9
ffffffffc02010c2:	7aa6b683          	ld	a3,1962(a3) # ffffffffc02aa868 <npage>
ffffffffc02010c6:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page)
{
    return page2ppn(page) << PGSHIFT;
ffffffffc02010c8:	0732                	slli	a4,a4,0xc
ffffffffc02010ca:	28d77763          	bgeu	a4,a3,ffffffffc0201358 <default_check+0x342>
    return page - pages + nbase;
ffffffffc02010ce:	40f98733          	sub	a4,s3,a5
ffffffffc02010d2:	8719                	srai	a4,a4,0x6
ffffffffc02010d4:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02010d6:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02010d8:	4cd77063          	bgeu	a4,a3,ffffffffc0201598 <default_check+0x582>
    return page - pages + nbase;
ffffffffc02010dc:	40f507b3          	sub	a5,a0,a5
ffffffffc02010e0:	8799                	srai	a5,a5,0x6
ffffffffc02010e2:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02010e4:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02010e6:	30d7f963          	bgeu	a5,a3,ffffffffc02013f8 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc02010ea:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02010ec:	00043c03          	ld	s8,0(s0)
ffffffffc02010f0:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc02010f4:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc02010f8:	e400                	sd	s0,8(s0)
ffffffffc02010fa:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc02010fc:	000a5797          	auipc	a5,0xa5
ffffffffc0201100:	7007a623          	sw	zero,1804(a5) # ffffffffc02a6808 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201104:	5b5000ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
ffffffffc0201108:	2c051863          	bnez	a0,ffffffffc02013d8 <default_check+0x3c2>
    free_page(p0);
ffffffffc020110c:	4585                	li	a1,1
ffffffffc020110e:	8556                	mv	a0,s5
ffffffffc0201110:	5e7000ef          	jal	ra,ffffffffc0201ef6 <free_pages>
    free_page(p1);
ffffffffc0201114:	4585                	li	a1,1
ffffffffc0201116:	854e                	mv	a0,s3
ffffffffc0201118:	5df000ef          	jal	ra,ffffffffc0201ef6 <free_pages>
    free_page(p2);
ffffffffc020111c:	4585                	li	a1,1
ffffffffc020111e:	8552                	mv	a0,s4
ffffffffc0201120:	5d7000ef          	jal	ra,ffffffffc0201ef6 <free_pages>
    assert(nr_free == 3);
ffffffffc0201124:	4818                	lw	a4,16(s0)
ffffffffc0201126:	478d                	li	a5,3
ffffffffc0201128:	28f71863          	bne	a4,a5,ffffffffc02013b8 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020112c:	4505                	li	a0,1
ffffffffc020112e:	58b000ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
ffffffffc0201132:	89aa                	mv	s3,a0
ffffffffc0201134:	26050263          	beqz	a0,ffffffffc0201398 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201138:	4505                	li	a0,1
ffffffffc020113a:	57f000ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
ffffffffc020113e:	8aaa                	mv	s5,a0
ffffffffc0201140:	3a050c63          	beqz	a0,ffffffffc02014f8 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201144:	4505                	li	a0,1
ffffffffc0201146:	573000ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
ffffffffc020114a:	8a2a                	mv	s4,a0
ffffffffc020114c:	38050663          	beqz	a0,ffffffffc02014d8 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0201150:	4505                	li	a0,1
ffffffffc0201152:	567000ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
ffffffffc0201156:	36051163          	bnez	a0,ffffffffc02014b8 <default_check+0x4a2>
    free_page(p0);
ffffffffc020115a:	4585                	li	a1,1
ffffffffc020115c:	854e                	mv	a0,s3
ffffffffc020115e:	599000ef          	jal	ra,ffffffffc0201ef6 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0201162:	641c                	ld	a5,8(s0)
ffffffffc0201164:	20878a63          	beq	a5,s0,ffffffffc0201378 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0201168:	4505                	li	a0,1
ffffffffc020116a:	54f000ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
ffffffffc020116e:	30a99563          	bne	s3,a0,ffffffffc0201478 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0201172:	4505                	li	a0,1
ffffffffc0201174:	545000ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
ffffffffc0201178:	2e051063          	bnez	a0,ffffffffc0201458 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc020117c:	481c                	lw	a5,16(s0)
ffffffffc020117e:	2a079d63          	bnez	a5,ffffffffc0201438 <default_check+0x422>
    free_page(p);
ffffffffc0201182:	854e                	mv	a0,s3
ffffffffc0201184:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201186:	01843023          	sd	s8,0(s0)
ffffffffc020118a:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc020118e:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0201192:	565000ef          	jal	ra,ffffffffc0201ef6 <free_pages>
    free_page(p1);
ffffffffc0201196:	4585                	li	a1,1
ffffffffc0201198:	8556                	mv	a0,s5
ffffffffc020119a:	55d000ef          	jal	ra,ffffffffc0201ef6 <free_pages>
    free_page(p2);
ffffffffc020119e:	4585                	li	a1,1
ffffffffc02011a0:	8552                	mv	a0,s4
ffffffffc02011a2:	555000ef          	jal	ra,ffffffffc0201ef6 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02011a6:	4515                	li	a0,5
ffffffffc02011a8:	511000ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
ffffffffc02011ac:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02011ae:	26050563          	beqz	a0,ffffffffc0201418 <default_check+0x402>
ffffffffc02011b2:	651c                	ld	a5,8(a0)
ffffffffc02011b4:	8385                	srli	a5,a5,0x1
ffffffffc02011b6:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc02011b8:	54079063          	bnez	a5,ffffffffc02016f8 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02011bc:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02011be:	00043b03          	ld	s6,0(s0)
ffffffffc02011c2:	00843a83          	ld	s5,8(s0)
ffffffffc02011c6:	e000                	sd	s0,0(s0)
ffffffffc02011c8:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc02011ca:	4ef000ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
ffffffffc02011ce:	50051563          	bnez	a0,ffffffffc02016d8 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02011d2:	08098a13          	addi	s4,s3,128
ffffffffc02011d6:	8552                	mv	a0,s4
ffffffffc02011d8:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02011da:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc02011de:	000a5797          	auipc	a5,0xa5
ffffffffc02011e2:	6207a523          	sw	zero,1578(a5) # ffffffffc02a6808 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02011e6:	511000ef          	jal	ra,ffffffffc0201ef6 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02011ea:	4511                	li	a0,4
ffffffffc02011ec:	4cd000ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
ffffffffc02011f0:	4c051463          	bnez	a0,ffffffffc02016b8 <default_check+0x6a2>
ffffffffc02011f4:	0889b783          	ld	a5,136(s3)
ffffffffc02011f8:	8385                	srli	a5,a5,0x1
ffffffffc02011fa:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02011fc:	48078e63          	beqz	a5,ffffffffc0201698 <default_check+0x682>
ffffffffc0201200:	0909a703          	lw	a4,144(s3)
ffffffffc0201204:	478d                	li	a5,3
ffffffffc0201206:	48f71963          	bne	a4,a5,ffffffffc0201698 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020120a:	450d                	li	a0,3
ffffffffc020120c:	4ad000ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
ffffffffc0201210:	8c2a                	mv	s8,a0
ffffffffc0201212:	46050363          	beqz	a0,ffffffffc0201678 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0201216:	4505                	li	a0,1
ffffffffc0201218:	4a1000ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
ffffffffc020121c:	42051e63          	bnez	a0,ffffffffc0201658 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0201220:	418a1c63          	bne	s4,s8,ffffffffc0201638 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201224:	4585                	li	a1,1
ffffffffc0201226:	854e                	mv	a0,s3
ffffffffc0201228:	4cf000ef          	jal	ra,ffffffffc0201ef6 <free_pages>
    free_pages(p1, 3);
ffffffffc020122c:	458d                	li	a1,3
ffffffffc020122e:	8552                	mv	a0,s4
ffffffffc0201230:	4c7000ef          	jal	ra,ffffffffc0201ef6 <free_pages>
ffffffffc0201234:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201238:	04098c13          	addi	s8,s3,64
ffffffffc020123c:	8385                	srli	a5,a5,0x1
ffffffffc020123e:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201240:	3c078c63          	beqz	a5,ffffffffc0201618 <default_check+0x602>
ffffffffc0201244:	0109a703          	lw	a4,16(s3)
ffffffffc0201248:	4785                	li	a5,1
ffffffffc020124a:	3cf71763          	bne	a4,a5,ffffffffc0201618 <default_check+0x602>
ffffffffc020124e:	008a3783          	ld	a5,8(s4)
ffffffffc0201252:	8385                	srli	a5,a5,0x1
ffffffffc0201254:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201256:	3a078163          	beqz	a5,ffffffffc02015f8 <default_check+0x5e2>
ffffffffc020125a:	010a2703          	lw	a4,16(s4)
ffffffffc020125e:	478d                	li	a5,3
ffffffffc0201260:	38f71c63          	bne	a4,a5,ffffffffc02015f8 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201264:	4505                	li	a0,1
ffffffffc0201266:	453000ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
ffffffffc020126a:	36a99763          	bne	s3,a0,ffffffffc02015d8 <default_check+0x5c2>
    free_page(p0);
ffffffffc020126e:	4585                	li	a1,1
ffffffffc0201270:	487000ef          	jal	ra,ffffffffc0201ef6 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201274:	4509                	li	a0,2
ffffffffc0201276:	443000ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
ffffffffc020127a:	32aa1f63          	bne	s4,a0,ffffffffc02015b8 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc020127e:	4589                	li	a1,2
ffffffffc0201280:	477000ef          	jal	ra,ffffffffc0201ef6 <free_pages>
    free_page(p2);
ffffffffc0201284:	4585                	li	a1,1
ffffffffc0201286:	8562                	mv	a0,s8
ffffffffc0201288:	46f000ef          	jal	ra,ffffffffc0201ef6 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020128c:	4515                	li	a0,5
ffffffffc020128e:	42b000ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
ffffffffc0201292:	89aa                	mv	s3,a0
ffffffffc0201294:	48050263          	beqz	a0,ffffffffc0201718 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc0201298:	4505                	li	a0,1
ffffffffc020129a:	41f000ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
ffffffffc020129e:	2c051d63          	bnez	a0,ffffffffc0201578 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc02012a2:	481c                	lw	a5,16(s0)
ffffffffc02012a4:	2a079a63          	bnez	a5,ffffffffc0201558 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02012a8:	4595                	li	a1,5
ffffffffc02012aa:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02012ac:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02012b0:	01643023          	sd	s6,0(s0)
ffffffffc02012b4:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc02012b8:	43f000ef          	jal	ra,ffffffffc0201ef6 <free_pages>
    return listelm->next;
ffffffffc02012bc:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc02012be:	00878963          	beq	a5,s0,ffffffffc02012d0 <default_check+0x2ba>
    {
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc02012c2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02012c6:	679c                	ld	a5,8(a5)
ffffffffc02012c8:	397d                	addiw	s2,s2,-1
ffffffffc02012ca:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc02012cc:	fe879be3          	bne	a5,s0,ffffffffc02012c2 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc02012d0:	26091463          	bnez	s2,ffffffffc0201538 <default_check+0x522>
    assert(total == 0);
ffffffffc02012d4:	46049263          	bnez	s1,ffffffffc0201738 <default_check+0x722>
}
ffffffffc02012d8:	60a6                	ld	ra,72(sp)
ffffffffc02012da:	6406                	ld	s0,64(sp)
ffffffffc02012dc:	74e2                	ld	s1,56(sp)
ffffffffc02012de:	7942                	ld	s2,48(sp)
ffffffffc02012e0:	79a2                	ld	s3,40(sp)
ffffffffc02012e2:	7a02                	ld	s4,32(sp)
ffffffffc02012e4:	6ae2                	ld	s5,24(sp)
ffffffffc02012e6:	6b42                	ld	s6,16(sp)
ffffffffc02012e8:	6ba2                	ld	s7,8(sp)
ffffffffc02012ea:	6c02                	ld	s8,0(sp)
ffffffffc02012ec:	6161                	addi	sp,sp,80
ffffffffc02012ee:	8082                	ret
    while ((le = list_next(le)) != &free_list)
ffffffffc02012f0:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02012f2:	4481                	li	s1,0
ffffffffc02012f4:	4901                	li	s2,0
ffffffffc02012f6:	b38d                	j	ffffffffc0201058 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc02012f8:	00005697          	auipc	a3,0x5
ffffffffc02012fc:	f8068693          	addi	a3,a3,-128 # ffffffffc0206278 <commands+0x818>
ffffffffc0201300:	00005617          	auipc	a2,0x5
ffffffffc0201304:	f8860613          	addi	a2,a2,-120 # ffffffffc0206288 <commands+0x828>
ffffffffc0201308:	11000593          	li	a1,272
ffffffffc020130c:	00005517          	auipc	a0,0x5
ffffffffc0201310:	f9450513          	addi	a0,a0,-108 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201314:	97aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201318:	00005697          	auipc	a3,0x5
ffffffffc020131c:	02068693          	addi	a3,a3,32 # ffffffffc0206338 <commands+0x8d8>
ffffffffc0201320:	00005617          	auipc	a2,0x5
ffffffffc0201324:	f6860613          	addi	a2,a2,-152 # ffffffffc0206288 <commands+0x828>
ffffffffc0201328:	0db00593          	li	a1,219
ffffffffc020132c:	00005517          	auipc	a0,0x5
ffffffffc0201330:	f7450513          	addi	a0,a0,-140 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201334:	95aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201338:	00005697          	auipc	a3,0x5
ffffffffc020133c:	02868693          	addi	a3,a3,40 # ffffffffc0206360 <commands+0x900>
ffffffffc0201340:	00005617          	auipc	a2,0x5
ffffffffc0201344:	f4860613          	addi	a2,a2,-184 # ffffffffc0206288 <commands+0x828>
ffffffffc0201348:	0dc00593          	li	a1,220
ffffffffc020134c:	00005517          	auipc	a0,0x5
ffffffffc0201350:	f5450513          	addi	a0,a0,-172 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201354:	93aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201358:	00005697          	auipc	a3,0x5
ffffffffc020135c:	04868693          	addi	a3,a3,72 # ffffffffc02063a0 <commands+0x940>
ffffffffc0201360:	00005617          	auipc	a2,0x5
ffffffffc0201364:	f2860613          	addi	a2,a2,-216 # ffffffffc0206288 <commands+0x828>
ffffffffc0201368:	0de00593          	li	a1,222
ffffffffc020136c:	00005517          	auipc	a0,0x5
ffffffffc0201370:	f3450513          	addi	a0,a0,-204 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201374:	91aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201378:	00005697          	auipc	a3,0x5
ffffffffc020137c:	0b068693          	addi	a3,a3,176 # ffffffffc0206428 <commands+0x9c8>
ffffffffc0201380:	00005617          	auipc	a2,0x5
ffffffffc0201384:	f0860613          	addi	a2,a2,-248 # ffffffffc0206288 <commands+0x828>
ffffffffc0201388:	0f700593          	li	a1,247
ffffffffc020138c:	00005517          	auipc	a0,0x5
ffffffffc0201390:	f1450513          	addi	a0,a0,-236 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201394:	8faff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201398:	00005697          	auipc	a3,0x5
ffffffffc020139c:	f4068693          	addi	a3,a3,-192 # ffffffffc02062d8 <commands+0x878>
ffffffffc02013a0:	00005617          	auipc	a2,0x5
ffffffffc02013a4:	ee860613          	addi	a2,a2,-280 # ffffffffc0206288 <commands+0x828>
ffffffffc02013a8:	0f000593          	li	a1,240
ffffffffc02013ac:	00005517          	auipc	a0,0x5
ffffffffc02013b0:	ef450513          	addi	a0,a0,-268 # ffffffffc02062a0 <commands+0x840>
ffffffffc02013b4:	8daff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free == 3);
ffffffffc02013b8:	00005697          	auipc	a3,0x5
ffffffffc02013bc:	06068693          	addi	a3,a3,96 # ffffffffc0206418 <commands+0x9b8>
ffffffffc02013c0:	00005617          	auipc	a2,0x5
ffffffffc02013c4:	ec860613          	addi	a2,a2,-312 # ffffffffc0206288 <commands+0x828>
ffffffffc02013c8:	0ee00593          	li	a1,238
ffffffffc02013cc:	00005517          	auipc	a0,0x5
ffffffffc02013d0:	ed450513          	addi	a0,a0,-300 # ffffffffc02062a0 <commands+0x840>
ffffffffc02013d4:	8baff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013d8:	00005697          	auipc	a3,0x5
ffffffffc02013dc:	02868693          	addi	a3,a3,40 # ffffffffc0206400 <commands+0x9a0>
ffffffffc02013e0:	00005617          	auipc	a2,0x5
ffffffffc02013e4:	ea860613          	addi	a2,a2,-344 # ffffffffc0206288 <commands+0x828>
ffffffffc02013e8:	0e900593          	li	a1,233
ffffffffc02013ec:	00005517          	auipc	a0,0x5
ffffffffc02013f0:	eb450513          	addi	a0,a0,-332 # ffffffffc02062a0 <commands+0x840>
ffffffffc02013f4:	89aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02013f8:	00005697          	auipc	a3,0x5
ffffffffc02013fc:	fe868693          	addi	a3,a3,-24 # ffffffffc02063e0 <commands+0x980>
ffffffffc0201400:	00005617          	auipc	a2,0x5
ffffffffc0201404:	e8860613          	addi	a2,a2,-376 # ffffffffc0206288 <commands+0x828>
ffffffffc0201408:	0e000593          	li	a1,224
ffffffffc020140c:	00005517          	auipc	a0,0x5
ffffffffc0201410:	e9450513          	addi	a0,a0,-364 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201414:	87aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(p0 != NULL);
ffffffffc0201418:	00005697          	auipc	a3,0x5
ffffffffc020141c:	05868693          	addi	a3,a3,88 # ffffffffc0206470 <commands+0xa10>
ffffffffc0201420:	00005617          	auipc	a2,0x5
ffffffffc0201424:	e6860613          	addi	a2,a2,-408 # ffffffffc0206288 <commands+0x828>
ffffffffc0201428:	11800593          	li	a1,280
ffffffffc020142c:	00005517          	auipc	a0,0x5
ffffffffc0201430:	e7450513          	addi	a0,a0,-396 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201434:	85aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free == 0);
ffffffffc0201438:	00005697          	auipc	a3,0x5
ffffffffc020143c:	02868693          	addi	a3,a3,40 # ffffffffc0206460 <commands+0xa00>
ffffffffc0201440:	00005617          	auipc	a2,0x5
ffffffffc0201444:	e4860613          	addi	a2,a2,-440 # ffffffffc0206288 <commands+0x828>
ffffffffc0201448:	0fd00593          	li	a1,253
ffffffffc020144c:	00005517          	auipc	a0,0x5
ffffffffc0201450:	e5450513          	addi	a0,a0,-428 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201454:	83aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201458:	00005697          	auipc	a3,0x5
ffffffffc020145c:	fa868693          	addi	a3,a3,-88 # ffffffffc0206400 <commands+0x9a0>
ffffffffc0201460:	00005617          	auipc	a2,0x5
ffffffffc0201464:	e2860613          	addi	a2,a2,-472 # ffffffffc0206288 <commands+0x828>
ffffffffc0201468:	0fb00593          	li	a1,251
ffffffffc020146c:	00005517          	auipc	a0,0x5
ffffffffc0201470:	e3450513          	addi	a0,a0,-460 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201474:	81aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201478:	00005697          	auipc	a3,0x5
ffffffffc020147c:	fc868693          	addi	a3,a3,-56 # ffffffffc0206440 <commands+0x9e0>
ffffffffc0201480:	00005617          	auipc	a2,0x5
ffffffffc0201484:	e0860613          	addi	a2,a2,-504 # ffffffffc0206288 <commands+0x828>
ffffffffc0201488:	0fa00593          	li	a1,250
ffffffffc020148c:	00005517          	auipc	a0,0x5
ffffffffc0201490:	e1450513          	addi	a0,a0,-492 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201494:	ffbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201498:	00005697          	auipc	a3,0x5
ffffffffc020149c:	e4068693          	addi	a3,a3,-448 # ffffffffc02062d8 <commands+0x878>
ffffffffc02014a0:	00005617          	auipc	a2,0x5
ffffffffc02014a4:	de860613          	addi	a2,a2,-536 # ffffffffc0206288 <commands+0x828>
ffffffffc02014a8:	0d700593          	li	a1,215
ffffffffc02014ac:	00005517          	auipc	a0,0x5
ffffffffc02014b0:	df450513          	addi	a0,a0,-524 # ffffffffc02062a0 <commands+0x840>
ffffffffc02014b4:	fdbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014b8:	00005697          	auipc	a3,0x5
ffffffffc02014bc:	f4868693          	addi	a3,a3,-184 # ffffffffc0206400 <commands+0x9a0>
ffffffffc02014c0:	00005617          	auipc	a2,0x5
ffffffffc02014c4:	dc860613          	addi	a2,a2,-568 # ffffffffc0206288 <commands+0x828>
ffffffffc02014c8:	0f400593          	li	a1,244
ffffffffc02014cc:	00005517          	auipc	a0,0x5
ffffffffc02014d0:	dd450513          	addi	a0,a0,-556 # ffffffffc02062a0 <commands+0x840>
ffffffffc02014d4:	fbbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02014d8:	00005697          	auipc	a3,0x5
ffffffffc02014dc:	e4068693          	addi	a3,a3,-448 # ffffffffc0206318 <commands+0x8b8>
ffffffffc02014e0:	00005617          	auipc	a2,0x5
ffffffffc02014e4:	da860613          	addi	a2,a2,-600 # ffffffffc0206288 <commands+0x828>
ffffffffc02014e8:	0f200593          	li	a1,242
ffffffffc02014ec:	00005517          	auipc	a0,0x5
ffffffffc02014f0:	db450513          	addi	a0,a0,-588 # ffffffffc02062a0 <commands+0x840>
ffffffffc02014f4:	f9bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02014f8:	00005697          	auipc	a3,0x5
ffffffffc02014fc:	e0068693          	addi	a3,a3,-512 # ffffffffc02062f8 <commands+0x898>
ffffffffc0201500:	00005617          	auipc	a2,0x5
ffffffffc0201504:	d8860613          	addi	a2,a2,-632 # ffffffffc0206288 <commands+0x828>
ffffffffc0201508:	0f100593          	li	a1,241
ffffffffc020150c:	00005517          	auipc	a0,0x5
ffffffffc0201510:	d9450513          	addi	a0,a0,-620 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201514:	f7bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201518:	00005697          	auipc	a3,0x5
ffffffffc020151c:	e0068693          	addi	a3,a3,-512 # ffffffffc0206318 <commands+0x8b8>
ffffffffc0201520:	00005617          	auipc	a2,0x5
ffffffffc0201524:	d6860613          	addi	a2,a2,-664 # ffffffffc0206288 <commands+0x828>
ffffffffc0201528:	0d900593          	li	a1,217
ffffffffc020152c:	00005517          	auipc	a0,0x5
ffffffffc0201530:	d7450513          	addi	a0,a0,-652 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201534:	f5bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(count == 0);
ffffffffc0201538:	00005697          	auipc	a3,0x5
ffffffffc020153c:	08868693          	addi	a3,a3,136 # ffffffffc02065c0 <commands+0xb60>
ffffffffc0201540:	00005617          	auipc	a2,0x5
ffffffffc0201544:	d4860613          	addi	a2,a2,-696 # ffffffffc0206288 <commands+0x828>
ffffffffc0201548:	14600593          	li	a1,326
ffffffffc020154c:	00005517          	auipc	a0,0x5
ffffffffc0201550:	d5450513          	addi	a0,a0,-684 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201554:	f3bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free == 0);
ffffffffc0201558:	00005697          	auipc	a3,0x5
ffffffffc020155c:	f0868693          	addi	a3,a3,-248 # ffffffffc0206460 <commands+0xa00>
ffffffffc0201560:	00005617          	auipc	a2,0x5
ffffffffc0201564:	d2860613          	addi	a2,a2,-728 # ffffffffc0206288 <commands+0x828>
ffffffffc0201568:	13a00593          	li	a1,314
ffffffffc020156c:	00005517          	auipc	a0,0x5
ffffffffc0201570:	d3450513          	addi	a0,a0,-716 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201574:	f1bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201578:	00005697          	auipc	a3,0x5
ffffffffc020157c:	e8868693          	addi	a3,a3,-376 # ffffffffc0206400 <commands+0x9a0>
ffffffffc0201580:	00005617          	auipc	a2,0x5
ffffffffc0201584:	d0860613          	addi	a2,a2,-760 # ffffffffc0206288 <commands+0x828>
ffffffffc0201588:	13800593          	li	a1,312
ffffffffc020158c:	00005517          	auipc	a0,0x5
ffffffffc0201590:	d1450513          	addi	a0,a0,-748 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201594:	efbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201598:	00005697          	auipc	a3,0x5
ffffffffc020159c:	e2868693          	addi	a3,a3,-472 # ffffffffc02063c0 <commands+0x960>
ffffffffc02015a0:	00005617          	auipc	a2,0x5
ffffffffc02015a4:	ce860613          	addi	a2,a2,-792 # ffffffffc0206288 <commands+0x828>
ffffffffc02015a8:	0df00593          	li	a1,223
ffffffffc02015ac:	00005517          	auipc	a0,0x5
ffffffffc02015b0:	cf450513          	addi	a0,a0,-780 # ffffffffc02062a0 <commands+0x840>
ffffffffc02015b4:	edbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02015b8:	00005697          	auipc	a3,0x5
ffffffffc02015bc:	fc868693          	addi	a3,a3,-56 # ffffffffc0206580 <commands+0xb20>
ffffffffc02015c0:	00005617          	auipc	a2,0x5
ffffffffc02015c4:	cc860613          	addi	a2,a2,-824 # ffffffffc0206288 <commands+0x828>
ffffffffc02015c8:	13200593          	li	a1,306
ffffffffc02015cc:	00005517          	auipc	a0,0x5
ffffffffc02015d0:	cd450513          	addi	a0,a0,-812 # ffffffffc02062a0 <commands+0x840>
ffffffffc02015d4:	ebbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02015d8:	00005697          	auipc	a3,0x5
ffffffffc02015dc:	f8868693          	addi	a3,a3,-120 # ffffffffc0206560 <commands+0xb00>
ffffffffc02015e0:	00005617          	auipc	a2,0x5
ffffffffc02015e4:	ca860613          	addi	a2,a2,-856 # ffffffffc0206288 <commands+0x828>
ffffffffc02015e8:	13000593          	li	a1,304
ffffffffc02015ec:	00005517          	auipc	a0,0x5
ffffffffc02015f0:	cb450513          	addi	a0,a0,-844 # ffffffffc02062a0 <commands+0x840>
ffffffffc02015f4:	e9bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02015f8:	00005697          	auipc	a3,0x5
ffffffffc02015fc:	f4068693          	addi	a3,a3,-192 # ffffffffc0206538 <commands+0xad8>
ffffffffc0201600:	00005617          	auipc	a2,0x5
ffffffffc0201604:	c8860613          	addi	a2,a2,-888 # ffffffffc0206288 <commands+0x828>
ffffffffc0201608:	12e00593          	li	a1,302
ffffffffc020160c:	00005517          	auipc	a0,0x5
ffffffffc0201610:	c9450513          	addi	a0,a0,-876 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201614:	e7bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201618:	00005697          	auipc	a3,0x5
ffffffffc020161c:	ef868693          	addi	a3,a3,-264 # ffffffffc0206510 <commands+0xab0>
ffffffffc0201620:	00005617          	auipc	a2,0x5
ffffffffc0201624:	c6860613          	addi	a2,a2,-920 # ffffffffc0206288 <commands+0x828>
ffffffffc0201628:	12d00593          	li	a1,301
ffffffffc020162c:	00005517          	auipc	a0,0x5
ffffffffc0201630:	c7450513          	addi	a0,a0,-908 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201634:	e5bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201638:	00005697          	auipc	a3,0x5
ffffffffc020163c:	ec868693          	addi	a3,a3,-312 # ffffffffc0206500 <commands+0xaa0>
ffffffffc0201640:	00005617          	auipc	a2,0x5
ffffffffc0201644:	c4860613          	addi	a2,a2,-952 # ffffffffc0206288 <commands+0x828>
ffffffffc0201648:	12800593          	li	a1,296
ffffffffc020164c:	00005517          	auipc	a0,0x5
ffffffffc0201650:	c5450513          	addi	a0,a0,-940 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201654:	e3bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201658:	00005697          	auipc	a3,0x5
ffffffffc020165c:	da868693          	addi	a3,a3,-600 # ffffffffc0206400 <commands+0x9a0>
ffffffffc0201660:	00005617          	auipc	a2,0x5
ffffffffc0201664:	c2860613          	addi	a2,a2,-984 # ffffffffc0206288 <commands+0x828>
ffffffffc0201668:	12700593          	li	a1,295
ffffffffc020166c:	00005517          	auipc	a0,0x5
ffffffffc0201670:	c3450513          	addi	a0,a0,-972 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201674:	e1bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201678:	00005697          	auipc	a3,0x5
ffffffffc020167c:	e6868693          	addi	a3,a3,-408 # ffffffffc02064e0 <commands+0xa80>
ffffffffc0201680:	00005617          	auipc	a2,0x5
ffffffffc0201684:	c0860613          	addi	a2,a2,-1016 # ffffffffc0206288 <commands+0x828>
ffffffffc0201688:	12600593          	li	a1,294
ffffffffc020168c:	00005517          	auipc	a0,0x5
ffffffffc0201690:	c1450513          	addi	a0,a0,-1004 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201694:	dfbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201698:	00005697          	auipc	a3,0x5
ffffffffc020169c:	e1868693          	addi	a3,a3,-488 # ffffffffc02064b0 <commands+0xa50>
ffffffffc02016a0:	00005617          	auipc	a2,0x5
ffffffffc02016a4:	be860613          	addi	a2,a2,-1048 # ffffffffc0206288 <commands+0x828>
ffffffffc02016a8:	12500593          	li	a1,293
ffffffffc02016ac:	00005517          	auipc	a0,0x5
ffffffffc02016b0:	bf450513          	addi	a0,a0,-1036 # ffffffffc02062a0 <commands+0x840>
ffffffffc02016b4:	ddbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02016b8:	00005697          	auipc	a3,0x5
ffffffffc02016bc:	de068693          	addi	a3,a3,-544 # ffffffffc0206498 <commands+0xa38>
ffffffffc02016c0:	00005617          	auipc	a2,0x5
ffffffffc02016c4:	bc860613          	addi	a2,a2,-1080 # ffffffffc0206288 <commands+0x828>
ffffffffc02016c8:	12400593          	li	a1,292
ffffffffc02016cc:	00005517          	auipc	a0,0x5
ffffffffc02016d0:	bd450513          	addi	a0,a0,-1068 # ffffffffc02062a0 <commands+0x840>
ffffffffc02016d4:	dbbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02016d8:	00005697          	auipc	a3,0x5
ffffffffc02016dc:	d2868693          	addi	a3,a3,-728 # ffffffffc0206400 <commands+0x9a0>
ffffffffc02016e0:	00005617          	auipc	a2,0x5
ffffffffc02016e4:	ba860613          	addi	a2,a2,-1112 # ffffffffc0206288 <commands+0x828>
ffffffffc02016e8:	11e00593          	li	a1,286
ffffffffc02016ec:	00005517          	auipc	a0,0x5
ffffffffc02016f0:	bb450513          	addi	a0,a0,-1100 # ffffffffc02062a0 <commands+0x840>
ffffffffc02016f4:	d9bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(!PageProperty(p0));
ffffffffc02016f8:	00005697          	auipc	a3,0x5
ffffffffc02016fc:	d8868693          	addi	a3,a3,-632 # ffffffffc0206480 <commands+0xa20>
ffffffffc0201700:	00005617          	auipc	a2,0x5
ffffffffc0201704:	b8860613          	addi	a2,a2,-1144 # ffffffffc0206288 <commands+0x828>
ffffffffc0201708:	11900593          	li	a1,281
ffffffffc020170c:	00005517          	auipc	a0,0x5
ffffffffc0201710:	b9450513          	addi	a0,a0,-1132 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201714:	d7bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201718:	00005697          	auipc	a3,0x5
ffffffffc020171c:	e8868693          	addi	a3,a3,-376 # ffffffffc02065a0 <commands+0xb40>
ffffffffc0201720:	00005617          	auipc	a2,0x5
ffffffffc0201724:	b6860613          	addi	a2,a2,-1176 # ffffffffc0206288 <commands+0x828>
ffffffffc0201728:	13700593          	li	a1,311
ffffffffc020172c:	00005517          	auipc	a0,0x5
ffffffffc0201730:	b7450513          	addi	a0,a0,-1164 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201734:	d5bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(total == 0);
ffffffffc0201738:	00005697          	auipc	a3,0x5
ffffffffc020173c:	e9868693          	addi	a3,a3,-360 # ffffffffc02065d0 <commands+0xb70>
ffffffffc0201740:	00005617          	auipc	a2,0x5
ffffffffc0201744:	b4860613          	addi	a2,a2,-1208 # ffffffffc0206288 <commands+0x828>
ffffffffc0201748:	14700593          	li	a1,327
ffffffffc020174c:	00005517          	auipc	a0,0x5
ffffffffc0201750:	b5450513          	addi	a0,a0,-1196 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201754:	d3bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(total == nr_free_pages());
ffffffffc0201758:	00005697          	auipc	a3,0x5
ffffffffc020175c:	b6068693          	addi	a3,a3,-1184 # ffffffffc02062b8 <commands+0x858>
ffffffffc0201760:	00005617          	auipc	a2,0x5
ffffffffc0201764:	b2860613          	addi	a2,a2,-1240 # ffffffffc0206288 <commands+0x828>
ffffffffc0201768:	11300593          	li	a1,275
ffffffffc020176c:	00005517          	auipc	a0,0x5
ffffffffc0201770:	b3450513          	addi	a0,a0,-1228 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201774:	d1bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201778:	00005697          	auipc	a3,0x5
ffffffffc020177c:	b8068693          	addi	a3,a3,-1152 # ffffffffc02062f8 <commands+0x898>
ffffffffc0201780:	00005617          	auipc	a2,0x5
ffffffffc0201784:	b0860613          	addi	a2,a2,-1272 # ffffffffc0206288 <commands+0x828>
ffffffffc0201788:	0d800593          	li	a1,216
ffffffffc020178c:	00005517          	auipc	a0,0x5
ffffffffc0201790:	b1450513          	addi	a0,a0,-1260 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201794:	cfbfe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201798 <default_free_pages>:
{
ffffffffc0201798:	1141                	addi	sp,sp,-16
ffffffffc020179a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020179c:	14058463          	beqz	a1,ffffffffc02018e4 <default_free_pages+0x14c>
    for (; p != base + n; p++)
ffffffffc02017a0:	00659693          	slli	a3,a1,0x6
ffffffffc02017a4:	96aa                	add	a3,a3,a0
ffffffffc02017a6:	87aa                	mv	a5,a0
ffffffffc02017a8:	02d50263          	beq	a0,a3,ffffffffc02017cc <default_free_pages+0x34>
ffffffffc02017ac:	6798                	ld	a4,8(a5)
ffffffffc02017ae:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02017b0:	10071a63          	bnez	a4,ffffffffc02018c4 <default_free_pages+0x12c>
ffffffffc02017b4:	6798                	ld	a4,8(a5)
ffffffffc02017b6:	8b09                	andi	a4,a4,2
ffffffffc02017b8:	10071663          	bnez	a4,ffffffffc02018c4 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc02017bc:	0007b423          	sd	zero,8(a5)
}

static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
ffffffffc02017c0:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02017c4:	04078793          	addi	a5,a5,64
ffffffffc02017c8:	fed792e3          	bne	a5,a3,ffffffffc02017ac <default_free_pages+0x14>
    base->property = n;
ffffffffc02017cc:	2581                	sext.w	a1,a1
ffffffffc02017ce:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02017d0:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02017d4:	4789                	li	a5,2
ffffffffc02017d6:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02017da:	000a5697          	auipc	a3,0xa5
ffffffffc02017de:	01e68693          	addi	a3,a3,30 # ffffffffc02a67f8 <free_area>
ffffffffc02017e2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02017e4:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02017e6:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02017ea:	9db9                	addw	a1,a1,a4
ffffffffc02017ec:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc02017ee:	0ad78463          	beq	a5,a3,ffffffffc0201896 <default_free_pages+0xfe>
            struct Page *page = le2page(le, page_link);
ffffffffc02017f2:	fe878713          	addi	a4,a5,-24
ffffffffc02017f6:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc02017fa:	4581                	li	a1,0
            if (base < page)
ffffffffc02017fc:	00e56a63          	bltu	a0,a4,ffffffffc0201810 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0201800:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc0201802:	04d70c63          	beq	a4,a3,ffffffffc020185a <default_free_pages+0xc2>
    for (; p != base + n; p++)
ffffffffc0201806:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0201808:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc020180c:	fee57ae3          	bgeu	a0,a4,ffffffffc0201800 <default_free_pages+0x68>
ffffffffc0201810:	c199                	beqz	a1,ffffffffc0201816 <default_free_pages+0x7e>
ffffffffc0201812:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201816:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201818:	e390                	sd	a2,0(a5)
ffffffffc020181a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020181c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020181e:	ed18                	sd	a4,24(a0)
    if (le != &free_list)
ffffffffc0201820:	00d70d63          	beq	a4,a3,ffffffffc020183a <default_free_pages+0xa2>
        if (p + p->property == base)
ffffffffc0201824:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201828:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base)
ffffffffc020182c:	02059813          	slli	a6,a1,0x20
ffffffffc0201830:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201834:	97b2                	add	a5,a5,a2
ffffffffc0201836:	02f50c63          	beq	a0,a5,ffffffffc020186e <default_free_pages+0xd6>
    return listelm->next;
ffffffffc020183a:	711c                	ld	a5,32(a0)
    if (le != &free_list)
ffffffffc020183c:	00d78c63          	beq	a5,a3,ffffffffc0201854 <default_free_pages+0xbc>
        if (base + base->property == p)
ffffffffc0201840:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0201842:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p)
ffffffffc0201846:	02061593          	slli	a1,a2,0x20
ffffffffc020184a:	01a5d713          	srli	a4,a1,0x1a
ffffffffc020184e:	972a                	add	a4,a4,a0
ffffffffc0201850:	04e68a63          	beq	a3,a4,ffffffffc02018a4 <default_free_pages+0x10c>
}
ffffffffc0201854:	60a2                	ld	ra,8(sp)
ffffffffc0201856:	0141                	addi	sp,sp,16
ffffffffc0201858:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020185a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020185c:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020185e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201860:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc0201862:	02d70763          	beq	a4,a3,ffffffffc0201890 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc0201866:	8832                	mv	a6,a2
ffffffffc0201868:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc020186a:	87ba                	mv	a5,a4
ffffffffc020186c:	bf71                	j	ffffffffc0201808 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc020186e:	491c                	lw	a5,16(a0)
ffffffffc0201870:	9dbd                	addw	a1,a1,a5
ffffffffc0201872:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201876:	57f5                	li	a5,-3
ffffffffc0201878:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020187c:	01853803          	ld	a6,24(a0)
ffffffffc0201880:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0201882:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201884:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc0201888:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc020188a:	0105b023          	sd	a6,0(a1)
ffffffffc020188e:	b77d                	j	ffffffffc020183c <default_free_pages+0xa4>
ffffffffc0201890:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list)
ffffffffc0201892:	873e                	mv	a4,a5
ffffffffc0201894:	bf41                	j	ffffffffc0201824 <default_free_pages+0x8c>
}
ffffffffc0201896:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201898:	e390                	sd	a2,0(a5)
ffffffffc020189a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020189c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020189e:	ed1c                	sd	a5,24(a0)
ffffffffc02018a0:	0141                	addi	sp,sp,16
ffffffffc02018a2:	8082                	ret
            base->property += p->property;
ffffffffc02018a4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02018a8:	ff078693          	addi	a3,a5,-16
ffffffffc02018ac:	9e39                	addw	a2,a2,a4
ffffffffc02018ae:	c910                	sw	a2,16(a0)
ffffffffc02018b0:	5775                	li	a4,-3
ffffffffc02018b2:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02018b6:	6398                	ld	a4,0(a5)
ffffffffc02018b8:	679c                	ld	a5,8(a5)
}
ffffffffc02018ba:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02018bc:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02018be:	e398                	sd	a4,0(a5)
ffffffffc02018c0:	0141                	addi	sp,sp,16
ffffffffc02018c2:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02018c4:	00005697          	auipc	a3,0x5
ffffffffc02018c8:	d2468693          	addi	a3,a3,-732 # ffffffffc02065e8 <commands+0xb88>
ffffffffc02018cc:	00005617          	auipc	a2,0x5
ffffffffc02018d0:	9bc60613          	addi	a2,a2,-1604 # ffffffffc0206288 <commands+0x828>
ffffffffc02018d4:	09400593          	li	a1,148
ffffffffc02018d8:	00005517          	auipc	a0,0x5
ffffffffc02018dc:	9c850513          	addi	a0,a0,-1592 # ffffffffc02062a0 <commands+0x840>
ffffffffc02018e0:	baffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(n > 0);
ffffffffc02018e4:	00005697          	auipc	a3,0x5
ffffffffc02018e8:	cfc68693          	addi	a3,a3,-772 # ffffffffc02065e0 <commands+0xb80>
ffffffffc02018ec:	00005617          	auipc	a2,0x5
ffffffffc02018f0:	99c60613          	addi	a2,a2,-1636 # ffffffffc0206288 <commands+0x828>
ffffffffc02018f4:	09000593          	li	a1,144
ffffffffc02018f8:	00005517          	auipc	a0,0x5
ffffffffc02018fc:	9a850513          	addi	a0,a0,-1624 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201900:	b8ffe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201904 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201904:	c941                	beqz	a0,ffffffffc0201994 <default_alloc_pages+0x90>
    if (n > nr_free)
ffffffffc0201906:	000a5597          	auipc	a1,0xa5
ffffffffc020190a:	ef258593          	addi	a1,a1,-270 # ffffffffc02a67f8 <free_area>
ffffffffc020190e:	0105a803          	lw	a6,16(a1)
ffffffffc0201912:	872a                	mv	a4,a0
ffffffffc0201914:	02081793          	slli	a5,a6,0x20
ffffffffc0201918:	9381                	srli	a5,a5,0x20
ffffffffc020191a:	00a7ee63          	bltu	a5,a0,ffffffffc0201936 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc020191e:	87ae                	mv	a5,a1
ffffffffc0201920:	a801                	j	ffffffffc0201930 <default_alloc_pages+0x2c>
        if (p->property >= n)
ffffffffc0201922:	ff87a683          	lw	a3,-8(a5)
ffffffffc0201926:	02069613          	slli	a2,a3,0x20
ffffffffc020192a:	9201                	srli	a2,a2,0x20
ffffffffc020192c:	00e67763          	bgeu	a2,a4,ffffffffc020193a <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201930:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc0201932:	feb798e3          	bne	a5,a1,ffffffffc0201922 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201936:	4501                	li	a0,0
}
ffffffffc0201938:	8082                	ret
    return listelm->prev;
ffffffffc020193a:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020193e:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201942:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0201946:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc020194a:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc020194e:	01133023          	sd	a7,0(t1)
        if (page->property > n)
ffffffffc0201952:	02c77863          	bgeu	a4,a2,ffffffffc0201982 <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc0201956:	071a                	slli	a4,a4,0x6
ffffffffc0201958:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc020195a:	41c686bb          	subw	a3,a3,t3
ffffffffc020195e:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201960:	00870613          	addi	a2,a4,8
ffffffffc0201964:	4689                	li	a3,2
ffffffffc0201966:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc020196a:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020196e:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0201972:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201976:	e290                	sd	a2,0(a3)
ffffffffc0201978:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc020197c:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc020197e:	01173c23          	sd	a7,24(a4)
ffffffffc0201982:	41c8083b          	subw	a6,a6,t3
ffffffffc0201986:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020198a:	5775                	li	a4,-3
ffffffffc020198c:	17c1                	addi	a5,a5,-16
ffffffffc020198e:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201992:	8082                	ret
{
ffffffffc0201994:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201996:	00005697          	auipc	a3,0x5
ffffffffc020199a:	c4a68693          	addi	a3,a3,-950 # ffffffffc02065e0 <commands+0xb80>
ffffffffc020199e:	00005617          	auipc	a2,0x5
ffffffffc02019a2:	8ea60613          	addi	a2,a2,-1814 # ffffffffc0206288 <commands+0x828>
ffffffffc02019a6:	06c00593          	li	a1,108
ffffffffc02019aa:	00005517          	auipc	a0,0x5
ffffffffc02019ae:	8f650513          	addi	a0,a0,-1802 # ffffffffc02062a0 <commands+0x840>
{
ffffffffc02019b2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02019b4:	adbfe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02019b8 <default_init_memmap>:
{
ffffffffc02019b8:	1141                	addi	sp,sp,-16
ffffffffc02019ba:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02019bc:	c5f1                	beqz	a1,ffffffffc0201a88 <default_init_memmap+0xd0>
    for (; p != base + n; p++)
ffffffffc02019be:	00659693          	slli	a3,a1,0x6
ffffffffc02019c2:	96aa                	add	a3,a3,a0
ffffffffc02019c4:	87aa                	mv	a5,a0
ffffffffc02019c6:	00d50f63          	beq	a0,a3,ffffffffc02019e4 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02019ca:	6798                	ld	a4,8(a5)
ffffffffc02019cc:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc02019ce:	cf49                	beqz	a4,ffffffffc0201a68 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc02019d0:	0007a823          	sw	zero,16(a5)
ffffffffc02019d4:	0007b423          	sd	zero,8(a5)
ffffffffc02019d8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02019dc:	04078793          	addi	a5,a5,64
ffffffffc02019e0:	fed795e3          	bne	a5,a3,ffffffffc02019ca <default_init_memmap+0x12>
    base->property = n;
ffffffffc02019e4:	2581                	sext.w	a1,a1
ffffffffc02019e6:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02019e8:	4789                	li	a5,2
ffffffffc02019ea:	00850713          	addi	a4,a0,8
ffffffffc02019ee:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02019f2:	000a5697          	auipc	a3,0xa5
ffffffffc02019f6:	e0668693          	addi	a3,a3,-506 # ffffffffc02a67f8 <free_area>
ffffffffc02019fa:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02019fc:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02019fe:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201a02:	9db9                	addw	a1,a1,a4
ffffffffc0201a04:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc0201a06:	04d78a63          	beq	a5,a3,ffffffffc0201a5a <default_init_memmap+0xa2>
            struct Page *page = le2page(le, page_link);
ffffffffc0201a0a:	fe878713          	addi	a4,a5,-24
ffffffffc0201a0e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc0201a12:	4581                	li	a1,0
            if (base < page)
ffffffffc0201a14:	00e56a63          	bltu	a0,a4,ffffffffc0201a28 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0201a18:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc0201a1a:	02d70263          	beq	a4,a3,ffffffffc0201a3e <default_init_memmap+0x86>
    for (; p != base + n; p++)
ffffffffc0201a1e:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0201a20:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0201a24:	fee57ae3          	bgeu	a0,a4,ffffffffc0201a18 <default_init_memmap+0x60>
ffffffffc0201a28:	c199                	beqz	a1,ffffffffc0201a2e <default_init_memmap+0x76>
ffffffffc0201a2a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201a2e:	6398                	ld	a4,0(a5)
}
ffffffffc0201a30:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201a32:	e390                	sd	a2,0(a5)
ffffffffc0201a34:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201a36:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201a38:	ed18                	sd	a4,24(a0)
ffffffffc0201a3a:	0141                	addi	sp,sp,16
ffffffffc0201a3c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201a3e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201a40:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201a42:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201a44:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc0201a46:	00d70663          	beq	a4,a3,ffffffffc0201a52 <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0201a4a:	8832                	mv	a6,a2
ffffffffc0201a4c:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc0201a4e:	87ba                	mv	a5,a4
ffffffffc0201a50:	bfc1                	j	ffffffffc0201a20 <default_init_memmap+0x68>
}
ffffffffc0201a52:	60a2                	ld	ra,8(sp)
ffffffffc0201a54:	e290                	sd	a2,0(a3)
ffffffffc0201a56:	0141                	addi	sp,sp,16
ffffffffc0201a58:	8082                	ret
ffffffffc0201a5a:	60a2                	ld	ra,8(sp)
ffffffffc0201a5c:	e390                	sd	a2,0(a5)
ffffffffc0201a5e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201a60:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201a62:	ed1c                	sd	a5,24(a0)
ffffffffc0201a64:	0141                	addi	sp,sp,16
ffffffffc0201a66:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201a68:	00005697          	auipc	a3,0x5
ffffffffc0201a6c:	ba868693          	addi	a3,a3,-1112 # ffffffffc0206610 <commands+0xbb0>
ffffffffc0201a70:	00005617          	auipc	a2,0x5
ffffffffc0201a74:	81860613          	addi	a2,a2,-2024 # ffffffffc0206288 <commands+0x828>
ffffffffc0201a78:	04b00593          	li	a1,75
ffffffffc0201a7c:	00005517          	auipc	a0,0x5
ffffffffc0201a80:	82450513          	addi	a0,a0,-2012 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201a84:	a0bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(n > 0);
ffffffffc0201a88:	00005697          	auipc	a3,0x5
ffffffffc0201a8c:	b5868693          	addi	a3,a3,-1192 # ffffffffc02065e0 <commands+0xb80>
ffffffffc0201a90:	00004617          	auipc	a2,0x4
ffffffffc0201a94:	7f860613          	addi	a2,a2,2040 # ffffffffc0206288 <commands+0x828>
ffffffffc0201a98:	04700593          	li	a1,71
ffffffffc0201a9c:	00005517          	auipc	a0,0x5
ffffffffc0201aa0:	80450513          	addi	a0,a0,-2044 # ffffffffc02062a0 <commands+0x840>
ffffffffc0201aa4:	9ebfe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201aa8 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201aa8:	c94d                	beqz	a0,ffffffffc0201b5a <slob_free+0xb2>
{
ffffffffc0201aaa:	1141                	addi	sp,sp,-16
ffffffffc0201aac:	e022                	sd	s0,0(sp)
ffffffffc0201aae:	e406                	sd	ra,8(sp)
ffffffffc0201ab0:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc0201ab2:	e9c1                	bnez	a1,ffffffffc0201b42 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201ab4:	100027f3          	csrr	a5,sstatus
ffffffffc0201ab8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201aba:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201abc:	ebd9                	bnez	a5,ffffffffc0201b52 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201abe:	000a5617          	auipc	a2,0xa5
ffffffffc0201ac2:	92a60613          	addi	a2,a2,-1750 # ffffffffc02a63e8 <slobfree>
ffffffffc0201ac6:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201ac8:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201aca:	679c                	ld	a5,8(a5)
ffffffffc0201acc:	02877a63          	bgeu	a4,s0,ffffffffc0201b00 <slob_free+0x58>
ffffffffc0201ad0:	00f46463          	bltu	s0,a5,ffffffffc0201ad8 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201ad4:	fef76ae3          	bltu	a4,a5,ffffffffc0201ac8 <slob_free+0x20>
			break;

	if (b + b->units == cur->next)
ffffffffc0201ad8:	400c                	lw	a1,0(s0)
ffffffffc0201ada:	00459693          	slli	a3,a1,0x4
ffffffffc0201ade:	96a2                	add	a3,a3,s0
ffffffffc0201ae0:	02d78a63          	beq	a5,a3,ffffffffc0201b14 <slob_free+0x6c>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc0201ae4:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0201ae6:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0201ae8:	00469793          	slli	a5,a3,0x4
ffffffffc0201aec:	97ba                	add	a5,a5,a4
ffffffffc0201aee:	02f40e63          	beq	s0,a5,ffffffffc0201b2a <slob_free+0x82>
	{
		cur->units += b->units;
		cur->next = b->next;
	}
	else
		cur->next = b;
ffffffffc0201af2:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0201af4:	e218                	sd	a4,0(a2)
    if (flag)
ffffffffc0201af6:	e129                	bnez	a0,ffffffffc0201b38 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201af8:	60a2                	ld	ra,8(sp)
ffffffffc0201afa:	6402                	ld	s0,0(sp)
ffffffffc0201afc:	0141                	addi	sp,sp,16
ffffffffc0201afe:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201b00:	fcf764e3          	bltu	a4,a5,ffffffffc0201ac8 <slob_free+0x20>
ffffffffc0201b04:	fcf472e3          	bgeu	s0,a5,ffffffffc0201ac8 <slob_free+0x20>
	if (b + b->units == cur->next)
ffffffffc0201b08:	400c                	lw	a1,0(s0)
ffffffffc0201b0a:	00459693          	slli	a3,a1,0x4
ffffffffc0201b0e:	96a2                	add	a3,a3,s0
ffffffffc0201b10:	fcd79ae3          	bne	a5,a3,ffffffffc0201ae4 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0201b14:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201b16:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201b18:	9db5                	addw	a1,a1,a3
ffffffffc0201b1a:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b)
ffffffffc0201b1c:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201b1e:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0201b20:	00469793          	slli	a5,a3,0x4
ffffffffc0201b24:	97ba                	add	a5,a5,a4
ffffffffc0201b26:	fcf416e3          	bne	s0,a5,ffffffffc0201af2 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0201b2a:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201b2c:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0201b2e:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201b30:	9ebd                	addw	a3,a3,a5
ffffffffc0201b32:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0201b34:	e70c                	sd	a1,8(a4)
ffffffffc0201b36:	d169                	beqz	a0,ffffffffc0201af8 <slob_free+0x50>
}
ffffffffc0201b38:	6402                	ld	s0,0(sp)
ffffffffc0201b3a:	60a2                	ld	ra,8(sp)
ffffffffc0201b3c:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201b3e:	e71fe06f          	j	ffffffffc02009ae <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0201b42:	25bd                	addiw	a1,a1,15
ffffffffc0201b44:	8191                	srli	a1,a1,0x4
ffffffffc0201b46:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b48:	100027f3          	csrr	a5,sstatus
ffffffffc0201b4c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201b4e:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b50:	d7bd                	beqz	a5,ffffffffc0201abe <slob_free+0x16>
        intr_disable();
ffffffffc0201b52:	e63fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc0201b56:	4505                	li	a0,1
ffffffffc0201b58:	b79d                	j	ffffffffc0201abe <slob_free+0x16>
ffffffffc0201b5a:	8082                	ret

ffffffffc0201b5c <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201b5c:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201b5e:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201b60:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201b64:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201b66:	352000ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
	if (!page)
ffffffffc0201b6a:	c91d                	beqz	a0,ffffffffc0201ba0 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201b6c:	000a9697          	auipc	a3,0xa9
ffffffffc0201b70:	d046b683          	ld	a3,-764(a3) # ffffffffc02aa870 <pages>
ffffffffc0201b74:	8d15                	sub	a0,a0,a3
ffffffffc0201b76:	8519                	srai	a0,a0,0x6
ffffffffc0201b78:	00006697          	auipc	a3,0x6
ffffffffc0201b7c:	f706b683          	ld	a3,-144(a3) # ffffffffc0207ae8 <nbase>
ffffffffc0201b80:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201b82:	00c51793          	slli	a5,a0,0xc
ffffffffc0201b86:	83b1                	srli	a5,a5,0xc
ffffffffc0201b88:	000a9717          	auipc	a4,0xa9
ffffffffc0201b8c:	ce073703          	ld	a4,-800(a4) # ffffffffc02aa868 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201b90:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201b92:	00e7fa63          	bgeu	a5,a4,ffffffffc0201ba6 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201b96:	000a9697          	auipc	a3,0xa9
ffffffffc0201b9a:	cea6b683          	ld	a3,-790(a3) # ffffffffc02aa880 <va_pa_offset>
ffffffffc0201b9e:	9536                	add	a0,a0,a3
}
ffffffffc0201ba0:	60a2                	ld	ra,8(sp)
ffffffffc0201ba2:	0141                	addi	sp,sp,16
ffffffffc0201ba4:	8082                	ret
ffffffffc0201ba6:	86aa                	mv	a3,a0
ffffffffc0201ba8:	00005617          	auipc	a2,0x5
ffffffffc0201bac:	ac860613          	addi	a2,a2,-1336 # ffffffffc0206670 <default_pmm_manager+0x38>
ffffffffc0201bb0:	07100593          	li	a1,113
ffffffffc0201bb4:	00005517          	auipc	a0,0x5
ffffffffc0201bb8:	ae450513          	addi	a0,a0,-1308 # ffffffffc0206698 <default_pmm_manager+0x60>
ffffffffc0201bbc:	8d3fe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201bc0 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201bc0:	1101                	addi	sp,sp,-32
ffffffffc0201bc2:	ec06                	sd	ra,24(sp)
ffffffffc0201bc4:	e822                	sd	s0,16(sp)
ffffffffc0201bc6:	e426                	sd	s1,8(sp)
ffffffffc0201bc8:	e04a                	sd	s2,0(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201bca:	01050713          	addi	a4,a0,16
ffffffffc0201bce:	6785                	lui	a5,0x1
ffffffffc0201bd0:	0cf77363          	bgeu	a4,a5,ffffffffc0201c96 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201bd4:	00f50493          	addi	s1,a0,15
ffffffffc0201bd8:	8091                	srli	s1,s1,0x4
ffffffffc0201bda:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201bdc:	10002673          	csrr	a2,sstatus
ffffffffc0201be0:	8a09                	andi	a2,a2,2
ffffffffc0201be2:	e25d                	bnez	a2,ffffffffc0201c88 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201be4:	000a5917          	auipc	s2,0xa5
ffffffffc0201be8:	80490913          	addi	s2,s2,-2044 # ffffffffc02a63e8 <slobfree>
ffffffffc0201bec:	00093683          	ld	a3,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201bf0:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta)
ffffffffc0201bf2:	4398                	lw	a4,0(a5)
ffffffffc0201bf4:	08975e63          	bge	a4,s1,ffffffffc0201c90 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree)
ffffffffc0201bf8:	00f68b63          	beq	a3,a5,ffffffffc0201c0e <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201bfc:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201bfe:	4018                	lw	a4,0(s0)
ffffffffc0201c00:	02975a63          	bge	a4,s1,ffffffffc0201c34 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree)
ffffffffc0201c04:	00093683          	ld	a3,0(s2)
ffffffffc0201c08:	87a2                	mv	a5,s0
ffffffffc0201c0a:	fef699e3          	bne	a3,a5,ffffffffc0201bfc <slob_alloc.constprop.0+0x3c>
    if (flag)
ffffffffc0201c0e:	ee31                	bnez	a2,ffffffffc0201c6a <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201c10:	4501                	li	a0,0
ffffffffc0201c12:	f4bff0ef          	jal	ra,ffffffffc0201b5c <__slob_get_free_pages.constprop.0>
ffffffffc0201c16:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201c18:	cd05                	beqz	a0,ffffffffc0201c50 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201c1a:	6585                	lui	a1,0x1
ffffffffc0201c1c:	e8dff0ef          	jal	ra,ffffffffc0201aa8 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201c20:	10002673          	csrr	a2,sstatus
ffffffffc0201c24:	8a09                	andi	a2,a2,2
ffffffffc0201c26:	ee05                	bnez	a2,ffffffffc0201c5e <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201c28:	00093783          	ld	a5,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201c2c:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201c2e:	4018                	lw	a4,0(s0)
ffffffffc0201c30:	fc974ae3          	blt	a4,s1,ffffffffc0201c04 <slob_alloc.constprop.0+0x44>
			if (cur->units == units)	/* exact fit? */
ffffffffc0201c34:	04e48763          	beq	s1,a4,ffffffffc0201c82 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201c38:	00449693          	slli	a3,s1,0x4
ffffffffc0201c3c:	96a2                	add	a3,a3,s0
ffffffffc0201c3e:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201c40:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201c42:	9f05                	subw	a4,a4,s1
ffffffffc0201c44:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201c46:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201c48:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201c4a:	00f93023          	sd	a5,0(s2)
    if (flag)
ffffffffc0201c4e:	e20d                	bnez	a2,ffffffffc0201c70 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201c50:	60e2                	ld	ra,24(sp)
ffffffffc0201c52:	8522                	mv	a0,s0
ffffffffc0201c54:	6442                	ld	s0,16(sp)
ffffffffc0201c56:	64a2                	ld	s1,8(sp)
ffffffffc0201c58:	6902                	ld	s2,0(sp)
ffffffffc0201c5a:	6105                	addi	sp,sp,32
ffffffffc0201c5c:	8082                	ret
        intr_disable();
ffffffffc0201c5e:	d57fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
			cur = slobfree;
ffffffffc0201c62:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201c66:	4605                	li	a2,1
ffffffffc0201c68:	b7d1                	j	ffffffffc0201c2c <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201c6a:	d45fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0201c6e:	b74d                	j	ffffffffc0201c10 <slob_alloc.constprop.0+0x50>
ffffffffc0201c70:	d3ffe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
}
ffffffffc0201c74:	60e2                	ld	ra,24(sp)
ffffffffc0201c76:	8522                	mv	a0,s0
ffffffffc0201c78:	6442                	ld	s0,16(sp)
ffffffffc0201c7a:	64a2                	ld	s1,8(sp)
ffffffffc0201c7c:	6902                	ld	s2,0(sp)
ffffffffc0201c7e:	6105                	addi	sp,sp,32
ffffffffc0201c80:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201c82:	6418                	ld	a4,8(s0)
ffffffffc0201c84:	e798                	sd	a4,8(a5)
ffffffffc0201c86:	b7d1                	j	ffffffffc0201c4a <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201c88:	d2dfe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc0201c8c:	4605                	li	a2,1
ffffffffc0201c8e:	bf99                	j	ffffffffc0201be4 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta)
ffffffffc0201c90:	843e                	mv	s0,a5
ffffffffc0201c92:	87b6                	mv	a5,a3
ffffffffc0201c94:	b745                	j	ffffffffc0201c34 <slob_alloc.constprop.0+0x74>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201c96:	00005697          	auipc	a3,0x5
ffffffffc0201c9a:	a1268693          	addi	a3,a3,-1518 # ffffffffc02066a8 <default_pmm_manager+0x70>
ffffffffc0201c9e:	00004617          	auipc	a2,0x4
ffffffffc0201ca2:	5ea60613          	addi	a2,a2,1514 # ffffffffc0206288 <commands+0x828>
ffffffffc0201ca6:	06300593          	li	a1,99
ffffffffc0201caa:	00005517          	auipc	a0,0x5
ffffffffc0201cae:	a1e50513          	addi	a0,a0,-1506 # ffffffffc02066c8 <default_pmm_manager+0x90>
ffffffffc0201cb2:	fdcfe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201cb6 <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc0201cb6:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc0201cb8:	00005517          	auipc	a0,0x5
ffffffffc0201cbc:	a2850513          	addi	a0,a0,-1496 # ffffffffc02066e0 <default_pmm_manager+0xa8>
{
ffffffffc0201cc0:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc0201cc2:	cd2fe0ef          	jal	ra,ffffffffc0200194 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201cc6:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201cc8:	00005517          	auipc	a0,0x5
ffffffffc0201ccc:	a3050513          	addi	a0,a0,-1488 # ffffffffc02066f8 <default_pmm_manager+0xc0>
}
ffffffffc0201cd0:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201cd2:	cc2fe06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0201cd6 <kallocated>:

size_t
kallocated(void)
{
	return slob_allocated();
}
ffffffffc0201cd6:	4501                	li	a0,0
ffffffffc0201cd8:	8082                	ret

ffffffffc0201cda <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201cda:	1101                	addi	sp,sp,-32
ffffffffc0201cdc:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201cde:	6905                	lui	s2,0x1
{
ffffffffc0201ce0:	e822                	sd	s0,16(sp)
ffffffffc0201ce2:	ec06                	sd	ra,24(sp)
ffffffffc0201ce4:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201ce6:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bd1>
{
ffffffffc0201cea:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201cec:	04a7f963          	bgeu	a5,a0,ffffffffc0201d3e <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201cf0:	4561                	li	a0,24
ffffffffc0201cf2:	ecfff0ef          	jal	ra,ffffffffc0201bc0 <slob_alloc.constprop.0>
ffffffffc0201cf6:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201cf8:	c929                	beqz	a0,ffffffffc0201d4a <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201cfa:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201cfe:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc0201d00:	00f95763          	bge	s2,a5,ffffffffc0201d0e <kmalloc+0x34>
ffffffffc0201d04:	6705                	lui	a4,0x1
ffffffffc0201d06:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201d08:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc0201d0a:	fef74ee3          	blt	a4,a5,ffffffffc0201d06 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201d0e:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201d10:	e4dff0ef          	jal	ra,ffffffffc0201b5c <__slob_get_free_pages.constprop.0>
ffffffffc0201d14:	e488                	sd	a0,8(s1)
ffffffffc0201d16:	842a                	mv	s0,a0
	if (bb->pages)
ffffffffc0201d18:	c525                	beqz	a0,ffffffffc0201d80 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201d1a:	100027f3          	csrr	a5,sstatus
ffffffffc0201d1e:	8b89                	andi	a5,a5,2
ffffffffc0201d20:	ef8d                	bnez	a5,ffffffffc0201d5a <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201d22:	000a9797          	auipc	a5,0xa9
ffffffffc0201d26:	b2e78793          	addi	a5,a5,-1234 # ffffffffc02aa850 <bigblocks>
ffffffffc0201d2a:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201d2c:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201d2e:	e898                	sd	a4,16(s1)
	return __kmalloc(size, 0);
}
ffffffffc0201d30:	60e2                	ld	ra,24(sp)
ffffffffc0201d32:	8522                	mv	a0,s0
ffffffffc0201d34:	6442                	ld	s0,16(sp)
ffffffffc0201d36:	64a2                	ld	s1,8(sp)
ffffffffc0201d38:	6902                	ld	s2,0(sp)
ffffffffc0201d3a:	6105                	addi	sp,sp,32
ffffffffc0201d3c:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201d3e:	0541                	addi	a0,a0,16
ffffffffc0201d40:	e81ff0ef          	jal	ra,ffffffffc0201bc0 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201d44:	01050413          	addi	s0,a0,16
ffffffffc0201d48:	f565                	bnez	a0,ffffffffc0201d30 <kmalloc+0x56>
ffffffffc0201d4a:	4401                	li	s0,0
}
ffffffffc0201d4c:	60e2                	ld	ra,24(sp)
ffffffffc0201d4e:	8522                	mv	a0,s0
ffffffffc0201d50:	6442                	ld	s0,16(sp)
ffffffffc0201d52:	64a2                	ld	s1,8(sp)
ffffffffc0201d54:	6902                	ld	s2,0(sp)
ffffffffc0201d56:	6105                	addi	sp,sp,32
ffffffffc0201d58:	8082                	ret
        intr_disable();
ffffffffc0201d5a:	c5bfe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201d5e:	000a9797          	auipc	a5,0xa9
ffffffffc0201d62:	af278793          	addi	a5,a5,-1294 # ffffffffc02aa850 <bigblocks>
ffffffffc0201d66:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201d68:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201d6a:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201d6c:	c43fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
		return bb->pages;
ffffffffc0201d70:	6480                	ld	s0,8(s1)
}
ffffffffc0201d72:	60e2                	ld	ra,24(sp)
ffffffffc0201d74:	64a2                	ld	s1,8(sp)
ffffffffc0201d76:	8522                	mv	a0,s0
ffffffffc0201d78:	6442                	ld	s0,16(sp)
ffffffffc0201d7a:	6902                	ld	s2,0(sp)
ffffffffc0201d7c:	6105                	addi	sp,sp,32
ffffffffc0201d7e:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d80:	45e1                	li	a1,24
ffffffffc0201d82:	8526                	mv	a0,s1
ffffffffc0201d84:	d25ff0ef          	jal	ra,ffffffffc0201aa8 <slob_free>
	return __kmalloc(size, 0);
ffffffffc0201d88:	b765                	j	ffffffffc0201d30 <kmalloc+0x56>

ffffffffc0201d8a <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201d8a:	c169                	beqz	a0,ffffffffc0201e4c <kfree+0xc2>
{
ffffffffc0201d8c:	1101                	addi	sp,sp,-32
ffffffffc0201d8e:	e822                	sd	s0,16(sp)
ffffffffc0201d90:	ec06                	sd	ra,24(sp)
ffffffffc0201d92:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201d94:	03451793          	slli	a5,a0,0x34
ffffffffc0201d98:	842a                	mv	s0,a0
ffffffffc0201d9a:	e3d9                	bnez	a5,ffffffffc0201e20 <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201d9c:	100027f3          	csrr	a5,sstatus
ffffffffc0201da0:	8b89                	andi	a5,a5,2
ffffffffc0201da2:	e7d9                	bnez	a5,ffffffffc0201e30 <kfree+0xa6>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201da4:	000a9797          	auipc	a5,0xa9
ffffffffc0201da8:	aac7b783          	ld	a5,-1364(a5) # ffffffffc02aa850 <bigblocks>
    return 0;
ffffffffc0201dac:	4601                	li	a2,0
ffffffffc0201dae:	cbad                	beqz	a5,ffffffffc0201e20 <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201db0:	000a9697          	auipc	a3,0xa9
ffffffffc0201db4:	aa068693          	addi	a3,a3,-1376 # ffffffffc02aa850 <bigblocks>
ffffffffc0201db8:	a021                	j	ffffffffc0201dc0 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201dba:	01048693          	addi	a3,s1,16
ffffffffc0201dbe:	c3a5                	beqz	a5,ffffffffc0201e1e <kfree+0x94>
		{
			if (bb->pages == block)
ffffffffc0201dc0:	6798                	ld	a4,8(a5)
ffffffffc0201dc2:	84be                	mv	s1,a5
			{
				*last = bb->next;
ffffffffc0201dc4:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc0201dc6:	fe871ae3          	bne	a4,s0,ffffffffc0201dba <kfree+0x30>
				*last = bb->next;
ffffffffc0201dca:	e29c                	sd	a5,0(a3)
    if (flag)
ffffffffc0201dcc:	ee2d                	bnez	a2,ffffffffc0201e46 <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201dce:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201dd2:	4098                	lw	a4,0(s1)
ffffffffc0201dd4:	08f46963          	bltu	s0,a5,ffffffffc0201e66 <kfree+0xdc>
ffffffffc0201dd8:	000a9697          	auipc	a3,0xa9
ffffffffc0201ddc:	aa86b683          	ld	a3,-1368(a3) # ffffffffc02aa880 <va_pa_offset>
ffffffffc0201de0:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage)
ffffffffc0201de2:	8031                	srli	s0,s0,0xc
ffffffffc0201de4:	000a9797          	auipc	a5,0xa9
ffffffffc0201de8:	a847b783          	ld	a5,-1404(a5) # ffffffffc02aa868 <npage>
ffffffffc0201dec:	06f47163          	bgeu	s0,a5,ffffffffc0201e4e <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201df0:	00006517          	auipc	a0,0x6
ffffffffc0201df4:	cf853503          	ld	a0,-776(a0) # ffffffffc0207ae8 <nbase>
ffffffffc0201df8:	8c09                	sub	s0,s0,a0
ffffffffc0201dfa:	041a                	slli	s0,s0,0x6
	free_pages(kva2page(kva), 1 << order);
ffffffffc0201dfc:	000a9517          	auipc	a0,0xa9
ffffffffc0201e00:	a7453503          	ld	a0,-1420(a0) # ffffffffc02aa870 <pages>
ffffffffc0201e04:	4585                	li	a1,1
ffffffffc0201e06:	9522                	add	a0,a0,s0
ffffffffc0201e08:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201e0c:	0ea000ef          	jal	ra,ffffffffc0201ef6 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201e10:	6442                	ld	s0,16(sp)
ffffffffc0201e12:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201e14:	8526                	mv	a0,s1
}
ffffffffc0201e16:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201e18:	45e1                	li	a1,24
}
ffffffffc0201e1a:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201e1c:	b171                	j	ffffffffc0201aa8 <slob_free>
ffffffffc0201e1e:	e20d                	bnez	a2,ffffffffc0201e40 <kfree+0xb6>
ffffffffc0201e20:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201e24:	6442                	ld	s0,16(sp)
ffffffffc0201e26:	60e2                	ld	ra,24(sp)
ffffffffc0201e28:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201e2a:	4581                	li	a1,0
}
ffffffffc0201e2c:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201e2e:	b9ad                	j	ffffffffc0201aa8 <slob_free>
        intr_disable();
ffffffffc0201e30:	b85fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201e34:	000a9797          	auipc	a5,0xa9
ffffffffc0201e38:	a1c7b783          	ld	a5,-1508(a5) # ffffffffc02aa850 <bigblocks>
        return 1;
ffffffffc0201e3c:	4605                	li	a2,1
ffffffffc0201e3e:	fbad                	bnez	a5,ffffffffc0201db0 <kfree+0x26>
        intr_enable();
ffffffffc0201e40:	b6ffe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0201e44:	bff1                	j	ffffffffc0201e20 <kfree+0x96>
ffffffffc0201e46:	b69fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0201e4a:	b751                	j	ffffffffc0201dce <kfree+0x44>
ffffffffc0201e4c:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201e4e:	00005617          	auipc	a2,0x5
ffffffffc0201e52:	8f260613          	addi	a2,a2,-1806 # ffffffffc0206740 <default_pmm_manager+0x108>
ffffffffc0201e56:	06900593          	li	a1,105
ffffffffc0201e5a:	00005517          	auipc	a0,0x5
ffffffffc0201e5e:	83e50513          	addi	a0,a0,-1986 # ffffffffc0206698 <default_pmm_manager+0x60>
ffffffffc0201e62:	e2cfe0ef          	jal	ra,ffffffffc020048e <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201e66:	86a2                	mv	a3,s0
ffffffffc0201e68:	00005617          	auipc	a2,0x5
ffffffffc0201e6c:	8b060613          	addi	a2,a2,-1872 # ffffffffc0206718 <default_pmm_manager+0xe0>
ffffffffc0201e70:	07700593          	li	a1,119
ffffffffc0201e74:	00005517          	auipc	a0,0x5
ffffffffc0201e78:	82450513          	addi	a0,a0,-2012 # ffffffffc0206698 <default_pmm_manager+0x60>
ffffffffc0201e7c:	e12fe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201e80 <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc0201e80:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201e82:	00005617          	auipc	a2,0x5
ffffffffc0201e86:	8be60613          	addi	a2,a2,-1858 # ffffffffc0206740 <default_pmm_manager+0x108>
ffffffffc0201e8a:	06900593          	li	a1,105
ffffffffc0201e8e:	00005517          	auipc	a0,0x5
ffffffffc0201e92:	80a50513          	addi	a0,a0,-2038 # ffffffffc0206698 <default_pmm_manager+0x60>
pa2page(uintptr_t pa)
ffffffffc0201e96:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201e98:	df6fe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201e9c <pte2page.part.0>:
pte2page(pte_t pte)
ffffffffc0201e9c:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201e9e:	00005617          	auipc	a2,0x5
ffffffffc0201ea2:	8c260613          	addi	a2,a2,-1854 # ffffffffc0206760 <default_pmm_manager+0x128>
ffffffffc0201ea6:	07f00593          	li	a1,127
ffffffffc0201eaa:	00004517          	auipc	a0,0x4
ffffffffc0201eae:	7ee50513          	addi	a0,a0,2030 # ffffffffc0206698 <default_pmm_manager+0x60>
pte2page(pte_t pte)
ffffffffc0201eb2:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201eb4:	ddafe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201eb8 <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201eb8:	100027f3          	csrr	a5,sstatus
ffffffffc0201ebc:	8b89                	andi	a5,a5,2
ffffffffc0201ebe:	e799                	bnez	a5,ffffffffc0201ecc <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201ec0:	000a9797          	auipc	a5,0xa9
ffffffffc0201ec4:	9b87b783          	ld	a5,-1608(a5) # ffffffffc02aa878 <pmm_manager>
ffffffffc0201ec8:	6f9c                	ld	a5,24(a5)
ffffffffc0201eca:	8782                	jr	a5
{
ffffffffc0201ecc:	1141                	addi	sp,sp,-16
ffffffffc0201ece:	e406                	sd	ra,8(sp)
ffffffffc0201ed0:	e022                	sd	s0,0(sp)
ffffffffc0201ed2:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201ed4:	ae1fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201ed8:	000a9797          	auipc	a5,0xa9
ffffffffc0201edc:	9a07b783          	ld	a5,-1632(a5) # ffffffffc02aa878 <pmm_manager>
ffffffffc0201ee0:	6f9c                	ld	a5,24(a5)
ffffffffc0201ee2:	8522                	mv	a0,s0
ffffffffc0201ee4:	9782                	jalr	a5
ffffffffc0201ee6:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201ee8:	ac7fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201eec:	60a2                	ld	ra,8(sp)
ffffffffc0201eee:	8522                	mv	a0,s0
ffffffffc0201ef0:	6402                	ld	s0,0(sp)
ffffffffc0201ef2:	0141                	addi	sp,sp,16
ffffffffc0201ef4:	8082                	ret

ffffffffc0201ef6 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201ef6:	100027f3          	csrr	a5,sstatus
ffffffffc0201efa:	8b89                	andi	a5,a5,2
ffffffffc0201efc:	e799                	bnez	a5,ffffffffc0201f0a <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201efe:	000a9797          	auipc	a5,0xa9
ffffffffc0201f02:	97a7b783          	ld	a5,-1670(a5) # ffffffffc02aa878 <pmm_manager>
ffffffffc0201f06:	739c                	ld	a5,32(a5)
ffffffffc0201f08:	8782                	jr	a5
{
ffffffffc0201f0a:	1101                	addi	sp,sp,-32
ffffffffc0201f0c:	ec06                	sd	ra,24(sp)
ffffffffc0201f0e:	e822                	sd	s0,16(sp)
ffffffffc0201f10:	e426                	sd	s1,8(sp)
ffffffffc0201f12:	842a                	mv	s0,a0
ffffffffc0201f14:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201f16:	a9ffe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201f1a:	000a9797          	auipc	a5,0xa9
ffffffffc0201f1e:	95e7b783          	ld	a5,-1698(a5) # ffffffffc02aa878 <pmm_manager>
ffffffffc0201f22:	739c                	ld	a5,32(a5)
ffffffffc0201f24:	85a6                	mv	a1,s1
ffffffffc0201f26:	8522                	mv	a0,s0
ffffffffc0201f28:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201f2a:	6442                	ld	s0,16(sp)
ffffffffc0201f2c:	60e2                	ld	ra,24(sp)
ffffffffc0201f2e:	64a2                	ld	s1,8(sp)
ffffffffc0201f30:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201f32:	a7dfe06f          	j	ffffffffc02009ae <intr_enable>

ffffffffc0201f36 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201f36:	100027f3          	csrr	a5,sstatus
ffffffffc0201f3a:	8b89                	andi	a5,a5,2
ffffffffc0201f3c:	e799                	bnez	a5,ffffffffc0201f4a <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f3e:	000a9797          	auipc	a5,0xa9
ffffffffc0201f42:	93a7b783          	ld	a5,-1734(a5) # ffffffffc02aa878 <pmm_manager>
ffffffffc0201f46:	779c                	ld	a5,40(a5)
ffffffffc0201f48:	8782                	jr	a5
{
ffffffffc0201f4a:	1141                	addi	sp,sp,-16
ffffffffc0201f4c:	e406                	sd	ra,8(sp)
ffffffffc0201f4e:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201f50:	a65fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f54:	000a9797          	auipc	a5,0xa9
ffffffffc0201f58:	9247b783          	ld	a5,-1756(a5) # ffffffffc02aa878 <pmm_manager>
ffffffffc0201f5c:	779c                	ld	a5,40(a5)
ffffffffc0201f5e:	9782                	jalr	a5
ffffffffc0201f60:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201f62:	a4dfe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201f66:	60a2                	ld	ra,8(sp)
ffffffffc0201f68:	8522                	mv	a0,s0
ffffffffc0201f6a:	6402                	ld	s0,0(sp)
ffffffffc0201f6c:	0141                	addi	sp,sp,16
ffffffffc0201f6e:	8082                	ret

ffffffffc0201f70 <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201f70:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201f74:	1ff7f793          	andi	a5,a5,511
{
ffffffffc0201f78:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201f7a:	078e                	slli	a5,a5,0x3
{
ffffffffc0201f7c:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201f7e:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc0201f82:	6094                	ld	a3,0(s1)
{
ffffffffc0201f84:	f04a                	sd	s2,32(sp)
ffffffffc0201f86:	ec4e                	sd	s3,24(sp)
ffffffffc0201f88:	e852                	sd	s4,16(sp)
ffffffffc0201f8a:	fc06                	sd	ra,56(sp)
ffffffffc0201f8c:	f822                	sd	s0,48(sp)
ffffffffc0201f8e:	e456                	sd	s5,8(sp)
ffffffffc0201f90:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc0201f92:	0016f793          	andi	a5,a3,1
{
ffffffffc0201f96:	892e                	mv	s2,a1
ffffffffc0201f98:	8a32                	mv	s4,a2
ffffffffc0201f9a:	000a9997          	auipc	s3,0xa9
ffffffffc0201f9e:	8ce98993          	addi	s3,s3,-1842 # ffffffffc02aa868 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc0201fa2:	efbd                	bnez	a5,ffffffffc0202020 <get_pte+0xb0>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201fa4:	14060c63          	beqz	a2,ffffffffc02020fc <get_pte+0x18c>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201fa8:	100027f3          	csrr	a5,sstatus
ffffffffc0201fac:	8b89                	andi	a5,a5,2
ffffffffc0201fae:	14079963          	bnez	a5,ffffffffc0202100 <get_pte+0x190>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201fb2:	000a9797          	auipc	a5,0xa9
ffffffffc0201fb6:	8c67b783          	ld	a5,-1850(a5) # ffffffffc02aa878 <pmm_manager>
ffffffffc0201fba:	6f9c                	ld	a5,24(a5)
ffffffffc0201fbc:	4505                	li	a0,1
ffffffffc0201fbe:	9782                	jalr	a5
ffffffffc0201fc0:	842a                	mv	s0,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201fc2:	12040d63          	beqz	s0,ffffffffc02020fc <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0201fc6:	000a9b17          	auipc	s6,0xa9
ffffffffc0201fca:	8aab0b13          	addi	s6,s6,-1878 # ffffffffc02aa870 <pages>
ffffffffc0201fce:	000b3503          	ld	a0,0(s6)
ffffffffc0201fd2:	00080ab7          	lui	s5,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201fd6:	000a9997          	auipc	s3,0xa9
ffffffffc0201fda:	89298993          	addi	s3,s3,-1902 # ffffffffc02aa868 <npage>
ffffffffc0201fde:	40a40533          	sub	a0,s0,a0
ffffffffc0201fe2:	8519                	srai	a0,a0,0x6
ffffffffc0201fe4:	9556                	add	a0,a0,s5
ffffffffc0201fe6:	0009b703          	ld	a4,0(s3)
ffffffffc0201fea:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201fee:	4685                	li	a3,1
ffffffffc0201ff0:	c014                	sw	a3,0(s0)
ffffffffc0201ff2:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ff4:	0532                	slli	a0,a0,0xc
ffffffffc0201ff6:	16e7f763          	bgeu	a5,a4,ffffffffc0202164 <get_pte+0x1f4>
ffffffffc0201ffa:	000a9797          	auipc	a5,0xa9
ffffffffc0201ffe:	8867b783          	ld	a5,-1914(a5) # ffffffffc02aa880 <va_pa_offset>
ffffffffc0202002:	6605                	lui	a2,0x1
ffffffffc0202004:	4581                	li	a1,0
ffffffffc0202006:	953e                	add	a0,a0,a5
ffffffffc0202008:	7c4030ef          	jal	ra,ffffffffc02057cc <memset>
    return page - pages + nbase;
ffffffffc020200c:	000b3683          	ld	a3,0(s6)
ffffffffc0202010:	40d406b3          	sub	a3,s0,a3
ffffffffc0202014:	8699                	srai	a3,a3,0x6
ffffffffc0202016:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202018:	06aa                	slli	a3,a3,0xa
ffffffffc020201a:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020201e:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202020:	77fd                	lui	a5,0xfffff
ffffffffc0202022:	068a                	slli	a3,a3,0x2
ffffffffc0202024:	0009b703          	ld	a4,0(s3)
ffffffffc0202028:	8efd                	and	a3,a3,a5
ffffffffc020202a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020202e:	10e7ff63          	bgeu	a5,a4,ffffffffc020214c <get_pte+0x1dc>
ffffffffc0202032:	000a9a97          	auipc	s5,0xa9
ffffffffc0202036:	84ea8a93          	addi	s5,s5,-1970 # ffffffffc02aa880 <va_pa_offset>
ffffffffc020203a:	000ab403          	ld	s0,0(s5)
ffffffffc020203e:	01595793          	srli	a5,s2,0x15
ffffffffc0202042:	1ff7f793          	andi	a5,a5,511
ffffffffc0202046:	96a2                	add	a3,a3,s0
ffffffffc0202048:	00379413          	slli	s0,a5,0x3
ffffffffc020204c:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V))
ffffffffc020204e:	6014                	ld	a3,0(s0)
ffffffffc0202050:	0016f793          	andi	a5,a3,1
ffffffffc0202054:	ebad                	bnez	a5,ffffffffc02020c6 <get_pte+0x156>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202056:	0a0a0363          	beqz	s4,ffffffffc02020fc <get_pte+0x18c>
ffffffffc020205a:	100027f3          	csrr	a5,sstatus
ffffffffc020205e:	8b89                	andi	a5,a5,2
ffffffffc0202060:	efcd                	bnez	a5,ffffffffc020211a <get_pte+0x1aa>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202062:	000a9797          	auipc	a5,0xa9
ffffffffc0202066:	8167b783          	ld	a5,-2026(a5) # ffffffffc02aa878 <pmm_manager>
ffffffffc020206a:	6f9c                	ld	a5,24(a5)
ffffffffc020206c:	4505                	li	a0,1
ffffffffc020206e:	9782                	jalr	a5
ffffffffc0202070:	84aa                	mv	s1,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202072:	c4c9                	beqz	s1,ffffffffc02020fc <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0202074:	000a8b17          	auipc	s6,0xa8
ffffffffc0202078:	7fcb0b13          	addi	s6,s6,2044 # ffffffffc02aa870 <pages>
ffffffffc020207c:	000b3503          	ld	a0,0(s6)
ffffffffc0202080:	00080a37          	lui	s4,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202084:	0009b703          	ld	a4,0(s3)
ffffffffc0202088:	40a48533          	sub	a0,s1,a0
ffffffffc020208c:	8519                	srai	a0,a0,0x6
ffffffffc020208e:	9552                	add	a0,a0,s4
ffffffffc0202090:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0202094:	4685                	li	a3,1
ffffffffc0202096:	c094                	sw	a3,0(s1)
ffffffffc0202098:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020209a:	0532                	slli	a0,a0,0xc
ffffffffc020209c:	0ee7f163          	bgeu	a5,a4,ffffffffc020217e <get_pte+0x20e>
ffffffffc02020a0:	000ab783          	ld	a5,0(s5)
ffffffffc02020a4:	6605                	lui	a2,0x1
ffffffffc02020a6:	4581                	li	a1,0
ffffffffc02020a8:	953e                	add	a0,a0,a5
ffffffffc02020aa:	722030ef          	jal	ra,ffffffffc02057cc <memset>
    return page - pages + nbase;
ffffffffc02020ae:	000b3683          	ld	a3,0(s6)
ffffffffc02020b2:	40d486b3          	sub	a3,s1,a3
ffffffffc02020b6:	8699                	srai	a3,a3,0x6
ffffffffc02020b8:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02020ba:	06aa                	slli	a3,a3,0xa
ffffffffc02020bc:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02020c0:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02020c2:	0009b703          	ld	a4,0(s3)
ffffffffc02020c6:	068a                	slli	a3,a3,0x2
ffffffffc02020c8:	757d                	lui	a0,0xfffff
ffffffffc02020ca:	8ee9                	and	a3,a3,a0
ffffffffc02020cc:	00c6d793          	srli	a5,a3,0xc
ffffffffc02020d0:	06e7f263          	bgeu	a5,a4,ffffffffc0202134 <get_pte+0x1c4>
ffffffffc02020d4:	000ab503          	ld	a0,0(s5)
ffffffffc02020d8:	00c95913          	srli	s2,s2,0xc
ffffffffc02020dc:	1ff97913          	andi	s2,s2,511
ffffffffc02020e0:	96aa                	add	a3,a3,a0
ffffffffc02020e2:	00391513          	slli	a0,s2,0x3
ffffffffc02020e6:	9536                	add	a0,a0,a3
}
ffffffffc02020e8:	70e2                	ld	ra,56(sp)
ffffffffc02020ea:	7442                	ld	s0,48(sp)
ffffffffc02020ec:	74a2                	ld	s1,40(sp)
ffffffffc02020ee:	7902                	ld	s2,32(sp)
ffffffffc02020f0:	69e2                	ld	s3,24(sp)
ffffffffc02020f2:	6a42                	ld	s4,16(sp)
ffffffffc02020f4:	6aa2                	ld	s5,8(sp)
ffffffffc02020f6:	6b02                	ld	s6,0(sp)
ffffffffc02020f8:	6121                	addi	sp,sp,64
ffffffffc02020fa:	8082                	ret
            return NULL;
ffffffffc02020fc:	4501                	li	a0,0
ffffffffc02020fe:	b7ed                	j	ffffffffc02020e8 <get_pte+0x178>
        intr_disable();
ffffffffc0202100:	8b5fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202104:	000a8797          	auipc	a5,0xa8
ffffffffc0202108:	7747b783          	ld	a5,1908(a5) # ffffffffc02aa878 <pmm_manager>
ffffffffc020210c:	6f9c                	ld	a5,24(a5)
ffffffffc020210e:	4505                	li	a0,1
ffffffffc0202110:	9782                	jalr	a5
ffffffffc0202112:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202114:	89bfe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202118:	b56d                	j	ffffffffc0201fc2 <get_pte+0x52>
        intr_disable();
ffffffffc020211a:	89bfe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc020211e:	000a8797          	auipc	a5,0xa8
ffffffffc0202122:	75a7b783          	ld	a5,1882(a5) # ffffffffc02aa878 <pmm_manager>
ffffffffc0202126:	6f9c                	ld	a5,24(a5)
ffffffffc0202128:	4505                	li	a0,1
ffffffffc020212a:	9782                	jalr	a5
ffffffffc020212c:	84aa                	mv	s1,a0
        intr_enable();
ffffffffc020212e:	881fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202132:	b781                	j	ffffffffc0202072 <get_pte+0x102>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202134:	00004617          	auipc	a2,0x4
ffffffffc0202138:	53c60613          	addi	a2,a2,1340 # ffffffffc0206670 <default_pmm_manager+0x38>
ffffffffc020213c:	0fa00593          	li	a1,250
ffffffffc0202140:	00004517          	auipc	a0,0x4
ffffffffc0202144:	64850513          	addi	a0,a0,1608 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0202148:	b46fe0ef          	jal	ra,ffffffffc020048e <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020214c:	00004617          	auipc	a2,0x4
ffffffffc0202150:	52460613          	addi	a2,a2,1316 # ffffffffc0206670 <default_pmm_manager+0x38>
ffffffffc0202154:	0ed00593          	li	a1,237
ffffffffc0202158:	00004517          	auipc	a0,0x4
ffffffffc020215c:	63050513          	addi	a0,a0,1584 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0202160:	b2efe0ef          	jal	ra,ffffffffc020048e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202164:	86aa                	mv	a3,a0
ffffffffc0202166:	00004617          	auipc	a2,0x4
ffffffffc020216a:	50a60613          	addi	a2,a2,1290 # ffffffffc0206670 <default_pmm_manager+0x38>
ffffffffc020216e:	0e900593          	li	a1,233
ffffffffc0202172:	00004517          	auipc	a0,0x4
ffffffffc0202176:	61650513          	addi	a0,a0,1558 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc020217a:	b14fe0ef          	jal	ra,ffffffffc020048e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020217e:	86aa                	mv	a3,a0
ffffffffc0202180:	00004617          	auipc	a2,0x4
ffffffffc0202184:	4f060613          	addi	a2,a2,1264 # ffffffffc0206670 <default_pmm_manager+0x38>
ffffffffc0202188:	0f700593          	li	a1,247
ffffffffc020218c:	00004517          	auipc	a0,0x4
ffffffffc0202190:	5fc50513          	addi	a0,a0,1532 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0202194:	afafe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0202198 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc0202198:	1141                	addi	sp,sp,-16
ffffffffc020219a:	e022                	sd	s0,0(sp)
ffffffffc020219c:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020219e:	4601                	li	a2,0
{
ffffffffc02021a0:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02021a2:	dcfff0ef          	jal	ra,ffffffffc0201f70 <get_pte>
    if (ptep_store != NULL)
ffffffffc02021a6:	c011                	beqz	s0,ffffffffc02021aa <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc02021a8:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc02021aa:	c511                	beqz	a0,ffffffffc02021b6 <get_page+0x1e>
ffffffffc02021ac:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02021ae:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc02021b0:	0017f713          	andi	a4,a5,1
ffffffffc02021b4:	e709                	bnez	a4,ffffffffc02021be <get_page+0x26>
}
ffffffffc02021b6:	60a2                	ld	ra,8(sp)
ffffffffc02021b8:	6402                	ld	s0,0(sp)
ffffffffc02021ba:	0141                	addi	sp,sp,16
ffffffffc02021bc:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02021be:	078a                	slli	a5,a5,0x2
ffffffffc02021c0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02021c2:	000a8717          	auipc	a4,0xa8
ffffffffc02021c6:	6a673703          	ld	a4,1702(a4) # ffffffffc02aa868 <npage>
ffffffffc02021ca:	00e7ff63          	bgeu	a5,a4,ffffffffc02021e8 <get_page+0x50>
ffffffffc02021ce:	60a2                	ld	ra,8(sp)
ffffffffc02021d0:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc02021d2:	fff80537          	lui	a0,0xfff80
ffffffffc02021d6:	97aa                	add	a5,a5,a0
ffffffffc02021d8:	079a                	slli	a5,a5,0x6
ffffffffc02021da:	000a8517          	auipc	a0,0xa8
ffffffffc02021de:	69653503          	ld	a0,1686(a0) # ffffffffc02aa870 <pages>
ffffffffc02021e2:	953e                	add	a0,a0,a5
ffffffffc02021e4:	0141                	addi	sp,sp,16
ffffffffc02021e6:	8082                	ret
ffffffffc02021e8:	c99ff0ef          	jal	ra,ffffffffc0201e80 <pa2page.part.0>

ffffffffc02021ec <unmap_range>:
        tlb_invalidate(pgdir, la);
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc02021ec:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02021ee:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc02021f2:	f486                	sd	ra,104(sp)
ffffffffc02021f4:	f0a2                	sd	s0,96(sp)
ffffffffc02021f6:	eca6                	sd	s1,88(sp)
ffffffffc02021f8:	e8ca                	sd	s2,80(sp)
ffffffffc02021fa:	e4ce                	sd	s3,72(sp)
ffffffffc02021fc:	e0d2                	sd	s4,64(sp)
ffffffffc02021fe:	fc56                	sd	s5,56(sp)
ffffffffc0202200:	f85a                	sd	s6,48(sp)
ffffffffc0202202:	f45e                	sd	s7,40(sp)
ffffffffc0202204:	f062                	sd	s8,32(sp)
ffffffffc0202206:	ec66                	sd	s9,24(sp)
ffffffffc0202208:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020220a:	17d2                	slli	a5,a5,0x34
ffffffffc020220c:	e3ed                	bnez	a5,ffffffffc02022ee <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc020220e:	002007b7          	lui	a5,0x200
ffffffffc0202212:	842e                	mv	s0,a1
ffffffffc0202214:	0ef5ed63          	bltu	a1,a5,ffffffffc020230e <unmap_range+0x122>
ffffffffc0202218:	8932                	mv	s2,a2
ffffffffc020221a:	0ec5fa63          	bgeu	a1,a2,ffffffffc020230e <unmap_range+0x122>
ffffffffc020221e:	4785                	li	a5,1
ffffffffc0202220:	07fe                	slli	a5,a5,0x1f
ffffffffc0202222:	0ec7e663          	bltu	a5,a2,ffffffffc020230e <unmap_range+0x122>
ffffffffc0202226:	89aa                	mv	s3,a0
        }
        if (*ptep != 0)
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0202228:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage)
ffffffffc020222a:	000a8c97          	auipc	s9,0xa8
ffffffffc020222e:	63ec8c93          	addi	s9,s9,1598 # ffffffffc02aa868 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202232:	000a8c17          	auipc	s8,0xa8
ffffffffc0202236:	63ec0c13          	addi	s8,s8,1598 # ffffffffc02aa870 <pages>
ffffffffc020223a:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc020223e:	000a8d17          	auipc	s10,0xa8
ffffffffc0202242:	63ad0d13          	addi	s10,s10,1594 # ffffffffc02aa878 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202246:	00200b37          	lui	s6,0x200
ffffffffc020224a:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc020224e:	4601                	li	a2,0
ffffffffc0202250:	85a2                	mv	a1,s0
ffffffffc0202252:	854e                	mv	a0,s3
ffffffffc0202254:	d1dff0ef          	jal	ra,ffffffffc0201f70 <get_pte>
ffffffffc0202258:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc020225a:	cd29                	beqz	a0,ffffffffc02022b4 <unmap_range+0xc8>
        if (*ptep != 0)
ffffffffc020225c:	611c                	ld	a5,0(a0)
ffffffffc020225e:	e395                	bnez	a5,ffffffffc0202282 <unmap_range+0x96>
        start += PGSIZE;
ffffffffc0202260:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0202262:	ff2466e3          	bltu	s0,s2,ffffffffc020224e <unmap_range+0x62>
}
ffffffffc0202266:	70a6                	ld	ra,104(sp)
ffffffffc0202268:	7406                	ld	s0,96(sp)
ffffffffc020226a:	64e6                	ld	s1,88(sp)
ffffffffc020226c:	6946                	ld	s2,80(sp)
ffffffffc020226e:	69a6                	ld	s3,72(sp)
ffffffffc0202270:	6a06                	ld	s4,64(sp)
ffffffffc0202272:	7ae2                	ld	s5,56(sp)
ffffffffc0202274:	7b42                	ld	s6,48(sp)
ffffffffc0202276:	7ba2                	ld	s7,40(sp)
ffffffffc0202278:	7c02                	ld	s8,32(sp)
ffffffffc020227a:	6ce2                	ld	s9,24(sp)
ffffffffc020227c:	6d42                	ld	s10,16(sp)
ffffffffc020227e:	6165                	addi	sp,sp,112
ffffffffc0202280:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc0202282:	0017f713          	andi	a4,a5,1
ffffffffc0202286:	df69                	beqz	a4,ffffffffc0202260 <unmap_range+0x74>
    if (PPN(pa) >= npage)
ffffffffc0202288:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020228c:	078a                	slli	a5,a5,0x2
ffffffffc020228e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202290:	08e7ff63          	bgeu	a5,a4,ffffffffc020232e <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc0202294:	000c3503          	ld	a0,0(s8)
ffffffffc0202298:	97de                	add	a5,a5,s7
ffffffffc020229a:	079a                	slli	a5,a5,0x6
ffffffffc020229c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020229e:	411c                	lw	a5,0(a0)
ffffffffc02022a0:	fff7871b          	addiw	a4,a5,-1
ffffffffc02022a4:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc02022a6:	cf11                	beqz	a4,ffffffffc02022c2 <unmap_range+0xd6>
        *ptep = 0;
ffffffffc02022a8:	0004b023          	sd	zero,0(s1)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02022ac:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc02022b0:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02022b2:	bf45                	j	ffffffffc0202262 <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02022b4:	945a                	add	s0,s0,s6
ffffffffc02022b6:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc02022ba:	d455                	beqz	s0,ffffffffc0202266 <unmap_range+0x7a>
ffffffffc02022bc:	f92469e3          	bltu	s0,s2,ffffffffc020224e <unmap_range+0x62>
ffffffffc02022c0:	b75d                	j	ffffffffc0202266 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02022c2:	100027f3          	csrr	a5,sstatus
ffffffffc02022c6:	8b89                	andi	a5,a5,2
ffffffffc02022c8:	e799                	bnez	a5,ffffffffc02022d6 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc02022ca:	000d3783          	ld	a5,0(s10)
ffffffffc02022ce:	4585                	li	a1,1
ffffffffc02022d0:	739c                	ld	a5,32(a5)
ffffffffc02022d2:	9782                	jalr	a5
    if (flag)
ffffffffc02022d4:	bfd1                	j	ffffffffc02022a8 <unmap_range+0xbc>
ffffffffc02022d6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02022d8:	edcfe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc02022dc:	000d3783          	ld	a5,0(s10)
ffffffffc02022e0:	6522                	ld	a0,8(sp)
ffffffffc02022e2:	4585                	li	a1,1
ffffffffc02022e4:	739c                	ld	a5,32(a5)
ffffffffc02022e6:	9782                	jalr	a5
        intr_enable();
ffffffffc02022e8:	ec6fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02022ec:	bf75                	j	ffffffffc02022a8 <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022ee:	00004697          	auipc	a3,0x4
ffffffffc02022f2:	4aa68693          	addi	a3,a3,1194 # ffffffffc0206798 <default_pmm_manager+0x160>
ffffffffc02022f6:	00004617          	auipc	a2,0x4
ffffffffc02022fa:	f9260613          	addi	a2,a2,-110 # ffffffffc0206288 <commands+0x828>
ffffffffc02022fe:	12000593          	li	a1,288
ffffffffc0202302:	00004517          	auipc	a0,0x4
ffffffffc0202306:	48650513          	addi	a0,a0,1158 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc020230a:	984fe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020230e:	00004697          	auipc	a3,0x4
ffffffffc0202312:	4ba68693          	addi	a3,a3,1210 # ffffffffc02067c8 <default_pmm_manager+0x190>
ffffffffc0202316:	00004617          	auipc	a2,0x4
ffffffffc020231a:	f7260613          	addi	a2,a2,-142 # ffffffffc0206288 <commands+0x828>
ffffffffc020231e:	12100593          	li	a1,289
ffffffffc0202322:	00004517          	auipc	a0,0x4
ffffffffc0202326:	46650513          	addi	a0,a0,1126 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc020232a:	964fe0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc020232e:	b53ff0ef          	jal	ra,ffffffffc0201e80 <pa2page.part.0>

ffffffffc0202332 <exit_range>:
{
ffffffffc0202332:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202334:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0202338:	fc86                	sd	ra,120(sp)
ffffffffc020233a:	f8a2                	sd	s0,112(sp)
ffffffffc020233c:	f4a6                	sd	s1,104(sp)
ffffffffc020233e:	f0ca                	sd	s2,96(sp)
ffffffffc0202340:	ecce                	sd	s3,88(sp)
ffffffffc0202342:	e8d2                	sd	s4,80(sp)
ffffffffc0202344:	e4d6                	sd	s5,72(sp)
ffffffffc0202346:	e0da                	sd	s6,64(sp)
ffffffffc0202348:	fc5e                	sd	s7,56(sp)
ffffffffc020234a:	f862                	sd	s8,48(sp)
ffffffffc020234c:	f466                	sd	s9,40(sp)
ffffffffc020234e:	f06a                	sd	s10,32(sp)
ffffffffc0202350:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202352:	17d2                	slli	a5,a5,0x34
ffffffffc0202354:	20079a63          	bnez	a5,ffffffffc0202568 <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc0202358:	002007b7          	lui	a5,0x200
ffffffffc020235c:	24f5e463          	bltu	a1,a5,ffffffffc02025a4 <exit_range+0x272>
ffffffffc0202360:	8ab2                	mv	s5,a2
ffffffffc0202362:	24c5f163          	bgeu	a1,a2,ffffffffc02025a4 <exit_range+0x272>
ffffffffc0202366:	4785                	li	a5,1
ffffffffc0202368:	07fe                	slli	a5,a5,0x1f
ffffffffc020236a:	22c7ed63          	bltu	a5,a2,ffffffffc02025a4 <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc020236e:	c00009b7          	lui	s3,0xc0000
ffffffffc0202372:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202376:	ffe00937          	lui	s2,0xffe00
ffffffffc020237a:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc020237e:	5cfd                	li	s9,-1
ffffffffc0202380:	8c2a                	mv	s8,a0
ffffffffc0202382:	0125f933          	and	s2,a1,s2
ffffffffc0202386:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage)
ffffffffc0202388:	000a8d17          	auipc	s10,0xa8
ffffffffc020238c:	4e0d0d13          	addi	s10,s10,1248 # ffffffffc02aa868 <npage>
    return KADDR(page2pa(page));
ffffffffc0202390:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0202394:	000a8717          	auipc	a4,0xa8
ffffffffc0202398:	4dc70713          	addi	a4,a4,1244 # ffffffffc02aa870 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc020239c:	000a8d97          	auipc	s11,0xa8
ffffffffc02023a0:	4dcd8d93          	addi	s11,s11,1244 # ffffffffc02aa878 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02023a4:	c0000437          	lui	s0,0xc0000
ffffffffc02023a8:	944e                	add	s0,s0,s3
ffffffffc02023aa:	8079                	srli	s0,s0,0x1e
ffffffffc02023ac:	1ff47413          	andi	s0,s0,511
ffffffffc02023b0:	040e                	slli	s0,s0,0x3
ffffffffc02023b2:	9462                	add	s0,s0,s8
ffffffffc02023b4:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ec8>
        if (pde1 & PTE_V)
ffffffffc02023b8:	001a7793          	andi	a5,s4,1
ffffffffc02023bc:	eb99                	bnez	a5,ffffffffc02023d2 <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc02023be:	12098463          	beqz	s3,ffffffffc02024e6 <exit_range+0x1b4>
ffffffffc02023c2:	400007b7          	lui	a5,0x40000
ffffffffc02023c6:	97ce                	add	a5,a5,s3
ffffffffc02023c8:	894e                	mv	s2,s3
ffffffffc02023ca:	1159fe63          	bgeu	s3,s5,ffffffffc02024e6 <exit_range+0x1b4>
ffffffffc02023ce:	89be                	mv	s3,a5
ffffffffc02023d0:	bfd1                	j	ffffffffc02023a4 <exit_range+0x72>
    if (PPN(pa) >= npage)
ffffffffc02023d2:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02023d6:	0a0a                	slli	s4,s4,0x2
ffffffffc02023d8:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage)
ffffffffc02023dc:	1cfa7263          	bgeu	s4,a5,ffffffffc02025a0 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02023e0:	fff80637          	lui	a2,0xfff80
ffffffffc02023e4:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc02023e6:	000806b7          	lui	a3,0x80
ffffffffc02023ea:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc02023ec:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc02023f0:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02023f2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02023f4:	18f5fa63          	bgeu	a1,a5,ffffffffc0202588 <exit_range+0x256>
ffffffffc02023f8:	000a8817          	auipc	a6,0xa8
ffffffffc02023fc:	48880813          	addi	a6,a6,1160 # ffffffffc02aa880 <va_pa_offset>
ffffffffc0202400:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc0202404:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc0202406:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc020240a:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc020240c:	00080337          	lui	t1,0x80
ffffffffc0202410:	6885                	lui	a7,0x1
ffffffffc0202412:	a819                	j	ffffffffc0202428 <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc0202414:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc0202416:	002007b7          	lui	a5,0x200
ffffffffc020241a:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc020241c:	08090c63          	beqz	s2,ffffffffc02024b4 <exit_range+0x182>
ffffffffc0202420:	09397a63          	bgeu	s2,s3,ffffffffc02024b4 <exit_range+0x182>
ffffffffc0202424:	0f597063          	bgeu	s2,s5,ffffffffc0202504 <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0202428:	01595493          	srli	s1,s2,0x15
ffffffffc020242c:	1ff4f493          	andi	s1,s1,511
ffffffffc0202430:	048e                	slli	s1,s1,0x3
ffffffffc0202432:	94da                	add	s1,s1,s6
ffffffffc0202434:	609c                	ld	a5,0(s1)
                if (pde0 & PTE_V)
ffffffffc0202436:	0017f693          	andi	a3,a5,1
ffffffffc020243a:	dee9                	beqz	a3,ffffffffc0202414 <exit_range+0xe2>
    if (PPN(pa) >= npage)
ffffffffc020243c:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202440:	078a                	slli	a5,a5,0x2
ffffffffc0202442:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202444:	14b7fe63          	bgeu	a5,a1,ffffffffc02025a0 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202448:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc020244a:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc020244e:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0202452:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202456:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202458:	12bef863          	bgeu	t4,a1,ffffffffc0202588 <exit_range+0x256>
ffffffffc020245c:	00083783          	ld	a5,0(a6)
ffffffffc0202460:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc0202462:	011685b3          	add	a1,a3,a7
                        if (pt[i] & PTE_V)
ffffffffc0202466:	629c                	ld	a5,0(a3)
ffffffffc0202468:	8b85                	andi	a5,a5,1
ffffffffc020246a:	f7d5                	bnez	a5,ffffffffc0202416 <exit_range+0xe4>
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc020246c:	06a1                	addi	a3,a3,8
ffffffffc020246e:	fed59ce3          	bne	a1,a3,ffffffffc0202466 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc0202472:	631c                	ld	a5,0(a4)
ffffffffc0202474:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202476:	100027f3          	csrr	a5,sstatus
ffffffffc020247a:	8b89                	andi	a5,a5,2
ffffffffc020247c:	e7d9                	bnez	a5,ffffffffc020250a <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc020247e:	000db783          	ld	a5,0(s11)
ffffffffc0202482:	4585                	li	a1,1
ffffffffc0202484:	e032                	sd	a2,0(sp)
ffffffffc0202486:	739c                	ld	a5,32(a5)
ffffffffc0202488:	9782                	jalr	a5
    if (flag)
ffffffffc020248a:	6602                	ld	a2,0(sp)
ffffffffc020248c:	000a8817          	auipc	a6,0xa8
ffffffffc0202490:	3f480813          	addi	a6,a6,1012 # ffffffffc02aa880 <va_pa_offset>
ffffffffc0202494:	fff80e37          	lui	t3,0xfff80
ffffffffc0202498:	00080337          	lui	t1,0x80
ffffffffc020249c:	6885                	lui	a7,0x1
ffffffffc020249e:	000a8717          	auipc	a4,0xa8
ffffffffc02024a2:	3d270713          	addi	a4,a4,978 # ffffffffc02aa870 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc02024a6:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc02024aa:	002007b7          	lui	a5,0x200
ffffffffc02024ae:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc02024b0:	f60918e3          	bnez	s2,ffffffffc0202420 <exit_range+0xee>
            if (free_pd0)
ffffffffc02024b4:	f00b85e3          	beqz	s7,ffffffffc02023be <exit_range+0x8c>
    if (PPN(pa) >= npage)
ffffffffc02024b8:	000d3783          	ld	a5,0(s10)
ffffffffc02024bc:	0efa7263          	bgeu	s4,a5,ffffffffc02025a0 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02024c0:	6308                	ld	a0,0(a4)
ffffffffc02024c2:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02024c4:	100027f3          	csrr	a5,sstatus
ffffffffc02024c8:	8b89                	andi	a5,a5,2
ffffffffc02024ca:	efad                	bnez	a5,ffffffffc0202544 <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc02024cc:	000db783          	ld	a5,0(s11)
ffffffffc02024d0:	4585                	li	a1,1
ffffffffc02024d2:	739c                	ld	a5,32(a5)
ffffffffc02024d4:	9782                	jalr	a5
ffffffffc02024d6:	000a8717          	auipc	a4,0xa8
ffffffffc02024da:	39a70713          	addi	a4,a4,922 # ffffffffc02aa870 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc02024de:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc02024e2:	ee0990e3          	bnez	s3,ffffffffc02023c2 <exit_range+0x90>
}
ffffffffc02024e6:	70e6                	ld	ra,120(sp)
ffffffffc02024e8:	7446                	ld	s0,112(sp)
ffffffffc02024ea:	74a6                	ld	s1,104(sp)
ffffffffc02024ec:	7906                	ld	s2,96(sp)
ffffffffc02024ee:	69e6                	ld	s3,88(sp)
ffffffffc02024f0:	6a46                	ld	s4,80(sp)
ffffffffc02024f2:	6aa6                	ld	s5,72(sp)
ffffffffc02024f4:	6b06                	ld	s6,64(sp)
ffffffffc02024f6:	7be2                	ld	s7,56(sp)
ffffffffc02024f8:	7c42                	ld	s8,48(sp)
ffffffffc02024fa:	7ca2                	ld	s9,40(sp)
ffffffffc02024fc:	7d02                	ld	s10,32(sp)
ffffffffc02024fe:	6de2                	ld	s11,24(sp)
ffffffffc0202500:	6109                	addi	sp,sp,128
ffffffffc0202502:	8082                	ret
            if (free_pd0)
ffffffffc0202504:	ea0b8fe3          	beqz	s7,ffffffffc02023c2 <exit_range+0x90>
ffffffffc0202508:	bf45                	j	ffffffffc02024b8 <exit_range+0x186>
ffffffffc020250a:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc020250c:	e42a                	sd	a0,8(sp)
ffffffffc020250e:	ca6fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202512:	000db783          	ld	a5,0(s11)
ffffffffc0202516:	6522                	ld	a0,8(sp)
ffffffffc0202518:	4585                	li	a1,1
ffffffffc020251a:	739c                	ld	a5,32(a5)
ffffffffc020251c:	9782                	jalr	a5
        intr_enable();
ffffffffc020251e:	c90fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202522:	6602                	ld	a2,0(sp)
ffffffffc0202524:	000a8717          	auipc	a4,0xa8
ffffffffc0202528:	34c70713          	addi	a4,a4,844 # ffffffffc02aa870 <pages>
ffffffffc020252c:	6885                	lui	a7,0x1
ffffffffc020252e:	00080337          	lui	t1,0x80
ffffffffc0202532:	fff80e37          	lui	t3,0xfff80
ffffffffc0202536:	000a8817          	auipc	a6,0xa8
ffffffffc020253a:	34a80813          	addi	a6,a6,842 # ffffffffc02aa880 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc020253e:	0004b023          	sd	zero,0(s1)
ffffffffc0202542:	b7a5                	j	ffffffffc02024aa <exit_range+0x178>
ffffffffc0202544:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0202546:	c6efe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020254a:	000db783          	ld	a5,0(s11)
ffffffffc020254e:	6502                	ld	a0,0(sp)
ffffffffc0202550:	4585                	li	a1,1
ffffffffc0202552:	739c                	ld	a5,32(a5)
ffffffffc0202554:	9782                	jalr	a5
        intr_enable();
ffffffffc0202556:	c58fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020255a:	000a8717          	auipc	a4,0xa8
ffffffffc020255e:	31670713          	addi	a4,a4,790 # ffffffffc02aa870 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202562:	00043023          	sd	zero,0(s0)
ffffffffc0202566:	bfb5                	j	ffffffffc02024e2 <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202568:	00004697          	auipc	a3,0x4
ffffffffc020256c:	23068693          	addi	a3,a3,560 # ffffffffc0206798 <default_pmm_manager+0x160>
ffffffffc0202570:	00004617          	auipc	a2,0x4
ffffffffc0202574:	d1860613          	addi	a2,a2,-744 # ffffffffc0206288 <commands+0x828>
ffffffffc0202578:	13500593          	li	a1,309
ffffffffc020257c:	00004517          	auipc	a0,0x4
ffffffffc0202580:	20c50513          	addi	a0,a0,524 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0202584:	f0bfd0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc0202588:	00004617          	auipc	a2,0x4
ffffffffc020258c:	0e860613          	addi	a2,a2,232 # ffffffffc0206670 <default_pmm_manager+0x38>
ffffffffc0202590:	07100593          	li	a1,113
ffffffffc0202594:	00004517          	auipc	a0,0x4
ffffffffc0202598:	10450513          	addi	a0,a0,260 # ffffffffc0206698 <default_pmm_manager+0x60>
ffffffffc020259c:	ef3fd0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc02025a0:	8e1ff0ef          	jal	ra,ffffffffc0201e80 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc02025a4:	00004697          	auipc	a3,0x4
ffffffffc02025a8:	22468693          	addi	a3,a3,548 # ffffffffc02067c8 <default_pmm_manager+0x190>
ffffffffc02025ac:	00004617          	auipc	a2,0x4
ffffffffc02025b0:	cdc60613          	addi	a2,a2,-804 # ffffffffc0206288 <commands+0x828>
ffffffffc02025b4:	13600593          	li	a1,310
ffffffffc02025b8:	00004517          	auipc	a0,0x4
ffffffffc02025bc:	1d050513          	addi	a0,a0,464 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc02025c0:	ecffd0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02025c4 <page_remove>:
{
ffffffffc02025c4:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02025c6:	4601                	li	a2,0
{
ffffffffc02025c8:	ec26                	sd	s1,24(sp)
ffffffffc02025ca:	f406                	sd	ra,40(sp)
ffffffffc02025cc:	f022                	sd	s0,32(sp)
ffffffffc02025ce:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02025d0:	9a1ff0ef          	jal	ra,ffffffffc0201f70 <get_pte>
    if (ptep != NULL)
ffffffffc02025d4:	c511                	beqz	a0,ffffffffc02025e0 <page_remove+0x1c>
    if (*ptep & PTE_V)
ffffffffc02025d6:	611c                	ld	a5,0(a0)
ffffffffc02025d8:	842a                	mv	s0,a0
ffffffffc02025da:	0017f713          	andi	a4,a5,1
ffffffffc02025de:	e711                	bnez	a4,ffffffffc02025ea <page_remove+0x26>
}
ffffffffc02025e0:	70a2                	ld	ra,40(sp)
ffffffffc02025e2:	7402                	ld	s0,32(sp)
ffffffffc02025e4:	64e2                	ld	s1,24(sp)
ffffffffc02025e6:	6145                	addi	sp,sp,48
ffffffffc02025e8:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02025ea:	078a                	slli	a5,a5,0x2
ffffffffc02025ec:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02025ee:	000a8717          	auipc	a4,0xa8
ffffffffc02025f2:	27a73703          	ld	a4,634(a4) # ffffffffc02aa868 <npage>
ffffffffc02025f6:	06e7f363          	bgeu	a5,a4,ffffffffc020265c <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc02025fa:	fff80537          	lui	a0,0xfff80
ffffffffc02025fe:	97aa                	add	a5,a5,a0
ffffffffc0202600:	079a                	slli	a5,a5,0x6
ffffffffc0202602:	000a8517          	auipc	a0,0xa8
ffffffffc0202606:	26e53503          	ld	a0,622(a0) # ffffffffc02aa870 <pages>
ffffffffc020260a:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020260c:	411c                	lw	a5,0(a0)
ffffffffc020260e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202612:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc0202614:	cb11                	beqz	a4,ffffffffc0202628 <page_remove+0x64>
        *ptep = 0;
ffffffffc0202616:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020261a:	12048073          	sfence.vma	s1
}
ffffffffc020261e:	70a2                	ld	ra,40(sp)
ffffffffc0202620:	7402                	ld	s0,32(sp)
ffffffffc0202622:	64e2                	ld	s1,24(sp)
ffffffffc0202624:	6145                	addi	sp,sp,48
ffffffffc0202626:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202628:	100027f3          	csrr	a5,sstatus
ffffffffc020262c:	8b89                	andi	a5,a5,2
ffffffffc020262e:	eb89                	bnez	a5,ffffffffc0202640 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0202630:	000a8797          	auipc	a5,0xa8
ffffffffc0202634:	2487b783          	ld	a5,584(a5) # ffffffffc02aa878 <pmm_manager>
ffffffffc0202638:	739c                	ld	a5,32(a5)
ffffffffc020263a:	4585                	li	a1,1
ffffffffc020263c:	9782                	jalr	a5
    if (flag)
ffffffffc020263e:	bfe1                	j	ffffffffc0202616 <page_remove+0x52>
        intr_disable();
ffffffffc0202640:	e42a                	sd	a0,8(sp)
ffffffffc0202642:	b72fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202646:	000a8797          	auipc	a5,0xa8
ffffffffc020264a:	2327b783          	ld	a5,562(a5) # ffffffffc02aa878 <pmm_manager>
ffffffffc020264e:	739c                	ld	a5,32(a5)
ffffffffc0202650:	6522                	ld	a0,8(sp)
ffffffffc0202652:	4585                	li	a1,1
ffffffffc0202654:	9782                	jalr	a5
        intr_enable();
ffffffffc0202656:	b58fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020265a:	bf75                	j	ffffffffc0202616 <page_remove+0x52>
ffffffffc020265c:	825ff0ef          	jal	ra,ffffffffc0201e80 <pa2page.part.0>

ffffffffc0202660 <page_insert>:
{
ffffffffc0202660:	7139                	addi	sp,sp,-64
ffffffffc0202662:	e852                	sd	s4,16(sp)
ffffffffc0202664:	8a32                	mv	s4,a2
ffffffffc0202666:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202668:	4605                	li	a2,1
{
ffffffffc020266a:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020266c:	85d2                	mv	a1,s4
{
ffffffffc020266e:	f426                	sd	s1,40(sp)
ffffffffc0202670:	fc06                	sd	ra,56(sp)
ffffffffc0202672:	f04a                	sd	s2,32(sp)
ffffffffc0202674:	ec4e                	sd	s3,24(sp)
ffffffffc0202676:	e456                	sd	s5,8(sp)
ffffffffc0202678:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020267a:	8f7ff0ef          	jal	ra,ffffffffc0201f70 <get_pte>
    if (ptep == NULL)
ffffffffc020267e:	c961                	beqz	a0,ffffffffc020274e <page_insert+0xee>
    page->ref += 1;
ffffffffc0202680:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V)
ffffffffc0202682:	611c                	ld	a5,0(a0)
ffffffffc0202684:	89aa                	mv	s3,a0
ffffffffc0202686:	0016871b          	addiw	a4,a3,1
ffffffffc020268a:	c018                	sw	a4,0(s0)
ffffffffc020268c:	0017f713          	andi	a4,a5,1
ffffffffc0202690:	ef05                	bnez	a4,ffffffffc02026c8 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0202692:	000a8717          	auipc	a4,0xa8
ffffffffc0202696:	1de73703          	ld	a4,478(a4) # ffffffffc02aa870 <pages>
ffffffffc020269a:	8c19                	sub	s0,s0,a4
ffffffffc020269c:	000807b7          	lui	a5,0x80
ffffffffc02026a0:	8419                	srai	s0,s0,0x6
ffffffffc02026a2:	943e                	add	s0,s0,a5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02026a4:	042a                	slli	s0,s0,0xa
ffffffffc02026a6:	8cc1                	or	s1,s1,s0
ffffffffc02026a8:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02026ac:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ec8>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02026b0:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc02026b4:	4501                	li	a0,0
}
ffffffffc02026b6:	70e2                	ld	ra,56(sp)
ffffffffc02026b8:	7442                	ld	s0,48(sp)
ffffffffc02026ba:	74a2                	ld	s1,40(sp)
ffffffffc02026bc:	7902                	ld	s2,32(sp)
ffffffffc02026be:	69e2                	ld	s3,24(sp)
ffffffffc02026c0:	6a42                	ld	s4,16(sp)
ffffffffc02026c2:	6aa2                	ld	s5,8(sp)
ffffffffc02026c4:	6121                	addi	sp,sp,64
ffffffffc02026c6:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02026c8:	078a                	slli	a5,a5,0x2
ffffffffc02026ca:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02026cc:	000a8717          	auipc	a4,0xa8
ffffffffc02026d0:	19c73703          	ld	a4,412(a4) # ffffffffc02aa868 <npage>
ffffffffc02026d4:	06e7ff63          	bgeu	a5,a4,ffffffffc0202752 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc02026d8:	000a8a97          	auipc	s5,0xa8
ffffffffc02026dc:	198a8a93          	addi	s5,s5,408 # ffffffffc02aa870 <pages>
ffffffffc02026e0:	000ab703          	ld	a4,0(s5)
ffffffffc02026e4:	fff80937          	lui	s2,0xfff80
ffffffffc02026e8:	993e                	add	s2,s2,a5
ffffffffc02026ea:	091a                	slli	s2,s2,0x6
ffffffffc02026ec:	993a                	add	s2,s2,a4
        if (p == page)
ffffffffc02026ee:	01240c63          	beq	s0,s2,ffffffffc0202706 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc02026f2:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fcd575c>
ffffffffc02026f6:	fff7869b          	addiw	a3,a5,-1
ffffffffc02026fa:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) == 0)
ffffffffc02026fe:	c691                	beqz	a3,ffffffffc020270a <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202700:	120a0073          	sfence.vma	s4
}
ffffffffc0202704:	bf59                	j	ffffffffc020269a <page_insert+0x3a>
ffffffffc0202706:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202708:	bf49                	j	ffffffffc020269a <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020270a:	100027f3          	csrr	a5,sstatus
ffffffffc020270e:	8b89                	andi	a5,a5,2
ffffffffc0202710:	ef91                	bnez	a5,ffffffffc020272c <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc0202712:	000a8797          	auipc	a5,0xa8
ffffffffc0202716:	1667b783          	ld	a5,358(a5) # ffffffffc02aa878 <pmm_manager>
ffffffffc020271a:	739c                	ld	a5,32(a5)
ffffffffc020271c:	4585                	li	a1,1
ffffffffc020271e:	854a                	mv	a0,s2
ffffffffc0202720:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0202722:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202726:	120a0073          	sfence.vma	s4
ffffffffc020272a:	bf85                	j	ffffffffc020269a <page_insert+0x3a>
        intr_disable();
ffffffffc020272c:	a88fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202730:	000a8797          	auipc	a5,0xa8
ffffffffc0202734:	1487b783          	ld	a5,328(a5) # ffffffffc02aa878 <pmm_manager>
ffffffffc0202738:	739c                	ld	a5,32(a5)
ffffffffc020273a:	4585                	li	a1,1
ffffffffc020273c:	854a                	mv	a0,s2
ffffffffc020273e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202740:	a6efe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202744:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202748:	120a0073          	sfence.vma	s4
ffffffffc020274c:	b7b9                	j	ffffffffc020269a <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc020274e:	5571                	li	a0,-4
ffffffffc0202750:	b79d                	j	ffffffffc02026b6 <page_insert+0x56>
ffffffffc0202752:	f2eff0ef          	jal	ra,ffffffffc0201e80 <pa2page.part.0>

ffffffffc0202756 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202756:	00004797          	auipc	a5,0x4
ffffffffc020275a:	ee278793          	addi	a5,a5,-286 # ffffffffc0206638 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020275e:	638c                	ld	a1,0(a5)
{
ffffffffc0202760:	7159                	addi	sp,sp,-112
ffffffffc0202762:	f85a                	sd	s6,48(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202764:	00004517          	auipc	a0,0x4
ffffffffc0202768:	07c50513          	addi	a0,a0,124 # ffffffffc02067e0 <default_pmm_manager+0x1a8>
    pmm_manager = &default_pmm_manager;
ffffffffc020276c:	000a8b17          	auipc	s6,0xa8
ffffffffc0202770:	10cb0b13          	addi	s6,s6,268 # ffffffffc02aa878 <pmm_manager>
{
ffffffffc0202774:	f486                	sd	ra,104(sp)
ffffffffc0202776:	e8ca                	sd	s2,80(sp)
ffffffffc0202778:	e4ce                	sd	s3,72(sp)
ffffffffc020277a:	f0a2                	sd	s0,96(sp)
ffffffffc020277c:	eca6                	sd	s1,88(sp)
ffffffffc020277e:	e0d2                	sd	s4,64(sp)
ffffffffc0202780:	fc56                	sd	s5,56(sp)
ffffffffc0202782:	f45e                	sd	s7,40(sp)
ffffffffc0202784:	f062                	sd	s8,32(sp)
ffffffffc0202786:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202788:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020278c:	a09fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    pmm_manager->init();
ffffffffc0202790:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0202794:	000a8997          	auipc	s3,0xa8
ffffffffc0202798:	0ec98993          	addi	s3,s3,236 # ffffffffc02aa880 <va_pa_offset>
    pmm_manager->init();
ffffffffc020279c:	679c                	ld	a5,8(a5)
ffffffffc020279e:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02027a0:	57f5                	li	a5,-3
ffffffffc02027a2:	07fa                	slli	a5,a5,0x1e
ffffffffc02027a4:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc02027a8:	9f2fe0ef          	jal	ra,ffffffffc020099a <get_memory_base>
ffffffffc02027ac:	892a                	mv	s2,a0
    uint64_t mem_size = get_memory_size();
ffffffffc02027ae:	9f6fe0ef          	jal	ra,ffffffffc02009a4 <get_memory_size>
    if (mem_size == 0)
ffffffffc02027b2:	200505e3          	beqz	a0,ffffffffc02031bc <pmm_init+0xa66>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc02027b6:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc02027b8:	00004517          	auipc	a0,0x4
ffffffffc02027bc:	06050513          	addi	a0,a0,96 # ffffffffc0206818 <default_pmm_manager+0x1e0>
ffffffffc02027c0:	9d5fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc02027c4:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02027c8:	fff40693          	addi	a3,s0,-1
ffffffffc02027cc:	864a                	mv	a2,s2
ffffffffc02027ce:	85a6                	mv	a1,s1
ffffffffc02027d0:	00004517          	auipc	a0,0x4
ffffffffc02027d4:	06050513          	addi	a0,a0,96 # ffffffffc0206830 <default_pmm_manager+0x1f8>
ffffffffc02027d8:	9bdfd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc02027dc:	c8000737          	lui	a4,0xc8000
ffffffffc02027e0:	87a2                	mv	a5,s0
ffffffffc02027e2:	54876163          	bltu	a4,s0,ffffffffc0202d24 <pmm_init+0x5ce>
ffffffffc02027e6:	757d                	lui	a0,0xfffff
ffffffffc02027e8:	000a9617          	auipc	a2,0xa9
ffffffffc02027ec:	0bb60613          	addi	a2,a2,187 # ffffffffc02ab8a3 <end+0xfff>
ffffffffc02027f0:	8e69                	and	a2,a2,a0
ffffffffc02027f2:	000a8497          	auipc	s1,0xa8
ffffffffc02027f6:	07648493          	addi	s1,s1,118 # ffffffffc02aa868 <npage>
ffffffffc02027fa:	00c7d513          	srli	a0,a5,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02027fe:	000a8b97          	auipc	s7,0xa8
ffffffffc0202802:	072b8b93          	addi	s7,s7,114 # ffffffffc02aa870 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0202806:	e088                	sd	a0,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202808:	00cbb023          	sd	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc020280c:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202810:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202812:	02f50863          	beq	a0,a5,ffffffffc0202842 <pmm_init+0xec>
ffffffffc0202816:	4781                	li	a5,0
ffffffffc0202818:	4585                	li	a1,1
ffffffffc020281a:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc020281e:	00679513          	slli	a0,a5,0x6
ffffffffc0202822:	9532                	add	a0,a0,a2
ffffffffc0202824:	00850713          	addi	a4,a0,8 # fffffffffffff008 <end+0x3fd54764>
ffffffffc0202828:	40b7302f          	amoor.d	zero,a1,(a4)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc020282c:	6088                	ld	a0,0(s1)
ffffffffc020282e:	0785                	addi	a5,a5,1
        SetPageReserved(pages + i);
ffffffffc0202830:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202834:	00d50733          	add	a4,a0,a3
ffffffffc0202838:	fee7e3e3          	bltu	a5,a4,ffffffffc020281e <pmm_init+0xc8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020283c:	071a                	slli	a4,a4,0x6
ffffffffc020283e:	00e606b3          	add	a3,a2,a4
ffffffffc0202842:	c02007b7          	lui	a5,0xc0200
ffffffffc0202846:	2ef6ece3          	bltu	a3,a5,ffffffffc020333e <pmm_init+0xbe8>
ffffffffc020284a:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc020284e:	77fd                	lui	a5,0xfffff
ffffffffc0202850:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202852:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc0202854:	5086eb63          	bltu	a3,s0,ffffffffc0202d6a <pmm_init+0x614>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202858:	00004517          	auipc	a0,0x4
ffffffffc020285c:	00050513          	mv	a0,a0
ffffffffc0202860:	935fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc0202864:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0202868:	000a8917          	auipc	s2,0xa8
ffffffffc020286c:	ff890913          	addi	s2,s2,-8 # ffffffffc02aa860 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc0202870:	7b9c                	ld	a5,48(a5)
ffffffffc0202872:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202874:	00004517          	auipc	a0,0x4
ffffffffc0202878:	ffc50513          	addi	a0,a0,-4 # ffffffffc0206870 <default_pmm_manager+0x238>
ffffffffc020287c:	919fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0202880:	00007697          	auipc	a3,0x7
ffffffffc0202884:	78068693          	addi	a3,a3,1920 # ffffffffc020a000 <boot_page_table_sv39>
ffffffffc0202888:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc020288c:	c02007b7          	lui	a5,0xc0200
ffffffffc0202890:	28f6ebe3          	bltu	a3,a5,ffffffffc0203326 <pmm_init+0xbd0>
ffffffffc0202894:	0009b783          	ld	a5,0(s3)
ffffffffc0202898:	8e9d                	sub	a3,a3,a5
ffffffffc020289a:	000a8797          	auipc	a5,0xa8
ffffffffc020289e:	fad7bf23          	sd	a3,-66(a5) # ffffffffc02aa858 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02028a2:	100027f3          	csrr	a5,sstatus
ffffffffc02028a6:	8b89                	andi	a5,a5,2
ffffffffc02028a8:	4a079763          	bnez	a5,ffffffffc0202d56 <pmm_init+0x600>
        ret = pmm_manager->nr_free_pages();
ffffffffc02028ac:	000b3783          	ld	a5,0(s6)
ffffffffc02028b0:	779c                	ld	a5,40(a5)
ffffffffc02028b2:	9782                	jalr	a5
ffffffffc02028b4:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02028b6:	6098                	ld	a4,0(s1)
ffffffffc02028b8:	c80007b7          	lui	a5,0xc8000
ffffffffc02028bc:	83b1                	srli	a5,a5,0xc
ffffffffc02028be:	66e7e363          	bltu	a5,a4,ffffffffc0202f24 <pmm_init+0x7ce>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc02028c2:	00093503          	ld	a0,0(s2)
ffffffffc02028c6:	62050f63          	beqz	a0,ffffffffc0202f04 <pmm_init+0x7ae>
ffffffffc02028ca:	03451793          	slli	a5,a0,0x34
ffffffffc02028ce:	62079b63          	bnez	a5,ffffffffc0202f04 <pmm_init+0x7ae>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc02028d2:	4601                	li	a2,0
ffffffffc02028d4:	4581                	li	a1,0
ffffffffc02028d6:	8c3ff0ef          	jal	ra,ffffffffc0202198 <get_page>
ffffffffc02028da:	60051563          	bnez	a0,ffffffffc0202ee4 <pmm_init+0x78e>
ffffffffc02028de:	100027f3          	csrr	a5,sstatus
ffffffffc02028e2:	8b89                	andi	a5,a5,2
ffffffffc02028e4:	44079e63          	bnez	a5,ffffffffc0202d40 <pmm_init+0x5ea>
        page = pmm_manager->alloc_pages(n);
ffffffffc02028e8:	000b3783          	ld	a5,0(s6)
ffffffffc02028ec:	4505                	li	a0,1
ffffffffc02028ee:	6f9c                	ld	a5,24(a5)
ffffffffc02028f0:	9782                	jalr	a5
ffffffffc02028f2:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc02028f4:	00093503          	ld	a0,0(s2)
ffffffffc02028f8:	4681                	li	a3,0
ffffffffc02028fa:	4601                	li	a2,0
ffffffffc02028fc:	85d2                	mv	a1,s4
ffffffffc02028fe:	d63ff0ef          	jal	ra,ffffffffc0202660 <page_insert>
ffffffffc0202902:	26051ae3          	bnez	a0,ffffffffc0203376 <pmm_init+0xc20>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0202906:	00093503          	ld	a0,0(s2)
ffffffffc020290a:	4601                	li	a2,0
ffffffffc020290c:	4581                	li	a1,0
ffffffffc020290e:	e62ff0ef          	jal	ra,ffffffffc0201f70 <get_pte>
ffffffffc0202912:	240502e3          	beqz	a0,ffffffffc0203356 <pmm_init+0xc00>
    assert(pte2page(*ptep) == p1);
ffffffffc0202916:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202918:	0017f713          	andi	a4,a5,1
ffffffffc020291c:	5a070263          	beqz	a4,ffffffffc0202ec0 <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc0202920:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202922:	078a                	slli	a5,a5,0x2
ffffffffc0202924:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202926:	58e7fb63          	bgeu	a5,a4,ffffffffc0202ebc <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc020292a:	000bb683          	ld	a3,0(s7)
ffffffffc020292e:	fff80637          	lui	a2,0xfff80
ffffffffc0202932:	97b2                	add	a5,a5,a2
ffffffffc0202934:	079a                	slli	a5,a5,0x6
ffffffffc0202936:	97b6                	add	a5,a5,a3
ffffffffc0202938:	14fa17e3          	bne	s4,a5,ffffffffc0203286 <pmm_init+0xb30>
    assert(page_ref(p1) == 1);
ffffffffc020293c:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc0202940:	4785                	li	a5,1
ffffffffc0202942:	12f692e3          	bne	a3,a5,ffffffffc0203266 <pmm_init+0xb10>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0202946:	00093503          	ld	a0,0(s2)
ffffffffc020294a:	77fd                	lui	a5,0xfffff
ffffffffc020294c:	6114                	ld	a3,0(a0)
ffffffffc020294e:	068a                	slli	a3,a3,0x2
ffffffffc0202950:	8efd                	and	a3,a3,a5
ffffffffc0202952:	00c6d613          	srli	a2,a3,0xc
ffffffffc0202956:	0ee67ce3          	bgeu	a2,a4,ffffffffc020324e <pmm_init+0xaf8>
ffffffffc020295a:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020295e:	96e2                	add	a3,a3,s8
ffffffffc0202960:	0006ba83          	ld	s5,0(a3)
ffffffffc0202964:	0a8a                	slli	s5,s5,0x2
ffffffffc0202966:	00fafab3          	and	s5,s5,a5
ffffffffc020296a:	00cad793          	srli	a5,s5,0xc
ffffffffc020296e:	0ce7f3e3          	bgeu	a5,a4,ffffffffc0203234 <pmm_init+0xade>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202972:	4601                	li	a2,0
ffffffffc0202974:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202976:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202978:	df8ff0ef          	jal	ra,ffffffffc0201f70 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020297c:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc020297e:	55551363          	bne	a0,s5,ffffffffc0202ec4 <pmm_init+0x76e>
ffffffffc0202982:	100027f3          	csrr	a5,sstatus
ffffffffc0202986:	8b89                	andi	a5,a5,2
ffffffffc0202988:	3a079163          	bnez	a5,ffffffffc0202d2a <pmm_init+0x5d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc020298c:	000b3783          	ld	a5,0(s6)
ffffffffc0202990:	4505                	li	a0,1
ffffffffc0202992:	6f9c                	ld	a5,24(a5)
ffffffffc0202994:	9782                	jalr	a5
ffffffffc0202996:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202998:	00093503          	ld	a0,0(s2)
ffffffffc020299c:	46d1                	li	a3,20
ffffffffc020299e:	6605                	lui	a2,0x1
ffffffffc02029a0:	85e2                	mv	a1,s8
ffffffffc02029a2:	cbfff0ef          	jal	ra,ffffffffc0202660 <page_insert>
ffffffffc02029a6:	060517e3          	bnez	a0,ffffffffc0203214 <pmm_init+0xabe>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02029aa:	00093503          	ld	a0,0(s2)
ffffffffc02029ae:	4601                	li	a2,0
ffffffffc02029b0:	6585                	lui	a1,0x1
ffffffffc02029b2:	dbeff0ef          	jal	ra,ffffffffc0201f70 <get_pte>
ffffffffc02029b6:	02050fe3          	beqz	a0,ffffffffc02031f4 <pmm_init+0xa9e>
    assert(*ptep & PTE_U);
ffffffffc02029ba:	611c                	ld	a5,0(a0)
ffffffffc02029bc:	0107f713          	andi	a4,a5,16
ffffffffc02029c0:	7c070e63          	beqz	a4,ffffffffc020319c <pmm_init+0xa46>
    assert(*ptep & PTE_W);
ffffffffc02029c4:	8b91                	andi	a5,a5,4
ffffffffc02029c6:	7a078b63          	beqz	a5,ffffffffc020317c <pmm_init+0xa26>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc02029ca:	00093503          	ld	a0,0(s2)
ffffffffc02029ce:	611c                	ld	a5,0(a0)
ffffffffc02029d0:	8bc1                	andi	a5,a5,16
ffffffffc02029d2:	78078563          	beqz	a5,ffffffffc020315c <pmm_init+0xa06>
    assert(page_ref(p2) == 1);
ffffffffc02029d6:	000c2703          	lw	a4,0(s8)
ffffffffc02029da:	4785                	li	a5,1
ffffffffc02029dc:	76f71063          	bne	a4,a5,ffffffffc020313c <pmm_init+0x9e6>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc02029e0:	4681                	li	a3,0
ffffffffc02029e2:	6605                	lui	a2,0x1
ffffffffc02029e4:	85d2                	mv	a1,s4
ffffffffc02029e6:	c7bff0ef          	jal	ra,ffffffffc0202660 <page_insert>
ffffffffc02029ea:	72051963          	bnez	a0,ffffffffc020311c <pmm_init+0x9c6>
    assert(page_ref(p1) == 2);
ffffffffc02029ee:	000a2703          	lw	a4,0(s4)
ffffffffc02029f2:	4789                	li	a5,2
ffffffffc02029f4:	70f71463          	bne	a4,a5,ffffffffc02030fc <pmm_init+0x9a6>
    assert(page_ref(p2) == 0);
ffffffffc02029f8:	000c2783          	lw	a5,0(s8)
ffffffffc02029fc:	6e079063          	bnez	a5,ffffffffc02030dc <pmm_init+0x986>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202a00:	00093503          	ld	a0,0(s2)
ffffffffc0202a04:	4601                	li	a2,0
ffffffffc0202a06:	6585                	lui	a1,0x1
ffffffffc0202a08:	d68ff0ef          	jal	ra,ffffffffc0201f70 <get_pte>
ffffffffc0202a0c:	6a050863          	beqz	a0,ffffffffc02030bc <pmm_init+0x966>
    assert(pte2page(*ptep) == p1);
ffffffffc0202a10:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202a12:	00177793          	andi	a5,a4,1
ffffffffc0202a16:	4a078563          	beqz	a5,ffffffffc0202ec0 <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc0202a1a:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202a1c:	00271793          	slli	a5,a4,0x2
ffffffffc0202a20:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202a22:	48d7fd63          	bgeu	a5,a3,ffffffffc0202ebc <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a26:	000bb683          	ld	a3,0(s7)
ffffffffc0202a2a:	fff80ab7          	lui	s5,0xfff80
ffffffffc0202a2e:	97d6                	add	a5,a5,s5
ffffffffc0202a30:	079a                	slli	a5,a5,0x6
ffffffffc0202a32:	97b6                	add	a5,a5,a3
ffffffffc0202a34:	66fa1463          	bne	s4,a5,ffffffffc020309c <pmm_init+0x946>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202a38:	8b41                	andi	a4,a4,16
ffffffffc0202a3a:	64071163          	bnez	a4,ffffffffc020307c <pmm_init+0x926>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc0202a3e:	00093503          	ld	a0,0(s2)
ffffffffc0202a42:	4581                	li	a1,0
ffffffffc0202a44:	b81ff0ef          	jal	ra,ffffffffc02025c4 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202a48:	000a2c83          	lw	s9,0(s4)
ffffffffc0202a4c:	4785                	li	a5,1
ffffffffc0202a4e:	60fc9763          	bne	s9,a5,ffffffffc020305c <pmm_init+0x906>
    assert(page_ref(p2) == 0);
ffffffffc0202a52:	000c2783          	lw	a5,0(s8)
ffffffffc0202a56:	5e079363          	bnez	a5,ffffffffc020303c <pmm_init+0x8e6>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc0202a5a:	00093503          	ld	a0,0(s2)
ffffffffc0202a5e:	6585                	lui	a1,0x1
ffffffffc0202a60:	b65ff0ef          	jal	ra,ffffffffc02025c4 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202a64:	000a2783          	lw	a5,0(s4)
ffffffffc0202a68:	52079a63          	bnez	a5,ffffffffc0202f9c <pmm_init+0x846>
    assert(page_ref(p2) == 0);
ffffffffc0202a6c:	000c2783          	lw	a5,0(s8)
ffffffffc0202a70:	50079663          	bnez	a5,ffffffffc0202f7c <pmm_init+0x826>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202a74:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202a78:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a7a:	000a3683          	ld	a3,0(s4)
ffffffffc0202a7e:	068a                	slli	a3,a3,0x2
ffffffffc0202a80:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0202a82:	42b6fd63          	bgeu	a3,a1,ffffffffc0202ebc <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a86:	000bb503          	ld	a0,0(s7)
ffffffffc0202a8a:	96d6                	add	a3,a3,s5
ffffffffc0202a8c:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0202a8e:	00d507b3          	add	a5,a0,a3
ffffffffc0202a92:	439c                	lw	a5,0(a5)
ffffffffc0202a94:	4d979463          	bne	a5,s9,ffffffffc0202f5c <pmm_init+0x806>
    return page - pages + nbase;
ffffffffc0202a98:	8699                	srai	a3,a3,0x6
ffffffffc0202a9a:	00080637          	lui	a2,0x80
ffffffffc0202a9e:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0202aa0:	00c69713          	slli	a4,a3,0xc
ffffffffc0202aa4:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202aa6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202aa8:	48b77e63          	bgeu	a4,a1,ffffffffc0202f44 <pmm_init+0x7ee>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202aac:	0009b703          	ld	a4,0(s3)
ffffffffc0202ab0:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ab2:	629c                	ld	a5,0(a3)
ffffffffc0202ab4:	078a                	slli	a5,a5,0x2
ffffffffc0202ab6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202ab8:	40b7f263          	bgeu	a5,a1,ffffffffc0202ebc <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202abc:	8f91                	sub	a5,a5,a2
ffffffffc0202abe:	079a                	slli	a5,a5,0x6
ffffffffc0202ac0:	953e                	add	a0,a0,a5
ffffffffc0202ac2:	100027f3          	csrr	a5,sstatus
ffffffffc0202ac6:	8b89                	andi	a5,a5,2
ffffffffc0202ac8:	30079963          	bnez	a5,ffffffffc0202dda <pmm_init+0x684>
        pmm_manager->free_pages(base, n);
ffffffffc0202acc:	000b3783          	ld	a5,0(s6)
ffffffffc0202ad0:	4585                	li	a1,1
ffffffffc0202ad2:	739c                	ld	a5,32(a5)
ffffffffc0202ad4:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ad6:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202ada:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202adc:	078a                	slli	a5,a5,0x2
ffffffffc0202ade:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202ae0:	3ce7fe63          	bgeu	a5,a4,ffffffffc0202ebc <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ae4:	000bb503          	ld	a0,0(s7)
ffffffffc0202ae8:	fff80737          	lui	a4,0xfff80
ffffffffc0202aec:	97ba                	add	a5,a5,a4
ffffffffc0202aee:	079a                	slli	a5,a5,0x6
ffffffffc0202af0:	953e                	add	a0,a0,a5
ffffffffc0202af2:	100027f3          	csrr	a5,sstatus
ffffffffc0202af6:	8b89                	andi	a5,a5,2
ffffffffc0202af8:	2c079563          	bnez	a5,ffffffffc0202dc2 <pmm_init+0x66c>
ffffffffc0202afc:	000b3783          	ld	a5,0(s6)
ffffffffc0202b00:	4585                	li	a1,1
ffffffffc0202b02:	739c                	ld	a5,32(a5)
ffffffffc0202b04:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202b06:	00093783          	ld	a5,0(s2)
ffffffffc0202b0a:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd5475c>
    asm volatile("sfence.vma");
ffffffffc0202b0e:	12000073          	sfence.vma
ffffffffc0202b12:	100027f3          	csrr	a5,sstatus
ffffffffc0202b16:	8b89                	andi	a5,a5,2
ffffffffc0202b18:	28079b63          	bnez	a5,ffffffffc0202dae <pmm_init+0x658>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202b1c:	000b3783          	ld	a5,0(s6)
ffffffffc0202b20:	779c                	ld	a5,40(a5)
ffffffffc0202b22:	9782                	jalr	a5
ffffffffc0202b24:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202b26:	4b441b63          	bne	s0,s4,ffffffffc0202fdc <pmm_init+0x886>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202b2a:	00004517          	auipc	a0,0x4
ffffffffc0202b2e:	06e50513          	addi	a0,a0,110 # ffffffffc0206b98 <default_pmm_manager+0x560>
ffffffffc0202b32:	e62fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0202b36:	100027f3          	csrr	a5,sstatus
ffffffffc0202b3a:	8b89                	andi	a5,a5,2
ffffffffc0202b3c:	24079f63          	bnez	a5,ffffffffc0202d9a <pmm_init+0x644>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202b40:	000b3783          	ld	a5,0(s6)
ffffffffc0202b44:	779c                	ld	a5,40(a5)
ffffffffc0202b46:	9782                	jalr	a5
ffffffffc0202b48:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202b4a:	6098                	ld	a4,0(s1)
ffffffffc0202b4c:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202b50:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202b52:	00c71793          	slli	a5,a4,0xc
ffffffffc0202b56:	6a05                	lui	s4,0x1
ffffffffc0202b58:	02f47c63          	bgeu	s0,a5,ffffffffc0202b90 <pmm_init+0x43a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202b5c:	00c45793          	srli	a5,s0,0xc
ffffffffc0202b60:	00093503          	ld	a0,0(s2)
ffffffffc0202b64:	2ee7ff63          	bgeu	a5,a4,ffffffffc0202e62 <pmm_init+0x70c>
ffffffffc0202b68:	0009b583          	ld	a1,0(s3)
ffffffffc0202b6c:	4601                	li	a2,0
ffffffffc0202b6e:	95a2                	add	a1,a1,s0
ffffffffc0202b70:	c00ff0ef          	jal	ra,ffffffffc0201f70 <get_pte>
ffffffffc0202b74:	32050463          	beqz	a0,ffffffffc0202e9c <pmm_init+0x746>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202b78:	611c                	ld	a5,0(a0)
ffffffffc0202b7a:	078a                	slli	a5,a5,0x2
ffffffffc0202b7c:	0157f7b3          	and	a5,a5,s5
ffffffffc0202b80:	2e879e63          	bne	a5,s0,ffffffffc0202e7c <pmm_init+0x726>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202b84:	6098                	ld	a4,0(s1)
ffffffffc0202b86:	9452                	add	s0,s0,s4
ffffffffc0202b88:	00c71793          	slli	a5,a4,0xc
ffffffffc0202b8c:	fcf468e3          	bltu	s0,a5,ffffffffc0202b5c <pmm_init+0x406>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc0202b90:	00093783          	ld	a5,0(s2)
ffffffffc0202b94:	639c                	ld	a5,0(a5)
ffffffffc0202b96:	42079363          	bnez	a5,ffffffffc0202fbc <pmm_init+0x866>
ffffffffc0202b9a:	100027f3          	csrr	a5,sstatus
ffffffffc0202b9e:	8b89                	andi	a5,a5,2
ffffffffc0202ba0:	24079963          	bnez	a5,ffffffffc0202df2 <pmm_init+0x69c>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202ba4:	000b3783          	ld	a5,0(s6)
ffffffffc0202ba8:	4505                	li	a0,1
ffffffffc0202baa:	6f9c                	ld	a5,24(a5)
ffffffffc0202bac:	9782                	jalr	a5
ffffffffc0202bae:	8a2a                	mv	s4,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202bb0:	00093503          	ld	a0,0(s2)
ffffffffc0202bb4:	4699                	li	a3,6
ffffffffc0202bb6:	10000613          	li	a2,256
ffffffffc0202bba:	85d2                	mv	a1,s4
ffffffffc0202bbc:	aa5ff0ef          	jal	ra,ffffffffc0202660 <page_insert>
ffffffffc0202bc0:	44051e63          	bnez	a0,ffffffffc020301c <pmm_init+0x8c6>
    assert(page_ref(p) == 1);
ffffffffc0202bc4:	000a2703          	lw	a4,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc0202bc8:	4785                	li	a5,1
ffffffffc0202bca:	42f71963          	bne	a4,a5,ffffffffc0202ffc <pmm_init+0x8a6>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202bce:	00093503          	ld	a0,0(s2)
ffffffffc0202bd2:	6405                	lui	s0,0x1
ffffffffc0202bd4:	4699                	li	a3,6
ffffffffc0202bd6:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8ac0>
ffffffffc0202bda:	85d2                	mv	a1,s4
ffffffffc0202bdc:	a85ff0ef          	jal	ra,ffffffffc0202660 <page_insert>
ffffffffc0202be0:	72051363          	bnez	a0,ffffffffc0203306 <pmm_init+0xbb0>
    assert(page_ref(p) == 2);
ffffffffc0202be4:	000a2703          	lw	a4,0(s4)
ffffffffc0202be8:	4789                	li	a5,2
ffffffffc0202bea:	6ef71e63          	bne	a4,a5,ffffffffc02032e6 <pmm_init+0xb90>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202bee:	00004597          	auipc	a1,0x4
ffffffffc0202bf2:	0f258593          	addi	a1,a1,242 # ffffffffc0206ce0 <default_pmm_manager+0x6a8>
ffffffffc0202bf6:	10000513          	li	a0,256
ffffffffc0202bfa:	367020ef          	jal	ra,ffffffffc0205760 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202bfe:	10040593          	addi	a1,s0,256
ffffffffc0202c02:	10000513          	li	a0,256
ffffffffc0202c06:	36d020ef          	jal	ra,ffffffffc0205772 <strcmp>
ffffffffc0202c0a:	6a051e63          	bnez	a0,ffffffffc02032c6 <pmm_init+0xb70>
    return page - pages + nbase;
ffffffffc0202c0e:	000bb683          	ld	a3,0(s7)
ffffffffc0202c12:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202c16:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0202c18:	40da06b3          	sub	a3,s4,a3
ffffffffc0202c1c:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202c1e:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202c20:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202c22:	8031                	srli	s0,s0,0xc
ffffffffc0202c24:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202c28:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202c2a:	30f77d63          	bgeu	a4,a5,ffffffffc0202f44 <pmm_init+0x7ee>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202c2e:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202c32:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202c36:	96be                	add	a3,a3,a5
ffffffffc0202c38:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202c3c:	2ef020ef          	jal	ra,ffffffffc020572a <strlen>
ffffffffc0202c40:	66051363          	bnez	a0,ffffffffc02032a6 <pmm_init+0xb50>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0202c44:	00093a83          	ld	s5,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202c48:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202c4a:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fd5475c>
ffffffffc0202c4e:	068a                	slli	a3,a3,0x2
ffffffffc0202c50:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0202c52:	26f6f563          	bgeu	a3,a5,ffffffffc0202ebc <pmm_init+0x766>
    return KADDR(page2pa(page));
ffffffffc0202c56:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202c58:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202c5a:	2ef47563          	bgeu	s0,a5,ffffffffc0202f44 <pmm_init+0x7ee>
ffffffffc0202c5e:	0009b403          	ld	s0,0(s3)
ffffffffc0202c62:	9436                	add	s0,s0,a3
ffffffffc0202c64:	100027f3          	csrr	a5,sstatus
ffffffffc0202c68:	8b89                	andi	a5,a5,2
ffffffffc0202c6a:	1e079163          	bnez	a5,ffffffffc0202e4c <pmm_init+0x6f6>
        pmm_manager->free_pages(base, n);
ffffffffc0202c6e:	000b3783          	ld	a5,0(s6)
ffffffffc0202c72:	4585                	li	a1,1
ffffffffc0202c74:	8552                	mv	a0,s4
ffffffffc0202c76:	739c                	ld	a5,32(a5)
ffffffffc0202c78:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202c7a:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage)
ffffffffc0202c7c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202c7e:	078a                	slli	a5,a5,0x2
ffffffffc0202c80:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202c82:	22e7fd63          	bgeu	a5,a4,ffffffffc0202ebc <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c86:	000bb503          	ld	a0,0(s7)
ffffffffc0202c8a:	fff80737          	lui	a4,0xfff80
ffffffffc0202c8e:	97ba                	add	a5,a5,a4
ffffffffc0202c90:	079a                	slli	a5,a5,0x6
ffffffffc0202c92:	953e                	add	a0,a0,a5
ffffffffc0202c94:	100027f3          	csrr	a5,sstatus
ffffffffc0202c98:	8b89                	andi	a5,a5,2
ffffffffc0202c9a:	18079d63          	bnez	a5,ffffffffc0202e34 <pmm_init+0x6de>
ffffffffc0202c9e:	000b3783          	ld	a5,0(s6)
ffffffffc0202ca2:	4585                	li	a1,1
ffffffffc0202ca4:	739c                	ld	a5,32(a5)
ffffffffc0202ca6:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ca8:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage)
ffffffffc0202cac:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202cae:	078a                	slli	a5,a5,0x2
ffffffffc0202cb0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202cb2:	20e7f563          	bgeu	a5,a4,ffffffffc0202ebc <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202cb6:	000bb503          	ld	a0,0(s7)
ffffffffc0202cba:	fff80737          	lui	a4,0xfff80
ffffffffc0202cbe:	97ba                	add	a5,a5,a4
ffffffffc0202cc0:	079a                	slli	a5,a5,0x6
ffffffffc0202cc2:	953e                	add	a0,a0,a5
ffffffffc0202cc4:	100027f3          	csrr	a5,sstatus
ffffffffc0202cc8:	8b89                	andi	a5,a5,2
ffffffffc0202cca:	14079963          	bnez	a5,ffffffffc0202e1c <pmm_init+0x6c6>
ffffffffc0202cce:	000b3783          	ld	a5,0(s6)
ffffffffc0202cd2:	4585                	li	a1,1
ffffffffc0202cd4:	739c                	ld	a5,32(a5)
ffffffffc0202cd6:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202cd8:	00093783          	ld	a5,0(s2)
ffffffffc0202cdc:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc0202ce0:	12000073          	sfence.vma
ffffffffc0202ce4:	100027f3          	csrr	a5,sstatus
ffffffffc0202ce8:	8b89                	andi	a5,a5,2
ffffffffc0202cea:	10079f63          	bnez	a5,ffffffffc0202e08 <pmm_init+0x6b2>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202cee:	000b3783          	ld	a5,0(s6)
ffffffffc0202cf2:	779c                	ld	a5,40(a5)
ffffffffc0202cf4:	9782                	jalr	a5
ffffffffc0202cf6:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202cf8:	4c8c1e63          	bne	s8,s0,ffffffffc02031d4 <pmm_init+0xa7e>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202cfc:	00004517          	auipc	a0,0x4
ffffffffc0202d00:	05c50513          	addi	a0,a0,92 # ffffffffc0206d58 <default_pmm_manager+0x720>
ffffffffc0202d04:	c90fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
}
ffffffffc0202d08:	7406                	ld	s0,96(sp)
ffffffffc0202d0a:	70a6                	ld	ra,104(sp)
ffffffffc0202d0c:	64e6                	ld	s1,88(sp)
ffffffffc0202d0e:	6946                	ld	s2,80(sp)
ffffffffc0202d10:	69a6                	ld	s3,72(sp)
ffffffffc0202d12:	6a06                	ld	s4,64(sp)
ffffffffc0202d14:	7ae2                	ld	s5,56(sp)
ffffffffc0202d16:	7b42                	ld	s6,48(sp)
ffffffffc0202d18:	7ba2                	ld	s7,40(sp)
ffffffffc0202d1a:	7c02                	ld	s8,32(sp)
ffffffffc0202d1c:	6ce2                	ld	s9,24(sp)
ffffffffc0202d1e:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0202d20:	f97fe06f          	j	ffffffffc0201cb6 <kmalloc_init>
    npage = maxpa / PGSIZE;
ffffffffc0202d24:	c80007b7          	lui	a5,0xc8000
ffffffffc0202d28:	bc7d                	j	ffffffffc02027e6 <pmm_init+0x90>
        intr_disable();
ffffffffc0202d2a:	c8bfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202d2e:	000b3783          	ld	a5,0(s6)
ffffffffc0202d32:	4505                	li	a0,1
ffffffffc0202d34:	6f9c                	ld	a5,24(a5)
ffffffffc0202d36:	9782                	jalr	a5
ffffffffc0202d38:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202d3a:	c75fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202d3e:	b9a9                	j	ffffffffc0202998 <pmm_init+0x242>
        intr_disable();
ffffffffc0202d40:	c75fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202d44:	000b3783          	ld	a5,0(s6)
ffffffffc0202d48:	4505                	li	a0,1
ffffffffc0202d4a:	6f9c                	ld	a5,24(a5)
ffffffffc0202d4c:	9782                	jalr	a5
ffffffffc0202d4e:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202d50:	c5ffd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202d54:	b645                	j	ffffffffc02028f4 <pmm_init+0x19e>
        intr_disable();
ffffffffc0202d56:	c5ffd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202d5a:	000b3783          	ld	a5,0(s6)
ffffffffc0202d5e:	779c                	ld	a5,40(a5)
ffffffffc0202d60:	9782                	jalr	a5
ffffffffc0202d62:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202d64:	c4bfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202d68:	b6b9                	j	ffffffffc02028b6 <pmm_init+0x160>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202d6a:	6705                	lui	a4,0x1
ffffffffc0202d6c:	177d                	addi	a4,a4,-1
ffffffffc0202d6e:	96ba                	add	a3,a3,a4
ffffffffc0202d70:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc0202d72:	00c7d713          	srli	a4,a5,0xc
ffffffffc0202d76:	14a77363          	bgeu	a4,a0,ffffffffc0202ebc <pmm_init+0x766>
    pmm_manager->init_memmap(base, n);
ffffffffc0202d7a:	000b3683          	ld	a3,0(s6)
    return &pages[PPN(pa) - nbase];
ffffffffc0202d7e:	fff80537          	lui	a0,0xfff80
ffffffffc0202d82:	972a                	add	a4,a4,a0
ffffffffc0202d84:	6a94                	ld	a3,16(a3)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202d86:	8c1d                	sub	s0,s0,a5
ffffffffc0202d88:	00671513          	slli	a0,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0202d8c:	00c45593          	srli	a1,s0,0xc
ffffffffc0202d90:	9532                	add	a0,a0,a2
ffffffffc0202d92:	9682                	jalr	a3
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202d94:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202d98:	b4c1                	j	ffffffffc0202858 <pmm_init+0x102>
        intr_disable();
ffffffffc0202d9a:	c1bfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202d9e:	000b3783          	ld	a5,0(s6)
ffffffffc0202da2:	779c                	ld	a5,40(a5)
ffffffffc0202da4:	9782                	jalr	a5
ffffffffc0202da6:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202da8:	c07fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202dac:	bb79                	j	ffffffffc0202b4a <pmm_init+0x3f4>
        intr_disable();
ffffffffc0202dae:	c07fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202db2:	000b3783          	ld	a5,0(s6)
ffffffffc0202db6:	779c                	ld	a5,40(a5)
ffffffffc0202db8:	9782                	jalr	a5
ffffffffc0202dba:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202dbc:	bf3fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202dc0:	b39d                	j	ffffffffc0202b26 <pmm_init+0x3d0>
ffffffffc0202dc2:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202dc4:	bf1fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202dc8:	000b3783          	ld	a5,0(s6)
ffffffffc0202dcc:	6522                	ld	a0,8(sp)
ffffffffc0202dce:	4585                	li	a1,1
ffffffffc0202dd0:	739c                	ld	a5,32(a5)
ffffffffc0202dd2:	9782                	jalr	a5
        intr_enable();
ffffffffc0202dd4:	bdbfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202dd8:	b33d                	j	ffffffffc0202b06 <pmm_init+0x3b0>
ffffffffc0202dda:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202ddc:	bd9fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202de0:	000b3783          	ld	a5,0(s6)
ffffffffc0202de4:	6522                	ld	a0,8(sp)
ffffffffc0202de6:	4585                	li	a1,1
ffffffffc0202de8:	739c                	ld	a5,32(a5)
ffffffffc0202dea:	9782                	jalr	a5
        intr_enable();
ffffffffc0202dec:	bc3fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202df0:	b1dd                	j	ffffffffc0202ad6 <pmm_init+0x380>
        intr_disable();
ffffffffc0202df2:	bc3fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202df6:	000b3783          	ld	a5,0(s6)
ffffffffc0202dfa:	4505                	li	a0,1
ffffffffc0202dfc:	6f9c                	ld	a5,24(a5)
ffffffffc0202dfe:	9782                	jalr	a5
ffffffffc0202e00:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202e02:	badfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202e06:	b36d                	j	ffffffffc0202bb0 <pmm_init+0x45a>
        intr_disable();
ffffffffc0202e08:	badfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202e0c:	000b3783          	ld	a5,0(s6)
ffffffffc0202e10:	779c                	ld	a5,40(a5)
ffffffffc0202e12:	9782                	jalr	a5
ffffffffc0202e14:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202e16:	b99fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202e1a:	bdf9                	j	ffffffffc0202cf8 <pmm_init+0x5a2>
ffffffffc0202e1c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202e1e:	b97fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202e22:	000b3783          	ld	a5,0(s6)
ffffffffc0202e26:	6522                	ld	a0,8(sp)
ffffffffc0202e28:	4585                	li	a1,1
ffffffffc0202e2a:	739c                	ld	a5,32(a5)
ffffffffc0202e2c:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e2e:	b81fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202e32:	b55d                	j	ffffffffc0202cd8 <pmm_init+0x582>
ffffffffc0202e34:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202e36:	b7ffd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202e3a:	000b3783          	ld	a5,0(s6)
ffffffffc0202e3e:	6522                	ld	a0,8(sp)
ffffffffc0202e40:	4585                	li	a1,1
ffffffffc0202e42:	739c                	ld	a5,32(a5)
ffffffffc0202e44:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e46:	b69fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202e4a:	bdb9                	j	ffffffffc0202ca8 <pmm_init+0x552>
        intr_disable();
ffffffffc0202e4c:	b69fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202e50:	000b3783          	ld	a5,0(s6)
ffffffffc0202e54:	4585                	li	a1,1
ffffffffc0202e56:	8552                	mv	a0,s4
ffffffffc0202e58:	739c                	ld	a5,32(a5)
ffffffffc0202e5a:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e5c:	b53fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202e60:	bd29                	j	ffffffffc0202c7a <pmm_init+0x524>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202e62:	86a2                	mv	a3,s0
ffffffffc0202e64:	00004617          	auipc	a2,0x4
ffffffffc0202e68:	80c60613          	addi	a2,a2,-2036 # ffffffffc0206670 <default_pmm_manager+0x38>
ffffffffc0202e6c:	25600593          	li	a1,598
ffffffffc0202e70:	00004517          	auipc	a0,0x4
ffffffffc0202e74:	91850513          	addi	a0,a0,-1768 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0202e78:	e16fd0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202e7c:	00004697          	auipc	a3,0x4
ffffffffc0202e80:	d7c68693          	addi	a3,a3,-644 # ffffffffc0206bf8 <default_pmm_manager+0x5c0>
ffffffffc0202e84:	00003617          	auipc	a2,0x3
ffffffffc0202e88:	40460613          	addi	a2,a2,1028 # ffffffffc0206288 <commands+0x828>
ffffffffc0202e8c:	25700593          	li	a1,599
ffffffffc0202e90:	00004517          	auipc	a0,0x4
ffffffffc0202e94:	8f850513          	addi	a0,a0,-1800 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0202e98:	df6fd0ef          	jal	ra,ffffffffc020048e <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202e9c:	00004697          	auipc	a3,0x4
ffffffffc0202ea0:	d1c68693          	addi	a3,a3,-740 # ffffffffc0206bb8 <default_pmm_manager+0x580>
ffffffffc0202ea4:	00003617          	auipc	a2,0x3
ffffffffc0202ea8:	3e460613          	addi	a2,a2,996 # ffffffffc0206288 <commands+0x828>
ffffffffc0202eac:	25600593          	li	a1,598
ffffffffc0202eb0:	00004517          	auipc	a0,0x4
ffffffffc0202eb4:	8d850513          	addi	a0,a0,-1832 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0202eb8:	dd6fd0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc0202ebc:	fc5fe0ef          	jal	ra,ffffffffc0201e80 <pa2page.part.0>
ffffffffc0202ec0:	fddfe0ef          	jal	ra,ffffffffc0201e9c <pte2page.part.0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202ec4:	00004697          	auipc	a3,0x4
ffffffffc0202ec8:	aec68693          	addi	a3,a3,-1300 # ffffffffc02069b0 <default_pmm_manager+0x378>
ffffffffc0202ecc:	00003617          	auipc	a2,0x3
ffffffffc0202ed0:	3bc60613          	addi	a2,a2,956 # ffffffffc0206288 <commands+0x828>
ffffffffc0202ed4:	22600593          	li	a1,550
ffffffffc0202ed8:	00004517          	auipc	a0,0x4
ffffffffc0202edc:	8b050513          	addi	a0,a0,-1872 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0202ee0:	daefd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0202ee4:	00004697          	auipc	a3,0x4
ffffffffc0202ee8:	a0c68693          	addi	a3,a3,-1524 # ffffffffc02068f0 <default_pmm_manager+0x2b8>
ffffffffc0202eec:	00003617          	auipc	a2,0x3
ffffffffc0202ef0:	39c60613          	addi	a2,a2,924 # ffffffffc0206288 <commands+0x828>
ffffffffc0202ef4:	21900593          	li	a1,537
ffffffffc0202ef8:	00004517          	auipc	a0,0x4
ffffffffc0202efc:	89050513          	addi	a0,a0,-1904 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0202f00:	d8efd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202f04:	00004697          	auipc	a3,0x4
ffffffffc0202f08:	9ac68693          	addi	a3,a3,-1620 # ffffffffc02068b0 <default_pmm_manager+0x278>
ffffffffc0202f0c:	00003617          	auipc	a2,0x3
ffffffffc0202f10:	37c60613          	addi	a2,a2,892 # ffffffffc0206288 <commands+0x828>
ffffffffc0202f14:	21800593          	li	a1,536
ffffffffc0202f18:	00004517          	auipc	a0,0x4
ffffffffc0202f1c:	87050513          	addi	a0,a0,-1936 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0202f20:	d6efd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202f24:	00004697          	auipc	a3,0x4
ffffffffc0202f28:	96c68693          	addi	a3,a3,-1684 # ffffffffc0206890 <default_pmm_manager+0x258>
ffffffffc0202f2c:	00003617          	auipc	a2,0x3
ffffffffc0202f30:	35c60613          	addi	a2,a2,860 # ffffffffc0206288 <commands+0x828>
ffffffffc0202f34:	21700593          	li	a1,535
ffffffffc0202f38:	00004517          	auipc	a0,0x4
ffffffffc0202f3c:	85050513          	addi	a0,a0,-1968 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0202f40:	d4efd0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc0202f44:	00003617          	auipc	a2,0x3
ffffffffc0202f48:	72c60613          	addi	a2,a2,1836 # ffffffffc0206670 <default_pmm_manager+0x38>
ffffffffc0202f4c:	07100593          	li	a1,113
ffffffffc0202f50:	00003517          	auipc	a0,0x3
ffffffffc0202f54:	74850513          	addi	a0,a0,1864 # ffffffffc0206698 <default_pmm_manager+0x60>
ffffffffc0202f58:	d36fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202f5c:	00004697          	auipc	a3,0x4
ffffffffc0202f60:	be468693          	addi	a3,a3,-1052 # ffffffffc0206b40 <default_pmm_manager+0x508>
ffffffffc0202f64:	00003617          	auipc	a2,0x3
ffffffffc0202f68:	32460613          	addi	a2,a2,804 # ffffffffc0206288 <commands+0x828>
ffffffffc0202f6c:	23f00593          	li	a1,575
ffffffffc0202f70:	00004517          	auipc	a0,0x4
ffffffffc0202f74:	81850513          	addi	a0,a0,-2024 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0202f78:	d16fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f7c:	00004697          	auipc	a3,0x4
ffffffffc0202f80:	b7c68693          	addi	a3,a3,-1156 # ffffffffc0206af8 <default_pmm_manager+0x4c0>
ffffffffc0202f84:	00003617          	auipc	a2,0x3
ffffffffc0202f88:	30460613          	addi	a2,a2,772 # ffffffffc0206288 <commands+0x828>
ffffffffc0202f8c:	23d00593          	li	a1,573
ffffffffc0202f90:	00003517          	auipc	a0,0x3
ffffffffc0202f94:	7f850513          	addi	a0,a0,2040 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0202f98:	cf6fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202f9c:	00004697          	auipc	a3,0x4
ffffffffc0202fa0:	b8c68693          	addi	a3,a3,-1140 # ffffffffc0206b28 <default_pmm_manager+0x4f0>
ffffffffc0202fa4:	00003617          	auipc	a2,0x3
ffffffffc0202fa8:	2e460613          	addi	a2,a2,740 # ffffffffc0206288 <commands+0x828>
ffffffffc0202fac:	23c00593          	li	a1,572
ffffffffc0202fb0:	00003517          	auipc	a0,0x3
ffffffffc0202fb4:	7d850513          	addi	a0,a0,2008 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0202fb8:	cd6fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc0202fbc:	00004697          	auipc	a3,0x4
ffffffffc0202fc0:	c5468693          	addi	a3,a3,-940 # ffffffffc0206c10 <default_pmm_manager+0x5d8>
ffffffffc0202fc4:	00003617          	auipc	a2,0x3
ffffffffc0202fc8:	2c460613          	addi	a2,a2,708 # ffffffffc0206288 <commands+0x828>
ffffffffc0202fcc:	25a00593          	li	a1,602
ffffffffc0202fd0:	00003517          	auipc	a0,0x3
ffffffffc0202fd4:	7b850513          	addi	a0,a0,1976 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0202fd8:	cb6fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0202fdc:	00004697          	auipc	a3,0x4
ffffffffc0202fe0:	b9468693          	addi	a3,a3,-1132 # ffffffffc0206b70 <default_pmm_manager+0x538>
ffffffffc0202fe4:	00003617          	auipc	a2,0x3
ffffffffc0202fe8:	2a460613          	addi	a2,a2,676 # ffffffffc0206288 <commands+0x828>
ffffffffc0202fec:	24700593          	li	a1,583
ffffffffc0202ff0:	00003517          	auipc	a0,0x3
ffffffffc0202ff4:	79850513          	addi	a0,a0,1944 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0202ff8:	c96fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202ffc:	00004697          	auipc	a3,0x4
ffffffffc0203000:	c6c68693          	addi	a3,a3,-916 # ffffffffc0206c68 <default_pmm_manager+0x630>
ffffffffc0203004:	00003617          	auipc	a2,0x3
ffffffffc0203008:	28460613          	addi	a2,a2,644 # ffffffffc0206288 <commands+0x828>
ffffffffc020300c:	25f00593          	li	a1,607
ffffffffc0203010:	00003517          	auipc	a0,0x3
ffffffffc0203014:	77850513          	addi	a0,a0,1912 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0203018:	c76fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020301c:	00004697          	auipc	a3,0x4
ffffffffc0203020:	c0c68693          	addi	a3,a3,-1012 # ffffffffc0206c28 <default_pmm_manager+0x5f0>
ffffffffc0203024:	00003617          	auipc	a2,0x3
ffffffffc0203028:	26460613          	addi	a2,a2,612 # ffffffffc0206288 <commands+0x828>
ffffffffc020302c:	25e00593          	li	a1,606
ffffffffc0203030:	00003517          	auipc	a0,0x3
ffffffffc0203034:	75850513          	addi	a0,a0,1880 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0203038:	c56fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020303c:	00004697          	auipc	a3,0x4
ffffffffc0203040:	abc68693          	addi	a3,a3,-1348 # ffffffffc0206af8 <default_pmm_manager+0x4c0>
ffffffffc0203044:	00003617          	auipc	a2,0x3
ffffffffc0203048:	24460613          	addi	a2,a2,580 # ffffffffc0206288 <commands+0x828>
ffffffffc020304c:	23900593          	li	a1,569
ffffffffc0203050:	00003517          	auipc	a0,0x3
ffffffffc0203054:	73850513          	addi	a0,a0,1848 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0203058:	c36fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020305c:	00004697          	auipc	a3,0x4
ffffffffc0203060:	93c68693          	addi	a3,a3,-1732 # ffffffffc0206998 <default_pmm_manager+0x360>
ffffffffc0203064:	00003617          	auipc	a2,0x3
ffffffffc0203068:	22460613          	addi	a2,a2,548 # ffffffffc0206288 <commands+0x828>
ffffffffc020306c:	23800593          	li	a1,568
ffffffffc0203070:	00003517          	auipc	a0,0x3
ffffffffc0203074:	71850513          	addi	a0,a0,1816 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0203078:	c16fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020307c:	00004697          	auipc	a3,0x4
ffffffffc0203080:	a9468693          	addi	a3,a3,-1388 # ffffffffc0206b10 <default_pmm_manager+0x4d8>
ffffffffc0203084:	00003617          	auipc	a2,0x3
ffffffffc0203088:	20460613          	addi	a2,a2,516 # ffffffffc0206288 <commands+0x828>
ffffffffc020308c:	23500593          	li	a1,565
ffffffffc0203090:	00003517          	auipc	a0,0x3
ffffffffc0203094:	6f850513          	addi	a0,a0,1784 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0203098:	bf6fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020309c:	00004697          	auipc	a3,0x4
ffffffffc02030a0:	8e468693          	addi	a3,a3,-1820 # ffffffffc0206980 <default_pmm_manager+0x348>
ffffffffc02030a4:	00003617          	auipc	a2,0x3
ffffffffc02030a8:	1e460613          	addi	a2,a2,484 # ffffffffc0206288 <commands+0x828>
ffffffffc02030ac:	23400593          	li	a1,564
ffffffffc02030b0:	00003517          	auipc	a0,0x3
ffffffffc02030b4:	6d850513          	addi	a0,a0,1752 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc02030b8:	bd6fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02030bc:	00004697          	auipc	a3,0x4
ffffffffc02030c0:	96468693          	addi	a3,a3,-1692 # ffffffffc0206a20 <default_pmm_manager+0x3e8>
ffffffffc02030c4:	00003617          	auipc	a2,0x3
ffffffffc02030c8:	1c460613          	addi	a2,a2,452 # ffffffffc0206288 <commands+0x828>
ffffffffc02030cc:	23300593          	li	a1,563
ffffffffc02030d0:	00003517          	auipc	a0,0x3
ffffffffc02030d4:	6b850513          	addi	a0,a0,1720 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc02030d8:	bb6fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02030dc:	00004697          	auipc	a3,0x4
ffffffffc02030e0:	a1c68693          	addi	a3,a3,-1508 # ffffffffc0206af8 <default_pmm_manager+0x4c0>
ffffffffc02030e4:	00003617          	auipc	a2,0x3
ffffffffc02030e8:	1a460613          	addi	a2,a2,420 # ffffffffc0206288 <commands+0x828>
ffffffffc02030ec:	23200593          	li	a1,562
ffffffffc02030f0:	00003517          	auipc	a0,0x3
ffffffffc02030f4:	69850513          	addi	a0,a0,1688 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc02030f8:	b96fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02030fc:	00004697          	auipc	a3,0x4
ffffffffc0203100:	9e468693          	addi	a3,a3,-1564 # ffffffffc0206ae0 <default_pmm_manager+0x4a8>
ffffffffc0203104:	00003617          	auipc	a2,0x3
ffffffffc0203108:	18460613          	addi	a2,a2,388 # ffffffffc0206288 <commands+0x828>
ffffffffc020310c:	23100593          	li	a1,561
ffffffffc0203110:	00003517          	auipc	a0,0x3
ffffffffc0203114:	67850513          	addi	a0,a0,1656 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0203118:	b76fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc020311c:	00004697          	auipc	a3,0x4
ffffffffc0203120:	99468693          	addi	a3,a3,-1644 # ffffffffc0206ab0 <default_pmm_manager+0x478>
ffffffffc0203124:	00003617          	auipc	a2,0x3
ffffffffc0203128:	16460613          	addi	a2,a2,356 # ffffffffc0206288 <commands+0x828>
ffffffffc020312c:	23000593          	li	a1,560
ffffffffc0203130:	00003517          	auipc	a0,0x3
ffffffffc0203134:	65850513          	addi	a0,a0,1624 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0203138:	b56fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 1);
ffffffffc020313c:	00004697          	auipc	a3,0x4
ffffffffc0203140:	95c68693          	addi	a3,a3,-1700 # ffffffffc0206a98 <default_pmm_manager+0x460>
ffffffffc0203144:	00003617          	auipc	a2,0x3
ffffffffc0203148:	14460613          	addi	a2,a2,324 # ffffffffc0206288 <commands+0x828>
ffffffffc020314c:	22e00593          	li	a1,558
ffffffffc0203150:	00003517          	auipc	a0,0x3
ffffffffc0203154:	63850513          	addi	a0,a0,1592 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0203158:	b36fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc020315c:	00004697          	auipc	a3,0x4
ffffffffc0203160:	91c68693          	addi	a3,a3,-1764 # ffffffffc0206a78 <default_pmm_manager+0x440>
ffffffffc0203164:	00003617          	auipc	a2,0x3
ffffffffc0203168:	12460613          	addi	a2,a2,292 # ffffffffc0206288 <commands+0x828>
ffffffffc020316c:	22d00593          	li	a1,557
ffffffffc0203170:	00003517          	auipc	a0,0x3
ffffffffc0203174:	61850513          	addi	a0,a0,1560 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0203178:	b16fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(*ptep & PTE_W);
ffffffffc020317c:	00004697          	auipc	a3,0x4
ffffffffc0203180:	8ec68693          	addi	a3,a3,-1812 # ffffffffc0206a68 <default_pmm_manager+0x430>
ffffffffc0203184:	00003617          	auipc	a2,0x3
ffffffffc0203188:	10460613          	addi	a2,a2,260 # ffffffffc0206288 <commands+0x828>
ffffffffc020318c:	22c00593          	li	a1,556
ffffffffc0203190:	00003517          	auipc	a0,0x3
ffffffffc0203194:	5f850513          	addi	a0,a0,1528 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0203198:	af6fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(*ptep & PTE_U);
ffffffffc020319c:	00004697          	auipc	a3,0x4
ffffffffc02031a0:	8bc68693          	addi	a3,a3,-1860 # ffffffffc0206a58 <default_pmm_manager+0x420>
ffffffffc02031a4:	00003617          	auipc	a2,0x3
ffffffffc02031a8:	0e460613          	addi	a2,a2,228 # ffffffffc0206288 <commands+0x828>
ffffffffc02031ac:	22b00593          	li	a1,555
ffffffffc02031b0:	00003517          	auipc	a0,0x3
ffffffffc02031b4:	5d850513          	addi	a0,a0,1496 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc02031b8:	ad6fd0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("DTB memory info not available");
ffffffffc02031bc:	00003617          	auipc	a2,0x3
ffffffffc02031c0:	63c60613          	addi	a2,a2,1596 # ffffffffc02067f8 <default_pmm_manager+0x1c0>
ffffffffc02031c4:	06500593          	li	a1,101
ffffffffc02031c8:	00003517          	auipc	a0,0x3
ffffffffc02031cc:	5c050513          	addi	a0,a0,1472 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc02031d0:	abefd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc02031d4:	00004697          	auipc	a3,0x4
ffffffffc02031d8:	99c68693          	addi	a3,a3,-1636 # ffffffffc0206b70 <default_pmm_manager+0x538>
ffffffffc02031dc:	00003617          	auipc	a2,0x3
ffffffffc02031e0:	0ac60613          	addi	a2,a2,172 # ffffffffc0206288 <commands+0x828>
ffffffffc02031e4:	27100593          	li	a1,625
ffffffffc02031e8:	00003517          	auipc	a0,0x3
ffffffffc02031ec:	5a050513          	addi	a0,a0,1440 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc02031f0:	a9efd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02031f4:	00004697          	auipc	a3,0x4
ffffffffc02031f8:	82c68693          	addi	a3,a3,-2004 # ffffffffc0206a20 <default_pmm_manager+0x3e8>
ffffffffc02031fc:	00003617          	auipc	a2,0x3
ffffffffc0203200:	08c60613          	addi	a2,a2,140 # ffffffffc0206288 <commands+0x828>
ffffffffc0203204:	22a00593          	li	a1,554
ffffffffc0203208:	00003517          	auipc	a0,0x3
ffffffffc020320c:	58050513          	addi	a0,a0,1408 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0203210:	a7efd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203214:	00003697          	auipc	a3,0x3
ffffffffc0203218:	7cc68693          	addi	a3,a3,1996 # ffffffffc02069e0 <default_pmm_manager+0x3a8>
ffffffffc020321c:	00003617          	auipc	a2,0x3
ffffffffc0203220:	06c60613          	addi	a2,a2,108 # ffffffffc0206288 <commands+0x828>
ffffffffc0203224:	22900593          	li	a1,553
ffffffffc0203228:	00003517          	auipc	a0,0x3
ffffffffc020322c:	56050513          	addi	a0,a0,1376 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0203230:	a5efd0ef          	jal	ra,ffffffffc020048e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203234:	86d6                	mv	a3,s5
ffffffffc0203236:	00003617          	auipc	a2,0x3
ffffffffc020323a:	43a60613          	addi	a2,a2,1082 # ffffffffc0206670 <default_pmm_manager+0x38>
ffffffffc020323e:	22500593          	li	a1,549
ffffffffc0203242:	00003517          	auipc	a0,0x3
ffffffffc0203246:	54650513          	addi	a0,a0,1350 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc020324a:	a44fd0ef          	jal	ra,ffffffffc020048e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc020324e:	00003617          	auipc	a2,0x3
ffffffffc0203252:	42260613          	addi	a2,a2,1058 # ffffffffc0206670 <default_pmm_manager+0x38>
ffffffffc0203256:	22400593          	li	a1,548
ffffffffc020325a:	00003517          	auipc	a0,0x3
ffffffffc020325e:	52e50513          	addi	a0,a0,1326 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0203262:	a2cfd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203266:	00003697          	auipc	a3,0x3
ffffffffc020326a:	73268693          	addi	a3,a3,1842 # ffffffffc0206998 <default_pmm_manager+0x360>
ffffffffc020326e:	00003617          	auipc	a2,0x3
ffffffffc0203272:	01a60613          	addi	a2,a2,26 # ffffffffc0206288 <commands+0x828>
ffffffffc0203276:	22200593          	li	a1,546
ffffffffc020327a:	00003517          	auipc	a0,0x3
ffffffffc020327e:	50e50513          	addi	a0,a0,1294 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0203282:	a0cfd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203286:	00003697          	auipc	a3,0x3
ffffffffc020328a:	6fa68693          	addi	a3,a3,1786 # ffffffffc0206980 <default_pmm_manager+0x348>
ffffffffc020328e:	00003617          	auipc	a2,0x3
ffffffffc0203292:	ffa60613          	addi	a2,a2,-6 # ffffffffc0206288 <commands+0x828>
ffffffffc0203296:	22100593          	li	a1,545
ffffffffc020329a:	00003517          	auipc	a0,0x3
ffffffffc020329e:	4ee50513          	addi	a0,a0,1262 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc02032a2:	9ecfd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02032a6:	00004697          	auipc	a3,0x4
ffffffffc02032aa:	a8a68693          	addi	a3,a3,-1398 # ffffffffc0206d30 <default_pmm_manager+0x6f8>
ffffffffc02032ae:	00003617          	auipc	a2,0x3
ffffffffc02032b2:	fda60613          	addi	a2,a2,-38 # ffffffffc0206288 <commands+0x828>
ffffffffc02032b6:	26800593          	li	a1,616
ffffffffc02032ba:	00003517          	auipc	a0,0x3
ffffffffc02032be:	4ce50513          	addi	a0,a0,1230 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc02032c2:	9ccfd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02032c6:	00004697          	auipc	a3,0x4
ffffffffc02032ca:	a3268693          	addi	a3,a3,-1486 # ffffffffc0206cf8 <default_pmm_manager+0x6c0>
ffffffffc02032ce:	00003617          	auipc	a2,0x3
ffffffffc02032d2:	fba60613          	addi	a2,a2,-70 # ffffffffc0206288 <commands+0x828>
ffffffffc02032d6:	26500593          	li	a1,613
ffffffffc02032da:	00003517          	auipc	a0,0x3
ffffffffc02032de:	4ae50513          	addi	a0,a0,1198 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc02032e2:	9acfd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p) == 2);
ffffffffc02032e6:	00004697          	auipc	a3,0x4
ffffffffc02032ea:	9e268693          	addi	a3,a3,-1566 # ffffffffc0206cc8 <default_pmm_manager+0x690>
ffffffffc02032ee:	00003617          	auipc	a2,0x3
ffffffffc02032f2:	f9a60613          	addi	a2,a2,-102 # ffffffffc0206288 <commands+0x828>
ffffffffc02032f6:	26100593          	li	a1,609
ffffffffc02032fa:	00003517          	auipc	a0,0x3
ffffffffc02032fe:	48e50513          	addi	a0,a0,1166 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0203302:	98cfd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203306:	00004697          	auipc	a3,0x4
ffffffffc020330a:	97a68693          	addi	a3,a3,-1670 # ffffffffc0206c80 <default_pmm_manager+0x648>
ffffffffc020330e:	00003617          	auipc	a2,0x3
ffffffffc0203312:	f7a60613          	addi	a2,a2,-134 # ffffffffc0206288 <commands+0x828>
ffffffffc0203316:	26000593          	li	a1,608
ffffffffc020331a:	00003517          	auipc	a0,0x3
ffffffffc020331e:	46e50513          	addi	a0,a0,1134 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0203322:	96cfd0ef          	jal	ra,ffffffffc020048e <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0203326:	00003617          	auipc	a2,0x3
ffffffffc020332a:	3f260613          	addi	a2,a2,1010 # ffffffffc0206718 <default_pmm_manager+0xe0>
ffffffffc020332e:	0c900593          	li	a1,201
ffffffffc0203332:	00003517          	auipc	a0,0x3
ffffffffc0203336:	45650513          	addi	a0,a0,1110 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc020333a:	954fd0ef          	jal	ra,ffffffffc020048e <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020333e:	00003617          	auipc	a2,0x3
ffffffffc0203342:	3da60613          	addi	a2,a2,986 # ffffffffc0206718 <default_pmm_manager+0xe0>
ffffffffc0203346:	08100593          	li	a1,129
ffffffffc020334a:	00003517          	auipc	a0,0x3
ffffffffc020334e:	43e50513          	addi	a0,a0,1086 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0203352:	93cfd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0203356:	00003697          	auipc	a3,0x3
ffffffffc020335a:	5fa68693          	addi	a3,a3,1530 # ffffffffc0206950 <default_pmm_manager+0x318>
ffffffffc020335e:	00003617          	auipc	a2,0x3
ffffffffc0203362:	f2a60613          	addi	a2,a2,-214 # ffffffffc0206288 <commands+0x828>
ffffffffc0203366:	22000593          	li	a1,544
ffffffffc020336a:	00003517          	auipc	a0,0x3
ffffffffc020336e:	41e50513          	addi	a0,a0,1054 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0203372:	91cfd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0203376:	00003697          	auipc	a3,0x3
ffffffffc020337a:	5aa68693          	addi	a3,a3,1450 # ffffffffc0206920 <default_pmm_manager+0x2e8>
ffffffffc020337e:	00003617          	auipc	a2,0x3
ffffffffc0203382:	f0a60613          	addi	a2,a2,-246 # ffffffffc0206288 <commands+0x828>
ffffffffc0203386:	21d00593          	li	a1,541
ffffffffc020338a:	00003517          	auipc	a0,0x3
ffffffffc020338e:	3fe50513          	addi	a0,a0,1022 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0203392:	8fcfd0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203396 <copy_range>:
{
ffffffffc0203396:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203398:	00d667b3          	or	a5,a2,a3
{
ffffffffc020339c:	f486                	sd	ra,104(sp)
ffffffffc020339e:	f0a2                	sd	s0,96(sp)
ffffffffc02033a0:	eca6                	sd	s1,88(sp)
ffffffffc02033a2:	e8ca                	sd	s2,80(sp)
ffffffffc02033a4:	e4ce                	sd	s3,72(sp)
ffffffffc02033a6:	e0d2                	sd	s4,64(sp)
ffffffffc02033a8:	fc56                	sd	s5,56(sp)
ffffffffc02033aa:	f85a                	sd	s6,48(sp)
ffffffffc02033ac:	f45e                	sd	s7,40(sp)
ffffffffc02033ae:	f062                	sd	s8,32(sp)
ffffffffc02033b0:	ec66                	sd	s9,24(sp)
ffffffffc02033b2:	e86a                	sd	s10,16(sp)
ffffffffc02033b4:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02033b6:	17d2                	slli	a5,a5,0x34
ffffffffc02033b8:	22079f63          	bnez	a5,ffffffffc02035f6 <copy_range+0x260>
    assert(USER_ACCESS(start, end));
ffffffffc02033bc:	002007b7          	lui	a5,0x200
ffffffffc02033c0:	8432                	mv	s0,a2
ffffffffc02033c2:	1cf66263          	bltu	a2,a5,ffffffffc0203586 <copy_range+0x1f0>
ffffffffc02033c6:	8936                	mv	s2,a3
ffffffffc02033c8:	1ad67f63          	bgeu	a2,a3,ffffffffc0203586 <copy_range+0x1f0>
ffffffffc02033cc:	4785                	li	a5,1
ffffffffc02033ce:	07fe                	slli	a5,a5,0x1f
ffffffffc02033d0:	1ad7eb63          	bltu	a5,a3,ffffffffc0203586 <copy_range+0x1f0>
ffffffffc02033d4:	5b7d                	li	s6,-1
ffffffffc02033d6:	8aaa                	mv	s5,a0
ffffffffc02033d8:	89ae                	mv	s3,a1
        start += PGSIZE;
ffffffffc02033da:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage)
ffffffffc02033dc:	000a7c17          	auipc	s8,0xa7
ffffffffc02033e0:	48cc0c13          	addi	s8,s8,1164 # ffffffffc02aa868 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02033e4:	000a7b97          	auipc	s7,0xa7
ffffffffc02033e8:	48cb8b93          	addi	s7,s7,1164 # ffffffffc02aa870 <pages>
    return KADDR(page2pa(page));
ffffffffc02033ec:	00cb5b13          	srli	s6,s6,0xc
        page = pmm_manager->alloc_pages(n);
ffffffffc02033f0:	000a7c97          	auipc	s9,0xa7
ffffffffc02033f4:	488c8c93          	addi	s9,s9,1160 # ffffffffc02aa878 <pmm_manager>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02033f8:	4601                	li	a2,0
ffffffffc02033fa:	85a2                	mv	a1,s0
ffffffffc02033fc:	854e                	mv	a0,s3
ffffffffc02033fe:	b73fe0ef          	jal	ra,ffffffffc0201f70 <get_pte>
ffffffffc0203402:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc0203404:	10050163          	beqz	a0,ffffffffc0203506 <copy_range+0x170>
        if (*ptep & PTE_V)
ffffffffc0203408:	611c                	ld	a5,0(a0)
ffffffffc020340a:	8b85                	andi	a5,a5,1
ffffffffc020340c:	e78d                	bnez	a5,ffffffffc0203436 <copy_range+0xa0>
        start += PGSIZE;
ffffffffc020340e:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0203410:	ff2464e3          	bltu	s0,s2,ffffffffc02033f8 <copy_range+0x62>
    return 0;
ffffffffc0203414:	4481                	li	s1,0
}
ffffffffc0203416:	70a6                	ld	ra,104(sp)
ffffffffc0203418:	7406                	ld	s0,96(sp)
ffffffffc020341a:	6946                	ld	s2,80(sp)
ffffffffc020341c:	69a6                	ld	s3,72(sp)
ffffffffc020341e:	6a06                	ld	s4,64(sp)
ffffffffc0203420:	7ae2                	ld	s5,56(sp)
ffffffffc0203422:	7b42                	ld	s6,48(sp)
ffffffffc0203424:	7ba2                	ld	s7,40(sp)
ffffffffc0203426:	7c02                	ld	s8,32(sp)
ffffffffc0203428:	6ce2                	ld	s9,24(sp)
ffffffffc020342a:	6d42                	ld	s10,16(sp)
ffffffffc020342c:	6da2                	ld	s11,8(sp)
ffffffffc020342e:	8526                	mv	a0,s1
ffffffffc0203430:	64e6                	ld	s1,88(sp)
ffffffffc0203432:	6165                	addi	sp,sp,112
ffffffffc0203434:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc0203436:	4605                	li	a2,1
ffffffffc0203438:	85a2                	mv	a1,s0
ffffffffc020343a:	8556                	mv	a0,s5
ffffffffc020343c:	b35fe0ef          	jal	ra,ffffffffc0201f70 <get_pte>
ffffffffc0203440:	0e050963          	beqz	a0,ffffffffc0203532 <copy_range+0x19c>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0203444:	609c                	ld	a5,0(s1)
    if (!(pte & PTE_V))
ffffffffc0203446:	0017f713          	andi	a4,a5,1
ffffffffc020344a:	01f7f493          	andi	s1,a5,31
ffffffffc020344e:	18070863          	beqz	a4,ffffffffc02035de <copy_range+0x248>
    if (PPN(pa) >= npage)
ffffffffc0203452:	000c3683          	ld	a3,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203456:	078a                	slli	a5,a5,0x2
ffffffffc0203458:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020345c:	16d77563          	bgeu	a4,a3,ffffffffc02035c6 <copy_range+0x230>
    return &pages[PPN(pa) - nbase];
ffffffffc0203460:	000bb783          	ld	a5,0(s7)
ffffffffc0203464:	fff806b7          	lui	a3,0xfff80
ffffffffc0203468:	9736                	add	a4,a4,a3
ffffffffc020346a:	071a                	slli	a4,a4,0x6
ffffffffc020346c:	00e78db3          	add	s11,a5,a4
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203470:	10002773          	csrr	a4,sstatus
ffffffffc0203474:	8b09                	andi	a4,a4,2
ffffffffc0203476:	e35d                	bnez	a4,ffffffffc020351c <copy_range+0x186>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203478:	000cb703          	ld	a4,0(s9)
ffffffffc020347c:	4505                	li	a0,1
ffffffffc020347e:	6f18                	ld	a4,24(a4)
ffffffffc0203480:	9702                	jalr	a4
ffffffffc0203482:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc0203484:	0e0d8163          	beqz	s11,ffffffffc0203566 <copy_range+0x1d0>
            assert(npage != NULL);
ffffffffc0203488:	100d0f63          	beqz	s10,ffffffffc02035a6 <copy_range+0x210>
    return page - pages + nbase;
ffffffffc020348c:	000bb703          	ld	a4,0(s7)
ffffffffc0203490:	000805b7          	lui	a1,0x80
    return KADDR(page2pa(page));
ffffffffc0203494:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0203498:	40ed86b3          	sub	a3,s11,a4
ffffffffc020349c:	8699                	srai	a3,a3,0x6
ffffffffc020349e:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc02034a0:	0166f7b3          	and	a5,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02034a4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02034a6:	0ac7f463          	bgeu	a5,a2,ffffffffc020354e <copy_range+0x1b8>
    return page - pages + nbase;
ffffffffc02034aa:	40ed07b3          	sub	a5,s10,a4
    return KADDR(page2pa(page));
ffffffffc02034ae:	000a7717          	auipc	a4,0xa7
ffffffffc02034b2:	3d270713          	addi	a4,a4,978 # ffffffffc02aa880 <va_pa_offset>
ffffffffc02034b6:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc02034b8:	8799                	srai	a5,a5,0x6
ffffffffc02034ba:	97ae                	add	a5,a5,a1
    return KADDR(page2pa(page));
ffffffffc02034bc:	0167f733          	and	a4,a5,s6
ffffffffc02034c0:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02034c4:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02034c6:	08c77363          	bgeu	a4,a2,ffffffffc020354c <copy_range+0x1b6>
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ffffffffc02034ca:	6605                	lui	a2,0x1
ffffffffc02034cc:	953e                	add	a0,a0,a5
ffffffffc02034ce:	310020ef          	jal	ra,ffffffffc02057de <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc02034d2:	86a6                	mv	a3,s1
ffffffffc02034d4:	8622                	mv	a2,s0
ffffffffc02034d6:	85ea                	mv	a1,s10
ffffffffc02034d8:	8556                	mv	a0,s5
ffffffffc02034da:	986ff0ef          	jal	ra,ffffffffc0202660 <page_insert>
ffffffffc02034de:	84aa                	mv	s1,a0
            if (ret != 0) {
ffffffffc02034e0:	d51d                	beqz	a0,ffffffffc020340e <copy_range+0x78>
                cprintf("copy_range: page_insert failed at 0x%x\n", start);
ffffffffc02034e2:	85a2                	mv	a1,s0
ffffffffc02034e4:	00004517          	auipc	a0,0x4
ffffffffc02034e8:	8b450513          	addi	a0,a0,-1868 # ffffffffc0206d98 <default_pmm_manager+0x760>
ffffffffc02034ec:	ca9fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02034f0:	100027f3          	csrr	a5,sstatus
ffffffffc02034f4:	8b89                	andi	a5,a5,2
ffffffffc02034f6:	e3a1                	bnez	a5,ffffffffc0203536 <copy_range+0x1a0>
        pmm_manager->free_pages(base, n);
ffffffffc02034f8:	000cb783          	ld	a5,0(s9)
ffffffffc02034fc:	4585                	li	a1,1
ffffffffc02034fe:	856a                	mv	a0,s10
ffffffffc0203500:	739c                	ld	a5,32(a5)
ffffffffc0203502:	9782                	jalr	a5
    if (flag)
ffffffffc0203504:	bf09                	j	ffffffffc0203416 <copy_range+0x80>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203506:	00200637          	lui	a2,0x200
ffffffffc020350a:	9432                	add	s0,s0,a2
ffffffffc020350c:	ffe00637          	lui	a2,0xffe00
ffffffffc0203510:	8c71                	and	s0,s0,a2
    } while (start != 0 && start < end);
ffffffffc0203512:	f00401e3          	beqz	s0,ffffffffc0203414 <copy_range+0x7e>
ffffffffc0203516:	ef2461e3          	bltu	s0,s2,ffffffffc02033f8 <copy_range+0x62>
ffffffffc020351a:	bded                	j	ffffffffc0203414 <copy_range+0x7e>
        intr_disable();
ffffffffc020351c:	c98fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203520:	000cb703          	ld	a4,0(s9)
ffffffffc0203524:	4505                	li	a0,1
ffffffffc0203526:	6f18                	ld	a4,24(a4)
ffffffffc0203528:	9702                	jalr	a4
ffffffffc020352a:	8d2a                	mv	s10,a0
        intr_enable();
ffffffffc020352c:	c82fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0203530:	bf91                	j	ffffffffc0203484 <copy_range+0xee>
                return -E_NO_MEM;
ffffffffc0203532:	54f1                	li	s1,-4
ffffffffc0203534:	b5cd                	j	ffffffffc0203416 <copy_range+0x80>
        intr_disable();
ffffffffc0203536:	c7efd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020353a:	000cb783          	ld	a5,0(s9)
ffffffffc020353e:	4585                	li	a1,1
ffffffffc0203540:	856a                	mv	a0,s10
ffffffffc0203542:	739c                	ld	a5,32(a5)
ffffffffc0203544:	9782                	jalr	a5
        intr_enable();
ffffffffc0203546:	c68fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020354a:	b5f1                	j	ffffffffc0203416 <copy_range+0x80>
ffffffffc020354c:	86be                	mv	a3,a5
ffffffffc020354e:	00003617          	auipc	a2,0x3
ffffffffc0203552:	12260613          	addi	a2,a2,290 # ffffffffc0206670 <default_pmm_manager+0x38>
ffffffffc0203556:	07100593          	li	a1,113
ffffffffc020355a:	00003517          	auipc	a0,0x3
ffffffffc020355e:	13e50513          	addi	a0,a0,318 # ffffffffc0206698 <default_pmm_manager+0x60>
ffffffffc0203562:	f2dfc0ef          	jal	ra,ffffffffc020048e <__panic>
            assert(page != NULL);
ffffffffc0203566:	00004697          	auipc	a3,0x4
ffffffffc020356a:	81268693          	addi	a3,a3,-2030 # ffffffffc0206d78 <default_pmm_manager+0x740>
ffffffffc020356e:	00003617          	auipc	a2,0x3
ffffffffc0203572:	d1a60613          	addi	a2,a2,-742 # ffffffffc0206288 <commands+0x828>
ffffffffc0203576:	19400593          	li	a1,404
ffffffffc020357a:	00003517          	auipc	a0,0x3
ffffffffc020357e:	20e50513          	addi	a0,a0,526 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0203582:	f0dfc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203586:	00003697          	auipc	a3,0x3
ffffffffc020358a:	24268693          	addi	a3,a3,578 # ffffffffc02067c8 <default_pmm_manager+0x190>
ffffffffc020358e:	00003617          	auipc	a2,0x3
ffffffffc0203592:	cfa60613          	addi	a2,a2,-774 # ffffffffc0206288 <commands+0x828>
ffffffffc0203596:	17c00593          	li	a1,380
ffffffffc020359a:	00003517          	auipc	a0,0x3
ffffffffc020359e:	1ee50513          	addi	a0,a0,494 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc02035a2:	eedfc0ef          	jal	ra,ffffffffc020048e <__panic>
            assert(npage != NULL);
ffffffffc02035a6:	00003697          	auipc	a3,0x3
ffffffffc02035aa:	7e268693          	addi	a3,a3,2018 # ffffffffc0206d88 <default_pmm_manager+0x750>
ffffffffc02035ae:	00003617          	auipc	a2,0x3
ffffffffc02035b2:	cda60613          	addi	a2,a2,-806 # ffffffffc0206288 <commands+0x828>
ffffffffc02035b6:	19500593          	li	a1,405
ffffffffc02035ba:	00003517          	auipc	a0,0x3
ffffffffc02035be:	1ce50513          	addi	a0,a0,462 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc02035c2:	ecdfc0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02035c6:	00003617          	auipc	a2,0x3
ffffffffc02035ca:	17a60613          	addi	a2,a2,378 # ffffffffc0206740 <default_pmm_manager+0x108>
ffffffffc02035ce:	06900593          	li	a1,105
ffffffffc02035d2:	00003517          	auipc	a0,0x3
ffffffffc02035d6:	0c650513          	addi	a0,a0,198 # ffffffffc0206698 <default_pmm_manager+0x60>
ffffffffc02035da:	eb5fc0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02035de:	00003617          	auipc	a2,0x3
ffffffffc02035e2:	18260613          	addi	a2,a2,386 # ffffffffc0206760 <default_pmm_manager+0x128>
ffffffffc02035e6:	07f00593          	li	a1,127
ffffffffc02035ea:	00003517          	auipc	a0,0x3
ffffffffc02035ee:	0ae50513          	addi	a0,a0,174 # ffffffffc0206698 <default_pmm_manager+0x60>
ffffffffc02035f2:	e9dfc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02035f6:	00003697          	auipc	a3,0x3
ffffffffc02035fa:	1a268693          	addi	a3,a3,418 # ffffffffc0206798 <default_pmm_manager+0x160>
ffffffffc02035fe:	00003617          	auipc	a2,0x3
ffffffffc0203602:	c8a60613          	addi	a2,a2,-886 # ffffffffc0206288 <commands+0x828>
ffffffffc0203606:	17b00593          	li	a1,379
ffffffffc020360a:	00003517          	auipc	a0,0x3
ffffffffc020360e:	17e50513          	addi	a0,a0,382 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc0203612:	e7dfc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203616 <pgdir_alloc_page>:
{
ffffffffc0203616:	7179                	addi	sp,sp,-48
ffffffffc0203618:	ec26                	sd	s1,24(sp)
ffffffffc020361a:	e84a                	sd	s2,16(sp)
ffffffffc020361c:	e052                	sd	s4,0(sp)
ffffffffc020361e:	f406                	sd	ra,40(sp)
ffffffffc0203620:	f022                	sd	s0,32(sp)
ffffffffc0203622:	e44e                	sd	s3,8(sp)
ffffffffc0203624:	8a2a                	mv	s4,a0
ffffffffc0203626:	84ae                	mv	s1,a1
ffffffffc0203628:	8932                	mv	s2,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020362a:	100027f3          	csrr	a5,sstatus
ffffffffc020362e:	8b89                	andi	a5,a5,2
        page = pmm_manager->alloc_pages(n);
ffffffffc0203630:	000a7997          	auipc	s3,0xa7
ffffffffc0203634:	24898993          	addi	s3,s3,584 # ffffffffc02aa878 <pmm_manager>
ffffffffc0203638:	ef8d                	bnez	a5,ffffffffc0203672 <pgdir_alloc_page+0x5c>
ffffffffc020363a:	0009b783          	ld	a5,0(s3)
ffffffffc020363e:	4505                	li	a0,1
ffffffffc0203640:	6f9c                	ld	a5,24(a5)
ffffffffc0203642:	9782                	jalr	a5
ffffffffc0203644:	842a                	mv	s0,a0
    if (page != NULL)
ffffffffc0203646:	cc09                	beqz	s0,ffffffffc0203660 <pgdir_alloc_page+0x4a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc0203648:	86ca                	mv	a3,s2
ffffffffc020364a:	8626                	mv	a2,s1
ffffffffc020364c:	85a2                	mv	a1,s0
ffffffffc020364e:	8552                	mv	a0,s4
ffffffffc0203650:	810ff0ef          	jal	ra,ffffffffc0202660 <page_insert>
ffffffffc0203654:	e915                	bnez	a0,ffffffffc0203688 <pgdir_alloc_page+0x72>
        assert(page_ref(page) == 1);
ffffffffc0203656:	4018                	lw	a4,0(s0)
        page->pra_vaddr = la;
ffffffffc0203658:	fc04                	sd	s1,56(s0)
        assert(page_ref(page) == 1);
ffffffffc020365a:	4785                	li	a5,1
ffffffffc020365c:	04f71e63          	bne	a4,a5,ffffffffc02036b8 <pgdir_alloc_page+0xa2>
}
ffffffffc0203660:	70a2                	ld	ra,40(sp)
ffffffffc0203662:	8522                	mv	a0,s0
ffffffffc0203664:	7402                	ld	s0,32(sp)
ffffffffc0203666:	64e2                	ld	s1,24(sp)
ffffffffc0203668:	6942                	ld	s2,16(sp)
ffffffffc020366a:	69a2                	ld	s3,8(sp)
ffffffffc020366c:	6a02                	ld	s4,0(sp)
ffffffffc020366e:	6145                	addi	sp,sp,48
ffffffffc0203670:	8082                	ret
        intr_disable();
ffffffffc0203672:	b42fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203676:	0009b783          	ld	a5,0(s3)
ffffffffc020367a:	4505                	li	a0,1
ffffffffc020367c:	6f9c                	ld	a5,24(a5)
ffffffffc020367e:	9782                	jalr	a5
ffffffffc0203680:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203682:	b2cfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0203686:	b7c1                	j	ffffffffc0203646 <pgdir_alloc_page+0x30>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203688:	100027f3          	csrr	a5,sstatus
ffffffffc020368c:	8b89                	andi	a5,a5,2
ffffffffc020368e:	eb89                	bnez	a5,ffffffffc02036a0 <pgdir_alloc_page+0x8a>
        pmm_manager->free_pages(base, n);
ffffffffc0203690:	0009b783          	ld	a5,0(s3)
ffffffffc0203694:	8522                	mv	a0,s0
ffffffffc0203696:	4585                	li	a1,1
ffffffffc0203698:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc020369a:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc020369c:	9782                	jalr	a5
    if (flag)
ffffffffc020369e:	b7c9                	j	ffffffffc0203660 <pgdir_alloc_page+0x4a>
        intr_disable();
ffffffffc02036a0:	b14fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc02036a4:	0009b783          	ld	a5,0(s3)
ffffffffc02036a8:	8522                	mv	a0,s0
ffffffffc02036aa:	4585                	li	a1,1
ffffffffc02036ac:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc02036ae:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc02036b0:	9782                	jalr	a5
        intr_enable();
ffffffffc02036b2:	afcfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02036b6:	b76d                	j	ffffffffc0203660 <pgdir_alloc_page+0x4a>
        assert(page_ref(page) == 1);
ffffffffc02036b8:	00003697          	auipc	a3,0x3
ffffffffc02036bc:	70868693          	addi	a3,a3,1800 # ffffffffc0206dc0 <default_pmm_manager+0x788>
ffffffffc02036c0:	00003617          	auipc	a2,0x3
ffffffffc02036c4:	bc860613          	addi	a2,a2,-1080 # ffffffffc0206288 <commands+0x828>
ffffffffc02036c8:	1fe00593          	li	a1,510
ffffffffc02036cc:	00003517          	auipc	a0,0x3
ffffffffc02036d0:	0bc50513          	addi	a0,a0,188 # ffffffffc0206788 <default_pmm_manager+0x150>
ffffffffc02036d4:	dbbfc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02036d8 <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02036d8:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02036da:	00003697          	auipc	a3,0x3
ffffffffc02036de:	6fe68693          	addi	a3,a3,1790 # ffffffffc0206dd8 <default_pmm_manager+0x7a0>
ffffffffc02036e2:	00003617          	auipc	a2,0x3
ffffffffc02036e6:	ba660613          	addi	a2,a2,-1114 # ffffffffc0206288 <commands+0x828>
ffffffffc02036ea:	07400593          	li	a1,116
ffffffffc02036ee:	00003517          	auipc	a0,0x3
ffffffffc02036f2:	70a50513          	addi	a0,a0,1802 # ffffffffc0206df8 <default_pmm_manager+0x7c0>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02036f6:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02036f8:	d97fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02036fc <mm_create>:
{
ffffffffc02036fc:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02036fe:	04000513          	li	a0,64
{
ffffffffc0203702:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203704:	dd6fe0ef          	jal	ra,ffffffffc0201cda <kmalloc>
    if (mm != NULL)
ffffffffc0203708:	cd19                	beqz	a0,ffffffffc0203726 <mm_create+0x2a>
    elm->prev = elm->next = elm;
ffffffffc020370a:	e508                	sd	a0,8(a0)
ffffffffc020370c:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc020370e:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203712:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203716:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc020371a:	02053423          	sd	zero,40(a0)
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc020371e:	02052823          	sw	zero,48(a0)
typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
ffffffffc0203722:	02053c23          	sd	zero,56(a0)
}
ffffffffc0203726:	60a2                	ld	ra,8(sp)
ffffffffc0203728:	0141                	addi	sp,sp,16
ffffffffc020372a:	8082                	ret

ffffffffc020372c <find_vma>:
{
ffffffffc020372c:	86aa                	mv	a3,a0
    if (mm != NULL)
ffffffffc020372e:	c505                	beqz	a0,ffffffffc0203756 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0203730:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0203732:	c501                	beqz	a0,ffffffffc020373a <find_vma+0xe>
ffffffffc0203734:	651c                	ld	a5,8(a0)
ffffffffc0203736:	02f5f263          	bgeu	a1,a5,ffffffffc020375a <find_vma+0x2e>
    return listelm->next;
ffffffffc020373a:	669c                	ld	a5,8(a3)
            while ((le = list_next(le)) != list)
ffffffffc020373c:	00f68d63          	beq	a3,a5,ffffffffc0203756 <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc0203740:	fe87b703          	ld	a4,-24(a5) # 1fffe8 <_binary_obj___user_exit_out_size+0x1f4eb0>
ffffffffc0203744:	00e5e663          	bltu	a1,a4,ffffffffc0203750 <find_vma+0x24>
ffffffffc0203748:	ff07b703          	ld	a4,-16(a5)
ffffffffc020374c:	00e5ec63          	bltu	a1,a4,ffffffffc0203764 <find_vma+0x38>
ffffffffc0203750:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc0203752:	fef697e3          	bne	a3,a5,ffffffffc0203740 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0203756:	4501                	li	a0,0
}
ffffffffc0203758:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc020375a:	691c                	ld	a5,16(a0)
ffffffffc020375c:	fcf5ffe3          	bgeu	a1,a5,ffffffffc020373a <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0203760:	ea88                	sd	a0,16(a3)
ffffffffc0203762:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc0203764:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0203768:	ea88                	sd	a0,16(a3)
ffffffffc020376a:	8082                	ret

ffffffffc020376c <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc020376c:	6590                	ld	a2,8(a1)
ffffffffc020376e:	0105b803          	ld	a6,16(a1) # 80010 <_binary_obj___user_exit_out_size+0x74ed8>
{
ffffffffc0203772:	1141                	addi	sp,sp,-16
ffffffffc0203774:	e406                	sd	ra,8(sp)
ffffffffc0203776:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203778:	01066763          	bltu	a2,a6,ffffffffc0203786 <insert_vma_struct+0x1a>
ffffffffc020377c:	a085                	j	ffffffffc02037dc <insert_vma_struct+0x70>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc020377e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203782:	04e66863          	bltu	a2,a4,ffffffffc02037d2 <insert_vma_struct+0x66>
ffffffffc0203786:	86be                	mv	a3,a5
ffffffffc0203788:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc020378a:	fef51ae3          	bne	a0,a5,ffffffffc020377e <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc020378e:	02a68463          	beq	a3,a0,ffffffffc02037b6 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203792:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203796:	fe86b883          	ld	a7,-24(a3)
ffffffffc020379a:	08e8f163          	bgeu	a7,a4,ffffffffc020381c <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020379e:	04e66f63          	bltu	a2,a4,ffffffffc02037fc <insert_vma_struct+0x90>
    }
    if (le_next != list)
ffffffffc02037a2:	00f50a63          	beq	a0,a5,ffffffffc02037b6 <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc02037a6:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02037aa:	05076963          	bltu	a4,a6,ffffffffc02037fc <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02037ae:	ff07b603          	ld	a2,-16(a5)
ffffffffc02037b2:	02c77363          	bgeu	a4,a2,ffffffffc02037d8 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc02037b6:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02037b8:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02037ba:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02037be:	e390                	sd	a2,0(a5)
ffffffffc02037c0:	e690                	sd	a2,8(a3)
}
ffffffffc02037c2:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02037c4:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02037c6:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc02037c8:	0017079b          	addiw	a5,a4,1
ffffffffc02037cc:	d11c                	sw	a5,32(a0)
}
ffffffffc02037ce:	0141                	addi	sp,sp,16
ffffffffc02037d0:	8082                	ret
    if (le_prev != list)
ffffffffc02037d2:	fca690e3          	bne	a3,a0,ffffffffc0203792 <insert_vma_struct+0x26>
ffffffffc02037d6:	bfd1                	j	ffffffffc02037aa <insert_vma_struct+0x3e>
ffffffffc02037d8:	f01ff0ef          	jal	ra,ffffffffc02036d8 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02037dc:	00003697          	auipc	a3,0x3
ffffffffc02037e0:	62c68693          	addi	a3,a3,1580 # ffffffffc0206e08 <default_pmm_manager+0x7d0>
ffffffffc02037e4:	00003617          	auipc	a2,0x3
ffffffffc02037e8:	aa460613          	addi	a2,a2,-1372 # ffffffffc0206288 <commands+0x828>
ffffffffc02037ec:	07a00593          	li	a1,122
ffffffffc02037f0:	00003517          	auipc	a0,0x3
ffffffffc02037f4:	60850513          	addi	a0,a0,1544 # ffffffffc0206df8 <default_pmm_manager+0x7c0>
ffffffffc02037f8:	c97fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02037fc:	00003697          	auipc	a3,0x3
ffffffffc0203800:	64c68693          	addi	a3,a3,1612 # ffffffffc0206e48 <default_pmm_manager+0x810>
ffffffffc0203804:	00003617          	auipc	a2,0x3
ffffffffc0203808:	a8460613          	addi	a2,a2,-1404 # ffffffffc0206288 <commands+0x828>
ffffffffc020380c:	07300593          	li	a1,115
ffffffffc0203810:	00003517          	auipc	a0,0x3
ffffffffc0203814:	5e850513          	addi	a0,a0,1512 # ffffffffc0206df8 <default_pmm_manager+0x7c0>
ffffffffc0203818:	c77fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020381c:	00003697          	auipc	a3,0x3
ffffffffc0203820:	60c68693          	addi	a3,a3,1548 # ffffffffc0206e28 <default_pmm_manager+0x7f0>
ffffffffc0203824:	00003617          	auipc	a2,0x3
ffffffffc0203828:	a6460613          	addi	a2,a2,-1436 # ffffffffc0206288 <commands+0x828>
ffffffffc020382c:	07200593          	li	a1,114
ffffffffc0203830:	00003517          	auipc	a0,0x3
ffffffffc0203834:	5c850513          	addi	a0,a0,1480 # ffffffffc0206df8 <default_pmm_manager+0x7c0>
ffffffffc0203838:	c57fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020383c <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc020383c:	591c                	lw	a5,48(a0)
{
ffffffffc020383e:	1141                	addi	sp,sp,-16
ffffffffc0203840:	e406                	sd	ra,8(sp)
ffffffffc0203842:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0203844:	e78d                	bnez	a5,ffffffffc020386e <mm_destroy+0x32>
ffffffffc0203846:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203848:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc020384a:	00a40c63          	beq	s0,a0,ffffffffc0203862 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020384e:	6118                	ld	a4,0(a0)
ffffffffc0203850:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc0203852:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203854:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203856:	e398                	sd	a4,0(a5)
ffffffffc0203858:	d32fe0ef          	jal	ra,ffffffffc0201d8a <kfree>
    return listelm->next;
ffffffffc020385c:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc020385e:	fea418e3          	bne	s0,a0,ffffffffc020384e <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc0203862:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc0203864:	6402                	ld	s0,0(sp)
ffffffffc0203866:	60a2                	ld	ra,8(sp)
ffffffffc0203868:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc020386a:	d20fe06f          	j	ffffffffc0201d8a <kfree>
    assert(mm_count(mm) == 0);
ffffffffc020386e:	00003697          	auipc	a3,0x3
ffffffffc0203872:	5fa68693          	addi	a3,a3,1530 # ffffffffc0206e68 <default_pmm_manager+0x830>
ffffffffc0203876:	00003617          	auipc	a2,0x3
ffffffffc020387a:	a1260613          	addi	a2,a2,-1518 # ffffffffc0206288 <commands+0x828>
ffffffffc020387e:	09e00593          	li	a1,158
ffffffffc0203882:	00003517          	auipc	a0,0x3
ffffffffc0203886:	57650513          	addi	a0,a0,1398 # ffffffffc0206df8 <default_pmm_manager+0x7c0>
ffffffffc020388a:	c05fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020388e <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
ffffffffc020388e:	7139                	addi	sp,sp,-64
ffffffffc0203890:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0203892:	6405                	lui	s0,0x1
ffffffffc0203894:	147d                	addi	s0,s0,-1
ffffffffc0203896:	77fd                	lui	a5,0xfffff
ffffffffc0203898:	9622                	add	a2,a2,s0
ffffffffc020389a:	962e                	add	a2,a2,a1
{
ffffffffc020389c:	f426                	sd	s1,40(sp)
ffffffffc020389e:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02038a0:	00f5f4b3          	and	s1,a1,a5
{
ffffffffc02038a4:	f04a                	sd	s2,32(sp)
ffffffffc02038a6:	ec4e                	sd	s3,24(sp)
ffffffffc02038a8:	e852                	sd	s4,16(sp)
ffffffffc02038aa:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end))
ffffffffc02038ac:	002005b7          	lui	a1,0x200
ffffffffc02038b0:	00f67433          	and	s0,a2,a5
ffffffffc02038b4:	06b4e363          	bltu	s1,a1,ffffffffc020391a <mm_map+0x8c>
ffffffffc02038b8:	0684f163          	bgeu	s1,s0,ffffffffc020391a <mm_map+0x8c>
ffffffffc02038bc:	4785                	li	a5,1
ffffffffc02038be:	07fe                	slli	a5,a5,0x1f
ffffffffc02038c0:	0487ed63          	bltu	a5,s0,ffffffffc020391a <mm_map+0x8c>
ffffffffc02038c4:	89aa                	mv	s3,a0
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02038c6:	cd21                	beqz	a0,ffffffffc020391e <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc02038c8:	85a6                	mv	a1,s1
ffffffffc02038ca:	8ab6                	mv	s5,a3
ffffffffc02038cc:	8a3a                	mv	s4,a4
ffffffffc02038ce:	e5fff0ef          	jal	ra,ffffffffc020372c <find_vma>
ffffffffc02038d2:	c501                	beqz	a0,ffffffffc02038da <mm_map+0x4c>
ffffffffc02038d4:	651c                	ld	a5,8(a0)
ffffffffc02038d6:	0487e263          	bltu	a5,s0,ffffffffc020391a <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02038da:	03000513          	li	a0,48
ffffffffc02038de:	bfcfe0ef          	jal	ra,ffffffffc0201cda <kmalloc>
ffffffffc02038e2:	892a                	mv	s2,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02038e4:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc02038e6:	02090163          	beqz	s2,ffffffffc0203908 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02038ea:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02038ec:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc02038f0:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc02038f4:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc02038f8:	85ca                	mv	a1,s2
ffffffffc02038fa:	e73ff0ef          	jal	ra,ffffffffc020376c <insert_vma_struct>
    if (vma_store != NULL)
    {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc02038fe:	4501                	li	a0,0
    if (vma_store != NULL)
ffffffffc0203900:	000a0463          	beqz	s4,ffffffffc0203908 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc0203904:	012a3023          	sd	s2,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>

out:
    return ret;
}
ffffffffc0203908:	70e2                	ld	ra,56(sp)
ffffffffc020390a:	7442                	ld	s0,48(sp)
ffffffffc020390c:	74a2                	ld	s1,40(sp)
ffffffffc020390e:	7902                	ld	s2,32(sp)
ffffffffc0203910:	69e2                	ld	s3,24(sp)
ffffffffc0203912:	6a42                	ld	s4,16(sp)
ffffffffc0203914:	6aa2                	ld	s5,8(sp)
ffffffffc0203916:	6121                	addi	sp,sp,64
ffffffffc0203918:	8082                	ret
        return -E_INVAL;
ffffffffc020391a:	5575                	li	a0,-3
ffffffffc020391c:	b7f5                	j	ffffffffc0203908 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc020391e:	00003697          	auipc	a3,0x3
ffffffffc0203922:	56268693          	addi	a3,a3,1378 # ffffffffc0206e80 <default_pmm_manager+0x848>
ffffffffc0203926:	00003617          	auipc	a2,0x3
ffffffffc020392a:	96260613          	addi	a2,a2,-1694 # ffffffffc0206288 <commands+0x828>
ffffffffc020392e:	0b300593          	li	a1,179
ffffffffc0203932:	00003517          	auipc	a0,0x3
ffffffffc0203936:	4c650513          	addi	a0,a0,1222 # ffffffffc0206df8 <default_pmm_manager+0x7c0>
ffffffffc020393a:	b55fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020393e <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc020393e:	7139                	addi	sp,sp,-64
ffffffffc0203940:	fc06                	sd	ra,56(sp)
ffffffffc0203942:	f822                	sd	s0,48(sp)
ffffffffc0203944:	f426                	sd	s1,40(sp)
ffffffffc0203946:	f04a                	sd	s2,32(sp)
ffffffffc0203948:	ec4e                	sd	s3,24(sp)
ffffffffc020394a:	e852                	sd	s4,16(sp)
ffffffffc020394c:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc020394e:	c52d                	beqz	a0,ffffffffc02039b8 <dup_mmap+0x7a>
ffffffffc0203950:	892a                	mv	s2,a0
ffffffffc0203952:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0203954:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0203956:	e595                	bnez	a1,ffffffffc0203982 <dup_mmap+0x44>
ffffffffc0203958:	a085                	j	ffffffffc02039b8 <dup_mmap+0x7a>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc020395a:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc020395c:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4ed0>
        vma->vm_end = vm_end;
ffffffffc0203960:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0203964:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc0203968:	e05ff0ef          	jal	ra,ffffffffc020376c <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc020396c:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bd0>
ffffffffc0203970:	fe843603          	ld	a2,-24(s0)
ffffffffc0203974:	6c8c                	ld	a1,24(s1)
ffffffffc0203976:	01893503          	ld	a0,24(s2)
ffffffffc020397a:	4701                	li	a4,0
ffffffffc020397c:	a1bff0ef          	jal	ra,ffffffffc0203396 <copy_range>
ffffffffc0203980:	e105                	bnez	a0,ffffffffc02039a0 <dup_mmap+0x62>
    return listelm->prev;
ffffffffc0203982:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc0203984:	02848863          	beq	s1,s0,ffffffffc02039b4 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203988:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc020398c:	fe843a83          	ld	s5,-24(s0)
ffffffffc0203990:	ff043a03          	ld	s4,-16(s0)
ffffffffc0203994:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203998:	b42fe0ef          	jal	ra,ffffffffc0201cda <kmalloc>
ffffffffc020399c:	85aa                	mv	a1,a0
    if (vma != NULL)
ffffffffc020399e:	fd55                	bnez	a0,ffffffffc020395a <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc02039a0:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02039a2:	70e2                	ld	ra,56(sp)
ffffffffc02039a4:	7442                	ld	s0,48(sp)
ffffffffc02039a6:	74a2                	ld	s1,40(sp)
ffffffffc02039a8:	7902                	ld	s2,32(sp)
ffffffffc02039aa:	69e2                	ld	s3,24(sp)
ffffffffc02039ac:	6a42                	ld	s4,16(sp)
ffffffffc02039ae:	6aa2                	ld	s5,8(sp)
ffffffffc02039b0:	6121                	addi	sp,sp,64
ffffffffc02039b2:	8082                	ret
    return 0;
ffffffffc02039b4:	4501                	li	a0,0
ffffffffc02039b6:	b7f5                	j	ffffffffc02039a2 <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc02039b8:	00003697          	auipc	a3,0x3
ffffffffc02039bc:	4d868693          	addi	a3,a3,1240 # ffffffffc0206e90 <default_pmm_manager+0x858>
ffffffffc02039c0:	00003617          	auipc	a2,0x3
ffffffffc02039c4:	8c860613          	addi	a2,a2,-1848 # ffffffffc0206288 <commands+0x828>
ffffffffc02039c8:	0cf00593          	li	a1,207
ffffffffc02039cc:	00003517          	auipc	a0,0x3
ffffffffc02039d0:	42c50513          	addi	a0,a0,1068 # ffffffffc0206df8 <default_pmm_manager+0x7c0>
ffffffffc02039d4:	abbfc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02039d8 <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc02039d8:	1101                	addi	sp,sp,-32
ffffffffc02039da:	ec06                	sd	ra,24(sp)
ffffffffc02039dc:	e822                	sd	s0,16(sp)
ffffffffc02039de:	e426                	sd	s1,8(sp)
ffffffffc02039e0:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02039e2:	c531                	beqz	a0,ffffffffc0203a2e <exit_mmap+0x56>
ffffffffc02039e4:	591c                	lw	a5,48(a0)
ffffffffc02039e6:	84aa                	mv	s1,a0
ffffffffc02039e8:	e3b9                	bnez	a5,ffffffffc0203a2e <exit_mmap+0x56>
    return listelm->next;
ffffffffc02039ea:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02039ec:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc02039f0:	02850663          	beq	a0,s0,ffffffffc0203a1c <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02039f4:	ff043603          	ld	a2,-16(s0)
ffffffffc02039f8:	fe843583          	ld	a1,-24(s0)
ffffffffc02039fc:	854a                	mv	a0,s2
ffffffffc02039fe:	feefe0ef          	jal	ra,ffffffffc02021ec <unmap_range>
ffffffffc0203a02:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0203a04:	fe8498e3          	bne	s1,s0,ffffffffc02039f4 <exit_mmap+0x1c>
ffffffffc0203a08:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc0203a0a:	00848c63          	beq	s1,s0,ffffffffc0203a22 <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0203a0e:	ff043603          	ld	a2,-16(s0)
ffffffffc0203a12:	fe843583          	ld	a1,-24(s0)
ffffffffc0203a16:	854a                	mv	a0,s2
ffffffffc0203a18:	91bfe0ef          	jal	ra,ffffffffc0202332 <exit_range>
ffffffffc0203a1c:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0203a1e:	fe8498e3          	bne	s1,s0,ffffffffc0203a0e <exit_mmap+0x36>
    }
}
ffffffffc0203a22:	60e2                	ld	ra,24(sp)
ffffffffc0203a24:	6442                	ld	s0,16(sp)
ffffffffc0203a26:	64a2                	ld	s1,8(sp)
ffffffffc0203a28:	6902                	ld	s2,0(sp)
ffffffffc0203a2a:	6105                	addi	sp,sp,32
ffffffffc0203a2c:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203a2e:	00003697          	auipc	a3,0x3
ffffffffc0203a32:	48268693          	addi	a3,a3,1154 # ffffffffc0206eb0 <default_pmm_manager+0x878>
ffffffffc0203a36:	00003617          	auipc	a2,0x3
ffffffffc0203a3a:	85260613          	addi	a2,a2,-1966 # ffffffffc0206288 <commands+0x828>
ffffffffc0203a3e:	0e800593          	li	a1,232
ffffffffc0203a42:	00003517          	auipc	a0,0x3
ffffffffc0203a46:	3b650513          	addi	a0,a0,950 # ffffffffc0206df8 <default_pmm_manager+0x7c0>
ffffffffc0203a4a:	a45fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203a4e <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0203a4e:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203a50:	04000513          	li	a0,64
{
ffffffffc0203a54:	fc06                	sd	ra,56(sp)
ffffffffc0203a56:	f822                	sd	s0,48(sp)
ffffffffc0203a58:	f426                	sd	s1,40(sp)
ffffffffc0203a5a:	f04a                	sd	s2,32(sp)
ffffffffc0203a5c:	ec4e                	sd	s3,24(sp)
ffffffffc0203a5e:	e852                	sd	s4,16(sp)
ffffffffc0203a60:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203a62:	a78fe0ef          	jal	ra,ffffffffc0201cda <kmalloc>
    if (mm != NULL)
ffffffffc0203a66:	2e050663          	beqz	a0,ffffffffc0203d52 <vmm_init+0x304>
ffffffffc0203a6a:	84aa                	mv	s1,a0
    elm->prev = elm->next = elm;
ffffffffc0203a6c:	e508                	sd	a0,8(a0)
ffffffffc0203a6e:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203a70:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203a74:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203a78:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0203a7c:	02053423          	sd	zero,40(a0)
ffffffffc0203a80:	02052823          	sw	zero,48(a0)
ffffffffc0203a84:	02053c23          	sd	zero,56(a0)
ffffffffc0203a88:	03200413          	li	s0,50
ffffffffc0203a8c:	a811                	j	ffffffffc0203aa0 <vmm_init+0x52>
        vma->vm_start = vm_start;
ffffffffc0203a8e:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203a90:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203a92:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
ffffffffc0203a96:	146d                	addi	s0,s0,-5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203a98:	8526                	mv	a0,s1
ffffffffc0203a9a:	cd3ff0ef          	jal	ra,ffffffffc020376c <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0203a9e:	c80d                	beqz	s0,ffffffffc0203ad0 <vmm_init+0x82>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203aa0:	03000513          	li	a0,48
ffffffffc0203aa4:	a36fe0ef          	jal	ra,ffffffffc0201cda <kmalloc>
ffffffffc0203aa8:	85aa                	mv	a1,a0
ffffffffc0203aaa:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0203aae:	f165                	bnez	a0,ffffffffc0203a8e <vmm_init+0x40>
        assert(vma != NULL);
ffffffffc0203ab0:	00003697          	auipc	a3,0x3
ffffffffc0203ab4:	59868693          	addi	a3,a3,1432 # ffffffffc0207048 <default_pmm_manager+0xa10>
ffffffffc0203ab8:	00002617          	auipc	a2,0x2
ffffffffc0203abc:	7d060613          	addi	a2,a2,2000 # ffffffffc0206288 <commands+0x828>
ffffffffc0203ac0:	12c00593          	li	a1,300
ffffffffc0203ac4:	00003517          	auipc	a0,0x3
ffffffffc0203ac8:	33450513          	addi	a0,a0,820 # ffffffffc0206df8 <default_pmm_manager+0x7c0>
ffffffffc0203acc:	9c3fc0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc0203ad0:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203ad4:	1f900913          	li	s2,505
ffffffffc0203ad8:	a819                	j	ffffffffc0203aee <vmm_init+0xa0>
        vma->vm_start = vm_start;
ffffffffc0203ada:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203adc:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203ade:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203ae2:	0415                	addi	s0,s0,5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203ae4:	8526                	mv	a0,s1
ffffffffc0203ae6:	c87ff0ef          	jal	ra,ffffffffc020376c <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203aea:	03240a63          	beq	s0,s2,ffffffffc0203b1e <vmm_init+0xd0>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203aee:	03000513          	li	a0,48
ffffffffc0203af2:	9e8fe0ef          	jal	ra,ffffffffc0201cda <kmalloc>
ffffffffc0203af6:	85aa                	mv	a1,a0
ffffffffc0203af8:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0203afc:	fd79                	bnez	a0,ffffffffc0203ada <vmm_init+0x8c>
        assert(vma != NULL);
ffffffffc0203afe:	00003697          	auipc	a3,0x3
ffffffffc0203b02:	54a68693          	addi	a3,a3,1354 # ffffffffc0207048 <default_pmm_manager+0xa10>
ffffffffc0203b06:	00002617          	auipc	a2,0x2
ffffffffc0203b0a:	78260613          	addi	a2,a2,1922 # ffffffffc0206288 <commands+0x828>
ffffffffc0203b0e:	13300593          	li	a1,307
ffffffffc0203b12:	00003517          	auipc	a0,0x3
ffffffffc0203b16:	2e650513          	addi	a0,a0,742 # ffffffffc0206df8 <default_pmm_manager+0x7c0>
ffffffffc0203b1a:	975fc0ef          	jal	ra,ffffffffc020048e <__panic>
    return listelm->next;
ffffffffc0203b1e:	649c                	ld	a5,8(s1)
ffffffffc0203b20:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0203b22:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0203b26:	16f48663          	beq	s1,a5,ffffffffc0203c92 <vmm_init+0x244>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203b2a:	fe87b603          	ld	a2,-24(a5) # ffffffffffffefe8 <end+0x3fd54744>
ffffffffc0203b2e:	ffe70693          	addi	a3,a4,-2
ffffffffc0203b32:	10d61063          	bne	a2,a3,ffffffffc0203c32 <vmm_init+0x1e4>
ffffffffc0203b36:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203b3a:	0ed71c63          	bne	a4,a3,ffffffffc0203c32 <vmm_init+0x1e4>
    for (i = 1; i <= step2; i++)
ffffffffc0203b3e:	0715                	addi	a4,a4,5
ffffffffc0203b40:	679c                	ld	a5,8(a5)
ffffffffc0203b42:	feb712e3          	bne	a4,a1,ffffffffc0203b26 <vmm_init+0xd8>
ffffffffc0203b46:	4a1d                	li	s4,7
ffffffffc0203b48:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203b4a:	1f900a93          	li	s5,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203b4e:	85a2                	mv	a1,s0
ffffffffc0203b50:	8526                	mv	a0,s1
ffffffffc0203b52:	bdbff0ef          	jal	ra,ffffffffc020372c <find_vma>
ffffffffc0203b56:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0203b58:	16050d63          	beqz	a0,ffffffffc0203cd2 <vmm_init+0x284>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0203b5c:	00140593          	addi	a1,s0,1
ffffffffc0203b60:	8526                	mv	a0,s1
ffffffffc0203b62:	bcbff0ef          	jal	ra,ffffffffc020372c <find_vma>
ffffffffc0203b66:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203b68:	14050563          	beqz	a0,ffffffffc0203cb2 <vmm_init+0x264>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0203b6c:	85d2                	mv	a1,s4
ffffffffc0203b6e:	8526                	mv	a0,s1
ffffffffc0203b70:	bbdff0ef          	jal	ra,ffffffffc020372c <find_vma>
        assert(vma3 == NULL);
ffffffffc0203b74:	16051f63          	bnez	a0,ffffffffc0203cf2 <vmm_init+0x2a4>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0203b78:	00340593          	addi	a1,s0,3
ffffffffc0203b7c:	8526                	mv	a0,s1
ffffffffc0203b7e:	bafff0ef          	jal	ra,ffffffffc020372c <find_vma>
        assert(vma4 == NULL);
ffffffffc0203b82:	1a051863          	bnez	a0,ffffffffc0203d32 <vmm_init+0x2e4>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0203b86:	00440593          	addi	a1,s0,4
ffffffffc0203b8a:	8526                	mv	a0,s1
ffffffffc0203b8c:	ba1ff0ef          	jal	ra,ffffffffc020372c <find_vma>
        assert(vma5 == NULL);
ffffffffc0203b90:	18051163          	bnez	a0,ffffffffc0203d12 <vmm_init+0x2c4>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203b94:	00893783          	ld	a5,8(s2)
ffffffffc0203b98:	0a879d63          	bne	a5,s0,ffffffffc0203c52 <vmm_init+0x204>
ffffffffc0203b9c:	01093783          	ld	a5,16(s2)
ffffffffc0203ba0:	0b479963          	bne	a5,s4,ffffffffc0203c52 <vmm_init+0x204>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203ba4:	0089b783          	ld	a5,8(s3)
ffffffffc0203ba8:	0c879563          	bne	a5,s0,ffffffffc0203c72 <vmm_init+0x224>
ffffffffc0203bac:	0109b783          	ld	a5,16(s3)
ffffffffc0203bb0:	0d479163          	bne	a5,s4,ffffffffc0203c72 <vmm_init+0x224>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203bb4:	0415                	addi	s0,s0,5
ffffffffc0203bb6:	0a15                	addi	s4,s4,5
ffffffffc0203bb8:	f9541be3          	bne	s0,s5,ffffffffc0203b4e <vmm_init+0x100>
ffffffffc0203bbc:	4411                	li	s0,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0203bbe:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0203bc0:	85a2                	mv	a1,s0
ffffffffc0203bc2:	8526                	mv	a0,s1
ffffffffc0203bc4:	b69ff0ef          	jal	ra,ffffffffc020372c <find_vma>
ffffffffc0203bc8:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL)
ffffffffc0203bcc:	c90d                	beqz	a0,ffffffffc0203bfe <vmm_init+0x1b0>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0203bce:	6914                	ld	a3,16(a0)
ffffffffc0203bd0:	6510                	ld	a2,8(a0)
ffffffffc0203bd2:	00003517          	auipc	a0,0x3
ffffffffc0203bd6:	3fe50513          	addi	a0,a0,1022 # ffffffffc0206fd0 <default_pmm_manager+0x998>
ffffffffc0203bda:	dbafc0ef          	jal	ra,ffffffffc0200194 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203bde:	00003697          	auipc	a3,0x3
ffffffffc0203be2:	41a68693          	addi	a3,a3,1050 # ffffffffc0206ff8 <default_pmm_manager+0x9c0>
ffffffffc0203be6:	00002617          	auipc	a2,0x2
ffffffffc0203bea:	6a260613          	addi	a2,a2,1698 # ffffffffc0206288 <commands+0x828>
ffffffffc0203bee:	15900593          	li	a1,345
ffffffffc0203bf2:	00003517          	auipc	a0,0x3
ffffffffc0203bf6:	20650513          	addi	a0,a0,518 # ffffffffc0206df8 <default_pmm_manager+0x7c0>
ffffffffc0203bfa:	895fc0ef          	jal	ra,ffffffffc020048e <__panic>
    for (i = 4; i >= 0; i--)
ffffffffc0203bfe:	147d                	addi	s0,s0,-1
ffffffffc0203c00:	fd2410e3          	bne	s0,s2,ffffffffc0203bc0 <vmm_init+0x172>
    }

    mm_destroy(mm);
ffffffffc0203c04:	8526                	mv	a0,s1
ffffffffc0203c06:	c37ff0ef          	jal	ra,ffffffffc020383c <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203c0a:	00003517          	auipc	a0,0x3
ffffffffc0203c0e:	40650513          	addi	a0,a0,1030 # ffffffffc0207010 <default_pmm_manager+0x9d8>
ffffffffc0203c12:	d82fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
}
ffffffffc0203c16:	7442                	ld	s0,48(sp)
ffffffffc0203c18:	70e2                	ld	ra,56(sp)
ffffffffc0203c1a:	74a2                	ld	s1,40(sp)
ffffffffc0203c1c:	7902                	ld	s2,32(sp)
ffffffffc0203c1e:	69e2                	ld	s3,24(sp)
ffffffffc0203c20:	6a42                	ld	s4,16(sp)
ffffffffc0203c22:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203c24:	00003517          	auipc	a0,0x3
ffffffffc0203c28:	40c50513          	addi	a0,a0,1036 # ffffffffc0207030 <default_pmm_manager+0x9f8>
}
ffffffffc0203c2c:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203c2e:	d66fc06f          	j	ffffffffc0200194 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203c32:	00003697          	auipc	a3,0x3
ffffffffc0203c36:	2b668693          	addi	a3,a3,694 # ffffffffc0206ee8 <default_pmm_manager+0x8b0>
ffffffffc0203c3a:	00002617          	auipc	a2,0x2
ffffffffc0203c3e:	64e60613          	addi	a2,a2,1614 # ffffffffc0206288 <commands+0x828>
ffffffffc0203c42:	13d00593          	li	a1,317
ffffffffc0203c46:	00003517          	auipc	a0,0x3
ffffffffc0203c4a:	1b250513          	addi	a0,a0,434 # ffffffffc0206df8 <default_pmm_manager+0x7c0>
ffffffffc0203c4e:	841fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203c52:	00003697          	auipc	a3,0x3
ffffffffc0203c56:	31e68693          	addi	a3,a3,798 # ffffffffc0206f70 <default_pmm_manager+0x938>
ffffffffc0203c5a:	00002617          	auipc	a2,0x2
ffffffffc0203c5e:	62e60613          	addi	a2,a2,1582 # ffffffffc0206288 <commands+0x828>
ffffffffc0203c62:	14e00593          	li	a1,334
ffffffffc0203c66:	00003517          	auipc	a0,0x3
ffffffffc0203c6a:	19250513          	addi	a0,a0,402 # ffffffffc0206df8 <default_pmm_manager+0x7c0>
ffffffffc0203c6e:	821fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203c72:	00003697          	auipc	a3,0x3
ffffffffc0203c76:	32e68693          	addi	a3,a3,814 # ffffffffc0206fa0 <default_pmm_manager+0x968>
ffffffffc0203c7a:	00002617          	auipc	a2,0x2
ffffffffc0203c7e:	60e60613          	addi	a2,a2,1550 # ffffffffc0206288 <commands+0x828>
ffffffffc0203c82:	14f00593          	li	a1,335
ffffffffc0203c86:	00003517          	auipc	a0,0x3
ffffffffc0203c8a:	17250513          	addi	a0,a0,370 # ffffffffc0206df8 <default_pmm_manager+0x7c0>
ffffffffc0203c8e:	801fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203c92:	00003697          	auipc	a3,0x3
ffffffffc0203c96:	23e68693          	addi	a3,a3,574 # ffffffffc0206ed0 <default_pmm_manager+0x898>
ffffffffc0203c9a:	00002617          	auipc	a2,0x2
ffffffffc0203c9e:	5ee60613          	addi	a2,a2,1518 # ffffffffc0206288 <commands+0x828>
ffffffffc0203ca2:	13b00593          	li	a1,315
ffffffffc0203ca6:	00003517          	auipc	a0,0x3
ffffffffc0203caa:	15250513          	addi	a0,a0,338 # ffffffffc0206df8 <default_pmm_manager+0x7c0>
ffffffffc0203cae:	fe0fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma2 != NULL);
ffffffffc0203cb2:	00003697          	auipc	a3,0x3
ffffffffc0203cb6:	27e68693          	addi	a3,a3,638 # ffffffffc0206f30 <default_pmm_manager+0x8f8>
ffffffffc0203cba:	00002617          	auipc	a2,0x2
ffffffffc0203cbe:	5ce60613          	addi	a2,a2,1486 # ffffffffc0206288 <commands+0x828>
ffffffffc0203cc2:	14600593          	li	a1,326
ffffffffc0203cc6:	00003517          	auipc	a0,0x3
ffffffffc0203cca:	13250513          	addi	a0,a0,306 # ffffffffc0206df8 <default_pmm_manager+0x7c0>
ffffffffc0203cce:	fc0fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma1 != NULL);
ffffffffc0203cd2:	00003697          	auipc	a3,0x3
ffffffffc0203cd6:	24e68693          	addi	a3,a3,590 # ffffffffc0206f20 <default_pmm_manager+0x8e8>
ffffffffc0203cda:	00002617          	auipc	a2,0x2
ffffffffc0203cde:	5ae60613          	addi	a2,a2,1454 # ffffffffc0206288 <commands+0x828>
ffffffffc0203ce2:	14400593          	li	a1,324
ffffffffc0203ce6:	00003517          	auipc	a0,0x3
ffffffffc0203cea:	11250513          	addi	a0,a0,274 # ffffffffc0206df8 <default_pmm_manager+0x7c0>
ffffffffc0203cee:	fa0fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma3 == NULL);
ffffffffc0203cf2:	00003697          	auipc	a3,0x3
ffffffffc0203cf6:	24e68693          	addi	a3,a3,590 # ffffffffc0206f40 <default_pmm_manager+0x908>
ffffffffc0203cfa:	00002617          	auipc	a2,0x2
ffffffffc0203cfe:	58e60613          	addi	a2,a2,1422 # ffffffffc0206288 <commands+0x828>
ffffffffc0203d02:	14800593          	li	a1,328
ffffffffc0203d06:	00003517          	auipc	a0,0x3
ffffffffc0203d0a:	0f250513          	addi	a0,a0,242 # ffffffffc0206df8 <default_pmm_manager+0x7c0>
ffffffffc0203d0e:	f80fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma5 == NULL);
ffffffffc0203d12:	00003697          	auipc	a3,0x3
ffffffffc0203d16:	24e68693          	addi	a3,a3,590 # ffffffffc0206f60 <default_pmm_manager+0x928>
ffffffffc0203d1a:	00002617          	auipc	a2,0x2
ffffffffc0203d1e:	56e60613          	addi	a2,a2,1390 # ffffffffc0206288 <commands+0x828>
ffffffffc0203d22:	14c00593          	li	a1,332
ffffffffc0203d26:	00003517          	auipc	a0,0x3
ffffffffc0203d2a:	0d250513          	addi	a0,a0,210 # ffffffffc0206df8 <default_pmm_manager+0x7c0>
ffffffffc0203d2e:	f60fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma4 == NULL);
ffffffffc0203d32:	00003697          	auipc	a3,0x3
ffffffffc0203d36:	21e68693          	addi	a3,a3,542 # ffffffffc0206f50 <default_pmm_manager+0x918>
ffffffffc0203d3a:	00002617          	auipc	a2,0x2
ffffffffc0203d3e:	54e60613          	addi	a2,a2,1358 # ffffffffc0206288 <commands+0x828>
ffffffffc0203d42:	14a00593          	li	a1,330
ffffffffc0203d46:	00003517          	auipc	a0,0x3
ffffffffc0203d4a:	0b250513          	addi	a0,a0,178 # ffffffffc0206df8 <default_pmm_manager+0x7c0>
ffffffffc0203d4e:	f40fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(mm != NULL);
ffffffffc0203d52:	00003697          	auipc	a3,0x3
ffffffffc0203d56:	12e68693          	addi	a3,a3,302 # ffffffffc0206e80 <default_pmm_manager+0x848>
ffffffffc0203d5a:	00002617          	auipc	a2,0x2
ffffffffc0203d5e:	52e60613          	addi	a2,a2,1326 # ffffffffc0206288 <commands+0x828>
ffffffffc0203d62:	12400593          	li	a1,292
ffffffffc0203d66:	00003517          	auipc	a0,0x3
ffffffffc0203d6a:	09250513          	addi	a0,a0,146 # ffffffffc0206df8 <default_pmm_manager+0x7c0>
ffffffffc0203d6e:	f20fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203d72 <user_mem_check>:
}
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc0203d72:	7179                	addi	sp,sp,-48
ffffffffc0203d74:	f022                	sd	s0,32(sp)
ffffffffc0203d76:	f406                	sd	ra,40(sp)
ffffffffc0203d78:	ec26                	sd	s1,24(sp)
ffffffffc0203d7a:	e84a                	sd	s2,16(sp)
ffffffffc0203d7c:	e44e                	sd	s3,8(sp)
ffffffffc0203d7e:	e052                	sd	s4,0(sp)
ffffffffc0203d80:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc0203d82:	c135                	beqz	a0,ffffffffc0203de6 <user_mem_check+0x74>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc0203d84:	002007b7          	lui	a5,0x200
ffffffffc0203d88:	04f5e663          	bltu	a1,a5,ffffffffc0203dd4 <user_mem_check+0x62>
ffffffffc0203d8c:	00c584b3          	add	s1,a1,a2
ffffffffc0203d90:	0495f263          	bgeu	a1,s1,ffffffffc0203dd4 <user_mem_check+0x62>
ffffffffc0203d94:	4785                	li	a5,1
ffffffffc0203d96:	07fe                	slli	a5,a5,0x1f
ffffffffc0203d98:	0297ee63          	bltu	a5,s1,ffffffffc0203dd4 <user_mem_check+0x62>
ffffffffc0203d9c:	892a                	mv	s2,a0
ffffffffc0203d9e:	89b6                	mv	s3,a3
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203da0:	6a05                	lui	s4,0x1
ffffffffc0203da2:	a821                	j	ffffffffc0203dba <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203da4:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203da8:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203daa:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203dac:	c685                	beqz	a3,ffffffffc0203dd4 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203dae:	c399                	beqz	a5,ffffffffc0203db4 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203db0:	02e46263          	bltu	s0,a4,ffffffffc0203dd4 <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0203db4:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc0203db6:	04947663          	bgeu	s0,s1,ffffffffc0203e02 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc0203dba:	85a2                	mv	a1,s0
ffffffffc0203dbc:	854a                	mv	a0,s2
ffffffffc0203dbe:	96fff0ef          	jal	ra,ffffffffc020372c <find_vma>
ffffffffc0203dc2:	c909                	beqz	a0,ffffffffc0203dd4 <user_mem_check+0x62>
ffffffffc0203dc4:	6518                	ld	a4,8(a0)
ffffffffc0203dc6:	00e46763          	bltu	s0,a4,ffffffffc0203dd4 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203dca:	4d1c                	lw	a5,24(a0)
ffffffffc0203dcc:	fc099ce3          	bnez	s3,ffffffffc0203da4 <user_mem_check+0x32>
ffffffffc0203dd0:	8b85                	andi	a5,a5,1
ffffffffc0203dd2:	f3ed                	bnez	a5,ffffffffc0203db4 <user_mem_check+0x42>
            return 0;
ffffffffc0203dd4:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203dd6:	70a2                	ld	ra,40(sp)
ffffffffc0203dd8:	7402                	ld	s0,32(sp)
ffffffffc0203dda:	64e2                	ld	s1,24(sp)
ffffffffc0203ddc:	6942                	ld	s2,16(sp)
ffffffffc0203dde:	69a2                	ld	s3,8(sp)
ffffffffc0203de0:	6a02                	ld	s4,0(sp)
ffffffffc0203de2:	6145                	addi	sp,sp,48
ffffffffc0203de4:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203de6:	c02007b7          	lui	a5,0xc0200
ffffffffc0203dea:	4501                	li	a0,0
ffffffffc0203dec:	fef5e5e3          	bltu	a1,a5,ffffffffc0203dd6 <user_mem_check+0x64>
ffffffffc0203df0:	962e                	add	a2,a2,a1
ffffffffc0203df2:	fec5f2e3          	bgeu	a1,a2,ffffffffc0203dd6 <user_mem_check+0x64>
ffffffffc0203df6:	c8000537          	lui	a0,0xc8000
ffffffffc0203dfa:	0505                	addi	a0,a0,1
ffffffffc0203dfc:	00a63533          	sltu	a0,a2,a0
ffffffffc0203e00:	bfd9                	j	ffffffffc0203dd6 <user_mem_check+0x64>
        return 1;
ffffffffc0203e02:	4505                	li	a0,1
ffffffffc0203e04:	bfc9                	j	ffffffffc0203dd6 <user_mem_check+0x64>

ffffffffc0203e06 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0203e06:	8526                	mv	a0,s1
	jalr s0
ffffffffc0203e08:	9402                	jalr	s0

	jal do_exit
ffffffffc0203e0a:	6ca000ef          	jal	ra,ffffffffc02044d4 <do_exit>

ffffffffc0203e0e <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc0203e0e:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203e10:	10800513          	li	a0,264
{
ffffffffc0203e14:	e022                	sd	s0,0(sp)
ffffffffc0203e16:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203e18:	ec3fd0ef          	jal	ra,ffffffffc0201cda <kmalloc>
ffffffffc0203e1c:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc0203e1e:	cd21                	beqz	a0,ffffffffc0203e76 <alloc_proc+0x68>
        /*
         * below fields(add in LAB5) in proc_struct need to be initialized
         *       uint32_t wait_state;                        // waiting state
         *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
         */
        proc->state = PROC_UNINIT;        // 尚未进入就绪态
ffffffffc0203e20:	57fd                	li	a5,-1
ffffffffc0203e22:	1782                	slli	a5,a5,0x20
ffffffffc0203e24:	e11c                	sd	a5,0(a0)
        proc->runs = 0;                   // 运行次数计数器清零
        proc->kstack = 0;                 // 还未分配内核栈
        proc->need_resched = 0;           // 默认不请求调度
        proc->parent = NULL;              // 父进程待后续设置
        proc->mm = NULL;                  // 地址空间后续 copy/share
        memset(&proc->context, 0, sizeof(struct context)); // 确保首次 switch_to 有确定值
ffffffffc0203e26:	07000613          	li	a2,112
ffffffffc0203e2a:	4581                	li	a1,0
        proc->runs = 0;                   // 运行次数计数器清零
ffffffffc0203e2c:	00052423          	sw	zero,8(a0) # ffffffffc8000008 <end+0x7d55764>
        proc->kstack = 0;                 // 还未分配内核栈
ffffffffc0203e30:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;           // 默认不请求调度
ffffffffc0203e34:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;              // 父进程待后续设置
ffffffffc0203e38:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;                  // 地址空间后续 copy/share
ffffffffc0203e3c:	02053423          	sd	zero,40(a0)
        memset(&proc->context, 0, sizeof(struct context)); // 确保首次 switch_to 有确定值
ffffffffc0203e40:	03050513          	addi	a0,a0,48
ffffffffc0203e44:	189010ef          	jal	ra,ffffffffc02057cc <memset>
        proc->tf = NULL;                  // trapframe 等栈建立后 copy_thread 设置
        proc->pgdir = boot_pgdir_pa;      // 先使用内核页表基址
ffffffffc0203e48:	000a7797          	auipc	a5,0xa7
ffffffffc0203e4c:	a107b783          	ld	a5,-1520(a5) # ffffffffc02aa858 <boot_pgdir_pa>
        proc->tf = NULL;                  // trapframe 等栈建立后 copy_thread 设置
ffffffffc0203e50:	0a043023          	sd	zero,160(s0)
        proc->pgdir = boot_pgdir_pa;      // 先使用内核页表基址
ffffffffc0203e54:	f45c                	sd	a5,168(s0)
        proc->flags = 0;                  // 初始无标志
ffffffffc0203e56:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, sizeof(proc->name)); // 进程名清零，后续 set_proc_name
ffffffffc0203e5a:	4641                	li	a2,16
ffffffffc0203e5c:	4581                	li	a1,0
ffffffffc0203e5e:	0b440513          	addi	a0,s0,180
ffffffffc0203e62:	16b010ef          	jal	ra,ffffffffc02057cc <memset>

        // LAB5: 初始化新增字段
        proc->exit_code = 0;              // 退出码初始化为0
ffffffffc0203e66:	0e043423          	sd	zero,232(s0)
        proc->wait_state = 0;             // 等待状态初始化为0
        proc->cptr = proc->yptr = proc->optr = NULL; // 进程关系指针初始化为NULL
ffffffffc0203e6a:	0e043823          	sd	zero,240(s0)
ffffffffc0203e6e:	0e043c23          	sd	zero,248(s0)
ffffffffc0203e72:	10043023          	sd	zero,256(s0)
    }
    return proc;
}
ffffffffc0203e76:	60a2                	ld	ra,8(sp)
ffffffffc0203e78:	8522                	mv	a0,s0
ffffffffc0203e7a:	6402                	ld	s0,0(sp)
ffffffffc0203e7c:	0141                	addi	sp,sp,16
ffffffffc0203e7e:	8082                	ret

ffffffffc0203e80 <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc0203e80:	000a7797          	auipc	a5,0xa7
ffffffffc0203e84:	a087b783          	ld	a5,-1528(a5) # ffffffffc02aa888 <current>
ffffffffc0203e88:	73c8                	ld	a0,160(a5)
ffffffffc0203e8a:	8c4fd06f          	j	ffffffffc0200f4e <forkrets>

ffffffffc0203e8e <user_main>:
// user_main - kernel thread used to exec a user program
static int
user_main(void *arg)
{
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0203e8e:	000a7797          	auipc	a5,0xa7
ffffffffc0203e92:	9fa7b783          	ld	a5,-1542(a5) # ffffffffc02aa888 <current>
ffffffffc0203e96:	43cc                	lw	a1,4(a5)
{
ffffffffc0203e98:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0203e9a:	00003617          	auipc	a2,0x3
ffffffffc0203e9e:	1be60613          	addi	a2,a2,446 # ffffffffc0207058 <default_pmm_manager+0xa20>
ffffffffc0203ea2:	00003517          	auipc	a0,0x3
ffffffffc0203ea6:	1c650513          	addi	a0,a0,454 # ffffffffc0207068 <default_pmm_manager+0xa30>
{
ffffffffc0203eaa:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0203eac:	ae8fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0203eb0:	3fe07797          	auipc	a5,0x3fe07
ffffffffc0203eb4:	ac878793          	addi	a5,a5,-1336 # a978 <_binary_obj___user_forktest_out_size>
ffffffffc0203eb8:	e43e                	sd	a5,8(sp)
ffffffffc0203eba:	00003517          	auipc	a0,0x3
ffffffffc0203ebe:	19e50513          	addi	a0,a0,414 # ffffffffc0207058 <default_pmm_manager+0xa20>
ffffffffc0203ec2:	00046797          	auipc	a5,0x46
ffffffffc0203ec6:	8be78793          	addi	a5,a5,-1858 # ffffffffc0249780 <_binary_obj___user_forktest_out_start>
ffffffffc0203eca:	f03e                	sd	a5,32(sp)
ffffffffc0203ecc:	f42a                	sd	a0,40(sp)
    int64_t ret = 0, len = strlen(name);
ffffffffc0203ece:	e802                	sd	zero,16(sp)
ffffffffc0203ed0:	05b010ef          	jal	ra,ffffffffc020572a <strlen>
ffffffffc0203ed4:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0203ed6:	4511                	li	a0,4
ffffffffc0203ed8:	55a2                	lw	a1,40(sp)
ffffffffc0203eda:	4662                	lw	a2,24(sp)
ffffffffc0203edc:	5682                	lw	a3,32(sp)
ffffffffc0203ede:	4722                	lw	a4,8(sp)
ffffffffc0203ee0:	48a9                	li	a7,10
ffffffffc0203ee2:	9002                	ebreak
ffffffffc0203ee4:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0203ee6:	65c2                	ld	a1,16(sp)
ffffffffc0203ee8:	00003517          	auipc	a0,0x3
ffffffffc0203eec:	1a850513          	addi	a0,a0,424 # ffffffffc0207090 <default_pmm_manager+0xa58>
ffffffffc0203ef0:	aa4fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0203ef4:	00003617          	auipc	a2,0x3
ffffffffc0203ef8:	1ac60613          	addi	a2,a2,428 # ffffffffc02070a0 <default_pmm_manager+0xa68>
ffffffffc0203efc:	3cc00593          	li	a1,972
ffffffffc0203f00:	00003517          	auipc	a0,0x3
ffffffffc0203f04:	1c050513          	addi	a0,a0,448 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc0203f08:	d86fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203f0c <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0203f0c:	6d14                	ld	a3,24(a0)
{
ffffffffc0203f0e:	1141                	addi	sp,sp,-16
ffffffffc0203f10:	e406                	sd	ra,8(sp)
ffffffffc0203f12:	c02007b7          	lui	a5,0xc0200
ffffffffc0203f16:	02f6ee63          	bltu	a3,a5,ffffffffc0203f52 <put_pgdir+0x46>
ffffffffc0203f1a:	000a7517          	auipc	a0,0xa7
ffffffffc0203f1e:	96653503          	ld	a0,-1690(a0) # ffffffffc02aa880 <va_pa_offset>
ffffffffc0203f22:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage)
ffffffffc0203f24:	82b1                	srli	a3,a3,0xc
ffffffffc0203f26:	000a7797          	auipc	a5,0xa7
ffffffffc0203f2a:	9427b783          	ld	a5,-1726(a5) # ffffffffc02aa868 <npage>
ffffffffc0203f2e:	02f6fe63          	bgeu	a3,a5,ffffffffc0203f6a <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203f32:	00004517          	auipc	a0,0x4
ffffffffc0203f36:	bb653503          	ld	a0,-1098(a0) # ffffffffc0207ae8 <nbase>
}
ffffffffc0203f3a:	60a2                	ld	ra,8(sp)
ffffffffc0203f3c:	8e89                	sub	a3,a3,a0
ffffffffc0203f3e:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0203f40:	000a7517          	auipc	a0,0xa7
ffffffffc0203f44:	93053503          	ld	a0,-1744(a0) # ffffffffc02aa870 <pages>
ffffffffc0203f48:	4585                	li	a1,1
ffffffffc0203f4a:	9536                	add	a0,a0,a3
}
ffffffffc0203f4c:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0203f4e:	fa9fd06f          	j	ffffffffc0201ef6 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0203f52:	00002617          	auipc	a2,0x2
ffffffffc0203f56:	7c660613          	addi	a2,a2,1990 # ffffffffc0206718 <default_pmm_manager+0xe0>
ffffffffc0203f5a:	07700593          	li	a1,119
ffffffffc0203f5e:	00002517          	auipc	a0,0x2
ffffffffc0203f62:	73a50513          	addi	a0,a0,1850 # ffffffffc0206698 <default_pmm_manager+0x60>
ffffffffc0203f66:	d28fc0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203f6a:	00002617          	auipc	a2,0x2
ffffffffc0203f6e:	7d660613          	addi	a2,a2,2006 # ffffffffc0206740 <default_pmm_manager+0x108>
ffffffffc0203f72:	06900593          	li	a1,105
ffffffffc0203f76:	00002517          	auipc	a0,0x2
ffffffffc0203f7a:	72250513          	addi	a0,a0,1826 # ffffffffc0206698 <default_pmm_manager+0x60>
ffffffffc0203f7e:	d10fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203f82 <setup_pgdir>:
{
ffffffffc0203f82:	7179                	addi	sp,sp,-48
ffffffffc0203f84:	e84a                	sd	s2,16(sp)
ffffffffc0203f86:	892a                	mv	s2,a0
    if ((page = alloc_page()) == NULL)
ffffffffc0203f88:	4505                	li	a0,1
{
ffffffffc0203f8a:	f406                	sd	ra,40(sp)
ffffffffc0203f8c:	f022                	sd	s0,32(sp)
ffffffffc0203f8e:	ec26                	sd	s1,24(sp)
ffffffffc0203f90:	e44e                	sd	s3,8(sp)
    if ((page = alloc_page()) == NULL)
ffffffffc0203f92:	f27fd0ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
ffffffffc0203f96:	c93d                	beqz	a0,ffffffffc020400c <setup_pgdir+0x8a>
    return page - pages + nbase;
ffffffffc0203f98:	000a7697          	auipc	a3,0xa7
ffffffffc0203f9c:	8d86b683          	ld	a3,-1832(a3) # ffffffffc02aa870 <pages>
ffffffffc0203fa0:	40d506b3          	sub	a3,a0,a3
ffffffffc0203fa4:	8699                	srai	a3,a3,0x6
ffffffffc0203fa6:	00004417          	auipc	s0,0x4
ffffffffc0203faa:	b4243403          	ld	s0,-1214(s0) # ffffffffc0207ae8 <nbase>
ffffffffc0203fae:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0203fb0:	00c69793          	slli	a5,a3,0xc
ffffffffc0203fb4:	83b1                	srli	a5,a5,0xc
ffffffffc0203fb6:	000a7717          	auipc	a4,0xa7
ffffffffc0203fba:	8b273703          	ld	a4,-1870(a4) # ffffffffc02aa868 <npage>
ffffffffc0203fbe:	84aa                	mv	s1,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203fc0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203fc2:	06e7f363          	bgeu	a5,a4,ffffffffc0204028 <setup_pgdir+0xa6>
    if (boot_pgdir_va == NULL) {
ffffffffc0203fc6:	000a7997          	auipc	s3,0xa7
ffffffffc0203fca:	89a98993          	addi	s3,s3,-1894 # ffffffffc02aa860 <boot_pgdir_va>
ffffffffc0203fce:	0009b583          	ld	a1,0(s3)
ffffffffc0203fd2:	000a7417          	auipc	s0,0xa7
ffffffffc0203fd6:	8ae43403          	ld	s0,-1874(s0) # ffffffffc02aa880 <va_pa_offset>
ffffffffc0203fda:	9436                	add	s0,s0,a3
ffffffffc0203fdc:	c995                	beqz	a1,ffffffffc0204010 <setup_pgdir+0x8e>
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0203fde:	6605                	lui	a2,0x1
ffffffffc0203fe0:	8522                	mv	a0,s0
ffffffffc0203fe2:	7fc010ef          	jal	ra,ffffffffc02057de <memcpy>
    cprintf("[DEBUG] setup_pgdir: new pgdir=%p, boot_pgdir_va=%p\n", 
ffffffffc0203fe6:	0009b603          	ld	a2,0(s3)
ffffffffc0203fea:	85a2                	mv	a1,s0
ffffffffc0203fec:	00003517          	auipc	a0,0x3
ffffffffc0203ff0:	11c50513          	addi	a0,a0,284 # ffffffffc0207108 <default_pmm_manager+0xad0>
ffffffffc0203ff4:	9a0fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
    return 0;
ffffffffc0203ff8:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc0203ffa:	00893c23          	sd	s0,24(s2)
}
ffffffffc0203ffe:	70a2                	ld	ra,40(sp)
ffffffffc0204000:	7402                	ld	s0,32(sp)
ffffffffc0204002:	64e2                	ld	s1,24(sp)
ffffffffc0204004:	6942                	ld	s2,16(sp)
ffffffffc0204006:	69a2                	ld	s3,8(sp)
ffffffffc0204008:	6145                	addi	sp,sp,48
ffffffffc020400a:	8082                	ret
        return -E_NO_MEM;
ffffffffc020400c:	5571                	li	a0,-4
ffffffffc020400e:	bfc5                	j	ffffffffc0203ffe <setup_pgdir+0x7c>
        cprintf("[ERROR] setup_pgdir: boot_pgdir_va is NULL\n");
ffffffffc0204010:	00003517          	auipc	a0,0x3
ffffffffc0204014:	0c850513          	addi	a0,a0,200 # ffffffffc02070d8 <default_pmm_manager+0xaa0>
ffffffffc0204018:	97cfc0ef          	jal	ra,ffffffffc0200194 <cprintf>
        free_page(page);
ffffffffc020401c:	8526                	mv	a0,s1
ffffffffc020401e:	4585                	li	a1,1
ffffffffc0204020:	ed7fd0ef          	jal	ra,ffffffffc0201ef6 <free_pages>
        return -E_INVAL;
ffffffffc0204024:	5575                	li	a0,-3
ffffffffc0204026:	bfe1                	j	ffffffffc0203ffe <setup_pgdir+0x7c>
ffffffffc0204028:	00002617          	auipc	a2,0x2
ffffffffc020402c:	64860613          	addi	a2,a2,1608 # ffffffffc0206670 <default_pmm_manager+0x38>
ffffffffc0204030:	07100593          	li	a1,113
ffffffffc0204034:	00002517          	auipc	a0,0x2
ffffffffc0204038:	66450513          	addi	a0,a0,1636 # ffffffffc0206698 <default_pmm_manager+0x60>
ffffffffc020403c:	c52fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204040 <proc_run>:
{
ffffffffc0204040:	7179                	addi	sp,sp,-48
ffffffffc0204042:	e84a                	sd	s2,16(sp)
    if (proc != current)
ffffffffc0204044:	000a7917          	auipc	s2,0xa7
ffffffffc0204048:	84490913          	addi	s2,s2,-1980 # ffffffffc02aa888 <current>
{
ffffffffc020404c:	ec26                	sd	s1,24(sp)
    if (proc != current)
ffffffffc020404e:	00093483          	ld	s1,0(s2)
{
ffffffffc0204052:	f406                	sd	ra,40(sp)
ffffffffc0204054:	f022                	sd	s0,32(sp)
ffffffffc0204056:	e44e                	sd	s3,8(sp)
    if (proc != current)
ffffffffc0204058:	04a48063          	beq	s1,a0,ffffffffc0204098 <proc_run+0x58>
ffffffffc020405c:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020405e:	100027f3          	csrr	a5,sstatus
ffffffffc0204062:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204064:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204066:	eba1                	bnez	a5,ffffffffc02040b6 <proc_run+0x76>
            cprintf("[DEBUG] proc_run: proc->pgdir=%p, calling lsatp\n", proc->pgdir);
ffffffffc0204068:	744c                	ld	a1,168(s0)
ffffffffc020406a:	00003517          	auipc	a0,0x3
ffffffffc020406e:	0d650513          	addi	a0,a0,214 # ffffffffc0207140 <default_pmm_manager+0xb08>
            current = proc;
ffffffffc0204072:	00893023          	sd	s0,0(s2)
            cprintf("[DEBUG] proc_run: proc->pgdir=%p, calling lsatp\n", proc->pgdir);
ffffffffc0204076:	91efc0ef          	jal	ra,ffffffffc0200194 <cprintf>
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned long pgdir)
{
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc020407a:	745c                	ld	a5,168(s0)
ffffffffc020407c:	577d                	li	a4,-1
ffffffffc020407e:	177e                	slli	a4,a4,0x3f
ffffffffc0204080:	83b1                	srli	a5,a5,0xc
ffffffffc0204082:	8fd9                	or	a5,a5,a4
ffffffffc0204084:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(proc->context));
ffffffffc0204088:	03040593          	addi	a1,s0,48
ffffffffc020408c:	03048513          	addi	a0,s1,48
ffffffffc0204090:	040010ef          	jal	ra,ffffffffc02050d0 <switch_to>
    if (flag)
ffffffffc0204094:	00099963          	bnez	s3,ffffffffc02040a6 <proc_run+0x66>
}
ffffffffc0204098:	70a2                	ld	ra,40(sp)
ffffffffc020409a:	7402                	ld	s0,32(sp)
ffffffffc020409c:	64e2                	ld	s1,24(sp)
ffffffffc020409e:	6942                	ld	s2,16(sp)
ffffffffc02040a0:	69a2                	ld	s3,8(sp)
ffffffffc02040a2:	6145                	addi	sp,sp,48
ffffffffc02040a4:	8082                	ret
ffffffffc02040a6:	7402                	ld	s0,32(sp)
ffffffffc02040a8:	70a2                	ld	ra,40(sp)
ffffffffc02040aa:	64e2                	ld	s1,24(sp)
ffffffffc02040ac:	6942                	ld	s2,16(sp)
ffffffffc02040ae:	69a2                	ld	s3,8(sp)
ffffffffc02040b0:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc02040b2:	8fdfc06f          	j	ffffffffc02009ae <intr_enable>
        intr_disable();
ffffffffc02040b6:	8fffc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc02040ba:	4985                	li	s3,1
            struct proc_struct *prev = current;
ffffffffc02040bc:	00093483          	ld	s1,0(s2)
ffffffffc02040c0:	b765                	j	ffffffffc0204068 <proc_run+0x28>

ffffffffc02040c2 <do_fork>:
{
ffffffffc02040c2:	7159                	addi	sp,sp,-112
ffffffffc02040c4:	eca6                	sd	s1,88(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc02040c6:	000a6497          	auipc	s1,0xa6
ffffffffc02040ca:	7da48493          	addi	s1,s1,2010 # ffffffffc02aa8a0 <nr_process>
ffffffffc02040ce:	4098                	lw	a4,0(s1)
{
ffffffffc02040d0:	f486                	sd	ra,104(sp)
ffffffffc02040d2:	f0a2                	sd	s0,96(sp)
ffffffffc02040d4:	e8ca                	sd	s2,80(sp)
ffffffffc02040d6:	e4ce                	sd	s3,72(sp)
ffffffffc02040d8:	e0d2                	sd	s4,64(sp)
ffffffffc02040da:	fc56                	sd	s5,56(sp)
ffffffffc02040dc:	f85a                	sd	s6,48(sp)
ffffffffc02040de:	f45e                	sd	s7,40(sp)
ffffffffc02040e0:	f062                	sd	s8,32(sp)
ffffffffc02040e2:	ec66                	sd	s9,24(sp)
ffffffffc02040e4:	e86a                	sd	s10,16(sp)
ffffffffc02040e6:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc02040e8:	6785                	lui	a5,0x1
ffffffffc02040ea:	2ef75363          	bge	a4,a5,ffffffffc02043d0 <do_fork+0x30e>
ffffffffc02040ee:	8a2a                	mv	s4,a0
ffffffffc02040f0:	892e                	mv	s2,a1
ffffffffc02040f2:	89b2                	mv	s3,a2
    if ((proc = alloc_proc()) == NULL)
ffffffffc02040f4:	d1bff0ef          	jal	ra,ffffffffc0203e0e <alloc_proc>
ffffffffc02040f8:	842a                	mv	s0,a0
ffffffffc02040fa:	2e050263          	beqz	a0,ffffffffc02043de <do_fork+0x31c>
    proc->parent = current;
ffffffffc02040fe:	000a6a97          	auipc	s5,0xa6
ffffffffc0204102:	78aa8a93          	addi	s5,s5,1930 # ffffffffc02aa888 <current>
ffffffffc0204106:	000ab783          	ld	a5,0(s5)
    assert(current->wait_state == 0);
ffffffffc020410a:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8ad4>
    proc->parent = current;
ffffffffc020410e:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc0204110:	2c071e63          	bnez	a4,ffffffffc02043ec <do_fork+0x32a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204114:	4509                	li	a0,2
ffffffffc0204116:	da3fd0ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
    if (page != NULL)
ffffffffc020411a:	2a050963          	beqz	a0,ffffffffc02043cc <do_fork+0x30a>
    return page - pages + nbase;
ffffffffc020411e:	000a6b97          	auipc	s7,0xa6
ffffffffc0204122:	752b8b93          	addi	s7,s7,1874 # ffffffffc02aa870 <pages>
ffffffffc0204126:	000bb683          	ld	a3,0(s7)
ffffffffc020412a:	00004d17          	auipc	s10,0x4
ffffffffc020412e:	9bed0d13          	addi	s10,s10,-1602 # ffffffffc0207ae8 <nbase>
ffffffffc0204132:	000d3703          	ld	a4,0(s10)
ffffffffc0204136:	40d506b3          	sub	a3,a0,a3
ffffffffc020413a:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020413c:	000a6d97          	auipc	s11,0xa6
ffffffffc0204140:	72cd8d93          	addi	s11,s11,1836 # ffffffffc02aa868 <npage>
    return page - pages + nbase;
ffffffffc0204144:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0204146:	000db703          	ld	a4,0(s11)
ffffffffc020414a:	00c69793          	slli	a5,a3,0xc
ffffffffc020414e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204150:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204152:	2ae7fd63          	bgeu	a5,a4,ffffffffc020440c <do_fork+0x34a>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204156:	000ab703          	ld	a4,0(s5)
ffffffffc020415a:	000a6b17          	auipc	s6,0xa6
ffffffffc020415e:	726b0b13          	addi	s6,s6,1830 # ffffffffc02aa880 <va_pa_offset>
ffffffffc0204162:	000b3783          	ld	a5,0(s6)
ffffffffc0204166:	02873a83          	ld	s5,40(a4)
ffffffffc020416a:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc020416c:	e814                	sd	a3,16(s0)
    if (oldmm == NULL)
ffffffffc020416e:	040a8763          	beqz	s5,ffffffffc02041bc <do_fork+0xfa>
    if (clone_flags & CLONE_VM)
ffffffffc0204172:	100a7a13          	andi	s4,s4,256
ffffffffc0204176:	1a0a0863          	beqz	s4,ffffffffc0204326 <do_fork+0x264>
}

static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
ffffffffc020417a:	030aa783          	lw	a5,48(s5)
    cprintf("[DEBUG] copy_mm: mm->pgdir=%p (before PADDR)\n", mm->pgdir);
ffffffffc020417e:	018ab583          	ld	a1,24(s5)
ffffffffc0204182:	00003517          	auipc	a0,0x3
ffffffffc0204186:	03e50513          	addi	a0,a0,62 # ffffffffc02071c0 <default_pmm_manager+0xb88>
ffffffffc020418a:	2785                	addiw	a5,a5,1
ffffffffc020418c:	02faa823          	sw	a5,48(s5)
    proc->mm = mm;
ffffffffc0204190:	03543423          	sd	s5,40(s0)
    cprintf("[DEBUG] copy_mm: mm->pgdir=%p (before PADDR)\n", mm->pgdir);
ffffffffc0204194:	800fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204198:	018ab683          	ld	a3,24(s5)
ffffffffc020419c:	c02007b7          	lui	a5,0xc0200
ffffffffc02041a0:	2cf6e663          	bltu	a3,a5,ffffffffc020446c <do_fork+0x3aa>
ffffffffc02041a4:	000b3583          	ld	a1,0(s6)
    cprintf("[DEBUG] copy_mm: proc->pgdir=%p (after PADDR)\n", proc->pgdir);
ffffffffc02041a8:	00003517          	auipc	a0,0x3
ffffffffc02041ac:	04850513          	addi	a0,a0,72 # ffffffffc02071f0 <default_pmm_manager+0xbb8>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc02041b0:	40b685b3          	sub	a1,a3,a1
ffffffffc02041b4:	f44c                	sd	a1,168(s0)
    cprintf("[DEBUG] copy_mm: proc->pgdir=%p (after PADDR)\n", proc->pgdir);
ffffffffc02041b6:	fdffb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02041ba:	6814                	ld	a3,16(s0)
ffffffffc02041bc:	6789                	lui	a5,0x2
ffffffffc02041be:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7ce0>
ffffffffc02041c2:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc02041c4:	864e                	mv	a2,s3
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02041c6:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc02041c8:	87b6                	mv	a5,a3
ffffffffc02041ca:	12098893          	addi	a7,s3,288
ffffffffc02041ce:	00063803          	ld	a6,0(a2)
ffffffffc02041d2:	6608                	ld	a0,8(a2)
ffffffffc02041d4:	6a0c                	ld	a1,16(a2)
ffffffffc02041d6:	6e18                	ld	a4,24(a2)
ffffffffc02041d8:	0107b023          	sd	a6,0(a5)
ffffffffc02041dc:	e788                	sd	a0,8(a5)
ffffffffc02041de:	eb8c                	sd	a1,16(a5)
ffffffffc02041e0:	ef98                	sd	a4,24(a5)
ffffffffc02041e2:	02060613          	addi	a2,a2,32
ffffffffc02041e6:	02078793          	addi	a5,a5,32
ffffffffc02041ea:	ff1612e3          	bne	a2,a7,ffffffffc02041ce <do_fork+0x10c>
    proc->tf->gpr.a0 = 0;
ffffffffc02041ee:	0406b823          	sd	zero,80(a3)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02041f2:	18090763          	beqz	s2,ffffffffc0204380 <do_fork+0x2be>
    if (++last_pid >= MAX_PID)
ffffffffc02041f6:	000a2817          	auipc	a6,0xa2
ffffffffc02041fa:	1fa80813          	addi	a6,a6,506 # ffffffffc02a63f0 <last_pid.1>
ffffffffc02041fe:	00082783          	lw	a5,0(a6)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204202:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204206:	00000717          	auipc	a4,0x0
ffffffffc020420a:	c7a70713          	addi	a4,a4,-902 # ffffffffc0203e80 <forkret>
    if (++last_pid >= MAX_PID)
ffffffffc020420e:	0017851b          	addiw	a0,a5,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204212:	f818                	sd	a4,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204214:	fc14                	sd	a3,56(s0)
    if (++last_pid >= MAX_PID)
ffffffffc0204216:	00a82023          	sw	a0,0(a6)
ffffffffc020421a:	6789                	lui	a5,0x2
ffffffffc020421c:	08f55e63          	bge	a0,a5,ffffffffc02042b8 <do_fork+0x1f6>
    if (last_pid >= next_safe)
ffffffffc0204220:	000a2317          	auipc	t1,0xa2
ffffffffc0204224:	1d430313          	addi	t1,t1,468 # ffffffffc02a63f4 <next_safe.0>
ffffffffc0204228:	00032783          	lw	a5,0(t1)
ffffffffc020422c:	000a6917          	auipc	s2,0xa6
ffffffffc0204230:	5e490913          	addi	s2,s2,1508 # ffffffffc02aa810 <proc_list>
ffffffffc0204234:	08f55a63          	bge	a0,a5,ffffffffc02042c8 <do_fork+0x206>
    proc->pid = get_pid();
ffffffffc0204238:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020423a:	45a9                	li	a1,10
ffffffffc020423c:	2501                	sext.w	a0,a0
ffffffffc020423e:	0e8010ef          	jal	ra,ffffffffc0205326 <hash32>
ffffffffc0204242:	02051793          	slli	a5,a0,0x20
ffffffffc0204246:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020424a:	000a2797          	auipc	a5,0xa2
ffffffffc020424e:	5c678793          	addi	a5,a5,1478 # ffffffffc02a6810 <hash_list>
ffffffffc0204252:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204254:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204256:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204258:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc020425c:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc020425e:	00893603          	ld	a2,8(s2)
    prev->next = next->prev = elm;
ffffffffc0204262:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204264:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0204266:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc020426a:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc020426c:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc020426e:	e21c                	sd	a5,0(a2)
ffffffffc0204270:	00f93423          	sd	a5,8(s2)
    elm->next = next;
ffffffffc0204274:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc0204276:	0d243423          	sd	s2,200(s0)
    proc->yptr = NULL;
ffffffffc020427a:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc020427e:	10e43023          	sd	a4,256(s0)
ffffffffc0204282:	c311                	beqz	a4,ffffffffc0204286 <do_fork+0x1c4>
        proc->optr->yptr = proc;
ffffffffc0204284:	ff60                	sd	s0,248(a4)
    nr_process++;
ffffffffc0204286:	409c                	lw	a5,0(s1)
    proc->parent->cptr = proc;
ffffffffc0204288:	fae0                	sd	s0,240(a3)
    wakeup_proc(proc);
ffffffffc020428a:	8522                	mv	a0,s0
    nr_process++;
ffffffffc020428c:	2785                	addiw	a5,a5,1
ffffffffc020428e:	c09c                	sw	a5,0(s1)
    wakeup_proc(proc);
ffffffffc0204290:	6ab000ef          	jal	ra,ffffffffc020513a <wakeup_proc>
    ret = proc->pid;
ffffffffc0204294:	00442c03          	lw	s8,4(s0)
}
ffffffffc0204298:	70a6                	ld	ra,104(sp)
ffffffffc020429a:	7406                	ld	s0,96(sp)
ffffffffc020429c:	64e6                	ld	s1,88(sp)
ffffffffc020429e:	6946                	ld	s2,80(sp)
ffffffffc02042a0:	69a6                	ld	s3,72(sp)
ffffffffc02042a2:	6a06                	ld	s4,64(sp)
ffffffffc02042a4:	7ae2                	ld	s5,56(sp)
ffffffffc02042a6:	7b42                	ld	s6,48(sp)
ffffffffc02042a8:	7ba2                	ld	s7,40(sp)
ffffffffc02042aa:	6ce2                	ld	s9,24(sp)
ffffffffc02042ac:	6d42                	ld	s10,16(sp)
ffffffffc02042ae:	6da2                	ld	s11,8(sp)
ffffffffc02042b0:	8562                	mv	a0,s8
ffffffffc02042b2:	7c02                	ld	s8,32(sp)
ffffffffc02042b4:	6165                	addi	sp,sp,112
ffffffffc02042b6:	8082                	ret
        last_pid = 1;
ffffffffc02042b8:	4785                	li	a5,1
ffffffffc02042ba:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc02042be:	4505                	li	a0,1
ffffffffc02042c0:	000a2317          	auipc	t1,0xa2
ffffffffc02042c4:	13430313          	addi	t1,t1,308 # ffffffffc02a63f4 <next_safe.0>
    return listelm->next;
ffffffffc02042c8:	000a6917          	auipc	s2,0xa6
ffffffffc02042cc:	54890913          	addi	s2,s2,1352 # ffffffffc02aa810 <proc_list>
ffffffffc02042d0:	00893e03          	ld	t3,8(s2)
        next_safe = MAX_PID;
ffffffffc02042d4:	6789                	lui	a5,0x2
ffffffffc02042d6:	00f32023          	sw	a5,0(t1)
ffffffffc02042da:	86aa                	mv	a3,a0
ffffffffc02042dc:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc02042de:	6e89                	lui	t4,0x2
ffffffffc02042e0:	0f2e0a63          	beq	t3,s2,ffffffffc02043d4 <do_fork+0x312>
ffffffffc02042e4:	88ae                	mv	a7,a1
ffffffffc02042e6:	87f2                	mv	a5,t3
ffffffffc02042e8:	6609                	lui	a2,0x2
ffffffffc02042ea:	a811                	j	ffffffffc02042fe <do_fork+0x23c>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc02042ec:	00e6d663          	bge	a3,a4,ffffffffc02042f8 <do_fork+0x236>
ffffffffc02042f0:	00c75463          	bge	a4,a2,ffffffffc02042f8 <do_fork+0x236>
ffffffffc02042f4:	863a                	mv	a2,a4
ffffffffc02042f6:	4885                	li	a7,1
ffffffffc02042f8:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02042fa:	01278d63          	beq	a5,s2,ffffffffc0204314 <do_fork+0x252>
            if (proc->pid == last_pid)
ffffffffc02042fe:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c84>
ffffffffc0204302:	fed715e3          	bne	a4,a3,ffffffffc02042ec <do_fork+0x22a>
                if (++last_pid >= next_safe)
ffffffffc0204306:	2685                	addiw	a3,a3,1
ffffffffc0204308:	0ac6dd63          	bge	a3,a2,ffffffffc02043c2 <do_fork+0x300>
ffffffffc020430c:	679c                	ld	a5,8(a5)
ffffffffc020430e:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc0204310:	ff2797e3          	bne	a5,s2,ffffffffc02042fe <do_fork+0x23c>
ffffffffc0204314:	c581                	beqz	a1,ffffffffc020431c <do_fork+0x25a>
ffffffffc0204316:	00d82023          	sw	a3,0(a6)
ffffffffc020431a:	8536                	mv	a0,a3
ffffffffc020431c:	f0088ee3          	beqz	a7,ffffffffc0204238 <do_fork+0x176>
ffffffffc0204320:	00c32023          	sw	a2,0(t1)
ffffffffc0204324:	bf11                	j	ffffffffc0204238 <do_fork+0x176>
    if ((mm = mm_create()) == NULL)
ffffffffc0204326:	bd6ff0ef          	jal	ra,ffffffffc02036fc <mm_create>
ffffffffc020432a:	8caa                	mv	s9,a0
ffffffffc020432c:	cd55                	beqz	a0,ffffffffc02043e8 <do_fork+0x326>
    if (setup_pgdir(mm) != 0)
ffffffffc020432e:	c55ff0ef          	jal	ra,ffffffffc0203f82 <setup_pgdir>
ffffffffc0204332:	e929                	bnez	a0,ffffffffc0204384 <do_fork+0x2c2>
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
ffffffffc0204334:	038a8a13          	addi	s4,s5,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204338:	4785                	li	a5,1
ffffffffc020433a:	40fa37af          	amoor.d	a5,a5,(s4)
}

static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))
ffffffffc020433e:	8b85                	andi	a5,a5,1
ffffffffc0204340:	4c05                	li	s8,1
ffffffffc0204342:	c799                	beqz	a5,ffffffffc0204350 <do_fork+0x28e>
    {
        schedule();
ffffffffc0204344:	677000ef          	jal	ra,ffffffffc02051ba <schedule>
ffffffffc0204348:	418a37af          	amoor.d	a5,s8,(s4)
    while (!try_lock(lock))
ffffffffc020434c:	8b85                	andi	a5,a5,1
ffffffffc020434e:	fbfd                	bnez	a5,ffffffffc0204344 <do_fork+0x282>
        ret = dup_mmap(mm, oldmm);
ffffffffc0204350:	85d6                	mv	a1,s5
ffffffffc0204352:	8566                	mv	a0,s9
ffffffffc0204354:	deaff0ef          	jal	ra,ffffffffc020393e <dup_mmap>
ffffffffc0204358:	8c2a                	mv	s8,a0
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020435a:	57f9                	li	a5,-2
ffffffffc020435c:	60fa37af          	amoand.d	a5,a5,(s4)
ffffffffc0204360:	8b85                	andi	a5,a5,1
}

static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))
ffffffffc0204362:	0e078963          	beqz	a5,ffffffffc0204454 <do_fork+0x392>
good_mm:
ffffffffc0204366:	8ae6                	mv	s5,s9
    if (ret != 0)
ffffffffc0204368:	e00509e3          	beqz	a0,ffffffffc020417a <do_fork+0xb8>
    exit_mmap(mm);
ffffffffc020436c:	8566                	mv	a0,s9
ffffffffc020436e:	e6aff0ef          	jal	ra,ffffffffc02039d8 <exit_mmap>
    put_pgdir(mm);
ffffffffc0204372:	8566                	mv	a0,s9
ffffffffc0204374:	b99ff0ef          	jal	ra,ffffffffc0203f0c <put_pgdir>
    mm_destroy(mm);
ffffffffc0204378:	8566                	mv	a0,s9
ffffffffc020437a:	cc2ff0ef          	jal	ra,ffffffffc020383c <mm_destroy>
ffffffffc020437e:	a039                	j	ffffffffc020438c <do_fork+0x2ca>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204380:	8936                	mv	s2,a3
ffffffffc0204382:	bd95                	j	ffffffffc02041f6 <do_fork+0x134>
    mm_destroy(mm);
ffffffffc0204384:	8566                	mv	a0,s9
ffffffffc0204386:	cb6ff0ef          	jal	ra,ffffffffc020383c <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc020438a:	5c71                	li	s8,-4
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020438c:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc020438e:	c02007b7          	lui	a5,0xc0200
ffffffffc0204392:	0af6e563          	bltu	a3,a5,ffffffffc020443c <do_fork+0x37a>
ffffffffc0204396:	000b3703          	ld	a4,0(s6)
    if (PPN(pa) >= npage)
ffffffffc020439a:	000db783          	ld	a5,0(s11)
    return pa2page(PADDR(kva));
ffffffffc020439e:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage)
ffffffffc02043a0:	82b1                	srli	a3,a3,0xc
ffffffffc02043a2:	08f6f163          	bgeu	a3,a5,ffffffffc0204424 <do_fork+0x362>
    return &pages[PPN(pa) - nbase];
ffffffffc02043a6:	000d3783          	ld	a5,0(s10)
ffffffffc02043aa:	000bb503          	ld	a0,0(s7)
ffffffffc02043ae:	4589                	li	a1,2
ffffffffc02043b0:	8e9d                	sub	a3,a3,a5
ffffffffc02043b2:	069a                	slli	a3,a3,0x6
ffffffffc02043b4:	9536                	add	a0,a0,a3
ffffffffc02043b6:	b41fd0ef          	jal	ra,ffffffffc0201ef6 <free_pages>
    kfree(proc);
ffffffffc02043ba:	8522                	mv	a0,s0
ffffffffc02043bc:	9cffd0ef          	jal	ra,ffffffffc0201d8a <kfree>
    return ret;
ffffffffc02043c0:	bde1                	j	ffffffffc0204298 <do_fork+0x1d6>
                    if (last_pid >= MAX_PID)
ffffffffc02043c2:	01d6c363          	blt	a3,t4,ffffffffc02043c8 <do_fork+0x306>
                        last_pid = 1;
ffffffffc02043c6:	4685                	li	a3,1
                    goto repeat;
ffffffffc02043c8:	4585                	li	a1,1
ffffffffc02043ca:	bf19                	j	ffffffffc02042e0 <do_fork+0x21e>
    return -E_NO_MEM;
ffffffffc02043cc:	5c71                	li	s8,-4
ffffffffc02043ce:	b7f5                	j	ffffffffc02043ba <do_fork+0x2f8>
    int ret = -E_NO_FREE_PROC;
ffffffffc02043d0:	5c6d                	li	s8,-5
ffffffffc02043d2:	b5d9                	j	ffffffffc0204298 <do_fork+0x1d6>
ffffffffc02043d4:	c599                	beqz	a1,ffffffffc02043e2 <do_fork+0x320>
ffffffffc02043d6:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc02043da:	8536                	mv	a0,a3
ffffffffc02043dc:	bdb1                	j	ffffffffc0204238 <do_fork+0x176>
    ret = -E_NO_MEM;
ffffffffc02043de:	5c71                	li	s8,-4
ffffffffc02043e0:	bd65                	j	ffffffffc0204298 <do_fork+0x1d6>
    return last_pid;
ffffffffc02043e2:	00082503          	lw	a0,0(a6)
ffffffffc02043e6:	bd89                	j	ffffffffc0204238 <do_fork+0x176>
    int ret = -E_NO_MEM;
ffffffffc02043e8:	5c71                	li	s8,-4
ffffffffc02043ea:	b74d                	j	ffffffffc020438c <do_fork+0x2ca>
    assert(current->wait_state == 0);
ffffffffc02043ec:	00003697          	auipc	a3,0x3
ffffffffc02043f0:	d8c68693          	addi	a3,a3,-628 # ffffffffc0207178 <default_pmm_manager+0xb40>
ffffffffc02043f4:	00002617          	auipc	a2,0x2
ffffffffc02043f8:	e9460613          	addi	a2,a2,-364 # ffffffffc0206288 <commands+0x828>
ffffffffc02043fc:	1f500593          	li	a1,501
ffffffffc0204400:	00003517          	auipc	a0,0x3
ffffffffc0204404:	cc050513          	addi	a0,a0,-832 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc0204408:	886fc0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc020440c:	00002617          	auipc	a2,0x2
ffffffffc0204410:	26460613          	addi	a2,a2,612 # ffffffffc0206670 <default_pmm_manager+0x38>
ffffffffc0204414:	07100593          	li	a1,113
ffffffffc0204418:	00002517          	auipc	a0,0x2
ffffffffc020441c:	28050513          	addi	a0,a0,640 # ffffffffc0206698 <default_pmm_manager+0x60>
ffffffffc0204420:	86efc0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204424:	00002617          	auipc	a2,0x2
ffffffffc0204428:	31c60613          	addi	a2,a2,796 # ffffffffc0206740 <default_pmm_manager+0x108>
ffffffffc020442c:	06900593          	li	a1,105
ffffffffc0204430:	00002517          	auipc	a0,0x2
ffffffffc0204434:	26850513          	addi	a0,a0,616 # ffffffffc0206698 <default_pmm_manager+0x60>
ffffffffc0204438:	856fc0ef          	jal	ra,ffffffffc020048e <__panic>
    return pa2page(PADDR(kva));
ffffffffc020443c:	00002617          	auipc	a2,0x2
ffffffffc0204440:	2dc60613          	addi	a2,a2,732 # ffffffffc0206718 <default_pmm_manager+0xe0>
ffffffffc0204444:	07700593          	li	a1,119
ffffffffc0204448:	00002517          	auipc	a0,0x2
ffffffffc020444c:	25050513          	addi	a0,a0,592 # ffffffffc0206698 <default_pmm_manager+0x60>
ffffffffc0204450:	83efc0ef          	jal	ra,ffffffffc020048e <__panic>
    {
        panic("Unlock failed.\n");
ffffffffc0204454:	00003617          	auipc	a2,0x3
ffffffffc0204458:	d4460613          	addi	a2,a2,-700 # ffffffffc0207198 <default_pmm_manager+0xb60>
ffffffffc020445c:	03f00593          	li	a1,63
ffffffffc0204460:	00003517          	auipc	a0,0x3
ffffffffc0204464:	d4850513          	addi	a0,a0,-696 # ffffffffc02071a8 <default_pmm_manager+0xb70>
ffffffffc0204468:	826fc0ef          	jal	ra,ffffffffc020048e <__panic>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc020446c:	00002617          	auipc	a2,0x2
ffffffffc0204470:	2ac60613          	addi	a2,a2,684 # ffffffffc0206718 <default_pmm_manager+0xe0>
ffffffffc0204474:	19a00593          	li	a1,410
ffffffffc0204478:	00003517          	auipc	a0,0x3
ffffffffc020447c:	c4850513          	addi	a0,a0,-952 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc0204480:	80efc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204484 <kernel_thread>:
{
ffffffffc0204484:	7129                	addi	sp,sp,-320
ffffffffc0204486:	fa22                	sd	s0,304(sp)
ffffffffc0204488:	f626                	sd	s1,296(sp)
ffffffffc020448a:	f24a                	sd	s2,288(sp)
ffffffffc020448c:	84ae                	mv	s1,a1
ffffffffc020448e:	892a                	mv	s2,a0
ffffffffc0204490:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204492:	4581                	li	a1,0
ffffffffc0204494:	12000613          	li	a2,288
ffffffffc0204498:	850a                	mv	a0,sp
{
ffffffffc020449a:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020449c:	330010ef          	jal	ra,ffffffffc02057cc <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02044a0:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02044a2:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02044a4:	100027f3          	csrr	a5,sstatus
ffffffffc02044a8:	edd7f793          	andi	a5,a5,-291
ffffffffc02044ac:	1207e793          	ori	a5,a5,288
ffffffffc02044b0:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02044b2:	860a                	mv	a2,sp
ffffffffc02044b4:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02044b8:	00000797          	auipc	a5,0x0
ffffffffc02044bc:	94e78793          	addi	a5,a5,-1714 # ffffffffc0203e06 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02044c0:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02044c2:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02044c4:	bffff0ef          	jal	ra,ffffffffc02040c2 <do_fork>
}
ffffffffc02044c8:	70f2                	ld	ra,312(sp)
ffffffffc02044ca:	7452                	ld	s0,304(sp)
ffffffffc02044cc:	74b2                	ld	s1,296(sp)
ffffffffc02044ce:	7912                	ld	s2,288(sp)
ffffffffc02044d0:	6131                	addi	sp,sp,320
ffffffffc02044d2:	8082                	ret

ffffffffc02044d4 <do_exit>:
{
ffffffffc02044d4:	7179                	addi	sp,sp,-48
ffffffffc02044d6:	f022                	sd	s0,32(sp)
    if (current == idleproc)
ffffffffc02044d8:	000a6417          	auipc	s0,0xa6
ffffffffc02044dc:	3b040413          	addi	s0,s0,944 # ffffffffc02aa888 <current>
ffffffffc02044e0:	601c                	ld	a5,0(s0)
{
ffffffffc02044e2:	f406                	sd	ra,40(sp)
ffffffffc02044e4:	ec26                	sd	s1,24(sp)
ffffffffc02044e6:	e84a                	sd	s2,16(sp)
ffffffffc02044e8:	e44e                	sd	s3,8(sp)
ffffffffc02044ea:	e052                	sd	s4,0(sp)
    if (current == idleproc)
ffffffffc02044ec:	000a6717          	auipc	a4,0xa6
ffffffffc02044f0:	3a473703          	ld	a4,932(a4) # ffffffffc02aa890 <idleproc>
ffffffffc02044f4:	0ce78c63          	beq	a5,a4,ffffffffc02045cc <do_exit+0xf8>
    if (current == initproc)
ffffffffc02044f8:	000a6497          	auipc	s1,0xa6
ffffffffc02044fc:	3a048493          	addi	s1,s1,928 # ffffffffc02aa898 <initproc>
ffffffffc0204500:	6098                	ld	a4,0(s1)
ffffffffc0204502:	0ee78b63          	beq	a5,a4,ffffffffc02045f8 <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc0204506:	0287b983          	ld	s3,40(a5)
ffffffffc020450a:	892a                	mv	s2,a0
    if (mm != NULL)
ffffffffc020450c:	02098663          	beqz	s3,ffffffffc0204538 <do_exit+0x64>
ffffffffc0204510:	000a6797          	auipc	a5,0xa6
ffffffffc0204514:	3487b783          	ld	a5,840(a5) # ffffffffc02aa858 <boot_pgdir_pa>
ffffffffc0204518:	577d                	li	a4,-1
ffffffffc020451a:	177e                	slli	a4,a4,0x3f
ffffffffc020451c:	83b1                	srli	a5,a5,0xc
ffffffffc020451e:	8fd9                	or	a5,a5,a4
ffffffffc0204520:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0204524:	0309a783          	lw	a5,48(s3)
ffffffffc0204528:	fff7871b          	addiw	a4,a5,-1
ffffffffc020452c:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0)
ffffffffc0204530:	cb55                	beqz	a4,ffffffffc02045e4 <do_exit+0x110>
        current->mm = NULL;
ffffffffc0204532:	601c                	ld	a5,0(s0)
ffffffffc0204534:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0204538:	601c                	ld	a5,0(s0)
ffffffffc020453a:	470d                	li	a4,3
ffffffffc020453c:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc020453e:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204542:	100027f3          	csrr	a5,sstatus
ffffffffc0204546:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204548:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020454a:	e3f9                	bnez	a5,ffffffffc0204610 <do_exit+0x13c>
        proc = current->parent;
ffffffffc020454c:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD)
ffffffffc020454e:	800007b7          	lui	a5,0x80000
ffffffffc0204552:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc0204554:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204556:	0ec52703          	lw	a4,236(a0)
ffffffffc020455a:	0af70f63          	beq	a4,a5,ffffffffc0204618 <do_exit+0x144>
        while (current->cptr != NULL)
ffffffffc020455e:	6018                	ld	a4,0(s0)
ffffffffc0204560:	7b7c                	ld	a5,240(a4)
ffffffffc0204562:	c3a1                	beqz	a5,ffffffffc02045a2 <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204564:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204568:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD)
ffffffffc020456a:	0985                	addi	s3,s3,1
ffffffffc020456c:	a021                	j	ffffffffc0204574 <do_exit+0xa0>
        while (current->cptr != NULL)
ffffffffc020456e:	6018                	ld	a4,0(s0)
ffffffffc0204570:	7b7c                	ld	a5,240(a4)
ffffffffc0204572:	cb85                	beqz	a5,ffffffffc02045a2 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc0204574:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fc8>
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204578:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc020457a:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc020457c:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc020457e:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204582:	10e7b023          	sd	a4,256(a5)
ffffffffc0204586:	c311                	beqz	a4,ffffffffc020458a <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc0204588:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc020458a:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc020458c:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc020458e:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204590:	fd271fe3          	bne	a4,s2,ffffffffc020456e <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204594:	0ec52783          	lw	a5,236(a0)
ffffffffc0204598:	fd379be3          	bne	a5,s3,ffffffffc020456e <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc020459c:	39f000ef          	jal	ra,ffffffffc020513a <wakeup_proc>
ffffffffc02045a0:	b7f9                	j	ffffffffc020456e <do_exit+0x9a>
    if (flag)
ffffffffc02045a2:	020a1263          	bnez	s4,ffffffffc02045c6 <do_exit+0xf2>
    schedule();
ffffffffc02045a6:	415000ef          	jal	ra,ffffffffc02051ba <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc02045aa:	601c                	ld	a5,0(s0)
ffffffffc02045ac:	00003617          	auipc	a2,0x3
ffffffffc02045b0:	c9460613          	addi	a2,a2,-876 # ffffffffc0207240 <default_pmm_manager+0xc08>
ffffffffc02045b4:	25100593          	li	a1,593
ffffffffc02045b8:	43d4                	lw	a3,4(a5)
ffffffffc02045ba:	00003517          	auipc	a0,0x3
ffffffffc02045be:	b0650513          	addi	a0,a0,-1274 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc02045c2:	ecdfb0ef          	jal	ra,ffffffffc020048e <__panic>
        intr_enable();
ffffffffc02045c6:	be8fc0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02045ca:	bff1                	j	ffffffffc02045a6 <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc02045cc:	00003617          	auipc	a2,0x3
ffffffffc02045d0:	c5460613          	addi	a2,a2,-940 # ffffffffc0207220 <default_pmm_manager+0xbe8>
ffffffffc02045d4:	21d00593          	li	a1,541
ffffffffc02045d8:	00003517          	auipc	a0,0x3
ffffffffc02045dc:	ae850513          	addi	a0,a0,-1304 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc02045e0:	eaffb0ef          	jal	ra,ffffffffc020048e <__panic>
            exit_mmap(mm);
ffffffffc02045e4:	854e                	mv	a0,s3
ffffffffc02045e6:	bf2ff0ef          	jal	ra,ffffffffc02039d8 <exit_mmap>
            put_pgdir(mm);
ffffffffc02045ea:	854e                	mv	a0,s3
ffffffffc02045ec:	921ff0ef          	jal	ra,ffffffffc0203f0c <put_pgdir>
            mm_destroy(mm);
ffffffffc02045f0:	854e                	mv	a0,s3
ffffffffc02045f2:	a4aff0ef          	jal	ra,ffffffffc020383c <mm_destroy>
ffffffffc02045f6:	bf35                	j	ffffffffc0204532 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc02045f8:	00003617          	auipc	a2,0x3
ffffffffc02045fc:	c3860613          	addi	a2,a2,-968 # ffffffffc0207230 <default_pmm_manager+0xbf8>
ffffffffc0204600:	22100593          	li	a1,545
ffffffffc0204604:	00003517          	auipc	a0,0x3
ffffffffc0204608:	abc50513          	addi	a0,a0,-1348 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc020460c:	e83fb0ef          	jal	ra,ffffffffc020048e <__panic>
        intr_disable();
ffffffffc0204610:	ba4fc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc0204614:	4a05                	li	s4,1
ffffffffc0204616:	bf1d                	j	ffffffffc020454c <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc0204618:	323000ef          	jal	ra,ffffffffc020513a <wakeup_proc>
ffffffffc020461c:	b789                	j	ffffffffc020455e <do_exit+0x8a>

ffffffffc020461e <do_wait.part.0>:
int do_wait(int pid, int *code_store)
ffffffffc020461e:	715d                	addi	sp,sp,-80
ffffffffc0204620:	f84a                	sd	s2,48(sp)
ffffffffc0204622:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc0204624:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID)
ffffffffc0204628:	6989                	lui	s3,0x2
int do_wait(int pid, int *code_store)
ffffffffc020462a:	fc26                	sd	s1,56(sp)
ffffffffc020462c:	f052                	sd	s4,32(sp)
ffffffffc020462e:	ec56                	sd	s5,24(sp)
ffffffffc0204630:	e85a                	sd	s6,16(sp)
ffffffffc0204632:	e45e                	sd	s7,8(sp)
ffffffffc0204634:	e486                	sd	ra,72(sp)
ffffffffc0204636:	e0a2                	sd	s0,64(sp)
ffffffffc0204638:	84aa                	mv	s1,a0
ffffffffc020463a:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc020463c:	000a6b97          	auipc	s7,0xa6
ffffffffc0204640:	24cb8b93          	addi	s7,s7,588 # ffffffffc02aa888 <current>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204644:	00050b1b          	sext.w	s6,a0
ffffffffc0204648:	fff50a9b          	addiw	s5,a0,-1
ffffffffc020464c:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc020464e:	0905                	addi	s2,s2,1
    if (pid != 0)
ffffffffc0204650:	ccbd                	beqz	s1,ffffffffc02046ce <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204652:	0359e863          	bltu	s3,s5,ffffffffc0204682 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204656:	45a9                	li	a1,10
ffffffffc0204658:	855a                	mv	a0,s6
ffffffffc020465a:	4cd000ef          	jal	ra,ffffffffc0205326 <hash32>
ffffffffc020465e:	02051793          	slli	a5,a0,0x20
ffffffffc0204662:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204666:	000a2797          	auipc	a5,0xa2
ffffffffc020466a:	1aa78793          	addi	a5,a5,426 # ffffffffc02a6810 <hash_list>
ffffffffc020466e:	953e                	add	a0,a0,a5
ffffffffc0204670:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list)
ffffffffc0204672:	a029                	j	ffffffffc020467c <do_wait.part.0+0x5e>
            if (proc->pid == pid)
ffffffffc0204674:	f2c42783          	lw	a5,-212(s0)
ffffffffc0204678:	02978163          	beq	a5,s1,ffffffffc020469a <do_wait.part.0+0x7c>
ffffffffc020467c:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list)
ffffffffc020467e:	fe851be3          	bne	a0,s0,ffffffffc0204674 <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc0204682:	5579                	li	a0,-2
}
ffffffffc0204684:	60a6                	ld	ra,72(sp)
ffffffffc0204686:	6406                	ld	s0,64(sp)
ffffffffc0204688:	74e2                	ld	s1,56(sp)
ffffffffc020468a:	7942                	ld	s2,48(sp)
ffffffffc020468c:	79a2                	ld	s3,40(sp)
ffffffffc020468e:	7a02                	ld	s4,32(sp)
ffffffffc0204690:	6ae2                	ld	s5,24(sp)
ffffffffc0204692:	6b42                	ld	s6,16(sp)
ffffffffc0204694:	6ba2                	ld	s7,8(sp)
ffffffffc0204696:	6161                	addi	sp,sp,80
ffffffffc0204698:	8082                	ret
        if (proc != NULL && proc->parent == current)
ffffffffc020469a:	000bb683          	ld	a3,0(s7)
ffffffffc020469e:	f4843783          	ld	a5,-184(s0)
ffffffffc02046a2:	fed790e3          	bne	a5,a3,ffffffffc0204682 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02046a6:	f2842703          	lw	a4,-216(s0)
ffffffffc02046aa:	478d                	li	a5,3
ffffffffc02046ac:	0ef70b63          	beq	a4,a5,ffffffffc02047a2 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc02046b0:	4785                	li	a5,1
ffffffffc02046b2:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc02046b4:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc02046b8:	303000ef          	jal	ra,ffffffffc02051ba <schedule>
        if (current->flags & PF_EXITING)
ffffffffc02046bc:	000bb783          	ld	a5,0(s7)
ffffffffc02046c0:	0b07a783          	lw	a5,176(a5)
ffffffffc02046c4:	8b85                	andi	a5,a5,1
ffffffffc02046c6:	d7c9                	beqz	a5,ffffffffc0204650 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc02046c8:	555d                	li	a0,-9
ffffffffc02046ca:	e0bff0ef          	jal	ra,ffffffffc02044d4 <do_exit>
        proc = current->cptr;
ffffffffc02046ce:	000bb683          	ld	a3,0(s7)
ffffffffc02046d2:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr)
ffffffffc02046d4:	d45d                	beqz	s0,ffffffffc0204682 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02046d6:	470d                	li	a4,3
ffffffffc02046d8:	a021                	j	ffffffffc02046e0 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr)
ffffffffc02046da:	10043403          	ld	s0,256(s0)
ffffffffc02046de:	d869                	beqz	s0,ffffffffc02046b0 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02046e0:	401c                	lw	a5,0(s0)
ffffffffc02046e2:	fee79ce3          	bne	a5,a4,ffffffffc02046da <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc)
ffffffffc02046e6:	000a6797          	auipc	a5,0xa6
ffffffffc02046ea:	1aa7b783          	ld	a5,426(a5) # ffffffffc02aa890 <idleproc>
ffffffffc02046ee:	0c878963          	beq	a5,s0,ffffffffc02047c0 <do_wait.part.0+0x1a2>
ffffffffc02046f2:	000a6797          	auipc	a5,0xa6
ffffffffc02046f6:	1a67b783          	ld	a5,422(a5) # ffffffffc02aa898 <initproc>
ffffffffc02046fa:	0cf40363          	beq	s0,a5,ffffffffc02047c0 <do_wait.part.0+0x1a2>
    if (code_store != NULL)
ffffffffc02046fe:	000a0663          	beqz	s4,ffffffffc020470a <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc0204702:	0e842783          	lw	a5,232(s0)
ffffffffc0204706:	00fa2023          	sw	a5,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020470a:	100027f3          	csrr	a5,sstatus
ffffffffc020470e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204710:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204712:	e7c1                	bnez	a5,ffffffffc020479a <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0204714:	6c70                	ld	a2,216(s0)
ffffffffc0204716:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL)
ffffffffc0204718:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc020471c:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc020471e:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0204720:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204722:	6470                	ld	a2,200(s0)
ffffffffc0204724:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0204726:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0204728:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL)
ffffffffc020472a:	c319                	beqz	a4,ffffffffc0204730 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc020472c:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL)
ffffffffc020472e:	7c7c                	ld	a5,248(s0)
ffffffffc0204730:	c3b5                	beqz	a5,ffffffffc0204794 <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc0204732:	10e7b023          	sd	a4,256(a5)
    nr_process--;
ffffffffc0204736:	000a6717          	auipc	a4,0xa6
ffffffffc020473a:	16a70713          	addi	a4,a4,362 # ffffffffc02aa8a0 <nr_process>
ffffffffc020473e:	431c                	lw	a5,0(a4)
ffffffffc0204740:	37fd                	addiw	a5,a5,-1
ffffffffc0204742:	c31c                	sw	a5,0(a4)
    if (flag)
ffffffffc0204744:	e5a9                	bnez	a1,ffffffffc020478e <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204746:	6814                	ld	a3,16(s0)
ffffffffc0204748:	c02007b7          	lui	a5,0xc0200
ffffffffc020474c:	04f6ee63          	bltu	a3,a5,ffffffffc02047a8 <do_wait.part.0+0x18a>
ffffffffc0204750:	000a6797          	auipc	a5,0xa6
ffffffffc0204754:	1307b783          	ld	a5,304(a5) # ffffffffc02aa880 <va_pa_offset>
ffffffffc0204758:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage)
ffffffffc020475a:	82b1                	srli	a3,a3,0xc
ffffffffc020475c:	000a6797          	auipc	a5,0xa6
ffffffffc0204760:	10c7b783          	ld	a5,268(a5) # ffffffffc02aa868 <npage>
ffffffffc0204764:	06f6fa63          	bgeu	a3,a5,ffffffffc02047d8 <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0204768:	00003517          	auipc	a0,0x3
ffffffffc020476c:	38053503          	ld	a0,896(a0) # ffffffffc0207ae8 <nbase>
ffffffffc0204770:	8e89                	sub	a3,a3,a0
ffffffffc0204772:	069a                	slli	a3,a3,0x6
ffffffffc0204774:	000a6517          	auipc	a0,0xa6
ffffffffc0204778:	0fc53503          	ld	a0,252(a0) # ffffffffc02aa870 <pages>
ffffffffc020477c:	9536                	add	a0,a0,a3
ffffffffc020477e:	4589                	li	a1,2
ffffffffc0204780:	f76fd0ef          	jal	ra,ffffffffc0201ef6 <free_pages>
    kfree(proc);
ffffffffc0204784:	8522                	mv	a0,s0
ffffffffc0204786:	e04fd0ef          	jal	ra,ffffffffc0201d8a <kfree>
    return 0;
ffffffffc020478a:	4501                	li	a0,0
ffffffffc020478c:	bde5                	j	ffffffffc0204684 <do_wait.part.0+0x66>
        intr_enable();
ffffffffc020478e:	a20fc0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0204792:	bf55                	j	ffffffffc0204746 <do_wait.part.0+0x128>
        proc->parent->cptr = proc->optr;
ffffffffc0204794:	701c                	ld	a5,32(s0)
ffffffffc0204796:	fbf8                	sd	a4,240(a5)
ffffffffc0204798:	bf79                	j	ffffffffc0204736 <do_wait.part.0+0x118>
        intr_disable();
ffffffffc020479a:	a1afc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc020479e:	4585                	li	a1,1
ffffffffc02047a0:	bf95                	j	ffffffffc0204714 <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02047a2:	f2840413          	addi	s0,s0,-216
ffffffffc02047a6:	b781                	j	ffffffffc02046e6 <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc02047a8:	00002617          	auipc	a2,0x2
ffffffffc02047ac:	f7060613          	addi	a2,a2,-144 # ffffffffc0206718 <default_pmm_manager+0xe0>
ffffffffc02047b0:	07700593          	li	a1,119
ffffffffc02047b4:	00002517          	auipc	a0,0x2
ffffffffc02047b8:	ee450513          	addi	a0,a0,-284 # ffffffffc0206698 <default_pmm_manager+0x60>
ffffffffc02047bc:	cd3fb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc02047c0:	00003617          	auipc	a2,0x3
ffffffffc02047c4:	aa060613          	addi	a2,a2,-1376 # ffffffffc0207260 <default_pmm_manager+0xc28>
ffffffffc02047c8:	37400593          	li	a1,884
ffffffffc02047cc:	00003517          	auipc	a0,0x3
ffffffffc02047d0:	8f450513          	addi	a0,a0,-1804 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc02047d4:	cbbfb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02047d8:	00002617          	auipc	a2,0x2
ffffffffc02047dc:	f6860613          	addi	a2,a2,-152 # ffffffffc0206740 <default_pmm_manager+0x108>
ffffffffc02047e0:	06900593          	li	a1,105
ffffffffc02047e4:	00002517          	auipc	a0,0x2
ffffffffc02047e8:	eb450513          	addi	a0,a0,-332 # ffffffffc0206698 <default_pmm_manager+0x60>
ffffffffc02047ec:	ca3fb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02047f0 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc02047f0:	1141                	addi	sp,sp,-16
ffffffffc02047f2:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02047f4:	f42fd0ef          	jal	ra,ffffffffc0201f36 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02047f8:	cdefd0ef          	jal	ra,ffffffffc0201cd6 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02047fc:	4601                	li	a2,0
ffffffffc02047fe:	4581                	li	a1,0
ffffffffc0204800:	fffff517          	auipc	a0,0xfffff
ffffffffc0204804:	68e50513          	addi	a0,a0,1678 # ffffffffc0203e8e <user_main>
ffffffffc0204808:	c7dff0ef          	jal	ra,ffffffffc0204484 <kernel_thread>
    if (pid <= 0)
ffffffffc020480c:	00a04563          	bgtz	a0,ffffffffc0204816 <init_main+0x26>
ffffffffc0204810:	a071                	j	ffffffffc020489c <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
ffffffffc0204812:	1a9000ef          	jal	ra,ffffffffc02051ba <schedule>
    if (code_store != NULL)
ffffffffc0204816:	4581                	li	a1,0
ffffffffc0204818:	4501                	li	a0,0
ffffffffc020481a:	e05ff0ef          	jal	ra,ffffffffc020461e <do_wait.part.0>
    while (do_wait(0, NULL) == 0)
ffffffffc020481e:	d975                	beqz	a0,ffffffffc0204812 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0204820:	00003517          	auipc	a0,0x3
ffffffffc0204824:	a8050513          	addi	a0,a0,-1408 # ffffffffc02072a0 <default_pmm_manager+0xc68>
ffffffffc0204828:	96dfb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020482c:	000a6797          	auipc	a5,0xa6
ffffffffc0204830:	06c7b783          	ld	a5,108(a5) # ffffffffc02aa898 <initproc>
ffffffffc0204834:	7bf8                	ld	a4,240(a5)
ffffffffc0204836:	e339                	bnez	a4,ffffffffc020487c <init_main+0x8c>
ffffffffc0204838:	7ff8                	ld	a4,248(a5)
ffffffffc020483a:	e329                	bnez	a4,ffffffffc020487c <init_main+0x8c>
ffffffffc020483c:	1007b703          	ld	a4,256(a5)
ffffffffc0204840:	ef15                	bnez	a4,ffffffffc020487c <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc0204842:	000a6697          	auipc	a3,0xa6
ffffffffc0204846:	05e6a683          	lw	a3,94(a3) # ffffffffc02aa8a0 <nr_process>
ffffffffc020484a:	4709                	li	a4,2
ffffffffc020484c:	0ae69463          	bne	a3,a4,ffffffffc02048f4 <init_main+0x104>
    return listelm->next;
ffffffffc0204850:	000a6697          	auipc	a3,0xa6
ffffffffc0204854:	fc068693          	addi	a3,a3,-64 # ffffffffc02aa810 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204858:	6698                	ld	a4,8(a3)
ffffffffc020485a:	0c878793          	addi	a5,a5,200
ffffffffc020485e:	06f71b63          	bne	a4,a5,ffffffffc02048d4 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204862:	629c                	ld	a5,0(a3)
ffffffffc0204864:	04f71863          	bne	a4,a5,ffffffffc02048b4 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc0204868:	00003517          	auipc	a0,0x3
ffffffffc020486c:	b2050513          	addi	a0,a0,-1248 # ffffffffc0207388 <default_pmm_manager+0xd50>
ffffffffc0204870:	925fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    return 0;
}
ffffffffc0204874:	60a2                	ld	ra,8(sp)
ffffffffc0204876:	4501                	li	a0,0
ffffffffc0204878:	0141                	addi	sp,sp,16
ffffffffc020487a:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020487c:	00003697          	auipc	a3,0x3
ffffffffc0204880:	a4c68693          	addi	a3,a3,-1460 # ffffffffc02072c8 <default_pmm_manager+0xc90>
ffffffffc0204884:	00002617          	auipc	a2,0x2
ffffffffc0204888:	a0460613          	addi	a2,a2,-1532 # ffffffffc0206288 <commands+0x828>
ffffffffc020488c:	3e200593          	li	a1,994
ffffffffc0204890:	00003517          	auipc	a0,0x3
ffffffffc0204894:	83050513          	addi	a0,a0,-2000 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc0204898:	bf7fb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("create user_main failed.\n");
ffffffffc020489c:	00003617          	auipc	a2,0x3
ffffffffc02048a0:	9e460613          	addi	a2,a2,-1564 # ffffffffc0207280 <default_pmm_manager+0xc48>
ffffffffc02048a4:	3d900593          	li	a1,985
ffffffffc02048a8:	00003517          	auipc	a0,0x3
ffffffffc02048ac:	81850513          	addi	a0,a0,-2024 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc02048b0:	bdffb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02048b4:	00003697          	auipc	a3,0x3
ffffffffc02048b8:	aa468693          	addi	a3,a3,-1372 # ffffffffc0207358 <default_pmm_manager+0xd20>
ffffffffc02048bc:	00002617          	auipc	a2,0x2
ffffffffc02048c0:	9cc60613          	addi	a2,a2,-1588 # ffffffffc0206288 <commands+0x828>
ffffffffc02048c4:	3e500593          	li	a1,997
ffffffffc02048c8:	00002517          	auipc	a0,0x2
ffffffffc02048cc:	7f850513          	addi	a0,a0,2040 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc02048d0:	bbffb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02048d4:	00003697          	auipc	a3,0x3
ffffffffc02048d8:	a5468693          	addi	a3,a3,-1452 # ffffffffc0207328 <default_pmm_manager+0xcf0>
ffffffffc02048dc:	00002617          	auipc	a2,0x2
ffffffffc02048e0:	9ac60613          	addi	a2,a2,-1620 # ffffffffc0206288 <commands+0x828>
ffffffffc02048e4:	3e400593          	li	a1,996
ffffffffc02048e8:	00002517          	auipc	a0,0x2
ffffffffc02048ec:	7d850513          	addi	a0,a0,2008 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc02048f0:	b9ffb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_process == 2);
ffffffffc02048f4:	00003697          	auipc	a3,0x3
ffffffffc02048f8:	a2468693          	addi	a3,a3,-1500 # ffffffffc0207318 <default_pmm_manager+0xce0>
ffffffffc02048fc:	00002617          	auipc	a2,0x2
ffffffffc0204900:	98c60613          	addi	a2,a2,-1652 # ffffffffc0206288 <commands+0x828>
ffffffffc0204904:	3e300593          	li	a1,995
ffffffffc0204908:	00002517          	auipc	a0,0x2
ffffffffc020490c:	7b850513          	addi	a0,a0,1976 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc0204910:	b7ffb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204914 <do_execve>:
{
ffffffffc0204914:	7135                	addi	sp,sp,-160
ffffffffc0204916:	f0da                	sd	s6,96(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204918:	000a6b17          	auipc	s6,0xa6
ffffffffc020491c:	f70b0b13          	addi	s6,s6,-144 # ffffffffc02aa888 <current>
ffffffffc0204920:	000b3783          	ld	a5,0(s6)
{
ffffffffc0204924:	fcce                	sd	s3,120(sp)
ffffffffc0204926:	e526                	sd	s1,136(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204928:	0287b983          	ld	s3,40(a5)
{
ffffffffc020492c:	e14a                	sd	s2,128(sp)
ffffffffc020492e:	f4d6                	sd	s5,104(sp)
ffffffffc0204930:	892a                	mv	s2,a0
ffffffffc0204932:	8ab2                	mv	s5,a2
ffffffffc0204934:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204936:	862e                	mv	a2,a1
ffffffffc0204938:	4681                	li	a3,0
ffffffffc020493a:	85aa                	mv	a1,a0
ffffffffc020493c:	854e                	mv	a0,s3
{
ffffffffc020493e:	ed06                	sd	ra,152(sp)
ffffffffc0204940:	e922                	sd	s0,144(sp)
ffffffffc0204942:	f8d2                	sd	s4,112(sp)
ffffffffc0204944:	ecde                	sd	s7,88(sp)
ffffffffc0204946:	e8e2                	sd	s8,80(sp)
ffffffffc0204948:	e4e6                	sd	s9,72(sp)
ffffffffc020494a:	e0ea                	sd	s10,64(sp)
ffffffffc020494c:	fc6e                	sd	s11,56(sp)
ffffffffc020494e:	e856                	sd	s5,16(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204950:	c22ff0ef          	jal	ra,ffffffffc0203d72 <user_mem_check>
ffffffffc0204954:	42050663          	beqz	a0,ffffffffc0204d80 <do_execve+0x46c>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0204958:	4641                	li	a2,16
ffffffffc020495a:	4581                	li	a1,0
ffffffffc020495c:	1008                	addi	a0,sp,32
ffffffffc020495e:	66f000ef          	jal	ra,ffffffffc02057cc <memset>
    memcpy(local_name, name, len);
ffffffffc0204962:	47bd                	li	a5,15
ffffffffc0204964:	8626                	mv	a2,s1
ffffffffc0204966:	0697ed63          	bltu	a5,s1,ffffffffc02049e0 <do_execve+0xcc>
ffffffffc020496a:	85ca                	mv	a1,s2
ffffffffc020496c:	1008                	addi	a0,sp,32
ffffffffc020496e:	671000ef          	jal	ra,ffffffffc02057de <memcpy>
    if (mm != NULL)
ffffffffc0204972:	06098e63          	beqz	s3,ffffffffc02049ee <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc0204976:	00002517          	auipc	a0,0x2
ffffffffc020497a:	50a50513          	addi	a0,a0,1290 # ffffffffc0206e80 <default_pmm_manager+0x848>
ffffffffc020497e:	84ffb0ef          	jal	ra,ffffffffc02001cc <cputs>
ffffffffc0204982:	000a6797          	auipc	a5,0xa6
ffffffffc0204986:	ed67b783          	ld	a5,-298(a5) # ffffffffc02aa858 <boot_pgdir_pa>
ffffffffc020498a:	577d                	li	a4,-1
ffffffffc020498c:	177e                	slli	a4,a4,0x3f
ffffffffc020498e:	83b1                	srli	a5,a5,0xc
ffffffffc0204990:	8fd9                	or	a5,a5,a4
ffffffffc0204992:	18079073          	csrw	satp,a5
ffffffffc0204996:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7b90>
ffffffffc020499a:	fff7871b          	addiw	a4,a5,-1
ffffffffc020499e:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0)
ffffffffc02049a2:	2c070663          	beqz	a4,ffffffffc0204c6e <do_execve+0x35a>
        current->mm = NULL;
ffffffffc02049a6:	000b3783          	ld	a5,0(s6)
ffffffffc02049aa:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc02049ae:	d4ffe0ef          	jal	ra,ffffffffc02036fc <mm_create>
ffffffffc02049b2:	84aa                	mv	s1,a0
ffffffffc02049b4:	c135                	beqz	a0,ffffffffc0204a18 <do_execve+0x104>
    if (setup_pgdir(mm) != 0)
ffffffffc02049b6:	dccff0ef          	jal	ra,ffffffffc0203f82 <setup_pgdir>
ffffffffc02049ba:	e931                	bnez	a0,ffffffffc0204a0e <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc02049bc:	67c2                	ld	a5,16(sp)
ffffffffc02049be:	4398                	lw	a4,0(a5)
ffffffffc02049c0:	464c47b7          	lui	a5,0x464c4
ffffffffc02049c4:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9447>
ffffffffc02049c8:	04f70a63          	beq	a4,a5,ffffffffc0204a1c <do_execve+0x108>
    put_pgdir(mm);
ffffffffc02049cc:	8526                	mv	a0,s1
ffffffffc02049ce:	d3eff0ef          	jal	ra,ffffffffc0203f0c <put_pgdir>
    mm_destroy(mm);
ffffffffc02049d2:	8526                	mv	a0,s1
ffffffffc02049d4:	e69fe0ef          	jal	ra,ffffffffc020383c <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc02049d8:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc02049da:	8552                	mv	a0,s4
ffffffffc02049dc:	af9ff0ef          	jal	ra,ffffffffc02044d4 <do_exit>
    memcpy(local_name, name, len);
ffffffffc02049e0:	463d                	li	a2,15
ffffffffc02049e2:	85ca                	mv	a1,s2
ffffffffc02049e4:	1008                	addi	a0,sp,32
ffffffffc02049e6:	5f9000ef          	jal	ra,ffffffffc02057de <memcpy>
    if (mm != NULL)
ffffffffc02049ea:	f80996e3          	bnez	s3,ffffffffc0204976 <do_execve+0x62>
    if (current->mm != NULL)
ffffffffc02049ee:	000b3783          	ld	a5,0(s6)
ffffffffc02049f2:	779c                	ld	a5,40(a5)
ffffffffc02049f4:	dfcd                	beqz	a5,ffffffffc02049ae <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc02049f6:	00003617          	auipc	a2,0x3
ffffffffc02049fa:	9b260613          	addi	a2,a2,-1614 # ffffffffc02073a8 <default_pmm_manager+0xd70>
ffffffffc02049fe:	25d00593          	li	a1,605
ffffffffc0204a02:	00002517          	auipc	a0,0x2
ffffffffc0204a06:	6be50513          	addi	a0,a0,1726 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc0204a0a:	a85fb0ef          	jal	ra,ffffffffc020048e <__panic>
    mm_destroy(mm);
ffffffffc0204a0e:	8526                	mv	a0,s1
ffffffffc0204a10:	e2dfe0ef          	jal	ra,ffffffffc020383c <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0204a14:	5a71                	li	s4,-4
ffffffffc0204a16:	b7d1                	j	ffffffffc02049da <do_execve+0xc6>
ffffffffc0204a18:	5a71                	li	s4,-4
ffffffffc0204a1a:	b7c1                	j	ffffffffc02049da <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204a1c:	66c2                	ld	a3,16(sp)
ffffffffc0204a1e:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204a22:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204a26:	00371793          	slli	a5,a4,0x3
ffffffffc0204a2a:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204a2c:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204a2e:	078e                	slli	a5,a5,0x3
ffffffffc0204a30:	97ce                	add	a5,a5,s3
ffffffffc0204a32:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph++)
ffffffffc0204a34:	02f9fb63          	bgeu	s3,a5,ffffffffc0204a6a <do_execve+0x156>
    return KADDR(page2pa(page));
ffffffffc0204a38:	57fd                	li	a5,-1
ffffffffc0204a3a:	83b1                	srli	a5,a5,0xc
    return page - pages + nbase;
ffffffffc0204a3c:	000a6d17          	auipc	s10,0xa6
ffffffffc0204a40:	e34d0d13          	addi	s10,s10,-460 # ffffffffc02aa870 <pages>
ffffffffc0204a44:	00003c97          	auipc	s9,0x3
ffffffffc0204a48:	0a4c8c93          	addi	s9,s9,164 # ffffffffc0207ae8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204a4c:	e43e                	sd	a5,8(sp)
ffffffffc0204a4e:	000a6c17          	auipc	s8,0xa6
ffffffffc0204a52:	e1ac0c13          	addi	s8,s8,-486 # ffffffffc02aa868 <npage>
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc0204a56:	0009a703          	lw	a4,0(s3)
ffffffffc0204a5a:	4785                	li	a5,1
ffffffffc0204a5c:	12f70863          	beq	a4,a5,ffffffffc0204b8c <do_execve+0x278>
    for (; ph < ph_end; ph++)
ffffffffc0204a60:	67e2                	ld	a5,24(sp)
ffffffffc0204a62:	03898993          	addi	s3,s3,56
ffffffffc0204a66:	fef9e8e3          	bltu	s3,a5,ffffffffc0204a56 <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc0204a6a:	4701                	li	a4,0
ffffffffc0204a6c:	46ad                	li	a3,11
ffffffffc0204a6e:	00100637          	lui	a2,0x100
ffffffffc0204a72:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0204a76:	8526                	mv	a0,s1
ffffffffc0204a78:	e17fe0ef          	jal	ra,ffffffffc020388e <mm_map>
ffffffffc0204a7c:	8a2a                	mv	s4,a0
ffffffffc0204a7e:	1c051e63          	bnez	a0,ffffffffc0204c5a <do_execve+0x346>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204a82:	6c88                	ld	a0,24(s1)
ffffffffc0204a84:	467d                	li	a2,31
ffffffffc0204a86:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0204a8a:	b8dfe0ef          	jal	ra,ffffffffc0203616 <pgdir_alloc_page>
ffffffffc0204a8e:	3a050363          	beqz	a0,ffffffffc0204e34 <do_execve+0x520>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204a92:	6c88                	ld	a0,24(s1)
ffffffffc0204a94:	467d                	li	a2,31
ffffffffc0204a96:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0204a9a:	b7dfe0ef          	jal	ra,ffffffffc0203616 <pgdir_alloc_page>
ffffffffc0204a9e:	36050b63          	beqz	a0,ffffffffc0204e14 <do_execve+0x500>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204aa2:	6c88                	ld	a0,24(s1)
ffffffffc0204aa4:	467d                	li	a2,31
ffffffffc0204aa6:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0204aaa:	b6dfe0ef          	jal	ra,ffffffffc0203616 <pgdir_alloc_page>
ffffffffc0204aae:	34050363          	beqz	a0,ffffffffc0204df4 <do_execve+0x4e0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204ab2:	6c88                	ld	a0,24(s1)
ffffffffc0204ab4:	467d                	li	a2,31
ffffffffc0204ab6:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0204aba:	b5dfe0ef          	jal	ra,ffffffffc0203616 <pgdir_alloc_page>
ffffffffc0204abe:	30050b63          	beqz	a0,ffffffffc0204dd4 <do_execve+0x4c0>
    mm->mm_count += 1;
ffffffffc0204ac2:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0204ac4:	000b3703          	ld	a4,0(s6)
    cprintf("[DEBUG] load_icode: mm->pgdir=%p (before PADDR)\n", mm->pgdir);
ffffffffc0204ac8:	6c8c                	ld	a1,24(s1)
ffffffffc0204aca:	2785                	addiw	a5,a5,1
ffffffffc0204acc:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0204ace:	f704                	sd	s1,40(a4)
    cprintf("[DEBUG] load_icode: mm->pgdir=%p (before PADDR)\n", mm->pgdir);
ffffffffc0204ad0:	00003517          	auipc	a0,0x3
ffffffffc0204ad4:	a6050513          	addi	a0,a0,-1440 # ffffffffc0207530 <default_pmm_manager+0xef8>
ffffffffc0204ad8:	ebcfb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204adc:	6c94                	ld	a3,24(s1)
ffffffffc0204ade:	c0200937          	lui	s2,0xc0200
ffffffffc0204ae2:	2d26ed63          	bltu	a3,s2,ffffffffc0204dbc <do_execve+0x4a8>
ffffffffc0204ae6:	000a6417          	auipc	s0,0xa6
ffffffffc0204aea:	d9a40413          	addi	s0,s0,-614 # ffffffffc02aa880 <va_pa_offset>
ffffffffc0204aee:	600c                	ld	a1,0(s0)
ffffffffc0204af0:	000b3783          	ld	a5,0(s6)
    cprintf("[DEBUG] load_icode: current->pgdir=%p (after PADDR)\n", current->pgdir);
ffffffffc0204af4:	00003517          	auipc	a0,0x3
ffffffffc0204af8:	a7450513          	addi	a0,a0,-1420 # ffffffffc0207568 <default_pmm_manager+0xf30>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204afc:	40b685b3          	sub	a1,a3,a1
ffffffffc0204b00:	f7cc                	sd	a1,168(a5)
    cprintf("[DEBUG] load_icode: current->pgdir=%p (after PADDR)\n", current->pgdir);
ffffffffc0204b02:	e92fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    lsatp(PADDR(mm->pgdir));
ffffffffc0204b06:	6c94                	ld	a3,24(s1)
ffffffffc0204b08:	2926ee63          	bltu	a3,s2,ffffffffc0204da4 <do_execve+0x490>
ffffffffc0204b0c:	601c                	ld	a5,0(s0)
ffffffffc0204b0e:	8e9d                	sub	a3,a3,a5
ffffffffc0204b10:	57fd                	li	a5,-1
ffffffffc0204b12:	17fe                	slli	a5,a5,0x3f
ffffffffc0204b14:	82b1                	srli	a3,a3,0xc
ffffffffc0204b16:	8edd                	or	a3,a3,a5
ffffffffc0204b18:	18069073          	csrw	satp,a3
    struct trapframe *tf = current->tf;
ffffffffc0204b1c:	000b3783          	ld	a5,0(s6)
ffffffffc0204b20:	0a07b903          	ld	s2,160(a5)
    uintptr_t sstatus = read_csr(sstatus);
ffffffffc0204b24:	10002473          	csrr	s0,sstatus
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204b28:	12000613          	li	a2,288
ffffffffc0204b2c:	4581                	li	a1,0
ffffffffc0204b2e:	854a                	mv	a0,s2
ffffffffc0204b30:	49d000ef          	jal	ra,ffffffffc02057cc <memset>
    tf->epc = elf->e_entry;
ffffffffc0204b34:	67c2                	ld	a5,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204b36:	000b3483          	ld	s1,0(s6)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204b3a:	edf47413          	andi	s0,s0,-289
    tf->epc = elf->e_entry;
ffffffffc0204b3e:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc0204b40:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204b42:	0b448493          	addi	s1,s1,180
    tf->gpr.sp = USTACKTOP;
ffffffffc0204b46:	07fe                	slli	a5,a5,0x1f
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204b48:	02046413          	ori	s0,s0,32
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204b4c:	4641                	li	a2,16
ffffffffc0204b4e:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP;
ffffffffc0204b50:	00f93823          	sd	a5,16(s2) # ffffffffc0200010 <kern_entry+0x10>
    tf->epc = elf->e_entry;
ffffffffc0204b54:	10e93423          	sd	a4,264(s2)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204b58:	10893023          	sd	s0,256(s2)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204b5c:	8526                	mv	a0,s1
ffffffffc0204b5e:	46f000ef          	jal	ra,ffffffffc02057cc <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204b62:	463d                	li	a2,15
ffffffffc0204b64:	100c                	addi	a1,sp,32
ffffffffc0204b66:	8526                	mv	a0,s1
ffffffffc0204b68:	477000ef          	jal	ra,ffffffffc02057de <memcpy>
}
ffffffffc0204b6c:	60ea                	ld	ra,152(sp)
ffffffffc0204b6e:	644a                	ld	s0,144(sp)
ffffffffc0204b70:	64aa                	ld	s1,136(sp)
ffffffffc0204b72:	690a                	ld	s2,128(sp)
ffffffffc0204b74:	79e6                	ld	s3,120(sp)
ffffffffc0204b76:	7aa6                	ld	s5,104(sp)
ffffffffc0204b78:	7b06                	ld	s6,96(sp)
ffffffffc0204b7a:	6be6                	ld	s7,88(sp)
ffffffffc0204b7c:	6c46                	ld	s8,80(sp)
ffffffffc0204b7e:	6ca6                	ld	s9,72(sp)
ffffffffc0204b80:	6d06                	ld	s10,64(sp)
ffffffffc0204b82:	7de2                	ld	s11,56(sp)
ffffffffc0204b84:	8552                	mv	a0,s4
ffffffffc0204b86:	7a46                	ld	s4,112(sp)
ffffffffc0204b88:	610d                	addi	sp,sp,160
ffffffffc0204b8a:	8082                	ret
        if (ph->p_filesz > ph->p_memsz)
ffffffffc0204b8c:	0289b603          	ld	a2,40(s3)
ffffffffc0204b90:	0209b783          	ld	a5,32(s3)
ffffffffc0204b94:	1ef66a63          	bltu	a2,a5,ffffffffc0204d88 <do_execve+0x474>
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204b98:	0049a783          	lw	a5,4(s3)
ffffffffc0204b9c:	0017f693          	andi	a3,a5,1
ffffffffc0204ba0:	c291                	beqz	a3,ffffffffc0204ba4 <do_execve+0x290>
            vm_flags |= VM_EXEC;
ffffffffc0204ba2:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204ba4:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204ba8:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204baa:	ef61                	bnez	a4,ffffffffc0204c82 <do_execve+0x36e>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0204bac:	4bc5                	li	s7,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204bae:	c781                	beqz	a5,ffffffffc0204bb6 <do_execve+0x2a2>
            vm_flags |= VM_READ;
ffffffffc0204bb0:	0016e693          	ori	a3,a3,1
            perm |= PTE_R;
ffffffffc0204bb4:	4bcd                	li	s7,19
        if (vm_flags & VM_WRITE)
ffffffffc0204bb6:	0026f793          	andi	a5,a3,2
ffffffffc0204bba:	e7f9                	bnez	a5,ffffffffc0204c88 <do_execve+0x374>
        if (vm_flags & VM_EXEC)
ffffffffc0204bbc:	0046f793          	andi	a5,a3,4
ffffffffc0204bc0:	c399                	beqz	a5,ffffffffc0204bc6 <do_execve+0x2b2>
            perm |= PTE_X;
ffffffffc0204bc2:	008beb93          	ori	s7,s7,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc0204bc6:	0109b583          	ld	a1,16(s3)
ffffffffc0204bca:	4701                	li	a4,0
ffffffffc0204bcc:	8526                	mv	a0,s1
ffffffffc0204bce:	cc1fe0ef          	jal	ra,ffffffffc020388e <mm_map>
ffffffffc0204bd2:	8a2a                	mv	s4,a0
ffffffffc0204bd4:	e159                	bnez	a0,ffffffffc0204c5a <do_execve+0x346>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204bd6:	0109bd83          	ld	s11,16(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204bda:	67c2                	ld	a5,16(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0204bdc:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204be0:	0089b903          	ld	s2,8(s3)
        end = ph->p_va + ph->p_filesz;
ffffffffc0204be4:	9a6e                	add	s4,s4,s11
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204be6:	993e                	add	s2,s2,a5
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204be8:	77fd                	lui	a5,0xfffff
ffffffffc0204bea:	00fdfab3          	and	s5,s11,a5
        while (start < end)
ffffffffc0204bee:	054dee63          	bltu	s11,s4,ffffffffc0204c4a <do_execve+0x336>
ffffffffc0204bf2:	aa49                	j	ffffffffc0204d84 <do_execve+0x470>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204bf4:	6785                	lui	a5,0x1
ffffffffc0204bf6:	415d8533          	sub	a0,s11,s5
ffffffffc0204bfa:	9abe                	add	s5,s5,a5
ffffffffc0204bfc:	41ba8633          	sub	a2,s5,s11
            if (end < la)
ffffffffc0204c00:	015a7463          	bgeu	s4,s5,ffffffffc0204c08 <do_execve+0x2f4>
                size -= la - end;
ffffffffc0204c04:	41ba0633          	sub	a2,s4,s11
    return page - pages + nbase;
ffffffffc0204c08:	000d3683          	ld	a3,0(s10)
ffffffffc0204c0c:	000cb803          	ld	a6,0(s9)
    return KADDR(page2pa(page));
ffffffffc0204c10:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0204c12:	40d406b3          	sub	a3,s0,a3
ffffffffc0204c16:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204c18:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204c1c:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0204c1e:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c22:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204c24:	16b87463          	bgeu	a6,a1,ffffffffc0204d8c <do_execve+0x478>
ffffffffc0204c28:	000a6797          	auipc	a5,0xa6
ffffffffc0204c2c:	c5878793          	addi	a5,a5,-936 # ffffffffc02aa880 <va_pa_offset>
ffffffffc0204c30:	0007b803          	ld	a6,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204c34:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0204c36:	9db2                	add	s11,s11,a2
ffffffffc0204c38:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204c3a:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0204c3c:	e032                	sd	a2,0(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204c3e:	3a1000ef          	jal	ra,ffffffffc02057de <memcpy>
            start += size, from += size;
ffffffffc0204c42:	6602                	ld	a2,0(sp)
ffffffffc0204c44:	9932                	add	s2,s2,a2
        while (start < end)
ffffffffc0204c46:	054df363          	bgeu	s11,s4,ffffffffc0204c8c <do_execve+0x378>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204c4a:	6c88                	ld	a0,24(s1)
ffffffffc0204c4c:	865e                	mv	a2,s7
ffffffffc0204c4e:	85d6                	mv	a1,s5
ffffffffc0204c50:	9c7fe0ef          	jal	ra,ffffffffc0203616 <pgdir_alloc_page>
ffffffffc0204c54:	842a                	mv	s0,a0
ffffffffc0204c56:	fd59                	bnez	a0,ffffffffc0204bf4 <do_execve+0x2e0>
        ret = -E_NO_MEM;
ffffffffc0204c58:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0204c5a:	8526                	mv	a0,s1
ffffffffc0204c5c:	d7dfe0ef          	jal	ra,ffffffffc02039d8 <exit_mmap>
    put_pgdir(mm);
ffffffffc0204c60:	8526                	mv	a0,s1
ffffffffc0204c62:	aaaff0ef          	jal	ra,ffffffffc0203f0c <put_pgdir>
    mm_destroy(mm);
ffffffffc0204c66:	8526                	mv	a0,s1
ffffffffc0204c68:	bd5fe0ef          	jal	ra,ffffffffc020383c <mm_destroy>
    return ret;
ffffffffc0204c6c:	b3bd                	j	ffffffffc02049da <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0204c6e:	854e                	mv	a0,s3
ffffffffc0204c70:	d69fe0ef          	jal	ra,ffffffffc02039d8 <exit_mmap>
            put_pgdir(mm);
ffffffffc0204c74:	854e                	mv	a0,s3
ffffffffc0204c76:	a96ff0ef          	jal	ra,ffffffffc0203f0c <put_pgdir>
            mm_destroy(mm);
ffffffffc0204c7a:	854e                	mv	a0,s3
ffffffffc0204c7c:	bc1fe0ef          	jal	ra,ffffffffc020383c <mm_destroy>
ffffffffc0204c80:	b31d                	j	ffffffffc02049a6 <do_execve+0x92>
            vm_flags |= VM_WRITE;
ffffffffc0204c82:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204c86:	f78d                	bnez	a5,ffffffffc0204bb0 <do_execve+0x29c>
            perm |= (PTE_W | PTE_R);
ffffffffc0204c88:	4bdd                	li	s7,23
ffffffffc0204c8a:	bf0d                	j	ffffffffc0204bbc <do_execve+0x2a8>
        end = ph->p_va + ph->p_memsz;
ffffffffc0204c8c:	0109b903          	ld	s2,16(s3)
ffffffffc0204c90:	0289b683          	ld	a3,40(s3)
ffffffffc0204c94:	9936                	add	s2,s2,a3
        if (start < la)
ffffffffc0204c96:	075dff63          	bgeu	s11,s5,ffffffffc0204d14 <do_execve+0x400>
            if (start == end)
ffffffffc0204c9a:	ddb903e3          	beq	s2,s11,ffffffffc0204a60 <do_execve+0x14c>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204c9e:	6505                	lui	a0,0x1
ffffffffc0204ca0:	956e                	add	a0,a0,s11
ffffffffc0204ca2:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0204ca6:	41b90a33          	sub	s4,s2,s11
            if (end < la)
ffffffffc0204caa:	0d597863          	bgeu	s2,s5,ffffffffc0204d7a <do_execve+0x466>
    return page - pages + nbase;
ffffffffc0204cae:	000d3683          	ld	a3,0(s10)
ffffffffc0204cb2:	000cb583          	ld	a1,0(s9)
    return KADDR(page2pa(page));
ffffffffc0204cb6:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0204cb8:	40d406b3          	sub	a3,s0,a3
ffffffffc0204cbc:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204cbe:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0204cc2:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0204cc4:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204cc8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204cca:	0cc5f163          	bgeu	a1,a2,ffffffffc0204d8c <do_execve+0x478>
ffffffffc0204cce:	000a6617          	auipc	a2,0xa6
ffffffffc0204cd2:	bb263603          	ld	a2,-1102(a2) # ffffffffc02aa880 <va_pa_offset>
ffffffffc0204cd6:	96b2                	add	a3,a3,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0204cd8:	4581                	li	a1,0
ffffffffc0204cda:	8652                	mv	a2,s4
ffffffffc0204cdc:	9536                	add	a0,a0,a3
ffffffffc0204cde:	2ef000ef          	jal	ra,ffffffffc02057cc <memset>
            start += size;
ffffffffc0204ce2:	01ba0733          	add	a4,s4,s11
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0204ce6:	03597463          	bgeu	s2,s5,ffffffffc0204d0e <do_execve+0x3fa>
ffffffffc0204cea:	d6e90be3          	beq	s2,a4,ffffffffc0204a60 <do_execve+0x14c>
ffffffffc0204cee:	00002697          	auipc	a3,0x2
ffffffffc0204cf2:	6e268693          	addi	a3,a3,1762 # ffffffffc02073d0 <default_pmm_manager+0xd98>
ffffffffc0204cf6:	00001617          	auipc	a2,0x1
ffffffffc0204cfa:	59260613          	addi	a2,a2,1426 # ffffffffc0206288 <commands+0x828>
ffffffffc0204cfe:	2c600593          	li	a1,710
ffffffffc0204d02:	00002517          	auipc	a0,0x2
ffffffffc0204d06:	3be50513          	addi	a0,a0,958 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc0204d0a:	f84fb0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc0204d0e:	ff5710e3          	bne	a4,s5,ffffffffc0204cee <do_execve+0x3da>
ffffffffc0204d12:	8dd6                	mv	s11,s5
ffffffffc0204d14:	000a6a17          	auipc	s4,0xa6
ffffffffc0204d18:	b6ca0a13          	addi	s4,s4,-1172 # ffffffffc02aa880 <va_pa_offset>
        while (start < end)
ffffffffc0204d1c:	052de763          	bltu	s11,s2,ffffffffc0204d6a <do_execve+0x456>
ffffffffc0204d20:	b381                	j	ffffffffc0204a60 <do_execve+0x14c>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204d22:	6785                	lui	a5,0x1
ffffffffc0204d24:	415d8533          	sub	a0,s11,s5
ffffffffc0204d28:	9abe                	add	s5,s5,a5
ffffffffc0204d2a:	41ba8633          	sub	a2,s5,s11
            if (end < la)
ffffffffc0204d2e:	01597463          	bgeu	s2,s5,ffffffffc0204d36 <do_execve+0x422>
                size -= la - end;
ffffffffc0204d32:	41b90633          	sub	a2,s2,s11
    return page - pages + nbase;
ffffffffc0204d36:	000d3683          	ld	a3,0(s10)
ffffffffc0204d3a:	000cb803          	ld	a6,0(s9)
    return KADDR(page2pa(page));
ffffffffc0204d3e:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0204d40:	40d406b3          	sub	a3,s0,a3
ffffffffc0204d44:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204d46:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204d4a:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0204d4c:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204d50:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204d52:	02b87d63          	bgeu	a6,a1,ffffffffc0204d8c <do_execve+0x478>
ffffffffc0204d56:	000a3803          	ld	a6,0(s4)
            start += size;
ffffffffc0204d5a:	9db2                	add	s11,s11,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0204d5c:	4581                	li	a1,0
ffffffffc0204d5e:	96c2                	add	a3,a3,a6
ffffffffc0204d60:	9536                	add	a0,a0,a3
ffffffffc0204d62:	26b000ef          	jal	ra,ffffffffc02057cc <memset>
        while (start < end)
ffffffffc0204d66:	cf2dfde3          	bgeu	s11,s2,ffffffffc0204a60 <do_execve+0x14c>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204d6a:	6c88                	ld	a0,24(s1)
ffffffffc0204d6c:	865e                	mv	a2,s7
ffffffffc0204d6e:	85d6                	mv	a1,s5
ffffffffc0204d70:	8a7fe0ef          	jal	ra,ffffffffc0203616 <pgdir_alloc_page>
ffffffffc0204d74:	842a                	mv	s0,a0
ffffffffc0204d76:	f555                	bnez	a0,ffffffffc0204d22 <do_execve+0x40e>
ffffffffc0204d78:	b5c5                	j	ffffffffc0204c58 <do_execve+0x344>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204d7a:	41ba8a33          	sub	s4,s5,s11
ffffffffc0204d7e:	bf05                	j	ffffffffc0204cae <do_execve+0x39a>
        return -E_INVAL;
ffffffffc0204d80:	5a75                	li	s4,-3
ffffffffc0204d82:	b3ed                	j	ffffffffc0204b6c <do_execve+0x258>
        while (start < end)
ffffffffc0204d84:	896e                	mv	s2,s11
ffffffffc0204d86:	b729                	j	ffffffffc0204c90 <do_execve+0x37c>
            ret = -E_INVAL_ELF;
ffffffffc0204d88:	5a61                	li	s4,-8
ffffffffc0204d8a:	bdc1                	j	ffffffffc0204c5a <do_execve+0x346>
ffffffffc0204d8c:	00002617          	auipc	a2,0x2
ffffffffc0204d90:	8e460613          	addi	a2,a2,-1820 # ffffffffc0206670 <default_pmm_manager+0x38>
ffffffffc0204d94:	07100593          	li	a1,113
ffffffffc0204d98:	00002517          	auipc	a0,0x2
ffffffffc0204d9c:	90050513          	addi	a0,a0,-1792 # ffffffffc0206698 <default_pmm_manager+0x60>
ffffffffc0204da0:	eeefb0ef          	jal	ra,ffffffffc020048e <__panic>
    lsatp(PADDR(mm->pgdir));
ffffffffc0204da4:	00002617          	auipc	a2,0x2
ffffffffc0204da8:	97460613          	addi	a2,a2,-1676 # ffffffffc0206718 <default_pmm_manager+0xe0>
ffffffffc0204dac:	2e800593          	li	a1,744
ffffffffc0204db0:	00002517          	auipc	a0,0x2
ffffffffc0204db4:	31050513          	addi	a0,a0,784 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc0204db8:	ed6fb0ef          	jal	ra,ffffffffc020048e <__panic>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204dbc:	00002617          	auipc	a2,0x2
ffffffffc0204dc0:	95c60613          	addi	a2,a2,-1700 # ffffffffc0206718 <default_pmm_manager+0xe0>
ffffffffc0204dc4:	2e600593          	li	a1,742
ffffffffc0204dc8:	00002517          	auipc	a0,0x2
ffffffffc0204dcc:	2f850513          	addi	a0,a0,760 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc0204dd0:	ebefb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204dd4:	00002697          	auipc	a3,0x2
ffffffffc0204dd8:	71468693          	addi	a3,a3,1812 # ffffffffc02074e8 <default_pmm_manager+0xeb0>
ffffffffc0204ddc:	00001617          	auipc	a2,0x1
ffffffffc0204de0:	4ac60613          	addi	a2,a2,1196 # ffffffffc0206288 <commands+0x828>
ffffffffc0204de4:	2e000593          	li	a1,736
ffffffffc0204de8:	00002517          	auipc	a0,0x2
ffffffffc0204dec:	2d850513          	addi	a0,a0,728 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc0204df0:	e9efb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204df4:	00002697          	auipc	a3,0x2
ffffffffc0204df8:	6ac68693          	addi	a3,a3,1708 # ffffffffc02074a0 <default_pmm_manager+0xe68>
ffffffffc0204dfc:	00001617          	auipc	a2,0x1
ffffffffc0204e00:	48c60613          	addi	a2,a2,1164 # ffffffffc0206288 <commands+0x828>
ffffffffc0204e04:	2df00593          	li	a1,735
ffffffffc0204e08:	00002517          	auipc	a0,0x2
ffffffffc0204e0c:	2b850513          	addi	a0,a0,696 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc0204e10:	e7efb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204e14:	00002697          	auipc	a3,0x2
ffffffffc0204e18:	64468693          	addi	a3,a3,1604 # ffffffffc0207458 <default_pmm_manager+0xe20>
ffffffffc0204e1c:	00001617          	auipc	a2,0x1
ffffffffc0204e20:	46c60613          	addi	a2,a2,1132 # ffffffffc0206288 <commands+0x828>
ffffffffc0204e24:	2de00593          	li	a1,734
ffffffffc0204e28:	00002517          	auipc	a0,0x2
ffffffffc0204e2c:	29850513          	addi	a0,a0,664 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc0204e30:	e5efb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204e34:	00002697          	auipc	a3,0x2
ffffffffc0204e38:	5dc68693          	addi	a3,a3,1500 # ffffffffc0207410 <default_pmm_manager+0xdd8>
ffffffffc0204e3c:	00001617          	auipc	a2,0x1
ffffffffc0204e40:	44c60613          	addi	a2,a2,1100 # ffffffffc0206288 <commands+0x828>
ffffffffc0204e44:	2dd00593          	li	a1,733
ffffffffc0204e48:	00002517          	auipc	a0,0x2
ffffffffc0204e4c:	27850513          	addi	a0,a0,632 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc0204e50:	e3efb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204e54 <do_yield>:
    current->need_resched = 1;
ffffffffc0204e54:	000a6797          	auipc	a5,0xa6
ffffffffc0204e58:	a347b783          	ld	a5,-1484(a5) # ffffffffc02aa888 <current>
ffffffffc0204e5c:	4705                	li	a4,1
ffffffffc0204e5e:	ef98                	sd	a4,24(a5)
}
ffffffffc0204e60:	4501                	li	a0,0
ffffffffc0204e62:	8082                	ret

ffffffffc0204e64 <do_wait>:
{
ffffffffc0204e64:	1101                	addi	sp,sp,-32
ffffffffc0204e66:	e822                	sd	s0,16(sp)
ffffffffc0204e68:	e426                	sd	s1,8(sp)
ffffffffc0204e6a:	ec06                	sd	ra,24(sp)
ffffffffc0204e6c:	842e                	mv	s0,a1
ffffffffc0204e6e:	84aa                	mv	s1,a0
    if (code_store != NULL)
ffffffffc0204e70:	c999                	beqz	a1,ffffffffc0204e86 <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0204e72:	000a6797          	auipc	a5,0xa6
ffffffffc0204e76:	a167b783          	ld	a5,-1514(a5) # ffffffffc02aa888 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0204e7a:	7788                	ld	a0,40(a5)
ffffffffc0204e7c:	4685                	li	a3,1
ffffffffc0204e7e:	4611                	li	a2,4
ffffffffc0204e80:	ef3fe0ef          	jal	ra,ffffffffc0203d72 <user_mem_check>
ffffffffc0204e84:	c909                	beqz	a0,ffffffffc0204e96 <do_wait+0x32>
ffffffffc0204e86:	85a2                	mv	a1,s0
}
ffffffffc0204e88:	6442                	ld	s0,16(sp)
ffffffffc0204e8a:	60e2                	ld	ra,24(sp)
ffffffffc0204e8c:	8526                	mv	a0,s1
ffffffffc0204e8e:	64a2                	ld	s1,8(sp)
ffffffffc0204e90:	6105                	addi	sp,sp,32
ffffffffc0204e92:	f8cff06f          	j	ffffffffc020461e <do_wait.part.0>
ffffffffc0204e96:	60e2                	ld	ra,24(sp)
ffffffffc0204e98:	6442                	ld	s0,16(sp)
ffffffffc0204e9a:	64a2                	ld	s1,8(sp)
ffffffffc0204e9c:	5575                	li	a0,-3
ffffffffc0204e9e:	6105                	addi	sp,sp,32
ffffffffc0204ea0:	8082                	ret

ffffffffc0204ea2 <do_kill>:
{
ffffffffc0204ea2:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID)
ffffffffc0204ea4:	6789                	lui	a5,0x2
{
ffffffffc0204ea6:	e406                	sd	ra,8(sp)
ffffffffc0204ea8:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID)
ffffffffc0204eaa:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204eae:	17f9                	addi	a5,a5,-2
ffffffffc0204eb0:	02e7e963          	bltu	a5,a4,ffffffffc0204ee2 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204eb4:	842a                	mv	s0,a0
ffffffffc0204eb6:	45a9                	li	a1,10
ffffffffc0204eb8:	2501                	sext.w	a0,a0
ffffffffc0204eba:	46c000ef          	jal	ra,ffffffffc0205326 <hash32>
ffffffffc0204ebe:	02051793          	slli	a5,a0,0x20
ffffffffc0204ec2:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204ec6:	000a2797          	auipc	a5,0xa2
ffffffffc0204eca:	94a78793          	addi	a5,a5,-1718 # ffffffffc02a6810 <hash_list>
ffffffffc0204ece:	953e                	add	a0,a0,a5
ffffffffc0204ed0:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list)
ffffffffc0204ed2:	a029                	j	ffffffffc0204edc <do_kill+0x3a>
            if (proc->pid == pid)
ffffffffc0204ed4:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0204ed8:	00870b63          	beq	a4,s0,ffffffffc0204eee <do_kill+0x4c>
ffffffffc0204edc:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204ede:	fef51be3          	bne	a0,a5,ffffffffc0204ed4 <do_kill+0x32>
    return -E_INVAL;
ffffffffc0204ee2:	5475                	li	s0,-3
}
ffffffffc0204ee4:	60a2                	ld	ra,8(sp)
ffffffffc0204ee6:	8522                	mv	a0,s0
ffffffffc0204ee8:	6402                	ld	s0,0(sp)
ffffffffc0204eea:	0141                	addi	sp,sp,16
ffffffffc0204eec:	8082                	ret
        if (!(proc->flags & PF_EXITING))
ffffffffc0204eee:	fd87a703          	lw	a4,-40(a5)
ffffffffc0204ef2:	00177693          	andi	a3,a4,1
ffffffffc0204ef6:	e295                	bnez	a3,ffffffffc0204f1a <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0204ef8:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0204efa:	00176713          	ori	a4,a4,1
ffffffffc0204efe:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0204f02:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0204f04:	fe06d0e3          	bgez	a3,ffffffffc0204ee4 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0204f08:	f2878513          	addi	a0,a5,-216
ffffffffc0204f0c:	22e000ef          	jal	ra,ffffffffc020513a <wakeup_proc>
}
ffffffffc0204f10:	60a2                	ld	ra,8(sp)
ffffffffc0204f12:	8522                	mv	a0,s0
ffffffffc0204f14:	6402                	ld	s0,0(sp)
ffffffffc0204f16:	0141                	addi	sp,sp,16
ffffffffc0204f18:	8082                	ret
        return -E_KILLED;
ffffffffc0204f1a:	545d                	li	s0,-9
ffffffffc0204f1c:	b7e1                	j	ffffffffc0204ee4 <do_kill+0x42>

ffffffffc0204f1e <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc0204f1e:	1101                	addi	sp,sp,-32
ffffffffc0204f20:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0204f22:	000a6797          	auipc	a5,0xa6
ffffffffc0204f26:	8ee78793          	addi	a5,a5,-1810 # ffffffffc02aa810 <proc_list>
ffffffffc0204f2a:	ec06                	sd	ra,24(sp)
ffffffffc0204f2c:	e822                	sd	s0,16(sp)
ffffffffc0204f2e:	e04a                	sd	s2,0(sp)
ffffffffc0204f30:	000a2497          	auipc	s1,0xa2
ffffffffc0204f34:	8e048493          	addi	s1,s1,-1824 # ffffffffc02a6810 <hash_list>
ffffffffc0204f38:	e79c                	sd	a5,8(a5)
ffffffffc0204f3a:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0204f3c:	000a6717          	auipc	a4,0xa6
ffffffffc0204f40:	8d470713          	addi	a4,a4,-1836 # ffffffffc02aa810 <proc_list>
ffffffffc0204f44:	87a6                	mv	a5,s1
ffffffffc0204f46:	e79c                	sd	a5,8(a5)
ffffffffc0204f48:	e39c                	sd	a5,0(a5)
ffffffffc0204f4a:	07c1                	addi	a5,a5,16
ffffffffc0204f4c:	fef71de3          	bne	a4,a5,ffffffffc0204f46 <proc_init+0x28>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc0204f50:	ebffe0ef          	jal	ra,ffffffffc0203e0e <alloc_proc>
ffffffffc0204f54:	000a6917          	auipc	s2,0xa6
ffffffffc0204f58:	93c90913          	addi	s2,s2,-1732 # ffffffffc02aa890 <idleproc>
ffffffffc0204f5c:	00a93023          	sd	a0,0(s2)
ffffffffc0204f60:	0e050f63          	beqz	a0,ffffffffc020505e <proc_init+0x140>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0204f64:	4789                	li	a5,2
ffffffffc0204f66:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204f68:	00003797          	auipc	a5,0x3
ffffffffc0204f6c:	09878793          	addi	a5,a5,152 # ffffffffc0208000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f70:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204f74:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0204f76:	4785                	li	a5,1
ffffffffc0204f78:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f7a:	4641                	li	a2,16
ffffffffc0204f7c:	4581                	li	a1,0
ffffffffc0204f7e:	8522                	mv	a0,s0
ffffffffc0204f80:	04d000ef          	jal	ra,ffffffffc02057cc <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f84:	463d                	li	a2,15
ffffffffc0204f86:	00002597          	auipc	a1,0x2
ffffffffc0204f8a:	63258593          	addi	a1,a1,1586 # ffffffffc02075b8 <default_pmm_manager+0xf80>
ffffffffc0204f8e:	8522                	mv	a0,s0
ffffffffc0204f90:	04f000ef          	jal	ra,ffffffffc02057de <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process++;
ffffffffc0204f94:	000a6717          	auipc	a4,0xa6
ffffffffc0204f98:	90c70713          	addi	a4,a4,-1780 # ffffffffc02aa8a0 <nr_process>
ffffffffc0204f9c:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0204f9e:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0204fa2:	4601                	li	a2,0
    nr_process++;
ffffffffc0204fa4:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0204fa6:	4581                	li	a1,0
ffffffffc0204fa8:	00000517          	auipc	a0,0x0
ffffffffc0204fac:	84850513          	addi	a0,a0,-1976 # ffffffffc02047f0 <init_main>
    nr_process++;
ffffffffc0204fb0:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0204fb2:	000a6797          	auipc	a5,0xa6
ffffffffc0204fb6:	8cd7bb23          	sd	a3,-1834(a5) # ffffffffc02aa888 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0204fba:	ccaff0ef          	jal	ra,ffffffffc0204484 <kernel_thread>
ffffffffc0204fbe:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc0204fc0:	08a05363          	blez	a0,ffffffffc0205046 <proc_init+0x128>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204fc4:	6789                	lui	a5,0x2
ffffffffc0204fc6:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204fca:	17f9                	addi	a5,a5,-2
ffffffffc0204fcc:	2501                	sext.w	a0,a0
ffffffffc0204fce:	02e7e363          	bltu	a5,a4,ffffffffc0204ff4 <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204fd2:	45a9                	li	a1,10
ffffffffc0204fd4:	352000ef          	jal	ra,ffffffffc0205326 <hash32>
ffffffffc0204fd8:	02051793          	slli	a5,a0,0x20
ffffffffc0204fdc:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0204fe0:	96a6                	add	a3,a3,s1
ffffffffc0204fe2:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0204fe4:	a029                	j	ffffffffc0204fee <proc_init+0xd0>
            if (proc->pid == pid)
ffffffffc0204fe6:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c94>
ffffffffc0204fea:	04870b63          	beq	a4,s0,ffffffffc0205040 <proc_init+0x122>
    return listelm->next;
ffffffffc0204fee:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204ff0:	fef69be3          	bne	a3,a5,ffffffffc0204fe6 <proc_init+0xc8>
    return NULL;
ffffffffc0204ff4:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ff6:	0b478493          	addi	s1,a5,180
ffffffffc0204ffa:	4641                	li	a2,16
ffffffffc0204ffc:	4581                	li	a1,0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0204ffe:	000a6417          	auipc	s0,0xa6
ffffffffc0205002:	89a40413          	addi	s0,s0,-1894 # ffffffffc02aa898 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205006:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0205008:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020500a:	7c2000ef          	jal	ra,ffffffffc02057cc <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020500e:	463d                	li	a2,15
ffffffffc0205010:	00002597          	auipc	a1,0x2
ffffffffc0205014:	5d058593          	addi	a1,a1,1488 # ffffffffc02075e0 <default_pmm_manager+0xfa8>
ffffffffc0205018:	8526                	mv	a0,s1
ffffffffc020501a:	7c4000ef          	jal	ra,ffffffffc02057de <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020501e:	00093783          	ld	a5,0(s2)
ffffffffc0205022:	cbb5                	beqz	a5,ffffffffc0205096 <proc_init+0x178>
ffffffffc0205024:	43dc                	lw	a5,4(a5)
ffffffffc0205026:	eba5                	bnez	a5,ffffffffc0205096 <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205028:	601c                	ld	a5,0(s0)
ffffffffc020502a:	c7b1                	beqz	a5,ffffffffc0205076 <proc_init+0x158>
ffffffffc020502c:	43d8                	lw	a4,4(a5)
ffffffffc020502e:	4785                	li	a5,1
ffffffffc0205030:	04f71363          	bne	a4,a5,ffffffffc0205076 <proc_init+0x158>
}
ffffffffc0205034:	60e2                	ld	ra,24(sp)
ffffffffc0205036:	6442                	ld	s0,16(sp)
ffffffffc0205038:	64a2                	ld	s1,8(sp)
ffffffffc020503a:	6902                	ld	s2,0(sp)
ffffffffc020503c:	6105                	addi	sp,sp,32
ffffffffc020503e:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205040:	f2878793          	addi	a5,a5,-216
ffffffffc0205044:	bf4d                	j	ffffffffc0204ff6 <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0205046:	00002617          	auipc	a2,0x2
ffffffffc020504a:	57a60613          	addi	a2,a2,1402 # ffffffffc02075c0 <default_pmm_manager+0xf88>
ffffffffc020504e:	40800593          	li	a1,1032
ffffffffc0205052:	00002517          	auipc	a0,0x2
ffffffffc0205056:	06e50513          	addi	a0,a0,110 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc020505a:	c34fb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc020505e:	00002617          	auipc	a2,0x2
ffffffffc0205062:	54260613          	addi	a2,a2,1346 # ffffffffc02075a0 <default_pmm_manager+0xf68>
ffffffffc0205066:	3f900593          	li	a1,1017
ffffffffc020506a:	00002517          	auipc	a0,0x2
ffffffffc020506e:	05650513          	addi	a0,a0,86 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc0205072:	c1cfb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205076:	00002697          	auipc	a3,0x2
ffffffffc020507a:	59a68693          	addi	a3,a3,1434 # ffffffffc0207610 <default_pmm_manager+0xfd8>
ffffffffc020507e:	00001617          	auipc	a2,0x1
ffffffffc0205082:	20a60613          	addi	a2,a2,522 # ffffffffc0206288 <commands+0x828>
ffffffffc0205086:	40f00593          	li	a1,1039
ffffffffc020508a:	00002517          	auipc	a0,0x2
ffffffffc020508e:	03650513          	addi	a0,a0,54 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc0205092:	bfcfb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205096:	00002697          	auipc	a3,0x2
ffffffffc020509a:	55268693          	addi	a3,a3,1362 # ffffffffc02075e8 <default_pmm_manager+0xfb0>
ffffffffc020509e:	00001617          	auipc	a2,0x1
ffffffffc02050a2:	1ea60613          	addi	a2,a2,490 # ffffffffc0206288 <commands+0x828>
ffffffffc02050a6:	40e00593          	li	a1,1038
ffffffffc02050aa:	00002517          	auipc	a0,0x2
ffffffffc02050ae:	01650513          	addi	a0,a0,22 # ffffffffc02070c0 <default_pmm_manager+0xa88>
ffffffffc02050b2:	bdcfb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02050b6 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc02050b6:	1141                	addi	sp,sp,-16
ffffffffc02050b8:	e022                	sd	s0,0(sp)
ffffffffc02050ba:	e406                	sd	ra,8(sp)
ffffffffc02050bc:	000a5417          	auipc	s0,0xa5
ffffffffc02050c0:	7cc40413          	addi	s0,s0,1996 # ffffffffc02aa888 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc02050c4:	6018                	ld	a4,0(s0)
ffffffffc02050c6:	6f1c                	ld	a5,24(a4)
ffffffffc02050c8:	dffd                	beqz	a5,ffffffffc02050c6 <cpu_idle+0x10>
        {
            schedule();
ffffffffc02050ca:	0f0000ef          	jal	ra,ffffffffc02051ba <schedule>
ffffffffc02050ce:	bfdd                	j	ffffffffc02050c4 <cpu_idle+0xe>

ffffffffc02050d0 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc02050d0:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc02050d4:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc02050d8:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc02050da:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc02050dc:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc02050e0:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc02050e4:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc02050e8:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc02050ec:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc02050f0:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc02050f4:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc02050f8:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc02050fc:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0205100:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0205104:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0205108:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc020510c:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc020510e:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0205110:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0205114:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0205118:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc020511c:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0205120:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0205124:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0205128:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc020512c:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0205130:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0205134:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0205138:	8082                	ret

ffffffffc020513a <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020513a:	4118                	lw	a4,0(a0)
{
ffffffffc020513c:	1101                	addi	sp,sp,-32
ffffffffc020513e:	ec06                	sd	ra,24(sp)
ffffffffc0205140:	e822                	sd	s0,16(sp)
ffffffffc0205142:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205144:	478d                	li	a5,3
ffffffffc0205146:	04f70b63          	beq	a4,a5,ffffffffc020519c <wakeup_proc+0x62>
ffffffffc020514a:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020514c:	100027f3          	csrr	a5,sstatus
ffffffffc0205150:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205152:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0205154:	ef9d                	bnez	a5,ffffffffc0205192 <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
ffffffffc0205156:	4789                	li	a5,2
ffffffffc0205158:	02f70163          	beq	a4,a5,ffffffffc020517a <wakeup_proc+0x40>
        {
            proc->state = PROC_RUNNABLE;
ffffffffc020515c:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc020515e:	0e042623          	sw	zero,236(s0)
    if (flag)
ffffffffc0205162:	e491                	bnez	s1,ffffffffc020516e <wakeup_proc+0x34>
        {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205164:	60e2                	ld	ra,24(sp)
ffffffffc0205166:	6442                	ld	s0,16(sp)
ffffffffc0205168:	64a2                	ld	s1,8(sp)
ffffffffc020516a:	6105                	addi	sp,sp,32
ffffffffc020516c:	8082                	ret
ffffffffc020516e:	6442                	ld	s0,16(sp)
ffffffffc0205170:	60e2                	ld	ra,24(sp)
ffffffffc0205172:	64a2                	ld	s1,8(sp)
ffffffffc0205174:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205176:	839fb06f          	j	ffffffffc02009ae <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc020517a:	00002617          	auipc	a2,0x2
ffffffffc020517e:	4f660613          	addi	a2,a2,1270 # ffffffffc0207670 <default_pmm_manager+0x1038>
ffffffffc0205182:	45d1                	li	a1,20
ffffffffc0205184:	00002517          	auipc	a0,0x2
ffffffffc0205188:	4d450513          	addi	a0,a0,1236 # ffffffffc0207658 <default_pmm_manager+0x1020>
ffffffffc020518c:	b6afb0ef          	jal	ra,ffffffffc02004f6 <__warn>
ffffffffc0205190:	bfc9                	j	ffffffffc0205162 <wakeup_proc+0x28>
        intr_disable();
ffffffffc0205192:	823fb0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        if (proc->state != PROC_RUNNABLE)
ffffffffc0205196:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc0205198:	4485                	li	s1,1
ffffffffc020519a:	bf75                	j	ffffffffc0205156 <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020519c:	00002697          	auipc	a3,0x2
ffffffffc02051a0:	49c68693          	addi	a3,a3,1180 # ffffffffc0207638 <default_pmm_manager+0x1000>
ffffffffc02051a4:	00001617          	auipc	a2,0x1
ffffffffc02051a8:	0e460613          	addi	a2,a2,228 # ffffffffc0206288 <commands+0x828>
ffffffffc02051ac:	45a5                	li	a1,9
ffffffffc02051ae:	00002517          	auipc	a0,0x2
ffffffffc02051b2:	4aa50513          	addi	a0,a0,1194 # ffffffffc0207658 <default_pmm_manager+0x1020>
ffffffffc02051b6:	ad8fb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02051ba <schedule>:

void schedule(void)
{
ffffffffc02051ba:	1141                	addi	sp,sp,-16
ffffffffc02051bc:	e406                	sd	ra,8(sp)
ffffffffc02051be:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02051c0:	100027f3          	csrr	a5,sstatus
ffffffffc02051c4:	8b89                	andi	a5,a5,2
ffffffffc02051c6:	4401                	li	s0,0
ffffffffc02051c8:	efbd                	bnez	a5,ffffffffc0205246 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02051ca:	000a5897          	auipc	a7,0xa5
ffffffffc02051ce:	6be8b883          	ld	a7,1726(a7) # ffffffffc02aa888 <current>
ffffffffc02051d2:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02051d6:	000a5517          	auipc	a0,0xa5
ffffffffc02051da:	6ba53503          	ld	a0,1722(a0) # ffffffffc02aa890 <idleproc>
ffffffffc02051de:	04a88e63          	beq	a7,a0,ffffffffc020523a <schedule+0x80>
ffffffffc02051e2:	0c888693          	addi	a3,a7,200
ffffffffc02051e6:	000a5617          	auipc	a2,0xa5
ffffffffc02051ea:	62a60613          	addi	a2,a2,1578 # ffffffffc02aa810 <proc_list>
        le = last;
ffffffffc02051ee:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc02051f0:	4581                	li	a1,0
        do
        {
            if ((le = list_next(le)) != &proc_list)
            {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE)
ffffffffc02051f2:	4809                	li	a6,2
ffffffffc02051f4:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list)
ffffffffc02051f6:	00c78863          	beq	a5,a2,ffffffffc0205206 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE)
ffffffffc02051fa:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02051fe:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE)
ffffffffc0205202:	03070163          	beq	a4,a6,ffffffffc0205224 <schedule+0x6a>
                {
                    break;
                }
            }
        } while (le != last);
ffffffffc0205206:	fef697e3          	bne	a3,a5,ffffffffc02051f4 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc020520a:	ed89                	bnez	a1,ffffffffc0205224 <schedule+0x6a>
        {
            next = idleproc;
        }
        next->runs++;
ffffffffc020520c:	451c                	lw	a5,8(a0)
ffffffffc020520e:	2785                	addiw	a5,a5,1
ffffffffc0205210:	c51c                	sw	a5,8(a0)
        if (next != current)
ffffffffc0205212:	00a88463          	beq	a7,a0,ffffffffc020521a <schedule+0x60>
        {
            proc_run(next);
ffffffffc0205216:	e2bfe0ef          	jal	ra,ffffffffc0204040 <proc_run>
    if (flag)
ffffffffc020521a:	e819                	bnez	s0,ffffffffc0205230 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020521c:	60a2                	ld	ra,8(sp)
ffffffffc020521e:	6402                	ld	s0,0(sp)
ffffffffc0205220:	0141                	addi	sp,sp,16
ffffffffc0205222:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc0205224:	4198                	lw	a4,0(a1)
ffffffffc0205226:	4789                	li	a5,2
ffffffffc0205228:	fef712e3          	bne	a4,a5,ffffffffc020520c <schedule+0x52>
ffffffffc020522c:	852e                	mv	a0,a1
ffffffffc020522e:	bff9                	j	ffffffffc020520c <schedule+0x52>
}
ffffffffc0205230:	6402                	ld	s0,0(sp)
ffffffffc0205232:	60a2                	ld	ra,8(sp)
ffffffffc0205234:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0205236:	f78fb06f          	j	ffffffffc02009ae <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020523a:	000a5617          	auipc	a2,0xa5
ffffffffc020523e:	5d660613          	addi	a2,a2,1494 # ffffffffc02aa810 <proc_list>
ffffffffc0205242:	86b2                	mv	a3,a2
ffffffffc0205244:	b76d                	j	ffffffffc02051ee <schedule+0x34>
        intr_disable();
ffffffffc0205246:	f6efb0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc020524a:	4405                	li	s0,1
ffffffffc020524c:	bfbd                	j	ffffffffc02051ca <schedule+0x10>

ffffffffc020524e <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc020524e:	000a5797          	auipc	a5,0xa5
ffffffffc0205252:	63a7b783          	ld	a5,1594(a5) # ffffffffc02aa888 <current>
}
ffffffffc0205256:	43c8                	lw	a0,4(a5)
ffffffffc0205258:	8082                	ret

ffffffffc020525a <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc020525a:	4501                	li	a0,0
ffffffffc020525c:	8082                	ret

ffffffffc020525e <sys_putc>:
    cputchar(c);
ffffffffc020525e:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0205260:	1141                	addi	sp,sp,-16
ffffffffc0205262:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0205264:	f67fa0ef          	jal	ra,ffffffffc02001ca <cputchar>
}
ffffffffc0205268:	60a2                	ld	ra,8(sp)
ffffffffc020526a:	4501                	li	a0,0
ffffffffc020526c:	0141                	addi	sp,sp,16
ffffffffc020526e:	8082                	ret

ffffffffc0205270 <sys_kill>:
    return do_kill(pid);
ffffffffc0205270:	4108                	lw	a0,0(a0)
ffffffffc0205272:	c31ff06f          	j	ffffffffc0204ea2 <do_kill>

ffffffffc0205276 <sys_yield>:
    return do_yield();
ffffffffc0205276:	bdfff06f          	j	ffffffffc0204e54 <do_yield>

ffffffffc020527a <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc020527a:	6d14                	ld	a3,24(a0)
ffffffffc020527c:	6910                	ld	a2,16(a0)
ffffffffc020527e:	650c                	ld	a1,8(a0)
ffffffffc0205280:	6108                	ld	a0,0(a0)
ffffffffc0205282:	e92ff06f          	j	ffffffffc0204914 <do_execve>

ffffffffc0205286 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0205286:	650c                	ld	a1,8(a0)
ffffffffc0205288:	4108                	lw	a0,0(a0)
ffffffffc020528a:	bdbff06f          	j	ffffffffc0204e64 <do_wait>

ffffffffc020528e <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc020528e:	000a5797          	auipc	a5,0xa5
ffffffffc0205292:	5fa7b783          	ld	a5,1530(a5) # ffffffffc02aa888 <current>
ffffffffc0205296:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0205298:	4501                	li	a0,0
ffffffffc020529a:	6a0c                	ld	a1,16(a2)
ffffffffc020529c:	e27fe06f          	j	ffffffffc02040c2 <do_fork>

ffffffffc02052a0 <sys_exit>:
    return do_exit(error_code);
ffffffffc02052a0:	4108                	lw	a0,0(a0)
ffffffffc02052a2:	a32ff06f          	j	ffffffffc02044d4 <do_exit>

ffffffffc02052a6 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc02052a6:	715d                	addi	sp,sp,-80
ffffffffc02052a8:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02052aa:	000a5497          	auipc	s1,0xa5
ffffffffc02052ae:	5de48493          	addi	s1,s1,1502 # ffffffffc02aa888 <current>
ffffffffc02052b2:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02052b4:	e0a2                	sd	s0,64(sp)
ffffffffc02052b6:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02052b8:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02052ba:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02052bc:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02052be:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02052c2:	0327ee63          	bltu	a5,s2,ffffffffc02052fe <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc02052c6:	00391713          	slli	a4,s2,0x3
ffffffffc02052ca:	00002797          	auipc	a5,0x2
ffffffffc02052ce:	40e78793          	addi	a5,a5,1038 # ffffffffc02076d8 <syscalls>
ffffffffc02052d2:	97ba                	add	a5,a5,a4
ffffffffc02052d4:	639c                	ld	a5,0(a5)
ffffffffc02052d6:	c785                	beqz	a5,ffffffffc02052fe <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc02052d8:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc02052da:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc02052dc:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc02052de:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc02052e0:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc02052e2:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc02052e4:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc02052e6:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02052e8:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc02052ea:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02052ec:	0028                	addi	a0,sp,8
ffffffffc02052ee:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc02052f0:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02052f2:	e828                	sd	a0,80(s0)
}
ffffffffc02052f4:	6406                	ld	s0,64(sp)
ffffffffc02052f6:	74e2                	ld	s1,56(sp)
ffffffffc02052f8:	7942                	ld	s2,48(sp)
ffffffffc02052fa:	6161                	addi	sp,sp,80
ffffffffc02052fc:	8082                	ret
    print_trapframe(tf);
ffffffffc02052fe:	8522                	mv	a0,s0
ffffffffc0205300:	8a5fb0ef          	jal	ra,ffffffffc0200ba4 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0205304:	609c                	ld	a5,0(s1)
ffffffffc0205306:	86ca                	mv	a3,s2
ffffffffc0205308:	00002617          	auipc	a2,0x2
ffffffffc020530c:	38860613          	addi	a2,a2,904 # ffffffffc0207690 <default_pmm_manager+0x1058>
ffffffffc0205310:	43d8                	lw	a4,4(a5)
ffffffffc0205312:	06200593          	li	a1,98
ffffffffc0205316:	0b478793          	addi	a5,a5,180
ffffffffc020531a:	00002517          	auipc	a0,0x2
ffffffffc020531e:	3a650513          	addi	a0,a0,934 # ffffffffc02076c0 <default_pmm_manager+0x1088>
ffffffffc0205322:	96cfb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0205326 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0205326:	9e3707b7          	lui	a5,0x9e370
ffffffffc020532a:	2785                	addiw	a5,a5,1
ffffffffc020532c:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0205330:	02000793          	li	a5,32
ffffffffc0205334:	9f8d                	subw	a5,a5,a1
}
ffffffffc0205336:	00f5553b          	srlw	a0,a0,a5
ffffffffc020533a:	8082                	ret

ffffffffc020533c <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020533c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205340:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0205342:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205346:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0205348:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020534c:	f022                	sd	s0,32(sp)
ffffffffc020534e:	ec26                	sd	s1,24(sp)
ffffffffc0205350:	e84a                	sd	s2,16(sp)
ffffffffc0205352:	f406                	sd	ra,40(sp)
ffffffffc0205354:	e44e                	sd	s3,8(sp)
ffffffffc0205356:	84aa                	mv	s1,a0
ffffffffc0205358:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020535a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020535e:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0205360:	03067e63          	bgeu	a2,a6,ffffffffc020539c <printnum+0x60>
ffffffffc0205364:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0205366:	00805763          	blez	s0,ffffffffc0205374 <printnum+0x38>
ffffffffc020536a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020536c:	85ca                	mv	a1,s2
ffffffffc020536e:	854e                	mv	a0,s3
ffffffffc0205370:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0205372:	fc65                	bnez	s0,ffffffffc020536a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205374:	1a02                	slli	s4,s4,0x20
ffffffffc0205376:	00002797          	auipc	a5,0x2
ffffffffc020537a:	46278793          	addi	a5,a5,1122 # ffffffffc02077d8 <syscalls+0x100>
ffffffffc020537e:	020a5a13          	srli	s4,s4,0x20
ffffffffc0205382:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0205384:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205386:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020538a:	70a2                	ld	ra,40(sp)
ffffffffc020538c:	69a2                	ld	s3,8(sp)
ffffffffc020538e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205390:	85ca                	mv	a1,s2
ffffffffc0205392:	87a6                	mv	a5,s1
}
ffffffffc0205394:	6942                	ld	s2,16(sp)
ffffffffc0205396:	64e2                	ld	s1,24(sp)
ffffffffc0205398:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020539a:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020539c:	03065633          	divu	a2,a2,a6
ffffffffc02053a0:	8722                	mv	a4,s0
ffffffffc02053a2:	f9bff0ef          	jal	ra,ffffffffc020533c <printnum>
ffffffffc02053a6:	b7f9                	j	ffffffffc0205374 <printnum+0x38>

ffffffffc02053a8 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02053a8:	7119                	addi	sp,sp,-128
ffffffffc02053aa:	f4a6                	sd	s1,104(sp)
ffffffffc02053ac:	f0ca                	sd	s2,96(sp)
ffffffffc02053ae:	ecce                	sd	s3,88(sp)
ffffffffc02053b0:	e8d2                	sd	s4,80(sp)
ffffffffc02053b2:	e4d6                	sd	s5,72(sp)
ffffffffc02053b4:	e0da                	sd	s6,64(sp)
ffffffffc02053b6:	fc5e                	sd	s7,56(sp)
ffffffffc02053b8:	f06a                	sd	s10,32(sp)
ffffffffc02053ba:	fc86                	sd	ra,120(sp)
ffffffffc02053bc:	f8a2                	sd	s0,112(sp)
ffffffffc02053be:	f862                	sd	s8,48(sp)
ffffffffc02053c0:	f466                	sd	s9,40(sp)
ffffffffc02053c2:	ec6e                	sd	s11,24(sp)
ffffffffc02053c4:	892a                	mv	s2,a0
ffffffffc02053c6:	84ae                	mv	s1,a1
ffffffffc02053c8:	8d32                	mv	s10,a2
ffffffffc02053ca:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02053cc:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02053d0:	5b7d                	li	s6,-1
ffffffffc02053d2:	00002a97          	auipc	s5,0x2
ffffffffc02053d6:	432a8a93          	addi	s5,s5,1074 # ffffffffc0207804 <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02053da:	00002b97          	auipc	s7,0x2
ffffffffc02053de:	646b8b93          	addi	s7,s7,1606 # ffffffffc0207a20 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02053e2:	000d4503          	lbu	a0,0(s10)
ffffffffc02053e6:	001d0413          	addi	s0,s10,1
ffffffffc02053ea:	01350a63          	beq	a0,s3,ffffffffc02053fe <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02053ee:	c121                	beqz	a0,ffffffffc020542e <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02053f0:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02053f2:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02053f4:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02053f6:	fff44503          	lbu	a0,-1(s0)
ffffffffc02053fa:	ff351ae3          	bne	a0,s3,ffffffffc02053ee <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02053fe:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0205402:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0205406:	4c81                	li	s9,0
ffffffffc0205408:	4881                	li	a7,0
        width = precision = -1;
ffffffffc020540a:	5c7d                	li	s8,-1
ffffffffc020540c:	5dfd                	li	s11,-1
ffffffffc020540e:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0205412:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205414:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0205418:	0ff5f593          	zext.b	a1,a1
ffffffffc020541c:	00140d13          	addi	s10,s0,1
ffffffffc0205420:	04b56263          	bltu	a0,a1,ffffffffc0205464 <vprintfmt+0xbc>
ffffffffc0205424:	058a                	slli	a1,a1,0x2
ffffffffc0205426:	95d6                	add	a1,a1,s5
ffffffffc0205428:	4194                	lw	a3,0(a1)
ffffffffc020542a:	96d6                	add	a3,a3,s5
ffffffffc020542c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020542e:	70e6                	ld	ra,120(sp)
ffffffffc0205430:	7446                	ld	s0,112(sp)
ffffffffc0205432:	74a6                	ld	s1,104(sp)
ffffffffc0205434:	7906                	ld	s2,96(sp)
ffffffffc0205436:	69e6                	ld	s3,88(sp)
ffffffffc0205438:	6a46                	ld	s4,80(sp)
ffffffffc020543a:	6aa6                	ld	s5,72(sp)
ffffffffc020543c:	6b06                	ld	s6,64(sp)
ffffffffc020543e:	7be2                	ld	s7,56(sp)
ffffffffc0205440:	7c42                	ld	s8,48(sp)
ffffffffc0205442:	7ca2                	ld	s9,40(sp)
ffffffffc0205444:	7d02                	ld	s10,32(sp)
ffffffffc0205446:	6de2                	ld	s11,24(sp)
ffffffffc0205448:	6109                	addi	sp,sp,128
ffffffffc020544a:	8082                	ret
            padc = '0';
ffffffffc020544c:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020544e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205452:	846a                	mv	s0,s10
ffffffffc0205454:	00140d13          	addi	s10,s0,1
ffffffffc0205458:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020545c:	0ff5f593          	zext.b	a1,a1
ffffffffc0205460:	fcb572e3          	bgeu	a0,a1,ffffffffc0205424 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0205464:	85a6                	mv	a1,s1
ffffffffc0205466:	02500513          	li	a0,37
ffffffffc020546a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020546c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0205470:	8d22                	mv	s10,s0
ffffffffc0205472:	f73788e3          	beq	a5,s3,ffffffffc02053e2 <vprintfmt+0x3a>
ffffffffc0205476:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020547a:	1d7d                	addi	s10,s10,-1
ffffffffc020547c:	ff379de3          	bne	a5,s3,ffffffffc0205476 <vprintfmt+0xce>
ffffffffc0205480:	b78d                	j	ffffffffc02053e2 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0205482:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0205486:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020548a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020548c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0205490:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0205494:	02d86463          	bltu	a6,a3,ffffffffc02054bc <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0205498:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020549c:	002c169b          	slliw	a3,s8,0x2
ffffffffc02054a0:	0186873b          	addw	a4,a3,s8
ffffffffc02054a4:	0017171b          	slliw	a4,a4,0x1
ffffffffc02054a8:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02054aa:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02054ae:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02054b0:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02054b4:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02054b8:	fed870e3          	bgeu	a6,a3,ffffffffc0205498 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02054bc:	f40ddce3          	bgez	s11,ffffffffc0205414 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02054c0:	8de2                	mv	s11,s8
ffffffffc02054c2:	5c7d                	li	s8,-1
ffffffffc02054c4:	bf81                	j	ffffffffc0205414 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02054c6:	fffdc693          	not	a3,s11
ffffffffc02054ca:	96fd                	srai	a3,a3,0x3f
ffffffffc02054cc:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02054d0:	00144603          	lbu	a2,1(s0)
ffffffffc02054d4:	2d81                	sext.w	s11,s11
ffffffffc02054d6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02054d8:	bf35                	j	ffffffffc0205414 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02054da:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02054de:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02054e2:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02054e4:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02054e6:	bfd9                	j	ffffffffc02054bc <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02054e8:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02054ea:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02054ee:	01174463          	blt	a4,a7,ffffffffc02054f6 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02054f2:	1a088e63          	beqz	a7,ffffffffc02056ae <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02054f6:	000a3603          	ld	a2,0(s4)
ffffffffc02054fa:	46c1                	li	a3,16
ffffffffc02054fc:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02054fe:	2781                	sext.w	a5,a5
ffffffffc0205500:	876e                	mv	a4,s11
ffffffffc0205502:	85a6                	mv	a1,s1
ffffffffc0205504:	854a                	mv	a0,s2
ffffffffc0205506:	e37ff0ef          	jal	ra,ffffffffc020533c <printnum>
            break;
ffffffffc020550a:	bde1                	j	ffffffffc02053e2 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020550c:	000a2503          	lw	a0,0(s4)
ffffffffc0205510:	85a6                	mv	a1,s1
ffffffffc0205512:	0a21                	addi	s4,s4,8
ffffffffc0205514:	9902                	jalr	s2
            break;
ffffffffc0205516:	b5f1                	j	ffffffffc02053e2 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0205518:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020551a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020551e:	01174463          	blt	a4,a7,ffffffffc0205526 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0205522:	18088163          	beqz	a7,ffffffffc02056a4 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0205526:	000a3603          	ld	a2,0(s4)
ffffffffc020552a:	46a9                	li	a3,10
ffffffffc020552c:	8a2e                	mv	s4,a1
ffffffffc020552e:	bfc1                	j	ffffffffc02054fe <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205530:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0205534:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205536:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0205538:	bdf1                	j	ffffffffc0205414 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020553a:	85a6                	mv	a1,s1
ffffffffc020553c:	02500513          	li	a0,37
ffffffffc0205540:	9902                	jalr	s2
            break;
ffffffffc0205542:	b545                	j	ffffffffc02053e2 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205544:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0205548:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020554a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020554c:	b5e1                	j	ffffffffc0205414 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020554e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205550:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205554:	01174463          	blt	a4,a7,ffffffffc020555c <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0205558:	14088163          	beqz	a7,ffffffffc020569a <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020555c:	000a3603          	ld	a2,0(s4)
ffffffffc0205560:	46a1                	li	a3,8
ffffffffc0205562:	8a2e                	mv	s4,a1
ffffffffc0205564:	bf69                	j	ffffffffc02054fe <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0205566:	03000513          	li	a0,48
ffffffffc020556a:	85a6                	mv	a1,s1
ffffffffc020556c:	e03e                	sd	a5,0(sp)
ffffffffc020556e:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0205570:	85a6                	mv	a1,s1
ffffffffc0205572:	07800513          	li	a0,120
ffffffffc0205576:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0205578:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020557a:	6782                	ld	a5,0(sp)
ffffffffc020557c:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020557e:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0205582:	bfb5                	j	ffffffffc02054fe <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0205584:	000a3403          	ld	s0,0(s4)
ffffffffc0205588:	008a0713          	addi	a4,s4,8
ffffffffc020558c:	e03a                	sd	a4,0(sp)
ffffffffc020558e:	14040263          	beqz	s0,ffffffffc02056d2 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0205592:	0fb05763          	blez	s11,ffffffffc0205680 <vprintfmt+0x2d8>
ffffffffc0205596:	02d00693          	li	a3,45
ffffffffc020559a:	0cd79163          	bne	a5,a3,ffffffffc020565c <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020559e:	00044783          	lbu	a5,0(s0)
ffffffffc02055a2:	0007851b          	sext.w	a0,a5
ffffffffc02055a6:	cf85                	beqz	a5,ffffffffc02055de <vprintfmt+0x236>
ffffffffc02055a8:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02055ac:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02055b0:	000c4563          	bltz	s8,ffffffffc02055ba <vprintfmt+0x212>
ffffffffc02055b4:	3c7d                	addiw	s8,s8,-1
ffffffffc02055b6:	036c0263          	beq	s8,s6,ffffffffc02055da <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02055ba:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02055bc:	0e0c8e63          	beqz	s9,ffffffffc02056b8 <vprintfmt+0x310>
ffffffffc02055c0:	3781                	addiw	a5,a5,-32
ffffffffc02055c2:	0ef47b63          	bgeu	s0,a5,ffffffffc02056b8 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02055c6:	03f00513          	li	a0,63
ffffffffc02055ca:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02055cc:	000a4783          	lbu	a5,0(s4)
ffffffffc02055d0:	3dfd                	addiw	s11,s11,-1
ffffffffc02055d2:	0a05                	addi	s4,s4,1
ffffffffc02055d4:	0007851b          	sext.w	a0,a5
ffffffffc02055d8:	ffe1                	bnez	a5,ffffffffc02055b0 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02055da:	01b05963          	blez	s11,ffffffffc02055ec <vprintfmt+0x244>
ffffffffc02055de:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02055e0:	85a6                	mv	a1,s1
ffffffffc02055e2:	02000513          	li	a0,32
ffffffffc02055e6:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02055e8:	fe0d9be3          	bnez	s11,ffffffffc02055de <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02055ec:	6a02                	ld	s4,0(sp)
ffffffffc02055ee:	bbd5                	j	ffffffffc02053e2 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02055f0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02055f2:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02055f6:	01174463          	blt	a4,a7,ffffffffc02055fe <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02055fa:	08088d63          	beqz	a7,ffffffffc0205694 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02055fe:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0205602:	0a044d63          	bltz	s0,ffffffffc02056bc <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0205606:	8622                	mv	a2,s0
ffffffffc0205608:	8a66                	mv	s4,s9
ffffffffc020560a:	46a9                	li	a3,10
ffffffffc020560c:	bdcd                	j	ffffffffc02054fe <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc020560e:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205612:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0205614:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0205616:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020561a:	8fb5                	xor	a5,a5,a3
ffffffffc020561c:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205620:	02d74163          	blt	a4,a3,ffffffffc0205642 <vprintfmt+0x29a>
ffffffffc0205624:	00369793          	slli	a5,a3,0x3
ffffffffc0205628:	97de                	add	a5,a5,s7
ffffffffc020562a:	639c                	ld	a5,0(a5)
ffffffffc020562c:	cb99                	beqz	a5,ffffffffc0205642 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020562e:	86be                	mv	a3,a5
ffffffffc0205630:	00000617          	auipc	a2,0x0
ffffffffc0205634:	1f060613          	addi	a2,a2,496 # ffffffffc0205820 <etext+0x2a>
ffffffffc0205638:	85a6                	mv	a1,s1
ffffffffc020563a:	854a                	mv	a0,s2
ffffffffc020563c:	0ce000ef          	jal	ra,ffffffffc020570a <printfmt>
ffffffffc0205640:	b34d                	j	ffffffffc02053e2 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0205642:	00002617          	auipc	a2,0x2
ffffffffc0205646:	1b660613          	addi	a2,a2,438 # ffffffffc02077f8 <syscalls+0x120>
ffffffffc020564a:	85a6                	mv	a1,s1
ffffffffc020564c:	854a                	mv	a0,s2
ffffffffc020564e:	0bc000ef          	jal	ra,ffffffffc020570a <printfmt>
ffffffffc0205652:	bb41                	j	ffffffffc02053e2 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0205654:	00002417          	auipc	s0,0x2
ffffffffc0205658:	19c40413          	addi	s0,s0,412 # ffffffffc02077f0 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020565c:	85e2                	mv	a1,s8
ffffffffc020565e:	8522                	mv	a0,s0
ffffffffc0205660:	e43e                	sd	a5,8(sp)
ffffffffc0205662:	0e2000ef          	jal	ra,ffffffffc0205744 <strnlen>
ffffffffc0205666:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020566a:	01b05b63          	blez	s11,ffffffffc0205680 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020566e:	67a2                	ld	a5,8(sp)
ffffffffc0205670:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205674:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0205676:	85a6                	mv	a1,s1
ffffffffc0205678:	8552                	mv	a0,s4
ffffffffc020567a:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020567c:	fe0d9ce3          	bnez	s11,ffffffffc0205674 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205680:	00044783          	lbu	a5,0(s0)
ffffffffc0205684:	00140a13          	addi	s4,s0,1
ffffffffc0205688:	0007851b          	sext.w	a0,a5
ffffffffc020568c:	d3a5                	beqz	a5,ffffffffc02055ec <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020568e:	05e00413          	li	s0,94
ffffffffc0205692:	bf39                	j	ffffffffc02055b0 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0205694:	000a2403          	lw	s0,0(s4)
ffffffffc0205698:	b7ad                	j	ffffffffc0205602 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020569a:	000a6603          	lwu	a2,0(s4)
ffffffffc020569e:	46a1                	li	a3,8
ffffffffc02056a0:	8a2e                	mv	s4,a1
ffffffffc02056a2:	bdb1                	j	ffffffffc02054fe <vprintfmt+0x156>
ffffffffc02056a4:	000a6603          	lwu	a2,0(s4)
ffffffffc02056a8:	46a9                	li	a3,10
ffffffffc02056aa:	8a2e                	mv	s4,a1
ffffffffc02056ac:	bd89                	j	ffffffffc02054fe <vprintfmt+0x156>
ffffffffc02056ae:	000a6603          	lwu	a2,0(s4)
ffffffffc02056b2:	46c1                	li	a3,16
ffffffffc02056b4:	8a2e                	mv	s4,a1
ffffffffc02056b6:	b5a1                	j	ffffffffc02054fe <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02056b8:	9902                	jalr	s2
ffffffffc02056ba:	bf09                	j	ffffffffc02055cc <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02056bc:	85a6                	mv	a1,s1
ffffffffc02056be:	02d00513          	li	a0,45
ffffffffc02056c2:	e03e                	sd	a5,0(sp)
ffffffffc02056c4:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02056c6:	6782                	ld	a5,0(sp)
ffffffffc02056c8:	8a66                	mv	s4,s9
ffffffffc02056ca:	40800633          	neg	a2,s0
ffffffffc02056ce:	46a9                	li	a3,10
ffffffffc02056d0:	b53d                	j	ffffffffc02054fe <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02056d2:	03b05163          	blez	s11,ffffffffc02056f4 <vprintfmt+0x34c>
ffffffffc02056d6:	02d00693          	li	a3,45
ffffffffc02056da:	f6d79de3          	bne	a5,a3,ffffffffc0205654 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02056de:	00002417          	auipc	s0,0x2
ffffffffc02056e2:	11240413          	addi	s0,s0,274 # ffffffffc02077f0 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02056e6:	02800793          	li	a5,40
ffffffffc02056ea:	02800513          	li	a0,40
ffffffffc02056ee:	00140a13          	addi	s4,s0,1
ffffffffc02056f2:	bd6d                	j	ffffffffc02055ac <vprintfmt+0x204>
ffffffffc02056f4:	00002a17          	auipc	s4,0x2
ffffffffc02056f8:	0fda0a13          	addi	s4,s4,253 # ffffffffc02077f1 <syscalls+0x119>
ffffffffc02056fc:	02800513          	li	a0,40
ffffffffc0205700:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205704:	05e00413          	li	s0,94
ffffffffc0205708:	b565                	j	ffffffffc02055b0 <vprintfmt+0x208>

ffffffffc020570a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020570a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020570c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205710:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205712:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205714:	ec06                	sd	ra,24(sp)
ffffffffc0205716:	f83a                	sd	a4,48(sp)
ffffffffc0205718:	fc3e                	sd	a5,56(sp)
ffffffffc020571a:	e0c2                	sd	a6,64(sp)
ffffffffc020571c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020571e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205720:	c89ff0ef          	jal	ra,ffffffffc02053a8 <vprintfmt>
}
ffffffffc0205724:	60e2                	ld	ra,24(sp)
ffffffffc0205726:	6161                	addi	sp,sp,80
ffffffffc0205728:	8082                	ret

ffffffffc020572a <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020572a:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc020572e:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0205730:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0205732:	cb81                	beqz	a5,ffffffffc0205742 <strlen+0x18>
        cnt ++;
ffffffffc0205734:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0205736:	00a707b3          	add	a5,a4,a0
ffffffffc020573a:	0007c783          	lbu	a5,0(a5)
ffffffffc020573e:	fbfd                	bnez	a5,ffffffffc0205734 <strlen+0xa>
ffffffffc0205740:	8082                	ret
    }
    return cnt;
}
ffffffffc0205742:	8082                	ret

ffffffffc0205744 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0205744:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205746:	e589                	bnez	a1,ffffffffc0205750 <strnlen+0xc>
ffffffffc0205748:	a811                	j	ffffffffc020575c <strnlen+0x18>
        cnt ++;
ffffffffc020574a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020574c:	00f58863          	beq	a1,a5,ffffffffc020575c <strnlen+0x18>
ffffffffc0205750:	00f50733          	add	a4,a0,a5
ffffffffc0205754:	00074703          	lbu	a4,0(a4)
ffffffffc0205758:	fb6d                	bnez	a4,ffffffffc020574a <strnlen+0x6>
ffffffffc020575a:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020575c:	852e                	mv	a0,a1
ffffffffc020575e:	8082                	ret

ffffffffc0205760 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0205760:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0205762:	0005c703          	lbu	a4,0(a1)
ffffffffc0205766:	0785                	addi	a5,a5,1
ffffffffc0205768:	0585                	addi	a1,a1,1
ffffffffc020576a:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020576e:	fb75                	bnez	a4,ffffffffc0205762 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0205770:	8082                	ret

ffffffffc0205772 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205772:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205776:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020577a:	cb89                	beqz	a5,ffffffffc020578c <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc020577c:	0505                	addi	a0,a0,1
ffffffffc020577e:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205780:	fee789e3          	beq	a5,a4,ffffffffc0205772 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205784:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0205788:	9d19                	subw	a0,a0,a4
ffffffffc020578a:	8082                	ret
ffffffffc020578c:	4501                	li	a0,0
ffffffffc020578e:	bfed                	j	ffffffffc0205788 <strcmp+0x16>

ffffffffc0205790 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205790:	c20d                	beqz	a2,ffffffffc02057b2 <strncmp+0x22>
ffffffffc0205792:	962e                	add	a2,a2,a1
ffffffffc0205794:	a031                	j	ffffffffc02057a0 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0205796:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205798:	00e79a63          	bne	a5,a4,ffffffffc02057ac <strncmp+0x1c>
ffffffffc020579c:	00b60b63          	beq	a2,a1,ffffffffc02057b2 <strncmp+0x22>
ffffffffc02057a0:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc02057a4:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02057a6:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02057aa:	f7f5                	bnez	a5,ffffffffc0205796 <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02057ac:	40e7853b          	subw	a0,a5,a4
}
ffffffffc02057b0:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02057b2:	4501                	li	a0,0
ffffffffc02057b4:	8082                	ret

ffffffffc02057b6 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02057b6:	00054783          	lbu	a5,0(a0)
ffffffffc02057ba:	c799                	beqz	a5,ffffffffc02057c8 <strchr+0x12>
        if (*s == c) {
ffffffffc02057bc:	00f58763          	beq	a1,a5,ffffffffc02057ca <strchr+0x14>
    while (*s != '\0') {
ffffffffc02057c0:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02057c4:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02057c6:	fbfd                	bnez	a5,ffffffffc02057bc <strchr+0x6>
    }
    return NULL;
ffffffffc02057c8:	4501                	li	a0,0
}
ffffffffc02057ca:	8082                	ret

ffffffffc02057cc <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02057cc:	ca01                	beqz	a2,ffffffffc02057dc <memset+0x10>
ffffffffc02057ce:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02057d0:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02057d2:	0785                	addi	a5,a5,1
ffffffffc02057d4:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02057d8:	fec79de3          	bne	a5,a2,ffffffffc02057d2 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02057dc:	8082                	ret

ffffffffc02057de <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02057de:	ca19                	beqz	a2,ffffffffc02057f4 <memcpy+0x16>
ffffffffc02057e0:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02057e2:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02057e4:	0005c703          	lbu	a4,0(a1)
ffffffffc02057e8:	0585                	addi	a1,a1,1
ffffffffc02057ea:	0785                	addi	a5,a5,1
ffffffffc02057ec:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02057f0:	fec59ae3          	bne	a1,a2,ffffffffc02057e4 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02057f4:	8082                	ret
