org 0x1000
bits 16

; second stage loader
;
; this code is now in the new sectors that are loaded in
; it should be in memory at 0x0000:0x1000
;
; goals: not sure yet. hopefully do someting cool.

start:
    ; we made it to 0x0000:0x1000. what next?
    ; top of the stack is 0x0000:0x7c00
    mov bx, b1_s_init
    call b1_print

    ; TODO:
    ; get available memory
    ; load the global description table
    ; switch to 32-bit protected mode
    ; enable and test a20
    ; get a cross-compiler and linker working
    ; load and move the kernel into high memory
    ; far jump to kernel

    cli
    hlt

b1_s_init: db "hello from 0x0000:0x1000!", 10, 0
b1_s_sector_info: db "segment info:", 10, "ss      sp      ds      es", 10, 0


%include "util.asm"
