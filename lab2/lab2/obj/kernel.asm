
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
ffffffffc0200050:	a7450513          	addi	a0,a0,-1420 # ffffffffc0201ac0 <etext>
void print_kerninfo(void) {
ffffffffc0200054:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200056:	0f6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", (uintptr_t)kern_init);
ffffffffc020005a:	00000597          	auipc	a1,0x0
ffffffffc020005e:	07e58593          	addi	a1,a1,126 # ffffffffc02000d8 <kern_init>
ffffffffc0200062:	00002517          	auipc	a0,0x2
ffffffffc0200066:	a7e50513          	addi	a0,a0,-1410 # ffffffffc0201ae0 <etext+0x20>
ffffffffc020006a:	0e2000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020006e:	00002597          	auipc	a1,0x2
ffffffffc0200072:	a5258593          	addi	a1,a1,-1454 # ffffffffc0201ac0 <etext>
ffffffffc0200076:	00002517          	auipc	a0,0x2
ffffffffc020007a:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0201b00 <etext+0x40>
ffffffffc020007e:	0ce000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200082:	00006597          	auipc	a1,0x6
ffffffffc0200086:	f9658593          	addi	a1,a1,-106 # ffffffffc0206018 <slub_allocator>
ffffffffc020008a:	00002517          	auipc	a0,0x2
ffffffffc020008e:	a9650513          	addi	a0,a0,-1386 # ffffffffc0201b20 <etext+0x60>
ffffffffc0200092:	0ba000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200096:	00016597          	auipc	a1,0x16
ffffffffc020009a:	05a58593          	addi	a1,a1,90 # ffffffffc02160f0 <end>
ffffffffc020009e:	00002517          	auipc	a0,0x2
ffffffffc02000a2:	aa250513          	addi	a0,a0,-1374 # ffffffffc0201b40 <etext+0x80>
ffffffffc02000a6:	0a6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - (char*)kern_init + 1023) / 1024);
ffffffffc02000aa:	00016597          	auipc	a1,0x16
ffffffffc02000ae:	44558593          	addi	a1,a1,1093 # ffffffffc02164ef <end+0x3ff>
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
ffffffffc02000d0:	a9450513          	addi	a0,a0,-1388 # ffffffffc0201b60 <etext+0xa0>
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
ffffffffc02000e4:	01060613          	addi	a2,a2,16 # ffffffffc02160f0 <end>
int kern_init(void) {
ffffffffc02000e8:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc02000ea:	8e09                	sub	a2,a2,a0
ffffffffc02000ec:	4581                	li	a1,0
int kern_init(void) {
ffffffffc02000ee:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc02000f0:	1bf010ef          	jal	ra,ffffffffc0201aae <memset>
    dtb_init();
ffffffffc02000f4:	12c000ef          	jal	ra,ffffffffc0200220 <dtb_init>
    cons_init();  // init the console
ffffffffc02000f8:	11e000ef          	jal	ra,ffffffffc0200216 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc02000fc:	00002517          	auipc	a0,0x2
ffffffffc0200100:	a9450513          	addi	a0,a0,-1388 # ffffffffc0201b90 <etext+0xd0>
ffffffffc0200104:	07e000ef          	jal	ra,ffffffffc0200182 <cputs>

    print_kerninfo();
ffffffffc0200108:	f43ff0ef          	jal	ra,ffffffffc020004a <print_kerninfo>

    // grade_backtrace();
    pmm_init();  // init physical memory management
ffffffffc020010c:	4dc000ef          	jal	ra,ffffffffc02005e8 <pmm_init>

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
ffffffffc0200140:	558010ef          	jal	ra,ffffffffc0201698 <vprintfmt>
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
ffffffffc0200176:	522010ef          	jal	ra,ffffffffc0201698 <vprintfmt>
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
ffffffffc02001c6:	ede30313          	addi	t1,t1,-290 # ffffffffc02160a0 <is_panic>
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
ffffffffc02001f6:	9be50513          	addi	a0,a0,-1602 # ffffffffc0201bb0 <etext+0xf0>
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
ffffffffc020020c:	ff850513          	addi	a0,a0,-8 # ffffffffc0202200 <etext+0x740>
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
ffffffffc020021c:	7fe0106f          	j	ffffffffc0201a1a <sbi_console_putchar>

ffffffffc0200220 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc0200220:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc0200222:	00002517          	auipc	a0,0x2
ffffffffc0200226:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0201bd0 <etext+0x110>
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
ffffffffc0200254:	99050513          	addi	a0,a0,-1648 # ffffffffc0201be0 <etext+0x120>
ffffffffc0200258:	ef5ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020025c:	00006417          	auipc	s0,0x6
ffffffffc0200260:	dac40413          	addi	s0,s0,-596 # ffffffffc0206008 <boot_dtb>
ffffffffc0200264:	600c                	ld	a1,0(s0)
ffffffffc0200266:	00002517          	auipc	a0,0x2
ffffffffc020026a:	98a50513          	addi	a0,a0,-1654 # ffffffffc0201bf0 <etext+0x130>
ffffffffc020026e:	edfff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200272:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200276:	00002517          	auipc	a0,0x2
ffffffffc020027a:	99250513          	addi	a0,a0,-1646 # ffffffffc0201c08 <etext+0x148>
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
ffffffffc02002be:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfec9dfd>
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
ffffffffc0200334:	92890913          	addi	s2,s2,-1752 # ffffffffc0201c58 <etext+0x198>
ffffffffc0200338:	49bd                	li	s3,15
        switch (token) {
ffffffffc020033a:	4d91                	li	s11,4
ffffffffc020033c:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020033e:	00002497          	auipc	s1,0x2
ffffffffc0200342:	91248493          	addi	s1,s1,-1774 # ffffffffc0201c50 <etext+0x190>
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
ffffffffc0200396:	93e50513          	addi	a0,a0,-1730 # ffffffffc0201cd0 <etext+0x210>
ffffffffc020039a:	db3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	96a50513          	addi	a0,a0,-1686 # ffffffffc0201d08 <etext+0x248>
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
ffffffffc02003e2:	84a50513          	addi	a0,a0,-1974 # ffffffffc0201c28 <etext+0x168>
}
ffffffffc02003e6:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003e8:	b395                	j	ffffffffc020014c <cprintf>
                int name_len = strlen(name);
ffffffffc02003ea:	8556                	mv	a0,s5
ffffffffc02003ec:	648010ef          	jal	ra,ffffffffc0201a34 <strlen>
ffffffffc02003f0:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003f2:	4619                	li	a2,6
ffffffffc02003f4:	85a6                	mv	a1,s1
ffffffffc02003f6:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02003f8:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003fa:	68e010ef          	jal	ra,ffffffffc0201a88 <strncmp>
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
ffffffffc0200490:	5da010ef          	jal	ra,ffffffffc0201a6a <strcmp>
ffffffffc0200494:	66a2                	ld	a3,8(sp)
ffffffffc0200496:	f94d                	bnez	a0,ffffffffc0200448 <dtb_init+0x228>
ffffffffc0200498:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200448 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc020049c:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc02004a0:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc02004a4:	00001517          	auipc	a0,0x1
ffffffffc02004a8:	7bc50513          	addi	a0,a0,1980 # ffffffffc0201c60 <etext+0x1a0>
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
ffffffffc0200576:	70e50513          	addi	a0,a0,1806 # ffffffffc0201c80 <etext+0x1c0>
ffffffffc020057a:	bd3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020057e:	014b5613          	srli	a2,s6,0x14
ffffffffc0200582:	85da                	mv	a1,s6
ffffffffc0200584:	00001517          	auipc	a0,0x1
ffffffffc0200588:	71450513          	addi	a0,a0,1812 # ffffffffc0201c98 <etext+0x1d8>
ffffffffc020058c:	bc1ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200590:	008b05b3          	add	a1,s6,s0
ffffffffc0200594:	15fd                	addi	a1,a1,-1
ffffffffc0200596:	00001517          	auipc	a0,0x1
ffffffffc020059a:	72250513          	addi	a0,a0,1826 # ffffffffc0201cb8 <etext+0x1f8>
ffffffffc020059e:	bafff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB init completed\n");
ffffffffc02005a2:	00001517          	auipc	a0,0x1
ffffffffc02005a6:	76650513          	addi	a0,a0,1894 # ffffffffc0201d08 <etext+0x248>
        memory_base = mem_base;
ffffffffc02005aa:	00016797          	auipc	a5,0x16
ffffffffc02005ae:	ae87bf23          	sd	s0,-1282(a5) # ffffffffc02160a8 <memory_base>
        memory_size = mem_size;
ffffffffc02005b2:	00016797          	auipc	a5,0x16
ffffffffc02005b6:	af67bf23          	sd	s6,-1282(a5) # ffffffffc02160b0 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc02005ba:	b3f5                	j	ffffffffc02003a6 <dtb_init+0x186>

ffffffffc02005bc <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02005bc:	00016517          	auipc	a0,0x16
ffffffffc02005c0:	aec53503          	ld	a0,-1300(a0) # ffffffffc02160a8 <memory_base>
ffffffffc02005c4:	8082                	ret

ffffffffc02005c6 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
ffffffffc02005c6:	00016517          	auipc	a0,0x16
ffffffffc02005ca:	aea53503          	ld	a0,-1302(a0) # ffffffffc02160b0 <memory_size>
ffffffffc02005ce:	8082                	ret

ffffffffc02005d0 <alloc_pages>:
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
    return pmm_manager->alloc_pages(n);
ffffffffc02005d0:	00016797          	auipc	a5,0x16
ffffffffc02005d4:	af87b783          	ld	a5,-1288(a5) # ffffffffc02160c8 <pmm_manager>
ffffffffc02005d8:	6f9c                	ld	a5,24(a5)
ffffffffc02005da:	8782                	jr	a5

ffffffffc02005dc <free_pages>:
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    pmm_manager->free_pages(base, n);
ffffffffc02005dc:	00016797          	auipc	a5,0x16
ffffffffc02005e0:	aec7b783          	ld	a5,-1300(a5) # ffffffffc02160c8 <pmm_manager>
ffffffffc02005e4:	739c                	ld	a5,32(a5)
ffffffffc02005e6:	8782                	jr	a5

ffffffffc02005e8 <pmm_init>:
    pmm_manager = &slub_pmm_manager;
ffffffffc02005e8:	00002797          	auipc	a5,0x2
ffffffffc02005ec:	38878793          	addi	a5,a5,904 # ffffffffc0202970 <slub_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02005f0:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02005f2:	7179                	addi	sp,sp,-48
ffffffffc02005f4:	f022                	sd	s0,32(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02005f6:	00001517          	auipc	a0,0x1
ffffffffc02005fa:	72a50513          	addi	a0,a0,1834 # ffffffffc0201d20 <etext+0x260>
    pmm_manager = &slub_pmm_manager;
ffffffffc02005fe:	00016417          	auipc	s0,0x16
ffffffffc0200602:	aca40413          	addi	s0,s0,-1334 # ffffffffc02160c8 <pmm_manager>
void pmm_init(void) {
ffffffffc0200606:	f406                	sd	ra,40(sp)
ffffffffc0200608:	ec26                	sd	s1,24(sp)
ffffffffc020060a:	e44e                	sd	s3,8(sp)
ffffffffc020060c:	e84a                	sd	s2,16(sp)
ffffffffc020060e:	e052                	sd	s4,0(sp)
    pmm_manager = &slub_pmm_manager;
ffffffffc0200610:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200612:	b3bff0ef          	jal	ra,ffffffffc020014c <cprintf>
    pmm_manager->init();
ffffffffc0200616:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200618:	00016497          	auipc	s1,0x16
ffffffffc020061c:	ac848493          	addi	s1,s1,-1336 # ffffffffc02160e0 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200620:	679c                	ld	a5,8(a5)
ffffffffc0200622:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200624:	57f5                	li	a5,-3
ffffffffc0200626:	07fa                	slli	a5,a5,0x1e
ffffffffc0200628:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();
ffffffffc020062a:	f93ff0ef          	jal	ra,ffffffffc02005bc <get_memory_base>
ffffffffc020062e:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc0200630:	f97ff0ef          	jal	ra,ffffffffc02005c6 <get_memory_size>
    if (mem_size == 0) {
ffffffffc0200634:	14050c63          	beqz	a0,ffffffffc020078c <pmm_init+0x1a4>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200638:	892a                	mv	s2,a0
    cprintf("physcial memory map:\n");
ffffffffc020063a:	00001517          	auipc	a0,0x1
ffffffffc020063e:	72e50513          	addi	a0,a0,1838 # ffffffffc0201d68 <etext+0x2a8>
ffffffffc0200642:	b0bff0ef          	jal	ra,ffffffffc020014c <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200646:	01298a33          	add	s4,s3,s2
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020064a:	864e                	mv	a2,s3
ffffffffc020064c:	fffa0693          	addi	a3,s4,-1
ffffffffc0200650:	85ca                	mv	a1,s2
ffffffffc0200652:	00001517          	auipc	a0,0x1
ffffffffc0200656:	72e50513          	addi	a0,a0,1838 # ffffffffc0201d80 <etext+0x2c0>
ffffffffc020065a:	af3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc020065e:	c80007b7          	lui	a5,0xc8000
ffffffffc0200662:	8652                	mv	a2,s4
ffffffffc0200664:	0d47e363          	bltu	a5,s4,ffffffffc020072a <pmm_init+0x142>
ffffffffc0200668:	00017797          	auipc	a5,0x17
ffffffffc020066c:	a8778793          	addi	a5,a5,-1401 # ffffffffc02170ef <end+0xfff>
ffffffffc0200670:	757d                	lui	a0,0xfffff
ffffffffc0200672:	8d7d                	and	a0,a0,a5
ffffffffc0200674:	8231                	srli	a2,a2,0xc
ffffffffc0200676:	00016797          	auipc	a5,0x16
ffffffffc020067a:	a4c7b123          	sd	a2,-1470(a5) # ffffffffc02160b8 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020067e:	00016797          	auipc	a5,0x16
ffffffffc0200682:	a4a7b123          	sd	a0,-1470(a5) # ffffffffc02160c0 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200686:	000807b7          	lui	a5,0x80
ffffffffc020068a:	002005b7          	lui	a1,0x200
ffffffffc020068e:	02f60563          	beq	a2,a5,ffffffffc02006b8 <pmm_init+0xd0>
ffffffffc0200692:	00261593          	slli	a1,a2,0x2
ffffffffc0200696:	00c586b3          	add	a3,a1,a2
ffffffffc020069a:	fec007b7          	lui	a5,0xfec00
ffffffffc020069e:	97aa                	add	a5,a5,a0
ffffffffc02006a0:	068e                	slli	a3,a3,0x3
ffffffffc02006a2:	96be                	add	a3,a3,a5
ffffffffc02006a4:	87aa                	mv	a5,a0
        SetPageReserved(pages + i);
ffffffffc02006a6:	6798                	ld	a4,8(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02006a8:	02878793          	addi	a5,a5,40 # fffffffffec00028 <end+0x3e9e9f38>
        SetPageReserved(pages + i);
ffffffffc02006ac:	00176713          	ori	a4,a4,1
ffffffffc02006b0:	fee7b023          	sd	a4,-32(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02006b4:	fef699e3          	bne	a3,a5,ffffffffc02006a6 <pmm_init+0xbe>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02006b8:	95b2                	add	a1,a1,a2
ffffffffc02006ba:	fec006b7          	lui	a3,0xfec00
ffffffffc02006be:	96aa                	add	a3,a3,a0
ffffffffc02006c0:	058e                	slli	a1,a1,0x3
ffffffffc02006c2:	96ae                	add	a3,a3,a1
ffffffffc02006c4:	c02007b7          	lui	a5,0xc0200
ffffffffc02006c8:	0af6e663          	bltu	a3,a5,ffffffffc0200774 <pmm_init+0x18c>
ffffffffc02006cc:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc02006ce:	77fd                	lui	a5,0xfffff
ffffffffc02006d0:	00fa75b3          	and	a1,s4,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02006d4:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02006d6:	04b6ed63          	bltu	a3,a1,ffffffffc0200730 <pmm_init+0x148>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02006da:	601c                	ld	a5,0(s0)
ffffffffc02006dc:	7b9c                	ld	a5,48(a5)
ffffffffc02006de:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	72850513          	addi	a0,a0,1832 # ffffffffc0201e08 <etext+0x348>
ffffffffc02006e8:	a65ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02006ec:	00005597          	auipc	a1,0x5
ffffffffc02006f0:	91458593          	addi	a1,a1,-1772 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02006f4:	00016797          	auipc	a5,0x16
ffffffffc02006f8:	9eb7b223          	sd	a1,-1564(a5) # ffffffffc02160d8 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02006fc:	c02007b7          	lui	a5,0xc0200
ffffffffc0200700:	0af5e263          	bltu	a1,a5,ffffffffc02007a4 <pmm_init+0x1bc>
ffffffffc0200704:	6090                	ld	a2,0(s1)
}
ffffffffc0200706:	7402                	ld	s0,32(sp)
ffffffffc0200708:	70a2                	ld	ra,40(sp)
ffffffffc020070a:	64e2                	ld	s1,24(sp)
ffffffffc020070c:	6942                	ld	s2,16(sp)
ffffffffc020070e:	69a2                	ld	s3,8(sp)
ffffffffc0200710:	6a02                	ld	s4,0(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200712:	40c58633          	sub	a2,a1,a2
ffffffffc0200716:	00016797          	auipc	a5,0x16
ffffffffc020071a:	9ac7bd23          	sd	a2,-1606(a5) # ffffffffc02160d0 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020071e:	00001517          	auipc	a0,0x1
ffffffffc0200722:	70a50513          	addi	a0,a0,1802 # ffffffffc0201e28 <etext+0x368>
}
ffffffffc0200726:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200728:	b415                	j	ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc020072a:	c8000637          	lui	a2,0xc8000
ffffffffc020072e:	bf2d                	j	ffffffffc0200668 <pmm_init+0x80>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200730:	6705                	lui	a4,0x1
ffffffffc0200732:	177d                	addi	a4,a4,-1
ffffffffc0200734:	96ba                	add	a3,a3,a4
ffffffffc0200736:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200738:	00c6d793          	srli	a5,a3,0xc
ffffffffc020073c:	02c7f063          	bgeu	a5,a2,ffffffffc020075c <pmm_init+0x174>
    pmm_manager->init_memmap(base, n);
ffffffffc0200740:	6010                	ld	a2,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200742:	fff80737          	lui	a4,0xfff80
ffffffffc0200746:	973e                	add	a4,a4,a5
ffffffffc0200748:	00271793          	slli	a5,a4,0x2
ffffffffc020074c:	97ba                	add	a5,a5,a4
ffffffffc020074e:	6a18                	ld	a4,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200750:	8d95                	sub	a1,a1,a3
ffffffffc0200752:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200754:	81b1                	srli	a1,a1,0xc
ffffffffc0200756:	953e                	add	a0,a0,a5
ffffffffc0200758:	9702                	jalr	a4
}
ffffffffc020075a:	b741                	j	ffffffffc02006da <pmm_init+0xf2>
        panic("pa2page called with invalid pa");
ffffffffc020075c:	00001617          	auipc	a2,0x1
ffffffffc0200760:	67c60613          	addi	a2,a2,1660 # ffffffffc0201dd8 <etext+0x318>
ffffffffc0200764:	06a00593          	li	a1,106
ffffffffc0200768:	00001517          	auipc	a0,0x1
ffffffffc020076c:	69050513          	addi	a0,a0,1680 # ffffffffc0201df8 <etext+0x338>
ffffffffc0200770:	a53ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200774:	00001617          	auipc	a2,0x1
ffffffffc0200778:	63c60613          	addi	a2,a2,1596 # ffffffffc0201db0 <etext+0x2f0>
ffffffffc020077c:	06100593          	li	a1,97
ffffffffc0200780:	00001517          	auipc	a0,0x1
ffffffffc0200784:	5d850513          	addi	a0,a0,1496 # ffffffffc0201d58 <etext+0x298>
ffffffffc0200788:	a3bff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("DTB memory info not available");
ffffffffc020078c:	00001617          	auipc	a2,0x1
ffffffffc0200790:	5ac60613          	addi	a2,a2,1452 # ffffffffc0201d38 <etext+0x278>
ffffffffc0200794:	04900593          	li	a1,73
ffffffffc0200798:	00001517          	auipc	a0,0x1
ffffffffc020079c:	5c050513          	addi	a0,a0,1472 # ffffffffc0201d58 <etext+0x298>
ffffffffc02007a0:	a23ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02007a4:	86ae                	mv	a3,a1
ffffffffc02007a6:	00001617          	auipc	a2,0x1
ffffffffc02007aa:	60a60613          	addi	a2,a2,1546 # ffffffffc0201db0 <etext+0x2f0>
ffffffffc02007ae:	07c00593          	li	a1,124
ffffffffc02007b2:	00001517          	auipc	a0,0x1
ffffffffc02007b6:	5a650513          	addi	a0,a0,1446 # ffffffffc0201d58 <etext+0x298>
ffffffffc02007ba:	a09ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02007be <slub_nr_free_pages>:
static size_t slub_nr_free_pages(void) {
    extern struct Page *pages;
    extern size_t npage;

    size_t free_pages = 0;
    for (size_t i = 0; i < npage; i++) {
ffffffffc02007be:	00016517          	auipc	a0,0x16
ffffffffc02007c2:	8fa53503          	ld	a0,-1798(a0) # ffffffffc02160b8 <npage>
ffffffffc02007c6:	c505                	beqz	a0,ffffffffc02007ee <slub_nr_free_pages+0x30>
ffffffffc02007c8:	00251693          	slli	a3,a0,0x2
ffffffffc02007cc:	96aa                	add	a3,a3,a0
ffffffffc02007ce:	00016717          	auipc	a4,0x16
ffffffffc02007d2:	8f273703          	ld	a4,-1806(a4) # ffffffffc02160c0 <pages>
ffffffffc02007d6:	068e                	slli	a3,a3,0x3
ffffffffc02007d8:	96ba                	add	a3,a3,a4
    size_t free_pages = 0;
ffffffffc02007da:	4501                	li	a0,0
        if (!PageReserved(pages + i) && !PageProperty(pages + i))
ffffffffc02007dc:	671c                	ld	a5,8(a4)
    for (size_t i = 0; i < npage; i++) {
ffffffffc02007de:	02870713          	addi	a4,a4,40
        if (!PageReserved(pages + i) && !PageProperty(pages + i))
ffffffffc02007e2:	8b8d                	andi	a5,a5,3
            free_pages++;
ffffffffc02007e4:	0017b793          	seqz	a5,a5
ffffffffc02007e8:	953e                	add	a0,a0,a5
    for (size_t i = 0; i < npage; i++) {
ffffffffc02007ea:	fed719e3          	bne	a4,a3,ffffffffc02007dc <slub_nr_free_pages+0x1e>
    }

    return free_pages;
}
ffffffffc02007ee:	8082                	ret

ffffffffc02007f0 <slub_init_memmap>:
static void slub_init_memmap(struct Page *base, size_t n) {
ffffffffc02007f0:	1101                	addi	sp,sp,-32
ffffffffc02007f2:	ec06                	sd	ra,24(sp)
ffffffffc02007f4:	e822                	sd	s0,16(sp)
ffffffffc02007f6:	e426                	sd	s1,8(sp)
ffffffffc02007f8:	e04a                	sd	s2,0(sp)
    assert(n > 0);
ffffffffc02007fa:	cdd1                	beqz	a1,ffffffffc0200896 <slub_init_memmap+0xa6>
    size_t info_size = n * sizeof(struct slub_page_info);
ffffffffc02007fc:	00259613          	slli	a2,a1,0x2
ffffffffc0200800:	962e                	add	a2,a2,a1
    size_t info_pages = (info_size + PGSIZE - 1) / PGSIZE;
ffffffffc0200802:	6905                	lui	s2,0x1
    size_t info_size = n * sizeof(struct slub_page_info);
ffffffffc0200804:	060e                	slli	a2,a2,0x3
    size_t info_pages = (info_size + PGSIZE - 1) / PGSIZE;
ffffffffc0200806:	197d                	addi	s2,s2,-1
    slub_allocator.max_pages = n;
ffffffffc0200808:	00006797          	auipc	a5,0x6
ffffffffc020080c:	81078793          	addi	a5,a5,-2032 # ffffffffc0206018 <slub_allocator>
    size_t info_pages = (info_size + PGSIZE - 1) / PGSIZE;
ffffffffc0200810:	9932                	add	s2,s2,a2
    slub_allocator.max_pages = n;
ffffffffc0200812:	e3cc                	sd	a1,128(a5)
    size_t info_pages = (info_size + PGSIZE - 1) / PGSIZE;
ffffffffc0200814:	00c95913          	srli	s2,s2,0xc
ffffffffc0200818:	84ae                	mv	s1,a1
    if (info_pages >= n)
ffffffffc020081a:	08b97e63          	bgeu	s2,a1,ffffffffc02008b6 <slub_init_memmap+0xc6>
    slub_allocator.page_infos = (struct slub_page_info *)page2kva(base);
ffffffffc020081e:	842a                	mv	s0,a0
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200820:	00016517          	auipc	a0,0x16
ffffffffc0200824:	8a053503          	ld	a0,-1888(a0) # ffffffffc02160c0 <pages>
ffffffffc0200828:	40a40533          	sub	a0,s0,a0
ffffffffc020082c:	00002717          	auipc	a4,0x2
ffffffffc0200830:	3cc73703          	ld	a4,972(a4) # ffffffffc0202bf8 <nbase+0x8>
ffffffffc0200834:	850d                	srai	a0,a0,0x3
ffffffffc0200836:	02e50533          	mul	a0,a0,a4
ffffffffc020083a:	00002717          	auipc	a4,0x2
ffffffffc020083e:	3b673703          	ld	a4,950(a4) # ffffffffc0202bf0 <nbase>
    memset(slub_allocator.page_infos, 0, info_size);
ffffffffc0200842:	4581                	li	a1,0
ffffffffc0200844:	953a                	add	a0,a0,a4
    return page2ppn(page) << PGSHIFT;
ffffffffc0200846:	0532                	slli	a0,a0,0xc
    slub_allocator.page_infos = (struct slub_page_info *)page2kva(base);
ffffffffc0200848:	00016717          	auipc	a4,0x16
ffffffffc020084c:	89873703          	ld	a4,-1896(a4) # ffffffffc02160e0 <va_pa_offset>
ffffffffc0200850:	953a                	add	a0,a0,a4
ffffffffc0200852:	ffa8                	sd	a0,120(a5)
    memset(slub_allocator.page_infos, 0, info_size);
ffffffffc0200854:	25a010ef          	jal	ra,ffffffffc0201aae <memset>
    struct Page *p = base + info_pages;
ffffffffc0200858:	00291513          	slli	a0,s2,0x2
ffffffffc020085c:	954a                	add	a0,a0,s2
ffffffffc020085e:	050e                	slli	a0,a0,0x3
ffffffffc0200860:	9522                	add	a0,a0,s0
ffffffffc0200862:	874a                	mv	a4,s2
        ClearPageProperty(p);
ffffffffc0200864:	651c                	ld	a5,8(a0)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200866:	00052023          	sw	zero,0(a0)
    for (size_t i = info_pages; i < n; i++, p++) {
ffffffffc020086a:	0705                	addi	a4,a4,1
        ClearPageProperty(p);
ffffffffc020086c:	9bf1                	andi	a5,a5,-4
ffffffffc020086e:	e51c                	sd	a5,8(a0)
    for (size_t i = info_pages; i < n; i++, p++) {
ffffffffc0200870:	02850513          	addi	a0,a0,40
ffffffffc0200874:	fee498e3          	bne	s1,a4,ffffffffc0200864 <slub_init_memmap+0x74>
}
ffffffffc0200878:	6442                	ld	s0,16(sp)
ffffffffc020087a:	60e2                	ld	ra,24(sp)
    cprintf("SLUB memmap initialized: %u pages, %u info pages\n",
ffffffffc020087c:	0009061b          	sext.w	a2,s2
ffffffffc0200880:	0004859b          	sext.w	a1,s1
}
ffffffffc0200884:	6902                	ld	s2,0(sp)
ffffffffc0200886:	64a2                	ld	s1,8(sp)
    cprintf("SLUB memmap initialized: %u pages, %u info pages\n",
ffffffffc0200888:	00001517          	auipc	a0,0x1
ffffffffc020088c:	64850513          	addi	a0,a0,1608 # ffffffffc0201ed0 <etext+0x410>
}
ffffffffc0200890:	6105                	addi	sp,sp,32
    cprintf("SLUB memmap initialized: %u pages, %u info pages\n",
ffffffffc0200892:	8bbff06f          	j	ffffffffc020014c <cprintf>
    assert(n > 0);
ffffffffc0200896:	00001697          	auipc	a3,0x1
ffffffffc020089a:	5d268693          	addi	a3,a3,1490 # ffffffffc0201e68 <etext+0x3a8>
ffffffffc020089e:	00001617          	auipc	a2,0x1
ffffffffc02008a2:	5d260613          	addi	a2,a2,1490 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc02008a6:	0a400593          	li	a1,164
ffffffffc02008aa:	00001517          	auipc	a0,0x1
ffffffffc02008ae:	5de50513          	addi	a0,a0,1502 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc02008b2:	911ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("Not enough memory for SLUB page info array");
ffffffffc02008b6:	00001617          	auipc	a2,0x1
ffffffffc02008ba:	5ea60613          	addi	a2,a2,1514 # ffffffffc0201ea0 <etext+0x3e0>
ffffffffc02008be:	0ad00593          	li	a1,173
ffffffffc02008c2:	00001517          	auipc	a0,0x1
ffffffffc02008c6:	5c650513          	addi	a0,a0,1478 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc02008ca:	8f9ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02008ce <slub_free_pages>:
static void slub_free_pages(struct Page *base, size_t n) {
ffffffffc02008ce:	1141                	addi	sp,sp,-16
ffffffffc02008d0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02008d2:	c5bd                	beqz	a1,ffffffffc0200940 <slub_free_pages+0x72>
    assert(PageReserved(base));
ffffffffc02008d4:	651c                	ld	a5,8(a0)
    for (size_t i = 0; i < n; i++) {
ffffffffc02008d6:	4701                	li	a4,0
    assert(PageReserved(base));
ffffffffc02008d8:	0017f693          	andi	a3,a5,1
ffffffffc02008dc:	ea81                	bnez	a3,ffffffffc02008ec <slub_free_pages+0x1e>
ffffffffc02008de:	a089                	j	ffffffffc0200920 <slub_free_pages+0x52>
        assert(PageReserved(p));
ffffffffc02008e0:	791c                	ld	a5,48(a0)
ffffffffc02008e2:	02850513          	addi	a0,a0,40
ffffffffc02008e6:	0017f693          	andi	a3,a5,1
ffffffffc02008ea:	ca99                	beqz	a3,ffffffffc0200900 <slub_free_pages+0x32>
        ClearPageSlab(p);
ffffffffc02008ec:	9be9                	andi	a5,a5,-6
ffffffffc02008ee:	e51c                	sd	a5,8(a0)
ffffffffc02008f0:	00052023          	sw	zero,0(a0)
    for (size_t i = 0; i < n; i++) {
ffffffffc02008f4:	0705                	addi	a4,a4,1
ffffffffc02008f6:	fee595e3          	bne	a1,a4,ffffffffc02008e0 <slub_free_pages+0x12>
}
ffffffffc02008fa:	60a2                	ld	ra,8(sp)
ffffffffc02008fc:	0141                	addi	sp,sp,16
ffffffffc02008fe:	8082                	ret
        assert(PageReserved(p));
ffffffffc0200900:	00001697          	auipc	a3,0x1
ffffffffc0200904:	62068693          	addi	a3,a3,1568 # ffffffffc0201f20 <etext+0x460>
ffffffffc0200908:	00001617          	auipc	a2,0x1
ffffffffc020090c:	56860613          	addi	a2,a2,1384 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc0200910:	0f000593          	li	a1,240
ffffffffc0200914:	00001517          	auipc	a0,0x1
ffffffffc0200918:	57450513          	addi	a0,a0,1396 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc020091c:	8a7ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(PageReserved(base));
ffffffffc0200920:	00001697          	auipc	a3,0x1
ffffffffc0200924:	5e868693          	addi	a3,a3,1512 # ffffffffc0201f08 <etext+0x448>
ffffffffc0200928:	00001617          	auipc	a2,0x1
ffffffffc020092c:	54860613          	addi	a2,a2,1352 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc0200930:	0ec00593          	li	a1,236
ffffffffc0200934:	00001517          	auipc	a0,0x1
ffffffffc0200938:	55450513          	addi	a0,a0,1364 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc020093c:	887ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc0200940:	00001697          	auipc	a3,0x1
ffffffffc0200944:	52868693          	addi	a3,a3,1320 # ffffffffc0201e68 <etext+0x3a8>
ffffffffc0200948:	00001617          	auipc	a2,0x1
ffffffffc020094c:	52860613          	addi	a2,a2,1320 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc0200950:	0eb00593          	li	a1,235
ffffffffc0200954:	00001517          	auipc	a0,0x1
ffffffffc0200958:	53450513          	addi	a0,a0,1332 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc020095c:	867ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200960 <slub_alloc_pages>:
    assert(n > 0);
ffffffffc0200960:	c141                	beqz	a0,ffffffffc02009e0 <slub_alloc_pages+0x80>
    for (size_t i = 0; i < npage; i++) {
ffffffffc0200962:	00015817          	auipc	a6,0x15
ffffffffc0200966:	75683803          	ld	a6,1878(a6) # ffffffffc02160b8 <npage>
ffffffffc020096a:	06080963          	beqz	a6,ffffffffc02009dc <slub_alloc_pages+0x7c>
ffffffffc020096e:	88aa                	mv	a7,a0
ffffffffc0200970:	00015597          	auipc	a1,0x15
ffffffffc0200974:	7505b583          	ld	a1,1872(a1) # ffffffffc02160c0 <pages>
ffffffffc0200978:	4601                	li	a2,0
ffffffffc020097a:	a031                	j	ffffffffc0200986 <slub_alloc_pages+0x26>
ffffffffc020097c:	0605                	addi	a2,a2,1
ffffffffc020097e:	02858593          	addi	a1,a1,40
ffffffffc0200982:	05060d63          	beq	a2,a6,ffffffffc02009dc <slub_alloc_pages+0x7c>
        if (PageReserved(p) || PageProperty(p))
ffffffffc0200986:	0085b303          	ld	t1,8(a1)
        struct Page *p = pages + i;
ffffffffc020098a:	852e                	mv	a0,a1
        if (PageReserved(p) || PageProperty(p))
ffffffffc020098c:	86ae                	mv	a3,a1
ffffffffc020098e:	00337793          	andi	a5,t1,3
ffffffffc0200992:	f7ed                	bnez	a5,ffffffffc020097c <slub_alloc_pages+0x1c>
        for (size_t j = 0; j < n && (i + j) < npage; j++) {
ffffffffc0200994:	00f60733          	add	a4,a2,a5
ffffffffc0200998:	03077b63          	bgeu	a4,a6,ffffffffc02009ce <slub_alloc_pages+0x6e>
            if (PageReserved(pages + i + j) || PageProperty(pages + i + j))
ffffffffc020099c:	6698                	ld	a4,8(a3)
ffffffffc020099e:	8b0d                	andi	a4,a4,3
ffffffffc02009a0:	e71d                	bnez	a4,ffffffffc02009ce <slub_alloc_pages+0x6e>
            count++;
ffffffffc02009a2:	0785                	addi	a5,a5,1
        for (size_t j = 0; j < n && (i + j) < npage; j++) {
ffffffffc02009a4:	02868693          	addi	a3,a3,40
ffffffffc02009a8:	fef896e3          	bne	a7,a5,ffffffffc0200994 <slub_alloc_pages+0x34>
ffffffffc02009ac:	00289793          	slli	a5,a7,0x2
ffffffffc02009b0:	97c6                	add	a5,a5,a7
ffffffffc02009b2:	078e                	slli	a5,a5,0x3
ffffffffc02009b4:	97ae                	add	a5,a5,a1
ffffffffc02009b6:	a019                	j	ffffffffc02009bc <slub_alloc_pages+0x5c>
            SetPageReserved(page + i);
ffffffffc02009b8:	0085b303          	ld	t1,8(a1)
ffffffffc02009bc:	00136313          	ori	t1,t1,1
ffffffffc02009c0:	0065b423          	sd	t1,8(a1)
        for (size_t i = 0; i < n; i++) {
ffffffffc02009c4:	02858593          	addi	a1,a1,40
ffffffffc02009c8:	fef598e3          	bne	a1,a5,ffffffffc02009b8 <slub_alloc_pages+0x58>
}
ffffffffc02009cc:	8082                	ret
        if (count >= n) {
ffffffffc02009ce:	fd17ffe3          	bgeu	a5,a7,ffffffffc02009ac <slub_alloc_pages+0x4c>
    for (size_t i = 0; i < npage; i++) {
ffffffffc02009d2:	0605                	addi	a2,a2,1
ffffffffc02009d4:	02858593          	addi	a1,a1,40
ffffffffc02009d8:	fb0617e3          	bne	a2,a6,ffffffffc0200986 <slub_alloc_pages+0x26>
    struct Page *page = NULL;
ffffffffc02009dc:	4501                	li	a0,0
ffffffffc02009de:	8082                	ret
static struct Page *slub_alloc_pages(size_t n) {
ffffffffc02009e0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02009e2:	00001697          	auipc	a3,0x1
ffffffffc02009e6:	48668693          	addi	a3,a3,1158 # ffffffffc0201e68 <etext+0x3a8>
ffffffffc02009ea:	00001617          	auipc	a2,0x1
ffffffffc02009ee:	48660613          	addi	a2,a2,1158 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc02009f2:	0c300593          	li	a1,195
ffffffffc02009f6:	00001517          	auipc	a0,0x1
ffffffffc02009fa:	49250513          	addi	a0,a0,1170 # ffffffffc0201e88 <etext+0x3c8>
static struct Page *slub_alloc_pages(size_t n) {
ffffffffc02009fe:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200a00:	fc2ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200a04 <slub_init>:
static void slub_init(void) {
ffffffffc0200a04:	7159                	addi	sp,sp,-112
    memset(&slub_allocator, 0, sizeof(slub_allocator));
ffffffffc0200a06:	08800613          	li	a2,136
ffffffffc0200a0a:	4581                	li	a1,0
ffffffffc0200a0c:	00005517          	auipc	a0,0x5
ffffffffc0200a10:	60c50513          	addi	a0,a0,1548 # ffffffffc0206018 <slub_allocator>
static void slub_init(void) {
ffffffffc0200a14:	e8ca                	sd	s2,80(sp)
ffffffffc0200a16:	e4ce                	sd	s3,72(sp)
ffffffffc0200a18:	e0d2                	sd	s4,64(sp)
ffffffffc0200a1a:	fc56                	sd	s5,56(sp)
ffffffffc0200a1c:	f45e                	sd	s7,40(sp)
ffffffffc0200a1e:	f062                	sd	s8,32(sp)
ffffffffc0200a20:	ec66                	sd	s9,24(sp)
ffffffffc0200a22:	e86a                	sd	s10,16(sp)
ffffffffc0200a24:	e46e                	sd	s11,8(sp)
ffffffffc0200a26:	f486                	sd	ra,104(sp)
ffffffffc0200a28:	f0a2                	sd	s0,96(sp)
ffffffffc0200a2a:	eca6                	sd	s1,88(sp)
ffffffffc0200a2c:	f85a                	sd	s6,48(sp)
    heap_used = 0;
ffffffffc0200a2e:	4c85                	li	s9,1
    memset(&slub_allocator, 0, sizeof(slub_allocator));
ffffffffc0200a30:	07e010ef          	jal	ra,ffffffffc0201aae <memset>
        cache->objects_per_slab = (PGSIZE - sizeof(void*)) / size;
ffffffffc0200a34:	6985                	lui	s3,0x1
    heap_used = 0;
ffffffffc0200a36:	00015797          	auipc	a5,0x15
ffffffffc0200a3a:	6a07b923          	sd	zero,1714(a5) # ffffffffc02160e8 <heap_used>
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc0200a3e:	00005d17          	auipc	s10,0x5
ffffffffc0200a42:	5dad0d13          	addi	s10,s10,1498 # ffffffffc0206018 <slub_allocator>
    heap_used = 0;
ffffffffc0200a46:	4b81                	li	s7,0
ffffffffc0200a48:	4781                	li	a5,0
ffffffffc0200a4a:	05000613          	li	a2,80
    if (index == 9) return 96;  // 特殊处理 96B
ffffffffc0200a4e:	4a25                	li	s4,9
    void *ptr = &static_heap[heap_used];
ffffffffc0200a50:	00005917          	auipc	s2,0x5
ffffffffc0200a54:	65090913          	addi	s2,s2,1616 # ffffffffc02060a0 <static_heap>
    heap_used = ((heap_used + size + 7) / 8) * 8;  // 8字节对齐
ffffffffc0200a58:	00015c17          	auipc	s8,0x15
ffffffffc0200a5c:	690c0c13          	addi	s8,s8,1680 # ffffffffc02160e8 <heap_used>
    if (heap_used + size > sizeof(static_heap))
ffffffffc0200a60:	6dc1                	lui	s11,0x10
        cache->cpu_cache.avail = 0;
ffffffffc0200a62:	024c9a93          	slli	s5,s9,0x24
        cache->objects_per_slab = (PGSIZE - sizeof(void*)) / size;
ffffffffc0200a66:	19e1                	addi	s3,s3,-8
ffffffffc0200a68:	a091                	j	ffffffffc0200aac <slub_init+0xa8>
            cache->objects_per_slab = 1;
ffffffffc0200a6a:	4785                	li	a5,1
ffffffffc0200a6c:	c41c                	sw	a5,8(s0)
    if (heap_used + size > sizeof(static_heap))
ffffffffc0200a6e:	000c3783          	ld	a5,0(s8)
        list_init(&cache->partial_list);
ffffffffc0200a72:	02040713          	addi	a4,s0,32
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200a76:	f418                	sd	a4,40(s0)
ffffffffc0200a78:	f018                	sd	a4,32(s0)
    if (heap_used + size > sizeof(static_heap))
ffffffffc0200a7a:	08078713          	addi	a4,a5,128
ffffffffc0200a7e:	08ede263          	bltu	s11,a4,ffffffffc0200b02 <slub_init+0xfe>
    heap_used = ((heap_used + size + 7) / 8) * 8;  // 8字节对齐
ffffffffc0200a82:	08778713          	addi	a4,a5,135
ffffffffc0200a86:	9b61                	andi	a4,a4,-8
    void *ptr = &static_heap[heap_used];
ffffffffc0200a88:	97ca                	add	a5,a5,s2
    heap_used = ((heap_used + size + 7) / 8) * 8;  // 8字节对齐
ffffffffc0200a8a:	00ec3023          	sd	a4,0(s8)
        cache->cpu_cache.freelist = static_alloc(SLUB_CPU_CACHE_SIZE * sizeof(void*));
ffffffffc0200a8e:	e81c                	sd	a5,16(s0)
        cache->cpu_cache.avail = 0;
ffffffffc0200a90:	01543c23          	sd	s5,24(s0)
        slub_allocator.size_caches[i] = cache;
ffffffffc0200a94:	008d3023          	sd	s0,0(s10)
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc0200a98:	47ad                	li	a5,11
ffffffffc0200a9a:	0afb0563          	beq	s6,a5,ffffffffc0200b44 <slub_init+0x140>
    if (heap_used + size > sizeof(static_heap))
ffffffffc0200a9e:	000c3783          	ld	a5,0(s8)
ffffffffc0200aa2:	05078613          	addi	a2,a5,80
ffffffffc0200aa6:	2b85                	addiw	s7,s7,1
ffffffffc0200aa8:	2c85                	addiw	s9,s9,1
ffffffffc0200aaa:	0d21                	addi	s10,s10,8
ffffffffc0200aac:	000b871b          	sext.w	a4,s7
    if (index == 9) return 96;  // 特殊处理 96B
ffffffffc0200ab0:	054b8b63          	beq	s7,s4,ffffffffc0200b06 <slub_init+0x102>
    if (index == 10) return 192; // 特殊处理 192B
ffffffffc0200ab4:	46a9                	li	a3,10
ffffffffc0200ab6:	08d70063          	beq	a4,a3,ffffffffc0200b36 <slub_init+0x132>
    return SLUB_MIN_SIZE << index;
ffffffffc0200aba:	44a1                	li	s1,8
ffffffffc0200abc:	00e494bb          	sllw	s1,s1,a4
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc0200ac0:	000c8b1b          	sext.w	s6,s9
    if (heap_used + size > sizeof(static_heap))
ffffffffc0200ac4:	fccdeae3          	bltu	s11,a2,ffffffffc0200a98 <slub_init+0x94>
    void *ptr = &static_heap[heap_used];
ffffffffc0200ac8:	00f90433          	add	s0,s2,a5
    heap_used = ((heap_used + size + 7) / 8) * 8;  // 8字节对齐
ffffffffc0200acc:	05778793          	addi	a5,a5,87
ffffffffc0200ad0:	9be1                	andi	a5,a5,-8
        memset(cache, 0, sizeof(struct slub_cache));
ffffffffc0200ad2:	05000613          	li	a2,80
ffffffffc0200ad6:	4581                	li	a1,0
ffffffffc0200ad8:	8522                	mv	a0,s0
    heap_used = ((heap_used + size + 7) / 8) * 8;  // 8字节对齐
ffffffffc0200ada:	00fc3023          	sd	a5,0(s8)
        memset(cache, 0, sizeof(struct slub_cache));
ffffffffc0200ade:	7d1000ef          	jal	ra,ffffffffc0201aae <memset>
        cache->object_size = size;
ffffffffc0200ae2:	e004                	sd	s1,0(s0)
        if (cache->objects_per_slab == 0)
ffffffffc0200ae4:	f899e3e3          	bltu	s3,s1,ffffffffc0200a6a <slub_init+0x66>
        cache->objects_per_slab = (PGSIZE - sizeof(void*)) / size;
ffffffffc0200ae8:	0299d4b3          	divu	s1,s3,s1
ffffffffc0200aec:	c404                	sw	s1,8(s0)
    if (heap_used + size > sizeof(static_heap))
ffffffffc0200aee:	000c3783          	ld	a5,0(s8)
        list_init(&cache->partial_list);
ffffffffc0200af2:	02040713          	addi	a4,s0,32
ffffffffc0200af6:	f418                	sd	a4,40(s0)
ffffffffc0200af8:	f018                	sd	a4,32(s0)
    if (heap_used + size > sizeof(static_heap))
ffffffffc0200afa:	08078713          	addi	a4,a5,128
ffffffffc0200afe:	f8edf2e3          	bgeu	s11,a4,ffffffffc0200a82 <slub_init+0x7e>
        return NULL;
ffffffffc0200b02:	4781                	li	a5,0
ffffffffc0200b04:	b769                	j	ffffffffc0200a8e <slub_init+0x8a>
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc0200b06:	000c8b1b          	sext.w	s6,s9
    if (heap_used + size > sizeof(static_heap))
ffffffffc0200b0a:	f8cdeee3          	bltu	s11,a2,ffffffffc0200aa6 <slub_init+0xa2>
    if (index == 9) return 96;  // 特殊处理 96B
ffffffffc0200b0e:	06000493          	li	s1,96
    void *ptr = &static_heap[heap_used];
ffffffffc0200b12:	00f90433          	add	s0,s2,a5
    heap_used = ((heap_used + size + 7) / 8) * 8;  // 8字节对齐
ffffffffc0200b16:	05778793          	addi	a5,a5,87
ffffffffc0200b1a:	9be1                	andi	a5,a5,-8
        memset(cache, 0, sizeof(struct slub_cache));
ffffffffc0200b1c:	05000613          	li	a2,80
ffffffffc0200b20:	4581                	li	a1,0
ffffffffc0200b22:	8522                	mv	a0,s0
    heap_used = ((heap_used + size + 7) / 8) * 8;  // 8字节对齐
ffffffffc0200b24:	00fc3023          	sd	a5,0(s8)
        memset(cache, 0, sizeof(struct slub_cache));
ffffffffc0200b28:	787000ef          	jal	ra,ffffffffc0201aae <memset>
        cache->object_size = size;
ffffffffc0200b2c:	e004                	sd	s1,0(s0)
        cache->objects_per_slab = (PGSIZE - sizeof(void*)) / size;
ffffffffc0200b2e:	0299d4b3          	divu	s1,s3,s1
ffffffffc0200b32:	c404                	sw	s1,8(s0)
ffffffffc0200b34:	bf6d                	j	ffffffffc0200aee <slub_init+0xea>
    if (heap_used + size > sizeof(static_heap))
ffffffffc0200b36:	00cde763          	bltu	s11,a2,ffffffffc0200b44 <slub_init+0x140>
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc0200b3a:	000c8b1b          	sext.w	s6,s9
    if (index == 10) return 192; // 特殊处理 192B
ffffffffc0200b3e:	0c000493          	li	s1,192
ffffffffc0200b42:	bfc1                	j	ffffffffc0200b12 <slub_init+0x10e>
}
ffffffffc0200b44:	7406                	ld	s0,96(sp)
ffffffffc0200b46:	70a6                	ld	ra,104(sp)
ffffffffc0200b48:	64e6                	ld	s1,88(sp)
ffffffffc0200b4a:	6946                	ld	s2,80(sp)
ffffffffc0200b4c:	69a6                	ld	s3,72(sp)
ffffffffc0200b4e:	6a06                	ld	s4,64(sp)
ffffffffc0200b50:	7ae2                	ld	s5,56(sp)
ffffffffc0200b52:	7b42                	ld	s6,48(sp)
ffffffffc0200b54:	7ba2                	ld	s7,40(sp)
ffffffffc0200b56:	7c02                	ld	s8,32(sp)
ffffffffc0200b58:	6ce2                	ld	s9,24(sp)
ffffffffc0200b5a:	6d42                	ld	s10,16(sp)
ffffffffc0200b5c:	6da2                	ld	s11,8(sp)
    cprintf("SLUB allocator initialized with %d size classes\n", SLUB_NUM_SIZES);
ffffffffc0200b5e:	45ad                	li	a1,11
ffffffffc0200b60:	00001517          	auipc	a0,0x1
ffffffffc0200b64:	3d050513          	addi	a0,a0,976 # ffffffffc0201f30 <etext+0x470>
}
ffffffffc0200b68:	6165                	addi	sp,sp,112
    cprintf("SLUB allocator initialized with %d size classes\n", SLUB_NUM_SIZES);
ffffffffc0200b6a:	de2ff06f          	j	ffffffffc020014c <cprintf>

ffffffffc0200b6e <slub_check>:
    free_page(p1);
    free_page(p2);
}

// SLUB特定检查函数
static void slub_check(void) {
ffffffffc0200b6e:	7125                	addi	sp,sp,-416
ffffffffc0200b70:	eae2                	sd	s8,336(sp)
    cprintf("=== SLUB Comprehensive Check Started ===\n");
ffffffffc0200b72:	00001517          	auipc	a0,0x1
ffffffffc0200b76:	3f650513          	addi	a0,a0,1014 # ffffffffc0201f68 <etext+0x4a8>
    for (size_t i = 0; i < npage; i++) {
ffffffffc0200b7a:	00015c17          	auipc	s8,0x15
ffffffffc0200b7e:	53ec0c13          	addi	s8,s8,1342 # ffffffffc02160b8 <npage>
static void slub_check(void) {
ffffffffc0200b82:	fad2                	sd	s4,368(sp)
ffffffffc0200b84:	ef06                	sd	ra,408(sp)
ffffffffc0200b86:	eb22                	sd	s0,400(sp)
ffffffffc0200b88:	e726                	sd	s1,392(sp)
ffffffffc0200b8a:	e34a                	sd	s2,384(sp)
ffffffffc0200b8c:	fece                	sd	s3,376(sp)
ffffffffc0200b8e:	f6d6                	sd	s5,360(sp)
ffffffffc0200b90:	f2da                	sd	s6,352(sp)
ffffffffc0200b92:	eede                	sd	s7,344(sp)
ffffffffc0200b94:	e6e6                	sd	s9,328(sp)
ffffffffc0200b96:	e2ea                	sd	s10,320(sp)
ffffffffc0200b98:	fe6e                	sd	s11,312(sp)
    cprintf("=== SLUB Comprehensive Check Started ===\n");
ffffffffc0200b9a:	db2ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (size_t i = 0; i < npage; i++) {
ffffffffc0200b9e:	000c3a03          	ld	s4,0(s8)
ffffffffc0200ba2:	6a0a0363          	beqz	s4,ffffffffc0201248 <slub_check+0x6da>
ffffffffc0200ba6:	002a1693          	slli	a3,s4,0x2
ffffffffc0200baa:	96d2                	add	a3,a3,s4
ffffffffc0200bac:	00015717          	auipc	a4,0x15
ffffffffc0200bb0:	51473703          	ld	a4,1300(a4) # ffffffffc02160c0 <pages>
ffffffffc0200bb4:	068e                	slli	a3,a3,0x3
ffffffffc0200bb6:	96ba                	add	a3,a3,a4
    size_t free_pages = 0;
ffffffffc0200bb8:	4a01                	li	s4,0
        if (!PageReserved(pages + i) && !PageProperty(pages + i))
ffffffffc0200bba:	671c                	ld	a5,8(a4)
    for (size_t i = 0; i < npage; i++) {
ffffffffc0200bbc:	02870713          	addi	a4,a4,40
        if (!PageReserved(pages + i) && !PageProperty(pages + i))
ffffffffc0200bc0:	8b8d                	andi	a5,a5,3
            free_pages++;
ffffffffc0200bc2:	0017b793          	seqz	a5,a5
ffffffffc0200bc6:	9a3e                	add	s4,s4,a5
    for (size_t i = 0; i < npage; i++) {
ffffffffc0200bc8:	fed719e3          	bne	a4,a3,ffffffffc0200bba <slub_check+0x4c>
    // 保存初始状态
    size_t initial_free_pages = slub_nr_free_pages();
    size_t initial_allocs = slub_allocator.total_allocs;
    size_t initial_frees = slub_allocator.total_frees;

    cprintf("Initial state: %u free pages, %u allocs, %u frees\n",
ffffffffc0200bcc:	000a079b          	sext.w	a5,s4
ffffffffc0200bd0:	e43e                	sd	a5,8(sp)
    size_t initial_allocs = slub_allocator.total_allocs;
ffffffffc0200bd2:	00005b97          	auipc	s7,0x5
ffffffffc0200bd6:	446b8b93          	addi	s7,s7,1094 # ffffffffc0206018 <slub_allocator>
    cprintf("Initial state: %u free pages, %u allocs, %u frees\n",
ffffffffc0200bda:	060ba783          	lw	a5,96(s7)
ffffffffc0200bde:	058ba603          	lw	a2,88(s7)
ffffffffc0200be2:	65a2                	ld	a1,8(sp)
ffffffffc0200be4:	86be                	mv	a3,a5
ffffffffc0200be6:	00001517          	auipc	a0,0x1
ffffffffc0200bea:	3b250513          	addi	a0,a0,946 # ffffffffc0201f98 <etext+0x4d8>
ffffffffc0200bee:	e832                	sd	a2,16(sp)
ffffffffc0200bf0:	ec3e                	sd	a5,24(sp)
ffffffffc0200bf2:	d5aff0ef          	jal	ra,ffffffffc020014c <cprintf>
            (unsigned int)initial_free_pages,
            (unsigned int)initial_allocs,
            (unsigned int)initial_frees);

    // 1. 运行基础检查
    cprintf("\n[Basic] Running basic page allocation checks...\n");
ffffffffc0200bf6:	00001517          	auipc	a0,0x1
ffffffffc0200bfa:	3da50513          	addi	a0,a0,986 # ffffffffc0201fd0 <etext+0x510>
ffffffffc0200bfe:	d4eff0ef          	jal	ra,ffffffffc020014c <cprintf>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c02:	4505                	li	a0,1
ffffffffc0200c04:	9cdff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200c08:	892a                	mv	s2,a0
ffffffffc0200c0a:	140501e3          	beqz	a0,ffffffffc020154c <slub_check+0x9de>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c0e:	4505                	li	a0,1
ffffffffc0200c10:	9c1ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200c14:	84aa                	mv	s1,a0
ffffffffc0200c16:	0e050be3          	beqz	a0,ffffffffc020150c <slub_check+0x99e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c1a:	4505                	li	a0,1
ffffffffc0200c1c:	9b5ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200c20:	842a                	mv	s0,a0
ffffffffc0200c22:	0c0505e3          	beqz	a0,ffffffffc02014ec <slub_check+0x97e>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c26:	0a9903e3          	beq	s2,s1,ffffffffc02014cc <slub_check+0x95e>
ffffffffc0200c2a:	0aa901e3          	beq	s2,a0,ffffffffc02014cc <slub_check+0x95e>
ffffffffc0200c2e:	08a48fe3          	beq	s1,a0,ffffffffc02014cc <slub_check+0x95e>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c32:	00092783          	lw	a5,0(s2)
ffffffffc0200c36:	06079be3          	bnez	a5,ffffffffc02014ac <slub_check+0x93e>
ffffffffc0200c3a:	409c                	lw	a5,0(s1)
ffffffffc0200c3c:	060798e3          	bnez	a5,ffffffffc02014ac <slub_check+0x93e>
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc0200c40:	411c                	lw	a5,0(a0)
ffffffffc0200c42:	060795e3          	bnez	a5,ffffffffc02014ac <slub_check+0x93e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c46:	00015797          	auipc	a5,0x15
ffffffffc0200c4a:	47a78793          	addi	a5,a5,1146 # ffffffffc02160c0 <pages>
ffffffffc0200c4e:	639c                	ld	a5,0(a5)
ffffffffc0200c50:	00002597          	auipc	a1,0x2
ffffffffc0200c54:	fa85b583          	ld	a1,-88(a1) # ffffffffc0202bf8 <nbase+0x8>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c58:	000c3683          	ld	a3,0(s8)
ffffffffc0200c5c:	40f90733          	sub	a4,s2,a5
ffffffffc0200c60:	870d                	srai	a4,a4,0x3
ffffffffc0200c62:	02b70733          	mul	a4,a4,a1
ffffffffc0200c66:	00002617          	auipc	a2,0x2
ffffffffc0200c6a:	f8a63603          	ld	a2,-118(a2) # ffffffffc0202bf0 <nbase>
ffffffffc0200c6e:	06b2                	slli	a3,a3,0xc
ffffffffc0200c70:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c72:	0732                	slli	a4,a4,0xc
ffffffffc0200c74:	00d77ce3          	bgeu	a4,a3,ffffffffc020148c <slub_check+0x91e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c78:	40f48733          	sub	a4,s1,a5
ffffffffc0200c7c:	870d                	srai	a4,a4,0x3
ffffffffc0200c7e:	02b70733          	mul	a4,a4,a1
ffffffffc0200c82:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c84:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200c86:	7ed77363          	bgeu	a4,a3,ffffffffc020146c <slub_check+0x8fe>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c8a:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c8e:	878d                	srai	a5,a5,0x3
ffffffffc0200c90:	02b787b3          	mul	a5,a5,a1
ffffffffc0200c94:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c96:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c98:	76d7fa63          	bgeu	a5,a3,ffffffffc020140c <slub_check+0x89e>
    free_page(p0);
ffffffffc0200c9c:	854a                	mv	a0,s2
ffffffffc0200c9e:	4585                	li	a1,1
ffffffffc0200ca0:	93dff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_page(p1);
ffffffffc0200ca4:	4585                	li	a1,1
ffffffffc0200ca6:	8526                	mv	a0,s1
ffffffffc0200ca8:	935ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_page(p2);
ffffffffc0200cac:	4585                	li	a1,1
ffffffffc0200cae:	8522                	mv	a0,s0
ffffffffc0200cb0:	92dff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cb4:	4505                	li	a0,1
ffffffffc0200cb6:	91bff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200cba:	892a                	mv	s2,a0
ffffffffc0200cbc:	72050863          	beqz	a0,ffffffffc02013ec <slub_check+0x87e>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200cc0:	4505                	li	a0,1
ffffffffc0200cc2:	90fff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200cc6:	84aa                	mv	s1,a0
ffffffffc0200cc8:	70050263          	beqz	a0,ffffffffc02013cc <slub_check+0x85e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ccc:	4505                	li	a0,1
ffffffffc0200cce:	903ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200cd2:	842a                	mv	s0,a0
ffffffffc0200cd4:	6c050c63          	beqz	a0,ffffffffc02013ac <slub_check+0x83e>
    free_page(p0);
ffffffffc0200cd8:	854a                	mv	a0,s2
ffffffffc0200cda:	4585                	li	a1,1
ffffffffc0200cdc:	901ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_page(p1);
ffffffffc0200ce0:	8526                	mv	a0,s1
ffffffffc0200ce2:	4585                	li	a1,1
ffffffffc0200ce4:	8f9ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_page(p2);
ffffffffc0200ce8:	4585                	li	a1,1
ffffffffc0200cea:	8522                	mv	a0,s0
ffffffffc0200cec:	8f1ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    basic_check();
    cprintf("Basic check passed!\n");
ffffffffc0200cf0:	00001517          	auipc	a0,0x1
ffffffffc0200cf4:	44050513          	addi	a0,a0,1088 # ffffffffc0202130 <etext+0x670>
ffffffffc0200cf8:	c54ff0ef          	jal	ra,ffffffffc020014c <cprintf>

    // 2. 检查SLUB大小分类系统
    cprintf("\n[SLUB] Checking size classification system...\n");
ffffffffc0200cfc:	00001517          	auipc	a0,0x1
ffffffffc0200d00:	44c50513          	addi	a0,a0,1100 # ffffffffc0202148 <etext+0x688>
ffffffffc0200d04:	c48ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    size_t expected_sizes[] = {8, 16, 32, 64, 128, 256, 512, 1024, 2048, 96, 192};
ffffffffc0200d08:	00002797          	auipc	a5,0x2
ffffffffc0200d0c:	c1078793          	addi	a5,a5,-1008 # ffffffffc0202918 <etext+0xe58>
ffffffffc0200d10:	0007be83          	ld	t4,0(a5)
ffffffffc0200d14:	0087be03          	ld	t3,8(a5)
ffffffffc0200d18:	0107b303          	ld	t1,16(a5)
ffffffffc0200d1c:	0187b883          	ld	a7,24(a5)
ffffffffc0200d20:	0207b803          	ld	a6,32(a5)
ffffffffc0200d24:	7788                	ld	a0,40(a5)
ffffffffc0200d26:	7b8c                	ld	a1,48(a5)
ffffffffc0200d28:	7f90                	ld	a2,56(a5)
ffffffffc0200d2a:	63b4                	ld	a3,64(a5)
ffffffffc0200d2c:	67b8                	ld	a4,72(a5)
ffffffffc0200d2e:	6bbc                	ld	a5,80(a5)
ffffffffc0200d30:	f0f6                	sd	t4,96(sp)
ffffffffc0200d32:	f4f2                	sd	t3,104(sp)
ffffffffc0200d34:	f89a                	sd	t1,112(sp)
ffffffffc0200d36:	fcc6                	sd	a7,120(sp)
ffffffffc0200d38:	e142                	sd	a6,128(sp)
ffffffffc0200d3a:	e52a                	sd	a0,136(sp)
ffffffffc0200d3c:	e92e                	sd	a1,144(sp)
ffffffffc0200d3e:	ed32                	sd	a2,152(sp)
ffffffffc0200d40:	f136                	sd	a3,160(sp)
ffffffffc0200d42:	f53a                	sd	a4,168(sp)
ffffffffc0200d44:	f93e                	sd	a5,176(sp)

    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc0200d46:	06010d13          	addi	s10,sp,96
ffffffffc0200d4a:	4c81                	li	s9,0
    if (index == 9) return 96;  // 特殊处理 96B
ffffffffc0200d4c:	4425                	li	s0,9
ffffffffc0200d4e:	06000b13          	li	s6,96
    if (index == 10) return 192; // 特殊处理 192B
ffffffffc0200d52:	4929                	li	s2,10
    return SLUB_MIN_SIZE << index;
ffffffffc0200d54:	4aa1                	li	s5,8
    if (size <= SLUB_MIN_SIZE) return 0;
ffffffffc0200d56:	49a1                	li	s3,8
    if (size == 192) return 10; // 特殊处理 192B
ffffffffc0200d58:	0c000b93          	li	s7,192
        assert(actual_size == expected_sizes[i]);

        int actual_index = size_to_index(actual_size);
        assert(actual_index == i);

        cprintf("  Size class %d: %u bytes ✓\n", i, (unsigned int)actual_size);
ffffffffc0200d5c:	00001497          	auipc	s1,0x1
ffffffffc0200d60:	44448493          	addi	s1,s1,1092 # ffffffffc02021a0 <etext+0x6e0>
    if (index == 9) return 96;  // 特殊处理 96B
ffffffffc0200d64:	1a8c8263          	beq	s9,s0,ffffffffc0200f08 <slub_check+0x39a>
    if (index == 10) return 192; // 特殊处理 192B
ffffffffc0200d68:	1b2c8963          	beq	s9,s2,ffffffffc0200f1a <slub_check+0x3ac>
        assert(actual_size == expected_sizes[i]);
ffffffffc0200d6c:	000d3783          	ld	a5,0(s10)
    return SLUB_MIN_SIZE << index;
ffffffffc0200d70:	019a963b          	sllw	a2,s5,s9
        assert(actual_size == expected_sizes[i]);
ffffffffc0200d74:	56c79c63          	bne	a5,a2,ffffffffc02012ec <slub_check+0x77e>
    if (size <= SLUB_MIN_SIZE) return 0;
ffffffffc0200d78:	18c9f563          	bgeu	s3,a2,ffffffffc0200f02 <slub_check+0x394>
    if (size == 96) return 9;  // 特殊处理 96B
ffffffffc0200d7c:	61660863          	beq	a2,s6,ffffffffc020138c <slub_check+0x81e>
    if (size == 192) return 10; // 特殊处理 192B
ffffffffc0200d80:	61760663          	beq	a2,s7,ffffffffc020138c <slub_check+0x81e>
    size_t temp = size - 1;
ffffffffc0200d84:	fff60713          	addi	a4,a2,-1
    int shift = 0;
ffffffffc0200d88:	4781                	li	a5,0
        temp >>= 1;
ffffffffc0200d8a:	8305                	srli	a4,a4,0x1
        shift++;
ffffffffc0200d8c:	86be                	mv	a3,a5
ffffffffc0200d8e:	2785                	addiw	a5,a5,1
    while (temp > 0) {
ffffffffc0200d90:	ff6d                	bnez	a4,ffffffffc0200d8a <slub_check+0x21c>
    return shift - SLUB_SHIFT_LOW;
ffffffffc0200d92:	36f9                	addiw	a3,a3,-2
        assert(actual_index == i);
ffffffffc0200d94:	5f969c63          	bne	a3,s9,ffffffffc020138c <slub_check+0x81e>
        cprintf("  Size class %d: %u bytes ✓\n", i, (unsigned int)actual_size);
ffffffffc0200d98:	85e6                	mv	a1,s9
ffffffffc0200d9a:	8526                	mv	a0,s1
ffffffffc0200d9c:	bb0ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc0200da0:	2c85                	addiw	s9,s9,1
ffffffffc0200da2:	47ad                	li	a5,11
ffffffffc0200da4:	0d21                	addi	s10,s10,8
ffffffffc0200da6:	fafc9fe3          	bne	s9,a5,ffffffffc0200d64 <slub_check+0x1f6>
    assert(size_to_index(1) == 0);     // 小于最小值
    assert(size_to_index(8) == 0);     // 最小值
    assert(size_to_index(96) == 9);    // 特殊大小96
    assert(size_to_index(192) == 10);  // 特殊大小192
    assert(size_to_index(5000) == -1); // 超出范围
    cprintf("Size classification system check passed!\n");
ffffffffc0200daa:	00001517          	auipc	a0,0x1
ffffffffc0200dae:	42e50513          	addi	a0,a0,1070 # ffffffffc02021d8 <etext+0x718>
ffffffffc0200db2:	b9aff0ef          	jal	ra,ffffffffc020014c <cprintf>

    // 3. 检查缓存结构初始化
    cprintf("\n[Cache] Checking cache structures...\n");
ffffffffc0200db6:	00005497          	auipc	s1,0x5
ffffffffc0200dba:	26248493          	addi	s1,s1,610 # ffffffffc0206018 <slub_allocator>
ffffffffc0200dbe:	00001517          	auipc	a0,0x1
ffffffffc0200dc2:	44a50513          	addi	a0,a0,1098 # ffffffffc0202208 <etext+0x748>
ffffffffc0200dc6:	b86ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200dca:	8ba6                	mv	s7,s1
ffffffffc0200dcc:	8d26                	mv	s10,s1
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc0200dce:	4d81                	li	s11,0
    if (index == 9) return 96;  // 特殊处理 96B
ffffffffc0200dd0:	4aa5                	li	s5,9
    if (index == 10) return 192; // 特殊处理 192B
ffffffffc0200dd2:	4b29                	li	s6,10
    return SLUB_MIN_SIZE << index;
ffffffffc0200dd4:	4ca1                	li	s9,8
        struct slub_cache *cache = slub_allocator.size_caches[i];
        assert(cache != NULL);
        assert(cache->object_size == index_to_size(i));
        assert(cache->objects_per_slab > 0);
        assert(cache->cpu_cache.limit == SLUB_CPU_CACHE_SIZE);
ffffffffc0200dd6:	49c1                	li	s3,16
        assert(cache->cpu_cache.avail == 0);
        assert(cache->cpu_cache.freelist != NULL);
        assert(list_empty(&cache->partial_list));

        cprintf("  Cache %d (size %u): %u objects per slab ✓\n",
ffffffffc0200dd8:	00001917          	auipc	s2,0x1
ffffffffc0200ddc:	55090913          	addi	s2,s2,1360 # ffffffffc0202328 <etext+0x868>
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc0200de0:	442d                	li	s0,11
        struct slub_cache *cache = slub_allocator.size_caches[i];
ffffffffc0200de2:	000d3783          	ld	a5,0(s10)
        assert(cache != NULL);
ffffffffc0200de6:	58078363          	beqz	a5,ffffffffc020136c <slub_check+0x7fe>
        assert(cache->object_size == index_to_size(i));
ffffffffc0200dea:	6390                	ld	a2,0(a5)
    if (index == 9) return 96;  // 特殊处理 96B
ffffffffc0200dec:	135d8163          	beq	s11,s5,ffffffffc0200f0e <slub_check+0x3a0>
    if (index == 10) return 192; // 特殊处理 192B
ffffffffc0200df0:	136d8263          	beq	s11,s6,ffffffffc0200f14 <slub_check+0x3a6>
    return SLUB_MIN_SIZE << index;
ffffffffc0200df4:	01bc96bb          	sllw	a3,s9,s11
        assert(cache->object_size == index_to_size(i));
ffffffffc0200df8:	4ad61a63          	bne	a2,a3,ffffffffc02012ac <slub_check+0x73e>
        assert(cache->objects_per_slab > 0);
ffffffffc0200dfc:	4794                	lw	a3,8(a5)
ffffffffc0200dfe:	54068763          	beqz	a3,ffffffffc020134c <slub_check+0x7de>
        assert(cache->cpu_cache.limit == SLUB_CPU_CACHE_SIZE);
ffffffffc0200e02:	4fcc                	lw	a1,28(a5)
ffffffffc0200e04:	53359463          	bne	a1,s3,ffffffffc020132c <slub_check+0x7be>
        assert(cache->cpu_cache.avail == 0);
ffffffffc0200e08:	4f8c                	lw	a1,24(a5)
ffffffffc0200e0a:	50059163          	bnez	a1,ffffffffc020130c <slub_check+0x79e>
        assert(cache->cpu_cache.freelist != NULL);
ffffffffc0200e0e:	6b8c                	ld	a1,16(a5)
ffffffffc0200e10:	46058e63          	beqz	a1,ffffffffc020128c <slub_check+0x71e>
        assert(list_empty(&cache->partial_list));
ffffffffc0200e14:	778c                	ld	a1,40(a5)
ffffffffc0200e16:	02078793          	addi	a5,a5,32
ffffffffc0200e1a:	4af59963          	bne	a1,a5,ffffffffc02012cc <slub_check+0x75e>
        cprintf("  Cache %d (size %u): %u objects per slab ✓\n",
ffffffffc0200e1e:	85ee                	mv	a1,s11
ffffffffc0200e20:	2601                	sext.w	a2,a2
ffffffffc0200e22:	854a                	mv	a0,s2
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc0200e24:	2d85                	addiw	s11,s11,1
        cprintf("  Cache %d (size %u): %u objects per slab ✓\n",
ffffffffc0200e26:	b26ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc0200e2a:	0d21                	addi	s10,s10,8
ffffffffc0200e2c:	fa8d9be3          	bne	s11,s0,ffffffffc0200de2 <slub_check+0x274>
                i, (unsigned int)cache->object_size, cache->objects_per_slab);
    }
    cprintf("Cache structures check passed!\n");
ffffffffc0200e30:	00001517          	auipc	a0,0x1
ffffffffc0200e34:	52850513          	addi	a0,a0,1320 # ffffffffc0202358 <etext+0x898>
ffffffffc0200e38:	b14ff0ef          	jal	ra,ffffffffc020014c <cprintf>

    // 4. 检查页面信息结构
    cprintf("\n[PageInfo] Checking page info structures...\n");
ffffffffc0200e3c:	00001517          	auipc	a0,0x1
ffffffffc0200e40:	53c50513          	addi	a0,a0,1340 # ffffffffc0202378 <etext+0x8b8>
ffffffffc0200e44:	b08ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    assert(slub_allocator.page_infos != NULL);
ffffffffc0200e48:	078bb783          	ld	a5,120(s7)
ffffffffc0200e4c:	7a078063          	beqz	a5,ffffffffc02015ec <slub_check+0xa7e>
    assert(slub_allocator.max_pages > 0);
ffffffffc0200e50:	080bb603          	ld	a2,128(s7)

    for (size_t i = 0; i < 10 && i < slub_allocator.max_pages; i++) {
ffffffffc0200e54:	4701                	li	a4,0
ffffffffc0200e56:	45a9                	li	a1,10
    assert(slub_allocator.max_pages > 0);
ffffffffc0200e58:	e619                	bnez	a2,ffffffffc0200e66 <slub_check+0x2f8>
ffffffffc0200e5a:	7320006f          	j	ffffffffc020158c <slub_check+0xa1e>
    for (size_t i = 0; i < 10 && i < slub_allocator.max_pages; i++) {
ffffffffc0200e5e:	02878793          	addi	a5,a5,40
ffffffffc0200e62:	02e60263          	beq	a2,a4,ffffffffc0200e86 <slub_check+0x318>
        struct slub_page_info *info = &slub_allocator.page_infos[i];
        assert(info->freelist == NULL);
ffffffffc0200e66:	6394                	ld	a3,0(a5)
ffffffffc0200e68:	70069263          	bnez	a3,ffffffffc020156c <slub_check+0x9fe>
        assert(info->inuse == 0);
ffffffffc0200e6c:	4794                	lw	a3,8(a5)
ffffffffc0200e6e:	5c069f63          	bnez	a3,ffffffffc020144c <slub_check+0x8de>
        assert(info->objects == 0);
ffffffffc0200e72:	00c7ab03          	lw	s6,12(a5)
ffffffffc0200e76:	5a0b1b63          	bnez	s6,ffffffffc020142c <slub_check+0x8be>
        assert(info->cache == NULL);
ffffffffc0200e7a:	6b94                	ld	a3,16(a5)
ffffffffc0200e7c:	74069863          	bnez	a3,ffffffffc02015cc <slub_check+0xa5e>
    for (size_t i = 0; i < 10 && i < slub_allocator.max_pages; i++) {
ffffffffc0200e80:	0705                	addi	a4,a4,1
ffffffffc0200e82:	fcb71ee3          	bne	a4,a1,ffffffffc0200e5e <slub_check+0x2f0>
    }
    cprintf("Page info structures check passed!\n");
ffffffffc0200e86:	00001517          	auipc	a0,0x1
ffffffffc0200e8a:	5ca50513          	addi	a0,a0,1482 # ffffffffc0202450 <etext+0x990>
ffffffffc0200e8e:	abeff0ef          	jal	ra,ffffffffc020014c <cprintf>

    // 5. 测试多页分配和释放
    cprintf("\n[MultiPage] Testing multi-page allocation...\n");
ffffffffc0200e92:	00001517          	auipc	a0,0x1
ffffffffc0200e96:	5e650513          	addi	a0,a0,1510 # ffffffffc0202478 <etext+0x9b8>
ffffffffc0200e9a:	ab2ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    struct Page *test_pages[4];
    size_t alloc_sizes[] = {1, 2, 4, 3};
ffffffffc0200e9e:	4789                	li	a5,2
ffffffffc0200ea0:	e4be                	sd	a5,72(sp)
ffffffffc0200ea2:	4791                	li	a5,4
ffffffffc0200ea4:	0080                	addi	s0,sp,64
ffffffffc0200ea6:	02010913          	addi	s2,sp,32
ffffffffc0200eaa:	e8be                	sd	a5,80(sp)
ffffffffc0200eac:	478d                	li	a5,3
ffffffffc0200eae:	ecbe                	sd	a5,88(sp)

    for (int i = 0; i < 4; i++) {
ffffffffc0200eb0:	8d22                	mv	s10,s0
    size_t alloc_sizes[] = {1, 2, 4, 3};
ffffffffc0200eb2:	89a2                	mv	s3,s0
ffffffffc0200eb4:	8aca                	mv	s5,s2
ffffffffc0200eb6:	4d85                	li	s11,1
        assert(test_pages[i] != NULL);

        for (size_t j = 0; j < alloc_sizes[i]; j++) {
            assert(PageReserved(test_pages[i] + j));
        }
        cprintf("  Allocated %u pages ✓\n", (unsigned int)alloc_sizes[i]);
ffffffffc0200eb8:	00001c97          	auipc	s9,0x1
ffffffffc0200ebc:	628c8c93          	addi	s9,s9,1576 # ffffffffc02024e0 <etext+0xa20>
        test_pages[i] = alloc_pages(alloc_sizes[i]);
ffffffffc0200ec0:	856e                	mv	a0,s11
ffffffffc0200ec2:	f0eff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200ec6:	00aab023          	sd	a0,0(s5)
        assert(test_pages[i] != NULL);
ffffffffc0200eca:	6e050163          	beqz	a0,ffffffffc02015ac <slub_check+0xa3e>
        for (size_t j = 0; j < alloc_sizes[i]; j++) {
ffffffffc0200ece:	00850713          	addi	a4,a0,8
ffffffffc0200ed2:	4681                	li	a3,0
ffffffffc0200ed4:	000d8b63          	beqz	s11,ffffffffc0200eea <slub_check+0x37c>
            assert(PageReserved(test_pages[i] + j));
ffffffffc0200ed8:	631c                	ld	a5,0(a4)
ffffffffc0200eda:	8b85                	andi	a5,a5,1
ffffffffc0200edc:	36078863          	beqz	a5,ffffffffc020124c <slub_check+0x6de>
        for (size_t j = 0; j < alloc_sizes[i]; j++) {
ffffffffc0200ee0:	0685                	addi	a3,a3,1
ffffffffc0200ee2:	02870713          	addi	a4,a4,40
ffffffffc0200ee6:	fedd99e3          	bne	s11,a3,ffffffffc0200ed8 <slub_check+0x36a>
        cprintf("  Allocated %u pages ✓\n", (unsigned int)alloc_sizes[i]);
ffffffffc0200eea:	000d859b          	sext.w	a1,s11
ffffffffc0200eee:	8566                	mv	a0,s9
    for (int i = 0; i < 4; i++) {
ffffffffc0200ef0:	0aa1                	addi	s5,s5,8
        cprintf("  Allocated %u pages ✓\n", (unsigned int)alloc_sizes[i]);
ffffffffc0200ef2:	a5aff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = 0; i < 4; i++) {
ffffffffc0200ef6:	09a1                	addi	s3,s3,8
ffffffffc0200ef8:	028a8b63          	beq	s5,s0,ffffffffc0200f2e <slub_check+0x3c0>
        test_pages[i] = alloc_pages(alloc_sizes[i]);
ffffffffc0200efc:	0009bd83          	ld	s11,0(s3) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0200f00:	b7c1                	j	ffffffffc0200ec0 <slub_check+0x352>
    if (size <= SLUB_MIN_SIZE) return 0;
ffffffffc0200f02:	4681                	li	a3,0
ffffffffc0200f04:	4621                	li	a2,8
ffffffffc0200f06:	b579                	j	ffffffffc0200d94 <slub_check+0x226>
ffffffffc0200f08:	06000613          	li	a2,96
ffffffffc0200f0c:	b571                	j	ffffffffc0200d98 <slub_check+0x22a>
    if (index == 9) return 96;  // 特殊处理 96B
ffffffffc0200f0e:	06000693          	li	a3,96
ffffffffc0200f12:	b5dd                	j	ffffffffc0200df8 <slub_check+0x28a>
    if (index == 10) return 192; // 特殊处理 192B
ffffffffc0200f14:	0c000693          	li	a3,192
ffffffffc0200f18:	b5c5                	j	ffffffffc0200df8 <slub_check+0x28a>
        cprintf("  Size class %d: %u bytes ✓\n", i, (unsigned int)actual_size);
ffffffffc0200f1a:	0c000613          	li	a2,192
ffffffffc0200f1e:	45a9                	li	a1,10
ffffffffc0200f20:	00001517          	auipc	a0,0x1
ffffffffc0200f24:	28050513          	addi	a0,a0,640 # ffffffffc02021a0 <etext+0x6e0>
ffffffffc0200f28:	a24ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc0200f2c:	bdbd                	j	ffffffffc0200daa <slub_check+0x23c>
    }

    for (int i = 0; i < 4; i++) {
        free_pages(test_pages[i], alloc_sizes[i]);
ffffffffc0200f2e:	00093503          	ld	a0,0(s2)
ffffffffc0200f32:	4585                	li	a1,1
    for (int i = 0; i < 4; i++) {
ffffffffc0200f34:	0921                	addi	s2,s2,8
        free_pages(test_pages[i], alloc_sizes[i]);
ffffffffc0200f36:	ea6ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    for (int i = 0; i < 4; i++) {
ffffffffc0200f3a:	0421                	addi	s0,s0,8
ffffffffc0200f3c:	01a90b63          	beq	s2,s10,ffffffffc0200f52 <slub_check+0x3e4>
        free_pages(test_pages[i], alloc_sizes[i]);
ffffffffc0200f40:	600c                	ld	a1,0(s0)
ffffffffc0200f42:	00093503          	ld	a0,0(s2)
    for (int i = 0; i < 4; i++) {
ffffffffc0200f46:	0921                	addi	s2,s2,8
ffffffffc0200f48:	0421                	addi	s0,s0,8
        free_pages(test_pages[i], alloc_sizes[i]);
ffffffffc0200f4a:	e92ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    for (int i = 0; i < 4; i++) {
ffffffffc0200f4e:	ffa919e3          	bne	s2,s10,ffffffffc0200f40 <slub_check+0x3d2>
    }
    cprintf("Multi-page allocation test passed!\n");
ffffffffc0200f52:	00001517          	auipc	a0,0x1
ffffffffc0200f56:	5ae50513          	addi	a0,a0,1454 # ffffffffc0202500 <etext+0xa40>
ffffffffc0200f5a:	9f2ff0ef          	jal	ra,ffffffffc020014c <cprintf>

    // 6. 边界条件测试
    cprintf("\n[Boundary] Testing boundary conditions...\n");
ffffffffc0200f5e:	00001517          	auipc	a0,0x1
ffffffffc0200f62:	5ca50513          	addi	a0,a0,1482 # ffffffffc0202528 <etext+0xa68>
ffffffffc0200f66:	9e6ff0ef          	jal	ra,ffffffffc020014c <cprintf>

    struct Page *p_single = alloc_pages(1);
ffffffffc0200f6a:	4505                	li	a0,1
ffffffffc0200f6c:	e64ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
    assert(p_single != NULL);
ffffffffc0200f70:	5a050e63          	beqz	a0,ffffffffc020152c <slub_check+0x9be>
    free_pages(p_single, 1);
ffffffffc0200f74:	4585                	li	a1,1
ffffffffc0200f76:	e66ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    cprintf("  Single page allocation ✓\n");
ffffffffc0200f7a:	00001517          	auipc	a0,0x1
ffffffffc0200f7e:	5f650513          	addi	a0,a0,1526 # ffffffffc0202570 <etext+0xab0>
ffffffffc0200f82:	9caff0ef          	jal	ra,ffffffffc020014c <cprintf>

    struct Page *p_large = alloc_pages(16);
ffffffffc0200f86:	4541                	li	a0,16
ffffffffc0200f88:	e48ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
    if (p_large != NULL) {
ffffffffc0200f8c:	2a050763          	beqz	a0,ffffffffc020123a <slub_check+0x6cc>
        free_pages(p_large, 16);
ffffffffc0200f90:	45c1                	li	a1,16
ffffffffc0200f92:	e4aff0ef          	jal	ra,ffffffffc02005dc <free_pages>
        cprintf("  Large allocation (16 pages) ✓\n");
ffffffffc0200f96:	00001517          	auipc	a0,0x1
ffffffffc0200f9a:	5fa50513          	addi	a0,a0,1530 # ffffffffc0202590 <etext+0xad0>
ffffffffc0200f9e:	9aeff0ef          	jal	ra,ffffffffc020014c <cprintf>
    } else {
        cprintf("  Large allocation skipped (insufficient memory)\n");
    }

    extern struct Page *pages;
    if (pages != NULL && slub_allocator.max_pages > 0) {
ffffffffc0200fa2:	00015797          	auipc	a5,0x15
ffffffffc0200fa6:	11e78793          	addi	a5,a5,286 # ffffffffc02160c0 <pages>
ffffffffc0200faa:	639c                	ld	a5,0(a5)
ffffffffc0200fac:	c789                	beqz	a5,ffffffffc0200fb6 <slub_check+0x448>
ffffffffc0200fae:	080bb783          	ld	a5,128(s7)
ffffffffc0200fb2:	22079b63          	bnez	a5,ffffffffc02011e8 <slub_check+0x67a>
        struct slub_page_info *info = page_to_slub_info(pages);
        assert(info != NULL);
        cprintf("  Page info boundary access ✓\n");
    }
    cprintf("Boundary conditions test passed!\n");
ffffffffc0200fb6:	00001517          	auipc	a0,0x1
ffffffffc0200fba:	67250513          	addi	a0,a0,1650 # ffffffffc0202628 <etext+0xb68>
ffffffffc0200fbe:	98eff0ef          	jal	ra,ffffffffc020014c <cprintf>

    // 7. 压力测试
    cprintf("\n[Stress] Running stress test...\n");
ffffffffc0200fc2:	00001517          	auipc	a0,0x1
ffffffffc0200fc6:	68e50513          	addi	a0,a0,1678 # ffffffffc0202650 <etext+0xb90>
ffffffffc0200fca:	982ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (size_t i = 0; i < npage; i++) {
ffffffffc0200fce:	000c3a83          	ld	s5,0(s8)
ffffffffc0200fd2:	020a8663          	beqz	s5,ffffffffc0200ffe <slub_check+0x490>
ffffffffc0200fd6:	00015797          	auipc	a5,0x15
ffffffffc0200fda:	0ea78793          	addi	a5,a5,234 # ffffffffc02160c0 <pages>
ffffffffc0200fde:	002a9693          	slli	a3,s5,0x2
ffffffffc0200fe2:	6398                	ld	a4,0(a5)
ffffffffc0200fe4:	96d6                	add	a3,a3,s5
ffffffffc0200fe6:	068e                	slli	a3,a3,0x3
ffffffffc0200fe8:	96ba                	add	a3,a3,a4
    size_t free_pages = 0;
ffffffffc0200fea:	4a81                	li	s5,0
        if (!PageReserved(pages + i) && !PageProperty(pages + i))
ffffffffc0200fec:	671c                	ld	a5,8(a4)
    for (size_t i = 0; i < npage; i++) {
ffffffffc0200fee:	02870713          	addi	a4,a4,40
        if (!PageReserved(pages + i) && !PageProperty(pages + i))
ffffffffc0200ff2:	8b8d                	andi	a5,a5,3
            free_pages++;
ffffffffc0200ff4:	0017b793          	seqz	a5,a5
ffffffffc0200ff8:	9abe                	add	s5,s5,a5
    for (size_t i = 0; i < npage; i++) {
ffffffffc0200ffa:	fed719e3          	bne	a4,a3,ffffffffc0200fec <slub_check+0x47e>
    size_t stress_initial_free = slub_nr_free_pages();
    const int test_cycles = 15;
    struct Page *stress_pages[test_cycles];

    for (int cycle = 0; cycle < 2; cycle++) {
ffffffffc0200ffe:	4781                	li	a5,0
        cprintf("  Stress cycle %d...\n", cycle + 1);

        // 分配阶段
        for (int i = 0; i < test_cycles; i++) {
            size_t size = (i % 3) + 1;
ffffffffc0201000:	440d                	li	s0,3
        for (int i = 0; i < test_cycles; i++) {
ffffffffc0201002:	49bd                	li	s3,15
            stress_pages[i] = alloc_pages(size);
            assert(stress_pages[i] != NULL);
        }

        // 释放阶段
        for (int i = test_cycles - 1; i >= 0; i--) {
ffffffffc0201004:	597d                	li	s2,-1
        cprintf("  Stress cycle %d...\n", cycle + 1);
ffffffffc0201006:	00178c93          	addi	s9,a5,1
ffffffffc020100a:	85e6                	mv	a1,s9
ffffffffc020100c:	00001517          	auipc	a0,0x1
ffffffffc0201010:	66c50513          	addi	a0,a0,1644 # ffffffffc0202678 <etext+0xbb8>
ffffffffc0201014:	938ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        for (int i = 0; i < test_cycles; i++) {
ffffffffc0201018:	0b810d93          	addi	s11,sp,184
ffffffffc020101c:	4d01                	li	s10,0
            size_t size = (i % 3) + 1;
ffffffffc020101e:	028d653b          	remw	a0,s10,s0
            stress_pages[i] = alloc_pages(size);
ffffffffc0201022:	2505                	addiw	a0,a0,1
ffffffffc0201024:	dacff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0201028:	00adb023          	sd	a0,0(s11) # 10000 <kern_entry-0xffffffffc01f0000>
            assert(stress_pages[i] != NULL);
ffffffffc020102c:	24050063          	beqz	a0,ffffffffc020126c <slub_check+0x6fe>
        for (int i = 0; i < test_cycles; i++) {
ffffffffc0201030:	2d05                	addiw	s10,s10,1
ffffffffc0201032:	0da1                	addi	s11,s11,8
ffffffffc0201034:	ff3d15e3          	bne	s10,s3,ffffffffc020101e <slub_check+0x4b0>
ffffffffc0201038:	12810d93          	addi	s11,sp,296
        for (int i = test_cycles - 1; i >= 0; i--) {
ffffffffc020103c:	4d39                	li	s10,14
            size_t size = (i % 3) + 1;
ffffffffc020103e:	028d65bb          	remw	a1,s10,s0
            free_pages(stress_pages[i], size);
ffffffffc0201042:	000db503          	ld	a0,0(s11)
        for (int i = test_cycles - 1; i >= 0; i--) {
ffffffffc0201046:	3d7d                	addiw	s10,s10,-1
ffffffffc0201048:	1de1                	addi	s11,s11,-8
            free_pages(stress_pages[i], size);
ffffffffc020104a:	2585                	addiw	a1,a1,1
ffffffffc020104c:	d90ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
        for (int i = test_cycles - 1; i >= 0; i--) {
ffffffffc0201050:	ff2d17e3          	bne	s10,s2,ffffffffc020103e <slub_check+0x4d0>
    for (int cycle = 0; cycle < 2; cycle++) {
ffffffffc0201054:	4709                	li	a4,2
ffffffffc0201056:	4785                	li	a5,1
ffffffffc0201058:	faec97e3          	bne	s9,a4,ffffffffc0201006 <slub_check+0x498>
    for (size_t i = 0; i < npage; i++) {
ffffffffc020105c:	000c3683          	ld	a3,0(s8)
ffffffffc0201060:	c68d                	beqz	a3,ffffffffc020108a <slub_check+0x51c>
ffffffffc0201062:	00015797          	auipc	a5,0x15
ffffffffc0201066:	05e78793          	addi	a5,a5,94 # ffffffffc02160c0 <pages>
ffffffffc020106a:	00269613          	slli	a2,a3,0x2
ffffffffc020106e:	6398                	ld	a4,0(a5)
ffffffffc0201070:	9636                	add	a2,a2,a3
ffffffffc0201072:	060e                	slli	a2,a2,0x3
ffffffffc0201074:	963a                	add	a2,a2,a4
    size_t free_pages = 0;
ffffffffc0201076:	4681                	li	a3,0
        if (!PageReserved(pages + i) && !PageProperty(pages + i))
ffffffffc0201078:	671c                	ld	a5,8(a4)
    for (size_t i = 0; i < npage; i++) {
ffffffffc020107a:	02870713          	addi	a4,a4,40
        if (!PageReserved(pages + i) && !PageProperty(pages + i))
ffffffffc020107e:	8b8d                	andi	a5,a5,3
            free_pages++;
ffffffffc0201080:	0017b793          	seqz	a5,a5
ffffffffc0201084:	96be                	add	a3,a3,a5
    for (size_t i = 0; i < npage; i++) {
ffffffffc0201086:	fec719e3          	bne	a4,a2,ffffffffc0201078 <slub_check+0x50a>
        }
    }

    size_t stress_final_free = slub_nr_free_pages();
    if (stress_final_free < stress_initial_free - 2) {
ffffffffc020108a:	1af9                	addi	s5,s5,-2
ffffffffc020108c:	1556e763          	bltu	a3,s5,ffffffffc02011da <slub_check+0x66c>
        cprintf("  WARNING: Possible memory leak in stress test!\n");
    } else {
        cprintf("  Memory leak test passed ✓\n");
ffffffffc0201090:	00001517          	auipc	a0,0x1
ffffffffc0201094:	65050513          	addi	a0,a0,1616 # ffffffffc02026e0 <etext+0xc20>
ffffffffc0201098:	8b4ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    }
    cprintf("Stress test passed!\n");
ffffffffc020109c:	00001517          	auipc	a0,0x1
ffffffffc02010a0:	66450513          	addi	a0,a0,1636 # ffffffffc0202700 <etext+0xc40>
ffffffffc02010a4:	8a8ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (size_t i = 0; i < npage; i++) {
ffffffffc02010a8:	000c3403          	ld	s0,0(s8)
ffffffffc02010ac:	c41d                	beqz	s0,ffffffffc02010da <slub_check+0x56c>
ffffffffc02010ae:	00015797          	auipc	a5,0x15
ffffffffc02010b2:	01278793          	addi	a5,a5,18 # ffffffffc02160c0 <pages>
ffffffffc02010b6:	00241693          	slli	a3,s0,0x2
ffffffffc02010ba:	6398                	ld	a4,0(a5)
ffffffffc02010bc:	96a2                	add	a3,a3,s0
ffffffffc02010be:	068e                	slli	a3,a3,0x3
ffffffffc02010c0:	96ba                	add	a3,a3,a4
    size_t free_pages = 0;
ffffffffc02010c2:	4401                	li	s0,0
        if (!PageReserved(pages + i) && !PageProperty(pages + i))
ffffffffc02010c4:	671c                	ld	a5,8(a4)
    for (size_t i = 0; i < npage; i++) {
ffffffffc02010c6:	02870713          	addi	a4,a4,40
        if (!PageReserved(pages + i) && !PageProperty(pages + i))
ffffffffc02010ca:	8b8d                	andi	a5,a5,3
            free_pages++;
ffffffffc02010cc:	0017b793          	seqz	a5,a5
ffffffffc02010d0:	943e                	add	s0,s0,a5
    for (size_t i = 0; i < npage; i++) {
ffffffffc02010d2:	fed719e3          	bne	a4,a3,ffffffffc02010c4 <slub_check+0x556>
    size_t final_allocs = slub_allocator.total_allocs;
    size_t final_frees = slub_allocator.total_frees;

    cprintf("\n=== Final Statistics Report ===\n");
    cprintf("System Status:\n");
    cprintf("  Free pages: %u\n", (unsigned int)final_free_pages);
ffffffffc02010d6:	00040b1b          	sext.w	s6,s0
    cprintf("\n=== Final Statistics Report ===\n");
ffffffffc02010da:	00001517          	auipc	a0,0x1
ffffffffc02010de:	63e50513          	addi	a0,a0,1598 # ffffffffc0202718 <etext+0xc58>
    size_t final_allocs = slub_allocator.total_allocs;
ffffffffc02010e2:	058bb903          	ld	s2,88(s7)
    size_t final_frees = slub_allocator.total_frees;
ffffffffc02010e6:	060bb983          	ld	s3,96(s7)
    cprintf("\n=== Final Statistics Report ===\n");
ffffffffc02010ea:	862ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("System Status:\n");
ffffffffc02010ee:	00001517          	auipc	a0,0x1
ffffffffc02010f2:	65250513          	addi	a0,a0,1618 # ffffffffc0202740 <etext+0xc80>
ffffffffc02010f6:	856ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  Free pages: %u\n", (unsigned int)final_free_pages);
ffffffffc02010fa:	85da                	mv	a1,s6
ffffffffc02010fc:	00001517          	auipc	a0,0x1
ffffffffc0201100:	65450513          	addi	a0,a0,1620 # ffffffffc0202750 <etext+0xc90>
ffffffffc0201104:	848ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  Total allocations: %u (delta: +%u)\n",
ffffffffc0201108:	67c2                	ld	a5,16(sp)
ffffffffc020110a:	0009059b          	sext.w	a1,s2
ffffffffc020110e:	00001517          	auipc	a0,0x1
ffffffffc0201112:	65a50513          	addi	a0,a0,1626 # ffffffffc0202768 <etext+0xca8>
ffffffffc0201116:	40f9063b          	subw	a2,s2,a5
ffffffffc020111a:	832ff0ef          	jal	ra,ffffffffc020014c <cprintf>
            (unsigned int)final_allocs,
            (unsigned int)(final_allocs - initial_allocs));
    cprintf("  Total frees: %u (delta: +%u)\n",
ffffffffc020111e:	67e2                	ld	a5,24(sp)
ffffffffc0201120:	0009859b          	sext.w	a1,s3
ffffffffc0201124:	00001517          	auipc	a0,0x1
ffffffffc0201128:	66c50513          	addi	a0,a0,1644 # ffffffffc0202790 <etext+0xcd0>
ffffffffc020112c:	40f9863b          	subw	a2,s3,a5
ffffffffc0201130:	81cff0ef          	jal	ra,ffffffffc020014c <cprintf>
            (unsigned int)final_frees,
            (unsigned int)(final_frees - initial_frees));
    cprintf("  Cache hits: %u\n", (unsigned int)slub_allocator.cache_hits);
ffffffffc0201134:	068ba583          	lw	a1,104(s7)
ffffffffc0201138:	00001517          	auipc	a0,0x1
ffffffffc020113c:	67850513          	addi	a0,a0,1656 # ffffffffc02027b0 <etext+0xcf0>
ffffffffc0201140:	80cff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  Active slabs: %u\n", (unsigned int)slub_allocator.nr_slabs);
ffffffffc0201144:	070ba583          	lw	a1,112(s7)
ffffffffc0201148:	00001517          	auipc	a0,0x1
ffffffffc020114c:	68050513          	addi	a0,a0,1664 # ffffffffc02027c8 <etext+0xd08>
ffffffffc0201150:	ffdfe0ef          	jal	ra,ffffffffc020014c <cprintf>

    if (final_allocs > 0) {
ffffffffc0201154:	0a091c63          	bnez	s2,ffffffffc020120c <slub_check+0x69e>
        cprintf("  Cache hit rate: %u.%02u%%\n",
                (unsigned int)(hit_rate / 100),
                (unsigned int)(hit_rate % 100));
    }

    cprintf("\nSize Class Details:\n");
ffffffffc0201158:	00001517          	auipc	a0,0x1
ffffffffc020115c:	6a850513          	addi	a0,a0,1704 # ffffffffc0202800 <etext+0xd40>
ffffffffc0201160:	fedfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc0201164:	00005917          	auipc	s2,0x5
ffffffffc0201168:	f0c90913          	addi	s2,s2,-244 # ffffffffc0206070 <slub_allocator+0x58>
        struct slub_cache *cache = slub_allocator.size_caches[i];
        if (cache) {
            cprintf("  Size %u: %u slabs, %u free, %u allocs, %u frees\n",
ffffffffc020116c:	00001997          	auipc	s3,0x1
ffffffffc0201170:	6ac98993          	addi	s3,s3,1708 # ffffffffc0202818 <etext+0xd58>
        struct slub_cache *cache = slub_allocator.size_caches[i];
ffffffffc0201174:	608c                	ld	a1,0(s1)
        if (cache) {
ffffffffc0201176:	c989                	beqz	a1,ffffffffc0201188 <slub_check+0x61a>
            cprintf("  Size %u: %u slabs, %u free, %u allocs, %u frees\n",
ffffffffc0201178:	45bc                	lw	a5,72(a1)
ffffffffc020117a:	41b8                	lw	a4,64(a1)
ffffffffc020117c:	5d94                	lw	a3,56(a1)
ffffffffc020117e:	5990                	lw	a2,48(a1)
ffffffffc0201180:	418c                	lw	a1,0(a1)
ffffffffc0201182:	854e                	mv	a0,s3
ffffffffc0201184:	fc9fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc0201188:	04a1                	addi	s1,s1,8
ffffffffc020118a:	fe9915e3          	bne	s2,s1,ffffffffc0201174 <slub_check+0x606>
                    (unsigned int)cache->nr_frees);
        }
    }

    // 内存完整性检查
    if (final_free_pages < initial_free_pages - 3) {
ffffffffc020118e:	1a75                	addi	s4,s4,-3
ffffffffc0201190:	07447763          	bgeu	s0,s4,ffffffffc02011fe <slub_check+0x690>
        cprintf("\nWARNING: Significant memory leak detected!\n");
ffffffffc0201194:	00001517          	auipc	a0,0x1
ffffffffc0201198:	6bc50513          	addi	a0,a0,1724 # ffffffffc0202850 <etext+0xd90>
ffffffffc020119c:	fb1fe0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("   Lost %d pages during testing\n",
ffffffffc02011a0:	67a2                	ld	a5,8(sp)
ffffffffc02011a2:	00001517          	auipc	a0,0x1
ffffffffc02011a6:	6de50513          	addi	a0,a0,1758 # ffffffffc0202880 <etext+0xdc0>
ffffffffc02011aa:	416785bb          	subw	a1,a5,s6
ffffffffc02011ae:	f9ffe0ef          	jal	ra,ffffffffc020014c <cprintf>
    } else {
        cprintf("\nMemory integrity check passed!\n");
    }

    cprintf("\n=== SLUB Check Completed Successfully ===\n");
}
ffffffffc02011b2:	645a                	ld	s0,400(sp)
ffffffffc02011b4:	60fa                	ld	ra,408(sp)
ffffffffc02011b6:	64ba                	ld	s1,392(sp)
ffffffffc02011b8:	691a                	ld	s2,384(sp)
ffffffffc02011ba:	79f6                	ld	s3,376(sp)
ffffffffc02011bc:	7a56                	ld	s4,368(sp)
ffffffffc02011be:	7ab6                	ld	s5,360(sp)
ffffffffc02011c0:	7b16                	ld	s6,352(sp)
ffffffffc02011c2:	6bf6                	ld	s7,344(sp)
ffffffffc02011c4:	6c56                	ld	s8,336(sp)
ffffffffc02011c6:	6cb6                	ld	s9,328(sp)
ffffffffc02011c8:	6d16                	ld	s10,320(sp)
ffffffffc02011ca:	7df2                	ld	s11,312(sp)
    cprintf("\n=== SLUB Check Completed Successfully ===\n");
ffffffffc02011cc:	00001517          	auipc	a0,0x1
ffffffffc02011d0:	70450513          	addi	a0,a0,1796 # ffffffffc02028d0 <etext+0xe10>
}
ffffffffc02011d4:	611d                	addi	sp,sp,416
    cprintf("\n=== SLUB Check Completed Successfully ===\n");
ffffffffc02011d6:	f77fe06f          	j	ffffffffc020014c <cprintf>
        cprintf("  WARNING: Possible memory leak in stress test!\n");
ffffffffc02011da:	00001517          	auipc	a0,0x1
ffffffffc02011de:	4ce50513          	addi	a0,a0,1230 # ffffffffc02026a8 <etext+0xbe8>
ffffffffc02011e2:	f6bfe0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc02011e6:	bd5d                	j	ffffffffc020109c <slub_check+0x52e>
        assert(info != NULL);
ffffffffc02011e8:	078bb783          	ld	a5,120(s7)
ffffffffc02011ec:	42078063          	beqz	a5,ffffffffc020160c <slub_check+0xa9e>
        cprintf("  Page info boundary access ✓\n");
ffffffffc02011f0:	00001517          	auipc	a0,0x1
ffffffffc02011f4:	41050513          	addi	a0,a0,1040 # ffffffffc0202600 <etext+0xb40>
ffffffffc02011f8:	f55fe0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc02011fc:	bb6d                	j	ffffffffc0200fb6 <slub_check+0x448>
        cprintf("\nMemory integrity check passed!\n");
ffffffffc02011fe:	00001517          	auipc	a0,0x1
ffffffffc0201202:	6aa50513          	addi	a0,a0,1706 # ffffffffc02028a8 <etext+0xde8>
ffffffffc0201206:	f47fe0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc020120a:	b765                	j	ffffffffc02011b2 <slub_check+0x644>
        size_t hit_rate = (slub_allocator.cache_hits * 10000) / final_allocs;
ffffffffc020120c:	068bb783          	ld	a5,104(s7)
ffffffffc0201210:	6709                	lui	a4,0x2
ffffffffc0201212:	71070713          	addi	a4,a4,1808 # 2710 <kern_entry-0xffffffffc01fd8f0>
ffffffffc0201216:	02e787b3          	mul	a5,a5,a4
                (unsigned int)(hit_rate % 100));
ffffffffc020121a:	06400613          	li	a2,100
        cprintf("  Cache hit rate: %u.%02u%%\n",
ffffffffc020121e:	00001517          	auipc	a0,0x1
ffffffffc0201222:	5c250513          	addi	a0,a0,1474 # ffffffffc02027e0 <etext+0xd20>
        size_t hit_rate = (slub_allocator.cache_hits * 10000) / final_allocs;
ffffffffc0201226:	0327d933          	divu	s2,a5,s2
                (unsigned int)(hit_rate / 100),
ffffffffc020122a:	02c955b3          	divu	a1,s2,a2
        cprintf("  Cache hit rate: %u.%02u%%\n",
ffffffffc020122e:	02c97633          	remu	a2,s2,a2
ffffffffc0201232:	2581                	sext.w	a1,a1
ffffffffc0201234:	f19fe0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0201238:	b705                	j	ffffffffc0201158 <slub_check+0x5ea>
        cprintf("  Large allocation skipped (insufficient memory)\n");
ffffffffc020123a:	00001517          	auipc	a0,0x1
ffffffffc020123e:	37e50513          	addi	a0,a0,894 # ffffffffc02025b8 <etext+0xaf8>
ffffffffc0201242:	f0bfe0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0201246:	bbb1                	j	ffffffffc0200fa2 <slub_check+0x434>
    for (size_t i = 0; i < npage; i++) {
ffffffffc0201248:	e402                	sd	zero,8(sp)
ffffffffc020124a:	b261                	j	ffffffffc0200bd2 <slub_check+0x64>
            assert(PageReserved(test_pages[i] + j));
ffffffffc020124c:	00001697          	auipc	a3,0x1
ffffffffc0201250:	27468693          	addi	a3,a3,628 # ffffffffc02024c0 <etext+0xa00>
ffffffffc0201254:	00001617          	auipc	a2,0x1
ffffffffc0201258:	c1c60613          	addi	a2,a2,-996 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc020125c:	17d00593          	li	a1,381
ffffffffc0201260:	00001517          	auipc	a0,0x1
ffffffffc0201264:	c2850513          	addi	a0,a0,-984 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc0201268:	f5bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
            assert(stress_pages[i] != NULL);
ffffffffc020126c:	00001697          	auipc	a3,0x1
ffffffffc0201270:	42468693          	addi	a3,a3,1060 # ffffffffc0202690 <etext+0xbd0>
ffffffffc0201274:	00001617          	auipc	a2,0x1
ffffffffc0201278:	bfc60613          	addi	a2,a2,-1028 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc020127c:	1ac00593          	li	a1,428
ffffffffc0201280:	00001517          	auipc	a0,0x1
ffffffffc0201284:	c0850513          	addi	a0,a0,-1016 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc0201288:	f3bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(cache->cpu_cache.freelist != NULL);
ffffffffc020128c:	00001697          	auipc	a3,0x1
ffffffffc0201290:	04c68693          	addi	a3,a3,76 # ffffffffc02022d8 <etext+0x818>
ffffffffc0201294:	00001617          	auipc	a2,0x1
ffffffffc0201298:	bdc60613          	addi	a2,a2,-1060 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc020129c:	15d00593          	li	a1,349
ffffffffc02012a0:	00001517          	auipc	a0,0x1
ffffffffc02012a4:	be850513          	addi	a0,a0,-1048 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc02012a8:	f1bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(cache->object_size == index_to_size(i));
ffffffffc02012ac:	00001697          	auipc	a3,0x1
ffffffffc02012b0:	f9468693          	addi	a3,a3,-108 # ffffffffc0202240 <etext+0x780>
ffffffffc02012b4:	00001617          	auipc	a2,0x1
ffffffffc02012b8:	bbc60613          	addi	a2,a2,-1092 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc02012bc:	15900593          	li	a1,345
ffffffffc02012c0:	00001517          	auipc	a0,0x1
ffffffffc02012c4:	bc850513          	addi	a0,a0,-1080 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc02012c8:	efbfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(list_empty(&cache->partial_list));
ffffffffc02012cc:	00001697          	auipc	a3,0x1
ffffffffc02012d0:	03468693          	addi	a3,a3,52 # ffffffffc0202300 <etext+0x840>
ffffffffc02012d4:	00001617          	auipc	a2,0x1
ffffffffc02012d8:	b9c60613          	addi	a2,a2,-1124 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc02012dc:	15e00593          	li	a1,350
ffffffffc02012e0:	00001517          	auipc	a0,0x1
ffffffffc02012e4:	ba850513          	addi	a0,a0,-1112 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc02012e8:	edbfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(actual_size == expected_sizes[i]);
ffffffffc02012ec:	00001697          	auipc	a3,0x1
ffffffffc02012f0:	e8c68693          	addi	a3,a3,-372 # ffffffffc0202178 <etext+0x6b8>
ffffffffc02012f4:	00001617          	auipc	a2,0x1
ffffffffc02012f8:	b7c60613          	addi	a2,a2,-1156 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc02012fc:	14400593          	li	a1,324
ffffffffc0201300:	00001517          	auipc	a0,0x1
ffffffffc0201304:	b8850513          	addi	a0,a0,-1144 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc0201308:	ebbfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(cache->cpu_cache.avail == 0);
ffffffffc020130c:	00001697          	auipc	a3,0x1
ffffffffc0201310:	fac68693          	addi	a3,a3,-84 # ffffffffc02022b8 <etext+0x7f8>
ffffffffc0201314:	00001617          	auipc	a2,0x1
ffffffffc0201318:	b5c60613          	addi	a2,a2,-1188 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc020131c:	15c00593          	li	a1,348
ffffffffc0201320:	00001517          	auipc	a0,0x1
ffffffffc0201324:	b6850513          	addi	a0,a0,-1176 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc0201328:	e9bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(cache->cpu_cache.limit == SLUB_CPU_CACHE_SIZE);
ffffffffc020132c:	00001697          	auipc	a3,0x1
ffffffffc0201330:	f5c68693          	addi	a3,a3,-164 # ffffffffc0202288 <etext+0x7c8>
ffffffffc0201334:	00001617          	auipc	a2,0x1
ffffffffc0201338:	b3c60613          	addi	a2,a2,-1220 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc020133c:	15b00593          	li	a1,347
ffffffffc0201340:	00001517          	auipc	a0,0x1
ffffffffc0201344:	b4850513          	addi	a0,a0,-1208 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc0201348:	e7bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(cache->objects_per_slab > 0);
ffffffffc020134c:	00001697          	auipc	a3,0x1
ffffffffc0201350:	f1c68693          	addi	a3,a3,-228 # ffffffffc0202268 <etext+0x7a8>
ffffffffc0201354:	00001617          	auipc	a2,0x1
ffffffffc0201358:	b1c60613          	addi	a2,a2,-1252 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc020135c:	15a00593          	li	a1,346
ffffffffc0201360:	00001517          	auipc	a0,0x1
ffffffffc0201364:	b2850513          	addi	a0,a0,-1240 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc0201368:	e5bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(cache != NULL);
ffffffffc020136c:	00001697          	auipc	a3,0x1
ffffffffc0201370:	ec468693          	addi	a3,a3,-316 # ffffffffc0202230 <etext+0x770>
ffffffffc0201374:	00001617          	auipc	a2,0x1
ffffffffc0201378:	afc60613          	addi	a2,a2,-1284 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc020137c:	15800593          	li	a1,344
ffffffffc0201380:	00001517          	auipc	a0,0x1
ffffffffc0201384:	b0850513          	addi	a0,a0,-1272 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc0201388:	e3bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(actual_index == i);
ffffffffc020138c:	00001697          	auipc	a3,0x1
ffffffffc0201390:	e3468693          	addi	a3,a3,-460 # ffffffffc02021c0 <etext+0x700>
ffffffffc0201394:	00001617          	auipc	a2,0x1
ffffffffc0201398:	adc60613          	addi	a2,a2,-1316 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc020139c:	14700593          	li	a1,327
ffffffffc02013a0:	00001517          	auipc	a0,0x1
ffffffffc02013a4:	ae850513          	addi	a0,a0,-1304 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc02013a8:	e1bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02013ac:	00001697          	auipc	a3,0x1
ffffffffc02013b0:	c9c68693          	addi	a3,a3,-868 # ffffffffc0202048 <etext+0x588>
ffffffffc02013b4:	00001617          	auipc	a2,0x1
ffffffffc02013b8:	abc60613          	addi	a2,a2,-1348 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc02013bc:	12400593          	li	a1,292
ffffffffc02013c0:	00001517          	auipc	a0,0x1
ffffffffc02013c4:	ac850513          	addi	a0,a0,-1336 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc02013c8:	dfbfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02013cc:	00001697          	auipc	a3,0x1
ffffffffc02013d0:	c5c68693          	addi	a3,a3,-932 # ffffffffc0202028 <etext+0x568>
ffffffffc02013d4:	00001617          	auipc	a2,0x1
ffffffffc02013d8:	a9c60613          	addi	a2,a2,-1380 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc02013dc:	12300593          	li	a1,291
ffffffffc02013e0:	00001517          	auipc	a0,0x1
ffffffffc02013e4:	aa850513          	addi	a0,a0,-1368 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc02013e8:	ddbfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02013ec:	00001697          	auipc	a3,0x1
ffffffffc02013f0:	c1c68693          	addi	a3,a3,-996 # ffffffffc0202008 <etext+0x548>
ffffffffc02013f4:	00001617          	auipc	a2,0x1
ffffffffc02013f8:	a7c60613          	addi	a2,a2,-1412 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc02013fc:	12200593          	li	a1,290
ffffffffc0201400:	00001517          	auipc	a0,0x1
ffffffffc0201404:	a8850513          	addi	a0,a0,-1400 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc0201408:	dbbfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020140c:	00001697          	auipc	a3,0x1
ffffffffc0201410:	d0468693          	addi	a3,a3,-764 # ffffffffc0202110 <etext+0x650>
ffffffffc0201414:	00001617          	auipc	a2,0x1
ffffffffc0201418:	a5c60613          	addi	a2,a2,-1444 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc020141c:	11700593          	li	a1,279
ffffffffc0201420:	00001517          	auipc	a0,0x1
ffffffffc0201424:	a6850513          	addi	a0,a0,-1432 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc0201428:	d9bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(info->objects == 0);
ffffffffc020142c:	00001697          	auipc	a3,0x1
ffffffffc0201430:	ff468693          	addi	a3,a3,-12 # ffffffffc0202420 <etext+0x960>
ffffffffc0201434:	00001617          	auipc	a2,0x1
ffffffffc0201438:	a3c60613          	addi	a2,a2,-1476 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc020143c:	16e00593          	li	a1,366
ffffffffc0201440:	00001517          	auipc	a0,0x1
ffffffffc0201444:	a4850513          	addi	a0,a0,-1464 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc0201448:	d7bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(info->inuse == 0);
ffffffffc020144c:	00001697          	auipc	a3,0x1
ffffffffc0201450:	fbc68693          	addi	a3,a3,-68 # ffffffffc0202408 <etext+0x948>
ffffffffc0201454:	00001617          	auipc	a2,0x1
ffffffffc0201458:	a1c60613          	addi	a2,a2,-1508 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc020145c:	16d00593          	li	a1,365
ffffffffc0201460:	00001517          	auipc	a0,0x1
ffffffffc0201464:	a2850513          	addi	a0,a0,-1496 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc0201468:	d5bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020146c:	00001697          	auipc	a3,0x1
ffffffffc0201470:	c8468693          	addi	a3,a3,-892 # ffffffffc02020f0 <etext+0x630>
ffffffffc0201474:	00001617          	auipc	a2,0x1
ffffffffc0201478:	9fc60613          	addi	a2,a2,-1540 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc020147c:	11600593          	li	a1,278
ffffffffc0201480:	00001517          	auipc	a0,0x1
ffffffffc0201484:	a0850513          	addi	a0,a0,-1528 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc0201488:	d3bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020148c:	00001697          	auipc	a3,0x1
ffffffffc0201490:	c4468693          	addi	a3,a3,-956 # ffffffffc02020d0 <etext+0x610>
ffffffffc0201494:	00001617          	auipc	a2,0x1
ffffffffc0201498:	9dc60613          	addi	a2,a2,-1572 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc020149c:	11500593          	li	a1,277
ffffffffc02014a0:	00001517          	auipc	a0,0x1
ffffffffc02014a4:	9e850513          	addi	a0,a0,-1560 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc02014a8:	d1bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02014ac:	00001697          	auipc	a3,0x1
ffffffffc02014b0:	be468693          	addi	a3,a3,-1052 # ffffffffc0202090 <etext+0x5d0>
ffffffffc02014b4:	00001617          	auipc	a2,0x1
ffffffffc02014b8:	9bc60613          	addi	a2,a2,-1604 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc02014bc:	11300593          	li	a1,275
ffffffffc02014c0:	00001517          	auipc	a0,0x1
ffffffffc02014c4:	9c850513          	addi	a0,a0,-1592 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc02014c8:	cfbfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02014cc:	00001697          	auipc	a3,0x1
ffffffffc02014d0:	b9c68693          	addi	a3,a3,-1124 # ffffffffc0202068 <etext+0x5a8>
ffffffffc02014d4:	00001617          	auipc	a2,0x1
ffffffffc02014d8:	99c60613          	addi	a2,a2,-1636 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc02014dc:	11200593          	li	a1,274
ffffffffc02014e0:	00001517          	auipc	a0,0x1
ffffffffc02014e4:	9a850513          	addi	a0,a0,-1624 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc02014e8:	cdbfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02014ec:	00001697          	auipc	a3,0x1
ffffffffc02014f0:	b5c68693          	addi	a3,a3,-1188 # ffffffffc0202048 <etext+0x588>
ffffffffc02014f4:	00001617          	auipc	a2,0x1
ffffffffc02014f8:	97c60613          	addi	a2,a2,-1668 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc02014fc:	11000593          	li	a1,272
ffffffffc0201500:	00001517          	auipc	a0,0x1
ffffffffc0201504:	98850513          	addi	a0,a0,-1656 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc0201508:	cbbfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020150c:	00001697          	auipc	a3,0x1
ffffffffc0201510:	b1c68693          	addi	a3,a3,-1252 # ffffffffc0202028 <etext+0x568>
ffffffffc0201514:	00001617          	auipc	a2,0x1
ffffffffc0201518:	95c60613          	addi	a2,a2,-1700 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc020151c:	10f00593          	li	a1,271
ffffffffc0201520:	00001517          	auipc	a0,0x1
ffffffffc0201524:	96850513          	addi	a0,a0,-1688 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc0201528:	c9bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p_single != NULL);
ffffffffc020152c:	00001697          	auipc	a3,0x1
ffffffffc0201530:	02c68693          	addi	a3,a3,44 # ffffffffc0202558 <etext+0xa98>
ffffffffc0201534:	00001617          	auipc	a2,0x1
ffffffffc0201538:	93c60613          	addi	a2,a2,-1732 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc020153c:	18b00593          	li	a1,395
ffffffffc0201540:	00001517          	auipc	a0,0x1
ffffffffc0201544:	94850513          	addi	a0,a0,-1720 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc0201548:	c7bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020154c:	00001697          	auipc	a3,0x1
ffffffffc0201550:	abc68693          	addi	a3,a3,-1348 # ffffffffc0202008 <etext+0x548>
ffffffffc0201554:	00001617          	auipc	a2,0x1
ffffffffc0201558:	91c60613          	addi	a2,a2,-1764 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc020155c:	10e00593          	li	a1,270
ffffffffc0201560:	00001517          	auipc	a0,0x1
ffffffffc0201564:	92850513          	addi	a0,a0,-1752 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc0201568:	c5bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(info->freelist == NULL);
ffffffffc020156c:	00001697          	auipc	a3,0x1
ffffffffc0201570:	e8468693          	addi	a3,a3,-380 # ffffffffc02023f0 <etext+0x930>
ffffffffc0201574:	00001617          	auipc	a2,0x1
ffffffffc0201578:	8fc60613          	addi	a2,a2,-1796 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc020157c:	16c00593          	li	a1,364
ffffffffc0201580:	00001517          	auipc	a0,0x1
ffffffffc0201584:	90850513          	addi	a0,a0,-1784 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc0201588:	c3bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(slub_allocator.max_pages > 0);
ffffffffc020158c:	00001697          	auipc	a3,0x1
ffffffffc0201590:	e4468693          	addi	a3,a3,-444 # ffffffffc02023d0 <etext+0x910>
ffffffffc0201594:	00001617          	auipc	a2,0x1
ffffffffc0201598:	8dc60613          	addi	a2,a2,-1828 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc020159c:	16800593          	li	a1,360
ffffffffc02015a0:	00001517          	auipc	a0,0x1
ffffffffc02015a4:	8e850513          	addi	a0,a0,-1816 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc02015a8:	c1bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(test_pages[i] != NULL);
ffffffffc02015ac:	00001697          	auipc	a3,0x1
ffffffffc02015b0:	efc68693          	addi	a3,a3,-260 # ffffffffc02024a8 <etext+0x9e8>
ffffffffc02015b4:	00001617          	auipc	a2,0x1
ffffffffc02015b8:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc02015bc:	17a00593          	li	a1,378
ffffffffc02015c0:	00001517          	auipc	a0,0x1
ffffffffc02015c4:	8c850513          	addi	a0,a0,-1848 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc02015c8:	bfbfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(info->cache == NULL);
ffffffffc02015cc:	00001697          	auipc	a3,0x1
ffffffffc02015d0:	e6c68693          	addi	a3,a3,-404 # ffffffffc0202438 <etext+0x978>
ffffffffc02015d4:	00001617          	auipc	a2,0x1
ffffffffc02015d8:	89c60613          	addi	a2,a2,-1892 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc02015dc:	16f00593          	li	a1,367
ffffffffc02015e0:	00001517          	auipc	a0,0x1
ffffffffc02015e4:	8a850513          	addi	a0,a0,-1880 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc02015e8:	bdbfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(slub_allocator.page_infos != NULL);
ffffffffc02015ec:	00001697          	auipc	a3,0x1
ffffffffc02015f0:	dbc68693          	addi	a3,a3,-580 # ffffffffc02023a8 <etext+0x8e8>
ffffffffc02015f4:	00001617          	auipc	a2,0x1
ffffffffc02015f8:	87c60613          	addi	a2,a2,-1924 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc02015fc:	16700593          	li	a1,359
ffffffffc0201600:	00001517          	auipc	a0,0x1
ffffffffc0201604:	88850513          	addi	a0,a0,-1912 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc0201608:	bbbfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(info != NULL);
ffffffffc020160c:	00001697          	auipc	a3,0x1
ffffffffc0201610:	fe468693          	addi	a3,a3,-28 # ffffffffc02025f0 <etext+0xb30>
ffffffffc0201614:	00001617          	auipc	a2,0x1
ffffffffc0201618:	85c60613          	addi	a2,a2,-1956 # ffffffffc0201e70 <etext+0x3b0>
ffffffffc020161c:	19a00593          	li	a1,410
ffffffffc0201620:	00001517          	auipc	a0,0x1
ffffffffc0201624:	86850513          	addi	a0,a0,-1944 # ffffffffc0201e88 <etext+0x3c8>
ffffffffc0201628:	b9bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc020162c <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020162c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201630:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201632:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201636:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201638:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020163c:	f022                	sd	s0,32(sp)
ffffffffc020163e:	ec26                	sd	s1,24(sp)
ffffffffc0201640:	e84a                	sd	s2,16(sp)
ffffffffc0201642:	f406                	sd	ra,40(sp)
ffffffffc0201644:	e44e                	sd	s3,8(sp)
ffffffffc0201646:	84aa                	mv	s1,a0
ffffffffc0201648:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020164a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020164e:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201650:	03067e63          	bgeu	a2,a6,ffffffffc020168c <printnum+0x60>
ffffffffc0201654:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201656:	00805763          	blez	s0,ffffffffc0201664 <printnum+0x38>
ffffffffc020165a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020165c:	85ca                	mv	a1,s2
ffffffffc020165e:	854e                	mv	a0,s3
ffffffffc0201660:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201662:	fc65                	bnez	s0,ffffffffc020165a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201664:	1a02                	slli	s4,s4,0x20
ffffffffc0201666:	00001797          	auipc	a5,0x1
ffffffffc020166a:	34278793          	addi	a5,a5,834 # ffffffffc02029a8 <slub_pmm_manager+0x38>
ffffffffc020166e:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201672:	9a3e                	add	s4,s4,a5
}
ffffffffc0201674:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201676:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020167a:	70a2                	ld	ra,40(sp)
ffffffffc020167c:	69a2                	ld	s3,8(sp)
ffffffffc020167e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201680:	85ca                	mv	a1,s2
ffffffffc0201682:	87a6                	mv	a5,s1
}
ffffffffc0201684:	6942                	ld	s2,16(sp)
ffffffffc0201686:	64e2                	ld	s1,24(sp)
ffffffffc0201688:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020168a:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020168c:	03065633          	divu	a2,a2,a6
ffffffffc0201690:	8722                	mv	a4,s0
ffffffffc0201692:	f9bff0ef          	jal	ra,ffffffffc020162c <printnum>
ffffffffc0201696:	b7f9                	j	ffffffffc0201664 <printnum+0x38>

ffffffffc0201698 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201698:	7119                	addi	sp,sp,-128
ffffffffc020169a:	f4a6                	sd	s1,104(sp)
ffffffffc020169c:	f0ca                	sd	s2,96(sp)
ffffffffc020169e:	ecce                	sd	s3,88(sp)
ffffffffc02016a0:	e8d2                	sd	s4,80(sp)
ffffffffc02016a2:	e4d6                	sd	s5,72(sp)
ffffffffc02016a4:	e0da                	sd	s6,64(sp)
ffffffffc02016a6:	fc5e                	sd	s7,56(sp)
ffffffffc02016a8:	f06a                	sd	s10,32(sp)
ffffffffc02016aa:	fc86                	sd	ra,120(sp)
ffffffffc02016ac:	f8a2                	sd	s0,112(sp)
ffffffffc02016ae:	f862                	sd	s8,48(sp)
ffffffffc02016b0:	f466                	sd	s9,40(sp)
ffffffffc02016b2:	ec6e                	sd	s11,24(sp)
ffffffffc02016b4:	892a                	mv	s2,a0
ffffffffc02016b6:	84ae                	mv	s1,a1
ffffffffc02016b8:	8d32                	mv	s10,a2
ffffffffc02016ba:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02016bc:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02016c0:	5b7d                	li	s6,-1
ffffffffc02016c2:	00001a97          	auipc	s5,0x1
ffffffffc02016c6:	31aa8a93          	addi	s5,s5,794 # ffffffffc02029dc <slub_pmm_manager+0x6c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02016ca:	00001b97          	auipc	s7,0x1
ffffffffc02016ce:	4eeb8b93          	addi	s7,s7,1262 # ffffffffc0202bb8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02016d2:	000d4503          	lbu	a0,0(s10)
ffffffffc02016d6:	001d0413          	addi	s0,s10,1
ffffffffc02016da:	01350a63          	beq	a0,s3,ffffffffc02016ee <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02016de:	c121                	beqz	a0,ffffffffc020171e <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02016e0:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02016e2:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02016e4:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02016e6:	fff44503          	lbu	a0,-1(s0)
ffffffffc02016ea:	ff351ae3          	bne	a0,s3,ffffffffc02016de <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016ee:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02016f2:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02016f6:	4c81                	li	s9,0
ffffffffc02016f8:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02016fa:	5c7d                	li	s8,-1
ffffffffc02016fc:	5dfd                	li	s11,-1
ffffffffc02016fe:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201702:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201704:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201708:	0ff5f593          	zext.b	a1,a1
ffffffffc020170c:	00140d13          	addi	s10,s0,1
ffffffffc0201710:	04b56263          	bltu	a0,a1,ffffffffc0201754 <vprintfmt+0xbc>
ffffffffc0201714:	058a                	slli	a1,a1,0x2
ffffffffc0201716:	95d6                	add	a1,a1,s5
ffffffffc0201718:	4194                	lw	a3,0(a1)
ffffffffc020171a:	96d6                	add	a3,a3,s5
ffffffffc020171c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020171e:	70e6                	ld	ra,120(sp)
ffffffffc0201720:	7446                	ld	s0,112(sp)
ffffffffc0201722:	74a6                	ld	s1,104(sp)
ffffffffc0201724:	7906                	ld	s2,96(sp)
ffffffffc0201726:	69e6                	ld	s3,88(sp)
ffffffffc0201728:	6a46                	ld	s4,80(sp)
ffffffffc020172a:	6aa6                	ld	s5,72(sp)
ffffffffc020172c:	6b06                	ld	s6,64(sp)
ffffffffc020172e:	7be2                	ld	s7,56(sp)
ffffffffc0201730:	7c42                	ld	s8,48(sp)
ffffffffc0201732:	7ca2                	ld	s9,40(sp)
ffffffffc0201734:	7d02                	ld	s10,32(sp)
ffffffffc0201736:	6de2                	ld	s11,24(sp)
ffffffffc0201738:	6109                	addi	sp,sp,128
ffffffffc020173a:	8082                	ret
            padc = '0';
ffffffffc020173c:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020173e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201742:	846a                	mv	s0,s10
ffffffffc0201744:	00140d13          	addi	s10,s0,1
ffffffffc0201748:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020174c:	0ff5f593          	zext.b	a1,a1
ffffffffc0201750:	fcb572e3          	bgeu	a0,a1,ffffffffc0201714 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201754:	85a6                	mv	a1,s1
ffffffffc0201756:	02500513          	li	a0,37
ffffffffc020175a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020175c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201760:	8d22                	mv	s10,s0
ffffffffc0201762:	f73788e3          	beq	a5,s3,ffffffffc02016d2 <vprintfmt+0x3a>
ffffffffc0201766:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020176a:	1d7d                	addi	s10,s10,-1
ffffffffc020176c:	ff379de3          	bne	a5,s3,ffffffffc0201766 <vprintfmt+0xce>
ffffffffc0201770:	b78d                	j	ffffffffc02016d2 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201772:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201776:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020177a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020177c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201780:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201784:	02d86463          	bltu	a6,a3,ffffffffc02017ac <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201788:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020178c:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201790:	0186873b          	addw	a4,a3,s8
ffffffffc0201794:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201798:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020179a:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020179e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02017a0:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02017a4:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02017a8:	fed870e3          	bgeu	a6,a3,ffffffffc0201788 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02017ac:	f40ddce3          	bgez	s11,ffffffffc0201704 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02017b0:	8de2                	mv	s11,s8
ffffffffc02017b2:	5c7d                	li	s8,-1
ffffffffc02017b4:	bf81                	j	ffffffffc0201704 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02017b6:	fffdc693          	not	a3,s11
ffffffffc02017ba:	96fd                	srai	a3,a3,0x3f
ffffffffc02017bc:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017c0:	00144603          	lbu	a2,1(s0)
ffffffffc02017c4:	2d81                	sext.w	s11,s11
ffffffffc02017c6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02017c8:	bf35                	j	ffffffffc0201704 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02017ca:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017ce:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02017d2:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017d4:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02017d6:	bfd9                	j	ffffffffc02017ac <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02017d8:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02017da:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02017de:	01174463          	blt	a4,a7,ffffffffc02017e6 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02017e2:	1a088e63          	beqz	a7,ffffffffc020199e <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02017e6:	000a3603          	ld	a2,0(s4)
ffffffffc02017ea:	46c1                	li	a3,16
ffffffffc02017ec:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02017ee:	2781                	sext.w	a5,a5
ffffffffc02017f0:	876e                	mv	a4,s11
ffffffffc02017f2:	85a6                	mv	a1,s1
ffffffffc02017f4:	854a                	mv	a0,s2
ffffffffc02017f6:	e37ff0ef          	jal	ra,ffffffffc020162c <printnum>
            break;
ffffffffc02017fa:	bde1                	j	ffffffffc02016d2 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02017fc:	000a2503          	lw	a0,0(s4)
ffffffffc0201800:	85a6                	mv	a1,s1
ffffffffc0201802:	0a21                	addi	s4,s4,8
ffffffffc0201804:	9902                	jalr	s2
            break;
ffffffffc0201806:	b5f1                	j	ffffffffc02016d2 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201808:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020180a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020180e:	01174463          	blt	a4,a7,ffffffffc0201816 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201812:	18088163          	beqz	a7,ffffffffc0201994 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201816:	000a3603          	ld	a2,0(s4)
ffffffffc020181a:	46a9                	li	a3,10
ffffffffc020181c:	8a2e                	mv	s4,a1
ffffffffc020181e:	bfc1                	j	ffffffffc02017ee <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201820:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201824:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201826:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201828:	bdf1                	j	ffffffffc0201704 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020182a:	85a6                	mv	a1,s1
ffffffffc020182c:	02500513          	li	a0,37
ffffffffc0201830:	9902                	jalr	s2
            break;
ffffffffc0201832:	b545                	j	ffffffffc02016d2 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201834:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201838:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020183a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020183c:	b5e1                	j	ffffffffc0201704 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020183e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201840:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201844:	01174463          	blt	a4,a7,ffffffffc020184c <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201848:	14088163          	beqz	a7,ffffffffc020198a <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020184c:	000a3603          	ld	a2,0(s4)
ffffffffc0201850:	46a1                	li	a3,8
ffffffffc0201852:	8a2e                	mv	s4,a1
ffffffffc0201854:	bf69                	j	ffffffffc02017ee <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201856:	03000513          	li	a0,48
ffffffffc020185a:	85a6                	mv	a1,s1
ffffffffc020185c:	e03e                	sd	a5,0(sp)
ffffffffc020185e:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201860:	85a6                	mv	a1,s1
ffffffffc0201862:	07800513          	li	a0,120
ffffffffc0201866:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201868:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020186a:	6782                	ld	a5,0(sp)
ffffffffc020186c:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020186e:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201872:	bfb5                	j	ffffffffc02017ee <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201874:	000a3403          	ld	s0,0(s4)
ffffffffc0201878:	008a0713          	addi	a4,s4,8
ffffffffc020187c:	e03a                	sd	a4,0(sp)
ffffffffc020187e:	14040263          	beqz	s0,ffffffffc02019c2 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201882:	0fb05763          	blez	s11,ffffffffc0201970 <vprintfmt+0x2d8>
ffffffffc0201886:	02d00693          	li	a3,45
ffffffffc020188a:	0cd79163          	bne	a5,a3,ffffffffc020194c <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020188e:	00044783          	lbu	a5,0(s0)
ffffffffc0201892:	0007851b          	sext.w	a0,a5
ffffffffc0201896:	cf85                	beqz	a5,ffffffffc02018ce <vprintfmt+0x236>
ffffffffc0201898:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020189c:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018a0:	000c4563          	bltz	s8,ffffffffc02018aa <vprintfmt+0x212>
ffffffffc02018a4:	3c7d                	addiw	s8,s8,-1
ffffffffc02018a6:	036c0263          	beq	s8,s6,ffffffffc02018ca <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02018aa:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02018ac:	0e0c8e63          	beqz	s9,ffffffffc02019a8 <vprintfmt+0x310>
ffffffffc02018b0:	3781                	addiw	a5,a5,-32
ffffffffc02018b2:	0ef47b63          	bgeu	s0,a5,ffffffffc02019a8 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02018b6:	03f00513          	li	a0,63
ffffffffc02018ba:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018bc:	000a4783          	lbu	a5,0(s4)
ffffffffc02018c0:	3dfd                	addiw	s11,s11,-1
ffffffffc02018c2:	0a05                	addi	s4,s4,1
ffffffffc02018c4:	0007851b          	sext.w	a0,a5
ffffffffc02018c8:	ffe1                	bnez	a5,ffffffffc02018a0 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02018ca:	01b05963          	blez	s11,ffffffffc02018dc <vprintfmt+0x244>
ffffffffc02018ce:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02018d0:	85a6                	mv	a1,s1
ffffffffc02018d2:	02000513          	li	a0,32
ffffffffc02018d6:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02018d8:	fe0d9be3          	bnez	s11,ffffffffc02018ce <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02018dc:	6a02                	ld	s4,0(sp)
ffffffffc02018de:	bbd5                	j	ffffffffc02016d2 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02018e0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02018e2:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02018e6:	01174463          	blt	a4,a7,ffffffffc02018ee <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02018ea:	08088d63          	beqz	a7,ffffffffc0201984 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02018ee:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02018f2:	0a044d63          	bltz	s0,ffffffffc02019ac <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02018f6:	8622                	mv	a2,s0
ffffffffc02018f8:	8a66                	mv	s4,s9
ffffffffc02018fa:	46a9                	li	a3,10
ffffffffc02018fc:	bdcd                	j	ffffffffc02017ee <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02018fe:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201902:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201904:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201906:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020190a:	8fb5                	xor	a5,a5,a3
ffffffffc020190c:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201910:	02d74163          	blt	a4,a3,ffffffffc0201932 <vprintfmt+0x29a>
ffffffffc0201914:	00369793          	slli	a5,a3,0x3
ffffffffc0201918:	97de                	add	a5,a5,s7
ffffffffc020191a:	639c                	ld	a5,0(a5)
ffffffffc020191c:	cb99                	beqz	a5,ffffffffc0201932 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020191e:	86be                	mv	a3,a5
ffffffffc0201920:	00001617          	auipc	a2,0x1
ffffffffc0201924:	0b860613          	addi	a2,a2,184 # ffffffffc02029d8 <slub_pmm_manager+0x68>
ffffffffc0201928:	85a6                	mv	a1,s1
ffffffffc020192a:	854a                	mv	a0,s2
ffffffffc020192c:	0ce000ef          	jal	ra,ffffffffc02019fa <printfmt>
ffffffffc0201930:	b34d                	j	ffffffffc02016d2 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201932:	00001617          	auipc	a2,0x1
ffffffffc0201936:	09660613          	addi	a2,a2,150 # ffffffffc02029c8 <slub_pmm_manager+0x58>
ffffffffc020193a:	85a6                	mv	a1,s1
ffffffffc020193c:	854a                	mv	a0,s2
ffffffffc020193e:	0bc000ef          	jal	ra,ffffffffc02019fa <printfmt>
ffffffffc0201942:	bb41                	j	ffffffffc02016d2 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201944:	00001417          	auipc	s0,0x1
ffffffffc0201948:	07c40413          	addi	s0,s0,124 # ffffffffc02029c0 <slub_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020194c:	85e2                	mv	a1,s8
ffffffffc020194e:	8522                	mv	a0,s0
ffffffffc0201950:	e43e                	sd	a5,8(sp)
ffffffffc0201952:	0fc000ef          	jal	ra,ffffffffc0201a4e <strnlen>
ffffffffc0201956:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020195a:	01b05b63          	blez	s11,ffffffffc0201970 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020195e:	67a2                	ld	a5,8(sp)
ffffffffc0201960:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201964:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201966:	85a6                	mv	a1,s1
ffffffffc0201968:	8552                	mv	a0,s4
ffffffffc020196a:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020196c:	fe0d9ce3          	bnez	s11,ffffffffc0201964 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201970:	00044783          	lbu	a5,0(s0)
ffffffffc0201974:	00140a13          	addi	s4,s0,1
ffffffffc0201978:	0007851b          	sext.w	a0,a5
ffffffffc020197c:	d3a5                	beqz	a5,ffffffffc02018dc <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020197e:	05e00413          	li	s0,94
ffffffffc0201982:	bf39                	j	ffffffffc02018a0 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201984:	000a2403          	lw	s0,0(s4)
ffffffffc0201988:	b7ad                	j	ffffffffc02018f2 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020198a:	000a6603          	lwu	a2,0(s4)
ffffffffc020198e:	46a1                	li	a3,8
ffffffffc0201990:	8a2e                	mv	s4,a1
ffffffffc0201992:	bdb1                	j	ffffffffc02017ee <vprintfmt+0x156>
ffffffffc0201994:	000a6603          	lwu	a2,0(s4)
ffffffffc0201998:	46a9                	li	a3,10
ffffffffc020199a:	8a2e                	mv	s4,a1
ffffffffc020199c:	bd89                	j	ffffffffc02017ee <vprintfmt+0x156>
ffffffffc020199e:	000a6603          	lwu	a2,0(s4)
ffffffffc02019a2:	46c1                	li	a3,16
ffffffffc02019a4:	8a2e                	mv	s4,a1
ffffffffc02019a6:	b5a1                	j	ffffffffc02017ee <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02019a8:	9902                	jalr	s2
ffffffffc02019aa:	bf09                	j	ffffffffc02018bc <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02019ac:	85a6                	mv	a1,s1
ffffffffc02019ae:	02d00513          	li	a0,45
ffffffffc02019b2:	e03e                	sd	a5,0(sp)
ffffffffc02019b4:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02019b6:	6782                	ld	a5,0(sp)
ffffffffc02019b8:	8a66                	mv	s4,s9
ffffffffc02019ba:	40800633          	neg	a2,s0
ffffffffc02019be:	46a9                	li	a3,10
ffffffffc02019c0:	b53d                	j	ffffffffc02017ee <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02019c2:	03b05163          	blez	s11,ffffffffc02019e4 <vprintfmt+0x34c>
ffffffffc02019c6:	02d00693          	li	a3,45
ffffffffc02019ca:	f6d79de3          	bne	a5,a3,ffffffffc0201944 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02019ce:	00001417          	auipc	s0,0x1
ffffffffc02019d2:	ff240413          	addi	s0,s0,-14 # ffffffffc02029c0 <slub_pmm_manager+0x50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02019d6:	02800793          	li	a5,40
ffffffffc02019da:	02800513          	li	a0,40
ffffffffc02019de:	00140a13          	addi	s4,s0,1
ffffffffc02019e2:	bd6d                	j	ffffffffc020189c <vprintfmt+0x204>
ffffffffc02019e4:	00001a17          	auipc	s4,0x1
ffffffffc02019e8:	fdda0a13          	addi	s4,s4,-35 # ffffffffc02029c1 <slub_pmm_manager+0x51>
ffffffffc02019ec:	02800513          	li	a0,40
ffffffffc02019f0:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02019f4:	05e00413          	li	s0,94
ffffffffc02019f8:	b565                	j	ffffffffc02018a0 <vprintfmt+0x208>

ffffffffc02019fa <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02019fa:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02019fc:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a00:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201a02:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a04:	ec06                	sd	ra,24(sp)
ffffffffc0201a06:	f83a                	sd	a4,48(sp)
ffffffffc0201a08:	fc3e                	sd	a5,56(sp)
ffffffffc0201a0a:	e0c2                	sd	a6,64(sp)
ffffffffc0201a0c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201a0e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201a10:	c89ff0ef          	jal	ra,ffffffffc0201698 <vprintfmt>
}
ffffffffc0201a14:	60e2                	ld	ra,24(sp)
ffffffffc0201a16:	6161                	addi	sp,sp,80
ffffffffc0201a18:	8082                	ret

ffffffffc0201a1a <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201a1a:	4781                	li	a5,0
ffffffffc0201a1c:	00004717          	auipc	a4,0x4
ffffffffc0201a20:	5f473703          	ld	a4,1524(a4) # ffffffffc0206010 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201a24:	88ba                	mv	a7,a4
ffffffffc0201a26:	852a                	mv	a0,a0
ffffffffc0201a28:	85be                	mv	a1,a5
ffffffffc0201a2a:	863e                	mv	a2,a5
ffffffffc0201a2c:	00000073          	ecall
ffffffffc0201a30:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201a32:	8082                	ret

ffffffffc0201a34 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0201a34:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0201a38:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0201a3a:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0201a3c:	cb81                	beqz	a5,ffffffffc0201a4c <strlen+0x18>
        cnt ++;
ffffffffc0201a3e:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0201a40:	00a707b3          	add	a5,a4,a0
ffffffffc0201a44:	0007c783          	lbu	a5,0(a5)
ffffffffc0201a48:	fbfd                	bnez	a5,ffffffffc0201a3e <strlen+0xa>
ffffffffc0201a4a:	8082                	ret
    }
    return cnt;
}
ffffffffc0201a4c:	8082                	ret

ffffffffc0201a4e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201a4e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a50:	e589                	bnez	a1,ffffffffc0201a5a <strnlen+0xc>
ffffffffc0201a52:	a811                	j	ffffffffc0201a66 <strnlen+0x18>
        cnt ++;
ffffffffc0201a54:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a56:	00f58863          	beq	a1,a5,ffffffffc0201a66 <strnlen+0x18>
ffffffffc0201a5a:	00f50733          	add	a4,a0,a5
ffffffffc0201a5e:	00074703          	lbu	a4,0(a4)
ffffffffc0201a62:	fb6d                	bnez	a4,ffffffffc0201a54 <strnlen+0x6>
ffffffffc0201a64:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201a66:	852e                	mv	a0,a1
ffffffffc0201a68:	8082                	ret

ffffffffc0201a6a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a6a:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a6e:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a72:	cb89                	beqz	a5,ffffffffc0201a84 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201a74:	0505                	addi	a0,a0,1
ffffffffc0201a76:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a78:	fee789e3          	beq	a5,a4,ffffffffc0201a6a <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a7c:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201a80:	9d19                	subw	a0,a0,a4
ffffffffc0201a82:	8082                	ret
ffffffffc0201a84:	4501                	li	a0,0
ffffffffc0201a86:	bfed                	j	ffffffffc0201a80 <strcmp+0x16>

ffffffffc0201a88 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201a88:	c20d                	beqz	a2,ffffffffc0201aaa <strncmp+0x22>
ffffffffc0201a8a:	962e                	add	a2,a2,a1
ffffffffc0201a8c:	a031                	j	ffffffffc0201a98 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0201a8e:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201a90:	00e79a63          	bne	a5,a4,ffffffffc0201aa4 <strncmp+0x1c>
ffffffffc0201a94:	00b60b63          	beq	a2,a1,ffffffffc0201aaa <strncmp+0x22>
ffffffffc0201a98:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0201a9c:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201a9e:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0201aa2:	f7f5                	bnez	a5,ffffffffc0201a8e <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201aa4:	40e7853b          	subw	a0,a5,a4
}
ffffffffc0201aa8:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201aaa:	4501                	li	a0,0
ffffffffc0201aac:	8082                	ret

ffffffffc0201aae <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201aae:	ca01                	beqz	a2,ffffffffc0201abe <memset+0x10>
ffffffffc0201ab0:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201ab2:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201ab4:	0785                	addi	a5,a5,1
ffffffffc0201ab6:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201aba:	fec79de3          	bne	a5,a2,ffffffffc0201ab4 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201abe:	8082                	ret
