#include <sbi.h>
#include <console.h>

/* kbd_intr - try to feed input characters from keyboard */
//键盘中断处理函数
void kbd_intr(void) {}

/* serial_intr - try to feed input characters from serial port */
//串口中断处理函数
void serial_intr(void) {}

/* cons_init - initializes the console devices */
//控制台初始化函数
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
//输出字符串
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }

/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
//输入字符串
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
    return c;
}
