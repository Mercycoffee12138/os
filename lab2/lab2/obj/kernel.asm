
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
ffffffffc0200050:	77c50513          	addi	a0,a0,1916 # ffffffffc02017c8 <etext+0x2>
void print_kerninfo(void) {
ffffffffc0200054:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200056:	0f6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", (uintptr_t)kern_init);
ffffffffc020005a:	00000597          	auipc	a1,0x0
ffffffffc020005e:	07e58593          	addi	a1,a1,126 # ffffffffc02000d8 <kern_init>
ffffffffc0200062:	00001517          	auipc	a0,0x1
ffffffffc0200066:	78650513          	addi	a0,a0,1926 # ffffffffc02017e8 <etext+0x22>
ffffffffc020006a:	0e2000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020006e:	00001597          	auipc	a1,0x1
ffffffffc0200072:	75858593          	addi	a1,a1,1880 # ffffffffc02017c6 <etext>
ffffffffc0200076:	00001517          	auipc	a0,0x1
ffffffffc020007a:	79250513          	addi	a0,a0,1938 # ffffffffc0201808 <etext+0x42>
ffffffffc020007e:	0ce000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200082:	00006597          	auipc	a1,0x6
ffffffffc0200086:	f9658593          	addi	a1,a1,-106 # ffffffffc0206018 <free_lists>
ffffffffc020008a:	00001517          	auipc	a0,0x1
ffffffffc020008e:	79e50513          	addi	a0,a0,1950 # ffffffffc0201828 <etext+0x62>
ffffffffc0200092:	0ba000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200096:	00006597          	auipc	a1,0x6
ffffffffc020009a:	0d258593          	addi	a1,a1,210 # ffffffffc0206168 <end>
ffffffffc020009e:	00001517          	auipc	a0,0x1
ffffffffc02000a2:	7aa50513          	addi	a0,a0,1962 # ffffffffc0201848 <etext+0x82>
ffffffffc02000a6:	0a6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - (char*)kern_init + 1023) / 1024);
ffffffffc02000aa:	00006597          	auipc	a1,0x6
ffffffffc02000ae:	4bd58593          	addi	a1,a1,1213 # ffffffffc0206567 <end+0x3ff>
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
ffffffffc02000d0:	79c50513          	addi	a0,a0,1948 # ffffffffc0201868 <etext+0xa2>
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
ffffffffc02000e4:	08860613          	addi	a2,a2,136 # ffffffffc0206168 <end>
int kern_init(void) {
ffffffffc02000e8:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc02000ea:	8e09                	sub	a2,a2,a0
ffffffffc02000ec:	4581                	li	a1,0
int kern_init(void) {
ffffffffc02000ee:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc02000f0:	6c4010ef          	jal	ra,ffffffffc02017b4 <memset>
    dtb_init();
ffffffffc02000f4:	12c000ef          	jal	ra,ffffffffc0200220 <dtb_init>
    cons_init();  // init the console
ffffffffc02000f8:	11e000ef          	jal	ra,ffffffffc0200216 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc02000fc:	00001517          	auipc	a0,0x1
ffffffffc0200100:	79c50513          	addi	a0,a0,1948 # ffffffffc0201898 <etext+0xd2>
ffffffffc0200104:	07e000ef          	jal	ra,ffffffffc0200182 <cputs>

    print_kerninfo();
ffffffffc0200108:	f43ff0ef          	jal	ra,ffffffffc020004a <print_kerninfo>

    // grade_backtrace();
    pmm_init();  // init physical memory management
ffffffffc020010c:	04e010ef          	jal	ra,ffffffffc020115a <pmm_init>

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
ffffffffc0200140:	25e010ef          	jal	ra,ffffffffc020139e <vprintfmt>
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
ffffffffc0200176:	228010ef          	jal	ra,ffffffffc020139e <vprintfmt>
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
ffffffffc02001f6:	6c650513          	addi	a0,a0,1734 # ffffffffc02018b8 <etext+0xf2>
    va_start(ap, fmt);
ffffffffc02001fa:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001fc:	f51ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200200:	65a2                	ld	a1,8(sp)
ffffffffc0200202:	8522                	mv	a0,s0
ffffffffc0200204:	f29ff0ef          	jal	ra,ffffffffc020012c <vcprintf>
    cprintf("\n");
ffffffffc0200208:	00002517          	auipc	a0,0x2
ffffffffc020020c:	b5850513          	addi	a0,a0,-1192 # ffffffffc0201d60 <etext+0x59a>
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
ffffffffc020021c:	5040106f          	j	ffffffffc0201720 <sbi_console_putchar>

ffffffffc0200220 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc0200220:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc0200222:	00001517          	auipc	a0,0x1
ffffffffc0200226:	6b650513          	addi	a0,a0,1718 # ffffffffc02018d8 <etext+0x112>
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
ffffffffc0200254:	69850513          	addi	a0,a0,1688 # ffffffffc02018e8 <etext+0x122>
ffffffffc0200258:	ef5ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020025c:	00006417          	auipc	s0,0x6
ffffffffc0200260:	dac40413          	addi	s0,s0,-596 # ffffffffc0206008 <boot_dtb>
ffffffffc0200264:	600c                	ld	a1,0(s0)
ffffffffc0200266:	00001517          	auipc	a0,0x1
ffffffffc020026a:	69250513          	addi	a0,a0,1682 # ffffffffc02018f8 <etext+0x132>
ffffffffc020026e:	edfff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200272:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200276:	00001517          	auipc	a0,0x1
ffffffffc020027a:	69a50513          	addi	a0,a0,1690 # ffffffffc0201910 <etext+0x14a>
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
ffffffffc02002be:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfed9d85>
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
ffffffffc0200334:	63090913          	addi	s2,s2,1584 # ffffffffc0201960 <etext+0x19a>
ffffffffc0200338:	49bd                	li	s3,15
        switch (token) {
ffffffffc020033a:	4d91                	li	s11,4
ffffffffc020033c:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020033e:	00001497          	auipc	s1,0x1
ffffffffc0200342:	61a48493          	addi	s1,s1,1562 # ffffffffc0201958 <etext+0x192>
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
ffffffffc0200396:	64650513          	addi	a0,a0,1606 # ffffffffc02019d8 <etext+0x212>
ffffffffc020039a:	db3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	67250513          	addi	a0,a0,1650 # ffffffffc0201a10 <etext+0x24a>
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
ffffffffc02003e2:	55250513          	addi	a0,a0,1362 # ffffffffc0201930 <etext+0x16a>
}
ffffffffc02003e6:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003e8:	b395                	j	ffffffffc020014c <cprintf>
                int name_len = strlen(name);
ffffffffc02003ea:	8556                	mv	a0,s5
ffffffffc02003ec:	34e010ef          	jal	ra,ffffffffc020173a <strlen>
ffffffffc02003f0:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003f2:	4619                	li	a2,6
ffffffffc02003f4:	85a6                	mv	a1,s1
ffffffffc02003f6:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02003f8:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003fa:	394010ef          	jal	ra,ffffffffc020178e <strncmp>
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
ffffffffc0200490:	2e0010ef          	jal	ra,ffffffffc0201770 <strcmp>
ffffffffc0200494:	66a2                	ld	a3,8(sp)
ffffffffc0200496:	f94d                	bnez	a0,ffffffffc0200448 <dtb_init+0x228>
ffffffffc0200498:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200448 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc020049c:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc02004a0:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc02004a4:	00001517          	auipc	a0,0x1
ffffffffc02004a8:	4c450513          	addi	a0,a0,1220 # ffffffffc0201968 <etext+0x1a2>
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
ffffffffc0200576:	41650513          	addi	a0,a0,1046 # ffffffffc0201988 <etext+0x1c2>
ffffffffc020057a:	bd3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020057e:	014b5613          	srli	a2,s6,0x14
ffffffffc0200582:	85da                	mv	a1,s6
ffffffffc0200584:	00001517          	auipc	a0,0x1
ffffffffc0200588:	41c50513          	addi	a0,a0,1052 # ffffffffc02019a0 <etext+0x1da>
ffffffffc020058c:	bc1ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200590:	008b05b3          	add	a1,s6,s0
ffffffffc0200594:	15fd                	addi	a1,a1,-1
ffffffffc0200596:	00001517          	auipc	a0,0x1
ffffffffc020059a:	42a50513          	addi	a0,a0,1066 # ffffffffc02019c0 <etext+0x1fa>
ffffffffc020059e:	bafff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB init completed\n");
ffffffffc02005a2:	00001517          	auipc	a0,0x1
ffffffffc02005a6:	46e50513          	addi	a0,a0,1134 # ffffffffc0201a10 <etext+0x24a>
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
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc02005d0:	00006797          	auipc	a5,0x6
ffffffffc02005d4:	a4878793          	addi	a5,a5,-1464 # ffffffffc0206018 <free_lists>
ffffffffc02005d8:	00006717          	auipc	a4,0x6
ffffffffc02005dc:	b4870713          	addi	a4,a4,-1208 # ffffffffc0206120 <is_panic>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02005e0:	e79c                	sd	a5,8(a5)
ffffffffc02005e2:	e39c                	sd	a5,0(a5)
        list_init(&(free_lists[i].free_list));
        free_lists[i].nr_free = 0;
ffffffffc02005e4:	0007a823          	sw	zero,16(a5)
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc02005e8:	07e1                	addi	a5,a5,24
ffffffffc02005ea:	fee79be3          	bne	a5,a4,ffffffffc02005e0 <buddy_init+0x10>
    }
}
ffffffffc02005ee:	8082                	ret

ffffffffc02005f0 <buddy_nr_free_pages>:
}

static size_t
buddy_nr_free_pages(void) {
    size_t total = 0;
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc02005f0:	00006697          	auipc	a3,0x6
ffffffffc02005f4:	a3868693          	addi	a3,a3,-1480 # ffffffffc0206028 <free_lists+0x10>
ffffffffc02005f8:	4701                	li	a4,0
    size_t total = 0;
ffffffffc02005fa:	4501                	li	a0,0
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc02005fc:	462d                	li	a2,11
        total += free_lists[i].nr_free * (1 << i);
ffffffffc02005fe:	429c                	lw	a5,0(a3)
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200600:	06e1                	addi	a3,a3,24
        total += free_lists[i].nr_free * (1 << i);
ffffffffc0200602:	00e797bb          	sllw	a5,a5,a4
ffffffffc0200606:	1782                	slli	a5,a5,0x20
ffffffffc0200608:	9381                	srli	a5,a5,0x20
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc020060a:	2705                	addiw	a4,a4,1
        total += free_lists[i].nr_free * (1 << i);
ffffffffc020060c:	953e                	add	a0,a0,a5
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc020060e:	fec718e3          	bne	a4,a2,ffffffffc02005fe <buddy_nr_free_pages+0xe>
    }
    return total;
}
ffffffffc0200612:	8082                	ret

ffffffffc0200614 <buddy_check>:
    free_page(p2);
}

// Buddy System特有的检查函数
static void
buddy_check(void) {
ffffffffc0200614:	710d                	addi	sp,sp,-352
    cprintf("=== Buddy System Check Started ===\n");
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	41250513          	addi	a0,a0,1042 # ffffffffc0201a28 <etext+0x262>
buddy_check(void) {
ffffffffc020061e:	ee86                	sd	ra,344(sp)
ffffffffc0200620:	eaa2                	sd	s0,336(sp)
ffffffffc0200622:	e6a6                	sd	s1,328(sp)
ffffffffc0200624:	e2ca                	sd	s2,320(sp)
ffffffffc0200626:	fe4e                	sd	s3,312(sp)
ffffffffc0200628:	fa52                	sd	s4,304(sp)
ffffffffc020062a:	f656                	sd	s5,296(sp)
ffffffffc020062c:	f25a                	sd	s6,288(sp)
ffffffffc020062e:	ee5e                	sd	s7,280(sp)
ffffffffc0200630:	ea62                	sd	s8,272(sp)
    cprintf("=== Buddy System Check Started ===\n");
ffffffffc0200632:	b1bff0ef          	jal	ra,ffffffffc020014c <cprintf>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200636:	4505                	li	a0,1
ffffffffc0200638:	30b000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
ffffffffc020063c:	6a050263          	beqz	a0,ffffffffc0200ce0 <buddy_check+0x6cc>
ffffffffc0200640:	8aaa                	mv	s5,a0
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200642:	4505                	li	a0,1
ffffffffc0200644:	2ff000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
ffffffffc0200648:	8a2a                	mv	s4,a0
ffffffffc020064a:	74050b63          	beqz	a0,ffffffffc0200da0 <buddy_check+0x78c>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020064e:	4505                	li	a0,1
ffffffffc0200650:	2f3000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
ffffffffc0200654:	892a                	mv	s2,a0
ffffffffc0200656:	72050563          	beqz	a0,ffffffffc0200d80 <buddy_check+0x76c>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020065a:	554a8363          	beq	s5,s4,ffffffffc0200ba0 <buddy_check+0x58c>
ffffffffc020065e:	54aa8163          	beq	s5,a0,ffffffffc0200ba0 <buddy_check+0x58c>
ffffffffc0200662:	52aa0f63          	beq	s4,a0,ffffffffc0200ba0 <buddy_check+0x58c>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200666:	000aa783          	lw	a5,0(s5)
ffffffffc020066a:	50079b63          	bnez	a5,ffffffffc0200b80 <buddy_check+0x56c>
ffffffffc020066e:	000a2783          	lw	a5,0(s4)
ffffffffc0200672:	50079763          	bnez	a5,ffffffffc0200b80 <buddy_check+0x56c>
    return page2ppn(page) << PGSHIFT;
}



static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc0200676:	4104                	lw	s1,0(a0)
ffffffffc0200678:	50049463          	bnez	s1,ffffffffc0200b80 <buddy_check+0x56c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020067c:	00006797          	auipc	a5,0x6
ffffffffc0200680:	ac47b783          	ld	a5,-1340(a5) # ffffffffc0206140 <pages>
ffffffffc0200684:	40fa8733          	sub	a4,s5,a5
ffffffffc0200688:	870d                	srai	a4,a4,0x3
ffffffffc020068a:	00002597          	auipc	a1,0x2
ffffffffc020068e:	eae5b583          	ld	a1,-338(a1) # ffffffffc0202538 <error_string+0x38>
ffffffffc0200692:	02b70733          	mul	a4,a4,a1
ffffffffc0200696:	00002617          	auipc	a2,0x2
ffffffffc020069a:	eaa63603          	ld	a2,-342(a2) # ffffffffc0202540 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020069e:	00006697          	auipc	a3,0x6
ffffffffc02006a2:	a9a6b683          	ld	a3,-1382(a3) # ffffffffc0206138 <npage>
ffffffffc02006a6:	06b2                	slli	a3,a3,0xc
ffffffffc02006a8:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02006aa:	0732                	slli	a4,a4,0xc
ffffffffc02006ac:	5ad77a63          	bgeu	a4,a3,ffffffffc0200c60 <buddy_check+0x64c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02006b0:	40fa0733          	sub	a4,s4,a5
ffffffffc02006b4:	870d                	srai	a4,a4,0x3
ffffffffc02006b6:	02b70733          	mul	a4,a4,a1
ffffffffc02006ba:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02006bc:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02006be:	58d77163          	bgeu	a4,a3,ffffffffc0200c40 <buddy_check+0x62c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02006c2:	40f507b3          	sub	a5,a0,a5
ffffffffc02006c6:	878d                	srai	a5,a5,0x3
ffffffffc02006c8:	02b787b3          	mul	a5,a5,a1
ffffffffc02006cc:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02006ce:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02006d0:	54d7f863          	bgeu	a5,a3,ffffffffc0200c20 <buddy_check+0x60c>
ffffffffc02006d4:	00006997          	auipc	s3,0x6
ffffffffc02006d8:	94498993          	addi	s3,s3,-1724 # ffffffffc0206018 <free_lists>
ffffffffc02006dc:	0020                	addi	s0,sp,8
ffffffffc02006de:	00006817          	auipc	a6,0x6
ffffffffc02006e2:	a4280813          	addi	a6,a6,-1470 # ffffffffc0206120 <is_panic>
ffffffffc02006e6:	8722                	mv	a4,s0
ffffffffc02006e8:	87ce                	mv	a5,s3
        free_lists_store[i] = free_lists[i];
ffffffffc02006ea:	638c                	ld	a1,0(a5)
ffffffffc02006ec:	6790                	ld	a2,8(a5)
ffffffffc02006ee:	6b94                	ld	a3,16(a5)
ffffffffc02006f0:	e30c                	sd	a1,0(a4)
ffffffffc02006f2:	e710                	sd	a2,8(a4)
ffffffffc02006f4:	eb14                	sd	a3,16(a4)
ffffffffc02006f6:	e79c                	sd	a5,8(a5)
ffffffffc02006f8:	e39c                	sd	a5,0(a5)
        free_lists[i].nr_free = 0;
ffffffffc02006fa:	0007a823          	sw	zero,16(a5)
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc02006fe:	07e1                	addi	a5,a5,24
ffffffffc0200700:	0761                	addi	a4,a4,24
ffffffffc0200702:	ff0794e3          	bne	a5,a6,ffffffffc02006ea <buddy_check+0xd6>
    assert(alloc_page() == NULL);
ffffffffc0200706:	4505                	li	a0,1
ffffffffc0200708:	23b000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
ffffffffc020070c:	4e051a63          	bnez	a0,ffffffffc0200c00 <buddy_check+0x5ec>
    free_page(p0);
ffffffffc0200710:	4585                	li	a1,1
ffffffffc0200712:	8556                	mv	a0,s5
ffffffffc0200714:	23b000ef          	jal	ra,ffffffffc020114e <free_pages>
    free_page(p1);
ffffffffc0200718:	4585                	li	a1,1
ffffffffc020071a:	8552                	mv	a0,s4
ffffffffc020071c:	233000ef          	jal	ra,ffffffffc020114e <free_pages>
    free_page(p2);
ffffffffc0200720:	4585                	li	a1,1
ffffffffc0200722:	854a                	mv	a0,s2
ffffffffc0200724:	22b000ef          	jal	ra,ffffffffc020114e <free_pages>
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200728:	00006917          	auipc	s2,0x6
ffffffffc020072c:	90090913          	addi	s2,s2,-1792 # ffffffffc0206028 <free_lists+0x10>
    free_page(p2);
ffffffffc0200730:	86ca                	mv	a3,s2
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200732:	4701                	li	a4,0
    size_t total = 0;
ffffffffc0200734:	4601                	li	a2,0
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200736:	45ad                	li	a1,11
        total += free_lists[i].nr_free * (1 << i);
ffffffffc0200738:	429c                	lw	a5,0(a3)
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc020073a:	06e1                	addi	a3,a3,24
        total += free_lists[i].nr_free * (1 << i);
ffffffffc020073c:	00e797bb          	sllw	a5,a5,a4
ffffffffc0200740:	1782                	slli	a5,a5,0x20
ffffffffc0200742:	9381                	srli	a5,a5,0x20
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200744:	2705                	addiw	a4,a4,1
        total += free_lists[i].nr_free * (1 << i);
ffffffffc0200746:	963e                	add	a2,a2,a5
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200748:	feb718e3          	bne	a4,a1,ffffffffc0200738 <buddy_check+0x124>
    assert(buddy_nr_free_pages() >= 3);
ffffffffc020074c:	4789                	li	a5,2
ffffffffc020074e:	48c7f963          	bgeu	a5,a2,ffffffffc0200be0 <buddy_check+0x5cc>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200752:	4505                	li	a0,1
ffffffffc0200754:	1ef000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
ffffffffc0200758:	8a2a                	mv	s4,a0
ffffffffc020075a:	46050363          	beqz	a0,ffffffffc0200bc0 <buddy_check+0x5ac>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020075e:	4505                	li	a0,1
ffffffffc0200760:	1e3000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
ffffffffc0200764:	8b2a                	mv	s6,a0
ffffffffc0200766:	5e050d63          	beqz	a0,ffffffffc0200d60 <buddy_check+0x74c>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020076a:	4505                	li	a0,1
ffffffffc020076c:	1d7000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
ffffffffc0200770:	8aaa                	mv	s5,a0
ffffffffc0200772:	5c050763          	beqz	a0,ffffffffc0200d40 <buddy_check+0x72c>
    assert(alloc_page() == NULL);
ffffffffc0200776:	4505                	li	a0,1
ffffffffc0200778:	1cb000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
ffffffffc020077c:	52051263          	bnez	a0,ffffffffc0200ca0 <buddy_check+0x68c>
    free_page(p0);
ffffffffc0200780:	4585                	li	a1,1
ffffffffc0200782:	8552                	mv	a0,s4
ffffffffc0200784:	1cb000ef          	jal	ra,ffffffffc020114e <free_pages>
    assert((p = alloc_page()) == p0);
ffffffffc0200788:	4505                	li	a0,1
ffffffffc020078a:	1b9000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
ffffffffc020078e:	8baa                	mv	s7,a0
ffffffffc0200790:	4eaa1863          	bne	s4,a0,ffffffffc0200c80 <buddy_check+0x66c>
    assert(alloc_page() == NULL);
ffffffffc0200794:	4505                	li	a0,1
ffffffffc0200796:	1ad000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
ffffffffc020079a:	003c                	addi	a5,sp,8
ffffffffc020079c:	10878613          	addi	a2,a5,264
ffffffffc02007a0:	58051063          	bnez	a0,ffffffffc0200d20 <buddy_check+0x70c>
        free_lists[i] = free_lists_store[i];
ffffffffc02007a4:	6014                	ld	a3,0(s0)
ffffffffc02007a6:	6418                	ld	a4,8(s0)
ffffffffc02007a8:	681c                	ld	a5,16(s0)
ffffffffc02007aa:	00d9b023          	sd	a3,0(s3)
ffffffffc02007ae:	00e9b423          	sd	a4,8(s3)
ffffffffc02007b2:	00f9b823          	sd	a5,16(s3)
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc02007b6:	0461                	addi	s0,s0,24
ffffffffc02007b8:	09e1                	addi	s3,s3,24
ffffffffc02007ba:	fec415e3          	bne	s0,a2,ffffffffc02007a4 <buddy_check+0x190>
    free_page(p);
ffffffffc02007be:	4585                	li	a1,1
ffffffffc02007c0:	855e                	mv	a0,s7
ffffffffc02007c2:	18d000ef          	jal	ra,ffffffffc020114e <free_pages>
    free_page(p1);
ffffffffc02007c6:	4585                	li	a1,1
ffffffffc02007c8:	855a                	mv	a0,s6
ffffffffc02007ca:	185000ef          	jal	ra,ffffffffc020114e <free_pages>
    free_page(p2);
ffffffffc02007ce:	4585                	li	a1,1
ffffffffc02007d0:	8556                	mv	a0,s5
ffffffffc02007d2:	17d000ef          	jal	ra,ffffffffc020114e <free_pages>
    
    basic_check();
    cprintf("Basic check passed!\n");
ffffffffc02007d6:	00001517          	auipc	a0,0x1
ffffffffc02007da:	42a50513          	addi	a0,a0,1066 # ffffffffc0201c00 <etext+0x43a>
ffffffffc02007de:	96fff0ef          	jal	ra,ffffffffc020014c <cprintf>

    // 1. 测试简单请求和释放操作，分配 1 页和 2 页，确保分配成功，然后释放这两块。
    cprintf("Testing simple alloc/free...\n");
ffffffffc02007e2:	00001517          	auipc	a0,0x1
ffffffffc02007e6:	43650513          	addi	a0,a0,1078 # ffffffffc0201c18 <etext+0x452>
ffffffffc02007ea:	963ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    struct Page *simple1 = alloc_pages(1);
ffffffffc02007ee:	4505                	li	a0,1
ffffffffc02007f0:	153000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
ffffffffc02007f4:	89aa                	mv	s3,a0
    struct Page *simple2 = alloc_pages(2);
ffffffffc02007f6:	4509                	li	a0,2
ffffffffc02007f8:	14b000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
ffffffffc02007fc:	842a                	mv	s0,a0
    assert(simple1 != NULL && simple2 != NULL);
ffffffffc02007fe:	36098163          	beqz	s3,ffffffffc0200b60 <buddy_check+0x54c>
ffffffffc0200802:	34050f63          	beqz	a0,ffffffffc0200b60 <buddy_check+0x54c>
    free_pages(simple1, 1);
ffffffffc0200806:	854e                	mv	a0,s3
ffffffffc0200808:	4585                	li	a1,1
ffffffffc020080a:	145000ef          	jal	ra,ffffffffc020114e <free_pages>
    free_pages(simple2, 2);
ffffffffc020080e:	4589                	li	a1,2
ffffffffc0200810:	8522                	mv	a0,s0
ffffffffc0200812:	13d000ef          	jal	ra,ffffffffc020114e <free_pages>
    cprintf("Simple alloc/free test passed!\n");
ffffffffc0200816:	00001517          	auipc	a0,0x1
ffffffffc020081a:	44a50513          	addi	a0,a0,1098 # ffffffffc0201c60 <etext+0x49a>
ffffffffc020081e:	92fff0ef          	jal	ra,ffffffffc020014c <cprintf>

    // 2. 测试复杂请求和释放操作，分配 3、5、7 页（不是 2 的幂），实际会分配到最近的 2 的幂（如 4、8 页），释放后测试伙伴合并机制和分配器对复杂请求的处理能力。
    cprintf("Testing complex alloc/free...\n");
ffffffffc0200822:	00001517          	auipc	a0,0x1
ffffffffc0200826:	45e50513          	addi	a0,a0,1118 # ffffffffc0201c80 <etext+0x4ba>
ffffffffc020082a:	923ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    struct Page *complex1 = alloc_pages(3);
ffffffffc020082e:	450d                	li	a0,3
ffffffffc0200830:	113000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
ffffffffc0200834:	842a                	mv	s0,a0
    struct Page *complex2 = alloc_pages(5);
ffffffffc0200836:	4515                	li	a0,5
ffffffffc0200838:	10b000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
ffffffffc020083c:	8a2a                	mv	s4,a0
    struct Page *complex3 = alloc_pages(7);
ffffffffc020083e:	451d                	li	a0,7
ffffffffc0200840:	103000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
ffffffffc0200844:	89aa                	mv	s3,a0
    assert(complex1 != NULL && complex2 != NULL && complex3 != NULL);
ffffffffc0200846:	2e040d63          	beqz	s0,ffffffffc0200b40 <buddy_check+0x52c>
ffffffffc020084a:	2e0a0b63          	beqz	s4,ffffffffc0200b40 <buddy_check+0x52c>
ffffffffc020084e:	2e050963          	beqz	a0,ffffffffc0200b40 <buddy_check+0x52c>
    free_pages(complex1, 3);
ffffffffc0200852:	458d                	li	a1,3
ffffffffc0200854:	8522                	mv	a0,s0
ffffffffc0200856:	0f9000ef          	jal	ra,ffffffffc020114e <free_pages>
    free_pages(complex2, 5);
ffffffffc020085a:	4595                	li	a1,5
ffffffffc020085c:	8552                	mv	a0,s4
ffffffffc020085e:	0f1000ef          	jal	ra,ffffffffc020114e <free_pages>
    free_pages(complex3, 7);
ffffffffc0200862:	459d                	li	a1,7
ffffffffc0200864:	854e                	mv	a0,s3
ffffffffc0200866:	0e9000ef          	jal	ra,ffffffffc020114e <free_pages>
    cprintf("Complex alloc/free test passed!\n");
ffffffffc020086a:	00001517          	auipc	a0,0x1
ffffffffc020086e:	47650513          	addi	a0,a0,1142 # ffffffffc0201ce0 <etext+0x51a>
ffffffffc0200872:	8dbff0ef          	jal	ra,ffffffffc020014c <cprintf>

    // 3. 测试请求和释放最小单元操作，测试分配和释放最小粒度（1 页），确保分配器能正确处理最小单位的请求。
    cprintf("Testing min unit alloc/free...\n");
ffffffffc0200876:	00001517          	auipc	a0,0x1
ffffffffc020087a:	49250513          	addi	a0,a0,1170 # ffffffffc0201d08 <etext+0x542>
ffffffffc020087e:	8cfff0ef          	jal	ra,ffffffffc020014c <cprintf>
    struct Page *min_unit = alloc_pages(1);
ffffffffc0200882:	4505                	li	a0,1
ffffffffc0200884:	0bf000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
    assert(min_unit != NULL);
ffffffffc0200888:	46050c63          	beqz	a0,ffffffffc0200d00 <buddy_check+0x6ec>
    free_pages(min_unit, 1);
ffffffffc020088c:	4585                	li	a1,1
ffffffffc020088e:	0c1000ef          	jal	ra,ffffffffc020114e <free_pages>
    cprintf("Min unit alloc/free test passed!\n");
ffffffffc0200892:	00001517          	auipc	a0,0x1
ffffffffc0200896:	4ae50513          	addi	a0,a0,1198 # ffffffffc0201d40 <etext+0x57a>
ffffffffc020089a:	8b3ff0ef          	jal	ra,ffffffffc020014c <cprintf>

    // 4. 测试请求和释放最大单元操作，测试分配和释放最大支持的块（2^MAX_ORDER 页），验证分配器在极限情况下的表现，内存不足时也能正确返回失败。
    cprintf("Testing max unit alloc/free...\n");
ffffffffc020089e:	00001517          	auipc	a0,0x1
ffffffffc02008a2:	4ca50513          	addi	a0,a0,1226 # ffffffffc0201d68 <etext+0x5a2>
ffffffffc02008a6:	8a7ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    struct Page *max_unit = alloc_pages(1 << MAX_ORDER);
ffffffffc02008aa:	40000513          	li	a0,1024
ffffffffc02008ae:	095000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
    if (max_unit != NULL) {
ffffffffc02008b2:	20050963          	beqz	a0,ffffffffc0200ac4 <buddy_check+0x4b0>
        free_pages(max_unit, 1 << MAX_ORDER);
ffffffffc02008b6:	40000593          	li	a1,1024
ffffffffc02008ba:	095000ef          	jal	ra,ffffffffc020114e <free_pages>
        cprintf("Max unit alloc/free test passed!\n");
ffffffffc02008be:	00001517          	auipc	a0,0x1
ffffffffc02008c2:	4ca50513          	addi	a0,a0,1226 # ffffffffc0201d88 <etext+0x5c2>
ffffffffc02008c6:	887ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    } else {
        cprintf("Max unit alloc failed (expected if insufficient memory)\n");
    }
    
    // 测试2的幂次分配，分配 1、2、4、8 页，测试标准块分配，确保分配器对常规块大小的支持。
    cprintf("Testing power-of-2 allocations...\n");
ffffffffc02008ca:	00001517          	auipc	a0,0x1
ffffffffc02008ce:	52650513          	addi	a0,a0,1318 # ffffffffc0201df0 <etext+0x62a>
ffffffffc02008d2:	87bff0ef          	jal	ra,ffffffffc020014c <cprintf>
    struct Page *p1 = alloc_pages(1);   // 分配1页
ffffffffc02008d6:	4505                	li	a0,1
ffffffffc02008d8:	06b000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
ffffffffc02008dc:	8baa                	mv	s7,a0
    struct Page *p2 = alloc_pages(2);   // 分配2页
ffffffffc02008de:	4509                	li	a0,2
ffffffffc02008e0:	063000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
ffffffffc02008e4:	8b2a                	mv	s6,a0
    struct Page *p4 = alloc_pages(4);   // 分配4页
ffffffffc02008e6:	4511                	li	a0,4
ffffffffc02008e8:	05b000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
ffffffffc02008ec:	8aaa                	mv	s5,a0
    struct Page *p8 = alloc_pages(8);   // 分配8页
ffffffffc02008ee:	4521                	li	a0,8
ffffffffc02008f0:	053000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
ffffffffc02008f4:	8a2a                	mv	s4,a0
    
    assert(p1 != NULL && p2 != NULL && p4 != NULL && p8 != NULL);
ffffffffc02008f6:	220b8563          	beqz	s7,ffffffffc0200b20 <buddy_check+0x50c>
ffffffffc02008fa:	220b0363          	beqz	s6,ffffffffc0200b20 <buddy_check+0x50c>
ffffffffc02008fe:	220a8163          	beqz	s5,ffffffffc0200b20 <buddy_check+0x50c>
ffffffffc0200902:	20050f63          	beqz	a0,ffffffffc0200b20 <buddy_check+0x50c>
    cprintf("Power-of-2 allocations successful!\n");
ffffffffc0200906:	00001517          	auipc	a0,0x1
ffffffffc020090a:	54a50513          	addi	a0,a0,1354 # ffffffffc0201e50 <etext+0x68a>
ffffffffc020090e:	83fff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 测试非2的幂次分配(应该向上取整)分配 3、5 页，实际会分配到最近的 2 的幂（4、8 页），测试分配器的向上取整策略。
    cprintf("Testing non-power-of-2 allocations...\n");
ffffffffc0200912:	00001517          	auipc	a0,0x1
ffffffffc0200916:	56650513          	addi	a0,a0,1382 # ffffffffc0201e78 <etext+0x6b2>
ffffffffc020091a:	833ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    struct Page *p3 = alloc_pages(3);   // 应该分配4页
ffffffffc020091e:	450d                	li	a0,3
ffffffffc0200920:	023000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
ffffffffc0200924:	89aa                	mv	s3,a0
    struct Page *p5 = alloc_pages(5);   // 应该分配8页
ffffffffc0200926:	4515                	li	a0,5
ffffffffc0200928:	01b000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
ffffffffc020092c:	842a                	mv	s0,a0
    
    assert(p3 != NULL && p5 != NULL);
ffffffffc020092e:	1c098963          	beqz	s3,ffffffffc0200b00 <buddy_check+0x4ec>
ffffffffc0200932:	1c050763          	beqz	a0,ffffffffc0200b00 <buddy_check+0x4ec>
    cprintf("Non-power-of-2 allocations successful!\n");
ffffffffc0200936:	00001517          	auipc	a0,0x1
ffffffffc020093a:	58a50513          	addi	a0,a0,1418 # ffffffffc0201ec0 <etext+0x6fa>
ffffffffc020093e:	80fff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 测试释放和合并，释放前面分配的所有块，统计释放前后空闲页数，验证伙伴合并机制是否正常工作。
    cprintf("Testing free and coalescing...\n");
ffffffffc0200942:	00001517          	auipc	a0,0x1
ffffffffc0200946:	5a650513          	addi	a0,a0,1446 # ffffffffc0201ee8 <etext+0x722>
ffffffffc020094a:	803ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    size_t total = 0;
ffffffffc020094e:	4c01                	li	s8,0
    cprintf("Testing free and coalescing...\n");
ffffffffc0200950:	00005697          	auipc	a3,0x5
ffffffffc0200954:	6d868693          	addi	a3,a3,1752 # ffffffffc0206028 <free_lists+0x10>
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200958:	4701                	li	a4,0
ffffffffc020095a:	462d                	li	a2,11
        total += free_lists[i].nr_free * (1 << i);
ffffffffc020095c:	429c                	lw	a5,0(a3)
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc020095e:	06e1                	addi	a3,a3,24
        total += free_lists[i].nr_free * (1 << i);
ffffffffc0200960:	00e797bb          	sllw	a5,a5,a4
ffffffffc0200964:	1782                	slli	a5,a5,0x20
ffffffffc0200966:	9381                	srli	a5,a5,0x20
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200968:	2705                	addiw	a4,a4,1
        total += free_lists[i].nr_free * (1 << i);
ffffffffc020096a:	9c3e                	add	s8,s8,a5
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc020096c:	fec718e3          	bne	a4,a2,ffffffffc020095c <buddy_check+0x348>
    size_t free_before = buddy_nr_free_pages();
    
    free_pages(p1, 1);
ffffffffc0200970:	4585                	li	a1,1
ffffffffc0200972:	855e                	mv	a0,s7
ffffffffc0200974:	7da000ef          	jal	ra,ffffffffc020114e <free_pages>
    free_pages(p2, 2);
ffffffffc0200978:	4589                	li	a1,2
ffffffffc020097a:	855a                	mv	a0,s6
ffffffffc020097c:	7d2000ef          	jal	ra,ffffffffc020114e <free_pages>
    free_pages(p4, 4);
ffffffffc0200980:	4591                	li	a1,4
ffffffffc0200982:	8556                	mv	a0,s5
ffffffffc0200984:	7ca000ef          	jal	ra,ffffffffc020114e <free_pages>
    free_pages(p8, 8);
ffffffffc0200988:	45a1                	li	a1,8
ffffffffc020098a:	8552                	mv	a0,s4
ffffffffc020098c:	7c2000ef          	jal	ra,ffffffffc020114e <free_pages>
    free_pages(p3, 3);  // 实际释放4页
ffffffffc0200990:	458d                	li	a1,3
ffffffffc0200992:	854e                	mv	a0,s3
ffffffffc0200994:	7ba000ef          	jal	ra,ffffffffc020114e <free_pages>
    free_pages(p5, 5);  // 实际释放8页
ffffffffc0200998:	4595                	li	a1,5
ffffffffc020099a:	8522                	mv	a0,s0
ffffffffc020099c:	7b2000ef          	jal	ra,ffffffffc020114e <free_pages>
ffffffffc02009a0:	00005697          	auipc	a3,0x5
ffffffffc02009a4:	68868693          	addi	a3,a3,1672 # ffffffffc0206028 <free_lists+0x10>
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc02009a8:	4701                	li	a4,0
    size_t total = 0;
ffffffffc02009aa:	4601                	li	a2,0
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc02009ac:	45ad                	li	a1,11
        total += free_lists[i].nr_free * (1 << i);
ffffffffc02009ae:	429c                	lw	a5,0(a3)
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc02009b0:	06e1                	addi	a3,a3,24
        total += free_lists[i].nr_free * (1 << i);
ffffffffc02009b2:	00e797bb          	sllw	a5,a5,a4
ffffffffc02009b6:	1782                	slli	a5,a5,0x20
ffffffffc02009b8:	9381                	srli	a5,a5,0x20
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc02009ba:	2705                	addiw	a4,a4,1
        total += free_lists[i].nr_free * (1 << i);
ffffffffc02009bc:	963e                	add	a2,a2,a5
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc02009be:	feb718e3          	bne	a4,a1,ffffffffc02009ae <buddy_check+0x39a>
    
    size_t free_after = buddy_nr_free_pages();
    cprintf("Free pages before: %d, after: %d\n", free_before, free_after);
ffffffffc02009c2:	85e2                	mv	a1,s8
ffffffffc02009c4:	00001517          	auipc	a0,0x1
ffffffffc02009c8:	54450513          	addi	a0,a0,1348 # ffffffffc0201f08 <etext+0x742>
ffffffffc02009cc:	f80ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 测试大块分配，分配 64 页大块，测试分配器对大块分配的支持和释放后的恢复能力。
    cprintf("Testing large block allocation...\n");
ffffffffc02009d0:	00001517          	auipc	a0,0x1
ffffffffc02009d4:	56050513          	addi	a0,a0,1376 # ffffffffc0201f30 <etext+0x76a>
ffffffffc02009d8:	f74ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    struct Page *large = alloc_pages(64);
ffffffffc02009dc:	04000513          	li	a0,64
ffffffffc02009e0:	762000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
ffffffffc02009e4:	842a                	mv	s0,a0
    if (large != NULL) {
ffffffffc02009e6:	0e050663          	beqz	a0,ffffffffc0200ad2 <buddy_check+0x4be>
        cprintf("Large block (64 pages) allocation successful!\n");
ffffffffc02009ea:	00001517          	auipc	a0,0x1
ffffffffc02009ee:	56e50513          	addi	a0,a0,1390 # ffffffffc0201f58 <etext+0x792>
ffffffffc02009f2:	f5aff0ef          	jal	ra,ffffffffc020014c <cprintf>
        free_pages(large, 64);
ffffffffc02009f6:	04000593          	li	a1,64
ffffffffc02009fa:	8522                	mv	a0,s0
ffffffffc02009fc:	752000ef          	jal	ra,ffffffffc020114e <free_pages>
    } else {
        cprintf("Large block allocation failed (expected if insufficient memory)\n");
    }
    
    // 测试边界情况
    cprintf("Testing boundary cases...\n");
ffffffffc0200a00:	00001517          	auipc	a0,0x1
ffffffffc0200a04:	5d050513          	addi	a0,a0,1488 # ffffffffc0201fd0 <etext+0x80a>
ffffffffc0200a08:	f44ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 尝试分配超大块
    struct Page *huge = alloc_pages(1 << (MAX_ORDER + 1));
ffffffffc0200a0c:	6505                	lui	a0,0x1
ffffffffc0200a0e:	80050513          	addi	a0,a0,-2048 # 800 <kern_entry-0xffffffffc01ff800>
ffffffffc0200a12:	730000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
    assert(huge == NULL);  // 应该失败
ffffffffc0200a16:	2a051563          	bnez	a0,ffffffffc0200cc0 <buddy_check+0x6ac>
    cprintf("Oversized allocation correctly failed!\n");
ffffffffc0200a1a:	00001517          	auipc	a0,0x1
ffffffffc0200a1e:	5e650513          	addi	a0,a0,1510 # ffffffffc0202000 <etext+0x83a>
ffffffffc0200a22:	f2aff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 测试连续分配和释放，连续分配 10 个单页，再全部释放，测试分配器在高频操作下的稳定性和正确性。
    cprintf("Testing continuous allocation and free...\n");
ffffffffc0200a26:	00001517          	auipc	a0,0x1
ffffffffc0200a2a:	60250513          	addi	a0,a0,1538 # ffffffffc0202028 <etext+0x862>
ffffffffc0200a2e:	0020                	addi	s0,sp,8
ffffffffc0200a30:	f1cff0ef          	jal	ra,ffffffffc020014c <cprintf>
    struct Page *pages_array[10];
    for (int i = 0; i < 10; i++) {
ffffffffc0200a34:	05810a13          	addi	s4,sp,88
    cprintf("Testing continuous allocation and free...\n");
ffffffffc0200a38:	89a2                	mv	s3,s0
        pages_array[i] = alloc_pages(1);
ffffffffc0200a3a:	4505                	li	a0,1
ffffffffc0200a3c:	706000ef          	jal	ra,ffffffffc0201142 <alloc_pages>
ffffffffc0200a40:	00a9b023          	sd	a0,0(s3)
        assert(pages_array[i] != NULL);
ffffffffc0200a44:	cd51                	beqz	a0,ffffffffc0200ae0 <buddy_check+0x4cc>
    for (int i = 0; i < 10; i++) {
ffffffffc0200a46:	09a1                	addi	s3,s3,8
ffffffffc0200a48:	ff3a19e3          	bne	s4,s3,ffffffffc0200a3a <buddy_check+0x426>
    }
    
    for (int i = 0; i < 10; i++) {
        free_pages(pages_array[i], 1);
ffffffffc0200a4c:	6008                	ld	a0,0(s0)
ffffffffc0200a4e:	4585                	li	a1,1
    for (int i = 0; i < 10; i++) {
ffffffffc0200a50:	0421                	addi	s0,s0,8
        free_pages(pages_array[i], 1);
ffffffffc0200a52:	6fc000ef          	jal	ra,ffffffffc020114e <free_pages>
    for (int i = 0; i < 10; i++) {
ffffffffc0200a56:	ff441be3          	bne	s0,s4,ffffffffc0200a4c <buddy_check+0x438>
    }
    cprintf("Continuous allocation and free test passed!\n");
ffffffffc0200a5a:	00001517          	auipc	a0,0x1
ffffffffc0200a5e:	61650513          	addi	a0,a0,1558 # ffffffffc0202070 <etext+0x8aa>
ffffffffc0200a62:	eeaff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 打印当前空闲块统计，打印当前各阶空闲块数量，方便观察分配器状态和内存碎片情况。
    cprintf("Current free block statistics:\n");
ffffffffc0200a66:	00001517          	auipc	a0,0x1
ffffffffc0200a6a:	63a50513          	addi	a0,a0,1594 # ffffffffc02020a0 <etext+0x8da>
ffffffffc0200a6e:	edeff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = 0; i <= MAX_ORDER; i++) {
        if (free_lists[i].nr_free > 0) {
            cprintf("Order %d (size %d): %d blocks\n", 
ffffffffc0200a72:	4a05                	li	s4,1
ffffffffc0200a74:	00001997          	auipc	s3,0x1
ffffffffc0200a78:	64c98993          	addi	s3,s3,1612 # ffffffffc02020c0 <etext+0x8fa>
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200a7c:	442d                	li	s0,11
ffffffffc0200a7e:	a029                	j	ffffffffc0200a88 <buddy_check+0x474>
ffffffffc0200a80:	2485                	addiw	s1,s1,1
ffffffffc0200a82:	0961                	addi	s2,s2,24
ffffffffc0200a84:	00848f63          	beq	s1,s0,ffffffffc0200aa2 <buddy_check+0x48e>
        if (free_lists[i].nr_free > 0) {
ffffffffc0200a88:	00092683          	lw	a3,0(s2)
ffffffffc0200a8c:	daf5                	beqz	a3,ffffffffc0200a80 <buddy_check+0x46c>
            cprintf("Order %d (size %d): %d blocks\n", 
ffffffffc0200a8e:	009a163b          	sllw	a2,s4,s1
ffffffffc0200a92:	85a6                	mv	a1,s1
ffffffffc0200a94:	854e                	mv	a0,s3
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200a96:	2485                	addiw	s1,s1,1
            cprintf("Order %d (size %d): %d blocks\n", 
ffffffffc0200a98:	eb4ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200a9c:	0961                	addi	s2,s2,24
ffffffffc0200a9e:	fe8495e3          	bne	s1,s0,ffffffffc0200a88 <buddy_check+0x474>
                   i, 1 << i, free_lists[i].nr_free);
        }
    }
    
    cprintf("=== Buddy System Check Completed Successfully ===\n");
}
ffffffffc0200aa2:	6456                	ld	s0,336(sp)
ffffffffc0200aa4:	60f6                	ld	ra,344(sp)
ffffffffc0200aa6:	64b6                	ld	s1,328(sp)
ffffffffc0200aa8:	6916                	ld	s2,320(sp)
ffffffffc0200aaa:	79f2                	ld	s3,312(sp)
ffffffffc0200aac:	7a52                	ld	s4,304(sp)
ffffffffc0200aae:	7ab2                	ld	s5,296(sp)
ffffffffc0200ab0:	7b12                	ld	s6,288(sp)
ffffffffc0200ab2:	6bf2                	ld	s7,280(sp)
ffffffffc0200ab4:	6c52                	ld	s8,272(sp)
    cprintf("=== Buddy System Check Completed Successfully ===\n");
ffffffffc0200ab6:	00001517          	auipc	a0,0x1
ffffffffc0200aba:	62a50513          	addi	a0,a0,1578 # ffffffffc02020e0 <etext+0x91a>
}
ffffffffc0200abe:	6135                	addi	sp,sp,352
    cprintf("=== Buddy System Check Completed Successfully ===\n");
ffffffffc0200ac0:	e8cff06f          	j	ffffffffc020014c <cprintf>
        cprintf("Max unit alloc failed (expected if insufficient memory)\n");
ffffffffc0200ac4:	00001517          	auipc	a0,0x1
ffffffffc0200ac8:	2ec50513          	addi	a0,a0,748 # ffffffffc0201db0 <etext+0x5ea>
ffffffffc0200acc:	e80ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200ad0:	bbed                	j	ffffffffc02008ca <buddy_check+0x2b6>
        cprintf("Large block allocation failed (expected if insufficient memory)\n");
ffffffffc0200ad2:	00001517          	auipc	a0,0x1
ffffffffc0200ad6:	4b650513          	addi	a0,a0,1206 # ffffffffc0201f88 <etext+0x7c2>
ffffffffc0200ada:	e72ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200ade:	b70d                	j	ffffffffc0200a00 <buddy_check+0x3ec>
        assert(pages_array[i] != NULL);
ffffffffc0200ae0:	00001697          	auipc	a3,0x1
ffffffffc0200ae4:	57868693          	addi	a3,a3,1400 # ffffffffc0202058 <etext+0x892>
ffffffffc0200ae8:	00001617          	auipc	a2,0x1
ffffffffc0200aec:	f8860613          	addi	a2,a2,-120 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200af0:	18000593          	li	a1,384
ffffffffc0200af4:	00001517          	auipc	a0,0x1
ffffffffc0200af8:	f9450513          	addi	a0,a0,-108 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200afc:	ec6ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p3 != NULL && p5 != NULL);
ffffffffc0200b00:	00001697          	auipc	a3,0x1
ffffffffc0200b04:	3a068693          	addi	a3,a3,928 # ffffffffc0201ea0 <etext+0x6da>
ffffffffc0200b08:	00001617          	auipc	a2,0x1
ffffffffc0200b0c:	f6860613          	addi	a2,a2,-152 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200b10:	15800593          	li	a1,344
ffffffffc0200b14:	00001517          	auipc	a0,0x1
ffffffffc0200b18:	f7450513          	addi	a0,a0,-140 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200b1c:	ea6ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p1 != NULL && p2 != NULL && p4 != NULL && p8 != NULL);
ffffffffc0200b20:	00001697          	auipc	a3,0x1
ffffffffc0200b24:	2f868693          	addi	a3,a3,760 # ffffffffc0201e18 <etext+0x652>
ffffffffc0200b28:	00001617          	auipc	a2,0x1
ffffffffc0200b2c:	f4860613          	addi	a2,a2,-184 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200b30:	15000593          	li	a1,336
ffffffffc0200b34:	00001517          	auipc	a0,0x1
ffffffffc0200b38:	f5450513          	addi	a0,a0,-172 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200b3c:	e86ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(complex1 != NULL && complex2 != NULL && complex3 != NULL);
ffffffffc0200b40:	00001697          	auipc	a3,0x1
ffffffffc0200b44:	16068693          	addi	a3,a3,352 # ffffffffc0201ca0 <etext+0x4da>
ffffffffc0200b48:	00001617          	auipc	a2,0x1
ffffffffc0200b4c:	f2860613          	addi	a2,a2,-216 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200b50:	13200593          	li	a1,306
ffffffffc0200b54:	00001517          	auipc	a0,0x1
ffffffffc0200b58:	f3450513          	addi	a0,a0,-204 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200b5c:	e66ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(simple1 != NULL && simple2 != NULL);
ffffffffc0200b60:	00001697          	auipc	a3,0x1
ffffffffc0200b64:	0d868693          	addi	a3,a3,216 # ffffffffc0201c38 <etext+0x472>
ffffffffc0200b68:	00001617          	auipc	a2,0x1
ffffffffc0200b6c:	f0860613          	addi	a2,a2,-248 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200b70:	12800593          	li	a1,296
ffffffffc0200b74:	00001517          	auipc	a0,0x1
ffffffffc0200b78:	f1450513          	addi	a0,a0,-236 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200b7c:	e46ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b80:	00001697          	auipc	a3,0x1
ffffffffc0200b84:	f8868693          	addi	a3,a3,-120 # ffffffffc0201b08 <etext+0x342>
ffffffffc0200b88:	00001617          	auipc	a2,0x1
ffffffffc0200b8c:	ee860613          	addi	a2,a2,-280 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200b90:	0f100593          	li	a1,241
ffffffffc0200b94:	00001517          	auipc	a0,0x1
ffffffffc0200b98:	ef450513          	addi	a0,a0,-268 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200b9c:	e26ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ba0:	00001697          	auipc	a3,0x1
ffffffffc0200ba4:	f4068693          	addi	a3,a3,-192 # ffffffffc0201ae0 <etext+0x31a>
ffffffffc0200ba8:	00001617          	auipc	a2,0x1
ffffffffc0200bac:	ec860613          	addi	a2,a2,-312 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200bb0:	0f000593          	li	a1,240
ffffffffc0200bb4:	00001517          	auipc	a0,0x1
ffffffffc0200bb8:	ed450513          	addi	a0,a0,-300 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200bbc:	e06ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bc0:	00001697          	auipc	a3,0x1
ffffffffc0200bc4:	e9068693          	addi	a3,a3,-368 # ffffffffc0201a50 <etext+0x28a>
ffffffffc0200bc8:	00001617          	auipc	a2,0x1
ffffffffc0200bcc:	ea860613          	addi	a2,a2,-344 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200bd0:	10600593          	li	a1,262
ffffffffc0200bd4:	00001517          	auipc	a0,0x1
ffffffffc0200bd8:	eb450513          	addi	a0,a0,-332 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200bdc:	de6ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() >= 3);
ffffffffc0200be0:	00001697          	auipc	a3,0x1
ffffffffc0200be4:	fe068693          	addi	a3,a3,-32 # ffffffffc0201bc0 <etext+0x3fa>
ffffffffc0200be8:	00001617          	auipc	a2,0x1
ffffffffc0200bec:	e8860613          	addi	a2,a2,-376 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200bf0:	10400593          	li	a1,260
ffffffffc0200bf4:	00001517          	auipc	a0,0x1
ffffffffc0200bf8:	e9450513          	addi	a0,a0,-364 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200bfc:	dc6ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200c00:	00001697          	auipc	a3,0x1
ffffffffc0200c04:	fa868693          	addi	a3,a3,-88 # ffffffffc0201ba8 <etext+0x3e2>
ffffffffc0200c08:	00001617          	auipc	a2,0x1
ffffffffc0200c0c:	e6860613          	addi	a2,a2,-408 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200c10:	0ff00593          	li	a1,255
ffffffffc0200c14:	00001517          	auipc	a0,0x1
ffffffffc0200c18:	e7450513          	addi	a0,a0,-396 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200c1c:	da6ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c20:	00001697          	auipc	a3,0x1
ffffffffc0200c24:	f6868693          	addi	a3,a3,-152 # ffffffffc0201b88 <etext+0x3c2>
ffffffffc0200c28:	00001617          	auipc	a2,0x1
ffffffffc0200c2c:	e4860613          	addi	a2,a2,-440 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200c30:	0f500593          	li	a1,245
ffffffffc0200c34:	00001517          	auipc	a0,0x1
ffffffffc0200c38:	e5450513          	addi	a0,a0,-428 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200c3c:	d86ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200c40:	00001697          	auipc	a3,0x1
ffffffffc0200c44:	f2868693          	addi	a3,a3,-216 # ffffffffc0201b68 <etext+0x3a2>
ffffffffc0200c48:	00001617          	auipc	a2,0x1
ffffffffc0200c4c:	e2860613          	addi	a2,a2,-472 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200c50:	0f400593          	li	a1,244
ffffffffc0200c54:	00001517          	auipc	a0,0x1
ffffffffc0200c58:	e3450513          	addi	a0,a0,-460 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200c5c:	d66ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c60:	00001697          	auipc	a3,0x1
ffffffffc0200c64:	ee868693          	addi	a3,a3,-280 # ffffffffc0201b48 <etext+0x382>
ffffffffc0200c68:	00001617          	auipc	a2,0x1
ffffffffc0200c6c:	e0860613          	addi	a2,a2,-504 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200c70:	0f300593          	li	a1,243
ffffffffc0200c74:	00001517          	auipc	a0,0x1
ffffffffc0200c78:	e1450513          	addi	a0,a0,-492 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200c7c:	d46ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200c80:	00001697          	auipc	a3,0x1
ffffffffc0200c84:	f6068693          	addi	a3,a3,-160 # ffffffffc0201be0 <etext+0x41a>
ffffffffc0200c88:	00001617          	auipc	a2,0x1
ffffffffc0200c8c:	de860613          	addi	a2,a2,-536 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200c90:	10f00593          	li	a1,271
ffffffffc0200c94:	00001517          	auipc	a0,0x1
ffffffffc0200c98:	df450513          	addi	a0,a0,-524 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200c9c:	d26ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ca0:	00001697          	auipc	a3,0x1
ffffffffc0200ca4:	f0868693          	addi	a3,a3,-248 # ffffffffc0201ba8 <etext+0x3e2>
ffffffffc0200ca8:	00001617          	auipc	a2,0x1
ffffffffc0200cac:	dc860613          	addi	a2,a2,-568 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200cb0:	10a00593          	li	a1,266
ffffffffc0200cb4:	00001517          	auipc	a0,0x1
ffffffffc0200cb8:	dd450513          	addi	a0,a0,-556 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200cbc:	d06ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(huge == NULL);  // 应该失败
ffffffffc0200cc0:	00001697          	auipc	a3,0x1
ffffffffc0200cc4:	33068693          	addi	a3,a3,816 # ffffffffc0201ff0 <etext+0x82a>
ffffffffc0200cc8:	00001617          	auipc	a2,0x1
ffffffffc0200ccc:	da860613          	addi	a2,a2,-600 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200cd0:	17800593          	li	a1,376
ffffffffc0200cd4:	00001517          	auipc	a0,0x1
ffffffffc0200cd8:	db450513          	addi	a0,a0,-588 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200cdc:	ce6ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ce0:	00001697          	auipc	a3,0x1
ffffffffc0200ce4:	d7068693          	addi	a3,a3,-656 # ffffffffc0201a50 <etext+0x28a>
ffffffffc0200ce8:	00001617          	auipc	a2,0x1
ffffffffc0200cec:	d8860613          	addi	a2,a2,-632 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200cf0:	0ec00593          	li	a1,236
ffffffffc0200cf4:	00001517          	auipc	a0,0x1
ffffffffc0200cf8:	d9450513          	addi	a0,a0,-620 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200cfc:	cc6ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(min_unit != NULL);
ffffffffc0200d00:	00001697          	auipc	a3,0x1
ffffffffc0200d04:	02868693          	addi	a3,a3,40 # ffffffffc0201d28 <etext+0x562>
ffffffffc0200d08:	00001617          	auipc	a2,0x1
ffffffffc0200d0c:	d6860613          	addi	a2,a2,-664 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200d10:	13b00593          	li	a1,315
ffffffffc0200d14:	00001517          	auipc	a0,0x1
ffffffffc0200d18:	d7450513          	addi	a0,a0,-652 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200d1c:	ca6ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d20:	00001697          	auipc	a3,0x1
ffffffffc0200d24:	e8868693          	addi	a3,a3,-376 # ffffffffc0201ba8 <etext+0x3e2>
ffffffffc0200d28:	00001617          	auipc	a2,0x1
ffffffffc0200d2c:	d4860613          	addi	a2,a2,-696 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200d30:	11000593          	li	a1,272
ffffffffc0200d34:	00001517          	auipc	a0,0x1
ffffffffc0200d38:	d5450513          	addi	a0,a0,-684 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200d3c:	c86ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d40:	00001697          	auipc	a3,0x1
ffffffffc0200d44:	d8068693          	addi	a3,a3,-640 # ffffffffc0201ac0 <etext+0x2fa>
ffffffffc0200d48:	00001617          	auipc	a2,0x1
ffffffffc0200d4c:	d2860613          	addi	a2,a2,-728 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200d50:	10800593          	li	a1,264
ffffffffc0200d54:	00001517          	auipc	a0,0x1
ffffffffc0200d58:	d3450513          	addi	a0,a0,-716 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200d5c:	c66ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d60:	00001697          	auipc	a3,0x1
ffffffffc0200d64:	d4068693          	addi	a3,a3,-704 # ffffffffc0201aa0 <etext+0x2da>
ffffffffc0200d68:	00001617          	auipc	a2,0x1
ffffffffc0200d6c:	d0860613          	addi	a2,a2,-760 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200d70:	10700593          	li	a1,263
ffffffffc0200d74:	00001517          	auipc	a0,0x1
ffffffffc0200d78:	d1450513          	addi	a0,a0,-748 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200d7c:	c46ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d80:	00001697          	auipc	a3,0x1
ffffffffc0200d84:	d4068693          	addi	a3,a3,-704 # ffffffffc0201ac0 <etext+0x2fa>
ffffffffc0200d88:	00001617          	auipc	a2,0x1
ffffffffc0200d8c:	ce860613          	addi	a2,a2,-792 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200d90:	0ee00593          	li	a1,238
ffffffffc0200d94:	00001517          	auipc	a0,0x1
ffffffffc0200d98:	cf450513          	addi	a0,a0,-780 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200d9c:	c26ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200da0:	00001697          	auipc	a3,0x1
ffffffffc0200da4:	d0068693          	addi	a3,a3,-768 # ffffffffc0201aa0 <etext+0x2da>
ffffffffc0200da8:	00001617          	auipc	a2,0x1
ffffffffc0200dac:	cc860613          	addi	a2,a2,-824 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200db0:	0ed00593          	li	a1,237
ffffffffc0200db4:	00001517          	auipc	a0,0x1
ffffffffc0200db8:	cd450513          	addi	a0,a0,-812 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200dbc:	c06ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200dc0 <buddy_free_pages>:
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0200dc0:	1141                	addi	sp,sp,-16
ffffffffc0200dc2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200dc4:	14058763          	beqz	a1,ffffffffc0200f12 <buddy_free_pages+0x152>
    while (size < n) {
ffffffffc0200dc8:	4705                	li	a4,1
    int order = 0;
ffffffffc0200dca:	4681                	li	a3,0
    size_t size = 1;
ffffffffc0200dcc:	4785                	li	a5,1
    while (size < n) {
ffffffffc0200dce:	10e58e63          	beq	a1,a4,ffffffffc0200eea <buddy_free_pages+0x12a>
        size <<= 1;
ffffffffc0200dd2:	0786                	slli	a5,a5,0x1
        order++;
ffffffffc0200dd4:	2685                	addiw	a3,a3,1
    while (size < n) {
ffffffffc0200dd6:	feb7eee3          	bltu	a5,a1,ffffffffc0200dd2 <buddy_free_pages+0x12>
    for (; p != base + (1 << order); p++) {
ffffffffc0200dda:	4585                	li	a1,1
ffffffffc0200ddc:	00d595bb          	sllw	a1,a1,a3
ffffffffc0200de0:	00259613          	slli	a2,a1,0x2
ffffffffc0200de4:	962e                	add	a2,a2,a1
ffffffffc0200de6:	060e                	slli	a2,a2,0x3
ffffffffc0200de8:	962a                	add	a2,a2,a0
ffffffffc0200dea:	00c50e63          	beq	a0,a2,ffffffffc0200e06 <buddy_free_pages+0x46>
    int order = 0;
ffffffffc0200dee:	87aa                	mv	a5,a0
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200df0:	6798                	ld	a4,8(a5)
ffffffffc0200df2:	8b0d                	andi	a4,a4,3
ffffffffc0200df4:	ef7d                	bnez	a4,ffffffffc0200ef2 <buddy_free_pages+0x132>
        p->flags = 0;
ffffffffc0200df6:	0007b423          	sd	zero,8(a5)

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200dfa:	0007a023          	sw	zero,0(a5)
    for (; p != base + (1 << order); p++) {
ffffffffc0200dfe:	02878793          	addi	a5,a5,40
ffffffffc0200e02:	fec797e3          	bne	a5,a2,ffffffffc0200df0 <buddy_free_pages+0x30>
    SetPageProperty(base);
ffffffffc0200e06:	651c                	ld	a5,8(a0)
    base->property = 1 << order;
ffffffffc0200e08:	c90c                	sw	a1,16(a0)
    while (current_order < MAX_ORDER) {
ffffffffc0200e0a:	4725                	li	a4,9
    SetPageProperty(base);
ffffffffc0200e0c:	0027e793          	ori	a5,a5,2
ffffffffc0200e10:	e51c                	sd	a5,8(a0)
    while (current_order < MAX_ORDER) {
ffffffffc0200e12:	00005f17          	auipc	t5,0x5
ffffffffc0200e16:	206f0f13          	addi	t5,t5,518 # ffffffffc0206018 <free_lists>
ffffffffc0200e1a:	0ad74163          	blt	a4,a3,ffffffffc0200ebc <buddy_free_pages+0xfc>
        if (buddy < pages || buddy >= pages + npage || 
ffffffffc0200e1e:	00005797          	auipc	a5,0x5
ffffffffc0200e22:	31a7b783          	ld	a5,794(a5) # ffffffffc0206138 <npage>
ffffffffc0200e26:	00279e93          	slli	t4,a5,0x2
ffffffffc0200e2a:	00169613          	slli	a2,a3,0x1
ffffffffc0200e2e:	9ebe                	add	t4,t4,a5
ffffffffc0200e30:	9636                	add	a2,a2,a3
    uintptr_t page_idx = page - pages;
ffffffffc0200e32:	00005817          	auipc	a6,0x5
ffffffffc0200e36:	30e83803          	ld	a6,782(a6) # ffffffffc0206140 <pages>
        if (buddy < pages || buddy >= pages + npage || 
ffffffffc0200e3a:	0e8e                	slli	t4,t4,0x3
ffffffffc0200e3c:	00005f17          	auipc	t5,0x5
ffffffffc0200e40:	1dcf0f13          	addi	t5,t5,476 # ffffffffc0206018 <free_lists>
ffffffffc0200e44:	060e                	slli	a2,a2,0x3
ffffffffc0200e46:	9ec2                	add	t4,t4,a6
ffffffffc0200e48:	967a                	add	a2,a2,t5
ffffffffc0200e4a:	00001f97          	auipc	t6,0x1
ffffffffc0200e4e:	6eefbf83          	ld	t6,1774(t6) # ffffffffc0202538 <error_string+0x38>
    uintptr_t buddy_idx = page_idx ^ (1 << order);
ffffffffc0200e52:	4e05                	li	t3,1
    while (current_order < MAX_ORDER) {
ffffffffc0200e54:	42a9                	li	t0,10
ffffffffc0200e56:	a099                	j	ffffffffc0200e9c <buddy_free_pages+0xdc>
        if (buddy < pages || buddy >= pages + npage || 
ffffffffc0200e58:	07d7f263          	bgeu	a5,t4,ffffffffc0200ebc <buddy_free_pages+0xfc>
            !PageProperty(buddy) || buddy->property != (1 << current_order)) {
ffffffffc0200e5c:	6798                	ld	a4,8(a5)
ffffffffc0200e5e:	00277893          	andi	a7,a4,2
        if (buddy < pages || buddy >= pages + npage || 
ffffffffc0200e62:	04088d63          	beqz	a7,ffffffffc0200ebc <buddy_free_pages+0xfc>
            !PageProperty(buddy) || buddy->property != (1 << current_order)) {
ffffffffc0200e66:	0107a883          	lw	a7,16(a5)
ffffffffc0200e6a:	04b89963          	bne	a7,a1,ffffffffc0200ebc <buddy_free_pages+0xfc>
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
ffffffffc0200e6e:	0187b303          	ld	t1,24(a5)
ffffffffc0200e72:	0207b883          	ld	a7,32(a5)
        free_lists[current_order].nr_free--;
ffffffffc0200e76:	4a0c                	lw	a1,16(a2)
        ClearPageProperty(buddy);
ffffffffc0200e78:	9b75                	andi	a4,a4,-3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200e7a:	01133423          	sd	a7,8(t1)
    next->prev = prev;
ffffffffc0200e7e:	0068b023          	sd	t1,0(a7)
        free_lists[current_order].nr_free--;
ffffffffc0200e82:	35fd                	addiw	a1,a1,-1
ffffffffc0200e84:	ca0c                	sw	a1,16(a2)
        ClearPageProperty(buddy);
ffffffffc0200e86:	e798                	sd	a4,8(a5)
        if (buddy < current_block) {
ffffffffc0200e88:	00a7f363          	bgeu	a5,a0,ffffffffc0200e8e <buddy_free_pages+0xce>
ffffffffc0200e8c:	853e                	mv	a0,a5
        current_order++;
ffffffffc0200e8e:	2685                	addiw	a3,a3,1
        current_block->property = 1 << current_order;
ffffffffc0200e90:	00de17bb          	sllw	a5,t3,a3
ffffffffc0200e94:	c91c                	sw	a5,16(a0)
    while (current_order < MAX_ORDER) {
ffffffffc0200e96:	0661                	addi	a2,a2,24
ffffffffc0200e98:	02568263          	beq	a3,t0,ffffffffc0200ebc <buddy_free_pages+0xfc>
    uintptr_t page_idx = page - pages;
ffffffffc0200e9c:	410507b3          	sub	a5,a0,a6
ffffffffc0200ea0:	878d                	srai	a5,a5,0x3
ffffffffc0200ea2:	03f787b3          	mul	a5,a5,t6
    uintptr_t buddy_idx = page_idx ^ (1 << order);
ffffffffc0200ea6:	00de15bb          	sllw	a1,t3,a3
ffffffffc0200eaa:	00b7c733          	xor	a4,a5,a1
    return pages + buddy_idx;
ffffffffc0200eae:	00271793          	slli	a5,a4,0x2
ffffffffc0200eb2:	97ba                	add	a5,a5,a4
ffffffffc0200eb4:	078e                	slli	a5,a5,0x3
ffffffffc0200eb6:	97c2                	add	a5,a5,a6
        if (buddy < pages || buddy >= pages + npage || 
ffffffffc0200eb8:	fb07f0e3          	bgeu	a5,a6,ffffffffc0200e58 <buddy_free_pages+0x98>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200ebc:	00169793          	slli	a5,a3,0x1
ffffffffc0200ec0:	96be                	add	a3,a3,a5
ffffffffc0200ec2:	068e                	slli	a3,a3,0x3
ffffffffc0200ec4:	9f36                	add	t5,t5,a3
ffffffffc0200ec6:	008f3703          	ld	a4,8(t5)
    free_lists[current_order].nr_free++;
ffffffffc0200eca:	010f2783          	lw	a5,16(t5)
    list_add(&(free_lists[current_order].free_list), &(current_block->page_link));
ffffffffc0200ece:	01850693          	addi	a3,a0,24
    prev->next = next->prev = elm;
ffffffffc0200ed2:	e314                	sd	a3,0(a4)
ffffffffc0200ed4:	00df3423          	sd	a3,8(t5)
}
ffffffffc0200ed8:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200eda:	f118                	sd	a4,32(a0)
    elm->prev = prev;
ffffffffc0200edc:	01e53c23          	sd	t5,24(a0)
    free_lists[current_order].nr_free++;
ffffffffc0200ee0:	2785                	addiw	a5,a5,1
ffffffffc0200ee2:	00ff2823          	sw	a5,16(t5)
}
ffffffffc0200ee6:	0141                	addi	sp,sp,16
ffffffffc0200ee8:	8082                	ret
    for (; p != base + (1 << order); p++) {
ffffffffc0200eea:	02850613          	addi	a2,a0,40
ffffffffc0200eee:	4585                	li	a1,1
ffffffffc0200ef0:	bdfd                	j	ffffffffc0200dee <buddy_free_pages+0x2e>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200ef2:	00001697          	auipc	a3,0x1
ffffffffc0200ef6:	22e68693          	addi	a3,a3,558 # ffffffffc0202120 <etext+0x95a>
ffffffffc0200efa:	00001617          	auipc	a2,0x1
ffffffffc0200efe:	b7660613          	addi	a2,a2,-1162 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200f02:	0b300593          	li	a1,179
ffffffffc0200f06:	00001517          	auipc	a0,0x1
ffffffffc0200f0a:	b8250513          	addi	a0,a0,-1150 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200f0e:	ab4ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc0200f12:	00001697          	auipc	a3,0x1
ffffffffc0200f16:	20668693          	addi	a3,a3,518 # ffffffffc0202118 <etext+0x952>
ffffffffc0200f1a:	00001617          	auipc	a2,0x1
ffffffffc0200f1e:	b5660613          	addi	a2,a2,-1194 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0200f22:	0ac00593          	li	a1,172
ffffffffc0200f26:	00001517          	auipc	a0,0x1
ffffffffc0200f2a:	b6250513          	addi	a0,a0,-1182 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc0200f2e:	a94ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200f32 <buddy_alloc_pages>:
    assert(n > 0);
ffffffffc0200f32:	cd71                	beqz	a0,ffffffffc020100e <buddy_alloc_pages+0xdc>
    if (n > (1 << MAX_ORDER)) {
ffffffffc0200f34:	40000793          	li	a5,1024
ffffffffc0200f38:	0ca7e963          	bltu	a5,a0,ffffffffc020100a <buddy_alloc_pages+0xd8>
    while (size < n) {
ffffffffc0200f3c:	4785                	li	a5,1
    int order = 0;
ffffffffc0200f3e:	4601                	li	a2,0
    while (size < n) {
ffffffffc0200f40:	00f50963          	beq	a0,a5,ffffffffc0200f52 <buddy_alloc_pages+0x20>
        size <<= 1;
ffffffffc0200f44:	0786                	slli	a5,a5,0x1
        order++;
ffffffffc0200f46:	2605                	addiw	a2,a2,1
    while (size < n) {
ffffffffc0200f48:	fea7eee3          	bltu	a5,a0,ffffffffc0200f44 <buddy_alloc_pages+0x12>
    while (current_order <= MAX_ORDER) {
ffffffffc0200f4c:	47a9                	li	a5,10
ffffffffc0200f4e:	0ac7ce63          	blt	a5,a2,ffffffffc020100a <buddy_alloc_pages+0xd8>
ffffffffc0200f52:	00161793          	slli	a5,a2,0x1
ffffffffc0200f56:	97b2                	add	a5,a5,a2
ffffffffc0200f58:	00005697          	auipc	a3,0x5
ffffffffc0200f5c:	0c068693          	addi	a3,a3,192 # ffffffffc0206018 <free_lists>
ffffffffc0200f60:	078e                	slli	a5,a5,0x3
ffffffffc0200f62:	97b6                	add	a5,a5,a3
    int order = 0;
ffffffffc0200f64:	8732                	mv	a4,a2
    while (current_order <= MAX_ORDER) {
ffffffffc0200f66:	452d                	li	a0,11
ffffffffc0200f68:	a029                	j	ffffffffc0200f72 <buddy_alloc_pages+0x40>
        current_order++;
ffffffffc0200f6a:	2705                	addiw	a4,a4,1
    while (current_order <= MAX_ORDER) {
ffffffffc0200f6c:	07e1                	addi	a5,a5,24
ffffffffc0200f6e:	08a70e63          	beq	a4,a0,ffffffffc020100a <buddy_alloc_pages+0xd8>
    return list->next == list;
ffffffffc0200f72:	678c                	ld	a1,8(a5)
        if (!list_empty(&(free_lists[current_order].free_list))) {
ffffffffc0200f74:	fef58be3          	beq	a1,a5,ffffffffc0200f6a <buddy_alloc_pages+0x38>
            free_lists[current_order].nr_free--;
ffffffffc0200f78:	00171793          	slli	a5,a4,0x1
ffffffffc0200f7c:	97ba                	add	a5,a5,a4
ffffffffc0200f7e:	078e                	slli	a5,a5,0x3
    __list_del(listelm->prev, listelm->next);
ffffffffc0200f80:	0005be03          	ld	t3,0(a1)
ffffffffc0200f84:	0085b303          	ld	t1,8(a1)
ffffffffc0200f88:	00f688b3          	add	a7,a3,a5
ffffffffc0200f8c:	0108a803          	lw	a6,16(a7)
            ClearPageProperty(page);
ffffffffc0200f90:	ff05b503          	ld	a0,-16(a1)
    prev->next = next;
ffffffffc0200f94:	006e3423          	sd	t1,8(t3)
    next->prev = prev;
ffffffffc0200f98:	01c33023          	sd	t3,0(t1)
            free_lists[current_order].nr_free--;
ffffffffc0200f9c:	387d                	addiw	a6,a6,-1
            ClearPageProperty(page);
ffffffffc0200f9e:	9975                	andi	a0,a0,-3
            free_lists[current_order].nr_free--;
ffffffffc0200fa0:	0108a823          	sw	a6,16(a7)
            ClearPageProperty(page);
ffffffffc0200fa4:	fea5b823          	sd	a0,-16(a1)
            struct Page *page = le2page(le, page_link);
ffffffffc0200fa8:	fe858513          	addi	a0,a1,-24
            while (current_order > order) {
ffffffffc0200fac:	04e65963          	bge	a2,a4,ffffffffc0200ffe <buddy_alloc_pages+0xcc>
ffffffffc0200fb0:	17a1                	addi	a5,a5,-24
ffffffffc0200fb2:	96be                	add	a3,a3,a5
                struct Page *buddy = page + (1 << current_order);
ffffffffc0200fb4:	4e05                	li	t3,1
                current_order--;
ffffffffc0200fb6:	377d                	addiw	a4,a4,-1
                struct Page *buddy = page + (1 << current_order);
ffffffffc0200fb8:	00ee18bb          	sllw	a7,t3,a4
ffffffffc0200fbc:	00289793          	slli	a5,a7,0x2
ffffffffc0200fc0:	97c6                	add	a5,a5,a7
ffffffffc0200fc2:	078e                	slli	a5,a5,0x3
ffffffffc0200fc4:	97aa                	add	a5,a5,a0
ffffffffc0200fc6:	8846                	mv	a6,a7
                SetPageProperty(buddy);
ffffffffc0200fc8:	0087b883          	ld	a7,8(a5)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200fcc:	0086b303          	ld	t1,8(a3)
                buddy->property = 1 << current_order;
ffffffffc0200fd0:	0107a823          	sw	a6,16(a5)
                SetPageProperty(buddy);
ffffffffc0200fd4:	0028e893          	ori	a7,a7,2
                free_lists[current_order].nr_free++;
ffffffffc0200fd8:	0106a803          	lw	a6,16(a3)
                SetPageProperty(buddy);
ffffffffc0200fdc:	0117b423          	sd	a7,8(a5)
                list_add(&(free_lists[current_order].free_list), &(buddy->page_link));
ffffffffc0200fe0:	01878893          	addi	a7,a5,24
    prev->next = next->prev = elm;
ffffffffc0200fe4:	01133023          	sd	a7,0(t1)
ffffffffc0200fe8:	0116b423          	sd	a7,8(a3)
    elm->prev = prev;
ffffffffc0200fec:	ef94                	sd	a3,24(a5)
    elm->next = next;
ffffffffc0200fee:	0267b023          	sd	t1,32(a5)
                free_lists[current_order].nr_free++;
ffffffffc0200ff2:	0018079b          	addiw	a5,a6,1
ffffffffc0200ff6:	ca9c                	sw	a5,16(a3)
            while (current_order > order) {
ffffffffc0200ff8:	16a1                	addi	a3,a3,-24
ffffffffc0200ffa:	fae61ee3          	bne	a2,a4,ffffffffc0200fb6 <buddy_alloc_pages+0x84>
            page->property = 1 << order;
ffffffffc0200ffe:	4785                	li	a5,1
ffffffffc0201000:	00c7963b          	sllw	a2,a5,a2
ffffffffc0201004:	fec5ac23          	sw	a2,-8(a1)
            return page;
ffffffffc0201008:	8082                	ret
        return NULL;
ffffffffc020100a:	4501                	li	a0,0
}
ffffffffc020100c:	8082                	ret
buddy_alloc_pages(size_t n) {
ffffffffc020100e:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201010:	00001697          	auipc	a3,0x1
ffffffffc0201014:	10868693          	addi	a3,a3,264 # ffffffffc0202118 <etext+0x952>
ffffffffc0201018:	00001617          	auipc	a2,0x1
ffffffffc020101c:	a5860613          	addi	a2,a2,-1448 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0201020:	07c00593          	li	a1,124
ffffffffc0201024:	00001517          	auipc	a0,0x1
ffffffffc0201028:	a6450513          	addi	a0,a0,-1436 # ffffffffc0201a88 <etext+0x2c2>
buddy_alloc_pages(size_t n) {
ffffffffc020102c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020102e:	994ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0201032 <buddy_init_memmap>:
buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0201032:	1141                	addi	sp,sp,-16
ffffffffc0201034:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201036:	c5f5                	beqz	a1,ffffffffc0201122 <buddy_init_memmap+0xf0>
    for (; p != base + n; p++) {
ffffffffc0201038:	00259693          	slli	a3,a1,0x2
ffffffffc020103c:	96ae                	add	a3,a3,a1
ffffffffc020103e:	068e                	slli	a3,a3,0x3
ffffffffc0201040:	96aa                	add	a3,a3,a0
ffffffffc0201042:	87aa                	mv	a5,a0
ffffffffc0201044:	00d50f63          	beq	a0,a3,ffffffffc0201062 <buddy_init_memmap+0x30>
        assert(PageReserved(p));
ffffffffc0201048:	6798                	ld	a4,8(a5)
ffffffffc020104a:	8b05                	andi	a4,a4,1
ffffffffc020104c:	cb5d                	beqz	a4,ffffffffc0201102 <buddy_init_memmap+0xd0>
        p->flags = 0;
ffffffffc020104e:	0007b423          	sd	zero,8(a5)
        p->property = 0;
ffffffffc0201052:	0007a823          	sw	zero,16(a5)
ffffffffc0201056:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++) {
ffffffffc020105a:	02878793          	addi	a5,a5,40
ffffffffc020105e:	fed795e3          	bne	a5,a3,ffffffffc0201048 <buddy_init_memmap+0x16>
ffffffffc0201062:	00005e17          	auipc	t3,0x5
ffffffffc0201066:	fb6e0e13          	addi	t3,t3,-74 # ffffffffc0206018 <free_lists>
        while (block_size * 2 <= current_size && order < MAX_ORDER) {
ffffffffc020106a:	4e85                	li	t4,1
ffffffffc020106c:	4829                	li	a6,10
        current_base += block_size;
ffffffffc020106e:	00005f17          	auipc	t5,0x5
ffffffffc0201072:	09af0f13          	addi	t5,t5,154 # ffffffffc0206108 <free_lists+0xf0>
        int order = 0;
ffffffffc0201076:	4781                	li	a5,0
ffffffffc0201078:	4709                	li	a4,2
        while (block_size * 2 <= current_size && order < MAX_ORDER) {
ffffffffc020107a:	07d58d63          	beq	a1,t4,ffffffffc02010f4 <buddy_init_memmap+0xc2>
            block_size <<= 1;
ffffffffc020107e:	86ba                	mv	a3,a4
        while (block_size * 2 <= current_size && order < MAX_ORDER) {
ffffffffc0201080:	0706                	slli	a4,a4,0x1
            order++;
ffffffffc0201082:	2785                	addiw	a5,a5,1
        while (block_size * 2 <= current_size && order < MAX_ORDER) {
ffffffffc0201084:	04e5eb63          	bltu	a1,a4,ffffffffc02010da <buddy_init_memmap+0xa8>
ffffffffc0201088:	ff079be3          	bne	a5,a6,ffffffffc020107e <buddy_init_memmap+0x4c>
        current_base += block_size;
ffffffffc020108c:	00269613          	slli	a2,a3,0x2
ffffffffc0201090:	9636                	add	a2,a2,a3
        current_base->property = block_size;
ffffffffc0201092:	00068f9b          	sext.w	t6,a3
        current_base += block_size;
ffffffffc0201096:	060e                	slli	a2,a2,0x3
ffffffffc0201098:	88fa                	mv	a7,t5
ffffffffc020109a:	00179713          	slli	a4,a5,0x1
    __list_add(elm, listelm, listelm->next);
ffffffffc020109e:	97ba                	add	a5,a5,a4
ffffffffc02010a0:	078e                	slli	a5,a5,0x3
        SetPageProperty(current_base);
ffffffffc02010a2:	6518                	ld	a4,8(a0)
ffffffffc02010a4:	97f2                	add	a5,a5,t3
ffffffffc02010a6:	0087b303          	ld	t1,8(a5)
ffffffffc02010aa:	00276713          	ori	a4,a4,2
        current_base->property = block_size;
ffffffffc02010ae:	01f52823          	sw	t6,16(a0)
        SetPageProperty(current_base);
ffffffffc02010b2:	e518                	sd	a4,8(a0)
        list_add(&(free_lists[order].free_list), &(current_base->page_link));
ffffffffc02010b4:	01850f93          	addi	t6,a0,24
        free_lists[order].nr_free++;
ffffffffc02010b8:	4b98                	lw	a4,16(a5)
    prev->next = next->prev = elm;
ffffffffc02010ba:	01f33023          	sd	t6,0(t1)
ffffffffc02010be:	01f7b423          	sd	t6,8(a5)
    elm->next = next;
ffffffffc02010c2:	02653023          	sd	t1,32(a0)
    elm->prev = prev;
ffffffffc02010c6:	01153c23          	sd	a7,24(a0)
ffffffffc02010ca:	2705                	addiw	a4,a4,1
ffffffffc02010cc:	cb98                	sw	a4,16(a5)
        current_size -= block_size;
ffffffffc02010ce:	8d95                	sub	a1,a1,a3
        current_base += block_size;
ffffffffc02010d0:	9532                	add	a0,a0,a2
    while (current_size > 0) {
ffffffffc02010d2:	f1d5                	bnez	a1,ffffffffc0201076 <buddy_init_memmap+0x44>
}
ffffffffc02010d4:	60a2                	ld	ra,8(sp)
ffffffffc02010d6:	0141                	addi	sp,sp,16
ffffffffc02010d8:	8082                	ret
        list_add(&(free_lists[order].free_list), &(current_base->page_link));
ffffffffc02010da:	00179713          	slli	a4,a5,0x1
ffffffffc02010de:	00f708b3          	add	a7,a4,a5
        current_base += block_size;
ffffffffc02010e2:	00269613          	slli	a2,a3,0x2
        list_add(&(free_lists[order].free_list), &(current_base->page_link));
ffffffffc02010e6:	088e                	slli	a7,a7,0x3
        current_base += block_size;
ffffffffc02010e8:	9636                	add	a2,a2,a3
        current_base->property = block_size;
ffffffffc02010ea:	00068f9b          	sext.w	t6,a3
        list_add(&(free_lists[order].free_list), &(current_base->page_link));
ffffffffc02010ee:	98f2                	add	a7,a7,t3
        current_base += block_size;
ffffffffc02010f0:	060e                	slli	a2,a2,0x3
ffffffffc02010f2:	b775                	j	ffffffffc020109e <buddy_init_memmap+0x6c>
        size_t block_size = 1;
ffffffffc02010f4:	4685                	li	a3,1
        while (block_size * 2 <= current_size && order < MAX_ORDER) {
ffffffffc02010f6:	02800613          	li	a2,40
ffffffffc02010fa:	88f2                	mv	a7,t3
ffffffffc02010fc:	4f85                	li	t6,1
ffffffffc02010fe:	4701                	li	a4,0
ffffffffc0201100:	bf79                	j	ffffffffc020109e <buddy_init_memmap+0x6c>
        assert(PageReserved(p));
ffffffffc0201102:	00001697          	auipc	a3,0x1
ffffffffc0201106:	04668693          	addi	a3,a3,70 # ffffffffc0202148 <etext+0x982>
ffffffffc020110a:	00001617          	auipc	a2,0x1
ffffffffc020110e:	96660613          	addi	a2,a2,-1690 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0201112:	05900593          	li	a1,89
ffffffffc0201116:	00001517          	auipc	a0,0x1
ffffffffc020111a:	97250513          	addi	a0,a0,-1678 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc020111e:	8a4ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc0201122:	00001697          	auipc	a3,0x1
ffffffffc0201126:	ff668693          	addi	a3,a3,-10 # ffffffffc0202118 <etext+0x952>
ffffffffc020112a:	00001617          	auipc	a2,0x1
ffffffffc020112e:	94660613          	addi	a2,a2,-1722 # ffffffffc0201a70 <etext+0x2aa>
ffffffffc0201132:	05400593          	li	a1,84
ffffffffc0201136:	00001517          	auipc	a0,0x1
ffffffffc020113a:	95250513          	addi	a0,a0,-1710 # ffffffffc0201a88 <etext+0x2c2>
ffffffffc020113e:	884ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0201142 <alloc_pages>:
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
    return pmm_manager->alloc_pages(n);
ffffffffc0201142:	00005797          	auipc	a5,0x5
ffffffffc0201146:	0067b783          	ld	a5,6(a5) # ffffffffc0206148 <pmm_manager>
ffffffffc020114a:	6f9c                	ld	a5,24(a5)
ffffffffc020114c:	8782                	jr	a5

ffffffffc020114e <free_pages>:
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    pmm_manager->free_pages(base, n);
ffffffffc020114e:	00005797          	auipc	a5,0x5
ffffffffc0201152:	ffa7b783          	ld	a5,-6(a5) # ffffffffc0206148 <pmm_manager>
ffffffffc0201156:	739c                	ld	a5,32(a5)
ffffffffc0201158:	8782                	jr	a5

ffffffffc020115a <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc020115a:	00001797          	auipc	a5,0x1
ffffffffc020115e:	01678793          	addi	a5,a5,22 # ffffffffc0202170 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201162:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201164:	7179                	addi	sp,sp,-48
ffffffffc0201166:	f022                	sd	s0,32(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201168:	00001517          	auipc	a0,0x1
ffffffffc020116c:	04050513          	addi	a0,a0,64 # ffffffffc02021a8 <buddy_pmm_manager+0x38>
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201170:	00005417          	auipc	s0,0x5
ffffffffc0201174:	fd840413          	addi	s0,s0,-40 # ffffffffc0206148 <pmm_manager>
void pmm_init(void) {
ffffffffc0201178:	f406                	sd	ra,40(sp)
ffffffffc020117a:	ec26                	sd	s1,24(sp)
ffffffffc020117c:	e44e                	sd	s3,8(sp)
ffffffffc020117e:	e84a                	sd	s2,16(sp)
ffffffffc0201180:	e052                	sd	s4,0(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201182:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201184:	fc9fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    pmm_manager->init();
ffffffffc0201188:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020118a:	00005497          	auipc	s1,0x5
ffffffffc020118e:	fd648493          	addi	s1,s1,-42 # ffffffffc0206160 <va_pa_offset>
    pmm_manager->init();
ffffffffc0201192:	679c                	ld	a5,8(a5)
ffffffffc0201194:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201196:	57f5                	li	a5,-3
ffffffffc0201198:	07fa                	slli	a5,a5,0x1e
ffffffffc020119a:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();
ffffffffc020119c:	c20ff0ef          	jal	ra,ffffffffc02005bc <get_memory_base>
ffffffffc02011a0:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc02011a2:	c24ff0ef          	jal	ra,ffffffffc02005c6 <get_memory_size>
    if (mem_size == 0) {
ffffffffc02011a6:	14050d63          	beqz	a0,ffffffffc0201300 <pmm_init+0x1a6>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc02011aa:	892a                	mv	s2,a0
    cprintf("physcial memory map:\n");
ffffffffc02011ac:	00001517          	auipc	a0,0x1
ffffffffc02011b0:	04450513          	addi	a0,a0,68 # ffffffffc02021f0 <buddy_pmm_manager+0x80>
ffffffffc02011b4:	f99fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc02011b8:	01298a33          	add	s4,s3,s2
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02011bc:	864e                	mv	a2,s3
ffffffffc02011be:	fffa0693          	addi	a3,s4,-1
ffffffffc02011c2:	85ca                	mv	a1,s2
ffffffffc02011c4:	00001517          	auipc	a0,0x1
ffffffffc02011c8:	04450513          	addi	a0,a0,68 # ffffffffc0202208 <buddy_pmm_manager+0x98>
ffffffffc02011cc:	f81fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc02011d0:	c80007b7          	lui	a5,0xc8000
ffffffffc02011d4:	8652                	mv	a2,s4
ffffffffc02011d6:	0d47e463          	bltu	a5,s4,ffffffffc020129e <pmm_init+0x144>
ffffffffc02011da:	00006797          	auipc	a5,0x6
ffffffffc02011de:	f8d78793          	addi	a5,a5,-115 # ffffffffc0207167 <end+0xfff>
ffffffffc02011e2:	757d                	lui	a0,0xfffff
ffffffffc02011e4:	8d7d                	and	a0,a0,a5
ffffffffc02011e6:	8231                	srli	a2,a2,0xc
ffffffffc02011e8:	00005797          	auipc	a5,0x5
ffffffffc02011ec:	f4c7b823          	sd	a2,-176(a5) # ffffffffc0206138 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02011f0:	00005797          	auipc	a5,0x5
ffffffffc02011f4:	f4a7b823          	sd	a0,-176(a5) # ffffffffc0206140 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02011f8:	000807b7          	lui	a5,0x80
ffffffffc02011fc:	002005b7          	lui	a1,0x200
ffffffffc0201200:	02f60563          	beq	a2,a5,ffffffffc020122a <pmm_init+0xd0>
ffffffffc0201204:	00261593          	slli	a1,a2,0x2
ffffffffc0201208:	00c586b3          	add	a3,a1,a2
ffffffffc020120c:	fec007b7          	lui	a5,0xfec00
ffffffffc0201210:	97aa                	add	a5,a5,a0
ffffffffc0201212:	068e                	slli	a3,a3,0x3
ffffffffc0201214:	96be                	add	a3,a3,a5
ffffffffc0201216:	87aa                	mv	a5,a0
        SetPageReserved(pages + i);
ffffffffc0201218:	6798                	ld	a4,8(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020121a:	02878793          	addi	a5,a5,40 # fffffffffec00028 <end+0x3e9f9ec0>
        SetPageReserved(pages + i);
ffffffffc020121e:	00176713          	ori	a4,a4,1
ffffffffc0201222:	fee7b023          	sd	a4,-32(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201226:	fef699e3          	bne	a3,a5,ffffffffc0201218 <pmm_init+0xbe>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020122a:	95b2                	add	a1,a1,a2
ffffffffc020122c:	fec006b7          	lui	a3,0xfec00
ffffffffc0201230:	96aa                	add	a3,a3,a0
ffffffffc0201232:	058e                	slli	a1,a1,0x3
ffffffffc0201234:	96ae                	add	a3,a3,a1
ffffffffc0201236:	c02007b7          	lui	a5,0xc0200
ffffffffc020123a:	0af6e763          	bltu	a3,a5,ffffffffc02012e8 <pmm_init+0x18e>
ffffffffc020123e:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0201240:	77fd                	lui	a5,0xfffff
ffffffffc0201242:	00fa75b3          	and	a1,s4,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201246:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201248:	04b6ee63          	bltu	a3,a1,ffffffffc02012a4 <pmm_init+0x14a>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020124c:	601c                	ld	a5,0(s0)
ffffffffc020124e:	7b9c                	ld	a5,48(a5)
ffffffffc0201250:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201252:	00001517          	auipc	a0,0x1
ffffffffc0201256:	03e50513          	addi	a0,a0,62 # ffffffffc0202290 <buddy_pmm_manager+0x120>
ffffffffc020125a:	ef3fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc020125e:	00004597          	auipc	a1,0x4
ffffffffc0201262:	da258593          	addi	a1,a1,-606 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201266:	00005797          	auipc	a5,0x5
ffffffffc020126a:	eeb7b923          	sd	a1,-270(a5) # ffffffffc0206158 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc020126e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201272:	0af5e363          	bltu	a1,a5,ffffffffc0201318 <pmm_init+0x1be>
ffffffffc0201276:	6090                	ld	a2,0(s1)
}
ffffffffc0201278:	7402                	ld	s0,32(sp)
ffffffffc020127a:	70a2                	ld	ra,40(sp)
ffffffffc020127c:	64e2                	ld	s1,24(sp)
ffffffffc020127e:	6942                	ld	s2,16(sp)
ffffffffc0201280:	69a2                	ld	s3,8(sp)
ffffffffc0201282:	6a02                	ld	s4,0(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0201284:	40c58633          	sub	a2,a1,a2
ffffffffc0201288:	00005797          	auipc	a5,0x5
ffffffffc020128c:	ecc7b423          	sd	a2,-312(a5) # ffffffffc0206150 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201290:	00001517          	auipc	a0,0x1
ffffffffc0201294:	02050513          	addi	a0,a0,32 # ffffffffc02022b0 <buddy_pmm_manager+0x140>
}
ffffffffc0201298:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020129a:	eb3fe06f          	j	ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc020129e:	c8000637          	lui	a2,0xc8000
ffffffffc02012a2:	bf25                	j	ffffffffc02011da <pmm_init+0x80>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02012a4:	6705                	lui	a4,0x1
ffffffffc02012a6:	177d                	addi	a4,a4,-1
ffffffffc02012a8:	96ba                	add	a3,a3,a4
ffffffffc02012aa:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02012ac:	00c6d793          	srli	a5,a3,0xc
ffffffffc02012b0:	02c7f063          	bgeu	a5,a2,ffffffffc02012d0 <pmm_init+0x176>
    pmm_manager->init_memmap(base, n);
ffffffffc02012b4:	6010                	ld	a2,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02012b6:	fff80737          	lui	a4,0xfff80
ffffffffc02012ba:	973e                	add	a4,a4,a5
ffffffffc02012bc:	00271793          	slli	a5,a4,0x2
ffffffffc02012c0:	97ba                	add	a5,a5,a4
ffffffffc02012c2:	6a18                	ld	a4,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02012c4:	8d95                	sub	a1,a1,a3
ffffffffc02012c6:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02012c8:	81b1                	srli	a1,a1,0xc
ffffffffc02012ca:	953e                	add	a0,a0,a5
ffffffffc02012cc:	9702                	jalr	a4
}
ffffffffc02012ce:	bfbd                	j	ffffffffc020124c <pmm_init+0xf2>
        panic("pa2page called with invalid pa");
ffffffffc02012d0:	00001617          	auipc	a2,0x1
ffffffffc02012d4:	f9060613          	addi	a2,a2,-112 # ffffffffc0202260 <buddy_pmm_manager+0xf0>
ffffffffc02012d8:	06a00593          	li	a1,106
ffffffffc02012dc:	00001517          	auipc	a0,0x1
ffffffffc02012e0:	fa450513          	addi	a0,a0,-92 # ffffffffc0202280 <buddy_pmm_manager+0x110>
ffffffffc02012e4:	edffe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02012e8:	00001617          	auipc	a2,0x1
ffffffffc02012ec:	f5060613          	addi	a2,a2,-176 # ffffffffc0202238 <buddy_pmm_manager+0xc8>
ffffffffc02012f0:	06000593          	li	a1,96
ffffffffc02012f4:	00001517          	auipc	a0,0x1
ffffffffc02012f8:	eec50513          	addi	a0,a0,-276 # ffffffffc02021e0 <buddy_pmm_manager+0x70>
ffffffffc02012fc:	ec7fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("DTB memory info not available");
ffffffffc0201300:	00001617          	auipc	a2,0x1
ffffffffc0201304:	ec060613          	addi	a2,a2,-320 # ffffffffc02021c0 <buddy_pmm_manager+0x50>
ffffffffc0201308:	04800593          	li	a1,72
ffffffffc020130c:	00001517          	auipc	a0,0x1
ffffffffc0201310:	ed450513          	addi	a0,a0,-300 # ffffffffc02021e0 <buddy_pmm_manager+0x70>
ffffffffc0201314:	eaffe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201318:	86ae                	mv	a3,a1
ffffffffc020131a:	00001617          	auipc	a2,0x1
ffffffffc020131e:	f1e60613          	addi	a2,a2,-226 # ffffffffc0202238 <buddy_pmm_manager+0xc8>
ffffffffc0201322:	07b00593          	li	a1,123
ffffffffc0201326:	00001517          	auipc	a0,0x1
ffffffffc020132a:	eba50513          	addi	a0,a0,-326 # ffffffffc02021e0 <buddy_pmm_manager+0x70>
ffffffffc020132e:	e95fe0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0201332 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201332:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201336:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201338:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020133c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020133e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201342:	f022                	sd	s0,32(sp)
ffffffffc0201344:	ec26                	sd	s1,24(sp)
ffffffffc0201346:	e84a                	sd	s2,16(sp)
ffffffffc0201348:	f406                	sd	ra,40(sp)
ffffffffc020134a:	e44e                	sd	s3,8(sp)
ffffffffc020134c:	84aa                	mv	s1,a0
ffffffffc020134e:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201350:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201354:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201356:	03067e63          	bgeu	a2,a6,ffffffffc0201392 <printnum+0x60>
ffffffffc020135a:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020135c:	00805763          	blez	s0,ffffffffc020136a <printnum+0x38>
ffffffffc0201360:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201362:	85ca                	mv	a1,s2
ffffffffc0201364:	854e                	mv	a0,s3
ffffffffc0201366:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201368:	fc65                	bnez	s0,ffffffffc0201360 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020136a:	1a02                	slli	s4,s4,0x20
ffffffffc020136c:	00001797          	auipc	a5,0x1
ffffffffc0201370:	f8478793          	addi	a5,a5,-124 # ffffffffc02022f0 <buddy_pmm_manager+0x180>
ffffffffc0201374:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201378:	9a3e                	add	s4,s4,a5
}
ffffffffc020137a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020137c:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201380:	70a2                	ld	ra,40(sp)
ffffffffc0201382:	69a2                	ld	s3,8(sp)
ffffffffc0201384:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201386:	85ca                	mv	a1,s2
ffffffffc0201388:	87a6                	mv	a5,s1
}
ffffffffc020138a:	6942                	ld	s2,16(sp)
ffffffffc020138c:	64e2                	ld	s1,24(sp)
ffffffffc020138e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201390:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201392:	03065633          	divu	a2,a2,a6
ffffffffc0201396:	8722                	mv	a4,s0
ffffffffc0201398:	f9bff0ef          	jal	ra,ffffffffc0201332 <printnum>
ffffffffc020139c:	b7f9                	j	ffffffffc020136a <printnum+0x38>

ffffffffc020139e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020139e:	7119                	addi	sp,sp,-128
ffffffffc02013a0:	f4a6                	sd	s1,104(sp)
ffffffffc02013a2:	f0ca                	sd	s2,96(sp)
ffffffffc02013a4:	ecce                	sd	s3,88(sp)
ffffffffc02013a6:	e8d2                	sd	s4,80(sp)
ffffffffc02013a8:	e4d6                	sd	s5,72(sp)
ffffffffc02013aa:	e0da                	sd	s6,64(sp)
ffffffffc02013ac:	fc5e                	sd	s7,56(sp)
ffffffffc02013ae:	f06a                	sd	s10,32(sp)
ffffffffc02013b0:	fc86                	sd	ra,120(sp)
ffffffffc02013b2:	f8a2                	sd	s0,112(sp)
ffffffffc02013b4:	f862                	sd	s8,48(sp)
ffffffffc02013b6:	f466                	sd	s9,40(sp)
ffffffffc02013b8:	ec6e                	sd	s11,24(sp)
ffffffffc02013ba:	892a                	mv	s2,a0
ffffffffc02013bc:	84ae                	mv	s1,a1
ffffffffc02013be:	8d32                	mv	s10,a2
ffffffffc02013c0:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013c2:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02013c6:	5b7d                	li	s6,-1
ffffffffc02013c8:	00001a97          	auipc	s5,0x1
ffffffffc02013cc:	f5ca8a93          	addi	s5,s5,-164 # ffffffffc0202324 <buddy_pmm_manager+0x1b4>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02013d0:	00001b97          	auipc	s7,0x1
ffffffffc02013d4:	130b8b93          	addi	s7,s7,304 # ffffffffc0202500 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013d8:	000d4503          	lbu	a0,0(s10)
ffffffffc02013dc:	001d0413          	addi	s0,s10,1
ffffffffc02013e0:	01350a63          	beq	a0,s3,ffffffffc02013f4 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02013e4:	c121                	beqz	a0,ffffffffc0201424 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02013e6:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013e8:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02013ea:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013ec:	fff44503          	lbu	a0,-1(s0)
ffffffffc02013f0:	ff351ae3          	bne	a0,s3,ffffffffc02013e4 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013f4:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02013f8:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02013fc:	4c81                	li	s9,0
ffffffffc02013fe:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201400:	5c7d                	li	s8,-1
ffffffffc0201402:	5dfd                	li	s11,-1
ffffffffc0201404:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201408:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020140a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020140e:	0ff5f593          	zext.b	a1,a1
ffffffffc0201412:	00140d13          	addi	s10,s0,1
ffffffffc0201416:	04b56263          	bltu	a0,a1,ffffffffc020145a <vprintfmt+0xbc>
ffffffffc020141a:	058a                	slli	a1,a1,0x2
ffffffffc020141c:	95d6                	add	a1,a1,s5
ffffffffc020141e:	4194                	lw	a3,0(a1)
ffffffffc0201420:	96d6                	add	a3,a3,s5
ffffffffc0201422:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201424:	70e6                	ld	ra,120(sp)
ffffffffc0201426:	7446                	ld	s0,112(sp)
ffffffffc0201428:	74a6                	ld	s1,104(sp)
ffffffffc020142a:	7906                	ld	s2,96(sp)
ffffffffc020142c:	69e6                	ld	s3,88(sp)
ffffffffc020142e:	6a46                	ld	s4,80(sp)
ffffffffc0201430:	6aa6                	ld	s5,72(sp)
ffffffffc0201432:	6b06                	ld	s6,64(sp)
ffffffffc0201434:	7be2                	ld	s7,56(sp)
ffffffffc0201436:	7c42                	ld	s8,48(sp)
ffffffffc0201438:	7ca2                	ld	s9,40(sp)
ffffffffc020143a:	7d02                	ld	s10,32(sp)
ffffffffc020143c:	6de2                	ld	s11,24(sp)
ffffffffc020143e:	6109                	addi	sp,sp,128
ffffffffc0201440:	8082                	ret
            padc = '0';
ffffffffc0201442:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201444:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201448:	846a                	mv	s0,s10
ffffffffc020144a:	00140d13          	addi	s10,s0,1
ffffffffc020144e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201452:	0ff5f593          	zext.b	a1,a1
ffffffffc0201456:	fcb572e3          	bgeu	a0,a1,ffffffffc020141a <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020145a:	85a6                	mv	a1,s1
ffffffffc020145c:	02500513          	li	a0,37
ffffffffc0201460:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201462:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201466:	8d22                	mv	s10,s0
ffffffffc0201468:	f73788e3          	beq	a5,s3,ffffffffc02013d8 <vprintfmt+0x3a>
ffffffffc020146c:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201470:	1d7d                	addi	s10,s10,-1
ffffffffc0201472:	ff379de3          	bne	a5,s3,ffffffffc020146c <vprintfmt+0xce>
ffffffffc0201476:	b78d                	j	ffffffffc02013d8 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201478:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020147c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201480:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201482:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201486:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020148a:	02d86463          	bltu	a6,a3,ffffffffc02014b2 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020148e:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201492:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201496:	0186873b          	addw	a4,a3,s8
ffffffffc020149a:	0017171b          	slliw	a4,a4,0x1
ffffffffc020149e:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02014a0:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02014a4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02014a6:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02014aa:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02014ae:	fed870e3          	bgeu	a6,a3,ffffffffc020148e <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02014b2:	f40ddce3          	bgez	s11,ffffffffc020140a <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02014b6:	8de2                	mv	s11,s8
ffffffffc02014b8:	5c7d                	li	s8,-1
ffffffffc02014ba:	bf81                	j	ffffffffc020140a <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02014bc:	fffdc693          	not	a3,s11
ffffffffc02014c0:	96fd                	srai	a3,a3,0x3f
ffffffffc02014c2:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014c6:	00144603          	lbu	a2,1(s0)
ffffffffc02014ca:	2d81                	sext.w	s11,s11
ffffffffc02014cc:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02014ce:	bf35                	j	ffffffffc020140a <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02014d0:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014d4:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02014d8:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014da:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02014dc:	bfd9                	j	ffffffffc02014b2 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02014de:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02014e0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02014e4:	01174463          	blt	a4,a7,ffffffffc02014ec <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02014e8:	1a088e63          	beqz	a7,ffffffffc02016a4 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02014ec:	000a3603          	ld	a2,0(s4)
ffffffffc02014f0:	46c1                	li	a3,16
ffffffffc02014f2:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02014f4:	2781                	sext.w	a5,a5
ffffffffc02014f6:	876e                	mv	a4,s11
ffffffffc02014f8:	85a6                	mv	a1,s1
ffffffffc02014fa:	854a                	mv	a0,s2
ffffffffc02014fc:	e37ff0ef          	jal	ra,ffffffffc0201332 <printnum>
            break;
ffffffffc0201500:	bde1                	j	ffffffffc02013d8 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201502:	000a2503          	lw	a0,0(s4)
ffffffffc0201506:	85a6                	mv	a1,s1
ffffffffc0201508:	0a21                	addi	s4,s4,8
ffffffffc020150a:	9902                	jalr	s2
            break;
ffffffffc020150c:	b5f1                	j	ffffffffc02013d8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020150e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201510:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201514:	01174463          	blt	a4,a7,ffffffffc020151c <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201518:	18088163          	beqz	a7,ffffffffc020169a <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020151c:	000a3603          	ld	a2,0(s4)
ffffffffc0201520:	46a9                	li	a3,10
ffffffffc0201522:	8a2e                	mv	s4,a1
ffffffffc0201524:	bfc1                	j	ffffffffc02014f4 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201526:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020152a:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020152c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020152e:	bdf1                	j	ffffffffc020140a <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201530:	85a6                	mv	a1,s1
ffffffffc0201532:	02500513          	li	a0,37
ffffffffc0201536:	9902                	jalr	s2
            break;
ffffffffc0201538:	b545                	j	ffffffffc02013d8 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020153a:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020153e:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201540:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201542:	b5e1                	j	ffffffffc020140a <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201544:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201546:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020154a:	01174463          	blt	a4,a7,ffffffffc0201552 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020154e:	14088163          	beqz	a7,ffffffffc0201690 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201552:	000a3603          	ld	a2,0(s4)
ffffffffc0201556:	46a1                	li	a3,8
ffffffffc0201558:	8a2e                	mv	s4,a1
ffffffffc020155a:	bf69                	j	ffffffffc02014f4 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc020155c:	03000513          	li	a0,48
ffffffffc0201560:	85a6                	mv	a1,s1
ffffffffc0201562:	e03e                	sd	a5,0(sp)
ffffffffc0201564:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201566:	85a6                	mv	a1,s1
ffffffffc0201568:	07800513          	li	a0,120
ffffffffc020156c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020156e:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201570:	6782                	ld	a5,0(sp)
ffffffffc0201572:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201574:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201578:	bfb5                	j	ffffffffc02014f4 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020157a:	000a3403          	ld	s0,0(s4)
ffffffffc020157e:	008a0713          	addi	a4,s4,8
ffffffffc0201582:	e03a                	sd	a4,0(sp)
ffffffffc0201584:	14040263          	beqz	s0,ffffffffc02016c8 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201588:	0fb05763          	blez	s11,ffffffffc0201676 <vprintfmt+0x2d8>
ffffffffc020158c:	02d00693          	li	a3,45
ffffffffc0201590:	0cd79163          	bne	a5,a3,ffffffffc0201652 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201594:	00044783          	lbu	a5,0(s0)
ffffffffc0201598:	0007851b          	sext.w	a0,a5
ffffffffc020159c:	cf85                	beqz	a5,ffffffffc02015d4 <vprintfmt+0x236>
ffffffffc020159e:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02015a2:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02015a6:	000c4563          	bltz	s8,ffffffffc02015b0 <vprintfmt+0x212>
ffffffffc02015aa:	3c7d                	addiw	s8,s8,-1
ffffffffc02015ac:	036c0263          	beq	s8,s6,ffffffffc02015d0 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02015b0:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02015b2:	0e0c8e63          	beqz	s9,ffffffffc02016ae <vprintfmt+0x310>
ffffffffc02015b6:	3781                	addiw	a5,a5,-32
ffffffffc02015b8:	0ef47b63          	bgeu	s0,a5,ffffffffc02016ae <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02015bc:	03f00513          	li	a0,63
ffffffffc02015c0:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02015c2:	000a4783          	lbu	a5,0(s4)
ffffffffc02015c6:	3dfd                	addiw	s11,s11,-1
ffffffffc02015c8:	0a05                	addi	s4,s4,1
ffffffffc02015ca:	0007851b          	sext.w	a0,a5
ffffffffc02015ce:	ffe1                	bnez	a5,ffffffffc02015a6 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02015d0:	01b05963          	blez	s11,ffffffffc02015e2 <vprintfmt+0x244>
ffffffffc02015d4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02015d6:	85a6                	mv	a1,s1
ffffffffc02015d8:	02000513          	li	a0,32
ffffffffc02015dc:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02015de:	fe0d9be3          	bnez	s11,ffffffffc02015d4 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02015e2:	6a02                	ld	s4,0(sp)
ffffffffc02015e4:	bbd5                	j	ffffffffc02013d8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02015e6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02015e8:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02015ec:	01174463          	blt	a4,a7,ffffffffc02015f4 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02015f0:	08088d63          	beqz	a7,ffffffffc020168a <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02015f4:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02015f8:	0a044d63          	bltz	s0,ffffffffc02016b2 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02015fc:	8622                	mv	a2,s0
ffffffffc02015fe:	8a66                	mv	s4,s9
ffffffffc0201600:	46a9                	li	a3,10
ffffffffc0201602:	bdcd                	j	ffffffffc02014f4 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201604:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201608:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020160a:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020160c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201610:	8fb5                	xor	a5,a5,a3
ffffffffc0201612:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201616:	02d74163          	blt	a4,a3,ffffffffc0201638 <vprintfmt+0x29a>
ffffffffc020161a:	00369793          	slli	a5,a3,0x3
ffffffffc020161e:	97de                	add	a5,a5,s7
ffffffffc0201620:	639c                	ld	a5,0(a5)
ffffffffc0201622:	cb99                	beqz	a5,ffffffffc0201638 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201624:	86be                	mv	a3,a5
ffffffffc0201626:	00001617          	auipc	a2,0x1
ffffffffc020162a:	cfa60613          	addi	a2,a2,-774 # ffffffffc0202320 <buddy_pmm_manager+0x1b0>
ffffffffc020162e:	85a6                	mv	a1,s1
ffffffffc0201630:	854a                	mv	a0,s2
ffffffffc0201632:	0ce000ef          	jal	ra,ffffffffc0201700 <printfmt>
ffffffffc0201636:	b34d                	j	ffffffffc02013d8 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201638:	00001617          	auipc	a2,0x1
ffffffffc020163c:	cd860613          	addi	a2,a2,-808 # ffffffffc0202310 <buddy_pmm_manager+0x1a0>
ffffffffc0201640:	85a6                	mv	a1,s1
ffffffffc0201642:	854a                	mv	a0,s2
ffffffffc0201644:	0bc000ef          	jal	ra,ffffffffc0201700 <printfmt>
ffffffffc0201648:	bb41                	j	ffffffffc02013d8 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020164a:	00001417          	auipc	s0,0x1
ffffffffc020164e:	cbe40413          	addi	s0,s0,-834 # ffffffffc0202308 <buddy_pmm_manager+0x198>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201652:	85e2                	mv	a1,s8
ffffffffc0201654:	8522                	mv	a0,s0
ffffffffc0201656:	e43e                	sd	a5,8(sp)
ffffffffc0201658:	0fc000ef          	jal	ra,ffffffffc0201754 <strnlen>
ffffffffc020165c:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201660:	01b05b63          	blez	s11,ffffffffc0201676 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201664:	67a2                	ld	a5,8(sp)
ffffffffc0201666:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020166a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020166c:	85a6                	mv	a1,s1
ffffffffc020166e:	8552                	mv	a0,s4
ffffffffc0201670:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201672:	fe0d9ce3          	bnez	s11,ffffffffc020166a <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201676:	00044783          	lbu	a5,0(s0)
ffffffffc020167a:	00140a13          	addi	s4,s0,1
ffffffffc020167e:	0007851b          	sext.w	a0,a5
ffffffffc0201682:	d3a5                	beqz	a5,ffffffffc02015e2 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201684:	05e00413          	li	s0,94
ffffffffc0201688:	bf39                	j	ffffffffc02015a6 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020168a:	000a2403          	lw	s0,0(s4)
ffffffffc020168e:	b7ad                	j	ffffffffc02015f8 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201690:	000a6603          	lwu	a2,0(s4)
ffffffffc0201694:	46a1                	li	a3,8
ffffffffc0201696:	8a2e                	mv	s4,a1
ffffffffc0201698:	bdb1                	j	ffffffffc02014f4 <vprintfmt+0x156>
ffffffffc020169a:	000a6603          	lwu	a2,0(s4)
ffffffffc020169e:	46a9                	li	a3,10
ffffffffc02016a0:	8a2e                	mv	s4,a1
ffffffffc02016a2:	bd89                	j	ffffffffc02014f4 <vprintfmt+0x156>
ffffffffc02016a4:	000a6603          	lwu	a2,0(s4)
ffffffffc02016a8:	46c1                	li	a3,16
ffffffffc02016aa:	8a2e                	mv	s4,a1
ffffffffc02016ac:	b5a1                	j	ffffffffc02014f4 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02016ae:	9902                	jalr	s2
ffffffffc02016b0:	bf09                	j	ffffffffc02015c2 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02016b2:	85a6                	mv	a1,s1
ffffffffc02016b4:	02d00513          	li	a0,45
ffffffffc02016b8:	e03e                	sd	a5,0(sp)
ffffffffc02016ba:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02016bc:	6782                	ld	a5,0(sp)
ffffffffc02016be:	8a66                	mv	s4,s9
ffffffffc02016c0:	40800633          	neg	a2,s0
ffffffffc02016c4:	46a9                	li	a3,10
ffffffffc02016c6:	b53d                	j	ffffffffc02014f4 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02016c8:	03b05163          	blez	s11,ffffffffc02016ea <vprintfmt+0x34c>
ffffffffc02016cc:	02d00693          	li	a3,45
ffffffffc02016d0:	f6d79de3          	bne	a5,a3,ffffffffc020164a <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02016d4:	00001417          	auipc	s0,0x1
ffffffffc02016d8:	c3440413          	addi	s0,s0,-972 # ffffffffc0202308 <buddy_pmm_manager+0x198>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016dc:	02800793          	li	a5,40
ffffffffc02016e0:	02800513          	li	a0,40
ffffffffc02016e4:	00140a13          	addi	s4,s0,1
ffffffffc02016e8:	bd6d                	j	ffffffffc02015a2 <vprintfmt+0x204>
ffffffffc02016ea:	00001a17          	auipc	s4,0x1
ffffffffc02016ee:	c1fa0a13          	addi	s4,s4,-993 # ffffffffc0202309 <buddy_pmm_manager+0x199>
ffffffffc02016f2:	02800513          	li	a0,40
ffffffffc02016f6:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02016fa:	05e00413          	li	s0,94
ffffffffc02016fe:	b565                	j	ffffffffc02015a6 <vprintfmt+0x208>

ffffffffc0201700 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201700:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201702:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201706:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201708:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020170a:	ec06                	sd	ra,24(sp)
ffffffffc020170c:	f83a                	sd	a4,48(sp)
ffffffffc020170e:	fc3e                	sd	a5,56(sp)
ffffffffc0201710:	e0c2                	sd	a6,64(sp)
ffffffffc0201712:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201714:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201716:	c89ff0ef          	jal	ra,ffffffffc020139e <vprintfmt>
}
ffffffffc020171a:	60e2                	ld	ra,24(sp)
ffffffffc020171c:	6161                	addi	sp,sp,80
ffffffffc020171e:	8082                	ret

ffffffffc0201720 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201720:	4781                	li	a5,0
ffffffffc0201722:	00005717          	auipc	a4,0x5
ffffffffc0201726:	8ee73703          	ld	a4,-1810(a4) # ffffffffc0206010 <SBI_CONSOLE_PUTCHAR>
ffffffffc020172a:	88ba                	mv	a7,a4
ffffffffc020172c:	852a                	mv	a0,a0
ffffffffc020172e:	85be                	mv	a1,a5
ffffffffc0201730:	863e                	mv	a2,a5
ffffffffc0201732:	00000073          	ecall
ffffffffc0201736:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201738:	8082                	ret

ffffffffc020173a <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020173a:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc020173e:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0201740:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0201742:	cb81                	beqz	a5,ffffffffc0201752 <strlen+0x18>
        cnt ++;
ffffffffc0201744:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0201746:	00a707b3          	add	a5,a4,a0
ffffffffc020174a:	0007c783          	lbu	a5,0(a5)
ffffffffc020174e:	fbfd                	bnez	a5,ffffffffc0201744 <strlen+0xa>
ffffffffc0201750:	8082                	ret
    }
    return cnt;
}
ffffffffc0201752:	8082                	ret

ffffffffc0201754 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201754:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201756:	e589                	bnez	a1,ffffffffc0201760 <strnlen+0xc>
ffffffffc0201758:	a811                	j	ffffffffc020176c <strnlen+0x18>
        cnt ++;
ffffffffc020175a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020175c:	00f58863          	beq	a1,a5,ffffffffc020176c <strnlen+0x18>
ffffffffc0201760:	00f50733          	add	a4,a0,a5
ffffffffc0201764:	00074703          	lbu	a4,0(a4)
ffffffffc0201768:	fb6d                	bnez	a4,ffffffffc020175a <strnlen+0x6>
ffffffffc020176a:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020176c:	852e                	mv	a0,a1
ffffffffc020176e:	8082                	ret

ffffffffc0201770 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201770:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201774:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201778:	cb89                	beqz	a5,ffffffffc020178a <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc020177a:	0505                	addi	a0,a0,1
ffffffffc020177c:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020177e:	fee789e3          	beq	a5,a4,ffffffffc0201770 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201782:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201786:	9d19                	subw	a0,a0,a4
ffffffffc0201788:	8082                	ret
ffffffffc020178a:	4501                	li	a0,0
ffffffffc020178c:	bfed                	j	ffffffffc0201786 <strcmp+0x16>

ffffffffc020178e <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020178e:	c20d                	beqz	a2,ffffffffc02017b0 <strncmp+0x22>
ffffffffc0201790:	962e                	add	a2,a2,a1
ffffffffc0201792:	a031                	j	ffffffffc020179e <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0201794:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201796:	00e79a63          	bne	a5,a4,ffffffffc02017aa <strncmp+0x1c>
ffffffffc020179a:	00b60b63          	beq	a2,a1,ffffffffc02017b0 <strncmp+0x22>
ffffffffc020179e:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc02017a2:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02017a4:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02017a8:	f7f5                	bnez	a5,ffffffffc0201794 <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02017aa:	40e7853b          	subw	a0,a5,a4
}
ffffffffc02017ae:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02017b0:	4501                	li	a0,0
ffffffffc02017b2:	8082                	ret

ffffffffc02017b4 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02017b4:	ca01                	beqz	a2,ffffffffc02017c4 <memset+0x10>
ffffffffc02017b6:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02017b8:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02017ba:	0785                	addi	a5,a5,1
ffffffffc02017bc:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02017c0:	fec79de3          	bne	a5,a2,ffffffffc02017ba <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02017c4:	8082                	ret
