
obj/__user_cowtest.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0c6000ef          	jal	ra,8000e6 <umain>
1:  j 1b
  800024:	a001                	j	800024 <_start+0x4>

0000000000800026 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800026:	1141                	addi	sp,sp,-16
  800028:	e022                	sd	s0,0(sp)
  80002a:	e406                	sd	ra,8(sp)
  80002c:	842e                	mv	s0,a1
    sys_putc(c);
  80002e:	094000ef          	jal	ra,8000c2 <sys_putc>
    (*cnt) ++;
  800032:	401c                	lw	a5,0(s0)
}
  800034:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  800036:	2785                	addiw	a5,a5,1
  800038:	c01c                	sw	a5,0(s0)
}
  80003a:	6402                	ld	s0,0(sp)
  80003c:	0141                	addi	sp,sp,16
  80003e:	8082                	ret

0000000000800040 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800040:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  800042:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800046:	8e2a                	mv	t3,a0
  800048:	f42e                	sd	a1,40(sp)
  80004a:	f832                	sd	a2,48(sp)
  80004c:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80004e:	00000517          	auipc	a0,0x0
  800052:	fd850513          	addi	a0,a0,-40 # 800026 <cputch>
  800056:	004c                	addi	a1,sp,4
  800058:	869a                	mv	a3,t1
  80005a:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
  80005c:	ec06                	sd	ra,24(sp)
  80005e:	e0ba                	sd	a4,64(sp)
  800060:	e4be                	sd	a5,72(sp)
  800062:	e8c2                	sd	a6,80(sp)
  800064:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  800066:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  800068:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80006a:	0f4000ef          	jal	ra,80015e <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  80006e:	60e2                	ld	ra,24(sp)
  800070:	4512                	lw	a0,4(sp)
  800072:	6125                	addi	sp,sp,96
  800074:	8082                	ret

0000000000800076 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
  800076:	7175                	addi	sp,sp,-144
  800078:	f8ba                	sd	a4,112(sp)
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
  80007a:	e0ba                	sd	a4,64(sp)
  80007c:	0118                	addi	a4,sp,128
syscall(int64_t num, ...) {
  80007e:	e42a                	sd	a0,8(sp)
  800080:	ecae                	sd	a1,88(sp)
  800082:	f0b2                	sd	a2,96(sp)
  800084:	f4b6                	sd	a3,104(sp)
  800086:	fcbe                	sd	a5,120(sp)
  800088:	e142                	sd	a6,128(sp)
  80008a:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);
  80008c:	f42e                	sd	a1,40(sp)
  80008e:	f832                	sd	a2,48(sp)
  800090:	fc36                	sd	a3,56(sp)
  800092:	f03a                	sd	a4,32(sp)
  800094:	e4be                	sd	a5,72(sp)
    }
    va_end(ap);

    asm volatile (
  800096:	6522                	ld	a0,8(sp)
  800098:	75a2                	ld	a1,40(sp)
  80009a:	7642                	ld	a2,48(sp)
  80009c:	76e2                	ld	a3,56(sp)
  80009e:	6706                	ld	a4,64(sp)
  8000a0:	67a6                	ld	a5,72(sp)
  8000a2:	00000073          	ecall
  8000a6:	00a13e23          	sd	a0,28(sp)
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
    return ret;
}
  8000aa:	4572                	lw	a0,28(sp)
  8000ac:	6149                	addi	sp,sp,144
  8000ae:	8082                	ret

00000000008000b0 <sys_exit>:

int
sys_exit(int64_t error_code) {
  8000b0:	85aa                	mv	a1,a0
    return syscall(SYS_exit, error_code);
  8000b2:	4505                	li	a0,1
  8000b4:	b7c9                	j	800076 <syscall>

00000000008000b6 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  8000b6:	4509                	li	a0,2
  8000b8:	bf7d                	j	800076 <syscall>

00000000008000ba <sys_wait>:
}

int
sys_wait(int64_t pid, int *store) {
  8000ba:	862e                	mv	a2,a1
    return syscall(SYS_wait, pid, store);
  8000bc:	85aa                	mv	a1,a0
  8000be:	450d                	li	a0,3
  8000c0:	bf5d                	j	800076 <syscall>

00000000008000c2 <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  8000c2:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000c4:	4579                	li	a0,30
  8000c6:	bf45                	j	800076 <syscall>

00000000008000c8 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000c8:	1141                	addi	sp,sp,-16
  8000ca:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000cc:	fe5ff0ef          	jal	ra,8000b0 <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000d0:	00000517          	auipc	a0,0x0
  8000d4:	73850513          	addi	a0,a0,1848 # 800808 <main+0x68>
  8000d8:	f69ff0ef          	jal	ra,800040 <cprintf>
    while (1);
  8000dc:	a001                	j	8000dc <exit+0x14>

00000000008000de <fork>:
}

int
fork(void) {
    return sys_fork();
  8000de:	bfe1                	j	8000b6 <sys_fork>

00000000008000e0 <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  8000e0:	4581                	li	a1,0
  8000e2:	4501                	li	a0,0
  8000e4:	bfd9                	j	8000ba <sys_wait>

00000000008000e6 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000e6:	1141                	addi	sp,sp,-16
  8000e8:	e406                	sd	ra,8(sp)
    int ret = main();
  8000ea:	6b6000ef          	jal	ra,8007a0 <main>
    exit(ret);
  8000ee:	fdbff0ef          	jal	ra,8000c8 <exit>

00000000008000f2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000f2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000f6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8000f8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000fc:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000fe:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800102:	f022                	sd	s0,32(sp)
  800104:	ec26                	sd	s1,24(sp)
  800106:	e84a                	sd	s2,16(sp)
  800108:	f406                	sd	ra,40(sp)
  80010a:	e44e                	sd	s3,8(sp)
  80010c:	84aa                	mv	s1,a0
  80010e:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800110:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800114:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800116:	03067e63          	bgeu	a2,a6,800152 <printnum+0x60>
  80011a:	89be                	mv	s3,a5
        while (-- width > 0)
  80011c:	00805763          	blez	s0,80012a <printnum+0x38>
  800120:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800122:	85ca                	mv	a1,s2
  800124:	854e                	mv	a0,s3
  800126:	9482                	jalr	s1
        while (-- width > 0)
  800128:	fc65                	bnez	s0,800120 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80012a:	1a02                	slli	s4,s4,0x20
  80012c:	00000797          	auipc	a5,0x0
  800130:	6f478793          	addi	a5,a5,1780 # 800820 <main+0x80>
  800134:	020a5a13          	srli	s4,s4,0x20
  800138:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80013a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80013c:	000a4503          	lbu	a0,0(s4)
}
  800140:	70a2                	ld	ra,40(sp)
  800142:	69a2                	ld	s3,8(sp)
  800144:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800146:	85ca                	mv	a1,s2
  800148:	87a6                	mv	a5,s1
}
  80014a:	6942                	ld	s2,16(sp)
  80014c:	64e2                	ld	s1,24(sp)
  80014e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800150:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800152:	03065633          	divu	a2,a2,a6
  800156:	8722                	mv	a4,s0
  800158:	f9bff0ef          	jal	ra,8000f2 <printnum>
  80015c:	b7f9                	j	80012a <printnum+0x38>

000000000080015e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  80015e:	7119                	addi	sp,sp,-128
  800160:	f4a6                	sd	s1,104(sp)
  800162:	f0ca                	sd	s2,96(sp)
  800164:	ecce                	sd	s3,88(sp)
  800166:	e8d2                	sd	s4,80(sp)
  800168:	e4d6                	sd	s5,72(sp)
  80016a:	e0da                	sd	s6,64(sp)
  80016c:	fc5e                	sd	s7,56(sp)
  80016e:	f06a                	sd	s10,32(sp)
  800170:	fc86                	sd	ra,120(sp)
  800172:	f8a2                	sd	s0,112(sp)
  800174:	f862                	sd	s8,48(sp)
  800176:	f466                	sd	s9,40(sp)
  800178:	ec6e                	sd	s11,24(sp)
  80017a:	892a                	mv	s2,a0
  80017c:	84ae                	mv	s1,a1
  80017e:	8d32                	mv	s10,a2
  800180:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800182:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800186:	5b7d                	li	s6,-1
  800188:	00000a97          	auipc	s5,0x0
  80018c:	6cca8a93          	addi	s5,s5,1740 # 800854 <main+0xb4>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800190:	00001b97          	auipc	s7,0x1
  800194:	8e0b8b93          	addi	s7,s7,-1824 # 800a70 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800198:	000d4503          	lbu	a0,0(s10)
  80019c:	001d0413          	addi	s0,s10,1
  8001a0:	01350a63          	beq	a0,s3,8001b4 <vprintfmt+0x56>
            if (ch == '\0') {
  8001a4:	c121                	beqz	a0,8001e4 <vprintfmt+0x86>
            putch(ch, putdat);
  8001a6:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001a8:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001aa:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ac:	fff44503          	lbu	a0,-1(s0)
  8001b0:	ff351ae3          	bne	a0,s3,8001a4 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  8001b4:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001b8:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001bc:	4c81                	li	s9,0
  8001be:	4881                	li	a7,0
        width = precision = -1;
  8001c0:	5c7d                	li	s8,-1
  8001c2:	5dfd                	li	s11,-1
  8001c4:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  8001c8:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001ca:	fdd6059b          	addiw	a1,a2,-35
  8001ce:	0ff5f593          	zext.b	a1,a1
  8001d2:	00140d13          	addi	s10,s0,1
  8001d6:	04b56263          	bltu	a0,a1,80021a <vprintfmt+0xbc>
  8001da:	058a                	slli	a1,a1,0x2
  8001dc:	95d6                	add	a1,a1,s5
  8001de:	4194                	lw	a3,0(a1)
  8001e0:	96d6                	add	a3,a3,s5
  8001e2:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001e4:	70e6                	ld	ra,120(sp)
  8001e6:	7446                	ld	s0,112(sp)
  8001e8:	74a6                	ld	s1,104(sp)
  8001ea:	7906                	ld	s2,96(sp)
  8001ec:	69e6                	ld	s3,88(sp)
  8001ee:	6a46                	ld	s4,80(sp)
  8001f0:	6aa6                	ld	s5,72(sp)
  8001f2:	6b06                	ld	s6,64(sp)
  8001f4:	7be2                	ld	s7,56(sp)
  8001f6:	7c42                	ld	s8,48(sp)
  8001f8:	7ca2                	ld	s9,40(sp)
  8001fa:	7d02                	ld	s10,32(sp)
  8001fc:	6de2                	ld	s11,24(sp)
  8001fe:	6109                	addi	sp,sp,128
  800200:	8082                	ret
            padc = '0';
  800202:	87b2                	mv	a5,a2
            goto reswitch;
  800204:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800208:	846a                	mv	s0,s10
  80020a:	00140d13          	addi	s10,s0,1
  80020e:	fdd6059b          	addiw	a1,a2,-35
  800212:	0ff5f593          	zext.b	a1,a1
  800216:	fcb572e3          	bgeu	a0,a1,8001da <vprintfmt+0x7c>
            putch('%', putdat);
  80021a:	85a6                	mv	a1,s1
  80021c:	02500513          	li	a0,37
  800220:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800222:	fff44783          	lbu	a5,-1(s0)
  800226:	8d22                	mv	s10,s0
  800228:	f73788e3          	beq	a5,s3,800198 <vprintfmt+0x3a>
  80022c:	ffed4783          	lbu	a5,-2(s10)
  800230:	1d7d                	addi	s10,s10,-1
  800232:	ff379de3          	bne	a5,s3,80022c <vprintfmt+0xce>
  800236:	b78d                	j	800198 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  800238:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  80023c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800240:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800242:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800246:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  80024a:	02d86463          	bltu	a6,a3,800272 <vprintfmt+0x114>
                ch = *fmt;
  80024e:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  800252:	002c169b          	slliw	a3,s8,0x2
  800256:	0186873b          	addw	a4,a3,s8
  80025a:	0017171b          	slliw	a4,a4,0x1
  80025e:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  800260:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  800264:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800266:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  80026a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  80026e:	fed870e3          	bgeu	a6,a3,80024e <vprintfmt+0xf0>
            if (width < 0)
  800272:	f40ddce3          	bgez	s11,8001ca <vprintfmt+0x6c>
                width = precision, precision = -1;
  800276:	8de2                	mv	s11,s8
  800278:	5c7d                	li	s8,-1
  80027a:	bf81                	j	8001ca <vprintfmt+0x6c>
            if (width < 0)
  80027c:	fffdc693          	not	a3,s11
  800280:	96fd                	srai	a3,a3,0x3f
  800282:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  800286:	00144603          	lbu	a2,1(s0)
  80028a:	2d81                	sext.w	s11,s11
  80028c:	846a                	mv	s0,s10
            goto reswitch;
  80028e:	bf35                	j	8001ca <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  800290:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800294:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800298:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  80029a:	846a                	mv	s0,s10
            goto process_precision;
  80029c:	bfd9                	j	800272 <vprintfmt+0x114>
    if (lflag >= 2) {
  80029e:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002a0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002a4:	01174463          	blt	a4,a7,8002ac <vprintfmt+0x14e>
    else if (lflag) {
  8002a8:	1a088e63          	beqz	a7,800464 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  8002ac:	000a3603          	ld	a2,0(s4)
  8002b0:	46c1                	li	a3,16
  8002b2:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002b4:	2781                	sext.w	a5,a5
  8002b6:	876e                	mv	a4,s11
  8002b8:	85a6                	mv	a1,s1
  8002ba:	854a                	mv	a0,s2
  8002bc:	e37ff0ef          	jal	ra,8000f2 <printnum>
            break;
  8002c0:	bde1                	j	800198 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  8002c2:	000a2503          	lw	a0,0(s4)
  8002c6:	85a6                	mv	a1,s1
  8002c8:	0a21                	addi	s4,s4,8
  8002ca:	9902                	jalr	s2
            break;
  8002cc:	b5f1                	j	800198 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002ce:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002d0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002d4:	01174463          	blt	a4,a7,8002dc <vprintfmt+0x17e>
    else if (lflag) {
  8002d8:	18088163          	beqz	a7,80045a <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  8002dc:	000a3603          	ld	a2,0(s4)
  8002e0:	46a9                	li	a3,10
  8002e2:	8a2e                	mv	s4,a1
  8002e4:	bfc1                	j	8002b4 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  8002e6:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8002ea:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002ec:	846a                	mv	s0,s10
            goto reswitch;
  8002ee:	bdf1                	j	8001ca <vprintfmt+0x6c>
            putch(ch, putdat);
  8002f0:	85a6                	mv	a1,s1
  8002f2:	02500513          	li	a0,37
  8002f6:	9902                	jalr	s2
            break;
  8002f8:	b545                	j	800198 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  8002fa:	00144603          	lbu	a2,1(s0)
            lflag ++;
  8002fe:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  800300:	846a                	mv	s0,s10
            goto reswitch;
  800302:	b5e1                	j	8001ca <vprintfmt+0x6c>
    if (lflag >= 2) {
  800304:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800306:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80030a:	01174463          	blt	a4,a7,800312 <vprintfmt+0x1b4>
    else if (lflag) {
  80030e:	14088163          	beqz	a7,800450 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  800312:	000a3603          	ld	a2,0(s4)
  800316:	46a1                	li	a3,8
  800318:	8a2e                	mv	s4,a1
  80031a:	bf69                	j	8002b4 <vprintfmt+0x156>
            putch('0', putdat);
  80031c:	03000513          	li	a0,48
  800320:	85a6                	mv	a1,s1
  800322:	e03e                	sd	a5,0(sp)
  800324:	9902                	jalr	s2
            putch('x', putdat);
  800326:	85a6                	mv	a1,s1
  800328:	07800513          	li	a0,120
  80032c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80032e:	0a21                	addi	s4,s4,8
            goto number;
  800330:	6782                	ld	a5,0(sp)
  800332:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800334:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  800338:	bfb5                	j	8002b4 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  80033a:	000a3403          	ld	s0,0(s4)
  80033e:	008a0713          	addi	a4,s4,8
  800342:	e03a                	sd	a4,0(sp)
  800344:	14040263          	beqz	s0,800488 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  800348:	0fb05763          	blez	s11,800436 <vprintfmt+0x2d8>
  80034c:	02d00693          	li	a3,45
  800350:	0cd79163          	bne	a5,a3,800412 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800354:	00044783          	lbu	a5,0(s0)
  800358:	0007851b          	sext.w	a0,a5
  80035c:	cf85                	beqz	a5,800394 <vprintfmt+0x236>
  80035e:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  800362:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800366:	000c4563          	bltz	s8,800370 <vprintfmt+0x212>
  80036a:	3c7d                	addiw	s8,s8,-1
  80036c:	036c0263          	beq	s8,s6,800390 <vprintfmt+0x232>
                    putch('?', putdat);
  800370:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800372:	0e0c8e63          	beqz	s9,80046e <vprintfmt+0x310>
  800376:	3781                	addiw	a5,a5,-32
  800378:	0ef47b63          	bgeu	s0,a5,80046e <vprintfmt+0x310>
                    putch('?', putdat);
  80037c:	03f00513          	li	a0,63
  800380:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800382:	000a4783          	lbu	a5,0(s4)
  800386:	3dfd                	addiw	s11,s11,-1
  800388:	0a05                	addi	s4,s4,1
  80038a:	0007851b          	sext.w	a0,a5
  80038e:	ffe1                	bnez	a5,800366 <vprintfmt+0x208>
            for (; width > 0; width --) {
  800390:	01b05963          	blez	s11,8003a2 <vprintfmt+0x244>
  800394:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800396:	85a6                	mv	a1,s1
  800398:	02000513          	li	a0,32
  80039c:	9902                	jalr	s2
            for (; width > 0; width --) {
  80039e:	fe0d9be3          	bnez	s11,800394 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003a2:	6a02                	ld	s4,0(sp)
  8003a4:	bbd5                	j	800198 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003a6:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003a8:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  8003ac:	01174463          	blt	a4,a7,8003b4 <vprintfmt+0x256>
    else if (lflag) {
  8003b0:	08088d63          	beqz	a7,80044a <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  8003b4:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003b8:	0a044d63          	bltz	s0,800472 <vprintfmt+0x314>
            num = getint(&ap, lflag);
  8003bc:	8622                	mv	a2,s0
  8003be:	8a66                	mv	s4,s9
  8003c0:	46a9                	li	a3,10
  8003c2:	bdcd                	j	8002b4 <vprintfmt+0x156>
            err = va_arg(ap, int);
  8003c4:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003c8:	4761                	li	a4,24
            err = va_arg(ap, int);
  8003ca:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8003cc:	41f7d69b          	sraiw	a3,a5,0x1f
  8003d0:	8fb5                	xor	a5,a5,a3
  8003d2:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003d6:	02d74163          	blt	a4,a3,8003f8 <vprintfmt+0x29a>
  8003da:	00369793          	slli	a5,a3,0x3
  8003de:	97de                	add	a5,a5,s7
  8003e0:	639c                	ld	a5,0(a5)
  8003e2:	cb99                	beqz	a5,8003f8 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  8003e4:	86be                	mv	a3,a5
  8003e6:	00000617          	auipc	a2,0x0
  8003ea:	46a60613          	addi	a2,a2,1130 # 800850 <main+0xb0>
  8003ee:	85a6                	mv	a1,s1
  8003f0:	854a                	mv	a0,s2
  8003f2:	0ce000ef          	jal	ra,8004c0 <printfmt>
  8003f6:	b34d                	j	800198 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  8003f8:	00000617          	auipc	a2,0x0
  8003fc:	44860613          	addi	a2,a2,1096 # 800840 <main+0xa0>
  800400:	85a6                	mv	a1,s1
  800402:	854a                	mv	a0,s2
  800404:	0bc000ef          	jal	ra,8004c0 <printfmt>
  800408:	bb41                	j	800198 <vprintfmt+0x3a>
                p = "(null)";
  80040a:	00000417          	auipc	s0,0x0
  80040e:	42e40413          	addi	s0,s0,1070 # 800838 <main+0x98>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800412:	85e2                	mv	a1,s8
  800414:	8522                	mv	a0,s0
  800416:	e43e                	sd	a5,8(sp)
  800418:	0c8000ef          	jal	ra,8004e0 <strnlen>
  80041c:	40ad8dbb          	subw	s11,s11,a0
  800420:	01b05b63          	blez	s11,800436 <vprintfmt+0x2d8>
                    putch(padc, putdat);
  800424:	67a2                	ld	a5,8(sp)
  800426:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  80042a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  80042c:	85a6                	mv	a1,s1
  80042e:	8552                	mv	a0,s4
  800430:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800432:	fe0d9ce3          	bnez	s11,80042a <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800436:	00044783          	lbu	a5,0(s0)
  80043a:	00140a13          	addi	s4,s0,1
  80043e:	0007851b          	sext.w	a0,a5
  800442:	d3a5                	beqz	a5,8003a2 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  800444:	05e00413          	li	s0,94
  800448:	bf39                	j	800366 <vprintfmt+0x208>
        return va_arg(*ap, int);
  80044a:	000a2403          	lw	s0,0(s4)
  80044e:	b7ad                	j	8003b8 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  800450:	000a6603          	lwu	a2,0(s4)
  800454:	46a1                	li	a3,8
  800456:	8a2e                	mv	s4,a1
  800458:	bdb1                	j	8002b4 <vprintfmt+0x156>
  80045a:	000a6603          	lwu	a2,0(s4)
  80045e:	46a9                	li	a3,10
  800460:	8a2e                	mv	s4,a1
  800462:	bd89                	j	8002b4 <vprintfmt+0x156>
  800464:	000a6603          	lwu	a2,0(s4)
  800468:	46c1                	li	a3,16
  80046a:	8a2e                	mv	s4,a1
  80046c:	b5a1                	j	8002b4 <vprintfmt+0x156>
                    putch(ch, putdat);
  80046e:	9902                	jalr	s2
  800470:	bf09                	j	800382 <vprintfmt+0x224>
                putch('-', putdat);
  800472:	85a6                	mv	a1,s1
  800474:	02d00513          	li	a0,45
  800478:	e03e                	sd	a5,0(sp)
  80047a:	9902                	jalr	s2
                num = -(long long)num;
  80047c:	6782                	ld	a5,0(sp)
  80047e:	8a66                	mv	s4,s9
  800480:	40800633          	neg	a2,s0
  800484:	46a9                	li	a3,10
  800486:	b53d                	j	8002b4 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  800488:	03b05163          	blez	s11,8004aa <vprintfmt+0x34c>
  80048c:	02d00693          	li	a3,45
  800490:	f6d79de3          	bne	a5,a3,80040a <vprintfmt+0x2ac>
                p = "(null)";
  800494:	00000417          	auipc	s0,0x0
  800498:	3a440413          	addi	s0,s0,932 # 800838 <main+0x98>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80049c:	02800793          	li	a5,40
  8004a0:	02800513          	li	a0,40
  8004a4:	00140a13          	addi	s4,s0,1
  8004a8:	bd6d                	j	800362 <vprintfmt+0x204>
  8004aa:	00000a17          	auipc	s4,0x0
  8004ae:	38fa0a13          	addi	s4,s4,911 # 800839 <main+0x99>
  8004b2:	02800513          	li	a0,40
  8004b6:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  8004ba:	05e00413          	li	s0,94
  8004be:	b565                	j	800366 <vprintfmt+0x208>

00000000008004c0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004c0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004c2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004c6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004c8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ca:	ec06                	sd	ra,24(sp)
  8004cc:	f83a                	sd	a4,48(sp)
  8004ce:	fc3e                	sd	a5,56(sp)
  8004d0:	e0c2                	sd	a6,64(sp)
  8004d2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004d4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004d6:	c89ff0ef          	jal	ra,80015e <vprintfmt>
}
  8004da:	60e2                	ld	ra,24(sp)
  8004dc:	6161                	addi	sp,sp,80
  8004de:	8082                	ret

00000000008004e0 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8004e0:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8004e2:	e589                	bnez	a1,8004ec <strnlen+0xc>
  8004e4:	a811                	j	8004f8 <strnlen+0x18>
        cnt ++;
  8004e6:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8004e8:	00f58863          	beq	a1,a5,8004f8 <strnlen+0x18>
  8004ec:	00f50733          	add	a4,a0,a5
  8004f0:	00074703          	lbu	a4,0(a4)
  8004f4:	fb6d                	bnez	a4,8004e6 <strnlen+0x6>
  8004f6:	85be                	mv	a1,a5
    }
    return cnt;
}
  8004f8:	852e                	mv	a0,a1
  8004fa:	8082                	ret

00000000008004fc <test_basic_cow>:
static int global_var = 100;

// Array to test COW on larger memory regions
static int global_array[1024];

void test_basic_cow(void) {
  8004fc:	1101                	addi	sp,sp,-32
    cprintf("=== Test 1: Basic COW Test ===\n");
  8004fe:	00000517          	auipc	a0,0x0
  800502:	63a50513          	addi	a0,a0,1594 # 800b38 <error_string+0xc8>
void test_basic_cow(void) {
  800506:	ec06                	sd	ra,24(sp)
  800508:	e822                	sd	s0,16(sp)
  80050a:	e426                	sd	s1,8(sp)
    cprintf("=== Test 1: Basic COW Test ===\n");
  80050c:	b35ff0ef          	jal	ra,800040 <cprintf>
    
    int local_var = 200;
    global_var = 100;
    
    cprintf("Parent: Before fork, global_var=%d, local_var=%d\n", 
  800510:	0c800613          	li	a2,200
  800514:	06400593          	li	a1,100
    global_var = 100;
  800518:	00002417          	auipc	s0,0x2
  80051c:	ae840413          	addi	s0,s0,-1304 # 802000 <global_var>
  800520:	06400493          	li	s1,100
    cprintf("Parent: Before fork, global_var=%d, local_var=%d\n", 
  800524:	00000517          	auipc	a0,0x0
  800528:	63450513          	addi	a0,a0,1588 # 800b58 <error_string+0xe8>
    global_var = 100;
  80052c:	c004                	sw	s1,0(s0)
    cprintf("Parent: Before fork, global_var=%d, local_var=%d\n", 
  80052e:	b13ff0ef          	jal	ra,800040 <cprintf>
            global_var, local_var);
    
    int pid = fork();
  800532:	badff0ef          	jal	ra,8000de <fork>
    
    if (pid == 0) {
  800536:	cd05                	beqz	a0,80056e <test_basic_cow+0x72>
        
        exit(0);
    } else {
        // Parent process
        // Wait for child to finish
        wait();
  800538:	ba9ff0ef          	jal	ra,8000e0 <wait>
        
        cprintf("Parent: After child exit, global_var=%d, local_var=%d\n", 
  80053c:	400c                	lw	a1,0(s0)
  80053e:	0c800613          	li	a2,200
  800542:	00000517          	auipc	a0,0x0
  800546:	6b650513          	addi	a0,a0,1718 # 800bf8 <error_string+0x188>
  80054a:	af7ff0ef          	jal	ra,800040 <cprintf>
                global_var, local_var);
        
        // Verify parent's values are unchanged
        if (global_var == 100 && local_var == 200) {
  80054e:	401c                	lw	a5,0(s0)
            cprintf("Test 1 PASSED: COW correctly isolated parent and child\n\n");
  800550:	00000517          	auipc	a0,0x0
  800554:	6e050513          	addi	a0,a0,1760 # 800c30 <error_string+0x1c0>
        if (global_var == 100 && local_var == 200) {
  800558:	00978663          	beq	a5,s1,800564 <test_basic_cow+0x68>
        } else {
            cprintf("Test 1 FAILED: Parent values were modified!\n\n");
  80055c:	00000517          	auipc	a0,0x0
  800560:	71450513          	addi	a0,a0,1812 # 800c70 <error_string+0x200>
        }
    }
}
  800564:	6442                	ld	s0,16(sp)
  800566:	60e2                	ld	ra,24(sp)
  800568:	64a2                	ld	s1,8(sp)
  80056a:	6105                	addi	sp,sp,32
            cprintf("Test 1 FAILED: Parent values were modified!\n\n");
  80056c:	bcd1                	j	800040 <cprintf>
        cprintf("Child: After fork, global_var=%d, local_var=%d\n", 
  80056e:	400c                	lw	a1,0(s0)
  800570:	0c800613          	li	a2,200
  800574:	00000517          	auipc	a0,0x0
  800578:	61c50513          	addi	a0,a0,1564 # 800b90 <error_string+0x120>
  80057c:	ac5ff0ef          	jal	ra,800040 <cprintf>
        global_var = 999;
  800580:	3e700793          	li	a5,999
        cprintf("Child: After modification, global_var=%d, local_var=%d\n", 
  800584:	37800613          	li	a2,888
  800588:	3e700593          	li	a1,999
  80058c:	00000517          	auipc	a0,0x0
  800590:	63450513          	addi	a0,a0,1588 # 800bc0 <error_string+0x150>
        global_var = 999;
  800594:	c01c                	sw	a5,0(s0)
        cprintf("Child: After modification, global_var=%d, local_var=%d\n", 
  800596:	aabff0ef          	jal	ra,800040 <cprintf>
        exit(0);
  80059a:	4501                	li	a0,0
  80059c:	b2dff0ef          	jal	ra,8000c8 <exit>

00000000008005a0 <test_array_cow>:

void test_array_cow(void) {
  8005a0:	1101                	addi	sp,sp,-32
    cprintf("=== Test 2: Array COW Test ===\n");
  8005a2:	00000517          	auipc	a0,0x0
  8005a6:	6fe50513          	addi	a0,a0,1790 # 800ca0 <error_string+0x230>
void test_array_cow(void) {
  8005aa:	e822                	sd	s0,16(sp)
  8005ac:	e426                	sd	s1,8(sp)
  8005ae:	00002417          	auipc	s0,0x2
  8005b2:	a5a40413          	addi	s0,s0,-1446 # 802008 <global_array>
  8005b6:	ec06                	sd	ra,24(sp)
    cprintf("=== Test 2: Array COW Test ===\n");
  8005b8:	a89ff0ef          	jal	ra,800040 <cprintf>
  8005bc:	84a2                	mv	s1,s0
  8005be:	8722                	mv	a4,s0
    
    // Initialize array
    for (int i = 0; i < 1024; i++) {
  8005c0:	4781                	li	a5,0
  8005c2:	40000693          	li	a3,1024
        global_array[i] = i;
  8005c6:	c31c                	sw	a5,0(a4)
    for (int i = 0; i < 1024; i++) {
  8005c8:	2785                	addiw	a5,a5,1
  8005ca:	0711                	addi	a4,a4,4
  8005cc:	fed79de3          	bne	a5,a3,8005c6 <test_array_cow+0x26>
    }
    
    int pid = fork();
  8005d0:	b0fff0ef          	jal	ra,8000de <fork>
    
    if (pid == 0) {
  8005d4:	c939                	beqz	a0,80062a <test_array_cow+0x8a>
        cprintf("Child: Modified array, global_array[0]=%d, global_array[1023]=%d\n",
                global_array[0], global_array[1023]);
        
        exit(0);
    } else {
        wait();
  8005d6:	b0bff0ef          	jal	ra,8000e0 <wait>
        
        cprintf("Parent: After child exit, global_array[0]=%d, global_array[1023]=%d\n",
  8005da:	408c                	lw	a1,0(s1)
  8005dc:	00003617          	auipc	a2,0x3
  8005e0:	a2862603          	lw	a2,-1496(a2) # 803004 <global_array+0xffc>
  8005e4:	00000517          	auipc	a0,0x0
  8005e8:	72450513          	addi	a0,a0,1828 # 800d08 <error_string+0x298>
  8005ec:	a55ff0ef          	jal	ra,800040 <cprintf>
                global_array[0], global_array[1023]);
        
        // Verify parent's array is unchanged
        int passed = 1;
        for (int i = 0; i < 1024; i++) {
  8005f0:	4781                	li	a5,0
  8005f2:	40000693          	li	a3,1024
  8005f6:	a029                	j	800600 <test_array_cow+0x60>
  8005f8:	2785                	addiw	a5,a5,1
  8005fa:	0411                	addi	s0,s0,4
  8005fc:	00d78e63          	beq	a5,a3,800618 <test_array_cow+0x78>
            if (global_array[i] != i) {
  800600:	4018                	lw	a4,0(s0)
  800602:	fef70be3          	beq	a4,a5,8005f8 <test_array_cow+0x58>
            cprintf("Test 2 PASSED: Array COW works correctly\n\n");
        } else {
            cprintf("Test 2 FAILED: Parent array was modified!\n\n");
        }
    }
}
  800606:	6442                	ld	s0,16(sp)
  800608:	60e2                	ld	ra,24(sp)
  80060a:	64a2                	ld	s1,8(sp)
            cprintf("Test 2 FAILED: Parent array was modified!\n\n");
  80060c:	00000517          	auipc	a0,0x0
  800610:	77450513          	addi	a0,a0,1908 # 800d80 <error_string+0x310>
}
  800614:	6105                	addi	sp,sp,32
            cprintf("Test 2 FAILED: Parent array was modified!\n\n");
  800616:	b42d                	j	800040 <cprintf>
}
  800618:	6442                	ld	s0,16(sp)
  80061a:	60e2                	ld	ra,24(sp)
  80061c:	64a2                	ld	s1,8(sp)
            cprintf("Test 2 PASSED: Array COW works correctly\n\n");
  80061e:	00000517          	auipc	a0,0x0
  800622:	73250513          	addi	a0,a0,1842 # 800d50 <error_string+0x2e0>
}
  800626:	6105                	addi	sp,sp,32
            cprintf("Test 2 FAILED: Parent array was modified!\n\n");
  800628:	bc21                	j	800040 <cprintf>
  80062a:	40000793          	li	a5,1024
            global_array[i] = 1024 - i;
  80062e:	c01c                	sw	a5,0(s0)
        for (int i = 0; i < 1024; i++) {
  800630:	37fd                	addiw	a5,a5,-1
  800632:	0411                	addi	s0,s0,4
  800634:	ffed                	bnez	a5,80062e <test_array_cow+0x8e>
        cprintf("Child: Modified array, global_array[0]=%d, global_array[1023]=%d\n",
  800636:	408c                	lw	a1,0(s1)
  800638:	00003617          	auipc	a2,0x3
  80063c:	9cc62603          	lw	a2,-1588(a2) # 803004 <global_array+0xffc>
  800640:	00000517          	auipc	a0,0x0
  800644:	68050513          	addi	a0,a0,1664 # 800cc0 <error_string+0x250>
  800648:	9f9ff0ef          	jal	ra,800040 <cprintf>
        exit(0);
  80064c:	4501                	li	a0,0
  80064e:	a7bff0ef          	jal	ra,8000c8 <exit>

0000000000800652 <test_multi_fork_cow>:

void test_multi_fork_cow(void) {
  800652:	1141                	addi	sp,sp,-16
    cprintf("=== Test 3: Multiple Fork COW Test ===\n");
  800654:	00000517          	auipc	a0,0x0
  800658:	75c50513          	addi	a0,a0,1884 # 800db0 <error_string+0x340>
void test_multi_fork_cow(void) {
  80065c:	e406                	sd	ra,8(sp)
  80065e:	e022                	sd	s0,0(sp)
    cprintf("=== Test 3: Multiple Fork COW Test ===\n");
  800660:	9e1ff0ef          	jal	ra,800040 <cprintf>
    
    int shared_counter = 0;
    
    for (int i = 0; i < 3; i++) {
        int pid = fork();
  800664:	a7bff0ef          	jal	ra,8000de <fork>
  800668:	842a                	mv	s0,a0
        
        if (pid == 0) {
  80066a:	cd15                	beqz	a0,8006a6 <test_multi_fork_cow+0x54>
        int pid = fork();
  80066c:	a73ff0ef          	jal	ra,8000de <fork>
        if (pid == 0) {
  800670:	c915                	beqz	a0,8006a4 <test_multi_fork_cow+0x52>
        int pid = fork();
  800672:	a6dff0ef          	jal	ra,8000de <fork>
    for (int i = 0; i < 3; i++) {
  800676:	4409                	li	s0,2
        if (pid == 0) {
  800678:	c51d                	beqz	a0,8006a6 <test_multi_fork_cow+0x54>
        }
    }
    
    // Parent waits for all children
    for (int i = 0; i < 3; i++) {
        wait();
  80067a:	a67ff0ef          	jal	ra,8000e0 <wait>
  80067e:	a63ff0ef          	jal	ra,8000e0 <wait>
  800682:	a5fff0ef          	jal	ra,8000e0 <wait>
    }
    
    cprintf("Parent: After all children exit, shared_counter=%d\n", shared_counter);
  800686:	4581                	li	a1,0
  800688:	00000517          	auipc	a0,0x0
  80068c:	77050513          	addi	a0,a0,1904 # 800df8 <error_string+0x388>
  800690:	9b1ff0ef          	jal	ra,800040 <cprintf>
    if (shared_counter == 0) {
        cprintf("Test 3 PASSED: Multiple fork COW isolation works\n\n");
    } else {
        cprintf("Test 3 FAILED: Parent counter was modified!\n\n");
    }
}
  800694:	6402                	ld	s0,0(sp)
  800696:	60a2                	ld	ra,8(sp)
        cprintf("Test 3 PASSED: Multiple fork COW isolation works\n\n");
  800698:	00000517          	auipc	a0,0x0
  80069c:	79850513          	addi	a0,a0,1944 # 800e30 <error_string+0x3c0>
}
  8006a0:	0141                	addi	sp,sp,16
        cprintf("Test 3 PASSED: Multiple fork COW isolation works\n\n");
  8006a2:	ba79                	j	800040 <cprintf>
    for (int i = 0; i < 3; i++) {
  8006a4:	4405                	li	s0,1
            cprintf("Child %d: shared_counter=%d\n", i, shared_counter);
  8006a6:	06400613          	li	a2,100
  8006aa:	85a2                	mv	a1,s0
  8006ac:	00000517          	auipc	a0,0x0
  8006b0:	72c50513          	addi	a0,a0,1836 # 800dd8 <error_string+0x368>
  8006b4:	98dff0ef          	jal	ra,800040 <cprintf>
            exit(i);
  8006b8:	8522                	mv	a0,s0
  8006ba:	a0fff0ef          	jal	ra,8000c8 <exit>

00000000008006be <test_nested_fork_cow>:

void test_nested_fork_cow(void) {
  8006be:	1141                	addi	sp,sp,-16
    cprintf("=== Test 4: Nested Fork COW Test ===\n");
  8006c0:	00000517          	auipc	a0,0x0
  8006c4:	7a850513          	addi	a0,a0,1960 # 800e68 <error_string+0x3f8>
void test_nested_fork_cow(void) {
  8006c8:	e406                	sd	ra,8(sp)
    cprintf("=== Test 4: Nested Fork COW Test ===\n");
  8006ca:	977ff0ef          	jal	ra,800040 <cprintf>
    
    int value = 1;
    
    int pid1 = fork();
  8006ce:	a11ff0ef          	jal	ra,8000de <fork>
    
    if (pid1 == 0) {
  8006d2:	e515                	bnez	a0,8006fe <test_nested_fork_cow+0x40>
        // First child
        value = 10;
        cprintf("Child1: value=%d\n", value);
  8006d4:	45a9                	li	a1,10
  8006d6:	00000517          	auipc	a0,0x0
  8006da:	7ba50513          	addi	a0,a0,1978 # 800e90 <error_string+0x420>
  8006de:	963ff0ef          	jal	ra,800040 <cprintf>
        
        int pid2 = fork();
  8006e2:	9fdff0ef          	jal	ra,8000de <fork>
        
        if (pid2 == 0) {
  8006e6:	ed05                	bnez	a0,80071e <test_nested_fork_cow+0x60>
            // Grandchild
            value = 100;
            cprintf("Grandchild: value=%d\n", value);
  8006e8:	06400593          	li	a1,100
  8006ec:	00000517          	auipc	a0,0x0
  8006f0:	7bc50513          	addi	a0,a0,1980 # 800ea8 <error_string+0x438>
  8006f4:	94dff0ef          	jal	ra,800040 <cprintf>
            exit(0);
  8006f8:	4501                	li	a0,0
  8006fa:	9cfff0ef          	jal	ra,8000c8 <exit>
                cprintf("Nested fork COW for Child1: OK\n");
            }
            exit(0);
        }
    } else {
        wait();
  8006fe:	9e3ff0ef          	jal	ra,8000e0 <wait>
        cprintf("Parent after Child1: value=%d\n", value);
  800702:	4585                	li	a1,1
  800704:	00001517          	auipc	a0,0x1
  800708:	80450513          	addi	a0,a0,-2044 # 800f08 <error_string+0x498>
  80070c:	935ff0ef          	jal	ra,800040 <cprintf>
            cprintf("Test 4 PASSED: Nested fork COW works correctly\n\n");
        } else {
            cprintf("Test 4 FAILED: Parent value was modified!\n\n");
        }
    }
}
  800710:	60a2                	ld	ra,8(sp)
            cprintf("Test 4 PASSED: Nested fork COW works correctly\n\n");
  800712:	00001517          	auipc	a0,0x1
  800716:	81650513          	addi	a0,a0,-2026 # 800f28 <error_string+0x4b8>
}
  80071a:	0141                	addi	sp,sp,16
            cprintf("Test 4 PASSED: Nested fork COW works correctly\n\n");
  80071c:	b215                	j	800040 <cprintf>
            wait();
  80071e:	9c3ff0ef          	jal	ra,8000e0 <wait>
            cprintf("Child1 after grandchild: value=%d\n", value);
  800722:	45a9                	li	a1,10
  800724:	00000517          	auipc	a0,0x0
  800728:	79c50513          	addi	a0,a0,1948 # 800ec0 <error_string+0x450>
  80072c:	915ff0ef          	jal	ra,800040 <cprintf>
                cprintf("Nested fork COW for Child1: OK\n");
  800730:	00000517          	auipc	a0,0x0
  800734:	7b850513          	addi	a0,a0,1976 # 800ee8 <error_string+0x478>
  800738:	909ff0ef          	jal	ra,800040 <cprintf>
            exit(0);
  80073c:	4501                	li	a0,0
  80073e:	98bff0ef          	jal	ra,8000c8 <exit>

0000000000800742 <test_read_no_cow>:

void test_read_no_cow(void) {
  800742:	1141                	addi	sp,sp,-16
    cprintf("=== Test 5: Read Access No COW Test ===\n");
  800744:	00001517          	auipc	a0,0x1
  800748:	81c50513          	addi	a0,a0,-2020 # 800f60 <error_string+0x4f0>
void test_read_no_cow(void) {
  80074c:	e022                	sd	s0,0(sp)
  80074e:	e406                	sd	ra,8(sp)
    cprintf("=== Test 5: Read Access No COW Test ===\n");
  800750:	8f1ff0ef          	jal	ra,800040 <cprintf>
    
    global_var = 12345;
  800754:	678d                	lui	a5,0x3
  800756:	00002417          	auipc	s0,0x2
  80075a:	8aa40413          	addi	s0,s0,-1878 # 802000 <global_var>
  80075e:	03978793          	addi	a5,a5,57 # 3039 <_start-0x7fcfe7>
  800762:	c01c                	sw	a5,0(s0)
    
    int pid = fork();
  800764:	97bff0ef          	jal	ra,8000de <fork>
    
    if (pid == 0) {
  800768:	cd01                	beqz	a0,800780 <test_read_no_cow+0x3e>
        }
        
        cprintf("Child: Completed 100 reads without triggering COW\n");
        exit(0);
    } else {
        wait();
  80076a:	977ff0ef          	jal	ra,8000e0 <wait>
        cprintf("Test 5 PASSED: Read-only access doesn't trigger unnecessary COW\n\n");
    }
}
  80076e:	6402                	ld	s0,0(sp)
  800770:	60a2                	ld	ra,8(sp)
        cprintf("Test 5 PASSED: Read-only access doesn't trigger unnecessary COW\n\n");
  800772:	00001517          	auipc	a0,0x1
  800776:	88e50513          	addi	a0,a0,-1906 # 801000 <error_string+0x590>
}
  80077a:	0141                	addi	sp,sp,16
        cprintf("Test 5 PASSED: Read-only access doesn't trigger unnecessary COW\n\n");
  80077c:	8c5ff06f          	j	800040 <cprintf>
        cprintf("Child: Read global_var=%d (should not trigger COW)\n", read_value);
  800780:	400c                	lw	a1,0(s0)
  800782:	00001517          	auipc	a0,0x1
  800786:	80e50513          	addi	a0,a0,-2034 # 800f90 <error_string+0x520>
  80078a:	8b7ff0ef          	jal	ra,800040 <cprintf>
        cprintf("Child: Completed 100 reads without triggering COW\n");
  80078e:	00001517          	auipc	a0,0x1
  800792:	83a50513          	addi	a0,a0,-1990 # 800fc8 <error_string+0x558>
  800796:	8abff0ef          	jal	ra,800040 <cprintf>
        exit(0);
  80079a:	4501                	li	a0,0
  80079c:	92dff0ef          	jal	ra,8000c8 <exit>

00000000008007a0 <main>:

int main(void) {
  8007a0:	1141                	addi	sp,sp,-16
    cprintf("\n========================================\n");
  8007a2:	00001517          	auipc	a0,0x1
  8007a6:	8a650513          	addi	a0,a0,-1882 # 801048 <error_string+0x5d8>
int main(void) {
  8007aa:	e406                	sd	ra,8(sp)
    cprintf("\n========================================\n");
  8007ac:	895ff0ef          	jal	ra,800040 <cprintf>
    cprintf("    COW (Copy-On-Write) Test Suite\n");
  8007b0:	00001517          	auipc	a0,0x1
  8007b4:	8c850513          	addi	a0,a0,-1848 # 801078 <error_string+0x608>
  8007b8:	889ff0ef          	jal	ra,800040 <cprintf>
    cprintf("========================================\n\n");
  8007bc:	00001517          	auipc	a0,0x1
  8007c0:	8e450513          	addi	a0,a0,-1820 # 8010a0 <error_string+0x630>
  8007c4:	87dff0ef          	jal	ra,800040 <cprintf>
    
    test_basic_cow();
  8007c8:	d35ff0ef          	jal	ra,8004fc <test_basic_cow>
    test_array_cow();
  8007cc:	dd5ff0ef          	jal	ra,8005a0 <test_array_cow>
    test_multi_fork_cow();
  8007d0:	e83ff0ef          	jal	ra,800652 <test_multi_fork_cow>
    test_nested_fork_cow();
  8007d4:	eebff0ef          	jal	ra,8006be <test_nested_fork_cow>
    test_read_no_cow();
  8007d8:	f6bff0ef          	jal	ra,800742 <test_read_no_cow>
    
    cprintf("========================================\n");
  8007dc:	00001517          	auipc	a0,0x1
  8007e0:	8f450513          	addi	a0,a0,-1804 # 8010d0 <error_string+0x660>
  8007e4:	85dff0ef          	jal	ra,800040 <cprintf>
    cprintf("    All COW Tests Completed!\n");
  8007e8:	00001517          	auipc	a0,0x1
  8007ec:	91850513          	addi	a0,a0,-1768 # 801100 <error_string+0x690>
  8007f0:	851ff0ef          	jal	ra,800040 <cprintf>
    cprintf("========================================\n");
  8007f4:	00001517          	auipc	a0,0x1
  8007f8:	8dc50513          	addi	a0,a0,-1828 # 8010d0 <error_string+0x660>
  8007fc:	845ff0ef          	jal	ra,800040 <cprintf>
    
    return 0;
}
  800800:	60a2                	ld	ra,8(sp)
  800802:	4501                	li	a0,0
  800804:	0141                	addi	sp,sp,16
  800806:	8082                	ret
