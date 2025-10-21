## 练习1：完善中断处理

### 实现过程

本实验在 `trap.c` 文件中完善了定时器中断的处理流程。主要步骤如下：

1. **设置下次时钟中断**：在 `interrupt_handler` 函数的 `IRQ_S_TIMER` 分支中，调用 `clock_set_next_event()`，确保时钟中断能够周期性触发。
2. **计数器自增**：每次进入时钟中断时，将全局变量 `ticks` 自增，记录中断次数。
3. **定期输出信息**：每当 `ticks` 达到 100 的倍数时，调用 `print_ticks()` 输出 "100 ticks" 信息，并将打印次数 `num` 自增。
4. **自动关机**：当打印次数 `num` 达到 10 时，调用 `sbi_shutdown()` 实现自动关机，防止系统无限循环输出。

### 定时器中断处理流程

- 当定时器中断发生时，CPU 跳转到中断处理入口，保存现场后进入 `interrupt_handler`。

- 在`IRQ_S_TIMER`

   分支：

  1. 设置下次中断时间（`clock_set_next_event()`）。
  2. 增加 `ticks` 计数。
  3. 每 100 次中断输出一次提示信息。
  4. 达到 10 次输出后自动关机。

- 这样保证了时钟中断的周期性和实验的自动终止。

------

## Challenge1：描述与理解中断流程

**ucore 中处理中断异常的流程如下：**

1. **异常产生**：当 CPU 执行过程中发生中断或异常（如时钟中断、非法指令等），硬件会自动跳转到异常入口（如 `stvec` 指定的地址）。
2. **保存现场**：在 `trapentry.S` 的 `__alltraps` 入口，首先执行 `SAVE_ALL` 宏，将所有通用寄存器（包括 ra、sp、gp、tp、t0-t6、s0-s11、a0-a7）依次压入当前栈空间，形成 `struct pushregs` 的布局。
3. **mov a0, sp 的目的**：将当前 sp（即保存好寄存器后的栈顶地址）传递给 C 语言的 trap 处理函数，作为 `struct trapframe *` 参数，方便 C 代码访问和修改保存的寄存器内容。
4. **寄存器在栈中的位置**：由 `SAVE_ALL` 宏的压栈顺序和 `struct pushregs` 的定义顺序共同决定，保证 C 代码能正确通过偏移访问各寄存器的值。
5. **是否需要保存所有寄存器**：理论上，为了保证异常返回后程序能无损恢复，**需要保存所有通用寄存器**。但对于某些特定异常或中断（如只会用到部分寄存器的陷入），可以只保存必要的寄存器。但 uCore 采用统一的 `SAVE_ALL`，简化了设计，避免遗漏。

------

## Challenge2：理解上下文切换机制

**trapentry.S 中的 `csrw sscratch, sp` 和 `csrrw s0, sscratch, x0` 的作用：**

- `csrw sscratch, sp`：将当前 sp（栈指针）保存到 sscratch CSR（控制状态寄存器）中。这样在陷入异常时，可以临时切换栈指针，防止破坏原有栈。
- `csrrw s0, sscratch, x0`：将 sscratch 的值读到 s0 寄存器，并将 x0 写入 sscratch（即清空 sscratch）。这样可以恢复原来的 sp 值，实现栈的切换和恢复。

**SAVE_ALL 里保存 stval、scause 等 CSR 的意义：**

- 这些 CSR（如 stval、scause）保存了异常发生时的详细信息（如出错地址、异常原因），便于 C 代码分析和处理异常。
- 在 `restore all` 时**不需要还原这些 CSR**，因为异常返回后，CPU 会自动恢复正常执行，不再需要这些异常信息。保存它们只是为了让 C 代码能读取和处理，而不是为了恢复硬件状态。

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