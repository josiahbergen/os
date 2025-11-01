
#include <kernel/init.h>
#include <kernel/logging.h>
#include <kernel/setup.h>
#include <kernel/tty.h>
#include <kernel/util.h>

void kernel_main(void) {
    terminal_initialize();

    KERNEL_LOG(LOG, "kernel_main at virtual address %p", (void *)kernel_main);
    KERNEL_LOG(INFO, "hi marko!");

    // load global descriptor table
    KERNEL_LOG_BEG(LOG, "gdt init... ");
    gdt_init();
    KERNEL_LOG_END(SUCCESS, "ok");

    halt();
}
