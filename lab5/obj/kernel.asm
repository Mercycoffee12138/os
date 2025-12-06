
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
ffffffffc020004e:	20650513          	addi	a0,a0,518 # ffffffffc02a6250 <buf>
ffffffffc0200052:	000aa617          	auipc	a2,0xaa
ffffffffc0200056:	6aa60613          	addi	a2,a2,1706 # ffffffffc02aa6fc <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	744050ef          	jal	ra,ffffffffc02057a6 <memset>
    dtb_init();
ffffffffc0200066:	598000ef          	jal	ra,ffffffffc02005fe <dtb_init>
    cons_init(); // init the console
ffffffffc020006a:	522000ef          	jal	ra,ffffffffc020058c <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006e:	00005597          	auipc	a1,0x5
ffffffffc0200072:	76258593          	addi	a1,a1,1890 # ffffffffc02057d0 <etext>
ffffffffc0200076:	00005517          	auipc	a0,0x5
ffffffffc020007a:	77a50513          	addi	a0,a0,1914 # ffffffffc02057f0 <etext+0x20>
ffffffffc020007e:	116000ef          	jal	ra,ffffffffc0200194 <cprintf>

    print_kerninfo();
ffffffffc0200082:	19a000ef          	jal	ra,ffffffffc020021c <print_kerninfo>

    // grade_backtrace();

    pmm_init(); // init physical memory management
ffffffffc0200086:	71c020ef          	jal	ra,ffffffffc02027a2 <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	131000ef          	jal	ra,ffffffffc02009ba <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	12f000ef          	jal	ra,ffffffffc02009bc <idt_init>

    vmm_init();  // init virtual memory management
ffffffffc0200092:	209030ef          	jal	ra,ffffffffc0203a9a <vmm_init>
    proc_init(); // init process table
ffffffffc0200096:	63b040ef          	jal	ra,ffffffffc0204ed0 <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009a:	4a0000ef          	jal	ra,ffffffffc020053a <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc020009e:	111000ef          	jal	ra,ffffffffc02009ae <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a2:	7c7040ef          	jal	ra,ffffffffc0205068 <cpu_idle>

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
ffffffffc02000c0:	73c50513          	addi	a0,a0,1852 # ffffffffc02057f8 <etext+0x28>
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
ffffffffc02000d6:	17eb8b93          	addi	s7,s7,382 # ffffffffc02a6250 <buf>
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
ffffffffc0200132:	12250513          	addi	a0,a0,290 # ffffffffc02a6250 <buf>
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
ffffffffc0200188:	1fa050ef          	jal	ra,ffffffffc0205382 <vprintfmt>
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
ffffffffc02001be:	1c4050ef          	jal	ra,ffffffffc0205382 <vprintfmt>
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
ffffffffc0200222:	5e250513          	addi	a0,a0,1506 # ffffffffc0205800 <etext+0x30>
{
ffffffffc0200226:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200228:	f6dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020022c:	00000597          	auipc	a1,0x0
ffffffffc0200230:	e1e58593          	addi	a1,a1,-482 # ffffffffc020004a <kern_init>
ffffffffc0200234:	00005517          	auipc	a0,0x5
ffffffffc0200238:	5ec50513          	addi	a0,a0,1516 # ffffffffc0205820 <etext+0x50>
ffffffffc020023c:	f59ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200240:	00005597          	auipc	a1,0x5
ffffffffc0200244:	59058593          	addi	a1,a1,1424 # ffffffffc02057d0 <etext>
ffffffffc0200248:	00005517          	auipc	a0,0x5
ffffffffc020024c:	5f850513          	addi	a0,a0,1528 # ffffffffc0205840 <etext+0x70>
ffffffffc0200250:	f45ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200254:	000a6597          	auipc	a1,0xa6
ffffffffc0200258:	ffc58593          	addi	a1,a1,-4 # ffffffffc02a6250 <buf>
ffffffffc020025c:	00005517          	auipc	a0,0x5
ffffffffc0200260:	60450513          	addi	a0,a0,1540 # ffffffffc0205860 <etext+0x90>
ffffffffc0200264:	f31ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200268:	000aa597          	auipc	a1,0xaa
ffffffffc020026c:	49458593          	addi	a1,a1,1172 # ffffffffc02aa6fc <end>
ffffffffc0200270:	00005517          	auipc	a0,0x5
ffffffffc0200274:	61050513          	addi	a0,a0,1552 # ffffffffc0205880 <etext+0xb0>
ffffffffc0200278:	f1dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020027c:	000ab597          	auipc	a1,0xab
ffffffffc0200280:	87f58593          	addi	a1,a1,-1921 # ffffffffc02aaafb <end+0x3ff>
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
ffffffffc02002a2:	60250513          	addi	a0,a0,1538 # ffffffffc02058a0 <etext+0xd0>
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
ffffffffc02002b0:	62460613          	addi	a2,a2,1572 # ffffffffc02058d0 <etext+0x100>
ffffffffc02002b4:	04f00593          	li	a1,79
ffffffffc02002b8:	00005517          	auipc	a0,0x5
ffffffffc02002bc:	63050513          	addi	a0,a0,1584 # ffffffffc02058e8 <etext+0x118>
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
ffffffffc02002cc:	63860613          	addi	a2,a2,1592 # ffffffffc0205900 <etext+0x130>
ffffffffc02002d0:	00005597          	auipc	a1,0x5
ffffffffc02002d4:	65058593          	addi	a1,a1,1616 # ffffffffc0205920 <etext+0x150>
ffffffffc02002d8:	00005517          	auipc	a0,0x5
ffffffffc02002dc:	65050513          	addi	a0,a0,1616 # ffffffffc0205928 <etext+0x158>
{
ffffffffc02002e0:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e2:	eb3ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02002e6:	00005617          	auipc	a2,0x5
ffffffffc02002ea:	65260613          	addi	a2,a2,1618 # ffffffffc0205938 <etext+0x168>
ffffffffc02002ee:	00005597          	auipc	a1,0x5
ffffffffc02002f2:	67258593          	addi	a1,a1,1650 # ffffffffc0205960 <etext+0x190>
ffffffffc02002f6:	00005517          	auipc	a0,0x5
ffffffffc02002fa:	63250513          	addi	a0,a0,1586 # ffffffffc0205928 <etext+0x158>
ffffffffc02002fe:	e97ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200302:	00005617          	auipc	a2,0x5
ffffffffc0200306:	66e60613          	addi	a2,a2,1646 # ffffffffc0205970 <etext+0x1a0>
ffffffffc020030a:	00005597          	auipc	a1,0x5
ffffffffc020030e:	68658593          	addi	a1,a1,1670 # ffffffffc0205990 <etext+0x1c0>
ffffffffc0200312:	00005517          	auipc	a0,0x5
ffffffffc0200316:	61650513          	addi	a0,a0,1558 # ffffffffc0205928 <etext+0x158>
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
ffffffffc0200350:	65450513          	addi	a0,a0,1620 # ffffffffc02059a0 <etext+0x1d0>
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
ffffffffc0200372:	65a50513          	addi	a0,a0,1626 # ffffffffc02059c8 <etext+0x1f8>
ffffffffc0200376:	e1fff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    if (tf != NULL)
ffffffffc020037a:	000b8563          	beqz	s7,ffffffffc0200384 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020037e:	855e                	mv	a0,s7
ffffffffc0200380:	025000ef          	jal	ra,ffffffffc0200ba4 <print_trapframe>
ffffffffc0200384:	00005c17          	auipc	s8,0x5
ffffffffc0200388:	6b4c0c13          	addi	s8,s8,1716 # ffffffffc0205a38 <commands>
        if ((buf = readline("K> ")) != NULL)
ffffffffc020038c:	00005917          	auipc	s2,0x5
ffffffffc0200390:	66490913          	addi	s2,s2,1636 # ffffffffc02059f0 <etext+0x220>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200394:	00005497          	auipc	s1,0x5
ffffffffc0200398:	66448493          	addi	s1,s1,1636 # ffffffffc02059f8 <etext+0x228>
        if (argc == MAXARGS - 1)
ffffffffc020039c:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020039e:	00005b17          	auipc	s6,0x5
ffffffffc02003a2:	662b0b13          	addi	s6,s6,1634 # ffffffffc0205a00 <etext+0x230>
        argv[argc++] = buf;
ffffffffc02003a6:	00005a17          	auipc	s4,0x5
ffffffffc02003aa:	57aa0a13          	addi	s4,s4,1402 # ffffffffc0205920 <etext+0x150>
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
ffffffffc02003cc:	670d0d13          	addi	s10,s10,1648 # ffffffffc0205a38 <commands>
        argv[argc++] = buf;
ffffffffc02003d0:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc02003d2:	4401                	li	s0,0
ffffffffc02003d4:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc02003d6:	376050ef          	jal	ra,ffffffffc020574c <strcmp>
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
ffffffffc02003ea:	362050ef          	jal	ra,ffffffffc020574c <strcmp>
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
ffffffffc0200428:	368050ef          	jal	ra,ffffffffc0205790 <strchr>
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
ffffffffc0200466:	32a050ef          	jal	ra,ffffffffc0205790 <strchr>
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
ffffffffc0200484:	5a050513          	addi	a0,a0,1440 # ffffffffc0205a20 <etext+0x250>
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
ffffffffc0200492:	1ea30313          	addi	t1,t1,490 # ffffffffc02aa678 <is_panic>
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
ffffffffc02004c0:	5c450513          	addi	a0,a0,1476 # ffffffffc0205a80 <commands+0x48>
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
ffffffffc02004d6:	71e50513          	addi	a0,a0,1822 # ffffffffc0206bf0 <default_pmm_manager+0x578>
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
ffffffffc020050a:	59a50513          	addi	a0,a0,1434 # ffffffffc0205aa0 <commands+0x68>
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
ffffffffc020052a:	6ca50513          	addi	a0,a0,1738 # ffffffffc0206bf0 <default_pmm_manager+0x578>
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
ffffffffc020053c:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd588>
ffffffffc0200540:	000aa717          	auipc	a4,0xaa
ffffffffc0200544:	14f73423          	sd	a5,328(a4) # ffffffffc02aa688 <timebase>
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
ffffffffc0200564:	56050513          	addi	a0,a0,1376 # ffffffffc0205ac0 <commands+0x88>
    ticks = 0;
ffffffffc0200568:	000aa797          	auipc	a5,0xaa
ffffffffc020056c:	1007bc23          	sd	zero,280(a5) # ffffffffc02aa680 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200570:	b115                	j	ffffffffc0200194 <cprintf>

ffffffffc0200572 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200572:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200576:	000aa797          	auipc	a5,0xaa
ffffffffc020057a:	1127b783          	ld	a5,274(a5) # ffffffffc02aa688 <timebase>
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
ffffffffc0200604:	4e050513          	addi	a0,a0,1248 # ffffffffc0205ae0 <commands+0xa8>
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
ffffffffc0200632:	4c250513          	addi	a0,a0,1218 # ffffffffc0205af0 <commands+0xb8>
ffffffffc0200636:	b5fff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020063a:	0000b417          	auipc	s0,0xb
ffffffffc020063e:	9ce40413          	addi	s0,s0,-1586 # ffffffffc020b008 <boot_dtb>
ffffffffc0200642:	600c                	ld	a1,0(s0)
ffffffffc0200644:	00005517          	auipc	a0,0x5
ffffffffc0200648:	4bc50513          	addi	a0,a0,1212 # ffffffffc0205b00 <commands+0xc8>
ffffffffc020064c:	b49ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200650:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200654:	00005517          	auipc	a0,0x5
ffffffffc0200658:	4c450513          	addi	a0,a0,1220 # ffffffffc0205b18 <commands+0xe0>
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
ffffffffc020069c:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfe357f1>
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
ffffffffc0200712:	45a90913          	addi	s2,s2,1114 # ffffffffc0205b68 <commands+0x130>
ffffffffc0200716:	49bd                	li	s3,15
        switch (token) {
ffffffffc0200718:	4d91                	li	s11,4
ffffffffc020071a:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020071c:	00005497          	auipc	s1,0x5
ffffffffc0200720:	44448493          	addi	s1,s1,1092 # ffffffffc0205b60 <commands+0x128>
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
ffffffffc0200774:	47050513          	addi	a0,a0,1136 # ffffffffc0205be0 <commands+0x1a8>
ffffffffc0200778:	a1dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc020077c:	00005517          	auipc	a0,0x5
ffffffffc0200780:	49c50513          	addi	a0,a0,1180 # ffffffffc0205c18 <commands+0x1e0>
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
ffffffffc02007c0:	37c50513          	addi	a0,a0,892 # ffffffffc0205b38 <commands+0x100>
}
ffffffffc02007c4:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02007c6:	b2f9                	j	ffffffffc0200194 <cprintf>
                int name_len = strlen(name);
ffffffffc02007c8:	8556                	mv	a0,s5
ffffffffc02007ca:	73b040ef          	jal	ra,ffffffffc0205704 <strlen>
ffffffffc02007ce:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02007d0:	4619                	li	a2,6
ffffffffc02007d2:	85a6                	mv	a1,s1
ffffffffc02007d4:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02007d6:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02007d8:	793040ef          	jal	ra,ffffffffc020576a <strncmp>
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
ffffffffc020086e:	6df040ef          	jal	ra,ffffffffc020574c <strcmp>
ffffffffc0200872:	66a2                	ld	a3,8(sp)
ffffffffc0200874:	f94d                	bnez	a0,ffffffffc0200826 <dtb_init+0x228>
ffffffffc0200876:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200826 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc020087a:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc020087e:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200882:	00005517          	auipc	a0,0x5
ffffffffc0200886:	2ee50513          	addi	a0,a0,750 # ffffffffc0205b70 <commands+0x138>
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
ffffffffc0200954:	24050513          	addi	a0,a0,576 # ffffffffc0205b90 <commands+0x158>
ffffffffc0200958:	83dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020095c:	014b5613          	srli	a2,s6,0x14
ffffffffc0200960:	85da                	mv	a1,s6
ffffffffc0200962:	00005517          	auipc	a0,0x5
ffffffffc0200966:	24650513          	addi	a0,a0,582 # ffffffffc0205ba8 <commands+0x170>
ffffffffc020096a:	82bff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc020096e:	008b05b3          	add	a1,s6,s0
ffffffffc0200972:	15fd                	addi	a1,a1,-1
ffffffffc0200974:	00005517          	auipc	a0,0x5
ffffffffc0200978:	25450513          	addi	a0,a0,596 # ffffffffc0205bc8 <commands+0x190>
ffffffffc020097c:	819ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("DTB init completed\n");
ffffffffc0200980:	00005517          	auipc	a0,0x5
ffffffffc0200984:	29850513          	addi	a0,a0,664 # ffffffffc0205c18 <commands+0x1e0>
        memory_base = mem_base;
ffffffffc0200988:	000aa797          	auipc	a5,0xaa
ffffffffc020098c:	d087b423          	sd	s0,-760(a5) # ffffffffc02aa690 <memory_base>
        memory_size = mem_size;
ffffffffc0200990:	000aa797          	auipc	a5,0xaa
ffffffffc0200994:	d167b423          	sd	s6,-760(a5) # ffffffffc02aa698 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc0200998:	b3f5                	j	ffffffffc0200784 <dtb_init+0x186>

ffffffffc020099a <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc020099a:	000aa517          	auipc	a0,0xaa
ffffffffc020099e:	cf653503          	ld	a0,-778(a0) # ffffffffc02aa690 <memory_base>
ffffffffc02009a2:	8082                	ret

ffffffffc02009a4 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc02009a4:	000aa517          	auipc	a0,0xaa
ffffffffc02009a8:	cf453503          	ld	a0,-780(a0) # ffffffffc02aa698 <memory_size>
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
ffffffffc02009c4:	51078793          	addi	a5,a5,1296 # ffffffffc0200ed0 <__alltraps>
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
ffffffffc02009e2:	25250513          	addi	a0,a0,594 # ffffffffc0205c30 <commands+0x1f8>
{
ffffffffc02009e6:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009e8:	facff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02009ec:	640c                	ld	a1,8(s0)
ffffffffc02009ee:	00005517          	auipc	a0,0x5
ffffffffc02009f2:	25a50513          	addi	a0,a0,602 # ffffffffc0205c48 <commands+0x210>
ffffffffc02009f6:	f9eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02009fa:	680c                	ld	a1,16(s0)
ffffffffc02009fc:	00005517          	auipc	a0,0x5
ffffffffc0200a00:	26450513          	addi	a0,a0,612 # ffffffffc0205c60 <commands+0x228>
ffffffffc0200a04:	f90ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200a08:	6c0c                	ld	a1,24(s0)
ffffffffc0200a0a:	00005517          	auipc	a0,0x5
ffffffffc0200a0e:	26e50513          	addi	a0,a0,622 # ffffffffc0205c78 <commands+0x240>
ffffffffc0200a12:	f82ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200a16:	700c                	ld	a1,32(s0)
ffffffffc0200a18:	00005517          	auipc	a0,0x5
ffffffffc0200a1c:	27850513          	addi	a0,a0,632 # ffffffffc0205c90 <commands+0x258>
ffffffffc0200a20:	f74ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200a24:	740c                	ld	a1,40(s0)
ffffffffc0200a26:	00005517          	auipc	a0,0x5
ffffffffc0200a2a:	28250513          	addi	a0,a0,642 # ffffffffc0205ca8 <commands+0x270>
ffffffffc0200a2e:	f66ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc0200a32:	780c                	ld	a1,48(s0)
ffffffffc0200a34:	00005517          	auipc	a0,0x5
ffffffffc0200a38:	28c50513          	addi	a0,a0,652 # ffffffffc0205cc0 <commands+0x288>
ffffffffc0200a3c:	f58ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200a40:	7c0c                	ld	a1,56(s0)
ffffffffc0200a42:	00005517          	auipc	a0,0x5
ffffffffc0200a46:	29650513          	addi	a0,a0,662 # ffffffffc0205cd8 <commands+0x2a0>
ffffffffc0200a4a:	f4aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200a4e:	602c                	ld	a1,64(s0)
ffffffffc0200a50:	00005517          	auipc	a0,0x5
ffffffffc0200a54:	2a050513          	addi	a0,a0,672 # ffffffffc0205cf0 <commands+0x2b8>
ffffffffc0200a58:	f3cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200a5c:	642c                	ld	a1,72(s0)
ffffffffc0200a5e:	00005517          	auipc	a0,0x5
ffffffffc0200a62:	2aa50513          	addi	a0,a0,682 # ffffffffc0205d08 <commands+0x2d0>
ffffffffc0200a66:	f2eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200a6a:	682c                	ld	a1,80(s0)
ffffffffc0200a6c:	00005517          	auipc	a0,0x5
ffffffffc0200a70:	2b450513          	addi	a0,a0,692 # ffffffffc0205d20 <commands+0x2e8>
ffffffffc0200a74:	f20ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200a78:	6c2c                	ld	a1,88(s0)
ffffffffc0200a7a:	00005517          	auipc	a0,0x5
ffffffffc0200a7e:	2be50513          	addi	a0,a0,702 # ffffffffc0205d38 <commands+0x300>
ffffffffc0200a82:	f12ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200a86:	702c                	ld	a1,96(s0)
ffffffffc0200a88:	00005517          	auipc	a0,0x5
ffffffffc0200a8c:	2c850513          	addi	a0,a0,712 # ffffffffc0205d50 <commands+0x318>
ffffffffc0200a90:	f04ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200a94:	742c                	ld	a1,104(s0)
ffffffffc0200a96:	00005517          	auipc	a0,0x5
ffffffffc0200a9a:	2d250513          	addi	a0,a0,722 # ffffffffc0205d68 <commands+0x330>
ffffffffc0200a9e:	ef6ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200aa2:	782c                	ld	a1,112(s0)
ffffffffc0200aa4:	00005517          	auipc	a0,0x5
ffffffffc0200aa8:	2dc50513          	addi	a0,a0,732 # ffffffffc0205d80 <commands+0x348>
ffffffffc0200aac:	ee8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200ab0:	7c2c                	ld	a1,120(s0)
ffffffffc0200ab2:	00005517          	auipc	a0,0x5
ffffffffc0200ab6:	2e650513          	addi	a0,a0,742 # ffffffffc0205d98 <commands+0x360>
ffffffffc0200aba:	edaff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200abe:	604c                	ld	a1,128(s0)
ffffffffc0200ac0:	00005517          	auipc	a0,0x5
ffffffffc0200ac4:	2f050513          	addi	a0,a0,752 # ffffffffc0205db0 <commands+0x378>
ffffffffc0200ac8:	eccff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200acc:	644c                	ld	a1,136(s0)
ffffffffc0200ace:	00005517          	auipc	a0,0x5
ffffffffc0200ad2:	2fa50513          	addi	a0,a0,762 # ffffffffc0205dc8 <commands+0x390>
ffffffffc0200ad6:	ebeff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200ada:	684c                	ld	a1,144(s0)
ffffffffc0200adc:	00005517          	auipc	a0,0x5
ffffffffc0200ae0:	30450513          	addi	a0,a0,772 # ffffffffc0205de0 <commands+0x3a8>
ffffffffc0200ae4:	eb0ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200ae8:	6c4c                	ld	a1,152(s0)
ffffffffc0200aea:	00005517          	auipc	a0,0x5
ffffffffc0200aee:	30e50513          	addi	a0,a0,782 # ffffffffc0205df8 <commands+0x3c0>
ffffffffc0200af2:	ea2ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200af6:	704c                	ld	a1,160(s0)
ffffffffc0200af8:	00005517          	auipc	a0,0x5
ffffffffc0200afc:	31850513          	addi	a0,a0,792 # ffffffffc0205e10 <commands+0x3d8>
ffffffffc0200b00:	e94ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200b04:	744c                	ld	a1,168(s0)
ffffffffc0200b06:	00005517          	auipc	a0,0x5
ffffffffc0200b0a:	32250513          	addi	a0,a0,802 # ffffffffc0205e28 <commands+0x3f0>
ffffffffc0200b0e:	e86ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200b12:	784c                	ld	a1,176(s0)
ffffffffc0200b14:	00005517          	auipc	a0,0x5
ffffffffc0200b18:	32c50513          	addi	a0,a0,812 # ffffffffc0205e40 <commands+0x408>
ffffffffc0200b1c:	e78ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200b20:	7c4c                	ld	a1,184(s0)
ffffffffc0200b22:	00005517          	auipc	a0,0x5
ffffffffc0200b26:	33650513          	addi	a0,a0,822 # ffffffffc0205e58 <commands+0x420>
ffffffffc0200b2a:	e6aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200b2e:	606c                	ld	a1,192(s0)
ffffffffc0200b30:	00005517          	auipc	a0,0x5
ffffffffc0200b34:	34050513          	addi	a0,a0,832 # ffffffffc0205e70 <commands+0x438>
ffffffffc0200b38:	e5cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200b3c:	646c                	ld	a1,200(s0)
ffffffffc0200b3e:	00005517          	auipc	a0,0x5
ffffffffc0200b42:	34a50513          	addi	a0,a0,842 # ffffffffc0205e88 <commands+0x450>
ffffffffc0200b46:	e4eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200b4a:	686c                	ld	a1,208(s0)
ffffffffc0200b4c:	00005517          	auipc	a0,0x5
ffffffffc0200b50:	35450513          	addi	a0,a0,852 # ffffffffc0205ea0 <commands+0x468>
ffffffffc0200b54:	e40ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200b58:	6c6c                	ld	a1,216(s0)
ffffffffc0200b5a:	00005517          	auipc	a0,0x5
ffffffffc0200b5e:	35e50513          	addi	a0,a0,862 # ffffffffc0205eb8 <commands+0x480>
ffffffffc0200b62:	e32ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200b66:	706c                	ld	a1,224(s0)
ffffffffc0200b68:	00005517          	auipc	a0,0x5
ffffffffc0200b6c:	36850513          	addi	a0,a0,872 # ffffffffc0205ed0 <commands+0x498>
ffffffffc0200b70:	e24ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200b74:	746c                	ld	a1,232(s0)
ffffffffc0200b76:	00005517          	auipc	a0,0x5
ffffffffc0200b7a:	37250513          	addi	a0,a0,882 # ffffffffc0205ee8 <commands+0x4b0>
ffffffffc0200b7e:	e16ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200b82:	786c                	ld	a1,240(s0)
ffffffffc0200b84:	00005517          	auipc	a0,0x5
ffffffffc0200b88:	37c50513          	addi	a0,a0,892 # ffffffffc0205f00 <commands+0x4c8>
ffffffffc0200b8c:	e08ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b90:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200b92:	6402                	ld	s0,0(sp)
ffffffffc0200b94:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b96:	00005517          	auipc	a0,0x5
ffffffffc0200b9a:	38250513          	addi	a0,a0,898 # ffffffffc0205f18 <commands+0x4e0>
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
ffffffffc0200bb0:	38450513          	addi	a0,a0,900 # ffffffffc0205f30 <commands+0x4f8>
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
ffffffffc0200bc8:	38450513          	addi	a0,a0,900 # ffffffffc0205f48 <commands+0x510>
ffffffffc0200bcc:	dc8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200bd0:	10843583          	ld	a1,264(s0)
ffffffffc0200bd4:	00005517          	auipc	a0,0x5
ffffffffc0200bd8:	38c50513          	addi	a0,a0,908 # ffffffffc0205f60 <commands+0x528>
ffffffffc0200bdc:	db8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200be0:	11043583          	ld	a1,272(s0)
ffffffffc0200be4:	00005517          	auipc	a0,0x5
ffffffffc0200be8:	39450513          	addi	a0,a0,916 # ffffffffc0205f78 <commands+0x540>
ffffffffc0200bec:	da8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bf0:	11843583          	ld	a1,280(s0)
}
ffffffffc0200bf4:	6402                	ld	s0,0(sp)
ffffffffc0200bf6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bf8:	00005517          	auipc	a0,0x5
ffffffffc0200bfc:	39050513          	addi	a0,a0,912 # ffffffffc0205f88 <commands+0x550>
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
ffffffffc0200c18:	43c70713          	addi	a4,a4,1084 # ffffffffc0206050 <commands+0x618>
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
ffffffffc0200c2a:	3da50513          	addi	a0,a0,986 # ffffffffc0206000 <commands+0x5c8>
ffffffffc0200c2e:	d66ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200c32:	00005517          	auipc	a0,0x5
ffffffffc0200c36:	3ae50513          	addi	a0,a0,942 # ffffffffc0205fe0 <commands+0x5a8>
ffffffffc0200c3a:	d5aff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200c3e:	00005517          	auipc	a0,0x5
ffffffffc0200c42:	36250513          	addi	a0,a0,866 # ffffffffc0205fa0 <commands+0x568>
ffffffffc0200c46:	d4eff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200c4a:	00005517          	auipc	a0,0x5
ffffffffc0200c4e:	37650513          	addi	a0,a0,886 # ffffffffc0205fc0 <commands+0x588>
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
ffffffffc0200c62:	000aa697          	auipc	a3,0xaa
ffffffffc0200c66:	a1e68693          	addi	a3,a3,-1506 # ffffffffc02aa680 <ticks>
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
ffffffffc0200c86:	3ae50513          	addi	a0,a0,942 # ffffffffc0206030 <commands+0x5f8>
ffffffffc0200c8a:	d0aff06f          	j	ffffffffc0200194 <cprintf>
        print_trapframe(tf);
ffffffffc0200c8e:	bf19                	j	ffffffffc0200ba4 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200c90:	06400593          	li	a1,100
ffffffffc0200c94:	00005517          	auipc	a0,0x5
ffffffffc0200c98:	38c50513          	addi	a0,a0,908 # ffffffffc0206020 <commands+0x5e8>
ffffffffc0200c9c:	cf8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
            num++; // 打印次数加一
ffffffffc0200ca0:	000aa717          	auipc	a4,0xaa
ffffffffc0200ca4:	a0070713          	addi	a4,a4,-1536 # ffffffffc02aa6a0 <num>
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
ffffffffc0200cc2:	000aa717          	auipc	a4,0xaa
ffffffffc0200cc6:	a1e73703          	ld	a4,-1506(a4) # ffffffffc02aa6e0 <current>
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
ffffffffc0200ce0:	1141                	addi	sp,sp,-16
ffffffffc0200ce2:	e022                	sd	s0,0(sp)
ffffffffc0200ce4:	e406                	sd	ra,8(sp)
ffffffffc0200ce6:	473d                	li	a4,15
ffffffffc0200ce8:	842a                	mv	s0,a0
ffffffffc0200cea:	10f76963          	bltu	a4,a5,ffffffffc0200dfc <exception_handler+0x120>
ffffffffc0200cee:	00005717          	auipc	a4,0x5
ffffffffc0200cf2:	58a70713          	addi	a4,a4,1418 # ffffffffc0206278 <commands+0x840>
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
ffffffffc0200d04:	46850513          	addi	a0,a0,1128 # ffffffffc0206168 <commands+0x730>
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
ffffffffc0200d1c:	53c0406f          	j	ffffffffc0205258 <syscall>
        cprintf("Environment call from H-mode\n");
ffffffffc0200d20:	00005517          	auipc	a0,0x5
ffffffffc0200d24:	46850513          	addi	a0,a0,1128 # ffffffffc0206188 <commands+0x750>
}
ffffffffc0200d28:	6402                	ld	s0,0(sp)
ffffffffc0200d2a:	60a2                	ld	ra,8(sp)
ffffffffc0200d2c:	0141                	addi	sp,sp,16
        cprintf("Instruction access fault\n");
ffffffffc0200d2e:	c66ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Environment call from M-mode\n");
ffffffffc0200d32:	00005517          	auipc	a0,0x5
ffffffffc0200d36:	47650513          	addi	a0,a0,1142 # ffffffffc02061a8 <commands+0x770>
ffffffffc0200d3a:	b7fd                	j	ffffffffc0200d28 <exception_handler+0x4c>
                tf->epc, tf->tval, current ? current->pid : -1);
ffffffffc0200d3c:	000aa797          	auipc	a5,0xaa
ffffffffc0200d40:	9a47b783          	ld	a5,-1628(a5) # ffffffffc02aa6e0 <current>
        cprintf("Instruction page fault at epc=0x%lx, tval=0x%lx, pid=%d\n",
ffffffffc0200d44:	10853583          	ld	a1,264(a0)
ffffffffc0200d48:	11053603          	ld	a2,272(a0)
ffffffffc0200d4c:	56fd                	li	a3,-1
ffffffffc0200d4e:	c391                	beqz	a5,ffffffffc0200d52 <exception_handler+0x76>
ffffffffc0200d50:	43d4                	lw	a3,4(a5)
ffffffffc0200d52:	00005517          	auipc	a0,0x5
ffffffffc0200d56:	47650513          	addi	a0,a0,1142 # ffffffffc02061c8 <commands+0x790>
ffffffffc0200d5a:	a081                	j	ffffffffc0200d9a <exception_handler+0xbe>
                tf->epc, tf->tval, current ? current->pid : -1);
ffffffffc0200d5c:	000aa797          	auipc	a5,0xaa
ffffffffc0200d60:	9847b783          	ld	a5,-1660(a5) # ffffffffc02aa6e0 <current>
        cprintf("Load page fault at epc=0x%lx, tval=0x%lx, pid=%d\n",
ffffffffc0200d64:	10853583          	ld	a1,264(a0)
ffffffffc0200d68:	11053603          	ld	a2,272(a0)
ffffffffc0200d6c:	56fd                	li	a3,-1
ffffffffc0200d6e:	c391                	beqz	a5,ffffffffc0200d72 <exception_handler+0x96>
ffffffffc0200d70:	43d4                	lw	a3,4(a5)
ffffffffc0200d72:	00005517          	auipc	a0,0x5
ffffffffc0200d76:	49650513          	addi	a0,a0,1174 # ffffffffc0206208 <commands+0x7d0>
ffffffffc0200d7a:	a005                	j	ffffffffc0200d9a <exception_handler+0xbe>
                tf->epc, tf->tval, current ? current->pid : -1);
ffffffffc0200d7c:	000aa797          	auipc	a5,0xaa
ffffffffc0200d80:	9647b783          	ld	a5,-1692(a5) # ffffffffc02aa6e0 <current>
        cprintf("Store/AMO page fault at epc=0x%lx, tval=0x%lx, pid=%d\n",
ffffffffc0200d84:	10853583          	ld	a1,264(a0)
ffffffffc0200d88:	11053603          	ld	a2,272(a0)
ffffffffc0200d8c:	56fd                	li	a3,-1
ffffffffc0200d8e:	c391                	beqz	a5,ffffffffc0200d92 <exception_handler+0xb6>
ffffffffc0200d90:	43d4                	lw	a3,4(a5)
ffffffffc0200d92:	00005517          	auipc	a0,0x5
ffffffffc0200d96:	4ae50513          	addi	a0,a0,1198 # ffffffffc0206240 <commands+0x808>
}
ffffffffc0200d9a:	6402                	ld	s0,0(sp)
ffffffffc0200d9c:	60a2                	ld	ra,8(sp)
ffffffffc0200d9e:	0141                	addi	sp,sp,16
        cprintf("Store/AMO page fault at epc=0x%lx, tval=0x%lx, pid=%d\n",
ffffffffc0200da0:	bf4ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Breakpoint\n");
ffffffffc0200da4:	00005517          	auipc	a0,0x5
ffffffffc0200da8:	33450513          	addi	a0,a0,820 # ffffffffc02060d8 <commands+0x6a0>
ffffffffc0200dac:	be8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        if (tf->gpr.a7 == 10)
ffffffffc0200db0:	6458                	ld	a4,136(s0)
ffffffffc0200db2:	47a9                	li	a5,10
ffffffffc0200db4:	06f70563          	beq	a4,a5,ffffffffc0200e1e <exception_handler+0x142>
}
ffffffffc0200db8:	60a2                	ld	ra,8(sp)
ffffffffc0200dba:	6402                	ld	s0,0(sp)
ffffffffc0200dbc:	0141                	addi	sp,sp,16
ffffffffc0200dbe:	8082                	ret
        cprintf("Instruction access fault\n");
ffffffffc0200dc0:	00005517          	auipc	a0,0x5
ffffffffc0200dc4:	2e050513          	addi	a0,a0,736 # ffffffffc02060a0 <commands+0x668>
ffffffffc0200dc8:	b785                	j	ffffffffc0200d28 <exception_handler+0x4c>
        cprintf("Illegal instruction\n");
ffffffffc0200dca:	00005517          	auipc	a0,0x5
ffffffffc0200dce:	2f650513          	addi	a0,a0,758 # ffffffffc02060c0 <commands+0x688>
ffffffffc0200dd2:	bf99                	j	ffffffffc0200d28 <exception_handler+0x4c>
        cprintf("Instruction address misaligned\n");
ffffffffc0200dd4:	00005517          	auipc	a0,0x5
ffffffffc0200dd8:	2ac50513          	addi	a0,a0,684 # ffffffffc0206080 <commands+0x648>
ffffffffc0200ddc:	b7b1                	j	ffffffffc0200d28 <exception_handler+0x4c>
        cprintf("Load access fault\n");
ffffffffc0200dde:	00005517          	auipc	a0,0x5
ffffffffc0200de2:	32a50513          	addi	a0,a0,810 # ffffffffc0206108 <commands+0x6d0>
ffffffffc0200de6:	b789                	j	ffffffffc0200d28 <exception_handler+0x4c>
        cprintf("Store/AMO access fault\n");
ffffffffc0200de8:	00005517          	auipc	a0,0x5
ffffffffc0200dec:	36850513          	addi	a0,a0,872 # ffffffffc0206150 <commands+0x718>
ffffffffc0200df0:	bf25                	j	ffffffffc0200d28 <exception_handler+0x4c>
        cprintf("Load address misaligned\n");
ffffffffc0200df2:	00005517          	auipc	a0,0x5
ffffffffc0200df6:	2f650513          	addi	a0,a0,758 # ffffffffc02060e8 <commands+0x6b0>
ffffffffc0200dfa:	b73d                	j	ffffffffc0200d28 <exception_handler+0x4c>
        print_trapframe(tf);
ffffffffc0200dfc:	8522                	mv	a0,s0
}
ffffffffc0200dfe:	6402                	ld	s0,0(sp)
ffffffffc0200e00:	60a2                	ld	ra,8(sp)
ffffffffc0200e02:	0141                	addi	sp,sp,16
        print_trapframe(tf);
ffffffffc0200e04:	b345                	j	ffffffffc0200ba4 <print_trapframe>
        panic("AMO address misaligned\n");
ffffffffc0200e06:	00005617          	auipc	a2,0x5
ffffffffc0200e0a:	31a60613          	addi	a2,a2,794 # ffffffffc0206120 <commands+0x6e8>
ffffffffc0200e0e:	0c000593          	li	a1,192
ffffffffc0200e12:	00005517          	auipc	a0,0x5
ffffffffc0200e16:	32650513          	addi	a0,a0,806 # ffffffffc0206138 <commands+0x700>
ffffffffc0200e1a:	e74ff0ef          	jal	ra,ffffffffc020048e <__panic>
            tf->epc += 4;
ffffffffc0200e1e:	10843783          	ld	a5,264(s0)
ffffffffc0200e22:	0791                	addi	a5,a5,4
ffffffffc0200e24:	10f43423          	sd	a5,264(s0)
            syscall();
ffffffffc0200e28:	430040ef          	jal	ra,ffffffffc0205258 <syscall>
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200e2c:	000aa797          	auipc	a5,0xaa
ffffffffc0200e30:	8b47b783          	ld	a5,-1868(a5) # ffffffffc02aa6e0 <current>
ffffffffc0200e34:	6b9c                	ld	a5,16(a5)
ffffffffc0200e36:	8522                	mv	a0,s0
}
ffffffffc0200e38:	6402                	ld	s0,0(sp)
ffffffffc0200e3a:	60a2                	ld	ra,8(sp)
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200e3c:	6589                	lui	a1,0x2
ffffffffc0200e3e:	95be                	add	a1,a1,a5
}
ffffffffc0200e40:	0141                	addi	sp,sp,16
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200e42:	aab1                	j	ffffffffc0200f9e <kernel_execve_ret>

ffffffffc0200e44 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf)
{
ffffffffc0200e44:	1101                	addi	sp,sp,-32
ffffffffc0200e46:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
    //    cputs("some trap");
    if (current == NULL)
ffffffffc0200e48:	000aa417          	auipc	s0,0xaa
ffffffffc0200e4c:	89840413          	addi	s0,s0,-1896 # ffffffffc02aa6e0 <current>
ffffffffc0200e50:	6018                	ld	a4,0(s0)
{
ffffffffc0200e52:	ec06                	sd	ra,24(sp)
ffffffffc0200e54:	e426                	sd	s1,8(sp)
ffffffffc0200e56:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0)
ffffffffc0200e58:	11853683          	ld	a3,280(a0)
    if (current == NULL)
ffffffffc0200e5c:	cf1d                	beqz	a4,ffffffffc0200e9a <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200e5e:	10053483          	ld	s1,256(a0)
    {
        trap_dispatch(tf);
    }
    else
    {
        struct trapframe *otf = current->tf;
ffffffffc0200e62:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200e66:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200e68:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0)
ffffffffc0200e6c:	0206c463          	bltz	a3,ffffffffc0200e94 <trap+0x50>
        exception_handler(tf);
ffffffffc0200e70:	e6dff0ef          	jal	ra,ffffffffc0200cdc <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200e74:	601c                	ld	a5,0(s0)
ffffffffc0200e76:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel)
ffffffffc0200e7a:	e499                	bnez	s1,ffffffffc0200e88 <trap+0x44>
        {
            if (current->flags & PF_EXITING)
ffffffffc0200e7c:	0b07a703          	lw	a4,176(a5)
ffffffffc0200e80:	8b05                	andi	a4,a4,1
ffffffffc0200e82:	e329                	bnez	a4,ffffffffc0200ec4 <trap+0x80>
            {
                do_exit(-E_KILLED);
            }
            if (current->need_resched)
ffffffffc0200e84:	6f9c                	ld	a5,24(a5)
ffffffffc0200e86:	eb85                	bnez	a5,ffffffffc0200eb6 <trap+0x72>
            {
                schedule();
            }
        }
    }
}
ffffffffc0200e88:	60e2                	ld	ra,24(sp)
ffffffffc0200e8a:	6442                	ld	s0,16(sp)
ffffffffc0200e8c:	64a2                	ld	s1,8(sp)
ffffffffc0200e8e:	6902                	ld	s2,0(sp)
ffffffffc0200e90:	6105                	addi	sp,sp,32
ffffffffc0200e92:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200e94:	d73ff0ef          	jal	ra,ffffffffc0200c06 <interrupt_handler>
ffffffffc0200e98:	bff1                	j	ffffffffc0200e74 <trap+0x30>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200e9a:	0006c863          	bltz	a3,ffffffffc0200eaa <trap+0x66>
}
ffffffffc0200e9e:	6442                	ld	s0,16(sp)
ffffffffc0200ea0:	60e2                	ld	ra,24(sp)
ffffffffc0200ea2:	64a2                	ld	s1,8(sp)
ffffffffc0200ea4:	6902                	ld	s2,0(sp)
ffffffffc0200ea6:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200ea8:	bd15                	j	ffffffffc0200cdc <exception_handler>
}
ffffffffc0200eaa:	6442                	ld	s0,16(sp)
ffffffffc0200eac:	60e2                	ld	ra,24(sp)
ffffffffc0200eae:	64a2                	ld	s1,8(sp)
ffffffffc0200eb0:	6902                	ld	s2,0(sp)
ffffffffc0200eb2:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200eb4:	bb89                	j	ffffffffc0200c06 <interrupt_handler>
}
ffffffffc0200eb6:	6442                	ld	s0,16(sp)
ffffffffc0200eb8:	60e2                	ld	ra,24(sp)
ffffffffc0200eba:	64a2                	ld	s1,8(sp)
ffffffffc0200ebc:	6902                	ld	s2,0(sp)
ffffffffc0200ebe:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200ec0:	2ac0406f          	j	ffffffffc020516c <schedule>
                do_exit(-E_KILLED);
ffffffffc0200ec4:	555d                	li	a0,-9
ffffffffc0200ec6:	606030ef          	jal	ra,ffffffffc02044cc <do_exit>
            if (current->need_resched)
ffffffffc0200eca:	601c                	ld	a5,0(s0)
ffffffffc0200ecc:	bf65                	j	ffffffffc0200e84 <trap+0x40>
	...

ffffffffc0200ed0 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ed0:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200ed4:	00011463          	bnez	sp,ffffffffc0200edc <__alltraps+0xc>
ffffffffc0200ed8:	14002173          	csrr	sp,sscratch
ffffffffc0200edc:	712d                	addi	sp,sp,-288
ffffffffc0200ede:	e002                	sd	zero,0(sp)
ffffffffc0200ee0:	e406                	sd	ra,8(sp)
ffffffffc0200ee2:	ec0e                	sd	gp,24(sp)
ffffffffc0200ee4:	f012                	sd	tp,32(sp)
ffffffffc0200ee6:	f416                	sd	t0,40(sp)
ffffffffc0200ee8:	f81a                	sd	t1,48(sp)
ffffffffc0200eea:	fc1e                	sd	t2,56(sp)
ffffffffc0200eec:	e0a2                	sd	s0,64(sp)
ffffffffc0200eee:	e4a6                	sd	s1,72(sp)
ffffffffc0200ef0:	e8aa                	sd	a0,80(sp)
ffffffffc0200ef2:	ecae                	sd	a1,88(sp)
ffffffffc0200ef4:	f0b2                	sd	a2,96(sp)
ffffffffc0200ef6:	f4b6                	sd	a3,104(sp)
ffffffffc0200ef8:	f8ba                	sd	a4,112(sp)
ffffffffc0200efa:	fcbe                	sd	a5,120(sp)
ffffffffc0200efc:	e142                	sd	a6,128(sp)
ffffffffc0200efe:	e546                	sd	a7,136(sp)
ffffffffc0200f00:	e94a                	sd	s2,144(sp)
ffffffffc0200f02:	ed4e                	sd	s3,152(sp)
ffffffffc0200f04:	f152                	sd	s4,160(sp)
ffffffffc0200f06:	f556                	sd	s5,168(sp)
ffffffffc0200f08:	f95a                	sd	s6,176(sp)
ffffffffc0200f0a:	fd5e                	sd	s7,184(sp)
ffffffffc0200f0c:	e1e2                	sd	s8,192(sp)
ffffffffc0200f0e:	e5e6                	sd	s9,200(sp)
ffffffffc0200f10:	e9ea                	sd	s10,208(sp)
ffffffffc0200f12:	edee                	sd	s11,216(sp)
ffffffffc0200f14:	f1f2                	sd	t3,224(sp)
ffffffffc0200f16:	f5f6                	sd	t4,232(sp)
ffffffffc0200f18:	f9fa                	sd	t5,240(sp)
ffffffffc0200f1a:	fdfe                	sd	t6,248(sp)
ffffffffc0200f1c:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200f20:	100024f3          	csrr	s1,sstatus
ffffffffc0200f24:	14102973          	csrr	s2,sepc
ffffffffc0200f28:	143029f3          	csrr	s3,stval
ffffffffc0200f2c:	14202a73          	csrr	s4,scause
ffffffffc0200f30:	e822                	sd	s0,16(sp)
ffffffffc0200f32:	e226                	sd	s1,256(sp)
ffffffffc0200f34:	e64a                	sd	s2,264(sp)
ffffffffc0200f36:	ea4e                	sd	s3,272(sp)
ffffffffc0200f38:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200f3a:	850a                	mv	a0,sp
    jal trap
ffffffffc0200f3c:	f09ff0ef          	jal	ra,ffffffffc0200e44 <trap>

ffffffffc0200f40 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200f40:	6492                	ld	s1,256(sp)
ffffffffc0200f42:	6932                	ld	s2,264(sp)
ffffffffc0200f44:	1004f413          	andi	s0,s1,256
ffffffffc0200f48:	e401                	bnez	s0,ffffffffc0200f50 <__trapret+0x10>
ffffffffc0200f4a:	1200                	addi	s0,sp,288
ffffffffc0200f4c:	14041073          	csrw	sscratch,s0
ffffffffc0200f50:	10049073          	csrw	sstatus,s1
ffffffffc0200f54:	14191073          	csrw	sepc,s2
ffffffffc0200f58:	60a2                	ld	ra,8(sp)
ffffffffc0200f5a:	61e2                	ld	gp,24(sp)
ffffffffc0200f5c:	7202                	ld	tp,32(sp)
ffffffffc0200f5e:	72a2                	ld	t0,40(sp)
ffffffffc0200f60:	7342                	ld	t1,48(sp)
ffffffffc0200f62:	73e2                	ld	t2,56(sp)
ffffffffc0200f64:	6406                	ld	s0,64(sp)
ffffffffc0200f66:	64a6                	ld	s1,72(sp)
ffffffffc0200f68:	6546                	ld	a0,80(sp)
ffffffffc0200f6a:	65e6                	ld	a1,88(sp)
ffffffffc0200f6c:	7606                	ld	a2,96(sp)
ffffffffc0200f6e:	76a6                	ld	a3,104(sp)
ffffffffc0200f70:	7746                	ld	a4,112(sp)
ffffffffc0200f72:	77e6                	ld	a5,120(sp)
ffffffffc0200f74:	680a                	ld	a6,128(sp)
ffffffffc0200f76:	68aa                	ld	a7,136(sp)
ffffffffc0200f78:	694a                	ld	s2,144(sp)
ffffffffc0200f7a:	69ea                	ld	s3,152(sp)
ffffffffc0200f7c:	7a0a                	ld	s4,160(sp)
ffffffffc0200f7e:	7aaa                	ld	s5,168(sp)
ffffffffc0200f80:	7b4a                	ld	s6,176(sp)
ffffffffc0200f82:	7bea                	ld	s7,184(sp)
ffffffffc0200f84:	6c0e                	ld	s8,192(sp)
ffffffffc0200f86:	6cae                	ld	s9,200(sp)
ffffffffc0200f88:	6d4e                	ld	s10,208(sp)
ffffffffc0200f8a:	6dee                	ld	s11,216(sp)
ffffffffc0200f8c:	7e0e                	ld	t3,224(sp)
ffffffffc0200f8e:	7eae                	ld	t4,232(sp)
ffffffffc0200f90:	7f4e                	ld	t5,240(sp)
ffffffffc0200f92:	7fee                	ld	t6,248(sp)
ffffffffc0200f94:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200f96:	10200073          	sret

ffffffffc0200f9a <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200f9a:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200f9c:	b755                	j	ffffffffc0200f40 <__trapret>

ffffffffc0200f9e <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200f9e:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cc8>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200fa2:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200fa6:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200faa:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200fae:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200fb2:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200fb6:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200fba:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200fbe:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200fc2:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200fc4:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200fc6:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200fc8:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200fca:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200fcc:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200fce:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200fd0:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200fd2:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200fd4:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200fd6:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200fd8:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200fda:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200fdc:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200fde:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200fe0:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200fe2:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200fe4:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200fe6:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200fe8:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200fea:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200fec:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200fee:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200ff0:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200ff2:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200ff4:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200ff6:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200ff8:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200ffa:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200ffc:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200ffe:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0201000:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0201002:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0201004:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0201006:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0201008:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc020100a:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc020100c:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc020100e:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0201010:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0201012:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0201014:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0201016:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0201018:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc020101a:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc020101c:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc020101e:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0201020:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0201022:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0201024:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0201026:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0201028:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc020102a:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc020102c:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc020102e:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0201030:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0201032:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0201034:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0201036:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0201038:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc020103a:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc020103c:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc020103e:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0201040:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0201042:	812e                	mv	sp,a1
ffffffffc0201044:	bdf5                	j	ffffffffc0200f40 <__trapret>

ffffffffc0201046 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0201046:	000a5797          	auipc	a5,0xa5
ffffffffc020104a:	60a78793          	addi	a5,a5,1546 # ffffffffc02a6650 <free_area>
ffffffffc020104e:	e79c                	sd	a5,8(a5)
ffffffffc0201050:	e39c                	sd	a5,0(a5)

static void
default_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc0201052:	0007a823          	sw	zero,16(a5)
}
ffffffffc0201056:	8082                	ret

ffffffffc0201058 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc0201058:	000a5517          	auipc	a0,0xa5
ffffffffc020105c:	60856503          	lwu	a0,1544(a0) # ffffffffc02a6660 <free_area+0x10>
ffffffffc0201060:	8082                	ret

ffffffffc0201062 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
ffffffffc0201062:	715d                	addi	sp,sp,-80
ffffffffc0201064:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0201066:	000a5417          	auipc	s0,0xa5
ffffffffc020106a:	5ea40413          	addi	s0,s0,1514 # ffffffffc02a6650 <free_area>
ffffffffc020106e:	641c                	ld	a5,8(s0)
ffffffffc0201070:	e486                	sd	ra,72(sp)
ffffffffc0201072:	fc26                	sd	s1,56(sp)
ffffffffc0201074:	f84a                	sd	s2,48(sp)
ffffffffc0201076:	f44e                	sd	s3,40(sp)
ffffffffc0201078:	f052                	sd	s4,32(sp)
ffffffffc020107a:	ec56                	sd	s5,24(sp)
ffffffffc020107c:	e85a                	sd	s6,16(sp)
ffffffffc020107e:	e45e                	sd	s7,8(sp)
ffffffffc0201080:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0201082:	2a878d63          	beq	a5,s0,ffffffffc020133c <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0201086:	4481                	li	s1,0
ffffffffc0201088:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020108a:	ff07b703          	ld	a4,-16(a5)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020108e:	8b09                	andi	a4,a4,2
ffffffffc0201090:	2a070a63          	beqz	a4,ffffffffc0201344 <default_check+0x2e2>
        count++, total += p->property;
ffffffffc0201094:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201098:	679c                	ld	a5,8(a5)
ffffffffc020109a:	2905                	addiw	s2,s2,1
ffffffffc020109c:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc020109e:	fe8796e3          	bne	a5,s0,ffffffffc020108a <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc02010a2:	89a6                	mv	s3,s1
ffffffffc02010a4:	6df000ef          	jal	ra,ffffffffc0201f82 <nr_free_pages>
ffffffffc02010a8:	6f351e63          	bne	a0,s3,ffffffffc02017a4 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02010ac:	4505                	li	a0,1
ffffffffc02010ae:	657000ef          	jal	ra,ffffffffc0201f04 <alloc_pages>
ffffffffc02010b2:	8aaa                	mv	s5,a0
ffffffffc02010b4:	42050863          	beqz	a0,ffffffffc02014e4 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02010b8:	4505                	li	a0,1
ffffffffc02010ba:	64b000ef          	jal	ra,ffffffffc0201f04 <alloc_pages>
ffffffffc02010be:	89aa                	mv	s3,a0
ffffffffc02010c0:	70050263          	beqz	a0,ffffffffc02017c4 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02010c4:	4505                	li	a0,1
ffffffffc02010c6:	63f000ef          	jal	ra,ffffffffc0201f04 <alloc_pages>
ffffffffc02010ca:	8a2a                	mv	s4,a0
ffffffffc02010cc:	48050c63          	beqz	a0,ffffffffc0201564 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02010d0:	293a8a63          	beq	s5,s3,ffffffffc0201364 <default_check+0x302>
ffffffffc02010d4:	28aa8863          	beq	s5,a0,ffffffffc0201364 <default_check+0x302>
ffffffffc02010d8:	28a98663          	beq	s3,a0,ffffffffc0201364 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02010dc:	000aa783          	lw	a5,0(s5)
ffffffffc02010e0:	2a079263          	bnez	a5,ffffffffc0201384 <default_check+0x322>
ffffffffc02010e4:	0009a783          	lw	a5,0(s3)
ffffffffc02010e8:	28079e63          	bnez	a5,ffffffffc0201384 <default_check+0x322>
ffffffffc02010ec:	411c                	lw	a5,0(a0)
ffffffffc02010ee:	28079b63          	bnez	a5,ffffffffc0201384 <default_check+0x322>
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page)
{
    return page - pages + nbase;
ffffffffc02010f2:	000a9797          	auipc	a5,0xa9
ffffffffc02010f6:	5d67b783          	ld	a5,1494(a5) # ffffffffc02aa6c8 <pages>
ffffffffc02010fa:	40fa8733          	sub	a4,s5,a5
ffffffffc02010fe:	00007617          	auipc	a2,0x7
ffffffffc0201102:	93263603          	ld	a2,-1742(a2) # ffffffffc0207a30 <nbase>
ffffffffc0201106:	8719                	srai	a4,a4,0x6
ffffffffc0201108:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020110a:	000a9697          	auipc	a3,0xa9
ffffffffc020110e:	5b66b683          	ld	a3,1462(a3) # ffffffffc02aa6c0 <npage>
ffffffffc0201112:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page)
{
    return page2ppn(page) << PGSHIFT;
ffffffffc0201114:	0732                	slli	a4,a4,0xc
ffffffffc0201116:	28d77763          	bgeu	a4,a3,ffffffffc02013a4 <default_check+0x342>
    return page - pages + nbase;
ffffffffc020111a:	40f98733          	sub	a4,s3,a5
ffffffffc020111e:	8719                	srai	a4,a4,0x6
ffffffffc0201120:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201122:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201124:	4cd77063          	bgeu	a4,a3,ffffffffc02015e4 <default_check+0x582>
    return page - pages + nbase;
ffffffffc0201128:	40f507b3          	sub	a5,a0,a5
ffffffffc020112c:	8799                	srai	a5,a5,0x6
ffffffffc020112e:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201130:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201132:	30d7f963          	bgeu	a5,a3,ffffffffc0201444 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0201136:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201138:	00043c03          	ld	s8,0(s0)
ffffffffc020113c:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0201140:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0201144:	e400                	sd	s0,8(s0)
ffffffffc0201146:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0201148:	000a5797          	auipc	a5,0xa5
ffffffffc020114c:	5007ac23          	sw	zero,1304(a5) # ffffffffc02a6660 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201150:	5b5000ef          	jal	ra,ffffffffc0201f04 <alloc_pages>
ffffffffc0201154:	2c051863          	bnez	a0,ffffffffc0201424 <default_check+0x3c2>
    free_page(p0);
ffffffffc0201158:	4585                	li	a1,1
ffffffffc020115a:	8556                	mv	a0,s5
ffffffffc020115c:	5e7000ef          	jal	ra,ffffffffc0201f42 <free_pages>
    free_page(p1);
ffffffffc0201160:	4585                	li	a1,1
ffffffffc0201162:	854e                	mv	a0,s3
ffffffffc0201164:	5df000ef          	jal	ra,ffffffffc0201f42 <free_pages>
    free_page(p2);
ffffffffc0201168:	4585                	li	a1,1
ffffffffc020116a:	8552                	mv	a0,s4
ffffffffc020116c:	5d7000ef          	jal	ra,ffffffffc0201f42 <free_pages>
    assert(nr_free == 3);
ffffffffc0201170:	4818                	lw	a4,16(s0)
ffffffffc0201172:	478d                	li	a5,3
ffffffffc0201174:	28f71863          	bne	a4,a5,ffffffffc0201404 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201178:	4505                	li	a0,1
ffffffffc020117a:	58b000ef          	jal	ra,ffffffffc0201f04 <alloc_pages>
ffffffffc020117e:	89aa                	mv	s3,a0
ffffffffc0201180:	26050263          	beqz	a0,ffffffffc02013e4 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201184:	4505                	li	a0,1
ffffffffc0201186:	57f000ef          	jal	ra,ffffffffc0201f04 <alloc_pages>
ffffffffc020118a:	8aaa                	mv	s5,a0
ffffffffc020118c:	3a050c63          	beqz	a0,ffffffffc0201544 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201190:	4505                	li	a0,1
ffffffffc0201192:	573000ef          	jal	ra,ffffffffc0201f04 <alloc_pages>
ffffffffc0201196:	8a2a                	mv	s4,a0
ffffffffc0201198:	38050663          	beqz	a0,ffffffffc0201524 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc020119c:	4505                	li	a0,1
ffffffffc020119e:	567000ef          	jal	ra,ffffffffc0201f04 <alloc_pages>
ffffffffc02011a2:	36051163          	bnez	a0,ffffffffc0201504 <default_check+0x4a2>
    free_page(p0);
ffffffffc02011a6:	4585                	li	a1,1
ffffffffc02011a8:	854e                	mv	a0,s3
ffffffffc02011aa:	599000ef          	jal	ra,ffffffffc0201f42 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02011ae:	641c                	ld	a5,8(s0)
ffffffffc02011b0:	20878a63          	beq	a5,s0,ffffffffc02013c4 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc02011b4:	4505                	li	a0,1
ffffffffc02011b6:	54f000ef          	jal	ra,ffffffffc0201f04 <alloc_pages>
ffffffffc02011ba:	30a99563          	bne	s3,a0,ffffffffc02014c4 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc02011be:	4505                	li	a0,1
ffffffffc02011c0:	545000ef          	jal	ra,ffffffffc0201f04 <alloc_pages>
ffffffffc02011c4:	2e051063          	bnez	a0,ffffffffc02014a4 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc02011c8:	481c                	lw	a5,16(s0)
ffffffffc02011ca:	2a079d63          	bnez	a5,ffffffffc0201484 <default_check+0x422>
    free_page(p);
ffffffffc02011ce:	854e                	mv	a0,s3
ffffffffc02011d0:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02011d2:	01843023          	sd	s8,0(s0)
ffffffffc02011d6:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc02011da:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc02011de:	565000ef          	jal	ra,ffffffffc0201f42 <free_pages>
    free_page(p1);
ffffffffc02011e2:	4585                	li	a1,1
ffffffffc02011e4:	8556                	mv	a0,s5
ffffffffc02011e6:	55d000ef          	jal	ra,ffffffffc0201f42 <free_pages>
    free_page(p2);
ffffffffc02011ea:	4585                	li	a1,1
ffffffffc02011ec:	8552                	mv	a0,s4
ffffffffc02011ee:	555000ef          	jal	ra,ffffffffc0201f42 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02011f2:	4515                	li	a0,5
ffffffffc02011f4:	511000ef          	jal	ra,ffffffffc0201f04 <alloc_pages>
ffffffffc02011f8:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02011fa:	26050563          	beqz	a0,ffffffffc0201464 <default_check+0x402>
ffffffffc02011fe:	651c                	ld	a5,8(a0)
ffffffffc0201200:	8385                	srli	a5,a5,0x1
ffffffffc0201202:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0201204:	54079063          	bnez	a5,ffffffffc0201744 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201208:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020120a:	00043b03          	ld	s6,0(s0)
ffffffffc020120e:	00843a83          	ld	s5,8(s0)
ffffffffc0201212:	e000                	sd	s0,0(s0)
ffffffffc0201214:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0201216:	4ef000ef          	jal	ra,ffffffffc0201f04 <alloc_pages>
ffffffffc020121a:	50051563          	bnez	a0,ffffffffc0201724 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020121e:	08098a13          	addi	s4,s3,128
ffffffffc0201222:	8552                	mv	a0,s4
ffffffffc0201224:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201226:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc020122a:	000a5797          	auipc	a5,0xa5
ffffffffc020122e:	4207ab23          	sw	zero,1078(a5) # ffffffffc02a6660 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201232:	511000ef          	jal	ra,ffffffffc0201f42 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201236:	4511                	li	a0,4
ffffffffc0201238:	4cd000ef          	jal	ra,ffffffffc0201f04 <alloc_pages>
ffffffffc020123c:	4c051463          	bnez	a0,ffffffffc0201704 <default_check+0x6a2>
ffffffffc0201240:	0889b783          	ld	a5,136(s3)
ffffffffc0201244:	8385                	srli	a5,a5,0x1
ffffffffc0201246:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201248:	48078e63          	beqz	a5,ffffffffc02016e4 <default_check+0x682>
ffffffffc020124c:	0909a703          	lw	a4,144(s3)
ffffffffc0201250:	478d                	li	a5,3
ffffffffc0201252:	48f71963          	bne	a4,a5,ffffffffc02016e4 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201256:	450d                	li	a0,3
ffffffffc0201258:	4ad000ef          	jal	ra,ffffffffc0201f04 <alloc_pages>
ffffffffc020125c:	8c2a                	mv	s8,a0
ffffffffc020125e:	46050363          	beqz	a0,ffffffffc02016c4 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0201262:	4505                	li	a0,1
ffffffffc0201264:	4a1000ef          	jal	ra,ffffffffc0201f04 <alloc_pages>
ffffffffc0201268:	42051e63          	bnez	a0,ffffffffc02016a4 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc020126c:	418a1c63          	bne	s4,s8,ffffffffc0201684 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201270:	4585                	li	a1,1
ffffffffc0201272:	854e                	mv	a0,s3
ffffffffc0201274:	4cf000ef          	jal	ra,ffffffffc0201f42 <free_pages>
    free_pages(p1, 3);
ffffffffc0201278:	458d                	li	a1,3
ffffffffc020127a:	8552                	mv	a0,s4
ffffffffc020127c:	4c7000ef          	jal	ra,ffffffffc0201f42 <free_pages>
ffffffffc0201280:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201284:	04098c13          	addi	s8,s3,64
ffffffffc0201288:	8385                	srli	a5,a5,0x1
ffffffffc020128a:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020128c:	3c078c63          	beqz	a5,ffffffffc0201664 <default_check+0x602>
ffffffffc0201290:	0109a703          	lw	a4,16(s3)
ffffffffc0201294:	4785                	li	a5,1
ffffffffc0201296:	3cf71763          	bne	a4,a5,ffffffffc0201664 <default_check+0x602>
ffffffffc020129a:	008a3783          	ld	a5,8(s4)
ffffffffc020129e:	8385                	srli	a5,a5,0x1
ffffffffc02012a0:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02012a2:	3a078163          	beqz	a5,ffffffffc0201644 <default_check+0x5e2>
ffffffffc02012a6:	010a2703          	lw	a4,16(s4)
ffffffffc02012aa:	478d                	li	a5,3
ffffffffc02012ac:	38f71c63          	bne	a4,a5,ffffffffc0201644 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02012b0:	4505                	li	a0,1
ffffffffc02012b2:	453000ef          	jal	ra,ffffffffc0201f04 <alloc_pages>
ffffffffc02012b6:	36a99763          	bne	s3,a0,ffffffffc0201624 <default_check+0x5c2>
    free_page(p0);
ffffffffc02012ba:	4585                	li	a1,1
ffffffffc02012bc:	487000ef          	jal	ra,ffffffffc0201f42 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02012c0:	4509                	li	a0,2
ffffffffc02012c2:	443000ef          	jal	ra,ffffffffc0201f04 <alloc_pages>
ffffffffc02012c6:	32aa1f63          	bne	s4,a0,ffffffffc0201604 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc02012ca:	4589                	li	a1,2
ffffffffc02012cc:	477000ef          	jal	ra,ffffffffc0201f42 <free_pages>
    free_page(p2);
ffffffffc02012d0:	4585                	li	a1,1
ffffffffc02012d2:	8562                	mv	a0,s8
ffffffffc02012d4:	46f000ef          	jal	ra,ffffffffc0201f42 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02012d8:	4515                	li	a0,5
ffffffffc02012da:	42b000ef          	jal	ra,ffffffffc0201f04 <alloc_pages>
ffffffffc02012de:	89aa                	mv	s3,a0
ffffffffc02012e0:	48050263          	beqz	a0,ffffffffc0201764 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc02012e4:	4505                	li	a0,1
ffffffffc02012e6:	41f000ef          	jal	ra,ffffffffc0201f04 <alloc_pages>
ffffffffc02012ea:	2c051d63          	bnez	a0,ffffffffc02015c4 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc02012ee:	481c                	lw	a5,16(s0)
ffffffffc02012f0:	2a079a63          	bnez	a5,ffffffffc02015a4 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02012f4:	4595                	li	a1,5
ffffffffc02012f6:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02012f8:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02012fc:	01643023          	sd	s6,0(s0)
ffffffffc0201300:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0201304:	43f000ef          	jal	ra,ffffffffc0201f42 <free_pages>
    return listelm->next;
ffffffffc0201308:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc020130a:	00878963          	beq	a5,s0,ffffffffc020131c <default_check+0x2ba>
    {
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc020130e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201312:	679c                	ld	a5,8(a5)
ffffffffc0201314:	397d                	addiw	s2,s2,-1
ffffffffc0201316:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0201318:	fe879be3          	bne	a5,s0,ffffffffc020130e <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc020131c:	26091463          	bnez	s2,ffffffffc0201584 <default_check+0x522>
    assert(total == 0);
ffffffffc0201320:	46049263          	bnez	s1,ffffffffc0201784 <default_check+0x722>
}
ffffffffc0201324:	60a6                	ld	ra,72(sp)
ffffffffc0201326:	6406                	ld	s0,64(sp)
ffffffffc0201328:	74e2                	ld	s1,56(sp)
ffffffffc020132a:	7942                	ld	s2,48(sp)
ffffffffc020132c:	79a2                	ld	s3,40(sp)
ffffffffc020132e:	7a02                	ld	s4,32(sp)
ffffffffc0201330:	6ae2                	ld	s5,24(sp)
ffffffffc0201332:	6b42                	ld	s6,16(sp)
ffffffffc0201334:	6ba2                	ld	s7,8(sp)
ffffffffc0201336:	6c02                	ld	s8,0(sp)
ffffffffc0201338:	6161                	addi	sp,sp,80
ffffffffc020133a:	8082                	ret
    while ((le = list_next(le)) != &free_list)
ffffffffc020133c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020133e:	4481                	li	s1,0
ffffffffc0201340:	4901                	li	s2,0
ffffffffc0201342:	b38d                	j	ffffffffc02010a4 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0201344:	00005697          	auipc	a3,0x5
ffffffffc0201348:	f7468693          	addi	a3,a3,-140 # ffffffffc02062b8 <commands+0x880>
ffffffffc020134c:	00005617          	auipc	a2,0x5
ffffffffc0201350:	f7c60613          	addi	a2,a2,-132 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201354:	11000593          	li	a1,272
ffffffffc0201358:	00005517          	auipc	a0,0x5
ffffffffc020135c:	f8850513          	addi	a0,a0,-120 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201360:	92eff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201364:	00005697          	auipc	a3,0x5
ffffffffc0201368:	01468693          	addi	a3,a3,20 # ffffffffc0206378 <commands+0x940>
ffffffffc020136c:	00005617          	auipc	a2,0x5
ffffffffc0201370:	f5c60613          	addi	a2,a2,-164 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201374:	0db00593          	li	a1,219
ffffffffc0201378:	00005517          	auipc	a0,0x5
ffffffffc020137c:	f6850513          	addi	a0,a0,-152 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201380:	90eff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201384:	00005697          	auipc	a3,0x5
ffffffffc0201388:	01c68693          	addi	a3,a3,28 # ffffffffc02063a0 <commands+0x968>
ffffffffc020138c:	00005617          	auipc	a2,0x5
ffffffffc0201390:	f3c60613          	addi	a2,a2,-196 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201394:	0dc00593          	li	a1,220
ffffffffc0201398:	00005517          	auipc	a0,0x5
ffffffffc020139c:	f4850513          	addi	a0,a0,-184 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc02013a0:	8eeff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02013a4:	00005697          	auipc	a3,0x5
ffffffffc02013a8:	03c68693          	addi	a3,a3,60 # ffffffffc02063e0 <commands+0x9a8>
ffffffffc02013ac:	00005617          	auipc	a2,0x5
ffffffffc02013b0:	f1c60613          	addi	a2,a2,-228 # ffffffffc02062c8 <commands+0x890>
ffffffffc02013b4:	0de00593          	li	a1,222
ffffffffc02013b8:	00005517          	auipc	a0,0x5
ffffffffc02013bc:	f2850513          	addi	a0,a0,-216 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc02013c0:	8ceff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(!list_empty(&free_list));
ffffffffc02013c4:	00005697          	auipc	a3,0x5
ffffffffc02013c8:	0a468693          	addi	a3,a3,164 # ffffffffc0206468 <commands+0xa30>
ffffffffc02013cc:	00005617          	auipc	a2,0x5
ffffffffc02013d0:	efc60613          	addi	a2,a2,-260 # ffffffffc02062c8 <commands+0x890>
ffffffffc02013d4:	0f700593          	li	a1,247
ffffffffc02013d8:	00005517          	auipc	a0,0x5
ffffffffc02013dc:	f0850513          	addi	a0,a0,-248 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc02013e0:	8aeff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02013e4:	00005697          	auipc	a3,0x5
ffffffffc02013e8:	f3468693          	addi	a3,a3,-204 # ffffffffc0206318 <commands+0x8e0>
ffffffffc02013ec:	00005617          	auipc	a2,0x5
ffffffffc02013f0:	edc60613          	addi	a2,a2,-292 # ffffffffc02062c8 <commands+0x890>
ffffffffc02013f4:	0f000593          	li	a1,240
ffffffffc02013f8:	00005517          	auipc	a0,0x5
ffffffffc02013fc:	ee850513          	addi	a0,a0,-280 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201400:	88eff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free == 3);
ffffffffc0201404:	00005697          	auipc	a3,0x5
ffffffffc0201408:	05468693          	addi	a3,a3,84 # ffffffffc0206458 <commands+0xa20>
ffffffffc020140c:	00005617          	auipc	a2,0x5
ffffffffc0201410:	ebc60613          	addi	a2,a2,-324 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201414:	0ee00593          	li	a1,238
ffffffffc0201418:	00005517          	auipc	a0,0x5
ffffffffc020141c:	ec850513          	addi	a0,a0,-312 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201420:	86eff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201424:	00005697          	auipc	a3,0x5
ffffffffc0201428:	01c68693          	addi	a3,a3,28 # ffffffffc0206440 <commands+0xa08>
ffffffffc020142c:	00005617          	auipc	a2,0x5
ffffffffc0201430:	e9c60613          	addi	a2,a2,-356 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201434:	0e900593          	li	a1,233
ffffffffc0201438:	00005517          	auipc	a0,0x5
ffffffffc020143c:	ea850513          	addi	a0,a0,-344 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201440:	84eff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201444:	00005697          	auipc	a3,0x5
ffffffffc0201448:	fdc68693          	addi	a3,a3,-36 # ffffffffc0206420 <commands+0x9e8>
ffffffffc020144c:	00005617          	auipc	a2,0x5
ffffffffc0201450:	e7c60613          	addi	a2,a2,-388 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201454:	0e000593          	li	a1,224
ffffffffc0201458:	00005517          	auipc	a0,0x5
ffffffffc020145c:	e8850513          	addi	a0,a0,-376 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201460:	82eff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(p0 != NULL);
ffffffffc0201464:	00005697          	auipc	a3,0x5
ffffffffc0201468:	04c68693          	addi	a3,a3,76 # ffffffffc02064b0 <commands+0xa78>
ffffffffc020146c:	00005617          	auipc	a2,0x5
ffffffffc0201470:	e5c60613          	addi	a2,a2,-420 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201474:	11800593          	li	a1,280
ffffffffc0201478:	00005517          	auipc	a0,0x5
ffffffffc020147c:	e6850513          	addi	a0,a0,-408 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201480:	80eff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free == 0);
ffffffffc0201484:	00005697          	auipc	a3,0x5
ffffffffc0201488:	01c68693          	addi	a3,a3,28 # ffffffffc02064a0 <commands+0xa68>
ffffffffc020148c:	00005617          	auipc	a2,0x5
ffffffffc0201490:	e3c60613          	addi	a2,a2,-452 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201494:	0fd00593          	li	a1,253
ffffffffc0201498:	00005517          	auipc	a0,0x5
ffffffffc020149c:	e4850513          	addi	a0,a0,-440 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc02014a0:	feffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014a4:	00005697          	auipc	a3,0x5
ffffffffc02014a8:	f9c68693          	addi	a3,a3,-100 # ffffffffc0206440 <commands+0xa08>
ffffffffc02014ac:	00005617          	auipc	a2,0x5
ffffffffc02014b0:	e1c60613          	addi	a2,a2,-484 # ffffffffc02062c8 <commands+0x890>
ffffffffc02014b4:	0fb00593          	li	a1,251
ffffffffc02014b8:	00005517          	auipc	a0,0x5
ffffffffc02014bc:	e2850513          	addi	a0,a0,-472 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc02014c0:	fcffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02014c4:	00005697          	auipc	a3,0x5
ffffffffc02014c8:	fbc68693          	addi	a3,a3,-68 # ffffffffc0206480 <commands+0xa48>
ffffffffc02014cc:	00005617          	auipc	a2,0x5
ffffffffc02014d0:	dfc60613          	addi	a2,a2,-516 # ffffffffc02062c8 <commands+0x890>
ffffffffc02014d4:	0fa00593          	li	a1,250
ffffffffc02014d8:	00005517          	auipc	a0,0x5
ffffffffc02014dc:	e0850513          	addi	a0,a0,-504 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc02014e0:	faffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02014e4:	00005697          	auipc	a3,0x5
ffffffffc02014e8:	e3468693          	addi	a3,a3,-460 # ffffffffc0206318 <commands+0x8e0>
ffffffffc02014ec:	00005617          	auipc	a2,0x5
ffffffffc02014f0:	ddc60613          	addi	a2,a2,-548 # ffffffffc02062c8 <commands+0x890>
ffffffffc02014f4:	0d700593          	li	a1,215
ffffffffc02014f8:	00005517          	auipc	a0,0x5
ffffffffc02014fc:	de850513          	addi	a0,a0,-536 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201500:	f8ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201504:	00005697          	auipc	a3,0x5
ffffffffc0201508:	f3c68693          	addi	a3,a3,-196 # ffffffffc0206440 <commands+0xa08>
ffffffffc020150c:	00005617          	auipc	a2,0x5
ffffffffc0201510:	dbc60613          	addi	a2,a2,-580 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201514:	0f400593          	li	a1,244
ffffffffc0201518:	00005517          	auipc	a0,0x5
ffffffffc020151c:	dc850513          	addi	a0,a0,-568 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201520:	f6ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201524:	00005697          	auipc	a3,0x5
ffffffffc0201528:	e3468693          	addi	a3,a3,-460 # ffffffffc0206358 <commands+0x920>
ffffffffc020152c:	00005617          	auipc	a2,0x5
ffffffffc0201530:	d9c60613          	addi	a2,a2,-612 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201534:	0f200593          	li	a1,242
ffffffffc0201538:	00005517          	auipc	a0,0x5
ffffffffc020153c:	da850513          	addi	a0,a0,-600 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201540:	f4ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201544:	00005697          	auipc	a3,0x5
ffffffffc0201548:	df468693          	addi	a3,a3,-524 # ffffffffc0206338 <commands+0x900>
ffffffffc020154c:	00005617          	auipc	a2,0x5
ffffffffc0201550:	d7c60613          	addi	a2,a2,-644 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201554:	0f100593          	li	a1,241
ffffffffc0201558:	00005517          	auipc	a0,0x5
ffffffffc020155c:	d8850513          	addi	a0,a0,-632 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201560:	f2ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201564:	00005697          	auipc	a3,0x5
ffffffffc0201568:	df468693          	addi	a3,a3,-524 # ffffffffc0206358 <commands+0x920>
ffffffffc020156c:	00005617          	auipc	a2,0x5
ffffffffc0201570:	d5c60613          	addi	a2,a2,-676 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201574:	0d900593          	li	a1,217
ffffffffc0201578:	00005517          	auipc	a0,0x5
ffffffffc020157c:	d6850513          	addi	a0,a0,-664 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201580:	f0ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(count == 0);
ffffffffc0201584:	00005697          	auipc	a3,0x5
ffffffffc0201588:	07c68693          	addi	a3,a3,124 # ffffffffc0206600 <commands+0xbc8>
ffffffffc020158c:	00005617          	auipc	a2,0x5
ffffffffc0201590:	d3c60613          	addi	a2,a2,-708 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201594:	14600593          	li	a1,326
ffffffffc0201598:	00005517          	auipc	a0,0x5
ffffffffc020159c:	d4850513          	addi	a0,a0,-696 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc02015a0:	eeffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free == 0);
ffffffffc02015a4:	00005697          	auipc	a3,0x5
ffffffffc02015a8:	efc68693          	addi	a3,a3,-260 # ffffffffc02064a0 <commands+0xa68>
ffffffffc02015ac:	00005617          	auipc	a2,0x5
ffffffffc02015b0:	d1c60613          	addi	a2,a2,-740 # ffffffffc02062c8 <commands+0x890>
ffffffffc02015b4:	13a00593          	li	a1,314
ffffffffc02015b8:	00005517          	auipc	a0,0x5
ffffffffc02015bc:	d2850513          	addi	a0,a0,-728 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc02015c0:	ecffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02015c4:	00005697          	auipc	a3,0x5
ffffffffc02015c8:	e7c68693          	addi	a3,a3,-388 # ffffffffc0206440 <commands+0xa08>
ffffffffc02015cc:	00005617          	auipc	a2,0x5
ffffffffc02015d0:	cfc60613          	addi	a2,a2,-772 # ffffffffc02062c8 <commands+0x890>
ffffffffc02015d4:	13800593          	li	a1,312
ffffffffc02015d8:	00005517          	auipc	a0,0x5
ffffffffc02015dc:	d0850513          	addi	a0,a0,-760 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc02015e0:	eaffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02015e4:	00005697          	auipc	a3,0x5
ffffffffc02015e8:	e1c68693          	addi	a3,a3,-484 # ffffffffc0206400 <commands+0x9c8>
ffffffffc02015ec:	00005617          	auipc	a2,0x5
ffffffffc02015f0:	cdc60613          	addi	a2,a2,-804 # ffffffffc02062c8 <commands+0x890>
ffffffffc02015f4:	0df00593          	li	a1,223
ffffffffc02015f8:	00005517          	auipc	a0,0x5
ffffffffc02015fc:	ce850513          	addi	a0,a0,-792 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201600:	e8ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201604:	00005697          	auipc	a3,0x5
ffffffffc0201608:	fbc68693          	addi	a3,a3,-68 # ffffffffc02065c0 <commands+0xb88>
ffffffffc020160c:	00005617          	auipc	a2,0x5
ffffffffc0201610:	cbc60613          	addi	a2,a2,-836 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201614:	13200593          	li	a1,306
ffffffffc0201618:	00005517          	auipc	a0,0x5
ffffffffc020161c:	cc850513          	addi	a0,a0,-824 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201620:	e6ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201624:	00005697          	auipc	a3,0x5
ffffffffc0201628:	f7c68693          	addi	a3,a3,-132 # ffffffffc02065a0 <commands+0xb68>
ffffffffc020162c:	00005617          	auipc	a2,0x5
ffffffffc0201630:	c9c60613          	addi	a2,a2,-868 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201634:	13000593          	li	a1,304
ffffffffc0201638:	00005517          	auipc	a0,0x5
ffffffffc020163c:	ca850513          	addi	a0,a0,-856 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201640:	e4ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201644:	00005697          	auipc	a3,0x5
ffffffffc0201648:	f3468693          	addi	a3,a3,-204 # ffffffffc0206578 <commands+0xb40>
ffffffffc020164c:	00005617          	auipc	a2,0x5
ffffffffc0201650:	c7c60613          	addi	a2,a2,-900 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201654:	12e00593          	li	a1,302
ffffffffc0201658:	00005517          	auipc	a0,0x5
ffffffffc020165c:	c8850513          	addi	a0,a0,-888 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201660:	e2ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201664:	00005697          	auipc	a3,0x5
ffffffffc0201668:	eec68693          	addi	a3,a3,-276 # ffffffffc0206550 <commands+0xb18>
ffffffffc020166c:	00005617          	auipc	a2,0x5
ffffffffc0201670:	c5c60613          	addi	a2,a2,-932 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201674:	12d00593          	li	a1,301
ffffffffc0201678:	00005517          	auipc	a0,0x5
ffffffffc020167c:	c6850513          	addi	a0,a0,-920 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201680:	e0ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201684:	00005697          	auipc	a3,0x5
ffffffffc0201688:	ebc68693          	addi	a3,a3,-324 # ffffffffc0206540 <commands+0xb08>
ffffffffc020168c:	00005617          	auipc	a2,0x5
ffffffffc0201690:	c3c60613          	addi	a2,a2,-964 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201694:	12800593          	li	a1,296
ffffffffc0201698:	00005517          	auipc	a0,0x5
ffffffffc020169c:	c4850513          	addi	a0,a0,-952 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc02016a0:	deffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02016a4:	00005697          	auipc	a3,0x5
ffffffffc02016a8:	d9c68693          	addi	a3,a3,-612 # ffffffffc0206440 <commands+0xa08>
ffffffffc02016ac:	00005617          	auipc	a2,0x5
ffffffffc02016b0:	c1c60613          	addi	a2,a2,-996 # ffffffffc02062c8 <commands+0x890>
ffffffffc02016b4:	12700593          	li	a1,295
ffffffffc02016b8:	00005517          	auipc	a0,0x5
ffffffffc02016bc:	c2850513          	addi	a0,a0,-984 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc02016c0:	dcffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02016c4:	00005697          	auipc	a3,0x5
ffffffffc02016c8:	e5c68693          	addi	a3,a3,-420 # ffffffffc0206520 <commands+0xae8>
ffffffffc02016cc:	00005617          	auipc	a2,0x5
ffffffffc02016d0:	bfc60613          	addi	a2,a2,-1028 # ffffffffc02062c8 <commands+0x890>
ffffffffc02016d4:	12600593          	li	a1,294
ffffffffc02016d8:	00005517          	auipc	a0,0x5
ffffffffc02016dc:	c0850513          	addi	a0,a0,-1016 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc02016e0:	daffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02016e4:	00005697          	auipc	a3,0x5
ffffffffc02016e8:	e0c68693          	addi	a3,a3,-500 # ffffffffc02064f0 <commands+0xab8>
ffffffffc02016ec:	00005617          	auipc	a2,0x5
ffffffffc02016f0:	bdc60613          	addi	a2,a2,-1060 # ffffffffc02062c8 <commands+0x890>
ffffffffc02016f4:	12500593          	li	a1,293
ffffffffc02016f8:	00005517          	auipc	a0,0x5
ffffffffc02016fc:	be850513          	addi	a0,a0,-1048 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201700:	d8ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201704:	00005697          	auipc	a3,0x5
ffffffffc0201708:	dd468693          	addi	a3,a3,-556 # ffffffffc02064d8 <commands+0xaa0>
ffffffffc020170c:	00005617          	auipc	a2,0x5
ffffffffc0201710:	bbc60613          	addi	a2,a2,-1092 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201714:	12400593          	li	a1,292
ffffffffc0201718:	00005517          	auipc	a0,0x5
ffffffffc020171c:	bc850513          	addi	a0,a0,-1080 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201720:	d6ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201724:	00005697          	auipc	a3,0x5
ffffffffc0201728:	d1c68693          	addi	a3,a3,-740 # ffffffffc0206440 <commands+0xa08>
ffffffffc020172c:	00005617          	auipc	a2,0x5
ffffffffc0201730:	b9c60613          	addi	a2,a2,-1124 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201734:	11e00593          	li	a1,286
ffffffffc0201738:	00005517          	auipc	a0,0x5
ffffffffc020173c:	ba850513          	addi	a0,a0,-1112 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201740:	d4ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(!PageProperty(p0));
ffffffffc0201744:	00005697          	auipc	a3,0x5
ffffffffc0201748:	d7c68693          	addi	a3,a3,-644 # ffffffffc02064c0 <commands+0xa88>
ffffffffc020174c:	00005617          	auipc	a2,0x5
ffffffffc0201750:	b7c60613          	addi	a2,a2,-1156 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201754:	11900593          	li	a1,281
ffffffffc0201758:	00005517          	auipc	a0,0x5
ffffffffc020175c:	b8850513          	addi	a0,a0,-1144 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201760:	d2ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201764:	00005697          	auipc	a3,0x5
ffffffffc0201768:	e7c68693          	addi	a3,a3,-388 # ffffffffc02065e0 <commands+0xba8>
ffffffffc020176c:	00005617          	auipc	a2,0x5
ffffffffc0201770:	b5c60613          	addi	a2,a2,-1188 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201774:	13700593          	li	a1,311
ffffffffc0201778:	00005517          	auipc	a0,0x5
ffffffffc020177c:	b6850513          	addi	a0,a0,-1176 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201780:	d0ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(total == 0);
ffffffffc0201784:	00005697          	auipc	a3,0x5
ffffffffc0201788:	e8c68693          	addi	a3,a3,-372 # ffffffffc0206610 <commands+0xbd8>
ffffffffc020178c:	00005617          	auipc	a2,0x5
ffffffffc0201790:	b3c60613          	addi	a2,a2,-1220 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201794:	14700593          	li	a1,327
ffffffffc0201798:	00005517          	auipc	a0,0x5
ffffffffc020179c:	b4850513          	addi	a0,a0,-1208 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc02017a0:	ceffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(total == nr_free_pages());
ffffffffc02017a4:	00005697          	auipc	a3,0x5
ffffffffc02017a8:	b5468693          	addi	a3,a3,-1196 # ffffffffc02062f8 <commands+0x8c0>
ffffffffc02017ac:	00005617          	auipc	a2,0x5
ffffffffc02017b0:	b1c60613          	addi	a2,a2,-1252 # ffffffffc02062c8 <commands+0x890>
ffffffffc02017b4:	11300593          	li	a1,275
ffffffffc02017b8:	00005517          	auipc	a0,0x5
ffffffffc02017bc:	b2850513          	addi	a0,a0,-1240 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc02017c0:	ccffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02017c4:	00005697          	auipc	a3,0x5
ffffffffc02017c8:	b7468693          	addi	a3,a3,-1164 # ffffffffc0206338 <commands+0x900>
ffffffffc02017cc:	00005617          	auipc	a2,0x5
ffffffffc02017d0:	afc60613          	addi	a2,a2,-1284 # ffffffffc02062c8 <commands+0x890>
ffffffffc02017d4:	0d800593          	li	a1,216
ffffffffc02017d8:	00005517          	auipc	a0,0x5
ffffffffc02017dc:	b0850513          	addi	a0,a0,-1272 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc02017e0:	caffe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02017e4 <default_free_pages>:
{
ffffffffc02017e4:	1141                	addi	sp,sp,-16
ffffffffc02017e6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02017e8:	14058463          	beqz	a1,ffffffffc0201930 <default_free_pages+0x14c>
    for (; p != base + n; p++)
ffffffffc02017ec:	00659693          	slli	a3,a1,0x6
ffffffffc02017f0:	96aa                	add	a3,a3,a0
ffffffffc02017f2:	87aa                	mv	a5,a0
ffffffffc02017f4:	02d50263          	beq	a0,a3,ffffffffc0201818 <default_free_pages+0x34>
ffffffffc02017f8:	6798                	ld	a4,8(a5)
ffffffffc02017fa:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02017fc:	10071a63          	bnez	a4,ffffffffc0201910 <default_free_pages+0x12c>
ffffffffc0201800:	6798                	ld	a4,8(a5)
ffffffffc0201802:	8b09                	andi	a4,a4,2
ffffffffc0201804:	10071663          	bnez	a4,ffffffffc0201910 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0201808:	0007b423          	sd	zero,8(a5)
}

static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
ffffffffc020180c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc0201810:	04078793          	addi	a5,a5,64
ffffffffc0201814:	fed792e3          	bne	a5,a3,ffffffffc02017f8 <default_free_pages+0x14>
    base->property = n;
ffffffffc0201818:	2581                	sext.w	a1,a1
ffffffffc020181a:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc020181c:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201820:	4789                	li	a5,2
ffffffffc0201822:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201826:	000a5697          	auipc	a3,0xa5
ffffffffc020182a:	e2a68693          	addi	a3,a3,-470 # ffffffffc02a6650 <free_area>
ffffffffc020182e:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201830:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201832:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201836:	9db9                	addw	a1,a1,a4
ffffffffc0201838:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc020183a:	0ad78463          	beq	a5,a3,ffffffffc02018e2 <default_free_pages+0xfe>
            struct Page *page = le2page(le, page_link);
ffffffffc020183e:	fe878713          	addi	a4,a5,-24
ffffffffc0201842:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc0201846:	4581                	li	a1,0
            if (base < page)
ffffffffc0201848:	00e56a63          	bltu	a0,a4,ffffffffc020185c <default_free_pages+0x78>
    return listelm->next;
ffffffffc020184c:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc020184e:	04d70c63          	beq	a4,a3,ffffffffc02018a6 <default_free_pages+0xc2>
    for (; p != base + n; p++)
ffffffffc0201852:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0201854:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0201858:	fee57ae3          	bgeu	a0,a4,ffffffffc020184c <default_free_pages+0x68>
ffffffffc020185c:	c199                	beqz	a1,ffffffffc0201862 <default_free_pages+0x7e>
ffffffffc020185e:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201862:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201864:	e390                	sd	a2,0(a5)
ffffffffc0201866:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201868:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020186a:	ed18                	sd	a4,24(a0)
    if (le != &free_list)
ffffffffc020186c:	00d70d63          	beq	a4,a3,ffffffffc0201886 <default_free_pages+0xa2>
        if (p + p->property == base)
ffffffffc0201870:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201874:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base)
ffffffffc0201878:	02059813          	slli	a6,a1,0x20
ffffffffc020187c:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201880:	97b2                	add	a5,a5,a2
ffffffffc0201882:	02f50c63          	beq	a0,a5,ffffffffc02018ba <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0201886:	711c                	ld	a5,32(a0)
    if (le != &free_list)
ffffffffc0201888:	00d78c63          	beq	a5,a3,ffffffffc02018a0 <default_free_pages+0xbc>
        if (base + base->property == p)
ffffffffc020188c:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc020188e:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p)
ffffffffc0201892:	02061593          	slli	a1,a2,0x20
ffffffffc0201896:	01a5d713          	srli	a4,a1,0x1a
ffffffffc020189a:	972a                	add	a4,a4,a0
ffffffffc020189c:	04e68a63          	beq	a3,a4,ffffffffc02018f0 <default_free_pages+0x10c>
}
ffffffffc02018a0:	60a2                	ld	ra,8(sp)
ffffffffc02018a2:	0141                	addi	sp,sp,16
ffffffffc02018a4:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02018a6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02018a8:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02018aa:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02018ac:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc02018ae:	02d70763          	beq	a4,a3,ffffffffc02018dc <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc02018b2:	8832                	mv	a6,a2
ffffffffc02018b4:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc02018b6:	87ba                	mv	a5,a4
ffffffffc02018b8:	bf71                	j	ffffffffc0201854 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc02018ba:	491c                	lw	a5,16(a0)
ffffffffc02018bc:	9dbd                	addw	a1,a1,a5
ffffffffc02018be:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02018c2:	57f5                	li	a5,-3
ffffffffc02018c4:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02018c8:	01853803          	ld	a6,24(a0)
ffffffffc02018cc:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc02018ce:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02018d0:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc02018d4:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc02018d6:	0105b023          	sd	a6,0(a1)
ffffffffc02018da:	b77d                	j	ffffffffc0201888 <default_free_pages+0xa4>
ffffffffc02018dc:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list)
ffffffffc02018de:	873e                	mv	a4,a5
ffffffffc02018e0:	bf41                	j	ffffffffc0201870 <default_free_pages+0x8c>
}
ffffffffc02018e2:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02018e4:	e390                	sd	a2,0(a5)
ffffffffc02018e6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02018e8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02018ea:	ed1c                	sd	a5,24(a0)
ffffffffc02018ec:	0141                	addi	sp,sp,16
ffffffffc02018ee:	8082                	ret
            base->property += p->property;
ffffffffc02018f0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02018f4:	ff078693          	addi	a3,a5,-16
ffffffffc02018f8:	9e39                	addw	a2,a2,a4
ffffffffc02018fa:	c910                	sw	a2,16(a0)
ffffffffc02018fc:	5775                	li	a4,-3
ffffffffc02018fe:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201902:	6398                	ld	a4,0(a5)
ffffffffc0201904:	679c                	ld	a5,8(a5)
}
ffffffffc0201906:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201908:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020190a:	e398                	sd	a4,0(a5)
ffffffffc020190c:	0141                	addi	sp,sp,16
ffffffffc020190e:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201910:	00005697          	auipc	a3,0x5
ffffffffc0201914:	d1868693          	addi	a3,a3,-744 # ffffffffc0206628 <commands+0xbf0>
ffffffffc0201918:	00005617          	auipc	a2,0x5
ffffffffc020191c:	9b060613          	addi	a2,a2,-1616 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201920:	09400593          	li	a1,148
ffffffffc0201924:	00005517          	auipc	a0,0x5
ffffffffc0201928:	9bc50513          	addi	a0,a0,-1604 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc020192c:	b63fe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(n > 0);
ffffffffc0201930:	00005697          	auipc	a3,0x5
ffffffffc0201934:	cf068693          	addi	a3,a3,-784 # ffffffffc0206620 <commands+0xbe8>
ffffffffc0201938:	00005617          	auipc	a2,0x5
ffffffffc020193c:	99060613          	addi	a2,a2,-1648 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201940:	09000593          	li	a1,144
ffffffffc0201944:	00005517          	auipc	a0,0x5
ffffffffc0201948:	99c50513          	addi	a0,a0,-1636 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc020194c:	b43fe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201950 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201950:	c941                	beqz	a0,ffffffffc02019e0 <default_alloc_pages+0x90>
    if (n > nr_free)
ffffffffc0201952:	000a5597          	auipc	a1,0xa5
ffffffffc0201956:	cfe58593          	addi	a1,a1,-770 # ffffffffc02a6650 <free_area>
ffffffffc020195a:	0105a803          	lw	a6,16(a1)
ffffffffc020195e:	872a                	mv	a4,a0
ffffffffc0201960:	02081793          	slli	a5,a6,0x20
ffffffffc0201964:	9381                	srli	a5,a5,0x20
ffffffffc0201966:	00a7ee63          	bltu	a5,a0,ffffffffc0201982 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc020196a:	87ae                	mv	a5,a1
ffffffffc020196c:	a801                	j	ffffffffc020197c <default_alloc_pages+0x2c>
        if (p->property >= n)
ffffffffc020196e:	ff87a683          	lw	a3,-8(a5)
ffffffffc0201972:	02069613          	slli	a2,a3,0x20
ffffffffc0201976:	9201                	srli	a2,a2,0x20
ffffffffc0201978:	00e67763          	bgeu	a2,a4,ffffffffc0201986 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc020197c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc020197e:	feb798e3          	bne	a5,a1,ffffffffc020196e <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201982:	4501                	li	a0,0
}
ffffffffc0201984:	8082                	ret
    return listelm->prev;
ffffffffc0201986:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020198a:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc020198e:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0201992:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0201996:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc020199a:	01133023          	sd	a7,0(t1)
        if (page->property > n)
ffffffffc020199e:	02c77863          	bgeu	a4,a2,ffffffffc02019ce <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc02019a2:	071a                	slli	a4,a4,0x6
ffffffffc02019a4:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc02019a6:	41c686bb          	subw	a3,a3,t3
ffffffffc02019aa:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02019ac:	00870613          	addi	a2,a4,8
ffffffffc02019b0:	4689                	li	a3,2
ffffffffc02019b2:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02019b6:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02019ba:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc02019be:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc02019c2:	e290                	sd	a2,0(a3)
ffffffffc02019c4:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02019c8:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc02019ca:	01173c23          	sd	a7,24(a4)
ffffffffc02019ce:	41c8083b          	subw	a6,a6,t3
ffffffffc02019d2:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02019d6:	5775                	li	a4,-3
ffffffffc02019d8:	17c1                	addi	a5,a5,-16
ffffffffc02019da:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc02019de:	8082                	ret
{
ffffffffc02019e0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02019e2:	00005697          	auipc	a3,0x5
ffffffffc02019e6:	c3e68693          	addi	a3,a3,-962 # ffffffffc0206620 <commands+0xbe8>
ffffffffc02019ea:	00005617          	auipc	a2,0x5
ffffffffc02019ee:	8de60613          	addi	a2,a2,-1826 # ffffffffc02062c8 <commands+0x890>
ffffffffc02019f2:	06c00593          	li	a1,108
ffffffffc02019f6:	00005517          	auipc	a0,0x5
ffffffffc02019fa:	8ea50513          	addi	a0,a0,-1814 # ffffffffc02062e0 <commands+0x8a8>
{
ffffffffc02019fe:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201a00:	a8ffe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201a04 <default_init_memmap>:
{
ffffffffc0201a04:	1141                	addi	sp,sp,-16
ffffffffc0201a06:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201a08:	c5f1                	beqz	a1,ffffffffc0201ad4 <default_init_memmap+0xd0>
    for (; p != base + n; p++)
ffffffffc0201a0a:	00659693          	slli	a3,a1,0x6
ffffffffc0201a0e:	96aa                	add	a3,a3,a0
ffffffffc0201a10:	87aa                	mv	a5,a0
ffffffffc0201a12:	00d50f63          	beq	a0,a3,ffffffffc0201a30 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201a16:	6798                	ld	a4,8(a5)
ffffffffc0201a18:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc0201a1a:	cf49                	beqz	a4,ffffffffc0201ab4 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0201a1c:	0007a823          	sw	zero,16(a5)
ffffffffc0201a20:	0007b423          	sd	zero,8(a5)
ffffffffc0201a24:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc0201a28:	04078793          	addi	a5,a5,64
ffffffffc0201a2c:	fed795e3          	bne	a5,a3,ffffffffc0201a16 <default_init_memmap+0x12>
    base->property = n;
ffffffffc0201a30:	2581                	sext.w	a1,a1
ffffffffc0201a32:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201a34:	4789                	li	a5,2
ffffffffc0201a36:	00850713          	addi	a4,a0,8
ffffffffc0201a3a:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201a3e:	000a5697          	auipc	a3,0xa5
ffffffffc0201a42:	c1268693          	addi	a3,a3,-1006 # ffffffffc02a6650 <free_area>
ffffffffc0201a46:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201a48:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201a4a:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201a4e:	9db9                	addw	a1,a1,a4
ffffffffc0201a50:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc0201a52:	04d78a63          	beq	a5,a3,ffffffffc0201aa6 <default_init_memmap+0xa2>
            struct Page *page = le2page(le, page_link);
ffffffffc0201a56:	fe878713          	addi	a4,a5,-24
ffffffffc0201a5a:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc0201a5e:	4581                	li	a1,0
            if (base < page)
ffffffffc0201a60:	00e56a63          	bltu	a0,a4,ffffffffc0201a74 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0201a64:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc0201a66:	02d70263          	beq	a4,a3,ffffffffc0201a8a <default_init_memmap+0x86>
    for (; p != base + n; p++)
ffffffffc0201a6a:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0201a6c:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0201a70:	fee57ae3          	bgeu	a0,a4,ffffffffc0201a64 <default_init_memmap+0x60>
ffffffffc0201a74:	c199                	beqz	a1,ffffffffc0201a7a <default_init_memmap+0x76>
ffffffffc0201a76:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201a7a:	6398                	ld	a4,0(a5)
}
ffffffffc0201a7c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201a7e:	e390                	sd	a2,0(a5)
ffffffffc0201a80:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201a82:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201a84:	ed18                	sd	a4,24(a0)
ffffffffc0201a86:	0141                	addi	sp,sp,16
ffffffffc0201a88:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201a8a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201a8c:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201a8e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201a90:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc0201a92:	00d70663          	beq	a4,a3,ffffffffc0201a9e <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0201a96:	8832                	mv	a6,a2
ffffffffc0201a98:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc0201a9a:	87ba                	mv	a5,a4
ffffffffc0201a9c:	bfc1                	j	ffffffffc0201a6c <default_init_memmap+0x68>
}
ffffffffc0201a9e:	60a2                	ld	ra,8(sp)
ffffffffc0201aa0:	e290                	sd	a2,0(a3)
ffffffffc0201aa2:	0141                	addi	sp,sp,16
ffffffffc0201aa4:	8082                	ret
ffffffffc0201aa6:	60a2                	ld	ra,8(sp)
ffffffffc0201aa8:	e390                	sd	a2,0(a5)
ffffffffc0201aaa:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201aac:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201aae:	ed1c                	sd	a5,24(a0)
ffffffffc0201ab0:	0141                	addi	sp,sp,16
ffffffffc0201ab2:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201ab4:	00005697          	auipc	a3,0x5
ffffffffc0201ab8:	b9c68693          	addi	a3,a3,-1124 # ffffffffc0206650 <commands+0xc18>
ffffffffc0201abc:	00005617          	auipc	a2,0x5
ffffffffc0201ac0:	80c60613          	addi	a2,a2,-2036 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201ac4:	04b00593          	li	a1,75
ffffffffc0201ac8:	00005517          	auipc	a0,0x5
ffffffffc0201acc:	81850513          	addi	a0,a0,-2024 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201ad0:	9bffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(n > 0);
ffffffffc0201ad4:	00005697          	auipc	a3,0x5
ffffffffc0201ad8:	b4c68693          	addi	a3,a3,-1204 # ffffffffc0206620 <commands+0xbe8>
ffffffffc0201adc:	00004617          	auipc	a2,0x4
ffffffffc0201ae0:	7ec60613          	addi	a2,a2,2028 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201ae4:	04700593          	li	a1,71
ffffffffc0201ae8:	00004517          	auipc	a0,0x4
ffffffffc0201aec:	7f850513          	addi	a0,a0,2040 # ffffffffc02062e0 <commands+0x8a8>
ffffffffc0201af0:	99ffe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201af4 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201af4:	c94d                	beqz	a0,ffffffffc0201ba6 <slob_free+0xb2>
{
ffffffffc0201af6:	1141                	addi	sp,sp,-16
ffffffffc0201af8:	e022                	sd	s0,0(sp)
ffffffffc0201afa:	e406                	sd	ra,8(sp)
ffffffffc0201afc:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc0201afe:	e9c1                	bnez	a1,ffffffffc0201b8e <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b00:	100027f3          	csrr	a5,sstatus
ffffffffc0201b04:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201b06:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b08:	ebd9                	bnez	a5,ffffffffc0201b9e <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201b0a:	000a4617          	auipc	a2,0xa4
ffffffffc0201b0e:	73660613          	addi	a2,a2,1846 # ffffffffc02a6240 <slobfree>
ffffffffc0201b12:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201b14:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201b16:	679c                	ld	a5,8(a5)
ffffffffc0201b18:	02877a63          	bgeu	a4,s0,ffffffffc0201b4c <slob_free+0x58>
ffffffffc0201b1c:	00f46463          	bltu	s0,a5,ffffffffc0201b24 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201b20:	fef76ae3          	bltu	a4,a5,ffffffffc0201b14 <slob_free+0x20>
			break;

	if (b + b->units == cur->next)
ffffffffc0201b24:	400c                	lw	a1,0(s0)
ffffffffc0201b26:	00459693          	slli	a3,a1,0x4
ffffffffc0201b2a:	96a2                	add	a3,a3,s0
ffffffffc0201b2c:	02d78a63          	beq	a5,a3,ffffffffc0201b60 <slob_free+0x6c>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc0201b30:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0201b32:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0201b34:	00469793          	slli	a5,a3,0x4
ffffffffc0201b38:	97ba                	add	a5,a5,a4
ffffffffc0201b3a:	02f40e63          	beq	s0,a5,ffffffffc0201b76 <slob_free+0x82>
	{
		cur->units += b->units;
		cur->next = b->next;
	}
	else
		cur->next = b;
ffffffffc0201b3e:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0201b40:	e218                	sd	a4,0(a2)
    if (flag)
ffffffffc0201b42:	e129                	bnez	a0,ffffffffc0201b84 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201b44:	60a2                	ld	ra,8(sp)
ffffffffc0201b46:	6402                	ld	s0,0(sp)
ffffffffc0201b48:	0141                	addi	sp,sp,16
ffffffffc0201b4a:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201b4c:	fcf764e3          	bltu	a4,a5,ffffffffc0201b14 <slob_free+0x20>
ffffffffc0201b50:	fcf472e3          	bgeu	s0,a5,ffffffffc0201b14 <slob_free+0x20>
	if (b + b->units == cur->next)
ffffffffc0201b54:	400c                	lw	a1,0(s0)
ffffffffc0201b56:	00459693          	slli	a3,a1,0x4
ffffffffc0201b5a:	96a2                	add	a3,a3,s0
ffffffffc0201b5c:	fcd79ae3          	bne	a5,a3,ffffffffc0201b30 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0201b60:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201b62:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201b64:	9db5                	addw	a1,a1,a3
ffffffffc0201b66:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b)
ffffffffc0201b68:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201b6a:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0201b6c:	00469793          	slli	a5,a3,0x4
ffffffffc0201b70:	97ba                	add	a5,a5,a4
ffffffffc0201b72:	fcf416e3          	bne	s0,a5,ffffffffc0201b3e <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0201b76:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201b78:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0201b7a:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201b7c:	9ebd                	addw	a3,a3,a5
ffffffffc0201b7e:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0201b80:	e70c                	sd	a1,8(a4)
ffffffffc0201b82:	d169                	beqz	a0,ffffffffc0201b44 <slob_free+0x50>
}
ffffffffc0201b84:	6402                	ld	s0,0(sp)
ffffffffc0201b86:	60a2                	ld	ra,8(sp)
ffffffffc0201b88:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201b8a:	e25fe06f          	j	ffffffffc02009ae <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0201b8e:	25bd                	addiw	a1,a1,15
ffffffffc0201b90:	8191                	srli	a1,a1,0x4
ffffffffc0201b92:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b94:	100027f3          	csrr	a5,sstatus
ffffffffc0201b98:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201b9a:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b9c:	d7bd                	beqz	a5,ffffffffc0201b0a <slob_free+0x16>
        intr_disable();
ffffffffc0201b9e:	e17fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc0201ba2:	4505                	li	a0,1
ffffffffc0201ba4:	b79d                	j	ffffffffc0201b0a <slob_free+0x16>
ffffffffc0201ba6:	8082                	ret

ffffffffc0201ba8 <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201ba8:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201baa:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201bac:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201bb0:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201bb2:	352000ef          	jal	ra,ffffffffc0201f04 <alloc_pages>
	if (!page)
ffffffffc0201bb6:	c91d                	beqz	a0,ffffffffc0201bec <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201bb8:	000a9697          	auipc	a3,0xa9
ffffffffc0201bbc:	b106b683          	ld	a3,-1264(a3) # ffffffffc02aa6c8 <pages>
ffffffffc0201bc0:	8d15                	sub	a0,a0,a3
ffffffffc0201bc2:	8519                	srai	a0,a0,0x6
ffffffffc0201bc4:	00006697          	auipc	a3,0x6
ffffffffc0201bc8:	e6c6b683          	ld	a3,-404(a3) # ffffffffc0207a30 <nbase>
ffffffffc0201bcc:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201bce:	00c51793          	slli	a5,a0,0xc
ffffffffc0201bd2:	83b1                	srli	a5,a5,0xc
ffffffffc0201bd4:	000a9717          	auipc	a4,0xa9
ffffffffc0201bd8:	aec73703          	ld	a4,-1300(a4) # ffffffffc02aa6c0 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201bdc:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201bde:	00e7fa63          	bgeu	a5,a4,ffffffffc0201bf2 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201be2:	000a9697          	auipc	a3,0xa9
ffffffffc0201be6:	af66b683          	ld	a3,-1290(a3) # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc0201bea:	9536                	add	a0,a0,a3
}
ffffffffc0201bec:	60a2                	ld	ra,8(sp)
ffffffffc0201bee:	0141                	addi	sp,sp,16
ffffffffc0201bf0:	8082                	ret
ffffffffc0201bf2:	86aa                	mv	a3,a0
ffffffffc0201bf4:	00005617          	auipc	a2,0x5
ffffffffc0201bf8:	abc60613          	addi	a2,a2,-1348 # ffffffffc02066b0 <default_pmm_manager+0x38>
ffffffffc0201bfc:	07100593          	li	a1,113
ffffffffc0201c00:	00005517          	auipc	a0,0x5
ffffffffc0201c04:	ad850513          	addi	a0,a0,-1320 # ffffffffc02066d8 <default_pmm_manager+0x60>
ffffffffc0201c08:	887fe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201c0c <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201c0c:	1101                	addi	sp,sp,-32
ffffffffc0201c0e:	ec06                	sd	ra,24(sp)
ffffffffc0201c10:	e822                	sd	s0,16(sp)
ffffffffc0201c12:	e426                	sd	s1,8(sp)
ffffffffc0201c14:	e04a                	sd	s2,0(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201c16:	01050713          	addi	a4,a0,16
ffffffffc0201c1a:	6785                	lui	a5,0x1
ffffffffc0201c1c:	0cf77363          	bgeu	a4,a5,ffffffffc0201ce2 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201c20:	00f50493          	addi	s1,a0,15
ffffffffc0201c24:	8091                	srli	s1,s1,0x4
ffffffffc0201c26:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201c28:	10002673          	csrr	a2,sstatus
ffffffffc0201c2c:	8a09                	andi	a2,a2,2
ffffffffc0201c2e:	e25d                	bnez	a2,ffffffffc0201cd4 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201c30:	000a4917          	auipc	s2,0xa4
ffffffffc0201c34:	61090913          	addi	s2,s2,1552 # ffffffffc02a6240 <slobfree>
ffffffffc0201c38:	00093683          	ld	a3,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201c3c:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta)
ffffffffc0201c3e:	4398                	lw	a4,0(a5)
ffffffffc0201c40:	08975e63          	bge	a4,s1,ffffffffc0201cdc <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree)
ffffffffc0201c44:	00f68b63          	beq	a3,a5,ffffffffc0201c5a <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201c48:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201c4a:	4018                	lw	a4,0(s0)
ffffffffc0201c4c:	02975a63          	bge	a4,s1,ffffffffc0201c80 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree)
ffffffffc0201c50:	00093683          	ld	a3,0(s2)
ffffffffc0201c54:	87a2                	mv	a5,s0
ffffffffc0201c56:	fef699e3          	bne	a3,a5,ffffffffc0201c48 <slob_alloc.constprop.0+0x3c>
    if (flag)
ffffffffc0201c5a:	ee31                	bnez	a2,ffffffffc0201cb6 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201c5c:	4501                	li	a0,0
ffffffffc0201c5e:	f4bff0ef          	jal	ra,ffffffffc0201ba8 <__slob_get_free_pages.constprop.0>
ffffffffc0201c62:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201c64:	cd05                	beqz	a0,ffffffffc0201c9c <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201c66:	6585                	lui	a1,0x1
ffffffffc0201c68:	e8dff0ef          	jal	ra,ffffffffc0201af4 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201c6c:	10002673          	csrr	a2,sstatus
ffffffffc0201c70:	8a09                	andi	a2,a2,2
ffffffffc0201c72:	ee05                	bnez	a2,ffffffffc0201caa <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201c74:	00093783          	ld	a5,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201c78:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201c7a:	4018                	lw	a4,0(s0)
ffffffffc0201c7c:	fc974ae3          	blt	a4,s1,ffffffffc0201c50 <slob_alloc.constprop.0+0x44>
			if (cur->units == units)	/* exact fit? */
ffffffffc0201c80:	04e48763          	beq	s1,a4,ffffffffc0201cce <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201c84:	00449693          	slli	a3,s1,0x4
ffffffffc0201c88:	96a2                	add	a3,a3,s0
ffffffffc0201c8a:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201c8c:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201c8e:	9f05                	subw	a4,a4,s1
ffffffffc0201c90:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201c92:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201c94:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201c96:	00f93023          	sd	a5,0(s2)
    if (flag)
ffffffffc0201c9a:	e20d                	bnez	a2,ffffffffc0201cbc <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201c9c:	60e2                	ld	ra,24(sp)
ffffffffc0201c9e:	8522                	mv	a0,s0
ffffffffc0201ca0:	6442                	ld	s0,16(sp)
ffffffffc0201ca2:	64a2                	ld	s1,8(sp)
ffffffffc0201ca4:	6902                	ld	s2,0(sp)
ffffffffc0201ca6:	6105                	addi	sp,sp,32
ffffffffc0201ca8:	8082                	ret
        intr_disable();
ffffffffc0201caa:	d0bfe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
			cur = slobfree;
ffffffffc0201cae:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201cb2:	4605                	li	a2,1
ffffffffc0201cb4:	b7d1                	j	ffffffffc0201c78 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201cb6:	cf9fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0201cba:	b74d                	j	ffffffffc0201c5c <slob_alloc.constprop.0+0x50>
ffffffffc0201cbc:	cf3fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
}
ffffffffc0201cc0:	60e2                	ld	ra,24(sp)
ffffffffc0201cc2:	8522                	mv	a0,s0
ffffffffc0201cc4:	6442                	ld	s0,16(sp)
ffffffffc0201cc6:	64a2                	ld	s1,8(sp)
ffffffffc0201cc8:	6902                	ld	s2,0(sp)
ffffffffc0201cca:	6105                	addi	sp,sp,32
ffffffffc0201ccc:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201cce:	6418                	ld	a4,8(s0)
ffffffffc0201cd0:	e798                	sd	a4,8(a5)
ffffffffc0201cd2:	b7d1                	j	ffffffffc0201c96 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201cd4:	ce1fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc0201cd8:	4605                	li	a2,1
ffffffffc0201cda:	bf99                	j	ffffffffc0201c30 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta)
ffffffffc0201cdc:	843e                	mv	s0,a5
ffffffffc0201cde:	87b6                	mv	a5,a3
ffffffffc0201ce0:	b745                	j	ffffffffc0201c80 <slob_alloc.constprop.0+0x74>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201ce2:	00005697          	auipc	a3,0x5
ffffffffc0201ce6:	a0668693          	addi	a3,a3,-1530 # ffffffffc02066e8 <default_pmm_manager+0x70>
ffffffffc0201cea:	00004617          	auipc	a2,0x4
ffffffffc0201cee:	5de60613          	addi	a2,a2,1502 # ffffffffc02062c8 <commands+0x890>
ffffffffc0201cf2:	06300593          	li	a1,99
ffffffffc0201cf6:	00005517          	auipc	a0,0x5
ffffffffc0201cfa:	a1250513          	addi	a0,a0,-1518 # ffffffffc0206708 <default_pmm_manager+0x90>
ffffffffc0201cfe:	f90fe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201d02 <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc0201d02:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc0201d04:	00005517          	auipc	a0,0x5
ffffffffc0201d08:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0206720 <default_pmm_manager+0xa8>
{
ffffffffc0201d0c:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc0201d0e:	c86fe0ef          	jal	ra,ffffffffc0200194 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201d12:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201d14:	00005517          	auipc	a0,0x5
ffffffffc0201d18:	a2450513          	addi	a0,a0,-1500 # ffffffffc0206738 <default_pmm_manager+0xc0>
}
ffffffffc0201d1c:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201d1e:	c76fe06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0201d22 <kallocated>:

size_t
kallocated(void)
{
	return slob_allocated();
}
ffffffffc0201d22:	4501                	li	a0,0
ffffffffc0201d24:	8082                	ret

ffffffffc0201d26 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201d26:	1101                	addi	sp,sp,-32
ffffffffc0201d28:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201d2a:	6905                	lui	s2,0x1
{
ffffffffc0201d2c:	e822                	sd	s0,16(sp)
ffffffffc0201d2e:	ec06                	sd	ra,24(sp)
ffffffffc0201d30:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201d32:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bb9>
{
ffffffffc0201d36:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201d38:	04a7f963          	bgeu	a5,a0,ffffffffc0201d8a <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201d3c:	4561                	li	a0,24
ffffffffc0201d3e:	ecfff0ef          	jal	ra,ffffffffc0201c0c <slob_alloc.constprop.0>
ffffffffc0201d42:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201d44:	c929                	beqz	a0,ffffffffc0201d96 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201d46:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201d4a:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc0201d4c:	00f95763          	bge	s2,a5,ffffffffc0201d5a <kmalloc+0x34>
ffffffffc0201d50:	6705                	lui	a4,0x1
ffffffffc0201d52:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201d54:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc0201d56:	fef74ee3          	blt	a4,a5,ffffffffc0201d52 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201d5a:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201d5c:	e4dff0ef          	jal	ra,ffffffffc0201ba8 <__slob_get_free_pages.constprop.0>
ffffffffc0201d60:	e488                	sd	a0,8(s1)
ffffffffc0201d62:	842a                	mv	s0,a0
	if (bb->pages)
ffffffffc0201d64:	c525                	beqz	a0,ffffffffc0201dcc <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201d66:	100027f3          	csrr	a5,sstatus
ffffffffc0201d6a:	8b89                	andi	a5,a5,2
ffffffffc0201d6c:	ef8d                	bnez	a5,ffffffffc0201da6 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201d6e:	000a9797          	auipc	a5,0xa9
ffffffffc0201d72:	93a78793          	addi	a5,a5,-1734 # ffffffffc02aa6a8 <bigblocks>
ffffffffc0201d76:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201d78:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201d7a:	e898                	sd	a4,16(s1)
	return __kmalloc(size, 0);
}
ffffffffc0201d7c:	60e2                	ld	ra,24(sp)
ffffffffc0201d7e:	8522                	mv	a0,s0
ffffffffc0201d80:	6442                	ld	s0,16(sp)
ffffffffc0201d82:	64a2                	ld	s1,8(sp)
ffffffffc0201d84:	6902                	ld	s2,0(sp)
ffffffffc0201d86:	6105                	addi	sp,sp,32
ffffffffc0201d88:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201d8a:	0541                	addi	a0,a0,16
ffffffffc0201d8c:	e81ff0ef          	jal	ra,ffffffffc0201c0c <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201d90:	01050413          	addi	s0,a0,16
ffffffffc0201d94:	f565                	bnez	a0,ffffffffc0201d7c <kmalloc+0x56>
ffffffffc0201d96:	4401                	li	s0,0
}
ffffffffc0201d98:	60e2                	ld	ra,24(sp)
ffffffffc0201d9a:	8522                	mv	a0,s0
ffffffffc0201d9c:	6442                	ld	s0,16(sp)
ffffffffc0201d9e:	64a2                	ld	s1,8(sp)
ffffffffc0201da0:	6902                	ld	s2,0(sp)
ffffffffc0201da2:	6105                	addi	sp,sp,32
ffffffffc0201da4:	8082                	ret
        intr_disable();
ffffffffc0201da6:	c0ffe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201daa:	000a9797          	auipc	a5,0xa9
ffffffffc0201dae:	8fe78793          	addi	a5,a5,-1794 # ffffffffc02aa6a8 <bigblocks>
ffffffffc0201db2:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201db4:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201db6:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201db8:	bf7fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
		return bb->pages;
ffffffffc0201dbc:	6480                	ld	s0,8(s1)
}
ffffffffc0201dbe:	60e2                	ld	ra,24(sp)
ffffffffc0201dc0:	64a2                	ld	s1,8(sp)
ffffffffc0201dc2:	8522                	mv	a0,s0
ffffffffc0201dc4:	6442                	ld	s0,16(sp)
ffffffffc0201dc6:	6902                	ld	s2,0(sp)
ffffffffc0201dc8:	6105                	addi	sp,sp,32
ffffffffc0201dca:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201dcc:	45e1                	li	a1,24
ffffffffc0201dce:	8526                	mv	a0,s1
ffffffffc0201dd0:	d25ff0ef          	jal	ra,ffffffffc0201af4 <slob_free>
	return __kmalloc(size, 0);
ffffffffc0201dd4:	b765                	j	ffffffffc0201d7c <kmalloc+0x56>

ffffffffc0201dd6 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201dd6:	c169                	beqz	a0,ffffffffc0201e98 <kfree+0xc2>
{
ffffffffc0201dd8:	1101                	addi	sp,sp,-32
ffffffffc0201dda:	e822                	sd	s0,16(sp)
ffffffffc0201ddc:	ec06                	sd	ra,24(sp)
ffffffffc0201dde:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201de0:	03451793          	slli	a5,a0,0x34
ffffffffc0201de4:	842a                	mv	s0,a0
ffffffffc0201de6:	e3d9                	bnez	a5,ffffffffc0201e6c <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201de8:	100027f3          	csrr	a5,sstatus
ffffffffc0201dec:	8b89                	andi	a5,a5,2
ffffffffc0201dee:	e7d9                	bnez	a5,ffffffffc0201e7c <kfree+0xa6>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201df0:	000a9797          	auipc	a5,0xa9
ffffffffc0201df4:	8b87b783          	ld	a5,-1864(a5) # ffffffffc02aa6a8 <bigblocks>
    return 0;
ffffffffc0201df8:	4601                	li	a2,0
ffffffffc0201dfa:	cbad                	beqz	a5,ffffffffc0201e6c <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201dfc:	000a9697          	auipc	a3,0xa9
ffffffffc0201e00:	8ac68693          	addi	a3,a3,-1876 # ffffffffc02aa6a8 <bigblocks>
ffffffffc0201e04:	a021                	j	ffffffffc0201e0c <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201e06:	01048693          	addi	a3,s1,16
ffffffffc0201e0a:	c3a5                	beqz	a5,ffffffffc0201e6a <kfree+0x94>
		{
			if (bb->pages == block)
ffffffffc0201e0c:	6798                	ld	a4,8(a5)
ffffffffc0201e0e:	84be                	mv	s1,a5
			{
				*last = bb->next;
ffffffffc0201e10:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc0201e12:	fe871ae3          	bne	a4,s0,ffffffffc0201e06 <kfree+0x30>
				*last = bb->next;
ffffffffc0201e16:	e29c                	sd	a5,0(a3)
    if (flag)
ffffffffc0201e18:	ee2d                	bnez	a2,ffffffffc0201e92 <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201e1a:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201e1e:	4098                	lw	a4,0(s1)
ffffffffc0201e20:	08f46963          	bltu	s0,a5,ffffffffc0201eb2 <kfree+0xdc>
ffffffffc0201e24:	000a9697          	auipc	a3,0xa9
ffffffffc0201e28:	8b46b683          	ld	a3,-1868(a3) # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc0201e2c:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage)
ffffffffc0201e2e:	8031                	srli	s0,s0,0xc
ffffffffc0201e30:	000a9797          	auipc	a5,0xa9
ffffffffc0201e34:	8907b783          	ld	a5,-1904(a5) # ffffffffc02aa6c0 <npage>
ffffffffc0201e38:	06f47163          	bgeu	s0,a5,ffffffffc0201e9a <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e3c:	00006517          	auipc	a0,0x6
ffffffffc0201e40:	bf453503          	ld	a0,-1036(a0) # ffffffffc0207a30 <nbase>
ffffffffc0201e44:	8c09                	sub	s0,s0,a0
ffffffffc0201e46:	041a                	slli	s0,s0,0x6
	free_pages(kva2page(kva), 1 << order);
ffffffffc0201e48:	000a9517          	auipc	a0,0xa9
ffffffffc0201e4c:	88053503          	ld	a0,-1920(a0) # ffffffffc02aa6c8 <pages>
ffffffffc0201e50:	4585                	li	a1,1
ffffffffc0201e52:	9522                	add	a0,a0,s0
ffffffffc0201e54:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201e58:	0ea000ef          	jal	ra,ffffffffc0201f42 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201e5c:	6442                	ld	s0,16(sp)
ffffffffc0201e5e:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201e60:	8526                	mv	a0,s1
}
ffffffffc0201e62:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201e64:	45e1                	li	a1,24
}
ffffffffc0201e66:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201e68:	b171                	j	ffffffffc0201af4 <slob_free>
ffffffffc0201e6a:	e20d                	bnez	a2,ffffffffc0201e8c <kfree+0xb6>
ffffffffc0201e6c:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201e70:	6442                	ld	s0,16(sp)
ffffffffc0201e72:	60e2                	ld	ra,24(sp)
ffffffffc0201e74:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201e76:	4581                	li	a1,0
}
ffffffffc0201e78:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201e7a:	b9ad                	j	ffffffffc0201af4 <slob_free>
        intr_disable();
ffffffffc0201e7c:	b39fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201e80:	000a9797          	auipc	a5,0xa9
ffffffffc0201e84:	8287b783          	ld	a5,-2008(a5) # ffffffffc02aa6a8 <bigblocks>
        return 1;
ffffffffc0201e88:	4605                	li	a2,1
ffffffffc0201e8a:	fbad                	bnez	a5,ffffffffc0201dfc <kfree+0x26>
        intr_enable();
ffffffffc0201e8c:	b23fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0201e90:	bff1                	j	ffffffffc0201e6c <kfree+0x96>
ffffffffc0201e92:	b1dfe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0201e96:	b751                	j	ffffffffc0201e1a <kfree+0x44>
ffffffffc0201e98:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201e9a:	00005617          	auipc	a2,0x5
ffffffffc0201e9e:	8e660613          	addi	a2,a2,-1818 # ffffffffc0206780 <default_pmm_manager+0x108>
ffffffffc0201ea2:	06900593          	li	a1,105
ffffffffc0201ea6:	00005517          	auipc	a0,0x5
ffffffffc0201eaa:	83250513          	addi	a0,a0,-1998 # ffffffffc02066d8 <default_pmm_manager+0x60>
ffffffffc0201eae:	de0fe0ef          	jal	ra,ffffffffc020048e <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201eb2:	86a2                	mv	a3,s0
ffffffffc0201eb4:	00005617          	auipc	a2,0x5
ffffffffc0201eb8:	8a460613          	addi	a2,a2,-1884 # ffffffffc0206758 <default_pmm_manager+0xe0>
ffffffffc0201ebc:	07700593          	li	a1,119
ffffffffc0201ec0:	00005517          	auipc	a0,0x5
ffffffffc0201ec4:	81850513          	addi	a0,a0,-2024 # ffffffffc02066d8 <default_pmm_manager+0x60>
ffffffffc0201ec8:	dc6fe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201ecc <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc0201ecc:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201ece:	00005617          	auipc	a2,0x5
ffffffffc0201ed2:	8b260613          	addi	a2,a2,-1870 # ffffffffc0206780 <default_pmm_manager+0x108>
ffffffffc0201ed6:	06900593          	li	a1,105
ffffffffc0201eda:	00004517          	auipc	a0,0x4
ffffffffc0201ede:	7fe50513          	addi	a0,a0,2046 # ffffffffc02066d8 <default_pmm_manager+0x60>
pa2page(uintptr_t pa)
ffffffffc0201ee2:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201ee4:	daafe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201ee8 <pte2page.part.0>:
pte2page(pte_t pte)
ffffffffc0201ee8:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201eea:	00005617          	auipc	a2,0x5
ffffffffc0201eee:	8b660613          	addi	a2,a2,-1866 # ffffffffc02067a0 <default_pmm_manager+0x128>
ffffffffc0201ef2:	07f00593          	li	a1,127
ffffffffc0201ef6:	00004517          	auipc	a0,0x4
ffffffffc0201efa:	7e250513          	addi	a0,a0,2018 # ffffffffc02066d8 <default_pmm_manager+0x60>
pte2page(pte_t pte)
ffffffffc0201efe:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201f00:	d8efe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201f04 <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201f04:	100027f3          	csrr	a5,sstatus
ffffffffc0201f08:	8b89                	andi	a5,a5,2
ffffffffc0201f0a:	e799                	bnez	a5,ffffffffc0201f18 <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201f0c:	000a8797          	auipc	a5,0xa8
ffffffffc0201f10:	7c47b783          	ld	a5,1988(a5) # ffffffffc02aa6d0 <pmm_manager>
ffffffffc0201f14:	6f9c                	ld	a5,24(a5)
ffffffffc0201f16:	8782                	jr	a5
{
ffffffffc0201f18:	1141                	addi	sp,sp,-16
ffffffffc0201f1a:	e406                	sd	ra,8(sp)
ffffffffc0201f1c:	e022                	sd	s0,0(sp)
ffffffffc0201f1e:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201f20:	a95fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201f24:	000a8797          	auipc	a5,0xa8
ffffffffc0201f28:	7ac7b783          	ld	a5,1964(a5) # ffffffffc02aa6d0 <pmm_manager>
ffffffffc0201f2c:	6f9c                	ld	a5,24(a5)
ffffffffc0201f2e:	8522                	mv	a0,s0
ffffffffc0201f30:	9782                	jalr	a5
ffffffffc0201f32:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201f34:	a7bfe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201f38:	60a2                	ld	ra,8(sp)
ffffffffc0201f3a:	8522                	mv	a0,s0
ffffffffc0201f3c:	6402                	ld	s0,0(sp)
ffffffffc0201f3e:	0141                	addi	sp,sp,16
ffffffffc0201f40:	8082                	ret

ffffffffc0201f42 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201f42:	100027f3          	csrr	a5,sstatus
ffffffffc0201f46:	8b89                	andi	a5,a5,2
ffffffffc0201f48:	e799                	bnez	a5,ffffffffc0201f56 <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201f4a:	000a8797          	auipc	a5,0xa8
ffffffffc0201f4e:	7867b783          	ld	a5,1926(a5) # ffffffffc02aa6d0 <pmm_manager>
ffffffffc0201f52:	739c                	ld	a5,32(a5)
ffffffffc0201f54:	8782                	jr	a5
{
ffffffffc0201f56:	1101                	addi	sp,sp,-32
ffffffffc0201f58:	ec06                	sd	ra,24(sp)
ffffffffc0201f5a:	e822                	sd	s0,16(sp)
ffffffffc0201f5c:	e426                	sd	s1,8(sp)
ffffffffc0201f5e:	842a                	mv	s0,a0
ffffffffc0201f60:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201f62:	a53fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201f66:	000a8797          	auipc	a5,0xa8
ffffffffc0201f6a:	76a7b783          	ld	a5,1898(a5) # ffffffffc02aa6d0 <pmm_manager>
ffffffffc0201f6e:	739c                	ld	a5,32(a5)
ffffffffc0201f70:	85a6                	mv	a1,s1
ffffffffc0201f72:	8522                	mv	a0,s0
ffffffffc0201f74:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201f76:	6442                	ld	s0,16(sp)
ffffffffc0201f78:	60e2                	ld	ra,24(sp)
ffffffffc0201f7a:	64a2                	ld	s1,8(sp)
ffffffffc0201f7c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201f7e:	a31fe06f          	j	ffffffffc02009ae <intr_enable>

ffffffffc0201f82 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201f82:	100027f3          	csrr	a5,sstatus
ffffffffc0201f86:	8b89                	andi	a5,a5,2
ffffffffc0201f88:	e799                	bnez	a5,ffffffffc0201f96 <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f8a:	000a8797          	auipc	a5,0xa8
ffffffffc0201f8e:	7467b783          	ld	a5,1862(a5) # ffffffffc02aa6d0 <pmm_manager>
ffffffffc0201f92:	779c                	ld	a5,40(a5)
ffffffffc0201f94:	8782                	jr	a5
{
ffffffffc0201f96:	1141                	addi	sp,sp,-16
ffffffffc0201f98:	e406                	sd	ra,8(sp)
ffffffffc0201f9a:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201f9c:	a19fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201fa0:	000a8797          	auipc	a5,0xa8
ffffffffc0201fa4:	7307b783          	ld	a5,1840(a5) # ffffffffc02aa6d0 <pmm_manager>
ffffffffc0201fa8:	779c                	ld	a5,40(a5)
ffffffffc0201faa:	9782                	jalr	a5
ffffffffc0201fac:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201fae:	a01fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201fb2:	60a2                	ld	ra,8(sp)
ffffffffc0201fb4:	8522                	mv	a0,s0
ffffffffc0201fb6:	6402                	ld	s0,0(sp)
ffffffffc0201fb8:	0141                	addi	sp,sp,16
ffffffffc0201fba:	8082                	ret

ffffffffc0201fbc <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201fbc:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201fc0:	1ff7f793          	andi	a5,a5,511
{
ffffffffc0201fc4:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201fc6:	078e                	slli	a5,a5,0x3
{
ffffffffc0201fc8:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201fca:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc0201fce:	6094                	ld	a3,0(s1)
{
ffffffffc0201fd0:	f04a                	sd	s2,32(sp)
ffffffffc0201fd2:	ec4e                	sd	s3,24(sp)
ffffffffc0201fd4:	e852                	sd	s4,16(sp)
ffffffffc0201fd6:	fc06                	sd	ra,56(sp)
ffffffffc0201fd8:	f822                	sd	s0,48(sp)
ffffffffc0201fda:	e456                	sd	s5,8(sp)
ffffffffc0201fdc:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc0201fde:	0016f793          	andi	a5,a3,1
{
ffffffffc0201fe2:	892e                	mv	s2,a1
ffffffffc0201fe4:	8a32                	mv	s4,a2
ffffffffc0201fe6:	000a8997          	auipc	s3,0xa8
ffffffffc0201fea:	6da98993          	addi	s3,s3,1754 # ffffffffc02aa6c0 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc0201fee:	efbd                	bnez	a5,ffffffffc020206c <get_pte+0xb0>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201ff0:	14060c63          	beqz	a2,ffffffffc0202148 <get_pte+0x18c>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201ff4:	100027f3          	csrr	a5,sstatus
ffffffffc0201ff8:	8b89                	andi	a5,a5,2
ffffffffc0201ffa:	14079963          	bnez	a5,ffffffffc020214c <get_pte+0x190>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201ffe:	000a8797          	auipc	a5,0xa8
ffffffffc0202002:	6d27b783          	ld	a5,1746(a5) # ffffffffc02aa6d0 <pmm_manager>
ffffffffc0202006:	6f9c                	ld	a5,24(a5)
ffffffffc0202008:	4505                	li	a0,1
ffffffffc020200a:	9782                	jalr	a5
ffffffffc020200c:	842a                	mv	s0,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc020200e:	12040d63          	beqz	s0,ffffffffc0202148 <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0202012:	000a8b17          	auipc	s6,0xa8
ffffffffc0202016:	6b6b0b13          	addi	s6,s6,1718 # ffffffffc02aa6c8 <pages>
ffffffffc020201a:	000b3503          	ld	a0,0(s6)
ffffffffc020201e:	00080ab7          	lui	s5,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202022:	000a8997          	auipc	s3,0xa8
ffffffffc0202026:	69e98993          	addi	s3,s3,1694 # ffffffffc02aa6c0 <npage>
ffffffffc020202a:	40a40533          	sub	a0,s0,a0
ffffffffc020202e:	8519                	srai	a0,a0,0x6
ffffffffc0202030:	9556                	add	a0,a0,s5
ffffffffc0202032:	0009b703          	ld	a4,0(s3)
ffffffffc0202036:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc020203a:	4685                	li	a3,1
ffffffffc020203c:	c014                	sw	a3,0(s0)
ffffffffc020203e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202040:	0532                	slli	a0,a0,0xc
ffffffffc0202042:	16e7f763          	bgeu	a5,a4,ffffffffc02021b0 <get_pte+0x1f4>
ffffffffc0202046:	000a8797          	auipc	a5,0xa8
ffffffffc020204a:	6927b783          	ld	a5,1682(a5) # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc020204e:	6605                	lui	a2,0x1
ffffffffc0202050:	4581                	li	a1,0
ffffffffc0202052:	953e                	add	a0,a0,a5
ffffffffc0202054:	752030ef          	jal	ra,ffffffffc02057a6 <memset>
    return page - pages + nbase;
ffffffffc0202058:	000b3683          	ld	a3,0(s6)
ffffffffc020205c:	40d406b3          	sub	a3,s0,a3
ffffffffc0202060:	8699                	srai	a3,a3,0x6
ffffffffc0202062:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202064:	06aa                	slli	a3,a3,0xa
ffffffffc0202066:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020206a:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020206c:	77fd                	lui	a5,0xfffff
ffffffffc020206e:	068a                	slli	a3,a3,0x2
ffffffffc0202070:	0009b703          	ld	a4,0(s3)
ffffffffc0202074:	8efd                	and	a3,a3,a5
ffffffffc0202076:	00c6d793          	srli	a5,a3,0xc
ffffffffc020207a:	10e7ff63          	bgeu	a5,a4,ffffffffc0202198 <get_pte+0x1dc>
ffffffffc020207e:	000a8a97          	auipc	s5,0xa8
ffffffffc0202082:	65aa8a93          	addi	s5,s5,1626 # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc0202086:	000ab403          	ld	s0,0(s5)
ffffffffc020208a:	01595793          	srli	a5,s2,0x15
ffffffffc020208e:	1ff7f793          	andi	a5,a5,511
ffffffffc0202092:	96a2                	add	a3,a3,s0
ffffffffc0202094:	00379413          	slli	s0,a5,0x3
ffffffffc0202098:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V))
ffffffffc020209a:	6014                	ld	a3,0(s0)
ffffffffc020209c:	0016f793          	andi	a5,a3,1
ffffffffc02020a0:	ebad                	bnez	a5,ffffffffc0202112 <get_pte+0x156>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc02020a2:	0a0a0363          	beqz	s4,ffffffffc0202148 <get_pte+0x18c>
ffffffffc02020a6:	100027f3          	csrr	a5,sstatus
ffffffffc02020aa:	8b89                	andi	a5,a5,2
ffffffffc02020ac:	efcd                	bnez	a5,ffffffffc0202166 <get_pte+0x1aa>
        page = pmm_manager->alloc_pages(n);
ffffffffc02020ae:	000a8797          	auipc	a5,0xa8
ffffffffc02020b2:	6227b783          	ld	a5,1570(a5) # ffffffffc02aa6d0 <pmm_manager>
ffffffffc02020b6:	6f9c                	ld	a5,24(a5)
ffffffffc02020b8:	4505                	li	a0,1
ffffffffc02020ba:	9782                	jalr	a5
ffffffffc02020bc:	84aa                	mv	s1,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc02020be:	c4c9                	beqz	s1,ffffffffc0202148 <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc02020c0:	000a8b17          	auipc	s6,0xa8
ffffffffc02020c4:	608b0b13          	addi	s6,s6,1544 # ffffffffc02aa6c8 <pages>
ffffffffc02020c8:	000b3503          	ld	a0,0(s6)
ffffffffc02020cc:	00080a37          	lui	s4,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020d0:	0009b703          	ld	a4,0(s3)
ffffffffc02020d4:	40a48533          	sub	a0,s1,a0
ffffffffc02020d8:	8519                	srai	a0,a0,0x6
ffffffffc02020da:	9552                	add	a0,a0,s4
ffffffffc02020dc:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc02020e0:	4685                	li	a3,1
ffffffffc02020e2:	c094                	sw	a3,0(s1)
ffffffffc02020e4:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02020e6:	0532                	slli	a0,a0,0xc
ffffffffc02020e8:	0ee7f163          	bgeu	a5,a4,ffffffffc02021ca <get_pte+0x20e>
ffffffffc02020ec:	000ab783          	ld	a5,0(s5)
ffffffffc02020f0:	6605                	lui	a2,0x1
ffffffffc02020f2:	4581                	li	a1,0
ffffffffc02020f4:	953e                	add	a0,a0,a5
ffffffffc02020f6:	6b0030ef          	jal	ra,ffffffffc02057a6 <memset>
    return page - pages + nbase;
ffffffffc02020fa:	000b3683          	ld	a3,0(s6)
ffffffffc02020fe:	40d486b3          	sub	a3,s1,a3
ffffffffc0202102:	8699                	srai	a3,a3,0x6
ffffffffc0202104:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202106:	06aa                	slli	a3,a3,0xa
ffffffffc0202108:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020210c:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020210e:	0009b703          	ld	a4,0(s3)
ffffffffc0202112:	068a                	slli	a3,a3,0x2
ffffffffc0202114:	757d                	lui	a0,0xfffff
ffffffffc0202116:	8ee9                	and	a3,a3,a0
ffffffffc0202118:	00c6d793          	srli	a5,a3,0xc
ffffffffc020211c:	06e7f263          	bgeu	a5,a4,ffffffffc0202180 <get_pte+0x1c4>
ffffffffc0202120:	000ab503          	ld	a0,0(s5)
ffffffffc0202124:	00c95913          	srli	s2,s2,0xc
ffffffffc0202128:	1ff97913          	andi	s2,s2,511
ffffffffc020212c:	96aa                	add	a3,a3,a0
ffffffffc020212e:	00391513          	slli	a0,s2,0x3
ffffffffc0202132:	9536                	add	a0,a0,a3
}
ffffffffc0202134:	70e2                	ld	ra,56(sp)
ffffffffc0202136:	7442                	ld	s0,48(sp)
ffffffffc0202138:	74a2                	ld	s1,40(sp)
ffffffffc020213a:	7902                	ld	s2,32(sp)
ffffffffc020213c:	69e2                	ld	s3,24(sp)
ffffffffc020213e:	6a42                	ld	s4,16(sp)
ffffffffc0202140:	6aa2                	ld	s5,8(sp)
ffffffffc0202142:	6b02                	ld	s6,0(sp)
ffffffffc0202144:	6121                	addi	sp,sp,64
ffffffffc0202146:	8082                	ret
            return NULL;
ffffffffc0202148:	4501                	li	a0,0
ffffffffc020214a:	b7ed                	j	ffffffffc0202134 <get_pte+0x178>
        intr_disable();
ffffffffc020214c:	869fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202150:	000a8797          	auipc	a5,0xa8
ffffffffc0202154:	5807b783          	ld	a5,1408(a5) # ffffffffc02aa6d0 <pmm_manager>
ffffffffc0202158:	6f9c                	ld	a5,24(a5)
ffffffffc020215a:	4505                	li	a0,1
ffffffffc020215c:	9782                	jalr	a5
ffffffffc020215e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202160:	84ffe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202164:	b56d                	j	ffffffffc020200e <get_pte+0x52>
        intr_disable();
ffffffffc0202166:	84ffe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc020216a:	000a8797          	auipc	a5,0xa8
ffffffffc020216e:	5667b783          	ld	a5,1382(a5) # ffffffffc02aa6d0 <pmm_manager>
ffffffffc0202172:	6f9c                	ld	a5,24(a5)
ffffffffc0202174:	4505                	li	a0,1
ffffffffc0202176:	9782                	jalr	a5
ffffffffc0202178:	84aa                	mv	s1,a0
        intr_enable();
ffffffffc020217a:	835fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020217e:	b781                	j	ffffffffc02020be <get_pte+0x102>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202180:	00004617          	auipc	a2,0x4
ffffffffc0202184:	53060613          	addi	a2,a2,1328 # ffffffffc02066b0 <default_pmm_manager+0x38>
ffffffffc0202188:	0fa00593          	li	a1,250
ffffffffc020218c:	00004517          	auipc	a0,0x4
ffffffffc0202190:	63c50513          	addi	a0,a0,1596 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0202194:	afafe0ef          	jal	ra,ffffffffc020048e <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202198:	00004617          	auipc	a2,0x4
ffffffffc020219c:	51860613          	addi	a2,a2,1304 # ffffffffc02066b0 <default_pmm_manager+0x38>
ffffffffc02021a0:	0ed00593          	li	a1,237
ffffffffc02021a4:	00004517          	auipc	a0,0x4
ffffffffc02021a8:	62450513          	addi	a0,a0,1572 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc02021ac:	ae2fe0ef          	jal	ra,ffffffffc020048e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02021b0:	86aa                	mv	a3,a0
ffffffffc02021b2:	00004617          	auipc	a2,0x4
ffffffffc02021b6:	4fe60613          	addi	a2,a2,1278 # ffffffffc02066b0 <default_pmm_manager+0x38>
ffffffffc02021ba:	0e900593          	li	a1,233
ffffffffc02021be:	00004517          	auipc	a0,0x4
ffffffffc02021c2:	60a50513          	addi	a0,a0,1546 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc02021c6:	ac8fe0ef          	jal	ra,ffffffffc020048e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02021ca:	86aa                	mv	a3,a0
ffffffffc02021cc:	00004617          	auipc	a2,0x4
ffffffffc02021d0:	4e460613          	addi	a2,a2,1252 # ffffffffc02066b0 <default_pmm_manager+0x38>
ffffffffc02021d4:	0f700593          	li	a1,247
ffffffffc02021d8:	00004517          	auipc	a0,0x4
ffffffffc02021dc:	5f050513          	addi	a0,a0,1520 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc02021e0:	aaefe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02021e4 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc02021e4:	1141                	addi	sp,sp,-16
ffffffffc02021e6:	e022                	sd	s0,0(sp)
ffffffffc02021e8:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02021ea:	4601                	li	a2,0
{
ffffffffc02021ec:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02021ee:	dcfff0ef          	jal	ra,ffffffffc0201fbc <get_pte>
    if (ptep_store != NULL)
ffffffffc02021f2:	c011                	beqz	s0,ffffffffc02021f6 <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc02021f4:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc02021f6:	c511                	beqz	a0,ffffffffc0202202 <get_page+0x1e>
ffffffffc02021f8:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02021fa:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc02021fc:	0017f713          	andi	a4,a5,1
ffffffffc0202200:	e709                	bnez	a4,ffffffffc020220a <get_page+0x26>
}
ffffffffc0202202:	60a2                	ld	ra,8(sp)
ffffffffc0202204:	6402                	ld	s0,0(sp)
ffffffffc0202206:	0141                	addi	sp,sp,16
ffffffffc0202208:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020220a:	078a                	slli	a5,a5,0x2
ffffffffc020220c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020220e:	000a8717          	auipc	a4,0xa8
ffffffffc0202212:	4b273703          	ld	a4,1202(a4) # ffffffffc02aa6c0 <npage>
ffffffffc0202216:	00e7ff63          	bgeu	a5,a4,ffffffffc0202234 <get_page+0x50>
ffffffffc020221a:	60a2                	ld	ra,8(sp)
ffffffffc020221c:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc020221e:	fff80537          	lui	a0,0xfff80
ffffffffc0202222:	97aa                	add	a5,a5,a0
ffffffffc0202224:	079a                	slli	a5,a5,0x6
ffffffffc0202226:	000a8517          	auipc	a0,0xa8
ffffffffc020222a:	4a253503          	ld	a0,1186(a0) # ffffffffc02aa6c8 <pages>
ffffffffc020222e:	953e                	add	a0,a0,a5
ffffffffc0202230:	0141                	addi	sp,sp,16
ffffffffc0202232:	8082                	ret
ffffffffc0202234:	c99ff0ef          	jal	ra,ffffffffc0201ecc <pa2page.part.0>

ffffffffc0202238 <unmap_range>:
        tlb_invalidate(pgdir, la);
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc0202238:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020223a:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc020223e:	f486                	sd	ra,104(sp)
ffffffffc0202240:	f0a2                	sd	s0,96(sp)
ffffffffc0202242:	eca6                	sd	s1,88(sp)
ffffffffc0202244:	e8ca                	sd	s2,80(sp)
ffffffffc0202246:	e4ce                	sd	s3,72(sp)
ffffffffc0202248:	e0d2                	sd	s4,64(sp)
ffffffffc020224a:	fc56                	sd	s5,56(sp)
ffffffffc020224c:	f85a                	sd	s6,48(sp)
ffffffffc020224e:	f45e                	sd	s7,40(sp)
ffffffffc0202250:	f062                	sd	s8,32(sp)
ffffffffc0202252:	ec66                	sd	s9,24(sp)
ffffffffc0202254:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202256:	17d2                	slli	a5,a5,0x34
ffffffffc0202258:	e3ed                	bnez	a5,ffffffffc020233a <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc020225a:	002007b7          	lui	a5,0x200
ffffffffc020225e:	842e                	mv	s0,a1
ffffffffc0202260:	0ef5ed63          	bltu	a1,a5,ffffffffc020235a <unmap_range+0x122>
ffffffffc0202264:	8932                	mv	s2,a2
ffffffffc0202266:	0ec5fa63          	bgeu	a1,a2,ffffffffc020235a <unmap_range+0x122>
ffffffffc020226a:	4785                	li	a5,1
ffffffffc020226c:	07fe                	slli	a5,a5,0x1f
ffffffffc020226e:	0ec7e663          	bltu	a5,a2,ffffffffc020235a <unmap_range+0x122>
ffffffffc0202272:	89aa                	mv	s3,a0
        }
        if (*ptep != 0)
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0202274:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage)
ffffffffc0202276:	000a8c97          	auipc	s9,0xa8
ffffffffc020227a:	44ac8c93          	addi	s9,s9,1098 # ffffffffc02aa6c0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020227e:	000a8c17          	auipc	s8,0xa8
ffffffffc0202282:	44ac0c13          	addi	s8,s8,1098 # ffffffffc02aa6c8 <pages>
ffffffffc0202286:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc020228a:	000a8d17          	auipc	s10,0xa8
ffffffffc020228e:	446d0d13          	addi	s10,s10,1094 # ffffffffc02aa6d0 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202292:	00200b37          	lui	s6,0x200
ffffffffc0202296:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc020229a:	4601                	li	a2,0
ffffffffc020229c:	85a2                	mv	a1,s0
ffffffffc020229e:	854e                	mv	a0,s3
ffffffffc02022a0:	d1dff0ef          	jal	ra,ffffffffc0201fbc <get_pte>
ffffffffc02022a4:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc02022a6:	cd29                	beqz	a0,ffffffffc0202300 <unmap_range+0xc8>
        if (*ptep != 0)
ffffffffc02022a8:	611c                	ld	a5,0(a0)
ffffffffc02022aa:	e395                	bnez	a5,ffffffffc02022ce <unmap_range+0x96>
        start += PGSIZE;
ffffffffc02022ac:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02022ae:	ff2466e3          	bltu	s0,s2,ffffffffc020229a <unmap_range+0x62>
}
ffffffffc02022b2:	70a6                	ld	ra,104(sp)
ffffffffc02022b4:	7406                	ld	s0,96(sp)
ffffffffc02022b6:	64e6                	ld	s1,88(sp)
ffffffffc02022b8:	6946                	ld	s2,80(sp)
ffffffffc02022ba:	69a6                	ld	s3,72(sp)
ffffffffc02022bc:	6a06                	ld	s4,64(sp)
ffffffffc02022be:	7ae2                	ld	s5,56(sp)
ffffffffc02022c0:	7b42                	ld	s6,48(sp)
ffffffffc02022c2:	7ba2                	ld	s7,40(sp)
ffffffffc02022c4:	7c02                	ld	s8,32(sp)
ffffffffc02022c6:	6ce2                	ld	s9,24(sp)
ffffffffc02022c8:	6d42                	ld	s10,16(sp)
ffffffffc02022ca:	6165                	addi	sp,sp,112
ffffffffc02022cc:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc02022ce:	0017f713          	andi	a4,a5,1
ffffffffc02022d2:	df69                	beqz	a4,ffffffffc02022ac <unmap_range+0x74>
    if (PPN(pa) >= npage)
ffffffffc02022d4:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc02022d8:	078a                	slli	a5,a5,0x2
ffffffffc02022da:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02022dc:	08e7ff63          	bgeu	a5,a4,ffffffffc020237a <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc02022e0:	000c3503          	ld	a0,0(s8)
ffffffffc02022e4:	97de                	add	a5,a5,s7
ffffffffc02022e6:	079a                	slli	a5,a5,0x6
ffffffffc02022e8:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02022ea:	411c                	lw	a5,0(a0)
ffffffffc02022ec:	fff7871b          	addiw	a4,a5,-1
ffffffffc02022f0:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc02022f2:	cf11                	beqz	a4,ffffffffc020230e <unmap_range+0xd6>
        *ptep = 0;
ffffffffc02022f4:	0004b023          	sd	zero,0(s1)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02022f8:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc02022fc:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02022fe:	bf45                	j	ffffffffc02022ae <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202300:	945a                	add	s0,s0,s6
ffffffffc0202302:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0202306:	d455                	beqz	s0,ffffffffc02022b2 <unmap_range+0x7a>
ffffffffc0202308:	f92469e3          	bltu	s0,s2,ffffffffc020229a <unmap_range+0x62>
ffffffffc020230c:	b75d                	j	ffffffffc02022b2 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020230e:	100027f3          	csrr	a5,sstatus
ffffffffc0202312:	8b89                	andi	a5,a5,2
ffffffffc0202314:	e799                	bnez	a5,ffffffffc0202322 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc0202316:	000d3783          	ld	a5,0(s10)
ffffffffc020231a:	4585                	li	a1,1
ffffffffc020231c:	739c                	ld	a5,32(a5)
ffffffffc020231e:	9782                	jalr	a5
    if (flag)
ffffffffc0202320:	bfd1                	j	ffffffffc02022f4 <unmap_range+0xbc>
ffffffffc0202322:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202324:	e90fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202328:	000d3783          	ld	a5,0(s10)
ffffffffc020232c:	6522                	ld	a0,8(sp)
ffffffffc020232e:	4585                	li	a1,1
ffffffffc0202330:	739c                	ld	a5,32(a5)
ffffffffc0202332:	9782                	jalr	a5
        intr_enable();
ffffffffc0202334:	e7afe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202338:	bf75                	j	ffffffffc02022f4 <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020233a:	00004697          	auipc	a3,0x4
ffffffffc020233e:	49e68693          	addi	a3,a3,1182 # ffffffffc02067d8 <default_pmm_manager+0x160>
ffffffffc0202342:	00004617          	auipc	a2,0x4
ffffffffc0202346:	f8660613          	addi	a2,a2,-122 # ffffffffc02062c8 <commands+0x890>
ffffffffc020234a:	12000593          	li	a1,288
ffffffffc020234e:	00004517          	auipc	a0,0x4
ffffffffc0202352:	47a50513          	addi	a0,a0,1146 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0202356:	938fe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020235a:	00004697          	auipc	a3,0x4
ffffffffc020235e:	4ae68693          	addi	a3,a3,1198 # ffffffffc0206808 <default_pmm_manager+0x190>
ffffffffc0202362:	00004617          	auipc	a2,0x4
ffffffffc0202366:	f6660613          	addi	a2,a2,-154 # ffffffffc02062c8 <commands+0x890>
ffffffffc020236a:	12100593          	li	a1,289
ffffffffc020236e:	00004517          	auipc	a0,0x4
ffffffffc0202372:	45a50513          	addi	a0,a0,1114 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0202376:	918fe0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc020237a:	b53ff0ef          	jal	ra,ffffffffc0201ecc <pa2page.part.0>

ffffffffc020237e <exit_range>:
{
ffffffffc020237e:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202380:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0202384:	fc86                	sd	ra,120(sp)
ffffffffc0202386:	f8a2                	sd	s0,112(sp)
ffffffffc0202388:	f4a6                	sd	s1,104(sp)
ffffffffc020238a:	f0ca                	sd	s2,96(sp)
ffffffffc020238c:	ecce                	sd	s3,88(sp)
ffffffffc020238e:	e8d2                	sd	s4,80(sp)
ffffffffc0202390:	e4d6                	sd	s5,72(sp)
ffffffffc0202392:	e0da                	sd	s6,64(sp)
ffffffffc0202394:	fc5e                	sd	s7,56(sp)
ffffffffc0202396:	f862                	sd	s8,48(sp)
ffffffffc0202398:	f466                	sd	s9,40(sp)
ffffffffc020239a:	f06a                	sd	s10,32(sp)
ffffffffc020239c:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020239e:	17d2                	slli	a5,a5,0x34
ffffffffc02023a0:	20079a63          	bnez	a5,ffffffffc02025b4 <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc02023a4:	002007b7          	lui	a5,0x200
ffffffffc02023a8:	24f5e463          	bltu	a1,a5,ffffffffc02025f0 <exit_range+0x272>
ffffffffc02023ac:	8ab2                	mv	s5,a2
ffffffffc02023ae:	24c5f163          	bgeu	a1,a2,ffffffffc02025f0 <exit_range+0x272>
ffffffffc02023b2:	4785                	li	a5,1
ffffffffc02023b4:	07fe                	slli	a5,a5,0x1f
ffffffffc02023b6:	22c7ed63          	bltu	a5,a2,ffffffffc02025f0 <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02023ba:	c00009b7          	lui	s3,0xc0000
ffffffffc02023be:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02023c2:	ffe00937          	lui	s2,0xffe00
ffffffffc02023c6:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc02023ca:	5cfd                	li	s9,-1
ffffffffc02023cc:	8c2a                	mv	s8,a0
ffffffffc02023ce:	0125f933          	and	s2,a1,s2
ffffffffc02023d2:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage)
ffffffffc02023d4:	000a8d17          	auipc	s10,0xa8
ffffffffc02023d8:	2ecd0d13          	addi	s10,s10,748 # ffffffffc02aa6c0 <npage>
    return KADDR(page2pa(page));
ffffffffc02023dc:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc02023e0:	000a8717          	auipc	a4,0xa8
ffffffffc02023e4:	2e870713          	addi	a4,a4,744 # ffffffffc02aa6c8 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc02023e8:	000a8d97          	auipc	s11,0xa8
ffffffffc02023ec:	2e8d8d93          	addi	s11,s11,744 # ffffffffc02aa6d0 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02023f0:	c0000437          	lui	s0,0xc0000
ffffffffc02023f4:	944e                	add	s0,s0,s3
ffffffffc02023f6:	8079                	srli	s0,s0,0x1e
ffffffffc02023f8:	1ff47413          	andi	s0,s0,511
ffffffffc02023fc:	040e                	slli	s0,s0,0x3
ffffffffc02023fe:	9462                	add	s0,s0,s8
ffffffffc0202400:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ee8>
        if (pde1 & PTE_V)
ffffffffc0202404:	001a7793          	andi	a5,s4,1
ffffffffc0202408:	eb99                	bnez	a5,ffffffffc020241e <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc020240a:	12098463          	beqz	s3,ffffffffc0202532 <exit_range+0x1b4>
ffffffffc020240e:	400007b7          	lui	a5,0x40000
ffffffffc0202412:	97ce                	add	a5,a5,s3
ffffffffc0202414:	894e                	mv	s2,s3
ffffffffc0202416:	1159fe63          	bgeu	s3,s5,ffffffffc0202532 <exit_range+0x1b4>
ffffffffc020241a:	89be                	mv	s3,a5
ffffffffc020241c:	bfd1                	j	ffffffffc02023f0 <exit_range+0x72>
    if (PPN(pa) >= npage)
ffffffffc020241e:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202422:	0a0a                	slli	s4,s4,0x2
ffffffffc0202424:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage)
ffffffffc0202428:	1cfa7263          	bgeu	s4,a5,ffffffffc02025ec <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc020242c:	fff80637          	lui	a2,0xfff80
ffffffffc0202430:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc0202432:	000806b7          	lui	a3,0x80
ffffffffc0202436:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0202438:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc020243c:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc020243e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202440:	18f5fa63          	bgeu	a1,a5,ffffffffc02025d4 <exit_range+0x256>
ffffffffc0202444:	000a8817          	auipc	a6,0xa8
ffffffffc0202448:	29480813          	addi	a6,a6,660 # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc020244c:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc0202450:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc0202452:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc0202456:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc0202458:	00080337          	lui	t1,0x80
ffffffffc020245c:	6885                	lui	a7,0x1
ffffffffc020245e:	a819                	j	ffffffffc0202474 <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc0202460:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc0202462:	002007b7          	lui	a5,0x200
ffffffffc0202466:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202468:	08090c63          	beqz	s2,ffffffffc0202500 <exit_range+0x182>
ffffffffc020246c:	09397a63          	bgeu	s2,s3,ffffffffc0202500 <exit_range+0x182>
ffffffffc0202470:	0f597063          	bgeu	s2,s5,ffffffffc0202550 <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0202474:	01595493          	srli	s1,s2,0x15
ffffffffc0202478:	1ff4f493          	andi	s1,s1,511
ffffffffc020247c:	048e                	slli	s1,s1,0x3
ffffffffc020247e:	94da                	add	s1,s1,s6
ffffffffc0202480:	609c                	ld	a5,0(s1)
                if (pde0 & PTE_V)
ffffffffc0202482:	0017f693          	andi	a3,a5,1
ffffffffc0202486:	dee9                	beqz	a3,ffffffffc0202460 <exit_range+0xe2>
    if (PPN(pa) >= npage)
ffffffffc0202488:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc020248c:	078a                	slli	a5,a5,0x2
ffffffffc020248e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202490:	14b7fe63          	bgeu	a5,a1,ffffffffc02025ec <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202494:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc0202496:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc020249a:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc020249e:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02024a2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02024a4:	12bef863          	bgeu	t4,a1,ffffffffc02025d4 <exit_range+0x256>
ffffffffc02024a8:	00083783          	ld	a5,0(a6)
ffffffffc02024ac:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc02024ae:	011685b3          	add	a1,a3,a7
                        if (pt[i] & PTE_V)
ffffffffc02024b2:	629c                	ld	a5,0(a3)
ffffffffc02024b4:	8b85                	andi	a5,a5,1
ffffffffc02024b6:	f7d5                	bnez	a5,ffffffffc0202462 <exit_range+0xe4>
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc02024b8:	06a1                	addi	a3,a3,8
ffffffffc02024ba:	fed59ce3          	bne	a1,a3,ffffffffc02024b2 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc02024be:	631c                	ld	a5,0(a4)
ffffffffc02024c0:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02024c2:	100027f3          	csrr	a5,sstatus
ffffffffc02024c6:	8b89                	andi	a5,a5,2
ffffffffc02024c8:	e7d9                	bnez	a5,ffffffffc0202556 <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc02024ca:	000db783          	ld	a5,0(s11)
ffffffffc02024ce:	4585                	li	a1,1
ffffffffc02024d0:	e032                	sd	a2,0(sp)
ffffffffc02024d2:	739c                	ld	a5,32(a5)
ffffffffc02024d4:	9782                	jalr	a5
    if (flag)
ffffffffc02024d6:	6602                	ld	a2,0(sp)
ffffffffc02024d8:	000a8817          	auipc	a6,0xa8
ffffffffc02024dc:	20080813          	addi	a6,a6,512 # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc02024e0:	fff80e37          	lui	t3,0xfff80
ffffffffc02024e4:	00080337          	lui	t1,0x80
ffffffffc02024e8:	6885                	lui	a7,0x1
ffffffffc02024ea:	000a8717          	auipc	a4,0xa8
ffffffffc02024ee:	1de70713          	addi	a4,a4,478 # ffffffffc02aa6c8 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc02024f2:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc02024f6:	002007b7          	lui	a5,0x200
ffffffffc02024fa:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc02024fc:	f60918e3          	bnez	s2,ffffffffc020246c <exit_range+0xee>
            if (free_pd0)
ffffffffc0202500:	f00b85e3          	beqz	s7,ffffffffc020240a <exit_range+0x8c>
    if (PPN(pa) >= npage)
ffffffffc0202504:	000d3783          	ld	a5,0(s10)
ffffffffc0202508:	0efa7263          	bgeu	s4,a5,ffffffffc02025ec <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc020250c:	6308                	ld	a0,0(a4)
ffffffffc020250e:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202510:	100027f3          	csrr	a5,sstatus
ffffffffc0202514:	8b89                	andi	a5,a5,2
ffffffffc0202516:	efad                	bnez	a5,ffffffffc0202590 <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc0202518:	000db783          	ld	a5,0(s11)
ffffffffc020251c:	4585                	li	a1,1
ffffffffc020251e:	739c                	ld	a5,32(a5)
ffffffffc0202520:	9782                	jalr	a5
ffffffffc0202522:	000a8717          	auipc	a4,0xa8
ffffffffc0202526:	1a670713          	addi	a4,a4,422 # ffffffffc02aa6c8 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc020252a:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc020252e:	ee0990e3          	bnez	s3,ffffffffc020240e <exit_range+0x90>
}
ffffffffc0202532:	70e6                	ld	ra,120(sp)
ffffffffc0202534:	7446                	ld	s0,112(sp)
ffffffffc0202536:	74a6                	ld	s1,104(sp)
ffffffffc0202538:	7906                	ld	s2,96(sp)
ffffffffc020253a:	69e6                	ld	s3,88(sp)
ffffffffc020253c:	6a46                	ld	s4,80(sp)
ffffffffc020253e:	6aa6                	ld	s5,72(sp)
ffffffffc0202540:	6b06                	ld	s6,64(sp)
ffffffffc0202542:	7be2                	ld	s7,56(sp)
ffffffffc0202544:	7c42                	ld	s8,48(sp)
ffffffffc0202546:	7ca2                	ld	s9,40(sp)
ffffffffc0202548:	7d02                	ld	s10,32(sp)
ffffffffc020254a:	6de2                	ld	s11,24(sp)
ffffffffc020254c:	6109                	addi	sp,sp,128
ffffffffc020254e:	8082                	ret
            if (free_pd0)
ffffffffc0202550:	ea0b8fe3          	beqz	s7,ffffffffc020240e <exit_range+0x90>
ffffffffc0202554:	bf45                	j	ffffffffc0202504 <exit_range+0x186>
ffffffffc0202556:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc0202558:	e42a                	sd	a0,8(sp)
ffffffffc020255a:	c5afe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020255e:	000db783          	ld	a5,0(s11)
ffffffffc0202562:	6522                	ld	a0,8(sp)
ffffffffc0202564:	4585                	li	a1,1
ffffffffc0202566:	739c                	ld	a5,32(a5)
ffffffffc0202568:	9782                	jalr	a5
        intr_enable();
ffffffffc020256a:	c44fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020256e:	6602                	ld	a2,0(sp)
ffffffffc0202570:	000a8717          	auipc	a4,0xa8
ffffffffc0202574:	15870713          	addi	a4,a4,344 # ffffffffc02aa6c8 <pages>
ffffffffc0202578:	6885                	lui	a7,0x1
ffffffffc020257a:	00080337          	lui	t1,0x80
ffffffffc020257e:	fff80e37          	lui	t3,0xfff80
ffffffffc0202582:	000a8817          	auipc	a6,0xa8
ffffffffc0202586:	15680813          	addi	a6,a6,342 # ffffffffc02aa6d8 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc020258a:	0004b023          	sd	zero,0(s1)
ffffffffc020258e:	b7a5                	j	ffffffffc02024f6 <exit_range+0x178>
ffffffffc0202590:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0202592:	c22fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202596:	000db783          	ld	a5,0(s11)
ffffffffc020259a:	6502                	ld	a0,0(sp)
ffffffffc020259c:	4585                	li	a1,1
ffffffffc020259e:	739c                	ld	a5,32(a5)
ffffffffc02025a0:	9782                	jalr	a5
        intr_enable();
ffffffffc02025a2:	c0cfe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02025a6:	000a8717          	auipc	a4,0xa8
ffffffffc02025aa:	12270713          	addi	a4,a4,290 # ffffffffc02aa6c8 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc02025ae:	00043023          	sd	zero,0(s0)
ffffffffc02025b2:	bfb5                	j	ffffffffc020252e <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02025b4:	00004697          	auipc	a3,0x4
ffffffffc02025b8:	22468693          	addi	a3,a3,548 # ffffffffc02067d8 <default_pmm_manager+0x160>
ffffffffc02025bc:	00004617          	auipc	a2,0x4
ffffffffc02025c0:	d0c60613          	addi	a2,a2,-756 # ffffffffc02062c8 <commands+0x890>
ffffffffc02025c4:	13500593          	li	a1,309
ffffffffc02025c8:	00004517          	auipc	a0,0x4
ffffffffc02025cc:	20050513          	addi	a0,a0,512 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc02025d0:	ebffd0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc02025d4:	00004617          	auipc	a2,0x4
ffffffffc02025d8:	0dc60613          	addi	a2,a2,220 # ffffffffc02066b0 <default_pmm_manager+0x38>
ffffffffc02025dc:	07100593          	li	a1,113
ffffffffc02025e0:	00004517          	auipc	a0,0x4
ffffffffc02025e4:	0f850513          	addi	a0,a0,248 # ffffffffc02066d8 <default_pmm_manager+0x60>
ffffffffc02025e8:	ea7fd0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc02025ec:	8e1ff0ef          	jal	ra,ffffffffc0201ecc <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc02025f0:	00004697          	auipc	a3,0x4
ffffffffc02025f4:	21868693          	addi	a3,a3,536 # ffffffffc0206808 <default_pmm_manager+0x190>
ffffffffc02025f8:	00004617          	auipc	a2,0x4
ffffffffc02025fc:	cd060613          	addi	a2,a2,-816 # ffffffffc02062c8 <commands+0x890>
ffffffffc0202600:	13600593          	li	a1,310
ffffffffc0202604:	00004517          	auipc	a0,0x4
ffffffffc0202608:	1c450513          	addi	a0,a0,452 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc020260c:	e83fd0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0202610 <page_remove>:
{
ffffffffc0202610:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202612:	4601                	li	a2,0
{
ffffffffc0202614:	ec26                	sd	s1,24(sp)
ffffffffc0202616:	f406                	sd	ra,40(sp)
ffffffffc0202618:	f022                	sd	s0,32(sp)
ffffffffc020261a:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020261c:	9a1ff0ef          	jal	ra,ffffffffc0201fbc <get_pte>
    if (ptep != NULL)
ffffffffc0202620:	c511                	beqz	a0,ffffffffc020262c <page_remove+0x1c>
    if (*ptep & PTE_V)
ffffffffc0202622:	611c                	ld	a5,0(a0)
ffffffffc0202624:	842a                	mv	s0,a0
ffffffffc0202626:	0017f713          	andi	a4,a5,1
ffffffffc020262a:	e711                	bnez	a4,ffffffffc0202636 <page_remove+0x26>
}
ffffffffc020262c:	70a2                	ld	ra,40(sp)
ffffffffc020262e:	7402                	ld	s0,32(sp)
ffffffffc0202630:	64e2                	ld	s1,24(sp)
ffffffffc0202632:	6145                	addi	sp,sp,48
ffffffffc0202634:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202636:	078a                	slli	a5,a5,0x2
ffffffffc0202638:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020263a:	000a8717          	auipc	a4,0xa8
ffffffffc020263e:	08673703          	ld	a4,134(a4) # ffffffffc02aa6c0 <npage>
ffffffffc0202642:	06e7f363          	bgeu	a5,a4,ffffffffc02026a8 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0202646:	fff80537          	lui	a0,0xfff80
ffffffffc020264a:	97aa                	add	a5,a5,a0
ffffffffc020264c:	079a                	slli	a5,a5,0x6
ffffffffc020264e:	000a8517          	auipc	a0,0xa8
ffffffffc0202652:	07a53503          	ld	a0,122(a0) # ffffffffc02aa6c8 <pages>
ffffffffc0202656:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202658:	411c                	lw	a5,0(a0)
ffffffffc020265a:	fff7871b          	addiw	a4,a5,-1
ffffffffc020265e:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc0202660:	cb11                	beqz	a4,ffffffffc0202674 <page_remove+0x64>
        *ptep = 0;
ffffffffc0202662:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202666:	12048073          	sfence.vma	s1
}
ffffffffc020266a:	70a2                	ld	ra,40(sp)
ffffffffc020266c:	7402                	ld	s0,32(sp)
ffffffffc020266e:	64e2                	ld	s1,24(sp)
ffffffffc0202670:	6145                	addi	sp,sp,48
ffffffffc0202672:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202674:	100027f3          	csrr	a5,sstatus
ffffffffc0202678:	8b89                	andi	a5,a5,2
ffffffffc020267a:	eb89                	bnez	a5,ffffffffc020268c <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc020267c:	000a8797          	auipc	a5,0xa8
ffffffffc0202680:	0547b783          	ld	a5,84(a5) # ffffffffc02aa6d0 <pmm_manager>
ffffffffc0202684:	739c                	ld	a5,32(a5)
ffffffffc0202686:	4585                	li	a1,1
ffffffffc0202688:	9782                	jalr	a5
    if (flag)
ffffffffc020268a:	bfe1                	j	ffffffffc0202662 <page_remove+0x52>
        intr_disable();
ffffffffc020268c:	e42a                	sd	a0,8(sp)
ffffffffc020268e:	b26fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202692:	000a8797          	auipc	a5,0xa8
ffffffffc0202696:	03e7b783          	ld	a5,62(a5) # ffffffffc02aa6d0 <pmm_manager>
ffffffffc020269a:	739c                	ld	a5,32(a5)
ffffffffc020269c:	6522                	ld	a0,8(sp)
ffffffffc020269e:	4585                	li	a1,1
ffffffffc02026a0:	9782                	jalr	a5
        intr_enable();
ffffffffc02026a2:	b0cfe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02026a6:	bf75                	j	ffffffffc0202662 <page_remove+0x52>
ffffffffc02026a8:	825ff0ef          	jal	ra,ffffffffc0201ecc <pa2page.part.0>

ffffffffc02026ac <page_insert>:
{
ffffffffc02026ac:	7139                	addi	sp,sp,-64
ffffffffc02026ae:	e852                	sd	s4,16(sp)
ffffffffc02026b0:	8a32                	mv	s4,a2
ffffffffc02026b2:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02026b4:	4605                	li	a2,1
{
ffffffffc02026b6:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02026b8:	85d2                	mv	a1,s4
{
ffffffffc02026ba:	f426                	sd	s1,40(sp)
ffffffffc02026bc:	fc06                	sd	ra,56(sp)
ffffffffc02026be:	f04a                	sd	s2,32(sp)
ffffffffc02026c0:	ec4e                	sd	s3,24(sp)
ffffffffc02026c2:	e456                	sd	s5,8(sp)
ffffffffc02026c4:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02026c6:	8f7ff0ef          	jal	ra,ffffffffc0201fbc <get_pte>
    if (ptep == NULL)
ffffffffc02026ca:	c961                	beqz	a0,ffffffffc020279a <page_insert+0xee>
    page->ref += 1;
ffffffffc02026cc:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V)
ffffffffc02026ce:	611c                	ld	a5,0(a0)
ffffffffc02026d0:	89aa                	mv	s3,a0
ffffffffc02026d2:	0016871b          	addiw	a4,a3,1
ffffffffc02026d6:	c018                	sw	a4,0(s0)
ffffffffc02026d8:	0017f713          	andi	a4,a5,1
ffffffffc02026dc:	ef05                	bnez	a4,ffffffffc0202714 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc02026de:	000a8717          	auipc	a4,0xa8
ffffffffc02026e2:	fea73703          	ld	a4,-22(a4) # ffffffffc02aa6c8 <pages>
ffffffffc02026e6:	8c19                	sub	s0,s0,a4
ffffffffc02026e8:	000807b7          	lui	a5,0x80
ffffffffc02026ec:	8419                	srai	s0,s0,0x6
ffffffffc02026ee:	943e                	add	s0,s0,a5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02026f0:	042a                	slli	s0,s0,0xa
ffffffffc02026f2:	8cc1                	or	s1,s1,s0
ffffffffc02026f4:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02026f8:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ee8>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02026fc:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0202700:	4501                	li	a0,0
}
ffffffffc0202702:	70e2                	ld	ra,56(sp)
ffffffffc0202704:	7442                	ld	s0,48(sp)
ffffffffc0202706:	74a2                	ld	s1,40(sp)
ffffffffc0202708:	7902                	ld	s2,32(sp)
ffffffffc020270a:	69e2                	ld	s3,24(sp)
ffffffffc020270c:	6a42                	ld	s4,16(sp)
ffffffffc020270e:	6aa2                	ld	s5,8(sp)
ffffffffc0202710:	6121                	addi	sp,sp,64
ffffffffc0202712:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202714:	078a                	slli	a5,a5,0x2
ffffffffc0202716:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202718:	000a8717          	auipc	a4,0xa8
ffffffffc020271c:	fa873703          	ld	a4,-88(a4) # ffffffffc02aa6c0 <npage>
ffffffffc0202720:	06e7ff63          	bgeu	a5,a4,ffffffffc020279e <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0202724:	000a8a97          	auipc	s5,0xa8
ffffffffc0202728:	fa4a8a93          	addi	s5,s5,-92 # ffffffffc02aa6c8 <pages>
ffffffffc020272c:	000ab703          	ld	a4,0(s5)
ffffffffc0202730:	fff80937          	lui	s2,0xfff80
ffffffffc0202734:	993e                	add	s2,s2,a5
ffffffffc0202736:	091a                	slli	s2,s2,0x6
ffffffffc0202738:	993a                	add	s2,s2,a4
        if (p == page)
ffffffffc020273a:	01240c63          	beq	s0,s2,ffffffffc0202752 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc020273e:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fcd5904>
ffffffffc0202742:	fff7869b          	addiw	a3,a5,-1
ffffffffc0202746:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) == 0)
ffffffffc020274a:	c691                	beqz	a3,ffffffffc0202756 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020274c:	120a0073          	sfence.vma	s4
}
ffffffffc0202750:	bf59                	j	ffffffffc02026e6 <page_insert+0x3a>
ffffffffc0202752:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202754:	bf49                	j	ffffffffc02026e6 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202756:	100027f3          	csrr	a5,sstatus
ffffffffc020275a:	8b89                	andi	a5,a5,2
ffffffffc020275c:	ef91                	bnez	a5,ffffffffc0202778 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc020275e:	000a8797          	auipc	a5,0xa8
ffffffffc0202762:	f727b783          	ld	a5,-142(a5) # ffffffffc02aa6d0 <pmm_manager>
ffffffffc0202766:	739c                	ld	a5,32(a5)
ffffffffc0202768:	4585                	li	a1,1
ffffffffc020276a:	854a                	mv	a0,s2
ffffffffc020276c:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc020276e:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202772:	120a0073          	sfence.vma	s4
ffffffffc0202776:	bf85                	j	ffffffffc02026e6 <page_insert+0x3a>
        intr_disable();
ffffffffc0202778:	a3cfe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020277c:	000a8797          	auipc	a5,0xa8
ffffffffc0202780:	f547b783          	ld	a5,-172(a5) # ffffffffc02aa6d0 <pmm_manager>
ffffffffc0202784:	739c                	ld	a5,32(a5)
ffffffffc0202786:	4585                	li	a1,1
ffffffffc0202788:	854a                	mv	a0,s2
ffffffffc020278a:	9782                	jalr	a5
        intr_enable();
ffffffffc020278c:	a22fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202790:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202794:	120a0073          	sfence.vma	s4
ffffffffc0202798:	b7b9                	j	ffffffffc02026e6 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc020279a:	5571                	li	a0,-4
ffffffffc020279c:	b79d                	j	ffffffffc0202702 <page_insert+0x56>
ffffffffc020279e:	f2eff0ef          	jal	ra,ffffffffc0201ecc <pa2page.part.0>

ffffffffc02027a2 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc02027a2:	00004797          	auipc	a5,0x4
ffffffffc02027a6:	ed678793          	addi	a5,a5,-298 # ffffffffc0206678 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02027aa:	638c                	ld	a1,0(a5)
{
ffffffffc02027ac:	7159                	addi	sp,sp,-112
ffffffffc02027ae:	f85a                	sd	s6,48(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02027b0:	00004517          	auipc	a0,0x4
ffffffffc02027b4:	07050513          	addi	a0,a0,112 # ffffffffc0206820 <default_pmm_manager+0x1a8>
    pmm_manager = &default_pmm_manager;
ffffffffc02027b8:	000a8b17          	auipc	s6,0xa8
ffffffffc02027bc:	f18b0b13          	addi	s6,s6,-232 # ffffffffc02aa6d0 <pmm_manager>
{
ffffffffc02027c0:	f486                	sd	ra,104(sp)
ffffffffc02027c2:	e8ca                	sd	s2,80(sp)
ffffffffc02027c4:	e4ce                	sd	s3,72(sp)
ffffffffc02027c6:	f0a2                	sd	s0,96(sp)
ffffffffc02027c8:	eca6                	sd	s1,88(sp)
ffffffffc02027ca:	e0d2                	sd	s4,64(sp)
ffffffffc02027cc:	fc56                	sd	s5,56(sp)
ffffffffc02027ce:	f45e                	sd	s7,40(sp)
ffffffffc02027d0:	f062                	sd	s8,32(sp)
ffffffffc02027d2:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02027d4:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02027d8:	9bdfd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    pmm_manager->init();
ffffffffc02027dc:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02027e0:	000a8997          	auipc	s3,0xa8
ffffffffc02027e4:	ef898993          	addi	s3,s3,-264 # ffffffffc02aa6d8 <va_pa_offset>
    pmm_manager->init();
ffffffffc02027e8:	679c                	ld	a5,8(a5)
ffffffffc02027ea:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02027ec:	57f5                	li	a5,-3
ffffffffc02027ee:	07fa                	slli	a5,a5,0x1e
ffffffffc02027f0:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc02027f4:	9a6fe0ef          	jal	ra,ffffffffc020099a <get_memory_base>
ffffffffc02027f8:	892a                	mv	s2,a0
    uint64_t mem_size = get_memory_size();
ffffffffc02027fa:	9aafe0ef          	jal	ra,ffffffffc02009a4 <get_memory_size>
    if (mem_size == 0)
ffffffffc02027fe:	200505e3          	beqz	a0,ffffffffc0203208 <pmm_init+0xa66>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc0202802:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc0202804:	00004517          	auipc	a0,0x4
ffffffffc0202808:	05450513          	addi	a0,a0,84 # ffffffffc0206858 <default_pmm_manager+0x1e0>
ffffffffc020280c:	989fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc0202810:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202814:	fff40693          	addi	a3,s0,-1
ffffffffc0202818:	864a                	mv	a2,s2
ffffffffc020281a:	85a6                	mv	a1,s1
ffffffffc020281c:	00004517          	auipc	a0,0x4
ffffffffc0202820:	05450513          	addi	a0,a0,84 # ffffffffc0206870 <default_pmm_manager+0x1f8>
ffffffffc0202824:	971fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0202828:	c8000737          	lui	a4,0xc8000
ffffffffc020282c:	87a2                	mv	a5,s0
ffffffffc020282e:	54876163          	bltu	a4,s0,ffffffffc0202d70 <pmm_init+0x5ce>
ffffffffc0202832:	757d                	lui	a0,0xfffff
ffffffffc0202834:	000a9617          	auipc	a2,0xa9
ffffffffc0202838:	ec760613          	addi	a2,a2,-313 # ffffffffc02ab6fb <end+0xfff>
ffffffffc020283c:	8e69                	and	a2,a2,a0
ffffffffc020283e:	000a8497          	auipc	s1,0xa8
ffffffffc0202842:	e8248493          	addi	s1,s1,-382 # ffffffffc02aa6c0 <npage>
ffffffffc0202846:	00c7d513          	srli	a0,a5,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020284a:	000a8b97          	auipc	s7,0xa8
ffffffffc020284e:	e7eb8b93          	addi	s7,s7,-386 # ffffffffc02aa6c8 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0202852:	e088                	sd	a0,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202854:	00cbb023          	sd	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202858:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020285c:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc020285e:	02f50863          	beq	a0,a5,ffffffffc020288e <pmm_init+0xec>
ffffffffc0202862:	4781                	li	a5,0
ffffffffc0202864:	4585                	li	a1,1
ffffffffc0202866:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc020286a:	00679513          	slli	a0,a5,0x6
ffffffffc020286e:	9532                	add	a0,a0,a2
ffffffffc0202870:	00850713          	addi	a4,a0,8 # fffffffffffff008 <end+0x3fd5490c>
ffffffffc0202874:	40b7302f          	amoor.d	zero,a1,(a4)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202878:	6088                	ld	a0,0(s1)
ffffffffc020287a:	0785                	addi	a5,a5,1
        SetPageReserved(pages + i);
ffffffffc020287c:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202880:	00d50733          	add	a4,a0,a3
ffffffffc0202884:	fee7e3e3          	bltu	a5,a4,ffffffffc020286a <pmm_init+0xc8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202888:	071a                	slli	a4,a4,0x6
ffffffffc020288a:	00e606b3          	add	a3,a2,a4
ffffffffc020288e:	c02007b7          	lui	a5,0xc0200
ffffffffc0202892:	2ef6ece3          	bltu	a3,a5,ffffffffc020338a <pmm_init+0xbe8>
ffffffffc0202896:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc020289a:	77fd                	lui	a5,0xfffff
ffffffffc020289c:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020289e:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc02028a0:	5086eb63          	bltu	a3,s0,ffffffffc0202db6 <pmm_init+0x614>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc02028a4:	00004517          	auipc	a0,0x4
ffffffffc02028a8:	ff450513          	addi	a0,a0,-12 # ffffffffc0206898 <default_pmm_manager+0x220>
ffffffffc02028ac:	8e9fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc02028b0:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc02028b4:	000a8917          	auipc	s2,0xa8
ffffffffc02028b8:	e0490913          	addi	s2,s2,-508 # ffffffffc02aa6b8 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc02028bc:	7b9c                	ld	a5,48(a5)
ffffffffc02028be:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02028c0:	00004517          	auipc	a0,0x4
ffffffffc02028c4:	ff050513          	addi	a0,a0,-16 # ffffffffc02068b0 <default_pmm_manager+0x238>
ffffffffc02028c8:	8cdfd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc02028cc:	00007697          	auipc	a3,0x7
ffffffffc02028d0:	73468693          	addi	a3,a3,1844 # ffffffffc020a000 <boot_page_table_sv39>
ffffffffc02028d4:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc02028d8:	c02007b7          	lui	a5,0xc0200
ffffffffc02028dc:	28f6ebe3          	bltu	a3,a5,ffffffffc0203372 <pmm_init+0xbd0>
ffffffffc02028e0:	0009b783          	ld	a5,0(s3)
ffffffffc02028e4:	8e9d                	sub	a3,a3,a5
ffffffffc02028e6:	000a8797          	auipc	a5,0xa8
ffffffffc02028ea:	dcd7b523          	sd	a3,-566(a5) # ffffffffc02aa6b0 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02028ee:	100027f3          	csrr	a5,sstatus
ffffffffc02028f2:	8b89                	andi	a5,a5,2
ffffffffc02028f4:	4a079763          	bnez	a5,ffffffffc0202da2 <pmm_init+0x600>
        ret = pmm_manager->nr_free_pages();
ffffffffc02028f8:	000b3783          	ld	a5,0(s6)
ffffffffc02028fc:	779c                	ld	a5,40(a5)
ffffffffc02028fe:	9782                	jalr	a5
ffffffffc0202900:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202902:	6098                	ld	a4,0(s1)
ffffffffc0202904:	c80007b7          	lui	a5,0xc8000
ffffffffc0202908:	83b1                	srli	a5,a5,0xc
ffffffffc020290a:	66e7e363          	bltu	a5,a4,ffffffffc0202f70 <pmm_init+0x7ce>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc020290e:	00093503          	ld	a0,0(s2)
ffffffffc0202912:	62050f63          	beqz	a0,ffffffffc0202f50 <pmm_init+0x7ae>
ffffffffc0202916:	03451793          	slli	a5,a0,0x34
ffffffffc020291a:	62079b63          	bnez	a5,ffffffffc0202f50 <pmm_init+0x7ae>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc020291e:	4601                	li	a2,0
ffffffffc0202920:	4581                	li	a1,0
ffffffffc0202922:	8c3ff0ef          	jal	ra,ffffffffc02021e4 <get_page>
ffffffffc0202926:	60051563          	bnez	a0,ffffffffc0202f30 <pmm_init+0x78e>
ffffffffc020292a:	100027f3          	csrr	a5,sstatus
ffffffffc020292e:	8b89                	andi	a5,a5,2
ffffffffc0202930:	44079e63          	bnez	a5,ffffffffc0202d8c <pmm_init+0x5ea>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202934:	000b3783          	ld	a5,0(s6)
ffffffffc0202938:	4505                	li	a0,1
ffffffffc020293a:	6f9c                	ld	a5,24(a5)
ffffffffc020293c:	9782                	jalr	a5
ffffffffc020293e:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0202940:	00093503          	ld	a0,0(s2)
ffffffffc0202944:	4681                	li	a3,0
ffffffffc0202946:	4601                	li	a2,0
ffffffffc0202948:	85d2                	mv	a1,s4
ffffffffc020294a:	d63ff0ef          	jal	ra,ffffffffc02026ac <page_insert>
ffffffffc020294e:	26051ae3          	bnez	a0,ffffffffc02033c2 <pmm_init+0xc20>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0202952:	00093503          	ld	a0,0(s2)
ffffffffc0202956:	4601                	li	a2,0
ffffffffc0202958:	4581                	li	a1,0
ffffffffc020295a:	e62ff0ef          	jal	ra,ffffffffc0201fbc <get_pte>
ffffffffc020295e:	240502e3          	beqz	a0,ffffffffc02033a2 <pmm_init+0xc00>
    assert(pte2page(*ptep) == p1);
ffffffffc0202962:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202964:	0017f713          	andi	a4,a5,1
ffffffffc0202968:	5a070263          	beqz	a4,ffffffffc0202f0c <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc020296c:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020296e:	078a                	slli	a5,a5,0x2
ffffffffc0202970:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202972:	58e7fb63          	bgeu	a5,a4,ffffffffc0202f08 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202976:	000bb683          	ld	a3,0(s7)
ffffffffc020297a:	fff80637          	lui	a2,0xfff80
ffffffffc020297e:	97b2                	add	a5,a5,a2
ffffffffc0202980:	079a                	slli	a5,a5,0x6
ffffffffc0202982:	97b6                	add	a5,a5,a3
ffffffffc0202984:	14fa17e3          	bne	s4,a5,ffffffffc02032d2 <pmm_init+0xb30>
    assert(page_ref(p1) == 1);
ffffffffc0202988:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8ba8>
ffffffffc020298c:	4785                	li	a5,1
ffffffffc020298e:	12f692e3          	bne	a3,a5,ffffffffc02032b2 <pmm_init+0xb10>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0202992:	00093503          	ld	a0,0(s2)
ffffffffc0202996:	77fd                	lui	a5,0xfffff
ffffffffc0202998:	6114                	ld	a3,0(a0)
ffffffffc020299a:	068a                	slli	a3,a3,0x2
ffffffffc020299c:	8efd                	and	a3,a3,a5
ffffffffc020299e:	00c6d613          	srli	a2,a3,0xc
ffffffffc02029a2:	0ee67ce3          	bgeu	a2,a4,ffffffffc020329a <pmm_init+0xaf8>
ffffffffc02029a6:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02029aa:	96e2                	add	a3,a3,s8
ffffffffc02029ac:	0006ba83          	ld	s5,0(a3)
ffffffffc02029b0:	0a8a                	slli	s5,s5,0x2
ffffffffc02029b2:	00fafab3          	and	s5,s5,a5
ffffffffc02029b6:	00cad793          	srli	a5,s5,0xc
ffffffffc02029ba:	0ce7f3e3          	bgeu	a5,a4,ffffffffc0203280 <pmm_init+0xade>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02029be:	4601                	li	a2,0
ffffffffc02029c0:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02029c2:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02029c4:	df8ff0ef          	jal	ra,ffffffffc0201fbc <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02029c8:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02029ca:	55551363          	bne	a0,s5,ffffffffc0202f10 <pmm_init+0x76e>
ffffffffc02029ce:	100027f3          	csrr	a5,sstatus
ffffffffc02029d2:	8b89                	andi	a5,a5,2
ffffffffc02029d4:	3a079163          	bnez	a5,ffffffffc0202d76 <pmm_init+0x5d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc02029d8:	000b3783          	ld	a5,0(s6)
ffffffffc02029dc:	4505                	li	a0,1
ffffffffc02029de:	6f9c                	ld	a5,24(a5)
ffffffffc02029e0:	9782                	jalr	a5
ffffffffc02029e2:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02029e4:	00093503          	ld	a0,0(s2)
ffffffffc02029e8:	46d1                	li	a3,20
ffffffffc02029ea:	6605                	lui	a2,0x1
ffffffffc02029ec:	85e2                	mv	a1,s8
ffffffffc02029ee:	cbfff0ef          	jal	ra,ffffffffc02026ac <page_insert>
ffffffffc02029f2:	060517e3          	bnez	a0,ffffffffc0203260 <pmm_init+0xabe>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02029f6:	00093503          	ld	a0,0(s2)
ffffffffc02029fa:	4601                	li	a2,0
ffffffffc02029fc:	6585                	lui	a1,0x1
ffffffffc02029fe:	dbeff0ef          	jal	ra,ffffffffc0201fbc <get_pte>
ffffffffc0202a02:	02050fe3          	beqz	a0,ffffffffc0203240 <pmm_init+0xa9e>
    assert(*ptep & PTE_U);
ffffffffc0202a06:	611c                	ld	a5,0(a0)
ffffffffc0202a08:	0107f713          	andi	a4,a5,16
ffffffffc0202a0c:	7c070e63          	beqz	a4,ffffffffc02031e8 <pmm_init+0xa46>
    assert(*ptep & PTE_W);
ffffffffc0202a10:	8b91                	andi	a5,a5,4
ffffffffc0202a12:	7a078b63          	beqz	a5,ffffffffc02031c8 <pmm_init+0xa26>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0202a16:	00093503          	ld	a0,0(s2)
ffffffffc0202a1a:	611c                	ld	a5,0(a0)
ffffffffc0202a1c:	8bc1                	andi	a5,a5,16
ffffffffc0202a1e:	78078563          	beqz	a5,ffffffffc02031a8 <pmm_init+0xa06>
    assert(page_ref(p2) == 1);
ffffffffc0202a22:	000c2703          	lw	a4,0(s8)
ffffffffc0202a26:	4785                	li	a5,1
ffffffffc0202a28:	76f71063          	bne	a4,a5,ffffffffc0203188 <pmm_init+0x9e6>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0202a2c:	4681                	li	a3,0
ffffffffc0202a2e:	6605                	lui	a2,0x1
ffffffffc0202a30:	85d2                	mv	a1,s4
ffffffffc0202a32:	c7bff0ef          	jal	ra,ffffffffc02026ac <page_insert>
ffffffffc0202a36:	72051963          	bnez	a0,ffffffffc0203168 <pmm_init+0x9c6>
    assert(page_ref(p1) == 2);
ffffffffc0202a3a:	000a2703          	lw	a4,0(s4)
ffffffffc0202a3e:	4789                	li	a5,2
ffffffffc0202a40:	70f71463          	bne	a4,a5,ffffffffc0203148 <pmm_init+0x9a6>
    assert(page_ref(p2) == 0);
ffffffffc0202a44:	000c2783          	lw	a5,0(s8)
ffffffffc0202a48:	6e079063          	bnez	a5,ffffffffc0203128 <pmm_init+0x986>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202a4c:	00093503          	ld	a0,0(s2)
ffffffffc0202a50:	4601                	li	a2,0
ffffffffc0202a52:	6585                	lui	a1,0x1
ffffffffc0202a54:	d68ff0ef          	jal	ra,ffffffffc0201fbc <get_pte>
ffffffffc0202a58:	6a050863          	beqz	a0,ffffffffc0203108 <pmm_init+0x966>
    assert(pte2page(*ptep) == p1);
ffffffffc0202a5c:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202a5e:	00177793          	andi	a5,a4,1
ffffffffc0202a62:	4a078563          	beqz	a5,ffffffffc0202f0c <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc0202a66:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202a68:	00271793          	slli	a5,a4,0x2
ffffffffc0202a6c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202a6e:	48d7fd63          	bgeu	a5,a3,ffffffffc0202f08 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a72:	000bb683          	ld	a3,0(s7)
ffffffffc0202a76:	fff80ab7          	lui	s5,0xfff80
ffffffffc0202a7a:	97d6                	add	a5,a5,s5
ffffffffc0202a7c:	079a                	slli	a5,a5,0x6
ffffffffc0202a7e:	97b6                	add	a5,a5,a3
ffffffffc0202a80:	66fa1463          	bne	s4,a5,ffffffffc02030e8 <pmm_init+0x946>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202a84:	8b41                	andi	a4,a4,16
ffffffffc0202a86:	64071163          	bnez	a4,ffffffffc02030c8 <pmm_init+0x926>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc0202a8a:	00093503          	ld	a0,0(s2)
ffffffffc0202a8e:	4581                	li	a1,0
ffffffffc0202a90:	b81ff0ef          	jal	ra,ffffffffc0202610 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202a94:	000a2c83          	lw	s9,0(s4)
ffffffffc0202a98:	4785                	li	a5,1
ffffffffc0202a9a:	60fc9763          	bne	s9,a5,ffffffffc02030a8 <pmm_init+0x906>
    assert(page_ref(p2) == 0);
ffffffffc0202a9e:	000c2783          	lw	a5,0(s8)
ffffffffc0202aa2:	5e079363          	bnez	a5,ffffffffc0203088 <pmm_init+0x8e6>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc0202aa6:	00093503          	ld	a0,0(s2)
ffffffffc0202aaa:	6585                	lui	a1,0x1
ffffffffc0202aac:	b65ff0ef          	jal	ra,ffffffffc0202610 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202ab0:	000a2783          	lw	a5,0(s4)
ffffffffc0202ab4:	52079a63          	bnez	a5,ffffffffc0202fe8 <pmm_init+0x846>
    assert(page_ref(p2) == 0);
ffffffffc0202ab8:	000c2783          	lw	a5,0(s8)
ffffffffc0202abc:	50079663          	bnez	a5,ffffffffc0202fc8 <pmm_init+0x826>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202ac0:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202ac4:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ac6:	000a3683          	ld	a3,0(s4)
ffffffffc0202aca:	068a                	slli	a3,a3,0x2
ffffffffc0202acc:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0202ace:	42b6fd63          	bgeu	a3,a1,ffffffffc0202f08 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ad2:	000bb503          	ld	a0,0(s7)
ffffffffc0202ad6:	96d6                	add	a3,a3,s5
ffffffffc0202ad8:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0202ada:	00d507b3          	add	a5,a0,a3
ffffffffc0202ade:	439c                	lw	a5,0(a5)
ffffffffc0202ae0:	4d979463          	bne	a5,s9,ffffffffc0202fa8 <pmm_init+0x806>
    return page - pages + nbase;
ffffffffc0202ae4:	8699                	srai	a3,a3,0x6
ffffffffc0202ae6:	00080637          	lui	a2,0x80
ffffffffc0202aea:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0202aec:	00c69713          	slli	a4,a3,0xc
ffffffffc0202af0:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202af2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202af4:	48b77e63          	bgeu	a4,a1,ffffffffc0202f90 <pmm_init+0x7ee>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202af8:	0009b703          	ld	a4,0(s3)
ffffffffc0202afc:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0202afe:	629c                	ld	a5,0(a3)
ffffffffc0202b00:	078a                	slli	a5,a5,0x2
ffffffffc0202b02:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b04:	40b7f263          	bgeu	a5,a1,ffffffffc0202f08 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b08:	8f91                	sub	a5,a5,a2
ffffffffc0202b0a:	079a                	slli	a5,a5,0x6
ffffffffc0202b0c:	953e                	add	a0,a0,a5
ffffffffc0202b0e:	100027f3          	csrr	a5,sstatus
ffffffffc0202b12:	8b89                	andi	a5,a5,2
ffffffffc0202b14:	30079963          	bnez	a5,ffffffffc0202e26 <pmm_init+0x684>
        pmm_manager->free_pages(base, n);
ffffffffc0202b18:	000b3783          	ld	a5,0(s6)
ffffffffc0202b1c:	4585                	li	a1,1
ffffffffc0202b1e:	739c                	ld	a5,32(a5)
ffffffffc0202b20:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b22:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202b26:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b28:	078a                	slli	a5,a5,0x2
ffffffffc0202b2a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b2c:	3ce7fe63          	bgeu	a5,a4,ffffffffc0202f08 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b30:	000bb503          	ld	a0,0(s7)
ffffffffc0202b34:	fff80737          	lui	a4,0xfff80
ffffffffc0202b38:	97ba                	add	a5,a5,a4
ffffffffc0202b3a:	079a                	slli	a5,a5,0x6
ffffffffc0202b3c:	953e                	add	a0,a0,a5
ffffffffc0202b3e:	100027f3          	csrr	a5,sstatus
ffffffffc0202b42:	8b89                	andi	a5,a5,2
ffffffffc0202b44:	2c079563          	bnez	a5,ffffffffc0202e0e <pmm_init+0x66c>
ffffffffc0202b48:	000b3783          	ld	a5,0(s6)
ffffffffc0202b4c:	4585                	li	a1,1
ffffffffc0202b4e:	739c                	ld	a5,32(a5)
ffffffffc0202b50:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202b52:	00093783          	ld	a5,0(s2)
ffffffffc0202b56:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd54904>
    asm volatile("sfence.vma");
ffffffffc0202b5a:	12000073          	sfence.vma
ffffffffc0202b5e:	100027f3          	csrr	a5,sstatus
ffffffffc0202b62:	8b89                	andi	a5,a5,2
ffffffffc0202b64:	28079b63          	bnez	a5,ffffffffc0202dfa <pmm_init+0x658>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202b68:	000b3783          	ld	a5,0(s6)
ffffffffc0202b6c:	779c                	ld	a5,40(a5)
ffffffffc0202b6e:	9782                	jalr	a5
ffffffffc0202b70:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202b72:	4b441b63          	bne	s0,s4,ffffffffc0203028 <pmm_init+0x886>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202b76:	00004517          	auipc	a0,0x4
ffffffffc0202b7a:	06250513          	addi	a0,a0,98 # ffffffffc0206bd8 <default_pmm_manager+0x560>
ffffffffc0202b7e:	e16fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0202b82:	100027f3          	csrr	a5,sstatus
ffffffffc0202b86:	8b89                	andi	a5,a5,2
ffffffffc0202b88:	24079f63          	bnez	a5,ffffffffc0202de6 <pmm_init+0x644>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202b8c:	000b3783          	ld	a5,0(s6)
ffffffffc0202b90:	779c                	ld	a5,40(a5)
ffffffffc0202b92:	9782                	jalr	a5
ffffffffc0202b94:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202b96:	6098                	ld	a4,0(s1)
ffffffffc0202b98:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202b9c:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202b9e:	00c71793          	slli	a5,a4,0xc
ffffffffc0202ba2:	6a05                	lui	s4,0x1
ffffffffc0202ba4:	02f47c63          	bgeu	s0,a5,ffffffffc0202bdc <pmm_init+0x43a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202ba8:	00c45793          	srli	a5,s0,0xc
ffffffffc0202bac:	00093503          	ld	a0,0(s2)
ffffffffc0202bb0:	2ee7ff63          	bgeu	a5,a4,ffffffffc0202eae <pmm_init+0x70c>
ffffffffc0202bb4:	0009b583          	ld	a1,0(s3)
ffffffffc0202bb8:	4601                	li	a2,0
ffffffffc0202bba:	95a2                	add	a1,a1,s0
ffffffffc0202bbc:	c00ff0ef          	jal	ra,ffffffffc0201fbc <get_pte>
ffffffffc0202bc0:	32050463          	beqz	a0,ffffffffc0202ee8 <pmm_init+0x746>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202bc4:	611c                	ld	a5,0(a0)
ffffffffc0202bc6:	078a                	slli	a5,a5,0x2
ffffffffc0202bc8:	0157f7b3          	and	a5,a5,s5
ffffffffc0202bcc:	2e879e63          	bne	a5,s0,ffffffffc0202ec8 <pmm_init+0x726>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202bd0:	6098                	ld	a4,0(s1)
ffffffffc0202bd2:	9452                	add	s0,s0,s4
ffffffffc0202bd4:	00c71793          	slli	a5,a4,0xc
ffffffffc0202bd8:	fcf468e3          	bltu	s0,a5,ffffffffc0202ba8 <pmm_init+0x406>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc0202bdc:	00093783          	ld	a5,0(s2)
ffffffffc0202be0:	639c                	ld	a5,0(a5)
ffffffffc0202be2:	42079363          	bnez	a5,ffffffffc0203008 <pmm_init+0x866>
ffffffffc0202be6:	100027f3          	csrr	a5,sstatus
ffffffffc0202bea:	8b89                	andi	a5,a5,2
ffffffffc0202bec:	24079963          	bnez	a5,ffffffffc0202e3e <pmm_init+0x69c>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202bf0:	000b3783          	ld	a5,0(s6)
ffffffffc0202bf4:	4505                	li	a0,1
ffffffffc0202bf6:	6f9c                	ld	a5,24(a5)
ffffffffc0202bf8:	9782                	jalr	a5
ffffffffc0202bfa:	8a2a                	mv	s4,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202bfc:	00093503          	ld	a0,0(s2)
ffffffffc0202c00:	4699                	li	a3,6
ffffffffc0202c02:	10000613          	li	a2,256
ffffffffc0202c06:	85d2                	mv	a1,s4
ffffffffc0202c08:	aa5ff0ef          	jal	ra,ffffffffc02026ac <page_insert>
ffffffffc0202c0c:	44051e63          	bnez	a0,ffffffffc0203068 <pmm_init+0x8c6>
    assert(page_ref(p) == 1);
ffffffffc0202c10:	000a2703          	lw	a4,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8ba8>
ffffffffc0202c14:	4785                	li	a5,1
ffffffffc0202c16:	42f71963          	bne	a4,a5,ffffffffc0203048 <pmm_init+0x8a6>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202c1a:	00093503          	ld	a0,0(s2)
ffffffffc0202c1e:	6405                	lui	s0,0x1
ffffffffc0202c20:	4699                	li	a3,6
ffffffffc0202c22:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8aa8>
ffffffffc0202c26:	85d2                	mv	a1,s4
ffffffffc0202c28:	a85ff0ef          	jal	ra,ffffffffc02026ac <page_insert>
ffffffffc0202c2c:	72051363          	bnez	a0,ffffffffc0203352 <pmm_init+0xbb0>
    assert(page_ref(p) == 2);
ffffffffc0202c30:	000a2703          	lw	a4,0(s4)
ffffffffc0202c34:	4789                	li	a5,2
ffffffffc0202c36:	6ef71e63          	bne	a4,a5,ffffffffc0203332 <pmm_init+0xb90>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202c3a:	00004597          	auipc	a1,0x4
ffffffffc0202c3e:	0e658593          	addi	a1,a1,230 # ffffffffc0206d20 <default_pmm_manager+0x6a8>
ffffffffc0202c42:	10000513          	li	a0,256
ffffffffc0202c46:	2f5020ef          	jal	ra,ffffffffc020573a <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202c4a:	10040593          	addi	a1,s0,256
ffffffffc0202c4e:	10000513          	li	a0,256
ffffffffc0202c52:	2fb020ef          	jal	ra,ffffffffc020574c <strcmp>
ffffffffc0202c56:	6a051e63          	bnez	a0,ffffffffc0203312 <pmm_init+0xb70>
    return page - pages + nbase;
ffffffffc0202c5a:	000bb683          	ld	a3,0(s7)
ffffffffc0202c5e:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202c62:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0202c64:	40da06b3          	sub	a3,s4,a3
ffffffffc0202c68:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202c6a:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202c6c:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202c6e:	8031                	srli	s0,s0,0xc
ffffffffc0202c70:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202c74:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202c76:	30f77d63          	bgeu	a4,a5,ffffffffc0202f90 <pmm_init+0x7ee>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202c7a:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202c7e:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202c82:	96be                	add	a3,a3,a5
ffffffffc0202c84:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202c88:	27d020ef          	jal	ra,ffffffffc0205704 <strlen>
ffffffffc0202c8c:	66051363          	bnez	a0,ffffffffc02032f2 <pmm_init+0xb50>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0202c90:	00093a83          	ld	s5,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202c94:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202c96:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fd54904>
ffffffffc0202c9a:	068a                	slli	a3,a3,0x2
ffffffffc0202c9c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0202c9e:	26f6f563          	bgeu	a3,a5,ffffffffc0202f08 <pmm_init+0x766>
    return KADDR(page2pa(page));
ffffffffc0202ca2:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ca4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202ca6:	2ef47563          	bgeu	s0,a5,ffffffffc0202f90 <pmm_init+0x7ee>
ffffffffc0202caa:	0009b403          	ld	s0,0(s3)
ffffffffc0202cae:	9436                	add	s0,s0,a3
ffffffffc0202cb0:	100027f3          	csrr	a5,sstatus
ffffffffc0202cb4:	8b89                	andi	a5,a5,2
ffffffffc0202cb6:	1e079163          	bnez	a5,ffffffffc0202e98 <pmm_init+0x6f6>
        pmm_manager->free_pages(base, n);
ffffffffc0202cba:	000b3783          	ld	a5,0(s6)
ffffffffc0202cbe:	4585                	li	a1,1
ffffffffc0202cc0:	8552                	mv	a0,s4
ffffffffc0202cc2:	739c                	ld	a5,32(a5)
ffffffffc0202cc4:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202cc6:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage)
ffffffffc0202cc8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202cca:	078a                	slli	a5,a5,0x2
ffffffffc0202ccc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202cce:	22e7fd63          	bgeu	a5,a4,ffffffffc0202f08 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202cd2:	000bb503          	ld	a0,0(s7)
ffffffffc0202cd6:	fff80737          	lui	a4,0xfff80
ffffffffc0202cda:	97ba                	add	a5,a5,a4
ffffffffc0202cdc:	079a                	slli	a5,a5,0x6
ffffffffc0202cde:	953e                	add	a0,a0,a5
ffffffffc0202ce0:	100027f3          	csrr	a5,sstatus
ffffffffc0202ce4:	8b89                	andi	a5,a5,2
ffffffffc0202ce6:	18079d63          	bnez	a5,ffffffffc0202e80 <pmm_init+0x6de>
ffffffffc0202cea:	000b3783          	ld	a5,0(s6)
ffffffffc0202cee:	4585                	li	a1,1
ffffffffc0202cf0:	739c                	ld	a5,32(a5)
ffffffffc0202cf2:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202cf4:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage)
ffffffffc0202cf8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202cfa:	078a                	slli	a5,a5,0x2
ffffffffc0202cfc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202cfe:	20e7f563          	bgeu	a5,a4,ffffffffc0202f08 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d02:	000bb503          	ld	a0,0(s7)
ffffffffc0202d06:	fff80737          	lui	a4,0xfff80
ffffffffc0202d0a:	97ba                	add	a5,a5,a4
ffffffffc0202d0c:	079a                	slli	a5,a5,0x6
ffffffffc0202d0e:	953e                	add	a0,a0,a5
ffffffffc0202d10:	100027f3          	csrr	a5,sstatus
ffffffffc0202d14:	8b89                	andi	a5,a5,2
ffffffffc0202d16:	14079963          	bnez	a5,ffffffffc0202e68 <pmm_init+0x6c6>
ffffffffc0202d1a:	000b3783          	ld	a5,0(s6)
ffffffffc0202d1e:	4585                	li	a1,1
ffffffffc0202d20:	739c                	ld	a5,32(a5)
ffffffffc0202d22:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202d24:	00093783          	ld	a5,0(s2)
ffffffffc0202d28:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc0202d2c:	12000073          	sfence.vma
ffffffffc0202d30:	100027f3          	csrr	a5,sstatus
ffffffffc0202d34:	8b89                	andi	a5,a5,2
ffffffffc0202d36:	10079f63          	bnez	a5,ffffffffc0202e54 <pmm_init+0x6b2>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202d3a:	000b3783          	ld	a5,0(s6)
ffffffffc0202d3e:	779c                	ld	a5,40(a5)
ffffffffc0202d40:	9782                	jalr	a5
ffffffffc0202d42:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202d44:	4c8c1e63          	bne	s8,s0,ffffffffc0203220 <pmm_init+0xa7e>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202d48:	00004517          	auipc	a0,0x4
ffffffffc0202d4c:	05050513          	addi	a0,a0,80 # ffffffffc0206d98 <default_pmm_manager+0x720>
ffffffffc0202d50:	c44fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
}
ffffffffc0202d54:	7406                	ld	s0,96(sp)
ffffffffc0202d56:	70a6                	ld	ra,104(sp)
ffffffffc0202d58:	64e6                	ld	s1,88(sp)
ffffffffc0202d5a:	6946                	ld	s2,80(sp)
ffffffffc0202d5c:	69a6                	ld	s3,72(sp)
ffffffffc0202d5e:	6a06                	ld	s4,64(sp)
ffffffffc0202d60:	7ae2                	ld	s5,56(sp)
ffffffffc0202d62:	7b42                	ld	s6,48(sp)
ffffffffc0202d64:	7ba2                	ld	s7,40(sp)
ffffffffc0202d66:	7c02                	ld	s8,32(sp)
ffffffffc0202d68:	6ce2                	ld	s9,24(sp)
ffffffffc0202d6a:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0202d6c:	f97fe06f          	j	ffffffffc0201d02 <kmalloc_init>
    npage = maxpa / PGSIZE;
ffffffffc0202d70:	c80007b7          	lui	a5,0xc8000
ffffffffc0202d74:	bc7d                	j	ffffffffc0202832 <pmm_init+0x90>
        intr_disable();
ffffffffc0202d76:	c3ffd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202d7a:	000b3783          	ld	a5,0(s6)
ffffffffc0202d7e:	4505                	li	a0,1
ffffffffc0202d80:	6f9c                	ld	a5,24(a5)
ffffffffc0202d82:	9782                	jalr	a5
ffffffffc0202d84:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202d86:	c29fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202d8a:	b9a9                	j	ffffffffc02029e4 <pmm_init+0x242>
        intr_disable();
ffffffffc0202d8c:	c29fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202d90:	000b3783          	ld	a5,0(s6)
ffffffffc0202d94:	4505                	li	a0,1
ffffffffc0202d96:	6f9c                	ld	a5,24(a5)
ffffffffc0202d98:	9782                	jalr	a5
ffffffffc0202d9a:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202d9c:	c13fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202da0:	b645                	j	ffffffffc0202940 <pmm_init+0x19e>
        intr_disable();
ffffffffc0202da2:	c13fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202da6:	000b3783          	ld	a5,0(s6)
ffffffffc0202daa:	779c                	ld	a5,40(a5)
ffffffffc0202dac:	9782                	jalr	a5
ffffffffc0202dae:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202db0:	bfffd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202db4:	b6b9                	j	ffffffffc0202902 <pmm_init+0x160>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202db6:	6705                	lui	a4,0x1
ffffffffc0202db8:	177d                	addi	a4,a4,-1
ffffffffc0202dba:	96ba                	add	a3,a3,a4
ffffffffc0202dbc:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc0202dbe:	00c7d713          	srli	a4,a5,0xc
ffffffffc0202dc2:	14a77363          	bgeu	a4,a0,ffffffffc0202f08 <pmm_init+0x766>
    pmm_manager->init_memmap(base, n);
ffffffffc0202dc6:	000b3683          	ld	a3,0(s6)
    return &pages[PPN(pa) - nbase];
ffffffffc0202dca:	fff80537          	lui	a0,0xfff80
ffffffffc0202dce:	972a                	add	a4,a4,a0
ffffffffc0202dd0:	6a94                	ld	a3,16(a3)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202dd2:	8c1d                	sub	s0,s0,a5
ffffffffc0202dd4:	00671513          	slli	a0,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0202dd8:	00c45593          	srli	a1,s0,0xc
ffffffffc0202ddc:	9532                	add	a0,a0,a2
ffffffffc0202dde:	9682                	jalr	a3
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202de0:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202de4:	b4c1                	j	ffffffffc02028a4 <pmm_init+0x102>
        intr_disable();
ffffffffc0202de6:	bcffd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202dea:	000b3783          	ld	a5,0(s6)
ffffffffc0202dee:	779c                	ld	a5,40(a5)
ffffffffc0202df0:	9782                	jalr	a5
ffffffffc0202df2:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202df4:	bbbfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202df8:	bb79                	j	ffffffffc0202b96 <pmm_init+0x3f4>
        intr_disable();
ffffffffc0202dfa:	bbbfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202dfe:	000b3783          	ld	a5,0(s6)
ffffffffc0202e02:	779c                	ld	a5,40(a5)
ffffffffc0202e04:	9782                	jalr	a5
ffffffffc0202e06:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202e08:	ba7fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202e0c:	b39d                	j	ffffffffc0202b72 <pmm_init+0x3d0>
ffffffffc0202e0e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202e10:	ba5fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202e14:	000b3783          	ld	a5,0(s6)
ffffffffc0202e18:	6522                	ld	a0,8(sp)
ffffffffc0202e1a:	4585                	li	a1,1
ffffffffc0202e1c:	739c                	ld	a5,32(a5)
ffffffffc0202e1e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e20:	b8ffd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202e24:	b33d                	j	ffffffffc0202b52 <pmm_init+0x3b0>
ffffffffc0202e26:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202e28:	b8dfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202e2c:	000b3783          	ld	a5,0(s6)
ffffffffc0202e30:	6522                	ld	a0,8(sp)
ffffffffc0202e32:	4585                	li	a1,1
ffffffffc0202e34:	739c                	ld	a5,32(a5)
ffffffffc0202e36:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e38:	b77fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202e3c:	b1dd                	j	ffffffffc0202b22 <pmm_init+0x380>
        intr_disable();
ffffffffc0202e3e:	b77fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202e42:	000b3783          	ld	a5,0(s6)
ffffffffc0202e46:	4505                	li	a0,1
ffffffffc0202e48:	6f9c                	ld	a5,24(a5)
ffffffffc0202e4a:	9782                	jalr	a5
ffffffffc0202e4c:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202e4e:	b61fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202e52:	b36d                	j	ffffffffc0202bfc <pmm_init+0x45a>
        intr_disable();
ffffffffc0202e54:	b61fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202e58:	000b3783          	ld	a5,0(s6)
ffffffffc0202e5c:	779c                	ld	a5,40(a5)
ffffffffc0202e5e:	9782                	jalr	a5
ffffffffc0202e60:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202e62:	b4dfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202e66:	bdf9                	j	ffffffffc0202d44 <pmm_init+0x5a2>
ffffffffc0202e68:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202e6a:	b4bfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202e6e:	000b3783          	ld	a5,0(s6)
ffffffffc0202e72:	6522                	ld	a0,8(sp)
ffffffffc0202e74:	4585                	li	a1,1
ffffffffc0202e76:	739c                	ld	a5,32(a5)
ffffffffc0202e78:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e7a:	b35fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202e7e:	b55d                	j	ffffffffc0202d24 <pmm_init+0x582>
ffffffffc0202e80:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202e82:	b33fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202e86:	000b3783          	ld	a5,0(s6)
ffffffffc0202e8a:	6522                	ld	a0,8(sp)
ffffffffc0202e8c:	4585                	li	a1,1
ffffffffc0202e8e:	739c                	ld	a5,32(a5)
ffffffffc0202e90:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e92:	b1dfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202e96:	bdb9                	j	ffffffffc0202cf4 <pmm_init+0x552>
        intr_disable();
ffffffffc0202e98:	b1dfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202e9c:	000b3783          	ld	a5,0(s6)
ffffffffc0202ea0:	4585                	li	a1,1
ffffffffc0202ea2:	8552                	mv	a0,s4
ffffffffc0202ea4:	739c                	ld	a5,32(a5)
ffffffffc0202ea6:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ea8:	b07fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202eac:	bd29                	j	ffffffffc0202cc6 <pmm_init+0x524>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202eae:	86a2                	mv	a3,s0
ffffffffc0202eb0:	00004617          	auipc	a2,0x4
ffffffffc0202eb4:	80060613          	addi	a2,a2,-2048 # ffffffffc02066b0 <default_pmm_manager+0x38>
ffffffffc0202eb8:	25600593          	li	a1,598
ffffffffc0202ebc:	00004517          	auipc	a0,0x4
ffffffffc0202ec0:	90c50513          	addi	a0,a0,-1780 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0202ec4:	dcafd0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202ec8:	00004697          	auipc	a3,0x4
ffffffffc0202ecc:	d7068693          	addi	a3,a3,-656 # ffffffffc0206c38 <default_pmm_manager+0x5c0>
ffffffffc0202ed0:	00003617          	auipc	a2,0x3
ffffffffc0202ed4:	3f860613          	addi	a2,a2,1016 # ffffffffc02062c8 <commands+0x890>
ffffffffc0202ed8:	25700593          	li	a1,599
ffffffffc0202edc:	00004517          	auipc	a0,0x4
ffffffffc0202ee0:	8ec50513          	addi	a0,a0,-1812 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0202ee4:	daafd0ef          	jal	ra,ffffffffc020048e <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202ee8:	00004697          	auipc	a3,0x4
ffffffffc0202eec:	d1068693          	addi	a3,a3,-752 # ffffffffc0206bf8 <default_pmm_manager+0x580>
ffffffffc0202ef0:	00003617          	auipc	a2,0x3
ffffffffc0202ef4:	3d860613          	addi	a2,a2,984 # ffffffffc02062c8 <commands+0x890>
ffffffffc0202ef8:	25600593          	li	a1,598
ffffffffc0202efc:	00004517          	auipc	a0,0x4
ffffffffc0202f00:	8cc50513          	addi	a0,a0,-1844 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0202f04:	d8afd0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc0202f08:	fc5fe0ef          	jal	ra,ffffffffc0201ecc <pa2page.part.0>
ffffffffc0202f0c:	fddfe0ef          	jal	ra,ffffffffc0201ee8 <pte2page.part.0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202f10:	00004697          	auipc	a3,0x4
ffffffffc0202f14:	ae068693          	addi	a3,a3,-1312 # ffffffffc02069f0 <default_pmm_manager+0x378>
ffffffffc0202f18:	00003617          	auipc	a2,0x3
ffffffffc0202f1c:	3b060613          	addi	a2,a2,944 # ffffffffc02062c8 <commands+0x890>
ffffffffc0202f20:	22600593          	li	a1,550
ffffffffc0202f24:	00004517          	auipc	a0,0x4
ffffffffc0202f28:	8a450513          	addi	a0,a0,-1884 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0202f2c:	d62fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0202f30:	00004697          	auipc	a3,0x4
ffffffffc0202f34:	a0068693          	addi	a3,a3,-1536 # ffffffffc0206930 <default_pmm_manager+0x2b8>
ffffffffc0202f38:	00003617          	auipc	a2,0x3
ffffffffc0202f3c:	39060613          	addi	a2,a2,912 # ffffffffc02062c8 <commands+0x890>
ffffffffc0202f40:	21900593          	li	a1,537
ffffffffc0202f44:	00004517          	auipc	a0,0x4
ffffffffc0202f48:	88450513          	addi	a0,a0,-1916 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0202f4c:	d42fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202f50:	00004697          	auipc	a3,0x4
ffffffffc0202f54:	9a068693          	addi	a3,a3,-1632 # ffffffffc02068f0 <default_pmm_manager+0x278>
ffffffffc0202f58:	00003617          	auipc	a2,0x3
ffffffffc0202f5c:	37060613          	addi	a2,a2,880 # ffffffffc02062c8 <commands+0x890>
ffffffffc0202f60:	21800593          	li	a1,536
ffffffffc0202f64:	00004517          	auipc	a0,0x4
ffffffffc0202f68:	86450513          	addi	a0,a0,-1948 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0202f6c:	d22fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202f70:	00004697          	auipc	a3,0x4
ffffffffc0202f74:	96068693          	addi	a3,a3,-1696 # ffffffffc02068d0 <default_pmm_manager+0x258>
ffffffffc0202f78:	00003617          	auipc	a2,0x3
ffffffffc0202f7c:	35060613          	addi	a2,a2,848 # ffffffffc02062c8 <commands+0x890>
ffffffffc0202f80:	21700593          	li	a1,535
ffffffffc0202f84:	00004517          	auipc	a0,0x4
ffffffffc0202f88:	84450513          	addi	a0,a0,-1980 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0202f8c:	d02fd0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc0202f90:	00003617          	auipc	a2,0x3
ffffffffc0202f94:	72060613          	addi	a2,a2,1824 # ffffffffc02066b0 <default_pmm_manager+0x38>
ffffffffc0202f98:	07100593          	li	a1,113
ffffffffc0202f9c:	00003517          	auipc	a0,0x3
ffffffffc0202fa0:	73c50513          	addi	a0,a0,1852 # ffffffffc02066d8 <default_pmm_manager+0x60>
ffffffffc0202fa4:	ceafd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202fa8:	00004697          	auipc	a3,0x4
ffffffffc0202fac:	bd868693          	addi	a3,a3,-1064 # ffffffffc0206b80 <default_pmm_manager+0x508>
ffffffffc0202fb0:	00003617          	auipc	a2,0x3
ffffffffc0202fb4:	31860613          	addi	a2,a2,792 # ffffffffc02062c8 <commands+0x890>
ffffffffc0202fb8:	23f00593          	li	a1,575
ffffffffc0202fbc:	00004517          	auipc	a0,0x4
ffffffffc0202fc0:	80c50513          	addi	a0,a0,-2036 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0202fc4:	ccafd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202fc8:	00004697          	auipc	a3,0x4
ffffffffc0202fcc:	b7068693          	addi	a3,a3,-1168 # ffffffffc0206b38 <default_pmm_manager+0x4c0>
ffffffffc0202fd0:	00003617          	auipc	a2,0x3
ffffffffc0202fd4:	2f860613          	addi	a2,a2,760 # ffffffffc02062c8 <commands+0x890>
ffffffffc0202fd8:	23d00593          	li	a1,573
ffffffffc0202fdc:	00003517          	auipc	a0,0x3
ffffffffc0202fe0:	7ec50513          	addi	a0,a0,2028 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0202fe4:	caafd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202fe8:	00004697          	auipc	a3,0x4
ffffffffc0202fec:	b8068693          	addi	a3,a3,-1152 # ffffffffc0206b68 <default_pmm_manager+0x4f0>
ffffffffc0202ff0:	00003617          	auipc	a2,0x3
ffffffffc0202ff4:	2d860613          	addi	a2,a2,728 # ffffffffc02062c8 <commands+0x890>
ffffffffc0202ff8:	23c00593          	li	a1,572
ffffffffc0202ffc:	00003517          	auipc	a0,0x3
ffffffffc0203000:	7cc50513          	addi	a0,a0,1996 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0203004:	c8afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc0203008:	00004697          	auipc	a3,0x4
ffffffffc020300c:	c4868693          	addi	a3,a3,-952 # ffffffffc0206c50 <default_pmm_manager+0x5d8>
ffffffffc0203010:	00003617          	auipc	a2,0x3
ffffffffc0203014:	2b860613          	addi	a2,a2,696 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203018:	25a00593          	li	a1,602
ffffffffc020301c:	00003517          	auipc	a0,0x3
ffffffffc0203020:	7ac50513          	addi	a0,a0,1964 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0203024:	c6afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0203028:	00004697          	auipc	a3,0x4
ffffffffc020302c:	b8868693          	addi	a3,a3,-1144 # ffffffffc0206bb0 <default_pmm_manager+0x538>
ffffffffc0203030:	00003617          	auipc	a2,0x3
ffffffffc0203034:	29860613          	addi	a2,a2,664 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203038:	24700593          	li	a1,583
ffffffffc020303c:	00003517          	auipc	a0,0x3
ffffffffc0203040:	78c50513          	addi	a0,a0,1932 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0203044:	c4afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p) == 1);
ffffffffc0203048:	00004697          	auipc	a3,0x4
ffffffffc020304c:	c6068693          	addi	a3,a3,-928 # ffffffffc0206ca8 <default_pmm_manager+0x630>
ffffffffc0203050:	00003617          	auipc	a2,0x3
ffffffffc0203054:	27860613          	addi	a2,a2,632 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203058:	25f00593          	li	a1,607
ffffffffc020305c:	00003517          	auipc	a0,0x3
ffffffffc0203060:	76c50513          	addi	a0,a0,1900 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0203064:	c2afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203068:	00004697          	auipc	a3,0x4
ffffffffc020306c:	c0068693          	addi	a3,a3,-1024 # ffffffffc0206c68 <default_pmm_manager+0x5f0>
ffffffffc0203070:	00003617          	auipc	a2,0x3
ffffffffc0203074:	25860613          	addi	a2,a2,600 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203078:	25e00593          	li	a1,606
ffffffffc020307c:	00003517          	auipc	a0,0x3
ffffffffc0203080:	74c50513          	addi	a0,a0,1868 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0203084:	c0afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203088:	00004697          	auipc	a3,0x4
ffffffffc020308c:	ab068693          	addi	a3,a3,-1360 # ffffffffc0206b38 <default_pmm_manager+0x4c0>
ffffffffc0203090:	00003617          	auipc	a2,0x3
ffffffffc0203094:	23860613          	addi	a2,a2,568 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203098:	23900593          	li	a1,569
ffffffffc020309c:	00003517          	auipc	a0,0x3
ffffffffc02030a0:	72c50513          	addi	a0,a0,1836 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc02030a4:	beafd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02030a8:	00004697          	auipc	a3,0x4
ffffffffc02030ac:	93068693          	addi	a3,a3,-1744 # ffffffffc02069d8 <default_pmm_manager+0x360>
ffffffffc02030b0:	00003617          	auipc	a2,0x3
ffffffffc02030b4:	21860613          	addi	a2,a2,536 # ffffffffc02062c8 <commands+0x890>
ffffffffc02030b8:	23800593          	li	a1,568
ffffffffc02030bc:	00003517          	auipc	a0,0x3
ffffffffc02030c0:	70c50513          	addi	a0,a0,1804 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc02030c4:	bcafd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02030c8:	00004697          	auipc	a3,0x4
ffffffffc02030cc:	a8868693          	addi	a3,a3,-1400 # ffffffffc0206b50 <default_pmm_manager+0x4d8>
ffffffffc02030d0:	00003617          	auipc	a2,0x3
ffffffffc02030d4:	1f860613          	addi	a2,a2,504 # ffffffffc02062c8 <commands+0x890>
ffffffffc02030d8:	23500593          	li	a1,565
ffffffffc02030dc:	00003517          	auipc	a0,0x3
ffffffffc02030e0:	6ec50513          	addi	a0,a0,1772 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc02030e4:	baafd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02030e8:	00004697          	auipc	a3,0x4
ffffffffc02030ec:	8d868693          	addi	a3,a3,-1832 # ffffffffc02069c0 <default_pmm_manager+0x348>
ffffffffc02030f0:	00003617          	auipc	a2,0x3
ffffffffc02030f4:	1d860613          	addi	a2,a2,472 # ffffffffc02062c8 <commands+0x890>
ffffffffc02030f8:	23400593          	li	a1,564
ffffffffc02030fc:	00003517          	auipc	a0,0x3
ffffffffc0203100:	6cc50513          	addi	a0,a0,1740 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0203104:	b8afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0203108:	00004697          	auipc	a3,0x4
ffffffffc020310c:	95868693          	addi	a3,a3,-1704 # ffffffffc0206a60 <default_pmm_manager+0x3e8>
ffffffffc0203110:	00003617          	auipc	a2,0x3
ffffffffc0203114:	1b860613          	addi	a2,a2,440 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203118:	23300593          	li	a1,563
ffffffffc020311c:	00003517          	auipc	a0,0x3
ffffffffc0203120:	6ac50513          	addi	a0,a0,1708 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0203124:	b6afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203128:	00004697          	auipc	a3,0x4
ffffffffc020312c:	a1068693          	addi	a3,a3,-1520 # ffffffffc0206b38 <default_pmm_manager+0x4c0>
ffffffffc0203130:	00003617          	auipc	a2,0x3
ffffffffc0203134:	19860613          	addi	a2,a2,408 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203138:	23200593          	li	a1,562
ffffffffc020313c:	00003517          	auipc	a0,0x3
ffffffffc0203140:	68c50513          	addi	a0,a0,1676 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0203144:	b4afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0203148:	00004697          	auipc	a3,0x4
ffffffffc020314c:	9d868693          	addi	a3,a3,-1576 # ffffffffc0206b20 <default_pmm_manager+0x4a8>
ffffffffc0203150:	00003617          	auipc	a2,0x3
ffffffffc0203154:	17860613          	addi	a2,a2,376 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203158:	23100593          	li	a1,561
ffffffffc020315c:	00003517          	auipc	a0,0x3
ffffffffc0203160:	66c50513          	addi	a0,a0,1644 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0203164:	b2afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0203168:	00004697          	auipc	a3,0x4
ffffffffc020316c:	98868693          	addi	a3,a3,-1656 # ffffffffc0206af0 <default_pmm_manager+0x478>
ffffffffc0203170:	00003617          	auipc	a2,0x3
ffffffffc0203174:	15860613          	addi	a2,a2,344 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203178:	23000593          	li	a1,560
ffffffffc020317c:	00003517          	auipc	a0,0x3
ffffffffc0203180:	64c50513          	addi	a0,a0,1612 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0203184:	b0afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203188:	00004697          	auipc	a3,0x4
ffffffffc020318c:	95068693          	addi	a3,a3,-1712 # ffffffffc0206ad8 <default_pmm_manager+0x460>
ffffffffc0203190:	00003617          	auipc	a2,0x3
ffffffffc0203194:	13860613          	addi	a2,a2,312 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203198:	22e00593          	li	a1,558
ffffffffc020319c:	00003517          	auipc	a0,0x3
ffffffffc02031a0:	62c50513          	addi	a0,a0,1580 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc02031a4:	aeafd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc02031a8:	00004697          	auipc	a3,0x4
ffffffffc02031ac:	91068693          	addi	a3,a3,-1776 # ffffffffc0206ab8 <default_pmm_manager+0x440>
ffffffffc02031b0:	00003617          	auipc	a2,0x3
ffffffffc02031b4:	11860613          	addi	a2,a2,280 # ffffffffc02062c8 <commands+0x890>
ffffffffc02031b8:	22d00593          	li	a1,557
ffffffffc02031bc:	00003517          	auipc	a0,0x3
ffffffffc02031c0:	60c50513          	addi	a0,a0,1548 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc02031c4:	acafd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(*ptep & PTE_W);
ffffffffc02031c8:	00004697          	auipc	a3,0x4
ffffffffc02031cc:	8e068693          	addi	a3,a3,-1824 # ffffffffc0206aa8 <default_pmm_manager+0x430>
ffffffffc02031d0:	00003617          	auipc	a2,0x3
ffffffffc02031d4:	0f860613          	addi	a2,a2,248 # ffffffffc02062c8 <commands+0x890>
ffffffffc02031d8:	22c00593          	li	a1,556
ffffffffc02031dc:	00003517          	auipc	a0,0x3
ffffffffc02031e0:	5ec50513          	addi	a0,a0,1516 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc02031e4:	aaafd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(*ptep & PTE_U);
ffffffffc02031e8:	00004697          	auipc	a3,0x4
ffffffffc02031ec:	8b068693          	addi	a3,a3,-1872 # ffffffffc0206a98 <default_pmm_manager+0x420>
ffffffffc02031f0:	00003617          	auipc	a2,0x3
ffffffffc02031f4:	0d860613          	addi	a2,a2,216 # ffffffffc02062c8 <commands+0x890>
ffffffffc02031f8:	22b00593          	li	a1,555
ffffffffc02031fc:	00003517          	auipc	a0,0x3
ffffffffc0203200:	5cc50513          	addi	a0,a0,1484 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0203204:	a8afd0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("DTB memory info not available");
ffffffffc0203208:	00003617          	auipc	a2,0x3
ffffffffc020320c:	63060613          	addi	a2,a2,1584 # ffffffffc0206838 <default_pmm_manager+0x1c0>
ffffffffc0203210:	06500593          	li	a1,101
ffffffffc0203214:	00003517          	auipc	a0,0x3
ffffffffc0203218:	5b450513          	addi	a0,a0,1460 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc020321c:	a72fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0203220:	00004697          	auipc	a3,0x4
ffffffffc0203224:	99068693          	addi	a3,a3,-1648 # ffffffffc0206bb0 <default_pmm_manager+0x538>
ffffffffc0203228:	00003617          	auipc	a2,0x3
ffffffffc020322c:	0a060613          	addi	a2,a2,160 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203230:	27100593          	li	a1,625
ffffffffc0203234:	00003517          	auipc	a0,0x3
ffffffffc0203238:	59450513          	addi	a0,a0,1428 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc020323c:	a52fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0203240:	00004697          	auipc	a3,0x4
ffffffffc0203244:	82068693          	addi	a3,a3,-2016 # ffffffffc0206a60 <default_pmm_manager+0x3e8>
ffffffffc0203248:	00003617          	auipc	a2,0x3
ffffffffc020324c:	08060613          	addi	a2,a2,128 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203250:	22a00593          	li	a1,554
ffffffffc0203254:	00003517          	auipc	a0,0x3
ffffffffc0203258:	57450513          	addi	a0,a0,1396 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc020325c:	a32fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203260:	00003697          	auipc	a3,0x3
ffffffffc0203264:	7c068693          	addi	a3,a3,1984 # ffffffffc0206a20 <default_pmm_manager+0x3a8>
ffffffffc0203268:	00003617          	auipc	a2,0x3
ffffffffc020326c:	06060613          	addi	a2,a2,96 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203270:	22900593          	li	a1,553
ffffffffc0203274:	00003517          	auipc	a0,0x3
ffffffffc0203278:	55450513          	addi	a0,a0,1364 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc020327c:	a12fd0ef          	jal	ra,ffffffffc020048e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203280:	86d6                	mv	a3,s5
ffffffffc0203282:	00003617          	auipc	a2,0x3
ffffffffc0203286:	42e60613          	addi	a2,a2,1070 # ffffffffc02066b0 <default_pmm_manager+0x38>
ffffffffc020328a:	22500593          	li	a1,549
ffffffffc020328e:	00003517          	auipc	a0,0x3
ffffffffc0203292:	53a50513          	addi	a0,a0,1338 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0203296:	9f8fd0ef          	jal	ra,ffffffffc020048e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc020329a:	00003617          	auipc	a2,0x3
ffffffffc020329e:	41660613          	addi	a2,a2,1046 # ffffffffc02066b0 <default_pmm_manager+0x38>
ffffffffc02032a2:	22400593          	li	a1,548
ffffffffc02032a6:	00003517          	auipc	a0,0x3
ffffffffc02032aa:	52250513          	addi	a0,a0,1314 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc02032ae:	9e0fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02032b2:	00003697          	auipc	a3,0x3
ffffffffc02032b6:	72668693          	addi	a3,a3,1830 # ffffffffc02069d8 <default_pmm_manager+0x360>
ffffffffc02032ba:	00003617          	auipc	a2,0x3
ffffffffc02032be:	00e60613          	addi	a2,a2,14 # ffffffffc02062c8 <commands+0x890>
ffffffffc02032c2:	22200593          	li	a1,546
ffffffffc02032c6:	00003517          	auipc	a0,0x3
ffffffffc02032ca:	50250513          	addi	a0,a0,1282 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc02032ce:	9c0fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02032d2:	00003697          	auipc	a3,0x3
ffffffffc02032d6:	6ee68693          	addi	a3,a3,1774 # ffffffffc02069c0 <default_pmm_manager+0x348>
ffffffffc02032da:	00003617          	auipc	a2,0x3
ffffffffc02032de:	fee60613          	addi	a2,a2,-18 # ffffffffc02062c8 <commands+0x890>
ffffffffc02032e2:	22100593          	li	a1,545
ffffffffc02032e6:	00003517          	auipc	a0,0x3
ffffffffc02032ea:	4e250513          	addi	a0,a0,1250 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc02032ee:	9a0fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02032f2:	00004697          	auipc	a3,0x4
ffffffffc02032f6:	a7e68693          	addi	a3,a3,-1410 # ffffffffc0206d70 <default_pmm_manager+0x6f8>
ffffffffc02032fa:	00003617          	auipc	a2,0x3
ffffffffc02032fe:	fce60613          	addi	a2,a2,-50 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203302:	26800593          	li	a1,616
ffffffffc0203306:	00003517          	auipc	a0,0x3
ffffffffc020330a:	4c250513          	addi	a0,a0,1218 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc020330e:	980fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203312:	00004697          	auipc	a3,0x4
ffffffffc0203316:	a2668693          	addi	a3,a3,-1498 # ffffffffc0206d38 <default_pmm_manager+0x6c0>
ffffffffc020331a:	00003617          	auipc	a2,0x3
ffffffffc020331e:	fae60613          	addi	a2,a2,-82 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203322:	26500593          	li	a1,613
ffffffffc0203326:	00003517          	auipc	a0,0x3
ffffffffc020332a:	4a250513          	addi	a0,a0,1186 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc020332e:	960fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203332:	00004697          	auipc	a3,0x4
ffffffffc0203336:	9d668693          	addi	a3,a3,-1578 # ffffffffc0206d08 <default_pmm_manager+0x690>
ffffffffc020333a:	00003617          	auipc	a2,0x3
ffffffffc020333e:	f8e60613          	addi	a2,a2,-114 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203342:	26100593          	li	a1,609
ffffffffc0203346:	00003517          	auipc	a0,0x3
ffffffffc020334a:	48250513          	addi	a0,a0,1154 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc020334e:	940fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203352:	00004697          	auipc	a3,0x4
ffffffffc0203356:	96e68693          	addi	a3,a3,-1682 # ffffffffc0206cc0 <default_pmm_manager+0x648>
ffffffffc020335a:	00003617          	auipc	a2,0x3
ffffffffc020335e:	f6e60613          	addi	a2,a2,-146 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203362:	26000593          	li	a1,608
ffffffffc0203366:	00003517          	auipc	a0,0x3
ffffffffc020336a:	46250513          	addi	a0,a0,1122 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc020336e:	920fd0ef          	jal	ra,ffffffffc020048e <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0203372:	00003617          	auipc	a2,0x3
ffffffffc0203376:	3e660613          	addi	a2,a2,998 # ffffffffc0206758 <default_pmm_manager+0xe0>
ffffffffc020337a:	0c900593          	li	a1,201
ffffffffc020337e:	00003517          	auipc	a0,0x3
ffffffffc0203382:	44a50513          	addi	a0,a0,1098 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0203386:	908fd0ef          	jal	ra,ffffffffc020048e <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020338a:	00003617          	auipc	a2,0x3
ffffffffc020338e:	3ce60613          	addi	a2,a2,974 # ffffffffc0206758 <default_pmm_manager+0xe0>
ffffffffc0203392:	08100593          	li	a1,129
ffffffffc0203396:	00003517          	auipc	a0,0x3
ffffffffc020339a:	43250513          	addi	a0,a0,1074 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc020339e:	8f0fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc02033a2:	00003697          	auipc	a3,0x3
ffffffffc02033a6:	5ee68693          	addi	a3,a3,1518 # ffffffffc0206990 <default_pmm_manager+0x318>
ffffffffc02033aa:	00003617          	auipc	a2,0x3
ffffffffc02033ae:	f1e60613          	addi	a2,a2,-226 # ffffffffc02062c8 <commands+0x890>
ffffffffc02033b2:	22000593          	li	a1,544
ffffffffc02033b6:	00003517          	auipc	a0,0x3
ffffffffc02033ba:	41250513          	addi	a0,a0,1042 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc02033be:	8d0fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc02033c2:	00003697          	auipc	a3,0x3
ffffffffc02033c6:	59e68693          	addi	a3,a3,1438 # ffffffffc0206960 <default_pmm_manager+0x2e8>
ffffffffc02033ca:	00003617          	auipc	a2,0x3
ffffffffc02033ce:	efe60613          	addi	a2,a2,-258 # ffffffffc02062c8 <commands+0x890>
ffffffffc02033d2:	21d00593          	li	a1,541
ffffffffc02033d6:	00003517          	auipc	a0,0x3
ffffffffc02033da:	3f250513          	addi	a0,a0,1010 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc02033de:	8b0fd0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02033e2 <copy_range>:
{
ffffffffc02033e2:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02033e4:	00d667b3          	or	a5,a2,a3
{
ffffffffc02033e8:	f486                	sd	ra,104(sp)
ffffffffc02033ea:	f0a2                	sd	s0,96(sp)
ffffffffc02033ec:	eca6                	sd	s1,88(sp)
ffffffffc02033ee:	e8ca                	sd	s2,80(sp)
ffffffffc02033f0:	e4ce                	sd	s3,72(sp)
ffffffffc02033f2:	e0d2                	sd	s4,64(sp)
ffffffffc02033f4:	fc56                	sd	s5,56(sp)
ffffffffc02033f6:	f85a                	sd	s6,48(sp)
ffffffffc02033f8:	f45e                	sd	s7,40(sp)
ffffffffc02033fa:	f062                	sd	s8,32(sp)
ffffffffc02033fc:	ec66                	sd	s9,24(sp)
ffffffffc02033fe:	e86a                	sd	s10,16(sp)
ffffffffc0203400:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203402:	17d2                	slli	a5,a5,0x34
ffffffffc0203404:	22079f63          	bnez	a5,ffffffffc0203642 <copy_range+0x260>
    assert(USER_ACCESS(start, end));
ffffffffc0203408:	002007b7          	lui	a5,0x200
ffffffffc020340c:	8432                	mv	s0,a2
ffffffffc020340e:	1cf66263          	bltu	a2,a5,ffffffffc02035d2 <copy_range+0x1f0>
ffffffffc0203412:	8936                	mv	s2,a3
ffffffffc0203414:	1ad67f63          	bgeu	a2,a3,ffffffffc02035d2 <copy_range+0x1f0>
ffffffffc0203418:	4785                	li	a5,1
ffffffffc020341a:	07fe                	slli	a5,a5,0x1f
ffffffffc020341c:	1ad7eb63          	bltu	a5,a3,ffffffffc02035d2 <copy_range+0x1f0>
ffffffffc0203420:	5b7d                	li	s6,-1
ffffffffc0203422:	8aaa                	mv	s5,a0
ffffffffc0203424:	89ae                	mv	s3,a1
        start += PGSIZE;
ffffffffc0203426:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage)
ffffffffc0203428:	000a7c17          	auipc	s8,0xa7
ffffffffc020342c:	298c0c13          	addi	s8,s8,664 # ffffffffc02aa6c0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203430:	000a7b97          	auipc	s7,0xa7
ffffffffc0203434:	298b8b93          	addi	s7,s7,664 # ffffffffc02aa6c8 <pages>
    return KADDR(page2pa(page));
ffffffffc0203438:	00cb5b13          	srli	s6,s6,0xc
        page = pmm_manager->alloc_pages(n);
ffffffffc020343c:	000a7c97          	auipc	s9,0xa7
ffffffffc0203440:	294c8c93          	addi	s9,s9,660 # ffffffffc02aa6d0 <pmm_manager>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0203444:	4601                	li	a2,0
ffffffffc0203446:	85a2                	mv	a1,s0
ffffffffc0203448:	854e                	mv	a0,s3
ffffffffc020344a:	b73fe0ef          	jal	ra,ffffffffc0201fbc <get_pte>
ffffffffc020344e:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc0203450:	10050163          	beqz	a0,ffffffffc0203552 <copy_range+0x170>
        if (*ptep & PTE_V)
ffffffffc0203454:	611c                	ld	a5,0(a0)
ffffffffc0203456:	8b85                	andi	a5,a5,1
ffffffffc0203458:	e78d                	bnez	a5,ffffffffc0203482 <copy_range+0xa0>
        start += PGSIZE;
ffffffffc020345a:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc020345c:	ff2464e3          	bltu	s0,s2,ffffffffc0203444 <copy_range+0x62>
    return 0;
ffffffffc0203460:	4481                	li	s1,0
}
ffffffffc0203462:	70a6                	ld	ra,104(sp)
ffffffffc0203464:	7406                	ld	s0,96(sp)
ffffffffc0203466:	6946                	ld	s2,80(sp)
ffffffffc0203468:	69a6                	ld	s3,72(sp)
ffffffffc020346a:	6a06                	ld	s4,64(sp)
ffffffffc020346c:	7ae2                	ld	s5,56(sp)
ffffffffc020346e:	7b42                	ld	s6,48(sp)
ffffffffc0203470:	7ba2                	ld	s7,40(sp)
ffffffffc0203472:	7c02                	ld	s8,32(sp)
ffffffffc0203474:	6ce2                	ld	s9,24(sp)
ffffffffc0203476:	6d42                	ld	s10,16(sp)
ffffffffc0203478:	6da2                	ld	s11,8(sp)
ffffffffc020347a:	8526                	mv	a0,s1
ffffffffc020347c:	64e6                	ld	s1,88(sp)
ffffffffc020347e:	6165                	addi	sp,sp,112
ffffffffc0203480:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc0203482:	4605                	li	a2,1
ffffffffc0203484:	85a2                	mv	a1,s0
ffffffffc0203486:	8556                	mv	a0,s5
ffffffffc0203488:	b35fe0ef          	jal	ra,ffffffffc0201fbc <get_pte>
ffffffffc020348c:	0e050963          	beqz	a0,ffffffffc020357e <copy_range+0x19c>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0203490:	609c                	ld	a5,0(s1)
    if (!(pte & PTE_V))
ffffffffc0203492:	0017f713          	andi	a4,a5,1
ffffffffc0203496:	01f7f493          	andi	s1,a5,31
ffffffffc020349a:	18070863          	beqz	a4,ffffffffc020362a <copy_range+0x248>
    if (PPN(pa) >= npage)
ffffffffc020349e:	000c3683          	ld	a3,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc02034a2:	078a                	slli	a5,a5,0x2
ffffffffc02034a4:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02034a8:	16d77563          	bgeu	a4,a3,ffffffffc0203612 <copy_range+0x230>
    return &pages[PPN(pa) - nbase];
ffffffffc02034ac:	000bb783          	ld	a5,0(s7)
ffffffffc02034b0:	fff806b7          	lui	a3,0xfff80
ffffffffc02034b4:	9736                	add	a4,a4,a3
ffffffffc02034b6:	071a                	slli	a4,a4,0x6
ffffffffc02034b8:	00e78db3          	add	s11,a5,a4
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02034bc:	10002773          	csrr	a4,sstatus
ffffffffc02034c0:	8b09                	andi	a4,a4,2
ffffffffc02034c2:	e35d                	bnez	a4,ffffffffc0203568 <copy_range+0x186>
        page = pmm_manager->alloc_pages(n);
ffffffffc02034c4:	000cb703          	ld	a4,0(s9)
ffffffffc02034c8:	4505                	li	a0,1
ffffffffc02034ca:	6f18                	ld	a4,24(a4)
ffffffffc02034cc:	9702                	jalr	a4
ffffffffc02034ce:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc02034d0:	0e0d8163          	beqz	s11,ffffffffc02035b2 <copy_range+0x1d0>
            assert(npage != NULL);
ffffffffc02034d4:	100d0f63          	beqz	s10,ffffffffc02035f2 <copy_range+0x210>
    return page - pages + nbase;
ffffffffc02034d8:	000bb703          	ld	a4,0(s7)
ffffffffc02034dc:	000805b7          	lui	a1,0x80
    return KADDR(page2pa(page));
ffffffffc02034e0:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc02034e4:	40ed86b3          	sub	a3,s11,a4
ffffffffc02034e8:	8699                	srai	a3,a3,0x6
ffffffffc02034ea:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc02034ec:	0166f7b3          	and	a5,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02034f0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02034f2:	0ac7f463          	bgeu	a5,a2,ffffffffc020359a <copy_range+0x1b8>
    return page - pages + nbase;
ffffffffc02034f6:	40ed07b3          	sub	a5,s10,a4
    return KADDR(page2pa(page));
ffffffffc02034fa:	000a7717          	auipc	a4,0xa7
ffffffffc02034fe:	1de70713          	addi	a4,a4,478 # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc0203502:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc0203504:	8799                	srai	a5,a5,0x6
ffffffffc0203506:	97ae                	add	a5,a5,a1
    return KADDR(page2pa(page));
ffffffffc0203508:	0167f733          	and	a4,a5,s6
ffffffffc020350c:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203510:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0203512:	08c77363          	bgeu	a4,a2,ffffffffc0203598 <copy_range+0x1b6>
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ffffffffc0203516:	6605                	lui	a2,0x1
ffffffffc0203518:	953e                	add	a0,a0,a5
ffffffffc020351a:	29e020ef          	jal	ra,ffffffffc02057b8 <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc020351e:	86a6                	mv	a3,s1
ffffffffc0203520:	8622                	mv	a2,s0
ffffffffc0203522:	85ea                	mv	a1,s10
ffffffffc0203524:	8556                	mv	a0,s5
ffffffffc0203526:	986ff0ef          	jal	ra,ffffffffc02026ac <page_insert>
ffffffffc020352a:	84aa                	mv	s1,a0
            if (ret != 0) {
ffffffffc020352c:	d51d                	beqz	a0,ffffffffc020345a <copy_range+0x78>
                cprintf("copy_range: page_insert failed at 0x%x\n", start);
ffffffffc020352e:	85a2                	mv	a1,s0
ffffffffc0203530:	00004517          	auipc	a0,0x4
ffffffffc0203534:	8a850513          	addi	a0,a0,-1880 # ffffffffc0206dd8 <default_pmm_manager+0x760>
ffffffffc0203538:	c5dfc0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc020353c:	100027f3          	csrr	a5,sstatus
ffffffffc0203540:	8b89                	andi	a5,a5,2
ffffffffc0203542:	e3a1                	bnez	a5,ffffffffc0203582 <copy_range+0x1a0>
        pmm_manager->free_pages(base, n);
ffffffffc0203544:	000cb783          	ld	a5,0(s9)
ffffffffc0203548:	4585                	li	a1,1
ffffffffc020354a:	856a                	mv	a0,s10
ffffffffc020354c:	739c                	ld	a5,32(a5)
ffffffffc020354e:	9782                	jalr	a5
    if (flag)
ffffffffc0203550:	bf09                	j	ffffffffc0203462 <copy_range+0x80>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203552:	00200637          	lui	a2,0x200
ffffffffc0203556:	9432                	add	s0,s0,a2
ffffffffc0203558:	ffe00637          	lui	a2,0xffe00
ffffffffc020355c:	8c71                	and	s0,s0,a2
    } while (start != 0 && start < end);
ffffffffc020355e:	f00401e3          	beqz	s0,ffffffffc0203460 <copy_range+0x7e>
ffffffffc0203562:	ef2461e3          	bltu	s0,s2,ffffffffc0203444 <copy_range+0x62>
ffffffffc0203566:	bded                	j	ffffffffc0203460 <copy_range+0x7e>
        intr_disable();
ffffffffc0203568:	c4cfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020356c:	000cb703          	ld	a4,0(s9)
ffffffffc0203570:	4505                	li	a0,1
ffffffffc0203572:	6f18                	ld	a4,24(a4)
ffffffffc0203574:	9702                	jalr	a4
ffffffffc0203576:	8d2a                	mv	s10,a0
        intr_enable();
ffffffffc0203578:	c36fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020357c:	bf91                	j	ffffffffc02034d0 <copy_range+0xee>
                return -E_NO_MEM;
ffffffffc020357e:	54f1                	li	s1,-4
ffffffffc0203580:	b5cd                	j	ffffffffc0203462 <copy_range+0x80>
        intr_disable();
ffffffffc0203582:	c32fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203586:	000cb783          	ld	a5,0(s9)
ffffffffc020358a:	4585                	li	a1,1
ffffffffc020358c:	856a                	mv	a0,s10
ffffffffc020358e:	739c                	ld	a5,32(a5)
ffffffffc0203590:	9782                	jalr	a5
        intr_enable();
ffffffffc0203592:	c1cfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0203596:	b5f1                	j	ffffffffc0203462 <copy_range+0x80>
ffffffffc0203598:	86be                	mv	a3,a5
ffffffffc020359a:	00003617          	auipc	a2,0x3
ffffffffc020359e:	11660613          	addi	a2,a2,278 # ffffffffc02066b0 <default_pmm_manager+0x38>
ffffffffc02035a2:	07100593          	li	a1,113
ffffffffc02035a6:	00003517          	auipc	a0,0x3
ffffffffc02035aa:	13250513          	addi	a0,a0,306 # ffffffffc02066d8 <default_pmm_manager+0x60>
ffffffffc02035ae:	ee1fc0ef          	jal	ra,ffffffffc020048e <__panic>
            assert(page != NULL);
ffffffffc02035b2:	00004697          	auipc	a3,0x4
ffffffffc02035b6:	80668693          	addi	a3,a3,-2042 # ffffffffc0206db8 <default_pmm_manager+0x740>
ffffffffc02035ba:	00003617          	auipc	a2,0x3
ffffffffc02035be:	d0e60613          	addi	a2,a2,-754 # ffffffffc02062c8 <commands+0x890>
ffffffffc02035c2:	19400593          	li	a1,404
ffffffffc02035c6:	00003517          	auipc	a0,0x3
ffffffffc02035ca:	20250513          	addi	a0,a0,514 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc02035ce:	ec1fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02035d2:	00003697          	auipc	a3,0x3
ffffffffc02035d6:	23668693          	addi	a3,a3,566 # ffffffffc0206808 <default_pmm_manager+0x190>
ffffffffc02035da:	00003617          	auipc	a2,0x3
ffffffffc02035de:	cee60613          	addi	a2,a2,-786 # ffffffffc02062c8 <commands+0x890>
ffffffffc02035e2:	17c00593          	li	a1,380
ffffffffc02035e6:	00003517          	auipc	a0,0x3
ffffffffc02035ea:	1e250513          	addi	a0,a0,482 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc02035ee:	ea1fc0ef          	jal	ra,ffffffffc020048e <__panic>
            assert(npage != NULL);
ffffffffc02035f2:	00003697          	auipc	a3,0x3
ffffffffc02035f6:	7d668693          	addi	a3,a3,2006 # ffffffffc0206dc8 <default_pmm_manager+0x750>
ffffffffc02035fa:	00003617          	auipc	a2,0x3
ffffffffc02035fe:	cce60613          	addi	a2,a2,-818 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203602:	19500593          	li	a1,405
ffffffffc0203606:	00003517          	auipc	a0,0x3
ffffffffc020360a:	1c250513          	addi	a0,a0,450 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc020360e:	e81fc0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203612:	00003617          	auipc	a2,0x3
ffffffffc0203616:	16e60613          	addi	a2,a2,366 # ffffffffc0206780 <default_pmm_manager+0x108>
ffffffffc020361a:	06900593          	li	a1,105
ffffffffc020361e:	00003517          	auipc	a0,0x3
ffffffffc0203622:	0ba50513          	addi	a0,a0,186 # ffffffffc02066d8 <default_pmm_manager+0x60>
ffffffffc0203626:	e69fc0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020362a:	00003617          	auipc	a2,0x3
ffffffffc020362e:	17660613          	addi	a2,a2,374 # ffffffffc02067a0 <default_pmm_manager+0x128>
ffffffffc0203632:	07f00593          	li	a1,127
ffffffffc0203636:	00003517          	auipc	a0,0x3
ffffffffc020363a:	0a250513          	addi	a0,a0,162 # ffffffffc02066d8 <default_pmm_manager+0x60>
ffffffffc020363e:	e51fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203642:	00003697          	auipc	a3,0x3
ffffffffc0203646:	19668693          	addi	a3,a3,406 # ffffffffc02067d8 <default_pmm_manager+0x160>
ffffffffc020364a:	00003617          	auipc	a2,0x3
ffffffffc020364e:	c7e60613          	addi	a2,a2,-898 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203652:	17b00593          	li	a1,379
ffffffffc0203656:	00003517          	auipc	a0,0x3
ffffffffc020365a:	17250513          	addi	a0,a0,370 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc020365e:	e31fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203662 <pgdir_alloc_page>:
{
ffffffffc0203662:	7179                	addi	sp,sp,-48
ffffffffc0203664:	ec26                	sd	s1,24(sp)
ffffffffc0203666:	e84a                	sd	s2,16(sp)
ffffffffc0203668:	e052                	sd	s4,0(sp)
ffffffffc020366a:	f406                	sd	ra,40(sp)
ffffffffc020366c:	f022                	sd	s0,32(sp)
ffffffffc020366e:	e44e                	sd	s3,8(sp)
ffffffffc0203670:	8a2a                	mv	s4,a0
ffffffffc0203672:	84ae                	mv	s1,a1
ffffffffc0203674:	8932                	mv	s2,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203676:	100027f3          	csrr	a5,sstatus
ffffffffc020367a:	8b89                	andi	a5,a5,2
        page = pmm_manager->alloc_pages(n);
ffffffffc020367c:	000a7997          	auipc	s3,0xa7
ffffffffc0203680:	05498993          	addi	s3,s3,84 # ffffffffc02aa6d0 <pmm_manager>
ffffffffc0203684:	ef8d                	bnez	a5,ffffffffc02036be <pgdir_alloc_page+0x5c>
ffffffffc0203686:	0009b783          	ld	a5,0(s3)
ffffffffc020368a:	4505                	li	a0,1
ffffffffc020368c:	6f9c                	ld	a5,24(a5)
ffffffffc020368e:	9782                	jalr	a5
ffffffffc0203690:	842a                	mv	s0,a0
    if (page != NULL)
ffffffffc0203692:	cc09                	beqz	s0,ffffffffc02036ac <pgdir_alloc_page+0x4a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc0203694:	86ca                	mv	a3,s2
ffffffffc0203696:	8626                	mv	a2,s1
ffffffffc0203698:	85a2                	mv	a1,s0
ffffffffc020369a:	8552                	mv	a0,s4
ffffffffc020369c:	810ff0ef          	jal	ra,ffffffffc02026ac <page_insert>
ffffffffc02036a0:	e915                	bnez	a0,ffffffffc02036d4 <pgdir_alloc_page+0x72>
        assert(page_ref(page) == 1);
ffffffffc02036a2:	4018                	lw	a4,0(s0)
        page->pra_vaddr = la;
ffffffffc02036a4:	fc04                	sd	s1,56(s0)
        assert(page_ref(page) == 1);
ffffffffc02036a6:	4785                	li	a5,1
ffffffffc02036a8:	04f71e63          	bne	a4,a5,ffffffffc0203704 <pgdir_alloc_page+0xa2>
}
ffffffffc02036ac:	70a2                	ld	ra,40(sp)
ffffffffc02036ae:	8522                	mv	a0,s0
ffffffffc02036b0:	7402                	ld	s0,32(sp)
ffffffffc02036b2:	64e2                	ld	s1,24(sp)
ffffffffc02036b4:	6942                	ld	s2,16(sp)
ffffffffc02036b6:	69a2                	ld	s3,8(sp)
ffffffffc02036b8:	6a02                	ld	s4,0(sp)
ffffffffc02036ba:	6145                	addi	sp,sp,48
ffffffffc02036bc:	8082                	ret
        intr_disable();
ffffffffc02036be:	af6fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02036c2:	0009b783          	ld	a5,0(s3)
ffffffffc02036c6:	4505                	li	a0,1
ffffffffc02036c8:	6f9c                	ld	a5,24(a5)
ffffffffc02036ca:	9782                	jalr	a5
ffffffffc02036cc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02036ce:	ae0fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02036d2:	b7c1                	j	ffffffffc0203692 <pgdir_alloc_page+0x30>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02036d4:	100027f3          	csrr	a5,sstatus
ffffffffc02036d8:	8b89                	andi	a5,a5,2
ffffffffc02036da:	eb89                	bnez	a5,ffffffffc02036ec <pgdir_alloc_page+0x8a>
        pmm_manager->free_pages(base, n);
ffffffffc02036dc:	0009b783          	ld	a5,0(s3)
ffffffffc02036e0:	8522                	mv	a0,s0
ffffffffc02036e2:	4585                	li	a1,1
ffffffffc02036e4:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc02036e6:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc02036e8:	9782                	jalr	a5
    if (flag)
ffffffffc02036ea:	b7c9                	j	ffffffffc02036ac <pgdir_alloc_page+0x4a>
        intr_disable();
ffffffffc02036ec:	ac8fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc02036f0:	0009b783          	ld	a5,0(s3)
ffffffffc02036f4:	8522                	mv	a0,s0
ffffffffc02036f6:	4585                	li	a1,1
ffffffffc02036f8:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc02036fa:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc02036fc:	9782                	jalr	a5
        intr_enable();
ffffffffc02036fe:	ab0fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0203702:	b76d                	j	ffffffffc02036ac <pgdir_alloc_page+0x4a>
        assert(page_ref(page) == 1);
ffffffffc0203704:	00003697          	auipc	a3,0x3
ffffffffc0203708:	6fc68693          	addi	a3,a3,1788 # ffffffffc0206e00 <default_pmm_manager+0x788>
ffffffffc020370c:	00003617          	auipc	a2,0x3
ffffffffc0203710:	bbc60613          	addi	a2,a2,-1092 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203714:	1fe00593          	li	a1,510
ffffffffc0203718:	00003517          	auipc	a0,0x3
ffffffffc020371c:	0b050513          	addi	a0,a0,176 # ffffffffc02067c8 <default_pmm_manager+0x150>
ffffffffc0203720:	d6ffc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203724 <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0203724:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203726:	00003697          	auipc	a3,0x3
ffffffffc020372a:	6f268693          	addi	a3,a3,1778 # ffffffffc0206e18 <default_pmm_manager+0x7a0>
ffffffffc020372e:	00003617          	auipc	a2,0x3
ffffffffc0203732:	b9a60613          	addi	a2,a2,-1126 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203736:	07400593          	li	a1,116
ffffffffc020373a:	00003517          	auipc	a0,0x3
ffffffffc020373e:	6fe50513          	addi	a0,a0,1790 # ffffffffc0206e38 <default_pmm_manager+0x7c0>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0203742:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0203744:	d4bfc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203748 <mm_create>:
{
ffffffffc0203748:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020374a:	04000513          	li	a0,64
{
ffffffffc020374e:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203750:	dd6fe0ef          	jal	ra,ffffffffc0201d26 <kmalloc>
    if (mm != NULL)
ffffffffc0203754:	cd19                	beqz	a0,ffffffffc0203772 <mm_create+0x2a>
    elm->prev = elm->next = elm;
ffffffffc0203756:	e508                	sd	a0,8(a0)
ffffffffc0203758:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc020375a:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020375e:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203762:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0203766:	02053423          	sd	zero,40(a0)
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc020376a:	02052823          	sw	zero,48(a0)
typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
ffffffffc020376e:	02053c23          	sd	zero,56(a0)
}
ffffffffc0203772:	60a2                	ld	ra,8(sp)
ffffffffc0203774:	0141                	addi	sp,sp,16
ffffffffc0203776:	8082                	ret

ffffffffc0203778 <find_vma>:
{
ffffffffc0203778:	86aa                	mv	a3,a0
    if (mm != NULL)
ffffffffc020377a:	c505                	beqz	a0,ffffffffc02037a2 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc020377c:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc020377e:	c501                	beqz	a0,ffffffffc0203786 <find_vma+0xe>
ffffffffc0203780:	651c                	ld	a5,8(a0)
ffffffffc0203782:	02f5f263          	bgeu	a1,a5,ffffffffc02037a6 <find_vma+0x2e>
    return listelm->next;
ffffffffc0203786:	669c                	ld	a5,8(a3)
            while ((le = list_next(le)) != list)
ffffffffc0203788:	00f68d63          	beq	a3,a5,ffffffffc02037a2 <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc020378c:	fe87b703          	ld	a4,-24(a5) # 1fffe8 <_binary_obj___user_exit_out_size+0x1f4ed0>
ffffffffc0203790:	00e5e663          	bltu	a1,a4,ffffffffc020379c <find_vma+0x24>
ffffffffc0203794:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203798:	00e5ec63          	bltu	a1,a4,ffffffffc02037b0 <find_vma+0x38>
ffffffffc020379c:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc020379e:	fef697e3          	bne	a3,a5,ffffffffc020378c <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc02037a2:	4501                	li	a0,0
}
ffffffffc02037a4:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc02037a6:	691c                	ld	a5,16(a0)
ffffffffc02037a8:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0203786 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc02037ac:	ea88                	sd	a0,16(a3)
ffffffffc02037ae:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc02037b0:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc02037b4:	ea88                	sd	a0,16(a3)
ffffffffc02037b6:	8082                	ret

ffffffffc02037b8 <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc02037b8:	6590                	ld	a2,8(a1)
ffffffffc02037ba:	0105b803          	ld	a6,16(a1) # 80010 <_binary_obj___user_exit_out_size+0x74ef8>
{
ffffffffc02037be:	1141                	addi	sp,sp,-16
ffffffffc02037c0:	e406                	sd	ra,8(sp)
ffffffffc02037c2:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02037c4:	01066763          	bltu	a2,a6,ffffffffc02037d2 <insert_vma_struct+0x1a>
ffffffffc02037c8:	a085                	j	ffffffffc0203828 <insert_vma_struct+0x70>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc02037ca:	fe87b703          	ld	a4,-24(a5)
ffffffffc02037ce:	04e66863          	bltu	a2,a4,ffffffffc020381e <insert_vma_struct+0x66>
ffffffffc02037d2:	86be                	mv	a3,a5
ffffffffc02037d4:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc02037d6:	fef51ae3          	bne	a0,a5,ffffffffc02037ca <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc02037da:	02a68463          	beq	a3,a0,ffffffffc0203802 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02037de:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02037e2:	fe86b883          	ld	a7,-24(a3)
ffffffffc02037e6:	08e8f163          	bgeu	a7,a4,ffffffffc0203868 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02037ea:	04e66f63          	bltu	a2,a4,ffffffffc0203848 <insert_vma_struct+0x90>
    }
    if (le_next != list)
ffffffffc02037ee:	00f50a63          	beq	a0,a5,ffffffffc0203802 <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc02037f2:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02037f6:	05076963          	bltu	a4,a6,ffffffffc0203848 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02037fa:	ff07b603          	ld	a2,-16(a5)
ffffffffc02037fe:	02c77363          	bgeu	a4,a2,ffffffffc0203824 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc0203802:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0203804:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203806:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc020380a:	e390                	sd	a2,0(a5)
ffffffffc020380c:	e690                	sd	a2,8(a3)
}
ffffffffc020380e:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0203810:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203812:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc0203814:	0017079b          	addiw	a5,a4,1
ffffffffc0203818:	d11c                	sw	a5,32(a0)
}
ffffffffc020381a:	0141                	addi	sp,sp,16
ffffffffc020381c:	8082                	ret
    if (le_prev != list)
ffffffffc020381e:	fca690e3          	bne	a3,a0,ffffffffc02037de <insert_vma_struct+0x26>
ffffffffc0203822:	bfd1                	j	ffffffffc02037f6 <insert_vma_struct+0x3e>
ffffffffc0203824:	f01ff0ef          	jal	ra,ffffffffc0203724 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203828:	00003697          	auipc	a3,0x3
ffffffffc020382c:	62068693          	addi	a3,a3,1568 # ffffffffc0206e48 <default_pmm_manager+0x7d0>
ffffffffc0203830:	00003617          	auipc	a2,0x3
ffffffffc0203834:	a9860613          	addi	a2,a2,-1384 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203838:	07a00593          	li	a1,122
ffffffffc020383c:	00003517          	auipc	a0,0x3
ffffffffc0203840:	5fc50513          	addi	a0,a0,1532 # ffffffffc0206e38 <default_pmm_manager+0x7c0>
ffffffffc0203844:	c4bfc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203848:	00003697          	auipc	a3,0x3
ffffffffc020384c:	64068693          	addi	a3,a3,1600 # ffffffffc0206e88 <default_pmm_manager+0x810>
ffffffffc0203850:	00003617          	auipc	a2,0x3
ffffffffc0203854:	a7860613          	addi	a2,a2,-1416 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203858:	07300593          	li	a1,115
ffffffffc020385c:	00003517          	auipc	a0,0x3
ffffffffc0203860:	5dc50513          	addi	a0,a0,1500 # ffffffffc0206e38 <default_pmm_manager+0x7c0>
ffffffffc0203864:	c2bfc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203868:	00003697          	auipc	a3,0x3
ffffffffc020386c:	60068693          	addi	a3,a3,1536 # ffffffffc0206e68 <default_pmm_manager+0x7f0>
ffffffffc0203870:	00003617          	auipc	a2,0x3
ffffffffc0203874:	a5860613          	addi	a2,a2,-1448 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203878:	07200593          	li	a1,114
ffffffffc020387c:	00003517          	auipc	a0,0x3
ffffffffc0203880:	5bc50513          	addi	a0,a0,1468 # ffffffffc0206e38 <default_pmm_manager+0x7c0>
ffffffffc0203884:	c0bfc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203888 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc0203888:	591c                	lw	a5,48(a0)
{
ffffffffc020388a:	1141                	addi	sp,sp,-16
ffffffffc020388c:	e406                	sd	ra,8(sp)
ffffffffc020388e:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0203890:	e78d                	bnez	a5,ffffffffc02038ba <mm_destroy+0x32>
ffffffffc0203892:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203894:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc0203896:	00a40c63          	beq	s0,a0,ffffffffc02038ae <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020389a:	6118                	ld	a4,0(a0)
ffffffffc020389c:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc020389e:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02038a0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02038a2:	e398                	sd	a4,0(a5)
ffffffffc02038a4:	d32fe0ef          	jal	ra,ffffffffc0201dd6 <kfree>
    return listelm->next;
ffffffffc02038a8:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc02038aa:	fea418e3          	bne	s0,a0,ffffffffc020389a <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc02038ae:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc02038b0:	6402                	ld	s0,0(sp)
ffffffffc02038b2:	60a2                	ld	ra,8(sp)
ffffffffc02038b4:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc02038b6:	d20fe06f          	j	ffffffffc0201dd6 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc02038ba:	00003697          	auipc	a3,0x3
ffffffffc02038be:	5ee68693          	addi	a3,a3,1518 # ffffffffc0206ea8 <default_pmm_manager+0x830>
ffffffffc02038c2:	00003617          	auipc	a2,0x3
ffffffffc02038c6:	a0660613          	addi	a2,a2,-1530 # ffffffffc02062c8 <commands+0x890>
ffffffffc02038ca:	09e00593          	li	a1,158
ffffffffc02038ce:	00003517          	auipc	a0,0x3
ffffffffc02038d2:	56a50513          	addi	a0,a0,1386 # ffffffffc0206e38 <default_pmm_manager+0x7c0>
ffffffffc02038d6:	bb9fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02038da <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
ffffffffc02038da:	7139                	addi	sp,sp,-64
ffffffffc02038dc:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02038de:	6405                	lui	s0,0x1
ffffffffc02038e0:	147d                	addi	s0,s0,-1
ffffffffc02038e2:	77fd                	lui	a5,0xfffff
ffffffffc02038e4:	9622                	add	a2,a2,s0
ffffffffc02038e6:	962e                	add	a2,a2,a1
{
ffffffffc02038e8:	f426                	sd	s1,40(sp)
ffffffffc02038ea:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02038ec:	00f5f4b3          	and	s1,a1,a5
{
ffffffffc02038f0:	f04a                	sd	s2,32(sp)
ffffffffc02038f2:	ec4e                	sd	s3,24(sp)
ffffffffc02038f4:	e852                	sd	s4,16(sp)
ffffffffc02038f6:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end))
ffffffffc02038f8:	002005b7          	lui	a1,0x200
ffffffffc02038fc:	00f67433          	and	s0,a2,a5
ffffffffc0203900:	06b4e363          	bltu	s1,a1,ffffffffc0203966 <mm_map+0x8c>
ffffffffc0203904:	0684f163          	bgeu	s1,s0,ffffffffc0203966 <mm_map+0x8c>
ffffffffc0203908:	4785                	li	a5,1
ffffffffc020390a:	07fe                	slli	a5,a5,0x1f
ffffffffc020390c:	0487ed63          	bltu	a5,s0,ffffffffc0203966 <mm_map+0x8c>
ffffffffc0203910:	89aa                	mv	s3,a0
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0203912:	cd21                	beqz	a0,ffffffffc020396a <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc0203914:	85a6                	mv	a1,s1
ffffffffc0203916:	8ab6                	mv	s5,a3
ffffffffc0203918:	8a3a                	mv	s4,a4
ffffffffc020391a:	e5fff0ef          	jal	ra,ffffffffc0203778 <find_vma>
ffffffffc020391e:	c501                	beqz	a0,ffffffffc0203926 <mm_map+0x4c>
ffffffffc0203920:	651c                	ld	a5,8(a0)
ffffffffc0203922:	0487e263          	bltu	a5,s0,ffffffffc0203966 <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203926:	03000513          	li	a0,48
ffffffffc020392a:	bfcfe0ef          	jal	ra,ffffffffc0201d26 <kmalloc>
ffffffffc020392e:	892a                	mv	s2,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0203930:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc0203932:	02090163          	beqz	s2,ffffffffc0203954 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0203936:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc0203938:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc020393c:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0203940:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0203944:	85ca                	mv	a1,s2
ffffffffc0203946:	e73ff0ef          	jal	ra,ffffffffc02037b8 <insert_vma_struct>
    if (vma_store != NULL)
    {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc020394a:	4501                	li	a0,0
    if (vma_store != NULL)
ffffffffc020394c:	000a0463          	beqz	s4,ffffffffc0203954 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc0203950:	012a3023          	sd	s2,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8ba8>

out:
    return ret;
}
ffffffffc0203954:	70e2                	ld	ra,56(sp)
ffffffffc0203956:	7442                	ld	s0,48(sp)
ffffffffc0203958:	74a2                	ld	s1,40(sp)
ffffffffc020395a:	7902                	ld	s2,32(sp)
ffffffffc020395c:	69e2                	ld	s3,24(sp)
ffffffffc020395e:	6a42                	ld	s4,16(sp)
ffffffffc0203960:	6aa2                	ld	s5,8(sp)
ffffffffc0203962:	6121                	addi	sp,sp,64
ffffffffc0203964:	8082                	ret
        return -E_INVAL;
ffffffffc0203966:	5575                	li	a0,-3
ffffffffc0203968:	b7f5                	j	ffffffffc0203954 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc020396a:	00003697          	auipc	a3,0x3
ffffffffc020396e:	55668693          	addi	a3,a3,1366 # ffffffffc0206ec0 <default_pmm_manager+0x848>
ffffffffc0203972:	00003617          	auipc	a2,0x3
ffffffffc0203976:	95660613          	addi	a2,a2,-1706 # ffffffffc02062c8 <commands+0x890>
ffffffffc020397a:	0b300593          	li	a1,179
ffffffffc020397e:	00003517          	auipc	a0,0x3
ffffffffc0203982:	4ba50513          	addi	a0,a0,1210 # ffffffffc0206e38 <default_pmm_manager+0x7c0>
ffffffffc0203986:	b09fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020398a <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc020398a:	7139                	addi	sp,sp,-64
ffffffffc020398c:	fc06                	sd	ra,56(sp)
ffffffffc020398e:	f822                	sd	s0,48(sp)
ffffffffc0203990:	f426                	sd	s1,40(sp)
ffffffffc0203992:	f04a                	sd	s2,32(sp)
ffffffffc0203994:	ec4e                	sd	s3,24(sp)
ffffffffc0203996:	e852                	sd	s4,16(sp)
ffffffffc0203998:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc020399a:	c52d                	beqz	a0,ffffffffc0203a04 <dup_mmap+0x7a>
ffffffffc020399c:	892a                	mv	s2,a0
ffffffffc020399e:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc02039a0:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc02039a2:	e595                	bnez	a1,ffffffffc02039ce <dup_mmap+0x44>
ffffffffc02039a4:	a085                	j	ffffffffc0203a04 <dup_mmap+0x7a>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc02039a6:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc02039a8:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4ef0>
        vma->vm_end = vm_end;
ffffffffc02039ac:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc02039b0:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc02039b4:	e05ff0ef          	jal	ra,ffffffffc02037b8 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc02039b8:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bb8>
ffffffffc02039bc:	fe843603          	ld	a2,-24(s0)
ffffffffc02039c0:	6c8c                	ld	a1,24(s1)
ffffffffc02039c2:	01893503          	ld	a0,24(s2)
ffffffffc02039c6:	4701                	li	a4,0
ffffffffc02039c8:	a1bff0ef          	jal	ra,ffffffffc02033e2 <copy_range>
ffffffffc02039cc:	e105                	bnez	a0,ffffffffc02039ec <dup_mmap+0x62>
    return listelm->prev;
ffffffffc02039ce:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc02039d0:	02848863          	beq	s1,s0,ffffffffc0203a00 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02039d4:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02039d8:	fe843a83          	ld	s5,-24(s0)
ffffffffc02039dc:	ff043a03          	ld	s4,-16(s0)
ffffffffc02039e0:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02039e4:	b42fe0ef          	jal	ra,ffffffffc0201d26 <kmalloc>
ffffffffc02039e8:	85aa                	mv	a1,a0
    if (vma != NULL)
ffffffffc02039ea:	fd55                	bnez	a0,ffffffffc02039a6 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc02039ec:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02039ee:	70e2                	ld	ra,56(sp)
ffffffffc02039f0:	7442                	ld	s0,48(sp)
ffffffffc02039f2:	74a2                	ld	s1,40(sp)
ffffffffc02039f4:	7902                	ld	s2,32(sp)
ffffffffc02039f6:	69e2                	ld	s3,24(sp)
ffffffffc02039f8:	6a42                	ld	s4,16(sp)
ffffffffc02039fa:	6aa2                	ld	s5,8(sp)
ffffffffc02039fc:	6121                	addi	sp,sp,64
ffffffffc02039fe:	8082                	ret
    return 0;
ffffffffc0203a00:	4501                	li	a0,0
ffffffffc0203a02:	b7f5                	j	ffffffffc02039ee <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc0203a04:	00003697          	auipc	a3,0x3
ffffffffc0203a08:	4cc68693          	addi	a3,a3,1228 # ffffffffc0206ed0 <default_pmm_manager+0x858>
ffffffffc0203a0c:	00003617          	auipc	a2,0x3
ffffffffc0203a10:	8bc60613          	addi	a2,a2,-1860 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203a14:	0cf00593          	li	a1,207
ffffffffc0203a18:	00003517          	auipc	a0,0x3
ffffffffc0203a1c:	42050513          	addi	a0,a0,1056 # ffffffffc0206e38 <default_pmm_manager+0x7c0>
ffffffffc0203a20:	a6ffc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203a24 <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc0203a24:	1101                	addi	sp,sp,-32
ffffffffc0203a26:	ec06                	sd	ra,24(sp)
ffffffffc0203a28:	e822                	sd	s0,16(sp)
ffffffffc0203a2a:	e426                	sd	s1,8(sp)
ffffffffc0203a2c:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203a2e:	c531                	beqz	a0,ffffffffc0203a7a <exit_mmap+0x56>
ffffffffc0203a30:	591c                	lw	a5,48(a0)
ffffffffc0203a32:	84aa                	mv	s1,a0
ffffffffc0203a34:	e3b9                	bnez	a5,ffffffffc0203a7a <exit_mmap+0x56>
    return listelm->next;
ffffffffc0203a36:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0203a38:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc0203a3c:	02850663          	beq	a0,s0,ffffffffc0203a68 <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0203a40:	ff043603          	ld	a2,-16(s0)
ffffffffc0203a44:	fe843583          	ld	a1,-24(s0)
ffffffffc0203a48:	854a                	mv	a0,s2
ffffffffc0203a4a:	feefe0ef          	jal	ra,ffffffffc0202238 <unmap_range>
ffffffffc0203a4e:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0203a50:	fe8498e3          	bne	s1,s0,ffffffffc0203a40 <exit_mmap+0x1c>
ffffffffc0203a54:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc0203a56:	00848c63          	beq	s1,s0,ffffffffc0203a6e <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0203a5a:	ff043603          	ld	a2,-16(s0)
ffffffffc0203a5e:	fe843583          	ld	a1,-24(s0)
ffffffffc0203a62:	854a                	mv	a0,s2
ffffffffc0203a64:	91bfe0ef          	jal	ra,ffffffffc020237e <exit_range>
ffffffffc0203a68:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0203a6a:	fe8498e3          	bne	s1,s0,ffffffffc0203a5a <exit_mmap+0x36>
    }
}
ffffffffc0203a6e:	60e2                	ld	ra,24(sp)
ffffffffc0203a70:	6442                	ld	s0,16(sp)
ffffffffc0203a72:	64a2                	ld	s1,8(sp)
ffffffffc0203a74:	6902                	ld	s2,0(sp)
ffffffffc0203a76:	6105                	addi	sp,sp,32
ffffffffc0203a78:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203a7a:	00003697          	auipc	a3,0x3
ffffffffc0203a7e:	47668693          	addi	a3,a3,1142 # ffffffffc0206ef0 <default_pmm_manager+0x878>
ffffffffc0203a82:	00003617          	auipc	a2,0x3
ffffffffc0203a86:	84660613          	addi	a2,a2,-1978 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203a8a:	0e800593          	li	a1,232
ffffffffc0203a8e:	00003517          	auipc	a0,0x3
ffffffffc0203a92:	3aa50513          	addi	a0,a0,938 # ffffffffc0206e38 <default_pmm_manager+0x7c0>
ffffffffc0203a96:	9f9fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203a9a <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0203a9a:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203a9c:	04000513          	li	a0,64
{
ffffffffc0203aa0:	fc06                	sd	ra,56(sp)
ffffffffc0203aa2:	f822                	sd	s0,48(sp)
ffffffffc0203aa4:	f426                	sd	s1,40(sp)
ffffffffc0203aa6:	f04a                	sd	s2,32(sp)
ffffffffc0203aa8:	ec4e                	sd	s3,24(sp)
ffffffffc0203aaa:	e852                	sd	s4,16(sp)
ffffffffc0203aac:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203aae:	a78fe0ef          	jal	ra,ffffffffc0201d26 <kmalloc>
    if (mm != NULL)
ffffffffc0203ab2:	2e050663          	beqz	a0,ffffffffc0203d9e <vmm_init+0x304>
ffffffffc0203ab6:	84aa                	mv	s1,a0
    elm->prev = elm->next = elm;
ffffffffc0203ab8:	e508                	sd	a0,8(a0)
ffffffffc0203aba:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203abc:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203ac0:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203ac4:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0203ac8:	02053423          	sd	zero,40(a0)
ffffffffc0203acc:	02052823          	sw	zero,48(a0)
ffffffffc0203ad0:	02053c23          	sd	zero,56(a0)
ffffffffc0203ad4:	03200413          	li	s0,50
ffffffffc0203ad8:	a811                	j	ffffffffc0203aec <vmm_init+0x52>
        vma->vm_start = vm_start;
ffffffffc0203ada:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203adc:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203ade:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
ffffffffc0203ae2:	146d                	addi	s0,s0,-5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203ae4:	8526                	mv	a0,s1
ffffffffc0203ae6:	cd3ff0ef          	jal	ra,ffffffffc02037b8 <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0203aea:	c80d                	beqz	s0,ffffffffc0203b1c <vmm_init+0x82>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203aec:	03000513          	li	a0,48
ffffffffc0203af0:	a36fe0ef          	jal	ra,ffffffffc0201d26 <kmalloc>
ffffffffc0203af4:	85aa                	mv	a1,a0
ffffffffc0203af6:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0203afa:	f165                	bnez	a0,ffffffffc0203ada <vmm_init+0x40>
        assert(vma != NULL);
ffffffffc0203afc:	00003697          	auipc	a3,0x3
ffffffffc0203b00:	58c68693          	addi	a3,a3,1420 # ffffffffc0207088 <default_pmm_manager+0xa10>
ffffffffc0203b04:	00002617          	auipc	a2,0x2
ffffffffc0203b08:	7c460613          	addi	a2,a2,1988 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203b0c:	12c00593          	li	a1,300
ffffffffc0203b10:	00003517          	auipc	a0,0x3
ffffffffc0203b14:	32850513          	addi	a0,a0,808 # ffffffffc0206e38 <default_pmm_manager+0x7c0>
ffffffffc0203b18:	977fc0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc0203b1c:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203b20:	1f900913          	li	s2,505
ffffffffc0203b24:	a819                	j	ffffffffc0203b3a <vmm_init+0xa0>
        vma->vm_start = vm_start;
ffffffffc0203b26:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203b28:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203b2a:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203b2e:	0415                	addi	s0,s0,5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203b30:	8526                	mv	a0,s1
ffffffffc0203b32:	c87ff0ef          	jal	ra,ffffffffc02037b8 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203b36:	03240a63          	beq	s0,s2,ffffffffc0203b6a <vmm_init+0xd0>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203b3a:	03000513          	li	a0,48
ffffffffc0203b3e:	9e8fe0ef          	jal	ra,ffffffffc0201d26 <kmalloc>
ffffffffc0203b42:	85aa                	mv	a1,a0
ffffffffc0203b44:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0203b48:	fd79                	bnez	a0,ffffffffc0203b26 <vmm_init+0x8c>
        assert(vma != NULL);
ffffffffc0203b4a:	00003697          	auipc	a3,0x3
ffffffffc0203b4e:	53e68693          	addi	a3,a3,1342 # ffffffffc0207088 <default_pmm_manager+0xa10>
ffffffffc0203b52:	00002617          	auipc	a2,0x2
ffffffffc0203b56:	77660613          	addi	a2,a2,1910 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203b5a:	13300593          	li	a1,307
ffffffffc0203b5e:	00003517          	auipc	a0,0x3
ffffffffc0203b62:	2da50513          	addi	a0,a0,730 # ffffffffc0206e38 <default_pmm_manager+0x7c0>
ffffffffc0203b66:	929fc0ef          	jal	ra,ffffffffc020048e <__panic>
    return listelm->next;
ffffffffc0203b6a:	649c                	ld	a5,8(s1)
ffffffffc0203b6c:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0203b6e:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0203b72:	16f48663          	beq	s1,a5,ffffffffc0203cde <vmm_init+0x244>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203b76:	fe87b603          	ld	a2,-24(a5) # ffffffffffffefe8 <end+0x3fd548ec>
ffffffffc0203b7a:	ffe70693          	addi	a3,a4,-2
ffffffffc0203b7e:	10d61063          	bne	a2,a3,ffffffffc0203c7e <vmm_init+0x1e4>
ffffffffc0203b82:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203b86:	0ed71c63          	bne	a4,a3,ffffffffc0203c7e <vmm_init+0x1e4>
    for (i = 1; i <= step2; i++)
ffffffffc0203b8a:	0715                	addi	a4,a4,5
ffffffffc0203b8c:	679c                	ld	a5,8(a5)
ffffffffc0203b8e:	feb712e3          	bne	a4,a1,ffffffffc0203b72 <vmm_init+0xd8>
ffffffffc0203b92:	4a1d                	li	s4,7
ffffffffc0203b94:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203b96:	1f900a93          	li	s5,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203b9a:	85a2                	mv	a1,s0
ffffffffc0203b9c:	8526                	mv	a0,s1
ffffffffc0203b9e:	bdbff0ef          	jal	ra,ffffffffc0203778 <find_vma>
ffffffffc0203ba2:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0203ba4:	16050d63          	beqz	a0,ffffffffc0203d1e <vmm_init+0x284>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0203ba8:	00140593          	addi	a1,s0,1
ffffffffc0203bac:	8526                	mv	a0,s1
ffffffffc0203bae:	bcbff0ef          	jal	ra,ffffffffc0203778 <find_vma>
ffffffffc0203bb2:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203bb4:	14050563          	beqz	a0,ffffffffc0203cfe <vmm_init+0x264>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0203bb8:	85d2                	mv	a1,s4
ffffffffc0203bba:	8526                	mv	a0,s1
ffffffffc0203bbc:	bbdff0ef          	jal	ra,ffffffffc0203778 <find_vma>
        assert(vma3 == NULL);
ffffffffc0203bc0:	16051f63          	bnez	a0,ffffffffc0203d3e <vmm_init+0x2a4>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0203bc4:	00340593          	addi	a1,s0,3
ffffffffc0203bc8:	8526                	mv	a0,s1
ffffffffc0203bca:	bafff0ef          	jal	ra,ffffffffc0203778 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203bce:	1a051863          	bnez	a0,ffffffffc0203d7e <vmm_init+0x2e4>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0203bd2:	00440593          	addi	a1,s0,4
ffffffffc0203bd6:	8526                	mv	a0,s1
ffffffffc0203bd8:	ba1ff0ef          	jal	ra,ffffffffc0203778 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203bdc:	18051163          	bnez	a0,ffffffffc0203d5e <vmm_init+0x2c4>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203be0:	00893783          	ld	a5,8(s2)
ffffffffc0203be4:	0a879d63          	bne	a5,s0,ffffffffc0203c9e <vmm_init+0x204>
ffffffffc0203be8:	01093783          	ld	a5,16(s2)
ffffffffc0203bec:	0b479963          	bne	a5,s4,ffffffffc0203c9e <vmm_init+0x204>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203bf0:	0089b783          	ld	a5,8(s3)
ffffffffc0203bf4:	0c879563          	bne	a5,s0,ffffffffc0203cbe <vmm_init+0x224>
ffffffffc0203bf8:	0109b783          	ld	a5,16(s3)
ffffffffc0203bfc:	0d479163          	bne	a5,s4,ffffffffc0203cbe <vmm_init+0x224>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203c00:	0415                	addi	s0,s0,5
ffffffffc0203c02:	0a15                	addi	s4,s4,5
ffffffffc0203c04:	f9541be3          	bne	s0,s5,ffffffffc0203b9a <vmm_init+0x100>
ffffffffc0203c08:	4411                	li	s0,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0203c0a:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0203c0c:	85a2                	mv	a1,s0
ffffffffc0203c0e:	8526                	mv	a0,s1
ffffffffc0203c10:	b69ff0ef          	jal	ra,ffffffffc0203778 <find_vma>
ffffffffc0203c14:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL)
ffffffffc0203c18:	c90d                	beqz	a0,ffffffffc0203c4a <vmm_init+0x1b0>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0203c1a:	6914                	ld	a3,16(a0)
ffffffffc0203c1c:	6510                	ld	a2,8(a0)
ffffffffc0203c1e:	00003517          	auipc	a0,0x3
ffffffffc0203c22:	3f250513          	addi	a0,a0,1010 # ffffffffc0207010 <default_pmm_manager+0x998>
ffffffffc0203c26:	d6efc0ef          	jal	ra,ffffffffc0200194 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203c2a:	00003697          	auipc	a3,0x3
ffffffffc0203c2e:	40e68693          	addi	a3,a3,1038 # ffffffffc0207038 <default_pmm_manager+0x9c0>
ffffffffc0203c32:	00002617          	auipc	a2,0x2
ffffffffc0203c36:	69660613          	addi	a2,a2,1686 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203c3a:	15900593          	li	a1,345
ffffffffc0203c3e:	00003517          	auipc	a0,0x3
ffffffffc0203c42:	1fa50513          	addi	a0,a0,506 # ffffffffc0206e38 <default_pmm_manager+0x7c0>
ffffffffc0203c46:	849fc0ef          	jal	ra,ffffffffc020048e <__panic>
    for (i = 4; i >= 0; i--)
ffffffffc0203c4a:	147d                	addi	s0,s0,-1
ffffffffc0203c4c:	fd2410e3          	bne	s0,s2,ffffffffc0203c0c <vmm_init+0x172>
    }

    mm_destroy(mm);
ffffffffc0203c50:	8526                	mv	a0,s1
ffffffffc0203c52:	c37ff0ef          	jal	ra,ffffffffc0203888 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203c56:	00003517          	auipc	a0,0x3
ffffffffc0203c5a:	3fa50513          	addi	a0,a0,1018 # ffffffffc0207050 <default_pmm_manager+0x9d8>
ffffffffc0203c5e:	d36fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
}
ffffffffc0203c62:	7442                	ld	s0,48(sp)
ffffffffc0203c64:	70e2                	ld	ra,56(sp)
ffffffffc0203c66:	74a2                	ld	s1,40(sp)
ffffffffc0203c68:	7902                	ld	s2,32(sp)
ffffffffc0203c6a:	69e2                	ld	s3,24(sp)
ffffffffc0203c6c:	6a42                	ld	s4,16(sp)
ffffffffc0203c6e:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203c70:	00003517          	auipc	a0,0x3
ffffffffc0203c74:	40050513          	addi	a0,a0,1024 # ffffffffc0207070 <default_pmm_manager+0x9f8>
}
ffffffffc0203c78:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203c7a:	d1afc06f          	j	ffffffffc0200194 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203c7e:	00003697          	auipc	a3,0x3
ffffffffc0203c82:	2aa68693          	addi	a3,a3,682 # ffffffffc0206f28 <default_pmm_manager+0x8b0>
ffffffffc0203c86:	00002617          	auipc	a2,0x2
ffffffffc0203c8a:	64260613          	addi	a2,a2,1602 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203c8e:	13d00593          	li	a1,317
ffffffffc0203c92:	00003517          	auipc	a0,0x3
ffffffffc0203c96:	1a650513          	addi	a0,a0,422 # ffffffffc0206e38 <default_pmm_manager+0x7c0>
ffffffffc0203c9a:	ff4fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203c9e:	00003697          	auipc	a3,0x3
ffffffffc0203ca2:	31268693          	addi	a3,a3,786 # ffffffffc0206fb0 <default_pmm_manager+0x938>
ffffffffc0203ca6:	00002617          	auipc	a2,0x2
ffffffffc0203caa:	62260613          	addi	a2,a2,1570 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203cae:	14e00593          	li	a1,334
ffffffffc0203cb2:	00003517          	auipc	a0,0x3
ffffffffc0203cb6:	18650513          	addi	a0,a0,390 # ffffffffc0206e38 <default_pmm_manager+0x7c0>
ffffffffc0203cba:	fd4fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203cbe:	00003697          	auipc	a3,0x3
ffffffffc0203cc2:	32268693          	addi	a3,a3,802 # ffffffffc0206fe0 <default_pmm_manager+0x968>
ffffffffc0203cc6:	00002617          	auipc	a2,0x2
ffffffffc0203cca:	60260613          	addi	a2,a2,1538 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203cce:	14f00593          	li	a1,335
ffffffffc0203cd2:	00003517          	auipc	a0,0x3
ffffffffc0203cd6:	16650513          	addi	a0,a0,358 # ffffffffc0206e38 <default_pmm_manager+0x7c0>
ffffffffc0203cda:	fb4fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203cde:	00003697          	auipc	a3,0x3
ffffffffc0203ce2:	23268693          	addi	a3,a3,562 # ffffffffc0206f10 <default_pmm_manager+0x898>
ffffffffc0203ce6:	00002617          	auipc	a2,0x2
ffffffffc0203cea:	5e260613          	addi	a2,a2,1506 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203cee:	13b00593          	li	a1,315
ffffffffc0203cf2:	00003517          	auipc	a0,0x3
ffffffffc0203cf6:	14650513          	addi	a0,a0,326 # ffffffffc0206e38 <default_pmm_manager+0x7c0>
ffffffffc0203cfa:	f94fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma2 != NULL);
ffffffffc0203cfe:	00003697          	auipc	a3,0x3
ffffffffc0203d02:	27268693          	addi	a3,a3,626 # ffffffffc0206f70 <default_pmm_manager+0x8f8>
ffffffffc0203d06:	00002617          	auipc	a2,0x2
ffffffffc0203d0a:	5c260613          	addi	a2,a2,1474 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203d0e:	14600593          	li	a1,326
ffffffffc0203d12:	00003517          	auipc	a0,0x3
ffffffffc0203d16:	12650513          	addi	a0,a0,294 # ffffffffc0206e38 <default_pmm_manager+0x7c0>
ffffffffc0203d1a:	f74fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma1 != NULL);
ffffffffc0203d1e:	00003697          	auipc	a3,0x3
ffffffffc0203d22:	24268693          	addi	a3,a3,578 # ffffffffc0206f60 <default_pmm_manager+0x8e8>
ffffffffc0203d26:	00002617          	auipc	a2,0x2
ffffffffc0203d2a:	5a260613          	addi	a2,a2,1442 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203d2e:	14400593          	li	a1,324
ffffffffc0203d32:	00003517          	auipc	a0,0x3
ffffffffc0203d36:	10650513          	addi	a0,a0,262 # ffffffffc0206e38 <default_pmm_manager+0x7c0>
ffffffffc0203d3a:	f54fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma3 == NULL);
ffffffffc0203d3e:	00003697          	auipc	a3,0x3
ffffffffc0203d42:	24268693          	addi	a3,a3,578 # ffffffffc0206f80 <default_pmm_manager+0x908>
ffffffffc0203d46:	00002617          	auipc	a2,0x2
ffffffffc0203d4a:	58260613          	addi	a2,a2,1410 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203d4e:	14800593          	li	a1,328
ffffffffc0203d52:	00003517          	auipc	a0,0x3
ffffffffc0203d56:	0e650513          	addi	a0,a0,230 # ffffffffc0206e38 <default_pmm_manager+0x7c0>
ffffffffc0203d5a:	f34fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma5 == NULL);
ffffffffc0203d5e:	00003697          	auipc	a3,0x3
ffffffffc0203d62:	24268693          	addi	a3,a3,578 # ffffffffc0206fa0 <default_pmm_manager+0x928>
ffffffffc0203d66:	00002617          	auipc	a2,0x2
ffffffffc0203d6a:	56260613          	addi	a2,a2,1378 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203d6e:	14c00593          	li	a1,332
ffffffffc0203d72:	00003517          	auipc	a0,0x3
ffffffffc0203d76:	0c650513          	addi	a0,a0,198 # ffffffffc0206e38 <default_pmm_manager+0x7c0>
ffffffffc0203d7a:	f14fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma4 == NULL);
ffffffffc0203d7e:	00003697          	auipc	a3,0x3
ffffffffc0203d82:	21268693          	addi	a3,a3,530 # ffffffffc0206f90 <default_pmm_manager+0x918>
ffffffffc0203d86:	00002617          	auipc	a2,0x2
ffffffffc0203d8a:	54260613          	addi	a2,a2,1346 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203d8e:	14a00593          	li	a1,330
ffffffffc0203d92:	00003517          	auipc	a0,0x3
ffffffffc0203d96:	0a650513          	addi	a0,a0,166 # ffffffffc0206e38 <default_pmm_manager+0x7c0>
ffffffffc0203d9a:	ef4fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(mm != NULL);
ffffffffc0203d9e:	00003697          	auipc	a3,0x3
ffffffffc0203da2:	12268693          	addi	a3,a3,290 # ffffffffc0206ec0 <default_pmm_manager+0x848>
ffffffffc0203da6:	00002617          	auipc	a2,0x2
ffffffffc0203daa:	52260613          	addi	a2,a2,1314 # ffffffffc02062c8 <commands+0x890>
ffffffffc0203dae:	12400593          	li	a1,292
ffffffffc0203db2:	00003517          	auipc	a0,0x3
ffffffffc0203db6:	08650513          	addi	a0,a0,134 # ffffffffc0206e38 <default_pmm_manager+0x7c0>
ffffffffc0203dba:	ed4fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203dbe <user_mem_check>:
}
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc0203dbe:	7179                	addi	sp,sp,-48
ffffffffc0203dc0:	f022                	sd	s0,32(sp)
ffffffffc0203dc2:	f406                	sd	ra,40(sp)
ffffffffc0203dc4:	ec26                	sd	s1,24(sp)
ffffffffc0203dc6:	e84a                	sd	s2,16(sp)
ffffffffc0203dc8:	e44e                	sd	s3,8(sp)
ffffffffc0203dca:	e052                	sd	s4,0(sp)
ffffffffc0203dcc:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc0203dce:	c135                	beqz	a0,ffffffffc0203e32 <user_mem_check+0x74>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc0203dd0:	002007b7          	lui	a5,0x200
ffffffffc0203dd4:	04f5e663          	bltu	a1,a5,ffffffffc0203e20 <user_mem_check+0x62>
ffffffffc0203dd8:	00c584b3          	add	s1,a1,a2
ffffffffc0203ddc:	0495f263          	bgeu	a1,s1,ffffffffc0203e20 <user_mem_check+0x62>
ffffffffc0203de0:	4785                	li	a5,1
ffffffffc0203de2:	07fe                	slli	a5,a5,0x1f
ffffffffc0203de4:	0297ee63          	bltu	a5,s1,ffffffffc0203e20 <user_mem_check+0x62>
ffffffffc0203de8:	892a                	mv	s2,a0
ffffffffc0203dea:	89b6                	mv	s3,a3
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203dec:	6a05                	lui	s4,0x1
ffffffffc0203dee:	a821                	j	ffffffffc0203e06 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203df0:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203df4:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203df6:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203df8:	c685                	beqz	a3,ffffffffc0203e20 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203dfa:	c399                	beqz	a5,ffffffffc0203e00 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203dfc:	02e46263          	bltu	s0,a4,ffffffffc0203e20 <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0203e00:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc0203e02:	04947663          	bgeu	s0,s1,ffffffffc0203e4e <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc0203e06:	85a2                	mv	a1,s0
ffffffffc0203e08:	854a                	mv	a0,s2
ffffffffc0203e0a:	96fff0ef          	jal	ra,ffffffffc0203778 <find_vma>
ffffffffc0203e0e:	c909                	beqz	a0,ffffffffc0203e20 <user_mem_check+0x62>
ffffffffc0203e10:	6518                	ld	a4,8(a0)
ffffffffc0203e12:	00e46763          	bltu	s0,a4,ffffffffc0203e20 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203e16:	4d1c                	lw	a5,24(a0)
ffffffffc0203e18:	fc099ce3          	bnez	s3,ffffffffc0203df0 <user_mem_check+0x32>
ffffffffc0203e1c:	8b85                	andi	a5,a5,1
ffffffffc0203e1e:	f3ed                	bnez	a5,ffffffffc0203e00 <user_mem_check+0x42>
            return 0;
ffffffffc0203e20:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203e22:	70a2                	ld	ra,40(sp)
ffffffffc0203e24:	7402                	ld	s0,32(sp)
ffffffffc0203e26:	64e2                	ld	s1,24(sp)
ffffffffc0203e28:	6942                	ld	s2,16(sp)
ffffffffc0203e2a:	69a2                	ld	s3,8(sp)
ffffffffc0203e2c:	6a02                	ld	s4,0(sp)
ffffffffc0203e2e:	6145                	addi	sp,sp,48
ffffffffc0203e30:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203e32:	c02007b7          	lui	a5,0xc0200
ffffffffc0203e36:	4501                	li	a0,0
ffffffffc0203e38:	fef5e5e3          	bltu	a1,a5,ffffffffc0203e22 <user_mem_check+0x64>
ffffffffc0203e3c:	962e                	add	a2,a2,a1
ffffffffc0203e3e:	fec5f2e3          	bgeu	a1,a2,ffffffffc0203e22 <user_mem_check+0x64>
ffffffffc0203e42:	c8000537          	lui	a0,0xc8000
ffffffffc0203e46:	0505                	addi	a0,a0,1
ffffffffc0203e48:	00a63533          	sltu	a0,a2,a0
ffffffffc0203e4c:	bfd9                	j	ffffffffc0203e22 <user_mem_check+0x64>
        return 1;
ffffffffc0203e4e:	4505                	li	a0,1
ffffffffc0203e50:	bfc9                	j	ffffffffc0203e22 <user_mem_check+0x64>

ffffffffc0203e52 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0203e52:	8526                	mv	a0,s1
	jalr s0
ffffffffc0203e54:	9402                	jalr	s0

	jal do_exit
ffffffffc0203e56:	676000ef          	jal	ra,ffffffffc02044cc <do_exit>

ffffffffc0203e5a <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc0203e5a:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203e5c:	10800513          	li	a0,264
{
ffffffffc0203e60:	e022                	sd	s0,0(sp)
ffffffffc0203e62:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203e64:	ec3fd0ef          	jal	ra,ffffffffc0201d26 <kmalloc>
ffffffffc0203e68:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc0203e6a:	cd21                	beqz	a0,ffffffffc0203ec2 <alloc_proc+0x68>
        /*
         * below fields(add in LAB5) in proc_struct need to be initialized
         *       uint32_t wait_state;                        // waiting state
         *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
         */
        proc->state = PROC_UNINIT;        // 尚未进入就绪态
ffffffffc0203e6c:	57fd                	li	a5,-1
ffffffffc0203e6e:	1782                	slli	a5,a5,0x20
ffffffffc0203e70:	e11c                	sd	a5,0(a0)
        proc->runs = 0;                   // 运行次数计数器清零
        proc->kstack = 0;                 // 还未分配内核栈
        proc->need_resched = 0;           // 默认不请求调度
        proc->parent = NULL;              // 父进程待后续设置
        proc->mm = NULL;                  // 地址空间后续 copy/share
        memset(&proc->context, 0, sizeof(struct context)); // 确保首次 switch_to 有确定值
ffffffffc0203e72:	07000613          	li	a2,112
ffffffffc0203e76:	4581                	li	a1,0
        proc->runs = 0;                   // 运行次数计数器清零
ffffffffc0203e78:	00052423          	sw	zero,8(a0) # ffffffffc8000008 <end+0x7d5590c>
        proc->kstack = 0;                 // 还未分配内核栈
ffffffffc0203e7c:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;           // 默认不请求调度
ffffffffc0203e80:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;              // 父进程待后续设置
ffffffffc0203e84:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;                  // 地址空间后续 copy/share
ffffffffc0203e88:	02053423          	sd	zero,40(a0)
        memset(&proc->context, 0, sizeof(struct context)); // 确保首次 switch_to 有确定值
ffffffffc0203e8c:	03050513          	addi	a0,a0,48
ffffffffc0203e90:	117010ef          	jal	ra,ffffffffc02057a6 <memset>
        proc->tf = NULL;                  // trapframe 等栈建立后 copy_thread 设置
        proc->pgdir = boot_pgdir_pa;      // 先使用内核页表基址
ffffffffc0203e94:	000a7797          	auipc	a5,0xa7
ffffffffc0203e98:	81c7b783          	ld	a5,-2020(a5) # ffffffffc02aa6b0 <boot_pgdir_pa>
        proc->tf = NULL;                  // trapframe 等栈建立后 copy_thread 设置
ffffffffc0203e9c:	0a043023          	sd	zero,160(s0)
        proc->pgdir = boot_pgdir_pa;      // 先使用内核页表基址
ffffffffc0203ea0:	f45c                	sd	a5,168(s0)
        proc->flags = 0;                  // 初始无标志
ffffffffc0203ea2:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, sizeof(proc->name)); // 进程名清零，后续 set_proc_name
ffffffffc0203ea6:	4641                	li	a2,16
ffffffffc0203ea8:	4581                	li	a1,0
ffffffffc0203eaa:	0b440513          	addi	a0,s0,180
ffffffffc0203eae:	0f9010ef          	jal	ra,ffffffffc02057a6 <memset>

        // LAB5: 初始化新增字段
        proc->exit_code = 0;              // 退出码初始化为0
ffffffffc0203eb2:	0e043423          	sd	zero,232(s0)
        proc->wait_state = 0;             // 等待状态初始化为0
        proc->cptr = proc->yptr = proc->optr = NULL; // 进程关系指针初始化为NULL
ffffffffc0203eb6:	0e043823          	sd	zero,240(s0)
ffffffffc0203eba:	0e043c23          	sd	zero,248(s0)
ffffffffc0203ebe:	10043023          	sd	zero,256(s0)
    }
    return proc;
}
ffffffffc0203ec2:	60a2                	ld	ra,8(sp)
ffffffffc0203ec4:	8522                	mv	a0,s0
ffffffffc0203ec6:	6402                	ld	s0,0(sp)
ffffffffc0203ec8:	0141                	addi	sp,sp,16
ffffffffc0203eca:	8082                	ret

ffffffffc0203ecc <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc0203ecc:	000a7797          	auipc	a5,0xa7
ffffffffc0203ed0:	8147b783          	ld	a5,-2028(a5) # ffffffffc02aa6e0 <current>
ffffffffc0203ed4:	73c8                	ld	a0,160(a5)
ffffffffc0203ed6:	8c4fd06f          	j	ffffffffc0200f9a <forkrets>

ffffffffc0203eda <user_main>:
// user_main - kernel thread used to exec a user program
static int
user_main(void *arg)
{
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0203eda:	000a7797          	auipc	a5,0xa7
ffffffffc0203ede:	8067b783          	ld	a5,-2042(a5) # ffffffffc02aa6e0 <current>
ffffffffc0203ee2:	43cc                	lw	a1,4(a5)
{
ffffffffc0203ee4:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0203ee6:	00003617          	auipc	a2,0x3
ffffffffc0203eea:	1b260613          	addi	a2,a2,434 # ffffffffc0207098 <default_pmm_manager+0xa20>
ffffffffc0203eee:	00003517          	auipc	a0,0x3
ffffffffc0203ef2:	1ba50513          	addi	a0,a0,442 # ffffffffc02070a8 <default_pmm_manager+0xa30>
{
ffffffffc0203ef6:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0203ef8:	a9cfc0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0203efc:	3fe07797          	auipc	a5,0x3fe07
ffffffffc0203f00:	a6478793          	addi	a5,a5,-1436 # a960 <_binary_obj___user_forktest_out_size>
ffffffffc0203f04:	e43e                	sd	a5,8(sp)
ffffffffc0203f06:	00003517          	auipc	a0,0x3
ffffffffc0203f0a:	19250513          	addi	a0,a0,402 # ffffffffc0207098 <default_pmm_manager+0xa20>
ffffffffc0203f0e:	00045797          	auipc	a5,0x45
ffffffffc0203f12:	7d278793          	addi	a5,a5,2002 # ffffffffc02496e0 <_binary_obj___user_forktest_out_start>
ffffffffc0203f16:	f03e                	sd	a5,32(sp)
ffffffffc0203f18:	f42a                	sd	a0,40(sp)
    int64_t ret = 0, len = strlen(name);
ffffffffc0203f1a:	e802                	sd	zero,16(sp)
ffffffffc0203f1c:	7e8010ef          	jal	ra,ffffffffc0205704 <strlen>
ffffffffc0203f20:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0203f22:	4511                	li	a0,4
ffffffffc0203f24:	55a2                	lw	a1,40(sp)
ffffffffc0203f26:	4662                	lw	a2,24(sp)
ffffffffc0203f28:	5682                	lw	a3,32(sp)
ffffffffc0203f2a:	4722                	lw	a4,8(sp)
ffffffffc0203f2c:	48a9                	li	a7,10
ffffffffc0203f2e:	9002                	ebreak
ffffffffc0203f30:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0203f32:	65c2                	ld	a1,16(sp)
ffffffffc0203f34:	00003517          	auipc	a0,0x3
ffffffffc0203f38:	19c50513          	addi	a0,a0,412 # ffffffffc02070d0 <default_pmm_manager+0xa58>
ffffffffc0203f3c:	a58fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0203f40:	00003617          	auipc	a2,0x3
ffffffffc0203f44:	1a060613          	addi	a2,a2,416 # ffffffffc02070e0 <default_pmm_manager+0xa68>
ffffffffc0203f48:	3bb00593          	li	a1,955
ffffffffc0203f4c:	00003517          	auipc	a0,0x3
ffffffffc0203f50:	1b450513          	addi	a0,a0,436 # ffffffffc0207100 <default_pmm_manager+0xa88>
ffffffffc0203f54:	d3afc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203f58 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0203f58:	6d14                	ld	a3,24(a0)
{
ffffffffc0203f5a:	1141                	addi	sp,sp,-16
ffffffffc0203f5c:	e406                	sd	ra,8(sp)
ffffffffc0203f5e:	c02007b7          	lui	a5,0xc0200
ffffffffc0203f62:	02f6ee63          	bltu	a3,a5,ffffffffc0203f9e <put_pgdir+0x46>
ffffffffc0203f66:	000a6517          	auipc	a0,0xa6
ffffffffc0203f6a:	77253503          	ld	a0,1906(a0) # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc0203f6e:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage)
ffffffffc0203f70:	82b1                	srli	a3,a3,0xc
ffffffffc0203f72:	000a6797          	auipc	a5,0xa6
ffffffffc0203f76:	74e7b783          	ld	a5,1870(a5) # ffffffffc02aa6c0 <npage>
ffffffffc0203f7a:	02f6fe63          	bgeu	a3,a5,ffffffffc0203fb6 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203f7e:	00004517          	auipc	a0,0x4
ffffffffc0203f82:	ab253503          	ld	a0,-1358(a0) # ffffffffc0207a30 <nbase>
}
ffffffffc0203f86:	60a2                	ld	ra,8(sp)
ffffffffc0203f88:	8e89                	sub	a3,a3,a0
ffffffffc0203f8a:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0203f8c:	000a6517          	auipc	a0,0xa6
ffffffffc0203f90:	73c53503          	ld	a0,1852(a0) # ffffffffc02aa6c8 <pages>
ffffffffc0203f94:	4585                	li	a1,1
ffffffffc0203f96:	9536                	add	a0,a0,a3
}
ffffffffc0203f98:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0203f9a:	fa9fd06f          	j	ffffffffc0201f42 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0203f9e:	00002617          	auipc	a2,0x2
ffffffffc0203fa2:	7ba60613          	addi	a2,a2,1978 # ffffffffc0206758 <default_pmm_manager+0xe0>
ffffffffc0203fa6:	07700593          	li	a1,119
ffffffffc0203faa:	00002517          	auipc	a0,0x2
ffffffffc0203fae:	72e50513          	addi	a0,a0,1838 # ffffffffc02066d8 <default_pmm_manager+0x60>
ffffffffc0203fb2:	cdcfc0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203fb6:	00002617          	auipc	a2,0x2
ffffffffc0203fba:	7ca60613          	addi	a2,a2,1994 # ffffffffc0206780 <default_pmm_manager+0x108>
ffffffffc0203fbe:	06900593          	li	a1,105
ffffffffc0203fc2:	00002517          	auipc	a0,0x2
ffffffffc0203fc6:	71650513          	addi	a0,a0,1814 # ffffffffc02066d8 <default_pmm_manager+0x60>
ffffffffc0203fca:	cc4fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203fce <setup_pgdir>:
{
ffffffffc0203fce:	1101                	addi	sp,sp,-32
ffffffffc0203fd0:	e04a                	sd	s2,0(sp)
ffffffffc0203fd2:	892a                	mv	s2,a0
    if ((page = alloc_page()) == NULL)
ffffffffc0203fd4:	4505                	li	a0,1
{
ffffffffc0203fd6:	ec06                	sd	ra,24(sp)
ffffffffc0203fd8:	e822                	sd	s0,16(sp)
ffffffffc0203fda:	e426                	sd	s1,8(sp)
    if ((page = alloc_page()) == NULL)
ffffffffc0203fdc:	f29fd0ef          	jal	ra,ffffffffc0201f04 <alloc_pages>
ffffffffc0203fe0:	cd39                	beqz	a0,ffffffffc020403e <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc0203fe2:	000a6697          	auipc	a3,0xa6
ffffffffc0203fe6:	6e66b683          	ld	a3,1766(a3) # ffffffffc02aa6c8 <pages>
ffffffffc0203fea:	40d506b3          	sub	a3,a0,a3
ffffffffc0203fee:	00004797          	auipc	a5,0x4
ffffffffc0203ff2:	a427b783          	ld	a5,-1470(a5) # ffffffffc0207a30 <nbase>
ffffffffc0203ff6:	8699                	srai	a3,a3,0x6
ffffffffc0203ff8:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0203ffa:	00c69793          	slli	a5,a3,0xc
ffffffffc0203ffe:	83b1                	srli	a5,a5,0xc
ffffffffc0204000:	000a6717          	auipc	a4,0xa6
ffffffffc0204004:	6c073703          	ld	a4,1728(a4) # ffffffffc02aa6c0 <npage>
ffffffffc0204008:	84aa                	mv	s1,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020400a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020400c:	04e7f763          	bgeu	a5,a4,ffffffffc020405a <setup_pgdir+0x8c>
ffffffffc0204010:	000a6417          	auipc	s0,0xa6
ffffffffc0204014:	6c843403          	ld	s0,1736(s0) # ffffffffc02aa6d8 <va_pa_offset>
    if (boot_pgdir_va == NULL) {
ffffffffc0204018:	000a6597          	auipc	a1,0xa6
ffffffffc020401c:	6a05b583          	ld	a1,1696(a1) # ffffffffc02aa6b8 <boot_pgdir_va>
ffffffffc0204020:	9436                	add	s0,s0,a3
ffffffffc0204022:	c185                	beqz	a1,ffffffffc0204042 <setup_pgdir+0x74>
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204024:	6605                	lui	a2,0x1
ffffffffc0204026:	8522                	mv	a0,s0
ffffffffc0204028:	790010ef          	jal	ra,ffffffffc02057b8 <memcpy>
    return 0;
ffffffffc020402c:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc020402e:	00893c23          	sd	s0,24(s2)
}
ffffffffc0204032:	60e2                	ld	ra,24(sp)
ffffffffc0204034:	6442                	ld	s0,16(sp)
ffffffffc0204036:	64a2                	ld	s1,8(sp)
ffffffffc0204038:	6902                	ld	s2,0(sp)
ffffffffc020403a:	6105                	addi	sp,sp,32
ffffffffc020403c:	8082                	ret
        return -E_NO_MEM;
ffffffffc020403e:	5571                	li	a0,-4
ffffffffc0204040:	bfcd                	j	ffffffffc0204032 <setup_pgdir+0x64>
        cprintf("[ERROR] setup_pgdir: boot_pgdir_va is NULL\n");
ffffffffc0204042:	00003517          	auipc	a0,0x3
ffffffffc0204046:	0d650513          	addi	a0,a0,214 # ffffffffc0207118 <default_pmm_manager+0xaa0>
ffffffffc020404a:	94afc0ef          	jal	ra,ffffffffc0200194 <cprintf>
        free_page(page);
ffffffffc020404e:	8526                	mv	a0,s1
ffffffffc0204050:	4585                	li	a1,1
ffffffffc0204052:	ef1fd0ef          	jal	ra,ffffffffc0201f42 <free_pages>
        return -E_INVAL;
ffffffffc0204056:	5575                	li	a0,-3
ffffffffc0204058:	bfe9                	j	ffffffffc0204032 <setup_pgdir+0x64>
ffffffffc020405a:	00002617          	auipc	a2,0x2
ffffffffc020405e:	65660613          	addi	a2,a2,1622 # ffffffffc02066b0 <default_pmm_manager+0x38>
ffffffffc0204062:	07100593          	li	a1,113
ffffffffc0204066:	00002517          	auipc	a0,0x2
ffffffffc020406a:	67250513          	addi	a0,a0,1650 # ffffffffc02066d8 <default_pmm_manager+0x60>
ffffffffc020406e:	c20fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204072 <proc_run>:
{
ffffffffc0204072:	7179                	addi	sp,sp,-48
ffffffffc0204074:	f026                	sd	s1,32(sp)
    if (proc != current)
ffffffffc0204076:	000a6497          	auipc	s1,0xa6
ffffffffc020407a:	66a48493          	addi	s1,s1,1642 # ffffffffc02aa6e0 <current>
ffffffffc020407e:	6098                	ld	a4,0(s1)
{
ffffffffc0204080:	f406                	sd	ra,40(sp)
ffffffffc0204082:	ec4a                	sd	s2,24(sp)
    if (proc != current)
ffffffffc0204084:	02a70763          	beq	a4,a0,ffffffffc02040b2 <proc_run+0x40>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204088:	100027f3          	csrr	a5,sstatus
ffffffffc020408c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020408e:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204090:	ef85                	bnez	a5,ffffffffc02040c8 <proc_run+0x56>
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned long pgdir)
{
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc0204092:	755c                	ld	a5,168(a0)
ffffffffc0204094:	56fd                	li	a3,-1
ffffffffc0204096:	16fe                	slli	a3,a3,0x3f
ffffffffc0204098:	83b1                	srli	a5,a5,0xc
            current = proc;
ffffffffc020409a:	e088                	sd	a0,0(s1)
ffffffffc020409c:	8fd5                	or	a5,a5,a3
ffffffffc020409e:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(proc->context));
ffffffffc02040a2:	03050593          	addi	a1,a0,48
ffffffffc02040a6:	03070513          	addi	a0,a4,48
ffffffffc02040aa:	7d9000ef          	jal	ra,ffffffffc0205082 <switch_to>
    if (flag)
ffffffffc02040ae:	00091763          	bnez	s2,ffffffffc02040bc <proc_run+0x4a>
}
ffffffffc02040b2:	70a2                	ld	ra,40(sp)
ffffffffc02040b4:	7482                	ld	s1,32(sp)
ffffffffc02040b6:	6962                	ld	s2,24(sp)
ffffffffc02040b8:	6145                	addi	sp,sp,48
ffffffffc02040ba:	8082                	ret
ffffffffc02040bc:	70a2                	ld	ra,40(sp)
ffffffffc02040be:	7482                	ld	s1,32(sp)
ffffffffc02040c0:	6962                	ld	s2,24(sp)
ffffffffc02040c2:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc02040c4:	8ebfc06f          	j	ffffffffc02009ae <intr_enable>
ffffffffc02040c8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02040ca:	8ebfc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
            struct proc_struct *prev = current;
ffffffffc02040ce:	6098                	ld	a4,0(s1)
        return 1;
ffffffffc02040d0:	6522                	ld	a0,8(sp)
ffffffffc02040d2:	4905                	li	s2,1
ffffffffc02040d4:	bf7d                	j	ffffffffc0204092 <proc_run+0x20>

ffffffffc02040d6 <do_fork>:
{
ffffffffc02040d6:	7159                	addi	sp,sp,-112
ffffffffc02040d8:	eca6                	sd	s1,88(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc02040da:	000a6497          	auipc	s1,0xa6
ffffffffc02040de:	61e48493          	addi	s1,s1,1566 # ffffffffc02aa6f8 <nr_process>
ffffffffc02040e2:	4098                	lw	a4,0(s1)
{
ffffffffc02040e4:	f486                	sd	ra,104(sp)
ffffffffc02040e6:	f0a2                	sd	s0,96(sp)
ffffffffc02040e8:	e8ca                	sd	s2,80(sp)
ffffffffc02040ea:	e4ce                	sd	s3,72(sp)
ffffffffc02040ec:	e0d2                	sd	s4,64(sp)
ffffffffc02040ee:	fc56                	sd	s5,56(sp)
ffffffffc02040f0:	f85a                	sd	s6,48(sp)
ffffffffc02040f2:	f45e                	sd	s7,40(sp)
ffffffffc02040f4:	f062                	sd	s8,32(sp)
ffffffffc02040f6:	ec66                	sd	s9,24(sp)
ffffffffc02040f8:	e86a                	sd	s10,16(sp)
ffffffffc02040fa:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc02040fc:	6785                	lui	a5,0x1
ffffffffc02040fe:	2cf75463          	bge	a4,a5,ffffffffc02043c6 <do_fork+0x2f0>
ffffffffc0204102:	8a2a                	mv	s4,a0
ffffffffc0204104:	892e                	mv	s2,a1
ffffffffc0204106:	89b2                	mv	s3,a2
    if ((proc = alloc_proc()) == NULL)
ffffffffc0204108:	d53ff0ef          	jal	ra,ffffffffc0203e5a <alloc_proc>
ffffffffc020410c:	842a                	mv	s0,a0
ffffffffc020410e:	2c050363          	beqz	a0,ffffffffc02043d4 <do_fork+0x2fe>
    proc->parent = current;
ffffffffc0204112:	000a6a97          	auipc	s5,0xa6
ffffffffc0204116:	5cea8a93          	addi	s5,s5,1486 # ffffffffc02aa6e0 <current>
ffffffffc020411a:	000ab783          	ld	a5,0(s5)
    assert(current->wait_state == 0);
ffffffffc020411e:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8abc>
    proc->parent = current;
ffffffffc0204122:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc0204124:	2a071f63          	bnez	a4,ffffffffc02043e2 <do_fork+0x30c>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204128:	4509                	li	a0,2
ffffffffc020412a:	ddbfd0ef          	jal	ra,ffffffffc0201f04 <alloc_pages>
    if (page != NULL)
ffffffffc020412e:	28050a63          	beqz	a0,ffffffffc02043c2 <do_fork+0x2ec>
    return page - pages + nbase;
ffffffffc0204132:	000a6b97          	auipc	s7,0xa6
ffffffffc0204136:	596b8b93          	addi	s7,s7,1430 # ffffffffc02aa6c8 <pages>
ffffffffc020413a:	000bb683          	ld	a3,0(s7)
ffffffffc020413e:	00004d17          	auipc	s10,0x4
ffffffffc0204142:	8f2d0d13          	addi	s10,s10,-1806 # ffffffffc0207a30 <nbase>
ffffffffc0204146:	000d3703          	ld	a4,0(s10)
ffffffffc020414a:	40d506b3          	sub	a3,a0,a3
ffffffffc020414e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204150:	000a6d97          	auipc	s11,0xa6
ffffffffc0204154:	570d8d93          	addi	s11,s11,1392 # ffffffffc02aa6c0 <npage>
    return page - pages + nbase;
ffffffffc0204158:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc020415a:	000db703          	ld	a4,0(s11)
ffffffffc020415e:	00c69793          	slli	a5,a3,0xc
ffffffffc0204162:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204164:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204166:	28e7fe63          	bgeu	a5,a4,ffffffffc0204402 <do_fork+0x32c>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc020416a:	000ab703          	ld	a4,0(s5)
ffffffffc020416e:	000a6b17          	auipc	s6,0xa6
ffffffffc0204172:	56ab0b13          	addi	s6,s6,1386 # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc0204176:	000b3783          	ld	a5,0(s6)
ffffffffc020417a:	02873a83          	ld	s5,40(a4)
ffffffffc020417e:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204180:	e814                	sd	a3,16(s0)
    if (oldmm == NULL)
ffffffffc0204182:	020a8863          	beqz	s5,ffffffffc02041b2 <do_fork+0xdc>
    if (clone_flags & CLONE_VM)
ffffffffc0204186:	100a7a13          	andi	s4,s4,256
ffffffffc020418a:	180a0963          	beqz	s4,ffffffffc020431c <do_fork+0x246>
}

static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
ffffffffc020418e:	030aa703          	lw	a4,48(s5)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204192:	018ab783          	ld	a5,24(s5)
ffffffffc0204196:	c02006b7          	lui	a3,0xc0200
ffffffffc020419a:	2705                	addiw	a4,a4,1
ffffffffc020419c:	02eaa823          	sw	a4,48(s5)
    proc->mm = mm;
ffffffffc02041a0:	03543423          	sd	s5,40(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc02041a4:	2ad7ef63          	bltu	a5,a3,ffffffffc0204462 <do_fork+0x38c>
ffffffffc02041a8:	000b3703          	ld	a4,0(s6)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02041ac:	6814                	ld	a3,16(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc02041ae:	8f99                	sub	a5,a5,a4
ffffffffc02041b0:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02041b2:	6789                	lui	a5,0x2
ffffffffc02041b4:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cc8>
ffffffffc02041b8:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc02041ba:	864e                	mv	a2,s3
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02041bc:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc02041be:	87b6                	mv	a5,a3
ffffffffc02041c0:	12098893          	addi	a7,s3,288
ffffffffc02041c4:	00063803          	ld	a6,0(a2)
ffffffffc02041c8:	6608                	ld	a0,8(a2)
ffffffffc02041ca:	6a0c                	ld	a1,16(a2)
ffffffffc02041cc:	6e18                	ld	a4,24(a2)
ffffffffc02041ce:	0107b023          	sd	a6,0(a5)
ffffffffc02041d2:	e788                	sd	a0,8(a5)
ffffffffc02041d4:	eb8c                	sd	a1,16(a5)
ffffffffc02041d6:	ef98                	sd	a4,24(a5)
ffffffffc02041d8:	02060613          	addi	a2,a2,32
ffffffffc02041dc:	02078793          	addi	a5,a5,32
ffffffffc02041e0:	ff1612e3          	bne	a2,a7,ffffffffc02041c4 <do_fork+0xee>
    proc->tf->gpr.a0 = 0;
ffffffffc02041e4:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x6>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02041e8:	18090763          	beqz	s2,ffffffffc0204376 <do_fork+0x2a0>
    if (++last_pid >= MAX_PID)
ffffffffc02041ec:	000a2817          	auipc	a6,0xa2
ffffffffc02041f0:	05c80813          	addi	a6,a6,92 # ffffffffc02a6248 <last_pid.1>
ffffffffc02041f4:	00082783          	lw	a5,0(a6)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02041f8:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02041fc:	00000717          	auipc	a4,0x0
ffffffffc0204200:	cd070713          	addi	a4,a4,-816 # ffffffffc0203ecc <forkret>
    if (++last_pid >= MAX_PID)
ffffffffc0204204:	0017851b          	addiw	a0,a5,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204208:	f818                	sd	a4,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020420a:	fc14                	sd	a3,56(s0)
    if (++last_pid >= MAX_PID)
ffffffffc020420c:	00a82023          	sw	a0,0(a6)
ffffffffc0204210:	6789                	lui	a5,0x2
ffffffffc0204212:	08f55e63          	bge	a0,a5,ffffffffc02042ae <do_fork+0x1d8>
    if (last_pid >= next_safe)
ffffffffc0204216:	000a2317          	auipc	t1,0xa2
ffffffffc020421a:	03630313          	addi	t1,t1,54 # ffffffffc02a624c <next_safe.0>
ffffffffc020421e:	00032783          	lw	a5,0(t1)
ffffffffc0204222:	000a6917          	auipc	s2,0xa6
ffffffffc0204226:	44690913          	addi	s2,s2,1094 # ffffffffc02aa668 <proc_list>
ffffffffc020422a:	08f55a63          	bge	a0,a5,ffffffffc02042be <do_fork+0x1e8>
    proc->pid = get_pid();
ffffffffc020422e:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204230:	45a9                	li	a1,10
ffffffffc0204232:	2501                	sext.w	a0,a0
ffffffffc0204234:	0cc010ef          	jal	ra,ffffffffc0205300 <hash32>
ffffffffc0204238:	02051793          	slli	a5,a0,0x20
ffffffffc020423c:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204240:	000a2797          	auipc	a5,0xa2
ffffffffc0204244:	42878793          	addi	a5,a5,1064 # ffffffffc02a6668 <hash_list>
ffffffffc0204248:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc020424a:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc020424c:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020424e:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc0204252:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0204254:	00893603          	ld	a2,8(s2)
    prev->next = next->prev = elm;
ffffffffc0204258:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc020425a:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc020425c:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc0204260:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc0204262:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc0204264:	e21c                	sd	a5,0(a2)
ffffffffc0204266:	00f93423          	sd	a5,8(s2)
    elm->next = next;
ffffffffc020426a:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc020426c:	0d243423          	sd	s2,200(s0)
    proc->yptr = NULL;
ffffffffc0204270:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204274:	10e43023          	sd	a4,256(s0)
ffffffffc0204278:	c311                	beqz	a4,ffffffffc020427c <do_fork+0x1a6>
        proc->optr->yptr = proc;
ffffffffc020427a:	ff60                	sd	s0,248(a4)
    nr_process++;
ffffffffc020427c:	409c                	lw	a5,0(s1)
    proc->parent->cptr = proc;
ffffffffc020427e:	fae0                	sd	s0,240(a3)
    wakeup_proc(proc);
ffffffffc0204280:	8522                	mv	a0,s0
    nr_process++;
ffffffffc0204282:	2785                	addiw	a5,a5,1
ffffffffc0204284:	c09c                	sw	a5,0(s1)
    wakeup_proc(proc);
ffffffffc0204286:	667000ef          	jal	ra,ffffffffc02050ec <wakeup_proc>
    ret = proc->pid;
ffffffffc020428a:	00442c03          	lw	s8,4(s0)
}
ffffffffc020428e:	70a6                	ld	ra,104(sp)
ffffffffc0204290:	7406                	ld	s0,96(sp)
ffffffffc0204292:	64e6                	ld	s1,88(sp)
ffffffffc0204294:	6946                	ld	s2,80(sp)
ffffffffc0204296:	69a6                	ld	s3,72(sp)
ffffffffc0204298:	6a06                	ld	s4,64(sp)
ffffffffc020429a:	7ae2                	ld	s5,56(sp)
ffffffffc020429c:	7b42                	ld	s6,48(sp)
ffffffffc020429e:	7ba2                	ld	s7,40(sp)
ffffffffc02042a0:	6ce2                	ld	s9,24(sp)
ffffffffc02042a2:	6d42                	ld	s10,16(sp)
ffffffffc02042a4:	6da2                	ld	s11,8(sp)
ffffffffc02042a6:	8562                	mv	a0,s8
ffffffffc02042a8:	7c02                	ld	s8,32(sp)
ffffffffc02042aa:	6165                	addi	sp,sp,112
ffffffffc02042ac:	8082                	ret
        last_pid = 1;
ffffffffc02042ae:	4785                	li	a5,1
ffffffffc02042b0:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc02042b4:	4505                	li	a0,1
ffffffffc02042b6:	000a2317          	auipc	t1,0xa2
ffffffffc02042ba:	f9630313          	addi	t1,t1,-106 # ffffffffc02a624c <next_safe.0>
    return listelm->next;
ffffffffc02042be:	000a6917          	auipc	s2,0xa6
ffffffffc02042c2:	3aa90913          	addi	s2,s2,938 # ffffffffc02aa668 <proc_list>
ffffffffc02042c6:	00893e03          	ld	t3,8(s2)
        next_safe = MAX_PID;
ffffffffc02042ca:	6789                	lui	a5,0x2
ffffffffc02042cc:	00f32023          	sw	a5,0(t1)
ffffffffc02042d0:	86aa                	mv	a3,a0
ffffffffc02042d2:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc02042d4:	6e89                	lui	t4,0x2
ffffffffc02042d6:	0f2e0a63          	beq	t3,s2,ffffffffc02043ca <do_fork+0x2f4>
ffffffffc02042da:	88ae                	mv	a7,a1
ffffffffc02042dc:	87f2                	mv	a5,t3
ffffffffc02042de:	6609                	lui	a2,0x2
ffffffffc02042e0:	a811                	j	ffffffffc02042f4 <do_fork+0x21e>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc02042e2:	00e6d663          	bge	a3,a4,ffffffffc02042ee <do_fork+0x218>
ffffffffc02042e6:	00c75463          	bge	a4,a2,ffffffffc02042ee <do_fork+0x218>
ffffffffc02042ea:	863a                	mv	a2,a4
ffffffffc02042ec:	4885                	li	a7,1
ffffffffc02042ee:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02042f0:	01278d63          	beq	a5,s2,ffffffffc020430a <do_fork+0x234>
            if (proc->pid == last_pid)
ffffffffc02042f4:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c6c>
ffffffffc02042f8:	fed715e3          	bne	a4,a3,ffffffffc02042e2 <do_fork+0x20c>
                if (++last_pid >= next_safe)
ffffffffc02042fc:	2685                	addiw	a3,a3,1
ffffffffc02042fe:	0ac6dd63          	bge	a3,a2,ffffffffc02043b8 <do_fork+0x2e2>
ffffffffc0204302:	679c                	ld	a5,8(a5)
ffffffffc0204304:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc0204306:	ff2797e3          	bne	a5,s2,ffffffffc02042f4 <do_fork+0x21e>
ffffffffc020430a:	c581                	beqz	a1,ffffffffc0204312 <do_fork+0x23c>
ffffffffc020430c:	00d82023          	sw	a3,0(a6)
ffffffffc0204310:	8536                	mv	a0,a3
ffffffffc0204312:	f0088ee3          	beqz	a7,ffffffffc020422e <do_fork+0x158>
ffffffffc0204316:	00c32023          	sw	a2,0(t1)
ffffffffc020431a:	bf11                	j	ffffffffc020422e <do_fork+0x158>
    if ((mm = mm_create()) == NULL)
ffffffffc020431c:	c2cff0ef          	jal	ra,ffffffffc0203748 <mm_create>
ffffffffc0204320:	8caa                	mv	s9,a0
ffffffffc0204322:	cd55                	beqz	a0,ffffffffc02043de <do_fork+0x308>
    if (setup_pgdir(mm) != 0)
ffffffffc0204324:	cabff0ef          	jal	ra,ffffffffc0203fce <setup_pgdir>
ffffffffc0204328:	e929                	bnez	a0,ffffffffc020437a <do_fork+0x2a4>
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
ffffffffc020432a:	038a8a13          	addi	s4,s5,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020432e:	4785                	li	a5,1
ffffffffc0204330:	40fa37af          	amoor.d	a5,a5,(s4)
}

static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))
ffffffffc0204334:	8b85                	andi	a5,a5,1
ffffffffc0204336:	4c05                	li	s8,1
ffffffffc0204338:	c799                	beqz	a5,ffffffffc0204346 <do_fork+0x270>
    {
        schedule();
ffffffffc020433a:	633000ef          	jal	ra,ffffffffc020516c <schedule>
ffffffffc020433e:	418a37af          	amoor.d	a5,s8,(s4)
    while (!try_lock(lock))
ffffffffc0204342:	8b85                	andi	a5,a5,1
ffffffffc0204344:	fbfd                	bnez	a5,ffffffffc020433a <do_fork+0x264>
        ret = dup_mmap(mm, oldmm);
ffffffffc0204346:	85d6                	mv	a1,s5
ffffffffc0204348:	8566                	mv	a0,s9
ffffffffc020434a:	e40ff0ef          	jal	ra,ffffffffc020398a <dup_mmap>
ffffffffc020434e:	8c2a                	mv	s8,a0
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0204350:	57f9                	li	a5,-2
ffffffffc0204352:	60fa37af          	amoand.d	a5,a5,(s4)
ffffffffc0204356:	8b85                	andi	a5,a5,1
}

static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))
ffffffffc0204358:	0e078963          	beqz	a5,ffffffffc020444a <do_fork+0x374>
good_mm:
ffffffffc020435c:	8ae6                	mv	s5,s9
    if (ret != 0)
ffffffffc020435e:	e20508e3          	beqz	a0,ffffffffc020418e <do_fork+0xb8>
    exit_mmap(mm);
ffffffffc0204362:	8566                	mv	a0,s9
ffffffffc0204364:	ec0ff0ef          	jal	ra,ffffffffc0203a24 <exit_mmap>
    put_pgdir(mm);
ffffffffc0204368:	8566                	mv	a0,s9
ffffffffc020436a:	befff0ef          	jal	ra,ffffffffc0203f58 <put_pgdir>
    mm_destroy(mm);
ffffffffc020436e:	8566                	mv	a0,s9
ffffffffc0204370:	d18ff0ef          	jal	ra,ffffffffc0203888 <mm_destroy>
ffffffffc0204374:	a039                	j	ffffffffc0204382 <do_fork+0x2ac>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204376:	8936                	mv	s2,a3
ffffffffc0204378:	bd95                	j	ffffffffc02041ec <do_fork+0x116>
    mm_destroy(mm);
ffffffffc020437a:	8566                	mv	a0,s9
ffffffffc020437c:	d0cff0ef          	jal	ra,ffffffffc0203888 <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0204380:	5c71                	li	s8,-4
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204382:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0204384:	c02007b7          	lui	a5,0xc0200
ffffffffc0204388:	0af6e563          	bltu	a3,a5,ffffffffc0204432 <do_fork+0x35c>
ffffffffc020438c:	000b3703          	ld	a4,0(s6)
    if (PPN(pa) >= npage)
ffffffffc0204390:	000db783          	ld	a5,0(s11)
    return pa2page(PADDR(kva));
ffffffffc0204394:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage)
ffffffffc0204396:	82b1                	srli	a3,a3,0xc
ffffffffc0204398:	08f6f163          	bgeu	a3,a5,ffffffffc020441a <do_fork+0x344>
    return &pages[PPN(pa) - nbase];
ffffffffc020439c:	000d3783          	ld	a5,0(s10)
ffffffffc02043a0:	000bb503          	ld	a0,0(s7)
ffffffffc02043a4:	4589                	li	a1,2
ffffffffc02043a6:	8e9d                	sub	a3,a3,a5
ffffffffc02043a8:	069a                	slli	a3,a3,0x6
ffffffffc02043aa:	9536                	add	a0,a0,a3
ffffffffc02043ac:	b97fd0ef          	jal	ra,ffffffffc0201f42 <free_pages>
    kfree(proc);
ffffffffc02043b0:	8522                	mv	a0,s0
ffffffffc02043b2:	a25fd0ef          	jal	ra,ffffffffc0201dd6 <kfree>
    return ret;
ffffffffc02043b6:	bde1                	j	ffffffffc020428e <do_fork+0x1b8>
                    if (last_pid >= MAX_PID)
ffffffffc02043b8:	01d6c363          	blt	a3,t4,ffffffffc02043be <do_fork+0x2e8>
                        last_pid = 1;
ffffffffc02043bc:	4685                	li	a3,1
                    goto repeat;
ffffffffc02043be:	4585                	li	a1,1
ffffffffc02043c0:	bf19                	j	ffffffffc02042d6 <do_fork+0x200>
    return -E_NO_MEM;
ffffffffc02043c2:	5c71                	li	s8,-4
ffffffffc02043c4:	b7f5                	j	ffffffffc02043b0 <do_fork+0x2da>
    int ret = -E_NO_FREE_PROC;
ffffffffc02043c6:	5c6d                	li	s8,-5
ffffffffc02043c8:	b5d9                	j	ffffffffc020428e <do_fork+0x1b8>
ffffffffc02043ca:	c599                	beqz	a1,ffffffffc02043d8 <do_fork+0x302>
ffffffffc02043cc:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc02043d0:	8536                	mv	a0,a3
ffffffffc02043d2:	bdb1                	j	ffffffffc020422e <do_fork+0x158>
    ret = -E_NO_MEM;
ffffffffc02043d4:	5c71                	li	s8,-4
ffffffffc02043d6:	bd65                	j	ffffffffc020428e <do_fork+0x1b8>
    return last_pid;
ffffffffc02043d8:	00082503          	lw	a0,0(a6)
ffffffffc02043dc:	bd89                	j	ffffffffc020422e <do_fork+0x158>
    int ret = -E_NO_MEM;
ffffffffc02043de:	5c71                	li	s8,-4
ffffffffc02043e0:	b74d                	j	ffffffffc0204382 <do_fork+0x2ac>
    assert(current->wait_state == 0);
ffffffffc02043e2:	00003697          	auipc	a3,0x3
ffffffffc02043e6:	d6668693          	addi	a3,a3,-666 # ffffffffc0207148 <default_pmm_manager+0xad0>
ffffffffc02043ea:	00002617          	auipc	a2,0x2
ffffffffc02043ee:	ede60613          	addi	a2,a2,-290 # ffffffffc02062c8 <commands+0x890>
ffffffffc02043f2:	1e600593          	li	a1,486
ffffffffc02043f6:	00003517          	auipc	a0,0x3
ffffffffc02043fa:	d0a50513          	addi	a0,a0,-758 # ffffffffc0207100 <default_pmm_manager+0xa88>
ffffffffc02043fe:	890fc0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc0204402:	00002617          	auipc	a2,0x2
ffffffffc0204406:	2ae60613          	addi	a2,a2,686 # ffffffffc02066b0 <default_pmm_manager+0x38>
ffffffffc020440a:	07100593          	li	a1,113
ffffffffc020440e:	00002517          	auipc	a0,0x2
ffffffffc0204412:	2ca50513          	addi	a0,a0,714 # ffffffffc02066d8 <default_pmm_manager+0x60>
ffffffffc0204416:	878fc0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020441a:	00002617          	auipc	a2,0x2
ffffffffc020441e:	36660613          	addi	a2,a2,870 # ffffffffc0206780 <default_pmm_manager+0x108>
ffffffffc0204422:	06900593          	li	a1,105
ffffffffc0204426:	00002517          	auipc	a0,0x2
ffffffffc020442a:	2b250513          	addi	a0,a0,690 # ffffffffc02066d8 <default_pmm_manager+0x60>
ffffffffc020442e:	860fc0ef          	jal	ra,ffffffffc020048e <__panic>
    return pa2page(PADDR(kva));
ffffffffc0204432:	00002617          	auipc	a2,0x2
ffffffffc0204436:	32660613          	addi	a2,a2,806 # ffffffffc0206758 <default_pmm_manager+0xe0>
ffffffffc020443a:	07700593          	li	a1,119
ffffffffc020443e:	00002517          	auipc	a0,0x2
ffffffffc0204442:	29a50513          	addi	a0,a0,666 # ffffffffc02066d8 <default_pmm_manager+0x60>
ffffffffc0204446:	848fc0ef          	jal	ra,ffffffffc020048e <__panic>
    {
        panic("Unlock failed.\n");
ffffffffc020444a:	00003617          	auipc	a2,0x3
ffffffffc020444e:	d1e60613          	addi	a2,a2,-738 # ffffffffc0207168 <default_pmm_manager+0xaf0>
ffffffffc0204452:	03f00593          	li	a1,63
ffffffffc0204456:	00003517          	auipc	a0,0x3
ffffffffc020445a:	d2250513          	addi	a0,a0,-734 # ffffffffc0207178 <default_pmm_manager+0xb00>
ffffffffc020445e:	830fc0ef          	jal	ra,ffffffffc020048e <__panic>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204462:	86be                	mv	a3,a5
ffffffffc0204464:	00002617          	auipc	a2,0x2
ffffffffc0204468:	2f460613          	addi	a2,a2,756 # ffffffffc0206758 <default_pmm_manager+0xe0>
ffffffffc020446c:	19300593          	li	a1,403
ffffffffc0204470:	00003517          	auipc	a0,0x3
ffffffffc0204474:	c9050513          	addi	a0,a0,-880 # ffffffffc0207100 <default_pmm_manager+0xa88>
ffffffffc0204478:	816fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020447c <kernel_thread>:
{
ffffffffc020447c:	7129                	addi	sp,sp,-320
ffffffffc020447e:	fa22                	sd	s0,304(sp)
ffffffffc0204480:	f626                	sd	s1,296(sp)
ffffffffc0204482:	f24a                	sd	s2,288(sp)
ffffffffc0204484:	84ae                	mv	s1,a1
ffffffffc0204486:	892a                	mv	s2,a0
ffffffffc0204488:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020448a:	4581                	li	a1,0
ffffffffc020448c:	12000613          	li	a2,288
ffffffffc0204490:	850a                	mv	a0,sp
{
ffffffffc0204492:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204494:	312010ef          	jal	ra,ffffffffc02057a6 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0204498:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc020449a:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc020449c:	100027f3          	csrr	a5,sstatus
ffffffffc02044a0:	edd7f793          	andi	a5,a5,-291
ffffffffc02044a4:	1207e793          	ori	a5,a5,288
ffffffffc02044a8:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02044aa:	860a                	mv	a2,sp
ffffffffc02044ac:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02044b0:	00000797          	auipc	a5,0x0
ffffffffc02044b4:	9a278793          	addi	a5,a5,-1630 # ffffffffc0203e52 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02044b8:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02044ba:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02044bc:	c1bff0ef          	jal	ra,ffffffffc02040d6 <do_fork>
}
ffffffffc02044c0:	70f2                	ld	ra,312(sp)
ffffffffc02044c2:	7452                	ld	s0,304(sp)
ffffffffc02044c4:	74b2                	ld	s1,296(sp)
ffffffffc02044c6:	7912                	ld	s2,288(sp)
ffffffffc02044c8:	6131                	addi	sp,sp,320
ffffffffc02044ca:	8082                	ret

ffffffffc02044cc <do_exit>:
{
ffffffffc02044cc:	7179                	addi	sp,sp,-48
ffffffffc02044ce:	f022                	sd	s0,32(sp)
    if (current == idleproc)
ffffffffc02044d0:	000a6417          	auipc	s0,0xa6
ffffffffc02044d4:	21040413          	addi	s0,s0,528 # ffffffffc02aa6e0 <current>
ffffffffc02044d8:	601c                	ld	a5,0(s0)
{
ffffffffc02044da:	f406                	sd	ra,40(sp)
ffffffffc02044dc:	ec26                	sd	s1,24(sp)
ffffffffc02044de:	e84a                	sd	s2,16(sp)
ffffffffc02044e0:	e44e                	sd	s3,8(sp)
ffffffffc02044e2:	e052                	sd	s4,0(sp)
    if (current == idleproc)
ffffffffc02044e4:	000a6717          	auipc	a4,0xa6
ffffffffc02044e8:	20473703          	ld	a4,516(a4) # ffffffffc02aa6e8 <idleproc>
ffffffffc02044ec:	0ce78c63          	beq	a5,a4,ffffffffc02045c4 <do_exit+0xf8>
    if (current == initproc)
ffffffffc02044f0:	000a6497          	auipc	s1,0xa6
ffffffffc02044f4:	20048493          	addi	s1,s1,512 # ffffffffc02aa6f0 <initproc>
ffffffffc02044f8:	6098                	ld	a4,0(s1)
ffffffffc02044fa:	0ee78b63          	beq	a5,a4,ffffffffc02045f0 <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc02044fe:	0287b983          	ld	s3,40(a5)
ffffffffc0204502:	892a                	mv	s2,a0
    if (mm != NULL)
ffffffffc0204504:	02098663          	beqz	s3,ffffffffc0204530 <do_exit+0x64>
ffffffffc0204508:	000a6797          	auipc	a5,0xa6
ffffffffc020450c:	1a87b783          	ld	a5,424(a5) # ffffffffc02aa6b0 <boot_pgdir_pa>
ffffffffc0204510:	577d                	li	a4,-1
ffffffffc0204512:	177e                	slli	a4,a4,0x3f
ffffffffc0204514:	83b1                	srli	a5,a5,0xc
ffffffffc0204516:	8fd9                	or	a5,a5,a4
ffffffffc0204518:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc020451c:	0309a783          	lw	a5,48(s3)
ffffffffc0204520:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204524:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0)
ffffffffc0204528:	cb55                	beqz	a4,ffffffffc02045dc <do_exit+0x110>
        current->mm = NULL;
ffffffffc020452a:	601c                	ld	a5,0(s0)
ffffffffc020452c:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0204530:	601c                	ld	a5,0(s0)
ffffffffc0204532:	470d                	li	a4,3
ffffffffc0204534:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0204536:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020453a:	100027f3          	csrr	a5,sstatus
ffffffffc020453e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204540:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204542:	e3f9                	bnez	a5,ffffffffc0204608 <do_exit+0x13c>
        proc = current->parent;
ffffffffc0204544:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204546:	800007b7          	lui	a5,0x80000
ffffffffc020454a:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc020454c:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc020454e:	0ec52703          	lw	a4,236(a0)
ffffffffc0204552:	0af70f63          	beq	a4,a5,ffffffffc0204610 <do_exit+0x144>
        while (current->cptr != NULL)
ffffffffc0204556:	6018                	ld	a4,0(s0)
ffffffffc0204558:	7b7c                	ld	a5,240(a4)
ffffffffc020455a:	c3a1                	beqz	a5,ffffffffc020459a <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD)
ffffffffc020455c:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204560:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204562:	0985                	addi	s3,s3,1
ffffffffc0204564:	a021                	j	ffffffffc020456c <do_exit+0xa0>
        while (current->cptr != NULL)
ffffffffc0204566:	6018                	ld	a4,0(s0)
ffffffffc0204568:	7b7c                	ld	a5,240(a4)
ffffffffc020456a:	cb85                	beqz	a5,ffffffffc020459a <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc020456c:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fe8>
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204570:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc0204572:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204574:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0204576:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc020457a:	10e7b023          	sd	a4,256(a5)
ffffffffc020457e:	c311                	beqz	a4,ffffffffc0204582 <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc0204580:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204582:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0204584:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0204586:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204588:	fd271fe3          	bne	a4,s2,ffffffffc0204566 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc020458c:	0ec52783          	lw	a5,236(a0)
ffffffffc0204590:	fd379be3          	bne	a5,s3,ffffffffc0204566 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc0204594:	359000ef          	jal	ra,ffffffffc02050ec <wakeup_proc>
ffffffffc0204598:	b7f9                	j	ffffffffc0204566 <do_exit+0x9a>
    if (flag)
ffffffffc020459a:	020a1263          	bnez	s4,ffffffffc02045be <do_exit+0xf2>
    schedule();
ffffffffc020459e:	3cf000ef          	jal	ra,ffffffffc020516c <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc02045a2:	601c                	ld	a5,0(s0)
ffffffffc02045a4:	00003617          	auipc	a2,0x3
ffffffffc02045a8:	c0c60613          	addi	a2,a2,-1012 # ffffffffc02071b0 <default_pmm_manager+0xb38>
ffffffffc02045ac:	24200593          	li	a1,578
ffffffffc02045b0:	43d4                	lw	a3,4(a5)
ffffffffc02045b2:	00003517          	auipc	a0,0x3
ffffffffc02045b6:	b4e50513          	addi	a0,a0,-1202 # ffffffffc0207100 <default_pmm_manager+0xa88>
ffffffffc02045ba:	ed5fb0ef          	jal	ra,ffffffffc020048e <__panic>
        intr_enable();
ffffffffc02045be:	bf0fc0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02045c2:	bff1                	j	ffffffffc020459e <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc02045c4:	00003617          	auipc	a2,0x3
ffffffffc02045c8:	bcc60613          	addi	a2,a2,-1076 # ffffffffc0207190 <default_pmm_manager+0xb18>
ffffffffc02045cc:	20e00593          	li	a1,526
ffffffffc02045d0:	00003517          	auipc	a0,0x3
ffffffffc02045d4:	b3050513          	addi	a0,a0,-1232 # ffffffffc0207100 <default_pmm_manager+0xa88>
ffffffffc02045d8:	eb7fb0ef          	jal	ra,ffffffffc020048e <__panic>
            exit_mmap(mm);
ffffffffc02045dc:	854e                	mv	a0,s3
ffffffffc02045de:	c46ff0ef          	jal	ra,ffffffffc0203a24 <exit_mmap>
            put_pgdir(mm);
ffffffffc02045e2:	854e                	mv	a0,s3
ffffffffc02045e4:	975ff0ef          	jal	ra,ffffffffc0203f58 <put_pgdir>
            mm_destroy(mm);
ffffffffc02045e8:	854e                	mv	a0,s3
ffffffffc02045ea:	a9eff0ef          	jal	ra,ffffffffc0203888 <mm_destroy>
ffffffffc02045ee:	bf35                	j	ffffffffc020452a <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc02045f0:	00003617          	auipc	a2,0x3
ffffffffc02045f4:	bb060613          	addi	a2,a2,-1104 # ffffffffc02071a0 <default_pmm_manager+0xb28>
ffffffffc02045f8:	21200593          	li	a1,530
ffffffffc02045fc:	00003517          	auipc	a0,0x3
ffffffffc0204600:	b0450513          	addi	a0,a0,-1276 # ffffffffc0207100 <default_pmm_manager+0xa88>
ffffffffc0204604:	e8bfb0ef          	jal	ra,ffffffffc020048e <__panic>
        intr_disable();
ffffffffc0204608:	bacfc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc020460c:	4a05                	li	s4,1
ffffffffc020460e:	bf1d                	j	ffffffffc0204544 <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc0204610:	2dd000ef          	jal	ra,ffffffffc02050ec <wakeup_proc>
ffffffffc0204614:	b789                	j	ffffffffc0204556 <do_exit+0x8a>

ffffffffc0204616 <do_wait.part.0>:
int do_wait(int pid, int *code_store)
ffffffffc0204616:	715d                	addi	sp,sp,-80
ffffffffc0204618:	f84a                	sd	s2,48(sp)
ffffffffc020461a:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc020461c:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID)
ffffffffc0204620:	6989                	lui	s3,0x2
int do_wait(int pid, int *code_store)
ffffffffc0204622:	fc26                	sd	s1,56(sp)
ffffffffc0204624:	f052                	sd	s4,32(sp)
ffffffffc0204626:	ec56                	sd	s5,24(sp)
ffffffffc0204628:	e85a                	sd	s6,16(sp)
ffffffffc020462a:	e45e                	sd	s7,8(sp)
ffffffffc020462c:	e486                	sd	ra,72(sp)
ffffffffc020462e:	e0a2                	sd	s0,64(sp)
ffffffffc0204630:	84aa                	mv	s1,a0
ffffffffc0204632:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc0204634:	000a6b97          	auipc	s7,0xa6
ffffffffc0204638:	0acb8b93          	addi	s7,s7,172 # ffffffffc02aa6e0 <current>
    if (0 < pid && pid < MAX_PID)
ffffffffc020463c:	00050b1b          	sext.w	s6,a0
ffffffffc0204640:	fff50a9b          	addiw	s5,a0,-1
ffffffffc0204644:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc0204646:	0905                	addi	s2,s2,1
    if (pid != 0)
ffffffffc0204648:	ccbd                	beqz	s1,ffffffffc02046c6 <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID)
ffffffffc020464a:	0359e863          	bltu	s3,s5,ffffffffc020467a <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020464e:	45a9                	li	a1,10
ffffffffc0204650:	855a                	mv	a0,s6
ffffffffc0204652:	4af000ef          	jal	ra,ffffffffc0205300 <hash32>
ffffffffc0204656:	02051793          	slli	a5,a0,0x20
ffffffffc020465a:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020465e:	000a2797          	auipc	a5,0xa2
ffffffffc0204662:	00a78793          	addi	a5,a5,10 # ffffffffc02a6668 <hash_list>
ffffffffc0204666:	953e                	add	a0,a0,a5
ffffffffc0204668:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list)
ffffffffc020466a:	a029                	j	ffffffffc0204674 <do_wait.part.0+0x5e>
            if (proc->pid == pid)
ffffffffc020466c:	f2c42783          	lw	a5,-212(s0)
ffffffffc0204670:	02978163          	beq	a5,s1,ffffffffc0204692 <do_wait.part.0+0x7c>
ffffffffc0204674:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list)
ffffffffc0204676:	fe851be3          	bne	a0,s0,ffffffffc020466c <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc020467a:	5579                	li	a0,-2
}
ffffffffc020467c:	60a6                	ld	ra,72(sp)
ffffffffc020467e:	6406                	ld	s0,64(sp)
ffffffffc0204680:	74e2                	ld	s1,56(sp)
ffffffffc0204682:	7942                	ld	s2,48(sp)
ffffffffc0204684:	79a2                	ld	s3,40(sp)
ffffffffc0204686:	7a02                	ld	s4,32(sp)
ffffffffc0204688:	6ae2                	ld	s5,24(sp)
ffffffffc020468a:	6b42                	ld	s6,16(sp)
ffffffffc020468c:	6ba2                	ld	s7,8(sp)
ffffffffc020468e:	6161                	addi	sp,sp,80
ffffffffc0204690:	8082                	ret
        if (proc != NULL && proc->parent == current)
ffffffffc0204692:	000bb683          	ld	a3,0(s7)
ffffffffc0204696:	f4843783          	ld	a5,-184(s0)
ffffffffc020469a:	fed790e3          	bne	a5,a3,ffffffffc020467a <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc020469e:	f2842703          	lw	a4,-216(s0)
ffffffffc02046a2:	478d                	li	a5,3
ffffffffc02046a4:	0ef70b63          	beq	a4,a5,ffffffffc020479a <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc02046a8:	4785                	li	a5,1
ffffffffc02046aa:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc02046ac:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc02046b0:	2bd000ef          	jal	ra,ffffffffc020516c <schedule>
        if (current->flags & PF_EXITING)
ffffffffc02046b4:	000bb783          	ld	a5,0(s7)
ffffffffc02046b8:	0b07a783          	lw	a5,176(a5)
ffffffffc02046bc:	8b85                	andi	a5,a5,1
ffffffffc02046be:	d7c9                	beqz	a5,ffffffffc0204648 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc02046c0:	555d                	li	a0,-9
ffffffffc02046c2:	e0bff0ef          	jal	ra,ffffffffc02044cc <do_exit>
        proc = current->cptr;
ffffffffc02046c6:	000bb683          	ld	a3,0(s7)
ffffffffc02046ca:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr)
ffffffffc02046cc:	d45d                	beqz	s0,ffffffffc020467a <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02046ce:	470d                	li	a4,3
ffffffffc02046d0:	a021                	j	ffffffffc02046d8 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr)
ffffffffc02046d2:	10043403          	ld	s0,256(s0)
ffffffffc02046d6:	d869                	beqz	s0,ffffffffc02046a8 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02046d8:	401c                	lw	a5,0(s0)
ffffffffc02046da:	fee79ce3          	bne	a5,a4,ffffffffc02046d2 <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc)
ffffffffc02046de:	000a6797          	auipc	a5,0xa6
ffffffffc02046e2:	00a7b783          	ld	a5,10(a5) # ffffffffc02aa6e8 <idleproc>
ffffffffc02046e6:	0c878963          	beq	a5,s0,ffffffffc02047b8 <do_wait.part.0+0x1a2>
ffffffffc02046ea:	000a6797          	auipc	a5,0xa6
ffffffffc02046ee:	0067b783          	ld	a5,6(a5) # ffffffffc02aa6f0 <initproc>
ffffffffc02046f2:	0cf40363          	beq	s0,a5,ffffffffc02047b8 <do_wait.part.0+0x1a2>
    if (code_store != NULL)
ffffffffc02046f6:	000a0663          	beqz	s4,ffffffffc0204702 <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc02046fa:	0e842783          	lw	a5,232(s0)
ffffffffc02046fe:	00fa2023          	sw	a5,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8ba8>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204702:	100027f3          	csrr	a5,sstatus
ffffffffc0204706:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204708:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020470a:	e7c1                	bnez	a5,ffffffffc0204792 <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc020470c:	6c70                	ld	a2,216(s0)
ffffffffc020470e:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL)
ffffffffc0204710:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc0204714:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0204716:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0204718:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020471a:	6470                	ld	a2,200(s0)
ffffffffc020471c:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc020471e:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0204720:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL)
ffffffffc0204722:	c319                	beqz	a4,ffffffffc0204728 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc0204724:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL)
ffffffffc0204726:	7c7c                	ld	a5,248(s0)
ffffffffc0204728:	c3b5                	beqz	a5,ffffffffc020478c <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc020472a:	10e7b023          	sd	a4,256(a5)
    nr_process--;
ffffffffc020472e:	000a6717          	auipc	a4,0xa6
ffffffffc0204732:	fca70713          	addi	a4,a4,-54 # ffffffffc02aa6f8 <nr_process>
ffffffffc0204736:	431c                	lw	a5,0(a4)
ffffffffc0204738:	37fd                	addiw	a5,a5,-1
ffffffffc020473a:	c31c                	sw	a5,0(a4)
    if (flag)
ffffffffc020473c:	e5a9                	bnez	a1,ffffffffc0204786 <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020473e:	6814                	ld	a3,16(s0)
ffffffffc0204740:	c02007b7          	lui	a5,0xc0200
ffffffffc0204744:	04f6ee63          	bltu	a3,a5,ffffffffc02047a0 <do_wait.part.0+0x18a>
ffffffffc0204748:	000a6797          	auipc	a5,0xa6
ffffffffc020474c:	f907b783          	ld	a5,-112(a5) # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc0204750:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage)
ffffffffc0204752:	82b1                	srli	a3,a3,0xc
ffffffffc0204754:	000a6797          	auipc	a5,0xa6
ffffffffc0204758:	f6c7b783          	ld	a5,-148(a5) # ffffffffc02aa6c0 <npage>
ffffffffc020475c:	06f6fa63          	bgeu	a3,a5,ffffffffc02047d0 <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0204760:	00003517          	auipc	a0,0x3
ffffffffc0204764:	2d053503          	ld	a0,720(a0) # ffffffffc0207a30 <nbase>
ffffffffc0204768:	8e89                	sub	a3,a3,a0
ffffffffc020476a:	069a                	slli	a3,a3,0x6
ffffffffc020476c:	000a6517          	auipc	a0,0xa6
ffffffffc0204770:	f5c53503          	ld	a0,-164(a0) # ffffffffc02aa6c8 <pages>
ffffffffc0204774:	9536                	add	a0,a0,a3
ffffffffc0204776:	4589                	li	a1,2
ffffffffc0204778:	fcafd0ef          	jal	ra,ffffffffc0201f42 <free_pages>
    kfree(proc);
ffffffffc020477c:	8522                	mv	a0,s0
ffffffffc020477e:	e58fd0ef          	jal	ra,ffffffffc0201dd6 <kfree>
    return 0;
ffffffffc0204782:	4501                	li	a0,0
ffffffffc0204784:	bde5                	j	ffffffffc020467c <do_wait.part.0+0x66>
        intr_enable();
ffffffffc0204786:	a28fc0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020478a:	bf55                	j	ffffffffc020473e <do_wait.part.0+0x128>
        proc->parent->cptr = proc->optr;
ffffffffc020478c:	701c                	ld	a5,32(s0)
ffffffffc020478e:	fbf8                	sd	a4,240(a5)
ffffffffc0204790:	bf79                	j	ffffffffc020472e <do_wait.part.0+0x118>
        intr_disable();
ffffffffc0204792:	a22fc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc0204796:	4585                	li	a1,1
ffffffffc0204798:	bf95                	j	ffffffffc020470c <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020479a:	f2840413          	addi	s0,s0,-216
ffffffffc020479e:	b781                	j	ffffffffc02046de <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc02047a0:	00002617          	auipc	a2,0x2
ffffffffc02047a4:	fb860613          	addi	a2,a2,-72 # ffffffffc0206758 <default_pmm_manager+0xe0>
ffffffffc02047a8:	07700593          	li	a1,119
ffffffffc02047ac:	00002517          	auipc	a0,0x2
ffffffffc02047b0:	f2c50513          	addi	a0,a0,-212 # ffffffffc02066d8 <default_pmm_manager+0x60>
ffffffffc02047b4:	cdbfb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc02047b8:	00003617          	auipc	a2,0x3
ffffffffc02047bc:	a1860613          	addi	a2,a2,-1512 # ffffffffc02071d0 <default_pmm_manager+0xb58>
ffffffffc02047c0:	36300593          	li	a1,867
ffffffffc02047c4:	00003517          	auipc	a0,0x3
ffffffffc02047c8:	93c50513          	addi	a0,a0,-1732 # ffffffffc0207100 <default_pmm_manager+0xa88>
ffffffffc02047cc:	cc3fb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02047d0:	00002617          	auipc	a2,0x2
ffffffffc02047d4:	fb060613          	addi	a2,a2,-80 # ffffffffc0206780 <default_pmm_manager+0x108>
ffffffffc02047d8:	06900593          	li	a1,105
ffffffffc02047dc:	00002517          	auipc	a0,0x2
ffffffffc02047e0:	efc50513          	addi	a0,a0,-260 # ffffffffc02066d8 <default_pmm_manager+0x60>
ffffffffc02047e4:	cabfb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02047e8 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc02047e8:	1141                	addi	sp,sp,-16
ffffffffc02047ea:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02047ec:	f96fd0ef          	jal	ra,ffffffffc0201f82 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02047f0:	d32fd0ef          	jal	ra,ffffffffc0201d22 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02047f4:	4601                	li	a2,0
ffffffffc02047f6:	4581                	li	a1,0
ffffffffc02047f8:	fffff517          	auipc	a0,0xfffff
ffffffffc02047fc:	6e250513          	addi	a0,a0,1762 # ffffffffc0203eda <user_main>
ffffffffc0204800:	c7dff0ef          	jal	ra,ffffffffc020447c <kernel_thread>
    if (pid <= 0)
ffffffffc0204804:	00a04563          	bgtz	a0,ffffffffc020480e <init_main+0x26>
ffffffffc0204808:	a071                	j	ffffffffc0204894 <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
ffffffffc020480a:	163000ef          	jal	ra,ffffffffc020516c <schedule>
    if (code_store != NULL)
ffffffffc020480e:	4581                	li	a1,0
ffffffffc0204810:	4501                	li	a0,0
ffffffffc0204812:	e05ff0ef          	jal	ra,ffffffffc0204616 <do_wait.part.0>
    while (do_wait(0, NULL) == 0)
ffffffffc0204816:	d975                	beqz	a0,ffffffffc020480a <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0204818:	00003517          	auipc	a0,0x3
ffffffffc020481c:	9f850513          	addi	a0,a0,-1544 # ffffffffc0207210 <default_pmm_manager+0xb98>
ffffffffc0204820:	975fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204824:	000a6797          	auipc	a5,0xa6
ffffffffc0204828:	ecc7b783          	ld	a5,-308(a5) # ffffffffc02aa6f0 <initproc>
ffffffffc020482c:	7bf8                	ld	a4,240(a5)
ffffffffc020482e:	e339                	bnez	a4,ffffffffc0204874 <init_main+0x8c>
ffffffffc0204830:	7ff8                	ld	a4,248(a5)
ffffffffc0204832:	e329                	bnez	a4,ffffffffc0204874 <init_main+0x8c>
ffffffffc0204834:	1007b703          	ld	a4,256(a5)
ffffffffc0204838:	ef15                	bnez	a4,ffffffffc0204874 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc020483a:	000a6697          	auipc	a3,0xa6
ffffffffc020483e:	ebe6a683          	lw	a3,-322(a3) # ffffffffc02aa6f8 <nr_process>
ffffffffc0204842:	4709                	li	a4,2
ffffffffc0204844:	0ae69463          	bne	a3,a4,ffffffffc02048ec <init_main+0x104>
    return listelm->next;
ffffffffc0204848:	000a6697          	auipc	a3,0xa6
ffffffffc020484c:	e2068693          	addi	a3,a3,-480 # ffffffffc02aa668 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204850:	6698                	ld	a4,8(a3)
ffffffffc0204852:	0c878793          	addi	a5,a5,200
ffffffffc0204856:	06f71b63          	bne	a4,a5,ffffffffc02048cc <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020485a:	629c                	ld	a5,0(a3)
ffffffffc020485c:	04f71863          	bne	a4,a5,ffffffffc02048ac <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc0204860:	00003517          	auipc	a0,0x3
ffffffffc0204864:	a9850513          	addi	a0,a0,-1384 # ffffffffc02072f8 <default_pmm_manager+0xc80>
ffffffffc0204868:	92dfb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    return 0;
}
ffffffffc020486c:	60a2                	ld	ra,8(sp)
ffffffffc020486e:	4501                	li	a0,0
ffffffffc0204870:	0141                	addi	sp,sp,16
ffffffffc0204872:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204874:	00003697          	auipc	a3,0x3
ffffffffc0204878:	9c468693          	addi	a3,a3,-1596 # ffffffffc0207238 <default_pmm_manager+0xbc0>
ffffffffc020487c:	00002617          	auipc	a2,0x2
ffffffffc0204880:	a4c60613          	addi	a2,a2,-1460 # ffffffffc02062c8 <commands+0x890>
ffffffffc0204884:	3d100593          	li	a1,977
ffffffffc0204888:	00003517          	auipc	a0,0x3
ffffffffc020488c:	87850513          	addi	a0,a0,-1928 # ffffffffc0207100 <default_pmm_manager+0xa88>
ffffffffc0204890:	bfffb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("create user_main failed.\n");
ffffffffc0204894:	00003617          	auipc	a2,0x3
ffffffffc0204898:	95c60613          	addi	a2,a2,-1700 # ffffffffc02071f0 <default_pmm_manager+0xb78>
ffffffffc020489c:	3c800593          	li	a1,968
ffffffffc02048a0:	00003517          	auipc	a0,0x3
ffffffffc02048a4:	86050513          	addi	a0,a0,-1952 # ffffffffc0207100 <default_pmm_manager+0xa88>
ffffffffc02048a8:	be7fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02048ac:	00003697          	auipc	a3,0x3
ffffffffc02048b0:	a1c68693          	addi	a3,a3,-1508 # ffffffffc02072c8 <default_pmm_manager+0xc50>
ffffffffc02048b4:	00002617          	auipc	a2,0x2
ffffffffc02048b8:	a1460613          	addi	a2,a2,-1516 # ffffffffc02062c8 <commands+0x890>
ffffffffc02048bc:	3d400593          	li	a1,980
ffffffffc02048c0:	00003517          	auipc	a0,0x3
ffffffffc02048c4:	84050513          	addi	a0,a0,-1984 # ffffffffc0207100 <default_pmm_manager+0xa88>
ffffffffc02048c8:	bc7fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02048cc:	00003697          	auipc	a3,0x3
ffffffffc02048d0:	9cc68693          	addi	a3,a3,-1588 # ffffffffc0207298 <default_pmm_manager+0xc20>
ffffffffc02048d4:	00002617          	auipc	a2,0x2
ffffffffc02048d8:	9f460613          	addi	a2,a2,-1548 # ffffffffc02062c8 <commands+0x890>
ffffffffc02048dc:	3d300593          	li	a1,979
ffffffffc02048e0:	00003517          	auipc	a0,0x3
ffffffffc02048e4:	82050513          	addi	a0,a0,-2016 # ffffffffc0207100 <default_pmm_manager+0xa88>
ffffffffc02048e8:	ba7fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_process == 2);
ffffffffc02048ec:	00003697          	auipc	a3,0x3
ffffffffc02048f0:	99c68693          	addi	a3,a3,-1636 # ffffffffc0207288 <default_pmm_manager+0xc10>
ffffffffc02048f4:	00002617          	auipc	a2,0x2
ffffffffc02048f8:	9d460613          	addi	a2,a2,-1580 # ffffffffc02062c8 <commands+0x890>
ffffffffc02048fc:	3d200593          	li	a1,978
ffffffffc0204900:	00003517          	auipc	a0,0x3
ffffffffc0204904:	80050513          	addi	a0,a0,-2048 # ffffffffc0207100 <default_pmm_manager+0xa88>
ffffffffc0204908:	b87fb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020490c <do_execve>:
{
ffffffffc020490c:	7135                	addi	sp,sp,-160
ffffffffc020490e:	ecde                	sd	s7,88(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204910:	000a6b97          	auipc	s7,0xa6
ffffffffc0204914:	dd0b8b93          	addi	s7,s7,-560 # ffffffffc02aa6e0 <current>
ffffffffc0204918:	000bb783          	ld	a5,0(s7)
{
ffffffffc020491c:	fcce                	sd	s3,120(sp)
ffffffffc020491e:	e526                	sd	s1,136(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204920:	0287b983          	ld	s3,40(a5)
{
ffffffffc0204924:	e14a                	sd	s2,128(sp)
ffffffffc0204926:	f4d6                	sd	s5,104(sp)
ffffffffc0204928:	892a                	mv	s2,a0
ffffffffc020492a:	8ab2                	mv	s5,a2
ffffffffc020492c:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc020492e:	862e                	mv	a2,a1
ffffffffc0204930:	4681                	li	a3,0
ffffffffc0204932:	85aa                	mv	a1,a0
ffffffffc0204934:	854e                	mv	a0,s3
{
ffffffffc0204936:	ed06                	sd	ra,152(sp)
ffffffffc0204938:	e922                	sd	s0,144(sp)
ffffffffc020493a:	f8d2                	sd	s4,112(sp)
ffffffffc020493c:	f0da                	sd	s6,96(sp)
ffffffffc020493e:	e8e2                	sd	s8,80(sp)
ffffffffc0204940:	e4e6                	sd	s9,72(sp)
ffffffffc0204942:	e0ea                	sd	s10,64(sp)
ffffffffc0204944:	fc6e                	sd	s11,56(sp)
ffffffffc0204946:	e856                	sd	s5,16(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204948:	c76ff0ef          	jal	ra,ffffffffc0203dbe <user_mem_check>
ffffffffc020494c:	3e050f63          	beqz	a0,ffffffffc0204d4a <do_execve+0x43e>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0204950:	4641                	li	a2,16
ffffffffc0204952:	4581                	li	a1,0
ffffffffc0204954:	1008                	addi	a0,sp,32
ffffffffc0204956:	651000ef          	jal	ra,ffffffffc02057a6 <memset>
    memcpy(local_name, name, len);
ffffffffc020495a:	47bd                	li	a5,15
ffffffffc020495c:	8626                	mv	a2,s1
ffffffffc020495e:	0697ed63          	bltu	a5,s1,ffffffffc02049d8 <do_execve+0xcc>
ffffffffc0204962:	85ca                	mv	a1,s2
ffffffffc0204964:	1008                	addi	a0,sp,32
ffffffffc0204966:	653000ef          	jal	ra,ffffffffc02057b8 <memcpy>
    if (mm != NULL)
ffffffffc020496a:	06098e63          	beqz	s3,ffffffffc02049e6 <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc020496e:	00002517          	auipc	a0,0x2
ffffffffc0204972:	55250513          	addi	a0,a0,1362 # ffffffffc0206ec0 <default_pmm_manager+0x848>
ffffffffc0204976:	857fb0ef          	jal	ra,ffffffffc02001cc <cputs>
ffffffffc020497a:	000a6797          	auipc	a5,0xa6
ffffffffc020497e:	d367b783          	ld	a5,-714(a5) # ffffffffc02aa6b0 <boot_pgdir_pa>
ffffffffc0204982:	577d                	li	a4,-1
ffffffffc0204984:	177e                	slli	a4,a4,0x3f
ffffffffc0204986:	83b1                	srli	a5,a5,0xc
ffffffffc0204988:	8fd9                	or	a5,a5,a4
ffffffffc020498a:	18079073          	csrw	satp,a5
ffffffffc020498e:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7b78>
ffffffffc0204992:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204996:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0)
ffffffffc020499a:	28070f63          	beqz	a4,ffffffffc0204c38 <do_execve+0x32c>
        current->mm = NULL;
ffffffffc020499e:	000bb783          	ld	a5,0(s7)
ffffffffc02049a2:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc02049a6:	da3fe0ef          	jal	ra,ffffffffc0203748 <mm_create>
ffffffffc02049aa:	84aa                	mv	s1,a0
ffffffffc02049ac:	c135                	beqz	a0,ffffffffc0204a10 <do_execve+0x104>
    if (setup_pgdir(mm) != 0)
ffffffffc02049ae:	e20ff0ef          	jal	ra,ffffffffc0203fce <setup_pgdir>
ffffffffc02049b2:	e931                	bnez	a0,ffffffffc0204a06 <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc02049b4:	67c2                	ld	a5,16(sp)
ffffffffc02049b6:	4398                	lw	a4,0(a5)
ffffffffc02049b8:	464c47b7          	lui	a5,0x464c4
ffffffffc02049bc:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9467>
ffffffffc02049c0:	04f70a63          	beq	a4,a5,ffffffffc0204a14 <do_execve+0x108>
    put_pgdir(mm);
ffffffffc02049c4:	8526                	mv	a0,s1
ffffffffc02049c6:	d92ff0ef          	jal	ra,ffffffffc0203f58 <put_pgdir>
    mm_destroy(mm);
ffffffffc02049ca:	8526                	mv	a0,s1
ffffffffc02049cc:	ebdfe0ef          	jal	ra,ffffffffc0203888 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc02049d0:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc02049d2:	8552                	mv	a0,s4
ffffffffc02049d4:	af9ff0ef          	jal	ra,ffffffffc02044cc <do_exit>
    memcpy(local_name, name, len);
ffffffffc02049d8:	463d                	li	a2,15
ffffffffc02049da:	85ca                	mv	a1,s2
ffffffffc02049dc:	1008                	addi	a0,sp,32
ffffffffc02049de:	5db000ef          	jal	ra,ffffffffc02057b8 <memcpy>
    if (mm != NULL)
ffffffffc02049e2:	f80996e3          	bnez	s3,ffffffffc020496e <do_execve+0x62>
    if (current->mm != NULL)
ffffffffc02049e6:	000bb783          	ld	a5,0(s7)
ffffffffc02049ea:	779c                	ld	a5,40(a5)
ffffffffc02049ec:	dfcd                	beqz	a5,ffffffffc02049a6 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc02049ee:	00003617          	auipc	a2,0x3
ffffffffc02049f2:	92a60613          	addi	a2,a2,-1750 # ffffffffc0207318 <default_pmm_manager+0xca0>
ffffffffc02049f6:	24e00593          	li	a1,590
ffffffffc02049fa:	00002517          	auipc	a0,0x2
ffffffffc02049fe:	70650513          	addi	a0,a0,1798 # ffffffffc0207100 <default_pmm_manager+0xa88>
ffffffffc0204a02:	a8dfb0ef          	jal	ra,ffffffffc020048e <__panic>
    mm_destroy(mm);
ffffffffc0204a06:	8526                	mv	a0,s1
ffffffffc0204a08:	e81fe0ef          	jal	ra,ffffffffc0203888 <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0204a0c:	5a71                	li	s4,-4
ffffffffc0204a0e:	b7d1                	j	ffffffffc02049d2 <do_execve+0xc6>
ffffffffc0204a10:	5a71                	li	s4,-4
ffffffffc0204a12:	b7c1                	j	ffffffffc02049d2 <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204a14:	66c2                	ld	a3,16(sp)
ffffffffc0204a16:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204a1a:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204a1e:	00371793          	slli	a5,a4,0x3
ffffffffc0204a22:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204a24:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204a26:	078e                	slli	a5,a5,0x3
ffffffffc0204a28:	97ce                	add	a5,a5,s3
ffffffffc0204a2a:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph++)
ffffffffc0204a2c:	02f9fb63          	bgeu	s3,a5,ffffffffc0204a62 <do_execve+0x156>
    return KADDR(page2pa(page));
ffffffffc0204a30:	57fd                	li	a5,-1
ffffffffc0204a32:	83b1                	srli	a5,a5,0xc
    return page - pages + nbase;
ffffffffc0204a34:	000a6d17          	auipc	s10,0xa6
ffffffffc0204a38:	c94d0d13          	addi	s10,s10,-876 # ffffffffc02aa6c8 <pages>
ffffffffc0204a3c:	00003c97          	auipc	s9,0x3
ffffffffc0204a40:	ff4c8c93          	addi	s9,s9,-12 # ffffffffc0207a30 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204a44:	e43e                	sd	a5,8(sp)
ffffffffc0204a46:	000a6c17          	auipc	s8,0xa6
ffffffffc0204a4a:	c7ac0c13          	addi	s8,s8,-902 # ffffffffc02aa6c0 <npage>
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc0204a4e:	0009a703          	lw	a4,0(s3)
ffffffffc0204a52:	4785                	li	a5,1
ffffffffc0204a54:	10f70163          	beq	a4,a5,ffffffffc0204b56 <do_execve+0x24a>
    for (; ph < ph_end; ph++)
ffffffffc0204a58:	67e2                	ld	a5,24(sp)
ffffffffc0204a5a:	03898993          	addi	s3,s3,56
ffffffffc0204a5e:	fef9e8e3          	bltu	s3,a5,ffffffffc0204a4e <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc0204a62:	4701                	li	a4,0
ffffffffc0204a64:	46ad                	li	a3,11
ffffffffc0204a66:	00100637          	lui	a2,0x100
ffffffffc0204a6a:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0204a6e:	8526                	mv	a0,s1
ffffffffc0204a70:	e6bfe0ef          	jal	ra,ffffffffc02038da <mm_map>
ffffffffc0204a74:	8a2a                	mv	s4,a0
ffffffffc0204a76:	1a051763          	bnez	a0,ffffffffc0204c24 <do_execve+0x318>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204a7a:	6c88                	ld	a0,24(s1)
ffffffffc0204a7c:	467d                	li	a2,31
ffffffffc0204a7e:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0204a82:	be1fe0ef          	jal	ra,ffffffffc0203662 <pgdir_alloc_page>
ffffffffc0204a86:	36050063          	beqz	a0,ffffffffc0204de6 <do_execve+0x4da>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204a8a:	6c88                	ld	a0,24(s1)
ffffffffc0204a8c:	467d                	li	a2,31
ffffffffc0204a8e:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0204a92:	bd1fe0ef          	jal	ra,ffffffffc0203662 <pgdir_alloc_page>
ffffffffc0204a96:	32050863          	beqz	a0,ffffffffc0204dc6 <do_execve+0x4ba>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204a9a:	6c88                	ld	a0,24(s1)
ffffffffc0204a9c:	467d                	li	a2,31
ffffffffc0204a9e:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0204aa2:	bc1fe0ef          	jal	ra,ffffffffc0203662 <pgdir_alloc_page>
ffffffffc0204aa6:	30050063          	beqz	a0,ffffffffc0204da6 <do_execve+0x49a>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204aaa:	6c88                	ld	a0,24(s1)
ffffffffc0204aac:	467d                	li	a2,31
ffffffffc0204aae:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0204ab2:	bb1fe0ef          	jal	ra,ffffffffc0203662 <pgdir_alloc_page>
ffffffffc0204ab6:	2c050863          	beqz	a0,ffffffffc0204d86 <do_execve+0x47a>
    mm->mm_count += 1;
ffffffffc0204aba:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0204abc:	000bb603          	ld	a2,0(s7)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204ac0:	6c94                	ld	a3,24(s1)
ffffffffc0204ac2:	2785                	addiw	a5,a5,1
ffffffffc0204ac4:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0204ac6:	f604                	sd	s1,40(a2)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204ac8:	c02007b7          	lui	a5,0xc0200
ffffffffc0204acc:	2af6e163          	bltu	a3,a5,ffffffffc0204d6e <do_execve+0x462>
ffffffffc0204ad0:	000a6797          	auipc	a5,0xa6
ffffffffc0204ad4:	c087b783          	ld	a5,-1016(a5) # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc0204ad8:	8e9d                	sub	a3,a3,a5
ffffffffc0204ada:	577d                	li	a4,-1
ffffffffc0204adc:	00c6d793          	srli	a5,a3,0xc
ffffffffc0204ae0:	177e                	slli	a4,a4,0x3f
ffffffffc0204ae2:	f654                	sd	a3,168(a2)
ffffffffc0204ae4:	8fd9                	or	a5,a5,a4
ffffffffc0204ae6:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0204aea:	0a063903          	ld	s2,160(a2) # 1000a0 <_binary_obj___user_exit_out_size+0xf4f88>
    uintptr_t sstatus = read_csr(sstatus);
ffffffffc0204aee:	10002473          	csrr	s0,sstatus
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204af2:	12000613          	li	a2,288
ffffffffc0204af6:	4581                	li	a1,0
ffffffffc0204af8:	854a                	mv	a0,s2
ffffffffc0204afa:	4ad000ef          	jal	ra,ffffffffc02057a6 <memset>
    tf->epc = elf->e_entry;
ffffffffc0204afe:	67c2                	ld	a5,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204b00:	000bb483          	ld	s1,0(s7)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204b04:	edf47413          	andi	s0,s0,-289
    tf->epc = elf->e_entry;
ffffffffc0204b08:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc0204b0a:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204b0c:	0b448493          	addi	s1,s1,180
    tf->gpr.sp = USTACKTOP;
ffffffffc0204b10:	07fe                	slli	a5,a5,0x1f
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204b12:	02046413          	ori	s0,s0,32
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204b16:	4641                	li	a2,16
ffffffffc0204b18:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP;
ffffffffc0204b1a:	00f93823          	sd	a5,16(s2) # ffffffff80000010 <_binary_obj___user_exit_out_size+0xffffffff7fff4ef8>
    tf->epc = elf->e_entry;
ffffffffc0204b1e:	10e93423          	sd	a4,264(s2)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204b22:	10893023          	sd	s0,256(s2)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204b26:	8526                	mv	a0,s1
ffffffffc0204b28:	47f000ef          	jal	ra,ffffffffc02057a6 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204b2c:	463d                	li	a2,15
ffffffffc0204b2e:	100c                	addi	a1,sp,32
ffffffffc0204b30:	8526                	mv	a0,s1
ffffffffc0204b32:	487000ef          	jal	ra,ffffffffc02057b8 <memcpy>
}
ffffffffc0204b36:	60ea                	ld	ra,152(sp)
ffffffffc0204b38:	644a                	ld	s0,144(sp)
ffffffffc0204b3a:	64aa                	ld	s1,136(sp)
ffffffffc0204b3c:	690a                	ld	s2,128(sp)
ffffffffc0204b3e:	79e6                	ld	s3,120(sp)
ffffffffc0204b40:	7aa6                	ld	s5,104(sp)
ffffffffc0204b42:	7b06                	ld	s6,96(sp)
ffffffffc0204b44:	6be6                	ld	s7,88(sp)
ffffffffc0204b46:	6c46                	ld	s8,80(sp)
ffffffffc0204b48:	6ca6                	ld	s9,72(sp)
ffffffffc0204b4a:	6d06                	ld	s10,64(sp)
ffffffffc0204b4c:	7de2                	ld	s11,56(sp)
ffffffffc0204b4e:	8552                	mv	a0,s4
ffffffffc0204b50:	7a46                	ld	s4,112(sp)
ffffffffc0204b52:	610d                	addi	sp,sp,160
ffffffffc0204b54:	8082                	ret
        if (ph->p_filesz > ph->p_memsz)
ffffffffc0204b56:	0289b603          	ld	a2,40(s3)
ffffffffc0204b5a:	0209b783          	ld	a5,32(s3)
ffffffffc0204b5e:	1ef66a63          	bltu	a2,a5,ffffffffc0204d52 <do_execve+0x446>
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204b62:	0049a783          	lw	a5,4(s3)
ffffffffc0204b66:	0017f693          	andi	a3,a5,1
ffffffffc0204b6a:	c291                	beqz	a3,ffffffffc0204b6e <do_execve+0x262>
            vm_flags |= VM_EXEC;
ffffffffc0204b6c:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204b6e:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204b72:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204b74:	ef61                	bnez	a4,ffffffffc0204c4c <do_execve+0x340>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0204b76:	4b45                	li	s6,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204b78:	c781                	beqz	a5,ffffffffc0204b80 <do_execve+0x274>
            vm_flags |= VM_READ;
ffffffffc0204b7a:	0016e693          	ori	a3,a3,1
            perm |= PTE_R;
ffffffffc0204b7e:	4b4d                	li	s6,19
        if (vm_flags & VM_WRITE)
ffffffffc0204b80:	0026f793          	andi	a5,a3,2
ffffffffc0204b84:	e7f9                	bnez	a5,ffffffffc0204c52 <do_execve+0x346>
        if (vm_flags & VM_EXEC)
ffffffffc0204b86:	0046f793          	andi	a5,a3,4
ffffffffc0204b8a:	c399                	beqz	a5,ffffffffc0204b90 <do_execve+0x284>
            perm |= PTE_X;
ffffffffc0204b8c:	008b6b13          	ori	s6,s6,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc0204b90:	0109b583          	ld	a1,16(s3)
ffffffffc0204b94:	4701                	li	a4,0
ffffffffc0204b96:	8526                	mv	a0,s1
ffffffffc0204b98:	d43fe0ef          	jal	ra,ffffffffc02038da <mm_map>
ffffffffc0204b9c:	8a2a                	mv	s4,a0
ffffffffc0204b9e:	e159                	bnez	a0,ffffffffc0204c24 <do_execve+0x318>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204ba0:	0109bd83          	ld	s11,16(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204ba4:	67c2                	ld	a5,16(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0204ba6:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204baa:	0089b903          	ld	s2,8(s3)
        end = ph->p_va + ph->p_filesz;
ffffffffc0204bae:	9a6e                	add	s4,s4,s11
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204bb0:	993e                	add	s2,s2,a5
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204bb2:	77fd                	lui	a5,0xfffff
ffffffffc0204bb4:	00fdfab3          	and	s5,s11,a5
        while (start < end)
ffffffffc0204bb8:	054dee63          	bltu	s11,s4,ffffffffc0204c14 <do_execve+0x308>
ffffffffc0204bbc:	aa49                	j	ffffffffc0204d4e <do_execve+0x442>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204bbe:	6785                	lui	a5,0x1
ffffffffc0204bc0:	415d8533          	sub	a0,s11,s5
ffffffffc0204bc4:	9abe                	add	s5,s5,a5
ffffffffc0204bc6:	41ba8633          	sub	a2,s5,s11
            if (end < la)
ffffffffc0204bca:	015a7463          	bgeu	s4,s5,ffffffffc0204bd2 <do_execve+0x2c6>
                size -= la - end;
ffffffffc0204bce:	41ba0633          	sub	a2,s4,s11
    return page - pages + nbase;
ffffffffc0204bd2:	000d3683          	ld	a3,0(s10)
ffffffffc0204bd6:	000cb803          	ld	a6,0(s9)
    return KADDR(page2pa(page));
ffffffffc0204bda:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0204bdc:	40d406b3          	sub	a3,s0,a3
ffffffffc0204be0:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204be2:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204be6:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0204be8:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204bec:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204bee:	16b87463          	bgeu	a6,a1,ffffffffc0204d56 <do_execve+0x44a>
ffffffffc0204bf2:	000a6797          	auipc	a5,0xa6
ffffffffc0204bf6:	ae678793          	addi	a5,a5,-1306 # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc0204bfa:	0007b803          	ld	a6,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204bfe:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0204c00:	9db2                	add	s11,s11,a2
ffffffffc0204c02:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204c04:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0204c06:	e032                	sd	a2,0(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204c08:	3b1000ef          	jal	ra,ffffffffc02057b8 <memcpy>
            start += size, from += size;
ffffffffc0204c0c:	6602                	ld	a2,0(sp)
ffffffffc0204c0e:	9932                	add	s2,s2,a2
        while (start < end)
ffffffffc0204c10:	054df363          	bgeu	s11,s4,ffffffffc0204c56 <do_execve+0x34a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204c14:	6c88                	ld	a0,24(s1)
ffffffffc0204c16:	865a                	mv	a2,s6
ffffffffc0204c18:	85d6                	mv	a1,s5
ffffffffc0204c1a:	a49fe0ef          	jal	ra,ffffffffc0203662 <pgdir_alloc_page>
ffffffffc0204c1e:	842a                	mv	s0,a0
ffffffffc0204c20:	fd59                	bnez	a0,ffffffffc0204bbe <do_execve+0x2b2>
        ret = -E_NO_MEM;
ffffffffc0204c22:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0204c24:	8526                	mv	a0,s1
ffffffffc0204c26:	dfffe0ef          	jal	ra,ffffffffc0203a24 <exit_mmap>
    put_pgdir(mm);
ffffffffc0204c2a:	8526                	mv	a0,s1
ffffffffc0204c2c:	b2cff0ef          	jal	ra,ffffffffc0203f58 <put_pgdir>
    mm_destroy(mm);
ffffffffc0204c30:	8526                	mv	a0,s1
ffffffffc0204c32:	c57fe0ef          	jal	ra,ffffffffc0203888 <mm_destroy>
    return ret;
ffffffffc0204c36:	bb71                	j	ffffffffc02049d2 <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0204c38:	854e                	mv	a0,s3
ffffffffc0204c3a:	debfe0ef          	jal	ra,ffffffffc0203a24 <exit_mmap>
            put_pgdir(mm);
ffffffffc0204c3e:	854e                	mv	a0,s3
ffffffffc0204c40:	b18ff0ef          	jal	ra,ffffffffc0203f58 <put_pgdir>
            mm_destroy(mm);
ffffffffc0204c44:	854e                	mv	a0,s3
ffffffffc0204c46:	c43fe0ef          	jal	ra,ffffffffc0203888 <mm_destroy>
ffffffffc0204c4a:	bb91                	j	ffffffffc020499e <do_execve+0x92>
            vm_flags |= VM_WRITE;
ffffffffc0204c4c:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204c50:	f78d                	bnez	a5,ffffffffc0204b7a <do_execve+0x26e>
            perm |= (PTE_W | PTE_R);
ffffffffc0204c52:	4b5d                	li	s6,23
ffffffffc0204c54:	bf0d                	j	ffffffffc0204b86 <do_execve+0x27a>
        end = ph->p_va + ph->p_memsz;
ffffffffc0204c56:	0109b903          	ld	s2,16(s3)
ffffffffc0204c5a:	0289b683          	ld	a3,40(s3)
ffffffffc0204c5e:	9936                	add	s2,s2,a3
        if (start < la)
ffffffffc0204c60:	075dff63          	bgeu	s11,s5,ffffffffc0204cde <do_execve+0x3d2>
            if (start == end)
ffffffffc0204c64:	dfb90ae3          	beq	s2,s11,ffffffffc0204a58 <do_execve+0x14c>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204c68:	6505                	lui	a0,0x1
ffffffffc0204c6a:	956e                	add	a0,a0,s11
ffffffffc0204c6c:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0204c70:	41b90a33          	sub	s4,s2,s11
            if (end < la)
ffffffffc0204c74:	0d597863          	bgeu	s2,s5,ffffffffc0204d44 <do_execve+0x438>
    return page - pages + nbase;
ffffffffc0204c78:	000d3683          	ld	a3,0(s10)
ffffffffc0204c7c:	000cb583          	ld	a1,0(s9)
    return KADDR(page2pa(page));
ffffffffc0204c80:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0204c82:	40d406b3          	sub	a3,s0,a3
ffffffffc0204c86:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204c88:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0204c8c:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0204c8e:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c92:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204c94:	0cc5f163          	bgeu	a1,a2,ffffffffc0204d56 <do_execve+0x44a>
ffffffffc0204c98:	000a6617          	auipc	a2,0xa6
ffffffffc0204c9c:	a4063603          	ld	a2,-1472(a2) # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc0204ca0:	96b2                	add	a3,a3,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0204ca2:	4581                	li	a1,0
ffffffffc0204ca4:	8652                	mv	a2,s4
ffffffffc0204ca6:	9536                	add	a0,a0,a3
ffffffffc0204ca8:	2ff000ef          	jal	ra,ffffffffc02057a6 <memset>
            start += size;
ffffffffc0204cac:	01ba0733          	add	a4,s4,s11
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0204cb0:	03597463          	bgeu	s2,s5,ffffffffc0204cd8 <do_execve+0x3cc>
ffffffffc0204cb4:	dae902e3          	beq	s2,a4,ffffffffc0204a58 <do_execve+0x14c>
ffffffffc0204cb8:	00002697          	auipc	a3,0x2
ffffffffc0204cbc:	68868693          	addi	a3,a3,1672 # ffffffffc0207340 <default_pmm_manager+0xcc8>
ffffffffc0204cc0:	00001617          	auipc	a2,0x1
ffffffffc0204cc4:	60860613          	addi	a2,a2,1544 # ffffffffc02062c8 <commands+0x890>
ffffffffc0204cc8:	2b700593          	li	a1,695
ffffffffc0204ccc:	00002517          	auipc	a0,0x2
ffffffffc0204cd0:	43450513          	addi	a0,a0,1076 # ffffffffc0207100 <default_pmm_manager+0xa88>
ffffffffc0204cd4:	fbafb0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc0204cd8:	ff5710e3          	bne	a4,s5,ffffffffc0204cb8 <do_execve+0x3ac>
ffffffffc0204cdc:	8dd6                	mv	s11,s5
ffffffffc0204cde:	000a6a17          	auipc	s4,0xa6
ffffffffc0204ce2:	9faa0a13          	addi	s4,s4,-1542 # ffffffffc02aa6d8 <va_pa_offset>
        while (start < end)
ffffffffc0204ce6:	052de763          	bltu	s11,s2,ffffffffc0204d34 <do_execve+0x428>
ffffffffc0204cea:	b3bd                	j	ffffffffc0204a58 <do_execve+0x14c>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204cec:	6785                	lui	a5,0x1
ffffffffc0204cee:	415d8533          	sub	a0,s11,s5
ffffffffc0204cf2:	9abe                	add	s5,s5,a5
ffffffffc0204cf4:	41ba8633          	sub	a2,s5,s11
            if (end < la)
ffffffffc0204cf8:	01597463          	bgeu	s2,s5,ffffffffc0204d00 <do_execve+0x3f4>
                size -= la - end;
ffffffffc0204cfc:	41b90633          	sub	a2,s2,s11
    return page - pages + nbase;
ffffffffc0204d00:	000d3683          	ld	a3,0(s10)
ffffffffc0204d04:	000cb803          	ld	a6,0(s9)
    return KADDR(page2pa(page));
ffffffffc0204d08:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0204d0a:	40d406b3          	sub	a3,s0,a3
ffffffffc0204d0e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204d10:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204d14:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0204d16:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204d1a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204d1c:	02b87d63          	bgeu	a6,a1,ffffffffc0204d56 <do_execve+0x44a>
ffffffffc0204d20:	000a3803          	ld	a6,0(s4)
            start += size;
ffffffffc0204d24:	9db2                	add	s11,s11,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0204d26:	4581                	li	a1,0
ffffffffc0204d28:	96c2                	add	a3,a3,a6
ffffffffc0204d2a:	9536                	add	a0,a0,a3
ffffffffc0204d2c:	27b000ef          	jal	ra,ffffffffc02057a6 <memset>
        while (start < end)
ffffffffc0204d30:	d32df4e3          	bgeu	s11,s2,ffffffffc0204a58 <do_execve+0x14c>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204d34:	6c88                	ld	a0,24(s1)
ffffffffc0204d36:	865a                	mv	a2,s6
ffffffffc0204d38:	85d6                	mv	a1,s5
ffffffffc0204d3a:	929fe0ef          	jal	ra,ffffffffc0203662 <pgdir_alloc_page>
ffffffffc0204d3e:	842a                	mv	s0,a0
ffffffffc0204d40:	f555                	bnez	a0,ffffffffc0204cec <do_execve+0x3e0>
ffffffffc0204d42:	b5c5                	j	ffffffffc0204c22 <do_execve+0x316>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204d44:	41ba8a33          	sub	s4,s5,s11
ffffffffc0204d48:	bf05                	j	ffffffffc0204c78 <do_execve+0x36c>
        return -E_INVAL;
ffffffffc0204d4a:	5a75                	li	s4,-3
ffffffffc0204d4c:	b3ed                	j	ffffffffc0204b36 <do_execve+0x22a>
        while (start < end)
ffffffffc0204d4e:	896e                	mv	s2,s11
ffffffffc0204d50:	b729                	j	ffffffffc0204c5a <do_execve+0x34e>
            ret = -E_INVAL_ELF;
ffffffffc0204d52:	5a61                	li	s4,-8
ffffffffc0204d54:	bdc1                	j	ffffffffc0204c24 <do_execve+0x318>
ffffffffc0204d56:	00002617          	auipc	a2,0x2
ffffffffc0204d5a:	95a60613          	addi	a2,a2,-1702 # ffffffffc02066b0 <default_pmm_manager+0x38>
ffffffffc0204d5e:	07100593          	li	a1,113
ffffffffc0204d62:	00002517          	auipc	a0,0x2
ffffffffc0204d66:	97650513          	addi	a0,a0,-1674 # ffffffffc02066d8 <default_pmm_manager+0x60>
ffffffffc0204d6a:	f24fb0ef          	jal	ra,ffffffffc020048e <__panic>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204d6e:	00002617          	auipc	a2,0x2
ffffffffc0204d72:	9ea60613          	addi	a2,a2,-1558 # ffffffffc0206758 <default_pmm_manager+0xe0>
ffffffffc0204d76:	2d600593          	li	a1,726
ffffffffc0204d7a:	00002517          	auipc	a0,0x2
ffffffffc0204d7e:	38650513          	addi	a0,a0,902 # ffffffffc0207100 <default_pmm_manager+0xa88>
ffffffffc0204d82:	f0cfb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204d86:	00002697          	auipc	a3,0x2
ffffffffc0204d8a:	6d268693          	addi	a3,a3,1746 # ffffffffc0207458 <default_pmm_manager+0xde0>
ffffffffc0204d8e:	00001617          	auipc	a2,0x1
ffffffffc0204d92:	53a60613          	addi	a2,a2,1338 # ffffffffc02062c8 <commands+0x890>
ffffffffc0204d96:	2d100593          	li	a1,721
ffffffffc0204d9a:	00002517          	auipc	a0,0x2
ffffffffc0204d9e:	36650513          	addi	a0,a0,870 # ffffffffc0207100 <default_pmm_manager+0xa88>
ffffffffc0204da2:	eecfb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204da6:	00002697          	auipc	a3,0x2
ffffffffc0204daa:	66a68693          	addi	a3,a3,1642 # ffffffffc0207410 <default_pmm_manager+0xd98>
ffffffffc0204dae:	00001617          	auipc	a2,0x1
ffffffffc0204db2:	51a60613          	addi	a2,a2,1306 # ffffffffc02062c8 <commands+0x890>
ffffffffc0204db6:	2d000593          	li	a1,720
ffffffffc0204dba:	00002517          	auipc	a0,0x2
ffffffffc0204dbe:	34650513          	addi	a0,a0,838 # ffffffffc0207100 <default_pmm_manager+0xa88>
ffffffffc0204dc2:	eccfb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204dc6:	00002697          	auipc	a3,0x2
ffffffffc0204dca:	60268693          	addi	a3,a3,1538 # ffffffffc02073c8 <default_pmm_manager+0xd50>
ffffffffc0204dce:	00001617          	auipc	a2,0x1
ffffffffc0204dd2:	4fa60613          	addi	a2,a2,1274 # ffffffffc02062c8 <commands+0x890>
ffffffffc0204dd6:	2cf00593          	li	a1,719
ffffffffc0204dda:	00002517          	auipc	a0,0x2
ffffffffc0204dde:	32650513          	addi	a0,a0,806 # ffffffffc0207100 <default_pmm_manager+0xa88>
ffffffffc0204de2:	eacfb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204de6:	00002697          	auipc	a3,0x2
ffffffffc0204dea:	59a68693          	addi	a3,a3,1434 # ffffffffc0207380 <default_pmm_manager+0xd08>
ffffffffc0204dee:	00001617          	auipc	a2,0x1
ffffffffc0204df2:	4da60613          	addi	a2,a2,1242 # ffffffffc02062c8 <commands+0x890>
ffffffffc0204df6:	2ce00593          	li	a1,718
ffffffffc0204dfa:	00002517          	auipc	a0,0x2
ffffffffc0204dfe:	30650513          	addi	a0,a0,774 # ffffffffc0207100 <default_pmm_manager+0xa88>
ffffffffc0204e02:	e8cfb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204e06 <do_yield>:
    current->need_resched = 1;
ffffffffc0204e06:	000a6797          	auipc	a5,0xa6
ffffffffc0204e0a:	8da7b783          	ld	a5,-1830(a5) # ffffffffc02aa6e0 <current>
ffffffffc0204e0e:	4705                	li	a4,1
ffffffffc0204e10:	ef98                	sd	a4,24(a5)
}
ffffffffc0204e12:	4501                	li	a0,0
ffffffffc0204e14:	8082                	ret

ffffffffc0204e16 <do_wait>:
{
ffffffffc0204e16:	1101                	addi	sp,sp,-32
ffffffffc0204e18:	e822                	sd	s0,16(sp)
ffffffffc0204e1a:	e426                	sd	s1,8(sp)
ffffffffc0204e1c:	ec06                	sd	ra,24(sp)
ffffffffc0204e1e:	842e                	mv	s0,a1
ffffffffc0204e20:	84aa                	mv	s1,a0
    if (code_store != NULL)
ffffffffc0204e22:	c999                	beqz	a1,ffffffffc0204e38 <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0204e24:	000a6797          	auipc	a5,0xa6
ffffffffc0204e28:	8bc7b783          	ld	a5,-1860(a5) # ffffffffc02aa6e0 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0204e2c:	7788                	ld	a0,40(a5)
ffffffffc0204e2e:	4685                	li	a3,1
ffffffffc0204e30:	4611                	li	a2,4
ffffffffc0204e32:	f8dfe0ef          	jal	ra,ffffffffc0203dbe <user_mem_check>
ffffffffc0204e36:	c909                	beqz	a0,ffffffffc0204e48 <do_wait+0x32>
ffffffffc0204e38:	85a2                	mv	a1,s0
}
ffffffffc0204e3a:	6442                	ld	s0,16(sp)
ffffffffc0204e3c:	60e2                	ld	ra,24(sp)
ffffffffc0204e3e:	8526                	mv	a0,s1
ffffffffc0204e40:	64a2                	ld	s1,8(sp)
ffffffffc0204e42:	6105                	addi	sp,sp,32
ffffffffc0204e44:	fd2ff06f          	j	ffffffffc0204616 <do_wait.part.0>
ffffffffc0204e48:	60e2                	ld	ra,24(sp)
ffffffffc0204e4a:	6442                	ld	s0,16(sp)
ffffffffc0204e4c:	64a2                	ld	s1,8(sp)
ffffffffc0204e4e:	5575                	li	a0,-3
ffffffffc0204e50:	6105                	addi	sp,sp,32
ffffffffc0204e52:	8082                	ret

ffffffffc0204e54 <do_kill>:
{
ffffffffc0204e54:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID)
ffffffffc0204e56:	6789                	lui	a5,0x2
{
ffffffffc0204e58:	e406                	sd	ra,8(sp)
ffffffffc0204e5a:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID)
ffffffffc0204e5c:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204e60:	17f9                	addi	a5,a5,-2
ffffffffc0204e62:	02e7e963          	bltu	a5,a4,ffffffffc0204e94 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204e66:	842a                	mv	s0,a0
ffffffffc0204e68:	45a9                	li	a1,10
ffffffffc0204e6a:	2501                	sext.w	a0,a0
ffffffffc0204e6c:	494000ef          	jal	ra,ffffffffc0205300 <hash32>
ffffffffc0204e70:	02051793          	slli	a5,a0,0x20
ffffffffc0204e74:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204e78:	000a1797          	auipc	a5,0xa1
ffffffffc0204e7c:	7f078793          	addi	a5,a5,2032 # ffffffffc02a6668 <hash_list>
ffffffffc0204e80:	953e                	add	a0,a0,a5
ffffffffc0204e82:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list)
ffffffffc0204e84:	a029                	j	ffffffffc0204e8e <do_kill+0x3a>
            if (proc->pid == pid)
ffffffffc0204e86:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0204e8a:	00870b63          	beq	a4,s0,ffffffffc0204ea0 <do_kill+0x4c>
ffffffffc0204e8e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204e90:	fef51be3          	bne	a0,a5,ffffffffc0204e86 <do_kill+0x32>
    return -E_INVAL;
ffffffffc0204e94:	5475                	li	s0,-3
}
ffffffffc0204e96:	60a2                	ld	ra,8(sp)
ffffffffc0204e98:	8522                	mv	a0,s0
ffffffffc0204e9a:	6402                	ld	s0,0(sp)
ffffffffc0204e9c:	0141                	addi	sp,sp,16
ffffffffc0204e9e:	8082                	ret
        if (!(proc->flags & PF_EXITING))
ffffffffc0204ea0:	fd87a703          	lw	a4,-40(a5)
ffffffffc0204ea4:	00177693          	andi	a3,a4,1
ffffffffc0204ea8:	e295                	bnez	a3,ffffffffc0204ecc <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0204eaa:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0204eac:	00176713          	ori	a4,a4,1
ffffffffc0204eb0:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0204eb4:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0204eb6:	fe06d0e3          	bgez	a3,ffffffffc0204e96 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0204eba:	f2878513          	addi	a0,a5,-216
ffffffffc0204ebe:	22e000ef          	jal	ra,ffffffffc02050ec <wakeup_proc>
}
ffffffffc0204ec2:	60a2                	ld	ra,8(sp)
ffffffffc0204ec4:	8522                	mv	a0,s0
ffffffffc0204ec6:	6402                	ld	s0,0(sp)
ffffffffc0204ec8:	0141                	addi	sp,sp,16
ffffffffc0204eca:	8082                	ret
        return -E_KILLED;
ffffffffc0204ecc:	545d                	li	s0,-9
ffffffffc0204ece:	b7e1                	j	ffffffffc0204e96 <do_kill+0x42>

ffffffffc0204ed0 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc0204ed0:	1101                	addi	sp,sp,-32
ffffffffc0204ed2:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0204ed4:	000a5797          	auipc	a5,0xa5
ffffffffc0204ed8:	79478793          	addi	a5,a5,1940 # ffffffffc02aa668 <proc_list>
ffffffffc0204edc:	ec06                	sd	ra,24(sp)
ffffffffc0204ede:	e822                	sd	s0,16(sp)
ffffffffc0204ee0:	e04a                	sd	s2,0(sp)
ffffffffc0204ee2:	000a1497          	auipc	s1,0xa1
ffffffffc0204ee6:	78648493          	addi	s1,s1,1926 # ffffffffc02a6668 <hash_list>
ffffffffc0204eea:	e79c                	sd	a5,8(a5)
ffffffffc0204eec:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0204eee:	000a5717          	auipc	a4,0xa5
ffffffffc0204ef2:	77a70713          	addi	a4,a4,1914 # ffffffffc02aa668 <proc_list>
ffffffffc0204ef6:	87a6                	mv	a5,s1
ffffffffc0204ef8:	e79c                	sd	a5,8(a5)
ffffffffc0204efa:	e39c                	sd	a5,0(a5)
ffffffffc0204efc:	07c1                	addi	a5,a5,16
ffffffffc0204efe:	fef71de3          	bne	a4,a5,ffffffffc0204ef8 <proc_init+0x28>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc0204f02:	f59fe0ef          	jal	ra,ffffffffc0203e5a <alloc_proc>
ffffffffc0204f06:	000a5917          	auipc	s2,0xa5
ffffffffc0204f0a:	7e290913          	addi	s2,s2,2018 # ffffffffc02aa6e8 <idleproc>
ffffffffc0204f0e:	00a93023          	sd	a0,0(s2)
ffffffffc0204f12:	0e050f63          	beqz	a0,ffffffffc0205010 <proc_init+0x140>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0204f16:	4789                	li	a5,2
ffffffffc0204f18:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204f1a:	00003797          	auipc	a5,0x3
ffffffffc0204f1e:	0e678793          	addi	a5,a5,230 # ffffffffc0208000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f22:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204f26:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0204f28:	4785                	li	a5,1
ffffffffc0204f2a:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f2c:	4641                	li	a2,16
ffffffffc0204f2e:	4581                	li	a1,0
ffffffffc0204f30:	8522                	mv	a0,s0
ffffffffc0204f32:	075000ef          	jal	ra,ffffffffc02057a6 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f36:	463d                	li	a2,15
ffffffffc0204f38:	00002597          	auipc	a1,0x2
ffffffffc0204f3c:	58058593          	addi	a1,a1,1408 # ffffffffc02074b8 <default_pmm_manager+0xe40>
ffffffffc0204f40:	8522                	mv	a0,s0
ffffffffc0204f42:	077000ef          	jal	ra,ffffffffc02057b8 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process++;
ffffffffc0204f46:	000a5717          	auipc	a4,0xa5
ffffffffc0204f4a:	7b270713          	addi	a4,a4,1970 # ffffffffc02aa6f8 <nr_process>
ffffffffc0204f4e:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0204f50:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0204f54:	4601                	li	a2,0
    nr_process++;
ffffffffc0204f56:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0204f58:	4581                	li	a1,0
ffffffffc0204f5a:	00000517          	auipc	a0,0x0
ffffffffc0204f5e:	88e50513          	addi	a0,a0,-1906 # ffffffffc02047e8 <init_main>
    nr_process++;
ffffffffc0204f62:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0204f64:	000a5797          	auipc	a5,0xa5
ffffffffc0204f68:	76d7be23          	sd	a3,1916(a5) # ffffffffc02aa6e0 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0204f6c:	d10ff0ef          	jal	ra,ffffffffc020447c <kernel_thread>
ffffffffc0204f70:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc0204f72:	08a05363          	blez	a0,ffffffffc0204ff8 <proc_init+0x128>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204f76:	6789                	lui	a5,0x2
ffffffffc0204f78:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204f7c:	17f9                	addi	a5,a5,-2
ffffffffc0204f7e:	2501                	sext.w	a0,a0
ffffffffc0204f80:	02e7e363          	bltu	a5,a4,ffffffffc0204fa6 <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204f84:	45a9                	li	a1,10
ffffffffc0204f86:	37a000ef          	jal	ra,ffffffffc0205300 <hash32>
ffffffffc0204f8a:	02051793          	slli	a5,a0,0x20
ffffffffc0204f8e:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0204f92:	96a6                	add	a3,a3,s1
ffffffffc0204f94:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0204f96:	a029                	j	ffffffffc0204fa0 <proc_init+0xd0>
            if (proc->pid == pid)
ffffffffc0204f98:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c7c>
ffffffffc0204f9c:	04870b63          	beq	a4,s0,ffffffffc0204ff2 <proc_init+0x122>
    return listelm->next;
ffffffffc0204fa0:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204fa2:	fef69be3          	bne	a3,a5,ffffffffc0204f98 <proc_init+0xc8>
    return NULL;
ffffffffc0204fa6:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204fa8:	0b478493          	addi	s1,a5,180
ffffffffc0204fac:	4641                	li	a2,16
ffffffffc0204fae:	4581                	li	a1,0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0204fb0:	000a5417          	auipc	s0,0xa5
ffffffffc0204fb4:	74040413          	addi	s0,s0,1856 # ffffffffc02aa6f0 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204fb8:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0204fba:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204fbc:	7ea000ef          	jal	ra,ffffffffc02057a6 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204fc0:	463d                	li	a2,15
ffffffffc0204fc2:	00002597          	auipc	a1,0x2
ffffffffc0204fc6:	51e58593          	addi	a1,a1,1310 # ffffffffc02074e0 <default_pmm_manager+0xe68>
ffffffffc0204fca:	8526                	mv	a0,s1
ffffffffc0204fcc:	7ec000ef          	jal	ra,ffffffffc02057b8 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204fd0:	00093783          	ld	a5,0(s2)
ffffffffc0204fd4:	cbb5                	beqz	a5,ffffffffc0205048 <proc_init+0x178>
ffffffffc0204fd6:	43dc                	lw	a5,4(a5)
ffffffffc0204fd8:	eba5                	bnez	a5,ffffffffc0205048 <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204fda:	601c                	ld	a5,0(s0)
ffffffffc0204fdc:	c7b1                	beqz	a5,ffffffffc0205028 <proc_init+0x158>
ffffffffc0204fde:	43d8                	lw	a4,4(a5)
ffffffffc0204fe0:	4785                	li	a5,1
ffffffffc0204fe2:	04f71363          	bne	a4,a5,ffffffffc0205028 <proc_init+0x158>
}
ffffffffc0204fe6:	60e2                	ld	ra,24(sp)
ffffffffc0204fe8:	6442                	ld	s0,16(sp)
ffffffffc0204fea:	64a2                	ld	s1,8(sp)
ffffffffc0204fec:	6902                	ld	s2,0(sp)
ffffffffc0204fee:	6105                	addi	sp,sp,32
ffffffffc0204ff0:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204ff2:	f2878793          	addi	a5,a5,-216
ffffffffc0204ff6:	bf4d                	j	ffffffffc0204fa8 <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0204ff8:	00002617          	auipc	a2,0x2
ffffffffc0204ffc:	4c860613          	addi	a2,a2,1224 # ffffffffc02074c0 <default_pmm_manager+0xe48>
ffffffffc0205000:	3f700593          	li	a1,1015
ffffffffc0205004:	00002517          	auipc	a0,0x2
ffffffffc0205008:	0fc50513          	addi	a0,a0,252 # ffffffffc0207100 <default_pmm_manager+0xa88>
ffffffffc020500c:	c82fb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0205010:	00002617          	auipc	a2,0x2
ffffffffc0205014:	49060613          	addi	a2,a2,1168 # ffffffffc02074a0 <default_pmm_manager+0xe28>
ffffffffc0205018:	3e800593          	li	a1,1000
ffffffffc020501c:	00002517          	auipc	a0,0x2
ffffffffc0205020:	0e450513          	addi	a0,a0,228 # ffffffffc0207100 <default_pmm_manager+0xa88>
ffffffffc0205024:	c6afb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205028:	00002697          	auipc	a3,0x2
ffffffffc020502c:	4e868693          	addi	a3,a3,1256 # ffffffffc0207510 <default_pmm_manager+0xe98>
ffffffffc0205030:	00001617          	auipc	a2,0x1
ffffffffc0205034:	29860613          	addi	a2,a2,664 # ffffffffc02062c8 <commands+0x890>
ffffffffc0205038:	3fe00593          	li	a1,1022
ffffffffc020503c:	00002517          	auipc	a0,0x2
ffffffffc0205040:	0c450513          	addi	a0,a0,196 # ffffffffc0207100 <default_pmm_manager+0xa88>
ffffffffc0205044:	c4afb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205048:	00002697          	auipc	a3,0x2
ffffffffc020504c:	4a068693          	addi	a3,a3,1184 # ffffffffc02074e8 <default_pmm_manager+0xe70>
ffffffffc0205050:	00001617          	auipc	a2,0x1
ffffffffc0205054:	27860613          	addi	a2,a2,632 # ffffffffc02062c8 <commands+0x890>
ffffffffc0205058:	3fd00593          	li	a1,1021
ffffffffc020505c:	00002517          	auipc	a0,0x2
ffffffffc0205060:	0a450513          	addi	a0,a0,164 # ffffffffc0207100 <default_pmm_manager+0xa88>
ffffffffc0205064:	c2afb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0205068 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc0205068:	1141                	addi	sp,sp,-16
ffffffffc020506a:	e022                	sd	s0,0(sp)
ffffffffc020506c:	e406                	sd	ra,8(sp)
ffffffffc020506e:	000a5417          	auipc	s0,0xa5
ffffffffc0205072:	67240413          	addi	s0,s0,1650 # ffffffffc02aa6e0 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc0205076:	6018                	ld	a4,0(s0)
ffffffffc0205078:	6f1c                	ld	a5,24(a4)
ffffffffc020507a:	dffd                	beqz	a5,ffffffffc0205078 <cpu_idle+0x10>
        {
            schedule();
ffffffffc020507c:	0f0000ef          	jal	ra,ffffffffc020516c <schedule>
ffffffffc0205080:	bfdd                	j	ffffffffc0205076 <cpu_idle+0xe>

ffffffffc0205082 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0205082:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0205086:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc020508a:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc020508c:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc020508e:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0205092:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0205096:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc020509a:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc020509e:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc02050a2:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc02050a6:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc02050aa:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc02050ae:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc02050b2:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc02050b6:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc02050ba:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc02050be:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc02050c0:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc02050c2:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc02050c6:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc02050ca:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc02050ce:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc02050d2:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc02050d6:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc02050da:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc02050de:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc02050e2:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc02050e6:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc02050ea:	8082                	ret

ffffffffc02050ec <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02050ec:	4118                	lw	a4,0(a0)
{
ffffffffc02050ee:	1101                	addi	sp,sp,-32
ffffffffc02050f0:	ec06                	sd	ra,24(sp)
ffffffffc02050f2:	e822                	sd	s0,16(sp)
ffffffffc02050f4:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02050f6:	478d                	li	a5,3
ffffffffc02050f8:	04f70b63          	beq	a4,a5,ffffffffc020514e <wakeup_proc+0x62>
ffffffffc02050fc:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02050fe:	100027f3          	csrr	a5,sstatus
ffffffffc0205102:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205104:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0205106:	ef9d                	bnez	a5,ffffffffc0205144 <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
ffffffffc0205108:	4789                	li	a5,2
ffffffffc020510a:	02f70163          	beq	a4,a5,ffffffffc020512c <wakeup_proc+0x40>
        {
            proc->state = PROC_RUNNABLE;
ffffffffc020510e:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0205110:	0e042623          	sw	zero,236(s0)
    if (flag)
ffffffffc0205114:	e491                	bnez	s1,ffffffffc0205120 <wakeup_proc+0x34>
        {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205116:	60e2                	ld	ra,24(sp)
ffffffffc0205118:	6442                	ld	s0,16(sp)
ffffffffc020511a:	64a2                	ld	s1,8(sp)
ffffffffc020511c:	6105                	addi	sp,sp,32
ffffffffc020511e:	8082                	ret
ffffffffc0205120:	6442                	ld	s0,16(sp)
ffffffffc0205122:	60e2                	ld	ra,24(sp)
ffffffffc0205124:	64a2                	ld	s1,8(sp)
ffffffffc0205126:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205128:	887fb06f          	j	ffffffffc02009ae <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc020512c:	00002617          	auipc	a2,0x2
ffffffffc0205130:	44460613          	addi	a2,a2,1092 # ffffffffc0207570 <default_pmm_manager+0xef8>
ffffffffc0205134:	45d1                	li	a1,20
ffffffffc0205136:	00002517          	auipc	a0,0x2
ffffffffc020513a:	42250513          	addi	a0,a0,1058 # ffffffffc0207558 <default_pmm_manager+0xee0>
ffffffffc020513e:	bb8fb0ef          	jal	ra,ffffffffc02004f6 <__warn>
ffffffffc0205142:	bfc9                	j	ffffffffc0205114 <wakeup_proc+0x28>
        intr_disable();
ffffffffc0205144:	871fb0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        if (proc->state != PROC_RUNNABLE)
ffffffffc0205148:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc020514a:	4485                	li	s1,1
ffffffffc020514c:	bf75                	j	ffffffffc0205108 <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020514e:	00002697          	auipc	a3,0x2
ffffffffc0205152:	3ea68693          	addi	a3,a3,1002 # ffffffffc0207538 <default_pmm_manager+0xec0>
ffffffffc0205156:	00001617          	auipc	a2,0x1
ffffffffc020515a:	17260613          	addi	a2,a2,370 # ffffffffc02062c8 <commands+0x890>
ffffffffc020515e:	45a5                	li	a1,9
ffffffffc0205160:	00002517          	auipc	a0,0x2
ffffffffc0205164:	3f850513          	addi	a0,a0,1016 # ffffffffc0207558 <default_pmm_manager+0xee0>
ffffffffc0205168:	b26fb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020516c <schedule>:

void schedule(void)
{
ffffffffc020516c:	1141                	addi	sp,sp,-16
ffffffffc020516e:	e406                	sd	ra,8(sp)
ffffffffc0205170:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0205172:	100027f3          	csrr	a5,sstatus
ffffffffc0205176:	8b89                	andi	a5,a5,2
ffffffffc0205178:	4401                	li	s0,0
ffffffffc020517a:	efbd                	bnez	a5,ffffffffc02051f8 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc020517c:	000a5897          	auipc	a7,0xa5
ffffffffc0205180:	5648b883          	ld	a7,1380(a7) # ffffffffc02aa6e0 <current>
ffffffffc0205184:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205188:	000a5517          	auipc	a0,0xa5
ffffffffc020518c:	56053503          	ld	a0,1376(a0) # ffffffffc02aa6e8 <idleproc>
ffffffffc0205190:	04a88e63          	beq	a7,a0,ffffffffc02051ec <schedule+0x80>
ffffffffc0205194:	0c888693          	addi	a3,a7,200
ffffffffc0205198:	000a5617          	auipc	a2,0xa5
ffffffffc020519c:	4d060613          	addi	a2,a2,1232 # ffffffffc02aa668 <proc_list>
        le = last;
ffffffffc02051a0:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc02051a2:	4581                	li	a1,0
        do
        {
            if ((le = list_next(le)) != &proc_list)
            {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE)
ffffffffc02051a4:	4809                	li	a6,2
ffffffffc02051a6:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list)
ffffffffc02051a8:	00c78863          	beq	a5,a2,ffffffffc02051b8 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE)
ffffffffc02051ac:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02051b0:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE)
ffffffffc02051b4:	03070163          	beq	a4,a6,ffffffffc02051d6 <schedule+0x6a>
                {
                    break;
                }
            }
        } while (le != last);
ffffffffc02051b8:	fef697e3          	bne	a3,a5,ffffffffc02051a6 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc02051bc:	ed89                	bnez	a1,ffffffffc02051d6 <schedule+0x6a>
        {
            next = idleproc;
        }
        next->runs++;
ffffffffc02051be:	451c                	lw	a5,8(a0)
ffffffffc02051c0:	2785                	addiw	a5,a5,1
ffffffffc02051c2:	c51c                	sw	a5,8(a0)
        if (next != current)
ffffffffc02051c4:	00a88463          	beq	a7,a0,ffffffffc02051cc <schedule+0x60>
        {
            proc_run(next);
ffffffffc02051c8:	eabfe0ef          	jal	ra,ffffffffc0204072 <proc_run>
    if (flag)
ffffffffc02051cc:	e819                	bnez	s0,ffffffffc02051e2 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02051ce:	60a2                	ld	ra,8(sp)
ffffffffc02051d0:	6402                	ld	s0,0(sp)
ffffffffc02051d2:	0141                	addi	sp,sp,16
ffffffffc02051d4:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc02051d6:	4198                	lw	a4,0(a1)
ffffffffc02051d8:	4789                	li	a5,2
ffffffffc02051da:	fef712e3          	bne	a4,a5,ffffffffc02051be <schedule+0x52>
ffffffffc02051de:	852e                	mv	a0,a1
ffffffffc02051e0:	bff9                	j	ffffffffc02051be <schedule+0x52>
}
ffffffffc02051e2:	6402                	ld	s0,0(sp)
ffffffffc02051e4:	60a2                	ld	ra,8(sp)
ffffffffc02051e6:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02051e8:	fc6fb06f          	j	ffffffffc02009ae <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02051ec:	000a5617          	auipc	a2,0xa5
ffffffffc02051f0:	47c60613          	addi	a2,a2,1148 # ffffffffc02aa668 <proc_list>
ffffffffc02051f4:	86b2                	mv	a3,a2
ffffffffc02051f6:	b76d                	j	ffffffffc02051a0 <schedule+0x34>
        intr_disable();
ffffffffc02051f8:	fbcfb0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc02051fc:	4405                	li	s0,1
ffffffffc02051fe:	bfbd                	j	ffffffffc020517c <schedule+0x10>

ffffffffc0205200 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0205200:	000a5797          	auipc	a5,0xa5
ffffffffc0205204:	4e07b783          	ld	a5,1248(a5) # ffffffffc02aa6e0 <current>
}
ffffffffc0205208:	43c8                	lw	a0,4(a5)
ffffffffc020520a:	8082                	ret

ffffffffc020520c <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc020520c:	4501                	li	a0,0
ffffffffc020520e:	8082                	ret

ffffffffc0205210 <sys_putc>:
    cputchar(c);
ffffffffc0205210:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0205212:	1141                	addi	sp,sp,-16
ffffffffc0205214:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0205216:	fb5fa0ef          	jal	ra,ffffffffc02001ca <cputchar>
}
ffffffffc020521a:	60a2                	ld	ra,8(sp)
ffffffffc020521c:	4501                	li	a0,0
ffffffffc020521e:	0141                	addi	sp,sp,16
ffffffffc0205220:	8082                	ret

ffffffffc0205222 <sys_kill>:
    return do_kill(pid);
ffffffffc0205222:	4108                	lw	a0,0(a0)
ffffffffc0205224:	c31ff06f          	j	ffffffffc0204e54 <do_kill>

ffffffffc0205228 <sys_yield>:
    return do_yield();
ffffffffc0205228:	bdfff06f          	j	ffffffffc0204e06 <do_yield>

ffffffffc020522c <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc020522c:	6d14                	ld	a3,24(a0)
ffffffffc020522e:	6910                	ld	a2,16(a0)
ffffffffc0205230:	650c                	ld	a1,8(a0)
ffffffffc0205232:	6108                	ld	a0,0(a0)
ffffffffc0205234:	ed8ff06f          	j	ffffffffc020490c <do_execve>

ffffffffc0205238 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0205238:	650c                	ld	a1,8(a0)
ffffffffc020523a:	4108                	lw	a0,0(a0)
ffffffffc020523c:	bdbff06f          	j	ffffffffc0204e16 <do_wait>

ffffffffc0205240 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0205240:	000a5797          	auipc	a5,0xa5
ffffffffc0205244:	4a07b783          	ld	a5,1184(a5) # ffffffffc02aa6e0 <current>
ffffffffc0205248:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc020524a:	4501                	li	a0,0
ffffffffc020524c:	6a0c                	ld	a1,16(a2)
ffffffffc020524e:	e89fe06f          	j	ffffffffc02040d6 <do_fork>

ffffffffc0205252 <sys_exit>:
    return do_exit(error_code);
ffffffffc0205252:	4108                	lw	a0,0(a0)
ffffffffc0205254:	a78ff06f          	j	ffffffffc02044cc <do_exit>

ffffffffc0205258 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0205258:	711d                	addi	sp,sp,-96
ffffffffc020525a:	e0ca                	sd	s2,64(sp)
    struct trapframe *tf = current->tf;
ffffffffc020525c:	000a5917          	auipc	s2,0xa5
ffffffffc0205260:	48490913          	addi	s2,s2,1156 # ffffffffc02aa6e0 <current>
ffffffffc0205264:	00093703          	ld	a4,0(s2)
syscall(void) {
ffffffffc0205268:	e8a2                	sd	s0,80(sp)
ffffffffc020526a:	e4a6                	sd	s1,72(sp)
    struct trapframe *tf = current->tf;
ffffffffc020526c:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc020526e:	fc4e                	sd	s3,56(sp)
ffffffffc0205270:	ec86                	sd	ra,88(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
ffffffffc0205272:	4824                	lw	s1,80(s0)
    // Debug: print epc before and after syscall
    uintptr_t epc_before = tf->epc;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205274:	47fd                	li	a5,31
    uintptr_t epc_before = tf->epc;
ffffffffc0205276:	10843983          	ld	s3,264(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc020527a:	0497ee63          	bltu	a5,s1,ffffffffc02052d6 <syscall+0x7e>
        if (syscalls[num] != NULL) {
ffffffffc020527e:	00349713          	slli	a4,s1,0x3
ffffffffc0205282:	00002797          	auipc	a5,0x2
ffffffffc0205286:	39e78793          	addi	a5,a5,926 # ffffffffc0207620 <syscalls>
ffffffffc020528a:	97ba                	add	a5,a5,a4
ffffffffc020528c:	639c                	ld	a5,0(a5)
ffffffffc020528e:	c7a1                	beqz	a5,ffffffffc02052d6 <syscall+0x7e>
            arg[0] = tf->gpr.a1;
ffffffffc0205290:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
            arg[2] = tf->gpr.a3;
ffffffffc0205292:	7430                	ld	a2,104(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0205294:	702c                	ld	a1,96(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0205296:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0205298:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc020529a:	e42a                	sd	a0,8(sp)
            arg[2] = tf->gpr.a3;
ffffffffc020529c:	ec32                	sd	a2,24(sp)
            arg[1] = tf->gpr.a2;
ffffffffc020529e:	e82e                	sd	a1,16(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02052a0:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc02052a2:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02052a4:	0028                	addi	a0,sp,8
ffffffffc02052a6:	9782                	jalr	a5
            // Debug: check if epc was corrupted
            if (tf->epc != epc_before) {
ffffffffc02052a8:	10843603          	ld	a2,264(s0)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02052ac:	e828                	sd	a0,80(s0)
            if (tf->epc != epc_before) {
ffffffffc02052ae:	01360d63          	beq	a2,s3,ffffffffc02052c8 <syscall+0x70>
                cprintf("[BUG] epc changed! before=0x%lx, after=0x%lx, syscall=%d, pid=%d\n",
ffffffffc02052b2:	00093783          	ld	a5,0(s2)
ffffffffc02052b6:	86a6                	mv	a3,s1
ffffffffc02052b8:	85ce                	mv	a1,s3
ffffffffc02052ba:	43d8                	lw	a4,4(a5)
ffffffffc02052bc:	00002517          	auipc	a0,0x2
ffffffffc02052c0:	2d450513          	addi	a0,a0,724 # ffffffffc0207590 <default_pmm_manager+0xf18>
ffffffffc02052c4:	ed1fa0ef          	jal	ra,ffffffffc0200194 <cprintf>
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc02052c8:	60e6                	ld	ra,88(sp)
ffffffffc02052ca:	6446                	ld	s0,80(sp)
ffffffffc02052cc:	64a6                	ld	s1,72(sp)
ffffffffc02052ce:	6906                	ld	s2,64(sp)
ffffffffc02052d0:	79e2                	ld	s3,56(sp)
ffffffffc02052d2:	6125                	addi	sp,sp,96
ffffffffc02052d4:	8082                	ret
    print_trapframe(tf);
ffffffffc02052d6:	8522                	mv	a0,s0
ffffffffc02052d8:	8cdfb0ef          	jal	ra,ffffffffc0200ba4 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc02052dc:	00093783          	ld	a5,0(s2)
ffffffffc02052e0:	86a6                	mv	a3,s1
ffffffffc02052e2:	00002617          	auipc	a2,0x2
ffffffffc02052e6:	2f660613          	addi	a2,a2,758 # ffffffffc02075d8 <default_pmm_manager+0xf60>
ffffffffc02052ea:	43d8                	lw	a4,4(a5)
ffffffffc02052ec:	06900593          	li	a1,105
ffffffffc02052f0:	0b478793          	addi	a5,a5,180
ffffffffc02052f4:	00002517          	auipc	a0,0x2
ffffffffc02052f8:	31450513          	addi	a0,a0,788 # ffffffffc0207608 <default_pmm_manager+0xf90>
ffffffffc02052fc:	992fb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0205300 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0205300:	9e3707b7          	lui	a5,0x9e370
ffffffffc0205304:	2785                	addiw	a5,a5,1
ffffffffc0205306:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc020530a:	02000793          	li	a5,32
ffffffffc020530e:	9f8d                	subw	a5,a5,a1
}
ffffffffc0205310:	00f5553b          	srlw	a0,a0,a5
ffffffffc0205314:	8082                	ret

ffffffffc0205316 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0205316:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020531a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020531c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205320:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0205322:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205326:	f022                	sd	s0,32(sp)
ffffffffc0205328:	ec26                	sd	s1,24(sp)
ffffffffc020532a:	e84a                	sd	s2,16(sp)
ffffffffc020532c:	f406                	sd	ra,40(sp)
ffffffffc020532e:	e44e                	sd	s3,8(sp)
ffffffffc0205330:	84aa                	mv	s1,a0
ffffffffc0205332:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0205334:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0205338:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020533a:	03067e63          	bgeu	a2,a6,ffffffffc0205376 <printnum+0x60>
ffffffffc020533e:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0205340:	00805763          	blez	s0,ffffffffc020534e <printnum+0x38>
ffffffffc0205344:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0205346:	85ca                	mv	a1,s2
ffffffffc0205348:	854e                	mv	a0,s3
ffffffffc020534a:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020534c:	fc65                	bnez	s0,ffffffffc0205344 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020534e:	1a02                	slli	s4,s4,0x20
ffffffffc0205350:	00002797          	auipc	a5,0x2
ffffffffc0205354:	3d078793          	addi	a5,a5,976 # ffffffffc0207720 <syscalls+0x100>
ffffffffc0205358:	020a5a13          	srli	s4,s4,0x20
ffffffffc020535c:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc020535e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205360:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0205364:	70a2                	ld	ra,40(sp)
ffffffffc0205366:	69a2                	ld	s3,8(sp)
ffffffffc0205368:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020536a:	85ca                	mv	a1,s2
ffffffffc020536c:	87a6                	mv	a5,s1
}
ffffffffc020536e:	6942                	ld	s2,16(sp)
ffffffffc0205370:	64e2                	ld	s1,24(sp)
ffffffffc0205372:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205374:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0205376:	03065633          	divu	a2,a2,a6
ffffffffc020537a:	8722                	mv	a4,s0
ffffffffc020537c:	f9bff0ef          	jal	ra,ffffffffc0205316 <printnum>
ffffffffc0205380:	b7f9                	j	ffffffffc020534e <printnum+0x38>

ffffffffc0205382 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0205382:	7119                	addi	sp,sp,-128
ffffffffc0205384:	f4a6                	sd	s1,104(sp)
ffffffffc0205386:	f0ca                	sd	s2,96(sp)
ffffffffc0205388:	ecce                	sd	s3,88(sp)
ffffffffc020538a:	e8d2                	sd	s4,80(sp)
ffffffffc020538c:	e4d6                	sd	s5,72(sp)
ffffffffc020538e:	e0da                	sd	s6,64(sp)
ffffffffc0205390:	fc5e                	sd	s7,56(sp)
ffffffffc0205392:	f06a                	sd	s10,32(sp)
ffffffffc0205394:	fc86                	sd	ra,120(sp)
ffffffffc0205396:	f8a2                	sd	s0,112(sp)
ffffffffc0205398:	f862                	sd	s8,48(sp)
ffffffffc020539a:	f466                	sd	s9,40(sp)
ffffffffc020539c:	ec6e                	sd	s11,24(sp)
ffffffffc020539e:	892a                	mv	s2,a0
ffffffffc02053a0:	84ae                	mv	s1,a1
ffffffffc02053a2:	8d32                	mv	s10,a2
ffffffffc02053a4:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02053a6:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02053aa:	5b7d                	li	s6,-1
ffffffffc02053ac:	00002a97          	auipc	s5,0x2
ffffffffc02053b0:	3a0a8a93          	addi	s5,s5,928 # ffffffffc020774c <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02053b4:	00002b97          	auipc	s7,0x2
ffffffffc02053b8:	5b4b8b93          	addi	s7,s7,1460 # ffffffffc0207968 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02053bc:	000d4503          	lbu	a0,0(s10)
ffffffffc02053c0:	001d0413          	addi	s0,s10,1
ffffffffc02053c4:	01350a63          	beq	a0,s3,ffffffffc02053d8 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02053c8:	c121                	beqz	a0,ffffffffc0205408 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02053ca:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02053cc:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02053ce:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02053d0:	fff44503          	lbu	a0,-1(s0)
ffffffffc02053d4:	ff351ae3          	bne	a0,s3,ffffffffc02053c8 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02053d8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02053dc:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02053e0:	4c81                	li	s9,0
ffffffffc02053e2:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02053e4:	5c7d                	li	s8,-1
ffffffffc02053e6:	5dfd                	li	s11,-1
ffffffffc02053e8:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02053ec:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02053ee:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02053f2:	0ff5f593          	zext.b	a1,a1
ffffffffc02053f6:	00140d13          	addi	s10,s0,1
ffffffffc02053fa:	04b56263          	bltu	a0,a1,ffffffffc020543e <vprintfmt+0xbc>
ffffffffc02053fe:	058a                	slli	a1,a1,0x2
ffffffffc0205400:	95d6                	add	a1,a1,s5
ffffffffc0205402:	4194                	lw	a3,0(a1)
ffffffffc0205404:	96d6                	add	a3,a3,s5
ffffffffc0205406:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0205408:	70e6                	ld	ra,120(sp)
ffffffffc020540a:	7446                	ld	s0,112(sp)
ffffffffc020540c:	74a6                	ld	s1,104(sp)
ffffffffc020540e:	7906                	ld	s2,96(sp)
ffffffffc0205410:	69e6                	ld	s3,88(sp)
ffffffffc0205412:	6a46                	ld	s4,80(sp)
ffffffffc0205414:	6aa6                	ld	s5,72(sp)
ffffffffc0205416:	6b06                	ld	s6,64(sp)
ffffffffc0205418:	7be2                	ld	s7,56(sp)
ffffffffc020541a:	7c42                	ld	s8,48(sp)
ffffffffc020541c:	7ca2                	ld	s9,40(sp)
ffffffffc020541e:	7d02                	ld	s10,32(sp)
ffffffffc0205420:	6de2                	ld	s11,24(sp)
ffffffffc0205422:	6109                	addi	sp,sp,128
ffffffffc0205424:	8082                	ret
            padc = '0';
ffffffffc0205426:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0205428:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020542c:	846a                	mv	s0,s10
ffffffffc020542e:	00140d13          	addi	s10,s0,1
ffffffffc0205432:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0205436:	0ff5f593          	zext.b	a1,a1
ffffffffc020543a:	fcb572e3          	bgeu	a0,a1,ffffffffc02053fe <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020543e:	85a6                	mv	a1,s1
ffffffffc0205440:	02500513          	li	a0,37
ffffffffc0205444:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0205446:	fff44783          	lbu	a5,-1(s0)
ffffffffc020544a:	8d22                	mv	s10,s0
ffffffffc020544c:	f73788e3          	beq	a5,s3,ffffffffc02053bc <vprintfmt+0x3a>
ffffffffc0205450:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0205454:	1d7d                	addi	s10,s10,-1
ffffffffc0205456:	ff379de3          	bne	a5,s3,ffffffffc0205450 <vprintfmt+0xce>
ffffffffc020545a:	b78d                	j	ffffffffc02053bc <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020545c:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0205460:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205464:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0205466:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020546a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020546e:	02d86463          	bltu	a6,a3,ffffffffc0205496 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0205472:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0205476:	002c169b          	slliw	a3,s8,0x2
ffffffffc020547a:	0186873b          	addw	a4,a3,s8
ffffffffc020547e:	0017171b          	slliw	a4,a4,0x1
ffffffffc0205482:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0205484:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0205488:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020548a:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020548e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0205492:	fed870e3          	bgeu	a6,a3,ffffffffc0205472 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0205496:	f40ddce3          	bgez	s11,ffffffffc02053ee <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020549a:	8de2                	mv	s11,s8
ffffffffc020549c:	5c7d                	li	s8,-1
ffffffffc020549e:	bf81                	j	ffffffffc02053ee <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02054a0:	fffdc693          	not	a3,s11
ffffffffc02054a4:	96fd                	srai	a3,a3,0x3f
ffffffffc02054a6:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02054aa:	00144603          	lbu	a2,1(s0)
ffffffffc02054ae:	2d81                	sext.w	s11,s11
ffffffffc02054b0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02054b2:	bf35                	j	ffffffffc02053ee <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02054b4:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02054b8:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02054bc:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02054be:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02054c0:	bfd9                	j	ffffffffc0205496 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02054c2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02054c4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02054c8:	01174463          	blt	a4,a7,ffffffffc02054d0 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02054cc:	1a088e63          	beqz	a7,ffffffffc0205688 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02054d0:	000a3603          	ld	a2,0(s4)
ffffffffc02054d4:	46c1                	li	a3,16
ffffffffc02054d6:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02054d8:	2781                	sext.w	a5,a5
ffffffffc02054da:	876e                	mv	a4,s11
ffffffffc02054dc:	85a6                	mv	a1,s1
ffffffffc02054de:	854a                	mv	a0,s2
ffffffffc02054e0:	e37ff0ef          	jal	ra,ffffffffc0205316 <printnum>
            break;
ffffffffc02054e4:	bde1                	j	ffffffffc02053bc <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02054e6:	000a2503          	lw	a0,0(s4)
ffffffffc02054ea:	85a6                	mv	a1,s1
ffffffffc02054ec:	0a21                	addi	s4,s4,8
ffffffffc02054ee:	9902                	jalr	s2
            break;
ffffffffc02054f0:	b5f1                	j	ffffffffc02053bc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02054f2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02054f4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02054f8:	01174463          	blt	a4,a7,ffffffffc0205500 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02054fc:	18088163          	beqz	a7,ffffffffc020567e <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0205500:	000a3603          	ld	a2,0(s4)
ffffffffc0205504:	46a9                	li	a3,10
ffffffffc0205506:	8a2e                	mv	s4,a1
ffffffffc0205508:	bfc1                	j	ffffffffc02054d8 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020550a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020550e:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205510:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0205512:	bdf1                	j	ffffffffc02053ee <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0205514:	85a6                	mv	a1,s1
ffffffffc0205516:	02500513          	li	a0,37
ffffffffc020551a:	9902                	jalr	s2
            break;
ffffffffc020551c:	b545                	j	ffffffffc02053bc <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020551e:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0205522:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205524:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0205526:	b5e1                	j	ffffffffc02053ee <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0205528:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020552a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020552e:	01174463          	blt	a4,a7,ffffffffc0205536 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0205532:	14088163          	beqz	a7,ffffffffc0205674 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0205536:	000a3603          	ld	a2,0(s4)
ffffffffc020553a:	46a1                	li	a3,8
ffffffffc020553c:	8a2e                	mv	s4,a1
ffffffffc020553e:	bf69                	j	ffffffffc02054d8 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0205540:	03000513          	li	a0,48
ffffffffc0205544:	85a6                	mv	a1,s1
ffffffffc0205546:	e03e                	sd	a5,0(sp)
ffffffffc0205548:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020554a:	85a6                	mv	a1,s1
ffffffffc020554c:	07800513          	li	a0,120
ffffffffc0205550:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0205552:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0205554:	6782                	ld	a5,0(sp)
ffffffffc0205556:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0205558:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020555c:	bfb5                	j	ffffffffc02054d8 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020555e:	000a3403          	ld	s0,0(s4)
ffffffffc0205562:	008a0713          	addi	a4,s4,8
ffffffffc0205566:	e03a                	sd	a4,0(sp)
ffffffffc0205568:	14040263          	beqz	s0,ffffffffc02056ac <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020556c:	0fb05763          	blez	s11,ffffffffc020565a <vprintfmt+0x2d8>
ffffffffc0205570:	02d00693          	li	a3,45
ffffffffc0205574:	0cd79163          	bne	a5,a3,ffffffffc0205636 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205578:	00044783          	lbu	a5,0(s0)
ffffffffc020557c:	0007851b          	sext.w	a0,a5
ffffffffc0205580:	cf85                	beqz	a5,ffffffffc02055b8 <vprintfmt+0x236>
ffffffffc0205582:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205586:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020558a:	000c4563          	bltz	s8,ffffffffc0205594 <vprintfmt+0x212>
ffffffffc020558e:	3c7d                	addiw	s8,s8,-1
ffffffffc0205590:	036c0263          	beq	s8,s6,ffffffffc02055b4 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0205594:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205596:	0e0c8e63          	beqz	s9,ffffffffc0205692 <vprintfmt+0x310>
ffffffffc020559a:	3781                	addiw	a5,a5,-32
ffffffffc020559c:	0ef47b63          	bgeu	s0,a5,ffffffffc0205692 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02055a0:	03f00513          	li	a0,63
ffffffffc02055a4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02055a6:	000a4783          	lbu	a5,0(s4)
ffffffffc02055aa:	3dfd                	addiw	s11,s11,-1
ffffffffc02055ac:	0a05                	addi	s4,s4,1
ffffffffc02055ae:	0007851b          	sext.w	a0,a5
ffffffffc02055b2:	ffe1                	bnez	a5,ffffffffc020558a <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02055b4:	01b05963          	blez	s11,ffffffffc02055c6 <vprintfmt+0x244>
ffffffffc02055b8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02055ba:	85a6                	mv	a1,s1
ffffffffc02055bc:	02000513          	li	a0,32
ffffffffc02055c0:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02055c2:	fe0d9be3          	bnez	s11,ffffffffc02055b8 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02055c6:	6a02                	ld	s4,0(sp)
ffffffffc02055c8:	bbd5                	j	ffffffffc02053bc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02055ca:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02055cc:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02055d0:	01174463          	blt	a4,a7,ffffffffc02055d8 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02055d4:	08088d63          	beqz	a7,ffffffffc020566e <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02055d8:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02055dc:	0a044d63          	bltz	s0,ffffffffc0205696 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02055e0:	8622                	mv	a2,s0
ffffffffc02055e2:	8a66                	mv	s4,s9
ffffffffc02055e4:	46a9                	li	a3,10
ffffffffc02055e6:	bdcd                	j	ffffffffc02054d8 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02055e8:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02055ec:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02055ee:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02055f0:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02055f4:	8fb5                	xor	a5,a5,a3
ffffffffc02055f6:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02055fa:	02d74163          	blt	a4,a3,ffffffffc020561c <vprintfmt+0x29a>
ffffffffc02055fe:	00369793          	slli	a5,a3,0x3
ffffffffc0205602:	97de                	add	a5,a5,s7
ffffffffc0205604:	639c                	ld	a5,0(a5)
ffffffffc0205606:	cb99                	beqz	a5,ffffffffc020561c <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0205608:	86be                	mv	a3,a5
ffffffffc020560a:	00000617          	auipc	a2,0x0
ffffffffc020560e:	1ee60613          	addi	a2,a2,494 # ffffffffc02057f8 <etext+0x28>
ffffffffc0205612:	85a6                	mv	a1,s1
ffffffffc0205614:	854a                	mv	a0,s2
ffffffffc0205616:	0ce000ef          	jal	ra,ffffffffc02056e4 <printfmt>
ffffffffc020561a:	b34d                	j	ffffffffc02053bc <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020561c:	00002617          	auipc	a2,0x2
ffffffffc0205620:	12460613          	addi	a2,a2,292 # ffffffffc0207740 <syscalls+0x120>
ffffffffc0205624:	85a6                	mv	a1,s1
ffffffffc0205626:	854a                	mv	a0,s2
ffffffffc0205628:	0bc000ef          	jal	ra,ffffffffc02056e4 <printfmt>
ffffffffc020562c:	bb41                	j	ffffffffc02053bc <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020562e:	00002417          	auipc	s0,0x2
ffffffffc0205632:	10a40413          	addi	s0,s0,266 # ffffffffc0207738 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205636:	85e2                	mv	a1,s8
ffffffffc0205638:	8522                	mv	a0,s0
ffffffffc020563a:	e43e                	sd	a5,8(sp)
ffffffffc020563c:	0e2000ef          	jal	ra,ffffffffc020571e <strnlen>
ffffffffc0205640:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0205644:	01b05b63          	blez	s11,ffffffffc020565a <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0205648:	67a2                	ld	a5,8(sp)
ffffffffc020564a:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020564e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0205650:	85a6                	mv	a1,s1
ffffffffc0205652:	8552                	mv	a0,s4
ffffffffc0205654:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205656:	fe0d9ce3          	bnez	s11,ffffffffc020564e <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020565a:	00044783          	lbu	a5,0(s0)
ffffffffc020565e:	00140a13          	addi	s4,s0,1
ffffffffc0205662:	0007851b          	sext.w	a0,a5
ffffffffc0205666:	d3a5                	beqz	a5,ffffffffc02055c6 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205668:	05e00413          	li	s0,94
ffffffffc020566c:	bf39                	j	ffffffffc020558a <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020566e:	000a2403          	lw	s0,0(s4)
ffffffffc0205672:	b7ad                	j	ffffffffc02055dc <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0205674:	000a6603          	lwu	a2,0(s4)
ffffffffc0205678:	46a1                	li	a3,8
ffffffffc020567a:	8a2e                	mv	s4,a1
ffffffffc020567c:	bdb1                	j	ffffffffc02054d8 <vprintfmt+0x156>
ffffffffc020567e:	000a6603          	lwu	a2,0(s4)
ffffffffc0205682:	46a9                	li	a3,10
ffffffffc0205684:	8a2e                	mv	s4,a1
ffffffffc0205686:	bd89                	j	ffffffffc02054d8 <vprintfmt+0x156>
ffffffffc0205688:	000a6603          	lwu	a2,0(s4)
ffffffffc020568c:	46c1                	li	a3,16
ffffffffc020568e:	8a2e                	mv	s4,a1
ffffffffc0205690:	b5a1                	j	ffffffffc02054d8 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0205692:	9902                	jalr	s2
ffffffffc0205694:	bf09                	j	ffffffffc02055a6 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0205696:	85a6                	mv	a1,s1
ffffffffc0205698:	02d00513          	li	a0,45
ffffffffc020569c:	e03e                	sd	a5,0(sp)
ffffffffc020569e:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02056a0:	6782                	ld	a5,0(sp)
ffffffffc02056a2:	8a66                	mv	s4,s9
ffffffffc02056a4:	40800633          	neg	a2,s0
ffffffffc02056a8:	46a9                	li	a3,10
ffffffffc02056aa:	b53d                	j	ffffffffc02054d8 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02056ac:	03b05163          	blez	s11,ffffffffc02056ce <vprintfmt+0x34c>
ffffffffc02056b0:	02d00693          	li	a3,45
ffffffffc02056b4:	f6d79de3          	bne	a5,a3,ffffffffc020562e <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02056b8:	00002417          	auipc	s0,0x2
ffffffffc02056bc:	08040413          	addi	s0,s0,128 # ffffffffc0207738 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02056c0:	02800793          	li	a5,40
ffffffffc02056c4:	02800513          	li	a0,40
ffffffffc02056c8:	00140a13          	addi	s4,s0,1
ffffffffc02056cc:	bd6d                	j	ffffffffc0205586 <vprintfmt+0x204>
ffffffffc02056ce:	00002a17          	auipc	s4,0x2
ffffffffc02056d2:	06ba0a13          	addi	s4,s4,107 # ffffffffc0207739 <syscalls+0x119>
ffffffffc02056d6:	02800513          	li	a0,40
ffffffffc02056da:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02056de:	05e00413          	li	s0,94
ffffffffc02056e2:	b565                	j	ffffffffc020558a <vprintfmt+0x208>

ffffffffc02056e4 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02056e4:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02056e6:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02056ea:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02056ec:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02056ee:	ec06                	sd	ra,24(sp)
ffffffffc02056f0:	f83a                	sd	a4,48(sp)
ffffffffc02056f2:	fc3e                	sd	a5,56(sp)
ffffffffc02056f4:	e0c2                	sd	a6,64(sp)
ffffffffc02056f6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02056f8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02056fa:	c89ff0ef          	jal	ra,ffffffffc0205382 <vprintfmt>
}
ffffffffc02056fe:	60e2                	ld	ra,24(sp)
ffffffffc0205700:	6161                	addi	sp,sp,80
ffffffffc0205702:	8082                	ret

ffffffffc0205704 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0205704:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0205708:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc020570a:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc020570c:	cb81                	beqz	a5,ffffffffc020571c <strlen+0x18>
        cnt ++;
ffffffffc020570e:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0205710:	00a707b3          	add	a5,a4,a0
ffffffffc0205714:	0007c783          	lbu	a5,0(a5)
ffffffffc0205718:	fbfd                	bnez	a5,ffffffffc020570e <strlen+0xa>
ffffffffc020571a:	8082                	ret
    }
    return cnt;
}
ffffffffc020571c:	8082                	ret

ffffffffc020571e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020571e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205720:	e589                	bnez	a1,ffffffffc020572a <strnlen+0xc>
ffffffffc0205722:	a811                	j	ffffffffc0205736 <strnlen+0x18>
        cnt ++;
ffffffffc0205724:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205726:	00f58863          	beq	a1,a5,ffffffffc0205736 <strnlen+0x18>
ffffffffc020572a:	00f50733          	add	a4,a0,a5
ffffffffc020572e:	00074703          	lbu	a4,0(a4)
ffffffffc0205732:	fb6d                	bnez	a4,ffffffffc0205724 <strnlen+0x6>
ffffffffc0205734:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0205736:	852e                	mv	a0,a1
ffffffffc0205738:	8082                	ret

ffffffffc020573a <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020573a:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020573c:	0005c703          	lbu	a4,0(a1)
ffffffffc0205740:	0785                	addi	a5,a5,1
ffffffffc0205742:	0585                	addi	a1,a1,1
ffffffffc0205744:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0205748:	fb75                	bnez	a4,ffffffffc020573c <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020574a:	8082                	ret

ffffffffc020574c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020574c:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205750:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205754:	cb89                	beqz	a5,ffffffffc0205766 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0205756:	0505                	addi	a0,a0,1
ffffffffc0205758:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020575a:	fee789e3          	beq	a5,a4,ffffffffc020574c <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020575e:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0205762:	9d19                	subw	a0,a0,a4
ffffffffc0205764:	8082                	ret
ffffffffc0205766:	4501                	li	a0,0
ffffffffc0205768:	bfed                	j	ffffffffc0205762 <strcmp+0x16>

ffffffffc020576a <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020576a:	c20d                	beqz	a2,ffffffffc020578c <strncmp+0x22>
ffffffffc020576c:	962e                	add	a2,a2,a1
ffffffffc020576e:	a031                	j	ffffffffc020577a <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0205770:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205772:	00e79a63          	bne	a5,a4,ffffffffc0205786 <strncmp+0x1c>
ffffffffc0205776:	00b60b63          	beq	a2,a1,ffffffffc020578c <strncmp+0x22>
ffffffffc020577a:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc020577e:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205780:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0205784:	f7f5                	bnez	a5,ffffffffc0205770 <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205786:	40e7853b          	subw	a0,a5,a4
}
ffffffffc020578a:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020578c:	4501                	li	a0,0
ffffffffc020578e:	8082                	ret

ffffffffc0205790 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0205790:	00054783          	lbu	a5,0(a0)
ffffffffc0205794:	c799                	beqz	a5,ffffffffc02057a2 <strchr+0x12>
        if (*s == c) {
ffffffffc0205796:	00f58763          	beq	a1,a5,ffffffffc02057a4 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020579a:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc020579e:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02057a0:	fbfd                	bnez	a5,ffffffffc0205796 <strchr+0x6>
    }
    return NULL;
ffffffffc02057a2:	4501                	li	a0,0
}
ffffffffc02057a4:	8082                	ret

ffffffffc02057a6 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02057a6:	ca01                	beqz	a2,ffffffffc02057b6 <memset+0x10>
ffffffffc02057a8:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02057aa:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02057ac:	0785                	addi	a5,a5,1
ffffffffc02057ae:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02057b2:	fec79de3          	bne	a5,a2,ffffffffc02057ac <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02057b6:	8082                	ret

ffffffffc02057b8 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02057b8:	ca19                	beqz	a2,ffffffffc02057ce <memcpy+0x16>
ffffffffc02057ba:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02057bc:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02057be:	0005c703          	lbu	a4,0(a1)
ffffffffc02057c2:	0585                	addi	a1,a1,1
ffffffffc02057c4:	0785                	addi	a5,a5,1
ffffffffc02057c6:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02057ca:	fec59ae3          	bne	a1,a2,ffffffffc02057be <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02057ce:	8082                	ret
