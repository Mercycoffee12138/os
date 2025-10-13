
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	00006297          	auipc	t0,0x6
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0206000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	00006297          	auipc	t0,0x6
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0206008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)

    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02052b7          	lui	t0,0xc0205
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
ffffffffc020003c:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200044:	0d828293          	addi	t0,t0,216 # ffffffffc02000d8 <kern_init>
    jr t0
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020004a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[];
    cprintf("Special kernel symbols:\n");
ffffffffc020004c:	00001517          	auipc	a0,0x1
ffffffffc0200050:	5e450513          	addi	a0,a0,1508 # ffffffffc0201630 <etext>
void print_kerninfo(void) {
ffffffffc0200054:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200056:	0f6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", (uintptr_t)kern_init);
ffffffffc020005a:	00000597          	auipc	a1,0x0
ffffffffc020005e:	07e58593          	addi	a1,a1,126 # ffffffffc02000d8 <kern_init>
ffffffffc0200062:	00001517          	auipc	a0,0x1
ffffffffc0200066:	5ee50513          	addi	a0,a0,1518 # ffffffffc0201650 <etext+0x20>
ffffffffc020006a:	0e2000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020006e:	00001597          	auipc	a1,0x1
ffffffffc0200072:	5c258593          	addi	a1,a1,1474 # ffffffffc0201630 <etext>
ffffffffc0200076:	00001517          	auipc	a0,0x1
ffffffffc020007a:	5fa50513          	addi	a0,a0,1530 # ffffffffc0201670 <etext+0x40>
ffffffffc020007e:	0ce000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200082:	00006597          	auipc	a1,0x6
ffffffffc0200086:	f9658593          	addi	a1,a1,-106 # ffffffffc0206018 <free_lists>
ffffffffc020008a:	00001517          	auipc	a0,0x1
ffffffffc020008e:	60650513          	addi	a0,a0,1542 # ffffffffc0201690 <etext+0x60>
ffffffffc0200092:	0ba000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200096:	00006597          	auipc	a1,0x6
ffffffffc020009a:	0da58593          	addi	a1,a1,218 # ffffffffc0206170 <end>
ffffffffc020009e:	00001517          	auipc	a0,0x1
ffffffffc02000a2:	61250513          	addi	a0,a0,1554 # ffffffffc02016b0 <etext+0x80>
ffffffffc02000a6:	0a6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - (char*)kern_init + 1023) / 1024);
ffffffffc02000aa:	00006597          	auipc	a1,0x6
ffffffffc02000ae:	4c558593          	addi	a1,a1,1221 # ffffffffc020656f <end+0x3ff>
ffffffffc02000b2:	00000797          	auipc	a5,0x0
ffffffffc02000b6:	02678793          	addi	a5,a5,38 # ffffffffc02000d8 <kern_init>
ffffffffc02000ba:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000be:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02000c2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000c4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02000c8:	95be                	add	a1,a1,a5
ffffffffc02000ca:	85a9                	srai	a1,a1,0xa
ffffffffc02000cc:	00001517          	auipc	a0,0x1
ffffffffc02000d0:	60450513          	addi	a0,a0,1540 # ffffffffc02016d0 <etext+0xa0>
}
ffffffffc02000d4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000d6:	a89d                	j	ffffffffc020014c <cprintf>

ffffffffc02000d8 <kern_init>:

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc02000d8:	00006517          	auipc	a0,0x6
ffffffffc02000dc:	f4050513          	addi	a0,a0,-192 # ffffffffc0206018 <free_lists>
ffffffffc02000e0:	00006617          	auipc	a2,0x6
ffffffffc02000e4:	09060613          	addi	a2,a2,144 # ffffffffc0206170 <end>
int kern_init(void) {
ffffffffc02000e8:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc02000ea:	8e09                	sub	a2,a2,a0
ffffffffc02000ec:	4581                	li	a1,0
int kern_init(void) {
ffffffffc02000ee:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc02000f0:	52e010ef          	jal	ra,ffffffffc020161e <memset>
    dtb_init();
ffffffffc02000f4:	12c000ef          	jal	ra,ffffffffc0200220 <dtb_init>
    cons_init();  // init the console
ffffffffc02000f8:	11e000ef          	jal	ra,ffffffffc0200216 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc02000fc:	00001517          	auipc	a0,0x1
ffffffffc0200100:	60450513          	addi	a0,a0,1540 # ffffffffc0201700 <etext+0xd0>
ffffffffc0200104:	07e000ef          	jal	ra,ffffffffc0200182 <cputs>

    print_kerninfo();
ffffffffc0200108:	f43ff0ef          	jal	ra,ffffffffc020004a <print_kerninfo>

    // grade_backtrace();
    pmm_init();  // init physical memory management
ffffffffc020010c:	6b9000ef          	jal	ra,ffffffffc0200fc4 <pmm_init>

    /* do nothing */
    while (1)
ffffffffc0200110:	a001                	j	ffffffffc0200110 <kern_init+0x38>

ffffffffc0200112 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200112:	1141                	addi	sp,sp,-16
ffffffffc0200114:	e022                	sd	s0,0(sp)
ffffffffc0200116:	e406                	sd	ra,8(sp)
ffffffffc0200118:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020011a:	0fe000ef          	jal	ra,ffffffffc0200218 <cons_putc>
    (*cnt) ++;
ffffffffc020011e:	401c                	lw	a5,0(s0)
}
ffffffffc0200120:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200122:	2785                	addiw	a5,a5,1
ffffffffc0200124:	c01c                	sw	a5,0(s0)
}
ffffffffc0200126:	6402                	ld	s0,0(sp)
ffffffffc0200128:	0141                	addi	sp,sp,16
ffffffffc020012a:	8082                	ret

ffffffffc020012c <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020012c:	1101                	addi	sp,sp,-32
ffffffffc020012e:	862a                	mv	a2,a0
ffffffffc0200130:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200132:	00000517          	auipc	a0,0x0
ffffffffc0200136:	fe050513          	addi	a0,a0,-32 # ffffffffc0200112 <cputch>
ffffffffc020013a:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc020013c:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc020013e:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200140:	0c8010ef          	jal	ra,ffffffffc0201208 <vprintfmt>
    return cnt;
}
ffffffffc0200144:	60e2                	ld	ra,24(sp)
ffffffffc0200146:	4532                	lw	a0,12(sp)
ffffffffc0200148:	6105                	addi	sp,sp,32
ffffffffc020014a:	8082                	ret

ffffffffc020014c <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc020014c:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc020014e:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200152:	8e2a                	mv	t3,a0
ffffffffc0200154:	f42e                	sd	a1,40(sp)
ffffffffc0200156:	f832                	sd	a2,48(sp)
ffffffffc0200158:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020015a:	00000517          	auipc	a0,0x0
ffffffffc020015e:	fb850513          	addi	a0,a0,-72 # ffffffffc0200112 <cputch>
ffffffffc0200162:	004c                	addi	a1,sp,4
ffffffffc0200164:	869a                	mv	a3,t1
ffffffffc0200166:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc0200168:	ec06                	sd	ra,24(sp)
ffffffffc020016a:	e0ba                	sd	a4,64(sp)
ffffffffc020016c:	e4be                	sd	a5,72(sp)
ffffffffc020016e:	e8c2                	sd	a6,80(sp)
ffffffffc0200170:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc0200172:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc0200174:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200176:	092010ef          	jal	ra,ffffffffc0201208 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc020017a:	60e2                	ld	ra,24(sp)
ffffffffc020017c:	4512                	lw	a0,4(sp)
ffffffffc020017e:	6125                	addi	sp,sp,96
ffffffffc0200180:	8082                	ret

ffffffffc0200182 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200182:	1101                	addi	sp,sp,-32
ffffffffc0200184:	e822                	sd	s0,16(sp)
ffffffffc0200186:	ec06                	sd	ra,24(sp)
ffffffffc0200188:	e426                	sd	s1,8(sp)
ffffffffc020018a:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc020018c:	00054503          	lbu	a0,0(a0)
ffffffffc0200190:	c51d                	beqz	a0,ffffffffc02001be <cputs+0x3c>
ffffffffc0200192:	0405                	addi	s0,s0,1
ffffffffc0200194:	4485                	li	s1,1
ffffffffc0200196:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200198:	080000ef          	jal	ra,ffffffffc0200218 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020019c:	00044503          	lbu	a0,0(s0)
ffffffffc02001a0:	008487bb          	addw	a5,s1,s0
ffffffffc02001a4:	0405                	addi	s0,s0,1
ffffffffc02001a6:	f96d                	bnez	a0,ffffffffc0200198 <cputs+0x16>
    (*cnt) ++;
ffffffffc02001a8:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001ac:	4529                	li	a0,10
ffffffffc02001ae:	06a000ef          	jal	ra,ffffffffc0200218 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001b2:	60e2                	ld	ra,24(sp)
ffffffffc02001b4:	8522                	mv	a0,s0
ffffffffc02001b6:	6442                	ld	s0,16(sp)
ffffffffc02001b8:	64a2                	ld	s1,8(sp)
ffffffffc02001ba:	6105                	addi	sp,sp,32
ffffffffc02001bc:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc02001be:	4405                	li	s0,1
ffffffffc02001c0:	b7f5                	j	ffffffffc02001ac <cputs+0x2a>

ffffffffc02001c2 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001c2:	00006317          	auipc	t1,0x6
ffffffffc02001c6:	f5e30313          	addi	t1,t1,-162 # ffffffffc0206120 <is_panic>
ffffffffc02001ca:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001ce:	715d                	addi	sp,sp,-80
ffffffffc02001d0:	ec06                	sd	ra,24(sp)
ffffffffc02001d2:	e822                	sd	s0,16(sp)
ffffffffc02001d4:	f436                	sd	a3,40(sp)
ffffffffc02001d6:	f83a                	sd	a4,48(sp)
ffffffffc02001d8:	fc3e                	sd	a5,56(sp)
ffffffffc02001da:	e0c2                	sd	a6,64(sp)
ffffffffc02001dc:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001de:	000e0363          	beqz	t3,ffffffffc02001e4 <__panic+0x22>
    vcprintf(fmt, ap);
    cprintf("\n");
    va_end(ap);

panic_dead:
    while (1) {
ffffffffc02001e2:	a001                	j	ffffffffc02001e2 <__panic+0x20>
    is_panic = 1;
ffffffffc02001e4:	4785                	li	a5,1
ffffffffc02001e6:	00f32023          	sw	a5,0(t1)
    va_start(ap, fmt);
ffffffffc02001ea:	8432                	mv	s0,a2
ffffffffc02001ec:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001ee:	862e                	mv	a2,a1
ffffffffc02001f0:	85aa                	mv	a1,a0
ffffffffc02001f2:	00001517          	auipc	a0,0x1
ffffffffc02001f6:	52e50513          	addi	a0,a0,1326 # ffffffffc0201720 <etext+0xf0>
    va_start(ap, fmt);
ffffffffc02001fa:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001fc:	f51ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200200:	65a2                	ld	a1,8(sp)
ffffffffc0200202:	8522                	mv	a0,s0
ffffffffc0200204:	f29ff0ef          	jal	ra,ffffffffc020012c <vcprintf>
    cprintf("\n");
ffffffffc0200208:	00001517          	auipc	a0,0x1
ffffffffc020020c:	76050513          	addi	a0,a0,1888 # ffffffffc0201968 <etext+0x338>
ffffffffc0200210:	f3dff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200214:	b7f9                	j	ffffffffc02001e2 <__panic+0x20>

ffffffffc0200216 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200216:	8082                	ret

ffffffffc0200218 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200218:	0ff57513          	zext.b	a0,a0
ffffffffc020021c:	36e0106f          	j	ffffffffc020158a <sbi_console_putchar>

ffffffffc0200220 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc0200220:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc0200222:	00001517          	auipc	a0,0x1
ffffffffc0200226:	51e50513          	addi	a0,a0,1310 # ffffffffc0201740 <etext+0x110>
void dtb_init(void) {
ffffffffc020022a:	fc86                	sd	ra,120(sp)
ffffffffc020022c:	f8a2                	sd	s0,112(sp)
ffffffffc020022e:	e8d2                	sd	s4,80(sp)
ffffffffc0200230:	f4a6                	sd	s1,104(sp)
ffffffffc0200232:	f0ca                	sd	s2,96(sp)
ffffffffc0200234:	ecce                	sd	s3,88(sp)
ffffffffc0200236:	e4d6                	sd	s5,72(sp)
ffffffffc0200238:	e0da                	sd	s6,64(sp)
ffffffffc020023a:	fc5e                	sd	s7,56(sp)
ffffffffc020023c:	f862                	sd	s8,48(sp)
ffffffffc020023e:	f466                	sd	s9,40(sp)
ffffffffc0200240:	f06a                	sd	s10,32(sp)
ffffffffc0200242:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc0200244:	f09ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200248:	00006597          	auipc	a1,0x6
ffffffffc020024c:	db85b583          	ld	a1,-584(a1) # ffffffffc0206000 <boot_hartid>
ffffffffc0200250:	00001517          	auipc	a0,0x1
ffffffffc0200254:	50050513          	addi	a0,a0,1280 # ffffffffc0201750 <etext+0x120>
ffffffffc0200258:	ef5ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020025c:	00006417          	auipc	s0,0x6
ffffffffc0200260:	dac40413          	addi	s0,s0,-596 # ffffffffc0206008 <boot_dtb>
ffffffffc0200264:	600c                	ld	a1,0(s0)
ffffffffc0200266:	00001517          	auipc	a0,0x1
ffffffffc020026a:	4fa50513          	addi	a0,a0,1274 # ffffffffc0201760 <etext+0x130>
ffffffffc020026e:	edfff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200272:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200276:	00001517          	auipc	a0,0x1
ffffffffc020027a:	50250513          	addi	a0,a0,1282 # ffffffffc0201778 <etext+0x148>
    if (boot_dtb == 0) {
ffffffffc020027e:	120a0463          	beqz	s4,ffffffffc02003a6 <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200282:	57f5                	li	a5,-3
ffffffffc0200284:	07fa                	slli	a5,a5,0x1e
ffffffffc0200286:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc020028a:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020028c:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200290:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200292:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200296:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020029a:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020029e:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002a2:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002a6:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002a8:	8ec9                	or	a3,a3,a0
ffffffffc02002aa:	0087979b          	slliw	a5,a5,0x8
ffffffffc02002ae:	1b7d                	addi	s6,s6,-1
ffffffffc02002b0:	0167f7b3          	and	a5,a5,s6
ffffffffc02002b4:	8dd5                	or	a1,a1,a3
ffffffffc02002b6:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc02002b8:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002bc:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc02002be:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfed9d7d>
ffffffffc02002c2:	10f59163          	bne	a1,a5,ffffffffc02003c4 <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc02002c6:	471c                	lw	a5,8(a4)
ffffffffc02002c8:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc02002ca:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002cc:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02002d0:	0086d51b          	srliw	a0,a3,0x8
ffffffffc02002d4:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002d8:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002dc:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002e0:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002e4:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002e8:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002ec:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002f0:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002f4:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002f6:	01146433          	or	s0,s0,a7
ffffffffc02002fa:	0086969b          	slliw	a3,a3,0x8
ffffffffc02002fe:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200302:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200304:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200308:	8c49                	or	s0,s0,a0
ffffffffc020030a:	0166f6b3          	and	a3,a3,s6
ffffffffc020030e:	00ca6a33          	or	s4,s4,a2
ffffffffc0200312:	0167f7b3          	and	a5,a5,s6
ffffffffc0200316:	8c55                	or	s0,s0,a3
ffffffffc0200318:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020031c:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020031e:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200320:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200322:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200326:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200328:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020032a:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc020032e:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200330:	00001917          	auipc	s2,0x1
ffffffffc0200334:	49890913          	addi	s2,s2,1176 # ffffffffc02017c8 <etext+0x198>
ffffffffc0200338:	49bd                	li	s3,15
        switch (token) {
ffffffffc020033a:	4d91                	li	s11,4
ffffffffc020033c:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020033e:	00001497          	auipc	s1,0x1
ffffffffc0200342:	48248493          	addi	s1,s1,1154 # ffffffffc02017c0 <etext+0x190>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200346:	000a2703          	lw	a4,0(s4)
ffffffffc020034a:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020034e:	0087569b          	srliw	a3,a4,0x8
ffffffffc0200352:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200356:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020035a:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020035e:	0107571b          	srliw	a4,a4,0x10
ffffffffc0200362:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200364:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200368:	0087171b          	slliw	a4,a4,0x8
ffffffffc020036c:	8fd5                	or	a5,a5,a3
ffffffffc020036e:	00eb7733          	and	a4,s6,a4
ffffffffc0200372:	8fd9                	or	a5,a5,a4
ffffffffc0200374:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc0200376:	09778c63          	beq	a5,s7,ffffffffc020040e <dtb_init+0x1ee>
ffffffffc020037a:	00fbea63          	bltu	s7,a5,ffffffffc020038e <dtb_init+0x16e>
ffffffffc020037e:	07a78663          	beq	a5,s10,ffffffffc02003ea <dtb_init+0x1ca>
ffffffffc0200382:	4709                	li	a4,2
ffffffffc0200384:	00e79763          	bne	a5,a4,ffffffffc0200392 <dtb_init+0x172>
ffffffffc0200388:	4c81                	li	s9,0
ffffffffc020038a:	8a56                	mv	s4,s5
ffffffffc020038c:	bf6d                	j	ffffffffc0200346 <dtb_init+0x126>
ffffffffc020038e:	ffb78ee3          	beq	a5,s11,ffffffffc020038a <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc0200392:	00001517          	auipc	a0,0x1
ffffffffc0200396:	4ae50513          	addi	a0,a0,1198 # ffffffffc0201840 <etext+0x210>
ffffffffc020039a:	db3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	4da50513          	addi	a0,a0,1242 # ffffffffc0201878 <etext+0x248>
}
ffffffffc02003a6:	7446                	ld	s0,112(sp)
ffffffffc02003a8:	70e6                	ld	ra,120(sp)
ffffffffc02003aa:	74a6                	ld	s1,104(sp)
ffffffffc02003ac:	7906                	ld	s2,96(sp)
ffffffffc02003ae:	69e6                	ld	s3,88(sp)
ffffffffc02003b0:	6a46                	ld	s4,80(sp)
ffffffffc02003b2:	6aa6                	ld	s5,72(sp)
ffffffffc02003b4:	6b06                	ld	s6,64(sp)
ffffffffc02003b6:	7be2                	ld	s7,56(sp)
ffffffffc02003b8:	7c42                	ld	s8,48(sp)
ffffffffc02003ba:	7ca2                	ld	s9,40(sp)
ffffffffc02003bc:	7d02                	ld	s10,32(sp)
ffffffffc02003be:	6de2                	ld	s11,24(sp)
ffffffffc02003c0:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc02003c2:	b369                	j	ffffffffc020014c <cprintf>
}
ffffffffc02003c4:	7446                	ld	s0,112(sp)
ffffffffc02003c6:	70e6                	ld	ra,120(sp)
ffffffffc02003c8:	74a6                	ld	s1,104(sp)
ffffffffc02003ca:	7906                	ld	s2,96(sp)
ffffffffc02003cc:	69e6                	ld	s3,88(sp)
ffffffffc02003ce:	6a46                	ld	s4,80(sp)
ffffffffc02003d0:	6aa6                	ld	s5,72(sp)
ffffffffc02003d2:	6b06                	ld	s6,64(sp)
ffffffffc02003d4:	7be2                	ld	s7,56(sp)
ffffffffc02003d6:	7c42                	ld	s8,48(sp)
ffffffffc02003d8:	7ca2                	ld	s9,40(sp)
ffffffffc02003da:	7d02                	ld	s10,32(sp)
ffffffffc02003dc:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003de:	00001517          	auipc	a0,0x1
ffffffffc02003e2:	3ba50513          	addi	a0,a0,954 # ffffffffc0201798 <etext+0x168>
}
ffffffffc02003e6:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003e8:	b395                	j	ffffffffc020014c <cprintf>
                int name_len = strlen(name);
ffffffffc02003ea:	8556                	mv	a0,s5
ffffffffc02003ec:	1b8010ef          	jal	ra,ffffffffc02015a4 <strlen>
ffffffffc02003f0:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003f2:	4619                	li	a2,6
ffffffffc02003f4:	85a6                	mv	a1,s1
ffffffffc02003f6:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02003f8:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003fa:	1fe010ef          	jal	ra,ffffffffc02015f8 <strncmp>
ffffffffc02003fe:	e111                	bnez	a0,ffffffffc0200402 <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc0200400:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc0200402:	0a91                	addi	s5,s5,4
ffffffffc0200404:	9ad2                	add	s5,s5,s4
ffffffffc0200406:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc020040a:	8a56                	mv	s4,s5
ffffffffc020040c:	bf2d                	j	ffffffffc0200346 <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc020040e:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200412:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200416:	0087d71b          	srliw	a4,a5,0x8
ffffffffc020041a:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020041e:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200422:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200426:	0107d79b          	srliw	a5,a5,0x10
ffffffffc020042a:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020042e:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200432:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200436:	00eaeab3          	or	s5,s5,a4
ffffffffc020043a:	00fb77b3          	and	a5,s6,a5
ffffffffc020043e:	00faeab3          	or	s5,s5,a5
ffffffffc0200442:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200444:	000c9c63          	bnez	s9,ffffffffc020045c <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc0200448:	1a82                	slli	s5,s5,0x20
ffffffffc020044a:	00368793          	addi	a5,a3,3
ffffffffc020044e:	020ada93          	srli	s5,s5,0x20
ffffffffc0200452:	9abe                	add	s5,s5,a5
ffffffffc0200454:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc0200458:	8a56                	mv	s4,s5
ffffffffc020045a:	b5f5                	j	ffffffffc0200346 <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc020045c:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200460:	85ca                	mv	a1,s2
ffffffffc0200462:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200464:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200468:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020046c:	0187971b          	slliw	a4,a5,0x18
ffffffffc0200470:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200474:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200478:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020047a:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020047e:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200482:	8d59                	or	a0,a0,a4
ffffffffc0200484:	00fb77b3          	and	a5,s6,a5
ffffffffc0200488:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc020048a:	1502                	slli	a0,a0,0x20
ffffffffc020048c:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020048e:	9522                	add	a0,a0,s0
ffffffffc0200490:	14a010ef          	jal	ra,ffffffffc02015da <strcmp>
ffffffffc0200494:	66a2                	ld	a3,8(sp)
ffffffffc0200496:	f94d                	bnez	a0,ffffffffc0200448 <dtb_init+0x228>
ffffffffc0200498:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200448 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc020049c:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc02004a0:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc02004a4:	00001517          	auipc	a0,0x1
ffffffffc02004a8:	32c50513          	addi	a0,a0,812 # ffffffffc02017d0 <etext+0x1a0>
           fdt32_to_cpu(x >> 32);
ffffffffc02004ac:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004b0:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc02004b4:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004b8:	0187de1b          	srliw	t3,a5,0x18
ffffffffc02004bc:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004c0:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004c4:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004c8:	0187d693          	srli	a3,a5,0x18
ffffffffc02004cc:	01861f1b          	slliw	t5,a2,0x18
ffffffffc02004d0:	0087579b          	srliw	a5,a4,0x8
ffffffffc02004d4:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004d8:	0106561b          	srliw	a2,a2,0x10
ffffffffc02004dc:	010f6f33          	or	t5,t5,a6
ffffffffc02004e0:	0187529b          	srliw	t0,a4,0x18
ffffffffc02004e4:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004e8:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004ec:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004f0:	0186f6b3          	and	a3,a3,s8
ffffffffc02004f4:	01859e1b          	slliw	t3,a1,0x18
ffffffffc02004f8:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004fc:	0107581b          	srliw	a6,a4,0x10
ffffffffc0200500:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200504:	8361                	srli	a4,a4,0x18
ffffffffc0200506:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020050a:	0105d59b          	srliw	a1,a1,0x10
ffffffffc020050e:	01e6e6b3          	or	a3,a3,t5
ffffffffc0200512:	00cb7633          	and	a2,s6,a2
ffffffffc0200516:	0088181b          	slliw	a6,a6,0x8
ffffffffc020051a:	0085959b          	slliw	a1,a1,0x8
ffffffffc020051e:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200522:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200526:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020052a:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020052e:	0088989b          	slliw	a7,a7,0x8
ffffffffc0200532:	011b78b3          	and	a7,s6,a7
ffffffffc0200536:	005eeeb3          	or	t4,t4,t0
ffffffffc020053a:	00c6e733          	or	a4,a3,a2
ffffffffc020053e:	006c6c33          	or	s8,s8,t1
ffffffffc0200542:	010b76b3          	and	a3,s6,a6
ffffffffc0200546:	00bb7b33          	and	s6,s6,a1
ffffffffc020054a:	01d7e7b3          	or	a5,a5,t4
ffffffffc020054e:	016c6b33          	or	s6,s8,s6
ffffffffc0200552:	01146433          	or	s0,s0,a7
ffffffffc0200556:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc0200558:	1702                	slli	a4,a4,0x20
ffffffffc020055a:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020055c:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc020055e:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200560:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200562:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200566:	0167eb33          	or	s6,a5,s6
ffffffffc020056a:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc020056c:	be1ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc0200570:	85a2                	mv	a1,s0
ffffffffc0200572:	00001517          	auipc	a0,0x1
ffffffffc0200576:	27e50513          	addi	a0,a0,638 # ffffffffc02017f0 <etext+0x1c0>
ffffffffc020057a:	bd3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020057e:	014b5613          	srli	a2,s6,0x14
ffffffffc0200582:	85da                	mv	a1,s6
ffffffffc0200584:	00001517          	auipc	a0,0x1
ffffffffc0200588:	28450513          	addi	a0,a0,644 # ffffffffc0201808 <etext+0x1d8>
ffffffffc020058c:	bc1ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200590:	008b05b3          	add	a1,s6,s0
ffffffffc0200594:	15fd                	addi	a1,a1,-1
ffffffffc0200596:	00001517          	auipc	a0,0x1
ffffffffc020059a:	29250513          	addi	a0,a0,658 # ffffffffc0201828 <etext+0x1f8>
ffffffffc020059e:	bafff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB init completed\n");
ffffffffc02005a2:	00001517          	auipc	a0,0x1
ffffffffc02005a6:	2d650513          	addi	a0,a0,726 # ffffffffc0201878 <etext+0x248>
        memory_base = mem_base;
ffffffffc02005aa:	00006797          	auipc	a5,0x6
ffffffffc02005ae:	b687bf23          	sd	s0,-1154(a5) # ffffffffc0206128 <memory_base>
        memory_size = mem_size;
ffffffffc02005b2:	00006797          	auipc	a5,0x6
ffffffffc02005b6:	b767bf23          	sd	s6,-1154(a5) # ffffffffc0206130 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc02005ba:	b3f5                	j	ffffffffc02003a6 <dtb_init+0x186>

ffffffffc02005bc <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02005bc:	00006517          	auipc	a0,0x6
ffffffffc02005c0:	b6c53503          	ld	a0,-1172(a0) # ffffffffc0206128 <memory_base>
ffffffffc02005c4:	8082                	ret

ffffffffc02005c6 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
ffffffffc02005c6:	00006517          	auipc	a0,0x6
ffffffffc02005ca:	b6a53503          	ld	a0,-1174(a0) # ffffffffc0206130 <memory_size>
ffffffffc02005ce:	8082                	ret

ffffffffc02005d0 <buddy_init>:
}

static void
buddy_init(void) {
    // 初始化所有空闲链表
    nr_free = 0;
ffffffffc02005d0:	00006797          	auipc	a5,0x6
ffffffffc02005d4:	b607b423          	sd	zero,-1176(a5) # ffffffffc0206138 <nr_free>
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc02005d8:	00006797          	auipc	a5,0x6
ffffffffc02005dc:	a4078793          	addi	a5,a5,-1472 # ffffffffc0206018 <free_lists>
ffffffffc02005e0:	00006717          	auipc	a4,0x6
ffffffffc02005e4:	b4070713          	addi	a4,a4,-1216 # ffffffffc0206120 <is_panic>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02005e8:	e79c                	sd	a5,8(a5)
ffffffffc02005ea:	e39c                	sd	a5,0(a5)
        list_init(&(free_lists[i].free_list));
        free_lists[i].nr_free = 0;
ffffffffc02005ec:	0007a823          	sw	zero,16(a5)
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc02005f0:	07e1                	addi	a5,a5,24
ffffffffc02005f2:	fee79be3          	bne	a5,a4,ffffffffc02005e8 <buddy_init+0x18>
    }
}
ffffffffc02005f6:	8082                	ret

ffffffffc02005f8 <buddy_nr_free_pages>:
}

static size_t
buddy_nr_free_pages(void) {
    size_t total = 0;
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc02005f8:	00006697          	auipc	a3,0x6
ffffffffc02005fc:	a3068693          	addi	a3,a3,-1488 # ffffffffc0206028 <free_lists+0x10>
ffffffffc0200600:	4701                	li	a4,0
    size_t total = 0;
ffffffffc0200602:	4501                	li	a0,0
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200604:	462d                	li	a2,11
        total += free_lists[i].nr_free * (1 << i);
ffffffffc0200606:	429c                	lw	a5,0(a3)
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200608:	06e1                	addi	a3,a3,24
        total += free_lists[i].nr_free * (1 << i);
ffffffffc020060a:	00e797bb          	sllw	a5,a5,a4
ffffffffc020060e:	1782                	slli	a5,a5,0x20
ffffffffc0200610:	9381                	srli	a5,a5,0x20
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200612:	2705                	addiw	a4,a4,1
        total += free_lists[i].nr_free * (1 << i);
ffffffffc0200614:	953e                	add	a0,a0,a5
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200616:	fec718e3          	bne	a4,a2,ffffffffc0200606 <buddy_nr_free_pages+0xe>
    }
    return total;
}
ffffffffc020061a:	8082                	ret

ffffffffc020061c <buddy_free_pages>:
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc020061c:	1101                	addi	sp,sp,-32
ffffffffc020061e:	ec06                	sd	ra,24(sp)
ffffffffc0200620:	e822                	sd	s0,16(sp)
ffffffffc0200622:	e426                	sd	s1,8(sp)
ffffffffc0200624:	e04a                	sd	s2,0(sp)
    assert(n > 0);
ffffffffc0200626:	18058b63          	beqz	a1,ffffffffc02007bc <buddy_free_pages+0x1a0>
    while (size < n) {
ffffffffc020062a:	4705                	li	a4,1
    int order = 0;
ffffffffc020062c:	4681                	li	a3,0
    size_t size = 1;
ffffffffc020062e:	4785                	li	a5,1
    while (size < n) {
ffffffffc0200630:	14e58c63          	beq	a1,a4,ffffffffc0200788 <buddy_free_pages+0x16c>
        size <<= 1;
ffffffffc0200634:	0786                	slli	a5,a5,0x1
        order++;
ffffffffc0200636:	2685                	addiw	a3,a3,1
    while (size < n) {
ffffffffc0200638:	feb7eee3          	bltu	a5,a1,ffffffffc0200634 <buddy_free_pages+0x18>
    for (; p != base + (1 << order); p++) {
ffffffffc020063c:	4805                	li	a6,1
ffffffffc020063e:	00d8183b          	sllw	a6,a6,a3
ffffffffc0200642:	00281613          	slli	a2,a6,0x2
ffffffffc0200646:	9642                	add	a2,a2,a6
ffffffffc0200648:	060e                	slli	a2,a2,0x3
ffffffffc020064a:	962a                	add	a2,a2,a0
ffffffffc020064c:	85c2                	mv	a1,a6
ffffffffc020064e:	02c50263          	beq	a0,a2,ffffffffc0200672 <buddy_free_pages+0x56>
    int order = 0;
ffffffffc0200652:	87aa                	mv	a5,a0
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200654:	6798                	ld	a4,8(a5)
ffffffffc0200656:	8b0d                	andi	a4,a4,3
ffffffffc0200658:	14071263          	bnez	a4,ffffffffc020079c <buddy_free_pages+0x180>
        p->flags = 0;
ffffffffc020065c:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200660:	0007a023          	sw	zero,0(a5)
    for (; p != base + (1 << order); p++) {
ffffffffc0200664:	02878793          	addi	a5,a5,40
ffffffffc0200668:	fec796e3          	bne	a5,a2,ffffffffc0200654 <buddy_free_pages+0x38>
    nr_free += (1 << current_order);
ffffffffc020066c:	4585                	li	a1,1
ffffffffc020066e:	00d595bb          	sllw	a1,a1,a3
    SetPageProperty(base);
ffffffffc0200672:	651c                	ld	a5,8(a0)
ffffffffc0200674:	00006417          	auipc	s0,0x6
ffffffffc0200678:	ac440413          	addi	s0,s0,-1340 # ffffffffc0206138 <nr_free>
    base->property = 1 << order;
ffffffffc020067c:	01052823          	sw	a6,16(a0)
    SetPageProperty(base);
ffffffffc0200680:	0027e793          	ori	a5,a5,2
ffffffffc0200684:	e51c                	sd	a5,8(a0)
    while (current_order < MAX_ORDER) {
ffffffffc0200686:	47a5                	li	a5,9
ffffffffc0200688:	6004                	ld	s1,0(s0)
ffffffffc020068a:	10d7c363          	blt	a5,a3,ffffffffc0200790 <buddy_free_pages+0x174>
        if (buddy < pages || buddy >= pages + npage || 
ffffffffc020068e:	00006797          	auipc	a5,0x6
ffffffffc0200692:	ab27b783          	ld	a5,-1358(a5) # ffffffffc0206140 <npage>
ffffffffc0200696:	00279f13          	slli	t5,a5,0x2
ffffffffc020069a:	00169613          	slli	a2,a3,0x1
ffffffffc020069e:	9f3e                	add	t5,t5,a5
ffffffffc02006a0:	9636                	add	a2,a2,a3
    uintptr_t page_idx = page - pages;
ffffffffc02006a2:	00006817          	auipc	a6,0x6
ffffffffc02006a6:	aa683803          	ld	a6,-1370(a6) # ffffffffc0206148 <pages>
        if (buddy < pages || buddy >= pages + npage || 
ffffffffc02006aa:	0f0e                	slli	t5,t5,0x3
ffffffffc02006ac:	00006397          	auipc	t2,0x6
ffffffffc02006b0:	96c38393          	addi	t2,t2,-1684 # ffffffffc0206018 <free_lists>
ffffffffc02006b4:	060e                	slli	a2,a2,0x3
ffffffffc02006b6:	9f42                	add	t5,t5,a6
ffffffffc02006b8:	961e                	add	a2,a2,t2
ffffffffc02006ba:	8e26                	mv	t3,s1
ffffffffc02006bc:	4301                	li	t1,0
ffffffffc02006be:	00002f97          	auipc	t6,0x2
ffffffffc02006c2:	a8afbf83          	ld	t6,-1398(t6) # ffffffffc0202148 <error_string+0x38>
    uintptr_t buddy_idx = page_idx ^ (1 << order);
ffffffffc02006c6:	4e85                	li	t4,1
    while (current_order < MAX_ORDER) {
ffffffffc02006c8:	42a9                	li	t0,10
ffffffffc02006ca:	a0b1                	j	ffffffffc0200716 <buddy_free_pages+0xfa>
        if (buddy < pages || buddy >= pages + npage || 
ffffffffc02006cc:	07e7f563          	bgeu	a5,t5,ffffffffc0200736 <buddy_free_pages+0x11a>
            !PageProperty(buddy) || buddy->property != (1 << current_order)) {
ffffffffc02006d0:	6798                	ld	a4,8(a5)
ffffffffc02006d2:	00277893          	andi	a7,a4,2
        if (buddy < pages || buddy >= pages + npage || 
ffffffffc02006d6:	06088063          	beqz	a7,ffffffffc0200736 <buddy_free_pages+0x11a>
            !PageProperty(buddy) || buddy->property != (1 << current_order)) {
ffffffffc02006da:	0107a883          	lw	a7,16(a5)
ffffffffc02006de:	08b89e63          	bne	a7,a1,ffffffffc020077a <buddy_free_pages+0x15e>
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
ffffffffc02006e2:	0187b903          	ld	s2,24(a5)
ffffffffc02006e6:	0207b303          	ld	t1,32(a5)
        free_lists[current_order].nr_free--;
ffffffffc02006ea:	4a0c                	lw	a1,16(a2)
        ClearPageProperty(buddy);
ffffffffc02006ec:	9b75                	andi	a4,a4,-3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02006ee:	00693423          	sd	t1,8(s2)
    next->prev = prev;
ffffffffc02006f2:	01233023          	sd	s2,0(t1)
        free_lists[current_order].nr_free--;
ffffffffc02006f6:	35fd                	addiw	a1,a1,-1
ffffffffc02006f8:	ca0c                	sw	a1,16(a2)
        ClearPageProperty(buddy);
ffffffffc02006fa:	e798                	sd	a4,8(a5)
        nr_free -= (1 << current_order);
ffffffffc02006fc:	411e0e33          	sub	t3,t3,a7
        if (buddy < current_block) {
ffffffffc0200700:	00a7f363          	bgeu	a5,a0,ffffffffc0200706 <buddy_free_pages+0xea>
ffffffffc0200704:	853e                	mv	a0,a5
        current_order++;
ffffffffc0200706:	2685                	addiw	a3,a3,1
        current_block->property = 1 << current_order;
ffffffffc0200708:	00de97bb          	sllw	a5,t4,a3
ffffffffc020070c:	c91c                	sw	a5,16(a0)
    while (current_order < MAX_ORDER) {
ffffffffc020070e:	0661                	addi	a2,a2,24
ffffffffc0200710:	4305                	li	t1,1
ffffffffc0200712:	06568863          	beq	a3,t0,ffffffffc0200782 <buddy_free_pages+0x166>
    uintptr_t page_idx = page - pages;
ffffffffc0200716:	410507b3          	sub	a5,a0,a6
ffffffffc020071a:	878d                	srai	a5,a5,0x3
ffffffffc020071c:	03f787b3          	mul	a5,a5,t6
    uintptr_t buddy_idx = page_idx ^ (1 << order);
ffffffffc0200720:	00de95bb          	sllw	a1,t4,a3
ffffffffc0200724:	00b7c733          	xor	a4,a5,a1
    return pages + buddy_idx;
ffffffffc0200728:	00271793          	slli	a5,a4,0x2
ffffffffc020072c:	97ba                	add	a5,a5,a4
ffffffffc020072e:	078e                	slli	a5,a5,0x3
ffffffffc0200730:	97c2                	add	a5,a5,a6
        if (buddy < pages || buddy >= pages + npage || 
ffffffffc0200732:	f907fde3          	bgeu	a5,a6,ffffffffc02006cc <buddy_free_pages+0xb0>
ffffffffc0200736:	00030463          	beqz	t1,ffffffffc020073e <buddy_free_pages+0x122>
ffffffffc020073a:	01c43023          	sd	t3,0(s0)
    nr_free += (1 << current_order);
ffffffffc020073e:	00043e03          	ld	t3,0(s0)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200742:	00169793          	slli	a5,a3,0x1
ffffffffc0200746:	96be                	add	a3,a3,a5
ffffffffc0200748:	068e                	slli	a3,a3,0x3
ffffffffc020074a:	93b6                	add	t2,t2,a3
ffffffffc020074c:	0083b703          	ld	a4,8(t2)
    free_lists[current_order].nr_free++;
ffffffffc0200750:	0103a783          	lw	a5,16(t2)
    list_add(&(free_lists[current_order].free_list), &(current_block->page_link));
ffffffffc0200754:	01850693          	addi	a3,a0,24
    prev->next = next->prev = elm;
ffffffffc0200758:	e314                	sd	a3,0(a4)
    nr_free += (1 << current_order);
ffffffffc020075a:	95f2                	add	a1,a1,t3
ffffffffc020075c:	00d3b423          	sd	a3,8(t2)
}
ffffffffc0200760:	60e2                	ld	ra,24(sp)
    nr_free += (1 << current_order);
ffffffffc0200762:	e00c                	sd	a1,0(s0)
}
ffffffffc0200764:	6442                	ld	s0,16(sp)
    elm->next = next;
ffffffffc0200766:	f118                	sd	a4,32(a0)
    elm->prev = prev;
ffffffffc0200768:	00753c23          	sd	t2,24(a0)
    free_lists[current_order].nr_free++;
ffffffffc020076c:	2785                	addiw	a5,a5,1
ffffffffc020076e:	00f3a823          	sw	a5,16(t2)
}
ffffffffc0200772:	64a2                	ld	s1,8(sp)
ffffffffc0200774:	6902                	ld	s2,0(sp)
ffffffffc0200776:	6105                	addi	sp,sp,32
ffffffffc0200778:	8082                	ret
ffffffffc020077a:	fc0314e3          	bnez	t1,ffffffffc0200742 <buddy_free_pages+0x126>
            !PageProperty(buddy) || buddy->property != (1 << current_order)) {
ffffffffc020077e:	8e26                	mv	t3,s1
ffffffffc0200780:	b7c9                	j	ffffffffc0200742 <buddy_free_pages+0x126>
ffffffffc0200782:	40000593          	li	a1,1024
ffffffffc0200786:	bf75                	j	ffffffffc0200742 <buddy_free_pages+0x126>
    for (; p != base + (1 << order); p++) {
ffffffffc0200788:	02850613          	addi	a2,a0,40
ffffffffc020078c:	4805                	li	a6,1
ffffffffc020078e:	b5d1                	j	ffffffffc0200652 <buddy_free_pages+0x36>
    while (current_order < MAX_ORDER) {
ffffffffc0200790:	8e26                	mv	t3,s1
ffffffffc0200792:	00006397          	auipc	t2,0x6
ffffffffc0200796:	88638393          	addi	t2,t2,-1914 # ffffffffc0206018 <free_lists>
ffffffffc020079a:	b765                	j	ffffffffc0200742 <buddy_free_pages+0x126>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020079c:	00001697          	auipc	a3,0x1
ffffffffc02007a0:	12c68693          	addi	a3,a3,300 # ffffffffc02018c8 <etext+0x298>
ffffffffc02007a4:	00001617          	auipc	a2,0x1
ffffffffc02007a8:	0f460613          	addi	a2,a2,244 # ffffffffc0201898 <etext+0x268>
ffffffffc02007ac:	0c600593          	li	a1,198
ffffffffc02007b0:	00001517          	auipc	a0,0x1
ffffffffc02007b4:	10050513          	addi	a0,a0,256 # ffffffffc02018b0 <etext+0x280>
ffffffffc02007b8:	a0bff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc02007bc:	00001697          	auipc	a3,0x1
ffffffffc02007c0:	0d468693          	addi	a3,a3,212 # ffffffffc0201890 <etext+0x260>
ffffffffc02007c4:	00001617          	auipc	a2,0x1
ffffffffc02007c8:	0d460613          	addi	a2,a2,212 # ffffffffc0201898 <etext+0x268>
ffffffffc02007cc:	0bf00593          	li	a1,191
ffffffffc02007d0:	00001517          	auipc	a0,0x1
ffffffffc02007d4:	0e050513          	addi	a0,a0,224 # ffffffffc02018b0 <etext+0x280>
ffffffffc02007d8:	9ebff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02007dc <buddy_alloc_pages>:
    assert(n > 0);
ffffffffc02007dc:	cd6d                	beqz	a0,ffffffffc02008d6 <buddy_alloc_pages+0xfa>
    if (n > (1 << MAX_ORDER)) {
ffffffffc02007de:	40000793          	li	a5,1024
ffffffffc02007e2:	0ea7e863          	bltu	a5,a0,ffffffffc02008d2 <buddy_alloc_pages+0xf6>
    while (size < n) {
ffffffffc02007e6:	4785                	li	a5,1
    int order = 0;
ffffffffc02007e8:	4601                	li	a2,0
    while (size < n) {
ffffffffc02007ea:	00f50963          	beq	a0,a5,ffffffffc02007fc <buddy_alloc_pages+0x20>
        size <<= 1;
ffffffffc02007ee:	0786                	slli	a5,a5,0x1
        order++;
ffffffffc02007f0:	2605                	addiw	a2,a2,1
    while (size < n) {
ffffffffc02007f2:	fea7eee3          	bltu	a5,a0,ffffffffc02007ee <buddy_alloc_pages+0x12>
    while (current_order <= MAX_ORDER) {
ffffffffc02007f6:	47a9                	li	a5,10
ffffffffc02007f8:	0cc7cd63          	blt	a5,a2,ffffffffc02008d2 <buddy_alloc_pages+0xf6>
ffffffffc02007fc:	00161793          	slli	a5,a2,0x1
ffffffffc0200800:	97b2                	add	a5,a5,a2
ffffffffc0200802:	00006697          	auipc	a3,0x6
ffffffffc0200806:	81668693          	addi	a3,a3,-2026 # ffffffffc0206018 <free_lists>
ffffffffc020080a:	078e                	slli	a5,a5,0x3
ffffffffc020080c:	97b6                	add	a5,a5,a3
    int order = 0;
ffffffffc020080e:	8732                	mv	a4,a2
    while (current_order <= MAX_ORDER) {
ffffffffc0200810:	452d                	li	a0,11
ffffffffc0200812:	a029                	j	ffffffffc020081c <buddy_alloc_pages+0x40>
        current_order++;
ffffffffc0200814:	2705                	addiw	a4,a4,1
    while (current_order <= MAX_ORDER) {
ffffffffc0200816:	07e1                	addi	a5,a5,24
ffffffffc0200818:	0aa70d63          	beq	a4,a0,ffffffffc02008d2 <buddy_alloc_pages+0xf6>
    return list->next == list;
ffffffffc020081c:	678c                	ld	a1,8(a5)
        if (!list_empty(&(free_lists[current_order].free_list))) {
ffffffffc020081e:	fef58be3          	beq	a1,a5,ffffffffc0200814 <buddy_alloc_pages+0x38>
            free_lists[current_order].nr_free--;
ffffffffc0200822:	00171793          	slli	a5,a4,0x1
ffffffffc0200826:	97ba                	add	a5,a5,a4
    __list_del(listelm->prev, listelm->next);
ffffffffc0200828:	0085b803          	ld	a6,8(a1)
ffffffffc020082c:	0005be03          	ld	t3,0(a1)
ffffffffc0200830:	078e                	slli	a5,a5,0x3
ffffffffc0200832:	00f68333          	add	t1,a3,a5
ffffffffc0200836:	01032883          	lw	a7,16(t1)
            nr_free -= (1 << current_order);
ffffffffc020083a:	00006f97          	auipc	t6,0x6
ffffffffc020083e:	8fef8f93          	addi	t6,t6,-1794 # ffffffffc0206138 <nr_free>
            ClearPageProperty(page);
ffffffffc0200842:	ff05b503          	ld	a0,-16(a1)
            nr_free -= (1 << current_order);
ffffffffc0200846:	000fbe83          	ld	t4,0(t6)
    prev->next = next;
ffffffffc020084a:	010e3423          	sd	a6,8(t3)
    next->prev = prev;
ffffffffc020084e:	01c83023          	sd	t3,0(a6)
ffffffffc0200852:	4805                	li	a6,1
            free_lists[current_order].nr_free--;
ffffffffc0200854:	38fd                	addiw	a7,a7,-1
            nr_free -= (1 << current_order);
ffffffffc0200856:	00e8183b          	sllw	a6,a6,a4
            ClearPageProperty(page);
ffffffffc020085a:	9975                	andi	a0,a0,-3
            free_lists[current_order].nr_free--;
ffffffffc020085c:	01132823          	sw	a7,16(t1)
            nr_free -= (1 << current_order);
ffffffffc0200860:	410e8eb3          	sub	t4,t4,a6
            ClearPageProperty(page);
ffffffffc0200864:	fea5b823          	sd	a0,-16(a1)
            nr_free -= (1 << current_order);
ffffffffc0200868:	01dfb023          	sd	t4,0(t6)
            struct Page *page = le2page(le, page_link);
ffffffffc020086c:	fe858513          	addi	a0,a1,-24
            while (current_order > order) {
ffffffffc0200870:	04e65b63          	bge	a2,a4,ffffffffc02008c6 <buddy_alloc_pages+0xea>
ffffffffc0200874:	17a1                	addi	a5,a5,-24
ffffffffc0200876:	96be                	add	a3,a3,a5
                struct Page *buddy = page + (1 << current_order);
ffffffffc0200878:	4f05                	li	t5,1
                current_order--;
ffffffffc020087a:	377d                	addiw	a4,a4,-1
                struct Page *buddy = page + (1 << current_order);
ffffffffc020087c:	00ef183b          	sllw	a6,t5,a4
ffffffffc0200880:	00281793          	slli	a5,a6,0x2
ffffffffc0200884:	97c2                	add	a5,a5,a6
ffffffffc0200886:	078e                	slli	a5,a5,0x3
ffffffffc0200888:	97aa                	add	a5,a5,a0
                SetPageProperty(buddy);
ffffffffc020088a:	0087b303          	ld	t1,8(a5)
    __list_add(elm, listelm, listelm->next);
ffffffffc020088e:	0086be03          	ld	t3,8(a3)
                buddy->property = 1 << current_order;
ffffffffc0200892:	0107a823          	sw	a6,16(a5)
                SetPageProperty(buddy);
ffffffffc0200896:	00236313          	ori	t1,t1,2
                free_lists[current_order].nr_free++;
ffffffffc020089a:	0106a883          	lw	a7,16(a3)
                SetPageProperty(buddy);
ffffffffc020089e:	0067b423          	sd	t1,8(a5)
                list_add(&(free_lists[current_order].free_list), &(buddy->page_link));
ffffffffc02008a2:	01878313          	addi	t1,a5,24
    prev->next = next->prev = elm;
ffffffffc02008a6:	006e3023          	sd	t1,0(t3)
ffffffffc02008aa:	0066b423          	sd	t1,8(a3)
    elm->prev = prev;
ffffffffc02008ae:	ef94                	sd	a3,24(a5)
    elm->next = next;
ffffffffc02008b0:	03c7b023          	sd	t3,32(a5)
                free_lists[current_order].nr_free++;
ffffffffc02008b4:	0018879b          	addiw	a5,a7,1
ffffffffc02008b8:	ca9c                	sw	a5,16(a3)
                nr_free += (1 << current_order);
ffffffffc02008ba:	9ec2                	add	t4,t4,a6
            while (current_order > order) {
ffffffffc02008bc:	16a1                	addi	a3,a3,-24
ffffffffc02008be:	fae61ee3          	bne	a2,a4,ffffffffc020087a <buddy_alloc_pages+0x9e>
ffffffffc02008c2:	01dfb023          	sd	t4,0(t6)
            page->property = 1 << order;
ffffffffc02008c6:	4785                	li	a5,1
ffffffffc02008c8:	00c7963b          	sllw	a2,a5,a2
ffffffffc02008cc:	fec5ac23          	sw	a2,-8(a1)
            return page;
ffffffffc02008d0:	8082                	ret
        return NULL;
ffffffffc02008d2:	4501                	li	a0,0
}
ffffffffc02008d4:	8082                	ret
buddy_alloc_pages(size_t n) {
ffffffffc02008d6:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02008d8:	00001697          	auipc	a3,0x1
ffffffffc02008dc:	fb868693          	addi	a3,a3,-72 # ffffffffc0201890 <etext+0x260>
ffffffffc02008e0:	00001617          	auipc	a2,0x1
ffffffffc02008e4:	fb860613          	addi	a2,a2,-72 # ffffffffc0201898 <etext+0x268>
ffffffffc02008e8:	08d00593          	li	a1,141
ffffffffc02008ec:	00001517          	auipc	a0,0x1
ffffffffc02008f0:	fc450513          	addi	a0,a0,-60 # ffffffffc02018b0 <etext+0x280>
buddy_alloc_pages(size_t n) {
ffffffffc02008f4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02008f6:	8cdff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02008fa <buddy_init_memmap>:
buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc02008fa:	1141                	addi	sp,sp,-16
ffffffffc02008fc:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02008fe:	10058063          	beqz	a1,ffffffffc02009fe <buddy_init_memmap+0x104>
    for (; p != base + n; p++) {
ffffffffc0200902:	00259693          	slli	a3,a1,0x2
ffffffffc0200906:	96ae                	add	a3,a3,a1
ffffffffc0200908:	068e                	slli	a3,a3,0x3
ffffffffc020090a:	96aa                	add	a3,a3,a0
ffffffffc020090c:	87aa                	mv	a5,a0
ffffffffc020090e:	00d50f63          	beq	a0,a3,ffffffffc020092c <buddy_init_memmap+0x32>
        assert(PageReserved(p));
ffffffffc0200912:	6798                	ld	a4,8(a5)
ffffffffc0200914:	8b05                	andi	a4,a4,1
ffffffffc0200916:	c761                	beqz	a4,ffffffffc02009de <buddy_init_memmap+0xe4>
        p->flags = 0;
ffffffffc0200918:	0007b423          	sd	zero,8(a5)
        p->property = 0;
ffffffffc020091c:	0007a823          	sw	zero,16(a5)
ffffffffc0200920:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++) {
ffffffffc0200924:	02878793          	addi	a5,a5,40
ffffffffc0200928:	fed795e3          	bne	a5,a3,ffffffffc0200912 <buddy_init_memmap+0x18>
ffffffffc020092c:	00006f97          	auipc	t6,0x6
ffffffffc0200930:	80cf8f93          	addi	t6,t6,-2036 # ffffffffc0206138 <nr_free>
ffffffffc0200934:	000fb303          	ld	t1,0(t6)
ffffffffc0200938:	00005e17          	auipc	t3,0x5
ffffffffc020093c:	6e0e0e13          	addi	t3,t3,1760 # ffffffffc0206018 <free_lists>
        while (block_size * 2 <= current_size && order < MAX_ORDER) {
ffffffffc0200940:	4e85                	li	t4,1
ffffffffc0200942:	4829                	li	a6,10
        current_base += block_size;
ffffffffc0200944:	00005f17          	auipc	t5,0x5
ffffffffc0200948:	7c4f0f13          	addi	t5,t5,1988 # ffffffffc0206108 <free_lists+0xf0>
        int order = 0;
ffffffffc020094c:	4781                	li	a5,0
ffffffffc020094e:	4709                	li	a4,2
        while (block_size * 2 <= current_size && order < MAX_ORDER) {
ffffffffc0200950:	09d58063          	beq	a1,t4,ffffffffc02009d0 <buddy_init_memmap+0xd6>
            block_size <<= 1;
ffffffffc0200954:	86ba                	mv	a3,a4
        while (block_size * 2 <= current_size && order < MAX_ORDER) {
ffffffffc0200956:	0706                	slli	a4,a4,0x1
            order++;
ffffffffc0200958:	2785                	addiw	a5,a5,1
        while (block_size * 2 <= current_size && order < MAX_ORDER) {
ffffffffc020095a:	04e5ee63          	bltu	a1,a4,ffffffffc02009b6 <buddy_init_memmap+0xbc>
ffffffffc020095e:	ff079be3          	bne	a5,a6,ffffffffc0200954 <buddy_init_memmap+0x5a>
        current_base += block_size;
ffffffffc0200962:	00269613          	slli	a2,a3,0x2
ffffffffc0200966:	9636                	add	a2,a2,a3
        current_base->property = block_size;
ffffffffc0200968:	0006839b          	sext.w	t2,a3
        current_base += block_size;
ffffffffc020096c:	060e                	slli	a2,a2,0x3
ffffffffc020096e:	88fa                	mv	a7,t5
ffffffffc0200970:	00179713          	slli	a4,a5,0x1
    __list_add(elm, listelm, listelm->next);
ffffffffc0200974:	97ba                	add	a5,a5,a4
ffffffffc0200976:	078e                	slli	a5,a5,0x3
        SetPageProperty(current_base);
ffffffffc0200978:	6518                	ld	a4,8(a0)
ffffffffc020097a:	97f2                	add	a5,a5,t3
ffffffffc020097c:	0087b283          	ld	t0,8(a5)
ffffffffc0200980:	00276713          	ori	a4,a4,2
        current_base->property = block_size;
ffffffffc0200984:	00752823          	sw	t2,16(a0)
        SetPageProperty(current_base);
ffffffffc0200988:	e518                	sd	a4,8(a0)
        list_add(&(free_lists[order].free_list), &(current_base->page_link));
ffffffffc020098a:	01850393          	addi	t2,a0,24
        free_lists[order].nr_free++;
ffffffffc020098e:	4b98                	lw	a4,16(a5)
    prev->next = next->prev = elm;
ffffffffc0200990:	0072b023          	sd	t2,0(t0)
ffffffffc0200994:	0077b423          	sd	t2,8(a5)
    elm->next = next;
ffffffffc0200998:	02553023          	sd	t0,32(a0)
    elm->prev = prev;
ffffffffc020099c:	01153c23          	sd	a7,24(a0)
ffffffffc02009a0:	2705                	addiw	a4,a4,1
ffffffffc02009a2:	cb98                	sw	a4,16(a5)
        current_size -= block_size;
ffffffffc02009a4:	8d95                	sub	a1,a1,a3
        nr_free += block_size;
ffffffffc02009a6:	9336                	add	t1,t1,a3
        current_base += block_size;
ffffffffc02009a8:	9532                	add	a0,a0,a2
    while (current_size > 0) {
ffffffffc02009aa:	f1cd                	bnez	a1,ffffffffc020094c <buddy_init_memmap+0x52>
}
ffffffffc02009ac:	60a2                	ld	ra,8(sp)
ffffffffc02009ae:	006fb023          	sd	t1,0(t6)
ffffffffc02009b2:	0141                	addi	sp,sp,16
ffffffffc02009b4:	8082                	ret
        list_add(&(free_lists[order].free_list), &(current_base->page_link));
ffffffffc02009b6:	00179713          	slli	a4,a5,0x1
ffffffffc02009ba:	00f708b3          	add	a7,a4,a5
        current_base += block_size;
ffffffffc02009be:	00269613          	slli	a2,a3,0x2
        list_add(&(free_lists[order].free_list), &(current_base->page_link));
ffffffffc02009c2:	088e                	slli	a7,a7,0x3
        current_base += block_size;
ffffffffc02009c4:	9636                	add	a2,a2,a3
        current_base->property = block_size;
ffffffffc02009c6:	0006839b          	sext.w	t2,a3
        list_add(&(free_lists[order].free_list), &(current_base->page_link));
ffffffffc02009ca:	98f2                	add	a7,a7,t3
        current_base += block_size;
ffffffffc02009cc:	060e                	slli	a2,a2,0x3
ffffffffc02009ce:	b75d                	j	ffffffffc0200974 <buddy_init_memmap+0x7a>
        size_t block_size = 1;
ffffffffc02009d0:	4685                	li	a3,1
        while (block_size * 2 <= current_size && order < MAX_ORDER) {
ffffffffc02009d2:	02800613          	li	a2,40
ffffffffc02009d6:	88f2                	mv	a7,t3
ffffffffc02009d8:	4385                	li	t2,1
ffffffffc02009da:	4701                	li	a4,0
ffffffffc02009dc:	bf61                	j	ffffffffc0200974 <buddy_init_memmap+0x7a>
        assert(PageReserved(p));
ffffffffc02009de:	00001697          	auipc	a3,0x1
ffffffffc02009e2:	f1268693          	addi	a3,a3,-238 # ffffffffc02018f0 <etext+0x2c0>
ffffffffc02009e6:	00001617          	auipc	a2,0x1
ffffffffc02009ea:	eb260613          	addi	a2,a2,-334 # ffffffffc0201898 <etext+0x268>
ffffffffc02009ee:	06900593          	li	a1,105
ffffffffc02009f2:	00001517          	auipc	a0,0x1
ffffffffc02009f6:	ebe50513          	addi	a0,a0,-322 # ffffffffc02018b0 <etext+0x280>
ffffffffc02009fa:	fc8ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc02009fe:	00001697          	auipc	a3,0x1
ffffffffc0200a02:	e9268693          	addi	a3,a3,-366 # ffffffffc0201890 <etext+0x260>
ffffffffc0200a06:	00001617          	auipc	a2,0x1
ffffffffc0200a0a:	e9260613          	addi	a2,a2,-366 # ffffffffc0201898 <etext+0x268>
ffffffffc0200a0e:	06400593          	li	a1,100
ffffffffc0200a12:	00001517          	auipc	a0,0x1
ffffffffc0200a16:	e9e50513          	addi	a0,a0,-354 # ffffffffc02018b0 <etext+0x280>
ffffffffc0200a1a:	fa8ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200a1e <show_buddy_array.constprop.0>:
static void show_buddy_array(int start, int end) {
ffffffffc0200a1e:	7179                	addi	sp,sp,-48
    cprintf("当前内存块分布:\n");
ffffffffc0200a20:	00001517          	auipc	a0,0x1
ffffffffc0200a24:	ee050513          	addi	a0,a0,-288 # ffffffffc0201900 <etext+0x2d0>
static void show_buddy_array(int start, int end) {
ffffffffc0200a28:	f022                	sd	s0,32(sp)
ffffffffc0200a2a:	ec26                	sd	s1,24(sp)
ffffffffc0200a2c:	e84a                	sd	s2,16(sp)
ffffffffc0200a2e:	e44e                	sd	s3,8(sp)
ffffffffc0200a30:	e052                	sd	s4,0(sp)
ffffffffc0200a32:	f406                	sd	ra,40(sp)
ffffffffc0200a34:	00005497          	auipc	s1,0x5
ffffffffc0200a38:	5f448493          	addi	s1,s1,1524 # ffffffffc0206028 <free_lists+0x10>
    cprintf("当前内存块分布:\n");
ffffffffc0200a3c:	f10ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = start; i <= end && i <= MAX_ORDER; i++) {
ffffffffc0200a40:	4401                	li	s0,0
        cprintf("Order %d (size %d页): %d块\n", 
ffffffffc0200a42:	4a05                	li	s4,1
ffffffffc0200a44:	00001997          	auipc	s3,0x1
ffffffffc0200a48:	ed498993          	addi	s3,s3,-300 # ffffffffc0201918 <etext+0x2e8>
    for (int i = start; i <= end && i <= MAX_ORDER; i++) {
ffffffffc0200a4c:	492d                	li	s2,11
        cprintf("Order %d (size %d页): %d块\n", 
ffffffffc0200a4e:	4094                	lw	a3,0(s1)
ffffffffc0200a50:	008a163b          	sllw	a2,s4,s0
ffffffffc0200a54:	85a2                	mv	a1,s0
ffffffffc0200a56:	854e                	mv	a0,s3
    for (int i = start; i <= end && i <= MAX_ORDER; i++) {
ffffffffc0200a58:	2405                	addiw	s0,s0,1
        cprintf("Order %d (size %d页): %d块\n", 
ffffffffc0200a5a:	ef2ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = start; i <= end && i <= MAX_ORDER; i++) {
ffffffffc0200a5e:	04e1                	addi	s1,s1,24
ffffffffc0200a60:	ff2417e3          	bne	s0,s2,ffffffffc0200a4e <show_buddy_array.constprop.0+0x30>
    cprintf("总空闲页数: %d\n", nr_free);
ffffffffc0200a64:	00005597          	auipc	a1,0x5
ffffffffc0200a68:	6d45b583          	ld	a1,1748(a1) # ffffffffc0206138 <nr_free>
ffffffffc0200a6c:	00001517          	auipc	a0,0x1
ffffffffc0200a70:	ecc50513          	addi	a0,a0,-308 # ffffffffc0201938 <etext+0x308>
ffffffffc0200a74:	ed8ff0ef          	jal	ra,ffffffffc020014c <cprintf>
}
ffffffffc0200a78:	7402                	ld	s0,32(sp)
ffffffffc0200a7a:	70a2                	ld	ra,40(sp)
ffffffffc0200a7c:	64e2                	ld	s1,24(sp)
ffffffffc0200a7e:	6942                	ld	s2,16(sp)
ffffffffc0200a80:	69a2                	ld	s3,8(sp)
ffffffffc0200a82:	6a02                	ld	s4,0(sp)
    cprintf("------------------------\n");
ffffffffc0200a84:	00001517          	auipc	a0,0x1
ffffffffc0200a88:	ecc50513          	addi	a0,a0,-308 # ffffffffc0201950 <etext+0x320>
}
ffffffffc0200a8c:	6145                	addi	sp,sp,48
    cprintf("------------------------\n");
ffffffffc0200a8e:	ebeff06f          	j	ffffffffc020014c <cprintf>

ffffffffc0200a92 <buddy_system_check>:
    }
}

// 综合测试函数
static void
buddy_system_check(void) {
ffffffffc0200a92:	715d                	addi	sp,sp,-80
    cprintf("BEGIN TO TEST OUR BUDDY SYSTEM!\n");
ffffffffc0200a94:	00001517          	auipc	a0,0x1
ffffffffc0200a98:	edc50513          	addi	a0,a0,-292 # ffffffffc0201970 <etext+0x340>
buddy_system_check(void) {
ffffffffc0200a9c:	e486                	sd	ra,72(sp)
ffffffffc0200a9e:	e0a2                	sd	s0,64(sp)
ffffffffc0200aa0:	ec56                	sd	s5,24(sp)
ffffffffc0200aa2:	e85a                	sd	s6,16(sp)
ffffffffc0200aa4:	e45e                	sd	s7,8(sp)
ffffffffc0200aa6:	fc26                	sd	s1,56(sp)
ffffffffc0200aa8:	f84a                	sd	s2,48(sp)
ffffffffc0200aaa:	f44e                	sd	s3,40(sp)
ffffffffc0200aac:	f052                	sd	s4,32(sp)
    cprintf("BEGIN TO TEST OUR BUDDY SYSTEM!\n");
ffffffffc0200aae:	e9eff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("CHECK OUR EASY ALLOC CONDITION:\n");
ffffffffc0200ab2:	00001517          	auipc	a0,0x1
ffffffffc0200ab6:	ee650513          	addi	a0,a0,-282 # ffffffffc0201998 <etext+0x368>
ffffffffc0200aba:	e92ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("当前总的空闲块的数量为：%d\n", nr_free);
ffffffffc0200abe:	00005417          	auipc	s0,0x5
ffffffffc0200ac2:	67a40413          	addi	s0,s0,1658 # ffffffffc0206138 <nr_free>
ffffffffc0200ac6:	600c                	ld	a1,0(s0)
ffffffffc0200ac8:	00001517          	auipc	a0,0x1
ffffffffc0200acc:	ef850513          	addi	a0,a0,-264 # ffffffffc02019c0 <etext+0x390>
ffffffffc0200ad0:	e7cff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("首先,p0请求10页\n");
ffffffffc0200ad4:	00001517          	auipc	a0,0x1
ffffffffc0200ad8:	f1450513          	addi	a0,a0,-236 # ffffffffc02019e8 <etext+0x3b8>
ffffffffc0200adc:	e70ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    p0 = alloc_pages(10);
ffffffffc0200ae0:	4529                	li	a0,10
ffffffffc0200ae2:	4ca000ef          	jal	ra,ffffffffc0200fac <alloc_pages>
ffffffffc0200ae6:	8b2a                	mv	s6,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200ae8:	f37ff0ef          	jal	ra,ffffffffc0200a1e <show_buddy_array.constprop.0>
    cprintf("然后,p1请求10页\n");
ffffffffc0200aec:	00001517          	auipc	a0,0x1
ffffffffc0200af0:	f1450513          	addi	a0,a0,-236 # ffffffffc0201a00 <etext+0x3d0>
ffffffffc0200af4:	e58ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    p1 = alloc_pages(10);
ffffffffc0200af8:	4529                	li	a0,10
ffffffffc0200afa:	4b2000ef          	jal	ra,ffffffffc0200fac <alloc_pages>
ffffffffc0200afe:	8aaa                	mv	s5,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200b00:	f1fff0ef          	jal	ra,ffffffffc0200a1e <show_buddy_array.constprop.0>
    cprintf("最后,p2请求10页\n");
ffffffffc0200b04:	00001517          	auipc	a0,0x1
ffffffffc0200b08:	f1450513          	addi	a0,a0,-236 # ffffffffc0201a18 <etext+0x3e8>
ffffffffc0200b0c:	e40ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    p2 = alloc_pages(10);
ffffffffc0200b10:	4529                	li	a0,10
ffffffffc0200b12:	49a000ef          	jal	ra,ffffffffc0200fac <alloc_pages>
ffffffffc0200b16:	8baa                	mv	s7,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200b18:	f07ff0ef          	jal	ra,ffffffffc0200a1e <show_buddy_array.constprop.0>
    cprintf("p0的虚拟地址为:0x%016lx.\n", (uintptr_t)p0);
ffffffffc0200b1c:	85da                	mv	a1,s6
ffffffffc0200b1e:	00001517          	auipc	a0,0x1
ffffffffc0200b22:	f1250513          	addi	a0,a0,-238 # ffffffffc0201a30 <etext+0x400>
ffffffffc0200b26:	e26ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("p1的虚拟地址为:0x%016lx.\n", (uintptr_t)p1);
ffffffffc0200b2a:	85d6                	mv	a1,s5
ffffffffc0200b2c:	00001517          	auipc	a0,0x1
ffffffffc0200b30:	f2450513          	addi	a0,a0,-220 # ffffffffc0201a50 <etext+0x420>
ffffffffc0200b34:	e18ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("p2的虚拟地址为:0x%016lx.\n", (uintptr_t)p2);
ffffffffc0200b38:	85de                	mv	a1,s7
ffffffffc0200b3a:	00001517          	auipc	a0,0x1
ffffffffc0200b3e:	f3650513          	addi	a0,a0,-202 # ffffffffc0201a70 <etext+0x440>
ffffffffc0200b42:	e0aff0ef          	jal	ra,ffffffffc020014c <cprintf>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b46:	355b0363          	beq	s6,s5,ffffffffc0200e8c <buddy_system_check+0x3fa>
ffffffffc0200b4a:	357b0163          	beq	s6,s7,ffffffffc0200e8c <buddy_system_check+0x3fa>
ffffffffc0200b4e:	337a8f63          	beq	s5,s7,ffffffffc0200e8c <buddy_system_check+0x3fa>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b52:	000b2783          	lw	a5,0(s6) # 10000 <kern_entry-0xffffffffc01f0000>
ffffffffc0200b56:	30079b63          	bnez	a5,ffffffffc0200e6c <buddy_system_check+0x3da>
ffffffffc0200b5a:	000aa783          	lw	a5,0(s5)
ffffffffc0200b5e:	30079763          	bnez	a5,ffffffffc0200e6c <buddy_system_check+0x3da>
ffffffffc0200b62:	000ba783          	lw	a5,0(s7)
ffffffffc0200b66:	30079363          	bnez	a5,ffffffffc0200e6c <buddy_system_check+0x3da>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b6a:	00005917          	auipc	s2,0x5
ffffffffc0200b6e:	5de90913          	addi	s2,s2,1502 # ffffffffc0206148 <pages>
ffffffffc0200b72:	00093783          	ld	a5,0(s2)
ffffffffc0200b76:	00001997          	auipc	s3,0x1
ffffffffc0200b7a:	5d29b983          	ld	s3,1490(s3) # ffffffffc0202148 <error_string+0x38>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b7e:	00005497          	auipc	s1,0x5
ffffffffc0200b82:	5c248493          	addi	s1,s1,1474 # ffffffffc0206140 <npage>
ffffffffc0200b86:	40fb0733          	sub	a4,s6,a5
ffffffffc0200b8a:	870d                	srai	a4,a4,0x3
ffffffffc0200b8c:	03370733          	mul	a4,a4,s3
ffffffffc0200b90:	6094                	ld	a3,0(s1)
ffffffffc0200b92:	00001a17          	auipc	s4,0x1
ffffffffc0200b96:	5bea3a03          	ld	s4,1470(s4) # ffffffffc0202150 <nbase>
ffffffffc0200b9a:	06b2                	slli	a3,a3,0xc
ffffffffc0200b9c:	9752                	add	a4,a4,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b9e:	0732                	slli	a4,a4,0xc
ffffffffc0200ba0:	38d77663          	bgeu	a4,a3,ffffffffc0200f2c <buddy_system_check+0x49a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ba4:	40fa8733          	sub	a4,s5,a5
ffffffffc0200ba8:	870d                	srai	a4,a4,0x3
ffffffffc0200baa:	03370733          	mul	a4,a4,s3
ffffffffc0200bae:	9752                	add	a4,a4,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bb0:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200bb2:	34d77d63          	bgeu	a4,a3,ffffffffc0200f0c <buddy_system_check+0x47a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bb6:	40fb87b3          	sub	a5,s7,a5
ffffffffc0200bba:	878d                	srai	a5,a5,0x3
ffffffffc0200bbc:	033787b3          	mul	a5,a5,s3
ffffffffc0200bc0:	97d2                	add	a5,a5,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bc2:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200bc4:	3ad7f463          	bgeu	a5,a3,ffffffffc0200f6c <buddy_system_check+0x4da>
    cprintf("CHECK OUR EASY FREE CONDITION:\n");
ffffffffc0200bc8:	00001517          	auipc	a0,0x1
ffffffffc0200bcc:	f9050513          	addi	a0,a0,-112 # ffffffffc0201b58 <etext+0x528>
ffffffffc0200bd0:	d7cff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("释放p0...\n");
ffffffffc0200bd4:	00001517          	auipc	a0,0x1
ffffffffc0200bd8:	fa450513          	addi	a0,a0,-92 # ffffffffc0201b78 <etext+0x548>
ffffffffc0200bdc:	d70ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    free_pages(p0, 10);
ffffffffc0200be0:	45a9                	li	a1,10
ffffffffc0200be2:	855a                	mv	a0,s6
ffffffffc0200be4:	3d4000ef          	jal	ra,ffffffffc0200fb8 <free_pages>
    cprintf("释放p0后,总空闲块数目为:%d\n", nr_free); 
ffffffffc0200be8:	600c                	ld	a1,0(s0)
ffffffffc0200bea:	00001517          	auipc	a0,0x1
ffffffffc0200bee:	f9e50513          	addi	a0,a0,-98 # ffffffffc0201b88 <etext+0x558>
ffffffffc0200bf2:	d5aff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200bf6:	e29ff0ef          	jal	ra,ffffffffc0200a1e <show_buddy_array.constprop.0>
    cprintf("释放p1...\n");
ffffffffc0200bfa:	00001517          	auipc	a0,0x1
ffffffffc0200bfe:	fb650513          	addi	a0,a0,-74 # ffffffffc0201bb0 <etext+0x580>
ffffffffc0200c02:	d4aff0ef          	jal	ra,ffffffffc020014c <cprintf>
    free_pages(p1, 10);
ffffffffc0200c06:	8556                	mv	a0,s5
ffffffffc0200c08:	45a9                	li	a1,10
ffffffffc0200c0a:	3ae000ef          	jal	ra,ffffffffc0200fb8 <free_pages>
    cprintf("释放p1后,总空闲块数目为:%d\n", nr_free); 
ffffffffc0200c0e:	600c                	ld	a1,0(s0)
ffffffffc0200c10:	00001517          	auipc	a0,0x1
ffffffffc0200c14:	fb050513          	addi	a0,a0,-80 # ffffffffc0201bc0 <etext+0x590>
ffffffffc0200c18:	d34ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200c1c:	e03ff0ef          	jal	ra,ffffffffc0200a1e <show_buddy_array.constprop.0>
    cprintf("释放p2...\n");
ffffffffc0200c20:	00001517          	auipc	a0,0x1
ffffffffc0200c24:	fc850513          	addi	a0,a0,-56 # ffffffffc0201be8 <etext+0x5b8>
ffffffffc0200c28:	d24ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    free_pages(p2, 10);
ffffffffc0200c2c:	45a9                	li	a1,10
ffffffffc0200c2e:	855e                	mv	a0,s7
ffffffffc0200c30:	388000ef          	jal	ra,ffffffffc0200fb8 <free_pages>
    cprintf("释放p2后,总空闲块数目为:%d\n", nr_free); 
ffffffffc0200c34:	600c                	ld	a1,0(s0)
ffffffffc0200c36:	00001517          	auipc	a0,0x1
ffffffffc0200c3a:	fc250513          	addi	a0,a0,-62 # ffffffffc0201bf8 <etext+0x5c8>
ffffffffc0200c3e:	d0eff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200c42:	dddff0ef          	jal	ra,ffffffffc0200a1e <show_buddy_array.constprop.0>
    cprintf("CHECK MIN UNIT ALLOC/FREE:\n");
ffffffffc0200c46:	00001517          	auipc	a0,0x1
ffffffffc0200c4a:	fda50513          	addi	a0,a0,-38 # ffffffffc0201c20 <etext+0x5f0>
ffffffffc0200c4e:	cfeff0ef          	jal	ra,ffffffffc020014c <cprintf>
    struct Page *p3 = alloc_pages(1);
ffffffffc0200c52:	4505                	li	a0,1
ffffffffc0200c54:	358000ef          	jal	ra,ffffffffc0200fac <alloc_pages>
ffffffffc0200c58:	8aaa                	mv	s5,a0
    cprintf("分配p3之后(1页)\n");
ffffffffc0200c5a:	00001517          	auipc	a0,0x1
ffffffffc0200c5e:	fe650513          	addi	a0,a0,-26 # ffffffffc0201c40 <etext+0x610>
ffffffffc0200c62:	ceaff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200c66:	db9ff0ef          	jal	ra,ffffffffc0200a1e <show_buddy_array.constprop.0>
    free_pages(p3, 1);
ffffffffc0200c6a:	4585                	li	a1,1
ffffffffc0200c6c:	8556                	mv	a0,s5
ffffffffc0200c6e:	34a000ef          	jal	ra,ffffffffc0200fb8 <free_pages>
    cprintf("释放p3之后\n");
ffffffffc0200c72:	00001517          	auipc	a0,0x1
ffffffffc0200c76:	fe650513          	addi	a0,a0,-26 # ffffffffc0201c58 <etext+0x628>
ffffffffc0200c7a:	cd2ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200c7e:	da1ff0ef          	jal	ra,ffffffffc0200a1e <show_buddy_array.constprop.0>
    cprintf("CHECK MAX UNIT ALLOC/FREE:\n");
ffffffffc0200c82:	00001517          	auipc	a0,0x1
ffffffffc0200c86:	fe650513          	addi	a0,a0,-26 # ffffffffc0201c68 <etext+0x638>
ffffffffc0200c8a:	cc2ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    struct Page *p3 = alloc_pages(1 << MAX_ORDER);
ffffffffc0200c8e:	40000513          	li	a0,1024
ffffffffc0200c92:	31a000ef          	jal	ra,ffffffffc0200fac <alloc_pages>
ffffffffc0200c96:	8aaa                	mv	s5,a0
    if (p3 != NULL) {
ffffffffc0200c98:	1c050363          	beqz	a0,ffffffffc0200e5e <buddy_system_check+0x3cc>
        cprintf("分配p3之后(%d页)\n", 1 << MAX_ORDER);
ffffffffc0200c9c:	40000593          	li	a1,1024
ffffffffc0200ca0:	00001517          	auipc	a0,0x1
ffffffffc0200ca4:	fe850513          	addi	a0,a0,-24 # ffffffffc0201c88 <etext+0x658>
ffffffffc0200ca8:	ca4ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200cac:	d73ff0ef          	jal	ra,ffffffffc0200a1e <show_buddy_array.constprop.0>
        free_pages(p3, 1 << MAX_ORDER);
ffffffffc0200cb0:	40000593          	li	a1,1024
ffffffffc0200cb4:	8556                	mv	a0,s5
ffffffffc0200cb6:	302000ef          	jal	ra,ffffffffc0200fb8 <free_pages>
        cprintf("释放p3之后\n");
ffffffffc0200cba:	00001517          	auipc	a0,0x1
ffffffffc0200cbe:	f9e50513          	addi	a0,a0,-98 # ffffffffc0201c58 <etext+0x628>
ffffffffc0200cc2:	c8aff0ef          	jal	ra,ffffffffc020014c <cprintf>
        show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200cc6:	d59ff0ef          	jal	ra,ffffffffc0200a1e <show_buddy_array.constprop.0>
    cprintf("CHECK OUR DIFFICULT ALLOC CONDITION:\n");
ffffffffc0200cca:	00001517          	auipc	a0,0x1
ffffffffc0200cce:	ffe50513          	addi	a0,a0,-2 # ffffffffc0201cc8 <etext+0x698>
ffffffffc0200cd2:	c7aff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("当前总的空闲块的数量为：%d\n", nr_free);
ffffffffc0200cd6:	600c                	ld	a1,0(s0)
ffffffffc0200cd8:	00001517          	auipc	a0,0x1
ffffffffc0200cdc:	ce850513          	addi	a0,a0,-792 # ffffffffc02019c0 <etext+0x390>
ffffffffc0200ce0:	c6cff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("首先,p0请求10页\n");
ffffffffc0200ce4:	00001517          	auipc	a0,0x1
ffffffffc0200ce8:	d0450513          	addi	a0,a0,-764 # ffffffffc02019e8 <etext+0x3b8>
ffffffffc0200cec:	c60ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    p0 = alloc_pages(10);
ffffffffc0200cf0:	4529                	li	a0,10
ffffffffc0200cf2:	2ba000ef          	jal	ra,ffffffffc0200fac <alloc_pages>
ffffffffc0200cf6:	8aaa                	mv	s5,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200cf8:	d27ff0ef          	jal	ra,ffffffffc0200a1e <show_buddy_array.constprop.0>
    cprintf("然后,p1请求50页\n");
ffffffffc0200cfc:	00001517          	auipc	a0,0x1
ffffffffc0200d00:	ff450513          	addi	a0,a0,-12 # ffffffffc0201cf0 <etext+0x6c0>
ffffffffc0200d04:	c48ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    p1 = alloc_pages(50);
ffffffffc0200d08:	03200513          	li	a0,50
ffffffffc0200d0c:	2a0000ef          	jal	ra,ffffffffc0200fac <alloc_pages>
ffffffffc0200d10:	8baa                	mv	s7,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200d12:	d0dff0ef          	jal	ra,ffffffffc0200a1e <show_buddy_array.constprop.0>
    cprintf("最后,p2请求100页\n");
ffffffffc0200d16:	00001517          	auipc	a0,0x1
ffffffffc0200d1a:	ff250513          	addi	a0,a0,-14 # ffffffffc0201d08 <etext+0x6d8>
ffffffffc0200d1e:	c2eff0ef          	jal	ra,ffffffffc020014c <cprintf>
    p2 = alloc_pages(100);
ffffffffc0200d22:	06400513          	li	a0,100
ffffffffc0200d26:	286000ef          	jal	ra,ffffffffc0200fac <alloc_pages>
ffffffffc0200d2a:	8b2a                	mv	s6,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200d2c:	cf3ff0ef          	jal	ra,ffffffffc0200a1e <show_buddy_array.constprop.0>
    cprintf("p0的虚拟地址为:0x%016lx.\n", (uintptr_t)p0);
ffffffffc0200d30:	85d6                	mv	a1,s5
ffffffffc0200d32:	00001517          	auipc	a0,0x1
ffffffffc0200d36:	cfe50513          	addi	a0,a0,-770 # ffffffffc0201a30 <etext+0x400>
ffffffffc0200d3a:	c12ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("p1的虚拟地址为:0x%016lx.\n", (uintptr_t)p1);
ffffffffc0200d3e:	85de                	mv	a1,s7
ffffffffc0200d40:	00001517          	auipc	a0,0x1
ffffffffc0200d44:	d1050513          	addi	a0,a0,-752 # ffffffffc0201a50 <etext+0x420>
ffffffffc0200d48:	c04ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("p2的虚拟地址为:0x%016lx.\n", (uintptr_t)p2);
ffffffffc0200d4c:	85da                	mv	a1,s6
ffffffffc0200d4e:	00001517          	auipc	a0,0x1
ffffffffc0200d52:	d2250513          	addi	a0,a0,-734 # ffffffffc0201a70 <etext+0x440>
ffffffffc0200d56:	bf6ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200d5a:	177a8963          	beq	s5,s7,ffffffffc0200ecc <buddy_system_check+0x43a>
ffffffffc0200d5e:	176a8763          	beq	s5,s6,ffffffffc0200ecc <buddy_system_check+0x43a>
ffffffffc0200d62:	176b8563          	beq	s7,s6,ffffffffc0200ecc <buddy_system_check+0x43a>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200d66:	000aa783          	lw	a5,0(s5)
ffffffffc0200d6a:	14079163          	bnez	a5,ffffffffc0200eac <buddy_system_check+0x41a>
ffffffffc0200d6e:	000ba783          	lw	a5,0(s7)
ffffffffc0200d72:	12079d63          	bnez	a5,ffffffffc0200eac <buddy_system_check+0x41a>
ffffffffc0200d76:	000b2783          	lw	a5,0(s6)
ffffffffc0200d7a:	12079963          	bnez	a5,ffffffffc0200eac <buddy_system_check+0x41a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d7e:	00093783          	ld	a5,0(s2)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200d82:	6094                	ld	a3,0(s1)
ffffffffc0200d84:	40fa8733          	sub	a4,s5,a5
ffffffffc0200d88:	870d                	srai	a4,a4,0x3
ffffffffc0200d8a:	03370733          	mul	a4,a4,s3
ffffffffc0200d8e:	06b2                	slli	a3,a3,0xc
ffffffffc0200d90:	9752                	add	a4,a4,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc0200d92:	0732                	slli	a4,a4,0xc
ffffffffc0200d94:	14d77c63          	bgeu	a4,a3,ffffffffc0200eec <buddy_system_check+0x45a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d98:	40fb8733          	sub	a4,s7,a5
ffffffffc0200d9c:	870d                	srai	a4,a4,0x3
ffffffffc0200d9e:	03370733          	mul	a4,a4,s3
ffffffffc0200da2:	9752                	add	a4,a4,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc0200da4:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200da6:	1ed77363          	bgeu	a4,a3,ffffffffc0200f8c <buddy_system_check+0x4fa>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200daa:	40fb07b3          	sub	a5,s6,a5
ffffffffc0200dae:	878d                	srai	a5,a5,0x3
ffffffffc0200db0:	033787b3          	mul	a5,a5,s3
ffffffffc0200db4:	97d2                	add	a5,a5,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc0200db6:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200db8:	18d7fa63          	bgeu	a5,a3,ffffffffc0200f4c <buddy_system_check+0x4ba>
    cprintf("CHECK OUR DIFFICULT FREE CONDITION:\n");
ffffffffc0200dbc:	00001517          	auipc	a0,0x1
ffffffffc0200dc0:	f6450513          	addi	a0,a0,-156 # ffffffffc0201d20 <etext+0x6f0>
ffffffffc0200dc4:	b88ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("释放p0...\n");
ffffffffc0200dc8:	00001517          	auipc	a0,0x1
ffffffffc0200dcc:	db050513          	addi	a0,a0,-592 # ffffffffc0201b78 <etext+0x548>
ffffffffc0200dd0:	b7cff0ef          	jal	ra,ffffffffc020014c <cprintf>
    free_pages(p0, 10);
ffffffffc0200dd4:	8556                	mv	a0,s5
ffffffffc0200dd6:	45a9                	li	a1,10
ffffffffc0200dd8:	1e0000ef          	jal	ra,ffffffffc0200fb8 <free_pages>
    cprintf("释放p0后,总空闲块数目为:%d\n", nr_free); 
ffffffffc0200ddc:	600c                	ld	a1,0(s0)
ffffffffc0200dde:	00001517          	auipc	a0,0x1
ffffffffc0200de2:	daa50513          	addi	a0,a0,-598 # ffffffffc0201b88 <etext+0x558>
ffffffffc0200de6:	b66ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200dea:	c35ff0ef          	jal	ra,ffffffffc0200a1e <show_buddy_array.constprop.0>
    cprintf("释放p1...\n");
ffffffffc0200dee:	00001517          	auipc	a0,0x1
ffffffffc0200df2:	dc250513          	addi	a0,a0,-574 # ffffffffc0201bb0 <etext+0x580>
ffffffffc0200df6:	b56ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    free_pages(p1, 50);
ffffffffc0200dfa:	855e                	mv	a0,s7
ffffffffc0200dfc:	03200593          	li	a1,50
ffffffffc0200e00:	1b8000ef          	jal	ra,ffffffffc0200fb8 <free_pages>
    cprintf("释放p1后,总空闲块数目为:%d\n", nr_free); 
ffffffffc0200e04:	600c                	ld	a1,0(s0)
ffffffffc0200e06:	00001517          	auipc	a0,0x1
ffffffffc0200e0a:	dba50513          	addi	a0,a0,-582 # ffffffffc0201bc0 <etext+0x590>
ffffffffc0200e0e:	b3eff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200e12:	c0dff0ef          	jal	ra,ffffffffc0200a1e <show_buddy_array.constprop.0>
    cprintf("释放p2...\n");
ffffffffc0200e16:	00001517          	auipc	a0,0x1
ffffffffc0200e1a:	dd250513          	addi	a0,a0,-558 # ffffffffc0201be8 <etext+0x5b8>
ffffffffc0200e1e:	b2eff0ef          	jal	ra,ffffffffc020014c <cprintf>
    free_pages(p2, 100);
ffffffffc0200e22:	855a                	mv	a0,s6
ffffffffc0200e24:	06400593          	li	a1,100
ffffffffc0200e28:	190000ef          	jal	ra,ffffffffc0200fb8 <free_pages>
    cprintf("释放p2后,总空闲块数目为:%d\n", nr_free); 
ffffffffc0200e2c:	600c                	ld	a1,0(s0)
ffffffffc0200e2e:	00001517          	auipc	a0,0x1
ffffffffc0200e32:	dca50513          	addi	a0,a0,-566 # ffffffffc0201bf8 <etext+0x5c8>
ffffffffc0200e36:	b16ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200e3a:	be5ff0ef          	jal	ra,ffffffffc0200a1e <show_buddy_array.constprop.0>
    buddy_system_check_easy_alloc_and_free_condition();
    buddy_system_check_min_alloc_and_free_condition();
    buddy_system_check_max_alloc_and_free_condition();
    buddy_system_check_difficult_alloc_and_free_condition();
    cprintf("BUDDY SYSTEM TEST COMPLETED!\n");
}
ffffffffc0200e3e:	6406                	ld	s0,64(sp)
ffffffffc0200e40:	60a6                	ld	ra,72(sp)
ffffffffc0200e42:	74e2                	ld	s1,56(sp)
ffffffffc0200e44:	7942                	ld	s2,48(sp)
ffffffffc0200e46:	79a2                	ld	s3,40(sp)
ffffffffc0200e48:	7a02                	ld	s4,32(sp)
ffffffffc0200e4a:	6ae2                	ld	s5,24(sp)
ffffffffc0200e4c:	6b42                	ld	s6,16(sp)
ffffffffc0200e4e:	6ba2                	ld	s7,8(sp)
    cprintf("BUDDY SYSTEM TEST COMPLETED!\n");
ffffffffc0200e50:	00001517          	auipc	a0,0x1
ffffffffc0200e54:	ef850513          	addi	a0,a0,-264 # ffffffffc0201d48 <etext+0x718>
}
ffffffffc0200e58:	6161                	addi	sp,sp,80
    cprintf("BUDDY SYSTEM TEST COMPLETED!\n");
ffffffffc0200e5a:	af2ff06f          	j	ffffffffc020014c <cprintf>
        cprintf("最大单元分配失败(内存不足)\n");
ffffffffc0200e5e:	00001517          	auipc	a0,0x1
ffffffffc0200e62:	e4250513          	addi	a0,a0,-446 # ffffffffc0201ca0 <etext+0x670>
ffffffffc0200e66:	ae6ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200e6a:	b585                	j	ffffffffc0200cca <buddy_system_check+0x238>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e6c:	00001697          	auipc	a3,0x1
ffffffffc0200e70:	c4c68693          	addi	a3,a3,-948 # ffffffffc0201ab8 <etext+0x488>
ffffffffc0200e74:	00001617          	auipc	a2,0x1
ffffffffc0200e78:	a2460613          	addi	a2,a2,-1500 # ffffffffc0201898 <etext+0x268>
ffffffffc0200e7c:	1c200593          	li	a1,450
ffffffffc0200e80:	00001517          	auipc	a0,0x1
ffffffffc0200e84:	a3050513          	addi	a0,a0,-1488 # ffffffffc02018b0 <etext+0x280>
ffffffffc0200e88:	b3aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e8c:	00001697          	auipc	a3,0x1
ffffffffc0200e90:	c0468693          	addi	a3,a3,-1020 # ffffffffc0201a90 <etext+0x460>
ffffffffc0200e94:	00001617          	auipc	a2,0x1
ffffffffc0200e98:	a0460613          	addi	a2,a2,-1532 # ffffffffc0201898 <etext+0x268>
ffffffffc0200e9c:	1c100593          	li	a1,449
ffffffffc0200ea0:	00001517          	auipc	a0,0x1
ffffffffc0200ea4:	a1050513          	addi	a0,a0,-1520 # ffffffffc02018b0 <etext+0x280>
ffffffffc0200ea8:	b1aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200eac:	00001697          	auipc	a3,0x1
ffffffffc0200eb0:	c0c68693          	addi	a3,a3,-1012 # ffffffffc0201ab8 <etext+0x488>
ffffffffc0200eb4:	00001617          	auipc	a2,0x1
ffffffffc0200eb8:	9e460613          	addi	a2,a2,-1564 # ffffffffc0201898 <etext+0x268>
ffffffffc0200ebc:	1f200593          	li	a1,498
ffffffffc0200ec0:	00001517          	auipc	a0,0x1
ffffffffc0200ec4:	9f050513          	addi	a0,a0,-1552 # ffffffffc02018b0 <etext+0x280>
ffffffffc0200ec8:	afaff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ecc:	00001697          	auipc	a3,0x1
ffffffffc0200ed0:	bc468693          	addi	a3,a3,-1084 # ffffffffc0201a90 <etext+0x460>
ffffffffc0200ed4:	00001617          	auipc	a2,0x1
ffffffffc0200ed8:	9c460613          	addi	a2,a2,-1596 # ffffffffc0201898 <etext+0x268>
ffffffffc0200edc:	1f100593          	li	a1,497
ffffffffc0200ee0:	00001517          	auipc	a0,0x1
ffffffffc0200ee4:	9d050513          	addi	a0,a0,-1584 # ffffffffc02018b0 <etext+0x280>
ffffffffc0200ee8:	adaff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200eec:	00001697          	auipc	a3,0x1
ffffffffc0200ef0:	c0c68693          	addi	a3,a3,-1012 # ffffffffc0201af8 <etext+0x4c8>
ffffffffc0200ef4:	00001617          	auipc	a2,0x1
ffffffffc0200ef8:	9a460613          	addi	a2,a2,-1628 # ffffffffc0201898 <etext+0x268>
ffffffffc0200efc:	1f400593          	li	a1,500
ffffffffc0200f00:	00001517          	auipc	a0,0x1
ffffffffc0200f04:	9b050513          	addi	a0,a0,-1616 # ffffffffc02018b0 <etext+0x280>
ffffffffc0200f08:	abaff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200f0c:	00001697          	auipc	a3,0x1
ffffffffc0200f10:	c0c68693          	addi	a3,a3,-1012 # ffffffffc0201b18 <etext+0x4e8>
ffffffffc0200f14:	00001617          	auipc	a2,0x1
ffffffffc0200f18:	98460613          	addi	a2,a2,-1660 # ffffffffc0201898 <etext+0x268>
ffffffffc0200f1c:	1c500593          	li	a1,453
ffffffffc0200f20:	00001517          	auipc	a0,0x1
ffffffffc0200f24:	99050513          	addi	a0,a0,-1648 # ffffffffc02018b0 <etext+0x280>
ffffffffc0200f28:	a9aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f2c:	00001697          	auipc	a3,0x1
ffffffffc0200f30:	bcc68693          	addi	a3,a3,-1076 # ffffffffc0201af8 <etext+0x4c8>
ffffffffc0200f34:	00001617          	auipc	a2,0x1
ffffffffc0200f38:	96460613          	addi	a2,a2,-1692 # ffffffffc0201898 <etext+0x268>
ffffffffc0200f3c:	1c400593          	li	a1,452
ffffffffc0200f40:	00001517          	auipc	a0,0x1
ffffffffc0200f44:	97050513          	addi	a0,a0,-1680 # ffffffffc02018b0 <etext+0x280>
ffffffffc0200f48:	a7aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f4c:	00001697          	auipc	a3,0x1
ffffffffc0200f50:	bec68693          	addi	a3,a3,-1044 # ffffffffc0201b38 <etext+0x508>
ffffffffc0200f54:	00001617          	auipc	a2,0x1
ffffffffc0200f58:	94460613          	addi	a2,a2,-1724 # ffffffffc0201898 <etext+0x268>
ffffffffc0200f5c:	1f600593          	li	a1,502
ffffffffc0200f60:	00001517          	auipc	a0,0x1
ffffffffc0200f64:	95050513          	addi	a0,a0,-1712 # ffffffffc02018b0 <etext+0x280>
ffffffffc0200f68:	a5aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f6c:	00001697          	auipc	a3,0x1
ffffffffc0200f70:	bcc68693          	addi	a3,a3,-1076 # ffffffffc0201b38 <etext+0x508>
ffffffffc0200f74:	00001617          	auipc	a2,0x1
ffffffffc0200f78:	92460613          	addi	a2,a2,-1756 # ffffffffc0201898 <etext+0x268>
ffffffffc0200f7c:	1c600593          	li	a1,454
ffffffffc0200f80:	00001517          	auipc	a0,0x1
ffffffffc0200f84:	93050513          	addi	a0,a0,-1744 # ffffffffc02018b0 <etext+0x280>
ffffffffc0200f88:	a3aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200f8c:	00001697          	auipc	a3,0x1
ffffffffc0200f90:	b8c68693          	addi	a3,a3,-1140 # ffffffffc0201b18 <etext+0x4e8>
ffffffffc0200f94:	00001617          	auipc	a2,0x1
ffffffffc0200f98:	90460613          	addi	a2,a2,-1788 # ffffffffc0201898 <etext+0x268>
ffffffffc0200f9c:	1f500593          	li	a1,501
ffffffffc0200fa0:	00001517          	auipc	a0,0x1
ffffffffc0200fa4:	91050513          	addi	a0,a0,-1776 # ffffffffc02018b0 <etext+0x280>
ffffffffc0200fa8:	a1aff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200fac <alloc_pages>:
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
    return pmm_manager->alloc_pages(n);
ffffffffc0200fac:	00005797          	auipc	a5,0x5
ffffffffc0200fb0:	1a47b783          	ld	a5,420(a5) # ffffffffc0206150 <pmm_manager>
ffffffffc0200fb4:	6f9c                	ld	a5,24(a5)
ffffffffc0200fb6:	8782                	jr	a5

ffffffffc0200fb8 <free_pages>:
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    pmm_manager->free_pages(base, n);
ffffffffc0200fb8:	00005797          	auipc	a5,0x5
ffffffffc0200fbc:	1987b783          	ld	a5,408(a5) # ffffffffc0206150 <pmm_manager>
ffffffffc0200fc0:	739c                	ld	a5,32(a5)
ffffffffc0200fc2:	8782                	jr	a5

ffffffffc0200fc4 <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200fc4:	00001797          	auipc	a5,0x1
ffffffffc0200fc8:	dbc78793          	addi	a5,a5,-580 # ffffffffc0201d80 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fcc:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200fce:	7179                	addi	sp,sp,-48
ffffffffc0200fd0:	f022                	sd	s0,32(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fd2:	00001517          	auipc	a0,0x1
ffffffffc0200fd6:	de650513          	addi	a0,a0,-538 # ffffffffc0201db8 <buddy_pmm_manager+0x38>
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200fda:	00005417          	auipc	s0,0x5
ffffffffc0200fde:	17640413          	addi	s0,s0,374 # ffffffffc0206150 <pmm_manager>
void pmm_init(void) {
ffffffffc0200fe2:	f406                	sd	ra,40(sp)
ffffffffc0200fe4:	ec26                	sd	s1,24(sp)
ffffffffc0200fe6:	e44e                	sd	s3,8(sp)
ffffffffc0200fe8:	e84a                	sd	s2,16(sp)
ffffffffc0200fea:	e052                	sd	s4,0(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200fec:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fee:	95eff0ef          	jal	ra,ffffffffc020014c <cprintf>
    pmm_manager->init();
ffffffffc0200ff2:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200ff4:	00005497          	auipc	s1,0x5
ffffffffc0200ff8:	17448493          	addi	s1,s1,372 # ffffffffc0206168 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200ffc:	679c                	ld	a5,8(a5)
ffffffffc0200ffe:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201000:	57f5                	li	a5,-3
ffffffffc0201002:	07fa                	slli	a5,a5,0x1e
ffffffffc0201004:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();
ffffffffc0201006:	db6ff0ef          	jal	ra,ffffffffc02005bc <get_memory_base>
ffffffffc020100a:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc020100c:	dbaff0ef          	jal	ra,ffffffffc02005c6 <get_memory_size>
    if (mem_size == 0) {
ffffffffc0201010:	14050d63          	beqz	a0,ffffffffc020116a <pmm_init+0x1a6>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0201014:	892a                	mv	s2,a0
    cprintf("physcial memory map:\n");
ffffffffc0201016:	00001517          	auipc	a0,0x1
ffffffffc020101a:	dea50513          	addi	a0,a0,-534 # ffffffffc0201e00 <buddy_pmm_manager+0x80>
ffffffffc020101e:	92eff0ef          	jal	ra,ffffffffc020014c <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0201022:	01298a33          	add	s4,s3,s2
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201026:	864e                	mv	a2,s3
ffffffffc0201028:	fffa0693          	addi	a3,s4,-1
ffffffffc020102c:	85ca                	mv	a1,s2
ffffffffc020102e:	00001517          	auipc	a0,0x1
ffffffffc0201032:	dea50513          	addi	a0,a0,-534 # ffffffffc0201e18 <buddy_pmm_manager+0x98>
ffffffffc0201036:	916ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc020103a:	c80007b7          	lui	a5,0xc8000
ffffffffc020103e:	8652                	mv	a2,s4
ffffffffc0201040:	0d47e463          	bltu	a5,s4,ffffffffc0201108 <pmm_init+0x144>
ffffffffc0201044:	00006797          	auipc	a5,0x6
ffffffffc0201048:	12b78793          	addi	a5,a5,299 # ffffffffc020716f <end+0xfff>
ffffffffc020104c:	757d                	lui	a0,0xfffff
ffffffffc020104e:	8d7d                	and	a0,a0,a5
ffffffffc0201050:	8231                	srli	a2,a2,0xc
ffffffffc0201052:	00005797          	auipc	a5,0x5
ffffffffc0201056:	0ec7b723          	sd	a2,238(a5) # ffffffffc0206140 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020105a:	00005797          	auipc	a5,0x5
ffffffffc020105e:	0ea7b723          	sd	a0,238(a5) # ffffffffc0206148 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201062:	000807b7          	lui	a5,0x80
ffffffffc0201066:	002005b7          	lui	a1,0x200
ffffffffc020106a:	02f60563          	beq	a2,a5,ffffffffc0201094 <pmm_init+0xd0>
ffffffffc020106e:	00261593          	slli	a1,a2,0x2
ffffffffc0201072:	00c586b3          	add	a3,a1,a2
ffffffffc0201076:	fec007b7          	lui	a5,0xfec00
ffffffffc020107a:	97aa                	add	a5,a5,a0
ffffffffc020107c:	068e                	slli	a3,a3,0x3
ffffffffc020107e:	96be                	add	a3,a3,a5
ffffffffc0201080:	87aa                	mv	a5,a0
        SetPageReserved(pages + i);
ffffffffc0201082:	6798                	ld	a4,8(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201084:	02878793          	addi	a5,a5,40 # fffffffffec00028 <end+0x3e9f9eb8>
        SetPageReserved(pages + i);
ffffffffc0201088:	00176713          	ori	a4,a4,1
ffffffffc020108c:	fee7b023          	sd	a4,-32(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201090:	fef699e3          	bne	a3,a5,ffffffffc0201082 <pmm_init+0xbe>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201094:	95b2                	add	a1,a1,a2
ffffffffc0201096:	fec006b7          	lui	a3,0xfec00
ffffffffc020109a:	96aa                	add	a3,a3,a0
ffffffffc020109c:	058e                	slli	a1,a1,0x3
ffffffffc020109e:	96ae                	add	a3,a3,a1
ffffffffc02010a0:	c02007b7          	lui	a5,0xc0200
ffffffffc02010a4:	0af6e763          	bltu	a3,a5,ffffffffc0201152 <pmm_init+0x18e>
ffffffffc02010a8:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc02010aa:	77fd                	lui	a5,0xfffff
ffffffffc02010ac:	00fa75b3          	and	a1,s4,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02010b0:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02010b2:	04b6ee63          	bltu	a3,a1,ffffffffc020110e <pmm_init+0x14a>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02010b6:	601c                	ld	a5,0(s0)
ffffffffc02010b8:	7b9c                	ld	a5,48(a5)
ffffffffc02010ba:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02010bc:	00001517          	auipc	a0,0x1
ffffffffc02010c0:	de450513          	addi	a0,a0,-540 # ffffffffc0201ea0 <buddy_pmm_manager+0x120>
ffffffffc02010c4:	888ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02010c8:	00004597          	auipc	a1,0x4
ffffffffc02010cc:	f3858593          	addi	a1,a1,-200 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02010d0:	00005797          	auipc	a5,0x5
ffffffffc02010d4:	08b7b823          	sd	a1,144(a5) # ffffffffc0206160 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02010d8:	c02007b7          	lui	a5,0xc0200
ffffffffc02010dc:	0af5e363          	bltu	a1,a5,ffffffffc0201182 <pmm_init+0x1be>
ffffffffc02010e0:	6090                	ld	a2,0(s1)
}
ffffffffc02010e2:	7402                	ld	s0,32(sp)
ffffffffc02010e4:	70a2                	ld	ra,40(sp)
ffffffffc02010e6:	64e2                	ld	s1,24(sp)
ffffffffc02010e8:	6942                	ld	s2,16(sp)
ffffffffc02010ea:	69a2                	ld	s3,8(sp)
ffffffffc02010ec:	6a02                	ld	s4,0(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02010ee:	40c58633          	sub	a2,a1,a2
ffffffffc02010f2:	00005797          	auipc	a5,0x5
ffffffffc02010f6:	06c7b323          	sd	a2,102(a5) # ffffffffc0206158 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02010fa:	00001517          	auipc	a0,0x1
ffffffffc02010fe:	dc650513          	addi	a0,a0,-570 # ffffffffc0201ec0 <buddy_pmm_manager+0x140>
}
ffffffffc0201102:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201104:	848ff06f          	j	ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0201108:	c8000637          	lui	a2,0xc8000
ffffffffc020110c:	bf25                	j	ffffffffc0201044 <pmm_init+0x80>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020110e:	6705                	lui	a4,0x1
ffffffffc0201110:	177d                	addi	a4,a4,-1
ffffffffc0201112:	96ba                	add	a3,a3,a4
ffffffffc0201114:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201116:	00c6d793          	srli	a5,a3,0xc
ffffffffc020111a:	02c7f063          	bgeu	a5,a2,ffffffffc020113a <pmm_init+0x176>
    pmm_manager->init_memmap(base, n);
ffffffffc020111e:	6010                	ld	a2,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201120:	fff80737          	lui	a4,0xfff80
ffffffffc0201124:	973e                	add	a4,a4,a5
ffffffffc0201126:	00271793          	slli	a5,a4,0x2
ffffffffc020112a:	97ba                	add	a5,a5,a4
ffffffffc020112c:	6a18                	ld	a4,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020112e:	8d95                	sub	a1,a1,a3
ffffffffc0201130:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201132:	81b1                	srli	a1,a1,0xc
ffffffffc0201134:	953e                	add	a0,a0,a5
ffffffffc0201136:	9702                	jalr	a4
}
ffffffffc0201138:	bfbd                	j	ffffffffc02010b6 <pmm_init+0xf2>
        panic("pa2page called with invalid pa");
ffffffffc020113a:	00001617          	auipc	a2,0x1
ffffffffc020113e:	d3660613          	addi	a2,a2,-714 # ffffffffc0201e70 <buddy_pmm_manager+0xf0>
ffffffffc0201142:	06a00593          	li	a1,106
ffffffffc0201146:	00001517          	auipc	a0,0x1
ffffffffc020114a:	d4a50513          	addi	a0,a0,-694 # ffffffffc0201e90 <buddy_pmm_manager+0x110>
ffffffffc020114e:	874ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201152:	00001617          	auipc	a2,0x1
ffffffffc0201156:	cf660613          	addi	a2,a2,-778 # ffffffffc0201e48 <buddy_pmm_manager+0xc8>
ffffffffc020115a:	06000593          	li	a1,96
ffffffffc020115e:	00001517          	auipc	a0,0x1
ffffffffc0201162:	c9250513          	addi	a0,a0,-878 # ffffffffc0201df0 <buddy_pmm_manager+0x70>
ffffffffc0201166:	85cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("DTB memory info not available");
ffffffffc020116a:	00001617          	auipc	a2,0x1
ffffffffc020116e:	c6660613          	addi	a2,a2,-922 # ffffffffc0201dd0 <buddy_pmm_manager+0x50>
ffffffffc0201172:	04800593          	li	a1,72
ffffffffc0201176:	00001517          	auipc	a0,0x1
ffffffffc020117a:	c7a50513          	addi	a0,a0,-902 # ffffffffc0201df0 <buddy_pmm_manager+0x70>
ffffffffc020117e:	844ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201182:	86ae                	mv	a3,a1
ffffffffc0201184:	00001617          	auipc	a2,0x1
ffffffffc0201188:	cc460613          	addi	a2,a2,-828 # ffffffffc0201e48 <buddy_pmm_manager+0xc8>
ffffffffc020118c:	07b00593          	li	a1,123
ffffffffc0201190:	00001517          	auipc	a0,0x1
ffffffffc0201194:	c6050513          	addi	a0,a0,-928 # ffffffffc0201df0 <buddy_pmm_manager+0x70>
ffffffffc0201198:	82aff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc020119c <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020119c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02011a0:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02011a2:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02011a6:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02011a8:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02011ac:	f022                	sd	s0,32(sp)
ffffffffc02011ae:	ec26                	sd	s1,24(sp)
ffffffffc02011b0:	e84a                	sd	s2,16(sp)
ffffffffc02011b2:	f406                	sd	ra,40(sp)
ffffffffc02011b4:	e44e                	sd	s3,8(sp)
ffffffffc02011b6:	84aa                	mv	s1,a0
ffffffffc02011b8:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02011ba:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02011be:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02011c0:	03067e63          	bgeu	a2,a6,ffffffffc02011fc <printnum+0x60>
ffffffffc02011c4:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02011c6:	00805763          	blez	s0,ffffffffc02011d4 <printnum+0x38>
ffffffffc02011ca:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02011cc:	85ca                	mv	a1,s2
ffffffffc02011ce:	854e                	mv	a0,s3
ffffffffc02011d0:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02011d2:	fc65                	bnez	s0,ffffffffc02011ca <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02011d4:	1a02                	slli	s4,s4,0x20
ffffffffc02011d6:	00001797          	auipc	a5,0x1
ffffffffc02011da:	d2a78793          	addi	a5,a5,-726 # ffffffffc0201f00 <buddy_pmm_manager+0x180>
ffffffffc02011de:	020a5a13          	srli	s4,s4,0x20
ffffffffc02011e2:	9a3e                	add	s4,s4,a5
}
ffffffffc02011e4:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02011e6:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02011ea:	70a2                	ld	ra,40(sp)
ffffffffc02011ec:	69a2                	ld	s3,8(sp)
ffffffffc02011ee:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02011f0:	85ca                	mv	a1,s2
ffffffffc02011f2:	87a6                	mv	a5,s1
}
ffffffffc02011f4:	6942                	ld	s2,16(sp)
ffffffffc02011f6:	64e2                	ld	s1,24(sp)
ffffffffc02011f8:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02011fa:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02011fc:	03065633          	divu	a2,a2,a6
ffffffffc0201200:	8722                	mv	a4,s0
ffffffffc0201202:	f9bff0ef          	jal	ra,ffffffffc020119c <printnum>
ffffffffc0201206:	b7f9                	j	ffffffffc02011d4 <printnum+0x38>

ffffffffc0201208 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201208:	7119                	addi	sp,sp,-128
ffffffffc020120a:	f4a6                	sd	s1,104(sp)
ffffffffc020120c:	f0ca                	sd	s2,96(sp)
ffffffffc020120e:	ecce                	sd	s3,88(sp)
ffffffffc0201210:	e8d2                	sd	s4,80(sp)
ffffffffc0201212:	e4d6                	sd	s5,72(sp)
ffffffffc0201214:	e0da                	sd	s6,64(sp)
ffffffffc0201216:	fc5e                	sd	s7,56(sp)
ffffffffc0201218:	f06a                	sd	s10,32(sp)
ffffffffc020121a:	fc86                	sd	ra,120(sp)
ffffffffc020121c:	f8a2                	sd	s0,112(sp)
ffffffffc020121e:	f862                	sd	s8,48(sp)
ffffffffc0201220:	f466                	sd	s9,40(sp)
ffffffffc0201222:	ec6e                	sd	s11,24(sp)
ffffffffc0201224:	892a                	mv	s2,a0
ffffffffc0201226:	84ae                	mv	s1,a1
ffffffffc0201228:	8d32                	mv	s10,a2
ffffffffc020122a:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020122c:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201230:	5b7d                	li	s6,-1
ffffffffc0201232:	00001a97          	auipc	s5,0x1
ffffffffc0201236:	d02a8a93          	addi	s5,s5,-766 # ffffffffc0201f34 <buddy_pmm_manager+0x1b4>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020123a:	00001b97          	auipc	s7,0x1
ffffffffc020123e:	ed6b8b93          	addi	s7,s7,-298 # ffffffffc0202110 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201242:	000d4503          	lbu	a0,0(s10)
ffffffffc0201246:	001d0413          	addi	s0,s10,1
ffffffffc020124a:	01350a63          	beq	a0,s3,ffffffffc020125e <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc020124e:	c121                	beqz	a0,ffffffffc020128e <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201250:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201252:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201254:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201256:	fff44503          	lbu	a0,-1(s0)
ffffffffc020125a:	ff351ae3          	bne	a0,s3,ffffffffc020124e <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020125e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201262:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201266:	4c81                	li	s9,0
ffffffffc0201268:	4881                	li	a7,0
        width = precision = -1;
ffffffffc020126a:	5c7d                	li	s8,-1
ffffffffc020126c:	5dfd                	li	s11,-1
ffffffffc020126e:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201272:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201274:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201278:	0ff5f593          	zext.b	a1,a1
ffffffffc020127c:	00140d13          	addi	s10,s0,1
ffffffffc0201280:	04b56263          	bltu	a0,a1,ffffffffc02012c4 <vprintfmt+0xbc>
ffffffffc0201284:	058a                	slli	a1,a1,0x2
ffffffffc0201286:	95d6                	add	a1,a1,s5
ffffffffc0201288:	4194                	lw	a3,0(a1)
ffffffffc020128a:	96d6                	add	a3,a3,s5
ffffffffc020128c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020128e:	70e6                	ld	ra,120(sp)
ffffffffc0201290:	7446                	ld	s0,112(sp)
ffffffffc0201292:	74a6                	ld	s1,104(sp)
ffffffffc0201294:	7906                	ld	s2,96(sp)
ffffffffc0201296:	69e6                	ld	s3,88(sp)
ffffffffc0201298:	6a46                	ld	s4,80(sp)
ffffffffc020129a:	6aa6                	ld	s5,72(sp)
ffffffffc020129c:	6b06                	ld	s6,64(sp)
ffffffffc020129e:	7be2                	ld	s7,56(sp)
ffffffffc02012a0:	7c42                	ld	s8,48(sp)
ffffffffc02012a2:	7ca2                	ld	s9,40(sp)
ffffffffc02012a4:	7d02                	ld	s10,32(sp)
ffffffffc02012a6:	6de2                	ld	s11,24(sp)
ffffffffc02012a8:	6109                	addi	sp,sp,128
ffffffffc02012aa:	8082                	ret
            padc = '0';
ffffffffc02012ac:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02012ae:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012b2:	846a                	mv	s0,s10
ffffffffc02012b4:	00140d13          	addi	s10,s0,1
ffffffffc02012b8:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02012bc:	0ff5f593          	zext.b	a1,a1
ffffffffc02012c0:	fcb572e3          	bgeu	a0,a1,ffffffffc0201284 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02012c4:	85a6                	mv	a1,s1
ffffffffc02012c6:	02500513          	li	a0,37
ffffffffc02012ca:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02012cc:	fff44783          	lbu	a5,-1(s0)
ffffffffc02012d0:	8d22                	mv	s10,s0
ffffffffc02012d2:	f73788e3          	beq	a5,s3,ffffffffc0201242 <vprintfmt+0x3a>
ffffffffc02012d6:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02012da:	1d7d                	addi	s10,s10,-1
ffffffffc02012dc:	ff379de3          	bne	a5,s3,ffffffffc02012d6 <vprintfmt+0xce>
ffffffffc02012e0:	b78d                	j	ffffffffc0201242 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02012e2:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02012e6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012ea:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02012ec:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02012f0:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02012f4:	02d86463          	bltu	a6,a3,ffffffffc020131c <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02012f8:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02012fc:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201300:	0186873b          	addw	a4,a3,s8
ffffffffc0201304:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201308:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020130a:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020130e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201310:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201314:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201318:	fed870e3          	bgeu	a6,a3,ffffffffc02012f8 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020131c:	f40ddce3          	bgez	s11,ffffffffc0201274 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201320:	8de2                	mv	s11,s8
ffffffffc0201322:	5c7d                	li	s8,-1
ffffffffc0201324:	bf81                	j	ffffffffc0201274 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201326:	fffdc693          	not	a3,s11
ffffffffc020132a:	96fd                	srai	a3,a3,0x3f
ffffffffc020132c:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201330:	00144603          	lbu	a2,1(s0)
ffffffffc0201334:	2d81                	sext.w	s11,s11
ffffffffc0201336:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201338:	bf35                	j	ffffffffc0201274 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020133a:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020133e:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201342:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201344:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201346:	bfd9                	j	ffffffffc020131c <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201348:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020134a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020134e:	01174463          	blt	a4,a7,ffffffffc0201356 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201352:	1a088e63          	beqz	a7,ffffffffc020150e <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201356:	000a3603          	ld	a2,0(s4)
ffffffffc020135a:	46c1                	li	a3,16
ffffffffc020135c:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020135e:	2781                	sext.w	a5,a5
ffffffffc0201360:	876e                	mv	a4,s11
ffffffffc0201362:	85a6                	mv	a1,s1
ffffffffc0201364:	854a                	mv	a0,s2
ffffffffc0201366:	e37ff0ef          	jal	ra,ffffffffc020119c <printnum>
            break;
ffffffffc020136a:	bde1                	j	ffffffffc0201242 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020136c:	000a2503          	lw	a0,0(s4)
ffffffffc0201370:	85a6                	mv	a1,s1
ffffffffc0201372:	0a21                	addi	s4,s4,8
ffffffffc0201374:	9902                	jalr	s2
            break;
ffffffffc0201376:	b5f1                	j	ffffffffc0201242 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201378:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020137a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020137e:	01174463          	blt	a4,a7,ffffffffc0201386 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201382:	18088163          	beqz	a7,ffffffffc0201504 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201386:	000a3603          	ld	a2,0(s4)
ffffffffc020138a:	46a9                	li	a3,10
ffffffffc020138c:	8a2e                	mv	s4,a1
ffffffffc020138e:	bfc1                	j	ffffffffc020135e <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201390:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201394:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201396:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201398:	bdf1                	j	ffffffffc0201274 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020139a:	85a6                	mv	a1,s1
ffffffffc020139c:	02500513          	li	a0,37
ffffffffc02013a0:	9902                	jalr	s2
            break;
ffffffffc02013a2:	b545                	j	ffffffffc0201242 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013a4:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02013a8:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013aa:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02013ac:	b5e1                	j	ffffffffc0201274 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02013ae:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02013b0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02013b4:	01174463          	blt	a4,a7,ffffffffc02013bc <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02013b8:	14088163          	beqz	a7,ffffffffc02014fa <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02013bc:	000a3603          	ld	a2,0(s4)
ffffffffc02013c0:	46a1                	li	a3,8
ffffffffc02013c2:	8a2e                	mv	s4,a1
ffffffffc02013c4:	bf69                	j	ffffffffc020135e <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02013c6:	03000513          	li	a0,48
ffffffffc02013ca:	85a6                	mv	a1,s1
ffffffffc02013cc:	e03e                	sd	a5,0(sp)
ffffffffc02013ce:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02013d0:	85a6                	mv	a1,s1
ffffffffc02013d2:	07800513          	li	a0,120
ffffffffc02013d6:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02013d8:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02013da:	6782                	ld	a5,0(sp)
ffffffffc02013dc:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02013de:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02013e2:	bfb5                	j	ffffffffc020135e <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02013e4:	000a3403          	ld	s0,0(s4)
ffffffffc02013e8:	008a0713          	addi	a4,s4,8
ffffffffc02013ec:	e03a                	sd	a4,0(sp)
ffffffffc02013ee:	14040263          	beqz	s0,ffffffffc0201532 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02013f2:	0fb05763          	blez	s11,ffffffffc02014e0 <vprintfmt+0x2d8>
ffffffffc02013f6:	02d00693          	li	a3,45
ffffffffc02013fa:	0cd79163          	bne	a5,a3,ffffffffc02014bc <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02013fe:	00044783          	lbu	a5,0(s0)
ffffffffc0201402:	0007851b          	sext.w	a0,a5
ffffffffc0201406:	cf85                	beqz	a5,ffffffffc020143e <vprintfmt+0x236>
ffffffffc0201408:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020140c:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201410:	000c4563          	bltz	s8,ffffffffc020141a <vprintfmt+0x212>
ffffffffc0201414:	3c7d                	addiw	s8,s8,-1
ffffffffc0201416:	036c0263          	beq	s8,s6,ffffffffc020143a <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020141a:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020141c:	0e0c8e63          	beqz	s9,ffffffffc0201518 <vprintfmt+0x310>
ffffffffc0201420:	3781                	addiw	a5,a5,-32
ffffffffc0201422:	0ef47b63          	bgeu	s0,a5,ffffffffc0201518 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201426:	03f00513          	li	a0,63
ffffffffc020142a:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020142c:	000a4783          	lbu	a5,0(s4)
ffffffffc0201430:	3dfd                	addiw	s11,s11,-1
ffffffffc0201432:	0a05                	addi	s4,s4,1
ffffffffc0201434:	0007851b          	sext.w	a0,a5
ffffffffc0201438:	ffe1                	bnez	a5,ffffffffc0201410 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc020143a:	01b05963          	blez	s11,ffffffffc020144c <vprintfmt+0x244>
ffffffffc020143e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201440:	85a6                	mv	a1,s1
ffffffffc0201442:	02000513          	li	a0,32
ffffffffc0201446:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201448:	fe0d9be3          	bnez	s11,ffffffffc020143e <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020144c:	6a02                	ld	s4,0(sp)
ffffffffc020144e:	bbd5                	j	ffffffffc0201242 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201450:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201452:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201456:	01174463          	blt	a4,a7,ffffffffc020145e <vprintfmt+0x256>
    else if (lflag) {
ffffffffc020145a:	08088d63          	beqz	a7,ffffffffc02014f4 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc020145e:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201462:	0a044d63          	bltz	s0,ffffffffc020151c <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201466:	8622                	mv	a2,s0
ffffffffc0201468:	8a66                	mv	s4,s9
ffffffffc020146a:	46a9                	li	a3,10
ffffffffc020146c:	bdcd                	j	ffffffffc020135e <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc020146e:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201472:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201474:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201476:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020147a:	8fb5                	xor	a5,a5,a3
ffffffffc020147c:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201480:	02d74163          	blt	a4,a3,ffffffffc02014a2 <vprintfmt+0x29a>
ffffffffc0201484:	00369793          	slli	a5,a3,0x3
ffffffffc0201488:	97de                	add	a5,a5,s7
ffffffffc020148a:	639c                	ld	a5,0(a5)
ffffffffc020148c:	cb99                	beqz	a5,ffffffffc02014a2 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020148e:	86be                	mv	a3,a5
ffffffffc0201490:	00001617          	auipc	a2,0x1
ffffffffc0201494:	aa060613          	addi	a2,a2,-1376 # ffffffffc0201f30 <buddy_pmm_manager+0x1b0>
ffffffffc0201498:	85a6                	mv	a1,s1
ffffffffc020149a:	854a                	mv	a0,s2
ffffffffc020149c:	0ce000ef          	jal	ra,ffffffffc020156a <printfmt>
ffffffffc02014a0:	b34d                	j	ffffffffc0201242 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02014a2:	00001617          	auipc	a2,0x1
ffffffffc02014a6:	a7e60613          	addi	a2,a2,-1410 # ffffffffc0201f20 <buddy_pmm_manager+0x1a0>
ffffffffc02014aa:	85a6                	mv	a1,s1
ffffffffc02014ac:	854a                	mv	a0,s2
ffffffffc02014ae:	0bc000ef          	jal	ra,ffffffffc020156a <printfmt>
ffffffffc02014b2:	bb41                	j	ffffffffc0201242 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02014b4:	00001417          	auipc	s0,0x1
ffffffffc02014b8:	a6440413          	addi	s0,s0,-1436 # ffffffffc0201f18 <buddy_pmm_manager+0x198>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02014bc:	85e2                	mv	a1,s8
ffffffffc02014be:	8522                	mv	a0,s0
ffffffffc02014c0:	e43e                	sd	a5,8(sp)
ffffffffc02014c2:	0fc000ef          	jal	ra,ffffffffc02015be <strnlen>
ffffffffc02014c6:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02014ca:	01b05b63          	blez	s11,ffffffffc02014e0 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02014ce:	67a2                	ld	a5,8(sp)
ffffffffc02014d0:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02014d4:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02014d6:	85a6                	mv	a1,s1
ffffffffc02014d8:	8552                	mv	a0,s4
ffffffffc02014da:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02014dc:	fe0d9ce3          	bnez	s11,ffffffffc02014d4 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014e0:	00044783          	lbu	a5,0(s0)
ffffffffc02014e4:	00140a13          	addi	s4,s0,1
ffffffffc02014e8:	0007851b          	sext.w	a0,a5
ffffffffc02014ec:	d3a5                	beqz	a5,ffffffffc020144c <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02014ee:	05e00413          	li	s0,94
ffffffffc02014f2:	bf39                	j	ffffffffc0201410 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02014f4:	000a2403          	lw	s0,0(s4)
ffffffffc02014f8:	b7ad                	j	ffffffffc0201462 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02014fa:	000a6603          	lwu	a2,0(s4)
ffffffffc02014fe:	46a1                	li	a3,8
ffffffffc0201500:	8a2e                	mv	s4,a1
ffffffffc0201502:	bdb1                	j	ffffffffc020135e <vprintfmt+0x156>
ffffffffc0201504:	000a6603          	lwu	a2,0(s4)
ffffffffc0201508:	46a9                	li	a3,10
ffffffffc020150a:	8a2e                	mv	s4,a1
ffffffffc020150c:	bd89                	j	ffffffffc020135e <vprintfmt+0x156>
ffffffffc020150e:	000a6603          	lwu	a2,0(s4)
ffffffffc0201512:	46c1                	li	a3,16
ffffffffc0201514:	8a2e                	mv	s4,a1
ffffffffc0201516:	b5a1                	j	ffffffffc020135e <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201518:	9902                	jalr	s2
ffffffffc020151a:	bf09                	j	ffffffffc020142c <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020151c:	85a6                	mv	a1,s1
ffffffffc020151e:	02d00513          	li	a0,45
ffffffffc0201522:	e03e                	sd	a5,0(sp)
ffffffffc0201524:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201526:	6782                	ld	a5,0(sp)
ffffffffc0201528:	8a66                	mv	s4,s9
ffffffffc020152a:	40800633          	neg	a2,s0
ffffffffc020152e:	46a9                	li	a3,10
ffffffffc0201530:	b53d                	j	ffffffffc020135e <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201532:	03b05163          	blez	s11,ffffffffc0201554 <vprintfmt+0x34c>
ffffffffc0201536:	02d00693          	li	a3,45
ffffffffc020153a:	f6d79de3          	bne	a5,a3,ffffffffc02014b4 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc020153e:	00001417          	auipc	s0,0x1
ffffffffc0201542:	9da40413          	addi	s0,s0,-1574 # ffffffffc0201f18 <buddy_pmm_manager+0x198>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201546:	02800793          	li	a5,40
ffffffffc020154a:	02800513          	li	a0,40
ffffffffc020154e:	00140a13          	addi	s4,s0,1
ffffffffc0201552:	bd6d                	j	ffffffffc020140c <vprintfmt+0x204>
ffffffffc0201554:	00001a17          	auipc	s4,0x1
ffffffffc0201558:	9c5a0a13          	addi	s4,s4,-1595 # ffffffffc0201f19 <buddy_pmm_manager+0x199>
ffffffffc020155c:	02800513          	li	a0,40
ffffffffc0201560:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201564:	05e00413          	li	s0,94
ffffffffc0201568:	b565                	j	ffffffffc0201410 <vprintfmt+0x208>

ffffffffc020156a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020156a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020156c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201570:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201572:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201574:	ec06                	sd	ra,24(sp)
ffffffffc0201576:	f83a                	sd	a4,48(sp)
ffffffffc0201578:	fc3e                	sd	a5,56(sp)
ffffffffc020157a:	e0c2                	sd	a6,64(sp)
ffffffffc020157c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020157e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201580:	c89ff0ef          	jal	ra,ffffffffc0201208 <vprintfmt>
}
ffffffffc0201584:	60e2                	ld	ra,24(sp)
ffffffffc0201586:	6161                	addi	sp,sp,80
ffffffffc0201588:	8082                	ret

ffffffffc020158a <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc020158a:	4781                	li	a5,0
ffffffffc020158c:	00005717          	auipc	a4,0x5
ffffffffc0201590:	a8473703          	ld	a4,-1404(a4) # ffffffffc0206010 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201594:	88ba                	mv	a7,a4
ffffffffc0201596:	852a                	mv	a0,a0
ffffffffc0201598:	85be                	mv	a1,a5
ffffffffc020159a:	863e                	mv	a2,a5
ffffffffc020159c:	00000073          	ecall
ffffffffc02015a0:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02015a2:	8082                	ret

ffffffffc02015a4 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02015a4:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02015a8:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02015aa:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02015ac:	cb81                	beqz	a5,ffffffffc02015bc <strlen+0x18>
        cnt ++;
ffffffffc02015ae:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02015b0:	00a707b3          	add	a5,a4,a0
ffffffffc02015b4:	0007c783          	lbu	a5,0(a5)
ffffffffc02015b8:	fbfd                	bnez	a5,ffffffffc02015ae <strlen+0xa>
ffffffffc02015ba:	8082                	ret
    }
    return cnt;
}
ffffffffc02015bc:	8082                	ret

ffffffffc02015be <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02015be:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02015c0:	e589                	bnez	a1,ffffffffc02015ca <strnlen+0xc>
ffffffffc02015c2:	a811                	j	ffffffffc02015d6 <strnlen+0x18>
        cnt ++;
ffffffffc02015c4:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02015c6:	00f58863          	beq	a1,a5,ffffffffc02015d6 <strnlen+0x18>
ffffffffc02015ca:	00f50733          	add	a4,a0,a5
ffffffffc02015ce:	00074703          	lbu	a4,0(a4)
ffffffffc02015d2:	fb6d                	bnez	a4,ffffffffc02015c4 <strnlen+0x6>
ffffffffc02015d4:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02015d6:	852e                	mv	a0,a1
ffffffffc02015d8:	8082                	ret

ffffffffc02015da <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02015da:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02015de:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02015e2:	cb89                	beqz	a5,ffffffffc02015f4 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02015e4:	0505                	addi	a0,a0,1
ffffffffc02015e6:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02015e8:	fee789e3          	beq	a5,a4,ffffffffc02015da <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02015ec:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02015f0:	9d19                	subw	a0,a0,a4
ffffffffc02015f2:	8082                	ret
ffffffffc02015f4:	4501                	li	a0,0
ffffffffc02015f6:	bfed                	j	ffffffffc02015f0 <strcmp+0x16>

ffffffffc02015f8 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02015f8:	c20d                	beqz	a2,ffffffffc020161a <strncmp+0x22>
ffffffffc02015fa:	962e                	add	a2,a2,a1
ffffffffc02015fc:	a031                	j	ffffffffc0201608 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc02015fe:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201600:	00e79a63          	bne	a5,a4,ffffffffc0201614 <strncmp+0x1c>
ffffffffc0201604:	00b60b63          	beq	a2,a1,ffffffffc020161a <strncmp+0x22>
ffffffffc0201608:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc020160c:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020160e:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0201612:	f7f5                	bnez	a5,ffffffffc02015fe <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201614:	40e7853b          	subw	a0,a5,a4
}
ffffffffc0201618:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020161a:	4501                	li	a0,0
ffffffffc020161c:	8082                	ret

ffffffffc020161e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020161e:	ca01                	beqz	a2,ffffffffc020162e <memset+0x10>
ffffffffc0201620:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201622:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201624:	0785                	addi	a5,a5,1
ffffffffc0201626:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020162a:	fec79de3          	bne	a5,a2,ffffffffc0201624 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020162e:	8082                	ret
