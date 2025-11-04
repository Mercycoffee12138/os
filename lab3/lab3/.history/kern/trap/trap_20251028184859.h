#ifndef __KERN_TRAP_TRAP_H__
#define __KERN_TRAP_TRAP_H__

#include <defs.h>

/*当操作系统处理中断或异常时,需要保存这些寄存器的当前值,以便中断处理完成后能够恢复程序的执行状态。这就是为什么它在 trapframe 结构体中使用,用于完整保存中断发生时的 CPU 状态。
zero (x0) - 硬连线为 0 的寄存器,读取永远返回 0
ra (x1) - 返回地址寄存器,存储函数调用的返回地址
sp (x2) - 栈指针,指向当前栈顶
gp (x3) - 全局指针,用于访问全局变量
tp (x4) - 线程指针,用于线程局部存储
t0-t2, t3-t6 (x5-x7, x28-x31) - 临时寄存器,调用者保存,函数可以随意使用而不需要保存
s0-s11 (x8-x9, x18-x27) - 保存寄存器,被调用者保存,函数如果要使用必须先保存原值
s0 也可以作为帧指针 (frame pointer)
a0-a7 (x10-x17) - 函数参数/返回值寄存器
a0, a1 还用于存储函数返回值
*/
struct pushregs {
    uintptr_t zero;  // Hard-wired zero
    uintptr_t ra;    // Return address
    uintptr_t sp;    // Stack pointer
    uintptr_t gp;    // Global pointer
    uintptr_t tp;    // Thread pointer
    uintptr_t t0;    // Temporary
    uintptr_t t1;    // Temporary
    uintptr_t t2;    // Temporary
    uintptr_t s0;    // Saved register/frame pointer
    uintptr_t s1;    // Saved register
    uintptr_t a0;    // Function argument/return value
    uintptr_t a1;    // Function argument/return value
    uintptr_t a2;    // Function argument
    uintptr_t a3;    // Function argument
    uintptr_t a4;    // Function argument
    uintptr_t a5;    // Function argument
    uintptr_t a6;    // Function argument
    uintptr_t a7;    // Function argument
    uintptr_t s2;    // Saved register
    uintptr_t s3;    // Saved register
    uintptr_t s4;    // Saved register
    uintptr_t s5;    // Saved register
    uintptr_t s6;    // Saved register
    uintptr_t s7;    // Saved register
    uintptr_t s8;    // Saved register
    uintptr_t s9;    // Saved register
    uintptr_t s10;   // Saved register
    uintptr_t s11;   // Saved register
    uintptr_t t3;    // Temporary
    uintptr_t t4;    // Temporary
    uintptr_t t5;    // Temporary
    uintptr_t t6;    // Temporary
};

struct trapframe {
    struct pushregs gpr; // 32个通用寄存器
    uintptr_t status;    // sstatus 保存了中断前的状态位
    uintptr_t epc;       // sepc (中断前的指令地址)
    uintptr_t badvaddr;  // sbadaddr (出错地址)
    uintptr_t cause;     // scause (中断原因)
};

void trap(struct trapframe *tf);
void idt_init(void);
void print_trapframe(struct trapframe *tf);
void print_regs(struct pushregs* gpr);
bool trap_in_kernel(struct trapframe *tf);

#endif /* !__KERN_TRAP_TRAP_H__ */
