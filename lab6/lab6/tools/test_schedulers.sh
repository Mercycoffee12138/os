#!/bin/bash

#
# test_schedulers.sh - 调度算法测试与比较脚本
# 
# LAB6 CHALLENGE 2: 2310137
#
# 用法: ./tools/test_schedulers.sh [algorithm]
#   algorithm: 0=RR, 1=Stride, 2=FIFO, 3=Priority, all=测试所有
#
# 该脚本会：
# 1. 编译指定的调度算法
# 2. 运行测试程序
# 3. 收集并分析输出结果
# 4. 比较不同调度算法的性能指标
#

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 调度算法名称
declare -a SCHED_NAMES=("RR (Round Robin)" "Stride" "FIFO" "Priority")

# 输出目录
OUTPUT_DIR="sched_test_results"
mkdir -p $OUTPUT_DIR

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Scheduling Algorithm Test Suite${NC}"
echo -e "${BLUE}   LAB6 CHALLENGE 2: 2310137${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 测试单个调度算法
test_scheduler() {
    local algo=$1
    local name="${SCHED_NAMES[$algo]}"
    
    echo -e "${YELLOW}Testing: $name (Algorithm $algo)${NC}"
    echo "----------------------------------------"
    
    # 修改sched.c中的SCHED_ALGORITHM
    sed -i "s/#define SCHED_ALGORITHM [0-9]/#define SCHED_ALGORITHM $algo/" kern/schedule/sched.c
    
    # 清理并重新编译
    make clean > /dev/null 2>&1
    make > /dev/null 2>&1
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Compilation failed for $name${NC}"
        return 1
    fi
    
    # 运行测试，使用timeout限制时间
    echo "Running test with $name scheduler..."
    
    timeout 60 qemu-system-riscv64 \
        -machine virt \
        -nographic \
        -bios default \
        -device loader,file=bin/ucore.img,addr=0x80200000 \
        2>&1 | tee "$OUTPUT_DIR/output_algo_$algo.log"
    
    echo ""
    echo -e "${GREEN}Test completed for $name${NC}"
    echo ""
}

# 分析结果
analyze_results() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}      Results Analysis Summary${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    
    for algo in 0 1 2 3; do
        local name="${SCHED_NAMES[$algo]}"
        local logfile="$OUTPUT_DIR/output_algo_$algo.log"
        
        if [ -f "$logfile" ]; then
            echo -e "${YELLOW}$name:${NC}"
            
            # 提取关键信息
            echo "  Scheduler: $(grep 'sched class:' $logfile | head -1)"
            
            # 提取完成顺序（如果存在）
            local order=$(grep 'Finish Order:' $logfile)
            if [ -n "$order" ]; then
                echo "  $order"
            fi
            
            # 提取平均周转时间
            local avg=$(grep 'Average Turnaround' $logfile)
            if [ -n "$avg" ]; then
                echo "  $avg"
            fi
            
            echo ""
        fi
    done
}

# 生成比较报告
generate_report() {
    local report="$OUTPUT_DIR/comparison_report.txt"
    
    echo "Scheduling Algorithm Comparison Report" > $report
    echo "=======================================" >> $report
    echo "Generated: $(date)" >> $report
    echo "" >> $report
    
    echo "Test Configuration:" >> $report
    echo "- Number of processes: 5" >> $report
    echo "- Priorities: 5, 4, 3, 2, 1" >> $report
    echo "- Workloads: varying" >> $report
    echo "" >> $report
    
    echo "Algorithm Characteristics:" >> $report
    echo "" >> $report
    
    echo "1. RR (Round Robin):" >> $report
    echo "   - Fair CPU sharing" >> $report
    echo "   - Good response time" >> $report
    echo "   - Does not consider priority" >> $report
    echo "" >> $report
    
    echo "2. Stride Scheduling:" >> $report
    echo "   - Proportional CPU sharing" >> $report
    echo "   - Respects priority" >> $report
    echo "   - Deterministic behavior" >> $report
    echo "" >> $report
    
    echo "3. FIFO:" >> $report
    echo "   - Simple implementation" >> $report
    echo "   - No preemption" >> $report
    echo "   - May cause convoy effect" >> $report
    echo "" >> $report
    
    echo "4. Priority Scheduling:" >> $report
    echo "   - High priority first" >> $report
    echo "   - May cause starvation" >> $report
    echo "   - Good for real-time tasks" >> $report
    echo "" >> $report
    
    echo -e "${GREEN}Report generated: $report${NC}"
}

# 主程序
main() {
    local algo=$1
    
    if [ "$algo" = "all" ] || [ -z "$algo" ]; then
        # 测试所有调度算法
        for i in 0 1 2 3; do
            test_scheduler $i
        done
        analyze_results
        generate_report
    elif [ "$algo" -ge 0 ] && [ "$algo" -le 3 ]; then
        # 测试指定的调度算法
        test_scheduler $algo
    else
        echo "Usage: $0 [algorithm]"
        echo "  algorithm: 0=RR, 1=Stride, 2=FIFO, 3=Priority, all=test all"
        exit 1
    fi
}

main "$@"

