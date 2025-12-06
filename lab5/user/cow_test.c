#include <stdio.h>
#include <ulib.h>

/* COW 测试程序 */

int data[1024];  // 4KB 数据，用于 COW 测试

int
main(void) {
    cprintf("==== COW (Copy-on-Write) Test ====\n\n");
    
    // 初始化数据
    int i;
    for (i = 0; i < 1024; i++) {
        data[i] = i;
    }
    
    cprintf("[TEST 1] Basic COW - Parent and Child\n");
    int pid = fork();
    
    if (pid == 0) {
        // 子进程
        cprintf("[CHILD] Checking initial value: data[0]=%d (expected 0)\n", data[0]);
        assert(data[0] == 0);
        
        // 修改数据，触发 COW
        cprintf("[CHILD] Writing data[0]=999...\n");
        data[0] = 999;
        
        cprintf("[CHILD] After write: data[0]=%d\n", data[0]);
        assert(data[0] == 999);
        
        cprintf("[CHILD] Exit OK\n");
        exit(0);
        
    } else if (pid > 0) {
        // 父进程等待子进程
        cprintf("[PARENT] Waiting for child...\n");
        assert(waitpid(pid, NULL) == 0);
        
        // 验证父进程的数据未被修改
        cprintf("[PARENT] After child exit: data[0]=%d (expected 0)\n", data[0]);
        assert(data[0] == 0);
        
        cprintf("[PARENT] COW Protection OK\n\n");
        
    } else {
        panic("fork failed");
    }
    
    // TEST 2: 多个子进程
    cprintf("[TEST 2] Multiple Children COW\n");
    int child_pids[3];
    
    // 初始化
    for (i = 0; i < 3; i++) {
        data[i] = 100 + i;
    }
    
    for (i = 0; i < 3; i++) {
        int p = fork();
        if (p == 0) {
            // 子进程修改各自的数据
            int idx = i;
            cprintf("[CHILD %d] Modifying data[%d]\n", getpid(), idx);
            data[idx] = 1000 + idx;
            
            cprintf("[CHILD %d] data[%d]=%d\n", getpid(), idx, data[idx]);
            assert(data[idx] == 1000 + idx);
            exit(0);
            
        } else if (p > 0) {
            child_pids[i] = p;
        } else {
            panic("fork failed");
        }
    }
    
    // 等待所有子进程
    for (i = 0; i < 3; i++) {
        cprintf("[PARENT] Waiting for child %d\n", child_pids[i]);
        assert(waitpid(child_pids[i], NULL) == 0);
    }
    
    // 验证父进程数据保持不变
    for (i = 0; i < 3; i++) {
        cprintf("[PARENT] data[%d]=%d (expected %d)\n", i, data[i], 100 + i);
        assert(data[i] == 100 + i);
    }
    
    cprintf("[PARENT] All children isolated OK\n\n");
    
    // TEST 3: 嵌套 fork
    cprintf("[TEST 3] Nested Fork COW\n");
    
    data[0] = 50;
    data[1] = 51;
    
    int pid1 = fork();
    if (pid1 == 0) {
        // 第一级子进程
        cprintf("[L1-CHILD] Modifying data[0]=150\n");
        data[0] = 150;
        
        int pid2 = fork();
        if (pid2 == 0) {
            // 第二级子进程
            cprintf("[L2-CHILD] Modifying data[1]=250\n");
            data[1] = 250;
            
            assert(data[0] == 150);
            assert(data[1] == 250);
            cprintf("[L2-CHILD] Exit OK\n");
            exit(0);
            
        } else if (pid2 > 0) {
            assert(waitpid(pid2, NULL) == 0);
            
            // 验证第一级子进程的数据
            cprintf("[L1-CHILD] After L2-CHILD: data[0]=%d, data[1]=%d\n", 
                    data[0], data[1]);
            assert(data[0] == 150);
            assert(data[1] == 51);  // 未被修改
            cprintf("[L1-CHILD] Exit OK\n");
            exit(0);
        } else {
            panic("fork failed");
        }
        
    } else if (pid1 > 0) {
        assert(waitpid(pid1, NULL) == 0);
        
        // 验证父进程数据未被修改
        cprintf("[PARENT] After nested fork: data[0]=%d, data[1]=%d\n",
                data[0], data[1]);
        assert(data[0] == 50);
        assert(data[1] == 51);
        cprintf("[PARENT] Nested fork OK\n\n");
        
    } else {
        panic("fork failed");
    }
    
    cprintf("==== ALL COW TESTS PASSED ====\n");
    return 0;
}
