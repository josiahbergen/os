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

    mov bx, s_wait
    call print

    xor ah, ah
    int 16h

    call get_sectors
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
s_wait: db "press any key to boot... ", 0
s_sector_info: db 10, 10, "ss      sp      ds      es", 10, 0


%include "util.asm"
