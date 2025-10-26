#include <kernel/tty.h>
#include <kernel/util.h>
#include <stdint.h>

void panic(char *message) {
    uint8_t panic_bg = 0x4f;
    uint8_t panic_text = 0x4f;

    terminal_fill(panic_bg);
    terminal_setcolor(panic_text);
    terminal_writestring("PANIC: ");
    terminal_writestring(message);
    terminal_writestring("\n\neverything has gone terribly wrong\n"
                         "press any key to restart the computer.\n");

    halt();
}
