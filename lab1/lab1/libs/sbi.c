// libs/sbi.c
#include <sbi.h>
#include <defs.h>


uint64_t SBI_SET_TIMER = 0;
uint64_t SBI_CONSOLE_PUTCHAR = 1; 
uint64_t SBI_CONSOLE_GETCHAR = 2;
uint64_t SBI_CLEAR_IPI = 3;
uint64_t SBI_SEND_IPI = 4;
uint64_t SBI_REMOTE_FENCE_I = 5;
uint64_t SBI_REMOTE_SFENCE_VMA = 6;
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
        "mv x17, %[sbi_type]\n"   // 把 sbi_type 放到寄存器 x17（SBI 规范要求）
        "mv x10, %[arg0]\n"       // 把 arg0 放到 x10
        "mv x11, %[arg1]\n"       // 把 arg1 放到 x11
        "mv x12, %[arg2]\n"       // 把 arg2 放到 x12
        "ecall\n"                 // 执行 ecall 指令，触发 SBI 调用
        "mv %[ret_val], x10"      // 把返回值从 x10 取出，存到 ret_val
        : [ret_val] "=r" (ret_val)//ret_val是一个输出变量，汇编代码会将结果保存到一个寄存器中，然后复制给ret_val
        : [sbi_type] "r" (sbi_type), [arg0] "r" (arg0), [arg1] "r" (arg1), [arg2] "r" (arg2)
        //sbi_type,arg0,arg1,arg2是输入变量，会将值放入寄存器中给汇编代码使用
        : "memory"//表示可能会修改内存
    );
    return ret_val;
}

//向控制台输出一个字符
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
//设置定时器
void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
