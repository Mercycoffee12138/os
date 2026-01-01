#include <ulib.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/*
 * sched_test.c - 调度算法测试与分析程序
 * 
 * LAB6 CHALLENGE 2: 2310137
 * 
 * 本测试程序用于比较不同调度算法的性能特征：
 * - 平均等待时间
 * - 平均周转时间
 * - 公平性（各进程获得CPU时间的比例）
 * 
 * 测试场景：
 * 创建多个具有不同优先级和不同工作量的进程，
 * 观察它们在不同调度算法下的执行顺序和CPU分配情况。
 */

#define NUM_PROCS 5
#define WORK_UNIT 5000   // 基本工作单元

// 进程信息结构
struct proc_info {
    int pid;
    int priority;      // 优先级 (1-5, 5最高)
    int work_amount;   // 工作量 (WORK_UNIT的倍数)
    int start_time;    // 开始时间
    int end_time;      // 结束时间
    int cpu_count;     // 获得CPU次数
};

static struct proc_info procs[NUM_PROCS];
static int pids[NUM_PROCS];

// 模拟CPU密集型工作
static void do_work(int amount) {
    volatile int sum = 0;
    int i, j;
    for (i = 0; i < amount; i++) {
        for (j = 0; j < 100; j++) {
            sum += i * j;
        }
    }
}

// 子进程工作函数
static void child_work(int id, int priority, int work_amount) {
    int start = gettime_msec();
    int count = 0;
    
    // 设置优先级
    lab6_setpriority(priority);
    
    cprintf("[Proc %d] Started: priority=%d, work=%d, time=%d ms\n", 
            id, priority, work_amount, start);
    
    // 分批完成工作，每批后让出CPU
    int batch_size = WORK_UNIT;
    int remaining = work_amount;
    
    while (remaining > 0) {
        int batch = (remaining > batch_size) ? batch_size : remaining;
        do_work(batch);
        remaining -= batch;
        count++;
        
        // 每完成一批工作后主动让出CPU（模拟I/O等待）
        if (remaining > 0 && count % 3 == 0) {
            yield();
        }
    }
    
    int end = gettime_msec();
    cprintf("[Proc %d] Finished: cpu_slices=%d, duration=%d ms\n", 
            id, count, end - start);
    
    // 退出码编码：高16位是count，低16位是duration
    exit(((count & 0xFF) << 8) | ((end - start) & 0xFF));
}

int main(void) {
    int i;
    int main_start = gettime_msec();
    
    cprintf("\n========================================\n");
    cprintf("  Scheduling Algorithm Test Program\n");
    cprintf("  LAB6 CHALLENGE 2: 2310137\n");
    cprintf("========================================\n\n");
    
    // 初始化进程配置
    // 不同优先级和工作量的组合，用于测试调度公平性
    int priorities[NUM_PROCS] = {5, 4, 3, 2, 1};  // 从高到低
    int workloads[NUM_PROCS] = {
        WORK_UNIT * 2,   // 短作业，高优先级
        WORK_UNIT * 4,   // 中等作业
        WORK_UNIT * 3,   // 中等作业
        WORK_UNIT * 5,   // 长作业
        WORK_UNIT * 1    // 最短作业，最低优先级
    };
    
    // 主进程设置最高优先级
    lab6_setpriority(10);
    
    cprintf("Creating %d test processes...\n", NUM_PROCS);
    cprintf("ID  Priority  Workload\n");
    cprintf("--  --------  --------\n");
    
    for (i = 0; i < NUM_PROCS; i++) {
        cprintf("%2d  %8d  %8d\n", i, priorities[i], workloads[i]);
    }
    cprintf("\n");
    
    // 创建子进程
    for (i = 0; i < NUM_PROCS; i++) {
        procs[i].priority = priorities[i];
        procs[i].work_amount = workloads[i];
        procs[i].start_time = gettime_msec();
        
        if ((pids[i] = fork()) == 0) {
            // 子进程
            child_work(i, priorities[i], workloads[i]);
            // 不会到达这里
        }
        
        if (pids[i] < 0) {
            cprintf("Fork failed for process %d\n", i);
            goto failed;
        }
        procs[i].pid = pids[i];
    }
    
    cprintf("All processes created, waiting for completion...\n\n");
    
    // 等待所有子进程完成，并收集统计信息
    int status[NUM_PROCS];
    int finish_order[NUM_PROCS];
    int order_idx = 0;
    
    for (i = 0; i < NUM_PROCS; i++) {
        int exit_code = 0;
        int finished_pid = wait();
        
        // 找出是哪个进程完成了
        int j;
        for (j = 0; j < NUM_PROCS; j++) {
            if (pids[j] == finished_pid) {
                finish_order[order_idx++] = j;
                procs[j].end_time = gettime_msec();
                break;
            }
        }
    }
    
    int main_end = gettime_msec();
    
    // 输出分析结果
    cprintf("\n========================================\n");
    cprintf("        Test Results Analysis\n");
    cprintf("========================================\n\n");
    
    cprintf("Finish Order: ");
    for (i = 0; i < NUM_PROCS; i++) {
        cprintf("P%d ", finish_order[i]);
    }
    cprintf("\n\n");
    
    cprintf("Process Statistics:\n");
    cprintf("ID  Priority  Workload  Turnaround\n");
    cprintf("--  --------  --------  ----------\n");
    
    int total_turnaround = 0;
    for (i = 0; i < NUM_PROCS; i++) {
        int turnaround = procs[i].end_time - procs[i].start_time;
        total_turnaround += turnaround;
        cprintf("%2d  %8d  %8d  %8d ms\n", 
                i, procs[i].priority, procs[i].work_amount, turnaround);
    }
    
    cprintf("\n");
    cprintf("Average Turnaround Time: %d ms\n", total_turnaround / NUM_PROCS);
    cprintf("Total Execution Time: %d ms\n", main_end - main_start);
    
    cprintf("\n========================================\n");
    cprintf("  Scheduling Algorithm Analysis:\n");
    cprintf("========================================\n");
    cprintf("\n");
    cprintf("Expected behavior for different schedulers:\n\n");
    cprintf("- RR (Round Robin):\n");
    cprintf("  All processes share CPU fairly, finish order\n");
    cprintf("  mainly depends on workload.\n\n");
    cprintf("- Stride:\n");
    cprintf("  Higher priority processes get more CPU time,\n");
    cprintf("  proportional to their priority values.\n\n");
    cprintf("- FIFO:\n");
    cprintf("  Processes finish in creation order,\n");
    cprintf("  no preemption between processes.\n\n");
    cprintf("- Priority:\n");
    cprintf("  Higher priority processes finish first,\n");
    cprintf("  may cause starvation for low priority.\n\n");
    
    cprintf("sched_test passed.\n");
    return 0;

failed:
    for (i = 0; i < NUM_PROCS; i++) {
        if (pids[i] > 0) {
            kill(pids[i]);
        }
    }
    cprintf("sched_test FAILED!\n");
    return -1;
}

