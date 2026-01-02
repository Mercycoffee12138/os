# Lab8 实验报告

## 练习1：完成读文件操作的实现

### 调用链分析：从 read 到 sfs_io_nolock

文件读操作的完整调用链如下：

1. **用户态**：
   - `read(fd, data, len)` 用户进程发起读请求。
   - 实际调用 `sys_read(fd, data, len)` 进入内核。

2. **系统调用/文件系统抽象层**：
   - `sys_read` 解析参数，调用 `sysfile_read(fd, base, len)`。
   - `sysfile_read` 检查参数、分配内核 buffer，循环调用 `file_read` 读取数据。
   - `file_read` 通过 `fd2file` 获取文件结构体，初始化 iobuf，调用 `vop_read(file->node, iob)`。

3. **VFS 层**：
   - `vop_read` 是一个宏，实际会调用具体文件系统的 `inode_ops->vop_read`，对于 SFS 文件系统就是 `sfs_read`。

4. **SFS 文件系统层**：
   - `sfs_read` 调用 `sfs_io(node, iob, 0)`，加锁后调用 `sfs_io_nolock` 完成实际读操作。
   - `sfs_io_nolock` 负责分块处理数据，最终通过 `sfs_bmap_load_nolock`、`sfs_rbuf`、`sfs_rblock` 等函数实现磁盘到内存的数据传输。

**简要流程图：**

```
read
  ↓
sys_read
  ↓
sysfile_read
  ↓
file_read
  ↓
vop_read (→ sfs_read)
  ↓
sfs_io
  ↓
sfs_io_nolock
```

这样，用户的 read 请求最终会通过多层抽象，落到 SFS 文件系统的 sfs_io_nolock 函数，完成实际的文件数据读取。

### 原理分析

在基于文件系统的操作系统中，文件读操作是一个核心功能。`sfs_io_nolock()` 函数实现了对Simple File System (SFS)中文件内容的读写操作。该函数的核心作用是将磁盘块中的数据与内存中的缓冲区进行交互。

**关键概念：**

- **块对齐问题**：文件系统以固定大小的块（SFS_BLKSIZE）为单位存储数据，但用户的读写请求可能不与块边界对齐
- **三阶段处理**：为了处理非对齐读写，需要分三个阶段进行：
  1. 首块不对齐处理：如果偏移量不是块大小的倍数，先处理首块中的部分数据
  2. 中间完整块处理：处理完全对齐的中间块，可以批量操作提高性能
  3. 末块不对齐处理：处理最后一块中的部分数据

### 实现代码

在 `kern/fs/sfs/sfs_inode.c` 的 `sfs_io_nolock()` 函数中，实现了完整的三阶段读写逻辑：

```c
// (1) 处理首块不对齐的情况
if (blkoff != 0) {
    size = (nblks != 0) ? (SFS_BLKSIZE - blkoff) : (endpos - offset);
    if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
        goto out;
    }
    if ((ret = sfs_buf_op(sfs, buf, size, ino, blkoff)) != 0) {
        goto out;
    }
    alen += size;
    buf += size;
    if (nblks == 0) {
        goto out;
    }
    blkno++;
    nblks--;
}

// (2) 处理中间完整块
if (nblks > 0) {
    if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
        goto out;
    }
    if ((ret = sfs_block_op(sfs, buf, ino, nblks)) != 0) {
        goto out;
    }
    alen += nblks * SFS_BLKSIZE;
    buf += nblks * SFS_BLKSIZE;
    blkno += nblks;
    nblks = 0;
}

// (3) 处理末块不对齐的情况
if ((size = endpos % SFS_BLKSIZE) != 0) {
    if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
        goto out;
    }
    if ((ret = sfs_buf_op(sfs, buf, size, ino, 0)) != 0) {
        goto out;
    }
    alen += size;
}
```

**关键函数说明：**

- `sfs_bmap_load_nolock()`：根据逻辑块号获取实际物理块号
- `sfs_buf_op()`：处理部分块的读写（指向 `sfs_rbuf` 或 `sfs_wbuf`）
- `sfs_block_op()`：批量读写完整块（指向 `sfs_rblock` 或 `sfs_wblock`）

---

## 练习2：完成基于文件系统的执行程序机制的实现

### 原理分析

在Lab5中实现的 `load_icode()` 函数是从内存中加载ELF格式的二进制程序。而Lab8要求将程序存储在文件系统中，通过文件描述符（fd）来加载程序。这需要修改 `load_icode()` 函数的参数和内部实现，使其能够：

1. **动态读取ELF头**：从文件中读取ELF头，而不是从内存buffer中
2. **动态读取程序头表**：根据ELF头信息读取程序头表
3. **逐段加载程序**：将TEXT/DATA/BSS段从文件读入内存

### 实现代码

#### 1. 文件读取辅助函数

在 `kern/process/proc.c` 中添加了 `load_icode_read()` 函数：

```c
static int
load_icode_read(int fd, void *buf, size_t len, off_t offset)
{
    int ret;
    // 使用 sysfile_seek 定位到文件偏移量
    if ((ret = sysfile_seek(fd, offset, LSEEK_SET)) != 0)
    {
        return ret;
    }
    // 使用 sysfile_read 从文件读取数据
    if ((ret = sysfile_read(fd, buf, len)) != len)
    {
        return (ret < 0) ? ret : -1;
    }
    return 0;
}
```

该函数封装了从文件特定偏移量读取数据的操作，使用 `sysfile_seek()` 和 `sysfile_read()` 系统调用。

#### 2. 主要加载函数

修改后的 `load_icode()` 函数采用与Lab5相同的八步骤框架，但关键改变是：

- 参数从 `(unsigned char *binary, size_t size)` 改为 `(int fd, int argc, char **kargv)`
- 使用 `load_icode_read()` 动态读取ELF信息，而非直接访问内存

**(1) 创建新的内存管理结构**

```c
struct mm_struct *mm;
if ((mm = mm_create()) == NULL) {
    goto bad_mm;
}
```

**(2) 设置页目录**

```c
if (setup_pgdir(mm) != 0) {
    goto bad_pgdir_cleanup_mm;
}
```

**(3.1) 从文件读取并解析ELF头**

```c
struct elfhdr elf_buf;
struct elfhdr *elf = &elf_buf;
if ((ret = load_icode_read(fd, elf, sizeof(struct elfhdr), 0)) != 0) {
    goto bad_pgdir_cleanup_mm;
}
```

**(3.2) 读取程序头表**

```c
struct proghdr *ph_orig = (struct proghdr *)kmalloc(sizeof(struct proghdr) * elf->e_phnum);
if (ph_orig == NULL) {
    goto bad_pgdir_cleanup_mm;
}
if ((ret = load_icode_read(fd, ph_orig, sizeof(struct proghdr) * elf->e_phnum, elf->e_phoff)) != 0) {
    goto bad_ph_cleanup_pgdir;
}
```

**((3.3)-(3.5) 加载各个程序段**
遍历每个程序头，对于 `ELF_PT_LOAD` 类型的段：

- 使用 `mm_map()` 为TEXT/DATA/BSS段建立虚拟地址映射
- 使用 `load_icode_read()` 从文件读取段数据到临时缓冲区
- 使用 `pgdir_alloc_page()` 为每个页面分配物理页
- 使用 `memcpy()` 将文件数据复制到物理页
- 使用 `memset()` 将BSS段清零

```c
unsigned char *from = (unsigned char *)kmalloc(ph->p_filesz);
if (from == NULL) {
    goto bad_cleanup_mmap;
}
if ((ret = load_icode_read(fd, from, ph->p_filesz, ph->p_offset)) != 0) {
    kfree(from);
    goto bad_cleanup_mmap;
}
```

### 调用链

- `do_execve()` → `load_icode(fd, argc, kargv)` → `load_icode_read()` → `sysfile_seek()`/`sysfile_read()`
- 最终通过VFS接口调用到 `sfs_io_nolock()` 进行实际的磁盘I/O操作

### 验证成功

程序成功运行的标志：

1. 能够看到sh用户shell的执行界面
2. 能够在sh中执行exit、hello等用户程序
3. 这些程序都存储在SFS文件系统中的 `disk0/`目录下
   简单测试了`hello`、`sh`、`sleep`、`divzero`、`exit`效果如下：
4. ![image-20260101111415676](C:\Users\13081\AppData\Roaming\Typora\typora-user-images\image-20260101111415676.png)

ps：`error: -16 - no such file or directory`是因为`divzero`我打成了`divezero`，所以没找到对应的程序（英语忘干净了）。

---

## 扩展练习 Challenge1：完成基于“UNIX 的 PIPE 机制”的设计方案

### 目标与语义

Pipe（管道）是一种典型的 UNIX 进程间通信（IPC）机制，用于在两个进程（常见场景是父子进程）之间建立“单向字节流”通道。`pipe()` 创建后返回两个文件描述符：读端 `rfd` 与写端 `wfd`。

- **读语义**：
  - 管道缓冲区为空且仍存在写端：`read()` 阻塞等待数据（或非阻塞模式返回 `-E_AGAIN`）。
  - 管道缓冲区为空且所有写端关闭：`read()` 返回 0（EOF）。
- **写语义**：
  - 管道缓冲区满且仍存在读端：`write()` 阻塞等待空间（或非阻塞模式返回 `-E_AGAIN`）。
  - 所有读端关闭：`write()` 失败（UNIX 上通常是 SIGPIPE；在 ucore 里可以简化为返回 `-E_PIPE`）。
- **继承/共享语义**：`fork()` 后子进程继承 fd，读端/写端引用计数应正确维护；`close()` 需递减引用并在最后一个引用关闭时释放对象。

### 至少需要的数据结构与接口设计

#### 1）关键数据结构（给出一个可实现的 C struct）

管道的核心是一个受保护的共享缓冲区（常见实现是环形队列），以及用于实现阻塞读写的等待队列/条件变量。

```c
#define PIPE_BUF_SIZE 4096

struct pipe_ring {
        char buf[PIPE_BUF_SIZE];
        size_t rpos;
        size_t wpos;
        size_t used;      // 当前已用字节数
};

typedef struct wait_queue wait_queue_t;

struct pipe_info {
        struct pipe_ring ring;

        // 引用计数：用于实现 EOF / EPIPE
        int readers;
        int writers;

        // 互斥保护：保护 ring/readers/writers 等共享状态
        volatile int lock;

        // 阻塞队列：无数据可读 / 无空间可写
        wait_queue_t rwait;
        wait_queue_t wwait;
};
```

设计说明：

- 读写操作都必须在 `lock` 保护下更新 `rpos/wpos/used`，避免并发破坏环形缓冲区状态。
- 写入数据后唤醒 `rwait`；读走数据后唤醒 `wwait`。
- `writers==0` 作为读端 EOF 判定；`readers==0` 作为写端 EPIPE 判定。

#### 2）接口（只需语义，不必实现）

- `int sys_pipe(int pipefd[2]);`
  - 创建一个 `pipe_info` 并分配两个 fd：`pipefd[0]` 为读端、`pipefd[1]` 为写端。
- `ssize_t sys_read(int fd, void *buf, size_t len);`
  - 若 `fd` 为管道读端：从 `pipe_info` 读取最多 `len` 字节。
  - 空且 `writers>0`：阻塞（或非阻塞返回 `-E_AGAIN`）；空且 `writers==0`：返回 0。
- `ssize_t sys_write(int fd, const void *buf, size_t len);`
  - 若 `fd` 为管道写端：向 `pipe_info` 写入最多 `len` 字节。
  - 满且 `readers>0`：阻塞（或非阻塞返回 `-E_AGAIN`）；`readers==0`：返回 `-E_PIPE`。
- `int sys_close(int fd);`
  - 关闭对应端并更新 `readers/writers`；必要时唤醒对端等待者；引用归零释放 `pipe_info`。

### 同步互斥问题与处理

- **互斥**：读写共享同一缓冲区，必须用锁保护临界区，保证 `used` 与指针更新一致。
- **条件等待**：在“缓冲区空/满”时要用 `while (cond) sleep()` 结构防止虚假唤醒；唤醒应发生在状态改变之后。
- **并发 close**：
  - 写端全部关闭后要唤醒 `rwait`，让读者返回 EOF。
  - 读端全部关闭后要唤醒 `wwait`，让写者返回 `-E_PIPE`。

---

## 扩展练习 Challenge2：完成基于“UNIX 的软连接和硬连接机制”的设计方案

### 目标与语义

UNIX 的链接机制建立在“目录项（name）→ inode（对象）”的映射之上。

- **硬链接（hard link）**：多个目录项指向同一个 inode（同一份数据）。删除一个目录项不会删除数据，直到 inode 的链接计数 `nlinks` 变为 0 且没有进程打开它。
- **软链接（symbolic link）**：创建一个新的 inode，inode 的内容保存一个“目标路径字符串”。路径解析遇到软链接时，需要将其目标路径继续解析，并限制最大解析深度避免循环。

### 至少需要的数据结构与接口设计

#### 1）硬链接：inode 增加链接计数（nlinks）

在具体文件系统（SFS）的磁盘 inode 中加入 `nlinks` 并持久化，内存 inode 缓存该字段用于快速判断回收条件。

```c
// 概念性结构：建议在 sfs_disk_inode 中增加 nlinks 字段并落盘
struct sfs_disk_inode {
        uint16_t type;
        uint16_t nlinks;   // 硬链接计数
        uint32_t size;
        // ... direct/indirect blocks ...
};
```

#### 2）软链接：新增 inode 类型 + 目标路径存储

软链接可以作为一种新的 inode 类型，例如 `SFS_TYPE_SYMLINK`。其数据区保存目标路径字符串：短路径可直接存在 inode 内（fast symlink），长路径再使用数据块。

```c
#define SYMLINK_MAX 256

struct sfs_symlink_info {
        uint16_t type;          // SFS_TYPE_SYMLINK
        uint16_t nlinks;        // symlink 自身也可以被硬链接
        uint16_t target_len;
        char target[SYMLINK_MAX];
};
```

#### 3）接口（只需语义，不必实现）

- `int sys_link(const char *oldpath, const char *newpath);`
  - 在 `newpath` 目录创建新目录项指向 `oldpath` 的 inode，令 `nlinks++`；通常禁止对目录硬链接。
- `int sys_unlink(const char *path);`
  - 删除目录项并令 inode `nlinks--`；当 `nlinks==0 && open_count==0` 时回收数据。
- `int sys_symlink(const char *target, const char *linkpath);`
  - 创建 symlink inode，写入 `target` 字符串，并在 `linkpath` 创建目录项指向它。
- `int sys_readlink(const char *path, char *buf, size_t buflen);`
  - 读取 symlink 保存的 `target` 内容到 `buf`，不解析目标路径。

#### 4）VFS 路径解析扩展要点

- 默认 `open/lookup` 跟随 symlink；可选支持 `O_NOFOLLOW`。
- 设置最大跟随深度（例如 8 或 16），防止循环链接导致无限递归。

### 同步互斥问题与处理

- **目录项更新原子性**：`link/unlink/symlink` 都会修改目录内容与 inode 元数据（`nlinks`），需要目录级别加锁，避免并发导致目录项丢失或 `nlinks` 错乱。
- **回收条件正确性**：`unlink` 时不能因为 `nlinks==0` 就立即回收，仍需等待 `open_count==0`。
- **解析过程的引用计数**：路径解析返回 inode 时需要 `inode_ref_inc` 保证生命周期，解析结束释放，避免并发删除带来的悬挂指针。

---

## 总结

Lab8通过两个练习完整实现了基于文件系统的操作系统核心机制：

- **练习1**确保了文件系统能高效地读写数据，处理块对齐等细节
- **练习2**利用文件读取能力，实现了从磁盘文件加载和执行用户程序，打通了从磁盘存储到内存执行的完整路径

这两个练习共同支撑了一个功能完整的类Unix操作系统，能够从磁盘文件系统启动和运行多个用户程序。
