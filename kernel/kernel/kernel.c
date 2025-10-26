
#include <kernel/logging.h>
#include <kernel/tty.h>
#include <kernel/util.h>

void kernel_main(void) {
    terminal_initialize();

    KERNEL_INFO("kernel_main");
    KERNEL_INFO("gdt init...");

    // panic("global discriptor table not implemented");

    // KERNEL_WARN("uh oh");
    KERNEL_ERROR("global discriptor table not implemented");

    halt();
}
