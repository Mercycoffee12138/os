
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
ffffffffc0200000:	00005297          	auipc	t0,0x5
ffffffffc0200004:	00028293          	mv	t0,t0
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0205000 <boot_hartid>
ffffffffc020000c:	00005297          	auipc	t0,0x5
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0205008 <boot_dtb>
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
ffffffffc0200018:	c02042b7          	lui	t0,0xc0204
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
ffffffffc0200034:	18029073          	csrw	satp,t0
ffffffffc0200038:	12000073          	sfence.vma
ffffffffc020003c:	c0204137          	lui	sp,0xc0204
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
ffffffffc0200044:	0d828293          	addi	t0,t0,216 # ffffffffc02000d8 <kern_init>
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <print_kerninfo>:
ffffffffc020004a:	1141                	addi	sp,sp,-16
ffffffffc020004c:	00001517          	auipc	a0,0x1
ffffffffc0200050:	5ec50513          	addi	a0,a0,1516 # ffffffffc0201638 <etext+0x4>
ffffffffc0200054:	e406                	sd	ra,8(sp)
ffffffffc0200056:	0f6000ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc020005a:	00000597          	auipc	a1,0x0
ffffffffc020005e:	07e58593          	addi	a1,a1,126 # ffffffffc02000d8 <kern_init>
ffffffffc0200062:	00001517          	auipc	a0,0x1
ffffffffc0200066:	5f650513          	addi	a0,a0,1526 # ffffffffc0201658 <etext+0x24>
ffffffffc020006a:	0e2000ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc020006e:	00001597          	auipc	a1,0x1
ffffffffc0200072:	5c658593          	addi	a1,a1,1478 # ffffffffc0201634 <etext>
ffffffffc0200076:	00001517          	auipc	a0,0x1
ffffffffc020007a:	60250513          	addi	a0,a0,1538 # ffffffffc0201678 <etext+0x44>
ffffffffc020007e:	0ce000ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200082:	00005597          	auipc	a1,0x5
ffffffffc0200086:	f9658593          	addi	a1,a1,-106 # ffffffffc0205018 <slub_allocator>
ffffffffc020008a:	00001517          	auipc	a0,0x1
ffffffffc020008e:	60e50513          	addi	a0,a0,1550 # ffffffffc0201698 <etext+0x64>
ffffffffc0200092:	0ba000ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200096:	00015597          	auipc	a1,0x15
ffffffffc020009a:	05258593          	addi	a1,a1,82 # ffffffffc02150e8 <end>
ffffffffc020009e:	00001517          	auipc	a0,0x1
ffffffffc02000a2:	61a50513          	addi	a0,a0,1562 # ffffffffc02016b8 <etext+0x84>
ffffffffc02000a6:	0a6000ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc02000aa:	00015597          	auipc	a1,0x15
ffffffffc02000ae:	43d58593          	addi	a1,a1,1085 # ffffffffc02154e7 <end+0x3ff>
ffffffffc02000b2:	00000797          	auipc	a5,0x0
ffffffffc02000b6:	02678793          	addi	a5,a5,38 # ffffffffc02000d8 <kern_init>
ffffffffc02000ba:	40f587b3          	sub	a5,a1,a5
ffffffffc02000be:	43f7d593          	srai	a1,a5,0x3f
ffffffffc02000c2:	60a2                	ld	ra,8(sp)
ffffffffc02000c4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02000c8:	95be                	add	a1,a1,a5
ffffffffc02000ca:	85a9                	srai	a1,a1,0xa
ffffffffc02000cc:	00001517          	auipc	a0,0x1
ffffffffc02000d0:	60c50513          	addi	a0,a0,1548 # ffffffffc02016d8 <etext+0xa4>
ffffffffc02000d4:	0141                	addi	sp,sp,16
ffffffffc02000d6:	a89d                	j	ffffffffc020014c <cprintf>

ffffffffc02000d8 <kern_init>:
ffffffffc02000d8:	00005517          	auipc	a0,0x5
ffffffffc02000dc:	f4050513          	addi	a0,a0,-192 # ffffffffc0205018 <slub_allocator>
ffffffffc02000e0:	00015617          	auipc	a2,0x15
ffffffffc02000e4:	00860613          	addi	a2,a2,8 # ffffffffc02150e8 <end>
ffffffffc02000e8:	1141                	addi	sp,sp,-16
ffffffffc02000ea:	8e09                	sub	a2,a2,a0
ffffffffc02000ec:	4581                	li	a1,0
ffffffffc02000ee:	e406                	sd	ra,8(sp)
ffffffffc02000f0:	532010ef          	jal	ra,ffffffffc0201622 <memset>
ffffffffc02000f4:	12c000ef          	jal	ra,ffffffffc0200220 <dtb_init>
ffffffffc02000f8:	11e000ef          	jal	ra,ffffffffc0200216 <cons_init>
ffffffffc02000fc:	00001517          	auipc	a0,0x1
ffffffffc0200100:	60c50513          	addi	a0,a0,1548 # ffffffffc0201708 <etext+0xd4>
ffffffffc0200104:	07e000ef          	jal	ra,ffffffffc0200182 <cputs>
ffffffffc0200108:	f43ff0ef          	jal	ra,ffffffffc020004a <print_kerninfo>
ffffffffc020010c:	4c4000ef          	jal	ra,ffffffffc02005d0 <pmm_init>
ffffffffc0200110:	a001                	j	ffffffffc0200110 <kern_init+0x38>

ffffffffc0200112 <cputch>:
ffffffffc0200112:	1141                	addi	sp,sp,-16
ffffffffc0200114:	e022                	sd	s0,0(sp)
ffffffffc0200116:	e406                	sd	ra,8(sp)
ffffffffc0200118:	842e                	mv	s0,a1
ffffffffc020011a:	0fe000ef          	jal	ra,ffffffffc0200218 <cons_putc>
ffffffffc020011e:	401c                	lw	a5,0(s0)
ffffffffc0200120:	60a2                	ld	ra,8(sp)
ffffffffc0200122:	2785                	addiw	a5,a5,1
ffffffffc0200124:	c01c                	sw	a5,0(s0)
ffffffffc0200126:	6402                	ld	s0,0(sp)
ffffffffc0200128:	0141                	addi	sp,sp,16
ffffffffc020012a:	8082                	ret

ffffffffc020012c <vcprintf>:
ffffffffc020012c:	1101                	addi	sp,sp,-32
ffffffffc020012e:	862a                	mv	a2,a0
ffffffffc0200130:	86ae                	mv	a3,a1
ffffffffc0200132:	00000517          	auipc	a0,0x0
ffffffffc0200136:	fe050513          	addi	a0,a0,-32 # ffffffffc0200112 <cputch>
ffffffffc020013a:	006c                	addi	a1,sp,12
ffffffffc020013c:	ec06                	sd	ra,24(sp)
ffffffffc020013e:	c602                	sw	zero,12(sp)
ffffffffc0200140:	0cc010ef          	jal	ra,ffffffffc020120c <vprintfmt>
ffffffffc0200144:	60e2                	ld	ra,24(sp)
ffffffffc0200146:	4532                	lw	a0,12(sp)
ffffffffc0200148:	6105                	addi	sp,sp,32
ffffffffc020014a:	8082                	ret

ffffffffc020014c <cprintf>:
ffffffffc020014c:	711d                	addi	sp,sp,-96
ffffffffc020014e:	02810313          	addi	t1,sp,40 # ffffffffc0204028 <boot_page_table_sv39+0x28>
ffffffffc0200152:	8e2a                	mv	t3,a0
ffffffffc0200154:	f42e                	sd	a1,40(sp)
ffffffffc0200156:	f832                	sd	a2,48(sp)
ffffffffc0200158:	fc36                	sd	a3,56(sp)
ffffffffc020015a:	00000517          	auipc	a0,0x0
ffffffffc020015e:	fb850513          	addi	a0,a0,-72 # ffffffffc0200112 <cputch>
ffffffffc0200162:	004c                	addi	a1,sp,4
ffffffffc0200164:	869a                	mv	a3,t1
ffffffffc0200166:	8672                	mv	a2,t3
ffffffffc0200168:	ec06                	sd	ra,24(sp)
ffffffffc020016a:	e0ba                	sd	a4,64(sp)
ffffffffc020016c:	e4be                	sd	a5,72(sp)
ffffffffc020016e:	e8c2                	sd	a6,80(sp)
ffffffffc0200170:	ecc6                	sd	a7,88(sp)
ffffffffc0200172:	e41a                	sd	t1,8(sp)
ffffffffc0200174:	c202                	sw	zero,4(sp)
ffffffffc0200176:	096010ef          	jal	ra,ffffffffc020120c <vprintfmt>
ffffffffc020017a:	60e2                	ld	ra,24(sp)
ffffffffc020017c:	4512                	lw	a0,4(sp)
ffffffffc020017e:	6125                	addi	sp,sp,96
ffffffffc0200180:	8082                	ret

ffffffffc0200182 <cputs>:
ffffffffc0200182:	1101                	addi	sp,sp,-32
ffffffffc0200184:	e822                	sd	s0,16(sp)
ffffffffc0200186:	ec06                	sd	ra,24(sp)
ffffffffc0200188:	e426                	sd	s1,8(sp)
ffffffffc020018a:	842a                	mv	s0,a0
ffffffffc020018c:	00054503          	lbu	a0,0(a0)
ffffffffc0200190:	c51d                	beqz	a0,ffffffffc02001be <cputs+0x3c>
ffffffffc0200192:	0405                	addi	s0,s0,1
ffffffffc0200194:	4485                	li	s1,1
ffffffffc0200196:	9c81                	subw	s1,s1,s0
ffffffffc0200198:	080000ef          	jal	ra,ffffffffc0200218 <cons_putc>
ffffffffc020019c:	00044503          	lbu	a0,0(s0)
ffffffffc02001a0:	008487bb          	addw	a5,s1,s0
ffffffffc02001a4:	0405                	addi	s0,s0,1
ffffffffc02001a6:	f96d                	bnez	a0,ffffffffc0200198 <cputs+0x16>
ffffffffc02001a8:	0017841b          	addiw	s0,a5,1
ffffffffc02001ac:	4529                	li	a0,10
ffffffffc02001ae:	06a000ef          	jal	ra,ffffffffc0200218 <cons_putc>
ffffffffc02001b2:	60e2                	ld	ra,24(sp)
ffffffffc02001b4:	8522                	mv	a0,s0
ffffffffc02001b6:	6442                	ld	s0,16(sp)
ffffffffc02001b8:	64a2                	ld	s1,8(sp)
ffffffffc02001ba:	6105                	addi	sp,sp,32
ffffffffc02001bc:	8082                	ret
ffffffffc02001be:	4405                	li	s0,1
ffffffffc02001c0:	b7f5                	j	ffffffffc02001ac <cputs+0x2a>

ffffffffc02001c2 <__panic>:
ffffffffc02001c2:	00015317          	auipc	t1,0x15
ffffffffc02001c6:	ed630313          	addi	t1,t1,-298 # ffffffffc0215098 <is_panic>
ffffffffc02001ca:	00032e03          	lw	t3,0(t1)
ffffffffc02001ce:	715d                	addi	sp,sp,-80
ffffffffc02001d0:	ec06                	sd	ra,24(sp)
ffffffffc02001d2:	e822                	sd	s0,16(sp)
ffffffffc02001d4:	f436                	sd	a3,40(sp)
ffffffffc02001d6:	f83a                	sd	a4,48(sp)
ffffffffc02001d8:	fc3e                	sd	a5,56(sp)
ffffffffc02001da:	e0c2                	sd	a6,64(sp)
ffffffffc02001dc:	e4c6                	sd	a7,72(sp)
ffffffffc02001de:	000e0363          	beqz	t3,ffffffffc02001e4 <__panic+0x22>
ffffffffc02001e2:	a001                	j	ffffffffc02001e2 <__panic+0x20>
ffffffffc02001e4:	4785                	li	a5,1
ffffffffc02001e6:	00f32023          	sw	a5,0(t1)
ffffffffc02001ea:	8432                	mv	s0,a2
ffffffffc02001ec:	103c                	addi	a5,sp,40
ffffffffc02001ee:	862e                	mv	a2,a1
ffffffffc02001f0:	85aa                	mv	a1,a0
ffffffffc02001f2:	00001517          	auipc	a0,0x1
ffffffffc02001f6:	53650513          	addi	a0,a0,1334 # ffffffffc0201728 <etext+0xf4>
ffffffffc02001fa:	e43e                	sd	a5,8(sp)
ffffffffc02001fc:	f51ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200200:	65a2                	ld	a1,8(sp)
ffffffffc0200202:	8522                	mv	a0,s0
ffffffffc0200204:	f29ff0ef          	jal	ra,ffffffffc020012c <vcprintf>
ffffffffc0200208:	00001517          	auipc	a0,0x1
ffffffffc020020c:	4f850513          	addi	a0,a0,1272 # ffffffffc0201700 <etext+0xcc>
ffffffffc0200210:	f3dff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200214:	b7f9                	j	ffffffffc02001e2 <__panic+0x20>

ffffffffc0200216 <cons_init>:
ffffffffc0200216:	8082                	ret

ffffffffc0200218 <cons_putc>:
ffffffffc0200218:	0ff57513          	zext.b	a0,a0
ffffffffc020021c:	3720106f          	j	ffffffffc020158e <sbi_console_putchar>

ffffffffc0200220 <dtb_init>:
ffffffffc0200220:	7119                	addi	sp,sp,-128
ffffffffc0200222:	00001517          	auipc	a0,0x1
ffffffffc0200226:	52650513          	addi	a0,a0,1318 # ffffffffc0201748 <etext+0x114>
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
ffffffffc0200244:	f09ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200248:	00005597          	auipc	a1,0x5
ffffffffc020024c:	db85b583          	ld	a1,-584(a1) # ffffffffc0205000 <boot_hartid>
ffffffffc0200250:	00001517          	auipc	a0,0x1
ffffffffc0200254:	50850513          	addi	a0,a0,1288 # ffffffffc0201758 <etext+0x124>
ffffffffc0200258:	ef5ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc020025c:	00005417          	auipc	s0,0x5
ffffffffc0200260:	dac40413          	addi	s0,s0,-596 # ffffffffc0205008 <boot_dtb>
ffffffffc0200264:	600c                	ld	a1,0(s0)
ffffffffc0200266:	00001517          	auipc	a0,0x1
ffffffffc020026a:	50250513          	addi	a0,a0,1282 # ffffffffc0201768 <etext+0x134>
ffffffffc020026e:	edfff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200272:	00043a03          	ld	s4,0(s0)
ffffffffc0200276:	00001517          	auipc	a0,0x1
ffffffffc020027a:	50a50513          	addi	a0,a0,1290 # ffffffffc0201780 <etext+0x14c>
ffffffffc020027e:	120a0463          	beqz	s4,ffffffffc02003a6 <dtb_init+0x186>
ffffffffc0200282:	57f5                	li	a5,-3
ffffffffc0200284:	07fa                	slli	a5,a5,0x1e
ffffffffc0200286:	00fa0733          	add	a4,s4,a5
ffffffffc020028a:	431c                	lw	a5,0(a4)
ffffffffc020028c:	00ff0637          	lui	a2,0xff0
ffffffffc0200290:	6b41                	lui	s6,0x10
ffffffffc0200292:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200296:	0187969b          	slliw	a3,a5,0x18
ffffffffc020029a:	0187d51b          	srliw	a0,a5,0x18
ffffffffc020029e:	0105959b          	slliw	a1,a1,0x10
ffffffffc02002a2:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02002a6:	8df1                	and	a1,a1,a2
ffffffffc02002a8:	8ec9                	or	a3,a3,a0
ffffffffc02002aa:	0087979b          	slliw	a5,a5,0x8
ffffffffc02002ae:	1b7d                	addi	s6,s6,-1
ffffffffc02002b0:	0167f7b3          	and	a5,a5,s6
ffffffffc02002b4:	8dd5                	or	a1,a1,a3
ffffffffc02002b6:	8ddd                	or	a1,a1,a5
ffffffffc02002b8:	d00e07b7          	lui	a5,0xd00e0
ffffffffc02002bc:	2581                	sext.w	a1,a1
ffffffffc02002be:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfecae05>
ffffffffc02002c2:	10f59163          	bne	a1,a5,ffffffffc02003c4 <dtb_init+0x1a4>
ffffffffc02002c6:	471c                	lw	a5,8(a4)
ffffffffc02002c8:	4754                	lw	a3,12(a4)
ffffffffc02002ca:	4c81                	li	s9,0
ffffffffc02002cc:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02002d0:	0086d51b          	srliw	a0,a3,0x8
ffffffffc02002d4:	0186941b          	slliw	s0,a3,0x18
ffffffffc02002d8:	0186d89b          	srliw	a7,a3,0x18
ffffffffc02002dc:	01879a1b          	slliw	s4,a5,0x18
ffffffffc02002e0:	0187d81b          	srliw	a6,a5,0x18
ffffffffc02002e4:	0105151b          	slliw	a0,a0,0x10
ffffffffc02002e8:	0106d69b          	srliw	a3,a3,0x10
ffffffffc02002ec:	0105959b          	slliw	a1,a1,0x10
ffffffffc02002f0:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02002f4:	8d71                	and	a0,a0,a2
ffffffffc02002f6:	01146433          	or	s0,s0,a7
ffffffffc02002fa:	0086969b          	slliw	a3,a3,0x8
ffffffffc02002fe:	010a6a33          	or	s4,s4,a6
ffffffffc0200302:	8e6d                	and	a2,a2,a1
ffffffffc0200304:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200308:	8c49                	or	s0,s0,a0
ffffffffc020030a:	0166f6b3          	and	a3,a3,s6
ffffffffc020030e:	00ca6a33          	or	s4,s4,a2
ffffffffc0200312:	0167f7b3          	and	a5,a5,s6
ffffffffc0200316:	8c55                	or	s0,s0,a3
ffffffffc0200318:	00fa6a33          	or	s4,s4,a5
ffffffffc020031c:	1402                	slli	s0,s0,0x20
ffffffffc020031e:	1a02                	slli	s4,s4,0x20
ffffffffc0200320:	9001                	srli	s0,s0,0x20
ffffffffc0200322:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200326:	943a                	add	s0,s0,a4
ffffffffc0200328:	9a3a                	add	s4,s4,a4
ffffffffc020032a:	00ff0c37          	lui	s8,0xff0
ffffffffc020032e:	4b8d                	li	s7,3
ffffffffc0200330:	00001917          	auipc	s2,0x1
ffffffffc0200334:	4a090913          	addi	s2,s2,1184 # ffffffffc02017d0 <etext+0x19c>
ffffffffc0200338:	49bd                	li	s3,15
ffffffffc020033a:	4d91                	li	s11,4
ffffffffc020033c:	4d05                	li	s10,1
ffffffffc020033e:	00001497          	auipc	s1,0x1
ffffffffc0200342:	48a48493          	addi	s1,s1,1162 # ffffffffc02017c8 <etext+0x194>
ffffffffc0200346:	000a2703          	lw	a4,0(s4)
ffffffffc020034a:	004a0a93          	addi	s5,s4,4
ffffffffc020034e:	0087569b          	srliw	a3,a4,0x8
ffffffffc0200352:	0187179b          	slliw	a5,a4,0x18
ffffffffc0200356:	0187561b          	srliw	a2,a4,0x18
ffffffffc020035a:	0106969b          	slliw	a3,a3,0x10
ffffffffc020035e:	0107571b          	srliw	a4,a4,0x10
ffffffffc0200362:	8fd1                	or	a5,a5,a2
ffffffffc0200364:	0186f6b3          	and	a3,a3,s8
ffffffffc0200368:	0087171b          	slliw	a4,a4,0x8
ffffffffc020036c:	8fd5                	or	a5,a5,a3
ffffffffc020036e:	00eb7733          	and	a4,s6,a4
ffffffffc0200372:	8fd9                	or	a5,a5,a4
ffffffffc0200374:	2781                	sext.w	a5,a5
ffffffffc0200376:	09778c63          	beq	a5,s7,ffffffffc020040e <dtb_init+0x1ee>
ffffffffc020037a:	00fbea63          	bltu	s7,a5,ffffffffc020038e <dtb_init+0x16e>
ffffffffc020037e:	07a78663          	beq	a5,s10,ffffffffc02003ea <dtb_init+0x1ca>
ffffffffc0200382:	4709                	li	a4,2
ffffffffc0200384:	00e79763          	bne	a5,a4,ffffffffc0200392 <dtb_init+0x172>
ffffffffc0200388:	4c81                	li	s9,0
ffffffffc020038a:	8a56                	mv	s4,s5
ffffffffc020038c:	bf6d                	j	ffffffffc0200346 <dtb_init+0x126>
ffffffffc020038e:	ffb78ee3          	beq	a5,s11,ffffffffc020038a <dtb_init+0x16a>
ffffffffc0200392:	00001517          	auipc	a0,0x1
ffffffffc0200396:	4b650513          	addi	a0,a0,1206 # ffffffffc0201848 <etext+0x214>
ffffffffc020039a:	db3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	4e250513          	addi	a0,a0,1250 # ffffffffc0201880 <etext+0x24c>
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
ffffffffc02003c2:	b369                	j	ffffffffc020014c <cprintf>
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
ffffffffc02003de:	00001517          	auipc	a0,0x1
ffffffffc02003e2:	3c250513          	addi	a0,a0,962 # ffffffffc02017a0 <etext+0x16c>
ffffffffc02003e6:	6109                	addi	sp,sp,128
ffffffffc02003e8:	b395                	j	ffffffffc020014c <cprintf>
ffffffffc02003ea:	8556                	mv	a0,s5
ffffffffc02003ec:	1bc010ef          	jal	ra,ffffffffc02015a8 <strlen>
ffffffffc02003f0:	8a2a                	mv	s4,a0
ffffffffc02003f2:	4619                	li	a2,6
ffffffffc02003f4:	85a6                	mv	a1,s1
ffffffffc02003f6:	8556                	mv	a0,s5
ffffffffc02003f8:	2a01                	sext.w	s4,s4
ffffffffc02003fa:	202010ef          	jal	ra,ffffffffc02015fc <strncmp>
ffffffffc02003fe:	e111                	bnez	a0,ffffffffc0200402 <dtb_init+0x1e2>
ffffffffc0200400:	4c85                	li	s9,1
ffffffffc0200402:	0a91                	addi	s5,s5,4
ffffffffc0200404:	9ad2                	add	s5,s5,s4
ffffffffc0200406:	ffcafa93          	andi	s5,s5,-4
ffffffffc020040a:	8a56                	mv	s4,s5
ffffffffc020040c:	bf2d                	j	ffffffffc0200346 <dtb_init+0x126>
ffffffffc020040e:	004a2783          	lw	a5,4(s4)
ffffffffc0200412:	00ca0693          	addi	a3,s4,12
ffffffffc0200416:	0087d71b          	srliw	a4,a5,0x8
ffffffffc020041a:	01879a9b          	slliw	s5,a5,0x18
ffffffffc020041e:	0187d61b          	srliw	a2,a5,0x18
ffffffffc0200422:	0107171b          	slliw	a4,a4,0x10
ffffffffc0200426:	0107d79b          	srliw	a5,a5,0x10
ffffffffc020042a:	00caeab3          	or	s5,s5,a2
ffffffffc020042e:	01877733          	and	a4,a4,s8
ffffffffc0200432:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200436:	00eaeab3          	or	s5,s5,a4
ffffffffc020043a:	00fb77b3          	and	a5,s6,a5
ffffffffc020043e:	00faeab3          	or	s5,s5,a5
ffffffffc0200442:	2a81                	sext.w	s5,s5
ffffffffc0200444:	000c9c63          	bnez	s9,ffffffffc020045c <dtb_init+0x23c>
ffffffffc0200448:	1a82                	slli	s5,s5,0x20
ffffffffc020044a:	00368793          	addi	a5,a3,3
ffffffffc020044e:	020ada93          	srli	s5,s5,0x20
ffffffffc0200452:	9abe                	add	s5,s5,a5
ffffffffc0200454:	ffcafa93          	andi	s5,s5,-4
ffffffffc0200458:	8a56                	mv	s4,s5
ffffffffc020045a:	b5f5                	j	ffffffffc0200346 <dtb_init+0x126>
ffffffffc020045c:	008a2783          	lw	a5,8(s4)
ffffffffc0200460:	85ca                	mv	a1,s2
ffffffffc0200462:	e436                	sd	a3,8(sp)
ffffffffc0200464:	0087d51b          	srliw	a0,a5,0x8
ffffffffc0200468:	0187d61b          	srliw	a2,a5,0x18
ffffffffc020046c:	0187971b          	slliw	a4,a5,0x18
ffffffffc0200470:	0105151b          	slliw	a0,a0,0x10
ffffffffc0200474:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200478:	8f51                	or	a4,a4,a2
ffffffffc020047a:	01857533          	and	a0,a0,s8
ffffffffc020047e:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200482:	8d59                	or	a0,a0,a4
ffffffffc0200484:	00fb77b3          	and	a5,s6,a5
ffffffffc0200488:	8d5d                	or	a0,a0,a5
ffffffffc020048a:	1502                	slli	a0,a0,0x20
ffffffffc020048c:	9101                	srli	a0,a0,0x20
ffffffffc020048e:	9522                	add	a0,a0,s0
ffffffffc0200490:	14e010ef          	jal	ra,ffffffffc02015de <strcmp>
ffffffffc0200494:	66a2                	ld	a3,8(sp)
ffffffffc0200496:	f94d                	bnez	a0,ffffffffc0200448 <dtb_init+0x228>
ffffffffc0200498:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200448 <dtb_init+0x228>
ffffffffc020049c:	00ca3783          	ld	a5,12(s4)
ffffffffc02004a0:	014a3703          	ld	a4,20(s4)
ffffffffc02004a4:	00001517          	auipc	a0,0x1
ffffffffc02004a8:	33450513          	addi	a0,a0,820 # ffffffffc02017d8 <etext+0x1a4>
ffffffffc02004ac:	4207d613          	srai	a2,a5,0x20
ffffffffc02004b0:	0087d31b          	srliw	t1,a5,0x8
ffffffffc02004b4:	42075593          	srai	a1,a4,0x20
ffffffffc02004b8:	0187de1b          	srliw	t3,a5,0x18
ffffffffc02004bc:	0186581b          	srliw	a6,a2,0x18
ffffffffc02004c0:	0187941b          	slliw	s0,a5,0x18
ffffffffc02004c4:	0107d89b          	srliw	a7,a5,0x10
ffffffffc02004c8:	0187d693          	srli	a3,a5,0x18
ffffffffc02004cc:	01861f1b          	slliw	t5,a2,0x18
ffffffffc02004d0:	0087579b          	srliw	a5,a4,0x8
ffffffffc02004d4:	0103131b          	slliw	t1,t1,0x10
ffffffffc02004d8:	0106561b          	srliw	a2,a2,0x10
ffffffffc02004dc:	010f6f33          	or	t5,t5,a6
ffffffffc02004e0:	0187529b          	srliw	t0,a4,0x18
ffffffffc02004e4:	0185df9b          	srliw	t6,a1,0x18
ffffffffc02004e8:	01837333          	and	t1,t1,s8
ffffffffc02004ec:	01c46433          	or	s0,s0,t3
ffffffffc02004f0:	0186f6b3          	and	a3,a3,s8
ffffffffc02004f4:	01859e1b          	slliw	t3,a1,0x18
ffffffffc02004f8:	01871e9b          	slliw	t4,a4,0x18
ffffffffc02004fc:	0107581b          	srliw	a6,a4,0x10
ffffffffc0200500:	0086161b          	slliw	a2,a2,0x8
ffffffffc0200504:	8361                	srli	a4,a4,0x18
ffffffffc0200506:	0107979b          	slliw	a5,a5,0x10
ffffffffc020050a:	0105d59b          	srliw	a1,a1,0x10
ffffffffc020050e:	01e6e6b3          	or	a3,a3,t5
ffffffffc0200512:	00cb7633          	and	a2,s6,a2
ffffffffc0200516:	0088181b          	slliw	a6,a6,0x8
ffffffffc020051a:	0085959b          	slliw	a1,a1,0x8
ffffffffc020051e:	00646433          	or	s0,s0,t1
ffffffffc0200522:	0187f7b3          	and	a5,a5,s8
ffffffffc0200526:	01fe6333          	or	t1,t3,t6
ffffffffc020052a:	01877c33          	and	s8,a4,s8
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
ffffffffc0200558:	1702                	slli	a4,a4,0x20
ffffffffc020055a:	1b02                	slli	s6,s6,0x20
ffffffffc020055c:	1782                	slli	a5,a5,0x20
ffffffffc020055e:	9301                	srli	a4,a4,0x20
ffffffffc0200560:	1402                	slli	s0,s0,0x20
ffffffffc0200562:	020b5b13          	srli	s6,s6,0x20
ffffffffc0200566:	0167eb33          	or	s6,a5,s6
ffffffffc020056a:	8c59                	or	s0,s0,a4
ffffffffc020056c:	be1ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200570:	85a2                	mv	a1,s0
ffffffffc0200572:	00001517          	auipc	a0,0x1
ffffffffc0200576:	28650513          	addi	a0,a0,646 # ffffffffc02017f8 <etext+0x1c4>
ffffffffc020057a:	bd3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc020057e:	014b5613          	srli	a2,s6,0x14
ffffffffc0200582:	85da                	mv	a1,s6
ffffffffc0200584:	00001517          	auipc	a0,0x1
ffffffffc0200588:	28c50513          	addi	a0,a0,652 # ffffffffc0201810 <etext+0x1dc>
ffffffffc020058c:	bc1ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200590:	008b05b3          	add	a1,s6,s0
ffffffffc0200594:	15fd                	addi	a1,a1,-1
ffffffffc0200596:	00001517          	auipc	a0,0x1
ffffffffc020059a:	29a50513          	addi	a0,a0,666 # ffffffffc0201830 <etext+0x1fc>
ffffffffc020059e:	bafff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc02005a2:	00001517          	auipc	a0,0x1
ffffffffc02005a6:	2de50513          	addi	a0,a0,734 # ffffffffc0201880 <etext+0x24c>
ffffffffc02005aa:	00015797          	auipc	a5,0x15
ffffffffc02005ae:	ae87bb23          	sd	s0,-1290(a5) # ffffffffc02150a0 <memory_base>
ffffffffc02005b2:	00015797          	auipc	a5,0x15
ffffffffc02005b6:	af67bb23          	sd	s6,-1290(a5) # ffffffffc02150a8 <memory_size>
ffffffffc02005ba:	b3f5                	j	ffffffffc02003a6 <dtb_init+0x186>

ffffffffc02005bc <get_memory_base>:
ffffffffc02005bc:	00015517          	auipc	a0,0x15
ffffffffc02005c0:	ae453503          	ld	a0,-1308(a0) # ffffffffc02150a0 <memory_base>
ffffffffc02005c4:	8082                	ret

ffffffffc02005c6 <get_memory_size>:
ffffffffc02005c6:	00015517          	auipc	a0,0x15
ffffffffc02005ca:	ae253503          	ld	a0,-1310(a0) # ffffffffc02150a8 <memory_size>
ffffffffc02005ce:	8082                	ret

ffffffffc02005d0 <pmm_init>:
static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    // 切换管理器：使用 SLUB 分配器进行练习测试
    pmm_manager = &slub_pmm_manager;
ffffffffc02005d0:	00001797          	auipc	a5,0x1
ffffffffc02005d4:	70078793          	addi	a5,a5,1792 # ffffffffc0201cd0 <slub_pmm_manager>
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
ffffffffc02005e2:	2ba50513          	addi	a0,a0,698 # ffffffffc0201898 <etext+0x264>
    pmm_manager = &slub_pmm_manager;
ffffffffc02005e6:	00015417          	auipc	s0,0x15
ffffffffc02005ea:	ada40413          	addi	s0,s0,-1318 # ffffffffc02150c0 <pmm_manager>
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
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;//设置偏移量
ffffffffc0200600:	00015497          	auipc	s1,0x15
ffffffffc0200604:	ad848493          	addi	s1,s1,-1320 # ffffffffc02150d8 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200608:	679c                	ld	a5,8(a5)
ffffffffc020060a:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;//设置偏移量
ffffffffc020060c:	57f5                	li	a5,-3
ffffffffc020060e:	07fa                	slli	a5,a5,0x1e
ffffffffc0200610:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();//获取物理内存的起始地址和总大小
ffffffffc0200612:	fabff0ef          	jal	ra,ffffffffc02005bc <get_memory_base>
ffffffffc0200616:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc0200618:	fafff0ef          	jal	ra,ffffffffc02005c6 <get_memory_size>
    if (mem_size == 0) {
ffffffffc020061c:	14050c63          	beqz	a0,ffffffffc0200774 <pmm_init+0x1a4>
    uint64_t mem_end   = mem_begin + mem_size;//物理内存的结束地址
ffffffffc0200620:	892a                	mv	s2,a0
    cprintf("physcial memory map:\n");
ffffffffc0200622:	00001517          	auipc	a0,0x1
ffffffffc0200626:	2be50513          	addi	a0,a0,702 # ffffffffc02018e0 <etext+0x2ac>
ffffffffc020062a:	b23ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;//物理内存的结束地址
ffffffffc020062e:	01298a33          	add	s4,s3,s2
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200632:	864e                	mv	a2,s3
ffffffffc0200634:	fffa0693          	addi	a3,s4,-1
ffffffffc0200638:	85ca                	mv	a1,s2
ffffffffc020063a:	00001517          	auipc	a0,0x1
ffffffffc020063e:	2be50513          	addi	a0,a0,702 # ffffffffc02018f8 <etext+0x2c4>
ffffffffc0200642:	b0bff0ef          	jal	ra,ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;//计算总页数
ffffffffc0200646:	c80007b7          	lui	a5,0xc8000
ffffffffc020064a:	8652                	mv	a2,s4
ffffffffc020064c:	0d47e363          	bltu	a5,s4,ffffffffc0200712 <pmm_init+0x142>
ffffffffc0200650:	00016797          	auipc	a5,0x16
ffffffffc0200654:	a9778793          	addi	a5,a5,-1385 # ffffffffc02160e7 <end+0xfff>
ffffffffc0200658:	757d                	lui	a0,0xfffff
ffffffffc020065a:	8d7d                	and	a0,a0,a5
ffffffffc020065c:	8231                	srli	a2,a2,0xc
ffffffffc020065e:	00015797          	auipc	a5,0x15
ffffffffc0200662:	a4c7b923          	sd	a2,-1454(a5) # ffffffffc02150b0 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200666:	00015797          	auipc	a5,0x15
ffffffffc020066a:	a4a7b923          	sd	a0,-1454(a5) # ffffffffc02150b8 <pages>
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
ffffffffc0200690:	02878793          	addi	a5,a5,40 # fffffffffec00028 <end+0x3e9eaf40>
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
    if (freemem < mem_end) {//空闲页链表
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
ffffffffc02006cc:	2b850513          	addi	a0,a0,696 # ffffffffc0201980 <etext+0x34c>
ffffffffc02006d0:	a7dff0ef          	jal	ra,ffffffffc020014c <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02006d4:	00004597          	auipc	a1,0x4
ffffffffc02006d8:	92c58593          	addi	a1,a1,-1748 # ffffffffc0204000 <boot_page_table_sv39>
ffffffffc02006dc:	00015797          	auipc	a5,0x15
ffffffffc02006e0:	9eb7ba23          	sd	a1,-1548(a5) # ffffffffc02150d0 <satp_virtual>
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
ffffffffc02006fe:	00015797          	auipc	a5,0x15
ffffffffc0200702:	9cc7b523          	sd	a2,-1590(a5) # ffffffffc02150c8 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200706:	00001517          	auipc	a0,0x1
ffffffffc020070a:	29a50513          	addi	a0,a0,666 # ffffffffc02019a0 <etext+0x36c>
}
ffffffffc020070e:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200710:	bc35                	j	ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;//计算总页数
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
ffffffffc0200748:	20c60613          	addi	a2,a2,524 # ffffffffc0201950 <etext+0x31c>
ffffffffc020074c:	06a00593          	li	a1,106
ffffffffc0200750:	00001517          	auipc	a0,0x1
ffffffffc0200754:	22050513          	addi	a0,a0,544 # ffffffffc0201970 <etext+0x33c>
ffffffffc0200758:	a6bff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020075c:	00001617          	auipc	a2,0x1
ffffffffc0200760:	1cc60613          	addi	a2,a2,460 # ffffffffc0201928 <etext+0x2f4>
ffffffffc0200764:	06100593          	li	a1,97
ffffffffc0200768:	00001517          	auipc	a0,0x1
ffffffffc020076c:	16850513          	addi	a0,a0,360 # ffffffffc02018d0 <etext+0x29c>
ffffffffc0200770:	a53ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("DTB memory info not available");
ffffffffc0200774:	00001617          	auipc	a2,0x1
ffffffffc0200778:	13c60613          	addi	a2,a2,316 # ffffffffc02018b0 <etext+0x27c>
ffffffffc020077c:	04900593          	li	a1,73
ffffffffc0200780:	00001517          	auipc	a0,0x1
ffffffffc0200784:	15050513          	addi	a0,a0,336 # ffffffffc02018d0 <etext+0x29c>
ffffffffc0200788:	a3bff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020078c:	86ae                	mv	a3,a1
ffffffffc020078e:	00001617          	auipc	a2,0x1
ffffffffc0200792:	19a60613          	addi	a2,a2,410 # ffffffffc0201928 <etext+0x2f4>
ffffffffc0200796:	07c00593          	li	a1,124
ffffffffc020079a:	00001517          	auipc	a0,0x1
ffffffffc020079e:	13650513          	addi	a0,a0,310 # ffffffffc02018d0 <etext+0x29c>
ffffffffc02007a2:	a21ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02007a6 <slub_nr_free_pages>:
static size_t slub_nr_free_pages(void) {
    extern struct Page *pages;
    extern size_t npage;

    size_t free_pages = 0;
    for (size_t i = 0; i < npage; i++) {
ffffffffc02007a6:	00015517          	auipc	a0,0x15
ffffffffc02007aa:	90a53503          	ld	a0,-1782(a0) # ffffffffc02150b0 <npage>
ffffffffc02007ae:	c505                	beqz	a0,ffffffffc02007d6 <slub_nr_free_pages+0x30>
ffffffffc02007b0:	00251693          	slli	a3,a0,0x2
ffffffffc02007b4:	96aa                	add	a3,a3,a0
ffffffffc02007b6:	00015717          	auipc	a4,0x15
ffffffffc02007ba:	90273703          	ld	a4,-1790(a4) # ffffffffc02150b8 <pages>
ffffffffc02007be:	068e                	slli	a3,a3,0x3
ffffffffc02007c0:	96ba                	add	a3,a3,a4
    size_t free_pages = 0;
ffffffffc02007c2:	4501                	li	a0,0
        if (!PageReserved(pages + i) && !PageProperty(pages + i))
ffffffffc02007c4:	671c                	ld	a5,8(a4)
    for (size_t i = 0; i < npage; i++) {
ffffffffc02007c6:	02870713          	addi	a4,a4,40
        if (!PageReserved(pages + i) && !PageProperty(pages + i))
ffffffffc02007ca:	8b8d                	andi	a5,a5,3
            free_pages++;
ffffffffc02007cc:	0017b793          	seqz	a5,a5
ffffffffc02007d0:	953e                	add	a0,a0,a5
    for (size_t i = 0; i < npage; i++) {
ffffffffc02007d2:	fed719e3          	bne	a4,a3,ffffffffc02007c4 <slub_nr_free_pages+0x1e>
    }

    return free_pages;
}
ffffffffc02007d6:	8082                	ret

ffffffffc02007d8 <slub_init_memmap>:
static void slub_init_memmap(struct Page *base, size_t n) {
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
ffffffffc02007f0:	00005797          	auipc	a5,0x5
ffffffffc02007f4:	82878793          	addi	a5,a5,-2008 # ffffffffc0205018 <slub_allocator>
    size_t info_pages = (info_size + PGSIZE - 1) / PGSIZE;
ffffffffc02007f8:	9932                	add	s2,s2,a2
    slub_allocator.max_pages = n;
ffffffffc02007fa:	ffac                	sd	a1,120(a5)
    size_t info_pages = (info_size + PGSIZE - 1) / PGSIZE;
ffffffffc02007fc:	00c95913          	srli	s2,s2,0xc
ffffffffc0200800:	84ae                	mv	s1,a1
    if (info_pages >= n)
ffffffffc0200802:	08b97d63          	bgeu	s2,a1,ffffffffc020089c <slub_init_memmap+0xc4>
    slub_allocator.page_infos = (struct slub_page_info *)page2kva(base);
ffffffffc0200806:	842a                	mv	s0,a0
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200808:	00015517          	auipc	a0,0x15
ffffffffc020080c:	8b053503          	ld	a0,-1872(a0) # ffffffffc02150b8 <pages>
ffffffffc0200810:	40a40533          	sub	a0,s0,a0
ffffffffc0200814:	00001717          	auipc	a4,0x1
ffffffffc0200818:	74473703          	ld	a4,1860(a4) # ffffffffc0201f58 <nbase+0x8>
ffffffffc020081c:	850d                	srai	a0,a0,0x3
ffffffffc020081e:	02e50533          	mul	a0,a0,a4
ffffffffc0200822:	00001717          	auipc	a4,0x1
ffffffffc0200826:	72e73703          	ld	a4,1838(a4) # ffffffffc0201f50 <nbase>
    memset(slub_allocator.page_infos, 0, info_size);
ffffffffc020082a:	4581                	li	a1,0
ffffffffc020082c:	953a                	add	a0,a0,a4
    return page2ppn(page) << PGSHIFT;
ffffffffc020082e:	0532                	slli	a0,a0,0xc
    slub_allocator.page_infos = (struct slub_page_info *)page2kva(base);
ffffffffc0200830:	00015717          	auipc	a4,0x15
ffffffffc0200834:	8a873703          	ld	a4,-1880(a4) # ffffffffc02150d8 <va_pa_offset>
ffffffffc0200838:	953a                	add	a0,a0,a4
ffffffffc020083a:	fba8                	sd	a0,112(a5)
    memset(slub_allocator.page_infos, 0, info_size);
ffffffffc020083c:	5e7000ef          	jal	ra,ffffffffc0201622 <memset>
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
    cprintf("SLUB memmap initialized: %u pages, %u info pages\n",
ffffffffc0200864:	0009061b          	sext.w	a2,s2
ffffffffc0200868:	0004859b          	sext.w	a1,s1
}
ffffffffc020086c:	6902                	ld	s2,0(sp)
ffffffffc020086e:	64a2                	ld	s1,8(sp)
    cprintf("SLUB memmap initialized: %u pages, %u info pages\n",
ffffffffc0200870:	00001517          	auipc	a0,0x1
ffffffffc0200874:	1d850513          	addi	a0,a0,472 # ffffffffc0201a48 <etext+0x414>
}
ffffffffc0200878:	6105                	addi	sp,sp,32
    cprintf("SLUB memmap initialized: %u pages, %u info pages\n",
ffffffffc020087a:	b8c9                	j	ffffffffc020014c <cprintf>
    assert(n > 0);
ffffffffc020087c:	00001697          	auipc	a3,0x1
ffffffffc0200880:	16468693          	addi	a3,a3,356 # ffffffffc02019e0 <etext+0x3ac>
ffffffffc0200884:	00001617          	auipc	a2,0x1
ffffffffc0200888:	16460613          	addi	a2,a2,356 # ffffffffc02019e8 <etext+0x3b4>
ffffffffc020088c:	13000593          	li	a1,304
ffffffffc0200890:	00001517          	auipc	a0,0x1
ffffffffc0200894:	17050513          	addi	a0,a0,368 # ffffffffc0201a00 <etext+0x3cc>
ffffffffc0200898:	92bff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("Not enough memory for SLUB page info array");
ffffffffc020089c:	00001617          	auipc	a2,0x1
ffffffffc02008a0:	17c60613          	addi	a2,a2,380 # ffffffffc0201a18 <etext+0x3e4>
ffffffffc02008a4:	13900593          	li	a1,313
ffffffffc02008a8:	00001517          	auipc	a0,0x1
ffffffffc02008ac:	15850513          	addi	a0,a0,344 # ffffffffc0201a00 <etext+0x3cc>
ffffffffc02008b0:	913ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02008b4 <slub_init>:
static void slub_init(void) {
ffffffffc02008b4:	711d                	addi	sp,sp,-96
    memset(&slub_allocator, 0, sizeof(slub_allocator));
ffffffffc02008b6:	08000613          	li	a2,128
ffffffffc02008ba:	4581                	li	a1,0
ffffffffc02008bc:	00004517          	auipc	a0,0x4
ffffffffc02008c0:	75c50513          	addi	a0,a0,1884 # ffffffffc0205018 <slub_allocator>
static void slub_init(void) {
ffffffffc02008c4:	e4a6                	sd	s1,72(sp)
ffffffffc02008c6:	fc4e                	sd	s3,56(sp)
ffffffffc02008c8:	f852                	sd	s4,48(sp)
ffffffffc02008ca:	f456                	sd	s5,40(sp)
ffffffffc02008cc:	f05a                	sd	s6,32(sp)
ffffffffc02008ce:	ec5e                	sd	s7,24(sp)
ffffffffc02008d0:	e862                	sd	s8,16(sp)
ffffffffc02008d2:	e466                	sd	s9,8(sp)
ffffffffc02008d4:	e06a                	sd	s10,0(sp)
ffffffffc02008d6:	ec86                	sd	ra,88(sp)
ffffffffc02008d8:	e8a2                	sd	s0,80(sp)
ffffffffc02008da:	e0ca                	sd	s2,64(sp)
        cache->cpu_cache.avail = 0;
ffffffffc02008dc:	4b05                	li	s6,1
    memset(&slub_allocator, 0, sizeof(slub_allocator));
ffffffffc02008de:	545000ef          	jal	ra,ffffffffc0201622 <memset>
        if (cache->objects_per_slab == 0)
ffffffffc02008e2:	6985                	lui	s3,0x1
    heap_used = 0;
ffffffffc02008e4:	00014797          	auipc	a5,0x14
ffffffffc02008e8:	7e07be23          	sd	zero,2044(a5) # ffffffffc02150e0 <heap_used>
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc02008ec:	00004c17          	auipc	s8,0x4
ffffffffc02008f0:	72cc0c13          	addi	s8,s8,1836 # ffffffffc0205018 <slub_allocator>
    heap_used = 0;
ffffffffc02008f4:	4781                	li	a5,0
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc02008f6:	4481                	li	s1,0
    return SLUB_MIN_SIZE << index;
ffffffffc02008f8:	4a21                	li	s4,8
    if (heap_used + size > sizeof(static_heap))
ffffffffc02008fa:	6cc1                	lui	s9,0x10
    void *ptr = &static_heap[heap_used];
ffffffffc02008fc:	00004d17          	auipc	s10,0x4
ffffffffc0200900:	79cd0d13          	addi	s10,s10,1948 # ffffffffc0205098 <static_heap>
    heap_used = ((heap_used + size + 7) / 8) * 8;  // 8字节对齐
ffffffffc0200904:	00014b97          	auipc	s7,0x14
ffffffffc0200908:	7dcb8b93          	addi	s7,s7,2012 # ffffffffc02150e0 <heap_used>
        if (cache->objects_per_slab == 0)
ffffffffc020090c:	19e1                	addi	s3,s3,-8
        cache->cpu_cache.avail = 0;
ffffffffc020090e:	024b1a93          	slli	s5,s6,0x24
ffffffffc0200912:	a089                	j	ffffffffc0200954 <slub_init+0xa0>
        cache->objects_per_slab = (PGSIZE - sizeof(void*)) / size;
ffffffffc0200914:	0329d933          	divu	s2,s3,s2
    if (heap_used + size > sizeof(static_heap))
ffffffffc0200918:	000bb783          	ld	a5,0(s7)
        list_init(&cache->partial_list);
ffffffffc020091c:	02040693          	addi	a3,s0,32
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200920:	f414                	sd	a3,40(s0)
    heap_used = ((heap_used + size + 7) / 8) * 8;  // 8字节对齐
ffffffffc0200922:	08778713          	addi	a4,a5,135
ffffffffc0200926:	f014                	sd	a3,32(s0)
    if (heap_used + size > sizeof(static_heap))
ffffffffc0200928:	08078693          	addi	a3,a5,128
    heap_used = ((heap_used + size + 7) / 8) * 8;  // 8字节对齐
ffffffffc020092c:	9b61                	andi	a4,a4,-8
        cache->objects_per_slab = (PGSIZE - sizeof(void*)) / size;
ffffffffc020092e:	01242423          	sw	s2,8(s0)
    if (heap_used + size > sizeof(static_heap))
ffffffffc0200932:	06dce763          	bltu	s9,a3,ffffffffc02009a0 <slub_init+0xec>
    void *ptr = &static_heap[heap_used];
ffffffffc0200936:	97ea                	add	a5,a5,s10
    heap_used = ((heap_used + size + 7) / 8) * 8;  // 8字节对齐
ffffffffc0200938:	00ebb023          	sd	a4,0(s7)
        slub_allocator.size_caches[i] = cache;
ffffffffc020093c:	008c3023          	sd	s0,0(s8)
        cache->cpu_cache.freelist = static_alloc(SLUB_CPU_CACHE_SIZE * sizeof(void*));
ffffffffc0200940:	e81c                	sd	a5,16(s0)
        cache->cpu_cache.avail = 0;
ffffffffc0200942:	01543c23          	sd	s5,24(s0)
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
ffffffffc0200946:	2485                	addiw	s1,s1,1
ffffffffc0200948:	47a9                	li	a5,10
ffffffffc020094a:	0c21                	addi	s8,s8,8
ffffffffc020094c:	04f48c63          	beq	s1,a5,ffffffffc02009a4 <slub_init+0xf0>
    if (heap_used + size > sizeof(static_heap))
ffffffffc0200950:	000bb783          	ld	a5,0(s7)
    void *ptr = &static_heap[heap_used];
ffffffffc0200954:	00fd0433          	add	s0,s10,a5
    heap_used = ((heap_used + size + 7) / 8) * 8;  // 8字节对齐
ffffffffc0200958:	05778713          	addi	a4,a5,87
    if (heap_used + size > sizeof(static_heap))
ffffffffc020095c:	05078793          	addi	a5,a5,80
    heap_used = ((heap_used + size + 7) / 8) * 8;  // 8字节对齐
ffffffffc0200960:	9b61                	andi	a4,a4,-8
        memset(cache, 0, sizeof(struct slub_cache));
ffffffffc0200962:	05000613          	li	a2,80
ffffffffc0200966:	4581                	li	a1,0
ffffffffc0200968:	8522                	mv	a0,s0
    return SLUB_MIN_SIZE << index;
ffffffffc020096a:	009a193b          	sllw	s2,s4,s1
    if (heap_used + size > sizeof(static_heap))
ffffffffc020096e:	fcfcece3          	bltu	s9,a5,ffffffffc0200946 <slub_init+0x92>
    heap_used = ((heap_used + size + 7) / 8) * 8;  // 8字节对齐
ffffffffc0200972:	00ebb023          	sd	a4,0(s7)
        memset(cache, 0, sizeof(struct slub_cache));
ffffffffc0200976:	4ad000ef          	jal	ra,ffffffffc0201622 <memset>
        cache->object_size = size;
ffffffffc020097a:	01243023          	sd	s2,0(s0)
        if (cache->objects_per_slab == 0)
ffffffffc020097e:	f929dbe3          	bge	s3,s2,ffffffffc0200914 <slub_init+0x60>
    if (heap_used + size > sizeof(static_heap))
ffffffffc0200982:	000bb783          	ld	a5,0(s7)
        list_init(&cache->partial_list);
ffffffffc0200986:	02040693          	addi	a3,s0,32
ffffffffc020098a:	f414                	sd	a3,40(s0)
    heap_used = ((heap_used + size + 7) / 8) * 8;  // 8字节对齐
ffffffffc020098c:	08778713          	addi	a4,a5,135
ffffffffc0200990:	f014                	sd	a3,32(s0)
            cache->objects_per_slab = 1;
ffffffffc0200992:	01642423          	sw	s6,8(s0)
    if (heap_used + size > sizeof(static_heap))
ffffffffc0200996:	08078693          	addi	a3,a5,128
    heap_used = ((heap_used + size + 7) / 8) * 8;  // 8字节对齐
ffffffffc020099a:	9b61                	andi	a4,a4,-8
    if (heap_used + size > sizeof(static_heap))
ffffffffc020099c:	f8dcfde3          	bgeu	s9,a3,ffffffffc0200936 <slub_init+0x82>
        return NULL;
ffffffffc02009a0:	4781                	li	a5,0
ffffffffc02009a2:	bf69                	j	ffffffffc020093c <slub_init+0x88>
}
ffffffffc02009a4:	6446                	ld	s0,80(sp)
ffffffffc02009a6:	60e6                	ld	ra,88(sp)
ffffffffc02009a8:	64a6                	ld	s1,72(sp)
ffffffffc02009aa:	6906                	ld	s2,64(sp)
ffffffffc02009ac:	79e2                	ld	s3,56(sp)
ffffffffc02009ae:	7a42                	ld	s4,48(sp)
ffffffffc02009b0:	7aa2                	ld	s5,40(sp)
ffffffffc02009b2:	7b02                	ld	s6,32(sp)
ffffffffc02009b4:	6be2                	ld	s7,24(sp)
ffffffffc02009b6:	6c42                	ld	s8,16(sp)
ffffffffc02009b8:	6ca2                	ld	s9,8(sp)
ffffffffc02009ba:	6d02                	ld	s10,0(sp)
    cprintf("SLUB allocator initialized with %d size classes\n", SLUB_NUM_SIZES);
ffffffffc02009bc:	45a9                	li	a1,10
ffffffffc02009be:	00001517          	auipc	a0,0x1
ffffffffc02009c2:	0c250513          	addi	a0,a0,194 # ffffffffc0201a80 <etext+0x44c>
}
ffffffffc02009c6:	6125                	addi	sp,sp,96
    cprintf("SLUB allocator initialized with %d size classes\n", SLUB_NUM_SIZES);
ffffffffc02009c8:	f84ff06f          	j	ffffffffc020014c <cprintf>

ffffffffc02009cc <slub_free_pages>:
static void slub_free_pages(struct Page *base, size_t n) {
ffffffffc02009cc:	1141                	addi	sp,sp,-16
ffffffffc02009ce:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02009d0:	c1f5                	beqz	a1,ffffffffc0200ab4 <slub_free_pages+0xe8>
    assert(PageReserved(base));
ffffffffc02009d2:	651c                	ld	a5,8(a0)
ffffffffc02009d4:	0017f713          	andi	a4,a5,1
ffffffffc02009d8:	cf55                	beqz	a4,ffffffffc0200a94 <slub_free_pages+0xc8>
    if (n == 1) {
ffffffffc02009da:	4685                	li	a3,1
ffffffffc02009dc:	4701                	li	a4,0
ffffffffc02009de:	00d59963          	bne	a1,a3,ffffffffc02009f0 <slub_free_pages+0x24>
ffffffffc02009e2:	a805                	j	ffffffffc0200a12 <slub_free_pages+0x46>
        assert(PageReserved(p));
ffffffffc02009e4:	791c                	ld	a5,48(a0)
ffffffffc02009e6:	02850513          	addi	a0,a0,40
ffffffffc02009ea:	0017f693          	andi	a3,a5,1
ffffffffc02009ee:	c2d9                	beqz	a3,ffffffffc0200a74 <slub_free_pages+0xa8>
        ClearPageSlab(p);
ffffffffc02009f0:	9be9                	andi	a5,a5,-6
ffffffffc02009f2:	e51c                	sd	a5,8(a0)
ffffffffc02009f4:	00052023          	sw	zero,0(a0)
    for (size_t i = 0; i < n; i++) {
ffffffffc02009f8:	0705                	addi	a4,a4,1
ffffffffc02009fa:	fee595e3          	bne	a1,a4,ffffffffc02009e4 <slub_free_pages+0x18>
    slub_allocator.total_frees++;
ffffffffc02009fe:	00004717          	auipc	a4,0x4
ffffffffc0200a02:	61a70713          	addi	a4,a4,1562 # ffffffffc0205018 <slub_allocator>
ffffffffc0200a06:	6f3c                	ld	a5,88(a4)
ffffffffc0200a08:	0785                	addi	a5,a5,1
ffffffffc0200a0a:	ef3c                	sd	a5,88(a4)
}
ffffffffc0200a0c:	60a2                	ld	ra,8(sp)
ffffffffc0200a0e:	0141                	addi	sp,sp,16
ffffffffc0200a10:	8082                	ret
    return slub_allocator.size_caches[idx];
ffffffffc0200a12:	00004717          	auipc	a4,0x4
ffffffffc0200a16:	60670713          	addi	a4,a4,1542 # ffffffffc0205018 <slub_allocator>
ffffffffc0200a1a:	6734                	ld	a3,72(a4)
        if (pcache != NULL) {
ffffffffc0200a1c:	c689                	beqz	a3,ffffffffc0200a26 <slub_free_pages+0x5a>
            if (cc->avail < cc->limit) {
ffffffffc0200a1e:	4e90                	lw	a2,24(a3)
ffffffffc0200a20:	4ecc                	lw	a1,28(a3)
ffffffffc0200a22:	02b66163          	bltu	a2,a1,ffffffffc0200a44 <slub_free_pages+0x78>
        ClearPageSlab(p);
ffffffffc0200a26:	9be9                	andi	a5,a5,-6
ffffffffc0200a28:	e51c                	sd	a5,8(a0)
    slub_allocator.total_frees++;
ffffffffc0200a2a:	6f3c                	ld	a5,88(a4)
    return slub_allocator.size_caches[idx];
ffffffffc0200a2c:	6734                	ld	a3,72(a4)
ffffffffc0200a2e:	00052023          	sw	zero,0(a0)
    slub_allocator.total_frees++;
ffffffffc0200a32:	0785                	addi	a5,a5,1
ffffffffc0200a34:	ef3c                	sd	a5,88(a4)
        if (pcache) pcache->nr_frees++;
ffffffffc0200a36:	daf9                	beqz	a3,ffffffffc0200a0c <slub_free_pages+0x40>
ffffffffc0200a38:	66bc                	ld	a5,72(a3)
}
ffffffffc0200a3a:	60a2                	ld	ra,8(sp)
        if (pcache) pcache->nr_frees++;
ffffffffc0200a3c:	0785                	addi	a5,a5,1
ffffffffc0200a3e:	e6bc                	sd	a5,72(a3)
}
ffffffffc0200a40:	0141                	addi	sp,sp,16
ffffffffc0200a42:	8082                	ret
                cc->freelist[cc->avail++] = (void *)base;
ffffffffc0200a44:	0106b803          	ld	a6,16(a3)
                slub_allocator.total_frees++;
ffffffffc0200a48:	6f2c                	ld	a1,88(a4)
                ClearPageSlab(base);
ffffffffc0200a4a:	9bed                	andi	a5,a5,-5
                cc->freelist[cc->avail++] = (void *)base;
ffffffffc0200a4c:	02061313          	slli	t1,a2,0x20
                ClearPageSlab(base);
ffffffffc0200a50:	e51c                	sd	a5,8(a0)
ffffffffc0200a52:	00052023          	sw	zero,0(a0)
                pcache->nr_frees++;
ffffffffc0200a56:	66bc                	ld	a5,72(a3)
                cc->freelist[cc->avail++] = (void *)base;
ffffffffc0200a58:	0016089b          	addiw	a7,a2,1
ffffffffc0200a5c:	01d35613          	srli	a2,t1,0x1d
ffffffffc0200a60:	0116ac23          	sw	a7,24(a3)
ffffffffc0200a64:	9642                	add	a2,a2,a6
ffffffffc0200a66:	e208                	sd	a0,0(a2)
                slub_allocator.total_frees++;
ffffffffc0200a68:	00158613          	addi	a2,a1,1
ffffffffc0200a6c:	ef30                	sd	a2,88(a4)
                pcache->nr_frees++;
ffffffffc0200a6e:	0785                	addi	a5,a5,1
ffffffffc0200a70:	e6bc                	sd	a5,72(a3)
                return;
ffffffffc0200a72:	bf69                	j	ffffffffc0200a0c <slub_free_pages+0x40>
        assert(PageReserved(p));
ffffffffc0200a74:	00001697          	auipc	a3,0x1
ffffffffc0200a78:	05c68693          	addi	a3,a3,92 # ffffffffc0201ad0 <etext+0x49c>
ffffffffc0200a7c:	00001617          	auipc	a2,0x1
ffffffffc0200a80:	f6c60613          	addi	a2,a2,-148 # ffffffffc02019e8 <etext+0x3b4>
ffffffffc0200a84:	1ad00593          	li	a1,429
ffffffffc0200a88:	00001517          	auipc	a0,0x1
ffffffffc0200a8c:	f7850513          	addi	a0,a0,-136 # ffffffffc0201a00 <etext+0x3cc>
ffffffffc0200a90:	f32ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(PageReserved(base));
ffffffffc0200a94:	00001697          	auipc	a3,0x1
ffffffffc0200a98:	02468693          	addi	a3,a3,36 # ffffffffc0201ab8 <etext+0x484>
ffffffffc0200a9c:	00001617          	auipc	a2,0x1
ffffffffc0200aa0:	f4c60613          	addi	a2,a2,-180 # ffffffffc02019e8 <etext+0x3b4>
ffffffffc0200aa4:	19400593          	li	a1,404
ffffffffc0200aa8:	00001517          	auipc	a0,0x1
ffffffffc0200aac:	f5850513          	addi	a0,a0,-168 # ffffffffc0201a00 <etext+0x3cc>
ffffffffc0200ab0:	f12ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc0200ab4:	00001697          	auipc	a3,0x1
ffffffffc0200ab8:	f2c68693          	addi	a3,a3,-212 # ffffffffc02019e0 <etext+0x3ac>
ffffffffc0200abc:	00001617          	auipc	a2,0x1
ffffffffc0200ac0:	f2c60613          	addi	a2,a2,-212 # ffffffffc02019e8 <etext+0x3b4>
ffffffffc0200ac4:	19300593          	li	a1,403
ffffffffc0200ac8:	00001517          	auipc	a0,0x1
ffffffffc0200acc:	f3850513          	addi	a0,a0,-200 # ffffffffc0201a00 <etext+0x3cc>
ffffffffc0200ad0:	ef2ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200ad4 <slub_alloc_pages>:
    assert(n > 0);
ffffffffc0200ad4:	c57d                	beqz	a0,ffffffffc0200bc2 <slub_alloc_pages+0xee>
    if (n == 1) {
ffffffffc0200ad6:	4785                	li	a5,1
ffffffffc0200ad8:	88aa                	mv	a7,a0
ffffffffc0200ada:	0af50063          	beq	a0,a5,ffffffffc0200b7a <slub_alloc_pages+0xa6>
    for (size_t i = 0; i < npage; i++) {
ffffffffc0200ade:	00014817          	auipc	a6,0x14
ffffffffc0200ae2:	5d283803          	ld	a6,1490(a6) # ffffffffc02150b0 <npage>
ffffffffc0200ae6:	08080263          	beqz	a6,ffffffffc0200b6a <slub_alloc_pages+0x96>
ffffffffc0200aea:	00014597          	auipc	a1,0x14
ffffffffc0200aee:	5ce5b583          	ld	a1,1486(a1) # ffffffffc02150b8 <pages>
        struct Page *p = pages + i;
ffffffffc0200af2:	4601                	li	a2,0
ffffffffc0200af4:	a031                	j	ffffffffc0200b00 <slub_alloc_pages+0x2c>
    for (size_t i = 0; i < npage; i++) {
ffffffffc0200af6:	0605                	addi	a2,a2,1
ffffffffc0200af8:	02858593          	addi	a1,a1,40
ffffffffc0200afc:	06c80763          	beq	a6,a2,ffffffffc0200b6a <slub_alloc_pages+0x96>
        if (PageReserved(p) || PageProperty(p))
ffffffffc0200b00:	0085b303          	ld	t1,8(a1)
        struct Page *p = pages + i;
ffffffffc0200b04:	852e                	mv	a0,a1
        if (PageReserved(p) || PageProperty(p))
ffffffffc0200b06:	86ae                	mv	a3,a1
ffffffffc0200b08:	00337793          	andi	a5,t1,3
ffffffffc0200b0c:	f7ed                	bnez	a5,ffffffffc0200af6 <slub_alloc_pages+0x22>
        for (size_t j = 0; j < n && (i + j) < npage; j++) {
ffffffffc0200b0e:	00f60733          	add	a4,a2,a5
ffffffffc0200b12:	05077563          	bgeu	a4,a6,ffffffffc0200b5c <slub_alloc_pages+0x88>
            if (PageReserved(pages + i + j) || PageProperty(pages + i + j))
ffffffffc0200b16:	6698                	ld	a4,8(a3)
ffffffffc0200b18:	8b0d                	andi	a4,a4,3
ffffffffc0200b1a:	e329                	bnez	a4,ffffffffc0200b5c <slub_alloc_pages+0x88>
            count++;
ffffffffc0200b1c:	0785                	addi	a5,a5,1
        for (size_t j = 0; j < n && (i + j) < npage; j++) {
ffffffffc0200b1e:	02868693          	addi	a3,a3,40
ffffffffc0200b22:	fef896e3          	bne	a7,a5,ffffffffc0200b0e <slub_alloc_pages+0x3a>
ffffffffc0200b26:	00289793          	slli	a5,a7,0x2
ffffffffc0200b2a:	97c6                	add	a5,a5,a7
ffffffffc0200b2c:	078e                	slli	a5,a5,0x3
ffffffffc0200b2e:	97ae                	add	a5,a5,a1
ffffffffc0200b30:	a019                	j	ffffffffc0200b36 <slub_alloc_pages+0x62>
            SetPageReserved(page + i);
ffffffffc0200b32:	0085b303          	ld	t1,8(a1)
ffffffffc0200b36:	00136313          	ori	t1,t1,1
ffffffffc0200b3a:	0065b423          	sd	t1,8(a1)
        for (size_t i = 0; i < n; i++) {
ffffffffc0200b3e:	02858593          	addi	a1,a1,40
ffffffffc0200b42:	feb798e3          	bne	a5,a1,ffffffffc0200b32 <slub_alloc_pages+0x5e>
        slub_allocator.total_allocs++;
ffffffffc0200b46:	00004717          	auipc	a4,0x4
ffffffffc0200b4a:	4d270713          	addi	a4,a4,1234 # ffffffffc0205018 <slub_allocator>
ffffffffc0200b4e:	6b3c                	ld	a5,80(a4)
        if (n == 1) {
ffffffffc0200b50:	4685                	li	a3,1
        slub_allocator.total_allocs++;
ffffffffc0200b52:	0785                	addi	a5,a5,1
ffffffffc0200b54:	eb3c                	sd	a5,80(a4)
        if (n == 1) {
ffffffffc0200b56:	00d88c63          	beq	a7,a3,ffffffffc0200b6e <slub_alloc_pages+0x9a>
}
ffffffffc0200b5a:	8082                	ret
        if (count >= n) {
ffffffffc0200b5c:	fd17f5e3          	bgeu	a5,a7,ffffffffc0200b26 <slub_alloc_pages+0x52>
    for (size_t i = 0; i < npage; i++) {
ffffffffc0200b60:	0605                	addi	a2,a2,1
ffffffffc0200b62:	02858593          	addi	a1,a1,40
ffffffffc0200b66:	f8c81de3          	bne	a6,a2,ffffffffc0200b00 <slub_alloc_pages+0x2c>
ffffffffc0200b6a:	4501                	li	a0,0
ffffffffc0200b6c:	8082                	ret
    return slub_allocator.size_caches[idx];
ffffffffc0200b6e:	673c                	ld	a5,72(a4)
            if (pcache) pcache->nr_allocs++;
ffffffffc0200b70:	d7ed                	beqz	a5,ffffffffc0200b5a <slub_alloc_pages+0x86>
ffffffffc0200b72:	63b8                	ld	a4,64(a5)
ffffffffc0200b74:	0705                	addi	a4,a4,1
ffffffffc0200b76:	e3b8                	sd	a4,64(a5)
}
ffffffffc0200b78:	8082                	ret
    return slub_allocator.size_caches[idx];
ffffffffc0200b7a:	00004717          	auipc	a4,0x4
ffffffffc0200b7e:	49e70713          	addi	a4,a4,1182 # ffffffffc0205018 <slub_allocator>
ffffffffc0200b82:	673c                	ld	a5,72(a4)
        if (pcache != NULL) {
ffffffffc0200b84:	dfa9                	beqz	a5,ffffffffc0200ade <slub_alloc_pages+0xa>
            if (cc->avail > 0) {
ffffffffc0200b86:	4f94                	lw	a3,24(a5)
ffffffffc0200b88:	dab9                	beqz	a3,ffffffffc0200ade <slub_alloc_pages+0xa>
                void *obj = cc->freelist[--cc->avail];
ffffffffc0200b8a:	6b90                	ld	a2,16(a5)
ffffffffc0200b8c:	36fd                	addiw	a3,a3,-1
ffffffffc0200b8e:	02069513          	slli	a0,a3,0x20
ffffffffc0200b92:	01d55593          	srli	a1,a0,0x1d
ffffffffc0200b96:	962e                	add	a2,a2,a1
ffffffffc0200b98:	6208                	ld	a0,0(a2)
                slub_allocator.total_allocs++;
ffffffffc0200b9a:	05073803          	ld	a6,80(a4)
                slub_allocator.cache_hits++;
ffffffffc0200b9e:	732c                	ld	a1,96(a4)
                SetPageReserved(p);
ffffffffc0200ba0:	00853883          	ld	a7,8(a0)
                pcache->nr_allocs++;
ffffffffc0200ba4:	63b0                	ld	a2,64(a5)
                void *obj = cc->freelist[--cc->avail];
ffffffffc0200ba6:	cf94                	sw	a3,24(a5)
                SetPageReserved(p);
ffffffffc0200ba8:	0018e693          	ori	a3,a7,1
ffffffffc0200bac:	e514                	sd	a3,8(a0)
                slub_allocator.total_allocs++;
ffffffffc0200bae:	0805                	addi	a6,a6,1
                slub_allocator.cache_hits++;
ffffffffc0200bb0:	00158693          	addi	a3,a1,1
                slub_allocator.total_allocs++;
ffffffffc0200bb4:	05073823          	sd	a6,80(a4)
                slub_allocator.cache_hits++;
ffffffffc0200bb8:	f334                	sd	a3,96(a4)
                pcache->nr_allocs++;
ffffffffc0200bba:	00160713          	addi	a4,a2,1
ffffffffc0200bbe:	e3b8                	sd	a4,64(a5)
                return p;
ffffffffc0200bc0:	8082                	ret
static struct Page *slub_alloc_pages(size_t n) {
ffffffffc0200bc2:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200bc4:	00001697          	auipc	a3,0x1
ffffffffc0200bc8:	e1c68693          	addi	a3,a3,-484 # ffffffffc02019e0 <etext+0x3ac>
ffffffffc0200bcc:	00001617          	auipc	a2,0x1
ffffffffc0200bd0:	e1c60613          	addi	a2,a2,-484 # ffffffffc02019e8 <etext+0x3b4>
ffffffffc0200bd4:	14f00593          	li	a1,335
ffffffffc0200bd8:	00001517          	auipc	a0,0x1
ffffffffc0200bdc:	e2850513          	addi	a0,a0,-472 # ffffffffc0201a00 <etext+0x3cc>
static struct Page *slub_alloc_pages(size_t n) {
ffffffffc0200be0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200be2:	de0ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200be6 <slub_malloc>:
    if (size == 0) return NULL;
ffffffffc0200be6:	1e050963          	beqz	a0,ffffffffc0200dd8 <slub_malloc+0x1f2>
    size = ROUNDUP(size, SLUB_ALIGN);
ffffffffc0200bea:	00750793          	addi	a5,a0,7
ffffffffc0200bee:	9be1                	andi	a5,a5,-8
    if (size <= SLUB_MIN_SIZE) return 0;
ffffffffc0200bf0:	4721                	li	a4,8
ffffffffc0200bf2:	0ef77263          	bgeu	a4,a5,ffffffffc0200cd6 <slub_malloc+0xf0>
    if (size > SLUB_MAX_SIZE) return -1;
ffffffffc0200bf6:	6705                	lui	a4,0x1
ffffffffc0200bf8:	1ef76063          	bltu	a4,a5,ffffffffc0200dd8 <slub_malloc+0x1f2>
    size_t temp = size - 1;
ffffffffc0200bfc:	17fd                	addi	a5,a5,-1
    int shift = 0;
ffffffffc0200bfe:	4701                	li	a4,0
        temp >>= 1;
ffffffffc0200c00:	8385                	srli	a5,a5,0x1
        shift++;
ffffffffc0200c02:	86ba                	mv	a3,a4
ffffffffc0200c04:	2705                	addiw	a4,a4,1
    while (temp > 0) {
ffffffffc0200c06:	ffed                	bnez	a5,ffffffffc0200c00 <slub_malloc+0x1a>
    return shift - SLUB_SHIFT_LOW;
ffffffffc0200c08:	36f9                	addiw	a3,a3,-2
    if (idx < 0 || idx >= SLUB_NUM_SIZES) return NULL;
ffffffffc0200c0a:	47a5                	li	a5,9
ffffffffc0200c0c:	1cd7e663          	bltu	a5,a3,ffffffffc0200dd8 <slub_malloc+0x1f2>
void *slub_malloc(size_t size) {
ffffffffc0200c10:	7179                	addi	sp,sp,-48
ffffffffc0200c12:	e84a                	sd	s2,16(sp)
    return slub_allocator.size_caches[idx];
ffffffffc0200c14:	068e                	slli	a3,a3,0x3
ffffffffc0200c16:	00004917          	auipc	s2,0x4
ffffffffc0200c1a:	40290913          	addi	s2,s2,1026 # ffffffffc0205018 <slub_allocator>
ffffffffc0200c1e:	96ca                	add	a3,a3,s2
void *slub_malloc(size_t size) {
ffffffffc0200c20:	ec26                	sd	s1,24(sp)
    return slub_allocator.size_caches[idx];
ffffffffc0200c22:	6284                	ld	s1,0(a3)
void *slub_malloc(size_t size) {
ffffffffc0200c24:	f406                	sd	ra,40(sp)
ffffffffc0200c26:	f022                	sd	s0,32(sp)
ffffffffc0200c28:	e44e                	sd	s3,8(sp)
    if (cache == NULL) return NULL;
ffffffffc0200c2a:	ccd1                	beqz	s1,ffffffffc0200cc6 <slub_malloc+0xe0>
    if (cc->avail > 0) {
ffffffffc0200c2c:	4c80                	lw	s0,24(s1)
ffffffffc0200c2e:	ec39                	bnez	s0,ffffffffc0200c8c <slub_malloc+0xa6>
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
ffffffffc0200c30:	0284b983          	ld	s3,40(s1)
    if (!list_empty(&cache->partial_list)) {
ffffffffc0200c34:	02048793          	addi	a5,s1,32
ffffffffc0200c38:	0af98163          	beq	s3,a5,ffffffffc0200cda <slub_malloc+0xf4>
    void *obj = info->freelist;
ffffffffc0200c3c:	fe89b503          	ld	a0,-24(s3) # fe8 <kern_entry-0xffffffffc01ff018>
    info->inuse++;
ffffffffc0200c40:	ff09a783          	lw	a5,-16(s3)
        if (info->inuse == info->objects) {
ffffffffc0200c44:	ff49a683          	lw	a3,-12(s3)
    info->freelist = *(void **)obj;
ffffffffc0200c48:	6110                	ld	a2,0(a0)
    info->inuse++;
ffffffffc0200c4a:	0017871b          	addiw	a4,a5,1
ffffffffc0200c4e:	fee9a823          	sw	a4,-16(s3)
    info->freelist = *(void **)obj;
ffffffffc0200c52:	fec9b423          	sd	a2,-24(s3)
        if (info->inuse == info->objects) {
ffffffffc0200c56:	00e69c63          	bne	a3,a4,ffffffffc0200c6e <slub_malloc+0x88>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200c5a:	0009b703          	ld	a4,0(s3)
ffffffffc0200c5e:	0089b783          	ld	a5,8(s3)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200c62:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200c64:	e398                	sd	a4,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0200c66:	0139b423          	sd	s3,8(s3)
ffffffffc0200c6a:	0139b023          	sd	s3,0(s3)
    slub_allocator.total_allocs++;
ffffffffc0200c6e:	05093703          	ld	a4,80(s2)
    cache->nr_allocs++;
ffffffffc0200c72:	60bc                	ld	a5,64(s1)
}
ffffffffc0200c74:	70a2                	ld	ra,40(sp)
ffffffffc0200c76:	7402                	ld	s0,32(sp)
    slub_allocator.total_allocs++;
ffffffffc0200c78:	0705                	addi	a4,a4,1
ffffffffc0200c7a:	04e93823          	sd	a4,80(s2)
    cache->nr_allocs++;
ffffffffc0200c7e:	0785                	addi	a5,a5,1
ffffffffc0200c80:	e0bc                	sd	a5,64(s1)
}
ffffffffc0200c82:	6942                	ld	s2,16(sp)
ffffffffc0200c84:	64e2                	ld	s1,24(sp)
ffffffffc0200c86:	69a2                	ld	s3,8(sp)
ffffffffc0200c88:	6145                	addi	sp,sp,48
ffffffffc0200c8a:	8082                	ret
        slub_allocator.total_allocs++;
ffffffffc0200c8c:	05093683          	ld	a3,80(s2)
        slub_allocator.cache_hits++;
ffffffffc0200c90:	06093703          	ld	a4,96(s2)
        void *obj = cc->freelist[--cc->avail];
ffffffffc0200c94:	6890                	ld	a2,16(s1)
ffffffffc0200c96:	347d                	addiw	s0,s0,-1
        cache->nr_allocs++;
ffffffffc0200c98:	60bc                	ld	a5,64(s1)
        void *obj = cc->freelist[--cc->avail];
ffffffffc0200c9a:	02041513          	slli	a0,s0,0x20
ffffffffc0200c9e:	01d55593          	srli	a1,a0,0x1d
ffffffffc0200ca2:	cc80                	sw	s0,24(s1)
}
ffffffffc0200ca4:	70a2                	ld	ra,40(sp)
ffffffffc0200ca6:	7402                	ld	s0,32(sp)
        void *obj = cc->freelist[--cc->avail];
ffffffffc0200ca8:	962e                	add	a2,a2,a1
        slub_allocator.total_allocs++;
ffffffffc0200caa:	0685                	addi	a3,a3,1
        slub_allocator.cache_hits++;
ffffffffc0200cac:	0705                	addi	a4,a4,1
        void *obj = cc->freelist[--cc->avail];
ffffffffc0200cae:	6208                	ld	a0,0(a2)
        cache->nr_allocs++;
ffffffffc0200cb0:	0785                	addi	a5,a5,1
        slub_allocator.total_allocs++;
ffffffffc0200cb2:	04d93823          	sd	a3,80(s2)
        slub_allocator.cache_hits++;
ffffffffc0200cb6:	06e93023          	sd	a4,96(s2)
        cache->nr_allocs++;
ffffffffc0200cba:	e0bc                	sd	a5,64(s1)
}
ffffffffc0200cbc:	6942                	ld	s2,16(sp)
ffffffffc0200cbe:	64e2                	ld	s1,24(sp)
ffffffffc0200cc0:	69a2                	ld	s3,8(sp)
ffffffffc0200cc2:	6145                	addi	sp,sp,48
ffffffffc0200cc4:	8082                	ret
ffffffffc0200cc6:	70a2                	ld	ra,40(sp)
ffffffffc0200cc8:	7402                	ld	s0,32(sp)
ffffffffc0200cca:	64e2                	ld	s1,24(sp)
ffffffffc0200ccc:	6942                	ld	s2,16(sp)
ffffffffc0200cce:	69a2                	ld	s3,8(sp)
    if (cache == NULL) return NULL;
ffffffffc0200cd0:	4501                	li	a0,0
}
ffffffffc0200cd2:	6145                	addi	sp,sp,48
ffffffffc0200cd4:	8082                	ret
    if (size <= SLUB_MIN_SIZE) return 0;
ffffffffc0200cd6:	4681                	li	a3,0
ffffffffc0200cd8:	bf25                	j	ffffffffc0200c10 <slub_malloc+0x2a>
    struct Page *page = slub_alloc_pages(1);
ffffffffc0200cda:	4505                	li	a0,1
ffffffffc0200cdc:	df9ff0ef          	jal	ra,ffffffffc0200ad4 <slub_alloc_pages>
    if (page == NULL) return NULL;
ffffffffc0200ce0:	d17d                	beqz	a0,ffffffffc0200cc6 <slub_malloc+0xe0>
    size_t page_idx = page - pages;
ffffffffc0200ce2:	00014e97          	auipc	t4,0x14
ffffffffc0200ce6:	3d6e8e93          	addi	t4,t4,982 # ffffffffc02150b8 <pages>
ffffffffc0200cea:	000eb883          	ld	a7,0(t4)
ffffffffc0200cee:	00001317          	auipc	t1,0x1
ffffffffc0200cf2:	26a33303          	ld	t1,618(t1) # ffffffffc0201f58 <nbase+0x8>
    SetPageSlab(page);
ffffffffc0200cf6:	6514                	ld	a3,8(a0)
    size_t page_idx = page - pages;
ffffffffc0200cf8:	41150733          	sub	a4,a0,a7
ffffffffc0200cfc:	40375793          	srai	a5,a4,0x3
ffffffffc0200d00:	026787b3          	mul	a5,a5,t1
    if (page_idx < slub_allocator.max_pages)
ffffffffc0200d04:	07893e03          	ld	t3,120(s2)
    SetPageSlab(page);
ffffffffc0200d08:	0046e613          	ori	a2,a3,4
    if (page_idx < slub_allocator.max_pages)
ffffffffc0200d0c:	0dc7f863          	bgeu	a5,t3,ffffffffc0200ddc <slub_malloc+0x1f6>
        return &slub_allocator.page_infos[page_idx];
ffffffffc0200d10:	07093883          	ld	a7,112(s2)
    info->objects = cache->objects_per_slab;
ffffffffc0200d14:	0084af03          	lw	t5,8(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d18:	00001697          	auipc	a3,0x1
ffffffffc0200d1c:	2386b683          	ld	a3,568(a3) # ffffffffc0201f50 <nbase>
        return &slub_allocator.page_infos[page_idx];
ffffffffc0200d20:	98ba                	add	a7,a7,a4
ffffffffc0200d22:	96be                	add	a3,a3,a5
    SetPageSlab(page);
ffffffffc0200d24:	e510                	sd	a2,8(a0)
    list_init(&info->slab_list);
ffffffffc0200d26:	01888793          	addi	a5,a7,24
    char *base = (char *)page2kva(page);
ffffffffc0200d2a:	00014717          	auipc	a4,0x14
ffffffffc0200d2e:	3ae73703          	ld	a4,942(a4) # ffffffffc02150d8 <va_pa_offset>
    return page2ppn(page) << PGSHIFT;
ffffffffc0200d32:	06b2                	slli	a3,a3,0xc
ffffffffc0200d34:	96ba                	add	a3,a3,a4
ffffffffc0200d36:	ffff081b          	addiw	a6,t5,-1
ffffffffc0200d3a:	02f8b023          	sd	a5,32(a7)
ffffffffc0200d3e:	00f8bc23          	sd	a5,24(a7)
    info->cache = cache;
ffffffffc0200d42:	0098b823          	sd	s1,16(a7)
    info->objects = cache->objects_per_slab;
ffffffffc0200d46:	01e8a623          	sw	t5,12(a7)
    info->inuse = 0;
ffffffffc0200d4a:	0008a423          	sw	zero,8(a7)
    for (unsigned int i = 0; i + 1 < cache->objects_per_slab; i++) {
ffffffffc0200d4e:	4705                	li	a4,1
    size_t objsz = cache->object_size;
ffffffffc0200d50:	6090                	ld	a2,0(s1)
    char *base = (char *)page2kva(page);
ffffffffc0200d52:	87b6                	mv	a5,a3
    for (unsigned int i = 0; i + 1 < cache->objects_per_slab; i++) {
ffffffffc0200d54:	0008059b          	sext.w	a1,a6
ffffffffc0200d58:	01e77863          	bgeu	a4,t5,ffffffffc0200d68 <slub_malloc+0x182>
        void *cur = base + i * objsz;
ffffffffc0200d5c:	873e                	mv	a4,a5
        void *nxt = base + (i + 1) * objsz;
ffffffffc0200d5e:	97b2                	add	a5,a5,a2
        *(void **)cur = nxt;
ffffffffc0200d60:	e31c                	sd	a5,0(a4)
    for (unsigned int i = 0; i + 1 < cache->objects_per_slab; i++) {
ffffffffc0200d62:	2405                	addiw	s0,s0,1
ffffffffc0200d64:	fe859ce3          	bne	a1,s0,ffffffffc0200d5c <slub_malloc+0x176>
    void *last = base + (cache->objects_per_slab - 1) * objsz;
ffffffffc0200d68:	1802                	slli	a6,a6,0x20
ffffffffc0200d6a:	02085813          	srli	a6,a6,0x20
ffffffffc0200d6e:	02c80633          	mul	a2,a6,a2
    cache->nr_slabs++;
ffffffffc0200d72:	788c                	ld	a1,48(s1)
    slub_allocator.nr_slabs++;
ffffffffc0200d74:	06893703          	ld	a4,104(s2)
    cache->nr_slabs++;
ffffffffc0200d78:	0585                	addi	a1,a1,1
    slub_allocator.nr_slabs++;
ffffffffc0200d7a:	0705                	addi	a4,a4,1
    *(void **)last = NULL;
ffffffffc0200d7c:	9636                	add	a2,a2,a3
ffffffffc0200d7e:	00063023          	sd	zero,0(a2)
    size_t page_idx = page - pages;
ffffffffc0200d82:	000eb783          	ld	a5,0(t4)
    info->freelist = base;
ffffffffc0200d86:	00d8b023          	sd	a3,0(a7)
    cache->nr_slabs++;
ffffffffc0200d8a:	f88c                	sd	a1,48(s1)
    size_t page_idx = page - pages;
ffffffffc0200d8c:	8d1d                	sub	a0,a0,a5
ffffffffc0200d8e:	40355793          	srai	a5,a0,0x3
ffffffffc0200d92:	026787b3          	mul	a5,a5,t1
    slub_allocator.nr_slabs++;
ffffffffc0200d96:	06e93423          	sd	a4,104(s2)
    if (page_idx < slub_allocator.max_pages)
ffffffffc0200d9a:	05c7f563          	bgeu	a5,t3,ffffffffc0200de4 <slub_malloc+0x1fe>
        return &slub_allocator.page_infos[page_idx];
ffffffffc0200d9e:	07093783          	ld	a5,112(s2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200da2:	7490                	ld	a2,40(s1)
ffffffffc0200da4:	97aa                	add	a5,a5,a0
    list_add(&cache->partial_list, &info->slab_list);
ffffffffc0200da6:	01878693          	addi	a3,a5,24
    prev->next = next->prev = elm;
ffffffffc0200daa:	e214                	sd	a3,0(a2)
    void *obj = info->freelist;
ffffffffc0200dac:	6388                	ld	a0,0(a5)
ffffffffc0200dae:	f494                	sd	a3,40(s1)
    info->inuse++;
ffffffffc0200db0:	4798                	lw	a4,8(a5)
    elm->next = next;
ffffffffc0200db2:	f390                	sd	a2,32(a5)
    elm->prev = prev;
ffffffffc0200db4:	0137bc23          	sd	s3,24(a5)
    info->freelist = *(void **)obj;
ffffffffc0200db8:	610c                	ld	a1,0(a0)
    if (info->inuse == info->objects) {
ffffffffc0200dba:	00c7a803          	lw	a6,12(a5)
    info->inuse++;
ffffffffc0200dbe:	2705                	addiw	a4,a4,1
    info->freelist = *(void **)obj;
ffffffffc0200dc0:	e38c                	sd	a1,0(a5)
    info->inuse++;
ffffffffc0200dc2:	c798                	sw	a4,8(a5)
ffffffffc0200dc4:	0007059b          	sext.w	a1,a4
    if (info->inuse == info->objects) {
ffffffffc0200dc8:	eab813e3          	bne	a6,a1,ffffffffc0200c6e <slub_malloc+0x88>
    prev->next = next;
ffffffffc0200dcc:	f490                	sd	a2,40(s1)
    next->prev = prev;
ffffffffc0200dce:	01363023          	sd	s3,0(a2)
    elm->prev = elm->next = elm;
ffffffffc0200dd2:	f394                	sd	a3,32(a5)
ffffffffc0200dd4:	ef94                	sd	a3,24(a5)
}
ffffffffc0200dd6:	bd61                	j	ffffffffc0200c6e <slub_malloc+0x88>
    if (cache == NULL) return NULL;
ffffffffc0200dd8:	4501                	li	a0,0
}
ffffffffc0200dda:	8082                	ret
    SetPageSlab(page);
ffffffffc0200ddc:	e510                	sd	a2,8(a0)
    info->cache = cache;
ffffffffc0200dde:	00903823          	sd	s1,16(zero) # 10 <kern_entry-0xffffffffc01ffff0>
ffffffffc0200de2:	9002                	ebreak
    __list_add(elm, listelm, listelm->next);
ffffffffc0200de4:	749c                	ld	a5,40(s1)
    list_add(&cache->partial_list, &info->slab_list);
ffffffffc0200de6:	4761                	li	a4,24
    prev->next = next->prev = elm;
ffffffffc0200de8:	e398                	sd	a4,0(a5)
ffffffffc0200dea:	f498                	sd	a4,40(s1)
    elm->next = next;
ffffffffc0200dec:	02f03023          	sd	a5,32(zero) # 20 <kern_entry-0xffffffffc01fffe0>
ffffffffc0200df0:	9002                	ebreak

ffffffffc0200df2 <slub_free>:
    if (ptr == NULL) return;
ffffffffc0200df2:	0e050f63          	beqz	a0,ffffffffc0200ef0 <slub_free+0xfe>
void slub_free(void *ptr) {
ffffffffc0200df6:	1101                	addi	sp,sp,-32
ffffffffc0200df8:	ec06                	sd	ra,24(sp)
ffffffffc0200dfa:	e822                	sd	s0,16(sp)
ffffffffc0200dfc:	e426                	sd	s1,8(sp)
    uintptr_t pa = PADDR(ptr);
ffffffffc0200dfe:	c02007b7          	lui	a5,0xc0200
ffffffffc0200e02:	10f56d63          	bltu	a0,a5,ffffffffc0200f1c <slub_free+0x12a>
ffffffffc0200e06:	00014797          	auipc	a5,0x14
ffffffffc0200e0a:	2d27b783          	ld	a5,722(a5) # ffffffffc02150d8 <va_pa_offset>
ffffffffc0200e0e:	40f507b3          	sub	a5,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc0200e12:	83b1                	srli	a5,a5,0xc
ffffffffc0200e14:	00014717          	auipc	a4,0x14
ffffffffc0200e18:	29c73703          	ld	a4,668(a4) # ffffffffc02150b0 <npage>
ffffffffc0200e1c:	10e7fd63          	bgeu	a5,a4,ffffffffc0200f36 <slub_free+0x144>
    return &pages[PPN(pa) - nbase];
ffffffffc0200e20:	00001717          	auipc	a4,0x1
ffffffffc0200e24:	13073703          	ld	a4,304(a4) # ffffffffc0201f50 <nbase>
ffffffffc0200e28:	8f99                	sub	a5,a5,a4
ffffffffc0200e2a:	00279713          	slli	a4,a5,0x2
ffffffffc0200e2e:	97ba                	add	a5,a5,a4
ffffffffc0200e30:	078e                	slli	a5,a5,0x3
    size_t page_idx = page - pages;
ffffffffc0200e32:	00001697          	auipc	a3,0x1
ffffffffc0200e36:	1266b683          	ld	a3,294(a3) # ffffffffc0201f58 <nbase+0x8>
ffffffffc0200e3a:	4037d713          	srai	a4,a5,0x3
ffffffffc0200e3e:	02d70733          	mul	a4,a4,a3
    if (page_idx < slub_allocator.max_pages)
ffffffffc0200e42:	00004417          	auipc	s0,0x4
ffffffffc0200e46:	1d640413          	addi	s0,s0,470 # ffffffffc0205018 <slub_allocator>
ffffffffc0200e4a:	7c34                	ld	a3,120(s0)
ffffffffc0200e4c:	04d77363          	bgeu	a4,a3,ffffffffc0200e92 <slub_free+0xa0>
        return &slub_allocator.page_infos[page_idx];
ffffffffc0200e50:	7838                	ld	a4,112(s0)
ffffffffc0200e52:	973e                	add	a4,a4,a5
    if (info == NULL || info->cache == NULL) return; // 非 SLUB 对象
ffffffffc0200e54:	cf1d                	beqz	a4,ffffffffc0200e92 <slub_free+0xa0>
ffffffffc0200e56:	6b04                	ld	s1,16(a4)
ffffffffc0200e58:	cc8d                	beqz	s1,ffffffffc0200e92 <slub_free+0xa0>
    if (cc->avail < cc->limit) {
ffffffffc0200e5a:	4c94                	lw	a3,24(s1)
ffffffffc0200e5c:	4cd0                	lw	a2,28(s1)
ffffffffc0200e5e:	08c6ea63          	bltu	a3,a2,ffffffffc0200ef2 <slub_free+0x100>
    info->inuse--;
ffffffffc0200e62:	4710                	lw	a2,8(a4)
    *(void **)obj = info->freelist;
ffffffffc0200e64:	00073883          	ld	a7,0(a4)
    if (info->inuse + 1 == info->objects) {
ffffffffc0200e68:	00c72803          	lw	a6,12(a4)
ffffffffc0200e6c:	00014597          	auipc	a1,0x14
ffffffffc0200e70:	24c5b583          	ld	a1,588(a1) # ffffffffc02150b8 <pages>
    info->inuse--;
ffffffffc0200e74:	fff6069b          	addiw	a3,a2,-1
    *(void **)obj = info->freelist;
ffffffffc0200e78:	01153023          	sd	a7,0(a0)
    info->freelist = obj;
ffffffffc0200e7c:	e308                	sd	a0,0(a4)
    info->inuse--;
ffffffffc0200e7e:	c714                	sw	a3,8(a4)
    if (info->inuse + 1 == info->objects) {
ffffffffc0200e80:	00c80e63          	beq	a6,a2,ffffffffc0200e9c <slub_free+0xaa>
    if (info->inuse == 0) {
ffffffffc0200e84:	ca8d                	beqz	a3,ffffffffc0200eb6 <slub_free+0xc4>
    slub_allocator.total_frees++;
ffffffffc0200e86:	6c38                	ld	a4,88(s0)
    cache->nr_frees++;
ffffffffc0200e88:	64bc                	ld	a5,72(s1)
    slub_allocator.total_frees++;
ffffffffc0200e8a:	0705                	addi	a4,a4,1
ffffffffc0200e8c:	ec38                	sd	a4,88(s0)
    cache->nr_frees++;
ffffffffc0200e8e:	0785                	addi	a5,a5,1
ffffffffc0200e90:	e4bc                	sd	a5,72(s1)
}
ffffffffc0200e92:	60e2                	ld	ra,24(sp)
ffffffffc0200e94:	6442                	ld	s0,16(sp)
ffffffffc0200e96:	64a2                	ld	s1,8(sp)
ffffffffc0200e98:	6105                	addi	sp,sp,32
ffffffffc0200e9a:	8082                	ret
    __list_add(elm, listelm, listelm->next);
ffffffffc0200e9c:	0284b803          	ld	a6,40(s1)
        list_add(&cache->partial_list, &info->slab_list);
ffffffffc0200ea0:	01870613          	addi	a2,a4,24
ffffffffc0200ea4:	02048513          	addi	a0,s1,32
    prev->next = next->prev = elm;
ffffffffc0200ea8:	00c83023          	sd	a2,0(a6)
ffffffffc0200eac:	f490                	sd	a2,40(s1)
    elm->next = next;
ffffffffc0200eae:	03073023          	sd	a6,32(a4)
    elm->prev = prev;
ffffffffc0200eb2:	ef08                	sd	a0,24(a4)
    if (info->inuse == 0) {
ffffffffc0200eb4:	fae9                	bnez	a3,ffffffffc0200e86 <slub_free+0x94>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200eb6:	01873883          	ld	a7,24(a4)
ffffffffc0200eba:	02073803          	ld	a6,32(a4)
ffffffffc0200ebe:	00f58533          	add	a0,a1,a5
        ClearPageSlab(page);
ffffffffc0200ec2:	6510                	ld	a2,8(a0)
        cache->nr_slabs--;
ffffffffc0200ec4:	7894                	ld	a3,48(s1)
    prev->next = next;
ffffffffc0200ec6:	0108b423          	sd	a6,8(a7)
        slub_allocator.nr_slabs--;
ffffffffc0200eca:	743c                	ld	a5,104(s0)
    next->prev = prev;
ffffffffc0200ecc:	01183023          	sd	a7,0(a6)
        list_del_init(&info->slab_list);
ffffffffc0200ed0:	01870593          	addi	a1,a4,24
    elm->prev = elm->next = elm;
ffffffffc0200ed4:	f30c                	sd	a1,32(a4)
ffffffffc0200ed6:	ef0c                	sd	a1,24(a4)
        ClearPageSlab(page);
ffffffffc0200ed8:	ffb67713          	andi	a4,a2,-5
ffffffffc0200edc:	e518                	sd	a4,8(a0)
        cache->nr_slabs--;
ffffffffc0200ede:	fff68713          	addi	a4,a3,-1
ffffffffc0200ee2:	f898                	sd	a4,48(s1)
        slub_allocator.nr_slabs--;
ffffffffc0200ee4:	17fd                	addi	a5,a5,-1
        slub_free_pages(page, 1);
ffffffffc0200ee6:	4585                	li	a1,1
        slub_allocator.nr_slabs--;
ffffffffc0200ee8:	f43c                	sd	a5,104(s0)
        slub_free_pages(page, 1);
ffffffffc0200eea:	ae3ff0ef          	jal	ra,ffffffffc02009cc <slub_free_pages>
ffffffffc0200eee:	bf61                	j	ffffffffc0200e86 <slub_free+0x94>
ffffffffc0200ef0:	8082                	ret
        cc->freelist[cc->avail++] = ptr;
ffffffffc0200ef2:	6890                	ld	a2,16(s1)
        slub_allocator.total_frees++;
ffffffffc0200ef4:	6c38                	ld	a4,88(s0)
        cc->freelist[cc->avail++] = ptr;
ffffffffc0200ef6:	02069813          	slli	a6,a3,0x20
ffffffffc0200efa:	0016859b          	addiw	a1,a3,1
ffffffffc0200efe:	01d85693          	srli	a3,a6,0x1d
        cache->nr_frees++;
ffffffffc0200f02:	64bc                	ld	a5,72(s1)
        cc->freelist[cc->avail++] = ptr;
ffffffffc0200f04:	cc8c                	sw	a1,24(s1)
ffffffffc0200f06:	96b2                	add	a3,a3,a2
ffffffffc0200f08:	e288                	sd	a0,0(a3)
        slub_allocator.total_frees++;
ffffffffc0200f0a:	0705                	addi	a4,a4,1
ffffffffc0200f0c:	ec38                	sd	a4,88(s0)
}
ffffffffc0200f0e:	60e2                	ld	ra,24(sp)
ffffffffc0200f10:	6442                	ld	s0,16(sp)
        cache->nr_frees++;
ffffffffc0200f12:	0785                	addi	a5,a5,1
ffffffffc0200f14:	e4bc                	sd	a5,72(s1)
}
ffffffffc0200f16:	64a2                	ld	s1,8(sp)
ffffffffc0200f18:	6105                	addi	sp,sp,32
ffffffffc0200f1a:	8082                	ret
    uintptr_t pa = PADDR(ptr);
ffffffffc0200f1c:	86aa                	mv	a3,a0
ffffffffc0200f1e:	00001617          	auipc	a2,0x1
ffffffffc0200f22:	a0a60613          	addi	a2,a2,-1526 # ffffffffc0201928 <etext+0x2f4>
ffffffffc0200f26:	0e600593          	li	a1,230
ffffffffc0200f2a:	00001517          	auipc	a0,0x1
ffffffffc0200f2e:	ad650513          	addi	a0,a0,-1322 # ffffffffc0201a00 <etext+0x3cc>
ffffffffc0200f32:	a90ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200f36:	00001617          	auipc	a2,0x1
ffffffffc0200f3a:	a1a60613          	addi	a2,a2,-1510 # ffffffffc0201950 <etext+0x31c>
ffffffffc0200f3e:	06a00593          	li	a1,106
ffffffffc0200f42:	00001517          	auipc	a0,0x1
ffffffffc0200f46:	a2e50513          	addi	a0,a0,-1490 # ffffffffc0201970 <etext+0x33c>
ffffffffc0200f4a:	a78ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200f4e <slub_check>:
    free_page(p1);
    free_page(p2);
}

// SLUB特定检查函数
static void slub_check(void) {
ffffffffc0200f4e:	7109                	addi	sp,sp,-384
    cprintf("=== SLUB Object-level Check Started ===\n");
ffffffffc0200f50:	00001517          	auipc	a0,0x1
ffffffffc0200f54:	b9050513          	addi	a0,a0,-1136 # ffffffffc0201ae0 <etext+0x4ac>
static void slub_check(void) {
ffffffffc0200f58:	f6a6                	sd	s1,360(sp)
ffffffffc0200f5a:	f2ca                	sd	s2,352(sp)
ffffffffc0200f5c:	eece                	sd	s3,344(sp)
ffffffffc0200f5e:	ead2                	sd	s4,336(sp)
ffffffffc0200f60:	fe5e                	sd	s7,312(sp)
ffffffffc0200f62:	f666                	sd	s9,296(sp)
ffffffffc0200f64:	f26a                	sd	s10,288(sp)
ffffffffc0200f66:	ee6e                	sd	s11,280(sp)

    // 记录初始 slab 数，方便回归检查
    size_t slabs_before = slub_allocator.nr_slabs;
ffffffffc0200f68:	00004a17          	auipc	s4,0x4
ffffffffc0200f6c:	0b0a0a13          	addi	s4,s4,176 # ffffffffc0205018 <slub_allocator>
static void slub_check(void) {
ffffffffc0200f70:	fe86                	sd	ra,376(sp)
ffffffffc0200f72:	faa2                	sd	s0,368(sp)
ffffffffc0200f74:	e6d6                	sd	s5,328(sp)
ffffffffc0200f76:	e2da                	sd	s6,320(sp)
ffffffffc0200f78:	fa62                	sd	s8,304(sp)
    cprintf("=== SLUB Object-level Check Started ===\n");
ffffffffc0200f7a:	9d2ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    size_t slabs_before = slub_allocator.nr_slabs;
ffffffffc0200f7e:	068a3783          	ld	a5,104(s4)
    size_t hits_before = slub_allocator.cache_hits;

    // 遍历全部 size class（8..4096，共 SLUB_NUM_SIZES 个）
    for (int si = 0; si < SLUB_NUM_SIZES; si++) {
ffffffffc0200f82:	4981                	li	s3,0
    return SLUB_MIN_SIZE << index;
ffffffffc0200f84:	44a1                	li	s1,8
    size_t slabs_before = slub_allocator.nr_slabs;
ffffffffc0200f86:	e03e                	sd	a5,0(sp)
    size_t hits_before = slub_allocator.cache_hits;
ffffffffc0200f88:	060a3783          	ld	a5,96(s4)
    return SLUB_MIN_SIZE << index;
ffffffffc0200f8c:	4921                	li	s2,8
    if (size <= SLUB_MIN_SIZE) return 0;
ffffffffc0200f8e:	4681                	li	a3,0
    size_t hits_before = slub_allocator.cache_hits;
ffffffffc0200f90:	e43e                	sd	a5,8(sp)
    if (size <= SLUB_MIN_SIZE) return 0;
ffffffffc0200f92:	02000d93          	li	s11,32
        unsigned int want = cache->objects_per_slab + 1;
        if (want > 32) want = 32;
        void *objs[32];

        // 1) 分配
        for (unsigned int i = 0; i < want; i++) {
ffffffffc0200f96:	5d7d                	li	s10,-1
            objs[i] = slub_malloc(req);
            assert(objs[i] != NULL);
        }
        cprintf("  size %u: allocated %u objects\n", (unsigned int)req, want);
ffffffffc0200f98:	00001c97          	auipc	s9,0x1
ffffffffc0200f9c:	b98c8c93          	addi	s9,s9,-1128 # ffffffffc0201b30 <etext+0x4fc>
        // 3) 释放全部对象（包含刚刚 again 的对象）
        slub_free(again);
        for (unsigned int i = 1; i < want; i++) {
            slub_free(objs[i]);
        }
        cprintf("  size %u: freed %u objects\n", (unsigned int)req, want);
ffffffffc0200fa0:	00001b97          	auipc	s7,0x1
ffffffffc0200fa4:	be0b8b93          	addi	s7,s7,-1056 # ffffffffc0201b80 <etext+0x54c>
    return slub_allocator.size_caches[idx];
ffffffffc0200fa8:	068e                	slli	a3,a3,0x3
ffffffffc0200faa:	96d2                	add	a3,a3,s4
ffffffffc0200fac:	629c                	ld	a5,0(a3)
        assert(cache != NULL);
ffffffffc0200fae:	cbc5                	beqz	a5,ffffffffc020105e <slub_check+0x110>
        unsigned int want = cache->objects_per_slab + 1;
ffffffffc0200fb0:	479c                	lw	a5,8(a5)
ffffffffc0200fb2:	00178a9b          	addiw	s5,a5,1
ffffffffc0200fb6:	8456                	mv	s0,s5
        if (want > 32) want = 32;
ffffffffc0200fb8:	015df463          	bgeu	s11,s5,ffffffffc0200fc0 <slub_check+0x72>
ffffffffc0200fbc:	02000413          	li	s0,32
        for (unsigned int i = 0; i < want; i++) {
ffffffffc0200fc0:	03a78063          	beq	a5,s10,ffffffffc0200fe0 <slub_check+0x92>
ffffffffc0200fc4:	01010c13          	addi	s8,sp,16
ffffffffc0200fc8:	4b01                	li	s6,0
            objs[i] = slub_malloc(req);
ffffffffc0200fca:	8526                	mv	a0,s1
ffffffffc0200fcc:	c1bff0ef          	jal	ra,ffffffffc0200be6 <slub_malloc>
ffffffffc0200fd0:	00ac3023          	sd	a0,0(s8)
            assert(objs[i] != NULL);
ffffffffc0200fd4:	14050663          	beqz	a0,ffffffffc0201120 <slub_check+0x1d2>
        for (unsigned int i = 0; i < want; i++) {
ffffffffc0200fd8:	2b05                	addiw	s6,s6,1
ffffffffc0200fda:	0c21                	addi	s8,s8,8
ffffffffc0200fdc:	fe8b67e3          	bltu	s6,s0,ffffffffc0200fca <slub_check+0x7c>
        cprintf("  size %u: allocated %u objects\n", (unsigned int)req, want);
ffffffffc0200fe0:	2901                	sext.w	s2,s2
ffffffffc0200fe2:	8622                	mv	a2,s0
ffffffffc0200fe4:	85ca                	mv	a1,s2
ffffffffc0200fe6:	8566                	mv	a0,s9
ffffffffc0200fe8:	964ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        slub_free(objs[0]);
ffffffffc0200fec:	6542                	ld	a0,16(sp)
ffffffffc0200fee:	e05ff0ef          	jal	ra,ffffffffc0200df2 <slub_free>
        void *again = slub_malloc(req);
ffffffffc0200ff2:	8526                	mv	a0,s1
        size_t hits_mid = slub_allocator.cache_hits;
ffffffffc0200ff4:	060a3483          	ld	s1,96(s4)
        void *again = slub_malloc(req);
ffffffffc0200ff8:	befff0ef          	jal	ra,ffffffffc0200be6 <slub_malloc>
        assert(again != NULL);
ffffffffc0200ffc:	14050263          	beqz	a0,ffffffffc0201140 <slub_check+0x1f2>
        assert(hits_after >= hits_mid); // 命中数应不减少
ffffffffc0201000:	060a3783          	ld	a5,96(s4)
ffffffffc0201004:	1697ee63          	bltu	a5,s1,ffffffffc0201180 <slub_check+0x232>
        slub_free(again);
ffffffffc0201008:	debff0ef          	jal	ra,ffffffffc0200df2 <slub_free>
        for (unsigned int i = 1; i < want; i++) {
ffffffffc020100c:	4785                	li	a5,1
ffffffffc020100e:	0157fd63          	bgeu	a5,s5,ffffffffc0201028 <slub_check+0xda>
ffffffffc0201012:	01810a93          	addi	s5,sp,24
ffffffffc0201016:	4485                	li	s1,1
            slub_free(objs[i]);
ffffffffc0201018:	000ab503          	ld	a0,0(s5)
        for (unsigned int i = 1; i < want; i++) {
ffffffffc020101c:	2485                	addiw	s1,s1,1
ffffffffc020101e:	0aa1                	addi	s5,s5,8
            slub_free(objs[i]);
ffffffffc0201020:	dd3ff0ef          	jal	ra,ffffffffc0200df2 <slub_free>
        for (unsigned int i = 1; i < want; i++) {
ffffffffc0201024:	fe84eae3          	bltu	s1,s0,ffffffffc0201018 <slub_check+0xca>
        cprintf("  size %u: freed %u objects\n", (unsigned int)req, want);
ffffffffc0201028:	8622                	mv	a2,s0
ffffffffc020102a:	85ca                	mv	a1,s2
ffffffffc020102c:	855e                	mv	a0,s7
ffffffffc020102e:	91eff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int si = 0; si < SLUB_NUM_SIZES; si++) {
ffffffffc0201032:	2985                	addiw	s3,s3,1
ffffffffc0201034:	47a9                	li	a5,10
ffffffffc0201036:	04f98463          	beq	s3,a5,ffffffffc020107e <slub_check+0x130>
    return SLUB_MIN_SIZE << index;
ffffffffc020103a:	4921                	li	s2,8
ffffffffc020103c:	0139193b          	sllw	s2,s2,s3
    size = ROUNDUP(size, SLUB_ALIGN);
ffffffffc0201040:	0079079b          	addiw	a5,s2,7
    size_t temp = size - 1;
ffffffffc0201044:	9be1                	andi	a5,a5,-8
ffffffffc0201046:	17fd                	addi	a5,a5,-1
    int shift = 0;
ffffffffc0201048:	4701                	li	a4,0
        temp >>= 1;
ffffffffc020104a:	8385                	srli	a5,a5,0x1
        shift++;
ffffffffc020104c:	86ba                	mv	a3,a4
ffffffffc020104e:	2705                	addiw	a4,a4,1
    while (temp > 0) {
ffffffffc0201050:	ffed                	bnez	a5,ffffffffc020104a <slub_check+0xfc>
    return shift - SLUB_SHIFT_LOW;
ffffffffc0201052:	36f9                	addiw	a3,a3,-2
    if (idx < 0 || idx >= SLUB_NUM_SIZES) return NULL;
ffffffffc0201054:	47a5                	li	a5,9
ffffffffc0201056:	00d7e463          	bltu	a5,a3,ffffffffc020105e <slub_check+0x110>
    return SLUB_MIN_SIZE << index;
ffffffffc020105a:	84ca                	mv	s1,s2
ffffffffc020105c:	b7b1                	j	ffffffffc0200fa8 <slub_check+0x5a>
        assert(cache != NULL);
ffffffffc020105e:	00001697          	auipc	a3,0x1
ffffffffc0201062:	ab268693          	addi	a3,a3,-1358 # ffffffffc0201b10 <etext+0x4dc>
ffffffffc0201066:	00001617          	auipc	a2,0x1
ffffffffc020106a:	98260613          	addi	a2,a2,-1662 # ffffffffc02019e8 <etext+0x3b4>
ffffffffc020106e:	1fa00593          	li	a1,506
ffffffffc0201072:	00001517          	auipc	a0,0x1
ffffffffc0201076:	98e50513          	addi	a0,a0,-1650 # ffffffffc0201a00 <etext+0x3cc>
ffffffffc020107a:	948ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    }

    // 回归检查：slab 数应能回到初始值或不显著偏差（允许常驻少量 slab）
    size_t slabs_after = slub_allocator.nr_slabs;
    if (slabs_after > slabs_before + 2) {
ffffffffc020107e:	6782                	ld	a5,0(sp)
    size_t slabs_after = slub_allocator.nr_slabs;
ffffffffc0201080:	068a3603          	ld	a2,104(s4)
    if (slabs_after > slabs_before + 2) {
ffffffffc0201084:	0789                	addi	a5,a5,2
ffffffffc0201086:	08c7e463          	bltu	a5,a2,ffffffffc020110e <slub_check+0x1c0>
        cprintf("WARNING: slab leak suspected: before=%u after=%u\n",
                (unsigned int)slabs_before, (unsigned int)slabs_after);
    }

    // 汇总
    size_t total_allocs = slub_allocator.total_allocs;
ffffffffc020108a:	050a3483          	ld	s1,80(s4)
    size_t total_frees = slub_allocator.total_frees;
    cprintf("\nSLUB Object-level Statistics:\n");
ffffffffc020108e:	00001517          	auipc	a0,0x1
ffffffffc0201092:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0201bd8 <etext+0x5a4>
    size_t total_frees = slub_allocator.total_frees;
ffffffffc0201096:	058a3403          	ld	s0,88(s4)
    cprintf("\nSLUB Object-level Statistics:\n");
ffffffffc020109a:	8b2ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  Total allocations: %u\n", (unsigned int)total_allocs);
ffffffffc020109e:	0004859b          	sext.w	a1,s1
ffffffffc02010a2:	00001517          	auipc	a0,0x1
ffffffffc02010a6:	b5650513          	addi	a0,a0,-1194 # ffffffffc0201bf8 <etext+0x5c4>
ffffffffc02010aa:	8a2ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  Total frees: %u\n", (unsigned int)total_frees);
ffffffffc02010ae:	0004059b          	sext.w	a1,s0
ffffffffc02010b2:	00001517          	auipc	a0,0x1
ffffffffc02010b6:	b6650513          	addi	a0,a0,-1178 # ffffffffc0201c18 <etext+0x5e4>
ffffffffc02010ba:	892ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  Cache hits (delta): %u\n",
ffffffffc02010be:	060a3583          	ld	a1,96(s4)
ffffffffc02010c2:	67a2                	ld	a5,8(sp)
ffffffffc02010c4:	00001517          	auipc	a0,0x1
ffffffffc02010c8:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0201c30 <etext+0x5fc>
ffffffffc02010cc:	9d9d                	subw	a1,a1,a5
ffffffffc02010ce:	87eff0ef          	jal	ra,ffffffffc020014c <cprintf>
            (unsigned int)(slub_allocator.cache_hits - hits_before));
    cprintf("  Active slabs: %u\n", (unsigned int)slub_allocator.nr_slabs);
ffffffffc02010d2:	068a2583          	lw	a1,104(s4)
ffffffffc02010d6:	00001517          	auipc	a0,0x1
ffffffffc02010da:	b7a50513          	addi	a0,a0,-1158 # ffffffffc0201c50 <etext+0x61c>
ffffffffc02010de:	86eff0ef          	jal	ra,ffffffffc020014c <cprintf>

    assert(total_allocs >= total_frees);
ffffffffc02010e2:	0684ef63          	bltu	s1,s0,ffffffffc0201160 <slub_check+0x212>
    cprintf("\n=== SLUB Object-level Check Completed ===\n");
}
ffffffffc02010e6:	7456                	ld	s0,368(sp)
ffffffffc02010e8:	70f6                	ld	ra,376(sp)
ffffffffc02010ea:	74b6                	ld	s1,360(sp)
ffffffffc02010ec:	7916                	ld	s2,352(sp)
ffffffffc02010ee:	69f6                	ld	s3,344(sp)
ffffffffc02010f0:	6a56                	ld	s4,336(sp)
ffffffffc02010f2:	6ab6                	ld	s5,328(sp)
ffffffffc02010f4:	6b16                	ld	s6,320(sp)
ffffffffc02010f6:	7bf2                	ld	s7,312(sp)
ffffffffc02010f8:	7c52                	ld	s8,304(sp)
ffffffffc02010fa:	7cb2                	ld	s9,296(sp)
ffffffffc02010fc:	7d12                	ld	s10,288(sp)
ffffffffc02010fe:	6df2                	ld	s11,280(sp)
    cprintf("\n=== SLUB Object-level Check Completed ===\n");
ffffffffc0201100:	00001517          	auipc	a0,0x1
ffffffffc0201104:	b8850513          	addi	a0,a0,-1144 # ffffffffc0201c88 <etext+0x654>
}
ffffffffc0201108:	6119                	addi	sp,sp,384
    cprintf("\n=== SLUB Object-level Check Completed ===\n");
ffffffffc020110a:	842ff06f          	j	ffffffffc020014c <cprintf>
        cprintf("WARNING: slab leak suspected: before=%u after=%u\n",
ffffffffc020110e:	4582                	lw	a1,0(sp)
ffffffffc0201110:	2601                	sext.w	a2,a2
ffffffffc0201112:	00001517          	auipc	a0,0x1
ffffffffc0201116:	a8e50513          	addi	a0,a0,-1394 # ffffffffc0201ba0 <etext+0x56c>
ffffffffc020111a:	832ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc020111e:	b7b5                	j	ffffffffc020108a <slub_check+0x13c>
            assert(objs[i] != NULL);
ffffffffc0201120:	00001697          	auipc	a3,0x1
ffffffffc0201124:	a0068693          	addi	a3,a3,-1536 # ffffffffc0201b20 <etext+0x4ec>
ffffffffc0201128:	00001617          	auipc	a2,0x1
ffffffffc020112c:	8c060613          	addi	a2,a2,-1856 # ffffffffc02019e8 <etext+0x3b4>
ffffffffc0201130:	20400593          	li	a1,516
ffffffffc0201134:	00001517          	auipc	a0,0x1
ffffffffc0201138:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0201a00 <etext+0x3cc>
ffffffffc020113c:	886ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(again != NULL);
ffffffffc0201140:	00001697          	auipc	a3,0x1
ffffffffc0201144:	a1868693          	addi	a3,a3,-1512 # ffffffffc0201b58 <etext+0x524>
ffffffffc0201148:	00001617          	auipc	a2,0x1
ffffffffc020114c:	8a060613          	addi	a2,a2,-1888 # ffffffffc02019e8 <etext+0x3b4>
ffffffffc0201150:	20c00593          	li	a1,524
ffffffffc0201154:	00001517          	auipc	a0,0x1
ffffffffc0201158:	8ac50513          	addi	a0,a0,-1876 # ffffffffc0201a00 <etext+0x3cc>
ffffffffc020115c:	866ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(total_allocs >= total_frees);
ffffffffc0201160:	00001697          	auipc	a3,0x1
ffffffffc0201164:	b0868693          	addi	a3,a3,-1272 # ffffffffc0201c68 <etext+0x634>
ffffffffc0201168:	00001617          	auipc	a2,0x1
ffffffffc020116c:	88060613          	addi	a2,a2,-1920 # ffffffffc02019e8 <etext+0x3b4>
ffffffffc0201170:	22900593          	li	a1,553
ffffffffc0201174:	00001517          	auipc	a0,0x1
ffffffffc0201178:	88c50513          	addi	a0,a0,-1908 # ffffffffc0201a00 <etext+0x3cc>
ffffffffc020117c:	846ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(hits_after >= hits_mid); // 命中数应不减少
ffffffffc0201180:	00001697          	auipc	a3,0x1
ffffffffc0201184:	9e868693          	addi	a3,a3,-1560 # ffffffffc0201b68 <etext+0x534>
ffffffffc0201188:	00001617          	auipc	a2,0x1
ffffffffc020118c:	86060613          	addi	a2,a2,-1952 # ffffffffc02019e8 <etext+0x3b4>
ffffffffc0201190:	20e00593          	li	a1,526
ffffffffc0201194:	00001517          	auipc	a0,0x1
ffffffffc0201198:	86c50513          	addi	a0,a0,-1940 # ffffffffc0201a00 <etext+0x3cc>
ffffffffc020119c:	826ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02011a0 <printnum>:
ffffffffc02011a0:	02069813          	slli	a6,a3,0x20
ffffffffc02011a4:	7179                	addi	sp,sp,-48
ffffffffc02011a6:	02085813          	srli	a6,a6,0x20
ffffffffc02011aa:	e052                	sd	s4,0(sp)
ffffffffc02011ac:	03067a33          	remu	s4,a2,a6
ffffffffc02011b0:	f022                	sd	s0,32(sp)
ffffffffc02011b2:	ec26                	sd	s1,24(sp)
ffffffffc02011b4:	e84a                	sd	s2,16(sp)
ffffffffc02011b6:	f406                	sd	ra,40(sp)
ffffffffc02011b8:	e44e                	sd	s3,8(sp)
ffffffffc02011ba:	84aa                	mv	s1,a0
ffffffffc02011bc:	892e                	mv	s2,a1
ffffffffc02011be:	fff7041b          	addiw	s0,a4,-1
ffffffffc02011c2:	2a01                	sext.w	s4,s4
ffffffffc02011c4:	03067e63          	bgeu	a2,a6,ffffffffc0201200 <printnum+0x60>
ffffffffc02011c8:	89be                	mv	s3,a5
ffffffffc02011ca:	00805763          	blez	s0,ffffffffc02011d8 <printnum+0x38>
ffffffffc02011ce:	347d                	addiw	s0,s0,-1
ffffffffc02011d0:	85ca                	mv	a1,s2
ffffffffc02011d2:	854e                	mv	a0,s3
ffffffffc02011d4:	9482                	jalr	s1
ffffffffc02011d6:	fc65                	bnez	s0,ffffffffc02011ce <printnum+0x2e>
ffffffffc02011d8:	1a02                	slli	s4,s4,0x20
ffffffffc02011da:	00001797          	auipc	a5,0x1
ffffffffc02011de:	b2e78793          	addi	a5,a5,-1234 # ffffffffc0201d08 <slub_pmm_manager+0x38>
ffffffffc02011e2:	020a5a13          	srli	s4,s4,0x20
ffffffffc02011e6:	9a3e                	add	s4,s4,a5
ffffffffc02011e8:	7402                	ld	s0,32(sp)
ffffffffc02011ea:	000a4503          	lbu	a0,0(s4)
ffffffffc02011ee:	70a2                	ld	ra,40(sp)
ffffffffc02011f0:	69a2                	ld	s3,8(sp)
ffffffffc02011f2:	6a02                	ld	s4,0(sp)
ffffffffc02011f4:	85ca                	mv	a1,s2
ffffffffc02011f6:	87a6                	mv	a5,s1
ffffffffc02011f8:	6942                	ld	s2,16(sp)
ffffffffc02011fa:	64e2                	ld	s1,24(sp)
ffffffffc02011fc:	6145                	addi	sp,sp,48
ffffffffc02011fe:	8782                	jr	a5
ffffffffc0201200:	03065633          	divu	a2,a2,a6
ffffffffc0201204:	8722                	mv	a4,s0
ffffffffc0201206:	f9bff0ef          	jal	ra,ffffffffc02011a0 <printnum>
ffffffffc020120a:	b7f9                	j	ffffffffc02011d8 <printnum+0x38>

ffffffffc020120c <vprintfmt>:
ffffffffc020120c:	7119                	addi	sp,sp,-128
ffffffffc020120e:	f4a6                	sd	s1,104(sp)
ffffffffc0201210:	f0ca                	sd	s2,96(sp)
ffffffffc0201212:	ecce                	sd	s3,88(sp)
ffffffffc0201214:	e8d2                	sd	s4,80(sp)
ffffffffc0201216:	e4d6                	sd	s5,72(sp)
ffffffffc0201218:	e0da                	sd	s6,64(sp)
ffffffffc020121a:	fc5e                	sd	s7,56(sp)
ffffffffc020121c:	f06a                	sd	s10,32(sp)
ffffffffc020121e:	fc86                	sd	ra,120(sp)
ffffffffc0201220:	f8a2                	sd	s0,112(sp)
ffffffffc0201222:	f862                	sd	s8,48(sp)
ffffffffc0201224:	f466                	sd	s9,40(sp)
ffffffffc0201226:	ec6e                	sd	s11,24(sp)
ffffffffc0201228:	892a                	mv	s2,a0
ffffffffc020122a:	84ae                	mv	s1,a1
ffffffffc020122c:	8d32                	mv	s10,a2
ffffffffc020122e:	8a36                	mv	s4,a3
ffffffffc0201230:	02500993          	li	s3,37
ffffffffc0201234:	5b7d                	li	s6,-1
ffffffffc0201236:	00001a97          	auipc	s5,0x1
ffffffffc020123a:	b06a8a93          	addi	s5,s5,-1274 # ffffffffc0201d3c <slub_pmm_manager+0x6c>
ffffffffc020123e:	00001b97          	auipc	s7,0x1
ffffffffc0201242:	cdab8b93          	addi	s7,s7,-806 # ffffffffc0201f18 <error_string>
ffffffffc0201246:	000d4503          	lbu	a0,0(s10)
ffffffffc020124a:	001d0413          	addi	s0,s10,1
ffffffffc020124e:	01350a63          	beq	a0,s3,ffffffffc0201262 <vprintfmt+0x56>
ffffffffc0201252:	c121                	beqz	a0,ffffffffc0201292 <vprintfmt+0x86>
ffffffffc0201254:	85a6                	mv	a1,s1
ffffffffc0201256:	0405                	addi	s0,s0,1
ffffffffc0201258:	9902                	jalr	s2
ffffffffc020125a:	fff44503          	lbu	a0,-1(s0)
ffffffffc020125e:	ff351ae3          	bne	a0,s3,ffffffffc0201252 <vprintfmt+0x46>
ffffffffc0201262:	00044603          	lbu	a2,0(s0)
ffffffffc0201266:	02000793          	li	a5,32
ffffffffc020126a:	4c81                	li	s9,0
ffffffffc020126c:	4881                	li	a7,0
ffffffffc020126e:	5c7d                	li	s8,-1
ffffffffc0201270:	5dfd                	li	s11,-1
ffffffffc0201272:	05500513          	li	a0,85
ffffffffc0201276:	4825                	li	a6,9
ffffffffc0201278:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020127c:	0ff5f593          	zext.b	a1,a1
ffffffffc0201280:	00140d13          	addi	s10,s0,1
ffffffffc0201284:	04b56263          	bltu	a0,a1,ffffffffc02012c8 <vprintfmt+0xbc>
ffffffffc0201288:	058a                	slli	a1,a1,0x2
ffffffffc020128a:	95d6                	add	a1,a1,s5
ffffffffc020128c:	4194                	lw	a3,0(a1)
ffffffffc020128e:	96d6                	add	a3,a3,s5
ffffffffc0201290:	8682                	jr	a3
ffffffffc0201292:	70e6                	ld	ra,120(sp)
ffffffffc0201294:	7446                	ld	s0,112(sp)
ffffffffc0201296:	74a6                	ld	s1,104(sp)
ffffffffc0201298:	7906                	ld	s2,96(sp)
ffffffffc020129a:	69e6                	ld	s3,88(sp)
ffffffffc020129c:	6a46                	ld	s4,80(sp)
ffffffffc020129e:	6aa6                	ld	s5,72(sp)
ffffffffc02012a0:	6b06                	ld	s6,64(sp)
ffffffffc02012a2:	7be2                	ld	s7,56(sp)
ffffffffc02012a4:	7c42                	ld	s8,48(sp)
ffffffffc02012a6:	7ca2                	ld	s9,40(sp)
ffffffffc02012a8:	7d02                	ld	s10,32(sp)
ffffffffc02012aa:	6de2                	ld	s11,24(sp)
ffffffffc02012ac:	6109                	addi	sp,sp,128
ffffffffc02012ae:	8082                	ret
ffffffffc02012b0:	87b2                	mv	a5,a2
ffffffffc02012b2:	00144603          	lbu	a2,1(s0)
ffffffffc02012b6:	846a                	mv	s0,s10
ffffffffc02012b8:	00140d13          	addi	s10,s0,1
ffffffffc02012bc:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02012c0:	0ff5f593          	zext.b	a1,a1
ffffffffc02012c4:	fcb572e3          	bgeu	a0,a1,ffffffffc0201288 <vprintfmt+0x7c>
ffffffffc02012c8:	85a6                	mv	a1,s1
ffffffffc02012ca:	02500513          	li	a0,37
ffffffffc02012ce:	9902                	jalr	s2
ffffffffc02012d0:	fff44783          	lbu	a5,-1(s0)
ffffffffc02012d4:	8d22                	mv	s10,s0
ffffffffc02012d6:	f73788e3          	beq	a5,s3,ffffffffc0201246 <vprintfmt+0x3a>
ffffffffc02012da:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02012de:	1d7d                	addi	s10,s10,-1
ffffffffc02012e0:	ff379de3          	bne	a5,s3,ffffffffc02012da <vprintfmt+0xce>
ffffffffc02012e4:	b78d                	j	ffffffffc0201246 <vprintfmt+0x3a>
ffffffffc02012e6:	fd060c1b          	addiw	s8,a2,-48
ffffffffc02012ea:	00144603          	lbu	a2,1(s0)
ffffffffc02012ee:	846a                	mv	s0,s10
ffffffffc02012f0:	fd06069b          	addiw	a3,a2,-48
ffffffffc02012f4:	0006059b          	sext.w	a1,a2
ffffffffc02012f8:	02d86463          	bltu	a6,a3,ffffffffc0201320 <vprintfmt+0x114>
ffffffffc02012fc:	00144603          	lbu	a2,1(s0)
ffffffffc0201300:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201304:	0186873b          	addw	a4,a3,s8
ffffffffc0201308:	0017171b          	slliw	a4,a4,0x1
ffffffffc020130c:	9f2d                	addw	a4,a4,a1
ffffffffc020130e:	fd06069b          	addiw	a3,a2,-48
ffffffffc0201312:	0405                	addi	s0,s0,1
ffffffffc0201314:	fd070c1b          	addiw	s8,a4,-48
ffffffffc0201318:	0006059b          	sext.w	a1,a2
ffffffffc020131c:	fed870e3          	bgeu	a6,a3,ffffffffc02012fc <vprintfmt+0xf0>
ffffffffc0201320:	f40ddce3          	bgez	s11,ffffffffc0201278 <vprintfmt+0x6c>
ffffffffc0201324:	8de2                	mv	s11,s8
ffffffffc0201326:	5c7d                	li	s8,-1
ffffffffc0201328:	bf81                	j	ffffffffc0201278 <vprintfmt+0x6c>
ffffffffc020132a:	fffdc693          	not	a3,s11
ffffffffc020132e:	96fd                	srai	a3,a3,0x3f
ffffffffc0201330:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201334:	00144603          	lbu	a2,1(s0)
ffffffffc0201338:	2d81                	sext.w	s11,s11
ffffffffc020133a:	846a                	mv	s0,s10
ffffffffc020133c:	bf35                	j	ffffffffc0201278 <vprintfmt+0x6c>
ffffffffc020133e:	000a2c03          	lw	s8,0(s4)
ffffffffc0201342:	00144603          	lbu	a2,1(s0)
ffffffffc0201346:	0a21                	addi	s4,s4,8
ffffffffc0201348:	846a                	mv	s0,s10
ffffffffc020134a:	bfd9                	j	ffffffffc0201320 <vprintfmt+0x114>
ffffffffc020134c:	4705                	li	a4,1
ffffffffc020134e:	008a0593          	addi	a1,s4,8
ffffffffc0201352:	01174463          	blt	a4,a7,ffffffffc020135a <vprintfmt+0x14e>
ffffffffc0201356:	1a088e63          	beqz	a7,ffffffffc0201512 <vprintfmt+0x306>
ffffffffc020135a:	000a3603          	ld	a2,0(s4)
ffffffffc020135e:	46c1                	li	a3,16
ffffffffc0201360:	8a2e                	mv	s4,a1
ffffffffc0201362:	2781                	sext.w	a5,a5
ffffffffc0201364:	876e                	mv	a4,s11
ffffffffc0201366:	85a6                	mv	a1,s1
ffffffffc0201368:	854a                	mv	a0,s2
ffffffffc020136a:	e37ff0ef          	jal	ra,ffffffffc02011a0 <printnum>
ffffffffc020136e:	bde1                	j	ffffffffc0201246 <vprintfmt+0x3a>
ffffffffc0201370:	000a2503          	lw	a0,0(s4)
ffffffffc0201374:	85a6                	mv	a1,s1
ffffffffc0201376:	0a21                	addi	s4,s4,8
ffffffffc0201378:	9902                	jalr	s2
ffffffffc020137a:	b5f1                	j	ffffffffc0201246 <vprintfmt+0x3a>
ffffffffc020137c:	4705                	li	a4,1
ffffffffc020137e:	008a0593          	addi	a1,s4,8
ffffffffc0201382:	01174463          	blt	a4,a7,ffffffffc020138a <vprintfmt+0x17e>
ffffffffc0201386:	18088163          	beqz	a7,ffffffffc0201508 <vprintfmt+0x2fc>
ffffffffc020138a:	000a3603          	ld	a2,0(s4)
ffffffffc020138e:	46a9                	li	a3,10
ffffffffc0201390:	8a2e                	mv	s4,a1
ffffffffc0201392:	bfc1                	j	ffffffffc0201362 <vprintfmt+0x156>
ffffffffc0201394:	00144603          	lbu	a2,1(s0)
ffffffffc0201398:	4c85                	li	s9,1
ffffffffc020139a:	846a                	mv	s0,s10
ffffffffc020139c:	bdf1                	j	ffffffffc0201278 <vprintfmt+0x6c>
ffffffffc020139e:	85a6                	mv	a1,s1
ffffffffc02013a0:	02500513          	li	a0,37
ffffffffc02013a4:	9902                	jalr	s2
ffffffffc02013a6:	b545                	j	ffffffffc0201246 <vprintfmt+0x3a>
ffffffffc02013a8:	00144603          	lbu	a2,1(s0)
ffffffffc02013ac:	2885                	addiw	a7,a7,1
ffffffffc02013ae:	846a                	mv	s0,s10
ffffffffc02013b0:	b5e1                	j	ffffffffc0201278 <vprintfmt+0x6c>
ffffffffc02013b2:	4705                	li	a4,1
ffffffffc02013b4:	008a0593          	addi	a1,s4,8
ffffffffc02013b8:	01174463          	blt	a4,a7,ffffffffc02013c0 <vprintfmt+0x1b4>
ffffffffc02013bc:	14088163          	beqz	a7,ffffffffc02014fe <vprintfmt+0x2f2>
ffffffffc02013c0:	000a3603          	ld	a2,0(s4)
ffffffffc02013c4:	46a1                	li	a3,8
ffffffffc02013c6:	8a2e                	mv	s4,a1
ffffffffc02013c8:	bf69                	j	ffffffffc0201362 <vprintfmt+0x156>
ffffffffc02013ca:	03000513          	li	a0,48
ffffffffc02013ce:	85a6                	mv	a1,s1
ffffffffc02013d0:	e03e                	sd	a5,0(sp)
ffffffffc02013d2:	9902                	jalr	s2
ffffffffc02013d4:	85a6                	mv	a1,s1
ffffffffc02013d6:	07800513          	li	a0,120
ffffffffc02013da:	9902                	jalr	s2
ffffffffc02013dc:	0a21                	addi	s4,s4,8
ffffffffc02013de:	6782                	ld	a5,0(sp)
ffffffffc02013e0:	46c1                	li	a3,16
ffffffffc02013e2:	ff8a3603          	ld	a2,-8(s4)
ffffffffc02013e6:	bfb5                	j	ffffffffc0201362 <vprintfmt+0x156>
ffffffffc02013e8:	000a3403          	ld	s0,0(s4)
ffffffffc02013ec:	008a0713          	addi	a4,s4,8
ffffffffc02013f0:	e03a                	sd	a4,0(sp)
ffffffffc02013f2:	14040263          	beqz	s0,ffffffffc0201536 <vprintfmt+0x32a>
ffffffffc02013f6:	0fb05763          	blez	s11,ffffffffc02014e4 <vprintfmt+0x2d8>
ffffffffc02013fa:	02d00693          	li	a3,45
ffffffffc02013fe:	0cd79163          	bne	a5,a3,ffffffffc02014c0 <vprintfmt+0x2b4>
ffffffffc0201402:	00044783          	lbu	a5,0(s0)
ffffffffc0201406:	0007851b          	sext.w	a0,a5
ffffffffc020140a:	cf85                	beqz	a5,ffffffffc0201442 <vprintfmt+0x236>
ffffffffc020140c:	00140a13          	addi	s4,s0,1
ffffffffc0201410:	05e00413          	li	s0,94
ffffffffc0201414:	000c4563          	bltz	s8,ffffffffc020141e <vprintfmt+0x212>
ffffffffc0201418:	3c7d                	addiw	s8,s8,-1
ffffffffc020141a:	036c0263          	beq	s8,s6,ffffffffc020143e <vprintfmt+0x232>
ffffffffc020141e:	85a6                	mv	a1,s1
ffffffffc0201420:	0e0c8e63          	beqz	s9,ffffffffc020151c <vprintfmt+0x310>
ffffffffc0201424:	3781                	addiw	a5,a5,-32
ffffffffc0201426:	0ef47b63          	bgeu	s0,a5,ffffffffc020151c <vprintfmt+0x310>
ffffffffc020142a:	03f00513          	li	a0,63
ffffffffc020142e:	9902                	jalr	s2
ffffffffc0201430:	000a4783          	lbu	a5,0(s4)
ffffffffc0201434:	3dfd                	addiw	s11,s11,-1
ffffffffc0201436:	0a05                	addi	s4,s4,1
ffffffffc0201438:	0007851b          	sext.w	a0,a5
ffffffffc020143c:	ffe1                	bnez	a5,ffffffffc0201414 <vprintfmt+0x208>
ffffffffc020143e:	01b05963          	blez	s11,ffffffffc0201450 <vprintfmt+0x244>
ffffffffc0201442:	3dfd                	addiw	s11,s11,-1
ffffffffc0201444:	85a6                	mv	a1,s1
ffffffffc0201446:	02000513          	li	a0,32
ffffffffc020144a:	9902                	jalr	s2
ffffffffc020144c:	fe0d9be3          	bnez	s11,ffffffffc0201442 <vprintfmt+0x236>
ffffffffc0201450:	6a02                	ld	s4,0(sp)
ffffffffc0201452:	bbd5                	j	ffffffffc0201246 <vprintfmt+0x3a>
ffffffffc0201454:	4705                	li	a4,1
ffffffffc0201456:	008a0c93          	addi	s9,s4,8
ffffffffc020145a:	01174463          	blt	a4,a7,ffffffffc0201462 <vprintfmt+0x256>
ffffffffc020145e:	08088d63          	beqz	a7,ffffffffc02014f8 <vprintfmt+0x2ec>
ffffffffc0201462:	000a3403          	ld	s0,0(s4)
ffffffffc0201466:	0a044d63          	bltz	s0,ffffffffc0201520 <vprintfmt+0x314>
ffffffffc020146a:	8622                	mv	a2,s0
ffffffffc020146c:	8a66                	mv	s4,s9
ffffffffc020146e:	46a9                	li	a3,10
ffffffffc0201470:	bdcd                	j	ffffffffc0201362 <vprintfmt+0x156>
ffffffffc0201472:	000a2783          	lw	a5,0(s4)
ffffffffc0201476:	4719                	li	a4,6
ffffffffc0201478:	0a21                	addi	s4,s4,8
ffffffffc020147a:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020147e:	8fb5                	xor	a5,a5,a3
ffffffffc0201480:	40d786bb          	subw	a3,a5,a3
ffffffffc0201484:	02d74163          	blt	a4,a3,ffffffffc02014a6 <vprintfmt+0x29a>
ffffffffc0201488:	00369793          	slli	a5,a3,0x3
ffffffffc020148c:	97de                	add	a5,a5,s7
ffffffffc020148e:	639c                	ld	a5,0(a5)
ffffffffc0201490:	cb99                	beqz	a5,ffffffffc02014a6 <vprintfmt+0x29a>
ffffffffc0201492:	86be                	mv	a3,a5
ffffffffc0201494:	00001617          	auipc	a2,0x1
ffffffffc0201498:	8a460613          	addi	a2,a2,-1884 # ffffffffc0201d38 <slub_pmm_manager+0x68>
ffffffffc020149c:	85a6                	mv	a1,s1
ffffffffc020149e:	854a                	mv	a0,s2
ffffffffc02014a0:	0ce000ef          	jal	ra,ffffffffc020156e <printfmt>
ffffffffc02014a4:	b34d                	j	ffffffffc0201246 <vprintfmt+0x3a>
ffffffffc02014a6:	00001617          	auipc	a2,0x1
ffffffffc02014aa:	88260613          	addi	a2,a2,-1918 # ffffffffc0201d28 <slub_pmm_manager+0x58>
ffffffffc02014ae:	85a6                	mv	a1,s1
ffffffffc02014b0:	854a                	mv	a0,s2
ffffffffc02014b2:	0bc000ef          	jal	ra,ffffffffc020156e <printfmt>
ffffffffc02014b6:	bb41                	j	ffffffffc0201246 <vprintfmt+0x3a>
ffffffffc02014b8:	00001417          	auipc	s0,0x1
ffffffffc02014bc:	86840413          	addi	s0,s0,-1944 # ffffffffc0201d20 <slub_pmm_manager+0x50>
ffffffffc02014c0:	85e2                	mv	a1,s8
ffffffffc02014c2:	8522                	mv	a0,s0
ffffffffc02014c4:	e43e                	sd	a5,8(sp)
ffffffffc02014c6:	0fc000ef          	jal	ra,ffffffffc02015c2 <strnlen>
ffffffffc02014ca:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02014ce:	01b05b63          	blez	s11,ffffffffc02014e4 <vprintfmt+0x2d8>
ffffffffc02014d2:	67a2                	ld	a5,8(sp)
ffffffffc02014d4:	00078a1b          	sext.w	s4,a5
ffffffffc02014d8:	3dfd                	addiw	s11,s11,-1
ffffffffc02014da:	85a6                	mv	a1,s1
ffffffffc02014dc:	8552                	mv	a0,s4
ffffffffc02014de:	9902                	jalr	s2
ffffffffc02014e0:	fe0d9ce3          	bnez	s11,ffffffffc02014d8 <vprintfmt+0x2cc>
ffffffffc02014e4:	00044783          	lbu	a5,0(s0)
ffffffffc02014e8:	00140a13          	addi	s4,s0,1
ffffffffc02014ec:	0007851b          	sext.w	a0,a5
ffffffffc02014f0:	d3a5                	beqz	a5,ffffffffc0201450 <vprintfmt+0x244>
ffffffffc02014f2:	05e00413          	li	s0,94
ffffffffc02014f6:	bf39                	j	ffffffffc0201414 <vprintfmt+0x208>
ffffffffc02014f8:	000a2403          	lw	s0,0(s4)
ffffffffc02014fc:	b7ad                	j	ffffffffc0201466 <vprintfmt+0x25a>
ffffffffc02014fe:	000a6603          	lwu	a2,0(s4)
ffffffffc0201502:	46a1                	li	a3,8
ffffffffc0201504:	8a2e                	mv	s4,a1
ffffffffc0201506:	bdb1                	j	ffffffffc0201362 <vprintfmt+0x156>
ffffffffc0201508:	000a6603          	lwu	a2,0(s4)
ffffffffc020150c:	46a9                	li	a3,10
ffffffffc020150e:	8a2e                	mv	s4,a1
ffffffffc0201510:	bd89                	j	ffffffffc0201362 <vprintfmt+0x156>
ffffffffc0201512:	000a6603          	lwu	a2,0(s4)
ffffffffc0201516:	46c1                	li	a3,16
ffffffffc0201518:	8a2e                	mv	s4,a1
ffffffffc020151a:	b5a1                	j	ffffffffc0201362 <vprintfmt+0x156>
ffffffffc020151c:	9902                	jalr	s2
ffffffffc020151e:	bf09                	j	ffffffffc0201430 <vprintfmt+0x224>
ffffffffc0201520:	85a6                	mv	a1,s1
ffffffffc0201522:	02d00513          	li	a0,45
ffffffffc0201526:	e03e                	sd	a5,0(sp)
ffffffffc0201528:	9902                	jalr	s2
ffffffffc020152a:	6782                	ld	a5,0(sp)
ffffffffc020152c:	8a66                	mv	s4,s9
ffffffffc020152e:	40800633          	neg	a2,s0
ffffffffc0201532:	46a9                	li	a3,10
ffffffffc0201534:	b53d                	j	ffffffffc0201362 <vprintfmt+0x156>
ffffffffc0201536:	03b05163          	blez	s11,ffffffffc0201558 <vprintfmt+0x34c>
ffffffffc020153a:	02d00693          	li	a3,45
ffffffffc020153e:	f6d79de3          	bne	a5,a3,ffffffffc02014b8 <vprintfmt+0x2ac>
ffffffffc0201542:	00000417          	auipc	s0,0x0
ffffffffc0201546:	7de40413          	addi	s0,s0,2014 # ffffffffc0201d20 <slub_pmm_manager+0x50>
ffffffffc020154a:	02800793          	li	a5,40
ffffffffc020154e:	02800513          	li	a0,40
ffffffffc0201552:	00140a13          	addi	s4,s0,1
ffffffffc0201556:	bd6d                	j	ffffffffc0201410 <vprintfmt+0x204>
ffffffffc0201558:	00000a17          	auipc	s4,0x0
ffffffffc020155c:	7c9a0a13          	addi	s4,s4,1993 # ffffffffc0201d21 <slub_pmm_manager+0x51>
ffffffffc0201560:	02800513          	li	a0,40
ffffffffc0201564:	02800793          	li	a5,40
ffffffffc0201568:	05e00413          	li	s0,94
ffffffffc020156c:	b565                	j	ffffffffc0201414 <vprintfmt+0x208>

ffffffffc020156e <printfmt>:
ffffffffc020156e:	715d                	addi	sp,sp,-80
ffffffffc0201570:	02810313          	addi	t1,sp,40
ffffffffc0201574:	f436                	sd	a3,40(sp)
ffffffffc0201576:	869a                	mv	a3,t1
ffffffffc0201578:	ec06                	sd	ra,24(sp)
ffffffffc020157a:	f83a                	sd	a4,48(sp)
ffffffffc020157c:	fc3e                	sd	a5,56(sp)
ffffffffc020157e:	e0c2                	sd	a6,64(sp)
ffffffffc0201580:	e4c6                	sd	a7,72(sp)
ffffffffc0201582:	e41a                	sd	t1,8(sp)
ffffffffc0201584:	c89ff0ef          	jal	ra,ffffffffc020120c <vprintfmt>
ffffffffc0201588:	60e2                	ld	ra,24(sp)
ffffffffc020158a:	6161                	addi	sp,sp,80
ffffffffc020158c:	8082                	ret

ffffffffc020158e <sbi_console_putchar>:
ffffffffc020158e:	4781                	li	a5,0
ffffffffc0201590:	00004717          	auipc	a4,0x4
ffffffffc0201594:	a8073703          	ld	a4,-1408(a4) # ffffffffc0205010 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201598:	88ba                	mv	a7,a4
ffffffffc020159a:	852a                	mv	a0,a0
ffffffffc020159c:	85be                	mv	a1,a5
ffffffffc020159e:	863e                	mv	a2,a5
ffffffffc02015a0:	00000073          	ecall
ffffffffc02015a4:	87aa                	mv	a5,a0
ffffffffc02015a6:	8082                	ret

ffffffffc02015a8 <strlen>:
ffffffffc02015a8:	00054783          	lbu	a5,0(a0)
ffffffffc02015ac:	872a                	mv	a4,a0
ffffffffc02015ae:	4501                	li	a0,0
ffffffffc02015b0:	cb81                	beqz	a5,ffffffffc02015c0 <strlen+0x18>
ffffffffc02015b2:	0505                	addi	a0,a0,1
ffffffffc02015b4:	00a707b3          	add	a5,a4,a0
ffffffffc02015b8:	0007c783          	lbu	a5,0(a5)
ffffffffc02015bc:	fbfd                	bnez	a5,ffffffffc02015b2 <strlen+0xa>
ffffffffc02015be:	8082                	ret
ffffffffc02015c0:	8082                	ret

ffffffffc02015c2 <strnlen>:
ffffffffc02015c2:	4781                	li	a5,0
ffffffffc02015c4:	e589                	bnez	a1,ffffffffc02015ce <strnlen+0xc>
ffffffffc02015c6:	a811                	j	ffffffffc02015da <strnlen+0x18>
ffffffffc02015c8:	0785                	addi	a5,a5,1
ffffffffc02015ca:	00f58863          	beq	a1,a5,ffffffffc02015da <strnlen+0x18>
ffffffffc02015ce:	00f50733          	add	a4,a0,a5
ffffffffc02015d2:	00074703          	lbu	a4,0(a4)
ffffffffc02015d6:	fb6d                	bnez	a4,ffffffffc02015c8 <strnlen+0x6>
ffffffffc02015d8:	85be                	mv	a1,a5
ffffffffc02015da:	852e                	mv	a0,a1
ffffffffc02015dc:	8082                	ret

ffffffffc02015de <strcmp>:
ffffffffc02015de:	00054783          	lbu	a5,0(a0)
ffffffffc02015e2:	0005c703          	lbu	a4,0(a1)
ffffffffc02015e6:	cb89                	beqz	a5,ffffffffc02015f8 <strcmp+0x1a>
ffffffffc02015e8:	0505                	addi	a0,a0,1
ffffffffc02015ea:	0585                	addi	a1,a1,1
ffffffffc02015ec:	fee789e3          	beq	a5,a4,ffffffffc02015de <strcmp>
ffffffffc02015f0:	0007851b          	sext.w	a0,a5
ffffffffc02015f4:	9d19                	subw	a0,a0,a4
ffffffffc02015f6:	8082                	ret
ffffffffc02015f8:	4501                	li	a0,0
ffffffffc02015fa:	bfed                	j	ffffffffc02015f4 <strcmp+0x16>

ffffffffc02015fc <strncmp>:
ffffffffc02015fc:	c20d                	beqz	a2,ffffffffc020161e <strncmp+0x22>
ffffffffc02015fe:	962e                	add	a2,a2,a1
ffffffffc0201600:	a031                	j	ffffffffc020160c <strncmp+0x10>
ffffffffc0201602:	0505                	addi	a0,a0,1
ffffffffc0201604:	00e79a63          	bne	a5,a4,ffffffffc0201618 <strncmp+0x1c>
ffffffffc0201608:	00b60b63          	beq	a2,a1,ffffffffc020161e <strncmp+0x22>
ffffffffc020160c:	00054783          	lbu	a5,0(a0)
ffffffffc0201610:	0585                	addi	a1,a1,1
ffffffffc0201612:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0201616:	f7f5                	bnez	a5,ffffffffc0201602 <strncmp+0x6>
ffffffffc0201618:	40e7853b          	subw	a0,a5,a4
ffffffffc020161c:	8082                	ret
ffffffffc020161e:	4501                	li	a0,0
ffffffffc0201620:	8082                	ret

ffffffffc0201622 <memset>:
ffffffffc0201622:	ca01                	beqz	a2,ffffffffc0201632 <memset+0x10>
ffffffffc0201624:	962a                	add	a2,a2,a0
ffffffffc0201626:	87aa                	mv	a5,a0
ffffffffc0201628:	0785                	addi	a5,a5,1
ffffffffc020162a:	feb78fa3          	sb	a1,-1(a5)
ffffffffc020162e:	fec79de3          	bne	a5,a2,ffffffffc0201628 <memset+0x6>
ffffffffc0201632:	8082                	ret
