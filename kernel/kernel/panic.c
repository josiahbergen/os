#include <kernel/tty.h>
#include <kernel/util.h>
#include <stdint.h>

void panic(char *message) {

    uint8_t col = 0x4f;

    terminal_fill_lines(23, 3, col);
    terminal_setcursor(0, 23);
    terminal_setcolor(col);
    terminal_writestring("PANIC: ");
    terminal_writestring(message);
    terminal_writestring("\neverything has gone terribly wrong\n");

    // TODO: reboot computer?

    halt();
}
