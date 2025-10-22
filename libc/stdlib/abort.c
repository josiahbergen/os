#include <stdio.h>
#include <stdlib.h>

__attribute__((__noreturn__)) void abort(void) {
#if defined(__is_libk)
    // TODO: Add proper kernel panic.
    printf("\nkernel: panic: abort()\n");
#else
    // TODO: Abnormally terminate the process as if by SIGABRT.
    printf("abort()\n");
#endif
    while (1) {
    }
    __builtin_unreachable();
}

__attribute__((__noreturn__)) void halt(void) {
    while (1) {
        __asm__ volatile("cli");
        __asm__ volatile("hlt");
    }
}
