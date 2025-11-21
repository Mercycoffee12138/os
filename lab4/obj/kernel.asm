
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
ffffffffc0200000:	00009297          	auipc	t0,0x9
ffffffffc0200004:	00028293          	mv	t0,t0
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0209000 <boot_hartid>
ffffffffc020000c:	00009297          	auipc	t0,0x9
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0209008 <boot_dtb>
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
ffffffffc0200018:	c02082b7          	lui	t0,0xc0208
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
ffffffffc0200034:	18029073          	csrw	satp,t0
ffffffffc0200038:	12000073          	sfence.vma
ffffffffc020003c:	c0208137          	lui	sp,0xc0208
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
ffffffffc0200044:	04a28293          	addi	t0,t0,74 # ffffffffc020004a <kern_init>
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <kern_init>:
ffffffffc020004a:	00009517          	auipc	a0,0x9
ffffffffc020004e:	fe650513          	addi	a0,a0,-26 # ffffffffc0209030 <buf>
ffffffffc0200052:	0000d617          	auipc	a2,0xd
ffffffffc0200056:	49a60613          	addi	a2,a2,1178 # ffffffffc020d4ec <end>
ffffffffc020005a:	1141                	addi	sp,sp,-16
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
ffffffffc0200060:	e406                	sd	ra,8(sp)
ffffffffc0200062:	60f030ef          	jal	ra,ffffffffc0203e70 <memset>
ffffffffc0200066:	514000ef          	jal	ra,ffffffffc020057a <dtb_init>
ffffffffc020006a:	49e000ef          	jal	ra,ffffffffc0200508 <cons_init>
ffffffffc020006e:	00004597          	auipc	a1,0x4
ffffffffc0200072:	e5258593          	addi	a1,a1,-430 # ffffffffc0203ec0 <etext+0x2>
ffffffffc0200076:	00004517          	auipc	a0,0x4
ffffffffc020007a:	e6a50513          	addi	a0,a0,-406 # ffffffffc0203ee0 <etext+0x22>
ffffffffc020007e:	116000ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200082:	15a000ef          	jal	ra,ffffffffc02001dc <print_kerninfo>
ffffffffc0200086:	0d8020ef          	jal	ra,ffffffffc020215e <pmm_init>
ffffffffc020008a:	0ad000ef          	jal	ra,ffffffffc0200936 <pic_init>
ffffffffc020008e:	0ab000ef          	jal	ra,ffffffffc0200938 <idt_init>
ffffffffc0200092:	641020ef          	jal	ra,ffffffffc0202ed2 <vmm_init>
ffffffffc0200096:	59a030ef          	jal	ra,ffffffffc0203630 <proc_init>
ffffffffc020009a:	41c000ef          	jal	ra,ffffffffc02004b6 <clock_init>
ffffffffc020009e:	08d000ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc02000a2:	7dc030ef          	jal	ra,ffffffffc020387e <cpu_idle>

ffffffffc02000a6 <readline>:
ffffffffc02000a6:	715d                	addi	sp,sp,-80
ffffffffc02000a8:	e486                	sd	ra,72(sp)
ffffffffc02000aa:	e0a6                	sd	s1,64(sp)
ffffffffc02000ac:	fc4a                	sd	s2,56(sp)
ffffffffc02000ae:	f84e                	sd	s3,48(sp)
ffffffffc02000b0:	f452                	sd	s4,40(sp)
ffffffffc02000b2:	f056                	sd	s5,32(sp)
ffffffffc02000b4:	ec5a                	sd	s6,24(sp)
ffffffffc02000b6:	e85e                	sd	s7,16(sp)
ffffffffc02000b8:	c901                	beqz	a0,ffffffffc02000c8 <readline+0x22>
ffffffffc02000ba:	85aa                	mv	a1,a0
ffffffffc02000bc:	00004517          	auipc	a0,0x4
ffffffffc02000c0:	e2c50513          	addi	a0,a0,-468 # ffffffffc0203ee8 <etext+0x2a>
ffffffffc02000c4:	0d0000ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02000c8:	4481                	li	s1,0
ffffffffc02000ca:	497d                	li	s2,31
ffffffffc02000cc:	49a1                	li	s3,8
ffffffffc02000ce:	4aa9                	li	s5,10
ffffffffc02000d0:	4b35                	li	s6,13
ffffffffc02000d2:	00009b97          	auipc	s7,0x9
ffffffffc02000d6:	f5eb8b93          	addi	s7,s7,-162 # ffffffffc0209030 <buf>
ffffffffc02000da:	3fe00a13          	li	s4,1022
ffffffffc02000de:	0ee000ef          	jal	ra,ffffffffc02001cc <getchar>
ffffffffc02000e2:	00054a63          	bltz	a0,ffffffffc02000f6 <readline+0x50>
ffffffffc02000e6:	00a95a63          	bge	s2,a0,ffffffffc02000fa <readline+0x54>
ffffffffc02000ea:	029a5263          	bge	s4,s1,ffffffffc020010e <readline+0x68>
ffffffffc02000ee:	0de000ef          	jal	ra,ffffffffc02001cc <getchar>
ffffffffc02000f2:	fe055ae3          	bgez	a0,ffffffffc02000e6 <readline+0x40>
ffffffffc02000f6:	4501                	li	a0,0
ffffffffc02000f8:	a091                	j	ffffffffc020013c <readline+0x96>
ffffffffc02000fa:	03351463          	bne	a0,s3,ffffffffc0200122 <readline+0x7c>
ffffffffc02000fe:	e8a9                	bnez	s1,ffffffffc0200150 <readline+0xaa>
ffffffffc0200100:	0cc000ef          	jal	ra,ffffffffc02001cc <getchar>
ffffffffc0200104:	fe0549e3          	bltz	a0,ffffffffc02000f6 <readline+0x50>
ffffffffc0200108:	fea959e3          	bge	s2,a0,ffffffffc02000fa <readline+0x54>
ffffffffc020010c:	4481                	li	s1,0
ffffffffc020010e:	e42a                	sd	a0,8(sp)
ffffffffc0200110:	0ba000ef          	jal	ra,ffffffffc02001ca <cputchar>
ffffffffc0200114:	6522                	ld	a0,8(sp)
ffffffffc0200116:	009b87b3          	add	a5,s7,s1
ffffffffc020011a:	2485                	addiw	s1,s1,1
ffffffffc020011c:	00a78023          	sb	a0,0(a5)
ffffffffc0200120:	bf7d                	j	ffffffffc02000de <readline+0x38>
ffffffffc0200122:	01550463          	beq	a0,s5,ffffffffc020012a <readline+0x84>
ffffffffc0200126:	fb651ce3          	bne	a0,s6,ffffffffc02000de <readline+0x38>
ffffffffc020012a:	0a0000ef          	jal	ra,ffffffffc02001ca <cputchar>
ffffffffc020012e:	00009517          	auipc	a0,0x9
ffffffffc0200132:	f0250513          	addi	a0,a0,-254 # ffffffffc0209030 <buf>
ffffffffc0200136:	94aa                	add	s1,s1,a0
ffffffffc0200138:	00048023          	sb	zero,0(s1)
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
ffffffffc0200150:	4521                	li	a0,8
ffffffffc0200152:	078000ef          	jal	ra,ffffffffc02001ca <cputchar>
ffffffffc0200156:	34fd                	addiw	s1,s1,-1
ffffffffc0200158:	b759                	j	ffffffffc02000de <readline+0x38>

ffffffffc020015a <cputch>:
ffffffffc020015a:	1141                	addi	sp,sp,-16
ffffffffc020015c:	e022                	sd	s0,0(sp)
ffffffffc020015e:	e406                	sd	ra,8(sp)
ffffffffc0200160:	842e                	mv	s0,a1
ffffffffc0200162:	3a8000ef          	jal	ra,ffffffffc020050a <cons_putc>
ffffffffc0200166:	401c                	lw	a5,0(s0)
ffffffffc0200168:	60a2                	ld	ra,8(sp)
ffffffffc020016a:	2785                	addiw	a5,a5,1
ffffffffc020016c:	c01c                	sw	a5,0(s0)
ffffffffc020016e:	6402                	ld	s0,0(sp)
ffffffffc0200170:	0141                	addi	sp,sp,16
ffffffffc0200172:	8082                	ret

ffffffffc0200174 <vcprintf>:
ffffffffc0200174:	1101                	addi	sp,sp,-32
ffffffffc0200176:	862a                	mv	a2,a0
ffffffffc0200178:	86ae                	mv	a3,a1
ffffffffc020017a:	00000517          	auipc	a0,0x0
ffffffffc020017e:	fe050513          	addi	a0,a0,-32 # ffffffffc020015a <cputch>
ffffffffc0200182:	006c                	addi	a1,sp,12
ffffffffc0200184:	ec06                	sd	ra,24(sp)
ffffffffc0200186:	c602                	sw	zero,12(sp)
ffffffffc0200188:	0c5030ef          	jal	ra,ffffffffc0203a4c <vprintfmt>
ffffffffc020018c:	60e2                	ld	ra,24(sp)
ffffffffc020018e:	4532                	lw	a0,12(sp)
ffffffffc0200190:	6105                	addi	sp,sp,32
ffffffffc0200192:	8082                	ret

ffffffffc0200194 <cprintf>:
ffffffffc0200194:	711d                	addi	sp,sp,-96
ffffffffc0200196:	02810313          	addi	t1,sp,40 # ffffffffc0208028 <boot_page_table_sv39+0x28>
ffffffffc020019a:	8e2a                	mv	t3,a0
ffffffffc020019c:	f42e                	sd	a1,40(sp)
ffffffffc020019e:	f832                	sd	a2,48(sp)
ffffffffc02001a0:	fc36                	sd	a3,56(sp)
ffffffffc02001a2:	00000517          	auipc	a0,0x0
ffffffffc02001a6:	fb850513          	addi	a0,a0,-72 # ffffffffc020015a <cputch>
ffffffffc02001aa:	004c                	addi	a1,sp,4
ffffffffc02001ac:	869a                	mv	a3,t1
ffffffffc02001ae:	8672                	mv	a2,t3
ffffffffc02001b0:	ec06                	sd	ra,24(sp)
ffffffffc02001b2:	e0ba                	sd	a4,64(sp)
ffffffffc02001b4:	e4be                	sd	a5,72(sp)
ffffffffc02001b6:	e8c2                	sd	a6,80(sp)
ffffffffc02001b8:	ecc6                	sd	a7,88(sp)
ffffffffc02001ba:	e41a                	sd	t1,8(sp)
ffffffffc02001bc:	c202                	sw	zero,4(sp)
ffffffffc02001be:	08f030ef          	jal	ra,ffffffffc0203a4c <vprintfmt>
ffffffffc02001c2:	60e2                	ld	ra,24(sp)
ffffffffc02001c4:	4512                	lw	a0,4(sp)
ffffffffc02001c6:	6125                	addi	sp,sp,96
ffffffffc02001c8:	8082                	ret

ffffffffc02001ca <cputchar>:
ffffffffc02001ca:	a681                	j	ffffffffc020050a <cons_putc>

ffffffffc02001cc <getchar>:
ffffffffc02001cc:	1141                	addi	sp,sp,-16
ffffffffc02001ce:	e406                	sd	ra,8(sp)
ffffffffc02001d0:	36e000ef          	jal	ra,ffffffffc020053e <cons_getc>
ffffffffc02001d4:	dd75                	beqz	a0,ffffffffc02001d0 <getchar+0x4>
ffffffffc02001d6:	60a2                	ld	ra,8(sp)
ffffffffc02001d8:	0141                	addi	sp,sp,16
ffffffffc02001da:	8082                	ret

ffffffffc02001dc <print_kerninfo>:
ffffffffc02001dc:	1141                	addi	sp,sp,-16
ffffffffc02001de:	00004517          	auipc	a0,0x4
ffffffffc02001e2:	d1250513          	addi	a0,a0,-750 # ffffffffc0203ef0 <etext+0x32>
ffffffffc02001e6:	e406                	sd	ra,8(sp)
ffffffffc02001e8:	fadff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02001ec:	00000597          	auipc	a1,0x0
ffffffffc02001f0:	e5e58593          	addi	a1,a1,-418 # ffffffffc020004a <kern_init>
ffffffffc02001f4:	00004517          	auipc	a0,0x4
ffffffffc02001f8:	d1c50513          	addi	a0,a0,-740 # ffffffffc0203f10 <etext+0x52>
ffffffffc02001fc:	f99ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200200:	00004597          	auipc	a1,0x4
ffffffffc0200204:	cbe58593          	addi	a1,a1,-834 # ffffffffc0203ebe <etext>
ffffffffc0200208:	00004517          	auipc	a0,0x4
ffffffffc020020c:	d2850513          	addi	a0,a0,-728 # ffffffffc0203f30 <etext+0x72>
ffffffffc0200210:	f85ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200214:	00009597          	auipc	a1,0x9
ffffffffc0200218:	e1c58593          	addi	a1,a1,-484 # ffffffffc0209030 <buf>
ffffffffc020021c:	00004517          	auipc	a0,0x4
ffffffffc0200220:	d3450513          	addi	a0,a0,-716 # ffffffffc0203f50 <etext+0x92>
ffffffffc0200224:	f71ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200228:	0000d597          	auipc	a1,0xd
ffffffffc020022c:	2c458593          	addi	a1,a1,708 # ffffffffc020d4ec <end>
ffffffffc0200230:	00004517          	auipc	a0,0x4
ffffffffc0200234:	d4050513          	addi	a0,a0,-704 # ffffffffc0203f70 <etext+0xb2>
ffffffffc0200238:	f5dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc020023c:	0000d597          	auipc	a1,0xd
ffffffffc0200240:	6af58593          	addi	a1,a1,1711 # ffffffffc020d8eb <end+0x3ff>
ffffffffc0200244:	00000797          	auipc	a5,0x0
ffffffffc0200248:	e0678793          	addi	a5,a5,-506 # ffffffffc020004a <kern_init>
ffffffffc020024c:	40f587b3          	sub	a5,a1,a5
ffffffffc0200250:	43f7d593          	srai	a1,a5,0x3f
ffffffffc0200254:	60a2                	ld	ra,8(sp)
ffffffffc0200256:	3ff5f593          	andi	a1,a1,1023
ffffffffc020025a:	95be                	add	a1,a1,a5
ffffffffc020025c:	85a9                	srai	a1,a1,0xa
ffffffffc020025e:	00004517          	auipc	a0,0x4
ffffffffc0200262:	d3250513          	addi	a0,a0,-718 # ffffffffc0203f90 <etext+0xd2>
ffffffffc0200266:	0141                	addi	sp,sp,16
ffffffffc0200268:	b735                	j	ffffffffc0200194 <cprintf>

ffffffffc020026a <print_stackframe>:
ffffffffc020026a:	1141                	addi	sp,sp,-16
ffffffffc020026c:	00004617          	auipc	a2,0x4
ffffffffc0200270:	d5460613          	addi	a2,a2,-684 # ffffffffc0203fc0 <etext+0x102>
ffffffffc0200274:	04900593          	li	a1,73
ffffffffc0200278:	00004517          	auipc	a0,0x4
ffffffffc020027c:	d6050513          	addi	a0,a0,-672 # ffffffffc0203fd8 <etext+0x11a>
ffffffffc0200280:	e406                	sd	ra,8(sp)
ffffffffc0200282:	1d8000ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0200286 <mon_help>:
ffffffffc0200286:	1141                	addi	sp,sp,-16
ffffffffc0200288:	00004617          	auipc	a2,0x4
ffffffffc020028c:	d6860613          	addi	a2,a2,-664 # ffffffffc0203ff0 <etext+0x132>
ffffffffc0200290:	00004597          	auipc	a1,0x4
ffffffffc0200294:	d8058593          	addi	a1,a1,-640 # ffffffffc0204010 <etext+0x152>
ffffffffc0200298:	00004517          	auipc	a0,0x4
ffffffffc020029c:	d8050513          	addi	a0,a0,-640 # ffffffffc0204018 <etext+0x15a>
ffffffffc02002a0:	e406                	sd	ra,8(sp)
ffffffffc02002a2:	ef3ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02002a6:	00004617          	auipc	a2,0x4
ffffffffc02002aa:	d8260613          	addi	a2,a2,-638 # ffffffffc0204028 <etext+0x16a>
ffffffffc02002ae:	00004597          	auipc	a1,0x4
ffffffffc02002b2:	da258593          	addi	a1,a1,-606 # ffffffffc0204050 <etext+0x192>
ffffffffc02002b6:	00004517          	auipc	a0,0x4
ffffffffc02002ba:	d6250513          	addi	a0,a0,-670 # ffffffffc0204018 <etext+0x15a>
ffffffffc02002be:	ed7ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02002c2:	00004617          	auipc	a2,0x4
ffffffffc02002c6:	d9e60613          	addi	a2,a2,-610 # ffffffffc0204060 <etext+0x1a2>
ffffffffc02002ca:	00004597          	auipc	a1,0x4
ffffffffc02002ce:	db658593          	addi	a1,a1,-586 # ffffffffc0204080 <etext+0x1c2>
ffffffffc02002d2:	00004517          	auipc	a0,0x4
ffffffffc02002d6:	d4650513          	addi	a0,a0,-698 # ffffffffc0204018 <etext+0x15a>
ffffffffc02002da:	ebbff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02002de:	60a2                	ld	ra,8(sp)
ffffffffc02002e0:	4501                	li	a0,0
ffffffffc02002e2:	0141                	addi	sp,sp,16
ffffffffc02002e4:	8082                	ret

ffffffffc02002e6 <mon_kerninfo>:
ffffffffc02002e6:	1141                	addi	sp,sp,-16
ffffffffc02002e8:	e406                	sd	ra,8(sp)
ffffffffc02002ea:	ef3ff0ef          	jal	ra,ffffffffc02001dc <print_kerninfo>
ffffffffc02002ee:	60a2                	ld	ra,8(sp)
ffffffffc02002f0:	4501                	li	a0,0
ffffffffc02002f2:	0141                	addi	sp,sp,16
ffffffffc02002f4:	8082                	ret

ffffffffc02002f6 <mon_backtrace>:
ffffffffc02002f6:	1141                	addi	sp,sp,-16
ffffffffc02002f8:	e406                	sd	ra,8(sp)
ffffffffc02002fa:	f71ff0ef          	jal	ra,ffffffffc020026a <print_stackframe>
ffffffffc02002fe:	60a2                	ld	ra,8(sp)
ffffffffc0200300:	4501                	li	a0,0
ffffffffc0200302:	0141                	addi	sp,sp,16
ffffffffc0200304:	8082                	ret

ffffffffc0200306 <kmonitor>:
ffffffffc0200306:	7115                	addi	sp,sp,-224
ffffffffc0200308:	ed5e                	sd	s7,152(sp)
ffffffffc020030a:	8baa                	mv	s7,a0
ffffffffc020030c:	00004517          	auipc	a0,0x4
ffffffffc0200310:	d8450513          	addi	a0,a0,-636 # ffffffffc0204090 <etext+0x1d2>
ffffffffc0200314:	ed86                	sd	ra,216(sp)
ffffffffc0200316:	e9a2                	sd	s0,208(sp)
ffffffffc0200318:	e5a6                	sd	s1,200(sp)
ffffffffc020031a:	e1ca                	sd	s2,192(sp)
ffffffffc020031c:	fd4e                	sd	s3,184(sp)
ffffffffc020031e:	f952                	sd	s4,176(sp)
ffffffffc0200320:	f556                	sd	s5,168(sp)
ffffffffc0200322:	f15a                	sd	s6,160(sp)
ffffffffc0200324:	e962                	sd	s8,144(sp)
ffffffffc0200326:	e566                	sd	s9,136(sp)
ffffffffc0200328:	e16a                	sd	s10,128(sp)
ffffffffc020032a:	e6bff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc020032e:	00004517          	auipc	a0,0x4
ffffffffc0200332:	d8a50513          	addi	a0,a0,-630 # ffffffffc02040b8 <etext+0x1fa>
ffffffffc0200336:	e5fff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc020033a:	000b8563          	beqz	s7,ffffffffc0200344 <kmonitor+0x3e>
ffffffffc020033e:	855e                	mv	a0,s7
ffffffffc0200340:	7e0000ef          	jal	ra,ffffffffc0200b20 <print_trapframe>
ffffffffc0200344:	4501                	li	a0,0
ffffffffc0200346:	4581                	li	a1,0
ffffffffc0200348:	4601                	li	a2,0
ffffffffc020034a:	48a1                	li	a7,8
ffffffffc020034c:	00000073          	ecall
ffffffffc0200350:	00004c17          	auipc	s8,0x4
ffffffffc0200354:	dd8c0c13          	addi	s8,s8,-552 # ffffffffc0204128 <commands>
ffffffffc0200358:	00004917          	auipc	s2,0x4
ffffffffc020035c:	d8890913          	addi	s2,s2,-632 # ffffffffc02040e0 <etext+0x222>
ffffffffc0200360:	00004497          	auipc	s1,0x4
ffffffffc0200364:	d8848493          	addi	s1,s1,-632 # ffffffffc02040e8 <etext+0x22a>
ffffffffc0200368:	49bd                	li	s3,15
ffffffffc020036a:	00004b17          	auipc	s6,0x4
ffffffffc020036e:	d86b0b13          	addi	s6,s6,-634 # ffffffffc02040f0 <etext+0x232>
ffffffffc0200372:	00004a17          	auipc	s4,0x4
ffffffffc0200376:	c9ea0a13          	addi	s4,s4,-866 # ffffffffc0204010 <etext+0x152>
ffffffffc020037a:	4a8d                	li	s5,3
ffffffffc020037c:	854a                	mv	a0,s2
ffffffffc020037e:	d29ff0ef          	jal	ra,ffffffffc02000a6 <readline>
ffffffffc0200382:	842a                	mv	s0,a0
ffffffffc0200384:	dd65                	beqz	a0,ffffffffc020037c <kmonitor+0x76>
ffffffffc0200386:	00054583          	lbu	a1,0(a0)
ffffffffc020038a:	4c81                	li	s9,0
ffffffffc020038c:	e1bd                	bnez	a1,ffffffffc02003f2 <kmonitor+0xec>
ffffffffc020038e:	fe0c87e3          	beqz	s9,ffffffffc020037c <kmonitor+0x76>
ffffffffc0200392:	6582                	ld	a1,0(sp)
ffffffffc0200394:	00004d17          	auipc	s10,0x4
ffffffffc0200398:	d94d0d13          	addi	s10,s10,-620 # ffffffffc0204128 <commands>
ffffffffc020039c:	8552                	mv	a0,s4
ffffffffc020039e:	4401                	li	s0,0
ffffffffc02003a0:	0d61                	addi	s10,s10,24
ffffffffc02003a2:	275030ef          	jal	ra,ffffffffc0203e16 <strcmp>
ffffffffc02003a6:	c919                	beqz	a0,ffffffffc02003bc <kmonitor+0xb6>
ffffffffc02003a8:	2405                	addiw	s0,s0,1
ffffffffc02003aa:	0b540063          	beq	s0,s5,ffffffffc020044a <kmonitor+0x144>
ffffffffc02003ae:	000d3503          	ld	a0,0(s10)
ffffffffc02003b2:	6582                	ld	a1,0(sp)
ffffffffc02003b4:	0d61                	addi	s10,s10,24
ffffffffc02003b6:	261030ef          	jal	ra,ffffffffc0203e16 <strcmp>
ffffffffc02003ba:	f57d                	bnez	a0,ffffffffc02003a8 <kmonitor+0xa2>
ffffffffc02003bc:	00141793          	slli	a5,s0,0x1
ffffffffc02003c0:	97a2                	add	a5,a5,s0
ffffffffc02003c2:	078e                	slli	a5,a5,0x3
ffffffffc02003c4:	97e2                	add	a5,a5,s8
ffffffffc02003c6:	6b9c                	ld	a5,16(a5)
ffffffffc02003c8:	865e                	mv	a2,s7
ffffffffc02003ca:	002c                	addi	a1,sp,8
ffffffffc02003cc:	fffc851b          	addiw	a0,s9,-1
ffffffffc02003d0:	9782                	jalr	a5
ffffffffc02003d2:	fa0555e3          	bgez	a0,ffffffffc020037c <kmonitor+0x76>
ffffffffc02003d6:	60ee                	ld	ra,216(sp)
ffffffffc02003d8:	644e                	ld	s0,208(sp)
ffffffffc02003da:	64ae                	ld	s1,200(sp)
ffffffffc02003dc:	690e                	ld	s2,192(sp)
ffffffffc02003de:	79ea                	ld	s3,184(sp)
ffffffffc02003e0:	7a4a                	ld	s4,176(sp)
ffffffffc02003e2:	7aaa                	ld	s5,168(sp)
ffffffffc02003e4:	7b0a                	ld	s6,160(sp)
ffffffffc02003e6:	6bea                	ld	s7,152(sp)
ffffffffc02003e8:	6c4a                	ld	s8,144(sp)
ffffffffc02003ea:	6caa                	ld	s9,136(sp)
ffffffffc02003ec:	6d0a                	ld	s10,128(sp)
ffffffffc02003ee:	612d                	addi	sp,sp,224
ffffffffc02003f0:	8082                	ret
ffffffffc02003f2:	8526                	mv	a0,s1
ffffffffc02003f4:	267030ef          	jal	ra,ffffffffc0203e5a <strchr>
ffffffffc02003f8:	c901                	beqz	a0,ffffffffc0200408 <kmonitor+0x102>
ffffffffc02003fa:	00144583          	lbu	a1,1(s0)
ffffffffc02003fe:	00040023          	sb	zero,0(s0)
ffffffffc0200402:	0405                	addi	s0,s0,1
ffffffffc0200404:	d5c9                	beqz	a1,ffffffffc020038e <kmonitor+0x88>
ffffffffc0200406:	b7f5                	j	ffffffffc02003f2 <kmonitor+0xec>
ffffffffc0200408:	00044783          	lbu	a5,0(s0)
ffffffffc020040c:	d3c9                	beqz	a5,ffffffffc020038e <kmonitor+0x88>
ffffffffc020040e:	033c8963          	beq	s9,s3,ffffffffc0200440 <kmonitor+0x13a>
ffffffffc0200412:	003c9793          	slli	a5,s9,0x3
ffffffffc0200416:	0118                	addi	a4,sp,128
ffffffffc0200418:	97ba                	add	a5,a5,a4
ffffffffc020041a:	f887b023          	sd	s0,-128(a5)
ffffffffc020041e:	00044583          	lbu	a1,0(s0)
ffffffffc0200422:	2c85                	addiw	s9,s9,1
ffffffffc0200424:	e591                	bnez	a1,ffffffffc0200430 <kmonitor+0x12a>
ffffffffc0200426:	b7b5                	j	ffffffffc0200392 <kmonitor+0x8c>
ffffffffc0200428:	00144583          	lbu	a1,1(s0)
ffffffffc020042c:	0405                	addi	s0,s0,1
ffffffffc020042e:	d1a5                	beqz	a1,ffffffffc020038e <kmonitor+0x88>
ffffffffc0200430:	8526                	mv	a0,s1
ffffffffc0200432:	229030ef          	jal	ra,ffffffffc0203e5a <strchr>
ffffffffc0200436:	d96d                	beqz	a0,ffffffffc0200428 <kmonitor+0x122>
ffffffffc0200438:	00044583          	lbu	a1,0(s0)
ffffffffc020043c:	d9a9                	beqz	a1,ffffffffc020038e <kmonitor+0x88>
ffffffffc020043e:	bf55                	j	ffffffffc02003f2 <kmonitor+0xec>
ffffffffc0200440:	45c1                	li	a1,16
ffffffffc0200442:	855a                	mv	a0,s6
ffffffffc0200444:	d51ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200448:	b7e9                	j	ffffffffc0200412 <kmonitor+0x10c>
ffffffffc020044a:	6582                	ld	a1,0(sp)
ffffffffc020044c:	00004517          	auipc	a0,0x4
ffffffffc0200450:	cc450513          	addi	a0,a0,-828 # ffffffffc0204110 <etext+0x252>
ffffffffc0200454:	d41ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200458:	b715                	j	ffffffffc020037c <kmonitor+0x76>

ffffffffc020045a <__panic>:
ffffffffc020045a:	0000d317          	auipc	t1,0xd
ffffffffc020045e:	00e30313          	addi	t1,t1,14 # ffffffffc020d468 <is_panic>
ffffffffc0200462:	00032e03          	lw	t3,0(t1)
ffffffffc0200466:	715d                	addi	sp,sp,-80
ffffffffc0200468:	ec06                	sd	ra,24(sp)
ffffffffc020046a:	e822                	sd	s0,16(sp)
ffffffffc020046c:	f436                	sd	a3,40(sp)
ffffffffc020046e:	f83a                	sd	a4,48(sp)
ffffffffc0200470:	fc3e                	sd	a5,56(sp)
ffffffffc0200472:	e0c2                	sd	a6,64(sp)
ffffffffc0200474:	e4c6                	sd	a7,72(sp)
ffffffffc0200476:	020e1a63          	bnez	t3,ffffffffc02004aa <__panic+0x50>
ffffffffc020047a:	4785                	li	a5,1
ffffffffc020047c:	00f32023          	sw	a5,0(t1)
ffffffffc0200480:	8432                	mv	s0,a2
ffffffffc0200482:	103c                	addi	a5,sp,40
ffffffffc0200484:	862e                	mv	a2,a1
ffffffffc0200486:	85aa                	mv	a1,a0
ffffffffc0200488:	00004517          	auipc	a0,0x4
ffffffffc020048c:	ce850513          	addi	a0,a0,-792 # ffffffffc0204170 <commands+0x48>
ffffffffc0200490:	e43e                	sd	a5,8(sp)
ffffffffc0200492:	d03ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200496:	65a2                	ld	a1,8(sp)
ffffffffc0200498:	8522                	mv	a0,s0
ffffffffc020049a:	cdbff0ef          	jal	ra,ffffffffc0200174 <vcprintf>
ffffffffc020049e:	00005517          	auipc	a0,0x5
ffffffffc02004a2:	d8250513          	addi	a0,a0,-638 # ffffffffc0205220 <default_pmm_manager+0x530>
ffffffffc02004a6:	cefff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02004aa:	486000ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc02004ae:	4501                	li	a0,0
ffffffffc02004b0:	e57ff0ef          	jal	ra,ffffffffc0200306 <kmonitor>
ffffffffc02004b4:	bfed                	j	ffffffffc02004ae <__panic+0x54>

ffffffffc02004b6 <clock_init>:
ffffffffc02004b6:	67e1                	lui	a5,0x18
ffffffffc02004b8:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02004bc:	0000d717          	auipc	a4,0xd
ffffffffc02004c0:	faf73e23          	sd	a5,-68(a4) # ffffffffc020d478 <timebase>
ffffffffc02004c4:	c0102573          	rdtime	a0
ffffffffc02004c8:	4581                	li	a1,0
ffffffffc02004ca:	953e                	add	a0,a0,a5
ffffffffc02004cc:	4601                	li	a2,0
ffffffffc02004ce:	4881                	li	a7,0
ffffffffc02004d0:	00000073          	ecall
ffffffffc02004d4:	02000793          	li	a5,32
ffffffffc02004d8:	1047a7f3          	csrrs	a5,sie,a5
ffffffffc02004dc:	00004517          	auipc	a0,0x4
ffffffffc02004e0:	cb450513          	addi	a0,a0,-844 # ffffffffc0204190 <commands+0x68>
ffffffffc02004e4:	0000d797          	auipc	a5,0xd
ffffffffc02004e8:	f807b623          	sd	zero,-116(a5) # ffffffffc020d470 <ticks>
ffffffffc02004ec:	b165                	j	ffffffffc0200194 <cprintf>

ffffffffc02004ee <clock_set_next_event>:
ffffffffc02004ee:	c0102573          	rdtime	a0
ffffffffc02004f2:	0000d797          	auipc	a5,0xd
ffffffffc02004f6:	f867b783          	ld	a5,-122(a5) # ffffffffc020d478 <timebase>
ffffffffc02004fa:	953e                	add	a0,a0,a5
ffffffffc02004fc:	4581                	li	a1,0
ffffffffc02004fe:	4601                	li	a2,0
ffffffffc0200500:	4881                	li	a7,0
ffffffffc0200502:	00000073          	ecall
ffffffffc0200506:	8082                	ret

ffffffffc0200508 <cons_init>:
ffffffffc0200508:	8082                	ret

ffffffffc020050a <cons_putc>:
ffffffffc020050a:	100027f3          	csrr	a5,sstatus
ffffffffc020050e:	8b89                	andi	a5,a5,2
ffffffffc0200510:	0ff57513          	zext.b	a0,a0
ffffffffc0200514:	e799                	bnez	a5,ffffffffc0200522 <cons_putc+0x18>
ffffffffc0200516:	4581                	li	a1,0
ffffffffc0200518:	4601                	li	a2,0
ffffffffc020051a:	4885                	li	a7,1
ffffffffc020051c:	00000073          	ecall
ffffffffc0200520:	8082                	ret
ffffffffc0200522:	1101                	addi	sp,sp,-32
ffffffffc0200524:	ec06                	sd	ra,24(sp)
ffffffffc0200526:	e42a                	sd	a0,8(sp)
ffffffffc0200528:	408000ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc020052c:	6522                	ld	a0,8(sp)
ffffffffc020052e:	4581                	li	a1,0
ffffffffc0200530:	4601                	li	a2,0
ffffffffc0200532:	4885                	li	a7,1
ffffffffc0200534:	00000073          	ecall
ffffffffc0200538:	60e2                	ld	ra,24(sp)
ffffffffc020053a:	6105                	addi	sp,sp,32
ffffffffc020053c:	a6fd                	j	ffffffffc020092a <intr_enable>

ffffffffc020053e <cons_getc>:
ffffffffc020053e:	100027f3          	csrr	a5,sstatus
ffffffffc0200542:	8b89                	andi	a5,a5,2
ffffffffc0200544:	eb89                	bnez	a5,ffffffffc0200556 <cons_getc+0x18>
ffffffffc0200546:	4501                	li	a0,0
ffffffffc0200548:	4581                	li	a1,0
ffffffffc020054a:	4601                	li	a2,0
ffffffffc020054c:	4889                	li	a7,2
ffffffffc020054e:	00000073          	ecall
ffffffffc0200552:	2501                	sext.w	a0,a0
ffffffffc0200554:	8082                	ret
ffffffffc0200556:	1101                	addi	sp,sp,-32
ffffffffc0200558:	ec06                	sd	ra,24(sp)
ffffffffc020055a:	3d6000ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc020055e:	4501                	li	a0,0
ffffffffc0200560:	4581                	li	a1,0
ffffffffc0200562:	4601                	li	a2,0
ffffffffc0200564:	4889                	li	a7,2
ffffffffc0200566:	00000073          	ecall
ffffffffc020056a:	2501                	sext.w	a0,a0
ffffffffc020056c:	e42a                	sd	a0,8(sp)
ffffffffc020056e:	3bc000ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0200572:	60e2                	ld	ra,24(sp)
ffffffffc0200574:	6522                	ld	a0,8(sp)
ffffffffc0200576:	6105                	addi	sp,sp,32
ffffffffc0200578:	8082                	ret

ffffffffc020057a <dtb_init>:
ffffffffc020057a:	7119                	addi	sp,sp,-128
ffffffffc020057c:	00004517          	auipc	a0,0x4
ffffffffc0200580:	c3450513          	addi	a0,a0,-972 # ffffffffc02041b0 <commands+0x88>
ffffffffc0200584:	fc86                	sd	ra,120(sp)
ffffffffc0200586:	f8a2                	sd	s0,112(sp)
ffffffffc0200588:	e8d2                	sd	s4,80(sp)
ffffffffc020058a:	f4a6                	sd	s1,104(sp)
ffffffffc020058c:	f0ca                	sd	s2,96(sp)
ffffffffc020058e:	ecce                	sd	s3,88(sp)
ffffffffc0200590:	e4d6                	sd	s5,72(sp)
ffffffffc0200592:	e0da                	sd	s6,64(sp)
ffffffffc0200594:	fc5e                	sd	s7,56(sp)
ffffffffc0200596:	f862                	sd	s8,48(sp)
ffffffffc0200598:	f466                	sd	s9,40(sp)
ffffffffc020059a:	f06a                	sd	s10,32(sp)
ffffffffc020059c:	ec6e                	sd	s11,24(sp)
ffffffffc020059e:	bf7ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02005a2:	00009597          	auipc	a1,0x9
ffffffffc02005a6:	a5e5b583          	ld	a1,-1442(a1) # ffffffffc0209000 <boot_hartid>
ffffffffc02005aa:	00004517          	auipc	a0,0x4
ffffffffc02005ae:	c1650513          	addi	a0,a0,-1002 # ffffffffc02041c0 <commands+0x98>
ffffffffc02005b2:	be3ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02005b6:	00009417          	auipc	s0,0x9
ffffffffc02005ba:	a5240413          	addi	s0,s0,-1454 # ffffffffc0209008 <boot_dtb>
ffffffffc02005be:	600c                	ld	a1,0(s0)
ffffffffc02005c0:	00004517          	auipc	a0,0x4
ffffffffc02005c4:	c1050513          	addi	a0,a0,-1008 # ffffffffc02041d0 <commands+0xa8>
ffffffffc02005c8:	bcdff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02005cc:	00043a03          	ld	s4,0(s0)
ffffffffc02005d0:	00004517          	auipc	a0,0x4
ffffffffc02005d4:	c1850513          	addi	a0,a0,-1000 # ffffffffc02041e8 <commands+0xc0>
ffffffffc02005d8:	120a0463          	beqz	s4,ffffffffc0200700 <dtb_init+0x186>
ffffffffc02005dc:	57f5                	li	a5,-3
ffffffffc02005de:	07fa                	slli	a5,a5,0x1e
ffffffffc02005e0:	00fa0733          	add	a4,s4,a5
ffffffffc02005e4:	431c                	lw	a5,0(a4)
ffffffffc02005e6:	00ff0637          	lui	a2,0xff0
ffffffffc02005ea:	6b41                	lui	s6,0x10
ffffffffc02005ec:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02005f0:	0187969b          	slliw	a3,a5,0x18
ffffffffc02005f4:	0187d51b          	srliw	a0,a5,0x18
ffffffffc02005f8:	0105959b          	slliw	a1,a1,0x10
ffffffffc02005fc:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200600:	8df1                	and	a1,a1,a2
ffffffffc0200602:	8ec9                	or	a3,a3,a0
ffffffffc0200604:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200608:	1b7d                	addi	s6,s6,-1
ffffffffc020060a:	0167f7b3          	and	a5,a5,s6
ffffffffc020060e:	8dd5                	or	a1,a1,a3
ffffffffc0200610:	8ddd                	or	a1,a1,a5
ffffffffc0200612:	d00e07b7          	lui	a5,0xd00e0
ffffffffc0200616:	2581                	sext.w	a1,a1
ffffffffc0200618:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfed2a01>
ffffffffc020061c:	10f59163          	bne	a1,a5,ffffffffc020071e <dtb_init+0x1a4>
ffffffffc0200620:	471c                	lw	a5,8(a4)
ffffffffc0200622:	4754                	lw	a3,12(a4)
ffffffffc0200624:	4c81                	li	s9,0
ffffffffc0200626:	0087d59b          	srliw	a1,a5,0x8
ffffffffc020062a:	0086d51b          	srliw	a0,a3,0x8
ffffffffc020062e:	0186941b          	slliw	s0,a3,0x18
ffffffffc0200632:	0186d89b          	srliw	a7,a3,0x18
ffffffffc0200636:	01879a1b          	slliw	s4,a5,0x18
ffffffffc020063a:	0187d81b          	srliw	a6,a5,0x18
ffffffffc020063e:	0105151b          	slliw	a0,a0,0x10
ffffffffc0200642:	0106d69b          	srliw	a3,a3,0x10
ffffffffc0200646:	0105959b          	slliw	a1,a1,0x10
ffffffffc020064a:	0107d79b          	srliw	a5,a5,0x10
ffffffffc020064e:	8d71                	and	a0,a0,a2
ffffffffc0200650:	01146433          	or	s0,s0,a7
ffffffffc0200654:	0086969b          	slliw	a3,a3,0x8
ffffffffc0200658:	010a6a33          	or	s4,s4,a6
ffffffffc020065c:	8e6d                	and	a2,a2,a1
ffffffffc020065e:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200662:	8c49                	or	s0,s0,a0
ffffffffc0200664:	0166f6b3          	and	a3,a3,s6
ffffffffc0200668:	00ca6a33          	or	s4,s4,a2
ffffffffc020066c:	0167f7b3          	and	a5,a5,s6
ffffffffc0200670:	8c55                	or	s0,s0,a3
ffffffffc0200672:	00fa6a33          	or	s4,s4,a5
ffffffffc0200676:	1402                	slli	s0,s0,0x20
ffffffffc0200678:	1a02                	slli	s4,s4,0x20
ffffffffc020067a:	9001                	srli	s0,s0,0x20
ffffffffc020067c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200680:	943a                	add	s0,s0,a4
ffffffffc0200682:	9a3a                	add	s4,s4,a4
ffffffffc0200684:	00ff0c37          	lui	s8,0xff0
ffffffffc0200688:	4b8d                	li	s7,3
ffffffffc020068a:	00004917          	auipc	s2,0x4
ffffffffc020068e:	bae90913          	addi	s2,s2,-1106 # ffffffffc0204238 <commands+0x110>
ffffffffc0200692:	49bd                	li	s3,15
ffffffffc0200694:	4d91                	li	s11,4
ffffffffc0200696:	4d05                	li	s10,1
ffffffffc0200698:	00004497          	auipc	s1,0x4
ffffffffc020069c:	b9848493          	addi	s1,s1,-1128 # ffffffffc0204230 <commands+0x108>
ffffffffc02006a0:	000a2703          	lw	a4,0(s4)
ffffffffc02006a4:	004a0a93          	addi	s5,s4,4
ffffffffc02006a8:	0087569b          	srliw	a3,a4,0x8
ffffffffc02006ac:	0187179b          	slliw	a5,a4,0x18
ffffffffc02006b0:	0187561b          	srliw	a2,a4,0x18
ffffffffc02006b4:	0106969b          	slliw	a3,a3,0x10
ffffffffc02006b8:	0107571b          	srliw	a4,a4,0x10
ffffffffc02006bc:	8fd1                	or	a5,a5,a2
ffffffffc02006be:	0186f6b3          	and	a3,a3,s8
ffffffffc02006c2:	0087171b          	slliw	a4,a4,0x8
ffffffffc02006c6:	8fd5                	or	a5,a5,a3
ffffffffc02006c8:	00eb7733          	and	a4,s6,a4
ffffffffc02006cc:	8fd9                	or	a5,a5,a4
ffffffffc02006ce:	2781                	sext.w	a5,a5
ffffffffc02006d0:	09778c63          	beq	a5,s7,ffffffffc0200768 <dtb_init+0x1ee>
ffffffffc02006d4:	00fbea63          	bltu	s7,a5,ffffffffc02006e8 <dtb_init+0x16e>
ffffffffc02006d8:	07a78663          	beq	a5,s10,ffffffffc0200744 <dtb_init+0x1ca>
ffffffffc02006dc:	4709                	li	a4,2
ffffffffc02006de:	00e79763          	bne	a5,a4,ffffffffc02006ec <dtb_init+0x172>
ffffffffc02006e2:	4c81                	li	s9,0
ffffffffc02006e4:	8a56                	mv	s4,s5
ffffffffc02006e6:	bf6d                	j	ffffffffc02006a0 <dtb_init+0x126>
ffffffffc02006e8:	ffb78ee3          	beq	a5,s11,ffffffffc02006e4 <dtb_init+0x16a>
ffffffffc02006ec:	00004517          	auipc	a0,0x4
ffffffffc02006f0:	bc450513          	addi	a0,a0,-1084 # ffffffffc02042b0 <commands+0x188>
ffffffffc02006f4:	aa1ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	bf050513          	addi	a0,a0,-1040 # ffffffffc02042e8 <commands+0x1c0>
ffffffffc0200700:	7446                	ld	s0,112(sp)
ffffffffc0200702:	70e6                	ld	ra,120(sp)
ffffffffc0200704:	74a6                	ld	s1,104(sp)
ffffffffc0200706:	7906                	ld	s2,96(sp)
ffffffffc0200708:	69e6                	ld	s3,88(sp)
ffffffffc020070a:	6a46                	ld	s4,80(sp)
ffffffffc020070c:	6aa6                	ld	s5,72(sp)
ffffffffc020070e:	6b06                	ld	s6,64(sp)
ffffffffc0200710:	7be2                	ld	s7,56(sp)
ffffffffc0200712:	7c42                	ld	s8,48(sp)
ffffffffc0200714:	7ca2                	ld	s9,40(sp)
ffffffffc0200716:	7d02                	ld	s10,32(sp)
ffffffffc0200718:	6de2                	ld	s11,24(sp)
ffffffffc020071a:	6109                	addi	sp,sp,128
ffffffffc020071c:	bca5                	j	ffffffffc0200194 <cprintf>
ffffffffc020071e:	7446                	ld	s0,112(sp)
ffffffffc0200720:	70e6                	ld	ra,120(sp)
ffffffffc0200722:	74a6                	ld	s1,104(sp)
ffffffffc0200724:	7906                	ld	s2,96(sp)
ffffffffc0200726:	69e6                	ld	s3,88(sp)
ffffffffc0200728:	6a46                	ld	s4,80(sp)
ffffffffc020072a:	6aa6                	ld	s5,72(sp)
ffffffffc020072c:	6b06                	ld	s6,64(sp)
ffffffffc020072e:	7be2                	ld	s7,56(sp)
ffffffffc0200730:	7c42                	ld	s8,48(sp)
ffffffffc0200732:	7ca2                	ld	s9,40(sp)
ffffffffc0200734:	7d02                	ld	s10,32(sp)
ffffffffc0200736:	6de2                	ld	s11,24(sp)
ffffffffc0200738:	00004517          	auipc	a0,0x4
ffffffffc020073c:	ad050513          	addi	a0,a0,-1328 # ffffffffc0204208 <commands+0xe0>
ffffffffc0200740:	6109                	addi	sp,sp,128
ffffffffc0200742:	bc89                	j	ffffffffc0200194 <cprintf>
ffffffffc0200744:	8556                	mv	a0,s5
ffffffffc0200746:	688030ef          	jal	ra,ffffffffc0203dce <strlen>
ffffffffc020074a:	8a2a                	mv	s4,a0
ffffffffc020074c:	4619                	li	a2,6
ffffffffc020074e:	85a6                	mv	a1,s1
ffffffffc0200750:	8556                	mv	a0,s5
ffffffffc0200752:	2a01                	sext.w	s4,s4
ffffffffc0200754:	6e0030ef          	jal	ra,ffffffffc0203e34 <strncmp>
ffffffffc0200758:	e111                	bnez	a0,ffffffffc020075c <dtb_init+0x1e2>
ffffffffc020075a:	4c85                	li	s9,1
ffffffffc020075c:	0a91                	addi	s5,s5,4
ffffffffc020075e:	9ad2                	add	s5,s5,s4
ffffffffc0200760:	ffcafa93          	andi	s5,s5,-4
ffffffffc0200764:	8a56                	mv	s4,s5
ffffffffc0200766:	bf2d                	j	ffffffffc02006a0 <dtb_init+0x126>
ffffffffc0200768:	004a2783          	lw	a5,4(s4)
ffffffffc020076c:	00ca0693          	addi	a3,s4,12
ffffffffc0200770:	0087d71b          	srliw	a4,a5,0x8
ffffffffc0200774:	01879a9b          	slliw	s5,a5,0x18
ffffffffc0200778:	0187d61b          	srliw	a2,a5,0x18
ffffffffc020077c:	0107171b          	slliw	a4,a4,0x10
ffffffffc0200780:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200784:	00caeab3          	or	s5,s5,a2
ffffffffc0200788:	01877733          	and	a4,a4,s8
ffffffffc020078c:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200790:	00eaeab3          	or	s5,s5,a4
ffffffffc0200794:	00fb77b3          	and	a5,s6,a5
ffffffffc0200798:	00faeab3          	or	s5,s5,a5
ffffffffc020079c:	2a81                	sext.w	s5,s5
ffffffffc020079e:	000c9c63          	bnez	s9,ffffffffc02007b6 <dtb_init+0x23c>
ffffffffc02007a2:	1a82                	slli	s5,s5,0x20
ffffffffc02007a4:	00368793          	addi	a5,a3,3
ffffffffc02007a8:	020ada93          	srli	s5,s5,0x20
ffffffffc02007ac:	9abe                	add	s5,s5,a5
ffffffffc02007ae:	ffcafa93          	andi	s5,s5,-4
ffffffffc02007b2:	8a56                	mv	s4,s5
ffffffffc02007b4:	b5f5                	j	ffffffffc02006a0 <dtb_init+0x126>
ffffffffc02007b6:	008a2783          	lw	a5,8(s4)
ffffffffc02007ba:	85ca                	mv	a1,s2
ffffffffc02007bc:	e436                	sd	a3,8(sp)
ffffffffc02007be:	0087d51b          	srliw	a0,a5,0x8
ffffffffc02007c2:	0187d61b          	srliw	a2,a5,0x18
ffffffffc02007c6:	0187971b          	slliw	a4,a5,0x18
ffffffffc02007ca:	0105151b          	slliw	a0,a0,0x10
ffffffffc02007ce:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02007d2:	8f51                	or	a4,a4,a2
ffffffffc02007d4:	01857533          	and	a0,a0,s8
ffffffffc02007d8:	0087979b          	slliw	a5,a5,0x8
ffffffffc02007dc:	8d59                	or	a0,a0,a4
ffffffffc02007de:	00fb77b3          	and	a5,s6,a5
ffffffffc02007e2:	8d5d                	or	a0,a0,a5
ffffffffc02007e4:	1502                	slli	a0,a0,0x20
ffffffffc02007e6:	9101                	srli	a0,a0,0x20
ffffffffc02007e8:	9522                	add	a0,a0,s0
ffffffffc02007ea:	62c030ef          	jal	ra,ffffffffc0203e16 <strcmp>
ffffffffc02007ee:	66a2                	ld	a3,8(sp)
ffffffffc02007f0:	f94d                	bnez	a0,ffffffffc02007a2 <dtb_init+0x228>
ffffffffc02007f2:	fb59f8e3          	bgeu	s3,s5,ffffffffc02007a2 <dtb_init+0x228>
ffffffffc02007f6:	00ca3783          	ld	a5,12(s4)
ffffffffc02007fa:	014a3703          	ld	a4,20(s4)
ffffffffc02007fe:	00004517          	auipc	a0,0x4
ffffffffc0200802:	a4250513          	addi	a0,a0,-1470 # ffffffffc0204240 <commands+0x118>
ffffffffc0200806:	4207d613          	srai	a2,a5,0x20
ffffffffc020080a:	0087d31b          	srliw	t1,a5,0x8
ffffffffc020080e:	42075593          	srai	a1,a4,0x20
ffffffffc0200812:	0187de1b          	srliw	t3,a5,0x18
ffffffffc0200816:	0186581b          	srliw	a6,a2,0x18
ffffffffc020081a:	0187941b          	slliw	s0,a5,0x18
ffffffffc020081e:	0107d89b          	srliw	a7,a5,0x10
ffffffffc0200822:	0187d693          	srli	a3,a5,0x18
ffffffffc0200826:	01861f1b          	slliw	t5,a2,0x18
ffffffffc020082a:	0087579b          	srliw	a5,a4,0x8
ffffffffc020082e:	0103131b          	slliw	t1,t1,0x10
ffffffffc0200832:	0106561b          	srliw	a2,a2,0x10
ffffffffc0200836:	010f6f33          	or	t5,t5,a6
ffffffffc020083a:	0187529b          	srliw	t0,a4,0x18
ffffffffc020083e:	0185df9b          	srliw	t6,a1,0x18
ffffffffc0200842:	01837333          	and	t1,t1,s8
ffffffffc0200846:	01c46433          	or	s0,s0,t3
ffffffffc020084a:	0186f6b3          	and	a3,a3,s8
ffffffffc020084e:	01859e1b          	slliw	t3,a1,0x18
ffffffffc0200852:	01871e9b          	slliw	t4,a4,0x18
ffffffffc0200856:	0107581b          	srliw	a6,a4,0x10
ffffffffc020085a:	0086161b          	slliw	a2,a2,0x8
ffffffffc020085e:	8361                	srli	a4,a4,0x18
ffffffffc0200860:	0107979b          	slliw	a5,a5,0x10
ffffffffc0200864:	0105d59b          	srliw	a1,a1,0x10
ffffffffc0200868:	01e6e6b3          	or	a3,a3,t5
ffffffffc020086c:	00cb7633          	and	a2,s6,a2
ffffffffc0200870:	0088181b          	slliw	a6,a6,0x8
ffffffffc0200874:	0085959b          	slliw	a1,a1,0x8
ffffffffc0200878:	00646433          	or	s0,s0,t1
ffffffffc020087c:	0187f7b3          	and	a5,a5,s8
ffffffffc0200880:	01fe6333          	or	t1,t3,t6
ffffffffc0200884:	01877c33          	and	s8,a4,s8
ffffffffc0200888:	0088989b          	slliw	a7,a7,0x8
ffffffffc020088c:	011b78b3          	and	a7,s6,a7
ffffffffc0200890:	005eeeb3          	or	t4,t4,t0
ffffffffc0200894:	00c6e733          	or	a4,a3,a2
ffffffffc0200898:	006c6c33          	or	s8,s8,t1
ffffffffc020089c:	010b76b3          	and	a3,s6,a6
ffffffffc02008a0:	00bb7b33          	and	s6,s6,a1
ffffffffc02008a4:	01d7e7b3          	or	a5,a5,t4
ffffffffc02008a8:	016c6b33          	or	s6,s8,s6
ffffffffc02008ac:	01146433          	or	s0,s0,a7
ffffffffc02008b0:	8fd5                	or	a5,a5,a3
ffffffffc02008b2:	1702                	slli	a4,a4,0x20
ffffffffc02008b4:	1b02                	slli	s6,s6,0x20
ffffffffc02008b6:	1782                	slli	a5,a5,0x20
ffffffffc02008b8:	9301                	srli	a4,a4,0x20
ffffffffc02008ba:	1402                	slli	s0,s0,0x20
ffffffffc02008bc:	020b5b13          	srli	s6,s6,0x20
ffffffffc02008c0:	0167eb33          	or	s6,a5,s6
ffffffffc02008c4:	8c59                	or	s0,s0,a4
ffffffffc02008c6:	8cfff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02008ca:	85a2                	mv	a1,s0
ffffffffc02008cc:	00004517          	auipc	a0,0x4
ffffffffc02008d0:	99450513          	addi	a0,a0,-1644 # ffffffffc0204260 <commands+0x138>
ffffffffc02008d4:	8c1ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02008d8:	014b5613          	srli	a2,s6,0x14
ffffffffc02008dc:	85da                	mv	a1,s6
ffffffffc02008de:	00004517          	auipc	a0,0x4
ffffffffc02008e2:	99a50513          	addi	a0,a0,-1638 # ffffffffc0204278 <commands+0x150>
ffffffffc02008e6:	8afff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02008ea:	008b05b3          	add	a1,s6,s0
ffffffffc02008ee:	15fd                	addi	a1,a1,-1
ffffffffc02008f0:	00004517          	auipc	a0,0x4
ffffffffc02008f4:	9a850513          	addi	a0,a0,-1624 # ffffffffc0204298 <commands+0x170>
ffffffffc02008f8:	89dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02008fc:	00004517          	auipc	a0,0x4
ffffffffc0200900:	9ec50513          	addi	a0,a0,-1556 # ffffffffc02042e8 <commands+0x1c0>
ffffffffc0200904:	0000d797          	auipc	a5,0xd
ffffffffc0200908:	b687be23          	sd	s0,-1156(a5) # ffffffffc020d480 <memory_base>
ffffffffc020090c:	0000d797          	auipc	a5,0xd
ffffffffc0200910:	b767be23          	sd	s6,-1156(a5) # ffffffffc020d488 <memory_size>
ffffffffc0200914:	b3f5                	j	ffffffffc0200700 <dtb_init+0x186>

ffffffffc0200916 <get_memory_base>:
ffffffffc0200916:	0000d517          	auipc	a0,0xd
ffffffffc020091a:	b6a53503          	ld	a0,-1174(a0) # ffffffffc020d480 <memory_base>
ffffffffc020091e:	8082                	ret

ffffffffc0200920 <get_memory_size>:
ffffffffc0200920:	0000d517          	auipc	a0,0xd
ffffffffc0200924:	b6853503          	ld	a0,-1176(a0) # ffffffffc020d488 <memory_size>
ffffffffc0200928:	8082                	ret

ffffffffc020092a <intr_enable>:
ffffffffc020092a:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020092e:	8082                	ret

ffffffffc0200930 <intr_disable>:
ffffffffc0200930:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200934:	8082                	ret

ffffffffc0200936 <pic_init>:
ffffffffc0200936:	8082                	ret

ffffffffc0200938 <idt_init>:
ffffffffc0200938:	14005073          	csrwi	sscratch,0
ffffffffc020093c:	00000797          	auipc	a5,0x0
ffffffffc0200940:	3dc78793          	addi	a5,a5,988 # ffffffffc0200d18 <__alltraps>
ffffffffc0200944:	10579073          	csrw	stvec,a5
ffffffffc0200948:	000407b7          	lui	a5,0x40
ffffffffc020094c:	1007a7f3          	csrrs	a5,sstatus,a5
ffffffffc0200950:	8082                	ret

ffffffffc0200952 <print_regs>:
ffffffffc0200952:	610c                	ld	a1,0(a0)
ffffffffc0200954:	1141                	addi	sp,sp,-16
ffffffffc0200956:	e022                	sd	s0,0(sp)
ffffffffc0200958:	842a                	mv	s0,a0
ffffffffc020095a:	00004517          	auipc	a0,0x4
ffffffffc020095e:	9a650513          	addi	a0,a0,-1626 # ffffffffc0204300 <commands+0x1d8>
ffffffffc0200962:	e406                	sd	ra,8(sp)
ffffffffc0200964:	831ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200968:	640c                	ld	a1,8(s0)
ffffffffc020096a:	00004517          	auipc	a0,0x4
ffffffffc020096e:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0204318 <commands+0x1f0>
ffffffffc0200972:	823ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200976:	680c                	ld	a1,16(s0)
ffffffffc0200978:	00004517          	auipc	a0,0x4
ffffffffc020097c:	9b850513          	addi	a0,a0,-1608 # ffffffffc0204330 <commands+0x208>
ffffffffc0200980:	815ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200984:	6c0c                	ld	a1,24(s0)
ffffffffc0200986:	00004517          	auipc	a0,0x4
ffffffffc020098a:	9c250513          	addi	a0,a0,-1598 # ffffffffc0204348 <commands+0x220>
ffffffffc020098e:	807ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200992:	700c                	ld	a1,32(s0)
ffffffffc0200994:	00004517          	auipc	a0,0x4
ffffffffc0200998:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0204360 <commands+0x238>
ffffffffc020099c:	ff8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02009a0:	740c                	ld	a1,40(s0)
ffffffffc02009a2:	00004517          	auipc	a0,0x4
ffffffffc02009a6:	9d650513          	addi	a0,a0,-1578 # ffffffffc0204378 <commands+0x250>
ffffffffc02009aa:	feaff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02009ae:	780c                	ld	a1,48(s0)
ffffffffc02009b0:	00004517          	auipc	a0,0x4
ffffffffc02009b4:	9e050513          	addi	a0,a0,-1568 # ffffffffc0204390 <commands+0x268>
ffffffffc02009b8:	fdcff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02009bc:	7c0c                	ld	a1,56(s0)
ffffffffc02009be:	00004517          	auipc	a0,0x4
ffffffffc02009c2:	9ea50513          	addi	a0,a0,-1558 # ffffffffc02043a8 <commands+0x280>
ffffffffc02009c6:	fceff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02009ca:	602c                	ld	a1,64(s0)
ffffffffc02009cc:	00004517          	auipc	a0,0x4
ffffffffc02009d0:	9f450513          	addi	a0,a0,-1548 # ffffffffc02043c0 <commands+0x298>
ffffffffc02009d4:	fc0ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02009d8:	642c                	ld	a1,72(s0)
ffffffffc02009da:	00004517          	auipc	a0,0x4
ffffffffc02009de:	9fe50513          	addi	a0,a0,-1538 # ffffffffc02043d8 <commands+0x2b0>
ffffffffc02009e2:	fb2ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02009e6:	682c                	ld	a1,80(s0)
ffffffffc02009e8:	00004517          	auipc	a0,0x4
ffffffffc02009ec:	a0850513          	addi	a0,a0,-1528 # ffffffffc02043f0 <commands+0x2c8>
ffffffffc02009f0:	fa4ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02009f4:	6c2c                	ld	a1,88(s0)
ffffffffc02009f6:	00004517          	auipc	a0,0x4
ffffffffc02009fa:	a1250513          	addi	a0,a0,-1518 # ffffffffc0204408 <commands+0x2e0>
ffffffffc02009fe:	f96ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200a02:	702c                	ld	a1,96(s0)
ffffffffc0200a04:	00004517          	auipc	a0,0x4
ffffffffc0200a08:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0204420 <commands+0x2f8>
ffffffffc0200a0c:	f88ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200a10:	742c                	ld	a1,104(s0)
ffffffffc0200a12:	00004517          	auipc	a0,0x4
ffffffffc0200a16:	a2650513          	addi	a0,a0,-1498 # ffffffffc0204438 <commands+0x310>
ffffffffc0200a1a:	f7aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200a1e:	782c                	ld	a1,112(s0)
ffffffffc0200a20:	00004517          	auipc	a0,0x4
ffffffffc0200a24:	a3050513          	addi	a0,a0,-1488 # ffffffffc0204450 <commands+0x328>
ffffffffc0200a28:	f6cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200a2c:	7c2c                	ld	a1,120(s0)
ffffffffc0200a2e:	00004517          	auipc	a0,0x4
ffffffffc0200a32:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0204468 <commands+0x340>
ffffffffc0200a36:	f5eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200a3a:	604c                	ld	a1,128(s0)
ffffffffc0200a3c:	00004517          	auipc	a0,0x4
ffffffffc0200a40:	a4450513          	addi	a0,a0,-1468 # ffffffffc0204480 <commands+0x358>
ffffffffc0200a44:	f50ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200a48:	644c                	ld	a1,136(s0)
ffffffffc0200a4a:	00004517          	auipc	a0,0x4
ffffffffc0200a4e:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0204498 <commands+0x370>
ffffffffc0200a52:	f42ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200a56:	684c                	ld	a1,144(s0)
ffffffffc0200a58:	00004517          	auipc	a0,0x4
ffffffffc0200a5c:	a5850513          	addi	a0,a0,-1448 # ffffffffc02044b0 <commands+0x388>
ffffffffc0200a60:	f34ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200a64:	6c4c                	ld	a1,152(s0)
ffffffffc0200a66:	00004517          	auipc	a0,0x4
ffffffffc0200a6a:	a6250513          	addi	a0,a0,-1438 # ffffffffc02044c8 <commands+0x3a0>
ffffffffc0200a6e:	f26ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200a72:	704c                	ld	a1,160(s0)
ffffffffc0200a74:	00004517          	auipc	a0,0x4
ffffffffc0200a78:	a6c50513          	addi	a0,a0,-1428 # ffffffffc02044e0 <commands+0x3b8>
ffffffffc0200a7c:	f18ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200a80:	744c                	ld	a1,168(s0)
ffffffffc0200a82:	00004517          	auipc	a0,0x4
ffffffffc0200a86:	a7650513          	addi	a0,a0,-1418 # ffffffffc02044f8 <commands+0x3d0>
ffffffffc0200a8a:	f0aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200a8e:	784c                	ld	a1,176(s0)
ffffffffc0200a90:	00004517          	auipc	a0,0x4
ffffffffc0200a94:	a8050513          	addi	a0,a0,-1408 # ffffffffc0204510 <commands+0x3e8>
ffffffffc0200a98:	efcff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200a9c:	7c4c                	ld	a1,184(s0)
ffffffffc0200a9e:	00004517          	auipc	a0,0x4
ffffffffc0200aa2:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0204528 <commands+0x400>
ffffffffc0200aa6:	eeeff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200aaa:	606c                	ld	a1,192(s0)
ffffffffc0200aac:	00004517          	auipc	a0,0x4
ffffffffc0200ab0:	a9450513          	addi	a0,a0,-1388 # ffffffffc0204540 <commands+0x418>
ffffffffc0200ab4:	ee0ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200ab8:	646c                	ld	a1,200(s0)
ffffffffc0200aba:	00004517          	auipc	a0,0x4
ffffffffc0200abe:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0204558 <commands+0x430>
ffffffffc0200ac2:	ed2ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200ac6:	686c                	ld	a1,208(s0)
ffffffffc0200ac8:	00004517          	auipc	a0,0x4
ffffffffc0200acc:	aa850513          	addi	a0,a0,-1368 # ffffffffc0204570 <commands+0x448>
ffffffffc0200ad0:	ec4ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200ad4:	6c6c                	ld	a1,216(s0)
ffffffffc0200ad6:	00004517          	auipc	a0,0x4
ffffffffc0200ada:	ab250513          	addi	a0,a0,-1358 # ffffffffc0204588 <commands+0x460>
ffffffffc0200ade:	eb6ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200ae2:	706c                	ld	a1,224(s0)
ffffffffc0200ae4:	00004517          	auipc	a0,0x4
ffffffffc0200ae8:	abc50513          	addi	a0,a0,-1348 # ffffffffc02045a0 <commands+0x478>
ffffffffc0200aec:	ea8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200af0:	746c                	ld	a1,232(s0)
ffffffffc0200af2:	00004517          	auipc	a0,0x4
ffffffffc0200af6:	ac650513          	addi	a0,a0,-1338 # ffffffffc02045b8 <commands+0x490>
ffffffffc0200afa:	e9aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200afe:	786c                	ld	a1,240(s0)
ffffffffc0200b00:	00004517          	auipc	a0,0x4
ffffffffc0200b04:	ad050513          	addi	a0,a0,-1328 # ffffffffc02045d0 <commands+0x4a8>
ffffffffc0200b08:	e8cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200b0c:	7c6c                	ld	a1,248(s0)
ffffffffc0200b0e:	6402                	ld	s0,0(sp)
ffffffffc0200b10:	60a2                	ld	ra,8(sp)
ffffffffc0200b12:	00004517          	auipc	a0,0x4
ffffffffc0200b16:	ad650513          	addi	a0,a0,-1322 # ffffffffc02045e8 <commands+0x4c0>
ffffffffc0200b1a:	0141                	addi	sp,sp,16
ffffffffc0200b1c:	e78ff06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0200b20 <print_trapframe>:
ffffffffc0200b20:	1141                	addi	sp,sp,-16
ffffffffc0200b22:	e022                	sd	s0,0(sp)
ffffffffc0200b24:	85aa                	mv	a1,a0
ffffffffc0200b26:	842a                	mv	s0,a0
ffffffffc0200b28:	00004517          	auipc	a0,0x4
ffffffffc0200b2c:	ad850513          	addi	a0,a0,-1320 # ffffffffc0204600 <commands+0x4d8>
ffffffffc0200b30:	e406                	sd	ra,8(sp)
ffffffffc0200b32:	e62ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200b36:	8522                	mv	a0,s0
ffffffffc0200b38:	e1bff0ef          	jal	ra,ffffffffc0200952 <print_regs>
ffffffffc0200b3c:	10043583          	ld	a1,256(s0)
ffffffffc0200b40:	00004517          	auipc	a0,0x4
ffffffffc0200b44:	ad850513          	addi	a0,a0,-1320 # ffffffffc0204618 <commands+0x4f0>
ffffffffc0200b48:	e4cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200b4c:	10843583          	ld	a1,264(s0)
ffffffffc0200b50:	00004517          	auipc	a0,0x4
ffffffffc0200b54:	ae050513          	addi	a0,a0,-1312 # ffffffffc0204630 <commands+0x508>
ffffffffc0200b58:	e3cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200b5c:	11043583          	ld	a1,272(s0)
ffffffffc0200b60:	00004517          	auipc	a0,0x4
ffffffffc0200b64:	ae850513          	addi	a0,a0,-1304 # ffffffffc0204648 <commands+0x520>
ffffffffc0200b68:	e2cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200b6c:	11843583          	ld	a1,280(s0)
ffffffffc0200b70:	6402                	ld	s0,0(sp)
ffffffffc0200b72:	60a2                	ld	ra,8(sp)
ffffffffc0200b74:	00004517          	auipc	a0,0x4
ffffffffc0200b78:	aec50513          	addi	a0,a0,-1300 # ffffffffc0204660 <commands+0x538>
ffffffffc0200b7c:	0141                	addi	sp,sp,16
ffffffffc0200b7e:	e16ff06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0200b82 <interrupt_handler>:
ffffffffc0200b82:	11853783          	ld	a5,280(a0)
ffffffffc0200b86:	472d                	li	a4,11
ffffffffc0200b88:	0786                	slli	a5,a5,0x1
ffffffffc0200b8a:	8385                	srli	a5,a5,0x1
ffffffffc0200b8c:	06f76c63          	bltu	a4,a5,ffffffffc0200c04 <interrupt_handler+0x82>
ffffffffc0200b90:	00004717          	auipc	a4,0x4
ffffffffc0200b94:	b9870713          	addi	a4,a4,-1128 # ffffffffc0204728 <commands+0x600>
ffffffffc0200b98:	078a                	slli	a5,a5,0x2
ffffffffc0200b9a:	97ba                	add	a5,a5,a4
ffffffffc0200b9c:	439c                	lw	a5,0(a5)
ffffffffc0200b9e:	97ba                	add	a5,a5,a4
ffffffffc0200ba0:	8782                	jr	a5
ffffffffc0200ba2:	00004517          	auipc	a0,0x4
ffffffffc0200ba6:	b3650513          	addi	a0,a0,-1226 # ffffffffc02046d8 <commands+0x5b0>
ffffffffc0200baa:	deaff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200bae:	00004517          	auipc	a0,0x4
ffffffffc0200bb2:	b0a50513          	addi	a0,a0,-1270 # ffffffffc02046b8 <commands+0x590>
ffffffffc0200bb6:	ddeff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200bba:	00004517          	auipc	a0,0x4
ffffffffc0200bbe:	abe50513          	addi	a0,a0,-1346 # ffffffffc0204678 <commands+0x550>
ffffffffc0200bc2:	dd2ff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200bc6:	00004517          	auipc	a0,0x4
ffffffffc0200bca:	ad250513          	addi	a0,a0,-1326 # ffffffffc0204698 <commands+0x570>
ffffffffc0200bce:	dc6ff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200bd2:	1141                	addi	sp,sp,-16
ffffffffc0200bd4:	e406                	sd	ra,8(sp)
ffffffffc0200bd6:	919ff0ef          	jal	ra,ffffffffc02004ee <clock_set_next_event>
ffffffffc0200bda:	0000d697          	auipc	a3,0xd
ffffffffc0200bde:	89668693          	addi	a3,a3,-1898 # ffffffffc020d470 <ticks>
ffffffffc0200be2:	629c                	ld	a5,0(a3)
ffffffffc0200be4:	06400713          	li	a4,100
ffffffffc0200be8:	0785                	addi	a5,a5,1
ffffffffc0200bea:	02e7f733          	remu	a4,a5,a4
ffffffffc0200bee:	e29c                	sd	a5,0(a3)
ffffffffc0200bf0:	cb19                	beqz	a4,ffffffffc0200c06 <interrupt_handler+0x84>
ffffffffc0200bf2:	60a2                	ld	ra,8(sp)
ffffffffc0200bf4:	0141                	addi	sp,sp,16
ffffffffc0200bf6:	8082                	ret
ffffffffc0200bf8:	00004517          	auipc	a0,0x4
ffffffffc0200bfc:	b1050513          	addi	a0,a0,-1264 # ffffffffc0204708 <commands+0x5e0>
ffffffffc0200c00:	d94ff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200c04:	bf31                	j	ffffffffc0200b20 <print_trapframe>
ffffffffc0200c06:	06400593          	li	a1,100
ffffffffc0200c0a:	00004517          	auipc	a0,0x4
ffffffffc0200c0e:	aee50513          	addi	a0,a0,-1298 # ffffffffc02046f8 <commands+0x5d0>
ffffffffc0200c12:	d82ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200c16:	0000d717          	auipc	a4,0xd
ffffffffc0200c1a:	87a70713          	addi	a4,a4,-1926 # ffffffffc020d490 <num>
ffffffffc0200c1e:	431c                	lw	a5,0(a4)
ffffffffc0200c20:	46a9                	li	a3,10
ffffffffc0200c22:	0017861b          	addiw	a2,a5,1
ffffffffc0200c26:	c310                	sw	a2,0(a4)
ffffffffc0200c28:	fcd615e3          	bne	a2,a3,ffffffffc0200bf2 <interrupt_handler+0x70>
ffffffffc0200c2c:	4501                	li	a0,0
ffffffffc0200c2e:	4581                	li	a1,0
ffffffffc0200c30:	4601                	li	a2,0
ffffffffc0200c32:	48a1                	li	a7,8
ffffffffc0200c34:	00000073          	ecall
ffffffffc0200c38:	bf6d                	j	ffffffffc0200bf2 <interrupt_handler+0x70>

ffffffffc0200c3a <exception_handler>:
ffffffffc0200c3a:	11853783          	ld	a5,280(a0)
ffffffffc0200c3e:	473d                	li	a4,15
ffffffffc0200c40:	0cf76563          	bltu	a4,a5,ffffffffc0200d0a <exception_handler+0xd0>
ffffffffc0200c44:	00004717          	auipc	a4,0x4
ffffffffc0200c48:	cac70713          	addi	a4,a4,-852 # ffffffffc02048f0 <commands+0x7c8>
ffffffffc0200c4c:	078a                	slli	a5,a5,0x2
ffffffffc0200c4e:	97ba                	add	a5,a5,a4
ffffffffc0200c50:	439c                	lw	a5,0(a5)
ffffffffc0200c52:	97ba                	add	a5,a5,a4
ffffffffc0200c54:	8782                	jr	a5
ffffffffc0200c56:	00004517          	auipc	a0,0x4
ffffffffc0200c5a:	c8250513          	addi	a0,a0,-894 # ffffffffc02048d8 <commands+0x7b0>
ffffffffc0200c5e:	d36ff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200c62:	00004517          	auipc	a0,0x4
ffffffffc0200c66:	af650513          	addi	a0,a0,-1290 # ffffffffc0204758 <commands+0x630>
ffffffffc0200c6a:	d2aff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200c6e:	00004517          	auipc	a0,0x4
ffffffffc0200c72:	b0a50513          	addi	a0,a0,-1270 # ffffffffc0204778 <commands+0x650>
ffffffffc0200c76:	d1eff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200c7a:	00004517          	auipc	a0,0x4
ffffffffc0200c7e:	b1e50513          	addi	a0,a0,-1250 # ffffffffc0204798 <commands+0x670>
ffffffffc0200c82:	d12ff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200c86:	00004517          	auipc	a0,0x4
ffffffffc0200c8a:	b2a50513          	addi	a0,a0,-1238 # ffffffffc02047b0 <commands+0x688>
ffffffffc0200c8e:	d06ff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200c92:	00004517          	auipc	a0,0x4
ffffffffc0200c96:	b2e50513          	addi	a0,a0,-1234 # ffffffffc02047c0 <commands+0x698>
ffffffffc0200c9a:	cfaff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200c9e:	00004517          	auipc	a0,0x4
ffffffffc0200ca2:	b4250513          	addi	a0,a0,-1214 # ffffffffc02047e0 <commands+0x6b8>
ffffffffc0200ca6:	ceeff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200caa:	00004517          	auipc	a0,0x4
ffffffffc0200cae:	b4e50513          	addi	a0,a0,-1202 # ffffffffc02047f8 <commands+0x6d0>
ffffffffc0200cb2:	ce2ff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200cb6:	00004517          	auipc	a0,0x4
ffffffffc0200cba:	b5a50513          	addi	a0,a0,-1190 # ffffffffc0204810 <commands+0x6e8>
ffffffffc0200cbe:	cd6ff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200cc2:	00004517          	auipc	a0,0x4
ffffffffc0200cc6:	b6650513          	addi	a0,a0,-1178 # ffffffffc0204828 <commands+0x700>
ffffffffc0200cca:	ccaff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200cce:	00004517          	auipc	a0,0x4
ffffffffc0200cd2:	b7a50513          	addi	a0,a0,-1158 # ffffffffc0204848 <commands+0x720>
ffffffffc0200cd6:	cbeff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200cda:	00004517          	auipc	a0,0x4
ffffffffc0200cde:	b8e50513          	addi	a0,a0,-1138 # ffffffffc0204868 <commands+0x740>
ffffffffc0200ce2:	cb2ff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200ce6:	00004517          	auipc	a0,0x4
ffffffffc0200cea:	ba250513          	addi	a0,a0,-1118 # ffffffffc0204888 <commands+0x760>
ffffffffc0200cee:	ca6ff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200cf2:	00004517          	auipc	a0,0x4
ffffffffc0200cf6:	bb650513          	addi	a0,a0,-1098 # ffffffffc02048a8 <commands+0x780>
ffffffffc0200cfa:	c9aff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200cfe:	00004517          	auipc	a0,0x4
ffffffffc0200d02:	bc250513          	addi	a0,a0,-1086 # ffffffffc02048c0 <commands+0x798>
ffffffffc0200d06:	c8eff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200d0a:	bd19                	j	ffffffffc0200b20 <print_trapframe>

ffffffffc0200d0c <trap>:
ffffffffc0200d0c:	11853783          	ld	a5,280(a0)
ffffffffc0200d10:	0007c363          	bltz	a5,ffffffffc0200d16 <trap+0xa>
ffffffffc0200d14:	b71d                	j	ffffffffc0200c3a <exception_handler>
ffffffffc0200d16:	b5b5                	j	ffffffffc0200b82 <interrupt_handler>

ffffffffc0200d18 <__alltraps>:
ffffffffc0200d18:	14011073          	csrw	sscratch,sp
ffffffffc0200d1c:	712d                	addi	sp,sp,-288
ffffffffc0200d1e:	e406                	sd	ra,8(sp)
ffffffffc0200d20:	ec0e                	sd	gp,24(sp)
ffffffffc0200d22:	f012                	sd	tp,32(sp)
ffffffffc0200d24:	f416                	sd	t0,40(sp)
ffffffffc0200d26:	f81a                	sd	t1,48(sp)
ffffffffc0200d28:	fc1e                	sd	t2,56(sp)
ffffffffc0200d2a:	e0a2                	sd	s0,64(sp)
ffffffffc0200d2c:	e4a6                	sd	s1,72(sp)
ffffffffc0200d2e:	e8aa                	sd	a0,80(sp)
ffffffffc0200d30:	ecae                	sd	a1,88(sp)
ffffffffc0200d32:	f0b2                	sd	a2,96(sp)
ffffffffc0200d34:	f4b6                	sd	a3,104(sp)
ffffffffc0200d36:	f8ba                	sd	a4,112(sp)
ffffffffc0200d38:	fcbe                	sd	a5,120(sp)
ffffffffc0200d3a:	e142                	sd	a6,128(sp)
ffffffffc0200d3c:	e546                	sd	a7,136(sp)
ffffffffc0200d3e:	e94a                	sd	s2,144(sp)
ffffffffc0200d40:	ed4e                	sd	s3,152(sp)
ffffffffc0200d42:	f152                	sd	s4,160(sp)
ffffffffc0200d44:	f556                	sd	s5,168(sp)
ffffffffc0200d46:	f95a                	sd	s6,176(sp)
ffffffffc0200d48:	fd5e                	sd	s7,184(sp)
ffffffffc0200d4a:	e1e2                	sd	s8,192(sp)
ffffffffc0200d4c:	e5e6                	sd	s9,200(sp)
ffffffffc0200d4e:	e9ea                	sd	s10,208(sp)
ffffffffc0200d50:	edee                	sd	s11,216(sp)
ffffffffc0200d52:	f1f2                	sd	t3,224(sp)
ffffffffc0200d54:	f5f6                	sd	t4,232(sp)
ffffffffc0200d56:	f9fa                	sd	t5,240(sp)
ffffffffc0200d58:	fdfe                	sd	t6,248(sp)
ffffffffc0200d5a:	14002473          	csrr	s0,sscratch
ffffffffc0200d5e:	100024f3          	csrr	s1,sstatus
ffffffffc0200d62:	14102973          	csrr	s2,sepc
ffffffffc0200d66:	143029f3          	csrr	s3,stval
ffffffffc0200d6a:	14202a73          	csrr	s4,scause
ffffffffc0200d6e:	e822                	sd	s0,16(sp)
ffffffffc0200d70:	e226                	sd	s1,256(sp)
ffffffffc0200d72:	e64a                	sd	s2,264(sp)
ffffffffc0200d74:	ea4e                	sd	s3,272(sp)
ffffffffc0200d76:	ee52                	sd	s4,280(sp)
ffffffffc0200d78:	850a                	mv	a0,sp
ffffffffc0200d7a:	f93ff0ef          	jal	ra,ffffffffc0200d0c <trap>

ffffffffc0200d7e <__trapret>:
ffffffffc0200d7e:	6492                	ld	s1,256(sp)
ffffffffc0200d80:	6932                	ld	s2,264(sp)
ffffffffc0200d82:	10049073          	csrw	sstatus,s1
ffffffffc0200d86:	14191073          	csrw	sepc,s2
ffffffffc0200d8a:	60a2                	ld	ra,8(sp)
ffffffffc0200d8c:	61e2                	ld	gp,24(sp)
ffffffffc0200d8e:	7202                	ld	tp,32(sp)
ffffffffc0200d90:	72a2                	ld	t0,40(sp)
ffffffffc0200d92:	7342                	ld	t1,48(sp)
ffffffffc0200d94:	73e2                	ld	t2,56(sp)
ffffffffc0200d96:	6406                	ld	s0,64(sp)
ffffffffc0200d98:	64a6                	ld	s1,72(sp)
ffffffffc0200d9a:	6546                	ld	a0,80(sp)
ffffffffc0200d9c:	65e6                	ld	a1,88(sp)
ffffffffc0200d9e:	7606                	ld	a2,96(sp)
ffffffffc0200da0:	76a6                	ld	a3,104(sp)
ffffffffc0200da2:	7746                	ld	a4,112(sp)
ffffffffc0200da4:	77e6                	ld	a5,120(sp)
ffffffffc0200da6:	680a                	ld	a6,128(sp)
ffffffffc0200da8:	68aa                	ld	a7,136(sp)
ffffffffc0200daa:	694a                	ld	s2,144(sp)
ffffffffc0200dac:	69ea                	ld	s3,152(sp)
ffffffffc0200dae:	7a0a                	ld	s4,160(sp)
ffffffffc0200db0:	7aaa                	ld	s5,168(sp)
ffffffffc0200db2:	7b4a                	ld	s6,176(sp)
ffffffffc0200db4:	7bea                	ld	s7,184(sp)
ffffffffc0200db6:	6c0e                	ld	s8,192(sp)
ffffffffc0200db8:	6cae                	ld	s9,200(sp)
ffffffffc0200dba:	6d4e                	ld	s10,208(sp)
ffffffffc0200dbc:	6dee                	ld	s11,216(sp)
ffffffffc0200dbe:	7e0e                	ld	t3,224(sp)
ffffffffc0200dc0:	7eae                	ld	t4,232(sp)
ffffffffc0200dc2:	7f4e                	ld	t5,240(sp)
ffffffffc0200dc4:	7fee                	ld	t6,248(sp)
ffffffffc0200dc6:	6142                	ld	sp,16(sp)
ffffffffc0200dc8:	10200073          	sret

ffffffffc0200dcc <forkrets>:
ffffffffc0200dcc:	812a                	mv	sp,a0
ffffffffc0200dce:	bf45                	j	ffffffffc0200d7e <__trapret>
	...

ffffffffc0200dd2 <default_init>:
ffffffffc0200dd2:	00008797          	auipc	a5,0x8
ffffffffc0200dd6:	65e78793          	addi	a5,a5,1630 # ffffffffc0209430 <free_area>
ffffffffc0200dda:	e79c                	sd	a5,8(a5)
ffffffffc0200ddc:	e39c                	sd	a5,0(a5)
ffffffffc0200dde:	0007a823          	sw	zero,16(a5)
ffffffffc0200de2:	8082                	ret

ffffffffc0200de4 <default_nr_free_pages>:
ffffffffc0200de4:	00008517          	auipc	a0,0x8
ffffffffc0200de8:	65c56503          	lwu	a0,1628(a0) # ffffffffc0209440 <free_area+0x10>
ffffffffc0200dec:	8082                	ret

ffffffffc0200dee <default_alloc_pages>:
ffffffffc0200dee:	cd51                	beqz	a0,ffffffffc0200e8a <default_alloc_pages+0x9c>
ffffffffc0200df0:	00008617          	auipc	a2,0x8
ffffffffc0200df4:	64060613          	addi	a2,a2,1600 # ffffffffc0209430 <free_area>
ffffffffc0200df8:	01062803          	lw	a6,16(a2)
ffffffffc0200dfc:	86aa                	mv	a3,a0
ffffffffc0200dfe:	02081793          	slli	a5,a6,0x20
ffffffffc0200e02:	9381                	srli	a5,a5,0x20
ffffffffc0200e04:	08a7e163          	bltu	a5,a0,ffffffffc0200e86 <default_alloc_pages+0x98>
ffffffffc0200e08:	661c                	ld	a5,8(a2)
ffffffffc0200e0a:	0018059b          	addiw	a1,a6,1
ffffffffc0200e0e:	1582                	slli	a1,a1,0x20
ffffffffc0200e10:	9181                	srli	a1,a1,0x20
ffffffffc0200e12:	4501                	li	a0,0
ffffffffc0200e14:	06c78863          	beq	a5,a2,ffffffffc0200e84 <default_alloc_pages+0x96>
ffffffffc0200e18:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0200e1c:	00d76763          	bltu	a4,a3,ffffffffc0200e2a <default_alloc_pages+0x3c>
ffffffffc0200e20:	00b77563          	bgeu	a4,a1,ffffffffc0200e2a <default_alloc_pages+0x3c>
ffffffffc0200e24:	fe878513          	addi	a0,a5,-24
ffffffffc0200e28:	85ba                	mv	a1,a4
ffffffffc0200e2a:	679c                	ld	a5,8(a5)
ffffffffc0200e2c:	fec796e3          	bne	a5,a2,ffffffffc0200e18 <default_alloc_pages+0x2a>
ffffffffc0200e30:	c931                	beqz	a0,ffffffffc0200e84 <default_alloc_pages+0x96>
ffffffffc0200e32:	710c                	ld	a1,32(a0)
ffffffffc0200e34:	6d1c                	ld	a5,24(a0)
ffffffffc0200e36:	4918                	lw	a4,16(a0)
ffffffffc0200e38:	0006889b          	sext.w	a7,a3
ffffffffc0200e3c:	e78c                	sd	a1,8(a5)
ffffffffc0200e3e:	e19c                	sd	a5,0(a1)
ffffffffc0200e40:	02071593          	slli	a1,a4,0x20
ffffffffc0200e44:	9181                	srli	a1,a1,0x20
ffffffffc0200e46:	02b6f563          	bgeu	a3,a1,ffffffffc0200e70 <default_alloc_pages+0x82>
ffffffffc0200e4a:	069a                	slli	a3,a3,0x6
ffffffffc0200e4c:	96aa                	add	a3,a3,a0
ffffffffc0200e4e:	4117073b          	subw	a4,a4,a7
ffffffffc0200e52:	ca98                	sw	a4,16(a3)
ffffffffc0200e54:	00868593          	addi	a1,a3,8
ffffffffc0200e58:	4709                	li	a4,2
ffffffffc0200e5a:	40e5b02f          	amoor.d	zero,a4,(a1)
ffffffffc0200e5e:	6798                	ld	a4,8(a5)
ffffffffc0200e60:	01868593          	addi	a1,a3,24
ffffffffc0200e64:	01062803          	lw	a6,16(a2)
ffffffffc0200e68:	e30c                	sd	a1,0(a4)
ffffffffc0200e6a:	e78c                	sd	a1,8(a5)
ffffffffc0200e6c:	f298                	sd	a4,32(a3)
ffffffffc0200e6e:	ee9c                	sd	a5,24(a3)
ffffffffc0200e70:	4118083b          	subw	a6,a6,a7
ffffffffc0200e74:	01062823          	sw	a6,16(a2)
ffffffffc0200e78:	57f5                	li	a5,-3
ffffffffc0200e7a:	00850713          	addi	a4,a0,8
ffffffffc0200e7e:	60f7302f          	amoand.d	zero,a5,(a4)
ffffffffc0200e82:	8082                	ret
ffffffffc0200e84:	8082                	ret
ffffffffc0200e86:	4501                	li	a0,0
ffffffffc0200e88:	8082                	ret
ffffffffc0200e8a:	1141                	addi	sp,sp,-16
ffffffffc0200e8c:	00004697          	auipc	a3,0x4
ffffffffc0200e90:	aa468693          	addi	a3,a3,-1372 # ffffffffc0204930 <commands+0x808>
ffffffffc0200e94:	00004617          	auipc	a2,0x4
ffffffffc0200e98:	aa460613          	addi	a2,a2,-1372 # ffffffffc0204938 <commands+0x810>
ffffffffc0200e9c:	06800593          	li	a1,104
ffffffffc0200ea0:	00004517          	auipc	a0,0x4
ffffffffc0200ea4:	ab050513          	addi	a0,a0,-1360 # ffffffffc0204950 <commands+0x828>
ffffffffc0200ea8:	e406                	sd	ra,8(sp)
ffffffffc0200eaa:	db0ff0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0200eae <default_check>:
ffffffffc0200eae:	715d                	addi	sp,sp,-80
ffffffffc0200eb0:	e0a2                	sd	s0,64(sp)
ffffffffc0200eb2:	00008417          	auipc	s0,0x8
ffffffffc0200eb6:	57e40413          	addi	s0,s0,1406 # ffffffffc0209430 <free_area>
ffffffffc0200eba:	641c                	ld	a5,8(s0)
ffffffffc0200ebc:	e486                	sd	ra,72(sp)
ffffffffc0200ebe:	fc26                	sd	s1,56(sp)
ffffffffc0200ec0:	f84a                	sd	s2,48(sp)
ffffffffc0200ec2:	f44e                	sd	s3,40(sp)
ffffffffc0200ec4:	f052                	sd	s4,32(sp)
ffffffffc0200ec6:	ec56                	sd	s5,24(sp)
ffffffffc0200ec8:	e85a                	sd	s6,16(sp)
ffffffffc0200eca:	e45e                	sd	s7,8(sp)
ffffffffc0200ecc:	e062                	sd	s8,0(sp)
ffffffffc0200ece:	2a878d63          	beq	a5,s0,ffffffffc0201188 <default_check+0x2da>
ffffffffc0200ed2:	4481                	li	s1,0
ffffffffc0200ed4:	4901                	li	s2,0
ffffffffc0200ed6:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200eda:	8b09                	andi	a4,a4,2
ffffffffc0200edc:	2a070a63          	beqz	a4,ffffffffc0201190 <default_check+0x2e2>
ffffffffc0200ee0:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ee4:	679c                	ld	a5,8(a5)
ffffffffc0200ee6:	2905                	addiw	s2,s2,1
ffffffffc0200ee8:	9cb9                	addw	s1,s1,a4
ffffffffc0200eea:	fe8796e3          	bne	a5,s0,ffffffffc0200ed6 <default_check+0x28>
ffffffffc0200eee:	89a6                	mv	s3,s1
ffffffffc0200ef0:	627000ef          	jal	ra,ffffffffc0201d16 <nr_free_pages>
ffffffffc0200ef4:	6f351e63          	bne	a0,s3,ffffffffc02015f0 <default_check+0x742>
ffffffffc0200ef8:	4505                	li	a0,1
ffffffffc0200efa:	59f000ef          	jal	ra,ffffffffc0201c98 <alloc_pages>
ffffffffc0200efe:	8aaa                	mv	s5,a0
ffffffffc0200f00:	42050863          	beqz	a0,ffffffffc0201330 <default_check+0x482>
ffffffffc0200f04:	4505                	li	a0,1
ffffffffc0200f06:	593000ef          	jal	ra,ffffffffc0201c98 <alloc_pages>
ffffffffc0200f0a:	89aa                	mv	s3,a0
ffffffffc0200f0c:	70050263          	beqz	a0,ffffffffc0201610 <default_check+0x762>
ffffffffc0200f10:	4505                	li	a0,1
ffffffffc0200f12:	587000ef          	jal	ra,ffffffffc0201c98 <alloc_pages>
ffffffffc0200f16:	8a2a                	mv	s4,a0
ffffffffc0200f18:	48050c63          	beqz	a0,ffffffffc02013b0 <default_check+0x502>
ffffffffc0200f1c:	293a8a63          	beq	s5,s3,ffffffffc02011b0 <default_check+0x302>
ffffffffc0200f20:	28aa8863          	beq	s5,a0,ffffffffc02011b0 <default_check+0x302>
ffffffffc0200f24:	28a98663          	beq	s3,a0,ffffffffc02011b0 <default_check+0x302>
ffffffffc0200f28:	000aa783          	lw	a5,0(s5)
ffffffffc0200f2c:	2a079263          	bnez	a5,ffffffffc02011d0 <default_check+0x322>
ffffffffc0200f30:	0009a783          	lw	a5,0(s3)
ffffffffc0200f34:	28079e63          	bnez	a5,ffffffffc02011d0 <default_check+0x322>
ffffffffc0200f38:	411c                	lw	a5,0(a0)
ffffffffc0200f3a:	28079b63          	bnez	a5,ffffffffc02011d0 <default_check+0x322>
ffffffffc0200f3e:	0000c797          	auipc	a5,0xc
ffffffffc0200f42:	57a7b783          	ld	a5,1402(a5) # ffffffffc020d4b8 <pages>
ffffffffc0200f46:	40fa8733          	sub	a4,s5,a5
ffffffffc0200f4a:	00005617          	auipc	a2,0x5
ffffffffc0200f4e:	abe63603          	ld	a2,-1346(a2) # ffffffffc0205a08 <nbase>
ffffffffc0200f52:	8719                	srai	a4,a4,0x6
ffffffffc0200f54:	9732                	add	a4,a4,a2
ffffffffc0200f56:	0000c697          	auipc	a3,0xc
ffffffffc0200f5a:	55a6b683          	ld	a3,1370(a3) # ffffffffc020d4b0 <npage>
ffffffffc0200f5e:	06b2                	slli	a3,a3,0xc
ffffffffc0200f60:	0732                	slli	a4,a4,0xc
ffffffffc0200f62:	28d77763          	bgeu	a4,a3,ffffffffc02011f0 <default_check+0x342>
ffffffffc0200f66:	40f98733          	sub	a4,s3,a5
ffffffffc0200f6a:	8719                	srai	a4,a4,0x6
ffffffffc0200f6c:	9732                	add	a4,a4,a2
ffffffffc0200f6e:	0732                	slli	a4,a4,0xc
ffffffffc0200f70:	4cd77063          	bgeu	a4,a3,ffffffffc0201430 <default_check+0x582>
ffffffffc0200f74:	40f507b3          	sub	a5,a0,a5
ffffffffc0200f78:	8799                	srai	a5,a5,0x6
ffffffffc0200f7a:	97b2                	add	a5,a5,a2
ffffffffc0200f7c:	07b2                	slli	a5,a5,0xc
ffffffffc0200f7e:	30d7f963          	bgeu	a5,a3,ffffffffc0201290 <default_check+0x3e2>
ffffffffc0200f82:	4505                	li	a0,1
ffffffffc0200f84:	00043c03          	ld	s8,0(s0)
ffffffffc0200f88:	00843b83          	ld	s7,8(s0)
ffffffffc0200f8c:	01042b03          	lw	s6,16(s0)
ffffffffc0200f90:	e400                	sd	s0,8(s0)
ffffffffc0200f92:	e000                	sd	s0,0(s0)
ffffffffc0200f94:	00008797          	auipc	a5,0x8
ffffffffc0200f98:	4a07a623          	sw	zero,1196(a5) # ffffffffc0209440 <free_area+0x10>
ffffffffc0200f9c:	4fd000ef          	jal	ra,ffffffffc0201c98 <alloc_pages>
ffffffffc0200fa0:	2c051863          	bnez	a0,ffffffffc0201270 <default_check+0x3c2>
ffffffffc0200fa4:	4585                	li	a1,1
ffffffffc0200fa6:	8556                	mv	a0,s5
ffffffffc0200fa8:	52f000ef          	jal	ra,ffffffffc0201cd6 <free_pages>
ffffffffc0200fac:	4585                	li	a1,1
ffffffffc0200fae:	854e                	mv	a0,s3
ffffffffc0200fb0:	527000ef          	jal	ra,ffffffffc0201cd6 <free_pages>
ffffffffc0200fb4:	4585                	li	a1,1
ffffffffc0200fb6:	8552                	mv	a0,s4
ffffffffc0200fb8:	51f000ef          	jal	ra,ffffffffc0201cd6 <free_pages>
ffffffffc0200fbc:	4818                	lw	a4,16(s0)
ffffffffc0200fbe:	478d                	li	a5,3
ffffffffc0200fc0:	28f71863          	bne	a4,a5,ffffffffc0201250 <default_check+0x3a2>
ffffffffc0200fc4:	4505                	li	a0,1
ffffffffc0200fc6:	4d3000ef          	jal	ra,ffffffffc0201c98 <alloc_pages>
ffffffffc0200fca:	89aa                	mv	s3,a0
ffffffffc0200fcc:	26050263          	beqz	a0,ffffffffc0201230 <default_check+0x382>
ffffffffc0200fd0:	4505                	li	a0,1
ffffffffc0200fd2:	4c7000ef          	jal	ra,ffffffffc0201c98 <alloc_pages>
ffffffffc0200fd6:	8aaa                	mv	s5,a0
ffffffffc0200fd8:	3a050c63          	beqz	a0,ffffffffc0201390 <default_check+0x4e2>
ffffffffc0200fdc:	4505                	li	a0,1
ffffffffc0200fde:	4bb000ef          	jal	ra,ffffffffc0201c98 <alloc_pages>
ffffffffc0200fe2:	8a2a                	mv	s4,a0
ffffffffc0200fe4:	38050663          	beqz	a0,ffffffffc0201370 <default_check+0x4c2>
ffffffffc0200fe8:	4505                	li	a0,1
ffffffffc0200fea:	4af000ef          	jal	ra,ffffffffc0201c98 <alloc_pages>
ffffffffc0200fee:	36051163          	bnez	a0,ffffffffc0201350 <default_check+0x4a2>
ffffffffc0200ff2:	4585                	li	a1,1
ffffffffc0200ff4:	854e                	mv	a0,s3
ffffffffc0200ff6:	4e1000ef          	jal	ra,ffffffffc0201cd6 <free_pages>
ffffffffc0200ffa:	641c                	ld	a5,8(s0)
ffffffffc0200ffc:	20878a63          	beq	a5,s0,ffffffffc0201210 <default_check+0x362>
ffffffffc0201000:	4505                	li	a0,1
ffffffffc0201002:	497000ef          	jal	ra,ffffffffc0201c98 <alloc_pages>
ffffffffc0201006:	30a99563          	bne	s3,a0,ffffffffc0201310 <default_check+0x462>
ffffffffc020100a:	4505                	li	a0,1
ffffffffc020100c:	48d000ef          	jal	ra,ffffffffc0201c98 <alloc_pages>
ffffffffc0201010:	2e051063          	bnez	a0,ffffffffc02012f0 <default_check+0x442>
ffffffffc0201014:	481c                	lw	a5,16(s0)
ffffffffc0201016:	2a079d63          	bnez	a5,ffffffffc02012d0 <default_check+0x422>
ffffffffc020101a:	854e                	mv	a0,s3
ffffffffc020101c:	4585                	li	a1,1
ffffffffc020101e:	01843023          	sd	s8,0(s0)
ffffffffc0201022:	01743423          	sd	s7,8(s0)
ffffffffc0201026:	01642823          	sw	s6,16(s0)
ffffffffc020102a:	4ad000ef          	jal	ra,ffffffffc0201cd6 <free_pages>
ffffffffc020102e:	4585                	li	a1,1
ffffffffc0201030:	8556                	mv	a0,s5
ffffffffc0201032:	4a5000ef          	jal	ra,ffffffffc0201cd6 <free_pages>
ffffffffc0201036:	4585                	li	a1,1
ffffffffc0201038:	8552                	mv	a0,s4
ffffffffc020103a:	49d000ef          	jal	ra,ffffffffc0201cd6 <free_pages>
ffffffffc020103e:	4515                	li	a0,5
ffffffffc0201040:	459000ef          	jal	ra,ffffffffc0201c98 <alloc_pages>
ffffffffc0201044:	89aa                	mv	s3,a0
ffffffffc0201046:	26050563          	beqz	a0,ffffffffc02012b0 <default_check+0x402>
ffffffffc020104a:	651c                	ld	a5,8(a0)
ffffffffc020104c:	8385                	srli	a5,a5,0x1
ffffffffc020104e:	8b85                	andi	a5,a5,1
ffffffffc0201050:	54079063          	bnez	a5,ffffffffc0201590 <default_check+0x6e2>
ffffffffc0201054:	4505                	li	a0,1
ffffffffc0201056:	00043b03          	ld	s6,0(s0)
ffffffffc020105a:	00843a83          	ld	s5,8(s0)
ffffffffc020105e:	e000                	sd	s0,0(s0)
ffffffffc0201060:	e400                	sd	s0,8(s0)
ffffffffc0201062:	437000ef          	jal	ra,ffffffffc0201c98 <alloc_pages>
ffffffffc0201066:	50051563          	bnez	a0,ffffffffc0201570 <default_check+0x6c2>
ffffffffc020106a:	08098a13          	addi	s4,s3,128
ffffffffc020106e:	8552                	mv	a0,s4
ffffffffc0201070:	458d                	li	a1,3
ffffffffc0201072:	01042b83          	lw	s7,16(s0)
ffffffffc0201076:	00008797          	auipc	a5,0x8
ffffffffc020107a:	3c07a523          	sw	zero,970(a5) # ffffffffc0209440 <free_area+0x10>
ffffffffc020107e:	459000ef          	jal	ra,ffffffffc0201cd6 <free_pages>
ffffffffc0201082:	4511                	li	a0,4
ffffffffc0201084:	415000ef          	jal	ra,ffffffffc0201c98 <alloc_pages>
ffffffffc0201088:	4c051463          	bnez	a0,ffffffffc0201550 <default_check+0x6a2>
ffffffffc020108c:	0889b783          	ld	a5,136(s3)
ffffffffc0201090:	8385                	srli	a5,a5,0x1
ffffffffc0201092:	8b85                	andi	a5,a5,1
ffffffffc0201094:	48078e63          	beqz	a5,ffffffffc0201530 <default_check+0x682>
ffffffffc0201098:	0909a703          	lw	a4,144(s3)
ffffffffc020109c:	478d                	li	a5,3
ffffffffc020109e:	48f71963          	bne	a4,a5,ffffffffc0201530 <default_check+0x682>
ffffffffc02010a2:	450d                	li	a0,3
ffffffffc02010a4:	3f5000ef          	jal	ra,ffffffffc0201c98 <alloc_pages>
ffffffffc02010a8:	8c2a                	mv	s8,a0
ffffffffc02010aa:	46050363          	beqz	a0,ffffffffc0201510 <default_check+0x662>
ffffffffc02010ae:	4505                	li	a0,1
ffffffffc02010b0:	3e9000ef          	jal	ra,ffffffffc0201c98 <alloc_pages>
ffffffffc02010b4:	42051e63          	bnez	a0,ffffffffc02014f0 <default_check+0x642>
ffffffffc02010b8:	418a1c63          	bne	s4,s8,ffffffffc02014d0 <default_check+0x622>
ffffffffc02010bc:	4585                	li	a1,1
ffffffffc02010be:	854e                	mv	a0,s3
ffffffffc02010c0:	417000ef          	jal	ra,ffffffffc0201cd6 <free_pages>
ffffffffc02010c4:	458d                	li	a1,3
ffffffffc02010c6:	8552                	mv	a0,s4
ffffffffc02010c8:	40f000ef          	jal	ra,ffffffffc0201cd6 <free_pages>
ffffffffc02010cc:	0089b783          	ld	a5,8(s3)
ffffffffc02010d0:	04098c13          	addi	s8,s3,64
ffffffffc02010d4:	8385                	srli	a5,a5,0x1
ffffffffc02010d6:	8b85                	andi	a5,a5,1
ffffffffc02010d8:	3c078c63          	beqz	a5,ffffffffc02014b0 <default_check+0x602>
ffffffffc02010dc:	0109a703          	lw	a4,16(s3)
ffffffffc02010e0:	4785                	li	a5,1
ffffffffc02010e2:	3cf71763          	bne	a4,a5,ffffffffc02014b0 <default_check+0x602>
ffffffffc02010e6:	008a3783          	ld	a5,8(s4)
ffffffffc02010ea:	8385                	srli	a5,a5,0x1
ffffffffc02010ec:	8b85                	andi	a5,a5,1
ffffffffc02010ee:	3a078163          	beqz	a5,ffffffffc0201490 <default_check+0x5e2>
ffffffffc02010f2:	010a2703          	lw	a4,16(s4)
ffffffffc02010f6:	478d                	li	a5,3
ffffffffc02010f8:	38f71c63          	bne	a4,a5,ffffffffc0201490 <default_check+0x5e2>
ffffffffc02010fc:	4505                	li	a0,1
ffffffffc02010fe:	39b000ef          	jal	ra,ffffffffc0201c98 <alloc_pages>
ffffffffc0201102:	36a99763          	bne	s3,a0,ffffffffc0201470 <default_check+0x5c2>
ffffffffc0201106:	4585                	li	a1,1
ffffffffc0201108:	3cf000ef          	jal	ra,ffffffffc0201cd6 <free_pages>
ffffffffc020110c:	4509                	li	a0,2
ffffffffc020110e:	38b000ef          	jal	ra,ffffffffc0201c98 <alloc_pages>
ffffffffc0201112:	32aa1f63          	bne	s4,a0,ffffffffc0201450 <default_check+0x5a2>
ffffffffc0201116:	4589                	li	a1,2
ffffffffc0201118:	3bf000ef          	jal	ra,ffffffffc0201cd6 <free_pages>
ffffffffc020111c:	4585                	li	a1,1
ffffffffc020111e:	8562                	mv	a0,s8
ffffffffc0201120:	3b7000ef          	jal	ra,ffffffffc0201cd6 <free_pages>
ffffffffc0201124:	4515                	li	a0,5
ffffffffc0201126:	373000ef          	jal	ra,ffffffffc0201c98 <alloc_pages>
ffffffffc020112a:	89aa                	mv	s3,a0
ffffffffc020112c:	48050263          	beqz	a0,ffffffffc02015b0 <default_check+0x702>
ffffffffc0201130:	4505                	li	a0,1
ffffffffc0201132:	367000ef          	jal	ra,ffffffffc0201c98 <alloc_pages>
ffffffffc0201136:	2c051d63          	bnez	a0,ffffffffc0201410 <default_check+0x562>
ffffffffc020113a:	481c                	lw	a5,16(s0)
ffffffffc020113c:	2a079a63          	bnez	a5,ffffffffc02013f0 <default_check+0x542>
ffffffffc0201140:	4595                	li	a1,5
ffffffffc0201142:	854e                	mv	a0,s3
ffffffffc0201144:	01742823          	sw	s7,16(s0)
ffffffffc0201148:	01643023          	sd	s6,0(s0)
ffffffffc020114c:	01543423          	sd	s5,8(s0)
ffffffffc0201150:	387000ef          	jal	ra,ffffffffc0201cd6 <free_pages>
ffffffffc0201154:	641c                	ld	a5,8(s0)
ffffffffc0201156:	00878963          	beq	a5,s0,ffffffffc0201168 <default_check+0x2ba>
ffffffffc020115a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020115e:	679c                	ld	a5,8(a5)
ffffffffc0201160:	397d                	addiw	s2,s2,-1
ffffffffc0201162:	9c99                	subw	s1,s1,a4
ffffffffc0201164:	fe879be3          	bne	a5,s0,ffffffffc020115a <default_check+0x2ac>
ffffffffc0201168:	26091463          	bnez	s2,ffffffffc02013d0 <default_check+0x522>
ffffffffc020116c:	46049263          	bnez	s1,ffffffffc02015d0 <default_check+0x722>
ffffffffc0201170:	60a6                	ld	ra,72(sp)
ffffffffc0201172:	6406                	ld	s0,64(sp)
ffffffffc0201174:	74e2                	ld	s1,56(sp)
ffffffffc0201176:	7942                	ld	s2,48(sp)
ffffffffc0201178:	79a2                	ld	s3,40(sp)
ffffffffc020117a:	7a02                	ld	s4,32(sp)
ffffffffc020117c:	6ae2                	ld	s5,24(sp)
ffffffffc020117e:	6b42                	ld	s6,16(sp)
ffffffffc0201180:	6ba2                	ld	s7,8(sp)
ffffffffc0201182:	6c02                	ld	s8,0(sp)
ffffffffc0201184:	6161                	addi	sp,sp,80
ffffffffc0201186:	8082                	ret
ffffffffc0201188:	4981                	li	s3,0
ffffffffc020118a:	4481                	li	s1,0
ffffffffc020118c:	4901                	li	s2,0
ffffffffc020118e:	b38d                	j	ffffffffc0200ef0 <default_check+0x42>
ffffffffc0201190:	00003697          	auipc	a3,0x3
ffffffffc0201194:	7d868693          	addi	a3,a3,2008 # ffffffffc0204968 <commands+0x840>
ffffffffc0201198:	00003617          	auipc	a2,0x3
ffffffffc020119c:	7a060613          	addi	a2,a2,1952 # ffffffffc0204938 <commands+0x810>
ffffffffc02011a0:	10700593          	li	a1,263
ffffffffc02011a4:	00003517          	auipc	a0,0x3
ffffffffc02011a8:	7ac50513          	addi	a0,a0,1964 # ffffffffc0204950 <commands+0x828>
ffffffffc02011ac:	aaeff0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02011b0:	00004697          	auipc	a3,0x4
ffffffffc02011b4:	84868693          	addi	a3,a3,-1976 # ffffffffc02049f8 <commands+0x8d0>
ffffffffc02011b8:	00003617          	auipc	a2,0x3
ffffffffc02011bc:	78060613          	addi	a2,a2,1920 # ffffffffc0204938 <commands+0x810>
ffffffffc02011c0:	0d400593          	li	a1,212
ffffffffc02011c4:	00003517          	auipc	a0,0x3
ffffffffc02011c8:	78c50513          	addi	a0,a0,1932 # ffffffffc0204950 <commands+0x828>
ffffffffc02011cc:	a8eff0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02011d0:	00004697          	auipc	a3,0x4
ffffffffc02011d4:	85068693          	addi	a3,a3,-1968 # ffffffffc0204a20 <commands+0x8f8>
ffffffffc02011d8:	00003617          	auipc	a2,0x3
ffffffffc02011dc:	76060613          	addi	a2,a2,1888 # ffffffffc0204938 <commands+0x810>
ffffffffc02011e0:	0d500593          	li	a1,213
ffffffffc02011e4:	00003517          	auipc	a0,0x3
ffffffffc02011e8:	76c50513          	addi	a0,a0,1900 # ffffffffc0204950 <commands+0x828>
ffffffffc02011ec:	a6eff0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02011f0:	00004697          	auipc	a3,0x4
ffffffffc02011f4:	87068693          	addi	a3,a3,-1936 # ffffffffc0204a60 <commands+0x938>
ffffffffc02011f8:	00003617          	auipc	a2,0x3
ffffffffc02011fc:	74060613          	addi	a2,a2,1856 # ffffffffc0204938 <commands+0x810>
ffffffffc0201200:	0d700593          	li	a1,215
ffffffffc0201204:	00003517          	auipc	a0,0x3
ffffffffc0201208:	74c50513          	addi	a0,a0,1868 # ffffffffc0204950 <commands+0x828>
ffffffffc020120c:	a4eff0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201210:	00004697          	auipc	a3,0x4
ffffffffc0201214:	8d868693          	addi	a3,a3,-1832 # ffffffffc0204ae8 <commands+0x9c0>
ffffffffc0201218:	00003617          	auipc	a2,0x3
ffffffffc020121c:	72060613          	addi	a2,a2,1824 # ffffffffc0204938 <commands+0x810>
ffffffffc0201220:	0f000593          	li	a1,240
ffffffffc0201224:	00003517          	auipc	a0,0x3
ffffffffc0201228:	72c50513          	addi	a0,a0,1836 # ffffffffc0204950 <commands+0x828>
ffffffffc020122c:	a2eff0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201230:	00003697          	auipc	a3,0x3
ffffffffc0201234:	76868693          	addi	a3,a3,1896 # ffffffffc0204998 <commands+0x870>
ffffffffc0201238:	00003617          	auipc	a2,0x3
ffffffffc020123c:	70060613          	addi	a2,a2,1792 # ffffffffc0204938 <commands+0x810>
ffffffffc0201240:	0e900593          	li	a1,233
ffffffffc0201244:	00003517          	auipc	a0,0x3
ffffffffc0201248:	70c50513          	addi	a0,a0,1804 # ffffffffc0204950 <commands+0x828>
ffffffffc020124c:	a0eff0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201250:	00004697          	auipc	a3,0x4
ffffffffc0201254:	88868693          	addi	a3,a3,-1912 # ffffffffc0204ad8 <commands+0x9b0>
ffffffffc0201258:	00003617          	auipc	a2,0x3
ffffffffc020125c:	6e060613          	addi	a2,a2,1760 # ffffffffc0204938 <commands+0x810>
ffffffffc0201260:	0e700593          	li	a1,231
ffffffffc0201264:	00003517          	auipc	a0,0x3
ffffffffc0201268:	6ec50513          	addi	a0,a0,1772 # ffffffffc0204950 <commands+0x828>
ffffffffc020126c:	9eeff0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201270:	00004697          	auipc	a3,0x4
ffffffffc0201274:	85068693          	addi	a3,a3,-1968 # ffffffffc0204ac0 <commands+0x998>
ffffffffc0201278:	00003617          	auipc	a2,0x3
ffffffffc020127c:	6c060613          	addi	a2,a2,1728 # ffffffffc0204938 <commands+0x810>
ffffffffc0201280:	0e200593          	li	a1,226
ffffffffc0201284:	00003517          	auipc	a0,0x3
ffffffffc0201288:	6cc50513          	addi	a0,a0,1740 # ffffffffc0204950 <commands+0x828>
ffffffffc020128c:	9ceff0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201290:	00004697          	auipc	a3,0x4
ffffffffc0201294:	81068693          	addi	a3,a3,-2032 # ffffffffc0204aa0 <commands+0x978>
ffffffffc0201298:	00003617          	auipc	a2,0x3
ffffffffc020129c:	6a060613          	addi	a2,a2,1696 # ffffffffc0204938 <commands+0x810>
ffffffffc02012a0:	0d900593          	li	a1,217
ffffffffc02012a4:	00003517          	auipc	a0,0x3
ffffffffc02012a8:	6ac50513          	addi	a0,a0,1708 # ffffffffc0204950 <commands+0x828>
ffffffffc02012ac:	9aeff0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02012b0:	00004697          	auipc	a3,0x4
ffffffffc02012b4:	88068693          	addi	a3,a3,-1920 # ffffffffc0204b30 <commands+0xa08>
ffffffffc02012b8:	00003617          	auipc	a2,0x3
ffffffffc02012bc:	68060613          	addi	a2,a2,1664 # ffffffffc0204938 <commands+0x810>
ffffffffc02012c0:	10f00593          	li	a1,271
ffffffffc02012c4:	00003517          	auipc	a0,0x3
ffffffffc02012c8:	68c50513          	addi	a0,a0,1676 # ffffffffc0204950 <commands+0x828>
ffffffffc02012cc:	98eff0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02012d0:	00004697          	auipc	a3,0x4
ffffffffc02012d4:	85068693          	addi	a3,a3,-1968 # ffffffffc0204b20 <commands+0x9f8>
ffffffffc02012d8:	00003617          	auipc	a2,0x3
ffffffffc02012dc:	66060613          	addi	a2,a2,1632 # ffffffffc0204938 <commands+0x810>
ffffffffc02012e0:	0f600593          	li	a1,246
ffffffffc02012e4:	00003517          	auipc	a0,0x3
ffffffffc02012e8:	66c50513          	addi	a0,a0,1644 # ffffffffc0204950 <commands+0x828>
ffffffffc02012ec:	96eff0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02012f0:	00003697          	auipc	a3,0x3
ffffffffc02012f4:	7d068693          	addi	a3,a3,2000 # ffffffffc0204ac0 <commands+0x998>
ffffffffc02012f8:	00003617          	auipc	a2,0x3
ffffffffc02012fc:	64060613          	addi	a2,a2,1600 # ffffffffc0204938 <commands+0x810>
ffffffffc0201300:	0f400593          	li	a1,244
ffffffffc0201304:	00003517          	auipc	a0,0x3
ffffffffc0201308:	64c50513          	addi	a0,a0,1612 # ffffffffc0204950 <commands+0x828>
ffffffffc020130c:	94eff0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201310:	00003697          	auipc	a3,0x3
ffffffffc0201314:	7f068693          	addi	a3,a3,2032 # ffffffffc0204b00 <commands+0x9d8>
ffffffffc0201318:	00003617          	auipc	a2,0x3
ffffffffc020131c:	62060613          	addi	a2,a2,1568 # ffffffffc0204938 <commands+0x810>
ffffffffc0201320:	0f300593          	li	a1,243
ffffffffc0201324:	00003517          	auipc	a0,0x3
ffffffffc0201328:	62c50513          	addi	a0,a0,1580 # ffffffffc0204950 <commands+0x828>
ffffffffc020132c:	92eff0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201330:	00003697          	auipc	a3,0x3
ffffffffc0201334:	66868693          	addi	a3,a3,1640 # ffffffffc0204998 <commands+0x870>
ffffffffc0201338:	00003617          	auipc	a2,0x3
ffffffffc020133c:	60060613          	addi	a2,a2,1536 # ffffffffc0204938 <commands+0x810>
ffffffffc0201340:	0d000593          	li	a1,208
ffffffffc0201344:	00003517          	auipc	a0,0x3
ffffffffc0201348:	60c50513          	addi	a0,a0,1548 # ffffffffc0204950 <commands+0x828>
ffffffffc020134c:	90eff0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201350:	00003697          	auipc	a3,0x3
ffffffffc0201354:	77068693          	addi	a3,a3,1904 # ffffffffc0204ac0 <commands+0x998>
ffffffffc0201358:	00003617          	auipc	a2,0x3
ffffffffc020135c:	5e060613          	addi	a2,a2,1504 # ffffffffc0204938 <commands+0x810>
ffffffffc0201360:	0ed00593          	li	a1,237
ffffffffc0201364:	00003517          	auipc	a0,0x3
ffffffffc0201368:	5ec50513          	addi	a0,a0,1516 # ffffffffc0204950 <commands+0x828>
ffffffffc020136c:	8eeff0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201370:	00003697          	auipc	a3,0x3
ffffffffc0201374:	66868693          	addi	a3,a3,1640 # ffffffffc02049d8 <commands+0x8b0>
ffffffffc0201378:	00003617          	auipc	a2,0x3
ffffffffc020137c:	5c060613          	addi	a2,a2,1472 # ffffffffc0204938 <commands+0x810>
ffffffffc0201380:	0eb00593          	li	a1,235
ffffffffc0201384:	00003517          	auipc	a0,0x3
ffffffffc0201388:	5cc50513          	addi	a0,a0,1484 # ffffffffc0204950 <commands+0x828>
ffffffffc020138c:	8ceff0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201390:	00003697          	auipc	a3,0x3
ffffffffc0201394:	62868693          	addi	a3,a3,1576 # ffffffffc02049b8 <commands+0x890>
ffffffffc0201398:	00003617          	auipc	a2,0x3
ffffffffc020139c:	5a060613          	addi	a2,a2,1440 # ffffffffc0204938 <commands+0x810>
ffffffffc02013a0:	0ea00593          	li	a1,234
ffffffffc02013a4:	00003517          	auipc	a0,0x3
ffffffffc02013a8:	5ac50513          	addi	a0,a0,1452 # ffffffffc0204950 <commands+0x828>
ffffffffc02013ac:	8aeff0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02013b0:	00003697          	auipc	a3,0x3
ffffffffc02013b4:	62868693          	addi	a3,a3,1576 # ffffffffc02049d8 <commands+0x8b0>
ffffffffc02013b8:	00003617          	auipc	a2,0x3
ffffffffc02013bc:	58060613          	addi	a2,a2,1408 # ffffffffc0204938 <commands+0x810>
ffffffffc02013c0:	0d200593          	li	a1,210
ffffffffc02013c4:	00003517          	auipc	a0,0x3
ffffffffc02013c8:	58c50513          	addi	a0,a0,1420 # ffffffffc0204950 <commands+0x828>
ffffffffc02013cc:	88eff0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02013d0:	00004697          	auipc	a3,0x4
ffffffffc02013d4:	8b068693          	addi	a3,a3,-1872 # ffffffffc0204c80 <commands+0xb58>
ffffffffc02013d8:	00003617          	auipc	a2,0x3
ffffffffc02013dc:	56060613          	addi	a2,a2,1376 # ffffffffc0204938 <commands+0x810>
ffffffffc02013e0:	13c00593          	li	a1,316
ffffffffc02013e4:	00003517          	auipc	a0,0x3
ffffffffc02013e8:	56c50513          	addi	a0,a0,1388 # ffffffffc0204950 <commands+0x828>
ffffffffc02013ec:	86eff0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02013f0:	00003697          	auipc	a3,0x3
ffffffffc02013f4:	73068693          	addi	a3,a3,1840 # ffffffffc0204b20 <commands+0x9f8>
ffffffffc02013f8:	00003617          	auipc	a2,0x3
ffffffffc02013fc:	54060613          	addi	a2,a2,1344 # ffffffffc0204938 <commands+0x810>
ffffffffc0201400:	13100593          	li	a1,305
ffffffffc0201404:	00003517          	auipc	a0,0x3
ffffffffc0201408:	54c50513          	addi	a0,a0,1356 # ffffffffc0204950 <commands+0x828>
ffffffffc020140c:	84eff0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201410:	00003697          	auipc	a3,0x3
ffffffffc0201414:	6b068693          	addi	a3,a3,1712 # ffffffffc0204ac0 <commands+0x998>
ffffffffc0201418:	00003617          	auipc	a2,0x3
ffffffffc020141c:	52060613          	addi	a2,a2,1312 # ffffffffc0204938 <commands+0x810>
ffffffffc0201420:	12f00593          	li	a1,303
ffffffffc0201424:	00003517          	auipc	a0,0x3
ffffffffc0201428:	52c50513          	addi	a0,a0,1324 # ffffffffc0204950 <commands+0x828>
ffffffffc020142c:	82eff0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201430:	00003697          	auipc	a3,0x3
ffffffffc0201434:	65068693          	addi	a3,a3,1616 # ffffffffc0204a80 <commands+0x958>
ffffffffc0201438:	00003617          	auipc	a2,0x3
ffffffffc020143c:	50060613          	addi	a2,a2,1280 # ffffffffc0204938 <commands+0x810>
ffffffffc0201440:	0d800593          	li	a1,216
ffffffffc0201444:	00003517          	auipc	a0,0x3
ffffffffc0201448:	50c50513          	addi	a0,a0,1292 # ffffffffc0204950 <commands+0x828>
ffffffffc020144c:	80eff0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201450:	00003697          	auipc	a3,0x3
ffffffffc0201454:	7f068693          	addi	a3,a3,2032 # ffffffffc0204c40 <commands+0xb18>
ffffffffc0201458:	00003617          	auipc	a2,0x3
ffffffffc020145c:	4e060613          	addi	a2,a2,1248 # ffffffffc0204938 <commands+0x810>
ffffffffc0201460:	12900593          	li	a1,297
ffffffffc0201464:	00003517          	auipc	a0,0x3
ffffffffc0201468:	4ec50513          	addi	a0,a0,1260 # ffffffffc0204950 <commands+0x828>
ffffffffc020146c:	feffe0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201470:	00003697          	auipc	a3,0x3
ffffffffc0201474:	7b068693          	addi	a3,a3,1968 # ffffffffc0204c20 <commands+0xaf8>
ffffffffc0201478:	00003617          	auipc	a2,0x3
ffffffffc020147c:	4c060613          	addi	a2,a2,1216 # ffffffffc0204938 <commands+0x810>
ffffffffc0201480:	12700593          	li	a1,295
ffffffffc0201484:	00003517          	auipc	a0,0x3
ffffffffc0201488:	4cc50513          	addi	a0,a0,1228 # ffffffffc0204950 <commands+0x828>
ffffffffc020148c:	fcffe0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201490:	00003697          	auipc	a3,0x3
ffffffffc0201494:	76868693          	addi	a3,a3,1896 # ffffffffc0204bf8 <commands+0xad0>
ffffffffc0201498:	00003617          	auipc	a2,0x3
ffffffffc020149c:	4a060613          	addi	a2,a2,1184 # ffffffffc0204938 <commands+0x810>
ffffffffc02014a0:	12500593          	li	a1,293
ffffffffc02014a4:	00003517          	auipc	a0,0x3
ffffffffc02014a8:	4ac50513          	addi	a0,a0,1196 # ffffffffc0204950 <commands+0x828>
ffffffffc02014ac:	faffe0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02014b0:	00003697          	auipc	a3,0x3
ffffffffc02014b4:	72068693          	addi	a3,a3,1824 # ffffffffc0204bd0 <commands+0xaa8>
ffffffffc02014b8:	00003617          	auipc	a2,0x3
ffffffffc02014bc:	48060613          	addi	a2,a2,1152 # ffffffffc0204938 <commands+0x810>
ffffffffc02014c0:	12400593          	li	a1,292
ffffffffc02014c4:	00003517          	auipc	a0,0x3
ffffffffc02014c8:	48c50513          	addi	a0,a0,1164 # ffffffffc0204950 <commands+0x828>
ffffffffc02014cc:	f8ffe0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02014d0:	00003697          	auipc	a3,0x3
ffffffffc02014d4:	6f068693          	addi	a3,a3,1776 # ffffffffc0204bc0 <commands+0xa98>
ffffffffc02014d8:	00003617          	auipc	a2,0x3
ffffffffc02014dc:	46060613          	addi	a2,a2,1120 # ffffffffc0204938 <commands+0x810>
ffffffffc02014e0:	11f00593          	li	a1,287
ffffffffc02014e4:	00003517          	auipc	a0,0x3
ffffffffc02014e8:	46c50513          	addi	a0,a0,1132 # ffffffffc0204950 <commands+0x828>
ffffffffc02014ec:	f6ffe0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02014f0:	00003697          	auipc	a3,0x3
ffffffffc02014f4:	5d068693          	addi	a3,a3,1488 # ffffffffc0204ac0 <commands+0x998>
ffffffffc02014f8:	00003617          	auipc	a2,0x3
ffffffffc02014fc:	44060613          	addi	a2,a2,1088 # ffffffffc0204938 <commands+0x810>
ffffffffc0201500:	11e00593          	li	a1,286
ffffffffc0201504:	00003517          	auipc	a0,0x3
ffffffffc0201508:	44c50513          	addi	a0,a0,1100 # ffffffffc0204950 <commands+0x828>
ffffffffc020150c:	f4ffe0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201510:	00003697          	auipc	a3,0x3
ffffffffc0201514:	69068693          	addi	a3,a3,1680 # ffffffffc0204ba0 <commands+0xa78>
ffffffffc0201518:	00003617          	auipc	a2,0x3
ffffffffc020151c:	42060613          	addi	a2,a2,1056 # ffffffffc0204938 <commands+0x810>
ffffffffc0201520:	11d00593          	li	a1,285
ffffffffc0201524:	00003517          	auipc	a0,0x3
ffffffffc0201528:	42c50513          	addi	a0,a0,1068 # ffffffffc0204950 <commands+0x828>
ffffffffc020152c:	f2ffe0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201530:	00003697          	auipc	a3,0x3
ffffffffc0201534:	64068693          	addi	a3,a3,1600 # ffffffffc0204b70 <commands+0xa48>
ffffffffc0201538:	00003617          	auipc	a2,0x3
ffffffffc020153c:	40060613          	addi	a2,a2,1024 # ffffffffc0204938 <commands+0x810>
ffffffffc0201540:	11c00593          	li	a1,284
ffffffffc0201544:	00003517          	auipc	a0,0x3
ffffffffc0201548:	40c50513          	addi	a0,a0,1036 # ffffffffc0204950 <commands+0x828>
ffffffffc020154c:	f0ffe0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201550:	00003697          	auipc	a3,0x3
ffffffffc0201554:	60868693          	addi	a3,a3,1544 # ffffffffc0204b58 <commands+0xa30>
ffffffffc0201558:	00003617          	auipc	a2,0x3
ffffffffc020155c:	3e060613          	addi	a2,a2,992 # ffffffffc0204938 <commands+0x810>
ffffffffc0201560:	11b00593          	li	a1,283
ffffffffc0201564:	00003517          	auipc	a0,0x3
ffffffffc0201568:	3ec50513          	addi	a0,a0,1004 # ffffffffc0204950 <commands+0x828>
ffffffffc020156c:	eeffe0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201570:	00003697          	auipc	a3,0x3
ffffffffc0201574:	55068693          	addi	a3,a3,1360 # ffffffffc0204ac0 <commands+0x998>
ffffffffc0201578:	00003617          	auipc	a2,0x3
ffffffffc020157c:	3c060613          	addi	a2,a2,960 # ffffffffc0204938 <commands+0x810>
ffffffffc0201580:	11500593          	li	a1,277
ffffffffc0201584:	00003517          	auipc	a0,0x3
ffffffffc0201588:	3cc50513          	addi	a0,a0,972 # ffffffffc0204950 <commands+0x828>
ffffffffc020158c:	ecffe0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201590:	00003697          	auipc	a3,0x3
ffffffffc0201594:	5b068693          	addi	a3,a3,1456 # ffffffffc0204b40 <commands+0xa18>
ffffffffc0201598:	00003617          	auipc	a2,0x3
ffffffffc020159c:	3a060613          	addi	a2,a2,928 # ffffffffc0204938 <commands+0x810>
ffffffffc02015a0:	11000593          	li	a1,272
ffffffffc02015a4:	00003517          	auipc	a0,0x3
ffffffffc02015a8:	3ac50513          	addi	a0,a0,940 # ffffffffc0204950 <commands+0x828>
ffffffffc02015ac:	eaffe0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02015b0:	00003697          	auipc	a3,0x3
ffffffffc02015b4:	6b068693          	addi	a3,a3,1712 # ffffffffc0204c60 <commands+0xb38>
ffffffffc02015b8:	00003617          	auipc	a2,0x3
ffffffffc02015bc:	38060613          	addi	a2,a2,896 # ffffffffc0204938 <commands+0x810>
ffffffffc02015c0:	12e00593          	li	a1,302
ffffffffc02015c4:	00003517          	auipc	a0,0x3
ffffffffc02015c8:	38c50513          	addi	a0,a0,908 # ffffffffc0204950 <commands+0x828>
ffffffffc02015cc:	e8ffe0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02015d0:	00003697          	auipc	a3,0x3
ffffffffc02015d4:	6c068693          	addi	a3,a3,1728 # ffffffffc0204c90 <commands+0xb68>
ffffffffc02015d8:	00003617          	auipc	a2,0x3
ffffffffc02015dc:	36060613          	addi	a2,a2,864 # ffffffffc0204938 <commands+0x810>
ffffffffc02015e0:	13d00593          	li	a1,317
ffffffffc02015e4:	00003517          	auipc	a0,0x3
ffffffffc02015e8:	36c50513          	addi	a0,a0,876 # ffffffffc0204950 <commands+0x828>
ffffffffc02015ec:	e6ffe0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02015f0:	00003697          	auipc	a3,0x3
ffffffffc02015f4:	38868693          	addi	a3,a3,904 # ffffffffc0204978 <commands+0x850>
ffffffffc02015f8:	00003617          	auipc	a2,0x3
ffffffffc02015fc:	34060613          	addi	a2,a2,832 # ffffffffc0204938 <commands+0x810>
ffffffffc0201600:	10a00593          	li	a1,266
ffffffffc0201604:	00003517          	auipc	a0,0x3
ffffffffc0201608:	34c50513          	addi	a0,a0,844 # ffffffffc0204950 <commands+0x828>
ffffffffc020160c:	e4ffe0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201610:	00003697          	auipc	a3,0x3
ffffffffc0201614:	3a868693          	addi	a3,a3,936 # ffffffffc02049b8 <commands+0x890>
ffffffffc0201618:	00003617          	auipc	a2,0x3
ffffffffc020161c:	32060613          	addi	a2,a2,800 # ffffffffc0204938 <commands+0x810>
ffffffffc0201620:	0d100593          	li	a1,209
ffffffffc0201624:	00003517          	auipc	a0,0x3
ffffffffc0201628:	32c50513          	addi	a0,a0,812 # ffffffffc0204950 <commands+0x828>
ffffffffc020162c:	e2ffe0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0201630 <default_free_pages>:
ffffffffc0201630:	1141                	addi	sp,sp,-16
ffffffffc0201632:	e406                	sd	ra,8(sp)
ffffffffc0201634:	14058463          	beqz	a1,ffffffffc020177c <default_free_pages+0x14c>
ffffffffc0201638:	00659693          	slli	a3,a1,0x6
ffffffffc020163c:	96aa                	add	a3,a3,a0
ffffffffc020163e:	87aa                	mv	a5,a0
ffffffffc0201640:	02d50263          	beq	a0,a3,ffffffffc0201664 <default_free_pages+0x34>
ffffffffc0201644:	6798                	ld	a4,8(a5)
ffffffffc0201646:	8b05                	andi	a4,a4,1
ffffffffc0201648:	10071a63          	bnez	a4,ffffffffc020175c <default_free_pages+0x12c>
ffffffffc020164c:	6798                	ld	a4,8(a5)
ffffffffc020164e:	8b09                	andi	a4,a4,2
ffffffffc0201650:	10071663          	bnez	a4,ffffffffc020175c <default_free_pages+0x12c>
ffffffffc0201654:	0007b423          	sd	zero,8(a5)
ffffffffc0201658:	0007a023          	sw	zero,0(a5)
ffffffffc020165c:	04078793          	addi	a5,a5,64
ffffffffc0201660:	fed792e3          	bne	a5,a3,ffffffffc0201644 <default_free_pages+0x14>
ffffffffc0201664:	2581                	sext.w	a1,a1
ffffffffc0201666:	c90c                	sw	a1,16(a0)
ffffffffc0201668:	00850893          	addi	a7,a0,8
ffffffffc020166c:	4789                	li	a5,2
ffffffffc020166e:	40f8b02f          	amoor.d	zero,a5,(a7)
ffffffffc0201672:	00008697          	auipc	a3,0x8
ffffffffc0201676:	dbe68693          	addi	a3,a3,-578 # ffffffffc0209430 <free_area>
ffffffffc020167a:	4a98                	lw	a4,16(a3)
ffffffffc020167c:	669c                	ld	a5,8(a3)
ffffffffc020167e:	01850613          	addi	a2,a0,24
ffffffffc0201682:	9db9                	addw	a1,a1,a4
ffffffffc0201684:	ca8c                	sw	a1,16(a3)
ffffffffc0201686:	0ad78463          	beq	a5,a3,ffffffffc020172e <default_free_pages+0xfe>
ffffffffc020168a:	fe878713          	addi	a4,a5,-24
ffffffffc020168e:	0006b803          	ld	a6,0(a3)
ffffffffc0201692:	4581                	li	a1,0
ffffffffc0201694:	00e56a63          	bltu	a0,a4,ffffffffc02016a8 <default_free_pages+0x78>
ffffffffc0201698:	6798                	ld	a4,8(a5)
ffffffffc020169a:	04d70c63          	beq	a4,a3,ffffffffc02016f2 <default_free_pages+0xc2>
ffffffffc020169e:	87ba                	mv	a5,a4
ffffffffc02016a0:	fe878713          	addi	a4,a5,-24
ffffffffc02016a4:	fee57ae3          	bgeu	a0,a4,ffffffffc0201698 <default_free_pages+0x68>
ffffffffc02016a8:	c199                	beqz	a1,ffffffffc02016ae <default_free_pages+0x7e>
ffffffffc02016aa:	0106b023          	sd	a6,0(a3)
ffffffffc02016ae:	6398                	ld	a4,0(a5)
ffffffffc02016b0:	e390                	sd	a2,0(a5)
ffffffffc02016b2:	e710                	sd	a2,8(a4)
ffffffffc02016b4:	f11c                	sd	a5,32(a0)
ffffffffc02016b6:	ed18                	sd	a4,24(a0)
ffffffffc02016b8:	00d70d63          	beq	a4,a3,ffffffffc02016d2 <default_free_pages+0xa2>
ffffffffc02016bc:	ff872583          	lw	a1,-8(a4)
ffffffffc02016c0:	fe870613          	addi	a2,a4,-24
ffffffffc02016c4:	02059813          	slli	a6,a1,0x20
ffffffffc02016c8:	01a85793          	srli	a5,a6,0x1a
ffffffffc02016cc:	97b2                	add	a5,a5,a2
ffffffffc02016ce:	02f50c63          	beq	a0,a5,ffffffffc0201706 <default_free_pages+0xd6>
ffffffffc02016d2:	711c                	ld	a5,32(a0)
ffffffffc02016d4:	00d78c63          	beq	a5,a3,ffffffffc02016ec <default_free_pages+0xbc>
ffffffffc02016d8:	4910                	lw	a2,16(a0)
ffffffffc02016da:	fe878693          	addi	a3,a5,-24
ffffffffc02016de:	02061593          	slli	a1,a2,0x20
ffffffffc02016e2:	01a5d713          	srli	a4,a1,0x1a
ffffffffc02016e6:	972a                	add	a4,a4,a0
ffffffffc02016e8:	04e68a63          	beq	a3,a4,ffffffffc020173c <default_free_pages+0x10c>
ffffffffc02016ec:	60a2                	ld	ra,8(sp)
ffffffffc02016ee:	0141                	addi	sp,sp,16
ffffffffc02016f0:	8082                	ret
ffffffffc02016f2:	e790                	sd	a2,8(a5)
ffffffffc02016f4:	f114                	sd	a3,32(a0)
ffffffffc02016f6:	6798                	ld	a4,8(a5)
ffffffffc02016f8:	ed1c                	sd	a5,24(a0)
ffffffffc02016fa:	02d70763          	beq	a4,a3,ffffffffc0201728 <default_free_pages+0xf8>
ffffffffc02016fe:	8832                	mv	a6,a2
ffffffffc0201700:	4585                	li	a1,1
ffffffffc0201702:	87ba                	mv	a5,a4
ffffffffc0201704:	bf71                	j	ffffffffc02016a0 <default_free_pages+0x70>
ffffffffc0201706:	491c                	lw	a5,16(a0)
ffffffffc0201708:	9dbd                	addw	a1,a1,a5
ffffffffc020170a:	feb72c23          	sw	a1,-8(a4)
ffffffffc020170e:	57f5                	li	a5,-3
ffffffffc0201710:	60f8b02f          	amoand.d	zero,a5,(a7)
ffffffffc0201714:	01853803          	ld	a6,24(a0)
ffffffffc0201718:	710c                	ld	a1,32(a0)
ffffffffc020171a:	8532                	mv	a0,a2
ffffffffc020171c:	00b83423          	sd	a1,8(a6)
ffffffffc0201720:	671c                	ld	a5,8(a4)
ffffffffc0201722:	0105b023          	sd	a6,0(a1)
ffffffffc0201726:	b77d                	j	ffffffffc02016d4 <default_free_pages+0xa4>
ffffffffc0201728:	e290                	sd	a2,0(a3)
ffffffffc020172a:	873e                	mv	a4,a5
ffffffffc020172c:	bf41                	j	ffffffffc02016bc <default_free_pages+0x8c>
ffffffffc020172e:	60a2                	ld	ra,8(sp)
ffffffffc0201730:	e390                	sd	a2,0(a5)
ffffffffc0201732:	e790                	sd	a2,8(a5)
ffffffffc0201734:	f11c                	sd	a5,32(a0)
ffffffffc0201736:	ed1c                	sd	a5,24(a0)
ffffffffc0201738:	0141                	addi	sp,sp,16
ffffffffc020173a:	8082                	ret
ffffffffc020173c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201740:	ff078693          	addi	a3,a5,-16
ffffffffc0201744:	9e39                	addw	a2,a2,a4
ffffffffc0201746:	c910                	sw	a2,16(a0)
ffffffffc0201748:	5775                	li	a4,-3
ffffffffc020174a:	60e6b02f          	amoand.d	zero,a4,(a3)
ffffffffc020174e:	6398                	ld	a4,0(a5)
ffffffffc0201750:	679c                	ld	a5,8(a5)
ffffffffc0201752:	60a2                	ld	ra,8(sp)
ffffffffc0201754:	e71c                	sd	a5,8(a4)
ffffffffc0201756:	e398                	sd	a4,0(a5)
ffffffffc0201758:	0141                	addi	sp,sp,16
ffffffffc020175a:	8082                	ret
ffffffffc020175c:	00003697          	auipc	a3,0x3
ffffffffc0201760:	54468693          	addi	a3,a3,1348 # ffffffffc0204ca0 <commands+0xb78>
ffffffffc0201764:	00003617          	auipc	a2,0x3
ffffffffc0201768:	1d460613          	addi	a2,a2,468 # ffffffffc0204938 <commands+0x810>
ffffffffc020176c:	09000593          	li	a1,144
ffffffffc0201770:	00003517          	auipc	a0,0x3
ffffffffc0201774:	1e050513          	addi	a0,a0,480 # ffffffffc0204950 <commands+0x828>
ffffffffc0201778:	ce3fe0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc020177c:	00003697          	auipc	a3,0x3
ffffffffc0201780:	1b468693          	addi	a3,a3,436 # ffffffffc0204930 <commands+0x808>
ffffffffc0201784:	00003617          	auipc	a2,0x3
ffffffffc0201788:	1b460613          	addi	a2,a2,436 # ffffffffc0204938 <commands+0x810>
ffffffffc020178c:	08d00593          	li	a1,141
ffffffffc0201790:	00003517          	auipc	a0,0x3
ffffffffc0201794:	1c050513          	addi	a0,a0,448 # ffffffffc0204950 <commands+0x828>
ffffffffc0201798:	cc3fe0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc020179c <default_init_memmap>:
ffffffffc020179c:	1141                	addi	sp,sp,-16
ffffffffc020179e:	e406                	sd	ra,8(sp)
ffffffffc02017a0:	c5f1                	beqz	a1,ffffffffc020186c <default_init_memmap+0xd0>
ffffffffc02017a2:	00659693          	slli	a3,a1,0x6
ffffffffc02017a6:	96aa                	add	a3,a3,a0
ffffffffc02017a8:	87aa                	mv	a5,a0
ffffffffc02017aa:	00d50f63          	beq	a0,a3,ffffffffc02017c8 <default_init_memmap+0x2c>
ffffffffc02017ae:	6798                	ld	a4,8(a5)
ffffffffc02017b0:	8b05                	andi	a4,a4,1
ffffffffc02017b2:	cf49                	beqz	a4,ffffffffc020184c <default_init_memmap+0xb0>
ffffffffc02017b4:	0007a823          	sw	zero,16(a5)
ffffffffc02017b8:	0007b423          	sd	zero,8(a5)
ffffffffc02017bc:	0007a023          	sw	zero,0(a5)
ffffffffc02017c0:	04078793          	addi	a5,a5,64
ffffffffc02017c4:	fed795e3          	bne	a5,a3,ffffffffc02017ae <default_init_memmap+0x12>
ffffffffc02017c8:	2581                	sext.w	a1,a1
ffffffffc02017ca:	c90c                	sw	a1,16(a0)
ffffffffc02017cc:	4789                	li	a5,2
ffffffffc02017ce:	00850713          	addi	a4,a0,8
ffffffffc02017d2:	40f7302f          	amoor.d	zero,a5,(a4)
ffffffffc02017d6:	00008697          	auipc	a3,0x8
ffffffffc02017da:	c5a68693          	addi	a3,a3,-934 # ffffffffc0209430 <free_area>
ffffffffc02017de:	4a98                	lw	a4,16(a3)
ffffffffc02017e0:	669c                	ld	a5,8(a3)
ffffffffc02017e2:	01850613          	addi	a2,a0,24
ffffffffc02017e6:	9db9                	addw	a1,a1,a4
ffffffffc02017e8:	ca8c                	sw	a1,16(a3)
ffffffffc02017ea:	04d78a63          	beq	a5,a3,ffffffffc020183e <default_init_memmap+0xa2>
ffffffffc02017ee:	fe878713          	addi	a4,a5,-24
ffffffffc02017f2:	0006b803          	ld	a6,0(a3)
ffffffffc02017f6:	4581                	li	a1,0
ffffffffc02017f8:	00e56a63          	bltu	a0,a4,ffffffffc020180c <default_init_memmap+0x70>
ffffffffc02017fc:	6798                	ld	a4,8(a5)
ffffffffc02017fe:	02d70263          	beq	a4,a3,ffffffffc0201822 <default_init_memmap+0x86>
ffffffffc0201802:	87ba                	mv	a5,a4
ffffffffc0201804:	fe878713          	addi	a4,a5,-24
ffffffffc0201808:	fee57ae3          	bgeu	a0,a4,ffffffffc02017fc <default_init_memmap+0x60>
ffffffffc020180c:	c199                	beqz	a1,ffffffffc0201812 <default_init_memmap+0x76>
ffffffffc020180e:	0106b023          	sd	a6,0(a3)
ffffffffc0201812:	6398                	ld	a4,0(a5)
ffffffffc0201814:	60a2                	ld	ra,8(sp)
ffffffffc0201816:	e390                	sd	a2,0(a5)
ffffffffc0201818:	e710                	sd	a2,8(a4)
ffffffffc020181a:	f11c                	sd	a5,32(a0)
ffffffffc020181c:	ed18                	sd	a4,24(a0)
ffffffffc020181e:	0141                	addi	sp,sp,16
ffffffffc0201820:	8082                	ret
ffffffffc0201822:	e790                	sd	a2,8(a5)
ffffffffc0201824:	f114                	sd	a3,32(a0)
ffffffffc0201826:	6798                	ld	a4,8(a5)
ffffffffc0201828:	ed1c                	sd	a5,24(a0)
ffffffffc020182a:	00d70663          	beq	a4,a3,ffffffffc0201836 <default_init_memmap+0x9a>
ffffffffc020182e:	8832                	mv	a6,a2
ffffffffc0201830:	4585                	li	a1,1
ffffffffc0201832:	87ba                	mv	a5,a4
ffffffffc0201834:	bfc1                	j	ffffffffc0201804 <default_init_memmap+0x68>
ffffffffc0201836:	60a2                	ld	ra,8(sp)
ffffffffc0201838:	e290                	sd	a2,0(a3)
ffffffffc020183a:	0141                	addi	sp,sp,16
ffffffffc020183c:	8082                	ret
ffffffffc020183e:	60a2                	ld	ra,8(sp)
ffffffffc0201840:	e390                	sd	a2,0(a5)
ffffffffc0201842:	e790                	sd	a2,8(a5)
ffffffffc0201844:	f11c                	sd	a5,32(a0)
ffffffffc0201846:	ed1c                	sd	a5,24(a0)
ffffffffc0201848:	0141                	addi	sp,sp,16
ffffffffc020184a:	8082                	ret
ffffffffc020184c:	00003697          	auipc	a3,0x3
ffffffffc0201850:	47c68693          	addi	a3,a3,1148 # ffffffffc0204cc8 <commands+0xba0>
ffffffffc0201854:	00003617          	auipc	a2,0x3
ffffffffc0201858:	0e460613          	addi	a2,a2,228 # ffffffffc0204938 <commands+0x810>
ffffffffc020185c:	04900593          	li	a1,73
ffffffffc0201860:	00003517          	auipc	a0,0x3
ffffffffc0201864:	0f050513          	addi	a0,a0,240 # ffffffffc0204950 <commands+0x828>
ffffffffc0201868:	bf3fe0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc020186c:	00003697          	auipc	a3,0x3
ffffffffc0201870:	0c468693          	addi	a3,a3,196 # ffffffffc0204930 <commands+0x808>
ffffffffc0201874:	00003617          	auipc	a2,0x3
ffffffffc0201878:	0c460613          	addi	a2,a2,196 # ffffffffc0204938 <commands+0x810>
ffffffffc020187c:	04600593          	li	a1,70
ffffffffc0201880:	00003517          	auipc	a0,0x3
ffffffffc0201884:	0d050513          	addi	a0,a0,208 # ffffffffc0204950 <commands+0x828>
ffffffffc0201888:	bd3fe0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc020188c <slob_free>:
ffffffffc020188c:	c94d                	beqz	a0,ffffffffc020193e <slob_free+0xb2>
ffffffffc020188e:	1141                	addi	sp,sp,-16
ffffffffc0201890:	e022                	sd	s0,0(sp)
ffffffffc0201892:	e406                	sd	ra,8(sp)
ffffffffc0201894:	842a                	mv	s0,a0
ffffffffc0201896:	e9c1                	bnez	a1,ffffffffc0201926 <slob_free+0x9a>
ffffffffc0201898:	100027f3          	csrr	a5,sstatus
ffffffffc020189c:	8b89                	andi	a5,a5,2
ffffffffc020189e:	4501                	li	a0,0
ffffffffc02018a0:	ebd9                	bnez	a5,ffffffffc0201936 <slob_free+0xaa>
ffffffffc02018a2:	00007617          	auipc	a2,0x7
ffffffffc02018a6:	77e60613          	addi	a2,a2,1918 # ffffffffc0209020 <slobfree>
ffffffffc02018aa:	621c                	ld	a5,0(a2)
ffffffffc02018ac:	873e                	mv	a4,a5
ffffffffc02018ae:	679c                	ld	a5,8(a5)
ffffffffc02018b0:	02877a63          	bgeu	a4,s0,ffffffffc02018e4 <slob_free+0x58>
ffffffffc02018b4:	00f46463          	bltu	s0,a5,ffffffffc02018bc <slob_free+0x30>
ffffffffc02018b8:	fef76ae3          	bltu	a4,a5,ffffffffc02018ac <slob_free+0x20>
ffffffffc02018bc:	400c                	lw	a1,0(s0)
ffffffffc02018be:	00459693          	slli	a3,a1,0x4
ffffffffc02018c2:	96a2                	add	a3,a3,s0
ffffffffc02018c4:	02d78a63          	beq	a5,a3,ffffffffc02018f8 <slob_free+0x6c>
ffffffffc02018c8:	4314                	lw	a3,0(a4)
ffffffffc02018ca:	e41c                	sd	a5,8(s0)
ffffffffc02018cc:	00469793          	slli	a5,a3,0x4
ffffffffc02018d0:	97ba                	add	a5,a5,a4
ffffffffc02018d2:	02f40e63          	beq	s0,a5,ffffffffc020190e <slob_free+0x82>
ffffffffc02018d6:	e700                	sd	s0,8(a4)
ffffffffc02018d8:	e218                	sd	a4,0(a2)
ffffffffc02018da:	e129                	bnez	a0,ffffffffc020191c <slob_free+0x90>
ffffffffc02018dc:	60a2                	ld	ra,8(sp)
ffffffffc02018de:	6402                	ld	s0,0(sp)
ffffffffc02018e0:	0141                	addi	sp,sp,16
ffffffffc02018e2:	8082                	ret
ffffffffc02018e4:	fcf764e3          	bltu	a4,a5,ffffffffc02018ac <slob_free+0x20>
ffffffffc02018e8:	fcf472e3          	bgeu	s0,a5,ffffffffc02018ac <slob_free+0x20>
ffffffffc02018ec:	400c                	lw	a1,0(s0)
ffffffffc02018ee:	00459693          	slli	a3,a1,0x4
ffffffffc02018f2:	96a2                	add	a3,a3,s0
ffffffffc02018f4:	fcd79ae3          	bne	a5,a3,ffffffffc02018c8 <slob_free+0x3c>
ffffffffc02018f8:	4394                	lw	a3,0(a5)
ffffffffc02018fa:	679c                	ld	a5,8(a5)
ffffffffc02018fc:	9db5                	addw	a1,a1,a3
ffffffffc02018fe:	c00c                	sw	a1,0(s0)
ffffffffc0201900:	4314                	lw	a3,0(a4)
ffffffffc0201902:	e41c                	sd	a5,8(s0)
ffffffffc0201904:	00469793          	slli	a5,a3,0x4
ffffffffc0201908:	97ba                	add	a5,a5,a4
ffffffffc020190a:	fcf416e3          	bne	s0,a5,ffffffffc02018d6 <slob_free+0x4a>
ffffffffc020190e:	401c                	lw	a5,0(s0)
ffffffffc0201910:	640c                	ld	a1,8(s0)
ffffffffc0201912:	e218                	sd	a4,0(a2)
ffffffffc0201914:	9ebd                	addw	a3,a3,a5
ffffffffc0201916:	c314                	sw	a3,0(a4)
ffffffffc0201918:	e70c                	sd	a1,8(a4)
ffffffffc020191a:	d169                	beqz	a0,ffffffffc02018dc <slob_free+0x50>
ffffffffc020191c:	6402                	ld	s0,0(sp)
ffffffffc020191e:	60a2                	ld	ra,8(sp)
ffffffffc0201920:	0141                	addi	sp,sp,16
ffffffffc0201922:	808ff06f          	j	ffffffffc020092a <intr_enable>
ffffffffc0201926:	25bd                	addiw	a1,a1,15
ffffffffc0201928:	8191                	srli	a1,a1,0x4
ffffffffc020192a:	c10c                	sw	a1,0(a0)
ffffffffc020192c:	100027f3          	csrr	a5,sstatus
ffffffffc0201930:	8b89                	andi	a5,a5,2
ffffffffc0201932:	4501                	li	a0,0
ffffffffc0201934:	d7bd                	beqz	a5,ffffffffc02018a2 <slob_free+0x16>
ffffffffc0201936:	ffbfe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc020193a:	4505                	li	a0,1
ffffffffc020193c:	b79d                	j	ffffffffc02018a2 <slob_free+0x16>
ffffffffc020193e:	8082                	ret

ffffffffc0201940 <__slob_get_free_pages.constprop.0>:
ffffffffc0201940:	4785                	li	a5,1
ffffffffc0201942:	1141                	addi	sp,sp,-16
ffffffffc0201944:	00a7953b          	sllw	a0,a5,a0
ffffffffc0201948:	e406                	sd	ra,8(sp)
ffffffffc020194a:	34e000ef          	jal	ra,ffffffffc0201c98 <alloc_pages>
ffffffffc020194e:	c91d                	beqz	a0,ffffffffc0201984 <__slob_get_free_pages.constprop.0+0x44>
ffffffffc0201950:	0000c697          	auipc	a3,0xc
ffffffffc0201954:	b686b683          	ld	a3,-1176(a3) # ffffffffc020d4b8 <pages>
ffffffffc0201958:	8d15                	sub	a0,a0,a3
ffffffffc020195a:	8519                	srai	a0,a0,0x6
ffffffffc020195c:	00004697          	auipc	a3,0x4
ffffffffc0201960:	0ac6b683          	ld	a3,172(a3) # ffffffffc0205a08 <nbase>
ffffffffc0201964:	9536                	add	a0,a0,a3
ffffffffc0201966:	00c51793          	slli	a5,a0,0xc
ffffffffc020196a:	83b1                	srli	a5,a5,0xc
ffffffffc020196c:	0000c717          	auipc	a4,0xc
ffffffffc0201970:	b4473703          	ld	a4,-1212(a4) # ffffffffc020d4b0 <npage>
ffffffffc0201974:	0532                	slli	a0,a0,0xc
ffffffffc0201976:	00e7fa63          	bgeu	a5,a4,ffffffffc020198a <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc020197a:	0000c697          	auipc	a3,0xc
ffffffffc020197e:	b4e6b683          	ld	a3,-1202(a3) # ffffffffc020d4c8 <va_pa_offset>
ffffffffc0201982:	9536                	add	a0,a0,a3
ffffffffc0201984:	60a2                	ld	ra,8(sp)
ffffffffc0201986:	0141                	addi	sp,sp,16
ffffffffc0201988:	8082                	ret
ffffffffc020198a:	86aa                	mv	a3,a0
ffffffffc020198c:	00003617          	auipc	a2,0x3
ffffffffc0201990:	39c60613          	addi	a2,a2,924 # ffffffffc0204d28 <default_pmm_manager+0x38>
ffffffffc0201994:	07100593          	li	a1,113
ffffffffc0201998:	00003517          	auipc	a0,0x3
ffffffffc020199c:	3b850513          	addi	a0,a0,952 # ffffffffc0204d50 <default_pmm_manager+0x60>
ffffffffc02019a0:	abbfe0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc02019a4 <slob_alloc.constprop.0>:
ffffffffc02019a4:	1101                	addi	sp,sp,-32
ffffffffc02019a6:	ec06                	sd	ra,24(sp)
ffffffffc02019a8:	e822                	sd	s0,16(sp)
ffffffffc02019aa:	e426                	sd	s1,8(sp)
ffffffffc02019ac:	e04a                	sd	s2,0(sp)
ffffffffc02019ae:	01050713          	addi	a4,a0,16
ffffffffc02019b2:	6785                	lui	a5,0x1
ffffffffc02019b4:	0cf77363          	bgeu	a4,a5,ffffffffc0201a7a <slob_alloc.constprop.0+0xd6>
ffffffffc02019b8:	00f50493          	addi	s1,a0,15
ffffffffc02019bc:	8091                	srli	s1,s1,0x4
ffffffffc02019be:	2481                	sext.w	s1,s1
ffffffffc02019c0:	10002673          	csrr	a2,sstatus
ffffffffc02019c4:	8a09                	andi	a2,a2,2
ffffffffc02019c6:	e25d                	bnez	a2,ffffffffc0201a6c <slob_alloc.constprop.0+0xc8>
ffffffffc02019c8:	00007917          	auipc	s2,0x7
ffffffffc02019cc:	65890913          	addi	s2,s2,1624 # ffffffffc0209020 <slobfree>
ffffffffc02019d0:	00093683          	ld	a3,0(s2)
ffffffffc02019d4:	669c                	ld	a5,8(a3)
ffffffffc02019d6:	4398                	lw	a4,0(a5)
ffffffffc02019d8:	08975e63          	bge	a4,s1,ffffffffc0201a74 <slob_alloc.constprop.0+0xd0>
ffffffffc02019dc:	00d78b63          	beq	a5,a3,ffffffffc02019f2 <slob_alloc.constprop.0+0x4e>
ffffffffc02019e0:	6780                	ld	s0,8(a5)
ffffffffc02019e2:	4018                	lw	a4,0(s0)
ffffffffc02019e4:	02975a63          	bge	a4,s1,ffffffffc0201a18 <slob_alloc.constprop.0+0x74>
ffffffffc02019e8:	00093683          	ld	a3,0(s2)
ffffffffc02019ec:	87a2                	mv	a5,s0
ffffffffc02019ee:	fed799e3          	bne	a5,a3,ffffffffc02019e0 <slob_alloc.constprop.0+0x3c>
ffffffffc02019f2:	ee31                	bnez	a2,ffffffffc0201a4e <slob_alloc.constprop.0+0xaa>
ffffffffc02019f4:	4501                	li	a0,0
ffffffffc02019f6:	f4bff0ef          	jal	ra,ffffffffc0201940 <__slob_get_free_pages.constprop.0>
ffffffffc02019fa:	842a                	mv	s0,a0
ffffffffc02019fc:	cd05                	beqz	a0,ffffffffc0201a34 <slob_alloc.constprop.0+0x90>
ffffffffc02019fe:	6585                	lui	a1,0x1
ffffffffc0201a00:	e8dff0ef          	jal	ra,ffffffffc020188c <slob_free>
ffffffffc0201a04:	10002673          	csrr	a2,sstatus
ffffffffc0201a08:	8a09                	andi	a2,a2,2
ffffffffc0201a0a:	ee05                	bnez	a2,ffffffffc0201a42 <slob_alloc.constprop.0+0x9e>
ffffffffc0201a0c:	00093783          	ld	a5,0(s2)
ffffffffc0201a10:	6780                	ld	s0,8(a5)
ffffffffc0201a12:	4018                	lw	a4,0(s0)
ffffffffc0201a14:	fc974ae3          	blt	a4,s1,ffffffffc02019e8 <slob_alloc.constprop.0+0x44>
ffffffffc0201a18:	04e48763          	beq	s1,a4,ffffffffc0201a66 <slob_alloc.constprop.0+0xc2>
ffffffffc0201a1c:	00449693          	slli	a3,s1,0x4
ffffffffc0201a20:	96a2                	add	a3,a3,s0
ffffffffc0201a22:	e794                	sd	a3,8(a5)
ffffffffc0201a24:	640c                	ld	a1,8(s0)
ffffffffc0201a26:	9f05                	subw	a4,a4,s1
ffffffffc0201a28:	c298                	sw	a4,0(a3)
ffffffffc0201a2a:	e68c                	sd	a1,8(a3)
ffffffffc0201a2c:	c004                	sw	s1,0(s0)
ffffffffc0201a2e:	00f93023          	sd	a5,0(s2)
ffffffffc0201a32:	e20d                	bnez	a2,ffffffffc0201a54 <slob_alloc.constprop.0+0xb0>
ffffffffc0201a34:	60e2                	ld	ra,24(sp)
ffffffffc0201a36:	8522                	mv	a0,s0
ffffffffc0201a38:	6442                	ld	s0,16(sp)
ffffffffc0201a3a:	64a2                	ld	s1,8(sp)
ffffffffc0201a3c:	6902                	ld	s2,0(sp)
ffffffffc0201a3e:	6105                	addi	sp,sp,32
ffffffffc0201a40:	8082                	ret
ffffffffc0201a42:	eeffe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc0201a46:	00093783          	ld	a5,0(s2)
ffffffffc0201a4a:	4605                	li	a2,1
ffffffffc0201a4c:	b7d1                	j	ffffffffc0201a10 <slob_alloc.constprop.0+0x6c>
ffffffffc0201a4e:	eddfe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0201a52:	b74d                	j	ffffffffc02019f4 <slob_alloc.constprop.0+0x50>
ffffffffc0201a54:	ed7fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0201a58:	60e2                	ld	ra,24(sp)
ffffffffc0201a5a:	8522                	mv	a0,s0
ffffffffc0201a5c:	6442                	ld	s0,16(sp)
ffffffffc0201a5e:	64a2                	ld	s1,8(sp)
ffffffffc0201a60:	6902                	ld	s2,0(sp)
ffffffffc0201a62:	6105                	addi	sp,sp,32
ffffffffc0201a64:	8082                	ret
ffffffffc0201a66:	6418                	ld	a4,8(s0)
ffffffffc0201a68:	e798                	sd	a4,8(a5)
ffffffffc0201a6a:	b7d1                	j	ffffffffc0201a2e <slob_alloc.constprop.0+0x8a>
ffffffffc0201a6c:	ec5fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc0201a70:	4605                	li	a2,1
ffffffffc0201a72:	bf99                	j	ffffffffc02019c8 <slob_alloc.constprop.0+0x24>
ffffffffc0201a74:	843e                	mv	s0,a5
ffffffffc0201a76:	87b6                	mv	a5,a3
ffffffffc0201a78:	b745                	j	ffffffffc0201a18 <slob_alloc.constprop.0+0x74>
ffffffffc0201a7a:	00003697          	auipc	a3,0x3
ffffffffc0201a7e:	2e668693          	addi	a3,a3,742 # ffffffffc0204d60 <default_pmm_manager+0x70>
ffffffffc0201a82:	00003617          	auipc	a2,0x3
ffffffffc0201a86:	eb660613          	addi	a2,a2,-330 # ffffffffc0204938 <commands+0x810>
ffffffffc0201a8a:	06300593          	li	a1,99
ffffffffc0201a8e:	00003517          	auipc	a0,0x3
ffffffffc0201a92:	2f250513          	addi	a0,a0,754 # ffffffffc0204d80 <default_pmm_manager+0x90>
ffffffffc0201a96:	9c5fe0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0201a9a <kmalloc_init>:
ffffffffc0201a9a:	1141                	addi	sp,sp,-16
ffffffffc0201a9c:	00003517          	auipc	a0,0x3
ffffffffc0201aa0:	2fc50513          	addi	a0,a0,764 # ffffffffc0204d98 <default_pmm_manager+0xa8>
ffffffffc0201aa4:	e406                	sd	ra,8(sp)
ffffffffc0201aa6:	eeefe0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0201aaa:	60a2                	ld	ra,8(sp)
ffffffffc0201aac:	00003517          	auipc	a0,0x3
ffffffffc0201ab0:	30450513          	addi	a0,a0,772 # ffffffffc0204db0 <default_pmm_manager+0xc0>
ffffffffc0201ab4:	0141                	addi	sp,sp,16
ffffffffc0201ab6:	edefe06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0201aba <kmalloc>:
ffffffffc0201aba:	1101                	addi	sp,sp,-32
ffffffffc0201abc:	e04a                	sd	s2,0(sp)
ffffffffc0201abe:	6905                	lui	s2,0x1
ffffffffc0201ac0:	e822                	sd	s0,16(sp)
ffffffffc0201ac2:	ec06                	sd	ra,24(sp)
ffffffffc0201ac4:	e426                	sd	s1,8(sp)
ffffffffc0201ac6:	fef90793          	addi	a5,s2,-17 # fef <kern_entry-0xffffffffc01ff011>
ffffffffc0201aca:	842a                	mv	s0,a0
ffffffffc0201acc:	04a7f963          	bgeu	a5,a0,ffffffffc0201b1e <kmalloc+0x64>
ffffffffc0201ad0:	4561                	li	a0,24
ffffffffc0201ad2:	ed3ff0ef          	jal	ra,ffffffffc02019a4 <slob_alloc.constprop.0>
ffffffffc0201ad6:	84aa                	mv	s1,a0
ffffffffc0201ad8:	c929                	beqz	a0,ffffffffc0201b2a <kmalloc+0x70>
ffffffffc0201ada:	0004079b          	sext.w	a5,s0
ffffffffc0201ade:	4501                	li	a0,0
ffffffffc0201ae0:	00f95763          	bge	s2,a5,ffffffffc0201aee <kmalloc+0x34>
ffffffffc0201ae4:	6705                	lui	a4,0x1
ffffffffc0201ae6:	8785                	srai	a5,a5,0x1
ffffffffc0201ae8:	2505                	addiw	a0,a0,1
ffffffffc0201aea:	fef74ee3          	blt	a4,a5,ffffffffc0201ae6 <kmalloc+0x2c>
ffffffffc0201aee:	c088                	sw	a0,0(s1)
ffffffffc0201af0:	e51ff0ef          	jal	ra,ffffffffc0201940 <__slob_get_free_pages.constprop.0>
ffffffffc0201af4:	e488                	sd	a0,8(s1)
ffffffffc0201af6:	842a                	mv	s0,a0
ffffffffc0201af8:	c525                	beqz	a0,ffffffffc0201b60 <kmalloc+0xa6>
ffffffffc0201afa:	100027f3          	csrr	a5,sstatus
ffffffffc0201afe:	8b89                	andi	a5,a5,2
ffffffffc0201b00:	ef8d                	bnez	a5,ffffffffc0201b3a <kmalloc+0x80>
ffffffffc0201b02:	0000c797          	auipc	a5,0xc
ffffffffc0201b06:	99678793          	addi	a5,a5,-1642 # ffffffffc020d498 <bigblocks>
ffffffffc0201b0a:	6398                	ld	a4,0(a5)
ffffffffc0201b0c:	e384                	sd	s1,0(a5)
ffffffffc0201b0e:	e898                	sd	a4,16(s1)
ffffffffc0201b10:	60e2                	ld	ra,24(sp)
ffffffffc0201b12:	8522                	mv	a0,s0
ffffffffc0201b14:	6442                	ld	s0,16(sp)
ffffffffc0201b16:	64a2                	ld	s1,8(sp)
ffffffffc0201b18:	6902                	ld	s2,0(sp)
ffffffffc0201b1a:	6105                	addi	sp,sp,32
ffffffffc0201b1c:	8082                	ret
ffffffffc0201b1e:	0541                	addi	a0,a0,16
ffffffffc0201b20:	e85ff0ef          	jal	ra,ffffffffc02019a4 <slob_alloc.constprop.0>
ffffffffc0201b24:	01050413          	addi	s0,a0,16
ffffffffc0201b28:	f565                	bnez	a0,ffffffffc0201b10 <kmalloc+0x56>
ffffffffc0201b2a:	4401                	li	s0,0
ffffffffc0201b2c:	60e2                	ld	ra,24(sp)
ffffffffc0201b2e:	8522                	mv	a0,s0
ffffffffc0201b30:	6442                	ld	s0,16(sp)
ffffffffc0201b32:	64a2                	ld	s1,8(sp)
ffffffffc0201b34:	6902                	ld	s2,0(sp)
ffffffffc0201b36:	6105                	addi	sp,sp,32
ffffffffc0201b38:	8082                	ret
ffffffffc0201b3a:	df7fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc0201b3e:	0000c797          	auipc	a5,0xc
ffffffffc0201b42:	95a78793          	addi	a5,a5,-1702 # ffffffffc020d498 <bigblocks>
ffffffffc0201b46:	6398                	ld	a4,0(a5)
ffffffffc0201b48:	e384                	sd	s1,0(a5)
ffffffffc0201b4a:	e898                	sd	a4,16(s1)
ffffffffc0201b4c:	ddffe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0201b50:	6480                	ld	s0,8(s1)
ffffffffc0201b52:	60e2                	ld	ra,24(sp)
ffffffffc0201b54:	64a2                	ld	s1,8(sp)
ffffffffc0201b56:	8522                	mv	a0,s0
ffffffffc0201b58:	6442                	ld	s0,16(sp)
ffffffffc0201b5a:	6902                	ld	s2,0(sp)
ffffffffc0201b5c:	6105                	addi	sp,sp,32
ffffffffc0201b5e:	8082                	ret
ffffffffc0201b60:	45e1                	li	a1,24
ffffffffc0201b62:	8526                	mv	a0,s1
ffffffffc0201b64:	d29ff0ef          	jal	ra,ffffffffc020188c <slob_free>
ffffffffc0201b68:	b765                	j	ffffffffc0201b10 <kmalloc+0x56>

ffffffffc0201b6a <kfree>:
ffffffffc0201b6a:	c169                	beqz	a0,ffffffffc0201c2c <kfree+0xc2>
ffffffffc0201b6c:	1101                	addi	sp,sp,-32
ffffffffc0201b6e:	e822                	sd	s0,16(sp)
ffffffffc0201b70:	ec06                	sd	ra,24(sp)
ffffffffc0201b72:	e426                	sd	s1,8(sp)
ffffffffc0201b74:	03451793          	slli	a5,a0,0x34
ffffffffc0201b78:	842a                	mv	s0,a0
ffffffffc0201b7a:	e3d9                	bnez	a5,ffffffffc0201c00 <kfree+0x96>
ffffffffc0201b7c:	100027f3          	csrr	a5,sstatus
ffffffffc0201b80:	8b89                	andi	a5,a5,2
ffffffffc0201b82:	e7d9                	bnez	a5,ffffffffc0201c10 <kfree+0xa6>
ffffffffc0201b84:	0000c797          	auipc	a5,0xc
ffffffffc0201b88:	9147b783          	ld	a5,-1772(a5) # ffffffffc020d498 <bigblocks>
ffffffffc0201b8c:	4601                	li	a2,0
ffffffffc0201b8e:	cbad                	beqz	a5,ffffffffc0201c00 <kfree+0x96>
ffffffffc0201b90:	0000c697          	auipc	a3,0xc
ffffffffc0201b94:	90868693          	addi	a3,a3,-1784 # ffffffffc020d498 <bigblocks>
ffffffffc0201b98:	a021                	j	ffffffffc0201ba0 <kfree+0x36>
ffffffffc0201b9a:	01048693          	addi	a3,s1,16
ffffffffc0201b9e:	c3a5                	beqz	a5,ffffffffc0201bfe <kfree+0x94>
ffffffffc0201ba0:	6798                	ld	a4,8(a5)
ffffffffc0201ba2:	84be                	mv	s1,a5
ffffffffc0201ba4:	6b9c                	ld	a5,16(a5)
ffffffffc0201ba6:	fe871ae3          	bne	a4,s0,ffffffffc0201b9a <kfree+0x30>
ffffffffc0201baa:	e29c                	sd	a5,0(a3)
ffffffffc0201bac:	ee2d                	bnez	a2,ffffffffc0201c26 <kfree+0xbc>
ffffffffc0201bae:	c02007b7          	lui	a5,0xc0200
ffffffffc0201bb2:	4098                	lw	a4,0(s1)
ffffffffc0201bb4:	08f46963          	bltu	s0,a5,ffffffffc0201c46 <kfree+0xdc>
ffffffffc0201bb8:	0000c697          	auipc	a3,0xc
ffffffffc0201bbc:	9106b683          	ld	a3,-1776(a3) # ffffffffc020d4c8 <va_pa_offset>
ffffffffc0201bc0:	8c15                	sub	s0,s0,a3
ffffffffc0201bc2:	8031                	srli	s0,s0,0xc
ffffffffc0201bc4:	0000c797          	auipc	a5,0xc
ffffffffc0201bc8:	8ec7b783          	ld	a5,-1812(a5) # ffffffffc020d4b0 <npage>
ffffffffc0201bcc:	06f47163          	bgeu	s0,a5,ffffffffc0201c2e <kfree+0xc4>
ffffffffc0201bd0:	00004517          	auipc	a0,0x4
ffffffffc0201bd4:	e3853503          	ld	a0,-456(a0) # ffffffffc0205a08 <nbase>
ffffffffc0201bd8:	8c09                	sub	s0,s0,a0
ffffffffc0201bda:	041a                	slli	s0,s0,0x6
ffffffffc0201bdc:	0000c517          	auipc	a0,0xc
ffffffffc0201be0:	8dc53503          	ld	a0,-1828(a0) # ffffffffc020d4b8 <pages>
ffffffffc0201be4:	4585                	li	a1,1
ffffffffc0201be6:	9522                	add	a0,a0,s0
ffffffffc0201be8:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201bec:	0ea000ef          	jal	ra,ffffffffc0201cd6 <free_pages>
ffffffffc0201bf0:	6442                	ld	s0,16(sp)
ffffffffc0201bf2:	60e2                	ld	ra,24(sp)
ffffffffc0201bf4:	8526                	mv	a0,s1
ffffffffc0201bf6:	64a2                	ld	s1,8(sp)
ffffffffc0201bf8:	45e1                	li	a1,24
ffffffffc0201bfa:	6105                	addi	sp,sp,32
ffffffffc0201bfc:	b941                	j	ffffffffc020188c <slob_free>
ffffffffc0201bfe:	e20d                	bnez	a2,ffffffffc0201c20 <kfree+0xb6>
ffffffffc0201c00:	ff040513          	addi	a0,s0,-16
ffffffffc0201c04:	6442                	ld	s0,16(sp)
ffffffffc0201c06:	60e2                	ld	ra,24(sp)
ffffffffc0201c08:	64a2                	ld	s1,8(sp)
ffffffffc0201c0a:	4581                	li	a1,0
ffffffffc0201c0c:	6105                	addi	sp,sp,32
ffffffffc0201c0e:	b9bd                	j	ffffffffc020188c <slob_free>
ffffffffc0201c10:	d21fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc0201c14:	0000c797          	auipc	a5,0xc
ffffffffc0201c18:	8847b783          	ld	a5,-1916(a5) # ffffffffc020d498 <bigblocks>
ffffffffc0201c1c:	4605                	li	a2,1
ffffffffc0201c1e:	fbad                	bnez	a5,ffffffffc0201b90 <kfree+0x26>
ffffffffc0201c20:	d0bfe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0201c24:	bff1                	j	ffffffffc0201c00 <kfree+0x96>
ffffffffc0201c26:	d05fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0201c2a:	b751                	j	ffffffffc0201bae <kfree+0x44>
ffffffffc0201c2c:	8082                	ret
ffffffffc0201c2e:	00003617          	auipc	a2,0x3
ffffffffc0201c32:	1ca60613          	addi	a2,a2,458 # ffffffffc0204df8 <default_pmm_manager+0x108>
ffffffffc0201c36:	06900593          	li	a1,105
ffffffffc0201c3a:	00003517          	auipc	a0,0x3
ffffffffc0201c3e:	11650513          	addi	a0,a0,278 # ffffffffc0204d50 <default_pmm_manager+0x60>
ffffffffc0201c42:	819fe0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201c46:	86a2                	mv	a3,s0
ffffffffc0201c48:	00003617          	auipc	a2,0x3
ffffffffc0201c4c:	18860613          	addi	a2,a2,392 # ffffffffc0204dd0 <default_pmm_manager+0xe0>
ffffffffc0201c50:	07700593          	li	a1,119
ffffffffc0201c54:	00003517          	auipc	a0,0x3
ffffffffc0201c58:	0fc50513          	addi	a0,a0,252 # ffffffffc0204d50 <default_pmm_manager+0x60>
ffffffffc0201c5c:	ffefe0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0201c60 <pa2page.part.0>:
ffffffffc0201c60:	1141                	addi	sp,sp,-16
ffffffffc0201c62:	00003617          	auipc	a2,0x3
ffffffffc0201c66:	19660613          	addi	a2,a2,406 # ffffffffc0204df8 <default_pmm_manager+0x108>
ffffffffc0201c6a:	06900593          	li	a1,105
ffffffffc0201c6e:	00003517          	auipc	a0,0x3
ffffffffc0201c72:	0e250513          	addi	a0,a0,226 # ffffffffc0204d50 <default_pmm_manager+0x60>
ffffffffc0201c76:	e406                	sd	ra,8(sp)
ffffffffc0201c78:	fe2fe0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0201c7c <pte2page.part.0>:
ffffffffc0201c7c:	1141                	addi	sp,sp,-16
ffffffffc0201c7e:	00003617          	auipc	a2,0x3
ffffffffc0201c82:	19a60613          	addi	a2,a2,410 # ffffffffc0204e18 <default_pmm_manager+0x128>
ffffffffc0201c86:	07f00593          	li	a1,127
ffffffffc0201c8a:	00003517          	auipc	a0,0x3
ffffffffc0201c8e:	0c650513          	addi	a0,a0,198 # ffffffffc0204d50 <default_pmm_manager+0x60>
ffffffffc0201c92:	e406                	sd	ra,8(sp)
ffffffffc0201c94:	fc6fe0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0201c98 <alloc_pages>:
ffffffffc0201c98:	100027f3          	csrr	a5,sstatus
ffffffffc0201c9c:	8b89                	andi	a5,a5,2
ffffffffc0201c9e:	e799                	bnez	a5,ffffffffc0201cac <alloc_pages+0x14>
ffffffffc0201ca0:	0000c797          	auipc	a5,0xc
ffffffffc0201ca4:	8207b783          	ld	a5,-2016(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0201ca8:	6f9c                	ld	a5,24(a5)
ffffffffc0201caa:	8782                	jr	a5
ffffffffc0201cac:	1141                	addi	sp,sp,-16
ffffffffc0201cae:	e406                	sd	ra,8(sp)
ffffffffc0201cb0:	e022                	sd	s0,0(sp)
ffffffffc0201cb2:	842a                	mv	s0,a0
ffffffffc0201cb4:	c7dfe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc0201cb8:	0000c797          	auipc	a5,0xc
ffffffffc0201cbc:	8087b783          	ld	a5,-2040(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0201cc0:	6f9c                	ld	a5,24(a5)
ffffffffc0201cc2:	8522                	mv	a0,s0
ffffffffc0201cc4:	9782                	jalr	a5
ffffffffc0201cc6:	842a                	mv	s0,a0
ffffffffc0201cc8:	c63fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0201ccc:	60a2                	ld	ra,8(sp)
ffffffffc0201cce:	8522                	mv	a0,s0
ffffffffc0201cd0:	6402                	ld	s0,0(sp)
ffffffffc0201cd2:	0141                	addi	sp,sp,16
ffffffffc0201cd4:	8082                	ret

ffffffffc0201cd6 <free_pages>:
ffffffffc0201cd6:	100027f3          	csrr	a5,sstatus
ffffffffc0201cda:	8b89                	andi	a5,a5,2
ffffffffc0201cdc:	e799                	bnez	a5,ffffffffc0201cea <free_pages+0x14>
ffffffffc0201cde:	0000b797          	auipc	a5,0xb
ffffffffc0201ce2:	7e27b783          	ld	a5,2018(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0201ce6:	739c                	ld	a5,32(a5)
ffffffffc0201ce8:	8782                	jr	a5
ffffffffc0201cea:	1101                	addi	sp,sp,-32
ffffffffc0201cec:	ec06                	sd	ra,24(sp)
ffffffffc0201cee:	e822                	sd	s0,16(sp)
ffffffffc0201cf0:	e426                	sd	s1,8(sp)
ffffffffc0201cf2:	842a                	mv	s0,a0
ffffffffc0201cf4:	84ae                	mv	s1,a1
ffffffffc0201cf6:	c3bfe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc0201cfa:	0000b797          	auipc	a5,0xb
ffffffffc0201cfe:	7c67b783          	ld	a5,1990(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0201d02:	739c                	ld	a5,32(a5)
ffffffffc0201d04:	85a6                	mv	a1,s1
ffffffffc0201d06:	8522                	mv	a0,s0
ffffffffc0201d08:	9782                	jalr	a5
ffffffffc0201d0a:	6442                	ld	s0,16(sp)
ffffffffc0201d0c:	60e2                	ld	ra,24(sp)
ffffffffc0201d0e:	64a2                	ld	s1,8(sp)
ffffffffc0201d10:	6105                	addi	sp,sp,32
ffffffffc0201d12:	c19fe06f          	j	ffffffffc020092a <intr_enable>

ffffffffc0201d16 <nr_free_pages>:
ffffffffc0201d16:	100027f3          	csrr	a5,sstatus
ffffffffc0201d1a:	8b89                	andi	a5,a5,2
ffffffffc0201d1c:	e799                	bnez	a5,ffffffffc0201d2a <nr_free_pages+0x14>
ffffffffc0201d1e:	0000b797          	auipc	a5,0xb
ffffffffc0201d22:	7a27b783          	ld	a5,1954(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0201d26:	779c                	ld	a5,40(a5)
ffffffffc0201d28:	8782                	jr	a5
ffffffffc0201d2a:	1141                	addi	sp,sp,-16
ffffffffc0201d2c:	e406                	sd	ra,8(sp)
ffffffffc0201d2e:	e022                	sd	s0,0(sp)
ffffffffc0201d30:	c01fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc0201d34:	0000b797          	auipc	a5,0xb
ffffffffc0201d38:	78c7b783          	ld	a5,1932(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0201d3c:	779c                	ld	a5,40(a5)
ffffffffc0201d3e:	9782                	jalr	a5
ffffffffc0201d40:	842a                	mv	s0,a0
ffffffffc0201d42:	be9fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0201d46:	60a2                	ld	ra,8(sp)
ffffffffc0201d48:	8522                	mv	a0,s0
ffffffffc0201d4a:	6402                	ld	s0,0(sp)
ffffffffc0201d4c:	0141                	addi	sp,sp,16
ffffffffc0201d4e:	8082                	ret

ffffffffc0201d50 <get_pte>:
ffffffffc0201d50:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201d54:	1ff7f793          	andi	a5,a5,511
ffffffffc0201d58:	7139                	addi	sp,sp,-64
ffffffffc0201d5a:	078e                	slli	a5,a5,0x3
ffffffffc0201d5c:	f426                	sd	s1,40(sp)
ffffffffc0201d5e:	00f504b3          	add	s1,a0,a5
ffffffffc0201d62:	6094                	ld	a3,0(s1)
ffffffffc0201d64:	f04a                	sd	s2,32(sp)
ffffffffc0201d66:	ec4e                	sd	s3,24(sp)
ffffffffc0201d68:	e852                	sd	s4,16(sp)
ffffffffc0201d6a:	fc06                	sd	ra,56(sp)
ffffffffc0201d6c:	f822                	sd	s0,48(sp)
ffffffffc0201d6e:	e456                	sd	s5,8(sp)
ffffffffc0201d70:	e05a                	sd	s6,0(sp)
ffffffffc0201d72:	0016f793          	andi	a5,a3,1
ffffffffc0201d76:	892e                	mv	s2,a1
ffffffffc0201d78:	8a32                	mv	s4,a2
ffffffffc0201d7a:	0000b997          	auipc	s3,0xb
ffffffffc0201d7e:	73698993          	addi	s3,s3,1846 # ffffffffc020d4b0 <npage>
ffffffffc0201d82:	efbd                	bnez	a5,ffffffffc0201e00 <get_pte+0xb0>
ffffffffc0201d84:	14060c63          	beqz	a2,ffffffffc0201edc <get_pte+0x18c>
ffffffffc0201d88:	100027f3          	csrr	a5,sstatus
ffffffffc0201d8c:	8b89                	andi	a5,a5,2
ffffffffc0201d8e:	14079963          	bnez	a5,ffffffffc0201ee0 <get_pte+0x190>
ffffffffc0201d92:	0000b797          	auipc	a5,0xb
ffffffffc0201d96:	72e7b783          	ld	a5,1838(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0201d9a:	6f9c                	ld	a5,24(a5)
ffffffffc0201d9c:	4505                	li	a0,1
ffffffffc0201d9e:	9782                	jalr	a5
ffffffffc0201da0:	842a                	mv	s0,a0
ffffffffc0201da2:	12040d63          	beqz	s0,ffffffffc0201edc <get_pte+0x18c>
ffffffffc0201da6:	0000bb17          	auipc	s6,0xb
ffffffffc0201daa:	712b0b13          	addi	s6,s6,1810 # ffffffffc020d4b8 <pages>
ffffffffc0201dae:	000b3503          	ld	a0,0(s6)
ffffffffc0201db2:	00080ab7          	lui	s5,0x80
ffffffffc0201db6:	0000b997          	auipc	s3,0xb
ffffffffc0201dba:	6fa98993          	addi	s3,s3,1786 # ffffffffc020d4b0 <npage>
ffffffffc0201dbe:	40a40533          	sub	a0,s0,a0
ffffffffc0201dc2:	8519                	srai	a0,a0,0x6
ffffffffc0201dc4:	9556                	add	a0,a0,s5
ffffffffc0201dc6:	0009b703          	ld	a4,0(s3)
ffffffffc0201dca:	00c51793          	slli	a5,a0,0xc
ffffffffc0201dce:	4685                	li	a3,1
ffffffffc0201dd0:	c014                	sw	a3,0(s0)
ffffffffc0201dd2:	83b1                	srli	a5,a5,0xc
ffffffffc0201dd4:	0532                	slli	a0,a0,0xc
ffffffffc0201dd6:	16e7f763          	bgeu	a5,a4,ffffffffc0201f44 <get_pte+0x1f4>
ffffffffc0201dda:	0000b797          	auipc	a5,0xb
ffffffffc0201dde:	6ee7b783          	ld	a5,1774(a5) # ffffffffc020d4c8 <va_pa_offset>
ffffffffc0201de2:	6605                	lui	a2,0x1
ffffffffc0201de4:	4581                	li	a1,0
ffffffffc0201de6:	953e                	add	a0,a0,a5
ffffffffc0201de8:	088020ef          	jal	ra,ffffffffc0203e70 <memset>
ffffffffc0201dec:	000b3683          	ld	a3,0(s6)
ffffffffc0201df0:	40d406b3          	sub	a3,s0,a3
ffffffffc0201df4:	8699                	srai	a3,a3,0x6
ffffffffc0201df6:	96d6                	add	a3,a3,s5
ffffffffc0201df8:	06aa                	slli	a3,a3,0xa
ffffffffc0201dfa:	0116e693          	ori	a3,a3,17
ffffffffc0201dfe:	e094                	sd	a3,0(s1)
ffffffffc0201e00:	77fd                	lui	a5,0xfffff
ffffffffc0201e02:	068a                	slli	a3,a3,0x2
ffffffffc0201e04:	0009b703          	ld	a4,0(s3)
ffffffffc0201e08:	8efd                	and	a3,a3,a5
ffffffffc0201e0a:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201e0e:	10e7ff63          	bgeu	a5,a4,ffffffffc0201f2c <get_pte+0x1dc>
ffffffffc0201e12:	0000ba97          	auipc	s5,0xb
ffffffffc0201e16:	6b6a8a93          	addi	s5,s5,1718 # ffffffffc020d4c8 <va_pa_offset>
ffffffffc0201e1a:	000ab403          	ld	s0,0(s5)
ffffffffc0201e1e:	01595793          	srli	a5,s2,0x15
ffffffffc0201e22:	1ff7f793          	andi	a5,a5,511
ffffffffc0201e26:	96a2                	add	a3,a3,s0
ffffffffc0201e28:	00379413          	slli	s0,a5,0x3
ffffffffc0201e2c:	9436                	add	s0,s0,a3
ffffffffc0201e2e:	6014                	ld	a3,0(s0)
ffffffffc0201e30:	0016f793          	andi	a5,a3,1
ffffffffc0201e34:	ebad                	bnez	a5,ffffffffc0201ea6 <get_pte+0x156>
ffffffffc0201e36:	0a0a0363          	beqz	s4,ffffffffc0201edc <get_pte+0x18c>
ffffffffc0201e3a:	100027f3          	csrr	a5,sstatus
ffffffffc0201e3e:	8b89                	andi	a5,a5,2
ffffffffc0201e40:	efcd                	bnez	a5,ffffffffc0201efa <get_pte+0x1aa>
ffffffffc0201e42:	0000b797          	auipc	a5,0xb
ffffffffc0201e46:	67e7b783          	ld	a5,1662(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0201e4a:	6f9c                	ld	a5,24(a5)
ffffffffc0201e4c:	4505                	li	a0,1
ffffffffc0201e4e:	9782                	jalr	a5
ffffffffc0201e50:	84aa                	mv	s1,a0
ffffffffc0201e52:	c4c9                	beqz	s1,ffffffffc0201edc <get_pte+0x18c>
ffffffffc0201e54:	0000bb17          	auipc	s6,0xb
ffffffffc0201e58:	664b0b13          	addi	s6,s6,1636 # ffffffffc020d4b8 <pages>
ffffffffc0201e5c:	000b3503          	ld	a0,0(s6)
ffffffffc0201e60:	00080a37          	lui	s4,0x80
ffffffffc0201e64:	0009b703          	ld	a4,0(s3)
ffffffffc0201e68:	40a48533          	sub	a0,s1,a0
ffffffffc0201e6c:	8519                	srai	a0,a0,0x6
ffffffffc0201e6e:	9552                	add	a0,a0,s4
ffffffffc0201e70:	00c51793          	slli	a5,a0,0xc
ffffffffc0201e74:	4685                	li	a3,1
ffffffffc0201e76:	c094                	sw	a3,0(s1)
ffffffffc0201e78:	83b1                	srli	a5,a5,0xc
ffffffffc0201e7a:	0532                	slli	a0,a0,0xc
ffffffffc0201e7c:	0ee7f163          	bgeu	a5,a4,ffffffffc0201f5e <get_pte+0x20e>
ffffffffc0201e80:	000ab783          	ld	a5,0(s5)
ffffffffc0201e84:	6605                	lui	a2,0x1
ffffffffc0201e86:	4581                	li	a1,0
ffffffffc0201e88:	953e                	add	a0,a0,a5
ffffffffc0201e8a:	7e7010ef          	jal	ra,ffffffffc0203e70 <memset>
ffffffffc0201e8e:	000b3683          	ld	a3,0(s6)
ffffffffc0201e92:	40d486b3          	sub	a3,s1,a3
ffffffffc0201e96:	8699                	srai	a3,a3,0x6
ffffffffc0201e98:	96d2                	add	a3,a3,s4
ffffffffc0201e9a:	06aa                	slli	a3,a3,0xa
ffffffffc0201e9c:	0116e693          	ori	a3,a3,17
ffffffffc0201ea0:	e014                	sd	a3,0(s0)
ffffffffc0201ea2:	0009b703          	ld	a4,0(s3)
ffffffffc0201ea6:	068a                	slli	a3,a3,0x2
ffffffffc0201ea8:	757d                	lui	a0,0xfffff
ffffffffc0201eaa:	8ee9                	and	a3,a3,a0
ffffffffc0201eac:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201eb0:	06e7f263          	bgeu	a5,a4,ffffffffc0201f14 <get_pte+0x1c4>
ffffffffc0201eb4:	000ab503          	ld	a0,0(s5)
ffffffffc0201eb8:	00c95913          	srli	s2,s2,0xc
ffffffffc0201ebc:	1ff97913          	andi	s2,s2,511
ffffffffc0201ec0:	96aa                	add	a3,a3,a0
ffffffffc0201ec2:	00391513          	slli	a0,s2,0x3
ffffffffc0201ec6:	9536                	add	a0,a0,a3
ffffffffc0201ec8:	70e2                	ld	ra,56(sp)
ffffffffc0201eca:	7442                	ld	s0,48(sp)
ffffffffc0201ecc:	74a2                	ld	s1,40(sp)
ffffffffc0201ece:	7902                	ld	s2,32(sp)
ffffffffc0201ed0:	69e2                	ld	s3,24(sp)
ffffffffc0201ed2:	6a42                	ld	s4,16(sp)
ffffffffc0201ed4:	6aa2                	ld	s5,8(sp)
ffffffffc0201ed6:	6b02                	ld	s6,0(sp)
ffffffffc0201ed8:	6121                	addi	sp,sp,64
ffffffffc0201eda:	8082                	ret
ffffffffc0201edc:	4501                	li	a0,0
ffffffffc0201ede:	b7ed                	j	ffffffffc0201ec8 <get_pte+0x178>
ffffffffc0201ee0:	a51fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc0201ee4:	0000b797          	auipc	a5,0xb
ffffffffc0201ee8:	5dc7b783          	ld	a5,1500(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0201eec:	6f9c                	ld	a5,24(a5)
ffffffffc0201eee:	4505                	li	a0,1
ffffffffc0201ef0:	9782                	jalr	a5
ffffffffc0201ef2:	842a                	mv	s0,a0
ffffffffc0201ef4:	a37fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0201ef8:	b56d                	j	ffffffffc0201da2 <get_pte+0x52>
ffffffffc0201efa:	a37fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc0201efe:	0000b797          	auipc	a5,0xb
ffffffffc0201f02:	5c27b783          	ld	a5,1474(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0201f06:	6f9c                	ld	a5,24(a5)
ffffffffc0201f08:	4505                	li	a0,1
ffffffffc0201f0a:	9782                	jalr	a5
ffffffffc0201f0c:	84aa                	mv	s1,a0
ffffffffc0201f0e:	a1dfe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0201f12:	b781                	j	ffffffffc0201e52 <get_pte+0x102>
ffffffffc0201f14:	00003617          	auipc	a2,0x3
ffffffffc0201f18:	e1460613          	addi	a2,a2,-492 # ffffffffc0204d28 <default_pmm_manager+0x38>
ffffffffc0201f1c:	0fb00593          	li	a1,251
ffffffffc0201f20:	00003517          	auipc	a0,0x3
ffffffffc0201f24:	f2050513          	addi	a0,a0,-224 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0201f28:	d32fe0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201f2c:	00003617          	auipc	a2,0x3
ffffffffc0201f30:	dfc60613          	addi	a2,a2,-516 # ffffffffc0204d28 <default_pmm_manager+0x38>
ffffffffc0201f34:	0ee00593          	li	a1,238
ffffffffc0201f38:	00003517          	auipc	a0,0x3
ffffffffc0201f3c:	f0850513          	addi	a0,a0,-248 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0201f40:	d1afe0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201f44:	86aa                	mv	a3,a0
ffffffffc0201f46:	00003617          	auipc	a2,0x3
ffffffffc0201f4a:	de260613          	addi	a2,a2,-542 # ffffffffc0204d28 <default_pmm_manager+0x38>
ffffffffc0201f4e:	0e900593          	li	a1,233
ffffffffc0201f52:	00003517          	auipc	a0,0x3
ffffffffc0201f56:	eee50513          	addi	a0,a0,-274 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0201f5a:	d00fe0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0201f5e:	86aa                	mv	a3,a0
ffffffffc0201f60:	00003617          	auipc	a2,0x3
ffffffffc0201f64:	dc860613          	addi	a2,a2,-568 # ffffffffc0204d28 <default_pmm_manager+0x38>
ffffffffc0201f68:	0f700593          	li	a1,247
ffffffffc0201f6c:	00003517          	auipc	a0,0x3
ffffffffc0201f70:	ed450513          	addi	a0,a0,-300 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0201f74:	ce6fe0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0201f78 <get_page>:
ffffffffc0201f78:	1141                	addi	sp,sp,-16
ffffffffc0201f7a:	e022                	sd	s0,0(sp)
ffffffffc0201f7c:	8432                	mv	s0,a2
ffffffffc0201f7e:	4601                	li	a2,0
ffffffffc0201f80:	e406                	sd	ra,8(sp)
ffffffffc0201f82:	dcfff0ef          	jal	ra,ffffffffc0201d50 <get_pte>
ffffffffc0201f86:	c011                	beqz	s0,ffffffffc0201f8a <get_page+0x12>
ffffffffc0201f88:	e008                	sd	a0,0(s0)
ffffffffc0201f8a:	c511                	beqz	a0,ffffffffc0201f96 <get_page+0x1e>
ffffffffc0201f8c:	611c                	ld	a5,0(a0)
ffffffffc0201f8e:	4501                	li	a0,0
ffffffffc0201f90:	0017f713          	andi	a4,a5,1
ffffffffc0201f94:	e709                	bnez	a4,ffffffffc0201f9e <get_page+0x26>
ffffffffc0201f96:	60a2                	ld	ra,8(sp)
ffffffffc0201f98:	6402                	ld	s0,0(sp)
ffffffffc0201f9a:	0141                	addi	sp,sp,16
ffffffffc0201f9c:	8082                	ret
ffffffffc0201f9e:	078a                	slli	a5,a5,0x2
ffffffffc0201fa0:	83b1                	srli	a5,a5,0xc
ffffffffc0201fa2:	0000b717          	auipc	a4,0xb
ffffffffc0201fa6:	50e73703          	ld	a4,1294(a4) # ffffffffc020d4b0 <npage>
ffffffffc0201faa:	00e7ff63          	bgeu	a5,a4,ffffffffc0201fc8 <get_page+0x50>
ffffffffc0201fae:	60a2                	ld	ra,8(sp)
ffffffffc0201fb0:	6402                	ld	s0,0(sp)
ffffffffc0201fb2:	fff80537          	lui	a0,0xfff80
ffffffffc0201fb6:	97aa                	add	a5,a5,a0
ffffffffc0201fb8:	079a                	slli	a5,a5,0x6
ffffffffc0201fba:	0000b517          	auipc	a0,0xb
ffffffffc0201fbe:	4fe53503          	ld	a0,1278(a0) # ffffffffc020d4b8 <pages>
ffffffffc0201fc2:	953e                	add	a0,a0,a5
ffffffffc0201fc4:	0141                	addi	sp,sp,16
ffffffffc0201fc6:	8082                	ret
ffffffffc0201fc8:	c99ff0ef          	jal	ra,ffffffffc0201c60 <pa2page.part.0>

ffffffffc0201fcc <page_remove>:
ffffffffc0201fcc:	7179                	addi	sp,sp,-48
ffffffffc0201fce:	4601                	li	a2,0
ffffffffc0201fd0:	ec26                	sd	s1,24(sp)
ffffffffc0201fd2:	f406                	sd	ra,40(sp)
ffffffffc0201fd4:	f022                	sd	s0,32(sp)
ffffffffc0201fd6:	84ae                	mv	s1,a1
ffffffffc0201fd8:	d79ff0ef          	jal	ra,ffffffffc0201d50 <get_pte>
ffffffffc0201fdc:	c511                	beqz	a0,ffffffffc0201fe8 <page_remove+0x1c>
ffffffffc0201fde:	611c                	ld	a5,0(a0)
ffffffffc0201fe0:	842a                	mv	s0,a0
ffffffffc0201fe2:	0017f713          	andi	a4,a5,1
ffffffffc0201fe6:	e711                	bnez	a4,ffffffffc0201ff2 <page_remove+0x26>
ffffffffc0201fe8:	70a2                	ld	ra,40(sp)
ffffffffc0201fea:	7402                	ld	s0,32(sp)
ffffffffc0201fec:	64e2                	ld	s1,24(sp)
ffffffffc0201fee:	6145                	addi	sp,sp,48
ffffffffc0201ff0:	8082                	ret
ffffffffc0201ff2:	078a                	slli	a5,a5,0x2
ffffffffc0201ff4:	83b1                	srli	a5,a5,0xc
ffffffffc0201ff6:	0000b717          	auipc	a4,0xb
ffffffffc0201ffa:	4ba73703          	ld	a4,1210(a4) # ffffffffc020d4b0 <npage>
ffffffffc0201ffe:	06e7f363          	bgeu	a5,a4,ffffffffc0202064 <page_remove+0x98>
ffffffffc0202002:	fff80537          	lui	a0,0xfff80
ffffffffc0202006:	97aa                	add	a5,a5,a0
ffffffffc0202008:	079a                	slli	a5,a5,0x6
ffffffffc020200a:	0000b517          	auipc	a0,0xb
ffffffffc020200e:	4ae53503          	ld	a0,1198(a0) # ffffffffc020d4b8 <pages>
ffffffffc0202012:	953e                	add	a0,a0,a5
ffffffffc0202014:	411c                	lw	a5,0(a0)
ffffffffc0202016:	fff7871b          	addiw	a4,a5,-1
ffffffffc020201a:	c118                	sw	a4,0(a0)
ffffffffc020201c:	cb11                	beqz	a4,ffffffffc0202030 <page_remove+0x64>
ffffffffc020201e:	00043023          	sd	zero,0(s0)
ffffffffc0202022:	12048073          	sfence.vma	s1
ffffffffc0202026:	70a2                	ld	ra,40(sp)
ffffffffc0202028:	7402                	ld	s0,32(sp)
ffffffffc020202a:	64e2                	ld	s1,24(sp)
ffffffffc020202c:	6145                	addi	sp,sp,48
ffffffffc020202e:	8082                	ret
ffffffffc0202030:	100027f3          	csrr	a5,sstatus
ffffffffc0202034:	8b89                	andi	a5,a5,2
ffffffffc0202036:	eb89                	bnez	a5,ffffffffc0202048 <page_remove+0x7c>
ffffffffc0202038:	0000b797          	auipc	a5,0xb
ffffffffc020203c:	4887b783          	ld	a5,1160(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0202040:	739c                	ld	a5,32(a5)
ffffffffc0202042:	4585                	li	a1,1
ffffffffc0202044:	9782                	jalr	a5
ffffffffc0202046:	bfe1                	j	ffffffffc020201e <page_remove+0x52>
ffffffffc0202048:	e42a                	sd	a0,8(sp)
ffffffffc020204a:	8e7fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc020204e:	0000b797          	auipc	a5,0xb
ffffffffc0202052:	4727b783          	ld	a5,1138(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0202056:	739c                	ld	a5,32(a5)
ffffffffc0202058:	6522                	ld	a0,8(sp)
ffffffffc020205a:	4585                	li	a1,1
ffffffffc020205c:	9782                	jalr	a5
ffffffffc020205e:	8cdfe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0202062:	bf75                	j	ffffffffc020201e <page_remove+0x52>
ffffffffc0202064:	bfdff0ef          	jal	ra,ffffffffc0201c60 <pa2page.part.0>

ffffffffc0202068 <page_insert>:
ffffffffc0202068:	7139                	addi	sp,sp,-64
ffffffffc020206a:	e852                	sd	s4,16(sp)
ffffffffc020206c:	8a32                	mv	s4,a2
ffffffffc020206e:	f822                	sd	s0,48(sp)
ffffffffc0202070:	4605                	li	a2,1
ffffffffc0202072:	842e                	mv	s0,a1
ffffffffc0202074:	85d2                	mv	a1,s4
ffffffffc0202076:	f426                	sd	s1,40(sp)
ffffffffc0202078:	fc06                	sd	ra,56(sp)
ffffffffc020207a:	f04a                	sd	s2,32(sp)
ffffffffc020207c:	ec4e                	sd	s3,24(sp)
ffffffffc020207e:	e456                	sd	s5,8(sp)
ffffffffc0202080:	84b6                	mv	s1,a3
ffffffffc0202082:	ccfff0ef          	jal	ra,ffffffffc0201d50 <get_pte>
ffffffffc0202086:	c961                	beqz	a0,ffffffffc0202156 <page_insert+0xee>
ffffffffc0202088:	4014                	lw	a3,0(s0)
ffffffffc020208a:	611c                	ld	a5,0(a0)
ffffffffc020208c:	89aa                	mv	s3,a0
ffffffffc020208e:	0016871b          	addiw	a4,a3,1
ffffffffc0202092:	c018                	sw	a4,0(s0)
ffffffffc0202094:	0017f713          	andi	a4,a5,1
ffffffffc0202098:	ef05                	bnez	a4,ffffffffc02020d0 <page_insert+0x68>
ffffffffc020209a:	0000b717          	auipc	a4,0xb
ffffffffc020209e:	41e73703          	ld	a4,1054(a4) # ffffffffc020d4b8 <pages>
ffffffffc02020a2:	8c19                	sub	s0,s0,a4
ffffffffc02020a4:	000807b7          	lui	a5,0x80
ffffffffc02020a8:	8419                	srai	s0,s0,0x6
ffffffffc02020aa:	943e                	add	s0,s0,a5
ffffffffc02020ac:	042a                	slli	s0,s0,0xa
ffffffffc02020ae:	8cc1                	or	s1,s1,s0
ffffffffc02020b0:	0014e493          	ori	s1,s1,1
ffffffffc02020b4:	0099b023          	sd	s1,0(s3)
ffffffffc02020b8:	120a0073          	sfence.vma	s4
ffffffffc02020bc:	4501                	li	a0,0
ffffffffc02020be:	70e2                	ld	ra,56(sp)
ffffffffc02020c0:	7442                	ld	s0,48(sp)
ffffffffc02020c2:	74a2                	ld	s1,40(sp)
ffffffffc02020c4:	7902                	ld	s2,32(sp)
ffffffffc02020c6:	69e2                	ld	s3,24(sp)
ffffffffc02020c8:	6a42                	ld	s4,16(sp)
ffffffffc02020ca:	6aa2                	ld	s5,8(sp)
ffffffffc02020cc:	6121                	addi	sp,sp,64
ffffffffc02020ce:	8082                	ret
ffffffffc02020d0:	078a                	slli	a5,a5,0x2
ffffffffc02020d2:	83b1                	srli	a5,a5,0xc
ffffffffc02020d4:	0000b717          	auipc	a4,0xb
ffffffffc02020d8:	3dc73703          	ld	a4,988(a4) # ffffffffc020d4b0 <npage>
ffffffffc02020dc:	06e7ff63          	bgeu	a5,a4,ffffffffc020215a <page_insert+0xf2>
ffffffffc02020e0:	0000ba97          	auipc	s5,0xb
ffffffffc02020e4:	3d8a8a93          	addi	s5,s5,984 # ffffffffc020d4b8 <pages>
ffffffffc02020e8:	000ab703          	ld	a4,0(s5)
ffffffffc02020ec:	fff80937          	lui	s2,0xfff80
ffffffffc02020f0:	993e                	add	s2,s2,a5
ffffffffc02020f2:	091a                	slli	s2,s2,0x6
ffffffffc02020f4:	993a                	add	s2,s2,a4
ffffffffc02020f6:	01240c63          	beq	s0,s2,ffffffffc020210e <page_insert+0xa6>
ffffffffc02020fa:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fd72b14>
ffffffffc02020fe:	fff7869b          	addiw	a3,a5,-1
ffffffffc0202102:	00d92023          	sw	a3,0(s2)
ffffffffc0202106:	c691                	beqz	a3,ffffffffc0202112 <page_insert+0xaa>
ffffffffc0202108:	120a0073          	sfence.vma	s4
ffffffffc020210c:	bf59                	j	ffffffffc02020a2 <page_insert+0x3a>
ffffffffc020210e:	c014                	sw	a3,0(s0)
ffffffffc0202110:	bf49                	j	ffffffffc02020a2 <page_insert+0x3a>
ffffffffc0202112:	100027f3          	csrr	a5,sstatus
ffffffffc0202116:	8b89                	andi	a5,a5,2
ffffffffc0202118:	ef91                	bnez	a5,ffffffffc0202134 <page_insert+0xcc>
ffffffffc020211a:	0000b797          	auipc	a5,0xb
ffffffffc020211e:	3a67b783          	ld	a5,934(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0202122:	739c                	ld	a5,32(a5)
ffffffffc0202124:	4585                	li	a1,1
ffffffffc0202126:	854a                	mv	a0,s2
ffffffffc0202128:	9782                	jalr	a5
ffffffffc020212a:	000ab703          	ld	a4,0(s5)
ffffffffc020212e:	120a0073          	sfence.vma	s4
ffffffffc0202132:	bf85                	j	ffffffffc02020a2 <page_insert+0x3a>
ffffffffc0202134:	ffcfe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc0202138:	0000b797          	auipc	a5,0xb
ffffffffc020213c:	3887b783          	ld	a5,904(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0202140:	739c                	ld	a5,32(a5)
ffffffffc0202142:	4585                	li	a1,1
ffffffffc0202144:	854a                	mv	a0,s2
ffffffffc0202146:	9782                	jalr	a5
ffffffffc0202148:	fe2fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc020214c:	000ab703          	ld	a4,0(s5)
ffffffffc0202150:	120a0073          	sfence.vma	s4
ffffffffc0202154:	b7b9                	j	ffffffffc02020a2 <page_insert+0x3a>
ffffffffc0202156:	5571                	li	a0,-4
ffffffffc0202158:	b79d                	j	ffffffffc02020be <page_insert+0x56>
ffffffffc020215a:	b07ff0ef          	jal	ra,ffffffffc0201c60 <pa2page.part.0>

ffffffffc020215e <pmm_init>:
ffffffffc020215e:	00003797          	auipc	a5,0x3
ffffffffc0202162:	b9278793          	addi	a5,a5,-1134 # ffffffffc0204cf0 <default_pmm_manager>
ffffffffc0202166:	638c                	ld	a1,0(a5)
ffffffffc0202168:	7159                	addi	sp,sp,-112
ffffffffc020216a:	f85a                	sd	s6,48(sp)
ffffffffc020216c:	00003517          	auipc	a0,0x3
ffffffffc0202170:	ce450513          	addi	a0,a0,-796 # ffffffffc0204e50 <default_pmm_manager+0x160>
ffffffffc0202174:	0000bb17          	auipc	s6,0xb
ffffffffc0202178:	34cb0b13          	addi	s6,s6,844 # ffffffffc020d4c0 <pmm_manager>
ffffffffc020217c:	f486                	sd	ra,104(sp)
ffffffffc020217e:	e8ca                	sd	s2,80(sp)
ffffffffc0202180:	e4ce                	sd	s3,72(sp)
ffffffffc0202182:	f0a2                	sd	s0,96(sp)
ffffffffc0202184:	eca6                	sd	s1,88(sp)
ffffffffc0202186:	e0d2                	sd	s4,64(sp)
ffffffffc0202188:	fc56                	sd	s5,56(sp)
ffffffffc020218a:	f45e                	sd	s7,40(sp)
ffffffffc020218c:	f062                	sd	s8,32(sp)
ffffffffc020218e:	ec66                	sd	s9,24(sp)
ffffffffc0202190:	00fb3023          	sd	a5,0(s6)
ffffffffc0202194:	800fe0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0202198:	000b3783          	ld	a5,0(s6)
ffffffffc020219c:	0000b997          	auipc	s3,0xb
ffffffffc02021a0:	32c98993          	addi	s3,s3,812 # ffffffffc020d4c8 <va_pa_offset>
ffffffffc02021a4:	679c                	ld	a5,8(a5)
ffffffffc02021a6:	9782                	jalr	a5
ffffffffc02021a8:	57f5                	li	a5,-3
ffffffffc02021aa:	07fa                	slli	a5,a5,0x1e
ffffffffc02021ac:	00f9b023          	sd	a5,0(s3)
ffffffffc02021b0:	f66fe0ef          	jal	ra,ffffffffc0200916 <get_memory_base>
ffffffffc02021b4:	892a                	mv	s2,a0
ffffffffc02021b6:	f6afe0ef          	jal	ra,ffffffffc0200920 <get_memory_size>
ffffffffc02021ba:	200505e3          	beqz	a0,ffffffffc0202bc4 <pmm_init+0xa66>
ffffffffc02021be:	84aa                	mv	s1,a0
ffffffffc02021c0:	00003517          	auipc	a0,0x3
ffffffffc02021c4:	cc850513          	addi	a0,a0,-824 # ffffffffc0204e88 <default_pmm_manager+0x198>
ffffffffc02021c8:	fcdfd0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02021cc:	00990433          	add	s0,s2,s1
ffffffffc02021d0:	fff40693          	addi	a3,s0,-1
ffffffffc02021d4:	864a                	mv	a2,s2
ffffffffc02021d6:	85a6                	mv	a1,s1
ffffffffc02021d8:	00003517          	auipc	a0,0x3
ffffffffc02021dc:	cc850513          	addi	a0,a0,-824 # ffffffffc0204ea0 <default_pmm_manager+0x1b0>
ffffffffc02021e0:	fb5fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02021e4:	c8000737          	lui	a4,0xc8000
ffffffffc02021e8:	87a2                	mv	a5,s0
ffffffffc02021ea:	54876163          	bltu	a4,s0,ffffffffc020272c <pmm_init+0x5ce>
ffffffffc02021ee:	757d                	lui	a0,0xfffff
ffffffffc02021f0:	0000c617          	auipc	a2,0xc
ffffffffc02021f4:	2fb60613          	addi	a2,a2,763 # ffffffffc020e4eb <end+0xfff>
ffffffffc02021f8:	8e69                	and	a2,a2,a0
ffffffffc02021fa:	0000b497          	auipc	s1,0xb
ffffffffc02021fe:	2b648493          	addi	s1,s1,694 # ffffffffc020d4b0 <npage>
ffffffffc0202202:	00c7d513          	srli	a0,a5,0xc
ffffffffc0202206:	0000bb97          	auipc	s7,0xb
ffffffffc020220a:	2b2b8b93          	addi	s7,s7,690 # ffffffffc020d4b8 <pages>
ffffffffc020220e:	e088                	sd	a0,0(s1)
ffffffffc0202210:	00cbb023          	sd	a2,0(s7)
ffffffffc0202214:	000807b7          	lui	a5,0x80
ffffffffc0202218:	86b2                	mv	a3,a2
ffffffffc020221a:	02f50863          	beq	a0,a5,ffffffffc020224a <pmm_init+0xec>
ffffffffc020221e:	4781                	li	a5,0
ffffffffc0202220:	4585                	li	a1,1
ffffffffc0202222:	fff806b7          	lui	a3,0xfff80
ffffffffc0202226:	00679513          	slli	a0,a5,0x6
ffffffffc020222a:	9532                	add	a0,a0,a2
ffffffffc020222c:	00850713          	addi	a4,a0,8 # fffffffffffff008 <end+0x3fdf1b1c>
ffffffffc0202230:	40b7302f          	amoor.d	zero,a1,(a4)
ffffffffc0202234:	6088                	ld	a0,0(s1)
ffffffffc0202236:	0785                	addi	a5,a5,1
ffffffffc0202238:	000bb603          	ld	a2,0(s7)
ffffffffc020223c:	00d50733          	add	a4,a0,a3
ffffffffc0202240:	fee7e3e3          	bltu	a5,a4,ffffffffc0202226 <pmm_init+0xc8>
ffffffffc0202244:	071a                	slli	a4,a4,0x6
ffffffffc0202246:	00e606b3          	add	a3,a2,a4
ffffffffc020224a:	c02007b7          	lui	a5,0xc0200
ffffffffc020224e:	2ef6ece3          	bltu	a3,a5,ffffffffc0202d46 <pmm_init+0xbe8>
ffffffffc0202252:	0009b583          	ld	a1,0(s3)
ffffffffc0202256:	77fd                	lui	a5,0xfffff
ffffffffc0202258:	8c7d                	and	s0,s0,a5
ffffffffc020225a:	8e8d                	sub	a3,a3,a1
ffffffffc020225c:	5086eb63          	bltu	a3,s0,ffffffffc0202772 <pmm_init+0x614>
ffffffffc0202260:	00003517          	auipc	a0,0x3
ffffffffc0202264:	c6850513          	addi	a0,a0,-920 # ffffffffc0204ec8 <default_pmm_manager+0x1d8>
ffffffffc0202268:	f2dfd0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc020226c:	000b3783          	ld	a5,0(s6)
ffffffffc0202270:	0000b917          	auipc	s2,0xb
ffffffffc0202274:	23890913          	addi	s2,s2,568 # ffffffffc020d4a8 <boot_pgdir_va>
ffffffffc0202278:	7b9c                	ld	a5,48(a5)
ffffffffc020227a:	9782                	jalr	a5
ffffffffc020227c:	00003517          	auipc	a0,0x3
ffffffffc0202280:	c6450513          	addi	a0,a0,-924 # ffffffffc0204ee0 <default_pmm_manager+0x1f0>
ffffffffc0202284:	f11fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0202288:	00006697          	auipc	a3,0x6
ffffffffc020228c:	d7868693          	addi	a3,a3,-648 # ffffffffc0208000 <boot_page_table_sv39>
ffffffffc0202290:	00d93023          	sd	a3,0(s2)
ffffffffc0202294:	c02007b7          	lui	a5,0xc0200
ffffffffc0202298:	28f6ebe3          	bltu	a3,a5,ffffffffc0202d2e <pmm_init+0xbd0>
ffffffffc020229c:	0009b783          	ld	a5,0(s3)
ffffffffc02022a0:	8e9d                	sub	a3,a3,a5
ffffffffc02022a2:	0000b797          	auipc	a5,0xb
ffffffffc02022a6:	1ed7bf23          	sd	a3,510(a5) # ffffffffc020d4a0 <boot_pgdir_pa>
ffffffffc02022aa:	100027f3          	csrr	a5,sstatus
ffffffffc02022ae:	8b89                	andi	a5,a5,2
ffffffffc02022b0:	4a079763          	bnez	a5,ffffffffc020275e <pmm_init+0x600>
ffffffffc02022b4:	000b3783          	ld	a5,0(s6)
ffffffffc02022b8:	779c                	ld	a5,40(a5)
ffffffffc02022ba:	9782                	jalr	a5
ffffffffc02022bc:	842a                	mv	s0,a0
ffffffffc02022be:	6098                	ld	a4,0(s1)
ffffffffc02022c0:	c80007b7          	lui	a5,0xc8000
ffffffffc02022c4:	83b1                	srli	a5,a5,0xc
ffffffffc02022c6:	66e7e363          	bltu	a5,a4,ffffffffc020292c <pmm_init+0x7ce>
ffffffffc02022ca:	00093503          	ld	a0,0(s2)
ffffffffc02022ce:	62050f63          	beqz	a0,ffffffffc020290c <pmm_init+0x7ae>
ffffffffc02022d2:	03451793          	slli	a5,a0,0x34
ffffffffc02022d6:	62079b63          	bnez	a5,ffffffffc020290c <pmm_init+0x7ae>
ffffffffc02022da:	4601                	li	a2,0
ffffffffc02022dc:	4581                	li	a1,0
ffffffffc02022de:	c9bff0ef          	jal	ra,ffffffffc0201f78 <get_page>
ffffffffc02022e2:	60051563          	bnez	a0,ffffffffc02028ec <pmm_init+0x78e>
ffffffffc02022e6:	100027f3          	csrr	a5,sstatus
ffffffffc02022ea:	8b89                	andi	a5,a5,2
ffffffffc02022ec:	44079e63          	bnez	a5,ffffffffc0202748 <pmm_init+0x5ea>
ffffffffc02022f0:	000b3783          	ld	a5,0(s6)
ffffffffc02022f4:	4505                	li	a0,1
ffffffffc02022f6:	6f9c                	ld	a5,24(a5)
ffffffffc02022f8:	9782                	jalr	a5
ffffffffc02022fa:	8a2a                	mv	s4,a0
ffffffffc02022fc:	00093503          	ld	a0,0(s2)
ffffffffc0202300:	4681                	li	a3,0
ffffffffc0202302:	4601                	li	a2,0
ffffffffc0202304:	85d2                	mv	a1,s4
ffffffffc0202306:	d63ff0ef          	jal	ra,ffffffffc0202068 <page_insert>
ffffffffc020230a:	26051ae3          	bnez	a0,ffffffffc0202d7e <pmm_init+0xc20>
ffffffffc020230e:	00093503          	ld	a0,0(s2)
ffffffffc0202312:	4601                	li	a2,0
ffffffffc0202314:	4581                	li	a1,0
ffffffffc0202316:	a3bff0ef          	jal	ra,ffffffffc0201d50 <get_pte>
ffffffffc020231a:	240502e3          	beqz	a0,ffffffffc0202d5e <pmm_init+0xc00>
ffffffffc020231e:	611c                	ld	a5,0(a0)
ffffffffc0202320:	0017f713          	andi	a4,a5,1
ffffffffc0202324:	5a070263          	beqz	a4,ffffffffc02028c8 <pmm_init+0x76a>
ffffffffc0202328:	6098                	ld	a4,0(s1)
ffffffffc020232a:	078a                	slli	a5,a5,0x2
ffffffffc020232c:	83b1                	srli	a5,a5,0xc
ffffffffc020232e:	58e7fb63          	bgeu	a5,a4,ffffffffc02028c4 <pmm_init+0x766>
ffffffffc0202332:	000bb683          	ld	a3,0(s7)
ffffffffc0202336:	fff80637          	lui	a2,0xfff80
ffffffffc020233a:	97b2                	add	a5,a5,a2
ffffffffc020233c:	079a                	slli	a5,a5,0x6
ffffffffc020233e:	97b6                	add	a5,a5,a3
ffffffffc0202340:	14fa17e3          	bne	s4,a5,ffffffffc0202c8e <pmm_init+0xb30>
ffffffffc0202344:	000a2683          	lw	a3,0(s4) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0202348:	4785                	li	a5,1
ffffffffc020234a:	12f692e3          	bne	a3,a5,ffffffffc0202c6e <pmm_init+0xb10>
ffffffffc020234e:	00093503          	ld	a0,0(s2)
ffffffffc0202352:	77fd                	lui	a5,0xfffff
ffffffffc0202354:	6114                	ld	a3,0(a0)
ffffffffc0202356:	068a                	slli	a3,a3,0x2
ffffffffc0202358:	8efd                	and	a3,a3,a5
ffffffffc020235a:	00c6d613          	srli	a2,a3,0xc
ffffffffc020235e:	0ee67ce3          	bgeu	a2,a4,ffffffffc0202c56 <pmm_init+0xaf8>
ffffffffc0202362:	0009bc03          	ld	s8,0(s3)
ffffffffc0202366:	96e2                	add	a3,a3,s8
ffffffffc0202368:	0006ba83          	ld	s5,0(a3)
ffffffffc020236c:	0a8a                	slli	s5,s5,0x2
ffffffffc020236e:	00fafab3          	and	s5,s5,a5
ffffffffc0202372:	00cad793          	srli	a5,s5,0xc
ffffffffc0202376:	0ce7f3e3          	bgeu	a5,a4,ffffffffc0202c3c <pmm_init+0xade>
ffffffffc020237a:	4601                	li	a2,0
ffffffffc020237c:	6585                	lui	a1,0x1
ffffffffc020237e:	9ae2                	add	s5,s5,s8
ffffffffc0202380:	9d1ff0ef          	jal	ra,ffffffffc0201d50 <get_pte>
ffffffffc0202384:	0aa1                	addi	s5,s5,8
ffffffffc0202386:	55551363          	bne	a0,s5,ffffffffc02028cc <pmm_init+0x76e>
ffffffffc020238a:	100027f3          	csrr	a5,sstatus
ffffffffc020238e:	8b89                	andi	a5,a5,2
ffffffffc0202390:	3a079163          	bnez	a5,ffffffffc0202732 <pmm_init+0x5d4>
ffffffffc0202394:	000b3783          	ld	a5,0(s6)
ffffffffc0202398:	4505                	li	a0,1
ffffffffc020239a:	6f9c                	ld	a5,24(a5)
ffffffffc020239c:	9782                	jalr	a5
ffffffffc020239e:	8c2a                	mv	s8,a0
ffffffffc02023a0:	00093503          	ld	a0,0(s2)
ffffffffc02023a4:	46d1                	li	a3,20
ffffffffc02023a6:	6605                	lui	a2,0x1
ffffffffc02023a8:	85e2                	mv	a1,s8
ffffffffc02023aa:	cbfff0ef          	jal	ra,ffffffffc0202068 <page_insert>
ffffffffc02023ae:	060517e3          	bnez	a0,ffffffffc0202c1c <pmm_init+0xabe>
ffffffffc02023b2:	00093503          	ld	a0,0(s2)
ffffffffc02023b6:	4601                	li	a2,0
ffffffffc02023b8:	6585                	lui	a1,0x1
ffffffffc02023ba:	997ff0ef          	jal	ra,ffffffffc0201d50 <get_pte>
ffffffffc02023be:	02050fe3          	beqz	a0,ffffffffc0202bfc <pmm_init+0xa9e>
ffffffffc02023c2:	611c                	ld	a5,0(a0)
ffffffffc02023c4:	0107f713          	andi	a4,a5,16
ffffffffc02023c8:	7c070e63          	beqz	a4,ffffffffc0202ba4 <pmm_init+0xa46>
ffffffffc02023cc:	8b91                	andi	a5,a5,4
ffffffffc02023ce:	7a078b63          	beqz	a5,ffffffffc0202b84 <pmm_init+0xa26>
ffffffffc02023d2:	00093503          	ld	a0,0(s2)
ffffffffc02023d6:	611c                	ld	a5,0(a0)
ffffffffc02023d8:	8bc1                	andi	a5,a5,16
ffffffffc02023da:	78078563          	beqz	a5,ffffffffc0202b64 <pmm_init+0xa06>
ffffffffc02023de:	000c2703          	lw	a4,0(s8) # ff0000 <kern_entry-0xffffffffbf210000>
ffffffffc02023e2:	4785                	li	a5,1
ffffffffc02023e4:	76f71063          	bne	a4,a5,ffffffffc0202b44 <pmm_init+0x9e6>
ffffffffc02023e8:	4681                	li	a3,0
ffffffffc02023ea:	6605                	lui	a2,0x1
ffffffffc02023ec:	85d2                	mv	a1,s4
ffffffffc02023ee:	c7bff0ef          	jal	ra,ffffffffc0202068 <page_insert>
ffffffffc02023f2:	72051963          	bnez	a0,ffffffffc0202b24 <pmm_init+0x9c6>
ffffffffc02023f6:	000a2703          	lw	a4,0(s4)
ffffffffc02023fa:	4789                	li	a5,2
ffffffffc02023fc:	70f71463          	bne	a4,a5,ffffffffc0202b04 <pmm_init+0x9a6>
ffffffffc0202400:	000c2783          	lw	a5,0(s8)
ffffffffc0202404:	6e079063          	bnez	a5,ffffffffc0202ae4 <pmm_init+0x986>
ffffffffc0202408:	00093503          	ld	a0,0(s2)
ffffffffc020240c:	4601                	li	a2,0
ffffffffc020240e:	6585                	lui	a1,0x1
ffffffffc0202410:	941ff0ef          	jal	ra,ffffffffc0201d50 <get_pte>
ffffffffc0202414:	6a050863          	beqz	a0,ffffffffc0202ac4 <pmm_init+0x966>
ffffffffc0202418:	6118                	ld	a4,0(a0)
ffffffffc020241a:	00177793          	andi	a5,a4,1
ffffffffc020241e:	4a078563          	beqz	a5,ffffffffc02028c8 <pmm_init+0x76a>
ffffffffc0202422:	6094                	ld	a3,0(s1)
ffffffffc0202424:	00271793          	slli	a5,a4,0x2
ffffffffc0202428:	83b1                	srli	a5,a5,0xc
ffffffffc020242a:	48d7fd63          	bgeu	a5,a3,ffffffffc02028c4 <pmm_init+0x766>
ffffffffc020242e:	000bb683          	ld	a3,0(s7)
ffffffffc0202432:	fff80ab7          	lui	s5,0xfff80
ffffffffc0202436:	97d6                	add	a5,a5,s5
ffffffffc0202438:	079a                	slli	a5,a5,0x6
ffffffffc020243a:	97b6                	add	a5,a5,a3
ffffffffc020243c:	66fa1463          	bne	s4,a5,ffffffffc0202aa4 <pmm_init+0x946>
ffffffffc0202440:	8b41                	andi	a4,a4,16
ffffffffc0202442:	64071163          	bnez	a4,ffffffffc0202a84 <pmm_init+0x926>
ffffffffc0202446:	00093503          	ld	a0,0(s2)
ffffffffc020244a:	4581                	li	a1,0
ffffffffc020244c:	b81ff0ef          	jal	ra,ffffffffc0201fcc <page_remove>
ffffffffc0202450:	000a2c83          	lw	s9,0(s4)
ffffffffc0202454:	4785                	li	a5,1
ffffffffc0202456:	60fc9763          	bne	s9,a5,ffffffffc0202a64 <pmm_init+0x906>
ffffffffc020245a:	000c2783          	lw	a5,0(s8)
ffffffffc020245e:	5e079363          	bnez	a5,ffffffffc0202a44 <pmm_init+0x8e6>
ffffffffc0202462:	00093503          	ld	a0,0(s2)
ffffffffc0202466:	6585                	lui	a1,0x1
ffffffffc0202468:	b65ff0ef          	jal	ra,ffffffffc0201fcc <page_remove>
ffffffffc020246c:	000a2783          	lw	a5,0(s4)
ffffffffc0202470:	52079a63          	bnez	a5,ffffffffc02029a4 <pmm_init+0x846>
ffffffffc0202474:	000c2783          	lw	a5,0(s8)
ffffffffc0202478:	50079663          	bnez	a5,ffffffffc0202984 <pmm_init+0x826>
ffffffffc020247c:	00093a03          	ld	s4,0(s2)
ffffffffc0202480:	608c                	ld	a1,0(s1)
ffffffffc0202482:	000a3683          	ld	a3,0(s4)
ffffffffc0202486:	068a                	slli	a3,a3,0x2
ffffffffc0202488:	82b1                	srli	a3,a3,0xc
ffffffffc020248a:	42b6fd63          	bgeu	a3,a1,ffffffffc02028c4 <pmm_init+0x766>
ffffffffc020248e:	000bb503          	ld	a0,0(s7)
ffffffffc0202492:	96d6                	add	a3,a3,s5
ffffffffc0202494:	069a                	slli	a3,a3,0x6
ffffffffc0202496:	00d507b3          	add	a5,a0,a3
ffffffffc020249a:	439c                	lw	a5,0(a5)
ffffffffc020249c:	4d979463          	bne	a5,s9,ffffffffc0202964 <pmm_init+0x806>
ffffffffc02024a0:	8699                	srai	a3,a3,0x6
ffffffffc02024a2:	00080637          	lui	a2,0x80
ffffffffc02024a6:	96b2                	add	a3,a3,a2
ffffffffc02024a8:	00c69713          	slli	a4,a3,0xc
ffffffffc02024ac:	8331                	srli	a4,a4,0xc
ffffffffc02024ae:	06b2                	slli	a3,a3,0xc
ffffffffc02024b0:	48b77e63          	bgeu	a4,a1,ffffffffc020294c <pmm_init+0x7ee>
ffffffffc02024b4:	0009b703          	ld	a4,0(s3)
ffffffffc02024b8:	96ba                	add	a3,a3,a4
ffffffffc02024ba:	629c                	ld	a5,0(a3)
ffffffffc02024bc:	078a                	slli	a5,a5,0x2
ffffffffc02024be:	83b1                	srli	a5,a5,0xc
ffffffffc02024c0:	40b7f263          	bgeu	a5,a1,ffffffffc02028c4 <pmm_init+0x766>
ffffffffc02024c4:	8f91                	sub	a5,a5,a2
ffffffffc02024c6:	079a                	slli	a5,a5,0x6
ffffffffc02024c8:	953e                	add	a0,a0,a5
ffffffffc02024ca:	100027f3          	csrr	a5,sstatus
ffffffffc02024ce:	8b89                	andi	a5,a5,2
ffffffffc02024d0:	30079963          	bnez	a5,ffffffffc02027e2 <pmm_init+0x684>
ffffffffc02024d4:	000b3783          	ld	a5,0(s6)
ffffffffc02024d8:	4585                	li	a1,1
ffffffffc02024da:	739c                	ld	a5,32(a5)
ffffffffc02024dc:	9782                	jalr	a5
ffffffffc02024de:	000a3783          	ld	a5,0(s4)
ffffffffc02024e2:	6098                	ld	a4,0(s1)
ffffffffc02024e4:	078a                	slli	a5,a5,0x2
ffffffffc02024e6:	83b1                	srli	a5,a5,0xc
ffffffffc02024e8:	3ce7fe63          	bgeu	a5,a4,ffffffffc02028c4 <pmm_init+0x766>
ffffffffc02024ec:	000bb503          	ld	a0,0(s7)
ffffffffc02024f0:	fff80737          	lui	a4,0xfff80
ffffffffc02024f4:	97ba                	add	a5,a5,a4
ffffffffc02024f6:	079a                	slli	a5,a5,0x6
ffffffffc02024f8:	953e                	add	a0,a0,a5
ffffffffc02024fa:	100027f3          	csrr	a5,sstatus
ffffffffc02024fe:	8b89                	andi	a5,a5,2
ffffffffc0202500:	2c079563          	bnez	a5,ffffffffc02027ca <pmm_init+0x66c>
ffffffffc0202504:	000b3783          	ld	a5,0(s6)
ffffffffc0202508:	4585                	li	a1,1
ffffffffc020250a:	739c                	ld	a5,32(a5)
ffffffffc020250c:	9782                	jalr	a5
ffffffffc020250e:	00093783          	ld	a5,0(s2)
ffffffffc0202512:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdf1b14>
ffffffffc0202516:	12000073          	sfence.vma
ffffffffc020251a:	100027f3          	csrr	a5,sstatus
ffffffffc020251e:	8b89                	andi	a5,a5,2
ffffffffc0202520:	28079b63          	bnez	a5,ffffffffc02027b6 <pmm_init+0x658>
ffffffffc0202524:	000b3783          	ld	a5,0(s6)
ffffffffc0202528:	779c                	ld	a5,40(a5)
ffffffffc020252a:	9782                	jalr	a5
ffffffffc020252c:	8a2a                	mv	s4,a0
ffffffffc020252e:	4b441b63          	bne	s0,s4,ffffffffc02029e4 <pmm_init+0x886>
ffffffffc0202532:	00003517          	auipc	a0,0x3
ffffffffc0202536:	cd650513          	addi	a0,a0,-810 # ffffffffc0205208 <default_pmm_manager+0x518>
ffffffffc020253a:	c5bfd0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc020253e:	100027f3          	csrr	a5,sstatus
ffffffffc0202542:	8b89                	andi	a5,a5,2
ffffffffc0202544:	24079f63          	bnez	a5,ffffffffc02027a2 <pmm_init+0x644>
ffffffffc0202548:	000b3783          	ld	a5,0(s6)
ffffffffc020254c:	779c                	ld	a5,40(a5)
ffffffffc020254e:	9782                	jalr	a5
ffffffffc0202550:	8c2a                	mv	s8,a0
ffffffffc0202552:	6098                	ld	a4,0(s1)
ffffffffc0202554:	c0200437          	lui	s0,0xc0200
ffffffffc0202558:	7afd                	lui	s5,0xfffff
ffffffffc020255a:	00c71793          	slli	a5,a4,0xc
ffffffffc020255e:	6a05                	lui	s4,0x1
ffffffffc0202560:	02f47c63          	bgeu	s0,a5,ffffffffc0202598 <pmm_init+0x43a>
ffffffffc0202564:	00c45793          	srli	a5,s0,0xc
ffffffffc0202568:	00093503          	ld	a0,0(s2)
ffffffffc020256c:	2ee7ff63          	bgeu	a5,a4,ffffffffc020286a <pmm_init+0x70c>
ffffffffc0202570:	0009b583          	ld	a1,0(s3)
ffffffffc0202574:	4601                	li	a2,0
ffffffffc0202576:	95a2                	add	a1,a1,s0
ffffffffc0202578:	fd8ff0ef          	jal	ra,ffffffffc0201d50 <get_pte>
ffffffffc020257c:	32050463          	beqz	a0,ffffffffc02028a4 <pmm_init+0x746>
ffffffffc0202580:	611c                	ld	a5,0(a0)
ffffffffc0202582:	078a                	slli	a5,a5,0x2
ffffffffc0202584:	0157f7b3          	and	a5,a5,s5
ffffffffc0202588:	2e879e63          	bne	a5,s0,ffffffffc0202884 <pmm_init+0x726>
ffffffffc020258c:	6098                	ld	a4,0(s1)
ffffffffc020258e:	9452                	add	s0,s0,s4
ffffffffc0202590:	00c71793          	slli	a5,a4,0xc
ffffffffc0202594:	fcf468e3          	bltu	s0,a5,ffffffffc0202564 <pmm_init+0x406>
ffffffffc0202598:	00093783          	ld	a5,0(s2)
ffffffffc020259c:	639c                	ld	a5,0(a5)
ffffffffc020259e:	42079363          	bnez	a5,ffffffffc02029c4 <pmm_init+0x866>
ffffffffc02025a2:	100027f3          	csrr	a5,sstatus
ffffffffc02025a6:	8b89                	andi	a5,a5,2
ffffffffc02025a8:	24079963          	bnez	a5,ffffffffc02027fa <pmm_init+0x69c>
ffffffffc02025ac:	000b3783          	ld	a5,0(s6)
ffffffffc02025b0:	4505                	li	a0,1
ffffffffc02025b2:	6f9c                	ld	a5,24(a5)
ffffffffc02025b4:	9782                	jalr	a5
ffffffffc02025b6:	8a2a                	mv	s4,a0
ffffffffc02025b8:	00093503          	ld	a0,0(s2)
ffffffffc02025bc:	4699                	li	a3,6
ffffffffc02025be:	10000613          	li	a2,256
ffffffffc02025c2:	85d2                	mv	a1,s4
ffffffffc02025c4:	aa5ff0ef          	jal	ra,ffffffffc0202068 <page_insert>
ffffffffc02025c8:	44051e63          	bnez	a0,ffffffffc0202a24 <pmm_init+0x8c6>
ffffffffc02025cc:	000a2703          	lw	a4,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02025d0:	4785                	li	a5,1
ffffffffc02025d2:	42f71963          	bne	a4,a5,ffffffffc0202a04 <pmm_init+0x8a6>
ffffffffc02025d6:	00093503          	ld	a0,0(s2)
ffffffffc02025da:	6405                	lui	s0,0x1
ffffffffc02025dc:	4699                	li	a3,6
ffffffffc02025de:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc02025e2:	85d2                	mv	a1,s4
ffffffffc02025e4:	a85ff0ef          	jal	ra,ffffffffc0202068 <page_insert>
ffffffffc02025e8:	72051363          	bnez	a0,ffffffffc0202d0e <pmm_init+0xbb0>
ffffffffc02025ec:	000a2703          	lw	a4,0(s4)
ffffffffc02025f0:	4789                	li	a5,2
ffffffffc02025f2:	6ef71e63          	bne	a4,a5,ffffffffc0202cee <pmm_init+0xb90>
ffffffffc02025f6:	00003597          	auipc	a1,0x3
ffffffffc02025fa:	d5a58593          	addi	a1,a1,-678 # ffffffffc0205350 <default_pmm_manager+0x660>
ffffffffc02025fe:	10000513          	li	a0,256
ffffffffc0202602:	003010ef          	jal	ra,ffffffffc0203e04 <strcpy>
ffffffffc0202606:	10040593          	addi	a1,s0,256
ffffffffc020260a:	10000513          	li	a0,256
ffffffffc020260e:	009010ef          	jal	ra,ffffffffc0203e16 <strcmp>
ffffffffc0202612:	6a051e63          	bnez	a0,ffffffffc0202cce <pmm_init+0xb70>
ffffffffc0202616:	000bb683          	ld	a3,0(s7)
ffffffffc020261a:	00080737          	lui	a4,0x80
ffffffffc020261e:	547d                	li	s0,-1
ffffffffc0202620:	40da06b3          	sub	a3,s4,a3
ffffffffc0202624:	8699                	srai	a3,a3,0x6
ffffffffc0202626:	609c                	ld	a5,0(s1)
ffffffffc0202628:	96ba                	add	a3,a3,a4
ffffffffc020262a:	8031                	srli	s0,s0,0xc
ffffffffc020262c:	0086f733          	and	a4,a3,s0
ffffffffc0202630:	06b2                	slli	a3,a3,0xc
ffffffffc0202632:	30f77d63          	bgeu	a4,a5,ffffffffc020294c <pmm_init+0x7ee>
ffffffffc0202636:	0009b783          	ld	a5,0(s3)
ffffffffc020263a:	10000513          	li	a0,256
ffffffffc020263e:	96be                	add	a3,a3,a5
ffffffffc0202640:	10068023          	sb	zero,256(a3)
ffffffffc0202644:	78a010ef          	jal	ra,ffffffffc0203dce <strlen>
ffffffffc0202648:	66051363          	bnez	a0,ffffffffc0202cae <pmm_init+0xb50>
ffffffffc020264c:	00093a83          	ld	s5,0(s2)
ffffffffc0202650:	609c                	ld	a5,0(s1)
ffffffffc0202652:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fdf1b14>
ffffffffc0202656:	068a                	slli	a3,a3,0x2
ffffffffc0202658:	82b1                	srli	a3,a3,0xc
ffffffffc020265a:	26f6f563          	bgeu	a3,a5,ffffffffc02028c4 <pmm_init+0x766>
ffffffffc020265e:	8c75                	and	s0,s0,a3
ffffffffc0202660:	06b2                	slli	a3,a3,0xc
ffffffffc0202662:	2ef47563          	bgeu	s0,a5,ffffffffc020294c <pmm_init+0x7ee>
ffffffffc0202666:	0009b403          	ld	s0,0(s3)
ffffffffc020266a:	9436                	add	s0,s0,a3
ffffffffc020266c:	100027f3          	csrr	a5,sstatus
ffffffffc0202670:	8b89                	andi	a5,a5,2
ffffffffc0202672:	1e079163          	bnez	a5,ffffffffc0202854 <pmm_init+0x6f6>
ffffffffc0202676:	000b3783          	ld	a5,0(s6)
ffffffffc020267a:	4585                	li	a1,1
ffffffffc020267c:	8552                	mv	a0,s4
ffffffffc020267e:	739c                	ld	a5,32(a5)
ffffffffc0202680:	9782                	jalr	a5
ffffffffc0202682:	601c                	ld	a5,0(s0)
ffffffffc0202684:	6098                	ld	a4,0(s1)
ffffffffc0202686:	078a                	slli	a5,a5,0x2
ffffffffc0202688:	83b1                	srli	a5,a5,0xc
ffffffffc020268a:	22e7fd63          	bgeu	a5,a4,ffffffffc02028c4 <pmm_init+0x766>
ffffffffc020268e:	000bb503          	ld	a0,0(s7)
ffffffffc0202692:	fff80737          	lui	a4,0xfff80
ffffffffc0202696:	97ba                	add	a5,a5,a4
ffffffffc0202698:	079a                	slli	a5,a5,0x6
ffffffffc020269a:	953e                	add	a0,a0,a5
ffffffffc020269c:	100027f3          	csrr	a5,sstatus
ffffffffc02026a0:	8b89                	andi	a5,a5,2
ffffffffc02026a2:	18079d63          	bnez	a5,ffffffffc020283c <pmm_init+0x6de>
ffffffffc02026a6:	000b3783          	ld	a5,0(s6)
ffffffffc02026aa:	4585                	li	a1,1
ffffffffc02026ac:	739c                	ld	a5,32(a5)
ffffffffc02026ae:	9782                	jalr	a5
ffffffffc02026b0:	000ab783          	ld	a5,0(s5)
ffffffffc02026b4:	6098                	ld	a4,0(s1)
ffffffffc02026b6:	078a                	slli	a5,a5,0x2
ffffffffc02026b8:	83b1                	srli	a5,a5,0xc
ffffffffc02026ba:	20e7f563          	bgeu	a5,a4,ffffffffc02028c4 <pmm_init+0x766>
ffffffffc02026be:	000bb503          	ld	a0,0(s7)
ffffffffc02026c2:	fff80737          	lui	a4,0xfff80
ffffffffc02026c6:	97ba                	add	a5,a5,a4
ffffffffc02026c8:	079a                	slli	a5,a5,0x6
ffffffffc02026ca:	953e                	add	a0,a0,a5
ffffffffc02026cc:	100027f3          	csrr	a5,sstatus
ffffffffc02026d0:	8b89                	andi	a5,a5,2
ffffffffc02026d2:	14079963          	bnez	a5,ffffffffc0202824 <pmm_init+0x6c6>
ffffffffc02026d6:	000b3783          	ld	a5,0(s6)
ffffffffc02026da:	4585                	li	a1,1
ffffffffc02026dc:	739c                	ld	a5,32(a5)
ffffffffc02026de:	9782                	jalr	a5
ffffffffc02026e0:	00093783          	ld	a5,0(s2)
ffffffffc02026e4:	0007b023          	sd	zero,0(a5)
ffffffffc02026e8:	12000073          	sfence.vma
ffffffffc02026ec:	100027f3          	csrr	a5,sstatus
ffffffffc02026f0:	8b89                	andi	a5,a5,2
ffffffffc02026f2:	10079f63          	bnez	a5,ffffffffc0202810 <pmm_init+0x6b2>
ffffffffc02026f6:	000b3783          	ld	a5,0(s6)
ffffffffc02026fa:	779c                	ld	a5,40(a5)
ffffffffc02026fc:	9782                	jalr	a5
ffffffffc02026fe:	842a                	mv	s0,a0
ffffffffc0202700:	4c8c1e63          	bne	s8,s0,ffffffffc0202bdc <pmm_init+0xa7e>
ffffffffc0202704:	00003517          	auipc	a0,0x3
ffffffffc0202708:	cc450513          	addi	a0,a0,-828 # ffffffffc02053c8 <default_pmm_manager+0x6d8>
ffffffffc020270c:	a89fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0202710:	7406                	ld	s0,96(sp)
ffffffffc0202712:	70a6                	ld	ra,104(sp)
ffffffffc0202714:	64e6                	ld	s1,88(sp)
ffffffffc0202716:	6946                	ld	s2,80(sp)
ffffffffc0202718:	69a6                	ld	s3,72(sp)
ffffffffc020271a:	6a06                	ld	s4,64(sp)
ffffffffc020271c:	7ae2                	ld	s5,56(sp)
ffffffffc020271e:	7b42                	ld	s6,48(sp)
ffffffffc0202720:	7ba2                	ld	s7,40(sp)
ffffffffc0202722:	7c02                	ld	s8,32(sp)
ffffffffc0202724:	6ce2                	ld	s9,24(sp)
ffffffffc0202726:	6165                	addi	sp,sp,112
ffffffffc0202728:	b72ff06f          	j	ffffffffc0201a9a <kmalloc_init>
ffffffffc020272c:	c80007b7          	lui	a5,0xc8000
ffffffffc0202730:	bc7d                	j	ffffffffc02021ee <pmm_init+0x90>
ffffffffc0202732:	9fefe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc0202736:	000b3783          	ld	a5,0(s6)
ffffffffc020273a:	4505                	li	a0,1
ffffffffc020273c:	6f9c                	ld	a5,24(a5)
ffffffffc020273e:	9782                	jalr	a5
ffffffffc0202740:	8c2a                	mv	s8,a0
ffffffffc0202742:	9e8fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0202746:	b9a9                	j	ffffffffc02023a0 <pmm_init+0x242>
ffffffffc0202748:	9e8fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc020274c:	000b3783          	ld	a5,0(s6)
ffffffffc0202750:	4505                	li	a0,1
ffffffffc0202752:	6f9c                	ld	a5,24(a5)
ffffffffc0202754:	9782                	jalr	a5
ffffffffc0202756:	8a2a                	mv	s4,a0
ffffffffc0202758:	9d2fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc020275c:	b645                	j	ffffffffc02022fc <pmm_init+0x19e>
ffffffffc020275e:	9d2fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc0202762:	000b3783          	ld	a5,0(s6)
ffffffffc0202766:	779c                	ld	a5,40(a5)
ffffffffc0202768:	9782                	jalr	a5
ffffffffc020276a:	842a                	mv	s0,a0
ffffffffc020276c:	9befe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0202770:	b6b9                	j	ffffffffc02022be <pmm_init+0x160>
ffffffffc0202772:	6705                	lui	a4,0x1
ffffffffc0202774:	177d                	addi	a4,a4,-1
ffffffffc0202776:	96ba                	add	a3,a3,a4
ffffffffc0202778:	8ff5                	and	a5,a5,a3
ffffffffc020277a:	00c7d713          	srli	a4,a5,0xc
ffffffffc020277e:	14a77363          	bgeu	a4,a0,ffffffffc02028c4 <pmm_init+0x766>
ffffffffc0202782:	000b3683          	ld	a3,0(s6)
ffffffffc0202786:	fff80537          	lui	a0,0xfff80
ffffffffc020278a:	972a                	add	a4,a4,a0
ffffffffc020278c:	6a94                	ld	a3,16(a3)
ffffffffc020278e:	8c1d                	sub	s0,s0,a5
ffffffffc0202790:	00671513          	slli	a0,a4,0x6
ffffffffc0202794:	00c45593          	srli	a1,s0,0xc
ffffffffc0202798:	9532                	add	a0,a0,a2
ffffffffc020279a:	9682                	jalr	a3
ffffffffc020279c:	0009b583          	ld	a1,0(s3)
ffffffffc02027a0:	b4c1                	j	ffffffffc0202260 <pmm_init+0x102>
ffffffffc02027a2:	98efe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc02027a6:	000b3783          	ld	a5,0(s6)
ffffffffc02027aa:	779c                	ld	a5,40(a5)
ffffffffc02027ac:	9782                	jalr	a5
ffffffffc02027ae:	8c2a                	mv	s8,a0
ffffffffc02027b0:	97afe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc02027b4:	bb79                	j	ffffffffc0202552 <pmm_init+0x3f4>
ffffffffc02027b6:	97afe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc02027ba:	000b3783          	ld	a5,0(s6)
ffffffffc02027be:	779c                	ld	a5,40(a5)
ffffffffc02027c0:	9782                	jalr	a5
ffffffffc02027c2:	8a2a                	mv	s4,a0
ffffffffc02027c4:	966fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc02027c8:	b39d                	j	ffffffffc020252e <pmm_init+0x3d0>
ffffffffc02027ca:	e42a                	sd	a0,8(sp)
ffffffffc02027cc:	964fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc02027d0:	000b3783          	ld	a5,0(s6)
ffffffffc02027d4:	6522                	ld	a0,8(sp)
ffffffffc02027d6:	4585                	li	a1,1
ffffffffc02027d8:	739c                	ld	a5,32(a5)
ffffffffc02027da:	9782                	jalr	a5
ffffffffc02027dc:	94efe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc02027e0:	b33d                	j	ffffffffc020250e <pmm_init+0x3b0>
ffffffffc02027e2:	e42a                	sd	a0,8(sp)
ffffffffc02027e4:	94cfe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc02027e8:	000b3783          	ld	a5,0(s6)
ffffffffc02027ec:	6522                	ld	a0,8(sp)
ffffffffc02027ee:	4585                	li	a1,1
ffffffffc02027f0:	739c                	ld	a5,32(a5)
ffffffffc02027f2:	9782                	jalr	a5
ffffffffc02027f4:	936fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc02027f8:	b1dd                	j	ffffffffc02024de <pmm_init+0x380>
ffffffffc02027fa:	936fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc02027fe:	000b3783          	ld	a5,0(s6)
ffffffffc0202802:	4505                	li	a0,1
ffffffffc0202804:	6f9c                	ld	a5,24(a5)
ffffffffc0202806:	9782                	jalr	a5
ffffffffc0202808:	8a2a                	mv	s4,a0
ffffffffc020280a:	920fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc020280e:	b36d                	j	ffffffffc02025b8 <pmm_init+0x45a>
ffffffffc0202810:	920fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc0202814:	000b3783          	ld	a5,0(s6)
ffffffffc0202818:	779c                	ld	a5,40(a5)
ffffffffc020281a:	9782                	jalr	a5
ffffffffc020281c:	842a                	mv	s0,a0
ffffffffc020281e:	90cfe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0202822:	bdf9                	j	ffffffffc0202700 <pmm_init+0x5a2>
ffffffffc0202824:	e42a                	sd	a0,8(sp)
ffffffffc0202826:	90afe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc020282a:	000b3783          	ld	a5,0(s6)
ffffffffc020282e:	6522                	ld	a0,8(sp)
ffffffffc0202830:	4585                	li	a1,1
ffffffffc0202832:	739c                	ld	a5,32(a5)
ffffffffc0202834:	9782                	jalr	a5
ffffffffc0202836:	8f4fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc020283a:	b55d                	j	ffffffffc02026e0 <pmm_init+0x582>
ffffffffc020283c:	e42a                	sd	a0,8(sp)
ffffffffc020283e:	8f2fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc0202842:	000b3783          	ld	a5,0(s6)
ffffffffc0202846:	6522                	ld	a0,8(sp)
ffffffffc0202848:	4585                	li	a1,1
ffffffffc020284a:	739c                	ld	a5,32(a5)
ffffffffc020284c:	9782                	jalr	a5
ffffffffc020284e:	8dcfe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0202852:	bdb9                	j	ffffffffc02026b0 <pmm_init+0x552>
ffffffffc0202854:	8dcfe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc0202858:	000b3783          	ld	a5,0(s6)
ffffffffc020285c:	4585                	li	a1,1
ffffffffc020285e:	8552                	mv	a0,s4
ffffffffc0202860:	739c                	ld	a5,32(a5)
ffffffffc0202862:	9782                	jalr	a5
ffffffffc0202864:	8c6fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0202868:	bd29                	j	ffffffffc0202682 <pmm_init+0x524>
ffffffffc020286a:	86a2                	mv	a3,s0
ffffffffc020286c:	00002617          	auipc	a2,0x2
ffffffffc0202870:	4bc60613          	addi	a2,a2,1212 # ffffffffc0204d28 <default_pmm_manager+0x38>
ffffffffc0202874:	1aa00593          	li	a1,426
ffffffffc0202878:	00002517          	auipc	a0,0x2
ffffffffc020287c:	5c850513          	addi	a0,a0,1480 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202880:	bdbfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202884:	00003697          	auipc	a3,0x3
ffffffffc0202888:	9e468693          	addi	a3,a3,-1564 # ffffffffc0205268 <default_pmm_manager+0x578>
ffffffffc020288c:	00002617          	auipc	a2,0x2
ffffffffc0202890:	0ac60613          	addi	a2,a2,172 # ffffffffc0204938 <commands+0x810>
ffffffffc0202894:	1ab00593          	li	a1,427
ffffffffc0202898:	00002517          	auipc	a0,0x2
ffffffffc020289c:	5a850513          	addi	a0,a0,1448 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc02028a0:	bbbfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02028a4:	00003697          	auipc	a3,0x3
ffffffffc02028a8:	98468693          	addi	a3,a3,-1660 # ffffffffc0205228 <default_pmm_manager+0x538>
ffffffffc02028ac:	00002617          	auipc	a2,0x2
ffffffffc02028b0:	08c60613          	addi	a2,a2,140 # ffffffffc0204938 <commands+0x810>
ffffffffc02028b4:	1aa00593          	li	a1,426
ffffffffc02028b8:	00002517          	auipc	a0,0x2
ffffffffc02028bc:	58850513          	addi	a0,a0,1416 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc02028c0:	b9bfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02028c4:	b9cff0ef          	jal	ra,ffffffffc0201c60 <pa2page.part.0>
ffffffffc02028c8:	bb4ff0ef          	jal	ra,ffffffffc0201c7c <pte2page.part.0>
ffffffffc02028cc:	00002697          	auipc	a3,0x2
ffffffffc02028d0:	75468693          	addi	a3,a3,1876 # ffffffffc0205020 <default_pmm_manager+0x330>
ffffffffc02028d4:	00002617          	auipc	a2,0x2
ffffffffc02028d8:	06460613          	addi	a2,a2,100 # ffffffffc0204938 <commands+0x810>
ffffffffc02028dc:	17a00593          	li	a1,378
ffffffffc02028e0:	00002517          	auipc	a0,0x2
ffffffffc02028e4:	56050513          	addi	a0,a0,1376 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc02028e8:	b73fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02028ec:	00002697          	auipc	a3,0x2
ffffffffc02028f0:	67468693          	addi	a3,a3,1652 # ffffffffc0204f60 <default_pmm_manager+0x270>
ffffffffc02028f4:	00002617          	auipc	a2,0x2
ffffffffc02028f8:	04460613          	addi	a2,a2,68 # ffffffffc0204938 <commands+0x810>
ffffffffc02028fc:	16b00593          	li	a1,363
ffffffffc0202900:	00002517          	auipc	a0,0x2
ffffffffc0202904:	54050513          	addi	a0,a0,1344 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202908:	b53fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc020290c:	00002697          	auipc	a3,0x2
ffffffffc0202910:	61468693          	addi	a3,a3,1556 # ffffffffc0204f20 <default_pmm_manager+0x230>
ffffffffc0202914:	00002617          	auipc	a2,0x2
ffffffffc0202918:	02460613          	addi	a2,a2,36 # ffffffffc0204938 <commands+0x810>
ffffffffc020291c:	16a00593          	li	a1,362
ffffffffc0202920:	00002517          	auipc	a0,0x2
ffffffffc0202924:	52050513          	addi	a0,a0,1312 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202928:	b33fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc020292c:	00002697          	auipc	a3,0x2
ffffffffc0202930:	5d468693          	addi	a3,a3,1492 # ffffffffc0204f00 <default_pmm_manager+0x210>
ffffffffc0202934:	00002617          	auipc	a2,0x2
ffffffffc0202938:	00460613          	addi	a2,a2,4 # ffffffffc0204938 <commands+0x810>
ffffffffc020293c:	16900593          	li	a1,361
ffffffffc0202940:	00002517          	auipc	a0,0x2
ffffffffc0202944:	50050513          	addi	a0,a0,1280 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202948:	b13fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc020294c:	00002617          	auipc	a2,0x2
ffffffffc0202950:	3dc60613          	addi	a2,a2,988 # ffffffffc0204d28 <default_pmm_manager+0x38>
ffffffffc0202954:	07100593          	li	a1,113
ffffffffc0202958:	00002517          	auipc	a0,0x2
ffffffffc020295c:	3f850513          	addi	a0,a0,1016 # ffffffffc0204d50 <default_pmm_manager+0x60>
ffffffffc0202960:	afbfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202964:	00003697          	auipc	a3,0x3
ffffffffc0202968:	84c68693          	addi	a3,a3,-1972 # ffffffffc02051b0 <default_pmm_manager+0x4c0>
ffffffffc020296c:	00002617          	auipc	a2,0x2
ffffffffc0202970:	fcc60613          	addi	a2,a2,-52 # ffffffffc0204938 <commands+0x810>
ffffffffc0202974:	19300593          	li	a1,403
ffffffffc0202978:	00002517          	auipc	a0,0x2
ffffffffc020297c:	4c850513          	addi	a0,a0,1224 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202980:	adbfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202984:	00002697          	auipc	a3,0x2
ffffffffc0202988:	7e468693          	addi	a3,a3,2020 # ffffffffc0205168 <default_pmm_manager+0x478>
ffffffffc020298c:	00002617          	auipc	a2,0x2
ffffffffc0202990:	fac60613          	addi	a2,a2,-84 # ffffffffc0204938 <commands+0x810>
ffffffffc0202994:	19100593          	li	a1,401
ffffffffc0202998:	00002517          	auipc	a0,0x2
ffffffffc020299c:	4a850513          	addi	a0,a0,1192 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc02029a0:	abbfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02029a4:	00002697          	auipc	a3,0x2
ffffffffc02029a8:	7f468693          	addi	a3,a3,2036 # ffffffffc0205198 <default_pmm_manager+0x4a8>
ffffffffc02029ac:	00002617          	auipc	a2,0x2
ffffffffc02029b0:	f8c60613          	addi	a2,a2,-116 # ffffffffc0204938 <commands+0x810>
ffffffffc02029b4:	19000593          	li	a1,400
ffffffffc02029b8:	00002517          	auipc	a0,0x2
ffffffffc02029bc:	48850513          	addi	a0,a0,1160 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc02029c0:	a9bfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02029c4:	00003697          	auipc	a3,0x3
ffffffffc02029c8:	8bc68693          	addi	a3,a3,-1860 # ffffffffc0205280 <default_pmm_manager+0x590>
ffffffffc02029cc:	00002617          	auipc	a2,0x2
ffffffffc02029d0:	f6c60613          	addi	a2,a2,-148 # ffffffffc0204938 <commands+0x810>
ffffffffc02029d4:	1ae00593          	li	a1,430
ffffffffc02029d8:	00002517          	auipc	a0,0x2
ffffffffc02029dc:	46850513          	addi	a0,a0,1128 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc02029e0:	a7bfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02029e4:	00002697          	auipc	a3,0x2
ffffffffc02029e8:	7fc68693          	addi	a3,a3,2044 # ffffffffc02051e0 <default_pmm_manager+0x4f0>
ffffffffc02029ec:	00002617          	auipc	a2,0x2
ffffffffc02029f0:	f4c60613          	addi	a2,a2,-180 # ffffffffc0204938 <commands+0x810>
ffffffffc02029f4:	19b00593          	li	a1,411
ffffffffc02029f8:	00002517          	auipc	a0,0x2
ffffffffc02029fc:	44850513          	addi	a0,a0,1096 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202a00:	a5bfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202a04:	00003697          	auipc	a3,0x3
ffffffffc0202a08:	8d468693          	addi	a3,a3,-1836 # ffffffffc02052d8 <default_pmm_manager+0x5e8>
ffffffffc0202a0c:	00002617          	auipc	a2,0x2
ffffffffc0202a10:	f2c60613          	addi	a2,a2,-212 # ffffffffc0204938 <commands+0x810>
ffffffffc0202a14:	1b300593          	li	a1,435
ffffffffc0202a18:	00002517          	auipc	a0,0x2
ffffffffc0202a1c:	42850513          	addi	a0,a0,1064 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202a20:	a3bfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202a24:	00003697          	auipc	a3,0x3
ffffffffc0202a28:	87468693          	addi	a3,a3,-1932 # ffffffffc0205298 <default_pmm_manager+0x5a8>
ffffffffc0202a2c:	00002617          	auipc	a2,0x2
ffffffffc0202a30:	f0c60613          	addi	a2,a2,-244 # ffffffffc0204938 <commands+0x810>
ffffffffc0202a34:	1b200593          	li	a1,434
ffffffffc0202a38:	00002517          	auipc	a0,0x2
ffffffffc0202a3c:	40850513          	addi	a0,a0,1032 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202a40:	a1bfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202a44:	00002697          	auipc	a3,0x2
ffffffffc0202a48:	72468693          	addi	a3,a3,1828 # ffffffffc0205168 <default_pmm_manager+0x478>
ffffffffc0202a4c:	00002617          	auipc	a2,0x2
ffffffffc0202a50:	eec60613          	addi	a2,a2,-276 # ffffffffc0204938 <commands+0x810>
ffffffffc0202a54:	18d00593          	li	a1,397
ffffffffc0202a58:	00002517          	auipc	a0,0x2
ffffffffc0202a5c:	3e850513          	addi	a0,a0,1000 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202a60:	9fbfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202a64:	00002697          	auipc	a3,0x2
ffffffffc0202a68:	5a468693          	addi	a3,a3,1444 # ffffffffc0205008 <default_pmm_manager+0x318>
ffffffffc0202a6c:	00002617          	auipc	a2,0x2
ffffffffc0202a70:	ecc60613          	addi	a2,a2,-308 # ffffffffc0204938 <commands+0x810>
ffffffffc0202a74:	18c00593          	li	a1,396
ffffffffc0202a78:	00002517          	auipc	a0,0x2
ffffffffc0202a7c:	3c850513          	addi	a0,a0,968 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202a80:	9dbfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202a84:	00002697          	auipc	a3,0x2
ffffffffc0202a88:	6fc68693          	addi	a3,a3,1788 # ffffffffc0205180 <default_pmm_manager+0x490>
ffffffffc0202a8c:	00002617          	auipc	a2,0x2
ffffffffc0202a90:	eac60613          	addi	a2,a2,-340 # ffffffffc0204938 <commands+0x810>
ffffffffc0202a94:	18900593          	li	a1,393
ffffffffc0202a98:	00002517          	auipc	a0,0x2
ffffffffc0202a9c:	3a850513          	addi	a0,a0,936 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202aa0:	9bbfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202aa4:	00002697          	auipc	a3,0x2
ffffffffc0202aa8:	54c68693          	addi	a3,a3,1356 # ffffffffc0204ff0 <default_pmm_manager+0x300>
ffffffffc0202aac:	00002617          	auipc	a2,0x2
ffffffffc0202ab0:	e8c60613          	addi	a2,a2,-372 # ffffffffc0204938 <commands+0x810>
ffffffffc0202ab4:	18800593          	li	a1,392
ffffffffc0202ab8:	00002517          	auipc	a0,0x2
ffffffffc0202abc:	38850513          	addi	a0,a0,904 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202ac0:	99bfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202ac4:	00002697          	auipc	a3,0x2
ffffffffc0202ac8:	5cc68693          	addi	a3,a3,1484 # ffffffffc0205090 <default_pmm_manager+0x3a0>
ffffffffc0202acc:	00002617          	auipc	a2,0x2
ffffffffc0202ad0:	e6c60613          	addi	a2,a2,-404 # ffffffffc0204938 <commands+0x810>
ffffffffc0202ad4:	18700593          	li	a1,391
ffffffffc0202ad8:	00002517          	auipc	a0,0x2
ffffffffc0202adc:	36850513          	addi	a0,a0,872 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202ae0:	97bfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202ae4:	00002697          	auipc	a3,0x2
ffffffffc0202ae8:	68468693          	addi	a3,a3,1668 # ffffffffc0205168 <default_pmm_manager+0x478>
ffffffffc0202aec:	00002617          	auipc	a2,0x2
ffffffffc0202af0:	e4c60613          	addi	a2,a2,-436 # ffffffffc0204938 <commands+0x810>
ffffffffc0202af4:	18600593          	li	a1,390
ffffffffc0202af8:	00002517          	auipc	a0,0x2
ffffffffc0202afc:	34850513          	addi	a0,a0,840 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202b00:	95bfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202b04:	00002697          	auipc	a3,0x2
ffffffffc0202b08:	64c68693          	addi	a3,a3,1612 # ffffffffc0205150 <default_pmm_manager+0x460>
ffffffffc0202b0c:	00002617          	auipc	a2,0x2
ffffffffc0202b10:	e2c60613          	addi	a2,a2,-468 # ffffffffc0204938 <commands+0x810>
ffffffffc0202b14:	18500593          	li	a1,389
ffffffffc0202b18:	00002517          	auipc	a0,0x2
ffffffffc0202b1c:	32850513          	addi	a0,a0,808 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202b20:	93bfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202b24:	00002697          	auipc	a3,0x2
ffffffffc0202b28:	5fc68693          	addi	a3,a3,1532 # ffffffffc0205120 <default_pmm_manager+0x430>
ffffffffc0202b2c:	00002617          	auipc	a2,0x2
ffffffffc0202b30:	e0c60613          	addi	a2,a2,-500 # ffffffffc0204938 <commands+0x810>
ffffffffc0202b34:	18400593          	li	a1,388
ffffffffc0202b38:	00002517          	auipc	a0,0x2
ffffffffc0202b3c:	30850513          	addi	a0,a0,776 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202b40:	91bfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202b44:	00002697          	auipc	a3,0x2
ffffffffc0202b48:	5c468693          	addi	a3,a3,1476 # ffffffffc0205108 <default_pmm_manager+0x418>
ffffffffc0202b4c:	00002617          	auipc	a2,0x2
ffffffffc0202b50:	dec60613          	addi	a2,a2,-532 # ffffffffc0204938 <commands+0x810>
ffffffffc0202b54:	18200593          	li	a1,386
ffffffffc0202b58:	00002517          	auipc	a0,0x2
ffffffffc0202b5c:	2e850513          	addi	a0,a0,744 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202b60:	8fbfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202b64:	00002697          	auipc	a3,0x2
ffffffffc0202b68:	58468693          	addi	a3,a3,1412 # ffffffffc02050e8 <default_pmm_manager+0x3f8>
ffffffffc0202b6c:	00002617          	auipc	a2,0x2
ffffffffc0202b70:	dcc60613          	addi	a2,a2,-564 # ffffffffc0204938 <commands+0x810>
ffffffffc0202b74:	18100593          	li	a1,385
ffffffffc0202b78:	00002517          	auipc	a0,0x2
ffffffffc0202b7c:	2c850513          	addi	a0,a0,712 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202b80:	8dbfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202b84:	00002697          	auipc	a3,0x2
ffffffffc0202b88:	55468693          	addi	a3,a3,1364 # ffffffffc02050d8 <default_pmm_manager+0x3e8>
ffffffffc0202b8c:	00002617          	auipc	a2,0x2
ffffffffc0202b90:	dac60613          	addi	a2,a2,-596 # ffffffffc0204938 <commands+0x810>
ffffffffc0202b94:	18000593          	li	a1,384
ffffffffc0202b98:	00002517          	auipc	a0,0x2
ffffffffc0202b9c:	2a850513          	addi	a0,a0,680 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202ba0:	8bbfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202ba4:	00002697          	auipc	a3,0x2
ffffffffc0202ba8:	52468693          	addi	a3,a3,1316 # ffffffffc02050c8 <default_pmm_manager+0x3d8>
ffffffffc0202bac:	00002617          	auipc	a2,0x2
ffffffffc0202bb0:	d8c60613          	addi	a2,a2,-628 # ffffffffc0204938 <commands+0x810>
ffffffffc0202bb4:	17f00593          	li	a1,383
ffffffffc0202bb8:	00002517          	auipc	a0,0x2
ffffffffc0202bbc:	28850513          	addi	a0,a0,648 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202bc0:	89bfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202bc4:	00002617          	auipc	a2,0x2
ffffffffc0202bc8:	2a460613          	addi	a2,a2,676 # ffffffffc0204e68 <default_pmm_manager+0x178>
ffffffffc0202bcc:	06400593          	li	a1,100
ffffffffc0202bd0:	00002517          	auipc	a0,0x2
ffffffffc0202bd4:	27050513          	addi	a0,a0,624 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202bd8:	883fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202bdc:	00002697          	auipc	a3,0x2
ffffffffc0202be0:	60468693          	addi	a3,a3,1540 # ffffffffc02051e0 <default_pmm_manager+0x4f0>
ffffffffc0202be4:	00002617          	auipc	a2,0x2
ffffffffc0202be8:	d5460613          	addi	a2,a2,-684 # ffffffffc0204938 <commands+0x810>
ffffffffc0202bec:	1c500593          	li	a1,453
ffffffffc0202bf0:	00002517          	auipc	a0,0x2
ffffffffc0202bf4:	25050513          	addi	a0,a0,592 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202bf8:	863fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202bfc:	00002697          	auipc	a3,0x2
ffffffffc0202c00:	49468693          	addi	a3,a3,1172 # ffffffffc0205090 <default_pmm_manager+0x3a0>
ffffffffc0202c04:	00002617          	auipc	a2,0x2
ffffffffc0202c08:	d3460613          	addi	a2,a2,-716 # ffffffffc0204938 <commands+0x810>
ffffffffc0202c0c:	17e00593          	li	a1,382
ffffffffc0202c10:	00002517          	auipc	a0,0x2
ffffffffc0202c14:	23050513          	addi	a0,a0,560 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202c18:	843fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202c1c:	00002697          	auipc	a3,0x2
ffffffffc0202c20:	43468693          	addi	a3,a3,1076 # ffffffffc0205050 <default_pmm_manager+0x360>
ffffffffc0202c24:	00002617          	auipc	a2,0x2
ffffffffc0202c28:	d1460613          	addi	a2,a2,-748 # ffffffffc0204938 <commands+0x810>
ffffffffc0202c2c:	17d00593          	li	a1,381
ffffffffc0202c30:	00002517          	auipc	a0,0x2
ffffffffc0202c34:	21050513          	addi	a0,a0,528 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202c38:	823fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202c3c:	86d6                	mv	a3,s5
ffffffffc0202c3e:	00002617          	auipc	a2,0x2
ffffffffc0202c42:	0ea60613          	addi	a2,a2,234 # ffffffffc0204d28 <default_pmm_manager+0x38>
ffffffffc0202c46:	17900593          	li	a1,377
ffffffffc0202c4a:	00002517          	auipc	a0,0x2
ffffffffc0202c4e:	1f650513          	addi	a0,a0,502 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202c52:	809fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202c56:	00002617          	auipc	a2,0x2
ffffffffc0202c5a:	0d260613          	addi	a2,a2,210 # ffffffffc0204d28 <default_pmm_manager+0x38>
ffffffffc0202c5e:	17800593          	li	a1,376
ffffffffc0202c62:	00002517          	auipc	a0,0x2
ffffffffc0202c66:	1de50513          	addi	a0,a0,478 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202c6a:	ff0fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202c6e:	00002697          	auipc	a3,0x2
ffffffffc0202c72:	39a68693          	addi	a3,a3,922 # ffffffffc0205008 <default_pmm_manager+0x318>
ffffffffc0202c76:	00002617          	auipc	a2,0x2
ffffffffc0202c7a:	cc260613          	addi	a2,a2,-830 # ffffffffc0204938 <commands+0x810>
ffffffffc0202c7e:	17500593          	li	a1,373
ffffffffc0202c82:	00002517          	auipc	a0,0x2
ffffffffc0202c86:	1be50513          	addi	a0,a0,446 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202c8a:	fd0fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202c8e:	00002697          	auipc	a3,0x2
ffffffffc0202c92:	36268693          	addi	a3,a3,866 # ffffffffc0204ff0 <default_pmm_manager+0x300>
ffffffffc0202c96:	00002617          	auipc	a2,0x2
ffffffffc0202c9a:	ca260613          	addi	a2,a2,-862 # ffffffffc0204938 <commands+0x810>
ffffffffc0202c9e:	17400593          	li	a1,372
ffffffffc0202ca2:	00002517          	auipc	a0,0x2
ffffffffc0202ca6:	19e50513          	addi	a0,a0,414 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202caa:	fb0fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202cae:	00002697          	auipc	a3,0x2
ffffffffc0202cb2:	6f268693          	addi	a3,a3,1778 # ffffffffc02053a0 <default_pmm_manager+0x6b0>
ffffffffc0202cb6:	00002617          	auipc	a2,0x2
ffffffffc0202cba:	c8260613          	addi	a2,a2,-894 # ffffffffc0204938 <commands+0x810>
ffffffffc0202cbe:	1bc00593          	li	a1,444
ffffffffc0202cc2:	00002517          	auipc	a0,0x2
ffffffffc0202cc6:	17e50513          	addi	a0,a0,382 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202cca:	f90fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202cce:	00002697          	auipc	a3,0x2
ffffffffc0202cd2:	69a68693          	addi	a3,a3,1690 # ffffffffc0205368 <default_pmm_manager+0x678>
ffffffffc0202cd6:	00002617          	auipc	a2,0x2
ffffffffc0202cda:	c6260613          	addi	a2,a2,-926 # ffffffffc0204938 <commands+0x810>
ffffffffc0202cde:	1b900593          	li	a1,441
ffffffffc0202ce2:	00002517          	auipc	a0,0x2
ffffffffc0202ce6:	15e50513          	addi	a0,a0,350 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202cea:	f70fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202cee:	00002697          	auipc	a3,0x2
ffffffffc0202cf2:	64a68693          	addi	a3,a3,1610 # ffffffffc0205338 <default_pmm_manager+0x648>
ffffffffc0202cf6:	00002617          	auipc	a2,0x2
ffffffffc0202cfa:	c4260613          	addi	a2,a2,-958 # ffffffffc0204938 <commands+0x810>
ffffffffc0202cfe:	1b500593          	li	a1,437
ffffffffc0202d02:	00002517          	auipc	a0,0x2
ffffffffc0202d06:	13e50513          	addi	a0,a0,318 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202d0a:	f50fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202d0e:	00002697          	auipc	a3,0x2
ffffffffc0202d12:	5e268693          	addi	a3,a3,1506 # ffffffffc02052f0 <default_pmm_manager+0x600>
ffffffffc0202d16:	00002617          	auipc	a2,0x2
ffffffffc0202d1a:	c2260613          	addi	a2,a2,-990 # ffffffffc0204938 <commands+0x810>
ffffffffc0202d1e:	1b400593          	li	a1,436
ffffffffc0202d22:	00002517          	auipc	a0,0x2
ffffffffc0202d26:	11e50513          	addi	a0,a0,286 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202d2a:	f30fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202d2e:	00002617          	auipc	a2,0x2
ffffffffc0202d32:	0a260613          	addi	a2,a2,162 # ffffffffc0204dd0 <default_pmm_manager+0xe0>
ffffffffc0202d36:	0cb00593          	li	a1,203
ffffffffc0202d3a:	00002517          	auipc	a0,0x2
ffffffffc0202d3e:	10650513          	addi	a0,a0,262 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202d42:	f18fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202d46:	00002617          	auipc	a2,0x2
ffffffffc0202d4a:	08a60613          	addi	a2,a2,138 # ffffffffc0204dd0 <default_pmm_manager+0xe0>
ffffffffc0202d4e:	08000593          	li	a1,128
ffffffffc0202d52:	00002517          	auipc	a0,0x2
ffffffffc0202d56:	0ee50513          	addi	a0,a0,238 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202d5a:	f00fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202d5e:	00002697          	auipc	a3,0x2
ffffffffc0202d62:	26268693          	addi	a3,a3,610 # ffffffffc0204fc0 <default_pmm_manager+0x2d0>
ffffffffc0202d66:	00002617          	auipc	a2,0x2
ffffffffc0202d6a:	bd260613          	addi	a2,a2,-1070 # ffffffffc0204938 <commands+0x810>
ffffffffc0202d6e:	17300593          	li	a1,371
ffffffffc0202d72:	00002517          	auipc	a0,0x2
ffffffffc0202d76:	0ce50513          	addi	a0,a0,206 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202d7a:	ee0fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202d7e:	00002697          	auipc	a3,0x2
ffffffffc0202d82:	21268693          	addi	a3,a3,530 # ffffffffc0204f90 <default_pmm_manager+0x2a0>
ffffffffc0202d86:	00002617          	auipc	a2,0x2
ffffffffc0202d8a:	bb260613          	addi	a2,a2,-1102 # ffffffffc0204938 <commands+0x810>
ffffffffc0202d8e:	17000593          	li	a1,368
ffffffffc0202d92:	00002517          	auipc	a0,0x2
ffffffffc0202d96:	0ae50513          	addi	a0,a0,174 # ffffffffc0204e40 <default_pmm_manager+0x150>
ffffffffc0202d9a:	ec0fd0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0202d9e <check_vma_overlap.part.0>:
ffffffffc0202d9e:	1141                	addi	sp,sp,-16
ffffffffc0202da0:	00002697          	auipc	a3,0x2
ffffffffc0202da4:	64868693          	addi	a3,a3,1608 # ffffffffc02053e8 <default_pmm_manager+0x6f8>
ffffffffc0202da8:	00002617          	auipc	a2,0x2
ffffffffc0202dac:	b9060613          	addi	a2,a2,-1136 # ffffffffc0204938 <commands+0x810>
ffffffffc0202db0:	08800593          	li	a1,136
ffffffffc0202db4:	00002517          	auipc	a0,0x2
ffffffffc0202db8:	65450513          	addi	a0,a0,1620 # ffffffffc0205408 <default_pmm_manager+0x718>
ffffffffc0202dbc:	e406                	sd	ra,8(sp)
ffffffffc0202dbe:	e9cfd0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0202dc2 <find_vma>:
ffffffffc0202dc2:	86aa                	mv	a3,a0
ffffffffc0202dc4:	c505                	beqz	a0,ffffffffc0202dec <find_vma+0x2a>
ffffffffc0202dc6:	6908                	ld	a0,16(a0)
ffffffffc0202dc8:	c501                	beqz	a0,ffffffffc0202dd0 <find_vma+0xe>
ffffffffc0202dca:	651c                	ld	a5,8(a0)
ffffffffc0202dcc:	02f5f263          	bgeu	a1,a5,ffffffffc0202df0 <find_vma+0x2e>
ffffffffc0202dd0:	669c                	ld	a5,8(a3)
ffffffffc0202dd2:	00f68d63          	beq	a3,a5,ffffffffc0202dec <find_vma+0x2a>
ffffffffc0202dd6:	fe87b703          	ld	a4,-24(a5) # ffffffffc7ffffe8 <end+0x7df2afc>
ffffffffc0202dda:	00e5e663          	bltu	a1,a4,ffffffffc0202de6 <find_vma+0x24>
ffffffffc0202dde:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202de2:	00e5ec63          	bltu	a1,a4,ffffffffc0202dfa <find_vma+0x38>
ffffffffc0202de6:	679c                	ld	a5,8(a5)
ffffffffc0202de8:	fef697e3          	bne	a3,a5,ffffffffc0202dd6 <find_vma+0x14>
ffffffffc0202dec:	4501                	li	a0,0
ffffffffc0202dee:	8082                	ret
ffffffffc0202df0:	691c                	ld	a5,16(a0)
ffffffffc0202df2:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0202dd0 <find_vma+0xe>
ffffffffc0202df6:	ea88                	sd	a0,16(a3)
ffffffffc0202df8:	8082                	ret
ffffffffc0202dfa:	fe078513          	addi	a0,a5,-32
ffffffffc0202dfe:	ea88                	sd	a0,16(a3)
ffffffffc0202e00:	8082                	ret

ffffffffc0202e02 <insert_vma_struct>:
ffffffffc0202e02:	6590                	ld	a2,8(a1)
ffffffffc0202e04:	0105b803          	ld	a6,16(a1)
ffffffffc0202e08:	1141                	addi	sp,sp,-16
ffffffffc0202e0a:	e406                	sd	ra,8(sp)
ffffffffc0202e0c:	87aa                	mv	a5,a0
ffffffffc0202e0e:	01066763          	bltu	a2,a6,ffffffffc0202e1c <insert_vma_struct+0x1a>
ffffffffc0202e12:	a085                	j	ffffffffc0202e72 <insert_vma_struct+0x70>
ffffffffc0202e14:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202e18:	04e66863          	bltu	a2,a4,ffffffffc0202e68 <insert_vma_struct+0x66>
ffffffffc0202e1c:	86be                	mv	a3,a5
ffffffffc0202e1e:	679c                	ld	a5,8(a5)
ffffffffc0202e20:	fef51ae3          	bne	a0,a5,ffffffffc0202e14 <insert_vma_struct+0x12>
ffffffffc0202e24:	02a68463          	beq	a3,a0,ffffffffc0202e4c <insert_vma_struct+0x4a>
ffffffffc0202e28:	ff06b703          	ld	a4,-16(a3)
ffffffffc0202e2c:	fe86b883          	ld	a7,-24(a3)
ffffffffc0202e30:	08e8f163          	bgeu	a7,a4,ffffffffc0202eb2 <insert_vma_struct+0xb0>
ffffffffc0202e34:	04e66f63          	bltu	a2,a4,ffffffffc0202e92 <insert_vma_struct+0x90>
ffffffffc0202e38:	00f50a63          	beq	a0,a5,ffffffffc0202e4c <insert_vma_struct+0x4a>
ffffffffc0202e3c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202e40:	05076963          	bltu	a4,a6,ffffffffc0202e92 <insert_vma_struct+0x90>
ffffffffc0202e44:	ff07b603          	ld	a2,-16(a5)
ffffffffc0202e48:	02c77363          	bgeu	a4,a2,ffffffffc0202e6e <insert_vma_struct+0x6c>
ffffffffc0202e4c:	5118                	lw	a4,32(a0)
ffffffffc0202e4e:	e188                	sd	a0,0(a1)
ffffffffc0202e50:	02058613          	addi	a2,a1,32
ffffffffc0202e54:	e390                	sd	a2,0(a5)
ffffffffc0202e56:	e690                	sd	a2,8(a3)
ffffffffc0202e58:	60a2                	ld	ra,8(sp)
ffffffffc0202e5a:	f59c                	sd	a5,40(a1)
ffffffffc0202e5c:	f194                	sd	a3,32(a1)
ffffffffc0202e5e:	0017079b          	addiw	a5,a4,1
ffffffffc0202e62:	d11c                	sw	a5,32(a0)
ffffffffc0202e64:	0141                	addi	sp,sp,16
ffffffffc0202e66:	8082                	ret
ffffffffc0202e68:	fca690e3          	bne	a3,a0,ffffffffc0202e28 <insert_vma_struct+0x26>
ffffffffc0202e6c:	bfd1                	j	ffffffffc0202e40 <insert_vma_struct+0x3e>
ffffffffc0202e6e:	f31ff0ef          	jal	ra,ffffffffc0202d9e <check_vma_overlap.part.0>
ffffffffc0202e72:	00002697          	auipc	a3,0x2
ffffffffc0202e76:	5a668693          	addi	a3,a3,1446 # ffffffffc0205418 <default_pmm_manager+0x728>
ffffffffc0202e7a:	00002617          	auipc	a2,0x2
ffffffffc0202e7e:	abe60613          	addi	a2,a2,-1346 # ffffffffc0204938 <commands+0x810>
ffffffffc0202e82:	08e00593          	li	a1,142
ffffffffc0202e86:	00002517          	auipc	a0,0x2
ffffffffc0202e8a:	58250513          	addi	a0,a0,1410 # ffffffffc0205408 <default_pmm_manager+0x718>
ffffffffc0202e8e:	dccfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202e92:	00002697          	auipc	a3,0x2
ffffffffc0202e96:	5c668693          	addi	a3,a3,1478 # ffffffffc0205458 <default_pmm_manager+0x768>
ffffffffc0202e9a:	00002617          	auipc	a2,0x2
ffffffffc0202e9e:	a9e60613          	addi	a2,a2,-1378 # ffffffffc0204938 <commands+0x810>
ffffffffc0202ea2:	08700593          	li	a1,135
ffffffffc0202ea6:	00002517          	auipc	a0,0x2
ffffffffc0202eaa:	56250513          	addi	a0,a0,1378 # ffffffffc0205408 <default_pmm_manager+0x718>
ffffffffc0202eae:	dacfd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202eb2:	00002697          	auipc	a3,0x2
ffffffffc0202eb6:	58668693          	addi	a3,a3,1414 # ffffffffc0205438 <default_pmm_manager+0x748>
ffffffffc0202eba:	00002617          	auipc	a2,0x2
ffffffffc0202ebe:	a7e60613          	addi	a2,a2,-1410 # ffffffffc0204938 <commands+0x810>
ffffffffc0202ec2:	08600593          	li	a1,134
ffffffffc0202ec6:	00002517          	auipc	a0,0x2
ffffffffc0202eca:	54250513          	addi	a0,a0,1346 # ffffffffc0205408 <default_pmm_manager+0x718>
ffffffffc0202ece:	d8cfd0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0202ed2 <vmm_init>:
ffffffffc0202ed2:	7139                	addi	sp,sp,-64
ffffffffc0202ed4:	03000513          	li	a0,48
ffffffffc0202ed8:	fc06                	sd	ra,56(sp)
ffffffffc0202eda:	f822                	sd	s0,48(sp)
ffffffffc0202edc:	f426                	sd	s1,40(sp)
ffffffffc0202ede:	f04a                	sd	s2,32(sp)
ffffffffc0202ee0:	ec4e                	sd	s3,24(sp)
ffffffffc0202ee2:	e852                	sd	s4,16(sp)
ffffffffc0202ee4:	e456                	sd	s5,8(sp)
ffffffffc0202ee6:	bd5fe0ef          	jal	ra,ffffffffc0201aba <kmalloc>
ffffffffc0202eea:	2e050f63          	beqz	a0,ffffffffc02031e8 <vmm_init+0x316>
ffffffffc0202eee:	84aa                	mv	s1,a0
ffffffffc0202ef0:	e508                	sd	a0,8(a0)
ffffffffc0202ef2:	e108                	sd	a0,0(a0)
ffffffffc0202ef4:	00053823          	sd	zero,16(a0)
ffffffffc0202ef8:	00053c23          	sd	zero,24(a0)
ffffffffc0202efc:	02052023          	sw	zero,32(a0)
ffffffffc0202f00:	02053423          	sd	zero,40(a0)
ffffffffc0202f04:	03200413          	li	s0,50
ffffffffc0202f08:	a811                	j	ffffffffc0202f1c <vmm_init+0x4a>
ffffffffc0202f0a:	e500                	sd	s0,8(a0)
ffffffffc0202f0c:	e91c                	sd	a5,16(a0)
ffffffffc0202f0e:	00052c23          	sw	zero,24(a0)
ffffffffc0202f12:	146d                	addi	s0,s0,-5
ffffffffc0202f14:	8526                	mv	a0,s1
ffffffffc0202f16:	eedff0ef          	jal	ra,ffffffffc0202e02 <insert_vma_struct>
ffffffffc0202f1a:	c80d                	beqz	s0,ffffffffc0202f4c <vmm_init+0x7a>
ffffffffc0202f1c:	03000513          	li	a0,48
ffffffffc0202f20:	b9bfe0ef          	jal	ra,ffffffffc0201aba <kmalloc>
ffffffffc0202f24:	85aa                	mv	a1,a0
ffffffffc0202f26:	00240793          	addi	a5,s0,2
ffffffffc0202f2a:	f165                	bnez	a0,ffffffffc0202f0a <vmm_init+0x38>
ffffffffc0202f2c:	00002697          	auipc	a3,0x2
ffffffffc0202f30:	6c468693          	addi	a3,a3,1732 # ffffffffc02055f0 <default_pmm_manager+0x900>
ffffffffc0202f34:	00002617          	auipc	a2,0x2
ffffffffc0202f38:	a0460613          	addi	a2,a2,-1532 # ffffffffc0204938 <commands+0x810>
ffffffffc0202f3c:	0da00593          	li	a1,218
ffffffffc0202f40:	00002517          	auipc	a0,0x2
ffffffffc0202f44:	4c850513          	addi	a0,a0,1224 # ffffffffc0205408 <default_pmm_manager+0x718>
ffffffffc0202f48:	d12fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202f4c:	03700413          	li	s0,55
ffffffffc0202f50:	1f900913          	li	s2,505
ffffffffc0202f54:	a819                	j	ffffffffc0202f6a <vmm_init+0x98>
ffffffffc0202f56:	e500                	sd	s0,8(a0)
ffffffffc0202f58:	e91c                	sd	a5,16(a0)
ffffffffc0202f5a:	00052c23          	sw	zero,24(a0)
ffffffffc0202f5e:	0415                	addi	s0,s0,5
ffffffffc0202f60:	8526                	mv	a0,s1
ffffffffc0202f62:	ea1ff0ef          	jal	ra,ffffffffc0202e02 <insert_vma_struct>
ffffffffc0202f66:	03240a63          	beq	s0,s2,ffffffffc0202f9a <vmm_init+0xc8>
ffffffffc0202f6a:	03000513          	li	a0,48
ffffffffc0202f6e:	b4dfe0ef          	jal	ra,ffffffffc0201aba <kmalloc>
ffffffffc0202f72:	85aa                	mv	a1,a0
ffffffffc0202f74:	00240793          	addi	a5,s0,2
ffffffffc0202f78:	fd79                	bnez	a0,ffffffffc0202f56 <vmm_init+0x84>
ffffffffc0202f7a:	00002697          	auipc	a3,0x2
ffffffffc0202f7e:	67668693          	addi	a3,a3,1654 # ffffffffc02055f0 <default_pmm_manager+0x900>
ffffffffc0202f82:	00002617          	auipc	a2,0x2
ffffffffc0202f86:	9b660613          	addi	a2,a2,-1610 # ffffffffc0204938 <commands+0x810>
ffffffffc0202f8a:	0e100593          	li	a1,225
ffffffffc0202f8e:	00002517          	auipc	a0,0x2
ffffffffc0202f92:	47a50513          	addi	a0,a0,1146 # ffffffffc0205408 <default_pmm_manager+0x718>
ffffffffc0202f96:	cc4fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202f9a:	649c                	ld	a5,8(s1)
ffffffffc0202f9c:	471d                	li	a4,7
ffffffffc0202f9e:	1fb00593          	li	a1,507
ffffffffc0202fa2:	18f48363          	beq	s1,a5,ffffffffc0203128 <vmm_init+0x256>
ffffffffc0202fa6:	fe87b603          	ld	a2,-24(a5)
ffffffffc0202faa:	ffe70693          	addi	a3,a4,-2 # ffe <kern_entry-0xffffffffc01ff002>
ffffffffc0202fae:	10d61d63          	bne	a2,a3,ffffffffc02030c8 <vmm_init+0x1f6>
ffffffffc0202fb2:	ff07b683          	ld	a3,-16(a5)
ffffffffc0202fb6:	10e69963          	bne	a3,a4,ffffffffc02030c8 <vmm_init+0x1f6>
ffffffffc0202fba:	0715                	addi	a4,a4,5
ffffffffc0202fbc:	679c                	ld	a5,8(a5)
ffffffffc0202fbe:	feb712e3          	bne	a4,a1,ffffffffc0202fa2 <vmm_init+0xd0>
ffffffffc0202fc2:	4a1d                	li	s4,7
ffffffffc0202fc4:	4415                	li	s0,5
ffffffffc0202fc6:	1f900a93          	li	s5,505
ffffffffc0202fca:	85a2                	mv	a1,s0
ffffffffc0202fcc:	8526                	mv	a0,s1
ffffffffc0202fce:	df5ff0ef          	jal	ra,ffffffffc0202dc2 <find_vma>
ffffffffc0202fd2:	892a                	mv	s2,a0
ffffffffc0202fd4:	18050a63          	beqz	a0,ffffffffc0203168 <vmm_init+0x296>
ffffffffc0202fd8:	00140593          	addi	a1,s0,1
ffffffffc0202fdc:	8526                	mv	a0,s1
ffffffffc0202fde:	de5ff0ef          	jal	ra,ffffffffc0202dc2 <find_vma>
ffffffffc0202fe2:	89aa                	mv	s3,a0
ffffffffc0202fe4:	16050263          	beqz	a0,ffffffffc0203148 <vmm_init+0x276>
ffffffffc0202fe8:	85d2                	mv	a1,s4
ffffffffc0202fea:	8526                	mv	a0,s1
ffffffffc0202fec:	dd7ff0ef          	jal	ra,ffffffffc0202dc2 <find_vma>
ffffffffc0202ff0:	18051c63          	bnez	a0,ffffffffc0203188 <vmm_init+0x2b6>
ffffffffc0202ff4:	00340593          	addi	a1,s0,3
ffffffffc0202ff8:	8526                	mv	a0,s1
ffffffffc0202ffa:	dc9ff0ef          	jal	ra,ffffffffc0202dc2 <find_vma>
ffffffffc0202ffe:	1c051563          	bnez	a0,ffffffffc02031c8 <vmm_init+0x2f6>
ffffffffc0203002:	00440593          	addi	a1,s0,4
ffffffffc0203006:	8526                	mv	a0,s1
ffffffffc0203008:	dbbff0ef          	jal	ra,ffffffffc0202dc2 <find_vma>
ffffffffc020300c:	18051e63          	bnez	a0,ffffffffc02031a8 <vmm_init+0x2d6>
ffffffffc0203010:	00893783          	ld	a5,8(s2)
ffffffffc0203014:	0c879a63          	bne	a5,s0,ffffffffc02030e8 <vmm_init+0x216>
ffffffffc0203018:	01093783          	ld	a5,16(s2)
ffffffffc020301c:	0d479663          	bne	a5,s4,ffffffffc02030e8 <vmm_init+0x216>
ffffffffc0203020:	0089b783          	ld	a5,8(s3)
ffffffffc0203024:	0e879263          	bne	a5,s0,ffffffffc0203108 <vmm_init+0x236>
ffffffffc0203028:	0109b783          	ld	a5,16(s3)
ffffffffc020302c:	0d479e63          	bne	a5,s4,ffffffffc0203108 <vmm_init+0x236>
ffffffffc0203030:	0415                	addi	s0,s0,5
ffffffffc0203032:	0a15                	addi	s4,s4,5
ffffffffc0203034:	f9541be3          	bne	s0,s5,ffffffffc0202fca <vmm_init+0xf8>
ffffffffc0203038:	4411                	li	s0,4
ffffffffc020303a:	597d                	li	s2,-1
ffffffffc020303c:	85a2                	mv	a1,s0
ffffffffc020303e:	8526                	mv	a0,s1
ffffffffc0203040:	d83ff0ef          	jal	ra,ffffffffc0202dc2 <find_vma>
ffffffffc0203044:	0004059b          	sext.w	a1,s0
ffffffffc0203048:	c90d                	beqz	a0,ffffffffc020307a <vmm_init+0x1a8>
ffffffffc020304a:	6914                	ld	a3,16(a0)
ffffffffc020304c:	6510                	ld	a2,8(a0)
ffffffffc020304e:	00002517          	auipc	a0,0x2
ffffffffc0203052:	52a50513          	addi	a0,a0,1322 # ffffffffc0205578 <default_pmm_manager+0x888>
ffffffffc0203056:	93efd0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc020305a:	00002697          	auipc	a3,0x2
ffffffffc020305e:	54668693          	addi	a3,a3,1350 # ffffffffc02055a0 <default_pmm_manager+0x8b0>
ffffffffc0203062:	00002617          	auipc	a2,0x2
ffffffffc0203066:	8d660613          	addi	a2,a2,-1834 # ffffffffc0204938 <commands+0x810>
ffffffffc020306a:	10700593          	li	a1,263
ffffffffc020306e:	00002517          	auipc	a0,0x2
ffffffffc0203072:	39a50513          	addi	a0,a0,922 # ffffffffc0205408 <default_pmm_manager+0x718>
ffffffffc0203076:	be4fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc020307a:	147d                	addi	s0,s0,-1
ffffffffc020307c:	fd2410e3          	bne	s0,s2,ffffffffc020303c <vmm_init+0x16a>
ffffffffc0203080:	6488                	ld	a0,8(s1)
ffffffffc0203082:	00a48c63          	beq	s1,a0,ffffffffc020309a <vmm_init+0x1c8>
ffffffffc0203086:	6118                	ld	a4,0(a0)
ffffffffc0203088:	651c                	ld	a5,8(a0)
ffffffffc020308a:	1501                	addi	a0,a0,-32
ffffffffc020308c:	e71c                	sd	a5,8(a4)
ffffffffc020308e:	e398                	sd	a4,0(a5)
ffffffffc0203090:	adbfe0ef          	jal	ra,ffffffffc0201b6a <kfree>
ffffffffc0203094:	6488                	ld	a0,8(s1)
ffffffffc0203096:	fea498e3          	bne	s1,a0,ffffffffc0203086 <vmm_init+0x1b4>
ffffffffc020309a:	8526                	mv	a0,s1
ffffffffc020309c:	acffe0ef          	jal	ra,ffffffffc0201b6a <kfree>
ffffffffc02030a0:	00002517          	auipc	a0,0x2
ffffffffc02030a4:	51850513          	addi	a0,a0,1304 # ffffffffc02055b8 <default_pmm_manager+0x8c8>
ffffffffc02030a8:	8ecfd0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02030ac:	7442                	ld	s0,48(sp)
ffffffffc02030ae:	70e2                	ld	ra,56(sp)
ffffffffc02030b0:	74a2                	ld	s1,40(sp)
ffffffffc02030b2:	7902                	ld	s2,32(sp)
ffffffffc02030b4:	69e2                	ld	s3,24(sp)
ffffffffc02030b6:	6a42                	ld	s4,16(sp)
ffffffffc02030b8:	6aa2                	ld	s5,8(sp)
ffffffffc02030ba:	00002517          	auipc	a0,0x2
ffffffffc02030be:	51e50513          	addi	a0,a0,1310 # ffffffffc02055d8 <default_pmm_manager+0x8e8>
ffffffffc02030c2:	6121                	addi	sp,sp,64
ffffffffc02030c4:	8d0fd06f          	j	ffffffffc0200194 <cprintf>
ffffffffc02030c8:	00002697          	auipc	a3,0x2
ffffffffc02030cc:	3c868693          	addi	a3,a3,968 # ffffffffc0205490 <default_pmm_manager+0x7a0>
ffffffffc02030d0:	00002617          	auipc	a2,0x2
ffffffffc02030d4:	86860613          	addi	a2,a2,-1944 # ffffffffc0204938 <commands+0x810>
ffffffffc02030d8:	0eb00593          	li	a1,235
ffffffffc02030dc:	00002517          	auipc	a0,0x2
ffffffffc02030e0:	32c50513          	addi	a0,a0,812 # ffffffffc0205408 <default_pmm_manager+0x718>
ffffffffc02030e4:	b76fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02030e8:	00002697          	auipc	a3,0x2
ffffffffc02030ec:	43068693          	addi	a3,a3,1072 # ffffffffc0205518 <default_pmm_manager+0x828>
ffffffffc02030f0:	00002617          	auipc	a2,0x2
ffffffffc02030f4:	84860613          	addi	a2,a2,-1976 # ffffffffc0204938 <commands+0x810>
ffffffffc02030f8:	0fc00593          	li	a1,252
ffffffffc02030fc:	00002517          	auipc	a0,0x2
ffffffffc0203100:	30c50513          	addi	a0,a0,780 # ffffffffc0205408 <default_pmm_manager+0x718>
ffffffffc0203104:	b56fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0203108:	00002697          	auipc	a3,0x2
ffffffffc020310c:	44068693          	addi	a3,a3,1088 # ffffffffc0205548 <default_pmm_manager+0x858>
ffffffffc0203110:	00002617          	auipc	a2,0x2
ffffffffc0203114:	82860613          	addi	a2,a2,-2008 # ffffffffc0204938 <commands+0x810>
ffffffffc0203118:	0fd00593          	li	a1,253
ffffffffc020311c:	00002517          	auipc	a0,0x2
ffffffffc0203120:	2ec50513          	addi	a0,a0,748 # ffffffffc0205408 <default_pmm_manager+0x718>
ffffffffc0203124:	b36fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0203128:	00002697          	auipc	a3,0x2
ffffffffc020312c:	35068693          	addi	a3,a3,848 # ffffffffc0205478 <default_pmm_manager+0x788>
ffffffffc0203130:	00002617          	auipc	a2,0x2
ffffffffc0203134:	80860613          	addi	a2,a2,-2040 # ffffffffc0204938 <commands+0x810>
ffffffffc0203138:	0e900593          	li	a1,233
ffffffffc020313c:	00002517          	auipc	a0,0x2
ffffffffc0203140:	2cc50513          	addi	a0,a0,716 # ffffffffc0205408 <default_pmm_manager+0x718>
ffffffffc0203144:	b16fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0203148:	00002697          	auipc	a3,0x2
ffffffffc020314c:	39068693          	addi	a3,a3,912 # ffffffffc02054d8 <default_pmm_manager+0x7e8>
ffffffffc0203150:	00001617          	auipc	a2,0x1
ffffffffc0203154:	7e860613          	addi	a2,a2,2024 # ffffffffc0204938 <commands+0x810>
ffffffffc0203158:	0f400593          	li	a1,244
ffffffffc020315c:	00002517          	auipc	a0,0x2
ffffffffc0203160:	2ac50513          	addi	a0,a0,684 # ffffffffc0205408 <default_pmm_manager+0x718>
ffffffffc0203164:	af6fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0203168:	00002697          	auipc	a3,0x2
ffffffffc020316c:	36068693          	addi	a3,a3,864 # ffffffffc02054c8 <default_pmm_manager+0x7d8>
ffffffffc0203170:	00001617          	auipc	a2,0x1
ffffffffc0203174:	7c860613          	addi	a2,a2,1992 # ffffffffc0204938 <commands+0x810>
ffffffffc0203178:	0f200593          	li	a1,242
ffffffffc020317c:	00002517          	auipc	a0,0x2
ffffffffc0203180:	28c50513          	addi	a0,a0,652 # ffffffffc0205408 <default_pmm_manager+0x718>
ffffffffc0203184:	ad6fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0203188:	00002697          	auipc	a3,0x2
ffffffffc020318c:	36068693          	addi	a3,a3,864 # ffffffffc02054e8 <default_pmm_manager+0x7f8>
ffffffffc0203190:	00001617          	auipc	a2,0x1
ffffffffc0203194:	7a860613          	addi	a2,a2,1960 # ffffffffc0204938 <commands+0x810>
ffffffffc0203198:	0f600593          	li	a1,246
ffffffffc020319c:	00002517          	auipc	a0,0x2
ffffffffc02031a0:	26c50513          	addi	a0,a0,620 # ffffffffc0205408 <default_pmm_manager+0x718>
ffffffffc02031a4:	ab6fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02031a8:	00002697          	auipc	a3,0x2
ffffffffc02031ac:	36068693          	addi	a3,a3,864 # ffffffffc0205508 <default_pmm_manager+0x818>
ffffffffc02031b0:	00001617          	auipc	a2,0x1
ffffffffc02031b4:	78860613          	addi	a2,a2,1928 # ffffffffc0204938 <commands+0x810>
ffffffffc02031b8:	0fa00593          	li	a1,250
ffffffffc02031bc:	00002517          	auipc	a0,0x2
ffffffffc02031c0:	24c50513          	addi	a0,a0,588 # ffffffffc0205408 <default_pmm_manager+0x718>
ffffffffc02031c4:	a96fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02031c8:	00002697          	auipc	a3,0x2
ffffffffc02031cc:	33068693          	addi	a3,a3,816 # ffffffffc02054f8 <default_pmm_manager+0x808>
ffffffffc02031d0:	00001617          	auipc	a2,0x1
ffffffffc02031d4:	76860613          	addi	a2,a2,1896 # ffffffffc0204938 <commands+0x810>
ffffffffc02031d8:	0f800593          	li	a1,248
ffffffffc02031dc:	00002517          	auipc	a0,0x2
ffffffffc02031e0:	22c50513          	addi	a0,a0,556 # ffffffffc0205408 <default_pmm_manager+0x718>
ffffffffc02031e4:	a76fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02031e8:	00002697          	auipc	a3,0x2
ffffffffc02031ec:	41868693          	addi	a3,a3,1048 # ffffffffc0205600 <default_pmm_manager+0x910>
ffffffffc02031f0:	00001617          	auipc	a2,0x1
ffffffffc02031f4:	74860613          	addi	a2,a2,1864 # ffffffffc0204938 <commands+0x810>
ffffffffc02031f8:	0d200593          	li	a1,210
ffffffffc02031fc:	00002517          	auipc	a0,0x2
ffffffffc0203200:	20c50513          	addi	a0,a0,524 # ffffffffc0205408 <default_pmm_manager+0x718>
ffffffffc0203204:	a56fd0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0203208 <kernel_thread_entry>:
ffffffffc0203208:	8526                	mv	a0,s1
ffffffffc020320a:	9402                	jalr	s0
ffffffffc020320c:	408000ef          	jal	ra,ffffffffc0203614 <do_exit>

ffffffffc0203210 <alloc_proc>:
ffffffffc0203210:	1141                	addi	sp,sp,-16
ffffffffc0203212:	10000513          	li	a0,256
ffffffffc0203216:	e022                	sd	s0,0(sp)
ffffffffc0203218:	e406                	sd	ra,8(sp)
ffffffffc020321a:	8a1fe0ef          	jal	ra,ffffffffc0201aba <kmalloc>
ffffffffc020321e:	842a                	mv	s0,a0
ffffffffc0203220:	c521                	beqz	a0,ffffffffc0203268 <alloc_proc+0x58>
ffffffffc0203222:	57fd                	li	a5,-1
ffffffffc0203224:	1782                	slli	a5,a5,0x20
ffffffffc0203226:	e11c                	sd	a5,0(a0)
ffffffffc0203228:	07000613          	li	a2,112
ffffffffc020322c:	4581                	li	a1,0
ffffffffc020322e:	00052423          	sw	zero,8(a0)
ffffffffc0203232:	00053823          	sd	zero,16(a0)
ffffffffc0203236:	00052c23          	sw	zero,24(a0)
ffffffffc020323a:	02053023          	sd	zero,32(a0)
ffffffffc020323e:	04053023          	sd	zero,64(a0)
ffffffffc0203242:	04850513          	addi	a0,a0,72
ffffffffc0203246:	42b000ef          	jal	ra,ffffffffc0203e70 <memset>
ffffffffc020324a:	0000a797          	auipc	a5,0xa
ffffffffc020324e:	2567b783          	ld	a5,598(a5) # ffffffffc020d4a0 <boot_pgdir_pa>
ffffffffc0203252:	0a043c23          	sd	zero,184(s0)
ffffffffc0203256:	e07c                	sd	a5,192(s0)
ffffffffc0203258:	0c042423          	sw	zero,200(s0)
ffffffffc020325c:	4641                	li	a2,16
ffffffffc020325e:	4581                	li	a1,0
ffffffffc0203260:	0cc40513          	addi	a0,s0,204
ffffffffc0203264:	40d000ef          	jal	ra,ffffffffc0203e70 <memset>
ffffffffc0203268:	60a2                	ld	ra,8(sp)
ffffffffc020326a:	8522                	mv	a0,s0
ffffffffc020326c:	6402                	ld	s0,0(sp)
ffffffffc020326e:	0141                	addi	sp,sp,16
ffffffffc0203270:	8082                	ret

ffffffffc0203272 <forkret>:
ffffffffc0203272:	0000a797          	auipc	a5,0xa
ffffffffc0203276:	25e7b783          	ld	a5,606(a5) # ffffffffc020d4d0 <current>
ffffffffc020327a:	7fc8                	ld	a0,184(a5)
ffffffffc020327c:	b51fd06f          	j	ffffffffc0200dcc <forkrets>

ffffffffc0203280 <init_main>:
ffffffffc0203280:	7179                	addi	sp,sp,-48
ffffffffc0203282:	ec26                	sd	s1,24(sp)
ffffffffc0203284:	0000a497          	auipc	s1,0xa
ffffffffc0203288:	1c448493          	addi	s1,s1,452 # ffffffffc020d448 <name.2>
ffffffffc020328c:	f022                	sd	s0,32(sp)
ffffffffc020328e:	e84a                	sd	s2,16(sp)
ffffffffc0203290:	842a                	mv	s0,a0
ffffffffc0203292:	0000a917          	auipc	s2,0xa
ffffffffc0203296:	23e93903          	ld	s2,574(s2) # ffffffffc020d4d0 <current>
ffffffffc020329a:	4641                	li	a2,16
ffffffffc020329c:	4581                	li	a1,0
ffffffffc020329e:	8526                	mv	a0,s1
ffffffffc02032a0:	f406                	sd	ra,40(sp)
ffffffffc02032a2:	e44e                	sd	s3,8(sp)
ffffffffc02032a4:	00492983          	lw	s3,4(s2)
ffffffffc02032a8:	3c9000ef          	jal	ra,ffffffffc0203e70 <memset>
ffffffffc02032ac:	0cc90593          	addi	a1,s2,204
ffffffffc02032b0:	463d                	li	a2,15
ffffffffc02032b2:	8526                	mv	a0,s1
ffffffffc02032b4:	3cf000ef          	jal	ra,ffffffffc0203e82 <memcpy>
ffffffffc02032b8:	862a                	mv	a2,a0
ffffffffc02032ba:	85ce                	mv	a1,s3
ffffffffc02032bc:	00002517          	auipc	a0,0x2
ffffffffc02032c0:	35450513          	addi	a0,a0,852 # ffffffffc0205610 <default_pmm_manager+0x920>
ffffffffc02032c4:	ed1fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02032c8:	85a2                	mv	a1,s0
ffffffffc02032ca:	00002517          	auipc	a0,0x2
ffffffffc02032ce:	36e50513          	addi	a0,a0,878 # ffffffffc0205638 <default_pmm_manager+0x948>
ffffffffc02032d2:	ec3fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02032d6:	00002517          	auipc	a0,0x2
ffffffffc02032da:	37250513          	addi	a0,a0,882 # ffffffffc0205648 <default_pmm_manager+0x958>
ffffffffc02032de:	eb7fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02032e2:	70a2                	ld	ra,40(sp)
ffffffffc02032e4:	7402                	ld	s0,32(sp)
ffffffffc02032e6:	64e2                	ld	s1,24(sp)
ffffffffc02032e8:	6942                	ld	s2,16(sp)
ffffffffc02032ea:	69a2                	ld	s3,8(sp)
ffffffffc02032ec:	4501                	li	a0,0
ffffffffc02032ee:	6145                	addi	sp,sp,48
ffffffffc02032f0:	8082                	ret

ffffffffc02032f2 <proc_run>:
ffffffffc02032f2:	7179                	addi	sp,sp,-48
ffffffffc02032f4:	f026                	sd	s1,32(sp)
ffffffffc02032f6:	0000a497          	auipc	s1,0xa
ffffffffc02032fa:	1da48493          	addi	s1,s1,474 # ffffffffc020d4d0 <current>
ffffffffc02032fe:	6098                	ld	a4,0(s1)
ffffffffc0203300:	f406                	sd	ra,40(sp)
ffffffffc0203302:	ec4a                	sd	s2,24(sp)
ffffffffc0203304:	02a70863          	beq	a4,a0,ffffffffc0203334 <proc_run+0x42>
ffffffffc0203308:	100027f3          	csrr	a5,sstatus
ffffffffc020330c:	8b89                	andi	a5,a5,2
ffffffffc020330e:	4901                	li	s2,0
ffffffffc0203310:	ef8d                	bnez	a5,ffffffffc020334a <proc_run+0x58>
ffffffffc0203312:	617c                	ld	a5,192(a0)
ffffffffc0203314:	800006b7          	lui	a3,0x80000
ffffffffc0203318:	e088                	sd	a0,0(s1)
ffffffffc020331a:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc020331e:	8fd5                	or	a5,a5,a3
ffffffffc0203320:	18079073          	csrw	satp,a5
ffffffffc0203324:	04850593          	addi	a1,a0,72
ffffffffc0203328:	04870513          	addi	a0,a4,72
ffffffffc020332c:	56e000ef          	jal	ra,ffffffffc020389a <switch_to>
ffffffffc0203330:	00091763          	bnez	s2,ffffffffc020333e <proc_run+0x4c>
ffffffffc0203334:	70a2                	ld	ra,40(sp)
ffffffffc0203336:	7482                	ld	s1,32(sp)
ffffffffc0203338:	6962                	ld	s2,24(sp)
ffffffffc020333a:	6145                	addi	sp,sp,48
ffffffffc020333c:	8082                	ret
ffffffffc020333e:	70a2                	ld	ra,40(sp)
ffffffffc0203340:	7482                	ld	s1,32(sp)
ffffffffc0203342:	6962                	ld	s2,24(sp)
ffffffffc0203344:	6145                	addi	sp,sp,48
ffffffffc0203346:	de4fd06f          	j	ffffffffc020092a <intr_enable>
ffffffffc020334a:	e42a                	sd	a0,8(sp)
ffffffffc020334c:	de4fd0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc0203350:	6098                	ld	a4,0(s1)
ffffffffc0203352:	6522                	ld	a0,8(sp)
ffffffffc0203354:	4905                	li	s2,1
ffffffffc0203356:	bf75                	j	ffffffffc0203312 <proc_run+0x20>

ffffffffc0203358 <do_fork>:
ffffffffc0203358:	7179                	addi	sp,sp,-48
ffffffffc020335a:	ec26                	sd	s1,24(sp)
ffffffffc020335c:	0000a497          	auipc	s1,0xa
ffffffffc0203360:	18c48493          	addi	s1,s1,396 # ffffffffc020d4e8 <nr_process>
ffffffffc0203364:	4098                	lw	a4,0(s1)
ffffffffc0203366:	f406                	sd	ra,40(sp)
ffffffffc0203368:	f022                	sd	s0,32(sp)
ffffffffc020336a:	e84a                	sd	s2,16(sp)
ffffffffc020336c:	e44e                	sd	s3,8(sp)
ffffffffc020336e:	e052                	sd	s4,0(sp)
ffffffffc0203370:	6785                	lui	a5,0x1
ffffffffc0203372:	20f75163          	bge	a4,a5,ffffffffc0203574 <do_fork+0x21c>
ffffffffc0203376:	892e                	mv	s2,a1
ffffffffc0203378:	89b2                	mv	s3,a2
ffffffffc020337a:	e97ff0ef          	jal	ra,ffffffffc0203210 <alloc_proc>
ffffffffc020337e:	842a                	mv	s0,a0
ffffffffc0203380:	20050163          	beqz	a0,ffffffffc0203582 <do_fork+0x22a>
ffffffffc0203384:	0000aa17          	auipc	s4,0xa
ffffffffc0203388:	14ca0a13          	addi	s4,s4,332 # ffffffffc020d4d0 <current>
ffffffffc020338c:	000a3783          	ld	a5,0(s4)
ffffffffc0203390:	7798                	ld	a4,40(a5)
ffffffffc0203392:	f11c                	sd	a5,32(a0)
ffffffffc0203394:	f518                	sd	a4,40(a0)
ffffffffc0203396:	c311                	beqz	a4,ffffffffc020339a <do_fork+0x42>
ffffffffc0203398:	fb08                	sd	a0,48(a4)
ffffffffc020339a:	f780                	sd	s0,40(a5)
ffffffffc020339c:	02043823          	sd	zero,48(s0)
ffffffffc02033a0:	02043c23          	sd	zero,56(s0)
ffffffffc02033a4:	4509                	li	a0,2
ffffffffc02033a6:	8f3fe0ef          	jal	ra,ffffffffc0201c98 <alloc_pages>
ffffffffc02033aa:	16050d63          	beqz	a0,ffffffffc0203524 <do_fork+0x1cc>
ffffffffc02033ae:	0000a697          	auipc	a3,0xa
ffffffffc02033b2:	10a6b683          	ld	a3,266(a3) # ffffffffc020d4b8 <pages>
ffffffffc02033b6:	40d506b3          	sub	a3,a0,a3
ffffffffc02033ba:	8699                	srai	a3,a3,0x6
ffffffffc02033bc:	00002517          	auipc	a0,0x2
ffffffffc02033c0:	64c53503          	ld	a0,1612(a0) # ffffffffc0205a08 <nbase>
ffffffffc02033c4:	96aa                	add	a3,a3,a0
ffffffffc02033c6:	00c69793          	slli	a5,a3,0xc
ffffffffc02033ca:	83b1                	srli	a5,a5,0xc
ffffffffc02033cc:	0000a717          	auipc	a4,0xa
ffffffffc02033d0:	0e473703          	ld	a4,228(a4) # ffffffffc020d4b0 <npage>
ffffffffc02033d4:	06b2                	slli	a3,a3,0xc
ffffffffc02033d6:	1ae7fb63          	bgeu	a5,a4,ffffffffc020358c <do_fork+0x234>
ffffffffc02033da:	000a3783          	ld	a5,0(s4)
ffffffffc02033de:	0000a717          	auipc	a4,0xa
ffffffffc02033e2:	0ea73703          	ld	a4,234(a4) # ffffffffc020d4c8 <va_pa_offset>
ffffffffc02033e6:	96ba                	add	a3,a3,a4
ffffffffc02033e8:	63bc                	ld	a5,64(a5)
ffffffffc02033ea:	e814                	sd	a3,16(s0)
ffffffffc02033ec:	1a079c63          	bnez	a5,ffffffffc02035a4 <do_fork+0x24c>
ffffffffc02033f0:	6789                	lui	a5,0x2
ffffffffc02033f2:	ee078793          	addi	a5,a5,-288 # 1ee0 <kern_entry-0xffffffffc01fe120>
ffffffffc02033f6:	96be                	add	a3,a3,a5
ffffffffc02033f8:	864e                	mv	a2,s3
ffffffffc02033fa:	fc54                	sd	a3,184(s0)
ffffffffc02033fc:	87b6                	mv	a5,a3
ffffffffc02033fe:	12098893          	addi	a7,s3,288
ffffffffc0203402:	00063803          	ld	a6,0(a2)
ffffffffc0203406:	6608                	ld	a0,8(a2)
ffffffffc0203408:	6a0c                	ld	a1,16(a2)
ffffffffc020340a:	6e18                	ld	a4,24(a2)
ffffffffc020340c:	0107b023          	sd	a6,0(a5)
ffffffffc0203410:	e788                	sd	a0,8(a5)
ffffffffc0203412:	eb8c                	sd	a1,16(a5)
ffffffffc0203414:	ef98                	sd	a4,24(a5)
ffffffffc0203416:	02060613          	addi	a2,a2,32
ffffffffc020341a:	02078793          	addi	a5,a5,32
ffffffffc020341e:	ff1612e3          	bne	a2,a7,ffffffffc0203402 <do_fork+0xaa>
ffffffffc0203422:	0406b823          	sd	zero,80(a3)
ffffffffc0203426:	10090b63          	beqz	s2,ffffffffc020353c <do_fork+0x1e4>
ffffffffc020342a:	00006817          	auipc	a6,0x6
ffffffffc020342e:	bfe80813          	addi	a6,a6,-1026 # ffffffffc0209028 <last_pid.1>
ffffffffc0203432:	00082783          	lw	a5,0(a6)
ffffffffc0203436:	0126b823          	sd	s2,16(a3)
ffffffffc020343a:	00000717          	auipc	a4,0x0
ffffffffc020343e:	e3870713          	addi	a4,a4,-456 # ffffffffc0203272 <forkret>
ffffffffc0203442:	0017851b          	addiw	a0,a5,1
ffffffffc0203446:	e438                	sd	a4,72(s0)
ffffffffc0203448:	e834                	sd	a3,80(s0)
ffffffffc020344a:	00a82023          	sw	a0,0(a6)
ffffffffc020344e:	6789                	lui	a5,0x2
ffffffffc0203450:	0ef55863          	bge	a0,a5,ffffffffc0203540 <do_fork+0x1e8>
ffffffffc0203454:	00006317          	auipc	t1,0x6
ffffffffc0203458:	bd830313          	addi	t1,t1,-1064 # ffffffffc020902c <next_safe.0>
ffffffffc020345c:	00032783          	lw	a5,0(t1)
ffffffffc0203460:	0000a917          	auipc	s2,0xa
ffffffffc0203464:	ff890913          	addi	s2,s2,-8 # ffffffffc020d458 <proc_list>
ffffffffc0203468:	06f54063          	blt	a0,a5,ffffffffc02034c8 <do_fork+0x170>
ffffffffc020346c:	0000a917          	auipc	s2,0xa
ffffffffc0203470:	fec90913          	addi	s2,s2,-20 # ffffffffc020d458 <proc_list>
ffffffffc0203474:	00893e03          	ld	t3,8(s2)
ffffffffc0203478:	6789                	lui	a5,0x2
ffffffffc020347a:	00f32023          	sw	a5,0(t1)
ffffffffc020347e:	86aa                	mv	a3,a0
ffffffffc0203480:	4581                	li	a1,0
ffffffffc0203482:	6e89                	lui	t4,0x2
ffffffffc0203484:	0f2e0a63          	beq	t3,s2,ffffffffc0203578 <do_fork+0x220>
ffffffffc0203488:	88ae                	mv	a7,a1
ffffffffc020348a:	87f2                	mv	a5,t3
ffffffffc020348c:	6609                	lui	a2,0x2
ffffffffc020348e:	a811                	j	ffffffffc02034a2 <do_fork+0x14a>
ffffffffc0203490:	00e6d663          	bge	a3,a4,ffffffffc020349c <do_fork+0x144>
ffffffffc0203494:	00c75463          	bge	a4,a2,ffffffffc020349c <do_fork+0x144>
ffffffffc0203498:	863a                	mv	a2,a4
ffffffffc020349a:	4885                	li	a7,1
ffffffffc020349c:	679c                	ld	a5,8(a5)
ffffffffc020349e:	01278d63          	beq	a5,s2,ffffffffc02034b8 <do_fork+0x160>
ffffffffc02034a2:	f247a703          	lw	a4,-220(a5) # 1f24 <kern_entry-0xffffffffc01fe0dc>
ffffffffc02034a6:	fed715e3          	bne	a4,a3,ffffffffc0203490 <do_fork+0x138>
ffffffffc02034aa:	2685                	addiw	a3,a3,1
ffffffffc02034ac:	0ac6df63          	bge	a3,a2,ffffffffc020356a <do_fork+0x212>
ffffffffc02034b0:	679c                	ld	a5,8(a5)
ffffffffc02034b2:	4585                	li	a1,1
ffffffffc02034b4:	ff2797e3          	bne	a5,s2,ffffffffc02034a2 <do_fork+0x14a>
ffffffffc02034b8:	c581                	beqz	a1,ffffffffc02034c0 <do_fork+0x168>
ffffffffc02034ba:	00d82023          	sw	a3,0(a6)
ffffffffc02034be:	8536                	mv	a0,a3
ffffffffc02034c0:	00088463          	beqz	a7,ffffffffc02034c8 <do_fork+0x170>
ffffffffc02034c4:	00c32023          	sw	a2,0(t1)
ffffffffc02034c8:	c048                	sw	a0,4(s0)
ffffffffc02034ca:	45a9                	li	a1,10
ffffffffc02034cc:	2501                	sext.w	a0,a0
ffffffffc02034ce:	4fc000ef          	jal	ra,ffffffffc02039ca <hash32>
ffffffffc02034d2:	02051793          	slli	a5,a0,0x20
ffffffffc02034d6:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02034da:	00006797          	auipc	a5,0x6
ffffffffc02034de:	f6e78793          	addi	a5,a5,-146 # ffffffffc0209448 <hash_list>
ffffffffc02034e2:	953e                	add	a0,a0,a5
ffffffffc02034e4:	6518                	ld	a4,8(a0)
ffffffffc02034e6:	0f040793          	addi	a5,s0,240
ffffffffc02034ea:	00893683          	ld	a3,8(s2)
ffffffffc02034ee:	e31c                	sd	a5,0(a4)
ffffffffc02034f0:	e51c                	sd	a5,8(a0)
ffffffffc02034f2:	409c                	lw	a5,0(s1)
ffffffffc02034f4:	fc78                	sd	a4,248(s0)
ffffffffc02034f6:	f868                	sd	a0,240(s0)
ffffffffc02034f8:	0e040713          	addi	a4,s0,224
ffffffffc02034fc:	e298                	sd	a4,0(a3)
ffffffffc02034fe:	0f243023          	sd	s2,224(s0)
ffffffffc0203502:	8522                	mv	a0,s0
ffffffffc0203504:	2785                	addiw	a5,a5,1
ffffffffc0203506:	f474                	sd	a3,232(s0)
ffffffffc0203508:	00e93423          	sd	a4,8(s2)
ffffffffc020350c:	c09c                	sw	a5,0(s1)
ffffffffc020350e:	3f6000ef          	jal	ra,ffffffffc0203904 <wakeup_proc>
ffffffffc0203512:	4048                	lw	a0,4(s0)
ffffffffc0203514:	70a2                	ld	ra,40(sp)
ffffffffc0203516:	7402                	ld	s0,32(sp)
ffffffffc0203518:	64e2                	ld	s1,24(sp)
ffffffffc020351a:	6942                	ld	s2,16(sp)
ffffffffc020351c:	69a2                	ld	s3,8(sp)
ffffffffc020351e:	6a02                	ld	s4,0(sp)
ffffffffc0203520:	6145                	addi	sp,sp,48
ffffffffc0203522:	8082                	ret
ffffffffc0203524:	8522                	mv	a0,s0
ffffffffc0203526:	e44fe0ef          	jal	ra,ffffffffc0201b6a <kfree>
ffffffffc020352a:	5571                	li	a0,-4
ffffffffc020352c:	70a2                	ld	ra,40(sp)
ffffffffc020352e:	7402                	ld	s0,32(sp)
ffffffffc0203530:	64e2                	ld	s1,24(sp)
ffffffffc0203532:	6942                	ld	s2,16(sp)
ffffffffc0203534:	69a2                	ld	s3,8(sp)
ffffffffc0203536:	6a02                	ld	s4,0(sp)
ffffffffc0203538:	6145                	addi	sp,sp,48
ffffffffc020353a:	8082                	ret
ffffffffc020353c:	8936                	mv	s2,a3
ffffffffc020353e:	b5f5                	j	ffffffffc020342a <do_fork+0xd2>
ffffffffc0203540:	4785                	li	a5,1
ffffffffc0203542:	00f82023          	sw	a5,0(a6)
ffffffffc0203546:	4505                	li	a0,1
ffffffffc0203548:	00006317          	auipc	t1,0x6
ffffffffc020354c:	ae430313          	addi	t1,t1,-1308 # ffffffffc020902c <next_safe.0>
ffffffffc0203550:	0000a917          	auipc	s2,0xa
ffffffffc0203554:	f0890913          	addi	s2,s2,-248 # ffffffffc020d458 <proc_list>
ffffffffc0203558:	6789                	lui	a5,0x2
ffffffffc020355a:	00893e03          	ld	t3,8(s2)
ffffffffc020355e:	00f32023          	sw	a5,0(t1)
ffffffffc0203562:	86aa                	mv	a3,a0
ffffffffc0203564:	4581                	li	a1,0
ffffffffc0203566:	6e89                	lui	t4,0x2
ffffffffc0203568:	bf31                	j	ffffffffc0203484 <do_fork+0x12c>
ffffffffc020356a:	01d6c363          	blt	a3,t4,ffffffffc0203570 <do_fork+0x218>
ffffffffc020356e:	4685                	li	a3,1
ffffffffc0203570:	4585                	li	a1,1
ffffffffc0203572:	bf09                	j	ffffffffc0203484 <do_fork+0x12c>
ffffffffc0203574:	556d                	li	a0,-5
ffffffffc0203576:	bf5d                	j	ffffffffc020352c <do_fork+0x1d4>
ffffffffc0203578:	c599                	beqz	a1,ffffffffc0203586 <do_fork+0x22e>
ffffffffc020357a:	00d82023          	sw	a3,0(a6)
ffffffffc020357e:	8536                	mv	a0,a3
ffffffffc0203580:	b7a1                	j	ffffffffc02034c8 <do_fork+0x170>
ffffffffc0203582:	5571                	li	a0,-4
ffffffffc0203584:	b765                	j	ffffffffc020352c <do_fork+0x1d4>
ffffffffc0203586:	00082503          	lw	a0,0(a6)
ffffffffc020358a:	bf3d                	j	ffffffffc02034c8 <do_fork+0x170>
ffffffffc020358c:	00001617          	auipc	a2,0x1
ffffffffc0203590:	79c60613          	addi	a2,a2,1948 # ffffffffc0204d28 <default_pmm_manager+0x38>
ffffffffc0203594:	07100593          	li	a1,113
ffffffffc0203598:	00001517          	auipc	a0,0x1
ffffffffc020359c:	7b850513          	addi	a0,a0,1976 # ffffffffc0204d50 <default_pmm_manager+0x60>
ffffffffc02035a0:	ebbfc0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02035a4:	00002697          	auipc	a3,0x2
ffffffffc02035a8:	0c468693          	addi	a3,a3,196 # ffffffffc0205668 <default_pmm_manager+0x978>
ffffffffc02035ac:	00001617          	auipc	a2,0x1
ffffffffc02035b0:	38c60613          	addi	a2,a2,908 # ffffffffc0204938 <commands+0x810>
ffffffffc02035b4:	11d00593          	li	a1,285
ffffffffc02035b8:	00002517          	auipc	a0,0x2
ffffffffc02035bc:	0c850513          	addi	a0,a0,200 # ffffffffc0205680 <default_pmm_manager+0x990>
ffffffffc02035c0:	e9bfc0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc02035c4 <kernel_thread>:
ffffffffc02035c4:	7129                	addi	sp,sp,-320
ffffffffc02035c6:	fa22                	sd	s0,304(sp)
ffffffffc02035c8:	f626                	sd	s1,296(sp)
ffffffffc02035ca:	f24a                	sd	s2,288(sp)
ffffffffc02035cc:	84ae                	mv	s1,a1
ffffffffc02035ce:	892a                	mv	s2,a0
ffffffffc02035d0:	8432                	mv	s0,a2
ffffffffc02035d2:	4581                	li	a1,0
ffffffffc02035d4:	12000613          	li	a2,288
ffffffffc02035d8:	850a                	mv	a0,sp
ffffffffc02035da:	fe06                	sd	ra,312(sp)
ffffffffc02035dc:	095000ef          	jal	ra,ffffffffc0203e70 <memset>
ffffffffc02035e0:	e0ca                	sd	s2,64(sp)
ffffffffc02035e2:	e4a6                	sd	s1,72(sp)
ffffffffc02035e4:	100027f3          	csrr	a5,sstatus
ffffffffc02035e8:	edd7f793          	andi	a5,a5,-291
ffffffffc02035ec:	1207e793          	ori	a5,a5,288
ffffffffc02035f0:	e23e                	sd	a5,256(sp)
ffffffffc02035f2:	860a                	mv	a2,sp
ffffffffc02035f4:	10046513          	ori	a0,s0,256
ffffffffc02035f8:	00000797          	auipc	a5,0x0
ffffffffc02035fc:	c1078793          	addi	a5,a5,-1008 # ffffffffc0203208 <kernel_thread_entry>
ffffffffc0203600:	4581                	li	a1,0
ffffffffc0203602:	e63e                	sd	a5,264(sp)
ffffffffc0203604:	d55ff0ef          	jal	ra,ffffffffc0203358 <do_fork>
ffffffffc0203608:	70f2                	ld	ra,312(sp)
ffffffffc020360a:	7452                	ld	s0,304(sp)
ffffffffc020360c:	74b2                	ld	s1,296(sp)
ffffffffc020360e:	7912                	ld	s2,288(sp)
ffffffffc0203610:	6131                	addi	sp,sp,320
ffffffffc0203612:	8082                	ret

ffffffffc0203614 <do_exit>:
ffffffffc0203614:	1141                	addi	sp,sp,-16
ffffffffc0203616:	00002617          	auipc	a2,0x2
ffffffffc020361a:	08260613          	addi	a2,a2,130 # ffffffffc0205698 <default_pmm_manager+0x9a8>
ffffffffc020361e:	19000593          	li	a1,400
ffffffffc0203622:	00002517          	auipc	a0,0x2
ffffffffc0203626:	05e50513          	addi	a0,a0,94 # ffffffffc0205680 <default_pmm_manager+0x990>
ffffffffc020362a:	e406                	sd	ra,8(sp)
ffffffffc020362c:	e2ffc0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0203630 <proc_init>:
ffffffffc0203630:	7179                	addi	sp,sp,-48
ffffffffc0203632:	ec26                	sd	s1,24(sp)
ffffffffc0203634:	0000a797          	auipc	a5,0xa
ffffffffc0203638:	e2478793          	addi	a5,a5,-476 # ffffffffc020d458 <proc_list>
ffffffffc020363c:	f406                	sd	ra,40(sp)
ffffffffc020363e:	f022                	sd	s0,32(sp)
ffffffffc0203640:	e84a                	sd	s2,16(sp)
ffffffffc0203642:	e44e                	sd	s3,8(sp)
ffffffffc0203644:	00006497          	auipc	s1,0x6
ffffffffc0203648:	e0448493          	addi	s1,s1,-508 # ffffffffc0209448 <hash_list>
ffffffffc020364c:	e79c                	sd	a5,8(a5)
ffffffffc020364e:	e39c                	sd	a5,0(a5)
ffffffffc0203650:	0000a717          	auipc	a4,0xa
ffffffffc0203654:	df870713          	addi	a4,a4,-520 # ffffffffc020d448 <name.2>
ffffffffc0203658:	87a6                	mv	a5,s1
ffffffffc020365a:	e79c                	sd	a5,8(a5)
ffffffffc020365c:	e39c                	sd	a5,0(a5)
ffffffffc020365e:	07c1                	addi	a5,a5,16
ffffffffc0203660:	fef71de3          	bne	a4,a5,ffffffffc020365a <proc_init+0x2a>
ffffffffc0203664:	badff0ef          	jal	ra,ffffffffc0203210 <alloc_proc>
ffffffffc0203668:	0000a917          	auipc	s2,0xa
ffffffffc020366c:	e7090913          	addi	s2,s2,-400 # ffffffffc020d4d8 <idleproc>
ffffffffc0203670:	00a93023          	sd	a0,0(s2)
ffffffffc0203674:	18050d63          	beqz	a0,ffffffffc020380e <proc_init+0x1de>
ffffffffc0203678:	07000513          	li	a0,112
ffffffffc020367c:	c3efe0ef          	jal	ra,ffffffffc0201aba <kmalloc>
ffffffffc0203680:	07000613          	li	a2,112
ffffffffc0203684:	4581                	li	a1,0
ffffffffc0203686:	842a                	mv	s0,a0
ffffffffc0203688:	7e8000ef          	jal	ra,ffffffffc0203e70 <memset>
ffffffffc020368c:	00093503          	ld	a0,0(s2)
ffffffffc0203690:	85a2                	mv	a1,s0
ffffffffc0203692:	07000613          	li	a2,112
ffffffffc0203696:	04850513          	addi	a0,a0,72
ffffffffc020369a:	001000ef          	jal	ra,ffffffffc0203e9a <memcmp>
ffffffffc020369e:	89aa                	mv	s3,a0
ffffffffc02036a0:	453d                	li	a0,15
ffffffffc02036a2:	c18fe0ef          	jal	ra,ffffffffc0201aba <kmalloc>
ffffffffc02036a6:	463d                	li	a2,15
ffffffffc02036a8:	4581                	li	a1,0
ffffffffc02036aa:	842a                	mv	s0,a0
ffffffffc02036ac:	7c4000ef          	jal	ra,ffffffffc0203e70 <memset>
ffffffffc02036b0:	00093503          	ld	a0,0(s2)
ffffffffc02036b4:	463d                	li	a2,15
ffffffffc02036b6:	85a2                	mv	a1,s0
ffffffffc02036b8:	0cc50513          	addi	a0,a0,204
ffffffffc02036bc:	7de000ef          	jal	ra,ffffffffc0203e9a <memcmp>
ffffffffc02036c0:	00093783          	ld	a5,0(s2)
ffffffffc02036c4:	0000a717          	auipc	a4,0xa
ffffffffc02036c8:	ddc73703          	ld	a4,-548(a4) # ffffffffc020d4a0 <boot_pgdir_pa>
ffffffffc02036cc:	63f4                	ld	a3,192(a5)
ffffffffc02036ce:	0ee68463          	beq	a3,a4,ffffffffc02037b6 <proc_init+0x186>
ffffffffc02036d2:	4709                	li	a4,2
ffffffffc02036d4:	e398                	sd	a4,0(a5)
ffffffffc02036d6:	00003717          	auipc	a4,0x3
ffffffffc02036da:	92a70713          	addi	a4,a4,-1750 # ffffffffc0206000 <bootstack>
ffffffffc02036de:	0cc78413          	addi	s0,a5,204
ffffffffc02036e2:	eb98                	sd	a4,16(a5)
ffffffffc02036e4:	4705                	li	a4,1
ffffffffc02036e6:	cf98                	sw	a4,24(a5)
ffffffffc02036e8:	4641                	li	a2,16
ffffffffc02036ea:	4581                	li	a1,0
ffffffffc02036ec:	8522                	mv	a0,s0
ffffffffc02036ee:	782000ef          	jal	ra,ffffffffc0203e70 <memset>
ffffffffc02036f2:	463d                	li	a2,15
ffffffffc02036f4:	00002597          	auipc	a1,0x2
ffffffffc02036f8:	fec58593          	addi	a1,a1,-20 # ffffffffc02056e0 <default_pmm_manager+0x9f0>
ffffffffc02036fc:	8522                	mv	a0,s0
ffffffffc02036fe:	784000ef          	jal	ra,ffffffffc0203e82 <memcpy>
ffffffffc0203702:	0000a717          	auipc	a4,0xa
ffffffffc0203706:	de670713          	addi	a4,a4,-538 # ffffffffc020d4e8 <nr_process>
ffffffffc020370a:	431c                	lw	a5,0(a4)
ffffffffc020370c:	00093683          	ld	a3,0(s2)
ffffffffc0203710:	4601                	li	a2,0
ffffffffc0203712:	2785                	addiw	a5,a5,1
ffffffffc0203714:	00002597          	auipc	a1,0x2
ffffffffc0203718:	fd458593          	addi	a1,a1,-44 # ffffffffc02056e8 <default_pmm_manager+0x9f8>
ffffffffc020371c:	00000517          	auipc	a0,0x0
ffffffffc0203720:	b6450513          	addi	a0,a0,-1180 # ffffffffc0203280 <init_main>
ffffffffc0203724:	c31c                	sw	a5,0(a4)
ffffffffc0203726:	0000a797          	auipc	a5,0xa
ffffffffc020372a:	dad7b523          	sd	a3,-598(a5) # ffffffffc020d4d0 <current>
ffffffffc020372e:	e97ff0ef          	jal	ra,ffffffffc02035c4 <kernel_thread>
ffffffffc0203732:	842a                	mv	s0,a0
ffffffffc0203734:	0ea05963          	blez	a0,ffffffffc0203826 <proc_init+0x1f6>
ffffffffc0203738:	6789                	lui	a5,0x2
ffffffffc020373a:	fff5071b          	addiw	a4,a0,-1
ffffffffc020373e:	17f9                	addi	a5,a5,-2
ffffffffc0203740:	2501                	sext.w	a0,a0
ffffffffc0203742:	02e7e363          	bltu	a5,a4,ffffffffc0203768 <proc_init+0x138>
ffffffffc0203746:	45a9                	li	a1,10
ffffffffc0203748:	282000ef          	jal	ra,ffffffffc02039ca <hash32>
ffffffffc020374c:	02051793          	slli	a5,a0,0x20
ffffffffc0203750:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0203754:	96a6                	add	a3,a3,s1
ffffffffc0203756:	87b6                	mv	a5,a3
ffffffffc0203758:	a029                	j	ffffffffc0203762 <proc_init+0x132>
ffffffffc020375a:	f147a703          	lw	a4,-236(a5) # 1f14 <kern_entry-0xffffffffc01fe0ec>
ffffffffc020375e:	0a870563          	beq	a4,s0,ffffffffc0203808 <proc_init+0x1d8>
ffffffffc0203762:	679c                	ld	a5,8(a5)
ffffffffc0203764:	fef69be3          	bne	a3,a5,ffffffffc020375a <proc_init+0x12a>
ffffffffc0203768:	4781                	li	a5,0
ffffffffc020376a:	0cc78493          	addi	s1,a5,204
ffffffffc020376e:	4641                	li	a2,16
ffffffffc0203770:	4581                	li	a1,0
ffffffffc0203772:	0000a417          	auipc	s0,0xa
ffffffffc0203776:	d6e40413          	addi	s0,s0,-658 # ffffffffc020d4e0 <initproc>
ffffffffc020377a:	8526                	mv	a0,s1
ffffffffc020377c:	e01c                	sd	a5,0(s0)
ffffffffc020377e:	6f2000ef          	jal	ra,ffffffffc0203e70 <memset>
ffffffffc0203782:	463d                	li	a2,15
ffffffffc0203784:	00002597          	auipc	a1,0x2
ffffffffc0203788:	f9458593          	addi	a1,a1,-108 # ffffffffc0205718 <default_pmm_manager+0xa28>
ffffffffc020378c:	8526                	mv	a0,s1
ffffffffc020378e:	6f4000ef          	jal	ra,ffffffffc0203e82 <memcpy>
ffffffffc0203792:	00093783          	ld	a5,0(s2)
ffffffffc0203796:	c7e1                	beqz	a5,ffffffffc020385e <proc_init+0x22e>
ffffffffc0203798:	43dc                	lw	a5,4(a5)
ffffffffc020379a:	e3f1                	bnez	a5,ffffffffc020385e <proc_init+0x22e>
ffffffffc020379c:	601c                	ld	a5,0(s0)
ffffffffc020379e:	c3c5                	beqz	a5,ffffffffc020383e <proc_init+0x20e>
ffffffffc02037a0:	43d8                	lw	a4,4(a5)
ffffffffc02037a2:	4785                	li	a5,1
ffffffffc02037a4:	08f71d63          	bne	a4,a5,ffffffffc020383e <proc_init+0x20e>
ffffffffc02037a8:	70a2                	ld	ra,40(sp)
ffffffffc02037aa:	7402                	ld	s0,32(sp)
ffffffffc02037ac:	64e2                	ld	s1,24(sp)
ffffffffc02037ae:	6942                	ld	s2,16(sp)
ffffffffc02037b0:	69a2                	ld	s3,8(sp)
ffffffffc02037b2:	6145                	addi	sp,sp,48
ffffffffc02037b4:	8082                	ret
ffffffffc02037b6:	7fd8                	ld	a4,184(a5)
ffffffffc02037b8:	ff09                	bnez	a4,ffffffffc02036d2 <proc_init+0xa2>
ffffffffc02037ba:	f0099ce3          	bnez	s3,ffffffffc02036d2 <proc_init+0xa2>
ffffffffc02037be:	6394                	ld	a3,0(a5)
ffffffffc02037c0:	577d                	li	a4,-1
ffffffffc02037c2:	1702                	slli	a4,a4,0x20
ffffffffc02037c4:	f0e697e3          	bne	a3,a4,ffffffffc02036d2 <proc_init+0xa2>
ffffffffc02037c8:	4798                	lw	a4,8(a5)
ffffffffc02037ca:	f00714e3          	bnez	a4,ffffffffc02036d2 <proc_init+0xa2>
ffffffffc02037ce:	6b98                	ld	a4,16(a5)
ffffffffc02037d0:	f00711e3          	bnez	a4,ffffffffc02036d2 <proc_init+0xa2>
ffffffffc02037d4:	4f98                	lw	a4,24(a5)
ffffffffc02037d6:	2701                	sext.w	a4,a4
ffffffffc02037d8:	ee071de3          	bnez	a4,ffffffffc02036d2 <proc_init+0xa2>
ffffffffc02037dc:	7398                	ld	a4,32(a5)
ffffffffc02037de:	ee071ae3          	bnez	a4,ffffffffc02036d2 <proc_init+0xa2>
ffffffffc02037e2:	63b8                	ld	a4,64(a5)
ffffffffc02037e4:	ee0717e3          	bnez	a4,ffffffffc02036d2 <proc_init+0xa2>
ffffffffc02037e8:	0c87a703          	lw	a4,200(a5)
ffffffffc02037ec:	8d59                	or	a0,a0,a4
ffffffffc02037ee:	0005071b          	sext.w	a4,a0
ffffffffc02037f2:	ee0710e3          	bnez	a4,ffffffffc02036d2 <proc_init+0xa2>
ffffffffc02037f6:	00002517          	auipc	a0,0x2
ffffffffc02037fa:	ed250513          	addi	a0,a0,-302 # ffffffffc02056c8 <default_pmm_manager+0x9d8>
ffffffffc02037fe:	997fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0203802:	00093783          	ld	a5,0(s2)
ffffffffc0203806:	b5f1                	j	ffffffffc02036d2 <proc_init+0xa2>
ffffffffc0203808:	f1078793          	addi	a5,a5,-240
ffffffffc020380c:	bfb9                	j	ffffffffc020376a <proc_init+0x13a>
ffffffffc020380e:	00002617          	auipc	a2,0x2
ffffffffc0203812:	ea260613          	addi	a2,a2,-350 # ffffffffc02056b0 <default_pmm_manager+0x9c0>
ffffffffc0203816:	1ab00593          	li	a1,427
ffffffffc020381a:	00002517          	auipc	a0,0x2
ffffffffc020381e:	e6650513          	addi	a0,a0,-410 # ffffffffc0205680 <default_pmm_manager+0x990>
ffffffffc0203822:	c39fc0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0203826:	00002617          	auipc	a2,0x2
ffffffffc020382a:	ed260613          	addi	a2,a2,-302 # ffffffffc02056f8 <default_pmm_manager+0xa08>
ffffffffc020382e:	1c800593          	li	a1,456
ffffffffc0203832:	00002517          	auipc	a0,0x2
ffffffffc0203836:	e4e50513          	addi	a0,a0,-434 # ffffffffc0205680 <default_pmm_manager+0x990>
ffffffffc020383a:	c21fc0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc020383e:	00002697          	auipc	a3,0x2
ffffffffc0203842:	f0a68693          	addi	a3,a3,-246 # ffffffffc0205748 <default_pmm_manager+0xa58>
ffffffffc0203846:	00001617          	auipc	a2,0x1
ffffffffc020384a:	0f260613          	addi	a2,a2,242 # ffffffffc0204938 <commands+0x810>
ffffffffc020384e:	1cf00593          	li	a1,463
ffffffffc0203852:	00002517          	auipc	a0,0x2
ffffffffc0203856:	e2e50513          	addi	a0,a0,-466 # ffffffffc0205680 <default_pmm_manager+0x990>
ffffffffc020385a:	c01fc0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc020385e:	00002697          	auipc	a3,0x2
ffffffffc0203862:	ec268693          	addi	a3,a3,-318 # ffffffffc0205720 <default_pmm_manager+0xa30>
ffffffffc0203866:	00001617          	auipc	a2,0x1
ffffffffc020386a:	0d260613          	addi	a2,a2,210 # ffffffffc0204938 <commands+0x810>
ffffffffc020386e:	1ce00593          	li	a1,462
ffffffffc0203872:	00002517          	auipc	a0,0x2
ffffffffc0203876:	e0e50513          	addi	a0,a0,-498 # ffffffffc0205680 <default_pmm_manager+0x990>
ffffffffc020387a:	be1fc0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc020387e <cpu_idle>:
ffffffffc020387e:	1141                	addi	sp,sp,-16
ffffffffc0203880:	e022                	sd	s0,0(sp)
ffffffffc0203882:	e406                	sd	ra,8(sp)
ffffffffc0203884:	0000a417          	auipc	s0,0xa
ffffffffc0203888:	c4c40413          	addi	s0,s0,-948 # ffffffffc020d4d0 <current>
ffffffffc020388c:	6018                	ld	a4,0(s0)
ffffffffc020388e:	4f1c                	lw	a5,24(a4)
ffffffffc0203890:	2781                	sext.w	a5,a5
ffffffffc0203892:	dff5                	beqz	a5,ffffffffc020388e <cpu_idle+0x10>
ffffffffc0203894:	0a2000ef          	jal	ra,ffffffffc0203936 <schedule>
ffffffffc0203898:	bfd5                	j	ffffffffc020388c <cpu_idle+0xe>

ffffffffc020389a <switch_to>:
ffffffffc020389a:	00153023          	sd	ra,0(a0)
ffffffffc020389e:	00253423          	sd	sp,8(a0)
ffffffffc02038a2:	e900                	sd	s0,16(a0)
ffffffffc02038a4:	ed04                	sd	s1,24(a0)
ffffffffc02038a6:	03253023          	sd	s2,32(a0)
ffffffffc02038aa:	03353423          	sd	s3,40(a0)
ffffffffc02038ae:	03453823          	sd	s4,48(a0)
ffffffffc02038b2:	03553c23          	sd	s5,56(a0)
ffffffffc02038b6:	05653023          	sd	s6,64(a0)
ffffffffc02038ba:	05753423          	sd	s7,72(a0)
ffffffffc02038be:	05853823          	sd	s8,80(a0)
ffffffffc02038c2:	05953c23          	sd	s9,88(a0)
ffffffffc02038c6:	07a53023          	sd	s10,96(a0)
ffffffffc02038ca:	07b53423          	sd	s11,104(a0)
ffffffffc02038ce:	0005b083          	ld	ra,0(a1)
ffffffffc02038d2:	0085b103          	ld	sp,8(a1)
ffffffffc02038d6:	6980                	ld	s0,16(a1)
ffffffffc02038d8:	6d84                	ld	s1,24(a1)
ffffffffc02038da:	0205b903          	ld	s2,32(a1)
ffffffffc02038de:	0285b983          	ld	s3,40(a1)
ffffffffc02038e2:	0305ba03          	ld	s4,48(a1)
ffffffffc02038e6:	0385ba83          	ld	s5,56(a1)
ffffffffc02038ea:	0405bb03          	ld	s6,64(a1)
ffffffffc02038ee:	0485bb83          	ld	s7,72(a1)
ffffffffc02038f2:	0505bc03          	ld	s8,80(a1)
ffffffffc02038f6:	0585bc83          	ld	s9,88(a1)
ffffffffc02038fa:	0605bd03          	ld	s10,96(a1)
ffffffffc02038fe:	0685bd83          	ld	s11,104(a1)
ffffffffc0203902:	8082                	ret

ffffffffc0203904 <wakeup_proc>:
ffffffffc0203904:	411c                	lw	a5,0(a0)
ffffffffc0203906:	4705                	li	a4,1
ffffffffc0203908:	37f9                	addiw	a5,a5,-2
ffffffffc020390a:	00f77563          	bgeu	a4,a5,ffffffffc0203914 <wakeup_proc+0x10>
ffffffffc020390e:	4789                	li	a5,2
ffffffffc0203910:	c11c                	sw	a5,0(a0)
ffffffffc0203912:	8082                	ret
ffffffffc0203914:	1141                	addi	sp,sp,-16
ffffffffc0203916:	00002697          	auipc	a3,0x2
ffffffffc020391a:	e5a68693          	addi	a3,a3,-422 # ffffffffc0205770 <default_pmm_manager+0xa80>
ffffffffc020391e:	00001617          	auipc	a2,0x1
ffffffffc0203922:	01a60613          	addi	a2,a2,26 # ffffffffc0204938 <commands+0x810>
ffffffffc0203926:	45a5                	li	a1,9
ffffffffc0203928:	00002517          	auipc	a0,0x2
ffffffffc020392c:	e8850513          	addi	a0,a0,-376 # ffffffffc02057b0 <default_pmm_manager+0xac0>
ffffffffc0203930:	e406                	sd	ra,8(sp)
ffffffffc0203932:	b29fc0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0203936 <schedule>:
ffffffffc0203936:	1141                	addi	sp,sp,-16
ffffffffc0203938:	e406                	sd	ra,8(sp)
ffffffffc020393a:	e022                	sd	s0,0(sp)
ffffffffc020393c:	100027f3          	csrr	a5,sstatus
ffffffffc0203940:	8b89                	andi	a5,a5,2
ffffffffc0203942:	4401                	li	s0,0
ffffffffc0203944:	efbd                	bnez	a5,ffffffffc02039c2 <schedule+0x8c>
ffffffffc0203946:	0000a897          	auipc	a7,0xa
ffffffffc020394a:	b8a8b883          	ld	a7,-1142(a7) # ffffffffc020d4d0 <current>
ffffffffc020394e:	0008ac23          	sw	zero,24(a7)
ffffffffc0203952:	0000a517          	auipc	a0,0xa
ffffffffc0203956:	b8653503          	ld	a0,-1146(a0) # ffffffffc020d4d8 <idleproc>
ffffffffc020395a:	04a88e63          	beq	a7,a0,ffffffffc02039b6 <schedule+0x80>
ffffffffc020395e:	0e088693          	addi	a3,a7,224
ffffffffc0203962:	0000a617          	auipc	a2,0xa
ffffffffc0203966:	af660613          	addi	a2,a2,-1290 # ffffffffc020d458 <proc_list>
ffffffffc020396a:	87b6                	mv	a5,a3
ffffffffc020396c:	4581                	li	a1,0
ffffffffc020396e:	4809                	li	a6,2
ffffffffc0203970:	679c                	ld	a5,8(a5)
ffffffffc0203972:	00c78863          	beq	a5,a2,ffffffffc0203982 <schedule+0x4c>
ffffffffc0203976:	f207a703          	lw	a4,-224(a5)
ffffffffc020397a:	f2078593          	addi	a1,a5,-224
ffffffffc020397e:	03070163          	beq	a4,a6,ffffffffc02039a0 <schedule+0x6a>
ffffffffc0203982:	fef697e3          	bne	a3,a5,ffffffffc0203970 <schedule+0x3a>
ffffffffc0203986:	ed89                	bnez	a1,ffffffffc02039a0 <schedule+0x6a>
ffffffffc0203988:	451c                	lw	a5,8(a0)
ffffffffc020398a:	2785                	addiw	a5,a5,1
ffffffffc020398c:	c51c                	sw	a5,8(a0)
ffffffffc020398e:	00a88463          	beq	a7,a0,ffffffffc0203996 <schedule+0x60>
ffffffffc0203992:	961ff0ef          	jal	ra,ffffffffc02032f2 <proc_run>
ffffffffc0203996:	e819                	bnez	s0,ffffffffc02039ac <schedule+0x76>
ffffffffc0203998:	60a2                	ld	ra,8(sp)
ffffffffc020399a:	6402                	ld	s0,0(sp)
ffffffffc020399c:	0141                	addi	sp,sp,16
ffffffffc020399e:	8082                	ret
ffffffffc02039a0:	4198                	lw	a4,0(a1)
ffffffffc02039a2:	4789                	li	a5,2
ffffffffc02039a4:	fef712e3          	bne	a4,a5,ffffffffc0203988 <schedule+0x52>
ffffffffc02039a8:	852e                	mv	a0,a1
ffffffffc02039aa:	bff9                	j	ffffffffc0203988 <schedule+0x52>
ffffffffc02039ac:	6402                	ld	s0,0(sp)
ffffffffc02039ae:	60a2                	ld	ra,8(sp)
ffffffffc02039b0:	0141                	addi	sp,sp,16
ffffffffc02039b2:	f79fc06f          	j	ffffffffc020092a <intr_enable>
ffffffffc02039b6:	0000a617          	auipc	a2,0xa
ffffffffc02039ba:	aa260613          	addi	a2,a2,-1374 # ffffffffc020d458 <proc_list>
ffffffffc02039be:	86b2                	mv	a3,a2
ffffffffc02039c0:	b76d                	j	ffffffffc020396a <schedule+0x34>
ffffffffc02039c2:	f6ffc0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc02039c6:	4405                	li	s0,1
ffffffffc02039c8:	bfbd                	j	ffffffffc0203946 <schedule+0x10>

ffffffffc02039ca <hash32>:
ffffffffc02039ca:	9e3707b7          	lui	a5,0x9e370
ffffffffc02039ce:	2785                	addiw	a5,a5,1
ffffffffc02039d0:	02a7853b          	mulw	a0,a5,a0
ffffffffc02039d4:	02000793          	li	a5,32
ffffffffc02039d8:	9f8d                	subw	a5,a5,a1
ffffffffc02039da:	00f5553b          	srlw	a0,a0,a5
ffffffffc02039de:	8082                	ret

ffffffffc02039e0 <printnum>:
ffffffffc02039e0:	02069813          	slli	a6,a3,0x20
ffffffffc02039e4:	7179                	addi	sp,sp,-48
ffffffffc02039e6:	02085813          	srli	a6,a6,0x20
ffffffffc02039ea:	e052                	sd	s4,0(sp)
ffffffffc02039ec:	03067a33          	remu	s4,a2,a6
ffffffffc02039f0:	f022                	sd	s0,32(sp)
ffffffffc02039f2:	ec26                	sd	s1,24(sp)
ffffffffc02039f4:	e84a                	sd	s2,16(sp)
ffffffffc02039f6:	f406                	sd	ra,40(sp)
ffffffffc02039f8:	e44e                	sd	s3,8(sp)
ffffffffc02039fa:	84aa                	mv	s1,a0
ffffffffc02039fc:	892e                	mv	s2,a1
ffffffffc02039fe:	fff7041b          	addiw	s0,a4,-1
ffffffffc0203a02:	2a01                	sext.w	s4,s4
ffffffffc0203a04:	03067e63          	bgeu	a2,a6,ffffffffc0203a40 <printnum+0x60>
ffffffffc0203a08:	89be                	mv	s3,a5
ffffffffc0203a0a:	00805763          	blez	s0,ffffffffc0203a18 <printnum+0x38>
ffffffffc0203a0e:	347d                	addiw	s0,s0,-1
ffffffffc0203a10:	85ca                	mv	a1,s2
ffffffffc0203a12:	854e                	mv	a0,s3
ffffffffc0203a14:	9482                	jalr	s1
ffffffffc0203a16:	fc65                	bnez	s0,ffffffffc0203a0e <printnum+0x2e>
ffffffffc0203a18:	1a02                	slli	s4,s4,0x20
ffffffffc0203a1a:	00002797          	auipc	a5,0x2
ffffffffc0203a1e:	dae78793          	addi	a5,a5,-594 # ffffffffc02057c8 <default_pmm_manager+0xad8>
ffffffffc0203a22:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203a26:	9a3e                	add	s4,s4,a5
ffffffffc0203a28:	7402                	ld	s0,32(sp)
ffffffffc0203a2a:	000a4503          	lbu	a0,0(s4)
ffffffffc0203a2e:	70a2                	ld	ra,40(sp)
ffffffffc0203a30:	69a2                	ld	s3,8(sp)
ffffffffc0203a32:	6a02                	ld	s4,0(sp)
ffffffffc0203a34:	85ca                	mv	a1,s2
ffffffffc0203a36:	87a6                	mv	a5,s1
ffffffffc0203a38:	6942                	ld	s2,16(sp)
ffffffffc0203a3a:	64e2                	ld	s1,24(sp)
ffffffffc0203a3c:	6145                	addi	sp,sp,48
ffffffffc0203a3e:	8782                	jr	a5
ffffffffc0203a40:	03065633          	divu	a2,a2,a6
ffffffffc0203a44:	8722                	mv	a4,s0
ffffffffc0203a46:	f9bff0ef          	jal	ra,ffffffffc02039e0 <printnum>
ffffffffc0203a4a:	b7f9                	j	ffffffffc0203a18 <printnum+0x38>

ffffffffc0203a4c <vprintfmt>:
ffffffffc0203a4c:	7119                	addi	sp,sp,-128
ffffffffc0203a4e:	f4a6                	sd	s1,104(sp)
ffffffffc0203a50:	f0ca                	sd	s2,96(sp)
ffffffffc0203a52:	ecce                	sd	s3,88(sp)
ffffffffc0203a54:	e8d2                	sd	s4,80(sp)
ffffffffc0203a56:	e4d6                	sd	s5,72(sp)
ffffffffc0203a58:	e0da                	sd	s6,64(sp)
ffffffffc0203a5a:	fc5e                	sd	s7,56(sp)
ffffffffc0203a5c:	f06a                	sd	s10,32(sp)
ffffffffc0203a5e:	fc86                	sd	ra,120(sp)
ffffffffc0203a60:	f8a2                	sd	s0,112(sp)
ffffffffc0203a62:	f862                	sd	s8,48(sp)
ffffffffc0203a64:	f466                	sd	s9,40(sp)
ffffffffc0203a66:	ec6e                	sd	s11,24(sp)
ffffffffc0203a68:	892a                	mv	s2,a0
ffffffffc0203a6a:	84ae                	mv	s1,a1
ffffffffc0203a6c:	8d32                	mv	s10,a2
ffffffffc0203a6e:	8a36                	mv	s4,a3
ffffffffc0203a70:	02500993          	li	s3,37
ffffffffc0203a74:	5b7d                	li	s6,-1
ffffffffc0203a76:	00002a97          	auipc	s5,0x2
ffffffffc0203a7a:	d7ea8a93          	addi	s5,s5,-642 # ffffffffc02057f4 <default_pmm_manager+0xb04>
ffffffffc0203a7e:	00002b97          	auipc	s7,0x2
ffffffffc0203a82:	f52b8b93          	addi	s7,s7,-174 # ffffffffc02059d0 <error_string>
ffffffffc0203a86:	000d4503          	lbu	a0,0(s10)
ffffffffc0203a8a:	001d0413          	addi	s0,s10,1
ffffffffc0203a8e:	01350a63          	beq	a0,s3,ffffffffc0203aa2 <vprintfmt+0x56>
ffffffffc0203a92:	c121                	beqz	a0,ffffffffc0203ad2 <vprintfmt+0x86>
ffffffffc0203a94:	85a6                	mv	a1,s1
ffffffffc0203a96:	0405                	addi	s0,s0,1
ffffffffc0203a98:	9902                	jalr	s2
ffffffffc0203a9a:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203a9e:	ff351ae3          	bne	a0,s3,ffffffffc0203a92 <vprintfmt+0x46>
ffffffffc0203aa2:	00044603          	lbu	a2,0(s0)
ffffffffc0203aa6:	02000793          	li	a5,32
ffffffffc0203aaa:	4c81                	li	s9,0
ffffffffc0203aac:	4881                	li	a7,0
ffffffffc0203aae:	5c7d                	li	s8,-1
ffffffffc0203ab0:	5dfd                	li	s11,-1
ffffffffc0203ab2:	05500513          	li	a0,85
ffffffffc0203ab6:	4825                	li	a6,9
ffffffffc0203ab8:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0203abc:	0ff5f593          	zext.b	a1,a1
ffffffffc0203ac0:	00140d13          	addi	s10,s0,1
ffffffffc0203ac4:	04b56263          	bltu	a0,a1,ffffffffc0203b08 <vprintfmt+0xbc>
ffffffffc0203ac8:	058a                	slli	a1,a1,0x2
ffffffffc0203aca:	95d6                	add	a1,a1,s5
ffffffffc0203acc:	4194                	lw	a3,0(a1)
ffffffffc0203ace:	96d6                	add	a3,a3,s5
ffffffffc0203ad0:	8682                	jr	a3
ffffffffc0203ad2:	70e6                	ld	ra,120(sp)
ffffffffc0203ad4:	7446                	ld	s0,112(sp)
ffffffffc0203ad6:	74a6                	ld	s1,104(sp)
ffffffffc0203ad8:	7906                	ld	s2,96(sp)
ffffffffc0203ada:	69e6                	ld	s3,88(sp)
ffffffffc0203adc:	6a46                	ld	s4,80(sp)
ffffffffc0203ade:	6aa6                	ld	s5,72(sp)
ffffffffc0203ae0:	6b06                	ld	s6,64(sp)
ffffffffc0203ae2:	7be2                	ld	s7,56(sp)
ffffffffc0203ae4:	7c42                	ld	s8,48(sp)
ffffffffc0203ae6:	7ca2                	ld	s9,40(sp)
ffffffffc0203ae8:	7d02                	ld	s10,32(sp)
ffffffffc0203aea:	6de2                	ld	s11,24(sp)
ffffffffc0203aec:	6109                	addi	sp,sp,128
ffffffffc0203aee:	8082                	ret
ffffffffc0203af0:	87b2                	mv	a5,a2
ffffffffc0203af2:	00144603          	lbu	a2,1(s0)
ffffffffc0203af6:	846a                	mv	s0,s10
ffffffffc0203af8:	00140d13          	addi	s10,s0,1
ffffffffc0203afc:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0203b00:	0ff5f593          	zext.b	a1,a1
ffffffffc0203b04:	fcb572e3          	bgeu	a0,a1,ffffffffc0203ac8 <vprintfmt+0x7c>
ffffffffc0203b08:	85a6                	mv	a1,s1
ffffffffc0203b0a:	02500513          	li	a0,37
ffffffffc0203b0e:	9902                	jalr	s2
ffffffffc0203b10:	fff44783          	lbu	a5,-1(s0)
ffffffffc0203b14:	8d22                	mv	s10,s0
ffffffffc0203b16:	f73788e3          	beq	a5,s3,ffffffffc0203a86 <vprintfmt+0x3a>
ffffffffc0203b1a:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0203b1e:	1d7d                	addi	s10,s10,-1
ffffffffc0203b20:	ff379de3          	bne	a5,s3,ffffffffc0203b1a <vprintfmt+0xce>
ffffffffc0203b24:	b78d                	j	ffffffffc0203a86 <vprintfmt+0x3a>
ffffffffc0203b26:	fd060c1b          	addiw	s8,a2,-48
ffffffffc0203b2a:	00144603          	lbu	a2,1(s0)
ffffffffc0203b2e:	846a                	mv	s0,s10
ffffffffc0203b30:	fd06069b          	addiw	a3,a2,-48
ffffffffc0203b34:	0006059b          	sext.w	a1,a2
ffffffffc0203b38:	02d86463          	bltu	a6,a3,ffffffffc0203b60 <vprintfmt+0x114>
ffffffffc0203b3c:	00144603          	lbu	a2,1(s0)
ffffffffc0203b40:	002c169b          	slliw	a3,s8,0x2
ffffffffc0203b44:	0186873b          	addw	a4,a3,s8
ffffffffc0203b48:	0017171b          	slliw	a4,a4,0x1
ffffffffc0203b4c:	9f2d                	addw	a4,a4,a1
ffffffffc0203b4e:	fd06069b          	addiw	a3,a2,-48
ffffffffc0203b52:	0405                	addi	s0,s0,1
ffffffffc0203b54:	fd070c1b          	addiw	s8,a4,-48
ffffffffc0203b58:	0006059b          	sext.w	a1,a2
ffffffffc0203b5c:	fed870e3          	bgeu	a6,a3,ffffffffc0203b3c <vprintfmt+0xf0>
ffffffffc0203b60:	f40ddce3          	bgez	s11,ffffffffc0203ab8 <vprintfmt+0x6c>
ffffffffc0203b64:	8de2                	mv	s11,s8
ffffffffc0203b66:	5c7d                	li	s8,-1
ffffffffc0203b68:	bf81                	j	ffffffffc0203ab8 <vprintfmt+0x6c>
ffffffffc0203b6a:	fffdc693          	not	a3,s11
ffffffffc0203b6e:	96fd                	srai	a3,a3,0x3f
ffffffffc0203b70:	00ddfdb3          	and	s11,s11,a3
ffffffffc0203b74:	00144603          	lbu	a2,1(s0)
ffffffffc0203b78:	2d81                	sext.w	s11,s11
ffffffffc0203b7a:	846a                	mv	s0,s10
ffffffffc0203b7c:	bf35                	j	ffffffffc0203ab8 <vprintfmt+0x6c>
ffffffffc0203b7e:	000a2c03          	lw	s8,0(s4)
ffffffffc0203b82:	00144603          	lbu	a2,1(s0)
ffffffffc0203b86:	0a21                	addi	s4,s4,8
ffffffffc0203b88:	846a                	mv	s0,s10
ffffffffc0203b8a:	bfd9                	j	ffffffffc0203b60 <vprintfmt+0x114>
ffffffffc0203b8c:	4705                	li	a4,1
ffffffffc0203b8e:	008a0593          	addi	a1,s4,8
ffffffffc0203b92:	01174463          	blt	a4,a7,ffffffffc0203b9a <vprintfmt+0x14e>
ffffffffc0203b96:	1a088e63          	beqz	a7,ffffffffc0203d52 <vprintfmt+0x306>
ffffffffc0203b9a:	000a3603          	ld	a2,0(s4)
ffffffffc0203b9e:	46c1                	li	a3,16
ffffffffc0203ba0:	8a2e                	mv	s4,a1
ffffffffc0203ba2:	2781                	sext.w	a5,a5
ffffffffc0203ba4:	876e                	mv	a4,s11
ffffffffc0203ba6:	85a6                	mv	a1,s1
ffffffffc0203ba8:	854a                	mv	a0,s2
ffffffffc0203baa:	e37ff0ef          	jal	ra,ffffffffc02039e0 <printnum>
ffffffffc0203bae:	bde1                	j	ffffffffc0203a86 <vprintfmt+0x3a>
ffffffffc0203bb0:	000a2503          	lw	a0,0(s4)
ffffffffc0203bb4:	85a6                	mv	a1,s1
ffffffffc0203bb6:	0a21                	addi	s4,s4,8
ffffffffc0203bb8:	9902                	jalr	s2
ffffffffc0203bba:	b5f1                	j	ffffffffc0203a86 <vprintfmt+0x3a>
ffffffffc0203bbc:	4705                	li	a4,1
ffffffffc0203bbe:	008a0593          	addi	a1,s4,8
ffffffffc0203bc2:	01174463          	blt	a4,a7,ffffffffc0203bca <vprintfmt+0x17e>
ffffffffc0203bc6:	18088163          	beqz	a7,ffffffffc0203d48 <vprintfmt+0x2fc>
ffffffffc0203bca:	000a3603          	ld	a2,0(s4)
ffffffffc0203bce:	46a9                	li	a3,10
ffffffffc0203bd0:	8a2e                	mv	s4,a1
ffffffffc0203bd2:	bfc1                	j	ffffffffc0203ba2 <vprintfmt+0x156>
ffffffffc0203bd4:	00144603          	lbu	a2,1(s0)
ffffffffc0203bd8:	4c85                	li	s9,1
ffffffffc0203bda:	846a                	mv	s0,s10
ffffffffc0203bdc:	bdf1                	j	ffffffffc0203ab8 <vprintfmt+0x6c>
ffffffffc0203bde:	85a6                	mv	a1,s1
ffffffffc0203be0:	02500513          	li	a0,37
ffffffffc0203be4:	9902                	jalr	s2
ffffffffc0203be6:	b545                	j	ffffffffc0203a86 <vprintfmt+0x3a>
ffffffffc0203be8:	00144603          	lbu	a2,1(s0)
ffffffffc0203bec:	2885                	addiw	a7,a7,1
ffffffffc0203bee:	846a                	mv	s0,s10
ffffffffc0203bf0:	b5e1                	j	ffffffffc0203ab8 <vprintfmt+0x6c>
ffffffffc0203bf2:	4705                	li	a4,1
ffffffffc0203bf4:	008a0593          	addi	a1,s4,8
ffffffffc0203bf8:	01174463          	blt	a4,a7,ffffffffc0203c00 <vprintfmt+0x1b4>
ffffffffc0203bfc:	14088163          	beqz	a7,ffffffffc0203d3e <vprintfmt+0x2f2>
ffffffffc0203c00:	000a3603          	ld	a2,0(s4)
ffffffffc0203c04:	46a1                	li	a3,8
ffffffffc0203c06:	8a2e                	mv	s4,a1
ffffffffc0203c08:	bf69                	j	ffffffffc0203ba2 <vprintfmt+0x156>
ffffffffc0203c0a:	03000513          	li	a0,48
ffffffffc0203c0e:	85a6                	mv	a1,s1
ffffffffc0203c10:	e03e                	sd	a5,0(sp)
ffffffffc0203c12:	9902                	jalr	s2
ffffffffc0203c14:	85a6                	mv	a1,s1
ffffffffc0203c16:	07800513          	li	a0,120
ffffffffc0203c1a:	9902                	jalr	s2
ffffffffc0203c1c:	0a21                	addi	s4,s4,8
ffffffffc0203c1e:	6782                	ld	a5,0(sp)
ffffffffc0203c20:	46c1                	li	a3,16
ffffffffc0203c22:	ff8a3603          	ld	a2,-8(s4)
ffffffffc0203c26:	bfb5                	j	ffffffffc0203ba2 <vprintfmt+0x156>
ffffffffc0203c28:	000a3403          	ld	s0,0(s4)
ffffffffc0203c2c:	008a0713          	addi	a4,s4,8
ffffffffc0203c30:	e03a                	sd	a4,0(sp)
ffffffffc0203c32:	14040263          	beqz	s0,ffffffffc0203d76 <vprintfmt+0x32a>
ffffffffc0203c36:	0fb05763          	blez	s11,ffffffffc0203d24 <vprintfmt+0x2d8>
ffffffffc0203c3a:	02d00693          	li	a3,45
ffffffffc0203c3e:	0cd79163          	bne	a5,a3,ffffffffc0203d00 <vprintfmt+0x2b4>
ffffffffc0203c42:	00044783          	lbu	a5,0(s0)
ffffffffc0203c46:	0007851b          	sext.w	a0,a5
ffffffffc0203c4a:	cf85                	beqz	a5,ffffffffc0203c82 <vprintfmt+0x236>
ffffffffc0203c4c:	00140a13          	addi	s4,s0,1
ffffffffc0203c50:	05e00413          	li	s0,94
ffffffffc0203c54:	000c4563          	bltz	s8,ffffffffc0203c5e <vprintfmt+0x212>
ffffffffc0203c58:	3c7d                	addiw	s8,s8,-1
ffffffffc0203c5a:	036c0263          	beq	s8,s6,ffffffffc0203c7e <vprintfmt+0x232>
ffffffffc0203c5e:	85a6                	mv	a1,s1
ffffffffc0203c60:	0e0c8e63          	beqz	s9,ffffffffc0203d5c <vprintfmt+0x310>
ffffffffc0203c64:	3781                	addiw	a5,a5,-32
ffffffffc0203c66:	0ef47b63          	bgeu	s0,a5,ffffffffc0203d5c <vprintfmt+0x310>
ffffffffc0203c6a:	03f00513          	li	a0,63
ffffffffc0203c6e:	9902                	jalr	s2
ffffffffc0203c70:	000a4783          	lbu	a5,0(s4)
ffffffffc0203c74:	3dfd                	addiw	s11,s11,-1
ffffffffc0203c76:	0a05                	addi	s4,s4,1
ffffffffc0203c78:	0007851b          	sext.w	a0,a5
ffffffffc0203c7c:	ffe1                	bnez	a5,ffffffffc0203c54 <vprintfmt+0x208>
ffffffffc0203c7e:	01b05963          	blez	s11,ffffffffc0203c90 <vprintfmt+0x244>
ffffffffc0203c82:	3dfd                	addiw	s11,s11,-1
ffffffffc0203c84:	85a6                	mv	a1,s1
ffffffffc0203c86:	02000513          	li	a0,32
ffffffffc0203c8a:	9902                	jalr	s2
ffffffffc0203c8c:	fe0d9be3          	bnez	s11,ffffffffc0203c82 <vprintfmt+0x236>
ffffffffc0203c90:	6a02                	ld	s4,0(sp)
ffffffffc0203c92:	bbd5                	j	ffffffffc0203a86 <vprintfmt+0x3a>
ffffffffc0203c94:	4705                	li	a4,1
ffffffffc0203c96:	008a0c93          	addi	s9,s4,8
ffffffffc0203c9a:	01174463          	blt	a4,a7,ffffffffc0203ca2 <vprintfmt+0x256>
ffffffffc0203c9e:	08088d63          	beqz	a7,ffffffffc0203d38 <vprintfmt+0x2ec>
ffffffffc0203ca2:	000a3403          	ld	s0,0(s4)
ffffffffc0203ca6:	0a044d63          	bltz	s0,ffffffffc0203d60 <vprintfmt+0x314>
ffffffffc0203caa:	8622                	mv	a2,s0
ffffffffc0203cac:	8a66                	mv	s4,s9
ffffffffc0203cae:	46a9                	li	a3,10
ffffffffc0203cb0:	bdcd                	j	ffffffffc0203ba2 <vprintfmt+0x156>
ffffffffc0203cb2:	000a2783          	lw	a5,0(s4)
ffffffffc0203cb6:	4719                	li	a4,6
ffffffffc0203cb8:	0a21                	addi	s4,s4,8
ffffffffc0203cba:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203cbe:	8fb5                	xor	a5,a5,a3
ffffffffc0203cc0:	40d786bb          	subw	a3,a5,a3
ffffffffc0203cc4:	02d74163          	blt	a4,a3,ffffffffc0203ce6 <vprintfmt+0x29a>
ffffffffc0203cc8:	00369793          	slli	a5,a3,0x3
ffffffffc0203ccc:	97de                	add	a5,a5,s7
ffffffffc0203cce:	639c                	ld	a5,0(a5)
ffffffffc0203cd0:	cb99                	beqz	a5,ffffffffc0203ce6 <vprintfmt+0x29a>
ffffffffc0203cd2:	86be                	mv	a3,a5
ffffffffc0203cd4:	00000617          	auipc	a2,0x0
ffffffffc0203cd8:	21460613          	addi	a2,a2,532 # ffffffffc0203ee8 <etext+0x2a>
ffffffffc0203cdc:	85a6                	mv	a1,s1
ffffffffc0203cde:	854a                	mv	a0,s2
ffffffffc0203ce0:	0ce000ef          	jal	ra,ffffffffc0203dae <printfmt>
ffffffffc0203ce4:	b34d                	j	ffffffffc0203a86 <vprintfmt+0x3a>
ffffffffc0203ce6:	00002617          	auipc	a2,0x2
ffffffffc0203cea:	b0260613          	addi	a2,a2,-1278 # ffffffffc02057e8 <default_pmm_manager+0xaf8>
ffffffffc0203cee:	85a6                	mv	a1,s1
ffffffffc0203cf0:	854a                	mv	a0,s2
ffffffffc0203cf2:	0bc000ef          	jal	ra,ffffffffc0203dae <printfmt>
ffffffffc0203cf6:	bb41                	j	ffffffffc0203a86 <vprintfmt+0x3a>
ffffffffc0203cf8:	00002417          	auipc	s0,0x2
ffffffffc0203cfc:	ae840413          	addi	s0,s0,-1304 # ffffffffc02057e0 <default_pmm_manager+0xaf0>
ffffffffc0203d00:	85e2                	mv	a1,s8
ffffffffc0203d02:	8522                	mv	a0,s0
ffffffffc0203d04:	e43e                	sd	a5,8(sp)
ffffffffc0203d06:	0e2000ef          	jal	ra,ffffffffc0203de8 <strnlen>
ffffffffc0203d0a:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0203d0e:	01b05b63          	blez	s11,ffffffffc0203d24 <vprintfmt+0x2d8>
ffffffffc0203d12:	67a2                	ld	a5,8(sp)
ffffffffc0203d14:	00078a1b          	sext.w	s4,a5
ffffffffc0203d18:	3dfd                	addiw	s11,s11,-1
ffffffffc0203d1a:	85a6                	mv	a1,s1
ffffffffc0203d1c:	8552                	mv	a0,s4
ffffffffc0203d1e:	9902                	jalr	s2
ffffffffc0203d20:	fe0d9ce3          	bnez	s11,ffffffffc0203d18 <vprintfmt+0x2cc>
ffffffffc0203d24:	00044783          	lbu	a5,0(s0)
ffffffffc0203d28:	00140a13          	addi	s4,s0,1
ffffffffc0203d2c:	0007851b          	sext.w	a0,a5
ffffffffc0203d30:	d3a5                	beqz	a5,ffffffffc0203c90 <vprintfmt+0x244>
ffffffffc0203d32:	05e00413          	li	s0,94
ffffffffc0203d36:	bf39                	j	ffffffffc0203c54 <vprintfmt+0x208>
ffffffffc0203d38:	000a2403          	lw	s0,0(s4)
ffffffffc0203d3c:	b7ad                	j	ffffffffc0203ca6 <vprintfmt+0x25a>
ffffffffc0203d3e:	000a6603          	lwu	a2,0(s4)
ffffffffc0203d42:	46a1                	li	a3,8
ffffffffc0203d44:	8a2e                	mv	s4,a1
ffffffffc0203d46:	bdb1                	j	ffffffffc0203ba2 <vprintfmt+0x156>
ffffffffc0203d48:	000a6603          	lwu	a2,0(s4)
ffffffffc0203d4c:	46a9                	li	a3,10
ffffffffc0203d4e:	8a2e                	mv	s4,a1
ffffffffc0203d50:	bd89                	j	ffffffffc0203ba2 <vprintfmt+0x156>
ffffffffc0203d52:	000a6603          	lwu	a2,0(s4)
ffffffffc0203d56:	46c1                	li	a3,16
ffffffffc0203d58:	8a2e                	mv	s4,a1
ffffffffc0203d5a:	b5a1                	j	ffffffffc0203ba2 <vprintfmt+0x156>
ffffffffc0203d5c:	9902                	jalr	s2
ffffffffc0203d5e:	bf09                	j	ffffffffc0203c70 <vprintfmt+0x224>
ffffffffc0203d60:	85a6                	mv	a1,s1
ffffffffc0203d62:	02d00513          	li	a0,45
ffffffffc0203d66:	e03e                	sd	a5,0(sp)
ffffffffc0203d68:	9902                	jalr	s2
ffffffffc0203d6a:	6782                	ld	a5,0(sp)
ffffffffc0203d6c:	8a66                	mv	s4,s9
ffffffffc0203d6e:	40800633          	neg	a2,s0
ffffffffc0203d72:	46a9                	li	a3,10
ffffffffc0203d74:	b53d                	j	ffffffffc0203ba2 <vprintfmt+0x156>
ffffffffc0203d76:	03b05163          	blez	s11,ffffffffc0203d98 <vprintfmt+0x34c>
ffffffffc0203d7a:	02d00693          	li	a3,45
ffffffffc0203d7e:	f6d79de3          	bne	a5,a3,ffffffffc0203cf8 <vprintfmt+0x2ac>
ffffffffc0203d82:	00002417          	auipc	s0,0x2
ffffffffc0203d86:	a5e40413          	addi	s0,s0,-1442 # ffffffffc02057e0 <default_pmm_manager+0xaf0>
ffffffffc0203d8a:	02800793          	li	a5,40
ffffffffc0203d8e:	02800513          	li	a0,40
ffffffffc0203d92:	00140a13          	addi	s4,s0,1
ffffffffc0203d96:	bd6d                	j	ffffffffc0203c50 <vprintfmt+0x204>
ffffffffc0203d98:	00002a17          	auipc	s4,0x2
ffffffffc0203d9c:	a49a0a13          	addi	s4,s4,-1463 # ffffffffc02057e1 <default_pmm_manager+0xaf1>
ffffffffc0203da0:	02800513          	li	a0,40
ffffffffc0203da4:	02800793          	li	a5,40
ffffffffc0203da8:	05e00413          	li	s0,94
ffffffffc0203dac:	b565                	j	ffffffffc0203c54 <vprintfmt+0x208>

ffffffffc0203dae <printfmt>:
ffffffffc0203dae:	715d                	addi	sp,sp,-80
ffffffffc0203db0:	02810313          	addi	t1,sp,40
ffffffffc0203db4:	f436                	sd	a3,40(sp)
ffffffffc0203db6:	869a                	mv	a3,t1
ffffffffc0203db8:	ec06                	sd	ra,24(sp)
ffffffffc0203dba:	f83a                	sd	a4,48(sp)
ffffffffc0203dbc:	fc3e                	sd	a5,56(sp)
ffffffffc0203dbe:	e0c2                	sd	a6,64(sp)
ffffffffc0203dc0:	e4c6                	sd	a7,72(sp)
ffffffffc0203dc2:	e41a                	sd	t1,8(sp)
ffffffffc0203dc4:	c89ff0ef          	jal	ra,ffffffffc0203a4c <vprintfmt>
ffffffffc0203dc8:	60e2                	ld	ra,24(sp)
ffffffffc0203dca:	6161                	addi	sp,sp,80
ffffffffc0203dcc:	8082                	ret

ffffffffc0203dce <strlen>:
ffffffffc0203dce:	00054783          	lbu	a5,0(a0)
ffffffffc0203dd2:	872a                	mv	a4,a0
ffffffffc0203dd4:	4501                	li	a0,0
ffffffffc0203dd6:	cb81                	beqz	a5,ffffffffc0203de6 <strlen+0x18>
ffffffffc0203dd8:	0505                	addi	a0,a0,1
ffffffffc0203dda:	00a707b3          	add	a5,a4,a0
ffffffffc0203dde:	0007c783          	lbu	a5,0(a5)
ffffffffc0203de2:	fbfd                	bnez	a5,ffffffffc0203dd8 <strlen+0xa>
ffffffffc0203de4:	8082                	ret
ffffffffc0203de6:	8082                	ret

ffffffffc0203de8 <strnlen>:
ffffffffc0203de8:	4781                	li	a5,0
ffffffffc0203dea:	e589                	bnez	a1,ffffffffc0203df4 <strnlen+0xc>
ffffffffc0203dec:	a811                	j	ffffffffc0203e00 <strnlen+0x18>
ffffffffc0203dee:	0785                	addi	a5,a5,1
ffffffffc0203df0:	00f58863          	beq	a1,a5,ffffffffc0203e00 <strnlen+0x18>
ffffffffc0203df4:	00f50733          	add	a4,a0,a5
ffffffffc0203df8:	00074703          	lbu	a4,0(a4)
ffffffffc0203dfc:	fb6d                	bnez	a4,ffffffffc0203dee <strnlen+0x6>
ffffffffc0203dfe:	85be                	mv	a1,a5
ffffffffc0203e00:	852e                	mv	a0,a1
ffffffffc0203e02:	8082                	ret

ffffffffc0203e04 <strcpy>:
ffffffffc0203e04:	87aa                	mv	a5,a0
ffffffffc0203e06:	0005c703          	lbu	a4,0(a1)
ffffffffc0203e0a:	0785                	addi	a5,a5,1
ffffffffc0203e0c:	0585                	addi	a1,a1,1
ffffffffc0203e0e:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203e12:	fb75                	bnez	a4,ffffffffc0203e06 <strcpy+0x2>
ffffffffc0203e14:	8082                	ret

ffffffffc0203e16 <strcmp>:
ffffffffc0203e16:	00054783          	lbu	a5,0(a0)
ffffffffc0203e1a:	0005c703          	lbu	a4,0(a1)
ffffffffc0203e1e:	cb89                	beqz	a5,ffffffffc0203e30 <strcmp+0x1a>
ffffffffc0203e20:	0505                	addi	a0,a0,1
ffffffffc0203e22:	0585                	addi	a1,a1,1
ffffffffc0203e24:	fee789e3          	beq	a5,a4,ffffffffc0203e16 <strcmp>
ffffffffc0203e28:	0007851b          	sext.w	a0,a5
ffffffffc0203e2c:	9d19                	subw	a0,a0,a4
ffffffffc0203e2e:	8082                	ret
ffffffffc0203e30:	4501                	li	a0,0
ffffffffc0203e32:	bfed                	j	ffffffffc0203e2c <strcmp+0x16>

ffffffffc0203e34 <strncmp>:
ffffffffc0203e34:	c20d                	beqz	a2,ffffffffc0203e56 <strncmp+0x22>
ffffffffc0203e36:	962e                	add	a2,a2,a1
ffffffffc0203e38:	a031                	j	ffffffffc0203e44 <strncmp+0x10>
ffffffffc0203e3a:	0505                	addi	a0,a0,1
ffffffffc0203e3c:	00e79a63          	bne	a5,a4,ffffffffc0203e50 <strncmp+0x1c>
ffffffffc0203e40:	00b60b63          	beq	a2,a1,ffffffffc0203e56 <strncmp+0x22>
ffffffffc0203e44:	00054783          	lbu	a5,0(a0)
ffffffffc0203e48:	0585                	addi	a1,a1,1
ffffffffc0203e4a:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0203e4e:	f7f5                	bnez	a5,ffffffffc0203e3a <strncmp+0x6>
ffffffffc0203e50:	40e7853b          	subw	a0,a5,a4
ffffffffc0203e54:	8082                	ret
ffffffffc0203e56:	4501                	li	a0,0
ffffffffc0203e58:	8082                	ret

ffffffffc0203e5a <strchr>:
ffffffffc0203e5a:	00054783          	lbu	a5,0(a0)
ffffffffc0203e5e:	c799                	beqz	a5,ffffffffc0203e6c <strchr+0x12>
ffffffffc0203e60:	00f58763          	beq	a1,a5,ffffffffc0203e6e <strchr+0x14>
ffffffffc0203e64:	00154783          	lbu	a5,1(a0)
ffffffffc0203e68:	0505                	addi	a0,a0,1
ffffffffc0203e6a:	fbfd                	bnez	a5,ffffffffc0203e60 <strchr+0x6>
ffffffffc0203e6c:	4501                	li	a0,0
ffffffffc0203e6e:	8082                	ret

ffffffffc0203e70 <memset>:
ffffffffc0203e70:	ca01                	beqz	a2,ffffffffc0203e80 <memset+0x10>
ffffffffc0203e72:	962a                	add	a2,a2,a0
ffffffffc0203e74:	87aa                	mv	a5,a0
ffffffffc0203e76:	0785                	addi	a5,a5,1
ffffffffc0203e78:	feb78fa3          	sb	a1,-1(a5)
ffffffffc0203e7c:	fec79de3          	bne	a5,a2,ffffffffc0203e76 <memset+0x6>
ffffffffc0203e80:	8082                	ret

ffffffffc0203e82 <memcpy>:
ffffffffc0203e82:	ca19                	beqz	a2,ffffffffc0203e98 <memcpy+0x16>
ffffffffc0203e84:	962e                	add	a2,a2,a1
ffffffffc0203e86:	87aa                	mv	a5,a0
ffffffffc0203e88:	0005c703          	lbu	a4,0(a1)
ffffffffc0203e8c:	0585                	addi	a1,a1,1
ffffffffc0203e8e:	0785                	addi	a5,a5,1
ffffffffc0203e90:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203e94:	fec59ae3          	bne	a1,a2,ffffffffc0203e88 <memcpy+0x6>
ffffffffc0203e98:	8082                	ret

ffffffffc0203e9a <memcmp>:
ffffffffc0203e9a:	c205                	beqz	a2,ffffffffc0203eba <memcmp+0x20>
ffffffffc0203e9c:	962e                	add	a2,a2,a1
ffffffffc0203e9e:	a019                	j	ffffffffc0203ea4 <memcmp+0xa>
ffffffffc0203ea0:	00c58d63          	beq	a1,a2,ffffffffc0203eba <memcmp+0x20>
ffffffffc0203ea4:	00054783          	lbu	a5,0(a0)
ffffffffc0203ea8:	0005c703          	lbu	a4,0(a1)
ffffffffc0203eac:	0505                	addi	a0,a0,1
ffffffffc0203eae:	0585                	addi	a1,a1,1
ffffffffc0203eb0:	fee788e3          	beq	a5,a4,ffffffffc0203ea0 <memcmp+0x6>
ffffffffc0203eb4:	40e7853b          	subw	a0,a5,a4
ffffffffc0203eb8:	8082                	ret
ffffffffc0203eba:	4501                	li	a0,0
ffffffffc0203ebc:	8082                	ret
