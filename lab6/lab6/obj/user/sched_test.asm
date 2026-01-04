
obj/__user_sched_test.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  800020:	144000ef          	jal	ra,800164 <umain>
1:  j 1b
  800024:	a001                	j	800024 <_start+0x4>

0000000000800026 <__panic>:
#include <stdio.h>
#include <ulib.h>
#include <error.h>

void
__panic(const char *file, int line, const char *fmt, ...) {
  800026:	715d                	addi	sp,sp,-80
  800028:	8e2e                	mv	t3,a1
  80002a:	e822                	sd	s0,16(sp)
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("user panic at %s:%d:\n    ", file, line);
  80002c:	85aa                	mv	a1,a0
__panic(const char *file, int line, const char *fmt, ...) {
  80002e:	8432                	mv	s0,a2
  800030:	fc3e                	sd	a5,56(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800032:	8672                	mv	a2,t3
    va_start(ap, fmt);
  800034:	103c                	addi	a5,sp,40
    cprintf("user panic at %s:%d:\n    ", file, line);
  800036:	00000517          	auipc	a0,0x0
  80003a:	75a50513          	addi	a0,a0,1882 # 800790 <main+0x216>
__panic(const char *file, int line, const char *fmt, ...) {
  80003e:	ec06                	sd	ra,24(sp)
  800040:	f436                	sd	a3,40(sp)
  800042:	f83a                	sd	a4,48(sp)
  800044:	e0c2                	sd	a6,64(sp)
  800046:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800048:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  80004a:	058000ef          	jal	ra,8000a2 <cprintf>
    vcprintf(fmt, ap);
  80004e:	65a2                	ld	a1,8(sp)
  800050:	8522                	mv	a0,s0
  800052:	030000ef          	jal	ra,800082 <vcprintf>
    cprintf("\n");
  800056:	00001517          	auipc	a0,0x1
  80005a:	d3250513          	addi	a0,a0,-718 # 800d88 <error_string+0x370>
  80005e:	044000ef          	jal	ra,8000a2 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800062:	5559                	li	a0,-10
  800064:	0da000ef          	jal	ra,80013e <exit>

0000000000800068 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800068:	1141                	addi	sp,sp,-16
  80006a:	e022                	sd	s0,0(sp)
  80006c:	e406                	sd	ra,8(sp)
  80006e:	842e                	mv	s0,a1
    sys_putc(c);
  800070:	0bc000ef          	jal	ra,80012c <sys_putc>
    (*cnt) ++;
  800074:	401c                	lw	a5,0(s0)
}
  800076:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  800078:	2785                	addiw	a5,a5,1
  80007a:	c01c                	sw	a5,0(s0)
}
  80007c:	6402                	ld	s0,0(sp)
  80007e:	0141                	addi	sp,sp,16
  800080:	8082                	ret

0000000000800082 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  800082:	1101                	addi	sp,sp,-32
  800084:	862a                	mv	a2,a0
  800086:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800088:	00000517          	auipc	a0,0x0
  80008c:	fe050513          	addi	a0,a0,-32 # 800068 <cputch>
  800090:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  800092:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  800094:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800096:	146000ef          	jal	ra,8001dc <vprintfmt>
    return cnt;
}
  80009a:	60e2                	ld	ra,24(sp)
  80009c:	4532                	lw	a0,12(sp)
  80009e:	6105                	addi	sp,sp,32
  8000a0:	8082                	ret

00000000008000a2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000a2:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000a4:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000a8:	8e2a                	mv	t3,a0
  8000aa:	f42e                	sd	a1,40(sp)
  8000ac:	f832                	sd	a2,48(sp)
  8000ae:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000b0:	00000517          	auipc	a0,0x0
  8000b4:	fb850513          	addi	a0,a0,-72 # 800068 <cputch>
  8000b8:	004c                	addi	a1,sp,4
  8000ba:	869a                	mv	a3,t1
  8000bc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
  8000be:	ec06                	sd	ra,24(sp)
  8000c0:	e0ba                	sd	a4,64(sp)
  8000c2:	e4be                	sd	a5,72(sp)
  8000c4:	e8c2                	sd	a6,80(sp)
  8000c6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  8000c8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  8000ca:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000cc:	110000ef          	jal	ra,8001dc <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000d0:	60e2                	ld	ra,24(sp)
  8000d2:	4512                	lw	a0,4(sp)
  8000d4:	6125                	addi	sp,sp,96
  8000d6:	8082                	ret

00000000008000d8 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
  8000d8:	7175                	addi	sp,sp,-144
  8000da:	f8ba                	sd	a4,112(sp)
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
  8000dc:	e0ba                	sd	a4,64(sp)
  8000de:	0118                	addi	a4,sp,128
syscall(int64_t num, ...) {
  8000e0:	e42a                	sd	a0,8(sp)
  8000e2:	ecae                	sd	a1,88(sp)
  8000e4:	f0b2                	sd	a2,96(sp)
  8000e6:	f4b6                	sd	a3,104(sp)
  8000e8:	fcbe                	sd	a5,120(sp)
  8000ea:	e142                	sd	a6,128(sp)
  8000ec:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);
  8000ee:	f42e                	sd	a1,40(sp)
  8000f0:	f832                	sd	a2,48(sp)
  8000f2:	fc36                	sd	a3,56(sp)
  8000f4:	f03a                	sd	a4,32(sp)
  8000f6:	e4be                	sd	a5,72(sp)
    }
    va_end(ap);
    asm volatile (
  8000f8:	4522                	lw	a0,8(sp)
  8000fa:	55a2                	lw	a1,40(sp)
  8000fc:	5642                	lw	a2,48(sp)
  8000fe:	56e2                	lw	a3,56(sp)
  800100:	4706                	lw	a4,64(sp)
  800102:	47a6                	lw	a5,72(sp)
  800104:	00000073          	ecall
  800108:	ce2a                	sw	a0,28(sp)
          "m" (a[3]),
          "m" (a[4])
        : "memory"
      );
    return ret;
}
  80010a:	4572                	lw	a0,28(sp)
  80010c:	6149                	addi	sp,sp,144
  80010e:	8082                	ret

0000000000800110 <sys_exit>:

int
sys_exit(int64_t error_code) {
  800110:	85aa                	mv	a1,a0
    return syscall(SYS_exit, error_code);
  800112:	4505                	li	a0,1
  800114:	b7d1                	j	8000d8 <syscall>

0000000000800116 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  800116:	4509                	li	a0,2
  800118:	b7c1                	j	8000d8 <syscall>

000000000080011a <sys_wait>:
}

int
sys_wait(int64_t pid, int *store) {
  80011a:	862e                	mv	a2,a1
    return syscall(SYS_wait, pid, store);
  80011c:	85aa                	mv	a1,a0
  80011e:	450d                	li	a0,3
  800120:	bf65                	j	8000d8 <syscall>

0000000000800122 <sys_kill>:
sys_yield(void) {
    return syscall(SYS_yield);
}

int
sys_kill(int64_t pid) {
  800122:	85aa                	mv	a1,a0
    return syscall(SYS_kill, pid);
  800124:	4531                	li	a0,12
  800126:	bf4d                	j	8000d8 <syscall>

0000000000800128 <sys_getpid>:
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  800128:	4549                	li	a0,18
  80012a:	b77d                	j	8000d8 <syscall>

000000000080012c <sys_putc>:
}

int
sys_putc(int64_t c) {
  80012c:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  80012e:	4579                	li	a0,30
  800130:	b765                	j	8000d8 <syscall>

0000000000800132 <sys_gettime>:
    return syscall(SYS_pgdir);
}

int
sys_gettime(void) {
    return syscall(SYS_gettime);
  800132:	4545                	li	a0,17
  800134:	b755                	j	8000d8 <syscall>

0000000000800136 <sys_lab6_set_priority>:
}

void
sys_lab6_set_priority(uint64_t priority)
{
  800136:	85aa                	mv	a1,a0
    syscall(SYS_lab6_set_priority, priority);
  800138:	0ff00513          	li	a0,255
  80013c:	bf71                	j	8000d8 <syscall>

000000000080013e <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80013e:	1141                	addi	sp,sp,-16
  800140:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800142:	fcfff0ef          	jal	ra,800110 <sys_exit>
    cprintf("BUG: exit failed.\n");
  800146:	00000517          	auipc	a0,0x0
  80014a:	66a50513          	addi	a0,a0,1642 # 8007b0 <main+0x236>
  80014e:	f55ff0ef          	jal	ra,8000a2 <cprintf>
    while (1);
  800152:	a001                	j	800152 <exit+0x14>

0000000000800154 <fork>:
}

int
fork(void) {
    return sys_fork();
  800154:	b7c9                	j	800116 <sys_fork>

0000000000800156 <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  800156:	b7d1                	j	80011a <sys_wait>

0000000000800158 <kill>:
    sys_yield();
}

int
kill(int pid) {
    return sys_kill(pid);
  800158:	b7e9                	j	800122 <sys_kill>

000000000080015a <getpid>:
}

int
getpid(void) {
    return sys_getpid();
  80015a:	b7f9                	j	800128 <sys_getpid>

000000000080015c <gettime_msec>:
    sys_pgdir();
}

unsigned int
gettime_msec(void) {
    return (unsigned int)sys_gettime();
  80015c:	bfd9                	j	800132 <sys_gettime>

000000000080015e <lab6_setpriority>:
}

void
lab6_setpriority(uint32_t priority)
{
    sys_lab6_set_priority(priority);
  80015e:	1502                	slli	a0,a0,0x20
  800160:	9101                	srli	a0,a0,0x20
  800162:	bfd1                	j	800136 <sys_lab6_set_priority>

0000000000800164 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800164:	1141                	addi	sp,sp,-16
  800166:	e406                	sd	ra,8(sp)
    int ret = main();
  800168:	412000ef          	jal	ra,80057a <main>
    exit(ret);
  80016c:	fd3ff0ef          	jal	ra,80013e <exit>

0000000000800170 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800170:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800174:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800176:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80017a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80017c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800180:	f022                	sd	s0,32(sp)
  800182:	ec26                	sd	s1,24(sp)
  800184:	e84a                	sd	s2,16(sp)
  800186:	f406                	sd	ra,40(sp)
  800188:	e44e                	sd	s3,8(sp)
  80018a:	84aa                	mv	s1,a0
  80018c:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80018e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800192:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800194:	03067e63          	bgeu	a2,a6,8001d0 <printnum+0x60>
  800198:	89be                	mv	s3,a5
        while (-- width > 0)
  80019a:	00805763          	blez	s0,8001a8 <printnum+0x38>
  80019e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001a0:	85ca                	mv	a1,s2
  8001a2:	854e                	mv	a0,s3
  8001a4:	9482                	jalr	s1
        while (-- width > 0)
  8001a6:	fc65                	bnez	s0,80019e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001a8:	1a02                	slli	s4,s4,0x20
  8001aa:	00000797          	auipc	a5,0x0
  8001ae:	61e78793          	addi	a5,a5,1566 # 8007c8 <main+0x24e>
  8001b2:	020a5a13          	srli	s4,s4,0x20
  8001b6:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001b8:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ba:	000a4503          	lbu	a0,0(s4)
}
  8001be:	70a2                	ld	ra,40(sp)
  8001c0:	69a2                	ld	s3,8(sp)
  8001c2:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001c4:	85ca                	mv	a1,s2
  8001c6:	87a6                	mv	a5,s1
}
  8001c8:	6942                	ld	s2,16(sp)
  8001ca:	64e2                	ld	s1,24(sp)
  8001cc:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001ce:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001d0:	03065633          	divu	a2,a2,a6
  8001d4:	8722                	mv	a4,s0
  8001d6:	f9bff0ef          	jal	ra,800170 <printnum>
  8001da:	b7f9                	j	8001a8 <printnum+0x38>

00000000008001dc <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001dc:	7119                	addi	sp,sp,-128
  8001de:	f4a6                	sd	s1,104(sp)
  8001e0:	f0ca                	sd	s2,96(sp)
  8001e2:	ecce                	sd	s3,88(sp)
  8001e4:	e8d2                	sd	s4,80(sp)
  8001e6:	e4d6                	sd	s5,72(sp)
  8001e8:	e0da                	sd	s6,64(sp)
  8001ea:	fc5e                	sd	s7,56(sp)
  8001ec:	f06a                	sd	s10,32(sp)
  8001ee:	fc86                	sd	ra,120(sp)
  8001f0:	f8a2                	sd	s0,112(sp)
  8001f2:	f862                	sd	s8,48(sp)
  8001f4:	f466                	sd	s9,40(sp)
  8001f6:	ec6e                	sd	s11,24(sp)
  8001f8:	892a                	mv	s2,a0
  8001fa:	84ae                	mv	s1,a1
  8001fc:	8d32                	mv	s10,a2
  8001fe:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800200:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800204:	5b7d                	li	s6,-1
  800206:	00000a97          	auipc	s5,0x0
  80020a:	5f6a8a93          	addi	s5,s5,1526 # 8007fc <main+0x282>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80020e:	00001b97          	auipc	s7,0x1
  800212:	80ab8b93          	addi	s7,s7,-2038 # 800a18 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800216:	000d4503          	lbu	a0,0(s10)
  80021a:	001d0413          	addi	s0,s10,1
  80021e:	01350a63          	beq	a0,s3,800232 <vprintfmt+0x56>
            if (ch == '\0') {
  800222:	c121                	beqz	a0,800262 <vprintfmt+0x86>
            putch(ch, putdat);
  800224:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800226:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800228:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80022a:	fff44503          	lbu	a0,-1(s0)
  80022e:	ff351ae3          	bne	a0,s3,800222 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  800232:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800236:	02000793          	li	a5,32
        lflag = altflag = 0;
  80023a:	4c81                	li	s9,0
  80023c:	4881                	li	a7,0
        width = precision = -1;
  80023e:	5c7d                	li	s8,-1
  800240:	5dfd                	li	s11,-1
  800242:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  800246:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  800248:	fdd6059b          	addiw	a1,a2,-35
  80024c:	0ff5f593          	zext.b	a1,a1
  800250:	00140d13          	addi	s10,s0,1
  800254:	04b56263          	bltu	a0,a1,800298 <vprintfmt+0xbc>
  800258:	058a                	slli	a1,a1,0x2
  80025a:	95d6                	add	a1,a1,s5
  80025c:	4194                	lw	a3,0(a1)
  80025e:	96d6                	add	a3,a3,s5
  800260:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800262:	70e6                	ld	ra,120(sp)
  800264:	7446                	ld	s0,112(sp)
  800266:	74a6                	ld	s1,104(sp)
  800268:	7906                	ld	s2,96(sp)
  80026a:	69e6                	ld	s3,88(sp)
  80026c:	6a46                	ld	s4,80(sp)
  80026e:	6aa6                	ld	s5,72(sp)
  800270:	6b06                	ld	s6,64(sp)
  800272:	7be2                	ld	s7,56(sp)
  800274:	7c42                	ld	s8,48(sp)
  800276:	7ca2                	ld	s9,40(sp)
  800278:	7d02                	ld	s10,32(sp)
  80027a:	6de2                	ld	s11,24(sp)
  80027c:	6109                	addi	sp,sp,128
  80027e:	8082                	ret
            padc = '0';
  800280:	87b2                	mv	a5,a2
            goto reswitch;
  800282:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800286:	846a                	mv	s0,s10
  800288:	00140d13          	addi	s10,s0,1
  80028c:	fdd6059b          	addiw	a1,a2,-35
  800290:	0ff5f593          	zext.b	a1,a1
  800294:	fcb572e3          	bgeu	a0,a1,800258 <vprintfmt+0x7c>
            putch('%', putdat);
  800298:	85a6                	mv	a1,s1
  80029a:	02500513          	li	a0,37
  80029e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8002a0:	fff44783          	lbu	a5,-1(s0)
  8002a4:	8d22                	mv	s10,s0
  8002a6:	f73788e3          	beq	a5,s3,800216 <vprintfmt+0x3a>
  8002aa:	ffed4783          	lbu	a5,-2(s10)
  8002ae:	1d7d                	addi	s10,s10,-1
  8002b0:	ff379de3          	bne	a5,s3,8002aa <vprintfmt+0xce>
  8002b4:	b78d                	j	800216 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  8002b6:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  8002ba:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002be:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002c0:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002c4:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002c8:	02d86463          	bltu	a6,a3,8002f0 <vprintfmt+0x114>
                ch = *fmt;
  8002cc:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  8002d0:	002c169b          	slliw	a3,s8,0x2
  8002d4:	0186873b          	addw	a4,a3,s8
  8002d8:	0017171b          	slliw	a4,a4,0x1
  8002dc:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  8002de:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  8002e2:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002e4:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  8002e8:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002ec:	fed870e3          	bgeu	a6,a3,8002cc <vprintfmt+0xf0>
            if (width < 0)
  8002f0:	f40ddce3          	bgez	s11,800248 <vprintfmt+0x6c>
                width = precision, precision = -1;
  8002f4:	8de2                	mv	s11,s8
  8002f6:	5c7d                	li	s8,-1
  8002f8:	bf81                	j	800248 <vprintfmt+0x6c>
            if (width < 0)
  8002fa:	fffdc693          	not	a3,s11
  8002fe:	96fd                	srai	a3,a3,0x3f
  800300:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  800304:	00144603          	lbu	a2,1(s0)
  800308:	2d81                	sext.w	s11,s11
  80030a:	846a                	mv	s0,s10
            goto reswitch;
  80030c:	bf35                	j	800248 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  80030e:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800312:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800316:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  800318:	846a                	mv	s0,s10
            goto process_precision;
  80031a:	bfd9                	j	8002f0 <vprintfmt+0x114>
    if (lflag >= 2) {
  80031c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80031e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800322:	01174463          	blt	a4,a7,80032a <vprintfmt+0x14e>
    else if (lflag) {
  800326:	1a088e63          	beqz	a7,8004e2 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  80032a:	000a3603          	ld	a2,0(s4)
  80032e:	46c1                	li	a3,16
  800330:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800332:	2781                	sext.w	a5,a5
  800334:	876e                	mv	a4,s11
  800336:	85a6                	mv	a1,s1
  800338:	854a                	mv	a0,s2
  80033a:	e37ff0ef          	jal	ra,800170 <printnum>
            break;
  80033e:	bde1                	j	800216 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  800340:	000a2503          	lw	a0,0(s4)
  800344:	85a6                	mv	a1,s1
  800346:	0a21                	addi	s4,s4,8
  800348:	9902                	jalr	s2
            break;
  80034a:	b5f1                	j	800216 <vprintfmt+0x3a>
    if (lflag >= 2) {
  80034c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80034e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800352:	01174463          	blt	a4,a7,80035a <vprintfmt+0x17e>
    else if (lflag) {
  800356:	18088163          	beqz	a7,8004d8 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  80035a:	000a3603          	ld	a2,0(s4)
  80035e:	46a9                	li	a3,10
  800360:	8a2e                	mv	s4,a1
  800362:	bfc1                	j	800332 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  800364:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800368:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  80036a:	846a                	mv	s0,s10
            goto reswitch;
  80036c:	bdf1                	j	800248 <vprintfmt+0x6c>
            putch(ch, putdat);
  80036e:	85a6                	mv	a1,s1
  800370:	02500513          	li	a0,37
  800374:	9902                	jalr	s2
            break;
  800376:	b545                	j	800216 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  800378:	00144603          	lbu	a2,1(s0)
            lflag ++;
  80037c:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  80037e:	846a                	mv	s0,s10
            goto reswitch;
  800380:	b5e1                	j	800248 <vprintfmt+0x6c>
    if (lflag >= 2) {
  800382:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800384:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800388:	01174463          	blt	a4,a7,800390 <vprintfmt+0x1b4>
    else if (lflag) {
  80038c:	14088163          	beqz	a7,8004ce <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  800390:	000a3603          	ld	a2,0(s4)
  800394:	46a1                	li	a3,8
  800396:	8a2e                	mv	s4,a1
  800398:	bf69                	j	800332 <vprintfmt+0x156>
            putch('0', putdat);
  80039a:	03000513          	li	a0,48
  80039e:	85a6                	mv	a1,s1
  8003a0:	e03e                	sd	a5,0(sp)
  8003a2:	9902                	jalr	s2
            putch('x', putdat);
  8003a4:	85a6                	mv	a1,s1
  8003a6:	07800513          	li	a0,120
  8003aa:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003ac:	0a21                	addi	s4,s4,8
            goto number;
  8003ae:	6782                	ld	a5,0(sp)
  8003b0:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003b2:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  8003b6:	bfb5                	j	800332 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003b8:	000a3403          	ld	s0,0(s4)
  8003bc:	008a0713          	addi	a4,s4,8
  8003c0:	e03a                	sd	a4,0(sp)
  8003c2:	14040263          	beqz	s0,800506 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  8003c6:	0fb05763          	blez	s11,8004b4 <vprintfmt+0x2d8>
  8003ca:	02d00693          	li	a3,45
  8003ce:	0cd79163          	bne	a5,a3,800490 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003d2:	00044783          	lbu	a5,0(s0)
  8003d6:	0007851b          	sext.w	a0,a5
  8003da:	cf85                	beqz	a5,800412 <vprintfmt+0x236>
  8003dc:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003e0:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003e4:	000c4563          	bltz	s8,8003ee <vprintfmt+0x212>
  8003e8:	3c7d                	addiw	s8,s8,-1
  8003ea:	036c0263          	beq	s8,s6,80040e <vprintfmt+0x232>
                    putch('?', putdat);
  8003ee:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003f0:	0e0c8e63          	beqz	s9,8004ec <vprintfmt+0x310>
  8003f4:	3781                	addiw	a5,a5,-32
  8003f6:	0ef47b63          	bgeu	s0,a5,8004ec <vprintfmt+0x310>
                    putch('?', putdat);
  8003fa:	03f00513          	li	a0,63
  8003fe:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800400:	000a4783          	lbu	a5,0(s4)
  800404:	3dfd                	addiw	s11,s11,-1
  800406:	0a05                	addi	s4,s4,1
  800408:	0007851b          	sext.w	a0,a5
  80040c:	ffe1                	bnez	a5,8003e4 <vprintfmt+0x208>
            for (; width > 0; width --) {
  80040e:	01b05963          	blez	s11,800420 <vprintfmt+0x244>
  800412:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800414:	85a6                	mv	a1,s1
  800416:	02000513          	li	a0,32
  80041a:	9902                	jalr	s2
            for (; width > 0; width --) {
  80041c:	fe0d9be3          	bnez	s11,800412 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  800420:	6a02                	ld	s4,0(sp)
  800422:	bbd5                	j	800216 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800424:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800426:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  80042a:	01174463          	blt	a4,a7,800432 <vprintfmt+0x256>
    else if (lflag) {
  80042e:	08088d63          	beqz	a7,8004c8 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  800432:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800436:	0a044d63          	bltz	s0,8004f0 <vprintfmt+0x314>
            num = getint(&ap, lflag);
  80043a:	8622                	mv	a2,s0
  80043c:	8a66                	mv	s4,s9
  80043e:	46a9                	li	a3,10
  800440:	bdcd                	j	800332 <vprintfmt+0x156>
            err = va_arg(ap, int);
  800442:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800446:	4761                	li	a4,24
            err = va_arg(ap, int);
  800448:	0a21                	addi	s4,s4,8
            if (err < 0) {
  80044a:	41f7d69b          	sraiw	a3,a5,0x1f
  80044e:	8fb5                	xor	a5,a5,a3
  800450:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800454:	02d74163          	blt	a4,a3,800476 <vprintfmt+0x29a>
  800458:	00369793          	slli	a5,a3,0x3
  80045c:	97de                	add	a5,a5,s7
  80045e:	639c                	ld	a5,0(a5)
  800460:	cb99                	beqz	a5,800476 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  800462:	86be                	mv	a3,a5
  800464:	00000617          	auipc	a2,0x0
  800468:	39460613          	addi	a2,a2,916 # 8007f8 <main+0x27e>
  80046c:	85a6                	mv	a1,s1
  80046e:	854a                	mv	a0,s2
  800470:	0ce000ef          	jal	ra,80053e <printfmt>
  800474:	b34d                	j	800216 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800476:	00000617          	auipc	a2,0x0
  80047a:	37260613          	addi	a2,a2,882 # 8007e8 <main+0x26e>
  80047e:	85a6                	mv	a1,s1
  800480:	854a                	mv	a0,s2
  800482:	0bc000ef          	jal	ra,80053e <printfmt>
  800486:	bb41                	j	800216 <vprintfmt+0x3a>
                p = "(null)";
  800488:	00000417          	auipc	s0,0x0
  80048c:	35840413          	addi	s0,s0,856 # 8007e0 <main+0x266>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800490:	85e2                	mv	a1,s8
  800492:	8522                	mv	a0,s0
  800494:	e43e                	sd	a5,8(sp)
  800496:	0c8000ef          	jal	ra,80055e <strnlen>
  80049a:	40ad8dbb          	subw	s11,s11,a0
  80049e:	01b05b63          	blez	s11,8004b4 <vprintfmt+0x2d8>
                    putch(padc, putdat);
  8004a2:	67a2                	ld	a5,8(sp)
  8004a4:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a8:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004aa:	85a6                	mv	a1,s1
  8004ac:	8552                	mv	a0,s4
  8004ae:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004b0:	fe0d9ce3          	bnez	s11,8004a8 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004b4:	00044783          	lbu	a5,0(s0)
  8004b8:	00140a13          	addi	s4,s0,1
  8004bc:	0007851b          	sext.w	a0,a5
  8004c0:	d3a5                	beqz	a5,800420 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  8004c2:	05e00413          	li	s0,94
  8004c6:	bf39                	j	8003e4 <vprintfmt+0x208>
        return va_arg(*ap, int);
  8004c8:	000a2403          	lw	s0,0(s4)
  8004cc:	b7ad                	j	800436 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  8004ce:	000a6603          	lwu	a2,0(s4)
  8004d2:	46a1                	li	a3,8
  8004d4:	8a2e                	mv	s4,a1
  8004d6:	bdb1                	j	800332 <vprintfmt+0x156>
  8004d8:	000a6603          	lwu	a2,0(s4)
  8004dc:	46a9                	li	a3,10
  8004de:	8a2e                	mv	s4,a1
  8004e0:	bd89                	j	800332 <vprintfmt+0x156>
  8004e2:	000a6603          	lwu	a2,0(s4)
  8004e6:	46c1                	li	a3,16
  8004e8:	8a2e                	mv	s4,a1
  8004ea:	b5a1                	j	800332 <vprintfmt+0x156>
                    putch(ch, putdat);
  8004ec:	9902                	jalr	s2
  8004ee:	bf09                	j	800400 <vprintfmt+0x224>
                putch('-', putdat);
  8004f0:	85a6                	mv	a1,s1
  8004f2:	02d00513          	li	a0,45
  8004f6:	e03e                	sd	a5,0(sp)
  8004f8:	9902                	jalr	s2
                num = -(long long)num;
  8004fa:	6782                	ld	a5,0(sp)
  8004fc:	8a66                	mv	s4,s9
  8004fe:	40800633          	neg	a2,s0
  800502:	46a9                	li	a3,10
  800504:	b53d                	j	800332 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  800506:	03b05163          	blez	s11,800528 <vprintfmt+0x34c>
  80050a:	02d00693          	li	a3,45
  80050e:	f6d79de3          	bne	a5,a3,800488 <vprintfmt+0x2ac>
                p = "(null)";
  800512:	00000417          	auipc	s0,0x0
  800516:	2ce40413          	addi	s0,s0,718 # 8007e0 <main+0x266>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80051a:	02800793          	li	a5,40
  80051e:	02800513          	li	a0,40
  800522:	00140a13          	addi	s4,s0,1
  800526:	bd6d                	j	8003e0 <vprintfmt+0x204>
  800528:	00000a17          	auipc	s4,0x0
  80052c:	2b9a0a13          	addi	s4,s4,697 # 8007e1 <main+0x267>
  800530:	02800513          	li	a0,40
  800534:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  800538:	05e00413          	li	s0,94
  80053c:	b565                	j	8003e4 <vprintfmt+0x208>

000000000080053e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80053e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800540:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800544:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800546:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800548:	ec06                	sd	ra,24(sp)
  80054a:	f83a                	sd	a4,48(sp)
  80054c:	fc3e                	sd	a5,56(sp)
  80054e:	e0c2                	sd	a6,64(sp)
  800550:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800552:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800554:	c89ff0ef          	jal	ra,8001dc <vprintfmt>
}
  800558:	60e2                	ld	ra,24(sp)
  80055a:	6161                	addi	sp,sp,80
  80055c:	8082                	ret

000000000080055e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  80055e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800560:	e589                	bnez	a1,80056a <strnlen+0xc>
  800562:	a811                	j	800576 <strnlen+0x18>
        cnt ++;
  800564:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800566:	00f58863          	beq	a1,a5,800576 <strnlen+0x18>
  80056a:	00f50733          	add	a4,a0,a5
  80056e:	00074703          	lbu	a4,0(a4)
  800572:	fb6d                	bnez	a4,800564 <strnlen+0x6>
  800574:	85be                	mv	a1,a5
    }
    return cnt;
}
  800576:	852e                	mv	a0,a1
  800578:	8082                	ret

000000000080057a <main>:
    for (i = 0; i != 100; ++i) {
        j = !j;
    }
}

int main(void) {
  80057a:	711d                	addi	sp,sp,-96
    int i;
    
    cprintf("\n========================================\n");
  80057c:	00000517          	auipc	a0,0x0
  800580:	56450513          	addi	a0,a0,1380 # 800ae0 <error_string+0xc8>
int main(void) {
  800584:	ec86                	sd	ra,88(sp)
  800586:	e8a2                	sd	s0,80(sp)
  800588:	e4a6                	sd	s1,72(sp)
  80058a:	e0ca                	sd	s2,64(sp)
  80058c:	fc4e                	sd	s3,56(sp)
  80058e:	f852                	sd	s4,48(sp)
  800590:	f456                	sd	s5,40(sp)
    cprintf("\n========================================\n");
  800592:	b11ff0ef          	jal	ra,8000a2 <cprintf>
    cprintf("  Scheduling Algorithm Test\n");
  800596:	00000517          	auipc	a0,0x0
  80059a:	57a50513          	addi	a0,a0,1402 # 800b10 <error_string+0xf8>
  80059e:	b05ff0ef          	jal	ra,8000a2 <cprintf>
    cprintf("  LAB6 CHALLENGE 2: 2310137\n");
  8005a2:	00000517          	auipc	a0,0x0
  8005a6:	58e50513          	addi	a0,a0,1422 # 800b30 <error_string+0x118>
  8005aa:	af9ff0ef          	jal	ra,8000a2 <cprintf>
    cprintf("========================================\n\n");
  8005ae:	00000517          	auipc	a0,0x0
  8005b2:	5a250513          	addi	a0,a0,1442 # 800b50 <error_string+0x138>
  8005b6:	aedff0ef          	jal	ra,8000a2 <cprintf>
    
    // 主进程设置高优先级
    lab6_setpriority(TOTAL + 1);
  8005ba:	4519                	li	a0,6
  8005bc:	00001a97          	auipc	s5,0x1
  8005c0:	a44a8a93          	addi	s5,s5,-1468 # 801000 <acc>
  8005c4:	00001497          	auipc	s1,0x1
  8005c8:	a5448493          	addi	s1,s1,-1452 # 801018 <pids>
  8005cc:	b93ff0ef          	jal	ra,80015e <lab6_setpriority>
    
    for (i = 0; i < TOTAL; i++) {
  8005d0:	89d6                	mv	s3,s5
    lab6_setpriority(TOTAL + 1);
  8005d2:	8926                	mv	s2,s1
    for (i = 0; i < TOTAL; i++) {
  8005d4:	4401                	li	s0,0
  8005d6:	4a15                	li	s4,5
        acc[i] = 0;
  8005d8:	0009a023          	sw	zero,0(s3)
        if ((pids[i] = fork()) == 0) {
  8005dc:	b79ff0ef          	jal	ra,800154 <fork>
  8005e0:	00a92023          	sw	a0,0(s2)
  8005e4:	10050863          	beqz	a0,8006f4 <main+0x17a>
                        exit(acc[i]);
                    }
                }
            }
        }
        if (pids[i] < 0) {
  8005e8:	16054c63          	bltz	a0,800760 <main+0x1e6>
    for (i = 0; i < TOTAL; i++) {
  8005ec:	2405                	addiw	s0,s0,1
  8005ee:	0991                	addi	s3,s3,4
  8005f0:	0911                	addi	s2,s2,4
  8005f2:	ff4413e3          	bne	s0,s4,8005d8 <main+0x5e>
            goto failed;
        }
    }
    
    cprintf("main: fork ok, waiting for children...\n");
  8005f6:	00000517          	auipc	a0,0x0
  8005fa:	5ba50513          	addi	a0,a0,1466 # 800bb0 <error_string+0x198>
  8005fe:	aa5ff0ef          	jal	ra,8000a2 <cprintf>
    
    int status[TOTAL];
    for (i = 0; i < TOTAL; i++) {
  800602:	0020                	addi	s0,sp,8
  800604:	01c10993          	addi	s3,sp,28
        status[i] = 0;
        waitpid(pids[i], &status[i]);
        cprintf("main: pid %d done, acc %d\n", pids[i], status[i]);
  800608:	00000917          	auipc	s2,0x0
  80060c:	5d090913          	addi	s2,s2,1488 # 800bd8 <error_string+0x1c0>
        waitpid(pids[i], &status[i]);
  800610:	4088                	lw	a0,0(s1)
  800612:	85a2                	mv	a1,s0
        status[i] = 0;
  800614:	00042023          	sw	zero,0(s0)
        waitpid(pids[i], &status[i]);
  800618:	b3fff0ef          	jal	ra,800156 <waitpid>
        cprintf("main: pid %d done, acc %d\n", pids[i], status[i]);
  80061c:	4010                	lw	a2,0(s0)
  80061e:	408c                	lw	a1,0(s1)
  800620:	854a                	mv	a0,s2
    for (i = 0; i < TOTAL; i++) {
  800622:	0411                	addi	s0,s0,4
        cprintf("main: pid %d done, acc %d\n", pids[i], status[i]);
  800624:	a7fff0ef          	jal	ra,8000a2 <cprintf>
    for (i = 0; i < TOTAL; i++) {
  800628:	0491                	addi	s1,s1,4
  80062a:	ff3413e3          	bne	s0,s3,800610 <main+0x96>
    }
    
    cprintf("\n========================================\n");
  80062e:	00000517          	auipc	a0,0x0
  800632:	4b250513          	addi	a0,a0,1202 # 800ae0 <error_string+0xc8>
  800636:	a6dff0ef          	jal	ra,8000a2 <cprintf>
    cprintf("  Results (acc values):\n");
  80063a:	00000517          	auipc	a0,0x0
  80063e:	5be50513          	addi	a0,a0,1470 # 800bf8 <error_string+0x1e0>
  800642:	a61ff0ef          	jal	ra,8000a2 <cprintf>
    cprintf("========================================\n");
  800646:	00000517          	auipc	a0,0x0
  80064a:	5d250513          	addi	a0,a0,1490 # 800c18 <error_string+0x200>
  80064e:	a55ff0ef          	jal	ra,8000a2 <cprintf>
    cprintf("Priority 1 (lowest): %d\n", status[0]);
  800652:	45a2                	lw	a1,8(sp)
  800654:	00000517          	auipc	a0,0x0
  800658:	5f450513          	addi	a0,a0,1524 # 800c48 <error_string+0x230>
  80065c:	a47ff0ef          	jal	ra,8000a2 <cprintf>
    cprintf("Priority 2:          %d\n", status[1]);
  800660:	45b2                	lw	a1,12(sp)
  800662:	00000517          	auipc	a0,0x0
  800666:	60650513          	addi	a0,a0,1542 # 800c68 <error_string+0x250>
  80066a:	a39ff0ef          	jal	ra,8000a2 <cprintf>
    cprintf("Priority 3:          %d\n", status[2]);
  80066e:	45c2                	lw	a1,16(sp)
  800670:	00000517          	auipc	a0,0x0
  800674:	61850513          	addi	a0,a0,1560 # 800c88 <error_string+0x270>
  800678:	a2bff0ef          	jal	ra,8000a2 <cprintf>
    cprintf("Priority 4:          %d\n", status[3]);
  80067c:	45d2                	lw	a1,20(sp)
  80067e:	00000517          	auipc	a0,0x0
  800682:	62a50513          	addi	a0,a0,1578 # 800ca8 <error_string+0x290>
  800686:	a1dff0ef          	jal	ra,8000a2 <cprintf>
    cprintf("Priority 5 (highest):%d\n", status[4]);
  80068a:	45e2                	lw	a1,24(sp)
  80068c:	00000517          	auipc	a0,0x0
  800690:	63c50513          	addi	a0,a0,1596 # 800cc8 <error_string+0x2b0>
  800694:	a0fff0ef          	jal	ra,8000a2 <cprintf>
    
    cprintf("\nExpected behavior:\n");
  800698:	00000517          	auipc	a0,0x0
  80069c:	65050513          	addi	a0,a0,1616 # 800ce8 <error_string+0x2d0>
  8006a0:	a03ff0ef          	jal	ra,8000a2 <cprintf>
    cprintf("- RR: All acc values similar (fair sharing)\n");
  8006a4:	00000517          	auipc	a0,0x0
  8006a8:	65c50513          	addi	a0,a0,1628 # 800d00 <error_string+0x2e8>
  8006ac:	9f7ff0ef          	jal	ra,8000a2 <cprintf>
    cprintf("- Stride: Higher priority = higher acc (proportional)\n");
  8006b0:	00000517          	auipc	a0,0x0
  8006b4:	68050513          	addi	a0,a0,1664 # 800d30 <error_string+0x318>
  8006b8:	9ebff0ef          	jal	ra,8000a2 <cprintf>
    cprintf("- FIFO: Similar acc (FIFO order)\n");
  8006bc:	00000517          	auipc	a0,0x0
  8006c0:	6ac50513          	addi	a0,a0,1708 # 800d68 <error_string+0x350>
  8006c4:	9dfff0ef          	jal	ra,8000a2 <cprintf>
    cprintf("- Priority: Higher priority = higher acc\n");
  8006c8:	00000517          	auipc	a0,0x0
  8006cc:	6c850513          	addi	a0,a0,1736 # 800d90 <error_string+0x378>
  8006d0:	9d3ff0ef          	jal	ra,8000a2 <cprintf>
    
    cprintf("\nsched_test passed.\n");
  8006d4:	00000517          	auipc	a0,0x0
  8006d8:	6ec50513          	addi	a0,a0,1772 # 800dc0 <error_string+0x3a8>
  8006dc:	9c7ff0ef          	jal	ra,8000a2 <cprintf>
        if (pids[i] > 0) {
            kill(pids[i]);
        }
    }
    panic("sched_test FAILED!\n");
}
  8006e0:	60e6                	ld	ra,88(sp)
  8006e2:	6446                	ld	s0,80(sp)
  8006e4:	64a6                	ld	s1,72(sp)
  8006e6:	6906                	ld	s2,64(sp)
  8006e8:	79e2                	ld	s3,56(sp)
  8006ea:	7a42                	ld	s4,48(sp)
  8006ec:	7aa2                	ld	s5,40(sp)
  8006ee:	4501                	li	a0,0
  8006f0:	6125                	addi	sp,sp,96
  8006f2:	8082                	ret
            lab6_setpriority(i + 1);
  8006f4:	0014049b          	addiw	s1,s0,1
            acc[i] = 0;
  8006f8:	040a                	slli	s0,s0,0x2
            lab6_setpriority(i + 1);
  8006fa:	8526                	mv	a0,s1
            acc[i] = 0;
  8006fc:	9456                	add	s0,s0,s5
                if (acc[i] % 4000 == 0) {
  8006fe:	6905                	lui	s2,0x1
            lab6_setpriority(i + 1);
  800700:	a5fff0ef          	jal	ra,80015e <lab6_setpriority>
                if (acc[i] % 4000 == 0) {
  800704:	fa09091b          	addiw	s2,s2,-96
            acc[i] = 0;
  800708:	00042023          	sw	zero,0(s0)
                    if ((time = gettime_msec()) > MAX_TIME) {
  80070c:	3e800a13          	li	s4,1000
  800710:	4014                	lw	a3,0(s0)
  800712:	2685                	addiw	a3,a3,1
    for (i = 0; i != 100; ++i) {
  800714:	06400713          	li	a4,100
        j = !j;
  800718:	47a2                	lw	a5,8(sp)
    for (i = 0; i != 100; ++i) {
  80071a:	377d                	addiw	a4,a4,-1
        j = !j;
  80071c:	2781                	sext.w	a5,a5
  80071e:	0017b793          	seqz	a5,a5
  800722:	c43e                	sw	a5,8(sp)
    for (i = 0; i != 100; ++i) {
  800724:	fb75                	bnez	a4,800718 <main+0x19e>
                if (acc[i] % 4000 == 0) {
  800726:	0326f7bb          	remuw	a5,a3,s2
  80072a:	0016871b          	addiw	a4,a3,1
  80072e:	c399                	beqz	a5,800734 <main+0x1ba>
  800730:	86ba                	mv	a3,a4
  800732:	b7cd                	j	800714 <main+0x19a>
  800734:	c014                	sw	a3,0(s0)
                    if ((time = gettime_msec()) > MAX_TIME) {
  800736:	a27ff0ef          	jal	ra,80015c <gettime_msec>
  80073a:	0005099b          	sext.w	s3,a0
  80073e:	fd3a59e3          	bge	s4,s3,800710 <main+0x196>
                        cprintf("child pid %d, priority %d, acc %d, time %d\n",
  800742:	a19ff0ef          	jal	ra,80015a <getpid>
  800746:	4014                	lw	a3,0(s0)
  800748:	85aa                	mv	a1,a0
  80074a:	874e                	mv	a4,s3
  80074c:	8626                	mv	a2,s1
  80074e:	00000517          	auipc	a0,0x0
  800752:	43250513          	addi	a0,a0,1074 # 800b80 <error_string+0x168>
  800756:	94dff0ef          	jal	ra,8000a2 <cprintf>
                        exit(acc[i]);
  80075a:	4008                	lw	a0,0(s0)
  80075c:	9e3ff0ef          	jal	ra,80013e <exit>
  800760:	00001417          	auipc	s0,0x1
  800764:	8cc40413          	addi	s0,s0,-1844 # 80102c <pids+0x14>
        if (pids[i] > 0) {
  800768:	4088                	lw	a0,0(s1)
  80076a:	00a05463          	blez	a0,800772 <main+0x1f8>
            kill(pids[i]);
  80076e:	9ebff0ef          	jal	ra,800158 <kill>
    for (i = 0; i < TOTAL; i++) {
  800772:	0491                	addi	s1,s1,4
  800774:	fe849ae3          	bne	s1,s0,800768 <main+0x1ee>
    panic("sched_test FAILED!\n");
  800778:	00000617          	auipc	a2,0x0
  80077c:	66060613          	addi	a2,a2,1632 # 800dd8 <error_string+0x3c0>
  800780:	06500593          	li	a1,101
  800784:	00000517          	auipc	a0,0x0
  800788:	66c50513          	addi	a0,a0,1644 # 800df0 <error_string+0x3d8>
  80078c:	89bff0ef          	jal	ra,800026 <__panic>
