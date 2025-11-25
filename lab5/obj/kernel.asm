
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
ffffffffc0200062:	72c050ef          	jal	ra,ffffffffc020578e <memset>
    dtb_init();
ffffffffc0200066:	598000ef          	jal	ra,ffffffffc02005fe <dtb_init>
    cons_init(); // init the console
ffffffffc020006a:	522000ef          	jal	ra,ffffffffc020058c <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006e:	00005597          	auipc	a1,0x5
ffffffffc0200072:	74a58593          	addi	a1,a1,1866 # ffffffffc02057b8 <etext>
ffffffffc0200076:	00005517          	auipc	a0,0x5
ffffffffc020007a:	76250513          	addi	a0,a0,1890 # ffffffffc02057d8 <etext+0x20>
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
ffffffffc0200092:	19d030ef          	jal	ra,ffffffffc0203a2e <vmm_init>
    proc_init(); // init process table
ffffffffc0200096:	64b040ef          	jal	ra,ffffffffc0204ee0 <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009a:	4a0000ef          	jal	ra,ffffffffc020053a <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc020009e:	111000ef          	jal	ra,ffffffffc02009ae <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a2:	7d7040ef          	jal	ra,ffffffffc0205078 <cpu_idle>

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
ffffffffc02000c0:	72450513          	addi	a0,a0,1828 # ffffffffc02057e0 <etext+0x28>
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
ffffffffc0200188:	1e2050ef          	jal	ra,ffffffffc020536a <vprintfmt>
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
ffffffffc02001be:	1ac050ef          	jal	ra,ffffffffc020536a <vprintfmt>
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
ffffffffc0200222:	5ca50513          	addi	a0,a0,1482 # ffffffffc02057e8 <etext+0x30>
{
ffffffffc0200226:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200228:	f6dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020022c:	00000597          	auipc	a1,0x0
ffffffffc0200230:	e1e58593          	addi	a1,a1,-482 # ffffffffc020004a <kern_init>
ffffffffc0200234:	00005517          	auipc	a0,0x5
ffffffffc0200238:	5d450513          	addi	a0,a0,1492 # ffffffffc0205808 <etext+0x50>
ffffffffc020023c:	f59ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200240:	00005597          	auipc	a1,0x5
ffffffffc0200244:	57858593          	addi	a1,a1,1400 # ffffffffc02057b8 <etext>
ffffffffc0200248:	00005517          	auipc	a0,0x5
ffffffffc020024c:	5e050513          	addi	a0,a0,1504 # ffffffffc0205828 <etext+0x70>
ffffffffc0200250:	f45ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200254:	000a6597          	auipc	a1,0xa6
ffffffffc0200258:	ffc58593          	addi	a1,a1,-4 # ffffffffc02a6250 <buf>
ffffffffc020025c:	00005517          	auipc	a0,0x5
ffffffffc0200260:	5ec50513          	addi	a0,a0,1516 # ffffffffc0205848 <etext+0x90>
ffffffffc0200264:	f31ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200268:	000aa597          	auipc	a1,0xaa
ffffffffc020026c:	49458593          	addi	a1,a1,1172 # ffffffffc02aa6fc <end>
ffffffffc0200270:	00005517          	auipc	a0,0x5
ffffffffc0200274:	5f850513          	addi	a0,a0,1528 # ffffffffc0205868 <etext+0xb0>
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
ffffffffc02002a2:	5ea50513          	addi	a0,a0,1514 # ffffffffc0205888 <etext+0xd0>
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
ffffffffc02002b0:	60c60613          	addi	a2,a2,1548 # ffffffffc02058b8 <etext+0x100>
ffffffffc02002b4:	04f00593          	li	a1,79
ffffffffc02002b8:	00005517          	auipc	a0,0x5
ffffffffc02002bc:	61850513          	addi	a0,a0,1560 # ffffffffc02058d0 <etext+0x118>
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
ffffffffc02002cc:	62060613          	addi	a2,a2,1568 # ffffffffc02058e8 <etext+0x130>
ffffffffc02002d0:	00005597          	auipc	a1,0x5
ffffffffc02002d4:	63858593          	addi	a1,a1,1592 # ffffffffc0205908 <etext+0x150>
ffffffffc02002d8:	00005517          	auipc	a0,0x5
ffffffffc02002dc:	63850513          	addi	a0,a0,1592 # ffffffffc0205910 <etext+0x158>
{
ffffffffc02002e0:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e2:	eb3ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02002e6:	00005617          	auipc	a2,0x5
ffffffffc02002ea:	63a60613          	addi	a2,a2,1594 # ffffffffc0205920 <etext+0x168>
ffffffffc02002ee:	00005597          	auipc	a1,0x5
ffffffffc02002f2:	65a58593          	addi	a1,a1,1626 # ffffffffc0205948 <etext+0x190>
ffffffffc02002f6:	00005517          	auipc	a0,0x5
ffffffffc02002fa:	61a50513          	addi	a0,a0,1562 # ffffffffc0205910 <etext+0x158>
ffffffffc02002fe:	e97ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200302:	00005617          	auipc	a2,0x5
ffffffffc0200306:	65660613          	addi	a2,a2,1622 # ffffffffc0205958 <etext+0x1a0>
ffffffffc020030a:	00005597          	auipc	a1,0x5
ffffffffc020030e:	66e58593          	addi	a1,a1,1646 # ffffffffc0205978 <etext+0x1c0>
ffffffffc0200312:	00005517          	auipc	a0,0x5
ffffffffc0200316:	5fe50513          	addi	a0,a0,1534 # ffffffffc0205910 <etext+0x158>
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
ffffffffc0200350:	63c50513          	addi	a0,a0,1596 # ffffffffc0205988 <etext+0x1d0>
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
ffffffffc0200372:	64250513          	addi	a0,a0,1602 # ffffffffc02059b0 <etext+0x1f8>
ffffffffc0200376:	e1fff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    if (tf != NULL)
ffffffffc020037a:	000b8563          	beqz	s7,ffffffffc0200384 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020037e:	855e                	mv	a0,s7
ffffffffc0200380:	025000ef          	jal	ra,ffffffffc0200ba4 <print_trapframe>
ffffffffc0200384:	00005c17          	auipc	s8,0x5
ffffffffc0200388:	69cc0c13          	addi	s8,s8,1692 # ffffffffc0205a20 <commands>
        if ((buf = readline("K> ")) != NULL)
ffffffffc020038c:	00005917          	auipc	s2,0x5
ffffffffc0200390:	64c90913          	addi	s2,s2,1612 # ffffffffc02059d8 <etext+0x220>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200394:	00005497          	auipc	s1,0x5
ffffffffc0200398:	64c48493          	addi	s1,s1,1612 # ffffffffc02059e0 <etext+0x228>
        if (argc == MAXARGS - 1)
ffffffffc020039c:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020039e:	00005b17          	auipc	s6,0x5
ffffffffc02003a2:	64ab0b13          	addi	s6,s6,1610 # ffffffffc02059e8 <etext+0x230>
        argv[argc++] = buf;
ffffffffc02003a6:	00005a17          	auipc	s4,0x5
ffffffffc02003aa:	562a0a13          	addi	s4,s4,1378 # ffffffffc0205908 <etext+0x150>
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
ffffffffc02003cc:	658d0d13          	addi	s10,s10,1624 # ffffffffc0205a20 <commands>
        argv[argc++] = buf;
ffffffffc02003d0:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc02003d2:	4401                	li	s0,0
ffffffffc02003d4:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc02003d6:	35e050ef          	jal	ra,ffffffffc0205734 <strcmp>
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
ffffffffc02003ea:	34a050ef          	jal	ra,ffffffffc0205734 <strcmp>
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
ffffffffc0200428:	350050ef          	jal	ra,ffffffffc0205778 <strchr>
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
ffffffffc0200466:	312050ef          	jal	ra,ffffffffc0205778 <strchr>
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
ffffffffc0200484:	58850513          	addi	a0,a0,1416 # ffffffffc0205a08 <etext+0x250>
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
ffffffffc02004c0:	5ac50513          	addi	a0,a0,1452 # ffffffffc0205a68 <commands+0x48>
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
ffffffffc02004d6:	69e50513          	addi	a0,a0,1694 # ffffffffc0206b70 <default_pmm_manager+0x578>
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
ffffffffc020050a:	58250513          	addi	a0,a0,1410 # ffffffffc0205a88 <commands+0x68>
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
ffffffffc020052a:	64a50513          	addi	a0,a0,1610 # ffffffffc0206b70 <default_pmm_manager+0x578>
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
ffffffffc0200564:	54850513          	addi	a0,a0,1352 # ffffffffc0205aa8 <commands+0x88>
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
ffffffffc0200604:	4c850513          	addi	a0,a0,1224 # ffffffffc0205ac8 <commands+0xa8>
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
ffffffffc0200632:	4aa50513          	addi	a0,a0,1194 # ffffffffc0205ad8 <commands+0xb8>
ffffffffc0200636:	b5fff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020063a:	0000b417          	auipc	s0,0xb
ffffffffc020063e:	9ce40413          	addi	s0,s0,-1586 # ffffffffc020b008 <boot_dtb>
ffffffffc0200642:	600c                	ld	a1,0(s0)
ffffffffc0200644:	00005517          	auipc	a0,0x5
ffffffffc0200648:	4a450513          	addi	a0,a0,1188 # ffffffffc0205ae8 <commands+0xc8>
ffffffffc020064c:	b49ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200650:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200654:	00005517          	auipc	a0,0x5
ffffffffc0200658:	4ac50513          	addi	a0,a0,1196 # ffffffffc0205b00 <commands+0xe0>
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
ffffffffc0200712:	44290913          	addi	s2,s2,1090 # ffffffffc0205b50 <commands+0x130>
ffffffffc0200716:	49bd                	li	s3,15
        switch (token) {
ffffffffc0200718:	4d91                	li	s11,4
ffffffffc020071a:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020071c:	00005497          	auipc	s1,0x5
ffffffffc0200720:	42c48493          	addi	s1,s1,1068 # ffffffffc0205b48 <commands+0x128>
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
ffffffffc0200774:	45850513          	addi	a0,a0,1112 # ffffffffc0205bc8 <commands+0x1a8>
ffffffffc0200778:	a1dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc020077c:	00005517          	auipc	a0,0x5
ffffffffc0200780:	48450513          	addi	a0,a0,1156 # ffffffffc0205c00 <commands+0x1e0>
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
ffffffffc02007c0:	36450513          	addi	a0,a0,868 # ffffffffc0205b20 <commands+0x100>
}
ffffffffc02007c4:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02007c6:	b2f9                	j	ffffffffc0200194 <cprintf>
                int name_len = strlen(name);
ffffffffc02007c8:	8556                	mv	a0,s5
ffffffffc02007ca:	723040ef          	jal	ra,ffffffffc02056ec <strlen>
ffffffffc02007ce:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02007d0:	4619                	li	a2,6
ffffffffc02007d2:	85a6                	mv	a1,s1
ffffffffc02007d4:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02007d6:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02007d8:	77b040ef          	jal	ra,ffffffffc0205752 <strncmp>
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
ffffffffc020086e:	6c7040ef          	jal	ra,ffffffffc0205734 <strcmp>
ffffffffc0200872:	66a2                	ld	a3,8(sp)
ffffffffc0200874:	f94d                	bnez	a0,ffffffffc0200826 <dtb_init+0x228>
ffffffffc0200876:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200826 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc020087a:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc020087e:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200882:	00005517          	auipc	a0,0x5
ffffffffc0200886:	2d650513          	addi	a0,a0,726 # ffffffffc0205b58 <commands+0x138>
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
ffffffffc0200954:	22850513          	addi	a0,a0,552 # ffffffffc0205b78 <commands+0x158>
ffffffffc0200958:	83dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020095c:	014b5613          	srli	a2,s6,0x14
ffffffffc0200960:	85da                	mv	a1,s6
ffffffffc0200962:	00005517          	auipc	a0,0x5
ffffffffc0200966:	22e50513          	addi	a0,a0,558 # ffffffffc0205b90 <commands+0x170>
ffffffffc020096a:	82bff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc020096e:	008b05b3          	add	a1,s6,s0
ffffffffc0200972:	15fd                	addi	a1,a1,-1
ffffffffc0200974:	00005517          	auipc	a0,0x5
ffffffffc0200978:	23c50513          	addi	a0,a0,572 # ffffffffc0205bb0 <commands+0x190>
ffffffffc020097c:	819ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("DTB init completed\n");
ffffffffc0200980:	00005517          	auipc	a0,0x5
ffffffffc0200984:	28050513          	addi	a0,a0,640 # ffffffffc0205c00 <commands+0x1e0>
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
ffffffffc02009e2:	23a50513          	addi	a0,a0,570 # ffffffffc0205c18 <commands+0x1f8>
{
ffffffffc02009e6:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009e8:	facff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02009ec:	640c                	ld	a1,8(s0)
ffffffffc02009ee:	00005517          	auipc	a0,0x5
ffffffffc02009f2:	24250513          	addi	a0,a0,578 # ffffffffc0205c30 <commands+0x210>
ffffffffc02009f6:	f9eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02009fa:	680c                	ld	a1,16(s0)
ffffffffc02009fc:	00005517          	auipc	a0,0x5
ffffffffc0200a00:	24c50513          	addi	a0,a0,588 # ffffffffc0205c48 <commands+0x228>
ffffffffc0200a04:	f90ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200a08:	6c0c                	ld	a1,24(s0)
ffffffffc0200a0a:	00005517          	auipc	a0,0x5
ffffffffc0200a0e:	25650513          	addi	a0,a0,598 # ffffffffc0205c60 <commands+0x240>
ffffffffc0200a12:	f82ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200a16:	700c                	ld	a1,32(s0)
ffffffffc0200a18:	00005517          	auipc	a0,0x5
ffffffffc0200a1c:	26050513          	addi	a0,a0,608 # ffffffffc0205c78 <commands+0x258>
ffffffffc0200a20:	f74ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200a24:	740c                	ld	a1,40(s0)
ffffffffc0200a26:	00005517          	auipc	a0,0x5
ffffffffc0200a2a:	26a50513          	addi	a0,a0,618 # ffffffffc0205c90 <commands+0x270>
ffffffffc0200a2e:	f66ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc0200a32:	780c                	ld	a1,48(s0)
ffffffffc0200a34:	00005517          	auipc	a0,0x5
ffffffffc0200a38:	27450513          	addi	a0,a0,628 # ffffffffc0205ca8 <commands+0x288>
ffffffffc0200a3c:	f58ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200a40:	7c0c                	ld	a1,56(s0)
ffffffffc0200a42:	00005517          	auipc	a0,0x5
ffffffffc0200a46:	27e50513          	addi	a0,a0,638 # ffffffffc0205cc0 <commands+0x2a0>
ffffffffc0200a4a:	f4aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200a4e:	602c                	ld	a1,64(s0)
ffffffffc0200a50:	00005517          	auipc	a0,0x5
ffffffffc0200a54:	28850513          	addi	a0,a0,648 # ffffffffc0205cd8 <commands+0x2b8>
ffffffffc0200a58:	f3cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200a5c:	642c                	ld	a1,72(s0)
ffffffffc0200a5e:	00005517          	auipc	a0,0x5
ffffffffc0200a62:	29250513          	addi	a0,a0,658 # ffffffffc0205cf0 <commands+0x2d0>
ffffffffc0200a66:	f2eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200a6a:	682c                	ld	a1,80(s0)
ffffffffc0200a6c:	00005517          	auipc	a0,0x5
ffffffffc0200a70:	29c50513          	addi	a0,a0,668 # ffffffffc0205d08 <commands+0x2e8>
ffffffffc0200a74:	f20ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200a78:	6c2c                	ld	a1,88(s0)
ffffffffc0200a7a:	00005517          	auipc	a0,0x5
ffffffffc0200a7e:	2a650513          	addi	a0,a0,678 # ffffffffc0205d20 <commands+0x300>
ffffffffc0200a82:	f12ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200a86:	702c                	ld	a1,96(s0)
ffffffffc0200a88:	00005517          	auipc	a0,0x5
ffffffffc0200a8c:	2b050513          	addi	a0,a0,688 # ffffffffc0205d38 <commands+0x318>
ffffffffc0200a90:	f04ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200a94:	742c                	ld	a1,104(s0)
ffffffffc0200a96:	00005517          	auipc	a0,0x5
ffffffffc0200a9a:	2ba50513          	addi	a0,a0,698 # ffffffffc0205d50 <commands+0x330>
ffffffffc0200a9e:	ef6ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200aa2:	782c                	ld	a1,112(s0)
ffffffffc0200aa4:	00005517          	auipc	a0,0x5
ffffffffc0200aa8:	2c450513          	addi	a0,a0,708 # ffffffffc0205d68 <commands+0x348>
ffffffffc0200aac:	ee8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200ab0:	7c2c                	ld	a1,120(s0)
ffffffffc0200ab2:	00005517          	auipc	a0,0x5
ffffffffc0200ab6:	2ce50513          	addi	a0,a0,718 # ffffffffc0205d80 <commands+0x360>
ffffffffc0200aba:	edaff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200abe:	604c                	ld	a1,128(s0)
ffffffffc0200ac0:	00005517          	auipc	a0,0x5
ffffffffc0200ac4:	2d850513          	addi	a0,a0,728 # ffffffffc0205d98 <commands+0x378>
ffffffffc0200ac8:	eccff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200acc:	644c                	ld	a1,136(s0)
ffffffffc0200ace:	00005517          	auipc	a0,0x5
ffffffffc0200ad2:	2e250513          	addi	a0,a0,738 # ffffffffc0205db0 <commands+0x390>
ffffffffc0200ad6:	ebeff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200ada:	684c                	ld	a1,144(s0)
ffffffffc0200adc:	00005517          	auipc	a0,0x5
ffffffffc0200ae0:	2ec50513          	addi	a0,a0,748 # ffffffffc0205dc8 <commands+0x3a8>
ffffffffc0200ae4:	eb0ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200ae8:	6c4c                	ld	a1,152(s0)
ffffffffc0200aea:	00005517          	auipc	a0,0x5
ffffffffc0200aee:	2f650513          	addi	a0,a0,758 # ffffffffc0205de0 <commands+0x3c0>
ffffffffc0200af2:	ea2ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200af6:	704c                	ld	a1,160(s0)
ffffffffc0200af8:	00005517          	auipc	a0,0x5
ffffffffc0200afc:	30050513          	addi	a0,a0,768 # ffffffffc0205df8 <commands+0x3d8>
ffffffffc0200b00:	e94ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200b04:	744c                	ld	a1,168(s0)
ffffffffc0200b06:	00005517          	auipc	a0,0x5
ffffffffc0200b0a:	30a50513          	addi	a0,a0,778 # ffffffffc0205e10 <commands+0x3f0>
ffffffffc0200b0e:	e86ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200b12:	784c                	ld	a1,176(s0)
ffffffffc0200b14:	00005517          	auipc	a0,0x5
ffffffffc0200b18:	31450513          	addi	a0,a0,788 # ffffffffc0205e28 <commands+0x408>
ffffffffc0200b1c:	e78ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200b20:	7c4c                	ld	a1,184(s0)
ffffffffc0200b22:	00005517          	auipc	a0,0x5
ffffffffc0200b26:	31e50513          	addi	a0,a0,798 # ffffffffc0205e40 <commands+0x420>
ffffffffc0200b2a:	e6aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200b2e:	606c                	ld	a1,192(s0)
ffffffffc0200b30:	00005517          	auipc	a0,0x5
ffffffffc0200b34:	32850513          	addi	a0,a0,808 # ffffffffc0205e58 <commands+0x438>
ffffffffc0200b38:	e5cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200b3c:	646c                	ld	a1,200(s0)
ffffffffc0200b3e:	00005517          	auipc	a0,0x5
ffffffffc0200b42:	33250513          	addi	a0,a0,818 # ffffffffc0205e70 <commands+0x450>
ffffffffc0200b46:	e4eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200b4a:	686c                	ld	a1,208(s0)
ffffffffc0200b4c:	00005517          	auipc	a0,0x5
ffffffffc0200b50:	33c50513          	addi	a0,a0,828 # ffffffffc0205e88 <commands+0x468>
ffffffffc0200b54:	e40ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200b58:	6c6c                	ld	a1,216(s0)
ffffffffc0200b5a:	00005517          	auipc	a0,0x5
ffffffffc0200b5e:	34650513          	addi	a0,a0,838 # ffffffffc0205ea0 <commands+0x480>
ffffffffc0200b62:	e32ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200b66:	706c                	ld	a1,224(s0)
ffffffffc0200b68:	00005517          	auipc	a0,0x5
ffffffffc0200b6c:	35050513          	addi	a0,a0,848 # ffffffffc0205eb8 <commands+0x498>
ffffffffc0200b70:	e24ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200b74:	746c                	ld	a1,232(s0)
ffffffffc0200b76:	00005517          	auipc	a0,0x5
ffffffffc0200b7a:	35a50513          	addi	a0,a0,858 # ffffffffc0205ed0 <commands+0x4b0>
ffffffffc0200b7e:	e16ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200b82:	786c                	ld	a1,240(s0)
ffffffffc0200b84:	00005517          	auipc	a0,0x5
ffffffffc0200b88:	36450513          	addi	a0,a0,868 # ffffffffc0205ee8 <commands+0x4c8>
ffffffffc0200b8c:	e08ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b90:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200b92:	6402                	ld	s0,0(sp)
ffffffffc0200b94:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b96:	00005517          	auipc	a0,0x5
ffffffffc0200b9a:	36a50513          	addi	a0,a0,874 # ffffffffc0205f00 <commands+0x4e0>
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
ffffffffc0200bb0:	36c50513          	addi	a0,a0,876 # ffffffffc0205f18 <commands+0x4f8>
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
ffffffffc0200bc8:	36c50513          	addi	a0,a0,876 # ffffffffc0205f30 <commands+0x510>
ffffffffc0200bcc:	dc8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200bd0:	10843583          	ld	a1,264(s0)
ffffffffc0200bd4:	00005517          	auipc	a0,0x5
ffffffffc0200bd8:	37450513          	addi	a0,a0,884 # ffffffffc0205f48 <commands+0x528>
ffffffffc0200bdc:	db8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200be0:	11043583          	ld	a1,272(s0)
ffffffffc0200be4:	00005517          	auipc	a0,0x5
ffffffffc0200be8:	37c50513          	addi	a0,a0,892 # ffffffffc0205f60 <commands+0x540>
ffffffffc0200bec:	da8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bf0:	11843583          	ld	a1,280(s0)
}
ffffffffc0200bf4:	6402                	ld	s0,0(sp)
ffffffffc0200bf6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bf8:	00005517          	auipc	a0,0x5
ffffffffc0200bfc:	37850513          	addi	a0,a0,888 # ffffffffc0205f70 <commands+0x550>
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
ffffffffc0200c18:	42470713          	addi	a4,a4,1060 # ffffffffc0206038 <commands+0x618>
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
ffffffffc0200c2a:	3c250513          	addi	a0,a0,962 # ffffffffc0205fe8 <commands+0x5c8>
ffffffffc0200c2e:	d66ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200c32:	00005517          	auipc	a0,0x5
ffffffffc0200c36:	39650513          	addi	a0,a0,918 # ffffffffc0205fc8 <commands+0x5a8>
ffffffffc0200c3a:	d5aff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200c3e:	00005517          	auipc	a0,0x5
ffffffffc0200c42:	34a50513          	addi	a0,a0,842 # ffffffffc0205f88 <commands+0x568>
ffffffffc0200c46:	d4eff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200c4a:	00005517          	auipc	a0,0x5
ffffffffc0200c4e:	35e50513          	addi	a0,a0,862 # ffffffffc0205fa8 <commands+0x588>
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
ffffffffc0200c66:	a1e68693          	addi	a3,a3,-1506 # ffffffffc02aa680 <ticks>
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
ffffffffc0200c7e:	a6673703          	ld	a4,-1434(a4) # ffffffffc02aa6e0 <current>
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
ffffffffc0200c9e:	37e50513          	addi	a0,a0,894 # ffffffffc0206018 <commands+0x5f8>
ffffffffc0200ca2:	cf2ff06f          	j	ffffffffc0200194 <cprintf>
        print_trapframe(tf);
ffffffffc0200ca6:	bdfd                	j	ffffffffc0200ba4 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200ca8:	06400593          	li	a1,100
ffffffffc0200cac:	00005517          	auipc	a0,0x5
ffffffffc0200cb0:	35c50513          	addi	a0,a0,860 # ffffffffc0206008 <commands+0x5e8>
ffffffffc0200cb4:	ce0ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
            num++; // 打印次数加一
ffffffffc0200cb8:	000aa717          	auipc	a4,0xaa
ffffffffc0200cbc:	9e870713          	addi	a4,a4,-1560 # ffffffffc02aa6a0 <num>
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
ffffffffc0200cf2:	50a70713          	addi	a4,a4,1290 # ffffffffc02061f8 <commands+0x7d8>
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
ffffffffc0200d04:	45050513          	addi	a0,a0,1104 # ffffffffc0206150 <commands+0x730>
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
ffffffffc0200d1c:	54c0406f          	j	ffffffffc0205268 <syscall>
        cprintf("Environment call from H-mode\n");
ffffffffc0200d20:	00005517          	auipc	a0,0x5
ffffffffc0200d24:	45050513          	addi	a0,a0,1104 # ffffffffc0206170 <commands+0x750>
}
ffffffffc0200d28:	6402                	ld	s0,0(sp)
ffffffffc0200d2a:	60a2                	ld	ra,8(sp)
ffffffffc0200d2c:	0141                	addi	sp,sp,16
        cprintf("Instruction access fault\n");
ffffffffc0200d2e:	c66ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Environment call from M-mode\n");
ffffffffc0200d32:	00005517          	auipc	a0,0x5
ffffffffc0200d36:	45e50513          	addi	a0,a0,1118 # ffffffffc0206190 <commands+0x770>
ffffffffc0200d3a:	b7fd                	j	ffffffffc0200d28 <exception_handler+0x4c>
        cprintf("Instruction page fault\n");
ffffffffc0200d3c:	00005517          	auipc	a0,0x5
ffffffffc0200d40:	47450513          	addi	a0,a0,1140 # ffffffffc02061b0 <commands+0x790>
ffffffffc0200d44:	b7d5                	j	ffffffffc0200d28 <exception_handler+0x4c>
        cprintf("Load page fault\n");
ffffffffc0200d46:	00005517          	auipc	a0,0x5
ffffffffc0200d4a:	48250513          	addi	a0,a0,1154 # ffffffffc02061c8 <commands+0x7a8>
ffffffffc0200d4e:	bfe9                	j	ffffffffc0200d28 <exception_handler+0x4c>
        cprintf("Store/AMO page fault\n");
ffffffffc0200d50:	00005517          	auipc	a0,0x5
ffffffffc0200d54:	49050513          	addi	a0,a0,1168 # ffffffffc02061e0 <commands+0x7c0>
ffffffffc0200d58:	bfc1                	j	ffffffffc0200d28 <exception_handler+0x4c>
        cprintf("Instruction address misaligned\n");
ffffffffc0200d5a:	00005517          	auipc	a0,0x5
ffffffffc0200d5e:	30e50513          	addi	a0,a0,782 # ffffffffc0206068 <commands+0x648>
ffffffffc0200d62:	b7d9                	j	ffffffffc0200d28 <exception_handler+0x4c>
        cprintf("Instruction access fault\n");
ffffffffc0200d64:	00005517          	auipc	a0,0x5
ffffffffc0200d68:	32450513          	addi	a0,a0,804 # ffffffffc0206088 <commands+0x668>
ffffffffc0200d6c:	bf75                	j	ffffffffc0200d28 <exception_handler+0x4c>
        cprintf("Illegal instruction\n");
ffffffffc0200d6e:	00005517          	auipc	a0,0x5
ffffffffc0200d72:	33a50513          	addi	a0,a0,826 # ffffffffc02060a8 <commands+0x688>
ffffffffc0200d76:	bf4d                	j	ffffffffc0200d28 <exception_handler+0x4c>
        cprintf("Breakpoint\n");
ffffffffc0200d78:	00005517          	auipc	a0,0x5
ffffffffc0200d7c:	34850513          	addi	a0,a0,840 # ffffffffc02060c0 <commands+0x6a0>
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
ffffffffc0200d98:	33c50513          	addi	a0,a0,828 # ffffffffc02060d0 <commands+0x6b0>
ffffffffc0200d9c:	b771                	j	ffffffffc0200d28 <exception_handler+0x4c>
        cprintf("Load access fault\n");
ffffffffc0200d9e:	00005517          	auipc	a0,0x5
ffffffffc0200da2:	35250513          	addi	a0,a0,850 # ffffffffc02060f0 <commands+0x6d0>
ffffffffc0200da6:	b749                	j	ffffffffc0200d28 <exception_handler+0x4c>
        cprintf("Store/AMO access fault\n");
ffffffffc0200da8:	00005517          	auipc	a0,0x5
ffffffffc0200dac:	39050513          	addi	a0,a0,912 # ffffffffc0206138 <commands+0x718>
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
ffffffffc0200dc0:	34c60613          	addi	a2,a2,844 # ffffffffc0206108 <commands+0x6e8>
ffffffffc0200dc4:	0c400593          	li	a1,196
ffffffffc0200dc8:	00005517          	auipc	a0,0x5
ffffffffc0200dcc:	35850513          	addi	a0,a0,856 # ffffffffc0206120 <commands+0x700>
ffffffffc0200dd0:	ebeff0ef          	jal	ra,ffffffffc020048e <__panic>
            tf->epc += 4;
ffffffffc0200dd4:	10843783          	ld	a5,264(s0)
ffffffffc0200dd8:	0791                	addi	a5,a5,4
ffffffffc0200dda:	10f43423          	sd	a5,264(s0)
            syscall();
ffffffffc0200dde:	48a040ef          	jal	ra,ffffffffc0205268 <syscall>
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200de2:	000aa797          	auipc	a5,0xaa
ffffffffc0200de6:	8fe7b783          	ld	a5,-1794(a5) # ffffffffc02aa6e0 <current>
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
ffffffffc0200e02:	8e240413          	addi	s0,s0,-1822 # ffffffffc02aa6e0 <current>
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
ffffffffc0200e76:	3060406f          	j	ffffffffc020517c <schedule>
                do_exit(-E_KILLED);
ffffffffc0200e7a:	555d                	li	a0,-9
ffffffffc0200e7c:	61a030ef          	jal	ra,ffffffffc0204496 <do_exit>
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
ffffffffc0200f52:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cc8>

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
ffffffffc0200ffe:	65678793          	addi	a5,a5,1622 # ffffffffc02a6650 <free_area>
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
ffffffffc0201010:	65456503          	lwu	a0,1620(a0) # ffffffffc02a6660 <free_area+0x10>
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
ffffffffc020101e:	63640413          	addi	s0,s0,1590 # ffffffffc02a6650 <free_area>
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
ffffffffc02010aa:	6227b783          	ld	a5,1570(a5) # ffffffffc02aa6c8 <pages>
ffffffffc02010ae:	40fa8733          	sub	a4,s5,a5
ffffffffc02010b2:	00007617          	auipc	a2,0x7
ffffffffc02010b6:	9ce63603          	ld	a2,-1586(a2) # ffffffffc0207a80 <nbase>
ffffffffc02010ba:	8719                	srai	a4,a4,0x6
ffffffffc02010bc:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02010be:	000a9697          	auipc	a3,0xa9
ffffffffc02010c2:	6026b683          	ld	a3,1538(a3) # ffffffffc02aa6c0 <npage>
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
ffffffffc0201100:	5607a223          	sw	zero,1380(a5) # ffffffffc02a6660 <free_area+0x10>
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
ffffffffc02011e2:	4807a123          	sw	zero,1154(a5) # ffffffffc02a6660 <free_area+0x10>
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
ffffffffc02012fc:	f4068693          	addi	a3,a3,-192 # ffffffffc0206238 <commands+0x818>
ffffffffc0201300:	00005617          	auipc	a2,0x5
ffffffffc0201304:	f4860613          	addi	a2,a2,-184 # ffffffffc0206248 <commands+0x828>
ffffffffc0201308:	11000593          	li	a1,272
ffffffffc020130c:	00005517          	auipc	a0,0x5
ffffffffc0201310:	f5450513          	addi	a0,a0,-172 # ffffffffc0206260 <commands+0x840>
ffffffffc0201314:	97aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201318:	00005697          	auipc	a3,0x5
ffffffffc020131c:	fe068693          	addi	a3,a3,-32 # ffffffffc02062f8 <commands+0x8d8>
ffffffffc0201320:	00005617          	auipc	a2,0x5
ffffffffc0201324:	f2860613          	addi	a2,a2,-216 # ffffffffc0206248 <commands+0x828>
ffffffffc0201328:	0db00593          	li	a1,219
ffffffffc020132c:	00005517          	auipc	a0,0x5
ffffffffc0201330:	f3450513          	addi	a0,a0,-204 # ffffffffc0206260 <commands+0x840>
ffffffffc0201334:	95aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201338:	00005697          	auipc	a3,0x5
ffffffffc020133c:	fe868693          	addi	a3,a3,-24 # ffffffffc0206320 <commands+0x900>
ffffffffc0201340:	00005617          	auipc	a2,0x5
ffffffffc0201344:	f0860613          	addi	a2,a2,-248 # ffffffffc0206248 <commands+0x828>
ffffffffc0201348:	0dc00593          	li	a1,220
ffffffffc020134c:	00005517          	auipc	a0,0x5
ffffffffc0201350:	f1450513          	addi	a0,a0,-236 # ffffffffc0206260 <commands+0x840>
ffffffffc0201354:	93aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201358:	00005697          	auipc	a3,0x5
ffffffffc020135c:	00868693          	addi	a3,a3,8 # ffffffffc0206360 <commands+0x940>
ffffffffc0201360:	00005617          	auipc	a2,0x5
ffffffffc0201364:	ee860613          	addi	a2,a2,-280 # ffffffffc0206248 <commands+0x828>
ffffffffc0201368:	0de00593          	li	a1,222
ffffffffc020136c:	00005517          	auipc	a0,0x5
ffffffffc0201370:	ef450513          	addi	a0,a0,-268 # ffffffffc0206260 <commands+0x840>
ffffffffc0201374:	91aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201378:	00005697          	auipc	a3,0x5
ffffffffc020137c:	07068693          	addi	a3,a3,112 # ffffffffc02063e8 <commands+0x9c8>
ffffffffc0201380:	00005617          	auipc	a2,0x5
ffffffffc0201384:	ec860613          	addi	a2,a2,-312 # ffffffffc0206248 <commands+0x828>
ffffffffc0201388:	0f700593          	li	a1,247
ffffffffc020138c:	00005517          	auipc	a0,0x5
ffffffffc0201390:	ed450513          	addi	a0,a0,-300 # ffffffffc0206260 <commands+0x840>
ffffffffc0201394:	8faff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201398:	00005697          	auipc	a3,0x5
ffffffffc020139c:	f0068693          	addi	a3,a3,-256 # ffffffffc0206298 <commands+0x878>
ffffffffc02013a0:	00005617          	auipc	a2,0x5
ffffffffc02013a4:	ea860613          	addi	a2,a2,-344 # ffffffffc0206248 <commands+0x828>
ffffffffc02013a8:	0f000593          	li	a1,240
ffffffffc02013ac:	00005517          	auipc	a0,0x5
ffffffffc02013b0:	eb450513          	addi	a0,a0,-332 # ffffffffc0206260 <commands+0x840>
ffffffffc02013b4:	8daff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free == 3);
ffffffffc02013b8:	00005697          	auipc	a3,0x5
ffffffffc02013bc:	02068693          	addi	a3,a3,32 # ffffffffc02063d8 <commands+0x9b8>
ffffffffc02013c0:	00005617          	auipc	a2,0x5
ffffffffc02013c4:	e8860613          	addi	a2,a2,-376 # ffffffffc0206248 <commands+0x828>
ffffffffc02013c8:	0ee00593          	li	a1,238
ffffffffc02013cc:	00005517          	auipc	a0,0x5
ffffffffc02013d0:	e9450513          	addi	a0,a0,-364 # ffffffffc0206260 <commands+0x840>
ffffffffc02013d4:	8baff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013d8:	00005697          	auipc	a3,0x5
ffffffffc02013dc:	fe868693          	addi	a3,a3,-24 # ffffffffc02063c0 <commands+0x9a0>
ffffffffc02013e0:	00005617          	auipc	a2,0x5
ffffffffc02013e4:	e6860613          	addi	a2,a2,-408 # ffffffffc0206248 <commands+0x828>
ffffffffc02013e8:	0e900593          	li	a1,233
ffffffffc02013ec:	00005517          	auipc	a0,0x5
ffffffffc02013f0:	e7450513          	addi	a0,a0,-396 # ffffffffc0206260 <commands+0x840>
ffffffffc02013f4:	89aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02013f8:	00005697          	auipc	a3,0x5
ffffffffc02013fc:	fa868693          	addi	a3,a3,-88 # ffffffffc02063a0 <commands+0x980>
ffffffffc0201400:	00005617          	auipc	a2,0x5
ffffffffc0201404:	e4860613          	addi	a2,a2,-440 # ffffffffc0206248 <commands+0x828>
ffffffffc0201408:	0e000593          	li	a1,224
ffffffffc020140c:	00005517          	auipc	a0,0x5
ffffffffc0201410:	e5450513          	addi	a0,a0,-428 # ffffffffc0206260 <commands+0x840>
ffffffffc0201414:	87aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(p0 != NULL);
ffffffffc0201418:	00005697          	auipc	a3,0x5
ffffffffc020141c:	01868693          	addi	a3,a3,24 # ffffffffc0206430 <commands+0xa10>
ffffffffc0201420:	00005617          	auipc	a2,0x5
ffffffffc0201424:	e2860613          	addi	a2,a2,-472 # ffffffffc0206248 <commands+0x828>
ffffffffc0201428:	11800593          	li	a1,280
ffffffffc020142c:	00005517          	auipc	a0,0x5
ffffffffc0201430:	e3450513          	addi	a0,a0,-460 # ffffffffc0206260 <commands+0x840>
ffffffffc0201434:	85aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free == 0);
ffffffffc0201438:	00005697          	auipc	a3,0x5
ffffffffc020143c:	fe868693          	addi	a3,a3,-24 # ffffffffc0206420 <commands+0xa00>
ffffffffc0201440:	00005617          	auipc	a2,0x5
ffffffffc0201444:	e0860613          	addi	a2,a2,-504 # ffffffffc0206248 <commands+0x828>
ffffffffc0201448:	0fd00593          	li	a1,253
ffffffffc020144c:	00005517          	auipc	a0,0x5
ffffffffc0201450:	e1450513          	addi	a0,a0,-492 # ffffffffc0206260 <commands+0x840>
ffffffffc0201454:	83aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201458:	00005697          	auipc	a3,0x5
ffffffffc020145c:	f6868693          	addi	a3,a3,-152 # ffffffffc02063c0 <commands+0x9a0>
ffffffffc0201460:	00005617          	auipc	a2,0x5
ffffffffc0201464:	de860613          	addi	a2,a2,-536 # ffffffffc0206248 <commands+0x828>
ffffffffc0201468:	0fb00593          	li	a1,251
ffffffffc020146c:	00005517          	auipc	a0,0x5
ffffffffc0201470:	df450513          	addi	a0,a0,-524 # ffffffffc0206260 <commands+0x840>
ffffffffc0201474:	81aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201478:	00005697          	auipc	a3,0x5
ffffffffc020147c:	f8868693          	addi	a3,a3,-120 # ffffffffc0206400 <commands+0x9e0>
ffffffffc0201480:	00005617          	auipc	a2,0x5
ffffffffc0201484:	dc860613          	addi	a2,a2,-568 # ffffffffc0206248 <commands+0x828>
ffffffffc0201488:	0fa00593          	li	a1,250
ffffffffc020148c:	00005517          	auipc	a0,0x5
ffffffffc0201490:	dd450513          	addi	a0,a0,-556 # ffffffffc0206260 <commands+0x840>
ffffffffc0201494:	ffbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201498:	00005697          	auipc	a3,0x5
ffffffffc020149c:	e0068693          	addi	a3,a3,-512 # ffffffffc0206298 <commands+0x878>
ffffffffc02014a0:	00005617          	auipc	a2,0x5
ffffffffc02014a4:	da860613          	addi	a2,a2,-600 # ffffffffc0206248 <commands+0x828>
ffffffffc02014a8:	0d700593          	li	a1,215
ffffffffc02014ac:	00005517          	auipc	a0,0x5
ffffffffc02014b0:	db450513          	addi	a0,a0,-588 # ffffffffc0206260 <commands+0x840>
ffffffffc02014b4:	fdbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014b8:	00005697          	auipc	a3,0x5
ffffffffc02014bc:	f0868693          	addi	a3,a3,-248 # ffffffffc02063c0 <commands+0x9a0>
ffffffffc02014c0:	00005617          	auipc	a2,0x5
ffffffffc02014c4:	d8860613          	addi	a2,a2,-632 # ffffffffc0206248 <commands+0x828>
ffffffffc02014c8:	0f400593          	li	a1,244
ffffffffc02014cc:	00005517          	auipc	a0,0x5
ffffffffc02014d0:	d9450513          	addi	a0,a0,-620 # ffffffffc0206260 <commands+0x840>
ffffffffc02014d4:	fbbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02014d8:	00005697          	auipc	a3,0x5
ffffffffc02014dc:	e0068693          	addi	a3,a3,-512 # ffffffffc02062d8 <commands+0x8b8>
ffffffffc02014e0:	00005617          	auipc	a2,0x5
ffffffffc02014e4:	d6860613          	addi	a2,a2,-664 # ffffffffc0206248 <commands+0x828>
ffffffffc02014e8:	0f200593          	li	a1,242
ffffffffc02014ec:	00005517          	auipc	a0,0x5
ffffffffc02014f0:	d7450513          	addi	a0,a0,-652 # ffffffffc0206260 <commands+0x840>
ffffffffc02014f4:	f9bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02014f8:	00005697          	auipc	a3,0x5
ffffffffc02014fc:	dc068693          	addi	a3,a3,-576 # ffffffffc02062b8 <commands+0x898>
ffffffffc0201500:	00005617          	auipc	a2,0x5
ffffffffc0201504:	d4860613          	addi	a2,a2,-696 # ffffffffc0206248 <commands+0x828>
ffffffffc0201508:	0f100593          	li	a1,241
ffffffffc020150c:	00005517          	auipc	a0,0x5
ffffffffc0201510:	d5450513          	addi	a0,a0,-684 # ffffffffc0206260 <commands+0x840>
ffffffffc0201514:	f7bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201518:	00005697          	auipc	a3,0x5
ffffffffc020151c:	dc068693          	addi	a3,a3,-576 # ffffffffc02062d8 <commands+0x8b8>
ffffffffc0201520:	00005617          	auipc	a2,0x5
ffffffffc0201524:	d2860613          	addi	a2,a2,-728 # ffffffffc0206248 <commands+0x828>
ffffffffc0201528:	0d900593          	li	a1,217
ffffffffc020152c:	00005517          	auipc	a0,0x5
ffffffffc0201530:	d3450513          	addi	a0,a0,-716 # ffffffffc0206260 <commands+0x840>
ffffffffc0201534:	f5bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(count == 0);
ffffffffc0201538:	00005697          	auipc	a3,0x5
ffffffffc020153c:	04868693          	addi	a3,a3,72 # ffffffffc0206580 <commands+0xb60>
ffffffffc0201540:	00005617          	auipc	a2,0x5
ffffffffc0201544:	d0860613          	addi	a2,a2,-760 # ffffffffc0206248 <commands+0x828>
ffffffffc0201548:	14600593          	li	a1,326
ffffffffc020154c:	00005517          	auipc	a0,0x5
ffffffffc0201550:	d1450513          	addi	a0,a0,-748 # ffffffffc0206260 <commands+0x840>
ffffffffc0201554:	f3bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free == 0);
ffffffffc0201558:	00005697          	auipc	a3,0x5
ffffffffc020155c:	ec868693          	addi	a3,a3,-312 # ffffffffc0206420 <commands+0xa00>
ffffffffc0201560:	00005617          	auipc	a2,0x5
ffffffffc0201564:	ce860613          	addi	a2,a2,-792 # ffffffffc0206248 <commands+0x828>
ffffffffc0201568:	13a00593          	li	a1,314
ffffffffc020156c:	00005517          	auipc	a0,0x5
ffffffffc0201570:	cf450513          	addi	a0,a0,-780 # ffffffffc0206260 <commands+0x840>
ffffffffc0201574:	f1bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201578:	00005697          	auipc	a3,0x5
ffffffffc020157c:	e4868693          	addi	a3,a3,-440 # ffffffffc02063c0 <commands+0x9a0>
ffffffffc0201580:	00005617          	auipc	a2,0x5
ffffffffc0201584:	cc860613          	addi	a2,a2,-824 # ffffffffc0206248 <commands+0x828>
ffffffffc0201588:	13800593          	li	a1,312
ffffffffc020158c:	00005517          	auipc	a0,0x5
ffffffffc0201590:	cd450513          	addi	a0,a0,-812 # ffffffffc0206260 <commands+0x840>
ffffffffc0201594:	efbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201598:	00005697          	auipc	a3,0x5
ffffffffc020159c:	de868693          	addi	a3,a3,-536 # ffffffffc0206380 <commands+0x960>
ffffffffc02015a0:	00005617          	auipc	a2,0x5
ffffffffc02015a4:	ca860613          	addi	a2,a2,-856 # ffffffffc0206248 <commands+0x828>
ffffffffc02015a8:	0df00593          	li	a1,223
ffffffffc02015ac:	00005517          	auipc	a0,0x5
ffffffffc02015b0:	cb450513          	addi	a0,a0,-844 # ffffffffc0206260 <commands+0x840>
ffffffffc02015b4:	edbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02015b8:	00005697          	auipc	a3,0x5
ffffffffc02015bc:	f8868693          	addi	a3,a3,-120 # ffffffffc0206540 <commands+0xb20>
ffffffffc02015c0:	00005617          	auipc	a2,0x5
ffffffffc02015c4:	c8860613          	addi	a2,a2,-888 # ffffffffc0206248 <commands+0x828>
ffffffffc02015c8:	13200593          	li	a1,306
ffffffffc02015cc:	00005517          	auipc	a0,0x5
ffffffffc02015d0:	c9450513          	addi	a0,a0,-876 # ffffffffc0206260 <commands+0x840>
ffffffffc02015d4:	ebbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02015d8:	00005697          	auipc	a3,0x5
ffffffffc02015dc:	f4868693          	addi	a3,a3,-184 # ffffffffc0206520 <commands+0xb00>
ffffffffc02015e0:	00005617          	auipc	a2,0x5
ffffffffc02015e4:	c6860613          	addi	a2,a2,-920 # ffffffffc0206248 <commands+0x828>
ffffffffc02015e8:	13000593          	li	a1,304
ffffffffc02015ec:	00005517          	auipc	a0,0x5
ffffffffc02015f0:	c7450513          	addi	a0,a0,-908 # ffffffffc0206260 <commands+0x840>
ffffffffc02015f4:	e9bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02015f8:	00005697          	auipc	a3,0x5
ffffffffc02015fc:	f0068693          	addi	a3,a3,-256 # ffffffffc02064f8 <commands+0xad8>
ffffffffc0201600:	00005617          	auipc	a2,0x5
ffffffffc0201604:	c4860613          	addi	a2,a2,-952 # ffffffffc0206248 <commands+0x828>
ffffffffc0201608:	12e00593          	li	a1,302
ffffffffc020160c:	00005517          	auipc	a0,0x5
ffffffffc0201610:	c5450513          	addi	a0,a0,-940 # ffffffffc0206260 <commands+0x840>
ffffffffc0201614:	e7bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201618:	00005697          	auipc	a3,0x5
ffffffffc020161c:	eb868693          	addi	a3,a3,-328 # ffffffffc02064d0 <commands+0xab0>
ffffffffc0201620:	00005617          	auipc	a2,0x5
ffffffffc0201624:	c2860613          	addi	a2,a2,-984 # ffffffffc0206248 <commands+0x828>
ffffffffc0201628:	12d00593          	li	a1,301
ffffffffc020162c:	00005517          	auipc	a0,0x5
ffffffffc0201630:	c3450513          	addi	a0,a0,-972 # ffffffffc0206260 <commands+0x840>
ffffffffc0201634:	e5bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201638:	00005697          	auipc	a3,0x5
ffffffffc020163c:	e8868693          	addi	a3,a3,-376 # ffffffffc02064c0 <commands+0xaa0>
ffffffffc0201640:	00005617          	auipc	a2,0x5
ffffffffc0201644:	c0860613          	addi	a2,a2,-1016 # ffffffffc0206248 <commands+0x828>
ffffffffc0201648:	12800593          	li	a1,296
ffffffffc020164c:	00005517          	auipc	a0,0x5
ffffffffc0201650:	c1450513          	addi	a0,a0,-1004 # ffffffffc0206260 <commands+0x840>
ffffffffc0201654:	e3bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201658:	00005697          	auipc	a3,0x5
ffffffffc020165c:	d6868693          	addi	a3,a3,-664 # ffffffffc02063c0 <commands+0x9a0>
ffffffffc0201660:	00005617          	auipc	a2,0x5
ffffffffc0201664:	be860613          	addi	a2,a2,-1048 # ffffffffc0206248 <commands+0x828>
ffffffffc0201668:	12700593          	li	a1,295
ffffffffc020166c:	00005517          	auipc	a0,0x5
ffffffffc0201670:	bf450513          	addi	a0,a0,-1036 # ffffffffc0206260 <commands+0x840>
ffffffffc0201674:	e1bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201678:	00005697          	auipc	a3,0x5
ffffffffc020167c:	e2868693          	addi	a3,a3,-472 # ffffffffc02064a0 <commands+0xa80>
ffffffffc0201680:	00005617          	auipc	a2,0x5
ffffffffc0201684:	bc860613          	addi	a2,a2,-1080 # ffffffffc0206248 <commands+0x828>
ffffffffc0201688:	12600593          	li	a1,294
ffffffffc020168c:	00005517          	auipc	a0,0x5
ffffffffc0201690:	bd450513          	addi	a0,a0,-1068 # ffffffffc0206260 <commands+0x840>
ffffffffc0201694:	dfbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201698:	00005697          	auipc	a3,0x5
ffffffffc020169c:	dd868693          	addi	a3,a3,-552 # ffffffffc0206470 <commands+0xa50>
ffffffffc02016a0:	00005617          	auipc	a2,0x5
ffffffffc02016a4:	ba860613          	addi	a2,a2,-1112 # ffffffffc0206248 <commands+0x828>
ffffffffc02016a8:	12500593          	li	a1,293
ffffffffc02016ac:	00005517          	auipc	a0,0x5
ffffffffc02016b0:	bb450513          	addi	a0,a0,-1100 # ffffffffc0206260 <commands+0x840>
ffffffffc02016b4:	ddbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02016b8:	00005697          	auipc	a3,0x5
ffffffffc02016bc:	da068693          	addi	a3,a3,-608 # ffffffffc0206458 <commands+0xa38>
ffffffffc02016c0:	00005617          	auipc	a2,0x5
ffffffffc02016c4:	b8860613          	addi	a2,a2,-1144 # ffffffffc0206248 <commands+0x828>
ffffffffc02016c8:	12400593          	li	a1,292
ffffffffc02016cc:	00005517          	auipc	a0,0x5
ffffffffc02016d0:	b9450513          	addi	a0,a0,-1132 # ffffffffc0206260 <commands+0x840>
ffffffffc02016d4:	dbbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02016d8:	00005697          	auipc	a3,0x5
ffffffffc02016dc:	ce868693          	addi	a3,a3,-792 # ffffffffc02063c0 <commands+0x9a0>
ffffffffc02016e0:	00005617          	auipc	a2,0x5
ffffffffc02016e4:	b6860613          	addi	a2,a2,-1176 # ffffffffc0206248 <commands+0x828>
ffffffffc02016e8:	11e00593          	li	a1,286
ffffffffc02016ec:	00005517          	auipc	a0,0x5
ffffffffc02016f0:	b7450513          	addi	a0,a0,-1164 # ffffffffc0206260 <commands+0x840>
ffffffffc02016f4:	d9bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(!PageProperty(p0));
ffffffffc02016f8:	00005697          	auipc	a3,0x5
ffffffffc02016fc:	d4868693          	addi	a3,a3,-696 # ffffffffc0206440 <commands+0xa20>
ffffffffc0201700:	00005617          	auipc	a2,0x5
ffffffffc0201704:	b4860613          	addi	a2,a2,-1208 # ffffffffc0206248 <commands+0x828>
ffffffffc0201708:	11900593          	li	a1,281
ffffffffc020170c:	00005517          	auipc	a0,0x5
ffffffffc0201710:	b5450513          	addi	a0,a0,-1196 # ffffffffc0206260 <commands+0x840>
ffffffffc0201714:	d7bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201718:	00005697          	auipc	a3,0x5
ffffffffc020171c:	e4868693          	addi	a3,a3,-440 # ffffffffc0206560 <commands+0xb40>
ffffffffc0201720:	00005617          	auipc	a2,0x5
ffffffffc0201724:	b2860613          	addi	a2,a2,-1240 # ffffffffc0206248 <commands+0x828>
ffffffffc0201728:	13700593          	li	a1,311
ffffffffc020172c:	00005517          	auipc	a0,0x5
ffffffffc0201730:	b3450513          	addi	a0,a0,-1228 # ffffffffc0206260 <commands+0x840>
ffffffffc0201734:	d5bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(total == 0);
ffffffffc0201738:	00005697          	auipc	a3,0x5
ffffffffc020173c:	e5868693          	addi	a3,a3,-424 # ffffffffc0206590 <commands+0xb70>
ffffffffc0201740:	00005617          	auipc	a2,0x5
ffffffffc0201744:	b0860613          	addi	a2,a2,-1272 # ffffffffc0206248 <commands+0x828>
ffffffffc0201748:	14700593          	li	a1,327
ffffffffc020174c:	00005517          	auipc	a0,0x5
ffffffffc0201750:	b1450513          	addi	a0,a0,-1260 # ffffffffc0206260 <commands+0x840>
ffffffffc0201754:	d3bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(total == nr_free_pages());
ffffffffc0201758:	00005697          	auipc	a3,0x5
ffffffffc020175c:	b2068693          	addi	a3,a3,-1248 # ffffffffc0206278 <commands+0x858>
ffffffffc0201760:	00005617          	auipc	a2,0x5
ffffffffc0201764:	ae860613          	addi	a2,a2,-1304 # ffffffffc0206248 <commands+0x828>
ffffffffc0201768:	11300593          	li	a1,275
ffffffffc020176c:	00005517          	auipc	a0,0x5
ffffffffc0201770:	af450513          	addi	a0,a0,-1292 # ffffffffc0206260 <commands+0x840>
ffffffffc0201774:	d1bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201778:	00005697          	auipc	a3,0x5
ffffffffc020177c:	b4068693          	addi	a3,a3,-1216 # ffffffffc02062b8 <commands+0x898>
ffffffffc0201780:	00005617          	auipc	a2,0x5
ffffffffc0201784:	ac860613          	addi	a2,a2,-1336 # ffffffffc0206248 <commands+0x828>
ffffffffc0201788:	0d800593          	li	a1,216
ffffffffc020178c:	00005517          	auipc	a0,0x5
ffffffffc0201790:	ad450513          	addi	a0,a0,-1324 # ffffffffc0206260 <commands+0x840>
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
ffffffffc02017de:	e7668693          	addi	a3,a3,-394 # ffffffffc02a6650 <free_area>
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
ffffffffc02018c8:	ce468693          	addi	a3,a3,-796 # ffffffffc02065a8 <commands+0xb88>
ffffffffc02018cc:	00005617          	auipc	a2,0x5
ffffffffc02018d0:	97c60613          	addi	a2,a2,-1668 # ffffffffc0206248 <commands+0x828>
ffffffffc02018d4:	09400593          	li	a1,148
ffffffffc02018d8:	00005517          	auipc	a0,0x5
ffffffffc02018dc:	98850513          	addi	a0,a0,-1656 # ffffffffc0206260 <commands+0x840>
ffffffffc02018e0:	baffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(n > 0);
ffffffffc02018e4:	00005697          	auipc	a3,0x5
ffffffffc02018e8:	cbc68693          	addi	a3,a3,-836 # ffffffffc02065a0 <commands+0xb80>
ffffffffc02018ec:	00005617          	auipc	a2,0x5
ffffffffc02018f0:	95c60613          	addi	a2,a2,-1700 # ffffffffc0206248 <commands+0x828>
ffffffffc02018f4:	09000593          	li	a1,144
ffffffffc02018f8:	00005517          	auipc	a0,0x5
ffffffffc02018fc:	96850513          	addi	a0,a0,-1688 # ffffffffc0206260 <commands+0x840>
ffffffffc0201900:	b8ffe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201904 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201904:	c941                	beqz	a0,ffffffffc0201994 <default_alloc_pages+0x90>
    if (n > nr_free)
ffffffffc0201906:	000a5597          	auipc	a1,0xa5
ffffffffc020190a:	d4a58593          	addi	a1,a1,-694 # ffffffffc02a6650 <free_area>
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
ffffffffc020199a:	c0a68693          	addi	a3,a3,-1014 # ffffffffc02065a0 <commands+0xb80>
ffffffffc020199e:	00005617          	auipc	a2,0x5
ffffffffc02019a2:	8aa60613          	addi	a2,a2,-1878 # ffffffffc0206248 <commands+0x828>
ffffffffc02019a6:	06c00593          	li	a1,108
ffffffffc02019aa:	00005517          	auipc	a0,0x5
ffffffffc02019ae:	8b650513          	addi	a0,a0,-1866 # ffffffffc0206260 <commands+0x840>
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
ffffffffc02019f6:	c5e68693          	addi	a3,a3,-930 # ffffffffc02a6650 <free_area>
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
ffffffffc0201a6c:	b6868693          	addi	a3,a3,-1176 # ffffffffc02065d0 <commands+0xbb0>
ffffffffc0201a70:	00004617          	auipc	a2,0x4
ffffffffc0201a74:	7d860613          	addi	a2,a2,2008 # ffffffffc0206248 <commands+0x828>
ffffffffc0201a78:	04b00593          	li	a1,75
ffffffffc0201a7c:	00004517          	auipc	a0,0x4
ffffffffc0201a80:	7e450513          	addi	a0,a0,2020 # ffffffffc0206260 <commands+0x840>
ffffffffc0201a84:	a0bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(n > 0);
ffffffffc0201a88:	00005697          	auipc	a3,0x5
ffffffffc0201a8c:	b1868693          	addi	a3,a3,-1256 # ffffffffc02065a0 <commands+0xb80>
ffffffffc0201a90:	00004617          	auipc	a2,0x4
ffffffffc0201a94:	7b860613          	addi	a2,a2,1976 # ffffffffc0206248 <commands+0x828>
ffffffffc0201a98:	04700593          	li	a1,71
ffffffffc0201a9c:	00004517          	auipc	a0,0x4
ffffffffc0201aa0:	7c450513          	addi	a0,a0,1988 # ffffffffc0206260 <commands+0x840>
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
ffffffffc0201abe:	000a4617          	auipc	a2,0xa4
ffffffffc0201ac2:	78260613          	addi	a2,a2,1922 # ffffffffc02a6240 <slobfree>
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
ffffffffc0201b70:	b5c6b683          	ld	a3,-1188(a3) # ffffffffc02aa6c8 <pages>
ffffffffc0201b74:	8d15                	sub	a0,a0,a3
ffffffffc0201b76:	8519                	srai	a0,a0,0x6
ffffffffc0201b78:	00006697          	auipc	a3,0x6
ffffffffc0201b7c:	f086b683          	ld	a3,-248(a3) # ffffffffc0207a80 <nbase>
ffffffffc0201b80:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201b82:	00c51793          	slli	a5,a0,0xc
ffffffffc0201b86:	83b1                	srli	a5,a5,0xc
ffffffffc0201b88:	000a9717          	auipc	a4,0xa9
ffffffffc0201b8c:	b3873703          	ld	a4,-1224(a4) # ffffffffc02aa6c0 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201b90:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201b92:	00e7fa63          	bgeu	a5,a4,ffffffffc0201ba6 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201b96:	000a9697          	auipc	a3,0xa9
ffffffffc0201b9a:	b426b683          	ld	a3,-1214(a3) # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc0201b9e:	9536                	add	a0,a0,a3
}
ffffffffc0201ba0:	60a2                	ld	ra,8(sp)
ffffffffc0201ba2:	0141                	addi	sp,sp,16
ffffffffc0201ba4:	8082                	ret
ffffffffc0201ba6:	86aa                	mv	a3,a0
ffffffffc0201ba8:	00005617          	auipc	a2,0x5
ffffffffc0201bac:	a8860613          	addi	a2,a2,-1400 # ffffffffc0206630 <default_pmm_manager+0x38>
ffffffffc0201bb0:	07100593          	li	a1,113
ffffffffc0201bb4:	00005517          	auipc	a0,0x5
ffffffffc0201bb8:	aa450513          	addi	a0,a0,-1372 # ffffffffc0206658 <default_pmm_manager+0x60>
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
ffffffffc0201be4:	000a4917          	auipc	s2,0xa4
ffffffffc0201be8:	65c90913          	addi	s2,s2,1628 # ffffffffc02a6240 <slobfree>
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
ffffffffc0201c9a:	9d268693          	addi	a3,a3,-1582 # ffffffffc0206668 <default_pmm_manager+0x70>
ffffffffc0201c9e:	00004617          	auipc	a2,0x4
ffffffffc0201ca2:	5aa60613          	addi	a2,a2,1450 # ffffffffc0206248 <commands+0x828>
ffffffffc0201ca6:	06300593          	li	a1,99
ffffffffc0201caa:	00005517          	auipc	a0,0x5
ffffffffc0201cae:	9de50513          	addi	a0,a0,-1570 # ffffffffc0206688 <default_pmm_manager+0x90>
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
ffffffffc0201cbc:	9e850513          	addi	a0,a0,-1560 # ffffffffc02066a0 <default_pmm_manager+0xa8>
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
ffffffffc0201ccc:	9f050513          	addi	a0,a0,-1552 # ffffffffc02066b8 <default_pmm_manager+0xc0>
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
ffffffffc0201ce6:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bb9>
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
ffffffffc0201d26:	98678793          	addi	a5,a5,-1658 # ffffffffc02aa6a8 <bigblocks>
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
ffffffffc0201d62:	94a78793          	addi	a5,a5,-1718 # ffffffffc02aa6a8 <bigblocks>
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
ffffffffc0201da8:	9047b783          	ld	a5,-1788(a5) # ffffffffc02aa6a8 <bigblocks>
    return 0;
ffffffffc0201dac:	4601                	li	a2,0
ffffffffc0201dae:	cbad                	beqz	a5,ffffffffc0201e20 <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201db0:	000a9697          	auipc	a3,0xa9
ffffffffc0201db4:	8f868693          	addi	a3,a3,-1800 # ffffffffc02aa6a8 <bigblocks>
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
ffffffffc0201ddc:	9006b683          	ld	a3,-1792(a3) # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc0201de0:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage)
ffffffffc0201de2:	8031                	srli	s0,s0,0xc
ffffffffc0201de4:	000a9797          	auipc	a5,0xa9
ffffffffc0201de8:	8dc7b783          	ld	a5,-1828(a5) # ffffffffc02aa6c0 <npage>
ffffffffc0201dec:	06f47163          	bgeu	s0,a5,ffffffffc0201e4e <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201df0:	00006517          	auipc	a0,0x6
ffffffffc0201df4:	c9053503          	ld	a0,-880(a0) # ffffffffc0207a80 <nbase>
ffffffffc0201df8:	8c09                	sub	s0,s0,a0
ffffffffc0201dfa:	041a                	slli	s0,s0,0x6
	free_pages(kva2page(kva), 1 << order);
ffffffffc0201dfc:	000a9517          	auipc	a0,0xa9
ffffffffc0201e00:	8cc53503          	ld	a0,-1844(a0) # ffffffffc02aa6c8 <pages>
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
ffffffffc0201e38:	8747b783          	ld	a5,-1932(a5) # ffffffffc02aa6a8 <bigblocks>
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
ffffffffc0201e52:	8b260613          	addi	a2,a2,-1870 # ffffffffc0206700 <default_pmm_manager+0x108>
ffffffffc0201e56:	06900593          	li	a1,105
ffffffffc0201e5a:	00004517          	auipc	a0,0x4
ffffffffc0201e5e:	7fe50513          	addi	a0,a0,2046 # ffffffffc0206658 <default_pmm_manager+0x60>
ffffffffc0201e62:	e2cfe0ef          	jal	ra,ffffffffc020048e <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201e66:	86a2                	mv	a3,s0
ffffffffc0201e68:	00005617          	auipc	a2,0x5
ffffffffc0201e6c:	87060613          	addi	a2,a2,-1936 # ffffffffc02066d8 <default_pmm_manager+0xe0>
ffffffffc0201e70:	07700593          	li	a1,119
ffffffffc0201e74:	00004517          	auipc	a0,0x4
ffffffffc0201e78:	7e450513          	addi	a0,a0,2020 # ffffffffc0206658 <default_pmm_manager+0x60>
ffffffffc0201e7c:	e12fe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201e80 <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc0201e80:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201e82:	00005617          	auipc	a2,0x5
ffffffffc0201e86:	87e60613          	addi	a2,a2,-1922 # ffffffffc0206700 <default_pmm_manager+0x108>
ffffffffc0201e8a:	06900593          	li	a1,105
ffffffffc0201e8e:	00004517          	auipc	a0,0x4
ffffffffc0201e92:	7ca50513          	addi	a0,a0,1994 # ffffffffc0206658 <default_pmm_manager+0x60>
pa2page(uintptr_t pa)
ffffffffc0201e96:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201e98:	df6fe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201e9c <pte2page.part.0>:
pte2page(pte_t pte)
ffffffffc0201e9c:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201e9e:	00005617          	auipc	a2,0x5
ffffffffc0201ea2:	88260613          	addi	a2,a2,-1918 # ffffffffc0206720 <default_pmm_manager+0x128>
ffffffffc0201ea6:	07f00593          	li	a1,127
ffffffffc0201eaa:	00004517          	auipc	a0,0x4
ffffffffc0201eae:	7ae50513          	addi	a0,a0,1966 # ffffffffc0206658 <default_pmm_manager+0x60>
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
ffffffffc0201ec4:	8107b783          	ld	a5,-2032(a5) # ffffffffc02aa6d0 <pmm_manager>
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
ffffffffc0201ed8:	000a8797          	auipc	a5,0xa8
ffffffffc0201edc:	7f87b783          	ld	a5,2040(a5) # ffffffffc02aa6d0 <pmm_manager>
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
ffffffffc0201efe:	000a8797          	auipc	a5,0xa8
ffffffffc0201f02:	7d27b783          	ld	a5,2002(a5) # ffffffffc02aa6d0 <pmm_manager>
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
ffffffffc0201f1a:	000a8797          	auipc	a5,0xa8
ffffffffc0201f1e:	7b67b783          	ld	a5,1974(a5) # ffffffffc02aa6d0 <pmm_manager>
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
ffffffffc0201f3e:	000a8797          	auipc	a5,0xa8
ffffffffc0201f42:	7927b783          	ld	a5,1938(a5) # ffffffffc02aa6d0 <pmm_manager>
ffffffffc0201f46:	779c                	ld	a5,40(a5)
ffffffffc0201f48:	8782                	jr	a5
{
ffffffffc0201f4a:	1141                	addi	sp,sp,-16
ffffffffc0201f4c:	e406                	sd	ra,8(sp)
ffffffffc0201f4e:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201f50:	a65fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f54:	000a8797          	auipc	a5,0xa8
ffffffffc0201f58:	77c7b783          	ld	a5,1916(a5) # ffffffffc02aa6d0 <pmm_manager>
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
ffffffffc0201f9a:	000a8997          	auipc	s3,0xa8
ffffffffc0201f9e:	72698993          	addi	s3,s3,1830 # ffffffffc02aa6c0 <npage>
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
ffffffffc0201fb2:	000a8797          	auipc	a5,0xa8
ffffffffc0201fb6:	71e7b783          	ld	a5,1822(a5) # ffffffffc02aa6d0 <pmm_manager>
ffffffffc0201fba:	6f9c                	ld	a5,24(a5)
ffffffffc0201fbc:	4505                	li	a0,1
ffffffffc0201fbe:	9782                	jalr	a5
ffffffffc0201fc0:	842a                	mv	s0,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201fc2:	12040d63          	beqz	s0,ffffffffc02020fc <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0201fc6:	000a8b17          	auipc	s6,0xa8
ffffffffc0201fca:	702b0b13          	addi	s6,s6,1794 # ffffffffc02aa6c8 <pages>
ffffffffc0201fce:	000b3503          	ld	a0,0(s6)
ffffffffc0201fd2:	00080ab7          	lui	s5,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201fd6:	000a8997          	auipc	s3,0xa8
ffffffffc0201fda:	6ea98993          	addi	s3,s3,1770 # ffffffffc02aa6c0 <npage>
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
ffffffffc0201ffa:	000a8797          	auipc	a5,0xa8
ffffffffc0201ffe:	6de7b783          	ld	a5,1758(a5) # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc0202002:	6605                	lui	a2,0x1
ffffffffc0202004:	4581                	li	a1,0
ffffffffc0202006:	953e                	add	a0,a0,a5
ffffffffc0202008:	786030ef          	jal	ra,ffffffffc020578e <memset>
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
ffffffffc0202032:	000a8a97          	auipc	s5,0xa8
ffffffffc0202036:	6a6a8a93          	addi	s5,s5,1702 # ffffffffc02aa6d8 <va_pa_offset>
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
ffffffffc0202062:	000a8797          	auipc	a5,0xa8
ffffffffc0202066:	66e7b783          	ld	a5,1646(a5) # ffffffffc02aa6d0 <pmm_manager>
ffffffffc020206a:	6f9c                	ld	a5,24(a5)
ffffffffc020206c:	4505                	li	a0,1
ffffffffc020206e:	9782                	jalr	a5
ffffffffc0202070:	84aa                	mv	s1,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202072:	c4c9                	beqz	s1,ffffffffc02020fc <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0202074:	000a8b17          	auipc	s6,0xa8
ffffffffc0202078:	654b0b13          	addi	s6,s6,1620 # ffffffffc02aa6c8 <pages>
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
ffffffffc02020aa:	6e4030ef          	jal	ra,ffffffffc020578e <memset>
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
ffffffffc0202108:	5cc7b783          	ld	a5,1484(a5) # ffffffffc02aa6d0 <pmm_manager>
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
ffffffffc0202122:	5b27b783          	ld	a5,1458(a5) # ffffffffc02aa6d0 <pmm_manager>
ffffffffc0202126:	6f9c                	ld	a5,24(a5)
ffffffffc0202128:	4505                	li	a0,1
ffffffffc020212a:	9782                	jalr	a5
ffffffffc020212c:	84aa                	mv	s1,a0
        intr_enable();
ffffffffc020212e:	881fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202132:	b781                	j	ffffffffc0202072 <get_pte+0x102>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202134:	00004617          	auipc	a2,0x4
ffffffffc0202138:	4fc60613          	addi	a2,a2,1276 # ffffffffc0206630 <default_pmm_manager+0x38>
ffffffffc020213c:	0fa00593          	li	a1,250
ffffffffc0202140:	00004517          	auipc	a0,0x4
ffffffffc0202144:	60850513          	addi	a0,a0,1544 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0202148:	b46fe0ef          	jal	ra,ffffffffc020048e <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020214c:	00004617          	auipc	a2,0x4
ffffffffc0202150:	4e460613          	addi	a2,a2,1252 # ffffffffc0206630 <default_pmm_manager+0x38>
ffffffffc0202154:	0ed00593          	li	a1,237
ffffffffc0202158:	00004517          	auipc	a0,0x4
ffffffffc020215c:	5f050513          	addi	a0,a0,1520 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0202160:	b2efe0ef          	jal	ra,ffffffffc020048e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202164:	86aa                	mv	a3,a0
ffffffffc0202166:	00004617          	auipc	a2,0x4
ffffffffc020216a:	4ca60613          	addi	a2,a2,1226 # ffffffffc0206630 <default_pmm_manager+0x38>
ffffffffc020216e:	0e900593          	li	a1,233
ffffffffc0202172:	00004517          	auipc	a0,0x4
ffffffffc0202176:	5d650513          	addi	a0,a0,1494 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc020217a:	b14fe0ef          	jal	ra,ffffffffc020048e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020217e:	86aa                	mv	a3,a0
ffffffffc0202180:	00004617          	auipc	a2,0x4
ffffffffc0202184:	4b060613          	addi	a2,a2,1200 # ffffffffc0206630 <default_pmm_manager+0x38>
ffffffffc0202188:	0f700593          	li	a1,247
ffffffffc020218c:	00004517          	auipc	a0,0x4
ffffffffc0202190:	5bc50513          	addi	a0,a0,1468 # ffffffffc0206748 <default_pmm_manager+0x150>
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
ffffffffc02021c6:	4fe73703          	ld	a4,1278(a4) # ffffffffc02aa6c0 <npage>
ffffffffc02021ca:	00e7ff63          	bgeu	a5,a4,ffffffffc02021e8 <get_page+0x50>
ffffffffc02021ce:	60a2                	ld	ra,8(sp)
ffffffffc02021d0:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc02021d2:	fff80537          	lui	a0,0xfff80
ffffffffc02021d6:	97aa                	add	a5,a5,a0
ffffffffc02021d8:	079a                	slli	a5,a5,0x6
ffffffffc02021da:	000a8517          	auipc	a0,0xa8
ffffffffc02021de:	4ee53503          	ld	a0,1262(a0) # ffffffffc02aa6c8 <pages>
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
ffffffffc020222e:	496c8c93          	addi	s9,s9,1174 # ffffffffc02aa6c0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202232:	000a8c17          	auipc	s8,0xa8
ffffffffc0202236:	496c0c13          	addi	s8,s8,1174 # ffffffffc02aa6c8 <pages>
ffffffffc020223a:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc020223e:	000a8d17          	auipc	s10,0xa8
ffffffffc0202242:	492d0d13          	addi	s10,s10,1170 # ffffffffc02aa6d0 <pmm_manager>
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
ffffffffc02022f2:	46a68693          	addi	a3,a3,1130 # ffffffffc0206758 <default_pmm_manager+0x160>
ffffffffc02022f6:	00004617          	auipc	a2,0x4
ffffffffc02022fa:	f5260613          	addi	a2,a2,-174 # ffffffffc0206248 <commands+0x828>
ffffffffc02022fe:	12000593          	li	a1,288
ffffffffc0202302:	00004517          	auipc	a0,0x4
ffffffffc0202306:	44650513          	addi	a0,a0,1094 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc020230a:	984fe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020230e:	00004697          	auipc	a3,0x4
ffffffffc0202312:	47a68693          	addi	a3,a3,1146 # ffffffffc0206788 <default_pmm_manager+0x190>
ffffffffc0202316:	00004617          	auipc	a2,0x4
ffffffffc020231a:	f3260613          	addi	a2,a2,-206 # ffffffffc0206248 <commands+0x828>
ffffffffc020231e:	12100593          	li	a1,289
ffffffffc0202322:	00004517          	auipc	a0,0x4
ffffffffc0202326:	42650513          	addi	a0,a0,1062 # ffffffffc0206748 <default_pmm_manager+0x150>
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
ffffffffc020238c:	338d0d13          	addi	s10,s10,824 # ffffffffc02aa6c0 <npage>
    return KADDR(page2pa(page));
ffffffffc0202390:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0202394:	000a8717          	auipc	a4,0xa8
ffffffffc0202398:	33470713          	addi	a4,a4,820 # ffffffffc02aa6c8 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc020239c:	000a8d97          	auipc	s11,0xa8
ffffffffc02023a0:	334d8d93          	addi	s11,s11,820 # ffffffffc02aa6d0 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02023a4:	c0000437          	lui	s0,0xc0000
ffffffffc02023a8:	944e                	add	s0,s0,s3
ffffffffc02023aa:	8079                	srli	s0,s0,0x1e
ffffffffc02023ac:	1ff47413          	andi	s0,s0,511
ffffffffc02023b0:	040e                	slli	s0,s0,0x3
ffffffffc02023b2:	9462                	add	s0,s0,s8
ffffffffc02023b4:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ee8>
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
ffffffffc02023fc:	2e080813          	addi	a6,a6,736 # ffffffffc02aa6d8 <va_pa_offset>
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
ffffffffc0202490:	24c80813          	addi	a6,a6,588 # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc0202494:	fff80e37          	lui	t3,0xfff80
ffffffffc0202498:	00080337          	lui	t1,0x80
ffffffffc020249c:	6885                	lui	a7,0x1
ffffffffc020249e:	000a8717          	auipc	a4,0xa8
ffffffffc02024a2:	22a70713          	addi	a4,a4,554 # ffffffffc02aa6c8 <pages>
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
ffffffffc02024da:	1f270713          	addi	a4,a4,498 # ffffffffc02aa6c8 <pages>
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
ffffffffc0202528:	1a470713          	addi	a4,a4,420 # ffffffffc02aa6c8 <pages>
ffffffffc020252c:	6885                	lui	a7,0x1
ffffffffc020252e:	00080337          	lui	t1,0x80
ffffffffc0202532:	fff80e37          	lui	t3,0xfff80
ffffffffc0202536:	000a8817          	auipc	a6,0xa8
ffffffffc020253a:	1a280813          	addi	a6,a6,418 # ffffffffc02aa6d8 <va_pa_offset>
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
ffffffffc020255e:	16e70713          	addi	a4,a4,366 # ffffffffc02aa6c8 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202562:	00043023          	sd	zero,0(s0)
ffffffffc0202566:	bfb5                	j	ffffffffc02024e2 <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202568:	00004697          	auipc	a3,0x4
ffffffffc020256c:	1f068693          	addi	a3,a3,496 # ffffffffc0206758 <default_pmm_manager+0x160>
ffffffffc0202570:	00004617          	auipc	a2,0x4
ffffffffc0202574:	cd860613          	addi	a2,a2,-808 # ffffffffc0206248 <commands+0x828>
ffffffffc0202578:	13500593          	li	a1,309
ffffffffc020257c:	00004517          	auipc	a0,0x4
ffffffffc0202580:	1cc50513          	addi	a0,a0,460 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0202584:	f0bfd0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc0202588:	00004617          	auipc	a2,0x4
ffffffffc020258c:	0a860613          	addi	a2,a2,168 # ffffffffc0206630 <default_pmm_manager+0x38>
ffffffffc0202590:	07100593          	li	a1,113
ffffffffc0202594:	00004517          	auipc	a0,0x4
ffffffffc0202598:	0c450513          	addi	a0,a0,196 # ffffffffc0206658 <default_pmm_manager+0x60>
ffffffffc020259c:	ef3fd0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc02025a0:	8e1ff0ef          	jal	ra,ffffffffc0201e80 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc02025a4:	00004697          	auipc	a3,0x4
ffffffffc02025a8:	1e468693          	addi	a3,a3,484 # ffffffffc0206788 <default_pmm_manager+0x190>
ffffffffc02025ac:	00004617          	auipc	a2,0x4
ffffffffc02025b0:	c9c60613          	addi	a2,a2,-868 # ffffffffc0206248 <commands+0x828>
ffffffffc02025b4:	13600593          	li	a1,310
ffffffffc02025b8:	00004517          	auipc	a0,0x4
ffffffffc02025bc:	19050513          	addi	a0,a0,400 # ffffffffc0206748 <default_pmm_manager+0x150>
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
ffffffffc02025f2:	0d273703          	ld	a4,210(a4) # ffffffffc02aa6c0 <npage>
ffffffffc02025f6:	06e7f363          	bgeu	a5,a4,ffffffffc020265c <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc02025fa:	fff80537          	lui	a0,0xfff80
ffffffffc02025fe:	97aa                	add	a5,a5,a0
ffffffffc0202600:	079a                	slli	a5,a5,0x6
ffffffffc0202602:	000a8517          	auipc	a0,0xa8
ffffffffc0202606:	0c653503          	ld	a0,198(a0) # ffffffffc02aa6c8 <pages>
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
ffffffffc0202634:	0a07b783          	ld	a5,160(a5) # ffffffffc02aa6d0 <pmm_manager>
ffffffffc0202638:	739c                	ld	a5,32(a5)
ffffffffc020263a:	4585                	li	a1,1
ffffffffc020263c:	9782                	jalr	a5
    if (flag)
ffffffffc020263e:	bfe1                	j	ffffffffc0202616 <page_remove+0x52>
        intr_disable();
ffffffffc0202640:	e42a                	sd	a0,8(sp)
ffffffffc0202642:	b72fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202646:	000a8797          	auipc	a5,0xa8
ffffffffc020264a:	08a7b783          	ld	a5,138(a5) # ffffffffc02aa6d0 <pmm_manager>
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
ffffffffc0202696:	03673703          	ld	a4,54(a4) # ffffffffc02aa6c8 <pages>
ffffffffc020269a:	8c19                	sub	s0,s0,a4
ffffffffc020269c:	000807b7          	lui	a5,0x80
ffffffffc02026a0:	8419                	srai	s0,s0,0x6
ffffffffc02026a2:	943e                	add	s0,s0,a5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02026a4:	042a                	slli	s0,s0,0xa
ffffffffc02026a6:	8cc1                	or	s1,s1,s0
ffffffffc02026a8:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02026ac:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ee8>
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
ffffffffc02026d0:	ff473703          	ld	a4,-12(a4) # ffffffffc02aa6c0 <npage>
ffffffffc02026d4:	06e7ff63          	bgeu	a5,a4,ffffffffc0202752 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc02026d8:	000a8a97          	auipc	s5,0xa8
ffffffffc02026dc:	ff0a8a93          	addi	s5,s5,-16 # ffffffffc02aa6c8 <pages>
ffffffffc02026e0:	000ab703          	ld	a4,0(s5)
ffffffffc02026e4:	fff80937          	lui	s2,0xfff80
ffffffffc02026e8:	993e                	add	s2,s2,a5
ffffffffc02026ea:	091a                	slli	s2,s2,0x6
ffffffffc02026ec:	993a                	add	s2,s2,a4
        if (p == page)
ffffffffc02026ee:	01240c63          	beq	s0,s2,ffffffffc0202706 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc02026f2:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fcd5904>
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
ffffffffc0202716:	fbe7b783          	ld	a5,-66(a5) # ffffffffc02aa6d0 <pmm_manager>
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
ffffffffc0202734:	fa07b783          	ld	a5,-96(a5) # ffffffffc02aa6d0 <pmm_manager>
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
ffffffffc020275a:	ea278793          	addi	a5,a5,-350 # ffffffffc02065f8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020275e:	638c                	ld	a1,0(a5)
{
ffffffffc0202760:	7159                	addi	sp,sp,-112
ffffffffc0202762:	f85a                	sd	s6,48(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202764:	00004517          	auipc	a0,0x4
ffffffffc0202768:	03c50513          	addi	a0,a0,60 # ffffffffc02067a0 <default_pmm_manager+0x1a8>
    pmm_manager = &default_pmm_manager;
ffffffffc020276c:	000a8b17          	auipc	s6,0xa8
ffffffffc0202770:	f64b0b13          	addi	s6,s6,-156 # ffffffffc02aa6d0 <pmm_manager>
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
ffffffffc0202798:	f4498993          	addi	s3,s3,-188 # ffffffffc02aa6d8 <va_pa_offset>
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
ffffffffc02027bc:	02050513          	addi	a0,a0,32 # ffffffffc02067d8 <default_pmm_manager+0x1e0>
ffffffffc02027c0:	9d5fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc02027c4:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02027c8:	fff40693          	addi	a3,s0,-1
ffffffffc02027cc:	864a                	mv	a2,s2
ffffffffc02027ce:	85a6                	mv	a1,s1
ffffffffc02027d0:	00004517          	auipc	a0,0x4
ffffffffc02027d4:	02050513          	addi	a0,a0,32 # ffffffffc02067f0 <default_pmm_manager+0x1f8>
ffffffffc02027d8:	9bdfd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc02027dc:	c8000737          	lui	a4,0xc8000
ffffffffc02027e0:	87a2                	mv	a5,s0
ffffffffc02027e2:	54876163          	bltu	a4,s0,ffffffffc0202d24 <pmm_init+0x5ce>
ffffffffc02027e6:	757d                	lui	a0,0xfffff
ffffffffc02027e8:	000a9617          	auipc	a2,0xa9
ffffffffc02027ec:	f1360613          	addi	a2,a2,-237 # ffffffffc02ab6fb <end+0xfff>
ffffffffc02027f0:	8e69                	and	a2,a2,a0
ffffffffc02027f2:	000a8497          	auipc	s1,0xa8
ffffffffc02027f6:	ece48493          	addi	s1,s1,-306 # ffffffffc02aa6c0 <npage>
ffffffffc02027fa:	00c7d513          	srli	a0,a5,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02027fe:	000a8b97          	auipc	s7,0xa8
ffffffffc0202802:	ecab8b93          	addi	s7,s7,-310 # ffffffffc02aa6c8 <pages>
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
ffffffffc0202824:	00850713          	addi	a4,a0,8 # fffffffffffff008 <end+0x3fd5490c>
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
ffffffffc020285c:	fc050513          	addi	a0,a0,-64 # ffffffffc0206818 <default_pmm_manager+0x220>
ffffffffc0202860:	935fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc0202864:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0202868:	000a8917          	auipc	s2,0xa8
ffffffffc020286c:	e5090913          	addi	s2,s2,-432 # ffffffffc02aa6b8 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc0202870:	7b9c                	ld	a5,48(a5)
ffffffffc0202872:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202874:	00004517          	auipc	a0,0x4
ffffffffc0202878:	fbc50513          	addi	a0,a0,-68 # ffffffffc0206830 <default_pmm_manager+0x238>
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
ffffffffc020289e:	e0d7bb23          	sd	a3,-490(a5) # ffffffffc02aa6b0 <boot_pgdir_pa>
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
ffffffffc020293c:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8ba8>
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
ffffffffc0202b0a:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd54904>
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
ffffffffc0202b2e:	02e50513          	addi	a0,a0,46 # ffffffffc0206b58 <default_pmm_manager+0x560>
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
ffffffffc0202bc4:	000a2703          	lw	a4,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8ba8>
ffffffffc0202bc8:	4785                	li	a5,1
ffffffffc0202bca:	42f71963          	bne	a4,a5,ffffffffc0202ffc <pmm_init+0x8a6>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202bce:	00093503          	ld	a0,0(s2)
ffffffffc0202bd2:	6405                	lui	s0,0x1
ffffffffc0202bd4:	4699                	li	a3,6
ffffffffc0202bd6:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8aa8>
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
ffffffffc0202bf2:	0b258593          	addi	a1,a1,178 # ffffffffc0206ca0 <default_pmm_manager+0x6a8>
ffffffffc0202bf6:	10000513          	li	a0,256
ffffffffc0202bfa:	329020ef          	jal	ra,ffffffffc0205722 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202bfe:	10040593          	addi	a1,s0,256
ffffffffc0202c02:	10000513          	li	a0,256
ffffffffc0202c06:	32f020ef          	jal	ra,ffffffffc0205734 <strcmp>
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
ffffffffc0202c3c:	2b1020ef          	jal	ra,ffffffffc02056ec <strlen>
ffffffffc0202c40:	66051363          	bnez	a0,ffffffffc02032a6 <pmm_init+0xb50>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0202c44:	00093a83          	ld	s5,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202c48:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202c4a:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fd54904>
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
ffffffffc0202d00:	01c50513          	addi	a0,a0,28 # ffffffffc0206d18 <default_pmm_manager+0x720>
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
ffffffffc0202e64:	00003617          	auipc	a2,0x3
ffffffffc0202e68:	7cc60613          	addi	a2,a2,1996 # ffffffffc0206630 <default_pmm_manager+0x38>
ffffffffc0202e6c:	24f00593          	li	a1,591
ffffffffc0202e70:	00004517          	auipc	a0,0x4
ffffffffc0202e74:	8d850513          	addi	a0,a0,-1832 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0202e78:	e16fd0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202e7c:	00004697          	auipc	a3,0x4
ffffffffc0202e80:	d3c68693          	addi	a3,a3,-708 # ffffffffc0206bb8 <default_pmm_manager+0x5c0>
ffffffffc0202e84:	00003617          	auipc	a2,0x3
ffffffffc0202e88:	3c460613          	addi	a2,a2,964 # ffffffffc0206248 <commands+0x828>
ffffffffc0202e8c:	25000593          	li	a1,592
ffffffffc0202e90:	00004517          	auipc	a0,0x4
ffffffffc0202e94:	8b850513          	addi	a0,a0,-1864 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0202e98:	df6fd0ef          	jal	ra,ffffffffc020048e <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202e9c:	00004697          	auipc	a3,0x4
ffffffffc0202ea0:	cdc68693          	addi	a3,a3,-804 # ffffffffc0206b78 <default_pmm_manager+0x580>
ffffffffc0202ea4:	00003617          	auipc	a2,0x3
ffffffffc0202ea8:	3a460613          	addi	a2,a2,932 # ffffffffc0206248 <commands+0x828>
ffffffffc0202eac:	24f00593          	li	a1,591
ffffffffc0202eb0:	00004517          	auipc	a0,0x4
ffffffffc0202eb4:	89850513          	addi	a0,a0,-1896 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0202eb8:	dd6fd0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc0202ebc:	fc5fe0ef          	jal	ra,ffffffffc0201e80 <pa2page.part.0>
ffffffffc0202ec0:	fddfe0ef          	jal	ra,ffffffffc0201e9c <pte2page.part.0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202ec4:	00004697          	auipc	a3,0x4
ffffffffc0202ec8:	aac68693          	addi	a3,a3,-1364 # ffffffffc0206970 <default_pmm_manager+0x378>
ffffffffc0202ecc:	00003617          	auipc	a2,0x3
ffffffffc0202ed0:	37c60613          	addi	a2,a2,892 # ffffffffc0206248 <commands+0x828>
ffffffffc0202ed4:	21f00593          	li	a1,543
ffffffffc0202ed8:	00004517          	auipc	a0,0x4
ffffffffc0202edc:	87050513          	addi	a0,a0,-1936 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0202ee0:	daefd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0202ee4:	00004697          	auipc	a3,0x4
ffffffffc0202ee8:	9cc68693          	addi	a3,a3,-1588 # ffffffffc02068b0 <default_pmm_manager+0x2b8>
ffffffffc0202eec:	00003617          	auipc	a2,0x3
ffffffffc0202ef0:	35c60613          	addi	a2,a2,860 # ffffffffc0206248 <commands+0x828>
ffffffffc0202ef4:	21200593          	li	a1,530
ffffffffc0202ef8:	00004517          	auipc	a0,0x4
ffffffffc0202efc:	85050513          	addi	a0,a0,-1968 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0202f00:	d8efd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202f04:	00004697          	auipc	a3,0x4
ffffffffc0202f08:	96c68693          	addi	a3,a3,-1684 # ffffffffc0206870 <default_pmm_manager+0x278>
ffffffffc0202f0c:	00003617          	auipc	a2,0x3
ffffffffc0202f10:	33c60613          	addi	a2,a2,828 # ffffffffc0206248 <commands+0x828>
ffffffffc0202f14:	21100593          	li	a1,529
ffffffffc0202f18:	00004517          	auipc	a0,0x4
ffffffffc0202f1c:	83050513          	addi	a0,a0,-2000 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0202f20:	d6efd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202f24:	00004697          	auipc	a3,0x4
ffffffffc0202f28:	92c68693          	addi	a3,a3,-1748 # ffffffffc0206850 <default_pmm_manager+0x258>
ffffffffc0202f2c:	00003617          	auipc	a2,0x3
ffffffffc0202f30:	31c60613          	addi	a2,a2,796 # ffffffffc0206248 <commands+0x828>
ffffffffc0202f34:	21000593          	li	a1,528
ffffffffc0202f38:	00004517          	auipc	a0,0x4
ffffffffc0202f3c:	81050513          	addi	a0,a0,-2032 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0202f40:	d4efd0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc0202f44:	00003617          	auipc	a2,0x3
ffffffffc0202f48:	6ec60613          	addi	a2,a2,1772 # ffffffffc0206630 <default_pmm_manager+0x38>
ffffffffc0202f4c:	07100593          	li	a1,113
ffffffffc0202f50:	00003517          	auipc	a0,0x3
ffffffffc0202f54:	70850513          	addi	a0,a0,1800 # ffffffffc0206658 <default_pmm_manager+0x60>
ffffffffc0202f58:	d36fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202f5c:	00004697          	auipc	a3,0x4
ffffffffc0202f60:	ba468693          	addi	a3,a3,-1116 # ffffffffc0206b00 <default_pmm_manager+0x508>
ffffffffc0202f64:	00003617          	auipc	a2,0x3
ffffffffc0202f68:	2e460613          	addi	a2,a2,740 # ffffffffc0206248 <commands+0x828>
ffffffffc0202f6c:	23800593          	li	a1,568
ffffffffc0202f70:	00003517          	auipc	a0,0x3
ffffffffc0202f74:	7d850513          	addi	a0,a0,2008 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0202f78:	d16fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f7c:	00004697          	auipc	a3,0x4
ffffffffc0202f80:	b3c68693          	addi	a3,a3,-1220 # ffffffffc0206ab8 <default_pmm_manager+0x4c0>
ffffffffc0202f84:	00003617          	auipc	a2,0x3
ffffffffc0202f88:	2c460613          	addi	a2,a2,708 # ffffffffc0206248 <commands+0x828>
ffffffffc0202f8c:	23600593          	li	a1,566
ffffffffc0202f90:	00003517          	auipc	a0,0x3
ffffffffc0202f94:	7b850513          	addi	a0,a0,1976 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0202f98:	cf6fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202f9c:	00004697          	auipc	a3,0x4
ffffffffc0202fa0:	b4c68693          	addi	a3,a3,-1204 # ffffffffc0206ae8 <default_pmm_manager+0x4f0>
ffffffffc0202fa4:	00003617          	auipc	a2,0x3
ffffffffc0202fa8:	2a460613          	addi	a2,a2,676 # ffffffffc0206248 <commands+0x828>
ffffffffc0202fac:	23500593          	li	a1,565
ffffffffc0202fb0:	00003517          	auipc	a0,0x3
ffffffffc0202fb4:	79850513          	addi	a0,a0,1944 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0202fb8:	cd6fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc0202fbc:	00004697          	auipc	a3,0x4
ffffffffc0202fc0:	c1468693          	addi	a3,a3,-1004 # ffffffffc0206bd0 <default_pmm_manager+0x5d8>
ffffffffc0202fc4:	00003617          	auipc	a2,0x3
ffffffffc0202fc8:	28460613          	addi	a2,a2,644 # ffffffffc0206248 <commands+0x828>
ffffffffc0202fcc:	25300593          	li	a1,595
ffffffffc0202fd0:	00003517          	auipc	a0,0x3
ffffffffc0202fd4:	77850513          	addi	a0,a0,1912 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0202fd8:	cb6fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0202fdc:	00004697          	auipc	a3,0x4
ffffffffc0202fe0:	b5468693          	addi	a3,a3,-1196 # ffffffffc0206b30 <default_pmm_manager+0x538>
ffffffffc0202fe4:	00003617          	auipc	a2,0x3
ffffffffc0202fe8:	26460613          	addi	a2,a2,612 # ffffffffc0206248 <commands+0x828>
ffffffffc0202fec:	24000593          	li	a1,576
ffffffffc0202ff0:	00003517          	auipc	a0,0x3
ffffffffc0202ff4:	75850513          	addi	a0,a0,1880 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0202ff8:	c96fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202ffc:	00004697          	auipc	a3,0x4
ffffffffc0203000:	c2c68693          	addi	a3,a3,-980 # ffffffffc0206c28 <default_pmm_manager+0x630>
ffffffffc0203004:	00003617          	auipc	a2,0x3
ffffffffc0203008:	24460613          	addi	a2,a2,580 # ffffffffc0206248 <commands+0x828>
ffffffffc020300c:	25800593          	li	a1,600
ffffffffc0203010:	00003517          	auipc	a0,0x3
ffffffffc0203014:	73850513          	addi	a0,a0,1848 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0203018:	c76fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020301c:	00004697          	auipc	a3,0x4
ffffffffc0203020:	bcc68693          	addi	a3,a3,-1076 # ffffffffc0206be8 <default_pmm_manager+0x5f0>
ffffffffc0203024:	00003617          	auipc	a2,0x3
ffffffffc0203028:	22460613          	addi	a2,a2,548 # ffffffffc0206248 <commands+0x828>
ffffffffc020302c:	25700593          	li	a1,599
ffffffffc0203030:	00003517          	auipc	a0,0x3
ffffffffc0203034:	71850513          	addi	a0,a0,1816 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0203038:	c56fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020303c:	00004697          	auipc	a3,0x4
ffffffffc0203040:	a7c68693          	addi	a3,a3,-1412 # ffffffffc0206ab8 <default_pmm_manager+0x4c0>
ffffffffc0203044:	00003617          	auipc	a2,0x3
ffffffffc0203048:	20460613          	addi	a2,a2,516 # ffffffffc0206248 <commands+0x828>
ffffffffc020304c:	23200593          	li	a1,562
ffffffffc0203050:	00003517          	auipc	a0,0x3
ffffffffc0203054:	6f850513          	addi	a0,a0,1784 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0203058:	c36fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020305c:	00004697          	auipc	a3,0x4
ffffffffc0203060:	8fc68693          	addi	a3,a3,-1796 # ffffffffc0206958 <default_pmm_manager+0x360>
ffffffffc0203064:	00003617          	auipc	a2,0x3
ffffffffc0203068:	1e460613          	addi	a2,a2,484 # ffffffffc0206248 <commands+0x828>
ffffffffc020306c:	23100593          	li	a1,561
ffffffffc0203070:	00003517          	auipc	a0,0x3
ffffffffc0203074:	6d850513          	addi	a0,a0,1752 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0203078:	c16fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020307c:	00004697          	auipc	a3,0x4
ffffffffc0203080:	a5468693          	addi	a3,a3,-1452 # ffffffffc0206ad0 <default_pmm_manager+0x4d8>
ffffffffc0203084:	00003617          	auipc	a2,0x3
ffffffffc0203088:	1c460613          	addi	a2,a2,452 # ffffffffc0206248 <commands+0x828>
ffffffffc020308c:	22e00593          	li	a1,558
ffffffffc0203090:	00003517          	auipc	a0,0x3
ffffffffc0203094:	6b850513          	addi	a0,a0,1720 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0203098:	bf6fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020309c:	00004697          	auipc	a3,0x4
ffffffffc02030a0:	8a468693          	addi	a3,a3,-1884 # ffffffffc0206940 <default_pmm_manager+0x348>
ffffffffc02030a4:	00003617          	auipc	a2,0x3
ffffffffc02030a8:	1a460613          	addi	a2,a2,420 # ffffffffc0206248 <commands+0x828>
ffffffffc02030ac:	22d00593          	li	a1,557
ffffffffc02030b0:	00003517          	auipc	a0,0x3
ffffffffc02030b4:	69850513          	addi	a0,a0,1688 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc02030b8:	bd6fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02030bc:	00004697          	auipc	a3,0x4
ffffffffc02030c0:	92468693          	addi	a3,a3,-1756 # ffffffffc02069e0 <default_pmm_manager+0x3e8>
ffffffffc02030c4:	00003617          	auipc	a2,0x3
ffffffffc02030c8:	18460613          	addi	a2,a2,388 # ffffffffc0206248 <commands+0x828>
ffffffffc02030cc:	22c00593          	li	a1,556
ffffffffc02030d0:	00003517          	auipc	a0,0x3
ffffffffc02030d4:	67850513          	addi	a0,a0,1656 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc02030d8:	bb6fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02030dc:	00004697          	auipc	a3,0x4
ffffffffc02030e0:	9dc68693          	addi	a3,a3,-1572 # ffffffffc0206ab8 <default_pmm_manager+0x4c0>
ffffffffc02030e4:	00003617          	auipc	a2,0x3
ffffffffc02030e8:	16460613          	addi	a2,a2,356 # ffffffffc0206248 <commands+0x828>
ffffffffc02030ec:	22b00593          	li	a1,555
ffffffffc02030f0:	00003517          	auipc	a0,0x3
ffffffffc02030f4:	65850513          	addi	a0,a0,1624 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc02030f8:	b96fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02030fc:	00004697          	auipc	a3,0x4
ffffffffc0203100:	9a468693          	addi	a3,a3,-1628 # ffffffffc0206aa0 <default_pmm_manager+0x4a8>
ffffffffc0203104:	00003617          	auipc	a2,0x3
ffffffffc0203108:	14460613          	addi	a2,a2,324 # ffffffffc0206248 <commands+0x828>
ffffffffc020310c:	22a00593          	li	a1,554
ffffffffc0203110:	00003517          	auipc	a0,0x3
ffffffffc0203114:	63850513          	addi	a0,a0,1592 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0203118:	b76fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc020311c:	00004697          	auipc	a3,0x4
ffffffffc0203120:	95468693          	addi	a3,a3,-1708 # ffffffffc0206a70 <default_pmm_manager+0x478>
ffffffffc0203124:	00003617          	auipc	a2,0x3
ffffffffc0203128:	12460613          	addi	a2,a2,292 # ffffffffc0206248 <commands+0x828>
ffffffffc020312c:	22900593          	li	a1,553
ffffffffc0203130:	00003517          	auipc	a0,0x3
ffffffffc0203134:	61850513          	addi	a0,a0,1560 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0203138:	b56fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 1);
ffffffffc020313c:	00004697          	auipc	a3,0x4
ffffffffc0203140:	91c68693          	addi	a3,a3,-1764 # ffffffffc0206a58 <default_pmm_manager+0x460>
ffffffffc0203144:	00003617          	auipc	a2,0x3
ffffffffc0203148:	10460613          	addi	a2,a2,260 # ffffffffc0206248 <commands+0x828>
ffffffffc020314c:	22700593          	li	a1,551
ffffffffc0203150:	00003517          	auipc	a0,0x3
ffffffffc0203154:	5f850513          	addi	a0,a0,1528 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0203158:	b36fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc020315c:	00004697          	auipc	a3,0x4
ffffffffc0203160:	8dc68693          	addi	a3,a3,-1828 # ffffffffc0206a38 <default_pmm_manager+0x440>
ffffffffc0203164:	00003617          	auipc	a2,0x3
ffffffffc0203168:	0e460613          	addi	a2,a2,228 # ffffffffc0206248 <commands+0x828>
ffffffffc020316c:	22600593          	li	a1,550
ffffffffc0203170:	00003517          	auipc	a0,0x3
ffffffffc0203174:	5d850513          	addi	a0,a0,1496 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0203178:	b16fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(*ptep & PTE_W);
ffffffffc020317c:	00004697          	auipc	a3,0x4
ffffffffc0203180:	8ac68693          	addi	a3,a3,-1876 # ffffffffc0206a28 <default_pmm_manager+0x430>
ffffffffc0203184:	00003617          	auipc	a2,0x3
ffffffffc0203188:	0c460613          	addi	a2,a2,196 # ffffffffc0206248 <commands+0x828>
ffffffffc020318c:	22500593          	li	a1,549
ffffffffc0203190:	00003517          	auipc	a0,0x3
ffffffffc0203194:	5b850513          	addi	a0,a0,1464 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0203198:	af6fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(*ptep & PTE_U);
ffffffffc020319c:	00004697          	auipc	a3,0x4
ffffffffc02031a0:	87c68693          	addi	a3,a3,-1924 # ffffffffc0206a18 <default_pmm_manager+0x420>
ffffffffc02031a4:	00003617          	auipc	a2,0x3
ffffffffc02031a8:	0a460613          	addi	a2,a2,164 # ffffffffc0206248 <commands+0x828>
ffffffffc02031ac:	22400593          	li	a1,548
ffffffffc02031b0:	00003517          	auipc	a0,0x3
ffffffffc02031b4:	59850513          	addi	a0,a0,1432 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc02031b8:	ad6fd0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("DTB memory info not available");
ffffffffc02031bc:	00003617          	auipc	a2,0x3
ffffffffc02031c0:	5fc60613          	addi	a2,a2,1532 # ffffffffc02067b8 <default_pmm_manager+0x1c0>
ffffffffc02031c4:	06500593          	li	a1,101
ffffffffc02031c8:	00003517          	auipc	a0,0x3
ffffffffc02031cc:	58050513          	addi	a0,a0,1408 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc02031d0:	abefd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc02031d4:	00004697          	auipc	a3,0x4
ffffffffc02031d8:	95c68693          	addi	a3,a3,-1700 # ffffffffc0206b30 <default_pmm_manager+0x538>
ffffffffc02031dc:	00003617          	auipc	a2,0x3
ffffffffc02031e0:	06c60613          	addi	a2,a2,108 # ffffffffc0206248 <commands+0x828>
ffffffffc02031e4:	26a00593          	li	a1,618
ffffffffc02031e8:	00003517          	auipc	a0,0x3
ffffffffc02031ec:	56050513          	addi	a0,a0,1376 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc02031f0:	a9efd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02031f4:	00003697          	auipc	a3,0x3
ffffffffc02031f8:	7ec68693          	addi	a3,a3,2028 # ffffffffc02069e0 <default_pmm_manager+0x3e8>
ffffffffc02031fc:	00003617          	auipc	a2,0x3
ffffffffc0203200:	04c60613          	addi	a2,a2,76 # ffffffffc0206248 <commands+0x828>
ffffffffc0203204:	22300593          	li	a1,547
ffffffffc0203208:	00003517          	auipc	a0,0x3
ffffffffc020320c:	54050513          	addi	a0,a0,1344 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0203210:	a7efd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203214:	00003697          	auipc	a3,0x3
ffffffffc0203218:	78c68693          	addi	a3,a3,1932 # ffffffffc02069a0 <default_pmm_manager+0x3a8>
ffffffffc020321c:	00003617          	auipc	a2,0x3
ffffffffc0203220:	02c60613          	addi	a2,a2,44 # ffffffffc0206248 <commands+0x828>
ffffffffc0203224:	22200593          	li	a1,546
ffffffffc0203228:	00003517          	auipc	a0,0x3
ffffffffc020322c:	52050513          	addi	a0,a0,1312 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0203230:	a5efd0ef          	jal	ra,ffffffffc020048e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203234:	86d6                	mv	a3,s5
ffffffffc0203236:	00003617          	auipc	a2,0x3
ffffffffc020323a:	3fa60613          	addi	a2,a2,1018 # ffffffffc0206630 <default_pmm_manager+0x38>
ffffffffc020323e:	21e00593          	li	a1,542
ffffffffc0203242:	00003517          	auipc	a0,0x3
ffffffffc0203246:	50650513          	addi	a0,a0,1286 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc020324a:	a44fd0ef          	jal	ra,ffffffffc020048e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc020324e:	00003617          	auipc	a2,0x3
ffffffffc0203252:	3e260613          	addi	a2,a2,994 # ffffffffc0206630 <default_pmm_manager+0x38>
ffffffffc0203256:	21d00593          	li	a1,541
ffffffffc020325a:	00003517          	auipc	a0,0x3
ffffffffc020325e:	4ee50513          	addi	a0,a0,1262 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0203262:	a2cfd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203266:	00003697          	auipc	a3,0x3
ffffffffc020326a:	6f268693          	addi	a3,a3,1778 # ffffffffc0206958 <default_pmm_manager+0x360>
ffffffffc020326e:	00003617          	auipc	a2,0x3
ffffffffc0203272:	fda60613          	addi	a2,a2,-38 # ffffffffc0206248 <commands+0x828>
ffffffffc0203276:	21b00593          	li	a1,539
ffffffffc020327a:	00003517          	auipc	a0,0x3
ffffffffc020327e:	4ce50513          	addi	a0,a0,1230 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0203282:	a0cfd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203286:	00003697          	auipc	a3,0x3
ffffffffc020328a:	6ba68693          	addi	a3,a3,1722 # ffffffffc0206940 <default_pmm_manager+0x348>
ffffffffc020328e:	00003617          	auipc	a2,0x3
ffffffffc0203292:	fba60613          	addi	a2,a2,-70 # ffffffffc0206248 <commands+0x828>
ffffffffc0203296:	21a00593          	li	a1,538
ffffffffc020329a:	00003517          	auipc	a0,0x3
ffffffffc020329e:	4ae50513          	addi	a0,a0,1198 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc02032a2:	9ecfd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02032a6:	00004697          	auipc	a3,0x4
ffffffffc02032aa:	a4a68693          	addi	a3,a3,-1462 # ffffffffc0206cf0 <default_pmm_manager+0x6f8>
ffffffffc02032ae:	00003617          	auipc	a2,0x3
ffffffffc02032b2:	f9a60613          	addi	a2,a2,-102 # ffffffffc0206248 <commands+0x828>
ffffffffc02032b6:	26100593          	li	a1,609
ffffffffc02032ba:	00003517          	auipc	a0,0x3
ffffffffc02032be:	48e50513          	addi	a0,a0,1166 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc02032c2:	9ccfd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02032c6:	00004697          	auipc	a3,0x4
ffffffffc02032ca:	9f268693          	addi	a3,a3,-1550 # ffffffffc0206cb8 <default_pmm_manager+0x6c0>
ffffffffc02032ce:	00003617          	auipc	a2,0x3
ffffffffc02032d2:	f7a60613          	addi	a2,a2,-134 # ffffffffc0206248 <commands+0x828>
ffffffffc02032d6:	25e00593          	li	a1,606
ffffffffc02032da:	00003517          	auipc	a0,0x3
ffffffffc02032de:	46e50513          	addi	a0,a0,1134 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc02032e2:	9acfd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p) == 2);
ffffffffc02032e6:	00004697          	auipc	a3,0x4
ffffffffc02032ea:	9a268693          	addi	a3,a3,-1630 # ffffffffc0206c88 <default_pmm_manager+0x690>
ffffffffc02032ee:	00003617          	auipc	a2,0x3
ffffffffc02032f2:	f5a60613          	addi	a2,a2,-166 # ffffffffc0206248 <commands+0x828>
ffffffffc02032f6:	25a00593          	li	a1,602
ffffffffc02032fa:	00003517          	auipc	a0,0x3
ffffffffc02032fe:	44e50513          	addi	a0,a0,1102 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0203302:	98cfd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203306:	00004697          	auipc	a3,0x4
ffffffffc020330a:	93a68693          	addi	a3,a3,-1734 # ffffffffc0206c40 <default_pmm_manager+0x648>
ffffffffc020330e:	00003617          	auipc	a2,0x3
ffffffffc0203312:	f3a60613          	addi	a2,a2,-198 # ffffffffc0206248 <commands+0x828>
ffffffffc0203316:	25900593          	li	a1,601
ffffffffc020331a:	00003517          	auipc	a0,0x3
ffffffffc020331e:	42e50513          	addi	a0,a0,1070 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0203322:	96cfd0ef          	jal	ra,ffffffffc020048e <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0203326:	00003617          	auipc	a2,0x3
ffffffffc020332a:	3b260613          	addi	a2,a2,946 # ffffffffc02066d8 <default_pmm_manager+0xe0>
ffffffffc020332e:	0c900593          	li	a1,201
ffffffffc0203332:	00003517          	auipc	a0,0x3
ffffffffc0203336:	41650513          	addi	a0,a0,1046 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc020333a:	954fd0ef          	jal	ra,ffffffffc020048e <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020333e:	00003617          	auipc	a2,0x3
ffffffffc0203342:	39a60613          	addi	a2,a2,922 # ffffffffc02066d8 <default_pmm_manager+0xe0>
ffffffffc0203346:	08100593          	li	a1,129
ffffffffc020334a:	00003517          	auipc	a0,0x3
ffffffffc020334e:	3fe50513          	addi	a0,a0,1022 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0203352:	93cfd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0203356:	00003697          	auipc	a3,0x3
ffffffffc020335a:	5ba68693          	addi	a3,a3,1466 # ffffffffc0206910 <default_pmm_manager+0x318>
ffffffffc020335e:	00003617          	auipc	a2,0x3
ffffffffc0203362:	eea60613          	addi	a2,a2,-278 # ffffffffc0206248 <commands+0x828>
ffffffffc0203366:	21900593          	li	a1,537
ffffffffc020336a:	00003517          	auipc	a0,0x3
ffffffffc020336e:	3de50513          	addi	a0,a0,990 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0203372:	91cfd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0203376:	00003697          	auipc	a3,0x3
ffffffffc020337a:	56a68693          	addi	a3,a3,1386 # ffffffffc02068e0 <default_pmm_manager+0x2e8>
ffffffffc020337e:	00003617          	auipc	a2,0x3
ffffffffc0203382:	eca60613          	addi	a2,a2,-310 # ffffffffc0206248 <commands+0x828>
ffffffffc0203386:	21600593          	li	a1,534
ffffffffc020338a:	00003517          	auipc	a0,0x3
ffffffffc020338e:	3be50513          	addi	a0,a0,958 # ffffffffc0206748 <default_pmm_manager+0x150>
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
ffffffffc02033b8:	20079f63          	bnez	a5,ffffffffc02035d6 <copy_range+0x240>
    assert(USER_ACCESS(start, end));
ffffffffc02033bc:	002007b7          	lui	a5,0x200
ffffffffc02033c0:	8432                	mv	s0,a2
ffffffffc02033c2:	1af66263          	bltu	a2,a5,ffffffffc0203566 <copy_range+0x1d0>
ffffffffc02033c6:	8936                	mv	s2,a3
ffffffffc02033c8:	18d67f63          	bgeu	a2,a3,ffffffffc0203566 <copy_range+0x1d0>
ffffffffc02033cc:	4785                	li	a5,1
ffffffffc02033ce:	07fe                	slli	a5,a5,0x1f
ffffffffc02033d0:	18d7eb63          	bltu	a5,a3,ffffffffc0203566 <copy_range+0x1d0>
ffffffffc02033d4:	5b7d                	li	s6,-1
ffffffffc02033d6:	8aaa                	mv	s5,a0
ffffffffc02033d8:	89ae                	mv	s3,a1
        start += PGSIZE;
ffffffffc02033da:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage)
ffffffffc02033dc:	000a7c17          	auipc	s8,0xa7
ffffffffc02033e0:	2e4c0c13          	addi	s8,s8,740 # ffffffffc02aa6c0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02033e4:	000a7b97          	auipc	s7,0xa7
ffffffffc02033e8:	2e4b8b93          	addi	s7,s7,740 # ffffffffc02aa6c8 <pages>
    return KADDR(page2pa(page));
ffffffffc02033ec:	00cb5b13          	srli	s6,s6,0xc
        page = pmm_manager->alloc_pages(n);
ffffffffc02033f0:	000a7c97          	auipc	s9,0xa7
ffffffffc02033f4:	2e0c8c93          	addi	s9,s9,736 # ffffffffc02aa6d0 <pmm_manager>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02033f8:	4601                	li	a2,0
ffffffffc02033fa:	85a2                	mv	a1,s0
ffffffffc02033fc:	854e                	mv	a0,s3
ffffffffc02033fe:	b73fe0ef          	jal	ra,ffffffffc0201f70 <get_pte>
ffffffffc0203402:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc0203404:	0e050c63          	beqz	a0,ffffffffc02034fc <copy_range+0x166>
        if (*ptep & PTE_V)
ffffffffc0203408:	611c                	ld	a5,0(a0)
ffffffffc020340a:	8b85                	andi	a5,a5,1
ffffffffc020340c:	e785                	bnez	a5,ffffffffc0203434 <copy_range+0x9e>
        start += PGSIZE;
ffffffffc020340e:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0203410:	ff2464e3          	bltu	s0,s2,ffffffffc02033f8 <copy_range+0x62>
    return 0;
ffffffffc0203414:	4501                	li	a0,0
}
ffffffffc0203416:	70a6                	ld	ra,104(sp)
ffffffffc0203418:	7406                	ld	s0,96(sp)
ffffffffc020341a:	64e6                	ld	s1,88(sp)
ffffffffc020341c:	6946                	ld	s2,80(sp)
ffffffffc020341e:	69a6                	ld	s3,72(sp)
ffffffffc0203420:	6a06                	ld	s4,64(sp)
ffffffffc0203422:	7ae2                	ld	s5,56(sp)
ffffffffc0203424:	7b42                	ld	s6,48(sp)
ffffffffc0203426:	7ba2                	ld	s7,40(sp)
ffffffffc0203428:	7c02                	ld	s8,32(sp)
ffffffffc020342a:	6ce2                	ld	s9,24(sp)
ffffffffc020342c:	6d42                	ld	s10,16(sp)
ffffffffc020342e:	6da2                	ld	s11,8(sp)
ffffffffc0203430:	6165                	addi	sp,sp,112
ffffffffc0203432:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc0203434:	4605                	li	a2,1
ffffffffc0203436:	85a2                	mv	a1,s0
ffffffffc0203438:	8556                	mv	a0,s5
ffffffffc020343a:	b37fe0ef          	jal	ra,ffffffffc0201f70 <get_pte>
ffffffffc020343e:	c56d                	beqz	a0,ffffffffc0203528 <copy_range+0x192>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0203440:	609c                	ld	a5,0(s1)
    if (!(pte & PTE_V))
ffffffffc0203442:	0017f713          	andi	a4,a5,1
ffffffffc0203446:	01f7f493          	andi	s1,a5,31
ffffffffc020344a:	16070a63          	beqz	a4,ffffffffc02035be <copy_range+0x228>
    if (PPN(pa) >= npage)
ffffffffc020344e:	000c3683          	ld	a3,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203452:	078a                	slli	a5,a5,0x2
ffffffffc0203454:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0203458:	14d77763          	bgeu	a4,a3,ffffffffc02035a6 <copy_range+0x210>
    return &pages[PPN(pa) - nbase];
ffffffffc020345c:	000bb783          	ld	a5,0(s7)
ffffffffc0203460:	fff806b7          	lui	a3,0xfff80
ffffffffc0203464:	9736                	add	a4,a4,a3
ffffffffc0203466:	071a                	slli	a4,a4,0x6
ffffffffc0203468:	00e78db3          	add	s11,a5,a4
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020346c:	10002773          	csrr	a4,sstatus
ffffffffc0203470:	8b09                	andi	a4,a4,2
ffffffffc0203472:	e345                	bnez	a4,ffffffffc0203512 <copy_range+0x17c>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203474:	000cb703          	ld	a4,0(s9)
ffffffffc0203478:	4505                	li	a0,1
ffffffffc020347a:	6f18                	ld	a4,24(a4)
ffffffffc020347c:	9702                	jalr	a4
ffffffffc020347e:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc0203480:	0c0d8363          	beqz	s11,ffffffffc0203546 <copy_range+0x1b0>
            assert(npage != NULL);
ffffffffc0203484:	100d0163          	beqz	s10,ffffffffc0203586 <copy_range+0x1f0>
    return page - pages + nbase;
ffffffffc0203488:	000bb703          	ld	a4,0(s7)
ffffffffc020348c:	000805b7          	lui	a1,0x80
    return KADDR(page2pa(page));
ffffffffc0203490:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0203494:	40ed86b3          	sub	a3,s11,a4
ffffffffc0203498:	8699                	srai	a3,a3,0x6
ffffffffc020349a:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc020349c:	0166f7b3          	and	a5,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02034a0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02034a2:	08c7f663          	bgeu	a5,a2,ffffffffc020352e <copy_range+0x198>
    return page - pages + nbase;
ffffffffc02034a6:	40ed07b3          	sub	a5,s10,a4
    return KADDR(page2pa(page));
ffffffffc02034aa:	000a7717          	auipc	a4,0xa7
ffffffffc02034ae:	22e70713          	addi	a4,a4,558 # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc02034b2:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc02034b4:	8799                	srai	a5,a5,0x6
ffffffffc02034b6:	97ae                	add	a5,a5,a1
    return KADDR(page2pa(page));
ffffffffc02034b8:	0167f733          	and	a4,a5,s6
ffffffffc02034bc:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02034c0:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02034c2:	06c77563          	bgeu	a4,a2,ffffffffc020352c <copy_range+0x196>
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ffffffffc02034c6:	6605                	lui	a2,0x1
ffffffffc02034c8:	953e                	add	a0,a0,a5
ffffffffc02034ca:	2d6020ef          	jal	ra,ffffffffc02057a0 <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc02034ce:	86a6                	mv	a3,s1
ffffffffc02034d0:	8622                	mv	a2,s0
ffffffffc02034d2:	85ea                	mv	a1,s10
ffffffffc02034d4:	8556                	mv	a0,s5
ffffffffc02034d6:	98aff0ef          	jal	ra,ffffffffc0202660 <page_insert>
            assert(ret == 0);
ffffffffc02034da:	d915                	beqz	a0,ffffffffc020340e <copy_range+0x78>
ffffffffc02034dc:	00004697          	auipc	a3,0x4
ffffffffc02034e0:	87c68693          	addi	a3,a3,-1924 # ffffffffc0206d58 <default_pmm_manager+0x760>
ffffffffc02034e4:	00003617          	auipc	a2,0x3
ffffffffc02034e8:	d6460613          	addi	a2,a2,-668 # ffffffffc0206248 <commands+0x828>
ffffffffc02034ec:	1ae00593          	li	a1,430
ffffffffc02034f0:	00003517          	auipc	a0,0x3
ffffffffc02034f4:	25850513          	addi	a0,a0,600 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc02034f8:	f97fc0ef          	jal	ra,ffffffffc020048e <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02034fc:	00200637          	lui	a2,0x200
ffffffffc0203500:	9432                	add	s0,s0,a2
ffffffffc0203502:	ffe00637          	lui	a2,0xffe00
ffffffffc0203506:	8c71                	and	s0,s0,a2
    } while (start != 0 && start < end);
ffffffffc0203508:	f00406e3          	beqz	s0,ffffffffc0203414 <copy_range+0x7e>
ffffffffc020350c:	ef2466e3          	bltu	s0,s2,ffffffffc02033f8 <copy_range+0x62>
ffffffffc0203510:	b711                	j	ffffffffc0203414 <copy_range+0x7e>
        intr_disable();
ffffffffc0203512:	ca2fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203516:	000cb703          	ld	a4,0(s9)
ffffffffc020351a:	4505                	li	a0,1
ffffffffc020351c:	6f18                	ld	a4,24(a4)
ffffffffc020351e:	9702                	jalr	a4
ffffffffc0203520:	8d2a                	mv	s10,a0
        intr_enable();
ffffffffc0203522:	c8cfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0203526:	bfa9                	j	ffffffffc0203480 <copy_range+0xea>
                return -E_NO_MEM;
ffffffffc0203528:	5571                	li	a0,-4
ffffffffc020352a:	b5f5                	j	ffffffffc0203416 <copy_range+0x80>
ffffffffc020352c:	86be                	mv	a3,a5
ffffffffc020352e:	00003617          	auipc	a2,0x3
ffffffffc0203532:	10260613          	addi	a2,a2,258 # ffffffffc0206630 <default_pmm_manager+0x38>
ffffffffc0203536:	07100593          	li	a1,113
ffffffffc020353a:	00003517          	auipc	a0,0x3
ffffffffc020353e:	11e50513          	addi	a0,a0,286 # ffffffffc0206658 <default_pmm_manager+0x60>
ffffffffc0203542:	f4dfc0ef          	jal	ra,ffffffffc020048e <__panic>
            assert(page != NULL);
ffffffffc0203546:	00003697          	auipc	a3,0x3
ffffffffc020354a:	7f268693          	addi	a3,a3,2034 # ffffffffc0206d38 <default_pmm_manager+0x740>
ffffffffc020354e:	00003617          	auipc	a2,0x3
ffffffffc0203552:	cfa60613          	addi	a2,a2,-774 # ffffffffc0206248 <commands+0x828>
ffffffffc0203556:	19400593          	li	a1,404
ffffffffc020355a:	00003517          	auipc	a0,0x3
ffffffffc020355e:	1ee50513          	addi	a0,a0,494 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0203562:	f2dfc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203566:	00003697          	auipc	a3,0x3
ffffffffc020356a:	22268693          	addi	a3,a3,546 # ffffffffc0206788 <default_pmm_manager+0x190>
ffffffffc020356e:	00003617          	auipc	a2,0x3
ffffffffc0203572:	cda60613          	addi	a2,a2,-806 # ffffffffc0206248 <commands+0x828>
ffffffffc0203576:	17c00593          	li	a1,380
ffffffffc020357a:	00003517          	auipc	a0,0x3
ffffffffc020357e:	1ce50513          	addi	a0,a0,462 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc0203582:	f0dfc0ef          	jal	ra,ffffffffc020048e <__panic>
            assert(npage != NULL);
ffffffffc0203586:	00003697          	auipc	a3,0x3
ffffffffc020358a:	7c268693          	addi	a3,a3,1986 # ffffffffc0206d48 <default_pmm_manager+0x750>
ffffffffc020358e:	00003617          	auipc	a2,0x3
ffffffffc0203592:	cba60613          	addi	a2,a2,-838 # ffffffffc0206248 <commands+0x828>
ffffffffc0203596:	19500593          	li	a1,405
ffffffffc020359a:	00003517          	auipc	a0,0x3
ffffffffc020359e:	1ae50513          	addi	a0,a0,430 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc02035a2:	eedfc0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02035a6:	00003617          	auipc	a2,0x3
ffffffffc02035aa:	15a60613          	addi	a2,a2,346 # ffffffffc0206700 <default_pmm_manager+0x108>
ffffffffc02035ae:	06900593          	li	a1,105
ffffffffc02035b2:	00003517          	auipc	a0,0x3
ffffffffc02035b6:	0a650513          	addi	a0,a0,166 # ffffffffc0206658 <default_pmm_manager+0x60>
ffffffffc02035ba:	ed5fc0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02035be:	00003617          	auipc	a2,0x3
ffffffffc02035c2:	16260613          	addi	a2,a2,354 # ffffffffc0206720 <default_pmm_manager+0x128>
ffffffffc02035c6:	07f00593          	li	a1,127
ffffffffc02035ca:	00003517          	auipc	a0,0x3
ffffffffc02035ce:	08e50513          	addi	a0,a0,142 # ffffffffc0206658 <default_pmm_manager+0x60>
ffffffffc02035d2:	ebdfc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02035d6:	00003697          	auipc	a3,0x3
ffffffffc02035da:	18268693          	addi	a3,a3,386 # ffffffffc0206758 <default_pmm_manager+0x160>
ffffffffc02035de:	00003617          	auipc	a2,0x3
ffffffffc02035e2:	c6a60613          	addi	a2,a2,-918 # ffffffffc0206248 <commands+0x828>
ffffffffc02035e6:	17b00593          	li	a1,379
ffffffffc02035ea:	00003517          	auipc	a0,0x3
ffffffffc02035ee:	15e50513          	addi	a0,a0,350 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc02035f2:	e9dfc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02035f6 <pgdir_alloc_page>:
{
ffffffffc02035f6:	7179                	addi	sp,sp,-48
ffffffffc02035f8:	ec26                	sd	s1,24(sp)
ffffffffc02035fa:	e84a                	sd	s2,16(sp)
ffffffffc02035fc:	e052                	sd	s4,0(sp)
ffffffffc02035fe:	f406                	sd	ra,40(sp)
ffffffffc0203600:	f022                	sd	s0,32(sp)
ffffffffc0203602:	e44e                	sd	s3,8(sp)
ffffffffc0203604:	8a2a                	mv	s4,a0
ffffffffc0203606:	84ae                	mv	s1,a1
ffffffffc0203608:	8932                	mv	s2,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020360a:	100027f3          	csrr	a5,sstatus
ffffffffc020360e:	8b89                	andi	a5,a5,2
        page = pmm_manager->alloc_pages(n);
ffffffffc0203610:	000a7997          	auipc	s3,0xa7
ffffffffc0203614:	0c098993          	addi	s3,s3,192 # ffffffffc02aa6d0 <pmm_manager>
ffffffffc0203618:	ef8d                	bnez	a5,ffffffffc0203652 <pgdir_alloc_page+0x5c>
ffffffffc020361a:	0009b783          	ld	a5,0(s3)
ffffffffc020361e:	4505                	li	a0,1
ffffffffc0203620:	6f9c                	ld	a5,24(a5)
ffffffffc0203622:	9782                	jalr	a5
ffffffffc0203624:	842a                	mv	s0,a0
    if (page != NULL)
ffffffffc0203626:	cc09                	beqz	s0,ffffffffc0203640 <pgdir_alloc_page+0x4a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc0203628:	86ca                	mv	a3,s2
ffffffffc020362a:	8626                	mv	a2,s1
ffffffffc020362c:	85a2                	mv	a1,s0
ffffffffc020362e:	8552                	mv	a0,s4
ffffffffc0203630:	830ff0ef          	jal	ra,ffffffffc0202660 <page_insert>
ffffffffc0203634:	e915                	bnez	a0,ffffffffc0203668 <pgdir_alloc_page+0x72>
        assert(page_ref(page) == 1);
ffffffffc0203636:	4018                	lw	a4,0(s0)
        page->pra_vaddr = la;
ffffffffc0203638:	fc04                	sd	s1,56(s0)
        assert(page_ref(page) == 1);
ffffffffc020363a:	4785                	li	a5,1
ffffffffc020363c:	04f71e63          	bne	a4,a5,ffffffffc0203698 <pgdir_alloc_page+0xa2>
}
ffffffffc0203640:	70a2                	ld	ra,40(sp)
ffffffffc0203642:	8522                	mv	a0,s0
ffffffffc0203644:	7402                	ld	s0,32(sp)
ffffffffc0203646:	64e2                	ld	s1,24(sp)
ffffffffc0203648:	6942                	ld	s2,16(sp)
ffffffffc020364a:	69a2                	ld	s3,8(sp)
ffffffffc020364c:	6a02                	ld	s4,0(sp)
ffffffffc020364e:	6145                	addi	sp,sp,48
ffffffffc0203650:	8082                	ret
        intr_disable();
ffffffffc0203652:	b62fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203656:	0009b783          	ld	a5,0(s3)
ffffffffc020365a:	4505                	li	a0,1
ffffffffc020365c:	6f9c                	ld	a5,24(a5)
ffffffffc020365e:	9782                	jalr	a5
ffffffffc0203660:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203662:	b4cfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0203666:	b7c1                	j	ffffffffc0203626 <pgdir_alloc_page+0x30>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203668:	100027f3          	csrr	a5,sstatus
ffffffffc020366c:	8b89                	andi	a5,a5,2
ffffffffc020366e:	eb89                	bnez	a5,ffffffffc0203680 <pgdir_alloc_page+0x8a>
        pmm_manager->free_pages(base, n);
ffffffffc0203670:	0009b783          	ld	a5,0(s3)
ffffffffc0203674:	8522                	mv	a0,s0
ffffffffc0203676:	4585                	li	a1,1
ffffffffc0203678:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc020367a:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc020367c:	9782                	jalr	a5
    if (flag)
ffffffffc020367e:	b7c9                	j	ffffffffc0203640 <pgdir_alloc_page+0x4a>
        intr_disable();
ffffffffc0203680:	b34fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0203684:	0009b783          	ld	a5,0(s3)
ffffffffc0203688:	8522                	mv	a0,s0
ffffffffc020368a:	4585                	li	a1,1
ffffffffc020368c:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc020368e:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc0203690:	9782                	jalr	a5
        intr_enable();
ffffffffc0203692:	b1cfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0203696:	b76d                	j	ffffffffc0203640 <pgdir_alloc_page+0x4a>
        assert(page_ref(page) == 1);
ffffffffc0203698:	00003697          	auipc	a3,0x3
ffffffffc020369c:	6d068693          	addi	a3,a3,1744 # ffffffffc0206d68 <default_pmm_manager+0x770>
ffffffffc02036a0:	00003617          	auipc	a2,0x3
ffffffffc02036a4:	ba860613          	addi	a2,a2,-1112 # ffffffffc0206248 <commands+0x828>
ffffffffc02036a8:	1f700593          	li	a1,503
ffffffffc02036ac:	00003517          	auipc	a0,0x3
ffffffffc02036b0:	09c50513          	addi	a0,a0,156 # ffffffffc0206748 <default_pmm_manager+0x150>
ffffffffc02036b4:	ddbfc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02036b8 <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02036b8:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02036ba:	00003697          	auipc	a3,0x3
ffffffffc02036be:	6c668693          	addi	a3,a3,1734 # ffffffffc0206d80 <default_pmm_manager+0x788>
ffffffffc02036c2:	00003617          	auipc	a2,0x3
ffffffffc02036c6:	b8660613          	addi	a2,a2,-1146 # ffffffffc0206248 <commands+0x828>
ffffffffc02036ca:	07400593          	li	a1,116
ffffffffc02036ce:	00003517          	auipc	a0,0x3
ffffffffc02036d2:	6d250513          	addi	a0,a0,1746 # ffffffffc0206da0 <default_pmm_manager+0x7a8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02036d6:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02036d8:	db7fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02036dc <mm_create>:
{
ffffffffc02036dc:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02036de:	04000513          	li	a0,64
{
ffffffffc02036e2:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02036e4:	df6fe0ef          	jal	ra,ffffffffc0201cda <kmalloc>
    if (mm != NULL)
ffffffffc02036e8:	cd19                	beqz	a0,ffffffffc0203706 <mm_create+0x2a>
    elm->prev = elm->next = elm;
ffffffffc02036ea:	e508                	sd	a0,8(a0)
ffffffffc02036ec:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02036ee:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02036f2:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02036f6:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc02036fa:	02053423          	sd	zero,40(a0)
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc02036fe:	02052823          	sw	zero,48(a0)
typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
ffffffffc0203702:	02053c23          	sd	zero,56(a0)
}
ffffffffc0203706:	60a2                	ld	ra,8(sp)
ffffffffc0203708:	0141                	addi	sp,sp,16
ffffffffc020370a:	8082                	ret

ffffffffc020370c <find_vma>:
{
ffffffffc020370c:	86aa                	mv	a3,a0
    if (mm != NULL)
ffffffffc020370e:	c505                	beqz	a0,ffffffffc0203736 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0203710:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0203712:	c501                	beqz	a0,ffffffffc020371a <find_vma+0xe>
ffffffffc0203714:	651c                	ld	a5,8(a0)
ffffffffc0203716:	02f5f263          	bgeu	a1,a5,ffffffffc020373a <find_vma+0x2e>
    return listelm->next;
ffffffffc020371a:	669c                	ld	a5,8(a3)
            while ((le = list_next(le)) != list)
ffffffffc020371c:	00f68d63          	beq	a3,a5,ffffffffc0203736 <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc0203720:	fe87b703          	ld	a4,-24(a5) # 1fffe8 <_binary_obj___user_exit_out_size+0x1f4ed0>
ffffffffc0203724:	00e5e663          	bltu	a1,a4,ffffffffc0203730 <find_vma+0x24>
ffffffffc0203728:	ff07b703          	ld	a4,-16(a5)
ffffffffc020372c:	00e5ec63          	bltu	a1,a4,ffffffffc0203744 <find_vma+0x38>
ffffffffc0203730:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc0203732:	fef697e3          	bne	a3,a5,ffffffffc0203720 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0203736:	4501                	li	a0,0
}
ffffffffc0203738:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc020373a:	691c                	ld	a5,16(a0)
ffffffffc020373c:	fcf5ffe3          	bgeu	a1,a5,ffffffffc020371a <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0203740:	ea88                	sd	a0,16(a3)
ffffffffc0203742:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc0203744:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0203748:	ea88                	sd	a0,16(a3)
ffffffffc020374a:	8082                	ret

ffffffffc020374c <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc020374c:	6590                	ld	a2,8(a1)
ffffffffc020374e:	0105b803          	ld	a6,16(a1) # 80010 <_binary_obj___user_exit_out_size+0x74ef8>
{
ffffffffc0203752:	1141                	addi	sp,sp,-16
ffffffffc0203754:	e406                	sd	ra,8(sp)
ffffffffc0203756:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203758:	01066763          	bltu	a2,a6,ffffffffc0203766 <insert_vma_struct+0x1a>
ffffffffc020375c:	a085                	j	ffffffffc02037bc <insert_vma_struct+0x70>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc020375e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203762:	04e66863          	bltu	a2,a4,ffffffffc02037b2 <insert_vma_struct+0x66>
ffffffffc0203766:	86be                	mv	a3,a5
ffffffffc0203768:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc020376a:	fef51ae3          	bne	a0,a5,ffffffffc020375e <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc020376e:	02a68463          	beq	a3,a0,ffffffffc0203796 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203772:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203776:	fe86b883          	ld	a7,-24(a3)
ffffffffc020377a:	08e8f163          	bgeu	a7,a4,ffffffffc02037fc <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020377e:	04e66f63          	bltu	a2,a4,ffffffffc02037dc <insert_vma_struct+0x90>
    }
    if (le_next != list)
ffffffffc0203782:	00f50a63          	beq	a0,a5,ffffffffc0203796 <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0203786:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc020378a:	05076963          	bltu	a4,a6,ffffffffc02037dc <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc020378e:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203792:	02c77363          	bgeu	a4,a2,ffffffffc02037b8 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc0203796:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0203798:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc020379a:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc020379e:	e390                	sd	a2,0(a5)
ffffffffc02037a0:	e690                	sd	a2,8(a3)
}
ffffffffc02037a2:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02037a4:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02037a6:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc02037a8:	0017079b          	addiw	a5,a4,1
ffffffffc02037ac:	d11c                	sw	a5,32(a0)
}
ffffffffc02037ae:	0141                	addi	sp,sp,16
ffffffffc02037b0:	8082                	ret
    if (le_prev != list)
ffffffffc02037b2:	fca690e3          	bne	a3,a0,ffffffffc0203772 <insert_vma_struct+0x26>
ffffffffc02037b6:	bfd1                	j	ffffffffc020378a <insert_vma_struct+0x3e>
ffffffffc02037b8:	f01ff0ef          	jal	ra,ffffffffc02036b8 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02037bc:	00003697          	auipc	a3,0x3
ffffffffc02037c0:	5f468693          	addi	a3,a3,1524 # ffffffffc0206db0 <default_pmm_manager+0x7b8>
ffffffffc02037c4:	00003617          	auipc	a2,0x3
ffffffffc02037c8:	a8460613          	addi	a2,a2,-1404 # ffffffffc0206248 <commands+0x828>
ffffffffc02037cc:	07a00593          	li	a1,122
ffffffffc02037d0:	00003517          	auipc	a0,0x3
ffffffffc02037d4:	5d050513          	addi	a0,a0,1488 # ffffffffc0206da0 <default_pmm_manager+0x7a8>
ffffffffc02037d8:	cb7fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02037dc:	00003697          	auipc	a3,0x3
ffffffffc02037e0:	61468693          	addi	a3,a3,1556 # ffffffffc0206df0 <default_pmm_manager+0x7f8>
ffffffffc02037e4:	00003617          	auipc	a2,0x3
ffffffffc02037e8:	a6460613          	addi	a2,a2,-1436 # ffffffffc0206248 <commands+0x828>
ffffffffc02037ec:	07300593          	li	a1,115
ffffffffc02037f0:	00003517          	auipc	a0,0x3
ffffffffc02037f4:	5b050513          	addi	a0,a0,1456 # ffffffffc0206da0 <default_pmm_manager+0x7a8>
ffffffffc02037f8:	c97fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02037fc:	00003697          	auipc	a3,0x3
ffffffffc0203800:	5d468693          	addi	a3,a3,1492 # ffffffffc0206dd0 <default_pmm_manager+0x7d8>
ffffffffc0203804:	00003617          	auipc	a2,0x3
ffffffffc0203808:	a4460613          	addi	a2,a2,-1468 # ffffffffc0206248 <commands+0x828>
ffffffffc020380c:	07200593          	li	a1,114
ffffffffc0203810:	00003517          	auipc	a0,0x3
ffffffffc0203814:	59050513          	addi	a0,a0,1424 # ffffffffc0206da0 <default_pmm_manager+0x7a8>
ffffffffc0203818:	c77fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020381c <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc020381c:	591c                	lw	a5,48(a0)
{
ffffffffc020381e:	1141                	addi	sp,sp,-16
ffffffffc0203820:	e406                	sd	ra,8(sp)
ffffffffc0203822:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0203824:	e78d                	bnez	a5,ffffffffc020384e <mm_destroy+0x32>
ffffffffc0203826:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203828:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc020382a:	00a40c63          	beq	s0,a0,ffffffffc0203842 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020382e:	6118                	ld	a4,0(a0)
ffffffffc0203830:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc0203832:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203834:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203836:	e398                	sd	a4,0(a5)
ffffffffc0203838:	d52fe0ef          	jal	ra,ffffffffc0201d8a <kfree>
    return listelm->next;
ffffffffc020383c:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc020383e:	fea418e3          	bne	s0,a0,ffffffffc020382e <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc0203842:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc0203844:	6402                	ld	s0,0(sp)
ffffffffc0203846:	60a2                	ld	ra,8(sp)
ffffffffc0203848:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc020384a:	d40fe06f          	j	ffffffffc0201d8a <kfree>
    assert(mm_count(mm) == 0);
ffffffffc020384e:	00003697          	auipc	a3,0x3
ffffffffc0203852:	5c268693          	addi	a3,a3,1474 # ffffffffc0206e10 <default_pmm_manager+0x818>
ffffffffc0203856:	00003617          	auipc	a2,0x3
ffffffffc020385a:	9f260613          	addi	a2,a2,-1550 # ffffffffc0206248 <commands+0x828>
ffffffffc020385e:	09e00593          	li	a1,158
ffffffffc0203862:	00003517          	auipc	a0,0x3
ffffffffc0203866:	53e50513          	addi	a0,a0,1342 # ffffffffc0206da0 <default_pmm_manager+0x7a8>
ffffffffc020386a:	c25fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020386e <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
ffffffffc020386e:	7139                	addi	sp,sp,-64
ffffffffc0203870:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0203872:	6405                	lui	s0,0x1
ffffffffc0203874:	147d                	addi	s0,s0,-1
ffffffffc0203876:	77fd                	lui	a5,0xfffff
ffffffffc0203878:	9622                	add	a2,a2,s0
ffffffffc020387a:	962e                	add	a2,a2,a1
{
ffffffffc020387c:	f426                	sd	s1,40(sp)
ffffffffc020387e:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0203880:	00f5f4b3          	and	s1,a1,a5
{
ffffffffc0203884:	f04a                	sd	s2,32(sp)
ffffffffc0203886:	ec4e                	sd	s3,24(sp)
ffffffffc0203888:	e852                	sd	s4,16(sp)
ffffffffc020388a:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end))
ffffffffc020388c:	002005b7          	lui	a1,0x200
ffffffffc0203890:	00f67433          	and	s0,a2,a5
ffffffffc0203894:	06b4e363          	bltu	s1,a1,ffffffffc02038fa <mm_map+0x8c>
ffffffffc0203898:	0684f163          	bgeu	s1,s0,ffffffffc02038fa <mm_map+0x8c>
ffffffffc020389c:	4785                	li	a5,1
ffffffffc020389e:	07fe                	slli	a5,a5,0x1f
ffffffffc02038a0:	0487ed63          	bltu	a5,s0,ffffffffc02038fa <mm_map+0x8c>
ffffffffc02038a4:	89aa                	mv	s3,a0
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02038a6:	cd21                	beqz	a0,ffffffffc02038fe <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc02038a8:	85a6                	mv	a1,s1
ffffffffc02038aa:	8ab6                	mv	s5,a3
ffffffffc02038ac:	8a3a                	mv	s4,a4
ffffffffc02038ae:	e5fff0ef          	jal	ra,ffffffffc020370c <find_vma>
ffffffffc02038b2:	c501                	beqz	a0,ffffffffc02038ba <mm_map+0x4c>
ffffffffc02038b4:	651c                	ld	a5,8(a0)
ffffffffc02038b6:	0487e263          	bltu	a5,s0,ffffffffc02038fa <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02038ba:	03000513          	li	a0,48
ffffffffc02038be:	c1cfe0ef          	jal	ra,ffffffffc0201cda <kmalloc>
ffffffffc02038c2:	892a                	mv	s2,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02038c4:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc02038c6:	02090163          	beqz	s2,ffffffffc02038e8 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02038ca:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02038cc:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc02038d0:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc02038d4:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc02038d8:	85ca                	mv	a1,s2
ffffffffc02038da:	e73ff0ef          	jal	ra,ffffffffc020374c <insert_vma_struct>
    if (vma_store != NULL)
    {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc02038de:	4501                	li	a0,0
    if (vma_store != NULL)
ffffffffc02038e0:	000a0463          	beqz	s4,ffffffffc02038e8 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc02038e4:	012a3023          	sd	s2,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8ba8>

out:
    return ret;
}
ffffffffc02038e8:	70e2                	ld	ra,56(sp)
ffffffffc02038ea:	7442                	ld	s0,48(sp)
ffffffffc02038ec:	74a2                	ld	s1,40(sp)
ffffffffc02038ee:	7902                	ld	s2,32(sp)
ffffffffc02038f0:	69e2                	ld	s3,24(sp)
ffffffffc02038f2:	6a42                	ld	s4,16(sp)
ffffffffc02038f4:	6aa2                	ld	s5,8(sp)
ffffffffc02038f6:	6121                	addi	sp,sp,64
ffffffffc02038f8:	8082                	ret
        return -E_INVAL;
ffffffffc02038fa:	5575                	li	a0,-3
ffffffffc02038fc:	b7f5                	j	ffffffffc02038e8 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc02038fe:	00003697          	auipc	a3,0x3
ffffffffc0203902:	52a68693          	addi	a3,a3,1322 # ffffffffc0206e28 <default_pmm_manager+0x830>
ffffffffc0203906:	00003617          	auipc	a2,0x3
ffffffffc020390a:	94260613          	addi	a2,a2,-1726 # ffffffffc0206248 <commands+0x828>
ffffffffc020390e:	0b300593          	li	a1,179
ffffffffc0203912:	00003517          	auipc	a0,0x3
ffffffffc0203916:	48e50513          	addi	a0,a0,1166 # ffffffffc0206da0 <default_pmm_manager+0x7a8>
ffffffffc020391a:	b75fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020391e <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc020391e:	7139                	addi	sp,sp,-64
ffffffffc0203920:	fc06                	sd	ra,56(sp)
ffffffffc0203922:	f822                	sd	s0,48(sp)
ffffffffc0203924:	f426                	sd	s1,40(sp)
ffffffffc0203926:	f04a                	sd	s2,32(sp)
ffffffffc0203928:	ec4e                	sd	s3,24(sp)
ffffffffc020392a:	e852                	sd	s4,16(sp)
ffffffffc020392c:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc020392e:	c52d                	beqz	a0,ffffffffc0203998 <dup_mmap+0x7a>
ffffffffc0203930:	892a                	mv	s2,a0
ffffffffc0203932:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0203934:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0203936:	e595                	bnez	a1,ffffffffc0203962 <dup_mmap+0x44>
ffffffffc0203938:	a085                	j	ffffffffc0203998 <dup_mmap+0x7a>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc020393a:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc020393c:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4ef0>
        vma->vm_end = vm_end;
ffffffffc0203940:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0203944:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc0203948:	e05ff0ef          	jal	ra,ffffffffc020374c <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc020394c:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bb8>
ffffffffc0203950:	fe843603          	ld	a2,-24(s0)
ffffffffc0203954:	6c8c                	ld	a1,24(s1)
ffffffffc0203956:	01893503          	ld	a0,24(s2)
ffffffffc020395a:	4701                	li	a4,0
ffffffffc020395c:	a3bff0ef          	jal	ra,ffffffffc0203396 <copy_range>
ffffffffc0203960:	e105                	bnez	a0,ffffffffc0203980 <dup_mmap+0x62>
    return listelm->prev;
ffffffffc0203962:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc0203964:	02848863          	beq	s1,s0,ffffffffc0203994 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203968:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc020396c:	fe843a83          	ld	s5,-24(s0)
ffffffffc0203970:	ff043a03          	ld	s4,-16(s0)
ffffffffc0203974:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203978:	b62fe0ef          	jal	ra,ffffffffc0201cda <kmalloc>
ffffffffc020397c:	85aa                	mv	a1,a0
    if (vma != NULL)
ffffffffc020397e:	fd55                	bnez	a0,ffffffffc020393a <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0203980:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0203982:	70e2                	ld	ra,56(sp)
ffffffffc0203984:	7442                	ld	s0,48(sp)
ffffffffc0203986:	74a2                	ld	s1,40(sp)
ffffffffc0203988:	7902                	ld	s2,32(sp)
ffffffffc020398a:	69e2                	ld	s3,24(sp)
ffffffffc020398c:	6a42                	ld	s4,16(sp)
ffffffffc020398e:	6aa2                	ld	s5,8(sp)
ffffffffc0203990:	6121                	addi	sp,sp,64
ffffffffc0203992:	8082                	ret
    return 0;
ffffffffc0203994:	4501                	li	a0,0
ffffffffc0203996:	b7f5                	j	ffffffffc0203982 <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc0203998:	00003697          	auipc	a3,0x3
ffffffffc020399c:	4a068693          	addi	a3,a3,1184 # ffffffffc0206e38 <default_pmm_manager+0x840>
ffffffffc02039a0:	00003617          	auipc	a2,0x3
ffffffffc02039a4:	8a860613          	addi	a2,a2,-1880 # ffffffffc0206248 <commands+0x828>
ffffffffc02039a8:	0cf00593          	li	a1,207
ffffffffc02039ac:	00003517          	auipc	a0,0x3
ffffffffc02039b0:	3f450513          	addi	a0,a0,1012 # ffffffffc0206da0 <default_pmm_manager+0x7a8>
ffffffffc02039b4:	adbfc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02039b8 <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc02039b8:	1101                	addi	sp,sp,-32
ffffffffc02039ba:	ec06                	sd	ra,24(sp)
ffffffffc02039bc:	e822                	sd	s0,16(sp)
ffffffffc02039be:	e426                	sd	s1,8(sp)
ffffffffc02039c0:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02039c2:	c531                	beqz	a0,ffffffffc0203a0e <exit_mmap+0x56>
ffffffffc02039c4:	591c                	lw	a5,48(a0)
ffffffffc02039c6:	84aa                	mv	s1,a0
ffffffffc02039c8:	e3b9                	bnez	a5,ffffffffc0203a0e <exit_mmap+0x56>
    return listelm->next;
ffffffffc02039ca:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02039cc:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc02039d0:	02850663          	beq	a0,s0,ffffffffc02039fc <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02039d4:	ff043603          	ld	a2,-16(s0)
ffffffffc02039d8:	fe843583          	ld	a1,-24(s0)
ffffffffc02039dc:	854a                	mv	a0,s2
ffffffffc02039de:	80ffe0ef          	jal	ra,ffffffffc02021ec <unmap_range>
ffffffffc02039e2:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc02039e4:	fe8498e3          	bne	s1,s0,ffffffffc02039d4 <exit_mmap+0x1c>
ffffffffc02039e8:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc02039ea:	00848c63          	beq	s1,s0,ffffffffc0203a02 <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02039ee:	ff043603          	ld	a2,-16(s0)
ffffffffc02039f2:	fe843583          	ld	a1,-24(s0)
ffffffffc02039f6:	854a                	mv	a0,s2
ffffffffc02039f8:	93bfe0ef          	jal	ra,ffffffffc0202332 <exit_range>
ffffffffc02039fc:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc02039fe:	fe8498e3          	bne	s1,s0,ffffffffc02039ee <exit_mmap+0x36>
    }
}
ffffffffc0203a02:	60e2                	ld	ra,24(sp)
ffffffffc0203a04:	6442                	ld	s0,16(sp)
ffffffffc0203a06:	64a2                	ld	s1,8(sp)
ffffffffc0203a08:	6902                	ld	s2,0(sp)
ffffffffc0203a0a:	6105                	addi	sp,sp,32
ffffffffc0203a0c:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203a0e:	00003697          	auipc	a3,0x3
ffffffffc0203a12:	44a68693          	addi	a3,a3,1098 # ffffffffc0206e58 <default_pmm_manager+0x860>
ffffffffc0203a16:	00003617          	auipc	a2,0x3
ffffffffc0203a1a:	83260613          	addi	a2,a2,-1998 # ffffffffc0206248 <commands+0x828>
ffffffffc0203a1e:	0e800593          	li	a1,232
ffffffffc0203a22:	00003517          	auipc	a0,0x3
ffffffffc0203a26:	37e50513          	addi	a0,a0,894 # ffffffffc0206da0 <default_pmm_manager+0x7a8>
ffffffffc0203a2a:	a65fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203a2e <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0203a2e:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203a30:	04000513          	li	a0,64
{
ffffffffc0203a34:	fc06                	sd	ra,56(sp)
ffffffffc0203a36:	f822                	sd	s0,48(sp)
ffffffffc0203a38:	f426                	sd	s1,40(sp)
ffffffffc0203a3a:	f04a                	sd	s2,32(sp)
ffffffffc0203a3c:	ec4e                	sd	s3,24(sp)
ffffffffc0203a3e:	e852                	sd	s4,16(sp)
ffffffffc0203a40:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203a42:	a98fe0ef          	jal	ra,ffffffffc0201cda <kmalloc>
    if (mm != NULL)
ffffffffc0203a46:	2e050663          	beqz	a0,ffffffffc0203d32 <vmm_init+0x304>
ffffffffc0203a4a:	84aa                	mv	s1,a0
    elm->prev = elm->next = elm;
ffffffffc0203a4c:	e508                	sd	a0,8(a0)
ffffffffc0203a4e:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203a50:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203a54:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203a58:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0203a5c:	02053423          	sd	zero,40(a0)
ffffffffc0203a60:	02052823          	sw	zero,48(a0)
ffffffffc0203a64:	02053c23          	sd	zero,56(a0)
ffffffffc0203a68:	03200413          	li	s0,50
ffffffffc0203a6c:	a811                	j	ffffffffc0203a80 <vmm_init+0x52>
        vma->vm_start = vm_start;
ffffffffc0203a6e:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203a70:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203a72:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
ffffffffc0203a76:	146d                	addi	s0,s0,-5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203a78:	8526                	mv	a0,s1
ffffffffc0203a7a:	cd3ff0ef          	jal	ra,ffffffffc020374c <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0203a7e:	c80d                	beqz	s0,ffffffffc0203ab0 <vmm_init+0x82>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a80:	03000513          	li	a0,48
ffffffffc0203a84:	a56fe0ef          	jal	ra,ffffffffc0201cda <kmalloc>
ffffffffc0203a88:	85aa                	mv	a1,a0
ffffffffc0203a8a:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0203a8e:	f165                	bnez	a0,ffffffffc0203a6e <vmm_init+0x40>
        assert(vma != NULL);
ffffffffc0203a90:	00003697          	auipc	a3,0x3
ffffffffc0203a94:	56068693          	addi	a3,a3,1376 # ffffffffc0206ff0 <default_pmm_manager+0x9f8>
ffffffffc0203a98:	00002617          	auipc	a2,0x2
ffffffffc0203a9c:	7b060613          	addi	a2,a2,1968 # ffffffffc0206248 <commands+0x828>
ffffffffc0203aa0:	12c00593          	li	a1,300
ffffffffc0203aa4:	00003517          	auipc	a0,0x3
ffffffffc0203aa8:	2fc50513          	addi	a0,a0,764 # ffffffffc0206da0 <default_pmm_manager+0x7a8>
ffffffffc0203aac:	9e3fc0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc0203ab0:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203ab4:	1f900913          	li	s2,505
ffffffffc0203ab8:	a819                	j	ffffffffc0203ace <vmm_init+0xa0>
        vma->vm_start = vm_start;
ffffffffc0203aba:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203abc:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203abe:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203ac2:	0415                	addi	s0,s0,5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203ac4:	8526                	mv	a0,s1
ffffffffc0203ac6:	c87ff0ef          	jal	ra,ffffffffc020374c <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203aca:	03240a63          	beq	s0,s2,ffffffffc0203afe <vmm_init+0xd0>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203ace:	03000513          	li	a0,48
ffffffffc0203ad2:	a08fe0ef          	jal	ra,ffffffffc0201cda <kmalloc>
ffffffffc0203ad6:	85aa                	mv	a1,a0
ffffffffc0203ad8:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0203adc:	fd79                	bnez	a0,ffffffffc0203aba <vmm_init+0x8c>
        assert(vma != NULL);
ffffffffc0203ade:	00003697          	auipc	a3,0x3
ffffffffc0203ae2:	51268693          	addi	a3,a3,1298 # ffffffffc0206ff0 <default_pmm_manager+0x9f8>
ffffffffc0203ae6:	00002617          	auipc	a2,0x2
ffffffffc0203aea:	76260613          	addi	a2,a2,1890 # ffffffffc0206248 <commands+0x828>
ffffffffc0203aee:	13300593          	li	a1,307
ffffffffc0203af2:	00003517          	auipc	a0,0x3
ffffffffc0203af6:	2ae50513          	addi	a0,a0,686 # ffffffffc0206da0 <default_pmm_manager+0x7a8>
ffffffffc0203afa:	995fc0ef          	jal	ra,ffffffffc020048e <__panic>
    return listelm->next;
ffffffffc0203afe:	649c                	ld	a5,8(s1)
ffffffffc0203b00:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0203b02:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0203b06:	16f48663          	beq	s1,a5,ffffffffc0203c72 <vmm_init+0x244>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203b0a:	fe87b603          	ld	a2,-24(a5) # ffffffffffffefe8 <end+0x3fd548ec>
ffffffffc0203b0e:	ffe70693          	addi	a3,a4,-2
ffffffffc0203b12:	10d61063          	bne	a2,a3,ffffffffc0203c12 <vmm_init+0x1e4>
ffffffffc0203b16:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203b1a:	0ed71c63          	bne	a4,a3,ffffffffc0203c12 <vmm_init+0x1e4>
    for (i = 1; i <= step2; i++)
ffffffffc0203b1e:	0715                	addi	a4,a4,5
ffffffffc0203b20:	679c                	ld	a5,8(a5)
ffffffffc0203b22:	feb712e3          	bne	a4,a1,ffffffffc0203b06 <vmm_init+0xd8>
ffffffffc0203b26:	4a1d                	li	s4,7
ffffffffc0203b28:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203b2a:	1f900a93          	li	s5,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203b2e:	85a2                	mv	a1,s0
ffffffffc0203b30:	8526                	mv	a0,s1
ffffffffc0203b32:	bdbff0ef          	jal	ra,ffffffffc020370c <find_vma>
ffffffffc0203b36:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0203b38:	16050d63          	beqz	a0,ffffffffc0203cb2 <vmm_init+0x284>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0203b3c:	00140593          	addi	a1,s0,1
ffffffffc0203b40:	8526                	mv	a0,s1
ffffffffc0203b42:	bcbff0ef          	jal	ra,ffffffffc020370c <find_vma>
ffffffffc0203b46:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203b48:	14050563          	beqz	a0,ffffffffc0203c92 <vmm_init+0x264>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0203b4c:	85d2                	mv	a1,s4
ffffffffc0203b4e:	8526                	mv	a0,s1
ffffffffc0203b50:	bbdff0ef          	jal	ra,ffffffffc020370c <find_vma>
        assert(vma3 == NULL);
ffffffffc0203b54:	16051f63          	bnez	a0,ffffffffc0203cd2 <vmm_init+0x2a4>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0203b58:	00340593          	addi	a1,s0,3
ffffffffc0203b5c:	8526                	mv	a0,s1
ffffffffc0203b5e:	bafff0ef          	jal	ra,ffffffffc020370c <find_vma>
        assert(vma4 == NULL);
ffffffffc0203b62:	1a051863          	bnez	a0,ffffffffc0203d12 <vmm_init+0x2e4>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0203b66:	00440593          	addi	a1,s0,4
ffffffffc0203b6a:	8526                	mv	a0,s1
ffffffffc0203b6c:	ba1ff0ef          	jal	ra,ffffffffc020370c <find_vma>
        assert(vma5 == NULL);
ffffffffc0203b70:	18051163          	bnez	a0,ffffffffc0203cf2 <vmm_init+0x2c4>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203b74:	00893783          	ld	a5,8(s2)
ffffffffc0203b78:	0a879d63          	bne	a5,s0,ffffffffc0203c32 <vmm_init+0x204>
ffffffffc0203b7c:	01093783          	ld	a5,16(s2)
ffffffffc0203b80:	0b479963          	bne	a5,s4,ffffffffc0203c32 <vmm_init+0x204>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203b84:	0089b783          	ld	a5,8(s3)
ffffffffc0203b88:	0c879563          	bne	a5,s0,ffffffffc0203c52 <vmm_init+0x224>
ffffffffc0203b8c:	0109b783          	ld	a5,16(s3)
ffffffffc0203b90:	0d479163          	bne	a5,s4,ffffffffc0203c52 <vmm_init+0x224>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203b94:	0415                	addi	s0,s0,5
ffffffffc0203b96:	0a15                	addi	s4,s4,5
ffffffffc0203b98:	f9541be3          	bne	s0,s5,ffffffffc0203b2e <vmm_init+0x100>
ffffffffc0203b9c:	4411                	li	s0,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0203b9e:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0203ba0:	85a2                	mv	a1,s0
ffffffffc0203ba2:	8526                	mv	a0,s1
ffffffffc0203ba4:	b69ff0ef          	jal	ra,ffffffffc020370c <find_vma>
ffffffffc0203ba8:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL)
ffffffffc0203bac:	c90d                	beqz	a0,ffffffffc0203bde <vmm_init+0x1b0>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0203bae:	6914                	ld	a3,16(a0)
ffffffffc0203bb0:	6510                	ld	a2,8(a0)
ffffffffc0203bb2:	00003517          	auipc	a0,0x3
ffffffffc0203bb6:	3c650513          	addi	a0,a0,966 # ffffffffc0206f78 <default_pmm_manager+0x980>
ffffffffc0203bba:	ddafc0ef          	jal	ra,ffffffffc0200194 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203bbe:	00003697          	auipc	a3,0x3
ffffffffc0203bc2:	3e268693          	addi	a3,a3,994 # ffffffffc0206fa0 <default_pmm_manager+0x9a8>
ffffffffc0203bc6:	00002617          	auipc	a2,0x2
ffffffffc0203bca:	68260613          	addi	a2,a2,1666 # ffffffffc0206248 <commands+0x828>
ffffffffc0203bce:	15900593          	li	a1,345
ffffffffc0203bd2:	00003517          	auipc	a0,0x3
ffffffffc0203bd6:	1ce50513          	addi	a0,a0,462 # ffffffffc0206da0 <default_pmm_manager+0x7a8>
ffffffffc0203bda:	8b5fc0ef          	jal	ra,ffffffffc020048e <__panic>
    for (i = 4; i >= 0; i--)
ffffffffc0203bde:	147d                	addi	s0,s0,-1
ffffffffc0203be0:	fd2410e3          	bne	s0,s2,ffffffffc0203ba0 <vmm_init+0x172>
    }

    mm_destroy(mm);
ffffffffc0203be4:	8526                	mv	a0,s1
ffffffffc0203be6:	c37ff0ef          	jal	ra,ffffffffc020381c <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203bea:	00003517          	auipc	a0,0x3
ffffffffc0203bee:	3ce50513          	addi	a0,a0,974 # ffffffffc0206fb8 <default_pmm_manager+0x9c0>
ffffffffc0203bf2:	da2fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
}
ffffffffc0203bf6:	7442                	ld	s0,48(sp)
ffffffffc0203bf8:	70e2                	ld	ra,56(sp)
ffffffffc0203bfa:	74a2                	ld	s1,40(sp)
ffffffffc0203bfc:	7902                	ld	s2,32(sp)
ffffffffc0203bfe:	69e2                	ld	s3,24(sp)
ffffffffc0203c00:	6a42                	ld	s4,16(sp)
ffffffffc0203c02:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203c04:	00003517          	auipc	a0,0x3
ffffffffc0203c08:	3d450513          	addi	a0,a0,980 # ffffffffc0206fd8 <default_pmm_manager+0x9e0>
}
ffffffffc0203c0c:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203c0e:	d86fc06f          	j	ffffffffc0200194 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203c12:	00003697          	auipc	a3,0x3
ffffffffc0203c16:	27e68693          	addi	a3,a3,638 # ffffffffc0206e90 <default_pmm_manager+0x898>
ffffffffc0203c1a:	00002617          	auipc	a2,0x2
ffffffffc0203c1e:	62e60613          	addi	a2,a2,1582 # ffffffffc0206248 <commands+0x828>
ffffffffc0203c22:	13d00593          	li	a1,317
ffffffffc0203c26:	00003517          	auipc	a0,0x3
ffffffffc0203c2a:	17a50513          	addi	a0,a0,378 # ffffffffc0206da0 <default_pmm_manager+0x7a8>
ffffffffc0203c2e:	861fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203c32:	00003697          	auipc	a3,0x3
ffffffffc0203c36:	2e668693          	addi	a3,a3,742 # ffffffffc0206f18 <default_pmm_manager+0x920>
ffffffffc0203c3a:	00002617          	auipc	a2,0x2
ffffffffc0203c3e:	60e60613          	addi	a2,a2,1550 # ffffffffc0206248 <commands+0x828>
ffffffffc0203c42:	14e00593          	li	a1,334
ffffffffc0203c46:	00003517          	auipc	a0,0x3
ffffffffc0203c4a:	15a50513          	addi	a0,a0,346 # ffffffffc0206da0 <default_pmm_manager+0x7a8>
ffffffffc0203c4e:	841fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203c52:	00003697          	auipc	a3,0x3
ffffffffc0203c56:	2f668693          	addi	a3,a3,758 # ffffffffc0206f48 <default_pmm_manager+0x950>
ffffffffc0203c5a:	00002617          	auipc	a2,0x2
ffffffffc0203c5e:	5ee60613          	addi	a2,a2,1518 # ffffffffc0206248 <commands+0x828>
ffffffffc0203c62:	14f00593          	li	a1,335
ffffffffc0203c66:	00003517          	auipc	a0,0x3
ffffffffc0203c6a:	13a50513          	addi	a0,a0,314 # ffffffffc0206da0 <default_pmm_manager+0x7a8>
ffffffffc0203c6e:	821fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203c72:	00003697          	auipc	a3,0x3
ffffffffc0203c76:	20668693          	addi	a3,a3,518 # ffffffffc0206e78 <default_pmm_manager+0x880>
ffffffffc0203c7a:	00002617          	auipc	a2,0x2
ffffffffc0203c7e:	5ce60613          	addi	a2,a2,1486 # ffffffffc0206248 <commands+0x828>
ffffffffc0203c82:	13b00593          	li	a1,315
ffffffffc0203c86:	00003517          	auipc	a0,0x3
ffffffffc0203c8a:	11a50513          	addi	a0,a0,282 # ffffffffc0206da0 <default_pmm_manager+0x7a8>
ffffffffc0203c8e:	801fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma2 != NULL);
ffffffffc0203c92:	00003697          	auipc	a3,0x3
ffffffffc0203c96:	24668693          	addi	a3,a3,582 # ffffffffc0206ed8 <default_pmm_manager+0x8e0>
ffffffffc0203c9a:	00002617          	auipc	a2,0x2
ffffffffc0203c9e:	5ae60613          	addi	a2,a2,1454 # ffffffffc0206248 <commands+0x828>
ffffffffc0203ca2:	14600593          	li	a1,326
ffffffffc0203ca6:	00003517          	auipc	a0,0x3
ffffffffc0203caa:	0fa50513          	addi	a0,a0,250 # ffffffffc0206da0 <default_pmm_manager+0x7a8>
ffffffffc0203cae:	fe0fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma1 != NULL);
ffffffffc0203cb2:	00003697          	auipc	a3,0x3
ffffffffc0203cb6:	21668693          	addi	a3,a3,534 # ffffffffc0206ec8 <default_pmm_manager+0x8d0>
ffffffffc0203cba:	00002617          	auipc	a2,0x2
ffffffffc0203cbe:	58e60613          	addi	a2,a2,1422 # ffffffffc0206248 <commands+0x828>
ffffffffc0203cc2:	14400593          	li	a1,324
ffffffffc0203cc6:	00003517          	auipc	a0,0x3
ffffffffc0203cca:	0da50513          	addi	a0,a0,218 # ffffffffc0206da0 <default_pmm_manager+0x7a8>
ffffffffc0203cce:	fc0fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma3 == NULL);
ffffffffc0203cd2:	00003697          	auipc	a3,0x3
ffffffffc0203cd6:	21668693          	addi	a3,a3,534 # ffffffffc0206ee8 <default_pmm_manager+0x8f0>
ffffffffc0203cda:	00002617          	auipc	a2,0x2
ffffffffc0203cde:	56e60613          	addi	a2,a2,1390 # ffffffffc0206248 <commands+0x828>
ffffffffc0203ce2:	14800593          	li	a1,328
ffffffffc0203ce6:	00003517          	auipc	a0,0x3
ffffffffc0203cea:	0ba50513          	addi	a0,a0,186 # ffffffffc0206da0 <default_pmm_manager+0x7a8>
ffffffffc0203cee:	fa0fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma5 == NULL);
ffffffffc0203cf2:	00003697          	auipc	a3,0x3
ffffffffc0203cf6:	21668693          	addi	a3,a3,534 # ffffffffc0206f08 <default_pmm_manager+0x910>
ffffffffc0203cfa:	00002617          	auipc	a2,0x2
ffffffffc0203cfe:	54e60613          	addi	a2,a2,1358 # ffffffffc0206248 <commands+0x828>
ffffffffc0203d02:	14c00593          	li	a1,332
ffffffffc0203d06:	00003517          	auipc	a0,0x3
ffffffffc0203d0a:	09a50513          	addi	a0,a0,154 # ffffffffc0206da0 <default_pmm_manager+0x7a8>
ffffffffc0203d0e:	f80fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma4 == NULL);
ffffffffc0203d12:	00003697          	auipc	a3,0x3
ffffffffc0203d16:	1e668693          	addi	a3,a3,486 # ffffffffc0206ef8 <default_pmm_manager+0x900>
ffffffffc0203d1a:	00002617          	auipc	a2,0x2
ffffffffc0203d1e:	52e60613          	addi	a2,a2,1326 # ffffffffc0206248 <commands+0x828>
ffffffffc0203d22:	14a00593          	li	a1,330
ffffffffc0203d26:	00003517          	auipc	a0,0x3
ffffffffc0203d2a:	07a50513          	addi	a0,a0,122 # ffffffffc0206da0 <default_pmm_manager+0x7a8>
ffffffffc0203d2e:	f60fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(mm != NULL);
ffffffffc0203d32:	00003697          	auipc	a3,0x3
ffffffffc0203d36:	0f668693          	addi	a3,a3,246 # ffffffffc0206e28 <default_pmm_manager+0x830>
ffffffffc0203d3a:	00002617          	auipc	a2,0x2
ffffffffc0203d3e:	50e60613          	addi	a2,a2,1294 # ffffffffc0206248 <commands+0x828>
ffffffffc0203d42:	12400593          	li	a1,292
ffffffffc0203d46:	00003517          	auipc	a0,0x3
ffffffffc0203d4a:	05a50513          	addi	a0,a0,90 # ffffffffc0206da0 <default_pmm_manager+0x7a8>
ffffffffc0203d4e:	f40fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203d52 <user_mem_check>:
}
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc0203d52:	7179                	addi	sp,sp,-48
ffffffffc0203d54:	f022                	sd	s0,32(sp)
ffffffffc0203d56:	f406                	sd	ra,40(sp)
ffffffffc0203d58:	ec26                	sd	s1,24(sp)
ffffffffc0203d5a:	e84a                	sd	s2,16(sp)
ffffffffc0203d5c:	e44e                	sd	s3,8(sp)
ffffffffc0203d5e:	e052                	sd	s4,0(sp)
ffffffffc0203d60:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc0203d62:	c135                	beqz	a0,ffffffffc0203dc6 <user_mem_check+0x74>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc0203d64:	002007b7          	lui	a5,0x200
ffffffffc0203d68:	04f5e663          	bltu	a1,a5,ffffffffc0203db4 <user_mem_check+0x62>
ffffffffc0203d6c:	00c584b3          	add	s1,a1,a2
ffffffffc0203d70:	0495f263          	bgeu	a1,s1,ffffffffc0203db4 <user_mem_check+0x62>
ffffffffc0203d74:	4785                	li	a5,1
ffffffffc0203d76:	07fe                	slli	a5,a5,0x1f
ffffffffc0203d78:	0297ee63          	bltu	a5,s1,ffffffffc0203db4 <user_mem_check+0x62>
ffffffffc0203d7c:	892a                	mv	s2,a0
ffffffffc0203d7e:	89b6                	mv	s3,a3
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203d80:	6a05                	lui	s4,0x1
ffffffffc0203d82:	a821                	j	ffffffffc0203d9a <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203d84:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203d88:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203d8a:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203d8c:	c685                	beqz	a3,ffffffffc0203db4 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203d8e:	c399                	beqz	a5,ffffffffc0203d94 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203d90:	02e46263          	bltu	s0,a4,ffffffffc0203db4 <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0203d94:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc0203d96:	04947663          	bgeu	s0,s1,ffffffffc0203de2 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc0203d9a:	85a2                	mv	a1,s0
ffffffffc0203d9c:	854a                	mv	a0,s2
ffffffffc0203d9e:	96fff0ef          	jal	ra,ffffffffc020370c <find_vma>
ffffffffc0203da2:	c909                	beqz	a0,ffffffffc0203db4 <user_mem_check+0x62>
ffffffffc0203da4:	6518                	ld	a4,8(a0)
ffffffffc0203da6:	00e46763          	bltu	s0,a4,ffffffffc0203db4 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203daa:	4d1c                	lw	a5,24(a0)
ffffffffc0203dac:	fc099ce3          	bnez	s3,ffffffffc0203d84 <user_mem_check+0x32>
ffffffffc0203db0:	8b85                	andi	a5,a5,1
ffffffffc0203db2:	f3ed                	bnez	a5,ffffffffc0203d94 <user_mem_check+0x42>
            return 0;
ffffffffc0203db4:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203db6:	70a2                	ld	ra,40(sp)
ffffffffc0203db8:	7402                	ld	s0,32(sp)
ffffffffc0203dba:	64e2                	ld	s1,24(sp)
ffffffffc0203dbc:	6942                	ld	s2,16(sp)
ffffffffc0203dbe:	69a2                	ld	s3,8(sp)
ffffffffc0203dc0:	6a02                	ld	s4,0(sp)
ffffffffc0203dc2:	6145                	addi	sp,sp,48
ffffffffc0203dc4:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203dc6:	c02007b7          	lui	a5,0xc0200
ffffffffc0203dca:	4501                	li	a0,0
ffffffffc0203dcc:	fef5e5e3          	bltu	a1,a5,ffffffffc0203db6 <user_mem_check+0x64>
ffffffffc0203dd0:	962e                	add	a2,a2,a1
ffffffffc0203dd2:	fec5f2e3          	bgeu	a1,a2,ffffffffc0203db6 <user_mem_check+0x64>
ffffffffc0203dd6:	c8000537          	lui	a0,0xc8000
ffffffffc0203dda:	0505                	addi	a0,a0,1
ffffffffc0203ddc:	00a63533          	sltu	a0,a2,a0
ffffffffc0203de0:	bfd9                	j	ffffffffc0203db6 <user_mem_check+0x64>
        return 1;
ffffffffc0203de2:	4505                	li	a0,1
ffffffffc0203de4:	bfc9                	j	ffffffffc0203db6 <user_mem_check+0x64>

ffffffffc0203de6 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0203de6:	8526                	mv	a0,s1
	jalr s0
ffffffffc0203de8:	9402                	jalr	s0

	jal do_exit
ffffffffc0203dea:	6ac000ef          	jal	ra,ffffffffc0204496 <do_exit>

ffffffffc0203dee <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc0203dee:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203df0:	10800513          	li	a0,264
{
ffffffffc0203df4:	e022                	sd	s0,0(sp)
ffffffffc0203df6:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203df8:	ee3fd0ef          	jal	ra,ffffffffc0201cda <kmalloc>
ffffffffc0203dfc:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc0203dfe:	cd21                	beqz	a0,ffffffffc0203e56 <alloc_proc+0x68>
        /*
         * below fields(add in LAB5) in proc_struct need to be initialized
         *       uint32_t wait_state;                        // waiting state
         *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
         */
        proc->state = PROC_UNINIT;        // 尚未进入就绪态
ffffffffc0203e00:	57fd                	li	a5,-1
ffffffffc0203e02:	1782                	slli	a5,a5,0x20
ffffffffc0203e04:	e11c                	sd	a5,0(a0)
        proc->runs = 0;                   // 运行次数计数器清零
        proc->kstack = 0;                 // 还未分配内核栈
        proc->need_resched = 0;           // 默认不请求调度
        proc->parent = NULL;              // 父进程待后续设置
        proc->mm = NULL;                  // 地址空间后续 copy/share
        memset(&proc->context, 0, sizeof(struct context)); // 确保首次 switch_to 有确定值
ffffffffc0203e06:	07000613          	li	a2,112
ffffffffc0203e0a:	4581                	li	a1,0
        proc->runs = 0;                   // 运行次数计数器清零
ffffffffc0203e0c:	00052423          	sw	zero,8(a0) # ffffffffc8000008 <end+0x7d5590c>
        proc->kstack = 0;                 // 还未分配内核栈
ffffffffc0203e10:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;           // 默认不请求调度
ffffffffc0203e14:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;              // 父进程待后续设置
ffffffffc0203e18:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;                  // 地址空间后续 copy/share
ffffffffc0203e1c:	02053423          	sd	zero,40(a0)
        memset(&proc->context, 0, sizeof(struct context)); // 确保首次 switch_to 有确定值
ffffffffc0203e20:	03050513          	addi	a0,a0,48
ffffffffc0203e24:	16b010ef          	jal	ra,ffffffffc020578e <memset>
        proc->tf = NULL;                  // trapframe 等栈建立后 copy_thread 设置
        proc->pgdir = boot_pgdir_pa;      // 先使用内核页表基址
ffffffffc0203e28:	000a7797          	auipc	a5,0xa7
ffffffffc0203e2c:	8887b783          	ld	a5,-1912(a5) # ffffffffc02aa6b0 <boot_pgdir_pa>
        proc->tf = NULL;                  // trapframe 等栈建立后 copy_thread 设置
ffffffffc0203e30:	0a043023          	sd	zero,160(s0)
        proc->pgdir = boot_pgdir_pa;      // 先使用内核页表基址
ffffffffc0203e34:	f45c                	sd	a5,168(s0)
        proc->flags = 0;                  // 初始无标志
ffffffffc0203e36:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, sizeof(proc->name)); // 进程名清零，后续 set_proc_name
ffffffffc0203e3a:	4641                	li	a2,16
ffffffffc0203e3c:	4581                	li	a1,0
ffffffffc0203e3e:	0b440513          	addi	a0,s0,180
ffffffffc0203e42:	14d010ef          	jal	ra,ffffffffc020578e <memset>

        // LAB5: 初始化新增字段
        proc->exit_code = 0;              // 退出码初始化为0
ffffffffc0203e46:	0e043423          	sd	zero,232(s0)
        proc->wait_state = 0;             // 等待状态初始化为0
        proc->cptr = proc->yptr = proc->optr = NULL; // 进程关系指针初始化为NULL
ffffffffc0203e4a:	0e043823          	sd	zero,240(s0)
ffffffffc0203e4e:	0e043c23          	sd	zero,248(s0)
ffffffffc0203e52:	10043023          	sd	zero,256(s0)
    }
    return proc;
}
ffffffffc0203e56:	60a2                	ld	ra,8(sp)
ffffffffc0203e58:	8522                	mv	a0,s0
ffffffffc0203e5a:	6402                	ld	s0,0(sp)
ffffffffc0203e5c:	0141                	addi	sp,sp,16
ffffffffc0203e5e:	8082                	ret

ffffffffc0203e60 <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc0203e60:	000a7797          	auipc	a5,0xa7
ffffffffc0203e64:	8807b783          	ld	a5,-1920(a5) # ffffffffc02aa6e0 <current>
ffffffffc0203e68:	73c8                	ld	a0,160(a5)
ffffffffc0203e6a:	8e4fd06f          	j	ffffffffc0200f4e <forkrets>

ffffffffc0203e6e <user_main>:
// user_main - kernel thread used to exec a user program
static int
user_main(void *arg)
{
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0203e6e:	000a7797          	auipc	a5,0xa7
ffffffffc0203e72:	8727b783          	ld	a5,-1934(a5) # ffffffffc02aa6e0 <current>
ffffffffc0203e76:	43cc                	lw	a1,4(a5)
{
ffffffffc0203e78:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0203e7a:	00003617          	auipc	a2,0x3
ffffffffc0203e7e:	18660613          	addi	a2,a2,390 # ffffffffc0207000 <default_pmm_manager+0xa08>
ffffffffc0203e82:	00003517          	auipc	a0,0x3
ffffffffc0203e86:	18e50513          	addi	a0,a0,398 # ffffffffc0207010 <default_pmm_manager+0xa18>
{
ffffffffc0203e8a:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0203e8c:	b08fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0203e90:	3fe07797          	auipc	a5,0x3fe07
ffffffffc0203e94:	ad078793          	addi	a5,a5,-1328 # a960 <_binary_obj___user_forktest_out_size>
ffffffffc0203e98:	e43e                	sd	a5,8(sp)
ffffffffc0203e9a:	00003517          	auipc	a0,0x3
ffffffffc0203e9e:	16650513          	addi	a0,a0,358 # ffffffffc0207000 <default_pmm_manager+0xa08>
ffffffffc0203ea2:	00046797          	auipc	a5,0x46
ffffffffc0203ea6:	83e78793          	addi	a5,a5,-1986 # ffffffffc02496e0 <_binary_obj___user_forktest_out_start>
ffffffffc0203eaa:	f03e                	sd	a5,32(sp)
ffffffffc0203eac:	f42a                	sd	a0,40(sp)
    int64_t ret = 0, len = strlen(name);
ffffffffc0203eae:	e802                	sd	zero,16(sp)
ffffffffc0203eb0:	03d010ef          	jal	ra,ffffffffc02056ec <strlen>
ffffffffc0203eb4:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0203eb6:	4511                	li	a0,4
ffffffffc0203eb8:	55a2                	lw	a1,40(sp)
ffffffffc0203eba:	4662                	lw	a2,24(sp)
ffffffffc0203ebc:	5682                	lw	a3,32(sp)
ffffffffc0203ebe:	4722                	lw	a4,8(sp)
ffffffffc0203ec0:	48a9                	li	a7,10
ffffffffc0203ec2:	9002                	ebreak
ffffffffc0203ec4:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0203ec6:	65c2                	ld	a1,16(sp)
ffffffffc0203ec8:	00003517          	auipc	a0,0x3
ffffffffc0203ecc:	17050513          	addi	a0,a0,368 # ffffffffc0207038 <default_pmm_manager+0xa40>
ffffffffc0203ed0:	ac4fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0203ed4:	00003617          	auipc	a2,0x3
ffffffffc0203ed8:	17460613          	addi	a2,a2,372 # ffffffffc0207048 <default_pmm_manager+0xa50>
ffffffffc0203edc:	3bb00593          	li	a1,955
ffffffffc0203ee0:	00003517          	auipc	a0,0x3
ffffffffc0203ee4:	18850513          	addi	a0,a0,392 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc0203ee8:	da6fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203eec <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0203eec:	6d14                	ld	a3,24(a0)
{
ffffffffc0203eee:	1141                	addi	sp,sp,-16
ffffffffc0203ef0:	e406                	sd	ra,8(sp)
ffffffffc0203ef2:	c02007b7          	lui	a5,0xc0200
ffffffffc0203ef6:	02f6ee63          	bltu	a3,a5,ffffffffc0203f32 <put_pgdir+0x46>
ffffffffc0203efa:	000a6517          	auipc	a0,0xa6
ffffffffc0203efe:	7de53503          	ld	a0,2014(a0) # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc0203f02:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage)
ffffffffc0203f04:	82b1                	srli	a3,a3,0xc
ffffffffc0203f06:	000a6797          	auipc	a5,0xa6
ffffffffc0203f0a:	7ba7b783          	ld	a5,1978(a5) # ffffffffc02aa6c0 <npage>
ffffffffc0203f0e:	02f6fe63          	bgeu	a3,a5,ffffffffc0203f4a <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203f12:	00004517          	auipc	a0,0x4
ffffffffc0203f16:	b6e53503          	ld	a0,-1170(a0) # ffffffffc0207a80 <nbase>
}
ffffffffc0203f1a:	60a2                	ld	ra,8(sp)
ffffffffc0203f1c:	8e89                	sub	a3,a3,a0
ffffffffc0203f1e:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0203f20:	000a6517          	auipc	a0,0xa6
ffffffffc0203f24:	7a853503          	ld	a0,1960(a0) # ffffffffc02aa6c8 <pages>
ffffffffc0203f28:	4585                	li	a1,1
ffffffffc0203f2a:	9536                	add	a0,a0,a3
}
ffffffffc0203f2c:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0203f2e:	fc9fd06f          	j	ffffffffc0201ef6 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0203f32:	00002617          	auipc	a2,0x2
ffffffffc0203f36:	7a660613          	addi	a2,a2,1958 # ffffffffc02066d8 <default_pmm_manager+0xe0>
ffffffffc0203f3a:	07700593          	li	a1,119
ffffffffc0203f3e:	00002517          	auipc	a0,0x2
ffffffffc0203f42:	71a50513          	addi	a0,a0,1818 # ffffffffc0206658 <default_pmm_manager+0x60>
ffffffffc0203f46:	d48fc0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203f4a:	00002617          	auipc	a2,0x2
ffffffffc0203f4e:	7b660613          	addi	a2,a2,1974 # ffffffffc0206700 <default_pmm_manager+0x108>
ffffffffc0203f52:	06900593          	li	a1,105
ffffffffc0203f56:	00002517          	auipc	a0,0x2
ffffffffc0203f5a:	70250513          	addi	a0,a0,1794 # ffffffffc0206658 <default_pmm_manager+0x60>
ffffffffc0203f5e:	d30fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203f62 <setup_pgdir>:
{
ffffffffc0203f62:	1101                	addi	sp,sp,-32
ffffffffc0203f64:	e426                	sd	s1,8(sp)
ffffffffc0203f66:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL)
ffffffffc0203f68:	4505                	li	a0,1
{
ffffffffc0203f6a:	ec06                	sd	ra,24(sp)
ffffffffc0203f6c:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL)
ffffffffc0203f6e:	f4bfd0ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
ffffffffc0203f72:	c935                	beqz	a0,ffffffffc0203fe6 <setup_pgdir+0x84>
    return page - pages + nbase;
ffffffffc0203f74:	000a6697          	auipc	a3,0xa6
ffffffffc0203f78:	7546b683          	ld	a3,1876(a3) # ffffffffc02aa6c8 <pages>
ffffffffc0203f7c:	40d506b3          	sub	a3,a0,a3
ffffffffc0203f80:	8699                	srai	a3,a3,0x6
ffffffffc0203f82:	00004417          	auipc	s0,0x4
ffffffffc0203f86:	afe43403          	ld	s0,-1282(s0) # ffffffffc0207a80 <nbase>
ffffffffc0203f8a:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0203f8c:	00c69793          	slli	a5,a3,0xc
ffffffffc0203f90:	83b1                	srli	a5,a5,0xc
ffffffffc0203f92:	000a6717          	auipc	a4,0xa6
ffffffffc0203f96:	72e73703          	ld	a4,1838(a4) # ffffffffc02aa6c0 <npage>
ffffffffc0203f9a:	85aa                	mv	a1,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203f9c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203f9e:	04e7f663          	bgeu	a5,a4,ffffffffc0203fea <setup_pgdir+0x88>
ffffffffc0203fa2:	000a6417          	auipc	s0,0xa6
ffffffffc0203fa6:	73643403          	ld	s0,1846(s0) # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc0203faa:	9436                	add	s0,s0,a3
    cprintf("[DEBUG] setup_pgdir: page=%p, pgdir(kva)=%p\n", page, pgdir);
ffffffffc0203fac:	8622                	mv	a2,s0
ffffffffc0203fae:	00003517          	auipc	a0,0x3
ffffffffc0203fb2:	0d250513          	addi	a0,a0,210 # ffffffffc0207080 <default_pmm_manager+0xa88>
ffffffffc0203fb6:	9defc0ef          	jal	ra,ffffffffc0200194 <cprintf>
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0203fba:	6605                	lui	a2,0x1
ffffffffc0203fbc:	000a6597          	auipc	a1,0xa6
ffffffffc0203fc0:	6fc5b583          	ld	a1,1788(a1) # ffffffffc02aa6b8 <boot_pgdir_va>
ffffffffc0203fc4:	8522                	mv	a0,s0
ffffffffc0203fc6:	7da010ef          	jal	ra,ffffffffc02057a0 <memcpy>
    cprintf("[DEBUG] setup_pgdir: mm->pgdir=%p\n", mm->pgdir);
ffffffffc0203fca:	85a2                	mv	a1,s0
    mm->pgdir = pgdir;
ffffffffc0203fcc:	ec80                	sd	s0,24(s1)
    cprintf("[DEBUG] setup_pgdir: mm->pgdir=%p\n", mm->pgdir);
ffffffffc0203fce:	00003517          	auipc	a0,0x3
ffffffffc0203fd2:	0e250513          	addi	a0,a0,226 # ffffffffc02070b0 <default_pmm_manager+0xab8>
ffffffffc0203fd6:	9befc0ef          	jal	ra,ffffffffc0200194 <cprintf>
    return 0;
ffffffffc0203fda:	4501                	li	a0,0
}
ffffffffc0203fdc:	60e2                	ld	ra,24(sp)
ffffffffc0203fde:	6442                	ld	s0,16(sp)
ffffffffc0203fe0:	64a2                	ld	s1,8(sp)
ffffffffc0203fe2:	6105                	addi	sp,sp,32
ffffffffc0203fe4:	8082                	ret
        return -E_NO_MEM;
ffffffffc0203fe6:	5571                	li	a0,-4
ffffffffc0203fe8:	bfd5                	j	ffffffffc0203fdc <setup_pgdir+0x7a>
ffffffffc0203fea:	00002617          	auipc	a2,0x2
ffffffffc0203fee:	64660613          	addi	a2,a2,1606 # ffffffffc0206630 <default_pmm_manager+0x38>
ffffffffc0203ff2:	07100593          	li	a1,113
ffffffffc0203ff6:	00002517          	auipc	a0,0x2
ffffffffc0203ffa:	66250513          	addi	a0,a0,1634 # ffffffffc0206658 <default_pmm_manager+0x60>
ffffffffc0203ffe:	c90fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204002 <proc_run>:
{
ffffffffc0204002:	7179                	addi	sp,sp,-48
ffffffffc0204004:	e84a                	sd	s2,16(sp)
    if (proc != current)
ffffffffc0204006:	000a6917          	auipc	s2,0xa6
ffffffffc020400a:	6da90913          	addi	s2,s2,1754 # ffffffffc02aa6e0 <current>
{
ffffffffc020400e:	ec26                	sd	s1,24(sp)
    if (proc != current)
ffffffffc0204010:	00093483          	ld	s1,0(s2)
{
ffffffffc0204014:	f406                	sd	ra,40(sp)
ffffffffc0204016:	f022                	sd	s0,32(sp)
ffffffffc0204018:	e44e                	sd	s3,8(sp)
    if (proc != current)
ffffffffc020401a:	04a48063          	beq	s1,a0,ffffffffc020405a <proc_run+0x58>
ffffffffc020401e:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204020:	100027f3          	csrr	a5,sstatus
ffffffffc0204024:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204026:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204028:	eba1                	bnez	a5,ffffffffc0204078 <proc_run+0x76>
            cprintf("[DEBUG] proc_run: proc->pgdir=%p, calling lsatp\n", proc->pgdir);
ffffffffc020402a:	744c                	ld	a1,168(s0)
ffffffffc020402c:	00003517          	auipc	a0,0x3
ffffffffc0204030:	0ac50513          	addi	a0,a0,172 # ffffffffc02070d8 <default_pmm_manager+0xae0>
            current = proc;
ffffffffc0204034:	00893023          	sd	s0,0(s2)
            cprintf("[DEBUG] proc_run: proc->pgdir=%p, calling lsatp\n", proc->pgdir);
ffffffffc0204038:	95cfc0ef          	jal	ra,ffffffffc0200194 <cprintf>
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned long pgdir)
{
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc020403c:	745c                	ld	a5,168(s0)
ffffffffc020403e:	577d                	li	a4,-1
ffffffffc0204040:	177e                	slli	a4,a4,0x3f
ffffffffc0204042:	83b1                	srli	a5,a5,0xc
ffffffffc0204044:	8fd9                	or	a5,a5,a4
ffffffffc0204046:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(proc->context));
ffffffffc020404a:	03040593          	addi	a1,s0,48
ffffffffc020404e:	03048513          	addi	a0,s1,48
ffffffffc0204052:	040010ef          	jal	ra,ffffffffc0205092 <switch_to>
    if (flag)
ffffffffc0204056:	00099963          	bnez	s3,ffffffffc0204068 <proc_run+0x66>
}
ffffffffc020405a:	70a2                	ld	ra,40(sp)
ffffffffc020405c:	7402                	ld	s0,32(sp)
ffffffffc020405e:	64e2                	ld	s1,24(sp)
ffffffffc0204060:	6942                	ld	s2,16(sp)
ffffffffc0204062:	69a2                	ld	s3,8(sp)
ffffffffc0204064:	6145                	addi	sp,sp,48
ffffffffc0204066:	8082                	ret
ffffffffc0204068:	7402                	ld	s0,32(sp)
ffffffffc020406a:	70a2                	ld	ra,40(sp)
ffffffffc020406c:	64e2                	ld	s1,24(sp)
ffffffffc020406e:	6942                	ld	s2,16(sp)
ffffffffc0204070:	69a2                	ld	s3,8(sp)
ffffffffc0204072:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0204074:	93bfc06f          	j	ffffffffc02009ae <intr_enable>
        intr_disable();
ffffffffc0204078:	93dfc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc020407c:	4985                	li	s3,1
            struct proc_struct *prev = current;
ffffffffc020407e:	00093483          	ld	s1,0(s2)
ffffffffc0204082:	b765                	j	ffffffffc020402a <proc_run+0x28>

ffffffffc0204084 <do_fork>:
{
ffffffffc0204084:	7159                	addi	sp,sp,-112
ffffffffc0204086:	eca6                	sd	s1,88(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0204088:	000a6497          	auipc	s1,0xa6
ffffffffc020408c:	67048493          	addi	s1,s1,1648 # ffffffffc02aa6f8 <nr_process>
ffffffffc0204090:	4098                	lw	a4,0(s1)
{
ffffffffc0204092:	f486                	sd	ra,104(sp)
ffffffffc0204094:	f0a2                	sd	s0,96(sp)
ffffffffc0204096:	e8ca                	sd	s2,80(sp)
ffffffffc0204098:	e4ce                	sd	s3,72(sp)
ffffffffc020409a:	e0d2                	sd	s4,64(sp)
ffffffffc020409c:	fc56                	sd	s5,56(sp)
ffffffffc020409e:	f85a                	sd	s6,48(sp)
ffffffffc02040a0:	f45e                	sd	s7,40(sp)
ffffffffc02040a2:	f062                	sd	s8,32(sp)
ffffffffc02040a4:	ec66                	sd	s9,24(sp)
ffffffffc02040a6:	e86a                	sd	s10,16(sp)
ffffffffc02040a8:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc02040aa:	6785                	lui	a5,0x1
ffffffffc02040ac:	2ef75363          	bge	a4,a5,ffffffffc0204392 <do_fork+0x30e>
ffffffffc02040b0:	8a2a                	mv	s4,a0
ffffffffc02040b2:	892e                	mv	s2,a1
ffffffffc02040b4:	89b2                	mv	s3,a2
    if ((proc = alloc_proc()) == NULL)
ffffffffc02040b6:	d39ff0ef          	jal	ra,ffffffffc0203dee <alloc_proc>
ffffffffc02040ba:	842a                	mv	s0,a0
ffffffffc02040bc:	2e050263          	beqz	a0,ffffffffc02043a0 <do_fork+0x31c>
    proc->parent = current;
ffffffffc02040c0:	000a6a97          	auipc	s5,0xa6
ffffffffc02040c4:	620a8a93          	addi	s5,s5,1568 # ffffffffc02aa6e0 <current>
ffffffffc02040c8:	000ab783          	ld	a5,0(s5)
    assert(current->wait_state == 0);
ffffffffc02040cc:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8abc>
    proc->parent = current;
ffffffffc02040d0:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc02040d2:	2c071e63          	bnez	a4,ffffffffc02043ae <do_fork+0x32a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02040d6:	4509                	li	a0,2
ffffffffc02040d8:	de1fd0ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
    if (page != NULL)
ffffffffc02040dc:	2a050963          	beqz	a0,ffffffffc020438e <do_fork+0x30a>
    return page - pages + nbase;
ffffffffc02040e0:	000a6b97          	auipc	s7,0xa6
ffffffffc02040e4:	5e8b8b93          	addi	s7,s7,1512 # ffffffffc02aa6c8 <pages>
ffffffffc02040e8:	000bb683          	ld	a3,0(s7)
ffffffffc02040ec:	00004d17          	auipc	s10,0x4
ffffffffc02040f0:	994d0d13          	addi	s10,s10,-1644 # ffffffffc0207a80 <nbase>
ffffffffc02040f4:	000d3703          	ld	a4,0(s10)
ffffffffc02040f8:	40d506b3          	sub	a3,a0,a3
ffffffffc02040fc:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02040fe:	000a6d97          	auipc	s11,0xa6
ffffffffc0204102:	5c2d8d93          	addi	s11,s11,1474 # ffffffffc02aa6c0 <npage>
    return page - pages + nbase;
ffffffffc0204106:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0204108:	000db703          	ld	a4,0(s11)
ffffffffc020410c:	00c69793          	slli	a5,a3,0xc
ffffffffc0204110:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204112:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204114:	2ae7fd63          	bgeu	a5,a4,ffffffffc02043ce <do_fork+0x34a>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204118:	000ab703          	ld	a4,0(s5)
ffffffffc020411c:	000a6b17          	auipc	s6,0xa6
ffffffffc0204120:	5bcb0b13          	addi	s6,s6,1468 # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc0204124:	000b3783          	ld	a5,0(s6)
ffffffffc0204128:	02873a83          	ld	s5,40(a4)
ffffffffc020412c:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc020412e:	e814                	sd	a3,16(s0)
    if (oldmm == NULL)
ffffffffc0204130:	040a8763          	beqz	s5,ffffffffc020417e <do_fork+0xfa>
    if (clone_flags & CLONE_VM)
ffffffffc0204134:	100a7a13          	andi	s4,s4,256
ffffffffc0204138:	1a0a0863          	beqz	s4,ffffffffc02042e8 <do_fork+0x264>
}

static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
ffffffffc020413c:	030aa783          	lw	a5,48(s5)
    cprintf("[DEBUG] copy_mm: mm->pgdir=%p (before PADDR)\n", mm->pgdir);
ffffffffc0204140:	018ab583          	ld	a1,24(s5)
ffffffffc0204144:	00003517          	auipc	a0,0x3
ffffffffc0204148:	01450513          	addi	a0,a0,20 # ffffffffc0207158 <default_pmm_manager+0xb60>
ffffffffc020414c:	2785                	addiw	a5,a5,1
ffffffffc020414e:	02faa823          	sw	a5,48(s5)
    proc->mm = mm;
ffffffffc0204152:	03543423          	sd	s5,40(s0)
    cprintf("[DEBUG] copy_mm: mm->pgdir=%p (before PADDR)\n", mm->pgdir);
ffffffffc0204156:	83efc0ef          	jal	ra,ffffffffc0200194 <cprintf>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc020415a:	018ab683          	ld	a3,24(s5)
ffffffffc020415e:	c02007b7          	lui	a5,0xc0200
ffffffffc0204162:	2cf6e663          	bltu	a3,a5,ffffffffc020442e <do_fork+0x3aa>
ffffffffc0204166:	000b3583          	ld	a1,0(s6)
    cprintf("[DEBUG] copy_mm: proc->pgdir=%p (after PADDR)\n", proc->pgdir);
ffffffffc020416a:	00003517          	auipc	a0,0x3
ffffffffc020416e:	01e50513          	addi	a0,a0,30 # ffffffffc0207188 <default_pmm_manager+0xb90>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204172:	40b685b3          	sub	a1,a3,a1
ffffffffc0204176:	f44c                	sd	a1,168(s0)
    cprintf("[DEBUG] copy_mm: proc->pgdir=%p (after PADDR)\n", proc->pgdir);
ffffffffc0204178:	81cfc0ef          	jal	ra,ffffffffc0200194 <cprintf>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc020417c:	6814                	ld	a3,16(s0)
ffffffffc020417e:	6789                	lui	a5,0x2
ffffffffc0204180:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cc8>
ffffffffc0204184:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204186:	864e                	mv	a2,s3
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204188:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc020418a:	87b6                	mv	a5,a3
ffffffffc020418c:	12098893          	addi	a7,s3,288
ffffffffc0204190:	00063803          	ld	a6,0(a2)
ffffffffc0204194:	6608                	ld	a0,8(a2)
ffffffffc0204196:	6a0c                	ld	a1,16(a2)
ffffffffc0204198:	6e18                	ld	a4,24(a2)
ffffffffc020419a:	0107b023          	sd	a6,0(a5)
ffffffffc020419e:	e788                	sd	a0,8(a5)
ffffffffc02041a0:	eb8c                	sd	a1,16(a5)
ffffffffc02041a2:	ef98                	sd	a4,24(a5)
ffffffffc02041a4:	02060613          	addi	a2,a2,32
ffffffffc02041a8:	02078793          	addi	a5,a5,32
ffffffffc02041ac:	ff1612e3          	bne	a2,a7,ffffffffc0204190 <do_fork+0x10c>
    proc->tf->gpr.a0 = 0;
ffffffffc02041b0:	0406b823          	sd	zero,80(a3)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02041b4:	18090763          	beqz	s2,ffffffffc0204342 <do_fork+0x2be>
    if (++last_pid >= MAX_PID)
ffffffffc02041b8:	000a2817          	auipc	a6,0xa2
ffffffffc02041bc:	09080813          	addi	a6,a6,144 # ffffffffc02a6248 <last_pid.1>
ffffffffc02041c0:	00082783          	lw	a5,0(a6)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02041c4:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02041c8:	00000717          	auipc	a4,0x0
ffffffffc02041cc:	c9870713          	addi	a4,a4,-872 # ffffffffc0203e60 <forkret>
    if (++last_pid >= MAX_PID)
ffffffffc02041d0:	0017851b          	addiw	a0,a5,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02041d4:	f818                	sd	a4,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02041d6:	fc14                	sd	a3,56(s0)
    if (++last_pid >= MAX_PID)
ffffffffc02041d8:	00a82023          	sw	a0,0(a6)
ffffffffc02041dc:	6789                	lui	a5,0x2
ffffffffc02041de:	08f55e63          	bge	a0,a5,ffffffffc020427a <do_fork+0x1f6>
    if (last_pid >= next_safe)
ffffffffc02041e2:	000a2317          	auipc	t1,0xa2
ffffffffc02041e6:	06a30313          	addi	t1,t1,106 # ffffffffc02a624c <next_safe.0>
ffffffffc02041ea:	00032783          	lw	a5,0(t1)
ffffffffc02041ee:	000a6917          	auipc	s2,0xa6
ffffffffc02041f2:	47a90913          	addi	s2,s2,1146 # ffffffffc02aa668 <proc_list>
ffffffffc02041f6:	08f55a63          	bge	a0,a5,ffffffffc020428a <do_fork+0x206>
    proc->pid = get_pid();
ffffffffc02041fa:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02041fc:	45a9                	li	a1,10
ffffffffc02041fe:	2501                	sext.w	a0,a0
ffffffffc0204200:	0e8010ef          	jal	ra,ffffffffc02052e8 <hash32>
ffffffffc0204204:	02051793          	slli	a5,a0,0x20
ffffffffc0204208:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020420c:	000a2797          	auipc	a5,0xa2
ffffffffc0204210:	45c78793          	addi	a5,a5,1116 # ffffffffc02a6668 <hash_list>
ffffffffc0204214:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204216:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204218:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020421a:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc020421e:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0204220:	00893603          	ld	a2,8(s2)
    prev->next = next->prev = elm;
ffffffffc0204224:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204226:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0204228:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc020422c:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc020422e:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc0204230:	e21c                	sd	a5,0(a2)
ffffffffc0204232:	00f93423          	sd	a5,8(s2)
    elm->next = next;
ffffffffc0204236:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc0204238:	0d243423          	sd	s2,200(s0)
    proc->yptr = NULL;
ffffffffc020423c:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204240:	10e43023          	sd	a4,256(s0)
ffffffffc0204244:	c311                	beqz	a4,ffffffffc0204248 <do_fork+0x1c4>
        proc->optr->yptr = proc;
ffffffffc0204246:	ff60                	sd	s0,248(a4)
    nr_process++;
ffffffffc0204248:	409c                	lw	a5,0(s1)
    proc->parent->cptr = proc;
ffffffffc020424a:	fae0                	sd	s0,240(a3)
    wakeup_proc(proc);
ffffffffc020424c:	8522                	mv	a0,s0
    nr_process++;
ffffffffc020424e:	2785                	addiw	a5,a5,1
ffffffffc0204250:	c09c                	sw	a5,0(s1)
    wakeup_proc(proc);
ffffffffc0204252:	6ab000ef          	jal	ra,ffffffffc02050fc <wakeup_proc>
    ret = proc->pid;
ffffffffc0204256:	00442c03          	lw	s8,4(s0)
}
ffffffffc020425a:	70a6                	ld	ra,104(sp)
ffffffffc020425c:	7406                	ld	s0,96(sp)
ffffffffc020425e:	64e6                	ld	s1,88(sp)
ffffffffc0204260:	6946                	ld	s2,80(sp)
ffffffffc0204262:	69a6                	ld	s3,72(sp)
ffffffffc0204264:	6a06                	ld	s4,64(sp)
ffffffffc0204266:	7ae2                	ld	s5,56(sp)
ffffffffc0204268:	7b42                	ld	s6,48(sp)
ffffffffc020426a:	7ba2                	ld	s7,40(sp)
ffffffffc020426c:	6ce2                	ld	s9,24(sp)
ffffffffc020426e:	6d42                	ld	s10,16(sp)
ffffffffc0204270:	6da2                	ld	s11,8(sp)
ffffffffc0204272:	8562                	mv	a0,s8
ffffffffc0204274:	7c02                	ld	s8,32(sp)
ffffffffc0204276:	6165                	addi	sp,sp,112
ffffffffc0204278:	8082                	ret
        last_pid = 1;
ffffffffc020427a:	4785                	li	a5,1
ffffffffc020427c:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc0204280:	4505                	li	a0,1
ffffffffc0204282:	000a2317          	auipc	t1,0xa2
ffffffffc0204286:	fca30313          	addi	t1,t1,-54 # ffffffffc02a624c <next_safe.0>
    return listelm->next;
ffffffffc020428a:	000a6917          	auipc	s2,0xa6
ffffffffc020428e:	3de90913          	addi	s2,s2,990 # ffffffffc02aa668 <proc_list>
ffffffffc0204292:	00893e03          	ld	t3,8(s2)
        next_safe = MAX_PID;
ffffffffc0204296:	6789                	lui	a5,0x2
ffffffffc0204298:	00f32023          	sw	a5,0(t1)
ffffffffc020429c:	86aa                	mv	a3,a0
ffffffffc020429e:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc02042a0:	6e89                	lui	t4,0x2
ffffffffc02042a2:	0f2e0a63          	beq	t3,s2,ffffffffc0204396 <do_fork+0x312>
ffffffffc02042a6:	88ae                	mv	a7,a1
ffffffffc02042a8:	87f2                	mv	a5,t3
ffffffffc02042aa:	6609                	lui	a2,0x2
ffffffffc02042ac:	a811                	j	ffffffffc02042c0 <do_fork+0x23c>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc02042ae:	00e6d663          	bge	a3,a4,ffffffffc02042ba <do_fork+0x236>
ffffffffc02042b2:	00c75463          	bge	a4,a2,ffffffffc02042ba <do_fork+0x236>
ffffffffc02042b6:	863a                	mv	a2,a4
ffffffffc02042b8:	4885                	li	a7,1
ffffffffc02042ba:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02042bc:	01278d63          	beq	a5,s2,ffffffffc02042d6 <do_fork+0x252>
            if (proc->pid == last_pid)
ffffffffc02042c0:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c6c>
ffffffffc02042c4:	fed715e3          	bne	a4,a3,ffffffffc02042ae <do_fork+0x22a>
                if (++last_pid >= next_safe)
ffffffffc02042c8:	2685                	addiw	a3,a3,1
ffffffffc02042ca:	0ac6dd63          	bge	a3,a2,ffffffffc0204384 <do_fork+0x300>
ffffffffc02042ce:	679c                	ld	a5,8(a5)
ffffffffc02042d0:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc02042d2:	ff2797e3          	bne	a5,s2,ffffffffc02042c0 <do_fork+0x23c>
ffffffffc02042d6:	c581                	beqz	a1,ffffffffc02042de <do_fork+0x25a>
ffffffffc02042d8:	00d82023          	sw	a3,0(a6)
ffffffffc02042dc:	8536                	mv	a0,a3
ffffffffc02042de:	f0088ee3          	beqz	a7,ffffffffc02041fa <do_fork+0x176>
ffffffffc02042e2:	00c32023          	sw	a2,0(t1)
ffffffffc02042e6:	bf11                	j	ffffffffc02041fa <do_fork+0x176>
    if ((mm = mm_create()) == NULL)
ffffffffc02042e8:	bf4ff0ef          	jal	ra,ffffffffc02036dc <mm_create>
ffffffffc02042ec:	8caa                	mv	s9,a0
ffffffffc02042ee:	cd55                	beqz	a0,ffffffffc02043aa <do_fork+0x326>
    if (setup_pgdir(mm) != 0)
ffffffffc02042f0:	c73ff0ef          	jal	ra,ffffffffc0203f62 <setup_pgdir>
ffffffffc02042f4:	e929                	bnez	a0,ffffffffc0204346 <do_fork+0x2c2>
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
ffffffffc02042f6:	038a8a13          	addi	s4,s5,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02042fa:	4785                	li	a5,1
ffffffffc02042fc:	40fa37af          	amoor.d	a5,a5,(s4)
}

static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))
ffffffffc0204300:	8b85                	andi	a5,a5,1
ffffffffc0204302:	4c05                	li	s8,1
ffffffffc0204304:	c799                	beqz	a5,ffffffffc0204312 <do_fork+0x28e>
    {
        schedule();
ffffffffc0204306:	677000ef          	jal	ra,ffffffffc020517c <schedule>
ffffffffc020430a:	418a37af          	amoor.d	a5,s8,(s4)
    while (!try_lock(lock))
ffffffffc020430e:	8b85                	andi	a5,a5,1
ffffffffc0204310:	fbfd                	bnez	a5,ffffffffc0204306 <do_fork+0x282>
        ret = dup_mmap(mm, oldmm);
ffffffffc0204312:	85d6                	mv	a1,s5
ffffffffc0204314:	8566                	mv	a0,s9
ffffffffc0204316:	e08ff0ef          	jal	ra,ffffffffc020391e <dup_mmap>
ffffffffc020431a:	8c2a                	mv	s8,a0
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020431c:	57f9                	li	a5,-2
ffffffffc020431e:	60fa37af          	amoand.d	a5,a5,(s4)
ffffffffc0204322:	8b85                	andi	a5,a5,1
}

static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))
ffffffffc0204324:	0e078963          	beqz	a5,ffffffffc0204416 <do_fork+0x392>
good_mm:
ffffffffc0204328:	8ae6                	mv	s5,s9
    if (ret != 0)
ffffffffc020432a:	e00509e3          	beqz	a0,ffffffffc020413c <do_fork+0xb8>
    exit_mmap(mm);
ffffffffc020432e:	8566                	mv	a0,s9
ffffffffc0204330:	e88ff0ef          	jal	ra,ffffffffc02039b8 <exit_mmap>
    put_pgdir(mm);
ffffffffc0204334:	8566                	mv	a0,s9
ffffffffc0204336:	bb7ff0ef          	jal	ra,ffffffffc0203eec <put_pgdir>
    mm_destroy(mm);
ffffffffc020433a:	8566                	mv	a0,s9
ffffffffc020433c:	ce0ff0ef          	jal	ra,ffffffffc020381c <mm_destroy>
ffffffffc0204340:	a039                	j	ffffffffc020434e <do_fork+0x2ca>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204342:	8936                	mv	s2,a3
ffffffffc0204344:	bd95                	j	ffffffffc02041b8 <do_fork+0x134>
    mm_destroy(mm);
ffffffffc0204346:	8566                	mv	a0,s9
ffffffffc0204348:	cd4ff0ef          	jal	ra,ffffffffc020381c <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc020434c:	5c71                	li	s8,-4
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020434e:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0204350:	c02007b7          	lui	a5,0xc0200
ffffffffc0204354:	0af6e563          	bltu	a3,a5,ffffffffc02043fe <do_fork+0x37a>
ffffffffc0204358:	000b3703          	ld	a4,0(s6)
    if (PPN(pa) >= npage)
ffffffffc020435c:	000db783          	ld	a5,0(s11)
    return pa2page(PADDR(kva));
ffffffffc0204360:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage)
ffffffffc0204362:	82b1                	srli	a3,a3,0xc
ffffffffc0204364:	08f6f163          	bgeu	a3,a5,ffffffffc02043e6 <do_fork+0x362>
    return &pages[PPN(pa) - nbase];
ffffffffc0204368:	000d3783          	ld	a5,0(s10)
ffffffffc020436c:	000bb503          	ld	a0,0(s7)
ffffffffc0204370:	4589                	li	a1,2
ffffffffc0204372:	8e9d                	sub	a3,a3,a5
ffffffffc0204374:	069a                	slli	a3,a3,0x6
ffffffffc0204376:	9536                	add	a0,a0,a3
ffffffffc0204378:	b7ffd0ef          	jal	ra,ffffffffc0201ef6 <free_pages>
    kfree(proc);
ffffffffc020437c:	8522                	mv	a0,s0
ffffffffc020437e:	a0dfd0ef          	jal	ra,ffffffffc0201d8a <kfree>
    return ret;
ffffffffc0204382:	bde1                	j	ffffffffc020425a <do_fork+0x1d6>
                    if (last_pid >= MAX_PID)
ffffffffc0204384:	01d6c363          	blt	a3,t4,ffffffffc020438a <do_fork+0x306>
                        last_pid = 1;
ffffffffc0204388:	4685                	li	a3,1
                    goto repeat;
ffffffffc020438a:	4585                	li	a1,1
ffffffffc020438c:	bf19                	j	ffffffffc02042a2 <do_fork+0x21e>
    return -E_NO_MEM;
ffffffffc020438e:	5c71                	li	s8,-4
ffffffffc0204390:	b7f5                	j	ffffffffc020437c <do_fork+0x2f8>
    int ret = -E_NO_FREE_PROC;
ffffffffc0204392:	5c6d                	li	s8,-5
ffffffffc0204394:	b5d9                	j	ffffffffc020425a <do_fork+0x1d6>
ffffffffc0204396:	c599                	beqz	a1,ffffffffc02043a4 <do_fork+0x320>
ffffffffc0204398:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc020439c:	8536                	mv	a0,a3
ffffffffc020439e:	bdb1                	j	ffffffffc02041fa <do_fork+0x176>
    ret = -E_NO_MEM;
ffffffffc02043a0:	5c71                	li	s8,-4
ffffffffc02043a2:	bd65                	j	ffffffffc020425a <do_fork+0x1d6>
    return last_pid;
ffffffffc02043a4:	00082503          	lw	a0,0(a6)
ffffffffc02043a8:	bd89                	j	ffffffffc02041fa <do_fork+0x176>
    int ret = -E_NO_MEM;
ffffffffc02043aa:	5c71                	li	s8,-4
ffffffffc02043ac:	b74d                	j	ffffffffc020434e <do_fork+0x2ca>
    assert(current->wait_state == 0);
ffffffffc02043ae:	00003697          	auipc	a3,0x3
ffffffffc02043b2:	d6268693          	addi	a3,a3,-670 # ffffffffc0207110 <default_pmm_manager+0xb18>
ffffffffc02043b6:	00002617          	auipc	a2,0x2
ffffffffc02043ba:	e9260613          	addi	a2,a2,-366 # ffffffffc0206248 <commands+0x828>
ffffffffc02043be:	1e400593          	li	a1,484
ffffffffc02043c2:	00003517          	auipc	a0,0x3
ffffffffc02043c6:	ca650513          	addi	a0,a0,-858 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc02043ca:	8c4fc0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc02043ce:	00002617          	auipc	a2,0x2
ffffffffc02043d2:	26260613          	addi	a2,a2,610 # ffffffffc0206630 <default_pmm_manager+0x38>
ffffffffc02043d6:	07100593          	li	a1,113
ffffffffc02043da:	00002517          	auipc	a0,0x2
ffffffffc02043de:	27e50513          	addi	a0,a0,638 # ffffffffc0206658 <default_pmm_manager+0x60>
ffffffffc02043e2:	8acfc0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02043e6:	00002617          	auipc	a2,0x2
ffffffffc02043ea:	31a60613          	addi	a2,a2,794 # ffffffffc0206700 <default_pmm_manager+0x108>
ffffffffc02043ee:	06900593          	li	a1,105
ffffffffc02043f2:	00002517          	auipc	a0,0x2
ffffffffc02043f6:	26650513          	addi	a0,a0,614 # ffffffffc0206658 <default_pmm_manager+0x60>
ffffffffc02043fa:	894fc0ef          	jal	ra,ffffffffc020048e <__panic>
    return pa2page(PADDR(kva));
ffffffffc02043fe:	00002617          	auipc	a2,0x2
ffffffffc0204402:	2da60613          	addi	a2,a2,730 # ffffffffc02066d8 <default_pmm_manager+0xe0>
ffffffffc0204406:	07700593          	li	a1,119
ffffffffc020440a:	00002517          	auipc	a0,0x2
ffffffffc020440e:	24e50513          	addi	a0,a0,590 # ffffffffc0206658 <default_pmm_manager+0x60>
ffffffffc0204412:	87cfc0ef          	jal	ra,ffffffffc020048e <__panic>
    {
        panic("Unlock failed.\n");
ffffffffc0204416:	00003617          	auipc	a2,0x3
ffffffffc020441a:	d1a60613          	addi	a2,a2,-742 # ffffffffc0207130 <default_pmm_manager+0xb38>
ffffffffc020441e:	03f00593          	li	a1,63
ffffffffc0204422:	00003517          	auipc	a0,0x3
ffffffffc0204426:	d1e50513          	addi	a0,a0,-738 # ffffffffc0207140 <default_pmm_manager+0xb48>
ffffffffc020442a:	864fc0ef          	jal	ra,ffffffffc020048e <__panic>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc020442e:	00002617          	auipc	a2,0x2
ffffffffc0204432:	2aa60613          	addi	a2,a2,682 # ffffffffc02066d8 <default_pmm_manager+0xe0>
ffffffffc0204436:	19000593          	li	a1,400
ffffffffc020443a:	00003517          	auipc	a0,0x3
ffffffffc020443e:	c2e50513          	addi	a0,a0,-978 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc0204442:	84cfc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204446 <kernel_thread>:
{
ffffffffc0204446:	7129                	addi	sp,sp,-320
ffffffffc0204448:	fa22                	sd	s0,304(sp)
ffffffffc020444a:	f626                	sd	s1,296(sp)
ffffffffc020444c:	f24a                	sd	s2,288(sp)
ffffffffc020444e:	84ae                	mv	s1,a1
ffffffffc0204450:	892a                	mv	s2,a0
ffffffffc0204452:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204454:	4581                	li	a1,0
ffffffffc0204456:	12000613          	li	a2,288
ffffffffc020445a:	850a                	mv	a0,sp
{
ffffffffc020445c:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020445e:	330010ef          	jal	ra,ffffffffc020578e <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0204462:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0204464:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204466:	100027f3          	csrr	a5,sstatus
ffffffffc020446a:	edd7f793          	andi	a5,a5,-291
ffffffffc020446e:	1207e793          	ori	a5,a5,288
ffffffffc0204472:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204474:	860a                	mv	a2,sp
ffffffffc0204476:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020447a:	00000797          	auipc	a5,0x0
ffffffffc020447e:	96c78793          	addi	a5,a5,-1684 # ffffffffc0203de6 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204482:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204484:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204486:	bffff0ef          	jal	ra,ffffffffc0204084 <do_fork>
}
ffffffffc020448a:	70f2                	ld	ra,312(sp)
ffffffffc020448c:	7452                	ld	s0,304(sp)
ffffffffc020448e:	74b2                	ld	s1,296(sp)
ffffffffc0204490:	7912                	ld	s2,288(sp)
ffffffffc0204492:	6131                	addi	sp,sp,320
ffffffffc0204494:	8082                	ret

ffffffffc0204496 <do_exit>:
{
ffffffffc0204496:	7179                	addi	sp,sp,-48
ffffffffc0204498:	f022                	sd	s0,32(sp)
    if (current == idleproc)
ffffffffc020449a:	000a6417          	auipc	s0,0xa6
ffffffffc020449e:	24640413          	addi	s0,s0,582 # ffffffffc02aa6e0 <current>
ffffffffc02044a2:	601c                	ld	a5,0(s0)
{
ffffffffc02044a4:	f406                	sd	ra,40(sp)
ffffffffc02044a6:	ec26                	sd	s1,24(sp)
ffffffffc02044a8:	e84a                	sd	s2,16(sp)
ffffffffc02044aa:	e44e                	sd	s3,8(sp)
ffffffffc02044ac:	e052                	sd	s4,0(sp)
    if (current == idleproc)
ffffffffc02044ae:	000a6717          	auipc	a4,0xa6
ffffffffc02044b2:	23a73703          	ld	a4,570(a4) # ffffffffc02aa6e8 <idleproc>
ffffffffc02044b6:	0ce78c63          	beq	a5,a4,ffffffffc020458e <do_exit+0xf8>
    if (current == initproc)
ffffffffc02044ba:	000a6497          	auipc	s1,0xa6
ffffffffc02044be:	23648493          	addi	s1,s1,566 # ffffffffc02aa6f0 <initproc>
ffffffffc02044c2:	6098                	ld	a4,0(s1)
ffffffffc02044c4:	0ee78b63          	beq	a5,a4,ffffffffc02045ba <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc02044c8:	0287b983          	ld	s3,40(a5)
ffffffffc02044cc:	892a                	mv	s2,a0
    if (mm != NULL)
ffffffffc02044ce:	02098663          	beqz	s3,ffffffffc02044fa <do_exit+0x64>
ffffffffc02044d2:	000a6797          	auipc	a5,0xa6
ffffffffc02044d6:	1de7b783          	ld	a5,478(a5) # ffffffffc02aa6b0 <boot_pgdir_pa>
ffffffffc02044da:	577d                	li	a4,-1
ffffffffc02044dc:	177e                	slli	a4,a4,0x3f
ffffffffc02044de:	83b1                	srli	a5,a5,0xc
ffffffffc02044e0:	8fd9                	or	a5,a5,a4
ffffffffc02044e2:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02044e6:	0309a783          	lw	a5,48(s3)
ffffffffc02044ea:	fff7871b          	addiw	a4,a5,-1
ffffffffc02044ee:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0)
ffffffffc02044f2:	cb55                	beqz	a4,ffffffffc02045a6 <do_exit+0x110>
        current->mm = NULL;
ffffffffc02044f4:	601c                	ld	a5,0(s0)
ffffffffc02044f6:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02044fa:	601c                	ld	a5,0(s0)
ffffffffc02044fc:	470d                	li	a4,3
ffffffffc02044fe:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0204500:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204504:	100027f3          	csrr	a5,sstatus
ffffffffc0204508:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020450a:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020450c:	e3f9                	bnez	a5,ffffffffc02045d2 <do_exit+0x13c>
        proc = current->parent;
ffffffffc020450e:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204510:	800007b7          	lui	a5,0x80000
ffffffffc0204514:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc0204516:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204518:	0ec52703          	lw	a4,236(a0)
ffffffffc020451c:	0af70f63          	beq	a4,a5,ffffffffc02045da <do_exit+0x144>
        while (current->cptr != NULL)
ffffffffc0204520:	6018                	ld	a4,0(s0)
ffffffffc0204522:	7b7c                	ld	a5,240(a4)
ffffffffc0204524:	c3a1                	beqz	a5,ffffffffc0204564 <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204526:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE)
ffffffffc020452a:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD)
ffffffffc020452c:	0985                	addi	s3,s3,1
ffffffffc020452e:	a021                	j	ffffffffc0204536 <do_exit+0xa0>
        while (current->cptr != NULL)
ffffffffc0204530:	6018                	ld	a4,0(s0)
ffffffffc0204532:	7b7c                	ld	a5,240(a4)
ffffffffc0204534:	cb85                	beqz	a5,ffffffffc0204564 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc0204536:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fe8>
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc020453a:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc020453c:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc020453e:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0204540:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204544:	10e7b023          	sd	a4,256(a5)
ffffffffc0204548:	c311                	beqz	a4,ffffffffc020454c <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc020454a:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc020454c:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc020454e:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0204550:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204552:	fd271fe3          	bne	a4,s2,ffffffffc0204530 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204556:	0ec52783          	lw	a5,236(a0)
ffffffffc020455a:	fd379be3          	bne	a5,s3,ffffffffc0204530 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc020455e:	39f000ef          	jal	ra,ffffffffc02050fc <wakeup_proc>
ffffffffc0204562:	b7f9                	j	ffffffffc0204530 <do_exit+0x9a>
    if (flag)
ffffffffc0204564:	020a1263          	bnez	s4,ffffffffc0204588 <do_exit+0xf2>
    schedule();
ffffffffc0204568:	415000ef          	jal	ra,ffffffffc020517c <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc020456c:	601c                	ld	a5,0(s0)
ffffffffc020456e:	00003617          	auipc	a2,0x3
ffffffffc0204572:	c6a60613          	addi	a2,a2,-918 # ffffffffc02071d8 <default_pmm_manager+0xbe0>
ffffffffc0204576:	24000593          	li	a1,576
ffffffffc020457a:	43d4                	lw	a3,4(a5)
ffffffffc020457c:	00003517          	auipc	a0,0x3
ffffffffc0204580:	aec50513          	addi	a0,a0,-1300 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc0204584:	f0bfb0ef          	jal	ra,ffffffffc020048e <__panic>
        intr_enable();
ffffffffc0204588:	c26fc0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020458c:	bff1                	j	ffffffffc0204568 <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc020458e:	00003617          	auipc	a2,0x3
ffffffffc0204592:	c2a60613          	addi	a2,a2,-982 # ffffffffc02071b8 <default_pmm_manager+0xbc0>
ffffffffc0204596:	20c00593          	li	a1,524
ffffffffc020459a:	00003517          	auipc	a0,0x3
ffffffffc020459e:	ace50513          	addi	a0,a0,-1330 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc02045a2:	eedfb0ef          	jal	ra,ffffffffc020048e <__panic>
            exit_mmap(mm);
ffffffffc02045a6:	854e                	mv	a0,s3
ffffffffc02045a8:	c10ff0ef          	jal	ra,ffffffffc02039b8 <exit_mmap>
            put_pgdir(mm);
ffffffffc02045ac:	854e                	mv	a0,s3
ffffffffc02045ae:	93fff0ef          	jal	ra,ffffffffc0203eec <put_pgdir>
            mm_destroy(mm);
ffffffffc02045b2:	854e                	mv	a0,s3
ffffffffc02045b4:	a68ff0ef          	jal	ra,ffffffffc020381c <mm_destroy>
ffffffffc02045b8:	bf35                	j	ffffffffc02044f4 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc02045ba:	00003617          	auipc	a2,0x3
ffffffffc02045be:	c0e60613          	addi	a2,a2,-1010 # ffffffffc02071c8 <default_pmm_manager+0xbd0>
ffffffffc02045c2:	21000593          	li	a1,528
ffffffffc02045c6:	00003517          	auipc	a0,0x3
ffffffffc02045ca:	aa250513          	addi	a0,a0,-1374 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc02045ce:	ec1fb0ef          	jal	ra,ffffffffc020048e <__panic>
        intr_disable();
ffffffffc02045d2:	be2fc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc02045d6:	4a05                	li	s4,1
ffffffffc02045d8:	bf1d                	j	ffffffffc020450e <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc02045da:	323000ef          	jal	ra,ffffffffc02050fc <wakeup_proc>
ffffffffc02045de:	b789                	j	ffffffffc0204520 <do_exit+0x8a>

ffffffffc02045e0 <do_wait.part.0>:
int do_wait(int pid, int *code_store)
ffffffffc02045e0:	715d                	addi	sp,sp,-80
ffffffffc02045e2:	f84a                	sd	s2,48(sp)
ffffffffc02045e4:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc02045e6:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID)
ffffffffc02045ea:	6989                	lui	s3,0x2
int do_wait(int pid, int *code_store)
ffffffffc02045ec:	fc26                	sd	s1,56(sp)
ffffffffc02045ee:	f052                	sd	s4,32(sp)
ffffffffc02045f0:	ec56                	sd	s5,24(sp)
ffffffffc02045f2:	e85a                	sd	s6,16(sp)
ffffffffc02045f4:	e45e                	sd	s7,8(sp)
ffffffffc02045f6:	e486                	sd	ra,72(sp)
ffffffffc02045f8:	e0a2                	sd	s0,64(sp)
ffffffffc02045fa:	84aa                	mv	s1,a0
ffffffffc02045fc:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc02045fe:	000a6b97          	auipc	s7,0xa6
ffffffffc0204602:	0e2b8b93          	addi	s7,s7,226 # ffffffffc02aa6e0 <current>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204606:	00050b1b          	sext.w	s6,a0
ffffffffc020460a:	fff50a9b          	addiw	s5,a0,-1
ffffffffc020460e:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc0204610:	0905                	addi	s2,s2,1
    if (pid != 0)
ffffffffc0204612:	ccbd                	beqz	s1,ffffffffc0204690 <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204614:	0359e863          	bltu	s3,s5,ffffffffc0204644 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204618:	45a9                	li	a1,10
ffffffffc020461a:	855a                	mv	a0,s6
ffffffffc020461c:	4cd000ef          	jal	ra,ffffffffc02052e8 <hash32>
ffffffffc0204620:	02051793          	slli	a5,a0,0x20
ffffffffc0204624:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204628:	000a2797          	auipc	a5,0xa2
ffffffffc020462c:	04078793          	addi	a5,a5,64 # ffffffffc02a6668 <hash_list>
ffffffffc0204630:	953e                	add	a0,a0,a5
ffffffffc0204632:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list)
ffffffffc0204634:	a029                	j	ffffffffc020463e <do_wait.part.0+0x5e>
            if (proc->pid == pid)
ffffffffc0204636:	f2c42783          	lw	a5,-212(s0)
ffffffffc020463a:	02978163          	beq	a5,s1,ffffffffc020465c <do_wait.part.0+0x7c>
ffffffffc020463e:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list)
ffffffffc0204640:	fe851be3          	bne	a0,s0,ffffffffc0204636 <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc0204644:	5579                	li	a0,-2
}
ffffffffc0204646:	60a6                	ld	ra,72(sp)
ffffffffc0204648:	6406                	ld	s0,64(sp)
ffffffffc020464a:	74e2                	ld	s1,56(sp)
ffffffffc020464c:	7942                	ld	s2,48(sp)
ffffffffc020464e:	79a2                	ld	s3,40(sp)
ffffffffc0204650:	7a02                	ld	s4,32(sp)
ffffffffc0204652:	6ae2                	ld	s5,24(sp)
ffffffffc0204654:	6b42                	ld	s6,16(sp)
ffffffffc0204656:	6ba2                	ld	s7,8(sp)
ffffffffc0204658:	6161                	addi	sp,sp,80
ffffffffc020465a:	8082                	ret
        if (proc != NULL && proc->parent == current)
ffffffffc020465c:	000bb683          	ld	a3,0(s7)
ffffffffc0204660:	f4843783          	ld	a5,-184(s0)
ffffffffc0204664:	fed790e3          	bne	a5,a3,ffffffffc0204644 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204668:	f2842703          	lw	a4,-216(s0)
ffffffffc020466c:	478d                	li	a5,3
ffffffffc020466e:	0ef70b63          	beq	a4,a5,ffffffffc0204764 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc0204672:	4785                	li	a5,1
ffffffffc0204674:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc0204676:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc020467a:	303000ef          	jal	ra,ffffffffc020517c <schedule>
        if (current->flags & PF_EXITING)
ffffffffc020467e:	000bb783          	ld	a5,0(s7)
ffffffffc0204682:	0b07a783          	lw	a5,176(a5)
ffffffffc0204686:	8b85                	andi	a5,a5,1
ffffffffc0204688:	d7c9                	beqz	a5,ffffffffc0204612 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc020468a:	555d                	li	a0,-9
ffffffffc020468c:	e0bff0ef          	jal	ra,ffffffffc0204496 <do_exit>
        proc = current->cptr;
ffffffffc0204690:	000bb683          	ld	a3,0(s7)
ffffffffc0204694:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr)
ffffffffc0204696:	d45d                	beqz	s0,ffffffffc0204644 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204698:	470d                	li	a4,3
ffffffffc020469a:	a021                	j	ffffffffc02046a2 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr)
ffffffffc020469c:	10043403          	ld	s0,256(s0)
ffffffffc02046a0:	d869                	beqz	s0,ffffffffc0204672 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02046a2:	401c                	lw	a5,0(s0)
ffffffffc02046a4:	fee79ce3          	bne	a5,a4,ffffffffc020469c <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc)
ffffffffc02046a8:	000a6797          	auipc	a5,0xa6
ffffffffc02046ac:	0407b783          	ld	a5,64(a5) # ffffffffc02aa6e8 <idleproc>
ffffffffc02046b0:	0c878963          	beq	a5,s0,ffffffffc0204782 <do_wait.part.0+0x1a2>
ffffffffc02046b4:	000a6797          	auipc	a5,0xa6
ffffffffc02046b8:	03c7b783          	ld	a5,60(a5) # ffffffffc02aa6f0 <initproc>
ffffffffc02046bc:	0cf40363          	beq	s0,a5,ffffffffc0204782 <do_wait.part.0+0x1a2>
    if (code_store != NULL)
ffffffffc02046c0:	000a0663          	beqz	s4,ffffffffc02046cc <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc02046c4:	0e842783          	lw	a5,232(s0)
ffffffffc02046c8:	00fa2023          	sw	a5,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8ba8>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02046cc:	100027f3          	csrr	a5,sstatus
ffffffffc02046d0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02046d2:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02046d4:	e7c1                	bnez	a5,ffffffffc020475c <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02046d6:	6c70                	ld	a2,216(s0)
ffffffffc02046d8:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL)
ffffffffc02046da:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc02046de:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02046e0:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02046e2:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02046e4:	6470                	ld	a2,200(s0)
ffffffffc02046e6:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc02046e8:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02046ea:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL)
ffffffffc02046ec:	c319                	beqz	a4,ffffffffc02046f2 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc02046ee:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL)
ffffffffc02046f0:	7c7c                	ld	a5,248(s0)
ffffffffc02046f2:	c3b5                	beqz	a5,ffffffffc0204756 <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc02046f4:	10e7b023          	sd	a4,256(a5)
    nr_process--;
ffffffffc02046f8:	000a6717          	auipc	a4,0xa6
ffffffffc02046fc:	00070713          	mv	a4,a4
ffffffffc0204700:	431c                	lw	a5,0(a4)
ffffffffc0204702:	37fd                	addiw	a5,a5,-1
ffffffffc0204704:	c31c                	sw	a5,0(a4)
    if (flag)
ffffffffc0204706:	e5a9                	bnez	a1,ffffffffc0204750 <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204708:	6814                	ld	a3,16(s0)
ffffffffc020470a:	c02007b7          	lui	a5,0xc0200
ffffffffc020470e:	04f6ee63          	bltu	a3,a5,ffffffffc020476a <do_wait.part.0+0x18a>
ffffffffc0204712:	000a6797          	auipc	a5,0xa6
ffffffffc0204716:	fc67b783          	ld	a5,-58(a5) # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc020471a:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage)
ffffffffc020471c:	82b1                	srli	a3,a3,0xc
ffffffffc020471e:	000a6797          	auipc	a5,0xa6
ffffffffc0204722:	fa27b783          	ld	a5,-94(a5) # ffffffffc02aa6c0 <npage>
ffffffffc0204726:	06f6fa63          	bgeu	a3,a5,ffffffffc020479a <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc020472a:	00003517          	auipc	a0,0x3
ffffffffc020472e:	35653503          	ld	a0,854(a0) # ffffffffc0207a80 <nbase>
ffffffffc0204732:	8e89                	sub	a3,a3,a0
ffffffffc0204734:	069a                	slli	a3,a3,0x6
ffffffffc0204736:	000a6517          	auipc	a0,0xa6
ffffffffc020473a:	f9253503          	ld	a0,-110(a0) # ffffffffc02aa6c8 <pages>
ffffffffc020473e:	9536                	add	a0,a0,a3
ffffffffc0204740:	4589                	li	a1,2
ffffffffc0204742:	fb4fd0ef          	jal	ra,ffffffffc0201ef6 <free_pages>
    kfree(proc);
ffffffffc0204746:	8522                	mv	a0,s0
ffffffffc0204748:	e42fd0ef          	jal	ra,ffffffffc0201d8a <kfree>
    return 0;
ffffffffc020474c:	4501                	li	a0,0
ffffffffc020474e:	bde5                	j	ffffffffc0204646 <do_wait.part.0+0x66>
        intr_enable();
ffffffffc0204750:	a5efc0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0204754:	bf55                	j	ffffffffc0204708 <do_wait.part.0+0x128>
        proc->parent->cptr = proc->optr;
ffffffffc0204756:	701c                	ld	a5,32(s0)
ffffffffc0204758:	fbf8                	sd	a4,240(a5)
ffffffffc020475a:	bf79                	j	ffffffffc02046f8 <do_wait.part.0+0x118>
        intr_disable();
ffffffffc020475c:	a58fc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc0204760:	4585                	li	a1,1
ffffffffc0204762:	bf95                	j	ffffffffc02046d6 <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204764:	f2840413          	addi	s0,s0,-216
ffffffffc0204768:	b781                	j	ffffffffc02046a8 <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc020476a:	00002617          	auipc	a2,0x2
ffffffffc020476e:	f6e60613          	addi	a2,a2,-146 # ffffffffc02066d8 <default_pmm_manager+0xe0>
ffffffffc0204772:	07700593          	li	a1,119
ffffffffc0204776:	00002517          	auipc	a0,0x2
ffffffffc020477a:	ee250513          	addi	a0,a0,-286 # ffffffffc0206658 <default_pmm_manager+0x60>
ffffffffc020477e:	d11fb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc0204782:	00003617          	auipc	a2,0x3
ffffffffc0204786:	a7660613          	addi	a2,a2,-1418 # ffffffffc02071f8 <default_pmm_manager+0xc00>
ffffffffc020478a:	36300593          	li	a1,867
ffffffffc020478e:	00003517          	auipc	a0,0x3
ffffffffc0204792:	8da50513          	addi	a0,a0,-1830 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc0204796:	cf9fb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020479a:	00002617          	auipc	a2,0x2
ffffffffc020479e:	f6660613          	addi	a2,a2,-154 # ffffffffc0206700 <default_pmm_manager+0x108>
ffffffffc02047a2:	06900593          	li	a1,105
ffffffffc02047a6:	00002517          	auipc	a0,0x2
ffffffffc02047aa:	eb250513          	addi	a0,a0,-334 # ffffffffc0206658 <default_pmm_manager+0x60>
ffffffffc02047ae:	ce1fb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02047b2 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc02047b2:	1141                	addi	sp,sp,-16
ffffffffc02047b4:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02047b6:	f80fd0ef          	jal	ra,ffffffffc0201f36 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02047ba:	d1cfd0ef          	jal	ra,ffffffffc0201cd6 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02047be:	4601                	li	a2,0
ffffffffc02047c0:	4581                	li	a1,0
ffffffffc02047c2:	fffff517          	auipc	a0,0xfffff
ffffffffc02047c6:	6ac50513          	addi	a0,a0,1708 # ffffffffc0203e6e <user_main>
ffffffffc02047ca:	c7dff0ef          	jal	ra,ffffffffc0204446 <kernel_thread>
    if (pid <= 0)
ffffffffc02047ce:	00a04563          	bgtz	a0,ffffffffc02047d8 <init_main+0x26>
ffffffffc02047d2:	a071                	j	ffffffffc020485e <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
ffffffffc02047d4:	1a9000ef          	jal	ra,ffffffffc020517c <schedule>
    if (code_store != NULL)
ffffffffc02047d8:	4581                	li	a1,0
ffffffffc02047da:	4501                	li	a0,0
ffffffffc02047dc:	e05ff0ef          	jal	ra,ffffffffc02045e0 <do_wait.part.0>
    while (do_wait(0, NULL) == 0)
ffffffffc02047e0:	d975                	beqz	a0,ffffffffc02047d4 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc02047e2:	00003517          	auipc	a0,0x3
ffffffffc02047e6:	a5650513          	addi	a0,a0,-1450 # ffffffffc0207238 <default_pmm_manager+0xc40>
ffffffffc02047ea:	9abfb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02047ee:	000a6797          	auipc	a5,0xa6
ffffffffc02047f2:	f027b783          	ld	a5,-254(a5) # ffffffffc02aa6f0 <initproc>
ffffffffc02047f6:	7bf8                	ld	a4,240(a5)
ffffffffc02047f8:	e339                	bnez	a4,ffffffffc020483e <init_main+0x8c>
ffffffffc02047fa:	7ff8                	ld	a4,248(a5)
ffffffffc02047fc:	e329                	bnez	a4,ffffffffc020483e <init_main+0x8c>
ffffffffc02047fe:	1007b703          	ld	a4,256(a5)
ffffffffc0204802:	ef15                	bnez	a4,ffffffffc020483e <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc0204804:	000a6697          	auipc	a3,0xa6
ffffffffc0204808:	ef46a683          	lw	a3,-268(a3) # ffffffffc02aa6f8 <nr_process>
ffffffffc020480c:	4709                	li	a4,2
ffffffffc020480e:	0ae69463          	bne	a3,a4,ffffffffc02048b6 <init_main+0x104>
    return listelm->next;
ffffffffc0204812:	000a6697          	auipc	a3,0xa6
ffffffffc0204816:	e5668693          	addi	a3,a3,-426 # ffffffffc02aa668 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020481a:	6698                	ld	a4,8(a3)
ffffffffc020481c:	0c878793          	addi	a5,a5,200
ffffffffc0204820:	06f71b63          	bne	a4,a5,ffffffffc0204896 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204824:	629c                	ld	a5,0(a3)
ffffffffc0204826:	04f71863          	bne	a4,a5,ffffffffc0204876 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc020482a:	00003517          	auipc	a0,0x3
ffffffffc020482e:	af650513          	addi	a0,a0,-1290 # ffffffffc0207320 <default_pmm_manager+0xd28>
ffffffffc0204832:	963fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    return 0;
}
ffffffffc0204836:	60a2                	ld	ra,8(sp)
ffffffffc0204838:	4501                	li	a0,0
ffffffffc020483a:	0141                	addi	sp,sp,16
ffffffffc020483c:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020483e:	00003697          	auipc	a3,0x3
ffffffffc0204842:	a2268693          	addi	a3,a3,-1502 # ffffffffc0207260 <default_pmm_manager+0xc68>
ffffffffc0204846:	00002617          	auipc	a2,0x2
ffffffffc020484a:	a0260613          	addi	a2,a2,-1534 # ffffffffc0206248 <commands+0x828>
ffffffffc020484e:	3d100593          	li	a1,977
ffffffffc0204852:	00003517          	auipc	a0,0x3
ffffffffc0204856:	81650513          	addi	a0,a0,-2026 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc020485a:	c35fb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("create user_main failed.\n");
ffffffffc020485e:	00003617          	auipc	a2,0x3
ffffffffc0204862:	9ba60613          	addi	a2,a2,-1606 # ffffffffc0207218 <default_pmm_manager+0xc20>
ffffffffc0204866:	3c800593          	li	a1,968
ffffffffc020486a:	00002517          	auipc	a0,0x2
ffffffffc020486e:	7fe50513          	addi	a0,a0,2046 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc0204872:	c1dfb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204876:	00003697          	auipc	a3,0x3
ffffffffc020487a:	a7a68693          	addi	a3,a3,-1414 # ffffffffc02072f0 <default_pmm_manager+0xcf8>
ffffffffc020487e:	00002617          	auipc	a2,0x2
ffffffffc0204882:	9ca60613          	addi	a2,a2,-1590 # ffffffffc0206248 <commands+0x828>
ffffffffc0204886:	3d400593          	li	a1,980
ffffffffc020488a:	00002517          	auipc	a0,0x2
ffffffffc020488e:	7de50513          	addi	a0,a0,2014 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc0204892:	bfdfb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204896:	00003697          	auipc	a3,0x3
ffffffffc020489a:	a2a68693          	addi	a3,a3,-1494 # ffffffffc02072c0 <default_pmm_manager+0xcc8>
ffffffffc020489e:	00002617          	auipc	a2,0x2
ffffffffc02048a2:	9aa60613          	addi	a2,a2,-1622 # ffffffffc0206248 <commands+0x828>
ffffffffc02048a6:	3d300593          	li	a1,979
ffffffffc02048aa:	00002517          	auipc	a0,0x2
ffffffffc02048ae:	7be50513          	addi	a0,a0,1982 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc02048b2:	bddfb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_process == 2);
ffffffffc02048b6:	00003697          	auipc	a3,0x3
ffffffffc02048ba:	9fa68693          	addi	a3,a3,-1542 # ffffffffc02072b0 <default_pmm_manager+0xcb8>
ffffffffc02048be:	00002617          	auipc	a2,0x2
ffffffffc02048c2:	98a60613          	addi	a2,a2,-1654 # ffffffffc0206248 <commands+0x828>
ffffffffc02048c6:	3d200593          	li	a1,978
ffffffffc02048ca:	00002517          	auipc	a0,0x2
ffffffffc02048ce:	79e50513          	addi	a0,a0,1950 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc02048d2:	bbdfb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02048d6 <do_execve>:
{
ffffffffc02048d6:	7135                	addi	sp,sp,-160
ffffffffc02048d8:	f0da                	sd	s6,96(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02048da:	000a6b17          	auipc	s6,0xa6
ffffffffc02048de:	e06b0b13          	addi	s6,s6,-506 # ffffffffc02aa6e0 <current>
ffffffffc02048e2:	000b3783          	ld	a5,0(s6)
{
ffffffffc02048e6:	fcce                	sd	s3,120(sp)
ffffffffc02048e8:	e526                	sd	s1,136(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02048ea:	0287b983          	ld	s3,40(a5)
{
ffffffffc02048ee:	e14a                	sd	s2,128(sp)
ffffffffc02048f0:	f4d6                	sd	s5,104(sp)
ffffffffc02048f2:	892a                	mv	s2,a0
ffffffffc02048f4:	8ab2                	mv	s5,a2
ffffffffc02048f6:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc02048f8:	862e                	mv	a2,a1
ffffffffc02048fa:	4681                	li	a3,0
ffffffffc02048fc:	85aa                	mv	a1,a0
ffffffffc02048fe:	854e                	mv	a0,s3
{
ffffffffc0204900:	ed06                	sd	ra,152(sp)
ffffffffc0204902:	e922                	sd	s0,144(sp)
ffffffffc0204904:	f8d2                	sd	s4,112(sp)
ffffffffc0204906:	ecde                	sd	s7,88(sp)
ffffffffc0204908:	e8e2                	sd	s8,80(sp)
ffffffffc020490a:	e4e6                	sd	s9,72(sp)
ffffffffc020490c:	e0ea                	sd	s10,64(sp)
ffffffffc020490e:	fc6e                	sd	s11,56(sp)
ffffffffc0204910:	e856                	sd	s5,16(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204912:	c40ff0ef          	jal	ra,ffffffffc0203d52 <user_mem_check>
ffffffffc0204916:	42050663          	beqz	a0,ffffffffc0204d42 <do_execve+0x46c>
    memset(local_name, 0, sizeof(local_name));
ffffffffc020491a:	4641                	li	a2,16
ffffffffc020491c:	4581                	li	a1,0
ffffffffc020491e:	1008                	addi	a0,sp,32
ffffffffc0204920:	66f000ef          	jal	ra,ffffffffc020578e <memset>
    memcpy(local_name, name, len);
ffffffffc0204924:	47bd                	li	a5,15
ffffffffc0204926:	8626                	mv	a2,s1
ffffffffc0204928:	0697ed63          	bltu	a5,s1,ffffffffc02049a2 <do_execve+0xcc>
ffffffffc020492c:	85ca                	mv	a1,s2
ffffffffc020492e:	1008                	addi	a0,sp,32
ffffffffc0204930:	671000ef          	jal	ra,ffffffffc02057a0 <memcpy>
    if (mm != NULL)
ffffffffc0204934:	06098e63          	beqz	s3,ffffffffc02049b0 <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc0204938:	00002517          	auipc	a0,0x2
ffffffffc020493c:	4f050513          	addi	a0,a0,1264 # ffffffffc0206e28 <default_pmm_manager+0x830>
ffffffffc0204940:	88dfb0ef          	jal	ra,ffffffffc02001cc <cputs>
ffffffffc0204944:	000a6797          	auipc	a5,0xa6
ffffffffc0204948:	d6c7b783          	ld	a5,-660(a5) # ffffffffc02aa6b0 <boot_pgdir_pa>
ffffffffc020494c:	577d                	li	a4,-1
ffffffffc020494e:	177e                	slli	a4,a4,0x3f
ffffffffc0204950:	83b1                	srli	a5,a5,0xc
ffffffffc0204952:	8fd9                	or	a5,a5,a4
ffffffffc0204954:	18079073          	csrw	satp,a5
ffffffffc0204958:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7b78>
ffffffffc020495c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204960:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0)
ffffffffc0204964:	2c070663          	beqz	a4,ffffffffc0204c30 <do_execve+0x35a>
        current->mm = NULL;
ffffffffc0204968:	000b3783          	ld	a5,0(s6)
ffffffffc020496c:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc0204970:	d6dfe0ef          	jal	ra,ffffffffc02036dc <mm_create>
ffffffffc0204974:	84aa                	mv	s1,a0
ffffffffc0204976:	c135                	beqz	a0,ffffffffc02049da <do_execve+0x104>
    if (setup_pgdir(mm) != 0)
ffffffffc0204978:	deaff0ef          	jal	ra,ffffffffc0203f62 <setup_pgdir>
ffffffffc020497c:	e931                	bnez	a0,ffffffffc02049d0 <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc020497e:	67c2                	ld	a5,16(sp)
ffffffffc0204980:	4398                	lw	a4,0(a5)
ffffffffc0204982:	464c47b7          	lui	a5,0x464c4
ffffffffc0204986:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9467>
ffffffffc020498a:	04f70a63          	beq	a4,a5,ffffffffc02049de <do_execve+0x108>
    put_pgdir(mm);
ffffffffc020498e:	8526                	mv	a0,s1
ffffffffc0204990:	d5cff0ef          	jal	ra,ffffffffc0203eec <put_pgdir>
    mm_destroy(mm);
ffffffffc0204994:	8526                	mv	a0,s1
ffffffffc0204996:	e87fe0ef          	jal	ra,ffffffffc020381c <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc020499a:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc020499c:	8552                	mv	a0,s4
ffffffffc020499e:	af9ff0ef          	jal	ra,ffffffffc0204496 <do_exit>
    memcpy(local_name, name, len);
ffffffffc02049a2:	463d                	li	a2,15
ffffffffc02049a4:	85ca                	mv	a1,s2
ffffffffc02049a6:	1008                	addi	a0,sp,32
ffffffffc02049a8:	5f9000ef          	jal	ra,ffffffffc02057a0 <memcpy>
    if (mm != NULL)
ffffffffc02049ac:	f80996e3          	bnez	s3,ffffffffc0204938 <do_execve+0x62>
    if (current->mm != NULL)
ffffffffc02049b0:	000b3783          	ld	a5,0(s6)
ffffffffc02049b4:	779c                	ld	a5,40(a5)
ffffffffc02049b6:	dfcd                	beqz	a5,ffffffffc0204970 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc02049b8:	00003617          	auipc	a2,0x3
ffffffffc02049bc:	98860613          	addi	a2,a2,-1656 # ffffffffc0207340 <default_pmm_manager+0xd48>
ffffffffc02049c0:	24c00593          	li	a1,588
ffffffffc02049c4:	00002517          	auipc	a0,0x2
ffffffffc02049c8:	6a450513          	addi	a0,a0,1700 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc02049cc:	ac3fb0ef          	jal	ra,ffffffffc020048e <__panic>
    mm_destroy(mm);
ffffffffc02049d0:	8526                	mv	a0,s1
ffffffffc02049d2:	e4bfe0ef          	jal	ra,ffffffffc020381c <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc02049d6:	5a71                	li	s4,-4
ffffffffc02049d8:	b7d1                	j	ffffffffc020499c <do_execve+0xc6>
ffffffffc02049da:	5a71                	li	s4,-4
ffffffffc02049dc:	b7c1                	j	ffffffffc020499c <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02049de:	66c2                	ld	a3,16(sp)
ffffffffc02049e0:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02049e4:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02049e8:	00371793          	slli	a5,a4,0x3
ffffffffc02049ec:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02049ee:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02049f0:	078e                	slli	a5,a5,0x3
ffffffffc02049f2:	97ce                	add	a5,a5,s3
ffffffffc02049f4:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph++)
ffffffffc02049f6:	02f9fb63          	bgeu	s3,a5,ffffffffc0204a2c <do_execve+0x156>
    return KADDR(page2pa(page));
ffffffffc02049fa:	57fd                	li	a5,-1
ffffffffc02049fc:	83b1                	srli	a5,a5,0xc
    return page - pages + nbase;
ffffffffc02049fe:	000a6d17          	auipc	s10,0xa6
ffffffffc0204a02:	ccad0d13          	addi	s10,s10,-822 # ffffffffc02aa6c8 <pages>
ffffffffc0204a06:	00003c97          	auipc	s9,0x3
ffffffffc0204a0a:	07ac8c93          	addi	s9,s9,122 # ffffffffc0207a80 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204a0e:	e43e                	sd	a5,8(sp)
ffffffffc0204a10:	000a6c17          	auipc	s8,0xa6
ffffffffc0204a14:	cb0c0c13          	addi	s8,s8,-848 # ffffffffc02aa6c0 <npage>
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc0204a18:	0009a703          	lw	a4,0(s3)
ffffffffc0204a1c:	4785                	li	a5,1
ffffffffc0204a1e:	12f70863          	beq	a4,a5,ffffffffc0204b4e <do_execve+0x278>
    for (; ph < ph_end; ph++)
ffffffffc0204a22:	67e2                	ld	a5,24(sp)
ffffffffc0204a24:	03898993          	addi	s3,s3,56
ffffffffc0204a28:	fef9e8e3          	bltu	s3,a5,ffffffffc0204a18 <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc0204a2c:	4701                	li	a4,0
ffffffffc0204a2e:	46ad                	li	a3,11
ffffffffc0204a30:	00100637          	lui	a2,0x100
ffffffffc0204a34:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0204a38:	8526                	mv	a0,s1
ffffffffc0204a3a:	e35fe0ef          	jal	ra,ffffffffc020386e <mm_map>
ffffffffc0204a3e:	8a2a                	mv	s4,a0
ffffffffc0204a40:	1c051e63          	bnez	a0,ffffffffc0204c1c <do_execve+0x346>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204a44:	6c88                	ld	a0,24(s1)
ffffffffc0204a46:	467d                	li	a2,31
ffffffffc0204a48:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0204a4c:	babfe0ef          	jal	ra,ffffffffc02035f6 <pgdir_alloc_page>
ffffffffc0204a50:	3a050363          	beqz	a0,ffffffffc0204df6 <do_execve+0x520>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204a54:	6c88                	ld	a0,24(s1)
ffffffffc0204a56:	467d                	li	a2,31
ffffffffc0204a58:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0204a5c:	b9bfe0ef          	jal	ra,ffffffffc02035f6 <pgdir_alloc_page>
ffffffffc0204a60:	36050b63          	beqz	a0,ffffffffc0204dd6 <do_execve+0x500>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204a64:	6c88                	ld	a0,24(s1)
ffffffffc0204a66:	467d                	li	a2,31
ffffffffc0204a68:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0204a6c:	b8bfe0ef          	jal	ra,ffffffffc02035f6 <pgdir_alloc_page>
ffffffffc0204a70:	34050363          	beqz	a0,ffffffffc0204db6 <do_execve+0x4e0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204a74:	6c88                	ld	a0,24(s1)
ffffffffc0204a76:	467d                	li	a2,31
ffffffffc0204a78:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0204a7c:	b7bfe0ef          	jal	ra,ffffffffc02035f6 <pgdir_alloc_page>
ffffffffc0204a80:	30050b63          	beqz	a0,ffffffffc0204d96 <do_execve+0x4c0>
    mm->mm_count += 1;
ffffffffc0204a84:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0204a86:	000b3703          	ld	a4,0(s6)
    cprintf("[DEBUG] load_icode: mm->pgdir=%p (before PADDR)\n", mm->pgdir);
ffffffffc0204a8a:	6c8c                	ld	a1,24(s1)
ffffffffc0204a8c:	2785                	addiw	a5,a5,1
ffffffffc0204a8e:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0204a90:	f704                	sd	s1,40(a4)
    cprintf("[DEBUG] load_icode: mm->pgdir=%p (before PADDR)\n", mm->pgdir);
ffffffffc0204a92:	00003517          	auipc	a0,0x3
ffffffffc0204a96:	a3650513          	addi	a0,a0,-1482 # ffffffffc02074c8 <default_pmm_manager+0xed0>
ffffffffc0204a9a:	efafb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204a9e:	6c94                	ld	a3,24(s1)
ffffffffc0204aa0:	c0200937          	lui	s2,0xc0200
ffffffffc0204aa4:	2d26ed63          	bltu	a3,s2,ffffffffc0204d7e <do_execve+0x4a8>
ffffffffc0204aa8:	000a6417          	auipc	s0,0xa6
ffffffffc0204aac:	c3040413          	addi	s0,s0,-976 # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc0204ab0:	600c                	ld	a1,0(s0)
ffffffffc0204ab2:	000b3783          	ld	a5,0(s6)
    cprintf("[DEBUG] load_icode: current->pgdir=%p (after PADDR)\n", current->pgdir);
ffffffffc0204ab6:	00003517          	auipc	a0,0x3
ffffffffc0204aba:	a4a50513          	addi	a0,a0,-1462 # ffffffffc0207500 <default_pmm_manager+0xf08>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204abe:	40b685b3          	sub	a1,a3,a1
ffffffffc0204ac2:	f7cc                	sd	a1,168(a5)
    cprintf("[DEBUG] load_icode: current->pgdir=%p (after PADDR)\n", current->pgdir);
ffffffffc0204ac4:	ed0fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    lsatp(PADDR(mm->pgdir));
ffffffffc0204ac8:	6c94                	ld	a3,24(s1)
ffffffffc0204aca:	2926ee63          	bltu	a3,s2,ffffffffc0204d66 <do_execve+0x490>
ffffffffc0204ace:	601c                	ld	a5,0(s0)
ffffffffc0204ad0:	8e9d                	sub	a3,a3,a5
ffffffffc0204ad2:	57fd                	li	a5,-1
ffffffffc0204ad4:	17fe                	slli	a5,a5,0x3f
ffffffffc0204ad6:	82b1                	srli	a3,a3,0xc
ffffffffc0204ad8:	8edd                	or	a3,a3,a5
ffffffffc0204ada:	18069073          	csrw	satp,a3
    struct trapframe *tf = current->tf;
ffffffffc0204ade:	000b3783          	ld	a5,0(s6)
ffffffffc0204ae2:	0a07b903          	ld	s2,160(a5)
    uintptr_t sstatus = read_csr(sstatus);
ffffffffc0204ae6:	10002473          	csrr	s0,sstatus
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204aea:	12000613          	li	a2,288
ffffffffc0204aee:	4581                	li	a1,0
ffffffffc0204af0:	854a                	mv	a0,s2
ffffffffc0204af2:	49d000ef          	jal	ra,ffffffffc020578e <memset>
    tf->epc = elf->e_entry;
ffffffffc0204af6:	67c2                	ld	a5,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204af8:	000b3483          	ld	s1,0(s6)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204afc:	edf47413          	andi	s0,s0,-289
    tf->epc = elf->e_entry;
ffffffffc0204b00:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc0204b02:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204b04:	0b448493          	addi	s1,s1,180
    tf->gpr.sp = USTACKTOP;
ffffffffc0204b08:	07fe                	slli	a5,a5,0x1f
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204b0a:	02046413          	ori	s0,s0,32
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204b0e:	4641                	li	a2,16
ffffffffc0204b10:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP;
ffffffffc0204b12:	00f93823          	sd	a5,16(s2) # ffffffffc0200010 <kern_entry+0x10>
    tf->epc = elf->e_entry;
ffffffffc0204b16:	10e93423          	sd	a4,264(s2)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204b1a:	10893023          	sd	s0,256(s2)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204b1e:	8526                	mv	a0,s1
ffffffffc0204b20:	46f000ef          	jal	ra,ffffffffc020578e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204b24:	463d                	li	a2,15
ffffffffc0204b26:	100c                	addi	a1,sp,32
ffffffffc0204b28:	8526                	mv	a0,s1
ffffffffc0204b2a:	477000ef          	jal	ra,ffffffffc02057a0 <memcpy>
}
ffffffffc0204b2e:	60ea                	ld	ra,152(sp)
ffffffffc0204b30:	644a                	ld	s0,144(sp)
ffffffffc0204b32:	64aa                	ld	s1,136(sp)
ffffffffc0204b34:	690a                	ld	s2,128(sp)
ffffffffc0204b36:	79e6                	ld	s3,120(sp)
ffffffffc0204b38:	7aa6                	ld	s5,104(sp)
ffffffffc0204b3a:	7b06                	ld	s6,96(sp)
ffffffffc0204b3c:	6be6                	ld	s7,88(sp)
ffffffffc0204b3e:	6c46                	ld	s8,80(sp)
ffffffffc0204b40:	6ca6                	ld	s9,72(sp)
ffffffffc0204b42:	6d06                	ld	s10,64(sp)
ffffffffc0204b44:	7de2                	ld	s11,56(sp)
ffffffffc0204b46:	8552                	mv	a0,s4
ffffffffc0204b48:	7a46                	ld	s4,112(sp)
ffffffffc0204b4a:	610d                	addi	sp,sp,160
ffffffffc0204b4c:	8082                	ret
        if (ph->p_filesz > ph->p_memsz)
ffffffffc0204b4e:	0289b603          	ld	a2,40(s3)
ffffffffc0204b52:	0209b783          	ld	a5,32(s3)
ffffffffc0204b56:	1ef66a63          	bltu	a2,a5,ffffffffc0204d4a <do_execve+0x474>
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204b5a:	0049a783          	lw	a5,4(s3)
ffffffffc0204b5e:	0017f693          	andi	a3,a5,1
ffffffffc0204b62:	c291                	beqz	a3,ffffffffc0204b66 <do_execve+0x290>
            vm_flags |= VM_EXEC;
ffffffffc0204b64:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204b66:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204b6a:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204b6c:	ef61                	bnez	a4,ffffffffc0204c44 <do_execve+0x36e>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0204b6e:	4bc5                	li	s7,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204b70:	c781                	beqz	a5,ffffffffc0204b78 <do_execve+0x2a2>
            vm_flags |= VM_READ;
ffffffffc0204b72:	0016e693          	ori	a3,a3,1
            perm |= PTE_R;
ffffffffc0204b76:	4bcd                	li	s7,19
        if (vm_flags & VM_WRITE)
ffffffffc0204b78:	0026f793          	andi	a5,a3,2
ffffffffc0204b7c:	e7f9                	bnez	a5,ffffffffc0204c4a <do_execve+0x374>
        if (vm_flags & VM_EXEC)
ffffffffc0204b7e:	0046f793          	andi	a5,a3,4
ffffffffc0204b82:	c399                	beqz	a5,ffffffffc0204b88 <do_execve+0x2b2>
            perm |= PTE_X;
ffffffffc0204b84:	008beb93          	ori	s7,s7,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc0204b88:	0109b583          	ld	a1,16(s3)
ffffffffc0204b8c:	4701                	li	a4,0
ffffffffc0204b8e:	8526                	mv	a0,s1
ffffffffc0204b90:	cdffe0ef          	jal	ra,ffffffffc020386e <mm_map>
ffffffffc0204b94:	8a2a                	mv	s4,a0
ffffffffc0204b96:	e159                	bnez	a0,ffffffffc0204c1c <do_execve+0x346>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204b98:	0109bd83          	ld	s11,16(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204b9c:	67c2                	ld	a5,16(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0204b9e:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204ba2:	0089b903          	ld	s2,8(s3)
        end = ph->p_va + ph->p_filesz;
ffffffffc0204ba6:	9a6e                	add	s4,s4,s11
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204ba8:	993e                	add	s2,s2,a5
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204baa:	77fd                	lui	a5,0xfffff
ffffffffc0204bac:	00fdfab3          	and	s5,s11,a5
        while (start < end)
ffffffffc0204bb0:	054dee63          	bltu	s11,s4,ffffffffc0204c0c <do_execve+0x336>
ffffffffc0204bb4:	aa49                	j	ffffffffc0204d46 <do_execve+0x470>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204bb6:	6785                	lui	a5,0x1
ffffffffc0204bb8:	415d8533          	sub	a0,s11,s5
ffffffffc0204bbc:	9abe                	add	s5,s5,a5
ffffffffc0204bbe:	41ba8633          	sub	a2,s5,s11
            if (end < la)
ffffffffc0204bc2:	015a7463          	bgeu	s4,s5,ffffffffc0204bca <do_execve+0x2f4>
                size -= la - end;
ffffffffc0204bc6:	41ba0633          	sub	a2,s4,s11
    return page - pages + nbase;
ffffffffc0204bca:	000d3683          	ld	a3,0(s10)
ffffffffc0204bce:	000cb803          	ld	a6,0(s9)
    return KADDR(page2pa(page));
ffffffffc0204bd2:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0204bd4:	40d406b3          	sub	a3,s0,a3
ffffffffc0204bd8:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204bda:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204bde:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0204be0:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204be4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204be6:	16b87463          	bgeu	a6,a1,ffffffffc0204d4e <do_execve+0x478>
ffffffffc0204bea:	000a6797          	auipc	a5,0xa6
ffffffffc0204bee:	aee78793          	addi	a5,a5,-1298 # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc0204bf2:	0007b803          	ld	a6,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204bf6:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0204bf8:	9db2                	add	s11,s11,a2
ffffffffc0204bfa:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204bfc:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0204bfe:	e032                	sd	a2,0(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204c00:	3a1000ef          	jal	ra,ffffffffc02057a0 <memcpy>
            start += size, from += size;
ffffffffc0204c04:	6602                	ld	a2,0(sp)
ffffffffc0204c06:	9932                	add	s2,s2,a2
        while (start < end)
ffffffffc0204c08:	054df363          	bgeu	s11,s4,ffffffffc0204c4e <do_execve+0x378>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204c0c:	6c88                	ld	a0,24(s1)
ffffffffc0204c0e:	865e                	mv	a2,s7
ffffffffc0204c10:	85d6                	mv	a1,s5
ffffffffc0204c12:	9e5fe0ef          	jal	ra,ffffffffc02035f6 <pgdir_alloc_page>
ffffffffc0204c16:	842a                	mv	s0,a0
ffffffffc0204c18:	fd59                	bnez	a0,ffffffffc0204bb6 <do_execve+0x2e0>
        ret = -E_NO_MEM;
ffffffffc0204c1a:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0204c1c:	8526                	mv	a0,s1
ffffffffc0204c1e:	d9bfe0ef          	jal	ra,ffffffffc02039b8 <exit_mmap>
    put_pgdir(mm);
ffffffffc0204c22:	8526                	mv	a0,s1
ffffffffc0204c24:	ac8ff0ef          	jal	ra,ffffffffc0203eec <put_pgdir>
    mm_destroy(mm);
ffffffffc0204c28:	8526                	mv	a0,s1
ffffffffc0204c2a:	bf3fe0ef          	jal	ra,ffffffffc020381c <mm_destroy>
    return ret;
ffffffffc0204c2e:	b3bd                	j	ffffffffc020499c <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0204c30:	854e                	mv	a0,s3
ffffffffc0204c32:	d87fe0ef          	jal	ra,ffffffffc02039b8 <exit_mmap>
            put_pgdir(mm);
ffffffffc0204c36:	854e                	mv	a0,s3
ffffffffc0204c38:	ab4ff0ef          	jal	ra,ffffffffc0203eec <put_pgdir>
            mm_destroy(mm);
ffffffffc0204c3c:	854e                	mv	a0,s3
ffffffffc0204c3e:	bdffe0ef          	jal	ra,ffffffffc020381c <mm_destroy>
ffffffffc0204c42:	b31d                	j	ffffffffc0204968 <do_execve+0x92>
            vm_flags |= VM_WRITE;
ffffffffc0204c44:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204c48:	f78d                	bnez	a5,ffffffffc0204b72 <do_execve+0x29c>
            perm |= (PTE_W | PTE_R);
ffffffffc0204c4a:	4bdd                	li	s7,23
ffffffffc0204c4c:	bf0d                	j	ffffffffc0204b7e <do_execve+0x2a8>
        end = ph->p_va + ph->p_memsz;
ffffffffc0204c4e:	0109b903          	ld	s2,16(s3)
ffffffffc0204c52:	0289b683          	ld	a3,40(s3)
ffffffffc0204c56:	9936                	add	s2,s2,a3
        if (start < la)
ffffffffc0204c58:	075dff63          	bgeu	s11,s5,ffffffffc0204cd6 <do_execve+0x400>
            if (start == end)
ffffffffc0204c5c:	ddb903e3          	beq	s2,s11,ffffffffc0204a22 <do_execve+0x14c>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204c60:	6505                	lui	a0,0x1
ffffffffc0204c62:	956e                	add	a0,a0,s11
ffffffffc0204c64:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0204c68:	41b90a33          	sub	s4,s2,s11
            if (end < la)
ffffffffc0204c6c:	0d597863          	bgeu	s2,s5,ffffffffc0204d3c <do_execve+0x466>
    return page - pages + nbase;
ffffffffc0204c70:	000d3683          	ld	a3,0(s10)
ffffffffc0204c74:	000cb583          	ld	a1,0(s9)
    return KADDR(page2pa(page));
ffffffffc0204c78:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0204c7a:	40d406b3          	sub	a3,s0,a3
ffffffffc0204c7e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204c80:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0204c84:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0204c86:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c8a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204c8c:	0cc5f163          	bgeu	a1,a2,ffffffffc0204d4e <do_execve+0x478>
ffffffffc0204c90:	000a6617          	auipc	a2,0xa6
ffffffffc0204c94:	a4863603          	ld	a2,-1464(a2) # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc0204c98:	96b2                	add	a3,a3,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0204c9a:	4581                	li	a1,0
ffffffffc0204c9c:	8652                	mv	a2,s4
ffffffffc0204c9e:	9536                	add	a0,a0,a3
ffffffffc0204ca0:	2ef000ef          	jal	ra,ffffffffc020578e <memset>
            start += size;
ffffffffc0204ca4:	01ba0733          	add	a4,s4,s11
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0204ca8:	03597463          	bgeu	s2,s5,ffffffffc0204cd0 <do_execve+0x3fa>
ffffffffc0204cac:	d6e90be3          	beq	s2,a4,ffffffffc0204a22 <do_execve+0x14c>
ffffffffc0204cb0:	00002697          	auipc	a3,0x2
ffffffffc0204cb4:	6b868693          	addi	a3,a3,1720 # ffffffffc0207368 <default_pmm_manager+0xd70>
ffffffffc0204cb8:	00001617          	auipc	a2,0x1
ffffffffc0204cbc:	59060613          	addi	a2,a2,1424 # ffffffffc0206248 <commands+0x828>
ffffffffc0204cc0:	2b500593          	li	a1,693
ffffffffc0204cc4:	00002517          	auipc	a0,0x2
ffffffffc0204cc8:	3a450513          	addi	a0,a0,932 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc0204ccc:	fc2fb0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc0204cd0:	ff5710e3          	bne	a4,s5,ffffffffc0204cb0 <do_execve+0x3da>
ffffffffc0204cd4:	8dd6                	mv	s11,s5
ffffffffc0204cd6:	000a6a17          	auipc	s4,0xa6
ffffffffc0204cda:	a02a0a13          	addi	s4,s4,-1534 # ffffffffc02aa6d8 <va_pa_offset>
        while (start < end)
ffffffffc0204cde:	052de763          	bltu	s11,s2,ffffffffc0204d2c <do_execve+0x456>
ffffffffc0204ce2:	b381                	j	ffffffffc0204a22 <do_execve+0x14c>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204ce4:	6785                	lui	a5,0x1
ffffffffc0204ce6:	415d8533          	sub	a0,s11,s5
ffffffffc0204cea:	9abe                	add	s5,s5,a5
ffffffffc0204cec:	41ba8633          	sub	a2,s5,s11
            if (end < la)
ffffffffc0204cf0:	01597463          	bgeu	s2,s5,ffffffffc0204cf8 <do_execve+0x422>
                size -= la - end;
ffffffffc0204cf4:	41b90633          	sub	a2,s2,s11
    return page - pages + nbase;
ffffffffc0204cf8:	000d3683          	ld	a3,0(s10)
ffffffffc0204cfc:	000cb803          	ld	a6,0(s9)
    return KADDR(page2pa(page));
ffffffffc0204d00:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0204d02:	40d406b3          	sub	a3,s0,a3
ffffffffc0204d06:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204d08:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204d0c:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0204d0e:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204d12:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204d14:	02b87d63          	bgeu	a6,a1,ffffffffc0204d4e <do_execve+0x478>
ffffffffc0204d18:	000a3803          	ld	a6,0(s4)
            start += size;
ffffffffc0204d1c:	9db2                	add	s11,s11,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0204d1e:	4581                	li	a1,0
ffffffffc0204d20:	96c2                	add	a3,a3,a6
ffffffffc0204d22:	9536                	add	a0,a0,a3
ffffffffc0204d24:	26b000ef          	jal	ra,ffffffffc020578e <memset>
        while (start < end)
ffffffffc0204d28:	cf2dfde3          	bgeu	s11,s2,ffffffffc0204a22 <do_execve+0x14c>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204d2c:	6c88                	ld	a0,24(s1)
ffffffffc0204d2e:	865e                	mv	a2,s7
ffffffffc0204d30:	85d6                	mv	a1,s5
ffffffffc0204d32:	8c5fe0ef          	jal	ra,ffffffffc02035f6 <pgdir_alloc_page>
ffffffffc0204d36:	842a                	mv	s0,a0
ffffffffc0204d38:	f555                	bnez	a0,ffffffffc0204ce4 <do_execve+0x40e>
ffffffffc0204d3a:	b5c5                	j	ffffffffc0204c1a <do_execve+0x344>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204d3c:	41ba8a33          	sub	s4,s5,s11
ffffffffc0204d40:	bf05                	j	ffffffffc0204c70 <do_execve+0x39a>
        return -E_INVAL;
ffffffffc0204d42:	5a75                	li	s4,-3
ffffffffc0204d44:	b3ed                	j	ffffffffc0204b2e <do_execve+0x258>
        while (start < end)
ffffffffc0204d46:	896e                	mv	s2,s11
ffffffffc0204d48:	b729                	j	ffffffffc0204c52 <do_execve+0x37c>
            ret = -E_INVAL_ELF;
ffffffffc0204d4a:	5a61                	li	s4,-8
ffffffffc0204d4c:	bdc1                	j	ffffffffc0204c1c <do_execve+0x346>
ffffffffc0204d4e:	00002617          	auipc	a2,0x2
ffffffffc0204d52:	8e260613          	addi	a2,a2,-1822 # ffffffffc0206630 <default_pmm_manager+0x38>
ffffffffc0204d56:	07100593          	li	a1,113
ffffffffc0204d5a:	00002517          	auipc	a0,0x2
ffffffffc0204d5e:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0206658 <default_pmm_manager+0x60>
ffffffffc0204d62:	f2cfb0ef          	jal	ra,ffffffffc020048e <__panic>
    lsatp(PADDR(mm->pgdir));
ffffffffc0204d66:	00002617          	auipc	a2,0x2
ffffffffc0204d6a:	97260613          	addi	a2,a2,-1678 # ffffffffc02066d8 <default_pmm_manager+0xe0>
ffffffffc0204d6e:	2d700593          	li	a1,727
ffffffffc0204d72:	00002517          	auipc	a0,0x2
ffffffffc0204d76:	2f650513          	addi	a0,a0,758 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc0204d7a:	f14fb0ef          	jal	ra,ffffffffc020048e <__panic>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204d7e:	00002617          	auipc	a2,0x2
ffffffffc0204d82:	95a60613          	addi	a2,a2,-1702 # ffffffffc02066d8 <default_pmm_manager+0xe0>
ffffffffc0204d86:	2d500593          	li	a1,725
ffffffffc0204d8a:	00002517          	auipc	a0,0x2
ffffffffc0204d8e:	2de50513          	addi	a0,a0,734 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc0204d92:	efcfb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204d96:	00002697          	auipc	a3,0x2
ffffffffc0204d9a:	6ea68693          	addi	a3,a3,1770 # ffffffffc0207480 <default_pmm_manager+0xe88>
ffffffffc0204d9e:	00001617          	auipc	a2,0x1
ffffffffc0204da2:	4aa60613          	addi	a2,a2,1194 # ffffffffc0206248 <commands+0x828>
ffffffffc0204da6:	2cf00593          	li	a1,719
ffffffffc0204daa:	00002517          	auipc	a0,0x2
ffffffffc0204dae:	2be50513          	addi	a0,a0,702 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc0204db2:	edcfb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204db6:	00002697          	auipc	a3,0x2
ffffffffc0204dba:	68268693          	addi	a3,a3,1666 # ffffffffc0207438 <default_pmm_manager+0xe40>
ffffffffc0204dbe:	00001617          	auipc	a2,0x1
ffffffffc0204dc2:	48a60613          	addi	a2,a2,1162 # ffffffffc0206248 <commands+0x828>
ffffffffc0204dc6:	2ce00593          	li	a1,718
ffffffffc0204dca:	00002517          	auipc	a0,0x2
ffffffffc0204dce:	29e50513          	addi	a0,a0,670 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc0204dd2:	ebcfb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204dd6:	00002697          	auipc	a3,0x2
ffffffffc0204dda:	61a68693          	addi	a3,a3,1562 # ffffffffc02073f0 <default_pmm_manager+0xdf8>
ffffffffc0204dde:	00001617          	auipc	a2,0x1
ffffffffc0204de2:	46a60613          	addi	a2,a2,1130 # ffffffffc0206248 <commands+0x828>
ffffffffc0204de6:	2cd00593          	li	a1,717
ffffffffc0204dea:	00002517          	auipc	a0,0x2
ffffffffc0204dee:	27e50513          	addi	a0,a0,638 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc0204df2:	e9cfb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204df6:	00002697          	auipc	a3,0x2
ffffffffc0204dfa:	5b268693          	addi	a3,a3,1458 # ffffffffc02073a8 <default_pmm_manager+0xdb0>
ffffffffc0204dfe:	00001617          	auipc	a2,0x1
ffffffffc0204e02:	44a60613          	addi	a2,a2,1098 # ffffffffc0206248 <commands+0x828>
ffffffffc0204e06:	2cc00593          	li	a1,716
ffffffffc0204e0a:	00002517          	auipc	a0,0x2
ffffffffc0204e0e:	25e50513          	addi	a0,a0,606 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc0204e12:	e7cfb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204e16 <do_yield>:
    current->need_resched = 1;
ffffffffc0204e16:	000a6797          	auipc	a5,0xa6
ffffffffc0204e1a:	8ca7b783          	ld	a5,-1846(a5) # ffffffffc02aa6e0 <current>
ffffffffc0204e1e:	4705                	li	a4,1
ffffffffc0204e20:	ef98                	sd	a4,24(a5)
}
ffffffffc0204e22:	4501                	li	a0,0
ffffffffc0204e24:	8082                	ret

ffffffffc0204e26 <do_wait>:
{
ffffffffc0204e26:	1101                	addi	sp,sp,-32
ffffffffc0204e28:	e822                	sd	s0,16(sp)
ffffffffc0204e2a:	e426                	sd	s1,8(sp)
ffffffffc0204e2c:	ec06                	sd	ra,24(sp)
ffffffffc0204e2e:	842e                	mv	s0,a1
ffffffffc0204e30:	84aa                	mv	s1,a0
    if (code_store != NULL)
ffffffffc0204e32:	c999                	beqz	a1,ffffffffc0204e48 <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0204e34:	000a6797          	auipc	a5,0xa6
ffffffffc0204e38:	8ac7b783          	ld	a5,-1876(a5) # ffffffffc02aa6e0 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0204e3c:	7788                	ld	a0,40(a5)
ffffffffc0204e3e:	4685                	li	a3,1
ffffffffc0204e40:	4611                	li	a2,4
ffffffffc0204e42:	f11fe0ef          	jal	ra,ffffffffc0203d52 <user_mem_check>
ffffffffc0204e46:	c909                	beqz	a0,ffffffffc0204e58 <do_wait+0x32>
ffffffffc0204e48:	85a2                	mv	a1,s0
}
ffffffffc0204e4a:	6442                	ld	s0,16(sp)
ffffffffc0204e4c:	60e2                	ld	ra,24(sp)
ffffffffc0204e4e:	8526                	mv	a0,s1
ffffffffc0204e50:	64a2                	ld	s1,8(sp)
ffffffffc0204e52:	6105                	addi	sp,sp,32
ffffffffc0204e54:	f8cff06f          	j	ffffffffc02045e0 <do_wait.part.0>
ffffffffc0204e58:	60e2                	ld	ra,24(sp)
ffffffffc0204e5a:	6442                	ld	s0,16(sp)
ffffffffc0204e5c:	64a2                	ld	s1,8(sp)
ffffffffc0204e5e:	5575                	li	a0,-3
ffffffffc0204e60:	6105                	addi	sp,sp,32
ffffffffc0204e62:	8082                	ret

ffffffffc0204e64 <do_kill>:
{
ffffffffc0204e64:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID)
ffffffffc0204e66:	6789                	lui	a5,0x2
{
ffffffffc0204e68:	e406                	sd	ra,8(sp)
ffffffffc0204e6a:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID)
ffffffffc0204e6c:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204e70:	17f9                	addi	a5,a5,-2
ffffffffc0204e72:	02e7e963          	bltu	a5,a4,ffffffffc0204ea4 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204e76:	842a                	mv	s0,a0
ffffffffc0204e78:	45a9                	li	a1,10
ffffffffc0204e7a:	2501                	sext.w	a0,a0
ffffffffc0204e7c:	46c000ef          	jal	ra,ffffffffc02052e8 <hash32>
ffffffffc0204e80:	02051793          	slli	a5,a0,0x20
ffffffffc0204e84:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204e88:	000a1797          	auipc	a5,0xa1
ffffffffc0204e8c:	7e078793          	addi	a5,a5,2016 # ffffffffc02a6668 <hash_list>
ffffffffc0204e90:	953e                	add	a0,a0,a5
ffffffffc0204e92:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list)
ffffffffc0204e94:	a029                	j	ffffffffc0204e9e <do_kill+0x3a>
            if (proc->pid == pid)
ffffffffc0204e96:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0204e9a:	00870b63          	beq	a4,s0,ffffffffc0204eb0 <do_kill+0x4c>
ffffffffc0204e9e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204ea0:	fef51be3          	bne	a0,a5,ffffffffc0204e96 <do_kill+0x32>
    return -E_INVAL;
ffffffffc0204ea4:	5475                	li	s0,-3
}
ffffffffc0204ea6:	60a2                	ld	ra,8(sp)
ffffffffc0204ea8:	8522                	mv	a0,s0
ffffffffc0204eaa:	6402                	ld	s0,0(sp)
ffffffffc0204eac:	0141                	addi	sp,sp,16
ffffffffc0204eae:	8082                	ret
        if (!(proc->flags & PF_EXITING))
ffffffffc0204eb0:	fd87a703          	lw	a4,-40(a5)
ffffffffc0204eb4:	00177693          	andi	a3,a4,1
ffffffffc0204eb8:	e295                	bnez	a3,ffffffffc0204edc <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0204eba:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0204ebc:	00176713          	ori	a4,a4,1
ffffffffc0204ec0:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0204ec4:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0204ec6:	fe06d0e3          	bgez	a3,ffffffffc0204ea6 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0204eca:	f2878513          	addi	a0,a5,-216
ffffffffc0204ece:	22e000ef          	jal	ra,ffffffffc02050fc <wakeup_proc>
}
ffffffffc0204ed2:	60a2                	ld	ra,8(sp)
ffffffffc0204ed4:	8522                	mv	a0,s0
ffffffffc0204ed6:	6402                	ld	s0,0(sp)
ffffffffc0204ed8:	0141                	addi	sp,sp,16
ffffffffc0204eda:	8082                	ret
        return -E_KILLED;
ffffffffc0204edc:	545d                	li	s0,-9
ffffffffc0204ede:	b7e1                	j	ffffffffc0204ea6 <do_kill+0x42>

ffffffffc0204ee0 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc0204ee0:	1101                	addi	sp,sp,-32
ffffffffc0204ee2:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0204ee4:	000a5797          	auipc	a5,0xa5
ffffffffc0204ee8:	78478793          	addi	a5,a5,1924 # ffffffffc02aa668 <proc_list>
ffffffffc0204eec:	ec06                	sd	ra,24(sp)
ffffffffc0204eee:	e822                	sd	s0,16(sp)
ffffffffc0204ef0:	e04a                	sd	s2,0(sp)
ffffffffc0204ef2:	000a1497          	auipc	s1,0xa1
ffffffffc0204ef6:	77648493          	addi	s1,s1,1910 # ffffffffc02a6668 <hash_list>
ffffffffc0204efa:	e79c                	sd	a5,8(a5)
ffffffffc0204efc:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0204efe:	000a5717          	auipc	a4,0xa5
ffffffffc0204f02:	76a70713          	addi	a4,a4,1898 # ffffffffc02aa668 <proc_list>
ffffffffc0204f06:	87a6                	mv	a5,s1
ffffffffc0204f08:	e79c                	sd	a5,8(a5)
ffffffffc0204f0a:	e39c                	sd	a5,0(a5)
ffffffffc0204f0c:	07c1                	addi	a5,a5,16
ffffffffc0204f0e:	fef71de3          	bne	a4,a5,ffffffffc0204f08 <proc_init+0x28>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc0204f12:	eddfe0ef          	jal	ra,ffffffffc0203dee <alloc_proc>
ffffffffc0204f16:	000a5917          	auipc	s2,0xa5
ffffffffc0204f1a:	7d290913          	addi	s2,s2,2002 # ffffffffc02aa6e8 <idleproc>
ffffffffc0204f1e:	00a93023          	sd	a0,0(s2)
ffffffffc0204f22:	0e050f63          	beqz	a0,ffffffffc0205020 <proc_init+0x140>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0204f26:	4789                	li	a5,2
ffffffffc0204f28:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204f2a:	00003797          	auipc	a5,0x3
ffffffffc0204f2e:	0d678793          	addi	a5,a5,214 # ffffffffc0208000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f32:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204f36:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0204f38:	4785                	li	a5,1
ffffffffc0204f3a:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f3c:	4641                	li	a2,16
ffffffffc0204f3e:	4581                	li	a1,0
ffffffffc0204f40:	8522                	mv	a0,s0
ffffffffc0204f42:	04d000ef          	jal	ra,ffffffffc020578e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f46:	463d                	li	a2,15
ffffffffc0204f48:	00002597          	auipc	a1,0x2
ffffffffc0204f4c:	60858593          	addi	a1,a1,1544 # ffffffffc0207550 <default_pmm_manager+0xf58>
ffffffffc0204f50:	8522                	mv	a0,s0
ffffffffc0204f52:	04f000ef          	jal	ra,ffffffffc02057a0 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process++;
ffffffffc0204f56:	000a5717          	auipc	a4,0xa5
ffffffffc0204f5a:	7a270713          	addi	a4,a4,1954 # ffffffffc02aa6f8 <nr_process>
ffffffffc0204f5e:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0204f60:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0204f64:	4601                	li	a2,0
    nr_process++;
ffffffffc0204f66:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0204f68:	4581                	li	a1,0
ffffffffc0204f6a:	00000517          	auipc	a0,0x0
ffffffffc0204f6e:	84850513          	addi	a0,a0,-1976 # ffffffffc02047b2 <init_main>
    nr_process++;
ffffffffc0204f72:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0204f74:	000a5797          	auipc	a5,0xa5
ffffffffc0204f78:	76d7b623          	sd	a3,1900(a5) # ffffffffc02aa6e0 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0204f7c:	ccaff0ef          	jal	ra,ffffffffc0204446 <kernel_thread>
ffffffffc0204f80:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc0204f82:	08a05363          	blez	a0,ffffffffc0205008 <proc_init+0x128>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204f86:	6789                	lui	a5,0x2
ffffffffc0204f88:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204f8c:	17f9                	addi	a5,a5,-2
ffffffffc0204f8e:	2501                	sext.w	a0,a0
ffffffffc0204f90:	02e7e363          	bltu	a5,a4,ffffffffc0204fb6 <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204f94:	45a9                	li	a1,10
ffffffffc0204f96:	352000ef          	jal	ra,ffffffffc02052e8 <hash32>
ffffffffc0204f9a:	02051793          	slli	a5,a0,0x20
ffffffffc0204f9e:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0204fa2:	96a6                	add	a3,a3,s1
ffffffffc0204fa4:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0204fa6:	a029                	j	ffffffffc0204fb0 <proc_init+0xd0>
            if (proc->pid == pid)
ffffffffc0204fa8:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c7c>
ffffffffc0204fac:	04870b63          	beq	a4,s0,ffffffffc0205002 <proc_init+0x122>
    return listelm->next;
ffffffffc0204fb0:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204fb2:	fef69be3          	bne	a3,a5,ffffffffc0204fa8 <proc_init+0xc8>
    return NULL;
ffffffffc0204fb6:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204fb8:	0b478493          	addi	s1,a5,180
ffffffffc0204fbc:	4641                	li	a2,16
ffffffffc0204fbe:	4581                	li	a1,0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0204fc0:	000a5417          	auipc	s0,0xa5
ffffffffc0204fc4:	73040413          	addi	s0,s0,1840 # ffffffffc02aa6f0 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204fc8:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0204fca:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204fcc:	7c2000ef          	jal	ra,ffffffffc020578e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204fd0:	463d                	li	a2,15
ffffffffc0204fd2:	00002597          	auipc	a1,0x2
ffffffffc0204fd6:	5a658593          	addi	a1,a1,1446 # ffffffffc0207578 <default_pmm_manager+0xf80>
ffffffffc0204fda:	8526                	mv	a0,s1
ffffffffc0204fdc:	7c4000ef          	jal	ra,ffffffffc02057a0 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204fe0:	00093783          	ld	a5,0(s2)
ffffffffc0204fe4:	cbb5                	beqz	a5,ffffffffc0205058 <proc_init+0x178>
ffffffffc0204fe6:	43dc                	lw	a5,4(a5)
ffffffffc0204fe8:	eba5                	bnez	a5,ffffffffc0205058 <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204fea:	601c                	ld	a5,0(s0)
ffffffffc0204fec:	c7b1                	beqz	a5,ffffffffc0205038 <proc_init+0x158>
ffffffffc0204fee:	43d8                	lw	a4,4(a5)
ffffffffc0204ff0:	4785                	li	a5,1
ffffffffc0204ff2:	04f71363          	bne	a4,a5,ffffffffc0205038 <proc_init+0x158>
}
ffffffffc0204ff6:	60e2                	ld	ra,24(sp)
ffffffffc0204ff8:	6442                	ld	s0,16(sp)
ffffffffc0204ffa:	64a2                	ld	s1,8(sp)
ffffffffc0204ffc:	6902                	ld	s2,0(sp)
ffffffffc0204ffe:	6105                	addi	sp,sp,32
ffffffffc0205000:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205002:	f2878793          	addi	a5,a5,-216
ffffffffc0205006:	bf4d                	j	ffffffffc0204fb8 <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0205008:	00002617          	auipc	a2,0x2
ffffffffc020500c:	55060613          	addi	a2,a2,1360 # ffffffffc0207558 <default_pmm_manager+0xf60>
ffffffffc0205010:	3f700593          	li	a1,1015
ffffffffc0205014:	00002517          	auipc	a0,0x2
ffffffffc0205018:	05450513          	addi	a0,a0,84 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc020501c:	c72fb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0205020:	00002617          	auipc	a2,0x2
ffffffffc0205024:	51860613          	addi	a2,a2,1304 # ffffffffc0207538 <default_pmm_manager+0xf40>
ffffffffc0205028:	3e800593          	li	a1,1000
ffffffffc020502c:	00002517          	auipc	a0,0x2
ffffffffc0205030:	03c50513          	addi	a0,a0,60 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc0205034:	c5afb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205038:	00002697          	auipc	a3,0x2
ffffffffc020503c:	57068693          	addi	a3,a3,1392 # ffffffffc02075a8 <default_pmm_manager+0xfb0>
ffffffffc0205040:	00001617          	auipc	a2,0x1
ffffffffc0205044:	20860613          	addi	a2,a2,520 # ffffffffc0206248 <commands+0x828>
ffffffffc0205048:	3fe00593          	li	a1,1022
ffffffffc020504c:	00002517          	auipc	a0,0x2
ffffffffc0205050:	01c50513          	addi	a0,a0,28 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc0205054:	c3afb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205058:	00002697          	auipc	a3,0x2
ffffffffc020505c:	52868693          	addi	a3,a3,1320 # ffffffffc0207580 <default_pmm_manager+0xf88>
ffffffffc0205060:	00001617          	auipc	a2,0x1
ffffffffc0205064:	1e860613          	addi	a2,a2,488 # ffffffffc0206248 <commands+0x828>
ffffffffc0205068:	3fd00593          	li	a1,1021
ffffffffc020506c:	00002517          	auipc	a0,0x2
ffffffffc0205070:	ffc50513          	addi	a0,a0,-4 # ffffffffc0207068 <default_pmm_manager+0xa70>
ffffffffc0205074:	c1afb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0205078 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc0205078:	1141                	addi	sp,sp,-16
ffffffffc020507a:	e022                	sd	s0,0(sp)
ffffffffc020507c:	e406                	sd	ra,8(sp)
ffffffffc020507e:	000a5417          	auipc	s0,0xa5
ffffffffc0205082:	66240413          	addi	s0,s0,1634 # ffffffffc02aa6e0 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc0205086:	6018                	ld	a4,0(s0)
ffffffffc0205088:	6f1c                	ld	a5,24(a4)
ffffffffc020508a:	dffd                	beqz	a5,ffffffffc0205088 <cpu_idle+0x10>
        {
            schedule();
ffffffffc020508c:	0f0000ef          	jal	ra,ffffffffc020517c <schedule>
ffffffffc0205090:	bfdd                	j	ffffffffc0205086 <cpu_idle+0xe>

ffffffffc0205092 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0205092:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0205096:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc020509a:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc020509c:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc020509e:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc02050a2:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc02050a6:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc02050aa:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc02050ae:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc02050b2:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc02050b6:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc02050ba:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc02050be:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc02050c2:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc02050c6:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc02050ca:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc02050ce:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc02050d0:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc02050d2:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc02050d6:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc02050da:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc02050de:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc02050e2:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc02050e6:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc02050ea:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc02050ee:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc02050f2:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc02050f6:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc02050fa:	8082                	ret

ffffffffc02050fc <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02050fc:	4118                	lw	a4,0(a0)
{
ffffffffc02050fe:	1101                	addi	sp,sp,-32
ffffffffc0205100:	ec06                	sd	ra,24(sp)
ffffffffc0205102:	e822                	sd	s0,16(sp)
ffffffffc0205104:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205106:	478d                	li	a5,3
ffffffffc0205108:	04f70b63          	beq	a4,a5,ffffffffc020515e <wakeup_proc+0x62>
ffffffffc020510c:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020510e:	100027f3          	csrr	a5,sstatus
ffffffffc0205112:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205114:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0205116:	ef9d                	bnez	a5,ffffffffc0205154 <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
ffffffffc0205118:	4789                	li	a5,2
ffffffffc020511a:	02f70163          	beq	a4,a5,ffffffffc020513c <wakeup_proc+0x40>
        {
            proc->state = PROC_RUNNABLE;
ffffffffc020511e:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0205120:	0e042623          	sw	zero,236(s0)
    if (flag)
ffffffffc0205124:	e491                	bnez	s1,ffffffffc0205130 <wakeup_proc+0x34>
        {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205126:	60e2                	ld	ra,24(sp)
ffffffffc0205128:	6442                	ld	s0,16(sp)
ffffffffc020512a:	64a2                	ld	s1,8(sp)
ffffffffc020512c:	6105                	addi	sp,sp,32
ffffffffc020512e:	8082                	ret
ffffffffc0205130:	6442                	ld	s0,16(sp)
ffffffffc0205132:	60e2                	ld	ra,24(sp)
ffffffffc0205134:	64a2                	ld	s1,8(sp)
ffffffffc0205136:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205138:	877fb06f          	j	ffffffffc02009ae <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc020513c:	00002617          	auipc	a2,0x2
ffffffffc0205140:	4cc60613          	addi	a2,a2,1228 # ffffffffc0207608 <default_pmm_manager+0x1010>
ffffffffc0205144:	45d1                	li	a1,20
ffffffffc0205146:	00002517          	auipc	a0,0x2
ffffffffc020514a:	4aa50513          	addi	a0,a0,1194 # ffffffffc02075f0 <default_pmm_manager+0xff8>
ffffffffc020514e:	ba8fb0ef          	jal	ra,ffffffffc02004f6 <__warn>
ffffffffc0205152:	bfc9                	j	ffffffffc0205124 <wakeup_proc+0x28>
        intr_disable();
ffffffffc0205154:	861fb0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        if (proc->state != PROC_RUNNABLE)
ffffffffc0205158:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc020515a:	4485                	li	s1,1
ffffffffc020515c:	bf75                	j	ffffffffc0205118 <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020515e:	00002697          	auipc	a3,0x2
ffffffffc0205162:	47268693          	addi	a3,a3,1138 # ffffffffc02075d0 <default_pmm_manager+0xfd8>
ffffffffc0205166:	00001617          	auipc	a2,0x1
ffffffffc020516a:	0e260613          	addi	a2,a2,226 # ffffffffc0206248 <commands+0x828>
ffffffffc020516e:	45a5                	li	a1,9
ffffffffc0205170:	00002517          	auipc	a0,0x2
ffffffffc0205174:	48050513          	addi	a0,a0,1152 # ffffffffc02075f0 <default_pmm_manager+0xff8>
ffffffffc0205178:	b16fb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020517c <schedule>:

void schedule(void)
{
ffffffffc020517c:	1141                	addi	sp,sp,-16
ffffffffc020517e:	e406                	sd	ra,8(sp)
ffffffffc0205180:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0205182:	100027f3          	csrr	a5,sstatus
ffffffffc0205186:	8b89                	andi	a5,a5,2
ffffffffc0205188:	4401                	li	s0,0
ffffffffc020518a:	efbd                	bnez	a5,ffffffffc0205208 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc020518c:	000a5897          	auipc	a7,0xa5
ffffffffc0205190:	5548b883          	ld	a7,1364(a7) # ffffffffc02aa6e0 <current>
ffffffffc0205194:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205198:	000a5517          	auipc	a0,0xa5
ffffffffc020519c:	55053503          	ld	a0,1360(a0) # ffffffffc02aa6e8 <idleproc>
ffffffffc02051a0:	04a88e63          	beq	a7,a0,ffffffffc02051fc <schedule+0x80>
ffffffffc02051a4:	0c888693          	addi	a3,a7,200
ffffffffc02051a8:	000a5617          	auipc	a2,0xa5
ffffffffc02051ac:	4c060613          	addi	a2,a2,1216 # ffffffffc02aa668 <proc_list>
        le = last;
ffffffffc02051b0:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc02051b2:	4581                	li	a1,0
        do
        {
            if ((le = list_next(le)) != &proc_list)
            {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE)
ffffffffc02051b4:	4809                	li	a6,2
ffffffffc02051b6:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list)
ffffffffc02051b8:	00c78863          	beq	a5,a2,ffffffffc02051c8 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE)
ffffffffc02051bc:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02051c0:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE)
ffffffffc02051c4:	03070163          	beq	a4,a6,ffffffffc02051e6 <schedule+0x6a>
                {
                    break;
                }
            }
        } while (le != last);
ffffffffc02051c8:	fef697e3          	bne	a3,a5,ffffffffc02051b6 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc02051cc:	ed89                	bnez	a1,ffffffffc02051e6 <schedule+0x6a>
        {
            next = idleproc;
        }
        next->runs++;
ffffffffc02051ce:	451c                	lw	a5,8(a0)
ffffffffc02051d0:	2785                	addiw	a5,a5,1
ffffffffc02051d2:	c51c                	sw	a5,8(a0)
        if (next != current)
ffffffffc02051d4:	00a88463          	beq	a7,a0,ffffffffc02051dc <schedule+0x60>
        {
            proc_run(next);
ffffffffc02051d8:	e2bfe0ef          	jal	ra,ffffffffc0204002 <proc_run>
    if (flag)
ffffffffc02051dc:	e819                	bnez	s0,ffffffffc02051f2 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02051de:	60a2                	ld	ra,8(sp)
ffffffffc02051e0:	6402                	ld	s0,0(sp)
ffffffffc02051e2:	0141                	addi	sp,sp,16
ffffffffc02051e4:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc02051e6:	4198                	lw	a4,0(a1)
ffffffffc02051e8:	4789                	li	a5,2
ffffffffc02051ea:	fef712e3          	bne	a4,a5,ffffffffc02051ce <schedule+0x52>
ffffffffc02051ee:	852e                	mv	a0,a1
ffffffffc02051f0:	bff9                	j	ffffffffc02051ce <schedule+0x52>
}
ffffffffc02051f2:	6402                	ld	s0,0(sp)
ffffffffc02051f4:	60a2                	ld	ra,8(sp)
ffffffffc02051f6:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02051f8:	fb6fb06f          	j	ffffffffc02009ae <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02051fc:	000a5617          	auipc	a2,0xa5
ffffffffc0205200:	46c60613          	addi	a2,a2,1132 # ffffffffc02aa668 <proc_list>
ffffffffc0205204:	86b2                	mv	a3,a2
ffffffffc0205206:	b76d                	j	ffffffffc02051b0 <schedule+0x34>
        intr_disable();
ffffffffc0205208:	facfb0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc020520c:	4405                	li	s0,1
ffffffffc020520e:	bfbd                	j	ffffffffc020518c <schedule+0x10>

ffffffffc0205210 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0205210:	000a5797          	auipc	a5,0xa5
ffffffffc0205214:	4d07b783          	ld	a5,1232(a5) # ffffffffc02aa6e0 <current>
}
ffffffffc0205218:	43c8                	lw	a0,4(a5)
ffffffffc020521a:	8082                	ret

ffffffffc020521c <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc020521c:	4501                	li	a0,0
ffffffffc020521e:	8082                	ret

ffffffffc0205220 <sys_putc>:
    cputchar(c);
ffffffffc0205220:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0205222:	1141                	addi	sp,sp,-16
ffffffffc0205224:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0205226:	fa5fa0ef          	jal	ra,ffffffffc02001ca <cputchar>
}
ffffffffc020522a:	60a2                	ld	ra,8(sp)
ffffffffc020522c:	4501                	li	a0,0
ffffffffc020522e:	0141                	addi	sp,sp,16
ffffffffc0205230:	8082                	ret

ffffffffc0205232 <sys_kill>:
    return do_kill(pid);
ffffffffc0205232:	4108                	lw	a0,0(a0)
ffffffffc0205234:	c31ff06f          	j	ffffffffc0204e64 <do_kill>

ffffffffc0205238 <sys_yield>:
    return do_yield();
ffffffffc0205238:	bdfff06f          	j	ffffffffc0204e16 <do_yield>

ffffffffc020523c <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc020523c:	6d14                	ld	a3,24(a0)
ffffffffc020523e:	6910                	ld	a2,16(a0)
ffffffffc0205240:	650c                	ld	a1,8(a0)
ffffffffc0205242:	6108                	ld	a0,0(a0)
ffffffffc0205244:	e92ff06f          	j	ffffffffc02048d6 <do_execve>

ffffffffc0205248 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0205248:	650c                	ld	a1,8(a0)
ffffffffc020524a:	4108                	lw	a0,0(a0)
ffffffffc020524c:	bdbff06f          	j	ffffffffc0204e26 <do_wait>

ffffffffc0205250 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0205250:	000a5797          	auipc	a5,0xa5
ffffffffc0205254:	4907b783          	ld	a5,1168(a5) # ffffffffc02aa6e0 <current>
ffffffffc0205258:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc020525a:	4501                	li	a0,0
ffffffffc020525c:	6a0c                	ld	a1,16(a2)
ffffffffc020525e:	e27fe06f          	j	ffffffffc0204084 <do_fork>

ffffffffc0205262 <sys_exit>:
    return do_exit(error_code);
ffffffffc0205262:	4108                	lw	a0,0(a0)
ffffffffc0205264:	a32ff06f          	j	ffffffffc0204496 <do_exit>

ffffffffc0205268 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0205268:	715d                	addi	sp,sp,-80
ffffffffc020526a:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc020526c:	000a5497          	auipc	s1,0xa5
ffffffffc0205270:	47448493          	addi	s1,s1,1140 # ffffffffc02aa6e0 <current>
ffffffffc0205274:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0205276:	e0a2                	sd	s0,64(sp)
ffffffffc0205278:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc020527a:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc020527c:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc020527e:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc0205280:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205284:	0327ee63          	bltu	a5,s2,ffffffffc02052c0 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0205288:	00391713          	slli	a4,s2,0x3
ffffffffc020528c:	00002797          	auipc	a5,0x2
ffffffffc0205290:	3e478793          	addi	a5,a5,996 # ffffffffc0207670 <syscalls>
ffffffffc0205294:	97ba                	add	a5,a5,a4
ffffffffc0205296:	639c                	ld	a5,0(a5)
ffffffffc0205298:	c785                	beqz	a5,ffffffffc02052c0 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc020529a:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc020529c:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc020529e:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc02052a0:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc02052a2:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc02052a4:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc02052a6:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc02052a8:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02052aa:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc02052ac:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02052ae:	0028                	addi	a0,sp,8
ffffffffc02052b0:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc02052b2:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02052b4:	e828                	sd	a0,80(s0)
}
ffffffffc02052b6:	6406                	ld	s0,64(sp)
ffffffffc02052b8:	74e2                	ld	s1,56(sp)
ffffffffc02052ba:	7942                	ld	s2,48(sp)
ffffffffc02052bc:	6161                	addi	sp,sp,80
ffffffffc02052be:	8082                	ret
    print_trapframe(tf);
ffffffffc02052c0:	8522                	mv	a0,s0
ffffffffc02052c2:	8e3fb0ef          	jal	ra,ffffffffc0200ba4 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc02052c6:	609c                	ld	a5,0(s1)
ffffffffc02052c8:	86ca                	mv	a3,s2
ffffffffc02052ca:	00002617          	auipc	a2,0x2
ffffffffc02052ce:	35e60613          	addi	a2,a2,862 # ffffffffc0207628 <default_pmm_manager+0x1030>
ffffffffc02052d2:	43d8                	lw	a4,4(a5)
ffffffffc02052d4:	06200593          	li	a1,98
ffffffffc02052d8:	0b478793          	addi	a5,a5,180
ffffffffc02052dc:	00002517          	auipc	a0,0x2
ffffffffc02052e0:	37c50513          	addi	a0,a0,892 # ffffffffc0207658 <default_pmm_manager+0x1060>
ffffffffc02052e4:	9aafb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02052e8 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02052e8:	9e3707b7          	lui	a5,0x9e370
ffffffffc02052ec:	2785                	addiw	a5,a5,1
ffffffffc02052ee:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc02052f2:	02000793          	li	a5,32
ffffffffc02052f6:	9f8d                	subw	a5,a5,a1
}
ffffffffc02052f8:	00f5553b          	srlw	a0,a0,a5
ffffffffc02052fc:	8082                	ret

ffffffffc02052fe <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02052fe:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205302:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0205304:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205308:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020530a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020530e:	f022                	sd	s0,32(sp)
ffffffffc0205310:	ec26                	sd	s1,24(sp)
ffffffffc0205312:	e84a                	sd	s2,16(sp)
ffffffffc0205314:	f406                	sd	ra,40(sp)
ffffffffc0205316:	e44e                	sd	s3,8(sp)
ffffffffc0205318:	84aa                	mv	s1,a0
ffffffffc020531a:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020531c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0205320:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0205322:	03067e63          	bgeu	a2,a6,ffffffffc020535e <printnum+0x60>
ffffffffc0205326:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0205328:	00805763          	blez	s0,ffffffffc0205336 <printnum+0x38>
ffffffffc020532c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020532e:	85ca                	mv	a1,s2
ffffffffc0205330:	854e                	mv	a0,s3
ffffffffc0205332:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0205334:	fc65                	bnez	s0,ffffffffc020532c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205336:	1a02                	slli	s4,s4,0x20
ffffffffc0205338:	00002797          	auipc	a5,0x2
ffffffffc020533c:	43878793          	addi	a5,a5,1080 # ffffffffc0207770 <syscalls+0x100>
ffffffffc0205340:	020a5a13          	srli	s4,s4,0x20
ffffffffc0205344:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0205346:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205348:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020534c:	70a2                	ld	ra,40(sp)
ffffffffc020534e:	69a2                	ld	s3,8(sp)
ffffffffc0205350:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205352:	85ca                	mv	a1,s2
ffffffffc0205354:	87a6                	mv	a5,s1
}
ffffffffc0205356:	6942                	ld	s2,16(sp)
ffffffffc0205358:	64e2                	ld	s1,24(sp)
ffffffffc020535a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020535c:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020535e:	03065633          	divu	a2,a2,a6
ffffffffc0205362:	8722                	mv	a4,s0
ffffffffc0205364:	f9bff0ef          	jal	ra,ffffffffc02052fe <printnum>
ffffffffc0205368:	b7f9                	j	ffffffffc0205336 <printnum+0x38>

ffffffffc020536a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020536a:	7119                	addi	sp,sp,-128
ffffffffc020536c:	f4a6                	sd	s1,104(sp)
ffffffffc020536e:	f0ca                	sd	s2,96(sp)
ffffffffc0205370:	ecce                	sd	s3,88(sp)
ffffffffc0205372:	e8d2                	sd	s4,80(sp)
ffffffffc0205374:	e4d6                	sd	s5,72(sp)
ffffffffc0205376:	e0da                	sd	s6,64(sp)
ffffffffc0205378:	fc5e                	sd	s7,56(sp)
ffffffffc020537a:	f06a                	sd	s10,32(sp)
ffffffffc020537c:	fc86                	sd	ra,120(sp)
ffffffffc020537e:	f8a2                	sd	s0,112(sp)
ffffffffc0205380:	f862                	sd	s8,48(sp)
ffffffffc0205382:	f466                	sd	s9,40(sp)
ffffffffc0205384:	ec6e                	sd	s11,24(sp)
ffffffffc0205386:	892a                	mv	s2,a0
ffffffffc0205388:	84ae                	mv	s1,a1
ffffffffc020538a:	8d32                	mv	s10,a2
ffffffffc020538c:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020538e:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0205392:	5b7d                	li	s6,-1
ffffffffc0205394:	00002a97          	auipc	s5,0x2
ffffffffc0205398:	408a8a93          	addi	s5,s5,1032 # ffffffffc020779c <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020539c:	00002b97          	auipc	s7,0x2
ffffffffc02053a0:	61cb8b93          	addi	s7,s7,1564 # ffffffffc02079b8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02053a4:	000d4503          	lbu	a0,0(s10)
ffffffffc02053a8:	001d0413          	addi	s0,s10,1
ffffffffc02053ac:	01350a63          	beq	a0,s3,ffffffffc02053c0 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02053b0:	c121                	beqz	a0,ffffffffc02053f0 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02053b2:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02053b4:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02053b6:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02053b8:	fff44503          	lbu	a0,-1(s0)
ffffffffc02053bc:	ff351ae3          	bne	a0,s3,ffffffffc02053b0 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02053c0:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02053c4:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02053c8:	4c81                	li	s9,0
ffffffffc02053ca:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02053cc:	5c7d                	li	s8,-1
ffffffffc02053ce:	5dfd                	li	s11,-1
ffffffffc02053d0:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02053d4:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02053d6:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02053da:	0ff5f593          	zext.b	a1,a1
ffffffffc02053de:	00140d13          	addi	s10,s0,1
ffffffffc02053e2:	04b56263          	bltu	a0,a1,ffffffffc0205426 <vprintfmt+0xbc>
ffffffffc02053e6:	058a                	slli	a1,a1,0x2
ffffffffc02053e8:	95d6                	add	a1,a1,s5
ffffffffc02053ea:	4194                	lw	a3,0(a1)
ffffffffc02053ec:	96d6                	add	a3,a3,s5
ffffffffc02053ee:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02053f0:	70e6                	ld	ra,120(sp)
ffffffffc02053f2:	7446                	ld	s0,112(sp)
ffffffffc02053f4:	74a6                	ld	s1,104(sp)
ffffffffc02053f6:	7906                	ld	s2,96(sp)
ffffffffc02053f8:	69e6                	ld	s3,88(sp)
ffffffffc02053fa:	6a46                	ld	s4,80(sp)
ffffffffc02053fc:	6aa6                	ld	s5,72(sp)
ffffffffc02053fe:	6b06                	ld	s6,64(sp)
ffffffffc0205400:	7be2                	ld	s7,56(sp)
ffffffffc0205402:	7c42                	ld	s8,48(sp)
ffffffffc0205404:	7ca2                	ld	s9,40(sp)
ffffffffc0205406:	7d02                	ld	s10,32(sp)
ffffffffc0205408:	6de2                	ld	s11,24(sp)
ffffffffc020540a:	6109                	addi	sp,sp,128
ffffffffc020540c:	8082                	ret
            padc = '0';
ffffffffc020540e:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0205410:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205414:	846a                	mv	s0,s10
ffffffffc0205416:	00140d13          	addi	s10,s0,1
ffffffffc020541a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020541e:	0ff5f593          	zext.b	a1,a1
ffffffffc0205422:	fcb572e3          	bgeu	a0,a1,ffffffffc02053e6 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0205426:	85a6                	mv	a1,s1
ffffffffc0205428:	02500513          	li	a0,37
ffffffffc020542c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020542e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0205432:	8d22                	mv	s10,s0
ffffffffc0205434:	f73788e3          	beq	a5,s3,ffffffffc02053a4 <vprintfmt+0x3a>
ffffffffc0205438:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020543c:	1d7d                	addi	s10,s10,-1
ffffffffc020543e:	ff379de3          	bne	a5,s3,ffffffffc0205438 <vprintfmt+0xce>
ffffffffc0205442:	b78d                	j	ffffffffc02053a4 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0205444:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0205448:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020544c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020544e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0205452:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0205456:	02d86463          	bltu	a6,a3,ffffffffc020547e <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020545a:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020545e:	002c169b          	slliw	a3,s8,0x2
ffffffffc0205462:	0186873b          	addw	a4,a3,s8
ffffffffc0205466:	0017171b          	slliw	a4,a4,0x1
ffffffffc020546a:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020546c:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0205470:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0205472:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0205476:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020547a:	fed870e3          	bgeu	a6,a3,ffffffffc020545a <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020547e:	f40ddce3          	bgez	s11,ffffffffc02053d6 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0205482:	8de2                	mv	s11,s8
ffffffffc0205484:	5c7d                	li	s8,-1
ffffffffc0205486:	bf81                	j	ffffffffc02053d6 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0205488:	fffdc693          	not	a3,s11
ffffffffc020548c:	96fd                	srai	a3,a3,0x3f
ffffffffc020548e:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205492:	00144603          	lbu	a2,1(s0)
ffffffffc0205496:	2d81                	sext.w	s11,s11
ffffffffc0205498:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020549a:	bf35                	j	ffffffffc02053d6 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020549c:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02054a0:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02054a4:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02054a6:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02054a8:	bfd9                	j	ffffffffc020547e <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02054aa:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02054ac:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02054b0:	01174463          	blt	a4,a7,ffffffffc02054b8 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02054b4:	1a088e63          	beqz	a7,ffffffffc0205670 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02054b8:	000a3603          	ld	a2,0(s4)
ffffffffc02054bc:	46c1                	li	a3,16
ffffffffc02054be:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02054c0:	2781                	sext.w	a5,a5
ffffffffc02054c2:	876e                	mv	a4,s11
ffffffffc02054c4:	85a6                	mv	a1,s1
ffffffffc02054c6:	854a                	mv	a0,s2
ffffffffc02054c8:	e37ff0ef          	jal	ra,ffffffffc02052fe <printnum>
            break;
ffffffffc02054cc:	bde1                	j	ffffffffc02053a4 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02054ce:	000a2503          	lw	a0,0(s4)
ffffffffc02054d2:	85a6                	mv	a1,s1
ffffffffc02054d4:	0a21                	addi	s4,s4,8
ffffffffc02054d6:	9902                	jalr	s2
            break;
ffffffffc02054d8:	b5f1                	j	ffffffffc02053a4 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02054da:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02054dc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02054e0:	01174463          	blt	a4,a7,ffffffffc02054e8 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02054e4:	18088163          	beqz	a7,ffffffffc0205666 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02054e8:	000a3603          	ld	a2,0(s4)
ffffffffc02054ec:	46a9                	li	a3,10
ffffffffc02054ee:	8a2e                	mv	s4,a1
ffffffffc02054f0:	bfc1                	j	ffffffffc02054c0 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02054f2:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02054f6:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02054f8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02054fa:	bdf1                	j	ffffffffc02053d6 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02054fc:	85a6                	mv	a1,s1
ffffffffc02054fe:	02500513          	li	a0,37
ffffffffc0205502:	9902                	jalr	s2
            break;
ffffffffc0205504:	b545                	j	ffffffffc02053a4 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205506:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020550a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020550c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020550e:	b5e1                	j	ffffffffc02053d6 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0205510:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205512:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205516:	01174463          	blt	a4,a7,ffffffffc020551e <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020551a:	14088163          	beqz	a7,ffffffffc020565c <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020551e:	000a3603          	ld	a2,0(s4)
ffffffffc0205522:	46a1                	li	a3,8
ffffffffc0205524:	8a2e                	mv	s4,a1
ffffffffc0205526:	bf69                	j	ffffffffc02054c0 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0205528:	03000513          	li	a0,48
ffffffffc020552c:	85a6                	mv	a1,s1
ffffffffc020552e:	e03e                	sd	a5,0(sp)
ffffffffc0205530:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0205532:	85a6                	mv	a1,s1
ffffffffc0205534:	07800513          	li	a0,120
ffffffffc0205538:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020553a:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020553c:	6782                	ld	a5,0(sp)
ffffffffc020553e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0205540:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0205544:	bfb5                	j	ffffffffc02054c0 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0205546:	000a3403          	ld	s0,0(s4)
ffffffffc020554a:	008a0713          	addi	a4,s4,8
ffffffffc020554e:	e03a                	sd	a4,0(sp)
ffffffffc0205550:	14040263          	beqz	s0,ffffffffc0205694 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0205554:	0fb05763          	blez	s11,ffffffffc0205642 <vprintfmt+0x2d8>
ffffffffc0205558:	02d00693          	li	a3,45
ffffffffc020555c:	0cd79163          	bne	a5,a3,ffffffffc020561e <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205560:	00044783          	lbu	a5,0(s0)
ffffffffc0205564:	0007851b          	sext.w	a0,a5
ffffffffc0205568:	cf85                	beqz	a5,ffffffffc02055a0 <vprintfmt+0x236>
ffffffffc020556a:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020556e:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205572:	000c4563          	bltz	s8,ffffffffc020557c <vprintfmt+0x212>
ffffffffc0205576:	3c7d                	addiw	s8,s8,-1
ffffffffc0205578:	036c0263          	beq	s8,s6,ffffffffc020559c <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020557c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020557e:	0e0c8e63          	beqz	s9,ffffffffc020567a <vprintfmt+0x310>
ffffffffc0205582:	3781                	addiw	a5,a5,-32
ffffffffc0205584:	0ef47b63          	bgeu	s0,a5,ffffffffc020567a <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0205588:	03f00513          	li	a0,63
ffffffffc020558c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020558e:	000a4783          	lbu	a5,0(s4)
ffffffffc0205592:	3dfd                	addiw	s11,s11,-1
ffffffffc0205594:	0a05                	addi	s4,s4,1
ffffffffc0205596:	0007851b          	sext.w	a0,a5
ffffffffc020559a:	ffe1                	bnez	a5,ffffffffc0205572 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc020559c:	01b05963          	blez	s11,ffffffffc02055ae <vprintfmt+0x244>
ffffffffc02055a0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02055a2:	85a6                	mv	a1,s1
ffffffffc02055a4:	02000513          	li	a0,32
ffffffffc02055a8:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02055aa:	fe0d9be3          	bnez	s11,ffffffffc02055a0 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02055ae:	6a02                	ld	s4,0(sp)
ffffffffc02055b0:	bbd5                	j	ffffffffc02053a4 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02055b2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02055b4:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02055b8:	01174463          	blt	a4,a7,ffffffffc02055c0 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02055bc:	08088d63          	beqz	a7,ffffffffc0205656 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02055c0:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02055c4:	0a044d63          	bltz	s0,ffffffffc020567e <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02055c8:	8622                	mv	a2,s0
ffffffffc02055ca:	8a66                	mv	s4,s9
ffffffffc02055cc:	46a9                	li	a3,10
ffffffffc02055ce:	bdcd                	j	ffffffffc02054c0 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02055d0:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02055d4:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02055d6:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02055d8:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02055dc:	8fb5                	xor	a5,a5,a3
ffffffffc02055de:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02055e2:	02d74163          	blt	a4,a3,ffffffffc0205604 <vprintfmt+0x29a>
ffffffffc02055e6:	00369793          	slli	a5,a3,0x3
ffffffffc02055ea:	97de                	add	a5,a5,s7
ffffffffc02055ec:	639c                	ld	a5,0(a5)
ffffffffc02055ee:	cb99                	beqz	a5,ffffffffc0205604 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02055f0:	86be                	mv	a3,a5
ffffffffc02055f2:	00000617          	auipc	a2,0x0
ffffffffc02055f6:	1ee60613          	addi	a2,a2,494 # ffffffffc02057e0 <etext+0x28>
ffffffffc02055fa:	85a6                	mv	a1,s1
ffffffffc02055fc:	854a                	mv	a0,s2
ffffffffc02055fe:	0ce000ef          	jal	ra,ffffffffc02056cc <printfmt>
ffffffffc0205602:	b34d                	j	ffffffffc02053a4 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0205604:	00002617          	auipc	a2,0x2
ffffffffc0205608:	18c60613          	addi	a2,a2,396 # ffffffffc0207790 <syscalls+0x120>
ffffffffc020560c:	85a6                	mv	a1,s1
ffffffffc020560e:	854a                	mv	a0,s2
ffffffffc0205610:	0bc000ef          	jal	ra,ffffffffc02056cc <printfmt>
ffffffffc0205614:	bb41                	j	ffffffffc02053a4 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0205616:	00002417          	auipc	s0,0x2
ffffffffc020561a:	17240413          	addi	s0,s0,370 # ffffffffc0207788 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020561e:	85e2                	mv	a1,s8
ffffffffc0205620:	8522                	mv	a0,s0
ffffffffc0205622:	e43e                	sd	a5,8(sp)
ffffffffc0205624:	0e2000ef          	jal	ra,ffffffffc0205706 <strnlen>
ffffffffc0205628:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020562c:	01b05b63          	blez	s11,ffffffffc0205642 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0205630:	67a2                	ld	a5,8(sp)
ffffffffc0205632:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205636:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0205638:	85a6                	mv	a1,s1
ffffffffc020563a:	8552                	mv	a0,s4
ffffffffc020563c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020563e:	fe0d9ce3          	bnez	s11,ffffffffc0205636 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205642:	00044783          	lbu	a5,0(s0)
ffffffffc0205646:	00140a13          	addi	s4,s0,1
ffffffffc020564a:	0007851b          	sext.w	a0,a5
ffffffffc020564e:	d3a5                	beqz	a5,ffffffffc02055ae <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205650:	05e00413          	li	s0,94
ffffffffc0205654:	bf39                	j	ffffffffc0205572 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0205656:	000a2403          	lw	s0,0(s4)
ffffffffc020565a:	b7ad                	j	ffffffffc02055c4 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020565c:	000a6603          	lwu	a2,0(s4)
ffffffffc0205660:	46a1                	li	a3,8
ffffffffc0205662:	8a2e                	mv	s4,a1
ffffffffc0205664:	bdb1                	j	ffffffffc02054c0 <vprintfmt+0x156>
ffffffffc0205666:	000a6603          	lwu	a2,0(s4)
ffffffffc020566a:	46a9                	li	a3,10
ffffffffc020566c:	8a2e                	mv	s4,a1
ffffffffc020566e:	bd89                	j	ffffffffc02054c0 <vprintfmt+0x156>
ffffffffc0205670:	000a6603          	lwu	a2,0(s4)
ffffffffc0205674:	46c1                	li	a3,16
ffffffffc0205676:	8a2e                	mv	s4,a1
ffffffffc0205678:	b5a1                	j	ffffffffc02054c0 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020567a:	9902                	jalr	s2
ffffffffc020567c:	bf09                	j	ffffffffc020558e <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020567e:	85a6                	mv	a1,s1
ffffffffc0205680:	02d00513          	li	a0,45
ffffffffc0205684:	e03e                	sd	a5,0(sp)
ffffffffc0205686:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0205688:	6782                	ld	a5,0(sp)
ffffffffc020568a:	8a66                	mv	s4,s9
ffffffffc020568c:	40800633          	neg	a2,s0
ffffffffc0205690:	46a9                	li	a3,10
ffffffffc0205692:	b53d                	j	ffffffffc02054c0 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0205694:	03b05163          	blez	s11,ffffffffc02056b6 <vprintfmt+0x34c>
ffffffffc0205698:	02d00693          	li	a3,45
ffffffffc020569c:	f6d79de3          	bne	a5,a3,ffffffffc0205616 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02056a0:	00002417          	auipc	s0,0x2
ffffffffc02056a4:	0e840413          	addi	s0,s0,232 # ffffffffc0207788 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02056a8:	02800793          	li	a5,40
ffffffffc02056ac:	02800513          	li	a0,40
ffffffffc02056b0:	00140a13          	addi	s4,s0,1
ffffffffc02056b4:	bd6d                	j	ffffffffc020556e <vprintfmt+0x204>
ffffffffc02056b6:	00002a17          	auipc	s4,0x2
ffffffffc02056ba:	0d3a0a13          	addi	s4,s4,211 # ffffffffc0207789 <syscalls+0x119>
ffffffffc02056be:	02800513          	li	a0,40
ffffffffc02056c2:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02056c6:	05e00413          	li	s0,94
ffffffffc02056ca:	b565                	j	ffffffffc0205572 <vprintfmt+0x208>

ffffffffc02056cc <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02056cc:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02056ce:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02056d2:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02056d4:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02056d6:	ec06                	sd	ra,24(sp)
ffffffffc02056d8:	f83a                	sd	a4,48(sp)
ffffffffc02056da:	fc3e                	sd	a5,56(sp)
ffffffffc02056dc:	e0c2                	sd	a6,64(sp)
ffffffffc02056de:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02056e0:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02056e2:	c89ff0ef          	jal	ra,ffffffffc020536a <vprintfmt>
}
ffffffffc02056e6:	60e2                	ld	ra,24(sp)
ffffffffc02056e8:	6161                	addi	sp,sp,80
ffffffffc02056ea:	8082                	ret

ffffffffc02056ec <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02056ec:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02056f0:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02056f2:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02056f4:	cb81                	beqz	a5,ffffffffc0205704 <strlen+0x18>
        cnt ++;
ffffffffc02056f6:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02056f8:	00a707b3          	add	a5,a4,a0
ffffffffc02056fc:	0007c783          	lbu	a5,0(a5)
ffffffffc0205700:	fbfd                	bnez	a5,ffffffffc02056f6 <strlen+0xa>
ffffffffc0205702:	8082                	ret
    }
    return cnt;
}
ffffffffc0205704:	8082                	ret

ffffffffc0205706 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0205706:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205708:	e589                	bnez	a1,ffffffffc0205712 <strnlen+0xc>
ffffffffc020570a:	a811                	j	ffffffffc020571e <strnlen+0x18>
        cnt ++;
ffffffffc020570c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020570e:	00f58863          	beq	a1,a5,ffffffffc020571e <strnlen+0x18>
ffffffffc0205712:	00f50733          	add	a4,a0,a5
ffffffffc0205716:	00074703          	lbu	a4,0(a4)
ffffffffc020571a:	fb6d                	bnez	a4,ffffffffc020570c <strnlen+0x6>
ffffffffc020571c:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020571e:	852e                	mv	a0,a1
ffffffffc0205720:	8082                	ret

ffffffffc0205722 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0205722:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0205724:	0005c703          	lbu	a4,0(a1)
ffffffffc0205728:	0785                	addi	a5,a5,1
ffffffffc020572a:	0585                	addi	a1,a1,1
ffffffffc020572c:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0205730:	fb75                	bnez	a4,ffffffffc0205724 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0205732:	8082                	ret

ffffffffc0205734 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205734:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205738:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020573c:	cb89                	beqz	a5,ffffffffc020574e <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc020573e:	0505                	addi	a0,a0,1
ffffffffc0205740:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205742:	fee789e3          	beq	a5,a4,ffffffffc0205734 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205746:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020574a:	9d19                	subw	a0,a0,a4
ffffffffc020574c:	8082                	ret
ffffffffc020574e:	4501                	li	a0,0
ffffffffc0205750:	bfed                	j	ffffffffc020574a <strcmp+0x16>

ffffffffc0205752 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205752:	c20d                	beqz	a2,ffffffffc0205774 <strncmp+0x22>
ffffffffc0205754:	962e                	add	a2,a2,a1
ffffffffc0205756:	a031                	j	ffffffffc0205762 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0205758:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020575a:	00e79a63          	bne	a5,a4,ffffffffc020576e <strncmp+0x1c>
ffffffffc020575e:	00b60b63          	beq	a2,a1,ffffffffc0205774 <strncmp+0x22>
ffffffffc0205762:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0205766:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205768:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020576c:	f7f5                	bnez	a5,ffffffffc0205758 <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020576e:	40e7853b          	subw	a0,a5,a4
}
ffffffffc0205772:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205774:	4501                	li	a0,0
ffffffffc0205776:	8082                	ret

ffffffffc0205778 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0205778:	00054783          	lbu	a5,0(a0)
ffffffffc020577c:	c799                	beqz	a5,ffffffffc020578a <strchr+0x12>
        if (*s == c) {
ffffffffc020577e:	00f58763          	beq	a1,a5,ffffffffc020578c <strchr+0x14>
    while (*s != '\0') {
ffffffffc0205782:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0205786:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0205788:	fbfd                	bnez	a5,ffffffffc020577e <strchr+0x6>
    }
    return NULL;
ffffffffc020578a:	4501                	li	a0,0
}
ffffffffc020578c:	8082                	ret

ffffffffc020578e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020578e:	ca01                	beqz	a2,ffffffffc020579e <memset+0x10>
ffffffffc0205790:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0205792:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0205794:	0785                	addi	a5,a5,1
ffffffffc0205796:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020579a:	fec79de3          	bne	a5,a2,ffffffffc0205794 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020579e:	8082                	ret

ffffffffc02057a0 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02057a0:	ca19                	beqz	a2,ffffffffc02057b6 <memcpy+0x16>
ffffffffc02057a2:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02057a4:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02057a6:	0005c703          	lbu	a4,0(a1)
ffffffffc02057aa:	0585                	addi	a1,a1,1
ffffffffc02057ac:	0785                	addi	a5,a5,1
ffffffffc02057ae:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02057b2:	fec59ae3          	bne	a1,a2,ffffffffc02057a6 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02057b6:	8082                	ret
