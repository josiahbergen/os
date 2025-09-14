org 0x7c00
bits 16
start: jmp boot

boot:
    ; clear screen
    call clear

    ; welcome message
    mov bx, title
    call print

    mov bx, welcome
    call print

    jmp $

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
    ; get cursor position
    mov ah, 03h
    mov bh, 0
    int 10h

    ; set cursor position
    mov ah, 02h
    inc dh ; cursor row is already in dh, so we need to add 1
    mov dl, 0 ; col 0
    int 10h

ret

clear:
    ; clear screen
    mov ah, 06h    ; scroll window up
    mov al, 00h    ; number of lines to scroll (00h = clear entire window)
    mov bh, 0fh    ; white on black
    mov cx, 0000h  ; upper left corner (row=0, col=0)
    mov dx, 184Fh  ; lower right corner (row=24, col=79)
    int 10h        ; call bios video service

    ; move cursor to the top left
    mov ah, 02h ; set cursor position
    mov bh, 0   ; page number (0)
    mov dh, 0   ; row
    mov dl, 0   ; column
    int 10h

    ret

title: db "welcome to JBIOS v0.01", 0
welcome: db "hi marko!", 0
healthy: db "hard disk is healthy", 0
panic: db "everything has gone wrong", 0

; we have to be 512 bytes, so fill the rest of the bytes with 0s
times 510 - ($-$$) db 0
dw 0xAA55 ; magic number
