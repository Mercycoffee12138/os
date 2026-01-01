# Lab6 调度算法测试指南

## 学号: 2310137

---

## 一、调度算法说明

### 已实现的4种调度算法

| 算法 | 文件 | 特点 | 适用场景 |
|------|------|------|----------|
| **RR** | `default_sched.c` | 时间片轮转，公平分配 | 交互式系统 |
| **Stride** | `default_sched_stride.c` | 按优先级比例分配CPU | 需要精确控制CPU分配 |
| **FIFO** | `sched_FIFO.c` | 先来先服务，非抢占 | 批处理系统 |
| **Priority** | `sched_priority.c` | 高优先级优先执行 | 实时系统 |

---

## 二、测试方法

### 方法1: 手动切换测试（推荐，最简单）

#### 步骤：

1. **修改调度算法**
   
   打开 `kern/schedule/sched.c`，修改第18行：
   ```c
   #define SCHED_ALGORITHM 0  // 0=RR, 1=Stride, 2=FIFO, 3=Priority
   ```

2. **编译并运行**
   ```bash
   make clean
   make qemu
   ```

3. **观察输出**
   
   系统启动时会显示：
   ```
   sched class: RR_scheduler        # 或 stride_scheduler, FIFO_scheduler, priority_scheduler
   ```

4. **运行测试程序**
   
   系统会自动运行 `priority` 测试程序，观察输出结果。

#### 测试不同算法：

```bash
# 测试 RR
# 修改 sched.c: #define SCHED_ALGORITHM 0
make clean && make qemu

# 测试 Stride  
# 修改 sched.c: #define SCHED_ALGORITHM 1
make clean && make qemu

# 测试 FIFO
# 修改 sched.c: #define SCHED_ALGORITHM 2
make clean && make qemu

# 测试 Priority
# 修改 sched.c: #define SCHED_ALGORITHM 3
make clean && make qemu
```

---

### 方法2: 使用测试脚本（Linux/WSL环境）

#### 一次性测试所有算法：

```bash
cd lab6/lab6
chmod +x tools/test_schedulers.sh
./tools/test_schedulers.sh all
```

#### 测试单个算法：

```bash
./tools/test_schedulers.sh 0  # 测试RR
./tools/test_schedulers.sh 1  # 测试Stride
./tools/test_schedulers.sh 2  # 测试FIFO
./tools/test_schedulers.sh 3  # 测试Priority
```

脚本会自动：
- 修改 `sched.c` 中的 `SCHED_ALGORITHM`
- 编译内核
- 运行测试
- 保存输出到 `sched_test_results/` 目录
- 生成比较报告

---

### 方法3: 使用批处理脚本（Windows环境）

如果使用Windows，可以创建一个简单的批处理脚本：

```batch
@echo off
echo Testing all schedulers...

for /L %%i in (0,1,3) do (
    echo.
    echo ========================================
    echo Testing Algorithm %%i
    echo ========================================
    
    REM 修改sched.c中的SCHED_ALGORITHM值
    powershell -Command "(Get-Content kern\schedule\sched.c) -replace '#define SCHED_ALGORITHM \d', '#define SCHED_ALGORITHM %%i' | Set-Content kern\schedule\sched.c"
    
    REM 编译
    make clean
    make
    
    REM 运行（需要手动观察输出）
    echo Please run: make qemu
    echo Press any key to continue to next algorithm...
    pause > nul
)
```

---

## 三、如何观察测试结果

### priority测试程序输出分析

运行 `priority` 测试时，会看到类似输出：

```
sched class: stride_scheduler
kernel_execve: pid = 2, name = "priority".
main: fork ok,now need to wait pids.
set priority to 5
set priority to 4
set priority to 3
set priority to 2
set priority to 1
child pid X, acc Y, time Z
...
sched result: 5 4 3 2 1
```

**关键观察点**：

1. **完成顺序** (`sched result` 后面的数字)
   - RR: 可能不是按优先级顺序
   - Stride: 高优先级进程获得更多CPU，先完成
   - FIFO: 按创建顺序完成
   - Priority: 严格按优先级顺序完成

2. **acc值** (每个进程的累计值)
   - 反映进程实际获得的CPU时间
   - Stride算法下，高优先级进程的acc值应该更大

---

## 四、预期结果对比

### 测试配置（priority程序）：
- 5个进程，优先级分别为 5, 4, 3, 2, 1
- 所有进程执行相同的工作量

### 预期行为：

| 调度算法 | 完成顺序 | acc值比例 | 说明 |
|----------|----------|-----------|------|
| **RR** | 接近 5,4,3,2,1 | 接近相等 | 公平轮转，不考虑优先级 |
| **Stride** | 5,4,3,2,1 | 5:4:3:2:1 | 按优先级比例分配 |
| **FIFO** | 5,4,3,2,1 | 接近相等 | 按创建顺序，非抢占 |
| **Priority** | 5,4,3,2,1 | 5先完成 | 高优先级先执行完 |

---

## 五、常见问题

### Q1: 如何确认当前使用的是哪个调度器？

**A**: 查看系统启动时的输出：
```
sched class: RR_scheduler
```
或
```
sched class: stride_scheduler
```

### Q2: FIFO和Priority有什么区别？

**A**: 
- **FIFO**: 非抢占式，按到达顺序执行，不考虑优先级
- **Priority**: 抢占式，高优先级先执行，使用时间片

### Q3: 为什么FIFO设置了时间片但不抢占？

**A**: 在 `FIFO_proc_tick` 函数中，我们故意不设置 `need_resched`，这样即使时间片用完也不会强制切换。进程会一直运行直到主动 `yield()` 或阻塞。

### Q4: 如何测试自定义程序？

**A**: 
1. 将你的测试程序放在 `user/` 目录
2. 修改 `Makefile` 或使用 `make run-<程序名>`
3. 或者修改 `kern/process/proc.c` 中的 `user_main` 函数

---

## 六、快速测试清单

- [ ] 修改 `sched.c` 中 `SCHED_ALGORITHM` 为 0，测试 RR
- [ ] 修改为 1，测试 Stride
- [ ] 修改为 2，测试 FIFO  
- [ ] 修改为 3，测试 Priority
- [ ] 对比不同算法的输出结果
- [ ] 记录完成顺序和acc值
- [ ] 分析各算法的特点


