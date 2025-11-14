
#include <kernel/init.h>
#include <kernel/logging.h>
#include <kernel/tty.h>
#include <kernel/util.h>

void kernel_main(void) {
    terminal_initialize();

    KERNEL_LOG(LOG, "kernel_main at virtual address %p", (void *)kernel_main);
    KERNEL_LOG(INFO, "hi marko!");

    // load global descriptor table
    load_gdt();
    // load interrupt descriptor table
    load_idt();

    halt();
}
