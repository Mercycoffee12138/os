# RISC-V QEMU + GDB 调试指南

## 调试步骤

### 1. 启动 QEMU 调试模式

```bash
make debug
```

这会启动 QEMU 并监听 1234 端口，CPU 在启动时暂停等待 GDB 连接。

### 2. 连接 GDB（在另一个终端）

```bash
make gdb
```

或者手动运行：

```bash
riscv64-unknown-elf-gdb \
    -ex 'file bin/kernel' \
    -ex 'set arch riscv:rv64' \
    -ex 'target remote localhost:1234'
```

### 3. 调试 CPU 复位地址执行

#### 查看当前 PC 位置

```
(gdb) info registers pc
(gdb) x/i $pc
```

#### 从复位地址 0x1000 开始调试

```
(gdb) b *0x1000
(gdb) c
(gdb) x/10i $pc
```

#### 单步执行观察 OpenSBI 初始化

```
(gdb) stepi
(gdb) x/i $pc
(gdb) info registers
```

### 4. 监控内核加载过程

#### 设置观察点监控 0x80200000 地址

```
(gdb) watch *0x80200000
(gdb) c
```

#### 在内核入口设置断点

```
(gdb) c
(gdb) c
```

### 5. 关键调试命令

- `x/10i $pc` - 查看当前 PC 处的 10 条指令
- `info registers` - 查看所有寄存器状态
- `stepi` - 单步执行一条指令
- `nexti` - 执行一条指令（不进入函数调用）
- `c` - 继续执行
- `x/10x 0x1000` - 查看 0x1000 地址处的 16 进制数据

## 需要观察和记录的关键信息

1. **CPU 复位后第一条指令的地址和内容**
2. **OpenSBI 固件的初始化过程**
3. **内核何时被加载到 0x80200000**
4. **SBI 如何跳转到内核代码**

## 预期观察结果

- CPU 从 0x1000 地址开始执行
- OpenSBI 进行硬件初始化
- 内核被加载到 0x80200000
- SBI 最终跳转到 0x80200000 执行内核第一条指令
