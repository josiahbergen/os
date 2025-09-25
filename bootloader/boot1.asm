 org 0x1000
 bits 16

 ; second stage loader
 ;
 ; this code is now in the new sectors that are loaded in
 ; it should be in memory at 0x0000:0x1000)
 ;
 ; goals: not sure yet. hopefully do someting cool.

 start:
    mov bx, s_init
    call print
    mov bx, s_success
    call print
    cli
    hlt

print:
    mov al, [bx]

    ; null check
    cmp al, 0
    je done

    ; print the character
    mov ah, 0eh ; display character
    int 10h ; call bios video service

    ; increment the pointer
    inc bx
    jmp print

done:
    ; put a newline at the end of each string we print
    ; so hacky but whatever works works

    mov ah, 03h ; get cursor position
    xor bh, bh ; page 0
    int 10h

    ; set cursor position
    mov ah, 02h
    inc dh ; cursor row is already in dh, so we need to add 1
    xor dl, dl ; col 0
    int 10h
    ret

s_init: db "boot1 init: hello from 0x0000:0x1000!", 0
s_success: db "it works!!", 0
