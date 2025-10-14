
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
ffffffffc020004c:	00002517          	auipc	a0,0x2
ffffffffc0200050:	a8450513          	addi	a0,a0,-1404 # ffffffffc0201ad0 <etext>
void print_kerninfo(void) {
ffffffffc0200054:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200056:	0f6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", (uintptr_t)kern_init);
ffffffffc020005a:	00000597          	auipc	a1,0x0
ffffffffc020005e:	07e58593          	addi	a1,a1,126 # ffffffffc02000d8 <kern_init>
ffffffffc0200062:	00002517          	auipc	a0,0x2
ffffffffc0200066:	a8e50513          	addi	a0,a0,-1394 # ffffffffc0201af0 <etext+0x20>
ffffffffc020006a:	0e2000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020006e:	00002597          	auipc	a1,0x2
ffffffffc0200072:	a6258593          	addi	a1,a1,-1438 # ffffffffc0201ad0 <etext>
ffffffffc0200076:	00002517          	auipc	a0,0x2
ffffffffc020007a:	a9a50513          	addi	a0,a0,-1382 # ffffffffc0201b10 <etext+0x40>
ffffffffc020007e:	0ce000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200082:	00006597          	auipc	a1,0x6
ffffffffc0200086:	f9658593          	addi	a1,a1,-106 # ffffffffc0206018 <slub_allocator>
ffffffffc020008a:	00002517          	auipc	a0,0x2
ffffffffc020008e:	aa650513          	addi	a0,a0,-1370 # ffffffffc0201b30 <etext+0x60>
ffffffffc0200092:	0ba000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200096:	00016597          	auipc	a1,0x16
ffffffffc020009a:	05258593          	addi	a1,a1,82 # ffffffffc02160e8 <end>
ffffffffc020009e:	00002517          	auipc	a0,0x2
ffffffffc02000a2:	ab250513          	addi	a0,a0,-1358 # ffffffffc0201b50 <etext+0x80>
ffffffffc02000a6:	0a6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - (char*)kern_init + 1023) / 1024);
ffffffffc02000aa:	00016597          	auipc	a1,0x16
ffffffffc02000ae:	43d58593          	addi	a1,a1,1085 # ffffffffc02164e7 <end+0x3ff>
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
ffffffffc02000cc:	00002517          	auipc	a0,0x2
ffffffffc02000d0:	aa450513          	addi	a0,a0,-1372 # ffffffffc0201b70 <etext+0xa0>
}
ffffffffc02000d4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000d6:	a89d                	j	ffffffffc020014c <cprintf>

ffffffffc02000d8 <kern_init>:

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc02000d8:	00006517          	auipc	a0,0x6
ffffffffc02000dc:	f4050513          	addi	a0,a0,-192 # ffffffffc0206018 <slub_allocator>
ffffffffc02000e0:	00016617          	auipc	a2,0x16
ffffffffc02000e4:	00860613          	addi	a2,a2,8 # ffffffffc02160e8 <end>
int kern_init(void) {
ffffffffc02000e8:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc02000ea:	8e09                	sub	a2,a2,a0
ffffffffc02000ec:	4581                	li	a1,0
int kern_init(void) {
ffffffffc02000ee:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc02000f0:	18f010ef          	jal	ra,ffffffffc0201a7e <memset>
    dtb_init();
ffffffffc02000f4:	12c000ef          	jal	ra,ffffffffc0200220 <dtb_init>
    cons_init();  // init the console
ffffffffc02000f8:	11e000ef          	jal	ra,ffffffffc0200216 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc02000fc:	00002517          	auipc	a0,0x2
ffffffffc0200100:	aa450513          	addi	a0,a0,-1372 # ffffffffc0201ba0 <etext+0xd0>
ffffffffc0200104:	07e000ef          	jal	ra,ffffffffc0200182 <cputs>

    print_kerninfo();
ffffffffc0200108:	f43ff0ef          	jal	ra,ffffffffc020004a <print_kerninfo>

    // grade_backtrace();
    pmm_init();  // init physical memory management
ffffffffc020010c:	4c4000ef          	jal	ra,ffffffffc02005d0 <pmm_init>

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
ffffffffc0200140:	4d0010ef          	jal	ra,ffffffffc0201610 <vprintfmt>
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
ffffffffc0200176:	49a010ef          	jal	ra,ffffffffc0201610 <vprintfmt>
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
ffffffffc02001c2:	00016317          	auipc	t1,0x16
ffffffffc02001c6:	ed630313          	addi	t1,t1,-298 # ffffffffc0216098 <is_panic>
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
ffffffffc02001f2:	00002517          	auipc	a0,0x2
ffffffffc02001f6:	9ce50513          	addi	a0,a0,-1586 # ffffffffc0201bc0 <etext+0xf0>
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
ffffffffc020020c:	0e850513          	addi	a0,a0,232 # ffffffffc02022f0 <etext+0x820>
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
ffffffffc020021c:	7bc0106f          	j	ffffffffc02019d8 <sbi_console_putchar>

ffffffffc0200220 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc0200220:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc0200222:	00002517          	auipc	a0,0x2
ffffffffc0200226:	9be50513          	addi	a0,a0,-1602 # ffffffffc0201be0 <etext+0x110>
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
ffffffffc0200250:	00002517          	auipc	a0,0x2
ffffffffc0200254:	9a050513          	addi	a0,a0,-1632 # ffffffffc0201bf0 <etext+0x120>
ffffffffc0200258:	ef5ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020025c:	00006417          	auipc	s0,0x6
ffffffffc0200260:	dac40413          	addi	s0,s0,-596 # ffffffffc0206008 <boot_dtb>
ffffffffc0200264:	600c                	ld	a1,0(s0)
ffffffffc0200266:	00002517          	auipc	a0,0x2
ffffffffc020026a:	99a50513          	addi	a0,a0,-1638 # ffffffffc0201c00 <etext+0x130>
ffffffffc020026e:	edfff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200272:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200276:	00002517          	auipc	a0,0x2
ffffffffc020027a:	9a250513          	addi	a0,a0,-1630 # ffffffffc0201c18 <etext+0x148>
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
ffffffffc02002be:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfec9e05>
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
ffffffffc0200330:	00002917          	auipc	s2,0x2
ffffffffc0200334:	93890913          	addi	s2,s2,-1736 # ffffffffc0201c68 <etext+0x198>
ffffffffc0200338:	49bd                	li	s3,15
        switch (token) {
ffffffffc020033a:	4d91                	li	s11,4
ffffffffc020033c:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020033e:	00002497          	auipc	s1,0x2
ffffffffc0200342:	92248493          	addi	s1,s1,-1758 # ffffffffc0201c60 <etext+0x190>
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
ffffffffc0200392:	00002517          	auipc	a0,0x2
ffffffffc0200396:	94e50513          	addi	a0,a0,-1714 # ffffffffc0201ce0 <etext+0x210>
ffffffffc020039a:	db3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	97a50513          	addi	a0,a0,-1670 # ffffffffc0201d18 <etext+0x248>
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
ffffffffc02003de:	00002517          	auipc	a0,0x2
ffffffffc02003e2:	85a50513          	addi	a0,a0,-1958 # ffffffffc0201c38 <etext+0x168>
}
ffffffffc02003e6:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003e8:	b395                	j	ffffffffc020014c <cprintf>
                int name_len = strlen(name);
ffffffffc02003ea:	8556                	mv	a0,s5
ffffffffc02003ec:	606010ef          	jal	ra,ffffffffc02019f2 <strlen>
ffffffffc02003f0:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003f2:	4619                	li	a2,6
ffffffffc02003f4:	85a6                	mv	a1,s1
ffffffffc02003f6:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02003f8:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003fa:	65e010ef          	jal	ra,ffffffffc0201a58 <strncmp>
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
ffffffffc0200490:	5aa010ef          	jal	ra,ffffffffc0201a3a <strcmp>
ffffffffc0200494:	66a2                	ld	a3,8(sp)
ffffffffc0200496:	f94d                	bnez	a0,ffffffffc0200448 <dtb_init+0x228>
ffffffffc0200498:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200448 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc020049c:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc02004a0:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc02004a4:	00001517          	auipc	a0,0x1
ffffffffc02004a8:	7cc50513          	addi	a0,a0,1996 # ffffffffc0201c70 <etext+0x1a0>
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
ffffffffc0200576:	71e50513          	addi	a0,a0,1822 # ffffffffc0201c90 <etext+0x1c0>
ffffffffc020057a:	bd3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020057e:	014b5613          	srli	a2,s6,0x14
ffffffffc0200582:	85da                	mv	a1,s6
ffffffffc0200584:	00001517          	auipc	a0,0x1
ffffffffc0200588:	72450513          	addi	a0,a0,1828 # ffffffffc0201ca8 <etext+0x1d8>
ffffffffc020058c:	bc1ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200590:	008b05b3          	add	a1,s6,s0
ffffffffc0200594:	15fd                	addi	a1,a1,-1
ffffffffc0200596:	00001517          	auipc	a0,0x1
ffffffffc020059a:	73250513          	addi	a0,a0,1842 # ffffffffc0201cc8 <etext+0x1f8>
ffffffffc020059e:	bafff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB init completed\n");
ffffffffc02005a2:	00001517          	auipc	a0,0x1
ffffffffc02005a6:	77650513          	addi	a0,a0,1910 # ffffffffc0201d18 <etext+0x248>
        memory_base = mem_base;
ffffffffc02005aa:	00016797          	auipc	a5,0x16
ffffffffc02005ae:	ae87bb23          	sd	s0,-1290(a5) # ffffffffc02160a0 <memory_base>
        memory_size = mem_size;
ffffffffc02005b2:	00016797          	auipc	a5,0x16
ffffffffc02005b6:	af67bb23          	sd	s6,-1290(a5) # ffffffffc02160a8 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc02005ba:	b3f5                	j	ffffffffc02003a6 <dtb_init+0x186>

ffffffffc02005bc <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02005bc:	00016517          	auipc	a0,0x16
ffffffffc02005c0:	ae453503          	ld	a0,-1308(a0) # ffffffffc02160a0 <memory_base>
ffffffffc02005c4:	8082                	ret

ffffffffc02005c6 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
ffffffffc02005c6:	00016517          	auipc	a0,0x16
ffffffffc02005ca:	ae253503          	ld	a0,-1310(a0) # ffffffffc02160a8 <memory_size>
ffffffffc02005ce:	8082                	ret

ffffffffc02005d0 <pmm_init>:
static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    //切换管理器
    pmm_manager = &slub_pmm_manager;
ffffffffc02005d0:	00002797          	auipc	a5,0x2
ffffffffc02005d4:	0e878793          	addi	a5,a5,232 # ffffffffc02026b8 <slub_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02005d8:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02005da:	7179                	addi	sp,sp,-48
ffffffffc02005dc:	f022                	sd	s0,32(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	75250513          	addi	a0,a0,1874 # ffffffffc0201d30 <etext+0x260>
    pmm_manager = &slub_pmm_manager;
ffffffffc02005e6:	00016417          	auipc	s0,0x16
ffffffffc02005ea:	ada40413          	addi	s0,s0,-1318 # ffffffffc02160c0 <pmm_manager>
void pmm_init(void) {
ffffffffc02005ee:	f406                	sd	ra,40(sp)
ffffffffc02005f0:	ec26                	sd	s1,24(sp)
ffffffffc02005f2:	e44e                	sd	s3,8(sp)
ffffffffc02005f4:	e84a                	sd	s2,16(sp)
ffffffffc02005f6:	e052                	sd	s4,0(sp)
    pmm_manager = &slub_pmm_manager;
ffffffffc02005f8:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02005fa:	b53ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    pmm_manager->init();
ffffffffc02005fe:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200600:	00016497          	auipc	s1,0x16
ffffffffc0200604:	ad848493          	addi	s1,s1,-1320 # ffffffffc02160d8 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200608:	679c                	ld	a5,8(a5)
ffffffffc020060a:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020060c:	57f5                	li	a5,-3
ffffffffc020060e:	07fa                	slli	a5,a5,0x1e
ffffffffc0200610:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();
ffffffffc0200612:	fabff0ef          	jal	ra,ffffffffc02005bc <get_memory_base>
ffffffffc0200616:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc0200618:	fafff0ef          	jal	ra,ffffffffc02005c6 <get_memory_size>
    if (mem_size == 0) {
ffffffffc020061c:	14050c63          	beqz	a0,ffffffffc0200774 <pmm_init+0x1a4>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200620:	892a                	mv	s2,a0
    cprintf("physcial memory map:\n");
ffffffffc0200622:	00001517          	auipc	a0,0x1
ffffffffc0200626:	75650513          	addi	a0,a0,1878 # ffffffffc0201d78 <etext+0x2a8>
ffffffffc020062a:	b23ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc020062e:	01298a33          	add	s4,s3,s2
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200632:	864e                	mv	a2,s3
ffffffffc0200634:	fffa0693          	addi	a3,s4,-1
ffffffffc0200638:	85ca                	mv	a1,s2
ffffffffc020063a:	00001517          	auipc	a0,0x1
ffffffffc020063e:	75650513          	addi	a0,a0,1878 # ffffffffc0201d90 <etext+0x2c0>
ffffffffc0200642:	b0bff0ef          	jal	ra,ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0200646:	c80007b7          	lui	a5,0xc8000
ffffffffc020064a:	8652                	mv	a2,s4
ffffffffc020064c:	0d47e363          	bltu	a5,s4,ffffffffc0200712 <pmm_init+0x142>
ffffffffc0200650:	00017797          	auipc	a5,0x17
ffffffffc0200654:	a9778793          	addi	a5,a5,-1385 # ffffffffc02170e7 <end+0xfff>
ffffffffc0200658:	757d                	lui	a0,0xfffff
ffffffffc020065a:	8d7d                	and	a0,a0,a5
ffffffffc020065c:	8231                	srli	a2,a2,0xc
ffffffffc020065e:	00016797          	auipc	a5,0x16
ffffffffc0200662:	a4c7b923          	sd	a2,-1454(a5) # ffffffffc02160b0 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200666:	00016797          	auipc	a5,0x16
ffffffffc020066a:	a4a7b923          	sd	a0,-1454(a5) # ffffffffc02160b8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020066e:	000807b7          	lui	a5,0x80
ffffffffc0200672:	002005b7          	lui	a1,0x200
ffffffffc0200676:	02f60563          	beq	a2,a5,ffffffffc02006a0 <pmm_init+0xd0>
ffffffffc020067a:	00261593          	slli	a1,a2,0x2
ffffffffc020067e:	00c586b3          	add	a3,a1,a2
ffffffffc0200682:	fec007b7          	lui	a5,0xfec00
ffffffffc0200686:	97aa                	add	a5,a5,a0
ffffffffc0200688:	068e                	slli	a3,a3,0x3
ffffffffc020068a:	96be                	add	a3,a3,a5
ffffffffc020068c:	87aa                	mv	a5,a0
        SetPageReserved(pages + i);
ffffffffc020068e:	6798                	ld	a4,8(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200690:	02878793          	addi	a5,a5,40 # fffffffffec00028 <end+0x3e9e9f40>
        SetPageReserved(pages + i);
ffffffffc0200694:	00176713          	ori	a4,a4,1
ffffffffc0200698:	fee7b023          	sd	a4,-32(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020069c:	fef699e3          	bne	a3,a5,ffffffffc020068e <pmm_init+0xbe>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02006a0:	95b2                	add	a1,a1,a2
ffffffffc02006a2:	fec006b7          	lui	a3,0xfec00
ffffffffc02006a6:	96aa                	add	a3,a3,a0
ffffffffc02006a8:	058e                	slli	a1,a1,0x3
ffffffffc02006aa:	96ae                	add	a3,a3,a1
ffffffffc02006ac:	c02007b7          	lui	a5,0xc0200
ffffffffc02006b0:	0af6e663          	bltu	a3,a5,ffffffffc020075c <pmm_init+0x18c>
ffffffffc02006b4:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc02006b6:	77fd                	lui	a5,0xfffff
ffffffffc02006b8:	00fa75b3          	and	a1,s4,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02006bc:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02006be:	04b6ed63          	bltu	a3,a1,ffffffffc0200718 <pmm_init+0x148>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02006c2:	601c                	ld	a5,0(s0)
ffffffffc02006c4:	7b9c                	ld	a5,48(a5)
ffffffffc02006c6:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02006c8:	00001517          	auipc	a0,0x1
ffffffffc02006cc:	75050513          	addi	a0,a0,1872 # ffffffffc0201e18 <etext+0x348>
ffffffffc02006d0:	a7dff0ef          	jal	ra,ffffffffc020014c <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02006d4:	00005597          	auipc	a1,0x5
ffffffffc02006d8:	92c58593          	addi	a1,a1,-1748 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02006dc:	00016797          	auipc	a5,0x16
ffffffffc02006e0:	9eb7ba23          	sd	a1,-1548(a5) # ffffffffc02160d0 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02006e4:	c02007b7          	lui	a5,0xc0200
ffffffffc02006e8:	0af5e263          	bltu	a1,a5,ffffffffc020078c <pmm_init+0x1bc>
ffffffffc02006ec:	6090                	ld	a2,0(s1)
}
ffffffffc02006ee:	7402                	ld	s0,32(sp)
ffffffffc02006f0:	70a2                	ld	ra,40(sp)
ffffffffc02006f2:	64e2                	ld	s1,24(sp)
ffffffffc02006f4:	6942                	ld	s2,16(sp)
ffffffffc02006f6:	69a2                	ld	s3,8(sp)
ffffffffc02006f8:	6a02                	ld	s4,0(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02006fa:	40c58633          	sub	a2,a1,a2
ffffffffc02006fe:	00016797          	auipc	a5,0x16
ffffffffc0200702:	9cc7b523          	sd	a2,-1590(a5) # ffffffffc02160c8 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200706:	00001517          	auipc	a0,0x1
ffffffffc020070a:	73250513          	addi	a0,a0,1842 # ffffffffc0201e38 <etext+0x368>
}
ffffffffc020070e:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200710:	bc35                	j	ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0200712:	c8000637          	lui	a2,0xc8000
ffffffffc0200716:	bf2d                	j	ffffffffc0200650 <pmm_init+0x80>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200718:	6705                	lui	a4,0x1
ffffffffc020071a:	177d                	addi	a4,a4,-1
ffffffffc020071c:	96ba                	add	a3,a3,a4
ffffffffc020071e:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200720:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200724:	02c7f063          	bgeu	a5,a2,ffffffffc0200744 <pmm_init+0x174>
    pmm_manager->init_memmap(base, n);
ffffffffc0200728:	6010                	ld	a2,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc020072a:	fff80737          	lui	a4,0xfff80
ffffffffc020072e:	973e                	add	a4,a4,a5
ffffffffc0200730:	00271793          	slli	a5,a4,0x2
ffffffffc0200734:	97ba                	add	a5,a5,a4
ffffffffc0200736:	6a18                	ld	a4,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200738:	8d95                	sub	a1,a1,a3
ffffffffc020073a:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc020073c:	81b1                	srli	a1,a1,0xc
ffffffffc020073e:	953e                	add	a0,a0,a5
ffffffffc0200740:	9702                	jalr	a4
}
ffffffffc0200742:	b741                	j	ffffffffc02006c2 <pmm_init+0xf2>
        panic("pa2page called with invalid pa");
ffffffffc0200744:	00001617          	auipc	a2,0x1
ffffffffc0200748:	6a460613          	addi	a2,a2,1700 # ffffffffc0201de8 <etext+0x318>
ffffffffc020074c:	06a00593          	li	a1,106
ffffffffc0200750:	00001517          	auipc	a0,0x1
ffffffffc0200754:	6b850513          	addi	a0,a0,1720 # ffffffffc0201e08 <etext+0x338>
ffffffffc0200758:	a6bff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020075c:	00001617          	auipc	a2,0x1
ffffffffc0200760:	66460613          	addi	a2,a2,1636 # ffffffffc0201dc0 <etext+0x2f0>
ffffffffc0200764:	06100593          	li	a1,97
ffffffffc0200768:	00001517          	auipc	a0,0x1
ffffffffc020076c:	60050513          	addi	a0,a0,1536 # ffffffffc0201d68 <etext+0x298>
ffffffffc0200770:	a53ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("DTB memory info not available");
ffffffffc0200774:	00001617          	auipc	a2,0x1
ffffffffc0200778:	5d460613          	addi	a2,a2,1492 # ffffffffc0201d48 <etext+0x278>
ffffffffc020077c:	04900593          	li	a1,73
ffffffffc0200780:	00001517          	auipc	a0,0x1
ffffffffc0200784:	5e850513          	addi	a0,a0,1512 # ffffffffc0201d68 <etext+0x298>
ffffffffc0200788:	a3bff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020078c:	86ae                	mv	a3,a1
ffffffffc020078e:	00001617          	auipc	a2,0x1
ffffffffc0200792:	63260613          	addi	a2,a2,1586 # ffffffffc0201dc0 <etext+0x2f0>
ffffffffc0200796:	07c00593          	li	a1,124
ffffffffc020079a:	00001517          	auipc	a0,0x1
ffffffffc020079e:	5ce50513          	addi	a0,a0,1486 # ffffffffc0201d68 <etext+0x298>
ffffffffc02007a2:	a21ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02007a6 <slub_nr_free_pages>:
size_t slub_nr_free_pages(void) {
    extern struct Page *pages;
    extern size_t npage;

    size_t free_pages = 0;
    for (size_t i = 0; i < npage; i++) {
ffffffffc02007a6:	00016517          	auipc	a0,0x16
ffffffffc02007aa:	90a53503          	ld	a0,-1782(a0) # ffffffffc02160b0 <npage>
ffffffffc02007ae:	c505                	beqz	a0,ffffffffc02007d6 <slub_nr_free_pages+0x30>
ffffffffc02007b0:	00251693          	slli	a3,a0,0x2
ffffffffc02007b4:	96aa                	add	a3,a3,a0
ffffffffc02007b6:	00016717          	auipc	a4,0x16
ffffffffc02007ba:	90273703          	ld	a4,-1790(a4) # ffffffffc02160b8 <pages>
ffffffffc02007be:	068e                	slli	a3,a3,0x3
ffffffffc02007c0:	96ba                	add	a3,a3,a4
    size_t free_pages = 0;
ffffffffc02007c2:	4501                	li	a0,0
        if (!PageReserved(pages + i) && !PageProperty(pages + i)) {
ffffffffc02007c4:	671c                	ld	a5,8(a4)
    for (size_t i = 0; i < npage; i++) {
ffffffffc02007c6:	02870713          	addi	a4,a4,40
        if (!PageReserved(pages + i) && !PageProperty(pages + i)) {
ffffffffc02007ca:	8b8d                	andi	a5,a5,3
            free_pages++;
ffffffffc02007cc:	0017b793          	seqz	a5,a5
ffffffffc02007d0:	953e                	add	a0,a0,a5
    for (size_t i = 0; i < npage; i++) {
ffffffffc02007d2:	fed719e3          	bne	a4,a3,ffffffffc02007c4 <slub_nr_free_pages+0x1e>
        }
    }

    return free_pages;
}
ffffffffc02007d6:	8082                	ret

ffffffffc02007d8 <slub_init_memmap>:
void slub_init_memmap(struct Page *base, size_t n) {
ffffffffc02007d8:	1101                	addi	sp,sp,-32
ffffffffc02007da:	ec06                	sd	ra,24(sp)
ffffffffc02007dc:	e822                	sd	s0,16(sp)
ffffffffc02007de:	e426                	sd	s1,8(sp)
ffffffffc02007e0:	e04a                	sd	s2,0(sp)
    assert(n > 0);
ffffffffc02007e2:	cdc9                	beqz	a1,ffffffffc020087c <slub_init_memmap+0xa4>
    size_t info_size = n * sizeof(struct slub_page_info);
ffffffffc02007e4:	00259613          	slli	a2,a1,0x2
ffffffffc02007e8:	962e                	add	a2,a2,a1
    size_t info_pages = (info_size + PGSIZE - 1) / PGSIZE;
ffffffffc02007ea:	6905                	lui	s2,0x1
    size_t info_size = n * sizeof(struct slub_page_info);
ffffffffc02007ec:	060e                	slli	a2,a2,0x3
    size_t info_pages = (info_size + PGSIZE - 1) / PGSIZE;
ffffffffc02007ee:	197d                	addi	s2,s2,-1
    slub_allocator.max_pages = n;
ffffffffc02007f0:	00006797          	auipc	a5,0x6
ffffffffc02007f4:	82878793          	addi	a5,a5,-2008 # ffffffffc0206018 <slub_allocator>
    size_t info_pages = (info_size + PGSIZE - 1) / PGSIZE;
ffffffffc02007f8:	9932                	add	s2,s2,a2
    slub_allocator.max_pages = n;
ffffffffc02007fa:	ffac                	sd	a1,120(a5)
    size_t info_pages = (info_size + PGSIZE - 1) / PGSIZE;
ffffffffc02007fc:	00c95913          	srli	s2,s2,0xc
ffffffffc0200800:	84ae                	mv	s1,a1
    if (info_pages >= n) {
ffffffffc0200802:	08b97d63          	bgeu	s2,a1,ffffffffc020089c <slub_init_memmap+0xc4>
    slub_allocator.page_infos = (struct slub_page_info *)page2kva(base);
ffffffffc0200806:	842a                	mv	s0,a0
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200808:	00016517          	auipc	a0,0x16
ffffffffc020080c:	8b053503          	ld	a0,-1872(a0) # ffffffffc02160b8 <pages>
ffffffffc0200810:	40a40533          	sub	a0,s0,a0
ffffffffc0200814:	00002717          	auipc	a4,0x2
ffffffffc0200818:	12c73703          	ld	a4,300(a4) # ffffffffc0202940 <nbase+0x8>
ffffffffc020081c:	850d                	srai	a0,a0,0x3
ffffffffc020081e:	02e50533          	mul	a0,a0,a4
ffffffffc0200822:	00002717          	auipc	a4,0x2
ffffffffc0200826:	11673703          	ld	a4,278(a4) # ffffffffc0202938 <nbase>
    memset(slub_allocator.page_infos, 0, info_size);
ffffffffc020082a:	4581                	li	a1,0
ffffffffc020082c:	953a                	add	a0,a0,a4
    return page2ppn(page) << PGSHIFT;
ffffffffc020082e:	0532                	slli	a0,a0,0xc
    slub_allocator.page_infos = (struct slub_page_info *)page2kva(base);
ffffffffc0200830:	00016717          	auipc	a4,0x16
ffffffffc0200834:	8a873703          	ld	a4,-1880(a4) # ffffffffc02160d8 <va_pa_offset>
ffffffffc0200838:	953a                	add	a0,a0,a4
ffffffffc020083a:	fba8                	sd	a0,112(a5)
    memset(slub_allocator.page_infos, 0, info_size);
ffffffffc020083c:	242010ef          	jal	ra,ffffffffc0201a7e <memset>
    struct Page *p = base + info_pages;
ffffffffc0200840:	00291513          	slli	a0,s2,0x2
ffffffffc0200844:	954a                	add	a0,a0,s2
ffffffffc0200846:	050e                	slli	a0,a0,0x3
ffffffffc0200848:	9522                	add	a0,a0,s0
ffffffffc020084a:	874a                	mv	a4,s2
        ClearPageProperty(p);
ffffffffc020084c:	651c                	ld	a5,8(a0)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020084e:	00052023          	sw	zero,0(a0)
    for (size_t i = info_pages; i < n; i++, p++) {
ffffffffc0200852:	0705                	addi	a4,a4,1
        ClearPageProperty(p);
ffffffffc0200854:	9bf1                	andi	a5,a5,-4
ffffffffc0200856:	e51c                	sd	a5,8(a0)
    for (size_t i = info_pages; i < n; i++, p++) {
ffffffffc0200858:	02850513          	addi	a0,a0,40
ffffffffc020085c:	fee498e3          	bne	s1,a4,ffffffffc020084c <slub_init_memmap+0x74>
}
ffffffffc0200860:	6442                	ld	s0,16(sp)
ffffffffc0200862:	60e2                	ld	ra,24(sp)
    cprintf("SLUB memmap initialized: %u pages, %u info pages\n", (unsigned int)n, (unsigned int)info_pages);
ffffffffc0200864:	0009061b          	sext.w	a2,s2
ffffffffc0200868:	0004859b          	sext.w	a1,s1
}
ffffffffc020086c:	6902                	ld	s2,0(sp)
ffffffffc020086e:	64a2                	ld	s1,8(sp)
    cprintf("SLUB memmap initialized: %u pages, %u info pages\n", (unsigned int)n, (unsigned int)info_pages);
ffffffffc0200870:	00001517          	auipc	a0,0x1
ffffffffc0200874:	67050513          	addi	a0,a0,1648 # ffffffffc0201ee0 <etext+0x410>
}
ffffffffc0200878:	6105                	addi	sp,sp,32
    cprintf("SLUB memmap initialized: %u pages, %u info pages\n", (unsigned int)n, (unsigned int)info_pages);
ffffffffc020087a:	b8c9                	j	ffffffffc020014c <cprintf>
    assert(n > 0);
ffffffffc020087c:	00001697          	auipc	a3,0x1
ffffffffc0200880:	5fc68693          	addi	a3,a3,1532 # ffffffffc0201e78 <etext+0x3a8>
ffffffffc0200884:	00001617          	auipc	a2,0x1
ffffffffc0200888:	5fc60613          	addi	a2,a2,1532 # ffffffffc0201e80 <etext+0x3b0>
ffffffffc020088c:	04300593          	li	a1,67
ffffffffc0200890:	00001517          	auipc	a0,0x1
ffffffffc0200894:	60850513          	addi	a0,a0,1544 # ffffffffc0201e98 <etext+0x3c8>
ffffffffc0200898:	92bff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("Not enough memory for SLUB page info array");
ffffffffc020089c:	00001617          	auipc	a2,0x1
ffffffffc02008a0:	61460613          	addi	a2,a2,1556 # ffffffffc0201eb0 <etext+0x3e0>
ffffffffc02008a4:	04e00593          	li	a1,78
ffffffffc02008a8:	00001517          	auipc	a0,0x1
ffffffffc02008ac:	5f050513          	addi	a0,a0,1520 # ffffffffc0201e98 <etext+0x3c8>
ffffffffc02008b0:	913ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02008b4 <slub_alloc_pages>:
    assert(n > 0);
ffffffffc02008b4:	c151                	beqz	a0,ffffffffc0200938 <slub_alloc_pages+0x84>
    for (size_t i = 0; i < npage; i++, p++) {
ffffffffc02008b6:	00015597          	auipc	a1,0x15
ffffffffc02008ba:	7fa5b583          	ld	a1,2042(a1) # ffffffffc02160b0 <npage>
ffffffffc02008be:	882a                	mv	a6,a0
    struct Page *p = pages;
ffffffffc02008c0:	00015517          	auipc	a0,0x15
ffffffffc02008c4:	7f853503          	ld	a0,2040(a0) # ffffffffc02160b8 <pages>
    for (size_t i = 0; i < npage; i++, p++) {
ffffffffc02008c8:	c5b5                	beqz	a1,ffffffffc0200934 <slub_alloc_pages+0x80>
ffffffffc02008ca:	4601                	li	a2,0
ffffffffc02008cc:	a031                	j	ffffffffc02008d8 <slub_alloc_pages+0x24>
ffffffffc02008ce:	0605                	addi	a2,a2,1
ffffffffc02008d0:	02850513          	addi	a0,a0,40
ffffffffc02008d4:	06b60063          	beq	a2,a1,ffffffffc0200934 <slub_alloc_pages+0x80>
        if (PageReserved(p) || PageProperty(p)) {
ffffffffc02008d8:	00853883          	ld	a7,8(a0)
ffffffffc02008dc:	832a                	mv	t1,a0
ffffffffc02008de:	86aa                	mv	a3,a0
ffffffffc02008e0:	0038f793          	andi	a5,a7,3
ffffffffc02008e4:	f7ed                	bnez	a5,ffffffffc02008ce <slub_alloc_pages+0x1a>
        for (size_t j = 0; j < n && (i + j) < npage; j++) {
ffffffffc02008e6:	00f60733          	add	a4,a2,a5
ffffffffc02008ea:	02b77e63          	bgeu	a4,a1,ffffffffc0200926 <slub_alloc_pages+0x72>
            if (PageReserved(found + j) || PageProperty(found + j)) {
ffffffffc02008ee:	6698                	ld	a4,8(a3)
ffffffffc02008f0:	8b0d                	andi	a4,a4,3
ffffffffc02008f2:	eb15                	bnez	a4,ffffffffc0200926 <slub_alloc_pages+0x72>
            count++;
ffffffffc02008f4:	0785                	addi	a5,a5,1
        for (size_t j = 0; j < n && (i + j) < npage; j++) {
ffffffffc02008f6:	02868693          	addi	a3,a3,40
ffffffffc02008fa:	fef816e3          	bne	a6,a5,ffffffffc02008e6 <slub_alloc_pages+0x32>
ffffffffc02008fe:	00281793          	slli	a5,a6,0x2
ffffffffc0200902:	97c2                	add	a5,a5,a6
ffffffffc0200904:	078e                	slli	a5,a5,0x3
ffffffffc0200906:	97aa                	add	a5,a5,a0
ffffffffc0200908:	4705                	li	a4,1
ffffffffc020090a:	a019                	j	ffffffffc0200910 <slub_alloc_pages+0x5c>
            SetPageReserved(page + i);
ffffffffc020090c:	00833883          	ld	a7,8(t1)
ffffffffc0200910:	0018e893          	ori	a7,a7,1
ffffffffc0200914:	01133423          	sd	a7,8(t1)
ffffffffc0200918:	00e32023          	sw	a4,0(t1)
        for (size_t i = 0; i < n; i++) {
ffffffffc020091c:	02830313          	addi	t1,t1,40
ffffffffc0200920:	fef316e3          	bne	t1,a5,ffffffffc020090c <slub_alloc_pages+0x58>
}
ffffffffc0200924:	8082                	ret
        if (count >= n) {
ffffffffc0200926:	fd07fce3          	bgeu	a5,a6,ffffffffc02008fe <slub_alloc_pages+0x4a>
    for (size_t i = 0; i < npage; i++, p++) {
ffffffffc020092a:	0605                	addi	a2,a2,1
ffffffffc020092c:	02850513          	addi	a0,a0,40
ffffffffc0200930:	fab614e3          	bne	a2,a1,ffffffffc02008d8 <slub_alloc_pages+0x24>
    struct Page *page = NULL;
ffffffffc0200934:	4501                	li	a0,0
}
ffffffffc0200936:	8082                	ret
struct Page *slub_alloc_pages(size_t n) {
ffffffffc0200938:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020093a:	00001697          	auipc	a3,0x1
ffffffffc020093e:	53e68693          	addi	a3,a3,1342 # ffffffffc0201e78 <etext+0x3a8>
ffffffffc0200942:	00001617          	auipc	a2,0x1
ffffffffc0200946:	53e60613          	addi	a2,a2,1342 # ffffffffc0201e80 <etext+0x3b0>
ffffffffc020094a:	06400593          	li	a1,100
ffffffffc020094e:	00001517          	auipc	a0,0x1
ffffffffc0200952:	54a50513          	addi	a0,a0,1354 # ffffffffc0201e98 <etext+0x3c8>
struct Page *slub_alloc_pages(size_t n) {
ffffffffc0200956:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200958:	86bff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc020095c <slub_free_pages>:
void slub_free_pages(struct Page *base, size_t n) {
ffffffffc020095c:	1141                	addi	sp,sp,-16
ffffffffc020095e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200960:	c5bd                	beqz	a1,ffffffffc02009ce <slub_free_pages+0x72>
    assert(PageReserved(base));
ffffffffc0200962:	651c                	ld	a5,8(a0)
    for (size_t i = 0; i < n; i++) {
ffffffffc0200964:	4701                	li	a4,0
    assert(PageReserved(base));
ffffffffc0200966:	0017f693          	andi	a3,a5,1
ffffffffc020096a:	ea81                	bnez	a3,ffffffffc020097a <slub_free_pages+0x1e>
ffffffffc020096c:	a089                	j	ffffffffc02009ae <slub_free_pages+0x52>
        assert(PageReserved(p));
ffffffffc020096e:	791c                	ld	a5,48(a0)
ffffffffc0200970:	02850513          	addi	a0,a0,40
ffffffffc0200974:	0017f693          	andi	a3,a5,1
ffffffffc0200978:	ca99                	beqz	a3,ffffffffc020098e <slub_free_pages+0x32>
        ClearPageSlab(p);
ffffffffc020097a:	9be9                	andi	a5,a5,-6
ffffffffc020097c:	e51c                	sd	a5,8(a0)
ffffffffc020097e:	00052023          	sw	zero,0(a0)
    for (size_t i = 0; i < n; i++) {
ffffffffc0200982:	0705                	addi	a4,a4,1
ffffffffc0200984:	fee595e3          	bne	a1,a4,ffffffffc020096e <slub_free_pages+0x12>
}
ffffffffc0200988:	60a2                	ld	ra,8(sp)
ffffffffc020098a:	0141                	addi	sp,sp,16
ffffffffc020098c:	8082                	ret
        assert(PageReserved(p));
ffffffffc020098e:	00001697          	auipc	a3,0x1
ffffffffc0200992:	5a268693          	addi	a3,a3,1442 # ffffffffc0201f30 <etext+0x460>
ffffffffc0200996:	00001617          	auipc	a2,0x1
ffffffffc020099a:	4ea60613          	addi	a2,a2,1258 # ffffffffc0201e80 <etext+0x3b0>
ffffffffc020099e:	09700593          	li	a1,151
ffffffffc02009a2:	00001517          	auipc	a0,0x1
ffffffffc02009a6:	4f650513          	addi	a0,a0,1270 # ffffffffc0201e98 <etext+0x3c8>
ffffffffc02009aa:	819ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(PageReserved(base));
ffffffffc02009ae:	00001697          	auipc	a3,0x1
ffffffffc02009b2:	56a68693          	addi	a3,a3,1386 # ffffffffc0201f18 <etext+0x448>
ffffffffc02009b6:	00001617          	auipc	a2,0x1
ffffffffc02009ba:	4ca60613          	addi	a2,a2,1226 # ffffffffc0201e80 <etext+0x3b0>
ffffffffc02009be:	09300593          	li	a1,147
ffffffffc02009c2:	00001517          	auipc	a0,0x1
ffffffffc02009c6:	4d650513          	addi	a0,a0,1238 # ffffffffc0201e98 <etext+0x3c8>
ffffffffc02009ca:	ff8ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc02009ce:	00001697          	auipc	a3,0x1
ffffffffc02009d2:	4aa68693          	addi	a3,a3,1194 # ffffffffc0201e78 <etext+0x3a8>
ffffffffc02009d6:	00001617          	auipc	a2,0x1
ffffffffc02009da:	4aa60613          	addi	a2,a2,1194 # ffffffffc0201e80 <etext+0x3b0>
ffffffffc02009de:	09200593          	li	a1,146
ffffffffc02009e2:	00001517          	auipc	a0,0x1
ffffffffc02009e6:	4b650513          	addi	a0,a0,1206 # ffffffffc0201e98 <etext+0x3c8>
ffffffffc02009ea:	fd8ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02009ee <slub_free.part.0>:
}

/**
 * Free object to SLUB cache
 */
void slub_free(void *ptr, size_t size) {
ffffffffc02009ee:	1101                	addi	sp,sp,-32
ffffffffc02009f0:	e426                	sd	s1,8(sp)
ffffffffc02009f2:	ec06                	sd	ra,24(sp)
ffffffffc02009f4:	e822                	sd	s0,16(sp)
ffffffffc02009f6:	e04a                	sd	s2,0(sp)
    return NULL;
}

// 内联函数：根据大小计算size class索引
static inline int size_to_index(size_t size) {
    if (size <= SLUB_MIN_SIZE) return 0;
ffffffffc02009f8:	47a1                	li	a5,8
ffffffffc02009fa:	84aa                	mv	s1,a0
ffffffffc02009fc:	02b7f463          	bgeu	a5,a1,ffffffffc0200a24 <slub_free.part.0+0x36>
    if (size > SLUB_MAX_SIZE) return -1;
ffffffffc0200a00:	6785                	lui	a5,0x1
ffffffffc0200a02:	00b7eb63          	bltu	a5,a1,ffffffffc0200a18 <slub_free.part.0+0x2a>

    // 计算需要的2的幂次
    int shift = 0;
    size_t temp = size - 1;
ffffffffc0200a06:	15fd                	addi	a1,a1,-1
    int shift = 0;
ffffffffc0200a08:	4781                	li	a5,0
    while (temp > 0) {
        temp >>= 1;
ffffffffc0200a0a:	8185                	srli	a1,a1,0x1
        shift++;
ffffffffc0200a0c:	873e                	mv	a4,a5
ffffffffc0200a0e:	2785                	addiw	a5,a5,1
    while (temp > 0) {
ffffffffc0200a10:	fded                	bnez	a1,ffffffffc0200a0a <slub_free.part.0+0x1c>
    }

    return shift - SLUB_SHIFT_LOW;
ffffffffc0200a12:	3779                	addiw	a4,a4,-2
    if (!ptr || size == 0) return;
    if (size > SLUB_MAX_SIZE) return;

    // Find appropriate cache
    int index = size_to_index(size);
    if (index < 0) return;
ffffffffc0200a14:	00075963          	bgez	a4,ffffffffc0200a26 <slub_free.part.0+0x38>
    }

    slub_allocator.total_frees++;
    cache->nr_frees++;
    cache->nr_free++;
}
ffffffffc0200a18:	60e2                	ld	ra,24(sp)
ffffffffc0200a1a:	6442                	ld	s0,16(sp)
ffffffffc0200a1c:	64a2                	ld	s1,8(sp)
ffffffffc0200a1e:	6902                	ld	s2,0(sp)
ffffffffc0200a20:	6105                	addi	sp,sp,32
ffffffffc0200a22:	8082                	ret
    if (size <= SLUB_MIN_SIZE) return 0;
ffffffffc0200a24:	4701                	li	a4,0
    struct slub_cache *cache = slub_allocator.size_caches[index];
ffffffffc0200a26:	00005917          	auipc	s2,0x5
ffffffffc0200a2a:	5f290913          	addi	s2,s2,1522 # ffffffffc0206018 <slub_allocator>
ffffffffc0200a2e:	070e                	slli	a4,a4,0x3
ffffffffc0200a30:	974a                	add	a4,a4,s2
ffffffffc0200a32:	6300                	ld	s0,0(a4)
    if (!cache) return;
ffffffffc0200a34:	d075                	beqz	s0,ffffffffc0200a18 <slub_free.part.0+0x2a>
    if (cache->cpu_cache.avail < cache->cpu_cache.limit) {
ffffffffc0200a36:	5810                	lw	a2,48(s0)
ffffffffc0200a38:	585c                	lw	a5,52(s0)
        cache->cpu_cache.freelist[cache->cpu_cache.avail] = ptr;
ffffffffc0200a3a:	7008                	ld	a0,32(s0)
    if (cache->cpu_cache.avail < cache->cpu_cache.limit) {
ffffffffc0200a3c:	02f67b63          	bgeu	a2,a5,ffffffffc0200a72 <slub_free.part.0+0x84>
        cache->cpu_cache.freelist[cache->cpu_cache.avail] = ptr;
ffffffffc0200a40:	02061713          	slli	a4,a2,0x20
ffffffffc0200a44:	01d75793          	srli	a5,a4,0x1d
ffffffffc0200a48:	953e                	add	a0,a0,a5
ffffffffc0200a4a:	e104                	sd	s1,0(a0)
        cache->cpu_cache.avail++;
ffffffffc0200a4c:	2605                	addiw	a2,a2,1
ffffffffc0200a4e:	d810                	sw	a2,48(s0)
    slub_allocator.total_frees++;
ffffffffc0200a50:	05893683          	ld	a3,88(s2)
    cache->nr_free++;
ffffffffc0200a54:	6c3c                	ld	a5,88(s0)
    cache->nr_frees++;
ffffffffc0200a56:	7438                	ld	a4,104(s0)
    slub_allocator.total_frees++;
ffffffffc0200a58:	0685                	addi	a3,a3,1
ffffffffc0200a5a:	04d93c23          	sd	a3,88(s2)
    cache->nr_frees++;
ffffffffc0200a5e:	0705                	addi	a4,a4,1
    cache->nr_free++;
ffffffffc0200a60:	0785                	addi	a5,a5,1
}
ffffffffc0200a62:	60e2                	ld	ra,24(sp)
    cache->nr_frees++;
ffffffffc0200a64:	f438                	sd	a4,104(s0)
    cache->nr_free++;
ffffffffc0200a66:	ec3c                	sd	a5,88(s0)
}
ffffffffc0200a68:	6442                	ld	s0,16(sp)
ffffffffc0200a6a:	64a2                	ld	s1,8(sp)
ffffffffc0200a6c:	6902                	ld	s2,0(sp)
ffffffffc0200a6e:	6105                	addi	sp,sp,32
ffffffffc0200a70:	8082                	ret
               (cache->cpu_cache.avail - 1) * sizeof(void*));
ffffffffc0200a72:	367d                	addiw	a2,a2,-1
        memmove(&cache->cpu_cache.freelist[0], &cache->cpu_cache.freelist[1],
ffffffffc0200a74:	02061793          	slli	a5,a2,0x20
ffffffffc0200a78:	01d7d613          	srli	a2,a5,0x1d
ffffffffc0200a7c:	00850593          	addi	a1,a0,8
ffffffffc0200a80:	010010ef          	jal	ra,ffffffffc0201a90 <memmove>
        cache->cpu_cache.freelist[cache->cpu_cache.avail - 1] = ptr;
ffffffffc0200a84:	581c                	lw	a5,48(s0)
ffffffffc0200a86:	7018                	ld	a4,32(s0)
ffffffffc0200a88:	37fd                	addiw	a5,a5,-1
ffffffffc0200a8a:	02079693          	slli	a3,a5,0x20
ffffffffc0200a8e:	01d6d793          	srli	a5,a3,0x1d
ffffffffc0200a92:	97ba                	add	a5,a5,a4
ffffffffc0200a94:	e384                	sd	s1,0(a5)
ffffffffc0200a96:	bf6d                	j	ffffffffc0200a50 <slub_free.part.0+0x62>

ffffffffc0200a98 <slub_alloc.part.0>:
ffffffffc0200a98:	47a1                	li	a5,8
ffffffffc0200a9a:	16a7fa63          	bgeu	a5,a0,ffffffffc0200c0e <slub_alloc.part.0+0x176>
    if (size > SLUB_MAX_SIZE) return -1;
ffffffffc0200a9e:	6785                	lui	a5,0x1
ffffffffc0200aa0:	18a7eb63          	bltu	a5,a0,ffffffffc0200c36 <slub_alloc.part.0+0x19e>
    size_t temp = size - 1;
ffffffffc0200aa4:	157d                	addi	a0,a0,-1
    int shift = 0;
ffffffffc0200aa6:	4781                	li	a5,0
        temp >>= 1;
ffffffffc0200aa8:	8105                	srli	a0,a0,0x1
        shift++;
ffffffffc0200aaa:	873e                	mv	a4,a5
ffffffffc0200aac:	2785                	addiw	a5,a5,1
    while (temp > 0) {
ffffffffc0200aae:	fd6d                	bnez	a0,ffffffffc0200aa8 <slub_alloc.part.0+0x10>
    return shift - SLUB_SHIFT_LOW;
ffffffffc0200ab0:	3779                	addiw	a4,a4,-2
    if (index < 0) return NULL;
ffffffffc0200ab2:	18074263          	bltz	a4,ffffffffc0200c36 <slub_alloc.part.0+0x19e>
void *slub_alloc(size_t size) {
ffffffffc0200ab6:	7179                	addi	sp,sp,-48
ffffffffc0200ab8:	ec26                	sd	s1,24(sp)
    struct slub_cache *cache = slub_allocator.size_caches[index];
ffffffffc0200aba:	070e                	slli	a4,a4,0x3
ffffffffc0200abc:	00005497          	auipc	s1,0x5
ffffffffc0200ac0:	55c48493          	addi	s1,s1,1372 # ffffffffc0206018 <slub_allocator>
ffffffffc0200ac4:	9726                	add	a4,a4,s1
void *slub_alloc(size_t size) {
ffffffffc0200ac6:	f022                	sd	s0,32(sp)
    struct slub_cache *cache = slub_allocator.size_caches[index];
ffffffffc0200ac8:	6300                	ld	s0,0(a4)
void *slub_alloc(size_t size) {
ffffffffc0200aca:	f406                	sd	ra,40(sp)
ffffffffc0200acc:	e84a                	sd	s2,16(sp)
ffffffffc0200ace:	e44e                	sd	s3,8(sp)
    if (!cache) return NULL;
ffffffffc0200ad0:	12040763          	beqz	s0,ffffffffc0200bfe <slub_alloc.part.0+0x166>
    if (cache->cpu_cache.avail > 0) {
ffffffffc0200ad4:	03042903          	lw	s2,48(s0)
ffffffffc0200ad8:	12091d63          	bnez	s2,ffffffffc0200c12 <slub_alloc.part.0+0x17a>
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
ffffffffc0200adc:	6038                	ld	a4,64(s0)
    if (!list_empty(&cache->partial_list)) {
ffffffffc0200ade:	03840993          	addi	s3,s0,56
ffffffffc0200ae2:	06e98163          	beq	s3,a4,ffffffffc0200b44 <slub_alloc.part.0+0xac>
        size_t info_index = info - slub_allocator.page_infos;
ffffffffc0200ae6:	78b4                	ld	a3,112(s1)
        struct slub_page_info *info = to_struct(le, struct slub_page_info, slab_list);
ffffffffc0200ae8:	fe870793          	addi	a5,a4,-24
        size_t info_index = info - slub_allocator.page_infos;
ffffffffc0200aec:	8f95                	sub	a5,a5,a3
    size_t page_idx = page - pages;
ffffffffc0200aee:	878d                	srai	a5,a5,0x3
ffffffffc0200af0:	00002697          	auipc	a3,0x2
ffffffffc0200af4:	e506b683          	ld	a3,-432(a3) # ffffffffc0202940 <nbase+0x8>
ffffffffc0200af8:	02d787b3          	mul	a5,a5,a3
    if (page_idx < slub_allocator.max_pages) {
ffffffffc0200afc:	7cb4                	ld	a3,120(s1)
ffffffffc0200afe:	04d7f363          	bgeu	a5,a3,ffffffffc0200b44 <slub_alloc.part.0+0xac>
    }
}

static void *get_object_from_page(struct Page *page, struct slub_cache *cache) {
    struct slub_page_info *info = page_to_slub_info(page);
    if (!info || !info->freelist) return NULL;
ffffffffc0200b02:	fe873503          	ld	a0,-24(a4)
ffffffffc0200b06:	cd1d                	beqz	a0,ffffffffc0200b44 <slub_alloc.part.0+0xac>
            info->inuse++;
ffffffffc0200b08:	ff072783          	lw	a5,-16(a4)

    void *obj = info->freelist;
    info->freelist = *(void**)obj;
ffffffffc0200b0c:	6114                	ld	a3,0(a0)
            if (info->inuse >= info->objects) {
ffffffffc0200b0e:	ff472603          	lw	a2,-12(a4)
            info->inuse++;
ffffffffc0200b12:	2785                	addiw	a5,a5,1
    info->freelist = *(void**)obj;
ffffffffc0200b14:	fed73423          	sd	a3,-24(a4)
            info->inuse++;
ffffffffc0200b18:	fef72823          	sw	a5,-16(a4)
ffffffffc0200b1c:	0007869b          	sext.w	a3,a5
            if (info->inuse >= info->objects) {
ffffffffc0200b20:	10c6fd63          	bgeu	a3,a2,ffffffffc0200c3a <slub_alloc.part.0+0x1a2>
        slub_allocator.total_allocs++;
ffffffffc0200b24:	68b4                	ld	a3,80(s1)
        cache->nr_allocs++;
ffffffffc0200b26:	7038                	ld	a4,96(s0)
        cache->nr_free--;
ffffffffc0200b28:	6c3c                	ld	a5,88(s0)
        slub_allocator.total_allocs++;
ffffffffc0200b2a:	0685                	addi	a3,a3,1
        cache->nr_allocs++;
ffffffffc0200b2c:	0705                	addi	a4,a4,1
        cache->nr_free--;
ffffffffc0200b2e:	17fd                	addi	a5,a5,-1
}
ffffffffc0200b30:	70a2                	ld	ra,40(sp)
        cache->nr_allocs++;
ffffffffc0200b32:	f038                	sd	a4,96(s0)
        cache->nr_free--;
ffffffffc0200b34:	ec3c                	sd	a5,88(s0)
}
ffffffffc0200b36:	7402                	ld	s0,32(sp)
        slub_allocator.total_allocs++;
ffffffffc0200b38:	e8b4                	sd	a3,80(s1)
}
ffffffffc0200b3a:	6942                	ld	s2,16(sp)
ffffffffc0200b3c:	64e2                	ld	s1,24(sp)
ffffffffc0200b3e:	69a2                	ld	s3,8(sp)
ffffffffc0200b40:	6145                	addi	sp,sp,48
ffffffffc0200b42:	8082                	ret
    struct Page *page = slub_alloc_pages(1);
ffffffffc0200b44:	4505                	li	a0,1
ffffffffc0200b46:	d6fff0ef          	jal	ra,ffffffffc02008b4 <slub_alloc_pages>
    if (!page) return NULL;
ffffffffc0200b4a:	c955                	beqz	a0,ffffffffc0200bfe <slub_alloc.part.0+0x166>
    size_t page_idx = page - pages;
ffffffffc0200b4c:	00015817          	auipc	a6,0x15
ffffffffc0200b50:	56c80813          	addi	a6,a6,1388 # ffffffffc02160b8 <pages>
ffffffffc0200b54:	00083783          	ld	a5,0(a6)
ffffffffc0200b58:	00002597          	auipc	a1,0x2
ffffffffc0200b5c:	de85b583          	ld	a1,-536(a1) # ffffffffc0202940 <nbase+0x8>
    SetPageSlab(page);
ffffffffc0200b60:	6518                	ld	a4,8(a0)
ffffffffc0200b62:	40f506b3          	sub	a3,a0,a5
ffffffffc0200b66:	4036d793          	srai	a5,a3,0x3
ffffffffc0200b6a:	02b787b3          	mul	a5,a5,a1
    if (page_idx < slub_allocator.max_pages) {
ffffffffc0200b6e:	7cb0                	ld	a2,120(s1)
ffffffffc0200b70:	00476713          	ori	a4,a4,4
ffffffffc0200b74:	e518                	sd	a4,8(a0)
ffffffffc0200b76:	0cc7f763          	bgeu	a5,a2,ffffffffc0200c44 <slub_alloc.part.0+0x1ac>
        return &slub_allocator.page_infos[page_idx];
ffffffffc0200b7a:	78b8                	ld	a4,112(s1)
ffffffffc0200b7c:	9736                	add	a4,a4,a3
    if (info) {
ffffffffc0200b7e:	cb79                	beqz	a4,ffffffffc0200c54 <slub_alloc.part.0+0x1bc>
        info->objects = cache->objects_per_slab;
ffffffffc0200b80:	01842883          	lw	a7,24(s0)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200b84:	04043303          	ld	t1,64(s0)
        list_add(&cache->partial_list, &info->slab_list);
ffffffffc0200b88:	01870e13          	addi	t3,a4,24
        info->cache = cache;
ffffffffc0200b8c:	eb00                	sd	s0,16(a4)
        info->objects = cache->objects_per_slab;
ffffffffc0200b8e:	01172623          	sw	a7,12(a4)
        info->inuse = 0;
ffffffffc0200b92:	00072423          	sw	zero,8(a4)
        info->freelist = NULL;
ffffffffc0200b96:	00073023          	sd	zero,0(a4)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200b9a:	01c33023          	sd	t3,0(t1)
ffffffffc0200b9e:	05c43023          	sd	t3,64(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ba2:	00002e17          	auipc	t3,0x2
ffffffffc0200ba6:	d96e3e03          	ld	t3,-618(t3) # ffffffffc0202938 <nbase>
ffffffffc0200baa:	97f2                	add	a5,a5,t3
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bac:	07b2                	slli	a5,a5,0xc
    elm->next = next;
ffffffffc0200bae:	02673023          	sd	t1,32(a4)
    elm->prev = prev;
ffffffffc0200bb2:	01373c23          	sd	s3,24(a4)
    void *addr = page2kva(page);
ffffffffc0200bb6:	00015317          	auipc	t1,0x15
ffffffffc0200bba:	52233303          	ld	t1,1314(t1) # ffffffffc02160d8 <va_pa_offset>
ffffffffc0200bbe:	979a                	add	a5,a5,t1
    for (unsigned int i = 0; i < cache->objects_per_slab; i++) {
ffffffffc0200bc0:	08088a63          	beqz	a7,ffffffffc0200c54 <slub_alloc.part.0+0x1bc>
        void *obj = (char*)addr + i * cache->object_size;
ffffffffc0200bc4:	00843303          	ld	t1,8(s0)
        *(void**)obj = *freelist;
ffffffffc0200bc8:	6314                	ld	a3,0(a4)
ffffffffc0200bca:	e394                	sd	a3,0(a5)
        *freelist = obj;
ffffffffc0200bcc:	e31c                	sd	a5,0(a4)
    for (unsigned int i = 0; i < cache->objects_per_slab; i++) {
ffffffffc0200bce:	2905                	addiw	s2,s2,1
        void *obj = (char*)addr + i * cache->object_size;
ffffffffc0200bd0:	86be                	mv	a3,a5
    for (unsigned int i = 0; i < cache->objects_per_slab; i++) {
ffffffffc0200bd2:	979a                	add	a5,a5,t1
ffffffffc0200bd4:	ff289be3          	bne	a7,s2,ffffffffc0200bca <slub_alloc.part.0+0x132>
    size_t page_idx = page - pages;
ffffffffc0200bd8:	00083783          	ld	a5,0(a6)
    cache->nr_slabs++;
ffffffffc0200bdc:	04843803          	ld	a6,72(s0)
    slub_allocator.nr_slabs++;
ffffffffc0200be0:	74b8                	ld	a4,104(s1)
ffffffffc0200be2:	40f506b3          	sub	a3,a0,a5
ffffffffc0200be6:	4036d793          	srai	a5,a3,0x3
ffffffffc0200bea:	02b785b3          	mul	a1,a5,a1
    cache->nr_slabs++;
ffffffffc0200bee:	00180793          	addi	a5,a6,1
ffffffffc0200bf2:	e43c                	sd	a5,72(s0)
    slub_allocator.nr_slabs++;
ffffffffc0200bf4:	00170793          	addi	a5,a4,1
ffffffffc0200bf8:	f4bc                	sd	a5,104(s1)
    if (page_idx < slub_allocator.max_pages) {
ffffffffc0200bfa:	06c5e363          	bltu	a1,a2,ffffffffc0200c60 <slub_alloc.part.0+0x1c8>
    if (index < 0) return NULL;
ffffffffc0200bfe:	4501                	li	a0,0
}
ffffffffc0200c00:	70a2                	ld	ra,40(sp)
ffffffffc0200c02:	7402                	ld	s0,32(sp)
ffffffffc0200c04:	64e2                	ld	s1,24(sp)
ffffffffc0200c06:	6942                	ld	s2,16(sp)
ffffffffc0200c08:	69a2                	ld	s3,8(sp)
ffffffffc0200c0a:	6145                	addi	sp,sp,48
ffffffffc0200c0c:	8082                	ret
    if (size <= SLUB_MIN_SIZE) return 0;
ffffffffc0200c0e:	4701                	li	a4,0
ffffffffc0200c10:	b55d                	j	ffffffffc0200ab6 <slub_alloc.part.0+0x1e>
        slub_allocator.cache_hits++;
ffffffffc0200c12:	70b0                	ld	a2,96(s1)
        obj = cache->cpu_cache.freelist[cache->cpu_cache.avail];
ffffffffc0200c14:	700c                	ld	a1,32(s0)
        cache->cpu_cache.avail--;
ffffffffc0200c16:	397d                	addiw	s2,s2,-1
        slub_allocator.total_allocs++;
ffffffffc0200c18:	68b4                	ld	a3,80(s1)
        obj = cache->cpu_cache.freelist[cache->cpu_cache.avail];
ffffffffc0200c1a:	02091813          	slli	a6,s2,0x20
ffffffffc0200c1e:	01d85513          	srli	a0,a6,0x1d
        cache->cpu_cache.avail--;
ffffffffc0200c22:	03242823          	sw	s2,48(s0)
        obj = cache->cpu_cache.freelist[cache->cpu_cache.avail];
ffffffffc0200c26:	95aa                	add	a1,a1,a0
        slub_allocator.cache_hits++;
ffffffffc0200c28:	0605                	addi	a2,a2,1
        cache->nr_allocs++;
ffffffffc0200c2a:	7038                	ld	a4,96(s0)
        cache->nr_free--;
ffffffffc0200c2c:	6c3c                	ld	a5,88(s0)
        obj = cache->cpu_cache.freelist[cache->cpu_cache.avail];
ffffffffc0200c2e:	6188                	ld	a0,0(a1)
        slub_allocator.total_allocs++;
ffffffffc0200c30:	0685                	addi	a3,a3,1
        slub_allocator.cache_hits++;
ffffffffc0200c32:	f0b0                	sd	a2,96(s1)
        slub_allocator.total_allocs++;
ffffffffc0200c34:	bde5                	j	ffffffffc0200b2c <slub_alloc.part.0+0x94>
    if (index < 0) return NULL;
ffffffffc0200c36:	4501                	li	a0,0
}
ffffffffc0200c38:	8082                	ret
    __list_del(listelm->prev, listelm->next);
ffffffffc0200c3a:	6314                	ld	a3,0(a4)
ffffffffc0200c3c:	671c                	ld	a5,8(a4)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200c3e:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0200c40:	e394                	sd	a3,0(a5)
}
ffffffffc0200c42:	b5cd                	j	ffffffffc0200b24 <slub_alloc.part.0+0x8c>
    cache->nr_slabs++;
ffffffffc0200c44:	6438                	ld	a4,72(s0)
    slub_allocator.nr_slabs++;
ffffffffc0200c46:	74bc                	ld	a5,104(s1)
    if (index < 0) return NULL;
ffffffffc0200c48:	4501                	li	a0,0
    cache->nr_slabs++;
ffffffffc0200c4a:	0705                	addi	a4,a4,1
ffffffffc0200c4c:	e438                	sd	a4,72(s0)
    slub_allocator.nr_slabs++;
ffffffffc0200c4e:	0785                	addi	a5,a5,1
ffffffffc0200c50:	f4bc                	sd	a5,104(s1)
    if (page_idx < slub_allocator.max_pages) {
ffffffffc0200c52:	b77d                	j	ffffffffc0200c00 <slub_alloc.part.0+0x168>
    cache->nr_slabs++;
ffffffffc0200c54:	6438                	ld	a4,72(s0)
    slub_allocator.nr_slabs++;
ffffffffc0200c56:	74bc                	ld	a5,104(s1)
    cache->nr_slabs++;
ffffffffc0200c58:	0705                	addi	a4,a4,1
ffffffffc0200c5a:	e438                	sd	a4,72(s0)
    slub_allocator.nr_slabs++;
ffffffffc0200c5c:	0785                	addi	a5,a5,1
ffffffffc0200c5e:	f4bc                	sd	a5,104(s1)
        return &slub_allocator.page_infos[page_idx];
ffffffffc0200c60:	78bc                	ld	a5,112(s1)
ffffffffc0200c62:	97b6                	add	a5,a5,a3
    if (!info || !info->freelist) return NULL;
ffffffffc0200c64:	dfc9                	beqz	a5,ffffffffc0200bfe <slub_alloc.part.0+0x166>
ffffffffc0200c66:	6388                	ld	a0,0(a5)
ffffffffc0200c68:	d959                	beqz	a0,ffffffffc0200bfe <slub_alloc.part.0+0x166>
                info->inuse++;
ffffffffc0200c6a:	4798                	lw	a4,8(a5)
    info->freelist = *(void**)obj;
ffffffffc0200c6c:	6114                	ld	a3,0(a0)
                info->inuse++;
ffffffffc0200c6e:	2705                	addiw	a4,a4,1
    info->freelist = *(void**)obj;
ffffffffc0200c70:	e394                	sd	a3,0(a5)
                info->inuse++;
ffffffffc0200c72:	c798                	sw	a4,8(a5)
ffffffffc0200c74:	bd45                	j	ffffffffc0200b24 <slub_alloc.part.0+0x8c>

ffffffffc0200c76 <slub_stress_check>:

    cprintf("对齐测试通过!\n");
}

// 压力测试
static void slub_stress_check(void) {
ffffffffc0200c76:	97010113          	addi	sp,sp,-1680
    cprintf("=== SLUB 压力测试开始 ===\n");
ffffffffc0200c7a:	00001517          	auipc	a0,0x1
ffffffffc0200c7e:	2c650513          	addi	a0,a0,710 # ffffffffc0201f40 <etext+0x470>
static void slub_stress_check(void) {
ffffffffc0200c82:	68113423          	sd	ra,1672(sp)
ffffffffc0200c86:	68813023          	sd	s0,1664(sp)
ffffffffc0200c8a:	66913c23          	sd	s1,1656(sp)
ffffffffc0200c8e:	67213823          	sd	s2,1648(sp)
ffffffffc0200c92:	67313423          	sd	s3,1640(sp)
ffffffffc0200c96:	67413023          	sd	s4,1632(sp)
ffffffffc0200c9a:	65513c23          	sd	s5,1624(sp)
ffffffffc0200c9e:	65613823          	sd	s6,1616(sp)
ffffffffc0200ca2:	65713423          	sd	s7,1608(sp)
ffffffffc0200ca6:	65813023          	sd	s8,1600(sp)
    cprintf("=== SLUB 压力测试开始 ===\n");
ffffffffc0200caa:	ca2ff0ef          	jal	ra,ffffffffc020014c <cprintf>

    // Allocate many small objects
    cprintf("测试高频小对象分配...\n");
ffffffffc0200cae:	00001517          	auipc	a0,0x1
ffffffffc0200cb2:	2ba50513          	addi	a0,a0,698 # ffffffffc0201f68 <etext+0x498>
ffffffffc0200cb6:	1600                	addi	s0,sp,800
ffffffffc0200cb8:	c94ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200cbc:	8922                	mv	s2,s0
    void *small_ptrs[100];
    for (int i = 0; i < 100; i++) {
ffffffffc0200cbe:	4481                	li	s1,0
ffffffffc0200cc0:	06400993          	li	s3,100
ffffffffc0200cc4:	a029                	j	ffffffffc0200cce <slub_stress_check+0x58>
ffffffffc0200cc6:	2485                	addiw	s1,s1,1
ffffffffc0200cc8:	0921                	addi	s2,s2,8
ffffffffc0200cca:	01348f63          	beq	s1,s3,ffffffffc0200ce8 <slub_stress_check+0x72>
    if (size > SLUB_MAX_SIZE) return NULL;
ffffffffc0200cce:	4521                	li	a0,8
ffffffffc0200cd0:	dc9ff0ef          	jal	ra,ffffffffc0200a98 <slub_alloc.part.0>
        small_ptrs[i] = slub_alloc(8);
ffffffffc0200cd4:	00a93023          	sd	a0,0(s2)
        if (small_ptrs[i] == NULL) {
ffffffffc0200cd8:	f57d                	bnez	a0,ffffffffc0200cc6 <slub_stress_check+0x50>
            cprintf("第%d次分配失败 (内存耗尽时为正常现象)\n", i);
ffffffffc0200cda:	85a6                	mv	a1,s1
ffffffffc0200cdc:	00001517          	auipc	a0,0x1
ffffffffc0200ce0:	2ac50513          	addi	a0,a0,684 # ffffffffc0201f88 <etext+0x4b8>
ffffffffc0200ce4:	c68ff0ef          	jal	ra,ffffffffc020014c <cprintf>
            break;
ffffffffc0200ce8:	32040493          	addi	s1,s0,800
        }
    }

    // Free all
    for (int i = 0; i < 100; i++) {
        if (small_ptrs[i]) {
ffffffffc0200cec:	6008                	ld	a0,0(s0)
ffffffffc0200cee:	c501                	beqz	a0,ffffffffc0200cf6 <slub_stress_check+0x80>
    if (size > SLUB_MAX_SIZE) return;
ffffffffc0200cf0:	45a1                	li	a1,8
ffffffffc0200cf2:	cfdff0ef          	jal	ra,ffffffffc02009ee <slub_free.part.0>
    for (int i = 0; i < 100; i++) {
ffffffffc0200cf6:	0421                	addi	s0,s0,8
ffffffffc0200cf8:	fe849ae3          	bne	s1,s0,ffffffffc0200cec <slub_stress_check+0x76>
            slub_free(small_ptrs[i], 8);
        }
    }

    // Mixed size allocation test
    cprintf("测试混合大小分配...\n");
ffffffffc0200cfc:	00001517          	auipc	a0,0x1
ffffffffc0200d00:	2c450513          	addi	a0,a0,708 # ffffffffc0201fc0 <etext+0x4f0>
ffffffffc0200d04:	848a                	mv	s1,sp
ffffffffc0200d06:	19010913          	addi	s2,sp,400
ffffffffc0200d0a:	c42ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200d0e:	8aca                	mv	s5,s2
ffffffffc0200d10:	8a26                	mv	s4,s1
    void *mixed_ptrs[50];
    size_t mixed_sizes[50];

    for (int i = 0; i < 50; i++) {
ffffffffc0200d12:	4981                	li	s3,0
        // Alternate between different sizes
        size_t size = index_to_size(i % SLUB_NUM_SIZES);
ffffffffc0200d14:	4ba9                	li	s7,10
}

// 内联函数：根据索引计算对象大小
static inline size_t index_to_size(int index) {
    if (index < 0 || index >= SLUB_NUM_SIZES) return 0;
    return SLUB_MIN_SIZE << index;
ffffffffc0200d16:	4b21                	li	s6,8
    for (int i = 0; i < 50; i++) {
ffffffffc0200d18:	03200c13          	li	s8,50
        size_t size = index_to_size(i % SLUB_NUM_SIZES);
ffffffffc0200d1c:	0379e43b          	remw	s0,s3,s7
ffffffffc0200d20:	008b143b          	sllw	s0,s6,s0
    if (size > SLUB_MAX_SIZE) return NULL;
ffffffffc0200d24:	8522                	mv	a0,s0
ffffffffc0200d26:	d73ff0ef          	jal	ra,ffffffffc0200a98 <slub_alloc.part.0>
        mixed_ptrs[i] = slub_alloc(size);
ffffffffc0200d2a:	00aa3023          	sd	a0,0(s4)
        mixed_sizes[i] = size;
ffffffffc0200d2e:	008ab023          	sd	s0,0(s5)

        if (mixed_ptrs[i] == NULL) {
ffffffffc0200d32:	c959                	beqz	a0,ffffffffc0200dc8 <slub_stress_check+0x152>
            break;
        }

        // Write unique pattern
        if (mixed_ptrs[i]) {
            memset(mixed_ptrs[i], i & 0xFF, size);
ffffffffc0200d34:	0ff9f593          	zext.b	a1,s3
ffffffffc0200d38:	8622                	mv	a2,s0
    for (int i = 0; i < 50; i++) {
ffffffffc0200d3a:	2985                	addiw	s3,s3,1
            memset(mixed_ptrs[i], i & 0xFF, size);
ffffffffc0200d3c:	543000ef          	jal	ra,ffffffffc0201a7e <memset>
    for (int i = 0; i < 50; i++) {
ffffffffc0200d40:	0a21                	addi	s4,s4,8
ffffffffc0200d42:	0aa1                	addi	s5,s5,8
ffffffffc0200d44:	fd899ce3          	bne	s3,s8,ffffffffc0200d1c <slub_stress_check+0xa6>
ffffffffc0200d48:	4401                	li	s0,0
    if (size > SLUB_MAX_SIZE) return;
ffffffffc0200d4a:	6a05                	lui	s4,0x1
        }
    }

    // Verify patterns and free
    for (int i = 0; i < 50; i++) {
ffffffffc0200d4c:	03200993          	li	s3,50
ffffffffc0200d50:	a031                	j	ffffffffc0200d5c <slub_stress_check+0xe6>
ffffffffc0200d52:	2405                	addiw	s0,s0,1
ffffffffc0200d54:	04a1                	addi	s1,s1,8
ffffffffc0200d56:	0921                	addi	s2,s2,8
ffffffffc0200d58:	03340c63          	beq	s0,s3,ffffffffc0200d90 <slub_stress_check+0x11a>
        if (mixed_ptrs[i]) {
ffffffffc0200d5c:	6088                	ld	a0,0(s1)
ffffffffc0200d5e:	d975                	beqz	a0,ffffffffc0200d52 <slub_stress_check+0xdc>
            char *bytes = (char*)mixed_ptrs[i];
            for (size_t j = 0; j < mixed_sizes[i]; j++) {
ffffffffc0200d60:	00093583          	ld	a1,0(s2)
ffffffffc0200d64:	d5fd                	beqz	a1,ffffffffc0200d52 <slub_stress_check+0xdc>
ffffffffc0200d66:	87aa                	mv	a5,a0
ffffffffc0200d68:	00a58633          	add	a2,a1,a0
ffffffffc0200d6c:	0ff47693          	zext.b	a3,s0
                assert(bytes[j] == (char)(i & 0xFF));
ffffffffc0200d70:	0007c703          	lbu	a4,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0200d74:	06d71263          	bne	a4,a3,ffffffffc0200dd8 <slub_stress_check+0x162>
            for (size_t j = 0; j < mixed_sizes[i]; j++) {
ffffffffc0200d78:	0785                	addi	a5,a5,1
ffffffffc0200d7a:	fef61be3          	bne	a2,a5,ffffffffc0200d70 <slub_stress_check+0xfa>
    if (size > SLUB_MAX_SIZE) return;
ffffffffc0200d7e:	fcba6ae3          	bltu	s4,a1,ffffffffc0200d52 <slub_stress_check+0xdc>
    for (int i = 0; i < 50; i++) {
ffffffffc0200d82:	2405                	addiw	s0,s0,1
ffffffffc0200d84:	c6bff0ef          	jal	ra,ffffffffc02009ee <slub_free.part.0>
ffffffffc0200d88:	04a1                	addi	s1,s1,8
ffffffffc0200d8a:	0921                	addi	s2,s2,8
ffffffffc0200d8c:	fd3418e3          	bne	s0,s3,ffffffffc0200d5c <slub_stress_check+0xe6>
            slub_free(mixed_ptrs[i], mixed_sizes[i]);
        }
    }

    cprintf("压力测试通过!\n");
}
ffffffffc0200d90:	68013403          	ld	s0,1664(sp)
ffffffffc0200d94:	68813083          	ld	ra,1672(sp)
ffffffffc0200d98:	67813483          	ld	s1,1656(sp)
ffffffffc0200d9c:	67013903          	ld	s2,1648(sp)
ffffffffc0200da0:	66813983          	ld	s3,1640(sp)
ffffffffc0200da4:	66013a03          	ld	s4,1632(sp)
ffffffffc0200da8:	65813a83          	ld	s5,1624(sp)
ffffffffc0200dac:	65013b03          	ld	s6,1616(sp)
ffffffffc0200db0:	64813b83          	ld	s7,1608(sp)
ffffffffc0200db4:	64013c03          	ld	s8,1600(sp)
    cprintf("压力测试通过!\n");
ffffffffc0200db8:	00001517          	auipc	a0,0x1
ffffffffc0200dbc:	26850513          	addi	a0,a0,616 # ffffffffc0202020 <etext+0x550>
}
ffffffffc0200dc0:	69010113          	addi	sp,sp,1680
    cprintf("压力测试通过!\n");
ffffffffc0200dc4:	b88ff06f          	j	ffffffffc020014c <cprintf>
            cprintf("第%d次混合分配失败\n", i);
ffffffffc0200dc8:	85ce                	mv	a1,s3
ffffffffc0200dca:	00001517          	auipc	a0,0x1
ffffffffc0200dce:	21650513          	addi	a0,a0,534 # ffffffffc0201fe0 <etext+0x510>
ffffffffc0200dd2:	b7aff0ef          	jal	ra,ffffffffc020014c <cprintf>
            break;
ffffffffc0200dd6:	bf8d                	j	ffffffffc0200d48 <slub_stress_check+0xd2>
                assert(bytes[j] == (char)(i & 0xFF));
ffffffffc0200dd8:	00001697          	auipc	a3,0x1
ffffffffc0200ddc:	22868693          	addi	a3,a3,552 # ffffffffc0202000 <etext+0x530>
ffffffffc0200de0:	00001617          	auipc	a2,0x1
ffffffffc0200de4:	0a060613          	addi	a2,a2,160 # ffffffffc0201e80 <etext+0x3b0>
ffffffffc0200de8:	25d00593          	li	a1,605
ffffffffc0200dec:	00001517          	auipc	a0,0x1
ffffffffc0200df0:	0ac50513          	addi	a0,a0,172 # ffffffffc0201e98 <etext+0x3c8>
ffffffffc0200df4:	bceff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200df8 <slub_cache_create>:
struct slub_cache *slub_cache_create(const char *name, size_t size, size_t align) {
ffffffffc0200df8:	7139                	addi	sp,sp,-64
ffffffffc0200dfa:	f04a                	sd	s2,32(sp)
    if (heap_used + size > sizeof(static_heap)) {
ffffffffc0200dfc:	00015917          	auipc	s2,0x15
ffffffffc0200e00:	2e490913          	addi	s2,s2,740 # ffffffffc02160e0 <heap_used>
ffffffffc0200e04:	00093703          	ld	a4,0(s2)
struct slub_cache *slub_cache_create(const char *name, size_t size, size_t align) {
ffffffffc0200e08:	e05a                	sd	s6,0(sp)
ffffffffc0200e0a:	fc06                	sd	ra,56(sp)
ffffffffc0200e0c:	f822                	sd	s0,48(sp)
ffffffffc0200e0e:	f426                	sd	s1,40(sp)
ffffffffc0200e10:	ec4e                	sd	s3,24(sp)
ffffffffc0200e12:	e852                	sd	s4,16(sp)
ffffffffc0200e14:	e456                	sd	s5,8(sp)
    if (heap_used + size > sizeof(static_heap)) {
ffffffffc0200e16:	07070693          	addi	a3,a4,112
ffffffffc0200e1a:	6b41                	lui	s6,0x10
ffffffffc0200e1c:	0cdb6b63          	bltu	s6,a3,ffffffffc0200ef2 <slub_cache_create+0xfa>
    void *ptr = &static_heap[heap_used];
ffffffffc0200e20:	00005a17          	auipc	s4,0x5
ffffffffc0200e24:	278a0a13          	addi	s4,s4,632 # ffffffffc0206098 <static_heap>
ffffffffc0200e28:	00ea0433          	add	s0,s4,a4
    heap_used = ROUNDUP(heap_used + size, 8);
ffffffffc0200e2c:	07770713          	addi	a4,a4,119
ffffffffc0200e30:	9b61                	andi	a4,a4,-8
ffffffffc0200e32:	8aaa                	mv	s5,a0
ffffffffc0200e34:	84ae                	mv	s1,a1
ffffffffc0200e36:	89b2                	mv	s3,a2
    memset(cache, 0, sizeof(struct slub_cache));
ffffffffc0200e38:	4581                	li	a1,0
ffffffffc0200e3a:	07000613          	li	a2,112
ffffffffc0200e3e:	8522                	mv	a0,s0
    heap_used = ROUNDUP(heap_used + size, 8);
ffffffffc0200e40:	00e93023          	sd	a4,0(s2)
    memset(cache, 0, sizeof(struct slub_cache));
ffffffffc0200e44:	43b000ef          	jal	ra,ffffffffc0201a7e <memset>
    size_t name_len = strlen(name) + 1;
ffffffffc0200e48:	8556                	mv	a0,s5
ffffffffc0200e4a:	3a9000ef          	jal	ra,ffffffffc02019f2 <strlen>
    if (heap_used + size > sizeof(static_heap)) {
ffffffffc0200e4e:	00093703          	ld	a4,0(s2)
ffffffffc0200e52:	00170793          	addi	a5,a4,1
ffffffffc0200e56:	97aa                	add	a5,a5,a0
ffffffffc0200e58:	08fb6f63          	bltu	s6,a5,ffffffffc0200ef6 <slub_cache_create+0xfe>
    void *ptr = &static_heap[heap_used];
ffffffffc0200e5c:	00ea0b33          	add	s6,s4,a4
    heap_used = ROUNDUP(heap_used + size, 8);
ffffffffc0200e60:	079d                	addi	a5,a5,7
ffffffffc0200e62:	9be1                	andi	a5,a5,-8
        strcpy(cache_name, name);
ffffffffc0200e64:	85d6                	mv	a1,s5
ffffffffc0200e66:	855a                	mv	a0,s6
    heap_used = ROUNDUP(heap_used + size, 8);
ffffffffc0200e68:	00f93023          	sd	a5,0(s2)
        strcpy(cache_name, name);
ffffffffc0200e6c:	3bd000ef          	jal	ra,ffffffffc0201a28 <strcpy>
    if (heap_used + size > sizeof(static_heap)) {
ffffffffc0200e70:	00093703          	ld	a4,0(s2)
        cache->name = cache_name;
ffffffffc0200e74:	01643023          	sd	s6,0(s0)
    cache->object_size = ROUNDUP(size, align);
ffffffffc0200e78:	fff48793          	addi	a5,s1,-1
ffffffffc0200e7c:	97ce                	add	a5,a5,s3
ffffffffc0200e7e:	0337f633          	remu	a2,a5,s3
    if (cache->objects_per_slab == 0) {
ffffffffc0200e82:	6685                	lui	a3,0x1
    cache->align = align;
ffffffffc0200e84:	01343823          	sd	s3,16(s0)
    if (cache->objects_per_slab == 0) {
ffffffffc0200e88:	16e1                	addi	a3,a3,-8
    cache->object_size = ROUNDUP(size, align);
ffffffffc0200e8a:	8f91                	sub	a5,a5,a2
ffffffffc0200e8c:	e41c                	sd	a5,8(s0)
    if (cache->objects_per_slab == 0) {
ffffffffc0200e8e:	04f6e563          	bltu	a3,a5,ffffffffc0200ed8 <slub_cache_create+0xe0>
    cache->objects_per_slab = (PGSIZE - sizeof(void*)) / cache->object_size;
ffffffffc0200e92:	02f6d7b3          	divu	a5,a3,a5
    if (heap_used + size > sizeof(static_heap)) {
ffffffffc0200e96:	66c1                	lui	a3,0x10
    cache->objects_per_slab = (PGSIZE - sizeof(void*)) / cache->object_size;
ffffffffc0200e98:	cc1c                	sw	a5,24(s0)
    list_init(&cache->partial_list);
ffffffffc0200e9a:	03840793          	addi	a5,s0,56
    elm->prev = elm->next = elm;
ffffffffc0200e9e:	e03c                	sd	a5,64(s0)
ffffffffc0200ea0:	fc1c                	sd	a5,56(s0)
    if (heap_used + size > sizeof(static_heap)) {
ffffffffc0200ea2:	08070793          	addi	a5,a4,128
ffffffffc0200ea6:	04f6e463          	bltu	a3,a5,ffffffffc0200eee <slub_cache_create+0xf6>
    heap_used = ROUNDUP(heap_used + size, 8);
ffffffffc0200eaa:	08770793          	addi	a5,a4,135
ffffffffc0200eae:	9be1                	andi	a5,a5,-8
    void *ptr = &static_heap[heap_used];
ffffffffc0200eb0:	9752                	add	a4,a4,s4
    heap_used = ROUNDUP(heap_used + size, 8);
ffffffffc0200eb2:	00f93023          	sd	a5,0(s2)
    cache->cpu_cache.avail = 0;
ffffffffc0200eb6:	4785                	li	a5,1
ffffffffc0200eb8:	1792                	slli	a5,a5,0x24
    cache->cpu_cache.freelist = (void **)kmalloc(SLUB_CPU_CACHE_SIZE * sizeof(void*));
ffffffffc0200eba:	f018                	sd	a4,32(s0)
    cache->cpu_cache.page = NULL;
ffffffffc0200ebc:	02043423          	sd	zero,40(s0)
    cache->cpu_cache.avail = 0;
ffffffffc0200ec0:	f81c                	sd	a5,48(s0)
}
ffffffffc0200ec2:	70e2                	ld	ra,56(sp)
ffffffffc0200ec4:	8522                	mv	a0,s0
ffffffffc0200ec6:	7442                	ld	s0,48(sp)
ffffffffc0200ec8:	74a2                	ld	s1,40(sp)
ffffffffc0200eca:	7902                	ld	s2,32(sp)
ffffffffc0200ecc:	69e2                	ld	s3,24(sp)
ffffffffc0200ece:	6a42                	ld	s4,16(sp)
ffffffffc0200ed0:	6aa2                	ld	s5,8(sp)
ffffffffc0200ed2:	6b02                	ld	s6,0(sp)
ffffffffc0200ed4:	6121                	addi	sp,sp,64
ffffffffc0200ed6:	8082                	ret
        cache->objects_per_slab = 1;
ffffffffc0200ed8:	4785                	li	a5,1
ffffffffc0200eda:	cc1c                	sw	a5,24(s0)
    list_init(&cache->partial_list);
ffffffffc0200edc:	03840793          	addi	a5,s0,56
ffffffffc0200ee0:	e03c                	sd	a5,64(s0)
ffffffffc0200ee2:	fc1c                	sd	a5,56(s0)
    if (heap_used + size > sizeof(static_heap)) {
ffffffffc0200ee4:	66c1                	lui	a3,0x10
ffffffffc0200ee6:	08070793          	addi	a5,a4,128
ffffffffc0200eea:	fcf6f0e3          	bgeu	a3,a5,ffffffffc0200eaa <slub_cache_create+0xb2>
        return NULL;
ffffffffc0200eee:	4701                	li	a4,0
ffffffffc0200ef0:	b7d9                	j	ffffffffc0200eb6 <slub_cache_create+0xbe>
        return NULL;
ffffffffc0200ef2:	4401                	li	s0,0
ffffffffc0200ef4:	b7f9                	j	ffffffffc0200ec2 <slub_cache_create+0xca>
        cache->name = "unnamed";
ffffffffc0200ef6:	00001797          	auipc	a5,0x1
ffffffffc0200efa:	14278793          	addi	a5,a5,322 # ffffffffc0202038 <etext+0x568>
ffffffffc0200efe:	e01c                	sd	a5,0(s0)
ffffffffc0200f00:	bfa5                	j	ffffffffc0200e78 <slub_cache_create+0x80>

ffffffffc0200f02 <slub_init>:
void slub_init(void) {
ffffffffc0200f02:	711d                	addi	sp,sp,-96
    memset(&slub_allocator, 0, sizeof(slub_allocator));
ffffffffc0200f04:	08000613          	li	a2,128
ffffffffc0200f08:	4581                	li	a1,0
ffffffffc0200f0a:	00005517          	auipc	a0,0x5
ffffffffc0200f0e:	10e50513          	addi	a0,a0,270 # ffffffffc0206018 <slub_allocator>
void slub_init(void) {
ffffffffc0200f12:	e8a2                	sd	s0,80(sp)
ffffffffc0200f14:	e4a6                	sd	s1,72(sp)
ffffffffc0200f16:	fc4e                	sd	s3,56(sp)
ffffffffc0200f18:	f852                	sd	s4,48(sp)
ffffffffc0200f1a:	f456                	sd	s5,40(sp)
ffffffffc0200f1c:	ec86                	sd	ra,88(sp)
ffffffffc0200f1e:	e0ca                	sd	s2,64(sp)
ffffffffc0200f20:	00005497          	auipc	s1,0x5
ffffffffc0200f24:	0f848493          	addi	s1,s1,248 # ffffffffc0206018 <slub_allocator>
    memset(&slub_allocator, 0, sizeof(slub_allocator));
ffffffffc0200f28:	357000ef          	jal	ra,ffffffffc0201a7e <memset>
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc0200f2c:	4401                	li	s0,0
ffffffffc0200f2e:	4aa1                	li	s5,8
        snprintf(cache_name, sizeof(cache_name), "slub-%u", (unsigned int)size);
ffffffffc0200f30:	00001a17          	auipc	s4,0x1
ffffffffc0200f34:	110a0a13          	addi	s4,s4,272 # ffffffffc0202040 <etext+0x570>
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc0200f38:	49a9                	li	s3,10
ffffffffc0200f3a:	008a993b          	sllw	s2,s5,s0
        snprintf(cache_name, sizeof(cache_name), "slub-%u", (unsigned int)size);
ffffffffc0200f3e:	86ca                	mv	a3,s2
ffffffffc0200f40:	8652                	mv	a2,s4
ffffffffc0200f42:	02000593          	li	a1,32
ffffffffc0200f46:	850a                	mv	a0,sp
ffffffffc0200f48:	24b000ef          	jal	ra,ffffffffc0201992 <snprintf>
        struct slub_cache *cache = slub_cache_create(cache_name, size, SLUB_ALIGN);
ffffffffc0200f4c:	4621                	li	a2,8
ffffffffc0200f4e:	85ca                	mv	a1,s2
ffffffffc0200f50:	850a                	mv	a0,sp
ffffffffc0200f52:	ea7ff0ef          	jal	ra,ffffffffc0200df8 <slub_cache_create>
        slub_allocator.size_caches[i] = cache;
ffffffffc0200f56:	e088                	sd	a0,0(s1)
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc0200f58:	2405                	addiw	s0,s0,1
ffffffffc0200f5a:	04a1                	addi	s1,s1,8
ffffffffc0200f5c:	fd341fe3          	bne	s0,s3,ffffffffc0200f3a <slub_init+0x38>
}
ffffffffc0200f60:	6446                	ld	s0,80(sp)
ffffffffc0200f62:	60e6                	ld	ra,88(sp)
ffffffffc0200f64:	64a6                	ld	s1,72(sp)
ffffffffc0200f66:	6906                	ld	s2,64(sp)
ffffffffc0200f68:	79e2                	ld	s3,56(sp)
ffffffffc0200f6a:	7a42                	ld	s4,48(sp)
ffffffffc0200f6c:	7aa2                	ld	s5,40(sp)
    cprintf("SLUB allocator initialized with %d size classes\n", SLUB_NUM_SIZES);
ffffffffc0200f6e:	45a9                	li	a1,10
ffffffffc0200f70:	00001517          	auipc	a0,0x1
ffffffffc0200f74:	0d850513          	addi	a0,a0,216 # ffffffffc0202048 <etext+0x578>
}
ffffffffc0200f78:	6125                	addi	sp,sp,96
    cprintf("SLUB allocator initialized with %d size classes\n", SLUB_NUM_SIZES);
ffffffffc0200f7a:	9d2ff06f          	j	ffffffffc020014c <cprintf>

ffffffffc0200f7e <slub_print_stats>:
void slub_print_stats(void) {
ffffffffc0200f7e:	1141                	addi	sp,sp,-16
    cprintf("SLUB Allocator Statistics:\n");
ffffffffc0200f80:	00001517          	auipc	a0,0x1
ffffffffc0200f84:	10050513          	addi	a0,a0,256 # ffffffffc0202080 <etext+0x5b0>
void slub_print_stats(void) {
ffffffffc0200f88:	e406                	sd	ra,8(sp)
ffffffffc0200f8a:	e022                	sd	s0,0(sp)
    cprintf("  Total allocations: %u\n", (unsigned int)slub_allocator.total_allocs);
ffffffffc0200f8c:	00005417          	auipc	s0,0x5
ffffffffc0200f90:	08c40413          	addi	s0,s0,140 # ffffffffc0206018 <slub_allocator>
    cprintf("SLUB Allocator Statistics:\n");
ffffffffc0200f94:	9b8ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  Total allocations: %u\n", (unsigned int)slub_allocator.total_allocs);
ffffffffc0200f98:	482c                	lw	a1,80(s0)
ffffffffc0200f9a:	00001517          	auipc	a0,0x1
ffffffffc0200f9e:	10650513          	addi	a0,a0,262 # ffffffffc02020a0 <etext+0x5d0>
ffffffffc0200fa2:	9aaff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  Total frees: %u\n", (unsigned int)slub_allocator.total_frees);
ffffffffc0200fa6:	4c2c                	lw	a1,88(s0)
ffffffffc0200fa8:	00001517          	auipc	a0,0x1
ffffffffc0200fac:	11850513          	addi	a0,a0,280 # ffffffffc02020c0 <etext+0x5f0>
ffffffffc0200fb0:	99cff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  Cache hits: %u\n", (unsigned int)slub_allocator.cache_hits);
ffffffffc0200fb4:	502c                	lw	a1,96(s0)
ffffffffc0200fb6:	00001517          	auipc	a0,0x1
ffffffffc0200fba:	12250513          	addi	a0,a0,290 # ffffffffc02020d8 <etext+0x608>
ffffffffc0200fbe:	98eff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  Total slabs: %u\n", (unsigned int)slub_allocator.nr_slabs);
ffffffffc0200fc2:	542c                	lw	a1,104(s0)
}
ffffffffc0200fc4:	6402                	ld	s0,0(sp)
ffffffffc0200fc6:	60a2                	ld	ra,8(sp)
    cprintf("  Total slabs: %u\n", (unsigned int)slub_allocator.nr_slabs);
ffffffffc0200fc8:	00001517          	auipc	a0,0x1
ffffffffc0200fcc:	12850513          	addi	a0,a0,296 # ffffffffc02020f0 <etext+0x620>
}
ffffffffc0200fd0:	0141                	addi	sp,sp,16
    cprintf("  Total slabs: %u\n", (unsigned int)slub_allocator.nr_slabs);
ffffffffc0200fd2:	97aff06f          	j	ffffffffc020014c <cprintf>

ffffffffc0200fd6 <slub_print_cache_info>:
    if (!cache) return;
ffffffffc0200fd6:	c925                	beqz	a0,ffffffffc0201046 <slub_print_cache_info+0x70>
    cprintf("Cache %s:\n", cache->name ? cache->name : "unnamed");
ffffffffc0200fd8:	610c                	ld	a1,0(a0)
void slub_print_cache_info(struct slub_cache *cache) {
ffffffffc0200fda:	1141                	addi	sp,sp,-16
ffffffffc0200fdc:	e022                	sd	s0,0(sp)
ffffffffc0200fde:	e406                	sd	ra,8(sp)
ffffffffc0200fe0:	842a                	mv	s0,a0
    cprintf("Cache %s:\n", cache->name ? cache->name : "unnamed");
ffffffffc0200fe2:	cda9                	beqz	a1,ffffffffc020103c <slub_print_cache_info+0x66>
ffffffffc0200fe4:	00001517          	auipc	a0,0x1
ffffffffc0200fe8:	12450513          	addi	a0,a0,292 # ffffffffc0202108 <etext+0x638>
ffffffffc0200fec:	960ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  Object size: %u\n", (unsigned int)cache->object_size);
ffffffffc0200ff0:	440c                	lw	a1,8(s0)
ffffffffc0200ff2:	00001517          	auipc	a0,0x1
ffffffffc0200ff6:	12650513          	addi	a0,a0,294 # ffffffffc0202118 <etext+0x648>
ffffffffc0200ffa:	952ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  Objects per slab: %u\n", cache->objects_per_slab);
ffffffffc0200ffe:	4c0c                	lw	a1,24(s0)
ffffffffc0201000:	00001517          	auipc	a0,0x1
ffffffffc0201004:	13050513          	addi	a0,a0,304 # ffffffffc0202130 <etext+0x660>
ffffffffc0201008:	944ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  Total slabs: %u\n", (unsigned int)cache->nr_slabs);
ffffffffc020100c:	442c                	lw	a1,72(s0)
ffffffffc020100e:	00001517          	auipc	a0,0x1
ffffffffc0201012:	0e250513          	addi	a0,a0,226 # ffffffffc02020f0 <etext+0x620>
ffffffffc0201016:	936ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  Allocations: %u\n", (unsigned int)cache->nr_allocs);
ffffffffc020101a:	502c                	lw	a1,96(s0)
ffffffffc020101c:	00001517          	auipc	a0,0x1
ffffffffc0201020:	12c50513          	addi	a0,a0,300 # ffffffffc0202148 <etext+0x678>
ffffffffc0201024:	928ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  Frees: %u\n", (unsigned int)cache->nr_frees);
ffffffffc0201028:	542c                	lw	a1,104(s0)
}
ffffffffc020102a:	6402                	ld	s0,0(sp)
ffffffffc020102c:	60a2                	ld	ra,8(sp)
    cprintf("  Frees: %u\n", (unsigned int)cache->nr_frees);
ffffffffc020102e:	00001517          	auipc	a0,0x1
ffffffffc0201032:	13250513          	addi	a0,a0,306 # ffffffffc0202160 <etext+0x690>
}
ffffffffc0201036:	0141                	addi	sp,sp,16
    cprintf("  Frees: %u\n", (unsigned int)cache->nr_frees);
ffffffffc0201038:	914ff06f          	j	ffffffffc020014c <cprintf>
    cprintf("Cache %s:\n", cache->name ? cache->name : "unnamed");
ffffffffc020103c:	00001597          	auipc	a1,0x1
ffffffffc0201040:	ffc58593          	addi	a1,a1,-4 # ffffffffc0202038 <etext+0x568>
ffffffffc0201044:	b745                	j	ffffffffc0200fe4 <slub_print_cache_info+0xe>
ffffffffc0201046:	8082                	ret

ffffffffc0201048 <slub_check>:
        cprintf("警告: 检测到潜在内存泄漏!\n");
    }
}

// 综合测试函数
void slub_check(void) {
ffffffffc0201048:	7151                	addi	sp,sp,-240
    cprintf("=== SLUB 综合测试开始 ===\n");
ffffffffc020104a:	00001517          	auipc	a0,0x1
ffffffffc020104e:	12650513          	addi	a0,a0,294 # ffffffffc0202170 <etext+0x6a0>
void slub_check(void) {
ffffffffc0201052:	f586                	sd	ra,232(sp)
ffffffffc0201054:	eda6                	sd	s1,216(sp)
ffffffffc0201056:	e5ce                	sd	s3,200(sp)
ffffffffc0201058:	e1d2                	sd	s4,192(sp)
ffffffffc020105a:	f1a2                	sd	s0,224(sp)
ffffffffc020105c:	e9ca                	sd	s2,208(sp)
ffffffffc020105e:	fd56                	sd	s5,184(sp)
    cprintf("=== SLUB 综合测试开始 ===\n");
ffffffffc0201060:	8ecff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("=== SLUB 基础功能测试开始 ===\n");
ffffffffc0201064:	00001517          	auipc	a0,0x1
ffffffffc0201068:	13450513          	addi	a0,a0,308 # ffffffffc0202198 <etext+0x6c8>
ffffffffc020106c:	8e0ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("测试所有大小类别...\n");
ffffffffc0201070:	00001517          	auipc	a0,0x1
ffffffffc0201074:	15050513          	addi	a0,a0,336 # ffffffffc02021c0 <etext+0x6f0>
ffffffffc0201078:	8d4ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc020107c:	4481                	li	s1,0
ffffffffc020107e:	4a21                	li	s4,8
ffffffffc0201080:	49a9                	li	s3,10
ffffffffc0201082:	a021                	j	ffffffffc020108a <slub_check+0x42>
ffffffffc0201084:	2485                	addiw	s1,s1,1
ffffffffc0201086:	05348163          	beq	s1,s3,ffffffffc02010c8 <slub_check+0x80>
ffffffffc020108a:	009a193b          	sllw	s2,s4,s1
    if (size > SLUB_MAX_SIZE) return NULL;
ffffffffc020108e:	854a                	mv	a0,s2
ffffffffc0201090:	a09ff0ef          	jal	ra,ffffffffc0200a98 <slub_alloc.part.0>
ffffffffc0201094:	842a                	mv	s0,a0
        if (ptr) {
ffffffffc0201096:	d57d                	beqz	a0,ffffffffc0201084 <slub_check+0x3c>
            memset(ptr, 0xAA, size);
ffffffffc0201098:	0aa00593          	li	a1,170
ffffffffc020109c:	864a                	mv	a2,s2
ffffffffc020109e:	1e1000ef          	jal	ra,ffffffffc0201a7e <memset>
            for (size_t j = 0; j < size; j++) {
ffffffffc02010a2:	87a2                	mv	a5,s0
ffffffffc02010a4:	008905b3          	add	a1,s2,s0
                assert(bytes[j] == (char)0xAA);
ffffffffc02010a8:	0aa00693          	li	a3,170
ffffffffc02010ac:	0007c703          	lbu	a4,0(a5)
ffffffffc02010b0:	38d71d63          	bne	a4,a3,ffffffffc020144a <slub_check+0x402>
            for (size_t j = 0; j < size; j++) {
ffffffffc02010b4:	0785                	addi	a5,a5,1
ffffffffc02010b6:	fef59be3          	bne	a1,a5,ffffffffc02010ac <slub_check+0x64>
    if (size > SLUB_MAX_SIZE) return;
ffffffffc02010ba:	85ca                	mv	a1,s2
ffffffffc02010bc:	8522                	mv	a0,s0
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc02010be:	2485                	addiw	s1,s1,1
ffffffffc02010c0:	92fff0ef          	jal	ra,ffffffffc02009ee <slub_free.part.0>
ffffffffc02010c4:	fd3493e3          	bne	s1,s3,ffffffffc020108a <slub_check+0x42>
    cprintf("大小类别测试通过!\n");
ffffffffc02010c8:	00001517          	auipc	a0,0x1
ffffffffc02010cc:	13050513          	addi	a0,a0,304 # ffffffffc02021f8 <etext+0x728>
ffffffffc02010d0:	87cff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("测试基础分配功能...\n");
ffffffffc02010d4:	00001517          	auipc	a0,0x1
ffffffffc02010d8:	14450513          	addi	a0,a0,324 # ffffffffc0202218 <etext+0x748>
ffffffffc02010dc:	870ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    if (size > SLUB_MAX_SIZE) return NULL;
ffffffffc02010e0:	02000513          	li	a0,32
ffffffffc02010e4:	9b5ff0ef          	jal	ra,ffffffffc0200a98 <slub_alloc.part.0>
ffffffffc02010e8:	892a                	mv	s2,a0
ffffffffc02010ea:	04000513          	li	a0,64
ffffffffc02010ee:	9abff0ef          	jal	ra,ffffffffc0200a98 <slub_alloc.part.0>
ffffffffc02010f2:	84aa                	mv	s1,a0
ffffffffc02010f4:	08000513          	li	a0,128
ffffffffc02010f8:	9a1ff0ef          	jal	ra,ffffffffc0200a98 <slub_alloc.part.0>
ffffffffc02010fc:	842a                	mv	s0,a0
    assert(p1 != NULL);
ffffffffc02010fe:	3c090663          	beqz	s2,ffffffffc02014ca <slub_check+0x482>
    assert(p2 != NULL);
ffffffffc0201102:	3e048463          	beqz	s1,ffffffffc02014ea <slub_check+0x4a2>
    assert(p3 != NULL);
ffffffffc0201106:	46050263          	beqz	a0,ffffffffc020156a <slub_check+0x522>
    assert(p1 != p2 && p2 != p3 && p1 != p3);
ffffffffc020110a:	44990063          	beq	s2,s1,ffffffffc020154a <slub_check+0x502>
ffffffffc020110e:	42a48e63          	beq	s1,a0,ffffffffc020154a <slub_check+0x502>
ffffffffc0201112:	42a90c63          	beq	s2,a0,ffffffffc020154a <slub_check+0x502>
    if (size > SLUB_MAX_SIZE) return;
ffffffffc0201116:	02000593          	li	a1,32
ffffffffc020111a:	854a                	mv	a0,s2
ffffffffc020111c:	8d3ff0ef          	jal	ra,ffffffffc02009ee <slub_free.part.0>
ffffffffc0201120:	04000593          	li	a1,64
ffffffffc0201124:	8526                	mv	a0,s1
ffffffffc0201126:	8c9ff0ef          	jal	ra,ffffffffc02009ee <slub_free.part.0>
ffffffffc020112a:	08000593          	li	a1,128
ffffffffc020112e:	8522                	mv	a0,s0
ffffffffc0201130:	8bfff0ef          	jal	ra,ffffffffc02009ee <slub_free.part.0>
    cprintf("基础分配测试通过!\n");
ffffffffc0201134:	00001517          	auipc	a0,0x1
ffffffffc0201138:	15c50513          	addi	a0,a0,348 # ffffffffc0202290 <etext+0x7c0>
ffffffffc020113c:	810ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("=== SLUB 边界条件测试开始 ===\n");
ffffffffc0201140:	00001517          	auipc	a0,0x1
ffffffffc0201144:	17050513          	addi	a0,a0,368 # ffffffffc02022b0 <etext+0x7e0>
ffffffffc0201148:	804ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("测试零大小分配...\n");
ffffffffc020114c:	00001517          	auipc	a0,0x1
ffffffffc0201150:	18c50513          	addi	a0,a0,396 # ffffffffc02022d8 <etext+0x808>
ffffffffc0201154:	ff9fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("零大小分配正确失败!\n");
ffffffffc0201158:	00001517          	auipc	a0,0x1
ffffffffc020115c:	1a050513          	addi	a0,a0,416 # ffffffffc02022f8 <etext+0x828>
ffffffffc0201160:	fedfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("测试超大对象分配...\n");
ffffffffc0201164:	00001517          	auipc	a0,0x1
ffffffffc0201168:	1b450513          	addi	a0,a0,436 # ffffffffc0202318 <etext+0x848>
ffffffffc020116c:	fe1fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("超大对象分配正确失败!\n");
ffffffffc0201170:	00001517          	auipc	a0,0x1
ffffffffc0201174:	1c850513          	addi	a0,a0,456 # ffffffffc0202338 <etext+0x868>
ffffffffc0201178:	fd5fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("测试空指针释放...\n");
ffffffffc020117c:	00001517          	auipc	a0,0x1
ffffffffc0201180:	1e450513          	addi	a0,a0,484 # ffffffffc0202360 <etext+0x890>
ffffffffc0201184:	fc9fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("空指针释放安全处理!\n");
ffffffffc0201188:	00001517          	auipc	a0,0x1
ffffffffc020118c:	1f850513          	addi	a0,a0,504 # ffffffffc0202380 <etext+0x8b0>
ffffffffc0201190:	fbdfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("测试最小大小分配...\n");
ffffffffc0201194:	00001517          	auipc	a0,0x1
ffffffffc0201198:	20c50513          	addi	a0,a0,524 # ffffffffc02023a0 <etext+0x8d0>
ffffffffc020119c:	fb1fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    if (size > SLUB_MAX_SIZE) return NULL;
ffffffffc02011a0:	4505                	li	a0,1
ffffffffc02011a2:	8f7ff0ef          	jal	ra,ffffffffc0200a98 <slub_alloc.part.0>
    assert(ptr_min != NULL);
ffffffffc02011a6:	38050263          	beqz	a0,ffffffffc020152a <slub_check+0x4e2>
    if (size > SLUB_MAX_SIZE) return;
ffffffffc02011aa:	4585                	li	a1,1
ffffffffc02011ac:	843ff0ef          	jal	ra,ffffffffc02009ee <slub_free.part.0>
    cprintf("最小大小分配测试通过!\n");
ffffffffc02011b0:	00001517          	auipc	a0,0x1
ffffffffc02011b4:	22050513          	addi	a0,a0,544 # ffffffffc02023d0 <etext+0x900>
ffffffffc02011b8:	f95fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("测试最大大小分配...\n");
ffffffffc02011bc:	00001517          	auipc	a0,0x1
ffffffffc02011c0:	23c50513          	addi	a0,a0,572 # ffffffffc02023f8 <etext+0x928>
ffffffffc02011c4:	f89fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    if (size > SLUB_MAX_SIZE) return NULL;
ffffffffc02011c8:	6505                	lui	a0,0x1
ffffffffc02011ca:	8cfff0ef          	jal	ra,ffffffffc0200a98 <slub_alloc.part.0>
    assert(ptr_max != NULL);
ffffffffc02011ce:	32050e63          	beqz	a0,ffffffffc020150a <slub_check+0x4c2>
    if (size > SLUB_MAX_SIZE) return;
ffffffffc02011d2:	6585                	lui	a1,0x1
ffffffffc02011d4:	81bff0ef          	jal	ra,ffffffffc02009ee <slub_free.part.0>
    cprintf("最大大小分配测试通过!\n");
ffffffffc02011d8:	00001517          	auipc	a0,0x1
ffffffffc02011dc:	25050513          	addi	a0,a0,592 # ffffffffc0202428 <etext+0x958>
ffffffffc02011e0:	f6dfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("=== SLUB CPU缓存测试开始 ===\n");
ffffffffc02011e4:	00001517          	auipc	a0,0x1
ffffffffc02011e8:	26c50513          	addi	a0,a0,620 # ffffffffc0202450 <etext+0x980>
ffffffffc02011ec:	f61fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    size_t initial_hits = slub_allocator.cache_hits;
ffffffffc02011f0:	00005917          	auipc	s2,0x5
ffffffffc02011f4:	e2890913          	addi	s2,s2,-472 # ffffffffc0206018 <slub_allocator>
    cprintf("测试CPU缓存行为...\n");
ffffffffc02011f8:	00001517          	auipc	a0,0x1
ffffffffc02011fc:	28050513          	addi	a0,a0,640 # ffffffffc0202478 <etext+0x9a8>
ffffffffc0201200:	0024                	addi	s1,sp,8
    size_t initial_hits = slub_allocator.cache_hits;
ffffffffc0201202:	06093a03          	ld	s4,96(s2)
    cprintf("测试CPU缓存行为...\n");
ffffffffc0201206:	0b010993          	addi	s3,sp,176
ffffffffc020120a:	f43fe0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc020120e:	8426                	mv	s0,s1
    if (size > SLUB_MAX_SIZE) return NULL;
ffffffffc0201210:	02000513          	li	a0,32
ffffffffc0201214:	885ff0ef          	jal	ra,ffffffffc0200a98 <slub_alloc.part.0>
        ptrs[i] = slub_alloc(32);
ffffffffc0201218:	e008                	sd	a0,0(s0)
        assert(ptrs[i] != NULL);
ffffffffc020121a:	24050863          	beqz	a0,ffffffffc020146a <slub_check+0x422>
    for (int i = 0; i < SLUB_CPU_CACHE_SIZE + 5; i++) {
ffffffffc020121e:	0421                	addi	s0,s0,8
ffffffffc0201220:	fe8998e3          	bne	s3,s0,ffffffffc0201210 <slub_check+0x1c8>
ffffffffc0201224:	0020                	addi	s0,sp,8
        slub_free(ptrs[i], 32);
ffffffffc0201226:	6008                	ld	a0,0(s0)
    if (!ptr || size == 0) return;
ffffffffc0201228:	c509                	beqz	a0,ffffffffc0201232 <slub_check+0x1ea>
    if (size > SLUB_MAX_SIZE) return;
ffffffffc020122a:	02000593          	li	a1,32
ffffffffc020122e:	fc0ff0ef          	jal	ra,ffffffffc02009ee <slub_free.part.0>
    for (int i = 0; i < SLUB_CPU_CACHE_SIZE + 5; i++) {
ffffffffc0201232:	0421                	addi	s0,s0,8
ffffffffc0201234:	ff3419e3          	bne	s0,s3,ffffffffc0201226 <slub_check+0x1de>
ffffffffc0201238:	003c                	addi	a5,sp,8
ffffffffc020123a:	08810993          	addi	s3,sp,136
ffffffffc020123e:	843e                	mv	s0,a5
    if (size > SLUB_MAX_SIZE) return NULL;
ffffffffc0201240:	02000513          	li	a0,32
ffffffffc0201244:	855ff0ef          	jal	ra,ffffffffc0200a98 <slub_alloc.part.0>
        ptrs[i] = slub_alloc(32);
ffffffffc0201248:	e008                	sd	a0,0(s0)
        assert(ptrs[i] != NULL);
ffffffffc020124a:	24050063          	beqz	a0,ffffffffc020148a <slub_check+0x442>
    for (int i = 0; i < SLUB_CPU_CACHE_SIZE; i++) {
ffffffffc020124e:	0421                	addi	s0,s0,8
ffffffffc0201250:	fe8998e3          	bne	s3,s0,ffffffffc0201240 <slub_check+0x1f8>
    cprintf("缓存命中次数增长: %u -> %u\n",
ffffffffc0201254:	06092603          	lw	a2,96(s2)
ffffffffc0201258:	000a059b          	sext.w	a1,s4
ffffffffc020125c:	00001517          	auipc	a0,0x1
ffffffffc0201260:	24c50513          	addi	a0,a0,588 # ffffffffc02024a8 <etext+0x9d8>
ffffffffc0201264:	ee9fe0ef          	jal	ra,ffffffffc020014c <cprintf>
        slub_free(ptrs[i], 32);
ffffffffc0201268:	6088                	ld	a0,0(s1)
    if (!ptr || size == 0) return;
ffffffffc020126a:	c509                	beqz	a0,ffffffffc0201274 <slub_check+0x22c>
    if (size > SLUB_MAX_SIZE) return;
ffffffffc020126c:	02000593          	li	a1,32
ffffffffc0201270:	f7eff0ef          	jal	ra,ffffffffc02009ee <slub_free.part.0>
    for (int i = 0; i < SLUB_CPU_CACHE_SIZE; i++) {
ffffffffc0201274:	04a1                	addi	s1,s1,8
ffffffffc0201276:	fe9999e3          	bne	s3,s1,ffffffffc0201268 <slub_check+0x220>
    cprintf("CPU缓存测试通过!\n");
ffffffffc020127a:	00001517          	auipc	a0,0x1
ffffffffc020127e:	25650513          	addi	a0,a0,598 # ffffffffc02024d0 <etext+0xa00>
ffffffffc0201282:	ecbfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("=== SLUB 对齐测试开始 ===\n");
ffffffffc0201286:	00001517          	auipc	a0,0x1
ffffffffc020128a:	26250513          	addi	a0,a0,610 # ffffffffc02024e8 <etext+0xa18>
ffffffffc020128e:	ebffe0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc0201292:	4401                	li	s0,0
ffffffffc0201294:	4a21                	li	s4,8
ffffffffc0201296:	49a9                	li	s3,10
ffffffffc0201298:	008a14bb          	sllw	s1,s4,s0
    if (size > SLUB_MAX_SIZE) return NULL;
ffffffffc020129c:	8526                	mv	a0,s1
ffffffffc020129e:	ffaff0ef          	jal	ra,ffffffffc0200a98 <slub_alloc.part.0>
        if (ptr) {
ffffffffc02012a2:	c901                	beqz	a0,ffffffffc02012b2 <slub_check+0x26a>
            assert((addr % SLUB_ALIGN) == 0);  // Check alignment
ffffffffc02012a4:	00757793          	andi	a5,a0,7
ffffffffc02012a8:	20079163          	bnez	a5,ffffffffc02014aa <slub_check+0x462>
    if (size > SLUB_MAX_SIZE) return;
ffffffffc02012ac:	85a6                	mv	a1,s1
ffffffffc02012ae:	f40ff0ef          	jal	ra,ffffffffc02009ee <slub_free.part.0>
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc02012b2:	2405                	addiw	s0,s0,1
ffffffffc02012b4:	ff3412e3          	bne	s0,s3,ffffffffc0201298 <slub_check+0x250>
    cprintf("对齐测试通过!\n");
ffffffffc02012b8:	00001517          	auipc	a0,0x1
ffffffffc02012bc:	27850513          	addi	a0,a0,632 # ffffffffc0202530 <etext+0xa60>
ffffffffc02012c0:	e8dfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    // Run all test suites
    slub_basic_check();
    slub_boundary_check();
    slub_cpu_cache_check();
    slub_alignment_check();
    slub_stress_check();
ffffffffc02012c4:	9b3ff0ef          	jal	ra,ffffffffc0200c76 <slub_stress_check>
    cprintf("=== SLUB 内存泄漏检测开始 ===\n");
ffffffffc02012c8:	00001517          	auipc	a0,0x1
ffffffffc02012cc:	28050513          	addi	a0,a0,640 # ffffffffc0202548 <etext+0xa78>
ffffffffc02012d0:	e7dfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    size_t initial_allocs = slub_allocator.total_allocs;
ffffffffc02012d4:	05093a83          	ld	s5,80(s2)
    size_t initial_frees = slub_allocator.total_frees;
ffffffffc02012d8:	05893a03          	ld	s4,88(s2)
    for (int i = 0; i < 20; i++) {
ffffffffc02012dc:	0020                	addi	s0,sp,8
ffffffffc02012de:	0a810993          	addi	s3,sp,168
    size_t initial_frees = slub_allocator.total_frees;
ffffffffc02012e2:	84a2                	mv	s1,s0
    if (size > SLUB_MAX_SIZE) return NULL;
ffffffffc02012e4:	02000513          	li	a0,32
ffffffffc02012e8:	fb0ff0ef          	jal	ra,ffffffffc0200a98 <slub_alloc.part.0>
        test_ptrs[i] = slub_alloc(32);
ffffffffc02012ec:	e088                	sd	a0,0(s1)
    for (int i = 0; i < 20; i++) {
ffffffffc02012ee:	04a1                	addi	s1,s1,8
ffffffffc02012f0:	fe999ae3          	bne	s3,s1,ffffffffc02012e4 <slub_check+0x29c>
        slub_free(test_ptrs[i], 32);
ffffffffc02012f4:	6008                	ld	a0,0(s0)
    if (!ptr || size == 0) return;
ffffffffc02012f6:	c509                	beqz	a0,ffffffffc0201300 <slub_check+0x2b8>
    if (size > SLUB_MAX_SIZE) return;
ffffffffc02012f8:	02000593          	li	a1,32
ffffffffc02012fc:	ef2ff0ef          	jal	ra,ffffffffc02009ee <slub_free.part.0>
    for (int i = 0; i < 20; i++) {
ffffffffc0201300:	0421                	addi	s0,s0,8
ffffffffc0201302:	fe8999e3          	bne	s3,s0,ffffffffc02012f4 <slub_check+0x2ac>
    size_t alloc_diff = final_allocs - initial_allocs;
ffffffffc0201306:	05093483          	ld	s1,80(s2)
    size_t free_diff = final_frees - initial_frees;
ffffffffc020130a:	05893403          	ld	s0,88(s2)
    cprintf("测试中分配次数: %u\n", (unsigned int)alloc_diff);
ffffffffc020130e:	00001517          	auipc	a0,0x1
ffffffffc0201312:	26250513          	addi	a0,a0,610 # ffffffffc0202570 <etext+0xaa0>
    size_t alloc_diff = final_allocs - initial_allocs;
ffffffffc0201316:	415484b3          	sub	s1,s1,s5
    cprintf("测试中分配次数: %u\n", (unsigned int)alloc_diff);
ffffffffc020131a:	0004859b          	sext.w	a1,s1
    size_t free_diff = final_frees - initial_frees;
ffffffffc020131e:	41440433          	sub	s0,s0,s4
    cprintf("测试中分配次数: %u\n", (unsigned int)alloc_diff);
ffffffffc0201322:	e2bfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("测试中释放次数: %u\n", (unsigned int)free_diff);
ffffffffc0201326:	0004059b          	sext.w	a1,s0
ffffffffc020132a:	00001517          	auipc	a0,0x1
ffffffffc020132e:	26650513          	addi	a0,a0,614 # ffffffffc0202590 <etext+0xac0>
ffffffffc0201332:	e1bfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    if (alloc_diff == free_diff) {
ffffffffc0201336:	0a848c63          	beq	s1,s0,ffffffffc02013ee <slub_check+0x3a6>
        cprintf("警告: 检测到潜在内存泄漏!\n");
ffffffffc020133a:	00001517          	auipc	a0,0x1
ffffffffc020133e:	29650513          	addi	a0,a0,662 # ffffffffc02025d0 <etext+0xb00>
ffffffffc0201342:	e0bfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("=== SLUB 状态信息 ===\n");
ffffffffc0201346:	00001517          	auipc	a0,0x1
ffffffffc020134a:	2b250513          	addi	a0,a0,690 # ffffffffc02025f8 <etext+0xb28>
ffffffffc020134e:	dfffe0ef          	jal	ra,ffffffffc020014c <cprintf>
    slub_print_stats();
ffffffffc0201352:	c2dff0ef          	jal	ra,ffffffffc0200f7e <slub_print_stats>
    if (slub_allocator.total_allocs > 0) {
ffffffffc0201356:	05093703          	ld	a4,80(s2)
ffffffffc020135a:	eb5d                	bnez	a4,ffffffffc0201410 <slub_check+0x3c8>
    for (size_t i = 0; i < npage; i++) {
ffffffffc020135c:	00015797          	auipc	a5,0x15
ffffffffc0201360:	d547b783          	ld	a5,-684(a5) # ffffffffc02160b0 <npage>
ffffffffc0201364:	0e078163          	beqz	a5,ffffffffc0201446 <slub_check+0x3fe>
ffffffffc0201368:	00279693          	slli	a3,a5,0x2
ffffffffc020136c:	96be                	add	a3,a3,a5
ffffffffc020136e:	00015717          	auipc	a4,0x15
ffffffffc0201372:	d4a73703          	ld	a4,-694(a4) # ffffffffc02160b8 <pages>
ffffffffc0201376:	068e                	slli	a3,a3,0x3
ffffffffc0201378:	96ba                	add	a3,a3,a4
    size_t free_pages = 0;
ffffffffc020137a:	4581                	li	a1,0
        if (!PageReserved(pages + i) && !PageProperty(pages + i)) {
ffffffffc020137c:	671c                	ld	a5,8(a4)
    for (size_t i = 0; i < npage; i++) {
ffffffffc020137e:	02870713          	addi	a4,a4,40
        if (!PageReserved(pages + i) && !PageProperty(pages + i)) {
ffffffffc0201382:	8b8d                	andi	a5,a5,3
            free_pages++;
ffffffffc0201384:	0017b793          	seqz	a5,a5
ffffffffc0201388:	95be                	add	a1,a1,a5
    for (size_t i = 0; i < npage; i++) {
ffffffffc020138a:	fed719e3          	bne	a4,a3,ffffffffc020137c <slub_check+0x334>
    cprintf("  空闲页面数: %u\n", (unsigned int)free_pages);
ffffffffc020138e:	2581                	sext.w	a1,a1
ffffffffc0201390:	00001517          	auipc	a0,0x1
ffffffffc0201394:	2a850513          	addi	a0,a0,680 # ffffffffc0202638 <etext+0xb68>
ffffffffc0201398:	db5fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("\n");
ffffffffc020139c:	00001517          	auipc	a0,0x1
ffffffffc02013a0:	f5450513          	addi	a0,a0,-172 # ffffffffc02022f0 <etext+0x820>
ffffffffc02013a4:	da9fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("=== SLUB 缓存详细信息 ===\n");
ffffffffc02013a8:	00001517          	auipc	a0,0x1
ffffffffc02013ac:	2a850513          	addi	a0,a0,680 # ffffffffc0202650 <etext+0xb80>
ffffffffc02013b0:	d9dfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc02013b4:	00005417          	auipc	s0,0x5
ffffffffc02013b8:	c6440413          	addi	s0,s0,-924 # ffffffffc0206018 <slub_allocator>
ffffffffc02013bc:	00005497          	auipc	s1,0x5
ffffffffc02013c0:	cac48493          	addi	s1,s1,-852 # ffffffffc0206068 <slub_allocator+0x50>
        if (slub_allocator.size_caches[i]) {
ffffffffc02013c4:	6008                	ld	a0,0(s0)
ffffffffc02013c6:	c119                	beqz	a0,ffffffffc02013cc <slub_check+0x384>
            slub_print_cache_info(slub_allocator.size_caches[i]);
ffffffffc02013c8:	c0fff0ef          	jal	ra,ffffffffc0200fd6 <slub_print_cache_info>
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc02013cc:	0421                	addi	s0,s0,8
ffffffffc02013ce:	fe849be3          	bne	s1,s0,ffffffffc02013c4 <slub_check+0x37c>

    // Show final status
    slub_show_status();

    cprintf("=== SLUB 综合测试成功完成 ===\n");
}
ffffffffc02013d2:	740e                	ld	s0,224(sp)
ffffffffc02013d4:	70ae                	ld	ra,232(sp)
ffffffffc02013d6:	64ee                	ld	s1,216(sp)
ffffffffc02013d8:	694e                	ld	s2,208(sp)
ffffffffc02013da:	69ae                	ld	s3,200(sp)
ffffffffc02013dc:	6a0e                	ld	s4,192(sp)
ffffffffc02013de:	7aea                	ld	s5,184(sp)
    cprintf("=== SLUB 综合测试成功完成 ===\n");
ffffffffc02013e0:	00001517          	auipc	a0,0x1
ffffffffc02013e4:	29850513          	addi	a0,a0,664 # ffffffffc0202678 <etext+0xba8>
}
ffffffffc02013e8:	616d                	addi	sp,sp,240
    cprintf("=== SLUB 综合测试成功完成 ===\n");
ffffffffc02013ea:	d63fe06f          	j	ffffffffc020014c <cprintf>
        cprintf("内存泄漏检测通过!\n");
ffffffffc02013ee:	00001517          	auipc	a0,0x1
ffffffffc02013f2:	1c250513          	addi	a0,a0,450 # ffffffffc02025b0 <etext+0xae0>
ffffffffc02013f6:	d57fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("=== SLUB 状态信息 ===\n");
ffffffffc02013fa:	00001517          	auipc	a0,0x1
ffffffffc02013fe:	1fe50513          	addi	a0,a0,510 # ffffffffc02025f8 <etext+0xb28>
ffffffffc0201402:	d4bfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    slub_print_stats();
ffffffffc0201406:	b79ff0ef          	jal	ra,ffffffffc0200f7e <slub_print_stats>
    if (slub_allocator.total_allocs > 0) {
ffffffffc020140a:	05093703          	ld	a4,80(s2)
ffffffffc020140e:	d739                	beqz	a4,ffffffffc020135c <slub_check+0x314>
        size_t hit_rate_int = (slub_allocator.cache_hits * 10000) / slub_allocator.total_allocs;
ffffffffc0201410:	06093783          	ld	a5,96(s2)
ffffffffc0201414:	6689                	lui	a3,0x2
ffffffffc0201416:	71068693          	addi	a3,a3,1808 # 2710 <kern_entry-0xffffffffc01fd8f0>
ffffffffc020141a:	02d787b3          	mul	a5,a5,a3
               (unsigned int)(hit_rate_int % 100));
ffffffffc020141e:	06400613          	li	a2,100
        cprintf("  缓存命中率: %u.%02u%%\n",
ffffffffc0201422:	00001517          	auipc	a0,0x1
ffffffffc0201426:	1f650513          	addi	a0,a0,502 # ffffffffc0202618 <etext+0xb48>
        size_t hit_rate_int = (slub_allocator.cache_hits * 10000) / slub_allocator.total_allocs;
ffffffffc020142a:	02e7d7b3          	divu	a5,a5,a4
               (unsigned int)(hit_rate_int / 100),
ffffffffc020142e:	02c7d5b3          	divu	a1,a5,a2
        cprintf("  缓存命中率: %u.%02u%%\n",
ffffffffc0201432:	02c7f633          	remu	a2,a5,a2
ffffffffc0201436:	2581                	sext.w	a1,a1
ffffffffc0201438:	d15fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (size_t i = 0; i < npage; i++) {
ffffffffc020143c:	00015797          	auipc	a5,0x15
ffffffffc0201440:	c747b783          	ld	a5,-908(a5) # ffffffffc02160b0 <npage>
ffffffffc0201444:	f395                	bnez	a5,ffffffffc0201368 <slub_check+0x320>
ffffffffc0201446:	4581                	li	a1,0
ffffffffc0201448:	b7a1                	j	ffffffffc0201390 <slub_check+0x348>
                assert(bytes[j] == (char)0xAA);
ffffffffc020144a:	00001697          	auipc	a3,0x1
ffffffffc020144e:	d9668693          	addi	a3,a3,-618 # ffffffffc02021e0 <etext+0x710>
ffffffffc0201452:	00001617          	auipc	a2,0x1
ffffffffc0201456:	a2e60613          	addi	a2,a2,-1490 # ffffffffc0201e80 <etext+0x3b0>
ffffffffc020145a:	1b400593          	li	a1,436
ffffffffc020145e:	00001517          	auipc	a0,0x1
ffffffffc0201462:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0201e98 <etext+0x3c8>
ffffffffc0201466:	d5dfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(ptrs[i] != NULL);
ffffffffc020146a:	00001697          	auipc	a3,0x1
ffffffffc020146e:	02e68693          	addi	a3,a3,46 # ffffffffc0202498 <etext+0x9c8>
ffffffffc0201472:	00001617          	auipc	a2,0x1
ffffffffc0201476:	a0e60613          	addi	a2,a2,-1522 # ffffffffc0201e80 <etext+0x3b0>
ffffffffc020147a:	1ff00593          	li	a1,511
ffffffffc020147e:	00001517          	auipc	a0,0x1
ffffffffc0201482:	a1a50513          	addi	a0,a0,-1510 # ffffffffc0201e98 <etext+0x3c8>
ffffffffc0201486:	d3dfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(ptrs[i] != NULL);
ffffffffc020148a:	00001697          	auipc	a3,0x1
ffffffffc020148e:	00e68693          	addi	a3,a3,14 # ffffffffc0202498 <etext+0x9c8>
ffffffffc0201492:	00001617          	auipc	a2,0x1
ffffffffc0201496:	9ee60613          	addi	a2,a2,-1554 # ffffffffc0201e80 <etext+0x3b0>
ffffffffc020149a:	20a00593          	li	a1,522
ffffffffc020149e:	00001517          	auipc	a0,0x1
ffffffffc02014a2:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0201e98 <etext+0x3c8>
ffffffffc02014a6:	d1dfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
            assert((addr % SLUB_ALIGN) == 0);  // Check alignment
ffffffffc02014aa:	00001697          	auipc	a3,0x1
ffffffffc02014ae:	06668693          	addi	a3,a3,102 # ffffffffc0202510 <etext+0xa40>
ffffffffc02014b2:	00001617          	auipc	a2,0x1
ffffffffc02014b6:	9ce60613          	addi	a2,a2,-1586 # ffffffffc0201e80 <etext+0x3b0>
ffffffffc02014ba:	22400593          	li	a1,548
ffffffffc02014be:	00001517          	auipc	a0,0x1
ffffffffc02014c2:	9da50513          	addi	a0,a0,-1574 # ffffffffc0201e98 <etext+0x3c8>
ffffffffc02014c6:	cfdfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p1 != NULL);
ffffffffc02014ca:	00001697          	auipc	a3,0x1
ffffffffc02014ce:	d6e68693          	addi	a3,a3,-658 # ffffffffc0202238 <etext+0x768>
ffffffffc02014d2:	00001617          	auipc	a2,0x1
ffffffffc02014d6:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0201e80 <etext+0x3b0>
ffffffffc02014da:	1c200593          	li	a1,450
ffffffffc02014de:	00001517          	auipc	a0,0x1
ffffffffc02014e2:	9ba50513          	addi	a0,a0,-1606 # ffffffffc0201e98 <etext+0x3c8>
ffffffffc02014e6:	cddfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p2 != NULL);
ffffffffc02014ea:	00001697          	auipc	a3,0x1
ffffffffc02014ee:	d5e68693          	addi	a3,a3,-674 # ffffffffc0202248 <etext+0x778>
ffffffffc02014f2:	00001617          	auipc	a2,0x1
ffffffffc02014f6:	98e60613          	addi	a2,a2,-1650 # ffffffffc0201e80 <etext+0x3b0>
ffffffffc02014fa:	1c300593          	li	a1,451
ffffffffc02014fe:	00001517          	auipc	a0,0x1
ffffffffc0201502:	99a50513          	addi	a0,a0,-1638 # ffffffffc0201e98 <etext+0x3c8>
ffffffffc0201506:	cbdfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(ptr_max != NULL);
ffffffffc020150a:	00001697          	auipc	a3,0x1
ffffffffc020150e:	f0e68693          	addi	a3,a3,-242 # ffffffffc0202418 <etext+0x948>
ffffffffc0201512:	00001617          	auipc	a2,0x1
ffffffffc0201516:	96e60613          	addi	a2,a2,-1682 # ffffffffc0201e80 <etext+0x3b0>
ffffffffc020151a:	1ed00593          	li	a1,493
ffffffffc020151e:	00001517          	auipc	a0,0x1
ffffffffc0201522:	97a50513          	addi	a0,a0,-1670 # ffffffffc0201e98 <etext+0x3c8>
ffffffffc0201526:	c9dfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(ptr_min != NULL);
ffffffffc020152a:	00001697          	auipc	a3,0x1
ffffffffc020152e:	e9668693          	addi	a3,a3,-362 # ffffffffc02023c0 <etext+0x8f0>
ffffffffc0201532:	00001617          	auipc	a2,0x1
ffffffffc0201536:	94e60613          	addi	a2,a2,-1714 # ffffffffc0201e80 <etext+0x3b0>
ffffffffc020153a:	1e600593          	li	a1,486
ffffffffc020153e:	00001517          	auipc	a0,0x1
ffffffffc0201542:	95a50513          	addi	a0,a0,-1702 # ffffffffc0201e98 <etext+0x3c8>
ffffffffc0201546:	c7dfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p1 != p2 && p2 != p3 && p1 != p3);
ffffffffc020154a:	00001697          	auipc	a3,0x1
ffffffffc020154e:	d1e68693          	addi	a3,a3,-738 # ffffffffc0202268 <etext+0x798>
ffffffffc0201552:	00001617          	auipc	a2,0x1
ffffffffc0201556:	92e60613          	addi	a2,a2,-1746 # ffffffffc0201e80 <etext+0x3b0>
ffffffffc020155a:	1c500593          	li	a1,453
ffffffffc020155e:	00001517          	auipc	a0,0x1
ffffffffc0201562:	93a50513          	addi	a0,a0,-1734 # ffffffffc0201e98 <etext+0x3c8>
ffffffffc0201566:	c5dfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p3 != NULL);
ffffffffc020156a:	00001697          	auipc	a3,0x1
ffffffffc020156e:	cee68693          	addi	a3,a3,-786 # ffffffffc0202258 <etext+0x788>
ffffffffc0201572:	00001617          	auipc	a2,0x1
ffffffffc0201576:	90e60613          	addi	a2,a2,-1778 # ffffffffc0201e80 <etext+0x3b0>
ffffffffc020157a:	1c400593          	li	a1,452
ffffffffc020157e:	00001517          	auipc	a0,0x1
ffffffffc0201582:	91a50513          	addi	a0,a0,-1766 # ffffffffc0201e98 <etext+0x3c8>
ffffffffc0201586:	c3dfe0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc020158a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020158a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020158e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201590:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201594:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201596:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020159a:	f022                	sd	s0,32(sp)
ffffffffc020159c:	ec26                	sd	s1,24(sp)
ffffffffc020159e:	e84a                	sd	s2,16(sp)
ffffffffc02015a0:	f406                	sd	ra,40(sp)
ffffffffc02015a2:	e44e                	sd	s3,8(sp)
ffffffffc02015a4:	84aa                	mv	s1,a0
ffffffffc02015a6:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02015a8:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02015ac:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02015ae:	03067e63          	bgeu	a2,a6,ffffffffc02015ea <printnum+0x60>
ffffffffc02015b2:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02015b4:	00805763          	blez	s0,ffffffffc02015c2 <printnum+0x38>
ffffffffc02015b8:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02015ba:	85ca                	mv	a1,s2
ffffffffc02015bc:	854e                	mv	a0,s3
ffffffffc02015be:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02015c0:	fc65                	bnez	s0,ffffffffc02015b8 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015c2:	1a02                	slli	s4,s4,0x20
ffffffffc02015c4:	00001797          	auipc	a5,0x1
ffffffffc02015c8:	12c78793          	addi	a5,a5,300 # ffffffffc02026f0 <slub_pmm_manager+0x38>
ffffffffc02015cc:	020a5a13          	srli	s4,s4,0x20
ffffffffc02015d0:	9a3e                	add	s4,s4,a5
}
ffffffffc02015d2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015d4:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02015d8:	70a2                	ld	ra,40(sp)
ffffffffc02015da:	69a2                	ld	s3,8(sp)
ffffffffc02015dc:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015de:	85ca                	mv	a1,s2
ffffffffc02015e0:	87a6                	mv	a5,s1
}
ffffffffc02015e2:	6942                	ld	s2,16(sp)
ffffffffc02015e4:	64e2                	ld	s1,24(sp)
ffffffffc02015e6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015e8:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02015ea:	03065633          	divu	a2,a2,a6
ffffffffc02015ee:	8722                	mv	a4,s0
ffffffffc02015f0:	f9bff0ef          	jal	ra,ffffffffc020158a <printnum>
ffffffffc02015f4:	b7f9                	j	ffffffffc02015c2 <printnum+0x38>

ffffffffc02015f6 <sprintputch>:
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
    b->cnt ++;
ffffffffc02015f6:	499c                	lw	a5,16(a1)
    if (b->buf < b->ebuf) {
ffffffffc02015f8:	6198                	ld	a4,0(a1)
ffffffffc02015fa:	6594                	ld	a3,8(a1)
    b->cnt ++;
ffffffffc02015fc:	2785                	addiw	a5,a5,1
ffffffffc02015fe:	c99c                	sw	a5,16(a1)
    if (b->buf < b->ebuf) {
ffffffffc0201600:	00d77763          	bgeu	a4,a3,ffffffffc020160e <sprintputch+0x18>
        *b->buf ++ = ch;
ffffffffc0201604:	00170793          	addi	a5,a4,1
ffffffffc0201608:	e19c                	sd	a5,0(a1)
ffffffffc020160a:	00a70023          	sb	a0,0(a4)
    }
}
ffffffffc020160e:	8082                	ret

ffffffffc0201610 <vprintfmt>:
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201610:	7119                	addi	sp,sp,-128
ffffffffc0201612:	f4a6                	sd	s1,104(sp)
ffffffffc0201614:	f0ca                	sd	s2,96(sp)
ffffffffc0201616:	ecce                	sd	s3,88(sp)
ffffffffc0201618:	e8d2                	sd	s4,80(sp)
ffffffffc020161a:	e4d6                	sd	s5,72(sp)
ffffffffc020161c:	e0da                	sd	s6,64(sp)
ffffffffc020161e:	fc5e                	sd	s7,56(sp)
ffffffffc0201620:	f06a                	sd	s10,32(sp)
ffffffffc0201622:	fc86                	sd	ra,120(sp)
ffffffffc0201624:	f8a2                	sd	s0,112(sp)
ffffffffc0201626:	f862                	sd	s8,48(sp)
ffffffffc0201628:	f466                	sd	s9,40(sp)
ffffffffc020162a:	ec6e                	sd	s11,24(sp)
ffffffffc020162c:	892a                	mv	s2,a0
ffffffffc020162e:	84ae                	mv	s1,a1
ffffffffc0201630:	8d32                	mv	s10,a2
ffffffffc0201632:	8a36                	mv	s4,a3
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201634:	02500993          	li	s3,37
        width = precision = -1;
ffffffffc0201638:	5b7d                	li	s6,-1
ffffffffc020163a:	00001a97          	auipc	s5,0x1
ffffffffc020163e:	0eaa8a93          	addi	s5,s5,234 # ffffffffc0202724 <slub_pmm_manager+0x6c>
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201642:	00001b97          	auipc	s7,0x1
ffffffffc0201646:	2beb8b93          	addi	s7,s7,702 # ffffffffc0202900 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020164a:	000d4503          	lbu	a0,0(s10)
ffffffffc020164e:	001d0413          	addi	s0,s10,1
ffffffffc0201652:	01350a63          	beq	a0,s3,ffffffffc0201666 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201656:	c121                	beqz	a0,ffffffffc0201696 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201658:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020165a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020165c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020165e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201662:	ff351ae3          	bne	a0,s3,ffffffffc0201656 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201666:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020166a:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020166e:	4c81                	li	s9,0
ffffffffc0201670:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201672:	5c7d                	li	s8,-1
ffffffffc0201674:	5dfd                	li	s11,-1
ffffffffc0201676:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020167a:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020167c:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201680:	0ff5f593          	zext.b	a1,a1
ffffffffc0201684:	00140d13          	addi	s10,s0,1
ffffffffc0201688:	04b56263          	bltu	a0,a1,ffffffffc02016cc <vprintfmt+0xbc>
ffffffffc020168c:	058a                	slli	a1,a1,0x2
ffffffffc020168e:	95d6                	add	a1,a1,s5
ffffffffc0201690:	4194                	lw	a3,0(a1)
ffffffffc0201692:	96d6                	add	a3,a3,s5
ffffffffc0201694:	8682                	jr	a3
}
ffffffffc0201696:	70e6                	ld	ra,120(sp)
ffffffffc0201698:	7446                	ld	s0,112(sp)
ffffffffc020169a:	74a6                	ld	s1,104(sp)
ffffffffc020169c:	7906                	ld	s2,96(sp)
ffffffffc020169e:	69e6                	ld	s3,88(sp)
ffffffffc02016a0:	6a46                	ld	s4,80(sp)
ffffffffc02016a2:	6aa6                	ld	s5,72(sp)
ffffffffc02016a4:	6b06                	ld	s6,64(sp)
ffffffffc02016a6:	7be2                	ld	s7,56(sp)
ffffffffc02016a8:	7c42                	ld	s8,48(sp)
ffffffffc02016aa:	7ca2                	ld	s9,40(sp)
ffffffffc02016ac:	7d02                	ld	s10,32(sp)
ffffffffc02016ae:	6de2                	ld	s11,24(sp)
ffffffffc02016b0:	6109                	addi	sp,sp,128
ffffffffc02016b2:	8082                	ret
            padc = '0';
ffffffffc02016b4:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02016b6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016ba:	846a                	mv	s0,s10
ffffffffc02016bc:	00140d13          	addi	s10,s0,1
ffffffffc02016c0:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02016c4:	0ff5f593          	zext.b	a1,a1
ffffffffc02016c8:	fcb572e3          	bgeu	a0,a1,ffffffffc020168c <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02016cc:	85a6                	mv	a1,s1
ffffffffc02016ce:	02500513          	li	a0,37
ffffffffc02016d2:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02016d4:	fff44783          	lbu	a5,-1(s0)
ffffffffc02016d8:	8d22                	mv	s10,s0
ffffffffc02016da:	f73788e3          	beq	a5,s3,ffffffffc020164a <vprintfmt+0x3a>
ffffffffc02016de:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02016e2:	1d7d                	addi	s10,s10,-1
ffffffffc02016e4:	ff379de3          	bne	a5,s3,ffffffffc02016de <vprintfmt+0xce>
ffffffffc02016e8:	b78d                	j	ffffffffc020164a <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02016ea:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02016ee:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016f2:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02016f4:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02016f8:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02016fc:	02d86463          	bltu	a6,a3,ffffffffc0201724 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201700:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201704:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201708:	0186873b          	addw	a4,a3,s8
ffffffffc020170c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201710:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201712:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201716:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201718:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020171c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201720:	fed870e3          	bgeu	a6,a3,ffffffffc0201700 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201724:	f40ddce3          	bgez	s11,ffffffffc020167c <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201728:	8de2                	mv	s11,s8
ffffffffc020172a:	5c7d                	li	s8,-1
ffffffffc020172c:	bf81                	j	ffffffffc020167c <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020172e:	fffdc693          	not	a3,s11
ffffffffc0201732:	96fd                	srai	a3,a3,0x3f
ffffffffc0201734:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201738:	00144603          	lbu	a2,1(s0)
ffffffffc020173c:	2d81                	sext.w	s11,s11
ffffffffc020173e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201740:	bf35                	j	ffffffffc020167c <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201742:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201746:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020174a:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020174c:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020174e:	bfd9                	j	ffffffffc0201724 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201750:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201752:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201756:	01174463          	blt	a4,a7,ffffffffc020175e <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020175a:	1a088e63          	beqz	a7,ffffffffc0201916 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020175e:	000a3603          	ld	a2,0(s4)
ffffffffc0201762:	46c1                	li	a3,16
ffffffffc0201764:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201766:	2781                	sext.w	a5,a5
ffffffffc0201768:	876e                	mv	a4,s11
ffffffffc020176a:	85a6                	mv	a1,s1
ffffffffc020176c:	854a                	mv	a0,s2
ffffffffc020176e:	e1dff0ef          	jal	ra,ffffffffc020158a <printnum>
            break;
ffffffffc0201772:	bde1                	j	ffffffffc020164a <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201774:	000a2503          	lw	a0,0(s4)
ffffffffc0201778:	85a6                	mv	a1,s1
ffffffffc020177a:	0a21                	addi	s4,s4,8
ffffffffc020177c:	9902                	jalr	s2
            break;
ffffffffc020177e:	b5f1                	j	ffffffffc020164a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201780:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201782:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201786:	01174463          	blt	a4,a7,ffffffffc020178e <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020178a:	18088163          	beqz	a7,ffffffffc020190c <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020178e:	000a3603          	ld	a2,0(s4)
ffffffffc0201792:	46a9                	li	a3,10
ffffffffc0201794:	8a2e                	mv	s4,a1
ffffffffc0201796:	bfc1                	j	ffffffffc0201766 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201798:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020179c:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020179e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02017a0:	bdf1                	j	ffffffffc020167c <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02017a2:	85a6                	mv	a1,s1
ffffffffc02017a4:	02500513          	li	a0,37
ffffffffc02017a8:	9902                	jalr	s2
            break;
ffffffffc02017aa:	b545                	j	ffffffffc020164a <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017ac:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02017b0:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017b2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02017b4:	b5e1                	j	ffffffffc020167c <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02017b6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02017b8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02017bc:	01174463          	blt	a4,a7,ffffffffc02017c4 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02017c0:	14088163          	beqz	a7,ffffffffc0201902 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02017c4:	000a3603          	ld	a2,0(s4)
ffffffffc02017c8:	46a1                	li	a3,8
ffffffffc02017ca:	8a2e                	mv	s4,a1
ffffffffc02017cc:	bf69                	j	ffffffffc0201766 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02017ce:	03000513          	li	a0,48
ffffffffc02017d2:	85a6                	mv	a1,s1
ffffffffc02017d4:	e03e                	sd	a5,0(sp)
ffffffffc02017d6:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02017d8:	85a6                	mv	a1,s1
ffffffffc02017da:	07800513          	li	a0,120
ffffffffc02017de:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02017e0:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02017e2:	6782                	ld	a5,0(sp)
ffffffffc02017e4:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02017e6:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02017ea:	bfb5                	j	ffffffffc0201766 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02017ec:	000a3403          	ld	s0,0(s4)
ffffffffc02017f0:	008a0713          	addi	a4,s4,8
ffffffffc02017f4:	e03a                	sd	a4,0(sp)
ffffffffc02017f6:	14040263          	beqz	s0,ffffffffc020193a <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02017fa:	0fb05763          	blez	s11,ffffffffc02018e8 <vprintfmt+0x2d8>
ffffffffc02017fe:	02d00693          	li	a3,45
ffffffffc0201802:	0cd79163          	bne	a5,a3,ffffffffc02018c4 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201806:	00044783          	lbu	a5,0(s0)
ffffffffc020180a:	0007851b          	sext.w	a0,a5
ffffffffc020180e:	cf85                	beqz	a5,ffffffffc0201846 <vprintfmt+0x236>
ffffffffc0201810:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201814:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201818:	000c4563          	bltz	s8,ffffffffc0201822 <vprintfmt+0x212>
ffffffffc020181c:	3c7d                	addiw	s8,s8,-1
ffffffffc020181e:	036c0263          	beq	s8,s6,ffffffffc0201842 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201822:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201824:	0e0c8e63          	beqz	s9,ffffffffc0201920 <vprintfmt+0x310>
ffffffffc0201828:	3781                	addiw	a5,a5,-32
ffffffffc020182a:	0ef47b63          	bgeu	s0,a5,ffffffffc0201920 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020182e:	03f00513          	li	a0,63
ffffffffc0201832:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201834:	000a4783          	lbu	a5,0(s4)
ffffffffc0201838:	3dfd                	addiw	s11,s11,-1
ffffffffc020183a:	0a05                	addi	s4,s4,1
ffffffffc020183c:	0007851b          	sext.w	a0,a5
ffffffffc0201840:	ffe1                	bnez	a5,ffffffffc0201818 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201842:	01b05963          	blez	s11,ffffffffc0201854 <vprintfmt+0x244>
ffffffffc0201846:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201848:	85a6                	mv	a1,s1
ffffffffc020184a:	02000513          	li	a0,32
ffffffffc020184e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201850:	fe0d9be3          	bnez	s11,ffffffffc0201846 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201854:	6a02                	ld	s4,0(sp)
ffffffffc0201856:	bbd5                	j	ffffffffc020164a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201858:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020185a:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020185e:	01174463          	blt	a4,a7,ffffffffc0201866 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201862:	08088d63          	beqz	a7,ffffffffc02018fc <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201866:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020186a:	0a044d63          	bltz	s0,ffffffffc0201924 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020186e:	8622                	mv	a2,s0
ffffffffc0201870:	8a66                	mv	s4,s9
ffffffffc0201872:	46a9                	li	a3,10
ffffffffc0201874:	bdcd                	j	ffffffffc0201766 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201876:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020187a:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020187c:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020187e:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201882:	8fb5                	xor	a5,a5,a3
ffffffffc0201884:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201888:	02d74163          	blt	a4,a3,ffffffffc02018aa <vprintfmt+0x29a>
ffffffffc020188c:	00369793          	slli	a5,a3,0x3
ffffffffc0201890:	97de                	add	a5,a5,s7
ffffffffc0201892:	639c                	ld	a5,0(a5)
ffffffffc0201894:	cb99                	beqz	a5,ffffffffc02018aa <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201896:	86be                	mv	a3,a5
ffffffffc0201898:	00001617          	auipc	a2,0x1
ffffffffc020189c:	e8860613          	addi	a2,a2,-376 # ffffffffc0202720 <slub_pmm_manager+0x68>
ffffffffc02018a0:	85a6                	mv	a1,s1
ffffffffc02018a2:	854a                	mv	a0,s2
ffffffffc02018a4:	0ce000ef          	jal	ra,ffffffffc0201972 <printfmt>
ffffffffc02018a8:	b34d                	j	ffffffffc020164a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02018aa:	00001617          	auipc	a2,0x1
ffffffffc02018ae:	e6660613          	addi	a2,a2,-410 # ffffffffc0202710 <slub_pmm_manager+0x58>
ffffffffc02018b2:	85a6                	mv	a1,s1
ffffffffc02018b4:	854a                	mv	a0,s2
ffffffffc02018b6:	0bc000ef          	jal	ra,ffffffffc0201972 <printfmt>
ffffffffc02018ba:	bb41                	j	ffffffffc020164a <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02018bc:	00001417          	auipc	s0,0x1
ffffffffc02018c0:	e4c40413          	addi	s0,s0,-436 # ffffffffc0202708 <slub_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018c4:	85e2                	mv	a1,s8
ffffffffc02018c6:	8522                	mv	a0,s0
ffffffffc02018c8:	e43e                	sd	a5,8(sp)
ffffffffc02018ca:	142000ef          	jal	ra,ffffffffc0201a0c <strnlen>
ffffffffc02018ce:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02018d2:	01b05b63          	blez	s11,ffffffffc02018e8 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02018d6:	67a2                	ld	a5,8(sp)
ffffffffc02018d8:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018dc:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02018de:	85a6                	mv	a1,s1
ffffffffc02018e0:	8552                	mv	a0,s4
ffffffffc02018e2:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018e4:	fe0d9ce3          	bnez	s11,ffffffffc02018dc <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018e8:	00044783          	lbu	a5,0(s0)
ffffffffc02018ec:	00140a13          	addi	s4,s0,1
ffffffffc02018f0:	0007851b          	sext.w	a0,a5
ffffffffc02018f4:	d3a5                	beqz	a5,ffffffffc0201854 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02018f6:	05e00413          	li	s0,94
ffffffffc02018fa:	bf39                	j	ffffffffc0201818 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02018fc:	000a2403          	lw	s0,0(s4)
ffffffffc0201900:	b7ad                	j	ffffffffc020186a <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201902:	000a6603          	lwu	a2,0(s4)
ffffffffc0201906:	46a1                	li	a3,8
ffffffffc0201908:	8a2e                	mv	s4,a1
ffffffffc020190a:	bdb1                	j	ffffffffc0201766 <vprintfmt+0x156>
ffffffffc020190c:	000a6603          	lwu	a2,0(s4)
ffffffffc0201910:	46a9                	li	a3,10
ffffffffc0201912:	8a2e                	mv	s4,a1
ffffffffc0201914:	bd89                	j	ffffffffc0201766 <vprintfmt+0x156>
ffffffffc0201916:	000a6603          	lwu	a2,0(s4)
ffffffffc020191a:	46c1                	li	a3,16
ffffffffc020191c:	8a2e                	mv	s4,a1
ffffffffc020191e:	b5a1                	j	ffffffffc0201766 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201920:	9902                	jalr	s2
ffffffffc0201922:	bf09                	j	ffffffffc0201834 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201924:	85a6                	mv	a1,s1
ffffffffc0201926:	02d00513          	li	a0,45
ffffffffc020192a:	e03e                	sd	a5,0(sp)
ffffffffc020192c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020192e:	6782                	ld	a5,0(sp)
ffffffffc0201930:	8a66                	mv	s4,s9
ffffffffc0201932:	40800633          	neg	a2,s0
ffffffffc0201936:	46a9                	li	a3,10
ffffffffc0201938:	b53d                	j	ffffffffc0201766 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020193a:	03b05163          	blez	s11,ffffffffc020195c <vprintfmt+0x34c>
ffffffffc020193e:	02d00693          	li	a3,45
ffffffffc0201942:	f6d79de3          	bne	a5,a3,ffffffffc02018bc <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201946:	00001417          	auipc	s0,0x1
ffffffffc020194a:	dc240413          	addi	s0,s0,-574 # ffffffffc0202708 <slub_pmm_manager+0x50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020194e:	02800793          	li	a5,40
ffffffffc0201952:	02800513          	li	a0,40
ffffffffc0201956:	00140a13          	addi	s4,s0,1
ffffffffc020195a:	bd6d                	j	ffffffffc0201814 <vprintfmt+0x204>
ffffffffc020195c:	00001a17          	auipc	s4,0x1
ffffffffc0201960:	dada0a13          	addi	s4,s4,-595 # ffffffffc0202709 <slub_pmm_manager+0x51>
ffffffffc0201964:	02800513          	li	a0,40
ffffffffc0201968:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020196c:	05e00413          	li	s0,94
ffffffffc0201970:	b565                	j	ffffffffc0201818 <vprintfmt+0x208>

ffffffffc0201972 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201972:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201974:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201978:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020197a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020197c:	ec06                	sd	ra,24(sp)
ffffffffc020197e:	f83a                	sd	a4,48(sp)
ffffffffc0201980:	fc3e                	sd	a5,56(sp)
ffffffffc0201982:	e0c2                	sd	a6,64(sp)
ffffffffc0201984:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201986:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201988:	c89ff0ef          	jal	ra,ffffffffc0201610 <vprintfmt>
}
ffffffffc020198c:	60e2                	ld	ra,24(sp)
ffffffffc020198e:	6161                	addi	sp,sp,80
ffffffffc0201990:	8082                	ret

ffffffffc0201992 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
ffffffffc0201992:	711d                	addi	sp,sp,-96
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
    struct sprintbuf b = {str, str + size - 1, 0};
ffffffffc0201994:	15fd                	addi	a1,a1,-1
    va_start(ap, fmt);
ffffffffc0201996:	03810313          	addi	t1,sp,56
    struct sprintbuf b = {str, str + size - 1, 0};
ffffffffc020199a:	95aa                	add	a1,a1,a0
snprintf(char *str, size_t size, const char *fmt, ...) {
ffffffffc020199c:	f406                	sd	ra,40(sp)
ffffffffc020199e:	fc36                	sd	a3,56(sp)
ffffffffc02019a0:	e0ba                	sd	a4,64(sp)
ffffffffc02019a2:	e4be                	sd	a5,72(sp)
ffffffffc02019a4:	e8c2                	sd	a6,80(sp)
ffffffffc02019a6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02019a8:	e01a                	sd	t1,0(sp)
    struct sprintbuf b = {str, str + size - 1, 0};
ffffffffc02019aa:	e42a                	sd	a0,8(sp)
ffffffffc02019ac:	e82e                	sd	a1,16(sp)
ffffffffc02019ae:	cc02                	sw	zero,24(sp)
    if (str == NULL || b.buf > b.ebuf) {
ffffffffc02019b0:	c115                	beqz	a0,ffffffffc02019d4 <snprintf+0x42>
ffffffffc02019b2:	02a5e163          	bltu	a1,a0,ffffffffc02019d4 <snprintf+0x42>
        return -E_INVAL;
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
ffffffffc02019b6:	00000517          	auipc	a0,0x0
ffffffffc02019ba:	c4050513          	addi	a0,a0,-960 # ffffffffc02015f6 <sprintputch>
ffffffffc02019be:	869a                	mv	a3,t1
ffffffffc02019c0:	002c                	addi	a1,sp,8
ffffffffc02019c2:	c4fff0ef          	jal	ra,ffffffffc0201610 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
ffffffffc02019c6:	67a2                	ld	a5,8(sp)
ffffffffc02019c8:	00078023          	sb	zero,0(a5)
    return b.cnt;
ffffffffc02019cc:	4562                	lw	a0,24(sp)
}
ffffffffc02019ce:	70a2                	ld	ra,40(sp)
ffffffffc02019d0:	6125                	addi	sp,sp,96
ffffffffc02019d2:	8082                	ret
        return -E_INVAL;
ffffffffc02019d4:	5575                	li	a0,-3
ffffffffc02019d6:	bfe5                	j	ffffffffc02019ce <snprintf+0x3c>

ffffffffc02019d8 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02019d8:	4781                	li	a5,0
ffffffffc02019da:	00004717          	auipc	a4,0x4
ffffffffc02019de:	63673703          	ld	a4,1590(a4) # ffffffffc0206010 <SBI_CONSOLE_PUTCHAR>
ffffffffc02019e2:	88ba                	mv	a7,a4
ffffffffc02019e4:	852a                	mv	a0,a0
ffffffffc02019e6:	85be                	mv	a1,a5
ffffffffc02019e8:	863e                	mv	a2,a5
ffffffffc02019ea:	00000073          	ecall
ffffffffc02019ee:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02019f0:	8082                	ret

ffffffffc02019f2 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02019f2:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02019f6:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02019f8:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02019fa:	cb81                	beqz	a5,ffffffffc0201a0a <strlen+0x18>
        cnt ++;
ffffffffc02019fc:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02019fe:	00a707b3          	add	a5,a4,a0
ffffffffc0201a02:	0007c783          	lbu	a5,0(a5)
ffffffffc0201a06:	fbfd                	bnez	a5,ffffffffc02019fc <strlen+0xa>
ffffffffc0201a08:	8082                	ret
    }
    return cnt;
}
ffffffffc0201a0a:	8082                	ret

ffffffffc0201a0c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201a0c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a0e:	e589                	bnez	a1,ffffffffc0201a18 <strnlen+0xc>
ffffffffc0201a10:	a811                	j	ffffffffc0201a24 <strnlen+0x18>
        cnt ++;
ffffffffc0201a12:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a14:	00f58863          	beq	a1,a5,ffffffffc0201a24 <strnlen+0x18>
ffffffffc0201a18:	00f50733          	add	a4,a0,a5
ffffffffc0201a1c:	00074703          	lbu	a4,0(a4)
ffffffffc0201a20:	fb6d                	bnez	a4,ffffffffc0201a12 <strnlen+0x6>
ffffffffc0201a22:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201a24:	852e                	mv	a0,a1
ffffffffc0201a26:	8082                	ret

ffffffffc0201a28 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0201a28:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0201a2a:	0005c703          	lbu	a4,0(a1) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0201a2e:	0785                	addi	a5,a5,1
ffffffffc0201a30:	0585                	addi	a1,a1,1
ffffffffc0201a32:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0201a36:	fb75                	bnez	a4,ffffffffc0201a2a <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0201a38:	8082                	ret

ffffffffc0201a3a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a3a:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a3e:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a42:	cb89                	beqz	a5,ffffffffc0201a54 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201a44:	0505                	addi	a0,a0,1
ffffffffc0201a46:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a48:	fee789e3          	beq	a5,a4,ffffffffc0201a3a <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a4c:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201a50:	9d19                	subw	a0,a0,a4
ffffffffc0201a52:	8082                	ret
ffffffffc0201a54:	4501                	li	a0,0
ffffffffc0201a56:	bfed                	j	ffffffffc0201a50 <strcmp+0x16>

ffffffffc0201a58 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201a58:	c20d                	beqz	a2,ffffffffc0201a7a <strncmp+0x22>
ffffffffc0201a5a:	962e                	add	a2,a2,a1
ffffffffc0201a5c:	a031                	j	ffffffffc0201a68 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0201a5e:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201a60:	00e79a63          	bne	a5,a4,ffffffffc0201a74 <strncmp+0x1c>
ffffffffc0201a64:	00b60b63          	beq	a2,a1,ffffffffc0201a7a <strncmp+0x22>
ffffffffc0201a68:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0201a6c:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201a6e:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0201a72:	f7f5                	bnez	a5,ffffffffc0201a5e <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a74:	40e7853b          	subw	a0,a5,a4
}
ffffffffc0201a78:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a7a:	4501                	li	a0,0
ffffffffc0201a7c:	8082                	ret

ffffffffc0201a7e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201a7e:	ca01                	beqz	a2,ffffffffc0201a8e <memset+0x10>
ffffffffc0201a80:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201a82:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201a84:	0785                	addi	a5,a5,1
ffffffffc0201a86:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201a8a:	fec79de3          	bne	a5,a2,ffffffffc0201a84 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201a8e:	8082                	ret

ffffffffc0201a90 <memmove>:
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    if (s < d && s + n > d) {
ffffffffc0201a90:	02a5f263          	bgeu	a1,a0,ffffffffc0201ab4 <memmove+0x24>
ffffffffc0201a94:	00c587b3          	add	a5,a1,a2
ffffffffc0201a98:	00f57e63          	bgeu	a0,a5,ffffffffc0201ab4 <memmove+0x24>
        s += n, d += n;
ffffffffc0201a9c:	00c50733          	add	a4,a0,a2
        while (n -- > 0) {
ffffffffc0201aa0:	c615                	beqz	a2,ffffffffc0201acc <memmove+0x3c>
            *-- d = *-- s;
ffffffffc0201aa2:	fff7c683          	lbu	a3,-1(a5)
ffffffffc0201aa6:	17fd                	addi	a5,a5,-1
ffffffffc0201aa8:	177d                	addi	a4,a4,-1
ffffffffc0201aaa:	00d70023          	sb	a3,0(a4)
        while (n -- > 0) {
ffffffffc0201aae:	fef59ae3          	bne	a1,a5,ffffffffc0201aa2 <memmove+0x12>
ffffffffc0201ab2:	8082                	ret
        }
    } else {
        while (n -- > 0) {
ffffffffc0201ab4:	00c586b3          	add	a3,a1,a2
ffffffffc0201ab8:	87aa                	mv	a5,a0
ffffffffc0201aba:	ca11                	beqz	a2,ffffffffc0201ace <memmove+0x3e>
            *d ++ = *s ++;
ffffffffc0201abc:	0005c703          	lbu	a4,0(a1)
ffffffffc0201ac0:	0585                	addi	a1,a1,1
ffffffffc0201ac2:	0785                	addi	a5,a5,1
ffffffffc0201ac4:	fee78fa3          	sb	a4,-1(a5)
        while (n -- > 0) {
ffffffffc0201ac8:	fed59ae3          	bne	a1,a3,ffffffffc0201abc <memmove+0x2c>
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
ffffffffc0201acc:	8082                	ret
ffffffffc0201ace:	8082                	ret
