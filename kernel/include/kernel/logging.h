#include <stdint.h>
#include <stdio.h>

#define LOG_COL_INFO 0x08
#define LOG_COL_LOG 0x07
#define LOG_COL_WARN 0x06
#define LOG_COL_ERROR 0x0c
#define LOG_COL_PANIC 0x0c
#define LOG_COL_SUCCESS 0x02

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
