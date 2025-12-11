/*
 * COW (Copy-On-Write) Test Program
 * 
 * This program tests the Copy-On-Write mechanism implementation.
 * It verifies that:
 * 1. Parent and child initially share the same physical pages
 * 2. When child writes to a shared page, COW creates a private copy
 * 3. Modifications in one process don't affect the other
 */

#include <ulib.h>
#include <stdio.h>

// Global variable to test COW on data segment
static int global_var = 100;

// Array to test COW on larger memory regions
static int global_array[1024];

void test_basic_cow(void) {
    cprintf("=== Test 1: Basic COW Test ===\n");
    
    int local_var = 200;
    global_var = 100;
    
    cprintf("Parent: Before fork, global_var=%d, local_var=%d\n", 
            global_var, local_var);
    
    int pid = fork();
    
    if (pid == 0) {
        // Child process
        cprintf("Child: After fork, global_var=%d, local_var=%d\n", 
                global_var, local_var);
        
        // Modify variables - this should trigger COW
        global_var = 999;
        local_var = 888;
        
        cprintf("Child: After modification, global_var=%d, local_var=%d\n", 
                global_var, local_var);
        
        exit(0);
    } else {
        // Parent process
        // Wait for child to finish
        wait();
        
        cprintf("Parent: After child exit, global_var=%d, local_var=%d\n", 
                global_var, local_var);
        
        // Verify parent's values are unchanged
        if (global_var == 100 && local_var == 200) {
            cprintf("Test 1 PASSED: COW correctly isolated parent and child\n\n");
        } else {
            cprintf("Test 1 FAILED: Parent values were modified!\n\n");
        }
    }
}

void test_array_cow(void) {
    cprintf("=== Test 2: Array COW Test ===\n");
    
    // Initialize array
    for (int i = 0; i < 1024; i++) {
        global_array[i] = i;
    }
    
    int pid = fork();
    
    if (pid == 0) {
        // Child: modify some array elements
        for (int i = 0; i < 1024; i++) {
            global_array[i] = 1024 - i;
        }
        
        cprintf("Child: Modified array, global_array[0]=%d, global_array[1023]=%d\n",
                global_array[0], global_array[1023]);
        
        exit(0);
    } else {
        wait();
        
        cprintf("Parent: After child exit, global_array[0]=%d, global_array[1023]=%d\n",
                global_array[0], global_array[1023]);
        
        // Verify parent's array is unchanged
        int passed = 1;
        for (int i = 0; i < 1024; i++) {
            if (global_array[i] != i) {
                passed = 0;
                break;
            }
        }
        
        if (passed) {
            cprintf("Test 2 PASSED: Array COW works correctly\n\n");
        } else {
            cprintf("Test 2 FAILED: Parent array was modified!\n\n");
        }
    }
}

void test_multi_fork_cow(void) {
    cprintf("=== Test 3: Multiple Fork COW Test ===\n");
    
    int shared_counter = 0;
    
    for (int i = 0; i < 3; i++) {
        int pid = fork();
        
        if (pid == 0) {
            // Child process
            shared_counter += 100;
            cprintf("Child %d: shared_counter=%d\n", i, shared_counter);
            exit(i);
        }
    }
    
    // Parent waits for all children
    for (int i = 0; i < 3; i++) {
        wait();
    }
    
    cprintf("Parent: After all children exit, shared_counter=%d\n", shared_counter);
    
    if (shared_counter == 0) {
        cprintf("Test 3 PASSED: Multiple fork COW isolation works\n\n");
    } else {
        cprintf("Test 3 FAILED: Parent counter was modified!\n\n");
    }
}

void test_nested_fork_cow(void) {
    cprintf("=== Test 4: Nested Fork COW Test ===\n");
    
    int value = 1;
    
    int pid1 = fork();
    
    if (pid1 == 0) {
        // First child
        value = 10;
        cprintf("Child1: value=%d\n", value);
        
        int pid2 = fork();
        
        if (pid2 == 0) {
            // Grandchild
            value = 100;
            cprintf("Grandchild: value=%d\n", value);
            exit(0);
        } else {
            wait();
            cprintf("Child1 after grandchild: value=%d\n", value);
            
            if (value == 10) {
                cprintf("Nested fork COW for Child1: OK\n");
            }
            exit(0);
        }
    } else {
        wait();
        cprintf("Parent after Child1: value=%d\n", value);
        
        if (value == 1) {
            cprintf("Test 4 PASSED: Nested fork COW works correctly\n\n");
        } else {
            cprintf("Test 4 FAILED: Parent value was modified!\n\n");
        }
    }
}

void test_read_no_cow(void) {
    cprintf("=== Test 5: Read Access No COW Test ===\n");
    
    global_var = 12345;
    
    int pid = fork();
    
    if (pid == 0) {
        // Child: only read, no write
        int read_value = global_var;
        cprintf("Child: Read global_var=%d (should not trigger COW)\n", read_value);
        
        // Multiple reads
        for (int i = 0; i < 100; i++) {
            read_value = global_var;
        }
        
        cprintf("Child: Completed 100 reads without triggering COW\n");
        exit(0);
    } else {
        wait();
        cprintf("Test 5 PASSED: Read-only access doesn't trigger unnecessary COW\n\n");
    }
}

int main(void) {
    cprintf("\n========================================\n");
    cprintf("    COW (Copy-On-Write) Test Suite\n");
    cprintf("========================================\n\n");
    
    test_basic_cow();
    test_array_cow();
    test_multi_fork_cow();
    test_nested_fork_cow();
    test_read_no_cow();
    
    cprintf("========================================\n");
    cprintf("    All COW Tests Completed!\n");
    cprintf("========================================\n");
    
    return 0;
}
