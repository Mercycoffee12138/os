**问题：**

## 扩展练习Challenge：硬件的可用物理内存范围的获取方法（思考题）

**如果 OS 无法提前知道当前硬件的可用物理内存范围，请问你有何办法让 OS 获取可用物理内存范围？**



**回答：**

当 **OS 启动时还不知道系统有多少物理内存、哪些地址可用、哪些保留**等，它就必须想办法**探测可用物理内存范围**。

------

## 一、问题背景

在操作系统刚启动时：

- 内核尚未建立页表；
- 也没有文件系统；
- 更不能去“读配置文件”。

此时唯一能用的就是**CPU + 固件（BIOS / UEFI）+ 启动引导程序（Bootloader）**。

因此 —— OS 自己是看不见内存的，它必须通过 **引导加载器（Bootloader）或固件接口** 获取物理内存布局（memory map）。

------

## 二、常见的物理内存探测方法

### 方法 1：通过 Bootloader（最常见）

几乎所有现代 OS（包括 Linux、ucore、Windows）都依赖 **Bootloader（如 GRUB、U-Boot）** 在启动时**把物理内存信息传递给内核**。

#### 具体流程：

1. **Bootloader 调用 BIOS/UEFI 的接口** 获取系统内存布局；
2. Bootloader 把“可用内存段列表”传递给内核（一般放在启动参数区）；
3. OS 内核启动时从该区域读取信息，完成物理内存探测。

------

### 方法 2：通过 BIOS 中断（仅适用于实模式阶段）

如果是 **x86 架构** 并且系统在实模式下运行，可以直接调用 **BIOS 中断 `INT 15h`，功能号 `E820h`**：

```asm
mov eax, 0xE820
mov edx, 'SMAP'
mov ecx, 24
int 0x15
```

**作用：**返回系统内存布局表，每一项包含：

| 字段                       | 含义                                     |
| -------------------------- | ---------------------------------------- |
| BaseAddrLow / BaseAddrHigh | 内存段起始地址                           |
| LengthLow / LengthHigh     | 段长度                                   |
| Type                       | 类型（1=可用，2=保留，3=ACPI，4=NVS 等） |

内核可以读取这些段来确定哪些物理地址可用、哪些被 BIOS/硬件保留。Linux、ucore、XV6 等在早期版本都使用此方式。

------

### 方法 3：通过 UEFI 系统表

在 **现代 64 位系统** 中，BIOS 已被 **UEFI** 替代。此时可以通过 `UEFI Boot Services` 的 `GetMemoryMap()` 获取内存信息。

```c
EFI_MEMORY_DESCRIPTOR *map;
UINTN map_size, map_key, desc_size;
UINT32 desc_version;
gBS->GetMemoryMap(&map_size, map, &map_key, &desc_size, &desc_version);
```

> 返回结果同样是一张**内存描述表**，记录各段物理地址及用途。

------

### 方法 4：硬编码假设

这种方法相对来说就很少见了，在一些教学实验（不是本操作系统课程的实验）中，为简化设计，如果不想使用 Bootloader 的复杂接口，也可以：

```c
#define PHYS_MEMORY_START 0x80000000
#define PHYS_MEMORY_END   0x88000000
```

直接假设内存大小为固定值（如 128MB），
 在 `pmm_init()` 阶段手动标记这些页为“可用”。

> 这种做法不灵活，但在教学内核中常见。

------

## 三、操作系统如何利用这些信息

获取可用内存范围后，内核就能：

1. **建立页框管理结构（如 Page 数组）**；
2. **标记每个物理页的状态（free / used / reserved）**；
3. **初始化物理页分配器（如 Challenge1中的Buddy System）**；
4. **为内核建立初始页表（虚拟地址 → 物理地址）**。

这也是老师在课上重点讲授的内容。

------

## 四、总结对比表

| 方法            | 适用场景   | 获取来源      | 特点                   |
| --------------- | ---------- | ------------- | ---------------------- |
| BIOS E820 中断  | x86 实模式 | BIOS          | 经典可靠，但仅限老系统 |
| Bootloader 传递 | 通用       | GRUB / U-Boot | OS 独立、通用          |
| UEFI Memory Map | 现代系统   | UEFI Firmware | 新标准                 |
| 固定地址假设    | 实验系统   | 代码硬编码    | 简单但不灵活           |

------

## 五、ucore 实验中通常的做法

在 ucore 的 `lab2`（物理内存管理）实验中，系统也可以通过 **Bootloader 提供的 e820 内存信息表** 获取物理内存范围：

```c
// boot/bootasm.S 或 boot/main.c
// 通过 BIOS 中断 INT 15h 获取 e820 map，传递给内核

// 内核部分
void pmm_init(void) {
    // 从 e820_map 读取内存段信息
    for (i = 0; i < e820.nr_map; i++) {
        if (e820.map[i].type == E820_ARM) {
            // 记录可用内存段
        }
    }
}
```

这样 OS 就能动态探测出机器的真实物理内存。

------

**总而言之**：

当 OS 无法提前知道物理内存范围时，它必须借助 **Bootloader / BIOS / UEFI 提供的内存映射信息（Memory Map）** 来

探测系统可用物理内存。这些信息在内核启动早期读取并用于初始化物理内存管理结构。
