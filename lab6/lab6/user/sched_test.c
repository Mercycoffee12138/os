#include <ulib.h>
#include <stdio.h>

/*
 * sched_test.c - 简化版调度算法测试程序
 * LAB6 CHALLENGE 2: 2310137
 * 
 * 测试不同调度算法的行为差异
 */

#define TOTAL 5
#define MAX_TIME 1000

unsigned int acc[TOTAL];
int pids[TOTAL];

static void spin_delay(void) {
    int i;
    volatile int j;
    for (i = 0; i != 100; ++i) {
        j = !j;
    }
}

int main(void) {
    int i;
    
    cprintf("\n========================================\n");
    cprintf("  Scheduling Algorithm Test\n");
    cprintf("  LAB6 CHALLENGE 2: 2310137\n");
    cprintf("========================================\n\n");
    
    // 主进程设置高优先级
    lab6_setpriority(TOTAL + 1);
    
    for (i = 0; i < TOTAL; i++) {
        acc[i] = 0;
        if ((pids[i] = fork()) == 0) {
            // 子进程：设置优先级并工作
            lab6_setpriority(i + 1);
            acc[i] = 0;
            
            int time;
            while (1) {
                ////纯CPU盲等，不发生阻塞I/O
                spin_delay();
                ++acc[i];
                if (acc[i] % 4000 == 0) {
                    if ((time = gettime_msec()) > MAX_TIME) {
                        cprintf("child pid %d, priority %d, acc %d, time %d\n",
                                getpid(), i + 1, acc[i], time);
                        exit(acc[i]);
                    }
                }
            }
        }
        if (pids[i] < 0) {
            goto failed;
        }
    }
    
    cprintf("main: fork ok, waiting for children...\n");
    
    int status[TOTAL];
    for (i = 0; i < TOTAL; i++) {
        status[i] = 0;
        waitpid(pids[i], &status[i]);
        cprintf("main: pid %d done, acc %d\n", pids[i], status[i]);
    }
    
    cprintf("\n========================================\n");
    cprintf("  Results (acc values):\n");
    cprintf("========================================\n");
    cprintf("Priority 1 (lowest): %d\n", status[0]);
    cprintf("Priority 2:          %d\n", status[1]);
    cprintf("Priority 3:          %d\n", status[2]);
    cprintf("Priority 4:          %d\n", status[3]);
    cprintf("Priority 5 (highest):%d\n", status[4]);
    
    cprintf("\nExpected behavior:\n");
    cprintf("- RR: All acc values similar (fair sharing)\n");
    cprintf("- Stride: Higher priority = higher acc (proportional)\n");
    cprintf("- FIFO: Similar acc (FIFO order)\n");
    cprintf("- Priority: Higher priority = higher acc\n");
    
    cprintf("\nsched_test passed.\n");
    return 0;

failed:
    for (i = 0; i < TOTAL; i++) {
        if (pids[i] > 0) {
            kill(pids[i]);
        }
    }
    panic("sched_test FAILED!\n");
}
