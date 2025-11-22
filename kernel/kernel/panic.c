#include <kernel/tty.h>
#include <kernel/util.h>
#include <stdint.h>

void panic(char *message) {

    uint8_t col = 0x4f;
    uint8_t old_col = 0x8;

    terminal_setcolor(col);
    terminal_writestring("kernel :: panic!\nkernel :: ");
    terminal_writestring(message);
    terminal_setcolor(old_col);
    terminal_writestring("\nkernel :: everything has gone terribly wrong\n");

    // TODO: reboot computer?
    halt();
}
