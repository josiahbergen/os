#include <stdint.h>
#include <stdio.h>

#define LOG_COL_INFO 0x08
#define LOG_COL_LOG 0x07
#define LOG_COL_WARN 0x0e
#define LOG_COL_ERROR 0x0c
#define LOG_COL_PANIC 0xc

#define KERNEL_INFO(m)                                                         \
    do {                                                                       \
        terminal_setcolor(LOG_COL_INFO);                                       \
        printf("kernel: %s\n", m);                                             \
    } while (0)

#define KERNEL_LOG(m)                                                          \
    do {                                                                       \
        terminal_setcolor(LOG_COL_LOG);                                        \
        printf("kernel: %s\n", m);                                             \
    } while (0)

#define KERNEL_WARN(m)                                                         \
    do {                                                                       \
        terminal_setcolor(LOG_COL_WARN);                                       \
        printf("kernel: warn: %s\n", m);                                       \
    } while (0)

#define KERNEL_ERROR(m)                                                        \
    do {                                                                       \
        terminal_setcolor(LOG_COL_ERROR);                                      \
        printf("kernel: error: %s\n", m);                                      \
    } while (0)
