org 0x7c00
bits 16
start: jmp boot

boot:
    ; welcome message
    mov bx, s_welcome
    call print
    mov bx, s_title
    call print

    call loader

    jmp $

; disk address packet
dap:
    db 10h ; size of DAP
    db 00h ; reserved
    dw 20h ; read 20 sectors (10,240 bytes)
    dw 0000h ; offset of buffer
    dw 9000h ; segment of buffer
    dq 1234h ; starting LBA

loader:
    mov bx, s_drive
    call print

    mov ah, 42h ; extended read sectors from drive
    mov dl, 80h ; drive 0
    int 13h

    cmp cf, 0
    jmp 7e00h ; jump to the next sector, here we go!

print:
    mov al, [bx]

    ; null check
    cmp al, 0
    je done

    ; newline check
    cmp al, ah ; ASCII line feed
    je newline

    ; print the character
    mov ah, 0eh ; display character
    int 10h ; call bios video service

    ; increment the pointer
    inc bx
    jmp print

newline:
    ; get cursor position
    mov ah, 03h ; get cursor position
    xor bh, bh ; page 0
    int 10h

    ; set cursor position
    mov ah, 02h
    inc dh ; cursor row is already in dh, so we need to add 1
    xor dl, dl ; col 0
    int 10h

    inc bx
    ret

done:
    call newline
    ret

clear:
    ; clear screen
    mov ah, 0x06    ; scroll window up
    mov al, 0x00    ; number of lines to scroll (00h = clear entire window)
    mov bh, 0x0f    ; white on black
    mov cx, 0x0000  ; upper left corner (row=0, col=0)
    mov dx, 0x184F  ; lower right corner (row=24, col=79)
    int 10h        ; call bios video service

    ; move cursor to the top left
    mov ah, 02h ; set cursor position
    mov bh, 0   ; page number (0)
    mov dh, 0   ; row
    mov dl, 0   ; column
    int 10h

    ret

panic:
    mov bx, s_panic
    call print
    jmp $


s_title: db "welcome to JAYOS v0.01", 0
s_welcome: db "hi marko!", 10, 0
s_drive: db "reading init sectors...", 0
s_panic: db "everything has gone wrong", 0

; we have to be 512 bytes, so fill the rest of the bytes with 0s
times 510 - ($-$$) db 0
dw 0xAA55 ; magic number

s_test: db "hello from address 0x7e00!", 0
mov bx, s_test
call print
