# 快速开始：调度算法测试

## 学号: 2310137

---

## 📋 你的问题解答

### Q1: 可以一次性测试所有调度算法吗？

**可以！** 有两种方式：

#### 方式A: 使用批处理脚本（Windows，最简单）
```cmd
cd lab6\lab6
tools\test_all_schedulers.bat
```
脚本会自动：
- 依次修改 `SCHED_ALGORITHM` (0→1→2→3)
- 编译每个版本
- 提示你运行 `make qemu` 测试

#### 方式B: 使用Shell脚本（Linux/WSL）
```bash
cd lab6/lab6
chmod +x tools/test_schedulers.sh
./tools/test_schedulers.sh all
```

---

### Q2: `sched_priority.c` 有什么用？

**优先级调度算法** - 高优先级进程优先执行

**特点**：
- ✅ 高优先级进程先完成
- ✅ 适合实时系统
- ⚠️ 可能导致低优先级进程饥饿

**示例**：
```
进程A: 优先级5 → 先执行
进程B: 优先级3 → 后执行
进程C: 优先级1 → 最后执行
```

---

### Q3: `sched_FIFO.c` 有什么用？

**先来先服务调度算法** - 按到达顺序执行

**特点**：
- ✅ 实现最简单
- ✅ 非抢占式（进程运行直到完成）
- ⚠️ 护航效应（短作业等长作业）

**与Priority的区别**：
| 特性 | FIFO | Priority |
|------|------|----------|
| 选择依据 | 到达顺序 | 优先级 |
| 抢占性 | 非抢占 | 抢占式 |
| 考虑优先级 | ❌ | ✅ |

**示例场景**：
```
FIFO: 即使进程B优先级更高，也要等先到的进程A完成
Priority: 高优先级进程B可以抢占低优先级进程A
```

---

## 🚀 最简单的测试方法（推荐）

### 步骤1: 修改调度算法

打开 `kern/schedule/sched.c`，找到第18行：

```c
#define SCHED_ALGORITHM 0  // 改成 0, 1, 2, 或 3
```

**对应关系**：
- `0` = RR (Round Robin)
- `1` = Stride  
- `2` = FIFO
- `3` = Priority

### 步骤2: 编译运行

```bash
make clean
make qemu
```

### 步骤3: 观察输出

系统启动时会显示：
```
sched class: RR_scheduler        ← 确认当前调度器
```

然后会自动运行 `priority` 测试程序，观察：
- 进程完成顺序
- `sched result:` 后面的数字
- 各进程的 `acc` 值

---

## 📊 四种算法对比表

| 算法 | 文件 | 选择策略 | 抢占性 | 测试值 |
|------|------|----------|--------|--------|
| **RR** | `default_sched.c` | 队首进程 | ✅ 是 | `SCHED_ALGORITHM 0` |
| **Stride** | `default_sched_stride.c` | stride最小 | ✅ 是 | `SCHED_ALGORITHM 1` |
| **FIFO** | `sched_FIFO.c` | 最先到达 | ❌ 否 | `SCHED_ALGORITHM 2` |
| **Priority** | `sched_priority.c` | 优先级最高 | ✅ 是 | `SCHED_ALGORITHM 3` |

---

## 🎯 测试清单

按顺序测试每个算法：

- [ ] **测试RR**: `SCHED_ALGORITHM 0` → `make clean && make qemu`
- [ ] **测试Stride**: `SCHED_ALGORITHM 1` → `make clean && make qemu`  
- [ ] **测试FIFO**: `SCHED_ALGORITHM 2` → `make clean && make qemu`
- [ ] **测试Priority**: `SCHED_ALGORITHM 3` → `make clean && make qemu`

**记录每个算法的**：
- 调度器名称（`sched class: xxx`）
- 完成顺序（`sched result:` 后面的数字）
- 执行时间

---

## 💡 预期结果示例

### priority测试程序（5个进程，优先级5,4,3,2,1）

**RR算法**:
```
sched class: RR_scheduler
sched result: 5 4 3 2 1  (可能不是严格按优先级)
```

**Stride算法**:
```
sched class: stride_scheduler  
sched result: 5 4 3 2 1  (高优先级先完成)
```

**FIFO算法**:
```
sched class: FIFO_scheduler
sched result: 5 4 3 2 1  (按创建顺序)
```

**Priority算法**:
```
sched class: priority_scheduler
sched result: 5 4 3 2 1  (严格按优先级)
```

---

## 📁 相关文件

- `kern/schedule/sched.c` - 调度器选择（修改这里切换算法）
- `kern/schedule/default_sched.c` - RR实现
- `kern/schedule/default_sched_stride.c` - Stride实现
- `kern/schedule/sched_FIFO.c` - FIFO实现
- `kern/schedule/sched_priority.c` - Priority实现
- `tools/test_all_schedulers.bat` - Windows测试脚本
- `tools/test_schedulers.sh` - Linux测试脚本
- `docs/TEST_GUIDE.md` - 详细测试指南

---

*快速开始指南 - Lab6 Challenge 2*

