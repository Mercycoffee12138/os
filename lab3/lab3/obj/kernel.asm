
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	00007297          	auipc	t0,0x7
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0207000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	00007297          	auipc	t0,0x7
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0207008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)

    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02062b7          	lui	t0,0xc0206
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
ffffffffc020003c:	c0206137          	lui	sp,0xc0206

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 1. 使用临时寄存器 t1 计算栈顶的精确地址
    lui t1, %hi(bootstacktop)
ffffffffc0200040:	c0206337          	lui	t1,0xc0206
    addi t1, t1, %lo(bootstacktop)
ffffffffc0200044:	00030313          	mv	t1,t1
    # 2. 将精确地址一次性地、安全地传给 sp
    mv sp, t1
ffffffffc0200048:	811a                	mv	sp,t1
    # 现在栈指针已经完美设置，可以安全地调用任何C函数了
    # 然后跳转到 kern_init (不再返回)
    lui t0, %hi(kern_init)
ffffffffc020004a:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020004e:	05428293          	addi	t0,t0,84 # ffffffffc0200054 <kern_init>
    jr t0
ffffffffc0200052:	8282                	jr	t0

ffffffffc0200054 <kern_init>:
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    // 先清零 BSS，再读取并保存 DTB 的内存信息，避免被清零覆盖（为了解释变化 正式上传时我觉得应该删去这句话）
    memset(edata, 0, end - edata);
ffffffffc0200054:	00007517          	auipc	a0,0x7
ffffffffc0200058:	fd450513          	addi	a0,a0,-44 # ffffffffc0207028 <free_area>
ffffffffc020005c:	00007617          	auipc	a2,0x7
ffffffffc0200060:	44460613          	addi	a2,a2,1092 # ffffffffc02074a0 <end>
int kern_init(void) {
ffffffffc0200064:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200066:	8e09                	sub	a2,a2,a0
ffffffffc0200068:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020006a:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020006c:	6bf010ef          	jal	ra,ffffffffc0201f2a <memset>
    dtb_init();
ffffffffc0200070:	45c000ef          	jal	ra,ffffffffc02004cc <dtb_init>
    cons_init();  // init the console
ffffffffc0200074:	44a000ef          	jal	ra,ffffffffc02004be <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200078:	00002517          	auipc	a0,0x2
ffffffffc020007c:	fd850513          	addi	a0,a0,-40 # ffffffffc0202050 <etext+0x114>
ffffffffc0200080:	0de000ef          	jal	ra,ffffffffc020015e <cputs>

    print_kerninfo();
ffffffffc0200084:	12a000ef          	jal	ra,ffffffffc02001ae <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200088:	001000ef          	jal	ra,ffffffffc0200888 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020008c:	722010ef          	jal	ra,ffffffffc02017ae <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc0200090:	7f8000ef          	jal	ra,ffffffffc0200888 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200094:	3e8000ef          	jal	ra,ffffffffc020047c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200098:	7e4000ef          	jal	ra,ffffffffc020087c <intr_enable>

    // LAB3 CHALLENGE3: 测试异常处理
    cprintf("\n========== Testing Exception Handling ==========\n");
ffffffffc020009c:	00002517          	auipc	a0,0x2
ffffffffc02000a0:	ea450513          	addi	a0,a0,-348 # ffffffffc0201f40 <etext+0x4>
ffffffffc02000a4:	082000ef          	jal	ra,ffffffffc0200126 <cprintf>
    
    // 测试断点异常 (ebreak)
    cprintf("\n--- Test 1: Breakpoint Exception ---\n");
ffffffffc02000a8:	00002517          	auipc	a0,0x2
ffffffffc02000ac:	ed050513          	addi	a0,a0,-304 # ffffffffc0201f78 <etext+0x3c>
ffffffffc02000b0:	076000ef          	jal	ra,ffffffffc0200126 <cprintf>
    asm volatile("ebreak");
ffffffffc02000b4:	9002                	ebreak
    cprintf("After breakpoint exception\n");
ffffffffc02000b6:	00002517          	auipc	a0,0x2
ffffffffc02000ba:	eea50513          	addi	a0,a0,-278 # ffffffffc0201fa0 <etext+0x64>
ffffffffc02000be:	068000ef          	jal	ra,ffffffffc0200126 <cprintf>
    
    // 测试非法指令异常 (mret 在 S 模式下是非法的)
    cprintf("\n--- Test 2: Illegal Instruction Exception ---\n");
ffffffffc02000c2:	00002517          	auipc	a0,0x2
ffffffffc02000c6:	efe50513          	addi	a0,a0,-258 # ffffffffc0201fc0 <etext+0x84>
ffffffffc02000ca:	05c000ef          	jal	ra,ffffffffc0200126 <cprintf>
ffffffffc02000ce:	30200073          	mret
    asm volatile(".word 0x30200073");  // mret 指令的机器码
    cprintf("After illegal instruction exception\n");
ffffffffc02000d2:	00002517          	auipc	a0,0x2
ffffffffc02000d6:	f1e50513          	addi	a0,a0,-226 # ffffffffc0201ff0 <etext+0xb4>
ffffffffc02000da:	04c000ef          	jal	ra,ffffffffc0200126 <cprintf>
    
    cprintf("\n========== Exception Tests Completed ==========\n\n");
ffffffffc02000de:	00002517          	auipc	a0,0x2
ffffffffc02000e2:	f3a50513          	addi	a0,a0,-198 # ffffffffc0202018 <etext+0xdc>
ffffffffc02000e6:	040000ef          	jal	ra,ffffffffc0200126 <cprintf>

    /* do nothing */
    while (1)
ffffffffc02000ea:	a001                	j	ffffffffc02000ea <kern_init+0x96>

ffffffffc02000ec <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc02000ec:	1141                	addi	sp,sp,-16
ffffffffc02000ee:	e022                	sd	s0,0(sp)
ffffffffc02000f0:	e406                	sd	ra,8(sp)
ffffffffc02000f2:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc02000f4:	3cc000ef          	jal	ra,ffffffffc02004c0 <cons_putc>
    (*cnt) ++;
ffffffffc02000f8:	401c                	lw	a5,0(s0)
}
ffffffffc02000fa:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000fc:	2785                	addiw	a5,a5,1
ffffffffc02000fe:	c01c                	sw	a5,0(s0)
}
ffffffffc0200100:	6402                	ld	s0,0(sp)
ffffffffc0200102:	0141                	addi	sp,sp,16
ffffffffc0200104:	8082                	ret

ffffffffc0200106 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200106:	1101                	addi	sp,sp,-32
ffffffffc0200108:	862a                	mv	a2,a0
ffffffffc020010a:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020010c:	00000517          	auipc	a0,0x0
ffffffffc0200110:	fe050513          	addi	a0,a0,-32 # ffffffffc02000ec <cputch>
ffffffffc0200114:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200116:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200118:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020011a:	0e1010ef          	jal	ra,ffffffffc02019fa <vprintfmt>
    return cnt;
}
ffffffffc020011e:	60e2                	ld	ra,24(sp)
ffffffffc0200120:	4532                	lw	a0,12(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret

ffffffffc0200126 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200126:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200128:	02810313          	addi	t1,sp,40 # ffffffffc0206028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc020012c:	8e2a                	mv	t3,a0
ffffffffc020012e:	f42e                	sd	a1,40(sp)
ffffffffc0200130:	f832                	sd	a2,48(sp)
ffffffffc0200132:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200134:	00000517          	auipc	a0,0x0
ffffffffc0200138:	fb850513          	addi	a0,a0,-72 # ffffffffc02000ec <cputch>
ffffffffc020013c:	004c                	addi	a1,sp,4
ffffffffc020013e:	869a                	mv	a3,t1
ffffffffc0200140:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc0200142:	ec06                	sd	ra,24(sp)
ffffffffc0200144:	e0ba                	sd	a4,64(sp)
ffffffffc0200146:	e4be                	sd	a5,72(sp)
ffffffffc0200148:	e8c2                	sd	a6,80(sp)
ffffffffc020014a:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc020014c:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc020014e:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200150:	0ab010ef          	jal	ra,ffffffffc02019fa <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc0200154:	60e2                	ld	ra,24(sp)
ffffffffc0200156:	4512                	lw	a0,4(sp)
ffffffffc0200158:	6125                	addi	sp,sp,96
ffffffffc020015a:	8082                	ret

ffffffffc020015c <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc020015c:	a695                	j	ffffffffc02004c0 <cons_putc>

ffffffffc020015e <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc020015e:	1101                	addi	sp,sp,-32
ffffffffc0200160:	e822                	sd	s0,16(sp)
ffffffffc0200162:	ec06                	sd	ra,24(sp)
ffffffffc0200164:	e426                	sd	s1,8(sp)
ffffffffc0200166:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc0200168:	00054503          	lbu	a0,0(a0)
ffffffffc020016c:	c51d                	beqz	a0,ffffffffc020019a <cputs+0x3c>
ffffffffc020016e:	0405                	addi	s0,s0,1
ffffffffc0200170:	4485                	li	s1,1
ffffffffc0200172:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200174:	34c000ef          	jal	ra,ffffffffc02004c0 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200178:	00044503          	lbu	a0,0(s0)
ffffffffc020017c:	008487bb          	addw	a5,s1,s0
ffffffffc0200180:	0405                	addi	s0,s0,1
ffffffffc0200182:	f96d                	bnez	a0,ffffffffc0200174 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200184:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200188:	4529                	li	a0,10
ffffffffc020018a:	336000ef          	jal	ra,ffffffffc02004c0 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020018e:	60e2                	ld	ra,24(sp)
ffffffffc0200190:	8522                	mv	a0,s0
ffffffffc0200192:	6442                	ld	s0,16(sp)
ffffffffc0200194:	64a2                	ld	s1,8(sp)
ffffffffc0200196:	6105                	addi	sp,sp,32
ffffffffc0200198:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020019a:	4405                	li	s0,1
ffffffffc020019c:	b7f5                	j	ffffffffc0200188 <cputs+0x2a>

ffffffffc020019e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020019e:	1141                	addi	sp,sp,-16
ffffffffc02001a0:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001a2:	326000ef          	jal	ra,ffffffffc02004c8 <cons_getc>
ffffffffc02001a6:	dd75                	beqz	a0,ffffffffc02001a2 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02001a8:	60a2                	ld	ra,8(sp)
ffffffffc02001aa:	0141                	addi	sp,sp,16
ffffffffc02001ac:	8082                	ret

ffffffffc02001ae <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02001ae:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001b0:	00002517          	auipc	a0,0x2
ffffffffc02001b4:	ec050513          	addi	a0,a0,-320 # ffffffffc0202070 <etext+0x134>
void print_kerninfo(void) {
ffffffffc02001b8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001ba:	f6dff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001be:	00000597          	auipc	a1,0x0
ffffffffc02001c2:	e9658593          	addi	a1,a1,-362 # ffffffffc0200054 <kern_init>
ffffffffc02001c6:	00002517          	auipc	a0,0x2
ffffffffc02001ca:	eca50513          	addi	a0,a0,-310 # ffffffffc0202090 <etext+0x154>
ffffffffc02001ce:	f59ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001d2:	00002597          	auipc	a1,0x2
ffffffffc02001d6:	d6a58593          	addi	a1,a1,-662 # ffffffffc0201f3c <etext>
ffffffffc02001da:	00002517          	auipc	a0,0x2
ffffffffc02001de:	ed650513          	addi	a0,a0,-298 # ffffffffc02020b0 <etext+0x174>
ffffffffc02001e2:	f45ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001e6:	00007597          	auipc	a1,0x7
ffffffffc02001ea:	e4258593          	addi	a1,a1,-446 # ffffffffc0207028 <free_area>
ffffffffc02001ee:	00002517          	auipc	a0,0x2
ffffffffc02001f2:	ee250513          	addi	a0,a0,-286 # ffffffffc02020d0 <etext+0x194>
ffffffffc02001f6:	f31ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001fa:	00007597          	auipc	a1,0x7
ffffffffc02001fe:	2a658593          	addi	a1,a1,678 # ffffffffc02074a0 <end>
ffffffffc0200202:	00002517          	auipc	a0,0x2
ffffffffc0200206:	eee50513          	addi	a0,a0,-274 # ffffffffc02020f0 <etext+0x1b4>
ffffffffc020020a:	f1dff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020020e:	00007597          	auipc	a1,0x7
ffffffffc0200212:	69158593          	addi	a1,a1,1681 # ffffffffc020789f <end+0x3ff>
ffffffffc0200216:	00000797          	auipc	a5,0x0
ffffffffc020021a:	e3e78793          	addi	a5,a5,-450 # ffffffffc0200054 <kern_init>
ffffffffc020021e:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200222:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200226:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200228:	3ff5f593          	andi	a1,a1,1023
ffffffffc020022c:	95be                	add	a1,a1,a5
ffffffffc020022e:	85a9                	srai	a1,a1,0xa
ffffffffc0200230:	00002517          	auipc	a0,0x2
ffffffffc0200234:	ee050513          	addi	a0,a0,-288 # ffffffffc0202110 <etext+0x1d4>
}
ffffffffc0200238:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020023a:	b5f5                	j	ffffffffc0200126 <cprintf>

ffffffffc020023c <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc020023c:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc020023e:	00002617          	auipc	a2,0x2
ffffffffc0200242:	f0260613          	addi	a2,a2,-254 # ffffffffc0202140 <etext+0x204>
ffffffffc0200246:	04d00593          	li	a1,77
ffffffffc020024a:	00002517          	auipc	a0,0x2
ffffffffc020024e:	f0e50513          	addi	a0,a0,-242 # ffffffffc0202158 <etext+0x21c>
void print_stackframe(void) {
ffffffffc0200252:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200254:	1cc000ef          	jal	ra,ffffffffc0200420 <__panic>

ffffffffc0200258 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200258:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020025a:	00002617          	auipc	a2,0x2
ffffffffc020025e:	f1660613          	addi	a2,a2,-234 # ffffffffc0202170 <etext+0x234>
ffffffffc0200262:	00002597          	auipc	a1,0x2
ffffffffc0200266:	f2e58593          	addi	a1,a1,-210 # ffffffffc0202190 <etext+0x254>
ffffffffc020026a:	00002517          	auipc	a0,0x2
ffffffffc020026e:	f2e50513          	addi	a0,a0,-210 # ffffffffc0202198 <etext+0x25c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200272:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200274:	eb3ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
ffffffffc0200278:	00002617          	auipc	a2,0x2
ffffffffc020027c:	f3060613          	addi	a2,a2,-208 # ffffffffc02021a8 <etext+0x26c>
ffffffffc0200280:	00002597          	auipc	a1,0x2
ffffffffc0200284:	f5058593          	addi	a1,a1,-176 # ffffffffc02021d0 <etext+0x294>
ffffffffc0200288:	00002517          	auipc	a0,0x2
ffffffffc020028c:	f1050513          	addi	a0,a0,-240 # ffffffffc0202198 <etext+0x25c>
ffffffffc0200290:	e97ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
ffffffffc0200294:	00002617          	auipc	a2,0x2
ffffffffc0200298:	f4c60613          	addi	a2,a2,-180 # ffffffffc02021e0 <etext+0x2a4>
ffffffffc020029c:	00002597          	auipc	a1,0x2
ffffffffc02002a0:	f6458593          	addi	a1,a1,-156 # ffffffffc0202200 <etext+0x2c4>
ffffffffc02002a4:	00002517          	auipc	a0,0x2
ffffffffc02002a8:	ef450513          	addi	a0,a0,-268 # ffffffffc0202198 <etext+0x25c>
ffffffffc02002ac:	e7bff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    }
    return 0;
}
ffffffffc02002b0:	60a2                	ld	ra,8(sp)
ffffffffc02002b2:	4501                	li	a0,0
ffffffffc02002b4:	0141                	addi	sp,sp,16
ffffffffc02002b6:	8082                	ret

ffffffffc02002b8 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002b8:	1141                	addi	sp,sp,-16
ffffffffc02002ba:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002bc:	ef3ff0ef          	jal	ra,ffffffffc02001ae <print_kerninfo>
    return 0;
}
ffffffffc02002c0:	60a2                	ld	ra,8(sp)
ffffffffc02002c2:	4501                	li	a0,0
ffffffffc02002c4:	0141                	addi	sp,sp,16
ffffffffc02002c6:	8082                	ret

ffffffffc02002c8 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002c8:	1141                	addi	sp,sp,-16
ffffffffc02002ca:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002cc:	f71ff0ef          	jal	ra,ffffffffc020023c <print_stackframe>
    return 0;
}
ffffffffc02002d0:	60a2                	ld	ra,8(sp)
ffffffffc02002d2:	4501                	li	a0,0
ffffffffc02002d4:	0141                	addi	sp,sp,16
ffffffffc02002d6:	8082                	ret

ffffffffc02002d8 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002d8:	7115                	addi	sp,sp,-224
ffffffffc02002da:	ed5e                	sd	s7,152(sp)
ffffffffc02002dc:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002de:	00002517          	auipc	a0,0x2
ffffffffc02002e2:	f3250513          	addi	a0,a0,-206 # ffffffffc0202210 <etext+0x2d4>
kmonitor(struct trapframe *tf) {
ffffffffc02002e6:	ed86                	sd	ra,216(sp)
ffffffffc02002e8:	e9a2                	sd	s0,208(sp)
ffffffffc02002ea:	e5a6                	sd	s1,200(sp)
ffffffffc02002ec:	e1ca                	sd	s2,192(sp)
ffffffffc02002ee:	fd4e                	sd	s3,184(sp)
ffffffffc02002f0:	f952                	sd	s4,176(sp)
ffffffffc02002f2:	f556                	sd	s5,168(sp)
ffffffffc02002f4:	f15a                	sd	s6,160(sp)
ffffffffc02002f6:	e962                	sd	s8,144(sp)
ffffffffc02002f8:	e566                	sd	s9,136(sp)
ffffffffc02002fa:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002fc:	e2bff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200300:	00002517          	auipc	a0,0x2
ffffffffc0200304:	f3850513          	addi	a0,a0,-200 # ffffffffc0202238 <etext+0x2fc>
ffffffffc0200308:	e1fff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    if (tf != NULL) {
ffffffffc020030c:	000b8563          	beqz	s7,ffffffffc0200316 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200310:	855e                	mv	a0,s7
ffffffffc0200312:	756000ef          	jal	ra,ffffffffc0200a68 <print_trapframe>
ffffffffc0200316:	00002c17          	auipc	s8,0x2
ffffffffc020031a:	f92c0c13          	addi	s8,s8,-110 # ffffffffc02022a8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020031e:	00002917          	auipc	s2,0x2
ffffffffc0200322:	f4290913          	addi	s2,s2,-190 # ffffffffc0202260 <etext+0x324>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200326:	00002497          	auipc	s1,0x2
ffffffffc020032a:	f4248493          	addi	s1,s1,-190 # ffffffffc0202268 <etext+0x32c>
        if (argc == MAXARGS - 1) {
ffffffffc020032e:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200330:	00002b17          	auipc	s6,0x2
ffffffffc0200334:	f40b0b13          	addi	s6,s6,-192 # ffffffffc0202270 <etext+0x334>
        argv[argc ++] = buf;
ffffffffc0200338:	00002a17          	auipc	s4,0x2
ffffffffc020033c:	e58a0a13          	addi	s4,s4,-424 # ffffffffc0202190 <etext+0x254>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200340:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200342:	854a                	mv	a0,s2
ffffffffc0200344:	239010ef          	jal	ra,ffffffffc0201d7c <readline>
ffffffffc0200348:	842a                	mv	s0,a0
ffffffffc020034a:	dd65                	beqz	a0,ffffffffc0200342 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020034c:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200350:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200352:	e1bd                	bnez	a1,ffffffffc02003b8 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc0200354:	fe0c87e3          	beqz	s9,ffffffffc0200342 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200358:	6582                	ld	a1,0(sp)
ffffffffc020035a:	00002d17          	auipc	s10,0x2
ffffffffc020035e:	f4ed0d13          	addi	s10,s10,-178 # ffffffffc02022a8 <commands>
        argv[argc ++] = buf;
ffffffffc0200362:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200364:	4401                	li	s0,0
ffffffffc0200366:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200368:	369010ef          	jal	ra,ffffffffc0201ed0 <strcmp>
ffffffffc020036c:	c919                	beqz	a0,ffffffffc0200382 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020036e:	2405                	addiw	s0,s0,1
ffffffffc0200370:	0b540063          	beq	s0,s5,ffffffffc0200410 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200374:	000d3503          	ld	a0,0(s10)
ffffffffc0200378:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020037a:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020037c:	355010ef          	jal	ra,ffffffffc0201ed0 <strcmp>
ffffffffc0200380:	f57d                	bnez	a0,ffffffffc020036e <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200382:	00141793          	slli	a5,s0,0x1
ffffffffc0200386:	97a2                	add	a5,a5,s0
ffffffffc0200388:	078e                	slli	a5,a5,0x3
ffffffffc020038a:	97e2                	add	a5,a5,s8
ffffffffc020038c:	6b9c                	ld	a5,16(a5)
ffffffffc020038e:	865e                	mv	a2,s7
ffffffffc0200390:	002c                	addi	a1,sp,8
ffffffffc0200392:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200396:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200398:	fa0555e3          	bgez	a0,ffffffffc0200342 <kmonitor+0x6a>
}
ffffffffc020039c:	60ee                	ld	ra,216(sp)
ffffffffc020039e:	644e                	ld	s0,208(sp)
ffffffffc02003a0:	64ae                	ld	s1,200(sp)
ffffffffc02003a2:	690e                	ld	s2,192(sp)
ffffffffc02003a4:	79ea                	ld	s3,184(sp)
ffffffffc02003a6:	7a4a                	ld	s4,176(sp)
ffffffffc02003a8:	7aaa                	ld	s5,168(sp)
ffffffffc02003aa:	7b0a                	ld	s6,160(sp)
ffffffffc02003ac:	6bea                	ld	s7,152(sp)
ffffffffc02003ae:	6c4a                	ld	s8,144(sp)
ffffffffc02003b0:	6caa                	ld	s9,136(sp)
ffffffffc02003b2:	6d0a                	ld	s10,128(sp)
ffffffffc02003b4:	612d                	addi	sp,sp,224
ffffffffc02003b6:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003b8:	8526                	mv	a0,s1
ffffffffc02003ba:	35b010ef          	jal	ra,ffffffffc0201f14 <strchr>
ffffffffc02003be:	c901                	beqz	a0,ffffffffc02003ce <kmonitor+0xf6>
ffffffffc02003c0:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02003c4:	00040023          	sb	zero,0(s0)
ffffffffc02003c8:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ca:	d5c9                	beqz	a1,ffffffffc0200354 <kmonitor+0x7c>
ffffffffc02003cc:	b7f5                	j	ffffffffc02003b8 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc02003ce:	00044783          	lbu	a5,0(s0)
ffffffffc02003d2:	d3c9                	beqz	a5,ffffffffc0200354 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc02003d4:	033c8963          	beq	s9,s3,ffffffffc0200406 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc02003d8:	003c9793          	slli	a5,s9,0x3
ffffffffc02003dc:	0118                	addi	a4,sp,128
ffffffffc02003de:	97ba                	add	a5,a5,a4
ffffffffc02003e0:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003e4:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02003e8:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003ea:	e591                	bnez	a1,ffffffffc02003f6 <kmonitor+0x11e>
ffffffffc02003ec:	b7b5                	j	ffffffffc0200358 <kmonitor+0x80>
ffffffffc02003ee:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02003f2:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003f4:	d1a5                	beqz	a1,ffffffffc0200354 <kmonitor+0x7c>
ffffffffc02003f6:	8526                	mv	a0,s1
ffffffffc02003f8:	31d010ef          	jal	ra,ffffffffc0201f14 <strchr>
ffffffffc02003fc:	d96d                	beqz	a0,ffffffffc02003ee <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003fe:	00044583          	lbu	a1,0(s0)
ffffffffc0200402:	d9a9                	beqz	a1,ffffffffc0200354 <kmonitor+0x7c>
ffffffffc0200404:	bf55                	j	ffffffffc02003b8 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200406:	45c1                	li	a1,16
ffffffffc0200408:	855a                	mv	a0,s6
ffffffffc020040a:	d1dff0ef          	jal	ra,ffffffffc0200126 <cprintf>
ffffffffc020040e:	b7e9                	j	ffffffffc02003d8 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200410:	6582                	ld	a1,0(sp)
ffffffffc0200412:	00002517          	auipc	a0,0x2
ffffffffc0200416:	e7e50513          	addi	a0,a0,-386 # ffffffffc0202290 <etext+0x354>
ffffffffc020041a:	d0dff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    return 0;
ffffffffc020041e:	b715                	j	ffffffffc0200342 <kmonitor+0x6a>

ffffffffc0200420 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200420:	00007317          	auipc	t1,0x7
ffffffffc0200424:	02030313          	addi	t1,t1,32 # ffffffffc0207440 <is_panic>
ffffffffc0200428:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020042c:	715d                	addi	sp,sp,-80
ffffffffc020042e:	ec06                	sd	ra,24(sp)
ffffffffc0200430:	e822                	sd	s0,16(sp)
ffffffffc0200432:	f436                	sd	a3,40(sp)
ffffffffc0200434:	f83a                	sd	a4,48(sp)
ffffffffc0200436:	fc3e                	sd	a5,56(sp)
ffffffffc0200438:	e0c2                	sd	a6,64(sp)
ffffffffc020043a:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020043c:	020e1a63          	bnez	t3,ffffffffc0200470 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200440:	4785                	li	a5,1
ffffffffc0200442:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200446:	8432                	mv	s0,a2
ffffffffc0200448:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020044a:	862e                	mv	a2,a1
ffffffffc020044c:	85aa                	mv	a1,a0
ffffffffc020044e:	00002517          	auipc	a0,0x2
ffffffffc0200452:	ea250513          	addi	a0,a0,-350 # ffffffffc02022f0 <commands+0x48>
    va_start(ap, fmt);
ffffffffc0200456:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200458:	ccfff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020045c:	65a2                	ld	a1,8(sp)
ffffffffc020045e:	8522                	mv	a0,s0
ffffffffc0200460:	ca7ff0ef          	jal	ra,ffffffffc0200106 <vcprintf>
    cprintf("\n");
ffffffffc0200464:	00003517          	auipc	a0,0x3
ffffffffc0200468:	83c50513          	addi	a0,a0,-1988 # ffffffffc0202ca0 <commands+0x9f8>
ffffffffc020046c:	cbbff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200470:	412000ef          	jal	ra,ffffffffc0200882 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200474:	4501                	li	a0,0
ffffffffc0200476:	e63ff0ef          	jal	ra,ffffffffc02002d8 <kmonitor>
    while (1) {
ffffffffc020047a:	bfed                	j	ffffffffc0200474 <__panic+0x54>

ffffffffc020047c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020047c:	1141                	addi	sp,sp,-16
ffffffffc020047e:	e406                	sd	ra,8(sp)
    // sie这个CSR可以单独使能/禁用某个来源的中断。默认时钟中断是关闭的
    // 所以我们要在初始化的时候，使能时钟中断
    set_csr(sie, MIP_STIP); // enable timer interrupt in sie
ffffffffc0200480:	02000793          	li	a5,32
ffffffffc0200484:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200488:	c0102573          	rdtime	a0

    cprintf("++ setup timer interrupts\n");
}
//设置时钟中断：timer的数值变为当前时间 + timebase 后，触发一次时钟中断
//对于QEMU, timer增加1，过去了10^-7 s， 也就是100ns
void clock_set_next_event(void) { sbi_set_timer(get_time() + timebase); }
ffffffffc020048c:	67e1                	lui	a5,0x18
ffffffffc020048e:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200492:	953e                	add	a0,a0,a5
ffffffffc0200494:	1b7010ef          	jal	ra,ffffffffc0201e4a <sbi_set_timer>
}
ffffffffc0200498:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020049a:	00007797          	auipc	a5,0x7
ffffffffc020049e:	fa07b723          	sd	zero,-82(a5) # ffffffffc0207448 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	e6e50513          	addi	a0,a0,-402 # ffffffffc0202310 <commands+0x68>
}
ffffffffc02004aa:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc02004ac:	b9ad                	j	ffffffffc0200126 <cprintf>

ffffffffc02004ae <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004ae:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_time() + timebase); }
ffffffffc02004b2:	67e1                	lui	a5,0x18
ffffffffc02004b4:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02004b8:	953e                	add	a0,a0,a5
ffffffffc02004ba:	1910106f          	j	ffffffffc0201e4a <sbi_set_timer>

ffffffffc02004be <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02004be:	8082                	ret

ffffffffc02004c0 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc02004c0:	0ff57513          	zext.b	a0,a0
ffffffffc02004c4:	16d0106f          	j	ffffffffc0201e30 <sbi_console_putchar>

ffffffffc02004c8 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc02004c8:	19d0106f          	j	ffffffffc0201e64 <sbi_console_getchar>

ffffffffc02004cc <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc02004cc:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc02004ce:	00002517          	auipc	a0,0x2
ffffffffc02004d2:	e6250513          	addi	a0,a0,-414 # ffffffffc0202330 <commands+0x88>
void dtb_init(void) {
ffffffffc02004d6:	fc86                	sd	ra,120(sp)
ffffffffc02004d8:	f8a2                	sd	s0,112(sp)
ffffffffc02004da:	e8d2                	sd	s4,80(sp)
ffffffffc02004dc:	f4a6                	sd	s1,104(sp)
ffffffffc02004de:	f0ca                	sd	s2,96(sp)
ffffffffc02004e0:	ecce                	sd	s3,88(sp)
ffffffffc02004e2:	e4d6                	sd	s5,72(sp)
ffffffffc02004e4:	e0da                	sd	s6,64(sp)
ffffffffc02004e6:	fc5e                	sd	s7,56(sp)
ffffffffc02004e8:	f862                	sd	s8,48(sp)
ffffffffc02004ea:	f466                	sd	s9,40(sp)
ffffffffc02004ec:	f06a                	sd	s10,32(sp)
ffffffffc02004ee:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc02004f0:	c37ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc02004f4:	00007597          	auipc	a1,0x7
ffffffffc02004f8:	b0c5b583          	ld	a1,-1268(a1) # ffffffffc0207000 <boot_hartid>
ffffffffc02004fc:	00002517          	auipc	a0,0x2
ffffffffc0200500:	e4450513          	addi	a0,a0,-444 # ffffffffc0202340 <commands+0x98>
ffffffffc0200504:	c23ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200508:	00007417          	auipc	s0,0x7
ffffffffc020050c:	b0040413          	addi	s0,s0,-1280 # ffffffffc0207008 <boot_dtb>
ffffffffc0200510:	600c                	ld	a1,0(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	e3e50513          	addi	a0,a0,-450 # ffffffffc0202350 <commands+0xa8>
ffffffffc020051a:	c0dff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc020051e:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200522:	00002517          	auipc	a0,0x2
ffffffffc0200526:	e4650513          	addi	a0,a0,-442 # ffffffffc0202368 <commands+0xc0>
    if (boot_dtb == 0) {
ffffffffc020052a:	120a0463          	beqz	s4,ffffffffc0200652 <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc020052e:	57f5                	li	a5,-3
ffffffffc0200530:	07fa                	slli	a5,a5,0x1e
ffffffffc0200532:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc0200536:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200538:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020053c:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020053e:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200542:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200546:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020054a:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020054e:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200552:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200554:	8ec9                	or	a3,a3,a0
ffffffffc0200556:	0087979b          	slliw	a5,a5,0x8
ffffffffc020055a:	1b7d                	addi	s6,s6,-1
ffffffffc020055c:	0167f7b3          	and	a5,a5,s6
ffffffffc0200560:	8dd5                	or	a1,a1,a3
ffffffffc0200562:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc0200564:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200568:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc020056a:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfed8a4d>
ffffffffc020056e:	10f59163          	bne	a1,a5,ffffffffc0200670 <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc0200572:	471c                	lw	a5,8(a4)
ffffffffc0200574:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc0200576:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200578:	0087d59b          	srliw	a1,a5,0x8
ffffffffc020057c:	0086d51b          	srliw	a0,a3,0x8
ffffffffc0200580:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200584:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200588:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020058c:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200590:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200594:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200598:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020059c:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005a0:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005a2:	01146433          	or	s0,s0,a7
ffffffffc02005a6:	0086969b          	slliw	a3,a3,0x8
ffffffffc02005aa:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005ae:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005b0:	0087979b          	slliw	a5,a5,0x8
ffffffffc02005b4:	8c49                	or	s0,s0,a0
ffffffffc02005b6:	0166f6b3          	and	a3,a3,s6
ffffffffc02005ba:	00ca6a33          	or	s4,s4,a2
ffffffffc02005be:	0167f7b3          	and	a5,a5,s6
ffffffffc02005c2:	8c55                	or	s0,s0,a3
ffffffffc02005c4:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02005c8:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02005ca:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02005cc:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02005ce:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02005d2:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02005d4:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005d6:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc02005da:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02005dc:	00002917          	auipc	s2,0x2
ffffffffc02005e0:	ddc90913          	addi	s2,s2,-548 # ffffffffc02023b8 <commands+0x110>
ffffffffc02005e4:	49bd                	li	s3,15
        switch (token) {
ffffffffc02005e6:	4d91                	li	s11,4
ffffffffc02005e8:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02005ea:	00002497          	auipc	s1,0x2
ffffffffc02005ee:	dc648493          	addi	s1,s1,-570 # ffffffffc02023b0 <commands+0x108>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc02005f2:	000a2703          	lw	a4,0(s4)
ffffffffc02005f6:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005fa:	0087569b          	srliw	a3,a4,0x8
ffffffffc02005fe:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200602:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200606:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020060a:	0107571b          	srliw	a4,a4,0x10
ffffffffc020060e:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200610:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200614:	0087171b          	slliw	a4,a4,0x8
ffffffffc0200618:	8fd5                	or	a5,a5,a3
ffffffffc020061a:	00eb7733          	and	a4,s6,a4
ffffffffc020061e:	8fd9                	or	a5,a5,a4
ffffffffc0200620:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc0200622:	09778c63          	beq	a5,s7,ffffffffc02006ba <dtb_init+0x1ee>
ffffffffc0200626:	00fbea63          	bltu	s7,a5,ffffffffc020063a <dtb_init+0x16e>
ffffffffc020062a:	07a78663          	beq	a5,s10,ffffffffc0200696 <dtb_init+0x1ca>
ffffffffc020062e:	4709                	li	a4,2
ffffffffc0200630:	00e79763          	bne	a5,a4,ffffffffc020063e <dtb_init+0x172>
ffffffffc0200634:	4c81                	li	s9,0
ffffffffc0200636:	8a56                	mv	s4,s5
ffffffffc0200638:	bf6d                	j	ffffffffc02005f2 <dtb_init+0x126>
ffffffffc020063a:	ffb78ee3          	beq	a5,s11,ffffffffc0200636 <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc020063e:	00002517          	auipc	a0,0x2
ffffffffc0200642:	df250513          	addi	a0,a0,-526 # ffffffffc0202430 <commands+0x188>
ffffffffc0200646:	ae1ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc020064a:	00002517          	auipc	a0,0x2
ffffffffc020064e:	e1e50513          	addi	a0,a0,-482 # ffffffffc0202468 <commands+0x1c0>
}
ffffffffc0200652:	7446                	ld	s0,112(sp)
ffffffffc0200654:	70e6                	ld	ra,120(sp)
ffffffffc0200656:	74a6                	ld	s1,104(sp)
ffffffffc0200658:	7906                	ld	s2,96(sp)
ffffffffc020065a:	69e6                	ld	s3,88(sp)
ffffffffc020065c:	6a46                	ld	s4,80(sp)
ffffffffc020065e:	6aa6                	ld	s5,72(sp)
ffffffffc0200660:	6b06                	ld	s6,64(sp)
ffffffffc0200662:	7be2                	ld	s7,56(sp)
ffffffffc0200664:	7c42                	ld	s8,48(sp)
ffffffffc0200666:	7ca2                	ld	s9,40(sp)
ffffffffc0200668:	7d02                	ld	s10,32(sp)
ffffffffc020066a:	6de2                	ld	s11,24(sp)
ffffffffc020066c:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc020066e:	bc65                	j	ffffffffc0200126 <cprintf>
}
ffffffffc0200670:	7446                	ld	s0,112(sp)
ffffffffc0200672:	70e6                	ld	ra,120(sp)
ffffffffc0200674:	74a6                	ld	s1,104(sp)
ffffffffc0200676:	7906                	ld	s2,96(sp)
ffffffffc0200678:	69e6                	ld	s3,88(sp)
ffffffffc020067a:	6a46                	ld	s4,80(sp)
ffffffffc020067c:	6aa6                	ld	s5,72(sp)
ffffffffc020067e:	6b06                	ld	s6,64(sp)
ffffffffc0200680:	7be2                	ld	s7,56(sp)
ffffffffc0200682:	7c42                	ld	s8,48(sp)
ffffffffc0200684:	7ca2                	ld	s9,40(sp)
ffffffffc0200686:	7d02                	ld	s10,32(sp)
ffffffffc0200688:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	cfe50513          	addi	a0,a0,-770 # ffffffffc0202388 <commands+0xe0>
}
ffffffffc0200692:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200694:	bc49                	j	ffffffffc0200126 <cprintf>
                int name_len = strlen(name);
ffffffffc0200696:	8556                	mv	a0,s5
ffffffffc0200698:	003010ef          	jal	ra,ffffffffc0201e9a <strlen>
ffffffffc020069c:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020069e:	4619                	li	a2,6
ffffffffc02006a0:	85a6                	mv	a1,s1
ffffffffc02006a2:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02006a4:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02006a6:	049010ef          	jal	ra,ffffffffc0201eee <strncmp>
ffffffffc02006aa:	e111                	bnez	a0,ffffffffc02006ae <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc02006ac:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02006ae:	0a91                	addi	s5,s5,4
ffffffffc02006b0:	9ad2                	add	s5,s5,s4
ffffffffc02006b2:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc02006b6:	8a56                	mv	s4,s5
ffffffffc02006b8:	bf2d                	j	ffffffffc02005f2 <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc02006ba:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc02006be:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006c2:	0087d71b          	srliw	a4,a5,0x8
ffffffffc02006c6:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006ca:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006ce:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006d2:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02006d6:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006da:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006de:	0087979b          	slliw	a5,a5,0x8
ffffffffc02006e2:	00eaeab3          	or	s5,s5,a4
ffffffffc02006e6:	00fb77b3          	and	a5,s6,a5
ffffffffc02006ea:	00faeab3          	or	s5,s5,a5
ffffffffc02006ee:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02006f0:	000c9c63          	bnez	s9,ffffffffc0200708 <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc02006f4:	1a82                	slli	s5,s5,0x20
ffffffffc02006f6:	00368793          	addi	a5,a3,3
ffffffffc02006fa:	020ada93          	srli	s5,s5,0x20
ffffffffc02006fe:	9abe                	add	s5,s5,a5
ffffffffc0200700:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc0200704:	8a56                	mv	s4,s5
ffffffffc0200706:	b5f5                	j	ffffffffc02005f2 <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200708:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020070c:	85ca                	mv	a1,s2
ffffffffc020070e:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200710:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200714:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200718:	0187971b          	slliw	a4,a5,0x18
ffffffffc020071c:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200720:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200724:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200726:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020072a:	0087979b          	slliw	a5,a5,0x8
ffffffffc020072e:	8d59                	or	a0,a0,a4
ffffffffc0200730:	00fb77b3          	and	a5,s6,a5
ffffffffc0200734:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc0200736:	1502                	slli	a0,a0,0x20
ffffffffc0200738:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020073a:	9522                	add	a0,a0,s0
ffffffffc020073c:	794010ef          	jal	ra,ffffffffc0201ed0 <strcmp>
ffffffffc0200740:	66a2                	ld	a3,8(sp)
ffffffffc0200742:	f94d                	bnez	a0,ffffffffc02006f4 <dtb_init+0x228>
ffffffffc0200744:	fb59f8e3          	bgeu	s3,s5,ffffffffc02006f4 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200748:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc020074c:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200750:	00002517          	auipc	a0,0x2
ffffffffc0200754:	c7050513          	addi	a0,a0,-912 # ffffffffc02023c0 <commands+0x118>
           fdt32_to_cpu(x >> 32);
ffffffffc0200758:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020075c:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc0200760:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200764:	0187de1b          	srliw	t3,a5,0x18
ffffffffc0200768:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020076c:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200770:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200774:	0187d693          	srli	a3,a5,0x18
ffffffffc0200778:	01861f1b          	slliw	t5,a2,0x18
ffffffffc020077c:	0087579b          	srliw	a5,a4,0x8
ffffffffc0200780:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200784:	0106561b          	srliw	a2,a2,0x10
ffffffffc0200788:	010f6f33          	or	t5,t5,a6
ffffffffc020078c:	0187529b          	srliw	t0,a4,0x18
ffffffffc0200790:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200794:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200798:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020079c:	0186f6b3          	and	a3,a3,s8
ffffffffc02007a0:	01859e1b          	slliw	t3,a1,0x18
ffffffffc02007a4:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007a8:	0107581b          	srliw	a6,a4,0x10
ffffffffc02007ac:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007b0:	8361                	srli	a4,a4,0x18
ffffffffc02007b2:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007b6:	0105d59b          	srliw	a1,a1,0x10
ffffffffc02007ba:	01e6e6b3          	or	a3,a3,t5
ffffffffc02007be:	00cb7633          	and	a2,s6,a2
ffffffffc02007c2:	0088181b          	slliw	a6,a6,0x8
ffffffffc02007c6:	0085959b          	slliw	a1,a1,0x8
ffffffffc02007ca:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007ce:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007d2:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007d6:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007da:	0088989b          	slliw	a7,a7,0x8
ffffffffc02007de:	011b78b3          	and	a7,s6,a7
ffffffffc02007e2:	005eeeb3          	or	t4,t4,t0
ffffffffc02007e6:	00c6e733          	or	a4,a3,a2
ffffffffc02007ea:	006c6c33          	or	s8,s8,t1
ffffffffc02007ee:	010b76b3          	and	a3,s6,a6
ffffffffc02007f2:	00bb7b33          	and	s6,s6,a1
ffffffffc02007f6:	01d7e7b3          	or	a5,a5,t4
ffffffffc02007fa:	016c6b33          	or	s6,s8,s6
ffffffffc02007fe:	01146433          	or	s0,s0,a7
ffffffffc0200802:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc0200804:	1702                	slli	a4,a4,0x20
ffffffffc0200806:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200808:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc020080a:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020080c:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc020080e:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200812:	0167eb33          	or	s6,a5,s6
ffffffffc0200816:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200818:	90fff0ef          	jal	ra,ffffffffc0200126 <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc020081c:	85a2                	mv	a1,s0
ffffffffc020081e:	00002517          	auipc	a0,0x2
ffffffffc0200822:	bc250513          	addi	a0,a0,-1086 # ffffffffc02023e0 <commands+0x138>
ffffffffc0200826:	901ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020082a:	014b5613          	srli	a2,s6,0x14
ffffffffc020082e:	85da                	mv	a1,s6
ffffffffc0200830:	00002517          	auipc	a0,0x2
ffffffffc0200834:	bc850513          	addi	a0,a0,-1080 # ffffffffc02023f8 <commands+0x150>
ffffffffc0200838:	8efff0ef          	jal	ra,ffffffffc0200126 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc020083c:	008b05b3          	add	a1,s6,s0
ffffffffc0200840:	15fd                	addi	a1,a1,-1
ffffffffc0200842:	00002517          	auipc	a0,0x2
ffffffffc0200846:	bd650513          	addi	a0,a0,-1066 # ffffffffc0202418 <commands+0x170>
ffffffffc020084a:	8ddff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("DTB init completed\n");
ffffffffc020084e:	00002517          	auipc	a0,0x2
ffffffffc0200852:	c1a50513          	addi	a0,a0,-998 # ffffffffc0202468 <commands+0x1c0>
        memory_base = mem_base;
ffffffffc0200856:	00007797          	auipc	a5,0x7
ffffffffc020085a:	be87bd23          	sd	s0,-1030(a5) # ffffffffc0207450 <memory_base>
        memory_size = mem_size;
ffffffffc020085e:	00007797          	auipc	a5,0x7
ffffffffc0200862:	bf67bd23          	sd	s6,-1030(a5) # ffffffffc0207458 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc0200866:	b3f5                	j	ffffffffc0200652 <dtb_init+0x186>

ffffffffc0200868 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc0200868:	00007517          	auipc	a0,0x7
ffffffffc020086c:	be853503          	ld	a0,-1048(a0) # ffffffffc0207450 <memory_base>
ffffffffc0200870:	8082                	ret

ffffffffc0200872 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc0200872:	00007517          	auipc	a0,0x7
ffffffffc0200876:	be653503          	ld	a0,-1050(a0) # ffffffffc0207458 <memory_size>
ffffffffc020087a:	8082                	ret

ffffffffc020087c <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020087c:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200880:	8082                	ret

ffffffffc0200882 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200882:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200886:	8082                	ret

ffffffffc0200888 <idt_init>:
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel 
       统一的中断入口点，位于trapentry.S中*/
    write_csr(sscratch, 0);
ffffffffc0200888:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address 
    sscratch 是 RISC-V S模式(Supervisor mode)的临时寄存器
    设置 sscratch 寄存器为 0，表示当前正在内核态执行
    当中断发生时，__alltraps 会检查这个值来判断是从用户态还是内核态进入的中断*/
    write_csr(stvec, &__alltraps);
ffffffffc020088c:	00000797          	auipc	a5,0x0
ffffffffc0200890:	39078793          	addi	a5,a5,912 # ffffffffc0200c1c <__alltraps>
ffffffffc0200894:	10579073          	csrw	stvec,a5
    /*
    stvec (Supervisor Trap Vector Base Address Register) 是中断向量基址寄存器
    将其设置为 __alltraps 的地址
    这是最关键的一步：告诉 CPU "当发生任何中断或异常时，跳转到 __alltraps 这个地址执行"
    */
}
ffffffffc0200898:	8082                	ret

ffffffffc020089a <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);//出错地址
    cprintf("  cause    0x%08x\n", tf->cause);//异常/中断原因码
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020089a:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020089c:	1141                	addi	sp,sp,-16
ffffffffc020089e:	e022                	sd	s0,0(sp)
ffffffffc02008a0:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02008a2:	00002517          	auipc	a0,0x2
ffffffffc02008a6:	bde50513          	addi	a0,a0,-1058 # ffffffffc0202480 <commands+0x1d8>
void print_regs(struct pushregs *gpr) {
ffffffffc02008aa:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02008ac:	87bff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02008b0:	640c                	ld	a1,8(s0)
ffffffffc02008b2:	00002517          	auipc	a0,0x2
ffffffffc02008b6:	be650513          	addi	a0,a0,-1050 # ffffffffc0202498 <commands+0x1f0>
ffffffffc02008ba:	86dff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02008be:	680c                	ld	a1,16(s0)
ffffffffc02008c0:	00002517          	auipc	a0,0x2
ffffffffc02008c4:	bf050513          	addi	a0,a0,-1040 # ffffffffc02024b0 <commands+0x208>
ffffffffc02008c8:	85fff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02008cc:	6c0c                	ld	a1,24(s0)
ffffffffc02008ce:	00002517          	auipc	a0,0x2
ffffffffc02008d2:	bfa50513          	addi	a0,a0,-1030 # ffffffffc02024c8 <commands+0x220>
ffffffffc02008d6:	851ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02008da:	700c                	ld	a1,32(s0)
ffffffffc02008dc:	00002517          	auipc	a0,0x2
ffffffffc02008e0:	c0450513          	addi	a0,a0,-1020 # ffffffffc02024e0 <commands+0x238>
ffffffffc02008e4:	843ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02008e8:	740c                	ld	a1,40(s0)
ffffffffc02008ea:	00002517          	auipc	a0,0x2
ffffffffc02008ee:	c0e50513          	addi	a0,a0,-1010 # ffffffffc02024f8 <commands+0x250>
ffffffffc02008f2:	835ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02008f6:	780c                	ld	a1,48(s0)
ffffffffc02008f8:	00002517          	auipc	a0,0x2
ffffffffc02008fc:	c1850513          	addi	a0,a0,-1000 # ffffffffc0202510 <commands+0x268>
ffffffffc0200900:	827ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200904:	7c0c                	ld	a1,56(s0)
ffffffffc0200906:	00002517          	auipc	a0,0x2
ffffffffc020090a:	c2250513          	addi	a0,a0,-990 # ffffffffc0202528 <commands+0x280>
ffffffffc020090e:	819ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200912:	602c                	ld	a1,64(s0)
ffffffffc0200914:	00002517          	auipc	a0,0x2
ffffffffc0200918:	c2c50513          	addi	a0,a0,-980 # ffffffffc0202540 <commands+0x298>
ffffffffc020091c:	80bff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200920:	642c                	ld	a1,72(s0)
ffffffffc0200922:	00002517          	auipc	a0,0x2
ffffffffc0200926:	c3650513          	addi	a0,a0,-970 # ffffffffc0202558 <commands+0x2b0>
ffffffffc020092a:	ffcff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020092e:	682c                	ld	a1,80(s0)
ffffffffc0200930:	00002517          	auipc	a0,0x2
ffffffffc0200934:	c4050513          	addi	a0,a0,-960 # ffffffffc0202570 <commands+0x2c8>
ffffffffc0200938:	feeff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020093c:	6c2c                	ld	a1,88(s0)
ffffffffc020093e:	00002517          	auipc	a0,0x2
ffffffffc0200942:	c4a50513          	addi	a0,a0,-950 # ffffffffc0202588 <commands+0x2e0>
ffffffffc0200946:	fe0ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020094a:	702c                	ld	a1,96(s0)
ffffffffc020094c:	00002517          	auipc	a0,0x2
ffffffffc0200950:	c5450513          	addi	a0,a0,-940 # ffffffffc02025a0 <commands+0x2f8>
ffffffffc0200954:	fd2ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200958:	742c                	ld	a1,104(s0)
ffffffffc020095a:	00002517          	auipc	a0,0x2
ffffffffc020095e:	c5e50513          	addi	a0,a0,-930 # ffffffffc02025b8 <commands+0x310>
ffffffffc0200962:	fc4ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200966:	782c                	ld	a1,112(s0)
ffffffffc0200968:	00002517          	auipc	a0,0x2
ffffffffc020096c:	c6850513          	addi	a0,a0,-920 # ffffffffc02025d0 <commands+0x328>
ffffffffc0200970:	fb6ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200974:	7c2c                	ld	a1,120(s0)
ffffffffc0200976:	00002517          	auipc	a0,0x2
ffffffffc020097a:	c7250513          	addi	a0,a0,-910 # ffffffffc02025e8 <commands+0x340>
ffffffffc020097e:	fa8ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200982:	604c                	ld	a1,128(s0)
ffffffffc0200984:	00002517          	auipc	a0,0x2
ffffffffc0200988:	c7c50513          	addi	a0,a0,-900 # ffffffffc0202600 <commands+0x358>
ffffffffc020098c:	f9aff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200990:	644c                	ld	a1,136(s0)
ffffffffc0200992:	00002517          	auipc	a0,0x2
ffffffffc0200996:	c8650513          	addi	a0,a0,-890 # ffffffffc0202618 <commands+0x370>
ffffffffc020099a:	f8cff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020099e:	684c                	ld	a1,144(s0)
ffffffffc02009a0:	00002517          	auipc	a0,0x2
ffffffffc02009a4:	c9050513          	addi	a0,a0,-880 # ffffffffc0202630 <commands+0x388>
ffffffffc02009a8:	f7eff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc02009ac:	6c4c                	ld	a1,152(s0)
ffffffffc02009ae:	00002517          	auipc	a0,0x2
ffffffffc02009b2:	c9a50513          	addi	a0,a0,-870 # ffffffffc0202648 <commands+0x3a0>
ffffffffc02009b6:	f70ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02009ba:	704c                	ld	a1,160(s0)
ffffffffc02009bc:	00002517          	auipc	a0,0x2
ffffffffc02009c0:	ca450513          	addi	a0,a0,-860 # ffffffffc0202660 <commands+0x3b8>
ffffffffc02009c4:	f62ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02009c8:	744c                	ld	a1,168(s0)
ffffffffc02009ca:	00002517          	auipc	a0,0x2
ffffffffc02009ce:	cae50513          	addi	a0,a0,-850 # ffffffffc0202678 <commands+0x3d0>
ffffffffc02009d2:	f54ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02009d6:	784c                	ld	a1,176(s0)
ffffffffc02009d8:	00002517          	auipc	a0,0x2
ffffffffc02009dc:	cb850513          	addi	a0,a0,-840 # ffffffffc0202690 <commands+0x3e8>
ffffffffc02009e0:	f46ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02009e4:	7c4c                	ld	a1,184(s0)
ffffffffc02009e6:	00002517          	auipc	a0,0x2
ffffffffc02009ea:	cc250513          	addi	a0,a0,-830 # ffffffffc02026a8 <commands+0x400>
ffffffffc02009ee:	f38ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02009f2:	606c                	ld	a1,192(s0)
ffffffffc02009f4:	00002517          	auipc	a0,0x2
ffffffffc02009f8:	ccc50513          	addi	a0,a0,-820 # ffffffffc02026c0 <commands+0x418>
ffffffffc02009fc:	f2aff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200a00:	646c                	ld	a1,200(s0)
ffffffffc0200a02:	00002517          	auipc	a0,0x2
ffffffffc0200a06:	cd650513          	addi	a0,a0,-810 # ffffffffc02026d8 <commands+0x430>
ffffffffc0200a0a:	f1cff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200a0e:	686c                	ld	a1,208(s0)
ffffffffc0200a10:	00002517          	auipc	a0,0x2
ffffffffc0200a14:	ce050513          	addi	a0,a0,-800 # ffffffffc02026f0 <commands+0x448>
ffffffffc0200a18:	f0eff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200a1c:	6c6c                	ld	a1,216(s0)
ffffffffc0200a1e:	00002517          	auipc	a0,0x2
ffffffffc0200a22:	cea50513          	addi	a0,a0,-790 # ffffffffc0202708 <commands+0x460>
ffffffffc0200a26:	f00ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200a2a:	706c                	ld	a1,224(s0)
ffffffffc0200a2c:	00002517          	auipc	a0,0x2
ffffffffc0200a30:	cf450513          	addi	a0,a0,-780 # ffffffffc0202720 <commands+0x478>
ffffffffc0200a34:	ef2ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200a38:	746c                	ld	a1,232(s0)
ffffffffc0200a3a:	00002517          	auipc	a0,0x2
ffffffffc0200a3e:	cfe50513          	addi	a0,a0,-770 # ffffffffc0202738 <commands+0x490>
ffffffffc0200a42:	ee4ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200a46:	786c                	ld	a1,240(s0)
ffffffffc0200a48:	00002517          	auipc	a0,0x2
ffffffffc0200a4c:	d0850513          	addi	a0,a0,-760 # ffffffffc0202750 <commands+0x4a8>
ffffffffc0200a50:	ed6ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200a54:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200a56:	6402                	ld	s0,0(sp)
ffffffffc0200a58:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200a5a:	00002517          	auipc	a0,0x2
ffffffffc0200a5e:	d0e50513          	addi	a0,a0,-754 # ffffffffc0202768 <commands+0x4c0>
}
ffffffffc0200a62:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200a64:	ec2ff06f          	j	ffffffffc0200126 <cprintf>

ffffffffc0200a68 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200a68:	1141                	addi	sp,sp,-16
ffffffffc0200a6a:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a6c:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200a6e:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a70:	00002517          	auipc	a0,0x2
ffffffffc0200a74:	d1050513          	addi	a0,a0,-752 # ffffffffc0202780 <commands+0x4d8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200a78:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a7a:	eacff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200a7e:	8522                	mv	a0,s0
ffffffffc0200a80:	e1bff0ef          	jal	ra,ffffffffc020089a <print_regs>
    cprintf("  status   0x%08x\n", tf->status);//CPU状态寄存器
ffffffffc0200a84:	10043583          	ld	a1,256(s0)
ffffffffc0200a88:	00002517          	auipc	a0,0x2
ffffffffc0200a8c:	d1050513          	addi	a0,a0,-752 # ffffffffc0202798 <commands+0x4f0>
ffffffffc0200a90:	e96ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);//异常发生时的PC
ffffffffc0200a94:	10843583          	ld	a1,264(s0)
ffffffffc0200a98:	00002517          	auipc	a0,0x2
ffffffffc0200a9c:	d1850513          	addi	a0,a0,-744 # ffffffffc02027b0 <commands+0x508>
ffffffffc0200aa0:	e86ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);//出错地址
ffffffffc0200aa4:	11043583          	ld	a1,272(s0)
ffffffffc0200aa8:	00002517          	auipc	a0,0x2
ffffffffc0200aac:	d2050513          	addi	a0,a0,-736 # ffffffffc02027c8 <commands+0x520>
ffffffffc0200ab0:	e76ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);//异常/中断原因码
ffffffffc0200ab4:	11843583          	ld	a1,280(s0)
}
ffffffffc0200ab8:	6402                	ld	s0,0(sp)
ffffffffc0200aba:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);//异常/中断原因码
ffffffffc0200abc:	00002517          	auipc	a0,0x2
ffffffffc0200ac0:	d2450513          	addi	a0,a0,-732 # ffffffffc02027e0 <commands+0x538>
}
ffffffffc0200ac4:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);//异常/中断原因码
ffffffffc0200ac6:	e60ff06f          	j	ffffffffc0200126 <cprintf>

ffffffffc0200aca <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200aca:	11853783          	ld	a5,280(a0)
ffffffffc0200ace:	472d                	li	a4,11
ffffffffc0200ad0:	0786                	slli	a5,a5,0x1
ffffffffc0200ad2:	8385                	srli	a5,a5,0x1
ffffffffc0200ad4:	08f76263          	bltu	a4,a5,ffffffffc0200b58 <interrupt_handler+0x8e>
ffffffffc0200ad8:	00002717          	auipc	a4,0x2
ffffffffc0200adc:	de870713          	addi	a4,a4,-536 # ffffffffc02028c0 <commands+0x618>
ffffffffc0200ae0:	078a                	slli	a5,a5,0x2
ffffffffc0200ae2:	97ba                	add	a5,a5,a4
ffffffffc0200ae4:	439c                	lw	a5,0(a5)
ffffffffc0200ae6:	97ba                	add	a5,a5,a4
ffffffffc0200ae8:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");//超级管理器（H态）中断
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");//机器模式中断
ffffffffc0200aea:	00002517          	auipc	a0,0x2
ffffffffc0200aee:	d6e50513          	addi	a0,a0,-658 # ffffffffc0202858 <commands+0x5b0>
ffffffffc0200af2:	e34ff06f          	j	ffffffffc0200126 <cprintf>
            cprintf("Hypervisor software interrupt\n");//超级管理器（H态）中断
ffffffffc0200af6:	00002517          	auipc	a0,0x2
ffffffffc0200afa:	d4250513          	addi	a0,a0,-702 # ffffffffc0202838 <commands+0x590>
ffffffffc0200afe:	e28ff06f          	j	ffffffffc0200126 <cprintf>
            cprintf("User software interrupt\n");//用户态中断
ffffffffc0200b02:	00002517          	auipc	a0,0x2
ffffffffc0200b06:	cf650513          	addi	a0,a0,-778 # ffffffffc02027f8 <commands+0x550>
ffffffffc0200b0a:	e1cff06f          	j	ffffffffc0200126 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");//用户态定时器中断
ffffffffc0200b0e:	00002517          	auipc	a0,0x2
ffffffffc0200b12:	d6a50513          	addi	a0,a0,-662 # ffffffffc0202878 <commands+0x5d0>
ffffffffc0200b16:	e10ff06f          	j	ffffffffc0200126 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200b1a:	1141                	addi	sp,sp,-16
ffffffffc0200b1c:	e406                	sd	ra,8(sp)
            /*(1)设置下次时钟中断- clock_set_next_event()
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            clock_set_next_event();//发生这次时钟中断的时候，我们要设置下一次时钟中断
ffffffffc0200b1e:	991ff0ef          	jal	ra,ffffffffc02004ae <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200b22:	00007697          	auipc	a3,0x7
ffffffffc0200b26:	92668693          	addi	a3,a3,-1754 # ffffffffc0207448 <ticks>
ffffffffc0200b2a:	629c                	ld	a5,0(a3)
ffffffffc0200b2c:	06400713          	li	a4,100
ffffffffc0200b30:	0785                	addi	a5,a5,1
ffffffffc0200b32:	02e7f733          	remu	a4,a5,a4
ffffffffc0200b36:	e29c                	sd	a5,0(a3)
ffffffffc0200b38:	c30d                	beqz	a4,ffffffffc0200b5a <interrupt_handler+0x90>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200b3a:	60a2                	ld	ra,8(sp)
ffffffffc0200b3c:	0141                	addi	sp,sp,16
ffffffffc0200b3e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200b40:	00002517          	auipc	a0,0x2
ffffffffc0200b44:	d6050513          	addi	a0,a0,-672 # ffffffffc02028a0 <commands+0x5f8>
ffffffffc0200b48:	ddeff06f          	j	ffffffffc0200126 <cprintf>
            cprintf("Supervisor software interrupt\n");//内核态中断
ffffffffc0200b4c:	00002517          	auipc	a0,0x2
ffffffffc0200b50:	ccc50513          	addi	a0,a0,-820 # ffffffffc0202818 <commands+0x570>
ffffffffc0200b54:	dd2ff06f          	j	ffffffffc0200126 <cprintf>
            print_trapframe(tf);
ffffffffc0200b58:	bf01                	j	ffffffffc0200a68 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200b5a:	06400593          	li	a1,100
ffffffffc0200b5e:	00002517          	auipc	a0,0x2
ffffffffc0200b62:	d3250513          	addi	a0,a0,-718 # ffffffffc0202890 <commands+0x5e8>
ffffffffc0200b66:	dc0ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
                num++; // 打印次数加一
ffffffffc0200b6a:	00007717          	auipc	a4,0x7
ffffffffc0200b6e:	8f670713          	addi	a4,a4,-1802 # ffffffffc0207460 <num>
ffffffffc0200b72:	431c                	lw	a5,0(a4)
                if (num == 10) {
ffffffffc0200b74:	46a9                	li	a3,10
                num++; // 打印次数加一
ffffffffc0200b76:	0017861b          	addiw	a2,a5,1
ffffffffc0200b7a:	c310                	sw	a2,0(a4)
                if (num == 10) {
ffffffffc0200b7c:	fad61fe3          	bne	a2,a3,ffffffffc0200b3a <interrupt_handler+0x70>
}
ffffffffc0200b80:	60a2                	ld	ra,8(sp)
ffffffffc0200b82:	0141                	addi	sp,sp,16
                    sbi_shutdown(); // 关机
ffffffffc0200b84:	2fc0106f          	j	ffffffffc0201e80 <sbi_shutdown>

ffffffffc0200b88 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
ffffffffc0200b88:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200b8c:	1141                	addi	sp,sp,-16
ffffffffc0200b8e:	e022                	sd	s0,0(sp)
ffffffffc0200b90:	e406                	sd	ra,8(sp)
    switch (tf->cause) {
ffffffffc0200b92:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
ffffffffc0200b94:	842a                	mv	s0,a0
    switch (tf->cause) {
ffffffffc0200b96:	04e78663          	beq	a5,a4,ffffffffc0200be2 <exception_handler+0x5a>
ffffffffc0200b9a:	02f76c63          	bltu	a4,a5,ffffffffc0200bd2 <exception_handler+0x4a>
ffffffffc0200b9e:	4709                	li	a4,2
ffffffffc0200ba0:	02e79563          	bne	a5,a4,ffffffffc0200bca <exception_handler+0x42>
             /* LAB3 CHALLENGE3   2310137 :  */
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            cprintf("Exception type: Illegal instruction\n");
ffffffffc0200ba4:	00002517          	auipc	a0,0x2
ffffffffc0200ba8:	d4c50513          	addi	a0,a0,-692 # ffffffffc02028f0 <commands+0x648>
ffffffffc0200bac:	d7aff0ef          	jal	ra,ffffffffc0200126 <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
ffffffffc0200bb0:	10843583          	ld	a1,264(s0)
ffffffffc0200bb4:	00002517          	auipc	a0,0x2
ffffffffc0200bb8:	d6450513          	addi	a0,a0,-668 # ffffffffc0202918 <commands+0x670>
ffffffffc0200bbc:	d6aff0ef          	jal	ra,ffffffffc0200126 <cprintf>
            // 更新 epc 寄存器，跳过非法指令（假设指令长度为4字节）
            tf->epc += 4;
ffffffffc0200bc0:	10843783          	ld	a5,264(s0)
ffffffffc0200bc4:	0791                	addi	a5,a5,4
ffffffffc0200bc6:	10f43423          	sd	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200bca:	60a2                	ld	ra,8(sp)
ffffffffc0200bcc:	6402                	ld	s0,0(sp)
ffffffffc0200bce:	0141                	addi	sp,sp,16
ffffffffc0200bd0:	8082                	ret
    switch (tf->cause) {
ffffffffc0200bd2:	17f1                	addi	a5,a5,-4
ffffffffc0200bd4:	471d                	li	a4,7
ffffffffc0200bd6:	fef77ae3          	bgeu	a4,a5,ffffffffc0200bca <exception_handler+0x42>
}
ffffffffc0200bda:	6402                	ld	s0,0(sp)
ffffffffc0200bdc:	60a2                	ld	ra,8(sp)
ffffffffc0200bde:	0141                	addi	sp,sp,16
            print_trapframe(tf);
ffffffffc0200be0:	b561                	j	ffffffffc0200a68 <print_trapframe>
            cprintf("Exception type: breakpoint\n");
ffffffffc0200be2:	00002517          	auipc	a0,0x2
ffffffffc0200be6:	d5e50513          	addi	a0,a0,-674 # ffffffffc0202940 <commands+0x698>
ffffffffc0200bea:	d3cff0ef          	jal	ra,ffffffffc0200126 <cprintf>
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
ffffffffc0200bee:	10843583          	ld	a1,264(s0)
ffffffffc0200bf2:	00002517          	auipc	a0,0x2
ffffffffc0200bf6:	d6e50513          	addi	a0,a0,-658 # ffffffffc0202960 <commands+0x6b8>
ffffffffc0200bfa:	d2cff0ef          	jal	ra,ffffffffc0200126 <cprintf>
            tf->epc += 2;
ffffffffc0200bfe:	10843783          	ld	a5,264(s0)
}
ffffffffc0200c02:	60a2                	ld	ra,8(sp)
            tf->epc += 2;
ffffffffc0200c04:	0789                	addi	a5,a5,2
ffffffffc0200c06:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200c0a:	6402                	ld	s0,0(sp)
ffffffffc0200c0c:	0141                	addi	sp,sp,16
ffffffffc0200c0e:	8082                	ret

ffffffffc0200c10 <trap>:
/*
tf->cause < 0：最高位为 1，表示是中断（interrupt），调用 interrupt_handler 处理
tf->cause >= 0：最高位为 0，表示是异常（exception），调用 exception_handler 处理
*/
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c10:	11853783          	ld	a5,280(a0)
ffffffffc0200c14:	0007c363          	bltz	a5,ffffffffc0200c1a <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200c18:	bf85                	j	ffffffffc0200b88 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200c1a:	bd45                	j	ffffffffc0200aca <interrupt_handler>

ffffffffc0200c1c <__alltraps>:

    .globl __alltraps

.align(2) # 中断入口点 __alltraps必须四字节对齐
__alltraps:
    SAVE_ALL # 保存上下文
ffffffffc0200c1c:	14011073          	csrw	sscratch,sp
ffffffffc0200c20:	712d                	addi	sp,sp,-288
ffffffffc0200c22:	e002                	sd	zero,0(sp)
ffffffffc0200c24:	e406                	sd	ra,8(sp)
ffffffffc0200c26:	ec0e                	sd	gp,24(sp)
ffffffffc0200c28:	f012                	sd	tp,32(sp)
ffffffffc0200c2a:	f416                	sd	t0,40(sp)
ffffffffc0200c2c:	f81a                	sd	t1,48(sp)
ffffffffc0200c2e:	fc1e                	sd	t2,56(sp)
ffffffffc0200c30:	e0a2                	sd	s0,64(sp)
ffffffffc0200c32:	e4a6                	sd	s1,72(sp)
ffffffffc0200c34:	e8aa                	sd	a0,80(sp)
ffffffffc0200c36:	ecae                	sd	a1,88(sp)
ffffffffc0200c38:	f0b2                	sd	a2,96(sp)
ffffffffc0200c3a:	f4b6                	sd	a3,104(sp)
ffffffffc0200c3c:	f8ba                	sd	a4,112(sp)
ffffffffc0200c3e:	fcbe                	sd	a5,120(sp)
ffffffffc0200c40:	e142                	sd	a6,128(sp)
ffffffffc0200c42:	e546                	sd	a7,136(sp)
ffffffffc0200c44:	e94a                	sd	s2,144(sp)
ffffffffc0200c46:	ed4e                	sd	s3,152(sp)
ffffffffc0200c48:	f152                	sd	s4,160(sp)
ffffffffc0200c4a:	f556                	sd	s5,168(sp)
ffffffffc0200c4c:	f95a                	sd	s6,176(sp)
ffffffffc0200c4e:	fd5e                	sd	s7,184(sp)
ffffffffc0200c50:	e1e2                	sd	s8,192(sp)
ffffffffc0200c52:	e5e6                	sd	s9,200(sp)
ffffffffc0200c54:	e9ea                	sd	s10,208(sp)
ffffffffc0200c56:	edee                	sd	s11,216(sp)
ffffffffc0200c58:	f1f2                	sd	t3,224(sp)
ffffffffc0200c5a:	f5f6                	sd	t4,232(sp)
ffffffffc0200c5c:	f9fa                	sd	t5,240(sp)
ffffffffc0200c5e:	fdfe                	sd	t6,248(sp)
ffffffffc0200c60:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200c64:	100024f3          	csrr	s1,sstatus
ffffffffc0200c68:	14102973          	csrr	s2,sepc
ffffffffc0200c6c:	143029f3          	csrr	s3,stval
ffffffffc0200c70:	14202a73          	csrr	s4,scause
ffffffffc0200c74:	e822                	sd	s0,16(sp)
ffffffffc0200c76:	e226                	sd	s1,256(sp)
ffffffffc0200c78:	e64a                	sd	s2,264(sp)
ffffffffc0200c7a:	ea4e                	sd	s3,272(sp)
ffffffffc0200c7c:	ee52                	sd	s4,280(sp)

    move  a0, sp # 传递参数。
ffffffffc0200c7e:	850a                	mv	a0,sp
    # 按照RISCV calling convention, a0寄存器传递参数给接下来调用的函数trap。
    # trap是trap.c里面的一个C语言函数，也就是我们的中断处理程序
    jal trap 
ffffffffc0200c80:	f91ff0ef          	jal	ra,ffffffffc0200c10 <trap>

ffffffffc0200c84 <__trapret>:
    # trap函数指向完之后，会回到这里向下继续执行__trapret里面的内容，RESTORE_ALL,sret

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200c84:	6492                	ld	s1,256(sp)
ffffffffc0200c86:	6932                	ld	s2,264(sp)
ffffffffc0200c88:	10049073          	csrw	sstatus,s1
ffffffffc0200c8c:	14191073          	csrw	sepc,s2
ffffffffc0200c90:	60a2                	ld	ra,8(sp)
ffffffffc0200c92:	61e2                	ld	gp,24(sp)
ffffffffc0200c94:	7202                	ld	tp,32(sp)
ffffffffc0200c96:	72a2                	ld	t0,40(sp)
ffffffffc0200c98:	7342                	ld	t1,48(sp)
ffffffffc0200c9a:	73e2                	ld	t2,56(sp)
ffffffffc0200c9c:	6406                	ld	s0,64(sp)
ffffffffc0200c9e:	64a6                	ld	s1,72(sp)
ffffffffc0200ca0:	6546                	ld	a0,80(sp)
ffffffffc0200ca2:	65e6                	ld	a1,88(sp)
ffffffffc0200ca4:	7606                	ld	a2,96(sp)
ffffffffc0200ca6:	76a6                	ld	a3,104(sp)
ffffffffc0200ca8:	7746                	ld	a4,112(sp)
ffffffffc0200caa:	77e6                	ld	a5,120(sp)
ffffffffc0200cac:	680a                	ld	a6,128(sp)
ffffffffc0200cae:	68aa                	ld	a7,136(sp)
ffffffffc0200cb0:	694a                	ld	s2,144(sp)
ffffffffc0200cb2:	69ea                	ld	s3,152(sp)
ffffffffc0200cb4:	7a0a                	ld	s4,160(sp)
ffffffffc0200cb6:	7aaa                	ld	s5,168(sp)
ffffffffc0200cb8:	7b4a                	ld	s6,176(sp)
ffffffffc0200cba:	7bea                	ld	s7,184(sp)
ffffffffc0200cbc:	6c0e                	ld	s8,192(sp)
ffffffffc0200cbe:	6cae                	ld	s9,200(sp)
ffffffffc0200cc0:	6d4e                	ld	s10,208(sp)
ffffffffc0200cc2:	6dee                	ld	s11,216(sp)
ffffffffc0200cc4:	7e0e                	ld	t3,224(sp)
ffffffffc0200cc6:	7eae                	ld	t4,232(sp)
ffffffffc0200cc8:	7f4e                	ld	t5,240(sp)
ffffffffc0200cca:	7fee                	ld	t6,248(sp)
ffffffffc0200ccc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200cce:	10200073          	sret

ffffffffc0200cd2 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200cd2:	00006797          	auipc	a5,0x6
ffffffffc0200cd6:	35678793          	addi	a5,a5,854 # ffffffffc0207028 <free_area>
ffffffffc0200cda:	e79c                	sd	a5,8(a5)
ffffffffc0200cdc:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200cde:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200ce2:	8082                	ret

ffffffffc0200ce4 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200ce4:	00006517          	auipc	a0,0x6
ffffffffc0200ce8:	35456503          	lwu	a0,852(a0) # ffffffffc0207038 <free_area+0x10>
ffffffffc0200cec:	8082                	ret

ffffffffc0200cee <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0200cee:	c14d                	beqz	a0,ffffffffc0200d90 <best_fit_alloc_pages+0xa2>
    if (n > nr_free) {
ffffffffc0200cf0:	00006617          	auipc	a2,0x6
ffffffffc0200cf4:	33860613          	addi	a2,a2,824 # ffffffffc0207028 <free_area>
ffffffffc0200cf8:	01062803          	lw	a6,16(a2)
ffffffffc0200cfc:	86aa                	mv	a3,a0
ffffffffc0200cfe:	02081793          	slli	a5,a6,0x20
ffffffffc0200d02:	9381                	srli	a5,a5,0x20
ffffffffc0200d04:	08a7e463          	bltu	a5,a0,ffffffffc0200d8c <best_fit_alloc_pages+0x9e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200d08:	661c                	ld	a5,8(a2)
    size_t min_size = nr_free + 1;
ffffffffc0200d0a:	0018059b          	addiw	a1,a6,1
ffffffffc0200d0e:	1582                	slli	a1,a1,0x20
ffffffffc0200d10:	9181                	srli	a1,a1,0x20
    struct Page *page = NULL;
ffffffffc0200d12:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d14:	06c78b63          	beq	a5,a2,ffffffffc0200d8a <best_fit_alloc_pages+0x9c>
    if (p->property >= n && p->property < min_size) {
ffffffffc0200d18:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0200d1c:	00d76763          	bltu	a4,a3,ffffffffc0200d2a <best_fit_alloc_pages+0x3c>
ffffffffc0200d20:	00b77563          	bgeu	a4,a1,ffffffffc0200d2a <best_fit_alloc_pages+0x3c>
    struct Page *p = le2page(le, page_link);
ffffffffc0200d24:	fe878513          	addi	a0,a5,-24
ffffffffc0200d28:	85ba                	mv	a1,a4
ffffffffc0200d2a:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d2c:	fec796e3          	bne	a5,a2,ffffffffc0200d18 <best_fit_alloc_pages+0x2a>
    if (page != NULL) {
ffffffffc0200d30:	cd29                	beqz	a0,ffffffffc0200d8a <best_fit_alloc_pages+0x9c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d32:	711c                	ld	a5,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200d34:	6d18                	ld	a4,24(a0)
        if (page->property > n) {
ffffffffc0200d36:	490c                	lw	a1,16(a0)
            p->property = page->property - n;
ffffffffc0200d38:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200d3c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200d3e:	e398                	sd	a4,0(a5)
        if (page->property > n) {
ffffffffc0200d40:	02059793          	slli	a5,a1,0x20
ffffffffc0200d44:	9381                	srli	a5,a5,0x20
ffffffffc0200d46:	02f6f863          	bgeu	a3,a5,ffffffffc0200d76 <best_fit_alloc_pages+0x88>
            struct Page *p = page + n;
ffffffffc0200d4a:	00269793          	slli	a5,a3,0x2
ffffffffc0200d4e:	97b6                	add	a5,a5,a3
ffffffffc0200d50:	078e                	slli	a5,a5,0x3
ffffffffc0200d52:	97aa                	add	a5,a5,a0
            p->property = page->property - n;
ffffffffc0200d54:	411585bb          	subw	a1,a1,a7
ffffffffc0200d58:	cb8c                	sw	a1,16(a5)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200d5a:	4689                	li	a3,2
ffffffffc0200d5c:	00878593          	addi	a1,a5,8
ffffffffc0200d60:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200d64:	6714                	ld	a3,8(a4)
            list_add(prev, &(p->page_link));
ffffffffc0200d66:	01878593          	addi	a1,a5,24
        nr_free -= n;
ffffffffc0200d6a:	01062803          	lw	a6,16(a2)
    prev->next = next->prev = elm;
ffffffffc0200d6e:	e28c                	sd	a1,0(a3)
ffffffffc0200d70:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc0200d72:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc0200d74:	ef98                	sd	a4,24(a5)
ffffffffc0200d76:	4118083b          	subw	a6,a6,a7
ffffffffc0200d7a:	01062823          	sw	a6,16(a2)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200d7e:	57f5                	li	a5,-3
ffffffffc0200d80:	00850713          	addi	a4,a0,8
ffffffffc0200d84:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc0200d88:	8082                	ret
}
ffffffffc0200d8a:	8082                	ret
        return NULL;
ffffffffc0200d8c:	4501                	li	a0,0
ffffffffc0200d8e:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc0200d90:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200d92:	00002697          	auipc	a3,0x2
ffffffffc0200d96:	bee68693          	addi	a3,a3,-1042 # ffffffffc0202980 <commands+0x6d8>
ffffffffc0200d9a:	00002617          	auipc	a2,0x2
ffffffffc0200d9e:	bee60613          	addi	a2,a2,-1042 # ffffffffc0202988 <commands+0x6e0>
ffffffffc0200da2:	06900593          	li	a1,105
ffffffffc0200da6:	00002517          	auipc	a0,0x2
ffffffffc0200daa:	bfa50513          	addi	a0,a0,-1030 # ffffffffc02029a0 <commands+0x6f8>
best_fit_alloc_pages(size_t n) {
ffffffffc0200dae:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200db0:	e70ff0ef          	jal	ra,ffffffffc0200420 <__panic>

ffffffffc0200db4 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200db4:	715d                	addi	sp,sp,-80
ffffffffc0200db6:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0200db8:	00006417          	auipc	s0,0x6
ffffffffc0200dbc:	27040413          	addi	s0,s0,624 # ffffffffc0207028 <free_area>
ffffffffc0200dc0:	641c                	ld	a5,8(s0)
ffffffffc0200dc2:	e486                	sd	ra,72(sp)
ffffffffc0200dc4:	fc26                	sd	s1,56(sp)
ffffffffc0200dc6:	f84a                	sd	s2,48(sp)
ffffffffc0200dc8:	f44e                	sd	s3,40(sp)
ffffffffc0200dca:	f052                	sd	s4,32(sp)
ffffffffc0200dcc:	ec56                	sd	s5,24(sp)
ffffffffc0200dce:	e85a                	sd	s6,16(sp)
ffffffffc0200dd0:	e45e                	sd	s7,8(sp)
ffffffffc0200dd2:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200dd4:	28878763          	beq	a5,s0,ffffffffc0201062 <best_fit_check+0x2ae>
    int count = 0, total = 0;
ffffffffc0200dd8:	4481                	li	s1,0
ffffffffc0200dda:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200ddc:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200de0:	8b09                	andi	a4,a4,2
ffffffffc0200de2:	28070463          	beqz	a4,ffffffffc020106a <best_fit_check+0x2b6>
        count ++, total += p->property;
ffffffffc0200de6:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200dea:	679c                	ld	a5,8(a5)
ffffffffc0200dec:	2905                	addiw	s2,s2,1
ffffffffc0200dee:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200df0:	fe8796e3          	bne	a5,s0,ffffffffc0200ddc <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200df4:	89a6                	mv	s3,s1
ffffffffc0200df6:	17f000ef          	jal	ra,ffffffffc0201774 <nr_free_pages>
ffffffffc0200dfa:	35351863          	bne	a0,s3,ffffffffc020114a <best_fit_check+0x396>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200dfe:	4505                	li	a0,1
ffffffffc0200e00:	0f7000ef          	jal	ra,ffffffffc02016f6 <alloc_pages>
ffffffffc0200e04:	8a2a                	mv	s4,a0
ffffffffc0200e06:	38050263          	beqz	a0,ffffffffc020118a <best_fit_check+0x3d6>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e0a:	4505                	li	a0,1
ffffffffc0200e0c:	0eb000ef          	jal	ra,ffffffffc02016f6 <alloc_pages>
ffffffffc0200e10:	89aa                	mv	s3,a0
ffffffffc0200e12:	34050c63          	beqz	a0,ffffffffc020116a <best_fit_check+0x3b6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e16:	4505                	li	a0,1
ffffffffc0200e18:	0df000ef          	jal	ra,ffffffffc02016f6 <alloc_pages>
ffffffffc0200e1c:	8aaa                	mv	s5,a0
ffffffffc0200e1e:	2e050663          	beqz	a0,ffffffffc020110a <best_fit_check+0x356>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e22:	273a0463          	beq	s4,s3,ffffffffc020108a <best_fit_check+0x2d6>
ffffffffc0200e26:	26aa0263          	beq	s4,a0,ffffffffc020108a <best_fit_check+0x2d6>
ffffffffc0200e2a:	26a98063          	beq	s3,a0,ffffffffc020108a <best_fit_check+0x2d6>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e2e:	000a2783          	lw	a5,0(s4)
ffffffffc0200e32:	26079c63          	bnez	a5,ffffffffc02010aa <best_fit_check+0x2f6>
ffffffffc0200e36:	0009a783          	lw	a5,0(s3)
ffffffffc0200e3a:	26079863          	bnez	a5,ffffffffc02010aa <best_fit_check+0x2f6>
ffffffffc0200e3e:	411c                	lw	a5,0(a0)
ffffffffc0200e40:	26079563          	bnez	a5,ffffffffc02010aa <best_fit_check+0x2f6>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200e44:	00006797          	auipc	a5,0x6
ffffffffc0200e48:	62c7b783          	ld	a5,1580(a5) # ffffffffc0207470 <pages>
ffffffffc0200e4c:	40fa0733          	sub	a4,s4,a5
ffffffffc0200e50:	870d                	srai	a4,a4,0x3
ffffffffc0200e52:	00002597          	auipc	a1,0x2
ffffffffc0200e56:	29e5b583          	ld	a1,670(a1) # ffffffffc02030f0 <error_string+0x38>
ffffffffc0200e5a:	02b70733          	mul	a4,a4,a1
ffffffffc0200e5e:	00002617          	auipc	a2,0x2
ffffffffc0200e62:	29a63603          	ld	a2,666(a2) # ffffffffc02030f8 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e66:	00006697          	auipc	a3,0x6
ffffffffc0200e6a:	6026b683          	ld	a3,1538(a3) # ffffffffc0207468 <npage>
ffffffffc0200e6e:	06b2                	slli	a3,a3,0xc
ffffffffc0200e70:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e72:	0732                	slli	a4,a4,0xc
ffffffffc0200e74:	24d77b63          	bgeu	a4,a3,ffffffffc02010ca <best_fit_check+0x316>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200e78:	40f98733          	sub	a4,s3,a5
ffffffffc0200e7c:	870d                	srai	a4,a4,0x3
ffffffffc0200e7e:	02b70733          	mul	a4,a4,a1
ffffffffc0200e82:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e84:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200e86:	40d77263          	bgeu	a4,a3,ffffffffc020128a <best_fit_check+0x4d6>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200e8a:	40f507b3          	sub	a5,a0,a5
ffffffffc0200e8e:	878d                	srai	a5,a5,0x3
ffffffffc0200e90:	02b787b3          	mul	a5,a5,a1
ffffffffc0200e94:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e96:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200e98:	3cd7f963          	bgeu	a5,a3,ffffffffc020126a <best_fit_check+0x4b6>
    assert(alloc_page() == NULL);
ffffffffc0200e9c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200e9e:	00043c03          	ld	s8,0(s0)
ffffffffc0200ea2:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200ea6:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200eaa:	e400                	sd	s0,8(s0)
ffffffffc0200eac:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200eae:	00006797          	auipc	a5,0x6
ffffffffc0200eb2:	1807a523          	sw	zero,394(a5) # ffffffffc0207038 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200eb6:	041000ef          	jal	ra,ffffffffc02016f6 <alloc_pages>
ffffffffc0200eba:	38051863          	bnez	a0,ffffffffc020124a <best_fit_check+0x496>
    free_page(p0);
ffffffffc0200ebe:	4585                	li	a1,1
ffffffffc0200ec0:	8552                	mv	a0,s4
ffffffffc0200ec2:	073000ef          	jal	ra,ffffffffc0201734 <free_pages>
    free_page(p1);
ffffffffc0200ec6:	4585                	li	a1,1
ffffffffc0200ec8:	854e                	mv	a0,s3
ffffffffc0200eca:	06b000ef          	jal	ra,ffffffffc0201734 <free_pages>
    free_page(p2);
ffffffffc0200ece:	4585                	li	a1,1
ffffffffc0200ed0:	8556                	mv	a0,s5
ffffffffc0200ed2:	063000ef          	jal	ra,ffffffffc0201734 <free_pages>
    assert(nr_free == 3);
ffffffffc0200ed6:	4818                	lw	a4,16(s0)
ffffffffc0200ed8:	478d                	li	a5,3
ffffffffc0200eda:	34f71863          	bne	a4,a5,ffffffffc020122a <best_fit_check+0x476>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ede:	4505                	li	a0,1
ffffffffc0200ee0:	017000ef          	jal	ra,ffffffffc02016f6 <alloc_pages>
ffffffffc0200ee4:	89aa                	mv	s3,a0
ffffffffc0200ee6:	32050263          	beqz	a0,ffffffffc020120a <best_fit_check+0x456>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200eea:	4505                	li	a0,1
ffffffffc0200eec:	00b000ef          	jal	ra,ffffffffc02016f6 <alloc_pages>
ffffffffc0200ef0:	8aaa                	mv	s5,a0
ffffffffc0200ef2:	2e050c63          	beqz	a0,ffffffffc02011ea <best_fit_check+0x436>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ef6:	4505                	li	a0,1
ffffffffc0200ef8:	7fe000ef          	jal	ra,ffffffffc02016f6 <alloc_pages>
ffffffffc0200efc:	8a2a                	mv	s4,a0
ffffffffc0200efe:	2c050663          	beqz	a0,ffffffffc02011ca <best_fit_check+0x416>
    assert(alloc_page() == NULL);
ffffffffc0200f02:	4505                	li	a0,1
ffffffffc0200f04:	7f2000ef          	jal	ra,ffffffffc02016f6 <alloc_pages>
ffffffffc0200f08:	2a051163          	bnez	a0,ffffffffc02011aa <best_fit_check+0x3f6>
    free_page(p0);
ffffffffc0200f0c:	4585                	li	a1,1
ffffffffc0200f0e:	854e                	mv	a0,s3
ffffffffc0200f10:	025000ef          	jal	ra,ffffffffc0201734 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200f14:	641c                	ld	a5,8(s0)
ffffffffc0200f16:	1c878a63          	beq	a5,s0,ffffffffc02010ea <best_fit_check+0x336>
    assert((p = alloc_page()) == p0);
ffffffffc0200f1a:	4505                	li	a0,1
ffffffffc0200f1c:	7da000ef          	jal	ra,ffffffffc02016f6 <alloc_pages>
ffffffffc0200f20:	54a99563          	bne	s3,a0,ffffffffc020146a <best_fit_check+0x6b6>
    assert(alloc_page() == NULL);
ffffffffc0200f24:	4505                	li	a0,1
ffffffffc0200f26:	7d0000ef          	jal	ra,ffffffffc02016f6 <alloc_pages>
ffffffffc0200f2a:	52051063          	bnez	a0,ffffffffc020144a <best_fit_check+0x696>
    assert(nr_free == 0);
ffffffffc0200f2e:	481c                	lw	a5,16(s0)
ffffffffc0200f30:	4e079d63          	bnez	a5,ffffffffc020142a <best_fit_check+0x676>
    free_page(p);
ffffffffc0200f34:	854e                	mv	a0,s3
ffffffffc0200f36:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200f38:	01843023          	sd	s8,0(s0)
ffffffffc0200f3c:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200f40:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200f44:	7f0000ef          	jal	ra,ffffffffc0201734 <free_pages>
    free_page(p1);
ffffffffc0200f48:	4585                	li	a1,1
ffffffffc0200f4a:	8556                	mv	a0,s5
ffffffffc0200f4c:	7e8000ef          	jal	ra,ffffffffc0201734 <free_pages>
    free_page(p2);
ffffffffc0200f50:	4585                	li	a1,1
ffffffffc0200f52:	8552                	mv	a0,s4
ffffffffc0200f54:	7e0000ef          	jal	ra,ffffffffc0201734 <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200f58:	4515                	li	a0,5
ffffffffc0200f5a:	79c000ef          	jal	ra,ffffffffc02016f6 <alloc_pages>
ffffffffc0200f5e:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200f60:	4a050563          	beqz	a0,ffffffffc020140a <best_fit_check+0x656>
ffffffffc0200f64:	651c                	ld	a5,8(a0)
ffffffffc0200f66:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200f68:	8b85                	andi	a5,a5,1
ffffffffc0200f6a:	48079063          	bnez	a5,ffffffffc02013ea <best_fit_check+0x636>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200f6e:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200f70:	00043a83          	ld	s5,0(s0)
ffffffffc0200f74:	00843a03          	ld	s4,8(s0)
ffffffffc0200f78:	e000                	sd	s0,0(s0)
ffffffffc0200f7a:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200f7c:	77a000ef          	jal	ra,ffffffffc02016f6 <alloc_pages>
ffffffffc0200f80:	44051563          	bnez	a0,ffffffffc02013ca <best_fit_check+0x616>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200f84:	4589                	li	a1,2
ffffffffc0200f86:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200f8a:	01042b03          	lw	s6,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc0200f8e:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200f92:	00006797          	auipc	a5,0x6
ffffffffc0200f96:	0a07a323          	sw	zero,166(a5) # ffffffffc0207038 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200f9a:	79a000ef          	jal	ra,ffffffffc0201734 <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200f9e:	8562                	mv	a0,s8
ffffffffc0200fa0:	4585                	li	a1,1
ffffffffc0200fa2:	792000ef          	jal	ra,ffffffffc0201734 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200fa6:	4511                	li	a0,4
ffffffffc0200fa8:	74e000ef          	jal	ra,ffffffffc02016f6 <alloc_pages>
ffffffffc0200fac:	3e051f63          	bnez	a0,ffffffffc02013aa <best_fit_check+0x5f6>
ffffffffc0200fb0:	0309b783          	ld	a5,48(s3)
ffffffffc0200fb4:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200fb6:	8b85                	andi	a5,a5,1
ffffffffc0200fb8:	3c078963          	beqz	a5,ffffffffc020138a <best_fit_check+0x5d6>
ffffffffc0200fbc:	0389a703          	lw	a4,56(s3)
ffffffffc0200fc0:	4789                	li	a5,2
ffffffffc0200fc2:	3cf71463          	bne	a4,a5,ffffffffc020138a <best_fit_check+0x5d6>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200fc6:	4505                	li	a0,1
ffffffffc0200fc8:	72e000ef          	jal	ra,ffffffffc02016f6 <alloc_pages>
ffffffffc0200fcc:	8baa                	mv	s7,a0
ffffffffc0200fce:	38050e63          	beqz	a0,ffffffffc020136a <best_fit_check+0x5b6>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200fd2:	4509                	li	a0,2
ffffffffc0200fd4:	722000ef          	jal	ra,ffffffffc02016f6 <alloc_pages>
ffffffffc0200fd8:	36050963          	beqz	a0,ffffffffc020134a <best_fit_check+0x596>
    assert(p0 + 4 == p1);
ffffffffc0200fdc:	357c1763          	bne	s8,s7,ffffffffc020132a <best_fit_check+0x576>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200fe0:	854e                	mv	a0,s3
ffffffffc0200fe2:	4595                	li	a1,5
ffffffffc0200fe4:	750000ef          	jal	ra,ffffffffc0201734 <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200fe8:	4515                	li	a0,5
ffffffffc0200fea:	70c000ef          	jal	ra,ffffffffc02016f6 <alloc_pages>
ffffffffc0200fee:	89aa                	mv	s3,a0
ffffffffc0200ff0:	30050d63          	beqz	a0,ffffffffc020130a <best_fit_check+0x556>
    assert(alloc_page() == NULL);
ffffffffc0200ff4:	4505                	li	a0,1
ffffffffc0200ff6:	700000ef          	jal	ra,ffffffffc02016f6 <alloc_pages>
ffffffffc0200ffa:	2e051863          	bnez	a0,ffffffffc02012ea <best_fit_check+0x536>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200ffe:	481c                	lw	a5,16(s0)
ffffffffc0201000:	2c079563          	bnez	a5,ffffffffc02012ca <best_fit_check+0x516>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201004:	4595                	li	a1,5
ffffffffc0201006:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0201008:	01642823          	sw	s6,16(s0)
    free_list = free_list_store;
ffffffffc020100c:	01543023          	sd	s5,0(s0)
ffffffffc0201010:	01443423          	sd	s4,8(s0)
    free_pages(p0, 5);
ffffffffc0201014:	720000ef          	jal	ra,ffffffffc0201734 <free_pages>
    return listelm->next;
ffffffffc0201018:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020101a:	00878963          	beq	a5,s0,ffffffffc020102c <best_fit_check+0x278>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020101e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201022:	679c                	ld	a5,8(a5)
ffffffffc0201024:	397d                	addiw	s2,s2,-1
ffffffffc0201026:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201028:	fe879be3          	bne	a5,s0,ffffffffc020101e <best_fit_check+0x26a>
    }
    assert(count == 0);
ffffffffc020102c:	26091f63          	bnez	s2,ffffffffc02012aa <best_fit_check+0x4f6>
    assert(total == 0);
ffffffffc0201030:	0e049d63          	bnez	s1,ffffffffc020112a <best_fit_check+0x376>
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif

    // 为自动评分脚本输出 satp 虚拟地址和物理地址
    cprintf("satp virtual address: 0xffffffffc0205000\n");
ffffffffc0201034:	00002517          	auipc	a0,0x2
ffffffffc0201038:	c4450513          	addi	a0,a0,-956 # ffffffffc0202c78 <commands+0x9d0>
ffffffffc020103c:	8eaff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("satp physical address: 0x0000000080205000\n");
}
ffffffffc0201040:	6406                	ld	s0,64(sp)
ffffffffc0201042:	60a6                	ld	ra,72(sp)
ffffffffc0201044:	74e2                	ld	s1,56(sp)
ffffffffc0201046:	7942                	ld	s2,48(sp)
ffffffffc0201048:	79a2                	ld	s3,40(sp)
ffffffffc020104a:	7a02                	ld	s4,32(sp)
ffffffffc020104c:	6ae2                	ld	s5,24(sp)
ffffffffc020104e:	6b42                	ld	s6,16(sp)
ffffffffc0201050:	6ba2                	ld	s7,8(sp)
ffffffffc0201052:	6c02                	ld	s8,0(sp)
    cprintf("satp physical address: 0x0000000080205000\n");
ffffffffc0201054:	00002517          	auipc	a0,0x2
ffffffffc0201058:	c5450513          	addi	a0,a0,-940 # ffffffffc0202ca8 <commands+0xa00>
}
ffffffffc020105c:	6161                	addi	sp,sp,80
    cprintf("satp physical address: 0x0000000080205000\n");
ffffffffc020105e:	8c8ff06f          	j	ffffffffc0200126 <cprintf>
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201062:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201064:	4481                	li	s1,0
ffffffffc0201066:	4901                	li	s2,0
ffffffffc0201068:	b379                	j	ffffffffc0200df6 <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc020106a:	00002697          	auipc	a3,0x2
ffffffffc020106e:	94e68693          	addi	a3,a3,-1714 # ffffffffc02029b8 <commands+0x710>
ffffffffc0201072:	00002617          	auipc	a2,0x2
ffffffffc0201076:	91660613          	addi	a2,a2,-1770 # ffffffffc0202988 <commands+0x6e0>
ffffffffc020107a:	10900593          	li	a1,265
ffffffffc020107e:	00002517          	auipc	a0,0x2
ffffffffc0201082:	92250513          	addi	a0,a0,-1758 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc0201086:	b9aff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020108a:	00002697          	auipc	a3,0x2
ffffffffc020108e:	9be68693          	addi	a3,a3,-1602 # ffffffffc0202a48 <commands+0x7a0>
ffffffffc0201092:	00002617          	auipc	a2,0x2
ffffffffc0201096:	8f660613          	addi	a2,a2,-1802 # ffffffffc0202988 <commands+0x6e0>
ffffffffc020109a:	0d500593          	li	a1,213
ffffffffc020109e:	00002517          	auipc	a0,0x2
ffffffffc02010a2:	90250513          	addi	a0,a0,-1790 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc02010a6:	b7aff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02010aa:	00002697          	auipc	a3,0x2
ffffffffc02010ae:	9c668693          	addi	a3,a3,-1594 # ffffffffc0202a70 <commands+0x7c8>
ffffffffc02010b2:	00002617          	auipc	a2,0x2
ffffffffc02010b6:	8d660613          	addi	a2,a2,-1834 # ffffffffc0202988 <commands+0x6e0>
ffffffffc02010ba:	0d600593          	li	a1,214
ffffffffc02010be:	00002517          	auipc	a0,0x2
ffffffffc02010c2:	8e250513          	addi	a0,a0,-1822 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc02010c6:	b5aff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02010ca:	00002697          	auipc	a3,0x2
ffffffffc02010ce:	9e668693          	addi	a3,a3,-1562 # ffffffffc0202ab0 <commands+0x808>
ffffffffc02010d2:	00002617          	auipc	a2,0x2
ffffffffc02010d6:	8b660613          	addi	a2,a2,-1866 # ffffffffc0202988 <commands+0x6e0>
ffffffffc02010da:	0d800593          	li	a1,216
ffffffffc02010de:	00002517          	auipc	a0,0x2
ffffffffc02010e2:	8c250513          	addi	a0,a0,-1854 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc02010e6:	b3aff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(!list_empty(&free_list));
ffffffffc02010ea:	00002697          	auipc	a3,0x2
ffffffffc02010ee:	a4e68693          	addi	a3,a3,-1458 # ffffffffc0202b38 <commands+0x890>
ffffffffc02010f2:	00002617          	auipc	a2,0x2
ffffffffc02010f6:	89660613          	addi	a2,a2,-1898 # ffffffffc0202988 <commands+0x6e0>
ffffffffc02010fa:	0f100593          	li	a1,241
ffffffffc02010fe:	00002517          	auipc	a0,0x2
ffffffffc0201102:	8a250513          	addi	a0,a0,-1886 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc0201106:	b1aff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020110a:	00002697          	auipc	a3,0x2
ffffffffc020110e:	91e68693          	addi	a3,a3,-1762 # ffffffffc0202a28 <commands+0x780>
ffffffffc0201112:	00002617          	auipc	a2,0x2
ffffffffc0201116:	87660613          	addi	a2,a2,-1930 # ffffffffc0202988 <commands+0x6e0>
ffffffffc020111a:	0d300593          	li	a1,211
ffffffffc020111e:	00002517          	auipc	a0,0x2
ffffffffc0201122:	88250513          	addi	a0,a0,-1918 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc0201126:	afaff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(total == 0);
ffffffffc020112a:	00002697          	auipc	a3,0x2
ffffffffc020112e:	b3e68693          	addi	a3,a3,-1218 # ffffffffc0202c68 <commands+0x9c0>
ffffffffc0201132:	00002617          	auipc	a2,0x2
ffffffffc0201136:	85660613          	addi	a2,a2,-1962 # ffffffffc0202988 <commands+0x6e0>
ffffffffc020113a:	14b00593          	li	a1,331
ffffffffc020113e:	00002517          	auipc	a0,0x2
ffffffffc0201142:	86250513          	addi	a0,a0,-1950 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc0201146:	adaff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(total == nr_free_pages());
ffffffffc020114a:	00002697          	auipc	a3,0x2
ffffffffc020114e:	87e68693          	addi	a3,a3,-1922 # ffffffffc02029c8 <commands+0x720>
ffffffffc0201152:	00002617          	auipc	a2,0x2
ffffffffc0201156:	83660613          	addi	a2,a2,-1994 # ffffffffc0202988 <commands+0x6e0>
ffffffffc020115a:	10c00593          	li	a1,268
ffffffffc020115e:	00002517          	auipc	a0,0x2
ffffffffc0201162:	84250513          	addi	a0,a0,-1982 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc0201166:	abaff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020116a:	00002697          	auipc	a3,0x2
ffffffffc020116e:	89e68693          	addi	a3,a3,-1890 # ffffffffc0202a08 <commands+0x760>
ffffffffc0201172:	00002617          	auipc	a2,0x2
ffffffffc0201176:	81660613          	addi	a2,a2,-2026 # ffffffffc0202988 <commands+0x6e0>
ffffffffc020117a:	0d200593          	li	a1,210
ffffffffc020117e:	00002517          	auipc	a0,0x2
ffffffffc0201182:	82250513          	addi	a0,a0,-2014 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc0201186:	a9aff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020118a:	00002697          	auipc	a3,0x2
ffffffffc020118e:	85e68693          	addi	a3,a3,-1954 # ffffffffc02029e8 <commands+0x740>
ffffffffc0201192:	00001617          	auipc	a2,0x1
ffffffffc0201196:	7f660613          	addi	a2,a2,2038 # ffffffffc0202988 <commands+0x6e0>
ffffffffc020119a:	0d100593          	li	a1,209
ffffffffc020119e:	00002517          	auipc	a0,0x2
ffffffffc02011a2:	80250513          	addi	a0,a0,-2046 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc02011a6:	a7aff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011aa:	00002697          	auipc	a3,0x2
ffffffffc02011ae:	96668693          	addi	a3,a3,-1690 # ffffffffc0202b10 <commands+0x868>
ffffffffc02011b2:	00001617          	auipc	a2,0x1
ffffffffc02011b6:	7d660613          	addi	a2,a2,2006 # ffffffffc0202988 <commands+0x6e0>
ffffffffc02011ba:	0ee00593          	li	a1,238
ffffffffc02011be:	00001517          	auipc	a0,0x1
ffffffffc02011c2:	7e250513          	addi	a0,a0,2018 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc02011c6:	a5aff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02011ca:	00002697          	auipc	a3,0x2
ffffffffc02011ce:	85e68693          	addi	a3,a3,-1954 # ffffffffc0202a28 <commands+0x780>
ffffffffc02011d2:	00001617          	auipc	a2,0x1
ffffffffc02011d6:	7b660613          	addi	a2,a2,1974 # ffffffffc0202988 <commands+0x6e0>
ffffffffc02011da:	0ec00593          	li	a1,236
ffffffffc02011de:	00001517          	auipc	a0,0x1
ffffffffc02011e2:	7c250513          	addi	a0,a0,1986 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc02011e6:	a3aff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02011ea:	00002697          	auipc	a3,0x2
ffffffffc02011ee:	81e68693          	addi	a3,a3,-2018 # ffffffffc0202a08 <commands+0x760>
ffffffffc02011f2:	00001617          	auipc	a2,0x1
ffffffffc02011f6:	79660613          	addi	a2,a2,1942 # ffffffffc0202988 <commands+0x6e0>
ffffffffc02011fa:	0eb00593          	li	a1,235
ffffffffc02011fe:	00001517          	auipc	a0,0x1
ffffffffc0201202:	7a250513          	addi	a0,a0,1954 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc0201206:	a1aff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020120a:	00001697          	auipc	a3,0x1
ffffffffc020120e:	7de68693          	addi	a3,a3,2014 # ffffffffc02029e8 <commands+0x740>
ffffffffc0201212:	00001617          	auipc	a2,0x1
ffffffffc0201216:	77660613          	addi	a2,a2,1910 # ffffffffc0202988 <commands+0x6e0>
ffffffffc020121a:	0ea00593          	li	a1,234
ffffffffc020121e:	00001517          	auipc	a0,0x1
ffffffffc0201222:	78250513          	addi	a0,a0,1922 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc0201226:	9faff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(nr_free == 3);
ffffffffc020122a:	00002697          	auipc	a3,0x2
ffffffffc020122e:	8fe68693          	addi	a3,a3,-1794 # ffffffffc0202b28 <commands+0x880>
ffffffffc0201232:	00001617          	auipc	a2,0x1
ffffffffc0201236:	75660613          	addi	a2,a2,1878 # ffffffffc0202988 <commands+0x6e0>
ffffffffc020123a:	0e800593          	li	a1,232
ffffffffc020123e:	00001517          	auipc	a0,0x1
ffffffffc0201242:	76250513          	addi	a0,a0,1890 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc0201246:	9daff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020124a:	00002697          	auipc	a3,0x2
ffffffffc020124e:	8c668693          	addi	a3,a3,-1850 # ffffffffc0202b10 <commands+0x868>
ffffffffc0201252:	00001617          	auipc	a2,0x1
ffffffffc0201256:	73660613          	addi	a2,a2,1846 # ffffffffc0202988 <commands+0x6e0>
ffffffffc020125a:	0e300593          	li	a1,227
ffffffffc020125e:	00001517          	auipc	a0,0x1
ffffffffc0201262:	74250513          	addi	a0,a0,1858 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc0201266:	9baff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020126a:	00002697          	auipc	a3,0x2
ffffffffc020126e:	88668693          	addi	a3,a3,-1914 # ffffffffc0202af0 <commands+0x848>
ffffffffc0201272:	00001617          	auipc	a2,0x1
ffffffffc0201276:	71660613          	addi	a2,a2,1814 # ffffffffc0202988 <commands+0x6e0>
ffffffffc020127a:	0da00593          	li	a1,218
ffffffffc020127e:	00001517          	auipc	a0,0x1
ffffffffc0201282:	72250513          	addi	a0,a0,1826 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc0201286:	99aff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020128a:	00002697          	auipc	a3,0x2
ffffffffc020128e:	84668693          	addi	a3,a3,-1978 # ffffffffc0202ad0 <commands+0x828>
ffffffffc0201292:	00001617          	auipc	a2,0x1
ffffffffc0201296:	6f660613          	addi	a2,a2,1782 # ffffffffc0202988 <commands+0x6e0>
ffffffffc020129a:	0d900593          	li	a1,217
ffffffffc020129e:	00001517          	auipc	a0,0x1
ffffffffc02012a2:	70250513          	addi	a0,a0,1794 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc02012a6:	97aff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(count == 0);
ffffffffc02012aa:	00002697          	auipc	a3,0x2
ffffffffc02012ae:	9ae68693          	addi	a3,a3,-1618 # ffffffffc0202c58 <commands+0x9b0>
ffffffffc02012b2:	00001617          	auipc	a2,0x1
ffffffffc02012b6:	6d660613          	addi	a2,a2,1750 # ffffffffc0202988 <commands+0x6e0>
ffffffffc02012ba:	14a00593          	li	a1,330
ffffffffc02012be:	00001517          	auipc	a0,0x1
ffffffffc02012c2:	6e250513          	addi	a0,a0,1762 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc02012c6:	95aff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(nr_free == 0);
ffffffffc02012ca:	00002697          	auipc	a3,0x2
ffffffffc02012ce:	8a668693          	addi	a3,a3,-1882 # ffffffffc0202b70 <commands+0x8c8>
ffffffffc02012d2:	00001617          	auipc	a2,0x1
ffffffffc02012d6:	6b660613          	addi	a2,a2,1718 # ffffffffc0202988 <commands+0x6e0>
ffffffffc02012da:	13f00593          	li	a1,319
ffffffffc02012de:	00001517          	auipc	a0,0x1
ffffffffc02012e2:	6c250513          	addi	a0,a0,1730 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc02012e6:	93aff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012ea:	00002697          	auipc	a3,0x2
ffffffffc02012ee:	82668693          	addi	a3,a3,-2010 # ffffffffc0202b10 <commands+0x868>
ffffffffc02012f2:	00001617          	auipc	a2,0x1
ffffffffc02012f6:	69660613          	addi	a2,a2,1686 # ffffffffc0202988 <commands+0x6e0>
ffffffffc02012fa:	13900593          	li	a1,313
ffffffffc02012fe:	00001517          	auipc	a0,0x1
ffffffffc0201302:	6a250513          	addi	a0,a0,1698 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc0201306:	91aff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020130a:	00002697          	auipc	a3,0x2
ffffffffc020130e:	92e68693          	addi	a3,a3,-1746 # ffffffffc0202c38 <commands+0x990>
ffffffffc0201312:	00001617          	auipc	a2,0x1
ffffffffc0201316:	67660613          	addi	a2,a2,1654 # ffffffffc0202988 <commands+0x6e0>
ffffffffc020131a:	13800593          	li	a1,312
ffffffffc020131e:	00001517          	auipc	a0,0x1
ffffffffc0201322:	68250513          	addi	a0,a0,1666 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc0201326:	8faff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(p0 + 4 == p1);
ffffffffc020132a:	00002697          	auipc	a3,0x2
ffffffffc020132e:	8fe68693          	addi	a3,a3,-1794 # ffffffffc0202c28 <commands+0x980>
ffffffffc0201332:	00001617          	auipc	a2,0x1
ffffffffc0201336:	65660613          	addi	a2,a2,1622 # ffffffffc0202988 <commands+0x6e0>
ffffffffc020133a:	13000593          	li	a1,304
ffffffffc020133e:	00001517          	auipc	a0,0x1
ffffffffc0201342:	66250513          	addi	a0,a0,1634 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc0201346:	8daff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc020134a:	00002697          	auipc	a3,0x2
ffffffffc020134e:	8c668693          	addi	a3,a3,-1850 # ffffffffc0202c10 <commands+0x968>
ffffffffc0201352:	00001617          	auipc	a2,0x1
ffffffffc0201356:	63660613          	addi	a2,a2,1590 # ffffffffc0202988 <commands+0x6e0>
ffffffffc020135a:	12f00593          	li	a1,303
ffffffffc020135e:	00001517          	auipc	a0,0x1
ffffffffc0201362:	64250513          	addi	a0,a0,1602 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc0201366:	8baff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc020136a:	00002697          	auipc	a3,0x2
ffffffffc020136e:	88668693          	addi	a3,a3,-1914 # ffffffffc0202bf0 <commands+0x948>
ffffffffc0201372:	00001617          	auipc	a2,0x1
ffffffffc0201376:	61660613          	addi	a2,a2,1558 # ffffffffc0202988 <commands+0x6e0>
ffffffffc020137a:	12e00593          	li	a1,302
ffffffffc020137e:	00001517          	auipc	a0,0x1
ffffffffc0201382:	62250513          	addi	a0,a0,1570 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc0201386:	89aff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc020138a:	00002697          	auipc	a3,0x2
ffffffffc020138e:	83668693          	addi	a3,a3,-1994 # ffffffffc0202bc0 <commands+0x918>
ffffffffc0201392:	00001617          	auipc	a2,0x1
ffffffffc0201396:	5f660613          	addi	a2,a2,1526 # ffffffffc0202988 <commands+0x6e0>
ffffffffc020139a:	12c00593          	li	a1,300
ffffffffc020139e:	00001517          	auipc	a0,0x1
ffffffffc02013a2:	60250513          	addi	a0,a0,1538 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc02013a6:	87aff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02013aa:	00001697          	auipc	a3,0x1
ffffffffc02013ae:	7fe68693          	addi	a3,a3,2046 # ffffffffc0202ba8 <commands+0x900>
ffffffffc02013b2:	00001617          	auipc	a2,0x1
ffffffffc02013b6:	5d660613          	addi	a2,a2,1494 # ffffffffc0202988 <commands+0x6e0>
ffffffffc02013ba:	12b00593          	li	a1,299
ffffffffc02013be:	00001517          	auipc	a0,0x1
ffffffffc02013c2:	5e250513          	addi	a0,a0,1506 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc02013c6:	85aff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013ca:	00001697          	auipc	a3,0x1
ffffffffc02013ce:	74668693          	addi	a3,a3,1862 # ffffffffc0202b10 <commands+0x868>
ffffffffc02013d2:	00001617          	auipc	a2,0x1
ffffffffc02013d6:	5b660613          	addi	a2,a2,1462 # ffffffffc0202988 <commands+0x6e0>
ffffffffc02013da:	11f00593          	li	a1,287
ffffffffc02013de:	00001517          	auipc	a0,0x1
ffffffffc02013e2:	5c250513          	addi	a0,a0,1474 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc02013e6:	83aff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(!PageProperty(p0));
ffffffffc02013ea:	00001697          	auipc	a3,0x1
ffffffffc02013ee:	7a668693          	addi	a3,a3,1958 # ffffffffc0202b90 <commands+0x8e8>
ffffffffc02013f2:	00001617          	auipc	a2,0x1
ffffffffc02013f6:	59660613          	addi	a2,a2,1430 # ffffffffc0202988 <commands+0x6e0>
ffffffffc02013fa:	11600593          	li	a1,278
ffffffffc02013fe:	00001517          	auipc	a0,0x1
ffffffffc0201402:	5a250513          	addi	a0,a0,1442 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc0201406:	81aff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(p0 != NULL);
ffffffffc020140a:	00001697          	auipc	a3,0x1
ffffffffc020140e:	77668693          	addi	a3,a3,1910 # ffffffffc0202b80 <commands+0x8d8>
ffffffffc0201412:	00001617          	auipc	a2,0x1
ffffffffc0201416:	57660613          	addi	a2,a2,1398 # ffffffffc0202988 <commands+0x6e0>
ffffffffc020141a:	11500593          	li	a1,277
ffffffffc020141e:	00001517          	auipc	a0,0x1
ffffffffc0201422:	58250513          	addi	a0,a0,1410 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc0201426:	ffbfe0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(nr_free == 0);
ffffffffc020142a:	00001697          	auipc	a3,0x1
ffffffffc020142e:	74668693          	addi	a3,a3,1862 # ffffffffc0202b70 <commands+0x8c8>
ffffffffc0201432:	00001617          	auipc	a2,0x1
ffffffffc0201436:	55660613          	addi	a2,a2,1366 # ffffffffc0202988 <commands+0x6e0>
ffffffffc020143a:	0f700593          	li	a1,247
ffffffffc020143e:	00001517          	auipc	a0,0x1
ffffffffc0201442:	56250513          	addi	a0,a0,1378 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc0201446:	fdbfe0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020144a:	00001697          	auipc	a3,0x1
ffffffffc020144e:	6c668693          	addi	a3,a3,1734 # ffffffffc0202b10 <commands+0x868>
ffffffffc0201452:	00001617          	auipc	a2,0x1
ffffffffc0201456:	53660613          	addi	a2,a2,1334 # ffffffffc0202988 <commands+0x6e0>
ffffffffc020145a:	0f500593          	li	a1,245
ffffffffc020145e:	00001517          	auipc	a0,0x1
ffffffffc0201462:	54250513          	addi	a0,a0,1346 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc0201466:	fbbfe0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020146a:	00001697          	auipc	a3,0x1
ffffffffc020146e:	6e668693          	addi	a3,a3,1766 # ffffffffc0202b50 <commands+0x8a8>
ffffffffc0201472:	00001617          	auipc	a2,0x1
ffffffffc0201476:	51660613          	addi	a2,a2,1302 # ffffffffc0202988 <commands+0x6e0>
ffffffffc020147a:	0f400593          	li	a1,244
ffffffffc020147e:	00001517          	auipc	a0,0x1
ffffffffc0201482:	52250513          	addi	a0,a0,1314 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc0201486:	f9bfe0ef          	jal	ra,ffffffffc0200420 <__panic>

ffffffffc020148a <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc020148a:	1141                	addi	sp,sp,-16
ffffffffc020148c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020148e:	14058a63          	beqz	a1,ffffffffc02015e2 <best_fit_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0201492:	00259693          	slli	a3,a1,0x2
ffffffffc0201496:	96ae                	add	a3,a3,a1
ffffffffc0201498:	068e                	slli	a3,a3,0x3
ffffffffc020149a:	96aa                	add	a3,a3,a0
ffffffffc020149c:	87aa                	mv	a5,a0
ffffffffc020149e:	02d50263          	beq	a0,a3,ffffffffc02014c2 <best_fit_free_pages+0x38>
ffffffffc02014a2:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02014a4:	8b05                	andi	a4,a4,1
ffffffffc02014a6:	10071e63          	bnez	a4,ffffffffc02015c2 <best_fit_free_pages+0x138>
ffffffffc02014aa:	6798                	ld	a4,8(a5)
ffffffffc02014ac:	8b09                	andi	a4,a4,2
ffffffffc02014ae:	10071a63          	bnez	a4,ffffffffc02015c2 <best_fit_free_pages+0x138>
        p->flags = 0;
ffffffffc02014b2:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02014b6:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02014ba:	02878793          	addi	a5,a5,40
ffffffffc02014be:	fed792e3          	bne	a5,a3,ffffffffc02014a2 <best_fit_free_pages+0x18>
    base->property = n;
ffffffffc02014c2:	2581                	sext.w	a1,a1
ffffffffc02014c4:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02014c6:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02014ca:	4789                	li	a5,2
ffffffffc02014cc:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02014d0:	00006697          	auipc	a3,0x6
ffffffffc02014d4:	b5868693          	addi	a3,a3,-1192 # ffffffffc0207028 <free_area>
ffffffffc02014d8:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02014da:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02014dc:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02014e0:	9db9                	addw	a1,a1,a4
ffffffffc02014e2:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02014e4:	0ad78863          	beq	a5,a3,ffffffffc0201594 <best_fit_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc02014e8:	fe878713          	addi	a4,a5,-24
ffffffffc02014ec:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02014f0:	4581                	li	a1,0
            if (base < page) {
ffffffffc02014f2:	00e56a63          	bltu	a0,a4,ffffffffc0201506 <best_fit_free_pages+0x7c>
    return listelm->next;
ffffffffc02014f6:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02014f8:	06d70263          	beq	a4,a3,ffffffffc020155c <best_fit_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc02014fc:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02014fe:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201502:	fee57ae3          	bgeu	a0,a4,ffffffffc02014f6 <best_fit_free_pages+0x6c>
ffffffffc0201506:	c199                	beqz	a1,ffffffffc020150c <best_fit_free_pages+0x82>
ffffffffc0201508:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020150c:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc020150e:	e390                	sd	a2,0(a5)
ffffffffc0201510:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201512:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201514:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0201516:	02d70063          	beq	a4,a3,ffffffffc0201536 <best_fit_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc020151a:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc020151e:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {
ffffffffc0201522:	02081613          	slli	a2,a6,0x20
ffffffffc0201526:	9201                	srli	a2,a2,0x20
ffffffffc0201528:	00261793          	slli	a5,a2,0x2
ffffffffc020152c:	97b2                	add	a5,a5,a2
ffffffffc020152e:	078e                	slli	a5,a5,0x3
ffffffffc0201530:	97ae                	add	a5,a5,a1
ffffffffc0201532:	02f50f63          	beq	a0,a5,ffffffffc0201570 <best_fit_free_pages+0xe6>
    return listelm->next;
ffffffffc0201536:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc0201538:	00d70f63          	beq	a4,a3,ffffffffc0201556 <best_fit_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc020153c:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc020153e:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc0201542:	02059613          	slli	a2,a1,0x20
ffffffffc0201546:	9201                	srli	a2,a2,0x20
ffffffffc0201548:	00261793          	slli	a5,a2,0x2
ffffffffc020154c:	97b2                	add	a5,a5,a2
ffffffffc020154e:	078e                	slli	a5,a5,0x3
ffffffffc0201550:	97aa                	add	a5,a5,a0
ffffffffc0201552:	04f68863          	beq	a3,a5,ffffffffc02015a2 <best_fit_free_pages+0x118>
}
ffffffffc0201556:	60a2                	ld	ra,8(sp)
ffffffffc0201558:	0141                	addi	sp,sp,16
ffffffffc020155a:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020155c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020155e:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201560:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201562:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201564:	02d70563          	beq	a4,a3,ffffffffc020158e <best_fit_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0201568:	8832                	mv	a6,a2
ffffffffc020156a:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020156c:	87ba                	mv	a5,a4
ffffffffc020156e:	bf41                	j	ffffffffc02014fe <best_fit_free_pages+0x74>
            p->property += base->property;
ffffffffc0201570:	491c                	lw	a5,16(a0)
ffffffffc0201572:	0107883b          	addw	a6,a5,a6
ffffffffc0201576:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020157a:	57f5                	li	a5,-3
ffffffffc020157c:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201580:	6d10                	ld	a2,24(a0)
ffffffffc0201582:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc0201584:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc0201586:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0201588:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc020158a:	e390                	sd	a2,0(a5)
ffffffffc020158c:	b775                	j	ffffffffc0201538 <best_fit_free_pages+0xae>
ffffffffc020158e:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201590:	873e                	mv	a4,a5
ffffffffc0201592:	b761                	j	ffffffffc020151a <best_fit_free_pages+0x90>
}
ffffffffc0201594:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201596:	e390                	sd	a2,0(a5)
ffffffffc0201598:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020159a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020159c:	ed1c                	sd	a5,24(a0)
ffffffffc020159e:	0141                	addi	sp,sp,16
ffffffffc02015a0:	8082                	ret
            base->property += p->property;
ffffffffc02015a2:	ff872783          	lw	a5,-8(a4)
ffffffffc02015a6:	ff070693          	addi	a3,a4,-16
ffffffffc02015aa:	9dbd                	addw	a1,a1,a5
ffffffffc02015ac:	c90c                	sw	a1,16(a0)
ffffffffc02015ae:	57f5                	li	a5,-3
ffffffffc02015b0:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02015b4:	6314                	ld	a3,0(a4)
ffffffffc02015b6:	671c                	ld	a5,8(a4)
}
ffffffffc02015b8:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02015ba:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02015bc:	e394                	sd	a3,0(a5)
ffffffffc02015be:	0141                	addi	sp,sp,16
ffffffffc02015c0:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02015c2:	00001697          	auipc	a3,0x1
ffffffffc02015c6:	71668693          	addi	a3,a3,1814 # ffffffffc0202cd8 <commands+0xa30>
ffffffffc02015ca:	00001617          	auipc	a2,0x1
ffffffffc02015ce:	3be60613          	addi	a2,a2,958 # ffffffffc0202988 <commands+0x6e0>
ffffffffc02015d2:	09100593          	li	a1,145
ffffffffc02015d6:	00001517          	auipc	a0,0x1
ffffffffc02015da:	3ca50513          	addi	a0,a0,970 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc02015de:	e43fe0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(n > 0);
ffffffffc02015e2:	00001697          	auipc	a3,0x1
ffffffffc02015e6:	39e68693          	addi	a3,a3,926 # ffffffffc0202980 <commands+0x6d8>
ffffffffc02015ea:	00001617          	auipc	a2,0x1
ffffffffc02015ee:	39e60613          	addi	a2,a2,926 # ffffffffc0202988 <commands+0x6e0>
ffffffffc02015f2:	08e00593          	li	a1,142
ffffffffc02015f6:	00001517          	auipc	a0,0x1
ffffffffc02015fa:	3aa50513          	addi	a0,a0,938 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc02015fe:	e23fe0ef          	jal	ra,ffffffffc0200420 <__panic>

ffffffffc0201602 <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc0201602:	1141                	addi	sp,sp,-16
ffffffffc0201604:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201606:	c9e1                	beqz	a1,ffffffffc02016d6 <best_fit_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0201608:	00259693          	slli	a3,a1,0x2
ffffffffc020160c:	96ae                	add	a3,a3,a1
ffffffffc020160e:	068e                	slli	a3,a3,0x3
ffffffffc0201610:	96aa                	add	a3,a3,a0
ffffffffc0201612:	87aa                	mv	a5,a0
ffffffffc0201614:	00d50f63          	beq	a0,a3,ffffffffc0201632 <best_fit_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201618:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc020161a:	8b05                	andi	a4,a4,1
ffffffffc020161c:	cf49                	beqz	a4,ffffffffc02016b6 <best_fit_init_memmap+0xb4>
        p->flags = p->property = 0;//表示这些页暂时没有特殊属性，也不是空闲页块
ffffffffc020161e:	0007a823          	sw	zero,16(a5)
ffffffffc0201622:	0007b423          	sd	zero,8(a5)
ffffffffc0201626:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020162a:	02878793          	addi	a5,a5,40
ffffffffc020162e:	fed795e3          	bne	a5,a3,ffffffffc0201618 <best_fit_init_memmap+0x16>
    base->property = n;
ffffffffc0201632:	2581                	sext.w	a1,a1
ffffffffc0201634:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201636:	4789                	li	a5,2
ffffffffc0201638:	00850713          	addi	a4,a0,8
ffffffffc020163c:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201640:	00006697          	auipc	a3,0x6
ffffffffc0201644:	9e868693          	addi	a3,a3,-1560 # ffffffffc0207028 <free_area>
ffffffffc0201648:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020164a:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020164c:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201650:	9db9                	addw	a1,a1,a4
ffffffffc0201652:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201654:	04d78a63          	beq	a5,a3,ffffffffc02016a8 <best_fit_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc0201658:	fe878713          	addi	a4,a5,-24
ffffffffc020165c:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201660:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201662:	00e56a63          	bltu	a0,a4,ffffffffc0201676 <best_fit_init_memmap+0x74>
    return listelm->next;
ffffffffc0201666:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201668:	02d70263          	beq	a4,a3,ffffffffc020168c <best_fit_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc020166c:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020166e:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201672:	fee57ae3          	bgeu	a0,a4,ffffffffc0201666 <best_fit_init_memmap+0x64>
ffffffffc0201676:	c199                	beqz	a1,ffffffffc020167c <best_fit_init_memmap+0x7a>
ffffffffc0201678:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020167c:	6398                	ld	a4,0(a5)
}
ffffffffc020167e:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201680:	e390                	sd	a2,0(a5)
ffffffffc0201682:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201684:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201686:	ed18                	sd	a4,24(a0)
ffffffffc0201688:	0141                	addi	sp,sp,16
ffffffffc020168a:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020168c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020168e:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201690:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201692:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201694:	00d70663          	beq	a4,a3,ffffffffc02016a0 <best_fit_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc0201698:	8832                	mv	a6,a2
ffffffffc020169a:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020169c:	87ba                	mv	a5,a4
ffffffffc020169e:	bfc1                	j	ffffffffc020166e <best_fit_init_memmap+0x6c>
}
ffffffffc02016a0:	60a2                	ld	ra,8(sp)
ffffffffc02016a2:	e290                	sd	a2,0(a3)
ffffffffc02016a4:	0141                	addi	sp,sp,16
ffffffffc02016a6:	8082                	ret
ffffffffc02016a8:	60a2                	ld	ra,8(sp)
ffffffffc02016aa:	e390                	sd	a2,0(a5)
ffffffffc02016ac:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02016ae:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016b0:	ed1c                	sd	a5,24(a0)
ffffffffc02016b2:	0141                	addi	sp,sp,16
ffffffffc02016b4:	8082                	ret
        assert(PageReserved(p));
ffffffffc02016b6:	00001697          	auipc	a3,0x1
ffffffffc02016ba:	64a68693          	addi	a3,a3,1610 # ffffffffc0202d00 <commands+0xa58>
ffffffffc02016be:	00001617          	auipc	a2,0x1
ffffffffc02016c2:	2ca60613          	addi	a2,a2,714 # ffffffffc0202988 <commands+0x6e0>
ffffffffc02016c6:	04a00593          	li	a1,74
ffffffffc02016ca:	00001517          	auipc	a0,0x1
ffffffffc02016ce:	2d650513          	addi	a0,a0,726 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc02016d2:	d4ffe0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(n > 0);
ffffffffc02016d6:	00001697          	auipc	a3,0x1
ffffffffc02016da:	2aa68693          	addi	a3,a3,682 # ffffffffc0202980 <commands+0x6d8>
ffffffffc02016de:	00001617          	auipc	a2,0x1
ffffffffc02016e2:	2aa60613          	addi	a2,a2,682 # ffffffffc0202988 <commands+0x6e0>
ffffffffc02016e6:	04700593          	li	a1,71
ffffffffc02016ea:	00001517          	auipc	a0,0x1
ffffffffc02016ee:	2b650513          	addi	a0,a0,694 # ffffffffc02029a0 <commands+0x6f8>
ffffffffc02016f2:	d2ffe0ef          	jal	ra,ffffffffc0200420 <__panic>

ffffffffc02016f6 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016f6:	100027f3          	csrr	a5,sstatus
ffffffffc02016fa:	8b89                	andi	a5,a5,2
ffffffffc02016fc:	e799                	bnez	a5,ffffffffc020170a <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02016fe:	00006797          	auipc	a5,0x6
ffffffffc0201702:	d7a7b783          	ld	a5,-646(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc0201706:	6f9c                	ld	a5,24(a5)
ffffffffc0201708:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc020170a:	1141                	addi	sp,sp,-16
ffffffffc020170c:	e406                	sd	ra,8(sp)
ffffffffc020170e:	e022                	sd	s0,0(sp)
ffffffffc0201710:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201712:	970ff0ef          	jal	ra,ffffffffc0200882 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201716:	00006797          	auipc	a5,0x6
ffffffffc020171a:	d627b783          	ld	a5,-670(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc020171e:	6f9c                	ld	a5,24(a5)
ffffffffc0201720:	8522                	mv	a0,s0
ffffffffc0201722:	9782                	jalr	a5
ffffffffc0201724:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0201726:	956ff0ef          	jal	ra,ffffffffc020087c <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc020172a:	60a2                	ld	ra,8(sp)
ffffffffc020172c:	8522                	mv	a0,s0
ffffffffc020172e:	6402                	ld	s0,0(sp)
ffffffffc0201730:	0141                	addi	sp,sp,16
ffffffffc0201732:	8082                	ret

ffffffffc0201734 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201734:	100027f3          	csrr	a5,sstatus
ffffffffc0201738:	8b89                	andi	a5,a5,2
ffffffffc020173a:	e799                	bnez	a5,ffffffffc0201748 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc020173c:	00006797          	auipc	a5,0x6
ffffffffc0201740:	d3c7b783          	ld	a5,-708(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc0201744:	739c                	ld	a5,32(a5)
ffffffffc0201746:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201748:	1101                	addi	sp,sp,-32
ffffffffc020174a:	ec06                	sd	ra,24(sp)
ffffffffc020174c:	e822                	sd	s0,16(sp)
ffffffffc020174e:	e426                	sd	s1,8(sp)
ffffffffc0201750:	842a                	mv	s0,a0
ffffffffc0201752:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201754:	92eff0ef          	jal	ra,ffffffffc0200882 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201758:	00006797          	auipc	a5,0x6
ffffffffc020175c:	d207b783          	ld	a5,-736(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc0201760:	739c                	ld	a5,32(a5)
ffffffffc0201762:	85a6                	mv	a1,s1
ffffffffc0201764:	8522                	mv	a0,s0
ffffffffc0201766:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201768:	6442                	ld	s0,16(sp)
ffffffffc020176a:	60e2                	ld	ra,24(sp)
ffffffffc020176c:	64a2                	ld	s1,8(sp)
ffffffffc020176e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201770:	90cff06f          	j	ffffffffc020087c <intr_enable>

ffffffffc0201774 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201774:	100027f3          	csrr	a5,sstatus
ffffffffc0201778:	8b89                	andi	a5,a5,2
ffffffffc020177a:	e799                	bnez	a5,ffffffffc0201788 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc020177c:	00006797          	auipc	a5,0x6
ffffffffc0201780:	cfc7b783          	ld	a5,-772(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc0201784:	779c                	ld	a5,40(a5)
ffffffffc0201786:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201788:	1141                	addi	sp,sp,-16
ffffffffc020178a:	e406                	sd	ra,8(sp)
ffffffffc020178c:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020178e:	8f4ff0ef          	jal	ra,ffffffffc0200882 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201792:	00006797          	auipc	a5,0x6
ffffffffc0201796:	ce67b783          	ld	a5,-794(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc020179a:	779c                	ld	a5,40(a5)
ffffffffc020179c:	9782                	jalr	a5
ffffffffc020179e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02017a0:	8dcff0ef          	jal	ra,ffffffffc020087c <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02017a4:	60a2                	ld	ra,8(sp)
ffffffffc02017a6:	8522                	mv	a0,s0
ffffffffc02017a8:	6402                	ld	s0,0(sp)
ffffffffc02017aa:	0141                	addi	sp,sp,16
ffffffffc02017ac:	8082                	ret

ffffffffc02017ae <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02017ae:	00001797          	auipc	a5,0x1
ffffffffc02017b2:	57a78793          	addi	a5,a5,1402 # ffffffffc0202d28 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02017b6:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02017b8:	7179                	addi	sp,sp,-48
ffffffffc02017ba:	f022                	sd	s0,32(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02017bc:	00001517          	auipc	a0,0x1
ffffffffc02017c0:	5a450513          	addi	a0,a0,1444 # ffffffffc0202d60 <best_fit_pmm_manager+0x38>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02017c4:	00006417          	auipc	s0,0x6
ffffffffc02017c8:	cb440413          	addi	s0,s0,-844 # ffffffffc0207478 <pmm_manager>
void pmm_init(void) {
ffffffffc02017cc:	f406                	sd	ra,40(sp)
ffffffffc02017ce:	ec26                	sd	s1,24(sp)
ffffffffc02017d0:	e44e                	sd	s3,8(sp)
ffffffffc02017d2:	e84a                	sd	s2,16(sp)
ffffffffc02017d4:	e052                	sd	s4,0(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02017d6:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02017d8:	94ffe0ef          	jal	ra,ffffffffc0200126 <cprintf>
    pmm_manager->init();
ffffffffc02017dc:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02017de:	00006497          	auipc	s1,0x6
ffffffffc02017e2:	cb248493          	addi	s1,s1,-846 # ffffffffc0207490 <va_pa_offset>
    pmm_manager->init();
ffffffffc02017e6:	679c                	ld	a5,8(a5)
ffffffffc02017e8:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02017ea:	57f5                	li	a5,-3
ffffffffc02017ec:	07fa                	slli	a5,a5,0x1e
ffffffffc02017ee:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();
ffffffffc02017f0:	878ff0ef          	jal	ra,ffffffffc0200868 <get_memory_base>
ffffffffc02017f4:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc02017f6:	87cff0ef          	jal	ra,ffffffffc0200872 <get_memory_size>
    if (mem_size == 0) {
ffffffffc02017fa:	16050163          	beqz	a0,ffffffffc020195c <pmm_init+0x1ae>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc02017fe:	892a                	mv	s2,a0
    cprintf("physcial memory map:\n");
ffffffffc0201800:	00001517          	auipc	a0,0x1
ffffffffc0201804:	5a850513          	addi	a0,a0,1448 # ffffffffc0202da8 <best_fit_pmm_manager+0x80>
ffffffffc0201808:	91ffe0ef          	jal	ra,ffffffffc0200126 <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc020180c:	01298a33          	add	s4,s3,s2
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201810:	864e                	mv	a2,s3
ffffffffc0201812:	fffa0693          	addi	a3,s4,-1
ffffffffc0201816:	85ca                	mv	a1,s2
ffffffffc0201818:	00001517          	auipc	a0,0x1
ffffffffc020181c:	5a850513          	addi	a0,a0,1448 # ffffffffc0202dc0 <best_fit_pmm_manager+0x98>
ffffffffc0201820:	907fe0ef          	jal	ra,ffffffffc0200126 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0201824:	c80007b7          	lui	a5,0xc8000
ffffffffc0201828:	8652                	mv	a2,s4
ffffffffc020182a:	0d47e863          	bltu	a5,s4,ffffffffc02018fa <pmm_init+0x14c>
ffffffffc020182e:	00007797          	auipc	a5,0x7
ffffffffc0201832:	c7178793          	addi	a5,a5,-911 # ffffffffc020849f <end+0xfff>
ffffffffc0201836:	757d                	lui	a0,0xfffff
ffffffffc0201838:	8d7d                	and	a0,a0,a5
ffffffffc020183a:	8231                	srli	a2,a2,0xc
ffffffffc020183c:	00006597          	auipc	a1,0x6
ffffffffc0201840:	c2c58593          	addi	a1,a1,-980 # ffffffffc0207468 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201844:	00006817          	auipc	a6,0x6
ffffffffc0201848:	c2c80813          	addi	a6,a6,-980 # ffffffffc0207470 <pages>
    npage = maxpa / PGSIZE;
ffffffffc020184c:	e190                	sd	a2,0(a1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020184e:	00a83023          	sd	a0,0(a6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201852:	000807b7          	lui	a5,0x80
ffffffffc0201856:	02f60663          	beq	a2,a5,ffffffffc0201882 <pmm_init+0xd4>
ffffffffc020185a:	4701                	li	a4,0
ffffffffc020185c:	4781                	li	a5,0
ffffffffc020185e:	4305                	li	t1,1
ffffffffc0201860:	fff808b7          	lui	a7,0xfff80
        SetPageReserved(pages + i);
ffffffffc0201864:	953a                	add	a0,a0,a4
ffffffffc0201866:	00850693          	addi	a3,a0,8 # fffffffffffff008 <end+0x3fdf7b68>
ffffffffc020186a:	4066b02f          	amoor.d	zero,t1,(a3)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020186e:	6190                	ld	a2,0(a1)
ffffffffc0201870:	0785                	addi	a5,a5,1
        SetPageReserved(pages + i);
ffffffffc0201872:	00083503          	ld	a0,0(a6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201876:	011606b3          	add	a3,a2,a7
ffffffffc020187a:	02870713          	addi	a4,a4,40
ffffffffc020187e:	fed7e3e3          	bltu	a5,a3,ffffffffc0201864 <pmm_init+0xb6>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201882:	00261693          	slli	a3,a2,0x2
ffffffffc0201886:	96b2                	add	a3,a3,a2
ffffffffc0201888:	fec007b7          	lui	a5,0xfec00
ffffffffc020188c:	97aa                	add	a5,a5,a0
ffffffffc020188e:	068e                	slli	a3,a3,0x3
ffffffffc0201890:	96be                	add	a3,a3,a5
ffffffffc0201892:	c02007b7          	lui	a5,0xc0200
ffffffffc0201896:	0af6e763          	bltu	a3,a5,ffffffffc0201944 <pmm_init+0x196>
ffffffffc020189a:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc020189c:	77fd                	lui	a5,0xfffff
ffffffffc020189e:	00fa75b3          	and	a1,s4,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02018a2:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02018a4:	04b6ee63          	bltu	a3,a1,ffffffffc0201900 <pmm_init+0x152>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02018a8:	601c                	ld	a5,0(s0)
ffffffffc02018aa:	7b9c                	ld	a5,48(a5)
ffffffffc02018ac:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02018ae:	00001517          	auipc	a0,0x1
ffffffffc02018b2:	59a50513          	addi	a0,a0,1434 # ffffffffc0202e48 <best_fit_pmm_manager+0x120>
ffffffffc02018b6:	871fe0ef          	jal	ra,ffffffffc0200126 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02018ba:	00004597          	auipc	a1,0x4
ffffffffc02018be:	74658593          	addi	a1,a1,1862 # ffffffffc0206000 <boot_page_table_sv39>
ffffffffc02018c2:	00006797          	auipc	a5,0x6
ffffffffc02018c6:	bcb7b323          	sd	a1,-1082(a5) # ffffffffc0207488 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02018ca:	c02007b7          	lui	a5,0xc0200
ffffffffc02018ce:	0af5e363          	bltu	a1,a5,ffffffffc0201974 <pmm_init+0x1c6>
ffffffffc02018d2:	6090                	ld	a2,0(s1)
}
ffffffffc02018d4:	7402                	ld	s0,32(sp)
ffffffffc02018d6:	70a2                	ld	ra,40(sp)
ffffffffc02018d8:	64e2                	ld	s1,24(sp)
ffffffffc02018da:	6942                	ld	s2,16(sp)
ffffffffc02018dc:	69a2                	ld	s3,8(sp)
ffffffffc02018de:	6a02                	ld	s4,0(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02018e0:	40c58633          	sub	a2,a1,a2
ffffffffc02018e4:	00006797          	auipc	a5,0x6
ffffffffc02018e8:	b8c7be23          	sd	a2,-1124(a5) # ffffffffc0207480 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02018ec:	00001517          	auipc	a0,0x1
ffffffffc02018f0:	57c50513          	addi	a0,a0,1404 # ffffffffc0202e68 <best_fit_pmm_manager+0x140>
}
ffffffffc02018f4:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02018f6:	831fe06f          	j	ffffffffc0200126 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc02018fa:	c8000637          	lui	a2,0xc8000
ffffffffc02018fe:	bf05                	j	ffffffffc020182e <pmm_init+0x80>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201900:	6705                	lui	a4,0x1
ffffffffc0201902:	177d                	addi	a4,a4,-1
ffffffffc0201904:	96ba                	add	a3,a3,a4
ffffffffc0201906:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201908:	00c6d793          	srli	a5,a3,0xc
ffffffffc020190c:	02c7f063          	bgeu	a5,a2,ffffffffc020192c <pmm_init+0x17e>
    pmm_manager->init_memmap(base, n);
ffffffffc0201910:	6010                	ld	a2,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201912:	fff80737          	lui	a4,0xfff80
ffffffffc0201916:	973e                	add	a4,a4,a5
ffffffffc0201918:	00271793          	slli	a5,a4,0x2
ffffffffc020191c:	97ba                	add	a5,a5,a4
ffffffffc020191e:	6a18                	ld	a4,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201920:	8d95                	sub	a1,a1,a3
ffffffffc0201922:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201924:	81b1                	srli	a1,a1,0xc
ffffffffc0201926:	953e                	add	a0,a0,a5
ffffffffc0201928:	9702                	jalr	a4
}
ffffffffc020192a:	bfbd                	j	ffffffffc02018a8 <pmm_init+0xfa>
        panic("pa2page called with invalid pa");
ffffffffc020192c:	00001617          	auipc	a2,0x1
ffffffffc0201930:	4ec60613          	addi	a2,a2,1260 # ffffffffc0202e18 <best_fit_pmm_manager+0xf0>
ffffffffc0201934:	06b00593          	li	a1,107
ffffffffc0201938:	00001517          	auipc	a0,0x1
ffffffffc020193c:	50050513          	addi	a0,a0,1280 # ffffffffc0202e38 <best_fit_pmm_manager+0x110>
ffffffffc0201940:	ae1fe0ef          	jal	ra,ffffffffc0200420 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201944:	00001617          	auipc	a2,0x1
ffffffffc0201948:	4ac60613          	addi	a2,a2,1196 # ffffffffc0202df0 <best_fit_pmm_manager+0xc8>
ffffffffc020194c:	07100593          	li	a1,113
ffffffffc0201950:	00001517          	auipc	a0,0x1
ffffffffc0201954:	44850513          	addi	a0,a0,1096 # ffffffffc0202d98 <best_fit_pmm_manager+0x70>
ffffffffc0201958:	ac9fe0ef          	jal	ra,ffffffffc0200420 <__panic>
        panic("DTB memory info not available");
ffffffffc020195c:	00001617          	auipc	a2,0x1
ffffffffc0201960:	41c60613          	addi	a2,a2,1052 # ffffffffc0202d78 <best_fit_pmm_manager+0x50>
ffffffffc0201964:	05a00593          	li	a1,90
ffffffffc0201968:	00001517          	auipc	a0,0x1
ffffffffc020196c:	43050513          	addi	a0,a0,1072 # ffffffffc0202d98 <best_fit_pmm_manager+0x70>
ffffffffc0201970:	ab1fe0ef          	jal	ra,ffffffffc0200420 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201974:	86ae                	mv	a3,a1
ffffffffc0201976:	00001617          	auipc	a2,0x1
ffffffffc020197a:	47a60613          	addi	a2,a2,1146 # ffffffffc0202df0 <best_fit_pmm_manager+0xc8>
ffffffffc020197e:	08c00593          	li	a1,140
ffffffffc0201982:	00001517          	auipc	a0,0x1
ffffffffc0201986:	41650513          	addi	a0,a0,1046 # ffffffffc0202d98 <best_fit_pmm_manager+0x70>
ffffffffc020198a:	a97fe0ef          	jal	ra,ffffffffc0200420 <__panic>

ffffffffc020198e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020198e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201992:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201994:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201998:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020199a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020199e:	f022                	sd	s0,32(sp)
ffffffffc02019a0:	ec26                	sd	s1,24(sp)
ffffffffc02019a2:	e84a                	sd	s2,16(sp)
ffffffffc02019a4:	f406                	sd	ra,40(sp)
ffffffffc02019a6:	e44e                	sd	s3,8(sp)
ffffffffc02019a8:	84aa                	mv	s1,a0
ffffffffc02019aa:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02019ac:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02019b0:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02019b2:	03067e63          	bgeu	a2,a6,ffffffffc02019ee <printnum+0x60>
ffffffffc02019b6:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02019b8:	00805763          	blez	s0,ffffffffc02019c6 <printnum+0x38>
ffffffffc02019bc:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02019be:	85ca                	mv	a1,s2
ffffffffc02019c0:	854e                	mv	a0,s3
ffffffffc02019c2:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02019c4:	fc65                	bnez	s0,ffffffffc02019bc <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02019c6:	1a02                	slli	s4,s4,0x20
ffffffffc02019c8:	00001797          	auipc	a5,0x1
ffffffffc02019cc:	4e078793          	addi	a5,a5,1248 # ffffffffc0202ea8 <best_fit_pmm_manager+0x180>
ffffffffc02019d0:	020a5a13          	srli	s4,s4,0x20
ffffffffc02019d4:	9a3e                	add	s4,s4,a5
}
ffffffffc02019d6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02019d8:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02019dc:	70a2                	ld	ra,40(sp)
ffffffffc02019de:	69a2                	ld	s3,8(sp)
ffffffffc02019e0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02019e2:	85ca                	mv	a1,s2
ffffffffc02019e4:	87a6                	mv	a5,s1
}
ffffffffc02019e6:	6942                	ld	s2,16(sp)
ffffffffc02019e8:	64e2                	ld	s1,24(sp)
ffffffffc02019ea:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02019ec:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02019ee:	03065633          	divu	a2,a2,a6
ffffffffc02019f2:	8722                	mv	a4,s0
ffffffffc02019f4:	f9bff0ef          	jal	ra,ffffffffc020198e <printnum>
ffffffffc02019f8:	b7f9                	j	ffffffffc02019c6 <printnum+0x38>

ffffffffc02019fa <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02019fa:	7119                	addi	sp,sp,-128
ffffffffc02019fc:	f4a6                	sd	s1,104(sp)
ffffffffc02019fe:	f0ca                	sd	s2,96(sp)
ffffffffc0201a00:	ecce                	sd	s3,88(sp)
ffffffffc0201a02:	e8d2                	sd	s4,80(sp)
ffffffffc0201a04:	e4d6                	sd	s5,72(sp)
ffffffffc0201a06:	e0da                	sd	s6,64(sp)
ffffffffc0201a08:	fc5e                	sd	s7,56(sp)
ffffffffc0201a0a:	f06a                	sd	s10,32(sp)
ffffffffc0201a0c:	fc86                	sd	ra,120(sp)
ffffffffc0201a0e:	f8a2                	sd	s0,112(sp)
ffffffffc0201a10:	f862                	sd	s8,48(sp)
ffffffffc0201a12:	f466                	sd	s9,40(sp)
ffffffffc0201a14:	ec6e                	sd	s11,24(sp)
ffffffffc0201a16:	892a                	mv	s2,a0
ffffffffc0201a18:	84ae                	mv	s1,a1
ffffffffc0201a1a:	8d32                	mv	s10,a2
ffffffffc0201a1c:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201a1e:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201a22:	5b7d                	li	s6,-1
ffffffffc0201a24:	00001a97          	auipc	s5,0x1
ffffffffc0201a28:	4b8a8a93          	addi	s5,s5,1208 # ffffffffc0202edc <best_fit_pmm_manager+0x1b4>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201a2c:	00001b97          	auipc	s7,0x1
ffffffffc0201a30:	68cb8b93          	addi	s7,s7,1676 # ffffffffc02030b8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201a34:	000d4503          	lbu	a0,0(s10)
ffffffffc0201a38:	001d0413          	addi	s0,s10,1
ffffffffc0201a3c:	01350a63          	beq	a0,s3,ffffffffc0201a50 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201a40:	c121                	beqz	a0,ffffffffc0201a80 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201a42:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201a44:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201a46:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201a48:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201a4c:	ff351ae3          	bne	a0,s3,ffffffffc0201a40 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a50:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201a54:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201a58:	4c81                	li	s9,0
ffffffffc0201a5a:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201a5c:	5c7d                	li	s8,-1
ffffffffc0201a5e:	5dfd                	li	s11,-1
ffffffffc0201a60:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201a64:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a66:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201a6a:	0ff5f593          	zext.b	a1,a1
ffffffffc0201a6e:	00140d13          	addi	s10,s0,1
ffffffffc0201a72:	04b56263          	bltu	a0,a1,ffffffffc0201ab6 <vprintfmt+0xbc>
ffffffffc0201a76:	058a                	slli	a1,a1,0x2
ffffffffc0201a78:	95d6                	add	a1,a1,s5
ffffffffc0201a7a:	4194                	lw	a3,0(a1)
ffffffffc0201a7c:	96d6                	add	a3,a3,s5
ffffffffc0201a7e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201a80:	70e6                	ld	ra,120(sp)
ffffffffc0201a82:	7446                	ld	s0,112(sp)
ffffffffc0201a84:	74a6                	ld	s1,104(sp)
ffffffffc0201a86:	7906                	ld	s2,96(sp)
ffffffffc0201a88:	69e6                	ld	s3,88(sp)
ffffffffc0201a8a:	6a46                	ld	s4,80(sp)
ffffffffc0201a8c:	6aa6                	ld	s5,72(sp)
ffffffffc0201a8e:	6b06                	ld	s6,64(sp)
ffffffffc0201a90:	7be2                	ld	s7,56(sp)
ffffffffc0201a92:	7c42                	ld	s8,48(sp)
ffffffffc0201a94:	7ca2                	ld	s9,40(sp)
ffffffffc0201a96:	7d02                	ld	s10,32(sp)
ffffffffc0201a98:	6de2                	ld	s11,24(sp)
ffffffffc0201a9a:	6109                	addi	sp,sp,128
ffffffffc0201a9c:	8082                	ret
            padc = '0';
ffffffffc0201a9e:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201aa0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201aa4:	846a                	mv	s0,s10
ffffffffc0201aa6:	00140d13          	addi	s10,s0,1
ffffffffc0201aaa:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201aae:	0ff5f593          	zext.b	a1,a1
ffffffffc0201ab2:	fcb572e3          	bgeu	a0,a1,ffffffffc0201a76 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201ab6:	85a6                	mv	a1,s1
ffffffffc0201ab8:	02500513          	li	a0,37
ffffffffc0201abc:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201abe:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201ac2:	8d22                	mv	s10,s0
ffffffffc0201ac4:	f73788e3          	beq	a5,s3,ffffffffc0201a34 <vprintfmt+0x3a>
ffffffffc0201ac8:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201acc:	1d7d                	addi	s10,s10,-1
ffffffffc0201ace:	ff379de3          	bne	a5,s3,ffffffffc0201ac8 <vprintfmt+0xce>
ffffffffc0201ad2:	b78d                	j	ffffffffc0201a34 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201ad4:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201ad8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201adc:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201ade:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201ae2:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201ae6:	02d86463          	bltu	a6,a3,ffffffffc0201b0e <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201aea:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201aee:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201af2:	0186873b          	addw	a4,a3,s8
ffffffffc0201af6:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201afa:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201afc:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201b00:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201b02:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201b06:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201b0a:	fed870e3          	bgeu	a6,a3,ffffffffc0201aea <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201b0e:	f40ddce3          	bgez	s11,ffffffffc0201a66 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201b12:	8de2                	mv	s11,s8
ffffffffc0201b14:	5c7d                	li	s8,-1
ffffffffc0201b16:	bf81                	j	ffffffffc0201a66 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201b18:	fffdc693          	not	a3,s11
ffffffffc0201b1c:	96fd                	srai	a3,a3,0x3f
ffffffffc0201b1e:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b22:	00144603          	lbu	a2,1(s0)
ffffffffc0201b26:	2d81                	sext.w	s11,s11
ffffffffc0201b28:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201b2a:	bf35                	j	ffffffffc0201a66 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201b2c:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b30:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201b34:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b36:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201b38:	bfd9                	j	ffffffffc0201b0e <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201b3a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201b3c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201b40:	01174463          	blt	a4,a7,ffffffffc0201b48 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201b44:	1a088e63          	beqz	a7,ffffffffc0201d00 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201b48:	000a3603          	ld	a2,0(s4)
ffffffffc0201b4c:	46c1                	li	a3,16
ffffffffc0201b4e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201b50:	2781                	sext.w	a5,a5
ffffffffc0201b52:	876e                	mv	a4,s11
ffffffffc0201b54:	85a6                	mv	a1,s1
ffffffffc0201b56:	854a                	mv	a0,s2
ffffffffc0201b58:	e37ff0ef          	jal	ra,ffffffffc020198e <printnum>
            break;
ffffffffc0201b5c:	bde1                	j	ffffffffc0201a34 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201b5e:	000a2503          	lw	a0,0(s4)
ffffffffc0201b62:	85a6                	mv	a1,s1
ffffffffc0201b64:	0a21                	addi	s4,s4,8
ffffffffc0201b66:	9902                	jalr	s2
            break;
ffffffffc0201b68:	b5f1                	j	ffffffffc0201a34 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201b6a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201b6c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201b70:	01174463          	blt	a4,a7,ffffffffc0201b78 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201b74:	18088163          	beqz	a7,ffffffffc0201cf6 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201b78:	000a3603          	ld	a2,0(s4)
ffffffffc0201b7c:	46a9                	li	a3,10
ffffffffc0201b7e:	8a2e                	mv	s4,a1
ffffffffc0201b80:	bfc1                	j	ffffffffc0201b50 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b82:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201b86:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b88:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201b8a:	bdf1                	j	ffffffffc0201a66 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201b8c:	85a6                	mv	a1,s1
ffffffffc0201b8e:	02500513          	li	a0,37
ffffffffc0201b92:	9902                	jalr	s2
            break;
ffffffffc0201b94:	b545                	j	ffffffffc0201a34 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b96:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201b9a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b9c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201b9e:	b5e1                	j	ffffffffc0201a66 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201ba0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201ba2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201ba6:	01174463          	blt	a4,a7,ffffffffc0201bae <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201baa:	14088163          	beqz	a7,ffffffffc0201cec <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201bae:	000a3603          	ld	a2,0(s4)
ffffffffc0201bb2:	46a1                	li	a3,8
ffffffffc0201bb4:	8a2e                	mv	s4,a1
ffffffffc0201bb6:	bf69                	j	ffffffffc0201b50 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201bb8:	03000513          	li	a0,48
ffffffffc0201bbc:	85a6                	mv	a1,s1
ffffffffc0201bbe:	e03e                	sd	a5,0(sp)
ffffffffc0201bc0:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201bc2:	85a6                	mv	a1,s1
ffffffffc0201bc4:	07800513          	li	a0,120
ffffffffc0201bc8:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201bca:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201bcc:	6782                	ld	a5,0(sp)
ffffffffc0201bce:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201bd0:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201bd4:	bfb5                	j	ffffffffc0201b50 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201bd6:	000a3403          	ld	s0,0(s4)
ffffffffc0201bda:	008a0713          	addi	a4,s4,8
ffffffffc0201bde:	e03a                	sd	a4,0(sp)
ffffffffc0201be0:	14040263          	beqz	s0,ffffffffc0201d24 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201be4:	0fb05763          	blez	s11,ffffffffc0201cd2 <vprintfmt+0x2d8>
ffffffffc0201be8:	02d00693          	li	a3,45
ffffffffc0201bec:	0cd79163          	bne	a5,a3,ffffffffc0201cae <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201bf0:	00044783          	lbu	a5,0(s0)
ffffffffc0201bf4:	0007851b          	sext.w	a0,a5
ffffffffc0201bf8:	cf85                	beqz	a5,ffffffffc0201c30 <vprintfmt+0x236>
ffffffffc0201bfa:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201bfe:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201c02:	000c4563          	bltz	s8,ffffffffc0201c0c <vprintfmt+0x212>
ffffffffc0201c06:	3c7d                	addiw	s8,s8,-1
ffffffffc0201c08:	036c0263          	beq	s8,s6,ffffffffc0201c2c <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201c0c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201c0e:	0e0c8e63          	beqz	s9,ffffffffc0201d0a <vprintfmt+0x310>
ffffffffc0201c12:	3781                	addiw	a5,a5,-32
ffffffffc0201c14:	0ef47b63          	bgeu	s0,a5,ffffffffc0201d0a <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201c18:	03f00513          	li	a0,63
ffffffffc0201c1c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201c1e:	000a4783          	lbu	a5,0(s4)
ffffffffc0201c22:	3dfd                	addiw	s11,s11,-1
ffffffffc0201c24:	0a05                	addi	s4,s4,1
ffffffffc0201c26:	0007851b          	sext.w	a0,a5
ffffffffc0201c2a:	ffe1                	bnez	a5,ffffffffc0201c02 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201c2c:	01b05963          	blez	s11,ffffffffc0201c3e <vprintfmt+0x244>
ffffffffc0201c30:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201c32:	85a6                	mv	a1,s1
ffffffffc0201c34:	02000513          	li	a0,32
ffffffffc0201c38:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201c3a:	fe0d9be3          	bnez	s11,ffffffffc0201c30 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201c3e:	6a02                	ld	s4,0(sp)
ffffffffc0201c40:	bbd5                	j	ffffffffc0201a34 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201c42:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201c44:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201c48:	01174463          	blt	a4,a7,ffffffffc0201c50 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201c4c:	08088d63          	beqz	a7,ffffffffc0201ce6 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201c50:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201c54:	0a044d63          	bltz	s0,ffffffffc0201d0e <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201c58:	8622                	mv	a2,s0
ffffffffc0201c5a:	8a66                	mv	s4,s9
ffffffffc0201c5c:	46a9                	li	a3,10
ffffffffc0201c5e:	bdcd                	j	ffffffffc0201b50 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201c60:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201c64:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201c66:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201c68:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201c6c:	8fb5                	xor	a5,a5,a3
ffffffffc0201c6e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201c72:	02d74163          	blt	a4,a3,ffffffffc0201c94 <vprintfmt+0x29a>
ffffffffc0201c76:	00369793          	slli	a5,a3,0x3
ffffffffc0201c7a:	97de                	add	a5,a5,s7
ffffffffc0201c7c:	639c                	ld	a5,0(a5)
ffffffffc0201c7e:	cb99                	beqz	a5,ffffffffc0201c94 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201c80:	86be                	mv	a3,a5
ffffffffc0201c82:	00001617          	auipc	a2,0x1
ffffffffc0201c86:	25660613          	addi	a2,a2,598 # ffffffffc0202ed8 <best_fit_pmm_manager+0x1b0>
ffffffffc0201c8a:	85a6                	mv	a1,s1
ffffffffc0201c8c:	854a                	mv	a0,s2
ffffffffc0201c8e:	0ce000ef          	jal	ra,ffffffffc0201d5c <printfmt>
ffffffffc0201c92:	b34d                	j	ffffffffc0201a34 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201c94:	00001617          	auipc	a2,0x1
ffffffffc0201c98:	23460613          	addi	a2,a2,564 # ffffffffc0202ec8 <best_fit_pmm_manager+0x1a0>
ffffffffc0201c9c:	85a6                	mv	a1,s1
ffffffffc0201c9e:	854a                	mv	a0,s2
ffffffffc0201ca0:	0bc000ef          	jal	ra,ffffffffc0201d5c <printfmt>
ffffffffc0201ca4:	bb41                	j	ffffffffc0201a34 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201ca6:	00001417          	auipc	s0,0x1
ffffffffc0201caa:	21a40413          	addi	s0,s0,538 # ffffffffc0202ec0 <best_fit_pmm_manager+0x198>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201cae:	85e2                	mv	a1,s8
ffffffffc0201cb0:	8522                	mv	a0,s0
ffffffffc0201cb2:	e43e                	sd	a5,8(sp)
ffffffffc0201cb4:	200000ef          	jal	ra,ffffffffc0201eb4 <strnlen>
ffffffffc0201cb8:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201cbc:	01b05b63          	blez	s11,ffffffffc0201cd2 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201cc0:	67a2                	ld	a5,8(sp)
ffffffffc0201cc2:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201cc6:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201cc8:	85a6                	mv	a1,s1
ffffffffc0201cca:	8552                	mv	a0,s4
ffffffffc0201ccc:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201cce:	fe0d9ce3          	bnez	s11,ffffffffc0201cc6 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201cd2:	00044783          	lbu	a5,0(s0)
ffffffffc0201cd6:	00140a13          	addi	s4,s0,1
ffffffffc0201cda:	0007851b          	sext.w	a0,a5
ffffffffc0201cde:	d3a5                	beqz	a5,ffffffffc0201c3e <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201ce0:	05e00413          	li	s0,94
ffffffffc0201ce4:	bf39                	j	ffffffffc0201c02 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201ce6:	000a2403          	lw	s0,0(s4)
ffffffffc0201cea:	b7ad                	j	ffffffffc0201c54 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201cec:	000a6603          	lwu	a2,0(s4)
ffffffffc0201cf0:	46a1                	li	a3,8
ffffffffc0201cf2:	8a2e                	mv	s4,a1
ffffffffc0201cf4:	bdb1                	j	ffffffffc0201b50 <vprintfmt+0x156>
ffffffffc0201cf6:	000a6603          	lwu	a2,0(s4)
ffffffffc0201cfa:	46a9                	li	a3,10
ffffffffc0201cfc:	8a2e                	mv	s4,a1
ffffffffc0201cfe:	bd89                	j	ffffffffc0201b50 <vprintfmt+0x156>
ffffffffc0201d00:	000a6603          	lwu	a2,0(s4)
ffffffffc0201d04:	46c1                	li	a3,16
ffffffffc0201d06:	8a2e                	mv	s4,a1
ffffffffc0201d08:	b5a1                	j	ffffffffc0201b50 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201d0a:	9902                	jalr	s2
ffffffffc0201d0c:	bf09                	j	ffffffffc0201c1e <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201d0e:	85a6                	mv	a1,s1
ffffffffc0201d10:	02d00513          	li	a0,45
ffffffffc0201d14:	e03e                	sd	a5,0(sp)
ffffffffc0201d16:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201d18:	6782                	ld	a5,0(sp)
ffffffffc0201d1a:	8a66                	mv	s4,s9
ffffffffc0201d1c:	40800633          	neg	a2,s0
ffffffffc0201d20:	46a9                	li	a3,10
ffffffffc0201d22:	b53d                	j	ffffffffc0201b50 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201d24:	03b05163          	blez	s11,ffffffffc0201d46 <vprintfmt+0x34c>
ffffffffc0201d28:	02d00693          	li	a3,45
ffffffffc0201d2c:	f6d79de3          	bne	a5,a3,ffffffffc0201ca6 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201d30:	00001417          	auipc	s0,0x1
ffffffffc0201d34:	19040413          	addi	s0,s0,400 # ffffffffc0202ec0 <best_fit_pmm_manager+0x198>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201d38:	02800793          	li	a5,40
ffffffffc0201d3c:	02800513          	li	a0,40
ffffffffc0201d40:	00140a13          	addi	s4,s0,1
ffffffffc0201d44:	bd6d                	j	ffffffffc0201bfe <vprintfmt+0x204>
ffffffffc0201d46:	00001a17          	auipc	s4,0x1
ffffffffc0201d4a:	17ba0a13          	addi	s4,s4,379 # ffffffffc0202ec1 <best_fit_pmm_manager+0x199>
ffffffffc0201d4e:	02800513          	li	a0,40
ffffffffc0201d52:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201d56:	05e00413          	li	s0,94
ffffffffc0201d5a:	b565                	j	ffffffffc0201c02 <vprintfmt+0x208>

ffffffffc0201d5c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201d5c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201d5e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201d62:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201d64:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201d66:	ec06                	sd	ra,24(sp)
ffffffffc0201d68:	f83a                	sd	a4,48(sp)
ffffffffc0201d6a:	fc3e                	sd	a5,56(sp)
ffffffffc0201d6c:	e0c2                	sd	a6,64(sp)
ffffffffc0201d6e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201d70:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201d72:	c89ff0ef          	jal	ra,ffffffffc02019fa <vprintfmt>
}
ffffffffc0201d76:	60e2                	ld	ra,24(sp)
ffffffffc0201d78:	6161                	addi	sp,sp,80
ffffffffc0201d7a:	8082                	ret

ffffffffc0201d7c <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201d7c:	715d                	addi	sp,sp,-80
ffffffffc0201d7e:	e486                	sd	ra,72(sp)
ffffffffc0201d80:	e0a6                	sd	s1,64(sp)
ffffffffc0201d82:	fc4a                	sd	s2,56(sp)
ffffffffc0201d84:	f84e                	sd	s3,48(sp)
ffffffffc0201d86:	f452                	sd	s4,40(sp)
ffffffffc0201d88:	f056                	sd	s5,32(sp)
ffffffffc0201d8a:	ec5a                	sd	s6,24(sp)
ffffffffc0201d8c:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201d8e:	c901                	beqz	a0,ffffffffc0201d9e <readline+0x22>
ffffffffc0201d90:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201d92:	00001517          	auipc	a0,0x1
ffffffffc0201d96:	14650513          	addi	a0,a0,326 # ffffffffc0202ed8 <best_fit_pmm_manager+0x1b0>
ffffffffc0201d9a:	b8cfe0ef          	jal	ra,ffffffffc0200126 <cprintf>
readline(const char *prompt) {
ffffffffc0201d9e:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201da0:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201da2:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201da4:	4aa9                	li	s5,10
ffffffffc0201da6:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201da8:	00005b97          	auipc	s7,0x5
ffffffffc0201dac:	298b8b93          	addi	s7,s7,664 # ffffffffc0207040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201db0:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201db4:	beafe0ef          	jal	ra,ffffffffc020019e <getchar>
        if (c < 0) {
ffffffffc0201db8:	00054a63          	bltz	a0,ffffffffc0201dcc <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201dbc:	00a95a63          	bge	s2,a0,ffffffffc0201dd0 <readline+0x54>
ffffffffc0201dc0:	029a5263          	bge	s4,s1,ffffffffc0201de4 <readline+0x68>
        c = getchar();
ffffffffc0201dc4:	bdafe0ef          	jal	ra,ffffffffc020019e <getchar>
        if (c < 0) {
ffffffffc0201dc8:	fe055ae3          	bgez	a0,ffffffffc0201dbc <readline+0x40>
            return NULL;
ffffffffc0201dcc:	4501                	li	a0,0
ffffffffc0201dce:	a091                	j	ffffffffc0201e12 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201dd0:	03351463          	bne	a0,s3,ffffffffc0201df8 <readline+0x7c>
ffffffffc0201dd4:	e8a9                	bnez	s1,ffffffffc0201e26 <readline+0xaa>
        c = getchar();
ffffffffc0201dd6:	bc8fe0ef          	jal	ra,ffffffffc020019e <getchar>
        if (c < 0) {
ffffffffc0201dda:	fe0549e3          	bltz	a0,ffffffffc0201dcc <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201dde:	fea959e3          	bge	s2,a0,ffffffffc0201dd0 <readline+0x54>
ffffffffc0201de2:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201de4:	e42a                	sd	a0,8(sp)
ffffffffc0201de6:	b76fe0ef          	jal	ra,ffffffffc020015c <cputchar>
            buf[i ++] = c;
ffffffffc0201dea:	6522                	ld	a0,8(sp)
ffffffffc0201dec:	009b87b3          	add	a5,s7,s1
ffffffffc0201df0:	2485                	addiw	s1,s1,1
ffffffffc0201df2:	00a78023          	sb	a0,0(a5)
ffffffffc0201df6:	bf7d                	j	ffffffffc0201db4 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201df8:	01550463          	beq	a0,s5,ffffffffc0201e00 <readline+0x84>
ffffffffc0201dfc:	fb651ce3          	bne	a0,s6,ffffffffc0201db4 <readline+0x38>
            cputchar(c);
ffffffffc0201e00:	b5cfe0ef          	jal	ra,ffffffffc020015c <cputchar>
            buf[i] = '\0';
ffffffffc0201e04:	00005517          	auipc	a0,0x5
ffffffffc0201e08:	23c50513          	addi	a0,a0,572 # ffffffffc0207040 <buf>
ffffffffc0201e0c:	94aa                	add	s1,s1,a0
ffffffffc0201e0e:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201e12:	60a6                	ld	ra,72(sp)
ffffffffc0201e14:	6486                	ld	s1,64(sp)
ffffffffc0201e16:	7962                	ld	s2,56(sp)
ffffffffc0201e18:	79c2                	ld	s3,48(sp)
ffffffffc0201e1a:	7a22                	ld	s4,40(sp)
ffffffffc0201e1c:	7a82                	ld	s5,32(sp)
ffffffffc0201e1e:	6b62                	ld	s6,24(sp)
ffffffffc0201e20:	6bc2                	ld	s7,16(sp)
ffffffffc0201e22:	6161                	addi	sp,sp,80
ffffffffc0201e24:	8082                	ret
            cputchar(c);
ffffffffc0201e26:	4521                	li	a0,8
ffffffffc0201e28:	b34fe0ef          	jal	ra,ffffffffc020015c <cputchar>
            i --;
ffffffffc0201e2c:	34fd                	addiw	s1,s1,-1
ffffffffc0201e2e:	b759                	j	ffffffffc0201db4 <readline+0x38>

ffffffffc0201e30 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201e30:	4781                	li	a5,0
ffffffffc0201e32:	00005717          	auipc	a4,0x5
ffffffffc0201e36:	1e673703          	ld	a4,486(a4) # ffffffffc0207018 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201e3a:	88ba                	mv	a7,a4
ffffffffc0201e3c:	852a                	mv	a0,a0
ffffffffc0201e3e:	85be                	mv	a1,a5
ffffffffc0201e40:	863e                	mv	a2,a5
ffffffffc0201e42:	00000073          	ecall
ffffffffc0201e46:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201e48:	8082                	ret

ffffffffc0201e4a <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201e4a:	4781                	li	a5,0
ffffffffc0201e4c:	00005717          	auipc	a4,0x5
ffffffffc0201e50:	64c73703          	ld	a4,1612(a4) # ffffffffc0207498 <SBI_SET_TIMER>
ffffffffc0201e54:	88ba                	mv	a7,a4
ffffffffc0201e56:	852a                	mv	a0,a0
ffffffffc0201e58:	85be                	mv	a1,a5
ffffffffc0201e5a:	863e                	mv	a2,a5
ffffffffc0201e5c:	00000073          	ecall
ffffffffc0201e60:	87aa                	mv	a5,a0

// 当time寄存器(rdtime的返回值)为stime_value的时候触发一个时钟中断
void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201e62:	8082                	ret

ffffffffc0201e64 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201e64:	4501                	li	a0,0
ffffffffc0201e66:	00005797          	auipc	a5,0x5
ffffffffc0201e6a:	1aa7b783          	ld	a5,426(a5) # ffffffffc0207010 <SBI_CONSOLE_GETCHAR>
ffffffffc0201e6e:	88be                	mv	a7,a5
ffffffffc0201e70:	852a                	mv	a0,a0
ffffffffc0201e72:	85aa                	mv	a1,a0
ffffffffc0201e74:	862a                	mv	a2,a0
ffffffffc0201e76:	00000073          	ecall
ffffffffc0201e7a:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc0201e7c:	2501                	sext.w	a0,a0
ffffffffc0201e7e:	8082                	ret

ffffffffc0201e80 <sbi_shutdown>:
    __asm__ volatile (
ffffffffc0201e80:	4781                	li	a5,0
ffffffffc0201e82:	00005717          	auipc	a4,0x5
ffffffffc0201e86:	19e73703          	ld	a4,414(a4) # ffffffffc0207020 <SBI_SHUTDOWN>
ffffffffc0201e8a:	88ba                	mv	a7,a4
ffffffffc0201e8c:	853e                	mv	a0,a5
ffffffffc0201e8e:	85be                	mv	a1,a5
ffffffffc0201e90:	863e                	mv	a2,a5
ffffffffc0201e92:	00000073          	ecall
ffffffffc0201e96:	87aa                	mv	a5,a0

void sbi_shutdown(void)
{
	sbi_call(SBI_SHUTDOWN, 0, 0, 0);
ffffffffc0201e98:	8082                	ret

ffffffffc0201e9a <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0201e9a:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0201e9e:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0201ea0:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0201ea2:	cb81                	beqz	a5,ffffffffc0201eb2 <strlen+0x18>
        cnt ++;
ffffffffc0201ea4:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0201ea6:	00a707b3          	add	a5,a4,a0
ffffffffc0201eaa:	0007c783          	lbu	a5,0(a5)
ffffffffc0201eae:	fbfd                	bnez	a5,ffffffffc0201ea4 <strlen+0xa>
ffffffffc0201eb0:	8082                	ret
    }
    return cnt;
}
ffffffffc0201eb2:	8082                	ret

ffffffffc0201eb4 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201eb4:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201eb6:	e589                	bnez	a1,ffffffffc0201ec0 <strnlen+0xc>
ffffffffc0201eb8:	a811                	j	ffffffffc0201ecc <strnlen+0x18>
        cnt ++;
ffffffffc0201eba:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201ebc:	00f58863          	beq	a1,a5,ffffffffc0201ecc <strnlen+0x18>
ffffffffc0201ec0:	00f50733          	add	a4,a0,a5
ffffffffc0201ec4:	00074703          	lbu	a4,0(a4)
ffffffffc0201ec8:	fb6d                	bnez	a4,ffffffffc0201eba <strnlen+0x6>
ffffffffc0201eca:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201ecc:	852e                	mv	a0,a1
ffffffffc0201ece:	8082                	ret

ffffffffc0201ed0 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201ed0:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201ed4:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201ed8:	cb89                	beqz	a5,ffffffffc0201eea <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201eda:	0505                	addi	a0,a0,1
ffffffffc0201edc:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201ede:	fee789e3          	beq	a5,a4,ffffffffc0201ed0 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201ee2:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201ee6:	9d19                	subw	a0,a0,a4
ffffffffc0201ee8:	8082                	ret
ffffffffc0201eea:	4501                	li	a0,0
ffffffffc0201eec:	bfed                	j	ffffffffc0201ee6 <strcmp+0x16>

ffffffffc0201eee <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201eee:	c20d                	beqz	a2,ffffffffc0201f10 <strncmp+0x22>
ffffffffc0201ef0:	962e                	add	a2,a2,a1
ffffffffc0201ef2:	a031                	j	ffffffffc0201efe <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0201ef4:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201ef6:	00e79a63          	bne	a5,a4,ffffffffc0201f0a <strncmp+0x1c>
ffffffffc0201efa:	00b60b63          	beq	a2,a1,ffffffffc0201f10 <strncmp+0x22>
ffffffffc0201efe:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0201f02:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201f04:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0201f08:	f7f5                	bnez	a5,ffffffffc0201ef4 <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201f0a:	40e7853b          	subw	a0,a5,a4
}
ffffffffc0201f0e:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201f10:	4501                	li	a0,0
ffffffffc0201f12:	8082                	ret

ffffffffc0201f14 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201f14:	00054783          	lbu	a5,0(a0)
ffffffffc0201f18:	c799                	beqz	a5,ffffffffc0201f26 <strchr+0x12>
        if (*s == c) {
ffffffffc0201f1a:	00f58763          	beq	a1,a5,ffffffffc0201f28 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201f1e:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201f22:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201f24:	fbfd                	bnez	a5,ffffffffc0201f1a <strchr+0x6>
    }
    return NULL;
ffffffffc0201f26:	4501                	li	a0,0
}
ffffffffc0201f28:	8082                	ret

ffffffffc0201f2a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201f2a:	ca01                	beqz	a2,ffffffffc0201f3a <memset+0x10>
ffffffffc0201f2c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201f2e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201f30:	0785                	addi	a5,a5,1
ffffffffc0201f32:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201f36:	fec79de3          	bne	a5,a2,ffffffffc0201f30 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201f3a:	8082                	ret
