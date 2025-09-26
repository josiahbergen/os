org 0x1000
bits 16

; second stage loader
;
; this code is now in the new sectors that are loaded in
; it should be in memory at 0x0000:0x1000)
;
; goals: not sure yet. hopefully do someting cool.

start:
    ; we made it to 0x0000:0x1000. what next?
    ; stack pointer is set at 0x0000:0x7c00
    mov bx, s_init
    call print

    call get_sectors

    ; TODO:
    ; get available memory
    ; enable a20
    ; load the global description table
    ; switch to protected mode
    ; get a cross-compiler and linker working
    ; load and move the kernel into high memory
    ; far jump to kernel

    cli
    hlt

get_sectors:
    ; print sector info
    mov bx, s_sector_info
    call print
    mov dx, ss
    call print_hex
    mov dx, sp
    call print_hex
    mov dx, ds
    call print_hex
    mov dx, es
    call print_hex
    call newline
    call newline
    ret

s_init: db "hello from 0x0000:0x1000!", 10, 10, 0
s_sector_info: db "segment info:", 10, "ss      sp      ds      es", 10, 0


%include "util.asm"
