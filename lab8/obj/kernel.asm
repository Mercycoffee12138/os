
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
ffffffffc0200000:	00014297          	auipc	t0,0x14
ffffffffc0200004:	00028293          	mv	t0,t0
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0214000 <boot_hartid>
ffffffffc020000c:	00014297          	auipc	t0,0x14
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0214008 <boot_dtb>
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
ffffffffc0200018:	c02132b7          	lui	t0,0xc0213
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
ffffffffc0200034:	18029073          	csrw	satp,t0
ffffffffc0200038:	12000073          	sfence.vma
ffffffffc020003c:	c0213137          	lui	sp,0xc0213
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
ffffffffc0200044:	04a28293          	addi	t0,t0,74 # ffffffffc020004a <kern_init>
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <kern_init>:
ffffffffc020004a:	00091517          	auipc	a0,0x91
ffffffffc020004e:	01650513          	addi	a0,a0,22 # ffffffffc0291060 <buf>
ffffffffc0200052:	00097617          	auipc	a2,0x97
ffffffffc0200056:	8be60613          	addi	a2,a2,-1858 # ffffffffc0296910 <end>
ffffffffc020005a:	1141                	addi	sp,sp,-16
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
ffffffffc0200060:	e406                	sd	ra,8(sp)
ffffffffc0200062:	0d00b0ef          	jal	ra,ffffffffc020b132 <memset>
ffffffffc0200066:	209000ef          	jal	ra,ffffffffc0200a6e <cons_init>
ffffffffc020006a:	0000b597          	auipc	a1,0xb
ffffffffc020006e:	5c658593          	addi	a1,a1,1478 # ffffffffc020b630 <etext+0x2>
ffffffffc0200072:	0000b517          	auipc	a0,0xb
ffffffffc0200076:	5de50513          	addi	a0,a0,1502 # ffffffffc020b650 <etext+0x22>
ffffffffc020007a:	0b0000ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020007e:	25c000ef          	jal	ra,ffffffffc02002da <print_kerninfo>
ffffffffc0200082:	4ca000ef          	jal	ra,ffffffffc020054c <dtb_init>
ffffffffc0200086:	3c9010ef          	jal	ra,ffffffffc0201c4e <pmm_init>
ffffffffc020008a:	2ff000ef          	jal	ra,ffffffffc0200b88 <pic_init>
ffffffffc020008e:	519000ef          	jal	ra,ffffffffc0200da6 <idt_init>
ffffffffc0200092:	054030ef          	jal	ra,ffffffffc02030e6 <vmm_init>
ffffffffc0200096:	1ce070ef          	jal	ra,ffffffffc0207264 <sched_init>
ffffffffc020009a:	727060ef          	jal	ra,ffffffffc0206fc0 <proc_init>
ffffffffc020009e:	2ed000ef          	jal	ra,ffffffffc0200b8a <ide_init>
ffffffffc02000a2:	720050ef          	jal	ra,ffffffffc02057c2 <fs_init>
ffffffffc02000a6:	17f000ef          	jal	ra,ffffffffc0200a24 <clock_init>
ffffffffc02000aa:	4f1000ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc02000ae:	0de070ef          	jal	ra,ffffffffc020718c <cpu_idle>

ffffffffc02000b2 <strdup>:
ffffffffc02000b2:	1101                	addi	sp,sp,-32
ffffffffc02000b4:	ec06                	sd	ra,24(sp)
ffffffffc02000b6:	e822                	sd	s0,16(sp)
ffffffffc02000b8:	e426                	sd	s1,8(sp)
ffffffffc02000ba:	e04a                	sd	s2,0(sp)
ffffffffc02000bc:	892a                	mv	s2,a0
ffffffffc02000be:	7d30a0ef          	jal	ra,ffffffffc020b090 <strlen>
ffffffffc02000c2:	842a                	mv	s0,a0
ffffffffc02000c4:	0505                	addi	a0,a0,1
ffffffffc02000c6:	6fc030ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc02000ca:	84aa                	mv	s1,a0
ffffffffc02000cc:	c901                	beqz	a0,ffffffffc02000dc <strdup+0x2a>
ffffffffc02000ce:	8622                	mv	a2,s0
ffffffffc02000d0:	85ca                	mv	a1,s2
ffffffffc02000d2:	9426                	add	s0,s0,s1
ffffffffc02000d4:	0b00b0ef          	jal	ra,ffffffffc020b184 <memcpy>
ffffffffc02000d8:	00040023          	sb	zero,0(s0)
ffffffffc02000dc:	60e2                	ld	ra,24(sp)
ffffffffc02000de:	6442                	ld	s0,16(sp)
ffffffffc02000e0:	6902                	ld	s2,0(sp)
ffffffffc02000e2:	8526                	mv	a0,s1
ffffffffc02000e4:	64a2                	ld	s1,8(sp)
ffffffffc02000e6:	6105                	addi	sp,sp,32
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputch>:
ffffffffc02000ea:	1141                	addi	sp,sp,-16
ffffffffc02000ec:	e022                	sd	s0,0(sp)
ffffffffc02000ee:	e406                	sd	ra,8(sp)
ffffffffc02000f0:	842e                	mv	s0,a1
ffffffffc02000f2:	18b000ef          	jal	ra,ffffffffc0200a7c <cons_putc>
ffffffffc02000f6:	401c                	lw	a5,0(s0)
ffffffffc02000f8:	60a2                	ld	ra,8(sp)
ffffffffc02000fa:	2785                	addiw	a5,a5,1
ffffffffc02000fc:	c01c                	sw	a5,0(s0)
ffffffffc02000fe:	6402                	ld	s0,0(sp)
ffffffffc0200100:	0141                	addi	sp,sp,16
ffffffffc0200102:	8082                	ret

ffffffffc0200104 <vcprintf>:
ffffffffc0200104:	1101                	addi	sp,sp,-32
ffffffffc0200106:	872e                	mv	a4,a1
ffffffffc0200108:	75dd                	lui	a1,0xffff7
ffffffffc020010a:	86aa                	mv	a3,a0
ffffffffc020010c:	0070                	addi	a2,sp,12
ffffffffc020010e:	00000517          	auipc	a0,0x0
ffffffffc0200112:	fdc50513          	addi	a0,a0,-36 # ffffffffc02000ea <cputch>
ffffffffc0200116:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <end+0x3fd601c9>
ffffffffc020011a:	ec06                	sd	ra,24(sp)
ffffffffc020011c:	c602                	sw	zero,12(sp)
ffffffffc020011e:	10e0b0ef          	jal	ra,ffffffffc020b22c <vprintfmt>
ffffffffc0200122:	60e2                	ld	ra,24(sp)
ffffffffc0200124:	4532                	lw	a0,12(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret

ffffffffc020012a <cprintf>:
ffffffffc020012a:	711d                	addi	sp,sp,-96
ffffffffc020012c:	02810313          	addi	t1,sp,40 # ffffffffc0213028 <boot_page_table_sv39+0x28>
ffffffffc0200130:	8e2a                	mv	t3,a0
ffffffffc0200132:	f42e                	sd	a1,40(sp)
ffffffffc0200134:	75dd                	lui	a1,0xffff7
ffffffffc0200136:	f832                	sd	a2,48(sp)
ffffffffc0200138:	fc36                	sd	a3,56(sp)
ffffffffc020013a:	e0ba                	sd	a4,64(sp)
ffffffffc020013c:	00000517          	auipc	a0,0x0
ffffffffc0200140:	fae50513          	addi	a0,a0,-82 # ffffffffc02000ea <cputch>
ffffffffc0200144:	0050                	addi	a2,sp,4
ffffffffc0200146:	871a                	mv	a4,t1
ffffffffc0200148:	86f2                	mv	a3,t3
ffffffffc020014a:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <end+0x3fd601c9>
ffffffffc020014e:	ec06                	sd	ra,24(sp)
ffffffffc0200150:	e4be                	sd	a5,72(sp)
ffffffffc0200152:	e8c2                	sd	a6,80(sp)
ffffffffc0200154:	ecc6                	sd	a7,88(sp)
ffffffffc0200156:	e41a                	sd	t1,8(sp)
ffffffffc0200158:	c202                	sw	zero,4(sp)
ffffffffc020015a:	0d20b0ef          	jal	ra,ffffffffc020b22c <vprintfmt>
ffffffffc020015e:	60e2                	ld	ra,24(sp)
ffffffffc0200160:	4512                	lw	a0,4(sp)
ffffffffc0200162:	6125                	addi	sp,sp,96
ffffffffc0200164:	8082                	ret

ffffffffc0200166 <cputchar>:
ffffffffc0200166:	1170006f          	j	ffffffffc0200a7c <cons_putc>

ffffffffc020016a <getchar>:
ffffffffc020016a:	1141                	addi	sp,sp,-16
ffffffffc020016c:	e406                	sd	ra,8(sp)
ffffffffc020016e:	163000ef          	jal	ra,ffffffffc0200ad0 <cons_getc>
ffffffffc0200172:	dd75                	beqz	a0,ffffffffc020016e <getchar+0x4>
ffffffffc0200174:	60a2                	ld	ra,8(sp)
ffffffffc0200176:	0141                	addi	sp,sp,16
ffffffffc0200178:	8082                	ret

ffffffffc020017a <readline>:
ffffffffc020017a:	715d                	addi	sp,sp,-80
ffffffffc020017c:	e486                	sd	ra,72(sp)
ffffffffc020017e:	e0a6                	sd	s1,64(sp)
ffffffffc0200180:	fc4a                	sd	s2,56(sp)
ffffffffc0200182:	f84e                	sd	s3,48(sp)
ffffffffc0200184:	f452                	sd	s4,40(sp)
ffffffffc0200186:	f056                	sd	s5,32(sp)
ffffffffc0200188:	ec5a                	sd	s6,24(sp)
ffffffffc020018a:	e85e                	sd	s7,16(sp)
ffffffffc020018c:	c901                	beqz	a0,ffffffffc020019c <readline+0x22>
ffffffffc020018e:	85aa                	mv	a1,a0
ffffffffc0200190:	0000b517          	auipc	a0,0xb
ffffffffc0200194:	4c850513          	addi	a0,a0,1224 # ffffffffc020b658 <etext+0x2a>
ffffffffc0200198:	f93ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020019c:	4481                	li	s1,0
ffffffffc020019e:	497d                	li	s2,31
ffffffffc02001a0:	49a1                	li	s3,8
ffffffffc02001a2:	4aa9                	li	s5,10
ffffffffc02001a4:	4b35                	li	s6,13
ffffffffc02001a6:	00091b97          	auipc	s7,0x91
ffffffffc02001aa:	ebab8b93          	addi	s7,s7,-326 # ffffffffc0291060 <buf>
ffffffffc02001ae:	3fe00a13          	li	s4,1022
ffffffffc02001b2:	fb9ff0ef          	jal	ra,ffffffffc020016a <getchar>
ffffffffc02001b6:	00054a63          	bltz	a0,ffffffffc02001ca <readline+0x50>
ffffffffc02001ba:	00a95a63          	bge	s2,a0,ffffffffc02001ce <readline+0x54>
ffffffffc02001be:	029a5263          	bge	s4,s1,ffffffffc02001e2 <readline+0x68>
ffffffffc02001c2:	fa9ff0ef          	jal	ra,ffffffffc020016a <getchar>
ffffffffc02001c6:	fe055ae3          	bgez	a0,ffffffffc02001ba <readline+0x40>
ffffffffc02001ca:	4501                	li	a0,0
ffffffffc02001cc:	a091                	j	ffffffffc0200210 <readline+0x96>
ffffffffc02001ce:	03351463          	bne	a0,s3,ffffffffc02001f6 <readline+0x7c>
ffffffffc02001d2:	e8a9                	bnez	s1,ffffffffc0200224 <readline+0xaa>
ffffffffc02001d4:	f97ff0ef          	jal	ra,ffffffffc020016a <getchar>
ffffffffc02001d8:	fe0549e3          	bltz	a0,ffffffffc02001ca <readline+0x50>
ffffffffc02001dc:	fea959e3          	bge	s2,a0,ffffffffc02001ce <readline+0x54>
ffffffffc02001e0:	4481                	li	s1,0
ffffffffc02001e2:	e42a                	sd	a0,8(sp)
ffffffffc02001e4:	f83ff0ef          	jal	ra,ffffffffc0200166 <cputchar>
ffffffffc02001e8:	6522                	ld	a0,8(sp)
ffffffffc02001ea:	009b87b3          	add	a5,s7,s1
ffffffffc02001ee:	2485                	addiw	s1,s1,1
ffffffffc02001f0:	00a78023          	sb	a0,0(a5)
ffffffffc02001f4:	bf7d                	j	ffffffffc02001b2 <readline+0x38>
ffffffffc02001f6:	01550463          	beq	a0,s5,ffffffffc02001fe <readline+0x84>
ffffffffc02001fa:	fb651ce3          	bne	a0,s6,ffffffffc02001b2 <readline+0x38>
ffffffffc02001fe:	f69ff0ef          	jal	ra,ffffffffc0200166 <cputchar>
ffffffffc0200202:	00091517          	auipc	a0,0x91
ffffffffc0200206:	e5e50513          	addi	a0,a0,-418 # ffffffffc0291060 <buf>
ffffffffc020020a:	94aa                	add	s1,s1,a0
ffffffffc020020c:	00048023          	sb	zero,0(s1)
ffffffffc0200210:	60a6                	ld	ra,72(sp)
ffffffffc0200212:	6486                	ld	s1,64(sp)
ffffffffc0200214:	7962                	ld	s2,56(sp)
ffffffffc0200216:	79c2                	ld	s3,48(sp)
ffffffffc0200218:	7a22                	ld	s4,40(sp)
ffffffffc020021a:	7a82                	ld	s5,32(sp)
ffffffffc020021c:	6b62                	ld	s6,24(sp)
ffffffffc020021e:	6bc2                	ld	s7,16(sp)
ffffffffc0200220:	6161                	addi	sp,sp,80
ffffffffc0200222:	8082                	ret
ffffffffc0200224:	4521                	li	a0,8
ffffffffc0200226:	f41ff0ef          	jal	ra,ffffffffc0200166 <cputchar>
ffffffffc020022a:	34fd                	addiw	s1,s1,-1
ffffffffc020022c:	b759                	j	ffffffffc02001b2 <readline+0x38>

ffffffffc020022e <__panic>:
ffffffffc020022e:	00096317          	auipc	t1,0x96
ffffffffc0200232:	63a30313          	addi	t1,t1,1594 # ffffffffc0296868 <is_panic>
ffffffffc0200236:	00033e03          	ld	t3,0(t1)
ffffffffc020023a:	715d                	addi	sp,sp,-80
ffffffffc020023c:	ec06                	sd	ra,24(sp)
ffffffffc020023e:	e822                	sd	s0,16(sp)
ffffffffc0200240:	f436                	sd	a3,40(sp)
ffffffffc0200242:	f83a                	sd	a4,48(sp)
ffffffffc0200244:	fc3e                	sd	a5,56(sp)
ffffffffc0200246:	e0c2                	sd	a6,64(sp)
ffffffffc0200248:	e4c6                	sd	a7,72(sp)
ffffffffc020024a:	020e1a63          	bnez	t3,ffffffffc020027e <__panic+0x50>
ffffffffc020024e:	4785                	li	a5,1
ffffffffc0200250:	00f33023          	sd	a5,0(t1)
ffffffffc0200254:	8432                	mv	s0,a2
ffffffffc0200256:	103c                	addi	a5,sp,40
ffffffffc0200258:	862e                	mv	a2,a1
ffffffffc020025a:	85aa                	mv	a1,a0
ffffffffc020025c:	0000b517          	auipc	a0,0xb
ffffffffc0200260:	40450513          	addi	a0,a0,1028 # ffffffffc020b660 <etext+0x32>
ffffffffc0200264:	e43e                	sd	a5,8(sp)
ffffffffc0200266:	ec5ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020026a:	65a2                	ld	a1,8(sp)
ffffffffc020026c:	8522                	mv	a0,s0
ffffffffc020026e:	e97ff0ef          	jal	ra,ffffffffc0200104 <vcprintf>
ffffffffc0200272:	0000c517          	auipc	a0,0xc
ffffffffc0200276:	4de50513          	addi	a0,a0,1246 # ffffffffc020c750 <commands+0xe78>
ffffffffc020027a:	eb1ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020027e:	4501                	li	a0,0
ffffffffc0200280:	4581                	li	a1,0
ffffffffc0200282:	4601                	li	a2,0
ffffffffc0200284:	48a1                	li	a7,8
ffffffffc0200286:	00000073          	ecall
ffffffffc020028a:	317000ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc020028e:	4501                	li	a0,0
ffffffffc0200290:	174000ef          	jal	ra,ffffffffc0200404 <kmonitor>
ffffffffc0200294:	bfed                	j	ffffffffc020028e <__panic+0x60>

ffffffffc0200296 <__warn>:
ffffffffc0200296:	715d                	addi	sp,sp,-80
ffffffffc0200298:	832e                	mv	t1,a1
ffffffffc020029a:	e822                	sd	s0,16(sp)
ffffffffc020029c:	85aa                	mv	a1,a0
ffffffffc020029e:	8432                	mv	s0,a2
ffffffffc02002a0:	fc3e                	sd	a5,56(sp)
ffffffffc02002a2:	861a                	mv	a2,t1
ffffffffc02002a4:	103c                	addi	a5,sp,40
ffffffffc02002a6:	0000b517          	auipc	a0,0xb
ffffffffc02002aa:	3da50513          	addi	a0,a0,986 # ffffffffc020b680 <etext+0x52>
ffffffffc02002ae:	ec06                	sd	ra,24(sp)
ffffffffc02002b0:	f436                	sd	a3,40(sp)
ffffffffc02002b2:	f83a                	sd	a4,48(sp)
ffffffffc02002b4:	e0c2                	sd	a6,64(sp)
ffffffffc02002b6:	e4c6                	sd	a7,72(sp)
ffffffffc02002b8:	e43e                	sd	a5,8(sp)
ffffffffc02002ba:	e71ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02002be:	65a2                	ld	a1,8(sp)
ffffffffc02002c0:	8522                	mv	a0,s0
ffffffffc02002c2:	e43ff0ef          	jal	ra,ffffffffc0200104 <vcprintf>
ffffffffc02002c6:	0000c517          	auipc	a0,0xc
ffffffffc02002ca:	48a50513          	addi	a0,a0,1162 # ffffffffc020c750 <commands+0xe78>
ffffffffc02002ce:	e5dff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02002d2:	60e2                	ld	ra,24(sp)
ffffffffc02002d4:	6442                	ld	s0,16(sp)
ffffffffc02002d6:	6161                	addi	sp,sp,80
ffffffffc02002d8:	8082                	ret

ffffffffc02002da <print_kerninfo>:
ffffffffc02002da:	1141                	addi	sp,sp,-16
ffffffffc02002dc:	0000b517          	auipc	a0,0xb
ffffffffc02002e0:	3c450513          	addi	a0,a0,964 # ffffffffc020b6a0 <etext+0x72>
ffffffffc02002e4:	e406                	sd	ra,8(sp)
ffffffffc02002e6:	e45ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02002ea:	00000597          	auipc	a1,0x0
ffffffffc02002ee:	d6058593          	addi	a1,a1,-672 # ffffffffc020004a <kern_init>
ffffffffc02002f2:	0000b517          	auipc	a0,0xb
ffffffffc02002f6:	3ce50513          	addi	a0,a0,974 # ffffffffc020b6c0 <etext+0x92>
ffffffffc02002fa:	e31ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02002fe:	0000b597          	auipc	a1,0xb
ffffffffc0200302:	33058593          	addi	a1,a1,816 # ffffffffc020b62e <etext>
ffffffffc0200306:	0000b517          	auipc	a0,0xb
ffffffffc020030a:	3da50513          	addi	a0,a0,986 # ffffffffc020b6e0 <etext+0xb2>
ffffffffc020030e:	e1dff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200312:	00091597          	auipc	a1,0x91
ffffffffc0200316:	d4e58593          	addi	a1,a1,-690 # ffffffffc0291060 <buf>
ffffffffc020031a:	0000b517          	auipc	a0,0xb
ffffffffc020031e:	3e650513          	addi	a0,a0,998 # ffffffffc020b700 <etext+0xd2>
ffffffffc0200322:	e09ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200326:	00096597          	auipc	a1,0x96
ffffffffc020032a:	5ea58593          	addi	a1,a1,1514 # ffffffffc0296910 <end>
ffffffffc020032e:	0000b517          	auipc	a0,0xb
ffffffffc0200332:	3f250513          	addi	a0,a0,1010 # ffffffffc020b720 <etext+0xf2>
ffffffffc0200336:	df5ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020033a:	00097597          	auipc	a1,0x97
ffffffffc020033e:	9d558593          	addi	a1,a1,-1579 # ffffffffc0296d0f <end+0x3ff>
ffffffffc0200342:	00000797          	auipc	a5,0x0
ffffffffc0200346:	d0878793          	addi	a5,a5,-760 # ffffffffc020004a <kern_init>
ffffffffc020034a:	40f587b3          	sub	a5,a1,a5
ffffffffc020034e:	43f7d593          	srai	a1,a5,0x3f
ffffffffc0200352:	60a2                	ld	ra,8(sp)
ffffffffc0200354:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200358:	95be                	add	a1,a1,a5
ffffffffc020035a:	85a9                	srai	a1,a1,0xa
ffffffffc020035c:	0000b517          	auipc	a0,0xb
ffffffffc0200360:	3e450513          	addi	a0,a0,996 # ffffffffc020b740 <etext+0x112>
ffffffffc0200364:	0141                	addi	sp,sp,16
ffffffffc0200366:	b3d1                	j	ffffffffc020012a <cprintf>

ffffffffc0200368 <print_stackframe>:
ffffffffc0200368:	1141                	addi	sp,sp,-16
ffffffffc020036a:	0000b617          	auipc	a2,0xb
ffffffffc020036e:	40660613          	addi	a2,a2,1030 # ffffffffc020b770 <etext+0x142>
ffffffffc0200372:	04e00593          	li	a1,78
ffffffffc0200376:	0000b517          	auipc	a0,0xb
ffffffffc020037a:	41250513          	addi	a0,a0,1042 # ffffffffc020b788 <etext+0x15a>
ffffffffc020037e:	e406                	sd	ra,8(sp)
ffffffffc0200380:	eafff0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0200384 <mon_help>:
ffffffffc0200384:	1141                	addi	sp,sp,-16
ffffffffc0200386:	0000b617          	auipc	a2,0xb
ffffffffc020038a:	41a60613          	addi	a2,a2,1050 # ffffffffc020b7a0 <etext+0x172>
ffffffffc020038e:	0000b597          	auipc	a1,0xb
ffffffffc0200392:	43258593          	addi	a1,a1,1074 # ffffffffc020b7c0 <etext+0x192>
ffffffffc0200396:	0000b517          	auipc	a0,0xb
ffffffffc020039a:	43250513          	addi	a0,a0,1074 # ffffffffc020b7c8 <etext+0x19a>
ffffffffc020039e:	e406                	sd	ra,8(sp)
ffffffffc02003a0:	d8bff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02003a4:	0000b617          	auipc	a2,0xb
ffffffffc02003a8:	43460613          	addi	a2,a2,1076 # ffffffffc020b7d8 <etext+0x1aa>
ffffffffc02003ac:	0000b597          	auipc	a1,0xb
ffffffffc02003b0:	45458593          	addi	a1,a1,1108 # ffffffffc020b800 <etext+0x1d2>
ffffffffc02003b4:	0000b517          	auipc	a0,0xb
ffffffffc02003b8:	41450513          	addi	a0,a0,1044 # ffffffffc020b7c8 <etext+0x19a>
ffffffffc02003bc:	d6fff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02003c0:	0000b617          	auipc	a2,0xb
ffffffffc02003c4:	45060613          	addi	a2,a2,1104 # ffffffffc020b810 <etext+0x1e2>
ffffffffc02003c8:	0000b597          	auipc	a1,0xb
ffffffffc02003cc:	46858593          	addi	a1,a1,1128 # ffffffffc020b830 <etext+0x202>
ffffffffc02003d0:	0000b517          	auipc	a0,0xb
ffffffffc02003d4:	3f850513          	addi	a0,a0,1016 # ffffffffc020b7c8 <etext+0x19a>
ffffffffc02003d8:	d53ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02003dc:	60a2                	ld	ra,8(sp)
ffffffffc02003de:	4501                	li	a0,0
ffffffffc02003e0:	0141                	addi	sp,sp,16
ffffffffc02003e2:	8082                	ret

ffffffffc02003e4 <mon_kerninfo>:
ffffffffc02003e4:	1141                	addi	sp,sp,-16
ffffffffc02003e6:	e406                	sd	ra,8(sp)
ffffffffc02003e8:	ef3ff0ef          	jal	ra,ffffffffc02002da <print_kerninfo>
ffffffffc02003ec:	60a2                	ld	ra,8(sp)
ffffffffc02003ee:	4501                	li	a0,0
ffffffffc02003f0:	0141                	addi	sp,sp,16
ffffffffc02003f2:	8082                	ret

ffffffffc02003f4 <mon_backtrace>:
ffffffffc02003f4:	1141                	addi	sp,sp,-16
ffffffffc02003f6:	e406                	sd	ra,8(sp)
ffffffffc02003f8:	f71ff0ef          	jal	ra,ffffffffc0200368 <print_stackframe>
ffffffffc02003fc:	60a2                	ld	ra,8(sp)
ffffffffc02003fe:	4501                	li	a0,0
ffffffffc0200400:	0141                	addi	sp,sp,16
ffffffffc0200402:	8082                	ret

ffffffffc0200404 <kmonitor>:
ffffffffc0200404:	7115                	addi	sp,sp,-224
ffffffffc0200406:	ed5e                	sd	s7,152(sp)
ffffffffc0200408:	8baa                	mv	s7,a0
ffffffffc020040a:	0000b517          	auipc	a0,0xb
ffffffffc020040e:	43650513          	addi	a0,a0,1078 # ffffffffc020b840 <etext+0x212>
ffffffffc0200412:	ed86                	sd	ra,216(sp)
ffffffffc0200414:	e9a2                	sd	s0,208(sp)
ffffffffc0200416:	e5a6                	sd	s1,200(sp)
ffffffffc0200418:	e1ca                	sd	s2,192(sp)
ffffffffc020041a:	fd4e                	sd	s3,184(sp)
ffffffffc020041c:	f952                	sd	s4,176(sp)
ffffffffc020041e:	f556                	sd	s5,168(sp)
ffffffffc0200420:	f15a                	sd	s6,160(sp)
ffffffffc0200422:	e962                	sd	s8,144(sp)
ffffffffc0200424:	e566                	sd	s9,136(sp)
ffffffffc0200426:	e16a                	sd	s10,128(sp)
ffffffffc0200428:	d03ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020042c:	0000b517          	auipc	a0,0xb
ffffffffc0200430:	43c50513          	addi	a0,a0,1084 # ffffffffc020b868 <etext+0x23a>
ffffffffc0200434:	cf7ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200438:	000b8563          	beqz	s7,ffffffffc0200442 <kmonitor+0x3e>
ffffffffc020043c:	855e                	mv	a0,s7
ffffffffc020043e:	351000ef          	jal	ra,ffffffffc0200f8e <print_trapframe>
ffffffffc0200442:	0000bc17          	auipc	s8,0xb
ffffffffc0200446:	496c0c13          	addi	s8,s8,1174 # ffffffffc020b8d8 <commands>
ffffffffc020044a:	0000b917          	auipc	s2,0xb
ffffffffc020044e:	44690913          	addi	s2,s2,1094 # ffffffffc020b890 <etext+0x262>
ffffffffc0200452:	0000b497          	auipc	s1,0xb
ffffffffc0200456:	44648493          	addi	s1,s1,1094 # ffffffffc020b898 <etext+0x26a>
ffffffffc020045a:	49bd                	li	s3,15
ffffffffc020045c:	0000bb17          	auipc	s6,0xb
ffffffffc0200460:	444b0b13          	addi	s6,s6,1092 # ffffffffc020b8a0 <etext+0x272>
ffffffffc0200464:	0000ba17          	auipc	s4,0xb
ffffffffc0200468:	35ca0a13          	addi	s4,s4,860 # ffffffffc020b7c0 <etext+0x192>
ffffffffc020046c:	4a8d                	li	s5,3
ffffffffc020046e:	854a                	mv	a0,s2
ffffffffc0200470:	d0bff0ef          	jal	ra,ffffffffc020017a <readline>
ffffffffc0200474:	842a                	mv	s0,a0
ffffffffc0200476:	dd65                	beqz	a0,ffffffffc020046e <kmonitor+0x6a>
ffffffffc0200478:	00054583          	lbu	a1,0(a0)
ffffffffc020047c:	4c81                	li	s9,0
ffffffffc020047e:	e1bd                	bnez	a1,ffffffffc02004e4 <kmonitor+0xe0>
ffffffffc0200480:	fe0c87e3          	beqz	s9,ffffffffc020046e <kmonitor+0x6a>
ffffffffc0200484:	6582                	ld	a1,0(sp)
ffffffffc0200486:	0000bd17          	auipc	s10,0xb
ffffffffc020048a:	452d0d13          	addi	s10,s10,1106 # ffffffffc020b8d8 <commands>
ffffffffc020048e:	8552                	mv	a0,s4
ffffffffc0200490:	4401                	li	s0,0
ffffffffc0200492:	0d61                	addi	s10,s10,24
ffffffffc0200494:	4450a0ef          	jal	ra,ffffffffc020b0d8 <strcmp>
ffffffffc0200498:	c919                	beqz	a0,ffffffffc02004ae <kmonitor+0xaa>
ffffffffc020049a:	2405                	addiw	s0,s0,1
ffffffffc020049c:	0b540063          	beq	s0,s5,ffffffffc020053c <kmonitor+0x138>
ffffffffc02004a0:	000d3503          	ld	a0,0(s10)
ffffffffc02004a4:	6582                	ld	a1,0(sp)
ffffffffc02004a6:	0d61                	addi	s10,s10,24
ffffffffc02004a8:	4310a0ef          	jal	ra,ffffffffc020b0d8 <strcmp>
ffffffffc02004ac:	f57d                	bnez	a0,ffffffffc020049a <kmonitor+0x96>
ffffffffc02004ae:	00141793          	slli	a5,s0,0x1
ffffffffc02004b2:	97a2                	add	a5,a5,s0
ffffffffc02004b4:	078e                	slli	a5,a5,0x3
ffffffffc02004b6:	97e2                	add	a5,a5,s8
ffffffffc02004b8:	6b9c                	ld	a5,16(a5)
ffffffffc02004ba:	865e                	mv	a2,s7
ffffffffc02004bc:	002c                	addi	a1,sp,8
ffffffffc02004be:	fffc851b          	addiw	a0,s9,-1
ffffffffc02004c2:	9782                	jalr	a5
ffffffffc02004c4:	fa0555e3          	bgez	a0,ffffffffc020046e <kmonitor+0x6a>
ffffffffc02004c8:	60ee                	ld	ra,216(sp)
ffffffffc02004ca:	644e                	ld	s0,208(sp)
ffffffffc02004cc:	64ae                	ld	s1,200(sp)
ffffffffc02004ce:	690e                	ld	s2,192(sp)
ffffffffc02004d0:	79ea                	ld	s3,184(sp)
ffffffffc02004d2:	7a4a                	ld	s4,176(sp)
ffffffffc02004d4:	7aaa                	ld	s5,168(sp)
ffffffffc02004d6:	7b0a                	ld	s6,160(sp)
ffffffffc02004d8:	6bea                	ld	s7,152(sp)
ffffffffc02004da:	6c4a                	ld	s8,144(sp)
ffffffffc02004dc:	6caa                	ld	s9,136(sp)
ffffffffc02004de:	6d0a                	ld	s10,128(sp)
ffffffffc02004e0:	612d                	addi	sp,sp,224
ffffffffc02004e2:	8082                	ret
ffffffffc02004e4:	8526                	mv	a0,s1
ffffffffc02004e6:	4370a0ef          	jal	ra,ffffffffc020b11c <strchr>
ffffffffc02004ea:	c901                	beqz	a0,ffffffffc02004fa <kmonitor+0xf6>
ffffffffc02004ec:	00144583          	lbu	a1,1(s0)
ffffffffc02004f0:	00040023          	sb	zero,0(s0)
ffffffffc02004f4:	0405                	addi	s0,s0,1
ffffffffc02004f6:	d5c9                	beqz	a1,ffffffffc0200480 <kmonitor+0x7c>
ffffffffc02004f8:	b7f5                	j	ffffffffc02004e4 <kmonitor+0xe0>
ffffffffc02004fa:	00044783          	lbu	a5,0(s0)
ffffffffc02004fe:	d3c9                	beqz	a5,ffffffffc0200480 <kmonitor+0x7c>
ffffffffc0200500:	033c8963          	beq	s9,s3,ffffffffc0200532 <kmonitor+0x12e>
ffffffffc0200504:	003c9793          	slli	a5,s9,0x3
ffffffffc0200508:	0118                	addi	a4,sp,128
ffffffffc020050a:	97ba                	add	a5,a5,a4
ffffffffc020050c:	f887b023          	sd	s0,-128(a5)
ffffffffc0200510:	00044583          	lbu	a1,0(s0)
ffffffffc0200514:	2c85                	addiw	s9,s9,1
ffffffffc0200516:	e591                	bnez	a1,ffffffffc0200522 <kmonitor+0x11e>
ffffffffc0200518:	b7b5                	j	ffffffffc0200484 <kmonitor+0x80>
ffffffffc020051a:	00144583          	lbu	a1,1(s0)
ffffffffc020051e:	0405                	addi	s0,s0,1
ffffffffc0200520:	d1a5                	beqz	a1,ffffffffc0200480 <kmonitor+0x7c>
ffffffffc0200522:	8526                	mv	a0,s1
ffffffffc0200524:	3f90a0ef          	jal	ra,ffffffffc020b11c <strchr>
ffffffffc0200528:	d96d                	beqz	a0,ffffffffc020051a <kmonitor+0x116>
ffffffffc020052a:	00044583          	lbu	a1,0(s0)
ffffffffc020052e:	d9a9                	beqz	a1,ffffffffc0200480 <kmonitor+0x7c>
ffffffffc0200530:	bf55                	j	ffffffffc02004e4 <kmonitor+0xe0>
ffffffffc0200532:	45c1                	li	a1,16
ffffffffc0200534:	855a                	mv	a0,s6
ffffffffc0200536:	bf5ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020053a:	b7e9                	j	ffffffffc0200504 <kmonitor+0x100>
ffffffffc020053c:	6582                	ld	a1,0(sp)
ffffffffc020053e:	0000b517          	auipc	a0,0xb
ffffffffc0200542:	38250513          	addi	a0,a0,898 # ffffffffc020b8c0 <etext+0x292>
ffffffffc0200546:	be5ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020054a:	b715                	j	ffffffffc020046e <kmonitor+0x6a>

ffffffffc020054c <dtb_init>:
ffffffffc020054c:	7119                	addi	sp,sp,-128
ffffffffc020054e:	0000b517          	auipc	a0,0xb
ffffffffc0200552:	3d250513          	addi	a0,a0,978 # ffffffffc020b920 <commands+0x48>
ffffffffc0200556:	fc86                	sd	ra,120(sp)
ffffffffc0200558:	f8a2                	sd	s0,112(sp)
ffffffffc020055a:	e8d2                	sd	s4,80(sp)
ffffffffc020055c:	f4a6                	sd	s1,104(sp)
ffffffffc020055e:	f0ca                	sd	s2,96(sp)
ffffffffc0200560:	ecce                	sd	s3,88(sp)
ffffffffc0200562:	e4d6                	sd	s5,72(sp)
ffffffffc0200564:	e0da                	sd	s6,64(sp)
ffffffffc0200566:	fc5e                	sd	s7,56(sp)
ffffffffc0200568:	f862                	sd	s8,48(sp)
ffffffffc020056a:	f466                	sd	s9,40(sp)
ffffffffc020056c:	f06a                	sd	s10,32(sp)
ffffffffc020056e:	ec6e                	sd	s11,24(sp)
ffffffffc0200570:	bbbff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200574:	00014597          	auipc	a1,0x14
ffffffffc0200578:	a8c5b583          	ld	a1,-1396(a1) # ffffffffc0214000 <boot_hartid>
ffffffffc020057c:	0000b517          	auipc	a0,0xb
ffffffffc0200580:	3b450513          	addi	a0,a0,948 # ffffffffc020b930 <commands+0x58>
ffffffffc0200584:	ba7ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200588:	00014417          	auipc	s0,0x14
ffffffffc020058c:	a8040413          	addi	s0,s0,-1408 # ffffffffc0214008 <boot_dtb>
ffffffffc0200590:	600c                	ld	a1,0(s0)
ffffffffc0200592:	0000b517          	auipc	a0,0xb
ffffffffc0200596:	3ae50513          	addi	a0,a0,942 # ffffffffc020b940 <commands+0x68>
ffffffffc020059a:	b91ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020059e:	00043a03          	ld	s4,0(s0)
ffffffffc02005a2:	0000b517          	auipc	a0,0xb
ffffffffc02005a6:	3b650513          	addi	a0,a0,950 # ffffffffc020b958 <commands+0x80>
ffffffffc02005aa:	120a0463          	beqz	s4,ffffffffc02006d2 <dtb_init+0x186>
ffffffffc02005ae:	57f5                	li	a5,-3
ffffffffc02005b0:	07fa                	slli	a5,a5,0x1e
ffffffffc02005b2:	00fa0733          	add	a4,s4,a5
ffffffffc02005b6:	431c                	lw	a5,0(a4)
ffffffffc02005b8:	00ff0637          	lui	a2,0xff0
ffffffffc02005bc:	6b41                	lui	s6,0x10
ffffffffc02005be:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02005c2:	0187969b          	slliw	a3,a5,0x18
ffffffffc02005c6:	0187d51b          	srliw	a0,a5,0x18
ffffffffc02005ca:	0105959b          	slliw	a1,a1,0x10
ffffffffc02005ce:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02005d2:	8df1                	and	a1,a1,a2
ffffffffc02005d4:	8ec9                	or	a3,a3,a0
ffffffffc02005d6:	0087979b          	slliw	a5,a5,0x8
ffffffffc02005da:	1b7d                	addi	s6,s6,-1
ffffffffc02005dc:	0167f7b3          	and	a5,a5,s6
ffffffffc02005e0:	8dd5                	or	a1,a1,a3
ffffffffc02005e2:	8ddd                	or	a1,a1,a5
ffffffffc02005e4:	d00e07b7          	lui	a5,0xd00e0
ffffffffc02005e8:	2581                	sext.w	a1,a1
ffffffffc02005ea:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfe495dd>
ffffffffc02005ee:	10f59163          	bne	a1,a5,ffffffffc02006f0 <dtb_init+0x1a4>
ffffffffc02005f2:	471c                	lw	a5,8(a4)
ffffffffc02005f4:	4754                	lw	a3,12(a4)
ffffffffc02005f6:	4c81                	li	s9,0
ffffffffc02005f8:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02005fc:	0086d51b          	srliw	a0,a3,0x8
ffffffffc0200600:	0186941b          	slliw	s0,a3,0x18
ffffffffc0200604:	0186d89b          	srliw	a7,a3,0x18
ffffffffc0200608:	01879a1b          	slliw	s4,a5,0x18
ffffffffc020060c:	0187d81b          	srliw	a6,a5,0x18
ffffffffc0200610:	0105151b          	slliw	a0,a0,0x10
ffffffffc0200614:	0106d69b          	srliw	a3,a3,0x10
ffffffffc0200618:	0105959b          	slliw	a1,a1,0x10
ffffffffc020061c:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200620:	8d71                	and	a0,a0,a2
ffffffffc0200622:	01146433          	or	s0,s0,a7
ffffffffc0200626:	0086969b          	slliw	a3,a3,0x8
ffffffffc020062a:	010a6a33          	or	s4,s4,a6
ffffffffc020062e:	8e6d                	and	a2,a2,a1
ffffffffc0200630:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200634:	8c49                	or	s0,s0,a0
ffffffffc0200636:	0166f6b3          	and	a3,a3,s6
ffffffffc020063a:	00ca6a33          	or	s4,s4,a2
ffffffffc020063e:	0167f7b3          	and	a5,a5,s6
ffffffffc0200642:	8c55                	or	s0,s0,a3
ffffffffc0200644:	00fa6a33          	or	s4,s4,a5
ffffffffc0200648:	1402                	slli	s0,s0,0x20
ffffffffc020064a:	1a02                	slli	s4,s4,0x20
ffffffffc020064c:	9001                	srli	s0,s0,0x20
ffffffffc020064e:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200652:	943a                	add	s0,s0,a4
ffffffffc0200654:	9a3a                	add	s4,s4,a4
ffffffffc0200656:	00ff0c37          	lui	s8,0xff0
ffffffffc020065a:	4b8d                	li	s7,3
ffffffffc020065c:	0000b917          	auipc	s2,0xb
ffffffffc0200660:	34c90913          	addi	s2,s2,844 # ffffffffc020b9a8 <commands+0xd0>
ffffffffc0200664:	49bd                	li	s3,15
ffffffffc0200666:	4d91                	li	s11,4
ffffffffc0200668:	4d05                	li	s10,1
ffffffffc020066a:	0000b497          	auipc	s1,0xb
ffffffffc020066e:	33648493          	addi	s1,s1,822 # ffffffffc020b9a0 <commands+0xc8>
ffffffffc0200672:	000a2703          	lw	a4,0(s4)
ffffffffc0200676:	004a0a93          	addi	s5,s4,4
ffffffffc020067a:	0087569b          	srliw	a3,a4,0x8
ffffffffc020067e:	0187179b          	slliw	a5,a4,0x18
ffffffffc0200682:	0187561b          	srliw	a2,a4,0x18
ffffffffc0200686:	0106969b          	slliw	a3,a3,0x10
ffffffffc020068a:	0107571b          	srliw	a4,a4,0x10
ffffffffc020068e:	8fd1                	or	a5,a5,a2
ffffffffc0200690:	0186f6b3          	and	a3,a3,s8
ffffffffc0200694:	0087171b          	slliw	a4,a4,0x8
ffffffffc0200698:	8fd5                	or	a5,a5,a3
ffffffffc020069a:	00eb7733          	and	a4,s6,a4
ffffffffc020069e:	8fd9                	or	a5,a5,a4
ffffffffc02006a0:	2781                	sext.w	a5,a5
ffffffffc02006a2:	09778c63          	beq	a5,s7,ffffffffc020073a <dtb_init+0x1ee>
ffffffffc02006a6:	00fbea63          	bltu	s7,a5,ffffffffc02006ba <dtb_init+0x16e>
ffffffffc02006aa:	07a78663          	beq	a5,s10,ffffffffc0200716 <dtb_init+0x1ca>
ffffffffc02006ae:	4709                	li	a4,2
ffffffffc02006b0:	00e79763          	bne	a5,a4,ffffffffc02006be <dtb_init+0x172>
ffffffffc02006b4:	4c81                	li	s9,0
ffffffffc02006b6:	8a56                	mv	s4,s5
ffffffffc02006b8:	bf6d                	j	ffffffffc0200672 <dtb_init+0x126>
ffffffffc02006ba:	ffb78ee3          	beq	a5,s11,ffffffffc02006b6 <dtb_init+0x16a>
ffffffffc02006be:	0000b517          	auipc	a0,0xb
ffffffffc02006c2:	36250513          	addi	a0,a0,866 # ffffffffc020ba20 <commands+0x148>
ffffffffc02006c6:	a65ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02006ca:	0000b517          	auipc	a0,0xb
ffffffffc02006ce:	38e50513          	addi	a0,a0,910 # ffffffffc020ba58 <commands+0x180>
ffffffffc02006d2:	7446                	ld	s0,112(sp)
ffffffffc02006d4:	70e6                	ld	ra,120(sp)
ffffffffc02006d6:	74a6                	ld	s1,104(sp)
ffffffffc02006d8:	7906                	ld	s2,96(sp)
ffffffffc02006da:	69e6                	ld	s3,88(sp)
ffffffffc02006dc:	6a46                	ld	s4,80(sp)
ffffffffc02006de:	6aa6                	ld	s5,72(sp)
ffffffffc02006e0:	6b06                	ld	s6,64(sp)
ffffffffc02006e2:	7be2                	ld	s7,56(sp)
ffffffffc02006e4:	7c42                	ld	s8,48(sp)
ffffffffc02006e6:	7ca2                	ld	s9,40(sp)
ffffffffc02006e8:	7d02                	ld	s10,32(sp)
ffffffffc02006ea:	6de2                	ld	s11,24(sp)
ffffffffc02006ec:	6109                	addi	sp,sp,128
ffffffffc02006ee:	bc35                	j	ffffffffc020012a <cprintf>
ffffffffc02006f0:	7446                	ld	s0,112(sp)
ffffffffc02006f2:	70e6                	ld	ra,120(sp)
ffffffffc02006f4:	74a6                	ld	s1,104(sp)
ffffffffc02006f6:	7906                	ld	s2,96(sp)
ffffffffc02006f8:	69e6                	ld	s3,88(sp)
ffffffffc02006fa:	6a46                	ld	s4,80(sp)
ffffffffc02006fc:	6aa6                	ld	s5,72(sp)
ffffffffc02006fe:	6b06                	ld	s6,64(sp)
ffffffffc0200700:	7be2                	ld	s7,56(sp)
ffffffffc0200702:	7c42                	ld	s8,48(sp)
ffffffffc0200704:	7ca2                	ld	s9,40(sp)
ffffffffc0200706:	7d02                	ld	s10,32(sp)
ffffffffc0200708:	6de2                	ld	s11,24(sp)
ffffffffc020070a:	0000b517          	auipc	a0,0xb
ffffffffc020070e:	26e50513          	addi	a0,a0,622 # ffffffffc020b978 <commands+0xa0>
ffffffffc0200712:	6109                	addi	sp,sp,128
ffffffffc0200714:	bc19                	j	ffffffffc020012a <cprintf>
ffffffffc0200716:	8556                	mv	a0,s5
ffffffffc0200718:	1790a0ef          	jal	ra,ffffffffc020b090 <strlen>
ffffffffc020071c:	8a2a                	mv	s4,a0
ffffffffc020071e:	4619                	li	a2,6
ffffffffc0200720:	85a6                	mv	a1,s1
ffffffffc0200722:	8556                	mv	a0,s5
ffffffffc0200724:	2a01                	sext.w	s4,s4
ffffffffc0200726:	1d10a0ef          	jal	ra,ffffffffc020b0f6 <strncmp>
ffffffffc020072a:	e111                	bnez	a0,ffffffffc020072e <dtb_init+0x1e2>
ffffffffc020072c:	4c85                	li	s9,1
ffffffffc020072e:	0a91                	addi	s5,s5,4
ffffffffc0200730:	9ad2                	add	s5,s5,s4
ffffffffc0200732:	ffcafa93          	andi	s5,s5,-4
ffffffffc0200736:	8a56                	mv	s4,s5
ffffffffc0200738:	bf2d                	j	ffffffffc0200672 <dtb_init+0x126>
ffffffffc020073a:	004a2783          	lw	a5,4(s4)
ffffffffc020073e:	00ca0693          	addi	a3,s4,12
ffffffffc0200742:	0087d71b          	srliw	a4,a5,0x8
ffffffffc0200746:	01879a9b          	slliw	s5,a5,0x18
ffffffffc020074a:	0187d61b          	srliw	a2,a5,0x18
ffffffffc020074e:	0107171b          	slliw	a4,a4,0x10
ffffffffc0200752:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200756:	00caeab3          	or	s5,s5,a2
ffffffffc020075a:	01877733          	and	a4,a4,s8
ffffffffc020075e:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200762:	00eaeab3          	or	s5,s5,a4
ffffffffc0200766:	00fb77b3          	and	a5,s6,a5
ffffffffc020076a:	00faeab3          	or	s5,s5,a5
ffffffffc020076e:	2a81                	sext.w	s5,s5
ffffffffc0200770:	000c9c63          	bnez	s9,ffffffffc0200788 <dtb_init+0x23c>
ffffffffc0200774:	1a82                	slli	s5,s5,0x20
ffffffffc0200776:	00368793          	addi	a5,a3,3
ffffffffc020077a:	020ada93          	srli	s5,s5,0x20
ffffffffc020077e:	9abe                	add	s5,s5,a5
ffffffffc0200780:	ffcafa93          	andi	s5,s5,-4
ffffffffc0200784:	8a56                	mv	s4,s5
ffffffffc0200786:	b5f5                	j	ffffffffc0200672 <dtb_init+0x126>
ffffffffc0200788:	008a2783          	lw	a5,8(s4)
ffffffffc020078c:	85ca                	mv	a1,s2
ffffffffc020078e:	e436                	sd	a3,8(sp)
ffffffffc0200790:	0087d51b          	srliw	a0,a5,0x8
ffffffffc0200794:	0187d61b          	srliw	a2,a5,0x18
ffffffffc0200798:	0187971b          	slliw	a4,a5,0x18
ffffffffc020079c:	0105151b          	slliw	a0,a0,0x10
ffffffffc02007a0:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02007a4:	8f51                	or	a4,a4,a2
ffffffffc02007a6:	01857533          	and	a0,a0,s8
ffffffffc02007aa:	0087979b          	slliw	a5,a5,0x8
ffffffffc02007ae:	8d59                	or	a0,a0,a4
ffffffffc02007b0:	00fb77b3          	and	a5,s6,a5
ffffffffc02007b4:	8d5d                	or	a0,a0,a5
ffffffffc02007b6:	1502                	slli	a0,a0,0x20
ffffffffc02007b8:	9101                	srli	a0,a0,0x20
ffffffffc02007ba:	9522                	add	a0,a0,s0
ffffffffc02007bc:	11d0a0ef          	jal	ra,ffffffffc020b0d8 <strcmp>
ffffffffc02007c0:	66a2                	ld	a3,8(sp)
ffffffffc02007c2:	f94d                	bnez	a0,ffffffffc0200774 <dtb_init+0x228>
ffffffffc02007c4:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200774 <dtb_init+0x228>
ffffffffc02007c8:	00ca3783          	ld	a5,12(s4)
ffffffffc02007cc:	014a3703          	ld	a4,20(s4)
ffffffffc02007d0:	0000b517          	auipc	a0,0xb
ffffffffc02007d4:	1e050513          	addi	a0,a0,480 # ffffffffc020b9b0 <commands+0xd8>
ffffffffc02007d8:	4207d613          	srai	a2,a5,0x20
ffffffffc02007dc:	0087d31b          	srliw	t1,a5,0x8
ffffffffc02007e0:	42075593          	srai	a1,a4,0x20
ffffffffc02007e4:	0187de1b          	srliw	t3,a5,0x18
ffffffffc02007e8:	0186581b          	srliw	a6,a2,0x18
ffffffffc02007ec:	0187941b          	slliw	s0,a5,0x18
ffffffffc02007f0:	0107d89b          	srliw	a7,a5,0x10
ffffffffc02007f4:	0187d693          	srli	a3,a5,0x18
ffffffffc02007f8:	01861f1b          	slliw	t5,a2,0x18
ffffffffc02007fc:	0087579b          	srliw	a5,a4,0x8
ffffffffc0200800:	0103131b          	slliw	t1,t1,0x10
ffffffffc0200804:	0106561b          	srliw	a2,a2,0x10
ffffffffc0200808:	010f6f33          	or	t5,t5,a6
ffffffffc020080c:	0187529b          	srliw	t0,a4,0x18
ffffffffc0200810:	0185df9b          	srliw	t6,a1,0x18
ffffffffc0200814:	01837333          	and	t1,t1,s8
ffffffffc0200818:	01c46433          	or	s0,s0,t3
ffffffffc020081c:	0186f6b3          	and	a3,a3,s8
ffffffffc0200820:	01859e1b          	slliw	t3,a1,0x18
ffffffffc0200824:	01871e9b          	slliw	t4,a4,0x18
ffffffffc0200828:	0107581b          	srliw	a6,a4,0x10
ffffffffc020082c:	0086161b          	slliw	a2,a2,0x8
ffffffffc0200830:	8361                	srli	a4,a4,0x18
ffffffffc0200832:	0107979b          	slliw	a5,a5,0x10
ffffffffc0200836:	0105d59b          	srliw	a1,a1,0x10
ffffffffc020083a:	01e6e6b3          	or	a3,a3,t5
ffffffffc020083e:	00cb7633          	and	a2,s6,a2
ffffffffc0200842:	0088181b          	slliw	a6,a6,0x8
ffffffffc0200846:	0085959b          	slliw	a1,a1,0x8
ffffffffc020084a:	00646433          	or	s0,s0,t1
ffffffffc020084e:	0187f7b3          	and	a5,a5,s8
ffffffffc0200852:	01fe6333          	or	t1,t3,t6
ffffffffc0200856:	01877c33          	and	s8,a4,s8
ffffffffc020085a:	0088989b          	slliw	a7,a7,0x8
ffffffffc020085e:	011b78b3          	and	a7,s6,a7
ffffffffc0200862:	005eeeb3          	or	t4,t4,t0
ffffffffc0200866:	00c6e733          	or	a4,a3,a2
ffffffffc020086a:	006c6c33          	or	s8,s8,t1
ffffffffc020086e:	010b76b3          	and	a3,s6,a6
ffffffffc0200872:	00bb7b33          	and	s6,s6,a1
ffffffffc0200876:	01d7e7b3          	or	a5,a5,t4
ffffffffc020087a:	016c6b33          	or	s6,s8,s6
ffffffffc020087e:	01146433          	or	s0,s0,a7
ffffffffc0200882:	8fd5                	or	a5,a5,a3
ffffffffc0200884:	1702                	slli	a4,a4,0x20
ffffffffc0200886:	1b02                	slli	s6,s6,0x20
ffffffffc0200888:	1782                	slli	a5,a5,0x20
ffffffffc020088a:	9301                	srli	a4,a4,0x20
ffffffffc020088c:	1402                	slli	s0,s0,0x20
ffffffffc020088e:	020b5b13          	srli	s6,s6,0x20
ffffffffc0200892:	0167eb33          	or	s6,a5,s6
ffffffffc0200896:	8c59                	or	s0,s0,a4
ffffffffc0200898:	893ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020089c:	85a2                	mv	a1,s0
ffffffffc020089e:	0000b517          	auipc	a0,0xb
ffffffffc02008a2:	13250513          	addi	a0,a0,306 # ffffffffc020b9d0 <commands+0xf8>
ffffffffc02008a6:	885ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02008aa:	014b5613          	srli	a2,s6,0x14
ffffffffc02008ae:	85da                	mv	a1,s6
ffffffffc02008b0:	0000b517          	auipc	a0,0xb
ffffffffc02008b4:	13850513          	addi	a0,a0,312 # ffffffffc020b9e8 <commands+0x110>
ffffffffc02008b8:	873ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02008bc:	008b05b3          	add	a1,s6,s0
ffffffffc02008c0:	15fd                	addi	a1,a1,-1
ffffffffc02008c2:	0000b517          	auipc	a0,0xb
ffffffffc02008c6:	14650513          	addi	a0,a0,326 # ffffffffc020ba08 <commands+0x130>
ffffffffc02008ca:	861ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02008ce:	0000b517          	auipc	a0,0xb
ffffffffc02008d2:	18a50513          	addi	a0,a0,394 # ffffffffc020ba58 <commands+0x180>
ffffffffc02008d6:	00096797          	auipc	a5,0x96
ffffffffc02008da:	f887bd23          	sd	s0,-102(a5) # ffffffffc0296870 <memory_base>
ffffffffc02008de:	00096797          	auipc	a5,0x96
ffffffffc02008e2:	f967bd23          	sd	s6,-102(a5) # ffffffffc0296878 <memory_size>
ffffffffc02008e6:	b3f5                	j	ffffffffc02006d2 <dtb_init+0x186>

ffffffffc02008e8 <get_memory_base>:
ffffffffc02008e8:	00096517          	auipc	a0,0x96
ffffffffc02008ec:	f8853503          	ld	a0,-120(a0) # ffffffffc0296870 <memory_base>
ffffffffc02008f0:	8082                	ret

ffffffffc02008f2 <get_memory_size>:
ffffffffc02008f2:	00096517          	auipc	a0,0x96
ffffffffc02008f6:	f8653503          	ld	a0,-122(a0) # ffffffffc0296878 <memory_size>
ffffffffc02008fa:	8082                	ret

ffffffffc02008fc <ramdisk_write>:
ffffffffc02008fc:	00856703          	lwu	a4,8(a0)
ffffffffc0200900:	1141                	addi	sp,sp,-16
ffffffffc0200902:	e406                	sd	ra,8(sp)
ffffffffc0200904:	8f0d                	sub	a4,a4,a1
ffffffffc0200906:	87ae                	mv	a5,a1
ffffffffc0200908:	85b2                	mv	a1,a2
ffffffffc020090a:	00e6f363          	bgeu	a3,a4,ffffffffc0200910 <ramdisk_write+0x14>
ffffffffc020090e:	8736                	mv	a4,a3
ffffffffc0200910:	6908                	ld	a0,16(a0)
ffffffffc0200912:	07a6                	slli	a5,a5,0x9
ffffffffc0200914:	00971613          	slli	a2,a4,0x9
ffffffffc0200918:	953e                	add	a0,a0,a5
ffffffffc020091a:	06b0a0ef          	jal	ra,ffffffffc020b184 <memcpy>
ffffffffc020091e:	60a2                	ld	ra,8(sp)
ffffffffc0200920:	4501                	li	a0,0
ffffffffc0200922:	0141                	addi	sp,sp,16
ffffffffc0200924:	8082                	ret

ffffffffc0200926 <ramdisk_read>:
ffffffffc0200926:	00856783          	lwu	a5,8(a0)
ffffffffc020092a:	1141                	addi	sp,sp,-16
ffffffffc020092c:	e406                	sd	ra,8(sp)
ffffffffc020092e:	8f8d                	sub	a5,a5,a1
ffffffffc0200930:	872a                	mv	a4,a0
ffffffffc0200932:	8532                	mv	a0,a2
ffffffffc0200934:	00f6f363          	bgeu	a3,a5,ffffffffc020093a <ramdisk_read+0x14>
ffffffffc0200938:	87b6                	mv	a5,a3
ffffffffc020093a:	6b18                	ld	a4,16(a4)
ffffffffc020093c:	05a6                	slli	a1,a1,0x9
ffffffffc020093e:	00979613          	slli	a2,a5,0x9
ffffffffc0200942:	95ba                	add	a1,a1,a4
ffffffffc0200944:	0410a0ef          	jal	ra,ffffffffc020b184 <memcpy>
ffffffffc0200948:	60a2                	ld	ra,8(sp)
ffffffffc020094a:	4501                	li	a0,0
ffffffffc020094c:	0141                	addi	sp,sp,16
ffffffffc020094e:	8082                	ret

ffffffffc0200950 <ramdisk_init>:
ffffffffc0200950:	1101                	addi	sp,sp,-32
ffffffffc0200952:	e822                	sd	s0,16(sp)
ffffffffc0200954:	842e                	mv	s0,a1
ffffffffc0200956:	e426                	sd	s1,8(sp)
ffffffffc0200958:	05000613          	li	a2,80
ffffffffc020095c:	84aa                	mv	s1,a0
ffffffffc020095e:	4581                	li	a1,0
ffffffffc0200960:	8522                	mv	a0,s0
ffffffffc0200962:	ec06                	sd	ra,24(sp)
ffffffffc0200964:	e04a                	sd	s2,0(sp)
ffffffffc0200966:	7cc0a0ef          	jal	ra,ffffffffc020b132 <memset>
ffffffffc020096a:	4785                	li	a5,1
ffffffffc020096c:	06f48b63          	beq	s1,a5,ffffffffc02009e2 <ramdisk_init+0x92>
ffffffffc0200970:	4789                	li	a5,2
ffffffffc0200972:	00090617          	auipc	a2,0x90
ffffffffc0200976:	69e60613          	addi	a2,a2,1694 # ffffffffc0291010 <arena>
ffffffffc020097a:	0001b917          	auipc	s2,0x1b
ffffffffc020097e:	39690913          	addi	s2,s2,918 # ffffffffc021bd10 <_binary_bin_sfs_img_start>
ffffffffc0200982:	08f49563          	bne	s1,a5,ffffffffc0200a0c <ramdisk_init+0xbc>
ffffffffc0200986:	06c90863          	beq	s2,a2,ffffffffc02009f6 <ramdisk_init+0xa6>
ffffffffc020098a:	412604b3          	sub	s1,a2,s2
ffffffffc020098e:	86a6                	mv	a3,s1
ffffffffc0200990:	85ca                	mv	a1,s2
ffffffffc0200992:	167d                	addi	a2,a2,-1
ffffffffc0200994:	0000b517          	auipc	a0,0xb
ffffffffc0200998:	0f450513          	addi	a0,a0,244 # ffffffffc020ba88 <commands+0x1b0>
ffffffffc020099c:	f8eff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02009a0:	57fd                	li	a5,-1
ffffffffc02009a2:	1782                	slli	a5,a5,0x20
ffffffffc02009a4:	0785                	addi	a5,a5,1
ffffffffc02009a6:	0094d49b          	srliw	s1,s1,0x9
ffffffffc02009aa:	e01c                	sd	a5,0(s0)
ffffffffc02009ac:	c404                	sw	s1,8(s0)
ffffffffc02009ae:	01243823          	sd	s2,16(s0)
ffffffffc02009b2:	02040513          	addi	a0,s0,32
ffffffffc02009b6:	0000b597          	auipc	a1,0xb
ffffffffc02009ba:	12a58593          	addi	a1,a1,298 # ffffffffc020bae0 <commands+0x208>
ffffffffc02009be:	7080a0ef          	jal	ra,ffffffffc020b0c6 <strcpy>
ffffffffc02009c2:	00000797          	auipc	a5,0x0
ffffffffc02009c6:	f6478793          	addi	a5,a5,-156 # ffffffffc0200926 <ramdisk_read>
ffffffffc02009ca:	e03c                	sd	a5,64(s0)
ffffffffc02009cc:	00000797          	auipc	a5,0x0
ffffffffc02009d0:	f3078793          	addi	a5,a5,-208 # ffffffffc02008fc <ramdisk_write>
ffffffffc02009d4:	60e2                	ld	ra,24(sp)
ffffffffc02009d6:	e43c                	sd	a5,72(s0)
ffffffffc02009d8:	6442                	ld	s0,16(sp)
ffffffffc02009da:	64a2                	ld	s1,8(sp)
ffffffffc02009dc:	6902                	ld	s2,0(sp)
ffffffffc02009de:	6105                	addi	sp,sp,32
ffffffffc02009e0:	8082                	ret
ffffffffc02009e2:	0001b617          	auipc	a2,0x1b
ffffffffc02009e6:	32e60613          	addi	a2,a2,814 # ffffffffc021bd10 <_binary_bin_sfs_img_start>
ffffffffc02009ea:	00013917          	auipc	s2,0x13
ffffffffc02009ee:	62690913          	addi	s2,s2,1574 # ffffffffc0214010 <_binary_bin_swap_img_start>
ffffffffc02009f2:	f8c91ce3          	bne	s2,a2,ffffffffc020098a <ramdisk_init+0x3a>
ffffffffc02009f6:	6442                	ld	s0,16(sp)
ffffffffc02009f8:	60e2                	ld	ra,24(sp)
ffffffffc02009fa:	64a2                	ld	s1,8(sp)
ffffffffc02009fc:	6902                	ld	s2,0(sp)
ffffffffc02009fe:	0000b517          	auipc	a0,0xb
ffffffffc0200a02:	07250513          	addi	a0,a0,114 # ffffffffc020ba70 <commands+0x198>
ffffffffc0200a06:	6105                	addi	sp,sp,32
ffffffffc0200a08:	f22ff06f          	j	ffffffffc020012a <cprintf>
ffffffffc0200a0c:	0000b617          	auipc	a2,0xb
ffffffffc0200a10:	0a460613          	addi	a2,a2,164 # ffffffffc020bab0 <commands+0x1d8>
ffffffffc0200a14:	03200593          	li	a1,50
ffffffffc0200a18:	0000b517          	auipc	a0,0xb
ffffffffc0200a1c:	0b050513          	addi	a0,a0,176 # ffffffffc020bac8 <commands+0x1f0>
ffffffffc0200a20:	80fff0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0200a24 <clock_init>:
ffffffffc0200a24:	02000793          	li	a5,32
ffffffffc0200a28:	1047a7f3          	csrrs	a5,sie,a5
ffffffffc0200a2c:	c0102573          	rdtime	a0
ffffffffc0200a30:	67e1                	lui	a5,0x18
ffffffffc0200a32:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_bin_swap_img_size+0x109a0>
ffffffffc0200a36:	953e                	add	a0,a0,a5
ffffffffc0200a38:	4581                	li	a1,0
ffffffffc0200a3a:	4601                	li	a2,0
ffffffffc0200a3c:	4881                	li	a7,0
ffffffffc0200a3e:	00000073          	ecall
ffffffffc0200a42:	0000b517          	auipc	a0,0xb
ffffffffc0200a46:	0ae50513          	addi	a0,a0,174 # ffffffffc020baf0 <commands+0x218>
ffffffffc0200a4a:	00096797          	auipc	a5,0x96
ffffffffc0200a4e:	e207bb23          	sd	zero,-458(a5) # ffffffffc0296880 <ticks>
ffffffffc0200a52:	ed8ff06f          	j	ffffffffc020012a <cprintf>

ffffffffc0200a56 <clock_set_next_event>:
ffffffffc0200a56:	c0102573          	rdtime	a0
ffffffffc0200a5a:	67e1                	lui	a5,0x18
ffffffffc0200a5c:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_bin_swap_img_size+0x109a0>
ffffffffc0200a60:	953e                	add	a0,a0,a5
ffffffffc0200a62:	4581                	li	a1,0
ffffffffc0200a64:	4601                	li	a2,0
ffffffffc0200a66:	4881                	li	a7,0
ffffffffc0200a68:	00000073          	ecall
ffffffffc0200a6c:	8082                	ret

ffffffffc0200a6e <cons_init>:
ffffffffc0200a6e:	4501                	li	a0,0
ffffffffc0200a70:	4581                	li	a1,0
ffffffffc0200a72:	4601                	li	a2,0
ffffffffc0200a74:	4889                	li	a7,2
ffffffffc0200a76:	00000073          	ecall
ffffffffc0200a7a:	8082                	ret

ffffffffc0200a7c <cons_putc>:
ffffffffc0200a7c:	1101                	addi	sp,sp,-32
ffffffffc0200a7e:	ec06                	sd	ra,24(sp)
ffffffffc0200a80:	100027f3          	csrr	a5,sstatus
ffffffffc0200a84:	8b89                	andi	a5,a5,2
ffffffffc0200a86:	4701                	li	a4,0
ffffffffc0200a88:	ef95                	bnez	a5,ffffffffc0200ac4 <cons_putc+0x48>
ffffffffc0200a8a:	47a1                	li	a5,8
ffffffffc0200a8c:	00f50b63          	beq	a0,a5,ffffffffc0200aa2 <cons_putc+0x26>
ffffffffc0200a90:	4581                	li	a1,0
ffffffffc0200a92:	4601                	li	a2,0
ffffffffc0200a94:	4885                	li	a7,1
ffffffffc0200a96:	00000073          	ecall
ffffffffc0200a9a:	e315                	bnez	a4,ffffffffc0200abe <cons_putc+0x42>
ffffffffc0200a9c:	60e2                	ld	ra,24(sp)
ffffffffc0200a9e:	6105                	addi	sp,sp,32
ffffffffc0200aa0:	8082                	ret
ffffffffc0200aa2:	4521                	li	a0,8
ffffffffc0200aa4:	4581                	li	a1,0
ffffffffc0200aa6:	4601                	li	a2,0
ffffffffc0200aa8:	4885                	li	a7,1
ffffffffc0200aaa:	00000073          	ecall
ffffffffc0200aae:	02000513          	li	a0,32
ffffffffc0200ab2:	00000073          	ecall
ffffffffc0200ab6:	4521                	li	a0,8
ffffffffc0200ab8:	00000073          	ecall
ffffffffc0200abc:	d365                	beqz	a4,ffffffffc0200a9c <cons_putc+0x20>
ffffffffc0200abe:	60e2                	ld	ra,24(sp)
ffffffffc0200ac0:	6105                	addi	sp,sp,32
ffffffffc0200ac2:	ace1                	j	ffffffffc0200d9a <intr_enable>
ffffffffc0200ac4:	e42a                	sd	a0,8(sp)
ffffffffc0200ac6:	2da000ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0200aca:	6522                	ld	a0,8(sp)
ffffffffc0200acc:	4705                	li	a4,1
ffffffffc0200ace:	bf75                	j	ffffffffc0200a8a <cons_putc+0xe>

ffffffffc0200ad0 <cons_getc>:
ffffffffc0200ad0:	1101                	addi	sp,sp,-32
ffffffffc0200ad2:	ec06                	sd	ra,24(sp)
ffffffffc0200ad4:	100027f3          	csrr	a5,sstatus
ffffffffc0200ad8:	8b89                	andi	a5,a5,2
ffffffffc0200ada:	4801                	li	a6,0
ffffffffc0200adc:	e3d5                	bnez	a5,ffffffffc0200b80 <cons_getc+0xb0>
ffffffffc0200ade:	00091697          	auipc	a3,0x91
ffffffffc0200ae2:	98268693          	addi	a3,a3,-1662 # ffffffffc0291460 <cons>
ffffffffc0200ae6:	07f00713          	li	a4,127
ffffffffc0200aea:	20000313          	li	t1,512
ffffffffc0200aee:	a021                	j	ffffffffc0200af6 <cons_getc+0x26>
ffffffffc0200af0:	0ff57513          	zext.b	a0,a0
ffffffffc0200af4:	ef91                	bnez	a5,ffffffffc0200b10 <cons_getc+0x40>
ffffffffc0200af6:	4501                	li	a0,0
ffffffffc0200af8:	4581                	li	a1,0
ffffffffc0200afa:	4601                	li	a2,0
ffffffffc0200afc:	4889                	li	a7,2
ffffffffc0200afe:	00000073          	ecall
ffffffffc0200b02:	0005079b          	sext.w	a5,a0
ffffffffc0200b06:	0207c763          	bltz	a5,ffffffffc0200b34 <cons_getc+0x64>
ffffffffc0200b0a:	fee793e3          	bne	a5,a4,ffffffffc0200af0 <cons_getc+0x20>
ffffffffc0200b0e:	4521                	li	a0,8
ffffffffc0200b10:	2046a783          	lw	a5,516(a3)
ffffffffc0200b14:	02079613          	slli	a2,a5,0x20
ffffffffc0200b18:	9201                	srli	a2,a2,0x20
ffffffffc0200b1a:	2785                	addiw	a5,a5,1
ffffffffc0200b1c:	9636                	add	a2,a2,a3
ffffffffc0200b1e:	20f6a223          	sw	a5,516(a3)
ffffffffc0200b22:	00a60023          	sb	a0,0(a2)
ffffffffc0200b26:	fc6798e3          	bne	a5,t1,ffffffffc0200af6 <cons_getc+0x26>
ffffffffc0200b2a:	00091797          	auipc	a5,0x91
ffffffffc0200b2e:	b207ad23          	sw	zero,-1222(a5) # ffffffffc0291664 <cons+0x204>
ffffffffc0200b32:	b7d1                	j	ffffffffc0200af6 <cons_getc+0x26>
ffffffffc0200b34:	2006a783          	lw	a5,512(a3)
ffffffffc0200b38:	2046a703          	lw	a4,516(a3)
ffffffffc0200b3c:	4501                	li	a0,0
ffffffffc0200b3e:	00f70f63          	beq	a4,a5,ffffffffc0200b5c <cons_getc+0x8c>
ffffffffc0200b42:	0017861b          	addiw	a2,a5,1
ffffffffc0200b46:	1782                	slli	a5,a5,0x20
ffffffffc0200b48:	9381                	srli	a5,a5,0x20
ffffffffc0200b4a:	97b6                	add	a5,a5,a3
ffffffffc0200b4c:	20c6a023          	sw	a2,512(a3)
ffffffffc0200b50:	20000713          	li	a4,512
ffffffffc0200b54:	0007c503          	lbu	a0,0(a5)
ffffffffc0200b58:	00e60763          	beq	a2,a4,ffffffffc0200b66 <cons_getc+0x96>
ffffffffc0200b5c:	00081b63          	bnez	a6,ffffffffc0200b72 <cons_getc+0xa2>
ffffffffc0200b60:	60e2                	ld	ra,24(sp)
ffffffffc0200b62:	6105                	addi	sp,sp,32
ffffffffc0200b64:	8082                	ret
ffffffffc0200b66:	00091797          	auipc	a5,0x91
ffffffffc0200b6a:	ae07ad23          	sw	zero,-1286(a5) # ffffffffc0291660 <cons+0x200>
ffffffffc0200b6e:	fe0809e3          	beqz	a6,ffffffffc0200b60 <cons_getc+0x90>
ffffffffc0200b72:	e42a                	sd	a0,8(sp)
ffffffffc0200b74:	226000ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0200b78:	60e2                	ld	ra,24(sp)
ffffffffc0200b7a:	6522                	ld	a0,8(sp)
ffffffffc0200b7c:	6105                	addi	sp,sp,32
ffffffffc0200b7e:	8082                	ret
ffffffffc0200b80:	220000ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0200b84:	4805                	li	a6,1
ffffffffc0200b86:	bfa1                	j	ffffffffc0200ade <cons_getc+0xe>

ffffffffc0200b88 <pic_init>:
ffffffffc0200b88:	8082                	ret

ffffffffc0200b8a <ide_init>:
ffffffffc0200b8a:	1141                	addi	sp,sp,-16
ffffffffc0200b8c:	00091597          	auipc	a1,0x91
ffffffffc0200b90:	b2c58593          	addi	a1,a1,-1236 # ffffffffc02916b8 <ide_devices+0x50>
ffffffffc0200b94:	4505                	li	a0,1
ffffffffc0200b96:	e022                	sd	s0,0(sp)
ffffffffc0200b98:	00091797          	auipc	a5,0x91
ffffffffc0200b9c:	ac07a823          	sw	zero,-1328(a5) # ffffffffc0291668 <ide_devices>
ffffffffc0200ba0:	00091797          	auipc	a5,0x91
ffffffffc0200ba4:	b007ac23          	sw	zero,-1256(a5) # ffffffffc02916b8 <ide_devices+0x50>
ffffffffc0200ba8:	00091797          	auipc	a5,0x91
ffffffffc0200bac:	b607a023          	sw	zero,-1184(a5) # ffffffffc0291708 <ide_devices+0xa0>
ffffffffc0200bb0:	00091797          	auipc	a5,0x91
ffffffffc0200bb4:	ba07a423          	sw	zero,-1112(a5) # ffffffffc0291758 <ide_devices+0xf0>
ffffffffc0200bb8:	e406                	sd	ra,8(sp)
ffffffffc0200bba:	00091417          	auipc	s0,0x91
ffffffffc0200bbe:	aae40413          	addi	s0,s0,-1362 # ffffffffc0291668 <ide_devices>
ffffffffc0200bc2:	d8fff0ef          	jal	ra,ffffffffc0200950 <ramdisk_init>
ffffffffc0200bc6:	483c                	lw	a5,80(s0)
ffffffffc0200bc8:	cf99                	beqz	a5,ffffffffc0200be6 <ide_init+0x5c>
ffffffffc0200bca:	00091597          	auipc	a1,0x91
ffffffffc0200bce:	b3e58593          	addi	a1,a1,-1218 # ffffffffc0291708 <ide_devices+0xa0>
ffffffffc0200bd2:	4509                	li	a0,2
ffffffffc0200bd4:	d7dff0ef          	jal	ra,ffffffffc0200950 <ramdisk_init>
ffffffffc0200bd8:	0a042783          	lw	a5,160(s0)
ffffffffc0200bdc:	c785                	beqz	a5,ffffffffc0200c04 <ide_init+0x7a>
ffffffffc0200bde:	60a2                	ld	ra,8(sp)
ffffffffc0200be0:	6402                	ld	s0,0(sp)
ffffffffc0200be2:	0141                	addi	sp,sp,16
ffffffffc0200be4:	8082                	ret
ffffffffc0200be6:	0000b697          	auipc	a3,0xb
ffffffffc0200bea:	f2a68693          	addi	a3,a3,-214 # ffffffffc020bb10 <commands+0x238>
ffffffffc0200bee:	0000b617          	auipc	a2,0xb
ffffffffc0200bf2:	f3a60613          	addi	a2,a2,-198 # ffffffffc020bb28 <commands+0x250>
ffffffffc0200bf6:	45c5                	li	a1,17
ffffffffc0200bf8:	0000b517          	auipc	a0,0xb
ffffffffc0200bfc:	f4850513          	addi	a0,a0,-184 # ffffffffc020bb40 <commands+0x268>
ffffffffc0200c00:	e2eff0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0200c04:	0000b697          	auipc	a3,0xb
ffffffffc0200c08:	f5468693          	addi	a3,a3,-172 # ffffffffc020bb58 <commands+0x280>
ffffffffc0200c0c:	0000b617          	auipc	a2,0xb
ffffffffc0200c10:	f1c60613          	addi	a2,a2,-228 # ffffffffc020bb28 <commands+0x250>
ffffffffc0200c14:	45d1                	li	a1,20
ffffffffc0200c16:	0000b517          	auipc	a0,0xb
ffffffffc0200c1a:	f2a50513          	addi	a0,a0,-214 # ffffffffc020bb40 <commands+0x268>
ffffffffc0200c1e:	e10ff0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0200c22 <ide_device_valid>:
ffffffffc0200c22:	478d                	li	a5,3
ffffffffc0200c24:	00a7ef63          	bltu	a5,a0,ffffffffc0200c42 <ide_device_valid+0x20>
ffffffffc0200c28:	00251793          	slli	a5,a0,0x2
ffffffffc0200c2c:	953e                	add	a0,a0,a5
ffffffffc0200c2e:	0512                	slli	a0,a0,0x4
ffffffffc0200c30:	00091797          	auipc	a5,0x91
ffffffffc0200c34:	a3878793          	addi	a5,a5,-1480 # ffffffffc0291668 <ide_devices>
ffffffffc0200c38:	953e                	add	a0,a0,a5
ffffffffc0200c3a:	4108                	lw	a0,0(a0)
ffffffffc0200c3c:	00a03533          	snez	a0,a0
ffffffffc0200c40:	8082                	ret
ffffffffc0200c42:	4501                	li	a0,0
ffffffffc0200c44:	8082                	ret

ffffffffc0200c46 <ide_device_size>:
ffffffffc0200c46:	478d                	li	a5,3
ffffffffc0200c48:	02a7e163          	bltu	a5,a0,ffffffffc0200c6a <ide_device_size+0x24>
ffffffffc0200c4c:	00251793          	slli	a5,a0,0x2
ffffffffc0200c50:	953e                	add	a0,a0,a5
ffffffffc0200c52:	0512                	slli	a0,a0,0x4
ffffffffc0200c54:	00091797          	auipc	a5,0x91
ffffffffc0200c58:	a1478793          	addi	a5,a5,-1516 # ffffffffc0291668 <ide_devices>
ffffffffc0200c5c:	97aa                	add	a5,a5,a0
ffffffffc0200c5e:	4398                	lw	a4,0(a5)
ffffffffc0200c60:	4501                	li	a0,0
ffffffffc0200c62:	c709                	beqz	a4,ffffffffc0200c6c <ide_device_size+0x26>
ffffffffc0200c64:	0087e503          	lwu	a0,8(a5)
ffffffffc0200c68:	8082                	ret
ffffffffc0200c6a:	4501                	li	a0,0
ffffffffc0200c6c:	8082                	ret

ffffffffc0200c6e <ide_read_secs>:
ffffffffc0200c6e:	1141                	addi	sp,sp,-16
ffffffffc0200c70:	e406                	sd	ra,8(sp)
ffffffffc0200c72:	08000793          	li	a5,128
ffffffffc0200c76:	04d7e763          	bltu	a5,a3,ffffffffc0200cc4 <ide_read_secs+0x56>
ffffffffc0200c7a:	478d                	li	a5,3
ffffffffc0200c7c:	0005081b          	sext.w	a6,a0
ffffffffc0200c80:	04a7e263          	bltu	a5,a0,ffffffffc0200cc4 <ide_read_secs+0x56>
ffffffffc0200c84:	00281793          	slli	a5,a6,0x2
ffffffffc0200c88:	97c2                	add	a5,a5,a6
ffffffffc0200c8a:	0792                	slli	a5,a5,0x4
ffffffffc0200c8c:	00091817          	auipc	a6,0x91
ffffffffc0200c90:	9dc80813          	addi	a6,a6,-1572 # ffffffffc0291668 <ide_devices>
ffffffffc0200c94:	97c2                	add	a5,a5,a6
ffffffffc0200c96:	0007a883          	lw	a7,0(a5)
ffffffffc0200c9a:	02088563          	beqz	a7,ffffffffc0200cc4 <ide_read_secs+0x56>
ffffffffc0200c9e:	100008b7          	lui	a7,0x10000
ffffffffc0200ca2:	0515f163          	bgeu	a1,a7,ffffffffc0200ce4 <ide_read_secs+0x76>
ffffffffc0200ca6:	1582                	slli	a1,a1,0x20
ffffffffc0200ca8:	9181                	srli	a1,a1,0x20
ffffffffc0200caa:	00d58733          	add	a4,a1,a3
ffffffffc0200cae:	02e8eb63          	bltu	a7,a4,ffffffffc0200ce4 <ide_read_secs+0x76>
ffffffffc0200cb2:	00251713          	slli	a4,a0,0x2
ffffffffc0200cb6:	60a2                	ld	ra,8(sp)
ffffffffc0200cb8:	63bc                	ld	a5,64(a5)
ffffffffc0200cba:	953a                	add	a0,a0,a4
ffffffffc0200cbc:	0512                	slli	a0,a0,0x4
ffffffffc0200cbe:	9542                	add	a0,a0,a6
ffffffffc0200cc0:	0141                	addi	sp,sp,16
ffffffffc0200cc2:	8782                	jr	a5
ffffffffc0200cc4:	0000b697          	auipc	a3,0xb
ffffffffc0200cc8:	eac68693          	addi	a3,a3,-340 # ffffffffc020bb70 <commands+0x298>
ffffffffc0200ccc:	0000b617          	auipc	a2,0xb
ffffffffc0200cd0:	e5c60613          	addi	a2,a2,-420 # ffffffffc020bb28 <commands+0x250>
ffffffffc0200cd4:	02200593          	li	a1,34
ffffffffc0200cd8:	0000b517          	auipc	a0,0xb
ffffffffc0200cdc:	e6850513          	addi	a0,a0,-408 # ffffffffc020bb40 <commands+0x268>
ffffffffc0200ce0:	d4eff0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0200ce4:	0000b697          	auipc	a3,0xb
ffffffffc0200ce8:	eb468693          	addi	a3,a3,-332 # ffffffffc020bb98 <commands+0x2c0>
ffffffffc0200cec:	0000b617          	auipc	a2,0xb
ffffffffc0200cf0:	e3c60613          	addi	a2,a2,-452 # ffffffffc020bb28 <commands+0x250>
ffffffffc0200cf4:	02300593          	li	a1,35
ffffffffc0200cf8:	0000b517          	auipc	a0,0xb
ffffffffc0200cfc:	e4850513          	addi	a0,a0,-440 # ffffffffc020bb40 <commands+0x268>
ffffffffc0200d00:	d2eff0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0200d04 <ide_write_secs>:
ffffffffc0200d04:	1141                	addi	sp,sp,-16
ffffffffc0200d06:	e406                	sd	ra,8(sp)
ffffffffc0200d08:	08000793          	li	a5,128
ffffffffc0200d0c:	04d7e763          	bltu	a5,a3,ffffffffc0200d5a <ide_write_secs+0x56>
ffffffffc0200d10:	478d                	li	a5,3
ffffffffc0200d12:	0005081b          	sext.w	a6,a0
ffffffffc0200d16:	04a7e263          	bltu	a5,a0,ffffffffc0200d5a <ide_write_secs+0x56>
ffffffffc0200d1a:	00281793          	slli	a5,a6,0x2
ffffffffc0200d1e:	97c2                	add	a5,a5,a6
ffffffffc0200d20:	0792                	slli	a5,a5,0x4
ffffffffc0200d22:	00091817          	auipc	a6,0x91
ffffffffc0200d26:	94680813          	addi	a6,a6,-1722 # ffffffffc0291668 <ide_devices>
ffffffffc0200d2a:	97c2                	add	a5,a5,a6
ffffffffc0200d2c:	0007a883          	lw	a7,0(a5)
ffffffffc0200d30:	02088563          	beqz	a7,ffffffffc0200d5a <ide_write_secs+0x56>
ffffffffc0200d34:	100008b7          	lui	a7,0x10000
ffffffffc0200d38:	0515f163          	bgeu	a1,a7,ffffffffc0200d7a <ide_write_secs+0x76>
ffffffffc0200d3c:	1582                	slli	a1,a1,0x20
ffffffffc0200d3e:	9181                	srli	a1,a1,0x20
ffffffffc0200d40:	00d58733          	add	a4,a1,a3
ffffffffc0200d44:	02e8eb63          	bltu	a7,a4,ffffffffc0200d7a <ide_write_secs+0x76>
ffffffffc0200d48:	00251713          	slli	a4,a0,0x2
ffffffffc0200d4c:	60a2                	ld	ra,8(sp)
ffffffffc0200d4e:	67bc                	ld	a5,72(a5)
ffffffffc0200d50:	953a                	add	a0,a0,a4
ffffffffc0200d52:	0512                	slli	a0,a0,0x4
ffffffffc0200d54:	9542                	add	a0,a0,a6
ffffffffc0200d56:	0141                	addi	sp,sp,16
ffffffffc0200d58:	8782                	jr	a5
ffffffffc0200d5a:	0000b697          	auipc	a3,0xb
ffffffffc0200d5e:	e1668693          	addi	a3,a3,-490 # ffffffffc020bb70 <commands+0x298>
ffffffffc0200d62:	0000b617          	auipc	a2,0xb
ffffffffc0200d66:	dc660613          	addi	a2,a2,-570 # ffffffffc020bb28 <commands+0x250>
ffffffffc0200d6a:	02900593          	li	a1,41
ffffffffc0200d6e:	0000b517          	auipc	a0,0xb
ffffffffc0200d72:	dd250513          	addi	a0,a0,-558 # ffffffffc020bb40 <commands+0x268>
ffffffffc0200d76:	cb8ff0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0200d7a:	0000b697          	auipc	a3,0xb
ffffffffc0200d7e:	e1e68693          	addi	a3,a3,-482 # ffffffffc020bb98 <commands+0x2c0>
ffffffffc0200d82:	0000b617          	auipc	a2,0xb
ffffffffc0200d86:	da660613          	addi	a2,a2,-602 # ffffffffc020bb28 <commands+0x250>
ffffffffc0200d8a:	02a00593          	li	a1,42
ffffffffc0200d8e:	0000b517          	auipc	a0,0xb
ffffffffc0200d92:	db250513          	addi	a0,a0,-590 # ffffffffc020bb40 <commands+0x268>
ffffffffc0200d96:	c98ff0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0200d9a <intr_enable>:
ffffffffc0200d9a:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200d9e:	8082                	ret

ffffffffc0200da0 <intr_disable>:
ffffffffc0200da0:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200da4:	8082                	ret

ffffffffc0200da6 <idt_init>:
ffffffffc0200da6:	14005073          	csrwi	sscratch,0
ffffffffc0200daa:	00000797          	auipc	a5,0x0
ffffffffc0200dae:	43a78793          	addi	a5,a5,1082 # ffffffffc02011e4 <__alltraps>
ffffffffc0200db2:	10579073          	csrw	stvec,a5
ffffffffc0200db6:	000407b7          	lui	a5,0x40
ffffffffc0200dba:	1007a7f3          	csrrs	a5,sstatus,a5
ffffffffc0200dbe:	8082                	ret

ffffffffc0200dc0 <print_regs>:
ffffffffc0200dc0:	610c                	ld	a1,0(a0)
ffffffffc0200dc2:	1141                	addi	sp,sp,-16
ffffffffc0200dc4:	e022                	sd	s0,0(sp)
ffffffffc0200dc6:	842a                	mv	s0,a0
ffffffffc0200dc8:	0000b517          	auipc	a0,0xb
ffffffffc0200dcc:	e1050513          	addi	a0,a0,-496 # ffffffffc020bbd8 <commands+0x300>
ffffffffc0200dd0:	e406                	sd	ra,8(sp)
ffffffffc0200dd2:	b58ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200dd6:	640c                	ld	a1,8(s0)
ffffffffc0200dd8:	0000b517          	auipc	a0,0xb
ffffffffc0200ddc:	e1850513          	addi	a0,a0,-488 # ffffffffc020bbf0 <commands+0x318>
ffffffffc0200de0:	b4aff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200de4:	680c                	ld	a1,16(s0)
ffffffffc0200de6:	0000b517          	auipc	a0,0xb
ffffffffc0200dea:	e2250513          	addi	a0,a0,-478 # ffffffffc020bc08 <commands+0x330>
ffffffffc0200dee:	b3cff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200df2:	6c0c                	ld	a1,24(s0)
ffffffffc0200df4:	0000b517          	auipc	a0,0xb
ffffffffc0200df8:	e2c50513          	addi	a0,a0,-468 # ffffffffc020bc20 <commands+0x348>
ffffffffc0200dfc:	b2eff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e00:	700c                	ld	a1,32(s0)
ffffffffc0200e02:	0000b517          	auipc	a0,0xb
ffffffffc0200e06:	e3650513          	addi	a0,a0,-458 # ffffffffc020bc38 <commands+0x360>
ffffffffc0200e0a:	b20ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e0e:	740c                	ld	a1,40(s0)
ffffffffc0200e10:	0000b517          	auipc	a0,0xb
ffffffffc0200e14:	e4050513          	addi	a0,a0,-448 # ffffffffc020bc50 <commands+0x378>
ffffffffc0200e18:	b12ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e1c:	780c                	ld	a1,48(s0)
ffffffffc0200e1e:	0000b517          	auipc	a0,0xb
ffffffffc0200e22:	e4a50513          	addi	a0,a0,-438 # ffffffffc020bc68 <commands+0x390>
ffffffffc0200e26:	b04ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e2a:	7c0c                	ld	a1,56(s0)
ffffffffc0200e2c:	0000b517          	auipc	a0,0xb
ffffffffc0200e30:	e5450513          	addi	a0,a0,-428 # ffffffffc020bc80 <commands+0x3a8>
ffffffffc0200e34:	af6ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e38:	602c                	ld	a1,64(s0)
ffffffffc0200e3a:	0000b517          	auipc	a0,0xb
ffffffffc0200e3e:	e5e50513          	addi	a0,a0,-418 # ffffffffc020bc98 <commands+0x3c0>
ffffffffc0200e42:	ae8ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e46:	642c                	ld	a1,72(s0)
ffffffffc0200e48:	0000b517          	auipc	a0,0xb
ffffffffc0200e4c:	e6850513          	addi	a0,a0,-408 # ffffffffc020bcb0 <commands+0x3d8>
ffffffffc0200e50:	adaff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e54:	682c                	ld	a1,80(s0)
ffffffffc0200e56:	0000b517          	auipc	a0,0xb
ffffffffc0200e5a:	e7250513          	addi	a0,a0,-398 # ffffffffc020bcc8 <commands+0x3f0>
ffffffffc0200e5e:	accff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e62:	6c2c                	ld	a1,88(s0)
ffffffffc0200e64:	0000b517          	auipc	a0,0xb
ffffffffc0200e68:	e7c50513          	addi	a0,a0,-388 # ffffffffc020bce0 <commands+0x408>
ffffffffc0200e6c:	abeff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e70:	702c                	ld	a1,96(s0)
ffffffffc0200e72:	0000b517          	auipc	a0,0xb
ffffffffc0200e76:	e8650513          	addi	a0,a0,-378 # ffffffffc020bcf8 <commands+0x420>
ffffffffc0200e7a:	ab0ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e7e:	742c                	ld	a1,104(s0)
ffffffffc0200e80:	0000b517          	auipc	a0,0xb
ffffffffc0200e84:	e9050513          	addi	a0,a0,-368 # ffffffffc020bd10 <commands+0x438>
ffffffffc0200e88:	aa2ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e8c:	782c                	ld	a1,112(s0)
ffffffffc0200e8e:	0000b517          	auipc	a0,0xb
ffffffffc0200e92:	e9a50513          	addi	a0,a0,-358 # ffffffffc020bd28 <commands+0x450>
ffffffffc0200e96:	a94ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e9a:	7c2c                	ld	a1,120(s0)
ffffffffc0200e9c:	0000b517          	auipc	a0,0xb
ffffffffc0200ea0:	ea450513          	addi	a0,a0,-348 # ffffffffc020bd40 <commands+0x468>
ffffffffc0200ea4:	a86ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200ea8:	604c                	ld	a1,128(s0)
ffffffffc0200eaa:	0000b517          	auipc	a0,0xb
ffffffffc0200eae:	eae50513          	addi	a0,a0,-338 # ffffffffc020bd58 <commands+0x480>
ffffffffc0200eb2:	a78ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200eb6:	644c                	ld	a1,136(s0)
ffffffffc0200eb8:	0000b517          	auipc	a0,0xb
ffffffffc0200ebc:	eb850513          	addi	a0,a0,-328 # ffffffffc020bd70 <commands+0x498>
ffffffffc0200ec0:	a6aff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200ec4:	684c                	ld	a1,144(s0)
ffffffffc0200ec6:	0000b517          	auipc	a0,0xb
ffffffffc0200eca:	ec250513          	addi	a0,a0,-318 # ffffffffc020bd88 <commands+0x4b0>
ffffffffc0200ece:	a5cff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200ed2:	6c4c                	ld	a1,152(s0)
ffffffffc0200ed4:	0000b517          	auipc	a0,0xb
ffffffffc0200ed8:	ecc50513          	addi	a0,a0,-308 # ffffffffc020bda0 <commands+0x4c8>
ffffffffc0200edc:	a4eff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200ee0:	704c                	ld	a1,160(s0)
ffffffffc0200ee2:	0000b517          	auipc	a0,0xb
ffffffffc0200ee6:	ed650513          	addi	a0,a0,-298 # ffffffffc020bdb8 <commands+0x4e0>
ffffffffc0200eea:	a40ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200eee:	744c                	ld	a1,168(s0)
ffffffffc0200ef0:	0000b517          	auipc	a0,0xb
ffffffffc0200ef4:	ee050513          	addi	a0,a0,-288 # ffffffffc020bdd0 <commands+0x4f8>
ffffffffc0200ef8:	a32ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200efc:	784c                	ld	a1,176(s0)
ffffffffc0200efe:	0000b517          	auipc	a0,0xb
ffffffffc0200f02:	eea50513          	addi	a0,a0,-278 # ffffffffc020bde8 <commands+0x510>
ffffffffc0200f06:	a24ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200f0a:	7c4c                	ld	a1,184(s0)
ffffffffc0200f0c:	0000b517          	auipc	a0,0xb
ffffffffc0200f10:	ef450513          	addi	a0,a0,-268 # ffffffffc020be00 <commands+0x528>
ffffffffc0200f14:	a16ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200f18:	606c                	ld	a1,192(s0)
ffffffffc0200f1a:	0000b517          	auipc	a0,0xb
ffffffffc0200f1e:	efe50513          	addi	a0,a0,-258 # ffffffffc020be18 <commands+0x540>
ffffffffc0200f22:	a08ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200f26:	646c                	ld	a1,200(s0)
ffffffffc0200f28:	0000b517          	auipc	a0,0xb
ffffffffc0200f2c:	f0850513          	addi	a0,a0,-248 # ffffffffc020be30 <commands+0x558>
ffffffffc0200f30:	9faff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200f34:	686c                	ld	a1,208(s0)
ffffffffc0200f36:	0000b517          	auipc	a0,0xb
ffffffffc0200f3a:	f1250513          	addi	a0,a0,-238 # ffffffffc020be48 <commands+0x570>
ffffffffc0200f3e:	9ecff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200f42:	6c6c                	ld	a1,216(s0)
ffffffffc0200f44:	0000b517          	auipc	a0,0xb
ffffffffc0200f48:	f1c50513          	addi	a0,a0,-228 # ffffffffc020be60 <commands+0x588>
ffffffffc0200f4c:	9deff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200f50:	706c                	ld	a1,224(s0)
ffffffffc0200f52:	0000b517          	auipc	a0,0xb
ffffffffc0200f56:	f2650513          	addi	a0,a0,-218 # ffffffffc020be78 <commands+0x5a0>
ffffffffc0200f5a:	9d0ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200f5e:	746c                	ld	a1,232(s0)
ffffffffc0200f60:	0000b517          	auipc	a0,0xb
ffffffffc0200f64:	f3050513          	addi	a0,a0,-208 # ffffffffc020be90 <commands+0x5b8>
ffffffffc0200f68:	9c2ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200f6c:	786c                	ld	a1,240(s0)
ffffffffc0200f6e:	0000b517          	auipc	a0,0xb
ffffffffc0200f72:	f3a50513          	addi	a0,a0,-198 # ffffffffc020bea8 <commands+0x5d0>
ffffffffc0200f76:	9b4ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200f7a:	7c6c                	ld	a1,248(s0)
ffffffffc0200f7c:	6402                	ld	s0,0(sp)
ffffffffc0200f7e:	60a2                	ld	ra,8(sp)
ffffffffc0200f80:	0000b517          	auipc	a0,0xb
ffffffffc0200f84:	f4050513          	addi	a0,a0,-192 # ffffffffc020bec0 <commands+0x5e8>
ffffffffc0200f88:	0141                	addi	sp,sp,16
ffffffffc0200f8a:	9a0ff06f          	j	ffffffffc020012a <cprintf>

ffffffffc0200f8e <print_trapframe>:
ffffffffc0200f8e:	1141                	addi	sp,sp,-16
ffffffffc0200f90:	e022                	sd	s0,0(sp)
ffffffffc0200f92:	85aa                	mv	a1,a0
ffffffffc0200f94:	842a                	mv	s0,a0
ffffffffc0200f96:	0000b517          	auipc	a0,0xb
ffffffffc0200f9a:	f4250513          	addi	a0,a0,-190 # ffffffffc020bed8 <commands+0x600>
ffffffffc0200f9e:	e406                	sd	ra,8(sp)
ffffffffc0200fa0:	98aff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200fa4:	8522                	mv	a0,s0
ffffffffc0200fa6:	e1bff0ef          	jal	ra,ffffffffc0200dc0 <print_regs>
ffffffffc0200faa:	10043583          	ld	a1,256(s0)
ffffffffc0200fae:	0000b517          	auipc	a0,0xb
ffffffffc0200fb2:	f4250513          	addi	a0,a0,-190 # ffffffffc020bef0 <commands+0x618>
ffffffffc0200fb6:	974ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200fba:	10843583          	ld	a1,264(s0)
ffffffffc0200fbe:	0000b517          	auipc	a0,0xb
ffffffffc0200fc2:	f4a50513          	addi	a0,a0,-182 # ffffffffc020bf08 <commands+0x630>
ffffffffc0200fc6:	964ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200fca:	11043583          	ld	a1,272(s0)
ffffffffc0200fce:	0000b517          	auipc	a0,0xb
ffffffffc0200fd2:	f5250513          	addi	a0,a0,-174 # ffffffffc020bf20 <commands+0x648>
ffffffffc0200fd6:	954ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200fda:	11843583          	ld	a1,280(s0)
ffffffffc0200fde:	6402                	ld	s0,0(sp)
ffffffffc0200fe0:	60a2                	ld	ra,8(sp)
ffffffffc0200fe2:	0000b517          	auipc	a0,0xb
ffffffffc0200fe6:	f4e50513          	addi	a0,a0,-178 # ffffffffc020bf30 <commands+0x658>
ffffffffc0200fea:	0141                	addi	sp,sp,16
ffffffffc0200fec:	93eff06f          	j	ffffffffc020012a <cprintf>

ffffffffc0200ff0 <interrupt_handler>:
ffffffffc0200ff0:	11853783          	ld	a5,280(a0)
ffffffffc0200ff4:	472d                	li	a4,11
ffffffffc0200ff6:	0786                	slli	a5,a5,0x1
ffffffffc0200ff8:	8385                	srli	a5,a5,0x1
ffffffffc0200ffa:	06f76c63          	bltu	a4,a5,ffffffffc0201072 <interrupt_handler+0x82>
ffffffffc0200ffe:	0000b717          	auipc	a4,0xb
ffffffffc0201002:	fea70713          	addi	a4,a4,-22 # ffffffffc020bfe8 <commands+0x710>
ffffffffc0201006:	078a                	slli	a5,a5,0x2
ffffffffc0201008:	97ba                	add	a5,a5,a4
ffffffffc020100a:	439c                	lw	a5,0(a5)
ffffffffc020100c:	97ba                	add	a5,a5,a4
ffffffffc020100e:	8782                	jr	a5
ffffffffc0201010:	0000b517          	auipc	a0,0xb
ffffffffc0201014:	f9850513          	addi	a0,a0,-104 # ffffffffc020bfa8 <commands+0x6d0>
ffffffffc0201018:	912ff06f          	j	ffffffffc020012a <cprintf>
ffffffffc020101c:	0000b517          	auipc	a0,0xb
ffffffffc0201020:	f6c50513          	addi	a0,a0,-148 # ffffffffc020bf88 <commands+0x6b0>
ffffffffc0201024:	906ff06f          	j	ffffffffc020012a <cprintf>
ffffffffc0201028:	0000b517          	auipc	a0,0xb
ffffffffc020102c:	f2050513          	addi	a0,a0,-224 # ffffffffc020bf48 <commands+0x670>
ffffffffc0201030:	8faff06f          	j	ffffffffc020012a <cprintf>
ffffffffc0201034:	0000b517          	auipc	a0,0xb
ffffffffc0201038:	f3450513          	addi	a0,a0,-204 # ffffffffc020bf68 <commands+0x690>
ffffffffc020103c:	8eeff06f          	j	ffffffffc020012a <cprintf>
ffffffffc0201040:	1141                	addi	sp,sp,-16
ffffffffc0201042:	e406                	sd	ra,8(sp)
ffffffffc0201044:	a13ff0ef          	jal	ra,ffffffffc0200a56 <clock_set_next_event>
ffffffffc0201048:	00096717          	auipc	a4,0x96
ffffffffc020104c:	83870713          	addi	a4,a4,-1992 # ffffffffc0296880 <ticks>
ffffffffc0201050:	631c                	ld	a5,0(a4)
ffffffffc0201052:	0785                	addi	a5,a5,1
ffffffffc0201054:	e31c                	sd	a5,0(a4)
ffffffffc0201056:	51e060ef          	jal	ra,ffffffffc0207574 <run_timer_list>
ffffffffc020105a:	a77ff0ef          	jal	ra,ffffffffc0200ad0 <cons_getc>
ffffffffc020105e:	60a2                	ld	ra,8(sp)
ffffffffc0201060:	0141                	addi	sp,sp,16
ffffffffc0201062:	7200706f          	j	ffffffffc0208782 <dev_stdin_write>
ffffffffc0201066:	0000b517          	auipc	a0,0xb
ffffffffc020106a:	f6250513          	addi	a0,a0,-158 # ffffffffc020bfc8 <commands+0x6f0>
ffffffffc020106e:	8bcff06f          	j	ffffffffc020012a <cprintf>
ffffffffc0201072:	bf31                	j	ffffffffc0200f8e <print_trapframe>

ffffffffc0201074 <exception_handler>:
ffffffffc0201074:	11853783          	ld	a5,280(a0)
ffffffffc0201078:	1141                	addi	sp,sp,-16
ffffffffc020107a:	e022                	sd	s0,0(sp)
ffffffffc020107c:	e406                	sd	ra,8(sp)
ffffffffc020107e:	473d                	li	a4,15
ffffffffc0201080:	842a                	mv	s0,a0
ffffffffc0201082:	0af76b63          	bltu	a4,a5,ffffffffc0201138 <exception_handler+0xc4>
ffffffffc0201086:	0000b717          	auipc	a4,0xb
ffffffffc020108a:	12270713          	addi	a4,a4,290 # ffffffffc020c1a8 <commands+0x8d0>
ffffffffc020108e:	078a                	slli	a5,a5,0x2
ffffffffc0201090:	97ba                	add	a5,a5,a4
ffffffffc0201092:	439c                	lw	a5,0(a5)
ffffffffc0201094:	97ba                	add	a5,a5,a4
ffffffffc0201096:	8782                	jr	a5
ffffffffc0201098:	0000b517          	auipc	a0,0xb
ffffffffc020109c:	06850513          	addi	a0,a0,104 # ffffffffc020c100 <commands+0x828>
ffffffffc02010a0:	88aff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02010a4:	10843783          	ld	a5,264(s0)
ffffffffc02010a8:	60a2                	ld	ra,8(sp)
ffffffffc02010aa:	0791                	addi	a5,a5,4
ffffffffc02010ac:	10f43423          	sd	a5,264(s0)
ffffffffc02010b0:	6402                	ld	s0,0(sp)
ffffffffc02010b2:	0141                	addi	sp,sp,16
ffffffffc02010b4:	7be0606f          	j	ffffffffc0207872 <syscall>
ffffffffc02010b8:	0000b517          	auipc	a0,0xb
ffffffffc02010bc:	06850513          	addi	a0,a0,104 # ffffffffc020c120 <commands+0x848>
ffffffffc02010c0:	6402                	ld	s0,0(sp)
ffffffffc02010c2:	60a2                	ld	ra,8(sp)
ffffffffc02010c4:	0141                	addi	sp,sp,16
ffffffffc02010c6:	864ff06f          	j	ffffffffc020012a <cprintf>
ffffffffc02010ca:	0000b517          	auipc	a0,0xb
ffffffffc02010ce:	07650513          	addi	a0,a0,118 # ffffffffc020c140 <commands+0x868>
ffffffffc02010d2:	b7fd                	j	ffffffffc02010c0 <exception_handler+0x4c>
ffffffffc02010d4:	0000b517          	auipc	a0,0xb
ffffffffc02010d8:	08c50513          	addi	a0,a0,140 # ffffffffc020c160 <commands+0x888>
ffffffffc02010dc:	b7d5                	j	ffffffffc02010c0 <exception_handler+0x4c>
ffffffffc02010de:	0000b517          	auipc	a0,0xb
ffffffffc02010e2:	09a50513          	addi	a0,a0,154 # ffffffffc020c178 <commands+0x8a0>
ffffffffc02010e6:	bfe9                	j	ffffffffc02010c0 <exception_handler+0x4c>
ffffffffc02010e8:	0000b517          	auipc	a0,0xb
ffffffffc02010ec:	0a850513          	addi	a0,a0,168 # ffffffffc020c190 <commands+0x8b8>
ffffffffc02010f0:	bfc1                	j	ffffffffc02010c0 <exception_handler+0x4c>
ffffffffc02010f2:	0000b517          	auipc	a0,0xb
ffffffffc02010f6:	f2650513          	addi	a0,a0,-218 # ffffffffc020c018 <commands+0x740>
ffffffffc02010fa:	b7d9                	j	ffffffffc02010c0 <exception_handler+0x4c>
ffffffffc02010fc:	0000b517          	auipc	a0,0xb
ffffffffc0201100:	f3c50513          	addi	a0,a0,-196 # ffffffffc020c038 <commands+0x760>
ffffffffc0201104:	bf75                	j	ffffffffc02010c0 <exception_handler+0x4c>
ffffffffc0201106:	0000b517          	auipc	a0,0xb
ffffffffc020110a:	f5250513          	addi	a0,a0,-174 # ffffffffc020c058 <commands+0x780>
ffffffffc020110e:	bf4d                	j	ffffffffc02010c0 <exception_handler+0x4c>
ffffffffc0201110:	0000b517          	auipc	a0,0xb
ffffffffc0201114:	f6050513          	addi	a0,a0,-160 # ffffffffc020c070 <commands+0x798>
ffffffffc0201118:	b765                	j	ffffffffc02010c0 <exception_handler+0x4c>
ffffffffc020111a:	0000b517          	auipc	a0,0xb
ffffffffc020111e:	f6650513          	addi	a0,a0,-154 # ffffffffc020c080 <commands+0x7a8>
ffffffffc0201122:	bf79                	j	ffffffffc02010c0 <exception_handler+0x4c>
ffffffffc0201124:	0000b517          	auipc	a0,0xb
ffffffffc0201128:	f7c50513          	addi	a0,a0,-132 # ffffffffc020c0a0 <commands+0x7c8>
ffffffffc020112c:	bf51                	j	ffffffffc02010c0 <exception_handler+0x4c>
ffffffffc020112e:	0000b517          	auipc	a0,0xb
ffffffffc0201132:	fba50513          	addi	a0,a0,-70 # ffffffffc020c0e8 <commands+0x810>
ffffffffc0201136:	b769                	j	ffffffffc02010c0 <exception_handler+0x4c>
ffffffffc0201138:	8522                	mv	a0,s0
ffffffffc020113a:	6402                	ld	s0,0(sp)
ffffffffc020113c:	60a2                	ld	ra,8(sp)
ffffffffc020113e:	0141                	addi	sp,sp,16
ffffffffc0201140:	b5b9                	j	ffffffffc0200f8e <print_trapframe>
ffffffffc0201142:	0000b617          	auipc	a2,0xb
ffffffffc0201146:	f7660613          	addi	a2,a2,-138 # ffffffffc020c0b8 <commands+0x7e0>
ffffffffc020114a:	0b100593          	li	a1,177
ffffffffc020114e:	0000b517          	auipc	a0,0xb
ffffffffc0201152:	f8250513          	addi	a0,a0,-126 # ffffffffc020c0d0 <commands+0x7f8>
ffffffffc0201156:	8d8ff0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020115a <trap>:
ffffffffc020115a:	1101                	addi	sp,sp,-32
ffffffffc020115c:	e822                	sd	s0,16(sp)
ffffffffc020115e:	00095417          	auipc	s0,0x95
ffffffffc0201162:	76240413          	addi	s0,s0,1890 # ffffffffc02968c0 <current>
ffffffffc0201166:	6018                	ld	a4,0(s0)
ffffffffc0201168:	ec06                	sd	ra,24(sp)
ffffffffc020116a:	e426                	sd	s1,8(sp)
ffffffffc020116c:	e04a                	sd	s2,0(sp)
ffffffffc020116e:	11853683          	ld	a3,280(a0)
ffffffffc0201172:	cf1d                	beqz	a4,ffffffffc02011b0 <trap+0x56>
ffffffffc0201174:	10053483          	ld	s1,256(a0)
ffffffffc0201178:	0a073903          	ld	s2,160(a4)
ffffffffc020117c:	f348                	sd	a0,160(a4)
ffffffffc020117e:	1004f493          	andi	s1,s1,256
ffffffffc0201182:	0206c463          	bltz	a3,ffffffffc02011aa <trap+0x50>
ffffffffc0201186:	eefff0ef          	jal	ra,ffffffffc0201074 <exception_handler>
ffffffffc020118a:	601c                	ld	a5,0(s0)
ffffffffc020118c:	0b27b023          	sd	s2,160(a5) # 400a0 <_binary_bin_swap_img_size+0x383a0>
ffffffffc0201190:	e499                	bnez	s1,ffffffffc020119e <trap+0x44>
ffffffffc0201192:	0b07a703          	lw	a4,176(a5)
ffffffffc0201196:	8b05                	andi	a4,a4,1
ffffffffc0201198:	e329                	bnez	a4,ffffffffc02011da <trap+0x80>
ffffffffc020119a:	6f9c                	ld	a5,24(a5)
ffffffffc020119c:	eb85                	bnez	a5,ffffffffc02011cc <trap+0x72>
ffffffffc020119e:	60e2                	ld	ra,24(sp)
ffffffffc02011a0:	6442                	ld	s0,16(sp)
ffffffffc02011a2:	64a2                	ld	s1,8(sp)
ffffffffc02011a4:	6902                	ld	s2,0(sp)
ffffffffc02011a6:	6105                	addi	sp,sp,32
ffffffffc02011a8:	8082                	ret
ffffffffc02011aa:	e47ff0ef          	jal	ra,ffffffffc0200ff0 <interrupt_handler>
ffffffffc02011ae:	bff1                	j	ffffffffc020118a <trap+0x30>
ffffffffc02011b0:	0006c863          	bltz	a3,ffffffffc02011c0 <trap+0x66>
ffffffffc02011b4:	6442                	ld	s0,16(sp)
ffffffffc02011b6:	60e2                	ld	ra,24(sp)
ffffffffc02011b8:	64a2                	ld	s1,8(sp)
ffffffffc02011ba:	6902                	ld	s2,0(sp)
ffffffffc02011bc:	6105                	addi	sp,sp,32
ffffffffc02011be:	bd5d                	j	ffffffffc0201074 <exception_handler>
ffffffffc02011c0:	6442                	ld	s0,16(sp)
ffffffffc02011c2:	60e2                	ld	ra,24(sp)
ffffffffc02011c4:	64a2                	ld	s1,8(sp)
ffffffffc02011c6:	6902                	ld	s2,0(sp)
ffffffffc02011c8:	6105                	addi	sp,sp,32
ffffffffc02011ca:	b51d                	j	ffffffffc0200ff0 <interrupt_handler>
ffffffffc02011cc:	6442                	ld	s0,16(sp)
ffffffffc02011ce:	60e2                	ld	ra,24(sp)
ffffffffc02011d0:	64a2                	ld	s1,8(sp)
ffffffffc02011d2:	6902                	ld	s2,0(sp)
ffffffffc02011d4:	6105                	addi	sp,sp,32
ffffffffc02011d6:	1920606f          	j	ffffffffc0207368 <schedule>
ffffffffc02011da:	555d                	li	a0,-9
ffffffffc02011dc:	689040ef          	jal	ra,ffffffffc0206064 <do_exit>
ffffffffc02011e0:	601c                	ld	a5,0(s0)
ffffffffc02011e2:	bf65                	j	ffffffffc020119a <trap+0x40>

ffffffffc02011e4 <__alltraps>:
ffffffffc02011e4:	14011173          	csrrw	sp,sscratch,sp
ffffffffc02011e8:	00011463          	bnez	sp,ffffffffc02011f0 <__alltraps+0xc>
ffffffffc02011ec:	14002173          	csrr	sp,sscratch
ffffffffc02011f0:	712d                	addi	sp,sp,-288
ffffffffc02011f2:	e002                	sd	zero,0(sp)
ffffffffc02011f4:	e406                	sd	ra,8(sp)
ffffffffc02011f6:	ec0e                	sd	gp,24(sp)
ffffffffc02011f8:	f012                	sd	tp,32(sp)
ffffffffc02011fa:	f416                	sd	t0,40(sp)
ffffffffc02011fc:	f81a                	sd	t1,48(sp)
ffffffffc02011fe:	fc1e                	sd	t2,56(sp)
ffffffffc0201200:	e0a2                	sd	s0,64(sp)
ffffffffc0201202:	e4a6                	sd	s1,72(sp)
ffffffffc0201204:	e8aa                	sd	a0,80(sp)
ffffffffc0201206:	ecae                	sd	a1,88(sp)
ffffffffc0201208:	f0b2                	sd	a2,96(sp)
ffffffffc020120a:	f4b6                	sd	a3,104(sp)
ffffffffc020120c:	f8ba                	sd	a4,112(sp)
ffffffffc020120e:	fcbe                	sd	a5,120(sp)
ffffffffc0201210:	e142                	sd	a6,128(sp)
ffffffffc0201212:	e546                	sd	a7,136(sp)
ffffffffc0201214:	e94a                	sd	s2,144(sp)
ffffffffc0201216:	ed4e                	sd	s3,152(sp)
ffffffffc0201218:	f152                	sd	s4,160(sp)
ffffffffc020121a:	f556                	sd	s5,168(sp)
ffffffffc020121c:	f95a                	sd	s6,176(sp)
ffffffffc020121e:	fd5e                	sd	s7,184(sp)
ffffffffc0201220:	e1e2                	sd	s8,192(sp)
ffffffffc0201222:	e5e6                	sd	s9,200(sp)
ffffffffc0201224:	e9ea                	sd	s10,208(sp)
ffffffffc0201226:	edee                	sd	s11,216(sp)
ffffffffc0201228:	f1f2                	sd	t3,224(sp)
ffffffffc020122a:	f5f6                	sd	t4,232(sp)
ffffffffc020122c:	f9fa                	sd	t5,240(sp)
ffffffffc020122e:	fdfe                	sd	t6,248(sp)
ffffffffc0201230:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0201234:	100024f3          	csrr	s1,sstatus
ffffffffc0201238:	14102973          	csrr	s2,sepc
ffffffffc020123c:	143029f3          	csrr	s3,stval
ffffffffc0201240:	14202a73          	csrr	s4,scause
ffffffffc0201244:	e822                	sd	s0,16(sp)
ffffffffc0201246:	e226                	sd	s1,256(sp)
ffffffffc0201248:	e64a                	sd	s2,264(sp)
ffffffffc020124a:	ea4e                	sd	s3,272(sp)
ffffffffc020124c:	ee52                	sd	s4,280(sp)
ffffffffc020124e:	850a                	mv	a0,sp
ffffffffc0201250:	f0bff0ef          	jal	ra,ffffffffc020115a <trap>

ffffffffc0201254 <__trapret>:
ffffffffc0201254:	6492                	ld	s1,256(sp)
ffffffffc0201256:	6932                	ld	s2,264(sp)
ffffffffc0201258:	1004f413          	andi	s0,s1,256
ffffffffc020125c:	e401                	bnez	s0,ffffffffc0201264 <__trapret+0x10>
ffffffffc020125e:	1200                	addi	s0,sp,288
ffffffffc0201260:	14041073          	csrw	sscratch,s0
ffffffffc0201264:	10049073          	csrw	sstatus,s1
ffffffffc0201268:	14191073          	csrw	sepc,s2
ffffffffc020126c:	60a2                	ld	ra,8(sp)
ffffffffc020126e:	61e2                	ld	gp,24(sp)
ffffffffc0201270:	7202                	ld	tp,32(sp)
ffffffffc0201272:	72a2                	ld	t0,40(sp)
ffffffffc0201274:	7342                	ld	t1,48(sp)
ffffffffc0201276:	73e2                	ld	t2,56(sp)
ffffffffc0201278:	6406                	ld	s0,64(sp)
ffffffffc020127a:	64a6                	ld	s1,72(sp)
ffffffffc020127c:	6546                	ld	a0,80(sp)
ffffffffc020127e:	65e6                	ld	a1,88(sp)
ffffffffc0201280:	7606                	ld	a2,96(sp)
ffffffffc0201282:	76a6                	ld	a3,104(sp)
ffffffffc0201284:	7746                	ld	a4,112(sp)
ffffffffc0201286:	77e6                	ld	a5,120(sp)
ffffffffc0201288:	680a                	ld	a6,128(sp)
ffffffffc020128a:	68aa                	ld	a7,136(sp)
ffffffffc020128c:	694a                	ld	s2,144(sp)
ffffffffc020128e:	69ea                	ld	s3,152(sp)
ffffffffc0201290:	7a0a                	ld	s4,160(sp)
ffffffffc0201292:	7aaa                	ld	s5,168(sp)
ffffffffc0201294:	7b4a                	ld	s6,176(sp)
ffffffffc0201296:	7bea                	ld	s7,184(sp)
ffffffffc0201298:	6c0e                	ld	s8,192(sp)
ffffffffc020129a:	6cae                	ld	s9,200(sp)
ffffffffc020129c:	6d4e                	ld	s10,208(sp)
ffffffffc020129e:	6dee                	ld	s11,216(sp)
ffffffffc02012a0:	7e0e                	ld	t3,224(sp)
ffffffffc02012a2:	7eae                	ld	t4,232(sp)
ffffffffc02012a4:	7f4e                	ld	t5,240(sp)
ffffffffc02012a6:	7fee                	ld	t6,248(sp)
ffffffffc02012a8:	6142                	ld	sp,16(sp)
ffffffffc02012aa:	10200073          	sret

ffffffffc02012ae <forkrets>:
ffffffffc02012ae:	812a                	mv	sp,a0
ffffffffc02012b0:	b755                	j	ffffffffc0201254 <__trapret>

ffffffffc02012b2 <pa2page.part.0>:
ffffffffc02012b2:	1141                	addi	sp,sp,-16
ffffffffc02012b4:	0000b617          	auipc	a2,0xb
ffffffffc02012b8:	f3460613          	addi	a2,a2,-204 # ffffffffc020c1e8 <commands+0x910>
ffffffffc02012bc:	06900593          	li	a1,105
ffffffffc02012c0:	0000b517          	auipc	a0,0xb
ffffffffc02012c4:	f4850513          	addi	a0,a0,-184 # ffffffffc020c208 <commands+0x930>
ffffffffc02012c8:	e406                	sd	ra,8(sp)
ffffffffc02012ca:	f65fe0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02012ce <pte2page.part.0>:
ffffffffc02012ce:	1141                	addi	sp,sp,-16
ffffffffc02012d0:	0000b617          	auipc	a2,0xb
ffffffffc02012d4:	f4860613          	addi	a2,a2,-184 # ffffffffc020c218 <commands+0x940>
ffffffffc02012d8:	07f00593          	li	a1,127
ffffffffc02012dc:	0000b517          	auipc	a0,0xb
ffffffffc02012e0:	f2c50513          	addi	a0,a0,-212 # ffffffffc020c208 <commands+0x930>
ffffffffc02012e4:	e406                	sd	ra,8(sp)
ffffffffc02012e6:	f49fe0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02012ea <alloc_pages>:
ffffffffc02012ea:	100027f3          	csrr	a5,sstatus
ffffffffc02012ee:	8b89                	andi	a5,a5,2
ffffffffc02012f0:	e799                	bnez	a5,ffffffffc02012fe <alloc_pages+0x14>
ffffffffc02012f2:	00095797          	auipc	a5,0x95
ffffffffc02012f6:	5b67b783          	ld	a5,1462(a5) # ffffffffc02968a8 <pmm_manager>
ffffffffc02012fa:	6f9c                	ld	a5,24(a5)
ffffffffc02012fc:	8782                	jr	a5
ffffffffc02012fe:	1141                	addi	sp,sp,-16
ffffffffc0201300:	e406                	sd	ra,8(sp)
ffffffffc0201302:	e022                	sd	s0,0(sp)
ffffffffc0201304:	842a                	mv	s0,a0
ffffffffc0201306:	a9bff0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc020130a:	00095797          	auipc	a5,0x95
ffffffffc020130e:	59e7b783          	ld	a5,1438(a5) # ffffffffc02968a8 <pmm_manager>
ffffffffc0201312:	6f9c                	ld	a5,24(a5)
ffffffffc0201314:	8522                	mv	a0,s0
ffffffffc0201316:	9782                	jalr	a5
ffffffffc0201318:	842a                	mv	s0,a0
ffffffffc020131a:	a81ff0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc020131e:	60a2                	ld	ra,8(sp)
ffffffffc0201320:	8522                	mv	a0,s0
ffffffffc0201322:	6402                	ld	s0,0(sp)
ffffffffc0201324:	0141                	addi	sp,sp,16
ffffffffc0201326:	8082                	ret

ffffffffc0201328 <free_pages>:
ffffffffc0201328:	100027f3          	csrr	a5,sstatus
ffffffffc020132c:	8b89                	andi	a5,a5,2
ffffffffc020132e:	e799                	bnez	a5,ffffffffc020133c <free_pages+0x14>
ffffffffc0201330:	00095797          	auipc	a5,0x95
ffffffffc0201334:	5787b783          	ld	a5,1400(a5) # ffffffffc02968a8 <pmm_manager>
ffffffffc0201338:	739c                	ld	a5,32(a5)
ffffffffc020133a:	8782                	jr	a5
ffffffffc020133c:	1101                	addi	sp,sp,-32
ffffffffc020133e:	ec06                	sd	ra,24(sp)
ffffffffc0201340:	e822                	sd	s0,16(sp)
ffffffffc0201342:	e426                	sd	s1,8(sp)
ffffffffc0201344:	842a                	mv	s0,a0
ffffffffc0201346:	84ae                	mv	s1,a1
ffffffffc0201348:	a59ff0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc020134c:	00095797          	auipc	a5,0x95
ffffffffc0201350:	55c7b783          	ld	a5,1372(a5) # ffffffffc02968a8 <pmm_manager>
ffffffffc0201354:	739c                	ld	a5,32(a5)
ffffffffc0201356:	85a6                	mv	a1,s1
ffffffffc0201358:	8522                	mv	a0,s0
ffffffffc020135a:	9782                	jalr	a5
ffffffffc020135c:	6442                	ld	s0,16(sp)
ffffffffc020135e:	60e2                	ld	ra,24(sp)
ffffffffc0201360:	64a2                	ld	s1,8(sp)
ffffffffc0201362:	6105                	addi	sp,sp,32
ffffffffc0201364:	a37ff06f          	j	ffffffffc0200d9a <intr_enable>

ffffffffc0201368 <nr_free_pages>:
ffffffffc0201368:	100027f3          	csrr	a5,sstatus
ffffffffc020136c:	8b89                	andi	a5,a5,2
ffffffffc020136e:	e799                	bnez	a5,ffffffffc020137c <nr_free_pages+0x14>
ffffffffc0201370:	00095797          	auipc	a5,0x95
ffffffffc0201374:	5387b783          	ld	a5,1336(a5) # ffffffffc02968a8 <pmm_manager>
ffffffffc0201378:	779c                	ld	a5,40(a5)
ffffffffc020137a:	8782                	jr	a5
ffffffffc020137c:	1141                	addi	sp,sp,-16
ffffffffc020137e:	e406                	sd	ra,8(sp)
ffffffffc0201380:	e022                	sd	s0,0(sp)
ffffffffc0201382:	a1fff0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0201386:	00095797          	auipc	a5,0x95
ffffffffc020138a:	5227b783          	ld	a5,1314(a5) # ffffffffc02968a8 <pmm_manager>
ffffffffc020138e:	779c                	ld	a5,40(a5)
ffffffffc0201390:	9782                	jalr	a5
ffffffffc0201392:	842a                	mv	s0,a0
ffffffffc0201394:	a07ff0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0201398:	60a2                	ld	ra,8(sp)
ffffffffc020139a:	8522                	mv	a0,s0
ffffffffc020139c:	6402                	ld	s0,0(sp)
ffffffffc020139e:	0141                	addi	sp,sp,16
ffffffffc02013a0:	8082                	ret

ffffffffc02013a2 <get_pte>:
ffffffffc02013a2:	01e5d793          	srli	a5,a1,0x1e
ffffffffc02013a6:	1ff7f793          	andi	a5,a5,511
ffffffffc02013aa:	7139                	addi	sp,sp,-64
ffffffffc02013ac:	078e                	slli	a5,a5,0x3
ffffffffc02013ae:	f426                	sd	s1,40(sp)
ffffffffc02013b0:	00f504b3          	add	s1,a0,a5
ffffffffc02013b4:	6094                	ld	a3,0(s1)
ffffffffc02013b6:	f04a                	sd	s2,32(sp)
ffffffffc02013b8:	ec4e                	sd	s3,24(sp)
ffffffffc02013ba:	e852                	sd	s4,16(sp)
ffffffffc02013bc:	fc06                	sd	ra,56(sp)
ffffffffc02013be:	f822                	sd	s0,48(sp)
ffffffffc02013c0:	e456                	sd	s5,8(sp)
ffffffffc02013c2:	e05a                	sd	s6,0(sp)
ffffffffc02013c4:	0016f793          	andi	a5,a3,1
ffffffffc02013c8:	892e                	mv	s2,a1
ffffffffc02013ca:	8a32                	mv	s4,a2
ffffffffc02013cc:	00095997          	auipc	s3,0x95
ffffffffc02013d0:	4cc98993          	addi	s3,s3,1228 # ffffffffc0296898 <npage>
ffffffffc02013d4:	efbd                	bnez	a5,ffffffffc0201452 <get_pte+0xb0>
ffffffffc02013d6:	14060c63          	beqz	a2,ffffffffc020152e <get_pte+0x18c>
ffffffffc02013da:	100027f3          	csrr	a5,sstatus
ffffffffc02013de:	8b89                	andi	a5,a5,2
ffffffffc02013e0:	14079963          	bnez	a5,ffffffffc0201532 <get_pte+0x190>
ffffffffc02013e4:	00095797          	auipc	a5,0x95
ffffffffc02013e8:	4c47b783          	ld	a5,1220(a5) # ffffffffc02968a8 <pmm_manager>
ffffffffc02013ec:	6f9c                	ld	a5,24(a5)
ffffffffc02013ee:	4505                	li	a0,1
ffffffffc02013f0:	9782                	jalr	a5
ffffffffc02013f2:	842a                	mv	s0,a0
ffffffffc02013f4:	12040d63          	beqz	s0,ffffffffc020152e <get_pte+0x18c>
ffffffffc02013f8:	00095b17          	auipc	s6,0x95
ffffffffc02013fc:	4a8b0b13          	addi	s6,s6,1192 # ffffffffc02968a0 <pages>
ffffffffc0201400:	000b3503          	ld	a0,0(s6)
ffffffffc0201404:	00080ab7          	lui	s5,0x80
ffffffffc0201408:	00095997          	auipc	s3,0x95
ffffffffc020140c:	49098993          	addi	s3,s3,1168 # ffffffffc0296898 <npage>
ffffffffc0201410:	40a40533          	sub	a0,s0,a0
ffffffffc0201414:	8519                	srai	a0,a0,0x6
ffffffffc0201416:	9556                	add	a0,a0,s5
ffffffffc0201418:	0009b703          	ld	a4,0(s3)
ffffffffc020141c:	00c51793          	slli	a5,a0,0xc
ffffffffc0201420:	4685                	li	a3,1
ffffffffc0201422:	c014                	sw	a3,0(s0)
ffffffffc0201424:	83b1                	srli	a5,a5,0xc
ffffffffc0201426:	0532                	slli	a0,a0,0xc
ffffffffc0201428:	16e7f763          	bgeu	a5,a4,ffffffffc0201596 <get_pte+0x1f4>
ffffffffc020142c:	00095797          	auipc	a5,0x95
ffffffffc0201430:	4847b783          	ld	a5,1156(a5) # ffffffffc02968b0 <va_pa_offset>
ffffffffc0201434:	6605                	lui	a2,0x1
ffffffffc0201436:	4581                	li	a1,0
ffffffffc0201438:	953e                	add	a0,a0,a5
ffffffffc020143a:	4f9090ef          	jal	ra,ffffffffc020b132 <memset>
ffffffffc020143e:	000b3683          	ld	a3,0(s6)
ffffffffc0201442:	40d406b3          	sub	a3,s0,a3
ffffffffc0201446:	8699                	srai	a3,a3,0x6
ffffffffc0201448:	96d6                	add	a3,a3,s5
ffffffffc020144a:	06aa                	slli	a3,a3,0xa
ffffffffc020144c:	0116e693          	ori	a3,a3,17
ffffffffc0201450:	e094                	sd	a3,0(s1)
ffffffffc0201452:	77fd                	lui	a5,0xfffff
ffffffffc0201454:	068a                	slli	a3,a3,0x2
ffffffffc0201456:	0009b703          	ld	a4,0(s3)
ffffffffc020145a:	8efd                	and	a3,a3,a5
ffffffffc020145c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201460:	10e7ff63          	bgeu	a5,a4,ffffffffc020157e <get_pte+0x1dc>
ffffffffc0201464:	00095a97          	auipc	s5,0x95
ffffffffc0201468:	44ca8a93          	addi	s5,s5,1100 # ffffffffc02968b0 <va_pa_offset>
ffffffffc020146c:	000ab403          	ld	s0,0(s5)
ffffffffc0201470:	01595793          	srli	a5,s2,0x15
ffffffffc0201474:	1ff7f793          	andi	a5,a5,511
ffffffffc0201478:	96a2                	add	a3,a3,s0
ffffffffc020147a:	00379413          	slli	s0,a5,0x3
ffffffffc020147e:	9436                	add	s0,s0,a3
ffffffffc0201480:	6014                	ld	a3,0(s0)
ffffffffc0201482:	0016f793          	andi	a5,a3,1
ffffffffc0201486:	ebad                	bnez	a5,ffffffffc02014f8 <get_pte+0x156>
ffffffffc0201488:	0a0a0363          	beqz	s4,ffffffffc020152e <get_pte+0x18c>
ffffffffc020148c:	100027f3          	csrr	a5,sstatus
ffffffffc0201490:	8b89                	andi	a5,a5,2
ffffffffc0201492:	efcd                	bnez	a5,ffffffffc020154c <get_pte+0x1aa>
ffffffffc0201494:	00095797          	auipc	a5,0x95
ffffffffc0201498:	4147b783          	ld	a5,1044(a5) # ffffffffc02968a8 <pmm_manager>
ffffffffc020149c:	6f9c                	ld	a5,24(a5)
ffffffffc020149e:	4505                	li	a0,1
ffffffffc02014a0:	9782                	jalr	a5
ffffffffc02014a2:	84aa                	mv	s1,a0
ffffffffc02014a4:	c4c9                	beqz	s1,ffffffffc020152e <get_pte+0x18c>
ffffffffc02014a6:	00095b17          	auipc	s6,0x95
ffffffffc02014aa:	3fab0b13          	addi	s6,s6,1018 # ffffffffc02968a0 <pages>
ffffffffc02014ae:	000b3503          	ld	a0,0(s6)
ffffffffc02014b2:	00080a37          	lui	s4,0x80
ffffffffc02014b6:	0009b703          	ld	a4,0(s3)
ffffffffc02014ba:	40a48533          	sub	a0,s1,a0
ffffffffc02014be:	8519                	srai	a0,a0,0x6
ffffffffc02014c0:	9552                	add	a0,a0,s4
ffffffffc02014c2:	00c51793          	slli	a5,a0,0xc
ffffffffc02014c6:	4685                	li	a3,1
ffffffffc02014c8:	c094                	sw	a3,0(s1)
ffffffffc02014ca:	83b1                	srli	a5,a5,0xc
ffffffffc02014cc:	0532                	slli	a0,a0,0xc
ffffffffc02014ce:	0ee7f163          	bgeu	a5,a4,ffffffffc02015b0 <get_pte+0x20e>
ffffffffc02014d2:	000ab783          	ld	a5,0(s5)
ffffffffc02014d6:	6605                	lui	a2,0x1
ffffffffc02014d8:	4581                	li	a1,0
ffffffffc02014da:	953e                	add	a0,a0,a5
ffffffffc02014dc:	457090ef          	jal	ra,ffffffffc020b132 <memset>
ffffffffc02014e0:	000b3683          	ld	a3,0(s6)
ffffffffc02014e4:	40d486b3          	sub	a3,s1,a3
ffffffffc02014e8:	8699                	srai	a3,a3,0x6
ffffffffc02014ea:	96d2                	add	a3,a3,s4
ffffffffc02014ec:	06aa                	slli	a3,a3,0xa
ffffffffc02014ee:	0116e693          	ori	a3,a3,17
ffffffffc02014f2:	e014                	sd	a3,0(s0)
ffffffffc02014f4:	0009b703          	ld	a4,0(s3)
ffffffffc02014f8:	068a                	slli	a3,a3,0x2
ffffffffc02014fa:	757d                	lui	a0,0xfffff
ffffffffc02014fc:	8ee9                	and	a3,a3,a0
ffffffffc02014fe:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201502:	06e7f263          	bgeu	a5,a4,ffffffffc0201566 <get_pte+0x1c4>
ffffffffc0201506:	000ab503          	ld	a0,0(s5)
ffffffffc020150a:	00c95913          	srli	s2,s2,0xc
ffffffffc020150e:	1ff97913          	andi	s2,s2,511
ffffffffc0201512:	96aa                	add	a3,a3,a0
ffffffffc0201514:	00391513          	slli	a0,s2,0x3
ffffffffc0201518:	9536                	add	a0,a0,a3
ffffffffc020151a:	70e2                	ld	ra,56(sp)
ffffffffc020151c:	7442                	ld	s0,48(sp)
ffffffffc020151e:	74a2                	ld	s1,40(sp)
ffffffffc0201520:	7902                	ld	s2,32(sp)
ffffffffc0201522:	69e2                	ld	s3,24(sp)
ffffffffc0201524:	6a42                	ld	s4,16(sp)
ffffffffc0201526:	6aa2                	ld	s5,8(sp)
ffffffffc0201528:	6b02                	ld	s6,0(sp)
ffffffffc020152a:	6121                	addi	sp,sp,64
ffffffffc020152c:	8082                	ret
ffffffffc020152e:	4501                	li	a0,0
ffffffffc0201530:	b7ed                	j	ffffffffc020151a <get_pte+0x178>
ffffffffc0201532:	86fff0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0201536:	00095797          	auipc	a5,0x95
ffffffffc020153a:	3727b783          	ld	a5,882(a5) # ffffffffc02968a8 <pmm_manager>
ffffffffc020153e:	6f9c                	ld	a5,24(a5)
ffffffffc0201540:	4505                	li	a0,1
ffffffffc0201542:	9782                	jalr	a5
ffffffffc0201544:	842a                	mv	s0,a0
ffffffffc0201546:	855ff0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc020154a:	b56d                	j	ffffffffc02013f4 <get_pte+0x52>
ffffffffc020154c:	855ff0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0201550:	00095797          	auipc	a5,0x95
ffffffffc0201554:	3587b783          	ld	a5,856(a5) # ffffffffc02968a8 <pmm_manager>
ffffffffc0201558:	6f9c                	ld	a5,24(a5)
ffffffffc020155a:	4505                	li	a0,1
ffffffffc020155c:	9782                	jalr	a5
ffffffffc020155e:	84aa                	mv	s1,a0
ffffffffc0201560:	83bff0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0201564:	b781                	j	ffffffffc02014a4 <get_pte+0x102>
ffffffffc0201566:	0000b617          	auipc	a2,0xb
ffffffffc020156a:	cda60613          	addi	a2,a2,-806 # ffffffffc020c240 <commands+0x968>
ffffffffc020156e:	13200593          	li	a1,306
ffffffffc0201572:	0000b517          	auipc	a0,0xb
ffffffffc0201576:	cf650513          	addi	a0,a0,-778 # ffffffffc020c268 <commands+0x990>
ffffffffc020157a:	cb5fe0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020157e:	0000b617          	auipc	a2,0xb
ffffffffc0201582:	cc260613          	addi	a2,a2,-830 # ffffffffc020c240 <commands+0x968>
ffffffffc0201586:	12500593          	li	a1,293
ffffffffc020158a:	0000b517          	auipc	a0,0xb
ffffffffc020158e:	cde50513          	addi	a0,a0,-802 # ffffffffc020c268 <commands+0x990>
ffffffffc0201592:	c9dfe0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0201596:	86aa                	mv	a3,a0
ffffffffc0201598:	0000b617          	auipc	a2,0xb
ffffffffc020159c:	ca860613          	addi	a2,a2,-856 # ffffffffc020c240 <commands+0x968>
ffffffffc02015a0:	12100593          	li	a1,289
ffffffffc02015a4:	0000b517          	auipc	a0,0xb
ffffffffc02015a8:	cc450513          	addi	a0,a0,-828 # ffffffffc020c268 <commands+0x990>
ffffffffc02015ac:	c83fe0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02015b0:	86aa                	mv	a3,a0
ffffffffc02015b2:	0000b617          	auipc	a2,0xb
ffffffffc02015b6:	c8e60613          	addi	a2,a2,-882 # ffffffffc020c240 <commands+0x968>
ffffffffc02015ba:	12f00593          	li	a1,303
ffffffffc02015be:	0000b517          	auipc	a0,0xb
ffffffffc02015c2:	caa50513          	addi	a0,a0,-854 # ffffffffc020c268 <commands+0x990>
ffffffffc02015c6:	c69fe0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02015ca <boot_map_segment>:
ffffffffc02015ca:	6785                	lui	a5,0x1
ffffffffc02015cc:	7139                	addi	sp,sp,-64
ffffffffc02015ce:	00d5c833          	xor	a6,a1,a3
ffffffffc02015d2:	17fd                	addi	a5,a5,-1
ffffffffc02015d4:	fc06                	sd	ra,56(sp)
ffffffffc02015d6:	f822                	sd	s0,48(sp)
ffffffffc02015d8:	f426                	sd	s1,40(sp)
ffffffffc02015da:	f04a                	sd	s2,32(sp)
ffffffffc02015dc:	ec4e                	sd	s3,24(sp)
ffffffffc02015de:	e852                	sd	s4,16(sp)
ffffffffc02015e0:	e456                	sd	s5,8(sp)
ffffffffc02015e2:	00f87833          	and	a6,a6,a5
ffffffffc02015e6:	08081563          	bnez	a6,ffffffffc0201670 <boot_map_segment+0xa6>
ffffffffc02015ea:	00f5f4b3          	and	s1,a1,a5
ffffffffc02015ee:	963e                	add	a2,a2,a5
ffffffffc02015f0:	94b2                	add	s1,s1,a2
ffffffffc02015f2:	797d                	lui	s2,0xfffff
ffffffffc02015f4:	80b1                	srli	s1,s1,0xc
ffffffffc02015f6:	0125f5b3          	and	a1,a1,s2
ffffffffc02015fa:	0126f6b3          	and	a3,a3,s2
ffffffffc02015fe:	c0a1                	beqz	s1,ffffffffc020163e <boot_map_segment+0x74>
ffffffffc0201600:	00176713          	ori	a4,a4,1
ffffffffc0201604:	04b2                	slli	s1,s1,0xc
ffffffffc0201606:	02071993          	slli	s3,a4,0x20
ffffffffc020160a:	8a2a                	mv	s4,a0
ffffffffc020160c:	842e                	mv	s0,a1
ffffffffc020160e:	94ae                	add	s1,s1,a1
ffffffffc0201610:	40b68933          	sub	s2,a3,a1
ffffffffc0201614:	0209d993          	srli	s3,s3,0x20
ffffffffc0201618:	6a85                	lui	s5,0x1
ffffffffc020161a:	4605                	li	a2,1
ffffffffc020161c:	85a2                	mv	a1,s0
ffffffffc020161e:	8552                	mv	a0,s4
ffffffffc0201620:	d83ff0ef          	jal	ra,ffffffffc02013a2 <get_pte>
ffffffffc0201624:	008907b3          	add	a5,s2,s0
ffffffffc0201628:	c505                	beqz	a0,ffffffffc0201650 <boot_map_segment+0x86>
ffffffffc020162a:	83b1                	srli	a5,a5,0xc
ffffffffc020162c:	07aa                	slli	a5,a5,0xa
ffffffffc020162e:	0137e7b3          	or	a5,a5,s3
ffffffffc0201632:	0017e793          	ori	a5,a5,1
ffffffffc0201636:	e11c                	sd	a5,0(a0)
ffffffffc0201638:	9456                	add	s0,s0,s5
ffffffffc020163a:	fe8490e3          	bne	s1,s0,ffffffffc020161a <boot_map_segment+0x50>
ffffffffc020163e:	70e2                	ld	ra,56(sp)
ffffffffc0201640:	7442                	ld	s0,48(sp)
ffffffffc0201642:	74a2                	ld	s1,40(sp)
ffffffffc0201644:	7902                	ld	s2,32(sp)
ffffffffc0201646:	69e2                	ld	s3,24(sp)
ffffffffc0201648:	6a42                	ld	s4,16(sp)
ffffffffc020164a:	6aa2                	ld	s5,8(sp)
ffffffffc020164c:	6121                	addi	sp,sp,64
ffffffffc020164e:	8082                	ret
ffffffffc0201650:	0000b697          	auipc	a3,0xb
ffffffffc0201654:	c4068693          	addi	a3,a3,-960 # ffffffffc020c290 <commands+0x9b8>
ffffffffc0201658:	0000a617          	auipc	a2,0xa
ffffffffc020165c:	4d060613          	addi	a2,a2,1232 # ffffffffc020bb28 <commands+0x250>
ffffffffc0201660:	09c00593          	li	a1,156
ffffffffc0201664:	0000b517          	auipc	a0,0xb
ffffffffc0201668:	c0450513          	addi	a0,a0,-1020 # ffffffffc020c268 <commands+0x990>
ffffffffc020166c:	bc3fe0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0201670:	0000b697          	auipc	a3,0xb
ffffffffc0201674:	c0868693          	addi	a3,a3,-1016 # ffffffffc020c278 <commands+0x9a0>
ffffffffc0201678:	0000a617          	auipc	a2,0xa
ffffffffc020167c:	4b060613          	addi	a2,a2,1200 # ffffffffc020bb28 <commands+0x250>
ffffffffc0201680:	09500593          	li	a1,149
ffffffffc0201684:	0000b517          	auipc	a0,0xb
ffffffffc0201688:	be450513          	addi	a0,a0,-1052 # ffffffffc020c268 <commands+0x990>
ffffffffc020168c:	ba3fe0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0201690 <get_page>:
ffffffffc0201690:	1141                	addi	sp,sp,-16
ffffffffc0201692:	e022                	sd	s0,0(sp)
ffffffffc0201694:	8432                	mv	s0,a2
ffffffffc0201696:	4601                	li	a2,0
ffffffffc0201698:	e406                	sd	ra,8(sp)
ffffffffc020169a:	d09ff0ef          	jal	ra,ffffffffc02013a2 <get_pte>
ffffffffc020169e:	c011                	beqz	s0,ffffffffc02016a2 <get_page+0x12>
ffffffffc02016a0:	e008                	sd	a0,0(s0)
ffffffffc02016a2:	c511                	beqz	a0,ffffffffc02016ae <get_page+0x1e>
ffffffffc02016a4:	611c                	ld	a5,0(a0)
ffffffffc02016a6:	4501                	li	a0,0
ffffffffc02016a8:	0017f713          	andi	a4,a5,1
ffffffffc02016ac:	e709                	bnez	a4,ffffffffc02016b6 <get_page+0x26>
ffffffffc02016ae:	60a2                	ld	ra,8(sp)
ffffffffc02016b0:	6402                	ld	s0,0(sp)
ffffffffc02016b2:	0141                	addi	sp,sp,16
ffffffffc02016b4:	8082                	ret
ffffffffc02016b6:	078a                	slli	a5,a5,0x2
ffffffffc02016b8:	83b1                	srli	a5,a5,0xc
ffffffffc02016ba:	00095717          	auipc	a4,0x95
ffffffffc02016be:	1de73703          	ld	a4,478(a4) # ffffffffc0296898 <npage>
ffffffffc02016c2:	00e7ff63          	bgeu	a5,a4,ffffffffc02016e0 <get_page+0x50>
ffffffffc02016c6:	60a2                	ld	ra,8(sp)
ffffffffc02016c8:	6402                	ld	s0,0(sp)
ffffffffc02016ca:	fff80537          	lui	a0,0xfff80
ffffffffc02016ce:	97aa                	add	a5,a5,a0
ffffffffc02016d0:	079a                	slli	a5,a5,0x6
ffffffffc02016d2:	00095517          	auipc	a0,0x95
ffffffffc02016d6:	1ce53503          	ld	a0,462(a0) # ffffffffc02968a0 <pages>
ffffffffc02016da:	953e                	add	a0,a0,a5
ffffffffc02016dc:	0141                	addi	sp,sp,16
ffffffffc02016de:	8082                	ret
ffffffffc02016e0:	bd3ff0ef          	jal	ra,ffffffffc02012b2 <pa2page.part.0>

ffffffffc02016e4 <unmap_range>:
ffffffffc02016e4:	7159                	addi	sp,sp,-112
ffffffffc02016e6:	00c5e7b3          	or	a5,a1,a2
ffffffffc02016ea:	f486                	sd	ra,104(sp)
ffffffffc02016ec:	f0a2                	sd	s0,96(sp)
ffffffffc02016ee:	eca6                	sd	s1,88(sp)
ffffffffc02016f0:	e8ca                	sd	s2,80(sp)
ffffffffc02016f2:	e4ce                	sd	s3,72(sp)
ffffffffc02016f4:	e0d2                	sd	s4,64(sp)
ffffffffc02016f6:	fc56                	sd	s5,56(sp)
ffffffffc02016f8:	f85a                	sd	s6,48(sp)
ffffffffc02016fa:	f45e                	sd	s7,40(sp)
ffffffffc02016fc:	f062                	sd	s8,32(sp)
ffffffffc02016fe:	ec66                	sd	s9,24(sp)
ffffffffc0201700:	e86a                	sd	s10,16(sp)
ffffffffc0201702:	17d2                	slli	a5,a5,0x34
ffffffffc0201704:	e3ed                	bnez	a5,ffffffffc02017e6 <unmap_range+0x102>
ffffffffc0201706:	002007b7          	lui	a5,0x200
ffffffffc020170a:	842e                	mv	s0,a1
ffffffffc020170c:	0ef5ed63          	bltu	a1,a5,ffffffffc0201806 <unmap_range+0x122>
ffffffffc0201710:	8932                	mv	s2,a2
ffffffffc0201712:	0ec5fa63          	bgeu	a1,a2,ffffffffc0201806 <unmap_range+0x122>
ffffffffc0201716:	4785                	li	a5,1
ffffffffc0201718:	07fe                	slli	a5,a5,0x1f
ffffffffc020171a:	0ec7e663          	bltu	a5,a2,ffffffffc0201806 <unmap_range+0x122>
ffffffffc020171e:	89aa                	mv	s3,a0
ffffffffc0201720:	6a05                	lui	s4,0x1
ffffffffc0201722:	00095c97          	auipc	s9,0x95
ffffffffc0201726:	176c8c93          	addi	s9,s9,374 # ffffffffc0296898 <npage>
ffffffffc020172a:	00095c17          	auipc	s8,0x95
ffffffffc020172e:	176c0c13          	addi	s8,s8,374 # ffffffffc02968a0 <pages>
ffffffffc0201732:	fff80bb7          	lui	s7,0xfff80
ffffffffc0201736:	00095d17          	auipc	s10,0x95
ffffffffc020173a:	172d0d13          	addi	s10,s10,370 # ffffffffc02968a8 <pmm_manager>
ffffffffc020173e:	00200b37          	lui	s6,0x200
ffffffffc0201742:	ffe00ab7          	lui	s5,0xffe00
ffffffffc0201746:	4601                	li	a2,0
ffffffffc0201748:	85a2                	mv	a1,s0
ffffffffc020174a:	854e                	mv	a0,s3
ffffffffc020174c:	c57ff0ef          	jal	ra,ffffffffc02013a2 <get_pte>
ffffffffc0201750:	84aa                	mv	s1,a0
ffffffffc0201752:	cd29                	beqz	a0,ffffffffc02017ac <unmap_range+0xc8>
ffffffffc0201754:	611c                	ld	a5,0(a0)
ffffffffc0201756:	e395                	bnez	a5,ffffffffc020177a <unmap_range+0x96>
ffffffffc0201758:	9452                	add	s0,s0,s4
ffffffffc020175a:	ff2466e3          	bltu	s0,s2,ffffffffc0201746 <unmap_range+0x62>
ffffffffc020175e:	70a6                	ld	ra,104(sp)
ffffffffc0201760:	7406                	ld	s0,96(sp)
ffffffffc0201762:	64e6                	ld	s1,88(sp)
ffffffffc0201764:	6946                	ld	s2,80(sp)
ffffffffc0201766:	69a6                	ld	s3,72(sp)
ffffffffc0201768:	6a06                	ld	s4,64(sp)
ffffffffc020176a:	7ae2                	ld	s5,56(sp)
ffffffffc020176c:	7b42                	ld	s6,48(sp)
ffffffffc020176e:	7ba2                	ld	s7,40(sp)
ffffffffc0201770:	7c02                	ld	s8,32(sp)
ffffffffc0201772:	6ce2                	ld	s9,24(sp)
ffffffffc0201774:	6d42                	ld	s10,16(sp)
ffffffffc0201776:	6165                	addi	sp,sp,112
ffffffffc0201778:	8082                	ret
ffffffffc020177a:	0017f713          	andi	a4,a5,1
ffffffffc020177e:	df69                	beqz	a4,ffffffffc0201758 <unmap_range+0x74>
ffffffffc0201780:	000cb703          	ld	a4,0(s9)
ffffffffc0201784:	078a                	slli	a5,a5,0x2
ffffffffc0201786:	83b1                	srli	a5,a5,0xc
ffffffffc0201788:	08e7ff63          	bgeu	a5,a4,ffffffffc0201826 <unmap_range+0x142>
ffffffffc020178c:	000c3503          	ld	a0,0(s8)
ffffffffc0201790:	97de                	add	a5,a5,s7
ffffffffc0201792:	079a                	slli	a5,a5,0x6
ffffffffc0201794:	953e                	add	a0,a0,a5
ffffffffc0201796:	411c                	lw	a5,0(a0)
ffffffffc0201798:	fff7871b          	addiw	a4,a5,-1
ffffffffc020179c:	c118                	sw	a4,0(a0)
ffffffffc020179e:	cf11                	beqz	a4,ffffffffc02017ba <unmap_range+0xd6>
ffffffffc02017a0:	0004b023          	sd	zero,0(s1)
ffffffffc02017a4:	12040073          	sfence.vma	s0
ffffffffc02017a8:	9452                	add	s0,s0,s4
ffffffffc02017aa:	bf45                	j	ffffffffc020175a <unmap_range+0x76>
ffffffffc02017ac:	945a                	add	s0,s0,s6
ffffffffc02017ae:	01547433          	and	s0,s0,s5
ffffffffc02017b2:	d455                	beqz	s0,ffffffffc020175e <unmap_range+0x7a>
ffffffffc02017b4:	f92469e3          	bltu	s0,s2,ffffffffc0201746 <unmap_range+0x62>
ffffffffc02017b8:	b75d                	j	ffffffffc020175e <unmap_range+0x7a>
ffffffffc02017ba:	100027f3          	csrr	a5,sstatus
ffffffffc02017be:	8b89                	andi	a5,a5,2
ffffffffc02017c0:	e799                	bnez	a5,ffffffffc02017ce <unmap_range+0xea>
ffffffffc02017c2:	000d3783          	ld	a5,0(s10)
ffffffffc02017c6:	4585                	li	a1,1
ffffffffc02017c8:	739c                	ld	a5,32(a5)
ffffffffc02017ca:	9782                	jalr	a5
ffffffffc02017cc:	bfd1                	j	ffffffffc02017a0 <unmap_range+0xbc>
ffffffffc02017ce:	e42a                	sd	a0,8(sp)
ffffffffc02017d0:	dd0ff0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc02017d4:	000d3783          	ld	a5,0(s10)
ffffffffc02017d8:	6522                	ld	a0,8(sp)
ffffffffc02017da:	4585                	li	a1,1
ffffffffc02017dc:	739c                	ld	a5,32(a5)
ffffffffc02017de:	9782                	jalr	a5
ffffffffc02017e0:	dbaff0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc02017e4:	bf75                	j	ffffffffc02017a0 <unmap_range+0xbc>
ffffffffc02017e6:	0000b697          	auipc	a3,0xb
ffffffffc02017ea:	aba68693          	addi	a3,a3,-1350 # ffffffffc020c2a0 <commands+0x9c8>
ffffffffc02017ee:	0000a617          	auipc	a2,0xa
ffffffffc02017f2:	33a60613          	addi	a2,a2,826 # ffffffffc020bb28 <commands+0x250>
ffffffffc02017f6:	15a00593          	li	a1,346
ffffffffc02017fa:	0000b517          	auipc	a0,0xb
ffffffffc02017fe:	a6e50513          	addi	a0,a0,-1426 # ffffffffc020c268 <commands+0x990>
ffffffffc0201802:	a2dfe0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0201806:	0000b697          	auipc	a3,0xb
ffffffffc020180a:	aca68693          	addi	a3,a3,-1334 # ffffffffc020c2d0 <commands+0x9f8>
ffffffffc020180e:	0000a617          	auipc	a2,0xa
ffffffffc0201812:	31a60613          	addi	a2,a2,794 # ffffffffc020bb28 <commands+0x250>
ffffffffc0201816:	15b00593          	li	a1,347
ffffffffc020181a:	0000b517          	auipc	a0,0xb
ffffffffc020181e:	a4e50513          	addi	a0,a0,-1458 # ffffffffc020c268 <commands+0x990>
ffffffffc0201822:	a0dfe0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0201826:	a8dff0ef          	jal	ra,ffffffffc02012b2 <pa2page.part.0>

ffffffffc020182a <exit_range>:
ffffffffc020182a:	7119                	addi	sp,sp,-128
ffffffffc020182c:	00c5e7b3          	or	a5,a1,a2
ffffffffc0201830:	fc86                	sd	ra,120(sp)
ffffffffc0201832:	f8a2                	sd	s0,112(sp)
ffffffffc0201834:	f4a6                	sd	s1,104(sp)
ffffffffc0201836:	f0ca                	sd	s2,96(sp)
ffffffffc0201838:	ecce                	sd	s3,88(sp)
ffffffffc020183a:	e8d2                	sd	s4,80(sp)
ffffffffc020183c:	e4d6                	sd	s5,72(sp)
ffffffffc020183e:	e0da                	sd	s6,64(sp)
ffffffffc0201840:	fc5e                	sd	s7,56(sp)
ffffffffc0201842:	f862                	sd	s8,48(sp)
ffffffffc0201844:	f466                	sd	s9,40(sp)
ffffffffc0201846:	f06a                	sd	s10,32(sp)
ffffffffc0201848:	ec6e                	sd	s11,24(sp)
ffffffffc020184a:	17d2                	slli	a5,a5,0x34
ffffffffc020184c:	20079a63          	bnez	a5,ffffffffc0201a60 <exit_range+0x236>
ffffffffc0201850:	002007b7          	lui	a5,0x200
ffffffffc0201854:	24f5e463          	bltu	a1,a5,ffffffffc0201a9c <exit_range+0x272>
ffffffffc0201858:	8ab2                	mv	s5,a2
ffffffffc020185a:	24c5f163          	bgeu	a1,a2,ffffffffc0201a9c <exit_range+0x272>
ffffffffc020185e:	4785                	li	a5,1
ffffffffc0201860:	07fe                	slli	a5,a5,0x1f
ffffffffc0201862:	22c7ed63          	bltu	a5,a2,ffffffffc0201a9c <exit_range+0x272>
ffffffffc0201866:	c00009b7          	lui	s3,0xc0000
ffffffffc020186a:	0135f9b3          	and	s3,a1,s3
ffffffffc020186e:	ffe00937          	lui	s2,0xffe00
ffffffffc0201872:	400007b7          	lui	a5,0x40000
ffffffffc0201876:	5cfd                	li	s9,-1
ffffffffc0201878:	8c2a                	mv	s8,a0
ffffffffc020187a:	0125f933          	and	s2,a1,s2
ffffffffc020187e:	99be                	add	s3,s3,a5
ffffffffc0201880:	00095d17          	auipc	s10,0x95
ffffffffc0201884:	018d0d13          	addi	s10,s10,24 # ffffffffc0296898 <npage>
ffffffffc0201888:	00ccdc93          	srli	s9,s9,0xc
ffffffffc020188c:	00095717          	auipc	a4,0x95
ffffffffc0201890:	01470713          	addi	a4,a4,20 # ffffffffc02968a0 <pages>
ffffffffc0201894:	00095d97          	auipc	s11,0x95
ffffffffc0201898:	014d8d93          	addi	s11,s11,20 # ffffffffc02968a8 <pmm_manager>
ffffffffc020189c:	c0000437          	lui	s0,0xc0000
ffffffffc02018a0:	944e                	add	s0,s0,s3
ffffffffc02018a2:	8079                	srli	s0,s0,0x1e
ffffffffc02018a4:	1ff47413          	andi	s0,s0,511
ffffffffc02018a8:	040e                	slli	s0,s0,0x3
ffffffffc02018aa:	9462                	add	s0,s0,s8
ffffffffc02018ac:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_bin_sfs_img_size+0xffffffffbff8ad00>
ffffffffc02018b0:	001a7793          	andi	a5,s4,1
ffffffffc02018b4:	eb99                	bnez	a5,ffffffffc02018ca <exit_range+0xa0>
ffffffffc02018b6:	12098463          	beqz	s3,ffffffffc02019de <exit_range+0x1b4>
ffffffffc02018ba:	400007b7          	lui	a5,0x40000
ffffffffc02018be:	97ce                	add	a5,a5,s3
ffffffffc02018c0:	894e                	mv	s2,s3
ffffffffc02018c2:	1159fe63          	bgeu	s3,s5,ffffffffc02019de <exit_range+0x1b4>
ffffffffc02018c6:	89be                	mv	s3,a5
ffffffffc02018c8:	bfd1                	j	ffffffffc020189c <exit_range+0x72>
ffffffffc02018ca:	000d3783          	ld	a5,0(s10)
ffffffffc02018ce:	0a0a                	slli	s4,s4,0x2
ffffffffc02018d0:	00ca5a13          	srli	s4,s4,0xc
ffffffffc02018d4:	1cfa7263          	bgeu	s4,a5,ffffffffc0201a98 <exit_range+0x26e>
ffffffffc02018d8:	fff80637          	lui	a2,0xfff80
ffffffffc02018dc:	9652                	add	a2,a2,s4
ffffffffc02018de:	000806b7          	lui	a3,0x80
ffffffffc02018e2:	96b2                	add	a3,a3,a2
ffffffffc02018e4:	0196f5b3          	and	a1,a3,s9
ffffffffc02018e8:	061a                	slli	a2,a2,0x6
ffffffffc02018ea:	06b2                	slli	a3,a3,0xc
ffffffffc02018ec:	18f5fa63          	bgeu	a1,a5,ffffffffc0201a80 <exit_range+0x256>
ffffffffc02018f0:	00095817          	auipc	a6,0x95
ffffffffc02018f4:	fc080813          	addi	a6,a6,-64 # ffffffffc02968b0 <va_pa_offset>
ffffffffc02018f8:	00083b03          	ld	s6,0(a6)
ffffffffc02018fc:	4b85                	li	s7,1
ffffffffc02018fe:	fff80e37          	lui	t3,0xfff80
ffffffffc0201902:	9b36                	add	s6,s6,a3
ffffffffc0201904:	00080337          	lui	t1,0x80
ffffffffc0201908:	6885                	lui	a7,0x1
ffffffffc020190a:	a819                	j	ffffffffc0201920 <exit_range+0xf6>
ffffffffc020190c:	4b81                	li	s7,0
ffffffffc020190e:	002007b7          	lui	a5,0x200
ffffffffc0201912:	993e                	add	s2,s2,a5
ffffffffc0201914:	08090c63          	beqz	s2,ffffffffc02019ac <exit_range+0x182>
ffffffffc0201918:	09397a63          	bgeu	s2,s3,ffffffffc02019ac <exit_range+0x182>
ffffffffc020191c:	0f597063          	bgeu	s2,s5,ffffffffc02019fc <exit_range+0x1d2>
ffffffffc0201920:	01595493          	srli	s1,s2,0x15
ffffffffc0201924:	1ff4f493          	andi	s1,s1,511
ffffffffc0201928:	048e                	slli	s1,s1,0x3
ffffffffc020192a:	94da                	add	s1,s1,s6
ffffffffc020192c:	609c                	ld	a5,0(s1)
ffffffffc020192e:	0017f693          	andi	a3,a5,1
ffffffffc0201932:	dee9                	beqz	a3,ffffffffc020190c <exit_range+0xe2>
ffffffffc0201934:	000d3583          	ld	a1,0(s10)
ffffffffc0201938:	078a                	slli	a5,a5,0x2
ffffffffc020193a:	83b1                	srli	a5,a5,0xc
ffffffffc020193c:	14b7fe63          	bgeu	a5,a1,ffffffffc0201a98 <exit_range+0x26e>
ffffffffc0201940:	97f2                	add	a5,a5,t3
ffffffffc0201942:	006786b3          	add	a3,a5,t1
ffffffffc0201946:	0196feb3          	and	t4,a3,s9
ffffffffc020194a:	00679513          	slli	a0,a5,0x6
ffffffffc020194e:	06b2                	slli	a3,a3,0xc
ffffffffc0201950:	12bef863          	bgeu	t4,a1,ffffffffc0201a80 <exit_range+0x256>
ffffffffc0201954:	00083783          	ld	a5,0(a6)
ffffffffc0201958:	96be                	add	a3,a3,a5
ffffffffc020195a:	011685b3          	add	a1,a3,a7
ffffffffc020195e:	629c                	ld	a5,0(a3)
ffffffffc0201960:	8b85                	andi	a5,a5,1
ffffffffc0201962:	f7d5                	bnez	a5,ffffffffc020190e <exit_range+0xe4>
ffffffffc0201964:	06a1                	addi	a3,a3,8
ffffffffc0201966:	fed59ce3          	bne	a1,a3,ffffffffc020195e <exit_range+0x134>
ffffffffc020196a:	631c                	ld	a5,0(a4)
ffffffffc020196c:	953e                	add	a0,a0,a5
ffffffffc020196e:	100027f3          	csrr	a5,sstatus
ffffffffc0201972:	8b89                	andi	a5,a5,2
ffffffffc0201974:	e7d9                	bnez	a5,ffffffffc0201a02 <exit_range+0x1d8>
ffffffffc0201976:	000db783          	ld	a5,0(s11)
ffffffffc020197a:	4585                	li	a1,1
ffffffffc020197c:	e032                	sd	a2,0(sp)
ffffffffc020197e:	739c                	ld	a5,32(a5)
ffffffffc0201980:	9782                	jalr	a5
ffffffffc0201982:	6602                	ld	a2,0(sp)
ffffffffc0201984:	00095817          	auipc	a6,0x95
ffffffffc0201988:	f2c80813          	addi	a6,a6,-212 # ffffffffc02968b0 <va_pa_offset>
ffffffffc020198c:	fff80e37          	lui	t3,0xfff80
ffffffffc0201990:	00080337          	lui	t1,0x80
ffffffffc0201994:	6885                	lui	a7,0x1
ffffffffc0201996:	00095717          	auipc	a4,0x95
ffffffffc020199a:	f0a70713          	addi	a4,a4,-246 # ffffffffc02968a0 <pages>
ffffffffc020199e:	0004b023          	sd	zero,0(s1)
ffffffffc02019a2:	002007b7          	lui	a5,0x200
ffffffffc02019a6:	993e                	add	s2,s2,a5
ffffffffc02019a8:	f60918e3          	bnez	s2,ffffffffc0201918 <exit_range+0xee>
ffffffffc02019ac:	f00b85e3          	beqz	s7,ffffffffc02018b6 <exit_range+0x8c>
ffffffffc02019b0:	000d3783          	ld	a5,0(s10)
ffffffffc02019b4:	0efa7263          	bgeu	s4,a5,ffffffffc0201a98 <exit_range+0x26e>
ffffffffc02019b8:	6308                	ld	a0,0(a4)
ffffffffc02019ba:	9532                	add	a0,a0,a2
ffffffffc02019bc:	100027f3          	csrr	a5,sstatus
ffffffffc02019c0:	8b89                	andi	a5,a5,2
ffffffffc02019c2:	efad                	bnez	a5,ffffffffc0201a3c <exit_range+0x212>
ffffffffc02019c4:	000db783          	ld	a5,0(s11)
ffffffffc02019c8:	4585                	li	a1,1
ffffffffc02019ca:	739c                	ld	a5,32(a5)
ffffffffc02019cc:	9782                	jalr	a5
ffffffffc02019ce:	00095717          	auipc	a4,0x95
ffffffffc02019d2:	ed270713          	addi	a4,a4,-302 # ffffffffc02968a0 <pages>
ffffffffc02019d6:	00043023          	sd	zero,0(s0)
ffffffffc02019da:	ee0990e3          	bnez	s3,ffffffffc02018ba <exit_range+0x90>
ffffffffc02019de:	70e6                	ld	ra,120(sp)
ffffffffc02019e0:	7446                	ld	s0,112(sp)
ffffffffc02019e2:	74a6                	ld	s1,104(sp)
ffffffffc02019e4:	7906                	ld	s2,96(sp)
ffffffffc02019e6:	69e6                	ld	s3,88(sp)
ffffffffc02019e8:	6a46                	ld	s4,80(sp)
ffffffffc02019ea:	6aa6                	ld	s5,72(sp)
ffffffffc02019ec:	6b06                	ld	s6,64(sp)
ffffffffc02019ee:	7be2                	ld	s7,56(sp)
ffffffffc02019f0:	7c42                	ld	s8,48(sp)
ffffffffc02019f2:	7ca2                	ld	s9,40(sp)
ffffffffc02019f4:	7d02                	ld	s10,32(sp)
ffffffffc02019f6:	6de2                	ld	s11,24(sp)
ffffffffc02019f8:	6109                	addi	sp,sp,128
ffffffffc02019fa:	8082                	ret
ffffffffc02019fc:	ea0b8fe3          	beqz	s7,ffffffffc02018ba <exit_range+0x90>
ffffffffc0201a00:	bf45                	j	ffffffffc02019b0 <exit_range+0x186>
ffffffffc0201a02:	e032                	sd	a2,0(sp)
ffffffffc0201a04:	e42a                	sd	a0,8(sp)
ffffffffc0201a06:	b9aff0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0201a0a:	000db783          	ld	a5,0(s11)
ffffffffc0201a0e:	6522                	ld	a0,8(sp)
ffffffffc0201a10:	4585                	li	a1,1
ffffffffc0201a12:	739c                	ld	a5,32(a5)
ffffffffc0201a14:	9782                	jalr	a5
ffffffffc0201a16:	b84ff0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0201a1a:	6602                	ld	a2,0(sp)
ffffffffc0201a1c:	00095717          	auipc	a4,0x95
ffffffffc0201a20:	e8470713          	addi	a4,a4,-380 # ffffffffc02968a0 <pages>
ffffffffc0201a24:	6885                	lui	a7,0x1
ffffffffc0201a26:	00080337          	lui	t1,0x80
ffffffffc0201a2a:	fff80e37          	lui	t3,0xfff80
ffffffffc0201a2e:	00095817          	auipc	a6,0x95
ffffffffc0201a32:	e8280813          	addi	a6,a6,-382 # ffffffffc02968b0 <va_pa_offset>
ffffffffc0201a36:	0004b023          	sd	zero,0(s1)
ffffffffc0201a3a:	b7a5                	j	ffffffffc02019a2 <exit_range+0x178>
ffffffffc0201a3c:	e02a                	sd	a0,0(sp)
ffffffffc0201a3e:	b62ff0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0201a42:	000db783          	ld	a5,0(s11)
ffffffffc0201a46:	6502                	ld	a0,0(sp)
ffffffffc0201a48:	4585                	li	a1,1
ffffffffc0201a4a:	739c                	ld	a5,32(a5)
ffffffffc0201a4c:	9782                	jalr	a5
ffffffffc0201a4e:	b4cff0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0201a52:	00095717          	auipc	a4,0x95
ffffffffc0201a56:	e4e70713          	addi	a4,a4,-434 # ffffffffc02968a0 <pages>
ffffffffc0201a5a:	00043023          	sd	zero,0(s0)
ffffffffc0201a5e:	bfb5                	j	ffffffffc02019da <exit_range+0x1b0>
ffffffffc0201a60:	0000b697          	auipc	a3,0xb
ffffffffc0201a64:	84068693          	addi	a3,a3,-1984 # ffffffffc020c2a0 <commands+0x9c8>
ffffffffc0201a68:	0000a617          	auipc	a2,0xa
ffffffffc0201a6c:	0c060613          	addi	a2,a2,192 # ffffffffc020bb28 <commands+0x250>
ffffffffc0201a70:	16f00593          	li	a1,367
ffffffffc0201a74:	0000a517          	auipc	a0,0xa
ffffffffc0201a78:	7f450513          	addi	a0,a0,2036 # ffffffffc020c268 <commands+0x990>
ffffffffc0201a7c:	fb2fe0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0201a80:	0000a617          	auipc	a2,0xa
ffffffffc0201a84:	7c060613          	addi	a2,a2,1984 # ffffffffc020c240 <commands+0x968>
ffffffffc0201a88:	07100593          	li	a1,113
ffffffffc0201a8c:	0000a517          	auipc	a0,0xa
ffffffffc0201a90:	77c50513          	addi	a0,a0,1916 # ffffffffc020c208 <commands+0x930>
ffffffffc0201a94:	f9afe0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0201a98:	81bff0ef          	jal	ra,ffffffffc02012b2 <pa2page.part.0>
ffffffffc0201a9c:	0000b697          	auipc	a3,0xb
ffffffffc0201aa0:	83468693          	addi	a3,a3,-1996 # ffffffffc020c2d0 <commands+0x9f8>
ffffffffc0201aa4:	0000a617          	auipc	a2,0xa
ffffffffc0201aa8:	08460613          	addi	a2,a2,132 # ffffffffc020bb28 <commands+0x250>
ffffffffc0201aac:	17000593          	li	a1,368
ffffffffc0201ab0:	0000a517          	auipc	a0,0xa
ffffffffc0201ab4:	7b850513          	addi	a0,a0,1976 # ffffffffc020c268 <commands+0x990>
ffffffffc0201ab8:	f76fe0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0201abc <page_remove>:
ffffffffc0201abc:	7179                	addi	sp,sp,-48
ffffffffc0201abe:	4601                	li	a2,0
ffffffffc0201ac0:	ec26                	sd	s1,24(sp)
ffffffffc0201ac2:	f406                	sd	ra,40(sp)
ffffffffc0201ac4:	f022                	sd	s0,32(sp)
ffffffffc0201ac6:	84ae                	mv	s1,a1
ffffffffc0201ac8:	8dbff0ef          	jal	ra,ffffffffc02013a2 <get_pte>
ffffffffc0201acc:	c511                	beqz	a0,ffffffffc0201ad8 <page_remove+0x1c>
ffffffffc0201ace:	611c                	ld	a5,0(a0)
ffffffffc0201ad0:	842a                	mv	s0,a0
ffffffffc0201ad2:	0017f713          	andi	a4,a5,1
ffffffffc0201ad6:	e711                	bnez	a4,ffffffffc0201ae2 <page_remove+0x26>
ffffffffc0201ad8:	70a2                	ld	ra,40(sp)
ffffffffc0201ada:	7402                	ld	s0,32(sp)
ffffffffc0201adc:	64e2                	ld	s1,24(sp)
ffffffffc0201ade:	6145                	addi	sp,sp,48
ffffffffc0201ae0:	8082                	ret
ffffffffc0201ae2:	078a                	slli	a5,a5,0x2
ffffffffc0201ae4:	83b1                	srli	a5,a5,0xc
ffffffffc0201ae6:	00095717          	auipc	a4,0x95
ffffffffc0201aea:	db273703          	ld	a4,-590(a4) # ffffffffc0296898 <npage>
ffffffffc0201aee:	06e7f363          	bgeu	a5,a4,ffffffffc0201b54 <page_remove+0x98>
ffffffffc0201af2:	fff80537          	lui	a0,0xfff80
ffffffffc0201af6:	97aa                	add	a5,a5,a0
ffffffffc0201af8:	079a                	slli	a5,a5,0x6
ffffffffc0201afa:	00095517          	auipc	a0,0x95
ffffffffc0201afe:	da653503          	ld	a0,-602(a0) # ffffffffc02968a0 <pages>
ffffffffc0201b02:	953e                	add	a0,a0,a5
ffffffffc0201b04:	411c                	lw	a5,0(a0)
ffffffffc0201b06:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201b0a:	c118                	sw	a4,0(a0)
ffffffffc0201b0c:	cb11                	beqz	a4,ffffffffc0201b20 <page_remove+0x64>
ffffffffc0201b0e:	00043023          	sd	zero,0(s0)
ffffffffc0201b12:	12048073          	sfence.vma	s1
ffffffffc0201b16:	70a2                	ld	ra,40(sp)
ffffffffc0201b18:	7402                	ld	s0,32(sp)
ffffffffc0201b1a:	64e2                	ld	s1,24(sp)
ffffffffc0201b1c:	6145                	addi	sp,sp,48
ffffffffc0201b1e:	8082                	ret
ffffffffc0201b20:	100027f3          	csrr	a5,sstatus
ffffffffc0201b24:	8b89                	andi	a5,a5,2
ffffffffc0201b26:	eb89                	bnez	a5,ffffffffc0201b38 <page_remove+0x7c>
ffffffffc0201b28:	00095797          	auipc	a5,0x95
ffffffffc0201b2c:	d807b783          	ld	a5,-640(a5) # ffffffffc02968a8 <pmm_manager>
ffffffffc0201b30:	739c                	ld	a5,32(a5)
ffffffffc0201b32:	4585                	li	a1,1
ffffffffc0201b34:	9782                	jalr	a5
ffffffffc0201b36:	bfe1                	j	ffffffffc0201b0e <page_remove+0x52>
ffffffffc0201b38:	e42a                	sd	a0,8(sp)
ffffffffc0201b3a:	a66ff0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0201b3e:	00095797          	auipc	a5,0x95
ffffffffc0201b42:	d6a7b783          	ld	a5,-662(a5) # ffffffffc02968a8 <pmm_manager>
ffffffffc0201b46:	739c                	ld	a5,32(a5)
ffffffffc0201b48:	6522                	ld	a0,8(sp)
ffffffffc0201b4a:	4585                	li	a1,1
ffffffffc0201b4c:	9782                	jalr	a5
ffffffffc0201b4e:	a4cff0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0201b52:	bf75                	j	ffffffffc0201b0e <page_remove+0x52>
ffffffffc0201b54:	f5eff0ef          	jal	ra,ffffffffc02012b2 <pa2page.part.0>

ffffffffc0201b58 <page_insert>:
ffffffffc0201b58:	7139                	addi	sp,sp,-64
ffffffffc0201b5a:	e852                	sd	s4,16(sp)
ffffffffc0201b5c:	8a32                	mv	s4,a2
ffffffffc0201b5e:	f822                	sd	s0,48(sp)
ffffffffc0201b60:	4605                	li	a2,1
ffffffffc0201b62:	842e                	mv	s0,a1
ffffffffc0201b64:	85d2                	mv	a1,s4
ffffffffc0201b66:	f426                	sd	s1,40(sp)
ffffffffc0201b68:	fc06                	sd	ra,56(sp)
ffffffffc0201b6a:	f04a                	sd	s2,32(sp)
ffffffffc0201b6c:	ec4e                	sd	s3,24(sp)
ffffffffc0201b6e:	e456                	sd	s5,8(sp)
ffffffffc0201b70:	84b6                	mv	s1,a3
ffffffffc0201b72:	831ff0ef          	jal	ra,ffffffffc02013a2 <get_pte>
ffffffffc0201b76:	c961                	beqz	a0,ffffffffc0201c46 <page_insert+0xee>
ffffffffc0201b78:	4014                	lw	a3,0(s0)
ffffffffc0201b7a:	611c                	ld	a5,0(a0)
ffffffffc0201b7c:	89aa                	mv	s3,a0
ffffffffc0201b7e:	0016871b          	addiw	a4,a3,1
ffffffffc0201b82:	c018                	sw	a4,0(s0)
ffffffffc0201b84:	0017f713          	andi	a4,a5,1
ffffffffc0201b88:	ef05                	bnez	a4,ffffffffc0201bc0 <page_insert+0x68>
ffffffffc0201b8a:	00095717          	auipc	a4,0x95
ffffffffc0201b8e:	d1673703          	ld	a4,-746(a4) # ffffffffc02968a0 <pages>
ffffffffc0201b92:	8c19                	sub	s0,s0,a4
ffffffffc0201b94:	000807b7          	lui	a5,0x80
ffffffffc0201b98:	8419                	srai	s0,s0,0x6
ffffffffc0201b9a:	943e                	add	s0,s0,a5
ffffffffc0201b9c:	042a                	slli	s0,s0,0xa
ffffffffc0201b9e:	8cc1                	or	s1,s1,s0
ffffffffc0201ba0:	0014e493          	ori	s1,s1,1
ffffffffc0201ba4:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_bin_sfs_img_size+0xffffffffbff8ad00>
ffffffffc0201ba8:	120a0073          	sfence.vma	s4
ffffffffc0201bac:	4501                	li	a0,0
ffffffffc0201bae:	70e2                	ld	ra,56(sp)
ffffffffc0201bb0:	7442                	ld	s0,48(sp)
ffffffffc0201bb2:	74a2                	ld	s1,40(sp)
ffffffffc0201bb4:	7902                	ld	s2,32(sp)
ffffffffc0201bb6:	69e2                	ld	s3,24(sp)
ffffffffc0201bb8:	6a42                	ld	s4,16(sp)
ffffffffc0201bba:	6aa2                	ld	s5,8(sp)
ffffffffc0201bbc:	6121                	addi	sp,sp,64
ffffffffc0201bbe:	8082                	ret
ffffffffc0201bc0:	078a                	slli	a5,a5,0x2
ffffffffc0201bc2:	83b1                	srli	a5,a5,0xc
ffffffffc0201bc4:	00095717          	auipc	a4,0x95
ffffffffc0201bc8:	cd473703          	ld	a4,-812(a4) # ffffffffc0296898 <npage>
ffffffffc0201bcc:	06e7ff63          	bgeu	a5,a4,ffffffffc0201c4a <page_insert+0xf2>
ffffffffc0201bd0:	00095a97          	auipc	s5,0x95
ffffffffc0201bd4:	cd0a8a93          	addi	s5,s5,-816 # ffffffffc02968a0 <pages>
ffffffffc0201bd8:	000ab703          	ld	a4,0(s5)
ffffffffc0201bdc:	fff80937          	lui	s2,0xfff80
ffffffffc0201be0:	993e                	add	s2,s2,a5
ffffffffc0201be2:	091a                	slli	s2,s2,0x6
ffffffffc0201be4:	993a                	add	s2,s2,a4
ffffffffc0201be6:	01240c63          	beq	s0,s2,ffffffffc0201bfe <page_insert+0xa6>
ffffffffc0201bea:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fce96f0>
ffffffffc0201bee:	fff7869b          	addiw	a3,a5,-1
ffffffffc0201bf2:	00d92023          	sw	a3,0(s2)
ffffffffc0201bf6:	c691                	beqz	a3,ffffffffc0201c02 <page_insert+0xaa>
ffffffffc0201bf8:	120a0073          	sfence.vma	s4
ffffffffc0201bfc:	bf59                	j	ffffffffc0201b92 <page_insert+0x3a>
ffffffffc0201bfe:	c014                	sw	a3,0(s0)
ffffffffc0201c00:	bf49                	j	ffffffffc0201b92 <page_insert+0x3a>
ffffffffc0201c02:	100027f3          	csrr	a5,sstatus
ffffffffc0201c06:	8b89                	andi	a5,a5,2
ffffffffc0201c08:	ef91                	bnez	a5,ffffffffc0201c24 <page_insert+0xcc>
ffffffffc0201c0a:	00095797          	auipc	a5,0x95
ffffffffc0201c0e:	c9e7b783          	ld	a5,-866(a5) # ffffffffc02968a8 <pmm_manager>
ffffffffc0201c12:	739c                	ld	a5,32(a5)
ffffffffc0201c14:	4585                	li	a1,1
ffffffffc0201c16:	854a                	mv	a0,s2
ffffffffc0201c18:	9782                	jalr	a5
ffffffffc0201c1a:	000ab703          	ld	a4,0(s5)
ffffffffc0201c1e:	120a0073          	sfence.vma	s4
ffffffffc0201c22:	bf85                	j	ffffffffc0201b92 <page_insert+0x3a>
ffffffffc0201c24:	97cff0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0201c28:	00095797          	auipc	a5,0x95
ffffffffc0201c2c:	c807b783          	ld	a5,-896(a5) # ffffffffc02968a8 <pmm_manager>
ffffffffc0201c30:	739c                	ld	a5,32(a5)
ffffffffc0201c32:	4585                	li	a1,1
ffffffffc0201c34:	854a                	mv	a0,s2
ffffffffc0201c36:	9782                	jalr	a5
ffffffffc0201c38:	962ff0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0201c3c:	000ab703          	ld	a4,0(s5)
ffffffffc0201c40:	120a0073          	sfence.vma	s4
ffffffffc0201c44:	b7b9                	j	ffffffffc0201b92 <page_insert+0x3a>
ffffffffc0201c46:	5571                	li	a0,-4
ffffffffc0201c48:	b79d                	j	ffffffffc0201bae <page_insert+0x56>
ffffffffc0201c4a:	e68ff0ef          	jal	ra,ffffffffc02012b2 <pa2page.part.0>

ffffffffc0201c4e <pmm_init>:
ffffffffc0201c4e:	0000b797          	auipc	a5,0xb
ffffffffc0201c52:	3aa78793          	addi	a5,a5,938 # ffffffffc020cff8 <default_pmm_manager>
ffffffffc0201c56:	638c                	ld	a1,0(a5)
ffffffffc0201c58:	7159                	addi	sp,sp,-112
ffffffffc0201c5a:	f85a                	sd	s6,48(sp)
ffffffffc0201c5c:	0000a517          	auipc	a0,0xa
ffffffffc0201c60:	68c50513          	addi	a0,a0,1676 # ffffffffc020c2e8 <commands+0xa10>
ffffffffc0201c64:	00095b17          	auipc	s6,0x95
ffffffffc0201c68:	c44b0b13          	addi	s6,s6,-956 # ffffffffc02968a8 <pmm_manager>
ffffffffc0201c6c:	f486                	sd	ra,104(sp)
ffffffffc0201c6e:	e8ca                	sd	s2,80(sp)
ffffffffc0201c70:	e4ce                	sd	s3,72(sp)
ffffffffc0201c72:	f0a2                	sd	s0,96(sp)
ffffffffc0201c74:	eca6                	sd	s1,88(sp)
ffffffffc0201c76:	e0d2                	sd	s4,64(sp)
ffffffffc0201c78:	fc56                	sd	s5,56(sp)
ffffffffc0201c7a:	f45e                	sd	s7,40(sp)
ffffffffc0201c7c:	f062                	sd	s8,32(sp)
ffffffffc0201c7e:	ec66                	sd	s9,24(sp)
ffffffffc0201c80:	00fb3023          	sd	a5,0(s6)
ffffffffc0201c84:	ca6fe0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0201c88:	000b3783          	ld	a5,0(s6)
ffffffffc0201c8c:	00095997          	auipc	s3,0x95
ffffffffc0201c90:	c2498993          	addi	s3,s3,-988 # ffffffffc02968b0 <va_pa_offset>
ffffffffc0201c94:	679c                	ld	a5,8(a5)
ffffffffc0201c96:	9782                	jalr	a5
ffffffffc0201c98:	57f5                	li	a5,-3
ffffffffc0201c9a:	07fa                	slli	a5,a5,0x1e
ffffffffc0201c9c:	00f9b023          	sd	a5,0(s3)
ffffffffc0201ca0:	c49fe0ef          	jal	ra,ffffffffc02008e8 <get_memory_base>
ffffffffc0201ca4:	892a                	mv	s2,a0
ffffffffc0201ca6:	c4dfe0ef          	jal	ra,ffffffffc02008f2 <get_memory_size>
ffffffffc0201caa:	280502e3          	beqz	a0,ffffffffc020272e <pmm_init+0xae0>
ffffffffc0201cae:	84aa                	mv	s1,a0
ffffffffc0201cb0:	0000a517          	auipc	a0,0xa
ffffffffc0201cb4:	67050513          	addi	a0,a0,1648 # ffffffffc020c320 <commands+0xa48>
ffffffffc0201cb8:	c72fe0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0201cbc:	00990433          	add	s0,s2,s1
ffffffffc0201cc0:	fff40693          	addi	a3,s0,-1
ffffffffc0201cc4:	864a                	mv	a2,s2
ffffffffc0201cc6:	85a6                	mv	a1,s1
ffffffffc0201cc8:	0000a517          	auipc	a0,0xa
ffffffffc0201ccc:	67050513          	addi	a0,a0,1648 # ffffffffc020c338 <commands+0xa60>
ffffffffc0201cd0:	c5afe0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0201cd4:	c8000737          	lui	a4,0xc8000
ffffffffc0201cd8:	87a2                	mv	a5,s0
ffffffffc0201cda:	5e876e63          	bltu	a4,s0,ffffffffc02022d6 <pmm_init+0x688>
ffffffffc0201cde:	757d                	lui	a0,0xfffff
ffffffffc0201ce0:	00096617          	auipc	a2,0x96
ffffffffc0201ce4:	c2f60613          	addi	a2,a2,-977 # ffffffffc029790f <end+0xfff>
ffffffffc0201ce8:	8e69                	and	a2,a2,a0
ffffffffc0201cea:	00095497          	auipc	s1,0x95
ffffffffc0201cee:	bae48493          	addi	s1,s1,-1106 # ffffffffc0296898 <npage>
ffffffffc0201cf2:	00c7d513          	srli	a0,a5,0xc
ffffffffc0201cf6:	00095b97          	auipc	s7,0x95
ffffffffc0201cfa:	baab8b93          	addi	s7,s7,-1110 # ffffffffc02968a0 <pages>
ffffffffc0201cfe:	e088                	sd	a0,0(s1)
ffffffffc0201d00:	00cbb023          	sd	a2,0(s7)
ffffffffc0201d04:	000807b7          	lui	a5,0x80
ffffffffc0201d08:	86b2                	mv	a3,a2
ffffffffc0201d0a:	02f50863          	beq	a0,a5,ffffffffc0201d3a <pmm_init+0xec>
ffffffffc0201d0e:	4781                	li	a5,0
ffffffffc0201d10:	4585                	li	a1,1
ffffffffc0201d12:	fff806b7          	lui	a3,0xfff80
ffffffffc0201d16:	00679513          	slli	a0,a5,0x6
ffffffffc0201d1a:	9532                	add	a0,a0,a2
ffffffffc0201d1c:	00850713          	addi	a4,a0,8 # fffffffffffff008 <end+0x3fd686f8>
ffffffffc0201d20:	40b7302f          	amoor.d	zero,a1,(a4)
ffffffffc0201d24:	6088                	ld	a0,0(s1)
ffffffffc0201d26:	0785                	addi	a5,a5,1
ffffffffc0201d28:	000bb603          	ld	a2,0(s7)
ffffffffc0201d2c:	00d50733          	add	a4,a0,a3
ffffffffc0201d30:	fee7e3e3          	bltu	a5,a4,ffffffffc0201d16 <pmm_init+0xc8>
ffffffffc0201d34:	071a                	slli	a4,a4,0x6
ffffffffc0201d36:	00e606b3          	add	a3,a2,a4
ffffffffc0201d3a:	c02007b7          	lui	a5,0xc0200
ffffffffc0201d3e:	3af6eae3          	bltu	a3,a5,ffffffffc02028f2 <pmm_init+0xca4>
ffffffffc0201d42:	0009b583          	ld	a1,0(s3)
ffffffffc0201d46:	77fd                	lui	a5,0xfffff
ffffffffc0201d48:	8c7d                	and	s0,s0,a5
ffffffffc0201d4a:	8e8d                	sub	a3,a3,a1
ffffffffc0201d4c:	5e86e363          	bltu	a3,s0,ffffffffc0202332 <pmm_init+0x6e4>
ffffffffc0201d50:	0000a517          	auipc	a0,0xa
ffffffffc0201d54:	63850513          	addi	a0,a0,1592 # ffffffffc020c388 <commands+0xab0>
ffffffffc0201d58:	bd2fe0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0201d5c:	000b3783          	ld	a5,0(s6)
ffffffffc0201d60:	7b9c                	ld	a5,48(a5)
ffffffffc0201d62:	9782                	jalr	a5
ffffffffc0201d64:	0000a517          	auipc	a0,0xa
ffffffffc0201d68:	63c50513          	addi	a0,a0,1596 # ffffffffc020c3a0 <commands+0xac8>
ffffffffc0201d6c:	bbefe0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0201d70:	100027f3          	csrr	a5,sstatus
ffffffffc0201d74:	8b89                	andi	a5,a5,2
ffffffffc0201d76:	5a079363          	bnez	a5,ffffffffc020231c <pmm_init+0x6ce>
ffffffffc0201d7a:	000b3783          	ld	a5,0(s6)
ffffffffc0201d7e:	4505                	li	a0,1
ffffffffc0201d80:	6f9c                	ld	a5,24(a5)
ffffffffc0201d82:	9782                	jalr	a5
ffffffffc0201d84:	842a                	mv	s0,a0
ffffffffc0201d86:	180408e3          	beqz	s0,ffffffffc0202716 <pmm_init+0xac8>
ffffffffc0201d8a:	000bb683          	ld	a3,0(s7)
ffffffffc0201d8e:	5a7d                	li	s4,-1
ffffffffc0201d90:	6098                	ld	a4,0(s1)
ffffffffc0201d92:	40d406b3          	sub	a3,s0,a3
ffffffffc0201d96:	8699                	srai	a3,a3,0x6
ffffffffc0201d98:	00080437          	lui	s0,0x80
ffffffffc0201d9c:	96a2                	add	a3,a3,s0
ffffffffc0201d9e:	00ca5793          	srli	a5,s4,0xc
ffffffffc0201da2:	8ff5                	and	a5,a5,a3
ffffffffc0201da4:	06b2                	slli	a3,a3,0xc
ffffffffc0201da6:	30e7fde3          	bgeu	a5,a4,ffffffffc02028c0 <pmm_init+0xc72>
ffffffffc0201daa:	0009b403          	ld	s0,0(s3)
ffffffffc0201dae:	6605                	lui	a2,0x1
ffffffffc0201db0:	4581                	li	a1,0
ffffffffc0201db2:	9436                	add	s0,s0,a3
ffffffffc0201db4:	8522                	mv	a0,s0
ffffffffc0201db6:	37c090ef          	jal	ra,ffffffffc020b132 <memset>
ffffffffc0201dba:	0009b683          	ld	a3,0(s3)
ffffffffc0201dbe:	77fd                	lui	a5,0xfffff
ffffffffc0201dc0:	0000b917          	auipc	s2,0xb
ffffffffc0201dc4:	86d90913          	addi	s2,s2,-1939 # ffffffffc020c62d <commands+0xd55>
ffffffffc0201dc8:	00f97933          	and	s2,s2,a5
ffffffffc0201dcc:	c0200ab7          	lui	s5,0xc0200
ffffffffc0201dd0:	3fe00637          	lui	a2,0x3fe00
ffffffffc0201dd4:	964a                	add	a2,a2,s2
ffffffffc0201dd6:	4729                	li	a4,10
ffffffffc0201dd8:	40da86b3          	sub	a3,s5,a3
ffffffffc0201ddc:	c02005b7          	lui	a1,0xc0200
ffffffffc0201de0:	8522                	mv	a0,s0
ffffffffc0201de2:	fe8ff0ef          	jal	ra,ffffffffc02015ca <boot_map_segment>
ffffffffc0201de6:	c8000637          	lui	a2,0xc8000
ffffffffc0201dea:	41260633          	sub	a2,a2,s2
ffffffffc0201dee:	3f596ce3          	bltu	s2,s5,ffffffffc02029e6 <pmm_init+0xd98>
ffffffffc0201df2:	0009b683          	ld	a3,0(s3)
ffffffffc0201df6:	85ca                	mv	a1,s2
ffffffffc0201df8:	4719                	li	a4,6
ffffffffc0201dfa:	40d906b3          	sub	a3,s2,a3
ffffffffc0201dfe:	8522                	mv	a0,s0
ffffffffc0201e00:	00095917          	auipc	s2,0x95
ffffffffc0201e04:	a9090913          	addi	s2,s2,-1392 # ffffffffc0296890 <boot_pgdir_va>
ffffffffc0201e08:	fc2ff0ef          	jal	ra,ffffffffc02015ca <boot_map_segment>
ffffffffc0201e0c:	00893023          	sd	s0,0(s2)
ffffffffc0201e10:	2d5464e3          	bltu	s0,s5,ffffffffc02028d8 <pmm_init+0xc8a>
ffffffffc0201e14:	0009b783          	ld	a5,0(s3)
ffffffffc0201e18:	1a7e                	slli	s4,s4,0x3f
ffffffffc0201e1a:	8c1d                	sub	s0,s0,a5
ffffffffc0201e1c:	00c45793          	srli	a5,s0,0xc
ffffffffc0201e20:	00095717          	auipc	a4,0x95
ffffffffc0201e24:	a6873423          	sd	s0,-1432(a4) # ffffffffc0296888 <boot_pgdir_pa>
ffffffffc0201e28:	0147ea33          	or	s4,a5,s4
ffffffffc0201e2c:	180a1073          	csrw	satp,s4
ffffffffc0201e30:	12000073          	sfence.vma
ffffffffc0201e34:	0000a517          	auipc	a0,0xa
ffffffffc0201e38:	5ac50513          	addi	a0,a0,1452 # ffffffffc020c3e0 <commands+0xb08>
ffffffffc0201e3c:	aeefe0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0201e40:	0000f717          	auipc	a4,0xf
ffffffffc0201e44:	1c070713          	addi	a4,a4,448 # ffffffffc0211000 <bootstack>
ffffffffc0201e48:	0000f797          	auipc	a5,0xf
ffffffffc0201e4c:	1b878793          	addi	a5,a5,440 # ffffffffc0211000 <bootstack>
ffffffffc0201e50:	5cf70d63          	beq	a4,a5,ffffffffc020242a <pmm_init+0x7dc>
ffffffffc0201e54:	100027f3          	csrr	a5,sstatus
ffffffffc0201e58:	8b89                	andi	a5,a5,2
ffffffffc0201e5a:	4a079763          	bnez	a5,ffffffffc0202308 <pmm_init+0x6ba>
ffffffffc0201e5e:	000b3783          	ld	a5,0(s6)
ffffffffc0201e62:	779c                	ld	a5,40(a5)
ffffffffc0201e64:	9782                	jalr	a5
ffffffffc0201e66:	842a                	mv	s0,a0
ffffffffc0201e68:	6098                	ld	a4,0(s1)
ffffffffc0201e6a:	c80007b7          	lui	a5,0xc8000
ffffffffc0201e6e:	83b1                	srli	a5,a5,0xc
ffffffffc0201e70:	08e7e3e3          	bltu	a5,a4,ffffffffc02026f6 <pmm_init+0xaa8>
ffffffffc0201e74:	00093503          	ld	a0,0(s2)
ffffffffc0201e78:	04050fe3          	beqz	a0,ffffffffc02026d6 <pmm_init+0xa88>
ffffffffc0201e7c:	03451793          	slli	a5,a0,0x34
ffffffffc0201e80:	04079be3          	bnez	a5,ffffffffc02026d6 <pmm_init+0xa88>
ffffffffc0201e84:	4601                	li	a2,0
ffffffffc0201e86:	4581                	li	a1,0
ffffffffc0201e88:	809ff0ef          	jal	ra,ffffffffc0201690 <get_page>
ffffffffc0201e8c:	2e0511e3          	bnez	a0,ffffffffc020296e <pmm_init+0xd20>
ffffffffc0201e90:	100027f3          	csrr	a5,sstatus
ffffffffc0201e94:	8b89                	andi	a5,a5,2
ffffffffc0201e96:	44079e63          	bnez	a5,ffffffffc02022f2 <pmm_init+0x6a4>
ffffffffc0201e9a:	000b3783          	ld	a5,0(s6)
ffffffffc0201e9e:	4505                	li	a0,1
ffffffffc0201ea0:	6f9c                	ld	a5,24(a5)
ffffffffc0201ea2:	9782                	jalr	a5
ffffffffc0201ea4:	8a2a                	mv	s4,a0
ffffffffc0201ea6:	00093503          	ld	a0,0(s2)
ffffffffc0201eaa:	4681                	li	a3,0
ffffffffc0201eac:	4601                	li	a2,0
ffffffffc0201eae:	85d2                	mv	a1,s4
ffffffffc0201eb0:	ca9ff0ef          	jal	ra,ffffffffc0201b58 <page_insert>
ffffffffc0201eb4:	26051be3          	bnez	a0,ffffffffc020292a <pmm_init+0xcdc>
ffffffffc0201eb8:	00093503          	ld	a0,0(s2)
ffffffffc0201ebc:	4601                	li	a2,0
ffffffffc0201ebe:	4581                	li	a1,0
ffffffffc0201ec0:	ce2ff0ef          	jal	ra,ffffffffc02013a2 <get_pte>
ffffffffc0201ec4:	280505e3          	beqz	a0,ffffffffc020294e <pmm_init+0xd00>
ffffffffc0201ec8:	611c                	ld	a5,0(a0)
ffffffffc0201eca:	0017f713          	andi	a4,a5,1
ffffffffc0201ece:	26070ee3          	beqz	a4,ffffffffc020294a <pmm_init+0xcfc>
ffffffffc0201ed2:	6098                	ld	a4,0(s1)
ffffffffc0201ed4:	078a                	slli	a5,a5,0x2
ffffffffc0201ed6:	83b1                	srli	a5,a5,0xc
ffffffffc0201ed8:	62e7f363          	bgeu	a5,a4,ffffffffc02024fe <pmm_init+0x8b0>
ffffffffc0201edc:	000bb683          	ld	a3,0(s7)
ffffffffc0201ee0:	fff80637          	lui	a2,0xfff80
ffffffffc0201ee4:	97b2                	add	a5,a5,a2
ffffffffc0201ee6:	079a                	slli	a5,a5,0x6
ffffffffc0201ee8:	97b6                	add	a5,a5,a3
ffffffffc0201eea:	2afa12e3          	bne	s4,a5,ffffffffc020298e <pmm_init+0xd40>
ffffffffc0201eee:	000a2683          	lw	a3,0(s4) # 1000 <_binary_bin_swap_img_size-0x6d00>
ffffffffc0201ef2:	4785                	li	a5,1
ffffffffc0201ef4:	2cf699e3          	bne	a3,a5,ffffffffc02029c6 <pmm_init+0xd78>
ffffffffc0201ef8:	00093503          	ld	a0,0(s2)
ffffffffc0201efc:	77fd                	lui	a5,0xfffff
ffffffffc0201efe:	6114                	ld	a3,0(a0)
ffffffffc0201f00:	068a                	slli	a3,a3,0x2
ffffffffc0201f02:	8efd                	and	a3,a3,a5
ffffffffc0201f04:	00c6d613          	srli	a2,a3,0xc
ffffffffc0201f08:	2ae673e3          	bgeu	a2,a4,ffffffffc02029ae <pmm_init+0xd60>
ffffffffc0201f0c:	0009bc03          	ld	s8,0(s3)
ffffffffc0201f10:	96e2                	add	a3,a3,s8
ffffffffc0201f12:	0006ba83          	ld	s5,0(a3) # fffffffffff80000 <end+0x3fce96f0>
ffffffffc0201f16:	0a8a                	slli	s5,s5,0x2
ffffffffc0201f18:	00fafab3          	and	s5,s5,a5
ffffffffc0201f1c:	00cad793          	srli	a5,s5,0xc
ffffffffc0201f20:	06e7f3e3          	bgeu	a5,a4,ffffffffc0202786 <pmm_init+0xb38>
ffffffffc0201f24:	4601                	li	a2,0
ffffffffc0201f26:	6585                	lui	a1,0x1
ffffffffc0201f28:	9ae2                	add	s5,s5,s8
ffffffffc0201f2a:	c78ff0ef          	jal	ra,ffffffffc02013a2 <get_pte>
ffffffffc0201f2e:	0aa1                	addi	s5,s5,8
ffffffffc0201f30:	03551be3          	bne	a0,s5,ffffffffc0202766 <pmm_init+0xb18>
ffffffffc0201f34:	100027f3          	csrr	a5,sstatus
ffffffffc0201f38:	8b89                	andi	a5,a5,2
ffffffffc0201f3a:	3a079163          	bnez	a5,ffffffffc02022dc <pmm_init+0x68e>
ffffffffc0201f3e:	000b3783          	ld	a5,0(s6)
ffffffffc0201f42:	4505                	li	a0,1
ffffffffc0201f44:	6f9c                	ld	a5,24(a5)
ffffffffc0201f46:	9782                	jalr	a5
ffffffffc0201f48:	8c2a                	mv	s8,a0
ffffffffc0201f4a:	00093503          	ld	a0,0(s2)
ffffffffc0201f4e:	46d1                	li	a3,20
ffffffffc0201f50:	6605                	lui	a2,0x1
ffffffffc0201f52:	85e2                	mv	a1,s8
ffffffffc0201f54:	c05ff0ef          	jal	ra,ffffffffc0201b58 <page_insert>
ffffffffc0201f58:	1a0519e3          	bnez	a0,ffffffffc020290a <pmm_init+0xcbc>
ffffffffc0201f5c:	00093503          	ld	a0,0(s2)
ffffffffc0201f60:	4601                	li	a2,0
ffffffffc0201f62:	6585                	lui	a1,0x1
ffffffffc0201f64:	c3eff0ef          	jal	ra,ffffffffc02013a2 <get_pte>
ffffffffc0201f68:	10050ce3          	beqz	a0,ffffffffc0202880 <pmm_init+0xc32>
ffffffffc0201f6c:	611c                	ld	a5,0(a0)
ffffffffc0201f6e:	0107f713          	andi	a4,a5,16
ffffffffc0201f72:	0e0707e3          	beqz	a4,ffffffffc0202860 <pmm_init+0xc12>
ffffffffc0201f76:	8b91                	andi	a5,a5,4
ffffffffc0201f78:	0c0784e3          	beqz	a5,ffffffffc0202840 <pmm_init+0xbf2>
ffffffffc0201f7c:	00093503          	ld	a0,0(s2)
ffffffffc0201f80:	611c                	ld	a5,0(a0)
ffffffffc0201f82:	8bc1                	andi	a5,a5,16
ffffffffc0201f84:	08078ee3          	beqz	a5,ffffffffc0202820 <pmm_init+0xbd2>
ffffffffc0201f88:	000c2703          	lw	a4,0(s8)
ffffffffc0201f8c:	4785                	li	a5,1
ffffffffc0201f8e:	06f719e3          	bne	a4,a5,ffffffffc0202800 <pmm_init+0xbb2>
ffffffffc0201f92:	4681                	li	a3,0
ffffffffc0201f94:	6605                	lui	a2,0x1
ffffffffc0201f96:	85d2                	mv	a1,s4
ffffffffc0201f98:	bc1ff0ef          	jal	ra,ffffffffc0201b58 <page_insert>
ffffffffc0201f9c:	040512e3          	bnez	a0,ffffffffc02027e0 <pmm_init+0xb92>
ffffffffc0201fa0:	000a2703          	lw	a4,0(s4)
ffffffffc0201fa4:	4789                	li	a5,2
ffffffffc0201fa6:	00f71de3          	bne	a4,a5,ffffffffc02027c0 <pmm_init+0xb72>
ffffffffc0201faa:	000c2783          	lw	a5,0(s8)
ffffffffc0201fae:	7e079963          	bnez	a5,ffffffffc02027a0 <pmm_init+0xb52>
ffffffffc0201fb2:	00093503          	ld	a0,0(s2)
ffffffffc0201fb6:	4601                	li	a2,0
ffffffffc0201fb8:	6585                	lui	a1,0x1
ffffffffc0201fba:	be8ff0ef          	jal	ra,ffffffffc02013a2 <get_pte>
ffffffffc0201fbe:	54050263          	beqz	a0,ffffffffc0202502 <pmm_init+0x8b4>
ffffffffc0201fc2:	6118                	ld	a4,0(a0)
ffffffffc0201fc4:	00177793          	andi	a5,a4,1
ffffffffc0201fc8:	180781e3          	beqz	a5,ffffffffc020294a <pmm_init+0xcfc>
ffffffffc0201fcc:	6094                	ld	a3,0(s1)
ffffffffc0201fce:	00271793          	slli	a5,a4,0x2
ffffffffc0201fd2:	83b1                	srli	a5,a5,0xc
ffffffffc0201fd4:	52d7f563          	bgeu	a5,a3,ffffffffc02024fe <pmm_init+0x8b0>
ffffffffc0201fd8:	000bb683          	ld	a3,0(s7)
ffffffffc0201fdc:	fff80ab7          	lui	s5,0xfff80
ffffffffc0201fe0:	97d6                	add	a5,a5,s5
ffffffffc0201fe2:	079a                	slli	a5,a5,0x6
ffffffffc0201fe4:	97b6                	add	a5,a5,a3
ffffffffc0201fe6:	58fa1e63          	bne	s4,a5,ffffffffc0202582 <pmm_init+0x934>
ffffffffc0201fea:	8b41                	andi	a4,a4,16
ffffffffc0201fec:	56071b63          	bnez	a4,ffffffffc0202562 <pmm_init+0x914>
ffffffffc0201ff0:	00093503          	ld	a0,0(s2)
ffffffffc0201ff4:	4581                	li	a1,0
ffffffffc0201ff6:	ac7ff0ef          	jal	ra,ffffffffc0201abc <page_remove>
ffffffffc0201ffa:	000a2c83          	lw	s9,0(s4)
ffffffffc0201ffe:	4785                	li	a5,1
ffffffffc0202000:	5cfc9163          	bne	s9,a5,ffffffffc02025c2 <pmm_init+0x974>
ffffffffc0202004:	000c2783          	lw	a5,0(s8)
ffffffffc0202008:	58079d63          	bnez	a5,ffffffffc02025a2 <pmm_init+0x954>
ffffffffc020200c:	00093503          	ld	a0,0(s2)
ffffffffc0202010:	6585                	lui	a1,0x1
ffffffffc0202012:	aabff0ef          	jal	ra,ffffffffc0201abc <page_remove>
ffffffffc0202016:	000a2783          	lw	a5,0(s4)
ffffffffc020201a:	200793e3          	bnez	a5,ffffffffc0202a20 <pmm_init+0xdd2>
ffffffffc020201e:	000c2783          	lw	a5,0(s8)
ffffffffc0202022:	1c079fe3          	bnez	a5,ffffffffc0202a00 <pmm_init+0xdb2>
ffffffffc0202026:	00093a03          	ld	s4,0(s2)
ffffffffc020202a:	608c                	ld	a1,0(s1)
ffffffffc020202c:	000a3683          	ld	a3,0(s4)
ffffffffc0202030:	068a                	slli	a3,a3,0x2
ffffffffc0202032:	82b1                	srli	a3,a3,0xc
ffffffffc0202034:	4cb6f563          	bgeu	a3,a1,ffffffffc02024fe <pmm_init+0x8b0>
ffffffffc0202038:	000bb503          	ld	a0,0(s7)
ffffffffc020203c:	96d6                	add	a3,a3,s5
ffffffffc020203e:	069a                	slli	a3,a3,0x6
ffffffffc0202040:	00d507b3          	add	a5,a0,a3
ffffffffc0202044:	439c                	lw	a5,0(a5)
ffffffffc0202046:	4f979e63          	bne	a5,s9,ffffffffc0202542 <pmm_init+0x8f4>
ffffffffc020204a:	8699                	srai	a3,a3,0x6
ffffffffc020204c:	00080637          	lui	a2,0x80
ffffffffc0202050:	96b2                	add	a3,a3,a2
ffffffffc0202052:	00c69713          	slli	a4,a3,0xc
ffffffffc0202056:	8331                	srli	a4,a4,0xc
ffffffffc0202058:	06b2                	slli	a3,a3,0xc
ffffffffc020205a:	06b773e3          	bgeu	a4,a1,ffffffffc02028c0 <pmm_init+0xc72>
ffffffffc020205e:	0009b703          	ld	a4,0(s3)
ffffffffc0202062:	96ba                	add	a3,a3,a4
ffffffffc0202064:	629c                	ld	a5,0(a3)
ffffffffc0202066:	078a                	slli	a5,a5,0x2
ffffffffc0202068:	83b1                	srli	a5,a5,0xc
ffffffffc020206a:	48b7fa63          	bgeu	a5,a1,ffffffffc02024fe <pmm_init+0x8b0>
ffffffffc020206e:	8f91                	sub	a5,a5,a2
ffffffffc0202070:	079a                	slli	a5,a5,0x6
ffffffffc0202072:	953e                	add	a0,a0,a5
ffffffffc0202074:	100027f3          	csrr	a5,sstatus
ffffffffc0202078:	8b89                	andi	a5,a5,2
ffffffffc020207a:	32079463          	bnez	a5,ffffffffc02023a2 <pmm_init+0x754>
ffffffffc020207e:	000b3783          	ld	a5,0(s6)
ffffffffc0202082:	4585                	li	a1,1
ffffffffc0202084:	739c                	ld	a5,32(a5)
ffffffffc0202086:	9782                	jalr	a5
ffffffffc0202088:	000a3783          	ld	a5,0(s4)
ffffffffc020208c:	6098                	ld	a4,0(s1)
ffffffffc020208e:	078a                	slli	a5,a5,0x2
ffffffffc0202090:	83b1                	srli	a5,a5,0xc
ffffffffc0202092:	46e7f663          	bgeu	a5,a4,ffffffffc02024fe <pmm_init+0x8b0>
ffffffffc0202096:	000bb503          	ld	a0,0(s7)
ffffffffc020209a:	fff80737          	lui	a4,0xfff80
ffffffffc020209e:	97ba                	add	a5,a5,a4
ffffffffc02020a0:	079a                	slli	a5,a5,0x6
ffffffffc02020a2:	953e                	add	a0,a0,a5
ffffffffc02020a4:	100027f3          	csrr	a5,sstatus
ffffffffc02020a8:	8b89                	andi	a5,a5,2
ffffffffc02020aa:	2e079063          	bnez	a5,ffffffffc020238a <pmm_init+0x73c>
ffffffffc02020ae:	000b3783          	ld	a5,0(s6)
ffffffffc02020b2:	4585                	li	a1,1
ffffffffc02020b4:	739c                	ld	a5,32(a5)
ffffffffc02020b6:	9782                	jalr	a5
ffffffffc02020b8:	00093783          	ld	a5,0(s2)
ffffffffc02020bc:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd686f0>
ffffffffc02020c0:	12000073          	sfence.vma
ffffffffc02020c4:	100027f3          	csrr	a5,sstatus
ffffffffc02020c8:	8b89                	andi	a5,a5,2
ffffffffc02020ca:	2a079663          	bnez	a5,ffffffffc0202376 <pmm_init+0x728>
ffffffffc02020ce:	000b3783          	ld	a5,0(s6)
ffffffffc02020d2:	779c                	ld	a5,40(a5)
ffffffffc02020d4:	9782                	jalr	a5
ffffffffc02020d6:	8a2a                	mv	s4,a0
ffffffffc02020d8:	7d441463          	bne	s0,s4,ffffffffc02028a0 <pmm_init+0xc52>
ffffffffc02020dc:	0000a517          	auipc	a0,0xa
ffffffffc02020e0:	65c50513          	addi	a0,a0,1628 # ffffffffc020c738 <commands+0xe60>
ffffffffc02020e4:	846fe0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02020e8:	100027f3          	csrr	a5,sstatus
ffffffffc02020ec:	8b89                	andi	a5,a5,2
ffffffffc02020ee:	26079a63          	bnez	a5,ffffffffc0202362 <pmm_init+0x714>
ffffffffc02020f2:	000b3783          	ld	a5,0(s6)
ffffffffc02020f6:	779c                	ld	a5,40(a5)
ffffffffc02020f8:	9782                	jalr	a5
ffffffffc02020fa:	8c2a                	mv	s8,a0
ffffffffc02020fc:	6098                	ld	a4,0(s1)
ffffffffc02020fe:	c0200437          	lui	s0,0xc0200
ffffffffc0202102:	7afd                	lui	s5,0xfffff
ffffffffc0202104:	00c71793          	slli	a5,a4,0xc
ffffffffc0202108:	6a05                	lui	s4,0x1
ffffffffc020210a:	02f47c63          	bgeu	s0,a5,ffffffffc0202142 <pmm_init+0x4f4>
ffffffffc020210e:	00c45793          	srli	a5,s0,0xc
ffffffffc0202112:	00093503          	ld	a0,0(s2)
ffffffffc0202116:	3ae7f763          	bgeu	a5,a4,ffffffffc02024c4 <pmm_init+0x876>
ffffffffc020211a:	0009b583          	ld	a1,0(s3)
ffffffffc020211e:	4601                	li	a2,0
ffffffffc0202120:	95a2                	add	a1,a1,s0
ffffffffc0202122:	a80ff0ef          	jal	ra,ffffffffc02013a2 <get_pte>
ffffffffc0202126:	36050f63          	beqz	a0,ffffffffc02024a4 <pmm_init+0x856>
ffffffffc020212a:	611c                	ld	a5,0(a0)
ffffffffc020212c:	078a                	slli	a5,a5,0x2
ffffffffc020212e:	0157f7b3          	and	a5,a5,s5
ffffffffc0202132:	3a879663          	bne	a5,s0,ffffffffc02024de <pmm_init+0x890>
ffffffffc0202136:	6098                	ld	a4,0(s1)
ffffffffc0202138:	9452                	add	s0,s0,s4
ffffffffc020213a:	00c71793          	slli	a5,a4,0xc
ffffffffc020213e:	fcf468e3          	bltu	s0,a5,ffffffffc020210e <pmm_init+0x4c0>
ffffffffc0202142:	00093783          	ld	a5,0(s2)
ffffffffc0202146:	639c                	ld	a5,0(a5)
ffffffffc0202148:	48079d63          	bnez	a5,ffffffffc02025e2 <pmm_init+0x994>
ffffffffc020214c:	100027f3          	csrr	a5,sstatus
ffffffffc0202150:	8b89                	andi	a5,a5,2
ffffffffc0202152:	26079463          	bnez	a5,ffffffffc02023ba <pmm_init+0x76c>
ffffffffc0202156:	000b3783          	ld	a5,0(s6)
ffffffffc020215a:	4505                	li	a0,1
ffffffffc020215c:	6f9c                	ld	a5,24(a5)
ffffffffc020215e:	9782                	jalr	a5
ffffffffc0202160:	8a2a                	mv	s4,a0
ffffffffc0202162:	00093503          	ld	a0,0(s2)
ffffffffc0202166:	4699                	li	a3,6
ffffffffc0202168:	10000613          	li	a2,256
ffffffffc020216c:	85d2                	mv	a1,s4
ffffffffc020216e:	9ebff0ef          	jal	ra,ffffffffc0201b58 <page_insert>
ffffffffc0202172:	4a051863          	bnez	a0,ffffffffc0202622 <pmm_init+0x9d4>
ffffffffc0202176:	000a2703          	lw	a4,0(s4) # 1000 <_binary_bin_swap_img_size-0x6d00>
ffffffffc020217a:	4785                	li	a5,1
ffffffffc020217c:	48f71363          	bne	a4,a5,ffffffffc0202602 <pmm_init+0x9b4>
ffffffffc0202180:	00093503          	ld	a0,0(s2)
ffffffffc0202184:	6405                	lui	s0,0x1
ffffffffc0202186:	4699                	li	a3,6
ffffffffc0202188:	10040613          	addi	a2,s0,256 # 1100 <_binary_bin_swap_img_size-0x6c00>
ffffffffc020218c:	85d2                	mv	a1,s4
ffffffffc020218e:	9cbff0ef          	jal	ra,ffffffffc0201b58 <page_insert>
ffffffffc0202192:	38051863          	bnez	a0,ffffffffc0202522 <pmm_init+0x8d4>
ffffffffc0202196:	000a2703          	lw	a4,0(s4)
ffffffffc020219a:	4789                	li	a5,2
ffffffffc020219c:	4ef71363          	bne	a4,a5,ffffffffc0202682 <pmm_init+0xa34>
ffffffffc02021a0:	0000a597          	auipc	a1,0xa
ffffffffc02021a4:	6e058593          	addi	a1,a1,1760 # ffffffffc020c880 <commands+0xfa8>
ffffffffc02021a8:	10000513          	li	a0,256
ffffffffc02021ac:	71b080ef          	jal	ra,ffffffffc020b0c6 <strcpy>
ffffffffc02021b0:	10040593          	addi	a1,s0,256
ffffffffc02021b4:	10000513          	li	a0,256
ffffffffc02021b8:	721080ef          	jal	ra,ffffffffc020b0d8 <strcmp>
ffffffffc02021bc:	4a051363          	bnez	a0,ffffffffc0202662 <pmm_init+0xa14>
ffffffffc02021c0:	000bb683          	ld	a3,0(s7)
ffffffffc02021c4:	00080737          	lui	a4,0x80
ffffffffc02021c8:	547d                	li	s0,-1
ffffffffc02021ca:	40da06b3          	sub	a3,s4,a3
ffffffffc02021ce:	8699                	srai	a3,a3,0x6
ffffffffc02021d0:	609c                	ld	a5,0(s1)
ffffffffc02021d2:	96ba                	add	a3,a3,a4
ffffffffc02021d4:	8031                	srli	s0,s0,0xc
ffffffffc02021d6:	0086f733          	and	a4,a3,s0
ffffffffc02021da:	06b2                	slli	a3,a3,0xc
ffffffffc02021dc:	6ef77263          	bgeu	a4,a5,ffffffffc02028c0 <pmm_init+0xc72>
ffffffffc02021e0:	0009b783          	ld	a5,0(s3)
ffffffffc02021e4:	10000513          	li	a0,256
ffffffffc02021e8:	96be                	add	a3,a3,a5
ffffffffc02021ea:	10068023          	sb	zero,256(a3)
ffffffffc02021ee:	6a3080ef          	jal	ra,ffffffffc020b090 <strlen>
ffffffffc02021f2:	44051863          	bnez	a0,ffffffffc0202642 <pmm_init+0x9f4>
ffffffffc02021f6:	00093a83          	ld	s5,0(s2)
ffffffffc02021fa:	609c                	ld	a5,0(s1)
ffffffffc02021fc:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fd686f0>
ffffffffc0202200:	068a                	slli	a3,a3,0x2
ffffffffc0202202:	82b1                	srli	a3,a3,0xc
ffffffffc0202204:	2ef6fd63          	bgeu	a3,a5,ffffffffc02024fe <pmm_init+0x8b0>
ffffffffc0202208:	8c75                	and	s0,s0,a3
ffffffffc020220a:	06b2                	slli	a3,a3,0xc
ffffffffc020220c:	6af47a63          	bgeu	s0,a5,ffffffffc02028c0 <pmm_init+0xc72>
ffffffffc0202210:	0009b403          	ld	s0,0(s3)
ffffffffc0202214:	9436                	add	s0,s0,a3
ffffffffc0202216:	100027f3          	csrr	a5,sstatus
ffffffffc020221a:	8b89                	andi	a5,a5,2
ffffffffc020221c:	1e079c63          	bnez	a5,ffffffffc0202414 <pmm_init+0x7c6>
ffffffffc0202220:	000b3783          	ld	a5,0(s6)
ffffffffc0202224:	4585                	li	a1,1
ffffffffc0202226:	8552                	mv	a0,s4
ffffffffc0202228:	739c                	ld	a5,32(a5)
ffffffffc020222a:	9782                	jalr	a5
ffffffffc020222c:	601c                	ld	a5,0(s0)
ffffffffc020222e:	6098                	ld	a4,0(s1)
ffffffffc0202230:	078a                	slli	a5,a5,0x2
ffffffffc0202232:	83b1                	srli	a5,a5,0xc
ffffffffc0202234:	2ce7f563          	bgeu	a5,a4,ffffffffc02024fe <pmm_init+0x8b0>
ffffffffc0202238:	000bb503          	ld	a0,0(s7)
ffffffffc020223c:	fff80737          	lui	a4,0xfff80
ffffffffc0202240:	97ba                	add	a5,a5,a4
ffffffffc0202242:	079a                	slli	a5,a5,0x6
ffffffffc0202244:	953e                	add	a0,a0,a5
ffffffffc0202246:	100027f3          	csrr	a5,sstatus
ffffffffc020224a:	8b89                	andi	a5,a5,2
ffffffffc020224c:	1a079863          	bnez	a5,ffffffffc02023fc <pmm_init+0x7ae>
ffffffffc0202250:	000b3783          	ld	a5,0(s6)
ffffffffc0202254:	4585                	li	a1,1
ffffffffc0202256:	739c                	ld	a5,32(a5)
ffffffffc0202258:	9782                	jalr	a5
ffffffffc020225a:	000ab783          	ld	a5,0(s5)
ffffffffc020225e:	6098                	ld	a4,0(s1)
ffffffffc0202260:	078a                	slli	a5,a5,0x2
ffffffffc0202262:	83b1                	srli	a5,a5,0xc
ffffffffc0202264:	28e7fd63          	bgeu	a5,a4,ffffffffc02024fe <pmm_init+0x8b0>
ffffffffc0202268:	000bb503          	ld	a0,0(s7)
ffffffffc020226c:	fff80737          	lui	a4,0xfff80
ffffffffc0202270:	97ba                	add	a5,a5,a4
ffffffffc0202272:	079a                	slli	a5,a5,0x6
ffffffffc0202274:	953e                	add	a0,a0,a5
ffffffffc0202276:	100027f3          	csrr	a5,sstatus
ffffffffc020227a:	8b89                	andi	a5,a5,2
ffffffffc020227c:	16079463          	bnez	a5,ffffffffc02023e4 <pmm_init+0x796>
ffffffffc0202280:	000b3783          	ld	a5,0(s6)
ffffffffc0202284:	4585                	li	a1,1
ffffffffc0202286:	739c                	ld	a5,32(a5)
ffffffffc0202288:	9782                	jalr	a5
ffffffffc020228a:	00093783          	ld	a5,0(s2)
ffffffffc020228e:	0007b023          	sd	zero,0(a5)
ffffffffc0202292:	12000073          	sfence.vma
ffffffffc0202296:	100027f3          	csrr	a5,sstatus
ffffffffc020229a:	8b89                	andi	a5,a5,2
ffffffffc020229c:	12079a63          	bnez	a5,ffffffffc02023d0 <pmm_init+0x782>
ffffffffc02022a0:	000b3783          	ld	a5,0(s6)
ffffffffc02022a4:	779c                	ld	a5,40(a5)
ffffffffc02022a6:	9782                	jalr	a5
ffffffffc02022a8:	842a                	mv	s0,a0
ffffffffc02022aa:	488c1e63          	bne	s8,s0,ffffffffc0202746 <pmm_init+0xaf8>
ffffffffc02022ae:	0000a517          	auipc	a0,0xa
ffffffffc02022b2:	64a50513          	addi	a0,a0,1610 # ffffffffc020c8f8 <commands+0x1020>
ffffffffc02022b6:	e75fd0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02022ba:	7406                	ld	s0,96(sp)
ffffffffc02022bc:	70a6                	ld	ra,104(sp)
ffffffffc02022be:	64e6                	ld	s1,88(sp)
ffffffffc02022c0:	6946                	ld	s2,80(sp)
ffffffffc02022c2:	69a6                	ld	s3,72(sp)
ffffffffc02022c4:	6a06                	ld	s4,64(sp)
ffffffffc02022c6:	7ae2                	ld	s5,56(sp)
ffffffffc02022c8:	7b42                	ld	s6,48(sp)
ffffffffc02022ca:	7ba2                	ld	s7,40(sp)
ffffffffc02022cc:	7c02                	ld	s8,32(sp)
ffffffffc02022ce:	6ce2                	ld	s9,24(sp)
ffffffffc02022d0:	6165                	addi	sp,sp,112
ffffffffc02022d2:	4cc0106f          	j	ffffffffc020379e <kmalloc_init>
ffffffffc02022d6:	c80007b7          	lui	a5,0xc8000
ffffffffc02022da:	b411                	j	ffffffffc0201cde <pmm_init+0x90>
ffffffffc02022dc:	ac5fe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc02022e0:	000b3783          	ld	a5,0(s6)
ffffffffc02022e4:	4505                	li	a0,1
ffffffffc02022e6:	6f9c                	ld	a5,24(a5)
ffffffffc02022e8:	9782                	jalr	a5
ffffffffc02022ea:	8c2a                	mv	s8,a0
ffffffffc02022ec:	aaffe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc02022f0:	b9a9                	j	ffffffffc0201f4a <pmm_init+0x2fc>
ffffffffc02022f2:	aaffe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc02022f6:	000b3783          	ld	a5,0(s6)
ffffffffc02022fa:	4505                	li	a0,1
ffffffffc02022fc:	6f9c                	ld	a5,24(a5)
ffffffffc02022fe:	9782                	jalr	a5
ffffffffc0202300:	8a2a                	mv	s4,a0
ffffffffc0202302:	a99fe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0202306:	b645                	j	ffffffffc0201ea6 <pmm_init+0x258>
ffffffffc0202308:	a99fe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc020230c:	000b3783          	ld	a5,0(s6)
ffffffffc0202310:	779c                	ld	a5,40(a5)
ffffffffc0202312:	9782                	jalr	a5
ffffffffc0202314:	842a                	mv	s0,a0
ffffffffc0202316:	a85fe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc020231a:	b6b9                	j	ffffffffc0201e68 <pmm_init+0x21a>
ffffffffc020231c:	a85fe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0202320:	000b3783          	ld	a5,0(s6)
ffffffffc0202324:	4505                	li	a0,1
ffffffffc0202326:	6f9c                	ld	a5,24(a5)
ffffffffc0202328:	9782                	jalr	a5
ffffffffc020232a:	842a                	mv	s0,a0
ffffffffc020232c:	a6ffe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0202330:	bc99                	j	ffffffffc0201d86 <pmm_init+0x138>
ffffffffc0202332:	6705                	lui	a4,0x1
ffffffffc0202334:	177d                	addi	a4,a4,-1
ffffffffc0202336:	96ba                	add	a3,a3,a4
ffffffffc0202338:	8ff5                	and	a5,a5,a3
ffffffffc020233a:	00c7d713          	srli	a4,a5,0xc
ffffffffc020233e:	1ca77063          	bgeu	a4,a0,ffffffffc02024fe <pmm_init+0x8b0>
ffffffffc0202342:	000b3683          	ld	a3,0(s6)
ffffffffc0202346:	fff80537          	lui	a0,0xfff80
ffffffffc020234a:	972a                	add	a4,a4,a0
ffffffffc020234c:	6a94                	ld	a3,16(a3)
ffffffffc020234e:	8c1d                	sub	s0,s0,a5
ffffffffc0202350:	00671513          	slli	a0,a4,0x6
ffffffffc0202354:	00c45593          	srli	a1,s0,0xc
ffffffffc0202358:	9532                	add	a0,a0,a2
ffffffffc020235a:	9682                	jalr	a3
ffffffffc020235c:	0009b583          	ld	a1,0(s3)
ffffffffc0202360:	bac5                	j	ffffffffc0201d50 <pmm_init+0x102>
ffffffffc0202362:	a3ffe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0202366:	000b3783          	ld	a5,0(s6)
ffffffffc020236a:	779c                	ld	a5,40(a5)
ffffffffc020236c:	9782                	jalr	a5
ffffffffc020236e:	8c2a                	mv	s8,a0
ffffffffc0202370:	a2bfe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0202374:	b361                	j	ffffffffc02020fc <pmm_init+0x4ae>
ffffffffc0202376:	a2bfe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc020237a:	000b3783          	ld	a5,0(s6)
ffffffffc020237e:	779c                	ld	a5,40(a5)
ffffffffc0202380:	9782                	jalr	a5
ffffffffc0202382:	8a2a                	mv	s4,a0
ffffffffc0202384:	a17fe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0202388:	bb81                	j	ffffffffc02020d8 <pmm_init+0x48a>
ffffffffc020238a:	e42a                	sd	a0,8(sp)
ffffffffc020238c:	a15fe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0202390:	000b3783          	ld	a5,0(s6)
ffffffffc0202394:	6522                	ld	a0,8(sp)
ffffffffc0202396:	4585                	li	a1,1
ffffffffc0202398:	739c                	ld	a5,32(a5)
ffffffffc020239a:	9782                	jalr	a5
ffffffffc020239c:	9fffe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc02023a0:	bb21                	j	ffffffffc02020b8 <pmm_init+0x46a>
ffffffffc02023a2:	e42a                	sd	a0,8(sp)
ffffffffc02023a4:	9fdfe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc02023a8:	000b3783          	ld	a5,0(s6)
ffffffffc02023ac:	6522                	ld	a0,8(sp)
ffffffffc02023ae:	4585                	li	a1,1
ffffffffc02023b0:	739c                	ld	a5,32(a5)
ffffffffc02023b2:	9782                	jalr	a5
ffffffffc02023b4:	9e7fe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc02023b8:	b9c1                	j	ffffffffc0202088 <pmm_init+0x43a>
ffffffffc02023ba:	9e7fe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc02023be:	000b3783          	ld	a5,0(s6)
ffffffffc02023c2:	4505                	li	a0,1
ffffffffc02023c4:	6f9c                	ld	a5,24(a5)
ffffffffc02023c6:	9782                	jalr	a5
ffffffffc02023c8:	8a2a                	mv	s4,a0
ffffffffc02023ca:	9d1fe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc02023ce:	bb51                	j	ffffffffc0202162 <pmm_init+0x514>
ffffffffc02023d0:	9d1fe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc02023d4:	000b3783          	ld	a5,0(s6)
ffffffffc02023d8:	779c                	ld	a5,40(a5)
ffffffffc02023da:	9782                	jalr	a5
ffffffffc02023dc:	842a                	mv	s0,a0
ffffffffc02023de:	9bdfe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc02023e2:	b5e1                	j	ffffffffc02022aa <pmm_init+0x65c>
ffffffffc02023e4:	e42a                	sd	a0,8(sp)
ffffffffc02023e6:	9bbfe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc02023ea:	000b3783          	ld	a5,0(s6)
ffffffffc02023ee:	6522                	ld	a0,8(sp)
ffffffffc02023f0:	4585                	li	a1,1
ffffffffc02023f2:	739c                	ld	a5,32(a5)
ffffffffc02023f4:	9782                	jalr	a5
ffffffffc02023f6:	9a5fe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc02023fa:	bd41                	j	ffffffffc020228a <pmm_init+0x63c>
ffffffffc02023fc:	e42a                	sd	a0,8(sp)
ffffffffc02023fe:	9a3fe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0202402:	000b3783          	ld	a5,0(s6)
ffffffffc0202406:	6522                	ld	a0,8(sp)
ffffffffc0202408:	4585                	li	a1,1
ffffffffc020240a:	739c                	ld	a5,32(a5)
ffffffffc020240c:	9782                	jalr	a5
ffffffffc020240e:	98dfe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0202412:	b5a1                	j	ffffffffc020225a <pmm_init+0x60c>
ffffffffc0202414:	98dfe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0202418:	000b3783          	ld	a5,0(s6)
ffffffffc020241c:	4585                	li	a1,1
ffffffffc020241e:	8552                	mv	a0,s4
ffffffffc0202420:	739c                	ld	a5,32(a5)
ffffffffc0202422:	9782                	jalr	a5
ffffffffc0202424:	977fe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0202428:	b511                	j	ffffffffc020222c <pmm_init+0x5de>
ffffffffc020242a:	00011417          	auipc	s0,0x11
ffffffffc020242e:	bd640413          	addi	s0,s0,-1066 # ffffffffc0213000 <boot_page_table_sv39>
ffffffffc0202432:	00011797          	auipc	a5,0x11
ffffffffc0202436:	bce78793          	addi	a5,a5,-1074 # ffffffffc0213000 <boot_page_table_sv39>
ffffffffc020243a:	a0f41de3          	bne	s0,a5,ffffffffc0201e54 <pmm_init+0x206>
ffffffffc020243e:	4581                	li	a1,0
ffffffffc0202440:	6605                	lui	a2,0x1
ffffffffc0202442:	8522                	mv	a0,s0
ffffffffc0202444:	4ef080ef          	jal	ra,ffffffffc020b132 <memset>
ffffffffc0202448:	0000e597          	auipc	a1,0xe
ffffffffc020244c:	bb858593          	addi	a1,a1,-1096 # ffffffffc0210000 <bootstackguard>
ffffffffc0202450:	0000f797          	auipc	a5,0xf
ffffffffc0202454:	ba0787a3          	sb	zero,-1105(a5) # ffffffffc0210fff <bootstackguard+0xfff>
ffffffffc0202458:	0000e797          	auipc	a5,0xe
ffffffffc020245c:	ba078423          	sb	zero,-1112(a5) # ffffffffc0210000 <bootstackguard>
ffffffffc0202460:	00093503          	ld	a0,0(s2)
ffffffffc0202464:	2555ec63          	bltu	a1,s5,ffffffffc02026bc <pmm_init+0xa6e>
ffffffffc0202468:	0009b683          	ld	a3,0(s3)
ffffffffc020246c:	4701                	li	a4,0
ffffffffc020246e:	6605                	lui	a2,0x1
ffffffffc0202470:	40d586b3          	sub	a3,a1,a3
ffffffffc0202474:	956ff0ef          	jal	ra,ffffffffc02015ca <boot_map_segment>
ffffffffc0202478:	00093503          	ld	a0,0(s2)
ffffffffc020247c:	23546363          	bltu	s0,s5,ffffffffc02026a2 <pmm_init+0xa54>
ffffffffc0202480:	0009b683          	ld	a3,0(s3)
ffffffffc0202484:	4701                	li	a4,0
ffffffffc0202486:	6605                	lui	a2,0x1
ffffffffc0202488:	40d406b3          	sub	a3,s0,a3
ffffffffc020248c:	85a2                	mv	a1,s0
ffffffffc020248e:	93cff0ef          	jal	ra,ffffffffc02015ca <boot_map_segment>
ffffffffc0202492:	12000073          	sfence.vma
ffffffffc0202496:	0000a517          	auipc	a0,0xa
ffffffffc020249a:	f7250513          	addi	a0,a0,-142 # ffffffffc020c408 <commands+0xb30>
ffffffffc020249e:	c8dfd0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02024a2:	ba4d                	j	ffffffffc0201e54 <pmm_init+0x206>
ffffffffc02024a4:	0000a697          	auipc	a3,0xa
ffffffffc02024a8:	2b468693          	addi	a3,a3,692 # ffffffffc020c758 <commands+0xe80>
ffffffffc02024ac:	00009617          	auipc	a2,0x9
ffffffffc02024b0:	67c60613          	addi	a2,a2,1660 # ffffffffc020bb28 <commands+0x250>
ffffffffc02024b4:	28e00593          	li	a1,654
ffffffffc02024b8:	0000a517          	auipc	a0,0xa
ffffffffc02024bc:	db050513          	addi	a0,a0,-592 # ffffffffc020c268 <commands+0x990>
ffffffffc02024c0:	d6ffd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02024c4:	86a2                	mv	a3,s0
ffffffffc02024c6:	0000a617          	auipc	a2,0xa
ffffffffc02024ca:	d7a60613          	addi	a2,a2,-646 # ffffffffc020c240 <commands+0x968>
ffffffffc02024ce:	28e00593          	li	a1,654
ffffffffc02024d2:	0000a517          	auipc	a0,0xa
ffffffffc02024d6:	d9650513          	addi	a0,a0,-618 # ffffffffc020c268 <commands+0x990>
ffffffffc02024da:	d55fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02024de:	0000a697          	auipc	a3,0xa
ffffffffc02024e2:	2ba68693          	addi	a3,a3,698 # ffffffffc020c798 <commands+0xec0>
ffffffffc02024e6:	00009617          	auipc	a2,0x9
ffffffffc02024ea:	64260613          	addi	a2,a2,1602 # ffffffffc020bb28 <commands+0x250>
ffffffffc02024ee:	28f00593          	li	a1,655
ffffffffc02024f2:	0000a517          	auipc	a0,0xa
ffffffffc02024f6:	d7650513          	addi	a0,a0,-650 # ffffffffc020c268 <commands+0x990>
ffffffffc02024fa:	d35fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02024fe:	db5fe0ef          	jal	ra,ffffffffc02012b2 <pa2page.part.0>
ffffffffc0202502:	0000a697          	auipc	a3,0xa
ffffffffc0202506:	0be68693          	addi	a3,a3,190 # ffffffffc020c5c0 <commands+0xce8>
ffffffffc020250a:	00009617          	auipc	a2,0x9
ffffffffc020250e:	61e60613          	addi	a2,a2,1566 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202512:	26b00593          	li	a1,619
ffffffffc0202516:	0000a517          	auipc	a0,0xa
ffffffffc020251a:	d5250513          	addi	a0,a0,-686 # ffffffffc020c268 <commands+0x990>
ffffffffc020251e:	d11fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202522:	0000a697          	auipc	a3,0xa
ffffffffc0202526:	2fe68693          	addi	a3,a3,766 # ffffffffc020c820 <commands+0xf48>
ffffffffc020252a:	00009617          	auipc	a2,0x9
ffffffffc020252e:	5fe60613          	addi	a2,a2,1534 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202532:	29800593          	li	a1,664
ffffffffc0202536:	0000a517          	auipc	a0,0xa
ffffffffc020253a:	d3250513          	addi	a0,a0,-718 # ffffffffc020c268 <commands+0x990>
ffffffffc020253e:	cf1fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202542:	0000a697          	auipc	a3,0xa
ffffffffc0202546:	19e68693          	addi	a3,a3,414 # ffffffffc020c6e0 <commands+0xe08>
ffffffffc020254a:	00009617          	auipc	a2,0x9
ffffffffc020254e:	5de60613          	addi	a2,a2,1502 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202552:	27700593          	li	a1,631
ffffffffc0202556:	0000a517          	auipc	a0,0xa
ffffffffc020255a:	d1250513          	addi	a0,a0,-750 # ffffffffc020c268 <commands+0x990>
ffffffffc020255e:	cd1fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202562:	0000a697          	auipc	a3,0xa
ffffffffc0202566:	14e68693          	addi	a3,a3,334 # ffffffffc020c6b0 <commands+0xdd8>
ffffffffc020256a:	00009617          	auipc	a2,0x9
ffffffffc020256e:	5be60613          	addi	a2,a2,1470 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202572:	26d00593          	li	a1,621
ffffffffc0202576:	0000a517          	auipc	a0,0xa
ffffffffc020257a:	cf250513          	addi	a0,a0,-782 # ffffffffc020c268 <commands+0x990>
ffffffffc020257e:	cb1fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202582:	0000a697          	auipc	a3,0xa
ffffffffc0202586:	f9e68693          	addi	a3,a3,-98 # ffffffffc020c520 <commands+0xc48>
ffffffffc020258a:	00009617          	auipc	a2,0x9
ffffffffc020258e:	59e60613          	addi	a2,a2,1438 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202592:	26c00593          	li	a1,620
ffffffffc0202596:	0000a517          	auipc	a0,0xa
ffffffffc020259a:	cd250513          	addi	a0,a0,-814 # ffffffffc020c268 <commands+0x990>
ffffffffc020259e:	c91fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02025a2:	0000a697          	auipc	a3,0xa
ffffffffc02025a6:	0f668693          	addi	a3,a3,246 # ffffffffc020c698 <commands+0xdc0>
ffffffffc02025aa:	00009617          	auipc	a2,0x9
ffffffffc02025ae:	57e60613          	addi	a2,a2,1406 # ffffffffc020bb28 <commands+0x250>
ffffffffc02025b2:	27100593          	li	a1,625
ffffffffc02025b6:	0000a517          	auipc	a0,0xa
ffffffffc02025ba:	cb250513          	addi	a0,a0,-846 # ffffffffc020c268 <commands+0x990>
ffffffffc02025be:	c71fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02025c2:	0000a697          	auipc	a3,0xa
ffffffffc02025c6:	f7668693          	addi	a3,a3,-138 # ffffffffc020c538 <commands+0xc60>
ffffffffc02025ca:	00009617          	auipc	a2,0x9
ffffffffc02025ce:	55e60613          	addi	a2,a2,1374 # ffffffffc020bb28 <commands+0x250>
ffffffffc02025d2:	27000593          	li	a1,624
ffffffffc02025d6:	0000a517          	auipc	a0,0xa
ffffffffc02025da:	c9250513          	addi	a0,a0,-878 # ffffffffc020c268 <commands+0x990>
ffffffffc02025de:	c51fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02025e2:	0000a697          	auipc	a3,0xa
ffffffffc02025e6:	1ce68693          	addi	a3,a3,462 # ffffffffc020c7b0 <commands+0xed8>
ffffffffc02025ea:	00009617          	auipc	a2,0x9
ffffffffc02025ee:	53e60613          	addi	a2,a2,1342 # ffffffffc020bb28 <commands+0x250>
ffffffffc02025f2:	29200593          	li	a1,658
ffffffffc02025f6:	0000a517          	auipc	a0,0xa
ffffffffc02025fa:	c7250513          	addi	a0,a0,-910 # ffffffffc020c268 <commands+0x990>
ffffffffc02025fe:	c31fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202602:	0000a697          	auipc	a3,0xa
ffffffffc0202606:	20668693          	addi	a3,a3,518 # ffffffffc020c808 <commands+0xf30>
ffffffffc020260a:	00009617          	auipc	a2,0x9
ffffffffc020260e:	51e60613          	addi	a2,a2,1310 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202612:	29700593          	li	a1,663
ffffffffc0202616:	0000a517          	auipc	a0,0xa
ffffffffc020261a:	c5250513          	addi	a0,a0,-942 # ffffffffc020c268 <commands+0x990>
ffffffffc020261e:	c11fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202622:	0000a697          	auipc	a3,0xa
ffffffffc0202626:	1a668693          	addi	a3,a3,422 # ffffffffc020c7c8 <commands+0xef0>
ffffffffc020262a:	00009617          	auipc	a2,0x9
ffffffffc020262e:	4fe60613          	addi	a2,a2,1278 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202632:	29600593          	li	a1,662
ffffffffc0202636:	0000a517          	auipc	a0,0xa
ffffffffc020263a:	c3250513          	addi	a0,a0,-974 # ffffffffc020c268 <commands+0x990>
ffffffffc020263e:	bf1fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202642:	0000a697          	auipc	a3,0xa
ffffffffc0202646:	28e68693          	addi	a3,a3,654 # ffffffffc020c8d0 <commands+0xff8>
ffffffffc020264a:	00009617          	auipc	a2,0x9
ffffffffc020264e:	4de60613          	addi	a2,a2,1246 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202652:	2a000593          	li	a1,672
ffffffffc0202656:	0000a517          	auipc	a0,0xa
ffffffffc020265a:	c1250513          	addi	a0,a0,-1006 # ffffffffc020c268 <commands+0x990>
ffffffffc020265e:	bd1fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202662:	0000a697          	auipc	a3,0xa
ffffffffc0202666:	23668693          	addi	a3,a3,566 # ffffffffc020c898 <commands+0xfc0>
ffffffffc020266a:	00009617          	auipc	a2,0x9
ffffffffc020266e:	4be60613          	addi	a2,a2,1214 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202672:	29d00593          	li	a1,669
ffffffffc0202676:	0000a517          	auipc	a0,0xa
ffffffffc020267a:	bf250513          	addi	a0,a0,-1038 # ffffffffc020c268 <commands+0x990>
ffffffffc020267e:	bb1fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202682:	0000a697          	auipc	a3,0xa
ffffffffc0202686:	1e668693          	addi	a3,a3,486 # ffffffffc020c868 <commands+0xf90>
ffffffffc020268a:	00009617          	auipc	a2,0x9
ffffffffc020268e:	49e60613          	addi	a2,a2,1182 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202692:	29900593          	li	a1,665
ffffffffc0202696:	0000a517          	auipc	a0,0xa
ffffffffc020269a:	bd250513          	addi	a0,a0,-1070 # ffffffffc020c268 <commands+0x990>
ffffffffc020269e:	b91fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02026a2:	86a2                	mv	a3,s0
ffffffffc02026a4:	0000a617          	auipc	a2,0xa
ffffffffc02026a8:	cbc60613          	addi	a2,a2,-836 # ffffffffc020c360 <commands+0xa88>
ffffffffc02026ac:	0dc00593          	li	a1,220
ffffffffc02026b0:	0000a517          	auipc	a0,0xa
ffffffffc02026b4:	bb850513          	addi	a0,a0,-1096 # ffffffffc020c268 <commands+0x990>
ffffffffc02026b8:	b77fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02026bc:	86ae                	mv	a3,a1
ffffffffc02026be:	0000a617          	auipc	a2,0xa
ffffffffc02026c2:	ca260613          	addi	a2,a2,-862 # ffffffffc020c360 <commands+0xa88>
ffffffffc02026c6:	0db00593          	li	a1,219
ffffffffc02026ca:	0000a517          	auipc	a0,0xa
ffffffffc02026ce:	b9e50513          	addi	a0,a0,-1122 # ffffffffc020c268 <commands+0x990>
ffffffffc02026d2:	b5dfd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02026d6:	0000a697          	auipc	a3,0xa
ffffffffc02026da:	d7a68693          	addi	a3,a3,-646 # ffffffffc020c450 <commands+0xb78>
ffffffffc02026de:	00009617          	auipc	a2,0x9
ffffffffc02026e2:	44a60613          	addi	a2,a2,1098 # ffffffffc020bb28 <commands+0x250>
ffffffffc02026e6:	25000593          	li	a1,592
ffffffffc02026ea:	0000a517          	auipc	a0,0xa
ffffffffc02026ee:	b7e50513          	addi	a0,a0,-1154 # ffffffffc020c268 <commands+0x990>
ffffffffc02026f2:	b3dfd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02026f6:	0000a697          	auipc	a3,0xa
ffffffffc02026fa:	d3a68693          	addi	a3,a3,-710 # ffffffffc020c430 <commands+0xb58>
ffffffffc02026fe:	00009617          	auipc	a2,0x9
ffffffffc0202702:	42a60613          	addi	a2,a2,1066 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202706:	24f00593          	li	a1,591
ffffffffc020270a:	0000a517          	auipc	a0,0xa
ffffffffc020270e:	b5e50513          	addi	a0,a0,-1186 # ffffffffc020c268 <commands+0x990>
ffffffffc0202712:	b1dfd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202716:	0000a617          	auipc	a2,0xa
ffffffffc020271a:	caa60613          	addi	a2,a2,-854 # ffffffffc020c3c0 <commands+0xae8>
ffffffffc020271e:	0aa00593          	li	a1,170
ffffffffc0202722:	0000a517          	auipc	a0,0xa
ffffffffc0202726:	b4650513          	addi	a0,a0,-1210 # ffffffffc020c268 <commands+0x990>
ffffffffc020272a:	b05fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020272e:	0000a617          	auipc	a2,0xa
ffffffffc0202732:	bd260613          	addi	a2,a2,-1070 # ffffffffc020c300 <commands+0xa28>
ffffffffc0202736:	06500593          	li	a1,101
ffffffffc020273a:	0000a517          	auipc	a0,0xa
ffffffffc020273e:	b2e50513          	addi	a0,a0,-1234 # ffffffffc020c268 <commands+0x990>
ffffffffc0202742:	aedfd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202746:	0000a697          	auipc	a3,0xa
ffffffffc020274a:	fca68693          	addi	a3,a3,-54 # ffffffffc020c710 <commands+0xe38>
ffffffffc020274e:	00009617          	auipc	a2,0x9
ffffffffc0202752:	3da60613          	addi	a2,a2,986 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202756:	2a900593          	li	a1,681
ffffffffc020275a:	0000a517          	auipc	a0,0xa
ffffffffc020275e:	b0e50513          	addi	a0,a0,-1266 # ffffffffc020c268 <commands+0x990>
ffffffffc0202762:	acdfd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202766:	0000a697          	auipc	a3,0xa
ffffffffc020276a:	dea68693          	addi	a3,a3,-534 # ffffffffc020c550 <commands+0xc78>
ffffffffc020276e:	00009617          	auipc	a2,0x9
ffffffffc0202772:	3ba60613          	addi	a2,a2,954 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202776:	25e00593          	li	a1,606
ffffffffc020277a:	0000a517          	auipc	a0,0xa
ffffffffc020277e:	aee50513          	addi	a0,a0,-1298 # ffffffffc020c268 <commands+0x990>
ffffffffc0202782:	aadfd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202786:	86d6                	mv	a3,s5
ffffffffc0202788:	0000a617          	auipc	a2,0xa
ffffffffc020278c:	ab860613          	addi	a2,a2,-1352 # ffffffffc020c240 <commands+0x968>
ffffffffc0202790:	25d00593          	li	a1,605
ffffffffc0202794:	0000a517          	auipc	a0,0xa
ffffffffc0202798:	ad450513          	addi	a0,a0,-1324 # ffffffffc020c268 <commands+0x990>
ffffffffc020279c:	a93fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02027a0:	0000a697          	auipc	a3,0xa
ffffffffc02027a4:	ef868693          	addi	a3,a3,-264 # ffffffffc020c698 <commands+0xdc0>
ffffffffc02027a8:	00009617          	auipc	a2,0x9
ffffffffc02027ac:	38060613          	addi	a2,a2,896 # ffffffffc020bb28 <commands+0x250>
ffffffffc02027b0:	26a00593          	li	a1,618
ffffffffc02027b4:	0000a517          	auipc	a0,0xa
ffffffffc02027b8:	ab450513          	addi	a0,a0,-1356 # ffffffffc020c268 <commands+0x990>
ffffffffc02027bc:	a73fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02027c0:	0000a697          	auipc	a3,0xa
ffffffffc02027c4:	ec068693          	addi	a3,a3,-320 # ffffffffc020c680 <commands+0xda8>
ffffffffc02027c8:	00009617          	auipc	a2,0x9
ffffffffc02027cc:	36060613          	addi	a2,a2,864 # ffffffffc020bb28 <commands+0x250>
ffffffffc02027d0:	26900593          	li	a1,617
ffffffffc02027d4:	0000a517          	auipc	a0,0xa
ffffffffc02027d8:	a9450513          	addi	a0,a0,-1388 # ffffffffc020c268 <commands+0x990>
ffffffffc02027dc:	a53fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02027e0:	0000a697          	auipc	a3,0xa
ffffffffc02027e4:	e7068693          	addi	a3,a3,-400 # ffffffffc020c650 <commands+0xd78>
ffffffffc02027e8:	00009617          	auipc	a2,0x9
ffffffffc02027ec:	34060613          	addi	a2,a2,832 # ffffffffc020bb28 <commands+0x250>
ffffffffc02027f0:	26800593          	li	a1,616
ffffffffc02027f4:	0000a517          	auipc	a0,0xa
ffffffffc02027f8:	a7450513          	addi	a0,a0,-1420 # ffffffffc020c268 <commands+0x990>
ffffffffc02027fc:	a33fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202800:	0000a697          	auipc	a3,0xa
ffffffffc0202804:	e3868693          	addi	a3,a3,-456 # ffffffffc020c638 <commands+0xd60>
ffffffffc0202808:	00009617          	auipc	a2,0x9
ffffffffc020280c:	32060613          	addi	a2,a2,800 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202810:	26600593          	li	a1,614
ffffffffc0202814:	0000a517          	auipc	a0,0xa
ffffffffc0202818:	a5450513          	addi	a0,a0,-1452 # ffffffffc020c268 <commands+0x990>
ffffffffc020281c:	a13fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202820:	0000a697          	auipc	a3,0xa
ffffffffc0202824:	df868693          	addi	a3,a3,-520 # ffffffffc020c618 <commands+0xd40>
ffffffffc0202828:	00009617          	auipc	a2,0x9
ffffffffc020282c:	30060613          	addi	a2,a2,768 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202830:	26500593          	li	a1,613
ffffffffc0202834:	0000a517          	auipc	a0,0xa
ffffffffc0202838:	a3450513          	addi	a0,a0,-1484 # ffffffffc020c268 <commands+0x990>
ffffffffc020283c:	9f3fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202840:	0000a697          	auipc	a3,0xa
ffffffffc0202844:	dc868693          	addi	a3,a3,-568 # ffffffffc020c608 <commands+0xd30>
ffffffffc0202848:	00009617          	auipc	a2,0x9
ffffffffc020284c:	2e060613          	addi	a2,a2,736 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202850:	26400593          	li	a1,612
ffffffffc0202854:	0000a517          	auipc	a0,0xa
ffffffffc0202858:	a1450513          	addi	a0,a0,-1516 # ffffffffc020c268 <commands+0x990>
ffffffffc020285c:	9d3fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202860:	0000a697          	auipc	a3,0xa
ffffffffc0202864:	d9868693          	addi	a3,a3,-616 # ffffffffc020c5f8 <commands+0xd20>
ffffffffc0202868:	00009617          	auipc	a2,0x9
ffffffffc020286c:	2c060613          	addi	a2,a2,704 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202870:	26300593          	li	a1,611
ffffffffc0202874:	0000a517          	auipc	a0,0xa
ffffffffc0202878:	9f450513          	addi	a0,a0,-1548 # ffffffffc020c268 <commands+0x990>
ffffffffc020287c:	9b3fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202880:	0000a697          	auipc	a3,0xa
ffffffffc0202884:	d4068693          	addi	a3,a3,-704 # ffffffffc020c5c0 <commands+0xce8>
ffffffffc0202888:	00009617          	auipc	a2,0x9
ffffffffc020288c:	2a060613          	addi	a2,a2,672 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202890:	26200593          	li	a1,610
ffffffffc0202894:	0000a517          	auipc	a0,0xa
ffffffffc0202898:	9d450513          	addi	a0,a0,-1580 # ffffffffc020c268 <commands+0x990>
ffffffffc020289c:	993fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02028a0:	0000a697          	auipc	a3,0xa
ffffffffc02028a4:	e7068693          	addi	a3,a3,-400 # ffffffffc020c710 <commands+0xe38>
ffffffffc02028a8:	00009617          	auipc	a2,0x9
ffffffffc02028ac:	28060613          	addi	a2,a2,640 # ffffffffc020bb28 <commands+0x250>
ffffffffc02028b0:	27f00593          	li	a1,639
ffffffffc02028b4:	0000a517          	auipc	a0,0xa
ffffffffc02028b8:	9b450513          	addi	a0,a0,-1612 # ffffffffc020c268 <commands+0x990>
ffffffffc02028bc:	973fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02028c0:	0000a617          	auipc	a2,0xa
ffffffffc02028c4:	98060613          	addi	a2,a2,-1664 # ffffffffc020c240 <commands+0x968>
ffffffffc02028c8:	07100593          	li	a1,113
ffffffffc02028cc:	0000a517          	auipc	a0,0xa
ffffffffc02028d0:	93c50513          	addi	a0,a0,-1732 # ffffffffc020c208 <commands+0x930>
ffffffffc02028d4:	95bfd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02028d8:	86a2                	mv	a3,s0
ffffffffc02028da:	0000a617          	auipc	a2,0xa
ffffffffc02028de:	a8660613          	addi	a2,a2,-1402 # ffffffffc020c360 <commands+0xa88>
ffffffffc02028e2:	0ca00593          	li	a1,202
ffffffffc02028e6:	0000a517          	auipc	a0,0xa
ffffffffc02028ea:	98250513          	addi	a0,a0,-1662 # ffffffffc020c268 <commands+0x990>
ffffffffc02028ee:	941fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02028f2:	0000a617          	auipc	a2,0xa
ffffffffc02028f6:	a6e60613          	addi	a2,a2,-1426 # ffffffffc020c360 <commands+0xa88>
ffffffffc02028fa:	08100593          	li	a1,129
ffffffffc02028fe:	0000a517          	auipc	a0,0xa
ffffffffc0202902:	96a50513          	addi	a0,a0,-1686 # ffffffffc020c268 <commands+0x990>
ffffffffc0202906:	929fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020290a:	0000a697          	auipc	a3,0xa
ffffffffc020290e:	c7668693          	addi	a3,a3,-906 # ffffffffc020c580 <commands+0xca8>
ffffffffc0202912:	00009617          	auipc	a2,0x9
ffffffffc0202916:	21660613          	addi	a2,a2,534 # ffffffffc020bb28 <commands+0x250>
ffffffffc020291a:	26100593          	li	a1,609
ffffffffc020291e:	0000a517          	auipc	a0,0xa
ffffffffc0202922:	94a50513          	addi	a0,a0,-1718 # ffffffffc020c268 <commands+0x990>
ffffffffc0202926:	909fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020292a:	0000a697          	auipc	a3,0xa
ffffffffc020292e:	b9668693          	addi	a3,a3,-1130 # ffffffffc020c4c0 <commands+0xbe8>
ffffffffc0202932:	00009617          	auipc	a2,0x9
ffffffffc0202936:	1f660613          	addi	a2,a2,502 # ffffffffc020bb28 <commands+0x250>
ffffffffc020293a:	25500593          	li	a1,597
ffffffffc020293e:	0000a517          	auipc	a0,0xa
ffffffffc0202942:	92a50513          	addi	a0,a0,-1750 # ffffffffc020c268 <commands+0x990>
ffffffffc0202946:	8e9fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020294a:	985fe0ef          	jal	ra,ffffffffc02012ce <pte2page.part.0>
ffffffffc020294e:	0000a697          	auipc	a3,0xa
ffffffffc0202952:	ba268693          	addi	a3,a3,-1118 # ffffffffc020c4f0 <commands+0xc18>
ffffffffc0202956:	00009617          	auipc	a2,0x9
ffffffffc020295a:	1d260613          	addi	a2,a2,466 # ffffffffc020bb28 <commands+0x250>
ffffffffc020295e:	25800593          	li	a1,600
ffffffffc0202962:	0000a517          	auipc	a0,0xa
ffffffffc0202966:	90650513          	addi	a0,a0,-1786 # ffffffffc020c268 <commands+0x990>
ffffffffc020296a:	8c5fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020296e:	0000a697          	auipc	a3,0xa
ffffffffc0202972:	b2268693          	addi	a3,a3,-1246 # ffffffffc020c490 <commands+0xbb8>
ffffffffc0202976:	00009617          	auipc	a2,0x9
ffffffffc020297a:	1b260613          	addi	a2,a2,434 # ffffffffc020bb28 <commands+0x250>
ffffffffc020297e:	25100593          	li	a1,593
ffffffffc0202982:	0000a517          	auipc	a0,0xa
ffffffffc0202986:	8e650513          	addi	a0,a0,-1818 # ffffffffc020c268 <commands+0x990>
ffffffffc020298a:	8a5fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020298e:	0000a697          	auipc	a3,0xa
ffffffffc0202992:	b9268693          	addi	a3,a3,-1134 # ffffffffc020c520 <commands+0xc48>
ffffffffc0202996:	00009617          	auipc	a2,0x9
ffffffffc020299a:	19260613          	addi	a2,a2,402 # ffffffffc020bb28 <commands+0x250>
ffffffffc020299e:	25900593          	li	a1,601
ffffffffc02029a2:	0000a517          	auipc	a0,0xa
ffffffffc02029a6:	8c650513          	addi	a0,a0,-1850 # ffffffffc020c268 <commands+0x990>
ffffffffc02029aa:	885fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02029ae:	0000a617          	auipc	a2,0xa
ffffffffc02029b2:	89260613          	addi	a2,a2,-1902 # ffffffffc020c240 <commands+0x968>
ffffffffc02029b6:	25c00593          	li	a1,604
ffffffffc02029ba:	0000a517          	auipc	a0,0xa
ffffffffc02029be:	8ae50513          	addi	a0,a0,-1874 # ffffffffc020c268 <commands+0x990>
ffffffffc02029c2:	86dfd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02029c6:	0000a697          	auipc	a3,0xa
ffffffffc02029ca:	b7268693          	addi	a3,a3,-1166 # ffffffffc020c538 <commands+0xc60>
ffffffffc02029ce:	00009617          	auipc	a2,0x9
ffffffffc02029d2:	15a60613          	addi	a2,a2,346 # ffffffffc020bb28 <commands+0x250>
ffffffffc02029d6:	25a00593          	li	a1,602
ffffffffc02029da:	0000a517          	auipc	a0,0xa
ffffffffc02029de:	88e50513          	addi	a0,a0,-1906 # ffffffffc020c268 <commands+0x990>
ffffffffc02029e2:	84dfd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02029e6:	86ca                	mv	a3,s2
ffffffffc02029e8:	0000a617          	auipc	a2,0xa
ffffffffc02029ec:	97860613          	addi	a2,a2,-1672 # ffffffffc020c360 <commands+0xa88>
ffffffffc02029f0:	0c600593          	li	a1,198
ffffffffc02029f4:	0000a517          	auipc	a0,0xa
ffffffffc02029f8:	87450513          	addi	a0,a0,-1932 # ffffffffc020c268 <commands+0x990>
ffffffffc02029fc:	833fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202a00:	0000a697          	auipc	a3,0xa
ffffffffc0202a04:	c9868693          	addi	a3,a3,-872 # ffffffffc020c698 <commands+0xdc0>
ffffffffc0202a08:	00009617          	auipc	a2,0x9
ffffffffc0202a0c:	12060613          	addi	a2,a2,288 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202a10:	27500593          	li	a1,629
ffffffffc0202a14:	0000a517          	auipc	a0,0xa
ffffffffc0202a18:	85450513          	addi	a0,a0,-1964 # ffffffffc020c268 <commands+0x990>
ffffffffc0202a1c:	813fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202a20:	0000a697          	auipc	a3,0xa
ffffffffc0202a24:	ca868693          	addi	a3,a3,-856 # ffffffffc020c6c8 <commands+0xdf0>
ffffffffc0202a28:	00009617          	auipc	a2,0x9
ffffffffc0202a2c:	10060613          	addi	a2,a2,256 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202a30:	27400593          	li	a1,628
ffffffffc0202a34:	0000a517          	auipc	a0,0xa
ffffffffc0202a38:	83450513          	addi	a0,a0,-1996 # ffffffffc020c268 <commands+0x990>
ffffffffc0202a3c:	ff2fd0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0202a40 <copy_range>:
ffffffffc0202a40:	7159                	addi	sp,sp,-112
ffffffffc0202a42:	00d667b3          	or	a5,a2,a3
ffffffffc0202a46:	f486                	sd	ra,104(sp)
ffffffffc0202a48:	f0a2                	sd	s0,96(sp)
ffffffffc0202a4a:	eca6                	sd	s1,88(sp)
ffffffffc0202a4c:	e8ca                	sd	s2,80(sp)
ffffffffc0202a4e:	e4ce                	sd	s3,72(sp)
ffffffffc0202a50:	e0d2                	sd	s4,64(sp)
ffffffffc0202a52:	fc56                	sd	s5,56(sp)
ffffffffc0202a54:	f85a                	sd	s6,48(sp)
ffffffffc0202a56:	f45e                	sd	s7,40(sp)
ffffffffc0202a58:	f062                	sd	s8,32(sp)
ffffffffc0202a5a:	ec66                	sd	s9,24(sp)
ffffffffc0202a5c:	e86a                	sd	s10,16(sp)
ffffffffc0202a5e:	e46e                	sd	s11,8(sp)
ffffffffc0202a60:	17d2                	slli	a5,a5,0x34
ffffffffc0202a62:	20079f63          	bnez	a5,ffffffffc0202c80 <copy_range+0x240>
ffffffffc0202a66:	002007b7          	lui	a5,0x200
ffffffffc0202a6a:	8432                	mv	s0,a2
ffffffffc0202a6c:	1af66263          	bltu	a2,a5,ffffffffc0202c10 <copy_range+0x1d0>
ffffffffc0202a70:	8936                	mv	s2,a3
ffffffffc0202a72:	18d67f63          	bgeu	a2,a3,ffffffffc0202c10 <copy_range+0x1d0>
ffffffffc0202a76:	4785                	li	a5,1
ffffffffc0202a78:	07fe                	slli	a5,a5,0x1f
ffffffffc0202a7a:	18d7eb63          	bltu	a5,a3,ffffffffc0202c10 <copy_range+0x1d0>
ffffffffc0202a7e:	5b7d                	li	s6,-1
ffffffffc0202a80:	8aaa                	mv	s5,a0
ffffffffc0202a82:	89ae                	mv	s3,a1
ffffffffc0202a84:	6a05                	lui	s4,0x1
ffffffffc0202a86:	00094c17          	auipc	s8,0x94
ffffffffc0202a8a:	e12c0c13          	addi	s8,s8,-494 # ffffffffc0296898 <npage>
ffffffffc0202a8e:	00094b97          	auipc	s7,0x94
ffffffffc0202a92:	e12b8b93          	addi	s7,s7,-494 # ffffffffc02968a0 <pages>
ffffffffc0202a96:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0202a9a:	00094c97          	auipc	s9,0x94
ffffffffc0202a9e:	e0ec8c93          	addi	s9,s9,-498 # ffffffffc02968a8 <pmm_manager>
ffffffffc0202aa2:	4601                	li	a2,0
ffffffffc0202aa4:	85a2                	mv	a1,s0
ffffffffc0202aa6:	854e                	mv	a0,s3
ffffffffc0202aa8:	8fbfe0ef          	jal	ra,ffffffffc02013a2 <get_pte>
ffffffffc0202aac:	84aa                	mv	s1,a0
ffffffffc0202aae:	0e050c63          	beqz	a0,ffffffffc0202ba6 <copy_range+0x166>
ffffffffc0202ab2:	611c                	ld	a5,0(a0)
ffffffffc0202ab4:	8b85                	andi	a5,a5,1
ffffffffc0202ab6:	e785                	bnez	a5,ffffffffc0202ade <copy_range+0x9e>
ffffffffc0202ab8:	9452                	add	s0,s0,s4
ffffffffc0202aba:	ff2464e3          	bltu	s0,s2,ffffffffc0202aa2 <copy_range+0x62>
ffffffffc0202abe:	4501                	li	a0,0
ffffffffc0202ac0:	70a6                	ld	ra,104(sp)
ffffffffc0202ac2:	7406                	ld	s0,96(sp)
ffffffffc0202ac4:	64e6                	ld	s1,88(sp)
ffffffffc0202ac6:	6946                	ld	s2,80(sp)
ffffffffc0202ac8:	69a6                	ld	s3,72(sp)
ffffffffc0202aca:	6a06                	ld	s4,64(sp)
ffffffffc0202acc:	7ae2                	ld	s5,56(sp)
ffffffffc0202ace:	7b42                	ld	s6,48(sp)
ffffffffc0202ad0:	7ba2                	ld	s7,40(sp)
ffffffffc0202ad2:	7c02                	ld	s8,32(sp)
ffffffffc0202ad4:	6ce2                	ld	s9,24(sp)
ffffffffc0202ad6:	6d42                	ld	s10,16(sp)
ffffffffc0202ad8:	6da2                	ld	s11,8(sp)
ffffffffc0202ada:	6165                	addi	sp,sp,112
ffffffffc0202adc:	8082                	ret
ffffffffc0202ade:	4605                	li	a2,1
ffffffffc0202ae0:	85a2                	mv	a1,s0
ffffffffc0202ae2:	8556                	mv	a0,s5
ffffffffc0202ae4:	8bffe0ef          	jal	ra,ffffffffc02013a2 <get_pte>
ffffffffc0202ae8:	c56d                	beqz	a0,ffffffffc0202bd2 <copy_range+0x192>
ffffffffc0202aea:	609c                	ld	a5,0(s1)
ffffffffc0202aec:	0017f713          	andi	a4,a5,1
ffffffffc0202af0:	01f7f493          	andi	s1,a5,31
ffffffffc0202af4:	16070a63          	beqz	a4,ffffffffc0202c68 <copy_range+0x228>
ffffffffc0202af8:	000c3683          	ld	a3,0(s8)
ffffffffc0202afc:	078a                	slli	a5,a5,0x2
ffffffffc0202afe:	00c7d713          	srli	a4,a5,0xc
ffffffffc0202b02:	14d77763          	bgeu	a4,a3,ffffffffc0202c50 <copy_range+0x210>
ffffffffc0202b06:	000bb783          	ld	a5,0(s7)
ffffffffc0202b0a:	fff806b7          	lui	a3,0xfff80
ffffffffc0202b0e:	9736                	add	a4,a4,a3
ffffffffc0202b10:	071a                	slli	a4,a4,0x6
ffffffffc0202b12:	00e78db3          	add	s11,a5,a4
ffffffffc0202b16:	10002773          	csrr	a4,sstatus
ffffffffc0202b1a:	8b09                	andi	a4,a4,2
ffffffffc0202b1c:	e345                	bnez	a4,ffffffffc0202bbc <copy_range+0x17c>
ffffffffc0202b1e:	000cb703          	ld	a4,0(s9)
ffffffffc0202b22:	4505                	li	a0,1
ffffffffc0202b24:	6f18                	ld	a4,24(a4)
ffffffffc0202b26:	9702                	jalr	a4
ffffffffc0202b28:	8d2a                	mv	s10,a0
ffffffffc0202b2a:	0c0d8363          	beqz	s11,ffffffffc0202bf0 <copy_range+0x1b0>
ffffffffc0202b2e:	100d0163          	beqz	s10,ffffffffc0202c30 <copy_range+0x1f0>
ffffffffc0202b32:	000bb703          	ld	a4,0(s7)
ffffffffc0202b36:	000805b7          	lui	a1,0x80
ffffffffc0202b3a:	000c3603          	ld	a2,0(s8)
ffffffffc0202b3e:	40ed86b3          	sub	a3,s11,a4
ffffffffc0202b42:	8699                	srai	a3,a3,0x6
ffffffffc0202b44:	96ae                	add	a3,a3,a1
ffffffffc0202b46:	0166f7b3          	and	a5,a3,s6
ffffffffc0202b4a:	06b2                	slli	a3,a3,0xc
ffffffffc0202b4c:	08c7f663          	bgeu	a5,a2,ffffffffc0202bd8 <copy_range+0x198>
ffffffffc0202b50:	40ed07b3          	sub	a5,s10,a4
ffffffffc0202b54:	00094717          	auipc	a4,0x94
ffffffffc0202b58:	d5c70713          	addi	a4,a4,-676 # ffffffffc02968b0 <va_pa_offset>
ffffffffc0202b5c:	6308                	ld	a0,0(a4)
ffffffffc0202b5e:	8799                	srai	a5,a5,0x6
ffffffffc0202b60:	97ae                	add	a5,a5,a1
ffffffffc0202b62:	0167f733          	and	a4,a5,s6
ffffffffc0202b66:	00a685b3          	add	a1,a3,a0
ffffffffc0202b6a:	07b2                	slli	a5,a5,0xc
ffffffffc0202b6c:	06c77563          	bgeu	a4,a2,ffffffffc0202bd6 <copy_range+0x196>
ffffffffc0202b70:	6605                	lui	a2,0x1
ffffffffc0202b72:	953e                	add	a0,a0,a5
ffffffffc0202b74:	610080ef          	jal	ra,ffffffffc020b184 <memcpy>
ffffffffc0202b78:	86a6                	mv	a3,s1
ffffffffc0202b7a:	8622                	mv	a2,s0
ffffffffc0202b7c:	85ea                	mv	a1,s10
ffffffffc0202b7e:	8556                	mv	a0,s5
ffffffffc0202b80:	fd9fe0ef          	jal	ra,ffffffffc0201b58 <page_insert>
ffffffffc0202b84:	d915                	beqz	a0,ffffffffc0202ab8 <copy_range+0x78>
ffffffffc0202b86:	0000a697          	auipc	a3,0xa
ffffffffc0202b8a:	db268693          	addi	a3,a3,-590 # ffffffffc020c938 <commands+0x1060>
ffffffffc0202b8e:	00009617          	auipc	a2,0x9
ffffffffc0202b92:	f9a60613          	addi	a2,a2,-102 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202b96:	1ed00593          	li	a1,493
ffffffffc0202b9a:	00009517          	auipc	a0,0x9
ffffffffc0202b9e:	6ce50513          	addi	a0,a0,1742 # ffffffffc020c268 <commands+0x990>
ffffffffc0202ba2:	e8cfd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202ba6:	00200637          	lui	a2,0x200
ffffffffc0202baa:	9432                	add	s0,s0,a2
ffffffffc0202bac:	ffe00637          	lui	a2,0xffe00
ffffffffc0202bb0:	8c71                	and	s0,s0,a2
ffffffffc0202bb2:	f00406e3          	beqz	s0,ffffffffc0202abe <copy_range+0x7e>
ffffffffc0202bb6:	ef2466e3          	bltu	s0,s2,ffffffffc0202aa2 <copy_range+0x62>
ffffffffc0202bba:	b711                	j	ffffffffc0202abe <copy_range+0x7e>
ffffffffc0202bbc:	9e4fe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0202bc0:	000cb703          	ld	a4,0(s9)
ffffffffc0202bc4:	4505                	li	a0,1
ffffffffc0202bc6:	6f18                	ld	a4,24(a4)
ffffffffc0202bc8:	9702                	jalr	a4
ffffffffc0202bca:	8d2a                	mv	s10,a0
ffffffffc0202bcc:	9cefe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0202bd0:	bfa9                	j	ffffffffc0202b2a <copy_range+0xea>
ffffffffc0202bd2:	5571                	li	a0,-4
ffffffffc0202bd4:	b5f5                	j	ffffffffc0202ac0 <copy_range+0x80>
ffffffffc0202bd6:	86be                	mv	a3,a5
ffffffffc0202bd8:	00009617          	auipc	a2,0x9
ffffffffc0202bdc:	66860613          	addi	a2,a2,1640 # ffffffffc020c240 <commands+0x968>
ffffffffc0202be0:	07100593          	li	a1,113
ffffffffc0202be4:	00009517          	auipc	a0,0x9
ffffffffc0202be8:	62450513          	addi	a0,a0,1572 # ffffffffc020c208 <commands+0x930>
ffffffffc0202bec:	e42fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202bf0:	0000a697          	auipc	a3,0xa
ffffffffc0202bf4:	d2868693          	addi	a3,a3,-728 # ffffffffc020c918 <commands+0x1040>
ffffffffc0202bf8:	00009617          	auipc	a2,0x9
ffffffffc0202bfc:	f3060613          	addi	a2,a2,-208 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202c00:	1ce00593          	li	a1,462
ffffffffc0202c04:	00009517          	auipc	a0,0x9
ffffffffc0202c08:	66450513          	addi	a0,a0,1636 # ffffffffc020c268 <commands+0x990>
ffffffffc0202c0c:	e22fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202c10:	00009697          	auipc	a3,0x9
ffffffffc0202c14:	6c068693          	addi	a3,a3,1728 # ffffffffc020c2d0 <commands+0x9f8>
ffffffffc0202c18:	00009617          	auipc	a2,0x9
ffffffffc0202c1c:	f1060613          	addi	a2,a2,-240 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202c20:	1b600593          	li	a1,438
ffffffffc0202c24:	00009517          	auipc	a0,0x9
ffffffffc0202c28:	64450513          	addi	a0,a0,1604 # ffffffffc020c268 <commands+0x990>
ffffffffc0202c2c:	e02fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202c30:	0000a697          	auipc	a3,0xa
ffffffffc0202c34:	cf868693          	addi	a3,a3,-776 # ffffffffc020c928 <commands+0x1050>
ffffffffc0202c38:	00009617          	auipc	a2,0x9
ffffffffc0202c3c:	ef060613          	addi	a2,a2,-272 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202c40:	1cf00593          	li	a1,463
ffffffffc0202c44:	00009517          	auipc	a0,0x9
ffffffffc0202c48:	62450513          	addi	a0,a0,1572 # ffffffffc020c268 <commands+0x990>
ffffffffc0202c4c:	de2fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202c50:	00009617          	auipc	a2,0x9
ffffffffc0202c54:	59860613          	addi	a2,a2,1432 # ffffffffc020c1e8 <commands+0x910>
ffffffffc0202c58:	06900593          	li	a1,105
ffffffffc0202c5c:	00009517          	auipc	a0,0x9
ffffffffc0202c60:	5ac50513          	addi	a0,a0,1452 # ffffffffc020c208 <commands+0x930>
ffffffffc0202c64:	dcafd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202c68:	00009617          	auipc	a2,0x9
ffffffffc0202c6c:	5b060613          	addi	a2,a2,1456 # ffffffffc020c218 <commands+0x940>
ffffffffc0202c70:	07f00593          	li	a1,127
ffffffffc0202c74:	00009517          	auipc	a0,0x9
ffffffffc0202c78:	59450513          	addi	a0,a0,1428 # ffffffffc020c208 <commands+0x930>
ffffffffc0202c7c:	db2fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202c80:	00009697          	auipc	a3,0x9
ffffffffc0202c84:	62068693          	addi	a3,a3,1568 # ffffffffc020c2a0 <commands+0x9c8>
ffffffffc0202c88:	00009617          	auipc	a2,0x9
ffffffffc0202c8c:	ea060613          	addi	a2,a2,-352 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202c90:	1b500593          	li	a1,437
ffffffffc0202c94:	00009517          	auipc	a0,0x9
ffffffffc0202c98:	5d450513          	addi	a0,a0,1492 # ffffffffc020c268 <commands+0x990>
ffffffffc0202c9c:	d92fd0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0202ca0 <pgdir_alloc_page>:
ffffffffc0202ca0:	7179                	addi	sp,sp,-48
ffffffffc0202ca2:	ec26                	sd	s1,24(sp)
ffffffffc0202ca4:	e84a                	sd	s2,16(sp)
ffffffffc0202ca6:	e052                	sd	s4,0(sp)
ffffffffc0202ca8:	f406                	sd	ra,40(sp)
ffffffffc0202caa:	f022                	sd	s0,32(sp)
ffffffffc0202cac:	e44e                	sd	s3,8(sp)
ffffffffc0202cae:	8a2a                	mv	s4,a0
ffffffffc0202cb0:	84ae                	mv	s1,a1
ffffffffc0202cb2:	8932                	mv	s2,a2
ffffffffc0202cb4:	100027f3          	csrr	a5,sstatus
ffffffffc0202cb8:	8b89                	andi	a5,a5,2
ffffffffc0202cba:	00094997          	auipc	s3,0x94
ffffffffc0202cbe:	bee98993          	addi	s3,s3,-1042 # ffffffffc02968a8 <pmm_manager>
ffffffffc0202cc2:	ef8d                	bnez	a5,ffffffffc0202cfc <pgdir_alloc_page+0x5c>
ffffffffc0202cc4:	0009b783          	ld	a5,0(s3)
ffffffffc0202cc8:	4505                	li	a0,1
ffffffffc0202cca:	6f9c                	ld	a5,24(a5)
ffffffffc0202ccc:	9782                	jalr	a5
ffffffffc0202cce:	842a                	mv	s0,a0
ffffffffc0202cd0:	cc09                	beqz	s0,ffffffffc0202cea <pgdir_alloc_page+0x4a>
ffffffffc0202cd2:	86ca                	mv	a3,s2
ffffffffc0202cd4:	8626                	mv	a2,s1
ffffffffc0202cd6:	85a2                	mv	a1,s0
ffffffffc0202cd8:	8552                	mv	a0,s4
ffffffffc0202cda:	e7ffe0ef          	jal	ra,ffffffffc0201b58 <page_insert>
ffffffffc0202cde:	e915                	bnez	a0,ffffffffc0202d12 <pgdir_alloc_page+0x72>
ffffffffc0202ce0:	4018                	lw	a4,0(s0)
ffffffffc0202ce2:	fc04                	sd	s1,56(s0)
ffffffffc0202ce4:	4785                	li	a5,1
ffffffffc0202ce6:	04f71e63          	bne	a4,a5,ffffffffc0202d42 <pgdir_alloc_page+0xa2>
ffffffffc0202cea:	70a2                	ld	ra,40(sp)
ffffffffc0202cec:	8522                	mv	a0,s0
ffffffffc0202cee:	7402                	ld	s0,32(sp)
ffffffffc0202cf0:	64e2                	ld	s1,24(sp)
ffffffffc0202cf2:	6942                	ld	s2,16(sp)
ffffffffc0202cf4:	69a2                	ld	s3,8(sp)
ffffffffc0202cf6:	6a02                	ld	s4,0(sp)
ffffffffc0202cf8:	6145                	addi	sp,sp,48
ffffffffc0202cfa:	8082                	ret
ffffffffc0202cfc:	8a4fe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0202d00:	0009b783          	ld	a5,0(s3)
ffffffffc0202d04:	4505                	li	a0,1
ffffffffc0202d06:	6f9c                	ld	a5,24(a5)
ffffffffc0202d08:	9782                	jalr	a5
ffffffffc0202d0a:	842a                	mv	s0,a0
ffffffffc0202d0c:	88efe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0202d10:	b7c1                	j	ffffffffc0202cd0 <pgdir_alloc_page+0x30>
ffffffffc0202d12:	100027f3          	csrr	a5,sstatus
ffffffffc0202d16:	8b89                	andi	a5,a5,2
ffffffffc0202d18:	eb89                	bnez	a5,ffffffffc0202d2a <pgdir_alloc_page+0x8a>
ffffffffc0202d1a:	0009b783          	ld	a5,0(s3)
ffffffffc0202d1e:	8522                	mv	a0,s0
ffffffffc0202d20:	4585                	li	a1,1
ffffffffc0202d22:	739c                	ld	a5,32(a5)
ffffffffc0202d24:	4401                	li	s0,0
ffffffffc0202d26:	9782                	jalr	a5
ffffffffc0202d28:	b7c9                	j	ffffffffc0202cea <pgdir_alloc_page+0x4a>
ffffffffc0202d2a:	876fe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0202d2e:	0009b783          	ld	a5,0(s3)
ffffffffc0202d32:	8522                	mv	a0,s0
ffffffffc0202d34:	4585                	li	a1,1
ffffffffc0202d36:	739c                	ld	a5,32(a5)
ffffffffc0202d38:	4401                	li	s0,0
ffffffffc0202d3a:	9782                	jalr	a5
ffffffffc0202d3c:	85efe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0202d40:	b76d                	j	ffffffffc0202cea <pgdir_alloc_page+0x4a>
ffffffffc0202d42:	0000a697          	auipc	a3,0xa
ffffffffc0202d46:	c0668693          	addi	a3,a3,-1018 # ffffffffc020c948 <commands+0x1070>
ffffffffc0202d4a:	00009617          	auipc	a2,0x9
ffffffffc0202d4e:	dde60613          	addi	a2,a2,-546 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202d52:	23600593          	li	a1,566
ffffffffc0202d56:	00009517          	auipc	a0,0x9
ffffffffc0202d5a:	51250513          	addi	a0,a0,1298 # ffffffffc020c268 <commands+0x990>
ffffffffc0202d5e:	cd0fd0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0202d62 <check_vma_overlap.part.0>:
ffffffffc0202d62:	1141                	addi	sp,sp,-16
ffffffffc0202d64:	0000a697          	auipc	a3,0xa
ffffffffc0202d68:	bfc68693          	addi	a3,a3,-1028 # ffffffffc020c960 <commands+0x1088>
ffffffffc0202d6c:	00009617          	auipc	a2,0x9
ffffffffc0202d70:	dbc60613          	addi	a2,a2,-580 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202d74:	07400593          	li	a1,116
ffffffffc0202d78:	0000a517          	auipc	a0,0xa
ffffffffc0202d7c:	c0850513          	addi	a0,a0,-1016 # ffffffffc020c980 <commands+0x10a8>
ffffffffc0202d80:	e406                	sd	ra,8(sp)
ffffffffc0202d82:	cacfd0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0202d86 <mm_create>:
ffffffffc0202d86:	1141                	addi	sp,sp,-16
ffffffffc0202d88:	05800513          	li	a0,88
ffffffffc0202d8c:	e022                	sd	s0,0(sp)
ffffffffc0202d8e:	e406                	sd	ra,8(sp)
ffffffffc0202d90:	233000ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc0202d94:	842a                	mv	s0,a0
ffffffffc0202d96:	c115                	beqz	a0,ffffffffc0202dba <mm_create+0x34>
ffffffffc0202d98:	e408                	sd	a0,8(s0)
ffffffffc0202d9a:	e008                	sd	a0,0(s0)
ffffffffc0202d9c:	00053823          	sd	zero,16(a0)
ffffffffc0202da0:	00053c23          	sd	zero,24(a0)
ffffffffc0202da4:	02052023          	sw	zero,32(a0)
ffffffffc0202da8:	02053423          	sd	zero,40(a0)
ffffffffc0202dac:	02052823          	sw	zero,48(a0)
ffffffffc0202db0:	4585                	li	a1,1
ffffffffc0202db2:	03850513          	addi	a0,a0,56
ffffffffc0202db6:	189010ef          	jal	ra,ffffffffc020473e <sem_init>
ffffffffc0202dba:	60a2                	ld	ra,8(sp)
ffffffffc0202dbc:	8522                	mv	a0,s0
ffffffffc0202dbe:	6402                	ld	s0,0(sp)
ffffffffc0202dc0:	0141                	addi	sp,sp,16
ffffffffc0202dc2:	8082                	ret

ffffffffc0202dc4 <find_vma>:
ffffffffc0202dc4:	86aa                	mv	a3,a0
ffffffffc0202dc6:	c505                	beqz	a0,ffffffffc0202dee <find_vma+0x2a>
ffffffffc0202dc8:	6908                	ld	a0,16(a0)
ffffffffc0202dca:	c501                	beqz	a0,ffffffffc0202dd2 <find_vma+0xe>
ffffffffc0202dcc:	651c                	ld	a5,8(a0)
ffffffffc0202dce:	02f5f263          	bgeu	a1,a5,ffffffffc0202df2 <find_vma+0x2e>
ffffffffc0202dd2:	669c                	ld	a5,8(a3)
ffffffffc0202dd4:	00f68d63          	beq	a3,a5,ffffffffc0202dee <find_vma+0x2a>
ffffffffc0202dd8:	fe87b703          	ld	a4,-24(a5) # 1fffe8 <_binary_bin_sfs_img_size+0x18ace8>
ffffffffc0202ddc:	00e5e663          	bltu	a1,a4,ffffffffc0202de8 <find_vma+0x24>
ffffffffc0202de0:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202de4:	00e5ec63          	bltu	a1,a4,ffffffffc0202dfc <find_vma+0x38>
ffffffffc0202de8:	679c                	ld	a5,8(a5)
ffffffffc0202dea:	fef697e3          	bne	a3,a5,ffffffffc0202dd8 <find_vma+0x14>
ffffffffc0202dee:	4501                	li	a0,0
ffffffffc0202df0:	8082                	ret
ffffffffc0202df2:	691c                	ld	a5,16(a0)
ffffffffc0202df4:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0202dd2 <find_vma+0xe>
ffffffffc0202df8:	ea88                	sd	a0,16(a3)
ffffffffc0202dfa:	8082                	ret
ffffffffc0202dfc:	fe078513          	addi	a0,a5,-32
ffffffffc0202e00:	ea88                	sd	a0,16(a3)
ffffffffc0202e02:	8082                	ret

ffffffffc0202e04 <insert_vma_struct>:
ffffffffc0202e04:	6590                	ld	a2,8(a1)
ffffffffc0202e06:	0105b803          	ld	a6,16(a1) # 80010 <_binary_bin_sfs_img_size+0xad10>
ffffffffc0202e0a:	1141                	addi	sp,sp,-16
ffffffffc0202e0c:	e406                	sd	ra,8(sp)
ffffffffc0202e0e:	87aa                	mv	a5,a0
ffffffffc0202e10:	01066763          	bltu	a2,a6,ffffffffc0202e1e <insert_vma_struct+0x1a>
ffffffffc0202e14:	a085                	j	ffffffffc0202e74 <insert_vma_struct+0x70>
ffffffffc0202e16:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202e1a:	04e66863          	bltu	a2,a4,ffffffffc0202e6a <insert_vma_struct+0x66>
ffffffffc0202e1e:	86be                	mv	a3,a5
ffffffffc0202e20:	679c                	ld	a5,8(a5)
ffffffffc0202e22:	fef51ae3          	bne	a0,a5,ffffffffc0202e16 <insert_vma_struct+0x12>
ffffffffc0202e26:	02a68463          	beq	a3,a0,ffffffffc0202e4e <insert_vma_struct+0x4a>
ffffffffc0202e2a:	ff06b703          	ld	a4,-16(a3)
ffffffffc0202e2e:	fe86b883          	ld	a7,-24(a3)
ffffffffc0202e32:	08e8f163          	bgeu	a7,a4,ffffffffc0202eb4 <insert_vma_struct+0xb0>
ffffffffc0202e36:	04e66f63          	bltu	a2,a4,ffffffffc0202e94 <insert_vma_struct+0x90>
ffffffffc0202e3a:	00f50a63          	beq	a0,a5,ffffffffc0202e4e <insert_vma_struct+0x4a>
ffffffffc0202e3e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202e42:	05076963          	bltu	a4,a6,ffffffffc0202e94 <insert_vma_struct+0x90>
ffffffffc0202e46:	ff07b603          	ld	a2,-16(a5)
ffffffffc0202e4a:	02c77363          	bgeu	a4,a2,ffffffffc0202e70 <insert_vma_struct+0x6c>
ffffffffc0202e4e:	5118                	lw	a4,32(a0)
ffffffffc0202e50:	e188                	sd	a0,0(a1)
ffffffffc0202e52:	02058613          	addi	a2,a1,32
ffffffffc0202e56:	e390                	sd	a2,0(a5)
ffffffffc0202e58:	e690                	sd	a2,8(a3)
ffffffffc0202e5a:	60a2                	ld	ra,8(sp)
ffffffffc0202e5c:	f59c                	sd	a5,40(a1)
ffffffffc0202e5e:	f194                	sd	a3,32(a1)
ffffffffc0202e60:	0017079b          	addiw	a5,a4,1
ffffffffc0202e64:	d11c                	sw	a5,32(a0)
ffffffffc0202e66:	0141                	addi	sp,sp,16
ffffffffc0202e68:	8082                	ret
ffffffffc0202e6a:	fca690e3          	bne	a3,a0,ffffffffc0202e2a <insert_vma_struct+0x26>
ffffffffc0202e6e:	bfd1                	j	ffffffffc0202e42 <insert_vma_struct+0x3e>
ffffffffc0202e70:	ef3ff0ef          	jal	ra,ffffffffc0202d62 <check_vma_overlap.part.0>
ffffffffc0202e74:	0000a697          	auipc	a3,0xa
ffffffffc0202e78:	b1c68693          	addi	a3,a3,-1252 # ffffffffc020c990 <commands+0x10b8>
ffffffffc0202e7c:	00009617          	auipc	a2,0x9
ffffffffc0202e80:	cac60613          	addi	a2,a2,-852 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202e84:	07a00593          	li	a1,122
ffffffffc0202e88:	0000a517          	auipc	a0,0xa
ffffffffc0202e8c:	af850513          	addi	a0,a0,-1288 # ffffffffc020c980 <commands+0x10a8>
ffffffffc0202e90:	b9efd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202e94:	0000a697          	auipc	a3,0xa
ffffffffc0202e98:	b3c68693          	addi	a3,a3,-1220 # ffffffffc020c9d0 <commands+0x10f8>
ffffffffc0202e9c:	00009617          	auipc	a2,0x9
ffffffffc0202ea0:	c8c60613          	addi	a2,a2,-884 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202ea4:	07300593          	li	a1,115
ffffffffc0202ea8:	0000a517          	auipc	a0,0xa
ffffffffc0202eac:	ad850513          	addi	a0,a0,-1320 # ffffffffc020c980 <commands+0x10a8>
ffffffffc0202eb0:	b7efd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202eb4:	0000a697          	auipc	a3,0xa
ffffffffc0202eb8:	afc68693          	addi	a3,a3,-1284 # ffffffffc020c9b0 <commands+0x10d8>
ffffffffc0202ebc:	00009617          	auipc	a2,0x9
ffffffffc0202ec0:	c6c60613          	addi	a2,a2,-916 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202ec4:	07200593          	li	a1,114
ffffffffc0202ec8:	0000a517          	auipc	a0,0xa
ffffffffc0202ecc:	ab850513          	addi	a0,a0,-1352 # ffffffffc020c980 <commands+0x10a8>
ffffffffc0202ed0:	b5efd0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0202ed4 <mm_destroy>:
ffffffffc0202ed4:	591c                	lw	a5,48(a0)
ffffffffc0202ed6:	1141                	addi	sp,sp,-16
ffffffffc0202ed8:	e406                	sd	ra,8(sp)
ffffffffc0202eda:	e022                	sd	s0,0(sp)
ffffffffc0202edc:	e78d                	bnez	a5,ffffffffc0202f06 <mm_destroy+0x32>
ffffffffc0202ede:	842a                	mv	s0,a0
ffffffffc0202ee0:	6508                	ld	a0,8(a0)
ffffffffc0202ee2:	00a40c63          	beq	s0,a0,ffffffffc0202efa <mm_destroy+0x26>
ffffffffc0202ee6:	6118                	ld	a4,0(a0)
ffffffffc0202ee8:	651c                	ld	a5,8(a0)
ffffffffc0202eea:	1501                	addi	a0,a0,-32
ffffffffc0202eec:	e71c                	sd	a5,8(a4)
ffffffffc0202eee:	e398                	sd	a4,0(a5)
ffffffffc0202ef0:	183000ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc0202ef4:	6408                	ld	a0,8(s0)
ffffffffc0202ef6:	fea418e3          	bne	s0,a0,ffffffffc0202ee6 <mm_destroy+0x12>
ffffffffc0202efa:	8522                	mv	a0,s0
ffffffffc0202efc:	6402                	ld	s0,0(sp)
ffffffffc0202efe:	60a2                	ld	ra,8(sp)
ffffffffc0202f00:	0141                	addi	sp,sp,16
ffffffffc0202f02:	1710006f          	j	ffffffffc0203872 <kfree>
ffffffffc0202f06:	0000a697          	auipc	a3,0xa
ffffffffc0202f0a:	aea68693          	addi	a3,a3,-1302 # ffffffffc020c9f0 <commands+0x1118>
ffffffffc0202f0e:	00009617          	auipc	a2,0x9
ffffffffc0202f12:	c1a60613          	addi	a2,a2,-998 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202f16:	09e00593          	li	a1,158
ffffffffc0202f1a:	0000a517          	auipc	a0,0xa
ffffffffc0202f1e:	a6650513          	addi	a0,a0,-1434 # ffffffffc020c980 <commands+0x10a8>
ffffffffc0202f22:	b0cfd0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0202f26 <mm_map>:
ffffffffc0202f26:	7139                	addi	sp,sp,-64
ffffffffc0202f28:	f822                	sd	s0,48(sp)
ffffffffc0202f2a:	6405                	lui	s0,0x1
ffffffffc0202f2c:	147d                	addi	s0,s0,-1
ffffffffc0202f2e:	77fd                	lui	a5,0xfffff
ffffffffc0202f30:	9622                	add	a2,a2,s0
ffffffffc0202f32:	962e                	add	a2,a2,a1
ffffffffc0202f34:	f426                	sd	s1,40(sp)
ffffffffc0202f36:	fc06                	sd	ra,56(sp)
ffffffffc0202f38:	00f5f4b3          	and	s1,a1,a5
ffffffffc0202f3c:	f04a                	sd	s2,32(sp)
ffffffffc0202f3e:	ec4e                	sd	s3,24(sp)
ffffffffc0202f40:	e852                	sd	s4,16(sp)
ffffffffc0202f42:	e456                	sd	s5,8(sp)
ffffffffc0202f44:	002005b7          	lui	a1,0x200
ffffffffc0202f48:	00f67433          	and	s0,a2,a5
ffffffffc0202f4c:	06b4e363          	bltu	s1,a1,ffffffffc0202fb2 <mm_map+0x8c>
ffffffffc0202f50:	0684f163          	bgeu	s1,s0,ffffffffc0202fb2 <mm_map+0x8c>
ffffffffc0202f54:	4785                	li	a5,1
ffffffffc0202f56:	07fe                	slli	a5,a5,0x1f
ffffffffc0202f58:	0487ed63          	bltu	a5,s0,ffffffffc0202fb2 <mm_map+0x8c>
ffffffffc0202f5c:	89aa                	mv	s3,a0
ffffffffc0202f5e:	cd21                	beqz	a0,ffffffffc0202fb6 <mm_map+0x90>
ffffffffc0202f60:	85a6                	mv	a1,s1
ffffffffc0202f62:	8ab6                	mv	s5,a3
ffffffffc0202f64:	8a3a                	mv	s4,a4
ffffffffc0202f66:	e5fff0ef          	jal	ra,ffffffffc0202dc4 <find_vma>
ffffffffc0202f6a:	c501                	beqz	a0,ffffffffc0202f72 <mm_map+0x4c>
ffffffffc0202f6c:	651c                	ld	a5,8(a0)
ffffffffc0202f6e:	0487e263          	bltu	a5,s0,ffffffffc0202fb2 <mm_map+0x8c>
ffffffffc0202f72:	03000513          	li	a0,48
ffffffffc0202f76:	04d000ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc0202f7a:	892a                	mv	s2,a0
ffffffffc0202f7c:	5571                	li	a0,-4
ffffffffc0202f7e:	02090163          	beqz	s2,ffffffffc0202fa0 <mm_map+0x7a>
ffffffffc0202f82:	854e                	mv	a0,s3
ffffffffc0202f84:	00993423          	sd	s1,8(s2)
ffffffffc0202f88:	00893823          	sd	s0,16(s2)
ffffffffc0202f8c:	01592c23          	sw	s5,24(s2)
ffffffffc0202f90:	85ca                	mv	a1,s2
ffffffffc0202f92:	e73ff0ef          	jal	ra,ffffffffc0202e04 <insert_vma_struct>
ffffffffc0202f96:	4501                	li	a0,0
ffffffffc0202f98:	000a0463          	beqz	s4,ffffffffc0202fa0 <mm_map+0x7a>
ffffffffc0202f9c:	012a3023          	sd	s2,0(s4) # 1000 <_binary_bin_swap_img_size-0x6d00>
ffffffffc0202fa0:	70e2                	ld	ra,56(sp)
ffffffffc0202fa2:	7442                	ld	s0,48(sp)
ffffffffc0202fa4:	74a2                	ld	s1,40(sp)
ffffffffc0202fa6:	7902                	ld	s2,32(sp)
ffffffffc0202fa8:	69e2                	ld	s3,24(sp)
ffffffffc0202faa:	6a42                	ld	s4,16(sp)
ffffffffc0202fac:	6aa2                	ld	s5,8(sp)
ffffffffc0202fae:	6121                	addi	sp,sp,64
ffffffffc0202fb0:	8082                	ret
ffffffffc0202fb2:	5575                	li	a0,-3
ffffffffc0202fb4:	b7f5                	j	ffffffffc0202fa0 <mm_map+0x7a>
ffffffffc0202fb6:	0000a697          	auipc	a3,0xa
ffffffffc0202fba:	a5268693          	addi	a3,a3,-1454 # ffffffffc020ca08 <commands+0x1130>
ffffffffc0202fbe:	00009617          	auipc	a2,0x9
ffffffffc0202fc2:	b6a60613          	addi	a2,a2,-1174 # ffffffffc020bb28 <commands+0x250>
ffffffffc0202fc6:	0b300593          	li	a1,179
ffffffffc0202fca:	0000a517          	auipc	a0,0xa
ffffffffc0202fce:	9b650513          	addi	a0,a0,-1610 # ffffffffc020c980 <commands+0x10a8>
ffffffffc0202fd2:	a5cfd0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0202fd6 <dup_mmap>:
ffffffffc0202fd6:	7139                	addi	sp,sp,-64
ffffffffc0202fd8:	fc06                	sd	ra,56(sp)
ffffffffc0202fda:	f822                	sd	s0,48(sp)
ffffffffc0202fdc:	f426                	sd	s1,40(sp)
ffffffffc0202fde:	f04a                	sd	s2,32(sp)
ffffffffc0202fe0:	ec4e                	sd	s3,24(sp)
ffffffffc0202fe2:	e852                	sd	s4,16(sp)
ffffffffc0202fe4:	e456                	sd	s5,8(sp)
ffffffffc0202fe6:	c52d                	beqz	a0,ffffffffc0203050 <dup_mmap+0x7a>
ffffffffc0202fe8:	892a                	mv	s2,a0
ffffffffc0202fea:	84ae                	mv	s1,a1
ffffffffc0202fec:	842e                	mv	s0,a1
ffffffffc0202fee:	e595                	bnez	a1,ffffffffc020301a <dup_mmap+0x44>
ffffffffc0202ff0:	a085                	j	ffffffffc0203050 <dup_mmap+0x7a>
ffffffffc0202ff2:	854a                	mv	a0,s2
ffffffffc0202ff4:	0155b423          	sd	s5,8(a1) # 200008 <_binary_bin_sfs_img_size+0x18ad08>
ffffffffc0202ff8:	0145b823          	sd	s4,16(a1)
ffffffffc0202ffc:	0135ac23          	sw	s3,24(a1)
ffffffffc0203000:	e05ff0ef          	jal	ra,ffffffffc0202e04 <insert_vma_struct>
ffffffffc0203004:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_bin_swap_img_size-0x6d10>
ffffffffc0203008:	fe843603          	ld	a2,-24(s0)
ffffffffc020300c:	6c8c                	ld	a1,24(s1)
ffffffffc020300e:	01893503          	ld	a0,24(s2)
ffffffffc0203012:	4701                	li	a4,0
ffffffffc0203014:	a2dff0ef          	jal	ra,ffffffffc0202a40 <copy_range>
ffffffffc0203018:	e105                	bnez	a0,ffffffffc0203038 <dup_mmap+0x62>
ffffffffc020301a:	6000                	ld	s0,0(s0)
ffffffffc020301c:	02848863          	beq	s1,s0,ffffffffc020304c <dup_mmap+0x76>
ffffffffc0203020:	03000513          	li	a0,48
ffffffffc0203024:	fe843a83          	ld	s5,-24(s0)
ffffffffc0203028:	ff043a03          	ld	s4,-16(s0)
ffffffffc020302c:	ff842983          	lw	s3,-8(s0)
ffffffffc0203030:	792000ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc0203034:	85aa                	mv	a1,a0
ffffffffc0203036:	fd55                	bnez	a0,ffffffffc0202ff2 <dup_mmap+0x1c>
ffffffffc0203038:	5571                	li	a0,-4
ffffffffc020303a:	70e2                	ld	ra,56(sp)
ffffffffc020303c:	7442                	ld	s0,48(sp)
ffffffffc020303e:	74a2                	ld	s1,40(sp)
ffffffffc0203040:	7902                	ld	s2,32(sp)
ffffffffc0203042:	69e2                	ld	s3,24(sp)
ffffffffc0203044:	6a42                	ld	s4,16(sp)
ffffffffc0203046:	6aa2                	ld	s5,8(sp)
ffffffffc0203048:	6121                	addi	sp,sp,64
ffffffffc020304a:	8082                	ret
ffffffffc020304c:	4501                	li	a0,0
ffffffffc020304e:	b7f5                	j	ffffffffc020303a <dup_mmap+0x64>
ffffffffc0203050:	0000a697          	auipc	a3,0xa
ffffffffc0203054:	9c868693          	addi	a3,a3,-1592 # ffffffffc020ca18 <commands+0x1140>
ffffffffc0203058:	00009617          	auipc	a2,0x9
ffffffffc020305c:	ad060613          	addi	a2,a2,-1328 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203060:	0cf00593          	li	a1,207
ffffffffc0203064:	0000a517          	auipc	a0,0xa
ffffffffc0203068:	91c50513          	addi	a0,a0,-1764 # ffffffffc020c980 <commands+0x10a8>
ffffffffc020306c:	9c2fd0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0203070 <exit_mmap>:
ffffffffc0203070:	1101                	addi	sp,sp,-32
ffffffffc0203072:	ec06                	sd	ra,24(sp)
ffffffffc0203074:	e822                	sd	s0,16(sp)
ffffffffc0203076:	e426                	sd	s1,8(sp)
ffffffffc0203078:	e04a                	sd	s2,0(sp)
ffffffffc020307a:	c531                	beqz	a0,ffffffffc02030c6 <exit_mmap+0x56>
ffffffffc020307c:	591c                	lw	a5,48(a0)
ffffffffc020307e:	84aa                	mv	s1,a0
ffffffffc0203080:	e3b9                	bnez	a5,ffffffffc02030c6 <exit_mmap+0x56>
ffffffffc0203082:	6500                	ld	s0,8(a0)
ffffffffc0203084:	01853903          	ld	s2,24(a0)
ffffffffc0203088:	02850663          	beq	a0,s0,ffffffffc02030b4 <exit_mmap+0x44>
ffffffffc020308c:	ff043603          	ld	a2,-16(s0)
ffffffffc0203090:	fe843583          	ld	a1,-24(s0)
ffffffffc0203094:	854a                	mv	a0,s2
ffffffffc0203096:	e4efe0ef          	jal	ra,ffffffffc02016e4 <unmap_range>
ffffffffc020309a:	6400                	ld	s0,8(s0)
ffffffffc020309c:	fe8498e3          	bne	s1,s0,ffffffffc020308c <exit_mmap+0x1c>
ffffffffc02030a0:	6400                	ld	s0,8(s0)
ffffffffc02030a2:	00848c63          	beq	s1,s0,ffffffffc02030ba <exit_mmap+0x4a>
ffffffffc02030a6:	ff043603          	ld	a2,-16(s0)
ffffffffc02030aa:	fe843583          	ld	a1,-24(s0)
ffffffffc02030ae:	854a                	mv	a0,s2
ffffffffc02030b0:	f7afe0ef          	jal	ra,ffffffffc020182a <exit_range>
ffffffffc02030b4:	6400                	ld	s0,8(s0)
ffffffffc02030b6:	fe8498e3          	bne	s1,s0,ffffffffc02030a6 <exit_mmap+0x36>
ffffffffc02030ba:	60e2                	ld	ra,24(sp)
ffffffffc02030bc:	6442                	ld	s0,16(sp)
ffffffffc02030be:	64a2                	ld	s1,8(sp)
ffffffffc02030c0:	6902                	ld	s2,0(sp)
ffffffffc02030c2:	6105                	addi	sp,sp,32
ffffffffc02030c4:	8082                	ret
ffffffffc02030c6:	0000a697          	auipc	a3,0xa
ffffffffc02030ca:	97268693          	addi	a3,a3,-1678 # ffffffffc020ca38 <commands+0x1160>
ffffffffc02030ce:	00009617          	auipc	a2,0x9
ffffffffc02030d2:	a5a60613          	addi	a2,a2,-1446 # ffffffffc020bb28 <commands+0x250>
ffffffffc02030d6:	0e800593          	li	a1,232
ffffffffc02030da:	0000a517          	auipc	a0,0xa
ffffffffc02030de:	8a650513          	addi	a0,a0,-1882 # ffffffffc020c980 <commands+0x10a8>
ffffffffc02030e2:	94cfd0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02030e6 <vmm_init>:
ffffffffc02030e6:	7139                	addi	sp,sp,-64
ffffffffc02030e8:	05800513          	li	a0,88
ffffffffc02030ec:	fc06                	sd	ra,56(sp)
ffffffffc02030ee:	f822                	sd	s0,48(sp)
ffffffffc02030f0:	f426                	sd	s1,40(sp)
ffffffffc02030f2:	f04a                	sd	s2,32(sp)
ffffffffc02030f4:	ec4e                	sd	s3,24(sp)
ffffffffc02030f6:	e852                	sd	s4,16(sp)
ffffffffc02030f8:	e456                	sd	s5,8(sp)
ffffffffc02030fa:	6c8000ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc02030fe:	2e050963          	beqz	a0,ffffffffc02033f0 <vmm_init+0x30a>
ffffffffc0203102:	e508                	sd	a0,8(a0)
ffffffffc0203104:	e108                	sd	a0,0(a0)
ffffffffc0203106:	00053823          	sd	zero,16(a0)
ffffffffc020310a:	00053c23          	sd	zero,24(a0)
ffffffffc020310e:	02052023          	sw	zero,32(a0)
ffffffffc0203112:	02053423          	sd	zero,40(a0)
ffffffffc0203116:	02052823          	sw	zero,48(a0)
ffffffffc020311a:	84aa                	mv	s1,a0
ffffffffc020311c:	4585                	li	a1,1
ffffffffc020311e:	03850513          	addi	a0,a0,56
ffffffffc0203122:	61c010ef          	jal	ra,ffffffffc020473e <sem_init>
ffffffffc0203126:	03200413          	li	s0,50
ffffffffc020312a:	a811                	j	ffffffffc020313e <vmm_init+0x58>
ffffffffc020312c:	e500                	sd	s0,8(a0)
ffffffffc020312e:	e91c                	sd	a5,16(a0)
ffffffffc0203130:	00052c23          	sw	zero,24(a0)
ffffffffc0203134:	146d                	addi	s0,s0,-5
ffffffffc0203136:	8526                	mv	a0,s1
ffffffffc0203138:	ccdff0ef          	jal	ra,ffffffffc0202e04 <insert_vma_struct>
ffffffffc020313c:	c80d                	beqz	s0,ffffffffc020316e <vmm_init+0x88>
ffffffffc020313e:	03000513          	li	a0,48
ffffffffc0203142:	680000ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc0203146:	85aa                	mv	a1,a0
ffffffffc0203148:	00240793          	addi	a5,s0,2
ffffffffc020314c:	f165                	bnez	a0,ffffffffc020312c <vmm_init+0x46>
ffffffffc020314e:	0000a697          	auipc	a3,0xa
ffffffffc0203152:	a8268693          	addi	a3,a3,-1406 # ffffffffc020cbd0 <commands+0x12f8>
ffffffffc0203156:	00009617          	auipc	a2,0x9
ffffffffc020315a:	9d260613          	addi	a2,a2,-1582 # ffffffffc020bb28 <commands+0x250>
ffffffffc020315e:	12c00593          	li	a1,300
ffffffffc0203162:	0000a517          	auipc	a0,0xa
ffffffffc0203166:	81e50513          	addi	a0,a0,-2018 # ffffffffc020c980 <commands+0x10a8>
ffffffffc020316a:	8c4fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020316e:	03700413          	li	s0,55
ffffffffc0203172:	1f900913          	li	s2,505
ffffffffc0203176:	a819                	j	ffffffffc020318c <vmm_init+0xa6>
ffffffffc0203178:	e500                	sd	s0,8(a0)
ffffffffc020317a:	e91c                	sd	a5,16(a0)
ffffffffc020317c:	00052c23          	sw	zero,24(a0)
ffffffffc0203180:	0415                	addi	s0,s0,5
ffffffffc0203182:	8526                	mv	a0,s1
ffffffffc0203184:	c81ff0ef          	jal	ra,ffffffffc0202e04 <insert_vma_struct>
ffffffffc0203188:	03240a63          	beq	s0,s2,ffffffffc02031bc <vmm_init+0xd6>
ffffffffc020318c:	03000513          	li	a0,48
ffffffffc0203190:	632000ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc0203194:	85aa                	mv	a1,a0
ffffffffc0203196:	00240793          	addi	a5,s0,2
ffffffffc020319a:	fd79                	bnez	a0,ffffffffc0203178 <vmm_init+0x92>
ffffffffc020319c:	0000a697          	auipc	a3,0xa
ffffffffc02031a0:	a3468693          	addi	a3,a3,-1484 # ffffffffc020cbd0 <commands+0x12f8>
ffffffffc02031a4:	00009617          	auipc	a2,0x9
ffffffffc02031a8:	98460613          	addi	a2,a2,-1660 # ffffffffc020bb28 <commands+0x250>
ffffffffc02031ac:	13300593          	li	a1,307
ffffffffc02031b0:	00009517          	auipc	a0,0x9
ffffffffc02031b4:	7d050513          	addi	a0,a0,2000 # ffffffffc020c980 <commands+0x10a8>
ffffffffc02031b8:	876fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02031bc:	649c                	ld	a5,8(s1)
ffffffffc02031be:	471d                	li	a4,7
ffffffffc02031c0:	1fb00593          	li	a1,507
ffffffffc02031c4:	16f48663          	beq	s1,a5,ffffffffc0203330 <vmm_init+0x24a>
ffffffffc02031c8:	fe87b603          	ld	a2,-24(a5) # ffffffffffffefe8 <end+0x3fd686d8>
ffffffffc02031cc:	ffe70693          	addi	a3,a4,-2
ffffffffc02031d0:	10d61063          	bne	a2,a3,ffffffffc02032d0 <vmm_init+0x1ea>
ffffffffc02031d4:	ff07b683          	ld	a3,-16(a5)
ffffffffc02031d8:	0ed71c63          	bne	a4,a3,ffffffffc02032d0 <vmm_init+0x1ea>
ffffffffc02031dc:	0715                	addi	a4,a4,5
ffffffffc02031de:	679c                	ld	a5,8(a5)
ffffffffc02031e0:	feb712e3          	bne	a4,a1,ffffffffc02031c4 <vmm_init+0xde>
ffffffffc02031e4:	4a1d                	li	s4,7
ffffffffc02031e6:	4415                	li	s0,5
ffffffffc02031e8:	1f900a93          	li	s5,505
ffffffffc02031ec:	85a2                	mv	a1,s0
ffffffffc02031ee:	8526                	mv	a0,s1
ffffffffc02031f0:	bd5ff0ef          	jal	ra,ffffffffc0202dc4 <find_vma>
ffffffffc02031f4:	892a                	mv	s2,a0
ffffffffc02031f6:	16050d63          	beqz	a0,ffffffffc0203370 <vmm_init+0x28a>
ffffffffc02031fa:	00140593          	addi	a1,s0,1
ffffffffc02031fe:	8526                	mv	a0,s1
ffffffffc0203200:	bc5ff0ef          	jal	ra,ffffffffc0202dc4 <find_vma>
ffffffffc0203204:	89aa                	mv	s3,a0
ffffffffc0203206:	14050563          	beqz	a0,ffffffffc0203350 <vmm_init+0x26a>
ffffffffc020320a:	85d2                	mv	a1,s4
ffffffffc020320c:	8526                	mv	a0,s1
ffffffffc020320e:	bb7ff0ef          	jal	ra,ffffffffc0202dc4 <find_vma>
ffffffffc0203212:	16051f63          	bnez	a0,ffffffffc0203390 <vmm_init+0x2aa>
ffffffffc0203216:	00340593          	addi	a1,s0,3
ffffffffc020321a:	8526                	mv	a0,s1
ffffffffc020321c:	ba9ff0ef          	jal	ra,ffffffffc0202dc4 <find_vma>
ffffffffc0203220:	1a051863          	bnez	a0,ffffffffc02033d0 <vmm_init+0x2ea>
ffffffffc0203224:	00440593          	addi	a1,s0,4
ffffffffc0203228:	8526                	mv	a0,s1
ffffffffc020322a:	b9bff0ef          	jal	ra,ffffffffc0202dc4 <find_vma>
ffffffffc020322e:	18051163          	bnez	a0,ffffffffc02033b0 <vmm_init+0x2ca>
ffffffffc0203232:	00893783          	ld	a5,8(s2)
ffffffffc0203236:	0a879d63          	bne	a5,s0,ffffffffc02032f0 <vmm_init+0x20a>
ffffffffc020323a:	01093783          	ld	a5,16(s2)
ffffffffc020323e:	0b479963          	bne	a5,s4,ffffffffc02032f0 <vmm_init+0x20a>
ffffffffc0203242:	0089b783          	ld	a5,8(s3)
ffffffffc0203246:	0c879563          	bne	a5,s0,ffffffffc0203310 <vmm_init+0x22a>
ffffffffc020324a:	0109b783          	ld	a5,16(s3)
ffffffffc020324e:	0d479163          	bne	a5,s4,ffffffffc0203310 <vmm_init+0x22a>
ffffffffc0203252:	0415                	addi	s0,s0,5
ffffffffc0203254:	0a15                	addi	s4,s4,5
ffffffffc0203256:	f9541be3          	bne	s0,s5,ffffffffc02031ec <vmm_init+0x106>
ffffffffc020325a:	4411                	li	s0,4
ffffffffc020325c:	597d                	li	s2,-1
ffffffffc020325e:	85a2                	mv	a1,s0
ffffffffc0203260:	8526                	mv	a0,s1
ffffffffc0203262:	b63ff0ef          	jal	ra,ffffffffc0202dc4 <find_vma>
ffffffffc0203266:	0004059b          	sext.w	a1,s0
ffffffffc020326a:	c90d                	beqz	a0,ffffffffc020329c <vmm_init+0x1b6>
ffffffffc020326c:	6914                	ld	a3,16(a0)
ffffffffc020326e:	6510                	ld	a2,8(a0)
ffffffffc0203270:	0000a517          	auipc	a0,0xa
ffffffffc0203274:	8e850513          	addi	a0,a0,-1816 # ffffffffc020cb58 <commands+0x1280>
ffffffffc0203278:	eb3fc0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020327c:	0000a697          	auipc	a3,0xa
ffffffffc0203280:	90468693          	addi	a3,a3,-1788 # ffffffffc020cb80 <commands+0x12a8>
ffffffffc0203284:	00009617          	auipc	a2,0x9
ffffffffc0203288:	8a460613          	addi	a2,a2,-1884 # ffffffffc020bb28 <commands+0x250>
ffffffffc020328c:	15900593          	li	a1,345
ffffffffc0203290:	00009517          	auipc	a0,0x9
ffffffffc0203294:	6f050513          	addi	a0,a0,1776 # ffffffffc020c980 <commands+0x10a8>
ffffffffc0203298:	f97fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020329c:	147d                	addi	s0,s0,-1
ffffffffc020329e:	fd2410e3          	bne	s0,s2,ffffffffc020325e <vmm_init+0x178>
ffffffffc02032a2:	8526                	mv	a0,s1
ffffffffc02032a4:	c31ff0ef          	jal	ra,ffffffffc0202ed4 <mm_destroy>
ffffffffc02032a8:	0000a517          	auipc	a0,0xa
ffffffffc02032ac:	8f050513          	addi	a0,a0,-1808 # ffffffffc020cb98 <commands+0x12c0>
ffffffffc02032b0:	e7bfc0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02032b4:	7442                	ld	s0,48(sp)
ffffffffc02032b6:	70e2                	ld	ra,56(sp)
ffffffffc02032b8:	74a2                	ld	s1,40(sp)
ffffffffc02032ba:	7902                	ld	s2,32(sp)
ffffffffc02032bc:	69e2                	ld	s3,24(sp)
ffffffffc02032be:	6a42                	ld	s4,16(sp)
ffffffffc02032c0:	6aa2                	ld	s5,8(sp)
ffffffffc02032c2:	0000a517          	auipc	a0,0xa
ffffffffc02032c6:	8f650513          	addi	a0,a0,-1802 # ffffffffc020cbb8 <commands+0x12e0>
ffffffffc02032ca:	6121                	addi	sp,sp,64
ffffffffc02032cc:	e5ffc06f          	j	ffffffffc020012a <cprintf>
ffffffffc02032d0:	00009697          	auipc	a3,0x9
ffffffffc02032d4:	7a068693          	addi	a3,a3,1952 # ffffffffc020ca70 <commands+0x1198>
ffffffffc02032d8:	00009617          	auipc	a2,0x9
ffffffffc02032dc:	85060613          	addi	a2,a2,-1968 # ffffffffc020bb28 <commands+0x250>
ffffffffc02032e0:	13d00593          	li	a1,317
ffffffffc02032e4:	00009517          	auipc	a0,0x9
ffffffffc02032e8:	69c50513          	addi	a0,a0,1692 # ffffffffc020c980 <commands+0x10a8>
ffffffffc02032ec:	f43fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02032f0:	0000a697          	auipc	a3,0xa
ffffffffc02032f4:	80868693          	addi	a3,a3,-2040 # ffffffffc020caf8 <commands+0x1220>
ffffffffc02032f8:	00009617          	auipc	a2,0x9
ffffffffc02032fc:	83060613          	addi	a2,a2,-2000 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203300:	14e00593          	li	a1,334
ffffffffc0203304:	00009517          	auipc	a0,0x9
ffffffffc0203308:	67c50513          	addi	a0,a0,1660 # ffffffffc020c980 <commands+0x10a8>
ffffffffc020330c:	f23fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203310:	0000a697          	auipc	a3,0xa
ffffffffc0203314:	81868693          	addi	a3,a3,-2024 # ffffffffc020cb28 <commands+0x1250>
ffffffffc0203318:	00009617          	auipc	a2,0x9
ffffffffc020331c:	81060613          	addi	a2,a2,-2032 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203320:	14f00593          	li	a1,335
ffffffffc0203324:	00009517          	auipc	a0,0x9
ffffffffc0203328:	65c50513          	addi	a0,a0,1628 # ffffffffc020c980 <commands+0x10a8>
ffffffffc020332c:	f03fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203330:	00009697          	auipc	a3,0x9
ffffffffc0203334:	72868693          	addi	a3,a3,1832 # ffffffffc020ca58 <commands+0x1180>
ffffffffc0203338:	00008617          	auipc	a2,0x8
ffffffffc020333c:	7f060613          	addi	a2,a2,2032 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203340:	13b00593          	li	a1,315
ffffffffc0203344:	00009517          	auipc	a0,0x9
ffffffffc0203348:	63c50513          	addi	a0,a0,1596 # ffffffffc020c980 <commands+0x10a8>
ffffffffc020334c:	ee3fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203350:	00009697          	auipc	a3,0x9
ffffffffc0203354:	76868693          	addi	a3,a3,1896 # ffffffffc020cab8 <commands+0x11e0>
ffffffffc0203358:	00008617          	auipc	a2,0x8
ffffffffc020335c:	7d060613          	addi	a2,a2,2000 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203360:	14600593          	li	a1,326
ffffffffc0203364:	00009517          	auipc	a0,0x9
ffffffffc0203368:	61c50513          	addi	a0,a0,1564 # ffffffffc020c980 <commands+0x10a8>
ffffffffc020336c:	ec3fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203370:	00009697          	auipc	a3,0x9
ffffffffc0203374:	73868693          	addi	a3,a3,1848 # ffffffffc020caa8 <commands+0x11d0>
ffffffffc0203378:	00008617          	auipc	a2,0x8
ffffffffc020337c:	7b060613          	addi	a2,a2,1968 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203380:	14400593          	li	a1,324
ffffffffc0203384:	00009517          	auipc	a0,0x9
ffffffffc0203388:	5fc50513          	addi	a0,a0,1532 # ffffffffc020c980 <commands+0x10a8>
ffffffffc020338c:	ea3fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203390:	00009697          	auipc	a3,0x9
ffffffffc0203394:	73868693          	addi	a3,a3,1848 # ffffffffc020cac8 <commands+0x11f0>
ffffffffc0203398:	00008617          	auipc	a2,0x8
ffffffffc020339c:	79060613          	addi	a2,a2,1936 # ffffffffc020bb28 <commands+0x250>
ffffffffc02033a0:	14800593          	li	a1,328
ffffffffc02033a4:	00009517          	auipc	a0,0x9
ffffffffc02033a8:	5dc50513          	addi	a0,a0,1500 # ffffffffc020c980 <commands+0x10a8>
ffffffffc02033ac:	e83fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02033b0:	00009697          	auipc	a3,0x9
ffffffffc02033b4:	73868693          	addi	a3,a3,1848 # ffffffffc020cae8 <commands+0x1210>
ffffffffc02033b8:	00008617          	auipc	a2,0x8
ffffffffc02033bc:	77060613          	addi	a2,a2,1904 # ffffffffc020bb28 <commands+0x250>
ffffffffc02033c0:	14c00593          	li	a1,332
ffffffffc02033c4:	00009517          	auipc	a0,0x9
ffffffffc02033c8:	5bc50513          	addi	a0,a0,1468 # ffffffffc020c980 <commands+0x10a8>
ffffffffc02033cc:	e63fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02033d0:	00009697          	auipc	a3,0x9
ffffffffc02033d4:	70868693          	addi	a3,a3,1800 # ffffffffc020cad8 <commands+0x1200>
ffffffffc02033d8:	00008617          	auipc	a2,0x8
ffffffffc02033dc:	75060613          	addi	a2,a2,1872 # ffffffffc020bb28 <commands+0x250>
ffffffffc02033e0:	14a00593          	li	a1,330
ffffffffc02033e4:	00009517          	auipc	a0,0x9
ffffffffc02033e8:	59c50513          	addi	a0,a0,1436 # ffffffffc020c980 <commands+0x10a8>
ffffffffc02033ec:	e43fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02033f0:	00009697          	auipc	a3,0x9
ffffffffc02033f4:	61868693          	addi	a3,a3,1560 # ffffffffc020ca08 <commands+0x1130>
ffffffffc02033f8:	00008617          	auipc	a2,0x8
ffffffffc02033fc:	73060613          	addi	a2,a2,1840 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203400:	12400593          	li	a1,292
ffffffffc0203404:	00009517          	auipc	a0,0x9
ffffffffc0203408:	57c50513          	addi	a0,a0,1404 # ffffffffc020c980 <commands+0x10a8>
ffffffffc020340c:	e23fc0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0203410 <user_mem_check>:
ffffffffc0203410:	7179                	addi	sp,sp,-48
ffffffffc0203412:	f022                	sd	s0,32(sp)
ffffffffc0203414:	f406                	sd	ra,40(sp)
ffffffffc0203416:	ec26                	sd	s1,24(sp)
ffffffffc0203418:	e84a                	sd	s2,16(sp)
ffffffffc020341a:	e44e                	sd	s3,8(sp)
ffffffffc020341c:	e052                	sd	s4,0(sp)
ffffffffc020341e:	842e                	mv	s0,a1
ffffffffc0203420:	c135                	beqz	a0,ffffffffc0203484 <user_mem_check+0x74>
ffffffffc0203422:	002007b7          	lui	a5,0x200
ffffffffc0203426:	04f5e663          	bltu	a1,a5,ffffffffc0203472 <user_mem_check+0x62>
ffffffffc020342a:	00c584b3          	add	s1,a1,a2
ffffffffc020342e:	0495f263          	bgeu	a1,s1,ffffffffc0203472 <user_mem_check+0x62>
ffffffffc0203432:	4785                	li	a5,1
ffffffffc0203434:	07fe                	slli	a5,a5,0x1f
ffffffffc0203436:	0297ee63          	bltu	a5,s1,ffffffffc0203472 <user_mem_check+0x62>
ffffffffc020343a:	892a                	mv	s2,a0
ffffffffc020343c:	89b6                	mv	s3,a3
ffffffffc020343e:	6a05                	lui	s4,0x1
ffffffffc0203440:	a821                	j	ffffffffc0203458 <user_mem_check+0x48>
ffffffffc0203442:	0027f693          	andi	a3,a5,2
ffffffffc0203446:	9752                	add	a4,a4,s4
ffffffffc0203448:	8ba1                	andi	a5,a5,8
ffffffffc020344a:	c685                	beqz	a3,ffffffffc0203472 <user_mem_check+0x62>
ffffffffc020344c:	c399                	beqz	a5,ffffffffc0203452 <user_mem_check+0x42>
ffffffffc020344e:	02e46263          	bltu	s0,a4,ffffffffc0203472 <user_mem_check+0x62>
ffffffffc0203452:	6900                	ld	s0,16(a0)
ffffffffc0203454:	04947663          	bgeu	s0,s1,ffffffffc02034a0 <user_mem_check+0x90>
ffffffffc0203458:	85a2                	mv	a1,s0
ffffffffc020345a:	854a                	mv	a0,s2
ffffffffc020345c:	969ff0ef          	jal	ra,ffffffffc0202dc4 <find_vma>
ffffffffc0203460:	c909                	beqz	a0,ffffffffc0203472 <user_mem_check+0x62>
ffffffffc0203462:	6518                	ld	a4,8(a0)
ffffffffc0203464:	00e46763          	bltu	s0,a4,ffffffffc0203472 <user_mem_check+0x62>
ffffffffc0203468:	4d1c                	lw	a5,24(a0)
ffffffffc020346a:	fc099ce3          	bnez	s3,ffffffffc0203442 <user_mem_check+0x32>
ffffffffc020346e:	8b85                	andi	a5,a5,1
ffffffffc0203470:	f3ed                	bnez	a5,ffffffffc0203452 <user_mem_check+0x42>
ffffffffc0203472:	4501                	li	a0,0
ffffffffc0203474:	70a2                	ld	ra,40(sp)
ffffffffc0203476:	7402                	ld	s0,32(sp)
ffffffffc0203478:	64e2                	ld	s1,24(sp)
ffffffffc020347a:	6942                	ld	s2,16(sp)
ffffffffc020347c:	69a2                	ld	s3,8(sp)
ffffffffc020347e:	6a02                	ld	s4,0(sp)
ffffffffc0203480:	6145                	addi	sp,sp,48
ffffffffc0203482:	8082                	ret
ffffffffc0203484:	c02007b7          	lui	a5,0xc0200
ffffffffc0203488:	4501                	li	a0,0
ffffffffc020348a:	fef5e5e3          	bltu	a1,a5,ffffffffc0203474 <user_mem_check+0x64>
ffffffffc020348e:	962e                	add	a2,a2,a1
ffffffffc0203490:	fec5f2e3          	bgeu	a1,a2,ffffffffc0203474 <user_mem_check+0x64>
ffffffffc0203494:	c8000537          	lui	a0,0xc8000
ffffffffc0203498:	0505                	addi	a0,a0,1
ffffffffc020349a:	00a63533          	sltu	a0,a2,a0
ffffffffc020349e:	bfd9                	j	ffffffffc0203474 <user_mem_check+0x64>
ffffffffc02034a0:	4505                	li	a0,1
ffffffffc02034a2:	bfc9                	j	ffffffffc0203474 <user_mem_check+0x64>

ffffffffc02034a4 <copy_from_user>:
ffffffffc02034a4:	1101                	addi	sp,sp,-32
ffffffffc02034a6:	e822                	sd	s0,16(sp)
ffffffffc02034a8:	e426                	sd	s1,8(sp)
ffffffffc02034aa:	8432                	mv	s0,a2
ffffffffc02034ac:	84b6                	mv	s1,a3
ffffffffc02034ae:	e04a                	sd	s2,0(sp)
ffffffffc02034b0:	86ba                	mv	a3,a4
ffffffffc02034b2:	892e                	mv	s2,a1
ffffffffc02034b4:	8626                	mv	a2,s1
ffffffffc02034b6:	85a2                	mv	a1,s0
ffffffffc02034b8:	ec06                	sd	ra,24(sp)
ffffffffc02034ba:	f57ff0ef          	jal	ra,ffffffffc0203410 <user_mem_check>
ffffffffc02034be:	c519                	beqz	a0,ffffffffc02034cc <copy_from_user+0x28>
ffffffffc02034c0:	8626                	mv	a2,s1
ffffffffc02034c2:	85a2                	mv	a1,s0
ffffffffc02034c4:	854a                	mv	a0,s2
ffffffffc02034c6:	4bf070ef          	jal	ra,ffffffffc020b184 <memcpy>
ffffffffc02034ca:	4505                	li	a0,1
ffffffffc02034cc:	60e2                	ld	ra,24(sp)
ffffffffc02034ce:	6442                	ld	s0,16(sp)
ffffffffc02034d0:	64a2                	ld	s1,8(sp)
ffffffffc02034d2:	6902                	ld	s2,0(sp)
ffffffffc02034d4:	6105                	addi	sp,sp,32
ffffffffc02034d6:	8082                	ret

ffffffffc02034d8 <copy_to_user>:
ffffffffc02034d8:	1101                	addi	sp,sp,-32
ffffffffc02034da:	e822                	sd	s0,16(sp)
ffffffffc02034dc:	8436                	mv	s0,a3
ffffffffc02034de:	e04a                	sd	s2,0(sp)
ffffffffc02034e0:	4685                	li	a3,1
ffffffffc02034e2:	8932                	mv	s2,a2
ffffffffc02034e4:	8622                	mv	a2,s0
ffffffffc02034e6:	e426                	sd	s1,8(sp)
ffffffffc02034e8:	ec06                	sd	ra,24(sp)
ffffffffc02034ea:	84ae                	mv	s1,a1
ffffffffc02034ec:	f25ff0ef          	jal	ra,ffffffffc0203410 <user_mem_check>
ffffffffc02034f0:	c519                	beqz	a0,ffffffffc02034fe <copy_to_user+0x26>
ffffffffc02034f2:	8622                	mv	a2,s0
ffffffffc02034f4:	85ca                	mv	a1,s2
ffffffffc02034f6:	8526                	mv	a0,s1
ffffffffc02034f8:	48d070ef          	jal	ra,ffffffffc020b184 <memcpy>
ffffffffc02034fc:	4505                	li	a0,1
ffffffffc02034fe:	60e2                	ld	ra,24(sp)
ffffffffc0203500:	6442                	ld	s0,16(sp)
ffffffffc0203502:	64a2                	ld	s1,8(sp)
ffffffffc0203504:	6902                	ld	s2,0(sp)
ffffffffc0203506:	6105                	addi	sp,sp,32
ffffffffc0203508:	8082                	ret

ffffffffc020350a <copy_string>:
ffffffffc020350a:	7139                	addi	sp,sp,-64
ffffffffc020350c:	ec4e                	sd	s3,24(sp)
ffffffffc020350e:	6985                	lui	s3,0x1
ffffffffc0203510:	99b2                	add	s3,s3,a2
ffffffffc0203512:	77fd                	lui	a5,0xfffff
ffffffffc0203514:	00f9f9b3          	and	s3,s3,a5
ffffffffc0203518:	f426                	sd	s1,40(sp)
ffffffffc020351a:	f04a                	sd	s2,32(sp)
ffffffffc020351c:	e852                	sd	s4,16(sp)
ffffffffc020351e:	e456                	sd	s5,8(sp)
ffffffffc0203520:	fc06                	sd	ra,56(sp)
ffffffffc0203522:	f822                	sd	s0,48(sp)
ffffffffc0203524:	84b2                	mv	s1,a2
ffffffffc0203526:	8aaa                	mv	s5,a0
ffffffffc0203528:	8a2e                	mv	s4,a1
ffffffffc020352a:	8936                	mv	s2,a3
ffffffffc020352c:	40c989b3          	sub	s3,s3,a2
ffffffffc0203530:	a015                	j	ffffffffc0203554 <copy_string+0x4a>
ffffffffc0203532:	379070ef          	jal	ra,ffffffffc020b0aa <strnlen>
ffffffffc0203536:	87aa                	mv	a5,a0
ffffffffc0203538:	85a6                	mv	a1,s1
ffffffffc020353a:	8552                	mv	a0,s4
ffffffffc020353c:	8622                	mv	a2,s0
ffffffffc020353e:	0487e363          	bltu	a5,s0,ffffffffc0203584 <copy_string+0x7a>
ffffffffc0203542:	0329f763          	bgeu	s3,s2,ffffffffc0203570 <copy_string+0x66>
ffffffffc0203546:	43f070ef          	jal	ra,ffffffffc020b184 <memcpy>
ffffffffc020354a:	9a22                	add	s4,s4,s0
ffffffffc020354c:	94a2                	add	s1,s1,s0
ffffffffc020354e:	40890933          	sub	s2,s2,s0
ffffffffc0203552:	6985                	lui	s3,0x1
ffffffffc0203554:	4681                	li	a3,0
ffffffffc0203556:	85a6                	mv	a1,s1
ffffffffc0203558:	8556                	mv	a0,s5
ffffffffc020355a:	844a                	mv	s0,s2
ffffffffc020355c:	0129f363          	bgeu	s3,s2,ffffffffc0203562 <copy_string+0x58>
ffffffffc0203560:	844e                	mv	s0,s3
ffffffffc0203562:	8622                	mv	a2,s0
ffffffffc0203564:	eadff0ef          	jal	ra,ffffffffc0203410 <user_mem_check>
ffffffffc0203568:	87aa                	mv	a5,a0
ffffffffc020356a:	85a2                	mv	a1,s0
ffffffffc020356c:	8526                	mv	a0,s1
ffffffffc020356e:	f3f1                	bnez	a5,ffffffffc0203532 <copy_string+0x28>
ffffffffc0203570:	4501                	li	a0,0
ffffffffc0203572:	70e2                	ld	ra,56(sp)
ffffffffc0203574:	7442                	ld	s0,48(sp)
ffffffffc0203576:	74a2                	ld	s1,40(sp)
ffffffffc0203578:	7902                	ld	s2,32(sp)
ffffffffc020357a:	69e2                	ld	s3,24(sp)
ffffffffc020357c:	6a42                	ld	s4,16(sp)
ffffffffc020357e:	6aa2                	ld	s5,8(sp)
ffffffffc0203580:	6121                	addi	sp,sp,64
ffffffffc0203582:	8082                	ret
ffffffffc0203584:	00178613          	addi	a2,a5,1 # fffffffffffff001 <end+0x3fd686f1>
ffffffffc0203588:	3fd070ef          	jal	ra,ffffffffc020b184 <memcpy>
ffffffffc020358c:	4505                	li	a0,1
ffffffffc020358e:	b7d5                	j	ffffffffc0203572 <copy_string+0x68>

ffffffffc0203590 <slob_free>:
ffffffffc0203590:	c94d                	beqz	a0,ffffffffc0203642 <slob_free+0xb2>
ffffffffc0203592:	1141                	addi	sp,sp,-16
ffffffffc0203594:	e022                	sd	s0,0(sp)
ffffffffc0203596:	e406                	sd	ra,8(sp)
ffffffffc0203598:	842a                	mv	s0,a0
ffffffffc020359a:	e9c1                	bnez	a1,ffffffffc020362a <slob_free+0x9a>
ffffffffc020359c:	100027f3          	csrr	a5,sstatus
ffffffffc02035a0:	8b89                	andi	a5,a5,2
ffffffffc02035a2:	4501                	li	a0,0
ffffffffc02035a4:	ebd9                	bnez	a5,ffffffffc020363a <slob_free+0xaa>
ffffffffc02035a6:	0008e617          	auipc	a2,0x8e
ffffffffc02035aa:	aaa60613          	addi	a2,a2,-1366 # ffffffffc0291050 <slobfree>
ffffffffc02035ae:	621c                	ld	a5,0(a2)
ffffffffc02035b0:	873e                	mv	a4,a5
ffffffffc02035b2:	679c                	ld	a5,8(a5)
ffffffffc02035b4:	02877a63          	bgeu	a4,s0,ffffffffc02035e8 <slob_free+0x58>
ffffffffc02035b8:	00f46463          	bltu	s0,a5,ffffffffc02035c0 <slob_free+0x30>
ffffffffc02035bc:	fef76ae3          	bltu	a4,a5,ffffffffc02035b0 <slob_free+0x20>
ffffffffc02035c0:	400c                	lw	a1,0(s0)
ffffffffc02035c2:	00459693          	slli	a3,a1,0x4
ffffffffc02035c6:	96a2                	add	a3,a3,s0
ffffffffc02035c8:	02d78a63          	beq	a5,a3,ffffffffc02035fc <slob_free+0x6c>
ffffffffc02035cc:	4314                	lw	a3,0(a4)
ffffffffc02035ce:	e41c                	sd	a5,8(s0)
ffffffffc02035d0:	00469793          	slli	a5,a3,0x4
ffffffffc02035d4:	97ba                	add	a5,a5,a4
ffffffffc02035d6:	02f40e63          	beq	s0,a5,ffffffffc0203612 <slob_free+0x82>
ffffffffc02035da:	e700                	sd	s0,8(a4)
ffffffffc02035dc:	e218                	sd	a4,0(a2)
ffffffffc02035de:	e129                	bnez	a0,ffffffffc0203620 <slob_free+0x90>
ffffffffc02035e0:	60a2                	ld	ra,8(sp)
ffffffffc02035e2:	6402                	ld	s0,0(sp)
ffffffffc02035e4:	0141                	addi	sp,sp,16
ffffffffc02035e6:	8082                	ret
ffffffffc02035e8:	fcf764e3          	bltu	a4,a5,ffffffffc02035b0 <slob_free+0x20>
ffffffffc02035ec:	fcf472e3          	bgeu	s0,a5,ffffffffc02035b0 <slob_free+0x20>
ffffffffc02035f0:	400c                	lw	a1,0(s0)
ffffffffc02035f2:	00459693          	slli	a3,a1,0x4
ffffffffc02035f6:	96a2                	add	a3,a3,s0
ffffffffc02035f8:	fcd79ae3          	bne	a5,a3,ffffffffc02035cc <slob_free+0x3c>
ffffffffc02035fc:	4394                	lw	a3,0(a5)
ffffffffc02035fe:	679c                	ld	a5,8(a5)
ffffffffc0203600:	9db5                	addw	a1,a1,a3
ffffffffc0203602:	c00c                	sw	a1,0(s0)
ffffffffc0203604:	4314                	lw	a3,0(a4)
ffffffffc0203606:	e41c                	sd	a5,8(s0)
ffffffffc0203608:	00469793          	slli	a5,a3,0x4
ffffffffc020360c:	97ba                	add	a5,a5,a4
ffffffffc020360e:	fcf416e3          	bne	s0,a5,ffffffffc02035da <slob_free+0x4a>
ffffffffc0203612:	401c                	lw	a5,0(s0)
ffffffffc0203614:	640c                	ld	a1,8(s0)
ffffffffc0203616:	e218                	sd	a4,0(a2)
ffffffffc0203618:	9ebd                	addw	a3,a3,a5
ffffffffc020361a:	c314                	sw	a3,0(a4)
ffffffffc020361c:	e70c                	sd	a1,8(a4)
ffffffffc020361e:	d169                	beqz	a0,ffffffffc02035e0 <slob_free+0x50>
ffffffffc0203620:	6402                	ld	s0,0(sp)
ffffffffc0203622:	60a2                	ld	ra,8(sp)
ffffffffc0203624:	0141                	addi	sp,sp,16
ffffffffc0203626:	f74fd06f          	j	ffffffffc0200d9a <intr_enable>
ffffffffc020362a:	25bd                	addiw	a1,a1,15
ffffffffc020362c:	8191                	srli	a1,a1,0x4
ffffffffc020362e:	c10c                	sw	a1,0(a0)
ffffffffc0203630:	100027f3          	csrr	a5,sstatus
ffffffffc0203634:	8b89                	andi	a5,a5,2
ffffffffc0203636:	4501                	li	a0,0
ffffffffc0203638:	d7bd                	beqz	a5,ffffffffc02035a6 <slob_free+0x16>
ffffffffc020363a:	f66fd0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc020363e:	4505                	li	a0,1
ffffffffc0203640:	b79d                	j	ffffffffc02035a6 <slob_free+0x16>
ffffffffc0203642:	8082                	ret

ffffffffc0203644 <__slob_get_free_pages.constprop.0>:
ffffffffc0203644:	4785                	li	a5,1
ffffffffc0203646:	1141                	addi	sp,sp,-16
ffffffffc0203648:	00a7953b          	sllw	a0,a5,a0
ffffffffc020364c:	e406                	sd	ra,8(sp)
ffffffffc020364e:	c9dfd0ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0203652:	c91d                	beqz	a0,ffffffffc0203688 <__slob_get_free_pages.constprop.0+0x44>
ffffffffc0203654:	00093697          	auipc	a3,0x93
ffffffffc0203658:	24c6b683          	ld	a3,588(a3) # ffffffffc02968a0 <pages>
ffffffffc020365c:	8d15                	sub	a0,a0,a3
ffffffffc020365e:	8519                	srai	a0,a0,0x6
ffffffffc0203660:	0000c697          	auipc	a3,0xc
ffffffffc0203664:	2906b683          	ld	a3,656(a3) # ffffffffc020f8f0 <nbase>
ffffffffc0203668:	9536                	add	a0,a0,a3
ffffffffc020366a:	00c51793          	slli	a5,a0,0xc
ffffffffc020366e:	83b1                	srli	a5,a5,0xc
ffffffffc0203670:	00093717          	auipc	a4,0x93
ffffffffc0203674:	22873703          	ld	a4,552(a4) # ffffffffc0296898 <npage>
ffffffffc0203678:	0532                	slli	a0,a0,0xc
ffffffffc020367a:	00e7fa63          	bgeu	a5,a4,ffffffffc020368e <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc020367e:	00093697          	auipc	a3,0x93
ffffffffc0203682:	2326b683          	ld	a3,562(a3) # ffffffffc02968b0 <va_pa_offset>
ffffffffc0203686:	9536                	add	a0,a0,a3
ffffffffc0203688:	60a2                	ld	ra,8(sp)
ffffffffc020368a:	0141                	addi	sp,sp,16
ffffffffc020368c:	8082                	ret
ffffffffc020368e:	86aa                	mv	a3,a0
ffffffffc0203690:	00009617          	auipc	a2,0x9
ffffffffc0203694:	bb060613          	addi	a2,a2,-1104 # ffffffffc020c240 <commands+0x968>
ffffffffc0203698:	07100593          	li	a1,113
ffffffffc020369c:	00009517          	auipc	a0,0x9
ffffffffc02036a0:	b6c50513          	addi	a0,a0,-1172 # ffffffffc020c208 <commands+0x930>
ffffffffc02036a4:	b8bfc0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02036a8 <slob_alloc.constprop.0>:
ffffffffc02036a8:	1101                	addi	sp,sp,-32
ffffffffc02036aa:	ec06                	sd	ra,24(sp)
ffffffffc02036ac:	e822                	sd	s0,16(sp)
ffffffffc02036ae:	e426                	sd	s1,8(sp)
ffffffffc02036b0:	e04a                	sd	s2,0(sp)
ffffffffc02036b2:	01050713          	addi	a4,a0,16
ffffffffc02036b6:	6785                	lui	a5,0x1
ffffffffc02036b8:	0cf77363          	bgeu	a4,a5,ffffffffc020377e <slob_alloc.constprop.0+0xd6>
ffffffffc02036bc:	00f50493          	addi	s1,a0,15
ffffffffc02036c0:	8091                	srli	s1,s1,0x4
ffffffffc02036c2:	2481                	sext.w	s1,s1
ffffffffc02036c4:	10002673          	csrr	a2,sstatus
ffffffffc02036c8:	8a09                	andi	a2,a2,2
ffffffffc02036ca:	e25d                	bnez	a2,ffffffffc0203770 <slob_alloc.constprop.0+0xc8>
ffffffffc02036cc:	0008e917          	auipc	s2,0x8e
ffffffffc02036d0:	98490913          	addi	s2,s2,-1660 # ffffffffc0291050 <slobfree>
ffffffffc02036d4:	00093683          	ld	a3,0(s2)
ffffffffc02036d8:	669c                	ld	a5,8(a3)
ffffffffc02036da:	4398                	lw	a4,0(a5)
ffffffffc02036dc:	08975e63          	bge	a4,s1,ffffffffc0203778 <slob_alloc.constprop.0+0xd0>
ffffffffc02036e0:	00f68b63          	beq	a3,a5,ffffffffc02036f6 <slob_alloc.constprop.0+0x4e>
ffffffffc02036e4:	6780                	ld	s0,8(a5)
ffffffffc02036e6:	4018                	lw	a4,0(s0)
ffffffffc02036e8:	02975a63          	bge	a4,s1,ffffffffc020371c <slob_alloc.constprop.0+0x74>
ffffffffc02036ec:	00093683          	ld	a3,0(s2)
ffffffffc02036f0:	87a2                	mv	a5,s0
ffffffffc02036f2:	fef699e3          	bne	a3,a5,ffffffffc02036e4 <slob_alloc.constprop.0+0x3c>
ffffffffc02036f6:	ee31                	bnez	a2,ffffffffc0203752 <slob_alloc.constprop.0+0xaa>
ffffffffc02036f8:	4501                	li	a0,0
ffffffffc02036fa:	f4bff0ef          	jal	ra,ffffffffc0203644 <__slob_get_free_pages.constprop.0>
ffffffffc02036fe:	842a                	mv	s0,a0
ffffffffc0203700:	cd05                	beqz	a0,ffffffffc0203738 <slob_alloc.constprop.0+0x90>
ffffffffc0203702:	6585                	lui	a1,0x1
ffffffffc0203704:	e8dff0ef          	jal	ra,ffffffffc0203590 <slob_free>
ffffffffc0203708:	10002673          	csrr	a2,sstatus
ffffffffc020370c:	8a09                	andi	a2,a2,2
ffffffffc020370e:	ee05                	bnez	a2,ffffffffc0203746 <slob_alloc.constprop.0+0x9e>
ffffffffc0203710:	00093783          	ld	a5,0(s2)
ffffffffc0203714:	6780                	ld	s0,8(a5)
ffffffffc0203716:	4018                	lw	a4,0(s0)
ffffffffc0203718:	fc974ae3          	blt	a4,s1,ffffffffc02036ec <slob_alloc.constprop.0+0x44>
ffffffffc020371c:	04e48763          	beq	s1,a4,ffffffffc020376a <slob_alloc.constprop.0+0xc2>
ffffffffc0203720:	00449693          	slli	a3,s1,0x4
ffffffffc0203724:	96a2                	add	a3,a3,s0
ffffffffc0203726:	e794                	sd	a3,8(a5)
ffffffffc0203728:	640c                	ld	a1,8(s0)
ffffffffc020372a:	9f05                	subw	a4,a4,s1
ffffffffc020372c:	c298                	sw	a4,0(a3)
ffffffffc020372e:	e68c                	sd	a1,8(a3)
ffffffffc0203730:	c004                	sw	s1,0(s0)
ffffffffc0203732:	00f93023          	sd	a5,0(s2)
ffffffffc0203736:	e20d                	bnez	a2,ffffffffc0203758 <slob_alloc.constprop.0+0xb0>
ffffffffc0203738:	60e2                	ld	ra,24(sp)
ffffffffc020373a:	8522                	mv	a0,s0
ffffffffc020373c:	6442                	ld	s0,16(sp)
ffffffffc020373e:	64a2                	ld	s1,8(sp)
ffffffffc0203740:	6902                	ld	s2,0(sp)
ffffffffc0203742:	6105                	addi	sp,sp,32
ffffffffc0203744:	8082                	ret
ffffffffc0203746:	e5afd0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc020374a:	00093783          	ld	a5,0(s2)
ffffffffc020374e:	4605                	li	a2,1
ffffffffc0203750:	b7d1                	j	ffffffffc0203714 <slob_alloc.constprop.0+0x6c>
ffffffffc0203752:	e48fd0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0203756:	b74d                	j	ffffffffc02036f8 <slob_alloc.constprop.0+0x50>
ffffffffc0203758:	e42fd0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc020375c:	60e2                	ld	ra,24(sp)
ffffffffc020375e:	8522                	mv	a0,s0
ffffffffc0203760:	6442                	ld	s0,16(sp)
ffffffffc0203762:	64a2                	ld	s1,8(sp)
ffffffffc0203764:	6902                	ld	s2,0(sp)
ffffffffc0203766:	6105                	addi	sp,sp,32
ffffffffc0203768:	8082                	ret
ffffffffc020376a:	6418                	ld	a4,8(s0)
ffffffffc020376c:	e798                	sd	a4,8(a5)
ffffffffc020376e:	b7d1                	j	ffffffffc0203732 <slob_alloc.constprop.0+0x8a>
ffffffffc0203770:	e30fd0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0203774:	4605                	li	a2,1
ffffffffc0203776:	bf99                	j	ffffffffc02036cc <slob_alloc.constprop.0+0x24>
ffffffffc0203778:	843e                	mv	s0,a5
ffffffffc020377a:	87b6                	mv	a5,a3
ffffffffc020377c:	b745                	j	ffffffffc020371c <slob_alloc.constprop.0+0x74>
ffffffffc020377e:	00009697          	auipc	a3,0x9
ffffffffc0203782:	46268693          	addi	a3,a3,1122 # ffffffffc020cbe0 <commands+0x1308>
ffffffffc0203786:	00008617          	auipc	a2,0x8
ffffffffc020378a:	3a260613          	addi	a2,a2,930 # ffffffffc020bb28 <commands+0x250>
ffffffffc020378e:	06300593          	li	a1,99
ffffffffc0203792:	00009517          	auipc	a0,0x9
ffffffffc0203796:	46e50513          	addi	a0,a0,1134 # ffffffffc020cc00 <commands+0x1328>
ffffffffc020379a:	a95fc0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020379e <kmalloc_init>:
ffffffffc020379e:	1141                	addi	sp,sp,-16
ffffffffc02037a0:	00009517          	auipc	a0,0x9
ffffffffc02037a4:	47850513          	addi	a0,a0,1144 # ffffffffc020cc18 <commands+0x1340>
ffffffffc02037a8:	e406                	sd	ra,8(sp)
ffffffffc02037aa:	981fc0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02037ae:	60a2                	ld	ra,8(sp)
ffffffffc02037b0:	00009517          	auipc	a0,0x9
ffffffffc02037b4:	48050513          	addi	a0,a0,1152 # ffffffffc020cc30 <commands+0x1358>
ffffffffc02037b8:	0141                	addi	sp,sp,16
ffffffffc02037ba:	971fc06f          	j	ffffffffc020012a <cprintf>

ffffffffc02037be <kallocated>:
ffffffffc02037be:	4501                	li	a0,0
ffffffffc02037c0:	8082                	ret

ffffffffc02037c2 <kmalloc>:
ffffffffc02037c2:	1101                	addi	sp,sp,-32
ffffffffc02037c4:	e04a                	sd	s2,0(sp)
ffffffffc02037c6:	6905                	lui	s2,0x1
ffffffffc02037c8:	e822                	sd	s0,16(sp)
ffffffffc02037ca:	ec06                	sd	ra,24(sp)
ffffffffc02037cc:	e426                	sd	s1,8(sp)
ffffffffc02037ce:	fef90793          	addi	a5,s2,-17 # fef <_binary_bin_swap_img_size-0x6d11>
ffffffffc02037d2:	842a                	mv	s0,a0
ffffffffc02037d4:	04a7f963          	bgeu	a5,a0,ffffffffc0203826 <kmalloc+0x64>
ffffffffc02037d8:	4561                	li	a0,24
ffffffffc02037da:	ecfff0ef          	jal	ra,ffffffffc02036a8 <slob_alloc.constprop.0>
ffffffffc02037de:	84aa                	mv	s1,a0
ffffffffc02037e0:	c929                	beqz	a0,ffffffffc0203832 <kmalloc+0x70>
ffffffffc02037e2:	0004079b          	sext.w	a5,s0
ffffffffc02037e6:	4501                	li	a0,0
ffffffffc02037e8:	00f95763          	bge	s2,a5,ffffffffc02037f6 <kmalloc+0x34>
ffffffffc02037ec:	6705                	lui	a4,0x1
ffffffffc02037ee:	8785                	srai	a5,a5,0x1
ffffffffc02037f0:	2505                	addiw	a0,a0,1
ffffffffc02037f2:	fef74ee3          	blt	a4,a5,ffffffffc02037ee <kmalloc+0x2c>
ffffffffc02037f6:	c088                	sw	a0,0(s1)
ffffffffc02037f8:	e4dff0ef          	jal	ra,ffffffffc0203644 <__slob_get_free_pages.constprop.0>
ffffffffc02037fc:	e488                	sd	a0,8(s1)
ffffffffc02037fe:	842a                	mv	s0,a0
ffffffffc0203800:	c525                	beqz	a0,ffffffffc0203868 <kmalloc+0xa6>
ffffffffc0203802:	100027f3          	csrr	a5,sstatus
ffffffffc0203806:	8b89                	andi	a5,a5,2
ffffffffc0203808:	ef8d                	bnez	a5,ffffffffc0203842 <kmalloc+0x80>
ffffffffc020380a:	00093797          	auipc	a5,0x93
ffffffffc020380e:	0ae78793          	addi	a5,a5,174 # ffffffffc02968b8 <bigblocks>
ffffffffc0203812:	6398                	ld	a4,0(a5)
ffffffffc0203814:	e384                	sd	s1,0(a5)
ffffffffc0203816:	e898                	sd	a4,16(s1)
ffffffffc0203818:	60e2                	ld	ra,24(sp)
ffffffffc020381a:	8522                	mv	a0,s0
ffffffffc020381c:	6442                	ld	s0,16(sp)
ffffffffc020381e:	64a2                	ld	s1,8(sp)
ffffffffc0203820:	6902                	ld	s2,0(sp)
ffffffffc0203822:	6105                	addi	sp,sp,32
ffffffffc0203824:	8082                	ret
ffffffffc0203826:	0541                	addi	a0,a0,16
ffffffffc0203828:	e81ff0ef          	jal	ra,ffffffffc02036a8 <slob_alloc.constprop.0>
ffffffffc020382c:	01050413          	addi	s0,a0,16
ffffffffc0203830:	f565                	bnez	a0,ffffffffc0203818 <kmalloc+0x56>
ffffffffc0203832:	4401                	li	s0,0
ffffffffc0203834:	60e2                	ld	ra,24(sp)
ffffffffc0203836:	8522                	mv	a0,s0
ffffffffc0203838:	6442                	ld	s0,16(sp)
ffffffffc020383a:	64a2                	ld	s1,8(sp)
ffffffffc020383c:	6902                	ld	s2,0(sp)
ffffffffc020383e:	6105                	addi	sp,sp,32
ffffffffc0203840:	8082                	ret
ffffffffc0203842:	d5efd0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0203846:	00093797          	auipc	a5,0x93
ffffffffc020384a:	07278793          	addi	a5,a5,114 # ffffffffc02968b8 <bigblocks>
ffffffffc020384e:	6398                	ld	a4,0(a5)
ffffffffc0203850:	e384                	sd	s1,0(a5)
ffffffffc0203852:	e898                	sd	a4,16(s1)
ffffffffc0203854:	d46fd0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0203858:	6480                	ld	s0,8(s1)
ffffffffc020385a:	60e2                	ld	ra,24(sp)
ffffffffc020385c:	64a2                	ld	s1,8(sp)
ffffffffc020385e:	8522                	mv	a0,s0
ffffffffc0203860:	6442                	ld	s0,16(sp)
ffffffffc0203862:	6902                	ld	s2,0(sp)
ffffffffc0203864:	6105                	addi	sp,sp,32
ffffffffc0203866:	8082                	ret
ffffffffc0203868:	45e1                	li	a1,24
ffffffffc020386a:	8526                	mv	a0,s1
ffffffffc020386c:	d25ff0ef          	jal	ra,ffffffffc0203590 <slob_free>
ffffffffc0203870:	b765                	j	ffffffffc0203818 <kmalloc+0x56>

ffffffffc0203872 <kfree>:
ffffffffc0203872:	c179                	beqz	a0,ffffffffc0203938 <kfree+0xc6>
ffffffffc0203874:	1101                	addi	sp,sp,-32
ffffffffc0203876:	e822                	sd	s0,16(sp)
ffffffffc0203878:	ec06                	sd	ra,24(sp)
ffffffffc020387a:	e426                	sd	s1,8(sp)
ffffffffc020387c:	03451793          	slli	a5,a0,0x34
ffffffffc0203880:	842a                	mv	s0,a0
ffffffffc0203882:	e7c1                	bnez	a5,ffffffffc020390a <kfree+0x98>
ffffffffc0203884:	100027f3          	csrr	a5,sstatus
ffffffffc0203888:	8b89                	andi	a5,a5,2
ffffffffc020388a:	ebc9                	bnez	a5,ffffffffc020391c <kfree+0xaa>
ffffffffc020388c:	00093797          	auipc	a5,0x93
ffffffffc0203890:	02c7b783          	ld	a5,44(a5) # ffffffffc02968b8 <bigblocks>
ffffffffc0203894:	4601                	li	a2,0
ffffffffc0203896:	cbb5                	beqz	a5,ffffffffc020390a <kfree+0x98>
ffffffffc0203898:	00093697          	auipc	a3,0x93
ffffffffc020389c:	02068693          	addi	a3,a3,32 # ffffffffc02968b8 <bigblocks>
ffffffffc02038a0:	a021                	j	ffffffffc02038a8 <kfree+0x36>
ffffffffc02038a2:	01048693          	addi	a3,s1,16
ffffffffc02038a6:	c3ad                	beqz	a5,ffffffffc0203908 <kfree+0x96>
ffffffffc02038a8:	6798                	ld	a4,8(a5)
ffffffffc02038aa:	84be                	mv	s1,a5
ffffffffc02038ac:	6b9c                	ld	a5,16(a5)
ffffffffc02038ae:	fe871ae3          	bne	a4,s0,ffffffffc02038a2 <kfree+0x30>
ffffffffc02038b2:	e29c                	sd	a5,0(a3)
ffffffffc02038b4:	ee3d                	bnez	a2,ffffffffc0203932 <kfree+0xc0>
ffffffffc02038b6:	c02007b7          	lui	a5,0xc0200
ffffffffc02038ba:	4098                	lw	a4,0(s1)
ffffffffc02038bc:	08f46b63          	bltu	s0,a5,ffffffffc0203952 <kfree+0xe0>
ffffffffc02038c0:	00093697          	auipc	a3,0x93
ffffffffc02038c4:	ff06b683          	ld	a3,-16(a3) # ffffffffc02968b0 <va_pa_offset>
ffffffffc02038c8:	8c15                	sub	s0,s0,a3
ffffffffc02038ca:	8031                	srli	s0,s0,0xc
ffffffffc02038cc:	00093797          	auipc	a5,0x93
ffffffffc02038d0:	fcc7b783          	ld	a5,-52(a5) # ffffffffc0296898 <npage>
ffffffffc02038d4:	06f47363          	bgeu	s0,a5,ffffffffc020393a <kfree+0xc8>
ffffffffc02038d8:	0000c517          	auipc	a0,0xc
ffffffffc02038dc:	01853503          	ld	a0,24(a0) # ffffffffc020f8f0 <nbase>
ffffffffc02038e0:	8c09                	sub	s0,s0,a0
ffffffffc02038e2:	041a                	slli	s0,s0,0x6
ffffffffc02038e4:	00093517          	auipc	a0,0x93
ffffffffc02038e8:	fbc53503          	ld	a0,-68(a0) # ffffffffc02968a0 <pages>
ffffffffc02038ec:	4585                	li	a1,1
ffffffffc02038ee:	9522                	add	a0,a0,s0
ffffffffc02038f0:	00e595bb          	sllw	a1,a1,a4
ffffffffc02038f4:	a35fd0ef          	jal	ra,ffffffffc0201328 <free_pages>
ffffffffc02038f8:	6442                	ld	s0,16(sp)
ffffffffc02038fa:	60e2                	ld	ra,24(sp)
ffffffffc02038fc:	8526                	mv	a0,s1
ffffffffc02038fe:	64a2                	ld	s1,8(sp)
ffffffffc0203900:	45e1                	li	a1,24
ffffffffc0203902:	6105                	addi	sp,sp,32
ffffffffc0203904:	c8dff06f          	j	ffffffffc0203590 <slob_free>
ffffffffc0203908:	e215                	bnez	a2,ffffffffc020392c <kfree+0xba>
ffffffffc020390a:	ff040513          	addi	a0,s0,-16
ffffffffc020390e:	6442                	ld	s0,16(sp)
ffffffffc0203910:	60e2                	ld	ra,24(sp)
ffffffffc0203912:	64a2                	ld	s1,8(sp)
ffffffffc0203914:	4581                	li	a1,0
ffffffffc0203916:	6105                	addi	sp,sp,32
ffffffffc0203918:	c79ff06f          	j	ffffffffc0203590 <slob_free>
ffffffffc020391c:	c84fd0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0203920:	00093797          	auipc	a5,0x93
ffffffffc0203924:	f987b783          	ld	a5,-104(a5) # ffffffffc02968b8 <bigblocks>
ffffffffc0203928:	4605                	li	a2,1
ffffffffc020392a:	f7bd                	bnez	a5,ffffffffc0203898 <kfree+0x26>
ffffffffc020392c:	c6efd0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0203930:	bfe9                	j	ffffffffc020390a <kfree+0x98>
ffffffffc0203932:	c68fd0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0203936:	b741                	j	ffffffffc02038b6 <kfree+0x44>
ffffffffc0203938:	8082                	ret
ffffffffc020393a:	00009617          	auipc	a2,0x9
ffffffffc020393e:	8ae60613          	addi	a2,a2,-1874 # ffffffffc020c1e8 <commands+0x910>
ffffffffc0203942:	06900593          	li	a1,105
ffffffffc0203946:	00009517          	auipc	a0,0x9
ffffffffc020394a:	8c250513          	addi	a0,a0,-1854 # ffffffffc020c208 <commands+0x930>
ffffffffc020394e:	8e1fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203952:	86a2                	mv	a3,s0
ffffffffc0203954:	00009617          	auipc	a2,0x9
ffffffffc0203958:	a0c60613          	addi	a2,a2,-1524 # ffffffffc020c360 <commands+0xa88>
ffffffffc020395c:	07700593          	li	a1,119
ffffffffc0203960:	00009517          	auipc	a0,0x9
ffffffffc0203964:	8a850513          	addi	a0,a0,-1880 # ffffffffc020c208 <commands+0x930>
ffffffffc0203968:	8c7fc0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020396c <default_init>:
ffffffffc020396c:	0008e797          	auipc	a5,0x8e
ffffffffc0203970:	e3c78793          	addi	a5,a5,-452 # ffffffffc02917a8 <free_area>
ffffffffc0203974:	e79c                	sd	a5,8(a5)
ffffffffc0203976:	e39c                	sd	a5,0(a5)
ffffffffc0203978:	0007a823          	sw	zero,16(a5)
ffffffffc020397c:	8082                	ret

ffffffffc020397e <default_nr_free_pages>:
ffffffffc020397e:	0008e517          	auipc	a0,0x8e
ffffffffc0203982:	e3a56503          	lwu	a0,-454(a0) # ffffffffc02917b8 <free_area+0x10>
ffffffffc0203986:	8082                	ret

ffffffffc0203988 <default_check>:
ffffffffc0203988:	715d                	addi	sp,sp,-80
ffffffffc020398a:	e0a2                	sd	s0,64(sp)
ffffffffc020398c:	0008e417          	auipc	s0,0x8e
ffffffffc0203990:	e1c40413          	addi	s0,s0,-484 # ffffffffc02917a8 <free_area>
ffffffffc0203994:	641c                	ld	a5,8(s0)
ffffffffc0203996:	e486                	sd	ra,72(sp)
ffffffffc0203998:	fc26                	sd	s1,56(sp)
ffffffffc020399a:	f84a                	sd	s2,48(sp)
ffffffffc020399c:	f44e                	sd	s3,40(sp)
ffffffffc020399e:	f052                	sd	s4,32(sp)
ffffffffc02039a0:	ec56                	sd	s5,24(sp)
ffffffffc02039a2:	e85a                	sd	s6,16(sp)
ffffffffc02039a4:	e45e                	sd	s7,8(sp)
ffffffffc02039a6:	e062                	sd	s8,0(sp)
ffffffffc02039a8:	2a878d63          	beq	a5,s0,ffffffffc0203c62 <default_check+0x2da>
ffffffffc02039ac:	4481                	li	s1,0
ffffffffc02039ae:	4901                	li	s2,0
ffffffffc02039b0:	ff07b703          	ld	a4,-16(a5)
ffffffffc02039b4:	8b09                	andi	a4,a4,2
ffffffffc02039b6:	2a070a63          	beqz	a4,ffffffffc0203c6a <default_check+0x2e2>
ffffffffc02039ba:	ff87a703          	lw	a4,-8(a5)
ffffffffc02039be:	679c                	ld	a5,8(a5)
ffffffffc02039c0:	2905                	addiw	s2,s2,1
ffffffffc02039c2:	9cb9                	addw	s1,s1,a4
ffffffffc02039c4:	fe8796e3          	bne	a5,s0,ffffffffc02039b0 <default_check+0x28>
ffffffffc02039c8:	89a6                	mv	s3,s1
ffffffffc02039ca:	99ffd0ef          	jal	ra,ffffffffc0201368 <nr_free_pages>
ffffffffc02039ce:	6f351e63          	bne	a0,s3,ffffffffc02040ca <default_check+0x742>
ffffffffc02039d2:	4505                	li	a0,1
ffffffffc02039d4:	917fd0ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc02039d8:	8aaa                	mv	s5,a0
ffffffffc02039da:	42050863          	beqz	a0,ffffffffc0203e0a <default_check+0x482>
ffffffffc02039de:	4505                	li	a0,1
ffffffffc02039e0:	90bfd0ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc02039e4:	89aa                	mv	s3,a0
ffffffffc02039e6:	70050263          	beqz	a0,ffffffffc02040ea <default_check+0x762>
ffffffffc02039ea:	4505                	li	a0,1
ffffffffc02039ec:	8fffd0ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc02039f0:	8a2a                	mv	s4,a0
ffffffffc02039f2:	48050c63          	beqz	a0,ffffffffc0203e8a <default_check+0x502>
ffffffffc02039f6:	293a8a63          	beq	s5,s3,ffffffffc0203c8a <default_check+0x302>
ffffffffc02039fa:	28aa8863          	beq	s5,a0,ffffffffc0203c8a <default_check+0x302>
ffffffffc02039fe:	28a98663          	beq	s3,a0,ffffffffc0203c8a <default_check+0x302>
ffffffffc0203a02:	000aa783          	lw	a5,0(s5)
ffffffffc0203a06:	2a079263          	bnez	a5,ffffffffc0203caa <default_check+0x322>
ffffffffc0203a0a:	0009a783          	lw	a5,0(s3) # 1000 <_binary_bin_swap_img_size-0x6d00>
ffffffffc0203a0e:	28079e63          	bnez	a5,ffffffffc0203caa <default_check+0x322>
ffffffffc0203a12:	411c                	lw	a5,0(a0)
ffffffffc0203a14:	28079b63          	bnez	a5,ffffffffc0203caa <default_check+0x322>
ffffffffc0203a18:	00093797          	auipc	a5,0x93
ffffffffc0203a1c:	e887b783          	ld	a5,-376(a5) # ffffffffc02968a0 <pages>
ffffffffc0203a20:	40fa8733          	sub	a4,s5,a5
ffffffffc0203a24:	0000c617          	auipc	a2,0xc
ffffffffc0203a28:	ecc63603          	ld	a2,-308(a2) # ffffffffc020f8f0 <nbase>
ffffffffc0203a2c:	8719                	srai	a4,a4,0x6
ffffffffc0203a2e:	9732                	add	a4,a4,a2
ffffffffc0203a30:	00093697          	auipc	a3,0x93
ffffffffc0203a34:	e686b683          	ld	a3,-408(a3) # ffffffffc0296898 <npage>
ffffffffc0203a38:	06b2                	slli	a3,a3,0xc
ffffffffc0203a3a:	0732                	slli	a4,a4,0xc
ffffffffc0203a3c:	28d77763          	bgeu	a4,a3,ffffffffc0203cca <default_check+0x342>
ffffffffc0203a40:	40f98733          	sub	a4,s3,a5
ffffffffc0203a44:	8719                	srai	a4,a4,0x6
ffffffffc0203a46:	9732                	add	a4,a4,a2
ffffffffc0203a48:	0732                	slli	a4,a4,0xc
ffffffffc0203a4a:	4cd77063          	bgeu	a4,a3,ffffffffc0203f0a <default_check+0x582>
ffffffffc0203a4e:	40f507b3          	sub	a5,a0,a5
ffffffffc0203a52:	8799                	srai	a5,a5,0x6
ffffffffc0203a54:	97b2                	add	a5,a5,a2
ffffffffc0203a56:	07b2                	slli	a5,a5,0xc
ffffffffc0203a58:	30d7f963          	bgeu	a5,a3,ffffffffc0203d6a <default_check+0x3e2>
ffffffffc0203a5c:	4505                	li	a0,1
ffffffffc0203a5e:	00043c03          	ld	s8,0(s0)
ffffffffc0203a62:	00843b83          	ld	s7,8(s0)
ffffffffc0203a66:	01042b03          	lw	s6,16(s0)
ffffffffc0203a6a:	e400                	sd	s0,8(s0)
ffffffffc0203a6c:	e000                	sd	s0,0(s0)
ffffffffc0203a6e:	0008e797          	auipc	a5,0x8e
ffffffffc0203a72:	d407a523          	sw	zero,-694(a5) # ffffffffc02917b8 <free_area+0x10>
ffffffffc0203a76:	875fd0ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0203a7a:	2c051863          	bnez	a0,ffffffffc0203d4a <default_check+0x3c2>
ffffffffc0203a7e:	4585                	li	a1,1
ffffffffc0203a80:	8556                	mv	a0,s5
ffffffffc0203a82:	8a7fd0ef          	jal	ra,ffffffffc0201328 <free_pages>
ffffffffc0203a86:	4585                	li	a1,1
ffffffffc0203a88:	854e                	mv	a0,s3
ffffffffc0203a8a:	89ffd0ef          	jal	ra,ffffffffc0201328 <free_pages>
ffffffffc0203a8e:	4585                	li	a1,1
ffffffffc0203a90:	8552                	mv	a0,s4
ffffffffc0203a92:	897fd0ef          	jal	ra,ffffffffc0201328 <free_pages>
ffffffffc0203a96:	4818                	lw	a4,16(s0)
ffffffffc0203a98:	478d                	li	a5,3
ffffffffc0203a9a:	28f71863          	bne	a4,a5,ffffffffc0203d2a <default_check+0x3a2>
ffffffffc0203a9e:	4505                	li	a0,1
ffffffffc0203aa0:	84bfd0ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0203aa4:	89aa                	mv	s3,a0
ffffffffc0203aa6:	26050263          	beqz	a0,ffffffffc0203d0a <default_check+0x382>
ffffffffc0203aaa:	4505                	li	a0,1
ffffffffc0203aac:	83ffd0ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0203ab0:	8aaa                	mv	s5,a0
ffffffffc0203ab2:	3a050c63          	beqz	a0,ffffffffc0203e6a <default_check+0x4e2>
ffffffffc0203ab6:	4505                	li	a0,1
ffffffffc0203ab8:	833fd0ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0203abc:	8a2a                	mv	s4,a0
ffffffffc0203abe:	38050663          	beqz	a0,ffffffffc0203e4a <default_check+0x4c2>
ffffffffc0203ac2:	4505                	li	a0,1
ffffffffc0203ac4:	827fd0ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0203ac8:	36051163          	bnez	a0,ffffffffc0203e2a <default_check+0x4a2>
ffffffffc0203acc:	4585                	li	a1,1
ffffffffc0203ace:	854e                	mv	a0,s3
ffffffffc0203ad0:	859fd0ef          	jal	ra,ffffffffc0201328 <free_pages>
ffffffffc0203ad4:	641c                	ld	a5,8(s0)
ffffffffc0203ad6:	20878a63          	beq	a5,s0,ffffffffc0203cea <default_check+0x362>
ffffffffc0203ada:	4505                	li	a0,1
ffffffffc0203adc:	80ffd0ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0203ae0:	30a99563          	bne	s3,a0,ffffffffc0203dea <default_check+0x462>
ffffffffc0203ae4:	4505                	li	a0,1
ffffffffc0203ae6:	805fd0ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0203aea:	2e051063          	bnez	a0,ffffffffc0203dca <default_check+0x442>
ffffffffc0203aee:	481c                	lw	a5,16(s0)
ffffffffc0203af0:	2a079d63          	bnez	a5,ffffffffc0203daa <default_check+0x422>
ffffffffc0203af4:	854e                	mv	a0,s3
ffffffffc0203af6:	4585                	li	a1,1
ffffffffc0203af8:	01843023          	sd	s8,0(s0)
ffffffffc0203afc:	01743423          	sd	s7,8(s0)
ffffffffc0203b00:	01642823          	sw	s6,16(s0)
ffffffffc0203b04:	825fd0ef          	jal	ra,ffffffffc0201328 <free_pages>
ffffffffc0203b08:	4585                	li	a1,1
ffffffffc0203b0a:	8556                	mv	a0,s5
ffffffffc0203b0c:	81dfd0ef          	jal	ra,ffffffffc0201328 <free_pages>
ffffffffc0203b10:	4585                	li	a1,1
ffffffffc0203b12:	8552                	mv	a0,s4
ffffffffc0203b14:	815fd0ef          	jal	ra,ffffffffc0201328 <free_pages>
ffffffffc0203b18:	4515                	li	a0,5
ffffffffc0203b1a:	fd0fd0ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0203b1e:	89aa                	mv	s3,a0
ffffffffc0203b20:	26050563          	beqz	a0,ffffffffc0203d8a <default_check+0x402>
ffffffffc0203b24:	651c                	ld	a5,8(a0)
ffffffffc0203b26:	8385                	srli	a5,a5,0x1
ffffffffc0203b28:	8b85                	andi	a5,a5,1
ffffffffc0203b2a:	54079063          	bnez	a5,ffffffffc020406a <default_check+0x6e2>
ffffffffc0203b2e:	4505                	li	a0,1
ffffffffc0203b30:	00043b03          	ld	s6,0(s0)
ffffffffc0203b34:	00843a83          	ld	s5,8(s0)
ffffffffc0203b38:	e000                	sd	s0,0(s0)
ffffffffc0203b3a:	e400                	sd	s0,8(s0)
ffffffffc0203b3c:	faefd0ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0203b40:	50051563          	bnez	a0,ffffffffc020404a <default_check+0x6c2>
ffffffffc0203b44:	08098a13          	addi	s4,s3,128
ffffffffc0203b48:	8552                	mv	a0,s4
ffffffffc0203b4a:	458d                	li	a1,3
ffffffffc0203b4c:	01042b83          	lw	s7,16(s0)
ffffffffc0203b50:	0008e797          	auipc	a5,0x8e
ffffffffc0203b54:	c607a423          	sw	zero,-920(a5) # ffffffffc02917b8 <free_area+0x10>
ffffffffc0203b58:	fd0fd0ef          	jal	ra,ffffffffc0201328 <free_pages>
ffffffffc0203b5c:	4511                	li	a0,4
ffffffffc0203b5e:	f8cfd0ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0203b62:	4c051463          	bnez	a0,ffffffffc020402a <default_check+0x6a2>
ffffffffc0203b66:	0889b783          	ld	a5,136(s3)
ffffffffc0203b6a:	8385                	srli	a5,a5,0x1
ffffffffc0203b6c:	8b85                	andi	a5,a5,1
ffffffffc0203b6e:	48078e63          	beqz	a5,ffffffffc020400a <default_check+0x682>
ffffffffc0203b72:	0909a703          	lw	a4,144(s3)
ffffffffc0203b76:	478d                	li	a5,3
ffffffffc0203b78:	48f71963          	bne	a4,a5,ffffffffc020400a <default_check+0x682>
ffffffffc0203b7c:	450d                	li	a0,3
ffffffffc0203b7e:	f6cfd0ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0203b82:	8c2a                	mv	s8,a0
ffffffffc0203b84:	46050363          	beqz	a0,ffffffffc0203fea <default_check+0x662>
ffffffffc0203b88:	4505                	li	a0,1
ffffffffc0203b8a:	f60fd0ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0203b8e:	42051e63          	bnez	a0,ffffffffc0203fca <default_check+0x642>
ffffffffc0203b92:	418a1c63          	bne	s4,s8,ffffffffc0203faa <default_check+0x622>
ffffffffc0203b96:	4585                	li	a1,1
ffffffffc0203b98:	854e                	mv	a0,s3
ffffffffc0203b9a:	f8efd0ef          	jal	ra,ffffffffc0201328 <free_pages>
ffffffffc0203b9e:	458d                	li	a1,3
ffffffffc0203ba0:	8552                	mv	a0,s4
ffffffffc0203ba2:	f86fd0ef          	jal	ra,ffffffffc0201328 <free_pages>
ffffffffc0203ba6:	0089b783          	ld	a5,8(s3)
ffffffffc0203baa:	04098c13          	addi	s8,s3,64
ffffffffc0203bae:	8385                	srli	a5,a5,0x1
ffffffffc0203bb0:	8b85                	andi	a5,a5,1
ffffffffc0203bb2:	3c078c63          	beqz	a5,ffffffffc0203f8a <default_check+0x602>
ffffffffc0203bb6:	0109a703          	lw	a4,16(s3)
ffffffffc0203bba:	4785                	li	a5,1
ffffffffc0203bbc:	3cf71763          	bne	a4,a5,ffffffffc0203f8a <default_check+0x602>
ffffffffc0203bc0:	008a3783          	ld	a5,8(s4) # 1008 <_binary_bin_swap_img_size-0x6cf8>
ffffffffc0203bc4:	8385                	srli	a5,a5,0x1
ffffffffc0203bc6:	8b85                	andi	a5,a5,1
ffffffffc0203bc8:	3a078163          	beqz	a5,ffffffffc0203f6a <default_check+0x5e2>
ffffffffc0203bcc:	010a2703          	lw	a4,16(s4)
ffffffffc0203bd0:	478d                	li	a5,3
ffffffffc0203bd2:	38f71c63          	bne	a4,a5,ffffffffc0203f6a <default_check+0x5e2>
ffffffffc0203bd6:	4505                	li	a0,1
ffffffffc0203bd8:	f12fd0ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0203bdc:	36a99763          	bne	s3,a0,ffffffffc0203f4a <default_check+0x5c2>
ffffffffc0203be0:	4585                	li	a1,1
ffffffffc0203be2:	f46fd0ef          	jal	ra,ffffffffc0201328 <free_pages>
ffffffffc0203be6:	4509                	li	a0,2
ffffffffc0203be8:	f02fd0ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0203bec:	32aa1f63          	bne	s4,a0,ffffffffc0203f2a <default_check+0x5a2>
ffffffffc0203bf0:	4589                	li	a1,2
ffffffffc0203bf2:	f36fd0ef          	jal	ra,ffffffffc0201328 <free_pages>
ffffffffc0203bf6:	4585                	li	a1,1
ffffffffc0203bf8:	8562                	mv	a0,s8
ffffffffc0203bfa:	f2efd0ef          	jal	ra,ffffffffc0201328 <free_pages>
ffffffffc0203bfe:	4515                	li	a0,5
ffffffffc0203c00:	eeafd0ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0203c04:	89aa                	mv	s3,a0
ffffffffc0203c06:	48050263          	beqz	a0,ffffffffc020408a <default_check+0x702>
ffffffffc0203c0a:	4505                	li	a0,1
ffffffffc0203c0c:	edefd0ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0203c10:	2c051d63          	bnez	a0,ffffffffc0203eea <default_check+0x562>
ffffffffc0203c14:	481c                	lw	a5,16(s0)
ffffffffc0203c16:	2a079a63          	bnez	a5,ffffffffc0203eca <default_check+0x542>
ffffffffc0203c1a:	4595                	li	a1,5
ffffffffc0203c1c:	854e                	mv	a0,s3
ffffffffc0203c1e:	01742823          	sw	s7,16(s0)
ffffffffc0203c22:	01643023          	sd	s6,0(s0)
ffffffffc0203c26:	01543423          	sd	s5,8(s0)
ffffffffc0203c2a:	efefd0ef          	jal	ra,ffffffffc0201328 <free_pages>
ffffffffc0203c2e:	641c                	ld	a5,8(s0)
ffffffffc0203c30:	00878963          	beq	a5,s0,ffffffffc0203c42 <default_check+0x2ba>
ffffffffc0203c34:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203c38:	679c                	ld	a5,8(a5)
ffffffffc0203c3a:	397d                	addiw	s2,s2,-1
ffffffffc0203c3c:	9c99                	subw	s1,s1,a4
ffffffffc0203c3e:	fe879be3          	bne	a5,s0,ffffffffc0203c34 <default_check+0x2ac>
ffffffffc0203c42:	26091463          	bnez	s2,ffffffffc0203eaa <default_check+0x522>
ffffffffc0203c46:	46049263          	bnez	s1,ffffffffc02040aa <default_check+0x722>
ffffffffc0203c4a:	60a6                	ld	ra,72(sp)
ffffffffc0203c4c:	6406                	ld	s0,64(sp)
ffffffffc0203c4e:	74e2                	ld	s1,56(sp)
ffffffffc0203c50:	7942                	ld	s2,48(sp)
ffffffffc0203c52:	79a2                	ld	s3,40(sp)
ffffffffc0203c54:	7a02                	ld	s4,32(sp)
ffffffffc0203c56:	6ae2                	ld	s5,24(sp)
ffffffffc0203c58:	6b42                	ld	s6,16(sp)
ffffffffc0203c5a:	6ba2                	ld	s7,8(sp)
ffffffffc0203c5c:	6c02                	ld	s8,0(sp)
ffffffffc0203c5e:	6161                	addi	sp,sp,80
ffffffffc0203c60:	8082                	ret
ffffffffc0203c62:	4981                	li	s3,0
ffffffffc0203c64:	4481                	li	s1,0
ffffffffc0203c66:	4901                	li	s2,0
ffffffffc0203c68:	b38d                	j	ffffffffc02039ca <default_check+0x42>
ffffffffc0203c6a:	00009697          	auipc	a3,0x9
ffffffffc0203c6e:	fe668693          	addi	a3,a3,-26 # ffffffffc020cc50 <commands+0x1378>
ffffffffc0203c72:	00008617          	auipc	a2,0x8
ffffffffc0203c76:	eb660613          	addi	a2,a2,-330 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203c7a:	0ef00593          	li	a1,239
ffffffffc0203c7e:	00009517          	auipc	a0,0x9
ffffffffc0203c82:	fe250513          	addi	a0,a0,-30 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203c86:	da8fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203c8a:	00009697          	auipc	a3,0x9
ffffffffc0203c8e:	06e68693          	addi	a3,a3,110 # ffffffffc020ccf8 <commands+0x1420>
ffffffffc0203c92:	00008617          	auipc	a2,0x8
ffffffffc0203c96:	e9660613          	addi	a2,a2,-362 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203c9a:	0bc00593          	li	a1,188
ffffffffc0203c9e:	00009517          	auipc	a0,0x9
ffffffffc0203ca2:	fc250513          	addi	a0,a0,-62 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203ca6:	d88fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203caa:	00009697          	auipc	a3,0x9
ffffffffc0203cae:	07668693          	addi	a3,a3,118 # ffffffffc020cd20 <commands+0x1448>
ffffffffc0203cb2:	00008617          	auipc	a2,0x8
ffffffffc0203cb6:	e7660613          	addi	a2,a2,-394 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203cba:	0bd00593          	li	a1,189
ffffffffc0203cbe:	00009517          	auipc	a0,0x9
ffffffffc0203cc2:	fa250513          	addi	a0,a0,-94 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203cc6:	d68fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203cca:	00009697          	auipc	a3,0x9
ffffffffc0203cce:	09668693          	addi	a3,a3,150 # ffffffffc020cd60 <commands+0x1488>
ffffffffc0203cd2:	00008617          	auipc	a2,0x8
ffffffffc0203cd6:	e5660613          	addi	a2,a2,-426 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203cda:	0bf00593          	li	a1,191
ffffffffc0203cde:	00009517          	auipc	a0,0x9
ffffffffc0203ce2:	f8250513          	addi	a0,a0,-126 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203ce6:	d48fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203cea:	00009697          	auipc	a3,0x9
ffffffffc0203cee:	0fe68693          	addi	a3,a3,254 # ffffffffc020cde8 <commands+0x1510>
ffffffffc0203cf2:	00008617          	auipc	a2,0x8
ffffffffc0203cf6:	e3660613          	addi	a2,a2,-458 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203cfa:	0d800593          	li	a1,216
ffffffffc0203cfe:	00009517          	auipc	a0,0x9
ffffffffc0203d02:	f6250513          	addi	a0,a0,-158 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203d06:	d28fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203d0a:	00009697          	auipc	a3,0x9
ffffffffc0203d0e:	f8e68693          	addi	a3,a3,-114 # ffffffffc020cc98 <commands+0x13c0>
ffffffffc0203d12:	00008617          	auipc	a2,0x8
ffffffffc0203d16:	e1660613          	addi	a2,a2,-490 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203d1a:	0d100593          	li	a1,209
ffffffffc0203d1e:	00009517          	auipc	a0,0x9
ffffffffc0203d22:	f4250513          	addi	a0,a0,-190 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203d26:	d08fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203d2a:	00009697          	auipc	a3,0x9
ffffffffc0203d2e:	0ae68693          	addi	a3,a3,174 # ffffffffc020cdd8 <commands+0x1500>
ffffffffc0203d32:	00008617          	auipc	a2,0x8
ffffffffc0203d36:	df660613          	addi	a2,a2,-522 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203d3a:	0cf00593          	li	a1,207
ffffffffc0203d3e:	00009517          	auipc	a0,0x9
ffffffffc0203d42:	f2250513          	addi	a0,a0,-222 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203d46:	ce8fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203d4a:	00009697          	auipc	a3,0x9
ffffffffc0203d4e:	07668693          	addi	a3,a3,118 # ffffffffc020cdc0 <commands+0x14e8>
ffffffffc0203d52:	00008617          	auipc	a2,0x8
ffffffffc0203d56:	dd660613          	addi	a2,a2,-554 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203d5a:	0ca00593          	li	a1,202
ffffffffc0203d5e:	00009517          	auipc	a0,0x9
ffffffffc0203d62:	f0250513          	addi	a0,a0,-254 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203d66:	cc8fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203d6a:	00009697          	auipc	a3,0x9
ffffffffc0203d6e:	03668693          	addi	a3,a3,54 # ffffffffc020cda0 <commands+0x14c8>
ffffffffc0203d72:	00008617          	auipc	a2,0x8
ffffffffc0203d76:	db660613          	addi	a2,a2,-586 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203d7a:	0c100593          	li	a1,193
ffffffffc0203d7e:	00009517          	auipc	a0,0x9
ffffffffc0203d82:	ee250513          	addi	a0,a0,-286 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203d86:	ca8fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203d8a:	00009697          	auipc	a3,0x9
ffffffffc0203d8e:	0a668693          	addi	a3,a3,166 # ffffffffc020ce30 <commands+0x1558>
ffffffffc0203d92:	00008617          	auipc	a2,0x8
ffffffffc0203d96:	d9660613          	addi	a2,a2,-618 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203d9a:	0f700593          	li	a1,247
ffffffffc0203d9e:	00009517          	auipc	a0,0x9
ffffffffc0203da2:	ec250513          	addi	a0,a0,-318 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203da6:	c88fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203daa:	00009697          	auipc	a3,0x9
ffffffffc0203dae:	07668693          	addi	a3,a3,118 # ffffffffc020ce20 <commands+0x1548>
ffffffffc0203db2:	00008617          	auipc	a2,0x8
ffffffffc0203db6:	d7660613          	addi	a2,a2,-650 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203dba:	0de00593          	li	a1,222
ffffffffc0203dbe:	00009517          	auipc	a0,0x9
ffffffffc0203dc2:	ea250513          	addi	a0,a0,-350 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203dc6:	c68fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203dca:	00009697          	auipc	a3,0x9
ffffffffc0203dce:	ff668693          	addi	a3,a3,-10 # ffffffffc020cdc0 <commands+0x14e8>
ffffffffc0203dd2:	00008617          	auipc	a2,0x8
ffffffffc0203dd6:	d5660613          	addi	a2,a2,-682 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203dda:	0dc00593          	li	a1,220
ffffffffc0203dde:	00009517          	auipc	a0,0x9
ffffffffc0203de2:	e8250513          	addi	a0,a0,-382 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203de6:	c48fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203dea:	00009697          	auipc	a3,0x9
ffffffffc0203dee:	01668693          	addi	a3,a3,22 # ffffffffc020ce00 <commands+0x1528>
ffffffffc0203df2:	00008617          	auipc	a2,0x8
ffffffffc0203df6:	d3660613          	addi	a2,a2,-714 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203dfa:	0db00593          	li	a1,219
ffffffffc0203dfe:	00009517          	auipc	a0,0x9
ffffffffc0203e02:	e6250513          	addi	a0,a0,-414 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203e06:	c28fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203e0a:	00009697          	auipc	a3,0x9
ffffffffc0203e0e:	e8e68693          	addi	a3,a3,-370 # ffffffffc020cc98 <commands+0x13c0>
ffffffffc0203e12:	00008617          	auipc	a2,0x8
ffffffffc0203e16:	d1660613          	addi	a2,a2,-746 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203e1a:	0b800593          	li	a1,184
ffffffffc0203e1e:	00009517          	auipc	a0,0x9
ffffffffc0203e22:	e4250513          	addi	a0,a0,-446 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203e26:	c08fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203e2a:	00009697          	auipc	a3,0x9
ffffffffc0203e2e:	f9668693          	addi	a3,a3,-106 # ffffffffc020cdc0 <commands+0x14e8>
ffffffffc0203e32:	00008617          	auipc	a2,0x8
ffffffffc0203e36:	cf660613          	addi	a2,a2,-778 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203e3a:	0d500593          	li	a1,213
ffffffffc0203e3e:	00009517          	auipc	a0,0x9
ffffffffc0203e42:	e2250513          	addi	a0,a0,-478 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203e46:	be8fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203e4a:	00009697          	auipc	a3,0x9
ffffffffc0203e4e:	e8e68693          	addi	a3,a3,-370 # ffffffffc020ccd8 <commands+0x1400>
ffffffffc0203e52:	00008617          	auipc	a2,0x8
ffffffffc0203e56:	cd660613          	addi	a2,a2,-810 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203e5a:	0d300593          	li	a1,211
ffffffffc0203e5e:	00009517          	auipc	a0,0x9
ffffffffc0203e62:	e0250513          	addi	a0,a0,-510 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203e66:	bc8fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203e6a:	00009697          	auipc	a3,0x9
ffffffffc0203e6e:	e4e68693          	addi	a3,a3,-434 # ffffffffc020ccb8 <commands+0x13e0>
ffffffffc0203e72:	00008617          	auipc	a2,0x8
ffffffffc0203e76:	cb660613          	addi	a2,a2,-842 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203e7a:	0d200593          	li	a1,210
ffffffffc0203e7e:	00009517          	auipc	a0,0x9
ffffffffc0203e82:	de250513          	addi	a0,a0,-542 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203e86:	ba8fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203e8a:	00009697          	auipc	a3,0x9
ffffffffc0203e8e:	e4e68693          	addi	a3,a3,-434 # ffffffffc020ccd8 <commands+0x1400>
ffffffffc0203e92:	00008617          	auipc	a2,0x8
ffffffffc0203e96:	c9660613          	addi	a2,a2,-874 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203e9a:	0ba00593          	li	a1,186
ffffffffc0203e9e:	00009517          	auipc	a0,0x9
ffffffffc0203ea2:	dc250513          	addi	a0,a0,-574 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203ea6:	b88fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203eaa:	00009697          	auipc	a3,0x9
ffffffffc0203eae:	0d668693          	addi	a3,a3,214 # ffffffffc020cf80 <commands+0x16a8>
ffffffffc0203eb2:	00008617          	auipc	a2,0x8
ffffffffc0203eb6:	c7660613          	addi	a2,a2,-906 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203eba:	12400593          	li	a1,292
ffffffffc0203ebe:	00009517          	auipc	a0,0x9
ffffffffc0203ec2:	da250513          	addi	a0,a0,-606 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203ec6:	b68fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203eca:	00009697          	auipc	a3,0x9
ffffffffc0203ece:	f5668693          	addi	a3,a3,-170 # ffffffffc020ce20 <commands+0x1548>
ffffffffc0203ed2:	00008617          	auipc	a2,0x8
ffffffffc0203ed6:	c5660613          	addi	a2,a2,-938 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203eda:	11900593          	li	a1,281
ffffffffc0203ede:	00009517          	auipc	a0,0x9
ffffffffc0203ee2:	d8250513          	addi	a0,a0,-638 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203ee6:	b48fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203eea:	00009697          	auipc	a3,0x9
ffffffffc0203eee:	ed668693          	addi	a3,a3,-298 # ffffffffc020cdc0 <commands+0x14e8>
ffffffffc0203ef2:	00008617          	auipc	a2,0x8
ffffffffc0203ef6:	c3660613          	addi	a2,a2,-970 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203efa:	11700593          	li	a1,279
ffffffffc0203efe:	00009517          	auipc	a0,0x9
ffffffffc0203f02:	d6250513          	addi	a0,a0,-670 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203f06:	b28fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203f0a:	00009697          	auipc	a3,0x9
ffffffffc0203f0e:	e7668693          	addi	a3,a3,-394 # ffffffffc020cd80 <commands+0x14a8>
ffffffffc0203f12:	00008617          	auipc	a2,0x8
ffffffffc0203f16:	c1660613          	addi	a2,a2,-1002 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203f1a:	0c000593          	li	a1,192
ffffffffc0203f1e:	00009517          	auipc	a0,0x9
ffffffffc0203f22:	d4250513          	addi	a0,a0,-702 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203f26:	b08fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203f2a:	00009697          	auipc	a3,0x9
ffffffffc0203f2e:	01668693          	addi	a3,a3,22 # ffffffffc020cf40 <commands+0x1668>
ffffffffc0203f32:	00008617          	auipc	a2,0x8
ffffffffc0203f36:	bf660613          	addi	a2,a2,-1034 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203f3a:	11100593          	li	a1,273
ffffffffc0203f3e:	00009517          	auipc	a0,0x9
ffffffffc0203f42:	d2250513          	addi	a0,a0,-734 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203f46:	ae8fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203f4a:	00009697          	auipc	a3,0x9
ffffffffc0203f4e:	fd668693          	addi	a3,a3,-42 # ffffffffc020cf20 <commands+0x1648>
ffffffffc0203f52:	00008617          	auipc	a2,0x8
ffffffffc0203f56:	bd660613          	addi	a2,a2,-1066 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203f5a:	10f00593          	li	a1,271
ffffffffc0203f5e:	00009517          	auipc	a0,0x9
ffffffffc0203f62:	d0250513          	addi	a0,a0,-766 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203f66:	ac8fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203f6a:	00009697          	auipc	a3,0x9
ffffffffc0203f6e:	f8e68693          	addi	a3,a3,-114 # ffffffffc020cef8 <commands+0x1620>
ffffffffc0203f72:	00008617          	auipc	a2,0x8
ffffffffc0203f76:	bb660613          	addi	a2,a2,-1098 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203f7a:	10d00593          	li	a1,269
ffffffffc0203f7e:	00009517          	auipc	a0,0x9
ffffffffc0203f82:	ce250513          	addi	a0,a0,-798 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203f86:	aa8fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203f8a:	00009697          	auipc	a3,0x9
ffffffffc0203f8e:	f4668693          	addi	a3,a3,-186 # ffffffffc020ced0 <commands+0x15f8>
ffffffffc0203f92:	00008617          	auipc	a2,0x8
ffffffffc0203f96:	b9660613          	addi	a2,a2,-1130 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203f9a:	10c00593          	li	a1,268
ffffffffc0203f9e:	00009517          	auipc	a0,0x9
ffffffffc0203fa2:	cc250513          	addi	a0,a0,-830 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203fa6:	a88fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203faa:	00009697          	auipc	a3,0x9
ffffffffc0203fae:	f1668693          	addi	a3,a3,-234 # ffffffffc020cec0 <commands+0x15e8>
ffffffffc0203fb2:	00008617          	auipc	a2,0x8
ffffffffc0203fb6:	b7660613          	addi	a2,a2,-1162 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203fba:	10700593          	li	a1,263
ffffffffc0203fbe:	00009517          	auipc	a0,0x9
ffffffffc0203fc2:	ca250513          	addi	a0,a0,-862 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203fc6:	a68fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203fca:	00009697          	auipc	a3,0x9
ffffffffc0203fce:	df668693          	addi	a3,a3,-522 # ffffffffc020cdc0 <commands+0x14e8>
ffffffffc0203fd2:	00008617          	auipc	a2,0x8
ffffffffc0203fd6:	b5660613          	addi	a2,a2,-1194 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203fda:	10600593          	li	a1,262
ffffffffc0203fde:	00009517          	auipc	a0,0x9
ffffffffc0203fe2:	c8250513          	addi	a0,a0,-894 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0203fe6:	a48fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203fea:	00009697          	auipc	a3,0x9
ffffffffc0203fee:	eb668693          	addi	a3,a3,-330 # ffffffffc020cea0 <commands+0x15c8>
ffffffffc0203ff2:	00008617          	auipc	a2,0x8
ffffffffc0203ff6:	b3660613          	addi	a2,a2,-1226 # ffffffffc020bb28 <commands+0x250>
ffffffffc0203ffa:	10500593          	li	a1,261
ffffffffc0203ffe:	00009517          	auipc	a0,0x9
ffffffffc0204002:	c6250513          	addi	a0,a0,-926 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0204006:	a28fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020400a:	00009697          	auipc	a3,0x9
ffffffffc020400e:	e6668693          	addi	a3,a3,-410 # ffffffffc020ce70 <commands+0x1598>
ffffffffc0204012:	00008617          	auipc	a2,0x8
ffffffffc0204016:	b1660613          	addi	a2,a2,-1258 # ffffffffc020bb28 <commands+0x250>
ffffffffc020401a:	10400593          	li	a1,260
ffffffffc020401e:	00009517          	auipc	a0,0x9
ffffffffc0204022:	c4250513          	addi	a0,a0,-958 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0204026:	a08fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020402a:	00009697          	auipc	a3,0x9
ffffffffc020402e:	e2e68693          	addi	a3,a3,-466 # ffffffffc020ce58 <commands+0x1580>
ffffffffc0204032:	00008617          	auipc	a2,0x8
ffffffffc0204036:	af660613          	addi	a2,a2,-1290 # ffffffffc020bb28 <commands+0x250>
ffffffffc020403a:	10300593          	li	a1,259
ffffffffc020403e:	00009517          	auipc	a0,0x9
ffffffffc0204042:	c2250513          	addi	a0,a0,-990 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0204046:	9e8fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020404a:	00009697          	auipc	a3,0x9
ffffffffc020404e:	d7668693          	addi	a3,a3,-650 # ffffffffc020cdc0 <commands+0x14e8>
ffffffffc0204052:	00008617          	auipc	a2,0x8
ffffffffc0204056:	ad660613          	addi	a2,a2,-1322 # ffffffffc020bb28 <commands+0x250>
ffffffffc020405a:	0fd00593          	li	a1,253
ffffffffc020405e:	00009517          	auipc	a0,0x9
ffffffffc0204062:	c0250513          	addi	a0,a0,-1022 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0204066:	9c8fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020406a:	00009697          	auipc	a3,0x9
ffffffffc020406e:	dd668693          	addi	a3,a3,-554 # ffffffffc020ce40 <commands+0x1568>
ffffffffc0204072:	00008617          	auipc	a2,0x8
ffffffffc0204076:	ab660613          	addi	a2,a2,-1354 # ffffffffc020bb28 <commands+0x250>
ffffffffc020407a:	0f800593          	li	a1,248
ffffffffc020407e:	00009517          	auipc	a0,0x9
ffffffffc0204082:	be250513          	addi	a0,a0,-1054 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0204086:	9a8fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020408a:	00009697          	auipc	a3,0x9
ffffffffc020408e:	ed668693          	addi	a3,a3,-298 # ffffffffc020cf60 <commands+0x1688>
ffffffffc0204092:	00008617          	auipc	a2,0x8
ffffffffc0204096:	a9660613          	addi	a2,a2,-1386 # ffffffffc020bb28 <commands+0x250>
ffffffffc020409a:	11600593          	li	a1,278
ffffffffc020409e:	00009517          	auipc	a0,0x9
ffffffffc02040a2:	bc250513          	addi	a0,a0,-1086 # ffffffffc020cc60 <commands+0x1388>
ffffffffc02040a6:	988fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02040aa:	00009697          	auipc	a3,0x9
ffffffffc02040ae:	ee668693          	addi	a3,a3,-282 # ffffffffc020cf90 <commands+0x16b8>
ffffffffc02040b2:	00008617          	auipc	a2,0x8
ffffffffc02040b6:	a7660613          	addi	a2,a2,-1418 # ffffffffc020bb28 <commands+0x250>
ffffffffc02040ba:	12500593          	li	a1,293
ffffffffc02040be:	00009517          	auipc	a0,0x9
ffffffffc02040c2:	ba250513          	addi	a0,a0,-1118 # ffffffffc020cc60 <commands+0x1388>
ffffffffc02040c6:	968fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02040ca:	00009697          	auipc	a3,0x9
ffffffffc02040ce:	bae68693          	addi	a3,a3,-1106 # ffffffffc020cc78 <commands+0x13a0>
ffffffffc02040d2:	00008617          	auipc	a2,0x8
ffffffffc02040d6:	a5660613          	addi	a2,a2,-1450 # ffffffffc020bb28 <commands+0x250>
ffffffffc02040da:	0f200593          	li	a1,242
ffffffffc02040de:	00009517          	auipc	a0,0x9
ffffffffc02040e2:	b8250513          	addi	a0,a0,-1150 # ffffffffc020cc60 <commands+0x1388>
ffffffffc02040e6:	948fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02040ea:	00009697          	auipc	a3,0x9
ffffffffc02040ee:	bce68693          	addi	a3,a3,-1074 # ffffffffc020ccb8 <commands+0x13e0>
ffffffffc02040f2:	00008617          	auipc	a2,0x8
ffffffffc02040f6:	a3660613          	addi	a2,a2,-1482 # ffffffffc020bb28 <commands+0x250>
ffffffffc02040fa:	0b900593          	li	a1,185
ffffffffc02040fe:	00009517          	auipc	a0,0x9
ffffffffc0204102:	b6250513          	addi	a0,a0,-1182 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0204106:	928fc0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020410a <default_free_pages>:
ffffffffc020410a:	1141                	addi	sp,sp,-16
ffffffffc020410c:	e406                	sd	ra,8(sp)
ffffffffc020410e:	14058463          	beqz	a1,ffffffffc0204256 <default_free_pages+0x14c>
ffffffffc0204112:	00659693          	slli	a3,a1,0x6
ffffffffc0204116:	96aa                	add	a3,a3,a0
ffffffffc0204118:	87aa                	mv	a5,a0
ffffffffc020411a:	02d50263          	beq	a0,a3,ffffffffc020413e <default_free_pages+0x34>
ffffffffc020411e:	6798                	ld	a4,8(a5)
ffffffffc0204120:	8b05                	andi	a4,a4,1
ffffffffc0204122:	10071a63          	bnez	a4,ffffffffc0204236 <default_free_pages+0x12c>
ffffffffc0204126:	6798                	ld	a4,8(a5)
ffffffffc0204128:	8b09                	andi	a4,a4,2
ffffffffc020412a:	10071663          	bnez	a4,ffffffffc0204236 <default_free_pages+0x12c>
ffffffffc020412e:	0007b423          	sd	zero,8(a5)
ffffffffc0204132:	0007a023          	sw	zero,0(a5)
ffffffffc0204136:	04078793          	addi	a5,a5,64
ffffffffc020413a:	fed792e3          	bne	a5,a3,ffffffffc020411e <default_free_pages+0x14>
ffffffffc020413e:	2581                	sext.w	a1,a1
ffffffffc0204140:	c90c                	sw	a1,16(a0)
ffffffffc0204142:	00850893          	addi	a7,a0,8
ffffffffc0204146:	4789                	li	a5,2
ffffffffc0204148:	40f8b02f          	amoor.d	zero,a5,(a7)
ffffffffc020414c:	0008d697          	auipc	a3,0x8d
ffffffffc0204150:	65c68693          	addi	a3,a3,1628 # ffffffffc02917a8 <free_area>
ffffffffc0204154:	4a98                	lw	a4,16(a3)
ffffffffc0204156:	669c                	ld	a5,8(a3)
ffffffffc0204158:	01850613          	addi	a2,a0,24
ffffffffc020415c:	9db9                	addw	a1,a1,a4
ffffffffc020415e:	ca8c                	sw	a1,16(a3)
ffffffffc0204160:	0ad78463          	beq	a5,a3,ffffffffc0204208 <default_free_pages+0xfe>
ffffffffc0204164:	fe878713          	addi	a4,a5,-24
ffffffffc0204168:	0006b803          	ld	a6,0(a3)
ffffffffc020416c:	4581                	li	a1,0
ffffffffc020416e:	00e56a63          	bltu	a0,a4,ffffffffc0204182 <default_free_pages+0x78>
ffffffffc0204172:	6798                	ld	a4,8(a5)
ffffffffc0204174:	04d70c63          	beq	a4,a3,ffffffffc02041cc <default_free_pages+0xc2>
ffffffffc0204178:	87ba                	mv	a5,a4
ffffffffc020417a:	fe878713          	addi	a4,a5,-24
ffffffffc020417e:	fee57ae3          	bgeu	a0,a4,ffffffffc0204172 <default_free_pages+0x68>
ffffffffc0204182:	c199                	beqz	a1,ffffffffc0204188 <default_free_pages+0x7e>
ffffffffc0204184:	0106b023          	sd	a6,0(a3)
ffffffffc0204188:	6398                	ld	a4,0(a5)
ffffffffc020418a:	e390                	sd	a2,0(a5)
ffffffffc020418c:	e710                	sd	a2,8(a4)
ffffffffc020418e:	f11c                	sd	a5,32(a0)
ffffffffc0204190:	ed18                	sd	a4,24(a0)
ffffffffc0204192:	00d70d63          	beq	a4,a3,ffffffffc02041ac <default_free_pages+0xa2>
ffffffffc0204196:	ff872583          	lw	a1,-8(a4) # ff8 <_binary_bin_swap_img_size-0x6d08>
ffffffffc020419a:	fe870613          	addi	a2,a4,-24
ffffffffc020419e:	02059813          	slli	a6,a1,0x20
ffffffffc02041a2:	01a85793          	srli	a5,a6,0x1a
ffffffffc02041a6:	97b2                	add	a5,a5,a2
ffffffffc02041a8:	02f50c63          	beq	a0,a5,ffffffffc02041e0 <default_free_pages+0xd6>
ffffffffc02041ac:	711c                	ld	a5,32(a0)
ffffffffc02041ae:	00d78c63          	beq	a5,a3,ffffffffc02041c6 <default_free_pages+0xbc>
ffffffffc02041b2:	4910                	lw	a2,16(a0)
ffffffffc02041b4:	fe878693          	addi	a3,a5,-24
ffffffffc02041b8:	02061593          	slli	a1,a2,0x20
ffffffffc02041bc:	01a5d713          	srli	a4,a1,0x1a
ffffffffc02041c0:	972a                	add	a4,a4,a0
ffffffffc02041c2:	04e68a63          	beq	a3,a4,ffffffffc0204216 <default_free_pages+0x10c>
ffffffffc02041c6:	60a2                	ld	ra,8(sp)
ffffffffc02041c8:	0141                	addi	sp,sp,16
ffffffffc02041ca:	8082                	ret
ffffffffc02041cc:	e790                	sd	a2,8(a5)
ffffffffc02041ce:	f114                	sd	a3,32(a0)
ffffffffc02041d0:	6798                	ld	a4,8(a5)
ffffffffc02041d2:	ed1c                	sd	a5,24(a0)
ffffffffc02041d4:	02d70763          	beq	a4,a3,ffffffffc0204202 <default_free_pages+0xf8>
ffffffffc02041d8:	8832                	mv	a6,a2
ffffffffc02041da:	4585                	li	a1,1
ffffffffc02041dc:	87ba                	mv	a5,a4
ffffffffc02041de:	bf71                	j	ffffffffc020417a <default_free_pages+0x70>
ffffffffc02041e0:	491c                	lw	a5,16(a0)
ffffffffc02041e2:	9dbd                	addw	a1,a1,a5
ffffffffc02041e4:	feb72c23          	sw	a1,-8(a4)
ffffffffc02041e8:	57f5                	li	a5,-3
ffffffffc02041ea:	60f8b02f          	amoand.d	zero,a5,(a7)
ffffffffc02041ee:	01853803          	ld	a6,24(a0)
ffffffffc02041f2:	710c                	ld	a1,32(a0)
ffffffffc02041f4:	8532                	mv	a0,a2
ffffffffc02041f6:	00b83423          	sd	a1,8(a6)
ffffffffc02041fa:	671c                	ld	a5,8(a4)
ffffffffc02041fc:	0105b023          	sd	a6,0(a1) # 1000 <_binary_bin_swap_img_size-0x6d00>
ffffffffc0204200:	b77d                	j	ffffffffc02041ae <default_free_pages+0xa4>
ffffffffc0204202:	e290                	sd	a2,0(a3)
ffffffffc0204204:	873e                	mv	a4,a5
ffffffffc0204206:	bf41                	j	ffffffffc0204196 <default_free_pages+0x8c>
ffffffffc0204208:	60a2                	ld	ra,8(sp)
ffffffffc020420a:	e390                	sd	a2,0(a5)
ffffffffc020420c:	e790                	sd	a2,8(a5)
ffffffffc020420e:	f11c                	sd	a5,32(a0)
ffffffffc0204210:	ed1c                	sd	a5,24(a0)
ffffffffc0204212:	0141                	addi	sp,sp,16
ffffffffc0204214:	8082                	ret
ffffffffc0204216:	ff87a703          	lw	a4,-8(a5)
ffffffffc020421a:	ff078693          	addi	a3,a5,-16
ffffffffc020421e:	9e39                	addw	a2,a2,a4
ffffffffc0204220:	c910                	sw	a2,16(a0)
ffffffffc0204222:	5775                	li	a4,-3
ffffffffc0204224:	60e6b02f          	amoand.d	zero,a4,(a3)
ffffffffc0204228:	6398                	ld	a4,0(a5)
ffffffffc020422a:	679c                	ld	a5,8(a5)
ffffffffc020422c:	60a2                	ld	ra,8(sp)
ffffffffc020422e:	e71c                	sd	a5,8(a4)
ffffffffc0204230:	e398                	sd	a4,0(a5)
ffffffffc0204232:	0141                	addi	sp,sp,16
ffffffffc0204234:	8082                	ret
ffffffffc0204236:	00009697          	auipc	a3,0x9
ffffffffc020423a:	d7268693          	addi	a3,a3,-654 # ffffffffc020cfa8 <commands+0x16d0>
ffffffffc020423e:	00008617          	auipc	a2,0x8
ffffffffc0204242:	8ea60613          	addi	a2,a2,-1814 # ffffffffc020bb28 <commands+0x250>
ffffffffc0204246:	08200593          	li	a1,130
ffffffffc020424a:	00009517          	auipc	a0,0x9
ffffffffc020424e:	a1650513          	addi	a0,a0,-1514 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0204252:	fddfb0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0204256:	00009697          	auipc	a3,0x9
ffffffffc020425a:	d4a68693          	addi	a3,a3,-694 # ffffffffc020cfa0 <commands+0x16c8>
ffffffffc020425e:	00008617          	auipc	a2,0x8
ffffffffc0204262:	8ca60613          	addi	a2,a2,-1846 # ffffffffc020bb28 <commands+0x250>
ffffffffc0204266:	07f00593          	li	a1,127
ffffffffc020426a:	00009517          	auipc	a0,0x9
ffffffffc020426e:	9f650513          	addi	a0,a0,-1546 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0204272:	fbdfb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0204276 <default_alloc_pages>:
ffffffffc0204276:	c941                	beqz	a0,ffffffffc0204306 <default_alloc_pages+0x90>
ffffffffc0204278:	0008d597          	auipc	a1,0x8d
ffffffffc020427c:	53058593          	addi	a1,a1,1328 # ffffffffc02917a8 <free_area>
ffffffffc0204280:	0105a803          	lw	a6,16(a1)
ffffffffc0204284:	872a                	mv	a4,a0
ffffffffc0204286:	02081793          	slli	a5,a6,0x20
ffffffffc020428a:	9381                	srli	a5,a5,0x20
ffffffffc020428c:	00a7ee63          	bltu	a5,a0,ffffffffc02042a8 <default_alloc_pages+0x32>
ffffffffc0204290:	87ae                	mv	a5,a1
ffffffffc0204292:	a801                	j	ffffffffc02042a2 <default_alloc_pages+0x2c>
ffffffffc0204294:	ff87a683          	lw	a3,-8(a5)
ffffffffc0204298:	02069613          	slli	a2,a3,0x20
ffffffffc020429c:	9201                	srli	a2,a2,0x20
ffffffffc020429e:	00e67763          	bgeu	a2,a4,ffffffffc02042ac <default_alloc_pages+0x36>
ffffffffc02042a2:	679c                	ld	a5,8(a5)
ffffffffc02042a4:	feb798e3          	bne	a5,a1,ffffffffc0204294 <default_alloc_pages+0x1e>
ffffffffc02042a8:	4501                	li	a0,0
ffffffffc02042aa:	8082                	ret
ffffffffc02042ac:	0007b883          	ld	a7,0(a5)
ffffffffc02042b0:	0087b303          	ld	t1,8(a5)
ffffffffc02042b4:	fe878513          	addi	a0,a5,-24
ffffffffc02042b8:	00070e1b          	sext.w	t3,a4
ffffffffc02042bc:	0068b423          	sd	t1,8(a7) # 1008 <_binary_bin_swap_img_size-0x6cf8>
ffffffffc02042c0:	01133023          	sd	a7,0(t1) # 80000 <_binary_bin_sfs_img_size+0xad00>
ffffffffc02042c4:	02c77863          	bgeu	a4,a2,ffffffffc02042f4 <default_alloc_pages+0x7e>
ffffffffc02042c8:	071a                	slli	a4,a4,0x6
ffffffffc02042ca:	972a                	add	a4,a4,a0
ffffffffc02042cc:	41c686bb          	subw	a3,a3,t3
ffffffffc02042d0:	cb14                	sw	a3,16(a4)
ffffffffc02042d2:	00870613          	addi	a2,a4,8
ffffffffc02042d6:	4689                	li	a3,2
ffffffffc02042d8:	40d6302f          	amoor.d	zero,a3,(a2)
ffffffffc02042dc:	0088b683          	ld	a3,8(a7)
ffffffffc02042e0:	01870613          	addi	a2,a4,24
ffffffffc02042e4:	0105a803          	lw	a6,16(a1)
ffffffffc02042e8:	e290                	sd	a2,0(a3)
ffffffffc02042ea:	00c8b423          	sd	a2,8(a7)
ffffffffc02042ee:	f314                	sd	a3,32(a4)
ffffffffc02042f0:	01173c23          	sd	a7,24(a4)
ffffffffc02042f4:	41c8083b          	subw	a6,a6,t3
ffffffffc02042f8:	0105a823          	sw	a6,16(a1)
ffffffffc02042fc:	5775                	li	a4,-3
ffffffffc02042fe:	17c1                	addi	a5,a5,-16
ffffffffc0204300:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0204304:	8082                	ret
ffffffffc0204306:	1141                	addi	sp,sp,-16
ffffffffc0204308:	00009697          	auipc	a3,0x9
ffffffffc020430c:	c9868693          	addi	a3,a3,-872 # ffffffffc020cfa0 <commands+0x16c8>
ffffffffc0204310:	00008617          	auipc	a2,0x8
ffffffffc0204314:	81860613          	addi	a2,a2,-2024 # ffffffffc020bb28 <commands+0x250>
ffffffffc0204318:	06100593          	li	a1,97
ffffffffc020431c:	00009517          	auipc	a0,0x9
ffffffffc0204320:	94450513          	addi	a0,a0,-1724 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0204324:	e406                	sd	ra,8(sp)
ffffffffc0204326:	f09fb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020432a <default_init_memmap>:
ffffffffc020432a:	1141                	addi	sp,sp,-16
ffffffffc020432c:	e406                	sd	ra,8(sp)
ffffffffc020432e:	c5f1                	beqz	a1,ffffffffc02043fa <default_init_memmap+0xd0>
ffffffffc0204330:	00659693          	slli	a3,a1,0x6
ffffffffc0204334:	96aa                	add	a3,a3,a0
ffffffffc0204336:	87aa                	mv	a5,a0
ffffffffc0204338:	00d50f63          	beq	a0,a3,ffffffffc0204356 <default_init_memmap+0x2c>
ffffffffc020433c:	6798                	ld	a4,8(a5)
ffffffffc020433e:	8b05                	andi	a4,a4,1
ffffffffc0204340:	cf49                	beqz	a4,ffffffffc02043da <default_init_memmap+0xb0>
ffffffffc0204342:	0007a823          	sw	zero,16(a5)
ffffffffc0204346:	0007b423          	sd	zero,8(a5)
ffffffffc020434a:	0007a023          	sw	zero,0(a5)
ffffffffc020434e:	04078793          	addi	a5,a5,64
ffffffffc0204352:	fed795e3          	bne	a5,a3,ffffffffc020433c <default_init_memmap+0x12>
ffffffffc0204356:	2581                	sext.w	a1,a1
ffffffffc0204358:	c90c                	sw	a1,16(a0)
ffffffffc020435a:	4789                	li	a5,2
ffffffffc020435c:	00850713          	addi	a4,a0,8
ffffffffc0204360:	40f7302f          	amoor.d	zero,a5,(a4)
ffffffffc0204364:	0008d697          	auipc	a3,0x8d
ffffffffc0204368:	44468693          	addi	a3,a3,1092 # ffffffffc02917a8 <free_area>
ffffffffc020436c:	4a98                	lw	a4,16(a3)
ffffffffc020436e:	669c                	ld	a5,8(a3)
ffffffffc0204370:	01850613          	addi	a2,a0,24
ffffffffc0204374:	9db9                	addw	a1,a1,a4
ffffffffc0204376:	ca8c                	sw	a1,16(a3)
ffffffffc0204378:	04d78a63          	beq	a5,a3,ffffffffc02043cc <default_init_memmap+0xa2>
ffffffffc020437c:	fe878713          	addi	a4,a5,-24
ffffffffc0204380:	0006b803          	ld	a6,0(a3)
ffffffffc0204384:	4581                	li	a1,0
ffffffffc0204386:	00e56a63          	bltu	a0,a4,ffffffffc020439a <default_init_memmap+0x70>
ffffffffc020438a:	6798                	ld	a4,8(a5)
ffffffffc020438c:	02d70263          	beq	a4,a3,ffffffffc02043b0 <default_init_memmap+0x86>
ffffffffc0204390:	87ba                	mv	a5,a4
ffffffffc0204392:	fe878713          	addi	a4,a5,-24
ffffffffc0204396:	fee57ae3          	bgeu	a0,a4,ffffffffc020438a <default_init_memmap+0x60>
ffffffffc020439a:	c199                	beqz	a1,ffffffffc02043a0 <default_init_memmap+0x76>
ffffffffc020439c:	0106b023          	sd	a6,0(a3)
ffffffffc02043a0:	6398                	ld	a4,0(a5)
ffffffffc02043a2:	60a2                	ld	ra,8(sp)
ffffffffc02043a4:	e390                	sd	a2,0(a5)
ffffffffc02043a6:	e710                	sd	a2,8(a4)
ffffffffc02043a8:	f11c                	sd	a5,32(a0)
ffffffffc02043aa:	ed18                	sd	a4,24(a0)
ffffffffc02043ac:	0141                	addi	sp,sp,16
ffffffffc02043ae:	8082                	ret
ffffffffc02043b0:	e790                	sd	a2,8(a5)
ffffffffc02043b2:	f114                	sd	a3,32(a0)
ffffffffc02043b4:	6798                	ld	a4,8(a5)
ffffffffc02043b6:	ed1c                	sd	a5,24(a0)
ffffffffc02043b8:	00d70663          	beq	a4,a3,ffffffffc02043c4 <default_init_memmap+0x9a>
ffffffffc02043bc:	8832                	mv	a6,a2
ffffffffc02043be:	4585                	li	a1,1
ffffffffc02043c0:	87ba                	mv	a5,a4
ffffffffc02043c2:	bfc1                	j	ffffffffc0204392 <default_init_memmap+0x68>
ffffffffc02043c4:	60a2                	ld	ra,8(sp)
ffffffffc02043c6:	e290                	sd	a2,0(a3)
ffffffffc02043c8:	0141                	addi	sp,sp,16
ffffffffc02043ca:	8082                	ret
ffffffffc02043cc:	60a2                	ld	ra,8(sp)
ffffffffc02043ce:	e390                	sd	a2,0(a5)
ffffffffc02043d0:	e790                	sd	a2,8(a5)
ffffffffc02043d2:	f11c                	sd	a5,32(a0)
ffffffffc02043d4:	ed1c                	sd	a5,24(a0)
ffffffffc02043d6:	0141                	addi	sp,sp,16
ffffffffc02043d8:	8082                	ret
ffffffffc02043da:	00009697          	auipc	a3,0x9
ffffffffc02043de:	bf668693          	addi	a3,a3,-1034 # ffffffffc020cfd0 <commands+0x16f8>
ffffffffc02043e2:	00007617          	auipc	a2,0x7
ffffffffc02043e6:	74660613          	addi	a2,a2,1862 # ffffffffc020bb28 <commands+0x250>
ffffffffc02043ea:	04800593          	li	a1,72
ffffffffc02043ee:	00009517          	auipc	a0,0x9
ffffffffc02043f2:	87250513          	addi	a0,a0,-1934 # ffffffffc020cc60 <commands+0x1388>
ffffffffc02043f6:	e39fb0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02043fa:	00009697          	auipc	a3,0x9
ffffffffc02043fe:	ba668693          	addi	a3,a3,-1114 # ffffffffc020cfa0 <commands+0x16c8>
ffffffffc0204402:	00007617          	auipc	a2,0x7
ffffffffc0204406:	72660613          	addi	a2,a2,1830 # ffffffffc020bb28 <commands+0x250>
ffffffffc020440a:	04500593          	li	a1,69
ffffffffc020440e:	00009517          	auipc	a0,0x9
ffffffffc0204412:	85250513          	addi	a0,a0,-1966 # ffffffffc020cc60 <commands+0x1388>
ffffffffc0204416:	e19fb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020441a <wait_queue_init>:
ffffffffc020441a:	e508                	sd	a0,8(a0)
ffffffffc020441c:	e108                	sd	a0,0(a0)
ffffffffc020441e:	8082                	ret

ffffffffc0204420 <wait_queue_del>:
ffffffffc0204420:	7198                	ld	a4,32(a1)
ffffffffc0204422:	01858793          	addi	a5,a1,24
ffffffffc0204426:	00e78b63          	beq	a5,a4,ffffffffc020443c <wait_queue_del+0x1c>
ffffffffc020442a:	6994                	ld	a3,16(a1)
ffffffffc020442c:	00a69863          	bne	a3,a0,ffffffffc020443c <wait_queue_del+0x1c>
ffffffffc0204430:	6d94                	ld	a3,24(a1)
ffffffffc0204432:	e698                	sd	a4,8(a3)
ffffffffc0204434:	e314                	sd	a3,0(a4)
ffffffffc0204436:	f19c                	sd	a5,32(a1)
ffffffffc0204438:	ed9c                	sd	a5,24(a1)
ffffffffc020443a:	8082                	ret
ffffffffc020443c:	1141                	addi	sp,sp,-16
ffffffffc020443e:	00009697          	auipc	a3,0x9
ffffffffc0204442:	c4268693          	addi	a3,a3,-958 # ffffffffc020d080 <default_pmm_manager+0x88>
ffffffffc0204446:	00007617          	auipc	a2,0x7
ffffffffc020444a:	6e260613          	addi	a2,a2,1762 # ffffffffc020bb28 <commands+0x250>
ffffffffc020444e:	45f1                	li	a1,28
ffffffffc0204450:	00009517          	auipc	a0,0x9
ffffffffc0204454:	c1850513          	addi	a0,a0,-1000 # ffffffffc020d068 <default_pmm_manager+0x70>
ffffffffc0204458:	e406                	sd	ra,8(sp)
ffffffffc020445a:	dd5fb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020445e <wait_queue_first>:
ffffffffc020445e:	651c                	ld	a5,8(a0)
ffffffffc0204460:	00f50563          	beq	a0,a5,ffffffffc020446a <wait_queue_first+0xc>
ffffffffc0204464:	fe878513          	addi	a0,a5,-24
ffffffffc0204468:	8082                	ret
ffffffffc020446a:	4501                	li	a0,0
ffffffffc020446c:	8082                	ret

ffffffffc020446e <wait_queue_empty>:
ffffffffc020446e:	651c                	ld	a5,8(a0)
ffffffffc0204470:	40a78533          	sub	a0,a5,a0
ffffffffc0204474:	00153513          	seqz	a0,a0
ffffffffc0204478:	8082                	ret

ffffffffc020447a <wait_in_queue>:
ffffffffc020447a:	711c                	ld	a5,32(a0)
ffffffffc020447c:	0561                	addi	a0,a0,24
ffffffffc020447e:	40a78533          	sub	a0,a5,a0
ffffffffc0204482:	00a03533          	snez	a0,a0
ffffffffc0204486:	8082                	ret

ffffffffc0204488 <wakeup_wait>:
ffffffffc0204488:	e689                	bnez	a3,ffffffffc0204492 <wakeup_wait+0xa>
ffffffffc020448a:	6188                	ld	a0,0(a1)
ffffffffc020448c:	c590                	sw	a2,8(a1)
ffffffffc020448e:	6290206f          	j	ffffffffc02072b6 <wakeup_proc>
ffffffffc0204492:	7198                	ld	a4,32(a1)
ffffffffc0204494:	01858793          	addi	a5,a1,24
ffffffffc0204498:	00e78e63          	beq	a5,a4,ffffffffc02044b4 <wakeup_wait+0x2c>
ffffffffc020449c:	6994                	ld	a3,16(a1)
ffffffffc020449e:	00d51b63          	bne	a0,a3,ffffffffc02044b4 <wakeup_wait+0x2c>
ffffffffc02044a2:	6d94                	ld	a3,24(a1)
ffffffffc02044a4:	6188                	ld	a0,0(a1)
ffffffffc02044a6:	e698                	sd	a4,8(a3)
ffffffffc02044a8:	e314                	sd	a3,0(a4)
ffffffffc02044aa:	f19c                	sd	a5,32(a1)
ffffffffc02044ac:	ed9c                	sd	a5,24(a1)
ffffffffc02044ae:	c590                	sw	a2,8(a1)
ffffffffc02044b0:	6070206f          	j	ffffffffc02072b6 <wakeup_proc>
ffffffffc02044b4:	1141                	addi	sp,sp,-16
ffffffffc02044b6:	00009697          	auipc	a3,0x9
ffffffffc02044ba:	bca68693          	addi	a3,a3,-1078 # ffffffffc020d080 <default_pmm_manager+0x88>
ffffffffc02044be:	00007617          	auipc	a2,0x7
ffffffffc02044c2:	66a60613          	addi	a2,a2,1642 # ffffffffc020bb28 <commands+0x250>
ffffffffc02044c6:	45f1                	li	a1,28
ffffffffc02044c8:	00009517          	auipc	a0,0x9
ffffffffc02044cc:	ba050513          	addi	a0,a0,-1120 # ffffffffc020d068 <default_pmm_manager+0x70>
ffffffffc02044d0:	e406                	sd	ra,8(sp)
ffffffffc02044d2:	d5dfb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02044d6 <wakeup_queue>:
ffffffffc02044d6:	651c                	ld	a5,8(a0)
ffffffffc02044d8:	0ca78563          	beq	a5,a0,ffffffffc02045a2 <wakeup_queue+0xcc>
ffffffffc02044dc:	1101                	addi	sp,sp,-32
ffffffffc02044de:	e822                	sd	s0,16(sp)
ffffffffc02044e0:	e426                	sd	s1,8(sp)
ffffffffc02044e2:	e04a                	sd	s2,0(sp)
ffffffffc02044e4:	ec06                	sd	ra,24(sp)
ffffffffc02044e6:	84aa                	mv	s1,a0
ffffffffc02044e8:	892e                	mv	s2,a1
ffffffffc02044ea:	fe878413          	addi	s0,a5,-24
ffffffffc02044ee:	e23d                	bnez	a2,ffffffffc0204554 <wakeup_queue+0x7e>
ffffffffc02044f0:	6008                	ld	a0,0(s0)
ffffffffc02044f2:	01242423          	sw	s2,8(s0)
ffffffffc02044f6:	5c1020ef          	jal	ra,ffffffffc02072b6 <wakeup_proc>
ffffffffc02044fa:	701c                	ld	a5,32(s0)
ffffffffc02044fc:	01840713          	addi	a4,s0,24
ffffffffc0204500:	02e78463          	beq	a5,a4,ffffffffc0204528 <wakeup_queue+0x52>
ffffffffc0204504:	6818                	ld	a4,16(s0)
ffffffffc0204506:	02e49163          	bne	s1,a4,ffffffffc0204528 <wakeup_queue+0x52>
ffffffffc020450a:	02f48f63          	beq	s1,a5,ffffffffc0204548 <wakeup_queue+0x72>
ffffffffc020450e:	fe87b503          	ld	a0,-24(a5)
ffffffffc0204512:	ff27a823          	sw	s2,-16(a5)
ffffffffc0204516:	fe878413          	addi	s0,a5,-24
ffffffffc020451a:	59d020ef          	jal	ra,ffffffffc02072b6 <wakeup_proc>
ffffffffc020451e:	701c                	ld	a5,32(s0)
ffffffffc0204520:	01840713          	addi	a4,s0,24
ffffffffc0204524:	fee790e3          	bne	a5,a4,ffffffffc0204504 <wakeup_queue+0x2e>
ffffffffc0204528:	00009697          	auipc	a3,0x9
ffffffffc020452c:	b5868693          	addi	a3,a3,-1192 # ffffffffc020d080 <default_pmm_manager+0x88>
ffffffffc0204530:	00007617          	auipc	a2,0x7
ffffffffc0204534:	5f860613          	addi	a2,a2,1528 # ffffffffc020bb28 <commands+0x250>
ffffffffc0204538:	02200593          	li	a1,34
ffffffffc020453c:	00009517          	auipc	a0,0x9
ffffffffc0204540:	b2c50513          	addi	a0,a0,-1236 # ffffffffc020d068 <default_pmm_manager+0x70>
ffffffffc0204544:	cebfb0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0204548:	60e2                	ld	ra,24(sp)
ffffffffc020454a:	6442                	ld	s0,16(sp)
ffffffffc020454c:	64a2                	ld	s1,8(sp)
ffffffffc020454e:	6902                	ld	s2,0(sp)
ffffffffc0204550:	6105                	addi	sp,sp,32
ffffffffc0204552:	8082                	ret
ffffffffc0204554:	6798                	ld	a4,8(a5)
ffffffffc0204556:	02f70763          	beq	a4,a5,ffffffffc0204584 <wakeup_queue+0xae>
ffffffffc020455a:	6814                	ld	a3,16(s0)
ffffffffc020455c:	02d49463          	bne	s1,a3,ffffffffc0204584 <wakeup_queue+0xae>
ffffffffc0204560:	6c14                	ld	a3,24(s0)
ffffffffc0204562:	6008                	ld	a0,0(s0)
ffffffffc0204564:	e698                	sd	a4,8(a3)
ffffffffc0204566:	e314                	sd	a3,0(a4)
ffffffffc0204568:	f01c                	sd	a5,32(s0)
ffffffffc020456a:	ec1c                	sd	a5,24(s0)
ffffffffc020456c:	01242423          	sw	s2,8(s0)
ffffffffc0204570:	547020ef          	jal	ra,ffffffffc02072b6 <wakeup_proc>
ffffffffc0204574:	6480                	ld	s0,8(s1)
ffffffffc0204576:	fc8489e3          	beq	s1,s0,ffffffffc0204548 <wakeup_queue+0x72>
ffffffffc020457a:	6418                	ld	a4,8(s0)
ffffffffc020457c:	87a2                	mv	a5,s0
ffffffffc020457e:	1421                	addi	s0,s0,-24
ffffffffc0204580:	fce79de3          	bne	a5,a4,ffffffffc020455a <wakeup_queue+0x84>
ffffffffc0204584:	00009697          	auipc	a3,0x9
ffffffffc0204588:	afc68693          	addi	a3,a3,-1284 # ffffffffc020d080 <default_pmm_manager+0x88>
ffffffffc020458c:	00007617          	auipc	a2,0x7
ffffffffc0204590:	59c60613          	addi	a2,a2,1436 # ffffffffc020bb28 <commands+0x250>
ffffffffc0204594:	45f1                	li	a1,28
ffffffffc0204596:	00009517          	auipc	a0,0x9
ffffffffc020459a:	ad250513          	addi	a0,a0,-1326 # ffffffffc020d068 <default_pmm_manager+0x70>
ffffffffc020459e:	c91fb0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02045a2:	8082                	ret

ffffffffc02045a4 <wait_current_set>:
ffffffffc02045a4:	00092797          	auipc	a5,0x92
ffffffffc02045a8:	31c7b783          	ld	a5,796(a5) # ffffffffc02968c0 <current>
ffffffffc02045ac:	c39d                	beqz	a5,ffffffffc02045d2 <wait_current_set+0x2e>
ffffffffc02045ae:	01858713          	addi	a4,a1,24
ffffffffc02045b2:	800006b7          	lui	a3,0x80000
ffffffffc02045b6:	ed98                	sd	a4,24(a1)
ffffffffc02045b8:	e19c                	sd	a5,0(a1)
ffffffffc02045ba:	c594                	sw	a3,8(a1)
ffffffffc02045bc:	4685                	li	a3,1
ffffffffc02045be:	c394                	sw	a3,0(a5)
ffffffffc02045c0:	0ec7a623          	sw	a2,236(a5)
ffffffffc02045c4:	611c                	ld	a5,0(a0)
ffffffffc02045c6:	e988                	sd	a0,16(a1)
ffffffffc02045c8:	e118                	sd	a4,0(a0)
ffffffffc02045ca:	e798                	sd	a4,8(a5)
ffffffffc02045cc:	f188                	sd	a0,32(a1)
ffffffffc02045ce:	ed9c                	sd	a5,24(a1)
ffffffffc02045d0:	8082                	ret
ffffffffc02045d2:	1141                	addi	sp,sp,-16
ffffffffc02045d4:	00009697          	auipc	a3,0x9
ffffffffc02045d8:	aec68693          	addi	a3,a3,-1300 # ffffffffc020d0c0 <default_pmm_manager+0xc8>
ffffffffc02045dc:	00007617          	auipc	a2,0x7
ffffffffc02045e0:	54c60613          	addi	a2,a2,1356 # ffffffffc020bb28 <commands+0x250>
ffffffffc02045e4:	07400593          	li	a1,116
ffffffffc02045e8:	00009517          	auipc	a0,0x9
ffffffffc02045ec:	a8050513          	addi	a0,a0,-1408 # ffffffffc020d068 <default_pmm_manager+0x70>
ffffffffc02045f0:	e406                	sd	ra,8(sp)
ffffffffc02045f2:	c3dfb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02045f6 <__down.constprop.0>:
ffffffffc02045f6:	715d                	addi	sp,sp,-80
ffffffffc02045f8:	e0a2                	sd	s0,64(sp)
ffffffffc02045fa:	e486                	sd	ra,72(sp)
ffffffffc02045fc:	fc26                	sd	s1,56(sp)
ffffffffc02045fe:	842a                	mv	s0,a0
ffffffffc0204600:	100027f3          	csrr	a5,sstatus
ffffffffc0204604:	8b89                	andi	a5,a5,2
ffffffffc0204606:	ebb1                	bnez	a5,ffffffffc020465a <__down.constprop.0+0x64>
ffffffffc0204608:	411c                	lw	a5,0(a0)
ffffffffc020460a:	00f05a63          	blez	a5,ffffffffc020461e <__down.constprop.0+0x28>
ffffffffc020460e:	37fd                	addiw	a5,a5,-1
ffffffffc0204610:	c11c                	sw	a5,0(a0)
ffffffffc0204612:	4501                	li	a0,0
ffffffffc0204614:	60a6                	ld	ra,72(sp)
ffffffffc0204616:	6406                	ld	s0,64(sp)
ffffffffc0204618:	74e2                	ld	s1,56(sp)
ffffffffc020461a:	6161                	addi	sp,sp,80
ffffffffc020461c:	8082                	ret
ffffffffc020461e:	00850413          	addi	s0,a0,8
ffffffffc0204622:	0024                	addi	s1,sp,8
ffffffffc0204624:	10000613          	li	a2,256
ffffffffc0204628:	85a6                	mv	a1,s1
ffffffffc020462a:	8522                	mv	a0,s0
ffffffffc020462c:	f79ff0ef          	jal	ra,ffffffffc02045a4 <wait_current_set>
ffffffffc0204630:	539020ef          	jal	ra,ffffffffc0207368 <schedule>
ffffffffc0204634:	100027f3          	csrr	a5,sstatus
ffffffffc0204638:	8b89                	andi	a5,a5,2
ffffffffc020463a:	efb9                	bnez	a5,ffffffffc0204698 <__down.constprop.0+0xa2>
ffffffffc020463c:	8526                	mv	a0,s1
ffffffffc020463e:	e3dff0ef          	jal	ra,ffffffffc020447a <wait_in_queue>
ffffffffc0204642:	e531                	bnez	a0,ffffffffc020468e <__down.constprop.0+0x98>
ffffffffc0204644:	4542                	lw	a0,16(sp)
ffffffffc0204646:	10000793          	li	a5,256
ffffffffc020464a:	fcf515e3          	bne	a0,a5,ffffffffc0204614 <__down.constprop.0+0x1e>
ffffffffc020464e:	60a6                	ld	ra,72(sp)
ffffffffc0204650:	6406                	ld	s0,64(sp)
ffffffffc0204652:	74e2                	ld	s1,56(sp)
ffffffffc0204654:	4501                	li	a0,0
ffffffffc0204656:	6161                	addi	sp,sp,80
ffffffffc0204658:	8082                	ret
ffffffffc020465a:	f46fc0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc020465e:	401c                	lw	a5,0(s0)
ffffffffc0204660:	00f05c63          	blez	a5,ffffffffc0204678 <__down.constprop.0+0x82>
ffffffffc0204664:	37fd                	addiw	a5,a5,-1
ffffffffc0204666:	c01c                	sw	a5,0(s0)
ffffffffc0204668:	f32fc0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc020466c:	60a6                	ld	ra,72(sp)
ffffffffc020466e:	6406                	ld	s0,64(sp)
ffffffffc0204670:	74e2                	ld	s1,56(sp)
ffffffffc0204672:	4501                	li	a0,0
ffffffffc0204674:	6161                	addi	sp,sp,80
ffffffffc0204676:	8082                	ret
ffffffffc0204678:	0421                	addi	s0,s0,8
ffffffffc020467a:	0024                	addi	s1,sp,8
ffffffffc020467c:	10000613          	li	a2,256
ffffffffc0204680:	85a6                	mv	a1,s1
ffffffffc0204682:	8522                	mv	a0,s0
ffffffffc0204684:	f21ff0ef          	jal	ra,ffffffffc02045a4 <wait_current_set>
ffffffffc0204688:	f12fc0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc020468c:	b755                	j	ffffffffc0204630 <__down.constprop.0+0x3a>
ffffffffc020468e:	85a6                	mv	a1,s1
ffffffffc0204690:	8522                	mv	a0,s0
ffffffffc0204692:	d8fff0ef          	jal	ra,ffffffffc0204420 <wait_queue_del>
ffffffffc0204696:	b77d                	j	ffffffffc0204644 <__down.constprop.0+0x4e>
ffffffffc0204698:	f08fc0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc020469c:	8526                	mv	a0,s1
ffffffffc020469e:	dddff0ef          	jal	ra,ffffffffc020447a <wait_in_queue>
ffffffffc02046a2:	e501                	bnez	a0,ffffffffc02046aa <__down.constprop.0+0xb4>
ffffffffc02046a4:	ef6fc0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc02046a8:	bf71                	j	ffffffffc0204644 <__down.constprop.0+0x4e>
ffffffffc02046aa:	85a6                	mv	a1,s1
ffffffffc02046ac:	8522                	mv	a0,s0
ffffffffc02046ae:	d73ff0ef          	jal	ra,ffffffffc0204420 <wait_queue_del>
ffffffffc02046b2:	bfcd                	j	ffffffffc02046a4 <__down.constprop.0+0xae>

ffffffffc02046b4 <__up.constprop.0>:
ffffffffc02046b4:	1101                	addi	sp,sp,-32
ffffffffc02046b6:	e822                	sd	s0,16(sp)
ffffffffc02046b8:	ec06                	sd	ra,24(sp)
ffffffffc02046ba:	e426                	sd	s1,8(sp)
ffffffffc02046bc:	e04a                	sd	s2,0(sp)
ffffffffc02046be:	842a                	mv	s0,a0
ffffffffc02046c0:	100027f3          	csrr	a5,sstatus
ffffffffc02046c4:	8b89                	andi	a5,a5,2
ffffffffc02046c6:	4901                	li	s2,0
ffffffffc02046c8:	eba1                	bnez	a5,ffffffffc0204718 <__up.constprop.0+0x64>
ffffffffc02046ca:	00840493          	addi	s1,s0,8
ffffffffc02046ce:	8526                	mv	a0,s1
ffffffffc02046d0:	d8fff0ef          	jal	ra,ffffffffc020445e <wait_queue_first>
ffffffffc02046d4:	85aa                	mv	a1,a0
ffffffffc02046d6:	cd0d                	beqz	a0,ffffffffc0204710 <__up.constprop.0+0x5c>
ffffffffc02046d8:	6118                	ld	a4,0(a0)
ffffffffc02046da:	10000793          	li	a5,256
ffffffffc02046de:	0ec72703          	lw	a4,236(a4)
ffffffffc02046e2:	02f71f63          	bne	a4,a5,ffffffffc0204720 <__up.constprop.0+0x6c>
ffffffffc02046e6:	4685                	li	a3,1
ffffffffc02046e8:	10000613          	li	a2,256
ffffffffc02046ec:	8526                	mv	a0,s1
ffffffffc02046ee:	d9bff0ef          	jal	ra,ffffffffc0204488 <wakeup_wait>
ffffffffc02046f2:	00091863          	bnez	s2,ffffffffc0204702 <__up.constprop.0+0x4e>
ffffffffc02046f6:	60e2                	ld	ra,24(sp)
ffffffffc02046f8:	6442                	ld	s0,16(sp)
ffffffffc02046fa:	64a2                	ld	s1,8(sp)
ffffffffc02046fc:	6902                	ld	s2,0(sp)
ffffffffc02046fe:	6105                	addi	sp,sp,32
ffffffffc0204700:	8082                	ret
ffffffffc0204702:	6442                	ld	s0,16(sp)
ffffffffc0204704:	60e2                	ld	ra,24(sp)
ffffffffc0204706:	64a2                	ld	s1,8(sp)
ffffffffc0204708:	6902                	ld	s2,0(sp)
ffffffffc020470a:	6105                	addi	sp,sp,32
ffffffffc020470c:	e8efc06f          	j	ffffffffc0200d9a <intr_enable>
ffffffffc0204710:	401c                	lw	a5,0(s0)
ffffffffc0204712:	2785                	addiw	a5,a5,1
ffffffffc0204714:	c01c                	sw	a5,0(s0)
ffffffffc0204716:	bff1                	j	ffffffffc02046f2 <__up.constprop.0+0x3e>
ffffffffc0204718:	e88fc0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc020471c:	4905                	li	s2,1
ffffffffc020471e:	b775                	j	ffffffffc02046ca <__up.constprop.0+0x16>
ffffffffc0204720:	00009697          	auipc	a3,0x9
ffffffffc0204724:	9b068693          	addi	a3,a3,-1616 # ffffffffc020d0d0 <default_pmm_manager+0xd8>
ffffffffc0204728:	00007617          	auipc	a2,0x7
ffffffffc020472c:	40060613          	addi	a2,a2,1024 # ffffffffc020bb28 <commands+0x250>
ffffffffc0204730:	45e5                	li	a1,25
ffffffffc0204732:	00009517          	auipc	a0,0x9
ffffffffc0204736:	9c650513          	addi	a0,a0,-1594 # ffffffffc020d0f8 <default_pmm_manager+0x100>
ffffffffc020473a:	af5fb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020473e <sem_init>:
ffffffffc020473e:	c10c                	sw	a1,0(a0)
ffffffffc0204740:	0521                	addi	a0,a0,8
ffffffffc0204742:	cd9ff06f          	j	ffffffffc020441a <wait_queue_init>

ffffffffc0204746 <up>:
ffffffffc0204746:	f6fff06f          	j	ffffffffc02046b4 <__up.constprop.0>

ffffffffc020474a <down>:
ffffffffc020474a:	1141                	addi	sp,sp,-16
ffffffffc020474c:	e406                	sd	ra,8(sp)
ffffffffc020474e:	ea9ff0ef          	jal	ra,ffffffffc02045f6 <__down.constprop.0>
ffffffffc0204752:	2501                	sext.w	a0,a0
ffffffffc0204754:	e501                	bnez	a0,ffffffffc020475c <down+0x12>
ffffffffc0204756:	60a2                	ld	ra,8(sp)
ffffffffc0204758:	0141                	addi	sp,sp,16
ffffffffc020475a:	8082                	ret
ffffffffc020475c:	00009697          	auipc	a3,0x9
ffffffffc0204760:	9ac68693          	addi	a3,a3,-1620 # ffffffffc020d108 <default_pmm_manager+0x110>
ffffffffc0204764:	00007617          	auipc	a2,0x7
ffffffffc0204768:	3c460613          	addi	a2,a2,964 # ffffffffc020bb28 <commands+0x250>
ffffffffc020476c:	04000593          	li	a1,64
ffffffffc0204770:	00009517          	auipc	a0,0x9
ffffffffc0204774:	98850513          	addi	a0,a0,-1656 # ffffffffc020d0f8 <default_pmm_manager+0x100>
ffffffffc0204778:	ab7fb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020477c <copy_path>:
ffffffffc020477c:	7139                	addi	sp,sp,-64
ffffffffc020477e:	f04a                	sd	s2,32(sp)
ffffffffc0204780:	00092917          	auipc	s2,0x92
ffffffffc0204784:	14090913          	addi	s2,s2,320 # ffffffffc02968c0 <current>
ffffffffc0204788:	00093703          	ld	a4,0(s2)
ffffffffc020478c:	ec4e                	sd	s3,24(sp)
ffffffffc020478e:	89aa                	mv	s3,a0
ffffffffc0204790:	6505                	lui	a0,0x1
ffffffffc0204792:	f426                	sd	s1,40(sp)
ffffffffc0204794:	e852                	sd	s4,16(sp)
ffffffffc0204796:	fc06                	sd	ra,56(sp)
ffffffffc0204798:	f822                	sd	s0,48(sp)
ffffffffc020479a:	e456                	sd	s5,8(sp)
ffffffffc020479c:	02873a03          	ld	s4,40(a4)
ffffffffc02047a0:	84ae                	mv	s1,a1
ffffffffc02047a2:	820ff0ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc02047a6:	c141                	beqz	a0,ffffffffc0204826 <copy_path+0xaa>
ffffffffc02047a8:	842a                	mv	s0,a0
ffffffffc02047aa:	040a0563          	beqz	s4,ffffffffc02047f4 <copy_path+0x78>
ffffffffc02047ae:	038a0a93          	addi	s5,s4,56
ffffffffc02047b2:	8556                	mv	a0,s5
ffffffffc02047b4:	f97ff0ef          	jal	ra,ffffffffc020474a <down>
ffffffffc02047b8:	00093783          	ld	a5,0(s2)
ffffffffc02047bc:	cba1                	beqz	a5,ffffffffc020480c <copy_path+0x90>
ffffffffc02047be:	43dc                	lw	a5,4(a5)
ffffffffc02047c0:	6685                	lui	a3,0x1
ffffffffc02047c2:	8626                	mv	a2,s1
ffffffffc02047c4:	04fa2823          	sw	a5,80(s4)
ffffffffc02047c8:	85a2                	mv	a1,s0
ffffffffc02047ca:	8552                	mv	a0,s4
ffffffffc02047cc:	d3ffe0ef          	jal	ra,ffffffffc020350a <copy_string>
ffffffffc02047d0:	c529                	beqz	a0,ffffffffc020481a <copy_path+0x9e>
ffffffffc02047d2:	8556                	mv	a0,s5
ffffffffc02047d4:	f73ff0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc02047d8:	040a2823          	sw	zero,80(s4)
ffffffffc02047dc:	0089b023          	sd	s0,0(s3)
ffffffffc02047e0:	4501                	li	a0,0
ffffffffc02047e2:	70e2                	ld	ra,56(sp)
ffffffffc02047e4:	7442                	ld	s0,48(sp)
ffffffffc02047e6:	74a2                	ld	s1,40(sp)
ffffffffc02047e8:	7902                	ld	s2,32(sp)
ffffffffc02047ea:	69e2                	ld	s3,24(sp)
ffffffffc02047ec:	6a42                	ld	s4,16(sp)
ffffffffc02047ee:	6aa2                	ld	s5,8(sp)
ffffffffc02047f0:	6121                	addi	sp,sp,64
ffffffffc02047f2:	8082                	ret
ffffffffc02047f4:	85aa                	mv	a1,a0
ffffffffc02047f6:	6685                	lui	a3,0x1
ffffffffc02047f8:	8626                	mv	a2,s1
ffffffffc02047fa:	4501                	li	a0,0
ffffffffc02047fc:	d0ffe0ef          	jal	ra,ffffffffc020350a <copy_string>
ffffffffc0204800:	fd71                	bnez	a0,ffffffffc02047dc <copy_path+0x60>
ffffffffc0204802:	8522                	mv	a0,s0
ffffffffc0204804:	86eff0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc0204808:	5575                	li	a0,-3
ffffffffc020480a:	bfe1                	j	ffffffffc02047e2 <copy_path+0x66>
ffffffffc020480c:	6685                	lui	a3,0x1
ffffffffc020480e:	8626                	mv	a2,s1
ffffffffc0204810:	85a2                	mv	a1,s0
ffffffffc0204812:	8552                	mv	a0,s4
ffffffffc0204814:	cf7fe0ef          	jal	ra,ffffffffc020350a <copy_string>
ffffffffc0204818:	fd4d                	bnez	a0,ffffffffc02047d2 <copy_path+0x56>
ffffffffc020481a:	8556                	mv	a0,s5
ffffffffc020481c:	f2bff0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc0204820:	040a2823          	sw	zero,80(s4)
ffffffffc0204824:	bff9                	j	ffffffffc0204802 <copy_path+0x86>
ffffffffc0204826:	5571                	li	a0,-4
ffffffffc0204828:	bf6d                	j	ffffffffc02047e2 <copy_path+0x66>

ffffffffc020482a <sysfile_open>:
ffffffffc020482a:	7179                	addi	sp,sp,-48
ffffffffc020482c:	872a                	mv	a4,a0
ffffffffc020482e:	ec26                	sd	s1,24(sp)
ffffffffc0204830:	0028                	addi	a0,sp,8
ffffffffc0204832:	84ae                	mv	s1,a1
ffffffffc0204834:	85ba                	mv	a1,a4
ffffffffc0204836:	f022                	sd	s0,32(sp)
ffffffffc0204838:	f406                	sd	ra,40(sp)
ffffffffc020483a:	f43ff0ef          	jal	ra,ffffffffc020477c <copy_path>
ffffffffc020483e:	842a                	mv	s0,a0
ffffffffc0204840:	e909                	bnez	a0,ffffffffc0204852 <sysfile_open+0x28>
ffffffffc0204842:	6522                	ld	a0,8(sp)
ffffffffc0204844:	85a6                	mv	a1,s1
ffffffffc0204846:	7ba000ef          	jal	ra,ffffffffc0205000 <file_open>
ffffffffc020484a:	842a                	mv	s0,a0
ffffffffc020484c:	6522                	ld	a0,8(sp)
ffffffffc020484e:	824ff0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc0204852:	70a2                	ld	ra,40(sp)
ffffffffc0204854:	8522                	mv	a0,s0
ffffffffc0204856:	7402                	ld	s0,32(sp)
ffffffffc0204858:	64e2                	ld	s1,24(sp)
ffffffffc020485a:	6145                	addi	sp,sp,48
ffffffffc020485c:	8082                	ret

ffffffffc020485e <sysfile_close>:
ffffffffc020485e:	0a10006f          	j	ffffffffc02050fe <file_close>

ffffffffc0204862 <sysfile_read>:
ffffffffc0204862:	7159                	addi	sp,sp,-112
ffffffffc0204864:	f0a2                	sd	s0,96(sp)
ffffffffc0204866:	f486                	sd	ra,104(sp)
ffffffffc0204868:	eca6                	sd	s1,88(sp)
ffffffffc020486a:	e8ca                	sd	s2,80(sp)
ffffffffc020486c:	e4ce                	sd	s3,72(sp)
ffffffffc020486e:	e0d2                	sd	s4,64(sp)
ffffffffc0204870:	fc56                	sd	s5,56(sp)
ffffffffc0204872:	f85a                	sd	s6,48(sp)
ffffffffc0204874:	f45e                	sd	s7,40(sp)
ffffffffc0204876:	f062                	sd	s8,32(sp)
ffffffffc0204878:	ec66                	sd	s9,24(sp)
ffffffffc020487a:	4401                	li	s0,0
ffffffffc020487c:	ee19                	bnez	a2,ffffffffc020489a <sysfile_read+0x38>
ffffffffc020487e:	70a6                	ld	ra,104(sp)
ffffffffc0204880:	8522                	mv	a0,s0
ffffffffc0204882:	7406                	ld	s0,96(sp)
ffffffffc0204884:	64e6                	ld	s1,88(sp)
ffffffffc0204886:	6946                	ld	s2,80(sp)
ffffffffc0204888:	69a6                	ld	s3,72(sp)
ffffffffc020488a:	6a06                	ld	s4,64(sp)
ffffffffc020488c:	7ae2                	ld	s5,56(sp)
ffffffffc020488e:	7b42                	ld	s6,48(sp)
ffffffffc0204890:	7ba2                	ld	s7,40(sp)
ffffffffc0204892:	7c02                	ld	s8,32(sp)
ffffffffc0204894:	6ce2                	ld	s9,24(sp)
ffffffffc0204896:	6165                	addi	sp,sp,112
ffffffffc0204898:	8082                	ret
ffffffffc020489a:	00092c97          	auipc	s9,0x92
ffffffffc020489e:	026c8c93          	addi	s9,s9,38 # ffffffffc02968c0 <current>
ffffffffc02048a2:	000cb783          	ld	a5,0(s9)
ffffffffc02048a6:	84b2                	mv	s1,a2
ffffffffc02048a8:	8b2e                	mv	s6,a1
ffffffffc02048aa:	4601                	li	a2,0
ffffffffc02048ac:	4585                	li	a1,1
ffffffffc02048ae:	0287b903          	ld	s2,40(a5)
ffffffffc02048b2:	8aaa                	mv	s5,a0
ffffffffc02048b4:	6f8000ef          	jal	ra,ffffffffc0204fac <file_testfd>
ffffffffc02048b8:	c959                	beqz	a0,ffffffffc020494e <sysfile_read+0xec>
ffffffffc02048ba:	6505                	lui	a0,0x1
ffffffffc02048bc:	f07fe0ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc02048c0:	89aa                	mv	s3,a0
ffffffffc02048c2:	c941                	beqz	a0,ffffffffc0204952 <sysfile_read+0xf0>
ffffffffc02048c4:	4b81                	li	s7,0
ffffffffc02048c6:	6a05                	lui	s4,0x1
ffffffffc02048c8:	03890c13          	addi	s8,s2,56
ffffffffc02048cc:	0744ec63          	bltu	s1,s4,ffffffffc0204944 <sysfile_read+0xe2>
ffffffffc02048d0:	e452                	sd	s4,8(sp)
ffffffffc02048d2:	6605                	lui	a2,0x1
ffffffffc02048d4:	0034                	addi	a3,sp,8
ffffffffc02048d6:	85ce                	mv	a1,s3
ffffffffc02048d8:	8556                	mv	a0,s5
ffffffffc02048da:	07b000ef          	jal	ra,ffffffffc0205154 <file_read>
ffffffffc02048de:	66a2                	ld	a3,8(sp)
ffffffffc02048e0:	842a                	mv	s0,a0
ffffffffc02048e2:	ca9d                	beqz	a3,ffffffffc0204918 <sysfile_read+0xb6>
ffffffffc02048e4:	00090c63          	beqz	s2,ffffffffc02048fc <sysfile_read+0x9a>
ffffffffc02048e8:	8562                	mv	a0,s8
ffffffffc02048ea:	e61ff0ef          	jal	ra,ffffffffc020474a <down>
ffffffffc02048ee:	000cb783          	ld	a5,0(s9)
ffffffffc02048f2:	cfa1                	beqz	a5,ffffffffc020494a <sysfile_read+0xe8>
ffffffffc02048f4:	43dc                	lw	a5,4(a5)
ffffffffc02048f6:	66a2                	ld	a3,8(sp)
ffffffffc02048f8:	04f92823          	sw	a5,80(s2)
ffffffffc02048fc:	864e                	mv	a2,s3
ffffffffc02048fe:	85da                	mv	a1,s6
ffffffffc0204900:	854a                	mv	a0,s2
ffffffffc0204902:	bd7fe0ef          	jal	ra,ffffffffc02034d8 <copy_to_user>
ffffffffc0204906:	c50d                	beqz	a0,ffffffffc0204930 <sysfile_read+0xce>
ffffffffc0204908:	67a2                	ld	a5,8(sp)
ffffffffc020490a:	04f4e663          	bltu	s1,a5,ffffffffc0204956 <sysfile_read+0xf4>
ffffffffc020490e:	9b3e                	add	s6,s6,a5
ffffffffc0204910:	8c9d                	sub	s1,s1,a5
ffffffffc0204912:	9bbe                	add	s7,s7,a5
ffffffffc0204914:	02091263          	bnez	s2,ffffffffc0204938 <sysfile_read+0xd6>
ffffffffc0204918:	e401                	bnez	s0,ffffffffc0204920 <sysfile_read+0xbe>
ffffffffc020491a:	67a2                	ld	a5,8(sp)
ffffffffc020491c:	c391                	beqz	a5,ffffffffc0204920 <sysfile_read+0xbe>
ffffffffc020491e:	f4dd                	bnez	s1,ffffffffc02048cc <sysfile_read+0x6a>
ffffffffc0204920:	854e                	mv	a0,s3
ffffffffc0204922:	f51fe0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc0204926:	f40b8ce3          	beqz	s7,ffffffffc020487e <sysfile_read+0x1c>
ffffffffc020492a:	000b841b          	sext.w	s0,s7
ffffffffc020492e:	bf81                	j	ffffffffc020487e <sysfile_read+0x1c>
ffffffffc0204930:	e011                	bnez	s0,ffffffffc0204934 <sysfile_read+0xd2>
ffffffffc0204932:	5475                	li	s0,-3
ffffffffc0204934:	fe0906e3          	beqz	s2,ffffffffc0204920 <sysfile_read+0xbe>
ffffffffc0204938:	8562                	mv	a0,s8
ffffffffc020493a:	e0dff0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc020493e:	04092823          	sw	zero,80(s2)
ffffffffc0204942:	bfd9                	j	ffffffffc0204918 <sysfile_read+0xb6>
ffffffffc0204944:	e426                	sd	s1,8(sp)
ffffffffc0204946:	8626                	mv	a2,s1
ffffffffc0204948:	b771                	j	ffffffffc02048d4 <sysfile_read+0x72>
ffffffffc020494a:	66a2                	ld	a3,8(sp)
ffffffffc020494c:	bf45                	j	ffffffffc02048fc <sysfile_read+0x9a>
ffffffffc020494e:	5475                	li	s0,-3
ffffffffc0204950:	b73d                	j	ffffffffc020487e <sysfile_read+0x1c>
ffffffffc0204952:	5471                	li	s0,-4
ffffffffc0204954:	b72d                	j	ffffffffc020487e <sysfile_read+0x1c>
ffffffffc0204956:	00008697          	auipc	a3,0x8
ffffffffc020495a:	7c268693          	addi	a3,a3,1986 # ffffffffc020d118 <default_pmm_manager+0x120>
ffffffffc020495e:	00007617          	auipc	a2,0x7
ffffffffc0204962:	1ca60613          	addi	a2,a2,458 # ffffffffc020bb28 <commands+0x250>
ffffffffc0204966:	05500593          	li	a1,85
ffffffffc020496a:	00008517          	auipc	a0,0x8
ffffffffc020496e:	7be50513          	addi	a0,a0,1982 # ffffffffc020d128 <default_pmm_manager+0x130>
ffffffffc0204972:	8bdfb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0204976 <sysfile_write>:
ffffffffc0204976:	7159                	addi	sp,sp,-112
ffffffffc0204978:	e8ca                	sd	s2,80(sp)
ffffffffc020497a:	f486                	sd	ra,104(sp)
ffffffffc020497c:	f0a2                	sd	s0,96(sp)
ffffffffc020497e:	eca6                	sd	s1,88(sp)
ffffffffc0204980:	e4ce                	sd	s3,72(sp)
ffffffffc0204982:	e0d2                	sd	s4,64(sp)
ffffffffc0204984:	fc56                	sd	s5,56(sp)
ffffffffc0204986:	f85a                	sd	s6,48(sp)
ffffffffc0204988:	f45e                	sd	s7,40(sp)
ffffffffc020498a:	f062                	sd	s8,32(sp)
ffffffffc020498c:	ec66                	sd	s9,24(sp)
ffffffffc020498e:	4901                	li	s2,0
ffffffffc0204990:	ee19                	bnez	a2,ffffffffc02049ae <sysfile_write+0x38>
ffffffffc0204992:	70a6                	ld	ra,104(sp)
ffffffffc0204994:	7406                	ld	s0,96(sp)
ffffffffc0204996:	64e6                	ld	s1,88(sp)
ffffffffc0204998:	69a6                	ld	s3,72(sp)
ffffffffc020499a:	6a06                	ld	s4,64(sp)
ffffffffc020499c:	7ae2                	ld	s5,56(sp)
ffffffffc020499e:	7b42                	ld	s6,48(sp)
ffffffffc02049a0:	7ba2                	ld	s7,40(sp)
ffffffffc02049a2:	7c02                	ld	s8,32(sp)
ffffffffc02049a4:	6ce2                	ld	s9,24(sp)
ffffffffc02049a6:	854a                	mv	a0,s2
ffffffffc02049a8:	6946                	ld	s2,80(sp)
ffffffffc02049aa:	6165                	addi	sp,sp,112
ffffffffc02049ac:	8082                	ret
ffffffffc02049ae:	00092c17          	auipc	s8,0x92
ffffffffc02049b2:	f12c0c13          	addi	s8,s8,-238 # ffffffffc02968c0 <current>
ffffffffc02049b6:	000c3783          	ld	a5,0(s8)
ffffffffc02049ba:	8432                	mv	s0,a2
ffffffffc02049bc:	89ae                	mv	s3,a1
ffffffffc02049be:	4605                	li	a2,1
ffffffffc02049c0:	4581                	li	a1,0
ffffffffc02049c2:	7784                	ld	s1,40(a5)
ffffffffc02049c4:	8baa                	mv	s7,a0
ffffffffc02049c6:	5e6000ef          	jal	ra,ffffffffc0204fac <file_testfd>
ffffffffc02049ca:	cd59                	beqz	a0,ffffffffc0204a68 <sysfile_write+0xf2>
ffffffffc02049cc:	6505                	lui	a0,0x1
ffffffffc02049ce:	df5fe0ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc02049d2:	8a2a                	mv	s4,a0
ffffffffc02049d4:	cd41                	beqz	a0,ffffffffc0204a6c <sysfile_write+0xf6>
ffffffffc02049d6:	4c81                	li	s9,0
ffffffffc02049d8:	6a85                	lui	s5,0x1
ffffffffc02049da:	03848b13          	addi	s6,s1,56
ffffffffc02049de:	05546a63          	bltu	s0,s5,ffffffffc0204a32 <sysfile_write+0xbc>
ffffffffc02049e2:	e456                	sd	s5,8(sp)
ffffffffc02049e4:	c8a9                	beqz	s1,ffffffffc0204a36 <sysfile_write+0xc0>
ffffffffc02049e6:	855a                	mv	a0,s6
ffffffffc02049e8:	d63ff0ef          	jal	ra,ffffffffc020474a <down>
ffffffffc02049ec:	000c3783          	ld	a5,0(s8)
ffffffffc02049f0:	c399                	beqz	a5,ffffffffc02049f6 <sysfile_write+0x80>
ffffffffc02049f2:	43dc                	lw	a5,4(a5)
ffffffffc02049f4:	c8bc                	sw	a5,80(s1)
ffffffffc02049f6:	66a2                	ld	a3,8(sp)
ffffffffc02049f8:	4701                	li	a4,0
ffffffffc02049fa:	864e                	mv	a2,s3
ffffffffc02049fc:	85d2                	mv	a1,s4
ffffffffc02049fe:	8526                	mv	a0,s1
ffffffffc0204a00:	aa5fe0ef          	jal	ra,ffffffffc02034a4 <copy_from_user>
ffffffffc0204a04:	c139                	beqz	a0,ffffffffc0204a4a <sysfile_write+0xd4>
ffffffffc0204a06:	855a                	mv	a0,s6
ffffffffc0204a08:	d3fff0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc0204a0c:	0404a823          	sw	zero,80(s1)
ffffffffc0204a10:	6622                	ld	a2,8(sp)
ffffffffc0204a12:	0034                	addi	a3,sp,8
ffffffffc0204a14:	85d2                	mv	a1,s4
ffffffffc0204a16:	855e                	mv	a0,s7
ffffffffc0204a18:	023000ef          	jal	ra,ffffffffc020523a <file_write>
ffffffffc0204a1c:	67a2                	ld	a5,8(sp)
ffffffffc0204a1e:	892a                	mv	s2,a0
ffffffffc0204a20:	ef85                	bnez	a5,ffffffffc0204a58 <sysfile_write+0xe2>
ffffffffc0204a22:	8552                	mv	a0,s4
ffffffffc0204a24:	e4ffe0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc0204a28:	f60c85e3          	beqz	s9,ffffffffc0204992 <sysfile_write+0x1c>
ffffffffc0204a2c:	000c891b          	sext.w	s2,s9
ffffffffc0204a30:	b78d                	j	ffffffffc0204992 <sysfile_write+0x1c>
ffffffffc0204a32:	e422                	sd	s0,8(sp)
ffffffffc0204a34:	f8cd                	bnez	s1,ffffffffc02049e6 <sysfile_write+0x70>
ffffffffc0204a36:	66a2                	ld	a3,8(sp)
ffffffffc0204a38:	4701                	li	a4,0
ffffffffc0204a3a:	864e                	mv	a2,s3
ffffffffc0204a3c:	85d2                	mv	a1,s4
ffffffffc0204a3e:	4501                	li	a0,0
ffffffffc0204a40:	a65fe0ef          	jal	ra,ffffffffc02034a4 <copy_from_user>
ffffffffc0204a44:	f571                	bnez	a0,ffffffffc0204a10 <sysfile_write+0x9a>
ffffffffc0204a46:	5975                	li	s2,-3
ffffffffc0204a48:	bfe9                	j	ffffffffc0204a22 <sysfile_write+0xac>
ffffffffc0204a4a:	855a                	mv	a0,s6
ffffffffc0204a4c:	cfbff0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc0204a50:	5975                	li	s2,-3
ffffffffc0204a52:	0404a823          	sw	zero,80(s1)
ffffffffc0204a56:	b7f1                	j	ffffffffc0204a22 <sysfile_write+0xac>
ffffffffc0204a58:	00f46c63          	bltu	s0,a5,ffffffffc0204a70 <sysfile_write+0xfa>
ffffffffc0204a5c:	99be                	add	s3,s3,a5
ffffffffc0204a5e:	8c1d                	sub	s0,s0,a5
ffffffffc0204a60:	9cbe                	add	s9,s9,a5
ffffffffc0204a62:	f161                	bnez	a0,ffffffffc0204a22 <sysfile_write+0xac>
ffffffffc0204a64:	fc2d                	bnez	s0,ffffffffc02049de <sysfile_write+0x68>
ffffffffc0204a66:	bf75                	j	ffffffffc0204a22 <sysfile_write+0xac>
ffffffffc0204a68:	5975                	li	s2,-3
ffffffffc0204a6a:	b725                	j	ffffffffc0204992 <sysfile_write+0x1c>
ffffffffc0204a6c:	5971                	li	s2,-4
ffffffffc0204a6e:	b715                	j	ffffffffc0204992 <sysfile_write+0x1c>
ffffffffc0204a70:	00008697          	auipc	a3,0x8
ffffffffc0204a74:	6a868693          	addi	a3,a3,1704 # ffffffffc020d118 <default_pmm_manager+0x120>
ffffffffc0204a78:	00007617          	auipc	a2,0x7
ffffffffc0204a7c:	0b060613          	addi	a2,a2,176 # ffffffffc020bb28 <commands+0x250>
ffffffffc0204a80:	08a00593          	li	a1,138
ffffffffc0204a84:	00008517          	auipc	a0,0x8
ffffffffc0204a88:	6a450513          	addi	a0,a0,1700 # ffffffffc020d128 <default_pmm_manager+0x130>
ffffffffc0204a8c:	fa2fb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0204a90 <sysfile_seek>:
ffffffffc0204a90:	0910006f          	j	ffffffffc0205320 <file_seek>

ffffffffc0204a94 <sysfile_fstat>:
ffffffffc0204a94:	715d                	addi	sp,sp,-80
ffffffffc0204a96:	f44e                	sd	s3,40(sp)
ffffffffc0204a98:	00092997          	auipc	s3,0x92
ffffffffc0204a9c:	e2898993          	addi	s3,s3,-472 # ffffffffc02968c0 <current>
ffffffffc0204aa0:	0009b703          	ld	a4,0(s3)
ffffffffc0204aa4:	fc26                	sd	s1,56(sp)
ffffffffc0204aa6:	84ae                	mv	s1,a1
ffffffffc0204aa8:	858a                	mv	a1,sp
ffffffffc0204aaa:	e0a2                	sd	s0,64(sp)
ffffffffc0204aac:	f84a                	sd	s2,48(sp)
ffffffffc0204aae:	e486                	sd	ra,72(sp)
ffffffffc0204ab0:	02873903          	ld	s2,40(a4)
ffffffffc0204ab4:	f052                	sd	s4,32(sp)
ffffffffc0204ab6:	18b000ef          	jal	ra,ffffffffc0205440 <file_fstat>
ffffffffc0204aba:	842a                	mv	s0,a0
ffffffffc0204abc:	e91d                	bnez	a0,ffffffffc0204af2 <sysfile_fstat+0x5e>
ffffffffc0204abe:	04090363          	beqz	s2,ffffffffc0204b04 <sysfile_fstat+0x70>
ffffffffc0204ac2:	03890a13          	addi	s4,s2,56
ffffffffc0204ac6:	8552                	mv	a0,s4
ffffffffc0204ac8:	c83ff0ef          	jal	ra,ffffffffc020474a <down>
ffffffffc0204acc:	0009b783          	ld	a5,0(s3)
ffffffffc0204ad0:	c3b9                	beqz	a5,ffffffffc0204b16 <sysfile_fstat+0x82>
ffffffffc0204ad2:	43dc                	lw	a5,4(a5)
ffffffffc0204ad4:	02000693          	li	a3,32
ffffffffc0204ad8:	860a                	mv	a2,sp
ffffffffc0204ada:	04f92823          	sw	a5,80(s2)
ffffffffc0204ade:	85a6                	mv	a1,s1
ffffffffc0204ae0:	854a                	mv	a0,s2
ffffffffc0204ae2:	9f7fe0ef          	jal	ra,ffffffffc02034d8 <copy_to_user>
ffffffffc0204ae6:	c121                	beqz	a0,ffffffffc0204b26 <sysfile_fstat+0x92>
ffffffffc0204ae8:	8552                	mv	a0,s4
ffffffffc0204aea:	c5dff0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc0204aee:	04092823          	sw	zero,80(s2)
ffffffffc0204af2:	60a6                	ld	ra,72(sp)
ffffffffc0204af4:	8522                	mv	a0,s0
ffffffffc0204af6:	6406                	ld	s0,64(sp)
ffffffffc0204af8:	74e2                	ld	s1,56(sp)
ffffffffc0204afa:	7942                	ld	s2,48(sp)
ffffffffc0204afc:	79a2                	ld	s3,40(sp)
ffffffffc0204afe:	7a02                	ld	s4,32(sp)
ffffffffc0204b00:	6161                	addi	sp,sp,80
ffffffffc0204b02:	8082                	ret
ffffffffc0204b04:	02000693          	li	a3,32
ffffffffc0204b08:	860a                	mv	a2,sp
ffffffffc0204b0a:	85a6                	mv	a1,s1
ffffffffc0204b0c:	9cdfe0ef          	jal	ra,ffffffffc02034d8 <copy_to_user>
ffffffffc0204b10:	f16d                	bnez	a0,ffffffffc0204af2 <sysfile_fstat+0x5e>
ffffffffc0204b12:	5475                	li	s0,-3
ffffffffc0204b14:	bff9                	j	ffffffffc0204af2 <sysfile_fstat+0x5e>
ffffffffc0204b16:	02000693          	li	a3,32
ffffffffc0204b1a:	860a                	mv	a2,sp
ffffffffc0204b1c:	85a6                	mv	a1,s1
ffffffffc0204b1e:	854a                	mv	a0,s2
ffffffffc0204b20:	9b9fe0ef          	jal	ra,ffffffffc02034d8 <copy_to_user>
ffffffffc0204b24:	f171                	bnez	a0,ffffffffc0204ae8 <sysfile_fstat+0x54>
ffffffffc0204b26:	8552                	mv	a0,s4
ffffffffc0204b28:	c1fff0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc0204b2c:	5475                	li	s0,-3
ffffffffc0204b2e:	04092823          	sw	zero,80(s2)
ffffffffc0204b32:	b7c1                	j	ffffffffc0204af2 <sysfile_fstat+0x5e>

ffffffffc0204b34 <sysfile_fsync>:
ffffffffc0204b34:	1cd0006f          	j	ffffffffc0205500 <file_fsync>

ffffffffc0204b38 <sysfile_getcwd>:
ffffffffc0204b38:	715d                	addi	sp,sp,-80
ffffffffc0204b3a:	f44e                	sd	s3,40(sp)
ffffffffc0204b3c:	00092997          	auipc	s3,0x92
ffffffffc0204b40:	d8498993          	addi	s3,s3,-636 # ffffffffc02968c0 <current>
ffffffffc0204b44:	0009b783          	ld	a5,0(s3)
ffffffffc0204b48:	f84a                	sd	s2,48(sp)
ffffffffc0204b4a:	e486                	sd	ra,72(sp)
ffffffffc0204b4c:	e0a2                	sd	s0,64(sp)
ffffffffc0204b4e:	fc26                	sd	s1,56(sp)
ffffffffc0204b50:	f052                	sd	s4,32(sp)
ffffffffc0204b52:	0287b903          	ld	s2,40(a5)
ffffffffc0204b56:	cda9                	beqz	a1,ffffffffc0204bb0 <sysfile_getcwd+0x78>
ffffffffc0204b58:	842e                	mv	s0,a1
ffffffffc0204b5a:	84aa                	mv	s1,a0
ffffffffc0204b5c:	04090363          	beqz	s2,ffffffffc0204ba2 <sysfile_getcwd+0x6a>
ffffffffc0204b60:	03890a13          	addi	s4,s2,56
ffffffffc0204b64:	8552                	mv	a0,s4
ffffffffc0204b66:	be5ff0ef          	jal	ra,ffffffffc020474a <down>
ffffffffc0204b6a:	0009b783          	ld	a5,0(s3)
ffffffffc0204b6e:	c781                	beqz	a5,ffffffffc0204b76 <sysfile_getcwd+0x3e>
ffffffffc0204b70:	43dc                	lw	a5,4(a5)
ffffffffc0204b72:	04f92823          	sw	a5,80(s2)
ffffffffc0204b76:	4685                	li	a3,1
ffffffffc0204b78:	8622                	mv	a2,s0
ffffffffc0204b7a:	85a6                	mv	a1,s1
ffffffffc0204b7c:	854a                	mv	a0,s2
ffffffffc0204b7e:	893fe0ef          	jal	ra,ffffffffc0203410 <user_mem_check>
ffffffffc0204b82:	e90d                	bnez	a0,ffffffffc0204bb4 <sysfile_getcwd+0x7c>
ffffffffc0204b84:	5475                	li	s0,-3
ffffffffc0204b86:	8552                	mv	a0,s4
ffffffffc0204b88:	bbfff0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc0204b8c:	04092823          	sw	zero,80(s2)
ffffffffc0204b90:	60a6                	ld	ra,72(sp)
ffffffffc0204b92:	8522                	mv	a0,s0
ffffffffc0204b94:	6406                	ld	s0,64(sp)
ffffffffc0204b96:	74e2                	ld	s1,56(sp)
ffffffffc0204b98:	7942                	ld	s2,48(sp)
ffffffffc0204b9a:	79a2                	ld	s3,40(sp)
ffffffffc0204b9c:	7a02                	ld	s4,32(sp)
ffffffffc0204b9e:	6161                	addi	sp,sp,80
ffffffffc0204ba0:	8082                	ret
ffffffffc0204ba2:	862e                	mv	a2,a1
ffffffffc0204ba4:	4685                	li	a3,1
ffffffffc0204ba6:	85aa                	mv	a1,a0
ffffffffc0204ba8:	4501                	li	a0,0
ffffffffc0204baa:	867fe0ef          	jal	ra,ffffffffc0203410 <user_mem_check>
ffffffffc0204bae:	ed09                	bnez	a0,ffffffffc0204bc8 <sysfile_getcwd+0x90>
ffffffffc0204bb0:	5475                	li	s0,-3
ffffffffc0204bb2:	bff9                	j	ffffffffc0204b90 <sysfile_getcwd+0x58>
ffffffffc0204bb4:	8622                	mv	a2,s0
ffffffffc0204bb6:	4681                	li	a3,0
ffffffffc0204bb8:	85a6                	mv	a1,s1
ffffffffc0204bba:	850a                	mv	a0,sp
ffffffffc0204bbc:	371000ef          	jal	ra,ffffffffc020572c <iobuf_init>
ffffffffc0204bc0:	236030ef          	jal	ra,ffffffffc0207df6 <vfs_getcwd>
ffffffffc0204bc4:	842a                	mv	s0,a0
ffffffffc0204bc6:	b7c1                	j	ffffffffc0204b86 <sysfile_getcwd+0x4e>
ffffffffc0204bc8:	8622                	mv	a2,s0
ffffffffc0204bca:	4681                	li	a3,0
ffffffffc0204bcc:	85a6                	mv	a1,s1
ffffffffc0204bce:	850a                	mv	a0,sp
ffffffffc0204bd0:	35d000ef          	jal	ra,ffffffffc020572c <iobuf_init>
ffffffffc0204bd4:	222030ef          	jal	ra,ffffffffc0207df6 <vfs_getcwd>
ffffffffc0204bd8:	842a                	mv	s0,a0
ffffffffc0204bda:	bf5d                	j	ffffffffc0204b90 <sysfile_getcwd+0x58>

ffffffffc0204bdc <sysfile_getdirentry>:
ffffffffc0204bdc:	7139                	addi	sp,sp,-64
ffffffffc0204bde:	e852                	sd	s4,16(sp)
ffffffffc0204be0:	00092a17          	auipc	s4,0x92
ffffffffc0204be4:	ce0a0a13          	addi	s4,s4,-800 # ffffffffc02968c0 <current>
ffffffffc0204be8:	000a3703          	ld	a4,0(s4)
ffffffffc0204bec:	ec4e                	sd	s3,24(sp)
ffffffffc0204bee:	89aa                	mv	s3,a0
ffffffffc0204bf0:	10800513          	li	a0,264
ffffffffc0204bf4:	f426                	sd	s1,40(sp)
ffffffffc0204bf6:	f04a                	sd	s2,32(sp)
ffffffffc0204bf8:	fc06                	sd	ra,56(sp)
ffffffffc0204bfa:	f822                	sd	s0,48(sp)
ffffffffc0204bfc:	e456                	sd	s5,8(sp)
ffffffffc0204bfe:	7704                	ld	s1,40(a4)
ffffffffc0204c00:	892e                	mv	s2,a1
ffffffffc0204c02:	bc1fe0ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc0204c06:	c169                	beqz	a0,ffffffffc0204cc8 <sysfile_getdirentry+0xec>
ffffffffc0204c08:	842a                	mv	s0,a0
ffffffffc0204c0a:	c8c1                	beqz	s1,ffffffffc0204c9a <sysfile_getdirentry+0xbe>
ffffffffc0204c0c:	03848a93          	addi	s5,s1,56
ffffffffc0204c10:	8556                	mv	a0,s5
ffffffffc0204c12:	b39ff0ef          	jal	ra,ffffffffc020474a <down>
ffffffffc0204c16:	000a3783          	ld	a5,0(s4)
ffffffffc0204c1a:	c399                	beqz	a5,ffffffffc0204c20 <sysfile_getdirentry+0x44>
ffffffffc0204c1c:	43dc                	lw	a5,4(a5)
ffffffffc0204c1e:	c8bc                	sw	a5,80(s1)
ffffffffc0204c20:	4705                	li	a4,1
ffffffffc0204c22:	46a1                	li	a3,8
ffffffffc0204c24:	864a                	mv	a2,s2
ffffffffc0204c26:	85a2                	mv	a1,s0
ffffffffc0204c28:	8526                	mv	a0,s1
ffffffffc0204c2a:	87bfe0ef          	jal	ra,ffffffffc02034a4 <copy_from_user>
ffffffffc0204c2e:	e505                	bnez	a0,ffffffffc0204c56 <sysfile_getdirentry+0x7a>
ffffffffc0204c30:	8556                	mv	a0,s5
ffffffffc0204c32:	b15ff0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc0204c36:	59f5                	li	s3,-3
ffffffffc0204c38:	0404a823          	sw	zero,80(s1)
ffffffffc0204c3c:	8522                	mv	a0,s0
ffffffffc0204c3e:	c35fe0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc0204c42:	70e2                	ld	ra,56(sp)
ffffffffc0204c44:	7442                	ld	s0,48(sp)
ffffffffc0204c46:	74a2                	ld	s1,40(sp)
ffffffffc0204c48:	7902                	ld	s2,32(sp)
ffffffffc0204c4a:	6a42                	ld	s4,16(sp)
ffffffffc0204c4c:	6aa2                	ld	s5,8(sp)
ffffffffc0204c4e:	854e                	mv	a0,s3
ffffffffc0204c50:	69e2                	ld	s3,24(sp)
ffffffffc0204c52:	6121                	addi	sp,sp,64
ffffffffc0204c54:	8082                	ret
ffffffffc0204c56:	8556                	mv	a0,s5
ffffffffc0204c58:	aefff0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc0204c5c:	854e                	mv	a0,s3
ffffffffc0204c5e:	85a2                	mv	a1,s0
ffffffffc0204c60:	0404a823          	sw	zero,80(s1)
ffffffffc0204c64:	14b000ef          	jal	ra,ffffffffc02055ae <file_getdirentry>
ffffffffc0204c68:	89aa                	mv	s3,a0
ffffffffc0204c6a:	f969                	bnez	a0,ffffffffc0204c3c <sysfile_getdirentry+0x60>
ffffffffc0204c6c:	8556                	mv	a0,s5
ffffffffc0204c6e:	addff0ef          	jal	ra,ffffffffc020474a <down>
ffffffffc0204c72:	000a3783          	ld	a5,0(s4)
ffffffffc0204c76:	c399                	beqz	a5,ffffffffc0204c7c <sysfile_getdirentry+0xa0>
ffffffffc0204c78:	43dc                	lw	a5,4(a5)
ffffffffc0204c7a:	c8bc                	sw	a5,80(s1)
ffffffffc0204c7c:	10800693          	li	a3,264
ffffffffc0204c80:	8622                	mv	a2,s0
ffffffffc0204c82:	85ca                	mv	a1,s2
ffffffffc0204c84:	8526                	mv	a0,s1
ffffffffc0204c86:	853fe0ef          	jal	ra,ffffffffc02034d8 <copy_to_user>
ffffffffc0204c8a:	e111                	bnez	a0,ffffffffc0204c8e <sysfile_getdirentry+0xb2>
ffffffffc0204c8c:	59f5                	li	s3,-3
ffffffffc0204c8e:	8556                	mv	a0,s5
ffffffffc0204c90:	ab7ff0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc0204c94:	0404a823          	sw	zero,80(s1)
ffffffffc0204c98:	b755                	j	ffffffffc0204c3c <sysfile_getdirentry+0x60>
ffffffffc0204c9a:	85aa                	mv	a1,a0
ffffffffc0204c9c:	4705                	li	a4,1
ffffffffc0204c9e:	46a1                	li	a3,8
ffffffffc0204ca0:	864a                	mv	a2,s2
ffffffffc0204ca2:	4501                	li	a0,0
ffffffffc0204ca4:	801fe0ef          	jal	ra,ffffffffc02034a4 <copy_from_user>
ffffffffc0204ca8:	cd11                	beqz	a0,ffffffffc0204cc4 <sysfile_getdirentry+0xe8>
ffffffffc0204caa:	854e                	mv	a0,s3
ffffffffc0204cac:	85a2                	mv	a1,s0
ffffffffc0204cae:	101000ef          	jal	ra,ffffffffc02055ae <file_getdirentry>
ffffffffc0204cb2:	89aa                	mv	s3,a0
ffffffffc0204cb4:	f541                	bnez	a0,ffffffffc0204c3c <sysfile_getdirentry+0x60>
ffffffffc0204cb6:	10800693          	li	a3,264
ffffffffc0204cba:	8622                	mv	a2,s0
ffffffffc0204cbc:	85ca                	mv	a1,s2
ffffffffc0204cbe:	81bfe0ef          	jal	ra,ffffffffc02034d8 <copy_to_user>
ffffffffc0204cc2:	fd2d                	bnez	a0,ffffffffc0204c3c <sysfile_getdirentry+0x60>
ffffffffc0204cc4:	59f5                	li	s3,-3
ffffffffc0204cc6:	bf9d                	j	ffffffffc0204c3c <sysfile_getdirentry+0x60>
ffffffffc0204cc8:	59f1                	li	s3,-4
ffffffffc0204cca:	bfa5                	j	ffffffffc0204c42 <sysfile_getdirentry+0x66>

ffffffffc0204ccc <sysfile_dup>:
ffffffffc0204ccc:	1c90006f          	j	ffffffffc0205694 <file_dup>

ffffffffc0204cd0 <get_fd_array.part.0>:
ffffffffc0204cd0:	1141                	addi	sp,sp,-16
ffffffffc0204cd2:	00008697          	auipc	a3,0x8
ffffffffc0204cd6:	46e68693          	addi	a3,a3,1134 # ffffffffc020d140 <default_pmm_manager+0x148>
ffffffffc0204cda:	00007617          	auipc	a2,0x7
ffffffffc0204cde:	e4e60613          	addi	a2,a2,-434 # ffffffffc020bb28 <commands+0x250>
ffffffffc0204ce2:	45d1                	li	a1,20
ffffffffc0204ce4:	00008517          	auipc	a0,0x8
ffffffffc0204ce8:	48c50513          	addi	a0,a0,1164 # ffffffffc020d170 <default_pmm_manager+0x178>
ffffffffc0204cec:	e406                	sd	ra,8(sp)
ffffffffc0204cee:	d40fb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0204cf2 <fd_array_alloc>:
ffffffffc0204cf2:	00092797          	auipc	a5,0x92
ffffffffc0204cf6:	bce7b783          	ld	a5,-1074(a5) # ffffffffc02968c0 <current>
ffffffffc0204cfa:	1487b783          	ld	a5,328(a5)
ffffffffc0204cfe:	1141                	addi	sp,sp,-16
ffffffffc0204d00:	e406                	sd	ra,8(sp)
ffffffffc0204d02:	c3a5                	beqz	a5,ffffffffc0204d62 <fd_array_alloc+0x70>
ffffffffc0204d04:	4b98                	lw	a4,16(a5)
ffffffffc0204d06:	04e05e63          	blez	a4,ffffffffc0204d62 <fd_array_alloc+0x70>
ffffffffc0204d0a:	775d                	lui	a4,0xffff7
ffffffffc0204d0c:	ad970713          	addi	a4,a4,-1319 # ffffffffffff6ad9 <end+0x3fd601c9>
ffffffffc0204d10:	679c                	ld	a5,8(a5)
ffffffffc0204d12:	02e50863          	beq	a0,a4,ffffffffc0204d42 <fd_array_alloc+0x50>
ffffffffc0204d16:	04700713          	li	a4,71
ffffffffc0204d1a:	04a76263          	bltu	a4,a0,ffffffffc0204d5e <fd_array_alloc+0x6c>
ffffffffc0204d1e:	00351713          	slli	a4,a0,0x3
ffffffffc0204d22:	40a70533          	sub	a0,a4,a0
ffffffffc0204d26:	050e                	slli	a0,a0,0x3
ffffffffc0204d28:	97aa                	add	a5,a5,a0
ffffffffc0204d2a:	4398                	lw	a4,0(a5)
ffffffffc0204d2c:	e71d                	bnez	a4,ffffffffc0204d5a <fd_array_alloc+0x68>
ffffffffc0204d2e:	5b88                	lw	a0,48(a5)
ffffffffc0204d30:	e91d                	bnez	a0,ffffffffc0204d66 <fd_array_alloc+0x74>
ffffffffc0204d32:	4705                	li	a4,1
ffffffffc0204d34:	c398                	sw	a4,0(a5)
ffffffffc0204d36:	0207b423          	sd	zero,40(a5)
ffffffffc0204d3a:	e19c                	sd	a5,0(a1)
ffffffffc0204d3c:	60a2                	ld	ra,8(sp)
ffffffffc0204d3e:	0141                	addi	sp,sp,16
ffffffffc0204d40:	8082                	ret
ffffffffc0204d42:	6685                	lui	a3,0x1
ffffffffc0204d44:	fc068693          	addi	a3,a3,-64 # fc0 <_binary_bin_swap_img_size-0x6d40>
ffffffffc0204d48:	96be                	add	a3,a3,a5
ffffffffc0204d4a:	4398                	lw	a4,0(a5)
ffffffffc0204d4c:	d36d                	beqz	a4,ffffffffc0204d2e <fd_array_alloc+0x3c>
ffffffffc0204d4e:	03878793          	addi	a5,a5,56
ffffffffc0204d52:	fef69ce3          	bne	a3,a5,ffffffffc0204d4a <fd_array_alloc+0x58>
ffffffffc0204d56:	5529                	li	a0,-22
ffffffffc0204d58:	b7d5                	j	ffffffffc0204d3c <fd_array_alloc+0x4a>
ffffffffc0204d5a:	5545                	li	a0,-15
ffffffffc0204d5c:	b7c5                	j	ffffffffc0204d3c <fd_array_alloc+0x4a>
ffffffffc0204d5e:	5575                	li	a0,-3
ffffffffc0204d60:	bff1                	j	ffffffffc0204d3c <fd_array_alloc+0x4a>
ffffffffc0204d62:	f6fff0ef          	jal	ra,ffffffffc0204cd0 <get_fd_array.part.0>
ffffffffc0204d66:	00008697          	auipc	a3,0x8
ffffffffc0204d6a:	41a68693          	addi	a3,a3,1050 # ffffffffc020d180 <default_pmm_manager+0x188>
ffffffffc0204d6e:	00007617          	auipc	a2,0x7
ffffffffc0204d72:	dba60613          	addi	a2,a2,-582 # ffffffffc020bb28 <commands+0x250>
ffffffffc0204d76:	03b00593          	li	a1,59
ffffffffc0204d7a:	00008517          	auipc	a0,0x8
ffffffffc0204d7e:	3f650513          	addi	a0,a0,1014 # ffffffffc020d170 <default_pmm_manager+0x178>
ffffffffc0204d82:	cacfb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0204d86 <fd_array_free>:
ffffffffc0204d86:	411c                	lw	a5,0(a0)
ffffffffc0204d88:	1141                	addi	sp,sp,-16
ffffffffc0204d8a:	e022                	sd	s0,0(sp)
ffffffffc0204d8c:	e406                	sd	ra,8(sp)
ffffffffc0204d8e:	4705                	li	a4,1
ffffffffc0204d90:	842a                	mv	s0,a0
ffffffffc0204d92:	04e78063          	beq	a5,a4,ffffffffc0204dd2 <fd_array_free+0x4c>
ffffffffc0204d96:	470d                	li	a4,3
ffffffffc0204d98:	04e79563          	bne	a5,a4,ffffffffc0204de2 <fd_array_free+0x5c>
ffffffffc0204d9c:	591c                	lw	a5,48(a0)
ffffffffc0204d9e:	c38d                	beqz	a5,ffffffffc0204dc0 <fd_array_free+0x3a>
ffffffffc0204da0:	00008697          	auipc	a3,0x8
ffffffffc0204da4:	3e068693          	addi	a3,a3,992 # ffffffffc020d180 <default_pmm_manager+0x188>
ffffffffc0204da8:	00007617          	auipc	a2,0x7
ffffffffc0204dac:	d8060613          	addi	a2,a2,-640 # ffffffffc020bb28 <commands+0x250>
ffffffffc0204db0:	04500593          	li	a1,69
ffffffffc0204db4:	00008517          	auipc	a0,0x8
ffffffffc0204db8:	3bc50513          	addi	a0,a0,956 # ffffffffc020d170 <default_pmm_manager+0x178>
ffffffffc0204dbc:	c72fb0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0204dc0:	7408                	ld	a0,40(s0)
ffffffffc0204dc2:	724030ef          	jal	ra,ffffffffc02084e6 <vfs_close>
ffffffffc0204dc6:	60a2                	ld	ra,8(sp)
ffffffffc0204dc8:	00042023          	sw	zero,0(s0)
ffffffffc0204dcc:	6402                	ld	s0,0(sp)
ffffffffc0204dce:	0141                	addi	sp,sp,16
ffffffffc0204dd0:	8082                	ret
ffffffffc0204dd2:	591c                	lw	a5,48(a0)
ffffffffc0204dd4:	f7f1                	bnez	a5,ffffffffc0204da0 <fd_array_free+0x1a>
ffffffffc0204dd6:	60a2                	ld	ra,8(sp)
ffffffffc0204dd8:	00042023          	sw	zero,0(s0)
ffffffffc0204ddc:	6402                	ld	s0,0(sp)
ffffffffc0204dde:	0141                	addi	sp,sp,16
ffffffffc0204de0:	8082                	ret
ffffffffc0204de2:	00008697          	auipc	a3,0x8
ffffffffc0204de6:	3d668693          	addi	a3,a3,982 # ffffffffc020d1b8 <default_pmm_manager+0x1c0>
ffffffffc0204dea:	00007617          	auipc	a2,0x7
ffffffffc0204dee:	d3e60613          	addi	a2,a2,-706 # ffffffffc020bb28 <commands+0x250>
ffffffffc0204df2:	04400593          	li	a1,68
ffffffffc0204df6:	00008517          	auipc	a0,0x8
ffffffffc0204dfa:	37a50513          	addi	a0,a0,890 # ffffffffc020d170 <default_pmm_manager+0x178>
ffffffffc0204dfe:	c30fb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0204e02 <fd_array_release>:
ffffffffc0204e02:	4118                	lw	a4,0(a0)
ffffffffc0204e04:	1141                	addi	sp,sp,-16
ffffffffc0204e06:	e406                	sd	ra,8(sp)
ffffffffc0204e08:	4685                	li	a3,1
ffffffffc0204e0a:	3779                	addiw	a4,a4,-2
ffffffffc0204e0c:	04e6e063          	bltu	a3,a4,ffffffffc0204e4c <fd_array_release+0x4a>
ffffffffc0204e10:	5918                	lw	a4,48(a0)
ffffffffc0204e12:	00e05d63          	blez	a4,ffffffffc0204e2c <fd_array_release+0x2a>
ffffffffc0204e16:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204e1a:	d914                	sw	a3,48(a0)
ffffffffc0204e1c:	c681                	beqz	a3,ffffffffc0204e24 <fd_array_release+0x22>
ffffffffc0204e1e:	60a2                	ld	ra,8(sp)
ffffffffc0204e20:	0141                	addi	sp,sp,16
ffffffffc0204e22:	8082                	ret
ffffffffc0204e24:	60a2                	ld	ra,8(sp)
ffffffffc0204e26:	0141                	addi	sp,sp,16
ffffffffc0204e28:	f5fff06f          	j	ffffffffc0204d86 <fd_array_free>
ffffffffc0204e2c:	00008697          	auipc	a3,0x8
ffffffffc0204e30:	3fc68693          	addi	a3,a3,1020 # ffffffffc020d228 <default_pmm_manager+0x230>
ffffffffc0204e34:	00007617          	auipc	a2,0x7
ffffffffc0204e38:	cf460613          	addi	a2,a2,-780 # ffffffffc020bb28 <commands+0x250>
ffffffffc0204e3c:	05600593          	li	a1,86
ffffffffc0204e40:	00008517          	auipc	a0,0x8
ffffffffc0204e44:	33050513          	addi	a0,a0,816 # ffffffffc020d170 <default_pmm_manager+0x178>
ffffffffc0204e48:	be6fb0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0204e4c:	00008697          	auipc	a3,0x8
ffffffffc0204e50:	3a468693          	addi	a3,a3,932 # ffffffffc020d1f0 <default_pmm_manager+0x1f8>
ffffffffc0204e54:	00007617          	auipc	a2,0x7
ffffffffc0204e58:	cd460613          	addi	a2,a2,-812 # ffffffffc020bb28 <commands+0x250>
ffffffffc0204e5c:	05500593          	li	a1,85
ffffffffc0204e60:	00008517          	auipc	a0,0x8
ffffffffc0204e64:	31050513          	addi	a0,a0,784 # ffffffffc020d170 <default_pmm_manager+0x178>
ffffffffc0204e68:	bc6fb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0204e6c <fd_array_open.part.0>:
ffffffffc0204e6c:	1141                	addi	sp,sp,-16
ffffffffc0204e6e:	00008697          	auipc	a3,0x8
ffffffffc0204e72:	3d268693          	addi	a3,a3,978 # ffffffffc020d240 <default_pmm_manager+0x248>
ffffffffc0204e76:	00007617          	auipc	a2,0x7
ffffffffc0204e7a:	cb260613          	addi	a2,a2,-846 # ffffffffc020bb28 <commands+0x250>
ffffffffc0204e7e:	05f00593          	li	a1,95
ffffffffc0204e82:	00008517          	auipc	a0,0x8
ffffffffc0204e86:	2ee50513          	addi	a0,a0,750 # ffffffffc020d170 <default_pmm_manager+0x178>
ffffffffc0204e8a:	e406                	sd	ra,8(sp)
ffffffffc0204e8c:	ba2fb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0204e90 <fd_array_init>:
ffffffffc0204e90:	4781                	li	a5,0
ffffffffc0204e92:	04800713          	li	a4,72
ffffffffc0204e96:	cd1c                	sw	a5,24(a0)
ffffffffc0204e98:	02052823          	sw	zero,48(a0)
ffffffffc0204e9c:	00052023          	sw	zero,0(a0)
ffffffffc0204ea0:	2785                	addiw	a5,a5,1
ffffffffc0204ea2:	03850513          	addi	a0,a0,56
ffffffffc0204ea6:	fee798e3          	bne	a5,a4,ffffffffc0204e96 <fd_array_init+0x6>
ffffffffc0204eaa:	8082                	ret

ffffffffc0204eac <fd_array_close>:
ffffffffc0204eac:	4118                	lw	a4,0(a0)
ffffffffc0204eae:	1141                	addi	sp,sp,-16
ffffffffc0204eb0:	e406                	sd	ra,8(sp)
ffffffffc0204eb2:	e022                	sd	s0,0(sp)
ffffffffc0204eb4:	4789                	li	a5,2
ffffffffc0204eb6:	04f71a63          	bne	a4,a5,ffffffffc0204f0a <fd_array_close+0x5e>
ffffffffc0204eba:	591c                	lw	a5,48(a0)
ffffffffc0204ebc:	842a                	mv	s0,a0
ffffffffc0204ebe:	02f05663          	blez	a5,ffffffffc0204eea <fd_array_close+0x3e>
ffffffffc0204ec2:	37fd                	addiw	a5,a5,-1
ffffffffc0204ec4:	470d                	li	a4,3
ffffffffc0204ec6:	c118                	sw	a4,0(a0)
ffffffffc0204ec8:	d91c                	sw	a5,48(a0)
ffffffffc0204eca:	0007871b          	sext.w	a4,a5
ffffffffc0204ece:	c709                	beqz	a4,ffffffffc0204ed8 <fd_array_close+0x2c>
ffffffffc0204ed0:	60a2                	ld	ra,8(sp)
ffffffffc0204ed2:	6402                	ld	s0,0(sp)
ffffffffc0204ed4:	0141                	addi	sp,sp,16
ffffffffc0204ed6:	8082                	ret
ffffffffc0204ed8:	7508                	ld	a0,40(a0)
ffffffffc0204eda:	60c030ef          	jal	ra,ffffffffc02084e6 <vfs_close>
ffffffffc0204ede:	60a2                	ld	ra,8(sp)
ffffffffc0204ee0:	00042023          	sw	zero,0(s0)
ffffffffc0204ee4:	6402                	ld	s0,0(sp)
ffffffffc0204ee6:	0141                	addi	sp,sp,16
ffffffffc0204ee8:	8082                	ret
ffffffffc0204eea:	00008697          	auipc	a3,0x8
ffffffffc0204eee:	33e68693          	addi	a3,a3,830 # ffffffffc020d228 <default_pmm_manager+0x230>
ffffffffc0204ef2:	00007617          	auipc	a2,0x7
ffffffffc0204ef6:	c3660613          	addi	a2,a2,-970 # ffffffffc020bb28 <commands+0x250>
ffffffffc0204efa:	06800593          	li	a1,104
ffffffffc0204efe:	00008517          	auipc	a0,0x8
ffffffffc0204f02:	27250513          	addi	a0,a0,626 # ffffffffc020d170 <default_pmm_manager+0x178>
ffffffffc0204f06:	b28fb0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0204f0a:	00008697          	auipc	a3,0x8
ffffffffc0204f0e:	28e68693          	addi	a3,a3,654 # ffffffffc020d198 <default_pmm_manager+0x1a0>
ffffffffc0204f12:	00007617          	auipc	a2,0x7
ffffffffc0204f16:	c1660613          	addi	a2,a2,-1002 # ffffffffc020bb28 <commands+0x250>
ffffffffc0204f1a:	06700593          	li	a1,103
ffffffffc0204f1e:	00008517          	auipc	a0,0x8
ffffffffc0204f22:	25250513          	addi	a0,a0,594 # ffffffffc020d170 <default_pmm_manager+0x178>
ffffffffc0204f26:	b08fb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0204f2a <fd_array_dup>:
ffffffffc0204f2a:	7179                	addi	sp,sp,-48
ffffffffc0204f2c:	e84a                	sd	s2,16(sp)
ffffffffc0204f2e:	00052903          	lw	s2,0(a0)
ffffffffc0204f32:	f406                	sd	ra,40(sp)
ffffffffc0204f34:	f022                	sd	s0,32(sp)
ffffffffc0204f36:	ec26                	sd	s1,24(sp)
ffffffffc0204f38:	e44e                	sd	s3,8(sp)
ffffffffc0204f3a:	4785                	li	a5,1
ffffffffc0204f3c:	04f91663          	bne	s2,a5,ffffffffc0204f88 <fd_array_dup+0x5e>
ffffffffc0204f40:	0005a983          	lw	s3,0(a1)
ffffffffc0204f44:	4789                	li	a5,2
ffffffffc0204f46:	04f99163          	bne	s3,a5,ffffffffc0204f88 <fd_array_dup+0x5e>
ffffffffc0204f4a:	7584                	ld	s1,40(a1)
ffffffffc0204f4c:	699c                	ld	a5,16(a1)
ffffffffc0204f4e:	7194                	ld	a3,32(a1)
ffffffffc0204f50:	6598                	ld	a4,8(a1)
ffffffffc0204f52:	842a                	mv	s0,a0
ffffffffc0204f54:	e91c                	sd	a5,16(a0)
ffffffffc0204f56:	f114                	sd	a3,32(a0)
ffffffffc0204f58:	e518                	sd	a4,8(a0)
ffffffffc0204f5a:	8526                	mv	a0,s1
ffffffffc0204f5c:	1cc030ef          	jal	ra,ffffffffc0208128 <inode_ref_inc>
ffffffffc0204f60:	8526                	mv	a0,s1
ffffffffc0204f62:	1d2030ef          	jal	ra,ffffffffc0208134 <inode_open_inc>
ffffffffc0204f66:	401c                	lw	a5,0(s0)
ffffffffc0204f68:	f404                	sd	s1,40(s0)
ffffffffc0204f6a:	03279f63          	bne	a5,s2,ffffffffc0204fa8 <fd_array_dup+0x7e>
ffffffffc0204f6e:	cc8d                	beqz	s1,ffffffffc0204fa8 <fd_array_dup+0x7e>
ffffffffc0204f70:	581c                	lw	a5,48(s0)
ffffffffc0204f72:	01342023          	sw	s3,0(s0)
ffffffffc0204f76:	70a2                	ld	ra,40(sp)
ffffffffc0204f78:	2785                	addiw	a5,a5,1
ffffffffc0204f7a:	d81c                	sw	a5,48(s0)
ffffffffc0204f7c:	7402                	ld	s0,32(sp)
ffffffffc0204f7e:	64e2                	ld	s1,24(sp)
ffffffffc0204f80:	6942                	ld	s2,16(sp)
ffffffffc0204f82:	69a2                	ld	s3,8(sp)
ffffffffc0204f84:	6145                	addi	sp,sp,48
ffffffffc0204f86:	8082                	ret
ffffffffc0204f88:	00008697          	auipc	a3,0x8
ffffffffc0204f8c:	2e868693          	addi	a3,a3,744 # ffffffffc020d270 <default_pmm_manager+0x278>
ffffffffc0204f90:	00007617          	auipc	a2,0x7
ffffffffc0204f94:	b9860613          	addi	a2,a2,-1128 # ffffffffc020bb28 <commands+0x250>
ffffffffc0204f98:	07300593          	li	a1,115
ffffffffc0204f9c:	00008517          	auipc	a0,0x8
ffffffffc0204fa0:	1d450513          	addi	a0,a0,468 # ffffffffc020d170 <default_pmm_manager+0x178>
ffffffffc0204fa4:	a8afb0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0204fa8:	ec5ff0ef          	jal	ra,ffffffffc0204e6c <fd_array_open.part.0>

ffffffffc0204fac <file_testfd>:
ffffffffc0204fac:	04700793          	li	a5,71
ffffffffc0204fb0:	04a7e263          	bltu	a5,a0,ffffffffc0204ff4 <file_testfd+0x48>
ffffffffc0204fb4:	00092797          	auipc	a5,0x92
ffffffffc0204fb8:	90c7b783          	ld	a5,-1780(a5) # ffffffffc02968c0 <current>
ffffffffc0204fbc:	1487b783          	ld	a5,328(a5)
ffffffffc0204fc0:	cf85                	beqz	a5,ffffffffc0204ff8 <file_testfd+0x4c>
ffffffffc0204fc2:	4b98                	lw	a4,16(a5)
ffffffffc0204fc4:	02e05a63          	blez	a4,ffffffffc0204ff8 <file_testfd+0x4c>
ffffffffc0204fc8:	6798                	ld	a4,8(a5)
ffffffffc0204fca:	00351793          	slli	a5,a0,0x3
ffffffffc0204fce:	8f89                	sub	a5,a5,a0
ffffffffc0204fd0:	078e                	slli	a5,a5,0x3
ffffffffc0204fd2:	97ba                	add	a5,a5,a4
ffffffffc0204fd4:	4394                	lw	a3,0(a5)
ffffffffc0204fd6:	4709                	li	a4,2
ffffffffc0204fd8:	00e69e63          	bne	a3,a4,ffffffffc0204ff4 <file_testfd+0x48>
ffffffffc0204fdc:	4f98                	lw	a4,24(a5)
ffffffffc0204fde:	00a71b63          	bne	a4,a0,ffffffffc0204ff4 <file_testfd+0x48>
ffffffffc0204fe2:	c199                	beqz	a1,ffffffffc0204fe8 <file_testfd+0x3c>
ffffffffc0204fe4:	6788                	ld	a0,8(a5)
ffffffffc0204fe6:	c901                	beqz	a0,ffffffffc0204ff6 <file_testfd+0x4a>
ffffffffc0204fe8:	4505                	li	a0,1
ffffffffc0204fea:	c611                	beqz	a2,ffffffffc0204ff6 <file_testfd+0x4a>
ffffffffc0204fec:	6b88                	ld	a0,16(a5)
ffffffffc0204fee:	00a03533          	snez	a0,a0
ffffffffc0204ff2:	8082                	ret
ffffffffc0204ff4:	4501                	li	a0,0
ffffffffc0204ff6:	8082                	ret
ffffffffc0204ff8:	1141                	addi	sp,sp,-16
ffffffffc0204ffa:	e406                	sd	ra,8(sp)
ffffffffc0204ffc:	cd5ff0ef          	jal	ra,ffffffffc0204cd0 <get_fd_array.part.0>

ffffffffc0205000 <file_open>:
ffffffffc0205000:	711d                	addi	sp,sp,-96
ffffffffc0205002:	ec86                	sd	ra,88(sp)
ffffffffc0205004:	e8a2                	sd	s0,80(sp)
ffffffffc0205006:	e4a6                	sd	s1,72(sp)
ffffffffc0205008:	e0ca                	sd	s2,64(sp)
ffffffffc020500a:	fc4e                	sd	s3,56(sp)
ffffffffc020500c:	f852                	sd	s4,48(sp)
ffffffffc020500e:	0035f793          	andi	a5,a1,3
ffffffffc0205012:	470d                	li	a4,3
ffffffffc0205014:	0ce78163          	beq	a5,a4,ffffffffc02050d6 <file_open+0xd6>
ffffffffc0205018:	078e                	slli	a5,a5,0x3
ffffffffc020501a:	00008717          	auipc	a4,0x8
ffffffffc020501e:	4c670713          	addi	a4,a4,1222 # ffffffffc020d4e0 <CSWTCH.79>
ffffffffc0205022:	892a                	mv	s2,a0
ffffffffc0205024:	00008697          	auipc	a3,0x8
ffffffffc0205028:	4a468693          	addi	a3,a3,1188 # ffffffffc020d4c8 <CSWTCH.78>
ffffffffc020502c:	755d                	lui	a0,0xffff7
ffffffffc020502e:	96be                	add	a3,a3,a5
ffffffffc0205030:	84ae                	mv	s1,a1
ffffffffc0205032:	97ba                	add	a5,a5,a4
ffffffffc0205034:	858a                	mv	a1,sp
ffffffffc0205036:	ad950513          	addi	a0,a0,-1319 # ffffffffffff6ad9 <end+0x3fd601c9>
ffffffffc020503a:	0006ba03          	ld	s4,0(a3)
ffffffffc020503e:	0007b983          	ld	s3,0(a5)
ffffffffc0205042:	cb1ff0ef          	jal	ra,ffffffffc0204cf2 <fd_array_alloc>
ffffffffc0205046:	842a                	mv	s0,a0
ffffffffc0205048:	c911                	beqz	a0,ffffffffc020505c <file_open+0x5c>
ffffffffc020504a:	60e6                	ld	ra,88(sp)
ffffffffc020504c:	8522                	mv	a0,s0
ffffffffc020504e:	6446                	ld	s0,80(sp)
ffffffffc0205050:	64a6                	ld	s1,72(sp)
ffffffffc0205052:	6906                	ld	s2,64(sp)
ffffffffc0205054:	79e2                	ld	s3,56(sp)
ffffffffc0205056:	7a42                	ld	s4,48(sp)
ffffffffc0205058:	6125                	addi	sp,sp,96
ffffffffc020505a:	8082                	ret
ffffffffc020505c:	0030                	addi	a2,sp,8
ffffffffc020505e:	85a6                	mv	a1,s1
ffffffffc0205060:	854a                	mv	a0,s2
ffffffffc0205062:	2de030ef          	jal	ra,ffffffffc0208340 <vfs_open>
ffffffffc0205066:	842a                	mv	s0,a0
ffffffffc0205068:	e13d                	bnez	a0,ffffffffc02050ce <file_open+0xce>
ffffffffc020506a:	6782                	ld	a5,0(sp)
ffffffffc020506c:	0204f493          	andi	s1,s1,32
ffffffffc0205070:	6422                	ld	s0,8(sp)
ffffffffc0205072:	0207b023          	sd	zero,32(a5)
ffffffffc0205076:	c885                	beqz	s1,ffffffffc02050a6 <file_open+0xa6>
ffffffffc0205078:	c03d                	beqz	s0,ffffffffc02050de <file_open+0xde>
ffffffffc020507a:	783c                	ld	a5,112(s0)
ffffffffc020507c:	c3ad                	beqz	a5,ffffffffc02050de <file_open+0xde>
ffffffffc020507e:	779c                	ld	a5,40(a5)
ffffffffc0205080:	cfb9                	beqz	a5,ffffffffc02050de <file_open+0xde>
ffffffffc0205082:	8522                	mv	a0,s0
ffffffffc0205084:	00008597          	auipc	a1,0x8
ffffffffc0205088:	27458593          	addi	a1,a1,628 # ffffffffc020d2f8 <default_pmm_manager+0x300>
ffffffffc020508c:	0b4030ef          	jal	ra,ffffffffc0208140 <inode_check>
ffffffffc0205090:	783c                	ld	a5,112(s0)
ffffffffc0205092:	6522                	ld	a0,8(sp)
ffffffffc0205094:	080c                	addi	a1,sp,16
ffffffffc0205096:	779c                	ld	a5,40(a5)
ffffffffc0205098:	9782                	jalr	a5
ffffffffc020509a:	842a                	mv	s0,a0
ffffffffc020509c:	e515                	bnez	a0,ffffffffc02050c8 <file_open+0xc8>
ffffffffc020509e:	6782                	ld	a5,0(sp)
ffffffffc02050a0:	7722                	ld	a4,40(sp)
ffffffffc02050a2:	6422                	ld	s0,8(sp)
ffffffffc02050a4:	f398                	sd	a4,32(a5)
ffffffffc02050a6:	4394                	lw	a3,0(a5)
ffffffffc02050a8:	f780                	sd	s0,40(a5)
ffffffffc02050aa:	0147b423          	sd	s4,8(a5)
ffffffffc02050ae:	0137b823          	sd	s3,16(a5)
ffffffffc02050b2:	4705                	li	a4,1
ffffffffc02050b4:	02e69363          	bne	a3,a4,ffffffffc02050da <file_open+0xda>
ffffffffc02050b8:	c00d                	beqz	s0,ffffffffc02050da <file_open+0xda>
ffffffffc02050ba:	5b98                	lw	a4,48(a5)
ffffffffc02050bc:	4689                	li	a3,2
ffffffffc02050be:	4f80                	lw	s0,24(a5)
ffffffffc02050c0:	2705                	addiw	a4,a4,1
ffffffffc02050c2:	c394                	sw	a3,0(a5)
ffffffffc02050c4:	db98                	sw	a4,48(a5)
ffffffffc02050c6:	b751                	j	ffffffffc020504a <file_open+0x4a>
ffffffffc02050c8:	6522                	ld	a0,8(sp)
ffffffffc02050ca:	41c030ef          	jal	ra,ffffffffc02084e6 <vfs_close>
ffffffffc02050ce:	6502                	ld	a0,0(sp)
ffffffffc02050d0:	cb7ff0ef          	jal	ra,ffffffffc0204d86 <fd_array_free>
ffffffffc02050d4:	bf9d                	j	ffffffffc020504a <file_open+0x4a>
ffffffffc02050d6:	5475                	li	s0,-3
ffffffffc02050d8:	bf8d                	j	ffffffffc020504a <file_open+0x4a>
ffffffffc02050da:	d93ff0ef          	jal	ra,ffffffffc0204e6c <fd_array_open.part.0>
ffffffffc02050de:	00008697          	auipc	a3,0x8
ffffffffc02050e2:	1ca68693          	addi	a3,a3,458 # ffffffffc020d2a8 <default_pmm_manager+0x2b0>
ffffffffc02050e6:	00007617          	auipc	a2,0x7
ffffffffc02050ea:	a4260613          	addi	a2,a2,-1470 # ffffffffc020bb28 <commands+0x250>
ffffffffc02050ee:	0b500593          	li	a1,181
ffffffffc02050f2:	00008517          	auipc	a0,0x8
ffffffffc02050f6:	07e50513          	addi	a0,a0,126 # ffffffffc020d170 <default_pmm_manager+0x178>
ffffffffc02050fa:	934fb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02050fe <file_close>:
ffffffffc02050fe:	04700713          	li	a4,71
ffffffffc0205102:	04a76563          	bltu	a4,a0,ffffffffc020514c <file_close+0x4e>
ffffffffc0205106:	00091717          	auipc	a4,0x91
ffffffffc020510a:	7ba73703          	ld	a4,1978(a4) # ffffffffc02968c0 <current>
ffffffffc020510e:	14873703          	ld	a4,328(a4)
ffffffffc0205112:	1141                	addi	sp,sp,-16
ffffffffc0205114:	e406                	sd	ra,8(sp)
ffffffffc0205116:	cf0d                	beqz	a4,ffffffffc0205150 <file_close+0x52>
ffffffffc0205118:	4b14                	lw	a3,16(a4)
ffffffffc020511a:	02d05b63          	blez	a3,ffffffffc0205150 <file_close+0x52>
ffffffffc020511e:	6718                	ld	a4,8(a4)
ffffffffc0205120:	87aa                	mv	a5,a0
ffffffffc0205122:	050e                	slli	a0,a0,0x3
ffffffffc0205124:	8d1d                	sub	a0,a0,a5
ffffffffc0205126:	050e                	slli	a0,a0,0x3
ffffffffc0205128:	953a                	add	a0,a0,a4
ffffffffc020512a:	4114                	lw	a3,0(a0)
ffffffffc020512c:	4709                	li	a4,2
ffffffffc020512e:	00e69b63          	bne	a3,a4,ffffffffc0205144 <file_close+0x46>
ffffffffc0205132:	4d18                	lw	a4,24(a0)
ffffffffc0205134:	00f71863          	bne	a4,a5,ffffffffc0205144 <file_close+0x46>
ffffffffc0205138:	d75ff0ef          	jal	ra,ffffffffc0204eac <fd_array_close>
ffffffffc020513c:	60a2                	ld	ra,8(sp)
ffffffffc020513e:	4501                	li	a0,0
ffffffffc0205140:	0141                	addi	sp,sp,16
ffffffffc0205142:	8082                	ret
ffffffffc0205144:	60a2                	ld	ra,8(sp)
ffffffffc0205146:	5575                	li	a0,-3
ffffffffc0205148:	0141                	addi	sp,sp,16
ffffffffc020514a:	8082                	ret
ffffffffc020514c:	5575                	li	a0,-3
ffffffffc020514e:	8082                	ret
ffffffffc0205150:	b81ff0ef          	jal	ra,ffffffffc0204cd0 <get_fd_array.part.0>

ffffffffc0205154 <file_read>:
ffffffffc0205154:	715d                	addi	sp,sp,-80
ffffffffc0205156:	e486                	sd	ra,72(sp)
ffffffffc0205158:	e0a2                	sd	s0,64(sp)
ffffffffc020515a:	fc26                	sd	s1,56(sp)
ffffffffc020515c:	f84a                	sd	s2,48(sp)
ffffffffc020515e:	f44e                	sd	s3,40(sp)
ffffffffc0205160:	f052                	sd	s4,32(sp)
ffffffffc0205162:	0006b023          	sd	zero,0(a3)
ffffffffc0205166:	04700793          	li	a5,71
ffffffffc020516a:	0aa7e463          	bltu	a5,a0,ffffffffc0205212 <file_read+0xbe>
ffffffffc020516e:	00091797          	auipc	a5,0x91
ffffffffc0205172:	7527b783          	ld	a5,1874(a5) # ffffffffc02968c0 <current>
ffffffffc0205176:	1487b783          	ld	a5,328(a5)
ffffffffc020517a:	cfd1                	beqz	a5,ffffffffc0205216 <file_read+0xc2>
ffffffffc020517c:	4b98                	lw	a4,16(a5)
ffffffffc020517e:	08e05c63          	blez	a4,ffffffffc0205216 <file_read+0xc2>
ffffffffc0205182:	6780                	ld	s0,8(a5)
ffffffffc0205184:	00351793          	slli	a5,a0,0x3
ffffffffc0205188:	8f89                	sub	a5,a5,a0
ffffffffc020518a:	078e                	slli	a5,a5,0x3
ffffffffc020518c:	943e                	add	s0,s0,a5
ffffffffc020518e:	00042983          	lw	s3,0(s0)
ffffffffc0205192:	4789                	li	a5,2
ffffffffc0205194:	06f99f63          	bne	s3,a5,ffffffffc0205212 <file_read+0xbe>
ffffffffc0205198:	4c1c                	lw	a5,24(s0)
ffffffffc020519a:	06a79c63          	bne	a5,a0,ffffffffc0205212 <file_read+0xbe>
ffffffffc020519e:	641c                	ld	a5,8(s0)
ffffffffc02051a0:	cbad                	beqz	a5,ffffffffc0205212 <file_read+0xbe>
ffffffffc02051a2:	581c                	lw	a5,48(s0)
ffffffffc02051a4:	8a36                	mv	s4,a3
ffffffffc02051a6:	7014                	ld	a3,32(s0)
ffffffffc02051a8:	2785                	addiw	a5,a5,1
ffffffffc02051aa:	850a                	mv	a0,sp
ffffffffc02051ac:	d81c                	sw	a5,48(s0)
ffffffffc02051ae:	57e000ef          	jal	ra,ffffffffc020572c <iobuf_init>
ffffffffc02051b2:	02843903          	ld	s2,40(s0)
ffffffffc02051b6:	84aa                	mv	s1,a0
ffffffffc02051b8:	06090163          	beqz	s2,ffffffffc020521a <file_read+0xc6>
ffffffffc02051bc:	07093783          	ld	a5,112(s2)
ffffffffc02051c0:	cfa9                	beqz	a5,ffffffffc020521a <file_read+0xc6>
ffffffffc02051c2:	6f9c                	ld	a5,24(a5)
ffffffffc02051c4:	cbb9                	beqz	a5,ffffffffc020521a <file_read+0xc6>
ffffffffc02051c6:	00008597          	auipc	a1,0x8
ffffffffc02051ca:	18a58593          	addi	a1,a1,394 # ffffffffc020d350 <default_pmm_manager+0x358>
ffffffffc02051ce:	854a                	mv	a0,s2
ffffffffc02051d0:	771020ef          	jal	ra,ffffffffc0208140 <inode_check>
ffffffffc02051d4:	07093783          	ld	a5,112(s2)
ffffffffc02051d8:	7408                	ld	a0,40(s0)
ffffffffc02051da:	85a6                	mv	a1,s1
ffffffffc02051dc:	6f9c                	ld	a5,24(a5)
ffffffffc02051de:	9782                	jalr	a5
ffffffffc02051e0:	689c                	ld	a5,16(s1)
ffffffffc02051e2:	6c94                	ld	a3,24(s1)
ffffffffc02051e4:	4018                	lw	a4,0(s0)
ffffffffc02051e6:	84aa                	mv	s1,a0
ffffffffc02051e8:	8f95                	sub	a5,a5,a3
ffffffffc02051ea:	03370063          	beq	a4,s3,ffffffffc020520a <file_read+0xb6>
ffffffffc02051ee:	00fa3023          	sd	a5,0(s4)
ffffffffc02051f2:	8522                	mv	a0,s0
ffffffffc02051f4:	c0fff0ef          	jal	ra,ffffffffc0204e02 <fd_array_release>
ffffffffc02051f8:	60a6                	ld	ra,72(sp)
ffffffffc02051fa:	6406                	ld	s0,64(sp)
ffffffffc02051fc:	7942                	ld	s2,48(sp)
ffffffffc02051fe:	79a2                	ld	s3,40(sp)
ffffffffc0205200:	7a02                	ld	s4,32(sp)
ffffffffc0205202:	8526                	mv	a0,s1
ffffffffc0205204:	74e2                	ld	s1,56(sp)
ffffffffc0205206:	6161                	addi	sp,sp,80
ffffffffc0205208:	8082                	ret
ffffffffc020520a:	7018                	ld	a4,32(s0)
ffffffffc020520c:	973e                	add	a4,a4,a5
ffffffffc020520e:	f018                	sd	a4,32(s0)
ffffffffc0205210:	bff9                	j	ffffffffc02051ee <file_read+0x9a>
ffffffffc0205212:	54f5                	li	s1,-3
ffffffffc0205214:	b7d5                	j	ffffffffc02051f8 <file_read+0xa4>
ffffffffc0205216:	abbff0ef          	jal	ra,ffffffffc0204cd0 <get_fd_array.part.0>
ffffffffc020521a:	00008697          	auipc	a3,0x8
ffffffffc020521e:	0e668693          	addi	a3,a3,230 # ffffffffc020d300 <default_pmm_manager+0x308>
ffffffffc0205222:	00007617          	auipc	a2,0x7
ffffffffc0205226:	90660613          	addi	a2,a2,-1786 # ffffffffc020bb28 <commands+0x250>
ffffffffc020522a:	0de00593          	li	a1,222
ffffffffc020522e:	00008517          	auipc	a0,0x8
ffffffffc0205232:	f4250513          	addi	a0,a0,-190 # ffffffffc020d170 <default_pmm_manager+0x178>
ffffffffc0205236:	ff9fa0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020523a <file_write>:
ffffffffc020523a:	715d                	addi	sp,sp,-80
ffffffffc020523c:	e486                	sd	ra,72(sp)
ffffffffc020523e:	e0a2                	sd	s0,64(sp)
ffffffffc0205240:	fc26                	sd	s1,56(sp)
ffffffffc0205242:	f84a                	sd	s2,48(sp)
ffffffffc0205244:	f44e                	sd	s3,40(sp)
ffffffffc0205246:	f052                	sd	s4,32(sp)
ffffffffc0205248:	0006b023          	sd	zero,0(a3)
ffffffffc020524c:	04700793          	li	a5,71
ffffffffc0205250:	0aa7e463          	bltu	a5,a0,ffffffffc02052f8 <file_write+0xbe>
ffffffffc0205254:	00091797          	auipc	a5,0x91
ffffffffc0205258:	66c7b783          	ld	a5,1644(a5) # ffffffffc02968c0 <current>
ffffffffc020525c:	1487b783          	ld	a5,328(a5)
ffffffffc0205260:	cfd1                	beqz	a5,ffffffffc02052fc <file_write+0xc2>
ffffffffc0205262:	4b98                	lw	a4,16(a5)
ffffffffc0205264:	08e05c63          	blez	a4,ffffffffc02052fc <file_write+0xc2>
ffffffffc0205268:	6780                	ld	s0,8(a5)
ffffffffc020526a:	00351793          	slli	a5,a0,0x3
ffffffffc020526e:	8f89                	sub	a5,a5,a0
ffffffffc0205270:	078e                	slli	a5,a5,0x3
ffffffffc0205272:	943e                	add	s0,s0,a5
ffffffffc0205274:	00042983          	lw	s3,0(s0)
ffffffffc0205278:	4789                	li	a5,2
ffffffffc020527a:	06f99f63          	bne	s3,a5,ffffffffc02052f8 <file_write+0xbe>
ffffffffc020527e:	4c1c                	lw	a5,24(s0)
ffffffffc0205280:	06a79c63          	bne	a5,a0,ffffffffc02052f8 <file_write+0xbe>
ffffffffc0205284:	681c                	ld	a5,16(s0)
ffffffffc0205286:	cbad                	beqz	a5,ffffffffc02052f8 <file_write+0xbe>
ffffffffc0205288:	581c                	lw	a5,48(s0)
ffffffffc020528a:	8a36                	mv	s4,a3
ffffffffc020528c:	7014                	ld	a3,32(s0)
ffffffffc020528e:	2785                	addiw	a5,a5,1
ffffffffc0205290:	850a                	mv	a0,sp
ffffffffc0205292:	d81c                	sw	a5,48(s0)
ffffffffc0205294:	498000ef          	jal	ra,ffffffffc020572c <iobuf_init>
ffffffffc0205298:	02843903          	ld	s2,40(s0)
ffffffffc020529c:	84aa                	mv	s1,a0
ffffffffc020529e:	06090163          	beqz	s2,ffffffffc0205300 <file_write+0xc6>
ffffffffc02052a2:	07093783          	ld	a5,112(s2)
ffffffffc02052a6:	cfa9                	beqz	a5,ffffffffc0205300 <file_write+0xc6>
ffffffffc02052a8:	739c                	ld	a5,32(a5)
ffffffffc02052aa:	cbb9                	beqz	a5,ffffffffc0205300 <file_write+0xc6>
ffffffffc02052ac:	00008597          	auipc	a1,0x8
ffffffffc02052b0:	0fc58593          	addi	a1,a1,252 # ffffffffc020d3a8 <default_pmm_manager+0x3b0>
ffffffffc02052b4:	854a                	mv	a0,s2
ffffffffc02052b6:	68b020ef          	jal	ra,ffffffffc0208140 <inode_check>
ffffffffc02052ba:	07093783          	ld	a5,112(s2)
ffffffffc02052be:	7408                	ld	a0,40(s0)
ffffffffc02052c0:	85a6                	mv	a1,s1
ffffffffc02052c2:	739c                	ld	a5,32(a5)
ffffffffc02052c4:	9782                	jalr	a5
ffffffffc02052c6:	689c                	ld	a5,16(s1)
ffffffffc02052c8:	6c94                	ld	a3,24(s1)
ffffffffc02052ca:	4018                	lw	a4,0(s0)
ffffffffc02052cc:	84aa                	mv	s1,a0
ffffffffc02052ce:	8f95                	sub	a5,a5,a3
ffffffffc02052d0:	03370063          	beq	a4,s3,ffffffffc02052f0 <file_write+0xb6>
ffffffffc02052d4:	00fa3023          	sd	a5,0(s4)
ffffffffc02052d8:	8522                	mv	a0,s0
ffffffffc02052da:	b29ff0ef          	jal	ra,ffffffffc0204e02 <fd_array_release>
ffffffffc02052de:	60a6                	ld	ra,72(sp)
ffffffffc02052e0:	6406                	ld	s0,64(sp)
ffffffffc02052e2:	7942                	ld	s2,48(sp)
ffffffffc02052e4:	79a2                	ld	s3,40(sp)
ffffffffc02052e6:	7a02                	ld	s4,32(sp)
ffffffffc02052e8:	8526                	mv	a0,s1
ffffffffc02052ea:	74e2                	ld	s1,56(sp)
ffffffffc02052ec:	6161                	addi	sp,sp,80
ffffffffc02052ee:	8082                	ret
ffffffffc02052f0:	7018                	ld	a4,32(s0)
ffffffffc02052f2:	973e                	add	a4,a4,a5
ffffffffc02052f4:	f018                	sd	a4,32(s0)
ffffffffc02052f6:	bff9                	j	ffffffffc02052d4 <file_write+0x9a>
ffffffffc02052f8:	54f5                	li	s1,-3
ffffffffc02052fa:	b7d5                	j	ffffffffc02052de <file_write+0xa4>
ffffffffc02052fc:	9d5ff0ef          	jal	ra,ffffffffc0204cd0 <get_fd_array.part.0>
ffffffffc0205300:	00008697          	auipc	a3,0x8
ffffffffc0205304:	05868693          	addi	a3,a3,88 # ffffffffc020d358 <default_pmm_manager+0x360>
ffffffffc0205308:	00007617          	auipc	a2,0x7
ffffffffc020530c:	82060613          	addi	a2,a2,-2016 # ffffffffc020bb28 <commands+0x250>
ffffffffc0205310:	0f800593          	li	a1,248
ffffffffc0205314:	00008517          	auipc	a0,0x8
ffffffffc0205318:	e5c50513          	addi	a0,a0,-420 # ffffffffc020d170 <default_pmm_manager+0x178>
ffffffffc020531c:	f13fa0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0205320 <file_seek>:
ffffffffc0205320:	7139                	addi	sp,sp,-64
ffffffffc0205322:	fc06                	sd	ra,56(sp)
ffffffffc0205324:	f822                	sd	s0,48(sp)
ffffffffc0205326:	f426                	sd	s1,40(sp)
ffffffffc0205328:	f04a                	sd	s2,32(sp)
ffffffffc020532a:	04700793          	li	a5,71
ffffffffc020532e:	08a7e863          	bltu	a5,a0,ffffffffc02053be <file_seek+0x9e>
ffffffffc0205332:	00091797          	auipc	a5,0x91
ffffffffc0205336:	58e7b783          	ld	a5,1422(a5) # ffffffffc02968c0 <current>
ffffffffc020533a:	1487b783          	ld	a5,328(a5)
ffffffffc020533e:	cfdd                	beqz	a5,ffffffffc02053fc <file_seek+0xdc>
ffffffffc0205340:	4b98                	lw	a4,16(a5)
ffffffffc0205342:	0ae05d63          	blez	a4,ffffffffc02053fc <file_seek+0xdc>
ffffffffc0205346:	6780                	ld	s0,8(a5)
ffffffffc0205348:	00351793          	slli	a5,a0,0x3
ffffffffc020534c:	8f89                	sub	a5,a5,a0
ffffffffc020534e:	078e                	slli	a5,a5,0x3
ffffffffc0205350:	943e                	add	s0,s0,a5
ffffffffc0205352:	4018                	lw	a4,0(s0)
ffffffffc0205354:	4789                	li	a5,2
ffffffffc0205356:	06f71463          	bne	a4,a5,ffffffffc02053be <file_seek+0x9e>
ffffffffc020535a:	4c1c                	lw	a5,24(s0)
ffffffffc020535c:	06a79163          	bne	a5,a0,ffffffffc02053be <file_seek+0x9e>
ffffffffc0205360:	581c                	lw	a5,48(s0)
ffffffffc0205362:	4685                	li	a3,1
ffffffffc0205364:	892e                	mv	s2,a1
ffffffffc0205366:	2785                	addiw	a5,a5,1
ffffffffc0205368:	d81c                	sw	a5,48(s0)
ffffffffc020536a:	02d60063          	beq	a2,a3,ffffffffc020538a <file_seek+0x6a>
ffffffffc020536e:	06e60063          	beq	a2,a4,ffffffffc02053ce <file_seek+0xae>
ffffffffc0205372:	54f5                	li	s1,-3
ffffffffc0205374:	ce11                	beqz	a2,ffffffffc0205390 <file_seek+0x70>
ffffffffc0205376:	8522                	mv	a0,s0
ffffffffc0205378:	a8bff0ef          	jal	ra,ffffffffc0204e02 <fd_array_release>
ffffffffc020537c:	70e2                	ld	ra,56(sp)
ffffffffc020537e:	7442                	ld	s0,48(sp)
ffffffffc0205380:	7902                	ld	s2,32(sp)
ffffffffc0205382:	8526                	mv	a0,s1
ffffffffc0205384:	74a2                	ld	s1,40(sp)
ffffffffc0205386:	6121                	addi	sp,sp,64
ffffffffc0205388:	8082                	ret
ffffffffc020538a:	701c                	ld	a5,32(s0)
ffffffffc020538c:	00f58933          	add	s2,a1,a5
ffffffffc0205390:	7404                	ld	s1,40(s0)
ffffffffc0205392:	c4bd                	beqz	s1,ffffffffc0205400 <file_seek+0xe0>
ffffffffc0205394:	78bc                	ld	a5,112(s1)
ffffffffc0205396:	c7ad                	beqz	a5,ffffffffc0205400 <file_seek+0xe0>
ffffffffc0205398:	6fbc                	ld	a5,88(a5)
ffffffffc020539a:	c3bd                	beqz	a5,ffffffffc0205400 <file_seek+0xe0>
ffffffffc020539c:	8526                	mv	a0,s1
ffffffffc020539e:	00008597          	auipc	a1,0x8
ffffffffc02053a2:	06258593          	addi	a1,a1,98 # ffffffffc020d400 <default_pmm_manager+0x408>
ffffffffc02053a6:	59b020ef          	jal	ra,ffffffffc0208140 <inode_check>
ffffffffc02053aa:	78bc                	ld	a5,112(s1)
ffffffffc02053ac:	7408                	ld	a0,40(s0)
ffffffffc02053ae:	85ca                	mv	a1,s2
ffffffffc02053b0:	6fbc                	ld	a5,88(a5)
ffffffffc02053b2:	9782                	jalr	a5
ffffffffc02053b4:	84aa                	mv	s1,a0
ffffffffc02053b6:	f161                	bnez	a0,ffffffffc0205376 <file_seek+0x56>
ffffffffc02053b8:	03243023          	sd	s2,32(s0)
ffffffffc02053bc:	bf6d                	j	ffffffffc0205376 <file_seek+0x56>
ffffffffc02053be:	70e2                	ld	ra,56(sp)
ffffffffc02053c0:	7442                	ld	s0,48(sp)
ffffffffc02053c2:	54f5                	li	s1,-3
ffffffffc02053c4:	7902                	ld	s2,32(sp)
ffffffffc02053c6:	8526                	mv	a0,s1
ffffffffc02053c8:	74a2                	ld	s1,40(sp)
ffffffffc02053ca:	6121                	addi	sp,sp,64
ffffffffc02053cc:	8082                	ret
ffffffffc02053ce:	7404                	ld	s1,40(s0)
ffffffffc02053d0:	c8a1                	beqz	s1,ffffffffc0205420 <file_seek+0x100>
ffffffffc02053d2:	78bc                	ld	a5,112(s1)
ffffffffc02053d4:	c7b1                	beqz	a5,ffffffffc0205420 <file_seek+0x100>
ffffffffc02053d6:	779c                	ld	a5,40(a5)
ffffffffc02053d8:	c7a1                	beqz	a5,ffffffffc0205420 <file_seek+0x100>
ffffffffc02053da:	8526                	mv	a0,s1
ffffffffc02053dc:	00008597          	auipc	a1,0x8
ffffffffc02053e0:	f1c58593          	addi	a1,a1,-228 # ffffffffc020d2f8 <default_pmm_manager+0x300>
ffffffffc02053e4:	55d020ef          	jal	ra,ffffffffc0208140 <inode_check>
ffffffffc02053e8:	78bc                	ld	a5,112(s1)
ffffffffc02053ea:	7408                	ld	a0,40(s0)
ffffffffc02053ec:	858a                	mv	a1,sp
ffffffffc02053ee:	779c                	ld	a5,40(a5)
ffffffffc02053f0:	9782                	jalr	a5
ffffffffc02053f2:	84aa                	mv	s1,a0
ffffffffc02053f4:	f149                	bnez	a0,ffffffffc0205376 <file_seek+0x56>
ffffffffc02053f6:	67e2                	ld	a5,24(sp)
ffffffffc02053f8:	993e                	add	s2,s2,a5
ffffffffc02053fa:	bf59                	j	ffffffffc0205390 <file_seek+0x70>
ffffffffc02053fc:	8d5ff0ef          	jal	ra,ffffffffc0204cd0 <get_fd_array.part.0>
ffffffffc0205400:	00008697          	auipc	a3,0x8
ffffffffc0205404:	fb068693          	addi	a3,a3,-80 # ffffffffc020d3b0 <default_pmm_manager+0x3b8>
ffffffffc0205408:	00006617          	auipc	a2,0x6
ffffffffc020540c:	72060613          	addi	a2,a2,1824 # ffffffffc020bb28 <commands+0x250>
ffffffffc0205410:	11a00593          	li	a1,282
ffffffffc0205414:	00008517          	auipc	a0,0x8
ffffffffc0205418:	d5c50513          	addi	a0,a0,-676 # ffffffffc020d170 <default_pmm_manager+0x178>
ffffffffc020541c:	e13fa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0205420:	00008697          	auipc	a3,0x8
ffffffffc0205424:	e8868693          	addi	a3,a3,-376 # ffffffffc020d2a8 <default_pmm_manager+0x2b0>
ffffffffc0205428:	00006617          	auipc	a2,0x6
ffffffffc020542c:	70060613          	addi	a2,a2,1792 # ffffffffc020bb28 <commands+0x250>
ffffffffc0205430:	11200593          	li	a1,274
ffffffffc0205434:	00008517          	auipc	a0,0x8
ffffffffc0205438:	d3c50513          	addi	a0,a0,-708 # ffffffffc020d170 <default_pmm_manager+0x178>
ffffffffc020543c:	df3fa0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0205440 <file_fstat>:
ffffffffc0205440:	1101                	addi	sp,sp,-32
ffffffffc0205442:	ec06                	sd	ra,24(sp)
ffffffffc0205444:	e822                	sd	s0,16(sp)
ffffffffc0205446:	e426                	sd	s1,8(sp)
ffffffffc0205448:	e04a                	sd	s2,0(sp)
ffffffffc020544a:	04700793          	li	a5,71
ffffffffc020544e:	06a7ef63          	bltu	a5,a0,ffffffffc02054cc <file_fstat+0x8c>
ffffffffc0205452:	00091797          	auipc	a5,0x91
ffffffffc0205456:	46e7b783          	ld	a5,1134(a5) # ffffffffc02968c0 <current>
ffffffffc020545a:	1487b783          	ld	a5,328(a5)
ffffffffc020545e:	cfd9                	beqz	a5,ffffffffc02054fc <file_fstat+0xbc>
ffffffffc0205460:	4b98                	lw	a4,16(a5)
ffffffffc0205462:	08e05d63          	blez	a4,ffffffffc02054fc <file_fstat+0xbc>
ffffffffc0205466:	6780                	ld	s0,8(a5)
ffffffffc0205468:	00351793          	slli	a5,a0,0x3
ffffffffc020546c:	8f89                	sub	a5,a5,a0
ffffffffc020546e:	078e                	slli	a5,a5,0x3
ffffffffc0205470:	943e                	add	s0,s0,a5
ffffffffc0205472:	4018                	lw	a4,0(s0)
ffffffffc0205474:	4789                	li	a5,2
ffffffffc0205476:	04f71b63          	bne	a4,a5,ffffffffc02054cc <file_fstat+0x8c>
ffffffffc020547a:	4c1c                	lw	a5,24(s0)
ffffffffc020547c:	04a79863          	bne	a5,a0,ffffffffc02054cc <file_fstat+0x8c>
ffffffffc0205480:	581c                	lw	a5,48(s0)
ffffffffc0205482:	02843903          	ld	s2,40(s0)
ffffffffc0205486:	2785                	addiw	a5,a5,1
ffffffffc0205488:	d81c                	sw	a5,48(s0)
ffffffffc020548a:	04090963          	beqz	s2,ffffffffc02054dc <file_fstat+0x9c>
ffffffffc020548e:	07093783          	ld	a5,112(s2)
ffffffffc0205492:	c7a9                	beqz	a5,ffffffffc02054dc <file_fstat+0x9c>
ffffffffc0205494:	779c                	ld	a5,40(a5)
ffffffffc0205496:	c3b9                	beqz	a5,ffffffffc02054dc <file_fstat+0x9c>
ffffffffc0205498:	84ae                	mv	s1,a1
ffffffffc020549a:	854a                	mv	a0,s2
ffffffffc020549c:	00008597          	auipc	a1,0x8
ffffffffc02054a0:	e5c58593          	addi	a1,a1,-420 # ffffffffc020d2f8 <default_pmm_manager+0x300>
ffffffffc02054a4:	49d020ef          	jal	ra,ffffffffc0208140 <inode_check>
ffffffffc02054a8:	07093783          	ld	a5,112(s2)
ffffffffc02054ac:	7408                	ld	a0,40(s0)
ffffffffc02054ae:	85a6                	mv	a1,s1
ffffffffc02054b0:	779c                	ld	a5,40(a5)
ffffffffc02054b2:	9782                	jalr	a5
ffffffffc02054b4:	87aa                	mv	a5,a0
ffffffffc02054b6:	8522                	mv	a0,s0
ffffffffc02054b8:	843e                	mv	s0,a5
ffffffffc02054ba:	949ff0ef          	jal	ra,ffffffffc0204e02 <fd_array_release>
ffffffffc02054be:	60e2                	ld	ra,24(sp)
ffffffffc02054c0:	8522                	mv	a0,s0
ffffffffc02054c2:	6442                	ld	s0,16(sp)
ffffffffc02054c4:	64a2                	ld	s1,8(sp)
ffffffffc02054c6:	6902                	ld	s2,0(sp)
ffffffffc02054c8:	6105                	addi	sp,sp,32
ffffffffc02054ca:	8082                	ret
ffffffffc02054cc:	5475                	li	s0,-3
ffffffffc02054ce:	60e2                	ld	ra,24(sp)
ffffffffc02054d0:	8522                	mv	a0,s0
ffffffffc02054d2:	6442                	ld	s0,16(sp)
ffffffffc02054d4:	64a2                	ld	s1,8(sp)
ffffffffc02054d6:	6902                	ld	s2,0(sp)
ffffffffc02054d8:	6105                	addi	sp,sp,32
ffffffffc02054da:	8082                	ret
ffffffffc02054dc:	00008697          	auipc	a3,0x8
ffffffffc02054e0:	dcc68693          	addi	a3,a3,-564 # ffffffffc020d2a8 <default_pmm_manager+0x2b0>
ffffffffc02054e4:	00006617          	auipc	a2,0x6
ffffffffc02054e8:	64460613          	addi	a2,a2,1604 # ffffffffc020bb28 <commands+0x250>
ffffffffc02054ec:	12c00593          	li	a1,300
ffffffffc02054f0:	00008517          	auipc	a0,0x8
ffffffffc02054f4:	c8050513          	addi	a0,a0,-896 # ffffffffc020d170 <default_pmm_manager+0x178>
ffffffffc02054f8:	d37fa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02054fc:	fd4ff0ef          	jal	ra,ffffffffc0204cd0 <get_fd_array.part.0>

ffffffffc0205500 <file_fsync>:
ffffffffc0205500:	1101                	addi	sp,sp,-32
ffffffffc0205502:	ec06                	sd	ra,24(sp)
ffffffffc0205504:	e822                	sd	s0,16(sp)
ffffffffc0205506:	e426                	sd	s1,8(sp)
ffffffffc0205508:	04700793          	li	a5,71
ffffffffc020550c:	06a7e863          	bltu	a5,a0,ffffffffc020557c <file_fsync+0x7c>
ffffffffc0205510:	00091797          	auipc	a5,0x91
ffffffffc0205514:	3b07b783          	ld	a5,944(a5) # ffffffffc02968c0 <current>
ffffffffc0205518:	1487b783          	ld	a5,328(a5)
ffffffffc020551c:	c7d9                	beqz	a5,ffffffffc02055aa <file_fsync+0xaa>
ffffffffc020551e:	4b98                	lw	a4,16(a5)
ffffffffc0205520:	08e05563          	blez	a4,ffffffffc02055aa <file_fsync+0xaa>
ffffffffc0205524:	6780                	ld	s0,8(a5)
ffffffffc0205526:	00351793          	slli	a5,a0,0x3
ffffffffc020552a:	8f89                	sub	a5,a5,a0
ffffffffc020552c:	078e                	slli	a5,a5,0x3
ffffffffc020552e:	943e                	add	s0,s0,a5
ffffffffc0205530:	4018                	lw	a4,0(s0)
ffffffffc0205532:	4789                	li	a5,2
ffffffffc0205534:	04f71463          	bne	a4,a5,ffffffffc020557c <file_fsync+0x7c>
ffffffffc0205538:	4c1c                	lw	a5,24(s0)
ffffffffc020553a:	04a79163          	bne	a5,a0,ffffffffc020557c <file_fsync+0x7c>
ffffffffc020553e:	581c                	lw	a5,48(s0)
ffffffffc0205540:	7404                	ld	s1,40(s0)
ffffffffc0205542:	2785                	addiw	a5,a5,1
ffffffffc0205544:	d81c                	sw	a5,48(s0)
ffffffffc0205546:	c0b1                	beqz	s1,ffffffffc020558a <file_fsync+0x8a>
ffffffffc0205548:	78bc                	ld	a5,112(s1)
ffffffffc020554a:	c3a1                	beqz	a5,ffffffffc020558a <file_fsync+0x8a>
ffffffffc020554c:	7b9c                	ld	a5,48(a5)
ffffffffc020554e:	cf95                	beqz	a5,ffffffffc020558a <file_fsync+0x8a>
ffffffffc0205550:	00008597          	auipc	a1,0x8
ffffffffc0205554:	f0858593          	addi	a1,a1,-248 # ffffffffc020d458 <default_pmm_manager+0x460>
ffffffffc0205558:	8526                	mv	a0,s1
ffffffffc020555a:	3e7020ef          	jal	ra,ffffffffc0208140 <inode_check>
ffffffffc020555e:	78bc                	ld	a5,112(s1)
ffffffffc0205560:	7408                	ld	a0,40(s0)
ffffffffc0205562:	7b9c                	ld	a5,48(a5)
ffffffffc0205564:	9782                	jalr	a5
ffffffffc0205566:	87aa                	mv	a5,a0
ffffffffc0205568:	8522                	mv	a0,s0
ffffffffc020556a:	843e                	mv	s0,a5
ffffffffc020556c:	897ff0ef          	jal	ra,ffffffffc0204e02 <fd_array_release>
ffffffffc0205570:	60e2                	ld	ra,24(sp)
ffffffffc0205572:	8522                	mv	a0,s0
ffffffffc0205574:	6442                	ld	s0,16(sp)
ffffffffc0205576:	64a2                	ld	s1,8(sp)
ffffffffc0205578:	6105                	addi	sp,sp,32
ffffffffc020557a:	8082                	ret
ffffffffc020557c:	5475                	li	s0,-3
ffffffffc020557e:	60e2                	ld	ra,24(sp)
ffffffffc0205580:	8522                	mv	a0,s0
ffffffffc0205582:	6442                	ld	s0,16(sp)
ffffffffc0205584:	64a2                	ld	s1,8(sp)
ffffffffc0205586:	6105                	addi	sp,sp,32
ffffffffc0205588:	8082                	ret
ffffffffc020558a:	00008697          	auipc	a3,0x8
ffffffffc020558e:	e7e68693          	addi	a3,a3,-386 # ffffffffc020d408 <default_pmm_manager+0x410>
ffffffffc0205592:	00006617          	auipc	a2,0x6
ffffffffc0205596:	59660613          	addi	a2,a2,1430 # ffffffffc020bb28 <commands+0x250>
ffffffffc020559a:	13a00593          	li	a1,314
ffffffffc020559e:	00008517          	auipc	a0,0x8
ffffffffc02055a2:	bd250513          	addi	a0,a0,-1070 # ffffffffc020d170 <default_pmm_manager+0x178>
ffffffffc02055a6:	c89fa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02055aa:	f26ff0ef          	jal	ra,ffffffffc0204cd0 <get_fd_array.part.0>

ffffffffc02055ae <file_getdirentry>:
ffffffffc02055ae:	715d                	addi	sp,sp,-80
ffffffffc02055b0:	e486                	sd	ra,72(sp)
ffffffffc02055b2:	e0a2                	sd	s0,64(sp)
ffffffffc02055b4:	fc26                	sd	s1,56(sp)
ffffffffc02055b6:	f84a                	sd	s2,48(sp)
ffffffffc02055b8:	f44e                	sd	s3,40(sp)
ffffffffc02055ba:	04700793          	li	a5,71
ffffffffc02055be:	0aa7e063          	bltu	a5,a0,ffffffffc020565e <file_getdirentry+0xb0>
ffffffffc02055c2:	00091797          	auipc	a5,0x91
ffffffffc02055c6:	2fe7b783          	ld	a5,766(a5) # ffffffffc02968c0 <current>
ffffffffc02055ca:	1487b783          	ld	a5,328(a5)
ffffffffc02055ce:	c3e9                	beqz	a5,ffffffffc0205690 <file_getdirentry+0xe2>
ffffffffc02055d0:	4b98                	lw	a4,16(a5)
ffffffffc02055d2:	0ae05f63          	blez	a4,ffffffffc0205690 <file_getdirentry+0xe2>
ffffffffc02055d6:	6780                	ld	s0,8(a5)
ffffffffc02055d8:	00351793          	slli	a5,a0,0x3
ffffffffc02055dc:	8f89                	sub	a5,a5,a0
ffffffffc02055de:	078e                	slli	a5,a5,0x3
ffffffffc02055e0:	943e                	add	s0,s0,a5
ffffffffc02055e2:	4018                	lw	a4,0(s0)
ffffffffc02055e4:	4789                	li	a5,2
ffffffffc02055e6:	06f71c63          	bne	a4,a5,ffffffffc020565e <file_getdirentry+0xb0>
ffffffffc02055ea:	4c1c                	lw	a5,24(s0)
ffffffffc02055ec:	06a79963          	bne	a5,a0,ffffffffc020565e <file_getdirentry+0xb0>
ffffffffc02055f0:	581c                	lw	a5,48(s0)
ffffffffc02055f2:	6194                	ld	a3,0(a1)
ffffffffc02055f4:	84ae                	mv	s1,a1
ffffffffc02055f6:	2785                	addiw	a5,a5,1
ffffffffc02055f8:	10000613          	li	a2,256
ffffffffc02055fc:	d81c                	sw	a5,48(s0)
ffffffffc02055fe:	05a1                	addi	a1,a1,8
ffffffffc0205600:	850a                	mv	a0,sp
ffffffffc0205602:	12a000ef          	jal	ra,ffffffffc020572c <iobuf_init>
ffffffffc0205606:	02843983          	ld	s3,40(s0)
ffffffffc020560a:	892a                	mv	s2,a0
ffffffffc020560c:	06098263          	beqz	s3,ffffffffc0205670 <file_getdirentry+0xc2>
ffffffffc0205610:	0709b783          	ld	a5,112(s3)
ffffffffc0205614:	cfb1                	beqz	a5,ffffffffc0205670 <file_getdirentry+0xc2>
ffffffffc0205616:	63bc                	ld	a5,64(a5)
ffffffffc0205618:	cfa1                	beqz	a5,ffffffffc0205670 <file_getdirentry+0xc2>
ffffffffc020561a:	854e                	mv	a0,s3
ffffffffc020561c:	00008597          	auipc	a1,0x8
ffffffffc0205620:	e9c58593          	addi	a1,a1,-356 # ffffffffc020d4b8 <default_pmm_manager+0x4c0>
ffffffffc0205624:	31d020ef          	jal	ra,ffffffffc0208140 <inode_check>
ffffffffc0205628:	0709b783          	ld	a5,112(s3)
ffffffffc020562c:	7408                	ld	a0,40(s0)
ffffffffc020562e:	85ca                	mv	a1,s2
ffffffffc0205630:	63bc                	ld	a5,64(a5)
ffffffffc0205632:	9782                	jalr	a5
ffffffffc0205634:	89aa                	mv	s3,a0
ffffffffc0205636:	e909                	bnez	a0,ffffffffc0205648 <file_getdirentry+0x9a>
ffffffffc0205638:	609c                	ld	a5,0(s1)
ffffffffc020563a:	01093683          	ld	a3,16(s2)
ffffffffc020563e:	01893703          	ld	a4,24(s2)
ffffffffc0205642:	97b6                	add	a5,a5,a3
ffffffffc0205644:	8f99                	sub	a5,a5,a4
ffffffffc0205646:	e09c                	sd	a5,0(s1)
ffffffffc0205648:	8522                	mv	a0,s0
ffffffffc020564a:	fb8ff0ef          	jal	ra,ffffffffc0204e02 <fd_array_release>
ffffffffc020564e:	60a6                	ld	ra,72(sp)
ffffffffc0205650:	6406                	ld	s0,64(sp)
ffffffffc0205652:	74e2                	ld	s1,56(sp)
ffffffffc0205654:	7942                	ld	s2,48(sp)
ffffffffc0205656:	854e                	mv	a0,s3
ffffffffc0205658:	79a2                	ld	s3,40(sp)
ffffffffc020565a:	6161                	addi	sp,sp,80
ffffffffc020565c:	8082                	ret
ffffffffc020565e:	60a6                	ld	ra,72(sp)
ffffffffc0205660:	6406                	ld	s0,64(sp)
ffffffffc0205662:	59f5                	li	s3,-3
ffffffffc0205664:	74e2                	ld	s1,56(sp)
ffffffffc0205666:	7942                	ld	s2,48(sp)
ffffffffc0205668:	854e                	mv	a0,s3
ffffffffc020566a:	79a2                	ld	s3,40(sp)
ffffffffc020566c:	6161                	addi	sp,sp,80
ffffffffc020566e:	8082                	ret
ffffffffc0205670:	00008697          	auipc	a3,0x8
ffffffffc0205674:	df068693          	addi	a3,a3,-528 # ffffffffc020d460 <default_pmm_manager+0x468>
ffffffffc0205678:	00006617          	auipc	a2,0x6
ffffffffc020567c:	4b060613          	addi	a2,a2,1200 # ffffffffc020bb28 <commands+0x250>
ffffffffc0205680:	14a00593          	li	a1,330
ffffffffc0205684:	00008517          	auipc	a0,0x8
ffffffffc0205688:	aec50513          	addi	a0,a0,-1300 # ffffffffc020d170 <default_pmm_manager+0x178>
ffffffffc020568c:	ba3fa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0205690:	e40ff0ef          	jal	ra,ffffffffc0204cd0 <get_fd_array.part.0>

ffffffffc0205694 <file_dup>:
ffffffffc0205694:	04700713          	li	a4,71
ffffffffc0205698:	06a76463          	bltu	a4,a0,ffffffffc0205700 <file_dup+0x6c>
ffffffffc020569c:	00091717          	auipc	a4,0x91
ffffffffc02056a0:	22473703          	ld	a4,548(a4) # ffffffffc02968c0 <current>
ffffffffc02056a4:	14873703          	ld	a4,328(a4)
ffffffffc02056a8:	1101                	addi	sp,sp,-32
ffffffffc02056aa:	ec06                	sd	ra,24(sp)
ffffffffc02056ac:	e822                	sd	s0,16(sp)
ffffffffc02056ae:	cb39                	beqz	a4,ffffffffc0205704 <file_dup+0x70>
ffffffffc02056b0:	4b14                	lw	a3,16(a4)
ffffffffc02056b2:	04d05963          	blez	a3,ffffffffc0205704 <file_dup+0x70>
ffffffffc02056b6:	6700                	ld	s0,8(a4)
ffffffffc02056b8:	00351713          	slli	a4,a0,0x3
ffffffffc02056bc:	8f09                	sub	a4,a4,a0
ffffffffc02056be:	070e                	slli	a4,a4,0x3
ffffffffc02056c0:	943a                	add	s0,s0,a4
ffffffffc02056c2:	4014                	lw	a3,0(s0)
ffffffffc02056c4:	4709                	li	a4,2
ffffffffc02056c6:	02e69863          	bne	a3,a4,ffffffffc02056f6 <file_dup+0x62>
ffffffffc02056ca:	4c18                	lw	a4,24(s0)
ffffffffc02056cc:	02a71563          	bne	a4,a0,ffffffffc02056f6 <file_dup+0x62>
ffffffffc02056d0:	852e                	mv	a0,a1
ffffffffc02056d2:	002c                	addi	a1,sp,8
ffffffffc02056d4:	e1eff0ef          	jal	ra,ffffffffc0204cf2 <fd_array_alloc>
ffffffffc02056d8:	c509                	beqz	a0,ffffffffc02056e2 <file_dup+0x4e>
ffffffffc02056da:	60e2                	ld	ra,24(sp)
ffffffffc02056dc:	6442                	ld	s0,16(sp)
ffffffffc02056de:	6105                	addi	sp,sp,32
ffffffffc02056e0:	8082                	ret
ffffffffc02056e2:	6522                	ld	a0,8(sp)
ffffffffc02056e4:	85a2                	mv	a1,s0
ffffffffc02056e6:	845ff0ef          	jal	ra,ffffffffc0204f2a <fd_array_dup>
ffffffffc02056ea:	67a2                	ld	a5,8(sp)
ffffffffc02056ec:	60e2                	ld	ra,24(sp)
ffffffffc02056ee:	6442                	ld	s0,16(sp)
ffffffffc02056f0:	4f88                	lw	a0,24(a5)
ffffffffc02056f2:	6105                	addi	sp,sp,32
ffffffffc02056f4:	8082                	ret
ffffffffc02056f6:	60e2                	ld	ra,24(sp)
ffffffffc02056f8:	6442                	ld	s0,16(sp)
ffffffffc02056fa:	5575                	li	a0,-3
ffffffffc02056fc:	6105                	addi	sp,sp,32
ffffffffc02056fe:	8082                	ret
ffffffffc0205700:	5575                	li	a0,-3
ffffffffc0205702:	8082                	ret
ffffffffc0205704:	dccff0ef          	jal	ra,ffffffffc0204cd0 <get_fd_array.part.0>

ffffffffc0205708 <iobuf_skip.part.0>:
ffffffffc0205708:	1141                	addi	sp,sp,-16
ffffffffc020570a:	00008697          	auipc	a3,0x8
ffffffffc020570e:	dee68693          	addi	a3,a3,-530 # ffffffffc020d4f8 <CSWTCH.79+0x18>
ffffffffc0205712:	00006617          	auipc	a2,0x6
ffffffffc0205716:	41660613          	addi	a2,a2,1046 # ffffffffc020bb28 <commands+0x250>
ffffffffc020571a:	04a00593          	li	a1,74
ffffffffc020571e:	00008517          	auipc	a0,0x8
ffffffffc0205722:	df250513          	addi	a0,a0,-526 # ffffffffc020d510 <CSWTCH.79+0x30>
ffffffffc0205726:	e406                	sd	ra,8(sp)
ffffffffc0205728:	b07fa0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020572c <iobuf_init>:
ffffffffc020572c:	e10c                	sd	a1,0(a0)
ffffffffc020572e:	e514                	sd	a3,8(a0)
ffffffffc0205730:	ed10                	sd	a2,24(a0)
ffffffffc0205732:	e910                	sd	a2,16(a0)
ffffffffc0205734:	8082                	ret

ffffffffc0205736 <iobuf_move>:
ffffffffc0205736:	7179                	addi	sp,sp,-48
ffffffffc0205738:	ec26                	sd	s1,24(sp)
ffffffffc020573a:	6d04                	ld	s1,24(a0)
ffffffffc020573c:	f022                	sd	s0,32(sp)
ffffffffc020573e:	e84a                	sd	s2,16(sp)
ffffffffc0205740:	e44e                	sd	s3,8(sp)
ffffffffc0205742:	f406                	sd	ra,40(sp)
ffffffffc0205744:	842a                	mv	s0,a0
ffffffffc0205746:	8932                	mv	s2,a2
ffffffffc0205748:	852e                	mv	a0,a1
ffffffffc020574a:	89ba                	mv	s3,a4
ffffffffc020574c:	00967363          	bgeu	a2,s1,ffffffffc0205752 <iobuf_move+0x1c>
ffffffffc0205750:	84b2                	mv	s1,a2
ffffffffc0205752:	c495                	beqz	s1,ffffffffc020577e <iobuf_move+0x48>
ffffffffc0205754:	600c                	ld	a1,0(s0)
ffffffffc0205756:	c681                	beqz	a3,ffffffffc020575e <iobuf_move+0x28>
ffffffffc0205758:	87ae                	mv	a5,a1
ffffffffc020575a:	85aa                	mv	a1,a0
ffffffffc020575c:	853e                	mv	a0,a5
ffffffffc020575e:	8626                	mv	a2,s1
ffffffffc0205760:	1e5050ef          	jal	ra,ffffffffc020b144 <memmove>
ffffffffc0205764:	6c1c                	ld	a5,24(s0)
ffffffffc0205766:	0297ea63          	bltu	a5,s1,ffffffffc020579a <iobuf_move+0x64>
ffffffffc020576a:	6014                	ld	a3,0(s0)
ffffffffc020576c:	6418                	ld	a4,8(s0)
ffffffffc020576e:	8f85                	sub	a5,a5,s1
ffffffffc0205770:	96a6                	add	a3,a3,s1
ffffffffc0205772:	9726                	add	a4,a4,s1
ffffffffc0205774:	e014                	sd	a3,0(s0)
ffffffffc0205776:	e418                	sd	a4,8(s0)
ffffffffc0205778:	ec1c                	sd	a5,24(s0)
ffffffffc020577a:	40990933          	sub	s2,s2,s1
ffffffffc020577e:	00098463          	beqz	s3,ffffffffc0205786 <iobuf_move+0x50>
ffffffffc0205782:	0099b023          	sd	s1,0(s3)
ffffffffc0205786:	4501                	li	a0,0
ffffffffc0205788:	00091b63          	bnez	s2,ffffffffc020579e <iobuf_move+0x68>
ffffffffc020578c:	70a2                	ld	ra,40(sp)
ffffffffc020578e:	7402                	ld	s0,32(sp)
ffffffffc0205790:	64e2                	ld	s1,24(sp)
ffffffffc0205792:	6942                	ld	s2,16(sp)
ffffffffc0205794:	69a2                	ld	s3,8(sp)
ffffffffc0205796:	6145                	addi	sp,sp,48
ffffffffc0205798:	8082                	ret
ffffffffc020579a:	f6fff0ef          	jal	ra,ffffffffc0205708 <iobuf_skip.part.0>
ffffffffc020579e:	5571                	li	a0,-4
ffffffffc02057a0:	b7f5                	j	ffffffffc020578c <iobuf_move+0x56>

ffffffffc02057a2 <iobuf_skip>:
ffffffffc02057a2:	6d1c                	ld	a5,24(a0)
ffffffffc02057a4:	00b7eb63          	bltu	a5,a1,ffffffffc02057ba <iobuf_skip+0x18>
ffffffffc02057a8:	6114                	ld	a3,0(a0)
ffffffffc02057aa:	6518                	ld	a4,8(a0)
ffffffffc02057ac:	8f8d                	sub	a5,a5,a1
ffffffffc02057ae:	96ae                	add	a3,a3,a1
ffffffffc02057b0:	95ba                	add	a1,a1,a4
ffffffffc02057b2:	e114                	sd	a3,0(a0)
ffffffffc02057b4:	e50c                	sd	a1,8(a0)
ffffffffc02057b6:	ed1c                	sd	a5,24(a0)
ffffffffc02057b8:	8082                	ret
ffffffffc02057ba:	1141                	addi	sp,sp,-16
ffffffffc02057bc:	e406                	sd	ra,8(sp)
ffffffffc02057be:	f4bff0ef          	jal	ra,ffffffffc0205708 <iobuf_skip.part.0>

ffffffffc02057c2 <fs_init>:
ffffffffc02057c2:	1141                	addi	sp,sp,-16
ffffffffc02057c4:	e406                	sd	ra,8(sp)
ffffffffc02057c6:	55b020ef          	jal	ra,ffffffffc0208520 <vfs_init>
ffffffffc02057ca:	792030ef          	jal	ra,ffffffffc0208f5c <dev_init>
ffffffffc02057ce:	60a2                	ld	ra,8(sp)
ffffffffc02057d0:	0141                	addi	sp,sp,16
ffffffffc02057d2:	7ca0306f          	j	ffffffffc0208f9c <sfs_init>

ffffffffc02057d6 <fs_cleanup>:
ffffffffc02057d6:	2840206f          	j	ffffffffc0207a5a <vfs_cleanup>

ffffffffc02057da <lock_files>:
ffffffffc02057da:	0561                	addi	a0,a0,24
ffffffffc02057dc:	f6ffe06f          	j	ffffffffc020474a <down>

ffffffffc02057e0 <unlock_files>:
ffffffffc02057e0:	0561                	addi	a0,a0,24
ffffffffc02057e2:	f65fe06f          	j	ffffffffc0204746 <up>

ffffffffc02057e6 <files_create>:
ffffffffc02057e6:	1141                	addi	sp,sp,-16
ffffffffc02057e8:	6505                	lui	a0,0x1
ffffffffc02057ea:	e022                	sd	s0,0(sp)
ffffffffc02057ec:	e406                	sd	ra,8(sp)
ffffffffc02057ee:	fd5fd0ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc02057f2:	842a                	mv	s0,a0
ffffffffc02057f4:	cd19                	beqz	a0,ffffffffc0205812 <files_create+0x2c>
ffffffffc02057f6:	03050793          	addi	a5,a0,48 # 1030 <_binary_bin_swap_img_size-0x6cd0>
ffffffffc02057fa:	00043023          	sd	zero,0(s0)
ffffffffc02057fe:	0561                	addi	a0,a0,24
ffffffffc0205800:	e41c                	sd	a5,8(s0)
ffffffffc0205802:	00042823          	sw	zero,16(s0)
ffffffffc0205806:	4585                	li	a1,1
ffffffffc0205808:	f37fe0ef          	jal	ra,ffffffffc020473e <sem_init>
ffffffffc020580c:	6408                	ld	a0,8(s0)
ffffffffc020580e:	e82ff0ef          	jal	ra,ffffffffc0204e90 <fd_array_init>
ffffffffc0205812:	60a2                	ld	ra,8(sp)
ffffffffc0205814:	8522                	mv	a0,s0
ffffffffc0205816:	6402                	ld	s0,0(sp)
ffffffffc0205818:	0141                	addi	sp,sp,16
ffffffffc020581a:	8082                	ret

ffffffffc020581c <files_destroy>:
ffffffffc020581c:	7179                	addi	sp,sp,-48
ffffffffc020581e:	f406                	sd	ra,40(sp)
ffffffffc0205820:	f022                	sd	s0,32(sp)
ffffffffc0205822:	ec26                	sd	s1,24(sp)
ffffffffc0205824:	e84a                	sd	s2,16(sp)
ffffffffc0205826:	e44e                	sd	s3,8(sp)
ffffffffc0205828:	c52d                	beqz	a0,ffffffffc0205892 <files_destroy+0x76>
ffffffffc020582a:	491c                	lw	a5,16(a0)
ffffffffc020582c:	89aa                	mv	s3,a0
ffffffffc020582e:	e3b5                	bnez	a5,ffffffffc0205892 <files_destroy+0x76>
ffffffffc0205830:	6108                	ld	a0,0(a0)
ffffffffc0205832:	c119                	beqz	a0,ffffffffc0205838 <files_destroy+0x1c>
ffffffffc0205834:	1c3020ef          	jal	ra,ffffffffc02081f6 <inode_ref_dec>
ffffffffc0205838:	0089b403          	ld	s0,8(s3)
ffffffffc020583c:	6485                	lui	s1,0x1
ffffffffc020583e:	fc048493          	addi	s1,s1,-64 # fc0 <_binary_bin_swap_img_size-0x6d40>
ffffffffc0205842:	94a2                	add	s1,s1,s0
ffffffffc0205844:	4909                	li	s2,2
ffffffffc0205846:	401c                	lw	a5,0(s0)
ffffffffc0205848:	03278063          	beq	a5,s2,ffffffffc0205868 <files_destroy+0x4c>
ffffffffc020584c:	e39d                	bnez	a5,ffffffffc0205872 <files_destroy+0x56>
ffffffffc020584e:	03840413          	addi	s0,s0,56
ffffffffc0205852:	fe849ae3          	bne	s1,s0,ffffffffc0205846 <files_destroy+0x2a>
ffffffffc0205856:	7402                	ld	s0,32(sp)
ffffffffc0205858:	70a2                	ld	ra,40(sp)
ffffffffc020585a:	64e2                	ld	s1,24(sp)
ffffffffc020585c:	6942                	ld	s2,16(sp)
ffffffffc020585e:	854e                	mv	a0,s3
ffffffffc0205860:	69a2                	ld	s3,8(sp)
ffffffffc0205862:	6145                	addi	sp,sp,48
ffffffffc0205864:	80efe06f          	j	ffffffffc0203872 <kfree>
ffffffffc0205868:	8522                	mv	a0,s0
ffffffffc020586a:	e42ff0ef          	jal	ra,ffffffffc0204eac <fd_array_close>
ffffffffc020586e:	401c                	lw	a5,0(s0)
ffffffffc0205870:	bff1                	j	ffffffffc020584c <files_destroy+0x30>
ffffffffc0205872:	00008697          	auipc	a3,0x8
ffffffffc0205876:	cee68693          	addi	a3,a3,-786 # ffffffffc020d560 <CSWTCH.79+0x80>
ffffffffc020587a:	00006617          	auipc	a2,0x6
ffffffffc020587e:	2ae60613          	addi	a2,a2,686 # ffffffffc020bb28 <commands+0x250>
ffffffffc0205882:	03d00593          	li	a1,61
ffffffffc0205886:	00008517          	auipc	a0,0x8
ffffffffc020588a:	cca50513          	addi	a0,a0,-822 # ffffffffc020d550 <CSWTCH.79+0x70>
ffffffffc020588e:	9a1fa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0205892:	00008697          	auipc	a3,0x8
ffffffffc0205896:	c8e68693          	addi	a3,a3,-882 # ffffffffc020d520 <CSWTCH.79+0x40>
ffffffffc020589a:	00006617          	auipc	a2,0x6
ffffffffc020589e:	28e60613          	addi	a2,a2,654 # ffffffffc020bb28 <commands+0x250>
ffffffffc02058a2:	03300593          	li	a1,51
ffffffffc02058a6:	00008517          	auipc	a0,0x8
ffffffffc02058aa:	caa50513          	addi	a0,a0,-854 # ffffffffc020d550 <CSWTCH.79+0x70>
ffffffffc02058ae:	981fa0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02058b2 <files_closeall>:
ffffffffc02058b2:	1101                	addi	sp,sp,-32
ffffffffc02058b4:	ec06                	sd	ra,24(sp)
ffffffffc02058b6:	e822                	sd	s0,16(sp)
ffffffffc02058b8:	e426                	sd	s1,8(sp)
ffffffffc02058ba:	e04a                	sd	s2,0(sp)
ffffffffc02058bc:	c129                	beqz	a0,ffffffffc02058fe <files_closeall+0x4c>
ffffffffc02058be:	491c                	lw	a5,16(a0)
ffffffffc02058c0:	02f05f63          	blez	a5,ffffffffc02058fe <files_closeall+0x4c>
ffffffffc02058c4:	6504                	ld	s1,8(a0)
ffffffffc02058c6:	6785                	lui	a5,0x1
ffffffffc02058c8:	fc078793          	addi	a5,a5,-64 # fc0 <_binary_bin_swap_img_size-0x6d40>
ffffffffc02058cc:	07048413          	addi	s0,s1,112
ffffffffc02058d0:	4909                	li	s2,2
ffffffffc02058d2:	94be                	add	s1,s1,a5
ffffffffc02058d4:	a029                	j	ffffffffc02058de <files_closeall+0x2c>
ffffffffc02058d6:	03840413          	addi	s0,s0,56
ffffffffc02058da:	00848c63          	beq	s1,s0,ffffffffc02058f2 <files_closeall+0x40>
ffffffffc02058de:	401c                	lw	a5,0(s0)
ffffffffc02058e0:	ff279be3          	bne	a5,s2,ffffffffc02058d6 <files_closeall+0x24>
ffffffffc02058e4:	8522                	mv	a0,s0
ffffffffc02058e6:	03840413          	addi	s0,s0,56
ffffffffc02058ea:	dc2ff0ef          	jal	ra,ffffffffc0204eac <fd_array_close>
ffffffffc02058ee:	fe8498e3          	bne	s1,s0,ffffffffc02058de <files_closeall+0x2c>
ffffffffc02058f2:	60e2                	ld	ra,24(sp)
ffffffffc02058f4:	6442                	ld	s0,16(sp)
ffffffffc02058f6:	64a2                	ld	s1,8(sp)
ffffffffc02058f8:	6902                	ld	s2,0(sp)
ffffffffc02058fa:	6105                	addi	sp,sp,32
ffffffffc02058fc:	8082                	ret
ffffffffc02058fe:	00008697          	auipc	a3,0x8
ffffffffc0205902:	84268693          	addi	a3,a3,-1982 # ffffffffc020d140 <default_pmm_manager+0x148>
ffffffffc0205906:	00006617          	auipc	a2,0x6
ffffffffc020590a:	22260613          	addi	a2,a2,546 # ffffffffc020bb28 <commands+0x250>
ffffffffc020590e:	04500593          	li	a1,69
ffffffffc0205912:	00008517          	auipc	a0,0x8
ffffffffc0205916:	c3e50513          	addi	a0,a0,-962 # ffffffffc020d550 <CSWTCH.79+0x70>
ffffffffc020591a:	915fa0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020591e <dup_files>:
ffffffffc020591e:	7179                	addi	sp,sp,-48
ffffffffc0205920:	f406                	sd	ra,40(sp)
ffffffffc0205922:	f022                	sd	s0,32(sp)
ffffffffc0205924:	ec26                	sd	s1,24(sp)
ffffffffc0205926:	e84a                	sd	s2,16(sp)
ffffffffc0205928:	e44e                	sd	s3,8(sp)
ffffffffc020592a:	e052                	sd	s4,0(sp)
ffffffffc020592c:	c52d                	beqz	a0,ffffffffc0205996 <dup_files+0x78>
ffffffffc020592e:	842e                	mv	s0,a1
ffffffffc0205930:	c1bd                	beqz	a1,ffffffffc0205996 <dup_files+0x78>
ffffffffc0205932:	491c                	lw	a5,16(a0)
ffffffffc0205934:	84aa                	mv	s1,a0
ffffffffc0205936:	e3c1                	bnez	a5,ffffffffc02059b6 <dup_files+0x98>
ffffffffc0205938:	499c                	lw	a5,16(a1)
ffffffffc020593a:	06f05e63          	blez	a5,ffffffffc02059b6 <dup_files+0x98>
ffffffffc020593e:	6188                	ld	a0,0(a1)
ffffffffc0205940:	e088                	sd	a0,0(s1)
ffffffffc0205942:	c119                	beqz	a0,ffffffffc0205948 <dup_files+0x2a>
ffffffffc0205944:	7e4020ef          	jal	ra,ffffffffc0208128 <inode_ref_inc>
ffffffffc0205948:	6400                	ld	s0,8(s0)
ffffffffc020594a:	6905                	lui	s2,0x1
ffffffffc020594c:	fc090913          	addi	s2,s2,-64 # fc0 <_binary_bin_swap_img_size-0x6d40>
ffffffffc0205950:	6484                	ld	s1,8(s1)
ffffffffc0205952:	9922                	add	s2,s2,s0
ffffffffc0205954:	4989                	li	s3,2
ffffffffc0205956:	4a05                	li	s4,1
ffffffffc0205958:	a039                	j	ffffffffc0205966 <dup_files+0x48>
ffffffffc020595a:	03840413          	addi	s0,s0,56
ffffffffc020595e:	03848493          	addi	s1,s1,56
ffffffffc0205962:	02890163          	beq	s2,s0,ffffffffc0205984 <dup_files+0x66>
ffffffffc0205966:	401c                	lw	a5,0(s0)
ffffffffc0205968:	ff3799e3          	bne	a5,s3,ffffffffc020595a <dup_files+0x3c>
ffffffffc020596c:	0144a023          	sw	s4,0(s1)
ffffffffc0205970:	85a2                	mv	a1,s0
ffffffffc0205972:	8526                	mv	a0,s1
ffffffffc0205974:	03840413          	addi	s0,s0,56
ffffffffc0205978:	db2ff0ef          	jal	ra,ffffffffc0204f2a <fd_array_dup>
ffffffffc020597c:	03848493          	addi	s1,s1,56
ffffffffc0205980:	fe8913e3          	bne	s2,s0,ffffffffc0205966 <dup_files+0x48>
ffffffffc0205984:	70a2                	ld	ra,40(sp)
ffffffffc0205986:	7402                	ld	s0,32(sp)
ffffffffc0205988:	64e2                	ld	s1,24(sp)
ffffffffc020598a:	6942                	ld	s2,16(sp)
ffffffffc020598c:	69a2                	ld	s3,8(sp)
ffffffffc020598e:	6a02                	ld	s4,0(sp)
ffffffffc0205990:	4501                	li	a0,0
ffffffffc0205992:	6145                	addi	sp,sp,48
ffffffffc0205994:	8082                	ret
ffffffffc0205996:	00007697          	auipc	a3,0x7
ffffffffc020599a:	08268693          	addi	a3,a3,130 # ffffffffc020ca18 <commands+0x1140>
ffffffffc020599e:	00006617          	auipc	a2,0x6
ffffffffc02059a2:	18a60613          	addi	a2,a2,394 # ffffffffc020bb28 <commands+0x250>
ffffffffc02059a6:	05300593          	li	a1,83
ffffffffc02059aa:	00008517          	auipc	a0,0x8
ffffffffc02059ae:	ba650513          	addi	a0,a0,-1114 # ffffffffc020d550 <CSWTCH.79+0x70>
ffffffffc02059b2:	87dfa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02059b6:	00008697          	auipc	a3,0x8
ffffffffc02059ba:	bc268693          	addi	a3,a3,-1086 # ffffffffc020d578 <CSWTCH.79+0x98>
ffffffffc02059be:	00006617          	auipc	a2,0x6
ffffffffc02059c2:	16a60613          	addi	a2,a2,362 # ffffffffc020bb28 <commands+0x250>
ffffffffc02059c6:	05400593          	li	a1,84
ffffffffc02059ca:	00008517          	auipc	a0,0x8
ffffffffc02059ce:	b8650513          	addi	a0,a0,-1146 # ffffffffc020d550 <CSWTCH.79+0x70>
ffffffffc02059d2:	85dfa0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02059d6 <kernel_thread_entry>:
ffffffffc02059d6:	8526                	mv	a0,s1
ffffffffc02059d8:	9402                	jalr	s0
ffffffffc02059da:	68a000ef          	jal	ra,ffffffffc0206064 <do_exit>

ffffffffc02059de <switch_to>:
ffffffffc02059de:	00153023          	sd	ra,0(a0)
ffffffffc02059e2:	00253423          	sd	sp,8(a0)
ffffffffc02059e6:	e900                	sd	s0,16(a0)
ffffffffc02059e8:	ed04                	sd	s1,24(a0)
ffffffffc02059ea:	03253023          	sd	s2,32(a0)
ffffffffc02059ee:	03353423          	sd	s3,40(a0)
ffffffffc02059f2:	03453823          	sd	s4,48(a0)
ffffffffc02059f6:	03553c23          	sd	s5,56(a0)
ffffffffc02059fa:	05653023          	sd	s6,64(a0)
ffffffffc02059fe:	05753423          	sd	s7,72(a0)
ffffffffc0205a02:	05853823          	sd	s8,80(a0)
ffffffffc0205a06:	05953c23          	sd	s9,88(a0)
ffffffffc0205a0a:	07a53023          	sd	s10,96(a0)
ffffffffc0205a0e:	07b53423          	sd	s11,104(a0)
ffffffffc0205a12:	0005b083          	ld	ra,0(a1)
ffffffffc0205a16:	0085b103          	ld	sp,8(a1)
ffffffffc0205a1a:	6980                	ld	s0,16(a1)
ffffffffc0205a1c:	6d84                	ld	s1,24(a1)
ffffffffc0205a1e:	0205b903          	ld	s2,32(a1)
ffffffffc0205a22:	0285b983          	ld	s3,40(a1)
ffffffffc0205a26:	0305ba03          	ld	s4,48(a1)
ffffffffc0205a2a:	0385ba83          	ld	s5,56(a1)
ffffffffc0205a2e:	0405bb03          	ld	s6,64(a1)
ffffffffc0205a32:	0485bb83          	ld	s7,72(a1)
ffffffffc0205a36:	0505bc03          	ld	s8,80(a1)
ffffffffc0205a3a:	0585bc83          	ld	s9,88(a1)
ffffffffc0205a3e:	0605bd03          	ld	s10,96(a1)
ffffffffc0205a42:	0685bd83          	ld	s11,104(a1)
ffffffffc0205a46:	8082                	ret

ffffffffc0205a48 <alloc_proc>:
ffffffffc0205a48:	1141                	addi	sp,sp,-16
ffffffffc0205a4a:	15000513          	li	a0,336
ffffffffc0205a4e:	e022                	sd	s0,0(sp)
ffffffffc0205a50:	e406                	sd	ra,8(sp)
ffffffffc0205a52:	d71fd0ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc0205a56:	842a                	mv	s0,a0
ffffffffc0205a58:	c141                	beqz	a0,ffffffffc0205ad8 <alloc_proc+0x90>
ffffffffc0205a5a:	57fd                	li	a5,-1
ffffffffc0205a5c:	1782                	slli	a5,a5,0x20
ffffffffc0205a5e:	e11c                	sd	a5,0(a0)
ffffffffc0205a60:	07000613          	li	a2,112
ffffffffc0205a64:	4581                	li	a1,0
ffffffffc0205a66:	00052423          	sw	zero,8(a0)
ffffffffc0205a6a:	00053823          	sd	zero,16(a0)
ffffffffc0205a6e:	00053c23          	sd	zero,24(a0)
ffffffffc0205a72:	02053023          	sd	zero,32(a0)
ffffffffc0205a76:	02053423          	sd	zero,40(a0)
ffffffffc0205a7a:	03050513          	addi	a0,a0,48
ffffffffc0205a7e:	6b4050ef          	jal	ra,ffffffffc020b132 <memset>
ffffffffc0205a82:	00091797          	auipc	a5,0x91
ffffffffc0205a86:	e067b783          	ld	a5,-506(a5) # ffffffffc0296888 <boot_pgdir_pa>
ffffffffc0205a8a:	f45c                	sd	a5,168(s0)
ffffffffc0205a8c:	0a043023          	sd	zero,160(s0)
ffffffffc0205a90:	0a042823          	sw	zero,176(s0)
ffffffffc0205a94:	463d                	li	a2,15
ffffffffc0205a96:	4581                	li	a1,0
ffffffffc0205a98:	0b440513          	addi	a0,s0,180
ffffffffc0205a9c:	696050ef          	jal	ra,ffffffffc020b132 <memset>
ffffffffc0205aa0:	11040793          	addi	a5,s0,272
ffffffffc0205aa4:	0e042623          	sw	zero,236(s0)
ffffffffc0205aa8:	0e043c23          	sd	zero,248(s0)
ffffffffc0205aac:	10043023          	sd	zero,256(s0)
ffffffffc0205ab0:	0e043823          	sd	zero,240(s0)
ffffffffc0205ab4:	10043423          	sd	zero,264(s0)
ffffffffc0205ab8:	10f43c23          	sd	a5,280(s0)
ffffffffc0205abc:	10f43823          	sd	a5,272(s0)
ffffffffc0205ac0:	12042023          	sw	zero,288(s0)
ffffffffc0205ac4:	12043423          	sd	zero,296(s0)
ffffffffc0205ac8:	12043823          	sd	zero,304(s0)
ffffffffc0205acc:	12043c23          	sd	zero,312(s0)
ffffffffc0205ad0:	14043023          	sd	zero,320(s0)
ffffffffc0205ad4:	14043423          	sd	zero,328(s0)
ffffffffc0205ad8:	60a2                	ld	ra,8(sp)
ffffffffc0205ada:	8522                	mv	a0,s0
ffffffffc0205adc:	6402                	ld	s0,0(sp)
ffffffffc0205ade:	0141                	addi	sp,sp,16
ffffffffc0205ae0:	8082                	ret

ffffffffc0205ae2 <forkret>:
ffffffffc0205ae2:	00091797          	auipc	a5,0x91
ffffffffc0205ae6:	dde7b783          	ld	a5,-546(a5) # ffffffffc02968c0 <current>
ffffffffc0205aea:	73c8                	ld	a0,160(a5)
ffffffffc0205aec:	fc2fb06f          	j	ffffffffc02012ae <forkrets>

ffffffffc0205af0 <pa2page.part.0>:
ffffffffc0205af0:	1141                	addi	sp,sp,-16
ffffffffc0205af2:	00006617          	auipc	a2,0x6
ffffffffc0205af6:	6f660613          	addi	a2,a2,1782 # ffffffffc020c1e8 <commands+0x910>
ffffffffc0205afa:	06900593          	li	a1,105
ffffffffc0205afe:	00006517          	auipc	a0,0x6
ffffffffc0205b02:	70a50513          	addi	a0,a0,1802 # ffffffffc020c208 <commands+0x930>
ffffffffc0205b06:	e406                	sd	ra,8(sp)
ffffffffc0205b08:	f26fa0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0205b0c <put_pgdir.isra.0>:
ffffffffc0205b0c:	1141                	addi	sp,sp,-16
ffffffffc0205b0e:	e406                	sd	ra,8(sp)
ffffffffc0205b10:	c02007b7          	lui	a5,0xc0200
ffffffffc0205b14:	02f56e63          	bltu	a0,a5,ffffffffc0205b50 <put_pgdir.isra.0+0x44>
ffffffffc0205b18:	00091697          	auipc	a3,0x91
ffffffffc0205b1c:	d986b683          	ld	a3,-616(a3) # ffffffffc02968b0 <va_pa_offset>
ffffffffc0205b20:	8d15                	sub	a0,a0,a3
ffffffffc0205b22:	8131                	srli	a0,a0,0xc
ffffffffc0205b24:	00091797          	auipc	a5,0x91
ffffffffc0205b28:	d747b783          	ld	a5,-652(a5) # ffffffffc0296898 <npage>
ffffffffc0205b2c:	02f57f63          	bgeu	a0,a5,ffffffffc0205b6a <put_pgdir.isra.0+0x5e>
ffffffffc0205b30:	0000a697          	auipc	a3,0xa
ffffffffc0205b34:	dc06b683          	ld	a3,-576(a3) # ffffffffc020f8f0 <nbase>
ffffffffc0205b38:	60a2                	ld	ra,8(sp)
ffffffffc0205b3a:	8d15                	sub	a0,a0,a3
ffffffffc0205b3c:	00091797          	auipc	a5,0x91
ffffffffc0205b40:	d647b783          	ld	a5,-668(a5) # ffffffffc02968a0 <pages>
ffffffffc0205b44:	051a                	slli	a0,a0,0x6
ffffffffc0205b46:	4585                	li	a1,1
ffffffffc0205b48:	953e                	add	a0,a0,a5
ffffffffc0205b4a:	0141                	addi	sp,sp,16
ffffffffc0205b4c:	fdcfb06f          	j	ffffffffc0201328 <free_pages>
ffffffffc0205b50:	86aa                	mv	a3,a0
ffffffffc0205b52:	00007617          	auipc	a2,0x7
ffffffffc0205b56:	80e60613          	addi	a2,a2,-2034 # ffffffffc020c360 <commands+0xa88>
ffffffffc0205b5a:	07700593          	li	a1,119
ffffffffc0205b5e:	00006517          	auipc	a0,0x6
ffffffffc0205b62:	6aa50513          	addi	a0,a0,1706 # ffffffffc020c208 <commands+0x930>
ffffffffc0205b66:	ec8fa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0205b6a:	f87ff0ef          	jal	ra,ffffffffc0205af0 <pa2page.part.0>

ffffffffc0205b6e <proc_run>:
ffffffffc0205b6e:	7179                	addi	sp,sp,-48
ffffffffc0205b70:	f026                	sd	s1,32(sp)
ffffffffc0205b72:	00091497          	auipc	s1,0x91
ffffffffc0205b76:	d4e48493          	addi	s1,s1,-690 # ffffffffc02968c0 <current>
ffffffffc0205b7a:	6098                	ld	a4,0(s1)
ffffffffc0205b7c:	f406                	sd	ra,40(sp)
ffffffffc0205b7e:	ec4a                	sd	s2,24(sp)
ffffffffc0205b80:	02a70963          	beq	a4,a0,ffffffffc0205bb2 <proc_run+0x44>
ffffffffc0205b84:	100027f3          	csrr	a5,sstatus
ffffffffc0205b88:	8b89                	andi	a5,a5,2
ffffffffc0205b8a:	4901                	li	s2,0
ffffffffc0205b8c:	ef95                	bnez	a5,ffffffffc0205bc8 <proc_run+0x5a>
ffffffffc0205b8e:	755c                	ld	a5,168(a0)
ffffffffc0205b90:	56fd                	li	a3,-1
ffffffffc0205b92:	16fe                	slli	a3,a3,0x3f
ffffffffc0205b94:	83b1                	srli	a5,a5,0xc
ffffffffc0205b96:	e088                	sd	a0,0(s1)
ffffffffc0205b98:	8fd5                	or	a5,a5,a3
ffffffffc0205b9a:	18079073          	csrw	satp,a5
ffffffffc0205b9e:	12000073          	sfence.vma
ffffffffc0205ba2:	03050593          	addi	a1,a0,48
ffffffffc0205ba6:	03070513          	addi	a0,a4,48
ffffffffc0205baa:	e35ff0ef          	jal	ra,ffffffffc02059de <switch_to>
ffffffffc0205bae:	00091763          	bnez	s2,ffffffffc0205bbc <proc_run+0x4e>
ffffffffc0205bb2:	70a2                	ld	ra,40(sp)
ffffffffc0205bb4:	7482                	ld	s1,32(sp)
ffffffffc0205bb6:	6962                	ld	s2,24(sp)
ffffffffc0205bb8:	6145                	addi	sp,sp,48
ffffffffc0205bba:	8082                	ret
ffffffffc0205bbc:	70a2                	ld	ra,40(sp)
ffffffffc0205bbe:	7482                	ld	s1,32(sp)
ffffffffc0205bc0:	6962                	ld	s2,24(sp)
ffffffffc0205bc2:	6145                	addi	sp,sp,48
ffffffffc0205bc4:	9d6fb06f          	j	ffffffffc0200d9a <intr_enable>
ffffffffc0205bc8:	e42a                	sd	a0,8(sp)
ffffffffc0205bca:	9d6fb0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0205bce:	6098                	ld	a4,0(s1)
ffffffffc0205bd0:	6522                	ld	a0,8(sp)
ffffffffc0205bd2:	4905                	li	s2,1
ffffffffc0205bd4:	bf6d                	j	ffffffffc0205b8e <proc_run+0x20>

ffffffffc0205bd6 <do_fork>:
ffffffffc0205bd6:	7119                	addi	sp,sp,-128
ffffffffc0205bd8:	f0ca                	sd	s2,96(sp)
ffffffffc0205bda:	00091917          	auipc	s2,0x91
ffffffffc0205bde:	cfe90913          	addi	s2,s2,-770 # ffffffffc02968d8 <nr_process>
ffffffffc0205be2:	00092783          	lw	a5,0(s2)
ffffffffc0205be6:	ecce                	sd	s3,88(sp)
ffffffffc0205be8:	fc86                	sd	ra,120(sp)
ffffffffc0205bea:	f8a2                	sd	s0,112(sp)
ffffffffc0205bec:	f4a6                	sd	s1,104(sp)
ffffffffc0205bee:	e8d2                	sd	s4,80(sp)
ffffffffc0205bf0:	e4d6                	sd	s5,72(sp)
ffffffffc0205bf2:	e0da                	sd	s6,64(sp)
ffffffffc0205bf4:	fc5e                	sd	s7,56(sp)
ffffffffc0205bf6:	f862                	sd	s8,48(sp)
ffffffffc0205bf8:	f466                	sd	s9,40(sp)
ffffffffc0205bfa:	f06a                	sd	s10,32(sp)
ffffffffc0205bfc:	ec6e                	sd	s11,24(sp)
ffffffffc0205bfe:	6985                	lui	s3,0x1
ffffffffc0205c00:	3537d963          	bge	a5,s3,ffffffffc0205f52 <do_fork+0x37c>
ffffffffc0205c04:	8a2a                	mv	s4,a0
ffffffffc0205c06:	8aae                	mv	s5,a1
ffffffffc0205c08:	84b2                	mv	s1,a2
ffffffffc0205c0a:	e3fff0ef          	jal	ra,ffffffffc0205a48 <alloc_proc>
ffffffffc0205c0e:	842a                	mv	s0,a0
ffffffffc0205c10:	36050363          	beqz	a0,ffffffffc0205f76 <do_fork+0x3a0>
ffffffffc0205c14:	00091c97          	auipc	s9,0x91
ffffffffc0205c18:	cacc8c93          	addi	s9,s9,-852 # ffffffffc02968c0 <current>
ffffffffc0205c1c:	000cb783          	ld	a5,0(s9)
ffffffffc0205c20:	0ec7a703          	lw	a4,236(a5)
ffffffffc0205c24:	f11c                	sd	a5,32(a0)
ffffffffc0205c26:	36071163          	bnez	a4,ffffffffc0205f88 <do_fork+0x3b2>
ffffffffc0205c2a:	4509                	li	a0,2
ffffffffc0205c2c:	ebefb0ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0205c30:	30050b63          	beqz	a0,ffffffffc0205f46 <do_fork+0x370>
ffffffffc0205c34:	00091c17          	auipc	s8,0x91
ffffffffc0205c38:	c6cc0c13          	addi	s8,s8,-916 # ffffffffc02968a0 <pages>
ffffffffc0205c3c:	000c3683          	ld	a3,0(s8)
ffffffffc0205c40:	0000ab97          	auipc	s7,0xa
ffffffffc0205c44:	cb0bbb83          	ld	s7,-848(s7) # ffffffffc020f8f0 <nbase>
ffffffffc0205c48:	00091d17          	auipc	s10,0x91
ffffffffc0205c4c:	c50d0d13          	addi	s10,s10,-944 # ffffffffc0296898 <npage>
ffffffffc0205c50:	40d506b3          	sub	a3,a0,a3
ffffffffc0205c54:	8699                	srai	a3,a3,0x6
ffffffffc0205c56:	96de                	add	a3,a3,s7
ffffffffc0205c58:	000d3703          	ld	a4,0(s10)
ffffffffc0205c5c:	00c69793          	slli	a5,a3,0xc
ffffffffc0205c60:	83b1                	srli	a5,a5,0xc
ffffffffc0205c62:	06b2                	slli	a3,a3,0xc
ffffffffc0205c64:	34e7f263          	bgeu	a5,a4,ffffffffc0205fa8 <do_fork+0x3d2>
ffffffffc0205c68:	000cb703          	ld	a4,0(s9)
ffffffffc0205c6c:	00091d97          	auipc	s11,0x91
ffffffffc0205c70:	c44d8d93          	addi	s11,s11,-956 # ffffffffc02968b0 <va_pa_offset>
ffffffffc0205c74:	000db783          	ld	a5,0(s11)
ffffffffc0205c78:	14873b03          	ld	s6,328(a4)
ffffffffc0205c7c:	96be                	add	a3,a3,a5
ffffffffc0205c7e:	e814                	sd	a3,16(s0)
ffffffffc0205c80:	340b0063          	beqz	s6,ffffffffc0205fc0 <do_fork+0x3ea>
ffffffffc0205c84:	80098993          	addi	s3,s3,-2048 # 800 <_binary_bin_swap_img_size-0x7500>
ffffffffc0205c88:	013a79b3          	and	s3,s4,s3
ffffffffc0205c8c:	10098363          	beqz	s3,ffffffffc0205d92 <do_fork+0x1bc>
ffffffffc0205c90:	010b2783          	lw	a5,16(s6)
ffffffffc0205c94:	7718                	ld	a4,40(a4)
ffffffffc0205c96:	2785                	addiw	a5,a5,1
ffffffffc0205c98:	00fb2823          	sw	a5,16(s6)
ffffffffc0205c9c:	15643423          	sd	s6,328(s0)
ffffffffc0205ca0:	c315                	beqz	a4,ffffffffc0205cc4 <do_fork+0xee>
ffffffffc0205ca2:	100a7a13          	andi	s4,s4,256
ffffffffc0205ca6:	100a0663          	beqz	s4,ffffffffc0205db2 <do_fork+0x1dc>
ffffffffc0205caa:	5b1c                	lw	a5,48(a4)
ffffffffc0205cac:	6f14                	ld	a3,24(a4)
ffffffffc0205cae:	c0200637          	lui	a2,0xc0200
ffffffffc0205cb2:	2785                	addiw	a5,a5,1
ffffffffc0205cb4:	db1c                	sw	a5,48(a4)
ffffffffc0205cb6:	f418                	sd	a4,40(s0)
ffffffffc0205cb8:	34c6e263          	bltu	a3,a2,ffffffffc0205ffc <do_fork+0x426>
ffffffffc0205cbc:	000db783          	ld	a5,0(s11)
ffffffffc0205cc0:	8e9d                	sub	a3,a3,a5
ffffffffc0205cc2:	f454                	sd	a3,168(s0)
ffffffffc0205cc4:	6818                	ld	a4,16(s0)
ffffffffc0205cc6:	6789                	lui	a5,0x2
ffffffffc0205cc8:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_bin_swap_img_size-0x5e20>
ffffffffc0205ccc:	973e                	add	a4,a4,a5
ffffffffc0205cce:	f058                	sd	a4,160(s0)
ffffffffc0205cd0:	87ba                	mv	a5,a4
ffffffffc0205cd2:	12048813          	addi	a6,s1,288
ffffffffc0205cd6:	6088                	ld	a0,0(s1)
ffffffffc0205cd8:	648c                	ld	a1,8(s1)
ffffffffc0205cda:	6890                	ld	a2,16(s1)
ffffffffc0205cdc:	6c94                	ld	a3,24(s1)
ffffffffc0205cde:	e388                	sd	a0,0(a5)
ffffffffc0205ce0:	e78c                	sd	a1,8(a5)
ffffffffc0205ce2:	eb90                	sd	a2,16(a5)
ffffffffc0205ce4:	ef94                	sd	a3,24(a5)
ffffffffc0205ce6:	02048493          	addi	s1,s1,32
ffffffffc0205cea:	02078793          	addi	a5,a5,32
ffffffffc0205cee:	ff0494e3          	bne	s1,a6,ffffffffc0205cd6 <do_fork+0x100>
ffffffffc0205cf2:	04073823          	sd	zero,80(a4)
ffffffffc0205cf6:	000a9363          	bnez	s5,ffffffffc0205cfc <do_fork+0x126>
ffffffffc0205cfa:	8aba                	mv	s5,a4
ffffffffc0205cfc:	01573823          	sd	s5,16(a4)
ffffffffc0205d00:	00000797          	auipc	a5,0x0
ffffffffc0205d04:	de278793          	addi	a5,a5,-542 # ffffffffc0205ae2 <forkret>
ffffffffc0205d08:	f81c                	sd	a5,48(s0)
ffffffffc0205d0a:	fc18                	sd	a4,56(s0)
ffffffffc0205d0c:	100027f3          	csrr	a5,sstatus
ffffffffc0205d10:	8b89                	andi	a5,a5,2
ffffffffc0205d12:	4981                	li	s3,0
ffffffffc0205d14:	22079b63          	bnez	a5,ffffffffc0205f4a <do_fork+0x374>
ffffffffc0205d18:	0008b817          	auipc	a6,0x8b
ffffffffc0205d1c:	34080813          	addi	a6,a6,832 # ffffffffc0291058 <last_pid.1>
ffffffffc0205d20:	00082783          	lw	a5,0(a6)
ffffffffc0205d24:	6709                	lui	a4,0x2
ffffffffc0205d26:	0017851b          	addiw	a0,a5,1
ffffffffc0205d2a:	00a82023          	sw	a0,0(a6)
ffffffffc0205d2e:	18e55f63          	bge	a0,a4,ffffffffc0205ecc <do_fork+0x2f6>
ffffffffc0205d32:	0008b317          	auipc	t1,0x8b
ffffffffc0205d36:	32a30313          	addi	t1,t1,810 # ffffffffc029105c <next_safe.0>
ffffffffc0205d3a:	00032783          	lw	a5,0(t1)
ffffffffc0205d3e:	00090497          	auipc	s1,0x90
ffffffffc0205d42:	a8248493          	addi	s1,s1,-1406 # ffffffffc02957c0 <proc_list>
ffffffffc0205d46:	10f54263          	blt	a0,a5,ffffffffc0205e4a <do_fork+0x274>
ffffffffc0205d4a:	00090497          	auipc	s1,0x90
ffffffffc0205d4e:	a7648493          	addi	s1,s1,-1418 # ffffffffc02957c0 <proc_list>
ffffffffc0205d52:	0084be03          	ld	t3,8(s1)
ffffffffc0205d56:	6789                	lui	a5,0x2
ffffffffc0205d58:	00f32023          	sw	a5,0(t1)
ffffffffc0205d5c:	86aa                	mv	a3,a0
ffffffffc0205d5e:	4581                	li	a1,0
ffffffffc0205d60:	6e89                	lui	t4,0x2
ffffffffc0205d62:	1e9e0a63          	beq	t3,s1,ffffffffc0205f56 <do_fork+0x380>
ffffffffc0205d66:	88ae                	mv	a7,a1
ffffffffc0205d68:	87f2                	mv	a5,t3
ffffffffc0205d6a:	6609                	lui	a2,0x2
ffffffffc0205d6c:	a811                	j	ffffffffc0205d80 <do_fork+0x1aa>
ffffffffc0205d6e:	00e6d663          	bge	a3,a4,ffffffffc0205d7a <do_fork+0x1a4>
ffffffffc0205d72:	00c75463          	bge	a4,a2,ffffffffc0205d7a <do_fork+0x1a4>
ffffffffc0205d76:	863a                	mv	a2,a4
ffffffffc0205d78:	4885                	li	a7,1
ffffffffc0205d7a:	679c                	ld	a5,8(a5)
ffffffffc0205d7c:	0a978f63          	beq	a5,s1,ffffffffc0205e3a <do_fork+0x264>
ffffffffc0205d80:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_bin_swap_img_size-0x5dc4>
ffffffffc0205d84:	fed715e3          	bne	a4,a3,ffffffffc0205d6e <do_fork+0x198>
ffffffffc0205d88:	2685                	addiw	a3,a3,1
ffffffffc0205d8a:	1ac6d963          	bge	a3,a2,ffffffffc0205f3c <do_fork+0x366>
ffffffffc0205d8e:	4585                	li	a1,1
ffffffffc0205d90:	b7ed                	j	ffffffffc0205d7a <do_fork+0x1a4>
ffffffffc0205d92:	a55ff0ef          	jal	ra,ffffffffc02057e6 <files_create>
ffffffffc0205d96:	e42a                	sd	a0,8(sp)
ffffffffc0205d98:	1e050163          	beqz	a0,ffffffffc0205f7a <do_fork+0x3a4>
ffffffffc0205d9c:	85da                	mv	a1,s6
ffffffffc0205d9e:	b81ff0ef          	jal	ra,ffffffffc020591e <dup_files>
ffffffffc0205da2:	67a2                	ld	a5,8(sp)
ffffffffc0205da4:	89aa                	mv	s3,a0
ffffffffc0205da6:	12051f63          	bnez	a0,ffffffffc0205ee4 <do_fork+0x30e>
ffffffffc0205daa:	000cb703          	ld	a4,0(s9)
ffffffffc0205dae:	8b3e                	mv	s6,a5
ffffffffc0205db0:	b5c5                	j	ffffffffc0205c90 <do_fork+0xba>
ffffffffc0205db2:	e43a                	sd	a4,8(sp)
ffffffffc0205db4:	fd3fc0ef          	jal	ra,ffffffffc0202d86 <mm_create>
ffffffffc0205db8:	8a2a                	mv	s4,a0
ffffffffc0205dba:	1c050563          	beqz	a0,ffffffffc0205f84 <do_fork+0x3ae>
ffffffffc0205dbe:	4505                	li	a0,1
ffffffffc0205dc0:	d2afb0ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0205dc4:	14050d63          	beqz	a0,ffffffffc0205f1e <do_fork+0x348>
ffffffffc0205dc8:	000c3683          	ld	a3,0(s8)
ffffffffc0205dcc:	000d3603          	ld	a2,0(s10)
ffffffffc0205dd0:	6722                	ld	a4,8(sp)
ffffffffc0205dd2:	40d506b3          	sub	a3,a0,a3
ffffffffc0205dd6:	8699                	srai	a3,a3,0x6
ffffffffc0205dd8:	96de                	add	a3,a3,s7
ffffffffc0205dda:	00c69793          	slli	a5,a3,0xc
ffffffffc0205dde:	83b1                	srli	a5,a5,0xc
ffffffffc0205de0:	06b2                	slli	a3,a3,0xc
ffffffffc0205de2:	1cc7f363          	bgeu	a5,a2,ffffffffc0205fa8 <do_fork+0x3d2>
ffffffffc0205de6:	000db983          	ld	s3,0(s11)
ffffffffc0205dea:	6605                	lui	a2,0x1
ffffffffc0205dec:	00091597          	auipc	a1,0x91
ffffffffc0205df0:	aa45b583          	ld	a1,-1372(a1) # ffffffffc0296890 <boot_pgdir_va>
ffffffffc0205df4:	99b6                	add	s3,s3,a3
ffffffffc0205df6:	854e                	mv	a0,s3
ffffffffc0205df8:	e43a                	sd	a4,8(sp)
ffffffffc0205dfa:	38a050ef          	jal	ra,ffffffffc020b184 <memcpy>
ffffffffc0205dfe:	6722                	ld	a4,8(sp)
ffffffffc0205e00:	013a3c23          	sd	s3,24(s4)
ffffffffc0205e04:	03870b13          	addi	s6,a4,56 # 2038 <_binary_bin_swap_img_size-0x5cc8>
ffffffffc0205e08:	855a                	mv	a0,s6
ffffffffc0205e0a:	941fe0ef          	jal	ra,ffffffffc020474a <down>
ffffffffc0205e0e:	000cb783          	ld	a5,0(s9)
ffffffffc0205e12:	6722                	ld	a4,8(sp)
ffffffffc0205e14:	c399                	beqz	a5,ffffffffc0205e1a <do_fork+0x244>
ffffffffc0205e16:	43dc                	lw	a5,4(a5)
ffffffffc0205e18:	cb3c                	sw	a5,80(a4)
ffffffffc0205e1a:	85ba                	mv	a1,a4
ffffffffc0205e1c:	8552                	mv	a0,s4
ffffffffc0205e1e:	e43a                	sd	a4,8(sp)
ffffffffc0205e20:	9b6fd0ef          	jal	ra,ffffffffc0202fd6 <dup_mmap>
ffffffffc0205e24:	89aa                	mv	s3,a0
ffffffffc0205e26:	855a                	mv	a0,s6
ffffffffc0205e28:	91ffe0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc0205e2c:	6722                	ld	a4,8(sp)
ffffffffc0205e2e:	04072823          	sw	zero,80(a4)
ffffffffc0205e32:	12099763          	bnez	s3,ffffffffc0205f60 <do_fork+0x38a>
ffffffffc0205e36:	8752                	mv	a4,s4
ffffffffc0205e38:	bd8d                	j	ffffffffc0205caa <do_fork+0xd4>
ffffffffc0205e3a:	c581                	beqz	a1,ffffffffc0205e42 <do_fork+0x26c>
ffffffffc0205e3c:	00d82023          	sw	a3,0(a6)
ffffffffc0205e40:	8536                	mv	a0,a3
ffffffffc0205e42:	00088463          	beqz	a7,ffffffffc0205e4a <do_fork+0x274>
ffffffffc0205e46:	00c32023          	sw	a2,0(t1)
ffffffffc0205e4a:	c048                	sw	a0,4(s0)
ffffffffc0205e4c:	45a9                	li	a1,10
ffffffffc0205e4e:	2501                	sext.w	a0,a0
ffffffffc0205e50:	7c8050ef          	jal	ra,ffffffffc020b618 <hash32>
ffffffffc0205e54:	02051793          	slli	a5,a0,0x20
ffffffffc0205e58:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205e5c:	0008c797          	auipc	a5,0x8c
ffffffffc0205e60:	96478793          	addi	a5,a5,-1692 # ffffffffc02917c0 <hash_list>
ffffffffc0205e64:	953e                	add	a0,a0,a5
ffffffffc0205e66:	650c                	ld	a1,8(a0)
ffffffffc0205e68:	7014                	ld	a3,32(s0)
ffffffffc0205e6a:	0d840793          	addi	a5,s0,216
ffffffffc0205e6e:	e19c                	sd	a5,0(a1)
ffffffffc0205e70:	6490                	ld	a2,8(s1)
ffffffffc0205e72:	e51c                	sd	a5,8(a0)
ffffffffc0205e74:	7af8                	ld	a4,240(a3)
ffffffffc0205e76:	0c840793          	addi	a5,s0,200
ffffffffc0205e7a:	f06c                	sd	a1,224(s0)
ffffffffc0205e7c:	ec68                	sd	a0,216(s0)
ffffffffc0205e7e:	e21c                	sd	a5,0(a2)
ffffffffc0205e80:	e49c                	sd	a5,8(s1)
ffffffffc0205e82:	e870                	sd	a2,208(s0)
ffffffffc0205e84:	e464                	sd	s1,200(s0)
ffffffffc0205e86:	0e043c23          	sd	zero,248(s0)
ffffffffc0205e8a:	10e43023          	sd	a4,256(s0)
ffffffffc0205e8e:	c311                	beqz	a4,ffffffffc0205e92 <do_fork+0x2bc>
ffffffffc0205e90:	ff60                	sd	s0,248(a4)
ffffffffc0205e92:	00092783          	lw	a5,0(s2)
ffffffffc0205e96:	fae0                	sd	s0,240(a3)
ffffffffc0205e98:	2785                	addiw	a5,a5,1
ffffffffc0205e9a:	00f92023          	sw	a5,0(s2)
ffffffffc0205e9e:	04099063          	bnez	s3,ffffffffc0205ede <do_fork+0x308>
ffffffffc0205ea2:	8522                	mv	a0,s0
ffffffffc0205ea4:	412010ef          	jal	ra,ffffffffc02072b6 <wakeup_proc>
ffffffffc0205ea8:	00442983          	lw	s3,4(s0)
ffffffffc0205eac:	70e6                	ld	ra,120(sp)
ffffffffc0205eae:	7446                	ld	s0,112(sp)
ffffffffc0205eb0:	74a6                	ld	s1,104(sp)
ffffffffc0205eb2:	7906                	ld	s2,96(sp)
ffffffffc0205eb4:	6a46                	ld	s4,80(sp)
ffffffffc0205eb6:	6aa6                	ld	s5,72(sp)
ffffffffc0205eb8:	6b06                	ld	s6,64(sp)
ffffffffc0205eba:	7be2                	ld	s7,56(sp)
ffffffffc0205ebc:	7c42                	ld	s8,48(sp)
ffffffffc0205ebe:	7ca2                	ld	s9,40(sp)
ffffffffc0205ec0:	7d02                	ld	s10,32(sp)
ffffffffc0205ec2:	6de2                	ld	s11,24(sp)
ffffffffc0205ec4:	854e                	mv	a0,s3
ffffffffc0205ec6:	69e6                	ld	s3,88(sp)
ffffffffc0205ec8:	6109                	addi	sp,sp,128
ffffffffc0205eca:	8082                	ret
ffffffffc0205ecc:	4785                	li	a5,1
ffffffffc0205ece:	00f82023          	sw	a5,0(a6)
ffffffffc0205ed2:	4505                	li	a0,1
ffffffffc0205ed4:	0008b317          	auipc	t1,0x8b
ffffffffc0205ed8:	18830313          	addi	t1,t1,392 # ffffffffc029105c <next_safe.0>
ffffffffc0205edc:	b5bd                	j	ffffffffc0205d4a <do_fork+0x174>
ffffffffc0205ede:	ebdfa0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0205ee2:	b7c1                	j	ffffffffc0205ea2 <do_fork+0x2cc>
ffffffffc0205ee4:	853e                	mv	a0,a5
ffffffffc0205ee6:	937ff0ef          	jal	ra,ffffffffc020581c <files_destroy>
ffffffffc0205eea:	6814                	ld	a3,16(s0)
ffffffffc0205eec:	c02007b7          	lui	a5,0xc0200
ffffffffc0205ef0:	0ef6ea63          	bltu	a3,a5,ffffffffc0205fe4 <do_fork+0x40e>
ffffffffc0205ef4:	000db703          	ld	a4,0(s11)
ffffffffc0205ef8:	000d3783          	ld	a5,0(s10)
ffffffffc0205efc:	8e99                	sub	a3,a3,a4
ffffffffc0205efe:	82b1                	srli	a3,a3,0xc
ffffffffc0205f00:	0ef6f063          	bgeu	a3,a5,ffffffffc0205fe0 <do_fork+0x40a>
ffffffffc0205f04:	000c3503          	ld	a0,0(s8)
ffffffffc0205f08:	417686b3          	sub	a3,a3,s7
ffffffffc0205f0c:	069a                	slli	a3,a3,0x6
ffffffffc0205f0e:	4589                	li	a1,2
ffffffffc0205f10:	9536                	add	a0,a0,a3
ffffffffc0205f12:	c16fb0ef          	jal	ra,ffffffffc0201328 <free_pages>
ffffffffc0205f16:	8522                	mv	a0,s0
ffffffffc0205f18:	95bfd0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc0205f1c:	bf41                	j	ffffffffc0205eac <do_fork+0x2d6>
ffffffffc0205f1e:	8552                	mv	a0,s4
ffffffffc0205f20:	fb5fc0ef          	jal	ra,ffffffffc0202ed4 <mm_destroy>
ffffffffc0205f24:	59f1                	li	s3,-4
ffffffffc0205f26:	14843503          	ld	a0,328(s0)
ffffffffc0205f2a:	d161                	beqz	a0,ffffffffc0205eea <do_fork+0x314>
ffffffffc0205f2c:	491c                	lw	a5,16(a0)
ffffffffc0205f2e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205f32:	c918                	sw	a4,16(a0)
ffffffffc0205f34:	fb5d                	bnez	a4,ffffffffc0205eea <do_fork+0x314>
ffffffffc0205f36:	8e7ff0ef          	jal	ra,ffffffffc020581c <files_destroy>
ffffffffc0205f3a:	bf45                	j	ffffffffc0205eea <do_fork+0x314>
ffffffffc0205f3c:	01d6c363          	blt	a3,t4,ffffffffc0205f42 <do_fork+0x36c>
ffffffffc0205f40:	4685                	li	a3,1
ffffffffc0205f42:	4585                	li	a1,1
ffffffffc0205f44:	bd39                	j	ffffffffc0205d62 <do_fork+0x18c>
ffffffffc0205f46:	59f1                	li	s3,-4
ffffffffc0205f48:	b7f9                	j	ffffffffc0205f16 <do_fork+0x340>
ffffffffc0205f4a:	e57fa0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0205f4e:	4985                	li	s3,1
ffffffffc0205f50:	b3e1                	j	ffffffffc0205d18 <do_fork+0x142>
ffffffffc0205f52:	59ed                	li	s3,-5
ffffffffc0205f54:	bfa1                	j	ffffffffc0205eac <do_fork+0x2d6>
ffffffffc0205f56:	c585                	beqz	a1,ffffffffc0205f7e <do_fork+0x3a8>
ffffffffc0205f58:	00d82023          	sw	a3,0(a6)
ffffffffc0205f5c:	8536                	mv	a0,a3
ffffffffc0205f5e:	b5f5                	j	ffffffffc0205e4a <do_fork+0x274>
ffffffffc0205f60:	8552                	mv	a0,s4
ffffffffc0205f62:	90efd0ef          	jal	ra,ffffffffc0203070 <exit_mmap>
ffffffffc0205f66:	018a3503          	ld	a0,24(s4)
ffffffffc0205f6a:	ba3ff0ef          	jal	ra,ffffffffc0205b0c <put_pgdir.isra.0>
ffffffffc0205f6e:	8552                	mv	a0,s4
ffffffffc0205f70:	f65fc0ef          	jal	ra,ffffffffc0202ed4 <mm_destroy>
ffffffffc0205f74:	bf4d                	j	ffffffffc0205f26 <do_fork+0x350>
ffffffffc0205f76:	59f1                	li	s3,-4
ffffffffc0205f78:	bf15                	j	ffffffffc0205eac <do_fork+0x2d6>
ffffffffc0205f7a:	59f1                	li	s3,-4
ffffffffc0205f7c:	b7bd                	j	ffffffffc0205eea <do_fork+0x314>
ffffffffc0205f7e:	00082503          	lw	a0,0(a6)
ffffffffc0205f82:	b5e1                	j	ffffffffc0205e4a <do_fork+0x274>
ffffffffc0205f84:	59f1                	li	s3,-4
ffffffffc0205f86:	b745                	j	ffffffffc0205f26 <do_fork+0x350>
ffffffffc0205f88:	00007697          	auipc	a3,0x7
ffffffffc0205f8c:	62068693          	addi	a3,a3,1568 # ffffffffc020d5a8 <CSWTCH.79+0xc8>
ffffffffc0205f90:	00006617          	auipc	a2,0x6
ffffffffc0205f94:	b9860613          	addi	a2,a2,-1128 # ffffffffc020bb28 <commands+0x250>
ffffffffc0205f98:	23e00593          	li	a1,574
ffffffffc0205f9c:	00007517          	auipc	a0,0x7
ffffffffc0205fa0:	62c50513          	addi	a0,a0,1580 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc0205fa4:	a8afa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0205fa8:	00006617          	auipc	a2,0x6
ffffffffc0205fac:	29860613          	addi	a2,a2,664 # ffffffffc020c240 <commands+0x968>
ffffffffc0205fb0:	07100593          	li	a1,113
ffffffffc0205fb4:	00006517          	auipc	a0,0x6
ffffffffc0205fb8:	25450513          	addi	a0,a0,596 # ffffffffc020c208 <commands+0x930>
ffffffffc0205fbc:	a72fa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0205fc0:	00007697          	auipc	a3,0x7
ffffffffc0205fc4:	62068693          	addi	a3,a3,1568 # ffffffffc020d5e0 <CSWTCH.79+0x100>
ffffffffc0205fc8:	00006617          	auipc	a2,0x6
ffffffffc0205fcc:	b6060613          	addi	a2,a2,-1184 # ffffffffc020bb28 <commands+0x250>
ffffffffc0205fd0:	1d900593          	li	a1,473
ffffffffc0205fd4:	00007517          	auipc	a0,0x7
ffffffffc0205fd8:	5f450513          	addi	a0,a0,1524 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc0205fdc:	a52fa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0205fe0:	b11ff0ef          	jal	ra,ffffffffc0205af0 <pa2page.part.0>
ffffffffc0205fe4:	00006617          	auipc	a2,0x6
ffffffffc0205fe8:	37c60613          	addi	a2,a2,892 # ffffffffc020c360 <commands+0xa88>
ffffffffc0205fec:	07700593          	li	a1,119
ffffffffc0205ff0:	00006517          	auipc	a0,0x6
ffffffffc0205ff4:	21850513          	addi	a0,a0,536 # ffffffffc020c208 <commands+0x930>
ffffffffc0205ff8:	a36fa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0205ffc:	00006617          	auipc	a2,0x6
ffffffffc0206000:	36460613          	addi	a2,a2,868 # ffffffffc020c360 <commands+0xa88>
ffffffffc0206004:	1b900593          	li	a1,441
ffffffffc0206008:	00007517          	auipc	a0,0x7
ffffffffc020600c:	5c050513          	addi	a0,a0,1472 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc0206010:	a1efa0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0206014 <kernel_thread>:
ffffffffc0206014:	7129                	addi	sp,sp,-320
ffffffffc0206016:	fa22                	sd	s0,304(sp)
ffffffffc0206018:	f626                	sd	s1,296(sp)
ffffffffc020601a:	f24a                	sd	s2,288(sp)
ffffffffc020601c:	84ae                	mv	s1,a1
ffffffffc020601e:	892a                	mv	s2,a0
ffffffffc0206020:	8432                	mv	s0,a2
ffffffffc0206022:	4581                	li	a1,0
ffffffffc0206024:	12000613          	li	a2,288
ffffffffc0206028:	850a                	mv	a0,sp
ffffffffc020602a:	fe06                	sd	ra,312(sp)
ffffffffc020602c:	106050ef          	jal	ra,ffffffffc020b132 <memset>
ffffffffc0206030:	e0ca                	sd	s2,64(sp)
ffffffffc0206032:	e4a6                	sd	s1,72(sp)
ffffffffc0206034:	100027f3          	csrr	a5,sstatus
ffffffffc0206038:	edd7f793          	andi	a5,a5,-291
ffffffffc020603c:	1207e793          	ori	a5,a5,288
ffffffffc0206040:	e23e                	sd	a5,256(sp)
ffffffffc0206042:	860a                	mv	a2,sp
ffffffffc0206044:	10046513          	ori	a0,s0,256
ffffffffc0206048:	00000797          	auipc	a5,0x0
ffffffffc020604c:	98e78793          	addi	a5,a5,-1650 # ffffffffc02059d6 <kernel_thread_entry>
ffffffffc0206050:	4581                	li	a1,0
ffffffffc0206052:	e63e                	sd	a5,264(sp)
ffffffffc0206054:	b83ff0ef          	jal	ra,ffffffffc0205bd6 <do_fork>
ffffffffc0206058:	70f2                	ld	ra,312(sp)
ffffffffc020605a:	7452                	ld	s0,304(sp)
ffffffffc020605c:	74b2                	ld	s1,296(sp)
ffffffffc020605e:	7912                	ld	s2,288(sp)
ffffffffc0206060:	6131                	addi	sp,sp,320
ffffffffc0206062:	8082                	ret

ffffffffc0206064 <do_exit>:
ffffffffc0206064:	7179                	addi	sp,sp,-48
ffffffffc0206066:	f022                	sd	s0,32(sp)
ffffffffc0206068:	00091417          	auipc	s0,0x91
ffffffffc020606c:	85840413          	addi	s0,s0,-1960 # ffffffffc02968c0 <current>
ffffffffc0206070:	601c                	ld	a5,0(s0)
ffffffffc0206072:	f406                	sd	ra,40(sp)
ffffffffc0206074:	ec26                	sd	s1,24(sp)
ffffffffc0206076:	e84a                	sd	s2,16(sp)
ffffffffc0206078:	e44e                	sd	s3,8(sp)
ffffffffc020607a:	e052                	sd	s4,0(sp)
ffffffffc020607c:	00091717          	auipc	a4,0x91
ffffffffc0206080:	84c73703          	ld	a4,-1972(a4) # ffffffffc02968c8 <idleproc>
ffffffffc0206084:	0ee78763          	beq	a5,a4,ffffffffc0206172 <do_exit+0x10e>
ffffffffc0206088:	00091497          	auipc	s1,0x91
ffffffffc020608c:	84848493          	addi	s1,s1,-1976 # ffffffffc02968d0 <initproc>
ffffffffc0206090:	6098                	ld	a4,0(s1)
ffffffffc0206092:	10e78763          	beq	a5,a4,ffffffffc02061a0 <do_exit+0x13c>
ffffffffc0206096:	0287b983          	ld	s3,40(a5)
ffffffffc020609a:	892a                	mv	s2,a0
ffffffffc020609c:	02098e63          	beqz	s3,ffffffffc02060d8 <do_exit+0x74>
ffffffffc02060a0:	00090797          	auipc	a5,0x90
ffffffffc02060a4:	7e87b783          	ld	a5,2024(a5) # ffffffffc0296888 <boot_pgdir_pa>
ffffffffc02060a8:	577d                	li	a4,-1
ffffffffc02060aa:	177e                	slli	a4,a4,0x3f
ffffffffc02060ac:	83b1                	srli	a5,a5,0xc
ffffffffc02060ae:	8fd9                	or	a5,a5,a4
ffffffffc02060b0:	18079073          	csrw	satp,a5
ffffffffc02060b4:	0309a783          	lw	a5,48(s3)
ffffffffc02060b8:	fff7871b          	addiw	a4,a5,-1
ffffffffc02060bc:	02e9a823          	sw	a4,48(s3)
ffffffffc02060c0:	c769                	beqz	a4,ffffffffc020618a <do_exit+0x126>
ffffffffc02060c2:	601c                	ld	a5,0(s0)
ffffffffc02060c4:	1487b503          	ld	a0,328(a5)
ffffffffc02060c8:	0207b423          	sd	zero,40(a5)
ffffffffc02060cc:	c511                	beqz	a0,ffffffffc02060d8 <do_exit+0x74>
ffffffffc02060ce:	491c                	lw	a5,16(a0)
ffffffffc02060d0:	fff7871b          	addiw	a4,a5,-1
ffffffffc02060d4:	c918                	sw	a4,16(a0)
ffffffffc02060d6:	cb59                	beqz	a4,ffffffffc020616c <do_exit+0x108>
ffffffffc02060d8:	601c                	ld	a5,0(s0)
ffffffffc02060da:	470d                	li	a4,3
ffffffffc02060dc:	c398                	sw	a4,0(a5)
ffffffffc02060de:	0f27a423          	sw	s2,232(a5)
ffffffffc02060e2:	100027f3          	csrr	a5,sstatus
ffffffffc02060e6:	8b89                	andi	a5,a5,2
ffffffffc02060e8:	4a01                	li	s4,0
ffffffffc02060ea:	e7f9                	bnez	a5,ffffffffc02061b8 <do_exit+0x154>
ffffffffc02060ec:	6018                	ld	a4,0(s0)
ffffffffc02060ee:	800007b7          	lui	a5,0x80000
ffffffffc02060f2:	0785                	addi	a5,a5,1
ffffffffc02060f4:	7308                	ld	a0,32(a4)
ffffffffc02060f6:	0ec52703          	lw	a4,236(a0)
ffffffffc02060fa:	0cf70363          	beq	a4,a5,ffffffffc02061c0 <do_exit+0x15c>
ffffffffc02060fe:	6018                	ld	a4,0(s0)
ffffffffc0206100:	7b7c                	ld	a5,240(a4)
ffffffffc0206102:	c3a1                	beqz	a5,ffffffffc0206142 <do_exit+0xde>
ffffffffc0206104:	800009b7          	lui	s3,0x80000
ffffffffc0206108:	490d                	li	s2,3
ffffffffc020610a:	0985                	addi	s3,s3,1
ffffffffc020610c:	a021                	j	ffffffffc0206114 <do_exit+0xb0>
ffffffffc020610e:	6018                	ld	a4,0(s0)
ffffffffc0206110:	7b7c                	ld	a5,240(a4)
ffffffffc0206112:	cb85                	beqz	a5,ffffffffc0206142 <do_exit+0xde>
ffffffffc0206114:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_bin_sfs_img_size+0xffffffff7ff8ae00>
ffffffffc0206118:	6088                	ld	a0,0(s1)
ffffffffc020611a:	fb74                	sd	a3,240(a4)
ffffffffc020611c:	7978                	ld	a4,240(a0)
ffffffffc020611e:	0e07bc23          	sd	zero,248(a5)
ffffffffc0206122:	10e7b023          	sd	a4,256(a5)
ffffffffc0206126:	c311                	beqz	a4,ffffffffc020612a <do_exit+0xc6>
ffffffffc0206128:	ff7c                	sd	a5,248(a4)
ffffffffc020612a:	4398                	lw	a4,0(a5)
ffffffffc020612c:	f388                	sd	a0,32(a5)
ffffffffc020612e:	f97c                	sd	a5,240(a0)
ffffffffc0206130:	fd271fe3          	bne	a4,s2,ffffffffc020610e <do_exit+0xaa>
ffffffffc0206134:	0ec52783          	lw	a5,236(a0)
ffffffffc0206138:	fd379be3          	bne	a5,s3,ffffffffc020610e <do_exit+0xaa>
ffffffffc020613c:	17a010ef          	jal	ra,ffffffffc02072b6 <wakeup_proc>
ffffffffc0206140:	b7f9                	j	ffffffffc020610e <do_exit+0xaa>
ffffffffc0206142:	020a1263          	bnez	s4,ffffffffc0206166 <do_exit+0x102>
ffffffffc0206146:	222010ef          	jal	ra,ffffffffc0207368 <schedule>
ffffffffc020614a:	601c                	ld	a5,0(s0)
ffffffffc020614c:	00007617          	auipc	a2,0x7
ffffffffc0206150:	4cc60613          	addi	a2,a2,1228 # ffffffffc020d618 <CSWTCH.79+0x138>
ffffffffc0206154:	2a800593          	li	a1,680
ffffffffc0206158:	43d4                	lw	a3,4(a5)
ffffffffc020615a:	00007517          	auipc	a0,0x7
ffffffffc020615e:	46e50513          	addi	a0,a0,1134 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc0206162:	8ccfa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206166:	c35fa0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc020616a:	bff1                	j	ffffffffc0206146 <do_exit+0xe2>
ffffffffc020616c:	eb0ff0ef          	jal	ra,ffffffffc020581c <files_destroy>
ffffffffc0206170:	b7a5                	j	ffffffffc02060d8 <do_exit+0x74>
ffffffffc0206172:	00007617          	auipc	a2,0x7
ffffffffc0206176:	48660613          	addi	a2,a2,1158 # ffffffffc020d5f8 <CSWTCH.79+0x118>
ffffffffc020617a:	27300593          	li	a1,627
ffffffffc020617e:	00007517          	auipc	a0,0x7
ffffffffc0206182:	44a50513          	addi	a0,a0,1098 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc0206186:	8a8fa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020618a:	854e                	mv	a0,s3
ffffffffc020618c:	ee5fc0ef          	jal	ra,ffffffffc0203070 <exit_mmap>
ffffffffc0206190:	0189b503          	ld	a0,24(s3) # ffffffff80000018 <_binary_bin_sfs_img_size+0xffffffff7ff8ad18>
ffffffffc0206194:	979ff0ef          	jal	ra,ffffffffc0205b0c <put_pgdir.isra.0>
ffffffffc0206198:	854e                	mv	a0,s3
ffffffffc020619a:	d3bfc0ef          	jal	ra,ffffffffc0202ed4 <mm_destroy>
ffffffffc020619e:	b715                	j	ffffffffc02060c2 <do_exit+0x5e>
ffffffffc02061a0:	00007617          	auipc	a2,0x7
ffffffffc02061a4:	46860613          	addi	a2,a2,1128 # ffffffffc020d608 <CSWTCH.79+0x128>
ffffffffc02061a8:	27700593          	li	a1,631
ffffffffc02061ac:	00007517          	auipc	a0,0x7
ffffffffc02061b0:	41c50513          	addi	a0,a0,1052 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc02061b4:	87afa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02061b8:	be9fa0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc02061bc:	4a05                	li	s4,1
ffffffffc02061be:	b73d                	j	ffffffffc02060ec <do_exit+0x88>
ffffffffc02061c0:	0f6010ef          	jal	ra,ffffffffc02072b6 <wakeup_proc>
ffffffffc02061c4:	bf2d                	j	ffffffffc02060fe <do_exit+0x9a>

ffffffffc02061c6 <do_wait.part.0>:
ffffffffc02061c6:	715d                	addi	sp,sp,-80
ffffffffc02061c8:	f84a                	sd	s2,48(sp)
ffffffffc02061ca:	f44e                	sd	s3,40(sp)
ffffffffc02061cc:	80000937          	lui	s2,0x80000
ffffffffc02061d0:	6989                	lui	s3,0x2
ffffffffc02061d2:	fc26                	sd	s1,56(sp)
ffffffffc02061d4:	f052                	sd	s4,32(sp)
ffffffffc02061d6:	ec56                	sd	s5,24(sp)
ffffffffc02061d8:	e85a                	sd	s6,16(sp)
ffffffffc02061da:	e45e                	sd	s7,8(sp)
ffffffffc02061dc:	e486                	sd	ra,72(sp)
ffffffffc02061de:	e0a2                	sd	s0,64(sp)
ffffffffc02061e0:	84aa                	mv	s1,a0
ffffffffc02061e2:	8a2e                	mv	s4,a1
ffffffffc02061e4:	00090b97          	auipc	s7,0x90
ffffffffc02061e8:	6dcb8b93          	addi	s7,s7,1756 # ffffffffc02968c0 <current>
ffffffffc02061ec:	00050b1b          	sext.w	s6,a0
ffffffffc02061f0:	fff50a9b          	addiw	s5,a0,-1
ffffffffc02061f4:	19f9                	addi	s3,s3,-2
ffffffffc02061f6:	0905                	addi	s2,s2,1
ffffffffc02061f8:	ccbd                	beqz	s1,ffffffffc0206276 <do_wait.part.0+0xb0>
ffffffffc02061fa:	0359e863          	bltu	s3,s5,ffffffffc020622a <do_wait.part.0+0x64>
ffffffffc02061fe:	45a9                	li	a1,10
ffffffffc0206200:	855a                	mv	a0,s6
ffffffffc0206202:	416050ef          	jal	ra,ffffffffc020b618 <hash32>
ffffffffc0206206:	02051793          	slli	a5,a0,0x20
ffffffffc020620a:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020620e:	0008b797          	auipc	a5,0x8b
ffffffffc0206212:	5b278793          	addi	a5,a5,1458 # ffffffffc02917c0 <hash_list>
ffffffffc0206216:	953e                	add	a0,a0,a5
ffffffffc0206218:	842a                	mv	s0,a0
ffffffffc020621a:	a029                	j	ffffffffc0206224 <do_wait.part.0+0x5e>
ffffffffc020621c:	f2c42783          	lw	a5,-212(s0)
ffffffffc0206220:	02978163          	beq	a5,s1,ffffffffc0206242 <do_wait.part.0+0x7c>
ffffffffc0206224:	6400                	ld	s0,8(s0)
ffffffffc0206226:	fe851be3          	bne	a0,s0,ffffffffc020621c <do_wait.part.0+0x56>
ffffffffc020622a:	5579                	li	a0,-2
ffffffffc020622c:	60a6                	ld	ra,72(sp)
ffffffffc020622e:	6406                	ld	s0,64(sp)
ffffffffc0206230:	74e2                	ld	s1,56(sp)
ffffffffc0206232:	7942                	ld	s2,48(sp)
ffffffffc0206234:	79a2                	ld	s3,40(sp)
ffffffffc0206236:	7a02                	ld	s4,32(sp)
ffffffffc0206238:	6ae2                	ld	s5,24(sp)
ffffffffc020623a:	6b42                	ld	s6,16(sp)
ffffffffc020623c:	6ba2                	ld	s7,8(sp)
ffffffffc020623e:	6161                	addi	sp,sp,80
ffffffffc0206240:	8082                	ret
ffffffffc0206242:	000bb683          	ld	a3,0(s7)
ffffffffc0206246:	f4843783          	ld	a5,-184(s0)
ffffffffc020624a:	fed790e3          	bne	a5,a3,ffffffffc020622a <do_wait.part.0+0x64>
ffffffffc020624e:	f2842703          	lw	a4,-216(s0)
ffffffffc0206252:	478d                	li	a5,3
ffffffffc0206254:	0ef70b63          	beq	a4,a5,ffffffffc020634a <do_wait.part.0+0x184>
ffffffffc0206258:	4785                	li	a5,1
ffffffffc020625a:	c29c                	sw	a5,0(a3)
ffffffffc020625c:	0f26a623          	sw	s2,236(a3)
ffffffffc0206260:	108010ef          	jal	ra,ffffffffc0207368 <schedule>
ffffffffc0206264:	000bb783          	ld	a5,0(s7)
ffffffffc0206268:	0b07a783          	lw	a5,176(a5)
ffffffffc020626c:	8b85                	andi	a5,a5,1
ffffffffc020626e:	d7c9                	beqz	a5,ffffffffc02061f8 <do_wait.part.0+0x32>
ffffffffc0206270:	555d                	li	a0,-9
ffffffffc0206272:	df3ff0ef          	jal	ra,ffffffffc0206064 <do_exit>
ffffffffc0206276:	000bb683          	ld	a3,0(s7)
ffffffffc020627a:	7ae0                	ld	s0,240(a3)
ffffffffc020627c:	d45d                	beqz	s0,ffffffffc020622a <do_wait.part.0+0x64>
ffffffffc020627e:	470d                	li	a4,3
ffffffffc0206280:	a021                	j	ffffffffc0206288 <do_wait.part.0+0xc2>
ffffffffc0206282:	10043403          	ld	s0,256(s0)
ffffffffc0206286:	d869                	beqz	s0,ffffffffc0206258 <do_wait.part.0+0x92>
ffffffffc0206288:	401c                	lw	a5,0(s0)
ffffffffc020628a:	fee79ce3          	bne	a5,a4,ffffffffc0206282 <do_wait.part.0+0xbc>
ffffffffc020628e:	00090797          	auipc	a5,0x90
ffffffffc0206292:	63a7b783          	ld	a5,1594(a5) # ffffffffc02968c8 <idleproc>
ffffffffc0206296:	0c878963          	beq	a5,s0,ffffffffc0206368 <do_wait.part.0+0x1a2>
ffffffffc020629a:	00090797          	auipc	a5,0x90
ffffffffc020629e:	6367b783          	ld	a5,1590(a5) # ffffffffc02968d0 <initproc>
ffffffffc02062a2:	0cf40363          	beq	s0,a5,ffffffffc0206368 <do_wait.part.0+0x1a2>
ffffffffc02062a6:	000a0663          	beqz	s4,ffffffffc02062b2 <do_wait.part.0+0xec>
ffffffffc02062aa:	0e842783          	lw	a5,232(s0)
ffffffffc02062ae:	00fa2023          	sw	a5,0(s4)
ffffffffc02062b2:	100027f3          	csrr	a5,sstatus
ffffffffc02062b6:	8b89                	andi	a5,a5,2
ffffffffc02062b8:	4581                	li	a1,0
ffffffffc02062ba:	e7c1                	bnez	a5,ffffffffc0206342 <do_wait.part.0+0x17c>
ffffffffc02062bc:	6c70                	ld	a2,216(s0)
ffffffffc02062be:	7074                	ld	a3,224(s0)
ffffffffc02062c0:	10043703          	ld	a4,256(s0)
ffffffffc02062c4:	7c7c                	ld	a5,248(s0)
ffffffffc02062c6:	e614                	sd	a3,8(a2)
ffffffffc02062c8:	e290                	sd	a2,0(a3)
ffffffffc02062ca:	6470                	ld	a2,200(s0)
ffffffffc02062cc:	6874                	ld	a3,208(s0)
ffffffffc02062ce:	e614                	sd	a3,8(a2)
ffffffffc02062d0:	e290                	sd	a2,0(a3)
ffffffffc02062d2:	c319                	beqz	a4,ffffffffc02062d8 <do_wait.part.0+0x112>
ffffffffc02062d4:	ff7c                	sd	a5,248(a4)
ffffffffc02062d6:	7c7c                	ld	a5,248(s0)
ffffffffc02062d8:	c3b5                	beqz	a5,ffffffffc020633c <do_wait.part.0+0x176>
ffffffffc02062da:	10e7b023          	sd	a4,256(a5)
ffffffffc02062de:	00090717          	auipc	a4,0x90
ffffffffc02062e2:	5fa70713          	addi	a4,a4,1530 # ffffffffc02968d8 <nr_process>
ffffffffc02062e6:	431c                	lw	a5,0(a4)
ffffffffc02062e8:	37fd                	addiw	a5,a5,-1
ffffffffc02062ea:	c31c                	sw	a5,0(a4)
ffffffffc02062ec:	e5a9                	bnez	a1,ffffffffc0206336 <do_wait.part.0+0x170>
ffffffffc02062ee:	6814                	ld	a3,16(s0)
ffffffffc02062f0:	c02007b7          	lui	a5,0xc0200
ffffffffc02062f4:	04f6ee63          	bltu	a3,a5,ffffffffc0206350 <do_wait.part.0+0x18a>
ffffffffc02062f8:	00090797          	auipc	a5,0x90
ffffffffc02062fc:	5b87b783          	ld	a5,1464(a5) # ffffffffc02968b0 <va_pa_offset>
ffffffffc0206300:	8e9d                	sub	a3,a3,a5
ffffffffc0206302:	82b1                	srli	a3,a3,0xc
ffffffffc0206304:	00090797          	auipc	a5,0x90
ffffffffc0206308:	5947b783          	ld	a5,1428(a5) # ffffffffc0296898 <npage>
ffffffffc020630c:	06f6fa63          	bgeu	a3,a5,ffffffffc0206380 <do_wait.part.0+0x1ba>
ffffffffc0206310:	00009517          	auipc	a0,0x9
ffffffffc0206314:	5e053503          	ld	a0,1504(a0) # ffffffffc020f8f0 <nbase>
ffffffffc0206318:	8e89                	sub	a3,a3,a0
ffffffffc020631a:	069a                	slli	a3,a3,0x6
ffffffffc020631c:	00090517          	auipc	a0,0x90
ffffffffc0206320:	58453503          	ld	a0,1412(a0) # ffffffffc02968a0 <pages>
ffffffffc0206324:	9536                	add	a0,a0,a3
ffffffffc0206326:	4589                	li	a1,2
ffffffffc0206328:	800fb0ef          	jal	ra,ffffffffc0201328 <free_pages>
ffffffffc020632c:	8522                	mv	a0,s0
ffffffffc020632e:	d44fd0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc0206332:	4501                	li	a0,0
ffffffffc0206334:	bde5                	j	ffffffffc020622c <do_wait.part.0+0x66>
ffffffffc0206336:	a65fa0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc020633a:	bf55                	j	ffffffffc02062ee <do_wait.part.0+0x128>
ffffffffc020633c:	701c                	ld	a5,32(s0)
ffffffffc020633e:	fbf8                	sd	a4,240(a5)
ffffffffc0206340:	bf79                	j	ffffffffc02062de <do_wait.part.0+0x118>
ffffffffc0206342:	a5ffa0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0206346:	4585                	li	a1,1
ffffffffc0206348:	bf95                	j	ffffffffc02062bc <do_wait.part.0+0xf6>
ffffffffc020634a:	f2840413          	addi	s0,s0,-216
ffffffffc020634e:	b781                	j	ffffffffc020628e <do_wait.part.0+0xc8>
ffffffffc0206350:	00006617          	auipc	a2,0x6
ffffffffc0206354:	01060613          	addi	a2,a2,16 # ffffffffc020c360 <commands+0xa88>
ffffffffc0206358:	07700593          	li	a1,119
ffffffffc020635c:	00006517          	auipc	a0,0x6
ffffffffc0206360:	eac50513          	addi	a0,a0,-340 # ffffffffc020c208 <commands+0x930>
ffffffffc0206364:	ecbf90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206368:	00007617          	auipc	a2,0x7
ffffffffc020636c:	2d060613          	addi	a2,a2,720 # ffffffffc020d638 <CSWTCH.79+0x158>
ffffffffc0206370:	47500593          	li	a1,1141
ffffffffc0206374:	00007517          	auipc	a0,0x7
ffffffffc0206378:	25450513          	addi	a0,a0,596 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc020637c:	eb3f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206380:	f70ff0ef          	jal	ra,ffffffffc0205af0 <pa2page.part.0>

ffffffffc0206384 <init_main>:
ffffffffc0206384:	1141                	addi	sp,sp,-16
ffffffffc0206386:	00007517          	auipc	a0,0x7
ffffffffc020638a:	2d250513          	addi	a0,a0,722 # ffffffffc020d658 <CSWTCH.79+0x178>
ffffffffc020638e:	e406                	sd	ra,8(sp)
ffffffffc0206390:	1aa020ef          	jal	ra,ffffffffc020853a <vfs_set_bootfs>
ffffffffc0206394:	e179                	bnez	a0,ffffffffc020645a <init_main+0xd6>
ffffffffc0206396:	fd3fa0ef          	jal	ra,ffffffffc0201368 <nr_free_pages>
ffffffffc020639a:	c24fd0ef          	jal	ra,ffffffffc02037be <kallocated>
ffffffffc020639e:	4601                	li	a2,0
ffffffffc02063a0:	4581                	li	a1,0
ffffffffc02063a2:	00001517          	auipc	a0,0x1
ffffffffc02063a6:	ac050513          	addi	a0,a0,-1344 # ffffffffc0206e62 <user_main>
ffffffffc02063aa:	c6bff0ef          	jal	ra,ffffffffc0206014 <kernel_thread>
ffffffffc02063ae:	00a04563          	bgtz	a0,ffffffffc02063b8 <init_main+0x34>
ffffffffc02063b2:	a841                	j	ffffffffc0206442 <init_main+0xbe>
ffffffffc02063b4:	7b5000ef          	jal	ra,ffffffffc0207368 <schedule>
ffffffffc02063b8:	4581                	li	a1,0
ffffffffc02063ba:	4501                	li	a0,0
ffffffffc02063bc:	e0bff0ef          	jal	ra,ffffffffc02061c6 <do_wait.part.0>
ffffffffc02063c0:	d975                	beqz	a0,ffffffffc02063b4 <init_main+0x30>
ffffffffc02063c2:	c14ff0ef          	jal	ra,ffffffffc02057d6 <fs_cleanup>
ffffffffc02063c6:	00007517          	auipc	a0,0x7
ffffffffc02063ca:	2da50513          	addi	a0,a0,730 # ffffffffc020d6a0 <CSWTCH.79+0x1c0>
ffffffffc02063ce:	d5df90ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02063d2:	00090797          	auipc	a5,0x90
ffffffffc02063d6:	4fe7b783          	ld	a5,1278(a5) # ffffffffc02968d0 <initproc>
ffffffffc02063da:	7bf8                	ld	a4,240(a5)
ffffffffc02063dc:	e339                	bnez	a4,ffffffffc0206422 <init_main+0x9e>
ffffffffc02063de:	7ff8                	ld	a4,248(a5)
ffffffffc02063e0:	e329                	bnez	a4,ffffffffc0206422 <init_main+0x9e>
ffffffffc02063e2:	1007b703          	ld	a4,256(a5)
ffffffffc02063e6:	ef15                	bnez	a4,ffffffffc0206422 <init_main+0x9e>
ffffffffc02063e8:	00090697          	auipc	a3,0x90
ffffffffc02063ec:	4f06a683          	lw	a3,1264(a3) # ffffffffc02968d8 <nr_process>
ffffffffc02063f0:	4709                	li	a4,2
ffffffffc02063f2:	0ce69163          	bne	a3,a4,ffffffffc02064b4 <init_main+0x130>
ffffffffc02063f6:	0008f717          	auipc	a4,0x8f
ffffffffc02063fa:	3ca70713          	addi	a4,a4,970 # ffffffffc02957c0 <proc_list>
ffffffffc02063fe:	6714                	ld	a3,8(a4)
ffffffffc0206400:	0c878793          	addi	a5,a5,200
ffffffffc0206404:	08d79863          	bne	a5,a3,ffffffffc0206494 <init_main+0x110>
ffffffffc0206408:	6318                	ld	a4,0(a4)
ffffffffc020640a:	06e79563          	bne	a5,a4,ffffffffc0206474 <init_main+0xf0>
ffffffffc020640e:	00007517          	auipc	a0,0x7
ffffffffc0206412:	37a50513          	addi	a0,a0,890 # ffffffffc020d788 <CSWTCH.79+0x2a8>
ffffffffc0206416:	d15f90ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020641a:	60a2                	ld	ra,8(sp)
ffffffffc020641c:	4501                	li	a0,0
ffffffffc020641e:	0141                	addi	sp,sp,16
ffffffffc0206420:	8082                	ret
ffffffffc0206422:	00007697          	auipc	a3,0x7
ffffffffc0206426:	2a668693          	addi	a3,a3,678 # ffffffffc020d6c8 <CSWTCH.79+0x1e8>
ffffffffc020642a:	00005617          	auipc	a2,0x5
ffffffffc020642e:	6fe60613          	addi	a2,a2,1790 # ffffffffc020bb28 <commands+0x250>
ffffffffc0206432:	4eb00593          	li	a1,1259
ffffffffc0206436:	00007517          	auipc	a0,0x7
ffffffffc020643a:	19250513          	addi	a0,a0,402 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc020643e:	df1f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206442:	00007617          	auipc	a2,0x7
ffffffffc0206446:	23e60613          	addi	a2,a2,574 # ffffffffc020d680 <CSWTCH.79+0x1a0>
ffffffffc020644a:	4de00593          	li	a1,1246
ffffffffc020644e:	00007517          	auipc	a0,0x7
ffffffffc0206452:	17a50513          	addi	a0,a0,378 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc0206456:	dd9f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020645a:	86aa                	mv	a3,a0
ffffffffc020645c:	00007617          	auipc	a2,0x7
ffffffffc0206460:	20460613          	addi	a2,a2,516 # ffffffffc020d660 <CSWTCH.79+0x180>
ffffffffc0206464:	4d600593          	li	a1,1238
ffffffffc0206468:	00007517          	auipc	a0,0x7
ffffffffc020646c:	16050513          	addi	a0,a0,352 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc0206470:	dbff90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206474:	00007697          	auipc	a3,0x7
ffffffffc0206478:	2e468693          	addi	a3,a3,740 # ffffffffc020d758 <CSWTCH.79+0x278>
ffffffffc020647c:	00005617          	auipc	a2,0x5
ffffffffc0206480:	6ac60613          	addi	a2,a2,1708 # ffffffffc020bb28 <commands+0x250>
ffffffffc0206484:	4ee00593          	li	a1,1262
ffffffffc0206488:	00007517          	auipc	a0,0x7
ffffffffc020648c:	14050513          	addi	a0,a0,320 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc0206490:	d9ff90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206494:	00007697          	auipc	a3,0x7
ffffffffc0206498:	29468693          	addi	a3,a3,660 # ffffffffc020d728 <CSWTCH.79+0x248>
ffffffffc020649c:	00005617          	auipc	a2,0x5
ffffffffc02064a0:	68c60613          	addi	a2,a2,1676 # ffffffffc020bb28 <commands+0x250>
ffffffffc02064a4:	4ed00593          	li	a1,1261
ffffffffc02064a8:	00007517          	auipc	a0,0x7
ffffffffc02064ac:	12050513          	addi	a0,a0,288 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc02064b0:	d7ff90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02064b4:	00007697          	auipc	a3,0x7
ffffffffc02064b8:	26468693          	addi	a3,a3,612 # ffffffffc020d718 <CSWTCH.79+0x238>
ffffffffc02064bc:	00005617          	auipc	a2,0x5
ffffffffc02064c0:	66c60613          	addi	a2,a2,1644 # ffffffffc020bb28 <commands+0x250>
ffffffffc02064c4:	4ec00593          	li	a1,1260
ffffffffc02064c8:	00007517          	auipc	a0,0x7
ffffffffc02064cc:	10050513          	addi	a0,a0,256 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc02064d0:	d5ff90ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02064d4 <do_execve>:
ffffffffc02064d4:	dd010113          	addi	sp,sp,-560
ffffffffc02064d8:	ffd6                	sd	s5,504(sp)
ffffffffc02064da:	00090a97          	auipc	s5,0x90
ffffffffc02064de:	3e6a8a93          	addi	s5,s5,998 # ffffffffc02968c0 <current>
ffffffffc02064e2:	000ab683          	ld	a3,0(s5)
ffffffffc02064e6:	f3e2                	sd	s8,480(sp)
ffffffffc02064e8:	e7ee                	sd	s11,456(sp)
ffffffffc02064ea:	0286bc03          	ld	s8,40(a3)
ffffffffc02064ee:	fff58d9b          	addiw	s11,a1,-1
ffffffffc02064f2:	0005869b          	sext.w	a3,a1
ffffffffc02064f6:	22113423          	sd	ra,552(sp)
ffffffffc02064fa:	22813023          	sd	s0,544(sp)
ffffffffc02064fe:	20913c23          	sd	s1,536(sp)
ffffffffc0206502:	21213823          	sd	s2,528(sp)
ffffffffc0206506:	21313423          	sd	s3,520(sp)
ffffffffc020650a:	21413023          	sd	s4,512(sp)
ffffffffc020650e:	fbda                	sd	s6,496(sp)
ffffffffc0206510:	f7de                	sd	s7,488(sp)
ffffffffc0206512:	efe6                	sd	s9,472(sp)
ffffffffc0206514:	ebea                	sd	s10,464(sp)
ffffffffc0206516:	000d871b          	sext.w	a4,s11
ffffffffc020651a:	47fd                	li	a5,31
ffffffffc020651c:	e436                	sd	a3,8(sp)
ffffffffc020651e:	50e7e363          	bltu	a5,a4,ffffffffc0206a24 <do_execve+0x550>
ffffffffc0206522:	842e                	mv	s0,a1
ffffffffc0206524:	84aa                	mv	s1,a0
ffffffffc0206526:	8a32                	mv	s4,a2
ffffffffc0206528:	4581                	li	a1,0
ffffffffc020652a:	4641                	li	a2,16
ffffffffc020652c:	1888                	addi	a0,sp,112
ffffffffc020652e:	405040ef          	jal	ra,ffffffffc020b132 <memset>
ffffffffc0206532:	000c0c63          	beqz	s8,ffffffffc020654a <do_execve+0x76>
ffffffffc0206536:	038c0513          	addi	a0,s8,56
ffffffffc020653a:	a10fe0ef          	jal	ra,ffffffffc020474a <down>
ffffffffc020653e:	000ab783          	ld	a5,0(s5)
ffffffffc0206542:	c781                	beqz	a5,ffffffffc020654a <do_execve+0x76>
ffffffffc0206544:	43dc                	lw	a5,4(a5)
ffffffffc0206546:	04fc2823          	sw	a5,80(s8)
ffffffffc020654a:	20048a63          	beqz	s1,ffffffffc020675e <do_execve+0x28a>
ffffffffc020654e:	46c1                	li	a3,16
ffffffffc0206550:	8626                	mv	a2,s1
ffffffffc0206552:	188c                	addi	a1,sp,112
ffffffffc0206554:	8562                	mv	a0,s8
ffffffffc0206556:	fb5fc0ef          	jal	ra,ffffffffc020350a <copy_string>
ffffffffc020655a:	5e050163          	beqz	a0,ffffffffc0206b3c <do_execve+0x668>
ffffffffc020655e:	00341b93          	slli	s7,s0,0x3
ffffffffc0206562:	4681                	li	a3,0
ffffffffc0206564:	865e                	mv	a2,s7
ffffffffc0206566:	85d2                	mv	a1,s4
ffffffffc0206568:	8562                	mv	a0,s8
ffffffffc020656a:	ea7fc0ef          	jal	ra,ffffffffc0203410 <user_mem_check>
ffffffffc020656e:	8952                	mv	s2,s4
ffffffffc0206570:	5c050263          	beqz	a0,ffffffffc0206b34 <do_execve+0x660>
ffffffffc0206574:	0c010b13          	addi	s6,sp,192
ffffffffc0206578:	89da                	mv	s3,s6
ffffffffc020657a:	4481                	li	s1,0
ffffffffc020657c:	6505                	lui	a0,0x1
ffffffffc020657e:	a44fd0ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc0206582:	8caa                	mv	s9,a0
ffffffffc0206584:	16050163          	beqz	a0,ffffffffc02066e6 <do_execve+0x212>
ffffffffc0206588:	00093603          	ld	a2,0(s2) # ffffffff80000000 <_binary_bin_sfs_img_size+0xffffffff7ff8ad00>
ffffffffc020658c:	85aa                	mv	a1,a0
ffffffffc020658e:	6685                	lui	a3,0x1
ffffffffc0206590:	8562                	mv	a0,s8
ffffffffc0206592:	f79fc0ef          	jal	ra,ffffffffc020350a <copy_string>
ffffffffc0206596:	1a050f63          	beqz	a0,ffffffffc0206754 <do_execve+0x280>
ffffffffc020659a:	0199b023          	sd	s9,0(s3) # 2000 <_binary_bin_swap_img_size-0x5d00>
ffffffffc020659e:	2485                	addiw	s1,s1,1
ffffffffc02065a0:	09a1                	addi	s3,s3,8
ffffffffc02065a2:	0921                	addi	s2,s2,8
ffffffffc02065a4:	fc941ce3          	bne	s0,s1,ffffffffc020657c <do_execve+0xa8>
ffffffffc02065a8:	000a3903          	ld	s2,0(s4)
ffffffffc02065ac:	100c0663          	beqz	s8,ffffffffc02066b8 <do_execve+0x1e4>
ffffffffc02065b0:	038c0513          	addi	a0,s8,56
ffffffffc02065b4:	992fe0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc02065b8:	000ab783          	ld	a5,0(s5)
ffffffffc02065bc:	040c2823          	sw	zero,80(s8)
ffffffffc02065c0:	1487b503          	ld	a0,328(a5)
ffffffffc02065c4:	aeeff0ef          	jal	ra,ffffffffc02058b2 <files_closeall>
ffffffffc02065c8:	4581                	li	a1,0
ffffffffc02065ca:	854a                	mv	a0,s2
ffffffffc02065cc:	a5efe0ef          	jal	ra,ffffffffc020482a <sysfile_open>
ffffffffc02065d0:	89aa                	mv	s3,a0
ffffffffc02065d2:	0a054d63          	bltz	a0,ffffffffc020668c <do_execve+0x1b8>
ffffffffc02065d6:	00090797          	auipc	a5,0x90
ffffffffc02065da:	2b27b783          	ld	a5,690(a5) # ffffffffc0296888 <boot_pgdir_pa>
ffffffffc02065de:	577d                	li	a4,-1
ffffffffc02065e0:	177e                	slli	a4,a4,0x3f
ffffffffc02065e2:	83b1                	srli	a5,a5,0xc
ffffffffc02065e4:	8fd9                	or	a5,a5,a4
ffffffffc02065e6:	18079073          	csrw	satp,a5
ffffffffc02065ea:	030c2783          	lw	a5,48(s8)
ffffffffc02065ee:	fff7871b          	addiw	a4,a5,-1
ffffffffc02065f2:	02ec2823          	sw	a4,48(s8)
ffffffffc02065f6:	1c070063          	beqz	a4,ffffffffc02067b6 <do_execve+0x2e2>
ffffffffc02065fa:	000ab783          	ld	a5,0(s5)
ffffffffc02065fe:	0207b423          	sd	zero,40(a5)
ffffffffc0206602:	f84fc0ef          	jal	ra,ffffffffc0202d86 <mm_create>
ffffffffc0206606:	892a                	mv	s2,a0
ffffffffc0206608:	54050463          	beqz	a0,ffffffffc0206b50 <do_execve+0x67c>
ffffffffc020660c:	4505                	li	a0,1
ffffffffc020660e:	cddfa0ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0206612:	c169                	beqz	a0,ffffffffc02066d4 <do_execve+0x200>
ffffffffc0206614:	00090d17          	auipc	s10,0x90
ffffffffc0206618:	28cd0d13          	addi	s10,s10,652 # ffffffffc02968a0 <pages>
ffffffffc020661c:	000d3683          	ld	a3,0(s10)
ffffffffc0206620:	00009797          	auipc	a5,0x9
ffffffffc0206624:	2d07b783          	ld	a5,720(a5) # ffffffffc020f8f0 <nbase>
ffffffffc0206628:	00090c97          	auipc	s9,0x90
ffffffffc020662c:	270c8c93          	addi	s9,s9,624 # ffffffffc0296898 <npage>
ffffffffc0206630:	40d506b3          	sub	a3,a0,a3
ffffffffc0206634:	8699                	srai	a3,a3,0x6
ffffffffc0206636:	96be                	add	a3,a3,a5
ffffffffc0206638:	000cb703          	ld	a4,0(s9)
ffffffffc020663c:	e83e                	sd	a5,16(sp)
ffffffffc020663e:	00c69793          	slli	a5,a3,0xc
ffffffffc0206642:	83b1                	srli	a5,a5,0xc
ffffffffc0206644:	06b2                	slli	a3,a3,0xc
ffffffffc0206646:	78e7f663          	bgeu	a5,a4,ffffffffc0206dd2 <do_execve+0x8fe>
ffffffffc020664a:	00090c17          	auipc	s8,0x90
ffffffffc020664e:	266c0c13          	addi	s8,s8,614 # ffffffffc02968b0 <va_pa_offset>
ffffffffc0206652:	000c3a03          	ld	s4,0(s8)
ffffffffc0206656:	6605                	lui	a2,0x1
ffffffffc0206658:	00090597          	auipc	a1,0x90
ffffffffc020665c:	2385b583          	ld	a1,568(a1) # ffffffffc0296890 <boot_pgdir_va>
ffffffffc0206660:	9a36                	add	s4,s4,a3
ffffffffc0206662:	8552                	mv	a0,s4
ffffffffc0206664:	321040ef          	jal	ra,ffffffffc020b184 <memcpy>
ffffffffc0206668:	4601                	li	a2,0
ffffffffc020666a:	01493c23          	sd	s4,24(s2)
ffffffffc020666e:	4581                	li	a1,0
ffffffffc0206670:	854e                	mv	a0,s3
ffffffffc0206672:	c1efe0ef          	jal	ra,ffffffffc0204a90 <sysfile_seek>
ffffffffc0206676:	8a2a                	mv	s4,a0
ffffffffc0206678:	0e050f63          	beqz	a0,ffffffffc0206776 <do_execve+0x2a2>
ffffffffc020667c:	01893503          	ld	a0,24(s2)
ffffffffc0206680:	89d2                	mv	s3,s4
ffffffffc0206682:	c8aff0ef          	jal	ra,ffffffffc0205b0c <put_pgdir.isra.0>
ffffffffc0206686:	854a                	mv	a0,s2
ffffffffc0206688:	84dfc0ef          	jal	ra,ffffffffc0202ed4 <mm_destroy>
ffffffffc020668c:	fff40793          	addi	a5,s0,-1
ffffffffc0206690:	020d9693          	slli	a3,s11,0x20
ffffffffc0206694:	ff0b0413          	addi	s0,s6,-16
ffffffffc0206698:	078e                	slli	a5,a5,0x3
ffffffffc020669a:	945e                	add	s0,s0,s7
ffffffffc020669c:	01d6d713          	srli	a4,a3,0x1d
ffffffffc02066a0:	9b3e                	add	s6,s6,a5
ffffffffc02066a2:	8c19                	sub	s0,s0,a4
ffffffffc02066a4:	000b3503          	ld	a0,0(s6)
ffffffffc02066a8:	1b61                	addi	s6,s6,-8
ffffffffc02066aa:	9c8fd0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc02066ae:	fe8b1be3          	bne	s6,s0,ffffffffc02066a4 <do_execve+0x1d0>
ffffffffc02066b2:	854e                	mv	a0,s3
ffffffffc02066b4:	9b1ff0ef          	jal	ra,ffffffffc0206064 <do_exit>
ffffffffc02066b8:	000ab783          	ld	a5,0(s5)
ffffffffc02066bc:	1487b503          	ld	a0,328(a5)
ffffffffc02066c0:	9f2ff0ef          	jal	ra,ffffffffc02058b2 <files_closeall>
ffffffffc02066c4:	4581                	li	a1,0
ffffffffc02066c6:	854a                	mv	a0,s2
ffffffffc02066c8:	962fe0ef          	jal	ra,ffffffffc020482a <sysfile_open>
ffffffffc02066cc:	89aa                	mv	s3,a0
ffffffffc02066ce:	f2055ae3          	bgez	a0,ffffffffc0206602 <do_execve+0x12e>
ffffffffc02066d2:	bf6d                	j	ffffffffc020668c <do_execve+0x1b8>
ffffffffc02066d4:	01893503          	ld	a0,24(s2)
ffffffffc02066d8:	59f1                	li	s3,-4
ffffffffc02066da:	c32ff0ef          	jal	ra,ffffffffc0205b0c <put_pgdir.isra.0>
ffffffffc02066de:	854a                	mv	a0,s2
ffffffffc02066e0:	ff4fc0ef          	jal	ra,ffffffffc0202ed4 <mm_destroy>
ffffffffc02066e4:	b765                	j	ffffffffc020668c <do_execve+0x1b8>
ffffffffc02066e6:	5a71                	li	s4,-4
ffffffffc02066e8:	c49d                	beqz	s1,ffffffffc0206716 <do_execve+0x242>
ffffffffc02066ea:	00349713          	slli	a4,s1,0x3
ffffffffc02066ee:	fff48793          	addi	a5,s1,-1
ffffffffc02066f2:	ff0b0413          	addi	s0,s6,-16
ffffffffc02066f6:	34fd                	addiw	s1,s1,-1
ffffffffc02066f8:	943a                	add	s0,s0,a4
ffffffffc02066fa:	02049713          	slli	a4,s1,0x20
ffffffffc02066fe:	078e                	slli	a5,a5,0x3
ffffffffc0206700:	01d75493          	srli	s1,a4,0x1d
ffffffffc0206704:	9b3e                	add	s6,s6,a5
ffffffffc0206706:	8c05                	sub	s0,s0,s1
ffffffffc0206708:	000b3503          	ld	a0,0(s6)
ffffffffc020670c:	1b61                	addi	s6,s6,-8
ffffffffc020670e:	964fd0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc0206712:	fe8b1be3          	bne	s6,s0,ffffffffc0206708 <do_execve+0x234>
ffffffffc0206716:	000c0863          	beqz	s8,ffffffffc0206726 <do_execve+0x252>
ffffffffc020671a:	038c0513          	addi	a0,s8,56
ffffffffc020671e:	828fe0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc0206722:	040c2823          	sw	zero,80(s8)
ffffffffc0206726:	22813083          	ld	ra,552(sp)
ffffffffc020672a:	22013403          	ld	s0,544(sp)
ffffffffc020672e:	21813483          	ld	s1,536(sp)
ffffffffc0206732:	21013903          	ld	s2,528(sp)
ffffffffc0206736:	20813983          	ld	s3,520(sp)
ffffffffc020673a:	7afe                	ld	s5,504(sp)
ffffffffc020673c:	7b5e                	ld	s6,496(sp)
ffffffffc020673e:	7bbe                	ld	s7,488(sp)
ffffffffc0206740:	7c1e                	ld	s8,480(sp)
ffffffffc0206742:	6cfe                	ld	s9,472(sp)
ffffffffc0206744:	6d5e                	ld	s10,464(sp)
ffffffffc0206746:	6dbe                	ld	s11,456(sp)
ffffffffc0206748:	8552                	mv	a0,s4
ffffffffc020674a:	20013a03          	ld	s4,512(sp)
ffffffffc020674e:	23010113          	addi	sp,sp,560
ffffffffc0206752:	8082                	ret
ffffffffc0206754:	8566                	mv	a0,s9
ffffffffc0206756:	91cfd0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc020675a:	5a75                	li	s4,-3
ffffffffc020675c:	b771                	j	ffffffffc02066e8 <do_execve+0x214>
ffffffffc020675e:	000ab783          	ld	a5,0(s5)
ffffffffc0206762:	00007617          	auipc	a2,0x7
ffffffffc0206766:	04660613          	addi	a2,a2,70 # ffffffffc020d7a8 <CSWTCH.79+0x2c8>
ffffffffc020676a:	45c1                	li	a1,16
ffffffffc020676c:	43d4                	lw	a3,4(a5)
ffffffffc020676e:	1888                	addi	a0,sp,112
ffffffffc0206770:	65b040ef          	jal	ra,ffffffffc020b5ca <snprintf>
ffffffffc0206774:	b3ed                	j	ffffffffc020655e <do_execve+0x8a>
ffffffffc0206776:	04000613          	li	a2,64
ffffffffc020677a:	010c                	addi	a1,sp,128
ffffffffc020677c:	854e                	mv	a0,s3
ffffffffc020677e:	8e4fe0ef          	jal	ra,ffffffffc0204862 <sysfile_read>
ffffffffc0206782:	04000793          	li	a5,64
ffffffffc0206786:	00f50863          	beq	a0,a5,ffffffffc0206796 <do_execve+0x2c2>
ffffffffc020678a:	00050a1b          	sext.w	s4,a0
ffffffffc020678e:	ee0547e3          	bltz	a0,ffffffffc020667c <do_execve+0x1a8>
ffffffffc0206792:	5a7d                	li	s4,-1
ffffffffc0206794:	b5e5                	j	ffffffffc020667c <do_execve+0x1a8>
ffffffffc0206796:	470a                	lw	a4,128(sp)
ffffffffc0206798:	464c47b7          	lui	a5,0x464c4
ffffffffc020679c:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_bin_sfs_img_size+0x4644f27f>
ffffffffc02067a0:	02f70663          	beq	a4,a5,ffffffffc02067cc <do_execve+0x2f8>
ffffffffc02067a4:	01893503          	ld	a0,24(s2)
ffffffffc02067a8:	59e1                	li	s3,-8
ffffffffc02067aa:	b62ff0ef          	jal	ra,ffffffffc0205b0c <put_pgdir.isra.0>
ffffffffc02067ae:	854a                	mv	a0,s2
ffffffffc02067b0:	f24fc0ef          	jal	ra,ffffffffc0202ed4 <mm_destroy>
ffffffffc02067b4:	bde1                	j	ffffffffc020668c <do_execve+0x1b8>
ffffffffc02067b6:	8562                	mv	a0,s8
ffffffffc02067b8:	8b9fc0ef          	jal	ra,ffffffffc0203070 <exit_mmap>
ffffffffc02067bc:	018c3503          	ld	a0,24(s8)
ffffffffc02067c0:	b4cff0ef          	jal	ra,ffffffffc0205b0c <put_pgdir.isra.0>
ffffffffc02067c4:	8562                	mv	a0,s8
ffffffffc02067c6:	f0efc0ef          	jal	ra,ffffffffc0202ed4 <mm_destroy>
ffffffffc02067ca:	bd05                	j	ffffffffc02065fa <do_execve+0x126>
ffffffffc02067cc:	0b815783          	lhu	a5,184(sp)
ffffffffc02067d0:	00379513          	slli	a0,a5,0x3
ffffffffc02067d4:	8d1d                	sub	a0,a0,a5
ffffffffc02067d6:	050e                	slli	a0,a0,0x3
ffffffffc02067d8:	febfc0ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc02067dc:	f42a                	sd	a0,40(sp)
ffffffffc02067de:	0e050663          	beqz	a0,ffffffffc02068ca <do_execve+0x3f6>
ffffffffc02067e2:	0b815703          	lhu	a4,184(sp)
ffffffffc02067e6:	758a                	ld	a1,160(sp)
ffffffffc02067e8:	4601                	li	a2,0
ffffffffc02067ea:	854e                	mv	a0,s3
ffffffffc02067ec:	ec3a                	sd	a4,24(sp)
ffffffffc02067ee:	aa2fe0ef          	jal	ra,ffffffffc0204a90 <sysfile_seek>
ffffffffc02067f2:	87aa                	mv	a5,a0
ffffffffc02067f4:	cd19                	beqz	a0,ffffffffc0206812 <do_execve+0x33e>
ffffffffc02067f6:	e43e                	sd	a5,8(sp)
ffffffffc02067f8:	7522                	ld	a0,40(sp)
ffffffffc02067fa:	878fd0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc02067fe:	01893503          	ld	a0,24(s2)
ffffffffc0206802:	67a2                	ld	a5,8(sp)
ffffffffc0206804:	89be                	mv	s3,a5
ffffffffc0206806:	b06ff0ef          	jal	ra,ffffffffc0205b0c <put_pgdir.isra.0>
ffffffffc020680a:	854a                	mv	a0,s2
ffffffffc020680c:	ec8fc0ef          	jal	ra,ffffffffc0202ed4 <mm_destroy>
ffffffffc0206810:	bdb5                	j	ffffffffc020668c <do_execve+0x1b8>
ffffffffc0206812:	6762                	ld	a4,24(sp)
ffffffffc0206814:	75a2                	ld	a1,40(sp)
ffffffffc0206816:	854e                	mv	a0,s3
ffffffffc0206818:	00371793          	slli	a5,a4,0x3
ffffffffc020681c:	8f99                	sub	a5,a5,a4
ffffffffc020681e:	00379613          	slli	a2,a5,0x3
ffffffffc0206822:	ec32                	sd	a2,24(sp)
ffffffffc0206824:	83efe0ef          	jal	ra,ffffffffc0204862 <sysfile_read>
ffffffffc0206828:	6662                	ld	a2,24(sp)
ffffffffc020682a:	0ea60c63          	beq	a2,a0,ffffffffc0206922 <do_execve+0x44e>
ffffffffc020682e:	0005079b          	sext.w	a5,a0
ffffffffc0206832:	fc0542e3          	bltz	a0,ffffffffc02067f6 <do_execve+0x322>
ffffffffc0206836:	57fd                	li	a5,-1
ffffffffc0206838:	bf7d                	j	ffffffffc02067f6 <do_execve+0x322>
ffffffffc020683a:	01043d83          	ld	s11,16(s0)
ffffffffc020683e:	7004                	ld	s1,32(s0)
ffffffffc0206840:	77fd                	lui	a5,0xfffff
ffffffffc0206842:	00fdfbb3          	and	s7,s11,a5
ffffffffc0206846:	94ee                	add	s1,s1,s11
ffffffffc0206848:	309df663          	bgeu	s11,s1,ffffffffc0206b54 <do_execve+0x680>
ffffffffc020684c:	89de                	mv	s3,s7
ffffffffc020684e:	a881                	j	ffffffffc020689e <do_execve+0x3ca>
ffffffffc0206850:	6785                	lui	a5,0x1
ffffffffc0206852:	413d8533          	sub	a0,s11,s3
ffffffffc0206856:	99be                	add	s3,s3,a5
ffffffffc0206858:	41b98633          	sub	a2,s3,s11
ffffffffc020685c:	0134f463          	bgeu	s1,s3,ffffffffc0206864 <do_execve+0x390>
ffffffffc0206860:	41b48633          	sub	a2,s1,s11
ffffffffc0206864:	000d3783          	ld	a5,0(s10)
ffffffffc0206868:	6742                	ld	a4,16(sp)
ffffffffc020686a:	000cb583          	ld	a1,0(s9)
ffffffffc020686e:	40fb87b3          	sub	a5,s7,a5
ffffffffc0206872:	8799                	srai	a5,a5,0x6
ffffffffc0206874:	97ba                	add	a5,a5,a4
ffffffffc0206876:	6762                	ld	a4,24(sp)
ffffffffc0206878:	00e7f833          	and	a6,a5,a4
ffffffffc020687c:	07b2                	slli	a5,a5,0xc
ffffffffc020687e:	54b87963          	bgeu	a6,a1,ffffffffc0206dd0 <do_execve+0x8fc>
ffffffffc0206882:	680c                	ld	a1,16(s0)
ffffffffc0206884:	000c3803          	ld	a6,0(s8)
ffffffffc0206888:	7702                	ld	a4,32(sp)
ffffffffc020688a:	40bd85b3          	sub	a1,s11,a1
ffffffffc020688e:	97c2                	add	a5,a5,a6
ffffffffc0206890:	9db2                	add	s11,s11,a2
ffffffffc0206892:	95ba                	add	a1,a1,a4
ffffffffc0206894:	953e                	add	a0,a0,a5
ffffffffc0206896:	0ef040ef          	jal	ra,ffffffffc020b184 <memcpy>
ffffffffc020689a:	1a9df063          	bgeu	s11,s1,ffffffffc0206a3a <do_execve+0x566>
ffffffffc020689e:	01893503          	ld	a0,24(s2)
ffffffffc02068a2:	8652                	mv	a2,s4
ffffffffc02068a4:	85ce                	mv	a1,s3
ffffffffc02068a6:	bfafc0ef          	jal	ra,ffffffffc0202ca0 <pgdir_alloc_page>
ffffffffc02068aa:	8baa                	mv	s7,a0
ffffffffc02068ac:	f155                	bnez	a0,ffffffffc0206850 <do_execve+0x37c>
ffffffffc02068ae:	7502                	ld	a0,32(sp)
ffffffffc02068b0:	7be2                	ld	s7,56(sp)
ffffffffc02068b2:	69c6                	ld	s3,80(sp)
ffffffffc02068b4:	6a66                	ld	s4,88(sp)
ffffffffc02068b6:	6406                	ld	s0,64(sp)
ffffffffc02068b8:	4da6                	lw	s11,72(sp)
ffffffffc02068ba:	fb9fc0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc02068be:	854a                	mv	a0,s2
ffffffffc02068c0:	fb0fc0ef          	jal	ra,ffffffffc0203070 <exit_mmap>
ffffffffc02068c4:	7522                	ld	a0,40(sp)
ffffffffc02068c6:	fadfc0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc02068ca:	01893503          	ld	a0,24(s2)
ffffffffc02068ce:	a3eff0ef          	jal	ra,ffffffffc0205b0c <put_pgdir.isra.0>
ffffffffc02068d2:	854a                	mv	a0,s2
ffffffffc02068d4:	e00fc0ef          	jal	ra,ffffffffc0202ed4 <mm_destroy>
ffffffffc02068d8:	854e                	mv	a0,s3
ffffffffc02068da:	f85fd0ef          	jal	ra,ffffffffc020485e <sysfile_close>
ffffffffc02068de:	ff0b0793          	addi	a5,s6,-16
ffffffffc02068e2:	147d                	addi	s0,s0,-1
ffffffffc02068e4:	020d9713          	slli	a4,s11,0x20
ffffffffc02068e8:	9bbe                	add	s7,s7,a5
ffffffffc02068ea:	040e                	slli	s0,s0,0x3
ffffffffc02068ec:	01d75793          	srli	a5,a4,0x1d
ffffffffc02068f0:	9b22                	add	s6,s6,s0
ffffffffc02068f2:	40fb8bb3          	sub	s7,s7,a5
ffffffffc02068f6:	000b3503          	ld	a0,0(s6)
ffffffffc02068fa:	1b61                	addi	s6,s6,-8
ffffffffc02068fc:	f77fc0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc0206900:	ff6b9be3          	bne	s7,s6,ffffffffc02068f6 <do_execve+0x422>
ffffffffc0206904:	000ab403          	ld	s0,0(s5)
ffffffffc0206908:	4641                	li	a2,16
ffffffffc020690a:	4581                	li	a1,0
ffffffffc020690c:	0b440413          	addi	s0,s0,180
ffffffffc0206910:	8522                	mv	a0,s0
ffffffffc0206912:	021040ef          	jal	ra,ffffffffc020b132 <memset>
ffffffffc0206916:	463d                	li	a2,15
ffffffffc0206918:	188c                	addi	a1,sp,112
ffffffffc020691a:	8522                	mv	a0,s0
ffffffffc020691c:	069040ef          	jal	ra,ffffffffc020b184 <memcpy>
ffffffffc0206920:	b519                	j	ffffffffc0206726 <do_execve+0x252>
ffffffffc0206922:	0b815703          	lhu	a4,184(sp)
ffffffffc0206926:	7622                	ld	a2,40(sp)
ffffffffc0206928:	00371793          	slli	a5,a4,0x3
ffffffffc020692c:	8f99                	sub	a5,a5,a4
ffffffffc020692e:	078e                	slli	a5,a5,0x3
ffffffffc0206930:	97b2                	add	a5,a5,a2
ffffffffc0206932:	f83e                	sd	a5,48(sp)
ffffffffc0206934:	02f67c63          	bgeu	a2,a5,ffffffffc020696c <do_execve+0x498>
ffffffffc0206938:	57fd                	li	a5,-1
ffffffffc020693a:	e8ce                	sd	s3,80(sp)
ffffffffc020693c:	7982                	ld	s3,32(sp)
ffffffffc020693e:	83b1                	srli	a5,a5,0xc
ffffffffc0206940:	e0a2                	sd	s0,64(sp)
ffffffffc0206942:	ec3e                	sd	a5,24(sp)
ffffffffc0206944:	fc5e                	sd	s7,56(sp)
ffffffffc0206946:	f0a6                	sd	s1,96(sp)
ffffffffc0206948:	ecd2                	sd	s4,88(sp)
ffffffffc020694a:	8432                	mv	s0,a2
ffffffffc020694c:	c4ee                	sw	s11,72(sp)
ffffffffc020694e:	401c                	lw	a5,0(s0)
ffffffffc0206950:	4705                	li	a4,1
ffffffffc0206952:	04e78163          	beq	a5,a4,ffffffffc0206994 <do_execve+0x4c0>
ffffffffc0206956:	77c2                	ld	a5,48(sp)
ffffffffc0206958:	03840413          	addi	s0,s0,56
ffffffffc020695c:	fef469e3          	bltu	s0,a5,ffffffffc020694e <do_execve+0x47a>
ffffffffc0206960:	7be2                	ld	s7,56(sp)
ffffffffc0206962:	7486                	ld	s1,96(sp)
ffffffffc0206964:	69c6                	ld	s3,80(sp)
ffffffffc0206966:	6a66                	ld	s4,88(sp)
ffffffffc0206968:	6406                	ld	s0,64(sp)
ffffffffc020696a:	4da6                	lw	s11,72(sp)
ffffffffc020696c:	7522                	ld	a0,40(sp)
ffffffffc020696e:	f05fc0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc0206972:	4701                	li	a4,0
ffffffffc0206974:	46ad                	li	a3,11
ffffffffc0206976:	00100637          	lui	a2,0x100
ffffffffc020697a:	7ff005b7          	lui	a1,0x7ff00
ffffffffc020697e:	854a                	mv	a0,s2
ffffffffc0206980:	da6fc0ef          	jal	ra,ffffffffc0202f26 <mm_map>
ffffffffc0206984:	87aa                	mv	a5,a0
ffffffffc0206986:	1c050963          	beqz	a0,ffffffffc0206b58 <do_execve+0x684>
ffffffffc020698a:	854a                	mv	a0,s2
ffffffffc020698c:	e43e                	sd	a5,8(sp)
ffffffffc020698e:	ee2fc0ef          	jal	ra,ffffffffc0203070 <exit_mmap>
ffffffffc0206992:	b59d                	j	ffffffffc02067f8 <do_execve+0x324>
ffffffffc0206994:	7410                	ld	a2,40(s0)
ffffffffc0206996:	701c                	ld	a5,32(s0)
ffffffffc0206998:	3ef66863          	bltu	a2,a5,ffffffffc0206d88 <do_execve+0x8b4>
ffffffffc020699c:	405c                	lw	a5,4(s0)
ffffffffc020699e:	0017f693          	andi	a3,a5,1
ffffffffc02069a2:	c291                	beqz	a3,ffffffffc02069a6 <do_execve+0x4d2>
ffffffffc02069a4:	4691                	li	a3,4
ffffffffc02069a6:	0027f713          	andi	a4,a5,2
ffffffffc02069aa:	8b91                	andi	a5,a5,4
ffffffffc02069ac:	c741                	beqz	a4,ffffffffc0206a34 <do_execve+0x560>
ffffffffc02069ae:	0026e693          	ori	a3,a3,2
ffffffffc02069b2:	cfbd                	beqz	a5,ffffffffc0206a30 <do_execve+0x55c>
ffffffffc02069b4:	0016e693          	ori	a3,a3,1
ffffffffc02069b8:	4a4d                	li	s4,19
ffffffffc02069ba:	0026f793          	andi	a5,a3,2
ffffffffc02069be:	ebad                	bnez	a5,ffffffffc0206a30 <do_execve+0x55c>
ffffffffc02069c0:	0046f793          	andi	a5,a3,4
ffffffffc02069c4:	c399                	beqz	a5,ffffffffc02069ca <do_execve+0x4f6>
ffffffffc02069c6:	008a6a13          	ori	s4,s4,8
ffffffffc02069ca:	680c                	ld	a1,16(s0)
ffffffffc02069cc:	4701                	li	a4,0
ffffffffc02069ce:	854a                	mv	a0,s2
ffffffffc02069d0:	d56fc0ef          	jal	ra,ffffffffc0202f26 <mm_map>
ffffffffc02069d4:	87aa                	mv	a5,a0
ffffffffc02069d6:	3c051463          	bnez	a0,ffffffffc0206d9e <do_execve+0x8ca>
ffffffffc02069da:	7008                	ld	a0,32(s0)
ffffffffc02069dc:	de7fc0ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc02069e0:	f02a                	sd	a0,32(sp)
ffffffffc02069e2:	8baa                	mv	s7,a0
ffffffffc02069e4:	3a050763          	beqz	a0,ffffffffc0206d92 <do_execve+0x8be>
ffffffffc02069e8:	6dc6                	ld	s11,80(sp)
ffffffffc02069ea:	640c                	ld	a1,8(s0)
ffffffffc02069ec:	4601                	li	a2,0
ffffffffc02069ee:	856e                	mv	a0,s11
ffffffffc02069f0:	7004                	ld	s1,32(s0)
ffffffffc02069f2:	89efe0ef          	jal	ra,ffffffffc0204a90 <sysfile_seek>
ffffffffc02069f6:	87aa                	mv	a5,a0
ffffffffc02069f8:	e905                	bnez	a0,ffffffffc0206a28 <do_execve+0x554>
ffffffffc02069fa:	8626                	mv	a2,s1
ffffffffc02069fc:	85de                	mv	a1,s7
ffffffffc02069fe:	856e                	mv	a0,s11
ffffffffc0206a00:	e63fd0ef          	jal	ra,ffffffffc0204862 <sysfile_read>
ffffffffc0206a04:	e2a48be3          	beq	s1,a0,ffffffffc020683a <do_execve+0x366>
ffffffffc0206a08:	7be2                	ld	s7,56(sp)
ffffffffc0206a0a:	6406                	ld	s0,64(sp)
ffffffffc0206a0c:	4da6                	lw	s11,72(sp)
ffffffffc0206a0e:	0005079b          	sext.w	a5,a0
ffffffffc0206a12:	00054363          	bltz	a0,ffffffffc0206a18 <do_execve+0x544>
ffffffffc0206a16:	57fd                	li	a5,-1
ffffffffc0206a18:	7502                	ld	a0,32(sp)
ffffffffc0206a1a:	e43e                	sd	a5,8(sp)
ffffffffc0206a1c:	e57fc0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc0206a20:	67a2                	ld	a5,8(sp)
ffffffffc0206a22:	b7a5                	j	ffffffffc020698a <do_execve+0x4b6>
ffffffffc0206a24:	5a75                	li	s4,-3
ffffffffc0206a26:	b301                	j	ffffffffc0206726 <do_execve+0x252>
ffffffffc0206a28:	7be2                	ld	s7,56(sp)
ffffffffc0206a2a:	6406                	ld	s0,64(sp)
ffffffffc0206a2c:	4da6                	lw	s11,72(sp)
ffffffffc0206a2e:	b7ed                	j	ffffffffc0206a18 <do_execve+0x544>
ffffffffc0206a30:	4a5d                	li	s4,23
ffffffffc0206a32:	b779                	j	ffffffffc02069c0 <do_execve+0x4ec>
ffffffffc0206a34:	4a45                	li	s4,17
ffffffffc0206a36:	d3d1                	beqz	a5,ffffffffc02069ba <do_execve+0x4e6>
ffffffffc0206a38:	bfb5                	j	ffffffffc02069b4 <do_execve+0x4e0>
ffffffffc0206a3a:	6804                	ld	s1,16(s0)
ffffffffc0206a3c:	87ce                	mv	a5,s3
ffffffffc0206a3e:	89de                	mv	s3,s7
ffffffffc0206a40:	8bbe                	mv	s7,a5
ffffffffc0206a42:	741c                	ld	a5,40(s0)
ffffffffc0206a44:	94be                	add	s1,s1,a5
ffffffffc0206a46:	097df163          	bgeu	s11,s7,ffffffffc0206ac8 <do_execve+0x5f4>
ffffffffc0206a4a:	0fb48163          	beq	s1,s11,ffffffffc0206b2c <do_execve+0x658>
ffffffffc0206a4e:	6785                	lui	a5,0x1
ffffffffc0206a50:	00fd8533          	add	a0,s11,a5
ffffffffc0206a54:	41750533          	sub	a0,a0,s7
ffffffffc0206a58:	41b48633          	sub	a2,s1,s11
ffffffffc0206a5c:	0174e463          	bltu	s1,s7,ffffffffc0206a64 <do_execve+0x590>
ffffffffc0206a60:	41bb8633          	sub	a2,s7,s11
ffffffffc0206a64:	000d3783          	ld	a5,0(s10)
ffffffffc0206a68:	66c2                	ld	a3,16(sp)
ffffffffc0206a6a:	000cb703          	ld	a4,0(s9)
ffffffffc0206a6e:	40f987b3          	sub	a5,s3,a5
ffffffffc0206a72:	8799                	srai	a5,a5,0x6
ffffffffc0206a74:	97b6                	add	a5,a5,a3
ffffffffc0206a76:	66e2                	ld	a3,24(sp)
ffffffffc0206a78:	00d7f5b3          	and	a1,a5,a3
ffffffffc0206a7c:	00c79693          	slli	a3,a5,0xc
ffffffffc0206a80:	34e5f963          	bgeu	a1,a4,ffffffffc0206dd2 <do_execve+0x8fe>
ffffffffc0206a84:	000c3783          	ld	a5,0(s8)
ffffffffc0206a88:	4581                	li	a1,0
ffffffffc0206a8a:	f4b2                	sd	a2,104(sp)
ffffffffc0206a8c:	97b6                	add	a5,a5,a3
ffffffffc0206a8e:	953e                	add	a0,a0,a5
ffffffffc0206a90:	6a2040ef          	jal	ra,ffffffffc020b132 <memset>
ffffffffc0206a94:	7626                	ld	a2,104(sp)
ffffffffc0206a96:	00cd8833          	add	a6,s11,a2
ffffffffc0206a9a:	0374f463          	bgeu	s1,s7,ffffffffc0206ac2 <do_execve+0x5ee>
ffffffffc0206a9e:	09048763          	beq	s1,a6,ffffffffc0206b2c <do_execve+0x658>
ffffffffc0206aa2:	00007697          	auipc	a3,0x7
ffffffffc0206aa6:	d1668693          	addi	a3,a3,-746 # ffffffffc020d7b8 <CSWTCH.79+0x2d8>
ffffffffc0206aaa:	00005617          	auipc	a2,0x5
ffffffffc0206aae:	07e60613          	addi	a2,a2,126 # ffffffffc020bb28 <commands+0x250>
ffffffffc0206ab2:	34d00593          	li	a1,845
ffffffffc0206ab6:	00007517          	auipc	a0,0x7
ffffffffc0206aba:	b1250513          	addi	a0,a0,-1262 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc0206abe:	f70f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206ac2:	ff7810e3          	bne	a6,s7,ffffffffc0206aa2 <do_execve+0x5ce>
ffffffffc0206ac6:	8dde                	mv	s11,s7
ffffffffc0206ac8:	069df263          	bgeu	s11,s1,ffffffffc0206b2c <do_execve+0x658>
ffffffffc0206acc:	f4a2                	sd	s0,104(sp)
ffffffffc0206ace:	6442                	ld	s0,16(sp)
ffffffffc0206ad0:	a0a1                	j	ffffffffc0206b18 <do_execve+0x644>
ffffffffc0206ad2:	6785                	lui	a5,0x1
ffffffffc0206ad4:	417d8533          	sub	a0,s11,s7
ffffffffc0206ad8:	9bbe                	add	s7,s7,a5
ffffffffc0206ada:	41bb8633          	sub	a2,s7,s11
ffffffffc0206ade:	0174f463          	bgeu	s1,s7,ffffffffc0206ae6 <do_execve+0x612>
ffffffffc0206ae2:	41b48633          	sub	a2,s1,s11
ffffffffc0206ae6:	000d3783          	ld	a5,0(s10)
ffffffffc0206aea:	6762                	ld	a4,24(sp)
ffffffffc0206aec:	000cb583          	ld	a1,0(s9)
ffffffffc0206af0:	40f987b3          	sub	a5,s3,a5
ffffffffc0206af4:	8799                	srai	a5,a5,0x6
ffffffffc0206af6:	97a2                	add	a5,a5,s0
ffffffffc0206af8:	00e7f833          	and	a6,a5,a4
ffffffffc0206afc:	00c79693          	slli	a3,a5,0xc
ffffffffc0206b00:	2cb87963          	bgeu	a6,a1,ffffffffc0206dd2 <do_execve+0x8fe>
ffffffffc0206b04:	000c3783          	ld	a5,0(s8)
ffffffffc0206b08:	9db2                	add	s11,s11,a2
ffffffffc0206b0a:	4581                	li	a1,0
ffffffffc0206b0c:	97b6                	add	a5,a5,a3
ffffffffc0206b0e:	953e                	add	a0,a0,a5
ffffffffc0206b10:	622040ef          	jal	ra,ffffffffc020b132 <memset>
ffffffffc0206b14:	009dfb63          	bgeu	s11,s1,ffffffffc0206b2a <do_execve+0x656>
ffffffffc0206b18:	01893503          	ld	a0,24(s2)
ffffffffc0206b1c:	8652                	mv	a2,s4
ffffffffc0206b1e:	85de                	mv	a1,s7
ffffffffc0206b20:	980fc0ef          	jal	ra,ffffffffc0202ca0 <pgdir_alloc_page>
ffffffffc0206b24:	89aa                	mv	s3,a0
ffffffffc0206b26:	f555                	bnez	a0,ffffffffc0206ad2 <do_execve+0x5fe>
ffffffffc0206b28:	b359                	j	ffffffffc02068ae <do_execve+0x3da>
ffffffffc0206b2a:	7426                	ld	s0,104(sp)
ffffffffc0206b2c:	7502                	ld	a0,32(sp)
ffffffffc0206b2e:	d45fc0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc0206b32:	b515                	j	ffffffffc0206956 <do_execve+0x482>
ffffffffc0206b34:	5a75                	li	s4,-3
ffffffffc0206b36:	be0c12e3          	bnez	s8,ffffffffc020671a <do_execve+0x246>
ffffffffc0206b3a:	b6f5                	j	ffffffffc0206726 <do_execve+0x252>
ffffffffc0206b3c:	ee0c04e3          	beqz	s8,ffffffffc0206a24 <do_execve+0x550>
ffffffffc0206b40:	038c0513          	addi	a0,s8,56
ffffffffc0206b44:	c03fd0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc0206b48:	5a75                	li	s4,-3
ffffffffc0206b4a:	040c2823          	sw	zero,80(s8)
ffffffffc0206b4e:	bee1                	j	ffffffffc0206726 <do_execve+0x252>
ffffffffc0206b50:	59f1                	li	s3,-4
ffffffffc0206b52:	be2d                	j	ffffffffc020668c <do_execve+0x1b8>
ffffffffc0206b54:	84ee                	mv	s1,s11
ffffffffc0206b56:	b5f5                	j	ffffffffc0206a42 <do_execve+0x56e>
ffffffffc0206b58:	01893503          	ld	a0,24(s2)
ffffffffc0206b5c:	467d                	li	a2,31
ffffffffc0206b5e:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0206b62:	93efc0ef          	jal	ra,ffffffffc0202ca0 <pgdir_alloc_page>
ffffffffc0206b66:	2a050263          	beqz	a0,ffffffffc0206e0a <do_execve+0x936>
ffffffffc0206b6a:	01893503          	ld	a0,24(s2)
ffffffffc0206b6e:	467d                	li	a2,31
ffffffffc0206b70:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0206b74:	92cfc0ef          	jal	ra,ffffffffc0202ca0 <pgdir_alloc_page>
ffffffffc0206b78:	2a050963          	beqz	a0,ffffffffc0206e2a <do_execve+0x956>
ffffffffc0206b7c:	01893503          	ld	a0,24(s2)
ffffffffc0206b80:	467d                	li	a2,31
ffffffffc0206b82:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0206b86:	91afc0ef          	jal	ra,ffffffffc0202ca0 <pgdir_alloc_page>
ffffffffc0206b8a:	26050063          	beqz	a0,ffffffffc0206dea <do_execve+0x916>
ffffffffc0206b8e:	01893503          	ld	a0,24(s2)
ffffffffc0206b92:	467d                	li	a2,31
ffffffffc0206b94:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0206b98:	908fc0ef          	jal	ra,ffffffffc0202ca0 <pgdir_alloc_page>
ffffffffc0206b9c:	20050863          	beqz	a0,ffffffffc0206dac <do_execve+0x8d8>
ffffffffc0206ba0:	4681                	li	a3,0
ffffffffc0206ba2:	ec22                	sd	s0,24(sp)
ffffffffc0206ba4:	d06e                	sw	s11,32(sp)
ffffffffc0206ba6:	4d01                	li	s10,0
ffffffffc0206ba8:	8dd2                	mv	s11,s4
ffffffffc0206baa:	8436                	mv	s0,a3
ffffffffc0206bac:	8a4e                	mv	s4,s3
ffffffffc0206bae:	89ca                	mv	s3,s2
ffffffffc0206bb0:	8926                	mv	s2,s1
ffffffffc0206bb2:	84da                	mv	s1,s6
ffffffffc0206bb4:	6088                	ld	a0,0(s1)
ffffffffc0206bb6:	6585                	lui	a1,0x1
ffffffffc0206bb8:	2405                	addiw	s0,s0,1
ffffffffc0206bba:	4f0040ef          	jal	ra,ffffffffc020b0aa <strnlen>
ffffffffc0206bbe:	67a2                	ld	a5,8(sp)
ffffffffc0206bc0:	00150713          	addi	a4,a0,1
ffffffffc0206bc4:	01a70d3b          	addw	s10,a4,s10
ffffffffc0206bc8:	04a1                	addi	s1,s1,8
ffffffffc0206bca:	fef465e3          	bltu	s0,a5,ffffffffc0206bb4 <do_execve+0x6e0>
ffffffffc0206bce:	100007b7          	lui	a5,0x10000
ffffffffc0206bd2:	003d571b          	srliw	a4,s10,0x3
ffffffffc0206bd6:	17fd                	addi	a5,a5,-1
ffffffffc0206bd8:	8f99                	sub	a5,a5,a4
ffffffffc0206bda:	078e                	slli	a5,a5,0x3
ffffffffc0206bdc:	41778733          	sub	a4,a5,s7
ffffffffc0206be0:	e4be                	sd	a5,72(sp)
ffffffffc0206be2:	57fd                	li	a5,-1
ffffffffc0206be4:	83b1                	srli	a5,a5,0xc
ffffffffc0206be6:	fc3e                	sd	a5,56(sp)
ffffffffc0206be8:	6785                	lui	a5,0x1
ffffffffc0206bea:	17fd                	addi	a5,a5,-1
ffffffffc0206bec:	e0be                	sd	a5,64(sp)
ffffffffc0206bee:	416707b3          	sub	a5,a4,s6
ffffffffc0206bf2:	84ca                	mv	s1,s2
ffffffffc0206bf4:	e8ba                	sd	a4,80(sp)
ffffffffc0206bf6:	894e                	mv	s2,s3
ffffffffc0206bf8:	8d5a                	mv	s10,s6
ffffffffc0206bfa:	89d2                	mv	s3,s4
ffffffffc0206bfc:	f802                	sd	zero,48(sp)
ffffffffc0206bfe:	8a6e                	mv	s4,s11
ffffffffc0206c00:	ecbe                	sd	a5,88(sp)
ffffffffc0206c02:	5d82                	lw	s11,32(sp)
ffffffffc0206c04:	f002                	sd	zero,32(sp)
ffffffffc0206c06:	02016703          	lwu	a4,32(sp)
ffffffffc0206c0a:	67a6                	ld	a5,72(sp)
ffffffffc0206c0c:	01893503          	ld	a0,24(s2)
ffffffffc0206c10:	4601                	li	a2,0
ffffffffc0206c12:	00f70433          	add	s0,a4,a5
ffffffffc0206c16:	85a2                	mv	a1,s0
ffffffffc0206c18:	f8afa0ef          	jal	ra,ffffffffc02013a2 <get_pte>
ffffffffc0206c1c:	18050563          	beqz	a0,ffffffffc0206da6 <do_execve+0x8d2>
ffffffffc0206c20:	611c                	ld	a5,0(a0)
ffffffffc0206c22:	0017f693          	andi	a3,a5,1
ffffffffc0206c26:	18068063          	beqz	a3,ffffffffc0206da6 <do_execve+0x8d2>
ffffffffc0206c2a:	000cb683          	ld	a3,0(s9)
ffffffffc0206c2e:	078a                	slli	a5,a5,0x2
ffffffffc0206c30:	83b1                	srli	a5,a5,0xc
ffffffffc0206c32:	18d7fd63          	bgeu	a5,a3,ffffffffc0206dcc <do_execve+0x8f8>
ffffffffc0206c36:	6742                	ld	a4,16(sp)
ffffffffc0206c38:	8f99                	sub	a5,a5,a4
ffffffffc0206c3a:	079a                	slli	a5,a5,0x6
ffffffffc0206c3c:	8799                	srai	a5,a5,0x6
ffffffffc0206c3e:	97ba                	add	a5,a5,a4
ffffffffc0206c40:	7762                	ld	a4,56(sp)
ffffffffc0206c42:	00e7f633          	and	a2,a5,a4
ffffffffc0206c46:	07b2                	slli	a5,a5,0xc
ffffffffc0206c48:	18d67463          	bgeu	a2,a3,ffffffffc0206dd0 <do_execve+0x8fc>
ffffffffc0206c4c:	000c3683          	ld	a3,0(s8)
ffffffffc0206c50:	6706                	ld	a4,64(sp)
ffffffffc0206c52:	000d3803          	ld	a6,0(s10)
ffffffffc0206c56:	97b6                	add	a5,a5,a3
ffffffffc0206c58:	00e47533          	and	a0,s0,a4
ffffffffc0206c5c:	85c2                	mv	a1,a6
ffffffffc0206c5e:	953e                	add	a0,a0,a5
ffffffffc0206c60:	f4c2                	sd	a6,104(sp)
ffffffffc0206c62:	464040ef          	jal	ra,ffffffffc020b0c6 <strcpy>
ffffffffc0206c66:	67e6                	ld	a5,88(sp)
ffffffffc0206c68:	01893503          	ld	a0,24(s2)
ffffffffc0206c6c:	4601                	li	a2,0
ffffffffc0206c6e:	01a785b3          	add	a1,a5,s10
ffffffffc0206c72:	f0ae                	sd	a1,96(sp)
ffffffffc0206c74:	f2efa0ef          	jal	ra,ffffffffc02013a2 <get_pte>
ffffffffc0206c78:	12050763          	beqz	a0,ffffffffc0206da6 <do_execve+0x8d2>
ffffffffc0206c7c:	611c                	ld	a5,0(a0)
ffffffffc0206c7e:	0017f693          	andi	a3,a5,1
ffffffffc0206c82:	12068263          	beqz	a3,ffffffffc0206da6 <do_execve+0x8d2>
ffffffffc0206c86:	000cb603          	ld	a2,0(s9)
ffffffffc0206c8a:	078a                	slli	a5,a5,0x2
ffffffffc0206c8c:	83b1                	srli	a5,a5,0xc
ffffffffc0206c8e:	12c7ff63          	bgeu	a5,a2,ffffffffc0206dcc <do_execve+0x8f8>
ffffffffc0206c92:	6742                	ld	a4,16(sp)
ffffffffc0206c94:	7586                	ld	a1,96(sp)
ffffffffc0206c96:	7826                	ld	a6,104(sp)
ffffffffc0206c98:	8f99                	sub	a5,a5,a4
ffffffffc0206c9a:	079a                	slli	a5,a5,0x6
ffffffffc0206c9c:	8799                	srai	a5,a5,0x6
ffffffffc0206c9e:	97ba                	add	a5,a5,a4
ffffffffc0206ca0:	7762                	ld	a4,56(sp)
ffffffffc0206ca2:	00c79693          	slli	a3,a5,0xc
ffffffffc0206ca6:	00e7f533          	and	a0,a5,a4
ffffffffc0206caa:	12c57463          	bgeu	a0,a2,ffffffffc0206dd2 <do_execve+0x8fe>
ffffffffc0206cae:	6786                	ld	a5,64(sp)
ffffffffc0206cb0:	000c3603          	ld	a2,0(s8)
ffffffffc0206cb4:	8542                	mv	a0,a6
ffffffffc0206cb6:	8fed                	and	a5,a5,a1
ffffffffc0206cb8:	97b6                	add	a5,a5,a3
ffffffffc0206cba:	97b2                	add	a5,a5,a2
ffffffffc0206cbc:	e380                	sd	s0,0(a5)
ffffffffc0206cbe:	6585                	lui	a1,0x1
ffffffffc0206cc0:	3ea040ef          	jal	ra,ffffffffc020b0aa <strnlen>
ffffffffc0206cc4:	7682                	ld	a3,32(sp)
ffffffffc0206cc6:	7742                	ld	a4,48(sp)
ffffffffc0206cc8:	00150793          	addi	a5,a0,1
ffffffffc0206ccc:	9fb5                	addw	a5,a5,a3
ffffffffc0206cce:	f03e                	sd	a5,32(sp)
ffffffffc0206cd0:	67a2                	ld	a5,8(sp)
ffffffffc0206cd2:	2705                	addiw	a4,a4,1
ffffffffc0206cd4:	f83a                	sd	a4,48(sp)
ffffffffc0206cd6:	0d21                	addi	s10,s10,8
ffffffffc0206cd8:	f2f767e3          	bltu	a4,a5,ffffffffc0206c06 <do_execve+0x732>
ffffffffc0206cdc:	67c6                	ld	a5,80(sp)
ffffffffc0206cde:	01893503          	ld	a0,24(s2)
ffffffffc0206ce2:	4601                	li	a2,0
ffffffffc0206ce4:	ffc78d13          	addi	s10,a5,-4 # ffc <_binary_bin_swap_img_size-0x6d04>
ffffffffc0206ce8:	85ea                	mv	a1,s10
ffffffffc0206cea:	6462                	ld	s0,24(sp)
ffffffffc0206cec:	eb6fa0ef          	jal	ra,ffffffffc02013a2 <get_pte>
ffffffffc0206cf0:	cd45                	beqz	a0,ffffffffc0206da8 <do_execve+0x8d4>
ffffffffc0206cf2:	611c                	ld	a5,0(a0)
ffffffffc0206cf4:	0017f713          	andi	a4,a5,1
ffffffffc0206cf8:	cb45                	beqz	a4,ffffffffc0206da8 <do_execve+0x8d4>
ffffffffc0206cfa:	000cb703          	ld	a4,0(s9)
ffffffffc0206cfe:	078a                	slli	a5,a5,0x2
ffffffffc0206d00:	83b1                	srli	a5,a5,0xc
ffffffffc0206d02:	0ce7f563          	bgeu	a5,a4,ffffffffc0206dcc <do_execve+0x8f8>
ffffffffc0206d06:	65c2                	ld	a1,16(sp)
ffffffffc0206d08:	567d                	li	a2,-1
ffffffffc0206d0a:	40b786b3          	sub	a3,a5,a1
ffffffffc0206d0e:	069a                	slli	a3,a3,0x6
ffffffffc0206d10:	8699                	srai	a3,a3,0x6
ffffffffc0206d12:	96ae                	add	a3,a3,a1
ffffffffc0206d14:	00c65793          	srli	a5,a2,0xc
ffffffffc0206d18:	8ff5                	and	a5,a5,a3
ffffffffc0206d1a:	06b2                	slli	a3,a3,0xc
ffffffffc0206d1c:	0ae7fb63          	bgeu	a5,a4,ffffffffc0206dd2 <do_execve+0x8fe>
ffffffffc0206d20:	000c3583          	ld	a1,0(s8)
ffffffffc0206d24:	6785                	lui	a5,0x1
ffffffffc0206d26:	17fd                	addi	a5,a5,-1
ffffffffc0206d28:	00fd7733          	and	a4,s10,a5
ffffffffc0206d2c:	00b687b3          	add	a5,a3,a1
ffffffffc0206d30:	97ba                	add	a5,a5,a4
ffffffffc0206d32:	c384                	sw	s1,0(a5)
ffffffffc0206d34:	03092703          	lw	a4,48(s2)
ffffffffc0206d38:	000ab783          	ld	a5,0(s5)
ffffffffc0206d3c:	01893683          	ld	a3,24(s2)
ffffffffc0206d40:	2705                	addiw	a4,a4,1
ffffffffc0206d42:	02e92823          	sw	a4,48(s2)
ffffffffc0206d46:	0327b423          	sd	s2,40(a5) # 1028 <_binary_bin_swap_img_size-0x6cd8>
ffffffffc0206d4a:	c0200737          	lui	a4,0xc0200
ffffffffc0206d4e:	0ee6ee63          	bltu	a3,a4,ffffffffc0206e4a <do_execve+0x976>
ffffffffc0206d52:	8e8d                	sub	a3,a3,a1
ffffffffc0206d54:	00c6d713          	srli	a4,a3,0xc
ffffffffc0206d58:	167e                	slli	a2,a2,0x3f
ffffffffc0206d5a:	f7d4                	sd	a3,168(a5)
ffffffffc0206d5c:	8e59                	or	a2,a2,a4
ffffffffc0206d5e:	18061073          	csrw	satp,a2
ffffffffc0206d62:	73c4                	ld	s1,160(a5)
ffffffffc0206d64:	12000613          	li	a2,288
ffffffffc0206d68:	4581                	li	a1,0
ffffffffc0206d6a:	8526                	mv	a0,s1
ffffffffc0206d6c:	1004b903          	ld	s2,256(s1)
ffffffffc0206d70:	3c2040ef          	jal	ra,ffffffffc020b132 <memset>
ffffffffc0206d74:	67ea                	ld	a5,152(sp)
ffffffffc0206d76:	edf97913          	andi	s2,s2,-289
ffffffffc0206d7a:	01a4b823          	sd	s10,16(s1)
ffffffffc0206d7e:	10f4b423          	sd	a5,264(s1)
ffffffffc0206d82:	1124b023          	sd	s2,256(s1)
ffffffffc0206d86:	be89                	j	ffffffffc02068d8 <do_execve+0x404>
ffffffffc0206d88:	7be2                	ld	s7,56(sp)
ffffffffc0206d8a:	6406                	ld	s0,64(sp)
ffffffffc0206d8c:	4da6                	lw	s11,72(sp)
ffffffffc0206d8e:	57e1                	li	a5,-8
ffffffffc0206d90:	beed                	j	ffffffffc020698a <do_execve+0x4b6>
ffffffffc0206d92:	7be2                	ld	s7,56(sp)
ffffffffc0206d94:	69c6                	ld	s3,80(sp)
ffffffffc0206d96:	6a66                	ld	s4,88(sp)
ffffffffc0206d98:	6406                	ld	s0,64(sp)
ffffffffc0206d9a:	4da6                	lw	s11,72(sp)
ffffffffc0206d9c:	b60d                	j	ffffffffc02068be <do_execve+0x3ea>
ffffffffc0206d9e:	7be2                	ld	s7,56(sp)
ffffffffc0206da0:	6406                	ld	s0,64(sp)
ffffffffc0206da2:	4da6                	lw	s11,72(sp)
ffffffffc0206da4:	b6dd                	j	ffffffffc020698a <do_execve+0x4b6>
ffffffffc0206da6:	6462                	ld	s0,24(sp)
ffffffffc0206da8:	57f5                	li	a5,-3
ffffffffc0206daa:	b6c5                	j	ffffffffc020698a <do_execve+0x4b6>
ffffffffc0206dac:	00007697          	auipc	a3,0x7
ffffffffc0206db0:	b2468693          	addi	a3,a3,-1244 # ffffffffc020d8d0 <CSWTCH.79+0x3f0>
ffffffffc0206db4:	00005617          	auipc	a2,0x5
ffffffffc0206db8:	d7460613          	addi	a2,a2,-652 # ffffffffc020bb28 <commands+0x250>
ffffffffc0206dbc:	36c00593          	li	a1,876
ffffffffc0206dc0:	00007517          	auipc	a0,0x7
ffffffffc0206dc4:	80850513          	addi	a0,a0,-2040 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc0206dc8:	c66f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206dcc:	d25fe0ef          	jal	ra,ffffffffc0205af0 <pa2page.part.0>
ffffffffc0206dd0:	86be                	mv	a3,a5
ffffffffc0206dd2:	00005617          	auipc	a2,0x5
ffffffffc0206dd6:	46e60613          	addi	a2,a2,1134 # ffffffffc020c240 <commands+0x968>
ffffffffc0206dda:	07100593          	li	a1,113
ffffffffc0206dde:	00005517          	auipc	a0,0x5
ffffffffc0206de2:	42a50513          	addi	a0,a0,1066 # ffffffffc020c208 <commands+0x930>
ffffffffc0206de6:	c48f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206dea:	00007697          	auipc	a3,0x7
ffffffffc0206dee:	a9e68693          	addi	a3,a3,-1378 # ffffffffc020d888 <CSWTCH.79+0x3a8>
ffffffffc0206df2:	00005617          	auipc	a2,0x5
ffffffffc0206df6:	d3660613          	addi	a2,a2,-714 # ffffffffc020bb28 <commands+0x250>
ffffffffc0206dfa:	36b00593          	li	a1,875
ffffffffc0206dfe:	00006517          	auipc	a0,0x6
ffffffffc0206e02:	7ca50513          	addi	a0,a0,1994 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc0206e06:	c28f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206e0a:	00007697          	auipc	a3,0x7
ffffffffc0206e0e:	9ee68693          	addi	a3,a3,-1554 # ffffffffc020d7f8 <CSWTCH.79+0x318>
ffffffffc0206e12:	00005617          	auipc	a2,0x5
ffffffffc0206e16:	d1660613          	addi	a2,a2,-746 # ffffffffc020bb28 <commands+0x250>
ffffffffc0206e1a:	36900593          	li	a1,873
ffffffffc0206e1e:	00006517          	auipc	a0,0x6
ffffffffc0206e22:	7aa50513          	addi	a0,a0,1962 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc0206e26:	c08f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206e2a:	00007697          	auipc	a3,0x7
ffffffffc0206e2e:	a1668693          	addi	a3,a3,-1514 # ffffffffc020d840 <CSWTCH.79+0x360>
ffffffffc0206e32:	00005617          	auipc	a2,0x5
ffffffffc0206e36:	cf660613          	addi	a2,a2,-778 # ffffffffc020bb28 <commands+0x250>
ffffffffc0206e3a:	36a00593          	li	a1,874
ffffffffc0206e3e:	00006517          	auipc	a0,0x6
ffffffffc0206e42:	78a50513          	addi	a0,a0,1930 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc0206e46:	be8f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206e4a:	00005617          	auipc	a2,0x5
ffffffffc0206e4e:	51660613          	addi	a2,a2,1302 # ffffffffc020c360 <commands+0xa88>
ffffffffc0206e52:	3a300593          	li	a1,931
ffffffffc0206e56:	00006517          	auipc	a0,0x6
ffffffffc0206e5a:	77250513          	addi	a0,a0,1906 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc0206e5e:	bd0f90ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0206e62 <user_main>:
ffffffffc0206e62:	7179                	addi	sp,sp,-48
ffffffffc0206e64:	e84a                	sd	s2,16(sp)
ffffffffc0206e66:	00090917          	auipc	s2,0x90
ffffffffc0206e6a:	a5a90913          	addi	s2,s2,-1446 # ffffffffc02968c0 <current>
ffffffffc0206e6e:	00093783          	ld	a5,0(s2)
ffffffffc0206e72:	00007617          	auipc	a2,0x7
ffffffffc0206e76:	aa660613          	addi	a2,a2,-1370 # ffffffffc020d918 <CSWTCH.79+0x438>
ffffffffc0206e7a:	00007517          	auipc	a0,0x7
ffffffffc0206e7e:	aa650513          	addi	a0,a0,-1370 # ffffffffc020d920 <CSWTCH.79+0x440>
ffffffffc0206e82:	43cc                	lw	a1,4(a5)
ffffffffc0206e84:	f406                	sd	ra,40(sp)
ffffffffc0206e86:	f022                	sd	s0,32(sp)
ffffffffc0206e88:	ec26                	sd	s1,24(sp)
ffffffffc0206e8a:	e032                	sd	a2,0(sp)
ffffffffc0206e8c:	e402                	sd	zero,8(sp)
ffffffffc0206e8e:	a9cf90ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0206e92:	6782                	ld	a5,0(sp)
ffffffffc0206e94:	cfb9                	beqz	a5,ffffffffc0206ef2 <user_main+0x90>
ffffffffc0206e96:	003c                	addi	a5,sp,8
ffffffffc0206e98:	4401                	li	s0,0
ffffffffc0206e9a:	6398                	ld	a4,0(a5)
ffffffffc0206e9c:	0405                	addi	s0,s0,1
ffffffffc0206e9e:	07a1                	addi	a5,a5,8
ffffffffc0206ea0:	ff6d                	bnez	a4,ffffffffc0206e9a <user_main+0x38>
ffffffffc0206ea2:	00093783          	ld	a5,0(s2)
ffffffffc0206ea6:	12000613          	li	a2,288
ffffffffc0206eaa:	6b84                	ld	s1,16(a5)
ffffffffc0206eac:	73cc                	ld	a1,160(a5)
ffffffffc0206eae:	6789                	lui	a5,0x2
ffffffffc0206eb0:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_bin_swap_img_size-0x5e20>
ffffffffc0206eb4:	94be                	add	s1,s1,a5
ffffffffc0206eb6:	8526                	mv	a0,s1
ffffffffc0206eb8:	2cc040ef          	jal	ra,ffffffffc020b184 <memcpy>
ffffffffc0206ebc:	00093783          	ld	a5,0(s2)
ffffffffc0206ec0:	860a                	mv	a2,sp
ffffffffc0206ec2:	0004059b          	sext.w	a1,s0
ffffffffc0206ec6:	f3c4                	sd	s1,160(a5)
ffffffffc0206ec8:	00007517          	auipc	a0,0x7
ffffffffc0206ecc:	a5050513          	addi	a0,a0,-1456 # ffffffffc020d918 <CSWTCH.79+0x438>
ffffffffc0206ed0:	e04ff0ef          	jal	ra,ffffffffc02064d4 <do_execve>
ffffffffc0206ed4:	8126                	mv	sp,s1
ffffffffc0206ed6:	b7efa06f          	j	ffffffffc0201254 <__trapret>
ffffffffc0206eda:	00007617          	auipc	a2,0x7
ffffffffc0206ede:	a6e60613          	addi	a2,a2,-1426 # ffffffffc020d948 <CSWTCH.79+0x468>
ffffffffc0206ee2:	4cc00593          	li	a1,1228
ffffffffc0206ee6:	00006517          	auipc	a0,0x6
ffffffffc0206eea:	6e250513          	addi	a0,a0,1762 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc0206eee:	b40f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206ef2:	4401                	li	s0,0
ffffffffc0206ef4:	b77d                	j	ffffffffc0206ea2 <user_main+0x40>

ffffffffc0206ef6 <do_yield>:
ffffffffc0206ef6:	00090797          	auipc	a5,0x90
ffffffffc0206efa:	9ca7b783          	ld	a5,-1590(a5) # ffffffffc02968c0 <current>
ffffffffc0206efe:	4705                	li	a4,1
ffffffffc0206f00:	ef98                	sd	a4,24(a5)
ffffffffc0206f02:	4501                	li	a0,0
ffffffffc0206f04:	8082                	ret

ffffffffc0206f06 <do_wait>:
ffffffffc0206f06:	1101                	addi	sp,sp,-32
ffffffffc0206f08:	e822                	sd	s0,16(sp)
ffffffffc0206f0a:	e426                	sd	s1,8(sp)
ffffffffc0206f0c:	ec06                	sd	ra,24(sp)
ffffffffc0206f0e:	842e                	mv	s0,a1
ffffffffc0206f10:	84aa                	mv	s1,a0
ffffffffc0206f12:	c999                	beqz	a1,ffffffffc0206f28 <do_wait+0x22>
ffffffffc0206f14:	00090797          	auipc	a5,0x90
ffffffffc0206f18:	9ac7b783          	ld	a5,-1620(a5) # ffffffffc02968c0 <current>
ffffffffc0206f1c:	7788                	ld	a0,40(a5)
ffffffffc0206f1e:	4685                	li	a3,1
ffffffffc0206f20:	4611                	li	a2,4
ffffffffc0206f22:	ceefc0ef          	jal	ra,ffffffffc0203410 <user_mem_check>
ffffffffc0206f26:	c909                	beqz	a0,ffffffffc0206f38 <do_wait+0x32>
ffffffffc0206f28:	85a2                	mv	a1,s0
ffffffffc0206f2a:	6442                	ld	s0,16(sp)
ffffffffc0206f2c:	60e2                	ld	ra,24(sp)
ffffffffc0206f2e:	8526                	mv	a0,s1
ffffffffc0206f30:	64a2                	ld	s1,8(sp)
ffffffffc0206f32:	6105                	addi	sp,sp,32
ffffffffc0206f34:	a92ff06f          	j	ffffffffc02061c6 <do_wait.part.0>
ffffffffc0206f38:	60e2                	ld	ra,24(sp)
ffffffffc0206f3a:	6442                	ld	s0,16(sp)
ffffffffc0206f3c:	64a2                	ld	s1,8(sp)
ffffffffc0206f3e:	5575                	li	a0,-3
ffffffffc0206f40:	6105                	addi	sp,sp,32
ffffffffc0206f42:	8082                	ret

ffffffffc0206f44 <do_kill>:
ffffffffc0206f44:	1141                	addi	sp,sp,-16
ffffffffc0206f46:	6789                	lui	a5,0x2
ffffffffc0206f48:	e406                	sd	ra,8(sp)
ffffffffc0206f4a:	e022                	sd	s0,0(sp)
ffffffffc0206f4c:	fff5071b          	addiw	a4,a0,-1
ffffffffc0206f50:	17f9                	addi	a5,a5,-2
ffffffffc0206f52:	02e7e963          	bltu	a5,a4,ffffffffc0206f84 <do_kill+0x40>
ffffffffc0206f56:	842a                	mv	s0,a0
ffffffffc0206f58:	45a9                	li	a1,10
ffffffffc0206f5a:	2501                	sext.w	a0,a0
ffffffffc0206f5c:	6bc040ef          	jal	ra,ffffffffc020b618 <hash32>
ffffffffc0206f60:	02051793          	slli	a5,a0,0x20
ffffffffc0206f64:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0206f68:	0008b797          	auipc	a5,0x8b
ffffffffc0206f6c:	85878793          	addi	a5,a5,-1960 # ffffffffc02917c0 <hash_list>
ffffffffc0206f70:	953e                	add	a0,a0,a5
ffffffffc0206f72:	87aa                	mv	a5,a0
ffffffffc0206f74:	a029                	j	ffffffffc0206f7e <do_kill+0x3a>
ffffffffc0206f76:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0206f7a:	00870b63          	beq	a4,s0,ffffffffc0206f90 <do_kill+0x4c>
ffffffffc0206f7e:	679c                	ld	a5,8(a5)
ffffffffc0206f80:	fef51be3          	bne	a0,a5,ffffffffc0206f76 <do_kill+0x32>
ffffffffc0206f84:	5475                	li	s0,-3
ffffffffc0206f86:	60a2                	ld	ra,8(sp)
ffffffffc0206f88:	8522                	mv	a0,s0
ffffffffc0206f8a:	6402                	ld	s0,0(sp)
ffffffffc0206f8c:	0141                	addi	sp,sp,16
ffffffffc0206f8e:	8082                	ret
ffffffffc0206f90:	fd87a703          	lw	a4,-40(a5)
ffffffffc0206f94:	00177693          	andi	a3,a4,1
ffffffffc0206f98:	e295                	bnez	a3,ffffffffc0206fbc <do_kill+0x78>
ffffffffc0206f9a:	4bd4                	lw	a3,20(a5)
ffffffffc0206f9c:	00176713          	ori	a4,a4,1
ffffffffc0206fa0:	fce7ac23          	sw	a4,-40(a5)
ffffffffc0206fa4:	4401                	li	s0,0
ffffffffc0206fa6:	fe06d0e3          	bgez	a3,ffffffffc0206f86 <do_kill+0x42>
ffffffffc0206faa:	f2878513          	addi	a0,a5,-216
ffffffffc0206fae:	308000ef          	jal	ra,ffffffffc02072b6 <wakeup_proc>
ffffffffc0206fb2:	60a2                	ld	ra,8(sp)
ffffffffc0206fb4:	8522                	mv	a0,s0
ffffffffc0206fb6:	6402                	ld	s0,0(sp)
ffffffffc0206fb8:	0141                	addi	sp,sp,16
ffffffffc0206fba:	8082                	ret
ffffffffc0206fbc:	545d                	li	s0,-9
ffffffffc0206fbe:	b7e1                	j	ffffffffc0206f86 <do_kill+0x42>

ffffffffc0206fc0 <proc_init>:
ffffffffc0206fc0:	1101                	addi	sp,sp,-32
ffffffffc0206fc2:	e426                	sd	s1,8(sp)
ffffffffc0206fc4:	0008e797          	auipc	a5,0x8e
ffffffffc0206fc8:	7fc78793          	addi	a5,a5,2044 # ffffffffc02957c0 <proc_list>
ffffffffc0206fcc:	ec06                	sd	ra,24(sp)
ffffffffc0206fce:	e822                	sd	s0,16(sp)
ffffffffc0206fd0:	e04a                	sd	s2,0(sp)
ffffffffc0206fd2:	0008a497          	auipc	s1,0x8a
ffffffffc0206fd6:	7ee48493          	addi	s1,s1,2030 # ffffffffc02917c0 <hash_list>
ffffffffc0206fda:	e79c                	sd	a5,8(a5)
ffffffffc0206fdc:	e39c                	sd	a5,0(a5)
ffffffffc0206fde:	0008e717          	auipc	a4,0x8e
ffffffffc0206fe2:	7e270713          	addi	a4,a4,2018 # ffffffffc02957c0 <proc_list>
ffffffffc0206fe6:	87a6                	mv	a5,s1
ffffffffc0206fe8:	e79c                	sd	a5,8(a5)
ffffffffc0206fea:	e39c                	sd	a5,0(a5)
ffffffffc0206fec:	07c1                	addi	a5,a5,16
ffffffffc0206fee:	fef71de3          	bne	a4,a5,ffffffffc0206fe8 <proc_init+0x28>
ffffffffc0206ff2:	a57fe0ef          	jal	ra,ffffffffc0205a48 <alloc_proc>
ffffffffc0206ff6:	00090917          	auipc	s2,0x90
ffffffffc0206ffa:	8d290913          	addi	s2,s2,-1838 # ffffffffc02968c8 <idleproc>
ffffffffc0206ffe:	00a93023          	sd	a0,0(s2)
ffffffffc0207002:	842a                	mv	s0,a0
ffffffffc0207004:	12050863          	beqz	a0,ffffffffc0207134 <proc_init+0x174>
ffffffffc0207008:	4789                	li	a5,2
ffffffffc020700a:	e11c                	sd	a5,0(a0)
ffffffffc020700c:	0000a797          	auipc	a5,0xa
ffffffffc0207010:	ff478793          	addi	a5,a5,-12 # ffffffffc0211000 <bootstack>
ffffffffc0207014:	e91c                	sd	a5,16(a0)
ffffffffc0207016:	4785                	li	a5,1
ffffffffc0207018:	ed1c                	sd	a5,24(a0)
ffffffffc020701a:	fccfe0ef          	jal	ra,ffffffffc02057e6 <files_create>
ffffffffc020701e:	14a43423          	sd	a0,328(s0)
ffffffffc0207022:	0e050d63          	beqz	a0,ffffffffc020711c <proc_init+0x15c>
ffffffffc0207026:	00093403          	ld	s0,0(s2)
ffffffffc020702a:	4641                	li	a2,16
ffffffffc020702c:	4581                	li	a1,0
ffffffffc020702e:	14843703          	ld	a4,328(s0)
ffffffffc0207032:	0b440413          	addi	s0,s0,180
ffffffffc0207036:	8522                	mv	a0,s0
ffffffffc0207038:	4b1c                	lw	a5,16(a4)
ffffffffc020703a:	2785                	addiw	a5,a5,1
ffffffffc020703c:	cb1c                	sw	a5,16(a4)
ffffffffc020703e:	0f4040ef          	jal	ra,ffffffffc020b132 <memset>
ffffffffc0207042:	463d                	li	a2,15
ffffffffc0207044:	00007597          	auipc	a1,0x7
ffffffffc0207048:	96458593          	addi	a1,a1,-1692 # ffffffffc020d9a8 <CSWTCH.79+0x4c8>
ffffffffc020704c:	8522                	mv	a0,s0
ffffffffc020704e:	136040ef          	jal	ra,ffffffffc020b184 <memcpy>
ffffffffc0207052:	00090717          	auipc	a4,0x90
ffffffffc0207056:	88670713          	addi	a4,a4,-1914 # ffffffffc02968d8 <nr_process>
ffffffffc020705a:	431c                	lw	a5,0(a4)
ffffffffc020705c:	00093683          	ld	a3,0(s2)
ffffffffc0207060:	4601                	li	a2,0
ffffffffc0207062:	2785                	addiw	a5,a5,1
ffffffffc0207064:	4581                	li	a1,0
ffffffffc0207066:	fffff517          	auipc	a0,0xfffff
ffffffffc020706a:	31e50513          	addi	a0,a0,798 # ffffffffc0206384 <init_main>
ffffffffc020706e:	c31c                	sw	a5,0(a4)
ffffffffc0207070:	00090797          	auipc	a5,0x90
ffffffffc0207074:	84d7b823          	sd	a3,-1968(a5) # ffffffffc02968c0 <current>
ffffffffc0207078:	f9dfe0ef          	jal	ra,ffffffffc0206014 <kernel_thread>
ffffffffc020707c:	842a                	mv	s0,a0
ffffffffc020707e:	08a05363          	blez	a0,ffffffffc0207104 <proc_init+0x144>
ffffffffc0207082:	6789                	lui	a5,0x2
ffffffffc0207084:	fff5071b          	addiw	a4,a0,-1
ffffffffc0207088:	17f9                	addi	a5,a5,-2
ffffffffc020708a:	2501                	sext.w	a0,a0
ffffffffc020708c:	02e7e363          	bltu	a5,a4,ffffffffc02070b2 <proc_init+0xf2>
ffffffffc0207090:	45a9                	li	a1,10
ffffffffc0207092:	586040ef          	jal	ra,ffffffffc020b618 <hash32>
ffffffffc0207096:	02051793          	slli	a5,a0,0x20
ffffffffc020709a:	01c7d693          	srli	a3,a5,0x1c
ffffffffc020709e:	96a6                	add	a3,a3,s1
ffffffffc02070a0:	87b6                	mv	a5,a3
ffffffffc02070a2:	a029                	j	ffffffffc02070ac <proc_init+0xec>
ffffffffc02070a4:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_bin_swap_img_size-0x5dd4>
ffffffffc02070a8:	04870b63          	beq	a4,s0,ffffffffc02070fe <proc_init+0x13e>
ffffffffc02070ac:	679c                	ld	a5,8(a5)
ffffffffc02070ae:	fef69be3          	bne	a3,a5,ffffffffc02070a4 <proc_init+0xe4>
ffffffffc02070b2:	4781                	li	a5,0
ffffffffc02070b4:	0b478493          	addi	s1,a5,180
ffffffffc02070b8:	4641                	li	a2,16
ffffffffc02070ba:	4581                	li	a1,0
ffffffffc02070bc:	00090417          	auipc	s0,0x90
ffffffffc02070c0:	81440413          	addi	s0,s0,-2028 # ffffffffc02968d0 <initproc>
ffffffffc02070c4:	8526                	mv	a0,s1
ffffffffc02070c6:	e01c                	sd	a5,0(s0)
ffffffffc02070c8:	06a040ef          	jal	ra,ffffffffc020b132 <memset>
ffffffffc02070cc:	463d                	li	a2,15
ffffffffc02070ce:	00007597          	auipc	a1,0x7
ffffffffc02070d2:	90258593          	addi	a1,a1,-1790 # ffffffffc020d9d0 <CSWTCH.79+0x4f0>
ffffffffc02070d6:	8526                	mv	a0,s1
ffffffffc02070d8:	0ac040ef          	jal	ra,ffffffffc020b184 <memcpy>
ffffffffc02070dc:	00093783          	ld	a5,0(s2)
ffffffffc02070e0:	c7d1                	beqz	a5,ffffffffc020716c <proc_init+0x1ac>
ffffffffc02070e2:	43dc                	lw	a5,4(a5)
ffffffffc02070e4:	e7c1                	bnez	a5,ffffffffc020716c <proc_init+0x1ac>
ffffffffc02070e6:	601c                	ld	a5,0(s0)
ffffffffc02070e8:	c3b5                	beqz	a5,ffffffffc020714c <proc_init+0x18c>
ffffffffc02070ea:	43d8                	lw	a4,4(a5)
ffffffffc02070ec:	4785                	li	a5,1
ffffffffc02070ee:	04f71f63          	bne	a4,a5,ffffffffc020714c <proc_init+0x18c>
ffffffffc02070f2:	60e2                	ld	ra,24(sp)
ffffffffc02070f4:	6442                	ld	s0,16(sp)
ffffffffc02070f6:	64a2                	ld	s1,8(sp)
ffffffffc02070f8:	6902                	ld	s2,0(sp)
ffffffffc02070fa:	6105                	addi	sp,sp,32
ffffffffc02070fc:	8082                	ret
ffffffffc02070fe:	f2878793          	addi	a5,a5,-216
ffffffffc0207102:	bf4d                	j	ffffffffc02070b4 <proc_init+0xf4>
ffffffffc0207104:	00007617          	auipc	a2,0x7
ffffffffc0207108:	8ac60613          	addi	a2,a2,-1876 # ffffffffc020d9b0 <CSWTCH.79+0x4d0>
ffffffffc020710c:	51800593          	li	a1,1304
ffffffffc0207110:	00006517          	auipc	a0,0x6
ffffffffc0207114:	4b850513          	addi	a0,a0,1208 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc0207118:	916f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020711c:	00007617          	auipc	a2,0x7
ffffffffc0207120:	86460613          	addi	a2,a2,-1948 # ffffffffc020d980 <CSWTCH.79+0x4a0>
ffffffffc0207124:	50c00593          	li	a1,1292
ffffffffc0207128:	00006517          	auipc	a0,0x6
ffffffffc020712c:	4a050513          	addi	a0,a0,1184 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc0207130:	8fef90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0207134:	00007617          	auipc	a2,0x7
ffffffffc0207138:	83460613          	addi	a2,a2,-1996 # ffffffffc020d968 <CSWTCH.79+0x488>
ffffffffc020713c:	50200593          	li	a1,1282
ffffffffc0207140:	00006517          	auipc	a0,0x6
ffffffffc0207144:	48850513          	addi	a0,a0,1160 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc0207148:	8e6f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020714c:	00007697          	auipc	a3,0x7
ffffffffc0207150:	8b468693          	addi	a3,a3,-1868 # ffffffffc020da00 <CSWTCH.79+0x520>
ffffffffc0207154:	00005617          	auipc	a2,0x5
ffffffffc0207158:	9d460613          	addi	a2,a2,-1580 # ffffffffc020bb28 <commands+0x250>
ffffffffc020715c:	51f00593          	li	a1,1311
ffffffffc0207160:	00006517          	auipc	a0,0x6
ffffffffc0207164:	46850513          	addi	a0,a0,1128 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc0207168:	8c6f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020716c:	00007697          	auipc	a3,0x7
ffffffffc0207170:	86c68693          	addi	a3,a3,-1940 # ffffffffc020d9d8 <CSWTCH.79+0x4f8>
ffffffffc0207174:	00005617          	auipc	a2,0x5
ffffffffc0207178:	9b460613          	addi	a2,a2,-1612 # ffffffffc020bb28 <commands+0x250>
ffffffffc020717c:	51e00593          	li	a1,1310
ffffffffc0207180:	00006517          	auipc	a0,0x6
ffffffffc0207184:	44850513          	addi	a0,a0,1096 # ffffffffc020d5c8 <CSWTCH.79+0xe8>
ffffffffc0207188:	8a6f90ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020718c <cpu_idle>:
ffffffffc020718c:	1141                	addi	sp,sp,-16
ffffffffc020718e:	e022                	sd	s0,0(sp)
ffffffffc0207190:	e406                	sd	ra,8(sp)
ffffffffc0207192:	0008f417          	auipc	s0,0x8f
ffffffffc0207196:	72e40413          	addi	s0,s0,1838 # ffffffffc02968c0 <current>
ffffffffc020719a:	6018                	ld	a4,0(s0)
ffffffffc020719c:	6f1c                	ld	a5,24(a4)
ffffffffc020719e:	dffd                	beqz	a5,ffffffffc020719c <cpu_idle+0x10>
ffffffffc02071a0:	1c8000ef          	jal	ra,ffffffffc0207368 <schedule>
ffffffffc02071a4:	bfdd                	j	ffffffffc020719a <cpu_idle+0xe>

ffffffffc02071a6 <lab6_set_priority>:
ffffffffc02071a6:	1141                	addi	sp,sp,-16
ffffffffc02071a8:	e022                	sd	s0,0(sp)
ffffffffc02071aa:	85aa                	mv	a1,a0
ffffffffc02071ac:	842a                	mv	s0,a0
ffffffffc02071ae:	00007517          	auipc	a0,0x7
ffffffffc02071b2:	87a50513          	addi	a0,a0,-1926 # ffffffffc020da28 <CSWTCH.79+0x548>
ffffffffc02071b6:	e406                	sd	ra,8(sp)
ffffffffc02071b8:	f73f80ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02071bc:	0008f797          	auipc	a5,0x8f
ffffffffc02071c0:	7047b783          	ld	a5,1796(a5) # ffffffffc02968c0 <current>
ffffffffc02071c4:	e801                	bnez	s0,ffffffffc02071d4 <lab6_set_priority+0x2e>
ffffffffc02071c6:	60a2                	ld	ra,8(sp)
ffffffffc02071c8:	6402                	ld	s0,0(sp)
ffffffffc02071ca:	4705                	li	a4,1
ffffffffc02071cc:	14e7a223          	sw	a4,324(a5)
ffffffffc02071d0:	0141                	addi	sp,sp,16
ffffffffc02071d2:	8082                	ret
ffffffffc02071d4:	60a2                	ld	ra,8(sp)
ffffffffc02071d6:	1487a223          	sw	s0,324(a5)
ffffffffc02071da:	6402                	ld	s0,0(sp)
ffffffffc02071dc:	0141                	addi	sp,sp,16
ffffffffc02071de:	8082                	ret

ffffffffc02071e0 <do_sleep>:
ffffffffc02071e0:	c539                	beqz	a0,ffffffffc020722e <do_sleep+0x4e>
ffffffffc02071e2:	7179                	addi	sp,sp,-48
ffffffffc02071e4:	f022                	sd	s0,32(sp)
ffffffffc02071e6:	f406                	sd	ra,40(sp)
ffffffffc02071e8:	842a                	mv	s0,a0
ffffffffc02071ea:	100027f3          	csrr	a5,sstatus
ffffffffc02071ee:	8b89                	andi	a5,a5,2
ffffffffc02071f0:	e3a9                	bnez	a5,ffffffffc0207232 <do_sleep+0x52>
ffffffffc02071f2:	0008f797          	auipc	a5,0x8f
ffffffffc02071f6:	6ce7b783          	ld	a5,1742(a5) # ffffffffc02968c0 <current>
ffffffffc02071fa:	0818                	addi	a4,sp,16
ffffffffc02071fc:	c02a                	sw	a0,0(sp)
ffffffffc02071fe:	ec3a                	sd	a4,24(sp)
ffffffffc0207200:	e83a                	sd	a4,16(sp)
ffffffffc0207202:	e43e                	sd	a5,8(sp)
ffffffffc0207204:	4705                	li	a4,1
ffffffffc0207206:	c398                	sw	a4,0(a5)
ffffffffc0207208:	80000737          	lui	a4,0x80000
ffffffffc020720c:	840a                	mv	s0,sp
ffffffffc020720e:	0709                	addi	a4,a4,2
ffffffffc0207210:	0ee7a623          	sw	a4,236(a5)
ffffffffc0207214:	8522                	mv	a0,s0
ffffffffc0207216:	212000ef          	jal	ra,ffffffffc0207428 <add_timer>
ffffffffc020721a:	14e000ef          	jal	ra,ffffffffc0207368 <schedule>
ffffffffc020721e:	8522                	mv	a0,s0
ffffffffc0207220:	2d0000ef          	jal	ra,ffffffffc02074f0 <del_timer>
ffffffffc0207224:	70a2                	ld	ra,40(sp)
ffffffffc0207226:	7402                	ld	s0,32(sp)
ffffffffc0207228:	4501                	li	a0,0
ffffffffc020722a:	6145                	addi	sp,sp,48
ffffffffc020722c:	8082                	ret
ffffffffc020722e:	4501                	li	a0,0
ffffffffc0207230:	8082                	ret
ffffffffc0207232:	b6ff90ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0207236:	0008f797          	auipc	a5,0x8f
ffffffffc020723a:	68a7b783          	ld	a5,1674(a5) # ffffffffc02968c0 <current>
ffffffffc020723e:	0818                	addi	a4,sp,16
ffffffffc0207240:	c022                	sw	s0,0(sp)
ffffffffc0207242:	e43e                	sd	a5,8(sp)
ffffffffc0207244:	ec3a                	sd	a4,24(sp)
ffffffffc0207246:	e83a                	sd	a4,16(sp)
ffffffffc0207248:	4705                	li	a4,1
ffffffffc020724a:	c398                	sw	a4,0(a5)
ffffffffc020724c:	80000737          	lui	a4,0x80000
ffffffffc0207250:	0709                	addi	a4,a4,2
ffffffffc0207252:	840a                	mv	s0,sp
ffffffffc0207254:	8522                	mv	a0,s0
ffffffffc0207256:	0ee7a623          	sw	a4,236(a5)
ffffffffc020725a:	1ce000ef          	jal	ra,ffffffffc0207428 <add_timer>
ffffffffc020725e:	b3df90ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0207262:	bf65                	j	ffffffffc020721a <do_sleep+0x3a>

ffffffffc0207264 <sched_init>:
ffffffffc0207264:	1141                	addi	sp,sp,-16
ffffffffc0207266:	0008a717          	auipc	a4,0x8a
ffffffffc020726a:	dba70713          	addi	a4,a4,-582 # ffffffffc0291020 <default_sched_class>
ffffffffc020726e:	e022                	sd	s0,0(sp)
ffffffffc0207270:	e406                	sd	ra,8(sp)
ffffffffc0207272:	0008e797          	auipc	a5,0x8e
ffffffffc0207276:	57e78793          	addi	a5,a5,1406 # ffffffffc02957f0 <timer_list>
ffffffffc020727a:	6714                	ld	a3,8(a4)
ffffffffc020727c:	0008e517          	auipc	a0,0x8e
ffffffffc0207280:	55450513          	addi	a0,a0,1364 # ffffffffc02957d0 <__rq>
ffffffffc0207284:	e79c                	sd	a5,8(a5)
ffffffffc0207286:	e39c                	sd	a5,0(a5)
ffffffffc0207288:	4795                	li	a5,5
ffffffffc020728a:	c95c                	sw	a5,20(a0)
ffffffffc020728c:	0008f417          	auipc	s0,0x8f
ffffffffc0207290:	65c40413          	addi	s0,s0,1628 # ffffffffc02968e8 <sched_class>
ffffffffc0207294:	0008f797          	auipc	a5,0x8f
ffffffffc0207298:	64a7b623          	sd	a0,1612(a5) # ffffffffc02968e0 <rq>
ffffffffc020729c:	e018                	sd	a4,0(s0)
ffffffffc020729e:	9682                	jalr	a3
ffffffffc02072a0:	601c                	ld	a5,0(s0)
ffffffffc02072a2:	6402                	ld	s0,0(sp)
ffffffffc02072a4:	60a2                	ld	ra,8(sp)
ffffffffc02072a6:	638c                	ld	a1,0(a5)
ffffffffc02072a8:	00006517          	auipc	a0,0x6
ffffffffc02072ac:	79850513          	addi	a0,a0,1944 # ffffffffc020da40 <CSWTCH.79+0x560>
ffffffffc02072b0:	0141                	addi	sp,sp,16
ffffffffc02072b2:	e79f806f          	j	ffffffffc020012a <cprintf>

ffffffffc02072b6 <wakeup_proc>:
ffffffffc02072b6:	4118                	lw	a4,0(a0)
ffffffffc02072b8:	1101                	addi	sp,sp,-32
ffffffffc02072ba:	ec06                	sd	ra,24(sp)
ffffffffc02072bc:	e822                	sd	s0,16(sp)
ffffffffc02072be:	e426                	sd	s1,8(sp)
ffffffffc02072c0:	478d                	li	a5,3
ffffffffc02072c2:	08f70363          	beq	a4,a5,ffffffffc0207348 <wakeup_proc+0x92>
ffffffffc02072c6:	842a                	mv	s0,a0
ffffffffc02072c8:	100027f3          	csrr	a5,sstatus
ffffffffc02072cc:	8b89                	andi	a5,a5,2
ffffffffc02072ce:	4481                	li	s1,0
ffffffffc02072d0:	e7bd                	bnez	a5,ffffffffc020733e <wakeup_proc+0x88>
ffffffffc02072d2:	4789                	li	a5,2
ffffffffc02072d4:	04f70863          	beq	a4,a5,ffffffffc0207324 <wakeup_proc+0x6e>
ffffffffc02072d8:	c01c                	sw	a5,0(s0)
ffffffffc02072da:	0e042623          	sw	zero,236(s0)
ffffffffc02072de:	0008f797          	auipc	a5,0x8f
ffffffffc02072e2:	5e27b783          	ld	a5,1506(a5) # ffffffffc02968c0 <current>
ffffffffc02072e6:	02878363          	beq	a5,s0,ffffffffc020730c <wakeup_proc+0x56>
ffffffffc02072ea:	0008f797          	auipc	a5,0x8f
ffffffffc02072ee:	5de7b783          	ld	a5,1502(a5) # ffffffffc02968c8 <idleproc>
ffffffffc02072f2:	00f40d63          	beq	s0,a5,ffffffffc020730c <wakeup_proc+0x56>
ffffffffc02072f6:	0008f797          	auipc	a5,0x8f
ffffffffc02072fa:	5f27b783          	ld	a5,1522(a5) # ffffffffc02968e8 <sched_class>
ffffffffc02072fe:	6b9c                	ld	a5,16(a5)
ffffffffc0207300:	85a2                	mv	a1,s0
ffffffffc0207302:	0008f517          	auipc	a0,0x8f
ffffffffc0207306:	5de53503          	ld	a0,1502(a0) # ffffffffc02968e0 <rq>
ffffffffc020730a:	9782                	jalr	a5
ffffffffc020730c:	e491                	bnez	s1,ffffffffc0207318 <wakeup_proc+0x62>
ffffffffc020730e:	60e2                	ld	ra,24(sp)
ffffffffc0207310:	6442                	ld	s0,16(sp)
ffffffffc0207312:	64a2                	ld	s1,8(sp)
ffffffffc0207314:	6105                	addi	sp,sp,32
ffffffffc0207316:	8082                	ret
ffffffffc0207318:	6442                	ld	s0,16(sp)
ffffffffc020731a:	60e2                	ld	ra,24(sp)
ffffffffc020731c:	64a2                	ld	s1,8(sp)
ffffffffc020731e:	6105                	addi	sp,sp,32
ffffffffc0207320:	a7bf906f          	j	ffffffffc0200d9a <intr_enable>
ffffffffc0207324:	00006617          	auipc	a2,0x6
ffffffffc0207328:	76c60613          	addi	a2,a2,1900 # ffffffffc020da90 <CSWTCH.79+0x5b0>
ffffffffc020732c:	05200593          	li	a1,82
ffffffffc0207330:	00006517          	auipc	a0,0x6
ffffffffc0207334:	74850513          	addi	a0,a0,1864 # ffffffffc020da78 <CSWTCH.79+0x598>
ffffffffc0207338:	f5ff80ef          	jal	ra,ffffffffc0200296 <__warn>
ffffffffc020733c:	bfc1                	j	ffffffffc020730c <wakeup_proc+0x56>
ffffffffc020733e:	a63f90ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0207342:	4018                	lw	a4,0(s0)
ffffffffc0207344:	4485                	li	s1,1
ffffffffc0207346:	b771                	j	ffffffffc02072d2 <wakeup_proc+0x1c>
ffffffffc0207348:	00006697          	auipc	a3,0x6
ffffffffc020734c:	71068693          	addi	a3,a3,1808 # ffffffffc020da58 <CSWTCH.79+0x578>
ffffffffc0207350:	00004617          	auipc	a2,0x4
ffffffffc0207354:	7d860613          	addi	a2,a2,2008 # ffffffffc020bb28 <commands+0x250>
ffffffffc0207358:	04300593          	li	a1,67
ffffffffc020735c:	00006517          	auipc	a0,0x6
ffffffffc0207360:	71c50513          	addi	a0,a0,1820 # ffffffffc020da78 <CSWTCH.79+0x598>
ffffffffc0207364:	ecbf80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0207368 <schedule>:
ffffffffc0207368:	7179                	addi	sp,sp,-48
ffffffffc020736a:	f406                	sd	ra,40(sp)
ffffffffc020736c:	f022                	sd	s0,32(sp)
ffffffffc020736e:	ec26                	sd	s1,24(sp)
ffffffffc0207370:	e84a                	sd	s2,16(sp)
ffffffffc0207372:	e44e                	sd	s3,8(sp)
ffffffffc0207374:	e052                	sd	s4,0(sp)
ffffffffc0207376:	100027f3          	csrr	a5,sstatus
ffffffffc020737a:	8b89                	andi	a5,a5,2
ffffffffc020737c:	4a01                	li	s4,0
ffffffffc020737e:	e3cd                	bnez	a5,ffffffffc0207420 <schedule+0xb8>
ffffffffc0207380:	0008f497          	auipc	s1,0x8f
ffffffffc0207384:	54048493          	addi	s1,s1,1344 # ffffffffc02968c0 <current>
ffffffffc0207388:	608c                	ld	a1,0(s1)
ffffffffc020738a:	0008f997          	auipc	s3,0x8f
ffffffffc020738e:	55e98993          	addi	s3,s3,1374 # ffffffffc02968e8 <sched_class>
ffffffffc0207392:	0008f917          	auipc	s2,0x8f
ffffffffc0207396:	54e90913          	addi	s2,s2,1358 # ffffffffc02968e0 <rq>
ffffffffc020739a:	4194                	lw	a3,0(a1)
ffffffffc020739c:	0005bc23          	sd	zero,24(a1)
ffffffffc02073a0:	4709                	li	a4,2
ffffffffc02073a2:	0009b783          	ld	a5,0(s3)
ffffffffc02073a6:	00093503          	ld	a0,0(s2)
ffffffffc02073aa:	04e68e63          	beq	a3,a4,ffffffffc0207406 <schedule+0x9e>
ffffffffc02073ae:	739c                	ld	a5,32(a5)
ffffffffc02073b0:	9782                	jalr	a5
ffffffffc02073b2:	842a                	mv	s0,a0
ffffffffc02073b4:	c521                	beqz	a0,ffffffffc02073fc <schedule+0x94>
ffffffffc02073b6:	0009b783          	ld	a5,0(s3)
ffffffffc02073ba:	00093503          	ld	a0,0(s2)
ffffffffc02073be:	85a2                	mv	a1,s0
ffffffffc02073c0:	6f9c                	ld	a5,24(a5)
ffffffffc02073c2:	9782                	jalr	a5
ffffffffc02073c4:	441c                	lw	a5,8(s0)
ffffffffc02073c6:	6098                	ld	a4,0(s1)
ffffffffc02073c8:	2785                	addiw	a5,a5,1
ffffffffc02073ca:	c41c                	sw	a5,8(s0)
ffffffffc02073cc:	00870563          	beq	a4,s0,ffffffffc02073d6 <schedule+0x6e>
ffffffffc02073d0:	8522                	mv	a0,s0
ffffffffc02073d2:	f9cfe0ef          	jal	ra,ffffffffc0205b6e <proc_run>
ffffffffc02073d6:	000a1a63          	bnez	s4,ffffffffc02073ea <schedule+0x82>
ffffffffc02073da:	70a2                	ld	ra,40(sp)
ffffffffc02073dc:	7402                	ld	s0,32(sp)
ffffffffc02073de:	64e2                	ld	s1,24(sp)
ffffffffc02073e0:	6942                	ld	s2,16(sp)
ffffffffc02073e2:	69a2                	ld	s3,8(sp)
ffffffffc02073e4:	6a02                	ld	s4,0(sp)
ffffffffc02073e6:	6145                	addi	sp,sp,48
ffffffffc02073e8:	8082                	ret
ffffffffc02073ea:	7402                	ld	s0,32(sp)
ffffffffc02073ec:	70a2                	ld	ra,40(sp)
ffffffffc02073ee:	64e2                	ld	s1,24(sp)
ffffffffc02073f0:	6942                	ld	s2,16(sp)
ffffffffc02073f2:	69a2                	ld	s3,8(sp)
ffffffffc02073f4:	6a02                	ld	s4,0(sp)
ffffffffc02073f6:	6145                	addi	sp,sp,48
ffffffffc02073f8:	9a3f906f          	j	ffffffffc0200d9a <intr_enable>
ffffffffc02073fc:	0008f417          	auipc	s0,0x8f
ffffffffc0207400:	4cc43403          	ld	s0,1228(s0) # ffffffffc02968c8 <idleproc>
ffffffffc0207404:	b7c1                	j	ffffffffc02073c4 <schedule+0x5c>
ffffffffc0207406:	0008f717          	auipc	a4,0x8f
ffffffffc020740a:	4c273703          	ld	a4,1218(a4) # ffffffffc02968c8 <idleproc>
ffffffffc020740e:	fae580e3          	beq	a1,a4,ffffffffc02073ae <schedule+0x46>
ffffffffc0207412:	6b9c                	ld	a5,16(a5)
ffffffffc0207414:	9782                	jalr	a5
ffffffffc0207416:	0009b783          	ld	a5,0(s3)
ffffffffc020741a:	00093503          	ld	a0,0(s2)
ffffffffc020741e:	bf41                	j	ffffffffc02073ae <schedule+0x46>
ffffffffc0207420:	981f90ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0207424:	4a05                	li	s4,1
ffffffffc0207426:	bfa9                	j	ffffffffc0207380 <schedule+0x18>

ffffffffc0207428 <add_timer>:
ffffffffc0207428:	1141                	addi	sp,sp,-16
ffffffffc020742a:	e022                	sd	s0,0(sp)
ffffffffc020742c:	e406                	sd	ra,8(sp)
ffffffffc020742e:	842a                	mv	s0,a0
ffffffffc0207430:	100027f3          	csrr	a5,sstatus
ffffffffc0207434:	8b89                	andi	a5,a5,2
ffffffffc0207436:	4501                	li	a0,0
ffffffffc0207438:	eba5                	bnez	a5,ffffffffc02074a8 <add_timer+0x80>
ffffffffc020743a:	401c                	lw	a5,0(s0)
ffffffffc020743c:	cbb5                	beqz	a5,ffffffffc02074b0 <add_timer+0x88>
ffffffffc020743e:	6418                	ld	a4,8(s0)
ffffffffc0207440:	cb25                	beqz	a4,ffffffffc02074b0 <add_timer+0x88>
ffffffffc0207442:	6c18                	ld	a4,24(s0)
ffffffffc0207444:	01040593          	addi	a1,s0,16
ffffffffc0207448:	08e59463          	bne	a1,a4,ffffffffc02074d0 <add_timer+0xa8>
ffffffffc020744c:	0008e617          	auipc	a2,0x8e
ffffffffc0207450:	3a460613          	addi	a2,a2,932 # ffffffffc02957f0 <timer_list>
ffffffffc0207454:	6618                	ld	a4,8(a2)
ffffffffc0207456:	00c71863          	bne	a4,a2,ffffffffc0207466 <add_timer+0x3e>
ffffffffc020745a:	a80d                	j	ffffffffc020748c <add_timer+0x64>
ffffffffc020745c:	6718                	ld	a4,8(a4)
ffffffffc020745e:	9f95                	subw	a5,a5,a3
ffffffffc0207460:	c01c                	sw	a5,0(s0)
ffffffffc0207462:	02c70563          	beq	a4,a2,ffffffffc020748c <add_timer+0x64>
ffffffffc0207466:	ff072683          	lw	a3,-16(a4)
ffffffffc020746a:	fed7f9e3          	bgeu	a5,a3,ffffffffc020745c <add_timer+0x34>
ffffffffc020746e:	40f687bb          	subw	a5,a3,a5
ffffffffc0207472:	fef72823          	sw	a5,-16(a4)
ffffffffc0207476:	631c                	ld	a5,0(a4)
ffffffffc0207478:	e30c                	sd	a1,0(a4)
ffffffffc020747a:	e78c                	sd	a1,8(a5)
ffffffffc020747c:	ec18                	sd	a4,24(s0)
ffffffffc020747e:	e81c                	sd	a5,16(s0)
ffffffffc0207480:	c105                	beqz	a0,ffffffffc02074a0 <add_timer+0x78>
ffffffffc0207482:	6402                	ld	s0,0(sp)
ffffffffc0207484:	60a2                	ld	ra,8(sp)
ffffffffc0207486:	0141                	addi	sp,sp,16
ffffffffc0207488:	913f906f          	j	ffffffffc0200d9a <intr_enable>
ffffffffc020748c:	0008e717          	auipc	a4,0x8e
ffffffffc0207490:	36470713          	addi	a4,a4,868 # ffffffffc02957f0 <timer_list>
ffffffffc0207494:	631c                	ld	a5,0(a4)
ffffffffc0207496:	e30c                	sd	a1,0(a4)
ffffffffc0207498:	e78c                	sd	a1,8(a5)
ffffffffc020749a:	ec18                	sd	a4,24(s0)
ffffffffc020749c:	e81c                	sd	a5,16(s0)
ffffffffc020749e:	f175                	bnez	a0,ffffffffc0207482 <add_timer+0x5a>
ffffffffc02074a0:	60a2                	ld	ra,8(sp)
ffffffffc02074a2:	6402                	ld	s0,0(sp)
ffffffffc02074a4:	0141                	addi	sp,sp,16
ffffffffc02074a6:	8082                	ret
ffffffffc02074a8:	8f9f90ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc02074ac:	4505                	li	a0,1
ffffffffc02074ae:	b771                	j	ffffffffc020743a <add_timer+0x12>
ffffffffc02074b0:	00006697          	auipc	a3,0x6
ffffffffc02074b4:	60068693          	addi	a3,a3,1536 # ffffffffc020dab0 <CSWTCH.79+0x5d0>
ffffffffc02074b8:	00004617          	auipc	a2,0x4
ffffffffc02074bc:	67060613          	addi	a2,a2,1648 # ffffffffc020bb28 <commands+0x250>
ffffffffc02074c0:	07a00593          	li	a1,122
ffffffffc02074c4:	00006517          	auipc	a0,0x6
ffffffffc02074c8:	5b450513          	addi	a0,a0,1460 # ffffffffc020da78 <CSWTCH.79+0x598>
ffffffffc02074cc:	d63f80ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02074d0:	00006697          	auipc	a3,0x6
ffffffffc02074d4:	61068693          	addi	a3,a3,1552 # ffffffffc020dae0 <CSWTCH.79+0x600>
ffffffffc02074d8:	00004617          	auipc	a2,0x4
ffffffffc02074dc:	65060613          	addi	a2,a2,1616 # ffffffffc020bb28 <commands+0x250>
ffffffffc02074e0:	07b00593          	li	a1,123
ffffffffc02074e4:	00006517          	auipc	a0,0x6
ffffffffc02074e8:	59450513          	addi	a0,a0,1428 # ffffffffc020da78 <CSWTCH.79+0x598>
ffffffffc02074ec:	d43f80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02074f0 <del_timer>:
ffffffffc02074f0:	1101                	addi	sp,sp,-32
ffffffffc02074f2:	e822                	sd	s0,16(sp)
ffffffffc02074f4:	ec06                	sd	ra,24(sp)
ffffffffc02074f6:	e426                	sd	s1,8(sp)
ffffffffc02074f8:	842a                	mv	s0,a0
ffffffffc02074fa:	100027f3          	csrr	a5,sstatus
ffffffffc02074fe:	8b89                	andi	a5,a5,2
ffffffffc0207500:	01050493          	addi	s1,a0,16
ffffffffc0207504:	eb9d                	bnez	a5,ffffffffc020753a <del_timer+0x4a>
ffffffffc0207506:	6d1c                	ld	a5,24(a0)
ffffffffc0207508:	02978463          	beq	a5,s1,ffffffffc0207530 <del_timer+0x40>
ffffffffc020750c:	4114                	lw	a3,0(a0)
ffffffffc020750e:	6918                	ld	a4,16(a0)
ffffffffc0207510:	ce81                	beqz	a3,ffffffffc0207528 <del_timer+0x38>
ffffffffc0207512:	0008e617          	auipc	a2,0x8e
ffffffffc0207516:	2de60613          	addi	a2,a2,734 # ffffffffc02957f0 <timer_list>
ffffffffc020751a:	00c78763          	beq	a5,a2,ffffffffc0207528 <del_timer+0x38>
ffffffffc020751e:	ff07a603          	lw	a2,-16(a5)
ffffffffc0207522:	9eb1                	addw	a3,a3,a2
ffffffffc0207524:	fed7a823          	sw	a3,-16(a5)
ffffffffc0207528:	e71c                	sd	a5,8(a4)
ffffffffc020752a:	e398                	sd	a4,0(a5)
ffffffffc020752c:	ec04                	sd	s1,24(s0)
ffffffffc020752e:	e804                	sd	s1,16(s0)
ffffffffc0207530:	60e2                	ld	ra,24(sp)
ffffffffc0207532:	6442                	ld	s0,16(sp)
ffffffffc0207534:	64a2                	ld	s1,8(sp)
ffffffffc0207536:	6105                	addi	sp,sp,32
ffffffffc0207538:	8082                	ret
ffffffffc020753a:	867f90ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc020753e:	6c1c                	ld	a5,24(s0)
ffffffffc0207540:	02978463          	beq	a5,s1,ffffffffc0207568 <del_timer+0x78>
ffffffffc0207544:	4014                	lw	a3,0(s0)
ffffffffc0207546:	6818                	ld	a4,16(s0)
ffffffffc0207548:	ce81                	beqz	a3,ffffffffc0207560 <del_timer+0x70>
ffffffffc020754a:	0008e617          	auipc	a2,0x8e
ffffffffc020754e:	2a660613          	addi	a2,a2,678 # ffffffffc02957f0 <timer_list>
ffffffffc0207552:	00c78763          	beq	a5,a2,ffffffffc0207560 <del_timer+0x70>
ffffffffc0207556:	ff07a603          	lw	a2,-16(a5)
ffffffffc020755a:	9eb1                	addw	a3,a3,a2
ffffffffc020755c:	fed7a823          	sw	a3,-16(a5)
ffffffffc0207560:	e71c                	sd	a5,8(a4)
ffffffffc0207562:	e398                	sd	a4,0(a5)
ffffffffc0207564:	ec04                	sd	s1,24(s0)
ffffffffc0207566:	e804                	sd	s1,16(s0)
ffffffffc0207568:	6442                	ld	s0,16(sp)
ffffffffc020756a:	60e2                	ld	ra,24(sp)
ffffffffc020756c:	64a2                	ld	s1,8(sp)
ffffffffc020756e:	6105                	addi	sp,sp,32
ffffffffc0207570:	82bf906f          	j	ffffffffc0200d9a <intr_enable>

ffffffffc0207574 <run_timer_list>:
ffffffffc0207574:	7139                	addi	sp,sp,-64
ffffffffc0207576:	fc06                	sd	ra,56(sp)
ffffffffc0207578:	f822                	sd	s0,48(sp)
ffffffffc020757a:	f426                	sd	s1,40(sp)
ffffffffc020757c:	f04a                	sd	s2,32(sp)
ffffffffc020757e:	ec4e                	sd	s3,24(sp)
ffffffffc0207580:	e852                	sd	s4,16(sp)
ffffffffc0207582:	e456                	sd	s5,8(sp)
ffffffffc0207584:	e05a                	sd	s6,0(sp)
ffffffffc0207586:	100027f3          	csrr	a5,sstatus
ffffffffc020758a:	8b89                	andi	a5,a5,2
ffffffffc020758c:	4b01                	li	s6,0
ffffffffc020758e:	efe9                	bnez	a5,ffffffffc0207668 <run_timer_list+0xf4>
ffffffffc0207590:	0008e997          	auipc	s3,0x8e
ffffffffc0207594:	26098993          	addi	s3,s3,608 # ffffffffc02957f0 <timer_list>
ffffffffc0207598:	0089b403          	ld	s0,8(s3)
ffffffffc020759c:	07340a63          	beq	s0,s3,ffffffffc0207610 <run_timer_list+0x9c>
ffffffffc02075a0:	ff042783          	lw	a5,-16(s0)
ffffffffc02075a4:	ff040913          	addi	s2,s0,-16
ffffffffc02075a8:	0e078763          	beqz	a5,ffffffffc0207696 <run_timer_list+0x122>
ffffffffc02075ac:	fff7871b          	addiw	a4,a5,-1
ffffffffc02075b0:	fee42823          	sw	a4,-16(s0)
ffffffffc02075b4:	ef31                	bnez	a4,ffffffffc0207610 <run_timer_list+0x9c>
ffffffffc02075b6:	00006a97          	auipc	s5,0x6
ffffffffc02075ba:	592a8a93          	addi	s5,s5,1426 # ffffffffc020db48 <CSWTCH.79+0x668>
ffffffffc02075be:	00006a17          	auipc	s4,0x6
ffffffffc02075c2:	4baa0a13          	addi	s4,s4,1210 # ffffffffc020da78 <CSWTCH.79+0x598>
ffffffffc02075c6:	a005                	j	ffffffffc02075e6 <run_timer_list+0x72>
ffffffffc02075c8:	0a07d763          	bgez	a5,ffffffffc0207676 <run_timer_list+0x102>
ffffffffc02075cc:	8526                	mv	a0,s1
ffffffffc02075ce:	ce9ff0ef          	jal	ra,ffffffffc02072b6 <wakeup_proc>
ffffffffc02075d2:	854a                	mv	a0,s2
ffffffffc02075d4:	f1dff0ef          	jal	ra,ffffffffc02074f0 <del_timer>
ffffffffc02075d8:	03340c63          	beq	s0,s3,ffffffffc0207610 <run_timer_list+0x9c>
ffffffffc02075dc:	ff042783          	lw	a5,-16(s0)
ffffffffc02075e0:	ff040913          	addi	s2,s0,-16
ffffffffc02075e4:	e795                	bnez	a5,ffffffffc0207610 <run_timer_list+0x9c>
ffffffffc02075e6:	00893483          	ld	s1,8(s2)
ffffffffc02075ea:	6400                	ld	s0,8(s0)
ffffffffc02075ec:	0ec4a783          	lw	a5,236(s1)
ffffffffc02075f0:	ffe1                	bnez	a5,ffffffffc02075c8 <run_timer_list+0x54>
ffffffffc02075f2:	40d4                	lw	a3,4(s1)
ffffffffc02075f4:	8656                	mv	a2,s5
ffffffffc02075f6:	0ba00593          	li	a1,186
ffffffffc02075fa:	8552                	mv	a0,s4
ffffffffc02075fc:	c9bf80ef          	jal	ra,ffffffffc0200296 <__warn>
ffffffffc0207600:	8526                	mv	a0,s1
ffffffffc0207602:	cb5ff0ef          	jal	ra,ffffffffc02072b6 <wakeup_proc>
ffffffffc0207606:	854a                	mv	a0,s2
ffffffffc0207608:	ee9ff0ef          	jal	ra,ffffffffc02074f0 <del_timer>
ffffffffc020760c:	fd3418e3          	bne	s0,s3,ffffffffc02075dc <run_timer_list+0x68>
ffffffffc0207610:	0008f597          	auipc	a1,0x8f
ffffffffc0207614:	2b05b583          	ld	a1,688(a1) # ffffffffc02968c0 <current>
ffffffffc0207618:	c18d                	beqz	a1,ffffffffc020763a <run_timer_list+0xc6>
ffffffffc020761a:	0008f797          	auipc	a5,0x8f
ffffffffc020761e:	2ae7b783          	ld	a5,686(a5) # ffffffffc02968c8 <idleproc>
ffffffffc0207622:	04f58763          	beq	a1,a5,ffffffffc0207670 <run_timer_list+0xfc>
ffffffffc0207626:	0008f797          	auipc	a5,0x8f
ffffffffc020762a:	2c27b783          	ld	a5,706(a5) # ffffffffc02968e8 <sched_class>
ffffffffc020762e:	779c                	ld	a5,40(a5)
ffffffffc0207630:	0008f517          	auipc	a0,0x8f
ffffffffc0207634:	2b053503          	ld	a0,688(a0) # ffffffffc02968e0 <rq>
ffffffffc0207638:	9782                	jalr	a5
ffffffffc020763a:	000b1c63          	bnez	s6,ffffffffc0207652 <run_timer_list+0xde>
ffffffffc020763e:	70e2                	ld	ra,56(sp)
ffffffffc0207640:	7442                	ld	s0,48(sp)
ffffffffc0207642:	74a2                	ld	s1,40(sp)
ffffffffc0207644:	7902                	ld	s2,32(sp)
ffffffffc0207646:	69e2                	ld	s3,24(sp)
ffffffffc0207648:	6a42                	ld	s4,16(sp)
ffffffffc020764a:	6aa2                	ld	s5,8(sp)
ffffffffc020764c:	6b02                	ld	s6,0(sp)
ffffffffc020764e:	6121                	addi	sp,sp,64
ffffffffc0207650:	8082                	ret
ffffffffc0207652:	7442                	ld	s0,48(sp)
ffffffffc0207654:	70e2                	ld	ra,56(sp)
ffffffffc0207656:	74a2                	ld	s1,40(sp)
ffffffffc0207658:	7902                	ld	s2,32(sp)
ffffffffc020765a:	69e2                	ld	s3,24(sp)
ffffffffc020765c:	6a42                	ld	s4,16(sp)
ffffffffc020765e:	6aa2                	ld	s5,8(sp)
ffffffffc0207660:	6b02                	ld	s6,0(sp)
ffffffffc0207662:	6121                	addi	sp,sp,64
ffffffffc0207664:	f36f906f          	j	ffffffffc0200d9a <intr_enable>
ffffffffc0207668:	f38f90ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc020766c:	4b05                	li	s6,1
ffffffffc020766e:	b70d                	j	ffffffffc0207590 <run_timer_list+0x1c>
ffffffffc0207670:	4785                	li	a5,1
ffffffffc0207672:	ed9c                	sd	a5,24(a1)
ffffffffc0207674:	b7d9                	j	ffffffffc020763a <run_timer_list+0xc6>
ffffffffc0207676:	00006697          	auipc	a3,0x6
ffffffffc020767a:	4aa68693          	addi	a3,a3,1194 # ffffffffc020db20 <CSWTCH.79+0x640>
ffffffffc020767e:	00004617          	auipc	a2,0x4
ffffffffc0207682:	4aa60613          	addi	a2,a2,1194 # ffffffffc020bb28 <commands+0x250>
ffffffffc0207686:	0b600593          	li	a1,182
ffffffffc020768a:	00006517          	auipc	a0,0x6
ffffffffc020768e:	3ee50513          	addi	a0,a0,1006 # ffffffffc020da78 <CSWTCH.79+0x598>
ffffffffc0207692:	b9df80ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0207696:	00006697          	auipc	a3,0x6
ffffffffc020769a:	47268693          	addi	a3,a3,1138 # ffffffffc020db08 <CSWTCH.79+0x628>
ffffffffc020769e:	00004617          	auipc	a2,0x4
ffffffffc02076a2:	48a60613          	addi	a2,a2,1162 # ffffffffc020bb28 <commands+0x250>
ffffffffc02076a6:	0ae00593          	li	a1,174
ffffffffc02076aa:	00006517          	auipc	a0,0x6
ffffffffc02076ae:	3ce50513          	addi	a0,a0,974 # ffffffffc020da78 <CSWTCH.79+0x598>
ffffffffc02076b2:	b7df80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02076b6 <RR_init>:
ffffffffc02076b6:	e508                	sd	a0,8(a0)
ffffffffc02076b8:	e108                	sd	a0,0(a0)
ffffffffc02076ba:	00052823          	sw	zero,16(a0)
ffffffffc02076be:	8082                	ret

ffffffffc02076c0 <RR_pick_next>:
ffffffffc02076c0:	651c                	ld	a5,8(a0)
ffffffffc02076c2:	00f50563          	beq	a0,a5,ffffffffc02076cc <RR_pick_next+0xc>
ffffffffc02076c6:	ef078513          	addi	a0,a5,-272
ffffffffc02076ca:	8082                	ret
ffffffffc02076cc:	4501                	li	a0,0
ffffffffc02076ce:	8082                	ret

ffffffffc02076d0 <RR_proc_tick>:
ffffffffc02076d0:	1205a783          	lw	a5,288(a1)
ffffffffc02076d4:	00f05563          	blez	a5,ffffffffc02076de <RR_proc_tick+0xe>
ffffffffc02076d8:	37fd                	addiw	a5,a5,-1
ffffffffc02076da:	12f5a023          	sw	a5,288(a1)
ffffffffc02076de:	e399                	bnez	a5,ffffffffc02076e4 <RR_proc_tick+0x14>
ffffffffc02076e0:	4785                	li	a5,1
ffffffffc02076e2:	ed9c                	sd	a5,24(a1)
ffffffffc02076e4:	8082                	ret

ffffffffc02076e6 <RR_dequeue>:
ffffffffc02076e6:	1185b703          	ld	a4,280(a1)
ffffffffc02076ea:	11058793          	addi	a5,a1,272
ffffffffc02076ee:	02e78363          	beq	a5,a4,ffffffffc0207714 <RR_dequeue+0x2e>
ffffffffc02076f2:	1085b683          	ld	a3,264(a1)
ffffffffc02076f6:	00a69f63          	bne	a3,a0,ffffffffc0207714 <RR_dequeue+0x2e>
ffffffffc02076fa:	1105b503          	ld	a0,272(a1)
ffffffffc02076fe:	4a90                	lw	a2,16(a3)
ffffffffc0207700:	e518                	sd	a4,8(a0)
ffffffffc0207702:	e308                	sd	a0,0(a4)
ffffffffc0207704:	10f5bc23          	sd	a5,280(a1)
ffffffffc0207708:	10f5b823          	sd	a5,272(a1)
ffffffffc020770c:	fff6079b          	addiw	a5,a2,-1
ffffffffc0207710:	ca9c                	sw	a5,16(a3)
ffffffffc0207712:	8082                	ret
ffffffffc0207714:	1141                	addi	sp,sp,-16
ffffffffc0207716:	00006697          	auipc	a3,0x6
ffffffffc020771a:	45268693          	addi	a3,a3,1106 # ffffffffc020db68 <CSWTCH.79+0x688>
ffffffffc020771e:	00004617          	auipc	a2,0x4
ffffffffc0207722:	40a60613          	addi	a2,a2,1034 # ffffffffc020bb28 <commands+0x250>
ffffffffc0207726:	03c00593          	li	a1,60
ffffffffc020772a:	00006517          	auipc	a0,0x6
ffffffffc020772e:	47650513          	addi	a0,a0,1142 # ffffffffc020dba0 <CSWTCH.79+0x6c0>
ffffffffc0207732:	e406                	sd	ra,8(sp)
ffffffffc0207734:	afbf80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0207738 <RR_enqueue>:
ffffffffc0207738:	1185b703          	ld	a4,280(a1)
ffffffffc020773c:	11058793          	addi	a5,a1,272
ffffffffc0207740:	02e79d63          	bne	a5,a4,ffffffffc020777a <RR_enqueue+0x42>
ffffffffc0207744:	6118                	ld	a4,0(a0)
ffffffffc0207746:	1205a683          	lw	a3,288(a1)
ffffffffc020774a:	e11c                	sd	a5,0(a0)
ffffffffc020774c:	e71c                	sd	a5,8(a4)
ffffffffc020774e:	10a5bc23          	sd	a0,280(a1)
ffffffffc0207752:	10e5b823          	sd	a4,272(a1)
ffffffffc0207756:	495c                	lw	a5,20(a0)
ffffffffc0207758:	ea89                	bnez	a3,ffffffffc020776a <RR_enqueue+0x32>
ffffffffc020775a:	12f5a023          	sw	a5,288(a1)
ffffffffc020775e:	491c                	lw	a5,16(a0)
ffffffffc0207760:	10a5b423          	sd	a0,264(a1)
ffffffffc0207764:	2785                	addiw	a5,a5,1
ffffffffc0207766:	c91c                	sw	a5,16(a0)
ffffffffc0207768:	8082                	ret
ffffffffc020776a:	fed7c8e3          	blt	a5,a3,ffffffffc020775a <RR_enqueue+0x22>
ffffffffc020776e:	491c                	lw	a5,16(a0)
ffffffffc0207770:	10a5b423          	sd	a0,264(a1)
ffffffffc0207774:	2785                	addiw	a5,a5,1
ffffffffc0207776:	c91c                	sw	a5,16(a0)
ffffffffc0207778:	8082                	ret
ffffffffc020777a:	1141                	addi	sp,sp,-16
ffffffffc020777c:	00006697          	auipc	a3,0x6
ffffffffc0207780:	44468693          	addi	a3,a3,1092 # ffffffffc020dbc0 <CSWTCH.79+0x6e0>
ffffffffc0207784:	00004617          	auipc	a2,0x4
ffffffffc0207788:	3a460613          	addi	a2,a2,932 # ffffffffc020bb28 <commands+0x250>
ffffffffc020778c:	02800593          	li	a1,40
ffffffffc0207790:	00006517          	auipc	a0,0x6
ffffffffc0207794:	41050513          	addi	a0,a0,1040 # ffffffffc020dba0 <CSWTCH.79+0x6c0>
ffffffffc0207798:	e406                	sd	ra,8(sp)
ffffffffc020779a:	a95f80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020779e <sys_getpid>:
ffffffffc020779e:	0008f797          	auipc	a5,0x8f
ffffffffc02077a2:	1227b783          	ld	a5,290(a5) # ffffffffc02968c0 <current>
ffffffffc02077a6:	43c8                	lw	a0,4(a5)
ffffffffc02077a8:	8082                	ret

ffffffffc02077aa <sys_pgdir>:
ffffffffc02077aa:	4501                	li	a0,0
ffffffffc02077ac:	8082                	ret

ffffffffc02077ae <sys_gettime>:
ffffffffc02077ae:	0008f797          	auipc	a5,0x8f
ffffffffc02077b2:	0d27b783          	ld	a5,210(a5) # ffffffffc0296880 <ticks>
ffffffffc02077b6:	0027951b          	slliw	a0,a5,0x2
ffffffffc02077ba:	9d3d                	addw	a0,a0,a5
ffffffffc02077bc:	0015151b          	slliw	a0,a0,0x1
ffffffffc02077c0:	8082                	ret

ffffffffc02077c2 <sys_lab6_set_priority>:
ffffffffc02077c2:	4108                	lw	a0,0(a0)
ffffffffc02077c4:	1141                	addi	sp,sp,-16
ffffffffc02077c6:	e406                	sd	ra,8(sp)
ffffffffc02077c8:	9dfff0ef          	jal	ra,ffffffffc02071a6 <lab6_set_priority>
ffffffffc02077cc:	60a2                	ld	ra,8(sp)
ffffffffc02077ce:	4501                	li	a0,0
ffffffffc02077d0:	0141                	addi	sp,sp,16
ffffffffc02077d2:	8082                	ret

ffffffffc02077d4 <sys_dup>:
ffffffffc02077d4:	450c                	lw	a1,8(a0)
ffffffffc02077d6:	4108                	lw	a0,0(a0)
ffffffffc02077d8:	cf4fd06f          	j	ffffffffc0204ccc <sysfile_dup>

ffffffffc02077dc <sys_getdirentry>:
ffffffffc02077dc:	650c                	ld	a1,8(a0)
ffffffffc02077de:	4108                	lw	a0,0(a0)
ffffffffc02077e0:	bfcfd06f          	j	ffffffffc0204bdc <sysfile_getdirentry>

ffffffffc02077e4 <sys_getcwd>:
ffffffffc02077e4:	650c                	ld	a1,8(a0)
ffffffffc02077e6:	6108                	ld	a0,0(a0)
ffffffffc02077e8:	b50fd06f          	j	ffffffffc0204b38 <sysfile_getcwd>

ffffffffc02077ec <sys_fsync>:
ffffffffc02077ec:	4108                	lw	a0,0(a0)
ffffffffc02077ee:	b46fd06f          	j	ffffffffc0204b34 <sysfile_fsync>

ffffffffc02077f2 <sys_fstat>:
ffffffffc02077f2:	650c                	ld	a1,8(a0)
ffffffffc02077f4:	4108                	lw	a0,0(a0)
ffffffffc02077f6:	a9efd06f          	j	ffffffffc0204a94 <sysfile_fstat>

ffffffffc02077fa <sys_seek>:
ffffffffc02077fa:	4910                	lw	a2,16(a0)
ffffffffc02077fc:	650c                	ld	a1,8(a0)
ffffffffc02077fe:	4108                	lw	a0,0(a0)
ffffffffc0207800:	a90fd06f          	j	ffffffffc0204a90 <sysfile_seek>

ffffffffc0207804 <sys_write>:
ffffffffc0207804:	6910                	ld	a2,16(a0)
ffffffffc0207806:	650c                	ld	a1,8(a0)
ffffffffc0207808:	4108                	lw	a0,0(a0)
ffffffffc020780a:	96cfd06f          	j	ffffffffc0204976 <sysfile_write>

ffffffffc020780e <sys_read>:
ffffffffc020780e:	6910                	ld	a2,16(a0)
ffffffffc0207810:	650c                	ld	a1,8(a0)
ffffffffc0207812:	4108                	lw	a0,0(a0)
ffffffffc0207814:	84efd06f          	j	ffffffffc0204862 <sysfile_read>

ffffffffc0207818 <sys_close>:
ffffffffc0207818:	4108                	lw	a0,0(a0)
ffffffffc020781a:	844fd06f          	j	ffffffffc020485e <sysfile_close>

ffffffffc020781e <sys_open>:
ffffffffc020781e:	450c                	lw	a1,8(a0)
ffffffffc0207820:	6108                	ld	a0,0(a0)
ffffffffc0207822:	808fd06f          	j	ffffffffc020482a <sysfile_open>

ffffffffc0207826 <sys_putc>:
ffffffffc0207826:	4108                	lw	a0,0(a0)
ffffffffc0207828:	1141                	addi	sp,sp,-16
ffffffffc020782a:	e406                	sd	ra,8(sp)
ffffffffc020782c:	93bf80ef          	jal	ra,ffffffffc0200166 <cputchar>
ffffffffc0207830:	60a2                	ld	ra,8(sp)
ffffffffc0207832:	4501                	li	a0,0
ffffffffc0207834:	0141                	addi	sp,sp,16
ffffffffc0207836:	8082                	ret

ffffffffc0207838 <sys_kill>:
ffffffffc0207838:	4108                	lw	a0,0(a0)
ffffffffc020783a:	f0aff06f          	j	ffffffffc0206f44 <do_kill>

ffffffffc020783e <sys_sleep>:
ffffffffc020783e:	4108                	lw	a0,0(a0)
ffffffffc0207840:	9a1ff06f          	j	ffffffffc02071e0 <do_sleep>

ffffffffc0207844 <sys_yield>:
ffffffffc0207844:	eb2ff06f          	j	ffffffffc0206ef6 <do_yield>

ffffffffc0207848 <sys_exec>:
ffffffffc0207848:	6910                	ld	a2,16(a0)
ffffffffc020784a:	450c                	lw	a1,8(a0)
ffffffffc020784c:	6108                	ld	a0,0(a0)
ffffffffc020784e:	c87fe06f          	j	ffffffffc02064d4 <do_execve>

ffffffffc0207852 <sys_wait>:
ffffffffc0207852:	650c                	ld	a1,8(a0)
ffffffffc0207854:	4108                	lw	a0,0(a0)
ffffffffc0207856:	eb0ff06f          	j	ffffffffc0206f06 <do_wait>

ffffffffc020785a <sys_fork>:
ffffffffc020785a:	0008f797          	auipc	a5,0x8f
ffffffffc020785e:	0667b783          	ld	a5,102(a5) # ffffffffc02968c0 <current>
ffffffffc0207862:	73d0                	ld	a2,160(a5)
ffffffffc0207864:	4501                	li	a0,0
ffffffffc0207866:	6a0c                	ld	a1,16(a2)
ffffffffc0207868:	b6efe06f          	j	ffffffffc0205bd6 <do_fork>

ffffffffc020786c <sys_exit>:
ffffffffc020786c:	4108                	lw	a0,0(a0)
ffffffffc020786e:	ff6fe06f          	j	ffffffffc0206064 <do_exit>

ffffffffc0207872 <syscall>:
ffffffffc0207872:	715d                	addi	sp,sp,-80
ffffffffc0207874:	fc26                	sd	s1,56(sp)
ffffffffc0207876:	0008f497          	auipc	s1,0x8f
ffffffffc020787a:	04a48493          	addi	s1,s1,74 # ffffffffc02968c0 <current>
ffffffffc020787e:	6098                	ld	a4,0(s1)
ffffffffc0207880:	e0a2                	sd	s0,64(sp)
ffffffffc0207882:	f84a                	sd	s2,48(sp)
ffffffffc0207884:	7340                	ld	s0,160(a4)
ffffffffc0207886:	e486                	sd	ra,72(sp)
ffffffffc0207888:	0ff00793          	li	a5,255
ffffffffc020788c:	05042903          	lw	s2,80(s0)
ffffffffc0207890:	0327ee63          	bltu	a5,s2,ffffffffc02078cc <syscall+0x5a>
ffffffffc0207894:	00391713          	slli	a4,s2,0x3
ffffffffc0207898:	00006797          	auipc	a5,0x6
ffffffffc020789c:	3a078793          	addi	a5,a5,928 # ffffffffc020dc38 <syscalls>
ffffffffc02078a0:	97ba                	add	a5,a5,a4
ffffffffc02078a2:	639c                	ld	a5,0(a5)
ffffffffc02078a4:	c785                	beqz	a5,ffffffffc02078cc <syscall+0x5a>
ffffffffc02078a6:	6c28                	ld	a0,88(s0)
ffffffffc02078a8:	702c                	ld	a1,96(s0)
ffffffffc02078aa:	7430                	ld	a2,104(s0)
ffffffffc02078ac:	7834                	ld	a3,112(s0)
ffffffffc02078ae:	7c38                	ld	a4,120(s0)
ffffffffc02078b0:	e42a                	sd	a0,8(sp)
ffffffffc02078b2:	e82e                	sd	a1,16(sp)
ffffffffc02078b4:	ec32                	sd	a2,24(sp)
ffffffffc02078b6:	f036                	sd	a3,32(sp)
ffffffffc02078b8:	f43a                	sd	a4,40(sp)
ffffffffc02078ba:	0028                	addi	a0,sp,8
ffffffffc02078bc:	9782                	jalr	a5
ffffffffc02078be:	60a6                	ld	ra,72(sp)
ffffffffc02078c0:	e828                	sd	a0,80(s0)
ffffffffc02078c2:	6406                	ld	s0,64(sp)
ffffffffc02078c4:	74e2                	ld	s1,56(sp)
ffffffffc02078c6:	7942                	ld	s2,48(sp)
ffffffffc02078c8:	6161                	addi	sp,sp,80
ffffffffc02078ca:	8082                	ret
ffffffffc02078cc:	8522                	mv	a0,s0
ffffffffc02078ce:	ec0f90ef          	jal	ra,ffffffffc0200f8e <print_trapframe>
ffffffffc02078d2:	609c                	ld	a5,0(s1)
ffffffffc02078d4:	86ca                	mv	a3,s2
ffffffffc02078d6:	00006617          	auipc	a2,0x6
ffffffffc02078da:	31a60613          	addi	a2,a2,794 # ffffffffc020dbf0 <CSWTCH.79+0x710>
ffffffffc02078de:	43d8                	lw	a4,4(a5)
ffffffffc02078e0:	0d800593          	li	a1,216
ffffffffc02078e4:	0b478793          	addi	a5,a5,180
ffffffffc02078e8:	00006517          	auipc	a0,0x6
ffffffffc02078ec:	33850513          	addi	a0,a0,824 # ffffffffc020dc20 <CSWTCH.79+0x740>
ffffffffc02078f0:	93ff80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02078f4 <vfs_do_add>:
ffffffffc02078f4:	7139                	addi	sp,sp,-64
ffffffffc02078f6:	fc06                	sd	ra,56(sp)
ffffffffc02078f8:	f822                	sd	s0,48(sp)
ffffffffc02078fa:	f426                	sd	s1,40(sp)
ffffffffc02078fc:	f04a                	sd	s2,32(sp)
ffffffffc02078fe:	ec4e                	sd	s3,24(sp)
ffffffffc0207900:	e852                	sd	s4,16(sp)
ffffffffc0207902:	e456                	sd	s5,8(sp)
ffffffffc0207904:	e05a                	sd	s6,0(sp)
ffffffffc0207906:	0e050b63          	beqz	a0,ffffffffc02079fc <vfs_do_add+0x108>
ffffffffc020790a:	842a                	mv	s0,a0
ffffffffc020790c:	8a2e                	mv	s4,a1
ffffffffc020790e:	8b32                	mv	s6,a2
ffffffffc0207910:	8ab6                	mv	s5,a3
ffffffffc0207912:	c5cd                	beqz	a1,ffffffffc02079bc <vfs_do_add+0xc8>
ffffffffc0207914:	4db8                	lw	a4,88(a1)
ffffffffc0207916:	6785                	lui	a5,0x1
ffffffffc0207918:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc020791c:	0af71163          	bne	a4,a5,ffffffffc02079be <vfs_do_add+0xca>
ffffffffc0207920:	8522                	mv	a0,s0
ffffffffc0207922:	76e030ef          	jal	ra,ffffffffc020b090 <strlen>
ffffffffc0207926:	47fd                	li	a5,31
ffffffffc0207928:	0ca7e663          	bltu	a5,a0,ffffffffc02079f4 <vfs_do_add+0x100>
ffffffffc020792c:	8522                	mv	a0,s0
ffffffffc020792e:	f84f80ef          	jal	ra,ffffffffc02000b2 <strdup>
ffffffffc0207932:	84aa                	mv	s1,a0
ffffffffc0207934:	c171                	beqz	a0,ffffffffc02079f8 <vfs_do_add+0x104>
ffffffffc0207936:	03000513          	li	a0,48
ffffffffc020793a:	e89fb0ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc020793e:	89aa                	mv	s3,a0
ffffffffc0207940:	c92d                	beqz	a0,ffffffffc02079b2 <vfs_do_add+0xbe>
ffffffffc0207942:	0008e517          	auipc	a0,0x8e
ffffffffc0207946:	ece50513          	addi	a0,a0,-306 # ffffffffc0295810 <vdev_list_sem>
ffffffffc020794a:	0008e917          	auipc	s2,0x8e
ffffffffc020794e:	eb690913          	addi	s2,s2,-330 # ffffffffc0295800 <vdev_list>
ffffffffc0207952:	df9fc0ef          	jal	ra,ffffffffc020474a <down>
ffffffffc0207956:	844a                	mv	s0,s2
ffffffffc0207958:	a039                	j	ffffffffc0207966 <vfs_do_add+0x72>
ffffffffc020795a:	fe043503          	ld	a0,-32(s0)
ffffffffc020795e:	85a6                	mv	a1,s1
ffffffffc0207960:	778030ef          	jal	ra,ffffffffc020b0d8 <strcmp>
ffffffffc0207964:	cd2d                	beqz	a0,ffffffffc02079de <vfs_do_add+0xea>
ffffffffc0207966:	6400                	ld	s0,8(s0)
ffffffffc0207968:	ff2419e3          	bne	s0,s2,ffffffffc020795a <vfs_do_add+0x66>
ffffffffc020796c:	6418                	ld	a4,8(s0)
ffffffffc020796e:	02098793          	addi	a5,s3,32
ffffffffc0207972:	0099b023          	sd	s1,0(s3)
ffffffffc0207976:	0149b423          	sd	s4,8(s3)
ffffffffc020797a:	0159bc23          	sd	s5,24(s3)
ffffffffc020797e:	0169b823          	sd	s6,16(s3)
ffffffffc0207982:	e31c                	sd	a5,0(a4)
ffffffffc0207984:	0289b023          	sd	s0,32(s3)
ffffffffc0207988:	02e9b423          	sd	a4,40(s3)
ffffffffc020798c:	0008e517          	auipc	a0,0x8e
ffffffffc0207990:	e8450513          	addi	a0,a0,-380 # ffffffffc0295810 <vdev_list_sem>
ffffffffc0207994:	e41c                	sd	a5,8(s0)
ffffffffc0207996:	4401                	li	s0,0
ffffffffc0207998:	daffc0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc020799c:	70e2                	ld	ra,56(sp)
ffffffffc020799e:	8522                	mv	a0,s0
ffffffffc02079a0:	7442                	ld	s0,48(sp)
ffffffffc02079a2:	74a2                	ld	s1,40(sp)
ffffffffc02079a4:	7902                	ld	s2,32(sp)
ffffffffc02079a6:	69e2                	ld	s3,24(sp)
ffffffffc02079a8:	6a42                	ld	s4,16(sp)
ffffffffc02079aa:	6aa2                	ld	s5,8(sp)
ffffffffc02079ac:	6b02                	ld	s6,0(sp)
ffffffffc02079ae:	6121                	addi	sp,sp,64
ffffffffc02079b0:	8082                	ret
ffffffffc02079b2:	5471                	li	s0,-4
ffffffffc02079b4:	8526                	mv	a0,s1
ffffffffc02079b6:	ebdfb0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc02079ba:	b7cd                	j	ffffffffc020799c <vfs_do_add+0xa8>
ffffffffc02079bc:	d2b5                	beqz	a3,ffffffffc0207920 <vfs_do_add+0x2c>
ffffffffc02079be:	00007697          	auipc	a3,0x7
ffffffffc02079c2:	aa268693          	addi	a3,a3,-1374 # ffffffffc020e460 <syscalls+0x828>
ffffffffc02079c6:	00004617          	auipc	a2,0x4
ffffffffc02079ca:	16260613          	addi	a2,a2,354 # ffffffffc020bb28 <commands+0x250>
ffffffffc02079ce:	08f00593          	li	a1,143
ffffffffc02079d2:	00007517          	auipc	a0,0x7
ffffffffc02079d6:	a7650513          	addi	a0,a0,-1418 # ffffffffc020e448 <syscalls+0x810>
ffffffffc02079da:	855f80ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02079de:	0008e517          	auipc	a0,0x8e
ffffffffc02079e2:	e3250513          	addi	a0,a0,-462 # ffffffffc0295810 <vdev_list_sem>
ffffffffc02079e6:	d61fc0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc02079ea:	854e                	mv	a0,s3
ffffffffc02079ec:	e87fb0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc02079f0:	5425                	li	s0,-23
ffffffffc02079f2:	b7c9                	j	ffffffffc02079b4 <vfs_do_add+0xc0>
ffffffffc02079f4:	5451                	li	s0,-12
ffffffffc02079f6:	b75d                	j	ffffffffc020799c <vfs_do_add+0xa8>
ffffffffc02079f8:	5471                	li	s0,-4
ffffffffc02079fa:	b74d                	j	ffffffffc020799c <vfs_do_add+0xa8>
ffffffffc02079fc:	00007697          	auipc	a3,0x7
ffffffffc0207a00:	a3c68693          	addi	a3,a3,-1476 # ffffffffc020e438 <syscalls+0x800>
ffffffffc0207a04:	00004617          	auipc	a2,0x4
ffffffffc0207a08:	12460613          	addi	a2,a2,292 # ffffffffc020bb28 <commands+0x250>
ffffffffc0207a0c:	08e00593          	li	a1,142
ffffffffc0207a10:	00007517          	auipc	a0,0x7
ffffffffc0207a14:	a3850513          	addi	a0,a0,-1480 # ffffffffc020e448 <syscalls+0x810>
ffffffffc0207a18:	817f80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0207a1c <find_mount.part.0>:
ffffffffc0207a1c:	1141                	addi	sp,sp,-16
ffffffffc0207a1e:	00007697          	auipc	a3,0x7
ffffffffc0207a22:	a1a68693          	addi	a3,a3,-1510 # ffffffffc020e438 <syscalls+0x800>
ffffffffc0207a26:	00004617          	auipc	a2,0x4
ffffffffc0207a2a:	10260613          	addi	a2,a2,258 # ffffffffc020bb28 <commands+0x250>
ffffffffc0207a2e:	0cd00593          	li	a1,205
ffffffffc0207a32:	00007517          	auipc	a0,0x7
ffffffffc0207a36:	a1650513          	addi	a0,a0,-1514 # ffffffffc020e448 <syscalls+0x810>
ffffffffc0207a3a:	e406                	sd	ra,8(sp)
ffffffffc0207a3c:	ff2f80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0207a40 <vfs_devlist_init>:
ffffffffc0207a40:	0008e797          	auipc	a5,0x8e
ffffffffc0207a44:	dc078793          	addi	a5,a5,-576 # ffffffffc0295800 <vdev_list>
ffffffffc0207a48:	4585                	li	a1,1
ffffffffc0207a4a:	0008e517          	auipc	a0,0x8e
ffffffffc0207a4e:	dc650513          	addi	a0,a0,-570 # ffffffffc0295810 <vdev_list_sem>
ffffffffc0207a52:	e79c                	sd	a5,8(a5)
ffffffffc0207a54:	e39c                	sd	a5,0(a5)
ffffffffc0207a56:	ce9fc06f          	j	ffffffffc020473e <sem_init>

ffffffffc0207a5a <vfs_cleanup>:
ffffffffc0207a5a:	1101                	addi	sp,sp,-32
ffffffffc0207a5c:	e426                	sd	s1,8(sp)
ffffffffc0207a5e:	0008e497          	auipc	s1,0x8e
ffffffffc0207a62:	da248493          	addi	s1,s1,-606 # ffffffffc0295800 <vdev_list>
ffffffffc0207a66:	649c                	ld	a5,8(s1)
ffffffffc0207a68:	ec06                	sd	ra,24(sp)
ffffffffc0207a6a:	e822                	sd	s0,16(sp)
ffffffffc0207a6c:	02978e63          	beq	a5,s1,ffffffffc0207aa8 <vfs_cleanup+0x4e>
ffffffffc0207a70:	0008e517          	auipc	a0,0x8e
ffffffffc0207a74:	da050513          	addi	a0,a0,-608 # ffffffffc0295810 <vdev_list_sem>
ffffffffc0207a78:	cd3fc0ef          	jal	ra,ffffffffc020474a <down>
ffffffffc0207a7c:	6480                	ld	s0,8(s1)
ffffffffc0207a7e:	00940b63          	beq	s0,s1,ffffffffc0207a94 <vfs_cleanup+0x3a>
ffffffffc0207a82:	ff043783          	ld	a5,-16(s0)
ffffffffc0207a86:	853e                	mv	a0,a5
ffffffffc0207a88:	c399                	beqz	a5,ffffffffc0207a8e <vfs_cleanup+0x34>
ffffffffc0207a8a:	6bfc                	ld	a5,208(a5)
ffffffffc0207a8c:	9782                	jalr	a5
ffffffffc0207a8e:	6400                	ld	s0,8(s0)
ffffffffc0207a90:	fe9419e3          	bne	s0,s1,ffffffffc0207a82 <vfs_cleanup+0x28>
ffffffffc0207a94:	6442                	ld	s0,16(sp)
ffffffffc0207a96:	60e2                	ld	ra,24(sp)
ffffffffc0207a98:	64a2                	ld	s1,8(sp)
ffffffffc0207a9a:	0008e517          	auipc	a0,0x8e
ffffffffc0207a9e:	d7650513          	addi	a0,a0,-650 # ffffffffc0295810 <vdev_list_sem>
ffffffffc0207aa2:	6105                	addi	sp,sp,32
ffffffffc0207aa4:	ca3fc06f          	j	ffffffffc0204746 <up>
ffffffffc0207aa8:	60e2                	ld	ra,24(sp)
ffffffffc0207aaa:	6442                	ld	s0,16(sp)
ffffffffc0207aac:	64a2                	ld	s1,8(sp)
ffffffffc0207aae:	6105                	addi	sp,sp,32
ffffffffc0207ab0:	8082                	ret

ffffffffc0207ab2 <vfs_get_root>:
ffffffffc0207ab2:	7179                	addi	sp,sp,-48
ffffffffc0207ab4:	f406                	sd	ra,40(sp)
ffffffffc0207ab6:	f022                	sd	s0,32(sp)
ffffffffc0207ab8:	ec26                	sd	s1,24(sp)
ffffffffc0207aba:	e84a                	sd	s2,16(sp)
ffffffffc0207abc:	e44e                	sd	s3,8(sp)
ffffffffc0207abe:	e052                	sd	s4,0(sp)
ffffffffc0207ac0:	c541                	beqz	a0,ffffffffc0207b48 <vfs_get_root+0x96>
ffffffffc0207ac2:	0008e917          	auipc	s2,0x8e
ffffffffc0207ac6:	d3e90913          	addi	s2,s2,-706 # ffffffffc0295800 <vdev_list>
ffffffffc0207aca:	00893783          	ld	a5,8(s2)
ffffffffc0207ace:	07278b63          	beq	a5,s2,ffffffffc0207b44 <vfs_get_root+0x92>
ffffffffc0207ad2:	89aa                	mv	s3,a0
ffffffffc0207ad4:	0008e517          	auipc	a0,0x8e
ffffffffc0207ad8:	d3c50513          	addi	a0,a0,-708 # ffffffffc0295810 <vdev_list_sem>
ffffffffc0207adc:	8a2e                	mv	s4,a1
ffffffffc0207ade:	844a                	mv	s0,s2
ffffffffc0207ae0:	c6bfc0ef          	jal	ra,ffffffffc020474a <down>
ffffffffc0207ae4:	a801                	j	ffffffffc0207af4 <vfs_get_root+0x42>
ffffffffc0207ae6:	fe043583          	ld	a1,-32(s0)
ffffffffc0207aea:	854e                	mv	a0,s3
ffffffffc0207aec:	5ec030ef          	jal	ra,ffffffffc020b0d8 <strcmp>
ffffffffc0207af0:	84aa                	mv	s1,a0
ffffffffc0207af2:	c505                	beqz	a0,ffffffffc0207b1a <vfs_get_root+0x68>
ffffffffc0207af4:	6400                	ld	s0,8(s0)
ffffffffc0207af6:	ff2418e3          	bne	s0,s2,ffffffffc0207ae6 <vfs_get_root+0x34>
ffffffffc0207afa:	54cd                	li	s1,-13
ffffffffc0207afc:	0008e517          	auipc	a0,0x8e
ffffffffc0207b00:	d1450513          	addi	a0,a0,-748 # ffffffffc0295810 <vdev_list_sem>
ffffffffc0207b04:	c43fc0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc0207b08:	70a2                	ld	ra,40(sp)
ffffffffc0207b0a:	7402                	ld	s0,32(sp)
ffffffffc0207b0c:	6942                	ld	s2,16(sp)
ffffffffc0207b0e:	69a2                	ld	s3,8(sp)
ffffffffc0207b10:	6a02                	ld	s4,0(sp)
ffffffffc0207b12:	8526                	mv	a0,s1
ffffffffc0207b14:	64e2                	ld	s1,24(sp)
ffffffffc0207b16:	6145                	addi	sp,sp,48
ffffffffc0207b18:	8082                	ret
ffffffffc0207b1a:	ff043503          	ld	a0,-16(s0)
ffffffffc0207b1e:	c519                	beqz	a0,ffffffffc0207b2c <vfs_get_root+0x7a>
ffffffffc0207b20:	617c                	ld	a5,192(a0)
ffffffffc0207b22:	9782                	jalr	a5
ffffffffc0207b24:	c519                	beqz	a0,ffffffffc0207b32 <vfs_get_root+0x80>
ffffffffc0207b26:	00aa3023          	sd	a0,0(s4)
ffffffffc0207b2a:	bfc9                	j	ffffffffc0207afc <vfs_get_root+0x4a>
ffffffffc0207b2c:	ff843783          	ld	a5,-8(s0)
ffffffffc0207b30:	c399                	beqz	a5,ffffffffc0207b36 <vfs_get_root+0x84>
ffffffffc0207b32:	54c9                	li	s1,-14
ffffffffc0207b34:	b7e1                	j	ffffffffc0207afc <vfs_get_root+0x4a>
ffffffffc0207b36:	fe843503          	ld	a0,-24(s0)
ffffffffc0207b3a:	5ee000ef          	jal	ra,ffffffffc0208128 <inode_ref_inc>
ffffffffc0207b3e:	fe843503          	ld	a0,-24(s0)
ffffffffc0207b42:	b7cd                	j	ffffffffc0207b24 <vfs_get_root+0x72>
ffffffffc0207b44:	54cd                	li	s1,-13
ffffffffc0207b46:	b7c9                	j	ffffffffc0207b08 <vfs_get_root+0x56>
ffffffffc0207b48:	00007697          	auipc	a3,0x7
ffffffffc0207b4c:	8f068693          	addi	a3,a3,-1808 # ffffffffc020e438 <syscalls+0x800>
ffffffffc0207b50:	00004617          	auipc	a2,0x4
ffffffffc0207b54:	fd860613          	addi	a2,a2,-40 # ffffffffc020bb28 <commands+0x250>
ffffffffc0207b58:	04500593          	li	a1,69
ffffffffc0207b5c:	00007517          	auipc	a0,0x7
ffffffffc0207b60:	8ec50513          	addi	a0,a0,-1812 # ffffffffc020e448 <syscalls+0x810>
ffffffffc0207b64:	ecaf80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0207b68 <vfs_get_devname>:
ffffffffc0207b68:	0008e697          	auipc	a3,0x8e
ffffffffc0207b6c:	c9868693          	addi	a3,a3,-872 # ffffffffc0295800 <vdev_list>
ffffffffc0207b70:	87b6                	mv	a5,a3
ffffffffc0207b72:	e511                	bnez	a0,ffffffffc0207b7e <vfs_get_devname+0x16>
ffffffffc0207b74:	a829                	j	ffffffffc0207b8e <vfs_get_devname+0x26>
ffffffffc0207b76:	ff07b703          	ld	a4,-16(a5)
ffffffffc0207b7a:	00a70763          	beq	a4,a0,ffffffffc0207b88 <vfs_get_devname+0x20>
ffffffffc0207b7e:	679c                	ld	a5,8(a5)
ffffffffc0207b80:	fed79be3          	bne	a5,a3,ffffffffc0207b76 <vfs_get_devname+0xe>
ffffffffc0207b84:	4501                	li	a0,0
ffffffffc0207b86:	8082                	ret
ffffffffc0207b88:	fe07b503          	ld	a0,-32(a5)
ffffffffc0207b8c:	8082                	ret
ffffffffc0207b8e:	1141                	addi	sp,sp,-16
ffffffffc0207b90:	00007697          	auipc	a3,0x7
ffffffffc0207b94:	93068693          	addi	a3,a3,-1744 # ffffffffc020e4c0 <syscalls+0x888>
ffffffffc0207b98:	00004617          	auipc	a2,0x4
ffffffffc0207b9c:	f9060613          	addi	a2,a2,-112 # ffffffffc020bb28 <commands+0x250>
ffffffffc0207ba0:	06a00593          	li	a1,106
ffffffffc0207ba4:	00007517          	auipc	a0,0x7
ffffffffc0207ba8:	8a450513          	addi	a0,a0,-1884 # ffffffffc020e448 <syscalls+0x810>
ffffffffc0207bac:	e406                	sd	ra,8(sp)
ffffffffc0207bae:	e80f80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0207bb2 <vfs_add_dev>:
ffffffffc0207bb2:	86b2                	mv	a3,a2
ffffffffc0207bb4:	4601                	li	a2,0
ffffffffc0207bb6:	d3fff06f          	j	ffffffffc02078f4 <vfs_do_add>

ffffffffc0207bba <vfs_mount>:
ffffffffc0207bba:	7179                	addi	sp,sp,-48
ffffffffc0207bbc:	e84a                	sd	s2,16(sp)
ffffffffc0207bbe:	892a                	mv	s2,a0
ffffffffc0207bc0:	0008e517          	auipc	a0,0x8e
ffffffffc0207bc4:	c5050513          	addi	a0,a0,-944 # ffffffffc0295810 <vdev_list_sem>
ffffffffc0207bc8:	e44e                	sd	s3,8(sp)
ffffffffc0207bca:	f406                	sd	ra,40(sp)
ffffffffc0207bcc:	f022                	sd	s0,32(sp)
ffffffffc0207bce:	ec26                	sd	s1,24(sp)
ffffffffc0207bd0:	89ae                	mv	s3,a1
ffffffffc0207bd2:	b79fc0ef          	jal	ra,ffffffffc020474a <down>
ffffffffc0207bd6:	08090a63          	beqz	s2,ffffffffc0207c6a <vfs_mount+0xb0>
ffffffffc0207bda:	0008e497          	auipc	s1,0x8e
ffffffffc0207bde:	c2648493          	addi	s1,s1,-986 # ffffffffc0295800 <vdev_list>
ffffffffc0207be2:	6480                	ld	s0,8(s1)
ffffffffc0207be4:	00941663          	bne	s0,s1,ffffffffc0207bf0 <vfs_mount+0x36>
ffffffffc0207be8:	a8ad                	j	ffffffffc0207c62 <vfs_mount+0xa8>
ffffffffc0207bea:	6400                	ld	s0,8(s0)
ffffffffc0207bec:	06940b63          	beq	s0,s1,ffffffffc0207c62 <vfs_mount+0xa8>
ffffffffc0207bf0:	ff843783          	ld	a5,-8(s0)
ffffffffc0207bf4:	dbfd                	beqz	a5,ffffffffc0207bea <vfs_mount+0x30>
ffffffffc0207bf6:	fe043503          	ld	a0,-32(s0)
ffffffffc0207bfa:	85ca                	mv	a1,s2
ffffffffc0207bfc:	4dc030ef          	jal	ra,ffffffffc020b0d8 <strcmp>
ffffffffc0207c00:	f56d                	bnez	a0,ffffffffc0207bea <vfs_mount+0x30>
ffffffffc0207c02:	ff043783          	ld	a5,-16(s0)
ffffffffc0207c06:	e3a5                	bnez	a5,ffffffffc0207c66 <vfs_mount+0xac>
ffffffffc0207c08:	fe043783          	ld	a5,-32(s0)
ffffffffc0207c0c:	c3c9                	beqz	a5,ffffffffc0207c8e <vfs_mount+0xd4>
ffffffffc0207c0e:	ff843783          	ld	a5,-8(s0)
ffffffffc0207c12:	cfb5                	beqz	a5,ffffffffc0207c8e <vfs_mount+0xd4>
ffffffffc0207c14:	fe843503          	ld	a0,-24(s0)
ffffffffc0207c18:	c939                	beqz	a0,ffffffffc0207c6e <vfs_mount+0xb4>
ffffffffc0207c1a:	4d38                	lw	a4,88(a0)
ffffffffc0207c1c:	6785                	lui	a5,0x1
ffffffffc0207c1e:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0207c22:	04f71663          	bne	a4,a5,ffffffffc0207c6e <vfs_mount+0xb4>
ffffffffc0207c26:	ff040593          	addi	a1,s0,-16
ffffffffc0207c2a:	9982                	jalr	s3
ffffffffc0207c2c:	84aa                	mv	s1,a0
ffffffffc0207c2e:	ed01                	bnez	a0,ffffffffc0207c46 <vfs_mount+0x8c>
ffffffffc0207c30:	ff043783          	ld	a5,-16(s0)
ffffffffc0207c34:	cfad                	beqz	a5,ffffffffc0207cae <vfs_mount+0xf4>
ffffffffc0207c36:	fe043583          	ld	a1,-32(s0)
ffffffffc0207c3a:	00007517          	auipc	a0,0x7
ffffffffc0207c3e:	91650513          	addi	a0,a0,-1770 # ffffffffc020e550 <syscalls+0x918>
ffffffffc0207c42:	ce8f80ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0207c46:	0008e517          	auipc	a0,0x8e
ffffffffc0207c4a:	bca50513          	addi	a0,a0,-1078 # ffffffffc0295810 <vdev_list_sem>
ffffffffc0207c4e:	af9fc0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc0207c52:	70a2                	ld	ra,40(sp)
ffffffffc0207c54:	7402                	ld	s0,32(sp)
ffffffffc0207c56:	6942                	ld	s2,16(sp)
ffffffffc0207c58:	69a2                	ld	s3,8(sp)
ffffffffc0207c5a:	8526                	mv	a0,s1
ffffffffc0207c5c:	64e2                	ld	s1,24(sp)
ffffffffc0207c5e:	6145                	addi	sp,sp,48
ffffffffc0207c60:	8082                	ret
ffffffffc0207c62:	54cd                	li	s1,-13
ffffffffc0207c64:	b7cd                	j	ffffffffc0207c46 <vfs_mount+0x8c>
ffffffffc0207c66:	54c5                	li	s1,-15
ffffffffc0207c68:	bff9                	j	ffffffffc0207c46 <vfs_mount+0x8c>
ffffffffc0207c6a:	db3ff0ef          	jal	ra,ffffffffc0207a1c <find_mount.part.0>
ffffffffc0207c6e:	00007697          	auipc	a3,0x7
ffffffffc0207c72:	89268693          	addi	a3,a3,-1902 # ffffffffc020e500 <syscalls+0x8c8>
ffffffffc0207c76:	00004617          	auipc	a2,0x4
ffffffffc0207c7a:	eb260613          	addi	a2,a2,-334 # ffffffffc020bb28 <commands+0x250>
ffffffffc0207c7e:	0ed00593          	li	a1,237
ffffffffc0207c82:	00006517          	auipc	a0,0x6
ffffffffc0207c86:	7c650513          	addi	a0,a0,1990 # ffffffffc020e448 <syscalls+0x810>
ffffffffc0207c8a:	da4f80ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0207c8e:	00007697          	auipc	a3,0x7
ffffffffc0207c92:	84268693          	addi	a3,a3,-1982 # ffffffffc020e4d0 <syscalls+0x898>
ffffffffc0207c96:	00004617          	auipc	a2,0x4
ffffffffc0207c9a:	e9260613          	addi	a2,a2,-366 # ffffffffc020bb28 <commands+0x250>
ffffffffc0207c9e:	0eb00593          	li	a1,235
ffffffffc0207ca2:	00006517          	auipc	a0,0x6
ffffffffc0207ca6:	7a650513          	addi	a0,a0,1958 # ffffffffc020e448 <syscalls+0x810>
ffffffffc0207caa:	d84f80ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0207cae:	00007697          	auipc	a3,0x7
ffffffffc0207cb2:	88a68693          	addi	a3,a3,-1910 # ffffffffc020e538 <syscalls+0x900>
ffffffffc0207cb6:	00004617          	auipc	a2,0x4
ffffffffc0207cba:	e7260613          	addi	a2,a2,-398 # ffffffffc020bb28 <commands+0x250>
ffffffffc0207cbe:	0ef00593          	li	a1,239
ffffffffc0207cc2:	00006517          	auipc	a0,0x6
ffffffffc0207cc6:	78650513          	addi	a0,a0,1926 # ffffffffc020e448 <syscalls+0x810>
ffffffffc0207cca:	d64f80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0207cce <vfs_get_curdir>:
ffffffffc0207cce:	0008f797          	auipc	a5,0x8f
ffffffffc0207cd2:	bf27b783          	ld	a5,-1038(a5) # ffffffffc02968c0 <current>
ffffffffc0207cd6:	1487b783          	ld	a5,328(a5)
ffffffffc0207cda:	1101                	addi	sp,sp,-32
ffffffffc0207cdc:	e426                	sd	s1,8(sp)
ffffffffc0207cde:	6384                	ld	s1,0(a5)
ffffffffc0207ce0:	ec06                	sd	ra,24(sp)
ffffffffc0207ce2:	e822                	sd	s0,16(sp)
ffffffffc0207ce4:	cc81                	beqz	s1,ffffffffc0207cfc <vfs_get_curdir+0x2e>
ffffffffc0207ce6:	842a                	mv	s0,a0
ffffffffc0207ce8:	8526                	mv	a0,s1
ffffffffc0207cea:	43e000ef          	jal	ra,ffffffffc0208128 <inode_ref_inc>
ffffffffc0207cee:	4501                	li	a0,0
ffffffffc0207cf0:	e004                	sd	s1,0(s0)
ffffffffc0207cf2:	60e2                	ld	ra,24(sp)
ffffffffc0207cf4:	6442                	ld	s0,16(sp)
ffffffffc0207cf6:	64a2                	ld	s1,8(sp)
ffffffffc0207cf8:	6105                	addi	sp,sp,32
ffffffffc0207cfa:	8082                	ret
ffffffffc0207cfc:	5541                	li	a0,-16
ffffffffc0207cfe:	bfd5                	j	ffffffffc0207cf2 <vfs_get_curdir+0x24>

ffffffffc0207d00 <vfs_set_curdir>:
ffffffffc0207d00:	7139                	addi	sp,sp,-64
ffffffffc0207d02:	f04a                	sd	s2,32(sp)
ffffffffc0207d04:	0008f917          	auipc	s2,0x8f
ffffffffc0207d08:	bbc90913          	addi	s2,s2,-1092 # ffffffffc02968c0 <current>
ffffffffc0207d0c:	00093783          	ld	a5,0(s2)
ffffffffc0207d10:	f822                	sd	s0,48(sp)
ffffffffc0207d12:	842a                	mv	s0,a0
ffffffffc0207d14:	1487b503          	ld	a0,328(a5)
ffffffffc0207d18:	ec4e                	sd	s3,24(sp)
ffffffffc0207d1a:	fc06                	sd	ra,56(sp)
ffffffffc0207d1c:	f426                	sd	s1,40(sp)
ffffffffc0207d1e:	abdfd0ef          	jal	ra,ffffffffc02057da <lock_files>
ffffffffc0207d22:	00093783          	ld	a5,0(s2)
ffffffffc0207d26:	1487b503          	ld	a0,328(a5)
ffffffffc0207d2a:	00053983          	ld	s3,0(a0)
ffffffffc0207d2e:	07340963          	beq	s0,s3,ffffffffc0207da0 <vfs_set_curdir+0xa0>
ffffffffc0207d32:	cc39                	beqz	s0,ffffffffc0207d90 <vfs_set_curdir+0x90>
ffffffffc0207d34:	783c                	ld	a5,112(s0)
ffffffffc0207d36:	c7bd                	beqz	a5,ffffffffc0207da4 <vfs_set_curdir+0xa4>
ffffffffc0207d38:	6bbc                	ld	a5,80(a5)
ffffffffc0207d3a:	c7ad                	beqz	a5,ffffffffc0207da4 <vfs_set_curdir+0xa4>
ffffffffc0207d3c:	00007597          	auipc	a1,0x7
ffffffffc0207d40:	88c58593          	addi	a1,a1,-1908 # ffffffffc020e5c8 <syscalls+0x990>
ffffffffc0207d44:	8522                	mv	a0,s0
ffffffffc0207d46:	3fa000ef          	jal	ra,ffffffffc0208140 <inode_check>
ffffffffc0207d4a:	783c                	ld	a5,112(s0)
ffffffffc0207d4c:	006c                	addi	a1,sp,12
ffffffffc0207d4e:	8522                	mv	a0,s0
ffffffffc0207d50:	6bbc                	ld	a5,80(a5)
ffffffffc0207d52:	9782                	jalr	a5
ffffffffc0207d54:	84aa                	mv	s1,a0
ffffffffc0207d56:	e901                	bnez	a0,ffffffffc0207d66 <vfs_set_curdir+0x66>
ffffffffc0207d58:	47b2                	lw	a5,12(sp)
ffffffffc0207d5a:	669d                	lui	a3,0x7
ffffffffc0207d5c:	6709                	lui	a4,0x2
ffffffffc0207d5e:	8ff5                	and	a5,a5,a3
ffffffffc0207d60:	54b9                	li	s1,-18
ffffffffc0207d62:	02e78063          	beq	a5,a4,ffffffffc0207d82 <vfs_set_curdir+0x82>
ffffffffc0207d66:	00093783          	ld	a5,0(s2)
ffffffffc0207d6a:	1487b503          	ld	a0,328(a5)
ffffffffc0207d6e:	a73fd0ef          	jal	ra,ffffffffc02057e0 <unlock_files>
ffffffffc0207d72:	70e2                	ld	ra,56(sp)
ffffffffc0207d74:	7442                	ld	s0,48(sp)
ffffffffc0207d76:	7902                	ld	s2,32(sp)
ffffffffc0207d78:	69e2                	ld	s3,24(sp)
ffffffffc0207d7a:	8526                	mv	a0,s1
ffffffffc0207d7c:	74a2                	ld	s1,40(sp)
ffffffffc0207d7e:	6121                	addi	sp,sp,64
ffffffffc0207d80:	8082                	ret
ffffffffc0207d82:	8522                	mv	a0,s0
ffffffffc0207d84:	3a4000ef          	jal	ra,ffffffffc0208128 <inode_ref_inc>
ffffffffc0207d88:	00093783          	ld	a5,0(s2)
ffffffffc0207d8c:	1487b503          	ld	a0,328(a5)
ffffffffc0207d90:	e100                	sd	s0,0(a0)
ffffffffc0207d92:	4481                	li	s1,0
ffffffffc0207d94:	fc098de3          	beqz	s3,ffffffffc0207d6e <vfs_set_curdir+0x6e>
ffffffffc0207d98:	854e                	mv	a0,s3
ffffffffc0207d9a:	45c000ef          	jal	ra,ffffffffc02081f6 <inode_ref_dec>
ffffffffc0207d9e:	b7e1                	j	ffffffffc0207d66 <vfs_set_curdir+0x66>
ffffffffc0207da0:	4481                	li	s1,0
ffffffffc0207da2:	b7f1                	j	ffffffffc0207d6e <vfs_set_curdir+0x6e>
ffffffffc0207da4:	00006697          	auipc	a3,0x6
ffffffffc0207da8:	7bc68693          	addi	a3,a3,1980 # ffffffffc020e560 <syscalls+0x928>
ffffffffc0207dac:	00004617          	auipc	a2,0x4
ffffffffc0207db0:	d7c60613          	addi	a2,a2,-644 # ffffffffc020bb28 <commands+0x250>
ffffffffc0207db4:	04300593          	li	a1,67
ffffffffc0207db8:	00006517          	auipc	a0,0x6
ffffffffc0207dbc:	7f850513          	addi	a0,a0,2040 # ffffffffc020e5b0 <syscalls+0x978>
ffffffffc0207dc0:	c6ef80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0207dc4 <vfs_chdir>:
ffffffffc0207dc4:	1101                	addi	sp,sp,-32
ffffffffc0207dc6:	002c                	addi	a1,sp,8
ffffffffc0207dc8:	e822                	sd	s0,16(sp)
ffffffffc0207dca:	ec06                	sd	ra,24(sp)
ffffffffc0207dcc:	21e000ef          	jal	ra,ffffffffc0207fea <vfs_lookup>
ffffffffc0207dd0:	842a                	mv	s0,a0
ffffffffc0207dd2:	c511                	beqz	a0,ffffffffc0207dde <vfs_chdir+0x1a>
ffffffffc0207dd4:	60e2                	ld	ra,24(sp)
ffffffffc0207dd6:	8522                	mv	a0,s0
ffffffffc0207dd8:	6442                	ld	s0,16(sp)
ffffffffc0207dda:	6105                	addi	sp,sp,32
ffffffffc0207ddc:	8082                	ret
ffffffffc0207dde:	6522                	ld	a0,8(sp)
ffffffffc0207de0:	f21ff0ef          	jal	ra,ffffffffc0207d00 <vfs_set_curdir>
ffffffffc0207de4:	842a                	mv	s0,a0
ffffffffc0207de6:	6522                	ld	a0,8(sp)
ffffffffc0207de8:	40e000ef          	jal	ra,ffffffffc02081f6 <inode_ref_dec>
ffffffffc0207dec:	60e2                	ld	ra,24(sp)
ffffffffc0207dee:	8522                	mv	a0,s0
ffffffffc0207df0:	6442                	ld	s0,16(sp)
ffffffffc0207df2:	6105                	addi	sp,sp,32
ffffffffc0207df4:	8082                	ret

ffffffffc0207df6 <vfs_getcwd>:
ffffffffc0207df6:	0008f797          	auipc	a5,0x8f
ffffffffc0207dfa:	aca7b783          	ld	a5,-1334(a5) # ffffffffc02968c0 <current>
ffffffffc0207dfe:	1487b783          	ld	a5,328(a5)
ffffffffc0207e02:	7179                	addi	sp,sp,-48
ffffffffc0207e04:	ec26                	sd	s1,24(sp)
ffffffffc0207e06:	6384                	ld	s1,0(a5)
ffffffffc0207e08:	f406                	sd	ra,40(sp)
ffffffffc0207e0a:	f022                	sd	s0,32(sp)
ffffffffc0207e0c:	e84a                	sd	s2,16(sp)
ffffffffc0207e0e:	ccbd                	beqz	s1,ffffffffc0207e8c <vfs_getcwd+0x96>
ffffffffc0207e10:	892a                	mv	s2,a0
ffffffffc0207e12:	8526                	mv	a0,s1
ffffffffc0207e14:	314000ef          	jal	ra,ffffffffc0208128 <inode_ref_inc>
ffffffffc0207e18:	74a8                	ld	a0,104(s1)
ffffffffc0207e1a:	c93d                	beqz	a0,ffffffffc0207e90 <vfs_getcwd+0x9a>
ffffffffc0207e1c:	d4dff0ef          	jal	ra,ffffffffc0207b68 <vfs_get_devname>
ffffffffc0207e20:	842a                	mv	s0,a0
ffffffffc0207e22:	26e030ef          	jal	ra,ffffffffc020b090 <strlen>
ffffffffc0207e26:	862a                	mv	a2,a0
ffffffffc0207e28:	85a2                	mv	a1,s0
ffffffffc0207e2a:	4701                	li	a4,0
ffffffffc0207e2c:	4685                	li	a3,1
ffffffffc0207e2e:	854a                	mv	a0,s2
ffffffffc0207e30:	907fd0ef          	jal	ra,ffffffffc0205736 <iobuf_move>
ffffffffc0207e34:	842a                	mv	s0,a0
ffffffffc0207e36:	c919                	beqz	a0,ffffffffc0207e4c <vfs_getcwd+0x56>
ffffffffc0207e38:	8526                	mv	a0,s1
ffffffffc0207e3a:	3bc000ef          	jal	ra,ffffffffc02081f6 <inode_ref_dec>
ffffffffc0207e3e:	70a2                	ld	ra,40(sp)
ffffffffc0207e40:	8522                	mv	a0,s0
ffffffffc0207e42:	7402                	ld	s0,32(sp)
ffffffffc0207e44:	64e2                	ld	s1,24(sp)
ffffffffc0207e46:	6942                	ld	s2,16(sp)
ffffffffc0207e48:	6145                	addi	sp,sp,48
ffffffffc0207e4a:	8082                	ret
ffffffffc0207e4c:	03a00793          	li	a5,58
ffffffffc0207e50:	4701                	li	a4,0
ffffffffc0207e52:	4685                	li	a3,1
ffffffffc0207e54:	4605                	li	a2,1
ffffffffc0207e56:	00f10593          	addi	a1,sp,15
ffffffffc0207e5a:	854a                	mv	a0,s2
ffffffffc0207e5c:	00f107a3          	sb	a5,15(sp)
ffffffffc0207e60:	8d7fd0ef          	jal	ra,ffffffffc0205736 <iobuf_move>
ffffffffc0207e64:	842a                	mv	s0,a0
ffffffffc0207e66:	f969                	bnez	a0,ffffffffc0207e38 <vfs_getcwd+0x42>
ffffffffc0207e68:	78bc                	ld	a5,112(s1)
ffffffffc0207e6a:	c3b9                	beqz	a5,ffffffffc0207eb0 <vfs_getcwd+0xba>
ffffffffc0207e6c:	7f9c                	ld	a5,56(a5)
ffffffffc0207e6e:	c3a9                	beqz	a5,ffffffffc0207eb0 <vfs_getcwd+0xba>
ffffffffc0207e70:	00006597          	auipc	a1,0x6
ffffffffc0207e74:	7d058593          	addi	a1,a1,2000 # ffffffffc020e640 <syscalls+0xa08>
ffffffffc0207e78:	8526                	mv	a0,s1
ffffffffc0207e7a:	2c6000ef          	jal	ra,ffffffffc0208140 <inode_check>
ffffffffc0207e7e:	78bc                	ld	a5,112(s1)
ffffffffc0207e80:	85ca                	mv	a1,s2
ffffffffc0207e82:	8526                	mv	a0,s1
ffffffffc0207e84:	7f9c                	ld	a5,56(a5)
ffffffffc0207e86:	9782                	jalr	a5
ffffffffc0207e88:	842a                	mv	s0,a0
ffffffffc0207e8a:	b77d                	j	ffffffffc0207e38 <vfs_getcwd+0x42>
ffffffffc0207e8c:	5441                	li	s0,-16
ffffffffc0207e8e:	bf45                	j	ffffffffc0207e3e <vfs_getcwd+0x48>
ffffffffc0207e90:	00006697          	auipc	a3,0x6
ffffffffc0207e94:	74068693          	addi	a3,a3,1856 # ffffffffc020e5d0 <syscalls+0x998>
ffffffffc0207e98:	00004617          	auipc	a2,0x4
ffffffffc0207e9c:	c9060613          	addi	a2,a2,-880 # ffffffffc020bb28 <commands+0x250>
ffffffffc0207ea0:	06e00593          	li	a1,110
ffffffffc0207ea4:	00006517          	auipc	a0,0x6
ffffffffc0207ea8:	70c50513          	addi	a0,a0,1804 # ffffffffc020e5b0 <syscalls+0x978>
ffffffffc0207eac:	b82f80ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0207eb0:	00006697          	auipc	a3,0x6
ffffffffc0207eb4:	73868693          	addi	a3,a3,1848 # ffffffffc020e5e8 <syscalls+0x9b0>
ffffffffc0207eb8:	00004617          	auipc	a2,0x4
ffffffffc0207ebc:	c7060613          	addi	a2,a2,-912 # ffffffffc020bb28 <commands+0x250>
ffffffffc0207ec0:	07800593          	li	a1,120
ffffffffc0207ec4:	00006517          	auipc	a0,0x6
ffffffffc0207ec8:	6ec50513          	addi	a0,a0,1772 # ffffffffc020e5b0 <syscalls+0x978>
ffffffffc0207ecc:	b62f80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0207ed0 <get_device>:
ffffffffc0207ed0:	7179                	addi	sp,sp,-48
ffffffffc0207ed2:	ec26                	sd	s1,24(sp)
ffffffffc0207ed4:	e84a                	sd	s2,16(sp)
ffffffffc0207ed6:	f406                	sd	ra,40(sp)
ffffffffc0207ed8:	f022                	sd	s0,32(sp)
ffffffffc0207eda:	00054303          	lbu	t1,0(a0)
ffffffffc0207ede:	892e                	mv	s2,a1
ffffffffc0207ee0:	84b2                	mv	s1,a2
ffffffffc0207ee2:	02030463          	beqz	t1,ffffffffc0207f0a <get_device+0x3a>
ffffffffc0207ee6:	00150413          	addi	s0,a0,1
ffffffffc0207eea:	86a2                	mv	a3,s0
ffffffffc0207eec:	879a                	mv	a5,t1
ffffffffc0207eee:	4701                	li	a4,0
ffffffffc0207ef0:	03a00813          	li	a6,58
ffffffffc0207ef4:	02f00893          	li	a7,47
ffffffffc0207ef8:	03078363          	beq	a5,a6,ffffffffc0207f1e <get_device+0x4e>
ffffffffc0207efc:	05178a63          	beq	a5,a7,ffffffffc0207f50 <get_device+0x80>
ffffffffc0207f00:	0006c783          	lbu	a5,0(a3)
ffffffffc0207f04:	2705                	addiw	a4,a4,1
ffffffffc0207f06:	0685                	addi	a3,a3,1
ffffffffc0207f08:	fbe5                	bnez	a5,ffffffffc0207ef8 <get_device+0x28>
ffffffffc0207f0a:	7402                	ld	s0,32(sp)
ffffffffc0207f0c:	00a93023          	sd	a0,0(s2)
ffffffffc0207f10:	70a2                	ld	ra,40(sp)
ffffffffc0207f12:	6942                	ld	s2,16(sp)
ffffffffc0207f14:	8526                	mv	a0,s1
ffffffffc0207f16:	64e2                	ld	s1,24(sp)
ffffffffc0207f18:	6145                	addi	sp,sp,48
ffffffffc0207f1a:	db5ff06f          	j	ffffffffc0207cce <vfs_get_curdir>
ffffffffc0207f1e:	cb15                	beqz	a4,ffffffffc0207f52 <get_device+0x82>
ffffffffc0207f20:	00e507b3          	add	a5,a0,a4
ffffffffc0207f24:	0705                	addi	a4,a4,1
ffffffffc0207f26:	00078023          	sb	zero,0(a5)
ffffffffc0207f2a:	972a                	add	a4,a4,a0
ffffffffc0207f2c:	02f00613          	li	a2,47
ffffffffc0207f30:	00074783          	lbu	a5,0(a4) # 2000 <_binary_bin_swap_img_size-0x5d00>
ffffffffc0207f34:	86ba                	mv	a3,a4
ffffffffc0207f36:	0705                	addi	a4,a4,1
ffffffffc0207f38:	fec78ce3          	beq	a5,a2,ffffffffc0207f30 <get_device+0x60>
ffffffffc0207f3c:	7402                	ld	s0,32(sp)
ffffffffc0207f3e:	70a2                	ld	ra,40(sp)
ffffffffc0207f40:	00d93023          	sd	a3,0(s2)
ffffffffc0207f44:	85a6                	mv	a1,s1
ffffffffc0207f46:	6942                	ld	s2,16(sp)
ffffffffc0207f48:	64e2                	ld	s1,24(sp)
ffffffffc0207f4a:	6145                	addi	sp,sp,48
ffffffffc0207f4c:	b67ff06f          	j	ffffffffc0207ab2 <vfs_get_root>
ffffffffc0207f50:	ff4d                	bnez	a4,ffffffffc0207f0a <get_device+0x3a>
ffffffffc0207f52:	02f00793          	li	a5,47
ffffffffc0207f56:	04f30563          	beq	t1,a5,ffffffffc0207fa0 <get_device+0xd0>
ffffffffc0207f5a:	03a00793          	li	a5,58
ffffffffc0207f5e:	06f31663          	bne	t1,a5,ffffffffc0207fca <get_device+0xfa>
ffffffffc0207f62:	0028                	addi	a0,sp,8
ffffffffc0207f64:	d6bff0ef          	jal	ra,ffffffffc0207cce <vfs_get_curdir>
ffffffffc0207f68:	e515                	bnez	a0,ffffffffc0207f94 <get_device+0xc4>
ffffffffc0207f6a:	67a2                	ld	a5,8(sp)
ffffffffc0207f6c:	77a8                	ld	a0,104(a5)
ffffffffc0207f6e:	cd15                	beqz	a0,ffffffffc0207faa <get_device+0xda>
ffffffffc0207f70:	617c                	ld	a5,192(a0)
ffffffffc0207f72:	9782                	jalr	a5
ffffffffc0207f74:	87aa                	mv	a5,a0
ffffffffc0207f76:	6522                	ld	a0,8(sp)
ffffffffc0207f78:	e09c                	sd	a5,0(s1)
ffffffffc0207f7a:	27c000ef          	jal	ra,ffffffffc02081f6 <inode_ref_dec>
ffffffffc0207f7e:	02f00713          	li	a4,47
ffffffffc0207f82:	a011                	j	ffffffffc0207f86 <get_device+0xb6>
ffffffffc0207f84:	0405                	addi	s0,s0,1
ffffffffc0207f86:	00044783          	lbu	a5,0(s0)
ffffffffc0207f8a:	fee78de3          	beq	a5,a4,ffffffffc0207f84 <get_device+0xb4>
ffffffffc0207f8e:	00893023          	sd	s0,0(s2)
ffffffffc0207f92:	4501                	li	a0,0
ffffffffc0207f94:	70a2                	ld	ra,40(sp)
ffffffffc0207f96:	7402                	ld	s0,32(sp)
ffffffffc0207f98:	64e2                	ld	s1,24(sp)
ffffffffc0207f9a:	6942                	ld	s2,16(sp)
ffffffffc0207f9c:	6145                	addi	sp,sp,48
ffffffffc0207f9e:	8082                	ret
ffffffffc0207fa0:	8526                	mv	a0,s1
ffffffffc0207fa2:	616000ef          	jal	ra,ffffffffc02085b8 <vfs_get_bootfs>
ffffffffc0207fa6:	dd61                	beqz	a0,ffffffffc0207f7e <get_device+0xae>
ffffffffc0207fa8:	b7f5                	j	ffffffffc0207f94 <get_device+0xc4>
ffffffffc0207faa:	00006697          	auipc	a3,0x6
ffffffffc0207fae:	62668693          	addi	a3,a3,1574 # ffffffffc020e5d0 <syscalls+0x998>
ffffffffc0207fb2:	00004617          	auipc	a2,0x4
ffffffffc0207fb6:	b7660613          	addi	a2,a2,-1162 # ffffffffc020bb28 <commands+0x250>
ffffffffc0207fba:	03900593          	li	a1,57
ffffffffc0207fbe:	00006517          	auipc	a0,0x6
ffffffffc0207fc2:	6a250513          	addi	a0,a0,1698 # ffffffffc020e660 <syscalls+0xa28>
ffffffffc0207fc6:	a68f80ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0207fca:	00006697          	auipc	a3,0x6
ffffffffc0207fce:	68668693          	addi	a3,a3,1670 # ffffffffc020e650 <syscalls+0xa18>
ffffffffc0207fd2:	00004617          	auipc	a2,0x4
ffffffffc0207fd6:	b5660613          	addi	a2,a2,-1194 # ffffffffc020bb28 <commands+0x250>
ffffffffc0207fda:	03300593          	li	a1,51
ffffffffc0207fde:	00006517          	auipc	a0,0x6
ffffffffc0207fe2:	68250513          	addi	a0,a0,1666 # ffffffffc020e660 <syscalls+0xa28>
ffffffffc0207fe6:	a48f80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0207fea <vfs_lookup>:
ffffffffc0207fea:	7139                	addi	sp,sp,-64
ffffffffc0207fec:	f426                	sd	s1,40(sp)
ffffffffc0207fee:	0830                	addi	a2,sp,24
ffffffffc0207ff0:	84ae                	mv	s1,a1
ffffffffc0207ff2:	002c                	addi	a1,sp,8
ffffffffc0207ff4:	f822                	sd	s0,48(sp)
ffffffffc0207ff6:	fc06                	sd	ra,56(sp)
ffffffffc0207ff8:	f04a                	sd	s2,32(sp)
ffffffffc0207ffa:	e42a                	sd	a0,8(sp)
ffffffffc0207ffc:	ed5ff0ef          	jal	ra,ffffffffc0207ed0 <get_device>
ffffffffc0208000:	842a                	mv	s0,a0
ffffffffc0208002:	ed1d                	bnez	a0,ffffffffc0208040 <vfs_lookup+0x56>
ffffffffc0208004:	67a2                	ld	a5,8(sp)
ffffffffc0208006:	6962                	ld	s2,24(sp)
ffffffffc0208008:	0007c783          	lbu	a5,0(a5)
ffffffffc020800c:	c3a9                	beqz	a5,ffffffffc020804e <vfs_lookup+0x64>
ffffffffc020800e:	04090963          	beqz	s2,ffffffffc0208060 <vfs_lookup+0x76>
ffffffffc0208012:	07093783          	ld	a5,112(s2)
ffffffffc0208016:	c7a9                	beqz	a5,ffffffffc0208060 <vfs_lookup+0x76>
ffffffffc0208018:	7bbc                	ld	a5,112(a5)
ffffffffc020801a:	c3b9                	beqz	a5,ffffffffc0208060 <vfs_lookup+0x76>
ffffffffc020801c:	854a                	mv	a0,s2
ffffffffc020801e:	00006597          	auipc	a1,0x6
ffffffffc0208022:	6aa58593          	addi	a1,a1,1706 # ffffffffc020e6c8 <syscalls+0xa90>
ffffffffc0208026:	11a000ef          	jal	ra,ffffffffc0208140 <inode_check>
ffffffffc020802a:	07093783          	ld	a5,112(s2)
ffffffffc020802e:	65a2                	ld	a1,8(sp)
ffffffffc0208030:	6562                	ld	a0,24(sp)
ffffffffc0208032:	7bbc                	ld	a5,112(a5)
ffffffffc0208034:	8626                	mv	a2,s1
ffffffffc0208036:	9782                	jalr	a5
ffffffffc0208038:	842a                	mv	s0,a0
ffffffffc020803a:	6562                	ld	a0,24(sp)
ffffffffc020803c:	1ba000ef          	jal	ra,ffffffffc02081f6 <inode_ref_dec>
ffffffffc0208040:	70e2                	ld	ra,56(sp)
ffffffffc0208042:	8522                	mv	a0,s0
ffffffffc0208044:	7442                	ld	s0,48(sp)
ffffffffc0208046:	74a2                	ld	s1,40(sp)
ffffffffc0208048:	7902                	ld	s2,32(sp)
ffffffffc020804a:	6121                	addi	sp,sp,64
ffffffffc020804c:	8082                	ret
ffffffffc020804e:	70e2                	ld	ra,56(sp)
ffffffffc0208050:	8522                	mv	a0,s0
ffffffffc0208052:	7442                	ld	s0,48(sp)
ffffffffc0208054:	0124b023          	sd	s2,0(s1)
ffffffffc0208058:	74a2                	ld	s1,40(sp)
ffffffffc020805a:	7902                	ld	s2,32(sp)
ffffffffc020805c:	6121                	addi	sp,sp,64
ffffffffc020805e:	8082                	ret
ffffffffc0208060:	00006697          	auipc	a3,0x6
ffffffffc0208064:	61868693          	addi	a3,a3,1560 # ffffffffc020e678 <syscalls+0xa40>
ffffffffc0208068:	00004617          	auipc	a2,0x4
ffffffffc020806c:	ac060613          	addi	a2,a2,-1344 # ffffffffc020bb28 <commands+0x250>
ffffffffc0208070:	04f00593          	li	a1,79
ffffffffc0208074:	00006517          	auipc	a0,0x6
ffffffffc0208078:	5ec50513          	addi	a0,a0,1516 # ffffffffc020e660 <syscalls+0xa28>
ffffffffc020807c:	9b2f80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0208080 <vfs_lookup_parent>:
ffffffffc0208080:	7139                	addi	sp,sp,-64
ffffffffc0208082:	f822                	sd	s0,48(sp)
ffffffffc0208084:	f426                	sd	s1,40(sp)
ffffffffc0208086:	842e                	mv	s0,a1
ffffffffc0208088:	84b2                	mv	s1,a2
ffffffffc020808a:	002c                	addi	a1,sp,8
ffffffffc020808c:	0830                	addi	a2,sp,24
ffffffffc020808e:	fc06                	sd	ra,56(sp)
ffffffffc0208090:	e42a                	sd	a0,8(sp)
ffffffffc0208092:	e3fff0ef          	jal	ra,ffffffffc0207ed0 <get_device>
ffffffffc0208096:	e509                	bnez	a0,ffffffffc02080a0 <vfs_lookup_parent+0x20>
ffffffffc0208098:	67a2                	ld	a5,8(sp)
ffffffffc020809a:	e09c                	sd	a5,0(s1)
ffffffffc020809c:	67e2                	ld	a5,24(sp)
ffffffffc020809e:	e01c                	sd	a5,0(s0)
ffffffffc02080a0:	70e2                	ld	ra,56(sp)
ffffffffc02080a2:	7442                	ld	s0,48(sp)
ffffffffc02080a4:	74a2                	ld	s1,40(sp)
ffffffffc02080a6:	6121                	addi	sp,sp,64
ffffffffc02080a8:	8082                	ret

ffffffffc02080aa <__alloc_inode>:
ffffffffc02080aa:	1141                	addi	sp,sp,-16
ffffffffc02080ac:	e022                	sd	s0,0(sp)
ffffffffc02080ae:	842a                	mv	s0,a0
ffffffffc02080b0:	07800513          	li	a0,120
ffffffffc02080b4:	e406                	sd	ra,8(sp)
ffffffffc02080b6:	f0cfb0ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc02080ba:	c111                	beqz	a0,ffffffffc02080be <__alloc_inode+0x14>
ffffffffc02080bc:	cd20                	sw	s0,88(a0)
ffffffffc02080be:	60a2                	ld	ra,8(sp)
ffffffffc02080c0:	6402                	ld	s0,0(sp)
ffffffffc02080c2:	0141                	addi	sp,sp,16
ffffffffc02080c4:	8082                	ret

ffffffffc02080c6 <inode_init>:
ffffffffc02080c6:	4785                	li	a5,1
ffffffffc02080c8:	06052023          	sw	zero,96(a0)
ffffffffc02080cc:	f92c                	sd	a1,112(a0)
ffffffffc02080ce:	f530                	sd	a2,104(a0)
ffffffffc02080d0:	cd7c                	sw	a5,92(a0)
ffffffffc02080d2:	8082                	ret

ffffffffc02080d4 <inode_kill>:
ffffffffc02080d4:	4d78                	lw	a4,92(a0)
ffffffffc02080d6:	1141                	addi	sp,sp,-16
ffffffffc02080d8:	e406                	sd	ra,8(sp)
ffffffffc02080da:	e719                	bnez	a4,ffffffffc02080e8 <inode_kill+0x14>
ffffffffc02080dc:	513c                	lw	a5,96(a0)
ffffffffc02080de:	e78d                	bnez	a5,ffffffffc0208108 <inode_kill+0x34>
ffffffffc02080e0:	60a2                	ld	ra,8(sp)
ffffffffc02080e2:	0141                	addi	sp,sp,16
ffffffffc02080e4:	f8efb06f          	j	ffffffffc0203872 <kfree>
ffffffffc02080e8:	00006697          	auipc	a3,0x6
ffffffffc02080ec:	5e868693          	addi	a3,a3,1512 # ffffffffc020e6d0 <syscalls+0xa98>
ffffffffc02080f0:	00004617          	auipc	a2,0x4
ffffffffc02080f4:	a3860613          	addi	a2,a2,-1480 # ffffffffc020bb28 <commands+0x250>
ffffffffc02080f8:	02900593          	li	a1,41
ffffffffc02080fc:	00006517          	auipc	a0,0x6
ffffffffc0208100:	5f450513          	addi	a0,a0,1524 # ffffffffc020e6f0 <syscalls+0xab8>
ffffffffc0208104:	92af80ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208108:	00006697          	auipc	a3,0x6
ffffffffc020810c:	60068693          	addi	a3,a3,1536 # ffffffffc020e708 <syscalls+0xad0>
ffffffffc0208110:	00004617          	auipc	a2,0x4
ffffffffc0208114:	a1860613          	addi	a2,a2,-1512 # ffffffffc020bb28 <commands+0x250>
ffffffffc0208118:	02a00593          	li	a1,42
ffffffffc020811c:	00006517          	auipc	a0,0x6
ffffffffc0208120:	5d450513          	addi	a0,a0,1492 # ffffffffc020e6f0 <syscalls+0xab8>
ffffffffc0208124:	90af80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0208128 <inode_ref_inc>:
ffffffffc0208128:	4d7c                	lw	a5,92(a0)
ffffffffc020812a:	2785                	addiw	a5,a5,1
ffffffffc020812c:	cd7c                	sw	a5,92(a0)
ffffffffc020812e:	0007851b          	sext.w	a0,a5
ffffffffc0208132:	8082                	ret

ffffffffc0208134 <inode_open_inc>:
ffffffffc0208134:	513c                	lw	a5,96(a0)
ffffffffc0208136:	2785                	addiw	a5,a5,1
ffffffffc0208138:	d13c                	sw	a5,96(a0)
ffffffffc020813a:	0007851b          	sext.w	a0,a5
ffffffffc020813e:	8082                	ret

ffffffffc0208140 <inode_check>:
ffffffffc0208140:	1141                	addi	sp,sp,-16
ffffffffc0208142:	e406                	sd	ra,8(sp)
ffffffffc0208144:	c90d                	beqz	a0,ffffffffc0208176 <inode_check+0x36>
ffffffffc0208146:	793c                	ld	a5,112(a0)
ffffffffc0208148:	c79d                	beqz	a5,ffffffffc0208176 <inode_check+0x36>
ffffffffc020814a:	6398                	ld	a4,0(a5)
ffffffffc020814c:	4625d7b7          	lui	a5,0x4625d
ffffffffc0208150:	0786                	slli	a5,a5,0x1
ffffffffc0208152:	47678793          	addi	a5,a5,1142 # 4625d476 <_binary_bin_sfs_img_size+0x461e8176>
ffffffffc0208156:	08f71063          	bne	a4,a5,ffffffffc02081d6 <inode_check+0x96>
ffffffffc020815a:	4d78                	lw	a4,92(a0)
ffffffffc020815c:	513c                	lw	a5,96(a0)
ffffffffc020815e:	04f74c63          	blt	a4,a5,ffffffffc02081b6 <inode_check+0x76>
ffffffffc0208162:	0407ca63          	bltz	a5,ffffffffc02081b6 <inode_check+0x76>
ffffffffc0208166:	66c1                	lui	a3,0x10
ffffffffc0208168:	02d75763          	bge	a4,a3,ffffffffc0208196 <inode_check+0x56>
ffffffffc020816c:	02d7d563          	bge	a5,a3,ffffffffc0208196 <inode_check+0x56>
ffffffffc0208170:	60a2                	ld	ra,8(sp)
ffffffffc0208172:	0141                	addi	sp,sp,16
ffffffffc0208174:	8082                	ret
ffffffffc0208176:	00006697          	auipc	a3,0x6
ffffffffc020817a:	5b268693          	addi	a3,a3,1458 # ffffffffc020e728 <syscalls+0xaf0>
ffffffffc020817e:	00004617          	auipc	a2,0x4
ffffffffc0208182:	9aa60613          	addi	a2,a2,-1622 # ffffffffc020bb28 <commands+0x250>
ffffffffc0208186:	06e00593          	li	a1,110
ffffffffc020818a:	00006517          	auipc	a0,0x6
ffffffffc020818e:	56650513          	addi	a0,a0,1382 # ffffffffc020e6f0 <syscalls+0xab8>
ffffffffc0208192:	89cf80ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208196:	00006697          	auipc	a3,0x6
ffffffffc020819a:	61268693          	addi	a3,a3,1554 # ffffffffc020e7a8 <syscalls+0xb70>
ffffffffc020819e:	00004617          	auipc	a2,0x4
ffffffffc02081a2:	98a60613          	addi	a2,a2,-1654 # ffffffffc020bb28 <commands+0x250>
ffffffffc02081a6:	07200593          	li	a1,114
ffffffffc02081aa:	00006517          	auipc	a0,0x6
ffffffffc02081ae:	54650513          	addi	a0,a0,1350 # ffffffffc020e6f0 <syscalls+0xab8>
ffffffffc02081b2:	87cf80ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02081b6:	00006697          	auipc	a3,0x6
ffffffffc02081ba:	5c268693          	addi	a3,a3,1474 # ffffffffc020e778 <syscalls+0xb40>
ffffffffc02081be:	00004617          	auipc	a2,0x4
ffffffffc02081c2:	96a60613          	addi	a2,a2,-1686 # ffffffffc020bb28 <commands+0x250>
ffffffffc02081c6:	07100593          	li	a1,113
ffffffffc02081ca:	00006517          	auipc	a0,0x6
ffffffffc02081ce:	52650513          	addi	a0,a0,1318 # ffffffffc020e6f0 <syscalls+0xab8>
ffffffffc02081d2:	85cf80ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02081d6:	00006697          	auipc	a3,0x6
ffffffffc02081da:	57a68693          	addi	a3,a3,1402 # ffffffffc020e750 <syscalls+0xb18>
ffffffffc02081de:	00004617          	auipc	a2,0x4
ffffffffc02081e2:	94a60613          	addi	a2,a2,-1718 # ffffffffc020bb28 <commands+0x250>
ffffffffc02081e6:	06f00593          	li	a1,111
ffffffffc02081ea:	00006517          	auipc	a0,0x6
ffffffffc02081ee:	50650513          	addi	a0,a0,1286 # ffffffffc020e6f0 <syscalls+0xab8>
ffffffffc02081f2:	83cf80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02081f6 <inode_ref_dec>:
ffffffffc02081f6:	4d7c                	lw	a5,92(a0)
ffffffffc02081f8:	1101                	addi	sp,sp,-32
ffffffffc02081fa:	ec06                	sd	ra,24(sp)
ffffffffc02081fc:	e822                	sd	s0,16(sp)
ffffffffc02081fe:	e426                	sd	s1,8(sp)
ffffffffc0208200:	e04a                	sd	s2,0(sp)
ffffffffc0208202:	06f05e63          	blez	a5,ffffffffc020827e <inode_ref_dec+0x88>
ffffffffc0208206:	fff7849b          	addiw	s1,a5,-1
ffffffffc020820a:	cd64                	sw	s1,92(a0)
ffffffffc020820c:	842a                	mv	s0,a0
ffffffffc020820e:	e09d                	bnez	s1,ffffffffc0208234 <inode_ref_dec+0x3e>
ffffffffc0208210:	793c                	ld	a5,112(a0)
ffffffffc0208212:	c7b1                	beqz	a5,ffffffffc020825e <inode_ref_dec+0x68>
ffffffffc0208214:	0487b903          	ld	s2,72(a5)
ffffffffc0208218:	04090363          	beqz	s2,ffffffffc020825e <inode_ref_dec+0x68>
ffffffffc020821c:	00006597          	auipc	a1,0x6
ffffffffc0208220:	63c58593          	addi	a1,a1,1596 # ffffffffc020e858 <syscalls+0xc20>
ffffffffc0208224:	f1dff0ef          	jal	ra,ffffffffc0208140 <inode_check>
ffffffffc0208228:	8522                	mv	a0,s0
ffffffffc020822a:	9902                	jalr	s2
ffffffffc020822c:	c501                	beqz	a0,ffffffffc0208234 <inode_ref_dec+0x3e>
ffffffffc020822e:	57c5                	li	a5,-15
ffffffffc0208230:	00f51963          	bne	a0,a5,ffffffffc0208242 <inode_ref_dec+0x4c>
ffffffffc0208234:	60e2                	ld	ra,24(sp)
ffffffffc0208236:	6442                	ld	s0,16(sp)
ffffffffc0208238:	6902                	ld	s2,0(sp)
ffffffffc020823a:	8526                	mv	a0,s1
ffffffffc020823c:	64a2                	ld	s1,8(sp)
ffffffffc020823e:	6105                	addi	sp,sp,32
ffffffffc0208240:	8082                	ret
ffffffffc0208242:	85aa                	mv	a1,a0
ffffffffc0208244:	00006517          	auipc	a0,0x6
ffffffffc0208248:	61c50513          	addi	a0,a0,1564 # ffffffffc020e860 <syscalls+0xc28>
ffffffffc020824c:	edff70ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0208250:	60e2                	ld	ra,24(sp)
ffffffffc0208252:	6442                	ld	s0,16(sp)
ffffffffc0208254:	6902                	ld	s2,0(sp)
ffffffffc0208256:	8526                	mv	a0,s1
ffffffffc0208258:	64a2                	ld	s1,8(sp)
ffffffffc020825a:	6105                	addi	sp,sp,32
ffffffffc020825c:	8082                	ret
ffffffffc020825e:	00006697          	auipc	a3,0x6
ffffffffc0208262:	5aa68693          	addi	a3,a3,1450 # ffffffffc020e808 <syscalls+0xbd0>
ffffffffc0208266:	00004617          	auipc	a2,0x4
ffffffffc020826a:	8c260613          	addi	a2,a2,-1854 # ffffffffc020bb28 <commands+0x250>
ffffffffc020826e:	04400593          	li	a1,68
ffffffffc0208272:	00006517          	auipc	a0,0x6
ffffffffc0208276:	47e50513          	addi	a0,a0,1150 # ffffffffc020e6f0 <syscalls+0xab8>
ffffffffc020827a:	fb5f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020827e:	00006697          	auipc	a3,0x6
ffffffffc0208282:	56a68693          	addi	a3,a3,1386 # ffffffffc020e7e8 <syscalls+0xbb0>
ffffffffc0208286:	00004617          	auipc	a2,0x4
ffffffffc020828a:	8a260613          	addi	a2,a2,-1886 # ffffffffc020bb28 <commands+0x250>
ffffffffc020828e:	03f00593          	li	a1,63
ffffffffc0208292:	00006517          	auipc	a0,0x6
ffffffffc0208296:	45e50513          	addi	a0,a0,1118 # ffffffffc020e6f0 <syscalls+0xab8>
ffffffffc020829a:	f95f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020829e <inode_open_dec>:
ffffffffc020829e:	513c                	lw	a5,96(a0)
ffffffffc02082a0:	1101                	addi	sp,sp,-32
ffffffffc02082a2:	ec06                	sd	ra,24(sp)
ffffffffc02082a4:	e822                	sd	s0,16(sp)
ffffffffc02082a6:	e426                	sd	s1,8(sp)
ffffffffc02082a8:	e04a                	sd	s2,0(sp)
ffffffffc02082aa:	06f05b63          	blez	a5,ffffffffc0208320 <inode_open_dec+0x82>
ffffffffc02082ae:	fff7849b          	addiw	s1,a5,-1
ffffffffc02082b2:	d124                	sw	s1,96(a0)
ffffffffc02082b4:	842a                	mv	s0,a0
ffffffffc02082b6:	e085                	bnez	s1,ffffffffc02082d6 <inode_open_dec+0x38>
ffffffffc02082b8:	793c                	ld	a5,112(a0)
ffffffffc02082ba:	c3b9                	beqz	a5,ffffffffc0208300 <inode_open_dec+0x62>
ffffffffc02082bc:	0107b903          	ld	s2,16(a5)
ffffffffc02082c0:	04090063          	beqz	s2,ffffffffc0208300 <inode_open_dec+0x62>
ffffffffc02082c4:	00006597          	auipc	a1,0x6
ffffffffc02082c8:	62c58593          	addi	a1,a1,1580 # ffffffffc020e8f0 <syscalls+0xcb8>
ffffffffc02082cc:	e75ff0ef          	jal	ra,ffffffffc0208140 <inode_check>
ffffffffc02082d0:	8522                	mv	a0,s0
ffffffffc02082d2:	9902                	jalr	s2
ffffffffc02082d4:	e901                	bnez	a0,ffffffffc02082e4 <inode_open_dec+0x46>
ffffffffc02082d6:	60e2                	ld	ra,24(sp)
ffffffffc02082d8:	6442                	ld	s0,16(sp)
ffffffffc02082da:	6902                	ld	s2,0(sp)
ffffffffc02082dc:	8526                	mv	a0,s1
ffffffffc02082de:	64a2                	ld	s1,8(sp)
ffffffffc02082e0:	6105                	addi	sp,sp,32
ffffffffc02082e2:	8082                	ret
ffffffffc02082e4:	85aa                	mv	a1,a0
ffffffffc02082e6:	00006517          	auipc	a0,0x6
ffffffffc02082ea:	61250513          	addi	a0,a0,1554 # ffffffffc020e8f8 <syscalls+0xcc0>
ffffffffc02082ee:	e3df70ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02082f2:	60e2                	ld	ra,24(sp)
ffffffffc02082f4:	6442                	ld	s0,16(sp)
ffffffffc02082f6:	6902                	ld	s2,0(sp)
ffffffffc02082f8:	8526                	mv	a0,s1
ffffffffc02082fa:	64a2                	ld	s1,8(sp)
ffffffffc02082fc:	6105                	addi	sp,sp,32
ffffffffc02082fe:	8082                	ret
ffffffffc0208300:	00006697          	auipc	a3,0x6
ffffffffc0208304:	5a068693          	addi	a3,a3,1440 # ffffffffc020e8a0 <syscalls+0xc68>
ffffffffc0208308:	00004617          	auipc	a2,0x4
ffffffffc020830c:	82060613          	addi	a2,a2,-2016 # ffffffffc020bb28 <commands+0x250>
ffffffffc0208310:	06100593          	li	a1,97
ffffffffc0208314:	00006517          	auipc	a0,0x6
ffffffffc0208318:	3dc50513          	addi	a0,a0,988 # ffffffffc020e6f0 <syscalls+0xab8>
ffffffffc020831c:	f13f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208320:	00006697          	auipc	a3,0x6
ffffffffc0208324:	56068693          	addi	a3,a3,1376 # ffffffffc020e880 <syscalls+0xc48>
ffffffffc0208328:	00004617          	auipc	a2,0x4
ffffffffc020832c:	80060613          	addi	a2,a2,-2048 # ffffffffc020bb28 <commands+0x250>
ffffffffc0208330:	05c00593          	li	a1,92
ffffffffc0208334:	00006517          	auipc	a0,0x6
ffffffffc0208338:	3bc50513          	addi	a0,a0,956 # ffffffffc020e6f0 <syscalls+0xab8>
ffffffffc020833c:	ef3f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0208340 <vfs_open>:
ffffffffc0208340:	711d                	addi	sp,sp,-96
ffffffffc0208342:	e4a6                	sd	s1,72(sp)
ffffffffc0208344:	e0ca                	sd	s2,64(sp)
ffffffffc0208346:	fc4e                	sd	s3,56(sp)
ffffffffc0208348:	ec86                	sd	ra,88(sp)
ffffffffc020834a:	e8a2                	sd	s0,80(sp)
ffffffffc020834c:	f852                	sd	s4,48(sp)
ffffffffc020834e:	f456                	sd	s5,40(sp)
ffffffffc0208350:	0035f793          	andi	a5,a1,3
ffffffffc0208354:	84ae                	mv	s1,a1
ffffffffc0208356:	892a                	mv	s2,a0
ffffffffc0208358:	89b2                	mv	s3,a2
ffffffffc020835a:	0e078663          	beqz	a5,ffffffffc0208446 <vfs_open+0x106>
ffffffffc020835e:	470d                	li	a4,3
ffffffffc0208360:	0105fa93          	andi	s5,a1,16
ffffffffc0208364:	0ce78f63          	beq	a5,a4,ffffffffc0208442 <vfs_open+0x102>
ffffffffc0208368:	002c                	addi	a1,sp,8
ffffffffc020836a:	854a                	mv	a0,s2
ffffffffc020836c:	c7fff0ef          	jal	ra,ffffffffc0207fea <vfs_lookup>
ffffffffc0208370:	842a                	mv	s0,a0
ffffffffc0208372:	0044fa13          	andi	s4,s1,4
ffffffffc0208376:	e159                	bnez	a0,ffffffffc02083fc <vfs_open+0xbc>
ffffffffc0208378:	00c4f793          	andi	a5,s1,12
ffffffffc020837c:	4731                	li	a4,12
ffffffffc020837e:	0ee78263          	beq	a5,a4,ffffffffc0208462 <vfs_open+0x122>
ffffffffc0208382:	6422                	ld	s0,8(sp)
ffffffffc0208384:	12040163          	beqz	s0,ffffffffc02084a6 <vfs_open+0x166>
ffffffffc0208388:	783c                	ld	a5,112(s0)
ffffffffc020838a:	cff1                	beqz	a5,ffffffffc0208466 <vfs_open+0x126>
ffffffffc020838c:	679c                	ld	a5,8(a5)
ffffffffc020838e:	cfe1                	beqz	a5,ffffffffc0208466 <vfs_open+0x126>
ffffffffc0208390:	8522                	mv	a0,s0
ffffffffc0208392:	00006597          	auipc	a1,0x6
ffffffffc0208396:	65658593          	addi	a1,a1,1622 # ffffffffc020e9e8 <syscalls+0xdb0>
ffffffffc020839a:	da7ff0ef          	jal	ra,ffffffffc0208140 <inode_check>
ffffffffc020839e:	783c                	ld	a5,112(s0)
ffffffffc02083a0:	6522                	ld	a0,8(sp)
ffffffffc02083a2:	85a6                	mv	a1,s1
ffffffffc02083a4:	679c                	ld	a5,8(a5)
ffffffffc02083a6:	9782                	jalr	a5
ffffffffc02083a8:	842a                	mv	s0,a0
ffffffffc02083aa:	6522                	ld	a0,8(sp)
ffffffffc02083ac:	e845                	bnez	s0,ffffffffc020845c <vfs_open+0x11c>
ffffffffc02083ae:	015a6a33          	or	s4,s4,s5
ffffffffc02083b2:	d83ff0ef          	jal	ra,ffffffffc0208134 <inode_open_inc>
ffffffffc02083b6:	020a0663          	beqz	s4,ffffffffc02083e2 <vfs_open+0xa2>
ffffffffc02083ba:	64a2                	ld	s1,8(sp)
ffffffffc02083bc:	c4e9                	beqz	s1,ffffffffc0208486 <vfs_open+0x146>
ffffffffc02083be:	78bc                	ld	a5,112(s1)
ffffffffc02083c0:	c3f9                	beqz	a5,ffffffffc0208486 <vfs_open+0x146>
ffffffffc02083c2:	73bc                	ld	a5,96(a5)
ffffffffc02083c4:	c3e9                	beqz	a5,ffffffffc0208486 <vfs_open+0x146>
ffffffffc02083c6:	00006597          	auipc	a1,0x6
ffffffffc02083ca:	68258593          	addi	a1,a1,1666 # ffffffffc020ea48 <syscalls+0xe10>
ffffffffc02083ce:	8526                	mv	a0,s1
ffffffffc02083d0:	d71ff0ef          	jal	ra,ffffffffc0208140 <inode_check>
ffffffffc02083d4:	78bc                	ld	a5,112(s1)
ffffffffc02083d6:	6522                	ld	a0,8(sp)
ffffffffc02083d8:	4581                	li	a1,0
ffffffffc02083da:	73bc                	ld	a5,96(a5)
ffffffffc02083dc:	9782                	jalr	a5
ffffffffc02083de:	87aa                	mv	a5,a0
ffffffffc02083e0:	e92d                	bnez	a0,ffffffffc0208452 <vfs_open+0x112>
ffffffffc02083e2:	67a2                	ld	a5,8(sp)
ffffffffc02083e4:	00f9b023          	sd	a5,0(s3)
ffffffffc02083e8:	60e6                	ld	ra,88(sp)
ffffffffc02083ea:	8522                	mv	a0,s0
ffffffffc02083ec:	6446                	ld	s0,80(sp)
ffffffffc02083ee:	64a6                	ld	s1,72(sp)
ffffffffc02083f0:	6906                	ld	s2,64(sp)
ffffffffc02083f2:	79e2                	ld	s3,56(sp)
ffffffffc02083f4:	7a42                	ld	s4,48(sp)
ffffffffc02083f6:	7aa2                	ld	s5,40(sp)
ffffffffc02083f8:	6125                	addi	sp,sp,96
ffffffffc02083fa:	8082                	ret
ffffffffc02083fc:	57c1                	li	a5,-16
ffffffffc02083fe:	fef515e3          	bne	a0,a5,ffffffffc02083e8 <vfs_open+0xa8>
ffffffffc0208402:	fe0a03e3          	beqz	s4,ffffffffc02083e8 <vfs_open+0xa8>
ffffffffc0208406:	0810                	addi	a2,sp,16
ffffffffc0208408:	082c                	addi	a1,sp,24
ffffffffc020840a:	854a                	mv	a0,s2
ffffffffc020840c:	c75ff0ef          	jal	ra,ffffffffc0208080 <vfs_lookup_parent>
ffffffffc0208410:	842a                	mv	s0,a0
ffffffffc0208412:	f979                	bnez	a0,ffffffffc02083e8 <vfs_open+0xa8>
ffffffffc0208414:	6462                	ld	s0,24(sp)
ffffffffc0208416:	c845                	beqz	s0,ffffffffc02084c6 <vfs_open+0x186>
ffffffffc0208418:	783c                	ld	a5,112(s0)
ffffffffc020841a:	c7d5                	beqz	a5,ffffffffc02084c6 <vfs_open+0x186>
ffffffffc020841c:	77bc                	ld	a5,104(a5)
ffffffffc020841e:	c7c5                	beqz	a5,ffffffffc02084c6 <vfs_open+0x186>
ffffffffc0208420:	8522                	mv	a0,s0
ffffffffc0208422:	00006597          	auipc	a1,0x6
ffffffffc0208426:	55e58593          	addi	a1,a1,1374 # ffffffffc020e980 <syscalls+0xd48>
ffffffffc020842a:	d17ff0ef          	jal	ra,ffffffffc0208140 <inode_check>
ffffffffc020842e:	783c                	ld	a5,112(s0)
ffffffffc0208430:	65c2                	ld	a1,16(sp)
ffffffffc0208432:	6562                	ld	a0,24(sp)
ffffffffc0208434:	77bc                	ld	a5,104(a5)
ffffffffc0208436:	4034d613          	srai	a2,s1,0x3
ffffffffc020843a:	0034                	addi	a3,sp,8
ffffffffc020843c:	8a05                	andi	a2,a2,1
ffffffffc020843e:	9782                	jalr	a5
ffffffffc0208440:	b789                	j	ffffffffc0208382 <vfs_open+0x42>
ffffffffc0208442:	5475                	li	s0,-3
ffffffffc0208444:	b755                	j	ffffffffc02083e8 <vfs_open+0xa8>
ffffffffc0208446:	0105fa93          	andi	s5,a1,16
ffffffffc020844a:	5475                	li	s0,-3
ffffffffc020844c:	f80a9ee3          	bnez	s5,ffffffffc02083e8 <vfs_open+0xa8>
ffffffffc0208450:	bf21                	j	ffffffffc0208368 <vfs_open+0x28>
ffffffffc0208452:	6522                	ld	a0,8(sp)
ffffffffc0208454:	843e                	mv	s0,a5
ffffffffc0208456:	e49ff0ef          	jal	ra,ffffffffc020829e <inode_open_dec>
ffffffffc020845a:	6522                	ld	a0,8(sp)
ffffffffc020845c:	d9bff0ef          	jal	ra,ffffffffc02081f6 <inode_ref_dec>
ffffffffc0208460:	b761                	j	ffffffffc02083e8 <vfs_open+0xa8>
ffffffffc0208462:	5425                	li	s0,-23
ffffffffc0208464:	b751                	j	ffffffffc02083e8 <vfs_open+0xa8>
ffffffffc0208466:	00006697          	auipc	a3,0x6
ffffffffc020846a:	53268693          	addi	a3,a3,1330 # ffffffffc020e998 <syscalls+0xd60>
ffffffffc020846e:	00003617          	auipc	a2,0x3
ffffffffc0208472:	6ba60613          	addi	a2,a2,1722 # ffffffffc020bb28 <commands+0x250>
ffffffffc0208476:	03300593          	li	a1,51
ffffffffc020847a:	00006517          	auipc	a0,0x6
ffffffffc020847e:	4ee50513          	addi	a0,a0,1262 # ffffffffc020e968 <syscalls+0xd30>
ffffffffc0208482:	dadf70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208486:	00006697          	auipc	a3,0x6
ffffffffc020848a:	56a68693          	addi	a3,a3,1386 # ffffffffc020e9f0 <syscalls+0xdb8>
ffffffffc020848e:	00003617          	auipc	a2,0x3
ffffffffc0208492:	69a60613          	addi	a2,a2,1690 # ffffffffc020bb28 <commands+0x250>
ffffffffc0208496:	03a00593          	li	a1,58
ffffffffc020849a:	00006517          	auipc	a0,0x6
ffffffffc020849e:	4ce50513          	addi	a0,a0,1230 # ffffffffc020e968 <syscalls+0xd30>
ffffffffc02084a2:	d8df70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02084a6:	00006697          	auipc	a3,0x6
ffffffffc02084aa:	4e268693          	addi	a3,a3,1250 # ffffffffc020e988 <syscalls+0xd50>
ffffffffc02084ae:	00003617          	auipc	a2,0x3
ffffffffc02084b2:	67a60613          	addi	a2,a2,1658 # ffffffffc020bb28 <commands+0x250>
ffffffffc02084b6:	03100593          	li	a1,49
ffffffffc02084ba:	00006517          	auipc	a0,0x6
ffffffffc02084be:	4ae50513          	addi	a0,a0,1198 # ffffffffc020e968 <syscalls+0xd30>
ffffffffc02084c2:	d6df70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02084c6:	00006697          	auipc	a3,0x6
ffffffffc02084ca:	45268693          	addi	a3,a3,1106 # ffffffffc020e918 <syscalls+0xce0>
ffffffffc02084ce:	00003617          	auipc	a2,0x3
ffffffffc02084d2:	65a60613          	addi	a2,a2,1626 # ffffffffc020bb28 <commands+0x250>
ffffffffc02084d6:	02c00593          	li	a1,44
ffffffffc02084da:	00006517          	auipc	a0,0x6
ffffffffc02084de:	48e50513          	addi	a0,a0,1166 # ffffffffc020e968 <syscalls+0xd30>
ffffffffc02084e2:	d4df70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02084e6 <vfs_close>:
ffffffffc02084e6:	1141                	addi	sp,sp,-16
ffffffffc02084e8:	e406                	sd	ra,8(sp)
ffffffffc02084ea:	e022                	sd	s0,0(sp)
ffffffffc02084ec:	842a                	mv	s0,a0
ffffffffc02084ee:	db1ff0ef          	jal	ra,ffffffffc020829e <inode_open_dec>
ffffffffc02084f2:	8522                	mv	a0,s0
ffffffffc02084f4:	d03ff0ef          	jal	ra,ffffffffc02081f6 <inode_ref_dec>
ffffffffc02084f8:	60a2                	ld	ra,8(sp)
ffffffffc02084fa:	6402                	ld	s0,0(sp)
ffffffffc02084fc:	4501                	li	a0,0
ffffffffc02084fe:	0141                	addi	sp,sp,16
ffffffffc0208500:	8082                	ret

ffffffffc0208502 <__alloc_fs>:
ffffffffc0208502:	1141                	addi	sp,sp,-16
ffffffffc0208504:	e022                	sd	s0,0(sp)
ffffffffc0208506:	842a                	mv	s0,a0
ffffffffc0208508:	0d800513          	li	a0,216
ffffffffc020850c:	e406                	sd	ra,8(sp)
ffffffffc020850e:	ab4fb0ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc0208512:	c119                	beqz	a0,ffffffffc0208518 <__alloc_fs+0x16>
ffffffffc0208514:	0a852823          	sw	s0,176(a0)
ffffffffc0208518:	60a2                	ld	ra,8(sp)
ffffffffc020851a:	6402                	ld	s0,0(sp)
ffffffffc020851c:	0141                	addi	sp,sp,16
ffffffffc020851e:	8082                	ret

ffffffffc0208520 <vfs_init>:
ffffffffc0208520:	1141                	addi	sp,sp,-16
ffffffffc0208522:	4585                	li	a1,1
ffffffffc0208524:	0008d517          	auipc	a0,0x8d
ffffffffc0208528:	30450513          	addi	a0,a0,772 # ffffffffc0295828 <bootfs_sem>
ffffffffc020852c:	e406                	sd	ra,8(sp)
ffffffffc020852e:	a10fc0ef          	jal	ra,ffffffffc020473e <sem_init>
ffffffffc0208532:	60a2                	ld	ra,8(sp)
ffffffffc0208534:	0141                	addi	sp,sp,16
ffffffffc0208536:	d0aff06f          	j	ffffffffc0207a40 <vfs_devlist_init>

ffffffffc020853a <vfs_set_bootfs>:
ffffffffc020853a:	7179                	addi	sp,sp,-48
ffffffffc020853c:	f022                	sd	s0,32(sp)
ffffffffc020853e:	f406                	sd	ra,40(sp)
ffffffffc0208540:	ec26                	sd	s1,24(sp)
ffffffffc0208542:	e402                	sd	zero,8(sp)
ffffffffc0208544:	842a                	mv	s0,a0
ffffffffc0208546:	c915                	beqz	a0,ffffffffc020857a <vfs_set_bootfs+0x40>
ffffffffc0208548:	03a00593          	li	a1,58
ffffffffc020854c:	3d1020ef          	jal	ra,ffffffffc020b11c <strchr>
ffffffffc0208550:	c135                	beqz	a0,ffffffffc02085b4 <vfs_set_bootfs+0x7a>
ffffffffc0208552:	00154783          	lbu	a5,1(a0)
ffffffffc0208556:	efb9                	bnez	a5,ffffffffc02085b4 <vfs_set_bootfs+0x7a>
ffffffffc0208558:	8522                	mv	a0,s0
ffffffffc020855a:	86bff0ef          	jal	ra,ffffffffc0207dc4 <vfs_chdir>
ffffffffc020855e:	842a                	mv	s0,a0
ffffffffc0208560:	c519                	beqz	a0,ffffffffc020856e <vfs_set_bootfs+0x34>
ffffffffc0208562:	70a2                	ld	ra,40(sp)
ffffffffc0208564:	8522                	mv	a0,s0
ffffffffc0208566:	7402                	ld	s0,32(sp)
ffffffffc0208568:	64e2                	ld	s1,24(sp)
ffffffffc020856a:	6145                	addi	sp,sp,48
ffffffffc020856c:	8082                	ret
ffffffffc020856e:	0028                	addi	a0,sp,8
ffffffffc0208570:	f5eff0ef          	jal	ra,ffffffffc0207cce <vfs_get_curdir>
ffffffffc0208574:	842a                	mv	s0,a0
ffffffffc0208576:	f575                	bnez	a0,ffffffffc0208562 <vfs_set_bootfs+0x28>
ffffffffc0208578:	6422                	ld	s0,8(sp)
ffffffffc020857a:	0008d517          	auipc	a0,0x8d
ffffffffc020857e:	2ae50513          	addi	a0,a0,686 # ffffffffc0295828 <bootfs_sem>
ffffffffc0208582:	9c8fc0ef          	jal	ra,ffffffffc020474a <down>
ffffffffc0208586:	0008e797          	auipc	a5,0x8e
ffffffffc020858a:	36a78793          	addi	a5,a5,874 # ffffffffc02968f0 <bootfs_node>
ffffffffc020858e:	6384                	ld	s1,0(a5)
ffffffffc0208590:	0008d517          	auipc	a0,0x8d
ffffffffc0208594:	29850513          	addi	a0,a0,664 # ffffffffc0295828 <bootfs_sem>
ffffffffc0208598:	e380                	sd	s0,0(a5)
ffffffffc020859a:	4401                	li	s0,0
ffffffffc020859c:	9aafc0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc02085a0:	d0e9                	beqz	s1,ffffffffc0208562 <vfs_set_bootfs+0x28>
ffffffffc02085a2:	8526                	mv	a0,s1
ffffffffc02085a4:	c53ff0ef          	jal	ra,ffffffffc02081f6 <inode_ref_dec>
ffffffffc02085a8:	70a2                	ld	ra,40(sp)
ffffffffc02085aa:	8522                	mv	a0,s0
ffffffffc02085ac:	7402                	ld	s0,32(sp)
ffffffffc02085ae:	64e2                	ld	s1,24(sp)
ffffffffc02085b0:	6145                	addi	sp,sp,48
ffffffffc02085b2:	8082                	ret
ffffffffc02085b4:	5475                	li	s0,-3
ffffffffc02085b6:	b775                	j	ffffffffc0208562 <vfs_set_bootfs+0x28>

ffffffffc02085b8 <vfs_get_bootfs>:
ffffffffc02085b8:	1101                	addi	sp,sp,-32
ffffffffc02085ba:	e426                	sd	s1,8(sp)
ffffffffc02085bc:	0008e497          	auipc	s1,0x8e
ffffffffc02085c0:	33448493          	addi	s1,s1,820 # ffffffffc02968f0 <bootfs_node>
ffffffffc02085c4:	609c                	ld	a5,0(s1)
ffffffffc02085c6:	ec06                	sd	ra,24(sp)
ffffffffc02085c8:	e822                	sd	s0,16(sp)
ffffffffc02085ca:	c3a1                	beqz	a5,ffffffffc020860a <vfs_get_bootfs+0x52>
ffffffffc02085cc:	842a                	mv	s0,a0
ffffffffc02085ce:	0008d517          	auipc	a0,0x8d
ffffffffc02085d2:	25a50513          	addi	a0,a0,602 # ffffffffc0295828 <bootfs_sem>
ffffffffc02085d6:	974fc0ef          	jal	ra,ffffffffc020474a <down>
ffffffffc02085da:	6084                	ld	s1,0(s1)
ffffffffc02085dc:	c08d                	beqz	s1,ffffffffc02085fe <vfs_get_bootfs+0x46>
ffffffffc02085de:	8526                	mv	a0,s1
ffffffffc02085e0:	b49ff0ef          	jal	ra,ffffffffc0208128 <inode_ref_inc>
ffffffffc02085e4:	0008d517          	auipc	a0,0x8d
ffffffffc02085e8:	24450513          	addi	a0,a0,580 # ffffffffc0295828 <bootfs_sem>
ffffffffc02085ec:	95afc0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc02085f0:	4501                	li	a0,0
ffffffffc02085f2:	e004                	sd	s1,0(s0)
ffffffffc02085f4:	60e2                	ld	ra,24(sp)
ffffffffc02085f6:	6442                	ld	s0,16(sp)
ffffffffc02085f8:	64a2                	ld	s1,8(sp)
ffffffffc02085fa:	6105                	addi	sp,sp,32
ffffffffc02085fc:	8082                	ret
ffffffffc02085fe:	0008d517          	auipc	a0,0x8d
ffffffffc0208602:	22a50513          	addi	a0,a0,554 # ffffffffc0295828 <bootfs_sem>
ffffffffc0208606:	940fc0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc020860a:	5541                	li	a0,-16
ffffffffc020860c:	b7e5                	j	ffffffffc02085f4 <vfs_get_bootfs+0x3c>

ffffffffc020860e <stdin_open>:
ffffffffc020860e:	4501                	li	a0,0
ffffffffc0208610:	e191                	bnez	a1,ffffffffc0208614 <stdin_open+0x6>
ffffffffc0208612:	8082                	ret
ffffffffc0208614:	5575                	li	a0,-3
ffffffffc0208616:	8082                	ret

ffffffffc0208618 <stdin_close>:
ffffffffc0208618:	4501                	li	a0,0
ffffffffc020861a:	8082                	ret

ffffffffc020861c <stdin_ioctl>:
ffffffffc020861c:	5575                	li	a0,-3
ffffffffc020861e:	8082                	ret

ffffffffc0208620 <stdin_io>:
ffffffffc0208620:	7135                	addi	sp,sp,-160
ffffffffc0208622:	ed06                	sd	ra,152(sp)
ffffffffc0208624:	e922                	sd	s0,144(sp)
ffffffffc0208626:	e526                	sd	s1,136(sp)
ffffffffc0208628:	e14a                	sd	s2,128(sp)
ffffffffc020862a:	fcce                	sd	s3,120(sp)
ffffffffc020862c:	f8d2                	sd	s4,112(sp)
ffffffffc020862e:	f4d6                	sd	s5,104(sp)
ffffffffc0208630:	f0da                	sd	s6,96(sp)
ffffffffc0208632:	ecde                	sd	s7,88(sp)
ffffffffc0208634:	e8e2                	sd	s8,80(sp)
ffffffffc0208636:	e4e6                	sd	s9,72(sp)
ffffffffc0208638:	e0ea                	sd	s10,64(sp)
ffffffffc020863a:	fc6e                	sd	s11,56(sp)
ffffffffc020863c:	14061163          	bnez	a2,ffffffffc020877e <stdin_io+0x15e>
ffffffffc0208640:	0005bd83          	ld	s11,0(a1)
ffffffffc0208644:	0185bd03          	ld	s10,24(a1)
ffffffffc0208648:	8b2e                	mv	s6,a1
ffffffffc020864a:	100027f3          	csrr	a5,sstatus
ffffffffc020864e:	8b89                	andi	a5,a5,2
ffffffffc0208650:	10079e63          	bnez	a5,ffffffffc020876c <stdin_io+0x14c>
ffffffffc0208654:	4401                	li	s0,0
ffffffffc0208656:	100d0963          	beqz	s10,ffffffffc0208768 <stdin_io+0x148>
ffffffffc020865a:	0008e997          	auipc	s3,0x8e
ffffffffc020865e:	29e98993          	addi	s3,s3,670 # ffffffffc02968f8 <p_rpos>
ffffffffc0208662:	0009b783          	ld	a5,0(s3)
ffffffffc0208666:	800004b7          	lui	s1,0x80000
ffffffffc020866a:	6c85                	lui	s9,0x1
ffffffffc020866c:	4a81                	li	s5,0
ffffffffc020866e:	0008ea17          	auipc	s4,0x8e
ffffffffc0208672:	292a0a13          	addi	s4,s4,658 # ffffffffc0296900 <p_wpos>
ffffffffc0208676:	0491                	addi	s1,s1,4
ffffffffc0208678:	0008d917          	auipc	s2,0x8d
ffffffffc020867c:	1c890913          	addi	s2,s2,456 # ffffffffc0295840 <__wait_queue>
ffffffffc0208680:	1cfd                	addi	s9,s9,-1
ffffffffc0208682:	000a3703          	ld	a4,0(s4)
ffffffffc0208686:	000a8c1b          	sext.w	s8,s5
ffffffffc020868a:	8be2                	mv	s7,s8
ffffffffc020868c:	02e7d763          	bge	a5,a4,ffffffffc02086ba <stdin_io+0x9a>
ffffffffc0208690:	a859                	j	ffffffffc0208726 <stdin_io+0x106>
ffffffffc0208692:	cd7fe0ef          	jal	ra,ffffffffc0207368 <schedule>
ffffffffc0208696:	100027f3          	csrr	a5,sstatus
ffffffffc020869a:	8b89                	andi	a5,a5,2
ffffffffc020869c:	4401                	li	s0,0
ffffffffc020869e:	ef8d                	bnez	a5,ffffffffc02086d8 <stdin_io+0xb8>
ffffffffc02086a0:	0028                	addi	a0,sp,8
ffffffffc02086a2:	dd9fb0ef          	jal	ra,ffffffffc020447a <wait_in_queue>
ffffffffc02086a6:	e121                	bnez	a0,ffffffffc02086e6 <stdin_io+0xc6>
ffffffffc02086a8:	47c2                	lw	a5,16(sp)
ffffffffc02086aa:	04979563          	bne	a5,s1,ffffffffc02086f4 <stdin_io+0xd4>
ffffffffc02086ae:	0009b783          	ld	a5,0(s3)
ffffffffc02086b2:	000a3703          	ld	a4,0(s4)
ffffffffc02086b6:	06e7c863          	blt	a5,a4,ffffffffc0208726 <stdin_io+0x106>
ffffffffc02086ba:	8626                	mv	a2,s1
ffffffffc02086bc:	002c                	addi	a1,sp,8
ffffffffc02086be:	854a                	mv	a0,s2
ffffffffc02086c0:	ee5fb0ef          	jal	ra,ffffffffc02045a4 <wait_current_set>
ffffffffc02086c4:	d479                	beqz	s0,ffffffffc0208692 <stdin_io+0x72>
ffffffffc02086c6:	ed4f80ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc02086ca:	c9ffe0ef          	jal	ra,ffffffffc0207368 <schedule>
ffffffffc02086ce:	100027f3          	csrr	a5,sstatus
ffffffffc02086d2:	8b89                	andi	a5,a5,2
ffffffffc02086d4:	4401                	li	s0,0
ffffffffc02086d6:	d7e9                	beqz	a5,ffffffffc02086a0 <stdin_io+0x80>
ffffffffc02086d8:	ec8f80ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc02086dc:	0028                	addi	a0,sp,8
ffffffffc02086de:	4405                	li	s0,1
ffffffffc02086e0:	d9bfb0ef          	jal	ra,ffffffffc020447a <wait_in_queue>
ffffffffc02086e4:	d171                	beqz	a0,ffffffffc02086a8 <stdin_io+0x88>
ffffffffc02086e6:	002c                	addi	a1,sp,8
ffffffffc02086e8:	854a                	mv	a0,s2
ffffffffc02086ea:	d37fb0ef          	jal	ra,ffffffffc0204420 <wait_queue_del>
ffffffffc02086ee:	47c2                	lw	a5,16(sp)
ffffffffc02086f0:	fa978fe3          	beq	a5,s1,ffffffffc02086ae <stdin_io+0x8e>
ffffffffc02086f4:	e435                	bnez	s0,ffffffffc0208760 <stdin_io+0x140>
ffffffffc02086f6:	060b8963          	beqz	s7,ffffffffc0208768 <stdin_io+0x148>
ffffffffc02086fa:	018b3783          	ld	a5,24(s6)
ffffffffc02086fe:	41578ab3          	sub	s5,a5,s5
ffffffffc0208702:	015b3c23          	sd	s5,24(s6)
ffffffffc0208706:	60ea                	ld	ra,152(sp)
ffffffffc0208708:	644a                	ld	s0,144(sp)
ffffffffc020870a:	64aa                	ld	s1,136(sp)
ffffffffc020870c:	690a                	ld	s2,128(sp)
ffffffffc020870e:	79e6                	ld	s3,120(sp)
ffffffffc0208710:	7a46                	ld	s4,112(sp)
ffffffffc0208712:	7aa6                	ld	s5,104(sp)
ffffffffc0208714:	7b06                	ld	s6,96(sp)
ffffffffc0208716:	6c46                	ld	s8,80(sp)
ffffffffc0208718:	6ca6                	ld	s9,72(sp)
ffffffffc020871a:	6d06                	ld	s10,64(sp)
ffffffffc020871c:	7de2                	ld	s11,56(sp)
ffffffffc020871e:	855e                	mv	a0,s7
ffffffffc0208720:	6be6                	ld	s7,88(sp)
ffffffffc0208722:	610d                	addi	sp,sp,160
ffffffffc0208724:	8082                	ret
ffffffffc0208726:	43f7d713          	srai	a4,a5,0x3f
ffffffffc020872a:	03475693          	srli	a3,a4,0x34
ffffffffc020872e:	00d78733          	add	a4,a5,a3
ffffffffc0208732:	01977733          	and	a4,a4,s9
ffffffffc0208736:	8f15                	sub	a4,a4,a3
ffffffffc0208738:	0008d697          	auipc	a3,0x8d
ffffffffc020873c:	11868693          	addi	a3,a3,280 # ffffffffc0295850 <stdin_buffer>
ffffffffc0208740:	9736                	add	a4,a4,a3
ffffffffc0208742:	00074683          	lbu	a3,0(a4)
ffffffffc0208746:	0785                	addi	a5,a5,1
ffffffffc0208748:	015d8733          	add	a4,s11,s5
ffffffffc020874c:	00d70023          	sb	a3,0(a4)
ffffffffc0208750:	00f9b023          	sd	a5,0(s3)
ffffffffc0208754:	0a85                	addi	s5,s5,1
ffffffffc0208756:	001c0b9b          	addiw	s7,s8,1
ffffffffc020875a:	f3aae4e3          	bltu	s5,s10,ffffffffc0208682 <stdin_io+0x62>
ffffffffc020875e:	dc51                	beqz	s0,ffffffffc02086fa <stdin_io+0xda>
ffffffffc0208760:	e3af80ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0208764:	f80b9be3          	bnez	s7,ffffffffc02086fa <stdin_io+0xda>
ffffffffc0208768:	4b81                	li	s7,0
ffffffffc020876a:	bf71                	j	ffffffffc0208706 <stdin_io+0xe6>
ffffffffc020876c:	e34f80ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0208770:	4405                	li	s0,1
ffffffffc0208772:	ee0d14e3          	bnez	s10,ffffffffc020865a <stdin_io+0x3a>
ffffffffc0208776:	e24f80ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc020877a:	4b81                	li	s7,0
ffffffffc020877c:	b769                	j	ffffffffc0208706 <stdin_io+0xe6>
ffffffffc020877e:	5bf5                	li	s7,-3
ffffffffc0208780:	b759                	j	ffffffffc0208706 <stdin_io+0xe6>

ffffffffc0208782 <dev_stdin_write>:
ffffffffc0208782:	e111                	bnez	a0,ffffffffc0208786 <dev_stdin_write+0x4>
ffffffffc0208784:	8082                	ret
ffffffffc0208786:	1101                	addi	sp,sp,-32
ffffffffc0208788:	e822                	sd	s0,16(sp)
ffffffffc020878a:	ec06                	sd	ra,24(sp)
ffffffffc020878c:	e426                	sd	s1,8(sp)
ffffffffc020878e:	842a                	mv	s0,a0
ffffffffc0208790:	100027f3          	csrr	a5,sstatus
ffffffffc0208794:	8b89                	andi	a5,a5,2
ffffffffc0208796:	4481                	li	s1,0
ffffffffc0208798:	e3c1                	bnez	a5,ffffffffc0208818 <dev_stdin_write+0x96>
ffffffffc020879a:	0008e597          	auipc	a1,0x8e
ffffffffc020879e:	16658593          	addi	a1,a1,358 # ffffffffc0296900 <p_wpos>
ffffffffc02087a2:	6198                	ld	a4,0(a1)
ffffffffc02087a4:	6605                	lui	a2,0x1
ffffffffc02087a6:	fff60513          	addi	a0,a2,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc02087aa:	43f75693          	srai	a3,a4,0x3f
ffffffffc02087ae:	92d1                	srli	a3,a3,0x34
ffffffffc02087b0:	00d707b3          	add	a5,a4,a3
ffffffffc02087b4:	8fe9                	and	a5,a5,a0
ffffffffc02087b6:	8f95                	sub	a5,a5,a3
ffffffffc02087b8:	0008d697          	auipc	a3,0x8d
ffffffffc02087bc:	09868693          	addi	a3,a3,152 # ffffffffc0295850 <stdin_buffer>
ffffffffc02087c0:	97b6                	add	a5,a5,a3
ffffffffc02087c2:	00878023          	sb	s0,0(a5)
ffffffffc02087c6:	0008e797          	auipc	a5,0x8e
ffffffffc02087ca:	1327b783          	ld	a5,306(a5) # ffffffffc02968f8 <p_rpos>
ffffffffc02087ce:	40f707b3          	sub	a5,a4,a5
ffffffffc02087d2:	00c7d463          	bge	a5,a2,ffffffffc02087da <dev_stdin_write+0x58>
ffffffffc02087d6:	0705                	addi	a4,a4,1
ffffffffc02087d8:	e198                	sd	a4,0(a1)
ffffffffc02087da:	0008d517          	auipc	a0,0x8d
ffffffffc02087de:	06650513          	addi	a0,a0,102 # ffffffffc0295840 <__wait_queue>
ffffffffc02087e2:	c8dfb0ef          	jal	ra,ffffffffc020446e <wait_queue_empty>
ffffffffc02087e6:	cd09                	beqz	a0,ffffffffc0208800 <dev_stdin_write+0x7e>
ffffffffc02087e8:	e491                	bnez	s1,ffffffffc02087f4 <dev_stdin_write+0x72>
ffffffffc02087ea:	60e2                	ld	ra,24(sp)
ffffffffc02087ec:	6442                	ld	s0,16(sp)
ffffffffc02087ee:	64a2                	ld	s1,8(sp)
ffffffffc02087f0:	6105                	addi	sp,sp,32
ffffffffc02087f2:	8082                	ret
ffffffffc02087f4:	6442                	ld	s0,16(sp)
ffffffffc02087f6:	60e2                	ld	ra,24(sp)
ffffffffc02087f8:	64a2                	ld	s1,8(sp)
ffffffffc02087fa:	6105                	addi	sp,sp,32
ffffffffc02087fc:	d9ef806f          	j	ffffffffc0200d9a <intr_enable>
ffffffffc0208800:	800005b7          	lui	a1,0x80000
ffffffffc0208804:	4605                	li	a2,1
ffffffffc0208806:	0591                	addi	a1,a1,4
ffffffffc0208808:	0008d517          	auipc	a0,0x8d
ffffffffc020880c:	03850513          	addi	a0,a0,56 # ffffffffc0295840 <__wait_queue>
ffffffffc0208810:	cc7fb0ef          	jal	ra,ffffffffc02044d6 <wakeup_queue>
ffffffffc0208814:	d8f9                	beqz	s1,ffffffffc02087ea <dev_stdin_write+0x68>
ffffffffc0208816:	bff9                	j	ffffffffc02087f4 <dev_stdin_write+0x72>
ffffffffc0208818:	d88f80ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc020881c:	4485                	li	s1,1
ffffffffc020881e:	bfb5                	j	ffffffffc020879a <dev_stdin_write+0x18>

ffffffffc0208820 <dev_init_stdin>:
ffffffffc0208820:	1141                	addi	sp,sp,-16
ffffffffc0208822:	e406                	sd	ra,8(sp)
ffffffffc0208824:	e022                	sd	s0,0(sp)
ffffffffc0208826:	74a000ef          	jal	ra,ffffffffc0208f70 <dev_create_inode>
ffffffffc020882a:	c93d                	beqz	a0,ffffffffc02088a0 <dev_init_stdin+0x80>
ffffffffc020882c:	4d38                	lw	a4,88(a0)
ffffffffc020882e:	6785                	lui	a5,0x1
ffffffffc0208830:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208834:	842a                	mv	s0,a0
ffffffffc0208836:	08f71e63          	bne	a4,a5,ffffffffc02088d2 <dev_init_stdin+0xb2>
ffffffffc020883a:	4785                	li	a5,1
ffffffffc020883c:	e41c                	sd	a5,8(s0)
ffffffffc020883e:	00000797          	auipc	a5,0x0
ffffffffc0208842:	dd078793          	addi	a5,a5,-560 # ffffffffc020860e <stdin_open>
ffffffffc0208846:	e81c                	sd	a5,16(s0)
ffffffffc0208848:	00000797          	auipc	a5,0x0
ffffffffc020884c:	dd078793          	addi	a5,a5,-560 # ffffffffc0208618 <stdin_close>
ffffffffc0208850:	ec1c                	sd	a5,24(s0)
ffffffffc0208852:	00000797          	auipc	a5,0x0
ffffffffc0208856:	dce78793          	addi	a5,a5,-562 # ffffffffc0208620 <stdin_io>
ffffffffc020885a:	f01c                	sd	a5,32(s0)
ffffffffc020885c:	00000797          	auipc	a5,0x0
ffffffffc0208860:	dc078793          	addi	a5,a5,-576 # ffffffffc020861c <stdin_ioctl>
ffffffffc0208864:	f41c                	sd	a5,40(s0)
ffffffffc0208866:	0008d517          	auipc	a0,0x8d
ffffffffc020886a:	fda50513          	addi	a0,a0,-38 # ffffffffc0295840 <__wait_queue>
ffffffffc020886e:	00043023          	sd	zero,0(s0)
ffffffffc0208872:	0008e797          	auipc	a5,0x8e
ffffffffc0208876:	0807b723          	sd	zero,142(a5) # ffffffffc0296900 <p_wpos>
ffffffffc020887a:	0008e797          	auipc	a5,0x8e
ffffffffc020887e:	0607bf23          	sd	zero,126(a5) # ffffffffc02968f8 <p_rpos>
ffffffffc0208882:	b99fb0ef          	jal	ra,ffffffffc020441a <wait_queue_init>
ffffffffc0208886:	4601                	li	a2,0
ffffffffc0208888:	85a2                	mv	a1,s0
ffffffffc020888a:	00006517          	auipc	a0,0x6
ffffffffc020888e:	20e50513          	addi	a0,a0,526 # ffffffffc020ea98 <syscalls+0xe60>
ffffffffc0208892:	b20ff0ef          	jal	ra,ffffffffc0207bb2 <vfs_add_dev>
ffffffffc0208896:	e10d                	bnez	a0,ffffffffc02088b8 <dev_init_stdin+0x98>
ffffffffc0208898:	60a2                	ld	ra,8(sp)
ffffffffc020889a:	6402                	ld	s0,0(sp)
ffffffffc020889c:	0141                	addi	sp,sp,16
ffffffffc020889e:	8082                	ret
ffffffffc02088a0:	00006617          	auipc	a2,0x6
ffffffffc02088a4:	1b860613          	addi	a2,a2,440 # ffffffffc020ea58 <syscalls+0xe20>
ffffffffc02088a8:	07500593          	li	a1,117
ffffffffc02088ac:	00006517          	auipc	a0,0x6
ffffffffc02088b0:	1cc50513          	addi	a0,a0,460 # ffffffffc020ea78 <syscalls+0xe40>
ffffffffc02088b4:	97bf70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02088b8:	86aa                	mv	a3,a0
ffffffffc02088ba:	00006617          	auipc	a2,0x6
ffffffffc02088be:	1e660613          	addi	a2,a2,486 # ffffffffc020eaa0 <syscalls+0xe68>
ffffffffc02088c2:	07b00593          	li	a1,123
ffffffffc02088c6:	00006517          	auipc	a0,0x6
ffffffffc02088ca:	1b250513          	addi	a0,a0,434 # ffffffffc020ea78 <syscalls+0xe40>
ffffffffc02088ce:	961f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02088d2:	00006697          	auipc	a3,0x6
ffffffffc02088d6:	c2e68693          	addi	a3,a3,-978 # ffffffffc020e500 <syscalls+0x8c8>
ffffffffc02088da:	00003617          	auipc	a2,0x3
ffffffffc02088de:	24e60613          	addi	a2,a2,590 # ffffffffc020bb28 <commands+0x250>
ffffffffc02088e2:	07700593          	li	a1,119
ffffffffc02088e6:	00006517          	auipc	a0,0x6
ffffffffc02088ea:	19250513          	addi	a0,a0,402 # ffffffffc020ea78 <syscalls+0xe40>
ffffffffc02088ee:	941f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02088f2 <disk0_open>:
ffffffffc02088f2:	4501                	li	a0,0
ffffffffc02088f4:	8082                	ret

ffffffffc02088f6 <disk0_close>:
ffffffffc02088f6:	4501                	li	a0,0
ffffffffc02088f8:	8082                	ret

ffffffffc02088fa <disk0_ioctl>:
ffffffffc02088fa:	5531                	li	a0,-20
ffffffffc02088fc:	8082                	ret

ffffffffc02088fe <disk0_io>:
ffffffffc02088fe:	659c                	ld	a5,8(a1)
ffffffffc0208900:	7159                	addi	sp,sp,-112
ffffffffc0208902:	eca6                	sd	s1,88(sp)
ffffffffc0208904:	f45e                	sd	s7,40(sp)
ffffffffc0208906:	6d84                	ld	s1,24(a1)
ffffffffc0208908:	6b85                	lui	s7,0x1
ffffffffc020890a:	1bfd                	addi	s7,s7,-1
ffffffffc020890c:	e4ce                	sd	s3,72(sp)
ffffffffc020890e:	43f7d993          	srai	s3,a5,0x3f
ffffffffc0208912:	0179f9b3          	and	s3,s3,s7
ffffffffc0208916:	99be                	add	s3,s3,a5
ffffffffc0208918:	8fc5                	or	a5,a5,s1
ffffffffc020891a:	f486                	sd	ra,104(sp)
ffffffffc020891c:	f0a2                	sd	s0,96(sp)
ffffffffc020891e:	e8ca                	sd	s2,80(sp)
ffffffffc0208920:	e0d2                	sd	s4,64(sp)
ffffffffc0208922:	fc56                	sd	s5,56(sp)
ffffffffc0208924:	f85a                	sd	s6,48(sp)
ffffffffc0208926:	f062                	sd	s8,32(sp)
ffffffffc0208928:	ec66                	sd	s9,24(sp)
ffffffffc020892a:	e86a                	sd	s10,16(sp)
ffffffffc020892c:	0177f7b3          	and	a5,a5,s7
ffffffffc0208930:	10079d63          	bnez	a5,ffffffffc0208a4a <disk0_io+0x14c>
ffffffffc0208934:	40c9d993          	srai	s3,s3,0xc
ffffffffc0208938:	00c4d713          	srli	a4,s1,0xc
ffffffffc020893c:	2981                	sext.w	s3,s3
ffffffffc020893e:	2701                	sext.w	a4,a4
ffffffffc0208940:	00e987bb          	addw	a5,s3,a4
ffffffffc0208944:	6114                	ld	a3,0(a0)
ffffffffc0208946:	1782                	slli	a5,a5,0x20
ffffffffc0208948:	9381                	srli	a5,a5,0x20
ffffffffc020894a:	10f6e063          	bltu	a3,a5,ffffffffc0208a4a <disk0_io+0x14c>
ffffffffc020894e:	4501                	li	a0,0
ffffffffc0208950:	ef19                	bnez	a4,ffffffffc020896e <disk0_io+0x70>
ffffffffc0208952:	70a6                	ld	ra,104(sp)
ffffffffc0208954:	7406                	ld	s0,96(sp)
ffffffffc0208956:	64e6                	ld	s1,88(sp)
ffffffffc0208958:	6946                	ld	s2,80(sp)
ffffffffc020895a:	69a6                	ld	s3,72(sp)
ffffffffc020895c:	6a06                	ld	s4,64(sp)
ffffffffc020895e:	7ae2                	ld	s5,56(sp)
ffffffffc0208960:	7b42                	ld	s6,48(sp)
ffffffffc0208962:	7ba2                	ld	s7,40(sp)
ffffffffc0208964:	7c02                	ld	s8,32(sp)
ffffffffc0208966:	6ce2                	ld	s9,24(sp)
ffffffffc0208968:	6d42                	ld	s10,16(sp)
ffffffffc020896a:	6165                	addi	sp,sp,112
ffffffffc020896c:	8082                	ret
ffffffffc020896e:	0008e517          	auipc	a0,0x8e
ffffffffc0208972:	ee250513          	addi	a0,a0,-286 # ffffffffc0296850 <disk0_sem>
ffffffffc0208976:	8b2e                	mv	s6,a1
ffffffffc0208978:	8c32                	mv	s8,a2
ffffffffc020897a:	0008ea97          	auipc	s5,0x8e
ffffffffc020897e:	f8ea8a93          	addi	s5,s5,-114 # ffffffffc0296908 <disk0_buffer>
ffffffffc0208982:	dc9fb0ef          	jal	ra,ffffffffc020474a <down>
ffffffffc0208986:	6c91                	lui	s9,0x4
ffffffffc0208988:	e4b9                	bnez	s1,ffffffffc02089d6 <disk0_io+0xd8>
ffffffffc020898a:	a845                	j	ffffffffc0208a3a <disk0_io+0x13c>
ffffffffc020898c:	00c4d413          	srli	s0,s1,0xc
ffffffffc0208990:	0034169b          	slliw	a3,s0,0x3
ffffffffc0208994:	00068d1b          	sext.w	s10,a3
ffffffffc0208998:	1682                	slli	a3,a3,0x20
ffffffffc020899a:	2401                	sext.w	s0,s0
ffffffffc020899c:	9281                	srli	a3,a3,0x20
ffffffffc020899e:	8926                	mv	s2,s1
ffffffffc02089a0:	00399a1b          	slliw	s4,s3,0x3
ffffffffc02089a4:	862e                	mv	a2,a1
ffffffffc02089a6:	4509                	li	a0,2
ffffffffc02089a8:	85d2                	mv	a1,s4
ffffffffc02089aa:	ac4f80ef          	jal	ra,ffffffffc0200c6e <ide_read_secs>
ffffffffc02089ae:	e165                	bnez	a0,ffffffffc0208a8e <disk0_io+0x190>
ffffffffc02089b0:	000ab583          	ld	a1,0(s5)
ffffffffc02089b4:	0038                	addi	a4,sp,8
ffffffffc02089b6:	4685                	li	a3,1
ffffffffc02089b8:	864a                	mv	a2,s2
ffffffffc02089ba:	855a                	mv	a0,s6
ffffffffc02089bc:	d7bfc0ef          	jal	ra,ffffffffc0205736 <iobuf_move>
ffffffffc02089c0:	67a2                	ld	a5,8(sp)
ffffffffc02089c2:	09279663          	bne	a5,s2,ffffffffc0208a4e <disk0_io+0x150>
ffffffffc02089c6:	017977b3          	and	a5,s2,s7
ffffffffc02089ca:	e3d1                	bnez	a5,ffffffffc0208a4e <disk0_io+0x150>
ffffffffc02089cc:	412484b3          	sub	s1,s1,s2
ffffffffc02089d0:	013409bb          	addw	s3,s0,s3
ffffffffc02089d4:	c0bd                	beqz	s1,ffffffffc0208a3a <disk0_io+0x13c>
ffffffffc02089d6:	000ab583          	ld	a1,0(s5)
ffffffffc02089da:	000c1b63          	bnez	s8,ffffffffc02089f0 <disk0_io+0xf2>
ffffffffc02089de:	fb94e7e3          	bltu	s1,s9,ffffffffc020898c <disk0_io+0x8e>
ffffffffc02089e2:	02000693          	li	a3,32
ffffffffc02089e6:	02000d13          	li	s10,32
ffffffffc02089ea:	4411                	li	s0,4
ffffffffc02089ec:	6911                	lui	s2,0x4
ffffffffc02089ee:	bf4d                	j	ffffffffc02089a0 <disk0_io+0xa2>
ffffffffc02089f0:	0038                	addi	a4,sp,8
ffffffffc02089f2:	4681                	li	a3,0
ffffffffc02089f4:	6611                	lui	a2,0x4
ffffffffc02089f6:	855a                	mv	a0,s6
ffffffffc02089f8:	d3ffc0ef          	jal	ra,ffffffffc0205736 <iobuf_move>
ffffffffc02089fc:	6422                	ld	s0,8(sp)
ffffffffc02089fe:	c825                	beqz	s0,ffffffffc0208a6e <disk0_io+0x170>
ffffffffc0208a00:	0684e763          	bltu	s1,s0,ffffffffc0208a6e <disk0_io+0x170>
ffffffffc0208a04:	017477b3          	and	a5,s0,s7
ffffffffc0208a08:	e3bd                	bnez	a5,ffffffffc0208a6e <disk0_io+0x170>
ffffffffc0208a0a:	8031                	srli	s0,s0,0xc
ffffffffc0208a0c:	0034179b          	slliw	a5,s0,0x3
ffffffffc0208a10:	000ab603          	ld	a2,0(s5)
ffffffffc0208a14:	0039991b          	slliw	s2,s3,0x3
ffffffffc0208a18:	02079693          	slli	a3,a5,0x20
ffffffffc0208a1c:	9281                	srli	a3,a3,0x20
ffffffffc0208a1e:	85ca                	mv	a1,s2
ffffffffc0208a20:	4509                	li	a0,2
ffffffffc0208a22:	2401                	sext.w	s0,s0
ffffffffc0208a24:	00078a1b          	sext.w	s4,a5
ffffffffc0208a28:	adcf80ef          	jal	ra,ffffffffc0200d04 <ide_write_secs>
ffffffffc0208a2c:	e151                	bnez	a0,ffffffffc0208ab0 <disk0_io+0x1b2>
ffffffffc0208a2e:	6922                	ld	s2,8(sp)
ffffffffc0208a30:	013409bb          	addw	s3,s0,s3
ffffffffc0208a34:	412484b3          	sub	s1,s1,s2
ffffffffc0208a38:	fcd9                	bnez	s1,ffffffffc02089d6 <disk0_io+0xd8>
ffffffffc0208a3a:	0008e517          	auipc	a0,0x8e
ffffffffc0208a3e:	e1650513          	addi	a0,a0,-490 # ffffffffc0296850 <disk0_sem>
ffffffffc0208a42:	d05fb0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc0208a46:	4501                	li	a0,0
ffffffffc0208a48:	b729                	j	ffffffffc0208952 <disk0_io+0x54>
ffffffffc0208a4a:	5575                	li	a0,-3
ffffffffc0208a4c:	b719                	j	ffffffffc0208952 <disk0_io+0x54>
ffffffffc0208a4e:	00006697          	auipc	a3,0x6
ffffffffc0208a52:	16a68693          	addi	a3,a3,362 # ffffffffc020ebb8 <syscalls+0xf80>
ffffffffc0208a56:	00003617          	auipc	a2,0x3
ffffffffc0208a5a:	0d260613          	addi	a2,a2,210 # ffffffffc020bb28 <commands+0x250>
ffffffffc0208a5e:	06200593          	li	a1,98
ffffffffc0208a62:	00006517          	auipc	a0,0x6
ffffffffc0208a66:	09e50513          	addi	a0,a0,158 # ffffffffc020eb00 <syscalls+0xec8>
ffffffffc0208a6a:	fc4f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208a6e:	00006697          	auipc	a3,0x6
ffffffffc0208a72:	05268693          	addi	a3,a3,82 # ffffffffc020eac0 <syscalls+0xe88>
ffffffffc0208a76:	00003617          	auipc	a2,0x3
ffffffffc0208a7a:	0b260613          	addi	a2,a2,178 # ffffffffc020bb28 <commands+0x250>
ffffffffc0208a7e:	05700593          	li	a1,87
ffffffffc0208a82:	00006517          	auipc	a0,0x6
ffffffffc0208a86:	07e50513          	addi	a0,a0,126 # ffffffffc020eb00 <syscalls+0xec8>
ffffffffc0208a8a:	fa4f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208a8e:	88aa                	mv	a7,a0
ffffffffc0208a90:	886a                	mv	a6,s10
ffffffffc0208a92:	87a2                	mv	a5,s0
ffffffffc0208a94:	8752                	mv	a4,s4
ffffffffc0208a96:	86ce                	mv	a3,s3
ffffffffc0208a98:	00006617          	auipc	a2,0x6
ffffffffc0208a9c:	0d860613          	addi	a2,a2,216 # ffffffffc020eb70 <syscalls+0xf38>
ffffffffc0208aa0:	02d00593          	li	a1,45
ffffffffc0208aa4:	00006517          	auipc	a0,0x6
ffffffffc0208aa8:	05c50513          	addi	a0,a0,92 # ffffffffc020eb00 <syscalls+0xec8>
ffffffffc0208aac:	f82f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208ab0:	88aa                	mv	a7,a0
ffffffffc0208ab2:	8852                	mv	a6,s4
ffffffffc0208ab4:	87a2                	mv	a5,s0
ffffffffc0208ab6:	874a                	mv	a4,s2
ffffffffc0208ab8:	86ce                	mv	a3,s3
ffffffffc0208aba:	00006617          	auipc	a2,0x6
ffffffffc0208abe:	06660613          	addi	a2,a2,102 # ffffffffc020eb20 <syscalls+0xee8>
ffffffffc0208ac2:	03700593          	li	a1,55
ffffffffc0208ac6:	00006517          	auipc	a0,0x6
ffffffffc0208aca:	03a50513          	addi	a0,a0,58 # ffffffffc020eb00 <syscalls+0xec8>
ffffffffc0208ace:	f60f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0208ad2 <dev_init_disk0>:
ffffffffc0208ad2:	1101                	addi	sp,sp,-32
ffffffffc0208ad4:	ec06                	sd	ra,24(sp)
ffffffffc0208ad6:	e822                	sd	s0,16(sp)
ffffffffc0208ad8:	e426                	sd	s1,8(sp)
ffffffffc0208ada:	496000ef          	jal	ra,ffffffffc0208f70 <dev_create_inode>
ffffffffc0208ade:	c541                	beqz	a0,ffffffffc0208b66 <dev_init_disk0+0x94>
ffffffffc0208ae0:	4d38                	lw	a4,88(a0)
ffffffffc0208ae2:	6485                	lui	s1,0x1
ffffffffc0208ae4:	23448793          	addi	a5,s1,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208ae8:	842a                	mv	s0,a0
ffffffffc0208aea:	0cf71f63          	bne	a4,a5,ffffffffc0208bc8 <dev_init_disk0+0xf6>
ffffffffc0208aee:	4509                	li	a0,2
ffffffffc0208af0:	932f80ef          	jal	ra,ffffffffc0200c22 <ide_device_valid>
ffffffffc0208af4:	cd55                	beqz	a0,ffffffffc0208bb0 <dev_init_disk0+0xde>
ffffffffc0208af6:	4509                	li	a0,2
ffffffffc0208af8:	94ef80ef          	jal	ra,ffffffffc0200c46 <ide_device_size>
ffffffffc0208afc:	00355793          	srli	a5,a0,0x3
ffffffffc0208b00:	e01c                	sd	a5,0(s0)
ffffffffc0208b02:	00000797          	auipc	a5,0x0
ffffffffc0208b06:	df078793          	addi	a5,a5,-528 # ffffffffc02088f2 <disk0_open>
ffffffffc0208b0a:	e81c                	sd	a5,16(s0)
ffffffffc0208b0c:	00000797          	auipc	a5,0x0
ffffffffc0208b10:	dea78793          	addi	a5,a5,-534 # ffffffffc02088f6 <disk0_close>
ffffffffc0208b14:	ec1c                	sd	a5,24(s0)
ffffffffc0208b16:	00000797          	auipc	a5,0x0
ffffffffc0208b1a:	de878793          	addi	a5,a5,-536 # ffffffffc02088fe <disk0_io>
ffffffffc0208b1e:	f01c                	sd	a5,32(s0)
ffffffffc0208b20:	00000797          	auipc	a5,0x0
ffffffffc0208b24:	dda78793          	addi	a5,a5,-550 # ffffffffc02088fa <disk0_ioctl>
ffffffffc0208b28:	f41c                	sd	a5,40(s0)
ffffffffc0208b2a:	4585                	li	a1,1
ffffffffc0208b2c:	0008e517          	auipc	a0,0x8e
ffffffffc0208b30:	d2450513          	addi	a0,a0,-732 # ffffffffc0296850 <disk0_sem>
ffffffffc0208b34:	e404                	sd	s1,8(s0)
ffffffffc0208b36:	c09fb0ef          	jal	ra,ffffffffc020473e <sem_init>
ffffffffc0208b3a:	6511                	lui	a0,0x4
ffffffffc0208b3c:	c87fa0ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc0208b40:	0008e797          	auipc	a5,0x8e
ffffffffc0208b44:	dca7b423          	sd	a0,-568(a5) # ffffffffc0296908 <disk0_buffer>
ffffffffc0208b48:	c921                	beqz	a0,ffffffffc0208b98 <dev_init_disk0+0xc6>
ffffffffc0208b4a:	4605                	li	a2,1
ffffffffc0208b4c:	85a2                	mv	a1,s0
ffffffffc0208b4e:	00006517          	auipc	a0,0x6
ffffffffc0208b52:	0fa50513          	addi	a0,a0,250 # ffffffffc020ec48 <syscalls+0x1010>
ffffffffc0208b56:	85cff0ef          	jal	ra,ffffffffc0207bb2 <vfs_add_dev>
ffffffffc0208b5a:	e115                	bnez	a0,ffffffffc0208b7e <dev_init_disk0+0xac>
ffffffffc0208b5c:	60e2                	ld	ra,24(sp)
ffffffffc0208b5e:	6442                	ld	s0,16(sp)
ffffffffc0208b60:	64a2                	ld	s1,8(sp)
ffffffffc0208b62:	6105                	addi	sp,sp,32
ffffffffc0208b64:	8082                	ret
ffffffffc0208b66:	00006617          	auipc	a2,0x6
ffffffffc0208b6a:	08260613          	addi	a2,a2,130 # ffffffffc020ebe8 <syscalls+0xfb0>
ffffffffc0208b6e:	08700593          	li	a1,135
ffffffffc0208b72:	00006517          	auipc	a0,0x6
ffffffffc0208b76:	f8e50513          	addi	a0,a0,-114 # ffffffffc020eb00 <syscalls+0xec8>
ffffffffc0208b7a:	eb4f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208b7e:	86aa                	mv	a3,a0
ffffffffc0208b80:	00006617          	auipc	a2,0x6
ffffffffc0208b84:	0d060613          	addi	a2,a2,208 # ffffffffc020ec50 <syscalls+0x1018>
ffffffffc0208b88:	08d00593          	li	a1,141
ffffffffc0208b8c:	00006517          	auipc	a0,0x6
ffffffffc0208b90:	f7450513          	addi	a0,a0,-140 # ffffffffc020eb00 <syscalls+0xec8>
ffffffffc0208b94:	e9af70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208b98:	00006617          	auipc	a2,0x6
ffffffffc0208b9c:	09060613          	addi	a2,a2,144 # ffffffffc020ec28 <syscalls+0xff0>
ffffffffc0208ba0:	07f00593          	li	a1,127
ffffffffc0208ba4:	00006517          	auipc	a0,0x6
ffffffffc0208ba8:	f5c50513          	addi	a0,a0,-164 # ffffffffc020eb00 <syscalls+0xec8>
ffffffffc0208bac:	e82f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208bb0:	00006617          	auipc	a2,0x6
ffffffffc0208bb4:	05860613          	addi	a2,a2,88 # ffffffffc020ec08 <syscalls+0xfd0>
ffffffffc0208bb8:	07300593          	li	a1,115
ffffffffc0208bbc:	00006517          	auipc	a0,0x6
ffffffffc0208bc0:	f4450513          	addi	a0,a0,-188 # ffffffffc020eb00 <syscalls+0xec8>
ffffffffc0208bc4:	e6af70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208bc8:	00006697          	auipc	a3,0x6
ffffffffc0208bcc:	93868693          	addi	a3,a3,-1736 # ffffffffc020e500 <syscalls+0x8c8>
ffffffffc0208bd0:	00003617          	auipc	a2,0x3
ffffffffc0208bd4:	f5860613          	addi	a2,a2,-168 # ffffffffc020bb28 <commands+0x250>
ffffffffc0208bd8:	08900593          	li	a1,137
ffffffffc0208bdc:	00006517          	auipc	a0,0x6
ffffffffc0208be0:	f2450513          	addi	a0,a0,-220 # ffffffffc020eb00 <syscalls+0xec8>
ffffffffc0208be4:	e4af70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0208be8 <stdout_open>:
ffffffffc0208be8:	4785                	li	a5,1
ffffffffc0208bea:	4501                	li	a0,0
ffffffffc0208bec:	00f59363          	bne	a1,a5,ffffffffc0208bf2 <stdout_open+0xa>
ffffffffc0208bf0:	8082                	ret
ffffffffc0208bf2:	5575                	li	a0,-3
ffffffffc0208bf4:	8082                	ret

ffffffffc0208bf6 <stdout_close>:
ffffffffc0208bf6:	4501                	li	a0,0
ffffffffc0208bf8:	8082                	ret

ffffffffc0208bfa <stdout_ioctl>:
ffffffffc0208bfa:	5575                	li	a0,-3
ffffffffc0208bfc:	8082                	ret

ffffffffc0208bfe <stdout_io>:
ffffffffc0208bfe:	ca05                	beqz	a2,ffffffffc0208c2e <stdout_io+0x30>
ffffffffc0208c00:	6d9c                	ld	a5,24(a1)
ffffffffc0208c02:	1101                	addi	sp,sp,-32
ffffffffc0208c04:	e822                	sd	s0,16(sp)
ffffffffc0208c06:	e426                	sd	s1,8(sp)
ffffffffc0208c08:	ec06                	sd	ra,24(sp)
ffffffffc0208c0a:	6180                	ld	s0,0(a1)
ffffffffc0208c0c:	84ae                	mv	s1,a1
ffffffffc0208c0e:	cb91                	beqz	a5,ffffffffc0208c22 <stdout_io+0x24>
ffffffffc0208c10:	00044503          	lbu	a0,0(s0)
ffffffffc0208c14:	0405                	addi	s0,s0,1
ffffffffc0208c16:	d50f70ef          	jal	ra,ffffffffc0200166 <cputchar>
ffffffffc0208c1a:	6c9c                	ld	a5,24(s1)
ffffffffc0208c1c:	17fd                	addi	a5,a5,-1
ffffffffc0208c1e:	ec9c                	sd	a5,24(s1)
ffffffffc0208c20:	fbe5                	bnez	a5,ffffffffc0208c10 <stdout_io+0x12>
ffffffffc0208c22:	60e2                	ld	ra,24(sp)
ffffffffc0208c24:	6442                	ld	s0,16(sp)
ffffffffc0208c26:	64a2                	ld	s1,8(sp)
ffffffffc0208c28:	4501                	li	a0,0
ffffffffc0208c2a:	6105                	addi	sp,sp,32
ffffffffc0208c2c:	8082                	ret
ffffffffc0208c2e:	5575                	li	a0,-3
ffffffffc0208c30:	8082                	ret

ffffffffc0208c32 <dev_init_stdout>:
ffffffffc0208c32:	1141                	addi	sp,sp,-16
ffffffffc0208c34:	e406                	sd	ra,8(sp)
ffffffffc0208c36:	33a000ef          	jal	ra,ffffffffc0208f70 <dev_create_inode>
ffffffffc0208c3a:	c939                	beqz	a0,ffffffffc0208c90 <dev_init_stdout+0x5e>
ffffffffc0208c3c:	4d38                	lw	a4,88(a0)
ffffffffc0208c3e:	6785                	lui	a5,0x1
ffffffffc0208c40:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208c44:	85aa                	mv	a1,a0
ffffffffc0208c46:	06f71e63          	bne	a4,a5,ffffffffc0208cc2 <dev_init_stdout+0x90>
ffffffffc0208c4a:	4785                	li	a5,1
ffffffffc0208c4c:	e51c                	sd	a5,8(a0)
ffffffffc0208c4e:	00000797          	auipc	a5,0x0
ffffffffc0208c52:	f9a78793          	addi	a5,a5,-102 # ffffffffc0208be8 <stdout_open>
ffffffffc0208c56:	e91c                	sd	a5,16(a0)
ffffffffc0208c58:	00000797          	auipc	a5,0x0
ffffffffc0208c5c:	f9e78793          	addi	a5,a5,-98 # ffffffffc0208bf6 <stdout_close>
ffffffffc0208c60:	ed1c                	sd	a5,24(a0)
ffffffffc0208c62:	00000797          	auipc	a5,0x0
ffffffffc0208c66:	f9c78793          	addi	a5,a5,-100 # ffffffffc0208bfe <stdout_io>
ffffffffc0208c6a:	f11c                	sd	a5,32(a0)
ffffffffc0208c6c:	00000797          	auipc	a5,0x0
ffffffffc0208c70:	f8e78793          	addi	a5,a5,-114 # ffffffffc0208bfa <stdout_ioctl>
ffffffffc0208c74:	00053023          	sd	zero,0(a0)
ffffffffc0208c78:	f51c                	sd	a5,40(a0)
ffffffffc0208c7a:	4601                	li	a2,0
ffffffffc0208c7c:	00006517          	auipc	a0,0x6
ffffffffc0208c80:	03450513          	addi	a0,a0,52 # ffffffffc020ecb0 <syscalls+0x1078>
ffffffffc0208c84:	f2ffe0ef          	jal	ra,ffffffffc0207bb2 <vfs_add_dev>
ffffffffc0208c88:	e105                	bnez	a0,ffffffffc0208ca8 <dev_init_stdout+0x76>
ffffffffc0208c8a:	60a2                	ld	ra,8(sp)
ffffffffc0208c8c:	0141                	addi	sp,sp,16
ffffffffc0208c8e:	8082                	ret
ffffffffc0208c90:	00006617          	auipc	a2,0x6
ffffffffc0208c94:	fe060613          	addi	a2,a2,-32 # ffffffffc020ec70 <syscalls+0x1038>
ffffffffc0208c98:	03700593          	li	a1,55
ffffffffc0208c9c:	00006517          	auipc	a0,0x6
ffffffffc0208ca0:	ff450513          	addi	a0,a0,-12 # ffffffffc020ec90 <syscalls+0x1058>
ffffffffc0208ca4:	d8af70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208ca8:	86aa                	mv	a3,a0
ffffffffc0208caa:	00006617          	auipc	a2,0x6
ffffffffc0208cae:	00e60613          	addi	a2,a2,14 # ffffffffc020ecb8 <syscalls+0x1080>
ffffffffc0208cb2:	03d00593          	li	a1,61
ffffffffc0208cb6:	00006517          	auipc	a0,0x6
ffffffffc0208cba:	fda50513          	addi	a0,a0,-38 # ffffffffc020ec90 <syscalls+0x1058>
ffffffffc0208cbe:	d70f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208cc2:	00006697          	auipc	a3,0x6
ffffffffc0208cc6:	83e68693          	addi	a3,a3,-1986 # ffffffffc020e500 <syscalls+0x8c8>
ffffffffc0208cca:	00003617          	auipc	a2,0x3
ffffffffc0208cce:	e5e60613          	addi	a2,a2,-418 # ffffffffc020bb28 <commands+0x250>
ffffffffc0208cd2:	03900593          	li	a1,57
ffffffffc0208cd6:	00006517          	auipc	a0,0x6
ffffffffc0208cda:	fba50513          	addi	a0,a0,-70 # ffffffffc020ec90 <syscalls+0x1058>
ffffffffc0208cde:	d50f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0208ce2 <dev_lookup>:
ffffffffc0208ce2:	0005c783          	lbu	a5,0(a1) # ffffffff80000000 <_binary_bin_sfs_img_size+0xffffffff7ff8ad00>
ffffffffc0208ce6:	e385                	bnez	a5,ffffffffc0208d06 <dev_lookup+0x24>
ffffffffc0208ce8:	1101                	addi	sp,sp,-32
ffffffffc0208cea:	e822                	sd	s0,16(sp)
ffffffffc0208cec:	e426                	sd	s1,8(sp)
ffffffffc0208cee:	ec06                	sd	ra,24(sp)
ffffffffc0208cf0:	84aa                	mv	s1,a0
ffffffffc0208cf2:	8432                	mv	s0,a2
ffffffffc0208cf4:	c34ff0ef          	jal	ra,ffffffffc0208128 <inode_ref_inc>
ffffffffc0208cf8:	60e2                	ld	ra,24(sp)
ffffffffc0208cfa:	e004                	sd	s1,0(s0)
ffffffffc0208cfc:	6442                	ld	s0,16(sp)
ffffffffc0208cfe:	64a2                	ld	s1,8(sp)
ffffffffc0208d00:	4501                	li	a0,0
ffffffffc0208d02:	6105                	addi	sp,sp,32
ffffffffc0208d04:	8082                	ret
ffffffffc0208d06:	5541                	li	a0,-16
ffffffffc0208d08:	8082                	ret

ffffffffc0208d0a <dev_fstat>:
ffffffffc0208d0a:	1101                	addi	sp,sp,-32
ffffffffc0208d0c:	e426                	sd	s1,8(sp)
ffffffffc0208d0e:	84ae                	mv	s1,a1
ffffffffc0208d10:	e822                	sd	s0,16(sp)
ffffffffc0208d12:	02000613          	li	a2,32
ffffffffc0208d16:	842a                	mv	s0,a0
ffffffffc0208d18:	4581                	li	a1,0
ffffffffc0208d1a:	8526                	mv	a0,s1
ffffffffc0208d1c:	ec06                	sd	ra,24(sp)
ffffffffc0208d1e:	414020ef          	jal	ra,ffffffffc020b132 <memset>
ffffffffc0208d22:	c429                	beqz	s0,ffffffffc0208d6c <dev_fstat+0x62>
ffffffffc0208d24:	783c                	ld	a5,112(s0)
ffffffffc0208d26:	c3b9                	beqz	a5,ffffffffc0208d6c <dev_fstat+0x62>
ffffffffc0208d28:	6bbc                	ld	a5,80(a5)
ffffffffc0208d2a:	c3a9                	beqz	a5,ffffffffc0208d6c <dev_fstat+0x62>
ffffffffc0208d2c:	00006597          	auipc	a1,0x6
ffffffffc0208d30:	89c58593          	addi	a1,a1,-1892 # ffffffffc020e5c8 <syscalls+0x990>
ffffffffc0208d34:	8522                	mv	a0,s0
ffffffffc0208d36:	c0aff0ef          	jal	ra,ffffffffc0208140 <inode_check>
ffffffffc0208d3a:	783c                	ld	a5,112(s0)
ffffffffc0208d3c:	85a6                	mv	a1,s1
ffffffffc0208d3e:	8522                	mv	a0,s0
ffffffffc0208d40:	6bbc                	ld	a5,80(a5)
ffffffffc0208d42:	9782                	jalr	a5
ffffffffc0208d44:	ed19                	bnez	a0,ffffffffc0208d62 <dev_fstat+0x58>
ffffffffc0208d46:	4c38                	lw	a4,88(s0)
ffffffffc0208d48:	6785                	lui	a5,0x1
ffffffffc0208d4a:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208d4e:	02f71f63          	bne	a4,a5,ffffffffc0208d8c <dev_fstat+0x82>
ffffffffc0208d52:	6018                	ld	a4,0(s0)
ffffffffc0208d54:	641c                	ld	a5,8(s0)
ffffffffc0208d56:	4685                	li	a3,1
ffffffffc0208d58:	e494                	sd	a3,8(s1)
ffffffffc0208d5a:	02e787b3          	mul	a5,a5,a4
ffffffffc0208d5e:	e898                	sd	a4,16(s1)
ffffffffc0208d60:	ec9c                	sd	a5,24(s1)
ffffffffc0208d62:	60e2                	ld	ra,24(sp)
ffffffffc0208d64:	6442                	ld	s0,16(sp)
ffffffffc0208d66:	64a2                	ld	s1,8(sp)
ffffffffc0208d68:	6105                	addi	sp,sp,32
ffffffffc0208d6a:	8082                	ret
ffffffffc0208d6c:	00005697          	auipc	a3,0x5
ffffffffc0208d70:	7f468693          	addi	a3,a3,2036 # ffffffffc020e560 <syscalls+0x928>
ffffffffc0208d74:	00003617          	auipc	a2,0x3
ffffffffc0208d78:	db460613          	addi	a2,a2,-588 # ffffffffc020bb28 <commands+0x250>
ffffffffc0208d7c:	04200593          	li	a1,66
ffffffffc0208d80:	00006517          	auipc	a0,0x6
ffffffffc0208d84:	f5850513          	addi	a0,a0,-168 # ffffffffc020ecd8 <syscalls+0x10a0>
ffffffffc0208d88:	ca6f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208d8c:	00005697          	auipc	a3,0x5
ffffffffc0208d90:	77468693          	addi	a3,a3,1908 # ffffffffc020e500 <syscalls+0x8c8>
ffffffffc0208d94:	00003617          	auipc	a2,0x3
ffffffffc0208d98:	d9460613          	addi	a2,a2,-620 # ffffffffc020bb28 <commands+0x250>
ffffffffc0208d9c:	04500593          	li	a1,69
ffffffffc0208da0:	00006517          	auipc	a0,0x6
ffffffffc0208da4:	f3850513          	addi	a0,a0,-200 # ffffffffc020ecd8 <syscalls+0x10a0>
ffffffffc0208da8:	c86f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0208dac <dev_ioctl>:
ffffffffc0208dac:	c909                	beqz	a0,ffffffffc0208dbe <dev_ioctl+0x12>
ffffffffc0208dae:	4d34                	lw	a3,88(a0)
ffffffffc0208db0:	6705                	lui	a4,0x1
ffffffffc0208db2:	23470713          	addi	a4,a4,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208db6:	00e69463          	bne	a3,a4,ffffffffc0208dbe <dev_ioctl+0x12>
ffffffffc0208dba:	751c                	ld	a5,40(a0)
ffffffffc0208dbc:	8782                	jr	a5
ffffffffc0208dbe:	1141                	addi	sp,sp,-16
ffffffffc0208dc0:	00005697          	auipc	a3,0x5
ffffffffc0208dc4:	74068693          	addi	a3,a3,1856 # ffffffffc020e500 <syscalls+0x8c8>
ffffffffc0208dc8:	00003617          	auipc	a2,0x3
ffffffffc0208dcc:	d6060613          	addi	a2,a2,-672 # ffffffffc020bb28 <commands+0x250>
ffffffffc0208dd0:	03500593          	li	a1,53
ffffffffc0208dd4:	00006517          	auipc	a0,0x6
ffffffffc0208dd8:	f0450513          	addi	a0,a0,-252 # ffffffffc020ecd8 <syscalls+0x10a0>
ffffffffc0208ddc:	e406                	sd	ra,8(sp)
ffffffffc0208dde:	c50f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0208de2 <dev_tryseek>:
ffffffffc0208de2:	c51d                	beqz	a0,ffffffffc0208e10 <dev_tryseek+0x2e>
ffffffffc0208de4:	4d38                	lw	a4,88(a0)
ffffffffc0208de6:	6785                	lui	a5,0x1
ffffffffc0208de8:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208dec:	02f71263          	bne	a4,a5,ffffffffc0208e10 <dev_tryseek+0x2e>
ffffffffc0208df0:	611c                	ld	a5,0(a0)
ffffffffc0208df2:	cf89                	beqz	a5,ffffffffc0208e0c <dev_tryseek+0x2a>
ffffffffc0208df4:	6518                	ld	a4,8(a0)
ffffffffc0208df6:	02e5f6b3          	remu	a3,a1,a4
ffffffffc0208dfa:	ea89                	bnez	a3,ffffffffc0208e0c <dev_tryseek+0x2a>
ffffffffc0208dfc:	0005c863          	bltz	a1,ffffffffc0208e0c <dev_tryseek+0x2a>
ffffffffc0208e00:	02e787b3          	mul	a5,a5,a4
ffffffffc0208e04:	00f5f463          	bgeu	a1,a5,ffffffffc0208e0c <dev_tryseek+0x2a>
ffffffffc0208e08:	4501                	li	a0,0
ffffffffc0208e0a:	8082                	ret
ffffffffc0208e0c:	5575                	li	a0,-3
ffffffffc0208e0e:	8082                	ret
ffffffffc0208e10:	1141                	addi	sp,sp,-16
ffffffffc0208e12:	00005697          	auipc	a3,0x5
ffffffffc0208e16:	6ee68693          	addi	a3,a3,1774 # ffffffffc020e500 <syscalls+0x8c8>
ffffffffc0208e1a:	00003617          	auipc	a2,0x3
ffffffffc0208e1e:	d0e60613          	addi	a2,a2,-754 # ffffffffc020bb28 <commands+0x250>
ffffffffc0208e22:	05f00593          	li	a1,95
ffffffffc0208e26:	00006517          	auipc	a0,0x6
ffffffffc0208e2a:	eb250513          	addi	a0,a0,-334 # ffffffffc020ecd8 <syscalls+0x10a0>
ffffffffc0208e2e:	e406                	sd	ra,8(sp)
ffffffffc0208e30:	bfef70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0208e34 <dev_gettype>:
ffffffffc0208e34:	c10d                	beqz	a0,ffffffffc0208e56 <dev_gettype+0x22>
ffffffffc0208e36:	4d38                	lw	a4,88(a0)
ffffffffc0208e38:	6785                	lui	a5,0x1
ffffffffc0208e3a:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208e3e:	00f71c63          	bne	a4,a5,ffffffffc0208e56 <dev_gettype+0x22>
ffffffffc0208e42:	6118                	ld	a4,0(a0)
ffffffffc0208e44:	6795                	lui	a5,0x5
ffffffffc0208e46:	c701                	beqz	a4,ffffffffc0208e4e <dev_gettype+0x1a>
ffffffffc0208e48:	c19c                	sw	a5,0(a1)
ffffffffc0208e4a:	4501                	li	a0,0
ffffffffc0208e4c:	8082                	ret
ffffffffc0208e4e:	6791                	lui	a5,0x4
ffffffffc0208e50:	c19c                	sw	a5,0(a1)
ffffffffc0208e52:	4501                	li	a0,0
ffffffffc0208e54:	8082                	ret
ffffffffc0208e56:	1141                	addi	sp,sp,-16
ffffffffc0208e58:	00005697          	auipc	a3,0x5
ffffffffc0208e5c:	6a868693          	addi	a3,a3,1704 # ffffffffc020e500 <syscalls+0x8c8>
ffffffffc0208e60:	00003617          	auipc	a2,0x3
ffffffffc0208e64:	cc860613          	addi	a2,a2,-824 # ffffffffc020bb28 <commands+0x250>
ffffffffc0208e68:	05300593          	li	a1,83
ffffffffc0208e6c:	00006517          	auipc	a0,0x6
ffffffffc0208e70:	e6c50513          	addi	a0,a0,-404 # ffffffffc020ecd8 <syscalls+0x10a0>
ffffffffc0208e74:	e406                	sd	ra,8(sp)
ffffffffc0208e76:	bb8f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0208e7a <dev_write>:
ffffffffc0208e7a:	c911                	beqz	a0,ffffffffc0208e8e <dev_write+0x14>
ffffffffc0208e7c:	4d34                	lw	a3,88(a0)
ffffffffc0208e7e:	6705                	lui	a4,0x1
ffffffffc0208e80:	23470713          	addi	a4,a4,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208e84:	00e69563          	bne	a3,a4,ffffffffc0208e8e <dev_write+0x14>
ffffffffc0208e88:	711c                	ld	a5,32(a0)
ffffffffc0208e8a:	4605                	li	a2,1
ffffffffc0208e8c:	8782                	jr	a5
ffffffffc0208e8e:	1141                	addi	sp,sp,-16
ffffffffc0208e90:	00005697          	auipc	a3,0x5
ffffffffc0208e94:	67068693          	addi	a3,a3,1648 # ffffffffc020e500 <syscalls+0x8c8>
ffffffffc0208e98:	00003617          	auipc	a2,0x3
ffffffffc0208e9c:	c9060613          	addi	a2,a2,-880 # ffffffffc020bb28 <commands+0x250>
ffffffffc0208ea0:	02c00593          	li	a1,44
ffffffffc0208ea4:	00006517          	auipc	a0,0x6
ffffffffc0208ea8:	e3450513          	addi	a0,a0,-460 # ffffffffc020ecd8 <syscalls+0x10a0>
ffffffffc0208eac:	e406                	sd	ra,8(sp)
ffffffffc0208eae:	b80f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0208eb2 <dev_read>:
ffffffffc0208eb2:	c911                	beqz	a0,ffffffffc0208ec6 <dev_read+0x14>
ffffffffc0208eb4:	4d34                	lw	a3,88(a0)
ffffffffc0208eb6:	6705                	lui	a4,0x1
ffffffffc0208eb8:	23470713          	addi	a4,a4,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208ebc:	00e69563          	bne	a3,a4,ffffffffc0208ec6 <dev_read+0x14>
ffffffffc0208ec0:	711c                	ld	a5,32(a0)
ffffffffc0208ec2:	4601                	li	a2,0
ffffffffc0208ec4:	8782                	jr	a5
ffffffffc0208ec6:	1141                	addi	sp,sp,-16
ffffffffc0208ec8:	00005697          	auipc	a3,0x5
ffffffffc0208ecc:	63868693          	addi	a3,a3,1592 # ffffffffc020e500 <syscalls+0x8c8>
ffffffffc0208ed0:	00003617          	auipc	a2,0x3
ffffffffc0208ed4:	c5860613          	addi	a2,a2,-936 # ffffffffc020bb28 <commands+0x250>
ffffffffc0208ed8:	02300593          	li	a1,35
ffffffffc0208edc:	00006517          	auipc	a0,0x6
ffffffffc0208ee0:	dfc50513          	addi	a0,a0,-516 # ffffffffc020ecd8 <syscalls+0x10a0>
ffffffffc0208ee4:	e406                	sd	ra,8(sp)
ffffffffc0208ee6:	b48f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0208eea <dev_close>:
ffffffffc0208eea:	c909                	beqz	a0,ffffffffc0208efc <dev_close+0x12>
ffffffffc0208eec:	4d34                	lw	a3,88(a0)
ffffffffc0208eee:	6705                	lui	a4,0x1
ffffffffc0208ef0:	23470713          	addi	a4,a4,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208ef4:	00e69463          	bne	a3,a4,ffffffffc0208efc <dev_close+0x12>
ffffffffc0208ef8:	6d1c                	ld	a5,24(a0)
ffffffffc0208efa:	8782                	jr	a5
ffffffffc0208efc:	1141                	addi	sp,sp,-16
ffffffffc0208efe:	00005697          	auipc	a3,0x5
ffffffffc0208f02:	60268693          	addi	a3,a3,1538 # ffffffffc020e500 <syscalls+0x8c8>
ffffffffc0208f06:	00003617          	auipc	a2,0x3
ffffffffc0208f0a:	c2260613          	addi	a2,a2,-990 # ffffffffc020bb28 <commands+0x250>
ffffffffc0208f0e:	45e9                	li	a1,26
ffffffffc0208f10:	00006517          	auipc	a0,0x6
ffffffffc0208f14:	dc850513          	addi	a0,a0,-568 # ffffffffc020ecd8 <syscalls+0x10a0>
ffffffffc0208f18:	e406                	sd	ra,8(sp)
ffffffffc0208f1a:	b14f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0208f1e <dev_open>:
ffffffffc0208f1e:	03c5f713          	andi	a4,a1,60
ffffffffc0208f22:	eb11                	bnez	a4,ffffffffc0208f36 <dev_open+0x18>
ffffffffc0208f24:	c919                	beqz	a0,ffffffffc0208f3a <dev_open+0x1c>
ffffffffc0208f26:	4d34                	lw	a3,88(a0)
ffffffffc0208f28:	6705                	lui	a4,0x1
ffffffffc0208f2a:	23470713          	addi	a4,a4,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208f2e:	00e69663          	bne	a3,a4,ffffffffc0208f3a <dev_open+0x1c>
ffffffffc0208f32:	691c                	ld	a5,16(a0)
ffffffffc0208f34:	8782                	jr	a5
ffffffffc0208f36:	5575                	li	a0,-3
ffffffffc0208f38:	8082                	ret
ffffffffc0208f3a:	1141                	addi	sp,sp,-16
ffffffffc0208f3c:	00005697          	auipc	a3,0x5
ffffffffc0208f40:	5c468693          	addi	a3,a3,1476 # ffffffffc020e500 <syscalls+0x8c8>
ffffffffc0208f44:	00003617          	auipc	a2,0x3
ffffffffc0208f48:	be460613          	addi	a2,a2,-1052 # ffffffffc020bb28 <commands+0x250>
ffffffffc0208f4c:	45c5                	li	a1,17
ffffffffc0208f4e:	00006517          	auipc	a0,0x6
ffffffffc0208f52:	d8a50513          	addi	a0,a0,-630 # ffffffffc020ecd8 <syscalls+0x10a0>
ffffffffc0208f56:	e406                	sd	ra,8(sp)
ffffffffc0208f58:	ad6f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0208f5c <dev_init>:
ffffffffc0208f5c:	1141                	addi	sp,sp,-16
ffffffffc0208f5e:	e406                	sd	ra,8(sp)
ffffffffc0208f60:	8c1ff0ef          	jal	ra,ffffffffc0208820 <dev_init_stdin>
ffffffffc0208f64:	ccfff0ef          	jal	ra,ffffffffc0208c32 <dev_init_stdout>
ffffffffc0208f68:	60a2                	ld	ra,8(sp)
ffffffffc0208f6a:	0141                	addi	sp,sp,16
ffffffffc0208f6c:	b67ff06f          	j	ffffffffc0208ad2 <dev_init_disk0>

ffffffffc0208f70 <dev_create_inode>:
ffffffffc0208f70:	6505                	lui	a0,0x1
ffffffffc0208f72:	1141                	addi	sp,sp,-16
ffffffffc0208f74:	23450513          	addi	a0,a0,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208f78:	e022                	sd	s0,0(sp)
ffffffffc0208f7a:	e406                	sd	ra,8(sp)
ffffffffc0208f7c:	92eff0ef          	jal	ra,ffffffffc02080aa <__alloc_inode>
ffffffffc0208f80:	842a                	mv	s0,a0
ffffffffc0208f82:	c901                	beqz	a0,ffffffffc0208f92 <dev_create_inode+0x22>
ffffffffc0208f84:	4601                	li	a2,0
ffffffffc0208f86:	00006597          	auipc	a1,0x6
ffffffffc0208f8a:	d6a58593          	addi	a1,a1,-662 # ffffffffc020ecf0 <dev_node_ops>
ffffffffc0208f8e:	938ff0ef          	jal	ra,ffffffffc02080c6 <inode_init>
ffffffffc0208f92:	60a2                	ld	ra,8(sp)
ffffffffc0208f94:	8522                	mv	a0,s0
ffffffffc0208f96:	6402                	ld	s0,0(sp)
ffffffffc0208f98:	0141                	addi	sp,sp,16
ffffffffc0208f9a:	8082                	ret

ffffffffc0208f9c <sfs_init>:
ffffffffc0208f9c:	1141                	addi	sp,sp,-16
ffffffffc0208f9e:	00006517          	auipc	a0,0x6
ffffffffc0208fa2:	caa50513          	addi	a0,a0,-854 # ffffffffc020ec48 <syscalls+0x1010>
ffffffffc0208fa6:	e406                	sd	ra,8(sp)
ffffffffc0208fa8:	574000ef          	jal	ra,ffffffffc020951c <sfs_mount>
ffffffffc0208fac:	e501                	bnez	a0,ffffffffc0208fb4 <sfs_init+0x18>
ffffffffc0208fae:	60a2                	ld	ra,8(sp)
ffffffffc0208fb0:	0141                	addi	sp,sp,16
ffffffffc0208fb2:	8082                	ret
ffffffffc0208fb4:	86aa                	mv	a3,a0
ffffffffc0208fb6:	00006617          	auipc	a2,0x6
ffffffffc0208fba:	dba60613          	addi	a2,a2,-582 # ffffffffc020ed70 <dev_node_ops+0x80>
ffffffffc0208fbe:	45c1                	li	a1,16
ffffffffc0208fc0:	00006517          	auipc	a0,0x6
ffffffffc0208fc4:	dd050513          	addi	a0,a0,-560 # ffffffffc020ed90 <dev_node_ops+0xa0>
ffffffffc0208fc8:	a66f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0208fcc <lock_sfs_fs>:
ffffffffc0208fcc:	05050513          	addi	a0,a0,80
ffffffffc0208fd0:	f7afb06f          	j	ffffffffc020474a <down>

ffffffffc0208fd4 <lock_sfs_io>:
ffffffffc0208fd4:	06850513          	addi	a0,a0,104
ffffffffc0208fd8:	f72fb06f          	j	ffffffffc020474a <down>

ffffffffc0208fdc <unlock_sfs_fs>:
ffffffffc0208fdc:	05050513          	addi	a0,a0,80
ffffffffc0208fe0:	f66fb06f          	j	ffffffffc0204746 <up>

ffffffffc0208fe4 <unlock_sfs_io>:
ffffffffc0208fe4:	06850513          	addi	a0,a0,104
ffffffffc0208fe8:	f5efb06f          	j	ffffffffc0204746 <up>

ffffffffc0208fec <sfs_unmount>:
ffffffffc0208fec:	1141                	addi	sp,sp,-16
ffffffffc0208fee:	e406                	sd	ra,8(sp)
ffffffffc0208ff0:	e022                	sd	s0,0(sp)
ffffffffc0208ff2:	cd1d                	beqz	a0,ffffffffc0209030 <sfs_unmount+0x44>
ffffffffc0208ff4:	0b052783          	lw	a5,176(a0)
ffffffffc0208ff8:	842a                	mv	s0,a0
ffffffffc0208ffa:	eb9d                	bnez	a5,ffffffffc0209030 <sfs_unmount+0x44>
ffffffffc0208ffc:	7158                	ld	a4,160(a0)
ffffffffc0208ffe:	09850793          	addi	a5,a0,152
ffffffffc0209002:	02f71563          	bne	a4,a5,ffffffffc020902c <sfs_unmount+0x40>
ffffffffc0209006:	613c                	ld	a5,64(a0)
ffffffffc0209008:	e7a1                	bnez	a5,ffffffffc0209050 <sfs_unmount+0x64>
ffffffffc020900a:	7d08                	ld	a0,56(a0)
ffffffffc020900c:	515010ef          	jal	ra,ffffffffc020ad20 <bitmap_destroy>
ffffffffc0209010:	6428                	ld	a0,72(s0)
ffffffffc0209012:	861fa0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc0209016:	7448                	ld	a0,168(s0)
ffffffffc0209018:	85bfa0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc020901c:	8522                	mv	a0,s0
ffffffffc020901e:	855fa0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc0209022:	4501                	li	a0,0
ffffffffc0209024:	60a2                	ld	ra,8(sp)
ffffffffc0209026:	6402                	ld	s0,0(sp)
ffffffffc0209028:	0141                	addi	sp,sp,16
ffffffffc020902a:	8082                	ret
ffffffffc020902c:	5545                	li	a0,-15
ffffffffc020902e:	bfdd                	j	ffffffffc0209024 <sfs_unmount+0x38>
ffffffffc0209030:	00006697          	auipc	a3,0x6
ffffffffc0209034:	d7868693          	addi	a3,a3,-648 # ffffffffc020eda8 <dev_node_ops+0xb8>
ffffffffc0209038:	00003617          	auipc	a2,0x3
ffffffffc020903c:	af060613          	addi	a2,a2,-1296 # ffffffffc020bb28 <commands+0x250>
ffffffffc0209040:	04100593          	li	a1,65
ffffffffc0209044:	00006517          	auipc	a0,0x6
ffffffffc0209048:	d9450513          	addi	a0,a0,-620 # ffffffffc020edd8 <dev_node_ops+0xe8>
ffffffffc020904c:	9e2f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209050:	00006697          	auipc	a3,0x6
ffffffffc0209054:	da068693          	addi	a3,a3,-608 # ffffffffc020edf0 <dev_node_ops+0x100>
ffffffffc0209058:	00003617          	auipc	a2,0x3
ffffffffc020905c:	ad060613          	addi	a2,a2,-1328 # ffffffffc020bb28 <commands+0x250>
ffffffffc0209060:	04500593          	li	a1,69
ffffffffc0209064:	00006517          	auipc	a0,0x6
ffffffffc0209068:	d7450513          	addi	a0,a0,-652 # ffffffffc020edd8 <dev_node_ops+0xe8>
ffffffffc020906c:	9c2f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209070 <sfs_cleanup>:
ffffffffc0209070:	1101                	addi	sp,sp,-32
ffffffffc0209072:	ec06                	sd	ra,24(sp)
ffffffffc0209074:	e822                	sd	s0,16(sp)
ffffffffc0209076:	e426                	sd	s1,8(sp)
ffffffffc0209078:	e04a                	sd	s2,0(sp)
ffffffffc020907a:	c525                	beqz	a0,ffffffffc02090e2 <sfs_cleanup+0x72>
ffffffffc020907c:	0b052783          	lw	a5,176(a0)
ffffffffc0209080:	84aa                	mv	s1,a0
ffffffffc0209082:	e3a5                	bnez	a5,ffffffffc02090e2 <sfs_cleanup+0x72>
ffffffffc0209084:	4158                	lw	a4,4(a0)
ffffffffc0209086:	4514                	lw	a3,8(a0)
ffffffffc0209088:	00c50913          	addi	s2,a0,12
ffffffffc020908c:	85ca                	mv	a1,s2
ffffffffc020908e:	40d7063b          	subw	a2,a4,a3
ffffffffc0209092:	00006517          	auipc	a0,0x6
ffffffffc0209096:	d7650513          	addi	a0,a0,-650 # ffffffffc020ee08 <dev_node_ops+0x118>
ffffffffc020909a:	890f70ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020909e:	02000413          	li	s0,32
ffffffffc02090a2:	a019                	j	ffffffffc02090a8 <sfs_cleanup+0x38>
ffffffffc02090a4:	347d                	addiw	s0,s0,-1
ffffffffc02090a6:	c819                	beqz	s0,ffffffffc02090bc <sfs_cleanup+0x4c>
ffffffffc02090a8:	7cdc                	ld	a5,184(s1)
ffffffffc02090aa:	8526                	mv	a0,s1
ffffffffc02090ac:	9782                	jalr	a5
ffffffffc02090ae:	f97d                	bnez	a0,ffffffffc02090a4 <sfs_cleanup+0x34>
ffffffffc02090b0:	60e2                	ld	ra,24(sp)
ffffffffc02090b2:	6442                	ld	s0,16(sp)
ffffffffc02090b4:	64a2                	ld	s1,8(sp)
ffffffffc02090b6:	6902                	ld	s2,0(sp)
ffffffffc02090b8:	6105                	addi	sp,sp,32
ffffffffc02090ba:	8082                	ret
ffffffffc02090bc:	6442                	ld	s0,16(sp)
ffffffffc02090be:	60e2                	ld	ra,24(sp)
ffffffffc02090c0:	64a2                	ld	s1,8(sp)
ffffffffc02090c2:	86ca                	mv	a3,s2
ffffffffc02090c4:	6902                	ld	s2,0(sp)
ffffffffc02090c6:	872a                	mv	a4,a0
ffffffffc02090c8:	00006617          	auipc	a2,0x6
ffffffffc02090cc:	d6060613          	addi	a2,a2,-672 # ffffffffc020ee28 <dev_node_ops+0x138>
ffffffffc02090d0:	05f00593          	li	a1,95
ffffffffc02090d4:	00006517          	auipc	a0,0x6
ffffffffc02090d8:	d0450513          	addi	a0,a0,-764 # ffffffffc020edd8 <dev_node_ops+0xe8>
ffffffffc02090dc:	6105                	addi	sp,sp,32
ffffffffc02090de:	9b8f706f          	j	ffffffffc0200296 <__warn>
ffffffffc02090e2:	00006697          	auipc	a3,0x6
ffffffffc02090e6:	cc668693          	addi	a3,a3,-826 # ffffffffc020eda8 <dev_node_ops+0xb8>
ffffffffc02090ea:	00003617          	auipc	a2,0x3
ffffffffc02090ee:	a3e60613          	addi	a2,a2,-1474 # ffffffffc020bb28 <commands+0x250>
ffffffffc02090f2:	05400593          	li	a1,84
ffffffffc02090f6:	00006517          	auipc	a0,0x6
ffffffffc02090fa:	ce250513          	addi	a0,a0,-798 # ffffffffc020edd8 <dev_node_ops+0xe8>
ffffffffc02090fe:	930f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209102 <sfs_sync>:
ffffffffc0209102:	7179                	addi	sp,sp,-48
ffffffffc0209104:	f406                	sd	ra,40(sp)
ffffffffc0209106:	f022                	sd	s0,32(sp)
ffffffffc0209108:	ec26                	sd	s1,24(sp)
ffffffffc020910a:	e84a                	sd	s2,16(sp)
ffffffffc020910c:	e44e                	sd	s3,8(sp)
ffffffffc020910e:	e052                	sd	s4,0(sp)
ffffffffc0209110:	cd4d                	beqz	a0,ffffffffc02091ca <sfs_sync+0xc8>
ffffffffc0209112:	0b052783          	lw	a5,176(a0)
ffffffffc0209116:	8a2a                	mv	s4,a0
ffffffffc0209118:	ebcd                	bnez	a5,ffffffffc02091ca <sfs_sync+0xc8>
ffffffffc020911a:	eb3ff0ef          	jal	ra,ffffffffc0208fcc <lock_sfs_fs>
ffffffffc020911e:	0a0a3403          	ld	s0,160(s4)
ffffffffc0209122:	098a0913          	addi	s2,s4,152
ffffffffc0209126:	02890763          	beq	s2,s0,ffffffffc0209154 <sfs_sync+0x52>
ffffffffc020912a:	00004997          	auipc	s3,0x4
ffffffffc020912e:	32e98993          	addi	s3,s3,814 # ffffffffc020d458 <default_pmm_manager+0x460>
ffffffffc0209132:	7c1c                	ld	a5,56(s0)
ffffffffc0209134:	fc840493          	addi	s1,s0,-56
ffffffffc0209138:	cbb5                	beqz	a5,ffffffffc02091ac <sfs_sync+0xaa>
ffffffffc020913a:	7b9c                	ld	a5,48(a5)
ffffffffc020913c:	cba5                	beqz	a5,ffffffffc02091ac <sfs_sync+0xaa>
ffffffffc020913e:	85ce                	mv	a1,s3
ffffffffc0209140:	8526                	mv	a0,s1
ffffffffc0209142:	ffffe0ef          	jal	ra,ffffffffc0208140 <inode_check>
ffffffffc0209146:	7c1c                	ld	a5,56(s0)
ffffffffc0209148:	8526                	mv	a0,s1
ffffffffc020914a:	7b9c                	ld	a5,48(a5)
ffffffffc020914c:	9782                	jalr	a5
ffffffffc020914e:	6400                	ld	s0,8(s0)
ffffffffc0209150:	fe8911e3          	bne	s2,s0,ffffffffc0209132 <sfs_sync+0x30>
ffffffffc0209154:	8552                	mv	a0,s4
ffffffffc0209156:	e87ff0ef          	jal	ra,ffffffffc0208fdc <unlock_sfs_fs>
ffffffffc020915a:	040a3783          	ld	a5,64(s4)
ffffffffc020915e:	4501                	li	a0,0
ffffffffc0209160:	eb89                	bnez	a5,ffffffffc0209172 <sfs_sync+0x70>
ffffffffc0209162:	70a2                	ld	ra,40(sp)
ffffffffc0209164:	7402                	ld	s0,32(sp)
ffffffffc0209166:	64e2                	ld	s1,24(sp)
ffffffffc0209168:	6942                	ld	s2,16(sp)
ffffffffc020916a:	69a2                	ld	s3,8(sp)
ffffffffc020916c:	6a02                	ld	s4,0(sp)
ffffffffc020916e:	6145                	addi	sp,sp,48
ffffffffc0209170:	8082                	ret
ffffffffc0209172:	040a3023          	sd	zero,64(s4)
ffffffffc0209176:	8552                	mv	a0,s4
ffffffffc0209178:	5fd010ef          	jal	ra,ffffffffc020af74 <sfs_sync_super>
ffffffffc020917c:	cd01                	beqz	a0,ffffffffc0209194 <sfs_sync+0x92>
ffffffffc020917e:	70a2                	ld	ra,40(sp)
ffffffffc0209180:	7402                	ld	s0,32(sp)
ffffffffc0209182:	4785                	li	a5,1
ffffffffc0209184:	04fa3023          	sd	a5,64(s4)
ffffffffc0209188:	64e2                	ld	s1,24(sp)
ffffffffc020918a:	6942                	ld	s2,16(sp)
ffffffffc020918c:	69a2                	ld	s3,8(sp)
ffffffffc020918e:	6a02                	ld	s4,0(sp)
ffffffffc0209190:	6145                	addi	sp,sp,48
ffffffffc0209192:	8082                	ret
ffffffffc0209194:	8552                	mv	a0,s4
ffffffffc0209196:	625010ef          	jal	ra,ffffffffc020afba <sfs_sync_freemap>
ffffffffc020919a:	f175                	bnez	a0,ffffffffc020917e <sfs_sync+0x7c>
ffffffffc020919c:	70a2                	ld	ra,40(sp)
ffffffffc020919e:	7402                	ld	s0,32(sp)
ffffffffc02091a0:	64e2                	ld	s1,24(sp)
ffffffffc02091a2:	6942                	ld	s2,16(sp)
ffffffffc02091a4:	69a2                	ld	s3,8(sp)
ffffffffc02091a6:	6a02                	ld	s4,0(sp)
ffffffffc02091a8:	6145                	addi	sp,sp,48
ffffffffc02091aa:	8082                	ret
ffffffffc02091ac:	00004697          	auipc	a3,0x4
ffffffffc02091b0:	25c68693          	addi	a3,a3,604 # ffffffffc020d408 <default_pmm_manager+0x410>
ffffffffc02091b4:	00003617          	auipc	a2,0x3
ffffffffc02091b8:	97460613          	addi	a2,a2,-1676 # ffffffffc020bb28 <commands+0x250>
ffffffffc02091bc:	45ed                	li	a1,27
ffffffffc02091be:	00006517          	auipc	a0,0x6
ffffffffc02091c2:	c1a50513          	addi	a0,a0,-998 # ffffffffc020edd8 <dev_node_ops+0xe8>
ffffffffc02091c6:	868f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02091ca:	00006697          	auipc	a3,0x6
ffffffffc02091ce:	bde68693          	addi	a3,a3,-1058 # ffffffffc020eda8 <dev_node_ops+0xb8>
ffffffffc02091d2:	00003617          	auipc	a2,0x3
ffffffffc02091d6:	95660613          	addi	a2,a2,-1706 # ffffffffc020bb28 <commands+0x250>
ffffffffc02091da:	45d5                	li	a1,21
ffffffffc02091dc:	00006517          	auipc	a0,0x6
ffffffffc02091e0:	bfc50513          	addi	a0,a0,-1028 # ffffffffc020edd8 <dev_node_ops+0xe8>
ffffffffc02091e4:	84af70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02091e8 <sfs_get_root>:
ffffffffc02091e8:	1101                	addi	sp,sp,-32
ffffffffc02091ea:	ec06                	sd	ra,24(sp)
ffffffffc02091ec:	cd09                	beqz	a0,ffffffffc0209206 <sfs_get_root+0x1e>
ffffffffc02091ee:	0b052783          	lw	a5,176(a0)
ffffffffc02091f2:	eb91                	bnez	a5,ffffffffc0209206 <sfs_get_root+0x1e>
ffffffffc02091f4:	4605                	li	a2,1
ffffffffc02091f6:	002c                	addi	a1,sp,8
ffffffffc02091f8:	368010ef          	jal	ra,ffffffffc020a560 <sfs_load_inode>
ffffffffc02091fc:	e50d                	bnez	a0,ffffffffc0209226 <sfs_get_root+0x3e>
ffffffffc02091fe:	60e2                	ld	ra,24(sp)
ffffffffc0209200:	6522                	ld	a0,8(sp)
ffffffffc0209202:	6105                	addi	sp,sp,32
ffffffffc0209204:	8082                	ret
ffffffffc0209206:	00006697          	auipc	a3,0x6
ffffffffc020920a:	ba268693          	addi	a3,a3,-1118 # ffffffffc020eda8 <dev_node_ops+0xb8>
ffffffffc020920e:	00003617          	auipc	a2,0x3
ffffffffc0209212:	91a60613          	addi	a2,a2,-1766 # ffffffffc020bb28 <commands+0x250>
ffffffffc0209216:	03600593          	li	a1,54
ffffffffc020921a:	00006517          	auipc	a0,0x6
ffffffffc020921e:	bbe50513          	addi	a0,a0,-1090 # ffffffffc020edd8 <dev_node_ops+0xe8>
ffffffffc0209222:	80cf70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209226:	86aa                	mv	a3,a0
ffffffffc0209228:	00006617          	auipc	a2,0x6
ffffffffc020922c:	c2060613          	addi	a2,a2,-992 # ffffffffc020ee48 <dev_node_ops+0x158>
ffffffffc0209230:	03700593          	li	a1,55
ffffffffc0209234:	00006517          	auipc	a0,0x6
ffffffffc0209238:	ba450513          	addi	a0,a0,-1116 # ffffffffc020edd8 <dev_node_ops+0xe8>
ffffffffc020923c:	ff3f60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209240 <sfs_do_mount>:
ffffffffc0209240:	6518                	ld	a4,8(a0)
ffffffffc0209242:	7171                	addi	sp,sp,-176
ffffffffc0209244:	f506                	sd	ra,168(sp)
ffffffffc0209246:	f122                	sd	s0,160(sp)
ffffffffc0209248:	ed26                	sd	s1,152(sp)
ffffffffc020924a:	e94a                	sd	s2,144(sp)
ffffffffc020924c:	e54e                	sd	s3,136(sp)
ffffffffc020924e:	e152                	sd	s4,128(sp)
ffffffffc0209250:	fcd6                	sd	s5,120(sp)
ffffffffc0209252:	f8da                	sd	s6,112(sp)
ffffffffc0209254:	f4de                	sd	s7,104(sp)
ffffffffc0209256:	f0e2                	sd	s8,96(sp)
ffffffffc0209258:	ece6                	sd	s9,88(sp)
ffffffffc020925a:	e8ea                	sd	s10,80(sp)
ffffffffc020925c:	e4ee                	sd	s11,72(sp)
ffffffffc020925e:	6785                	lui	a5,0x1
ffffffffc0209260:	24f71663          	bne	a4,a5,ffffffffc02094ac <sfs_do_mount+0x26c>
ffffffffc0209264:	892a                	mv	s2,a0
ffffffffc0209266:	4501                	li	a0,0
ffffffffc0209268:	8aae                	mv	s5,a1
ffffffffc020926a:	a98ff0ef          	jal	ra,ffffffffc0208502 <__alloc_fs>
ffffffffc020926e:	842a                	mv	s0,a0
ffffffffc0209270:	24050463          	beqz	a0,ffffffffc02094b8 <sfs_do_mount+0x278>
ffffffffc0209274:	0b052b03          	lw	s6,176(a0)
ffffffffc0209278:	260b1263          	bnez	s6,ffffffffc02094dc <sfs_do_mount+0x29c>
ffffffffc020927c:	03253823          	sd	s2,48(a0)
ffffffffc0209280:	6505                	lui	a0,0x1
ffffffffc0209282:	d40fa0ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc0209286:	e428                	sd	a0,72(s0)
ffffffffc0209288:	84aa                	mv	s1,a0
ffffffffc020928a:	16050363          	beqz	a0,ffffffffc02093f0 <sfs_do_mount+0x1b0>
ffffffffc020928e:	85aa                	mv	a1,a0
ffffffffc0209290:	4681                	li	a3,0
ffffffffc0209292:	6605                	lui	a2,0x1
ffffffffc0209294:	1008                	addi	a0,sp,32
ffffffffc0209296:	c96fc0ef          	jal	ra,ffffffffc020572c <iobuf_init>
ffffffffc020929a:	02093783          	ld	a5,32(s2) # 4020 <_binary_bin_swap_img_size-0x3ce0>
ffffffffc020929e:	85aa                	mv	a1,a0
ffffffffc02092a0:	4601                	li	a2,0
ffffffffc02092a2:	854a                	mv	a0,s2
ffffffffc02092a4:	9782                	jalr	a5
ffffffffc02092a6:	8a2a                	mv	s4,a0
ffffffffc02092a8:	10051e63          	bnez	a0,ffffffffc02093c4 <sfs_do_mount+0x184>
ffffffffc02092ac:	408c                	lw	a1,0(s1)
ffffffffc02092ae:	2f8dc637          	lui	a2,0x2f8dc
ffffffffc02092b2:	e2a60613          	addi	a2,a2,-470 # 2f8dbe2a <_binary_bin_sfs_img_size+0x2f866b2a>
ffffffffc02092b6:	14c59863          	bne	a1,a2,ffffffffc0209406 <sfs_do_mount+0x1c6>
ffffffffc02092ba:	40dc                	lw	a5,4(s1)
ffffffffc02092bc:	00093603          	ld	a2,0(s2)
ffffffffc02092c0:	02079713          	slli	a4,a5,0x20
ffffffffc02092c4:	9301                	srli	a4,a4,0x20
ffffffffc02092c6:	12e66763          	bltu	a2,a4,ffffffffc02093f4 <sfs_do_mount+0x1b4>
ffffffffc02092ca:	020485a3          	sb	zero,43(s1)
ffffffffc02092ce:	0084af03          	lw	t5,8(s1)
ffffffffc02092d2:	00c4ae83          	lw	t4,12(s1)
ffffffffc02092d6:	0104ae03          	lw	t3,16(s1)
ffffffffc02092da:	0144a303          	lw	t1,20(s1)
ffffffffc02092de:	0184a883          	lw	a7,24(s1)
ffffffffc02092e2:	01c4a803          	lw	a6,28(s1)
ffffffffc02092e6:	5090                	lw	a2,32(s1)
ffffffffc02092e8:	50d4                	lw	a3,36(s1)
ffffffffc02092ea:	5498                	lw	a4,40(s1)
ffffffffc02092ec:	6511                	lui	a0,0x4
ffffffffc02092ee:	c00c                	sw	a1,0(s0)
ffffffffc02092f0:	c05c                	sw	a5,4(s0)
ffffffffc02092f2:	01e42423          	sw	t5,8(s0)
ffffffffc02092f6:	01d42623          	sw	t4,12(s0)
ffffffffc02092fa:	01c42823          	sw	t3,16(s0)
ffffffffc02092fe:	00642a23          	sw	t1,20(s0)
ffffffffc0209302:	01142c23          	sw	a7,24(s0)
ffffffffc0209306:	01042e23          	sw	a6,28(s0)
ffffffffc020930a:	d010                	sw	a2,32(s0)
ffffffffc020930c:	d054                	sw	a3,36(s0)
ffffffffc020930e:	d418                	sw	a4,40(s0)
ffffffffc0209310:	cb2fa0ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc0209314:	f448                	sd	a0,168(s0)
ffffffffc0209316:	8c2a                	mv	s8,a0
ffffffffc0209318:	18050c63          	beqz	a0,ffffffffc02094b0 <sfs_do_mount+0x270>
ffffffffc020931c:	6711                	lui	a4,0x4
ffffffffc020931e:	87aa                	mv	a5,a0
ffffffffc0209320:	972a                	add	a4,a4,a0
ffffffffc0209322:	e79c                	sd	a5,8(a5)
ffffffffc0209324:	e39c                	sd	a5,0(a5)
ffffffffc0209326:	07c1                	addi	a5,a5,16
ffffffffc0209328:	fee79de3          	bne	a5,a4,ffffffffc0209322 <sfs_do_mount+0xe2>
ffffffffc020932c:	0044eb83          	lwu	s7,4(s1)
ffffffffc0209330:	67a1                	lui	a5,0x8
ffffffffc0209332:	fff78993          	addi	s3,a5,-1 # 7fff <_binary_bin_swap_img_size+0x2ff>
ffffffffc0209336:	9bce                	add	s7,s7,s3
ffffffffc0209338:	77e1                	lui	a5,0xffff8
ffffffffc020933a:	00fbfbb3          	and	s7,s7,a5
ffffffffc020933e:	2b81                	sext.w	s7,s7
ffffffffc0209340:	855e                	mv	a0,s7
ffffffffc0209342:	7e4010ef          	jal	ra,ffffffffc020ab26 <bitmap_create>
ffffffffc0209346:	fc08                	sd	a0,56(s0)
ffffffffc0209348:	8d2a                	mv	s10,a0
ffffffffc020934a:	14050f63          	beqz	a0,ffffffffc02094a8 <sfs_do_mount+0x268>
ffffffffc020934e:	0044e783          	lwu	a5,4(s1)
ffffffffc0209352:	082c                	addi	a1,sp,24
ffffffffc0209354:	97ce                	add	a5,a5,s3
ffffffffc0209356:	00f7d713          	srli	a4,a5,0xf
ffffffffc020935a:	e43a                	sd	a4,8(sp)
ffffffffc020935c:	40f7d993          	srai	s3,a5,0xf
ffffffffc0209360:	1db010ef          	jal	ra,ffffffffc020ad3a <bitmap_getdata>
ffffffffc0209364:	14050c63          	beqz	a0,ffffffffc02094bc <sfs_do_mount+0x27c>
ffffffffc0209368:	00c9979b          	slliw	a5,s3,0xc
ffffffffc020936c:	66e2                	ld	a3,24(sp)
ffffffffc020936e:	1782                	slli	a5,a5,0x20
ffffffffc0209370:	9381                	srli	a5,a5,0x20
ffffffffc0209372:	14d79563          	bne	a5,a3,ffffffffc02094bc <sfs_do_mount+0x27c>
ffffffffc0209376:	6722                	ld	a4,8(sp)
ffffffffc0209378:	6d89                	lui	s11,0x2
ffffffffc020937a:	89aa                	mv	s3,a0
ffffffffc020937c:	00c71c93          	slli	s9,a4,0xc
ffffffffc0209380:	9caa                	add	s9,s9,a0
ffffffffc0209382:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0209386:	e711                	bnez	a4,ffffffffc0209392 <sfs_do_mount+0x152>
ffffffffc0209388:	a079                	j	ffffffffc0209416 <sfs_do_mount+0x1d6>
ffffffffc020938a:	6785                	lui	a5,0x1
ffffffffc020938c:	99be                	add	s3,s3,a5
ffffffffc020938e:	093c8463          	beq	s9,s3,ffffffffc0209416 <sfs_do_mount+0x1d6>
ffffffffc0209392:	013d86bb          	addw	a3,s11,s3
ffffffffc0209396:	1682                	slli	a3,a3,0x20
ffffffffc0209398:	6605                	lui	a2,0x1
ffffffffc020939a:	85ce                	mv	a1,s3
ffffffffc020939c:	9281                	srli	a3,a3,0x20
ffffffffc020939e:	1008                	addi	a0,sp,32
ffffffffc02093a0:	b8cfc0ef          	jal	ra,ffffffffc020572c <iobuf_init>
ffffffffc02093a4:	02093783          	ld	a5,32(s2)
ffffffffc02093a8:	85aa                	mv	a1,a0
ffffffffc02093aa:	4601                	li	a2,0
ffffffffc02093ac:	854a                	mv	a0,s2
ffffffffc02093ae:	9782                	jalr	a5
ffffffffc02093b0:	dd69                	beqz	a0,ffffffffc020938a <sfs_do_mount+0x14a>
ffffffffc02093b2:	e42a                	sd	a0,8(sp)
ffffffffc02093b4:	856a                	mv	a0,s10
ffffffffc02093b6:	16b010ef          	jal	ra,ffffffffc020ad20 <bitmap_destroy>
ffffffffc02093ba:	67a2                	ld	a5,8(sp)
ffffffffc02093bc:	8a3e                	mv	s4,a5
ffffffffc02093be:	8562                	mv	a0,s8
ffffffffc02093c0:	cb2fa0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc02093c4:	8526                	mv	a0,s1
ffffffffc02093c6:	cacfa0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc02093ca:	8522                	mv	a0,s0
ffffffffc02093cc:	ca6fa0ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc02093d0:	70aa                	ld	ra,168(sp)
ffffffffc02093d2:	740a                	ld	s0,160(sp)
ffffffffc02093d4:	64ea                	ld	s1,152(sp)
ffffffffc02093d6:	694a                	ld	s2,144(sp)
ffffffffc02093d8:	69aa                	ld	s3,136(sp)
ffffffffc02093da:	7ae6                	ld	s5,120(sp)
ffffffffc02093dc:	7b46                	ld	s6,112(sp)
ffffffffc02093de:	7ba6                	ld	s7,104(sp)
ffffffffc02093e0:	7c06                	ld	s8,96(sp)
ffffffffc02093e2:	6ce6                	ld	s9,88(sp)
ffffffffc02093e4:	6d46                	ld	s10,80(sp)
ffffffffc02093e6:	6da6                	ld	s11,72(sp)
ffffffffc02093e8:	8552                	mv	a0,s4
ffffffffc02093ea:	6a0a                	ld	s4,128(sp)
ffffffffc02093ec:	614d                	addi	sp,sp,176
ffffffffc02093ee:	8082                	ret
ffffffffc02093f0:	5a71                	li	s4,-4
ffffffffc02093f2:	bfe1                	j	ffffffffc02093ca <sfs_do_mount+0x18a>
ffffffffc02093f4:	85be                	mv	a1,a5
ffffffffc02093f6:	00006517          	auipc	a0,0x6
ffffffffc02093fa:	aaa50513          	addi	a0,a0,-1366 # ffffffffc020eea0 <dev_node_ops+0x1b0>
ffffffffc02093fe:	d2df60ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0209402:	5a75                	li	s4,-3
ffffffffc0209404:	b7c1                	j	ffffffffc02093c4 <sfs_do_mount+0x184>
ffffffffc0209406:	00006517          	auipc	a0,0x6
ffffffffc020940a:	a6250513          	addi	a0,a0,-1438 # ffffffffc020ee68 <dev_node_ops+0x178>
ffffffffc020940e:	d1df60ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0209412:	5a75                	li	s4,-3
ffffffffc0209414:	bf45                	j	ffffffffc02093c4 <sfs_do_mount+0x184>
ffffffffc0209416:	00442903          	lw	s2,4(s0)
ffffffffc020941a:	4481                	li	s1,0
ffffffffc020941c:	080b8c63          	beqz	s7,ffffffffc02094b4 <sfs_do_mount+0x274>
ffffffffc0209420:	85a6                	mv	a1,s1
ffffffffc0209422:	856a                	mv	a0,s10
ffffffffc0209424:	083010ef          	jal	ra,ffffffffc020aca6 <bitmap_test>
ffffffffc0209428:	c111                	beqz	a0,ffffffffc020942c <sfs_do_mount+0x1ec>
ffffffffc020942a:	2b05                	addiw	s6,s6,1
ffffffffc020942c:	2485                	addiw	s1,s1,1
ffffffffc020942e:	fe9b99e3          	bne	s7,s1,ffffffffc0209420 <sfs_do_mount+0x1e0>
ffffffffc0209432:	441c                	lw	a5,8(s0)
ffffffffc0209434:	0d679463          	bne	a5,s6,ffffffffc02094fc <sfs_do_mount+0x2bc>
ffffffffc0209438:	4585                	li	a1,1
ffffffffc020943a:	05040513          	addi	a0,s0,80
ffffffffc020943e:	04043023          	sd	zero,64(s0)
ffffffffc0209442:	afcfb0ef          	jal	ra,ffffffffc020473e <sem_init>
ffffffffc0209446:	4585                	li	a1,1
ffffffffc0209448:	06840513          	addi	a0,s0,104
ffffffffc020944c:	af2fb0ef          	jal	ra,ffffffffc020473e <sem_init>
ffffffffc0209450:	4585                	li	a1,1
ffffffffc0209452:	08040513          	addi	a0,s0,128
ffffffffc0209456:	ae8fb0ef          	jal	ra,ffffffffc020473e <sem_init>
ffffffffc020945a:	09840793          	addi	a5,s0,152
ffffffffc020945e:	f05c                	sd	a5,160(s0)
ffffffffc0209460:	ec5c                	sd	a5,152(s0)
ffffffffc0209462:	874a                	mv	a4,s2
ffffffffc0209464:	86da                	mv	a3,s6
ffffffffc0209466:	4169063b          	subw	a2,s2,s6
ffffffffc020946a:	00c40593          	addi	a1,s0,12
ffffffffc020946e:	00006517          	auipc	a0,0x6
ffffffffc0209472:	ac250513          	addi	a0,a0,-1342 # ffffffffc020ef30 <dev_node_ops+0x240>
ffffffffc0209476:	cb5f60ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020947a:	00000797          	auipc	a5,0x0
ffffffffc020947e:	c8878793          	addi	a5,a5,-888 # ffffffffc0209102 <sfs_sync>
ffffffffc0209482:	fc5c                	sd	a5,184(s0)
ffffffffc0209484:	00000797          	auipc	a5,0x0
ffffffffc0209488:	d6478793          	addi	a5,a5,-668 # ffffffffc02091e8 <sfs_get_root>
ffffffffc020948c:	e07c                	sd	a5,192(s0)
ffffffffc020948e:	00000797          	auipc	a5,0x0
ffffffffc0209492:	b5e78793          	addi	a5,a5,-1186 # ffffffffc0208fec <sfs_unmount>
ffffffffc0209496:	e47c                	sd	a5,200(s0)
ffffffffc0209498:	00000797          	auipc	a5,0x0
ffffffffc020949c:	bd878793          	addi	a5,a5,-1064 # ffffffffc0209070 <sfs_cleanup>
ffffffffc02094a0:	e87c                	sd	a5,208(s0)
ffffffffc02094a2:	008ab023          	sd	s0,0(s5)
ffffffffc02094a6:	b72d                	j	ffffffffc02093d0 <sfs_do_mount+0x190>
ffffffffc02094a8:	5a71                	li	s4,-4
ffffffffc02094aa:	bf11                	j	ffffffffc02093be <sfs_do_mount+0x17e>
ffffffffc02094ac:	5a49                	li	s4,-14
ffffffffc02094ae:	b70d                	j	ffffffffc02093d0 <sfs_do_mount+0x190>
ffffffffc02094b0:	5a71                	li	s4,-4
ffffffffc02094b2:	bf09                	j	ffffffffc02093c4 <sfs_do_mount+0x184>
ffffffffc02094b4:	4b01                	li	s6,0
ffffffffc02094b6:	bfb5                	j	ffffffffc0209432 <sfs_do_mount+0x1f2>
ffffffffc02094b8:	5a71                	li	s4,-4
ffffffffc02094ba:	bf19                	j	ffffffffc02093d0 <sfs_do_mount+0x190>
ffffffffc02094bc:	00006697          	auipc	a3,0x6
ffffffffc02094c0:	a1468693          	addi	a3,a3,-1516 # ffffffffc020eed0 <dev_node_ops+0x1e0>
ffffffffc02094c4:	00002617          	auipc	a2,0x2
ffffffffc02094c8:	66460613          	addi	a2,a2,1636 # ffffffffc020bb28 <commands+0x250>
ffffffffc02094cc:	08300593          	li	a1,131
ffffffffc02094d0:	00006517          	auipc	a0,0x6
ffffffffc02094d4:	90850513          	addi	a0,a0,-1784 # ffffffffc020edd8 <dev_node_ops+0xe8>
ffffffffc02094d8:	d57f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02094dc:	00006697          	auipc	a3,0x6
ffffffffc02094e0:	8cc68693          	addi	a3,a3,-1844 # ffffffffc020eda8 <dev_node_ops+0xb8>
ffffffffc02094e4:	00002617          	auipc	a2,0x2
ffffffffc02094e8:	64460613          	addi	a2,a2,1604 # ffffffffc020bb28 <commands+0x250>
ffffffffc02094ec:	0a300593          	li	a1,163
ffffffffc02094f0:	00006517          	auipc	a0,0x6
ffffffffc02094f4:	8e850513          	addi	a0,a0,-1816 # ffffffffc020edd8 <dev_node_ops+0xe8>
ffffffffc02094f8:	d37f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02094fc:	00006697          	auipc	a3,0x6
ffffffffc0209500:	a0468693          	addi	a3,a3,-1532 # ffffffffc020ef00 <dev_node_ops+0x210>
ffffffffc0209504:	00002617          	auipc	a2,0x2
ffffffffc0209508:	62460613          	addi	a2,a2,1572 # ffffffffc020bb28 <commands+0x250>
ffffffffc020950c:	0e000593          	li	a1,224
ffffffffc0209510:	00006517          	auipc	a0,0x6
ffffffffc0209514:	8c850513          	addi	a0,a0,-1848 # ffffffffc020edd8 <dev_node_ops+0xe8>
ffffffffc0209518:	d17f60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020951c <sfs_mount>:
ffffffffc020951c:	00000597          	auipc	a1,0x0
ffffffffc0209520:	d2458593          	addi	a1,a1,-732 # ffffffffc0209240 <sfs_do_mount>
ffffffffc0209524:	e96fe06f          	j	ffffffffc0207bba <vfs_mount>

ffffffffc0209528 <sfs_opendir>:
ffffffffc0209528:	0235f593          	andi	a1,a1,35
ffffffffc020952c:	4501                	li	a0,0
ffffffffc020952e:	e191                	bnez	a1,ffffffffc0209532 <sfs_opendir+0xa>
ffffffffc0209530:	8082                	ret
ffffffffc0209532:	553d                	li	a0,-17
ffffffffc0209534:	8082                	ret

ffffffffc0209536 <sfs_openfile>:
ffffffffc0209536:	4501                	li	a0,0
ffffffffc0209538:	8082                	ret

ffffffffc020953a <sfs_gettype>:
ffffffffc020953a:	1141                	addi	sp,sp,-16
ffffffffc020953c:	e406                	sd	ra,8(sp)
ffffffffc020953e:	c939                	beqz	a0,ffffffffc0209594 <sfs_gettype+0x5a>
ffffffffc0209540:	4d34                	lw	a3,88(a0)
ffffffffc0209542:	6785                	lui	a5,0x1
ffffffffc0209544:	23578713          	addi	a4,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc0209548:	04e69663          	bne	a3,a4,ffffffffc0209594 <sfs_gettype+0x5a>
ffffffffc020954c:	6114                	ld	a3,0(a0)
ffffffffc020954e:	4709                	li	a4,2
ffffffffc0209550:	0046d683          	lhu	a3,4(a3)
ffffffffc0209554:	02e68a63          	beq	a3,a4,ffffffffc0209588 <sfs_gettype+0x4e>
ffffffffc0209558:	470d                	li	a4,3
ffffffffc020955a:	02e68163          	beq	a3,a4,ffffffffc020957c <sfs_gettype+0x42>
ffffffffc020955e:	4705                	li	a4,1
ffffffffc0209560:	00e68f63          	beq	a3,a4,ffffffffc020957e <sfs_gettype+0x44>
ffffffffc0209564:	00006617          	auipc	a2,0x6
ffffffffc0209568:	a3c60613          	addi	a2,a2,-1476 # ffffffffc020efa0 <dev_node_ops+0x2b0>
ffffffffc020956c:	38f00593          	li	a1,911
ffffffffc0209570:	00006517          	auipc	a0,0x6
ffffffffc0209574:	a1850513          	addi	a0,a0,-1512 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc0209578:	cb7f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020957c:	678d                	lui	a5,0x3
ffffffffc020957e:	60a2                	ld	ra,8(sp)
ffffffffc0209580:	c19c                	sw	a5,0(a1)
ffffffffc0209582:	4501                	li	a0,0
ffffffffc0209584:	0141                	addi	sp,sp,16
ffffffffc0209586:	8082                	ret
ffffffffc0209588:	60a2                	ld	ra,8(sp)
ffffffffc020958a:	6789                	lui	a5,0x2
ffffffffc020958c:	c19c                	sw	a5,0(a1)
ffffffffc020958e:	4501                	li	a0,0
ffffffffc0209590:	0141                	addi	sp,sp,16
ffffffffc0209592:	8082                	ret
ffffffffc0209594:	00006697          	auipc	a3,0x6
ffffffffc0209598:	9bc68693          	addi	a3,a3,-1604 # ffffffffc020ef50 <dev_node_ops+0x260>
ffffffffc020959c:	00002617          	auipc	a2,0x2
ffffffffc02095a0:	58c60613          	addi	a2,a2,1420 # ffffffffc020bb28 <commands+0x250>
ffffffffc02095a4:	38300593          	li	a1,899
ffffffffc02095a8:	00006517          	auipc	a0,0x6
ffffffffc02095ac:	9e050513          	addi	a0,a0,-1568 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc02095b0:	c7ff60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02095b4 <sfs_fsync>:
ffffffffc02095b4:	7179                	addi	sp,sp,-48
ffffffffc02095b6:	ec26                	sd	s1,24(sp)
ffffffffc02095b8:	7524                	ld	s1,104(a0)
ffffffffc02095ba:	f406                	sd	ra,40(sp)
ffffffffc02095bc:	f022                	sd	s0,32(sp)
ffffffffc02095be:	e84a                	sd	s2,16(sp)
ffffffffc02095c0:	e44e                	sd	s3,8(sp)
ffffffffc02095c2:	c4bd                	beqz	s1,ffffffffc0209630 <sfs_fsync+0x7c>
ffffffffc02095c4:	0b04a783          	lw	a5,176(s1)
ffffffffc02095c8:	e7a5                	bnez	a5,ffffffffc0209630 <sfs_fsync+0x7c>
ffffffffc02095ca:	4d38                	lw	a4,88(a0)
ffffffffc02095cc:	6785                	lui	a5,0x1
ffffffffc02095ce:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc02095d2:	842a                	mv	s0,a0
ffffffffc02095d4:	06f71e63          	bne	a4,a5,ffffffffc0209650 <sfs_fsync+0x9c>
ffffffffc02095d8:	691c                	ld	a5,16(a0)
ffffffffc02095da:	4901                	li	s2,0
ffffffffc02095dc:	eb89                	bnez	a5,ffffffffc02095ee <sfs_fsync+0x3a>
ffffffffc02095de:	70a2                	ld	ra,40(sp)
ffffffffc02095e0:	7402                	ld	s0,32(sp)
ffffffffc02095e2:	64e2                	ld	s1,24(sp)
ffffffffc02095e4:	69a2                	ld	s3,8(sp)
ffffffffc02095e6:	854a                	mv	a0,s2
ffffffffc02095e8:	6942                	ld	s2,16(sp)
ffffffffc02095ea:	6145                	addi	sp,sp,48
ffffffffc02095ec:	8082                	ret
ffffffffc02095ee:	02050993          	addi	s3,a0,32
ffffffffc02095f2:	854e                	mv	a0,s3
ffffffffc02095f4:	956fb0ef          	jal	ra,ffffffffc020474a <down>
ffffffffc02095f8:	681c                	ld	a5,16(s0)
ffffffffc02095fa:	ef81                	bnez	a5,ffffffffc0209612 <sfs_fsync+0x5e>
ffffffffc02095fc:	854e                	mv	a0,s3
ffffffffc02095fe:	948fb0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc0209602:	70a2                	ld	ra,40(sp)
ffffffffc0209604:	7402                	ld	s0,32(sp)
ffffffffc0209606:	64e2                	ld	s1,24(sp)
ffffffffc0209608:	69a2                	ld	s3,8(sp)
ffffffffc020960a:	854a                	mv	a0,s2
ffffffffc020960c:	6942                	ld	s2,16(sp)
ffffffffc020960e:	6145                	addi	sp,sp,48
ffffffffc0209610:	8082                	ret
ffffffffc0209612:	4414                	lw	a3,8(s0)
ffffffffc0209614:	600c                	ld	a1,0(s0)
ffffffffc0209616:	00043823          	sd	zero,16(s0)
ffffffffc020961a:	4701                	li	a4,0
ffffffffc020961c:	04000613          	li	a2,64
ffffffffc0209620:	8526                	mv	a0,s1
ffffffffc0209622:	0bf010ef          	jal	ra,ffffffffc020aee0 <sfs_wbuf>
ffffffffc0209626:	892a                	mv	s2,a0
ffffffffc0209628:	d971                	beqz	a0,ffffffffc02095fc <sfs_fsync+0x48>
ffffffffc020962a:	4785                	li	a5,1
ffffffffc020962c:	e81c                	sd	a5,16(s0)
ffffffffc020962e:	b7f9                	j	ffffffffc02095fc <sfs_fsync+0x48>
ffffffffc0209630:	00005697          	auipc	a3,0x5
ffffffffc0209634:	77868693          	addi	a3,a3,1912 # ffffffffc020eda8 <dev_node_ops+0xb8>
ffffffffc0209638:	00002617          	auipc	a2,0x2
ffffffffc020963c:	4f060613          	addi	a2,a2,1264 # ffffffffc020bb28 <commands+0x250>
ffffffffc0209640:	2c700593          	li	a1,711
ffffffffc0209644:	00006517          	auipc	a0,0x6
ffffffffc0209648:	94450513          	addi	a0,a0,-1724 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020964c:	be3f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209650:	00006697          	auipc	a3,0x6
ffffffffc0209654:	90068693          	addi	a3,a3,-1792 # ffffffffc020ef50 <dev_node_ops+0x260>
ffffffffc0209658:	00002617          	auipc	a2,0x2
ffffffffc020965c:	4d060613          	addi	a2,a2,1232 # ffffffffc020bb28 <commands+0x250>
ffffffffc0209660:	2c800593          	li	a1,712
ffffffffc0209664:	00006517          	auipc	a0,0x6
ffffffffc0209668:	92450513          	addi	a0,a0,-1756 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020966c:	bc3f60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209670 <sfs_fstat>:
ffffffffc0209670:	1101                	addi	sp,sp,-32
ffffffffc0209672:	e426                	sd	s1,8(sp)
ffffffffc0209674:	84ae                	mv	s1,a1
ffffffffc0209676:	e822                	sd	s0,16(sp)
ffffffffc0209678:	02000613          	li	a2,32
ffffffffc020967c:	842a                	mv	s0,a0
ffffffffc020967e:	4581                	li	a1,0
ffffffffc0209680:	8526                	mv	a0,s1
ffffffffc0209682:	ec06                	sd	ra,24(sp)
ffffffffc0209684:	2af010ef          	jal	ra,ffffffffc020b132 <memset>
ffffffffc0209688:	c439                	beqz	s0,ffffffffc02096d6 <sfs_fstat+0x66>
ffffffffc020968a:	783c                	ld	a5,112(s0)
ffffffffc020968c:	c7a9                	beqz	a5,ffffffffc02096d6 <sfs_fstat+0x66>
ffffffffc020968e:	6bbc                	ld	a5,80(a5)
ffffffffc0209690:	c3b9                	beqz	a5,ffffffffc02096d6 <sfs_fstat+0x66>
ffffffffc0209692:	00005597          	auipc	a1,0x5
ffffffffc0209696:	f3658593          	addi	a1,a1,-202 # ffffffffc020e5c8 <syscalls+0x990>
ffffffffc020969a:	8522                	mv	a0,s0
ffffffffc020969c:	aa5fe0ef          	jal	ra,ffffffffc0208140 <inode_check>
ffffffffc02096a0:	783c                	ld	a5,112(s0)
ffffffffc02096a2:	85a6                	mv	a1,s1
ffffffffc02096a4:	8522                	mv	a0,s0
ffffffffc02096a6:	6bbc                	ld	a5,80(a5)
ffffffffc02096a8:	9782                	jalr	a5
ffffffffc02096aa:	e10d                	bnez	a0,ffffffffc02096cc <sfs_fstat+0x5c>
ffffffffc02096ac:	4c38                	lw	a4,88(s0)
ffffffffc02096ae:	6785                	lui	a5,0x1
ffffffffc02096b0:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc02096b4:	04f71163          	bne	a4,a5,ffffffffc02096f6 <sfs_fstat+0x86>
ffffffffc02096b8:	601c                	ld	a5,0(s0)
ffffffffc02096ba:	0067d683          	lhu	a3,6(a5)
ffffffffc02096be:	0087e703          	lwu	a4,8(a5)
ffffffffc02096c2:	0007e783          	lwu	a5,0(a5)
ffffffffc02096c6:	e494                	sd	a3,8(s1)
ffffffffc02096c8:	e898                	sd	a4,16(s1)
ffffffffc02096ca:	ec9c                	sd	a5,24(s1)
ffffffffc02096cc:	60e2                	ld	ra,24(sp)
ffffffffc02096ce:	6442                	ld	s0,16(sp)
ffffffffc02096d0:	64a2                	ld	s1,8(sp)
ffffffffc02096d2:	6105                	addi	sp,sp,32
ffffffffc02096d4:	8082                	ret
ffffffffc02096d6:	00005697          	auipc	a3,0x5
ffffffffc02096da:	e8a68693          	addi	a3,a3,-374 # ffffffffc020e560 <syscalls+0x928>
ffffffffc02096de:	00002617          	auipc	a2,0x2
ffffffffc02096e2:	44a60613          	addi	a2,a2,1098 # ffffffffc020bb28 <commands+0x250>
ffffffffc02096e6:	2b800593          	li	a1,696
ffffffffc02096ea:	00006517          	auipc	a0,0x6
ffffffffc02096ee:	89e50513          	addi	a0,a0,-1890 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc02096f2:	b3df60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02096f6:	00006697          	auipc	a3,0x6
ffffffffc02096fa:	85a68693          	addi	a3,a3,-1958 # ffffffffc020ef50 <dev_node_ops+0x260>
ffffffffc02096fe:	00002617          	auipc	a2,0x2
ffffffffc0209702:	42a60613          	addi	a2,a2,1066 # ffffffffc020bb28 <commands+0x250>
ffffffffc0209706:	2bb00593          	li	a1,699
ffffffffc020970a:	00006517          	auipc	a0,0x6
ffffffffc020970e:	87e50513          	addi	a0,a0,-1922 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc0209712:	b1df60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209716 <sfs_tryseek>:
ffffffffc0209716:	080007b7          	lui	a5,0x8000
ffffffffc020971a:	04f5fd63          	bgeu	a1,a5,ffffffffc0209774 <sfs_tryseek+0x5e>
ffffffffc020971e:	1101                	addi	sp,sp,-32
ffffffffc0209720:	e822                	sd	s0,16(sp)
ffffffffc0209722:	ec06                	sd	ra,24(sp)
ffffffffc0209724:	e426                	sd	s1,8(sp)
ffffffffc0209726:	842a                	mv	s0,a0
ffffffffc0209728:	c921                	beqz	a0,ffffffffc0209778 <sfs_tryseek+0x62>
ffffffffc020972a:	4d38                	lw	a4,88(a0)
ffffffffc020972c:	6785                	lui	a5,0x1
ffffffffc020972e:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc0209732:	04f71363          	bne	a4,a5,ffffffffc0209778 <sfs_tryseek+0x62>
ffffffffc0209736:	611c                	ld	a5,0(a0)
ffffffffc0209738:	84ae                	mv	s1,a1
ffffffffc020973a:	0007e783          	lwu	a5,0(a5)
ffffffffc020973e:	02b7d563          	bge	a5,a1,ffffffffc0209768 <sfs_tryseek+0x52>
ffffffffc0209742:	793c                	ld	a5,112(a0)
ffffffffc0209744:	cbb1                	beqz	a5,ffffffffc0209798 <sfs_tryseek+0x82>
ffffffffc0209746:	73bc                	ld	a5,96(a5)
ffffffffc0209748:	cba1                	beqz	a5,ffffffffc0209798 <sfs_tryseek+0x82>
ffffffffc020974a:	00005597          	auipc	a1,0x5
ffffffffc020974e:	2fe58593          	addi	a1,a1,766 # ffffffffc020ea48 <syscalls+0xe10>
ffffffffc0209752:	9effe0ef          	jal	ra,ffffffffc0208140 <inode_check>
ffffffffc0209756:	783c                	ld	a5,112(s0)
ffffffffc0209758:	8522                	mv	a0,s0
ffffffffc020975a:	6442                	ld	s0,16(sp)
ffffffffc020975c:	60e2                	ld	ra,24(sp)
ffffffffc020975e:	73bc                	ld	a5,96(a5)
ffffffffc0209760:	85a6                	mv	a1,s1
ffffffffc0209762:	64a2                	ld	s1,8(sp)
ffffffffc0209764:	6105                	addi	sp,sp,32
ffffffffc0209766:	8782                	jr	a5
ffffffffc0209768:	60e2                	ld	ra,24(sp)
ffffffffc020976a:	6442                	ld	s0,16(sp)
ffffffffc020976c:	64a2                	ld	s1,8(sp)
ffffffffc020976e:	4501                	li	a0,0
ffffffffc0209770:	6105                	addi	sp,sp,32
ffffffffc0209772:	8082                	ret
ffffffffc0209774:	5575                	li	a0,-3
ffffffffc0209776:	8082                	ret
ffffffffc0209778:	00005697          	auipc	a3,0x5
ffffffffc020977c:	7d868693          	addi	a3,a3,2008 # ffffffffc020ef50 <dev_node_ops+0x260>
ffffffffc0209780:	00002617          	auipc	a2,0x2
ffffffffc0209784:	3a860613          	addi	a2,a2,936 # ffffffffc020bb28 <commands+0x250>
ffffffffc0209788:	39a00593          	li	a1,922
ffffffffc020978c:	00005517          	auipc	a0,0x5
ffffffffc0209790:	7fc50513          	addi	a0,a0,2044 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc0209794:	a9bf60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209798:	00005697          	auipc	a3,0x5
ffffffffc020979c:	25868693          	addi	a3,a3,600 # ffffffffc020e9f0 <syscalls+0xdb8>
ffffffffc02097a0:	00002617          	auipc	a2,0x2
ffffffffc02097a4:	38860613          	addi	a2,a2,904 # ffffffffc020bb28 <commands+0x250>
ffffffffc02097a8:	39c00593          	li	a1,924
ffffffffc02097ac:	00005517          	auipc	a0,0x5
ffffffffc02097b0:	7dc50513          	addi	a0,a0,2012 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc02097b4:	a7bf60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02097b8 <sfs_close>:
ffffffffc02097b8:	1141                	addi	sp,sp,-16
ffffffffc02097ba:	e406                	sd	ra,8(sp)
ffffffffc02097bc:	e022                	sd	s0,0(sp)
ffffffffc02097be:	c11d                	beqz	a0,ffffffffc02097e4 <sfs_close+0x2c>
ffffffffc02097c0:	793c                	ld	a5,112(a0)
ffffffffc02097c2:	842a                	mv	s0,a0
ffffffffc02097c4:	c385                	beqz	a5,ffffffffc02097e4 <sfs_close+0x2c>
ffffffffc02097c6:	7b9c                	ld	a5,48(a5)
ffffffffc02097c8:	cf91                	beqz	a5,ffffffffc02097e4 <sfs_close+0x2c>
ffffffffc02097ca:	00004597          	auipc	a1,0x4
ffffffffc02097ce:	c8e58593          	addi	a1,a1,-882 # ffffffffc020d458 <default_pmm_manager+0x460>
ffffffffc02097d2:	96ffe0ef          	jal	ra,ffffffffc0208140 <inode_check>
ffffffffc02097d6:	783c                	ld	a5,112(s0)
ffffffffc02097d8:	8522                	mv	a0,s0
ffffffffc02097da:	6402                	ld	s0,0(sp)
ffffffffc02097dc:	60a2                	ld	ra,8(sp)
ffffffffc02097de:	7b9c                	ld	a5,48(a5)
ffffffffc02097e0:	0141                	addi	sp,sp,16
ffffffffc02097e2:	8782                	jr	a5
ffffffffc02097e4:	00004697          	auipc	a3,0x4
ffffffffc02097e8:	c2468693          	addi	a3,a3,-988 # ffffffffc020d408 <default_pmm_manager+0x410>
ffffffffc02097ec:	00002617          	auipc	a2,0x2
ffffffffc02097f0:	33c60613          	addi	a2,a2,828 # ffffffffc020bb28 <commands+0x250>
ffffffffc02097f4:	21c00593          	li	a1,540
ffffffffc02097f8:	00005517          	auipc	a0,0x5
ffffffffc02097fc:	79050513          	addi	a0,a0,1936 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc0209800:	a2ff60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209804 <sfs_io.part.0>:
ffffffffc0209804:	1141                	addi	sp,sp,-16
ffffffffc0209806:	00005697          	auipc	a3,0x5
ffffffffc020980a:	74a68693          	addi	a3,a3,1866 # ffffffffc020ef50 <dev_node_ops+0x260>
ffffffffc020980e:	00002617          	auipc	a2,0x2
ffffffffc0209812:	31a60613          	addi	a2,a2,794 # ffffffffc020bb28 <commands+0x250>
ffffffffc0209816:	29700593          	li	a1,663
ffffffffc020981a:	00005517          	auipc	a0,0x5
ffffffffc020981e:	76e50513          	addi	a0,a0,1902 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc0209822:	e406                	sd	ra,8(sp)
ffffffffc0209824:	a0bf60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209828 <sfs_block_free>:
ffffffffc0209828:	1101                	addi	sp,sp,-32
ffffffffc020982a:	e426                	sd	s1,8(sp)
ffffffffc020982c:	ec06                	sd	ra,24(sp)
ffffffffc020982e:	e822                	sd	s0,16(sp)
ffffffffc0209830:	4154                	lw	a3,4(a0)
ffffffffc0209832:	84ae                	mv	s1,a1
ffffffffc0209834:	c595                	beqz	a1,ffffffffc0209860 <sfs_block_free+0x38>
ffffffffc0209836:	02d5f563          	bgeu	a1,a3,ffffffffc0209860 <sfs_block_free+0x38>
ffffffffc020983a:	842a                	mv	s0,a0
ffffffffc020983c:	7d08                	ld	a0,56(a0)
ffffffffc020983e:	468010ef          	jal	ra,ffffffffc020aca6 <bitmap_test>
ffffffffc0209842:	ed05                	bnez	a0,ffffffffc020987a <sfs_block_free+0x52>
ffffffffc0209844:	7c08                	ld	a0,56(s0)
ffffffffc0209846:	85a6                	mv	a1,s1
ffffffffc0209848:	486010ef          	jal	ra,ffffffffc020acce <bitmap_free>
ffffffffc020984c:	441c                	lw	a5,8(s0)
ffffffffc020984e:	4705                	li	a4,1
ffffffffc0209850:	60e2                	ld	ra,24(sp)
ffffffffc0209852:	2785                	addiw	a5,a5,1
ffffffffc0209854:	e038                	sd	a4,64(s0)
ffffffffc0209856:	c41c                	sw	a5,8(s0)
ffffffffc0209858:	6442                	ld	s0,16(sp)
ffffffffc020985a:	64a2                	ld	s1,8(sp)
ffffffffc020985c:	6105                	addi	sp,sp,32
ffffffffc020985e:	8082                	ret
ffffffffc0209860:	8726                	mv	a4,s1
ffffffffc0209862:	00005617          	auipc	a2,0x5
ffffffffc0209866:	75660613          	addi	a2,a2,1878 # ffffffffc020efb8 <dev_node_ops+0x2c8>
ffffffffc020986a:	05300593          	li	a1,83
ffffffffc020986e:	00005517          	auipc	a0,0x5
ffffffffc0209872:	71a50513          	addi	a0,a0,1818 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc0209876:	9b9f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020987a:	00005697          	auipc	a3,0x5
ffffffffc020987e:	77668693          	addi	a3,a3,1910 # ffffffffc020eff0 <dev_node_ops+0x300>
ffffffffc0209882:	00002617          	auipc	a2,0x2
ffffffffc0209886:	2a660613          	addi	a2,a2,678 # ffffffffc020bb28 <commands+0x250>
ffffffffc020988a:	06a00593          	li	a1,106
ffffffffc020988e:	00005517          	auipc	a0,0x5
ffffffffc0209892:	6fa50513          	addi	a0,a0,1786 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc0209896:	999f60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020989a <sfs_reclaim>:
ffffffffc020989a:	1101                	addi	sp,sp,-32
ffffffffc020989c:	e426                	sd	s1,8(sp)
ffffffffc020989e:	7524                	ld	s1,104(a0)
ffffffffc02098a0:	ec06                	sd	ra,24(sp)
ffffffffc02098a2:	e822                	sd	s0,16(sp)
ffffffffc02098a4:	e04a                	sd	s2,0(sp)
ffffffffc02098a6:	0e048a63          	beqz	s1,ffffffffc020999a <sfs_reclaim+0x100>
ffffffffc02098aa:	0b04a783          	lw	a5,176(s1)
ffffffffc02098ae:	0e079663          	bnez	a5,ffffffffc020999a <sfs_reclaim+0x100>
ffffffffc02098b2:	4d38                	lw	a4,88(a0)
ffffffffc02098b4:	6785                	lui	a5,0x1
ffffffffc02098b6:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc02098ba:	842a                	mv	s0,a0
ffffffffc02098bc:	10f71f63          	bne	a4,a5,ffffffffc02099da <sfs_reclaim+0x140>
ffffffffc02098c0:	8526                	mv	a0,s1
ffffffffc02098c2:	f0aff0ef          	jal	ra,ffffffffc0208fcc <lock_sfs_fs>
ffffffffc02098c6:	4c1c                	lw	a5,24(s0)
ffffffffc02098c8:	0ef05963          	blez	a5,ffffffffc02099ba <sfs_reclaim+0x120>
ffffffffc02098cc:	fff7871b          	addiw	a4,a5,-1
ffffffffc02098d0:	cc18                	sw	a4,24(s0)
ffffffffc02098d2:	eb59                	bnez	a4,ffffffffc0209968 <sfs_reclaim+0xce>
ffffffffc02098d4:	05c42903          	lw	s2,92(s0)
ffffffffc02098d8:	08091863          	bnez	s2,ffffffffc0209968 <sfs_reclaim+0xce>
ffffffffc02098dc:	601c                	ld	a5,0(s0)
ffffffffc02098de:	0067d783          	lhu	a5,6(a5)
ffffffffc02098e2:	e785                	bnez	a5,ffffffffc020990a <sfs_reclaim+0x70>
ffffffffc02098e4:	783c                	ld	a5,112(s0)
ffffffffc02098e6:	10078a63          	beqz	a5,ffffffffc02099fa <sfs_reclaim+0x160>
ffffffffc02098ea:	73bc                	ld	a5,96(a5)
ffffffffc02098ec:	10078763          	beqz	a5,ffffffffc02099fa <sfs_reclaim+0x160>
ffffffffc02098f0:	00005597          	auipc	a1,0x5
ffffffffc02098f4:	15858593          	addi	a1,a1,344 # ffffffffc020ea48 <syscalls+0xe10>
ffffffffc02098f8:	8522                	mv	a0,s0
ffffffffc02098fa:	847fe0ef          	jal	ra,ffffffffc0208140 <inode_check>
ffffffffc02098fe:	783c                	ld	a5,112(s0)
ffffffffc0209900:	4581                	li	a1,0
ffffffffc0209902:	8522                	mv	a0,s0
ffffffffc0209904:	73bc                	ld	a5,96(a5)
ffffffffc0209906:	9782                	jalr	a5
ffffffffc0209908:	e559                	bnez	a0,ffffffffc0209996 <sfs_reclaim+0xfc>
ffffffffc020990a:	681c                	ld	a5,16(s0)
ffffffffc020990c:	c39d                	beqz	a5,ffffffffc0209932 <sfs_reclaim+0x98>
ffffffffc020990e:	783c                	ld	a5,112(s0)
ffffffffc0209910:	10078563          	beqz	a5,ffffffffc0209a1a <sfs_reclaim+0x180>
ffffffffc0209914:	7b9c                	ld	a5,48(a5)
ffffffffc0209916:	10078263          	beqz	a5,ffffffffc0209a1a <sfs_reclaim+0x180>
ffffffffc020991a:	8522                	mv	a0,s0
ffffffffc020991c:	00004597          	auipc	a1,0x4
ffffffffc0209920:	b3c58593          	addi	a1,a1,-1220 # ffffffffc020d458 <default_pmm_manager+0x460>
ffffffffc0209924:	81dfe0ef          	jal	ra,ffffffffc0208140 <inode_check>
ffffffffc0209928:	783c                	ld	a5,112(s0)
ffffffffc020992a:	8522                	mv	a0,s0
ffffffffc020992c:	7b9c                	ld	a5,48(a5)
ffffffffc020992e:	9782                	jalr	a5
ffffffffc0209930:	e13d                	bnez	a0,ffffffffc0209996 <sfs_reclaim+0xfc>
ffffffffc0209932:	7c18                	ld	a4,56(s0)
ffffffffc0209934:	603c                	ld	a5,64(s0)
ffffffffc0209936:	8526                	mv	a0,s1
ffffffffc0209938:	e71c                	sd	a5,8(a4)
ffffffffc020993a:	e398                	sd	a4,0(a5)
ffffffffc020993c:	6438                	ld	a4,72(s0)
ffffffffc020993e:	683c                	ld	a5,80(s0)
ffffffffc0209940:	e71c                	sd	a5,8(a4)
ffffffffc0209942:	e398                	sd	a4,0(a5)
ffffffffc0209944:	e98ff0ef          	jal	ra,ffffffffc0208fdc <unlock_sfs_fs>
ffffffffc0209948:	6008                	ld	a0,0(s0)
ffffffffc020994a:	00655783          	lhu	a5,6(a0)
ffffffffc020994e:	cb85                	beqz	a5,ffffffffc020997e <sfs_reclaim+0xe4>
ffffffffc0209950:	f23f90ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc0209954:	8522                	mv	a0,s0
ffffffffc0209956:	f7efe0ef          	jal	ra,ffffffffc02080d4 <inode_kill>
ffffffffc020995a:	60e2                	ld	ra,24(sp)
ffffffffc020995c:	6442                	ld	s0,16(sp)
ffffffffc020995e:	64a2                	ld	s1,8(sp)
ffffffffc0209960:	854a                	mv	a0,s2
ffffffffc0209962:	6902                	ld	s2,0(sp)
ffffffffc0209964:	6105                	addi	sp,sp,32
ffffffffc0209966:	8082                	ret
ffffffffc0209968:	5945                	li	s2,-15
ffffffffc020996a:	8526                	mv	a0,s1
ffffffffc020996c:	e70ff0ef          	jal	ra,ffffffffc0208fdc <unlock_sfs_fs>
ffffffffc0209970:	60e2                	ld	ra,24(sp)
ffffffffc0209972:	6442                	ld	s0,16(sp)
ffffffffc0209974:	64a2                	ld	s1,8(sp)
ffffffffc0209976:	854a                	mv	a0,s2
ffffffffc0209978:	6902                	ld	s2,0(sp)
ffffffffc020997a:	6105                	addi	sp,sp,32
ffffffffc020997c:	8082                	ret
ffffffffc020997e:	440c                	lw	a1,8(s0)
ffffffffc0209980:	8526                	mv	a0,s1
ffffffffc0209982:	ea7ff0ef          	jal	ra,ffffffffc0209828 <sfs_block_free>
ffffffffc0209986:	6008                	ld	a0,0(s0)
ffffffffc0209988:	5d4c                	lw	a1,60(a0)
ffffffffc020998a:	d1f9                	beqz	a1,ffffffffc0209950 <sfs_reclaim+0xb6>
ffffffffc020998c:	8526                	mv	a0,s1
ffffffffc020998e:	e9bff0ef          	jal	ra,ffffffffc0209828 <sfs_block_free>
ffffffffc0209992:	6008                	ld	a0,0(s0)
ffffffffc0209994:	bf75                	j	ffffffffc0209950 <sfs_reclaim+0xb6>
ffffffffc0209996:	892a                	mv	s2,a0
ffffffffc0209998:	bfc9                	j	ffffffffc020996a <sfs_reclaim+0xd0>
ffffffffc020999a:	00005697          	auipc	a3,0x5
ffffffffc020999e:	40e68693          	addi	a3,a3,1038 # ffffffffc020eda8 <dev_node_ops+0xb8>
ffffffffc02099a2:	00002617          	auipc	a2,0x2
ffffffffc02099a6:	18660613          	addi	a2,a2,390 # ffffffffc020bb28 <commands+0x250>
ffffffffc02099aa:	35800593          	li	a1,856
ffffffffc02099ae:	00005517          	auipc	a0,0x5
ffffffffc02099b2:	5da50513          	addi	a0,a0,1498 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc02099b6:	879f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02099ba:	00005697          	auipc	a3,0x5
ffffffffc02099be:	65668693          	addi	a3,a3,1622 # ffffffffc020f010 <dev_node_ops+0x320>
ffffffffc02099c2:	00002617          	auipc	a2,0x2
ffffffffc02099c6:	16660613          	addi	a2,a2,358 # ffffffffc020bb28 <commands+0x250>
ffffffffc02099ca:	35e00593          	li	a1,862
ffffffffc02099ce:	00005517          	auipc	a0,0x5
ffffffffc02099d2:	5ba50513          	addi	a0,a0,1466 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc02099d6:	859f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02099da:	00005697          	auipc	a3,0x5
ffffffffc02099de:	57668693          	addi	a3,a3,1398 # ffffffffc020ef50 <dev_node_ops+0x260>
ffffffffc02099e2:	00002617          	auipc	a2,0x2
ffffffffc02099e6:	14660613          	addi	a2,a2,326 # ffffffffc020bb28 <commands+0x250>
ffffffffc02099ea:	35900593          	li	a1,857
ffffffffc02099ee:	00005517          	auipc	a0,0x5
ffffffffc02099f2:	59a50513          	addi	a0,a0,1434 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc02099f6:	839f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02099fa:	00005697          	auipc	a3,0x5
ffffffffc02099fe:	ff668693          	addi	a3,a3,-10 # ffffffffc020e9f0 <syscalls+0xdb8>
ffffffffc0209a02:	00002617          	auipc	a2,0x2
ffffffffc0209a06:	12660613          	addi	a2,a2,294 # ffffffffc020bb28 <commands+0x250>
ffffffffc0209a0a:	36300593          	li	a1,867
ffffffffc0209a0e:	00005517          	auipc	a0,0x5
ffffffffc0209a12:	57a50513          	addi	a0,a0,1402 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc0209a16:	819f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209a1a:	00004697          	auipc	a3,0x4
ffffffffc0209a1e:	9ee68693          	addi	a3,a3,-1554 # ffffffffc020d408 <default_pmm_manager+0x410>
ffffffffc0209a22:	00002617          	auipc	a2,0x2
ffffffffc0209a26:	10660613          	addi	a2,a2,262 # ffffffffc020bb28 <commands+0x250>
ffffffffc0209a2a:	36800593          	li	a1,872
ffffffffc0209a2e:	00005517          	auipc	a0,0x5
ffffffffc0209a32:	55a50513          	addi	a0,a0,1370 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc0209a36:	ff8f60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209a3a <sfs_block_alloc>:
ffffffffc0209a3a:	1101                	addi	sp,sp,-32
ffffffffc0209a3c:	e822                	sd	s0,16(sp)
ffffffffc0209a3e:	842a                	mv	s0,a0
ffffffffc0209a40:	7d08                	ld	a0,56(a0)
ffffffffc0209a42:	e426                	sd	s1,8(sp)
ffffffffc0209a44:	ec06                	sd	ra,24(sp)
ffffffffc0209a46:	84ae                	mv	s1,a1
ffffffffc0209a48:	1ee010ef          	jal	ra,ffffffffc020ac36 <bitmap_alloc>
ffffffffc0209a4c:	e90d                	bnez	a0,ffffffffc0209a7e <sfs_block_alloc+0x44>
ffffffffc0209a4e:	441c                	lw	a5,8(s0)
ffffffffc0209a50:	cbad                	beqz	a5,ffffffffc0209ac2 <sfs_block_alloc+0x88>
ffffffffc0209a52:	37fd                	addiw	a5,a5,-1
ffffffffc0209a54:	c41c                	sw	a5,8(s0)
ffffffffc0209a56:	408c                	lw	a1,0(s1)
ffffffffc0209a58:	4785                	li	a5,1
ffffffffc0209a5a:	e03c                	sd	a5,64(s0)
ffffffffc0209a5c:	4054                	lw	a3,4(s0)
ffffffffc0209a5e:	c58d                	beqz	a1,ffffffffc0209a88 <sfs_block_alloc+0x4e>
ffffffffc0209a60:	02d5f463          	bgeu	a1,a3,ffffffffc0209a88 <sfs_block_alloc+0x4e>
ffffffffc0209a64:	7c08                	ld	a0,56(s0)
ffffffffc0209a66:	240010ef          	jal	ra,ffffffffc020aca6 <bitmap_test>
ffffffffc0209a6a:	ed05                	bnez	a0,ffffffffc0209aa2 <sfs_block_alloc+0x68>
ffffffffc0209a6c:	8522                	mv	a0,s0
ffffffffc0209a6e:	6442                	ld	s0,16(sp)
ffffffffc0209a70:	408c                	lw	a1,0(s1)
ffffffffc0209a72:	60e2                	ld	ra,24(sp)
ffffffffc0209a74:	64a2                	ld	s1,8(sp)
ffffffffc0209a76:	4605                	li	a2,1
ffffffffc0209a78:	6105                	addi	sp,sp,32
ffffffffc0209a7a:	5b60106f          	j	ffffffffc020b030 <sfs_clear_block>
ffffffffc0209a7e:	60e2                	ld	ra,24(sp)
ffffffffc0209a80:	6442                	ld	s0,16(sp)
ffffffffc0209a82:	64a2                	ld	s1,8(sp)
ffffffffc0209a84:	6105                	addi	sp,sp,32
ffffffffc0209a86:	8082                	ret
ffffffffc0209a88:	872e                	mv	a4,a1
ffffffffc0209a8a:	00005617          	auipc	a2,0x5
ffffffffc0209a8e:	52e60613          	addi	a2,a2,1326 # ffffffffc020efb8 <dev_node_ops+0x2c8>
ffffffffc0209a92:	05300593          	li	a1,83
ffffffffc0209a96:	00005517          	auipc	a0,0x5
ffffffffc0209a9a:	4f250513          	addi	a0,a0,1266 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc0209a9e:	f90f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209aa2:	00005697          	auipc	a3,0x5
ffffffffc0209aa6:	5a668693          	addi	a3,a3,1446 # ffffffffc020f048 <dev_node_ops+0x358>
ffffffffc0209aaa:	00002617          	auipc	a2,0x2
ffffffffc0209aae:	07e60613          	addi	a2,a2,126 # ffffffffc020bb28 <commands+0x250>
ffffffffc0209ab2:	06100593          	li	a1,97
ffffffffc0209ab6:	00005517          	auipc	a0,0x5
ffffffffc0209aba:	4d250513          	addi	a0,a0,1234 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc0209abe:	f70f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209ac2:	00005697          	auipc	a3,0x5
ffffffffc0209ac6:	56668693          	addi	a3,a3,1382 # ffffffffc020f028 <dev_node_ops+0x338>
ffffffffc0209aca:	00002617          	auipc	a2,0x2
ffffffffc0209ace:	05e60613          	addi	a2,a2,94 # ffffffffc020bb28 <commands+0x250>
ffffffffc0209ad2:	05f00593          	li	a1,95
ffffffffc0209ad6:	00005517          	auipc	a0,0x5
ffffffffc0209ada:	4b250513          	addi	a0,a0,1202 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc0209ade:	f50f60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209ae2 <sfs_bmap_load_nolock>:
ffffffffc0209ae2:	7159                	addi	sp,sp,-112
ffffffffc0209ae4:	f85a                	sd	s6,48(sp)
ffffffffc0209ae6:	0005bb03          	ld	s6,0(a1)
ffffffffc0209aea:	f45e                	sd	s7,40(sp)
ffffffffc0209aec:	f486                	sd	ra,104(sp)
ffffffffc0209aee:	008b2b83          	lw	s7,8(s6)
ffffffffc0209af2:	f0a2                	sd	s0,96(sp)
ffffffffc0209af4:	eca6                	sd	s1,88(sp)
ffffffffc0209af6:	e8ca                	sd	s2,80(sp)
ffffffffc0209af8:	e4ce                	sd	s3,72(sp)
ffffffffc0209afa:	e0d2                	sd	s4,64(sp)
ffffffffc0209afc:	fc56                	sd	s5,56(sp)
ffffffffc0209afe:	f062                	sd	s8,32(sp)
ffffffffc0209b00:	ec66                	sd	s9,24(sp)
ffffffffc0209b02:	18cbe363          	bltu	s7,a2,ffffffffc0209c88 <sfs_bmap_load_nolock+0x1a6>
ffffffffc0209b06:	47ad                	li	a5,11
ffffffffc0209b08:	8aae                	mv	s5,a1
ffffffffc0209b0a:	8432                	mv	s0,a2
ffffffffc0209b0c:	84aa                	mv	s1,a0
ffffffffc0209b0e:	89b6                	mv	s3,a3
ffffffffc0209b10:	04c7f563          	bgeu	a5,a2,ffffffffc0209b5a <sfs_bmap_load_nolock+0x78>
ffffffffc0209b14:	ff46071b          	addiw	a4,a2,-12
ffffffffc0209b18:	0007069b          	sext.w	a3,a4
ffffffffc0209b1c:	3ff00793          	li	a5,1023
ffffffffc0209b20:	1ad7e163          	bltu	a5,a3,ffffffffc0209cc2 <sfs_bmap_load_nolock+0x1e0>
ffffffffc0209b24:	03cb2a03          	lw	s4,60(s6)
ffffffffc0209b28:	02071793          	slli	a5,a4,0x20
ffffffffc0209b2c:	c602                	sw	zero,12(sp)
ffffffffc0209b2e:	c452                	sw	s4,8(sp)
ffffffffc0209b30:	01e7dc13          	srli	s8,a5,0x1e
ffffffffc0209b34:	0e0a1e63          	bnez	s4,ffffffffc0209c30 <sfs_bmap_load_nolock+0x14e>
ffffffffc0209b38:	0acb8663          	beq	s7,a2,ffffffffc0209be4 <sfs_bmap_load_nolock+0x102>
ffffffffc0209b3c:	4a01                	li	s4,0
ffffffffc0209b3e:	40d4                	lw	a3,4(s1)
ffffffffc0209b40:	8752                	mv	a4,s4
ffffffffc0209b42:	00005617          	auipc	a2,0x5
ffffffffc0209b46:	47660613          	addi	a2,a2,1142 # ffffffffc020efb8 <dev_node_ops+0x2c8>
ffffffffc0209b4a:	05300593          	li	a1,83
ffffffffc0209b4e:	00005517          	auipc	a0,0x5
ffffffffc0209b52:	43a50513          	addi	a0,a0,1082 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc0209b56:	ed8f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209b5a:	02061793          	slli	a5,a2,0x20
ffffffffc0209b5e:	01e7da13          	srli	s4,a5,0x1e
ffffffffc0209b62:	9a5a                	add	s4,s4,s6
ffffffffc0209b64:	00ca2583          	lw	a1,12(s4)
ffffffffc0209b68:	c22e                	sw	a1,4(sp)
ffffffffc0209b6a:	ed99                	bnez	a1,ffffffffc0209b88 <sfs_bmap_load_nolock+0xa6>
ffffffffc0209b6c:	fccb98e3          	bne	s7,a2,ffffffffc0209b3c <sfs_bmap_load_nolock+0x5a>
ffffffffc0209b70:	004c                	addi	a1,sp,4
ffffffffc0209b72:	ec9ff0ef          	jal	ra,ffffffffc0209a3a <sfs_block_alloc>
ffffffffc0209b76:	892a                	mv	s2,a0
ffffffffc0209b78:	e921                	bnez	a0,ffffffffc0209bc8 <sfs_bmap_load_nolock+0xe6>
ffffffffc0209b7a:	4592                	lw	a1,4(sp)
ffffffffc0209b7c:	4705                	li	a4,1
ffffffffc0209b7e:	00ba2623          	sw	a1,12(s4)
ffffffffc0209b82:	00eab823          	sd	a4,16(s5)
ffffffffc0209b86:	d9dd                	beqz	a1,ffffffffc0209b3c <sfs_bmap_load_nolock+0x5a>
ffffffffc0209b88:	40d4                	lw	a3,4(s1)
ffffffffc0209b8a:	10d5ff63          	bgeu	a1,a3,ffffffffc0209ca8 <sfs_bmap_load_nolock+0x1c6>
ffffffffc0209b8e:	7c88                	ld	a0,56(s1)
ffffffffc0209b90:	116010ef          	jal	ra,ffffffffc020aca6 <bitmap_test>
ffffffffc0209b94:	18051363          	bnez	a0,ffffffffc0209d1a <sfs_bmap_load_nolock+0x238>
ffffffffc0209b98:	4a12                	lw	s4,4(sp)
ffffffffc0209b9a:	fa0a02e3          	beqz	s4,ffffffffc0209b3e <sfs_bmap_load_nolock+0x5c>
ffffffffc0209b9e:	40dc                	lw	a5,4(s1)
ffffffffc0209ba0:	f8fa7fe3          	bgeu	s4,a5,ffffffffc0209b3e <sfs_bmap_load_nolock+0x5c>
ffffffffc0209ba4:	7c88                	ld	a0,56(s1)
ffffffffc0209ba6:	85d2                	mv	a1,s4
ffffffffc0209ba8:	0fe010ef          	jal	ra,ffffffffc020aca6 <bitmap_test>
ffffffffc0209bac:	12051763          	bnez	a0,ffffffffc0209cda <sfs_bmap_load_nolock+0x1f8>
ffffffffc0209bb0:	008b9763          	bne	s7,s0,ffffffffc0209bbe <sfs_bmap_load_nolock+0xdc>
ffffffffc0209bb4:	008b2783          	lw	a5,8(s6)
ffffffffc0209bb8:	2785                	addiw	a5,a5,1
ffffffffc0209bba:	00fb2423          	sw	a5,8(s6)
ffffffffc0209bbe:	4901                	li	s2,0
ffffffffc0209bc0:	00098463          	beqz	s3,ffffffffc0209bc8 <sfs_bmap_load_nolock+0xe6>
ffffffffc0209bc4:	0149a023          	sw	s4,0(s3)
ffffffffc0209bc8:	70a6                	ld	ra,104(sp)
ffffffffc0209bca:	7406                	ld	s0,96(sp)
ffffffffc0209bcc:	64e6                	ld	s1,88(sp)
ffffffffc0209bce:	69a6                	ld	s3,72(sp)
ffffffffc0209bd0:	6a06                	ld	s4,64(sp)
ffffffffc0209bd2:	7ae2                	ld	s5,56(sp)
ffffffffc0209bd4:	7b42                	ld	s6,48(sp)
ffffffffc0209bd6:	7ba2                	ld	s7,40(sp)
ffffffffc0209bd8:	7c02                	ld	s8,32(sp)
ffffffffc0209bda:	6ce2                	ld	s9,24(sp)
ffffffffc0209bdc:	854a                	mv	a0,s2
ffffffffc0209bde:	6946                	ld	s2,80(sp)
ffffffffc0209be0:	6165                	addi	sp,sp,112
ffffffffc0209be2:	8082                	ret
ffffffffc0209be4:	002c                	addi	a1,sp,8
ffffffffc0209be6:	e55ff0ef          	jal	ra,ffffffffc0209a3a <sfs_block_alloc>
ffffffffc0209bea:	892a                	mv	s2,a0
ffffffffc0209bec:	00c10c93          	addi	s9,sp,12
ffffffffc0209bf0:	fd61                	bnez	a0,ffffffffc0209bc8 <sfs_bmap_load_nolock+0xe6>
ffffffffc0209bf2:	85e6                	mv	a1,s9
ffffffffc0209bf4:	8526                	mv	a0,s1
ffffffffc0209bf6:	e45ff0ef          	jal	ra,ffffffffc0209a3a <sfs_block_alloc>
ffffffffc0209bfa:	892a                	mv	s2,a0
ffffffffc0209bfc:	e925                	bnez	a0,ffffffffc0209c6c <sfs_bmap_load_nolock+0x18a>
ffffffffc0209bfe:	46a2                	lw	a3,8(sp)
ffffffffc0209c00:	85e6                	mv	a1,s9
ffffffffc0209c02:	8762                	mv	a4,s8
ffffffffc0209c04:	4611                	li	a2,4
ffffffffc0209c06:	8526                	mv	a0,s1
ffffffffc0209c08:	2d8010ef          	jal	ra,ffffffffc020aee0 <sfs_wbuf>
ffffffffc0209c0c:	45b2                	lw	a1,12(sp)
ffffffffc0209c0e:	892a                	mv	s2,a0
ffffffffc0209c10:	e939                	bnez	a0,ffffffffc0209c66 <sfs_bmap_load_nolock+0x184>
ffffffffc0209c12:	03cb2683          	lw	a3,60(s6)
ffffffffc0209c16:	4722                	lw	a4,8(sp)
ffffffffc0209c18:	c22e                	sw	a1,4(sp)
ffffffffc0209c1a:	f6d706e3          	beq	a4,a3,ffffffffc0209b86 <sfs_bmap_load_nolock+0xa4>
ffffffffc0209c1e:	eef1                	bnez	a3,ffffffffc0209cfa <sfs_bmap_load_nolock+0x218>
ffffffffc0209c20:	02eb2e23          	sw	a4,60(s6)
ffffffffc0209c24:	4705                	li	a4,1
ffffffffc0209c26:	00eab823          	sd	a4,16(s5)
ffffffffc0209c2a:	f00589e3          	beqz	a1,ffffffffc0209b3c <sfs_bmap_load_nolock+0x5a>
ffffffffc0209c2e:	bfa9                	j	ffffffffc0209b88 <sfs_bmap_load_nolock+0xa6>
ffffffffc0209c30:	00c10c93          	addi	s9,sp,12
ffffffffc0209c34:	8762                	mv	a4,s8
ffffffffc0209c36:	86d2                	mv	a3,s4
ffffffffc0209c38:	4611                	li	a2,4
ffffffffc0209c3a:	85e6                	mv	a1,s9
ffffffffc0209c3c:	224010ef          	jal	ra,ffffffffc020ae60 <sfs_rbuf>
ffffffffc0209c40:	892a                	mv	s2,a0
ffffffffc0209c42:	f159                	bnez	a0,ffffffffc0209bc8 <sfs_bmap_load_nolock+0xe6>
ffffffffc0209c44:	45b2                	lw	a1,12(sp)
ffffffffc0209c46:	e995                	bnez	a1,ffffffffc0209c7a <sfs_bmap_load_nolock+0x198>
ffffffffc0209c48:	fa8b85e3          	beq	s7,s0,ffffffffc0209bf2 <sfs_bmap_load_nolock+0x110>
ffffffffc0209c4c:	03cb2703          	lw	a4,60(s6)
ffffffffc0209c50:	47a2                	lw	a5,8(sp)
ffffffffc0209c52:	c202                	sw	zero,4(sp)
ffffffffc0209c54:	eee784e3          	beq	a5,a4,ffffffffc0209b3c <sfs_bmap_load_nolock+0x5a>
ffffffffc0209c58:	e34d                	bnez	a4,ffffffffc0209cfa <sfs_bmap_load_nolock+0x218>
ffffffffc0209c5a:	02fb2e23          	sw	a5,60(s6)
ffffffffc0209c5e:	4785                	li	a5,1
ffffffffc0209c60:	00fab823          	sd	a5,16(s5)
ffffffffc0209c64:	bde1                	j	ffffffffc0209b3c <sfs_bmap_load_nolock+0x5a>
ffffffffc0209c66:	8526                	mv	a0,s1
ffffffffc0209c68:	bc1ff0ef          	jal	ra,ffffffffc0209828 <sfs_block_free>
ffffffffc0209c6c:	45a2                	lw	a1,8(sp)
ffffffffc0209c6e:	f4ba0de3          	beq	s4,a1,ffffffffc0209bc8 <sfs_bmap_load_nolock+0xe6>
ffffffffc0209c72:	8526                	mv	a0,s1
ffffffffc0209c74:	bb5ff0ef          	jal	ra,ffffffffc0209828 <sfs_block_free>
ffffffffc0209c78:	bf81                	j	ffffffffc0209bc8 <sfs_bmap_load_nolock+0xe6>
ffffffffc0209c7a:	03cb2683          	lw	a3,60(s6)
ffffffffc0209c7e:	4722                	lw	a4,8(sp)
ffffffffc0209c80:	c22e                	sw	a1,4(sp)
ffffffffc0209c82:	f8e69ee3          	bne	a3,a4,ffffffffc0209c1e <sfs_bmap_load_nolock+0x13c>
ffffffffc0209c86:	b709                	j	ffffffffc0209b88 <sfs_bmap_load_nolock+0xa6>
ffffffffc0209c88:	00005697          	auipc	a3,0x5
ffffffffc0209c8c:	3e868693          	addi	a3,a3,1000 # ffffffffc020f070 <dev_node_ops+0x380>
ffffffffc0209c90:	00002617          	auipc	a2,0x2
ffffffffc0209c94:	e9860613          	addi	a2,a2,-360 # ffffffffc020bb28 <commands+0x250>
ffffffffc0209c98:	16400593          	li	a1,356
ffffffffc0209c9c:	00005517          	auipc	a0,0x5
ffffffffc0209ca0:	2ec50513          	addi	a0,a0,748 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc0209ca4:	d8af60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209ca8:	872e                	mv	a4,a1
ffffffffc0209caa:	00005617          	auipc	a2,0x5
ffffffffc0209cae:	30e60613          	addi	a2,a2,782 # ffffffffc020efb8 <dev_node_ops+0x2c8>
ffffffffc0209cb2:	05300593          	li	a1,83
ffffffffc0209cb6:	00005517          	auipc	a0,0x5
ffffffffc0209cba:	2d250513          	addi	a0,a0,722 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc0209cbe:	d70f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209cc2:	00005617          	auipc	a2,0x5
ffffffffc0209cc6:	3de60613          	addi	a2,a2,990 # ffffffffc020f0a0 <dev_node_ops+0x3b0>
ffffffffc0209cca:	11e00593          	li	a1,286
ffffffffc0209cce:	00005517          	auipc	a0,0x5
ffffffffc0209cd2:	2ba50513          	addi	a0,a0,698 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc0209cd6:	d58f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209cda:	00005697          	auipc	a3,0x5
ffffffffc0209cde:	31668693          	addi	a3,a3,790 # ffffffffc020eff0 <dev_node_ops+0x300>
ffffffffc0209ce2:	00002617          	auipc	a2,0x2
ffffffffc0209ce6:	e4660613          	addi	a2,a2,-442 # ffffffffc020bb28 <commands+0x250>
ffffffffc0209cea:	16b00593          	li	a1,363
ffffffffc0209cee:	00005517          	auipc	a0,0x5
ffffffffc0209cf2:	29a50513          	addi	a0,a0,666 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc0209cf6:	d38f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209cfa:	00005697          	auipc	a3,0x5
ffffffffc0209cfe:	38e68693          	addi	a3,a3,910 # ffffffffc020f088 <dev_node_ops+0x398>
ffffffffc0209d02:	00002617          	auipc	a2,0x2
ffffffffc0209d06:	e2660613          	addi	a2,a2,-474 # ffffffffc020bb28 <commands+0x250>
ffffffffc0209d0a:	11800593          	li	a1,280
ffffffffc0209d0e:	00005517          	auipc	a0,0x5
ffffffffc0209d12:	27a50513          	addi	a0,a0,634 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc0209d16:	d18f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209d1a:	00005697          	auipc	a3,0x5
ffffffffc0209d1e:	3b668693          	addi	a3,a3,950 # ffffffffc020f0d0 <dev_node_ops+0x3e0>
ffffffffc0209d22:	00002617          	auipc	a2,0x2
ffffffffc0209d26:	e0660613          	addi	a2,a2,-506 # ffffffffc020bb28 <commands+0x250>
ffffffffc0209d2a:	12100593          	li	a1,289
ffffffffc0209d2e:	00005517          	auipc	a0,0x5
ffffffffc0209d32:	25a50513          	addi	a0,a0,602 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc0209d36:	cf8f60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209d3a <sfs_io_nolock>:
ffffffffc0209d3a:	7175                	addi	sp,sp,-144
ffffffffc0209d3c:	f4ce                	sd	s3,104(sp)
ffffffffc0209d3e:	89ae                	mv	s3,a1
ffffffffc0209d40:	618c                	ld	a1,0(a1)
ffffffffc0209d42:	e506                	sd	ra,136(sp)
ffffffffc0209d44:	e122                	sd	s0,128(sp)
ffffffffc0209d46:	0045d883          	lhu	a7,4(a1)
ffffffffc0209d4a:	fca6                	sd	s1,120(sp)
ffffffffc0209d4c:	f8ca                	sd	s2,112(sp)
ffffffffc0209d4e:	f0d2                	sd	s4,96(sp)
ffffffffc0209d50:	ecd6                	sd	s5,88(sp)
ffffffffc0209d52:	e8da                	sd	s6,80(sp)
ffffffffc0209d54:	e4de                	sd	s7,72(sp)
ffffffffc0209d56:	e0e2                	sd	s8,64(sp)
ffffffffc0209d58:	fc66                	sd	s9,56(sp)
ffffffffc0209d5a:	f86a                	sd	s10,48(sp)
ffffffffc0209d5c:	f46e                	sd	s11,40(sp)
ffffffffc0209d5e:	4809                	li	a6,2
ffffffffc0209d60:	19088863          	beq	a7,a6,ffffffffc0209ef0 <sfs_io_nolock+0x1b6>
ffffffffc0209d64:	6304                	ld	s1,0(a4)
ffffffffc0209d66:	893a                	mv	s2,a4
ffffffffc0209d68:	00093023          	sd	zero,0(s2)
ffffffffc0209d6c:	08000737          	lui	a4,0x8000
ffffffffc0209d70:	8436                	mv	s0,a3
ffffffffc0209d72:	8b36                	mv	s6,a3
ffffffffc0209d74:	94b6                	add	s1,s1,a3
ffffffffc0209d76:	16e6fb63          	bgeu	a3,a4,ffffffffc0209eec <sfs_io_nolock+0x1b2>
ffffffffc0209d7a:	16d4c963          	blt	s1,a3,ffffffffc0209eec <sfs_io_nolock+0x1b2>
ffffffffc0209d7e:	8baa                	mv	s7,a0
ffffffffc0209d80:	4501                	li	a0,0
ffffffffc0209d82:	0a968363          	beq	a3,s1,ffffffffc0209e28 <sfs_io_nolock+0xee>
ffffffffc0209d86:	8c32                	mv	s8,a2
ffffffffc0209d88:	00977463          	bgeu	a4,s1,ffffffffc0209d90 <sfs_io_nolock+0x56>
ffffffffc0209d8c:	080004b7          	lui	s1,0x8000
ffffffffc0209d90:	cbdd                	beqz	a5,ffffffffc0209e46 <sfs_io_nolock+0x10c>
ffffffffc0209d92:	00001797          	auipc	a5,0x1
ffffffffc0209d96:	06e78793          	addi	a5,a5,110 # ffffffffc020ae00 <sfs_wblock>
ffffffffc0209d9a:	e43e                	sd	a5,8(sp)
ffffffffc0209d9c:	00001797          	auipc	a5,0x1
ffffffffc0209da0:	14478793          	addi	a5,a5,324 # ffffffffc020aee0 <sfs_wbuf>
ffffffffc0209da4:	e03e                	sd	a5,0(sp)
ffffffffc0209da6:	6705                	lui	a4,0x1
ffffffffc0209da8:	40c45613          	srai	a2,s0,0xc
ffffffffc0209dac:	40c4da93          	srai	s5,s1,0xc
ffffffffc0209db0:	fff70c93          	addi	s9,a4,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc0209db4:	40ca8a3b          	subw	s4,s5,a2
ffffffffc0209db8:	01947cb3          	and	s9,s0,s9
ffffffffc0209dbc:	8ad2                	mv	s5,s4
ffffffffc0209dbe:	00060d1b          	sext.w	s10,a2
ffffffffc0209dc2:	8de6                	mv	s11,s9
ffffffffc0209dc4:	020c8b63          	beqz	s9,ffffffffc0209dfa <sfs_io_nolock+0xc0>
ffffffffc0209dc8:	40848db3          	sub	s11,s1,s0
ffffffffc0209dcc:	080a1f63          	bnez	s4,ffffffffc0209e6a <sfs_io_nolock+0x130>
ffffffffc0209dd0:	0874                	addi	a3,sp,28
ffffffffc0209dd2:	866a                	mv	a2,s10
ffffffffc0209dd4:	85ce                	mv	a1,s3
ffffffffc0209dd6:	855e                	mv	a0,s7
ffffffffc0209dd8:	d0bff0ef          	jal	ra,ffffffffc0209ae2 <sfs_bmap_load_nolock>
ffffffffc0209ddc:	e145                	bnez	a0,ffffffffc0209e7c <sfs_io_nolock+0x142>
ffffffffc0209dde:	46f2                	lw	a3,28(sp)
ffffffffc0209de0:	6782                	ld	a5,0(sp)
ffffffffc0209de2:	8766                	mv	a4,s9
ffffffffc0209de4:	866e                	mv	a2,s11
ffffffffc0209de6:	85e2                	mv	a1,s8
ffffffffc0209de8:	855e                	mv	a0,s7
ffffffffc0209dea:	9782                	jalr	a5
ffffffffc0209dec:	e941                	bnez	a0,ffffffffc0209e7c <sfs_io_nolock+0x142>
ffffffffc0209dee:	0c0a0563          	beqz	s4,ffffffffc0209eb8 <sfs_io_nolock+0x17e>
ffffffffc0209df2:	9c6e                	add	s8,s8,s11
ffffffffc0209df4:	2d05                	addiw	s10,s10,1
ffffffffc0209df6:	fffa8a1b          	addiw	s4,s5,-1
ffffffffc0209dfa:	0c0a1263          	bnez	s4,ffffffffc0209ebe <sfs_io_nolock+0x184>
ffffffffc0209dfe:	14d2                	slli	s1,s1,0x34
ffffffffc0209e00:	0344da93          	srli	s5,s1,0x34
ffffffffc0209e04:	e8d1                	bnez	s1,ffffffffc0209e98 <sfs_io_nolock+0x15e>
ffffffffc0209e06:	01b40b33          	add	s6,s0,s11
ffffffffc0209e0a:	4501                	li	a0,0
ffffffffc0209e0c:	0009b783          	ld	a5,0(s3)
ffffffffc0209e10:	01b93023          	sd	s11,0(s2)
ffffffffc0209e14:	0007e703          	lwu	a4,0(a5)
ffffffffc0209e18:	01677863          	bgeu	a4,s6,ffffffffc0209e28 <sfs_io_nolock+0xee>
ffffffffc0209e1c:	01b4043b          	addw	s0,s0,s11
ffffffffc0209e20:	c380                	sw	s0,0(a5)
ffffffffc0209e22:	4785                	li	a5,1
ffffffffc0209e24:	00f9b823          	sd	a5,16(s3)
ffffffffc0209e28:	60aa                	ld	ra,136(sp)
ffffffffc0209e2a:	640a                	ld	s0,128(sp)
ffffffffc0209e2c:	74e6                	ld	s1,120(sp)
ffffffffc0209e2e:	7946                	ld	s2,112(sp)
ffffffffc0209e30:	79a6                	ld	s3,104(sp)
ffffffffc0209e32:	7a06                	ld	s4,96(sp)
ffffffffc0209e34:	6ae6                	ld	s5,88(sp)
ffffffffc0209e36:	6b46                	ld	s6,80(sp)
ffffffffc0209e38:	6ba6                	ld	s7,72(sp)
ffffffffc0209e3a:	6c06                	ld	s8,64(sp)
ffffffffc0209e3c:	7ce2                	ld	s9,56(sp)
ffffffffc0209e3e:	7d42                	ld	s10,48(sp)
ffffffffc0209e40:	7da2                	ld	s11,40(sp)
ffffffffc0209e42:	6149                	addi	sp,sp,144
ffffffffc0209e44:	8082                	ret
ffffffffc0209e46:	0005e783          	lwu	a5,0(a1)
ffffffffc0209e4a:	4501                	li	a0,0
ffffffffc0209e4c:	fcf45ee3          	bge	s0,a5,ffffffffc0209e28 <sfs_io_nolock+0xee>
ffffffffc0209e50:	0297c863          	blt	a5,s1,ffffffffc0209e80 <sfs_io_nolock+0x146>
ffffffffc0209e54:	00001797          	auipc	a5,0x1
ffffffffc0209e58:	f4c78793          	addi	a5,a5,-180 # ffffffffc020ada0 <sfs_rblock>
ffffffffc0209e5c:	e43e                	sd	a5,8(sp)
ffffffffc0209e5e:	00001797          	auipc	a5,0x1
ffffffffc0209e62:	00278793          	addi	a5,a5,2 # ffffffffc020ae60 <sfs_rbuf>
ffffffffc0209e66:	e03e                	sd	a5,0(sp)
ffffffffc0209e68:	bf3d                	j	ffffffffc0209da6 <sfs_io_nolock+0x6c>
ffffffffc0209e6a:	0874                	addi	a3,sp,28
ffffffffc0209e6c:	866a                	mv	a2,s10
ffffffffc0209e6e:	85ce                	mv	a1,s3
ffffffffc0209e70:	855e                	mv	a0,s7
ffffffffc0209e72:	41970db3          	sub	s11,a4,s9
ffffffffc0209e76:	c6dff0ef          	jal	ra,ffffffffc0209ae2 <sfs_bmap_load_nolock>
ffffffffc0209e7a:	d135                	beqz	a0,ffffffffc0209dde <sfs_io_nolock+0xa4>
ffffffffc0209e7c:	4d81                	li	s11,0
ffffffffc0209e7e:	b779                	j	ffffffffc0209e0c <sfs_io_nolock+0xd2>
ffffffffc0209e80:	84be                	mv	s1,a5
ffffffffc0209e82:	00001797          	auipc	a5,0x1
ffffffffc0209e86:	f1e78793          	addi	a5,a5,-226 # ffffffffc020ada0 <sfs_rblock>
ffffffffc0209e8a:	e43e                	sd	a5,8(sp)
ffffffffc0209e8c:	00001797          	auipc	a5,0x1
ffffffffc0209e90:	fd478793          	addi	a5,a5,-44 # ffffffffc020ae60 <sfs_rbuf>
ffffffffc0209e94:	e03e                	sd	a5,0(sp)
ffffffffc0209e96:	bf01                	j	ffffffffc0209da6 <sfs_io_nolock+0x6c>
ffffffffc0209e98:	0874                	addi	a3,sp,28
ffffffffc0209e9a:	866a                	mv	a2,s10
ffffffffc0209e9c:	85ce                	mv	a1,s3
ffffffffc0209e9e:	855e                	mv	a0,s7
ffffffffc0209ea0:	c43ff0ef          	jal	ra,ffffffffc0209ae2 <sfs_bmap_load_nolock>
ffffffffc0209ea4:	e911                	bnez	a0,ffffffffc0209eb8 <sfs_io_nolock+0x17e>
ffffffffc0209ea6:	46f2                	lw	a3,28(sp)
ffffffffc0209ea8:	6782                	ld	a5,0(sp)
ffffffffc0209eaa:	4701                	li	a4,0
ffffffffc0209eac:	8656                	mv	a2,s5
ffffffffc0209eae:	85e2                	mv	a1,s8
ffffffffc0209eb0:	855e                	mv	a0,s7
ffffffffc0209eb2:	9782                	jalr	a5
ffffffffc0209eb4:	e111                	bnez	a0,ffffffffc0209eb8 <sfs_io_nolock+0x17e>
ffffffffc0209eb6:	9dd6                	add	s11,s11,s5
ffffffffc0209eb8:	01b40b33          	add	s6,s0,s11
ffffffffc0209ebc:	bf81                	j	ffffffffc0209e0c <sfs_io_nolock+0xd2>
ffffffffc0209ebe:	0874                	addi	a3,sp,28
ffffffffc0209ec0:	866a                	mv	a2,s10
ffffffffc0209ec2:	85ce                	mv	a1,s3
ffffffffc0209ec4:	855e                	mv	a0,s7
ffffffffc0209ec6:	c1dff0ef          	jal	ra,ffffffffc0209ae2 <sfs_bmap_load_nolock>
ffffffffc0209eca:	f57d                	bnez	a0,ffffffffc0209eb8 <sfs_io_nolock+0x17e>
ffffffffc0209ecc:	4672                	lw	a2,28(sp)
ffffffffc0209ece:	67a2                	ld	a5,8(sp)
ffffffffc0209ed0:	86d2                	mv	a3,s4
ffffffffc0209ed2:	85e2                	mv	a1,s8
ffffffffc0209ed4:	855e                	mv	a0,s7
ffffffffc0209ed6:	9782                	jalr	a5
ffffffffc0209ed8:	f165                	bnez	a0,ffffffffc0209eb8 <sfs_io_nolock+0x17e>
ffffffffc0209eda:	00ca171b          	slliw	a4,s4,0xc
ffffffffc0209ede:	1702                	slli	a4,a4,0x20
ffffffffc0209ee0:	9301                	srli	a4,a4,0x20
ffffffffc0209ee2:	9dba                	add	s11,s11,a4
ffffffffc0209ee4:	9c3a                	add	s8,s8,a4
ffffffffc0209ee6:	014d0d3b          	addw	s10,s10,s4
ffffffffc0209eea:	bf11                	j	ffffffffc0209dfe <sfs_io_nolock+0xc4>
ffffffffc0209eec:	5575                	li	a0,-3
ffffffffc0209eee:	bf2d                	j	ffffffffc0209e28 <sfs_io_nolock+0xee>
ffffffffc0209ef0:	00005697          	auipc	a3,0x5
ffffffffc0209ef4:	20868693          	addi	a3,a3,520 # ffffffffc020f0f8 <dev_node_ops+0x408>
ffffffffc0209ef8:	00002617          	auipc	a2,0x2
ffffffffc0209efc:	c3060613          	addi	a2,a2,-976 # ffffffffc020bb28 <commands+0x250>
ffffffffc0209f00:	22b00593          	li	a1,555
ffffffffc0209f04:	00005517          	auipc	a0,0x5
ffffffffc0209f08:	08450513          	addi	a0,a0,132 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc0209f0c:	b22f60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209f10 <sfs_read>:
ffffffffc0209f10:	7139                	addi	sp,sp,-64
ffffffffc0209f12:	f04a                	sd	s2,32(sp)
ffffffffc0209f14:	06853903          	ld	s2,104(a0)
ffffffffc0209f18:	fc06                	sd	ra,56(sp)
ffffffffc0209f1a:	f822                	sd	s0,48(sp)
ffffffffc0209f1c:	f426                	sd	s1,40(sp)
ffffffffc0209f1e:	ec4e                	sd	s3,24(sp)
ffffffffc0209f20:	04090f63          	beqz	s2,ffffffffc0209f7e <sfs_read+0x6e>
ffffffffc0209f24:	0b092783          	lw	a5,176(s2)
ffffffffc0209f28:	ebb9                	bnez	a5,ffffffffc0209f7e <sfs_read+0x6e>
ffffffffc0209f2a:	4d38                	lw	a4,88(a0)
ffffffffc0209f2c:	6785                	lui	a5,0x1
ffffffffc0209f2e:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc0209f32:	842a                	mv	s0,a0
ffffffffc0209f34:	06f71563          	bne	a4,a5,ffffffffc0209f9e <sfs_read+0x8e>
ffffffffc0209f38:	02050993          	addi	s3,a0,32
ffffffffc0209f3c:	854e                	mv	a0,s3
ffffffffc0209f3e:	84ae                	mv	s1,a1
ffffffffc0209f40:	80bfa0ef          	jal	ra,ffffffffc020474a <down>
ffffffffc0209f44:	0184b803          	ld	a6,24(s1) # 8000018 <_binary_bin_sfs_img_size+0x7f8ad18>
ffffffffc0209f48:	6494                	ld	a3,8(s1)
ffffffffc0209f4a:	6090                	ld	a2,0(s1)
ffffffffc0209f4c:	85a2                	mv	a1,s0
ffffffffc0209f4e:	4781                	li	a5,0
ffffffffc0209f50:	0038                	addi	a4,sp,8
ffffffffc0209f52:	854a                	mv	a0,s2
ffffffffc0209f54:	e442                	sd	a6,8(sp)
ffffffffc0209f56:	de5ff0ef          	jal	ra,ffffffffc0209d3a <sfs_io_nolock>
ffffffffc0209f5a:	65a2                	ld	a1,8(sp)
ffffffffc0209f5c:	842a                	mv	s0,a0
ffffffffc0209f5e:	ed81                	bnez	a1,ffffffffc0209f76 <sfs_read+0x66>
ffffffffc0209f60:	854e                	mv	a0,s3
ffffffffc0209f62:	fe4fa0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc0209f66:	70e2                	ld	ra,56(sp)
ffffffffc0209f68:	8522                	mv	a0,s0
ffffffffc0209f6a:	7442                	ld	s0,48(sp)
ffffffffc0209f6c:	74a2                	ld	s1,40(sp)
ffffffffc0209f6e:	7902                	ld	s2,32(sp)
ffffffffc0209f70:	69e2                	ld	s3,24(sp)
ffffffffc0209f72:	6121                	addi	sp,sp,64
ffffffffc0209f74:	8082                	ret
ffffffffc0209f76:	8526                	mv	a0,s1
ffffffffc0209f78:	82bfb0ef          	jal	ra,ffffffffc02057a2 <iobuf_skip>
ffffffffc0209f7c:	b7d5                	j	ffffffffc0209f60 <sfs_read+0x50>
ffffffffc0209f7e:	00005697          	auipc	a3,0x5
ffffffffc0209f82:	e2a68693          	addi	a3,a3,-470 # ffffffffc020eda8 <dev_node_ops+0xb8>
ffffffffc0209f86:	00002617          	auipc	a2,0x2
ffffffffc0209f8a:	ba260613          	addi	a2,a2,-1118 # ffffffffc020bb28 <commands+0x250>
ffffffffc0209f8e:	29600593          	li	a1,662
ffffffffc0209f92:	00005517          	auipc	a0,0x5
ffffffffc0209f96:	ff650513          	addi	a0,a0,-10 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc0209f9a:	a94f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209f9e:	867ff0ef          	jal	ra,ffffffffc0209804 <sfs_io.part.0>

ffffffffc0209fa2 <sfs_write>:
ffffffffc0209fa2:	7139                	addi	sp,sp,-64
ffffffffc0209fa4:	f04a                	sd	s2,32(sp)
ffffffffc0209fa6:	06853903          	ld	s2,104(a0)
ffffffffc0209faa:	fc06                	sd	ra,56(sp)
ffffffffc0209fac:	f822                	sd	s0,48(sp)
ffffffffc0209fae:	f426                	sd	s1,40(sp)
ffffffffc0209fb0:	ec4e                	sd	s3,24(sp)
ffffffffc0209fb2:	04090f63          	beqz	s2,ffffffffc020a010 <sfs_write+0x6e>
ffffffffc0209fb6:	0b092783          	lw	a5,176(s2)
ffffffffc0209fba:	ebb9                	bnez	a5,ffffffffc020a010 <sfs_write+0x6e>
ffffffffc0209fbc:	4d38                	lw	a4,88(a0)
ffffffffc0209fbe:	6785                	lui	a5,0x1
ffffffffc0209fc0:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc0209fc4:	842a                	mv	s0,a0
ffffffffc0209fc6:	06f71563          	bne	a4,a5,ffffffffc020a030 <sfs_write+0x8e>
ffffffffc0209fca:	02050993          	addi	s3,a0,32
ffffffffc0209fce:	854e                	mv	a0,s3
ffffffffc0209fd0:	84ae                	mv	s1,a1
ffffffffc0209fd2:	f78fa0ef          	jal	ra,ffffffffc020474a <down>
ffffffffc0209fd6:	0184b803          	ld	a6,24(s1)
ffffffffc0209fda:	6494                	ld	a3,8(s1)
ffffffffc0209fdc:	6090                	ld	a2,0(s1)
ffffffffc0209fde:	85a2                	mv	a1,s0
ffffffffc0209fe0:	4785                	li	a5,1
ffffffffc0209fe2:	0038                	addi	a4,sp,8
ffffffffc0209fe4:	854a                	mv	a0,s2
ffffffffc0209fe6:	e442                	sd	a6,8(sp)
ffffffffc0209fe8:	d53ff0ef          	jal	ra,ffffffffc0209d3a <sfs_io_nolock>
ffffffffc0209fec:	65a2                	ld	a1,8(sp)
ffffffffc0209fee:	842a                	mv	s0,a0
ffffffffc0209ff0:	ed81                	bnez	a1,ffffffffc020a008 <sfs_write+0x66>
ffffffffc0209ff2:	854e                	mv	a0,s3
ffffffffc0209ff4:	f52fa0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc0209ff8:	70e2                	ld	ra,56(sp)
ffffffffc0209ffa:	8522                	mv	a0,s0
ffffffffc0209ffc:	7442                	ld	s0,48(sp)
ffffffffc0209ffe:	74a2                	ld	s1,40(sp)
ffffffffc020a000:	7902                	ld	s2,32(sp)
ffffffffc020a002:	69e2                	ld	s3,24(sp)
ffffffffc020a004:	6121                	addi	sp,sp,64
ffffffffc020a006:	8082                	ret
ffffffffc020a008:	8526                	mv	a0,s1
ffffffffc020a00a:	f98fb0ef          	jal	ra,ffffffffc02057a2 <iobuf_skip>
ffffffffc020a00e:	b7d5                	j	ffffffffc0209ff2 <sfs_write+0x50>
ffffffffc020a010:	00005697          	auipc	a3,0x5
ffffffffc020a014:	d9868693          	addi	a3,a3,-616 # ffffffffc020eda8 <dev_node_ops+0xb8>
ffffffffc020a018:	00002617          	auipc	a2,0x2
ffffffffc020a01c:	b1060613          	addi	a2,a2,-1264 # ffffffffc020bb28 <commands+0x250>
ffffffffc020a020:	29600593          	li	a1,662
ffffffffc020a024:	00005517          	auipc	a0,0x5
ffffffffc020a028:	f6450513          	addi	a0,a0,-156 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020a02c:	a02f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a030:	fd4ff0ef          	jal	ra,ffffffffc0209804 <sfs_io.part.0>

ffffffffc020a034 <sfs_dirent_read_nolock>:
ffffffffc020a034:	6198                	ld	a4,0(a1)
ffffffffc020a036:	7179                	addi	sp,sp,-48
ffffffffc020a038:	f406                	sd	ra,40(sp)
ffffffffc020a03a:	00475883          	lhu	a7,4(a4)
ffffffffc020a03e:	f022                	sd	s0,32(sp)
ffffffffc020a040:	ec26                	sd	s1,24(sp)
ffffffffc020a042:	4809                	li	a6,2
ffffffffc020a044:	05089b63          	bne	a7,a6,ffffffffc020a09a <sfs_dirent_read_nolock+0x66>
ffffffffc020a048:	4718                	lw	a4,8(a4)
ffffffffc020a04a:	87b2                	mv	a5,a2
ffffffffc020a04c:	2601                	sext.w	a2,a2
ffffffffc020a04e:	04e7f663          	bgeu	a5,a4,ffffffffc020a09a <sfs_dirent_read_nolock+0x66>
ffffffffc020a052:	84b6                	mv	s1,a3
ffffffffc020a054:	0074                	addi	a3,sp,12
ffffffffc020a056:	842a                	mv	s0,a0
ffffffffc020a058:	a8bff0ef          	jal	ra,ffffffffc0209ae2 <sfs_bmap_load_nolock>
ffffffffc020a05c:	c511                	beqz	a0,ffffffffc020a068 <sfs_dirent_read_nolock+0x34>
ffffffffc020a05e:	70a2                	ld	ra,40(sp)
ffffffffc020a060:	7402                	ld	s0,32(sp)
ffffffffc020a062:	64e2                	ld	s1,24(sp)
ffffffffc020a064:	6145                	addi	sp,sp,48
ffffffffc020a066:	8082                	ret
ffffffffc020a068:	45b2                	lw	a1,12(sp)
ffffffffc020a06a:	4054                	lw	a3,4(s0)
ffffffffc020a06c:	c5b9                	beqz	a1,ffffffffc020a0ba <sfs_dirent_read_nolock+0x86>
ffffffffc020a06e:	04d5f663          	bgeu	a1,a3,ffffffffc020a0ba <sfs_dirent_read_nolock+0x86>
ffffffffc020a072:	7c08                	ld	a0,56(s0)
ffffffffc020a074:	433000ef          	jal	ra,ffffffffc020aca6 <bitmap_test>
ffffffffc020a078:	ed31                	bnez	a0,ffffffffc020a0d4 <sfs_dirent_read_nolock+0xa0>
ffffffffc020a07a:	46b2                	lw	a3,12(sp)
ffffffffc020a07c:	4701                	li	a4,0
ffffffffc020a07e:	10400613          	li	a2,260
ffffffffc020a082:	85a6                	mv	a1,s1
ffffffffc020a084:	8522                	mv	a0,s0
ffffffffc020a086:	5db000ef          	jal	ra,ffffffffc020ae60 <sfs_rbuf>
ffffffffc020a08a:	f971                	bnez	a0,ffffffffc020a05e <sfs_dirent_read_nolock+0x2a>
ffffffffc020a08c:	100481a3          	sb	zero,259(s1)
ffffffffc020a090:	70a2                	ld	ra,40(sp)
ffffffffc020a092:	7402                	ld	s0,32(sp)
ffffffffc020a094:	64e2                	ld	s1,24(sp)
ffffffffc020a096:	6145                	addi	sp,sp,48
ffffffffc020a098:	8082                	ret
ffffffffc020a09a:	00005697          	auipc	a3,0x5
ffffffffc020a09e:	07e68693          	addi	a3,a3,126 # ffffffffc020f118 <dev_node_ops+0x428>
ffffffffc020a0a2:	00002617          	auipc	a2,0x2
ffffffffc020a0a6:	a8660613          	addi	a2,a2,-1402 # ffffffffc020bb28 <commands+0x250>
ffffffffc020a0aa:	18e00593          	li	a1,398
ffffffffc020a0ae:	00005517          	auipc	a0,0x5
ffffffffc020a0b2:	eda50513          	addi	a0,a0,-294 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020a0b6:	978f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a0ba:	872e                	mv	a4,a1
ffffffffc020a0bc:	00005617          	auipc	a2,0x5
ffffffffc020a0c0:	efc60613          	addi	a2,a2,-260 # ffffffffc020efb8 <dev_node_ops+0x2c8>
ffffffffc020a0c4:	05300593          	li	a1,83
ffffffffc020a0c8:	00005517          	auipc	a0,0x5
ffffffffc020a0cc:	ec050513          	addi	a0,a0,-320 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020a0d0:	95ef60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a0d4:	00005697          	auipc	a3,0x5
ffffffffc020a0d8:	f1c68693          	addi	a3,a3,-228 # ffffffffc020eff0 <dev_node_ops+0x300>
ffffffffc020a0dc:	00002617          	auipc	a2,0x2
ffffffffc020a0e0:	a4c60613          	addi	a2,a2,-1460 # ffffffffc020bb28 <commands+0x250>
ffffffffc020a0e4:	19500593          	li	a1,405
ffffffffc020a0e8:	00005517          	auipc	a0,0x5
ffffffffc020a0ec:	ea050513          	addi	a0,a0,-352 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020a0f0:	93ef60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020a0f4 <sfs_getdirentry>:
ffffffffc020a0f4:	715d                	addi	sp,sp,-80
ffffffffc020a0f6:	ec56                	sd	s5,24(sp)
ffffffffc020a0f8:	8aaa                	mv	s5,a0
ffffffffc020a0fa:	10400513          	li	a0,260
ffffffffc020a0fe:	e85a                	sd	s6,16(sp)
ffffffffc020a100:	e486                	sd	ra,72(sp)
ffffffffc020a102:	e0a2                	sd	s0,64(sp)
ffffffffc020a104:	fc26                	sd	s1,56(sp)
ffffffffc020a106:	f84a                	sd	s2,48(sp)
ffffffffc020a108:	f44e                	sd	s3,40(sp)
ffffffffc020a10a:	f052                	sd	s4,32(sp)
ffffffffc020a10c:	e45e                	sd	s7,8(sp)
ffffffffc020a10e:	e062                	sd	s8,0(sp)
ffffffffc020a110:	8b2e                	mv	s6,a1
ffffffffc020a112:	eb0f90ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc020a116:	cd61                	beqz	a0,ffffffffc020a1ee <sfs_getdirentry+0xfa>
ffffffffc020a118:	068abb83          	ld	s7,104(s5)
ffffffffc020a11c:	0c0b8b63          	beqz	s7,ffffffffc020a1f2 <sfs_getdirentry+0xfe>
ffffffffc020a120:	0b0ba783          	lw	a5,176(s7) # 10b0 <_binary_bin_swap_img_size-0x6c50>
ffffffffc020a124:	e7f9                	bnez	a5,ffffffffc020a1f2 <sfs_getdirentry+0xfe>
ffffffffc020a126:	058aa703          	lw	a4,88(s5)
ffffffffc020a12a:	6785                	lui	a5,0x1
ffffffffc020a12c:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a130:	0ef71163          	bne	a4,a5,ffffffffc020a212 <sfs_getdirentry+0x11e>
ffffffffc020a134:	008b3983          	ld	s3,8(s6)
ffffffffc020a138:	892a                	mv	s2,a0
ffffffffc020a13a:	0a09c163          	bltz	s3,ffffffffc020a1dc <sfs_getdirentry+0xe8>
ffffffffc020a13e:	0ff9f793          	zext.b	a5,s3
ffffffffc020a142:	efc9                	bnez	a5,ffffffffc020a1dc <sfs_getdirentry+0xe8>
ffffffffc020a144:	000ab783          	ld	a5,0(s5)
ffffffffc020a148:	0089d993          	srli	s3,s3,0x8
ffffffffc020a14c:	2981                	sext.w	s3,s3
ffffffffc020a14e:	479c                	lw	a5,8(a5)
ffffffffc020a150:	0937eb63          	bltu	a5,s3,ffffffffc020a1e6 <sfs_getdirentry+0xf2>
ffffffffc020a154:	020a8c13          	addi	s8,s5,32
ffffffffc020a158:	8562                	mv	a0,s8
ffffffffc020a15a:	df0fa0ef          	jal	ra,ffffffffc020474a <down>
ffffffffc020a15e:	000ab783          	ld	a5,0(s5)
ffffffffc020a162:	0087aa03          	lw	s4,8(a5)
ffffffffc020a166:	07405663          	blez	s4,ffffffffc020a1d2 <sfs_getdirentry+0xde>
ffffffffc020a16a:	4481                	li	s1,0
ffffffffc020a16c:	a811                	j	ffffffffc020a180 <sfs_getdirentry+0x8c>
ffffffffc020a16e:	00092783          	lw	a5,0(s2)
ffffffffc020a172:	c781                	beqz	a5,ffffffffc020a17a <sfs_getdirentry+0x86>
ffffffffc020a174:	02098263          	beqz	s3,ffffffffc020a198 <sfs_getdirentry+0xa4>
ffffffffc020a178:	39fd                	addiw	s3,s3,-1
ffffffffc020a17a:	2485                	addiw	s1,s1,1
ffffffffc020a17c:	049a0b63          	beq	s4,s1,ffffffffc020a1d2 <sfs_getdirentry+0xde>
ffffffffc020a180:	86ca                	mv	a3,s2
ffffffffc020a182:	8626                	mv	a2,s1
ffffffffc020a184:	85d6                	mv	a1,s5
ffffffffc020a186:	855e                	mv	a0,s7
ffffffffc020a188:	eadff0ef          	jal	ra,ffffffffc020a034 <sfs_dirent_read_nolock>
ffffffffc020a18c:	842a                	mv	s0,a0
ffffffffc020a18e:	d165                	beqz	a0,ffffffffc020a16e <sfs_getdirentry+0x7a>
ffffffffc020a190:	8562                	mv	a0,s8
ffffffffc020a192:	db4fa0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc020a196:	a831                	j	ffffffffc020a1b2 <sfs_getdirentry+0xbe>
ffffffffc020a198:	8562                	mv	a0,s8
ffffffffc020a19a:	dacfa0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc020a19e:	4701                	li	a4,0
ffffffffc020a1a0:	4685                	li	a3,1
ffffffffc020a1a2:	10000613          	li	a2,256
ffffffffc020a1a6:	00490593          	addi	a1,s2,4
ffffffffc020a1aa:	855a                	mv	a0,s6
ffffffffc020a1ac:	d8afb0ef          	jal	ra,ffffffffc0205736 <iobuf_move>
ffffffffc020a1b0:	842a                	mv	s0,a0
ffffffffc020a1b2:	854a                	mv	a0,s2
ffffffffc020a1b4:	ebef90ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc020a1b8:	60a6                	ld	ra,72(sp)
ffffffffc020a1ba:	8522                	mv	a0,s0
ffffffffc020a1bc:	6406                	ld	s0,64(sp)
ffffffffc020a1be:	74e2                	ld	s1,56(sp)
ffffffffc020a1c0:	7942                	ld	s2,48(sp)
ffffffffc020a1c2:	79a2                	ld	s3,40(sp)
ffffffffc020a1c4:	7a02                	ld	s4,32(sp)
ffffffffc020a1c6:	6ae2                	ld	s5,24(sp)
ffffffffc020a1c8:	6b42                	ld	s6,16(sp)
ffffffffc020a1ca:	6ba2                	ld	s7,8(sp)
ffffffffc020a1cc:	6c02                	ld	s8,0(sp)
ffffffffc020a1ce:	6161                	addi	sp,sp,80
ffffffffc020a1d0:	8082                	ret
ffffffffc020a1d2:	8562                	mv	a0,s8
ffffffffc020a1d4:	5441                	li	s0,-16
ffffffffc020a1d6:	d70fa0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc020a1da:	bfe1                	j	ffffffffc020a1b2 <sfs_getdirentry+0xbe>
ffffffffc020a1dc:	854a                	mv	a0,s2
ffffffffc020a1de:	e94f90ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc020a1e2:	5475                	li	s0,-3
ffffffffc020a1e4:	bfd1                	j	ffffffffc020a1b8 <sfs_getdirentry+0xc4>
ffffffffc020a1e6:	e8cf90ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc020a1ea:	5441                	li	s0,-16
ffffffffc020a1ec:	b7f1                	j	ffffffffc020a1b8 <sfs_getdirentry+0xc4>
ffffffffc020a1ee:	5471                	li	s0,-4
ffffffffc020a1f0:	b7e1                	j	ffffffffc020a1b8 <sfs_getdirentry+0xc4>
ffffffffc020a1f2:	00005697          	auipc	a3,0x5
ffffffffc020a1f6:	bb668693          	addi	a3,a3,-1098 # ffffffffc020eda8 <dev_node_ops+0xb8>
ffffffffc020a1fa:	00002617          	auipc	a2,0x2
ffffffffc020a1fe:	92e60613          	addi	a2,a2,-1746 # ffffffffc020bb28 <commands+0x250>
ffffffffc020a202:	33a00593          	li	a1,826
ffffffffc020a206:	00005517          	auipc	a0,0x5
ffffffffc020a20a:	d8250513          	addi	a0,a0,-638 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020a20e:	820f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a212:	00005697          	auipc	a3,0x5
ffffffffc020a216:	d3e68693          	addi	a3,a3,-706 # ffffffffc020ef50 <dev_node_ops+0x260>
ffffffffc020a21a:	00002617          	auipc	a2,0x2
ffffffffc020a21e:	90e60613          	addi	a2,a2,-1778 # ffffffffc020bb28 <commands+0x250>
ffffffffc020a222:	33b00593          	li	a1,827
ffffffffc020a226:	00005517          	auipc	a0,0x5
ffffffffc020a22a:	d6250513          	addi	a0,a0,-670 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020a22e:	800f60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020a232 <sfs_dirent_search_nolock.constprop.0>:
ffffffffc020a232:	715d                	addi	sp,sp,-80
ffffffffc020a234:	f052                	sd	s4,32(sp)
ffffffffc020a236:	8a2a                	mv	s4,a0
ffffffffc020a238:	8532                	mv	a0,a2
ffffffffc020a23a:	f44e                	sd	s3,40(sp)
ffffffffc020a23c:	e85a                	sd	s6,16(sp)
ffffffffc020a23e:	e45e                	sd	s7,8(sp)
ffffffffc020a240:	e486                	sd	ra,72(sp)
ffffffffc020a242:	e0a2                	sd	s0,64(sp)
ffffffffc020a244:	fc26                	sd	s1,56(sp)
ffffffffc020a246:	f84a                	sd	s2,48(sp)
ffffffffc020a248:	ec56                	sd	s5,24(sp)
ffffffffc020a24a:	e062                	sd	s8,0(sp)
ffffffffc020a24c:	8b32                	mv	s6,a2
ffffffffc020a24e:	89ae                	mv	s3,a1
ffffffffc020a250:	8bb6                	mv	s7,a3
ffffffffc020a252:	63f000ef          	jal	ra,ffffffffc020b090 <strlen>
ffffffffc020a256:	0ff00793          	li	a5,255
ffffffffc020a25a:	06a7ef63          	bltu	a5,a0,ffffffffc020a2d8 <sfs_dirent_search_nolock.constprop.0+0xa6>
ffffffffc020a25e:	10400513          	li	a0,260
ffffffffc020a262:	d60f90ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc020a266:	892a                	mv	s2,a0
ffffffffc020a268:	c535                	beqz	a0,ffffffffc020a2d4 <sfs_dirent_search_nolock.constprop.0+0xa2>
ffffffffc020a26a:	0009b783          	ld	a5,0(s3)
ffffffffc020a26e:	0087aa83          	lw	s5,8(a5)
ffffffffc020a272:	05505a63          	blez	s5,ffffffffc020a2c6 <sfs_dirent_search_nolock.constprop.0+0x94>
ffffffffc020a276:	4481                	li	s1,0
ffffffffc020a278:	00450c13          	addi	s8,a0,4
ffffffffc020a27c:	a829                	j	ffffffffc020a296 <sfs_dirent_search_nolock.constprop.0+0x64>
ffffffffc020a27e:	00092783          	lw	a5,0(s2)
ffffffffc020a282:	c799                	beqz	a5,ffffffffc020a290 <sfs_dirent_search_nolock.constprop.0+0x5e>
ffffffffc020a284:	85e2                	mv	a1,s8
ffffffffc020a286:	855a                	mv	a0,s6
ffffffffc020a288:	651000ef          	jal	ra,ffffffffc020b0d8 <strcmp>
ffffffffc020a28c:	842a                	mv	s0,a0
ffffffffc020a28e:	cd15                	beqz	a0,ffffffffc020a2ca <sfs_dirent_search_nolock.constprop.0+0x98>
ffffffffc020a290:	2485                	addiw	s1,s1,1
ffffffffc020a292:	029a8a63          	beq	s5,s1,ffffffffc020a2c6 <sfs_dirent_search_nolock.constprop.0+0x94>
ffffffffc020a296:	86ca                	mv	a3,s2
ffffffffc020a298:	8626                	mv	a2,s1
ffffffffc020a29a:	85ce                	mv	a1,s3
ffffffffc020a29c:	8552                	mv	a0,s4
ffffffffc020a29e:	d97ff0ef          	jal	ra,ffffffffc020a034 <sfs_dirent_read_nolock>
ffffffffc020a2a2:	842a                	mv	s0,a0
ffffffffc020a2a4:	dd69                	beqz	a0,ffffffffc020a27e <sfs_dirent_search_nolock.constprop.0+0x4c>
ffffffffc020a2a6:	854a                	mv	a0,s2
ffffffffc020a2a8:	dcaf90ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc020a2ac:	60a6                	ld	ra,72(sp)
ffffffffc020a2ae:	8522                	mv	a0,s0
ffffffffc020a2b0:	6406                	ld	s0,64(sp)
ffffffffc020a2b2:	74e2                	ld	s1,56(sp)
ffffffffc020a2b4:	7942                	ld	s2,48(sp)
ffffffffc020a2b6:	79a2                	ld	s3,40(sp)
ffffffffc020a2b8:	7a02                	ld	s4,32(sp)
ffffffffc020a2ba:	6ae2                	ld	s5,24(sp)
ffffffffc020a2bc:	6b42                	ld	s6,16(sp)
ffffffffc020a2be:	6ba2                	ld	s7,8(sp)
ffffffffc020a2c0:	6c02                	ld	s8,0(sp)
ffffffffc020a2c2:	6161                	addi	sp,sp,80
ffffffffc020a2c4:	8082                	ret
ffffffffc020a2c6:	5441                	li	s0,-16
ffffffffc020a2c8:	bff9                	j	ffffffffc020a2a6 <sfs_dirent_search_nolock.constprop.0+0x74>
ffffffffc020a2ca:	00092783          	lw	a5,0(s2)
ffffffffc020a2ce:	00fba023          	sw	a5,0(s7)
ffffffffc020a2d2:	bfd1                	j	ffffffffc020a2a6 <sfs_dirent_search_nolock.constprop.0+0x74>
ffffffffc020a2d4:	5471                	li	s0,-4
ffffffffc020a2d6:	bfd9                	j	ffffffffc020a2ac <sfs_dirent_search_nolock.constprop.0+0x7a>
ffffffffc020a2d8:	00005697          	auipc	a3,0x5
ffffffffc020a2dc:	e9068693          	addi	a3,a3,-368 # ffffffffc020f168 <dev_node_ops+0x478>
ffffffffc020a2e0:	00002617          	auipc	a2,0x2
ffffffffc020a2e4:	84860613          	addi	a2,a2,-1976 # ffffffffc020bb28 <commands+0x250>
ffffffffc020a2e8:	1ba00593          	li	a1,442
ffffffffc020a2ec:	00005517          	auipc	a0,0x5
ffffffffc020a2f0:	c9c50513          	addi	a0,a0,-868 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020a2f4:	f3bf50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020a2f8 <sfs_truncfile>:
ffffffffc020a2f8:	7175                	addi	sp,sp,-144
ffffffffc020a2fa:	e506                	sd	ra,136(sp)
ffffffffc020a2fc:	e122                	sd	s0,128(sp)
ffffffffc020a2fe:	fca6                	sd	s1,120(sp)
ffffffffc020a300:	f8ca                	sd	s2,112(sp)
ffffffffc020a302:	f4ce                	sd	s3,104(sp)
ffffffffc020a304:	f0d2                	sd	s4,96(sp)
ffffffffc020a306:	ecd6                	sd	s5,88(sp)
ffffffffc020a308:	e8da                	sd	s6,80(sp)
ffffffffc020a30a:	e4de                	sd	s7,72(sp)
ffffffffc020a30c:	e0e2                	sd	s8,64(sp)
ffffffffc020a30e:	fc66                	sd	s9,56(sp)
ffffffffc020a310:	f86a                	sd	s10,48(sp)
ffffffffc020a312:	f46e                	sd	s11,40(sp)
ffffffffc020a314:	080007b7          	lui	a5,0x8000
ffffffffc020a318:	16b7e463          	bltu	a5,a1,ffffffffc020a480 <sfs_truncfile+0x188>
ffffffffc020a31c:	06853c83          	ld	s9,104(a0)
ffffffffc020a320:	89aa                	mv	s3,a0
ffffffffc020a322:	160c8163          	beqz	s9,ffffffffc020a484 <sfs_truncfile+0x18c>
ffffffffc020a326:	0b0ca783          	lw	a5,176(s9) # 40b0 <_binary_bin_swap_img_size-0x3c50>
ffffffffc020a32a:	14079d63          	bnez	a5,ffffffffc020a484 <sfs_truncfile+0x18c>
ffffffffc020a32e:	4d38                	lw	a4,88(a0)
ffffffffc020a330:	6405                	lui	s0,0x1
ffffffffc020a332:	23540793          	addi	a5,s0,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a336:	16f71763          	bne	a4,a5,ffffffffc020a4a4 <sfs_truncfile+0x1ac>
ffffffffc020a33a:	00053a83          	ld	s5,0(a0)
ffffffffc020a33e:	147d                	addi	s0,s0,-1
ffffffffc020a340:	942e                	add	s0,s0,a1
ffffffffc020a342:	000ae783          	lwu	a5,0(s5)
ffffffffc020a346:	8031                	srli	s0,s0,0xc
ffffffffc020a348:	8a2e                	mv	s4,a1
ffffffffc020a34a:	2401                	sext.w	s0,s0
ffffffffc020a34c:	02b79763          	bne	a5,a1,ffffffffc020a37a <sfs_truncfile+0x82>
ffffffffc020a350:	008aa783          	lw	a5,8(s5)
ffffffffc020a354:	4901                	li	s2,0
ffffffffc020a356:	18879763          	bne	a5,s0,ffffffffc020a4e4 <sfs_truncfile+0x1ec>
ffffffffc020a35a:	60aa                	ld	ra,136(sp)
ffffffffc020a35c:	640a                	ld	s0,128(sp)
ffffffffc020a35e:	74e6                	ld	s1,120(sp)
ffffffffc020a360:	79a6                	ld	s3,104(sp)
ffffffffc020a362:	7a06                	ld	s4,96(sp)
ffffffffc020a364:	6ae6                	ld	s5,88(sp)
ffffffffc020a366:	6b46                	ld	s6,80(sp)
ffffffffc020a368:	6ba6                	ld	s7,72(sp)
ffffffffc020a36a:	6c06                	ld	s8,64(sp)
ffffffffc020a36c:	7ce2                	ld	s9,56(sp)
ffffffffc020a36e:	7d42                	ld	s10,48(sp)
ffffffffc020a370:	7da2                	ld	s11,40(sp)
ffffffffc020a372:	854a                	mv	a0,s2
ffffffffc020a374:	7946                	ld	s2,112(sp)
ffffffffc020a376:	6149                	addi	sp,sp,144
ffffffffc020a378:	8082                	ret
ffffffffc020a37a:	02050b13          	addi	s6,a0,32
ffffffffc020a37e:	855a                	mv	a0,s6
ffffffffc020a380:	bcafa0ef          	jal	ra,ffffffffc020474a <down>
ffffffffc020a384:	008aa483          	lw	s1,8(s5)
ffffffffc020a388:	0a84e663          	bltu	s1,s0,ffffffffc020a434 <sfs_truncfile+0x13c>
ffffffffc020a38c:	0c947163          	bgeu	s0,s1,ffffffffc020a44e <sfs_truncfile+0x156>
ffffffffc020a390:	4dad                	li	s11,11
ffffffffc020a392:	4b85                	li	s7,1
ffffffffc020a394:	a09d                	j	ffffffffc020a3fa <sfs_truncfile+0x102>
ffffffffc020a396:	ff37091b          	addiw	s2,a4,-13
ffffffffc020a39a:	0009079b          	sext.w	a5,s2
ffffffffc020a39e:	3ff00713          	li	a4,1023
ffffffffc020a3a2:	04f76563          	bltu	a4,a5,ffffffffc020a3ec <sfs_truncfile+0xf4>
ffffffffc020a3a6:	03cd2c03          	lw	s8,60(s10)
ffffffffc020a3aa:	040c0163          	beqz	s8,ffffffffc020a3ec <sfs_truncfile+0xf4>
ffffffffc020a3ae:	004ca783          	lw	a5,4(s9)
ffffffffc020a3b2:	18fc7963          	bgeu	s8,a5,ffffffffc020a544 <sfs_truncfile+0x24c>
ffffffffc020a3b6:	038cb503          	ld	a0,56(s9)
ffffffffc020a3ba:	85e2                	mv	a1,s8
ffffffffc020a3bc:	0eb000ef          	jal	ra,ffffffffc020aca6 <bitmap_test>
ffffffffc020a3c0:	16051263          	bnez	a0,ffffffffc020a524 <sfs_truncfile+0x22c>
ffffffffc020a3c4:	02091793          	slli	a5,s2,0x20
ffffffffc020a3c8:	01e7d713          	srli	a4,a5,0x1e
ffffffffc020a3cc:	86e2                	mv	a3,s8
ffffffffc020a3ce:	4611                	li	a2,4
ffffffffc020a3d0:	082c                	addi	a1,sp,24
ffffffffc020a3d2:	8566                	mv	a0,s9
ffffffffc020a3d4:	e43a                	sd	a4,8(sp)
ffffffffc020a3d6:	ce02                	sw	zero,28(sp)
ffffffffc020a3d8:	289000ef          	jal	ra,ffffffffc020ae60 <sfs_rbuf>
ffffffffc020a3dc:	892a                	mv	s2,a0
ffffffffc020a3de:	e141                	bnez	a0,ffffffffc020a45e <sfs_truncfile+0x166>
ffffffffc020a3e0:	47e2                	lw	a5,24(sp)
ffffffffc020a3e2:	6722                	ld	a4,8(sp)
ffffffffc020a3e4:	e3c9                	bnez	a5,ffffffffc020a466 <sfs_truncfile+0x16e>
ffffffffc020a3e6:	008d2603          	lw	a2,8(s10)
ffffffffc020a3ea:	367d                	addiw	a2,a2,-1
ffffffffc020a3ec:	00cd2423          	sw	a2,8(s10)
ffffffffc020a3f0:	0179b823          	sd	s7,16(s3)
ffffffffc020a3f4:	34fd                	addiw	s1,s1,-1
ffffffffc020a3f6:	04940a63          	beq	s0,s1,ffffffffc020a44a <sfs_truncfile+0x152>
ffffffffc020a3fa:	0009bd03          	ld	s10,0(s3)
ffffffffc020a3fe:	008d2703          	lw	a4,8(s10)
ffffffffc020a402:	c369                	beqz	a4,ffffffffc020a4c4 <sfs_truncfile+0x1cc>
ffffffffc020a404:	fff7079b          	addiw	a5,a4,-1
ffffffffc020a408:	0007861b          	sext.w	a2,a5
ffffffffc020a40c:	f8cde5e3          	bltu	s11,a2,ffffffffc020a396 <sfs_truncfile+0x9e>
ffffffffc020a410:	02079713          	slli	a4,a5,0x20
ffffffffc020a414:	01e75793          	srli	a5,a4,0x1e
ffffffffc020a418:	00fd0933          	add	s2,s10,a5
ffffffffc020a41c:	00c92583          	lw	a1,12(s2)
ffffffffc020a420:	d5f1                	beqz	a1,ffffffffc020a3ec <sfs_truncfile+0xf4>
ffffffffc020a422:	8566                	mv	a0,s9
ffffffffc020a424:	c04ff0ef          	jal	ra,ffffffffc0209828 <sfs_block_free>
ffffffffc020a428:	00092623          	sw	zero,12(s2)
ffffffffc020a42c:	008d2603          	lw	a2,8(s10)
ffffffffc020a430:	367d                	addiw	a2,a2,-1
ffffffffc020a432:	bf6d                	j	ffffffffc020a3ec <sfs_truncfile+0xf4>
ffffffffc020a434:	4681                	li	a3,0
ffffffffc020a436:	8626                	mv	a2,s1
ffffffffc020a438:	85ce                	mv	a1,s3
ffffffffc020a43a:	8566                	mv	a0,s9
ffffffffc020a43c:	ea6ff0ef          	jal	ra,ffffffffc0209ae2 <sfs_bmap_load_nolock>
ffffffffc020a440:	892a                	mv	s2,a0
ffffffffc020a442:	ed11                	bnez	a0,ffffffffc020a45e <sfs_truncfile+0x166>
ffffffffc020a444:	2485                	addiw	s1,s1,1
ffffffffc020a446:	fe9417e3          	bne	s0,s1,ffffffffc020a434 <sfs_truncfile+0x13c>
ffffffffc020a44a:	008aa483          	lw	s1,8(s5)
ffffffffc020a44e:	0a941b63          	bne	s0,s1,ffffffffc020a504 <sfs_truncfile+0x20c>
ffffffffc020a452:	014aa023          	sw	s4,0(s5)
ffffffffc020a456:	4785                	li	a5,1
ffffffffc020a458:	00f9b823          	sd	a5,16(s3)
ffffffffc020a45c:	4901                	li	s2,0
ffffffffc020a45e:	855a                	mv	a0,s6
ffffffffc020a460:	ae6fa0ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc020a464:	bddd                	j	ffffffffc020a35a <sfs_truncfile+0x62>
ffffffffc020a466:	86e2                	mv	a3,s8
ffffffffc020a468:	4611                	li	a2,4
ffffffffc020a46a:	086c                	addi	a1,sp,28
ffffffffc020a46c:	8566                	mv	a0,s9
ffffffffc020a46e:	273000ef          	jal	ra,ffffffffc020aee0 <sfs_wbuf>
ffffffffc020a472:	892a                	mv	s2,a0
ffffffffc020a474:	f56d                	bnez	a0,ffffffffc020a45e <sfs_truncfile+0x166>
ffffffffc020a476:	45e2                	lw	a1,24(sp)
ffffffffc020a478:	8566                	mv	a0,s9
ffffffffc020a47a:	baeff0ef          	jal	ra,ffffffffc0209828 <sfs_block_free>
ffffffffc020a47e:	b7a5                	j	ffffffffc020a3e6 <sfs_truncfile+0xee>
ffffffffc020a480:	5975                	li	s2,-3
ffffffffc020a482:	bde1                	j	ffffffffc020a35a <sfs_truncfile+0x62>
ffffffffc020a484:	00005697          	auipc	a3,0x5
ffffffffc020a488:	92468693          	addi	a3,a3,-1756 # ffffffffc020eda8 <dev_node_ops+0xb8>
ffffffffc020a48c:	00001617          	auipc	a2,0x1
ffffffffc020a490:	69c60613          	addi	a2,a2,1692 # ffffffffc020bb28 <commands+0x250>
ffffffffc020a494:	3a900593          	li	a1,937
ffffffffc020a498:	00005517          	auipc	a0,0x5
ffffffffc020a49c:	af050513          	addi	a0,a0,-1296 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020a4a0:	d8ff50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a4a4:	00005697          	auipc	a3,0x5
ffffffffc020a4a8:	aac68693          	addi	a3,a3,-1364 # ffffffffc020ef50 <dev_node_ops+0x260>
ffffffffc020a4ac:	00001617          	auipc	a2,0x1
ffffffffc020a4b0:	67c60613          	addi	a2,a2,1660 # ffffffffc020bb28 <commands+0x250>
ffffffffc020a4b4:	3aa00593          	li	a1,938
ffffffffc020a4b8:	00005517          	auipc	a0,0x5
ffffffffc020a4bc:	ad050513          	addi	a0,a0,-1328 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020a4c0:	d6ff50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a4c4:	00005697          	auipc	a3,0x5
ffffffffc020a4c8:	ce468693          	addi	a3,a3,-796 # ffffffffc020f1a8 <dev_node_ops+0x4b8>
ffffffffc020a4cc:	00001617          	auipc	a2,0x1
ffffffffc020a4d0:	65c60613          	addi	a2,a2,1628 # ffffffffc020bb28 <commands+0x250>
ffffffffc020a4d4:	17b00593          	li	a1,379
ffffffffc020a4d8:	00005517          	auipc	a0,0x5
ffffffffc020a4dc:	ab050513          	addi	a0,a0,-1360 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020a4e0:	d4ff50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a4e4:	00005697          	auipc	a3,0x5
ffffffffc020a4e8:	cac68693          	addi	a3,a3,-852 # ffffffffc020f190 <dev_node_ops+0x4a0>
ffffffffc020a4ec:	00001617          	auipc	a2,0x1
ffffffffc020a4f0:	63c60613          	addi	a2,a2,1596 # ffffffffc020bb28 <commands+0x250>
ffffffffc020a4f4:	3b100593          	li	a1,945
ffffffffc020a4f8:	00005517          	auipc	a0,0x5
ffffffffc020a4fc:	a9050513          	addi	a0,a0,-1392 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020a500:	d2ff50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a504:	00005697          	auipc	a3,0x5
ffffffffc020a508:	cf468693          	addi	a3,a3,-780 # ffffffffc020f1f8 <dev_node_ops+0x508>
ffffffffc020a50c:	00001617          	auipc	a2,0x1
ffffffffc020a510:	61c60613          	addi	a2,a2,1564 # ffffffffc020bb28 <commands+0x250>
ffffffffc020a514:	3ca00593          	li	a1,970
ffffffffc020a518:	00005517          	auipc	a0,0x5
ffffffffc020a51c:	a7050513          	addi	a0,a0,-1424 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020a520:	d0ff50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a524:	00005697          	auipc	a3,0x5
ffffffffc020a528:	c9c68693          	addi	a3,a3,-868 # ffffffffc020f1c0 <dev_node_ops+0x4d0>
ffffffffc020a52c:	00001617          	auipc	a2,0x1
ffffffffc020a530:	5fc60613          	addi	a2,a2,1532 # ffffffffc020bb28 <commands+0x250>
ffffffffc020a534:	12b00593          	li	a1,299
ffffffffc020a538:	00005517          	auipc	a0,0x5
ffffffffc020a53c:	a5050513          	addi	a0,a0,-1456 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020a540:	ceff50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a544:	8762                	mv	a4,s8
ffffffffc020a546:	86be                	mv	a3,a5
ffffffffc020a548:	00005617          	auipc	a2,0x5
ffffffffc020a54c:	a7060613          	addi	a2,a2,-1424 # ffffffffc020efb8 <dev_node_ops+0x2c8>
ffffffffc020a550:	05300593          	li	a1,83
ffffffffc020a554:	00005517          	auipc	a0,0x5
ffffffffc020a558:	a3450513          	addi	a0,a0,-1484 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020a55c:	cd3f50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020a560 <sfs_load_inode>:
ffffffffc020a560:	7139                	addi	sp,sp,-64
ffffffffc020a562:	fc06                	sd	ra,56(sp)
ffffffffc020a564:	f822                	sd	s0,48(sp)
ffffffffc020a566:	f426                	sd	s1,40(sp)
ffffffffc020a568:	f04a                	sd	s2,32(sp)
ffffffffc020a56a:	84b2                	mv	s1,a2
ffffffffc020a56c:	892a                	mv	s2,a0
ffffffffc020a56e:	ec4e                	sd	s3,24(sp)
ffffffffc020a570:	e852                	sd	s4,16(sp)
ffffffffc020a572:	89ae                	mv	s3,a1
ffffffffc020a574:	e456                	sd	s5,8(sp)
ffffffffc020a576:	a57fe0ef          	jal	ra,ffffffffc0208fcc <lock_sfs_fs>
ffffffffc020a57a:	45a9                	li	a1,10
ffffffffc020a57c:	8526                	mv	a0,s1
ffffffffc020a57e:	0a893403          	ld	s0,168(s2)
ffffffffc020a582:	096010ef          	jal	ra,ffffffffc020b618 <hash32>
ffffffffc020a586:	02051793          	slli	a5,a0,0x20
ffffffffc020a58a:	01c7d713          	srli	a4,a5,0x1c
ffffffffc020a58e:	9722                	add	a4,a4,s0
ffffffffc020a590:	843a                	mv	s0,a4
ffffffffc020a592:	a029                	j	ffffffffc020a59c <sfs_load_inode+0x3c>
ffffffffc020a594:	fc042783          	lw	a5,-64(s0)
ffffffffc020a598:	10978863          	beq	a5,s1,ffffffffc020a6a8 <sfs_load_inode+0x148>
ffffffffc020a59c:	6400                	ld	s0,8(s0)
ffffffffc020a59e:	fe871be3          	bne	a4,s0,ffffffffc020a594 <sfs_load_inode+0x34>
ffffffffc020a5a2:	04000513          	li	a0,64
ffffffffc020a5a6:	a1cf90ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc020a5aa:	8aaa                	mv	s5,a0
ffffffffc020a5ac:	16050563          	beqz	a0,ffffffffc020a716 <sfs_load_inode+0x1b6>
ffffffffc020a5b0:	00492683          	lw	a3,4(s2)
ffffffffc020a5b4:	18048363          	beqz	s1,ffffffffc020a73a <sfs_load_inode+0x1da>
ffffffffc020a5b8:	18d4f163          	bgeu	s1,a3,ffffffffc020a73a <sfs_load_inode+0x1da>
ffffffffc020a5bc:	03893503          	ld	a0,56(s2)
ffffffffc020a5c0:	85a6                	mv	a1,s1
ffffffffc020a5c2:	6e4000ef          	jal	ra,ffffffffc020aca6 <bitmap_test>
ffffffffc020a5c6:	18051763          	bnez	a0,ffffffffc020a754 <sfs_load_inode+0x1f4>
ffffffffc020a5ca:	4701                	li	a4,0
ffffffffc020a5cc:	86a6                	mv	a3,s1
ffffffffc020a5ce:	04000613          	li	a2,64
ffffffffc020a5d2:	85d6                	mv	a1,s5
ffffffffc020a5d4:	854a                	mv	a0,s2
ffffffffc020a5d6:	08b000ef          	jal	ra,ffffffffc020ae60 <sfs_rbuf>
ffffffffc020a5da:	842a                	mv	s0,a0
ffffffffc020a5dc:	0e051563          	bnez	a0,ffffffffc020a6c6 <sfs_load_inode+0x166>
ffffffffc020a5e0:	006ad783          	lhu	a5,6(s5)
ffffffffc020a5e4:	12078b63          	beqz	a5,ffffffffc020a71a <sfs_load_inode+0x1ba>
ffffffffc020a5e8:	6405                	lui	s0,0x1
ffffffffc020a5ea:	23540513          	addi	a0,s0,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a5ee:	abdfd0ef          	jal	ra,ffffffffc02080aa <__alloc_inode>
ffffffffc020a5f2:	8a2a                	mv	s4,a0
ffffffffc020a5f4:	c961                	beqz	a0,ffffffffc020a6c4 <sfs_load_inode+0x164>
ffffffffc020a5f6:	004ad683          	lhu	a3,4(s5)
ffffffffc020a5fa:	4785                	li	a5,1
ffffffffc020a5fc:	0cf69c63          	bne	a3,a5,ffffffffc020a6d4 <sfs_load_inode+0x174>
ffffffffc020a600:	864a                	mv	a2,s2
ffffffffc020a602:	00005597          	auipc	a1,0x5
ffffffffc020a606:	d0658593          	addi	a1,a1,-762 # ffffffffc020f308 <sfs_node_fileops>
ffffffffc020a60a:	abdfd0ef          	jal	ra,ffffffffc02080c6 <inode_init>
ffffffffc020a60e:	058a2783          	lw	a5,88(s4)
ffffffffc020a612:	23540413          	addi	s0,s0,565
ffffffffc020a616:	0e879063          	bne	a5,s0,ffffffffc020a6f6 <sfs_load_inode+0x196>
ffffffffc020a61a:	4785                	li	a5,1
ffffffffc020a61c:	00fa2c23          	sw	a5,24(s4)
ffffffffc020a620:	015a3023          	sd	s5,0(s4)
ffffffffc020a624:	009a2423          	sw	s1,8(s4)
ffffffffc020a628:	000a3823          	sd	zero,16(s4)
ffffffffc020a62c:	4585                	li	a1,1
ffffffffc020a62e:	020a0513          	addi	a0,s4,32
ffffffffc020a632:	90cfa0ef          	jal	ra,ffffffffc020473e <sem_init>
ffffffffc020a636:	058a2703          	lw	a4,88(s4)
ffffffffc020a63a:	6785                	lui	a5,0x1
ffffffffc020a63c:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a640:	14f71663          	bne	a4,a5,ffffffffc020a78c <sfs_load_inode+0x22c>
ffffffffc020a644:	0a093703          	ld	a4,160(s2)
ffffffffc020a648:	038a0793          	addi	a5,s4,56
ffffffffc020a64c:	008a2503          	lw	a0,8(s4)
ffffffffc020a650:	e31c                	sd	a5,0(a4)
ffffffffc020a652:	0af93023          	sd	a5,160(s2)
ffffffffc020a656:	09890793          	addi	a5,s2,152
ffffffffc020a65a:	0a893403          	ld	s0,168(s2)
ffffffffc020a65e:	45a9                	li	a1,10
ffffffffc020a660:	04ea3023          	sd	a4,64(s4)
ffffffffc020a664:	02fa3c23          	sd	a5,56(s4)
ffffffffc020a668:	7b1000ef          	jal	ra,ffffffffc020b618 <hash32>
ffffffffc020a66c:	02051713          	slli	a4,a0,0x20
ffffffffc020a670:	01c75793          	srli	a5,a4,0x1c
ffffffffc020a674:	97a2                	add	a5,a5,s0
ffffffffc020a676:	6798                	ld	a4,8(a5)
ffffffffc020a678:	048a0693          	addi	a3,s4,72
ffffffffc020a67c:	e314                	sd	a3,0(a4)
ffffffffc020a67e:	e794                	sd	a3,8(a5)
ffffffffc020a680:	04ea3823          	sd	a4,80(s4)
ffffffffc020a684:	04fa3423          	sd	a5,72(s4)
ffffffffc020a688:	854a                	mv	a0,s2
ffffffffc020a68a:	953fe0ef          	jal	ra,ffffffffc0208fdc <unlock_sfs_fs>
ffffffffc020a68e:	4401                	li	s0,0
ffffffffc020a690:	0149b023          	sd	s4,0(s3)
ffffffffc020a694:	70e2                	ld	ra,56(sp)
ffffffffc020a696:	8522                	mv	a0,s0
ffffffffc020a698:	7442                	ld	s0,48(sp)
ffffffffc020a69a:	74a2                	ld	s1,40(sp)
ffffffffc020a69c:	7902                	ld	s2,32(sp)
ffffffffc020a69e:	69e2                	ld	s3,24(sp)
ffffffffc020a6a0:	6a42                	ld	s4,16(sp)
ffffffffc020a6a2:	6aa2                	ld	s5,8(sp)
ffffffffc020a6a4:	6121                	addi	sp,sp,64
ffffffffc020a6a6:	8082                	ret
ffffffffc020a6a8:	fb840a13          	addi	s4,s0,-72
ffffffffc020a6ac:	8552                	mv	a0,s4
ffffffffc020a6ae:	a7bfd0ef          	jal	ra,ffffffffc0208128 <inode_ref_inc>
ffffffffc020a6b2:	4785                	li	a5,1
ffffffffc020a6b4:	fcf51ae3          	bne	a0,a5,ffffffffc020a688 <sfs_load_inode+0x128>
ffffffffc020a6b8:	fd042783          	lw	a5,-48(s0)
ffffffffc020a6bc:	2785                	addiw	a5,a5,1
ffffffffc020a6be:	fcf42823          	sw	a5,-48(s0)
ffffffffc020a6c2:	b7d9                	j	ffffffffc020a688 <sfs_load_inode+0x128>
ffffffffc020a6c4:	5471                	li	s0,-4
ffffffffc020a6c6:	8556                	mv	a0,s5
ffffffffc020a6c8:	9aaf90ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc020a6cc:	854a                	mv	a0,s2
ffffffffc020a6ce:	90ffe0ef          	jal	ra,ffffffffc0208fdc <unlock_sfs_fs>
ffffffffc020a6d2:	b7c9                	j	ffffffffc020a694 <sfs_load_inode+0x134>
ffffffffc020a6d4:	4789                	li	a5,2
ffffffffc020a6d6:	08f69f63          	bne	a3,a5,ffffffffc020a774 <sfs_load_inode+0x214>
ffffffffc020a6da:	864a                	mv	a2,s2
ffffffffc020a6dc:	00005597          	auipc	a1,0x5
ffffffffc020a6e0:	bac58593          	addi	a1,a1,-1108 # ffffffffc020f288 <sfs_node_dirops>
ffffffffc020a6e4:	9e3fd0ef          	jal	ra,ffffffffc02080c6 <inode_init>
ffffffffc020a6e8:	058a2703          	lw	a4,88(s4)
ffffffffc020a6ec:	6785                	lui	a5,0x1
ffffffffc020a6ee:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a6f2:	f2f704e3          	beq	a4,a5,ffffffffc020a61a <sfs_load_inode+0xba>
ffffffffc020a6f6:	00005697          	auipc	a3,0x5
ffffffffc020a6fa:	85a68693          	addi	a3,a3,-1958 # ffffffffc020ef50 <dev_node_ops+0x260>
ffffffffc020a6fe:	00001617          	auipc	a2,0x1
ffffffffc020a702:	42a60613          	addi	a2,a2,1066 # ffffffffc020bb28 <commands+0x250>
ffffffffc020a706:	07700593          	li	a1,119
ffffffffc020a70a:	00005517          	auipc	a0,0x5
ffffffffc020a70e:	87e50513          	addi	a0,a0,-1922 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020a712:	b1df50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a716:	5471                	li	s0,-4
ffffffffc020a718:	bf55                	j	ffffffffc020a6cc <sfs_load_inode+0x16c>
ffffffffc020a71a:	00005697          	auipc	a3,0x5
ffffffffc020a71e:	af668693          	addi	a3,a3,-1290 # ffffffffc020f210 <dev_node_ops+0x520>
ffffffffc020a722:	00001617          	auipc	a2,0x1
ffffffffc020a726:	40660613          	addi	a2,a2,1030 # ffffffffc020bb28 <commands+0x250>
ffffffffc020a72a:	0ad00593          	li	a1,173
ffffffffc020a72e:	00005517          	auipc	a0,0x5
ffffffffc020a732:	85a50513          	addi	a0,a0,-1958 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020a736:	af9f50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a73a:	8726                	mv	a4,s1
ffffffffc020a73c:	00005617          	auipc	a2,0x5
ffffffffc020a740:	87c60613          	addi	a2,a2,-1924 # ffffffffc020efb8 <dev_node_ops+0x2c8>
ffffffffc020a744:	05300593          	li	a1,83
ffffffffc020a748:	00005517          	auipc	a0,0x5
ffffffffc020a74c:	84050513          	addi	a0,a0,-1984 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020a750:	adff50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a754:	00005697          	auipc	a3,0x5
ffffffffc020a758:	89c68693          	addi	a3,a3,-1892 # ffffffffc020eff0 <dev_node_ops+0x300>
ffffffffc020a75c:	00001617          	auipc	a2,0x1
ffffffffc020a760:	3cc60613          	addi	a2,a2,972 # ffffffffc020bb28 <commands+0x250>
ffffffffc020a764:	0a800593          	li	a1,168
ffffffffc020a768:	00005517          	auipc	a0,0x5
ffffffffc020a76c:	82050513          	addi	a0,a0,-2016 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020a770:	abff50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a774:	00005617          	auipc	a2,0x5
ffffffffc020a778:	82c60613          	addi	a2,a2,-2004 # ffffffffc020efa0 <dev_node_ops+0x2b0>
ffffffffc020a77c:	02e00593          	li	a1,46
ffffffffc020a780:	00005517          	auipc	a0,0x5
ffffffffc020a784:	80850513          	addi	a0,a0,-2040 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020a788:	aa7f50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a78c:	00004697          	auipc	a3,0x4
ffffffffc020a790:	7c468693          	addi	a3,a3,1988 # ffffffffc020ef50 <dev_node_ops+0x260>
ffffffffc020a794:	00001617          	auipc	a2,0x1
ffffffffc020a798:	39460613          	addi	a2,a2,916 # ffffffffc020bb28 <commands+0x250>
ffffffffc020a79c:	0b100593          	li	a1,177
ffffffffc020a7a0:	00004517          	auipc	a0,0x4
ffffffffc020a7a4:	7e850513          	addi	a0,a0,2024 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020a7a8:	a87f50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020a7ac <sfs_lookup>:
ffffffffc020a7ac:	7139                	addi	sp,sp,-64
ffffffffc020a7ae:	ec4e                	sd	s3,24(sp)
ffffffffc020a7b0:	06853983          	ld	s3,104(a0)
ffffffffc020a7b4:	fc06                	sd	ra,56(sp)
ffffffffc020a7b6:	f822                	sd	s0,48(sp)
ffffffffc020a7b8:	f426                	sd	s1,40(sp)
ffffffffc020a7ba:	f04a                	sd	s2,32(sp)
ffffffffc020a7bc:	e852                	sd	s4,16(sp)
ffffffffc020a7be:	0a098c63          	beqz	s3,ffffffffc020a876 <sfs_lookup+0xca>
ffffffffc020a7c2:	0b09a783          	lw	a5,176(s3)
ffffffffc020a7c6:	ebc5                	bnez	a5,ffffffffc020a876 <sfs_lookup+0xca>
ffffffffc020a7c8:	0005c783          	lbu	a5,0(a1)
ffffffffc020a7cc:	84ae                	mv	s1,a1
ffffffffc020a7ce:	c7c1                	beqz	a5,ffffffffc020a856 <sfs_lookup+0xaa>
ffffffffc020a7d0:	02f00713          	li	a4,47
ffffffffc020a7d4:	08e78163          	beq	a5,a4,ffffffffc020a856 <sfs_lookup+0xaa>
ffffffffc020a7d8:	842a                	mv	s0,a0
ffffffffc020a7da:	8a32                	mv	s4,a2
ffffffffc020a7dc:	94dfd0ef          	jal	ra,ffffffffc0208128 <inode_ref_inc>
ffffffffc020a7e0:	4c38                	lw	a4,88(s0)
ffffffffc020a7e2:	6785                	lui	a5,0x1
ffffffffc020a7e4:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a7e8:	0af71763          	bne	a4,a5,ffffffffc020a896 <sfs_lookup+0xea>
ffffffffc020a7ec:	6018                	ld	a4,0(s0)
ffffffffc020a7ee:	4789                	li	a5,2
ffffffffc020a7f0:	00475703          	lhu	a4,4(a4)
ffffffffc020a7f4:	04f71c63          	bne	a4,a5,ffffffffc020a84c <sfs_lookup+0xa0>
ffffffffc020a7f8:	02040913          	addi	s2,s0,32
ffffffffc020a7fc:	854a                	mv	a0,s2
ffffffffc020a7fe:	f4df90ef          	jal	ra,ffffffffc020474a <down>
ffffffffc020a802:	8626                	mv	a2,s1
ffffffffc020a804:	0054                	addi	a3,sp,4
ffffffffc020a806:	85a2                	mv	a1,s0
ffffffffc020a808:	854e                	mv	a0,s3
ffffffffc020a80a:	a29ff0ef          	jal	ra,ffffffffc020a232 <sfs_dirent_search_nolock.constprop.0>
ffffffffc020a80e:	84aa                	mv	s1,a0
ffffffffc020a810:	854a                	mv	a0,s2
ffffffffc020a812:	f35f90ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc020a816:	cc89                	beqz	s1,ffffffffc020a830 <sfs_lookup+0x84>
ffffffffc020a818:	8522                	mv	a0,s0
ffffffffc020a81a:	9ddfd0ef          	jal	ra,ffffffffc02081f6 <inode_ref_dec>
ffffffffc020a81e:	70e2                	ld	ra,56(sp)
ffffffffc020a820:	7442                	ld	s0,48(sp)
ffffffffc020a822:	7902                	ld	s2,32(sp)
ffffffffc020a824:	69e2                	ld	s3,24(sp)
ffffffffc020a826:	6a42                	ld	s4,16(sp)
ffffffffc020a828:	8526                	mv	a0,s1
ffffffffc020a82a:	74a2                	ld	s1,40(sp)
ffffffffc020a82c:	6121                	addi	sp,sp,64
ffffffffc020a82e:	8082                	ret
ffffffffc020a830:	4612                	lw	a2,4(sp)
ffffffffc020a832:	002c                	addi	a1,sp,8
ffffffffc020a834:	854e                	mv	a0,s3
ffffffffc020a836:	d2bff0ef          	jal	ra,ffffffffc020a560 <sfs_load_inode>
ffffffffc020a83a:	84aa                	mv	s1,a0
ffffffffc020a83c:	8522                	mv	a0,s0
ffffffffc020a83e:	9b9fd0ef          	jal	ra,ffffffffc02081f6 <inode_ref_dec>
ffffffffc020a842:	fcf1                	bnez	s1,ffffffffc020a81e <sfs_lookup+0x72>
ffffffffc020a844:	67a2                	ld	a5,8(sp)
ffffffffc020a846:	00fa3023          	sd	a5,0(s4)
ffffffffc020a84a:	bfd1                	j	ffffffffc020a81e <sfs_lookup+0x72>
ffffffffc020a84c:	8522                	mv	a0,s0
ffffffffc020a84e:	9a9fd0ef          	jal	ra,ffffffffc02081f6 <inode_ref_dec>
ffffffffc020a852:	54b9                	li	s1,-18
ffffffffc020a854:	b7e9                	j	ffffffffc020a81e <sfs_lookup+0x72>
ffffffffc020a856:	00005697          	auipc	a3,0x5
ffffffffc020a85a:	9d268693          	addi	a3,a3,-1582 # ffffffffc020f228 <dev_node_ops+0x538>
ffffffffc020a85e:	00001617          	auipc	a2,0x1
ffffffffc020a862:	2ca60613          	addi	a2,a2,714 # ffffffffc020bb28 <commands+0x250>
ffffffffc020a866:	3db00593          	li	a1,987
ffffffffc020a86a:	00004517          	auipc	a0,0x4
ffffffffc020a86e:	71e50513          	addi	a0,a0,1822 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020a872:	9bdf50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a876:	00004697          	auipc	a3,0x4
ffffffffc020a87a:	53268693          	addi	a3,a3,1330 # ffffffffc020eda8 <dev_node_ops+0xb8>
ffffffffc020a87e:	00001617          	auipc	a2,0x1
ffffffffc020a882:	2aa60613          	addi	a2,a2,682 # ffffffffc020bb28 <commands+0x250>
ffffffffc020a886:	3da00593          	li	a1,986
ffffffffc020a88a:	00004517          	auipc	a0,0x4
ffffffffc020a88e:	6fe50513          	addi	a0,a0,1790 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020a892:	99df50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a896:	00004697          	auipc	a3,0x4
ffffffffc020a89a:	6ba68693          	addi	a3,a3,1722 # ffffffffc020ef50 <dev_node_ops+0x260>
ffffffffc020a89e:	00001617          	auipc	a2,0x1
ffffffffc020a8a2:	28a60613          	addi	a2,a2,650 # ffffffffc020bb28 <commands+0x250>
ffffffffc020a8a6:	3dd00593          	li	a1,989
ffffffffc020a8aa:	00004517          	auipc	a0,0x4
ffffffffc020a8ae:	6de50513          	addi	a0,a0,1758 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020a8b2:	97df50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020a8b6 <sfs_namefile>:
ffffffffc020a8b6:	6d98                	ld	a4,24(a1)
ffffffffc020a8b8:	7175                	addi	sp,sp,-144
ffffffffc020a8ba:	e506                	sd	ra,136(sp)
ffffffffc020a8bc:	e122                	sd	s0,128(sp)
ffffffffc020a8be:	fca6                	sd	s1,120(sp)
ffffffffc020a8c0:	f8ca                	sd	s2,112(sp)
ffffffffc020a8c2:	f4ce                	sd	s3,104(sp)
ffffffffc020a8c4:	f0d2                	sd	s4,96(sp)
ffffffffc020a8c6:	ecd6                	sd	s5,88(sp)
ffffffffc020a8c8:	e8da                	sd	s6,80(sp)
ffffffffc020a8ca:	e4de                	sd	s7,72(sp)
ffffffffc020a8cc:	e0e2                	sd	s8,64(sp)
ffffffffc020a8ce:	fc66                	sd	s9,56(sp)
ffffffffc020a8d0:	f86a                	sd	s10,48(sp)
ffffffffc020a8d2:	f46e                	sd	s11,40(sp)
ffffffffc020a8d4:	e42e                	sd	a1,8(sp)
ffffffffc020a8d6:	4789                	li	a5,2
ffffffffc020a8d8:	1ae7f363          	bgeu	a5,a4,ffffffffc020aa7e <sfs_namefile+0x1c8>
ffffffffc020a8dc:	89aa                	mv	s3,a0
ffffffffc020a8de:	10400513          	li	a0,260
ffffffffc020a8e2:	ee1f80ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc020a8e6:	842a                	mv	s0,a0
ffffffffc020a8e8:	18050b63          	beqz	a0,ffffffffc020aa7e <sfs_namefile+0x1c8>
ffffffffc020a8ec:	0689b483          	ld	s1,104(s3)
ffffffffc020a8f0:	1e048963          	beqz	s1,ffffffffc020aae2 <sfs_namefile+0x22c>
ffffffffc020a8f4:	0b04a783          	lw	a5,176(s1)
ffffffffc020a8f8:	1e079563          	bnez	a5,ffffffffc020aae2 <sfs_namefile+0x22c>
ffffffffc020a8fc:	0589ac83          	lw	s9,88(s3)
ffffffffc020a900:	6785                	lui	a5,0x1
ffffffffc020a902:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a906:	1afc9e63          	bne	s9,a5,ffffffffc020aac2 <sfs_namefile+0x20c>
ffffffffc020a90a:	6722                	ld	a4,8(sp)
ffffffffc020a90c:	854e                	mv	a0,s3
ffffffffc020a90e:	8ace                	mv	s5,s3
ffffffffc020a910:	6f1c                	ld	a5,24(a4)
ffffffffc020a912:	00073b03          	ld	s6,0(a4)
ffffffffc020a916:	02098a13          	addi	s4,s3,32
ffffffffc020a91a:	ffe78b93          	addi	s7,a5,-2
ffffffffc020a91e:	9b3e                	add	s6,s6,a5
ffffffffc020a920:	00005d17          	auipc	s10,0x5
ffffffffc020a924:	928d0d13          	addi	s10,s10,-1752 # ffffffffc020f248 <dev_node_ops+0x558>
ffffffffc020a928:	801fd0ef          	jal	ra,ffffffffc0208128 <inode_ref_inc>
ffffffffc020a92c:	00440c13          	addi	s8,s0,4
ffffffffc020a930:	e066                	sd	s9,0(sp)
ffffffffc020a932:	8552                	mv	a0,s4
ffffffffc020a934:	e17f90ef          	jal	ra,ffffffffc020474a <down>
ffffffffc020a938:	0854                	addi	a3,sp,20
ffffffffc020a93a:	866a                	mv	a2,s10
ffffffffc020a93c:	85d6                	mv	a1,s5
ffffffffc020a93e:	8526                	mv	a0,s1
ffffffffc020a940:	8f3ff0ef          	jal	ra,ffffffffc020a232 <sfs_dirent_search_nolock.constprop.0>
ffffffffc020a944:	8daa                	mv	s11,a0
ffffffffc020a946:	8552                	mv	a0,s4
ffffffffc020a948:	dfff90ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc020a94c:	020d8863          	beqz	s11,ffffffffc020a97c <sfs_namefile+0xc6>
ffffffffc020a950:	854e                	mv	a0,s3
ffffffffc020a952:	8a5fd0ef          	jal	ra,ffffffffc02081f6 <inode_ref_dec>
ffffffffc020a956:	8522                	mv	a0,s0
ffffffffc020a958:	f1bf80ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc020a95c:	60aa                	ld	ra,136(sp)
ffffffffc020a95e:	640a                	ld	s0,128(sp)
ffffffffc020a960:	74e6                	ld	s1,120(sp)
ffffffffc020a962:	7946                	ld	s2,112(sp)
ffffffffc020a964:	79a6                	ld	s3,104(sp)
ffffffffc020a966:	7a06                	ld	s4,96(sp)
ffffffffc020a968:	6ae6                	ld	s5,88(sp)
ffffffffc020a96a:	6b46                	ld	s6,80(sp)
ffffffffc020a96c:	6ba6                	ld	s7,72(sp)
ffffffffc020a96e:	6c06                	ld	s8,64(sp)
ffffffffc020a970:	7ce2                	ld	s9,56(sp)
ffffffffc020a972:	7d42                	ld	s10,48(sp)
ffffffffc020a974:	856e                	mv	a0,s11
ffffffffc020a976:	7da2                	ld	s11,40(sp)
ffffffffc020a978:	6149                	addi	sp,sp,144
ffffffffc020a97a:	8082                	ret
ffffffffc020a97c:	4652                	lw	a2,20(sp)
ffffffffc020a97e:	082c                	addi	a1,sp,24
ffffffffc020a980:	8526                	mv	a0,s1
ffffffffc020a982:	bdfff0ef          	jal	ra,ffffffffc020a560 <sfs_load_inode>
ffffffffc020a986:	8daa                	mv	s11,a0
ffffffffc020a988:	f561                	bnez	a0,ffffffffc020a950 <sfs_namefile+0x9a>
ffffffffc020a98a:	854e                	mv	a0,s3
ffffffffc020a98c:	008aa903          	lw	s2,8(s5)
ffffffffc020a990:	867fd0ef          	jal	ra,ffffffffc02081f6 <inode_ref_dec>
ffffffffc020a994:	6ce2                	ld	s9,24(sp)
ffffffffc020a996:	0b3c8463          	beq	s9,s3,ffffffffc020aa3e <sfs_namefile+0x188>
ffffffffc020a99a:	100c8463          	beqz	s9,ffffffffc020aaa2 <sfs_namefile+0x1ec>
ffffffffc020a99e:	058ca703          	lw	a4,88(s9)
ffffffffc020a9a2:	6782                	ld	a5,0(sp)
ffffffffc020a9a4:	0ef71f63          	bne	a4,a5,ffffffffc020aaa2 <sfs_namefile+0x1ec>
ffffffffc020a9a8:	008ca703          	lw	a4,8(s9)
ffffffffc020a9ac:	8ae6                	mv	s5,s9
ffffffffc020a9ae:	0d270a63          	beq	a4,s2,ffffffffc020aa82 <sfs_namefile+0x1cc>
ffffffffc020a9b2:	000cb703          	ld	a4,0(s9)
ffffffffc020a9b6:	4789                	li	a5,2
ffffffffc020a9b8:	00475703          	lhu	a4,4(a4)
ffffffffc020a9bc:	0cf71363          	bne	a4,a5,ffffffffc020aa82 <sfs_namefile+0x1cc>
ffffffffc020a9c0:	020c8a13          	addi	s4,s9,32
ffffffffc020a9c4:	8552                	mv	a0,s4
ffffffffc020a9c6:	d85f90ef          	jal	ra,ffffffffc020474a <down>
ffffffffc020a9ca:	000cb703          	ld	a4,0(s9)
ffffffffc020a9ce:	00872983          	lw	s3,8(a4)
ffffffffc020a9d2:	01304963          	bgtz	s3,ffffffffc020a9e4 <sfs_namefile+0x12e>
ffffffffc020a9d6:	a899                	j	ffffffffc020aa2c <sfs_namefile+0x176>
ffffffffc020a9d8:	4018                	lw	a4,0(s0)
ffffffffc020a9da:	01270e63          	beq	a4,s2,ffffffffc020a9f6 <sfs_namefile+0x140>
ffffffffc020a9de:	2d85                	addiw	s11,s11,1
ffffffffc020a9e0:	05b98663          	beq	s3,s11,ffffffffc020aa2c <sfs_namefile+0x176>
ffffffffc020a9e4:	86a2                	mv	a3,s0
ffffffffc020a9e6:	866e                	mv	a2,s11
ffffffffc020a9e8:	85e6                	mv	a1,s9
ffffffffc020a9ea:	8526                	mv	a0,s1
ffffffffc020a9ec:	e48ff0ef          	jal	ra,ffffffffc020a034 <sfs_dirent_read_nolock>
ffffffffc020a9f0:	872a                	mv	a4,a0
ffffffffc020a9f2:	d17d                	beqz	a0,ffffffffc020a9d8 <sfs_namefile+0x122>
ffffffffc020a9f4:	a82d                	j	ffffffffc020aa2e <sfs_namefile+0x178>
ffffffffc020a9f6:	8552                	mv	a0,s4
ffffffffc020a9f8:	d4ff90ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc020a9fc:	8562                	mv	a0,s8
ffffffffc020a9fe:	692000ef          	jal	ra,ffffffffc020b090 <strlen>
ffffffffc020aa02:	00150793          	addi	a5,a0,1
ffffffffc020aa06:	862a                	mv	a2,a0
ffffffffc020aa08:	06fbe863          	bltu	s7,a5,ffffffffc020aa78 <sfs_namefile+0x1c2>
ffffffffc020aa0c:	fff64913          	not	s2,a2
ffffffffc020aa10:	995a                	add	s2,s2,s6
ffffffffc020aa12:	85e2                	mv	a1,s8
ffffffffc020aa14:	854a                	mv	a0,s2
ffffffffc020aa16:	40fb8bb3          	sub	s7,s7,a5
ffffffffc020aa1a:	76a000ef          	jal	ra,ffffffffc020b184 <memcpy>
ffffffffc020aa1e:	02f00793          	li	a5,47
ffffffffc020aa22:	fefb0fa3          	sb	a5,-1(s6)
ffffffffc020aa26:	89e6                	mv	s3,s9
ffffffffc020aa28:	8b4a                	mv	s6,s2
ffffffffc020aa2a:	b721                	j	ffffffffc020a932 <sfs_namefile+0x7c>
ffffffffc020aa2c:	5741                	li	a4,-16
ffffffffc020aa2e:	8552                	mv	a0,s4
ffffffffc020aa30:	e03a                	sd	a4,0(sp)
ffffffffc020aa32:	d15f90ef          	jal	ra,ffffffffc0204746 <up>
ffffffffc020aa36:	6702                	ld	a4,0(sp)
ffffffffc020aa38:	89e6                	mv	s3,s9
ffffffffc020aa3a:	8dba                	mv	s11,a4
ffffffffc020aa3c:	bf11                	j	ffffffffc020a950 <sfs_namefile+0x9a>
ffffffffc020aa3e:	854e                	mv	a0,s3
ffffffffc020aa40:	fb6fd0ef          	jal	ra,ffffffffc02081f6 <inode_ref_dec>
ffffffffc020aa44:	64a2                	ld	s1,8(sp)
ffffffffc020aa46:	85da                	mv	a1,s6
ffffffffc020aa48:	6c98                	ld	a4,24(s1)
ffffffffc020aa4a:	6088                	ld	a0,0(s1)
ffffffffc020aa4c:	1779                	addi	a4,a4,-2
ffffffffc020aa4e:	41770bb3          	sub	s7,a4,s7
ffffffffc020aa52:	865e                	mv	a2,s7
ffffffffc020aa54:	0505                	addi	a0,a0,1
ffffffffc020aa56:	6ee000ef          	jal	ra,ffffffffc020b144 <memmove>
ffffffffc020aa5a:	02f00713          	li	a4,47
ffffffffc020aa5e:	fee50fa3          	sb	a4,-1(a0)
ffffffffc020aa62:	955e                	add	a0,a0,s7
ffffffffc020aa64:	00050023          	sb	zero,0(a0)
ffffffffc020aa68:	85de                	mv	a1,s7
ffffffffc020aa6a:	8526                	mv	a0,s1
ffffffffc020aa6c:	d37fa0ef          	jal	ra,ffffffffc02057a2 <iobuf_skip>
ffffffffc020aa70:	8522                	mv	a0,s0
ffffffffc020aa72:	e01f80ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc020aa76:	b5dd                	j	ffffffffc020a95c <sfs_namefile+0xa6>
ffffffffc020aa78:	89e6                	mv	s3,s9
ffffffffc020aa7a:	5df1                	li	s11,-4
ffffffffc020aa7c:	bdd1                	j	ffffffffc020a950 <sfs_namefile+0x9a>
ffffffffc020aa7e:	5df1                	li	s11,-4
ffffffffc020aa80:	bdf1                	j	ffffffffc020a95c <sfs_namefile+0xa6>
ffffffffc020aa82:	00004697          	auipc	a3,0x4
ffffffffc020aa86:	7ce68693          	addi	a3,a3,1998 # ffffffffc020f250 <dev_node_ops+0x560>
ffffffffc020aa8a:	00001617          	auipc	a2,0x1
ffffffffc020aa8e:	09e60613          	addi	a2,a2,158 # ffffffffc020bb28 <commands+0x250>
ffffffffc020aa92:	2f900593          	li	a1,761
ffffffffc020aa96:	00004517          	auipc	a0,0x4
ffffffffc020aa9a:	4f250513          	addi	a0,a0,1266 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020aa9e:	f90f50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020aaa2:	00004697          	auipc	a3,0x4
ffffffffc020aaa6:	4ae68693          	addi	a3,a3,1198 # ffffffffc020ef50 <dev_node_ops+0x260>
ffffffffc020aaaa:	00001617          	auipc	a2,0x1
ffffffffc020aaae:	07e60613          	addi	a2,a2,126 # ffffffffc020bb28 <commands+0x250>
ffffffffc020aab2:	2f800593          	li	a1,760
ffffffffc020aab6:	00004517          	auipc	a0,0x4
ffffffffc020aaba:	4d250513          	addi	a0,a0,1234 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020aabe:	f70f50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020aac2:	00004697          	auipc	a3,0x4
ffffffffc020aac6:	48e68693          	addi	a3,a3,1166 # ffffffffc020ef50 <dev_node_ops+0x260>
ffffffffc020aaca:	00001617          	auipc	a2,0x1
ffffffffc020aace:	05e60613          	addi	a2,a2,94 # ffffffffc020bb28 <commands+0x250>
ffffffffc020aad2:	2e500593          	li	a1,741
ffffffffc020aad6:	00004517          	auipc	a0,0x4
ffffffffc020aada:	4b250513          	addi	a0,a0,1202 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020aade:	f50f50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020aae2:	00004697          	auipc	a3,0x4
ffffffffc020aae6:	2c668693          	addi	a3,a3,710 # ffffffffc020eda8 <dev_node_ops+0xb8>
ffffffffc020aaea:	00001617          	auipc	a2,0x1
ffffffffc020aaee:	03e60613          	addi	a2,a2,62 # ffffffffc020bb28 <commands+0x250>
ffffffffc020aaf2:	2e400593          	li	a1,740
ffffffffc020aaf6:	00004517          	auipc	a0,0x4
ffffffffc020aafa:	49250513          	addi	a0,a0,1170 # ffffffffc020ef88 <dev_node_ops+0x298>
ffffffffc020aafe:	f30f50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020ab02 <bitmap_translate.part.0>:
ffffffffc020ab02:	1141                	addi	sp,sp,-16
ffffffffc020ab04:	00005697          	auipc	a3,0x5
ffffffffc020ab08:	88468693          	addi	a3,a3,-1916 # ffffffffc020f388 <sfs_node_fileops+0x80>
ffffffffc020ab0c:	00001617          	auipc	a2,0x1
ffffffffc020ab10:	01c60613          	addi	a2,a2,28 # ffffffffc020bb28 <commands+0x250>
ffffffffc020ab14:	04c00593          	li	a1,76
ffffffffc020ab18:	00005517          	auipc	a0,0x5
ffffffffc020ab1c:	88850513          	addi	a0,a0,-1912 # ffffffffc020f3a0 <sfs_node_fileops+0x98>
ffffffffc020ab20:	e406                	sd	ra,8(sp)
ffffffffc020ab22:	f0cf50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020ab26 <bitmap_create>:
ffffffffc020ab26:	7139                	addi	sp,sp,-64
ffffffffc020ab28:	fc06                	sd	ra,56(sp)
ffffffffc020ab2a:	f822                	sd	s0,48(sp)
ffffffffc020ab2c:	f426                	sd	s1,40(sp)
ffffffffc020ab2e:	f04a                	sd	s2,32(sp)
ffffffffc020ab30:	ec4e                	sd	s3,24(sp)
ffffffffc020ab32:	e852                	sd	s4,16(sp)
ffffffffc020ab34:	e456                	sd	s5,8(sp)
ffffffffc020ab36:	c14d                	beqz	a0,ffffffffc020abd8 <bitmap_create+0xb2>
ffffffffc020ab38:	842a                	mv	s0,a0
ffffffffc020ab3a:	4541                	li	a0,16
ffffffffc020ab3c:	c87f80ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc020ab40:	84aa                	mv	s1,a0
ffffffffc020ab42:	cd25                	beqz	a0,ffffffffc020abba <bitmap_create+0x94>
ffffffffc020ab44:	02041a13          	slli	s4,s0,0x20
ffffffffc020ab48:	020a5a13          	srli	s4,s4,0x20
ffffffffc020ab4c:	01fa0793          	addi	a5,s4,31
ffffffffc020ab50:	0057d993          	srli	s3,a5,0x5
ffffffffc020ab54:	00299a93          	slli	s5,s3,0x2
ffffffffc020ab58:	8556                	mv	a0,s5
ffffffffc020ab5a:	894e                	mv	s2,s3
ffffffffc020ab5c:	c67f80ef          	jal	ra,ffffffffc02037c2 <kmalloc>
ffffffffc020ab60:	c53d                	beqz	a0,ffffffffc020abce <bitmap_create+0xa8>
ffffffffc020ab62:	0134a223          	sw	s3,4(s1)
ffffffffc020ab66:	c080                	sw	s0,0(s1)
ffffffffc020ab68:	8656                	mv	a2,s5
ffffffffc020ab6a:	0ff00593          	li	a1,255
ffffffffc020ab6e:	5c4000ef          	jal	ra,ffffffffc020b132 <memset>
ffffffffc020ab72:	e488                	sd	a0,8(s1)
ffffffffc020ab74:	0996                	slli	s3,s3,0x5
ffffffffc020ab76:	053a0263          	beq	s4,s3,ffffffffc020abba <bitmap_create+0x94>
ffffffffc020ab7a:	fff9079b          	addiw	a5,s2,-1
ffffffffc020ab7e:	0057969b          	slliw	a3,a5,0x5
ffffffffc020ab82:	0054561b          	srliw	a2,s0,0x5
ffffffffc020ab86:	40d4073b          	subw	a4,s0,a3
ffffffffc020ab8a:	0054541b          	srliw	s0,s0,0x5
ffffffffc020ab8e:	08f61463          	bne	a2,a5,ffffffffc020ac16 <bitmap_create+0xf0>
ffffffffc020ab92:	fff7069b          	addiw	a3,a4,-1
ffffffffc020ab96:	47f9                	li	a5,30
ffffffffc020ab98:	04d7ef63          	bltu	a5,a3,ffffffffc020abf6 <bitmap_create+0xd0>
ffffffffc020ab9c:	1402                	slli	s0,s0,0x20
ffffffffc020ab9e:	8079                	srli	s0,s0,0x1e
ffffffffc020aba0:	9522                	add	a0,a0,s0
ffffffffc020aba2:	411c                	lw	a5,0(a0)
ffffffffc020aba4:	4585                	li	a1,1
ffffffffc020aba6:	02000613          	li	a2,32
ffffffffc020abaa:	00e596bb          	sllw	a3,a1,a4
ffffffffc020abae:	8fb5                	xor	a5,a5,a3
ffffffffc020abb0:	2705                	addiw	a4,a4,1
ffffffffc020abb2:	2781                	sext.w	a5,a5
ffffffffc020abb4:	fec71be3          	bne	a4,a2,ffffffffc020abaa <bitmap_create+0x84>
ffffffffc020abb8:	c11c                	sw	a5,0(a0)
ffffffffc020abba:	70e2                	ld	ra,56(sp)
ffffffffc020abbc:	7442                	ld	s0,48(sp)
ffffffffc020abbe:	7902                	ld	s2,32(sp)
ffffffffc020abc0:	69e2                	ld	s3,24(sp)
ffffffffc020abc2:	6a42                	ld	s4,16(sp)
ffffffffc020abc4:	6aa2                	ld	s5,8(sp)
ffffffffc020abc6:	8526                	mv	a0,s1
ffffffffc020abc8:	74a2                	ld	s1,40(sp)
ffffffffc020abca:	6121                	addi	sp,sp,64
ffffffffc020abcc:	8082                	ret
ffffffffc020abce:	8526                	mv	a0,s1
ffffffffc020abd0:	ca3f80ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc020abd4:	4481                	li	s1,0
ffffffffc020abd6:	b7d5                	j	ffffffffc020abba <bitmap_create+0x94>
ffffffffc020abd8:	00004697          	auipc	a3,0x4
ffffffffc020abdc:	7e068693          	addi	a3,a3,2016 # ffffffffc020f3b8 <sfs_node_fileops+0xb0>
ffffffffc020abe0:	00001617          	auipc	a2,0x1
ffffffffc020abe4:	f4860613          	addi	a2,a2,-184 # ffffffffc020bb28 <commands+0x250>
ffffffffc020abe8:	45d5                	li	a1,21
ffffffffc020abea:	00004517          	auipc	a0,0x4
ffffffffc020abee:	7b650513          	addi	a0,a0,1974 # ffffffffc020f3a0 <sfs_node_fileops+0x98>
ffffffffc020abf2:	e3cf50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020abf6:	00005697          	auipc	a3,0x5
ffffffffc020abfa:	80268693          	addi	a3,a3,-2046 # ffffffffc020f3f8 <sfs_node_fileops+0xf0>
ffffffffc020abfe:	00001617          	auipc	a2,0x1
ffffffffc020ac02:	f2a60613          	addi	a2,a2,-214 # ffffffffc020bb28 <commands+0x250>
ffffffffc020ac06:	02b00593          	li	a1,43
ffffffffc020ac0a:	00004517          	auipc	a0,0x4
ffffffffc020ac0e:	79650513          	addi	a0,a0,1942 # ffffffffc020f3a0 <sfs_node_fileops+0x98>
ffffffffc020ac12:	e1cf50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020ac16:	00004697          	auipc	a3,0x4
ffffffffc020ac1a:	7ca68693          	addi	a3,a3,1994 # ffffffffc020f3e0 <sfs_node_fileops+0xd8>
ffffffffc020ac1e:	00001617          	auipc	a2,0x1
ffffffffc020ac22:	f0a60613          	addi	a2,a2,-246 # ffffffffc020bb28 <commands+0x250>
ffffffffc020ac26:	02a00593          	li	a1,42
ffffffffc020ac2a:	00004517          	auipc	a0,0x4
ffffffffc020ac2e:	77650513          	addi	a0,a0,1910 # ffffffffc020f3a0 <sfs_node_fileops+0x98>
ffffffffc020ac32:	dfcf50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020ac36 <bitmap_alloc>:
ffffffffc020ac36:	4150                	lw	a2,4(a0)
ffffffffc020ac38:	651c                	ld	a5,8(a0)
ffffffffc020ac3a:	c231                	beqz	a2,ffffffffc020ac7e <bitmap_alloc+0x48>
ffffffffc020ac3c:	4701                	li	a4,0
ffffffffc020ac3e:	a029                	j	ffffffffc020ac48 <bitmap_alloc+0x12>
ffffffffc020ac40:	2705                	addiw	a4,a4,1
ffffffffc020ac42:	0791                	addi	a5,a5,4
ffffffffc020ac44:	02e60d63          	beq	a2,a4,ffffffffc020ac7e <bitmap_alloc+0x48>
ffffffffc020ac48:	4394                	lw	a3,0(a5)
ffffffffc020ac4a:	dafd                	beqz	a3,ffffffffc020ac40 <bitmap_alloc+0xa>
ffffffffc020ac4c:	4501                	li	a0,0
ffffffffc020ac4e:	4885                	li	a7,1
ffffffffc020ac50:	8e36                	mv	t3,a3
ffffffffc020ac52:	02000313          	li	t1,32
ffffffffc020ac56:	a021                	j	ffffffffc020ac5e <bitmap_alloc+0x28>
ffffffffc020ac58:	2505                	addiw	a0,a0,1
ffffffffc020ac5a:	02650463          	beq	a0,t1,ffffffffc020ac82 <bitmap_alloc+0x4c>
ffffffffc020ac5e:	00a8983b          	sllw	a6,a7,a0
ffffffffc020ac62:	0106f633          	and	a2,a3,a6
ffffffffc020ac66:	2601                	sext.w	a2,a2
ffffffffc020ac68:	da65                	beqz	a2,ffffffffc020ac58 <bitmap_alloc+0x22>
ffffffffc020ac6a:	010e4833          	xor	a6,t3,a6
ffffffffc020ac6e:	0057171b          	slliw	a4,a4,0x5
ffffffffc020ac72:	9f29                	addw	a4,a4,a0
ffffffffc020ac74:	0107a023          	sw	a6,0(a5)
ffffffffc020ac78:	c198                	sw	a4,0(a1)
ffffffffc020ac7a:	4501                	li	a0,0
ffffffffc020ac7c:	8082                	ret
ffffffffc020ac7e:	5571                	li	a0,-4
ffffffffc020ac80:	8082                	ret
ffffffffc020ac82:	1141                	addi	sp,sp,-16
ffffffffc020ac84:	00002697          	auipc	a3,0x2
ffffffffc020ac88:	a5468693          	addi	a3,a3,-1452 # ffffffffc020c6d8 <commands+0xe00>
ffffffffc020ac8c:	00001617          	auipc	a2,0x1
ffffffffc020ac90:	e9c60613          	addi	a2,a2,-356 # ffffffffc020bb28 <commands+0x250>
ffffffffc020ac94:	04300593          	li	a1,67
ffffffffc020ac98:	00004517          	auipc	a0,0x4
ffffffffc020ac9c:	70850513          	addi	a0,a0,1800 # ffffffffc020f3a0 <sfs_node_fileops+0x98>
ffffffffc020aca0:	e406                	sd	ra,8(sp)
ffffffffc020aca2:	d8cf50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020aca6 <bitmap_test>:
ffffffffc020aca6:	411c                	lw	a5,0(a0)
ffffffffc020aca8:	00f5ff63          	bgeu	a1,a5,ffffffffc020acc6 <bitmap_test+0x20>
ffffffffc020acac:	651c                	ld	a5,8(a0)
ffffffffc020acae:	0055d71b          	srliw	a4,a1,0x5
ffffffffc020acb2:	070a                	slli	a4,a4,0x2
ffffffffc020acb4:	97ba                	add	a5,a5,a4
ffffffffc020acb6:	4388                	lw	a0,0(a5)
ffffffffc020acb8:	4785                	li	a5,1
ffffffffc020acba:	00b795bb          	sllw	a1,a5,a1
ffffffffc020acbe:	8d6d                	and	a0,a0,a1
ffffffffc020acc0:	1502                	slli	a0,a0,0x20
ffffffffc020acc2:	9101                	srli	a0,a0,0x20
ffffffffc020acc4:	8082                	ret
ffffffffc020acc6:	1141                	addi	sp,sp,-16
ffffffffc020acc8:	e406                	sd	ra,8(sp)
ffffffffc020acca:	e39ff0ef          	jal	ra,ffffffffc020ab02 <bitmap_translate.part.0>

ffffffffc020acce <bitmap_free>:
ffffffffc020acce:	411c                	lw	a5,0(a0)
ffffffffc020acd0:	1141                	addi	sp,sp,-16
ffffffffc020acd2:	e406                	sd	ra,8(sp)
ffffffffc020acd4:	02f5f463          	bgeu	a1,a5,ffffffffc020acfc <bitmap_free+0x2e>
ffffffffc020acd8:	651c                	ld	a5,8(a0)
ffffffffc020acda:	0055d71b          	srliw	a4,a1,0x5
ffffffffc020acde:	070a                	slli	a4,a4,0x2
ffffffffc020ace0:	97ba                	add	a5,a5,a4
ffffffffc020ace2:	4398                	lw	a4,0(a5)
ffffffffc020ace4:	4685                	li	a3,1
ffffffffc020ace6:	00b695bb          	sllw	a1,a3,a1
ffffffffc020acea:	00b776b3          	and	a3,a4,a1
ffffffffc020acee:	2681                	sext.w	a3,a3
ffffffffc020acf0:	ea81                	bnez	a3,ffffffffc020ad00 <bitmap_free+0x32>
ffffffffc020acf2:	60a2                	ld	ra,8(sp)
ffffffffc020acf4:	8f4d                	or	a4,a4,a1
ffffffffc020acf6:	c398                	sw	a4,0(a5)
ffffffffc020acf8:	0141                	addi	sp,sp,16
ffffffffc020acfa:	8082                	ret
ffffffffc020acfc:	e07ff0ef          	jal	ra,ffffffffc020ab02 <bitmap_translate.part.0>
ffffffffc020ad00:	00004697          	auipc	a3,0x4
ffffffffc020ad04:	72068693          	addi	a3,a3,1824 # ffffffffc020f420 <sfs_node_fileops+0x118>
ffffffffc020ad08:	00001617          	auipc	a2,0x1
ffffffffc020ad0c:	e2060613          	addi	a2,a2,-480 # ffffffffc020bb28 <commands+0x250>
ffffffffc020ad10:	05f00593          	li	a1,95
ffffffffc020ad14:	00004517          	auipc	a0,0x4
ffffffffc020ad18:	68c50513          	addi	a0,a0,1676 # ffffffffc020f3a0 <sfs_node_fileops+0x98>
ffffffffc020ad1c:	d12f50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020ad20 <bitmap_destroy>:
ffffffffc020ad20:	1141                	addi	sp,sp,-16
ffffffffc020ad22:	e022                	sd	s0,0(sp)
ffffffffc020ad24:	842a                	mv	s0,a0
ffffffffc020ad26:	6508                	ld	a0,8(a0)
ffffffffc020ad28:	e406                	sd	ra,8(sp)
ffffffffc020ad2a:	b49f80ef          	jal	ra,ffffffffc0203872 <kfree>
ffffffffc020ad2e:	8522                	mv	a0,s0
ffffffffc020ad30:	6402                	ld	s0,0(sp)
ffffffffc020ad32:	60a2                	ld	ra,8(sp)
ffffffffc020ad34:	0141                	addi	sp,sp,16
ffffffffc020ad36:	b3df806f          	j	ffffffffc0203872 <kfree>

ffffffffc020ad3a <bitmap_getdata>:
ffffffffc020ad3a:	c589                	beqz	a1,ffffffffc020ad44 <bitmap_getdata+0xa>
ffffffffc020ad3c:	00456783          	lwu	a5,4(a0)
ffffffffc020ad40:	078a                	slli	a5,a5,0x2
ffffffffc020ad42:	e19c                	sd	a5,0(a1)
ffffffffc020ad44:	6508                	ld	a0,8(a0)
ffffffffc020ad46:	8082                	ret

ffffffffc020ad48 <sfs_rwblock_nolock>:
ffffffffc020ad48:	7139                	addi	sp,sp,-64
ffffffffc020ad4a:	f822                	sd	s0,48(sp)
ffffffffc020ad4c:	f426                	sd	s1,40(sp)
ffffffffc020ad4e:	fc06                	sd	ra,56(sp)
ffffffffc020ad50:	842a                	mv	s0,a0
ffffffffc020ad52:	84b6                	mv	s1,a3
ffffffffc020ad54:	e211                	bnez	a2,ffffffffc020ad58 <sfs_rwblock_nolock+0x10>
ffffffffc020ad56:	e715                	bnez	a4,ffffffffc020ad82 <sfs_rwblock_nolock+0x3a>
ffffffffc020ad58:	405c                	lw	a5,4(s0)
ffffffffc020ad5a:	02f67463          	bgeu	a2,a5,ffffffffc020ad82 <sfs_rwblock_nolock+0x3a>
ffffffffc020ad5e:	00c6169b          	slliw	a3,a2,0xc
ffffffffc020ad62:	1682                	slli	a3,a3,0x20
ffffffffc020ad64:	6605                	lui	a2,0x1
ffffffffc020ad66:	9281                	srli	a3,a3,0x20
ffffffffc020ad68:	850a                	mv	a0,sp
ffffffffc020ad6a:	9c3fa0ef          	jal	ra,ffffffffc020572c <iobuf_init>
ffffffffc020ad6e:	85aa                	mv	a1,a0
ffffffffc020ad70:	7808                	ld	a0,48(s0)
ffffffffc020ad72:	8626                	mv	a2,s1
ffffffffc020ad74:	7118                	ld	a4,32(a0)
ffffffffc020ad76:	9702                	jalr	a4
ffffffffc020ad78:	70e2                	ld	ra,56(sp)
ffffffffc020ad7a:	7442                	ld	s0,48(sp)
ffffffffc020ad7c:	74a2                	ld	s1,40(sp)
ffffffffc020ad7e:	6121                	addi	sp,sp,64
ffffffffc020ad80:	8082                	ret
ffffffffc020ad82:	00004697          	auipc	a3,0x4
ffffffffc020ad86:	6ae68693          	addi	a3,a3,1710 # ffffffffc020f430 <sfs_node_fileops+0x128>
ffffffffc020ad8a:	00001617          	auipc	a2,0x1
ffffffffc020ad8e:	d9e60613          	addi	a2,a2,-610 # ffffffffc020bb28 <commands+0x250>
ffffffffc020ad92:	45d5                	li	a1,21
ffffffffc020ad94:	00004517          	auipc	a0,0x4
ffffffffc020ad98:	6d450513          	addi	a0,a0,1748 # ffffffffc020f468 <sfs_node_fileops+0x160>
ffffffffc020ad9c:	c92f50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020ada0 <sfs_rblock>:
ffffffffc020ada0:	7139                	addi	sp,sp,-64
ffffffffc020ada2:	ec4e                	sd	s3,24(sp)
ffffffffc020ada4:	89b6                	mv	s3,a3
ffffffffc020ada6:	f822                	sd	s0,48(sp)
ffffffffc020ada8:	f04a                	sd	s2,32(sp)
ffffffffc020adaa:	e852                	sd	s4,16(sp)
ffffffffc020adac:	fc06                	sd	ra,56(sp)
ffffffffc020adae:	f426                	sd	s1,40(sp)
ffffffffc020adb0:	e456                	sd	s5,8(sp)
ffffffffc020adb2:	8a2a                	mv	s4,a0
ffffffffc020adb4:	892e                	mv	s2,a1
ffffffffc020adb6:	8432                	mv	s0,a2
ffffffffc020adb8:	a1cfe0ef          	jal	ra,ffffffffc0208fd4 <lock_sfs_io>
ffffffffc020adbc:	04098063          	beqz	s3,ffffffffc020adfc <sfs_rblock+0x5c>
ffffffffc020adc0:	013409bb          	addw	s3,s0,s3
ffffffffc020adc4:	6a85                	lui	s5,0x1
ffffffffc020adc6:	a021                	j	ffffffffc020adce <sfs_rblock+0x2e>
ffffffffc020adc8:	9956                	add	s2,s2,s5
ffffffffc020adca:	02898963          	beq	s3,s0,ffffffffc020adfc <sfs_rblock+0x5c>
ffffffffc020adce:	8622                	mv	a2,s0
ffffffffc020add0:	85ca                	mv	a1,s2
ffffffffc020add2:	4705                	li	a4,1
ffffffffc020add4:	4681                	li	a3,0
ffffffffc020add6:	8552                	mv	a0,s4
ffffffffc020add8:	f71ff0ef          	jal	ra,ffffffffc020ad48 <sfs_rwblock_nolock>
ffffffffc020addc:	84aa                	mv	s1,a0
ffffffffc020adde:	2405                	addiw	s0,s0,1
ffffffffc020ade0:	d565                	beqz	a0,ffffffffc020adc8 <sfs_rblock+0x28>
ffffffffc020ade2:	8552                	mv	a0,s4
ffffffffc020ade4:	a00fe0ef          	jal	ra,ffffffffc0208fe4 <unlock_sfs_io>
ffffffffc020ade8:	70e2                	ld	ra,56(sp)
ffffffffc020adea:	7442                	ld	s0,48(sp)
ffffffffc020adec:	7902                	ld	s2,32(sp)
ffffffffc020adee:	69e2                	ld	s3,24(sp)
ffffffffc020adf0:	6a42                	ld	s4,16(sp)
ffffffffc020adf2:	6aa2                	ld	s5,8(sp)
ffffffffc020adf4:	8526                	mv	a0,s1
ffffffffc020adf6:	74a2                	ld	s1,40(sp)
ffffffffc020adf8:	6121                	addi	sp,sp,64
ffffffffc020adfa:	8082                	ret
ffffffffc020adfc:	4481                	li	s1,0
ffffffffc020adfe:	b7d5                	j	ffffffffc020ade2 <sfs_rblock+0x42>

ffffffffc020ae00 <sfs_wblock>:
ffffffffc020ae00:	7139                	addi	sp,sp,-64
ffffffffc020ae02:	ec4e                	sd	s3,24(sp)
ffffffffc020ae04:	89b6                	mv	s3,a3
ffffffffc020ae06:	f822                	sd	s0,48(sp)
ffffffffc020ae08:	f04a                	sd	s2,32(sp)
ffffffffc020ae0a:	e852                	sd	s4,16(sp)
ffffffffc020ae0c:	fc06                	sd	ra,56(sp)
ffffffffc020ae0e:	f426                	sd	s1,40(sp)
ffffffffc020ae10:	e456                	sd	s5,8(sp)
ffffffffc020ae12:	8a2a                	mv	s4,a0
ffffffffc020ae14:	892e                	mv	s2,a1
ffffffffc020ae16:	8432                	mv	s0,a2
ffffffffc020ae18:	9bcfe0ef          	jal	ra,ffffffffc0208fd4 <lock_sfs_io>
ffffffffc020ae1c:	04098063          	beqz	s3,ffffffffc020ae5c <sfs_wblock+0x5c>
ffffffffc020ae20:	013409bb          	addw	s3,s0,s3
ffffffffc020ae24:	6a85                	lui	s5,0x1
ffffffffc020ae26:	a021                	j	ffffffffc020ae2e <sfs_wblock+0x2e>
ffffffffc020ae28:	9956                	add	s2,s2,s5
ffffffffc020ae2a:	02898963          	beq	s3,s0,ffffffffc020ae5c <sfs_wblock+0x5c>
ffffffffc020ae2e:	8622                	mv	a2,s0
ffffffffc020ae30:	85ca                	mv	a1,s2
ffffffffc020ae32:	4705                	li	a4,1
ffffffffc020ae34:	4685                	li	a3,1
ffffffffc020ae36:	8552                	mv	a0,s4
ffffffffc020ae38:	f11ff0ef          	jal	ra,ffffffffc020ad48 <sfs_rwblock_nolock>
ffffffffc020ae3c:	84aa                	mv	s1,a0
ffffffffc020ae3e:	2405                	addiw	s0,s0,1
ffffffffc020ae40:	d565                	beqz	a0,ffffffffc020ae28 <sfs_wblock+0x28>
ffffffffc020ae42:	8552                	mv	a0,s4
ffffffffc020ae44:	9a0fe0ef          	jal	ra,ffffffffc0208fe4 <unlock_sfs_io>
ffffffffc020ae48:	70e2                	ld	ra,56(sp)
ffffffffc020ae4a:	7442                	ld	s0,48(sp)
ffffffffc020ae4c:	7902                	ld	s2,32(sp)
ffffffffc020ae4e:	69e2                	ld	s3,24(sp)
ffffffffc020ae50:	6a42                	ld	s4,16(sp)
ffffffffc020ae52:	6aa2                	ld	s5,8(sp)
ffffffffc020ae54:	8526                	mv	a0,s1
ffffffffc020ae56:	74a2                	ld	s1,40(sp)
ffffffffc020ae58:	6121                	addi	sp,sp,64
ffffffffc020ae5a:	8082                	ret
ffffffffc020ae5c:	4481                	li	s1,0
ffffffffc020ae5e:	b7d5                	j	ffffffffc020ae42 <sfs_wblock+0x42>

ffffffffc020ae60 <sfs_rbuf>:
ffffffffc020ae60:	7179                	addi	sp,sp,-48
ffffffffc020ae62:	f406                	sd	ra,40(sp)
ffffffffc020ae64:	f022                	sd	s0,32(sp)
ffffffffc020ae66:	ec26                	sd	s1,24(sp)
ffffffffc020ae68:	e84a                	sd	s2,16(sp)
ffffffffc020ae6a:	e44e                	sd	s3,8(sp)
ffffffffc020ae6c:	e052                	sd	s4,0(sp)
ffffffffc020ae6e:	6785                	lui	a5,0x1
ffffffffc020ae70:	04f77863          	bgeu	a4,a5,ffffffffc020aec0 <sfs_rbuf+0x60>
ffffffffc020ae74:	84ba                	mv	s1,a4
ffffffffc020ae76:	9732                	add	a4,a4,a2
ffffffffc020ae78:	89b2                	mv	s3,a2
ffffffffc020ae7a:	04e7e363          	bltu	a5,a4,ffffffffc020aec0 <sfs_rbuf+0x60>
ffffffffc020ae7e:	8936                	mv	s2,a3
ffffffffc020ae80:	842a                	mv	s0,a0
ffffffffc020ae82:	8a2e                	mv	s4,a1
ffffffffc020ae84:	950fe0ef          	jal	ra,ffffffffc0208fd4 <lock_sfs_io>
ffffffffc020ae88:	642c                	ld	a1,72(s0)
ffffffffc020ae8a:	864a                	mv	a2,s2
ffffffffc020ae8c:	4705                	li	a4,1
ffffffffc020ae8e:	4681                	li	a3,0
ffffffffc020ae90:	8522                	mv	a0,s0
ffffffffc020ae92:	eb7ff0ef          	jal	ra,ffffffffc020ad48 <sfs_rwblock_nolock>
ffffffffc020ae96:	892a                	mv	s2,a0
ffffffffc020ae98:	cd09                	beqz	a0,ffffffffc020aeb2 <sfs_rbuf+0x52>
ffffffffc020ae9a:	8522                	mv	a0,s0
ffffffffc020ae9c:	948fe0ef          	jal	ra,ffffffffc0208fe4 <unlock_sfs_io>
ffffffffc020aea0:	70a2                	ld	ra,40(sp)
ffffffffc020aea2:	7402                	ld	s0,32(sp)
ffffffffc020aea4:	64e2                	ld	s1,24(sp)
ffffffffc020aea6:	69a2                	ld	s3,8(sp)
ffffffffc020aea8:	6a02                	ld	s4,0(sp)
ffffffffc020aeaa:	854a                	mv	a0,s2
ffffffffc020aeac:	6942                	ld	s2,16(sp)
ffffffffc020aeae:	6145                	addi	sp,sp,48
ffffffffc020aeb0:	8082                	ret
ffffffffc020aeb2:	642c                	ld	a1,72(s0)
ffffffffc020aeb4:	864e                	mv	a2,s3
ffffffffc020aeb6:	8552                	mv	a0,s4
ffffffffc020aeb8:	95a6                	add	a1,a1,s1
ffffffffc020aeba:	2ca000ef          	jal	ra,ffffffffc020b184 <memcpy>
ffffffffc020aebe:	bff1                	j	ffffffffc020ae9a <sfs_rbuf+0x3a>
ffffffffc020aec0:	00004697          	auipc	a3,0x4
ffffffffc020aec4:	5c068693          	addi	a3,a3,1472 # ffffffffc020f480 <sfs_node_fileops+0x178>
ffffffffc020aec8:	00001617          	auipc	a2,0x1
ffffffffc020aecc:	c6060613          	addi	a2,a2,-928 # ffffffffc020bb28 <commands+0x250>
ffffffffc020aed0:	05500593          	li	a1,85
ffffffffc020aed4:	00004517          	auipc	a0,0x4
ffffffffc020aed8:	59450513          	addi	a0,a0,1428 # ffffffffc020f468 <sfs_node_fileops+0x160>
ffffffffc020aedc:	b52f50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020aee0 <sfs_wbuf>:
ffffffffc020aee0:	7139                	addi	sp,sp,-64
ffffffffc020aee2:	fc06                	sd	ra,56(sp)
ffffffffc020aee4:	f822                	sd	s0,48(sp)
ffffffffc020aee6:	f426                	sd	s1,40(sp)
ffffffffc020aee8:	f04a                	sd	s2,32(sp)
ffffffffc020aeea:	ec4e                	sd	s3,24(sp)
ffffffffc020aeec:	e852                	sd	s4,16(sp)
ffffffffc020aeee:	e456                	sd	s5,8(sp)
ffffffffc020aef0:	6785                	lui	a5,0x1
ffffffffc020aef2:	06f77163          	bgeu	a4,a5,ffffffffc020af54 <sfs_wbuf+0x74>
ffffffffc020aef6:	893a                	mv	s2,a4
ffffffffc020aef8:	9732                	add	a4,a4,a2
ffffffffc020aefa:	8a32                	mv	s4,a2
ffffffffc020aefc:	04e7ec63          	bltu	a5,a4,ffffffffc020af54 <sfs_wbuf+0x74>
ffffffffc020af00:	842a                	mv	s0,a0
ffffffffc020af02:	89b6                	mv	s3,a3
ffffffffc020af04:	8aae                	mv	s5,a1
ffffffffc020af06:	8cefe0ef          	jal	ra,ffffffffc0208fd4 <lock_sfs_io>
ffffffffc020af0a:	642c                	ld	a1,72(s0)
ffffffffc020af0c:	4705                	li	a4,1
ffffffffc020af0e:	4681                	li	a3,0
ffffffffc020af10:	864e                	mv	a2,s3
ffffffffc020af12:	8522                	mv	a0,s0
ffffffffc020af14:	e35ff0ef          	jal	ra,ffffffffc020ad48 <sfs_rwblock_nolock>
ffffffffc020af18:	84aa                	mv	s1,a0
ffffffffc020af1a:	cd11                	beqz	a0,ffffffffc020af36 <sfs_wbuf+0x56>
ffffffffc020af1c:	8522                	mv	a0,s0
ffffffffc020af1e:	8c6fe0ef          	jal	ra,ffffffffc0208fe4 <unlock_sfs_io>
ffffffffc020af22:	70e2                	ld	ra,56(sp)
ffffffffc020af24:	7442                	ld	s0,48(sp)
ffffffffc020af26:	7902                	ld	s2,32(sp)
ffffffffc020af28:	69e2                	ld	s3,24(sp)
ffffffffc020af2a:	6a42                	ld	s4,16(sp)
ffffffffc020af2c:	6aa2                	ld	s5,8(sp)
ffffffffc020af2e:	8526                	mv	a0,s1
ffffffffc020af30:	74a2                	ld	s1,40(sp)
ffffffffc020af32:	6121                	addi	sp,sp,64
ffffffffc020af34:	8082                	ret
ffffffffc020af36:	6428                	ld	a0,72(s0)
ffffffffc020af38:	8652                	mv	a2,s4
ffffffffc020af3a:	85d6                	mv	a1,s5
ffffffffc020af3c:	954a                	add	a0,a0,s2
ffffffffc020af3e:	246000ef          	jal	ra,ffffffffc020b184 <memcpy>
ffffffffc020af42:	642c                	ld	a1,72(s0)
ffffffffc020af44:	4705                	li	a4,1
ffffffffc020af46:	4685                	li	a3,1
ffffffffc020af48:	864e                	mv	a2,s3
ffffffffc020af4a:	8522                	mv	a0,s0
ffffffffc020af4c:	dfdff0ef          	jal	ra,ffffffffc020ad48 <sfs_rwblock_nolock>
ffffffffc020af50:	84aa                	mv	s1,a0
ffffffffc020af52:	b7e9                	j	ffffffffc020af1c <sfs_wbuf+0x3c>
ffffffffc020af54:	00004697          	auipc	a3,0x4
ffffffffc020af58:	52c68693          	addi	a3,a3,1324 # ffffffffc020f480 <sfs_node_fileops+0x178>
ffffffffc020af5c:	00001617          	auipc	a2,0x1
ffffffffc020af60:	bcc60613          	addi	a2,a2,-1076 # ffffffffc020bb28 <commands+0x250>
ffffffffc020af64:	06b00593          	li	a1,107
ffffffffc020af68:	00004517          	auipc	a0,0x4
ffffffffc020af6c:	50050513          	addi	a0,a0,1280 # ffffffffc020f468 <sfs_node_fileops+0x160>
ffffffffc020af70:	abef50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020af74 <sfs_sync_super>:
ffffffffc020af74:	1101                	addi	sp,sp,-32
ffffffffc020af76:	ec06                	sd	ra,24(sp)
ffffffffc020af78:	e822                	sd	s0,16(sp)
ffffffffc020af7a:	e426                	sd	s1,8(sp)
ffffffffc020af7c:	842a                	mv	s0,a0
ffffffffc020af7e:	856fe0ef          	jal	ra,ffffffffc0208fd4 <lock_sfs_io>
ffffffffc020af82:	6428                	ld	a0,72(s0)
ffffffffc020af84:	6605                	lui	a2,0x1
ffffffffc020af86:	4581                	li	a1,0
ffffffffc020af88:	1aa000ef          	jal	ra,ffffffffc020b132 <memset>
ffffffffc020af8c:	6428                	ld	a0,72(s0)
ffffffffc020af8e:	85a2                	mv	a1,s0
ffffffffc020af90:	02c00613          	li	a2,44
ffffffffc020af94:	1f0000ef          	jal	ra,ffffffffc020b184 <memcpy>
ffffffffc020af98:	642c                	ld	a1,72(s0)
ffffffffc020af9a:	4701                	li	a4,0
ffffffffc020af9c:	4685                	li	a3,1
ffffffffc020af9e:	4601                	li	a2,0
ffffffffc020afa0:	8522                	mv	a0,s0
ffffffffc020afa2:	da7ff0ef          	jal	ra,ffffffffc020ad48 <sfs_rwblock_nolock>
ffffffffc020afa6:	84aa                	mv	s1,a0
ffffffffc020afa8:	8522                	mv	a0,s0
ffffffffc020afaa:	83afe0ef          	jal	ra,ffffffffc0208fe4 <unlock_sfs_io>
ffffffffc020afae:	60e2                	ld	ra,24(sp)
ffffffffc020afb0:	6442                	ld	s0,16(sp)
ffffffffc020afb2:	8526                	mv	a0,s1
ffffffffc020afb4:	64a2                	ld	s1,8(sp)
ffffffffc020afb6:	6105                	addi	sp,sp,32
ffffffffc020afb8:	8082                	ret

ffffffffc020afba <sfs_sync_freemap>:
ffffffffc020afba:	7139                	addi	sp,sp,-64
ffffffffc020afbc:	ec4e                	sd	s3,24(sp)
ffffffffc020afbe:	e852                	sd	s4,16(sp)
ffffffffc020afc0:	00456983          	lwu	s3,4(a0)
ffffffffc020afc4:	8a2a                	mv	s4,a0
ffffffffc020afc6:	7d08                	ld	a0,56(a0)
ffffffffc020afc8:	67a1                	lui	a5,0x8
ffffffffc020afca:	17fd                	addi	a5,a5,-1
ffffffffc020afcc:	4581                	li	a1,0
ffffffffc020afce:	f822                	sd	s0,48(sp)
ffffffffc020afd0:	fc06                	sd	ra,56(sp)
ffffffffc020afd2:	f426                	sd	s1,40(sp)
ffffffffc020afd4:	f04a                	sd	s2,32(sp)
ffffffffc020afd6:	e456                	sd	s5,8(sp)
ffffffffc020afd8:	99be                	add	s3,s3,a5
ffffffffc020afda:	d61ff0ef          	jal	ra,ffffffffc020ad3a <bitmap_getdata>
ffffffffc020afde:	00f9d993          	srli	s3,s3,0xf
ffffffffc020afe2:	842a                	mv	s0,a0
ffffffffc020afe4:	8552                	mv	a0,s4
ffffffffc020afe6:	feffd0ef          	jal	ra,ffffffffc0208fd4 <lock_sfs_io>
ffffffffc020afea:	04098163          	beqz	s3,ffffffffc020b02c <sfs_sync_freemap+0x72>
ffffffffc020afee:	09b2                	slli	s3,s3,0xc
ffffffffc020aff0:	99a2                	add	s3,s3,s0
ffffffffc020aff2:	4909                	li	s2,2
ffffffffc020aff4:	6a85                	lui	s5,0x1
ffffffffc020aff6:	a021                	j	ffffffffc020affe <sfs_sync_freemap+0x44>
ffffffffc020aff8:	2905                	addiw	s2,s2,1
ffffffffc020affa:	02898963          	beq	s3,s0,ffffffffc020b02c <sfs_sync_freemap+0x72>
ffffffffc020affe:	85a2                	mv	a1,s0
ffffffffc020b000:	864a                	mv	a2,s2
ffffffffc020b002:	4705                	li	a4,1
ffffffffc020b004:	4685                	li	a3,1
ffffffffc020b006:	8552                	mv	a0,s4
ffffffffc020b008:	d41ff0ef          	jal	ra,ffffffffc020ad48 <sfs_rwblock_nolock>
ffffffffc020b00c:	84aa                	mv	s1,a0
ffffffffc020b00e:	9456                	add	s0,s0,s5
ffffffffc020b010:	d565                	beqz	a0,ffffffffc020aff8 <sfs_sync_freemap+0x3e>
ffffffffc020b012:	8552                	mv	a0,s4
ffffffffc020b014:	fd1fd0ef          	jal	ra,ffffffffc0208fe4 <unlock_sfs_io>
ffffffffc020b018:	70e2                	ld	ra,56(sp)
ffffffffc020b01a:	7442                	ld	s0,48(sp)
ffffffffc020b01c:	7902                	ld	s2,32(sp)
ffffffffc020b01e:	69e2                	ld	s3,24(sp)
ffffffffc020b020:	6a42                	ld	s4,16(sp)
ffffffffc020b022:	6aa2                	ld	s5,8(sp)
ffffffffc020b024:	8526                	mv	a0,s1
ffffffffc020b026:	74a2                	ld	s1,40(sp)
ffffffffc020b028:	6121                	addi	sp,sp,64
ffffffffc020b02a:	8082                	ret
ffffffffc020b02c:	4481                	li	s1,0
ffffffffc020b02e:	b7d5                	j	ffffffffc020b012 <sfs_sync_freemap+0x58>

ffffffffc020b030 <sfs_clear_block>:
ffffffffc020b030:	7179                	addi	sp,sp,-48
ffffffffc020b032:	f022                	sd	s0,32(sp)
ffffffffc020b034:	e84a                	sd	s2,16(sp)
ffffffffc020b036:	e44e                	sd	s3,8(sp)
ffffffffc020b038:	f406                	sd	ra,40(sp)
ffffffffc020b03a:	89b2                	mv	s3,a2
ffffffffc020b03c:	ec26                	sd	s1,24(sp)
ffffffffc020b03e:	892a                	mv	s2,a0
ffffffffc020b040:	842e                	mv	s0,a1
ffffffffc020b042:	f93fd0ef          	jal	ra,ffffffffc0208fd4 <lock_sfs_io>
ffffffffc020b046:	04893503          	ld	a0,72(s2)
ffffffffc020b04a:	6605                	lui	a2,0x1
ffffffffc020b04c:	4581                	li	a1,0
ffffffffc020b04e:	0e4000ef          	jal	ra,ffffffffc020b132 <memset>
ffffffffc020b052:	02098d63          	beqz	s3,ffffffffc020b08c <sfs_clear_block+0x5c>
ffffffffc020b056:	013409bb          	addw	s3,s0,s3
ffffffffc020b05a:	a019                	j	ffffffffc020b060 <sfs_clear_block+0x30>
ffffffffc020b05c:	02898863          	beq	s3,s0,ffffffffc020b08c <sfs_clear_block+0x5c>
ffffffffc020b060:	04893583          	ld	a1,72(s2)
ffffffffc020b064:	8622                	mv	a2,s0
ffffffffc020b066:	4705                	li	a4,1
ffffffffc020b068:	4685                	li	a3,1
ffffffffc020b06a:	854a                	mv	a0,s2
ffffffffc020b06c:	cddff0ef          	jal	ra,ffffffffc020ad48 <sfs_rwblock_nolock>
ffffffffc020b070:	84aa                	mv	s1,a0
ffffffffc020b072:	2405                	addiw	s0,s0,1
ffffffffc020b074:	d565                	beqz	a0,ffffffffc020b05c <sfs_clear_block+0x2c>
ffffffffc020b076:	854a                	mv	a0,s2
ffffffffc020b078:	f6dfd0ef          	jal	ra,ffffffffc0208fe4 <unlock_sfs_io>
ffffffffc020b07c:	70a2                	ld	ra,40(sp)
ffffffffc020b07e:	7402                	ld	s0,32(sp)
ffffffffc020b080:	6942                	ld	s2,16(sp)
ffffffffc020b082:	69a2                	ld	s3,8(sp)
ffffffffc020b084:	8526                	mv	a0,s1
ffffffffc020b086:	64e2                	ld	s1,24(sp)
ffffffffc020b088:	6145                	addi	sp,sp,48
ffffffffc020b08a:	8082                	ret
ffffffffc020b08c:	4481                	li	s1,0
ffffffffc020b08e:	b7e5                	j	ffffffffc020b076 <sfs_clear_block+0x46>

ffffffffc020b090 <strlen>:
ffffffffc020b090:	00054783          	lbu	a5,0(a0)
ffffffffc020b094:	872a                	mv	a4,a0
ffffffffc020b096:	4501                	li	a0,0
ffffffffc020b098:	cb81                	beqz	a5,ffffffffc020b0a8 <strlen+0x18>
ffffffffc020b09a:	0505                	addi	a0,a0,1
ffffffffc020b09c:	00a707b3          	add	a5,a4,a0
ffffffffc020b0a0:	0007c783          	lbu	a5,0(a5) # 8000 <_binary_bin_swap_img_size+0x300>
ffffffffc020b0a4:	fbfd                	bnez	a5,ffffffffc020b09a <strlen+0xa>
ffffffffc020b0a6:	8082                	ret
ffffffffc020b0a8:	8082                	ret

ffffffffc020b0aa <strnlen>:
ffffffffc020b0aa:	4781                	li	a5,0
ffffffffc020b0ac:	e589                	bnez	a1,ffffffffc020b0b6 <strnlen+0xc>
ffffffffc020b0ae:	a811                	j	ffffffffc020b0c2 <strnlen+0x18>
ffffffffc020b0b0:	0785                	addi	a5,a5,1
ffffffffc020b0b2:	00f58863          	beq	a1,a5,ffffffffc020b0c2 <strnlen+0x18>
ffffffffc020b0b6:	00f50733          	add	a4,a0,a5
ffffffffc020b0ba:	00074703          	lbu	a4,0(a4)
ffffffffc020b0be:	fb6d                	bnez	a4,ffffffffc020b0b0 <strnlen+0x6>
ffffffffc020b0c0:	85be                	mv	a1,a5
ffffffffc020b0c2:	852e                	mv	a0,a1
ffffffffc020b0c4:	8082                	ret

ffffffffc020b0c6 <strcpy>:
ffffffffc020b0c6:	87aa                	mv	a5,a0
ffffffffc020b0c8:	0005c703          	lbu	a4,0(a1)
ffffffffc020b0cc:	0785                	addi	a5,a5,1
ffffffffc020b0ce:	0585                	addi	a1,a1,1
ffffffffc020b0d0:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020b0d4:	fb75                	bnez	a4,ffffffffc020b0c8 <strcpy+0x2>
ffffffffc020b0d6:	8082                	ret

ffffffffc020b0d8 <strcmp>:
ffffffffc020b0d8:	00054783          	lbu	a5,0(a0)
ffffffffc020b0dc:	0005c703          	lbu	a4,0(a1)
ffffffffc020b0e0:	cb89                	beqz	a5,ffffffffc020b0f2 <strcmp+0x1a>
ffffffffc020b0e2:	0505                	addi	a0,a0,1
ffffffffc020b0e4:	0585                	addi	a1,a1,1
ffffffffc020b0e6:	fee789e3          	beq	a5,a4,ffffffffc020b0d8 <strcmp>
ffffffffc020b0ea:	0007851b          	sext.w	a0,a5
ffffffffc020b0ee:	9d19                	subw	a0,a0,a4
ffffffffc020b0f0:	8082                	ret
ffffffffc020b0f2:	4501                	li	a0,0
ffffffffc020b0f4:	bfed                	j	ffffffffc020b0ee <strcmp+0x16>

ffffffffc020b0f6 <strncmp>:
ffffffffc020b0f6:	c20d                	beqz	a2,ffffffffc020b118 <strncmp+0x22>
ffffffffc020b0f8:	962e                	add	a2,a2,a1
ffffffffc020b0fa:	a031                	j	ffffffffc020b106 <strncmp+0x10>
ffffffffc020b0fc:	0505                	addi	a0,a0,1
ffffffffc020b0fe:	00e79a63          	bne	a5,a4,ffffffffc020b112 <strncmp+0x1c>
ffffffffc020b102:	00b60b63          	beq	a2,a1,ffffffffc020b118 <strncmp+0x22>
ffffffffc020b106:	00054783          	lbu	a5,0(a0)
ffffffffc020b10a:	0585                	addi	a1,a1,1
ffffffffc020b10c:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020b110:	f7f5                	bnez	a5,ffffffffc020b0fc <strncmp+0x6>
ffffffffc020b112:	40e7853b          	subw	a0,a5,a4
ffffffffc020b116:	8082                	ret
ffffffffc020b118:	4501                	li	a0,0
ffffffffc020b11a:	8082                	ret

ffffffffc020b11c <strchr>:
ffffffffc020b11c:	00054783          	lbu	a5,0(a0)
ffffffffc020b120:	c799                	beqz	a5,ffffffffc020b12e <strchr+0x12>
ffffffffc020b122:	00f58763          	beq	a1,a5,ffffffffc020b130 <strchr+0x14>
ffffffffc020b126:	00154783          	lbu	a5,1(a0)
ffffffffc020b12a:	0505                	addi	a0,a0,1
ffffffffc020b12c:	fbfd                	bnez	a5,ffffffffc020b122 <strchr+0x6>
ffffffffc020b12e:	4501                	li	a0,0
ffffffffc020b130:	8082                	ret

ffffffffc020b132 <memset>:
ffffffffc020b132:	ca01                	beqz	a2,ffffffffc020b142 <memset+0x10>
ffffffffc020b134:	962a                	add	a2,a2,a0
ffffffffc020b136:	87aa                	mv	a5,a0
ffffffffc020b138:	0785                	addi	a5,a5,1
ffffffffc020b13a:	feb78fa3          	sb	a1,-1(a5)
ffffffffc020b13e:	fec79de3          	bne	a5,a2,ffffffffc020b138 <memset+0x6>
ffffffffc020b142:	8082                	ret

ffffffffc020b144 <memmove>:
ffffffffc020b144:	02a5f263          	bgeu	a1,a0,ffffffffc020b168 <memmove+0x24>
ffffffffc020b148:	00c587b3          	add	a5,a1,a2
ffffffffc020b14c:	00f57e63          	bgeu	a0,a5,ffffffffc020b168 <memmove+0x24>
ffffffffc020b150:	00c50733          	add	a4,a0,a2
ffffffffc020b154:	c615                	beqz	a2,ffffffffc020b180 <memmove+0x3c>
ffffffffc020b156:	fff7c683          	lbu	a3,-1(a5)
ffffffffc020b15a:	17fd                	addi	a5,a5,-1
ffffffffc020b15c:	177d                	addi	a4,a4,-1
ffffffffc020b15e:	00d70023          	sb	a3,0(a4)
ffffffffc020b162:	fef59ae3          	bne	a1,a5,ffffffffc020b156 <memmove+0x12>
ffffffffc020b166:	8082                	ret
ffffffffc020b168:	00c586b3          	add	a3,a1,a2
ffffffffc020b16c:	87aa                	mv	a5,a0
ffffffffc020b16e:	ca11                	beqz	a2,ffffffffc020b182 <memmove+0x3e>
ffffffffc020b170:	0005c703          	lbu	a4,0(a1)
ffffffffc020b174:	0585                	addi	a1,a1,1
ffffffffc020b176:	0785                	addi	a5,a5,1
ffffffffc020b178:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020b17c:	fed59ae3          	bne	a1,a3,ffffffffc020b170 <memmove+0x2c>
ffffffffc020b180:	8082                	ret
ffffffffc020b182:	8082                	ret

ffffffffc020b184 <memcpy>:
ffffffffc020b184:	ca19                	beqz	a2,ffffffffc020b19a <memcpy+0x16>
ffffffffc020b186:	962e                	add	a2,a2,a1
ffffffffc020b188:	87aa                	mv	a5,a0
ffffffffc020b18a:	0005c703          	lbu	a4,0(a1)
ffffffffc020b18e:	0585                	addi	a1,a1,1
ffffffffc020b190:	0785                	addi	a5,a5,1
ffffffffc020b192:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020b196:	fec59ae3          	bne	a1,a2,ffffffffc020b18a <memcpy+0x6>
ffffffffc020b19a:	8082                	ret

ffffffffc020b19c <printnum>:
ffffffffc020b19c:	02071893          	slli	a7,a4,0x20
ffffffffc020b1a0:	7139                	addi	sp,sp,-64
ffffffffc020b1a2:	0208d893          	srli	a7,a7,0x20
ffffffffc020b1a6:	e456                	sd	s5,8(sp)
ffffffffc020b1a8:	0316fab3          	remu	s5,a3,a7
ffffffffc020b1ac:	f822                	sd	s0,48(sp)
ffffffffc020b1ae:	f426                	sd	s1,40(sp)
ffffffffc020b1b0:	f04a                	sd	s2,32(sp)
ffffffffc020b1b2:	ec4e                	sd	s3,24(sp)
ffffffffc020b1b4:	fc06                	sd	ra,56(sp)
ffffffffc020b1b6:	e852                	sd	s4,16(sp)
ffffffffc020b1b8:	84aa                	mv	s1,a0
ffffffffc020b1ba:	89ae                	mv	s3,a1
ffffffffc020b1bc:	8932                	mv	s2,a2
ffffffffc020b1be:	fff7841b          	addiw	s0,a5,-1
ffffffffc020b1c2:	2a81                	sext.w	s5,s5
ffffffffc020b1c4:	0516f163          	bgeu	a3,a7,ffffffffc020b206 <printnum+0x6a>
ffffffffc020b1c8:	8a42                	mv	s4,a6
ffffffffc020b1ca:	00805863          	blez	s0,ffffffffc020b1da <printnum+0x3e>
ffffffffc020b1ce:	347d                	addiw	s0,s0,-1
ffffffffc020b1d0:	864e                	mv	a2,s3
ffffffffc020b1d2:	85ca                	mv	a1,s2
ffffffffc020b1d4:	8552                	mv	a0,s4
ffffffffc020b1d6:	9482                	jalr	s1
ffffffffc020b1d8:	f87d                	bnez	s0,ffffffffc020b1ce <printnum+0x32>
ffffffffc020b1da:	1a82                	slli	s5,s5,0x20
ffffffffc020b1dc:	00004797          	auipc	a5,0x4
ffffffffc020b1e0:	2ec78793          	addi	a5,a5,748 # ffffffffc020f4c8 <sfs_node_fileops+0x1c0>
ffffffffc020b1e4:	020ada93          	srli	s5,s5,0x20
ffffffffc020b1e8:	9abe                	add	s5,s5,a5
ffffffffc020b1ea:	7442                	ld	s0,48(sp)
ffffffffc020b1ec:	000ac503          	lbu	a0,0(s5) # 1000 <_binary_bin_swap_img_size-0x6d00>
ffffffffc020b1f0:	70e2                	ld	ra,56(sp)
ffffffffc020b1f2:	6a42                	ld	s4,16(sp)
ffffffffc020b1f4:	6aa2                	ld	s5,8(sp)
ffffffffc020b1f6:	864e                	mv	a2,s3
ffffffffc020b1f8:	85ca                	mv	a1,s2
ffffffffc020b1fa:	69e2                	ld	s3,24(sp)
ffffffffc020b1fc:	7902                	ld	s2,32(sp)
ffffffffc020b1fe:	87a6                	mv	a5,s1
ffffffffc020b200:	74a2                	ld	s1,40(sp)
ffffffffc020b202:	6121                	addi	sp,sp,64
ffffffffc020b204:	8782                	jr	a5
ffffffffc020b206:	0316d6b3          	divu	a3,a3,a7
ffffffffc020b20a:	87a2                	mv	a5,s0
ffffffffc020b20c:	f91ff0ef          	jal	ra,ffffffffc020b19c <printnum>
ffffffffc020b210:	b7e9                	j	ffffffffc020b1da <printnum+0x3e>

ffffffffc020b212 <sprintputch>:
ffffffffc020b212:	499c                	lw	a5,16(a1)
ffffffffc020b214:	6198                	ld	a4,0(a1)
ffffffffc020b216:	6594                	ld	a3,8(a1)
ffffffffc020b218:	2785                	addiw	a5,a5,1
ffffffffc020b21a:	c99c                	sw	a5,16(a1)
ffffffffc020b21c:	00d77763          	bgeu	a4,a3,ffffffffc020b22a <sprintputch+0x18>
ffffffffc020b220:	00170793          	addi	a5,a4,1
ffffffffc020b224:	e19c                	sd	a5,0(a1)
ffffffffc020b226:	00a70023          	sb	a0,0(a4)
ffffffffc020b22a:	8082                	ret

ffffffffc020b22c <vprintfmt>:
ffffffffc020b22c:	7119                	addi	sp,sp,-128
ffffffffc020b22e:	f4a6                	sd	s1,104(sp)
ffffffffc020b230:	f0ca                	sd	s2,96(sp)
ffffffffc020b232:	ecce                	sd	s3,88(sp)
ffffffffc020b234:	e8d2                	sd	s4,80(sp)
ffffffffc020b236:	e4d6                	sd	s5,72(sp)
ffffffffc020b238:	e0da                	sd	s6,64(sp)
ffffffffc020b23a:	fc5e                	sd	s7,56(sp)
ffffffffc020b23c:	ec6e                	sd	s11,24(sp)
ffffffffc020b23e:	fc86                	sd	ra,120(sp)
ffffffffc020b240:	f8a2                	sd	s0,112(sp)
ffffffffc020b242:	f862                	sd	s8,48(sp)
ffffffffc020b244:	f466                	sd	s9,40(sp)
ffffffffc020b246:	f06a                	sd	s10,32(sp)
ffffffffc020b248:	89aa                	mv	s3,a0
ffffffffc020b24a:	892e                	mv	s2,a1
ffffffffc020b24c:	84b2                	mv	s1,a2
ffffffffc020b24e:	8db6                	mv	s11,a3
ffffffffc020b250:	8aba                	mv	s5,a4
ffffffffc020b252:	02500a13          	li	s4,37
ffffffffc020b256:	5bfd                	li	s7,-1
ffffffffc020b258:	00004b17          	auipc	s6,0x4
ffffffffc020b25c:	29cb0b13          	addi	s6,s6,668 # ffffffffc020f4f4 <sfs_node_fileops+0x1ec>
ffffffffc020b260:	000dc503          	lbu	a0,0(s11) # 2000 <_binary_bin_swap_img_size-0x5d00>
ffffffffc020b264:	001d8413          	addi	s0,s11,1
ffffffffc020b268:	01450b63          	beq	a0,s4,ffffffffc020b27e <vprintfmt+0x52>
ffffffffc020b26c:	c129                	beqz	a0,ffffffffc020b2ae <vprintfmt+0x82>
ffffffffc020b26e:	864a                	mv	a2,s2
ffffffffc020b270:	85a6                	mv	a1,s1
ffffffffc020b272:	0405                	addi	s0,s0,1
ffffffffc020b274:	9982                	jalr	s3
ffffffffc020b276:	fff44503          	lbu	a0,-1(s0)
ffffffffc020b27a:	ff4519e3          	bne	a0,s4,ffffffffc020b26c <vprintfmt+0x40>
ffffffffc020b27e:	00044583          	lbu	a1,0(s0)
ffffffffc020b282:	02000813          	li	a6,32
ffffffffc020b286:	4d01                	li	s10,0
ffffffffc020b288:	4301                	li	t1,0
ffffffffc020b28a:	5cfd                	li	s9,-1
ffffffffc020b28c:	5c7d                	li	s8,-1
ffffffffc020b28e:	05500513          	li	a0,85
ffffffffc020b292:	48a5                	li	a7,9
ffffffffc020b294:	fdd5861b          	addiw	a2,a1,-35
ffffffffc020b298:	0ff67613          	zext.b	a2,a2
ffffffffc020b29c:	00140d93          	addi	s11,s0,1
ffffffffc020b2a0:	04c56263          	bltu	a0,a2,ffffffffc020b2e4 <vprintfmt+0xb8>
ffffffffc020b2a4:	060a                	slli	a2,a2,0x2
ffffffffc020b2a6:	965a                	add	a2,a2,s6
ffffffffc020b2a8:	4214                	lw	a3,0(a2)
ffffffffc020b2aa:	96da                	add	a3,a3,s6
ffffffffc020b2ac:	8682                	jr	a3
ffffffffc020b2ae:	70e6                	ld	ra,120(sp)
ffffffffc020b2b0:	7446                	ld	s0,112(sp)
ffffffffc020b2b2:	74a6                	ld	s1,104(sp)
ffffffffc020b2b4:	7906                	ld	s2,96(sp)
ffffffffc020b2b6:	69e6                	ld	s3,88(sp)
ffffffffc020b2b8:	6a46                	ld	s4,80(sp)
ffffffffc020b2ba:	6aa6                	ld	s5,72(sp)
ffffffffc020b2bc:	6b06                	ld	s6,64(sp)
ffffffffc020b2be:	7be2                	ld	s7,56(sp)
ffffffffc020b2c0:	7c42                	ld	s8,48(sp)
ffffffffc020b2c2:	7ca2                	ld	s9,40(sp)
ffffffffc020b2c4:	7d02                	ld	s10,32(sp)
ffffffffc020b2c6:	6de2                	ld	s11,24(sp)
ffffffffc020b2c8:	6109                	addi	sp,sp,128
ffffffffc020b2ca:	8082                	ret
ffffffffc020b2cc:	882e                	mv	a6,a1
ffffffffc020b2ce:	00144583          	lbu	a1,1(s0)
ffffffffc020b2d2:	846e                	mv	s0,s11
ffffffffc020b2d4:	00140d93          	addi	s11,s0,1
ffffffffc020b2d8:	fdd5861b          	addiw	a2,a1,-35
ffffffffc020b2dc:	0ff67613          	zext.b	a2,a2
ffffffffc020b2e0:	fcc572e3          	bgeu	a0,a2,ffffffffc020b2a4 <vprintfmt+0x78>
ffffffffc020b2e4:	864a                	mv	a2,s2
ffffffffc020b2e6:	85a6                	mv	a1,s1
ffffffffc020b2e8:	02500513          	li	a0,37
ffffffffc020b2ec:	9982                	jalr	s3
ffffffffc020b2ee:	fff44783          	lbu	a5,-1(s0)
ffffffffc020b2f2:	8da2                	mv	s11,s0
ffffffffc020b2f4:	f74786e3          	beq	a5,s4,ffffffffc020b260 <vprintfmt+0x34>
ffffffffc020b2f8:	ffedc783          	lbu	a5,-2(s11)
ffffffffc020b2fc:	1dfd                	addi	s11,s11,-1
ffffffffc020b2fe:	ff479de3          	bne	a5,s4,ffffffffc020b2f8 <vprintfmt+0xcc>
ffffffffc020b302:	bfb9                	j	ffffffffc020b260 <vprintfmt+0x34>
ffffffffc020b304:	fd058c9b          	addiw	s9,a1,-48
ffffffffc020b308:	00144583          	lbu	a1,1(s0)
ffffffffc020b30c:	846e                	mv	s0,s11
ffffffffc020b30e:	fd05869b          	addiw	a3,a1,-48
ffffffffc020b312:	0005861b          	sext.w	a2,a1
ffffffffc020b316:	02d8e463          	bltu	a7,a3,ffffffffc020b33e <vprintfmt+0x112>
ffffffffc020b31a:	00144583          	lbu	a1,1(s0)
ffffffffc020b31e:	002c969b          	slliw	a3,s9,0x2
ffffffffc020b322:	0196873b          	addw	a4,a3,s9
ffffffffc020b326:	0017171b          	slliw	a4,a4,0x1
ffffffffc020b32a:	9f31                	addw	a4,a4,a2
ffffffffc020b32c:	fd05869b          	addiw	a3,a1,-48
ffffffffc020b330:	0405                	addi	s0,s0,1
ffffffffc020b332:	fd070c9b          	addiw	s9,a4,-48
ffffffffc020b336:	0005861b          	sext.w	a2,a1
ffffffffc020b33a:	fed8f0e3          	bgeu	a7,a3,ffffffffc020b31a <vprintfmt+0xee>
ffffffffc020b33e:	f40c5be3          	bgez	s8,ffffffffc020b294 <vprintfmt+0x68>
ffffffffc020b342:	8c66                	mv	s8,s9
ffffffffc020b344:	5cfd                	li	s9,-1
ffffffffc020b346:	b7b9                	j	ffffffffc020b294 <vprintfmt+0x68>
ffffffffc020b348:	fffc4693          	not	a3,s8
ffffffffc020b34c:	96fd                	srai	a3,a3,0x3f
ffffffffc020b34e:	00dc77b3          	and	a5,s8,a3
ffffffffc020b352:	00144583          	lbu	a1,1(s0)
ffffffffc020b356:	00078c1b          	sext.w	s8,a5
ffffffffc020b35a:	846e                	mv	s0,s11
ffffffffc020b35c:	bf25                	j	ffffffffc020b294 <vprintfmt+0x68>
ffffffffc020b35e:	000aac83          	lw	s9,0(s5)
ffffffffc020b362:	00144583          	lbu	a1,1(s0)
ffffffffc020b366:	0aa1                	addi	s5,s5,8
ffffffffc020b368:	846e                	mv	s0,s11
ffffffffc020b36a:	bfd1                	j	ffffffffc020b33e <vprintfmt+0x112>
ffffffffc020b36c:	4705                	li	a4,1
ffffffffc020b36e:	008a8613          	addi	a2,s5,8
ffffffffc020b372:	00674463          	blt	a4,t1,ffffffffc020b37a <vprintfmt+0x14e>
ffffffffc020b376:	1c030c63          	beqz	t1,ffffffffc020b54e <vprintfmt+0x322>
ffffffffc020b37a:	000ab683          	ld	a3,0(s5)
ffffffffc020b37e:	4741                	li	a4,16
ffffffffc020b380:	8ab2                	mv	s5,a2
ffffffffc020b382:	2801                	sext.w	a6,a6
ffffffffc020b384:	87e2                	mv	a5,s8
ffffffffc020b386:	8626                	mv	a2,s1
ffffffffc020b388:	85ca                	mv	a1,s2
ffffffffc020b38a:	854e                	mv	a0,s3
ffffffffc020b38c:	e11ff0ef          	jal	ra,ffffffffc020b19c <printnum>
ffffffffc020b390:	bdc1                	j	ffffffffc020b260 <vprintfmt+0x34>
ffffffffc020b392:	000aa503          	lw	a0,0(s5)
ffffffffc020b396:	864a                	mv	a2,s2
ffffffffc020b398:	85a6                	mv	a1,s1
ffffffffc020b39a:	0aa1                	addi	s5,s5,8
ffffffffc020b39c:	9982                	jalr	s3
ffffffffc020b39e:	b5c9                	j	ffffffffc020b260 <vprintfmt+0x34>
ffffffffc020b3a0:	4705                	li	a4,1
ffffffffc020b3a2:	008a8613          	addi	a2,s5,8
ffffffffc020b3a6:	00674463          	blt	a4,t1,ffffffffc020b3ae <vprintfmt+0x182>
ffffffffc020b3aa:	18030d63          	beqz	t1,ffffffffc020b544 <vprintfmt+0x318>
ffffffffc020b3ae:	000ab683          	ld	a3,0(s5)
ffffffffc020b3b2:	4729                	li	a4,10
ffffffffc020b3b4:	8ab2                	mv	s5,a2
ffffffffc020b3b6:	b7f1                	j	ffffffffc020b382 <vprintfmt+0x156>
ffffffffc020b3b8:	00144583          	lbu	a1,1(s0)
ffffffffc020b3bc:	4d05                	li	s10,1
ffffffffc020b3be:	846e                	mv	s0,s11
ffffffffc020b3c0:	bdd1                	j	ffffffffc020b294 <vprintfmt+0x68>
ffffffffc020b3c2:	864a                	mv	a2,s2
ffffffffc020b3c4:	85a6                	mv	a1,s1
ffffffffc020b3c6:	02500513          	li	a0,37
ffffffffc020b3ca:	9982                	jalr	s3
ffffffffc020b3cc:	bd51                	j	ffffffffc020b260 <vprintfmt+0x34>
ffffffffc020b3ce:	00144583          	lbu	a1,1(s0)
ffffffffc020b3d2:	2305                	addiw	t1,t1,1
ffffffffc020b3d4:	846e                	mv	s0,s11
ffffffffc020b3d6:	bd7d                	j	ffffffffc020b294 <vprintfmt+0x68>
ffffffffc020b3d8:	4705                	li	a4,1
ffffffffc020b3da:	008a8613          	addi	a2,s5,8
ffffffffc020b3de:	00674463          	blt	a4,t1,ffffffffc020b3e6 <vprintfmt+0x1ba>
ffffffffc020b3e2:	14030c63          	beqz	t1,ffffffffc020b53a <vprintfmt+0x30e>
ffffffffc020b3e6:	000ab683          	ld	a3,0(s5)
ffffffffc020b3ea:	4721                	li	a4,8
ffffffffc020b3ec:	8ab2                	mv	s5,a2
ffffffffc020b3ee:	bf51                	j	ffffffffc020b382 <vprintfmt+0x156>
ffffffffc020b3f0:	03000513          	li	a0,48
ffffffffc020b3f4:	864a                	mv	a2,s2
ffffffffc020b3f6:	85a6                	mv	a1,s1
ffffffffc020b3f8:	e042                	sd	a6,0(sp)
ffffffffc020b3fa:	9982                	jalr	s3
ffffffffc020b3fc:	864a                	mv	a2,s2
ffffffffc020b3fe:	85a6                	mv	a1,s1
ffffffffc020b400:	07800513          	li	a0,120
ffffffffc020b404:	9982                	jalr	s3
ffffffffc020b406:	0aa1                	addi	s5,s5,8
ffffffffc020b408:	6802                	ld	a6,0(sp)
ffffffffc020b40a:	4741                	li	a4,16
ffffffffc020b40c:	ff8ab683          	ld	a3,-8(s5)
ffffffffc020b410:	bf8d                	j	ffffffffc020b382 <vprintfmt+0x156>
ffffffffc020b412:	000ab403          	ld	s0,0(s5)
ffffffffc020b416:	008a8793          	addi	a5,s5,8
ffffffffc020b41a:	e03e                	sd	a5,0(sp)
ffffffffc020b41c:	14040c63          	beqz	s0,ffffffffc020b574 <vprintfmt+0x348>
ffffffffc020b420:	11805063          	blez	s8,ffffffffc020b520 <vprintfmt+0x2f4>
ffffffffc020b424:	02d00693          	li	a3,45
ffffffffc020b428:	0cd81963          	bne	a6,a3,ffffffffc020b4fa <vprintfmt+0x2ce>
ffffffffc020b42c:	00044683          	lbu	a3,0(s0)
ffffffffc020b430:	0006851b          	sext.w	a0,a3
ffffffffc020b434:	ce8d                	beqz	a3,ffffffffc020b46e <vprintfmt+0x242>
ffffffffc020b436:	00140a93          	addi	s5,s0,1
ffffffffc020b43a:	05e00413          	li	s0,94
ffffffffc020b43e:	000cc563          	bltz	s9,ffffffffc020b448 <vprintfmt+0x21c>
ffffffffc020b442:	3cfd                	addiw	s9,s9,-1
ffffffffc020b444:	037c8363          	beq	s9,s7,ffffffffc020b46a <vprintfmt+0x23e>
ffffffffc020b448:	864a                	mv	a2,s2
ffffffffc020b44a:	85a6                	mv	a1,s1
ffffffffc020b44c:	100d0663          	beqz	s10,ffffffffc020b558 <vprintfmt+0x32c>
ffffffffc020b450:	3681                	addiw	a3,a3,-32
ffffffffc020b452:	10d47363          	bgeu	s0,a3,ffffffffc020b558 <vprintfmt+0x32c>
ffffffffc020b456:	03f00513          	li	a0,63
ffffffffc020b45a:	9982                	jalr	s3
ffffffffc020b45c:	000ac683          	lbu	a3,0(s5)
ffffffffc020b460:	3c7d                	addiw	s8,s8,-1
ffffffffc020b462:	0a85                	addi	s5,s5,1
ffffffffc020b464:	0006851b          	sext.w	a0,a3
ffffffffc020b468:	faf9                	bnez	a3,ffffffffc020b43e <vprintfmt+0x212>
ffffffffc020b46a:	01805a63          	blez	s8,ffffffffc020b47e <vprintfmt+0x252>
ffffffffc020b46e:	3c7d                	addiw	s8,s8,-1
ffffffffc020b470:	864a                	mv	a2,s2
ffffffffc020b472:	85a6                	mv	a1,s1
ffffffffc020b474:	02000513          	li	a0,32
ffffffffc020b478:	9982                	jalr	s3
ffffffffc020b47a:	fe0c1ae3          	bnez	s8,ffffffffc020b46e <vprintfmt+0x242>
ffffffffc020b47e:	6a82                	ld	s5,0(sp)
ffffffffc020b480:	b3c5                	j	ffffffffc020b260 <vprintfmt+0x34>
ffffffffc020b482:	4705                	li	a4,1
ffffffffc020b484:	008a8d13          	addi	s10,s5,8
ffffffffc020b488:	00674463          	blt	a4,t1,ffffffffc020b490 <vprintfmt+0x264>
ffffffffc020b48c:	0a030463          	beqz	t1,ffffffffc020b534 <vprintfmt+0x308>
ffffffffc020b490:	000ab403          	ld	s0,0(s5)
ffffffffc020b494:	0c044463          	bltz	s0,ffffffffc020b55c <vprintfmt+0x330>
ffffffffc020b498:	86a2                	mv	a3,s0
ffffffffc020b49a:	8aea                	mv	s5,s10
ffffffffc020b49c:	4729                	li	a4,10
ffffffffc020b49e:	b5d5                	j	ffffffffc020b382 <vprintfmt+0x156>
ffffffffc020b4a0:	000aa783          	lw	a5,0(s5)
ffffffffc020b4a4:	46e1                	li	a3,24
ffffffffc020b4a6:	0aa1                	addi	s5,s5,8
ffffffffc020b4a8:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc020b4ac:	8fb9                	xor	a5,a5,a4
ffffffffc020b4ae:	40e7873b          	subw	a4,a5,a4
ffffffffc020b4b2:	02e6c663          	blt	a3,a4,ffffffffc020b4de <vprintfmt+0x2b2>
ffffffffc020b4b6:	00371793          	slli	a5,a4,0x3
ffffffffc020b4ba:	00004697          	auipc	a3,0x4
ffffffffc020b4be:	36e68693          	addi	a3,a3,878 # ffffffffc020f828 <error_string>
ffffffffc020b4c2:	97b6                	add	a5,a5,a3
ffffffffc020b4c4:	639c                	ld	a5,0(a5)
ffffffffc020b4c6:	cf81                	beqz	a5,ffffffffc020b4de <vprintfmt+0x2b2>
ffffffffc020b4c8:	873e                	mv	a4,a5
ffffffffc020b4ca:	00000697          	auipc	a3,0x0
ffffffffc020b4ce:	18e68693          	addi	a3,a3,398 # ffffffffc020b658 <etext+0x2a>
ffffffffc020b4d2:	8626                	mv	a2,s1
ffffffffc020b4d4:	85ca                	mv	a1,s2
ffffffffc020b4d6:	854e                	mv	a0,s3
ffffffffc020b4d8:	0d4000ef          	jal	ra,ffffffffc020b5ac <printfmt>
ffffffffc020b4dc:	b351                	j	ffffffffc020b260 <vprintfmt+0x34>
ffffffffc020b4de:	00004697          	auipc	a3,0x4
ffffffffc020b4e2:	00a68693          	addi	a3,a3,10 # ffffffffc020f4e8 <sfs_node_fileops+0x1e0>
ffffffffc020b4e6:	8626                	mv	a2,s1
ffffffffc020b4e8:	85ca                	mv	a1,s2
ffffffffc020b4ea:	854e                	mv	a0,s3
ffffffffc020b4ec:	0c0000ef          	jal	ra,ffffffffc020b5ac <printfmt>
ffffffffc020b4f0:	bb85                	j	ffffffffc020b260 <vprintfmt+0x34>
ffffffffc020b4f2:	00004417          	auipc	s0,0x4
ffffffffc020b4f6:	fee40413          	addi	s0,s0,-18 # ffffffffc020f4e0 <sfs_node_fileops+0x1d8>
ffffffffc020b4fa:	85e6                	mv	a1,s9
ffffffffc020b4fc:	8522                	mv	a0,s0
ffffffffc020b4fe:	e442                	sd	a6,8(sp)
ffffffffc020b500:	babff0ef          	jal	ra,ffffffffc020b0aa <strnlen>
ffffffffc020b504:	40ac0c3b          	subw	s8,s8,a0
ffffffffc020b508:	01805c63          	blez	s8,ffffffffc020b520 <vprintfmt+0x2f4>
ffffffffc020b50c:	6822                	ld	a6,8(sp)
ffffffffc020b50e:	00080a9b          	sext.w	s5,a6
ffffffffc020b512:	3c7d                	addiw	s8,s8,-1
ffffffffc020b514:	864a                	mv	a2,s2
ffffffffc020b516:	85a6                	mv	a1,s1
ffffffffc020b518:	8556                	mv	a0,s5
ffffffffc020b51a:	9982                	jalr	s3
ffffffffc020b51c:	fe0c1be3          	bnez	s8,ffffffffc020b512 <vprintfmt+0x2e6>
ffffffffc020b520:	00044683          	lbu	a3,0(s0)
ffffffffc020b524:	00140a93          	addi	s5,s0,1
ffffffffc020b528:	0006851b          	sext.w	a0,a3
ffffffffc020b52c:	daa9                	beqz	a3,ffffffffc020b47e <vprintfmt+0x252>
ffffffffc020b52e:	05e00413          	li	s0,94
ffffffffc020b532:	b731                	j	ffffffffc020b43e <vprintfmt+0x212>
ffffffffc020b534:	000aa403          	lw	s0,0(s5)
ffffffffc020b538:	bfb1                	j	ffffffffc020b494 <vprintfmt+0x268>
ffffffffc020b53a:	000ae683          	lwu	a3,0(s5)
ffffffffc020b53e:	4721                	li	a4,8
ffffffffc020b540:	8ab2                	mv	s5,a2
ffffffffc020b542:	b581                	j	ffffffffc020b382 <vprintfmt+0x156>
ffffffffc020b544:	000ae683          	lwu	a3,0(s5)
ffffffffc020b548:	4729                	li	a4,10
ffffffffc020b54a:	8ab2                	mv	s5,a2
ffffffffc020b54c:	bd1d                	j	ffffffffc020b382 <vprintfmt+0x156>
ffffffffc020b54e:	000ae683          	lwu	a3,0(s5)
ffffffffc020b552:	4741                	li	a4,16
ffffffffc020b554:	8ab2                	mv	s5,a2
ffffffffc020b556:	b535                	j	ffffffffc020b382 <vprintfmt+0x156>
ffffffffc020b558:	9982                	jalr	s3
ffffffffc020b55a:	b709                	j	ffffffffc020b45c <vprintfmt+0x230>
ffffffffc020b55c:	864a                	mv	a2,s2
ffffffffc020b55e:	85a6                	mv	a1,s1
ffffffffc020b560:	02d00513          	li	a0,45
ffffffffc020b564:	e042                	sd	a6,0(sp)
ffffffffc020b566:	9982                	jalr	s3
ffffffffc020b568:	6802                	ld	a6,0(sp)
ffffffffc020b56a:	8aea                	mv	s5,s10
ffffffffc020b56c:	408006b3          	neg	a3,s0
ffffffffc020b570:	4729                	li	a4,10
ffffffffc020b572:	bd01                	j	ffffffffc020b382 <vprintfmt+0x156>
ffffffffc020b574:	03805163          	blez	s8,ffffffffc020b596 <vprintfmt+0x36a>
ffffffffc020b578:	02d00693          	li	a3,45
ffffffffc020b57c:	f6d81be3          	bne	a6,a3,ffffffffc020b4f2 <vprintfmt+0x2c6>
ffffffffc020b580:	00004417          	auipc	s0,0x4
ffffffffc020b584:	f6040413          	addi	s0,s0,-160 # ffffffffc020f4e0 <sfs_node_fileops+0x1d8>
ffffffffc020b588:	02800693          	li	a3,40
ffffffffc020b58c:	02800513          	li	a0,40
ffffffffc020b590:	00140a93          	addi	s5,s0,1
ffffffffc020b594:	b55d                	j	ffffffffc020b43a <vprintfmt+0x20e>
ffffffffc020b596:	00004a97          	auipc	s5,0x4
ffffffffc020b59a:	f4ba8a93          	addi	s5,s5,-181 # ffffffffc020f4e1 <sfs_node_fileops+0x1d9>
ffffffffc020b59e:	02800513          	li	a0,40
ffffffffc020b5a2:	02800693          	li	a3,40
ffffffffc020b5a6:	05e00413          	li	s0,94
ffffffffc020b5aa:	bd51                	j	ffffffffc020b43e <vprintfmt+0x212>

ffffffffc020b5ac <printfmt>:
ffffffffc020b5ac:	7139                	addi	sp,sp,-64
ffffffffc020b5ae:	02010313          	addi	t1,sp,32
ffffffffc020b5b2:	f03a                	sd	a4,32(sp)
ffffffffc020b5b4:	871a                	mv	a4,t1
ffffffffc020b5b6:	ec06                	sd	ra,24(sp)
ffffffffc020b5b8:	f43e                	sd	a5,40(sp)
ffffffffc020b5ba:	f842                	sd	a6,48(sp)
ffffffffc020b5bc:	fc46                	sd	a7,56(sp)
ffffffffc020b5be:	e41a                	sd	t1,8(sp)
ffffffffc020b5c0:	c6dff0ef          	jal	ra,ffffffffc020b22c <vprintfmt>
ffffffffc020b5c4:	60e2                	ld	ra,24(sp)
ffffffffc020b5c6:	6121                	addi	sp,sp,64
ffffffffc020b5c8:	8082                	ret

ffffffffc020b5ca <snprintf>:
ffffffffc020b5ca:	711d                	addi	sp,sp,-96
ffffffffc020b5cc:	15fd                	addi	a1,a1,-1
ffffffffc020b5ce:	03810313          	addi	t1,sp,56
ffffffffc020b5d2:	95aa                	add	a1,a1,a0
ffffffffc020b5d4:	f406                	sd	ra,40(sp)
ffffffffc020b5d6:	fc36                	sd	a3,56(sp)
ffffffffc020b5d8:	e0ba                	sd	a4,64(sp)
ffffffffc020b5da:	e4be                	sd	a5,72(sp)
ffffffffc020b5dc:	e8c2                	sd	a6,80(sp)
ffffffffc020b5de:	ecc6                	sd	a7,88(sp)
ffffffffc020b5e0:	e01a                	sd	t1,0(sp)
ffffffffc020b5e2:	e42a                	sd	a0,8(sp)
ffffffffc020b5e4:	e82e                	sd	a1,16(sp)
ffffffffc020b5e6:	cc02                	sw	zero,24(sp)
ffffffffc020b5e8:	c515                	beqz	a0,ffffffffc020b614 <snprintf+0x4a>
ffffffffc020b5ea:	02a5e563          	bltu	a1,a0,ffffffffc020b614 <snprintf+0x4a>
ffffffffc020b5ee:	75dd                	lui	a1,0xffff7
ffffffffc020b5f0:	86b2                	mv	a3,a2
ffffffffc020b5f2:	00000517          	auipc	a0,0x0
ffffffffc020b5f6:	c2050513          	addi	a0,a0,-992 # ffffffffc020b212 <sprintputch>
ffffffffc020b5fa:	871a                	mv	a4,t1
ffffffffc020b5fc:	0030                	addi	a2,sp,8
ffffffffc020b5fe:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <end+0x3fd601c9>
ffffffffc020b602:	c2bff0ef          	jal	ra,ffffffffc020b22c <vprintfmt>
ffffffffc020b606:	67a2                	ld	a5,8(sp)
ffffffffc020b608:	00078023          	sb	zero,0(a5)
ffffffffc020b60c:	4562                	lw	a0,24(sp)
ffffffffc020b60e:	70a2                	ld	ra,40(sp)
ffffffffc020b610:	6125                	addi	sp,sp,96
ffffffffc020b612:	8082                	ret
ffffffffc020b614:	5575                	li	a0,-3
ffffffffc020b616:	bfe5                	j	ffffffffc020b60e <snprintf+0x44>

ffffffffc020b618 <hash32>:
ffffffffc020b618:	9e3707b7          	lui	a5,0x9e370
ffffffffc020b61c:	2785                	addiw	a5,a5,1
ffffffffc020b61e:	02a7853b          	mulw	a0,a5,a0
ffffffffc020b622:	02000793          	li	a5,32
ffffffffc020b626:	9f8d                	subw	a5,a5,a1
ffffffffc020b628:	00f5553b          	srlw	a0,a0,a5
ffffffffc020b62c:	8082                	ret
