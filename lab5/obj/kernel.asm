
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
ffffffffc0200062:	590050ef          	jal	ra,ffffffffc02055f2 <memset>
    dtb_init();
ffffffffc0200066:	598000ef          	jal	ra,ffffffffc02005fe <dtb_init>
    cons_init(); // init the console
ffffffffc020006a:	522000ef          	jal	ra,ffffffffc020058c <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006e:	00005597          	auipc	a1,0x5
ffffffffc0200072:	5b258593          	addi	a1,a1,1458 # ffffffffc0205620 <etext+0x4>
ffffffffc0200076:	00005517          	auipc	a0,0x5
ffffffffc020007a:	5ca50513          	addi	a0,a0,1482 # ffffffffc0205640 <etext+0x24>
ffffffffc020007e:	116000ef          	jal	ra,ffffffffc0200194 <cprintf>

    print_kerninfo();
ffffffffc0200082:	19a000ef          	jal	ra,ffffffffc020021c <print_kerninfo>

    // grade_backtrace();

    pmm_init(); // init physical memory management
ffffffffc0200086:	08f020ef          	jal	ra,ffffffffc0202914 <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	131000ef          	jal	ra,ffffffffc02009ba <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	12f000ef          	jal	ra,ffffffffc02009bc <idt_init>

    vmm_init();  // init virtual memory management
ffffffffc0200092:	0fb030ef          	jal	ra,ffffffffc020398c <vmm_init>
    proc_init(); // init process table
ffffffffc0200096:	499040ef          	jal	ra,ffffffffc0204d2e <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009a:	4a0000ef          	jal	ra,ffffffffc020053a <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc020009e:	111000ef          	jal	ra,ffffffffc02009ae <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a2:	63b040ef          	jal	ra,ffffffffc0204edc <cpu_idle>

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
ffffffffc02000c0:	58c50513          	addi	a0,a0,1420 # ffffffffc0205648 <etext+0x2c>
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
ffffffffc0200188:	046050ef          	jal	ra,ffffffffc02051ce <vprintfmt>
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
ffffffffc02001be:	010050ef          	jal	ra,ffffffffc02051ce <vprintfmt>
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
ffffffffc0200222:	43250513          	addi	a0,a0,1074 # ffffffffc0205650 <etext+0x34>
{
ffffffffc0200226:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200228:	f6dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020022c:	00000597          	auipc	a1,0x0
ffffffffc0200230:	e1e58593          	addi	a1,a1,-482 # ffffffffc020004a <kern_init>
ffffffffc0200234:	00005517          	auipc	a0,0x5
ffffffffc0200238:	43c50513          	addi	a0,a0,1084 # ffffffffc0205670 <etext+0x54>
ffffffffc020023c:	f59ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200240:	00005597          	auipc	a1,0x5
ffffffffc0200244:	3dc58593          	addi	a1,a1,988 # ffffffffc020561c <etext>
ffffffffc0200248:	00005517          	auipc	a0,0x5
ffffffffc020024c:	44850513          	addi	a0,a0,1096 # ffffffffc0205690 <etext+0x74>
ffffffffc0200250:	f45ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200254:	000a6597          	auipc	a1,0xa6
ffffffffc0200258:	ffc58593          	addi	a1,a1,-4 # ffffffffc02a6250 <buf>
ffffffffc020025c:	00005517          	auipc	a0,0x5
ffffffffc0200260:	45450513          	addi	a0,a0,1108 # ffffffffc02056b0 <etext+0x94>
ffffffffc0200264:	f31ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200268:	000aa597          	auipc	a1,0xaa
ffffffffc020026c:	49458593          	addi	a1,a1,1172 # ffffffffc02aa6fc <end>
ffffffffc0200270:	00005517          	auipc	a0,0x5
ffffffffc0200274:	46050513          	addi	a0,a0,1120 # ffffffffc02056d0 <etext+0xb4>
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
ffffffffc02002a2:	45250513          	addi	a0,a0,1106 # ffffffffc02056f0 <etext+0xd4>
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
ffffffffc02002b0:	47460613          	addi	a2,a2,1140 # ffffffffc0205720 <etext+0x104>
ffffffffc02002b4:	04f00593          	li	a1,79
ffffffffc02002b8:	00005517          	auipc	a0,0x5
ffffffffc02002bc:	48050513          	addi	a0,a0,1152 # ffffffffc0205738 <etext+0x11c>
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
ffffffffc02002cc:	48860613          	addi	a2,a2,1160 # ffffffffc0205750 <etext+0x134>
ffffffffc02002d0:	00005597          	auipc	a1,0x5
ffffffffc02002d4:	4a058593          	addi	a1,a1,1184 # ffffffffc0205770 <etext+0x154>
ffffffffc02002d8:	00005517          	auipc	a0,0x5
ffffffffc02002dc:	4a050513          	addi	a0,a0,1184 # ffffffffc0205778 <etext+0x15c>
{
ffffffffc02002e0:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e2:	eb3ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02002e6:	00005617          	auipc	a2,0x5
ffffffffc02002ea:	4a260613          	addi	a2,a2,1186 # ffffffffc0205788 <etext+0x16c>
ffffffffc02002ee:	00005597          	auipc	a1,0x5
ffffffffc02002f2:	4c258593          	addi	a1,a1,1218 # ffffffffc02057b0 <etext+0x194>
ffffffffc02002f6:	00005517          	auipc	a0,0x5
ffffffffc02002fa:	48250513          	addi	a0,a0,1154 # ffffffffc0205778 <etext+0x15c>
ffffffffc02002fe:	e97ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200302:	00005617          	auipc	a2,0x5
ffffffffc0200306:	4be60613          	addi	a2,a2,1214 # ffffffffc02057c0 <etext+0x1a4>
ffffffffc020030a:	00005597          	auipc	a1,0x5
ffffffffc020030e:	4d658593          	addi	a1,a1,1238 # ffffffffc02057e0 <etext+0x1c4>
ffffffffc0200312:	00005517          	auipc	a0,0x5
ffffffffc0200316:	46650513          	addi	a0,a0,1126 # ffffffffc0205778 <etext+0x15c>
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
ffffffffc0200350:	4a450513          	addi	a0,a0,1188 # ffffffffc02057f0 <etext+0x1d4>
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
ffffffffc0200372:	4aa50513          	addi	a0,a0,1194 # ffffffffc0205818 <etext+0x1fc>
ffffffffc0200376:	e1fff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    if (tf != NULL)
ffffffffc020037a:	000b8563          	beqz	s7,ffffffffc0200384 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020037e:	855e                	mv	a0,s7
ffffffffc0200380:	025000ef          	jal	ra,ffffffffc0200ba4 <print_trapframe>
ffffffffc0200384:	00005c17          	auipc	s8,0x5
ffffffffc0200388:	504c0c13          	addi	s8,s8,1284 # ffffffffc0205888 <commands>
        if ((buf = readline("K> ")) != NULL)
ffffffffc020038c:	00005917          	auipc	s2,0x5
ffffffffc0200390:	4b490913          	addi	s2,s2,1204 # ffffffffc0205840 <etext+0x224>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200394:	00005497          	auipc	s1,0x5
ffffffffc0200398:	4b448493          	addi	s1,s1,1204 # ffffffffc0205848 <etext+0x22c>
        if (argc == MAXARGS - 1)
ffffffffc020039c:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020039e:	00005b17          	auipc	s6,0x5
ffffffffc02003a2:	4b2b0b13          	addi	s6,s6,1202 # ffffffffc0205850 <etext+0x234>
        argv[argc++] = buf;
ffffffffc02003a6:	00005a17          	auipc	s4,0x5
ffffffffc02003aa:	3caa0a13          	addi	s4,s4,970 # ffffffffc0205770 <etext+0x154>
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
ffffffffc02003cc:	4c0d0d13          	addi	s10,s10,1216 # ffffffffc0205888 <commands>
        argv[argc++] = buf;
ffffffffc02003d0:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc02003d2:	4401                	li	s0,0
ffffffffc02003d4:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc02003d6:	1c2050ef          	jal	ra,ffffffffc0205598 <strcmp>
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
ffffffffc02003ea:	1ae050ef          	jal	ra,ffffffffc0205598 <strcmp>
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
ffffffffc0200428:	1b4050ef          	jal	ra,ffffffffc02055dc <strchr>
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
ffffffffc0200466:	176050ef          	jal	ra,ffffffffc02055dc <strchr>
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
ffffffffc0200484:	3f050513          	addi	a0,a0,1008 # ffffffffc0205870 <etext+0x254>
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
ffffffffc02004c0:	41450513          	addi	a0,a0,1044 # ffffffffc02058d0 <commands+0x48>
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
ffffffffc02004d6:	55e50513          	addi	a0,a0,1374 # ffffffffc0206a30 <default_pmm_manager+0x598>
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
ffffffffc020050a:	3ea50513          	addi	a0,a0,1002 # ffffffffc02058f0 <commands+0x68>
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
ffffffffc020052a:	50a50513          	addi	a0,a0,1290 # ffffffffc0206a30 <default_pmm_manager+0x598>
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
ffffffffc0200564:	3b050513          	addi	a0,a0,944 # ffffffffc0205910 <commands+0x88>
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
ffffffffc0200604:	33050513          	addi	a0,a0,816 # ffffffffc0205930 <commands+0xa8>
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
ffffffffc0200632:	31250513          	addi	a0,a0,786 # ffffffffc0205940 <commands+0xb8>
ffffffffc0200636:	b5fff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020063a:	0000b417          	auipc	s0,0xb
ffffffffc020063e:	9ce40413          	addi	s0,s0,-1586 # ffffffffc020b008 <boot_dtb>
ffffffffc0200642:	600c                	ld	a1,0(s0)
ffffffffc0200644:	00005517          	auipc	a0,0x5
ffffffffc0200648:	30c50513          	addi	a0,a0,780 # ffffffffc0205950 <commands+0xc8>
ffffffffc020064c:	b49ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200650:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200654:	00005517          	auipc	a0,0x5
ffffffffc0200658:	31450513          	addi	a0,a0,788 # ffffffffc0205968 <commands+0xe0>
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
ffffffffc0200712:	2aa90913          	addi	s2,s2,682 # ffffffffc02059b8 <commands+0x130>
ffffffffc0200716:	49bd                	li	s3,15
        switch (token) {
ffffffffc0200718:	4d91                	li	s11,4
ffffffffc020071a:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020071c:	00005497          	auipc	s1,0x5
ffffffffc0200720:	29448493          	addi	s1,s1,660 # ffffffffc02059b0 <commands+0x128>
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
ffffffffc0200774:	2c050513          	addi	a0,a0,704 # ffffffffc0205a30 <commands+0x1a8>
ffffffffc0200778:	a1dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc020077c:	00005517          	auipc	a0,0x5
ffffffffc0200780:	2ec50513          	addi	a0,a0,748 # ffffffffc0205a68 <commands+0x1e0>
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
ffffffffc02007c0:	1cc50513          	addi	a0,a0,460 # ffffffffc0205988 <commands+0x100>
}
ffffffffc02007c4:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02007c6:	b2f9                	j	ffffffffc0200194 <cprintf>
                int name_len = strlen(name);
ffffffffc02007c8:	8556                	mv	a0,s5
ffffffffc02007ca:	587040ef          	jal	ra,ffffffffc0205550 <strlen>
ffffffffc02007ce:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02007d0:	4619                	li	a2,6
ffffffffc02007d2:	85a6                	mv	a1,s1
ffffffffc02007d4:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02007d6:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02007d8:	5df040ef          	jal	ra,ffffffffc02055b6 <strncmp>
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
ffffffffc020086e:	52b040ef          	jal	ra,ffffffffc0205598 <strcmp>
ffffffffc0200872:	66a2                	ld	a3,8(sp)
ffffffffc0200874:	f94d                	bnez	a0,ffffffffc0200826 <dtb_init+0x228>
ffffffffc0200876:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200826 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc020087a:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc020087e:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200882:	00005517          	auipc	a0,0x5
ffffffffc0200886:	13e50513          	addi	a0,a0,318 # ffffffffc02059c0 <commands+0x138>
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
ffffffffc0200954:	09050513          	addi	a0,a0,144 # ffffffffc02059e0 <commands+0x158>
ffffffffc0200958:	83dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020095c:	014b5613          	srli	a2,s6,0x14
ffffffffc0200960:	85da                	mv	a1,s6
ffffffffc0200962:	00005517          	auipc	a0,0x5
ffffffffc0200966:	09650513          	addi	a0,a0,150 # ffffffffc02059f8 <commands+0x170>
ffffffffc020096a:	82bff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc020096e:	008b05b3          	add	a1,s6,s0
ffffffffc0200972:	15fd                	addi	a1,a1,-1
ffffffffc0200974:	00005517          	auipc	a0,0x5
ffffffffc0200978:	0a450513          	addi	a0,a0,164 # ffffffffc0205a18 <commands+0x190>
ffffffffc020097c:	819ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("DTB init completed\n");
ffffffffc0200980:	00005517          	auipc	a0,0x5
ffffffffc0200984:	0e850513          	addi	a0,a0,232 # ffffffffc0205a68 <commands+0x1e0>
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
ffffffffc02009e2:	0a250513          	addi	a0,a0,162 # ffffffffc0205a80 <commands+0x1f8>
{
ffffffffc02009e6:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009e8:	facff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02009ec:	640c                	ld	a1,8(s0)
ffffffffc02009ee:	00005517          	auipc	a0,0x5
ffffffffc02009f2:	0aa50513          	addi	a0,a0,170 # ffffffffc0205a98 <commands+0x210>
ffffffffc02009f6:	f9eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02009fa:	680c                	ld	a1,16(s0)
ffffffffc02009fc:	00005517          	auipc	a0,0x5
ffffffffc0200a00:	0b450513          	addi	a0,a0,180 # ffffffffc0205ab0 <commands+0x228>
ffffffffc0200a04:	f90ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200a08:	6c0c                	ld	a1,24(s0)
ffffffffc0200a0a:	00005517          	auipc	a0,0x5
ffffffffc0200a0e:	0be50513          	addi	a0,a0,190 # ffffffffc0205ac8 <commands+0x240>
ffffffffc0200a12:	f82ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200a16:	700c                	ld	a1,32(s0)
ffffffffc0200a18:	00005517          	auipc	a0,0x5
ffffffffc0200a1c:	0c850513          	addi	a0,a0,200 # ffffffffc0205ae0 <commands+0x258>
ffffffffc0200a20:	f74ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200a24:	740c                	ld	a1,40(s0)
ffffffffc0200a26:	00005517          	auipc	a0,0x5
ffffffffc0200a2a:	0d250513          	addi	a0,a0,210 # ffffffffc0205af8 <commands+0x270>
ffffffffc0200a2e:	f66ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc0200a32:	780c                	ld	a1,48(s0)
ffffffffc0200a34:	00005517          	auipc	a0,0x5
ffffffffc0200a38:	0dc50513          	addi	a0,a0,220 # ffffffffc0205b10 <commands+0x288>
ffffffffc0200a3c:	f58ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200a40:	7c0c                	ld	a1,56(s0)
ffffffffc0200a42:	00005517          	auipc	a0,0x5
ffffffffc0200a46:	0e650513          	addi	a0,a0,230 # ffffffffc0205b28 <commands+0x2a0>
ffffffffc0200a4a:	f4aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200a4e:	602c                	ld	a1,64(s0)
ffffffffc0200a50:	00005517          	auipc	a0,0x5
ffffffffc0200a54:	0f050513          	addi	a0,a0,240 # ffffffffc0205b40 <commands+0x2b8>
ffffffffc0200a58:	f3cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200a5c:	642c                	ld	a1,72(s0)
ffffffffc0200a5e:	00005517          	auipc	a0,0x5
ffffffffc0200a62:	0fa50513          	addi	a0,a0,250 # ffffffffc0205b58 <commands+0x2d0>
ffffffffc0200a66:	f2eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200a6a:	682c                	ld	a1,80(s0)
ffffffffc0200a6c:	00005517          	auipc	a0,0x5
ffffffffc0200a70:	10450513          	addi	a0,a0,260 # ffffffffc0205b70 <commands+0x2e8>
ffffffffc0200a74:	f20ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200a78:	6c2c                	ld	a1,88(s0)
ffffffffc0200a7a:	00005517          	auipc	a0,0x5
ffffffffc0200a7e:	10e50513          	addi	a0,a0,270 # ffffffffc0205b88 <commands+0x300>
ffffffffc0200a82:	f12ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200a86:	702c                	ld	a1,96(s0)
ffffffffc0200a88:	00005517          	auipc	a0,0x5
ffffffffc0200a8c:	11850513          	addi	a0,a0,280 # ffffffffc0205ba0 <commands+0x318>
ffffffffc0200a90:	f04ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200a94:	742c                	ld	a1,104(s0)
ffffffffc0200a96:	00005517          	auipc	a0,0x5
ffffffffc0200a9a:	12250513          	addi	a0,a0,290 # ffffffffc0205bb8 <commands+0x330>
ffffffffc0200a9e:	ef6ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200aa2:	782c                	ld	a1,112(s0)
ffffffffc0200aa4:	00005517          	auipc	a0,0x5
ffffffffc0200aa8:	12c50513          	addi	a0,a0,300 # ffffffffc0205bd0 <commands+0x348>
ffffffffc0200aac:	ee8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200ab0:	7c2c                	ld	a1,120(s0)
ffffffffc0200ab2:	00005517          	auipc	a0,0x5
ffffffffc0200ab6:	13650513          	addi	a0,a0,310 # ffffffffc0205be8 <commands+0x360>
ffffffffc0200aba:	edaff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200abe:	604c                	ld	a1,128(s0)
ffffffffc0200ac0:	00005517          	auipc	a0,0x5
ffffffffc0200ac4:	14050513          	addi	a0,a0,320 # ffffffffc0205c00 <commands+0x378>
ffffffffc0200ac8:	eccff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200acc:	644c                	ld	a1,136(s0)
ffffffffc0200ace:	00005517          	auipc	a0,0x5
ffffffffc0200ad2:	14a50513          	addi	a0,a0,330 # ffffffffc0205c18 <commands+0x390>
ffffffffc0200ad6:	ebeff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200ada:	684c                	ld	a1,144(s0)
ffffffffc0200adc:	00005517          	auipc	a0,0x5
ffffffffc0200ae0:	15450513          	addi	a0,a0,340 # ffffffffc0205c30 <commands+0x3a8>
ffffffffc0200ae4:	eb0ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200ae8:	6c4c                	ld	a1,152(s0)
ffffffffc0200aea:	00005517          	auipc	a0,0x5
ffffffffc0200aee:	15e50513          	addi	a0,a0,350 # ffffffffc0205c48 <commands+0x3c0>
ffffffffc0200af2:	ea2ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200af6:	704c                	ld	a1,160(s0)
ffffffffc0200af8:	00005517          	auipc	a0,0x5
ffffffffc0200afc:	16850513          	addi	a0,a0,360 # ffffffffc0205c60 <commands+0x3d8>
ffffffffc0200b00:	e94ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200b04:	744c                	ld	a1,168(s0)
ffffffffc0200b06:	00005517          	auipc	a0,0x5
ffffffffc0200b0a:	17250513          	addi	a0,a0,370 # ffffffffc0205c78 <commands+0x3f0>
ffffffffc0200b0e:	e86ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200b12:	784c                	ld	a1,176(s0)
ffffffffc0200b14:	00005517          	auipc	a0,0x5
ffffffffc0200b18:	17c50513          	addi	a0,a0,380 # ffffffffc0205c90 <commands+0x408>
ffffffffc0200b1c:	e78ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200b20:	7c4c                	ld	a1,184(s0)
ffffffffc0200b22:	00005517          	auipc	a0,0x5
ffffffffc0200b26:	18650513          	addi	a0,a0,390 # ffffffffc0205ca8 <commands+0x420>
ffffffffc0200b2a:	e6aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200b2e:	606c                	ld	a1,192(s0)
ffffffffc0200b30:	00005517          	auipc	a0,0x5
ffffffffc0200b34:	19050513          	addi	a0,a0,400 # ffffffffc0205cc0 <commands+0x438>
ffffffffc0200b38:	e5cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200b3c:	646c                	ld	a1,200(s0)
ffffffffc0200b3e:	00005517          	auipc	a0,0x5
ffffffffc0200b42:	19a50513          	addi	a0,a0,410 # ffffffffc0205cd8 <commands+0x450>
ffffffffc0200b46:	e4eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200b4a:	686c                	ld	a1,208(s0)
ffffffffc0200b4c:	00005517          	auipc	a0,0x5
ffffffffc0200b50:	1a450513          	addi	a0,a0,420 # ffffffffc0205cf0 <commands+0x468>
ffffffffc0200b54:	e40ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200b58:	6c6c                	ld	a1,216(s0)
ffffffffc0200b5a:	00005517          	auipc	a0,0x5
ffffffffc0200b5e:	1ae50513          	addi	a0,a0,430 # ffffffffc0205d08 <commands+0x480>
ffffffffc0200b62:	e32ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200b66:	706c                	ld	a1,224(s0)
ffffffffc0200b68:	00005517          	auipc	a0,0x5
ffffffffc0200b6c:	1b850513          	addi	a0,a0,440 # ffffffffc0205d20 <commands+0x498>
ffffffffc0200b70:	e24ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200b74:	746c                	ld	a1,232(s0)
ffffffffc0200b76:	00005517          	auipc	a0,0x5
ffffffffc0200b7a:	1c250513          	addi	a0,a0,450 # ffffffffc0205d38 <commands+0x4b0>
ffffffffc0200b7e:	e16ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200b82:	786c                	ld	a1,240(s0)
ffffffffc0200b84:	00005517          	auipc	a0,0x5
ffffffffc0200b88:	1cc50513          	addi	a0,a0,460 # ffffffffc0205d50 <commands+0x4c8>
ffffffffc0200b8c:	e08ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b90:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200b92:	6402                	ld	s0,0(sp)
ffffffffc0200b94:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b96:	00005517          	auipc	a0,0x5
ffffffffc0200b9a:	1d250513          	addi	a0,a0,466 # ffffffffc0205d68 <commands+0x4e0>
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
ffffffffc0200bb0:	1d450513          	addi	a0,a0,468 # ffffffffc0205d80 <commands+0x4f8>
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
ffffffffc0200bc8:	1d450513          	addi	a0,a0,468 # ffffffffc0205d98 <commands+0x510>
ffffffffc0200bcc:	dc8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200bd0:	10843583          	ld	a1,264(s0)
ffffffffc0200bd4:	00005517          	auipc	a0,0x5
ffffffffc0200bd8:	1dc50513          	addi	a0,a0,476 # ffffffffc0205db0 <commands+0x528>
ffffffffc0200bdc:	db8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200be0:	11043583          	ld	a1,272(s0)
ffffffffc0200be4:	00005517          	auipc	a0,0x5
ffffffffc0200be8:	1e450513          	addi	a0,a0,484 # ffffffffc0205dc8 <commands+0x540>
ffffffffc0200bec:	da8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bf0:	11843583          	ld	a1,280(s0)
}
ffffffffc0200bf4:	6402                	ld	s0,0(sp)
ffffffffc0200bf6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bf8:	00005517          	auipc	a0,0x5
ffffffffc0200bfc:	1e050513          	addi	a0,a0,480 # ffffffffc0205dd8 <commands+0x550>
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
ffffffffc0200c10:	06f76c63          	bltu	a4,a5,ffffffffc0200c88 <interrupt_handler+0x82>
ffffffffc0200c14:	00005717          	auipc	a4,0x5
ffffffffc0200c18:	28c70713          	addi	a4,a4,652 # ffffffffc0205ea0 <commands+0x618>
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
ffffffffc0200c2a:	22a50513          	addi	a0,a0,554 # ffffffffc0205e50 <commands+0x5c8>
ffffffffc0200c2e:	d66ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200c32:	00005517          	auipc	a0,0x5
ffffffffc0200c36:	1fe50513          	addi	a0,a0,510 # ffffffffc0205e30 <commands+0x5a8>
ffffffffc0200c3a:	d5aff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200c3e:	00005517          	auipc	a0,0x5
ffffffffc0200c42:	1b250513          	addi	a0,a0,434 # ffffffffc0205df0 <commands+0x568>
ffffffffc0200c46:	d4eff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200c4a:	00005517          	auipc	a0,0x5
ffffffffc0200c4e:	1c650513          	addi	a0,a0,454 # ffffffffc0205e10 <commands+0x588>
ffffffffc0200c52:	d42ff06f          	j	ffffffffc0200194 <cprintf>
{
ffffffffc0200c56:	1141                	addi	sp,sp,-16
ffffffffc0200c58:	e406                	sd	ra,8(sp)
        /*(1)设置下次时钟中断- clock_set_next_event()
         *(2)计数器（ticks）加一
         *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
         * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
         */
        clock_set_next_event();//发生这次时钟中断的时候，我们要设置下一次时钟中断
ffffffffc0200c5a:	919ff0ef          	jal	ra,ffffffffc0200572 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200c5e:	000aa697          	auipc	a3,0xaa
ffffffffc0200c62:	a2268693          	addi	a3,a3,-1502 # ffffffffc02aa680 <ticks>
ffffffffc0200c66:	629c                	ld	a5,0(a3)
ffffffffc0200c68:	06400713          	li	a4,100
ffffffffc0200c6c:	0785                	addi	a5,a5,1
ffffffffc0200c6e:	02e7f733          	remu	a4,a5,a4
ffffffffc0200c72:	e29c                	sd	a5,0(a3)
ffffffffc0200c74:	cb19                	beqz	a4,ffffffffc0200c8a <interrupt_handler+0x84>
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200c76:	60a2                	ld	ra,8(sp)
ffffffffc0200c78:	0141                	addi	sp,sp,16
ffffffffc0200c7a:	8082                	ret
        cprintf("Supervisor external interrupt\n");
ffffffffc0200c7c:	00005517          	auipc	a0,0x5
ffffffffc0200c80:	20450513          	addi	a0,a0,516 # ffffffffc0205e80 <commands+0x5f8>
ffffffffc0200c84:	d10ff06f          	j	ffffffffc0200194 <cprintf>
        print_trapframe(tf);
ffffffffc0200c88:	bf31                	j	ffffffffc0200ba4 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200c8a:	06400593          	li	a1,100
ffffffffc0200c8e:	00005517          	auipc	a0,0x5
ffffffffc0200c92:	1e250513          	addi	a0,a0,482 # ffffffffc0205e70 <commands+0x5e8>
ffffffffc0200c96:	cfeff0ef          	jal	ra,ffffffffc0200194 <cprintf>
                num++; // 打印次数加一
ffffffffc0200c9a:	000aa717          	auipc	a4,0xaa
ffffffffc0200c9e:	a0670713          	addi	a4,a4,-1530 # ffffffffc02aa6a0 <num>
ffffffffc0200ca2:	431c                	lw	a5,0(a4)
                if (num == 10) {
ffffffffc0200ca4:	46a9                	li	a3,10
                num++; // 打印次数加一
ffffffffc0200ca6:	0017861b          	addiw	a2,a5,1
ffffffffc0200caa:	c310                	sw	a2,0(a4)
                if (num == 10) {
ffffffffc0200cac:	fcd615e3          	bne	a2,a3,ffffffffc0200c76 <interrupt_handler+0x70>
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200cb0:	4501                	li	a0,0
ffffffffc0200cb2:	4581                	li	a1,0
ffffffffc0200cb4:	4601                	li	a2,0
ffffffffc0200cb6:	48a1                	li	a7,8
ffffffffc0200cb8:	00000073          	ecall
}
ffffffffc0200cbc:	bf6d                	j	ffffffffc0200c76 <interrupt_handler+0x70>

ffffffffc0200cbe <exception_handler>:
void kernel_execve_ret(struct trapframe *tf, uintptr_t kstacktop);
void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
ffffffffc0200cbe:	11853783          	ld	a5,280(a0)
{
ffffffffc0200cc2:	1141                	addi	sp,sp,-16
ffffffffc0200cc4:	e022                	sd	s0,0(sp)
ffffffffc0200cc6:	e406                	sd	ra,8(sp)
ffffffffc0200cc8:	473d                	li	a4,15
ffffffffc0200cca:	842a                	mv	s0,a0
ffffffffc0200ccc:	10f76563          	bltu	a4,a5,ffffffffc0200dd6 <exception_handler+0x118>
ffffffffc0200cd0:	00005717          	auipc	a4,0x5
ffffffffc0200cd4:	3c870713          	addi	a4,a4,968 # ffffffffc0206098 <commands+0x810>
ffffffffc0200cd8:	078a                	slli	a5,a5,0x2
ffffffffc0200cda:	97ba                	add	a5,a5,a4
ffffffffc0200cdc:	439c                	lw	a5,0(a5)
ffffffffc0200cde:	97ba                	add	a5,a5,a4
ffffffffc0200ce0:	8782                	jr	a5
        // cprintf("Environment call from U-mode\n");
        tf->epc += 4;
        syscall();
        break;
    case CAUSE_SUPERVISOR_ECALL:
        cprintf("Environment call from S-mode\n");
ffffffffc0200ce2:	00005517          	auipc	a0,0x5
ffffffffc0200ce6:	30e50513          	addi	a0,a0,782 # ffffffffc0205ff0 <commands+0x768>
ffffffffc0200cea:	caaff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        tf->epc += 4;
ffffffffc0200cee:	10843783          	ld	a5,264(s0)
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200cf2:	60a2                	ld	ra,8(sp)
        tf->epc += 4;
ffffffffc0200cf4:	0791                	addi	a5,a5,4
ffffffffc0200cf6:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200cfa:	6402                	ld	s0,0(sp)
ffffffffc0200cfc:	0141                	addi	sp,sp,16
        syscall();
ffffffffc0200cfe:	3ce0406f          	j	ffffffffc02050cc <syscall>
        cprintf("Environment call from H-mode\n");
ffffffffc0200d02:	00005517          	auipc	a0,0x5
ffffffffc0200d06:	30e50513          	addi	a0,a0,782 # ffffffffc0206010 <commands+0x788>
}
ffffffffc0200d0a:	6402                	ld	s0,0(sp)
ffffffffc0200d0c:	60a2                	ld	ra,8(sp)
ffffffffc0200d0e:	0141                	addi	sp,sp,16
        cprintf("Instruction access fault\n");
ffffffffc0200d10:	c84ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Environment call from M-mode\n");
ffffffffc0200d14:	00005517          	auipc	a0,0x5
ffffffffc0200d18:	31c50513          	addi	a0,a0,796 # ffffffffc0206030 <commands+0x7a8>
ffffffffc0200d1c:	b7fd                	j	ffffffffc0200d0a <exception_handler+0x4c>
        cprintf("Instruction page fault\n");
ffffffffc0200d1e:	00005517          	auipc	a0,0x5
ffffffffc0200d22:	33250513          	addi	a0,a0,818 # ffffffffc0206050 <commands+0x7c8>
ffffffffc0200d26:	b7d5                	j	ffffffffc0200d0a <exception_handler+0x4c>
        cprintf("Load page fault\n");
ffffffffc0200d28:	00005517          	auipc	a0,0x5
ffffffffc0200d2c:	34050513          	addi	a0,a0,832 # ffffffffc0206068 <commands+0x7e0>
ffffffffc0200d30:	bfe9                	j	ffffffffc0200d0a <exception_handler+0x4c>
        cprintf("Store/AMO page fault\n");
ffffffffc0200d32:	00005517          	auipc	a0,0x5
ffffffffc0200d36:	34e50513          	addi	a0,a0,846 # ffffffffc0206080 <commands+0x7f8>
ffffffffc0200d3a:	bfc1                	j	ffffffffc0200d0a <exception_handler+0x4c>
        cprintf("Instruction address misaligned\n");
ffffffffc0200d3c:	00005517          	auipc	a0,0x5
ffffffffc0200d40:	19450513          	addi	a0,a0,404 # ffffffffc0205ed0 <commands+0x648>
ffffffffc0200d44:	b7d9                	j	ffffffffc0200d0a <exception_handler+0x4c>
        cprintf("Instruction access fault\n");
ffffffffc0200d46:	00005517          	auipc	a0,0x5
ffffffffc0200d4a:	1aa50513          	addi	a0,a0,426 # ffffffffc0205ef0 <commands+0x668>
ffffffffc0200d4e:	bf75                	j	ffffffffc0200d0a <exception_handler+0x4c>
            cprintf("Exception type: Illegal instruction\n");
ffffffffc0200d50:	00005517          	auipc	a0,0x5
ffffffffc0200d54:	1c050513          	addi	a0,a0,448 # ffffffffc0205f10 <commands+0x688>
ffffffffc0200d58:	c3cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
ffffffffc0200d5c:	10843583          	ld	a1,264(s0)
ffffffffc0200d60:	00005517          	auipc	a0,0x5
ffffffffc0200d64:	1d850513          	addi	a0,a0,472 # ffffffffc0205f38 <commands+0x6b0>
ffffffffc0200d68:	c2cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
            tf->epc += 4;
ffffffffc0200d6c:	10843783          	ld	a5,264(s0)
ffffffffc0200d70:	0791                	addi	a5,a5,4
ffffffffc0200d72:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200d76:	60a2                	ld	ra,8(sp)
ffffffffc0200d78:	6402                	ld	s0,0(sp)
ffffffffc0200d7a:	0141                	addi	sp,sp,16
ffffffffc0200d7c:	8082                	ret
        cprintf("Breakpoint\n");
ffffffffc0200d7e:	00005517          	auipc	a0,0x5
ffffffffc0200d82:	1e250513          	addi	a0,a0,482 # ffffffffc0205f60 <commands+0x6d8>
ffffffffc0200d86:	c0eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        if (tf->gpr.a7 == 10)
ffffffffc0200d8a:	6458                	ld	a4,136(s0)
ffffffffc0200d8c:	47a9                	li	a5,10
ffffffffc0200d8e:	fef714e3          	bne	a4,a5,ffffffffc0200d76 <exception_handler+0xb8>
            tf->epc += 4;
ffffffffc0200d92:	10843783          	ld	a5,264(s0)
ffffffffc0200d96:	0791                	addi	a5,a5,4
ffffffffc0200d98:	10f43423          	sd	a5,264(s0)
            syscall();
ffffffffc0200d9c:	330040ef          	jal	ra,ffffffffc02050cc <syscall>
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200da0:	000aa797          	auipc	a5,0xaa
ffffffffc0200da4:	9407b783          	ld	a5,-1728(a5) # ffffffffc02aa6e0 <current>
ffffffffc0200da8:	6b9c                	ld	a5,16(a5)
ffffffffc0200daa:	8522                	mv	a0,s0
}
ffffffffc0200dac:	6402                	ld	s0,0(sp)
ffffffffc0200dae:	60a2                	ld	ra,8(sp)
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200db0:	6589                	lui	a1,0x2
ffffffffc0200db2:	95be                	add	a1,a1,a5
}
ffffffffc0200db4:	0141                	addi	sp,sp,16
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200db6:	aa71                	j	ffffffffc0200f52 <kernel_execve_ret>
        cprintf("Load address misaligned\n");
ffffffffc0200db8:	00005517          	auipc	a0,0x5
ffffffffc0200dbc:	1b850513          	addi	a0,a0,440 # ffffffffc0205f70 <commands+0x6e8>
ffffffffc0200dc0:	b7a9                	j	ffffffffc0200d0a <exception_handler+0x4c>
        cprintf("Load access fault\n");
ffffffffc0200dc2:	00005517          	auipc	a0,0x5
ffffffffc0200dc6:	1ce50513          	addi	a0,a0,462 # ffffffffc0205f90 <commands+0x708>
ffffffffc0200dca:	b781                	j	ffffffffc0200d0a <exception_handler+0x4c>
        cprintf("Store/AMO access fault\n");
ffffffffc0200dcc:	00005517          	auipc	a0,0x5
ffffffffc0200dd0:	20c50513          	addi	a0,a0,524 # ffffffffc0205fd8 <commands+0x750>
ffffffffc0200dd4:	bf1d                	j	ffffffffc0200d0a <exception_handler+0x4c>
        print_trapframe(tf);
ffffffffc0200dd6:	8522                	mv	a0,s0
}
ffffffffc0200dd8:	6402                	ld	s0,0(sp)
ffffffffc0200dda:	60a2                	ld	ra,8(sp)
ffffffffc0200ddc:	0141                	addi	sp,sp,16
        print_trapframe(tf);
ffffffffc0200dde:	b3d9                	j	ffffffffc0200ba4 <print_trapframe>
        panic("AMO address misaligned\n");
ffffffffc0200de0:	00005617          	auipc	a2,0x5
ffffffffc0200de4:	1c860613          	addi	a2,a2,456 # ffffffffc0205fa8 <commands+0x720>
ffffffffc0200de8:	0c800593          	li	a1,200
ffffffffc0200dec:	00005517          	auipc	a0,0x5
ffffffffc0200df0:	1d450513          	addi	a0,a0,468 # ffffffffc0205fc0 <commands+0x738>
ffffffffc0200df4:	e9aff0ef          	jal	ra,ffffffffc020048e <__panic>

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
ffffffffc0200dfc:	000aa417          	auipc	s0,0xaa
ffffffffc0200e00:	8e440413          	addi	s0,s0,-1820 # ffffffffc02aa6e0 <current>
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
ffffffffc0200e24:	e9bff0ef          	jal	ra,ffffffffc0200cbe <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200e28:	601c                	ld	a5,0(s0)
ffffffffc0200e2a:	0b27b023          	sd	s2,160(a5)
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
ffffffffc0200e48:	dbfff0ef          	jal	ra,ffffffffc0200c06 <interrupt_handler>
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
ffffffffc0200e5c:	b58d                	j	ffffffffc0200cbe <exception_handler>
}
ffffffffc0200e5e:	6442                	ld	s0,16(sp)
ffffffffc0200e60:	60e2                	ld	ra,24(sp)
ffffffffc0200e62:	64a2                	ld	s1,8(sp)
ffffffffc0200e64:	6902                	ld	s2,0(sp)
ffffffffc0200e66:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200e68:	bb79                	j	ffffffffc0200c06 <interrupt_handler>
}
ffffffffc0200e6a:	6442                	ld	s0,16(sp)
ffffffffc0200e6c:	60e2                	ld	ra,24(sp)
ffffffffc0200e6e:	64a2                	ld	s1,8(sp)
ffffffffc0200e70:	6902                	ld	s2,0(sp)
ffffffffc0200e72:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200e74:	16c0406f          	j	ffffffffc0204fe0 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200e78:	555d                	li	a0,-9
ffffffffc0200e7a:	4b6030ef          	jal	ra,ffffffffc0204330 <do_exit>
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
ffffffffc02010b2:	00006617          	auipc	a2,0x6
ffffffffc02010b6:	6de63603          	ld	a2,1758(a2) # ffffffffc0207790 <nbase>
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
ffffffffc02012fc:	de068693          	addi	a3,a3,-544 # ffffffffc02060d8 <commands+0x850>
ffffffffc0201300:	00005617          	auipc	a2,0x5
ffffffffc0201304:	de860613          	addi	a2,a2,-536 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201308:	11000593          	li	a1,272
ffffffffc020130c:	00005517          	auipc	a0,0x5
ffffffffc0201310:	df450513          	addi	a0,a0,-524 # ffffffffc0206100 <commands+0x878>
ffffffffc0201314:	97aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201318:	00005697          	auipc	a3,0x5
ffffffffc020131c:	e8068693          	addi	a3,a3,-384 # ffffffffc0206198 <commands+0x910>
ffffffffc0201320:	00005617          	auipc	a2,0x5
ffffffffc0201324:	dc860613          	addi	a2,a2,-568 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201328:	0db00593          	li	a1,219
ffffffffc020132c:	00005517          	auipc	a0,0x5
ffffffffc0201330:	dd450513          	addi	a0,a0,-556 # ffffffffc0206100 <commands+0x878>
ffffffffc0201334:	95aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201338:	00005697          	auipc	a3,0x5
ffffffffc020133c:	e8868693          	addi	a3,a3,-376 # ffffffffc02061c0 <commands+0x938>
ffffffffc0201340:	00005617          	auipc	a2,0x5
ffffffffc0201344:	da860613          	addi	a2,a2,-600 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201348:	0dc00593          	li	a1,220
ffffffffc020134c:	00005517          	auipc	a0,0x5
ffffffffc0201350:	db450513          	addi	a0,a0,-588 # ffffffffc0206100 <commands+0x878>
ffffffffc0201354:	93aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201358:	00005697          	auipc	a3,0x5
ffffffffc020135c:	ea868693          	addi	a3,a3,-344 # ffffffffc0206200 <commands+0x978>
ffffffffc0201360:	00005617          	auipc	a2,0x5
ffffffffc0201364:	d8860613          	addi	a2,a2,-632 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201368:	0de00593          	li	a1,222
ffffffffc020136c:	00005517          	auipc	a0,0x5
ffffffffc0201370:	d9450513          	addi	a0,a0,-620 # ffffffffc0206100 <commands+0x878>
ffffffffc0201374:	91aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201378:	00005697          	auipc	a3,0x5
ffffffffc020137c:	f1068693          	addi	a3,a3,-240 # ffffffffc0206288 <commands+0xa00>
ffffffffc0201380:	00005617          	auipc	a2,0x5
ffffffffc0201384:	d6860613          	addi	a2,a2,-664 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201388:	0f700593          	li	a1,247
ffffffffc020138c:	00005517          	auipc	a0,0x5
ffffffffc0201390:	d7450513          	addi	a0,a0,-652 # ffffffffc0206100 <commands+0x878>
ffffffffc0201394:	8faff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201398:	00005697          	auipc	a3,0x5
ffffffffc020139c:	da068693          	addi	a3,a3,-608 # ffffffffc0206138 <commands+0x8b0>
ffffffffc02013a0:	00005617          	auipc	a2,0x5
ffffffffc02013a4:	d4860613          	addi	a2,a2,-696 # ffffffffc02060e8 <commands+0x860>
ffffffffc02013a8:	0f000593          	li	a1,240
ffffffffc02013ac:	00005517          	auipc	a0,0x5
ffffffffc02013b0:	d5450513          	addi	a0,a0,-684 # ffffffffc0206100 <commands+0x878>
ffffffffc02013b4:	8daff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free == 3);
ffffffffc02013b8:	00005697          	auipc	a3,0x5
ffffffffc02013bc:	ec068693          	addi	a3,a3,-320 # ffffffffc0206278 <commands+0x9f0>
ffffffffc02013c0:	00005617          	auipc	a2,0x5
ffffffffc02013c4:	d2860613          	addi	a2,a2,-728 # ffffffffc02060e8 <commands+0x860>
ffffffffc02013c8:	0ee00593          	li	a1,238
ffffffffc02013cc:	00005517          	auipc	a0,0x5
ffffffffc02013d0:	d3450513          	addi	a0,a0,-716 # ffffffffc0206100 <commands+0x878>
ffffffffc02013d4:	8baff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013d8:	00005697          	auipc	a3,0x5
ffffffffc02013dc:	e8868693          	addi	a3,a3,-376 # ffffffffc0206260 <commands+0x9d8>
ffffffffc02013e0:	00005617          	auipc	a2,0x5
ffffffffc02013e4:	d0860613          	addi	a2,a2,-760 # ffffffffc02060e8 <commands+0x860>
ffffffffc02013e8:	0e900593          	li	a1,233
ffffffffc02013ec:	00005517          	auipc	a0,0x5
ffffffffc02013f0:	d1450513          	addi	a0,a0,-748 # ffffffffc0206100 <commands+0x878>
ffffffffc02013f4:	89aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02013f8:	00005697          	auipc	a3,0x5
ffffffffc02013fc:	e4868693          	addi	a3,a3,-440 # ffffffffc0206240 <commands+0x9b8>
ffffffffc0201400:	00005617          	auipc	a2,0x5
ffffffffc0201404:	ce860613          	addi	a2,a2,-792 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201408:	0e000593          	li	a1,224
ffffffffc020140c:	00005517          	auipc	a0,0x5
ffffffffc0201410:	cf450513          	addi	a0,a0,-780 # ffffffffc0206100 <commands+0x878>
ffffffffc0201414:	87aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(p0 != NULL);
ffffffffc0201418:	00005697          	auipc	a3,0x5
ffffffffc020141c:	eb868693          	addi	a3,a3,-328 # ffffffffc02062d0 <commands+0xa48>
ffffffffc0201420:	00005617          	auipc	a2,0x5
ffffffffc0201424:	cc860613          	addi	a2,a2,-824 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201428:	11800593          	li	a1,280
ffffffffc020142c:	00005517          	auipc	a0,0x5
ffffffffc0201430:	cd450513          	addi	a0,a0,-812 # ffffffffc0206100 <commands+0x878>
ffffffffc0201434:	85aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free == 0);
ffffffffc0201438:	00005697          	auipc	a3,0x5
ffffffffc020143c:	e8868693          	addi	a3,a3,-376 # ffffffffc02062c0 <commands+0xa38>
ffffffffc0201440:	00005617          	auipc	a2,0x5
ffffffffc0201444:	ca860613          	addi	a2,a2,-856 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201448:	0fd00593          	li	a1,253
ffffffffc020144c:	00005517          	auipc	a0,0x5
ffffffffc0201450:	cb450513          	addi	a0,a0,-844 # ffffffffc0206100 <commands+0x878>
ffffffffc0201454:	83aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201458:	00005697          	auipc	a3,0x5
ffffffffc020145c:	e0868693          	addi	a3,a3,-504 # ffffffffc0206260 <commands+0x9d8>
ffffffffc0201460:	00005617          	auipc	a2,0x5
ffffffffc0201464:	c8860613          	addi	a2,a2,-888 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201468:	0fb00593          	li	a1,251
ffffffffc020146c:	00005517          	auipc	a0,0x5
ffffffffc0201470:	c9450513          	addi	a0,a0,-876 # ffffffffc0206100 <commands+0x878>
ffffffffc0201474:	81aff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201478:	00005697          	auipc	a3,0x5
ffffffffc020147c:	e2868693          	addi	a3,a3,-472 # ffffffffc02062a0 <commands+0xa18>
ffffffffc0201480:	00005617          	auipc	a2,0x5
ffffffffc0201484:	c6860613          	addi	a2,a2,-920 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201488:	0fa00593          	li	a1,250
ffffffffc020148c:	00005517          	auipc	a0,0x5
ffffffffc0201490:	c7450513          	addi	a0,a0,-908 # ffffffffc0206100 <commands+0x878>
ffffffffc0201494:	ffbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201498:	00005697          	auipc	a3,0x5
ffffffffc020149c:	ca068693          	addi	a3,a3,-864 # ffffffffc0206138 <commands+0x8b0>
ffffffffc02014a0:	00005617          	auipc	a2,0x5
ffffffffc02014a4:	c4860613          	addi	a2,a2,-952 # ffffffffc02060e8 <commands+0x860>
ffffffffc02014a8:	0d700593          	li	a1,215
ffffffffc02014ac:	00005517          	auipc	a0,0x5
ffffffffc02014b0:	c5450513          	addi	a0,a0,-940 # ffffffffc0206100 <commands+0x878>
ffffffffc02014b4:	fdbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014b8:	00005697          	auipc	a3,0x5
ffffffffc02014bc:	da868693          	addi	a3,a3,-600 # ffffffffc0206260 <commands+0x9d8>
ffffffffc02014c0:	00005617          	auipc	a2,0x5
ffffffffc02014c4:	c2860613          	addi	a2,a2,-984 # ffffffffc02060e8 <commands+0x860>
ffffffffc02014c8:	0f400593          	li	a1,244
ffffffffc02014cc:	00005517          	auipc	a0,0x5
ffffffffc02014d0:	c3450513          	addi	a0,a0,-972 # ffffffffc0206100 <commands+0x878>
ffffffffc02014d4:	fbbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02014d8:	00005697          	auipc	a3,0x5
ffffffffc02014dc:	ca068693          	addi	a3,a3,-864 # ffffffffc0206178 <commands+0x8f0>
ffffffffc02014e0:	00005617          	auipc	a2,0x5
ffffffffc02014e4:	c0860613          	addi	a2,a2,-1016 # ffffffffc02060e8 <commands+0x860>
ffffffffc02014e8:	0f200593          	li	a1,242
ffffffffc02014ec:	00005517          	auipc	a0,0x5
ffffffffc02014f0:	c1450513          	addi	a0,a0,-1004 # ffffffffc0206100 <commands+0x878>
ffffffffc02014f4:	f9bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02014f8:	00005697          	auipc	a3,0x5
ffffffffc02014fc:	c6068693          	addi	a3,a3,-928 # ffffffffc0206158 <commands+0x8d0>
ffffffffc0201500:	00005617          	auipc	a2,0x5
ffffffffc0201504:	be860613          	addi	a2,a2,-1048 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201508:	0f100593          	li	a1,241
ffffffffc020150c:	00005517          	auipc	a0,0x5
ffffffffc0201510:	bf450513          	addi	a0,a0,-1036 # ffffffffc0206100 <commands+0x878>
ffffffffc0201514:	f7bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201518:	00005697          	auipc	a3,0x5
ffffffffc020151c:	c6068693          	addi	a3,a3,-928 # ffffffffc0206178 <commands+0x8f0>
ffffffffc0201520:	00005617          	auipc	a2,0x5
ffffffffc0201524:	bc860613          	addi	a2,a2,-1080 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201528:	0d900593          	li	a1,217
ffffffffc020152c:	00005517          	auipc	a0,0x5
ffffffffc0201530:	bd450513          	addi	a0,a0,-1068 # ffffffffc0206100 <commands+0x878>
ffffffffc0201534:	f5bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(count == 0);
ffffffffc0201538:	00005697          	auipc	a3,0x5
ffffffffc020153c:	ee868693          	addi	a3,a3,-280 # ffffffffc0206420 <commands+0xb98>
ffffffffc0201540:	00005617          	auipc	a2,0x5
ffffffffc0201544:	ba860613          	addi	a2,a2,-1112 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201548:	14600593          	li	a1,326
ffffffffc020154c:	00005517          	auipc	a0,0x5
ffffffffc0201550:	bb450513          	addi	a0,a0,-1100 # ffffffffc0206100 <commands+0x878>
ffffffffc0201554:	f3bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free == 0);
ffffffffc0201558:	00005697          	auipc	a3,0x5
ffffffffc020155c:	d6868693          	addi	a3,a3,-664 # ffffffffc02062c0 <commands+0xa38>
ffffffffc0201560:	00005617          	auipc	a2,0x5
ffffffffc0201564:	b8860613          	addi	a2,a2,-1144 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201568:	13a00593          	li	a1,314
ffffffffc020156c:	00005517          	auipc	a0,0x5
ffffffffc0201570:	b9450513          	addi	a0,a0,-1132 # ffffffffc0206100 <commands+0x878>
ffffffffc0201574:	f1bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201578:	00005697          	auipc	a3,0x5
ffffffffc020157c:	ce868693          	addi	a3,a3,-792 # ffffffffc0206260 <commands+0x9d8>
ffffffffc0201580:	00005617          	auipc	a2,0x5
ffffffffc0201584:	b6860613          	addi	a2,a2,-1176 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201588:	13800593          	li	a1,312
ffffffffc020158c:	00005517          	auipc	a0,0x5
ffffffffc0201590:	b7450513          	addi	a0,a0,-1164 # ffffffffc0206100 <commands+0x878>
ffffffffc0201594:	efbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201598:	00005697          	auipc	a3,0x5
ffffffffc020159c:	c8868693          	addi	a3,a3,-888 # ffffffffc0206220 <commands+0x998>
ffffffffc02015a0:	00005617          	auipc	a2,0x5
ffffffffc02015a4:	b4860613          	addi	a2,a2,-1208 # ffffffffc02060e8 <commands+0x860>
ffffffffc02015a8:	0df00593          	li	a1,223
ffffffffc02015ac:	00005517          	auipc	a0,0x5
ffffffffc02015b0:	b5450513          	addi	a0,a0,-1196 # ffffffffc0206100 <commands+0x878>
ffffffffc02015b4:	edbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02015b8:	00005697          	auipc	a3,0x5
ffffffffc02015bc:	e2868693          	addi	a3,a3,-472 # ffffffffc02063e0 <commands+0xb58>
ffffffffc02015c0:	00005617          	auipc	a2,0x5
ffffffffc02015c4:	b2860613          	addi	a2,a2,-1240 # ffffffffc02060e8 <commands+0x860>
ffffffffc02015c8:	13200593          	li	a1,306
ffffffffc02015cc:	00005517          	auipc	a0,0x5
ffffffffc02015d0:	b3450513          	addi	a0,a0,-1228 # ffffffffc0206100 <commands+0x878>
ffffffffc02015d4:	ebbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02015d8:	00005697          	auipc	a3,0x5
ffffffffc02015dc:	de868693          	addi	a3,a3,-536 # ffffffffc02063c0 <commands+0xb38>
ffffffffc02015e0:	00005617          	auipc	a2,0x5
ffffffffc02015e4:	b0860613          	addi	a2,a2,-1272 # ffffffffc02060e8 <commands+0x860>
ffffffffc02015e8:	13000593          	li	a1,304
ffffffffc02015ec:	00005517          	auipc	a0,0x5
ffffffffc02015f0:	b1450513          	addi	a0,a0,-1260 # ffffffffc0206100 <commands+0x878>
ffffffffc02015f4:	e9bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02015f8:	00005697          	auipc	a3,0x5
ffffffffc02015fc:	da068693          	addi	a3,a3,-608 # ffffffffc0206398 <commands+0xb10>
ffffffffc0201600:	00005617          	auipc	a2,0x5
ffffffffc0201604:	ae860613          	addi	a2,a2,-1304 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201608:	12e00593          	li	a1,302
ffffffffc020160c:	00005517          	auipc	a0,0x5
ffffffffc0201610:	af450513          	addi	a0,a0,-1292 # ffffffffc0206100 <commands+0x878>
ffffffffc0201614:	e7bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201618:	00005697          	auipc	a3,0x5
ffffffffc020161c:	d5868693          	addi	a3,a3,-680 # ffffffffc0206370 <commands+0xae8>
ffffffffc0201620:	00005617          	auipc	a2,0x5
ffffffffc0201624:	ac860613          	addi	a2,a2,-1336 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201628:	12d00593          	li	a1,301
ffffffffc020162c:	00005517          	auipc	a0,0x5
ffffffffc0201630:	ad450513          	addi	a0,a0,-1324 # ffffffffc0206100 <commands+0x878>
ffffffffc0201634:	e5bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201638:	00005697          	auipc	a3,0x5
ffffffffc020163c:	d2868693          	addi	a3,a3,-728 # ffffffffc0206360 <commands+0xad8>
ffffffffc0201640:	00005617          	auipc	a2,0x5
ffffffffc0201644:	aa860613          	addi	a2,a2,-1368 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201648:	12800593          	li	a1,296
ffffffffc020164c:	00005517          	auipc	a0,0x5
ffffffffc0201650:	ab450513          	addi	a0,a0,-1356 # ffffffffc0206100 <commands+0x878>
ffffffffc0201654:	e3bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201658:	00005697          	auipc	a3,0x5
ffffffffc020165c:	c0868693          	addi	a3,a3,-1016 # ffffffffc0206260 <commands+0x9d8>
ffffffffc0201660:	00005617          	auipc	a2,0x5
ffffffffc0201664:	a8860613          	addi	a2,a2,-1400 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201668:	12700593          	li	a1,295
ffffffffc020166c:	00005517          	auipc	a0,0x5
ffffffffc0201670:	a9450513          	addi	a0,a0,-1388 # ffffffffc0206100 <commands+0x878>
ffffffffc0201674:	e1bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201678:	00005697          	auipc	a3,0x5
ffffffffc020167c:	cc868693          	addi	a3,a3,-824 # ffffffffc0206340 <commands+0xab8>
ffffffffc0201680:	00005617          	auipc	a2,0x5
ffffffffc0201684:	a6860613          	addi	a2,a2,-1432 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201688:	12600593          	li	a1,294
ffffffffc020168c:	00005517          	auipc	a0,0x5
ffffffffc0201690:	a7450513          	addi	a0,a0,-1420 # ffffffffc0206100 <commands+0x878>
ffffffffc0201694:	dfbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201698:	00005697          	auipc	a3,0x5
ffffffffc020169c:	c7868693          	addi	a3,a3,-904 # ffffffffc0206310 <commands+0xa88>
ffffffffc02016a0:	00005617          	auipc	a2,0x5
ffffffffc02016a4:	a4860613          	addi	a2,a2,-1464 # ffffffffc02060e8 <commands+0x860>
ffffffffc02016a8:	12500593          	li	a1,293
ffffffffc02016ac:	00005517          	auipc	a0,0x5
ffffffffc02016b0:	a5450513          	addi	a0,a0,-1452 # ffffffffc0206100 <commands+0x878>
ffffffffc02016b4:	ddbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02016b8:	00005697          	auipc	a3,0x5
ffffffffc02016bc:	c4068693          	addi	a3,a3,-960 # ffffffffc02062f8 <commands+0xa70>
ffffffffc02016c0:	00005617          	auipc	a2,0x5
ffffffffc02016c4:	a2860613          	addi	a2,a2,-1496 # ffffffffc02060e8 <commands+0x860>
ffffffffc02016c8:	12400593          	li	a1,292
ffffffffc02016cc:	00005517          	auipc	a0,0x5
ffffffffc02016d0:	a3450513          	addi	a0,a0,-1484 # ffffffffc0206100 <commands+0x878>
ffffffffc02016d4:	dbbfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02016d8:	00005697          	auipc	a3,0x5
ffffffffc02016dc:	b8868693          	addi	a3,a3,-1144 # ffffffffc0206260 <commands+0x9d8>
ffffffffc02016e0:	00005617          	auipc	a2,0x5
ffffffffc02016e4:	a0860613          	addi	a2,a2,-1528 # ffffffffc02060e8 <commands+0x860>
ffffffffc02016e8:	11e00593          	li	a1,286
ffffffffc02016ec:	00005517          	auipc	a0,0x5
ffffffffc02016f0:	a1450513          	addi	a0,a0,-1516 # ffffffffc0206100 <commands+0x878>
ffffffffc02016f4:	d9bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(!PageProperty(p0));
ffffffffc02016f8:	00005697          	auipc	a3,0x5
ffffffffc02016fc:	be868693          	addi	a3,a3,-1048 # ffffffffc02062e0 <commands+0xa58>
ffffffffc0201700:	00005617          	auipc	a2,0x5
ffffffffc0201704:	9e860613          	addi	a2,a2,-1560 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201708:	11900593          	li	a1,281
ffffffffc020170c:	00005517          	auipc	a0,0x5
ffffffffc0201710:	9f450513          	addi	a0,a0,-1548 # ffffffffc0206100 <commands+0x878>
ffffffffc0201714:	d7bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201718:	00005697          	auipc	a3,0x5
ffffffffc020171c:	ce868693          	addi	a3,a3,-792 # ffffffffc0206400 <commands+0xb78>
ffffffffc0201720:	00005617          	auipc	a2,0x5
ffffffffc0201724:	9c860613          	addi	a2,a2,-1592 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201728:	13700593          	li	a1,311
ffffffffc020172c:	00005517          	auipc	a0,0x5
ffffffffc0201730:	9d450513          	addi	a0,a0,-1580 # ffffffffc0206100 <commands+0x878>
ffffffffc0201734:	d5bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(total == 0);
ffffffffc0201738:	00005697          	auipc	a3,0x5
ffffffffc020173c:	cf868693          	addi	a3,a3,-776 # ffffffffc0206430 <commands+0xba8>
ffffffffc0201740:	00005617          	auipc	a2,0x5
ffffffffc0201744:	9a860613          	addi	a2,a2,-1624 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201748:	14700593          	li	a1,327
ffffffffc020174c:	00005517          	auipc	a0,0x5
ffffffffc0201750:	9b450513          	addi	a0,a0,-1612 # ffffffffc0206100 <commands+0x878>
ffffffffc0201754:	d3bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(total == nr_free_pages());
ffffffffc0201758:	00005697          	auipc	a3,0x5
ffffffffc020175c:	9c068693          	addi	a3,a3,-1600 # ffffffffc0206118 <commands+0x890>
ffffffffc0201760:	00005617          	auipc	a2,0x5
ffffffffc0201764:	98860613          	addi	a2,a2,-1656 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201768:	11300593          	li	a1,275
ffffffffc020176c:	00005517          	auipc	a0,0x5
ffffffffc0201770:	99450513          	addi	a0,a0,-1644 # ffffffffc0206100 <commands+0x878>
ffffffffc0201774:	d1bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201778:	00005697          	auipc	a3,0x5
ffffffffc020177c:	9e068693          	addi	a3,a3,-1568 # ffffffffc0206158 <commands+0x8d0>
ffffffffc0201780:	00005617          	auipc	a2,0x5
ffffffffc0201784:	96860613          	addi	a2,a2,-1688 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201788:	0d800593          	li	a1,216
ffffffffc020178c:	00005517          	auipc	a0,0x5
ffffffffc0201790:	97450513          	addi	a0,a0,-1676 # ffffffffc0206100 <commands+0x878>
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
ffffffffc02018c8:	b8468693          	addi	a3,a3,-1148 # ffffffffc0206448 <commands+0xbc0>
ffffffffc02018cc:	00005617          	auipc	a2,0x5
ffffffffc02018d0:	81c60613          	addi	a2,a2,-2020 # ffffffffc02060e8 <commands+0x860>
ffffffffc02018d4:	09400593          	li	a1,148
ffffffffc02018d8:	00005517          	auipc	a0,0x5
ffffffffc02018dc:	82850513          	addi	a0,a0,-2008 # ffffffffc0206100 <commands+0x878>
ffffffffc02018e0:	baffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(n > 0);
ffffffffc02018e4:	00005697          	auipc	a3,0x5
ffffffffc02018e8:	b5c68693          	addi	a3,a3,-1188 # ffffffffc0206440 <commands+0xbb8>
ffffffffc02018ec:	00004617          	auipc	a2,0x4
ffffffffc02018f0:	7fc60613          	addi	a2,a2,2044 # ffffffffc02060e8 <commands+0x860>
ffffffffc02018f4:	09000593          	li	a1,144
ffffffffc02018f8:	00005517          	auipc	a0,0x5
ffffffffc02018fc:	80850513          	addi	a0,a0,-2040 # ffffffffc0206100 <commands+0x878>
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
ffffffffc020199a:	aaa68693          	addi	a3,a3,-1366 # ffffffffc0206440 <commands+0xbb8>
ffffffffc020199e:	00004617          	auipc	a2,0x4
ffffffffc02019a2:	74a60613          	addi	a2,a2,1866 # ffffffffc02060e8 <commands+0x860>
ffffffffc02019a6:	06c00593          	li	a1,108
ffffffffc02019aa:	00004517          	auipc	a0,0x4
ffffffffc02019ae:	75650513          	addi	a0,a0,1878 # ffffffffc0206100 <commands+0x878>
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
ffffffffc0201a6c:	a0868693          	addi	a3,a3,-1528 # ffffffffc0206470 <commands+0xbe8>
ffffffffc0201a70:	00004617          	auipc	a2,0x4
ffffffffc0201a74:	67860613          	addi	a2,a2,1656 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201a78:	04b00593          	li	a1,75
ffffffffc0201a7c:	00004517          	auipc	a0,0x4
ffffffffc0201a80:	68450513          	addi	a0,a0,1668 # ffffffffc0206100 <commands+0x878>
ffffffffc0201a84:	a0bfe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(n > 0);
ffffffffc0201a88:	00005697          	auipc	a3,0x5
ffffffffc0201a8c:	9b868693          	addi	a3,a3,-1608 # ffffffffc0206440 <commands+0xbb8>
ffffffffc0201a90:	00004617          	auipc	a2,0x4
ffffffffc0201a94:	65860613          	addi	a2,a2,1624 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201a98:	04700593          	li	a1,71
ffffffffc0201a9c:	00004517          	auipc	a0,0x4
ffffffffc0201aa0:	66450513          	addi	a0,a0,1636 # ffffffffc0206100 <commands+0x878>
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
ffffffffc0201b7c:	c186b683          	ld	a3,-1000(a3) # ffffffffc0207790 <nbase>
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
ffffffffc0201bac:	92860613          	addi	a2,a2,-1752 # ffffffffc02064d0 <default_pmm_manager+0x38>
ffffffffc0201bb0:	07100593          	li	a1,113
ffffffffc0201bb4:	00005517          	auipc	a0,0x5
ffffffffc0201bb8:	94450513          	addi	a0,a0,-1724 # ffffffffc02064f8 <default_pmm_manager+0x60>
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
ffffffffc0201c9a:	87268693          	addi	a3,a3,-1934 # ffffffffc0206508 <default_pmm_manager+0x70>
ffffffffc0201c9e:	00004617          	auipc	a2,0x4
ffffffffc0201ca2:	44a60613          	addi	a2,a2,1098 # ffffffffc02060e8 <commands+0x860>
ffffffffc0201ca6:	06300593          	li	a1,99
ffffffffc0201caa:	00005517          	auipc	a0,0x5
ffffffffc0201cae:	87e50513          	addi	a0,a0,-1922 # ffffffffc0206528 <default_pmm_manager+0x90>
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
ffffffffc0201cbc:	88850513          	addi	a0,a0,-1912 # ffffffffc0206540 <default_pmm_manager+0xa8>
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
ffffffffc0201ccc:	89050513          	addi	a0,a0,-1904 # ffffffffc0206558 <default_pmm_manager+0xc0>
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
ffffffffc0201df4:	9a053503          	ld	a0,-1632(a0) # ffffffffc0207790 <nbase>
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
ffffffffc0201e4e:	00004617          	auipc	a2,0x4
ffffffffc0201e52:	75260613          	addi	a2,a2,1874 # ffffffffc02065a0 <default_pmm_manager+0x108>
ffffffffc0201e56:	06900593          	li	a1,105
ffffffffc0201e5a:	00004517          	auipc	a0,0x4
ffffffffc0201e5e:	69e50513          	addi	a0,a0,1694 # ffffffffc02064f8 <default_pmm_manager+0x60>
ffffffffc0201e62:	e2cfe0ef          	jal	ra,ffffffffc020048e <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201e66:	86a2                	mv	a3,s0
ffffffffc0201e68:	00004617          	auipc	a2,0x4
ffffffffc0201e6c:	71060613          	addi	a2,a2,1808 # ffffffffc0206578 <default_pmm_manager+0xe0>
ffffffffc0201e70:	07700593          	li	a1,119
ffffffffc0201e74:	00004517          	auipc	a0,0x4
ffffffffc0201e78:	68450513          	addi	a0,a0,1668 # ffffffffc02064f8 <default_pmm_manager+0x60>
ffffffffc0201e7c:	e12fe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201e80 <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc0201e80:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201e82:	00004617          	auipc	a2,0x4
ffffffffc0201e86:	71e60613          	addi	a2,a2,1822 # ffffffffc02065a0 <default_pmm_manager+0x108>
ffffffffc0201e8a:	06900593          	li	a1,105
ffffffffc0201e8e:	00004517          	auipc	a0,0x4
ffffffffc0201e92:	66a50513          	addi	a0,a0,1642 # ffffffffc02064f8 <default_pmm_manager+0x60>
pa2page(uintptr_t pa)
ffffffffc0201e96:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201e98:	df6fe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201e9c <pte2page.part.0>:
pte2page(pte_t pte)
ffffffffc0201e9c:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201e9e:	00004617          	auipc	a2,0x4
ffffffffc0201ea2:	72260613          	addi	a2,a2,1826 # ffffffffc02065c0 <default_pmm_manager+0x128>
ffffffffc0201ea6:	07f00593          	li	a1,127
ffffffffc0201eaa:	00004517          	auipc	a0,0x4
ffffffffc0201eae:	64e50513          	addi	a0,a0,1614 # ffffffffc02064f8 <default_pmm_manager+0x60>
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
ffffffffc0202008:	5ea030ef          	jal	ra,ffffffffc02055f2 <memset>
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
ffffffffc02020aa:	548030ef          	jal	ra,ffffffffc02055f2 <memset>
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
ffffffffc0202138:	39c60613          	addi	a2,a2,924 # ffffffffc02064d0 <default_pmm_manager+0x38>
ffffffffc020213c:	0fa00593          	li	a1,250
ffffffffc0202140:	00004517          	auipc	a0,0x4
ffffffffc0202144:	4a850513          	addi	a0,a0,1192 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0202148:	b46fe0ef          	jal	ra,ffffffffc020048e <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020214c:	00004617          	auipc	a2,0x4
ffffffffc0202150:	38460613          	addi	a2,a2,900 # ffffffffc02064d0 <default_pmm_manager+0x38>
ffffffffc0202154:	0ed00593          	li	a1,237
ffffffffc0202158:	00004517          	auipc	a0,0x4
ffffffffc020215c:	49050513          	addi	a0,a0,1168 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0202160:	b2efe0ef          	jal	ra,ffffffffc020048e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202164:	86aa                	mv	a3,a0
ffffffffc0202166:	00004617          	auipc	a2,0x4
ffffffffc020216a:	36a60613          	addi	a2,a2,874 # ffffffffc02064d0 <default_pmm_manager+0x38>
ffffffffc020216e:	0e900593          	li	a1,233
ffffffffc0202172:	00004517          	auipc	a0,0x4
ffffffffc0202176:	47650513          	addi	a0,a0,1142 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc020217a:	b14fe0ef          	jal	ra,ffffffffc020048e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020217e:	86aa                	mv	a3,a0
ffffffffc0202180:	00004617          	auipc	a2,0x4
ffffffffc0202184:	35060613          	addi	a2,a2,848 # ffffffffc02064d0 <default_pmm_manager+0x38>
ffffffffc0202188:	0f700593          	li	a1,247
ffffffffc020218c:	00004517          	auipc	a0,0x4
ffffffffc0202190:	45c50513          	addi	a0,a0,1116 # ffffffffc02065e8 <default_pmm_manager+0x150>
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
ffffffffc02022f2:	30a68693          	addi	a3,a3,778 # ffffffffc02065f8 <default_pmm_manager+0x160>
ffffffffc02022f6:	00004617          	auipc	a2,0x4
ffffffffc02022fa:	df260613          	addi	a2,a2,-526 # ffffffffc02060e8 <commands+0x860>
ffffffffc02022fe:	12000593          	li	a1,288
ffffffffc0202302:	00004517          	auipc	a0,0x4
ffffffffc0202306:	2e650513          	addi	a0,a0,742 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc020230a:	984fe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020230e:	00004697          	auipc	a3,0x4
ffffffffc0202312:	31a68693          	addi	a3,a3,794 # ffffffffc0206628 <default_pmm_manager+0x190>
ffffffffc0202316:	00004617          	auipc	a2,0x4
ffffffffc020231a:	dd260613          	addi	a2,a2,-558 # ffffffffc02060e8 <commands+0x860>
ffffffffc020231e:	12100593          	li	a1,289
ffffffffc0202322:	00004517          	auipc	a0,0x4
ffffffffc0202326:	2c650513          	addi	a0,a0,710 # ffffffffc02065e8 <default_pmm_manager+0x150>
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
ffffffffc020256c:	09068693          	addi	a3,a3,144 # ffffffffc02065f8 <default_pmm_manager+0x160>
ffffffffc0202570:	00004617          	auipc	a2,0x4
ffffffffc0202574:	b7860613          	addi	a2,a2,-1160 # ffffffffc02060e8 <commands+0x860>
ffffffffc0202578:	13500593          	li	a1,309
ffffffffc020257c:	00004517          	auipc	a0,0x4
ffffffffc0202580:	06c50513          	addi	a0,a0,108 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0202584:	f0bfd0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc0202588:	00004617          	auipc	a2,0x4
ffffffffc020258c:	f4860613          	addi	a2,a2,-184 # ffffffffc02064d0 <default_pmm_manager+0x38>
ffffffffc0202590:	07100593          	li	a1,113
ffffffffc0202594:	00004517          	auipc	a0,0x4
ffffffffc0202598:	f6450513          	addi	a0,a0,-156 # ffffffffc02064f8 <default_pmm_manager+0x60>
ffffffffc020259c:	ef3fd0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc02025a0:	8e1ff0ef          	jal	ra,ffffffffc0201e80 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc02025a4:	00004697          	auipc	a3,0x4
ffffffffc02025a8:	08468693          	addi	a3,a3,132 # ffffffffc0206628 <default_pmm_manager+0x190>
ffffffffc02025ac:	00004617          	auipc	a2,0x4
ffffffffc02025b0:	b3c60613          	addi	a2,a2,-1220 # ffffffffc02060e8 <commands+0x860>
ffffffffc02025b4:	13600593          	li	a1,310
ffffffffc02025b8:	00004517          	auipc	a0,0x4
ffffffffc02025bc:	03050513          	addi	a0,a0,48 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc02025c0:	ecffd0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02025c4 <copy_range>:
{
ffffffffc02025c4:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02025c6:	00d667b3          	or	a5,a2,a3
{
ffffffffc02025ca:	fc86                	sd	ra,120(sp)
ffffffffc02025cc:	f8a2                	sd	s0,112(sp)
ffffffffc02025ce:	f4a6                	sd	s1,104(sp)
ffffffffc02025d0:	f0ca                	sd	s2,96(sp)
ffffffffc02025d2:	ecce                	sd	s3,88(sp)
ffffffffc02025d4:	e8d2                	sd	s4,80(sp)
ffffffffc02025d6:	e4d6                	sd	s5,72(sp)
ffffffffc02025d8:	e0da                	sd	s6,64(sp)
ffffffffc02025da:	fc5e                	sd	s7,56(sp)
ffffffffc02025dc:	f862                	sd	s8,48(sp)
ffffffffc02025de:	f466                	sd	s9,40(sp)
ffffffffc02025e0:	f06a                	sd	s10,32(sp)
ffffffffc02025e2:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02025e4:	17d2                	slli	a5,a5,0x34
ffffffffc02025e6:	16079e63          	bnez	a5,ffffffffc0202762 <copy_range+0x19e>
    assert(USER_ACCESS(start, end));
ffffffffc02025ea:	002007b7          	lui	a5,0x200
ffffffffc02025ee:	8db2                	mv	s11,a2
ffffffffc02025f0:	12f66d63          	bltu	a2,a5,ffffffffc020272a <copy_range+0x166>
ffffffffc02025f4:	84b6                	mv	s1,a3
ffffffffc02025f6:	12d67a63          	bgeu	a2,a3,ffffffffc020272a <copy_range+0x166>
ffffffffc02025fa:	4785                	li	a5,1
ffffffffc02025fc:	07fe                	slli	a5,a5,0x1f
ffffffffc02025fe:	12d7e663          	bltu	a5,a3,ffffffffc020272a <copy_range+0x166>
ffffffffc0202602:	8a2a                	mv	s4,a0
ffffffffc0202604:	892e                	mv	s2,a1
        start += PGSIZE;
ffffffffc0202606:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage)
ffffffffc0202608:	000a8c17          	auipc	s8,0xa8
ffffffffc020260c:	0b8c0c13          	addi	s8,s8,184 # ffffffffc02aa6c0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202610:	000a8b97          	auipc	s7,0xa8
ffffffffc0202614:	0b8b8b93          	addi	s7,s7,184 # ffffffffc02aa6c8 <pages>
ffffffffc0202618:	fff80b37          	lui	s6,0xfff80
        page = pmm_manager->alloc_pages(n);
ffffffffc020261c:	000a8a97          	auipc	s5,0xa8
ffffffffc0202620:	0b4a8a93          	addi	s5,s5,180 # ffffffffc02aa6d0 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202624:	00200d37          	lui	s10,0x200
ffffffffc0202628:	ffe00cb7          	lui	s9,0xffe00
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc020262c:	4601                	li	a2,0
ffffffffc020262e:	85ee                	mv	a1,s11
ffffffffc0202630:	854a                	mv	a0,s2
ffffffffc0202632:	93fff0ef          	jal	ra,ffffffffc0201f70 <get_pte>
ffffffffc0202636:	842a                	mv	s0,a0
        if (ptep == NULL)
ffffffffc0202638:	c559                	beqz	a0,ffffffffc02026c6 <copy_range+0x102>
        if (*ptep & PTE_V)
ffffffffc020263a:	611c                	ld	a5,0(a0)
ffffffffc020263c:	8b85                	andi	a5,a5,1
ffffffffc020263e:	e785                	bnez	a5,ffffffffc0202666 <copy_range+0xa2>
        start += PGSIZE;
ffffffffc0202640:	9dce                	add	s11,s11,s3
    } while (start != 0 && start < end);
ffffffffc0202642:	fe9de5e3          	bltu	s11,s1,ffffffffc020262c <copy_range+0x68>
    return 0;
ffffffffc0202646:	4501                	li	a0,0
}
ffffffffc0202648:	70e6                	ld	ra,120(sp)
ffffffffc020264a:	7446                	ld	s0,112(sp)
ffffffffc020264c:	74a6                	ld	s1,104(sp)
ffffffffc020264e:	7906                	ld	s2,96(sp)
ffffffffc0202650:	69e6                	ld	s3,88(sp)
ffffffffc0202652:	6a46                	ld	s4,80(sp)
ffffffffc0202654:	6aa6                	ld	s5,72(sp)
ffffffffc0202656:	6b06                	ld	s6,64(sp)
ffffffffc0202658:	7be2                	ld	s7,56(sp)
ffffffffc020265a:	7c42                	ld	s8,48(sp)
ffffffffc020265c:	7ca2                	ld	s9,40(sp)
ffffffffc020265e:	7d02                	ld	s10,32(sp)
ffffffffc0202660:	6de2                	ld	s11,24(sp)
ffffffffc0202662:	6109                	addi	sp,sp,128
ffffffffc0202664:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc0202666:	4605                	li	a2,1
ffffffffc0202668:	85ee                	mv	a1,s11
ffffffffc020266a:	8552                	mv	a0,s4
ffffffffc020266c:	905ff0ef          	jal	ra,ffffffffc0201f70 <get_pte>
ffffffffc0202670:	cd3d                	beqz	a0,ffffffffc02026ee <copy_range+0x12a>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0202672:	601c                	ld	a5,0(s0)
    if (!(pte & PTE_V))
ffffffffc0202674:	0017f713          	andi	a4,a5,1
ffffffffc0202678:	cb69                	beqz	a4,ffffffffc020274a <copy_range+0x186>
    if (PPN(pa) >= npage)
ffffffffc020267a:	000c3703          	ld	a4,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc020267e:	078a                	slli	a5,a5,0x2
ffffffffc0202680:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202682:	08e7f863          	bgeu	a5,a4,ffffffffc0202712 <copy_range+0x14e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202686:	000bb403          	ld	s0,0(s7)
ffffffffc020268a:	97da                	add	a5,a5,s6
ffffffffc020268c:	079a                	slli	a5,a5,0x6
ffffffffc020268e:	943e                	add	s0,s0,a5
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202690:	100027f3          	csrr	a5,sstatus
ffffffffc0202694:	8b89                	andi	a5,a5,2
ffffffffc0202696:	e3a1                	bnez	a5,ffffffffc02026d6 <copy_range+0x112>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202698:	000ab783          	ld	a5,0(s5)
ffffffffc020269c:	4505                	li	a0,1
ffffffffc020269e:	6f9c                	ld	a5,24(a5)
ffffffffc02026a0:	9782                	jalr	a5
            assert(page != NULL);
ffffffffc02026a2:	c821                	beqz	s0,ffffffffc02026f2 <copy_range+0x12e>
            assert(npage != NULL);
ffffffffc02026a4:	fd51                	bnez	a0,ffffffffc0202640 <copy_range+0x7c>
ffffffffc02026a6:	00004697          	auipc	a3,0x4
ffffffffc02026aa:	faa68693          	addi	a3,a3,-86 # ffffffffc0206650 <default_pmm_manager+0x1b8>
ffffffffc02026ae:	00004617          	auipc	a2,0x4
ffffffffc02026b2:	a3a60613          	addi	a2,a2,-1478 # ffffffffc02060e8 <commands+0x860>
ffffffffc02026b6:	19500593          	li	a1,405
ffffffffc02026ba:	00004517          	auipc	a0,0x4
ffffffffc02026be:	f2e50513          	addi	a0,a0,-210 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc02026c2:	dcdfd0ef          	jal	ra,ffffffffc020048e <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02026c6:	9dea                	add	s11,s11,s10
ffffffffc02026c8:	019dfdb3          	and	s11,s11,s9
    } while (start != 0 && start < end);
ffffffffc02026cc:	f60d8de3          	beqz	s11,ffffffffc0202646 <copy_range+0x82>
ffffffffc02026d0:	f49deee3          	bltu	s11,s1,ffffffffc020262c <copy_range+0x68>
ffffffffc02026d4:	bf8d                	j	ffffffffc0202646 <copy_range+0x82>
        intr_disable();
ffffffffc02026d6:	adefe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02026da:	000ab783          	ld	a5,0(s5)
ffffffffc02026de:	4505                	li	a0,1
ffffffffc02026e0:	6f9c                	ld	a5,24(a5)
ffffffffc02026e2:	9782                	jalr	a5
ffffffffc02026e4:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02026e6:	ac8fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02026ea:	6522                	ld	a0,8(sp)
ffffffffc02026ec:	bf5d                	j	ffffffffc02026a2 <copy_range+0xde>
                return -E_NO_MEM;
ffffffffc02026ee:	5571                	li	a0,-4
ffffffffc02026f0:	bfa1                	j	ffffffffc0202648 <copy_range+0x84>
            assert(page != NULL);
ffffffffc02026f2:	00004697          	auipc	a3,0x4
ffffffffc02026f6:	f4e68693          	addi	a3,a3,-178 # ffffffffc0206640 <default_pmm_manager+0x1a8>
ffffffffc02026fa:	00004617          	auipc	a2,0x4
ffffffffc02026fe:	9ee60613          	addi	a2,a2,-1554 # ffffffffc02060e8 <commands+0x860>
ffffffffc0202702:	19400593          	li	a1,404
ffffffffc0202706:	00004517          	auipc	a0,0x4
ffffffffc020270a:	ee250513          	addi	a0,a0,-286 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc020270e:	d81fd0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202712:	00004617          	auipc	a2,0x4
ffffffffc0202716:	e8e60613          	addi	a2,a2,-370 # ffffffffc02065a0 <default_pmm_manager+0x108>
ffffffffc020271a:	06900593          	li	a1,105
ffffffffc020271e:	00004517          	auipc	a0,0x4
ffffffffc0202722:	dda50513          	addi	a0,a0,-550 # ffffffffc02064f8 <default_pmm_manager+0x60>
ffffffffc0202726:	d69fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020272a:	00004697          	auipc	a3,0x4
ffffffffc020272e:	efe68693          	addi	a3,a3,-258 # ffffffffc0206628 <default_pmm_manager+0x190>
ffffffffc0202732:	00004617          	auipc	a2,0x4
ffffffffc0202736:	9b660613          	addi	a2,a2,-1610 # ffffffffc02060e8 <commands+0x860>
ffffffffc020273a:	17c00593          	li	a1,380
ffffffffc020273e:	00004517          	auipc	a0,0x4
ffffffffc0202742:	eaa50513          	addi	a0,a0,-342 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0202746:	d49fd0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020274a:	00004617          	auipc	a2,0x4
ffffffffc020274e:	e7660613          	addi	a2,a2,-394 # ffffffffc02065c0 <default_pmm_manager+0x128>
ffffffffc0202752:	07f00593          	li	a1,127
ffffffffc0202756:	00004517          	auipc	a0,0x4
ffffffffc020275a:	da250513          	addi	a0,a0,-606 # ffffffffc02064f8 <default_pmm_manager+0x60>
ffffffffc020275e:	d31fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202762:	00004697          	auipc	a3,0x4
ffffffffc0202766:	e9668693          	addi	a3,a3,-362 # ffffffffc02065f8 <default_pmm_manager+0x160>
ffffffffc020276a:	00004617          	auipc	a2,0x4
ffffffffc020276e:	97e60613          	addi	a2,a2,-1666 # ffffffffc02060e8 <commands+0x860>
ffffffffc0202772:	17b00593          	li	a1,379
ffffffffc0202776:	00004517          	auipc	a0,0x4
ffffffffc020277a:	e7250513          	addi	a0,a0,-398 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc020277e:	d11fd0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0202782 <page_remove>:
{
ffffffffc0202782:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202784:	4601                	li	a2,0
{
ffffffffc0202786:	ec26                	sd	s1,24(sp)
ffffffffc0202788:	f406                	sd	ra,40(sp)
ffffffffc020278a:	f022                	sd	s0,32(sp)
ffffffffc020278c:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020278e:	fe2ff0ef          	jal	ra,ffffffffc0201f70 <get_pte>
    if (ptep != NULL)
ffffffffc0202792:	c511                	beqz	a0,ffffffffc020279e <page_remove+0x1c>
    if (*ptep & PTE_V)
ffffffffc0202794:	611c                	ld	a5,0(a0)
ffffffffc0202796:	842a                	mv	s0,a0
ffffffffc0202798:	0017f713          	andi	a4,a5,1
ffffffffc020279c:	e711                	bnez	a4,ffffffffc02027a8 <page_remove+0x26>
}
ffffffffc020279e:	70a2                	ld	ra,40(sp)
ffffffffc02027a0:	7402                	ld	s0,32(sp)
ffffffffc02027a2:	64e2                	ld	s1,24(sp)
ffffffffc02027a4:	6145                	addi	sp,sp,48
ffffffffc02027a6:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02027a8:	078a                	slli	a5,a5,0x2
ffffffffc02027aa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02027ac:	000a8717          	auipc	a4,0xa8
ffffffffc02027b0:	f1473703          	ld	a4,-236(a4) # ffffffffc02aa6c0 <npage>
ffffffffc02027b4:	06e7f363          	bgeu	a5,a4,ffffffffc020281a <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc02027b8:	fff80537          	lui	a0,0xfff80
ffffffffc02027bc:	97aa                	add	a5,a5,a0
ffffffffc02027be:	079a                	slli	a5,a5,0x6
ffffffffc02027c0:	000a8517          	auipc	a0,0xa8
ffffffffc02027c4:	f0853503          	ld	a0,-248(a0) # ffffffffc02aa6c8 <pages>
ffffffffc02027c8:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02027ca:	411c                	lw	a5,0(a0)
ffffffffc02027cc:	fff7871b          	addiw	a4,a5,-1
ffffffffc02027d0:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc02027d2:	cb11                	beqz	a4,ffffffffc02027e6 <page_remove+0x64>
        *ptep = 0;
ffffffffc02027d4:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02027d8:	12048073          	sfence.vma	s1
}
ffffffffc02027dc:	70a2                	ld	ra,40(sp)
ffffffffc02027de:	7402                	ld	s0,32(sp)
ffffffffc02027e0:	64e2                	ld	s1,24(sp)
ffffffffc02027e2:	6145                	addi	sp,sp,48
ffffffffc02027e4:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02027e6:	100027f3          	csrr	a5,sstatus
ffffffffc02027ea:	8b89                	andi	a5,a5,2
ffffffffc02027ec:	eb89                	bnez	a5,ffffffffc02027fe <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc02027ee:	000a8797          	auipc	a5,0xa8
ffffffffc02027f2:	ee27b783          	ld	a5,-286(a5) # ffffffffc02aa6d0 <pmm_manager>
ffffffffc02027f6:	739c                	ld	a5,32(a5)
ffffffffc02027f8:	4585                	li	a1,1
ffffffffc02027fa:	9782                	jalr	a5
    if (flag)
ffffffffc02027fc:	bfe1                	j	ffffffffc02027d4 <page_remove+0x52>
        intr_disable();
ffffffffc02027fe:	e42a                	sd	a0,8(sp)
ffffffffc0202800:	9b4fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202804:	000a8797          	auipc	a5,0xa8
ffffffffc0202808:	ecc7b783          	ld	a5,-308(a5) # ffffffffc02aa6d0 <pmm_manager>
ffffffffc020280c:	739c                	ld	a5,32(a5)
ffffffffc020280e:	6522                	ld	a0,8(sp)
ffffffffc0202810:	4585                	li	a1,1
ffffffffc0202812:	9782                	jalr	a5
        intr_enable();
ffffffffc0202814:	99afe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202818:	bf75                	j	ffffffffc02027d4 <page_remove+0x52>
ffffffffc020281a:	e66ff0ef          	jal	ra,ffffffffc0201e80 <pa2page.part.0>

ffffffffc020281e <page_insert>:
{
ffffffffc020281e:	7139                	addi	sp,sp,-64
ffffffffc0202820:	e852                	sd	s4,16(sp)
ffffffffc0202822:	8a32                	mv	s4,a2
ffffffffc0202824:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202826:	4605                	li	a2,1
{
ffffffffc0202828:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020282a:	85d2                	mv	a1,s4
{
ffffffffc020282c:	f426                	sd	s1,40(sp)
ffffffffc020282e:	fc06                	sd	ra,56(sp)
ffffffffc0202830:	f04a                	sd	s2,32(sp)
ffffffffc0202832:	ec4e                	sd	s3,24(sp)
ffffffffc0202834:	e456                	sd	s5,8(sp)
ffffffffc0202836:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202838:	f38ff0ef          	jal	ra,ffffffffc0201f70 <get_pte>
    if (ptep == NULL)
ffffffffc020283c:	c961                	beqz	a0,ffffffffc020290c <page_insert+0xee>
    page->ref += 1;
ffffffffc020283e:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V)
ffffffffc0202840:	611c                	ld	a5,0(a0)
ffffffffc0202842:	89aa                	mv	s3,a0
ffffffffc0202844:	0016871b          	addiw	a4,a3,1
ffffffffc0202848:	c018                	sw	a4,0(s0)
ffffffffc020284a:	0017f713          	andi	a4,a5,1
ffffffffc020284e:	ef05                	bnez	a4,ffffffffc0202886 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0202850:	000a8717          	auipc	a4,0xa8
ffffffffc0202854:	e7873703          	ld	a4,-392(a4) # ffffffffc02aa6c8 <pages>
ffffffffc0202858:	8c19                	sub	s0,s0,a4
ffffffffc020285a:	000807b7          	lui	a5,0x80
ffffffffc020285e:	8419                	srai	s0,s0,0x6
ffffffffc0202860:	943e                	add	s0,s0,a5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202862:	042a                	slli	s0,s0,0xa
ffffffffc0202864:	8cc1                	or	s1,s1,s0
ffffffffc0202866:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc020286a:	0099b023          	sd	s1,0(s3) # 1000 <_binary_obj___user_faultread_out_size-0x8ba8>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020286e:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0202872:	4501                	li	a0,0
}
ffffffffc0202874:	70e2                	ld	ra,56(sp)
ffffffffc0202876:	7442                	ld	s0,48(sp)
ffffffffc0202878:	74a2                	ld	s1,40(sp)
ffffffffc020287a:	7902                	ld	s2,32(sp)
ffffffffc020287c:	69e2                	ld	s3,24(sp)
ffffffffc020287e:	6a42                	ld	s4,16(sp)
ffffffffc0202880:	6aa2                	ld	s5,8(sp)
ffffffffc0202882:	6121                	addi	sp,sp,64
ffffffffc0202884:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202886:	078a                	slli	a5,a5,0x2
ffffffffc0202888:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020288a:	000a8717          	auipc	a4,0xa8
ffffffffc020288e:	e3673703          	ld	a4,-458(a4) # ffffffffc02aa6c0 <npage>
ffffffffc0202892:	06e7ff63          	bgeu	a5,a4,ffffffffc0202910 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0202896:	000a8a97          	auipc	s5,0xa8
ffffffffc020289a:	e32a8a93          	addi	s5,s5,-462 # ffffffffc02aa6c8 <pages>
ffffffffc020289e:	000ab703          	ld	a4,0(s5)
ffffffffc02028a2:	fff80937          	lui	s2,0xfff80
ffffffffc02028a6:	993e                	add	s2,s2,a5
ffffffffc02028a8:	091a                	slli	s2,s2,0x6
ffffffffc02028aa:	993a                	add	s2,s2,a4
        if (p == page)
ffffffffc02028ac:	01240c63          	beq	s0,s2,ffffffffc02028c4 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc02028b0:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fcd5904>
ffffffffc02028b4:	fff7869b          	addiw	a3,a5,-1
ffffffffc02028b8:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) == 0)
ffffffffc02028bc:	c691                	beqz	a3,ffffffffc02028c8 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02028be:	120a0073          	sfence.vma	s4
}
ffffffffc02028c2:	bf59                	j	ffffffffc0202858 <page_insert+0x3a>
ffffffffc02028c4:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc02028c6:	bf49                	j	ffffffffc0202858 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02028c8:	100027f3          	csrr	a5,sstatus
ffffffffc02028cc:	8b89                	andi	a5,a5,2
ffffffffc02028ce:	ef91                	bnez	a5,ffffffffc02028ea <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc02028d0:	000a8797          	auipc	a5,0xa8
ffffffffc02028d4:	e007b783          	ld	a5,-512(a5) # ffffffffc02aa6d0 <pmm_manager>
ffffffffc02028d8:	739c                	ld	a5,32(a5)
ffffffffc02028da:	4585                	li	a1,1
ffffffffc02028dc:	854a                	mv	a0,s2
ffffffffc02028de:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc02028e0:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02028e4:	120a0073          	sfence.vma	s4
ffffffffc02028e8:	bf85                	j	ffffffffc0202858 <page_insert+0x3a>
        intr_disable();
ffffffffc02028ea:	8cafe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02028ee:	000a8797          	auipc	a5,0xa8
ffffffffc02028f2:	de27b783          	ld	a5,-542(a5) # ffffffffc02aa6d0 <pmm_manager>
ffffffffc02028f6:	739c                	ld	a5,32(a5)
ffffffffc02028f8:	4585                	li	a1,1
ffffffffc02028fa:	854a                	mv	a0,s2
ffffffffc02028fc:	9782                	jalr	a5
        intr_enable();
ffffffffc02028fe:	8b0fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202902:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202906:	120a0073          	sfence.vma	s4
ffffffffc020290a:	b7b9                	j	ffffffffc0202858 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc020290c:	5571                	li	a0,-4
ffffffffc020290e:	b79d                	j	ffffffffc0202874 <page_insert+0x56>
ffffffffc0202910:	d70ff0ef          	jal	ra,ffffffffc0201e80 <pa2page.part.0>

ffffffffc0202914 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202914:	00004797          	auipc	a5,0x4
ffffffffc0202918:	b8478793          	addi	a5,a5,-1148 # ffffffffc0206498 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020291c:	638c                	ld	a1,0(a5)
{
ffffffffc020291e:	7159                	addi	sp,sp,-112
ffffffffc0202920:	f85a                	sd	s6,48(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202922:	00004517          	auipc	a0,0x4
ffffffffc0202926:	d3e50513          	addi	a0,a0,-706 # ffffffffc0206660 <default_pmm_manager+0x1c8>
    pmm_manager = &default_pmm_manager;
ffffffffc020292a:	000a8b17          	auipc	s6,0xa8
ffffffffc020292e:	da6b0b13          	addi	s6,s6,-602 # ffffffffc02aa6d0 <pmm_manager>
{
ffffffffc0202932:	f486                	sd	ra,104(sp)
ffffffffc0202934:	e8ca                	sd	s2,80(sp)
ffffffffc0202936:	e4ce                	sd	s3,72(sp)
ffffffffc0202938:	f0a2                	sd	s0,96(sp)
ffffffffc020293a:	eca6                	sd	s1,88(sp)
ffffffffc020293c:	e0d2                	sd	s4,64(sp)
ffffffffc020293e:	fc56                	sd	s5,56(sp)
ffffffffc0202940:	f45e                	sd	s7,40(sp)
ffffffffc0202942:	f062                	sd	s8,32(sp)
ffffffffc0202944:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202946:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020294a:	84bfd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    pmm_manager->init();
ffffffffc020294e:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0202952:	000a8997          	auipc	s3,0xa8
ffffffffc0202956:	d8698993          	addi	s3,s3,-634 # ffffffffc02aa6d8 <va_pa_offset>
    pmm_manager->init();
ffffffffc020295a:	679c                	ld	a5,8(a5)
ffffffffc020295c:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020295e:	57f5                	li	a5,-3
ffffffffc0202960:	07fa                	slli	a5,a5,0x1e
ffffffffc0202962:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc0202966:	834fe0ef          	jal	ra,ffffffffc020099a <get_memory_base>
ffffffffc020296a:	892a                	mv	s2,a0
    uint64_t mem_size = get_memory_size();
ffffffffc020296c:	838fe0ef          	jal	ra,ffffffffc02009a4 <get_memory_size>
    if (mem_size == 0)
ffffffffc0202970:	200505e3          	beqz	a0,ffffffffc020337a <pmm_init+0xa66>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc0202974:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc0202976:	00004517          	auipc	a0,0x4
ffffffffc020297a:	d2250513          	addi	a0,a0,-734 # ffffffffc0206698 <default_pmm_manager+0x200>
ffffffffc020297e:	817fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc0202982:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202986:	fff40693          	addi	a3,s0,-1
ffffffffc020298a:	864a                	mv	a2,s2
ffffffffc020298c:	85a6                	mv	a1,s1
ffffffffc020298e:	00004517          	auipc	a0,0x4
ffffffffc0202992:	d2250513          	addi	a0,a0,-734 # ffffffffc02066b0 <default_pmm_manager+0x218>
ffffffffc0202996:	ffefd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc020299a:	c8000737          	lui	a4,0xc8000
ffffffffc020299e:	87a2                	mv	a5,s0
ffffffffc02029a0:	54876163          	bltu	a4,s0,ffffffffc0202ee2 <pmm_init+0x5ce>
ffffffffc02029a4:	757d                	lui	a0,0xfffff
ffffffffc02029a6:	000a9617          	auipc	a2,0xa9
ffffffffc02029aa:	d5560613          	addi	a2,a2,-683 # ffffffffc02ab6fb <end+0xfff>
ffffffffc02029ae:	8e69                	and	a2,a2,a0
ffffffffc02029b0:	000a8497          	auipc	s1,0xa8
ffffffffc02029b4:	d1048493          	addi	s1,s1,-752 # ffffffffc02aa6c0 <npage>
ffffffffc02029b8:	00c7d513          	srli	a0,a5,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02029bc:	000a8b97          	auipc	s7,0xa8
ffffffffc02029c0:	d0cb8b93          	addi	s7,s7,-756 # ffffffffc02aa6c8 <pages>
    npage = maxpa / PGSIZE;
ffffffffc02029c4:	e088                	sd	a0,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02029c6:	00cbb023          	sd	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02029ca:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02029ce:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02029d0:	02f50863          	beq	a0,a5,ffffffffc0202a00 <pmm_init+0xec>
ffffffffc02029d4:	4781                	li	a5,0
ffffffffc02029d6:	4585                	li	a1,1
ffffffffc02029d8:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc02029dc:	00679513          	slli	a0,a5,0x6
ffffffffc02029e0:	9532                	add	a0,a0,a2
ffffffffc02029e2:	00850713          	addi	a4,a0,8 # fffffffffffff008 <end+0x3fd5490c>
ffffffffc02029e6:	40b7302f          	amoor.d	zero,a1,(a4)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02029ea:	6088                	ld	a0,0(s1)
ffffffffc02029ec:	0785                	addi	a5,a5,1
        SetPageReserved(pages + i);
ffffffffc02029ee:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02029f2:	00d50733          	add	a4,a0,a3
ffffffffc02029f6:	fee7e3e3          	bltu	a5,a4,ffffffffc02029dc <pmm_init+0xc8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02029fa:	071a                	slli	a4,a4,0x6
ffffffffc02029fc:	00e606b3          	add	a3,a2,a4
ffffffffc0202a00:	c02007b7          	lui	a5,0xc0200
ffffffffc0202a04:	2ef6ece3          	bltu	a3,a5,ffffffffc02034fc <pmm_init+0xbe8>
ffffffffc0202a08:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0202a0c:	77fd                	lui	a5,0xfffff
ffffffffc0202a0e:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202a10:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc0202a12:	5086eb63          	bltu	a3,s0,ffffffffc0202f28 <pmm_init+0x614>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202a16:	00004517          	auipc	a0,0x4
ffffffffc0202a1a:	cc250513          	addi	a0,a0,-830 # ffffffffc02066d8 <default_pmm_manager+0x240>
ffffffffc0202a1e:	f76fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc0202a22:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0202a26:	000a8917          	auipc	s2,0xa8
ffffffffc0202a2a:	c9290913          	addi	s2,s2,-878 # ffffffffc02aa6b8 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc0202a2e:	7b9c                	ld	a5,48(a5)
ffffffffc0202a30:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202a32:	00004517          	auipc	a0,0x4
ffffffffc0202a36:	cbe50513          	addi	a0,a0,-834 # ffffffffc02066f0 <default_pmm_manager+0x258>
ffffffffc0202a3a:	f5afd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0202a3e:	00007697          	auipc	a3,0x7
ffffffffc0202a42:	5c268693          	addi	a3,a3,1474 # ffffffffc020a000 <boot_page_table_sv39>
ffffffffc0202a46:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0202a4a:	c02007b7          	lui	a5,0xc0200
ffffffffc0202a4e:	28f6ebe3          	bltu	a3,a5,ffffffffc02034e4 <pmm_init+0xbd0>
ffffffffc0202a52:	0009b783          	ld	a5,0(s3)
ffffffffc0202a56:	8e9d                	sub	a3,a3,a5
ffffffffc0202a58:	000a8797          	auipc	a5,0xa8
ffffffffc0202a5c:	c4d7bc23          	sd	a3,-936(a5) # ffffffffc02aa6b0 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202a60:	100027f3          	csrr	a5,sstatus
ffffffffc0202a64:	8b89                	andi	a5,a5,2
ffffffffc0202a66:	4a079763          	bnez	a5,ffffffffc0202f14 <pmm_init+0x600>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202a6a:	000b3783          	ld	a5,0(s6)
ffffffffc0202a6e:	779c                	ld	a5,40(a5)
ffffffffc0202a70:	9782                	jalr	a5
ffffffffc0202a72:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202a74:	6098                	ld	a4,0(s1)
ffffffffc0202a76:	c80007b7          	lui	a5,0xc8000
ffffffffc0202a7a:	83b1                	srli	a5,a5,0xc
ffffffffc0202a7c:	66e7e363          	bltu	a5,a4,ffffffffc02030e2 <pmm_init+0x7ce>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202a80:	00093503          	ld	a0,0(s2)
ffffffffc0202a84:	62050f63          	beqz	a0,ffffffffc02030c2 <pmm_init+0x7ae>
ffffffffc0202a88:	03451793          	slli	a5,a0,0x34
ffffffffc0202a8c:	62079b63          	bnez	a5,ffffffffc02030c2 <pmm_init+0x7ae>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0202a90:	4601                	li	a2,0
ffffffffc0202a92:	4581                	li	a1,0
ffffffffc0202a94:	f04ff0ef          	jal	ra,ffffffffc0202198 <get_page>
ffffffffc0202a98:	60051563          	bnez	a0,ffffffffc02030a2 <pmm_init+0x78e>
ffffffffc0202a9c:	100027f3          	csrr	a5,sstatus
ffffffffc0202aa0:	8b89                	andi	a5,a5,2
ffffffffc0202aa2:	44079e63          	bnez	a5,ffffffffc0202efe <pmm_init+0x5ea>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202aa6:	000b3783          	ld	a5,0(s6)
ffffffffc0202aaa:	4505                	li	a0,1
ffffffffc0202aac:	6f9c                	ld	a5,24(a5)
ffffffffc0202aae:	9782                	jalr	a5
ffffffffc0202ab0:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0202ab2:	00093503          	ld	a0,0(s2)
ffffffffc0202ab6:	4681                	li	a3,0
ffffffffc0202ab8:	4601                	li	a2,0
ffffffffc0202aba:	85d2                	mv	a1,s4
ffffffffc0202abc:	d63ff0ef          	jal	ra,ffffffffc020281e <page_insert>
ffffffffc0202ac0:	26051ae3          	bnez	a0,ffffffffc0203534 <pmm_init+0xc20>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0202ac4:	00093503          	ld	a0,0(s2)
ffffffffc0202ac8:	4601                	li	a2,0
ffffffffc0202aca:	4581                	li	a1,0
ffffffffc0202acc:	ca4ff0ef          	jal	ra,ffffffffc0201f70 <get_pte>
ffffffffc0202ad0:	240502e3          	beqz	a0,ffffffffc0203514 <pmm_init+0xc00>
    assert(pte2page(*ptep) == p1);
ffffffffc0202ad4:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202ad6:	0017f713          	andi	a4,a5,1
ffffffffc0202ada:	5a070263          	beqz	a4,ffffffffc020307e <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc0202ade:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202ae0:	078a                	slli	a5,a5,0x2
ffffffffc0202ae2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202ae4:	58e7fb63          	bgeu	a5,a4,ffffffffc020307a <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ae8:	000bb683          	ld	a3,0(s7)
ffffffffc0202aec:	fff80637          	lui	a2,0xfff80
ffffffffc0202af0:	97b2                	add	a5,a5,a2
ffffffffc0202af2:	079a                	slli	a5,a5,0x6
ffffffffc0202af4:	97b6                	add	a5,a5,a3
ffffffffc0202af6:	14fa17e3          	bne	s4,a5,ffffffffc0203444 <pmm_init+0xb30>
    assert(page_ref(p1) == 1);
ffffffffc0202afa:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8ba8>
ffffffffc0202afe:	4785                	li	a5,1
ffffffffc0202b00:	12f692e3          	bne	a3,a5,ffffffffc0203424 <pmm_init+0xb10>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0202b04:	00093503          	ld	a0,0(s2)
ffffffffc0202b08:	77fd                	lui	a5,0xfffff
ffffffffc0202b0a:	6114                	ld	a3,0(a0)
ffffffffc0202b0c:	068a                	slli	a3,a3,0x2
ffffffffc0202b0e:	8efd                	and	a3,a3,a5
ffffffffc0202b10:	00c6d613          	srli	a2,a3,0xc
ffffffffc0202b14:	0ee67ce3          	bgeu	a2,a4,ffffffffc020340c <pmm_init+0xaf8>
ffffffffc0202b18:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202b1c:	96e2                	add	a3,a3,s8
ffffffffc0202b1e:	0006ba83          	ld	s5,0(a3)
ffffffffc0202b22:	0a8a                	slli	s5,s5,0x2
ffffffffc0202b24:	00fafab3          	and	s5,s5,a5
ffffffffc0202b28:	00cad793          	srli	a5,s5,0xc
ffffffffc0202b2c:	0ce7f3e3          	bgeu	a5,a4,ffffffffc02033f2 <pmm_init+0xade>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202b30:	4601                	li	a2,0
ffffffffc0202b32:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202b34:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202b36:	c3aff0ef          	jal	ra,ffffffffc0201f70 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202b3a:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202b3c:	55551363          	bne	a0,s5,ffffffffc0203082 <pmm_init+0x76e>
ffffffffc0202b40:	100027f3          	csrr	a5,sstatus
ffffffffc0202b44:	8b89                	andi	a5,a5,2
ffffffffc0202b46:	3a079163          	bnez	a5,ffffffffc0202ee8 <pmm_init+0x5d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202b4a:	000b3783          	ld	a5,0(s6)
ffffffffc0202b4e:	4505                	li	a0,1
ffffffffc0202b50:	6f9c                	ld	a5,24(a5)
ffffffffc0202b52:	9782                	jalr	a5
ffffffffc0202b54:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202b56:	00093503          	ld	a0,0(s2)
ffffffffc0202b5a:	46d1                	li	a3,20
ffffffffc0202b5c:	6605                	lui	a2,0x1
ffffffffc0202b5e:	85e2                	mv	a1,s8
ffffffffc0202b60:	cbfff0ef          	jal	ra,ffffffffc020281e <page_insert>
ffffffffc0202b64:	060517e3          	bnez	a0,ffffffffc02033d2 <pmm_init+0xabe>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202b68:	00093503          	ld	a0,0(s2)
ffffffffc0202b6c:	4601                	li	a2,0
ffffffffc0202b6e:	6585                	lui	a1,0x1
ffffffffc0202b70:	c00ff0ef          	jal	ra,ffffffffc0201f70 <get_pte>
ffffffffc0202b74:	02050fe3          	beqz	a0,ffffffffc02033b2 <pmm_init+0xa9e>
    assert(*ptep & PTE_U);
ffffffffc0202b78:	611c                	ld	a5,0(a0)
ffffffffc0202b7a:	0107f713          	andi	a4,a5,16
ffffffffc0202b7e:	7c070e63          	beqz	a4,ffffffffc020335a <pmm_init+0xa46>
    assert(*ptep & PTE_W);
ffffffffc0202b82:	8b91                	andi	a5,a5,4
ffffffffc0202b84:	7a078b63          	beqz	a5,ffffffffc020333a <pmm_init+0xa26>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0202b88:	00093503          	ld	a0,0(s2)
ffffffffc0202b8c:	611c                	ld	a5,0(a0)
ffffffffc0202b8e:	8bc1                	andi	a5,a5,16
ffffffffc0202b90:	78078563          	beqz	a5,ffffffffc020331a <pmm_init+0xa06>
    assert(page_ref(p2) == 1);
ffffffffc0202b94:	000c2703          	lw	a4,0(s8)
ffffffffc0202b98:	4785                	li	a5,1
ffffffffc0202b9a:	76f71063          	bne	a4,a5,ffffffffc02032fa <pmm_init+0x9e6>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0202b9e:	4681                	li	a3,0
ffffffffc0202ba0:	6605                	lui	a2,0x1
ffffffffc0202ba2:	85d2                	mv	a1,s4
ffffffffc0202ba4:	c7bff0ef          	jal	ra,ffffffffc020281e <page_insert>
ffffffffc0202ba8:	72051963          	bnez	a0,ffffffffc02032da <pmm_init+0x9c6>
    assert(page_ref(p1) == 2);
ffffffffc0202bac:	000a2703          	lw	a4,0(s4)
ffffffffc0202bb0:	4789                	li	a5,2
ffffffffc0202bb2:	70f71463          	bne	a4,a5,ffffffffc02032ba <pmm_init+0x9a6>
    assert(page_ref(p2) == 0);
ffffffffc0202bb6:	000c2783          	lw	a5,0(s8)
ffffffffc0202bba:	6e079063          	bnez	a5,ffffffffc020329a <pmm_init+0x986>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202bbe:	00093503          	ld	a0,0(s2)
ffffffffc0202bc2:	4601                	li	a2,0
ffffffffc0202bc4:	6585                	lui	a1,0x1
ffffffffc0202bc6:	baaff0ef          	jal	ra,ffffffffc0201f70 <get_pte>
ffffffffc0202bca:	6a050863          	beqz	a0,ffffffffc020327a <pmm_init+0x966>
    assert(pte2page(*ptep) == p1);
ffffffffc0202bce:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202bd0:	00177793          	andi	a5,a4,1
ffffffffc0202bd4:	4a078563          	beqz	a5,ffffffffc020307e <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc0202bd8:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202bda:	00271793          	slli	a5,a4,0x2
ffffffffc0202bde:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202be0:	48d7fd63          	bgeu	a5,a3,ffffffffc020307a <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202be4:	000bb683          	ld	a3,0(s7)
ffffffffc0202be8:	fff80ab7          	lui	s5,0xfff80
ffffffffc0202bec:	97d6                	add	a5,a5,s5
ffffffffc0202bee:	079a                	slli	a5,a5,0x6
ffffffffc0202bf0:	97b6                	add	a5,a5,a3
ffffffffc0202bf2:	66fa1463          	bne	s4,a5,ffffffffc020325a <pmm_init+0x946>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202bf6:	8b41                	andi	a4,a4,16
ffffffffc0202bf8:	64071163          	bnez	a4,ffffffffc020323a <pmm_init+0x926>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc0202bfc:	00093503          	ld	a0,0(s2)
ffffffffc0202c00:	4581                	li	a1,0
ffffffffc0202c02:	b81ff0ef          	jal	ra,ffffffffc0202782 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202c06:	000a2c83          	lw	s9,0(s4)
ffffffffc0202c0a:	4785                	li	a5,1
ffffffffc0202c0c:	60fc9763          	bne	s9,a5,ffffffffc020321a <pmm_init+0x906>
    assert(page_ref(p2) == 0);
ffffffffc0202c10:	000c2783          	lw	a5,0(s8)
ffffffffc0202c14:	5e079363          	bnez	a5,ffffffffc02031fa <pmm_init+0x8e6>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc0202c18:	00093503          	ld	a0,0(s2)
ffffffffc0202c1c:	6585                	lui	a1,0x1
ffffffffc0202c1e:	b65ff0ef          	jal	ra,ffffffffc0202782 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202c22:	000a2783          	lw	a5,0(s4)
ffffffffc0202c26:	52079a63          	bnez	a5,ffffffffc020315a <pmm_init+0x846>
    assert(page_ref(p2) == 0);
ffffffffc0202c2a:	000c2783          	lw	a5,0(s8)
ffffffffc0202c2e:	50079663          	bnez	a5,ffffffffc020313a <pmm_init+0x826>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202c32:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202c36:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202c38:	000a3683          	ld	a3,0(s4)
ffffffffc0202c3c:	068a                	slli	a3,a3,0x2
ffffffffc0202c3e:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0202c40:	42b6fd63          	bgeu	a3,a1,ffffffffc020307a <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c44:	000bb503          	ld	a0,0(s7)
ffffffffc0202c48:	96d6                	add	a3,a3,s5
ffffffffc0202c4a:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0202c4c:	00d507b3          	add	a5,a0,a3
ffffffffc0202c50:	439c                	lw	a5,0(a5)
ffffffffc0202c52:	4d979463          	bne	a5,s9,ffffffffc020311a <pmm_init+0x806>
    return page - pages + nbase;
ffffffffc0202c56:	8699                	srai	a3,a3,0x6
ffffffffc0202c58:	00080637          	lui	a2,0x80
ffffffffc0202c5c:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0202c5e:	00c69713          	slli	a4,a3,0xc
ffffffffc0202c62:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202c64:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202c66:	48b77e63          	bgeu	a4,a1,ffffffffc0203102 <pmm_init+0x7ee>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202c6a:	0009b703          	ld	a4,0(s3)
ffffffffc0202c6e:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0202c70:	629c                	ld	a5,0(a3)
ffffffffc0202c72:	078a                	slli	a5,a5,0x2
ffffffffc0202c74:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202c76:	40b7f263          	bgeu	a5,a1,ffffffffc020307a <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c7a:	8f91                	sub	a5,a5,a2
ffffffffc0202c7c:	079a                	slli	a5,a5,0x6
ffffffffc0202c7e:	953e                	add	a0,a0,a5
ffffffffc0202c80:	100027f3          	csrr	a5,sstatus
ffffffffc0202c84:	8b89                	andi	a5,a5,2
ffffffffc0202c86:	30079963          	bnez	a5,ffffffffc0202f98 <pmm_init+0x684>
        pmm_manager->free_pages(base, n);
ffffffffc0202c8a:	000b3783          	ld	a5,0(s6)
ffffffffc0202c8e:	4585                	li	a1,1
ffffffffc0202c90:	739c                	ld	a5,32(a5)
ffffffffc0202c92:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202c94:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202c98:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202c9a:	078a                	slli	a5,a5,0x2
ffffffffc0202c9c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202c9e:	3ce7fe63          	bgeu	a5,a4,ffffffffc020307a <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ca2:	000bb503          	ld	a0,0(s7)
ffffffffc0202ca6:	fff80737          	lui	a4,0xfff80
ffffffffc0202caa:	97ba                	add	a5,a5,a4
ffffffffc0202cac:	079a                	slli	a5,a5,0x6
ffffffffc0202cae:	953e                	add	a0,a0,a5
ffffffffc0202cb0:	100027f3          	csrr	a5,sstatus
ffffffffc0202cb4:	8b89                	andi	a5,a5,2
ffffffffc0202cb6:	2c079563          	bnez	a5,ffffffffc0202f80 <pmm_init+0x66c>
ffffffffc0202cba:	000b3783          	ld	a5,0(s6)
ffffffffc0202cbe:	4585                	li	a1,1
ffffffffc0202cc0:	739c                	ld	a5,32(a5)
ffffffffc0202cc2:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202cc4:	00093783          	ld	a5,0(s2)
ffffffffc0202cc8:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd54904>
    asm volatile("sfence.vma");
ffffffffc0202ccc:	12000073          	sfence.vma
ffffffffc0202cd0:	100027f3          	csrr	a5,sstatus
ffffffffc0202cd4:	8b89                	andi	a5,a5,2
ffffffffc0202cd6:	28079b63          	bnez	a5,ffffffffc0202f6c <pmm_init+0x658>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202cda:	000b3783          	ld	a5,0(s6)
ffffffffc0202cde:	779c                	ld	a5,40(a5)
ffffffffc0202ce0:	9782                	jalr	a5
ffffffffc0202ce2:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202ce4:	4b441b63          	bne	s0,s4,ffffffffc020319a <pmm_init+0x886>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202ce8:	00004517          	auipc	a0,0x4
ffffffffc0202cec:	d3050513          	addi	a0,a0,-720 # ffffffffc0206a18 <default_pmm_manager+0x580>
ffffffffc0202cf0:	ca4fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0202cf4:	100027f3          	csrr	a5,sstatus
ffffffffc0202cf8:	8b89                	andi	a5,a5,2
ffffffffc0202cfa:	24079f63          	bnez	a5,ffffffffc0202f58 <pmm_init+0x644>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202cfe:	000b3783          	ld	a5,0(s6)
ffffffffc0202d02:	779c                	ld	a5,40(a5)
ffffffffc0202d04:	9782                	jalr	a5
ffffffffc0202d06:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202d08:	6098                	ld	a4,0(s1)
ffffffffc0202d0a:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202d0e:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202d10:	00c71793          	slli	a5,a4,0xc
ffffffffc0202d14:	6a05                	lui	s4,0x1
ffffffffc0202d16:	02f47c63          	bgeu	s0,a5,ffffffffc0202d4e <pmm_init+0x43a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202d1a:	00c45793          	srli	a5,s0,0xc
ffffffffc0202d1e:	00093503          	ld	a0,0(s2)
ffffffffc0202d22:	2ee7ff63          	bgeu	a5,a4,ffffffffc0203020 <pmm_init+0x70c>
ffffffffc0202d26:	0009b583          	ld	a1,0(s3)
ffffffffc0202d2a:	4601                	li	a2,0
ffffffffc0202d2c:	95a2                	add	a1,a1,s0
ffffffffc0202d2e:	a42ff0ef          	jal	ra,ffffffffc0201f70 <get_pte>
ffffffffc0202d32:	32050463          	beqz	a0,ffffffffc020305a <pmm_init+0x746>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202d36:	611c                	ld	a5,0(a0)
ffffffffc0202d38:	078a                	slli	a5,a5,0x2
ffffffffc0202d3a:	0157f7b3          	and	a5,a5,s5
ffffffffc0202d3e:	2e879e63          	bne	a5,s0,ffffffffc020303a <pmm_init+0x726>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202d42:	6098                	ld	a4,0(s1)
ffffffffc0202d44:	9452                	add	s0,s0,s4
ffffffffc0202d46:	00c71793          	slli	a5,a4,0xc
ffffffffc0202d4a:	fcf468e3          	bltu	s0,a5,ffffffffc0202d1a <pmm_init+0x406>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc0202d4e:	00093783          	ld	a5,0(s2)
ffffffffc0202d52:	639c                	ld	a5,0(a5)
ffffffffc0202d54:	42079363          	bnez	a5,ffffffffc020317a <pmm_init+0x866>
ffffffffc0202d58:	100027f3          	csrr	a5,sstatus
ffffffffc0202d5c:	8b89                	andi	a5,a5,2
ffffffffc0202d5e:	24079963          	bnez	a5,ffffffffc0202fb0 <pmm_init+0x69c>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202d62:	000b3783          	ld	a5,0(s6)
ffffffffc0202d66:	4505                	li	a0,1
ffffffffc0202d68:	6f9c                	ld	a5,24(a5)
ffffffffc0202d6a:	9782                	jalr	a5
ffffffffc0202d6c:	8a2a                	mv	s4,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202d6e:	00093503          	ld	a0,0(s2)
ffffffffc0202d72:	4699                	li	a3,6
ffffffffc0202d74:	10000613          	li	a2,256
ffffffffc0202d78:	85d2                	mv	a1,s4
ffffffffc0202d7a:	aa5ff0ef          	jal	ra,ffffffffc020281e <page_insert>
ffffffffc0202d7e:	44051e63          	bnez	a0,ffffffffc02031da <pmm_init+0x8c6>
    assert(page_ref(p) == 1);
ffffffffc0202d82:	000a2703          	lw	a4,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8ba8>
ffffffffc0202d86:	4785                	li	a5,1
ffffffffc0202d88:	42f71963          	bne	a4,a5,ffffffffc02031ba <pmm_init+0x8a6>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202d8c:	00093503          	ld	a0,0(s2)
ffffffffc0202d90:	6405                	lui	s0,0x1
ffffffffc0202d92:	4699                	li	a3,6
ffffffffc0202d94:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8aa8>
ffffffffc0202d98:	85d2                	mv	a1,s4
ffffffffc0202d9a:	a85ff0ef          	jal	ra,ffffffffc020281e <page_insert>
ffffffffc0202d9e:	72051363          	bnez	a0,ffffffffc02034c4 <pmm_init+0xbb0>
    assert(page_ref(p) == 2);
ffffffffc0202da2:	000a2703          	lw	a4,0(s4)
ffffffffc0202da6:	4789                	li	a5,2
ffffffffc0202da8:	6ef71e63          	bne	a4,a5,ffffffffc02034a4 <pmm_init+0xb90>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202dac:	00004597          	auipc	a1,0x4
ffffffffc0202db0:	db458593          	addi	a1,a1,-588 # ffffffffc0206b60 <default_pmm_manager+0x6c8>
ffffffffc0202db4:	10000513          	li	a0,256
ffffffffc0202db8:	7ce020ef          	jal	ra,ffffffffc0205586 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202dbc:	10040593          	addi	a1,s0,256
ffffffffc0202dc0:	10000513          	li	a0,256
ffffffffc0202dc4:	7d4020ef          	jal	ra,ffffffffc0205598 <strcmp>
ffffffffc0202dc8:	6a051e63          	bnez	a0,ffffffffc0203484 <pmm_init+0xb70>
    return page - pages + nbase;
ffffffffc0202dcc:	000bb683          	ld	a3,0(s7)
ffffffffc0202dd0:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202dd4:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0202dd6:	40da06b3          	sub	a3,s4,a3
ffffffffc0202dda:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202ddc:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202dde:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202de0:	8031                	srli	s0,s0,0xc
ffffffffc0202de2:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202de6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202de8:	30f77d63          	bgeu	a4,a5,ffffffffc0203102 <pmm_init+0x7ee>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202dec:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202df0:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202df4:	96be                	add	a3,a3,a5
ffffffffc0202df6:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202dfa:	756020ef          	jal	ra,ffffffffc0205550 <strlen>
ffffffffc0202dfe:	66051363          	bnez	a0,ffffffffc0203464 <pmm_init+0xb50>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0202e02:	00093a83          	ld	s5,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202e06:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202e08:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fd54904>
ffffffffc0202e0c:	068a                	slli	a3,a3,0x2
ffffffffc0202e0e:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0202e10:	26f6f563          	bgeu	a3,a5,ffffffffc020307a <pmm_init+0x766>
    return KADDR(page2pa(page));
ffffffffc0202e14:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202e16:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202e18:	2ef47563          	bgeu	s0,a5,ffffffffc0203102 <pmm_init+0x7ee>
ffffffffc0202e1c:	0009b403          	ld	s0,0(s3)
ffffffffc0202e20:	9436                	add	s0,s0,a3
ffffffffc0202e22:	100027f3          	csrr	a5,sstatus
ffffffffc0202e26:	8b89                	andi	a5,a5,2
ffffffffc0202e28:	1e079163          	bnez	a5,ffffffffc020300a <pmm_init+0x6f6>
        pmm_manager->free_pages(base, n);
ffffffffc0202e2c:	000b3783          	ld	a5,0(s6)
ffffffffc0202e30:	4585                	li	a1,1
ffffffffc0202e32:	8552                	mv	a0,s4
ffffffffc0202e34:	739c                	ld	a5,32(a5)
ffffffffc0202e36:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202e38:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage)
ffffffffc0202e3a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202e3c:	078a                	slli	a5,a5,0x2
ffffffffc0202e3e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202e40:	22e7fd63          	bgeu	a5,a4,ffffffffc020307a <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e44:	000bb503          	ld	a0,0(s7)
ffffffffc0202e48:	fff80737          	lui	a4,0xfff80
ffffffffc0202e4c:	97ba                	add	a5,a5,a4
ffffffffc0202e4e:	079a                	slli	a5,a5,0x6
ffffffffc0202e50:	953e                	add	a0,a0,a5
ffffffffc0202e52:	100027f3          	csrr	a5,sstatus
ffffffffc0202e56:	8b89                	andi	a5,a5,2
ffffffffc0202e58:	18079d63          	bnez	a5,ffffffffc0202ff2 <pmm_init+0x6de>
ffffffffc0202e5c:	000b3783          	ld	a5,0(s6)
ffffffffc0202e60:	4585                	li	a1,1
ffffffffc0202e62:	739c                	ld	a5,32(a5)
ffffffffc0202e64:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202e66:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage)
ffffffffc0202e6a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202e6c:	078a                	slli	a5,a5,0x2
ffffffffc0202e6e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202e70:	20e7f563          	bgeu	a5,a4,ffffffffc020307a <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e74:	000bb503          	ld	a0,0(s7)
ffffffffc0202e78:	fff80737          	lui	a4,0xfff80
ffffffffc0202e7c:	97ba                	add	a5,a5,a4
ffffffffc0202e7e:	079a                	slli	a5,a5,0x6
ffffffffc0202e80:	953e                	add	a0,a0,a5
ffffffffc0202e82:	100027f3          	csrr	a5,sstatus
ffffffffc0202e86:	8b89                	andi	a5,a5,2
ffffffffc0202e88:	14079963          	bnez	a5,ffffffffc0202fda <pmm_init+0x6c6>
ffffffffc0202e8c:	000b3783          	ld	a5,0(s6)
ffffffffc0202e90:	4585                	li	a1,1
ffffffffc0202e92:	739c                	ld	a5,32(a5)
ffffffffc0202e94:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202e96:	00093783          	ld	a5,0(s2)
ffffffffc0202e9a:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc0202e9e:	12000073          	sfence.vma
ffffffffc0202ea2:	100027f3          	csrr	a5,sstatus
ffffffffc0202ea6:	8b89                	andi	a5,a5,2
ffffffffc0202ea8:	10079f63          	bnez	a5,ffffffffc0202fc6 <pmm_init+0x6b2>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202eac:	000b3783          	ld	a5,0(s6)
ffffffffc0202eb0:	779c                	ld	a5,40(a5)
ffffffffc0202eb2:	9782                	jalr	a5
ffffffffc0202eb4:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202eb6:	4c8c1e63          	bne	s8,s0,ffffffffc0203392 <pmm_init+0xa7e>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202eba:	00004517          	auipc	a0,0x4
ffffffffc0202ebe:	d1e50513          	addi	a0,a0,-738 # ffffffffc0206bd8 <default_pmm_manager+0x740>
ffffffffc0202ec2:	ad2fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
}
ffffffffc0202ec6:	7406                	ld	s0,96(sp)
ffffffffc0202ec8:	70a6                	ld	ra,104(sp)
ffffffffc0202eca:	64e6                	ld	s1,88(sp)
ffffffffc0202ecc:	6946                	ld	s2,80(sp)
ffffffffc0202ece:	69a6                	ld	s3,72(sp)
ffffffffc0202ed0:	6a06                	ld	s4,64(sp)
ffffffffc0202ed2:	7ae2                	ld	s5,56(sp)
ffffffffc0202ed4:	7b42                	ld	s6,48(sp)
ffffffffc0202ed6:	7ba2                	ld	s7,40(sp)
ffffffffc0202ed8:	7c02                	ld	s8,32(sp)
ffffffffc0202eda:	6ce2                	ld	s9,24(sp)
ffffffffc0202edc:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0202ede:	dd9fe06f          	j	ffffffffc0201cb6 <kmalloc_init>
    npage = maxpa / PGSIZE;
ffffffffc0202ee2:	c80007b7          	lui	a5,0xc8000
ffffffffc0202ee6:	bc7d                	j	ffffffffc02029a4 <pmm_init+0x90>
        intr_disable();
ffffffffc0202ee8:	acdfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202eec:	000b3783          	ld	a5,0(s6)
ffffffffc0202ef0:	4505                	li	a0,1
ffffffffc0202ef2:	6f9c                	ld	a5,24(a5)
ffffffffc0202ef4:	9782                	jalr	a5
ffffffffc0202ef6:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202ef8:	ab7fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202efc:	b9a9                	j	ffffffffc0202b56 <pmm_init+0x242>
        intr_disable();
ffffffffc0202efe:	ab7fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202f02:	000b3783          	ld	a5,0(s6)
ffffffffc0202f06:	4505                	li	a0,1
ffffffffc0202f08:	6f9c                	ld	a5,24(a5)
ffffffffc0202f0a:	9782                	jalr	a5
ffffffffc0202f0c:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202f0e:	aa1fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202f12:	b645                	j	ffffffffc0202ab2 <pmm_init+0x19e>
        intr_disable();
ffffffffc0202f14:	aa1fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202f18:	000b3783          	ld	a5,0(s6)
ffffffffc0202f1c:	779c                	ld	a5,40(a5)
ffffffffc0202f1e:	9782                	jalr	a5
ffffffffc0202f20:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202f22:	a8dfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202f26:	b6b9                	j	ffffffffc0202a74 <pmm_init+0x160>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202f28:	6705                	lui	a4,0x1
ffffffffc0202f2a:	177d                	addi	a4,a4,-1
ffffffffc0202f2c:	96ba                	add	a3,a3,a4
ffffffffc0202f2e:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc0202f30:	00c7d713          	srli	a4,a5,0xc
ffffffffc0202f34:	14a77363          	bgeu	a4,a0,ffffffffc020307a <pmm_init+0x766>
    pmm_manager->init_memmap(base, n);
ffffffffc0202f38:	000b3683          	ld	a3,0(s6)
    return &pages[PPN(pa) - nbase];
ffffffffc0202f3c:	fff80537          	lui	a0,0xfff80
ffffffffc0202f40:	972a                	add	a4,a4,a0
ffffffffc0202f42:	6a94                	ld	a3,16(a3)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202f44:	8c1d                	sub	s0,s0,a5
ffffffffc0202f46:	00671513          	slli	a0,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0202f4a:	00c45593          	srli	a1,s0,0xc
ffffffffc0202f4e:	9532                	add	a0,a0,a2
ffffffffc0202f50:	9682                	jalr	a3
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202f52:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202f56:	b4c1                	j	ffffffffc0202a16 <pmm_init+0x102>
        intr_disable();
ffffffffc0202f58:	a5dfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202f5c:	000b3783          	ld	a5,0(s6)
ffffffffc0202f60:	779c                	ld	a5,40(a5)
ffffffffc0202f62:	9782                	jalr	a5
ffffffffc0202f64:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202f66:	a49fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202f6a:	bb79                	j	ffffffffc0202d08 <pmm_init+0x3f4>
        intr_disable();
ffffffffc0202f6c:	a49fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202f70:	000b3783          	ld	a5,0(s6)
ffffffffc0202f74:	779c                	ld	a5,40(a5)
ffffffffc0202f76:	9782                	jalr	a5
ffffffffc0202f78:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202f7a:	a35fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202f7e:	b39d                	j	ffffffffc0202ce4 <pmm_init+0x3d0>
ffffffffc0202f80:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202f82:	a33fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202f86:	000b3783          	ld	a5,0(s6)
ffffffffc0202f8a:	6522                	ld	a0,8(sp)
ffffffffc0202f8c:	4585                	li	a1,1
ffffffffc0202f8e:	739c                	ld	a5,32(a5)
ffffffffc0202f90:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f92:	a1dfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202f96:	b33d                	j	ffffffffc0202cc4 <pmm_init+0x3b0>
ffffffffc0202f98:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202f9a:	a1bfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202f9e:	000b3783          	ld	a5,0(s6)
ffffffffc0202fa2:	6522                	ld	a0,8(sp)
ffffffffc0202fa4:	4585                	li	a1,1
ffffffffc0202fa6:	739c                	ld	a5,32(a5)
ffffffffc0202fa8:	9782                	jalr	a5
        intr_enable();
ffffffffc0202faa:	a05fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202fae:	b1dd                	j	ffffffffc0202c94 <pmm_init+0x380>
        intr_disable();
ffffffffc0202fb0:	a05fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202fb4:	000b3783          	ld	a5,0(s6)
ffffffffc0202fb8:	4505                	li	a0,1
ffffffffc0202fba:	6f9c                	ld	a5,24(a5)
ffffffffc0202fbc:	9782                	jalr	a5
ffffffffc0202fbe:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202fc0:	9effd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202fc4:	b36d                	j	ffffffffc0202d6e <pmm_init+0x45a>
        intr_disable();
ffffffffc0202fc6:	9effd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202fca:	000b3783          	ld	a5,0(s6)
ffffffffc0202fce:	779c                	ld	a5,40(a5)
ffffffffc0202fd0:	9782                	jalr	a5
ffffffffc0202fd2:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202fd4:	9dbfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202fd8:	bdf9                	j	ffffffffc0202eb6 <pmm_init+0x5a2>
ffffffffc0202fda:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202fdc:	9d9fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202fe0:	000b3783          	ld	a5,0(s6)
ffffffffc0202fe4:	6522                	ld	a0,8(sp)
ffffffffc0202fe6:	4585                	li	a1,1
ffffffffc0202fe8:	739c                	ld	a5,32(a5)
ffffffffc0202fea:	9782                	jalr	a5
        intr_enable();
ffffffffc0202fec:	9c3fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202ff0:	b55d                	j	ffffffffc0202e96 <pmm_init+0x582>
ffffffffc0202ff2:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202ff4:	9c1fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202ff8:	000b3783          	ld	a5,0(s6)
ffffffffc0202ffc:	6522                	ld	a0,8(sp)
ffffffffc0202ffe:	4585                	li	a1,1
ffffffffc0203000:	739c                	ld	a5,32(a5)
ffffffffc0203002:	9782                	jalr	a5
        intr_enable();
ffffffffc0203004:	9abfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0203008:	bdb9                	j	ffffffffc0202e66 <pmm_init+0x552>
        intr_disable();
ffffffffc020300a:	9abfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc020300e:	000b3783          	ld	a5,0(s6)
ffffffffc0203012:	4585                	li	a1,1
ffffffffc0203014:	8552                	mv	a0,s4
ffffffffc0203016:	739c                	ld	a5,32(a5)
ffffffffc0203018:	9782                	jalr	a5
        intr_enable();
ffffffffc020301a:	995fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020301e:	bd29                	j	ffffffffc0202e38 <pmm_init+0x524>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203020:	86a2                	mv	a3,s0
ffffffffc0203022:	00003617          	auipc	a2,0x3
ffffffffc0203026:	4ae60613          	addi	a2,a2,1198 # ffffffffc02064d0 <default_pmm_manager+0x38>
ffffffffc020302a:	24b00593          	li	a1,587
ffffffffc020302e:	00003517          	auipc	a0,0x3
ffffffffc0203032:	5ba50513          	addi	a0,a0,1466 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203036:	c58fd0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020303a:	00004697          	auipc	a3,0x4
ffffffffc020303e:	a3e68693          	addi	a3,a3,-1474 # ffffffffc0206a78 <default_pmm_manager+0x5e0>
ffffffffc0203042:	00003617          	auipc	a2,0x3
ffffffffc0203046:	0a660613          	addi	a2,a2,166 # ffffffffc02060e8 <commands+0x860>
ffffffffc020304a:	24c00593          	li	a1,588
ffffffffc020304e:	00003517          	auipc	a0,0x3
ffffffffc0203052:	59a50513          	addi	a0,a0,1434 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203056:	c38fd0ef          	jal	ra,ffffffffc020048e <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020305a:	00004697          	auipc	a3,0x4
ffffffffc020305e:	9de68693          	addi	a3,a3,-1570 # ffffffffc0206a38 <default_pmm_manager+0x5a0>
ffffffffc0203062:	00003617          	auipc	a2,0x3
ffffffffc0203066:	08660613          	addi	a2,a2,134 # ffffffffc02060e8 <commands+0x860>
ffffffffc020306a:	24b00593          	li	a1,587
ffffffffc020306e:	00003517          	auipc	a0,0x3
ffffffffc0203072:	57a50513          	addi	a0,a0,1402 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203076:	c18fd0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc020307a:	e07fe0ef          	jal	ra,ffffffffc0201e80 <pa2page.part.0>
ffffffffc020307e:	e1ffe0ef          	jal	ra,ffffffffc0201e9c <pte2page.part.0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0203082:	00003697          	auipc	a3,0x3
ffffffffc0203086:	7ae68693          	addi	a3,a3,1966 # ffffffffc0206830 <default_pmm_manager+0x398>
ffffffffc020308a:	00003617          	auipc	a2,0x3
ffffffffc020308e:	05e60613          	addi	a2,a2,94 # ffffffffc02060e8 <commands+0x860>
ffffffffc0203092:	21b00593          	li	a1,539
ffffffffc0203096:	00003517          	auipc	a0,0x3
ffffffffc020309a:	55250513          	addi	a0,a0,1362 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc020309e:	bf0fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc02030a2:	00003697          	auipc	a3,0x3
ffffffffc02030a6:	6ce68693          	addi	a3,a3,1742 # ffffffffc0206770 <default_pmm_manager+0x2d8>
ffffffffc02030aa:	00003617          	auipc	a2,0x3
ffffffffc02030ae:	03e60613          	addi	a2,a2,62 # ffffffffc02060e8 <commands+0x860>
ffffffffc02030b2:	20e00593          	li	a1,526
ffffffffc02030b6:	00003517          	auipc	a0,0x3
ffffffffc02030ba:	53250513          	addi	a0,a0,1330 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc02030be:	bd0fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc02030c2:	00003697          	auipc	a3,0x3
ffffffffc02030c6:	66e68693          	addi	a3,a3,1646 # ffffffffc0206730 <default_pmm_manager+0x298>
ffffffffc02030ca:	00003617          	auipc	a2,0x3
ffffffffc02030ce:	01e60613          	addi	a2,a2,30 # ffffffffc02060e8 <commands+0x860>
ffffffffc02030d2:	20d00593          	li	a1,525
ffffffffc02030d6:	00003517          	auipc	a0,0x3
ffffffffc02030da:	51250513          	addi	a0,a0,1298 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc02030de:	bb0fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02030e2:	00003697          	auipc	a3,0x3
ffffffffc02030e6:	62e68693          	addi	a3,a3,1582 # ffffffffc0206710 <default_pmm_manager+0x278>
ffffffffc02030ea:	00003617          	auipc	a2,0x3
ffffffffc02030ee:	ffe60613          	addi	a2,a2,-2 # ffffffffc02060e8 <commands+0x860>
ffffffffc02030f2:	20c00593          	li	a1,524
ffffffffc02030f6:	00003517          	auipc	a0,0x3
ffffffffc02030fa:	4f250513          	addi	a0,a0,1266 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc02030fe:	b90fd0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc0203102:	00003617          	auipc	a2,0x3
ffffffffc0203106:	3ce60613          	addi	a2,a2,974 # ffffffffc02064d0 <default_pmm_manager+0x38>
ffffffffc020310a:	07100593          	li	a1,113
ffffffffc020310e:	00003517          	auipc	a0,0x3
ffffffffc0203112:	3ea50513          	addi	a0,a0,1002 # ffffffffc02064f8 <default_pmm_manager+0x60>
ffffffffc0203116:	b78fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc020311a:	00004697          	auipc	a3,0x4
ffffffffc020311e:	8a668693          	addi	a3,a3,-1882 # ffffffffc02069c0 <default_pmm_manager+0x528>
ffffffffc0203122:	00003617          	auipc	a2,0x3
ffffffffc0203126:	fc660613          	addi	a2,a2,-58 # ffffffffc02060e8 <commands+0x860>
ffffffffc020312a:	23400593          	li	a1,564
ffffffffc020312e:	00003517          	auipc	a0,0x3
ffffffffc0203132:	4ba50513          	addi	a0,a0,1210 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203136:	b58fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020313a:	00004697          	auipc	a3,0x4
ffffffffc020313e:	83e68693          	addi	a3,a3,-1986 # ffffffffc0206978 <default_pmm_manager+0x4e0>
ffffffffc0203142:	00003617          	auipc	a2,0x3
ffffffffc0203146:	fa660613          	addi	a2,a2,-90 # ffffffffc02060e8 <commands+0x860>
ffffffffc020314a:	23200593          	li	a1,562
ffffffffc020314e:	00003517          	auipc	a0,0x3
ffffffffc0203152:	49a50513          	addi	a0,a0,1178 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203156:	b38fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 0);
ffffffffc020315a:	00004697          	auipc	a3,0x4
ffffffffc020315e:	84e68693          	addi	a3,a3,-1970 # ffffffffc02069a8 <default_pmm_manager+0x510>
ffffffffc0203162:	00003617          	auipc	a2,0x3
ffffffffc0203166:	f8660613          	addi	a2,a2,-122 # ffffffffc02060e8 <commands+0x860>
ffffffffc020316a:	23100593          	li	a1,561
ffffffffc020316e:	00003517          	auipc	a0,0x3
ffffffffc0203172:	47a50513          	addi	a0,a0,1146 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203176:	b18fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc020317a:	00004697          	auipc	a3,0x4
ffffffffc020317e:	91668693          	addi	a3,a3,-1770 # ffffffffc0206a90 <default_pmm_manager+0x5f8>
ffffffffc0203182:	00003617          	auipc	a2,0x3
ffffffffc0203186:	f6660613          	addi	a2,a2,-154 # ffffffffc02060e8 <commands+0x860>
ffffffffc020318a:	24f00593          	li	a1,591
ffffffffc020318e:	00003517          	auipc	a0,0x3
ffffffffc0203192:	45a50513          	addi	a0,a0,1114 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203196:	af8fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc020319a:	00004697          	auipc	a3,0x4
ffffffffc020319e:	85668693          	addi	a3,a3,-1962 # ffffffffc02069f0 <default_pmm_manager+0x558>
ffffffffc02031a2:	00003617          	auipc	a2,0x3
ffffffffc02031a6:	f4660613          	addi	a2,a2,-186 # ffffffffc02060e8 <commands+0x860>
ffffffffc02031aa:	23c00593          	li	a1,572
ffffffffc02031ae:	00003517          	auipc	a0,0x3
ffffffffc02031b2:	43a50513          	addi	a0,a0,1082 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc02031b6:	ad8fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p) == 1);
ffffffffc02031ba:	00004697          	auipc	a3,0x4
ffffffffc02031be:	92e68693          	addi	a3,a3,-1746 # ffffffffc0206ae8 <default_pmm_manager+0x650>
ffffffffc02031c2:	00003617          	auipc	a2,0x3
ffffffffc02031c6:	f2660613          	addi	a2,a2,-218 # ffffffffc02060e8 <commands+0x860>
ffffffffc02031ca:	25400593          	li	a1,596
ffffffffc02031ce:	00003517          	auipc	a0,0x3
ffffffffc02031d2:	41a50513          	addi	a0,a0,1050 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc02031d6:	ab8fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02031da:	00004697          	auipc	a3,0x4
ffffffffc02031de:	8ce68693          	addi	a3,a3,-1842 # ffffffffc0206aa8 <default_pmm_manager+0x610>
ffffffffc02031e2:	00003617          	auipc	a2,0x3
ffffffffc02031e6:	f0660613          	addi	a2,a2,-250 # ffffffffc02060e8 <commands+0x860>
ffffffffc02031ea:	25300593          	li	a1,595
ffffffffc02031ee:	00003517          	auipc	a0,0x3
ffffffffc02031f2:	3fa50513          	addi	a0,a0,1018 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc02031f6:	a98fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02031fa:	00003697          	auipc	a3,0x3
ffffffffc02031fe:	77e68693          	addi	a3,a3,1918 # ffffffffc0206978 <default_pmm_manager+0x4e0>
ffffffffc0203202:	00003617          	auipc	a2,0x3
ffffffffc0203206:	ee660613          	addi	a2,a2,-282 # ffffffffc02060e8 <commands+0x860>
ffffffffc020320a:	22e00593          	li	a1,558
ffffffffc020320e:	00003517          	auipc	a0,0x3
ffffffffc0203212:	3da50513          	addi	a0,a0,986 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203216:	a78fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020321a:	00003697          	auipc	a3,0x3
ffffffffc020321e:	5fe68693          	addi	a3,a3,1534 # ffffffffc0206818 <default_pmm_manager+0x380>
ffffffffc0203222:	00003617          	auipc	a2,0x3
ffffffffc0203226:	ec660613          	addi	a2,a2,-314 # ffffffffc02060e8 <commands+0x860>
ffffffffc020322a:	22d00593          	li	a1,557
ffffffffc020322e:	00003517          	auipc	a0,0x3
ffffffffc0203232:	3ba50513          	addi	a0,a0,954 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203236:	a58fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020323a:	00003697          	auipc	a3,0x3
ffffffffc020323e:	75668693          	addi	a3,a3,1878 # ffffffffc0206990 <default_pmm_manager+0x4f8>
ffffffffc0203242:	00003617          	auipc	a2,0x3
ffffffffc0203246:	ea660613          	addi	a2,a2,-346 # ffffffffc02060e8 <commands+0x860>
ffffffffc020324a:	22a00593          	li	a1,554
ffffffffc020324e:	00003517          	auipc	a0,0x3
ffffffffc0203252:	39a50513          	addi	a0,a0,922 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203256:	a38fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020325a:	00003697          	auipc	a3,0x3
ffffffffc020325e:	5a668693          	addi	a3,a3,1446 # ffffffffc0206800 <default_pmm_manager+0x368>
ffffffffc0203262:	00003617          	auipc	a2,0x3
ffffffffc0203266:	e8660613          	addi	a2,a2,-378 # ffffffffc02060e8 <commands+0x860>
ffffffffc020326a:	22900593          	li	a1,553
ffffffffc020326e:	00003517          	auipc	a0,0x3
ffffffffc0203272:	37a50513          	addi	a0,a0,890 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203276:	a18fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc020327a:	00003697          	auipc	a3,0x3
ffffffffc020327e:	62668693          	addi	a3,a3,1574 # ffffffffc02068a0 <default_pmm_manager+0x408>
ffffffffc0203282:	00003617          	auipc	a2,0x3
ffffffffc0203286:	e6660613          	addi	a2,a2,-410 # ffffffffc02060e8 <commands+0x860>
ffffffffc020328a:	22800593          	li	a1,552
ffffffffc020328e:	00003517          	auipc	a0,0x3
ffffffffc0203292:	35a50513          	addi	a0,a0,858 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203296:	9f8fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020329a:	00003697          	auipc	a3,0x3
ffffffffc020329e:	6de68693          	addi	a3,a3,1758 # ffffffffc0206978 <default_pmm_manager+0x4e0>
ffffffffc02032a2:	00003617          	auipc	a2,0x3
ffffffffc02032a6:	e4660613          	addi	a2,a2,-442 # ffffffffc02060e8 <commands+0x860>
ffffffffc02032aa:	22700593          	li	a1,551
ffffffffc02032ae:	00003517          	auipc	a0,0x3
ffffffffc02032b2:	33a50513          	addi	a0,a0,826 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc02032b6:	9d8fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02032ba:	00003697          	auipc	a3,0x3
ffffffffc02032be:	6a668693          	addi	a3,a3,1702 # ffffffffc0206960 <default_pmm_manager+0x4c8>
ffffffffc02032c2:	00003617          	auipc	a2,0x3
ffffffffc02032c6:	e2660613          	addi	a2,a2,-474 # ffffffffc02060e8 <commands+0x860>
ffffffffc02032ca:	22600593          	li	a1,550
ffffffffc02032ce:	00003517          	auipc	a0,0x3
ffffffffc02032d2:	31a50513          	addi	a0,a0,794 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc02032d6:	9b8fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc02032da:	00003697          	auipc	a3,0x3
ffffffffc02032de:	65668693          	addi	a3,a3,1622 # ffffffffc0206930 <default_pmm_manager+0x498>
ffffffffc02032e2:	00003617          	auipc	a2,0x3
ffffffffc02032e6:	e0660613          	addi	a2,a2,-506 # ffffffffc02060e8 <commands+0x860>
ffffffffc02032ea:	22500593          	li	a1,549
ffffffffc02032ee:	00003517          	auipc	a0,0x3
ffffffffc02032f2:	2fa50513          	addi	a0,a0,762 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc02032f6:	998fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02032fa:	00003697          	auipc	a3,0x3
ffffffffc02032fe:	61e68693          	addi	a3,a3,1566 # ffffffffc0206918 <default_pmm_manager+0x480>
ffffffffc0203302:	00003617          	auipc	a2,0x3
ffffffffc0203306:	de660613          	addi	a2,a2,-538 # ffffffffc02060e8 <commands+0x860>
ffffffffc020330a:	22300593          	li	a1,547
ffffffffc020330e:	00003517          	auipc	a0,0x3
ffffffffc0203312:	2da50513          	addi	a0,a0,730 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203316:	978fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc020331a:	00003697          	auipc	a3,0x3
ffffffffc020331e:	5de68693          	addi	a3,a3,1502 # ffffffffc02068f8 <default_pmm_manager+0x460>
ffffffffc0203322:	00003617          	auipc	a2,0x3
ffffffffc0203326:	dc660613          	addi	a2,a2,-570 # ffffffffc02060e8 <commands+0x860>
ffffffffc020332a:	22200593          	li	a1,546
ffffffffc020332e:	00003517          	auipc	a0,0x3
ffffffffc0203332:	2ba50513          	addi	a0,a0,698 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203336:	958fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(*ptep & PTE_W);
ffffffffc020333a:	00003697          	auipc	a3,0x3
ffffffffc020333e:	5ae68693          	addi	a3,a3,1454 # ffffffffc02068e8 <default_pmm_manager+0x450>
ffffffffc0203342:	00003617          	auipc	a2,0x3
ffffffffc0203346:	da660613          	addi	a2,a2,-602 # ffffffffc02060e8 <commands+0x860>
ffffffffc020334a:	22100593          	li	a1,545
ffffffffc020334e:	00003517          	auipc	a0,0x3
ffffffffc0203352:	29a50513          	addi	a0,a0,666 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203356:	938fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(*ptep & PTE_U);
ffffffffc020335a:	00003697          	auipc	a3,0x3
ffffffffc020335e:	57e68693          	addi	a3,a3,1406 # ffffffffc02068d8 <default_pmm_manager+0x440>
ffffffffc0203362:	00003617          	auipc	a2,0x3
ffffffffc0203366:	d8660613          	addi	a2,a2,-634 # ffffffffc02060e8 <commands+0x860>
ffffffffc020336a:	22000593          	li	a1,544
ffffffffc020336e:	00003517          	auipc	a0,0x3
ffffffffc0203372:	27a50513          	addi	a0,a0,634 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203376:	918fd0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("DTB memory info not available");
ffffffffc020337a:	00003617          	auipc	a2,0x3
ffffffffc020337e:	2fe60613          	addi	a2,a2,766 # ffffffffc0206678 <default_pmm_manager+0x1e0>
ffffffffc0203382:	06500593          	li	a1,101
ffffffffc0203386:	00003517          	auipc	a0,0x3
ffffffffc020338a:	26250513          	addi	a0,a0,610 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc020338e:	900fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0203392:	00003697          	auipc	a3,0x3
ffffffffc0203396:	65e68693          	addi	a3,a3,1630 # ffffffffc02069f0 <default_pmm_manager+0x558>
ffffffffc020339a:	00003617          	auipc	a2,0x3
ffffffffc020339e:	d4e60613          	addi	a2,a2,-690 # ffffffffc02060e8 <commands+0x860>
ffffffffc02033a2:	26600593          	li	a1,614
ffffffffc02033a6:	00003517          	auipc	a0,0x3
ffffffffc02033aa:	24250513          	addi	a0,a0,578 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc02033ae:	8e0fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02033b2:	00003697          	auipc	a3,0x3
ffffffffc02033b6:	4ee68693          	addi	a3,a3,1262 # ffffffffc02068a0 <default_pmm_manager+0x408>
ffffffffc02033ba:	00003617          	auipc	a2,0x3
ffffffffc02033be:	d2e60613          	addi	a2,a2,-722 # ffffffffc02060e8 <commands+0x860>
ffffffffc02033c2:	21f00593          	li	a1,543
ffffffffc02033c6:	00003517          	auipc	a0,0x3
ffffffffc02033ca:	22250513          	addi	a0,a0,546 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc02033ce:	8c0fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02033d2:	00003697          	auipc	a3,0x3
ffffffffc02033d6:	48e68693          	addi	a3,a3,1166 # ffffffffc0206860 <default_pmm_manager+0x3c8>
ffffffffc02033da:	00003617          	auipc	a2,0x3
ffffffffc02033de:	d0e60613          	addi	a2,a2,-754 # ffffffffc02060e8 <commands+0x860>
ffffffffc02033e2:	21e00593          	li	a1,542
ffffffffc02033e6:	00003517          	auipc	a0,0x3
ffffffffc02033ea:	20250513          	addi	a0,a0,514 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc02033ee:	8a0fd0ef          	jal	ra,ffffffffc020048e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02033f2:	86d6                	mv	a3,s5
ffffffffc02033f4:	00003617          	auipc	a2,0x3
ffffffffc02033f8:	0dc60613          	addi	a2,a2,220 # ffffffffc02064d0 <default_pmm_manager+0x38>
ffffffffc02033fc:	21a00593          	li	a1,538
ffffffffc0203400:	00003517          	auipc	a0,0x3
ffffffffc0203404:	1e850513          	addi	a0,a0,488 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203408:	886fd0ef          	jal	ra,ffffffffc020048e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc020340c:	00003617          	auipc	a2,0x3
ffffffffc0203410:	0c460613          	addi	a2,a2,196 # ffffffffc02064d0 <default_pmm_manager+0x38>
ffffffffc0203414:	21900593          	li	a1,537
ffffffffc0203418:	00003517          	auipc	a0,0x3
ffffffffc020341c:	1d050513          	addi	a0,a0,464 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203420:	86efd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203424:	00003697          	auipc	a3,0x3
ffffffffc0203428:	3f468693          	addi	a3,a3,1012 # ffffffffc0206818 <default_pmm_manager+0x380>
ffffffffc020342c:	00003617          	auipc	a2,0x3
ffffffffc0203430:	cbc60613          	addi	a2,a2,-836 # ffffffffc02060e8 <commands+0x860>
ffffffffc0203434:	21700593          	li	a1,535
ffffffffc0203438:	00003517          	auipc	a0,0x3
ffffffffc020343c:	1b050513          	addi	a0,a0,432 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203440:	84efd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203444:	00003697          	auipc	a3,0x3
ffffffffc0203448:	3bc68693          	addi	a3,a3,956 # ffffffffc0206800 <default_pmm_manager+0x368>
ffffffffc020344c:	00003617          	auipc	a2,0x3
ffffffffc0203450:	c9c60613          	addi	a2,a2,-868 # ffffffffc02060e8 <commands+0x860>
ffffffffc0203454:	21600593          	li	a1,534
ffffffffc0203458:	00003517          	auipc	a0,0x3
ffffffffc020345c:	19050513          	addi	a0,a0,400 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203460:	82efd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203464:	00003697          	auipc	a3,0x3
ffffffffc0203468:	74c68693          	addi	a3,a3,1868 # ffffffffc0206bb0 <default_pmm_manager+0x718>
ffffffffc020346c:	00003617          	auipc	a2,0x3
ffffffffc0203470:	c7c60613          	addi	a2,a2,-900 # ffffffffc02060e8 <commands+0x860>
ffffffffc0203474:	25d00593          	li	a1,605
ffffffffc0203478:	00003517          	auipc	a0,0x3
ffffffffc020347c:	17050513          	addi	a0,a0,368 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203480:	80efd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203484:	00003697          	auipc	a3,0x3
ffffffffc0203488:	6f468693          	addi	a3,a3,1780 # ffffffffc0206b78 <default_pmm_manager+0x6e0>
ffffffffc020348c:	00003617          	auipc	a2,0x3
ffffffffc0203490:	c5c60613          	addi	a2,a2,-932 # ffffffffc02060e8 <commands+0x860>
ffffffffc0203494:	25a00593          	li	a1,602
ffffffffc0203498:	00003517          	auipc	a0,0x3
ffffffffc020349c:	15050513          	addi	a0,a0,336 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc02034a0:	feffc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p) == 2);
ffffffffc02034a4:	00003697          	auipc	a3,0x3
ffffffffc02034a8:	6a468693          	addi	a3,a3,1700 # ffffffffc0206b48 <default_pmm_manager+0x6b0>
ffffffffc02034ac:	00003617          	auipc	a2,0x3
ffffffffc02034b0:	c3c60613          	addi	a2,a2,-964 # ffffffffc02060e8 <commands+0x860>
ffffffffc02034b4:	25600593          	li	a1,598
ffffffffc02034b8:	00003517          	auipc	a0,0x3
ffffffffc02034bc:	13050513          	addi	a0,a0,304 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc02034c0:	fcffc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02034c4:	00003697          	auipc	a3,0x3
ffffffffc02034c8:	63c68693          	addi	a3,a3,1596 # ffffffffc0206b00 <default_pmm_manager+0x668>
ffffffffc02034cc:	00003617          	auipc	a2,0x3
ffffffffc02034d0:	c1c60613          	addi	a2,a2,-996 # ffffffffc02060e8 <commands+0x860>
ffffffffc02034d4:	25500593          	li	a1,597
ffffffffc02034d8:	00003517          	auipc	a0,0x3
ffffffffc02034dc:	11050513          	addi	a0,a0,272 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc02034e0:	faffc0ef          	jal	ra,ffffffffc020048e <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc02034e4:	00003617          	auipc	a2,0x3
ffffffffc02034e8:	09460613          	addi	a2,a2,148 # ffffffffc0206578 <default_pmm_manager+0xe0>
ffffffffc02034ec:	0c900593          	li	a1,201
ffffffffc02034f0:	00003517          	auipc	a0,0x3
ffffffffc02034f4:	0f850513          	addi	a0,a0,248 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc02034f8:	f97fc0ef          	jal	ra,ffffffffc020048e <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02034fc:	00003617          	auipc	a2,0x3
ffffffffc0203500:	07c60613          	addi	a2,a2,124 # ffffffffc0206578 <default_pmm_manager+0xe0>
ffffffffc0203504:	08100593          	li	a1,129
ffffffffc0203508:	00003517          	auipc	a0,0x3
ffffffffc020350c:	0e050513          	addi	a0,a0,224 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203510:	f7ffc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0203514:	00003697          	auipc	a3,0x3
ffffffffc0203518:	2bc68693          	addi	a3,a3,700 # ffffffffc02067d0 <default_pmm_manager+0x338>
ffffffffc020351c:	00003617          	auipc	a2,0x3
ffffffffc0203520:	bcc60613          	addi	a2,a2,-1076 # ffffffffc02060e8 <commands+0x860>
ffffffffc0203524:	21500593          	li	a1,533
ffffffffc0203528:	00003517          	auipc	a0,0x3
ffffffffc020352c:	0c050513          	addi	a0,a0,192 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203530:	f5ffc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0203534:	00003697          	auipc	a3,0x3
ffffffffc0203538:	26c68693          	addi	a3,a3,620 # ffffffffc02067a0 <default_pmm_manager+0x308>
ffffffffc020353c:	00003617          	auipc	a2,0x3
ffffffffc0203540:	bac60613          	addi	a2,a2,-1108 # ffffffffc02060e8 <commands+0x860>
ffffffffc0203544:	21200593          	li	a1,530
ffffffffc0203548:	00003517          	auipc	a0,0x3
ffffffffc020354c:	0a050513          	addi	a0,a0,160 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203550:	f3ffc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203554 <pgdir_alloc_page>:
{
ffffffffc0203554:	7179                	addi	sp,sp,-48
ffffffffc0203556:	ec26                	sd	s1,24(sp)
ffffffffc0203558:	e84a                	sd	s2,16(sp)
ffffffffc020355a:	e052                	sd	s4,0(sp)
ffffffffc020355c:	f406                	sd	ra,40(sp)
ffffffffc020355e:	f022                	sd	s0,32(sp)
ffffffffc0203560:	e44e                	sd	s3,8(sp)
ffffffffc0203562:	8a2a                	mv	s4,a0
ffffffffc0203564:	84ae                	mv	s1,a1
ffffffffc0203566:	8932                	mv	s2,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203568:	100027f3          	csrr	a5,sstatus
ffffffffc020356c:	8b89                	andi	a5,a5,2
        page = pmm_manager->alloc_pages(n);
ffffffffc020356e:	000a7997          	auipc	s3,0xa7
ffffffffc0203572:	16298993          	addi	s3,s3,354 # ffffffffc02aa6d0 <pmm_manager>
ffffffffc0203576:	ef8d                	bnez	a5,ffffffffc02035b0 <pgdir_alloc_page+0x5c>
ffffffffc0203578:	0009b783          	ld	a5,0(s3)
ffffffffc020357c:	4505                	li	a0,1
ffffffffc020357e:	6f9c                	ld	a5,24(a5)
ffffffffc0203580:	9782                	jalr	a5
ffffffffc0203582:	842a                	mv	s0,a0
    if (page != NULL)
ffffffffc0203584:	cc09                	beqz	s0,ffffffffc020359e <pgdir_alloc_page+0x4a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc0203586:	86ca                	mv	a3,s2
ffffffffc0203588:	8626                	mv	a2,s1
ffffffffc020358a:	85a2                	mv	a1,s0
ffffffffc020358c:	8552                	mv	a0,s4
ffffffffc020358e:	a90ff0ef          	jal	ra,ffffffffc020281e <page_insert>
ffffffffc0203592:	e915                	bnez	a0,ffffffffc02035c6 <pgdir_alloc_page+0x72>
        assert(page_ref(page) == 1);
ffffffffc0203594:	4018                	lw	a4,0(s0)
        page->pra_vaddr = la;
ffffffffc0203596:	fc04                	sd	s1,56(s0)
        assert(page_ref(page) == 1);
ffffffffc0203598:	4785                	li	a5,1
ffffffffc020359a:	04f71e63          	bne	a4,a5,ffffffffc02035f6 <pgdir_alloc_page+0xa2>
}
ffffffffc020359e:	70a2                	ld	ra,40(sp)
ffffffffc02035a0:	8522                	mv	a0,s0
ffffffffc02035a2:	7402                	ld	s0,32(sp)
ffffffffc02035a4:	64e2                	ld	s1,24(sp)
ffffffffc02035a6:	6942                	ld	s2,16(sp)
ffffffffc02035a8:	69a2                	ld	s3,8(sp)
ffffffffc02035aa:	6a02                	ld	s4,0(sp)
ffffffffc02035ac:	6145                	addi	sp,sp,48
ffffffffc02035ae:	8082                	ret
        intr_disable();
ffffffffc02035b0:	c04fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02035b4:	0009b783          	ld	a5,0(s3)
ffffffffc02035b8:	4505                	li	a0,1
ffffffffc02035ba:	6f9c                	ld	a5,24(a5)
ffffffffc02035bc:	9782                	jalr	a5
ffffffffc02035be:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02035c0:	beefd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02035c4:	b7c1                	j	ffffffffc0203584 <pgdir_alloc_page+0x30>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02035c6:	100027f3          	csrr	a5,sstatus
ffffffffc02035ca:	8b89                	andi	a5,a5,2
ffffffffc02035cc:	eb89                	bnez	a5,ffffffffc02035de <pgdir_alloc_page+0x8a>
        pmm_manager->free_pages(base, n);
ffffffffc02035ce:	0009b783          	ld	a5,0(s3)
ffffffffc02035d2:	8522                	mv	a0,s0
ffffffffc02035d4:	4585                	li	a1,1
ffffffffc02035d6:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc02035d8:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc02035da:	9782                	jalr	a5
    if (flag)
ffffffffc02035dc:	b7c9                	j	ffffffffc020359e <pgdir_alloc_page+0x4a>
        intr_disable();
ffffffffc02035de:	bd6fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc02035e2:	0009b783          	ld	a5,0(s3)
ffffffffc02035e6:	8522                	mv	a0,s0
ffffffffc02035e8:	4585                	li	a1,1
ffffffffc02035ea:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc02035ec:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc02035ee:	9782                	jalr	a5
        intr_enable();
ffffffffc02035f0:	bbefd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02035f4:	b76d                	j	ffffffffc020359e <pgdir_alloc_page+0x4a>
        assert(page_ref(page) == 1);
ffffffffc02035f6:	00003697          	auipc	a3,0x3
ffffffffc02035fa:	60268693          	addi	a3,a3,1538 # ffffffffc0206bf8 <default_pmm_manager+0x760>
ffffffffc02035fe:	00003617          	auipc	a2,0x3
ffffffffc0203602:	aea60613          	addi	a2,a2,-1302 # ffffffffc02060e8 <commands+0x860>
ffffffffc0203606:	1f300593          	li	a1,499
ffffffffc020360a:	00003517          	auipc	a0,0x3
ffffffffc020360e:	fde50513          	addi	a0,a0,-34 # ffffffffc02065e8 <default_pmm_manager+0x150>
ffffffffc0203612:	e7dfc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203616 <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0203616:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203618:	00003697          	auipc	a3,0x3
ffffffffc020361c:	5f868693          	addi	a3,a3,1528 # ffffffffc0206c10 <default_pmm_manager+0x778>
ffffffffc0203620:	00003617          	auipc	a2,0x3
ffffffffc0203624:	ac860613          	addi	a2,a2,-1336 # ffffffffc02060e8 <commands+0x860>
ffffffffc0203628:	07400593          	li	a1,116
ffffffffc020362c:	00003517          	auipc	a0,0x3
ffffffffc0203630:	60450513          	addi	a0,a0,1540 # ffffffffc0206c30 <default_pmm_manager+0x798>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0203634:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0203636:	e59fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020363a <mm_create>:
{
ffffffffc020363a:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020363c:	04000513          	li	a0,64
{
ffffffffc0203640:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203642:	e98fe0ef          	jal	ra,ffffffffc0201cda <kmalloc>
    if (mm != NULL)
ffffffffc0203646:	cd19                	beqz	a0,ffffffffc0203664 <mm_create+0x2a>
    elm->prev = elm->next = elm;
ffffffffc0203648:	e508                	sd	a0,8(a0)
ffffffffc020364a:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc020364c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203650:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203654:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0203658:	02053423          	sd	zero,40(a0)
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc020365c:	02052823          	sw	zero,48(a0)
typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
ffffffffc0203660:	02053c23          	sd	zero,56(a0)
}
ffffffffc0203664:	60a2                	ld	ra,8(sp)
ffffffffc0203666:	0141                	addi	sp,sp,16
ffffffffc0203668:	8082                	ret

ffffffffc020366a <find_vma>:
{
ffffffffc020366a:	86aa                	mv	a3,a0
    if (mm != NULL)
ffffffffc020366c:	c505                	beqz	a0,ffffffffc0203694 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc020366e:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0203670:	c501                	beqz	a0,ffffffffc0203678 <find_vma+0xe>
ffffffffc0203672:	651c                	ld	a5,8(a0)
ffffffffc0203674:	02f5f263          	bgeu	a1,a5,ffffffffc0203698 <find_vma+0x2e>
    return listelm->next;
ffffffffc0203678:	669c                	ld	a5,8(a3)
            while ((le = list_next(le)) != list)
ffffffffc020367a:	00f68d63          	beq	a3,a5,ffffffffc0203694 <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc020367e:	fe87b703          	ld	a4,-24(a5) # ffffffffc7ffffe8 <end+0x7d558ec>
ffffffffc0203682:	00e5e663          	bltu	a1,a4,ffffffffc020368e <find_vma+0x24>
ffffffffc0203686:	ff07b703          	ld	a4,-16(a5)
ffffffffc020368a:	00e5ec63          	bltu	a1,a4,ffffffffc02036a2 <find_vma+0x38>
ffffffffc020368e:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc0203690:	fef697e3          	bne	a3,a5,ffffffffc020367e <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0203694:	4501                	li	a0,0
}
ffffffffc0203696:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0203698:	691c                	ld	a5,16(a0)
ffffffffc020369a:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0203678 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc020369e:	ea88                	sd	a0,16(a3)
ffffffffc02036a0:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc02036a2:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc02036a6:	ea88                	sd	a0,16(a3)
ffffffffc02036a8:	8082                	ret

ffffffffc02036aa <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc02036aa:	6590                	ld	a2,8(a1)
ffffffffc02036ac:	0105b803          	ld	a6,16(a1)
{
ffffffffc02036b0:	1141                	addi	sp,sp,-16
ffffffffc02036b2:	e406                	sd	ra,8(sp)
ffffffffc02036b4:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02036b6:	01066763          	bltu	a2,a6,ffffffffc02036c4 <insert_vma_struct+0x1a>
ffffffffc02036ba:	a085                	j	ffffffffc020371a <insert_vma_struct+0x70>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc02036bc:	fe87b703          	ld	a4,-24(a5)
ffffffffc02036c0:	04e66863          	bltu	a2,a4,ffffffffc0203710 <insert_vma_struct+0x66>
ffffffffc02036c4:	86be                	mv	a3,a5
ffffffffc02036c6:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc02036c8:	fef51ae3          	bne	a0,a5,ffffffffc02036bc <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc02036cc:	02a68463          	beq	a3,a0,ffffffffc02036f4 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02036d0:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02036d4:	fe86b883          	ld	a7,-24(a3)
ffffffffc02036d8:	08e8f163          	bgeu	a7,a4,ffffffffc020375a <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02036dc:	04e66f63          	bltu	a2,a4,ffffffffc020373a <insert_vma_struct+0x90>
    }
    if (le_next != list)
ffffffffc02036e0:	00f50a63          	beq	a0,a5,ffffffffc02036f4 <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc02036e4:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02036e8:	05076963          	bltu	a4,a6,ffffffffc020373a <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02036ec:	ff07b603          	ld	a2,-16(a5)
ffffffffc02036f0:	02c77363          	bgeu	a4,a2,ffffffffc0203716 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc02036f4:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02036f6:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02036f8:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02036fc:	e390                	sd	a2,0(a5)
ffffffffc02036fe:	e690                	sd	a2,8(a3)
}
ffffffffc0203700:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0203702:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203704:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc0203706:	0017079b          	addiw	a5,a4,1
ffffffffc020370a:	d11c                	sw	a5,32(a0)
}
ffffffffc020370c:	0141                	addi	sp,sp,16
ffffffffc020370e:	8082                	ret
    if (le_prev != list)
ffffffffc0203710:	fca690e3          	bne	a3,a0,ffffffffc02036d0 <insert_vma_struct+0x26>
ffffffffc0203714:	bfd1                	j	ffffffffc02036e8 <insert_vma_struct+0x3e>
ffffffffc0203716:	f01ff0ef          	jal	ra,ffffffffc0203616 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc020371a:	00003697          	auipc	a3,0x3
ffffffffc020371e:	52668693          	addi	a3,a3,1318 # ffffffffc0206c40 <default_pmm_manager+0x7a8>
ffffffffc0203722:	00003617          	auipc	a2,0x3
ffffffffc0203726:	9c660613          	addi	a2,a2,-1594 # ffffffffc02060e8 <commands+0x860>
ffffffffc020372a:	07a00593          	li	a1,122
ffffffffc020372e:	00003517          	auipc	a0,0x3
ffffffffc0203732:	50250513          	addi	a0,a0,1282 # ffffffffc0206c30 <default_pmm_manager+0x798>
ffffffffc0203736:	d59fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020373a:	00003697          	auipc	a3,0x3
ffffffffc020373e:	54668693          	addi	a3,a3,1350 # ffffffffc0206c80 <default_pmm_manager+0x7e8>
ffffffffc0203742:	00003617          	auipc	a2,0x3
ffffffffc0203746:	9a660613          	addi	a2,a2,-1626 # ffffffffc02060e8 <commands+0x860>
ffffffffc020374a:	07300593          	li	a1,115
ffffffffc020374e:	00003517          	auipc	a0,0x3
ffffffffc0203752:	4e250513          	addi	a0,a0,1250 # ffffffffc0206c30 <default_pmm_manager+0x798>
ffffffffc0203756:	d39fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020375a:	00003697          	auipc	a3,0x3
ffffffffc020375e:	50668693          	addi	a3,a3,1286 # ffffffffc0206c60 <default_pmm_manager+0x7c8>
ffffffffc0203762:	00003617          	auipc	a2,0x3
ffffffffc0203766:	98660613          	addi	a2,a2,-1658 # ffffffffc02060e8 <commands+0x860>
ffffffffc020376a:	07200593          	li	a1,114
ffffffffc020376e:	00003517          	auipc	a0,0x3
ffffffffc0203772:	4c250513          	addi	a0,a0,1218 # ffffffffc0206c30 <default_pmm_manager+0x798>
ffffffffc0203776:	d19fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020377a <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc020377a:	591c                	lw	a5,48(a0)
{
ffffffffc020377c:	1141                	addi	sp,sp,-16
ffffffffc020377e:	e406                	sd	ra,8(sp)
ffffffffc0203780:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0203782:	e78d                	bnez	a5,ffffffffc02037ac <mm_destroy+0x32>
ffffffffc0203784:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203786:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc0203788:	00a40c63          	beq	s0,a0,ffffffffc02037a0 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020378c:	6118                	ld	a4,0(a0)
ffffffffc020378e:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc0203790:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203792:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203794:	e398                	sd	a4,0(a5)
ffffffffc0203796:	df4fe0ef          	jal	ra,ffffffffc0201d8a <kfree>
    return listelm->next;
ffffffffc020379a:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc020379c:	fea418e3          	bne	s0,a0,ffffffffc020378c <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc02037a0:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc02037a2:	6402                	ld	s0,0(sp)
ffffffffc02037a4:	60a2                	ld	ra,8(sp)
ffffffffc02037a6:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc02037a8:	de2fe06f          	j	ffffffffc0201d8a <kfree>
    assert(mm_count(mm) == 0);
ffffffffc02037ac:	00003697          	auipc	a3,0x3
ffffffffc02037b0:	4f468693          	addi	a3,a3,1268 # ffffffffc0206ca0 <default_pmm_manager+0x808>
ffffffffc02037b4:	00003617          	auipc	a2,0x3
ffffffffc02037b8:	93460613          	addi	a2,a2,-1740 # ffffffffc02060e8 <commands+0x860>
ffffffffc02037bc:	09e00593          	li	a1,158
ffffffffc02037c0:	00003517          	auipc	a0,0x3
ffffffffc02037c4:	47050513          	addi	a0,a0,1136 # ffffffffc0206c30 <default_pmm_manager+0x798>
ffffffffc02037c8:	cc7fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02037cc <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
ffffffffc02037cc:	7139                	addi	sp,sp,-64
ffffffffc02037ce:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02037d0:	6405                	lui	s0,0x1
ffffffffc02037d2:	147d                	addi	s0,s0,-1
ffffffffc02037d4:	77fd                	lui	a5,0xfffff
ffffffffc02037d6:	9622                	add	a2,a2,s0
ffffffffc02037d8:	962e                	add	a2,a2,a1
{
ffffffffc02037da:	f426                	sd	s1,40(sp)
ffffffffc02037dc:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02037de:	00f5f4b3          	and	s1,a1,a5
{
ffffffffc02037e2:	f04a                	sd	s2,32(sp)
ffffffffc02037e4:	ec4e                	sd	s3,24(sp)
ffffffffc02037e6:	e852                	sd	s4,16(sp)
ffffffffc02037e8:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end))
ffffffffc02037ea:	002005b7          	lui	a1,0x200
ffffffffc02037ee:	00f67433          	and	s0,a2,a5
ffffffffc02037f2:	06b4e363          	bltu	s1,a1,ffffffffc0203858 <mm_map+0x8c>
ffffffffc02037f6:	0684f163          	bgeu	s1,s0,ffffffffc0203858 <mm_map+0x8c>
ffffffffc02037fa:	4785                	li	a5,1
ffffffffc02037fc:	07fe                	slli	a5,a5,0x1f
ffffffffc02037fe:	0487ed63          	bltu	a5,s0,ffffffffc0203858 <mm_map+0x8c>
ffffffffc0203802:	89aa                	mv	s3,a0
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0203804:	cd21                	beqz	a0,ffffffffc020385c <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc0203806:	85a6                	mv	a1,s1
ffffffffc0203808:	8ab6                	mv	s5,a3
ffffffffc020380a:	8a3a                	mv	s4,a4
ffffffffc020380c:	e5fff0ef          	jal	ra,ffffffffc020366a <find_vma>
ffffffffc0203810:	c501                	beqz	a0,ffffffffc0203818 <mm_map+0x4c>
ffffffffc0203812:	651c                	ld	a5,8(a0)
ffffffffc0203814:	0487e263          	bltu	a5,s0,ffffffffc0203858 <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203818:	03000513          	li	a0,48
ffffffffc020381c:	cbefe0ef          	jal	ra,ffffffffc0201cda <kmalloc>
ffffffffc0203820:	892a                	mv	s2,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0203822:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc0203824:	02090163          	beqz	s2,ffffffffc0203846 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0203828:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc020382a:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc020382e:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0203832:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0203836:	85ca                	mv	a1,s2
ffffffffc0203838:	e73ff0ef          	jal	ra,ffffffffc02036aa <insert_vma_struct>
    if (vma_store != NULL)
    {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc020383c:	4501                	li	a0,0
    if (vma_store != NULL)
ffffffffc020383e:	000a0463          	beqz	s4,ffffffffc0203846 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc0203842:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0203846:	70e2                	ld	ra,56(sp)
ffffffffc0203848:	7442                	ld	s0,48(sp)
ffffffffc020384a:	74a2                	ld	s1,40(sp)
ffffffffc020384c:	7902                	ld	s2,32(sp)
ffffffffc020384e:	69e2                	ld	s3,24(sp)
ffffffffc0203850:	6a42                	ld	s4,16(sp)
ffffffffc0203852:	6aa2                	ld	s5,8(sp)
ffffffffc0203854:	6121                	addi	sp,sp,64
ffffffffc0203856:	8082                	ret
        return -E_INVAL;
ffffffffc0203858:	5575                	li	a0,-3
ffffffffc020385a:	b7f5                	j	ffffffffc0203846 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc020385c:	00003697          	auipc	a3,0x3
ffffffffc0203860:	45c68693          	addi	a3,a3,1116 # ffffffffc0206cb8 <default_pmm_manager+0x820>
ffffffffc0203864:	00003617          	auipc	a2,0x3
ffffffffc0203868:	88460613          	addi	a2,a2,-1916 # ffffffffc02060e8 <commands+0x860>
ffffffffc020386c:	0b300593          	li	a1,179
ffffffffc0203870:	00003517          	auipc	a0,0x3
ffffffffc0203874:	3c050513          	addi	a0,a0,960 # ffffffffc0206c30 <default_pmm_manager+0x798>
ffffffffc0203878:	c17fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020387c <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc020387c:	7139                	addi	sp,sp,-64
ffffffffc020387e:	fc06                	sd	ra,56(sp)
ffffffffc0203880:	f822                	sd	s0,48(sp)
ffffffffc0203882:	f426                	sd	s1,40(sp)
ffffffffc0203884:	f04a                	sd	s2,32(sp)
ffffffffc0203886:	ec4e                	sd	s3,24(sp)
ffffffffc0203888:	e852                	sd	s4,16(sp)
ffffffffc020388a:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc020388c:	c52d                	beqz	a0,ffffffffc02038f6 <dup_mmap+0x7a>
ffffffffc020388e:	892a                	mv	s2,a0
ffffffffc0203890:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0203892:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0203894:	e595                	bnez	a1,ffffffffc02038c0 <dup_mmap+0x44>
ffffffffc0203896:	a085                	j	ffffffffc02038f6 <dup_mmap+0x7a>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0203898:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc020389a:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4ef0>
        vma->vm_end = vm_end;
ffffffffc020389e:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc02038a2:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc02038a6:	e05ff0ef          	jal	ra,ffffffffc02036aa <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc02038aa:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bb8>
ffffffffc02038ae:	fe843603          	ld	a2,-24(s0)
ffffffffc02038b2:	6c8c                	ld	a1,24(s1)
ffffffffc02038b4:	01893503          	ld	a0,24(s2)
ffffffffc02038b8:	4701                	li	a4,0
ffffffffc02038ba:	d0bfe0ef          	jal	ra,ffffffffc02025c4 <copy_range>
ffffffffc02038be:	e105                	bnez	a0,ffffffffc02038de <dup_mmap+0x62>
    return listelm->prev;
ffffffffc02038c0:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc02038c2:	02848863          	beq	s1,s0,ffffffffc02038f2 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02038c6:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02038ca:	fe843a83          	ld	s5,-24(s0)
ffffffffc02038ce:	ff043a03          	ld	s4,-16(s0)
ffffffffc02038d2:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02038d6:	c04fe0ef          	jal	ra,ffffffffc0201cda <kmalloc>
ffffffffc02038da:	85aa                	mv	a1,a0
    if (vma != NULL)
ffffffffc02038dc:	fd55                	bnez	a0,ffffffffc0203898 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc02038de:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02038e0:	70e2                	ld	ra,56(sp)
ffffffffc02038e2:	7442                	ld	s0,48(sp)
ffffffffc02038e4:	74a2                	ld	s1,40(sp)
ffffffffc02038e6:	7902                	ld	s2,32(sp)
ffffffffc02038e8:	69e2                	ld	s3,24(sp)
ffffffffc02038ea:	6a42                	ld	s4,16(sp)
ffffffffc02038ec:	6aa2                	ld	s5,8(sp)
ffffffffc02038ee:	6121                	addi	sp,sp,64
ffffffffc02038f0:	8082                	ret
    return 0;
ffffffffc02038f2:	4501                	li	a0,0
ffffffffc02038f4:	b7f5                	j	ffffffffc02038e0 <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc02038f6:	00003697          	auipc	a3,0x3
ffffffffc02038fa:	3d268693          	addi	a3,a3,978 # ffffffffc0206cc8 <default_pmm_manager+0x830>
ffffffffc02038fe:	00002617          	auipc	a2,0x2
ffffffffc0203902:	7ea60613          	addi	a2,a2,2026 # ffffffffc02060e8 <commands+0x860>
ffffffffc0203906:	0cf00593          	li	a1,207
ffffffffc020390a:	00003517          	auipc	a0,0x3
ffffffffc020390e:	32650513          	addi	a0,a0,806 # ffffffffc0206c30 <default_pmm_manager+0x798>
ffffffffc0203912:	b7dfc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203916 <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc0203916:	1101                	addi	sp,sp,-32
ffffffffc0203918:	ec06                	sd	ra,24(sp)
ffffffffc020391a:	e822                	sd	s0,16(sp)
ffffffffc020391c:	e426                	sd	s1,8(sp)
ffffffffc020391e:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203920:	c531                	beqz	a0,ffffffffc020396c <exit_mmap+0x56>
ffffffffc0203922:	591c                	lw	a5,48(a0)
ffffffffc0203924:	84aa                	mv	s1,a0
ffffffffc0203926:	e3b9                	bnez	a5,ffffffffc020396c <exit_mmap+0x56>
    return listelm->next;
ffffffffc0203928:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc020392a:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc020392e:	02850663          	beq	a0,s0,ffffffffc020395a <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0203932:	ff043603          	ld	a2,-16(s0)
ffffffffc0203936:	fe843583          	ld	a1,-24(s0)
ffffffffc020393a:	854a                	mv	a0,s2
ffffffffc020393c:	8b1fe0ef          	jal	ra,ffffffffc02021ec <unmap_range>
ffffffffc0203940:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0203942:	fe8498e3          	bne	s1,s0,ffffffffc0203932 <exit_mmap+0x1c>
ffffffffc0203946:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc0203948:	00848c63          	beq	s1,s0,ffffffffc0203960 <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020394c:	ff043603          	ld	a2,-16(s0)
ffffffffc0203950:	fe843583          	ld	a1,-24(s0)
ffffffffc0203954:	854a                	mv	a0,s2
ffffffffc0203956:	9ddfe0ef          	jal	ra,ffffffffc0202332 <exit_range>
ffffffffc020395a:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc020395c:	fe8498e3          	bne	s1,s0,ffffffffc020394c <exit_mmap+0x36>
    }
}
ffffffffc0203960:	60e2                	ld	ra,24(sp)
ffffffffc0203962:	6442                	ld	s0,16(sp)
ffffffffc0203964:	64a2                	ld	s1,8(sp)
ffffffffc0203966:	6902                	ld	s2,0(sp)
ffffffffc0203968:	6105                	addi	sp,sp,32
ffffffffc020396a:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc020396c:	00003697          	auipc	a3,0x3
ffffffffc0203970:	37c68693          	addi	a3,a3,892 # ffffffffc0206ce8 <default_pmm_manager+0x850>
ffffffffc0203974:	00002617          	auipc	a2,0x2
ffffffffc0203978:	77460613          	addi	a2,a2,1908 # ffffffffc02060e8 <commands+0x860>
ffffffffc020397c:	0e800593          	li	a1,232
ffffffffc0203980:	00003517          	auipc	a0,0x3
ffffffffc0203984:	2b050513          	addi	a0,a0,688 # ffffffffc0206c30 <default_pmm_manager+0x798>
ffffffffc0203988:	b07fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020398c <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc020398c:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020398e:	04000513          	li	a0,64
{
ffffffffc0203992:	fc06                	sd	ra,56(sp)
ffffffffc0203994:	f822                	sd	s0,48(sp)
ffffffffc0203996:	f426                	sd	s1,40(sp)
ffffffffc0203998:	f04a                	sd	s2,32(sp)
ffffffffc020399a:	ec4e                	sd	s3,24(sp)
ffffffffc020399c:	e852                	sd	s4,16(sp)
ffffffffc020399e:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02039a0:	b3afe0ef          	jal	ra,ffffffffc0201cda <kmalloc>
    if (mm != NULL)
ffffffffc02039a4:	2e050663          	beqz	a0,ffffffffc0203c90 <vmm_init+0x304>
ffffffffc02039a8:	84aa                	mv	s1,a0
    elm->prev = elm->next = elm;
ffffffffc02039aa:	e508                	sd	a0,8(a0)
ffffffffc02039ac:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02039ae:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02039b2:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02039b6:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc02039ba:	02053423          	sd	zero,40(a0)
ffffffffc02039be:	02052823          	sw	zero,48(a0)
ffffffffc02039c2:	02053c23          	sd	zero,56(a0)
ffffffffc02039c6:	03200413          	li	s0,50
ffffffffc02039ca:	a811                	j	ffffffffc02039de <vmm_init+0x52>
        vma->vm_start = vm_start;
ffffffffc02039cc:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02039ce:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02039d0:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
ffffffffc02039d4:	146d                	addi	s0,s0,-5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02039d6:	8526                	mv	a0,s1
ffffffffc02039d8:	cd3ff0ef          	jal	ra,ffffffffc02036aa <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc02039dc:	c80d                	beqz	s0,ffffffffc0203a0e <vmm_init+0x82>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02039de:	03000513          	li	a0,48
ffffffffc02039e2:	af8fe0ef          	jal	ra,ffffffffc0201cda <kmalloc>
ffffffffc02039e6:	85aa                	mv	a1,a0
ffffffffc02039e8:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc02039ec:	f165                	bnez	a0,ffffffffc02039cc <vmm_init+0x40>
        assert(vma != NULL);
ffffffffc02039ee:	00003697          	auipc	a3,0x3
ffffffffc02039f2:	49268693          	addi	a3,a3,1170 # ffffffffc0206e80 <default_pmm_manager+0x9e8>
ffffffffc02039f6:	00002617          	auipc	a2,0x2
ffffffffc02039fa:	6f260613          	addi	a2,a2,1778 # ffffffffc02060e8 <commands+0x860>
ffffffffc02039fe:	12c00593          	li	a1,300
ffffffffc0203a02:	00003517          	auipc	a0,0x3
ffffffffc0203a06:	22e50513          	addi	a0,a0,558 # ffffffffc0206c30 <default_pmm_manager+0x798>
ffffffffc0203a0a:	a85fc0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc0203a0e:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203a12:	1f900913          	li	s2,505
ffffffffc0203a16:	a819                	j	ffffffffc0203a2c <vmm_init+0xa0>
        vma->vm_start = vm_start;
ffffffffc0203a18:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203a1a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203a1c:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203a20:	0415                	addi	s0,s0,5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203a22:	8526                	mv	a0,s1
ffffffffc0203a24:	c87ff0ef          	jal	ra,ffffffffc02036aa <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203a28:	03240a63          	beq	s0,s2,ffffffffc0203a5c <vmm_init+0xd0>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a2c:	03000513          	li	a0,48
ffffffffc0203a30:	aaafe0ef          	jal	ra,ffffffffc0201cda <kmalloc>
ffffffffc0203a34:	85aa                	mv	a1,a0
ffffffffc0203a36:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0203a3a:	fd79                	bnez	a0,ffffffffc0203a18 <vmm_init+0x8c>
        assert(vma != NULL);
ffffffffc0203a3c:	00003697          	auipc	a3,0x3
ffffffffc0203a40:	44468693          	addi	a3,a3,1092 # ffffffffc0206e80 <default_pmm_manager+0x9e8>
ffffffffc0203a44:	00002617          	auipc	a2,0x2
ffffffffc0203a48:	6a460613          	addi	a2,a2,1700 # ffffffffc02060e8 <commands+0x860>
ffffffffc0203a4c:	13300593          	li	a1,307
ffffffffc0203a50:	00003517          	auipc	a0,0x3
ffffffffc0203a54:	1e050513          	addi	a0,a0,480 # ffffffffc0206c30 <default_pmm_manager+0x798>
ffffffffc0203a58:	a37fc0ef          	jal	ra,ffffffffc020048e <__panic>
    return listelm->next;
ffffffffc0203a5c:	649c                	ld	a5,8(s1)
ffffffffc0203a5e:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0203a60:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0203a64:	16f48663          	beq	s1,a5,ffffffffc0203bd0 <vmm_init+0x244>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203a68:	fe87b603          	ld	a2,-24(a5) # ffffffffffffefe8 <end+0x3fd548ec>
ffffffffc0203a6c:	ffe70693          	addi	a3,a4,-2 # ffe <_binary_obj___user_faultread_out_size-0x8baa>
ffffffffc0203a70:	10d61063          	bne	a2,a3,ffffffffc0203b70 <vmm_init+0x1e4>
ffffffffc0203a74:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203a78:	0ed71c63          	bne	a4,a3,ffffffffc0203b70 <vmm_init+0x1e4>
    for (i = 1; i <= step2; i++)
ffffffffc0203a7c:	0715                	addi	a4,a4,5
ffffffffc0203a7e:	679c                	ld	a5,8(a5)
ffffffffc0203a80:	feb712e3          	bne	a4,a1,ffffffffc0203a64 <vmm_init+0xd8>
ffffffffc0203a84:	4a1d                	li	s4,7
ffffffffc0203a86:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203a88:	1f900a93          	li	s5,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203a8c:	85a2                	mv	a1,s0
ffffffffc0203a8e:	8526                	mv	a0,s1
ffffffffc0203a90:	bdbff0ef          	jal	ra,ffffffffc020366a <find_vma>
ffffffffc0203a94:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0203a96:	16050d63          	beqz	a0,ffffffffc0203c10 <vmm_init+0x284>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0203a9a:	00140593          	addi	a1,s0,1
ffffffffc0203a9e:	8526                	mv	a0,s1
ffffffffc0203aa0:	bcbff0ef          	jal	ra,ffffffffc020366a <find_vma>
ffffffffc0203aa4:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203aa6:	14050563          	beqz	a0,ffffffffc0203bf0 <vmm_init+0x264>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0203aaa:	85d2                	mv	a1,s4
ffffffffc0203aac:	8526                	mv	a0,s1
ffffffffc0203aae:	bbdff0ef          	jal	ra,ffffffffc020366a <find_vma>
        assert(vma3 == NULL);
ffffffffc0203ab2:	16051f63          	bnez	a0,ffffffffc0203c30 <vmm_init+0x2a4>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0203ab6:	00340593          	addi	a1,s0,3
ffffffffc0203aba:	8526                	mv	a0,s1
ffffffffc0203abc:	bafff0ef          	jal	ra,ffffffffc020366a <find_vma>
        assert(vma4 == NULL);
ffffffffc0203ac0:	1a051863          	bnez	a0,ffffffffc0203c70 <vmm_init+0x2e4>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0203ac4:	00440593          	addi	a1,s0,4
ffffffffc0203ac8:	8526                	mv	a0,s1
ffffffffc0203aca:	ba1ff0ef          	jal	ra,ffffffffc020366a <find_vma>
        assert(vma5 == NULL);
ffffffffc0203ace:	18051163          	bnez	a0,ffffffffc0203c50 <vmm_init+0x2c4>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203ad2:	00893783          	ld	a5,8(s2)
ffffffffc0203ad6:	0a879d63          	bne	a5,s0,ffffffffc0203b90 <vmm_init+0x204>
ffffffffc0203ada:	01093783          	ld	a5,16(s2)
ffffffffc0203ade:	0b479963          	bne	a5,s4,ffffffffc0203b90 <vmm_init+0x204>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203ae2:	0089b783          	ld	a5,8(s3)
ffffffffc0203ae6:	0c879563          	bne	a5,s0,ffffffffc0203bb0 <vmm_init+0x224>
ffffffffc0203aea:	0109b783          	ld	a5,16(s3)
ffffffffc0203aee:	0d479163          	bne	a5,s4,ffffffffc0203bb0 <vmm_init+0x224>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203af2:	0415                	addi	s0,s0,5
ffffffffc0203af4:	0a15                	addi	s4,s4,5
ffffffffc0203af6:	f9541be3          	bne	s0,s5,ffffffffc0203a8c <vmm_init+0x100>
ffffffffc0203afa:	4411                	li	s0,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0203afc:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0203afe:	85a2                	mv	a1,s0
ffffffffc0203b00:	8526                	mv	a0,s1
ffffffffc0203b02:	b69ff0ef          	jal	ra,ffffffffc020366a <find_vma>
ffffffffc0203b06:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL)
ffffffffc0203b0a:	c90d                	beqz	a0,ffffffffc0203b3c <vmm_init+0x1b0>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0203b0c:	6914                	ld	a3,16(a0)
ffffffffc0203b0e:	6510                	ld	a2,8(a0)
ffffffffc0203b10:	00003517          	auipc	a0,0x3
ffffffffc0203b14:	2f850513          	addi	a0,a0,760 # ffffffffc0206e08 <default_pmm_manager+0x970>
ffffffffc0203b18:	e7cfc0ef          	jal	ra,ffffffffc0200194 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203b1c:	00003697          	auipc	a3,0x3
ffffffffc0203b20:	31468693          	addi	a3,a3,788 # ffffffffc0206e30 <default_pmm_manager+0x998>
ffffffffc0203b24:	00002617          	auipc	a2,0x2
ffffffffc0203b28:	5c460613          	addi	a2,a2,1476 # ffffffffc02060e8 <commands+0x860>
ffffffffc0203b2c:	15900593          	li	a1,345
ffffffffc0203b30:	00003517          	auipc	a0,0x3
ffffffffc0203b34:	10050513          	addi	a0,a0,256 # ffffffffc0206c30 <default_pmm_manager+0x798>
ffffffffc0203b38:	957fc0ef          	jal	ra,ffffffffc020048e <__panic>
    for (i = 4; i >= 0; i--)
ffffffffc0203b3c:	147d                	addi	s0,s0,-1
ffffffffc0203b3e:	fd2410e3          	bne	s0,s2,ffffffffc0203afe <vmm_init+0x172>
    }

    mm_destroy(mm);
ffffffffc0203b42:	8526                	mv	a0,s1
ffffffffc0203b44:	c37ff0ef          	jal	ra,ffffffffc020377a <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203b48:	00003517          	auipc	a0,0x3
ffffffffc0203b4c:	30050513          	addi	a0,a0,768 # ffffffffc0206e48 <default_pmm_manager+0x9b0>
ffffffffc0203b50:	e44fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
}
ffffffffc0203b54:	7442                	ld	s0,48(sp)
ffffffffc0203b56:	70e2                	ld	ra,56(sp)
ffffffffc0203b58:	74a2                	ld	s1,40(sp)
ffffffffc0203b5a:	7902                	ld	s2,32(sp)
ffffffffc0203b5c:	69e2                	ld	s3,24(sp)
ffffffffc0203b5e:	6a42                	ld	s4,16(sp)
ffffffffc0203b60:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203b62:	00003517          	auipc	a0,0x3
ffffffffc0203b66:	30650513          	addi	a0,a0,774 # ffffffffc0206e68 <default_pmm_manager+0x9d0>
}
ffffffffc0203b6a:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203b6c:	e28fc06f          	j	ffffffffc0200194 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203b70:	00003697          	auipc	a3,0x3
ffffffffc0203b74:	1b068693          	addi	a3,a3,432 # ffffffffc0206d20 <default_pmm_manager+0x888>
ffffffffc0203b78:	00002617          	auipc	a2,0x2
ffffffffc0203b7c:	57060613          	addi	a2,a2,1392 # ffffffffc02060e8 <commands+0x860>
ffffffffc0203b80:	13d00593          	li	a1,317
ffffffffc0203b84:	00003517          	auipc	a0,0x3
ffffffffc0203b88:	0ac50513          	addi	a0,a0,172 # ffffffffc0206c30 <default_pmm_manager+0x798>
ffffffffc0203b8c:	903fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203b90:	00003697          	auipc	a3,0x3
ffffffffc0203b94:	21868693          	addi	a3,a3,536 # ffffffffc0206da8 <default_pmm_manager+0x910>
ffffffffc0203b98:	00002617          	auipc	a2,0x2
ffffffffc0203b9c:	55060613          	addi	a2,a2,1360 # ffffffffc02060e8 <commands+0x860>
ffffffffc0203ba0:	14e00593          	li	a1,334
ffffffffc0203ba4:	00003517          	auipc	a0,0x3
ffffffffc0203ba8:	08c50513          	addi	a0,a0,140 # ffffffffc0206c30 <default_pmm_manager+0x798>
ffffffffc0203bac:	8e3fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203bb0:	00003697          	auipc	a3,0x3
ffffffffc0203bb4:	22868693          	addi	a3,a3,552 # ffffffffc0206dd8 <default_pmm_manager+0x940>
ffffffffc0203bb8:	00002617          	auipc	a2,0x2
ffffffffc0203bbc:	53060613          	addi	a2,a2,1328 # ffffffffc02060e8 <commands+0x860>
ffffffffc0203bc0:	14f00593          	li	a1,335
ffffffffc0203bc4:	00003517          	auipc	a0,0x3
ffffffffc0203bc8:	06c50513          	addi	a0,a0,108 # ffffffffc0206c30 <default_pmm_manager+0x798>
ffffffffc0203bcc:	8c3fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203bd0:	00003697          	auipc	a3,0x3
ffffffffc0203bd4:	13868693          	addi	a3,a3,312 # ffffffffc0206d08 <default_pmm_manager+0x870>
ffffffffc0203bd8:	00002617          	auipc	a2,0x2
ffffffffc0203bdc:	51060613          	addi	a2,a2,1296 # ffffffffc02060e8 <commands+0x860>
ffffffffc0203be0:	13b00593          	li	a1,315
ffffffffc0203be4:	00003517          	auipc	a0,0x3
ffffffffc0203be8:	04c50513          	addi	a0,a0,76 # ffffffffc0206c30 <default_pmm_manager+0x798>
ffffffffc0203bec:	8a3fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma2 != NULL);
ffffffffc0203bf0:	00003697          	auipc	a3,0x3
ffffffffc0203bf4:	17868693          	addi	a3,a3,376 # ffffffffc0206d68 <default_pmm_manager+0x8d0>
ffffffffc0203bf8:	00002617          	auipc	a2,0x2
ffffffffc0203bfc:	4f060613          	addi	a2,a2,1264 # ffffffffc02060e8 <commands+0x860>
ffffffffc0203c00:	14600593          	li	a1,326
ffffffffc0203c04:	00003517          	auipc	a0,0x3
ffffffffc0203c08:	02c50513          	addi	a0,a0,44 # ffffffffc0206c30 <default_pmm_manager+0x798>
ffffffffc0203c0c:	883fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma1 != NULL);
ffffffffc0203c10:	00003697          	auipc	a3,0x3
ffffffffc0203c14:	14868693          	addi	a3,a3,328 # ffffffffc0206d58 <default_pmm_manager+0x8c0>
ffffffffc0203c18:	00002617          	auipc	a2,0x2
ffffffffc0203c1c:	4d060613          	addi	a2,a2,1232 # ffffffffc02060e8 <commands+0x860>
ffffffffc0203c20:	14400593          	li	a1,324
ffffffffc0203c24:	00003517          	auipc	a0,0x3
ffffffffc0203c28:	00c50513          	addi	a0,a0,12 # ffffffffc0206c30 <default_pmm_manager+0x798>
ffffffffc0203c2c:	863fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma3 == NULL);
ffffffffc0203c30:	00003697          	auipc	a3,0x3
ffffffffc0203c34:	14868693          	addi	a3,a3,328 # ffffffffc0206d78 <default_pmm_manager+0x8e0>
ffffffffc0203c38:	00002617          	auipc	a2,0x2
ffffffffc0203c3c:	4b060613          	addi	a2,a2,1200 # ffffffffc02060e8 <commands+0x860>
ffffffffc0203c40:	14800593          	li	a1,328
ffffffffc0203c44:	00003517          	auipc	a0,0x3
ffffffffc0203c48:	fec50513          	addi	a0,a0,-20 # ffffffffc0206c30 <default_pmm_manager+0x798>
ffffffffc0203c4c:	843fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma5 == NULL);
ffffffffc0203c50:	00003697          	auipc	a3,0x3
ffffffffc0203c54:	14868693          	addi	a3,a3,328 # ffffffffc0206d98 <default_pmm_manager+0x900>
ffffffffc0203c58:	00002617          	auipc	a2,0x2
ffffffffc0203c5c:	49060613          	addi	a2,a2,1168 # ffffffffc02060e8 <commands+0x860>
ffffffffc0203c60:	14c00593          	li	a1,332
ffffffffc0203c64:	00003517          	auipc	a0,0x3
ffffffffc0203c68:	fcc50513          	addi	a0,a0,-52 # ffffffffc0206c30 <default_pmm_manager+0x798>
ffffffffc0203c6c:	823fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma4 == NULL);
ffffffffc0203c70:	00003697          	auipc	a3,0x3
ffffffffc0203c74:	11868693          	addi	a3,a3,280 # ffffffffc0206d88 <default_pmm_manager+0x8f0>
ffffffffc0203c78:	00002617          	auipc	a2,0x2
ffffffffc0203c7c:	47060613          	addi	a2,a2,1136 # ffffffffc02060e8 <commands+0x860>
ffffffffc0203c80:	14a00593          	li	a1,330
ffffffffc0203c84:	00003517          	auipc	a0,0x3
ffffffffc0203c88:	fac50513          	addi	a0,a0,-84 # ffffffffc0206c30 <default_pmm_manager+0x798>
ffffffffc0203c8c:	803fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(mm != NULL);
ffffffffc0203c90:	00003697          	auipc	a3,0x3
ffffffffc0203c94:	02868693          	addi	a3,a3,40 # ffffffffc0206cb8 <default_pmm_manager+0x820>
ffffffffc0203c98:	00002617          	auipc	a2,0x2
ffffffffc0203c9c:	45060613          	addi	a2,a2,1104 # ffffffffc02060e8 <commands+0x860>
ffffffffc0203ca0:	12400593          	li	a1,292
ffffffffc0203ca4:	00003517          	auipc	a0,0x3
ffffffffc0203ca8:	f8c50513          	addi	a0,a0,-116 # ffffffffc0206c30 <default_pmm_manager+0x798>
ffffffffc0203cac:	fe2fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203cb0 <user_mem_check>:
}
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc0203cb0:	7179                	addi	sp,sp,-48
ffffffffc0203cb2:	f022                	sd	s0,32(sp)
ffffffffc0203cb4:	f406                	sd	ra,40(sp)
ffffffffc0203cb6:	ec26                	sd	s1,24(sp)
ffffffffc0203cb8:	e84a                	sd	s2,16(sp)
ffffffffc0203cba:	e44e                	sd	s3,8(sp)
ffffffffc0203cbc:	e052                	sd	s4,0(sp)
ffffffffc0203cbe:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc0203cc0:	c135                	beqz	a0,ffffffffc0203d24 <user_mem_check+0x74>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc0203cc2:	002007b7          	lui	a5,0x200
ffffffffc0203cc6:	04f5e663          	bltu	a1,a5,ffffffffc0203d12 <user_mem_check+0x62>
ffffffffc0203cca:	00c584b3          	add	s1,a1,a2
ffffffffc0203cce:	0495f263          	bgeu	a1,s1,ffffffffc0203d12 <user_mem_check+0x62>
ffffffffc0203cd2:	4785                	li	a5,1
ffffffffc0203cd4:	07fe                	slli	a5,a5,0x1f
ffffffffc0203cd6:	0297ee63          	bltu	a5,s1,ffffffffc0203d12 <user_mem_check+0x62>
ffffffffc0203cda:	892a                	mv	s2,a0
ffffffffc0203cdc:	89b6                	mv	s3,a3
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203cde:	6a05                	lui	s4,0x1
ffffffffc0203ce0:	a821                	j	ffffffffc0203cf8 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203ce2:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203ce6:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203ce8:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203cea:	c685                	beqz	a3,ffffffffc0203d12 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203cec:	c399                	beqz	a5,ffffffffc0203cf2 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203cee:	02e46263          	bltu	s0,a4,ffffffffc0203d12 <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0203cf2:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc0203cf4:	04947663          	bgeu	s0,s1,ffffffffc0203d40 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc0203cf8:	85a2                	mv	a1,s0
ffffffffc0203cfa:	854a                	mv	a0,s2
ffffffffc0203cfc:	96fff0ef          	jal	ra,ffffffffc020366a <find_vma>
ffffffffc0203d00:	c909                	beqz	a0,ffffffffc0203d12 <user_mem_check+0x62>
ffffffffc0203d02:	6518                	ld	a4,8(a0)
ffffffffc0203d04:	00e46763          	bltu	s0,a4,ffffffffc0203d12 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203d08:	4d1c                	lw	a5,24(a0)
ffffffffc0203d0a:	fc099ce3          	bnez	s3,ffffffffc0203ce2 <user_mem_check+0x32>
ffffffffc0203d0e:	8b85                	andi	a5,a5,1
ffffffffc0203d10:	f3ed                	bnez	a5,ffffffffc0203cf2 <user_mem_check+0x42>
            return 0;
ffffffffc0203d12:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203d14:	70a2                	ld	ra,40(sp)
ffffffffc0203d16:	7402                	ld	s0,32(sp)
ffffffffc0203d18:	64e2                	ld	s1,24(sp)
ffffffffc0203d1a:	6942                	ld	s2,16(sp)
ffffffffc0203d1c:	69a2                	ld	s3,8(sp)
ffffffffc0203d1e:	6a02                	ld	s4,0(sp)
ffffffffc0203d20:	6145                	addi	sp,sp,48
ffffffffc0203d22:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203d24:	c02007b7          	lui	a5,0xc0200
ffffffffc0203d28:	4501                	li	a0,0
ffffffffc0203d2a:	fef5e5e3          	bltu	a1,a5,ffffffffc0203d14 <user_mem_check+0x64>
ffffffffc0203d2e:	962e                	add	a2,a2,a1
ffffffffc0203d30:	fec5f2e3          	bgeu	a1,a2,ffffffffc0203d14 <user_mem_check+0x64>
ffffffffc0203d34:	c8000537          	lui	a0,0xc8000
ffffffffc0203d38:	0505                	addi	a0,a0,1
ffffffffc0203d3a:	00a63533          	sltu	a0,a2,a0
ffffffffc0203d3e:	bfd9                	j	ffffffffc0203d14 <user_mem_check+0x64>
        return 1;
ffffffffc0203d40:	4505                	li	a0,1
ffffffffc0203d42:	bfc9                	j	ffffffffc0203d14 <user_mem_check+0x64>

ffffffffc0203d44 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0203d44:	8526                	mv	a0,s1
	jalr s0
ffffffffc0203d46:	9402                	jalr	s0

	jal do_exit
ffffffffc0203d48:	5e8000ef          	jal	ra,ffffffffc0204330 <do_exit>

ffffffffc0203d4c <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc0203d4c:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203d4e:	10800513          	li	a0,264
{
ffffffffc0203d52:	e022                	sd	s0,0(sp)
ffffffffc0203d54:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203d56:	f85fd0ef          	jal	ra,ffffffffc0201cda <kmalloc>
ffffffffc0203d5a:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc0203d5c:	cd21                	beqz	a0,ffffffffc0203db4 <alloc_proc+0x68>
         * below fields(add in LAB5) in proc_struct need to be initialized
         *       uint32_t wait_state;                        // waiting state
         *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
         */
        /* 初始化一个新的进程控制块的最基本字段，不进行资源分配 */
        proc->state = PROC_UNINIT;        // 尚未进入就绪态
ffffffffc0203d5e:	57fd                	li	a5,-1
ffffffffc0203d60:	1782                	slli	a5,a5,0x20
ffffffffc0203d62:	e11c                	sd	a5,0(a0)
        proc->runs = 0;                   // 运行次数计数器清零
        proc->kstack = 0;                 // 还未分配内核栈
        proc->need_resched = 0;           // 默认不请求调度
        proc->parent = NULL;              // 父进程待后续设置
        proc->mm = NULL;                  // 地址空间后续 copy/share
        memset(&proc->context, 0, sizeof(struct context)); // 确保首次 switch_to 有确定值
ffffffffc0203d64:	07000613          	li	a2,112
ffffffffc0203d68:	4581                	li	a1,0
        proc->runs = 0;                   // 运行次数计数器清零
ffffffffc0203d6a:	00052423          	sw	zero,8(a0) # ffffffffc8000008 <end+0x7d5590c>
        proc->kstack = 0;                 // 还未分配内核栈
ffffffffc0203d6e:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;           // 默认不请求调度
ffffffffc0203d72:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;              // 父进程待后续设置
ffffffffc0203d76:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;                  // 地址空间后续 copy/share
ffffffffc0203d7a:	02053423          	sd	zero,40(a0)
        memset(&proc->context, 0, sizeof(struct context)); // 确保首次 switch_to 有确定值
ffffffffc0203d7e:	03050513          	addi	a0,a0,48
ffffffffc0203d82:	071010ef          	jal	ra,ffffffffc02055f2 <memset>
        proc->tf = NULL;                  // trapframe 等栈建立后 copy_thread 设置
        proc->pgdir = boot_pgdir_pa;      // 先使用内核页表基址
ffffffffc0203d86:	000a7797          	auipc	a5,0xa7
ffffffffc0203d8a:	92a7b783          	ld	a5,-1750(a5) # ffffffffc02aa6b0 <boot_pgdir_pa>
        proc->tf = NULL;                  // trapframe 等栈建立后 copy_thread 设置
ffffffffc0203d8e:	0a043023          	sd	zero,160(s0)
        proc->pgdir = boot_pgdir_pa;      // 先使用内核页表基址
ffffffffc0203d92:	f45c                	sd	a5,168(s0)
        proc->flags = 0;                  // 初始无标志
ffffffffc0203d94:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, sizeof(proc->name)); // 进程名清零，后续 set_proc_name
ffffffffc0203d98:	4641                	li	a2,16
ffffffffc0203d9a:	4581                	li	a1,0
ffffffffc0203d9c:	0b440513          	addi	a0,s0,180
ffffffffc0203da0:	053010ef          	jal	ra,ffffffffc02055f2 <memset>

        // LAB5: 初始化新增字段
        proc->exit_code = 0;              // 退出码初始化为0
ffffffffc0203da4:	0e043423          	sd	zero,232(s0)
        proc->wait_state = 0;             // 等待状态初始化为0
        proc->cptr = proc->yptr = proc->optr = NULL; // 进程关系指针初始化为NULL
ffffffffc0203da8:	0e043823          	sd	zero,240(s0)
ffffffffc0203dac:	0e043c23          	sd	zero,248(s0)
ffffffffc0203db0:	10043023          	sd	zero,256(s0)
    }
    return proc;
}
ffffffffc0203db4:	60a2                	ld	ra,8(sp)
ffffffffc0203db6:	8522                	mv	a0,s0
ffffffffc0203db8:	6402                	ld	s0,0(sp)
ffffffffc0203dba:	0141                	addi	sp,sp,16
ffffffffc0203dbc:	8082                	ret

ffffffffc0203dbe <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc0203dbe:	000a7797          	auipc	a5,0xa7
ffffffffc0203dc2:	9227b783          	ld	a5,-1758(a5) # ffffffffc02aa6e0 <current>
ffffffffc0203dc6:	73c8                	ld	a0,160(a5)
ffffffffc0203dc8:	986fd06f          	j	ffffffffc0200f4e <forkrets>

ffffffffc0203dcc <user_main>:
// user_main - kernel thread used to exec a user program
static int
user_main(void *arg)
{
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0203dcc:	000a7797          	auipc	a5,0xa7
ffffffffc0203dd0:	9147b783          	ld	a5,-1772(a5) # ffffffffc02aa6e0 <current>
ffffffffc0203dd4:	43cc                	lw	a1,4(a5)
{
ffffffffc0203dd6:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0203dd8:	00003617          	auipc	a2,0x3
ffffffffc0203ddc:	0b860613          	addi	a2,a2,184 # ffffffffc0206e90 <default_pmm_manager+0x9f8>
ffffffffc0203de0:	00003517          	auipc	a0,0x3
ffffffffc0203de4:	0c050513          	addi	a0,a0,192 # ffffffffc0206ea0 <default_pmm_manager+0xa08>
{
ffffffffc0203de8:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0203dea:	baafc0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0203dee:	3fe06797          	auipc	a5,0x3fe06
ffffffffc0203df2:	72278793          	addi	a5,a5,1826 # a510 <_binary_obj___user_faultreadkernel_out_size>
ffffffffc0203df6:	e43e                	sd	a5,8(sp)
ffffffffc0203df8:	00003517          	auipc	a0,0x3
ffffffffc0203dfc:	09850513          	addi	a0,a0,152 # ffffffffc0206e90 <default_pmm_manager+0x9f8>
ffffffffc0203e00:	0003b797          	auipc	a5,0x3b
ffffffffc0203e04:	3d078793          	addi	a5,a5,976 # ffffffffc023f1d0 <_binary_obj___user_faultreadkernel_out_start>
ffffffffc0203e08:	f03e                	sd	a5,32(sp)
ffffffffc0203e0a:	f42a                	sd	a0,40(sp)
    int64_t ret = 0, len = strlen(name);
ffffffffc0203e0c:	e802                	sd	zero,16(sp)
ffffffffc0203e0e:	742010ef          	jal	ra,ffffffffc0205550 <strlen>
ffffffffc0203e12:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0203e14:	4511                	li	a0,4
ffffffffc0203e16:	55a2                	lw	a1,40(sp)
ffffffffc0203e18:	4662                	lw	a2,24(sp)
ffffffffc0203e1a:	5682                	lw	a3,32(sp)
ffffffffc0203e1c:	4722                	lw	a4,8(sp)
ffffffffc0203e1e:	48a9                	li	a7,10
ffffffffc0203e20:	9002                	ebreak
ffffffffc0203e22:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0203e24:	65c2                	ld	a1,16(sp)
ffffffffc0203e26:	00003517          	auipc	a0,0x3
ffffffffc0203e2a:	0a250513          	addi	a0,a0,162 # ffffffffc0206ec8 <default_pmm_manager+0xa30>
ffffffffc0203e2e:	b66fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0203e32:	00003617          	auipc	a2,0x3
ffffffffc0203e36:	0a660613          	addi	a2,a2,166 # ffffffffc0206ed8 <default_pmm_manager+0xa40>
ffffffffc0203e3a:	3b100593          	li	a1,945
ffffffffc0203e3e:	00003517          	auipc	a0,0x3
ffffffffc0203e42:	0ba50513          	addi	a0,a0,186 # ffffffffc0206ef8 <default_pmm_manager+0xa60>
ffffffffc0203e46:	e48fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203e4a <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0203e4a:	6d14                	ld	a3,24(a0)
{
ffffffffc0203e4c:	1141                	addi	sp,sp,-16
ffffffffc0203e4e:	e406                	sd	ra,8(sp)
ffffffffc0203e50:	c02007b7          	lui	a5,0xc0200
ffffffffc0203e54:	02f6ee63          	bltu	a3,a5,ffffffffc0203e90 <put_pgdir+0x46>
ffffffffc0203e58:	000a7517          	auipc	a0,0xa7
ffffffffc0203e5c:	88053503          	ld	a0,-1920(a0) # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc0203e60:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage)
ffffffffc0203e62:	82b1                	srli	a3,a3,0xc
ffffffffc0203e64:	000a7797          	auipc	a5,0xa7
ffffffffc0203e68:	85c7b783          	ld	a5,-1956(a5) # ffffffffc02aa6c0 <npage>
ffffffffc0203e6c:	02f6fe63          	bgeu	a3,a5,ffffffffc0203ea8 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203e70:	00004517          	auipc	a0,0x4
ffffffffc0203e74:	92053503          	ld	a0,-1760(a0) # ffffffffc0207790 <nbase>
}
ffffffffc0203e78:	60a2                	ld	ra,8(sp)
ffffffffc0203e7a:	8e89                	sub	a3,a3,a0
ffffffffc0203e7c:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0203e7e:	000a7517          	auipc	a0,0xa7
ffffffffc0203e82:	84a53503          	ld	a0,-1974(a0) # ffffffffc02aa6c8 <pages>
ffffffffc0203e86:	4585                	li	a1,1
ffffffffc0203e88:	9536                	add	a0,a0,a3
}
ffffffffc0203e8a:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0203e8c:	86afe06f          	j	ffffffffc0201ef6 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0203e90:	00002617          	auipc	a2,0x2
ffffffffc0203e94:	6e860613          	addi	a2,a2,1768 # ffffffffc0206578 <default_pmm_manager+0xe0>
ffffffffc0203e98:	07700593          	li	a1,119
ffffffffc0203e9c:	00002517          	auipc	a0,0x2
ffffffffc0203ea0:	65c50513          	addi	a0,a0,1628 # ffffffffc02064f8 <default_pmm_manager+0x60>
ffffffffc0203ea4:	deafc0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203ea8:	00002617          	auipc	a2,0x2
ffffffffc0203eac:	6f860613          	addi	a2,a2,1784 # ffffffffc02065a0 <default_pmm_manager+0x108>
ffffffffc0203eb0:	06900593          	li	a1,105
ffffffffc0203eb4:	00002517          	auipc	a0,0x2
ffffffffc0203eb8:	64450513          	addi	a0,a0,1604 # ffffffffc02064f8 <default_pmm_manager+0x60>
ffffffffc0203ebc:	dd2fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203ec0 <proc_run>:
{
ffffffffc0203ec0:	7179                	addi	sp,sp,-48
ffffffffc0203ec2:	f026                	sd	s1,32(sp)
    if (proc != current)
ffffffffc0203ec4:	000a7497          	auipc	s1,0xa7
ffffffffc0203ec8:	81c48493          	addi	s1,s1,-2020 # ffffffffc02aa6e0 <current>
ffffffffc0203ecc:	6098                	ld	a4,0(s1)
{
ffffffffc0203ece:	f406                	sd	ra,40(sp)
ffffffffc0203ed0:	ec4a                	sd	s2,24(sp)
    if (proc != current)
ffffffffc0203ed2:	02a70763          	beq	a4,a0,ffffffffc0203f00 <proc_run+0x40>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203ed6:	100027f3          	csrr	a5,sstatus
ffffffffc0203eda:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203edc:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203ede:	ef85                	bnez	a5,ffffffffc0203f16 <proc_run+0x56>
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned long pgdir)
{
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc0203ee0:	755c                	ld	a5,168(a0)
ffffffffc0203ee2:	56fd                	li	a3,-1
ffffffffc0203ee4:	16fe                	slli	a3,a3,0x3f
ffffffffc0203ee6:	83b1                	srli	a5,a5,0xc
            current = proc;
ffffffffc0203ee8:	e088                	sd	a0,0(s1)
ffffffffc0203eea:	8fd5                	or	a5,a5,a3
ffffffffc0203eec:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(proc->context));
ffffffffc0203ef0:	03050593          	addi	a1,a0,48
ffffffffc0203ef4:	03070513          	addi	a0,a4,48
ffffffffc0203ef8:	7ff000ef          	jal	ra,ffffffffc0204ef6 <switch_to>
    if (flag)
ffffffffc0203efc:	00091763          	bnez	s2,ffffffffc0203f0a <proc_run+0x4a>
}
ffffffffc0203f00:	70a2                	ld	ra,40(sp)
ffffffffc0203f02:	7482                	ld	s1,32(sp)
ffffffffc0203f04:	6962                	ld	s2,24(sp)
ffffffffc0203f06:	6145                	addi	sp,sp,48
ffffffffc0203f08:	8082                	ret
ffffffffc0203f0a:	70a2                	ld	ra,40(sp)
ffffffffc0203f0c:	7482                	ld	s1,32(sp)
ffffffffc0203f0e:	6962                	ld	s2,24(sp)
ffffffffc0203f10:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0203f12:	a9dfc06f          	j	ffffffffc02009ae <intr_enable>
ffffffffc0203f16:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203f18:	a9dfc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
            struct proc_struct *prev = current;
ffffffffc0203f1c:	6098                	ld	a4,0(s1)
        return 1;
ffffffffc0203f1e:	6522                	ld	a0,8(sp)
ffffffffc0203f20:	4905                	li	s2,1
ffffffffc0203f22:	bf7d                	j	ffffffffc0203ee0 <proc_run+0x20>

ffffffffc0203f24 <do_fork>:
{
ffffffffc0203f24:	7119                	addi	sp,sp,-128
ffffffffc0203f26:	f4a6                	sd	s1,104(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0203f28:	000a6497          	auipc	s1,0xa6
ffffffffc0203f2c:	7d048493          	addi	s1,s1,2000 # ffffffffc02aa6f8 <nr_process>
ffffffffc0203f30:	4098                	lw	a4,0(s1)
{
ffffffffc0203f32:	fc86                	sd	ra,120(sp)
ffffffffc0203f34:	f8a2                	sd	s0,112(sp)
ffffffffc0203f36:	f0ca                	sd	s2,96(sp)
ffffffffc0203f38:	ecce                	sd	s3,88(sp)
ffffffffc0203f3a:	e8d2                	sd	s4,80(sp)
ffffffffc0203f3c:	e4d6                	sd	s5,72(sp)
ffffffffc0203f3e:	e0da                	sd	s6,64(sp)
ffffffffc0203f40:	fc5e                	sd	s7,56(sp)
ffffffffc0203f42:	f862                	sd	s8,48(sp)
ffffffffc0203f44:	f466                	sd	s9,40(sp)
ffffffffc0203f46:	f06a                	sd	s10,32(sp)
ffffffffc0203f48:	ec6e                	sd	s11,24(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0203f4a:	6785                	lui	a5,0x1
ffffffffc0203f4c:	2ef75f63          	bge	a4,a5,ffffffffc020424a <do_fork+0x326>
ffffffffc0203f50:	8a2a                	mv	s4,a0
ffffffffc0203f52:	892e                	mv	s2,a1
ffffffffc0203f54:	89b2                	mv	s3,a2
        if ((proc = alloc_proc()) == NULL)
ffffffffc0203f56:	df7ff0ef          	jal	ra,ffffffffc0203d4c <alloc_proc>
ffffffffc0203f5a:	842a                	mv	s0,a0
ffffffffc0203f5c:	2e050e63          	beqz	a0,ffffffffc0204258 <do_fork+0x334>
    proc->parent = current;
ffffffffc0203f60:	000a6b97          	auipc	s7,0xa6
ffffffffc0203f64:	780b8b93          	addi	s7,s7,1920 # ffffffffc02aa6e0 <current>
ffffffffc0203f68:	000bb783          	ld	a5,0(s7)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0203f6c:	4509                	li	a0,2
    proc->parent = current;
ffffffffc0203f6e:	f01c                	sd	a5,32(s0)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0203f70:	f49fd0ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
    if (page != NULL)
ffffffffc0203f74:	2c050963          	beqz	a0,ffffffffc0204246 <do_fork+0x322>
    return page - pages + nbase;
ffffffffc0203f78:	000a6c97          	auipc	s9,0xa6
ffffffffc0203f7c:	750c8c93          	addi	s9,s9,1872 # ffffffffc02aa6c8 <pages>
ffffffffc0203f80:	000cb683          	ld	a3,0(s9)
ffffffffc0203f84:	00004a97          	auipc	s5,0x4
ffffffffc0203f88:	80ca8a93          	addi	s5,s5,-2036 # ffffffffc0207790 <nbase>
ffffffffc0203f8c:	000ab703          	ld	a4,0(s5)
ffffffffc0203f90:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0203f94:	000a6d17          	auipc	s10,0xa6
ffffffffc0203f98:	72cd0d13          	addi	s10,s10,1836 # ffffffffc02aa6c0 <npage>
    return page - pages + nbase;
ffffffffc0203f9c:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0203f9e:	5b7d                	li	s6,-1
ffffffffc0203fa0:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc0203fa4:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0203fa6:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0203faa:	0166f633          	and	a2,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0203fae:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203fb0:	2af67b63          	bgeu	a2,a5,ffffffffc0204266 <do_fork+0x342>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0203fb4:	000bb603          	ld	a2,0(s7)
ffffffffc0203fb8:	000a6d97          	auipc	s11,0xa6
ffffffffc0203fbc:	720d8d93          	addi	s11,s11,1824 # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc0203fc0:	000db783          	ld	a5,0(s11)
ffffffffc0203fc4:	02863b83          	ld	s7,40(a2)
ffffffffc0203fc8:	e43a                	sd	a4,8(sp)
ffffffffc0203fca:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0203fcc:	e814                	sd	a3,16(s0)
    if (oldmm == NULL)
ffffffffc0203fce:	020b8863          	beqz	s7,ffffffffc0203ffe <do_fork+0xda>
    if (clone_flags & CLONE_VM)
ffffffffc0203fd2:	100a7a13          	andi	s4,s4,256
ffffffffc0203fd6:	180a0963          	beqz	s4,ffffffffc0204168 <do_fork+0x244>
}

static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
ffffffffc0203fda:	030ba703          	lw	a4,48(s7)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0203fde:	018bb783          	ld	a5,24(s7)
ffffffffc0203fe2:	c02006b7          	lui	a3,0xc0200
ffffffffc0203fe6:	2705                	addiw	a4,a4,1
ffffffffc0203fe8:	02eba823          	sw	a4,48(s7)
    proc->mm = mm;
ffffffffc0203fec:	03743423          	sd	s7,40(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0203ff0:	2ad7e363          	bltu	a5,a3,ffffffffc0204296 <do_fork+0x372>
ffffffffc0203ff4:	000db703          	ld	a4,0(s11)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0203ff8:	6814                	ld	a3,16(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0203ffa:	8f99                	sub	a5,a5,a4
ffffffffc0203ffc:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0203ffe:	6789                	lui	a5,0x2
ffffffffc0204000:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cc8>
ffffffffc0204004:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204006:	864e                	mv	a2,s3
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204008:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc020400a:	87b6                	mv	a5,a3
ffffffffc020400c:	12098893          	addi	a7,s3,288
ffffffffc0204010:	00063803          	ld	a6,0(a2)
ffffffffc0204014:	6608                	ld	a0,8(a2)
ffffffffc0204016:	6a0c                	ld	a1,16(a2)
ffffffffc0204018:	6e18                	ld	a4,24(a2)
ffffffffc020401a:	0107b023          	sd	a6,0(a5)
ffffffffc020401e:	e788                	sd	a0,8(a5)
ffffffffc0204020:	eb8c                	sd	a1,16(a5)
ffffffffc0204022:	ef98                	sd	a4,24(a5)
ffffffffc0204024:	02060613          	addi	a2,a2,32
ffffffffc0204028:	02078793          	addi	a5,a5,32
ffffffffc020402c:	ff1612e3          	bne	a2,a7,ffffffffc0204010 <do_fork+0xec>
    proc->tf->gpr.a0 = 0;
ffffffffc0204030:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x6>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204034:	1c090363          	beqz	s2,ffffffffc02041fa <do_fork+0x2d6>
    if (++last_pid >= MAX_PID)
ffffffffc0204038:	000a2817          	auipc	a6,0xa2
ffffffffc020403c:	21080813          	addi	a6,a6,528 # ffffffffc02a6248 <last_pid.1>
ffffffffc0204040:	00082783          	lw	a5,0(a6)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204044:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204048:	00000717          	auipc	a4,0x0
ffffffffc020404c:	d7670713          	addi	a4,a4,-650 # ffffffffc0203dbe <forkret>
    if (++last_pid >= MAX_PID)
ffffffffc0204050:	0017851b          	addiw	a0,a5,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204054:	f818                	sd	a4,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204056:	fc14                	sd	a3,56(s0)
    if (++last_pid >= MAX_PID)
ffffffffc0204058:	00a82023          	sw	a0,0(a6)
ffffffffc020405c:	6789                	lui	a5,0x2
ffffffffc020405e:	08f55e63          	bge	a0,a5,ffffffffc02040fa <do_fork+0x1d6>
    if (last_pid >= next_safe)
ffffffffc0204062:	000a2317          	auipc	t1,0xa2
ffffffffc0204066:	1ea30313          	addi	t1,t1,490 # ffffffffc02a624c <next_safe.0>
ffffffffc020406a:	00032783          	lw	a5,0(t1)
ffffffffc020406e:	000a6917          	auipc	s2,0xa6
ffffffffc0204072:	5fa90913          	addi	s2,s2,1530 # ffffffffc02aa668 <proc_list>
ffffffffc0204076:	08f55a63          	bge	a0,a5,ffffffffc020410a <do_fork+0x1e6>
    proc->pid = get_pid();
ffffffffc020407a:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020407c:	45a9                	li	a1,10
ffffffffc020407e:	2501                	sext.w	a0,a0
ffffffffc0204080:	0cc010ef          	jal	ra,ffffffffc020514c <hash32>
ffffffffc0204084:	02051793          	slli	a5,a0,0x20
ffffffffc0204088:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020408c:	000a2797          	auipc	a5,0xa2
ffffffffc0204090:	5dc78793          	addi	a5,a5,1500 # ffffffffc02a6668 <hash_list>
ffffffffc0204094:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204096:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204098:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020409a:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc020409e:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02040a0:	00893603          	ld	a2,8(s2)
    prev->next = next->prev = elm;
ffffffffc02040a4:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc02040a6:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc02040a8:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc02040ac:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc02040ae:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc02040b0:	e21c                	sd	a5,0(a2)
ffffffffc02040b2:	00f93423          	sd	a5,8(s2)
    elm->next = next;
ffffffffc02040b6:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc02040b8:	0d243423          	sd	s2,200(s0)
    proc->yptr = NULL;
ffffffffc02040bc:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc02040c0:	10e43023          	sd	a4,256(s0)
ffffffffc02040c4:	c311                	beqz	a4,ffffffffc02040c8 <do_fork+0x1a4>
        proc->optr->yptr = proc;
ffffffffc02040c6:	ff60                	sd	s0,248(a4)
    nr_process++;
ffffffffc02040c8:	409c                	lw	a5,0(s1)
    proc->parent->cptr = proc;
ffffffffc02040ca:	fae0                	sd	s0,240(a3)
    wakeup_proc(proc);
ffffffffc02040cc:	8522                	mv	a0,s0
    nr_process++;
ffffffffc02040ce:	2785                	addiw	a5,a5,1
ffffffffc02040d0:	c09c                	sw	a5,0(s1)
    wakeup_proc(proc);
ffffffffc02040d2:	68f000ef          	jal	ra,ffffffffc0204f60 <wakeup_proc>
    ret = proc->pid;
ffffffffc02040d6:	00442a03          	lw	s4,4(s0)
}
ffffffffc02040da:	70e6                	ld	ra,120(sp)
ffffffffc02040dc:	7446                	ld	s0,112(sp)
ffffffffc02040de:	74a6                	ld	s1,104(sp)
ffffffffc02040e0:	7906                	ld	s2,96(sp)
ffffffffc02040e2:	69e6                	ld	s3,88(sp)
ffffffffc02040e4:	6aa6                	ld	s5,72(sp)
ffffffffc02040e6:	6b06                	ld	s6,64(sp)
ffffffffc02040e8:	7be2                	ld	s7,56(sp)
ffffffffc02040ea:	7c42                	ld	s8,48(sp)
ffffffffc02040ec:	7ca2                	ld	s9,40(sp)
ffffffffc02040ee:	7d02                	ld	s10,32(sp)
ffffffffc02040f0:	6de2                	ld	s11,24(sp)
ffffffffc02040f2:	8552                	mv	a0,s4
ffffffffc02040f4:	6a46                	ld	s4,80(sp)
ffffffffc02040f6:	6109                	addi	sp,sp,128
ffffffffc02040f8:	8082                	ret
        last_pid = 1;
ffffffffc02040fa:	4785                	li	a5,1
ffffffffc02040fc:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc0204100:	4505                	li	a0,1
ffffffffc0204102:	000a2317          	auipc	t1,0xa2
ffffffffc0204106:	14a30313          	addi	t1,t1,330 # ffffffffc02a624c <next_safe.0>
    return listelm->next;
ffffffffc020410a:	000a6917          	auipc	s2,0xa6
ffffffffc020410e:	55e90913          	addi	s2,s2,1374 # ffffffffc02aa668 <proc_list>
ffffffffc0204112:	00893e03          	ld	t3,8(s2)
        next_safe = MAX_PID;
ffffffffc0204116:	6789                	lui	a5,0x2
ffffffffc0204118:	00f32023          	sw	a5,0(t1)
ffffffffc020411c:	86aa                	mv	a3,a0
ffffffffc020411e:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc0204120:	6e89                	lui	t4,0x2
ffffffffc0204122:	132e0663          	beq	t3,s2,ffffffffc020424e <do_fork+0x32a>
ffffffffc0204126:	88ae                	mv	a7,a1
ffffffffc0204128:	87f2                	mv	a5,t3
ffffffffc020412a:	6609                	lui	a2,0x2
ffffffffc020412c:	a811                	j	ffffffffc0204140 <do_fork+0x21c>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc020412e:	00e6d663          	bge	a3,a4,ffffffffc020413a <do_fork+0x216>
ffffffffc0204132:	00c75463          	bge	a4,a2,ffffffffc020413a <do_fork+0x216>
ffffffffc0204136:	863a                	mv	a2,a4
ffffffffc0204138:	4885                	li	a7,1
ffffffffc020413a:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc020413c:	01278d63          	beq	a5,s2,ffffffffc0204156 <do_fork+0x232>
            if (proc->pid == last_pid)
ffffffffc0204140:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c6c>
ffffffffc0204144:	fed715e3          	bne	a4,a3,ffffffffc020412e <do_fork+0x20a>
                if (++last_pid >= next_safe)
ffffffffc0204148:	2685                	addiw	a3,a3,1
ffffffffc020414a:	0ec6d963          	bge	a3,a2,ffffffffc020423c <do_fork+0x318>
ffffffffc020414e:	679c                	ld	a5,8(a5)
ffffffffc0204150:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc0204152:	ff2797e3          	bne	a5,s2,ffffffffc0204140 <do_fork+0x21c>
ffffffffc0204156:	c581                	beqz	a1,ffffffffc020415e <do_fork+0x23a>
ffffffffc0204158:	00d82023          	sw	a3,0(a6)
ffffffffc020415c:	8536                	mv	a0,a3
ffffffffc020415e:	f0088ee3          	beqz	a7,ffffffffc020407a <do_fork+0x156>
ffffffffc0204162:	00c32023          	sw	a2,0(t1)
ffffffffc0204166:	bf11                	j	ffffffffc020407a <do_fork+0x156>
    if ((mm = mm_create()) == NULL)
ffffffffc0204168:	cd2ff0ef          	jal	ra,ffffffffc020363a <mm_create>
ffffffffc020416c:	8c2a                	mv	s8,a0
ffffffffc020416e:	0e050a63          	beqz	a0,ffffffffc0204262 <do_fork+0x33e>
    if ((page = alloc_page()) == NULL)
ffffffffc0204172:	4505                	li	a0,1
ffffffffc0204174:	d45fd0ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
ffffffffc0204178:	c159                	beqz	a0,ffffffffc02041fe <do_fork+0x2da>
    return page - pages + nbase;
ffffffffc020417a:	000cb683          	ld	a3,0(s9)
ffffffffc020417e:	6722                	ld	a4,8(sp)
    return KADDR(page2pa(page));
ffffffffc0204180:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc0204184:	40d506b3          	sub	a3,a0,a3
ffffffffc0204188:	8699                	srai	a3,a3,0x6
ffffffffc020418a:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc020418c:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0204190:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204192:	0cfb7a63          	bgeu	s6,a5,ffffffffc0204266 <do_fork+0x342>
ffffffffc0204196:	000dba03          	ld	s4,0(s11)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc020419a:	6605                	lui	a2,0x1
ffffffffc020419c:	000a6597          	auipc	a1,0xa6
ffffffffc02041a0:	51c5b583          	ld	a1,1308(a1) # ffffffffc02aa6b8 <boot_pgdir_va>
ffffffffc02041a4:	9a36                	add	s4,s4,a3
ffffffffc02041a6:	8552                	mv	a0,s4
ffffffffc02041a8:	45c010ef          	jal	ra,ffffffffc0205604 <memcpy>
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
ffffffffc02041ac:	038b8b13          	addi	s6,s7,56
    mm->pgdir = pgdir;
ffffffffc02041b0:	014c3c23          	sd	s4,24(s8)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02041b4:	4785                	li	a5,1
ffffffffc02041b6:	40fb37af          	amoor.d	a5,a5,(s6)
}

static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))
ffffffffc02041ba:	8b85                	andi	a5,a5,1
ffffffffc02041bc:	4a05                	li	s4,1
ffffffffc02041be:	c799                	beqz	a5,ffffffffc02041cc <do_fork+0x2a8>
    {
        schedule();
ffffffffc02041c0:	621000ef          	jal	ra,ffffffffc0204fe0 <schedule>
ffffffffc02041c4:	414b37af          	amoor.d	a5,s4,(s6)
    while (!try_lock(lock))
ffffffffc02041c8:	8b85                	andi	a5,a5,1
ffffffffc02041ca:	fbfd                	bnez	a5,ffffffffc02041c0 <do_fork+0x29c>
        ret = dup_mmap(mm, oldmm);
ffffffffc02041cc:	85de                	mv	a1,s7
ffffffffc02041ce:	8562                	mv	a0,s8
ffffffffc02041d0:	eacff0ef          	jal	ra,ffffffffc020387c <dup_mmap>
ffffffffc02041d4:	8a2a                	mv	s4,a0
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02041d6:	57f9                	li	a5,-2
ffffffffc02041d8:	60fb37af          	amoand.d	a5,a5,(s6)
ffffffffc02041dc:	8b85                	andi	a5,a5,1
}

static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))
ffffffffc02041de:	c3c5                	beqz	a5,ffffffffc020427e <do_fork+0x35a>
good_mm:
ffffffffc02041e0:	8be2                	mv	s7,s8
    if (ret != 0)
ffffffffc02041e2:	de050ce3          	beqz	a0,ffffffffc0203fda <do_fork+0xb6>
    exit_mmap(mm);
ffffffffc02041e6:	8562                	mv	a0,s8
ffffffffc02041e8:	f2eff0ef          	jal	ra,ffffffffc0203916 <exit_mmap>
    put_pgdir(mm);
ffffffffc02041ec:	8562                	mv	a0,s8
ffffffffc02041ee:	c5dff0ef          	jal	ra,ffffffffc0203e4a <put_pgdir>
    mm_destroy(mm);
ffffffffc02041f2:	8562                	mv	a0,s8
ffffffffc02041f4:	d86ff0ef          	jal	ra,ffffffffc020377a <mm_destroy>
ffffffffc02041f8:	a039                	j	ffffffffc0204206 <do_fork+0x2e2>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02041fa:	8936                	mv	s2,a3
ffffffffc02041fc:	bd35                	j	ffffffffc0204038 <do_fork+0x114>
    mm_destroy(mm);
ffffffffc02041fe:	8562                	mv	a0,s8
ffffffffc0204200:	d7aff0ef          	jal	ra,ffffffffc020377a <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0204204:	5a71                	li	s4,-4
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204206:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0204208:	c02007b7          	lui	a5,0xc0200
ffffffffc020420c:	0af6ee63          	bltu	a3,a5,ffffffffc02042c8 <do_fork+0x3a4>
ffffffffc0204210:	000db703          	ld	a4,0(s11)
    if (PPN(pa) >= npage)
ffffffffc0204214:	000d3783          	ld	a5,0(s10)
    return pa2page(PADDR(kva));
ffffffffc0204218:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage)
ffffffffc020421a:	82b1                	srli	a3,a3,0xc
ffffffffc020421c:	08f6fa63          	bgeu	a3,a5,ffffffffc02042b0 <do_fork+0x38c>
    return &pages[PPN(pa) - nbase];
ffffffffc0204220:	000ab783          	ld	a5,0(s5)
ffffffffc0204224:	000cb503          	ld	a0,0(s9)
ffffffffc0204228:	4589                	li	a1,2
ffffffffc020422a:	8e9d                	sub	a3,a3,a5
ffffffffc020422c:	069a                	slli	a3,a3,0x6
ffffffffc020422e:	9536                	add	a0,a0,a3
ffffffffc0204230:	cc7fd0ef          	jal	ra,ffffffffc0201ef6 <free_pages>
    kfree(proc);
ffffffffc0204234:	8522                	mv	a0,s0
ffffffffc0204236:	b55fd0ef          	jal	ra,ffffffffc0201d8a <kfree>
    return ret;
ffffffffc020423a:	b545                	j	ffffffffc02040da <do_fork+0x1b6>
                    if (last_pid >= MAX_PID)
ffffffffc020423c:	01d6c363          	blt	a3,t4,ffffffffc0204242 <do_fork+0x31e>
                        last_pid = 1;
ffffffffc0204240:	4685                	li	a3,1
                    goto repeat;
ffffffffc0204242:	4585                	li	a1,1
ffffffffc0204244:	bdf9                	j	ffffffffc0204122 <do_fork+0x1fe>
    return -E_NO_MEM;
ffffffffc0204246:	5a71                	li	s4,-4
ffffffffc0204248:	b7f5                	j	ffffffffc0204234 <do_fork+0x310>
    int ret = -E_NO_FREE_PROC;
ffffffffc020424a:	5a6d                	li	s4,-5
ffffffffc020424c:	b579                	j	ffffffffc02040da <do_fork+0x1b6>
ffffffffc020424e:	c599                	beqz	a1,ffffffffc020425c <do_fork+0x338>
ffffffffc0204250:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc0204254:	8536                	mv	a0,a3
ffffffffc0204256:	b515                	j	ffffffffc020407a <do_fork+0x156>
    ret = -E_NO_MEM;
ffffffffc0204258:	5a71                	li	s4,-4
ffffffffc020425a:	b541                	j	ffffffffc02040da <do_fork+0x1b6>
    return last_pid;
ffffffffc020425c:	00082503          	lw	a0,0(a6)
ffffffffc0204260:	bd29                	j	ffffffffc020407a <do_fork+0x156>
    int ret = -E_NO_MEM;
ffffffffc0204262:	5a71                	li	s4,-4
ffffffffc0204264:	b74d                	j	ffffffffc0204206 <do_fork+0x2e2>
    return KADDR(page2pa(page));
ffffffffc0204266:	00002617          	auipc	a2,0x2
ffffffffc020426a:	26a60613          	addi	a2,a2,618 # ffffffffc02064d0 <default_pmm_manager+0x38>
ffffffffc020426e:	07100593          	li	a1,113
ffffffffc0204272:	00002517          	auipc	a0,0x2
ffffffffc0204276:	28650513          	addi	a0,a0,646 # ffffffffc02064f8 <default_pmm_manager+0x60>
ffffffffc020427a:	a14fc0ef          	jal	ra,ffffffffc020048e <__panic>
    {
        panic("Unlock failed.\n");
ffffffffc020427e:	00003617          	auipc	a2,0x3
ffffffffc0204282:	c9260613          	addi	a2,a2,-878 # ffffffffc0206f10 <default_pmm_manager+0xa78>
ffffffffc0204286:	03f00593          	li	a1,63
ffffffffc020428a:	00003517          	auipc	a0,0x3
ffffffffc020428e:	c9650513          	addi	a0,a0,-874 # ffffffffc0206f20 <default_pmm_manager+0xa88>
ffffffffc0204292:	9fcfc0ef          	jal	ra,ffffffffc020048e <__panic>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204296:	86be                	mv	a3,a5
ffffffffc0204298:	00002617          	auipc	a2,0x2
ffffffffc020429c:	2e060613          	addi	a2,a2,736 # ffffffffc0206578 <default_pmm_manager+0xe0>
ffffffffc02042a0:	18d00593          	li	a1,397
ffffffffc02042a4:	00003517          	auipc	a0,0x3
ffffffffc02042a8:	c5450513          	addi	a0,a0,-940 # ffffffffc0206ef8 <default_pmm_manager+0xa60>
ffffffffc02042ac:	9e2fc0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02042b0:	00002617          	auipc	a2,0x2
ffffffffc02042b4:	2f060613          	addi	a2,a2,752 # ffffffffc02065a0 <default_pmm_manager+0x108>
ffffffffc02042b8:	06900593          	li	a1,105
ffffffffc02042bc:	00002517          	auipc	a0,0x2
ffffffffc02042c0:	23c50513          	addi	a0,a0,572 # ffffffffc02064f8 <default_pmm_manager+0x60>
ffffffffc02042c4:	9cafc0ef          	jal	ra,ffffffffc020048e <__panic>
    return pa2page(PADDR(kva));
ffffffffc02042c8:	00002617          	auipc	a2,0x2
ffffffffc02042cc:	2b060613          	addi	a2,a2,688 # ffffffffc0206578 <default_pmm_manager+0xe0>
ffffffffc02042d0:	07700593          	li	a1,119
ffffffffc02042d4:	00002517          	auipc	a0,0x2
ffffffffc02042d8:	22450513          	addi	a0,a0,548 # ffffffffc02064f8 <default_pmm_manager+0x60>
ffffffffc02042dc:	9b2fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02042e0 <kernel_thread>:
{
ffffffffc02042e0:	7129                	addi	sp,sp,-320
ffffffffc02042e2:	fa22                	sd	s0,304(sp)
ffffffffc02042e4:	f626                	sd	s1,296(sp)
ffffffffc02042e6:	f24a                	sd	s2,288(sp)
ffffffffc02042e8:	84ae                	mv	s1,a1
ffffffffc02042ea:	892a                	mv	s2,a0
ffffffffc02042ec:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02042ee:	4581                	li	a1,0
ffffffffc02042f0:	12000613          	li	a2,288
ffffffffc02042f4:	850a                	mv	a0,sp
{
ffffffffc02042f6:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02042f8:	2fa010ef          	jal	ra,ffffffffc02055f2 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02042fc:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02042fe:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204300:	100027f3          	csrr	a5,sstatus
ffffffffc0204304:	edd7f793          	andi	a5,a5,-291
ffffffffc0204308:	1207e793          	ori	a5,a5,288
ffffffffc020430c:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020430e:	860a                	mv	a2,sp
ffffffffc0204310:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204314:	00000797          	auipc	a5,0x0
ffffffffc0204318:	a3078793          	addi	a5,a5,-1488 # ffffffffc0203d44 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020431c:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020431e:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204320:	c05ff0ef          	jal	ra,ffffffffc0203f24 <do_fork>
}
ffffffffc0204324:	70f2                	ld	ra,312(sp)
ffffffffc0204326:	7452                	ld	s0,304(sp)
ffffffffc0204328:	74b2                	ld	s1,296(sp)
ffffffffc020432a:	7912                	ld	s2,288(sp)
ffffffffc020432c:	6131                	addi	sp,sp,320
ffffffffc020432e:	8082                	ret

ffffffffc0204330 <do_exit>:
{
ffffffffc0204330:	7179                	addi	sp,sp,-48
ffffffffc0204332:	f022                	sd	s0,32(sp)
    if (current == idleproc)
ffffffffc0204334:	000a6417          	auipc	s0,0xa6
ffffffffc0204338:	3ac40413          	addi	s0,s0,940 # ffffffffc02aa6e0 <current>
ffffffffc020433c:	601c                	ld	a5,0(s0)
{
ffffffffc020433e:	f406                	sd	ra,40(sp)
ffffffffc0204340:	ec26                	sd	s1,24(sp)
ffffffffc0204342:	e84a                	sd	s2,16(sp)
ffffffffc0204344:	e44e                	sd	s3,8(sp)
ffffffffc0204346:	e052                	sd	s4,0(sp)
    if (current == idleproc)
ffffffffc0204348:	000a6717          	auipc	a4,0xa6
ffffffffc020434c:	3a073703          	ld	a4,928(a4) # ffffffffc02aa6e8 <idleproc>
ffffffffc0204350:	0ce78c63          	beq	a5,a4,ffffffffc0204428 <do_exit+0xf8>
    if (current == initproc)
ffffffffc0204354:	000a6497          	auipc	s1,0xa6
ffffffffc0204358:	39c48493          	addi	s1,s1,924 # ffffffffc02aa6f0 <initproc>
ffffffffc020435c:	6098                	ld	a4,0(s1)
ffffffffc020435e:	0ee78b63          	beq	a5,a4,ffffffffc0204454 <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc0204362:	0287b983          	ld	s3,40(a5)
ffffffffc0204366:	892a                	mv	s2,a0
    if (mm != NULL)
ffffffffc0204368:	02098663          	beqz	s3,ffffffffc0204394 <do_exit+0x64>
ffffffffc020436c:	000a6797          	auipc	a5,0xa6
ffffffffc0204370:	3447b783          	ld	a5,836(a5) # ffffffffc02aa6b0 <boot_pgdir_pa>
ffffffffc0204374:	577d                	li	a4,-1
ffffffffc0204376:	177e                	slli	a4,a4,0x3f
ffffffffc0204378:	83b1                	srli	a5,a5,0xc
ffffffffc020437a:	8fd9                	or	a5,a5,a4
ffffffffc020437c:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0204380:	0309a783          	lw	a5,48(s3)
ffffffffc0204384:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204388:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0)
ffffffffc020438c:	cb55                	beqz	a4,ffffffffc0204440 <do_exit+0x110>
        current->mm = NULL;
ffffffffc020438e:	601c                	ld	a5,0(s0)
ffffffffc0204390:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0204394:	601c                	ld	a5,0(s0)
ffffffffc0204396:	470d                	li	a4,3
ffffffffc0204398:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc020439a:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020439e:	100027f3          	csrr	a5,sstatus
ffffffffc02043a2:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02043a4:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02043a6:	e3f9                	bnez	a5,ffffffffc020446c <do_exit+0x13c>
        proc = current->parent;
ffffffffc02043a8:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD)
ffffffffc02043aa:	800007b7          	lui	a5,0x80000
ffffffffc02043ae:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc02043b0:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc02043b2:	0ec52703          	lw	a4,236(a0)
ffffffffc02043b6:	0af70f63          	beq	a4,a5,ffffffffc0204474 <do_exit+0x144>
        while (current->cptr != NULL)
ffffffffc02043ba:	6018                	ld	a4,0(s0)
ffffffffc02043bc:	7b7c                	ld	a5,240(a4)
ffffffffc02043be:	c3a1                	beqz	a5,ffffffffc02043fe <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD)
ffffffffc02043c0:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE)
ffffffffc02043c4:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD)
ffffffffc02043c6:	0985                	addi	s3,s3,1
ffffffffc02043c8:	a021                	j	ffffffffc02043d0 <do_exit+0xa0>
        while (current->cptr != NULL)
ffffffffc02043ca:	6018                	ld	a4,0(s0)
ffffffffc02043cc:	7b7c                	ld	a5,240(a4)
ffffffffc02043ce:	cb85                	beqz	a5,ffffffffc02043fe <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc02043d0:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fe8>
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc02043d4:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc02043d6:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc02043d8:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc02043da:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc02043de:	10e7b023          	sd	a4,256(a5)
ffffffffc02043e2:	c311                	beqz	a4,ffffffffc02043e6 <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc02043e4:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc02043e6:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02043e8:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02043ea:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc02043ec:	fd271fe3          	bne	a4,s2,ffffffffc02043ca <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc02043f0:	0ec52783          	lw	a5,236(a0)
ffffffffc02043f4:	fd379be3          	bne	a5,s3,ffffffffc02043ca <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc02043f8:	369000ef          	jal	ra,ffffffffc0204f60 <wakeup_proc>
ffffffffc02043fc:	b7f9                	j	ffffffffc02043ca <do_exit+0x9a>
    if (flag)
ffffffffc02043fe:	020a1263          	bnez	s4,ffffffffc0204422 <do_exit+0xf2>
    schedule();
ffffffffc0204402:	3df000ef          	jal	ra,ffffffffc0204fe0 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0204406:	601c                	ld	a5,0(s0)
ffffffffc0204408:	00003617          	auipc	a2,0x3
ffffffffc020440c:	b5060613          	addi	a2,a2,-1200 # ffffffffc0206f58 <default_pmm_manager+0xac0>
ffffffffc0204410:	23b00593          	li	a1,571
ffffffffc0204414:	43d4                	lw	a3,4(a5)
ffffffffc0204416:	00003517          	auipc	a0,0x3
ffffffffc020441a:	ae250513          	addi	a0,a0,-1310 # ffffffffc0206ef8 <default_pmm_manager+0xa60>
ffffffffc020441e:	870fc0ef          	jal	ra,ffffffffc020048e <__panic>
        intr_enable();
ffffffffc0204422:	d8cfc0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0204426:	bff1                	j	ffffffffc0204402 <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc0204428:	00003617          	auipc	a2,0x3
ffffffffc020442c:	b1060613          	addi	a2,a2,-1264 # ffffffffc0206f38 <default_pmm_manager+0xaa0>
ffffffffc0204430:	20700593          	li	a1,519
ffffffffc0204434:	00003517          	auipc	a0,0x3
ffffffffc0204438:	ac450513          	addi	a0,a0,-1340 # ffffffffc0206ef8 <default_pmm_manager+0xa60>
ffffffffc020443c:	852fc0ef          	jal	ra,ffffffffc020048e <__panic>
            exit_mmap(mm);
ffffffffc0204440:	854e                	mv	a0,s3
ffffffffc0204442:	cd4ff0ef          	jal	ra,ffffffffc0203916 <exit_mmap>
            put_pgdir(mm);
ffffffffc0204446:	854e                	mv	a0,s3
ffffffffc0204448:	a03ff0ef          	jal	ra,ffffffffc0203e4a <put_pgdir>
            mm_destroy(mm);
ffffffffc020444c:	854e                	mv	a0,s3
ffffffffc020444e:	b2cff0ef          	jal	ra,ffffffffc020377a <mm_destroy>
ffffffffc0204452:	bf35                	j	ffffffffc020438e <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc0204454:	00003617          	auipc	a2,0x3
ffffffffc0204458:	af460613          	addi	a2,a2,-1292 # ffffffffc0206f48 <default_pmm_manager+0xab0>
ffffffffc020445c:	20b00593          	li	a1,523
ffffffffc0204460:	00003517          	auipc	a0,0x3
ffffffffc0204464:	a9850513          	addi	a0,a0,-1384 # ffffffffc0206ef8 <default_pmm_manager+0xa60>
ffffffffc0204468:	826fc0ef          	jal	ra,ffffffffc020048e <__panic>
        intr_disable();
ffffffffc020446c:	d48fc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc0204470:	4a05                	li	s4,1
ffffffffc0204472:	bf1d                	j	ffffffffc02043a8 <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc0204474:	2ed000ef          	jal	ra,ffffffffc0204f60 <wakeup_proc>
ffffffffc0204478:	b789                	j	ffffffffc02043ba <do_exit+0x8a>

ffffffffc020447a <do_wait.part.0>:
int do_wait(int pid, int *code_store)
ffffffffc020447a:	715d                	addi	sp,sp,-80
ffffffffc020447c:	f84a                	sd	s2,48(sp)
ffffffffc020447e:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc0204480:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID)
ffffffffc0204484:	6989                	lui	s3,0x2
int do_wait(int pid, int *code_store)
ffffffffc0204486:	fc26                	sd	s1,56(sp)
ffffffffc0204488:	f052                	sd	s4,32(sp)
ffffffffc020448a:	ec56                	sd	s5,24(sp)
ffffffffc020448c:	e85a                	sd	s6,16(sp)
ffffffffc020448e:	e45e                	sd	s7,8(sp)
ffffffffc0204490:	e486                	sd	ra,72(sp)
ffffffffc0204492:	e0a2                	sd	s0,64(sp)
ffffffffc0204494:	84aa                	mv	s1,a0
ffffffffc0204496:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc0204498:	000a6b97          	auipc	s7,0xa6
ffffffffc020449c:	248b8b93          	addi	s7,s7,584 # ffffffffc02aa6e0 <current>
    if (0 < pid && pid < MAX_PID)
ffffffffc02044a0:	00050b1b          	sext.w	s6,a0
ffffffffc02044a4:	fff50a9b          	addiw	s5,a0,-1
ffffffffc02044a8:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc02044aa:	0905                	addi	s2,s2,1
    if (pid != 0)
ffffffffc02044ac:	ccbd                	beqz	s1,ffffffffc020452a <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID)
ffffffffc02044ae:	0359e863          	bltu	s3,s5,ffffffffc02044de <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02044b2:	45a9                	li	a1,10
ffffffffc02044b4:	855a                	mv	a0,s6
ffffffffc02044b6:	497000ef          	jal	ra,ffffffffc020514c <hash32>
ffffffffc02044ba:	02051793          	slli	a5,a0,0x20
ffffffffc02044be:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02044c2:	000a2797          	auipc	a5,0xa2
ffffffffc02044c6:	1a678793          	addi	a5,a5,422 # ffffffffc02a6668 <hash_list>
ffffffffc02044ca:	953e                	add	a0,a0,a5
ffffffffc02044cc:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list)
ffffffffc02044ce:	a029                	j	ffffffffc02044d8 <do_wait.part.0+0x5e>
            if (proc->pid == pid)
ffffffffc02044d0:	f2c42783          	lw	a5,-212(s0)
ffffffffc02044d4:	02978163          	beq	a5,s1,ffffffffc02044f6 <do_wait.part.0+0x7c>
ffffffffc02044d8:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list)
ffffffffc02044da:	fe851be3          	bne	a0,s0,ffffffffc02044d0 <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc02044de:	5579                	li	a0,-2
}
ffffffffc02044e0:	60a6                	ld	ra,72(sp)
ffffffffc02044e2:	6406                	ld	s0,64(sp)
ffffffffc02044e4:	74e2                	ld	s1,56(sp)
ffffffffc02044e6:	7942                	ld	s2,48(sp)
ffffffffc02044e8:	79a2                	ld	s3,40(sp)
ffffffffc02044ea:	7a02                	ld	s4,32(sp)
ffffffffc02044ec:	6ae2                	ld	s5,24(sp)
ffffffffc02044ee:	6b42                	ld	s6,16(sp)
ffffffffc02044f0:	6ba2                	ld	s7,8(sp)
ffffffffc02044f2:	6161                	addi	sp,sp,80
ffffffffc02044f4:	8082                	ret
        if (proc != NULL && proc->parent == current)
ffffffffc02044f6:	000bb683          	ld	a3,0(s7)
ffffffffc02044fa:	f4843783          	ld	a5,-184(s0)
ffffffffc02044fe:	fed790e3          	bne	a5,a3,ffffffffc02044de <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204502:	f2842703          	lw	a4,-216(s0)
ffffffffc0204506:	478d                	li	a5,3
ffffffffc0204508:	0ef70b63          	beq	a4,a5,ffffffffc02045fe <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc020450c:	4785                	li	a5,1
ffffffffc020450e:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc0204510:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc0204514:	2cd000ef          	jal	ra,ffffffffc0204fe0 <schedule>
        if (current->flags & PF_EXITING)
ffffffffc0204518:	000bb783          	ld	a5,0(s7)
ffffffffc020451c:	0b07a783          	lw	a5,176(a5)
ffffffffc0204520:	8b85                	andi	a5,a5,1
ffffffffc0204522:	d7c9                	beqz	a5,ffffffffc02044ac <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc0204524:	555d                	li	a0,-9
ffffffffc0204526:	e0bff0ef          	jal	ra,ffffffffc0204330 <do_exit>
        proc = current->cptr;
ffffffffc020452a:	000bb683          	ld	a3,0(s7)
ffffffffc020452e:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr)
ffffffffc0204530:	d45d                	beqz	s0,ffffffffc02044de <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204532:	470d                	li	a4,3
ffffffffc0204534:	a021                	j	ffffffffc020453c <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr)
ffffffffc0204536:	10043403          	ld	s0,256(s0)
ffffffffc020453a:	d869                	beqz	s0,ffffffffc020450c <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE)
ffffffffc020453c:	401c                	lw	a5,0(s0)
ffffffffc020453e:	fee79ce3          	bne	a5,a4,ffffffffc0204536 <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc)
ffffffffc0204542:	000a6797          	auipc	a5,0xa6
ffffffffc0204546:	1a67b783          	ld	a5,422(a5) # ffffffffc02aa6e8 <idleproc>
ffffffffc020454a:	0c878963          	beq	a5,s0,ffffffffc020461c <do_wait.part.0+0x1a2>
ffffffffc020454e:	000a6797          	auipc	a5,0xa6
ffffffffc0204552:	1a27b783          	ld	a5,418(a5) # ffffffffc02aa6f0 <initproc>
ffffffffc0204556:	0cf40363          	beq	s0,a5,ffffffffc020461c <do_wait.part.0+0x1a2>
    if (code_store != NULL)
ffffffffc020455a:	000a0663          	beqz	s4,ffffffffc0204566 <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc020455e:	0e842783          	lw	a5,232(s0)
ffffffffc0204562:	00fa2023          	sw	a5,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8ba8>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204566:	100027f3          	csrr	a5,sstatus
ffffffffc020456a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020456c:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020456e:	e7c1                	bnez	a5,ffffffffc02045f6 <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0204570:	6c70                	ld	a2,216(s0)
ffffffffc0204572:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL)
ffffffffc0204574:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc0204578:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc020457a:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020457c:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020457e:	6470                	ld	a2,200(s0)
ffffffffc0204580:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0204582:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0204584:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL)
ffffffffc0204586:	c319                	beqz	a4,ffffffffc020458c <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc0204588:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL)
ffffffffc020458a:	7c7c                	ld	a5,248(s0)
ffffffffc020458c:	c3b5                	beqz	a5,ffffffffc02045f0 <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc020458e:	10e7b023          	sd	a4,256(a5)
    nr_process--;
ffffffffc0204592:	000a6717          	auipc	a4,0xa6
ffffffffc0204596:	16670713          	addi	a4,a4,358 # ffffffffc02aa6f8 <nr_process>
ffffffffc020459a:	431c                	lw	a5,0(a4)
ffffffffc020459c:	37fd                	addiw	a5,a5,-1
ffffffffc020459e:	c31c                	sw	a5,0(a4)
    if (flag)
ffffffffc02045a0:	e5a9                	bnez	a1,ffffffffc02045ea <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02045a2:	6814                	ld	a3,16(s0)
ffffffffc02045a4:	c02007b7          	lui	a5,0xc0200
ffffffffc02045a8:	04f6ee63          	bltu	a3,a5,ffffffffc0204604 <do_wait.part.0+0x18a>
ffffffffc02045ac:	000a6797          	auipc	a5,0xa6
ffffffffc02045b0:	12c7b783          	ld	a5,300(a5) # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc02045b4:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage)
ffffffffc02045b6:	82b1                	srli	a3,a3,0xc
ffffffffc02045b8:	000a6797          	auipc	a5,0xa6
ffffffffc02045bc:	1087b783          	ld	a5,264(a5) # ffffffffc02aa6c0 <npage>
ffffffffc02045c0:	06f6fa63          	bgeu	a3,a5,ffffffffc0204634 <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc02045c4:	00003517          	auipc	a0,0x3
ffffffffc02045c8:	1cc53503          	ld	a0,460(a0) # ffffffffc0207790 <nbase>
ffffffffc02045cc:	8e89                	sub	a3,a3,a0
ffffffffc02045ce:	069a                	slli	a3,a3,0x6
ffffffffc02045d0:	000a6517          	auipc	a0,0xa6
ffffffffc02045d4:	0f853503          	ld	a0,248(a0) # ffffffffc02aa6c8 <pages>
ffffffffc02045d8:	9536                	add	a0,a0,a3
ffffffffc02045da:	4589                	li	a1,2
ffffffffc02045dc:	91bfd0ef          	jal	ra,ffffffffc0201ef6 <free_pages>
    kfree(proc);
ffffffffc02045e0:	8522                	mv	a0,s0
ffffffffc02045e2:	fa8fd0ef          	jal	ra,ffffffffc0201d8a <kfree>
    return 0;
ffffffffc02045e6:	4501                	li	a0,0
ffffffffc02045e8:	bde5                	j	ffffffffc02044e0 <do_wait.part.0+0x66>
        intr_enable();
ffffffffc02045ea:	bc4fc0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02045ee:	bf55                	j	ffffffffc02045a2 <do_wait.part.0+0x128>
        proc->parent->cptr = proc->optr;
ffffffffc02045f0:	701c                	ld	a5,32(s0)
ffffffffc02045f2:	fbf8                	sd	a4,240(a5)
ffffffffc02045f4:	bf79                	j	ffffffffc0204592 <do_wait.part.0+0x118>
        intr_disable();
ffffffffc02045f6:	bbefc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc02045fa:	4585                	li	a1,1
ffffffffc02045fc:	bf95                	j	ffffffffc0204570 <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02045fe:	f2840413          	addi	s0,s0,-216
ffffffffc0204602:	b781                	j	ffffffffc0204542 <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc0204604:	00002617          	auipc	a2,0x2
ffffffffc0204608:	f7460613          	addi	a2,a2,-140 # ffffffffc0206578 <default_pmm_manager+0xe0>
ffffffffc020460c:	07700593          	li	a1,119
ffffffffc0204610:	00002517          	auipc	a0,0x2
ffffffffc0204614:	ee850513          	addi	a0,a0,-280 # ffffffffc02064f8 <default_pmm_manager+0x60>
ffffffffc0204618:	e77fb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc020461c:	00003617          	auipc	a2,0x3
ffffffffc0204620:	95c60613          	addi	a2,a2,-1700 # ffffffffc0206f78 <default_pmm_manager+0xae0>
ffffffffc0204624:	35900593          	li	a1,857
ffffffffc0204628:	00003517          	auipc	a0,0x3
ffffffffc020462c:	8d050513          	addi	a0,a0,-1840 # ffffffffc0206ef8 <default_pmm_manager+0xa60>
ffffffffc0204630:	e5ffb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204634:	00002617          	auipc	a2,0x2
ffffffffc0204638:	f6c60613          	addi	a2,a2,-148 # ffffffffc02065a0 <default_pmm_manager+0x108>
ffffffffc020463c:	06900593          	li	a1,105
ffffffffc0204640:	00002517          	auipc	a0,0x2
ffffffffc0204644:	eb850513          	addi	a0,a0,-328 # ffffffffc02064f8 <default_pmm_manager+0x60>
ffffffffc0204648:	e47fb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020464c <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc020464c:	1141                	addi	sp,sp,-16
ffffffffc020464e:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0204650:	8e7fd0ef          	jal	ra,ffffffffc0201f36 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0204654:	e82fd0ef          	jal	ra,ffffffffc0201cd6 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0204658:	4601                	li	a2,0
ffffffffc020465a:	4581                	li	a1,0
ffffffffc020465c:	fffff517          	auipc	a0,0xfffff
ffffffffc0204660:	77050513          	addi	a0,a0,1904 # ffffffffc0203dcc <user_main>
ffffffffc0204664:	c7dff0ef          	jal	ra,ffffffffc02042e0 <kernel_thread>
    if (pid <= 0)
ffffffffc0204668:	00a04563          	bgtz	a0,ffffffffc0204672 <init_main+0x26>
ffffffffc020466c:	a071                	j	ffffffffc02046f8 <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
ffffffffc020466e:	173000ef          	jal	ra,ffffffffc0204fe0 <schedule>
    if (code_store != NULL)
ffffffffc0204672:	4581                	li	a1,0
ffffffffc0204674:	4501                	li	a0,0
ffffffffc0204676:	e05ff0ef          	jal	ra,ffffffffc020447a <do_wait.part.0>
    while (do_wait(0, NULL) == 0)
ffffffffc020467a:	d975                	beqz	a0,ffffffffc020466e <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc020467c:	00003517          	auipc	a0,0x3
ffffffffc0204680:	93c50513          	addi	a0,a0,-1732 # ffffffffc0206fb8 <default_pmm_manager+0xb20>
ffffffffc0204684:	b11fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204688:	000a6797          	auipc	a5,0xa6
ffffffffc020468c:	0687b783          	ld	a5,104(a5) # ffffffffc02aa6f0 <initproc>
ffffffffc0204690:	7bf8                	ld	a4,240(a5)
ffffffffc0204692:	e339                	bnez	a4,ffffffffc02046d8 <init_main+0x8c>
ffffffffc0204694:	7ff8                	ld	a4,248(a5)
ffffffffc0204696:	e329                	bnez	a4,ffffffffc02046d8 <init_main+0x8c>
ffffffffc0204698:	1007b703          	ld	a4,256(a5)
ffffffffc020469c:	ef15                	bnez	a4,ffffffffc02046d8 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc020469e:	000a6697          	auipc	a3,0xa6
ffffffffc02046a2:	05a6a683          	lw	a3,90(a3) # ffffffffc02aa6f8 <nr_process>
ffffffffc02046a6:	4709                	li	a4,2
ffffffffc02046a8:	0ae69463          	bne	a3,a4,ffffffffc0204750 <init_main+0x104>
    return listelm->next;
ffffffffc02046ac:	000a6697          	auipc	a3,0xa6
ffffffffc02046b0:	fbc68693          	addi	a3,a3,-68 # ffffffffc02aa668 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02046b4:	6698                	ld	a4,8(a3)
ffffffffc02046b6:	0c878793          	addi	a5,a5,200
ffffffffc02046ba:	06f71b63          	bne	a4,a5,ffffffffc0204730 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02046be:	629c                	ld	a5,0(a3)
ffffffffc02046c0:	04f71863          	bne	a4,a5,ffffffffc0204710 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc02046c4:	00003517          	auipc	a0,0x3
ffffffffc02046c8:	9dc50513          	addi	a0,a0,-1572 # ffffffffc02070a0 <default_pmm_manager+0xc08>
ffffffffc02046cc:	ac9fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    return 0;
}
ffffffffc02046d0:	60a2                	ld	ra,8(sp)
ffffffffc02046d2:	4501                	li	a0,0
ffffffffc02046d4:	0141                	addi	sp,sp,16
ffffffffc02046d6:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02046d8:	00003697          	auipc	a3,0x3
ffffffffc02046dc:	90868693          	addi	a3,a3,-1784 # ffffffffc0206fe0 <default_pmm_manager+0xb48>
ffffffffc02046e0:	00002617          	auipc	a2,0x2
ffffffffc02046e4:	a0860613          	addi	a2,a2,-1528 # ffffffffc02060e8 <commands+0x860>
ffffffffc02046e8:	3c700593          	li	a1,967
ffffffffc02046ec:	00003517          	auipc	a0,0x3
ffffffffc02046f0:	80c50513          	addi	a0,a0,-2036 # ffffffffc0206ef8 <default_pmm_manager+0xa60>
ffffffffc02046f4:	d9bfb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("create user_main failed.\n");
ffffffffc02046f8:	00003617          	auipc	a2,0x3
ffffffffc02046fc:	8a060613          	addi	a2,a2,-1888 # ffffffffc0206f98 <default_pmm_manager+0xb00>
ffffffffc0204700:	3be00593          	li	a1,958
ffffffffc0204704:	00002517          	auipc	a0,0x2
ffffffffc0204708:	7f450513          	addi	a0,a0,2036 # ffffffffc0206ef8 <default_pmm_manager+0xa60>
ffffffffc020470c:	d83fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204710:	00003697          	auipc	a3,0x3
ffffffffc0204714:	96068693          	addi	a3,a3,-1696 # ffffffffc0207070 <default_pmm_manager+0xbd8>
ffffffffc0204718:	00002617          	auipc	a2,0x2
ffffffffc020471c:	9d060613          	addi	a2,a2,-1584 # ffffffffc02060e8 <commands+0x860>
ffffffffc0204720:	3ca00593          	li	a1,970
ffffffffc0204724:	00002517          	auipc	a0,0x2
ffffffffc0204728:	7d450513          	addi	a0,a0,2004 # ffffffffc0206ef8 <default_pmm_manager+0xa60>
ffffffffc020472c:	d63fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204730:	00003697          	auipc	a3,0x3
ffffffffc0204734:	91068693          	addi	a3,a3,-1776 # ffffffffc0207040 <default_pmm_manager+0xba8>
ffffffffc0204738:	00002617          	auipc	a2,0x2
ffffffffc020473c:	9b060613          	addi	a2,a2,-1616 # ffffffffc02060e8 <commands+0x860>
ffffffffc0204740:	3c900593          	li	a1,969
ffffffffc0204744:	00002517          	auipc	a0,0x2
ffffffffc0204748:	7b450513          	addi	a0,a0,1972 # ffffffffc0206ef8 <default_pmm_manager+0xa60>
ffffffffc020474c:	d43fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_process == 2);
ffffffffc0204750:	00003697          	auipc	a3,0x3
ffffffffc0204754:	8e068693          	addi	a3,a3,-1824 # ffffffffc0207030 <default_pmm_manager+0xb98>
ffffffffc0204758:	00002617          	auipc	a2,0x2
ffffffffc020475c:	99060613          	addi	a2,a2,-1648 # ffffffffc02060e8 <commands+0x860>
ffffffffc0204760:	3c800593          	li	a1,968
ffffffffc0204764:	00002517          	auipc	a0,0x2
ffffffffc0204768:	79450513          	addi	a0,a0,1940 # ffffffffc0206ef8 <default_pmm_manager+0xa60>
ffffffffc020476c:	d23fb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204770 <do_execve>:
{
ffffffffc0204770:	7171                	addi	sp,sp,-176
ffffffffc0204772:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204774:	000a6d97          	auipc	s11,0xa6
ffffffffc0204778:	f6cd8d93          	addi	s11,s11,-148 # ffffffffc02aa6e0 <current>
ffffffffc020477c:	000db783          	ld	a5,0(s11)
{
ffffffffc0204780:	e54e                	sd	s3,136(sp)
ffffffffc0204782:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204784:	0287b983          	ld	s3,40(a5)
{
ffffffffc0204788:	e94a                	sd	s2,144(sp)
ffffffffc020478a:	87b2                	mv	a5,a2
ffffffffc020478c:	892a                	mv	s2,a0
ffffffffc020478e:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204790:	862e                	mv	a2,a1
ffffffffc0204792:	4681                	li	a3,0
ffffffffc0204794:	85aa                	mv	a1,a0
ffffffffc0204796:	854e                	mv	a0,s3
{
ffffffffc0204798:	f506                	sd	ra,168(sp)
ffffffffc020479a:	f122                	sd	s0,160(sp)
ffffffffc020479c:	e152                	sd	s4,128(sp)
ffffffffc020479e:	fcd6                	sd	s5,120(sp)
ffffffffc02047a0:	f8da                	sd	s6,112(sp)
ffffffffc02047a2:	f4de                	sd	s7,104(sp)
ffffffffc02047a4:	f0e2                	sd	s8,96(sp)
ffffffffc02047a6:	ece6                	sd	s9,88(sp)
ffffffffc02047a8:	e8ea                	sd	s10,80(sp)
ffffffffc02047aa:	f03e                	sd	a5,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc02047ac:	d04ff0ef          	jal	ra,ffffffffc0203cb0 <user_mem_check>
ffffffffc02047b0:	3e050a63          	beqz	a0,ffffffffc0204ba4 <do_execve+0x434>
    memset(local_name, 0, sizeof(local_name));
ffffffffc02047b4:	4641                	li	a2,16
ffffffffc02047b6:	4581                	li	a1,0
ffffffffc02047b8:	1808                	addi	a0,sp,48
ffffffffc02047ba:	639000ef          	jal	ra,ffffffffc02055f2 <memset>
    memcpy(local_name, name, len);
ffffffffc02047be:	47bd                	li	a5,15
ffffffffc02047c0:	8626                	mv	a2,s1
ffffffffc02047c2:	1c97e263          	bltu	a5,s1,ffffffffc0204986 <do_execve+0x216>
ffffffffc02047c6:	85ca                	mv	a1,s2
ffffffffc02047c8:	1808                	addi	a0,sp,48
ffffffffc02047ca:	63b000ef          	jal	ra,ffffffffc0205604 <memcpy>
    if (mm != NULL)
ffffffffc02047ce:	1c098363          	beqz	s3,ffffffffc0204994 <do_execve+0x224>
        cputs("mm != NULL");
ffffffffc02047d2:	00002517          	auipc	a0,0x2
ffffffffc02047d6:	4e650513          	addi	a0,a0,1254 # ffffffffc0206cb8 <default_pmm_manager+0x820>
ffffffffc02047da:	9f3fb0ef          	jal	ra,ffffffffc02001cc <cputs>
ffffffffc02047de:	000a6797          	auipc	a5,0xa6
ffffffffc02047e2:	ed27b783          	ld	a5,-302(a5) # ffffffffc02aa6b0 <boot_pgdir_pa>
ffffffffc02047e6:	577d                	li	a4,-1
ffffffffc02047e8:	177e                	slli	a4,a4,0x3f
ffffffffc02047ea:	83b1                	srli	a5,a5,0xc
ffffffffc02047ec:	8fd9                	or	a5,a5,a4
ffffffffc02047ee:	18079073          	csrw	satp,a5
ffffffffc02047f2:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7b78>
ffffffffc02047f6:	fff7871b          	addiw	a4,a5,-1
ffffffffc02047fa:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0)
ffffffffc02047fe:	2a070463          	beqz	a4,ffffffffc0204aa6 <do_execve+0x336>
        current->mm = NULL;
ffffffffc0204802:	000db783          	ld	a5,0(s11)
ffffffffc0204806:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc020480a:	e31fe0ef          	jal	ra,ffffffffc020363a <mm_create>
ffffffffc020480e:	84aa                	mv	s1,a0
ffffffffc0204810:	1a050d63          	beqz	a0,ffffffffc02049ca <do_execve+0x25a>
    if ((page = alloc_page()) == NULL)
ffffffffc0204814:	4505                	li	a0,1
ffffffffc0204816:	ea2fd0ef          	jal	ra,ffffffffc0201eb8 <alloc_pages>
ffffffffc020481a:	38050963          	beqz	a0,ffffffffc0204bac <do_execve+0x43c>
    return page - pages + nbase;
ffffffffc020481e:	000a6c17          	auipc	s8,0xa6
ffffffffc0204822:	eaac0c13          	addi	s8,s8,-342 # ffffffffc02aa6c8 <pages>
ffffffffc0204826:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc020482a:	000a6c97          	auipc	s9,0xa6
ffffffffc020482e:	e96c8c93          	addi	s9,s9,-362 # ffffffffc02aa6c0 <npage>
    return page - pages + nbase;
ffffffffc0204832:	00003717          	auipc	a4,0x3
ffffffffc0204836:	f5e73703          	ld	a4,-162(a4) # ffffffffc0207790 <nbase>
ffffffffc020483a:	40d506b3          	sub	a3,a0,a3
ffffffffc020483e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204840:	5afd                	li	s5,-1
ffffffffc0204842:	000cb783          	ld	a5,0(s9)
    return page - pages + nbase;
ffffffffc0204846:	96ba                	add	a3,a3,a4
ffffffffc0204848:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc020484a:	00cad713          	srli	a4,s5,0xc
ffffffffc020484e:	ec3a                	sd	a4,24(sp)
ffffffffc0204850:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204852:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204854:	36f77063          	bgeu	a4,a5,ffffffffc0204bb4 <do_execve+0x444>
ffffffffc0204858:	000a6b17          	auipc	s6,0xa6
ffffffffc020485c:	e80b0b13          	addi	s6,s6,-384 # ffffffffc02aa6d8 <va_pa_offset>
ffffffffc0204860:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204864:	6605                	lui	a2,0x1
ffffffffc0204866:	000a6597          	auipc	a1,0xa6
ffffffffc020486a:	e525b583          	ld	a1,-430(a1) # ffffffffc02aa6b8 <boot_pgdir_va>
ffffffffc020486e:	9936                	add	s2,s2,a3
ffffffffc0204870:	854a                	mv	a0,s2
ffffffffc0204872:	593000ef          	jal	ra,ffffffffc0205604 <memcpy>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204876:	7782                	ld	a5,32(sp)
ffffffffc0204878:	4398                	lw	a4,0(a5)
ffffffffc020487a:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc020487e:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204882:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9467>
ffffffffc0204886:	12f71863          	bne	a4,a5,ffffffffc02049b6 <do_execve+0x246>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020488a:	7682                	ld	a3,32(sp)
ffffffffc020488c:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204890:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204894:	00371793          	slli	a5,a4,0x3
ffffffffc0204898:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020489a:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020489c:	078e                	slli	a5,a5,0x3
ffffffffc020489e:	97ce                	add	a5,a5,s3
ffffffffc02048a0:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph++)
ffffffffc02048a2:	00f9fc63          	bgeu	s3,a5,ffffffffc02048ba <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc02048a6:	0009a783          	lw	a5,0(s3)
ffffffffc02048aa:	4705                	li	a4,1
ffffffffc02048ac:	12e78163          	beq	a5,a4,ffffffffc02049ce <do_execve+0x25e>
    for (; ph < ph_end; ph++)
ffffffffc02048b0:	77a2                	ld	a5,40(sp)
ffffffffc02048b2:	03898993          	addi	s3,s3,56
ffffffffc02048b6:	fef9e8e3          	bltu	s3,a5,ffffffffc02048a6 <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc02048ba:	4701                	li	a4,0
ffffffffc02048bc:	46ad                	li	a3,11
ffffffffc02048be:	00100637          	lui	a2,0x100
ffffffffc02048c2:	7ff005b7          	lui	a1,0x7ff00
ffffffffc02048c6:	8526                	mv	a0,s1
ffffffffc02048c8:	f05fe0ef          	jal	ra,ffffffffc02037cc <mm_map>
ffffffffc02048cc:	892a                	mv	s2,a0
ffffffffc02048ce:	1c051263          	bnez	a0,ffffffffc0204a92 <do_execve+0x322>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc02048d2:	6c88                	ld	a0,24(s1)
ffffffffc02048d4:	467d                	li	a2,31
ffffffffc02048d6:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc02048da:	c7bfe0ef          	jal	ra,ffffffffc0203554 <pgdir_alloc_page>
ffffffffc02048de:	36050363          	beqz	a0,ffffffffc0204c44 <do_execve+0x4d4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc02048e2:	6c88                	ld	a0,24(s1)
ffffffffc02048e4:	467d                	li	a2,31
ffffffffc02048e6:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc02048ea:	c6bfe0ef          	jal	ra,ffffffffc0203554 <pgdir_alloc_page>
ffffffffc02048ee:	32050b63          	beqz	a0,ffffffffc0204c24 <do_execve+0x4b4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc02048f2:	6c88                	ld	a0,24(s1)
ffffffffc02048f4:	467d                	li	a2,31
ffffffffc02048f6:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc02048fa:	c5bfe0ef          	jal	ra,ffffffffc0203554 <pgdir_alloc_page>
ffffffffc02048fe:	30050363          	beqz	a0,ffffffffc0204c04 <do_execve+0x494>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204902:	6c88                	ld	a0,24(s1)
ffffffffc0204904:	467d                	li	a2,31
ffffffffc0204906:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc020490a:	c4bfe0ef          	jal	ra,ffffffffc0203554 <pgdir_alloc_page>
ffffffffc020490e:	2c050b63          	beqz	a0,ffffffffc0204be4 <do_execve+0x474>
    mm->mm_count += 1;
ffffffffc0204912:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0204914:	000db603          	ld	a2,0(s11)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204918:	6c94                	ld	a3,24(s1)
ffffffffc020491a:	2785                	addiw	a5,a5,1
ffffffffc020491c:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc020491e:	f604                	sd	s1,40(a2)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204920:	c02007b7          	lui	a5,0xc0200
ffffffffc0204924:	2af6e463          	bltu	a3,a5,ffffffffc0204bcc <do_execve+0x45c>
ffffffffc0204928:	000b3783          	ld	a5,0(s6)
ffffffffc020492c:	577d                	li	a4,-1
ffffffffc020492e:	177e                	slli	a4,a4,0x3f
ffffffffc0204930:	8e9d                	sub	a3,a3,a5
ffffffffc0204932:	00c6d793          	srli	a5,a3,0xc
ffffffffc0204936:	f654                	sd	a3,168(a2)
ffffffffc0204938:	8fd9                	or	a5,a5,a4
ffffffffc020493a:	18079073          	csrw	satp,a5
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc020493e:	7248                	ld	a0,160(a2)
ffffffffc0204940:	4581                	li	a1,0
ffffffffc0204942:	12000613          	li	a2,288
ffffffffc0204946:	4ad000ef          	jal	ra,ffffffffc02055f2 <memset>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020494a:	000db403          	ld	s0,0(s11)
ffffffffc020494e:	4641                	li	a2,16
ffffffffc0204950:	4581                	li	a1,0
ffffffffc0204952:	0b440413          	addi	s0,s0,180
ffffffffc0204956:	8522                	mv	a0,s0
ffffffffc0204958:	49b000ef          	jal	ra,ffffffffc02055f2 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020495c:	463d                	li	a2,15
ffffffffc020495e:	180c                	addi	a1,sp,48
ffffffffc0204960:	8522                	mv	a0,s0
ffffffffc0204962:	4a3000ef          	jal	ra,ffffffffc0205604 <memcpy>
}
ffffffffc0204966:	70aa                	ld	ra,168(sp)
ffffffffc0204968:	740a                	ld	s0,160(sp)
ffffffffc020496a:	64ea                	ld	s1,152(sp)
ffffffffc020496c:	69aa                	ld	s3,136(sp)
ffffffffc020496e:	6a0a                	ld	s4,128(sp)
ffffffffc0204970:	7ae6                	ld	s5,120(sp)
ffffffffc0204972:	7b46                	ld	s6,112(sp)
ffffffffc0204974:	7ba6                	ld	s7,104(sp)
ffffffffc0204976:	7c06                	ld	s8,96(sp)
ffffffffc0204978:	6ce6                	ld	s9,88(sp)
ffffffffc020497a:	6d46                	ld	s10,80(sp)
ffffffffc020497c:	6da6                	ld	s11,72(sp)
ffffffffc020497e:	854a                	mv	a0,s2
ffffffffc0204980:	694a                	ld	s2,144(sp)
ffffffffc0204982:	614d                	addi	sp,sp,176
ffffffffc0204984:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc0204986:	463d                	li	a2,15
ffffffffc0204988:	85ca                	mv	a1,s2
ffffffffc020498a:	1808                	addi	a0,sp,48
ffffffffc020498c:	479000ef          	jal	ra,ffffffffc0205604 <memcpy>
    if (mm != NULL)
ffffffffc0204990:	e40991e3          	bnez	s3,ffffffffc02047d2 <do_execve+0x62>
    if (current->mm != NULL)
ffffffffc0204994:	000db783          	ld	a5,0(s11)
ffffffffc0204998:	779c                	ld	a5,40(a5)
ffffffffc020499a:	e60788e3          	beqz	a5,ffffffffc020480a <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc020499e:	00002617          	auipc	a2,0x2
ffffffffc02049a2:	72260613          	addi	a2,a2,1826 # ffffffffc02070c0 <default_pmm_manager+0xc28>
ffffffffc02049a6:	24700593          	li	a1,583
ffffffffc02049aa:	00002517          	auipc	a0,0x2
ffffffffc02049ae:	54e50513          	addi	a0,a0,1358 # ffffffffc0206ef8 <default_pmm_manager+0xa60>
ffffffffc02049b2:	addfb0ef          	jal	ra,ffffffffc020048e <__panic>
    put_pgdir(mm);
ffffffffc02049b6:	8526                	mv	a0,s1
ffffffffc02049b8:	c92ff0ef          	jal	ra,ffffffffc0203e4a <put_pgdir>
    mm_destroy(mm);
ffffffffc02049bc:	8526                	mv	a0,s1
ffffffffc02049be:	dbdfe0ef          	jal	ra,ffffffffc020377a <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc02049c2:	5961                	li	s2,-8
    do_exit(ret);
ffffffffc02049c4:	854a                	mv	a0,s2
ffffffffc02049c6:	96bff0ef          	jal	ra,ffffffffc0204330 <do_exit>
    int ret = -E_NO_MEM;
ffffffffc02049ca:	5971                	li	s2,-4
ffffffffc02049cc:	bfe5                	j	ffffffffc02049c4 <do_execve+0x254>
        if (ph->p_filesz > ph->p_memsz)
ffffffffc02049ce:	0289b603          	ld	a2,40(s3)
ffffffffc02049d2:	0209b783          	ld	a5,32(s3)
ffffffffc02049d6:	1cf66d63          	bltu	a2,a5,ffffffffc0204bb0 <do_execve+0x440>
        if (ph->p_flags & ELF_PF_X)
ffffffffc02049da:	0049a783          	lw	a5,4(s3)
ffffffffc02049de:	0017f693          	andi	a3,a5,1
ffffffffc02049e2:	c291                	beqz	a3,ffffffffc02049e6 <do_execve+0x276>
            vm_flags |= VM_EXEC;
ffffffffc02049e4:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc02049e6:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc02049ea:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc02049ec:	e779                	bnez	a4,ffffffffc0204aba <do_execve+0x34a>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc02049ee:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc02049f0:	c781                	beqz	a5,ffffffffc02049f8 <do_execve+0x288>
            vm_flags |= VM_READ;
ffffffffc02049f2:	0016e693          	ori	a3,a3,1
            perm |= PTE_R;
ffffffffc02049f6:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE)
ffffffffc02049f8:	0026f793          	andi	a5,a3,2
ffffffffc02049fc:	e3f1                	bnez	a5,ffffffffc0204ac0 <do_execve+0x350>
        if (vm_flags & VM_EXEC)
ffffffffc02049fe:	0046f793          	andi	a5,a3,4
ffffffffc0204a02:	c399                	beqz	a5,ffffffffc0204a08 <do_execve+0x298>
            perm |= PTE_X;
ffffffffc0204a04:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc0204a08:	0109b583          	ld	a1,16(s3)
ffffffffc0204a0c:	4701                	li	a4,0
ffffffffc0204a0e:	8526                	mv	a0,s1
ffffffffc0204a10:	dbdfe0ef          	jal	ra,ffffffffc02037cc <mm_map>
ffffffffc0204a14:	892a                	mv	s2,a0
ffffffffc0204a16:	ed35                	bnez	a0,ffffffffc0204a92 <do_execve+0x322>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204a18:	0109ba83          	ld	s5,16(s3)
ffffffffc0204a1c:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0204a1e:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204a22:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204a26:	00fafbb3          	and	s7,s5,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204a2a:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0204a2c:	9a56                	add	s4,s4,s5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204a2e:	993e                	add	s2,s2,a5
        while (start < end)
ffffffffc0204a30:	054ae963          	bltu	s5,s4,ffffffffc0204a82 <do_execve+0x312>
ffffffffc0204a34:	aa95                	j	ffffffffc0204ba8 <do_execve+0x438>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204a36:	6785                	lui	a5,0x1
ffffffffc0204a38:	417a8533          	sub	a0,s5,s7
ffffffffc0204a3c:	9bbe                	add	s7,s7,a5
ffffffffc0204a3e:	415b8633          	sub	a2,s7,s5
            if (end < la)
ffffffffc0204a42:	017a7463          	bgeu	s4,s7,ffffffffc0204a4a <do_execve+0x2da>
                size -= la - end;
ffffffffc0204a46:	415a0633          	sub	a2,s4,s5
    return page - pages + nbase;
ffffffffc0204a4a:	000c3683          	ld	a3,0(s8)
ffffffffc0204a4e:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204a50:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0204a54:	40d406b3          	sub	a3,s0,a3
ffffffffc0204a58:	8699                	srai	a3,a3,0x6
ffffffffc0204a5a:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204a5c:	67e2                	ld	a5,24(sp)
ffffffffc0204a5e:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204a62:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204a64:	14b87863          	bgeu	a6,a1,ffffffffc0204bb4 <do_execve+0x444>
ffffffffc0204a68:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204a6c:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0204a6e:	9ab2                	add	s5,s5,a2
ffffffffc0204a70:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204a72:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0204a74:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204a76:	38f000ef          	jal	ra,ffffffffc0205604 <memcpy>
            start += size, from += size;
ffffffffc0204a7a:	6622                	ld	a2,8(sp)
ffffffffc0204a7c:	9932                	add	s2,s2,a2
        while (start < end)
ffffffffc0204a7e:	054af363          	bgeu	s5,s4,ffffffffc0204ac4 <do_execve+0x354>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204a82:	6c88                	ld	a0,24(s1)
ffffffffc0204a84:	866a                	mv	a2,s10
ffffffffc0204a86:	85de                	mv	a1,s7
ffffffffc0204a88:	acdfe0ef          	jal	ra,ffffffffc0203554 <pgdir_alloc_page>
ffffffffc0204a8c:	842a                	mv	s0,a0
ffffffffc0204a8e:	f545                	bnez	a0,ffffffffc0204a36 <do_execve+0x2c6>
        ret = -E_NO_MEM;
ffffffffc0204a90:	5971                	li	s2,-4
    exit_mmap(mm);
ffffffffc0204a92:	8526                	mv	a0,s1
ffffffffc0204a94:	e83fe0ef          	jal	ra,ffffffffc0203916 <exit_mmap>
    put_pgdir(mm);
ffffffffc0204a98:	8526                	mv	a0,s1
ffffffffc0204a9a:	bb0ff0ef          	jal	ra,ffffffffc0203e4a <put_pgdir>
    mm_destroy(mm);
ffffffffc0204a9e:	8526                	mv	a0,s1
ffffffffc0204aa0:	cdbfe0ef          	jal	ra,ffffffffc020377a <mm_destroy>
    return ret;
ffffffffc0204aa4:	b705                	j	ffffffffc02049c4 <do_execve+0x254>
            exit_mmap(mm);
ffffffffc0204aa6:	854e                	mv	a0,s3
ffffffffc0204aa8:	e6ffe0ef          	jal	ra,ffffffffc0203916 <exit_mmap>
            put_pgdir(mm);
ffffffffc0204aac:	854e                	mv	a0,s3
ffffffffc0204aae:	b9cff0ef          	jal	ra,ffffffffc0203e4a <put_pgdir>
            mm_destroy(mm);
ffffffffc0204ab2:	854e                	mv	a0,s3
ffffffffc0204ab4:	cc7fe0ef          	jal	ra,ffffffffc020377a <mm_destroy>
ffffffffc0204ab8:	b3a9                	j	ffffffffc0204802 <do_execve+0x92>
            vm_flags |= VM_WRITE;
ffffffffc0204aba:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204abe:	fb95                	bnez	a5,ffffffffc02049f2 <do_execve+0x282>
            perm |= (PTE_W | PTE_R);
ffffffffc0204ac0:	4d5d                	li	s10,23
ffffffffc0204ac2:	bf35                	j	ffffffffc02049fe <do_execve+0x28e>
        end = ph->p_va + ph->p_memsz;
ffffffffc0204ac4:	0109b903          	ld	s2,16(s3)
ffffffffc0204ac8:	0289b683          	ld	a3,40(s3)
ffffffffc0204acc:	9936                	add	s2,s2,a3
        if (start < la)
ffffffffc0204ace:	077afd63          	bgeu	s5,s7,ffffffffc0204b48 <do_execve+0x3d8>
            if (start == end)
ffffffffc0204ad2:	dd590fe3          	beq	s2,s5,ffffffffc02048b0 <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204ad6:	6785                	lui	a5,0x1
ffffffffc0204ad8:	00fa8533          	add	a0,s5,a5
ffffffffc0204adc:	41750533          	sub	a0,a0,s7
                size -= la - end;
ffffffffc0204ae0:	41590a33          	sub	s4,s2,s5
            if (end < la)
ffffffffc0204ae4:	0b797d63          	bgeu	s2,s7,ffffffffc0204b9e <do_execve+0x42e>
    return page - pages + nbase;
ffffffffc0204ae8:	000c3683          	ld	a3,0(s8)
ffffffffc0204aec:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204aee:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0204af2:	40d406b3          	sub	a3,s0,a3
ffffffffc0204af6:	8699                	srai	a3,a3,0x6
ffffffffc0204af8:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204afa:	67e2                	ld	a5,24(sp)
ffffffffc0204afc:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b00:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204b02:	0ac5f963          	bgeu	a1,a2,ffffffffc0204bb4 <do_execve+0x444>
ffffffffc0204b06:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204b0a:	8652                	mv	a2,s4
ffffffffc0204b0c:	4581                	li	a1,0
ffffffffc0204b0e:	96c2                	add	a3,a3,a6
ffffffffc0204b10:	9536                	add	a0,a0,a3
ffffffffc0204b12:	2e1000ef          	jal	ra,ffffffffc02055f2 <memset>
            start += size;
ffffffffc0204b16:	015a0733          	add	a4,s4,s5
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0204b1a:	03797463          	bgeu	s2,s7,ffffffffc0204b42 <do_execve+0x3d2>
ffffffffc0204b1e:	d8e909e3          	beq	s2,a4,ffffffffc02048b0 <do_execve+0x140>
ffffffffc0204b22:	00002697          	auipc	a3,0x2
ffffffffc0204b26:	5c668693          	addi	a3,a3,1478 # ffffffffc02070e8 <default_pmm_manager+0xc50>
ffffffffc0204b2a:	00001617          	auipc	a2,0x1
ffffffffc0204b2e:	5be60613          	addi	a2,a2,1470 # ffffffffc02060e8 <commands+0x860>
ffffffffc0204b32:	2b000593          	li	a1,688
ffffffffc0204b36:	00002517          	auipc	a0,0x2
ffffffffc0204b3a:	3c250513          	addi	a0,a0,962 # ffffffffc0206ef8 <default_pmm_manager+0xa60>
ffffffffc0204b3e:	951fb0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc0204b42:	ff7710e3          	bne	a4,s7,ffffffffc0204b22 <do_execve+0x3b2>
ffffffffc0204b46:	8ade                	mv	s5,s7
        while (start < end)
ffffffffc0204b48:	d72af4e3          	bgeu	s5,s2,ffffffffc02048b0 <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204b4c:	6c88                	ld	a0,24(s1)
ffffffffc0204b4e:	866a                	mv	a2,s10
ffffffffc0204b50:	85de                	mv	a1,s7
ffffffffc0204b52:	a03fe0ef          	jal	ra,ffffffffc0203554 <pgdir_alloc_page>
ffffffffc0204b56:	842a                	mv	s0,a0
ffffffffc0204b58:	dd05                	beqz	a0,ffffffffc0204a90 <do_execve+0x320>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204b5a:	6785                	lui	a5,0x1
ffffffffc0204b5c:	417a8533          	sub	a0,s5,s7
ffffffffc0204b60:	9bbe                	add	s7,s7,a5
ffffffffc0204b62:	415b8633          	sub	a2,s7,s5
            if (end < la)
ffffffffc0204b66:	01797463          	bgeu	s2,s7,ffffffffc0204b6e <do_execve+0x3fe>
                size -= la - end;
ffffffffc0204b6a:	41590633          	sub	a2,s2,s5
    return page - pages + nbase;
ffffffffc0204b6e:	000c3683          	ld	a3,0(s8)
ffffffffc0204b72:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204b74:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0204b78:	40d406b3          	sub	a3,s0,a3
ffffffffc0204b7c:	8699                	srai	a3,a3,0x6
ffffffffc0204b7e:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204b80:	67e2                	ld	a5,24(sp)
ffffffffc0204b82:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b86:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204b88:	02b87663          	bgeu	a6,a1,ffffffffc0204bb4 <do_execve+0x444>
ffffffffc0204b8c:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204b90:	4581                	li	a1,0
            start += size;
ffffffffc0204b92:	9ab2                	add	s5,s5,a2
ffffffffc0204b94:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0204b96:	9536                	add	a0,a0,a3
ffffffffc0204b98:	25b000ef          	jal	ra,ffffffffc02055f2 <memset>
ffffffffc0204b9c:	b775                	j	ffffffffc0204b48 <do_execve+0x3d8>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204b9e:	415b8a33          	sub	s4,s7,s5
ffffffffc0204ba2:	b799                	j	ffffffffc0204ae8 <do_execve+0x378>
        return -E_INVAL;
ffffffffc0204ba4:	5975                	li	s2,-3
ffffffffc0204ba6:	b3c1                	j	ffffffffc0204966 <do_execve+0x1f6>
        while (start < end)
ffffffffc0204ba8:	8956                	mv	s2,s5
ffffffffc0204baa:	bf39                	j	ffffffffc0204ac8 <do_execve+0x358>
    int ret = -E_NO_MEM;
ffffffffc0204bac:	5971                	li	s2,-4
ffffffffc0204bae:	bdc5                	j	ffffffffc0204a9e <do_execve+0x32e>
            ret = -E_INVAL_ELF;
ffffffffc0204bb0:	5961                	li	s2,-8
ffffffffc0204bb2:	b5c5                	j	ffffffffc0204a92 <do_execve+0x322>
ffffffffc0204bb4:	00002617          	auipc	a2,0x2
ffffffffc0204bb8:	91c60613          	addi	a2,a2,-1764 # ffffffffc02064d0 <default_pmm_manager+0x38>
ffffffffc0204bbc:	07100593          	li	a1,113
ffffffffc0204bc0:	00002517          	auipc	a0,0x2
ffffffffc0204bc4:	93850513          	addi	a0,a0,-1736 # ffffffffc02064f8 <default_pmm_manager+0x60>
ffffffffc0204bc8:	8c7fb0ef          	jal	ra,ffffffffc020048e <__panic>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204bcc:	00002617          	auipc	a2,0x2
ffffffffc0204bd0:	9ac60613          	addi	a2,a2,-1620 # ffffffffc0206578 <default_pmm_manager+0xe0>
ffffffffc0204bd4:	2cf00593          	li	a1,719
ffffffffc0204bd8:	00002517          	auipc	a0,0x2
ffffffffc0204bdc:	32050513          	addi	a0,a0,800 # ffffffffc0206ef8 <default_pmm_manager+0xa60>
ffffffffc0204be0:	8affb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204be4:	00002697          	auipc	a3,0x2
ffffffffc0204be8:	61c68693          	addi	a3,a3,1564 # ffffffffc0207200 <default_pmm_manager+0xd68>
ffffffffc0204bec:	00001617          	auipc	a2,0x1
ffffffffc0204bf0:	4fc60613          	addi	a2,a2,1276 # ffffffffc02060e8 <commands+0x860>
ffffffffc0204bf4:	2ca00593          	li	a1,714
ffffffffc0204bf8:	00002517          	auipc	a0,0x2
ffffffffc0204bfc:	30050513          	addi	a0,a0,768 # ffffffffc0206ef8 <default_pmm_manager+0xa60>
ffffffffc0204c00:	88ffb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204c04:	00002697          	auipc	a3,0x2
ffffffffc0204c08:	5b468693          	addi	a3,a3,1460 # ffffffffc02071b8 <default_pmm_manager+0xd20>
ffffffffc0204c0c:	00001617          	auipc	a2,0x1
ffffffffc0204c10:	4dc60613          	addi	a2,a2,1244 # ffffffffc02060e8 <commands+0x860>
ffffffffc0204c14:	2c900593          	li	a1,713
ffffffffc0204c18:	00002517          	auipc	a0,0x2
ffffffffc0204c1c:	2e050513          	addi	a0,a0,736 # ffffffffc0206ef8 <default_pmm_manager+0xa60>
ffffffffc0204c20:	86ffb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204c24:	00002697          	auipc	a3,0x2
ffffffffc0204c28:	54c68693          	addi	a3,a3,1356 # ffffffffc0207170 <default_pmm_manager+0xcd8>
ffffffffc0204c2c:	00001617          	auipc	a2,0x1
ffffffffc0204c30:	4bc60613          	addi	a2,a2,1212 # ffffffffc02060e8 <commands+0x860>
ffffffffc0204c34:	2c800593          	li	a1,712
ffffffffc0204c38:	00002517          	auipc	a0,0x2
ffffffffc0204c3c:	2c050513          	addi	a0,a0,704 # ffffffffc0206ef8 <default_pmm_manager+0xa60>
ffffffffc0204c40:	84ffb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204c44:	00002697          	auipc	a3,0x2
ffffffffc0204c48:	4e468693          	addi	a3,a3,1252 # ffffffffc0207128 <default_pmm_manager+0xc90>
ffffffffc0204c4c:	00001617          	auipc	a2,0x1
ffffffffc0204c50:	49c60613          	addi	a2,a2,1180 # ffffffffc02060e8 <commands+0x860>
ffffffffc0204c54:	2c700593          	li	a1,711
ffffffffc0204c58:	00002517          	auipc	a0,0x2
ffffffffc0204c5c:	2a050513          	addi	a0,a0,672 # ffffffffc0206ef8 <default_pmm_manager+0xa60>
ffffffffc0204c60:	82ffb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204c64 <do_yield>:
    current->need_resched = 1;
ffffffffc0204c64:	000a6797          	auipc	a5,0xa6
ffffffffc0204c68:	a7c7b783          	ld	a5,-1412(a5) # ffffffffc02aa6e0 <current>
ffffffffc0204c6c:	4705                	li	a4,1
ffffffffc0204c6e:	ef98                	sd	a4,24(a5)
}
ffffffffc0204c70:	4501                	li	a0,0
ffffffffc0204c72:	8082                	ret

ffffffffc0204c74 <do_wait>:
{
ffffffffc0204c74:	1101                	addi	sp,sp,-32
ffffffffc0204c76:	e822                	sd	s0,16(sp)
ffffffffc0204c78:	e426                	sd	s1,8(sp)
ffffffffc0204c7a:	ec06                	sd	ra,24(sp)
ffffffffc0204c7c:	842e                	mv	s0,a1
ffffffffc0204c7e:	84aa                	mv	s1,a0
    if (code_store != NULL)
ffffffffc0204c80:	c999                	beqz	a1,ffffffffc0204c96 <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0204c82:	000a6797          	auipc	a5,0xa6
ffffffffc0204c86:	a5e7b783          	ld	a5,-1442(a5) # ffffffffc02aa6e0 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0204c8a:	7788                	ld	a0,40(a5)
ffffffffc0204c8c:	4685                	li	a3,1
ffffffffc0204c8e:	4611                	li	a2,4
ffffffffc0204c90:	820ff0ef          	jal	ra,ffffffffc0203cb0 <user_mem_check>
ffffffffc0204c94:	c909                	beqz	a0,ffffffffc0204ca6 <do_wait+0x32>
ffffffffc0204c96:	85a2                	mv	a1,s0
}
ffffffffc0204c98:	6442                	ld	s0,16(sp)
ffffffffc0204c9a:	60e2                	ld	ra,24(sp)
ffffffffc0204c9c:	8526                	mv	a0,s1
ffffffffc0204c9e:	64a2                	ld	s1,8(sp)
ffffffffc0204ca0:	6105                	addi	sp,sp,32
ffffffffc0204ca2:	fd8ff06f          	j	ffffffffc020447a <do_wait.part.0>
ffffffffc0204ca6:	60e2                	ld	ra,24(sp)
ffffffffc0204ca8:	6442                	ld	s0,16(sp)
ffffffffc0204caa:	64a2                	ld	s1,8(sp)
ffffffffc0204cac:	5575                	li	a0,-3
ffffffffc0204cae:	6105                	addi	sp,sp,32
ffffffffc0204cb0:	8082                	ret

ffffffffc0204cb2 <do_kill>:
{
ffffffffc0204cb2:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID)
ffffffffc0204cb4:	6789                	lui	a5,0x2
{
ffffffffc0204cb6:	e406                	sd	ra,8(sp)
ffffffffc0204cb8:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID)
ffffffffc0204cba:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204cbe:	17f9                	addi	a5,a5,-2
ffffffffc0204cc0:	02e7e963          	bltu	a5,a4,ffffffffc0204cf2 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204cc4:	842a                	mv	s0,a0
ffffffffc0204cc6:	45a9                	li	a1,10
ffffffffc0204cc8:	2501                	sext.w	a0,a0
ffffffffc0204cca:	482000ef          	jal	ra,ffffffffc020514c <hash32>
ffffffffc0204cce:	02051793          	slli	a5,a0,0x20
ffffffffc0204cd2:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204cd6:	000a2797          	auipc	a5,0xa2
ffffffffc0204cda:	99278793          	addi	a5,a5,-1646 # ffffffffc02a6668 <hash_list>
ffffffffc0204cde:	953e                	add	a0,a0,a5
ffffffffc0204ce0:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list)
ffffffffc0204ce2:	a029                	j	ffffffffc0204cec <do_kill+0x3a>
            if (proc->pid == pid)
ffffffffc0204ce4:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0204ce8:	00870b63          	beq	a4,s0,ffffffffc0204cfe <do_kill+0x4c>
ffffffffc0204cec:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204cee:	fef51be3          	bne	a0,a5,ffffffffc0204ce4 <do_kill+0x32>
    return -E_INVAL;
ffffffffc0204cf2:	5475                	li	s0,-3
}
ffffffffc0204cf4:	60a2                	ld	ra,8(sp)
ffffffffc0204cf6:	8522                	mv	a0,s0
ffffffffc0204cf8:	6402                	ld	s0,0(sp)
ffffffffc0204cfa:	0141                	addi	sp,sp,16
ffffffffc0204cfc:	8082                	ret
        if (!(proc->flags & PF_EXITING))
ffffffffc0204cfe:	fd87a703          	lw	a4,-40(a5)
ffffffffc0204d02:	00177693          	andi	a3,a4,1
ffffffffc0204d06:	e295                	bnez	a3,ffffffffc0204d2a <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0204d08:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0204d0a:	00176713          	ori	a4,a4,1
ffffffffc0204d0e:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0204d12:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0204d14:	fe06d0e3          	bgez	a3,ffffffffc0204cf4 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0204d18:	f2878513          	addi	a0,a5,-216
ffffffffc0204d1c:	244000ef          	jal	ra,ffffffffc0204f60 <wakeup_proc>
}
ffffffffc0204d20:	60a2                	ld	ra,8(sp)
ffffffffc0204d22:	8522                	mv	a0,s0
ffffffffc0204d24:	6402                	ld	s0,0(sp)
ffffffffc0204d26:	0141                	addi	sp,sp,16
ffffffffc0204d28:	8082                	ret
        return -E_KILLED;
ffffffffc0204d2a:	545d                	li	s0,-9
ffffffffc0204d2c:	b7e1                	j	ffffffffc0204cf4 <do_kill+0x42>

ffffffffc0204d2e <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc0204d2e:	7179                	addi	sp,sp,-48
ffffffffc0204d30:	f022                	sd	s0,32(sp)
ffffffffc0204d32:	ec26                	sd	s1,24(sp)
ffffffffc0204d34:	f406                	sd	ra,40(sp)
ffffffffc0204d36:	e84a                	sd	s2,16(sp)
ffffffffc0204d38:	e44e                	sd	s3,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0204d3a:	000a6417          	auipc	s0,0xa6
ffffffffc0204d3e:	92e40413          	addi	s0,s0,-1746 # ffffffffc02aa668 <proc_list>
ffffffffc0204d42:	000a2497          	auipc	s1,0xa2
ffffffffc0204d46:	92648493          	addi	s1,s1,-1754 # ffffffffc02a6668 <hash_list>
ffffffffc0204d4a:	e400                	sd	s0,8(s0)
ffffffffc0204d4c:	e000                	sd	s0,0(s0)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0204d4e:	87a6                	mv	a5,s1
ffffffffc0204d50:	000a6717          	auipc	a4,0xa6
ffffffffc0204d54:	91870713          	addi	a4,a4,-1768 # ffffffffc02aa668 <proc_list>
ffffffffc0204d58:	e79c                	sd	a5,8(a5)
ffffffffc0204d5a:	e39c                	sd	a5,0(a5)
ffffffffc0204d5c:	07c1                	addi	a5,a5,16
ffffffffc0204d5e:	fef71de3          	bne	a4,a5,ffffffffc0204d58 <proc_init+0x2a>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc0204d62:	febfe0ef          	jal	ra,ffffffffc0203d4c <alloc_proc>
ffffffffc0204d66:	000a6917          	auipc	s2,0xa6
ffffffffc0204d6a:	98290913          	addi	s2,s2,-1662 # ffffffffc02aa6e8 <idleproc>
ffffffffc0204d6e:	00a93023          	sd	a0,0(s2)
ffffffffc0204d72:	10050963          	beqz	a0,ffffffffc0204e84 <proc_init+0x156>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0204d76:	4789                	li	a5,2
ffffffffc0204d78:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204d7a:	00003797          	auipc	a5,0x3
ffffffffc0204d7e:	28678793          	addi	a5,a5,646 # ffffffffc0208000 <bootstack>
ffffffffc0204d82:	e91c                	sd	a5,16(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204d84:	0b450993          	addi	s3,a0,180
    idleproc->need_resched = 1;
ffffffffc0204d88:	4785                	li	a5,1
ffffffffc0204d8a:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204d8c:	4641                	li	a2,16
ffffffffc0204d8e:	4581                	li	a1,0
ffffffffc0204d90:	854e                	mv	a0,s3
ffffffffc0204d92:	061000ef          	jal	ra,ffffffffc02055f2 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204d96:	463d                	li	a2,15
ffffffffc0204d98:	00002597          	auipc	a1,0x2
ffffffffc0204d9c:	4c858593          	addi	a1,a1,1224 # ffffffffc0207260 <default_pmm_manager+0xdc8>
ffffffffc0204da0:	854e                	mv	a0,s3
ffffffffc0204da2:	063000ef          	jal	ra,ffffffffc0205604 <memcpy>
    set_proc_name(idleproc, "idle");
    list_add(&proc_list, &(idleproc->list_link));
ffffffffc0204da6:	00093783          	ld	a5,0(s2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0204daa:	6410                	ld	a2,8(s0)
    nr_process++;
ffffffffc0204dac:	000a6697          	auipc	a3,0xa6
ffffffffc0204db0:	94c68693          	addi	a3,a3,-1716 # ffffffffc02aa6f8 <nr_process>
ffffffffc0204db4:	4298                	lw	a4,0(a3)
    list_add(&proc_list, &(idleproc->list_link));
ffffffffc0204db6:	0c878813          	addi	a6,a5,200
    prev->next = next->prev = elm;
ffffffffc0204dba:	01063023          	sd	a6,0(a2)
    nr_process++;
ffffffffc0204dbe:	2705                	addiw	a4,a4,1
    elm->next = next;
ffffffffc0204dc0:	ebf0                	sd	a2,208(a5)
    elm->prev = prev;
ffffffffc0204dc2:	e7e0                	sd	s0,200(a5)

    current = idleproc;

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0204dc4:	4601                	li	a2,0
ffffffffc0204dc6:	4581                	li	a1,0
ffffffffc0204dc8:	00000517          	auipc	a0,0x0
ffffffffc0204dcc:	88450513          	addi	a0,a0,-1916 # ffffffffc020464c <init_main>
    prev->next = next->prev = elm;
ffffffffc0204dd0:	01043423          	sd	a6,8(s0)
    nr_process++;
ffffffffc0204dd4:	c298                	sw	a4,0(a3)
    current = idleproc;
ffffffffc0204dd6:	000a6717          	auipc	a4,0xa6
ffffffffc0204dda:	90f73523          	sd	a5,-1782(a4) # ffffffffc02aa6e0 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0204dde:	d02ff0ef          	jal	ra,ffffffffc02042e0 <kernel_thread>
ffffffffc0204de2:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc0204de4:	08a05463          	blez	a0,ffffffffc0204e6c <proc_init+0x13e>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204de8:	6789                	lui	a5,0x2
ffffffffc0204dea:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204dee:	17f9                	addi	a5,a5,-2
ffffffffc0204df0:	2501                	sext.w	a0,a0
ffffffffc0204df2:	02e7e363          	bltu	a5,a4,ffffffffc0204e18 <proc_init+0xea>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204df6:	45a9                	li	a1,10
ffffffffc0204df8:	354000ef          	jal	ra,ffffffffc020514c <hash32>
ffffffffc0204dfc:	02051793          	slli	a5,a0,0x20
ffffffffc0204e00:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0204e04:	96a6                	add	a3,a3,s1
ffffffffc0204e06:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0204e08:	a029                	j	ffffffffc0204e12 <proc_init+0xe4>
            if (proc->pid == pid)
ffffffffc0204e0a:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c7c>
ffffffffc0204e0e:	04870c63          	beq	a4,s0,ffffffffc0204e66 <proc_init+0x138>
    return listelm->next;
ffffffffc0204e12:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204e14:	fef69be3          	bne	a3,a5,ffffffffc0204e0a <proc_init+0xdc>
    return NULL;
ffffffffc0204e18:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e1a:	0b478493          	addi	s1,a5,180
ffffffffc0204e1e:	4641                	li	a2,16
ffffffffc0204e20:	4581                	li	a1,0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0204e22:	000a6417          	auipc	s0,0xa6
ffffffffc0204e26:	8ce40413          	addi	s0,s0,-1842 # ffffffffc02aa6f0 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e2a:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0204e2c:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e2e:	7c4000ef          	jal	ra,ffffffffc02055f2 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204e32:	463d                	li	a2,15
ffffffffc0204e34:	00002597          	auipc	a1,0x2
ffffffffc0204e38:	45458593          	addi	a1,a1,1108 # ffffffffc0207288 <default_pmm_manager+0xdf0>
ffffffffc0204e3c:	8526                	mv	a0,s1
ffffffffc0204e3e:	7c6000ef          	jal	ra,ffffffffc0205604 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204e42:	00093783          	ld	a5,0(s2)
ffffffffc0204e46:	cbbd                	beqz	a5,ffffffffc0204ebc <proc_init+0x18e>
ffffffffc0204e48:	43dc                	lw	a5,4(a5)
ffffffffc0204e4a:	ebad                	bnez	a5,ffffffffc0204ebc <proc_init+0x18e>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204e4c:	601c                	ld	a5,0(s0)
ffffffffc0204e4e:	c7b9                	beqz	a5,ffffffffc0204e9c <proc_init+0x16e>
ffffffffc0204e50:	43d8                	lw	a4,4(a5)
ffffffffc0204e52:	4785                	li	a5,1
ffffffffc0204e54:	04f71463          	bne	a4,a5,ffffffffc0204e9c <proc_init+0x16e>
}
ffffffffc0204e58:	70a2                	ld	ra,40(sp)
ffffffffc0204e5a:	7402                	ld	s0,32(sp)
ffffffffc0204e5c:	64e2                	ld	s1,24(sp)
ffffffffc0204e5e:	6942                	ld	s2,16(sp)
ffffffffc0204e60:	69a2                	ld	s3,8(sp)
ffffffffc0204e62:	6145                	addi	sp,sp,48
ffffffffc0204e64:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204e66:	f2878793          	addi	a5,a5,-216
ffffffffc0204e6a:	bf45                	j	ffffffffc0204e1a <proc_init+0xec>
        panic("create init_main failed.\n");
ffffffffc0204e6c:	00002617          	auipc	a2,0x2
ffffffffc0204e70:	3fc60613          	addi	a2,a2,1020 # ffffffffc0207268 <default_pmm_manager+0xdd0>
ffffffffc0204e74:	3ee00593          	li	a1,1006
ffffffffc0204e78:	00002517          	auipc	a0,0x2
ffffffffc0204e7c:	08050513          	addi	a0,a0,128 # ffffffffc0206ef8 <default_pmm_manager+0xa60>
ffffffffc0204e80:	e0efb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0204e84:	00002617          	auipc	a2,0x2
ffffffffc0204e88:	3c460613          	addi	a2,a2,964 # ffffffffc0207248 <default_pmm_manager+0xdb0>
ffffffffc0204e8c:	3de00593          	li	a1,990
ffffffffc0204e90:	00002517          	auipc	a0,0x2
ffffffffc0204e94:	06850513          	addi	a0,a0,104 # ffffffffc0206ef8 <default_pmm_manager+0xa60>
ffffffffc0204e98:	df6fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204e9c:	00002697          	auipc	a3,0x2
ffffffffc0204ea0:	41c68693          	addi	a3,a3,1052 # ffffffffc02072b8 <default_pmm_manager+0xe20>
ffffffffc0204ea4:	00001617          	auipc	a2,0x1
ffffffffc0204ea8:	24460613          	addi	a2,a2,580 # ffffffffc02060e8 <commands+0x860>
ffffffffc0204eac:	3f500593          	li	a1,1013
ffffffffc0204eb0:	00002517          	auipc	a0,0x2
ffffffffc0204eb4:	04850513          	addi	a0,a0,72 # ffffffffc0206ef8 <default_pmm_manager+0xa60>
ffffffffc0204eb8:	dd6fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204ebc:	00002697          	auipc	a3,0x2
ffffffffc0204ec0:	3d468693          	addi	a3,a3,980 # ffffffffc0207290 <default_pmm_manager+0xdf8>
ffffffffc0204ec4:	00001617          	auipc	a2,0x1
ffffffffc0204ec8:	22460613          	addi	a2,a2,548 # ffffffffc02060e8 <commands+0x860>
ffffffffc0204ecc:	3f400593          	li	a1,1012
ffffffffc0204ed0:	00002517          	auipc	a0,0x2
ffffffffc0204ed4:	02850513          	addi	a0,a0,40 # ffffffffc0206ef8 <default_pmm_manager+0xa60>
ffffffffc0204ed8:	db6fb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204edc <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc0204edc:	1141                	addi	sp,sp,-16
ffffffffc0204ede:	e022                	sd	s0,0(sp)
ffffffffc0204ee0:	e406                	sd	ra,8(sp)
ffffffffc0204ee2:	000a5417          	auipc	s0,0xa5
ffffffffc0204ee6:	7fe40413          	addi	s0,s0,2046 # ffffffffc02aa6e0 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc0204eea:	6018                	ld	a4,0(s0)
ffffffffc0204eec:	6f1c                	ld	a5,24(a4)
ffffffffc0204eee:	dffd                	beqz	a5,ffffffffc0204eec <cpu_idle+0x10>
        {
            schedule();
ffffffffc0204ef0:	0f0000ef          	jal	ra,ffffffffc0204fe0 <schedule>
ffffffffc0204ef4:	bfdd                	j	ffffffffc0204eea <cpu_idle+0xe>

ffffffffc0204ef6 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204ef6:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204efa:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204efe:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204f00:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204f02:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204f06:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204f0a:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204f0e:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204f12:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204f16:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204f1a:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204f1e:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204f22:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204f26:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204f2a:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204f2e:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204f32:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204f34:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204f36:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204f3a:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204f3e:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204f42:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204f46:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204f4a:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204f4e:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204f52:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204f56:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204f5a:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204f5e:	8082                	ret

ffffffffc0204f60 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0204f60:	4118                	lw	a4,0(a0)
{
ffffffffc0204f62:	1101                	addi	sp,sp,-32
ffffffffc0204f64:	ec06                	sd	ra,24(sp)
ffffffffc0204f66:	e822                	sd	s0,16(sp)
ffffffffc0204f68:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0204f6a:	478d                	li	a5,3
ffffffffc0204f6c:	04f70b63          	beq	a4,a5,ffffffffc0204fc2 <wakeup_proc+0x62>
ffffffffc0204f70:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204f72:	100027f3          	csrr	a5,sstatus
ffffffffc0204f76:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204f78:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204f7a:	ef9d                	bnez	a5,ffffffffc0204fb8 <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
ffffffffc0204f7c:	4789                	li	a5,2
ffffffffc0204f7e:	02f70163          	beq	a4,a5,ffffffffc0204fa0 <wakeup_proc+0x40>
        {
            proc->state = PROC_RUNNABLE;
ffffffffc0204f82:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0204f84:	0e042623          	sw	zero,236(s0)
    if (flag)
ffffffffc0204f88:	e491                	bnez	s1,ffffffffc0204f94 <wakeup_proc+0x34>
        {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0204f8a:	60e2                	ld	ra,24(sp)
ffffffffc0204f8c:	6442                	ld	s0,16(sp)
ffffffffc0204f8e:	64a2                	ld	s1,8(sp)
ffffffffc0204f90:	6105                	addi	sp,sp,32
ffffffffc0204f92:	8082                	ret
ffffffffc0204f94:	6442                	ld	s0,16(sp)
ffffffffc0204f96:	60e2                	ld	ra,24(sp)
ffffffffc0204f98:	64a2                	ld	s1,8(sp)
ffffffffc0204f9a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204f9c:	a13fb06f          	j	ffffffffc02009ae <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0204fa0:	00002617          	auipc	a2,0x2
ffffffffc0204fa4:	37860613          	addi	a2,a2,888 # ffffffffc0207318 <default_pmm_manager+0xe80>
ffffffffc0204fa8:	45d1                	li	a1,20
ffffffffc0204faa:	00002517          	auipc	a0,0x2
ffffffffc0204fae:	35650513          	addi	a0,a0,854 # ffffffffc0207300 <default_pmm_manager+0xe68>
ffffffffc0204fb2:	d44fb0ef          	jal	ra,ffffffffc02004f6 <__warn>
ffffffffc0204fb6:	bfc9                	j	ffffffffc0204f88 <wakeup_proc+0x28>
        intr_disable();
ffffffffc0204fb8:	9fdfb0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        if (proc->state != PROC_RUNNABLE)
ffffffffc0204fbc:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc0204fbe:	4485                	li	s1,1
ffffffffc0204fc0:	bf75                	j	ffffffffc0204f7c <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0204fc2:	00002697          	auipc	a3,0x2
ffffffffc0204fc6:	31e68693          	addi	a3,a3,798 # ffffffffc02072e0 <default_pmm_manager+0xe48>
ffffffffc0204fca:	00001617          	auipc	a2,0x1
ffffffffc0204fce:	11e60613          	addi	a2,a2,286 # ffffffffc02060e8 <commands+0x860>
ffffffffc0204fd2:	45a5                	li	a1,9
ffffffffc0204fd4:	00002517          	auipc	a0,0x2
ffffffffc0204fd8:	32c50513          	addi	a0,a0,812 # ffffffffc0207300 <default_pmm_manager+0xe68>
ffffffffc0204fdc:	cb2fb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204fe0 <schedule>:

void schedule(void)
{
ffffffffc0204fe0:	1141                	addi	sp,sp,-16
ffffffffc0204fe2:	e406                	sd	ra,8(sp)
ffffffffc0204fe4:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204fe6:	100027f3          	csrr	a5,sstatus
ffffffffc0204fea:	8b89                	andi	a5,a5,2
ffffffffc0204fec:	4401                	li	s0,0
ffffffffc0204fee:	efbd                	bnez	a5,ffffffffc020506c <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0204ff0:	000a5897          	auipc	a7,0xa5
ffffffffc0204ff4:	6f08b883          	ld	a7,1776(a7) # ffffffffc02aa6e0 <current>
ffffffffc0204ff8:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204ffc:	000a5517          	auipc	a0,0xa5
ffffffffc0205000:	6ec53503          	ld	a0,1772(a0) # ffffffffc02aa6e8 <idleproc>
ffffffffc0205004:	04a88e63          	beq	a7,a0,ffffffffc0205060 <schedule+0x80>
ffffffffc0205008:	0c888693          	addi	a3,a7,200
ffffffffc020500c:	000a5617          	auipc	a2,0xa5
ffffffffc0205010:	65c60613          	addi	a2,a2,1628 # ffffffffc02aa668 <proc_list>
        le = last;
ffffffffc0205014:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0205016:	4581                	li	a1,0
        do
        {
            if ((le = list_next(le)) != &proc_list)
            {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE)
ffffffffc0205018:	4809                	li	a6,2
ffffffffc020501a:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list)
ffffffffc020501c:	00c78863          	beq	a5,a2,ffffffffc020502c <schedule+0x4c>
                if (next->state == PROC_RUNNABLE)
ffffffffc0205020:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0205024:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE)
ffffffffc0205028:	03070163          	beq	a4,a6,ffffffffc020504a <schedule+0x6a>
                {
                    break;
                }
            }
        } while (le != last);
ffffffffc020502c:	fef697e3          	bne	a3,a5,ffffffffc020501a <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc0205030:	ed89                	bnez	a1,ffffffffc020504a <schedule+0x6a>
        {
            next = idleproc;
        }
        next->runs++;
ffffffffc0205032:	451c                	lw	a5,8(a0)
ffffffffc0205034:	2785                	addiw	a5,a5,1
ffffffffc0205036:	c51c                	sw	a5,8(a0)
        if (next != current)
ffffffffc0205038:	00a88463          	beq	a7,a0,ffffffffc0205040 <schedule+0x60>
        {
            proc_run(next);
ffffffffc020503c:	e85fe0ef          	jal	ra,ffffffffc0203ec0 <proc_run>
    if (flag)
ffffffffc0205040:	e819                	bnez	s0,ffffffffc0205056 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205042:	60a2                	ld	ra,8(sp)
ffffffffc0205044:	6402                	ld	s0,0(sp)
ffffffffc0205046:	0141                	addi	sp,sp,16
ffffffffc0205048:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc020504a:	4198                	lw	a4,0(a1)
ffffffffc020504c:	4789                	li	a5,2
ffffffffc020504e:	fef712e3          	bne	a4,a5,ffffffffc0205032 <schedule+0x52>
ffffffffc0205052:	852e                	mv	a0,a1
ffffffffc0205054:	bff9                	j	ffffffffc0205032 <schedule+0x52>
}
ffffffffc0205056:	6402                	ld	s0,0(sp)
ffffffffc0205058:	60a2                	ld	ra,8(sp)
ffffffffc020505a:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020505c:	953fb06f          	j	ffffffffc02009ae <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205060:	000a5617          	auipc	a2,0xa5
ffffffffc0205064:	60860613          	addi	a2,a2,1544 # ffffffffc02aa668 <proc_list>
ffffffffc0205068:	86b2                	mv	a3,a2
ffffffffc020506a:	b76d                	j	ffffffffc0205014 <schedule+0x34>
        intr_disable();
ffffffffc020506c:	949fb0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc0205070:	4405                	li	s0,1
ffffffffc0205072:	bfbd                	j	ffffffffc0204ff0 <schedule+0x10>

ffffffffc0205074 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0205074:	000a5797          	auipc	a5,0xa5
ffffffffc0205078:	66c7b783          	ld	a5,1644(a5) # ffffffffc02aa6e0 <current>
}
ffffffffc020507c:	43c8                	lw	a0,4(a5)
ffffffffc020507e:	8082                	ret

ffffffffc0205080 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0205080:	4501                	li	a0,0
ffffffffc0205082:	8082                	ret

ffffffffc0205084 <sys_putc>:
    cputchar(c);
ffffffffc0205084:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0205086:	1141                	addi	sp,sp,-16
ffffffffc0205088:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc020508a:	940fb0ef          	jal	ra,ffffffffc02001ca <cputchar>
}
ffffffffc020508e:	60a2                	ld	ra,8(sp)
ffffffffc0205090:	4501                	li	a0,0
ffffffffc0205092:	0141                	addi	sp,sp,16
ffffffffc0205094:	8082                	ret

ffffffffc0205096 <sys_kill>:
    return do_kill(pid);
ffffffffc0205096:	4108                	lw	a0,0(a0)
ffffffffc0205098:	c1bff06f          	j	ffffffffc0204cb2 <do_kill>

ffffffffc020509c <sys_yield>:
    return do_yield();
ffffffffc020509c:	bc9ff06f          	j	ffffffffc0204c64 <do_yield>

ffffffffc02050a0 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc02050a0:	6d14                	ld	a3,24(a0)
ffffffffc02050a2:	6910                	ld	a2,16(a0)
ffffffffc02050a4:	650c                	ld	a1,8(a0)
ffffffffc02050a6:	6108                	ld	a0,0(a0)
ffffffffc02050a8:	ec8ff06f          	j	ffffffffc0204770 <do_execve>

ffffffffc02050ac <sys_wait>:
    return do_wait(pid, store);
ffffffffc02050ac:	650c                	ld	a1,8(a0)
ffffffffc02050ae:	4108                	lw	a0,0(a0)
ffffffffc02050b0:	bc5ff06f          	j	ffffffffc0204c74 <do_wait>

ffffffffc02050b4 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc02050b4:	000a5797          	auipc	a5,0xa5
ffffffffc02050b8:	62c7b783          	ld	a5,1580(a5) # ffffffffc02aa6e0 <current>
ffffffffc02050bc:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02050be:	4501                	li	a0,0
ffffffffc02050c0:	6a0c                	ld	a1,16(a2)
ffffffffc02050c2:	e63fe06f          	j	ffffffffc0203f24 <do_fork>

ffffffffc02050c6 <sys_exit>:
    return do_exit(error_code);
ffffffffc02050c6:	4108                	lw	a0,0(a0)
ffffffffc02050c8:	a68ff06f          	j	ffffffffc0204330 <do_exit>

ffffffffc02050cc <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc02050cc:	715d                	addi	sp,sp,-80
ffffffffc02050ce:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02050d0:	000a5497          	auipc	s1,0xa5
ffffffffc02050d4:	61048493          	addi	s1,s1,1552 # ffffffffc02aa6e0 <current>
ffffffffc02050d8:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02050da:	e0a2                	sd	s0,64(sp)
ffffffffc02050dc:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02050de:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02050e0:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02050e2:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02050e4:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02050e8:	0327ee63          	bltu	a5,s2,ffffffffc0205124 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc02050ec:	00391713          	slli	a4,s2,0x3
ffffffffc02050f0:	00002797          	auipc	a5,0x2
ffffffffc02050f4:	29078793          	addi	a5,a5,656 # ffffffffc0207380 <syscalls>
ffffffffc02050f8:	97ba                	add	a5,a5,a4
ffffffffc02050fa:	639c                	ld	a5,0(a5)
ffffffffc02050fc:	c785                	beqz	a5,ffffffffc0205124 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc02050fe:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0205100:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0205102:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0205104:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0205106:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0205108:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc020510a:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc020510c:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc020510e:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0205110:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205112:	0028                	addi	a0,sp,8
ffffffffc0205114:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0205116:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205118:	e828                	sd	a0,80(s0)
}
ffffffffc020511a:	6406                	ld	s0,64(sp)
ffffffffc020511c:	74e2                	ld	s1,56(sp)
ffffffffc020511e:	7942                	ld	s2,48(sp)
ffffffffc0205120:	6161                	addi	sp,sp,80
ffffffffc0205122:	8082                	ret
    print_trapframe(tf);
ffffffffc0205124:	8522                	mv	a0,s0
ffffffffc0205126:	a7ffb0ef          	jal	ra,ffffffffc0200ba4 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc020512a:	609c                	ld	a5,0(s1)
ffffffffc020512c:	86ca                	mv	a3,s2
ffffffffc020512e:	00002617          	auipc	a2,0x2
ffffffffc0205132:	20a60613          	addi	a2,a2,522 # ffffffffc0207338 <default_pmm_manager+0xea0>
ffffffffc0205136:	43d8                	lw	a4,4(a5)
ffffffffc0205138:	06200593          	li	a1,98
ffffffffc020513c:	0b478793          	addi	a5,a5,180
ffffffffc0205140:	00002517          	auipc	a0,0x2
ffffffffc0205144:	22850513          	addi	a0,a0,552 # ffffffffc0207368 <default_pmm_manager+0xed0>
ffffffffc0205148:	b46fb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020514c <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc020514c:	9e3707b7          	lui	a5,0x9e370
ffffffffc0205150:	2785                	addiw	a5,a5,1
ffffffffc0205152:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0205156:	02000793          	li	a5,32
ffffffffc020515a:	9f8d                	subw	a5,a5,a1
}
ffffffffc020515c:	00f5553b          	srlw	a0,a0,a5
ffffffffc0205160:	8082                	ret

ffffffffc0205162 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0205162:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205166:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0205168:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020516c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020516e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205172:	f022                	sd	s0,32(sp)
ffffffffc0205174:	ec26                	sd	s1,24(sp)
ffffffffc0205176:	e84a                	sd	s2,16(sp)
ffffffffc0205178:	f406                	sd	ra,40(sp)
ffffffffc020517a:	e44e                	sd	s3,8(sp)
ffffffffc020517c:	84aa                	mv	s1,a0
ffffffffc020517e:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0205180:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0205184:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0205186:	03067e63          	bgeu	a2,a6,ffffffffc02051c2 <printnum+0x60>
ffffffffc020518a:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020518c:	00805763          	blez	s0,ffffffffc020519a <printnum+0x38>
ffffffffc0205190:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0205192:	85ca                	mv	a1,s2
ffffffffc0205194:	854e                	mv	a0,s3
ffffffffc0205196:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0205198:	fc65                	bnez	s0,ffffffffc0205190 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020519a:	1a02                	slli	s4,s4,0x20
ffffffffc020519c:	00002797          	auipc	a5,0x2
ffffffffc02051a0:	2e478793          	addi	a5,a5,740 # ffffffffc0207480 <syscalls+0x100>
ffffffffc02051a4:	020a5a13          	srli	s4,s4,0x20
ffffffffc02051a8:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02051aa:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02051ac:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02051b0:	70a2                	ld	ra,40(sp)
ffffffffc02051b2:	69a2                	ld	s3,8(sp)
ffffffffc02051b4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02051b6:	85ca                	mv	a1,s2
ffffffffc02051b8:	87a6                	mv	a5,s1
}
ffffffffc02051ba:	6942                	ld	s2,16(sp)
ffffffffc02051bc:	64e2                	ld	s1,24(sp)
ffffffffc02051be:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02051c0:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02051c2:	03065633          	divu	a2,a2,a6
ffffffffc02051c6:	8722                	mv	a4,s0
ffffffffc02051c8:	f9bff0ef          	jal	ra,ffffffffc0205162 <printnum>
ffffffffc02051cc:	b7f9                	j	ffffffffc020519a <printnum+0x38>

ffffffffc02051ce <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02051ce:	7119                	addi	sp,sp,-128
ffffffffc02051d0:	f4a6                	sd	s1,104(sp)
ffffffffc02051d2:	f0ca                	sd	s2,96(sp)
ffffffffc02051d4:	ecce                	sd	s3,88(sp)
ffffffffc02051d6:	e8d2                	sd	s4,80(sp)
ffffffffc02051d8:	e4d6                	sd	s5,72(sp)
ffffffffc02051da:	e0da                	sd	s6,64(sp)
ffffffffc02051dc:	fc5e                	sd	s7,56(sp)
ffffffffc02051de:	f06a                	sd	s10,32(sp)
ffffffffc02051e0:	fc86                	sd	ra,120(sp)
ffffffffc02051e2:	f8a2                	sd	s0,112(sp)
ffffffffc02051e4:	f862                	sd	s8,48(sp)
ffffffffc02051e6:	f466                	sd	s9,40(sp)
ffffffffc02051e8:	ec6e                	sd	s11,24(sp)
ffffffffc02051ea:	892a                	mv	s2,a0
ffffffffc02051ec:	84ae                	mv	s1,a1
ffffffffc02051ee:	8d32                	mv	s10,a2
ffffffffc02051f0:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02051f2:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02051f6:	5b7d                	li	s6,-1
ffffffffc02051f8:	00002a97          	auipc	s5,0x2
ffffffffc02051fc:	2b4a8a93          	addi	s5,s5,692 # ffffffffc02074ac <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205200:	00002b97          	auipc	s7,0x2
ffffffffc0205204:	4c8b8b93          	addi	s7,s7,1224 # ffffffffc02076c8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205208:	000d4503          	lbu	a0,0(s10)
ffffffffc020520c:	001d0413          	addi	s0,s10,1
ffffffffc0205210:	01350a63          	beq	a0,s3,ffffffffc0205224 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0205214:	c121                	beqz	a0,ffffffffc0205254 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0205216:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205218:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020521a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020521c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0205220:	ff351ae3          	bne	a0,s3,ffffffffc0205214 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205224:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0205228:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020522c:	4c81                	li	s9,0
ffffffffc020522e:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0205230:	5c7d                	li	s8,-1
ffffffffc0205232:	5dfd                	li	s11,-1
ffffffffc0205234:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0205238:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020523a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020523e:	0ff5f593          	zext.b	a1,a1
ffffffffc0205242:	00140d13          	addi	s10,s0,1
ffffffffc0205246:	04b56263          	bltu	a0,a1,ffffffffc020528a <vprintfmt+0xbc>
ffffffffc020524a:	058a                	slli	a1,a1,0x2
ffffffffc020524c:	95d6                	add	a1,a1,s5
ffffffffc020524e:	4194                	lw	a3,0(a1)
ffffffffc0205250:	96d6                	add	a3,a3,s5
ffffffffc0205252:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0205254:	70e6                	ld	ra,120(sp)
ffffffffc0205256:	7446                	ld	s0,112(sp)
ffffffffc0205258:	74a6                	ld	s1,104(sp)
ffffffffc020525a:	7906                	ld	s2,96(sp)
ffffffffc020525c:	69e6                	ld	s3,88(sp)
ffffffffc020525e:	6a46                	ld	s4,80(sp)
ffffffffc0205260:	6aa6                	ld	s5,72(sp)
ffffffffc0205262:	6b06                	ld	s6,64(sp)
ffffffffc0205264:	7be2                	ld	s7,56(sp)
ffffffffc0205266:	7c42                	ld	s8,48(sp)
ffffffffc0205268:	7ca2                	ld	s9,40(sp)
ffffffffc020526a:	7d02                	ld	s10,32(sp)
ffffffffc020526c:	6de2                	ld	s11,24(sp)
ffffffffc020526e:	6109                	addi	sp,sp,128
ffffffffc0205270:	8082                	ret
            padc = '0';
ffffffffc0205272:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0205274:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205278:	846a                	mv	s0,s10
ffffffffc020527a:	00140d13          	addi	s10,s0,1
ffffffffc020527e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0205282:	0ff5f593          	zext.b	a1,a1
ffffffffc0205286:	fcb572e3          	bgeu	a0,a1,ffffffffc020524a <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020528a:	85a6                	mv	a1,s1
ffffffffc020528c:	02500513          	li	a0,37
ffffffffc0205290:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0205292:	fff44783          	lbu	a5,-1(s0)
ffffffffc0205296:	8d22                	mv	s10,s0
ffffffffc0205298:	f73788e3          	beq	a5,s3,ffffffffc0205208 <vprintfmt+0x3a>
ffffffffc020529c:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02052a0:	1d7d                	addi	s10,s10,-1
ffffffffc02052a2:	ff379de3          	bne	a5,s3,ffffffffc020529c <vprintfmt+0xce>
ffffffffc02052a6:	b78d                	j	ffffffffc0205208 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02052a8:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02052ac:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02052b0:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02052b2:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02052b6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02052ba:	02d86463          	bltu	a6,a3,ffffffffc02052e2 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02052be:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02052c2:	002c169b          	slliw	a3,s8,0x2
ffffffffc02052c6:	0186873b          	addw	a4,a3,s8
ffffffffc02052ca:	0017171b          	slliw	a4,a4,0x1
ffffffffc02052ce:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02052d0:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02052d4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02052d6:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02052da:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02052de:	fed870e3          	bgeu	a6,a3,ffffffffc02052be <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02052e2:	f40ddce3          	bgez	s11,ffffffffc020523a <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02052e6:	8de2                	mv	s11,s8
ffffffffc02052e8:	5c7d                	li	s8,-1
ffffffffc02052ea:	bf81                	j	ffffffffc020523a <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02052ec:	fffdc693          	not	a3,s11
ffffffffc02052f0:	96fd                	srai	a3,a3,0x3f
ffffffffc02052f2:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02052f6:	00144603          	lbu	a2,1(s0)
ffffffffc02052fa:	2d81                	sext.w	s11,s11
ffffffffc02052fc:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02052fe:	bf35                	j	ffffffffc020523a <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0205300:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205304:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0205308:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020530a:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020530c:	bfd9                	j	ffffffffc02052e2 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020530e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205310:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205314:	01174463          	blt	a4,a7,ffffffffc020531c <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0205318:	1a088e63          	beqz	a7,ffffffffc02054d4 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020531c:	000a3603          	ld	a2,0(s4)
ffffffffc0205320:	46c1                	li	a3,16
ffffffffc0205322:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0205324:	2781                	sext.w	a5,a5
ffffffffc0205326:	876e                	mv	a4,s11
ffffffffc0205328:	85a6                	mv	a1,s1
ffffffffc020532a:	854a                	mv	a0,s2
ffffffffc020532c:	e37ff0ef          	jal	ra,ffffffffc0205162 <printnum>
            break;
ffffffffc0205330:	bde1                	j	ffffffffc0205208 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0205332:	000a2503          	lw	a0,0(s4)
ffffffffc0205336:	85a6                	mv	a1,s1
ffffffffc0205338:	0a21                	addi	s4,s4,8
ffffffffc020533a:	9902                	jalr	s2
            break;
ffffffffc020533c:	b5f1                	j	ffffffffc0205208 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020533e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205340:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205344:	01174463          	blt	a4,a7,ffffffffc020534c <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0205348:	18088163          	beqz	a7,ffffffffc02054ca <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020534c:	000a3603          	ld	a2,0(s4)
ffffffffc0205350:	46a9                	li	a3,10
ffffffffc0205352:	8a2e                	mv	s4,a1
ffffffffc0205354:	bfc1                	j	ffffffffc0205324 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205356:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020535a:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020535c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020535e:	bdf1                	j	ffffffffc020523a <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0205360:	85a6                	mv	a1,s1
ffffffffc0205362:	02500513          	li	a0,37
ffffffffc0205366:	9902                	jalr	s2
            break;
ffffffffc0205368:	b545                	j	ffffffffc0205208 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020536a:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020536e:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205370:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0205372:	b5e1                	j	ffffffffc020523a <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0205374:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205376:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020537a:	01174463          	blt	a4,a7,ffffffffc0205382 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020537e:	14088163          	beqz	a7,ffffffffc02054c0 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0205382:	000a3603          	ld	a2,0(s4)
ffffffffc0205386:	46a1                	li	a3,8
ffffffffc0205388:	8a2e                	mv	s4,a1
ffffffffc020538a:	bf69                	j	ffffffffc0205324 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc020538c:	03000513          	li	a0,48
ffffffffc0205390:	85a6                	mv	a1,s1
ffffffffc0205392:	e03e                	sd	a5,0(sp)
ffffffffc0205394:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0205396:	85a6                	mv	a1,s1
ffffffffc0205398:	07800513          	li	a0,120
ffffffffc020539c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020539e:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02053a0:	6782                	ld	a5,0(sp)
ffffffffc02053a2:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02053a4:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02053a8:	bfb5                	j	ffffffffc0205324 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02053aa:	000a3403          	ld	s0,0(s4)
ffffffffc02053ae:	008a0713          	addi	a4,s4,8
ffffffffc02053b2:	e03a                	sd	a4,0(sp)
ffffffffc02053b4:	14040263          	beqz	s0,ffffffffc02054f8 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02053b8:	0fb05763          	blez	s11,ffffffffc02054a6 <vprintfmt+0x2d8>
ffffffffc02053bc:	02d00693          	li	a3,45
ffffffffc02053c0:	0cd79163          	bne	a5,a3,ffffffffc0205482 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02053c4:	00044783          	lbu	a5,0(s0)
ffffffffc02053c8:	0007851b          	sext.w	a0,a5
ffffffffc02053cc:	cf85                	beqz	a5,ffffffffc0205404 <vprintfmt+0x236>
ffffffffc02053ce:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02053d2:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02053d6:	000c4563          	bltz	s8,ffffffffc02053e0 <vprintfmt+0x212>
ffffffffc02053da:	3c7d                	addiw	s8,s8,-1
ffffffffc02053dc:	036c0263          	beq	s8,s6,ffffffffc0205400 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02053e0:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02053e2:	0e0c8e63          	beqz	s9,ffffffffc02054de <vprintfmt+0x310>
ffffffffc02053e6:	3781                	addiw	a5,a5,-32
ffffffffc02053e8:	0ef47b63          	bgeu	s0,a5,ffffffffc02054de <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02053ec:	03f00513          	li	a0,63
ffffffffc02053f0:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02053f2:	000a4783          	lbu	a5,0(s4)
ffffffffc02053f6:	3dfd                	addiw	s11,s11,-1
ffffffffc02053f8:	0a05                	addi	s4,s4,1
ffffffffc02053fa:	0007851b          	sext.w	a0,a5
ffffffffc02053fe:	ffe1                	bnez	a5,ffffffffc02053d6 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0205400:	01b05963          	blez	s11,ffffffffc0205412 <vprintfmt+0x244>
ffffffffc0205404:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0205406:	85a6                	mv	a1,s1
ffffffffc0205408:	02000513          	li	a0,32
ffffffffc020540c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020540e:	fe0d9be3          	bnez	s11,ffffffffc0205404 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0205412:	6a02                	ld	s4,0(sp)
ffffffffc0205414:	bbd5                	j	ffffffffc0205208 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0205416:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205418:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020541c:	01174463          	blt	a4,a7,ffffffffc0205424 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0205420:	08088d63          	beqz	a7,ffffffffc02054ba <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0205424:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0205428:	0a044d63          	bltz	s0,ffffffffc02054e2 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020542c:	8622                	mv	a2,s0
ffffffffc020542e:	8a66                	mv	s4,s9
ffffffffc0205430:	46a9                	li	a3,10
ffffffffc0205432:	bdcd                	j	ffffffffc0205324 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0205434:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205438:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc020543a:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020543c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0205440:	8fb5                	xor	a5,a5,a3
ffffffffc0205442:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205446:	02d74163          	blt	a4,a3,ffffffffc0205468 <vprintfmt+0x29a>
ffffffffc020544a:	00369793          	slli	a5,a3,0x3
ffffffffc020544e:	97de                	add	a5,a5,s7
ffffffffc0205450:	639c                	ld	a5,0(a5)
ffffffffc0205452:	cb99                	beqz	a5,ffffffffc0205468 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0205454:	86be                	mv	a3,a5
ffffffffc0205456:	00000617          	auipc	a2,0x0
ffffffffc020545a:	1f260613          	addi	a2,a2,498 # ffffffffc0205648 <etext+0x2c>
ffffffffc020545e:	85a6                	mv	a1,s1
ffffffffc0205460:	854a                	mv	a0,s2
ffffffffc0205462:	0ce000ef          	jal	ra,ffffffffc0205530 <printfmt>
ffffffffc0205466:	b34d                	j	ffffffffc0205208 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0205468:	00002617          	auipc	a2,0x2
ffffffffc020546c:	03860613          	addi	a2,a2,56 # ffffffffc02074a0 <syscalls+0x120>
ffffffffc0205470:	85a6                	mv	a1,s1
ffffffffc0205472:	854a                	mv	a0,s2
ffffffffc0205474:	0bc000ef          	jal	ra,ffffffffc0205530 <printfmt>
ffffffffc0205478:	bb41                	j	ffffffffc0205208 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020547a:	00002417          	auipc	s0,0x2
ffffffffc020547e:	01e40413          	addi	s0,s0,30 # ffffffffc0207498 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205482:	85e2                	mv	a1,s8
ffffffffc0205484:	8522                	mv	a0,s0
ffffffffc0205486:	e43e                	sd	a5,8(sp)
ffffffffc0205488:	0e2000ef          	jal	ra,ffffffffc020556a <strnlen>
ffffffffc020548c:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0205490:	01b05b63          	blez	s11,ffffffffc02054a6 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0205494:	67a2                	ld	a5,8(sp)
ffffffffc0205496:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020549a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020549c:	85a6                	mv	a1,s1
ffffffffc020549e:	8552                	mv	a0,s4
ffffffffc02054a0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02054a2:	fe0d9ce3          	bnez	s11,ffffffffc020549a <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02054a6:	00044783          	lbu	a5,0(s0)
ffffffffc02054aa:	00140a13          	addi	s4,s0,1
ffffffffc02054ae:	0007851b          	sext.w	a0,a5
ffffffffc02054b2:	d3a5                	beqz	a5,ffffffffc0205412 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02054b4:	05e00413          	li	s0,94
ffffffffc02054b8:	bf39                	j	ffffffffc02053d6 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02054ba:	000a2403          	lw	s0,0(s4)
ffffffffc02054be:	b7ad                	j	ffffffffc0205428 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02054c0:	000a6603          	lwu	a2,0(s4)
ffffffffc02054c4:	46a1                	li	a3,8
ffffffffc02054c6:	8a2e                	mv	s4,a1
ffffffffc02054c8:	bdb1                	j	ffffffffc0205324 <vprintfmt+0x156>
ffffffffc02054ca:	000a6603          	lwu	a2,0(s4)
ffffffffc02054ce:	46a9                	li	a3,10
ffffffffc02054d0:	8a2e                	mv	s4,a1
ffffffffc02054d2:	bd89                	j	ffffffffc0205324 <vprintfmt+0x156>
ffffffffc02054d4:	000a6603          	lwu	a2,0(s4)
ffffffffc02054d8:	46c1                	li	a3,16
ffffffffc02054da:	8a2e                	mv	s4,a1
ffffffffc02054dc:	b5a1                	j	ffffffffc0205324 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02054de:	9902                	jalr	s2
ffffffffc02054e0:	bf09                	j	ffffffffc02053f2 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02054e2:	85a6                	mv	a1,s1
ffffffffc02054e4:	02d00513          	li	a0,45
ffffffffc02054e8:	e03e                	sd	a5,0(sp)
ffffffffc02054ea:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02054ec:	6782                	ld	a5,0(sp)
ffffffffc02054ee:	8a66                	mv	s4,s9
ffffffffc02054f0:	40800633          	neg	a2,s0
ffffffffc02054f4:	46a9                	li	a3,10
ffffffffc02054f6:	b53d                	j	ffffffffc0205324 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02054f8:	03b05163          	blez	s11,ffffffffc020551a <vprintfmt+0x34c>
ffffffffc02054fc:	02d00693          	li	a3,45
ffffffffc0205500:	f6d79de3          	bne	a5,a3,ffffffffc020547a <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0205504:	00002417          	auipc	s0,0x2
ffffffffc0205508:	f9440413          	addi	s0,s0,-108 # ffffffffc0207498 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020550c:	02800793          	li	a5,40
ffffffffc0205510:	02800513          	li	a0,40
ffffffffc0205514:	00140a13          	addi	s4,s0,1
ffffffffc0205518:	bd6d                	j	ffffffffc02053d2 <vprintfmt+0x204>
ffffffffc020551a:	00002a17          	auipc	s4,0x2
ffffffffc020551e:	f7fa0a13          	addi	s4,s4,-129 # ffffffffc0207499 <syscalls+0x119>
ffffffffc0205522:	02800513          	li	a0,40
ffffffffc0205526:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020552a:	05e00413          	li	s0,94
ffffffffc020552e:	b565                	j	ffffffffc02053d6 <vprintfmt+0x208>

ffffffffc0205530 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205530:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0205532:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205536:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205538:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020553a:	ec06                	sd	ra,24(sp)
ffffffffc020553c:	f83a                	sd	a4,48(sp)
ffffffffc020553e:	fc3e                	sd	a5,56(sp)
ffffffffc0205540:	e0c2                	sd	a6,64(sp)
ffffffffc0205542:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0205544:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205546:	c89ff0ef          	jal	ra,ffffffffc02051ce <vprintfmt>
}
ffffffffc020554a:	60e2                	ld	ra,24(sp)
ffffffffc020554c:	6161                	addi	sp,sp,80
ffffffffc020554e:	8082                	ret

ffffffffc0205550 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0205550:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0205554:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0205556:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0205558:	cb81                	beqz	a5,ffffffffc0205568 <strlen+0x18>
        cnt ++;
ffffffffc020555a:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc020555c:	00a707b3          	add	a5,a4,a0
ffffffffc0205560:	0007c783          	lbu	a5,0(a5)
ffffffffc0205564:	fbfd                	bnez	a5,ffffffffc020555a <strlen+0xa>
ffffffffc0205566:	8082                	ret
    }
    return cnt;
}
ffffffffc0205568:	8082                	ret

ffffffffc020556a <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020556a:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020556c:	e589                	bnez	a1,ffffffffc0205576 <strnlen+0xc>
ffffffffc020556e:	a811                	j	ffffffffc0205582 <strnlen+0x18>
        cnt ++;
ffffffffc0205570:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205572:	00f58863          	beq	a1,a5,ffffffffc0205582 <strnlen+0x18>
ffffffffc0205576:	00f50733          	add	a4,a0,a5
ffffffffc020557a:	00074703          	lbu	a4,0(a4)
ffffffffc020557e:	fb6d                	bnez	a4,ffffffffc0205570 <strnlen+0x6>
ffffffffc0205580:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0205582:	852e                	mv	a0,a1
ffffffffc0205584:	8082                	ret

ffffffffc0205586 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0205586:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0205588:	0005c703          	lbu	a4,0(a1)
ffffffffc020558c:	0785                	addi	a5,a5,1
ffffffffc020558e:	0585                	addi	a1,a1,1
ffffffffc0205590:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0205594:	fb75                	bnez	a4,ffffffffc0205588 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0205596:	8082                	ret

ffffffffc0205598 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205598:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020559c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02055a0:	cb89                	beqz	a5,ffffffffc02055b2 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02055a2:	0505                	addi	a0,a0,1
ffffffffc02055a4:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02055a6:	fee789e3          	beq	a5,a4,ffffffffc0205598 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02055aa:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02055ae:	9d19                	subw	a0,a0,a4
ffffffffc02055b0:	8082                	ret
ffffffffc02055b2:	4501                	li	a0,0
ffffffffc02055b4:	bfed                	j	ffffffffc02055ae <strcmp+0x16>

ffffffffc02055b6 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02055b6:	c20d                	beqz	a2,ffffffffc02055d8 <strncmp+0x22>
ffffffffc02055b8:	962e                	add	a2,a2,a1
ffffffffc02055ba:	a031                	j	ffffffffc02055c6 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc02055bc:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02055be:	00e79a63          	bne	a5,a4,ffffffffc02055d2 <strncmp+0x1c>
ffffffffc02055c2:	00b60b63          	beq	a2,a1,ffffffffc02055d8 <strncmp+0x22>
ffffffffc02055c6:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc02055ca:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02055cc:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02055d0:	f7f5                	bnez	a5,ffffffffc02055bc <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02055d2:	40e7853b          	subw	a0,a5,a4
}
ffffffffc02055d6:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02055d8:	4501                	li	a0,0
ffffffffc02055da:	8082                	ret

ffffffffc02055dc <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02055dc:	00054783          	lbu	a5,0(a0)
ffffffffc02055e0:	c799                	beqz	a5,ffffffffc02055ee <strchr+0x12>
        if (*s == c) {
ffffffffc02055e2:	00f58763          	beq	a1,a5,ffffffffc02055f0 <strchr+0x14>
    while (*s != '\0') {
ffffffffc02055e6:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02055ea:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02055ec:	fbfd                	bnez	a5,ffffffffc02055e2 <strchr+0x6>
    }
    return NULL;
ffffffffc02055ee:	4501                	li	a0,0
}
ffffffffc02055f0:	8082                	ret

ffffffffc02055f2 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02055f2:	ca01                	beqz	a2,ffffffffc0205602 <memset+0x10>
ffffffffc02055f4:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02055f6:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02055f8:	0785                	addi	a5,a5,1
ffffffffc02055fa:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02055fe:	fec79de3          	bne	a5,a2,ffffffffc02055f8 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0205602:	8082                	ret

ffffffffc0205604 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0205604:	ca19                	beqz	a2,ffffffffc020561a <memcpy+0x16>
ffffffffc0205606:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0205608:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020560a:	0005c703          	lbu	a4,0(a1)
ffffffffc020560e:	0585                	addi	a1,a1,1
ffffffffc0205610:	0785                	addi	a5,a5,1
ffffffffc0205612:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0205616:	fec59ae3          	bne	a1,a2,ffffffffc020560a <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020561a:	8082                	ret
