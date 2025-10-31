# Lab3：中断与中断处理流程

## 练习1：完善中断处理

### 实现过程

本实验在 `trap.c` 文件中完善了定时器中断的处理流程。主要步骤如下：

1. **设置下次时钟中断**：在 `interrupt_handler` 函数的 `IRQ_S_TIMER` 分支中，调用 `clock_set_next_event()`，确保时钟中断能够周期性触发。
2. **计数器自增**：每次进入时钟中断时，将全局变量 `ticks` 自增，记录中断次数。
3. **定期输出信息**：每当 `ticks` 达到 100 的倍数时，调用 `print_ticks()` 输出 "100 ticks" 信息，并将打印次数 `num` 自增。
4. **自动关机**：当打印次数 `num` 达到 10 时，调用 `sbi_shutdown()` 实现自动关机，防止系统无限循环输出。

```c++
clock_set_next_event();//发生这次时钟中断的时候，我们要设置下一次时钟中断
if (++ticks % TICK_NUM == 0) {
    print_ticks();
    num++; // 打印次数加一
    if (num == 10) {
        sbi_shutdown(); // 关机
    }
}
```

### 定时器中断处理流程

- 当定时器中断发生时，CPU 跳转到中断处理入口，保存现场后进入 `interrupt_handler`。

- 在`IRQ_S_TIMER`

   分支：

  1. 设置下次中断时间（`clock_set_next_event()`）。
  2. 增加 `ticks` 计数。
  3. 每 100 次中断输出一次提示信息。
  4. 达到 10 次输出后自动关机。

- 这样保证了时钟中断的周期性和实验的自动终止。

### 结果展示：

我们可以看到确实在打印了10个`100 ticks`之后，程序自己进行了中断。

![练习1结果](练习1结果.png)

------

## Challenge1：描述与理解中断流程

### 一、中断异常处理的完整流程

#### 1. 异常/中断的产生

- 当发生中断（如时钟中断）或异常（如非法指令、断点）时，CPU硬件自动做以下事情：
  - 将当前PC值保存到 `sepc` (Supervisor Exception Program Counter)
  - 将异常/中断原因保存到 `scause` 寄存器
  - 将出错地址保存到 `sbadaddr` 寄存器
  - 将当前状态保存到 `sstatus` 寄存器
  - 跳转到 `stvec` 寄存器指向的地址（即 `__alltraps`）

#### 2. 进入 `__alltraps` (trapentry.S)

```
__alltraps:
    SAVE_ALL              # 保存所有寄存器到栈中
    move  a0, sp          # 将栈指针sp赋值给a0
    jal trap              # 调用C函数trap()
```

#### 3. `SAVE_ALL` 宏展开（保存上下文）

```
csrw sscratch, sp         # 先将当前sp保存到sscratch
addi sp, sp, -36*REGBYTES # 在栈上分配36个寄存器大小的空间
STORE x0-x31...           # 保存32个通用寄存器
csrr s0-s4, CSRs...       # 读取CSR寄存器到通用寄存器
STORE s0-s4...            # 保存CSR寄存器值到栈
```

#### 4. 调用C函数(trap.c)

```
void trap(struct trapframe *tf) {
    trap_dispatch(tf);    # 根据tf->cause分发处理
}
```

#### 5. 分发到具体处理函数

 trap_dispatch()检查tf->cause的最高位：

- 最高位为1 → 中断 → `interrupt_handler()`
- 最高位为0 → 异常 → `exception_handler()`

### 二、`mov a0, sp` 的目的

作用：将trapframe结构体的地址作为参数传递给C函数

​	RISC-V调用约定：在RISC-V架构中，`a0` 寄存器用于传递函数的第一个参数。此时sp的含义：执行完 `SAVE_ALL` 后，`sp` 指向刚刚在栈上构造的 trapframe 结构体的起始地址。

### 三、SAVE_ALL中寄存器在栈中的位置是如何确定的？

由 trapframe 结构体的定义决定的，采用固定偏移量的方式

```c++
struct trapframe {
    struct pushregs gpr;  // 32个通用寄存器 (offset: 0-31*REGBYTES)
    uintptr_t status;     // sstatus (offset: 32*REGBYTES)
    uintptr_t epc;        // sepc    (offset: 33*REGBYTES)
    uintptr_t badvaddr;   // sbadaddr(offset: 34*REGBYTES)
    uintptr_t cause;      // scause  (offset: 35*REGBYTES)
};
```

### 四、是否所有中断都需要保存所有寄存器？

是的，在ucore的设计中，所有中断都需要保存所有寄存器。理由如下：

#### 1. 统一的中断入口

项目中只有一个中断入口 `__alltraps`，这意味着：无论是时钟中断、非法指令、断点等任何中断/异常都会执行同一个 `SAVE_ALL` 宏，无法针对不同中断类型做选择性保存。

#### 2. 无法预知中断处理的需求

时钟中断看起来只需要几个寄存器，但实际上

```c++
clock_set_next_event();  // 可能修改多个寄存器
cprintf("%d ticks\n");   // 函数调用会破坏临时寄存器
```

------

## Challenge2：理解上下文切换机制

#### `csrw sscratch, sp` 和 `csrrw s0, sscratch, x0` 实现了什么操作？

```asm
csrw sscratch, sp # 保存原先的栈顶指针到sscratch
```

将当前的栈指针 `sp` 的值写入到 `sscratch` 寄存器中，临时保存中断发生时的栈顶指针。

```asm
csrrw s0, sscratch, x0
```

这是一个原子交换操作，将 `sscratch` 的值读到 `s0` 寄存器（此时 `s0` 得到了原来的 `sp` 值），同时将 `x0`（恒为0）写入 `sscratch`。取回之前保存的原始 `sp` 值，以便保存到 trapFrame 中。

***

## Challenge3：完善异常中断

### 实现思路

本扩展练习要求完善异常处理流程，能够正确捕获和处理非法指令异常和断点异常。具体实现如下：

1. **定位处理函数**：在 `trap.c`的 `exception_handler` 函数中，分别处理 `CAUSE_ILLEGAL_INSTRUCTION` 和 `CAUSE_BREAKPOINT` 两种异常。
2. 输出异常信息：
   - 对于非法指令异常，输出 "Exception type: Illegal instruction" 和 "Illegal instruction caught at 0x(地址)"。
   - 对于断点异常，输出 "Exception type: breakpoint" 和 "ebreak caught at 0x(地址)"。
3. 跳过异常指令：
   - 对于非法指令，`tf->epc += 4`，跳过当前 4 字节指令，防止异常返回后再次陷入异常。
   - 对于断点指令（`ebreak`），`tf->epc += 2`，跳过当前 2 字节指令。
4. **测试验证**：在 `init.c` 中插入 `ebreak` 和非法指令（如 `mret`），验证异常处理是否生效。

### 总结

通过上述实现，系统能够正确识别并处理常见的异常类型，输出详细的异常信息，并保证异常返回后系统能够继续正常运行。这对于操作系统的健壮性和调试非常重要。