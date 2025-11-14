#include "kernel/io.h"
#include <stdint.h>

void arch_halt() {
    __asm__ volatile("cli");
    __asm__ volatile("hlt");
}

void arch_reset() {
    uint8_t good = 0x02;
    while (good & 0x02)
        good = inb(0x64);
    outb(0x64, 0xFE);
    arch_halt();
}
