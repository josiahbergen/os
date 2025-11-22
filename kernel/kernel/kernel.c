
#include <kernel/init.h>
#include <kernel/logging.h>
#include <kernel/tty.h>
#include <kernel/util.h>

void kernel_main(void) {
    terminal_initialize();

    KERNEL_LOG(LOG, "kernel_main at virtual address %p", (void *)kernel_main);
    KERNEL_LOG(INFO, "hi marko!");

    load_gdt(); // load global descriptor table
    load_idt(); // load interrupt descriptor table

    KERNEL_LOG(LOG, "everything seems fine..?");

    // KERNEL_LOG(LOG, "checking interrupt handlers...");

    // // cause a fault
    // volatile int a = 1;
    // volatile int b = 0;
    // int c = a / b;
    // (void)c;

    // KERNEL_LOG(ERROR, "no fault.. something is wrong!");
    KERNEL_LOG(INFO, "goodnight");

    terminal_scroll(1);
    halt();
}
