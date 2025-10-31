#include <stdint.h>
#include <stdio.h>

#define LOG_COL_INFO 0x08
#define LOG_COL_LOG 0x07
#define LOG_COL_WARN 0x06
#define LOG_COL_ERROR 0x0c
#define LOG_COL_PANIC 0x0c
#define LOG_COL_SUCCESS 0x02

#define KERNEL_LOG(lvl, msg) KERNEL_LOG_BASE("kernel :: ", lvl, msg, "\n")
#define KERNEL_LOG_BEG(lvl, msg) KERNEL_LOG_BASE("kernel :: ", lvl, msg, "")
#define KERNEL_LOG_END(lvl, msg) KERNEL_LOG_BASE("", lvl, msg, "\n")
#define KERNEL_LOG_BASE(pre, lvl, msg, end)                                    \
    do {                                                                       \
        terminal_setcolor(LOG_COL_##lvl);                                      \
        printf("%s%s%s", pre, msg, end);                                       \
    } while (0)
