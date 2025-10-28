#include <stdint.h>
#include <stdio.h>

#define LOG_COL_INFO 0x08
#define LOG_COL_LOG 0x07
#define LOG_COL_WARN 0x06
#define LOG_COL_ERROR 0x0c
#define LOG_COL_PANIC 0xc

#define KERNEL_LOG(lvl, msg) KERNEL_LOG_MAIN("kernel :: ", lvl, msg, "\n")
#define KERNEL_LOG_NBR(lvl, msg) KERNEL_LOG_MAIN("kernel :: ", lvl, msg, "")
#define KERNEL_LOG_CUSTOM(pre, lvl, msg, end)                                  \
    KERNEL_LOG_MAIN(pre, lvl, msg, end)

#define KERNEL_LOG_MAIN(pre, lvl, msg, end)                                    \
    do {                                                                       \
        terminal_setcolor(LOG_COL_##lvl);                                      \
        printf("%s%s%s", pre, msg, end);                                       \
    } while (0)
