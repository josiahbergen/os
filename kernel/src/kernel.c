#include "include/terminal.h"

void kernel_main(void) {

  // we are here!!! finally!!!
  terminal_init();
  terminal_write("hello from the kernel!");

  while (1) {
    // mark volatile to prevent the compiler from messing with it
    asm volatile("hlt");
  }
}
