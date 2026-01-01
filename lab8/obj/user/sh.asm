
obj/__user_sh.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <__panic>:
  800020:	715d                	addi	sp,sp,-80
  800022:	8e2e                	mv	t3,a1
  800024:	e822                	sd	s0,16(sp)
  800026:	85aa                	mv	a1,a0
  800028:	8432                	mv	s0,a2
  80002a:	fc3e                	sd	a5,56(sp)
  80002c:	8672                	mv	a2,t3
  80002e:	103c                	addi	a5,sp,40
  800030:	00001517          	auipc	a0,0x1
  800034:	d3050513          	addi	a0,a0,-720 # 800d60 <main+0xce>
  800038:	ec06                	sd	ra,24(sp)
  80003a:	f436                	sd	a3,40(sp)
  80003c:	f83a                	sd	a4,48(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
  800042:	e43e                	sd	a5,8(sp)
  800044:	16e000ef          	jal	ra,8001b2 <cprintf>
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	140000ef          	jal	ra,80018c <vcprintf>
  800050:	00001517          	auipc	a0,0x1
  800054:	d7050513          	addi	a0,a0,-656 # 800dc0 <main+0x12e>
  800058:	15a000ef          	jal	ra,8001b2 <cprintf>
  80005c:	5559                	li	a0,-10
  80005e:	2be000ef          	jal	ra,80031c <exit>

0000000000800062 <__warn>:
  800062:	715d                	addi	sp,sp,-80
  800064:	832e                	mv	t1,a1
  800066:	e822                	sd	s0,16(sp)
  800068:	85aa                	mv	a1,a0
  80006a:	8432                	mv	s0,a2
  80006c:	fc3e                	sd	a5,56(sp)
  80006e:	861a                	mv	a2,t1
  800070:	103c                	addi	a5,sp,40
  800072:	00001517          	auipc	a0,0x1
  800076:	d0e50513          	addi	a0,a0,-754 # 800d80 <main+0xee>
  80007a:	ec06                	sd	ra,24(sp)
  80007c:	f436                	sd	a3,40(sp)
  80007e:	f83a                	sd	a4,48(sp)
  800080:	e0c2                	sd	a6,64(sp)
  800082:	e4c6                	sd	a7,72(sp)
  800084:	e43e                	sd	a5,8(sp)
  800086:	12c000ef          	jal	ra,8001b2 <cprintf>
  80008a:	65a2                	ld	a1,8(sp)
  80008c:	8522                	mv	a0,s0
  80008e:	0fe000ef          	jal	ra,80018c <vcprintf>
  800092:	00001517          	auipc	a0,0x1
  800096:	d2e50513          	addi	a0,a0,-722 # 800dc0 <main+0x12e>
  80009a:	118000ef          	jal	ra,8001b2 <cprintf>
  80009e:	60e2                	ld	ra,24(sp)
  8000a0:	6442                	ld	s0,16(sp)
  8000a2:	6161                	addi	sp,sp,80
  8000a4:	8082                	ret

00000000008000a6 <syscall>:
  8000a6:	7175                	addi	sp,sp,-144
  8000a8:	f8ba                	sd	a4,112(sp)
  8000aa:	e0ba                	sd	a4,64(sp)
  8000ac:	0118                	addi	a4,sp,128
  8000ae:	e42a                	sd	a0,8(sp)
  8000b0:	ecae                	sd	a1,88(sp)
  8000b2:	f0b2                	sd	a2,96(sp)
  8000b4:	f4b6                	sd	a3,104(sp)
  8000b6:	fcbe                	sd	a5,120(sp)
  8000b8:	e142                	sd	a6,128(sp)
  8000ba:	e546                	sd	a7,136(sp)
  8000bc:	f42e                	sd	a1,40(sp)
  8000be:	f832                	sd	a2,48(sp)
  8000c0:	fc36                	sd	a3,56(sp)
  8000c2:	f03a                	sd	a4,32(sp)
  8000c4:	e4be                	sd	a5,72(sp)
  8000c6:	4522                	lw	a0,8(sp)
  8000c8:	55a2                	lw	a1,40(sp)
  8000ca:	5642                	lw	a2,48(sp)
  8000cc:	56e2                	lw	a3,56(sp)
  8000ce:	4706                	lw	a4,64(sp)
  8000d0:	47a6                	lw	a5,72(sp)
  8000d2:	00000073          	ecall
  8000d6:	ce2a                	sw	a0,28(sp)
  8000d8:	4572                	lw	a0,28(sp)
  8000da:	6149                	addi	sp,sp,144
  8000dc:	8082                	ret

00000000008000de <sys_exit>:
  8000de:	85aa                	mv	a1,a0
  8000e0:	4505                	li	a0,1
  8000e2:	b7d1                	j	8000a6 <syscall>

00000000008000e4 <sys_fork>:
  8000e4:	4509                	li	a0,2
  8000e6:	b7c1                	j	8000a6 <syscall>

00000000008000e8 <sys_wait>:
  8000e8:	862e                	mv	a2,a1
  8000ea:	85aa                	mv	a1,a0
  8000ec:	450d                	li	a0,3
  8000ee:	bf65                	j	8000a6 <syscall>

00000000008000f0 <sys_putc>:
  8000f0:	85aa                	mv	a1,a0
  8000f2:	4579                	li	a0,30
  8000f4:	bf4d                	j	8000a6 <syscall>

00000000008000f6 <sys_exec>:
  8000f6:	86b2                	mv	a3,a2
  8000f8:	862e                	mv	a2,a1
  8000fa:	85aa                	mv	a1,a0
  8000fc:	4511                	li	a0,4
  8000fe:	b765                	j	8000a6 <syscall>

0000000000800100 <sys_open>:
  800100:	862e                	mv	a2,a1
  800102:	85aa                	mv	a1,a0
  800104:	06400513          	li	a0,100
  800108:	bf79                	j	8000a6 <syscall>

000000000080010a <sys_close>:
  80010a:	85aa                	mv	a1,a0
  80010c:	06500513          	li	a0,101
  800110:	bf59                	j	8000a6 <syscall>

0000000000800112 <sys_read>:
  800112:	86b2                	mv	a3,a2
  800114:	862e                	mv	a2,a1
  800116:	85aa                	mv	a1,a0
  800118:	06600513          	li	a0,102
  80011c:	b769                	j	8000a6 <syscall>

000000000080011e <sys_write>:
  80011e:	86b2                	mv	a3,a2
  800120:	862e                	mv	a2,a1
  800122:	85aa                	mv	a1,a0
  800124:	06700513          	li	a0,103
  800128:	bfbd                	j	8000a6 <syscall>

000000000080012a <sys_dup>:
  80012a:	862e                	mv	a2,a1
  80012c:	85aa                	mv	a1,a0
  80012e:	08200513          	li	a0,130
  800132:	bf95                	j	8000a6 <syscall>

0000000000800134 <_start>:
  800134:	174000ef          	jal	ra,8002a8 <umain>
  800138:	a001                	j	800138 <_start+0x4>

000000000080013a <open>:
  80013a:	1582                	slli	a1,a1,0x20
  80013c:	9181                	srli	a1,a1,0x20
  80013e:	b7c9                	j	800100 <sys_open>

0000000000800140 <close>:
  800140:	b7e9                	j	80010a <sys_close>

0000000000800142 <read>:
  800142:	bfc1                	j	800112 <sys_read>

0000000000800144 <write>:
  800144:	bfe9                	j	80011e <sys_write>

0000000000800146 <dup2>:
  800146:	b7d5                	j	80012a <sys_dup>

0000000000800148 <cputch>:
  800148:	1141                	addi	sp,sp,-16
  80014a:	e022                	sd	s0,0(sp)
  80014c:	e406                	sd	ra,8(sp)
  80014e:	842e                	mv	s0,a1
  800150:	fa1ff0ef          	jal	ra,8000f0 <sys_putc>
  800154:	401c                	lw	a5,0(s0)
  800156:	60a2                	ld	ra,8(sp)
  800158:	2785                	addiw	a5,a5,1
  80015a:	c01c                	sw	a5,0(s0)
  80015c:	6402                	ld	s0,0(sp)
  80015e:	0141                	addi	sp,sp,16
  800160:	8082                	ret

0000000000800162 <fputch>:
  800162:	1101                	addi	sp,sp,-32
  800164:	8732                	mv	a4,a2
  800166:	e822                	sd	s0,16(sp)
  800168:	87aa                	mv	a5,a0
  80016a:	842e                	mv	s0,a1
  80016c:	4605                	li	a2,1
  80016e:	00f10593          	addi	a1,sp,15
  800172:	853a                	mv	a0,a4
  800174:	ec06                	sd	ra,24(sp)
  800176:	00f107a3          	sb	a5,15(sp)
  80017a:	fcbff0ef          	jal	ra,800144 <write>
  80017e:	401c                	lw	a5,0(s0)
  800180:	60e2                	ld	ra,24(sp)
  800182:	2785                	addiw	a5,a5,1
  800184:	c01c                	sw	a5,0(s0)
  800186:	6442                	ld	s0,16(sp)
  800188:	6105                	addi	sp,sp,32
  80018a:	8082                	ret

000000000080018c <vcprintf>:
  80018c:	1101                	addi	sp,sp,-32
  80018e:	872e                	mv	a4,a1
  800190:	75dd                	lui	a1,0xffff7
  800192:	86aa                	mv	a3,a0
  800194:	0070                	addi	a2,sp,12
  800196:	00000517          	auipc	a0,0x0
  80019a:	fb250513          	addi	a0,a0,-78 # 800148 <cputch>
  80019e:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <shcwd+0xffffffffff7f29d1>
  8001a2:	ec06                	sd	ra,24(sp)
  8001a4:	c602                	sw	zero,12(sp)
  8001a6:	29c000ef          	jal	ra,800442 <vprintfmt>
  8001aa:	60e2                	ld	ra,24(sp)
  8001ac:	4532                	lw	a0,12(sp)
  8001ae:	6105                	addi	sp,sp,32
  8001b0:	8082                	ret

00000000008001b2 <cprintf>:
  8001b2:	711d                	addi	sp,sp,-96
  8001b4:	02810313          	addi	t1,sp,40
  8001b8:	8e2a                	mv	t3,a0
  8001ba:	f42e                	sd	a1,40(sp)
  8001bc:	75dd                	lui	a1,0xffff7
  8001be:	f832                	sd	a2,48(sp)
  8001c0:	fc36                	sd	a3,56(sp)
  8001c2:	e0ba                	sd	a4,64(sp)
  8001c4:	00000517          	auipc	a0,0x0
  8001c8:	f8450513          	addi	a0,a0,-124 # 800148 <cputch>
  8001cc:	0050                	addi	a2,sp,4
  8001ce:	871a                	mv	a4,t1
  8001d0:	86f2                	mv	a3,t3
  8001d2:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <shcwd+0xffffffffff7f29d1>
  8001d6:	ec06                	sd	ra,24(sp)
  8001d8:	e4be                	sd	a5,72(sp)
  8001da:	e8c2                	sd	a6,80(sp)
  8001dc:	ecc6                	sd	a7,88(sp)
  8001de:	e41a                	sd	t1,8(sp)
  8001e0:	c202                	sw	zero,4(sp)
  8001e2:	260000ef          	jal	ra,800442 <vprintfmt>
  8001e6:	60e2                	ld	ra,24(sp)
  8001e8:	4512                	lw	a0,4(sp)
  8001ea:	6125                	addi	sp,sp,96
  8001ec:	8082                	ret

00000000008001ee <cputs>:
  8001ee:	1101                	addi	sp,sp,-32
  8001f0:	e822                	sd	s0,16(sp)
  8001f2:	ec06                	sd	ra,24(sp)
  8001f4:	e426                	sd	s1,8(sp)
  8001f6:	842a                	mv	s0,a0
  8001f8:	00054503          	lbu	a0,0(a0)
  8001fc:	c51d                	beqz	a0,80022a <cputs+0x3c>
  8001fe:	0405                	addi	s0,s0,1
  800200:	4485                	li	s1,1
  800202:	9c81                	subw	s1,s1,s0
  800204:	eedff0ef          	jal	ra,8000f0 <sys_putc>
  800208:	00044503          	lbu	a0,0(s0)
  80020c:	008487bb          	addw	a5,s1,s0
  800210:	0405                	addi	s0,s0,1
  800212:	f96d                	bnez	a0,800204 <cputs+0x16>
  800214:	0017841b          	addiw	s0,a5,1
  800218:	4529                	li	a0,10
  80021a:	ed7ff0ef          	jal	ra,8000f0 <sys_putc>
  80021e:	60e2                	ld	ra,24(sp)
  800220:	8522                	mv	a0,s0
  800222:	6442                	ld	s0,16(sp)
  800224:	64a2                	ld	s1,8(sp)
  800226:	6105                	addi	sp,sp,32
  800228:	8082                	ret
  80022a:	4405                	li	s0,1
  80022c:	b7f5                	j	800218 <cputs+0x2a>

000000000080022e <fprintf>:
  80022e:	715d                	addi	sp,sp,-80
  800230:	02010313          	addi	t1,sp,32
  800234:	8e2a                	mv	t3,a0
  800236:	f032                	sd	a2,32(sp)
  800238:	f436                	sd	a3,40(sp)
  80023a:	f83a                	sd	a4,48(sp)
  80023c:	00000517          	auipc	a0,0x0
  800240:	f2650513          	addi	a0,a0,-218 # 800162 <fputch>
  800244:	86ae                	mv	a3,a1
  800246:	0050                	addi	a2,sp,4
  800248:	871a                	mv	a4,t1
  80024a:	85f2                	mv	a1,t3
  80024c:	ec06                	sd	ra,24(sp)
  80024e:	fc3e                	sd	a5,56(sp)
  800250:	e0c2                	sd	a6,64(sp)
  800252:	e4c6                	sd	a7,72(sp)
  800254:	e41a                	sd	t1,8(sp)
  800256:	c202                	sw	zero,4(sp)
  800258:	1ea000ef          	jal	ra,800442 <vprintfmt>
  80025c:	60e2                	ld	ra,24(sp)
  80025e:	4512                	lw	a0,4(sp)
  800260:	6161                	addi	sp,sp,80
  800262:	8082                	ret

0000000000800264 <initfd>:
  800264:	1101                	addi	sp,sp,-32
  800266:	87ae                	mv	a5,a1
  800268:	e426                	sd	s1,8(sp)
  80026a:	85b2                	mv	a1,a2
  80026c:	84aa                	mv	s1,a0
  80026e:	853e                	mv	a0,a5
  800270:	e822                	sd	s0,16(sp)
  800272:	ec06                	sd	ra,24(sp)
  800274:	ec7ff0ef          	jal	ra,80013a <open>
  800278:	842a                	mv	s0,a0
  80027a:	00054463          	bltz	a0,800282 <initfd+0x1e>
  80027e:	00951863          	bne	a0,s1,80028e <initfd+0x2a>
  800282:	60e2                	ld	ra,24(sp)
  800284:	8522                	mv	a0,s0
  800286:	6442                	ld	s0,16(sp)
  800288:	64a2                	ld	s1,8(sp)
  80028a:	6105                	addi	sp,sp,32
  80028c:	8082                	ret
  80028e:	8526                	mv	a0,s1
  800290:	eb1ff0ef          	jal	ra,800140 <close>
  800294:	85a6                	mv	a1,s1
  800296:	8522                	mv	a0,s0
  800298:	eafff0ef          	jal	ra,800146 <dup2>
  80029c:	84aa                	mv	s1,a0
  80029e:	8522                	mv	a0,s0
  8002a0:	ea1ff0ef          	jal	ra,800140 <close>
  8002a4:	8426                	mv	s0,s1
  8002a6:	bff1                	j	800282 <initfd+0x1e>

00000000008002a8 <umain>:
  8002a8:	1101                	addi	sp,sp,-32
  8002aa:	e822                	sd	s0,16(sp)
  8002ac:	e426                	sd	s1,8(sp)
  8002ae:	842a                	mv	s0,a0
  8002b0:	84ae                	mv	s1,a1
  8002b2:	4601                	li	a2,0
  8002b4:	00001597          	auipc	a1,0x1
  8002b8:	aec58593          	addi	a1,a1,-1300 # 800da0 <main+0x10e>
  8002bc:	4501                	li	a0,0
  8002be:	ec06                	sd	ra,24(sp)
  8002c0:	fa5ff0ef          	jal	ra,800264 <initfd>
  8002c4:	02054263          	bltz	a0,8002e8 <umain+0x40>
  8002c8:	4605                	li	a2,1
  8002ca:	00001597          	auipc	a1,0x1
  8002ce:	b1658593          	addi	a1,a1,-1258 # 800de0 <main+0x14e>
  8002d2:	4505                	li	a0,1
  8002d4:	f91ff0ef          	jal	ra,800264 <initfd>
  8002d8:	02054563          	bltz	a0,800302 <umain+0x5a>
  8002dc:	85a6                	mv	a1,s1
  8002de:	8522                	mv	a0,s0
  8002e0:	1b3000ef          	jal	ra,800c92 <main>
  8002e4:	038000ef          	jal	ra,80031c <exit>
  8002e8:	86aa                	mv	a3,a0
  8002ea:	00001617          	auipc	a2,0x1
  8002ee:	abe60613          	addi	a2,a2,-1346 # 800da8 <main+0x116>
  8002f2:	45e9                	li	a1,26
  8002f4:	00001517          	auipc	a0,0x1
  8002f8:	ad450513          	addi	a0,a0,-1324 # 800dc8 <main+0x136>
  8002fc:	d67ff0ef          	jal	ra,800062 <__warn>
  800300:	b7e1                	j	8002c8 <umain+0x20>
  800302:	86aa                	mv	a3,a0
  800304:	00001617          	auipc	a2,0x1
  800308:	ae460613          	addi	a2,a2,-1308 # 800de8 <main+0x156>
  80030c:	45f5                	li	a1,29
  80030e:	00001517          	auipc	a0,0x1
  800312:	aba50513          	addi	a0,a0,-1350 # 800dc8 <main+0x136>
  800316:	d4dff0ef          	jal	ra,800062 <__warn>
  80031a:	b7c9                	j	8002dc <umain+0x34>

000000000080031c <exit>:
  80031c:	1141                	addi	sp,sp,-16
  80031e:	e406                	sd	ra,8(sp)
  800320:	dbfff0ef          	jal	ra,8000de <sys_exit>
  800324:	00001517          	auipc	a0,0x1
  800328:	ae450513          	addi	a0,a0,-1308 # 800e08 <main+0x176>
  80032c:	e87ff0ef          	jal	ra,8001b2 <cprintf>
  800330:	a001                	j	800330 <exit+0x14>

0000000000800332 <fork>:
  800332:	bb4d                	j	8000e4 <sys_fork>

0000000000800334 <waitpid>:
  800334:	bb55                	j	8000e8 <sys_wait>

0000000000800336 <__exec>:
  800336:	619c                	ld	a5,0(a1)
  800338:	862e                	mv	a2,a1
  80033a:	cb89                	beqz	a5,80034c <__exec+0x16>
  80033c:	00858793          	addi	a5,a1,8
  800340:	4581                	li	a1,0
  800342:	6398                	ld	a4,0(a5)
  800344:	2585                	addiw	a1,a1,1
  800346:	07a1                	addi	a5,a5,8
  800348:	ff6d                	bnez	a4,800342 <__exec+0xc>
  80034a:	b375                	j	8000f6 <sys_exec>
  80034c:	4581                	li	a1,0
  80034e:	b365                	j	8000f6 <sys_exec>

0000000000800350 <strnlen>:
  800350:	4781                	li	a5,0
  800352:	e589                	bnez	a1,80035c <strnlen+0xc>
  800354:	a811                	j	800368 <strnlen+0x18>
  800356:	0785                	addi	a5,a5,1
  800358:	00f58863          	beq	a1,a5,800368 <strnlen+0x18>
  80035c:	00f50733          	add	a4,a0,a5
  800360:	00074703          	lbu	a4,0(a4)
  800364:	fb6d                	bnez	a4,800356 <strnlen+0x6>
  800366:	85be                	mv	a1,a5
  800368:	852e                	mv	a0,a1
  80036a:	8082                	ret

000000000080036c <strcpy>:
  80036c:	87aa                	mv	a5,a0
  80036e:	0005c703          	lbu	a4,0(a1)
  800372:	0785                	addi	a5,a5,1
  800374:	0585                	addi	a1,a1,1
  800376:	fee78fa3          	sb	a4,-1(a5)
  80037a:	fb75                	bnez	a4,80036e <strcpy+0x2>
  80037c:	8082                	ret

000000000080037e <strcmp>:
  80037e:	00054783          	lbu	a5,0(a0)
  800382:	0005c703          	lbu	a4,0(a1)
  800386:	cb89                	beqz	a5,800398 <strcmp+0x1a>
  800388:	0505                	addi	a0,a0,1
  80038a:	0585                	addi	a1,a1,1
  80038c:	fee789e3          	beq	a5,a4,80037e <strcmp>
  800390:	0007851b          	sext.w	a0,a5
  800394:	9d19                	subw	a0,a0,a4
  800396:	8082                	ret
  800398:	4501                	li	a0,0
  80039a:	bfed                	j	800394 <strcmp+0x16>

000000000080039c <strchr>:
  80039c:	00054783          	lbu	a5,0(a0)
  8003a0:	c799                	beqz	a5,8003ae <strchr+0x12>
  8003a2:	00f58763          	beq	a1,a5,8003b0 <strchr+0x14>
  8003a6:	00154783          	lbu	a5,1(a0)
  8003aa:	0505                	addi	a0,a0,1
  8003ac:	fbfd                	bnez	a5,8003a2 <strchr+0x6>
  8003ae:	4501                	li	a0,0
  8003b0:	8082                	ret

00000000008003b2 <printnum>:
  8003b2:	02071893          	slli	a7,a4,0x20
  8003b6:	7139                	addi	sp,sp,-64
  8003b8:	0208d893          	srli	a7,a7,0x20
  8003bc:	e456                	sd	s5,8(sp)
  8003be:	0316fab3          	remu	s5,a3,a7
  8003c2:	f822                	sd	s0,48(sp)
  8003c4:	f426                	sd	s1,40(sp)
  8003c6:	f04a                	sd	s2,32(sp)
  8003c8:	ec4e                	sd	s3,24(sp)
  8003ca:	fc06                	sd	ra,56(sp)
  8003cc:	e852                	sd	s4,16(sp)
  8003ce:	84aa                	mv	s1,a0
  8003d0:	89ae                	mv	s3,a1
  8003d2:	8932                	mv	s2,a2
  8003d4:	fff7841b          	addiw	s0,a5,-1
  8003d8:	2a81                	sext.w	s5,s5
  8003da:	0516f163          	bgeu	a3,a7,80041c <printnum+0x6a>
  8003de:	8a42                	mv	s4,a6
  8003e0:	00805863          	blez	s0,8003f0 <printnum+0x3e>
  8003e4:	347d                	addiw	s0,s0,-1
  8003e6:	864e                	mv	a2,s3
  8003e8:	85ca                	mv	a1,s2
  8003ea:	8552                	mv	a0,s4
  8003ec:	9482                	jalr	s1
  8003ee:	f87d                	bnez	s0,8003e4 <printnum+0x32>
  8003f0:	1a82                	slli	s5,s5,0x20
  8003f2:	00001797          	auipc	a5,0x1
  8003f6:	a2e78793          	addi	a5,a5,-1490 # 800e20 <main+0x18e>
  8003fa:	020ada93          	srli	s5,s5,0x20
  8003fe:	9abe                	add	s5,s5,a5
  800400:	7442                	ld	s0,48(sp)
  800402:	000ac503          	lbu	a0,0(s5)
  800406:	70e2                	ld	ra,56(sp)
  800408:	6a42                	ld	s4,16(sp)
  80040a:	6aa2                	ld	s5,8(sp)
  80040c:	864e                	mv	a2,s3
  80040e:	85ca                	mv	a1,s2
  800410:	69e2                	ld	s3,24(sp)
  800412:	7902                	ld	s2,32(sp)
  800414:	87a6                	mv	a5,s1
  800416:	74a2                	ld	s1,40(sp)
  800418:	6121                	addi	sp,sp,64
  80041a:	8782                	jr	a5
  80041c:	0316d6b3          	divu	a3,a3,a7
  800420:	87a2                	mv	a5,s0
  800422:	f91ff0ef          	jal	ra,8003b2 <printnum>
  800426:	b7e9                	j	8003f0 <printnum+0x3e>

0000000000800428 <sprintputch>:
  800428:	499c                	lw	a5,16(a1)
  80042a:	6198                	ld	a4,0(a1)
  80042c:	6594                	ld	a3,8(a1)
  80042e:	2785                	addiw	a5,a5,1
  800430:	c99c                	sw	a5,16(a1)
  800432:	00d77763          	bgeu	a4,a3,800440 <sprintputch+0x18>
  800436:	00170793          	addi	a5,a4,1
  80043a:	e19c                	sd	a5,0(a1)
  80043c:	00a70023          	sb	a0,0(a4)
  800440:	8082                	ret

0000000000800442 <vprintfmt>:
  800442:	7119                	addi	sp,sp,-128
  800444:	f4a6                	sd	s1,104(sp)
  800446:	f0ca                	sd	s2,96(sp)
  800448:	ecce                	sd	s3,88(sp)
  80044a:	e8d2                	sd	s4,80(sp)
  80044c:	e4d6                	sd	s5,72(sp)
  80044e:	e0da                	sd	s6,64(sp)
  800450:	fc5e                	sd	s7,56(sp)
  800452:	ec6e                	sd	s11,24(sp)
  800454:	fc86                	sd	ra,120(sp)
  800456:	f8a2                	sd	s0,112(sp)
  800458:	f862                	sd	s8,48(sp)
  80045a:	f466                	sd	s9,40(sp)
  80045c:	f06a                	sd	s10,32(sp)
  80045e:	89aa                	mv	s3,a0
  800460:	892e                	mv	s2,a1
  800462:	84b2                	mv	s1,a2
  800464:	8db6                	mv	s11,a3
  800466:	8aba                	mv	s5,a4
  800468:	02500a13          	li	s4,37
  80046c:	5bfd                	li	s7,-1
  80046e:	00001b17          	auipc	s6,0x1
  800472:	9e6b0b13          	addi	s6,s6,-1562 # 800e54 <main+0x1c2>
  800476:	000dc503          	lbu	a0,0(s11)
  80047a:	001d8413          	addi	s0,s11,1
  80047e:	01450b63          	beq	a0,s4,800494 <vprintfmt+0x52>
  800482:	c129                	beqz	a0,8004c4 <vprintfmt+0x82>
  800484:	864a                	mv	a2,s2
  800486:	85a6                	mv	a1,s1
  800488:	0405                	addi	s0,s0,1
  80048a:	9982                	jalr	s3
  80048c:	fff44503          	lbu	a0,-1(s0)
  800490:	ff4519e3          	bne	a0,s4,800482 <vprintfmt+0x40>
  800494:	00044583          	lbu	a1,0(s0)
  800498:	02000813          	li	a6,32
  80049c:	4d01                	li	s10,0
  80049e:	4301                	li	t1,0
  8004a0:	5cfd                	li	s9,-1
  8004a2:	5c7d                	li	s8,-1
  8004a4:	05500513          	li	a0,85
  8004a8:	48a5                	li	a7,9
  8004aa:	fdd5861b          	addiw	a2,a1,-35
  8004ae:	0ff67613          	zext.b	a2,a2
  8004b2:	00140d93          	addi	s11,s0,1
  8004b6:	04c56263          	bltu	a0,a2,8004fa <vprintfmt+0xb8>
  8004ba:	060a                	slli	a2,a2,0x2
  8004bc:	965a                	add	a2,a2,s6
  8004be:	4214                	lw	a3,0(a2)
  8004c0:	96da                	add	a3,a3,s6
  8004c2:	8682                	jr	a3
  8004c4:	70e6                	ld	ra,120(sp)
  8004c6:	7446                	ld	s0,112(sp)
  8004c8:	74a6                	ld	s1,104(sp)
  8004ca:	7906                	ld	s2,96(sp)
  8004cc:	69e6                	ld	s3,88(sp)
  8004ce:	6a46                	ld	s4,80(sp)
  8004d0:	6aa6                	ld	s5,72(sp)
  8004d2:	6b06                	ld	s6,64(sp)
  8004d4:	7be2                	ld	s7,56(sp)
  8004d6:	7c42                	ld	s8,48(sp)
  8004d8:	7ca2                	ld	s9,40(sp)
  8004da:	7d02                	ld	s10,32(sp)
  8004dc:	6de2                	ld	s11,24(sp)
  8004de:	6109                	addi	sp,sp,128
  8004e0:	8082                	ret
  8004e2:	882e                	mv	a6,a1
  8004e4:	00144583          	lbu	a1,1(s0)
  8004e8:	846e                	mv	s0,s11
  8004ea:	00140d93          	addi	s11,s0,1
  8004ee:	fdd5861b          	addiw	a2,a1,-35
  8004f2:	0ff67613          	zext.b	a2,a2
  8004f6:	fcc572e3          	bgeu	a0,a2,8004ba <vprintfmt+0x78>
  8004fa:	864a                	mv	a2,s2
  8004fc:	85a6                	mv	a1,s1
  8004fe:	02500513          	li	a0,37
  800502:	9982                	jalr	s3
  800504:	fff44783          	lbu	a5,-1(s0)
  800508:	8da2                	mv	s11,s0
  80050a:	f74786e3          	beq	a5,s4,800476 <vprintfmt+0x34>
  80050e:	ffedc783          	lbu	a5,-2(s11)
  800512:	1dfd                	addi	s11,s11,-1
  800514:	ff479de3          	bne	a5,s4,80050e <vprintfmt+0xcc>
  800518:	bfb9                	j	800476 <vprintfmt+0x34>
  80051a:	fd058c9b          	addiw	s9,a1,-48
  80051e:	00144583          	lbu	a1,1(s0)
  800522:	846e                	mv	s0,s11
  800524:	fd05869b          	addiw	a3,a1,-48
  800528:	0005861b          	sext.w	a2,a1
  80052c:	02d8e463          	bltu	a7,a3,800554 <vprintfmt+0x112>
  800530:	00144583          	lbu	a1,1(s0)
  800534:	002c969b          	slliw	a3,s9,0x2
  800538:	0196873b          	addw	a4,a3,s9
  80053c:	0017171b          	slliw	a4,a4,0x1
  800540:	9f31                	addw	a4,a4,a2
  800542:	fd05869b          	addiw	a3,a1,-48
  800546:	0405                	addi	s0,s0,1
  800548:	fd070c9b          	addiw	s9,a4,-48
  80054c:	0005861b          	sext.w	a2,a1
  800550:	fed8f0e3          	bgeu	a7,a3,800530 <vprintfmt+0xee>
  800554:	f40c5be3          	bgez	s8,8004aa <vprintfmt+0x68>
  800558:	8c66                	mv	s8,s9
  80055a:	5cfd                	li	s9,-1
  80055c:	b7b9                	j	8004aa <vprintfmt+0x68>
  80055e:	fffc4693          	not	a3,s8
  800562:	96fd                	srai	a3,a3,0x3f
  800564:	00dc77b3          	and	a5,s8,a3
  800568:	00144583          	lbu	a1,1(s0)
  80056c:	00078c1b          	sext.w	s8,a5
  800570:	846e                	mv	s0,s11
  800572:	bf25                	j	8004aa <vprintfmt+0x68>
  800574:	000aac83          	lw	s9,0(s5)
  800578:	00144583          	lbu	a1,1(s0)
  80057c:	0aa1                	addi	s5,s5,8
  80057e:	846e                	mv	s0,s11
  800580:	bfd1                	j	800554 <vprintfmt+0x112>
  800582:	4705                	li	a4,1
  800584:	008a8613          	addi	a2,s5,8
  800588:	00674463          	blt	a4,t1,800590 <vprintfmt+0x14e>
  80058c:	1c030c63          	beqz	t1,800764 <vprintfmt+0x322>
  800590:	000ab683          	ld	a3,0(s5)
  800594:	4741                	li	a4,16
  800596:	8ab2                	mv	s5,a2
  800598:	2801                	sext.w	a6,a6
  80059a:	87e2                	mv	a5,s8
  80059c:	8626                	mv	a2,s1
  80059e:	85ca                	mv	a1,s2
  8005a0:	854e                	mv	a0,s3
  8005a2:	e11ff0ef          	jal	ra,8003b2 <printnum>
  8005a6:	bdc1                	j	800476 <vprintfmt+0x34>
  8005a8:	000aa503          	lw	a0,0(s5)
  8005ac:	864a                	mv	a2,s2
  8005ae:	85a6                	mv	a1,s1
  8005b0:	0aa1                	addi	s5,s5,8
  8005b2:	9982                	jalr	s3
  8005b4:	b5c9                	j	800476 <vprintfmt+0x34>
  8005b6:	4705                	li	a4,1
  8005b8:	008a8613          	addi	a2,s5,8
  8005bc:	00674463          	blt	a4,t1,8005c4 <vprintfmt+0x182>
  8005c0:	18030d63          	beqz	t1,80075a <vprintfmt+0x318>
  8005c4:	000ab683          	ld	a3,0(s5)
  8005c8:	4729                	li	a4,10
  8005ca:	8ab2                	mv	s5,a2
  8005cc:	b7f1                	j	800598 <vprintfmt+0x156>
  8005ce:	00144583          	lbu	a1,1(s0)
  8005d2:	4d05                	li	s10,1
  8005d4:	846e                	mv	s0,s11
  8005d6:	bdd1                	j	8004aa <vprintfmt+0x68>
  8005d8:	864a                	mv	a2,s2
  8005da:	85a6                	mv	a1,s1
  8005dc:	02500513          	li	a0,37
  8005e0:	9982                	jalr	s3
  8005e2:	bd51                	j	800476 <vprintfmt+0x34>
  8005e4:	00144583          	lbu	a1,1(s0)
  8005e8:	2305                	addiw	t1,t1,1
  8005ea:	846e                	mv	s0,s11
  8005ec:	bd7d                	j	8004aa <vprintfmt+0x68>
  8005ee:	4705                	li	a4,1
  8005f0:	008a8613          	addi	a2,s5,8
  8005f4:	00674463          	blt	a4,t1,8005fc <vprintfmt+0x1ba>
  8005f8:	14030c63          	beqz	t1,800750 <vprintfmt+0x30e>
  8005fc:	000ab683          	ld	a3,0(s5)
  800600:	4721                	li	a4,8
  800602:	8ab2                	mv	s5,a2
  800604:	bf51                	j	800598 <vprintfmt+0x156>
  800606:	03000513          	li	a0,48
  80060a:	864a                	mv	a2,s2
  80060c:	85a6                	mv	a1,s1
  80060e:	e042                	sd	a6,0(sp)
  800610:	9982                	jalr	s3
  800612:	864a                	mv	a2,s2
  800614:	85a6                	mv	a1,s1
  800616:	07800513          	li	a0,120
  80061a:	9982                	jalr	s3
  80061c:	0aa1                	addi	s5,s5,8
  80061e:	6802                	ld	a6,0(sp)
  800620:	4741                	li	a4,16
  800622:	ff8ab683          	ld	a3,-8(s5)
  800626:	bf8d                	j	800598 <vprintfmt+0x156>
  800628:	000ab403          	ld	s0,0(s5)
  80062c:	008a8793          	addi	a5,s5,8
  800630:	e03e                	sd	a5,0(sp)
  800632:	14040c63          	beqz	s0,80078a <vprintfmt+0x348>
  800636:	11805063          	blez	s8,800736 <vprintfmt+0x2f4>
  80063a:	02d00693          	li	a3,45
  80063e:	0cd81963          	bne	a6,a3,800710 <vprintfmt+0x2ce>
  800642:	00044683          	lbu	a3,0(s0)
  800646:	0006851b          	sext.w	a0,a3
  80064a:	ce8d                	beqz	a3,800684 <vprintfmt+0x242>
  80064c:	00140a93          	addi	s5,s0,1
  800650:	05e00413          	li	s0,94
  800654:	000cc563          	bltz	s9,80065e <vprintfmt+0x21c>
  800658:	3cfd                	addiw	s9,s9,-1
  80065a:	037c8363          	beq	s9,s7,800680 <vprintfmt+0x23e>
  80065e:	864a                	mv	a2,s2
  800660:	85a6                	mv	a1,s1
  800662:	100d0663          	beqz	s10,80076e <vprintfmt+0x32c>
  800666:	3681                	addiw	a3,a3,-32
  800668:	10d47363          	bgeu	s0,a3,80076e <vprintfmt+0x32c>
  80066c:	03f00513          	li	a0,63
  800670:	9982                	jalr	s3
  800672:	000ac683          	lbu	a3,0(s5)
  800676:	3c7d                	addiw	s8,s8,-1
  800678:	0a85                	addi	s5,s5,1
  80067a:	0006851b          	sext.w	a0,a3
  80067e:	faf9                	bnez	a3,800654 <vprintfmt+0x212>
  800680:	01805a63          	blez	s8,800694 <vprintfmt+0x252>
  800684:	3c7d                	addiw	s8,s8,-1
  800686:	864a                	mv	a2,s2
  800688:	85a6                	mv	a1,s1
  80068a:	02000513          	li	a0,32
  80068e:	9982                	jalr	s3
  800690:	fe0c1ae3          	bnez	s8,800684 <vprintfmt+0x242>
  800694:	6a82                	ld	s5,0(sp)
  800696:	b3c5                	j	800476 <vprintfmt+0x34>
  800698:	4705                	li	a4,1
  80069a:	008a8d13          	addi	s10,s5,8
  80069e:	00674463          	blt	a4,t1,8006a6 <vprintfmt+0x264>
  8006a2:	0a030463          	beqz	t1,80074a <vprintfmt+0x308>
  8006a6:	000ab403          	ld	s0,0(s5)
  8006aa:	0c044463          	bltz	s0,800772 <vprintfmt+0x330>
  8006ae:	86a2                	mv	a3,s0
  8006b0:	8aea                	mv	s5,s10
  8006b2:	4729                	li	a4,10
  8006b4:	b5d5                	j	800598 <vprintfmt+0x156>
  8006b6:	000aa783          	lw	a5,0(s5)
  8006ba:	46e1                	li	a3,24
  8006bc:	0aa1                	addi	s5,s5,8
  8006be:	41f7d71b          	sraiw	a4,a5,0x1f
  8006c2:	8fb9                	xor	a5,a5,a4
  8006c4:	40e7873b          	subw	a4,a5,a4
  8006c8:	02e6c663          	blt	a3,a4,8006f4 <vprintfmt+0x2b2>
  8006cc:	00371793          	slli	a5,a4,0x3
  8006d0:	00001697          	auipc	a3,0x1
  8006d4:	ab868693          	addi	a3,a3,-1352 # 801188 <error_string>
  8006d8:	97b6                	add	a5,a5,a3
  8006da:	639c                	ld	a5,0(a5)
  8006dc:	cf81                	beqz	a5,8006f4 <vprintfmt+0x2b2>
  8006de:	873e                	mv	a4,a5
  8006e0:	00000697          	auipc	a3,0x0
  8006e4:	77068693          	addi	a3,a3,1904 # 800e50 <main+0x1be>
  8006e8:	8626                	mv	a2,s1
  8006ea:	85ca                	mv	a1,s2
  8006ec:	854e                	mv	a0,s3
  8006ee:	0d4000ef          	jal	ra,8007c2 <printfmt>
  8006f2:	b351                	j	800476 <vprintfmt+0x34>
  8006f4:	00000697          	auipc	a3,0x0
  8006f8:	74c68693          	addi	a3,a3,1868 # 800e40 <main+0x1ae>
  8006fc:	8626                	mv	a2,s1
  8006fe:	85ca                	mv	a1,s2
  800700:	854e                	mv	a0,s3
  800702:	0c0000ef          	jal	ra,8007c2 <printfmt>
  800706:	bb85                	j	800476 <vprintfmt+0x34>
  800708:	00000417          	auipc	s0,0x0
  80070c:	73040413          	addi	s0,s0,1840 # 800e38 <main+0x1a6>
  800710:	85e6                	mv	a1,s9
  800712:	8522                	mv	a0,s0
  800714:	e442                	sd	a6,8(sp)
  800716:	c3bff0ef          	jal	ra,800350 <strnlen>
  80071a:	40ac0c3b          	subw	s8,s8,a0
  80071e:	01805c63          	blez	s8,800736 <vprintfmt+0x2f4>
  800722:	6822                	ld	a6,8(sp)
  800724:	00080a9b          	sext.w	s5,a6
  800728:	3c7d                	addiw	s8,s8,-1
  80072a:	864a                	mv	a2,s2
  80072c:	85a6                	mv	a1,s1
  80072e:	8556                	mv	a0,s5
  800730:	9982                	jalr	s3
  800732:	fe0c1be3          	bnez	s8,800728 <vprintfmt+0x2e6>
  800736:	00044683          	lbu	a3,0(s0)
  80073a:	00140a93          	addi	s5,s0,1
  80073e:	0006851b          	sext.w	a0,a3
  800742:	daa9                	beqz	a3,800694 <vprintfmt+0x252>
  800744:	05e00413          	li	s0,94
  800748:	b731                	j	800654 <vprintfmt+0x212>
  80074a:	000aa403          	lw	s0,0(s5)
  80074e:	bfb1                	j	8006aa <vprintfmt+0x268>
  800750:	000ae683          	lwu	a3,0(s5)
  800754:	4721                	li	a4,8
  800756:	8ab2                	mv	s5,a2
  800758:	b581                	j	800598 <vprintfmt+0x156>
  80075a:	000ae683          	lwu	a3,0(s5)
  80075e:	4729                	li	a4,10
  800760:	8ab2                	mv	s5,a2
  800762:	bd1d                	j	800598 <vprintfmt+0x156>
  800764:	000ae683          	lwu	a3,0(s5)
  800768:	4741                	li	a4,16
  80076a:	8ab2                	mv	s5,a2
  80076c:	b535                	j	800598 <vprintfmt+0x156>
  80076e:	9982                	jalr	s3
  800770:	b709                	j	800672 <vprintfmt+0x230>
  800772:	864a                	mv	a2,s2
  800774:	85a6                	mv	a1,s1
  800776:	02d00513          	li	a0,45
  80077a:	e042                	sd	a6,0(sp)
  80077c:	9982                	jalr	s3
  80077e:	6802                	ld	a6,0(sp)
  800780:	8aea                	mv	s5,s10
  800782:	408006b3          	neg	a3,s0
  800786:	4729                	li	a4,10
  800788:	bd01                	j	800598 <vprintfmt+0x156>
  80078a:	03805163          	blez	s8,8007ac <vprintfmt+0x36a>
  80078e:	02d00693          	li	a3,45
  800792:	f6d81be3          	bne	a6,a3,800708 <vprintfmt+0x2c6>
  800796:	00000417          	auipc	s0,0x0
  80079a:	6a240413          	addi	s0,s0,1698 # 800e38 <main+0x1a6>
  80079e:	02800693          	li	a3,40
  8007a2:	02800513          	li	a0,40
  8007a6:	00140a93          	addi	s5,s0,1
  8007aa:	b55d                	j	800650 <vprintfmt+0x20e>
  8007ac:	00000a97          	auipc	s5,0x0
  8007b0:	68da8a93          	addi	s5,s5,1677 # 800e39 <main+0x1a7>
  8007b4:	02800513          	li	a0,40
  8007b8:	02800693          	li	a3,40
  8007bc:	05e00413          	li	s0,94
  8007c0:	bd51                	j	800654 <vprintfmt+0x212>

00000000008007c2 <printfmt>:
  8007c2:	7139                	addi	sp,sp,-64
  8007c4:	02010313          	addi	t1,sp,32
  8007c8:	f03a                	sd	a4,32(sp)
  8007ca:	871a                	mv	a4,t1
  8007cc:	ec06                	sd	ra,24(sp)
  8007ce:	f43e                	sd	a5,40(sp)
  8007d0:	f842                	sd	a6,48(sp)
  8007d2:	fc46                	sd	a7,56(sp)
  8007d4:	e41a                	sd	t1,8(sp)
  8007d6:	c6dff0ef          	jal	ra,800442 <vprintfmt>
  8007da:	60e2                	ld	ra,24(sp)
  8007dc:	6121                	addi	sp,sp,64
  8007de:	8082                	ret

00000000008007e0 <snprintf>:
  8007e0:	711d                	addi	sp,sp,-96
  8007e2:	15fd                	addi	a1,a1,-1
  8007e4:	03810313          	addi	t1,sp,56
  8007e8:	95aa                	add	a1,a1,a0
  8007ea:	f406                	sd	ra,40(sp)
  8007ec:	fc36                	sd	a3,56(sp)
  8007ee:	e0ba                	sd	a4,64(sp)
  8007f0:	e4be                	sd	a5,72(sp)
  8007f2:	e8c2                	sd	a6,80(sp)
  8007f4:	ecc6                	sd	a7,88(sp)
  8007f6:	e01a                	sd	t1,0(sp)
  8007f8:	e42a                	sd	a0,8(sp)
  8007fa:	e82e                	sd	a1,16(sp)
  8007fc:	cc02                	sw	zero,24(sp)
  8007fe:	c515                	beqz	a0,80082a <snprintf+0x4a>
  800800:	02a5e563          	bltu	a1,a0,80082a <snprintf+0x4a>
  800804:	75dd                	lui	a1,0xffff7
  800806:	86b2                	mv	a3,a2
  800808:	00000517          	auipc	a0,0x0
  80080c:	c2050513          	addi	a0,a0,-992 # 800428 <sprintputch>
  800810:	871a                	mv	a4,t1
  800812:	0030                	addi	a2,sp,8
  800814:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <shcwd+0xffffffffff7f29d1>
  800818:	c2bff0ef          	jal	ra,800442 <vprintfmt>
  80081c:	67a2                	ld	a5,8(sp)
  80081e:	00078023          	sb	zero,0(a5)
  800822:	4562                	lw	a0,24(sp)
  800824:	70a2                	ld	ra,40(sp)
  800826:	6125                	addi	sp,sp,96
  800828:	8082                	ret
  80082a:	5575                	li	a0,-3
  80082c:	bfe5                	j	800824 <snprintf+0x44>

000000000080082e <gettoken>:
  80082e:	7139                	addi	sp,sp,-64
  800830:	f822                	sd	s0,48(sp)
  800832:	6100                	ld	s0,0(a0)
  800834:	fc06                	sd	ra,56(sp)
  800836:	f426                	sd	s1,40(sp)
  800838:	f04a                	sd	s2,32(sp)
  80083a:	ec4e                	sd	s3,24(sp)
  80083c:	e852                	sd	s4,16(sp)
  80083e:	e456                	sd	s5,8(sp)
  800840:	e05a                	sd	s6,0(sp)
  800842:	c405                	beqz	s0,80086a <gettoken+0x3c>
  800844:	892a                	mv	s2,a0
  800846:	89ae                	mv	s3,a1
  800848:	00001497          	auipc	s1,0x1
  80084c:	a0848493          	addi	s1,s1,-1528 # 801250 <error_string+0xc8>
  800850:	a021                	j	800858 <gettoken+0x2a>
  800852:	0405                	addi	s0,s0,1
  800854:	fe040fa3          	sb	zero,-1(s0)
  800858:	00044583          	lbu	a1,0(s0)
  80085c:	8526                	mv	a0,s1
  80085e:	b3fff0ef          	jal	ra,80039c <strchr>
  800862:	f965                	bnez	a0,800852 <gettoken+0x24>
  800864:	00044783          	lbu	a5,0(s0)
  800868:	ef81                	bnez	a5,800880 <gettoken+0x52>
  80086a:	4501                	li	a0,0
  80086c:	70e2                	ld	ra,56(sp)
  80086e:	7442                	ld	s0,48(sp)
  800870:	74a2                	ld	s1,40(sp)
  800872:	7902                	ld	s2,32(sp)
  800874:	69e2                	ld	s3,24(sp)
  800876:	6a42                	ld	s4,16(sp)
  800878:	6aa2                	ld	s5,8(sp)
  80087a:	6b02                	ld	s6,0(sp)
  80087c:	6121                	addi	sp,sp,64
  80087e:	8082                	ret
  800880:	0089b023          	sd	s0,0(s3)
  800884:	00044583          	lbu	a1,0(s0)
  800888:	00001517          	auipc	a0,0x1
  80088c:	9d050513          	addi	a0,a0,-1584 # 801258 <error_string+0xd0>
  800890:	b0dff0ef          	jal	ra,80039c <strchr>
  800894:	84aa                	mv	s1,a0
  800896:	c10d                	beqz	a0,8008b8 <gettoken+0x8a>
  800898:	00044503          	lbu	a0,0(s0)
  80089c:	00140493          	addi	s1,s0,1
  8008a0:	00040023          	sb	zero,0(s0)
  8008a4:	0004c783          	lbu	a5,0(s1)
  8008a8:	00f037b3          	snez	a5,a5
  8008ac:	40f007b3          	neg	a5,a5
  8008b0:	8cfd                	and	s1,s1,a5
  8008b2:	00993023          	sd	s1,0(s2)
  8008b6:	bf5d                	j	80086c <gettoken+0x3e>
  8008b8:	00044583          	lbu	a1,0(s0)
  8008bc:	4981                	li	s3,0
  8008be:	00001b17          	auipc	s6,0x1
  8008c2:	9a2b0b13          	addi	s6,s6,-1630 # 801260 <error_string+0xd8>
  8008c6:	02200a13          	li	s4,34
  8008ca:	02000a93          	li	s5,32
  8008ce:	cd99                	beqz	a1,8008ec <gettoken+0xbe>
  8008d0:	02098363          	beqz	s3,8008f6 <gettoken+0xc8>
  8008d4:	00044783          	lbu	a5,0(s0)
  8008d8:	01479663          	bne	a5,s4,8008e4 <gettoken+0xb6>
  8008dc:	01540023          	sb	s5,0(s0)
  8008e0:	0019c993          	xori	s3,s3,1
  8008e4:	00144583          	lbu	a1,1(s0)
  8008e8:	0405                	addi	s0,s0,1
  8008ea:	f1fd                	bnez	a1,8008d0 <gettoken+0xa2>
  8008ec:	07700513          	li	a0,119
  8008f0:	00993023          	sd	s1,0(s2)
  8008f4:	bfa5                	j	80086c <gettoken+0x3e>
  8008f6:	855a                	mv	a0,s6
  8008f8:	aa5ff0ef          	jal	ra,80039c <strchr>
  8008fc:	dd61                	beqz	a0,8008d4 <gettoken+0xa6>
  8008fe:	84a2                	mv	s1,s0
  800900:	07700513          	li	a0,119
  800904:	b745                	j	8008a4 <gettoken+0x76>

0000000000800906 <readline>:
  800906:	711d                	addi	sp,sp,-96
  800908:	ec86                	sd	ra,88(sp)
  80090a:	e8a2                	sd	s0,80(sp)
  80090c:	e4a6                	sd	s1,72(sp)
  80090e:	e0ca                	sd	s2,64(sp)
  800910:	fc4e                	sd	s3,56(sp)
  800912:	f852                	sd	s4,48(sp)
  800914:	f456                	sd	s5,40(sp)
  800916:	f05a                	sd	s6,32(sp)
  800918:	ec5e                	sd	s7,24(sp)
  80091a:	c909                	beqz	a0,80092c <readline+0x26>
  80091c:	862a                	mv	a2,a0
  80091e:	00000597          	auipc	a1,0x0
  800922:	53258593          	addi	a1,a1,1330 # 800e50 <main+0x1be>
  800926:	4505                	li	a0,1
  800928:	907ff0ef          	jal	ra,80022e <fprintf>
  80092c:	6985                	lui	s3,0x1
  80092e:	4401                	li	s0,0
  800930:	448d                	li	s1,3
  800932:	497d                	li	s2,31
  800934:	4a21                	li	s4,8
  800936:	4aa9                	li	s5,10
  800938:	4b35                	li	s6,13
  80093a:	19f9                	addi	s3,s3,-2
  80093c:	00002b97          	auipc	s7,0x2
  800940:	7ccb8b93          	addi	s7,s7,1996 # 803108 <buffer.2>
  800944:	4605                	li	a2,1
  800946:	00f10593          	addi	a1,sp,15
  80094a:	4501                	li	a0,0
  80094c:	ff6ff0ef          	jal	ra,800142 <read>
  800950:	04054163          	bltz	a0,800992 <readline+0x8c>
  800954:	c549                	beqz	a0,8009de <readline+0xd8>
  800956:	00f14603          	lbu	a2,15(sp)
  80095a:	02960c63          	beq	a2,s1,800992 <readline+0x8c>
  80095e:	04c97663          	bgeu	s2,a2,8009aa <readline+0xa4>
  800962:	fe89c1e3          	blt	s3,s0,800944 <readline+0x3e>
  800966:	00001597          	auipc	a1,0x1
  80096a:	90a58593          	addi	a1,a1,-1782 # 801270 <error_string+0xe8>
  80096e:	4505                	li	a0,1
  800970:	8bfff0ef          	jal	ra,80022e <fprintf>
  800974:	00f14703          	lbu	a4,15(sp)
  800978:	008b87b3          	add	a5,s7,s0
  80097c:	4605                	li	a2,1
  80097e:	00e78023          	sb	a4,0(a5)
  800982:	00f10593          	addi	a1,sp,15
  800986:	4501                	li	a0,0
  800988:	2405                	addiw	s0,s0,1
  80098a:	fb8ff0ef          	jal	ra,800142 <read>
  80098e:	fc0553e3          	bgez	a0,800954 <readline+0x4e>
  800992:	4501                	li	a0,0
  800994:	60e6                	ld	ra,88(sp)
  800996:	6446                	ld	s0,80(sp)
  800998:	64a6                	ld	s1,72(sp)
  80099a:	6906                	ld	s2,64(sp)
  80099c:	79e2                	ld	s3,56(sp)
  80099e:	7a42                	ld	s4,48(sp)
  8009a0:	7aa2                	ld	s5,40(sp)
  8009a2:	7b02                	ld	s6,32(sp)
  8009a4:	6be2                	ld	s7,24(sp)
  8009a6:	6125                	addi	sp,sp,96
  8009a8:	8082                	ret
  8009aa:	01461d63          	bne	a2,s4,8009c4 <readline+0xbe>
  8009ae:	d859                	beqz	s0,800944 <readline+0x3e>
  8009b0:	4621                	li	a2,8
  8009b2:	00001597          	auipc	a1,0x1
  8009b6:	8be58593          	addi	a1,a1,-1858 # 801270 <error_string+0xe8>
  8009ba:	4505                	li	a0,1
  8009bc:	873ff0ef          	jal	ra,80022e <fprintf>
  8009c0:	347d                	addiw	s0,s0,-1
  8009c2:	b749                	j	800944 <readline+0x3e>
  8009c4:	03560a63          	beq	a2,s5,8009f8 <readline+0xf2>
  8009c8:	f7661ee3          	bne	a2,s6,800944 <readline+0x3e>
  8009cc:	4635                	li	a2,13
  8009ce:	00001597          	auipc	a1,0x1
  8009d2:	8a258593          	addi	a1,a1,-1886 # 801270 <error_string+0xe8>
  8009d6:	4505                	li	a0,1
  8009d8:	857ff0ef          	jal	ra,80022e <fprintf>
  8009dc:	a011                	j	8009e0 <readline+0xda>
  8009de:	d855                	beqz	s0,800992 <readline+0x8c>
  8009e0:	00002797          	auipc	a5,0x2
  8009e4:	72878793          	addi	a5,a5,1832 # 803108 <buffer.2>
  8009e8:	97a2                	add	a5,a5,s0
  8009ea:	00078023          	sb	zero,0(a5)
  8009ee:	00002517          	auipc	a0,0x2
  8009f2:	71a50513          	addi	a0,a0,1818 # 803108 <buffer.2>
  8009f6:	bf79                	j	800994 <readline+0x8e>
  8009f8:	4629                	li	a2,10
  8009fa:	bfd1                	j	8009ce <readline+0xc8>

00000000008009fc <reopen>:
  8009fc:	1101                	addi	sp,sp,-32
  8009fe:	ec06                	sd	ra,24(sp)
  800a00:	e822                	sd	s0,16(sp)
  800a02:	e426                	sd	s1,8(sp)
  800a04:	842e                	mv	s0,a1
  800a06:	e04a                	sd	s2,0(sp)
  800a08:	84aa                	mv	s1,a0
  800a0a:	8932                	mv	s2,a2
  800a0c:	f34ff0ef          	jal	ra,800140 <close>
  800a10:	8522                	mv	a0,s0
  800a12:	85ca                	mv	a1,s2
  800a14:	f26ff0ef          	jal	ra,80013a <open>
  800a18:	842a                	mv	s0,a0
  800a1a:	00054463          	bltz	a0,800a22 <reopen+0x26>
  800a1e:	00a49e63          	bne	s1,a0,800a3a <reopen+0x3e>
  800a22:	00142513          	slti	a0,s0,1
  800a26:	40a0053b          	negw	a0,a0
  800a2a:	60e2                	ld	ra,24(sp)
  800a2c:	8d61                	and	a0,a0,s0
  800a2e:	6442                	ld	s0,16(sp)
  800a30:	64a2                	ld	s1,8(sp)
  800a32:	6902                	ld	s2,0(sp)
  800a34:	2501                	sext.w	a0,a0
  800a36:	6105                	addi	sp,sp,32
  800a38:	8082                	ret
  800a3a:	8526                	mv	a0,s1
  800a3c:	f04ff0ef          	jal	ra,800140 <close>
  800a40:	85a6                	mv	a1,s1
  800a42:	8522                	mv	a0,s0
  800a44:	f02ff0ef          	jal	ra,800146 <dup2>
  800a48:	84aa                	mv	s1,a0
  800a4a:	8522                	mv	a0,s0
  800a4c:	ef4ff0ef          	jal	ra,800140 <close>
  800a50:	8426                	mv	s0,s1
  800a52:	bfc1                	j	800a22 <reopen+0x26>

0000000000800a54 <runcmd>:
  800a54:	7159                	addi	sp,sp,-112
  800a56:	e8ca                	sd	s2,80(sp)
  800a58:	e0d2                	sd	s4,64(sp)
  800a5a:	f85a                	sd	s6,48(sp)
  800a5c:	f45e                	sd	s7,40(sp)
  800a5e:	f486                	sd	ra,104(sp)
  800a60:	f0a2                	sd	s0,96(sp)
  800a62:	eca6                	sd	s1,88(sp)
  800a64:	e4ce                	sd	s3,72(sp)
  800a66:	fc56                	sd	s5,56(sp)
  800a68:	f062                	sd	s8,32(sp)
  800a6a:	e42a                	sd	a0,8(sp)
  800a6c:	07700913          	li	s2,119
  800a70:	02000b13          	li	s6,32
  800a74:	00001b97          	auipc	s7,0x1
  800a78:	58cb8b93          	addi	s7,s7,1420 # 802000 <argv.1>
  800a7c:	03b00a13          	li	s4,59
  800a80:	4401                	li	s0,0
  800a82:	03e00493          	li	s1,62
  800a86:	03c00993          	li	s3,60
  800a8a:	082c                	addi	a1,sp,24
  800a8c:	0028                	addi	a0,sp,8
  800a8e:	da1ff0ef          	jal	ra,80082e <gettoken>
  800a92:	0e950e63          	beq	a0,s1,800b8e <runcmd+0x13a>
  800a96:	04a4c763          	blt	s1,a0,800ae4 <runcmd+0x90>
  800a9a:	0f450063          	beq	a0,s4,800b7a <runcmd+0x126>
  800a9e:	07351e63          	bne	a0,s3,800b1a <runcmd+0xc6>
  800aa2:	082c                	addi	a1,sp,24
  800aa4:	0028                	addi	a0,sp,8
  800aa6:	d89ff0ef          	jal	ra,80082e <gettoken>
  800aaa:	19251463          	bne	a0,s2,800c32 <runcmd+0x1de>
  800aae:	6ae2                	ld	s5,24(sp)
  800ab0:	4501                	li	a0,0
  800ab2:	e8eff0ef          	jal	ra,800140 <close>
  800ab6:	8556                	mv	a0,s5
  800ab8:	4581                	li	a1,0
  800aba:	e80ff0ef          	jal	ra,80013a <open>
  800abe:	8aaa                	mv	s5,a0
  800ac0:	10054963          	bltz	a0,800bd2 <runcmd+0x17e>
  800ac4:	d179                	beqz	a0,800a8a <runcmd+0x36>
  800ac6:	4501                	li	a0,0
  800ac8:	e78ff0ef          	jal	ra,800140 <close>
  800acc:	4581                	li	a1,0
  800ace:	8556                	mv	a0,s5
  800ad0:	e76ff0ef          	jal	ra,800146 <dup2>
  800ad4:	8c2a                	mv	s8,a0
  800ad6:	8556                	mv	a0,s5
  800ad8:	e68ff0ef          	jal	ra,800140 <close>
  800adc:	fa0c57e3          	bgez	s8,800a8a <runcmd+0x36>
  800ae0:	8462                	mv	s0,s8
  800ae2:	a8bd                	j	800b60 <runcmd+0x10c>
  800ae4:	0d250e63          	beq	a0,s2,800bc0 <runcmd+0x16c>
  800ae8:	07c00793          	li	a5,124
  800aec:	06f51163          	bne	a0,a5,800b4e <runcmd+0xfa>
  800af0:	843ff0ef          	jal	ra,800332 <fork>
  800af4:	87aa                	mv	a5,a0
  800af6:	14051763          	bnez	a0,800c44 <runcmd+0x1f0>
  800afa:	e46ff0ef          	jal	ra,800140 <close>
  800afe:	4581                	li	a1,0
  800b00:	4501                	li	a0,0
  800b02:	e44ff0ef          	jal	ra,800146 <dup2>
  800b06:	842a                	mv	s0,a0
  800b08:	04054c63          	bltz	a0,800b60 <runcmd+0x10c>
  800b0c:	4501                	li	a0,0
  800b0e:	e32ff0ef          	jal	ra,800140 <close>
  800b12:	4501                	li	a0,0
  800b14:	e2cff0ef          	jal	ra,800140 <close>
  800b18:	b7a5                	j	800a80 <runcmd+0x2c>
  800b1a:	e915                	bnez	a0,800b4e <runcmd+0xfa>
  800b1c:	c031                	beqz	s0,800b60 <runcmd+0x10c>
  800b1e:	00001497          	auipc	s1,0x1
  800b22:	4e248493          	addi	s1,s1,1250 # 802000 <argv.1>
  800b26:	6088                	ld	a0,0(s1)
  800b28:	00001597          	auipc	a1,0x1
  800b2c:	81858593          	addi	a1,a1,-2024 # 801340 <error_string+0x1b8>
  800b30:	84fff0ef          	jal	ra,80037e <strcmp>
  800b34:	e14d                	bnez	a0,800bd6 <runcmd+0x182>
  800b36:	4789                	li	a5,2
  800b38:	12f41963          	bne	s0,a5,800c6a <runcmd+0x216>
  800b3c:	648c                	ld	a1,8(s1)
  800b3e:	00003517          	auipc	a0,0x3
  800b42:	5ca50513          	addi	a0,a0,1482 # 804108 <shcwd>
  800b46:	4401                	li	s0,0
  800b48:	825ff0ef          	jal	ra,80036c <strcpy>
  800b4c:	a811                	j	800b60 <runcmd+0x10c>
  800b4e:	862a                	mv	a2,a0
  800b50:	00000597          	auipc	a1,0x0
  800b54:	7c858593          	addi	a1,a1,1992 # 801318 <error_string+0x190>
  800b58:	4505                	li	a0,1
  800b5a:	ed4ff0ef          	jal	ra,80022e <fprintf>
  800b5e:	547d                	li	s0,-1
  800b60:	70a6                	ld	ra,104(sp)
  800b62:	8522                	mv	a0,s0
  800b64:	7406                	ld	s0,96(sp)
  800b66:	64e6                	ld	s1,88(sp)
  800b68:	6946                	ld	s2,80(sp)
  800b6a:	69a6                	ld	s3,72(sp)
  800b6c:	6a06                	ld	s4,64(sp)
  800b6e:	7ae2                	ld	s5,56(sp)
  800b70:	7b42                	ld	s6,48(sp)
  800b72:	7ba2                	ld	s7,40(sp)
  800b74:	7c02                	ld	s8,32(sp)
  800b76:	6165                	addi	sp,sp,112
  800b78:	8082                	ret
  800b7a:	fb8ff0ef          	jal	ra,800332 <fork>
  800b7e:	87aa                	mv	a5,a0
  800b80:	dd51                	beqz	a0,800b1c <runcmd+0xc8>
  800b82:	08054463          	bltz	a0,800c0a <runcmd+0x1b6>
  800b86:	4581                	li	a1,0
  800b88:	facff0ef          	jal	ra,800334 <waitpid>
  800b8c:	bdd5                	j	800a80 <runcmd+0x2c>
  800b8e:	082c                	addi	a1,sp,24
  800b90:	0028                	addi	a0,sp,8
  800b92:	c9dff0ef          	jal	ra,80082e <gettoken>
  800b96:	0d251c63          	bne	a0,s2,800c6e <runcmd+0x21a>
  800b9a:	6ae2                	ld	s5,24(sp)
  800b9c:	4505                	li	a0,1
  800b9e:	da2ff0ef          	jal	ra,800140 <close>
  800ba2:	8556                	mv	a0,s5
  800ba4:	45d9                	li	a1,22
  800ba6:	d94ff0ef          	jal	ra,80013a <open>
  800baa:	8aaa                	mv	s5,a0
  800bac:	02054363          	bltz	a0,800bd2 <runcmd+0x17e>
  800bb0:	4785                	li	a5,1
  800bb2:	ecf50ce3          	beq	a0,a5,800a8a <runcmd+0x36>
  800bb6:	4505                	li	a0,1
  800bb8:	d88ff0ef          	jal	ra,800140 <close>
  800bbc:	4585                	li	a1,1
  800bbe:	bf01                	j	800ace <runcmd+0x7a>
  800bc0:	0d640063          	beq	s0,s6,800c80 <runcmd+0x22c>
  800bc4:	6762                	ld	a4,24(sp)
  800bc6:	00341793          	slli	a5,s0,0x3
  800bca:	97de                	add	a5,a5,s7
  800bcc:	e398                	sd	a4,0(a5)
  800bce:	2405                	addiw	s0,s0,1
  800bd0:	bd6d                	j	800a8a <runcmd+0x36>
  800bd2:	8456                	mv	s0,s5
  800bd4:	b771                	j	800b60 <runcmd+0x10c>
  800bd6:	6088                	ld	a0,0(s1)
  800bd8:	4581                	li	a1,0
  800bda:	d60ff0ef          	jal	ra,80013a <open>
  800bde:	87aa                	mv	a5,a0
  800be0:	02054263          	bltz	a0,800c04 <runcmd+0x1b0>
  800be4:	d5cff0ef          	jal	ra,800140 <close>
  800be8:	00341793          	slli	a5,s0,0x3
  800bec:	97a6                	add	a5,a5,s1
  800bee:	0007b023          	sd	zero,0(a5)
  800bf2:	6088                	ld	a0,0(s1)
  800bf4:	00001597          	auipc	a1,0x1
  800bf8:	40c58593          	addi	a1,a1,1036 # 802000 <argv.1>
  800bfc:	f3aff0ef          	jal	ra,800336 <__exec>
  800c00:	842a                	mv	s0,a0
  800c02:	bfb9                	j	800b60 <runcmd+0x10c>
  800c04:	5741                	li	a4,-16
  800c06:	00e50463          	beq	a0,a4,800c0e <runcmd+0x1ba>
  800c0a:	843e                	mv	s0,a5
  800c0c:	bf91                	j	800b60 <runcmd+0x10c>
  800c0e:	6094                	ld	a3,0(s1)
  800c10:	00000617          	auipc	a2,0x0
  800c14:	73860613          	addi	a2,a2,1848 # 801348 <error_string+0x1c0>
  800c18:	6585                	lui	a1,0x1
  800c1a:	00001517          	auipc	a0,0x1
  800c1e:	4ee50513          	addi	a0,a0,1262 # 802108 <argv0.0>
  800c22:	bbfff0ef          	jal	ra,8007e0 <snprintf>
  800c26:	00001797          	auipc	a5,0x1
  800c2a:	4e278793          	addi	a5,a5,1250 # 802108 <argv0.0>
  800c2e:	e09c                	sd	a5,0(s1)
  800c30:	bf65                	j	800be8 <runcmd+0x194>
  800c32:	00000597          	auipc	a1,0x0
  800c36:	68658593          	addi	a1,a1,1670 # 8012b8 <error_string+0x130>
  800c3a:	4505                	li	a0,1
  800c3c:	df2ff0ef          	jal	ra,80022e <fprintf>
  800c40:	547d                	li	s0,-1
  800c42:	bf39                	j	800b60 <runcmd+0x10c>
  800c44:	fc0543e3          	bltz	a0,800c0a <runcmd+0x1b6>
  800c48:	4505                	li	a0,1
  800c4a:	cf6ff0ef          	jal	ra,800140 <close>
  800c4e:	4585                	li	a1,1
  800c50:	4501                	li	a0,0
  800c52:	cf4ff0ef          	jal	ra,800146 <dup2>
  800c56:	87aa                	mv	a5,a0
  800c58:	fa0549e3          	bltz	a0,800c0a <runcmd+0x1b6>
  800c5c:	4501                	li	a0,0
  800c5e:	ce2ff0ef          	jal	ra,800140 <close>
  800c62:	4501                	li	a0,0
  800c64:	cdcff0ef          	jal	ra,800140 <close>
  800c68:	bd55                	j	800b1c <runcmd+0xc8>
  800c6a:	547d                	li	s0,-1
  800c6c:	bdd5                	j	800b60 <runcmd+0x10c>
  800c6e:	00000597          	auipc	a1,0x0
  800c72:	67a58593          	addi	a1,a1,1658 # 8012e8 <error_string+0x160>
  800c76:	4505                	li	a0,1
  800c78:	db6ff0ef          	jal	ra,80022e <fprintf>
  800c7c:	547d                	li	s0,-1
  800c7e:	b5cd                	j	800b60 <runcmd+0x10c>
  800c80:	00000597          	auipc	a1,0x0
  800c84:	61858593          	addi	a1,a1,1560 # 801298 <error_string+0x110>
  800c88:	4505                	li	a0,1
  800c8a:	da4ff0ef          	jal	ra,80022e <fprintf>
  800c8e:	547d                	li	s0,-1
  800c90:	bdc1                	j	800b60 <runcmd+0x10c>

0000000000800c92 <main>:
  800c92:	7179                	addi	sp,sp,-48
  800c94:	f022                	sd	s0,32(sp)
  800c96:	842a                	mv	s0,a0
  800c98:	00000517          	auipc	a0,0x0
  800c9c:	6b850513          	addi	a0,a0,1720 # 801350 <error_string+0x1c8>
  800ca0:	ec26                	sd	s1,24(sp)
  800ca2:	f406                	sd	ra,40(sp)
  800ca4:	e84a                	sd	s2,16(sp)
  800ca6:	84ae                	mv	s1,a1
  800ca8:	d46ff0ef          	jal	ra,8001ee <cputs>
  800cac:	4789                	li	a5,2
  800cae:	04f40e63          	beq	s0,a5,800d0a <main+0x78>
  800cb2:	00000497          	auipc	s1,0x0
  800cb6:	6ee48493          	addi	s1,s1,1774 # 8013a0 <error_string+0x218>
  800cba:	0687c163          	blt	a5,s0,800d1c <main+0x8a>
  800cbe:	00000917          	auipc	s2,0x0
  800cc2:	6ea90913          	addi	s2,s2,1770 # 8013a8 <error_string+0x220>
  800cc6:	a831                	j	800ce2 <main+0x50>
  800cc8:	00003797          	auipc	a5,0x3
  800ccc:	44078023          	sb	zero,1088(a5) # 804108 <shcwd>
  800cd0:	e62ff0ef          	jal	ra,800332 <fork>
  800cd4:	cd2d                	beqz	a0,800d4e <main+0xbc>
  800cd6:	04054c63          	bltz	a0,800d2e <main+0x9c>
  800cda:	006c                	addi	a1,sp,12
  800cdc:	e58ff0ef          	jal	ra,800334 <waitpid>
  800ce0:	cd09                	beqz	a0,800cfa <main+0x68>
  800ce2:	8526                	mv	a0,s1
  800ce4:	c23ff0ef          	jal	ra,800906 <readline>
  800ce8:	842a                	mv	s0,a0
  800cea:	fd79                	bnez	a0,800cc8 <main+0x36>
  800cec:	4501                	li	a0,0
  800cee:	70a2                	ld	ra,40(sp)
  800cf0:	7402                	ld	s0,32(sp)
  800cf2:	64e2                	ld	s1,24(sp)
  800cf4:	6942                	ld	s2,16(sp)
  800cf6:	6145                	addi	sp,sp,48
  800cf8:	8082                	ret
  800cfa:	46b2                	lw	a3,12(sp)
  800cfc:	d2fd                	beqz	a3,800ce2 <main+0x50>
  800cfe:	8636                	mv	a2,a3
  800d00:	85ca                	mv	a1,s2
  800d02:	4505                	li	a0,1
  800d04:	d2aff0ef          	jal	ra,80022e <fprintf>
  800d08:	bfe9                	j	800ce2 <main+0x50>
  800d0a:	648c                	ld	a1,8(s1)
  800d0c:	4601                	li	a2,0
  800d0e:	4501                	li	a0,0
  800d10:	cedff0ef          	jal	ra,8009fc <reopen>
  800d14:	c62a                	sw	a0,12(sp)
  800d16:	4481                	li	s1,0
  800d18:	d15d                	beqz	a0,800cbe <main+0x2c>
  800d1a:	bfd1                	j	800cee <main+0x5c>
  800d1c:	00000597          	auipc	a1,0x0
  800d20:	55c58593          	addi	a1,a1,1372 # 801278 <error_string+0xf0>
  800d24:	4505                	li	a0,1
  800d26:	d08ff0ef          	jal	ra,80022e <fprintf>
  800d2a:	557d                	li	a0,-1
  800d2c:	b7c9                	j	800cee <main+0x5c>
  800d2e:	00000697          	auipc	a3,0x0
  800d32:	63a68693          	addi	a3,a3,1594 # 801368 <error_string+0x1e0>
  800d36:	00000617          	auipc	a2,0x0
  800d3a:	64260613          	addi	a2,a2,1602 # 801378 <error_string+0x1f0>
  800d3e:	0f200593          	li	a1,242
  800d42:	00000517          	auipc	a0,0x0
  800d46:	64e50513          	addi	a0,a0,1614 # 801390 <error_string+0x208>
  800d4a:	ad6ff0ef          	jal	ra,800020 <__panic>
  800d4e:	8522                	mv	a0,s0
  800d50:	d05ff0ef          	jal	ra,800a54 <runcmd>
  800d54:	c62a                	sw	a0,12(sp)
  800d56:	dc6ff0ef          	jal	ra,80031c <exit>
