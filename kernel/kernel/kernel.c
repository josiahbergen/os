
#include <kernel/logging.h>
#include <kernel/tty.h>
#include <kernel/util.h>

void kernel_main(void) {
    terminal_initialize();

    KERNEL_LOG(INFO, "kernel_main");

    // load global descriptor table (for real)
    KERNEL_LOG_NBR(LOG, "gdt init... ");
    // gdt_init();

    KERNEL_LOG_CUSTOM("", ERROR, "failed", "\n");

    halt();
}
