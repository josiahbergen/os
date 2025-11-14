#include <kernel/tty.h>
#include <stdint.h>
#include <stdio.h>

#define LOG_COL_INFO 0x8
#define LOG_COL_LOG 0x7
#define LOG_COL_WARN 0xe
#define LOG_COL_ERROR 0xc
#define LOG_COL_PANIC 0xc
#define LOG_COL_SUCCESS 0x2

/*
Hex Binary  Color
0 	0000 	Black
1 	0001 	Blue
2   0010    Green
3   0011    Cyan
4   0100    Red
5   0101    Magenta
6   0110    Brown
7   0111    Light Gray
8 	1000 	Dark Gray
9 	1001 	Light Blue
A 	1010 	Light Green
B 	1011 	Light Cyan
C 	1100 	Light Red
D 	1101 	Light Magenta
E 	1110 	Yellow
F 	1111 	White
*/

#define KERNEL_LOG(lvl, fmt, ...)                                              \
    KERNEL_LOG_BASE("kernel :: ", lvl, fmt, "\n", ##__VA_ARGS__)

#define KERNEL_LOG_BEG(lvl, fmt, ...)                                          \
    KERNEL_LOG_BASE("kernel :: ", lvl, fmt, "", ##__VA_ARGS__)

#define KERNEL_LOG_END(lvl, fmt, ...)                                          \
    KERNEL_LOG_BASE("", lvl, fmt, "\n", ##__VA_ARGS__)

#define KERNEL_LOG_BASE(pre, lvl, fmt, end, ...)                               \
    do {                                                                       \
        terminal_setcolor(LOG_COL_##lvl);                                      \
        printf("%s", pre);                                                     \
        printf(fmt, ##__VA_ARGS__);                                            \
        printf("%s", end);                                                     \
    } while (0)
