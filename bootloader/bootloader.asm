org 0x7c00
bits 16
start: jmp boot

boot:
    ; welcome message
    mov bx, s_welcome
    call print
    mov bx, s_title
    call print

    call load_sectors

dap: ; disk address packet
	db 0x10
	db 0
	blkcount: dw 16 ; int 13 resets this to # of blocks actually read/written
	dw 0x7e00 ; memory buffer destination address (0:7c00)
	dw 0 ; in memory page zero
    dd 1 ; put the lba to read in this spot
	dd 0 ; more storage bytes only for big lba's ( > 4 bytes )

load_sectors:
    mov bx, s_drive
    call print

    mov ah, 00h ; reset disk
    mov dl, 80h ; first hard disk
    int 13h
    jc panic

    mov ah, 41h ; check if extensions are supported
    mov bx, 0x55aa
    mov dl, 0x80
    int 13h
    jc panic

    mov ah, 42h ; extended read sectors from drive
    mov si, dap
    mov dl, 80h
    mov ax, ds  ; ds already points to current segment
    int 13h
    jc panic ; bad news

    call chilling
    jmp 0x7e00 ; jump to the next sector, here we go!

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

chilling:
    mov al, 0x0 ; letter A
    mov ah, 0eh ; display character
    int 10h 
    ret

s_title: db "welcome to JaideOS v0.01", 0
s_welcome: db "hi marko!", 10, 0
s_drive: db "reading init sectors...", 0
s_success: db "success", 0
s_panic: db "everything has gone wrong", 0
s_post_load: db "hello from address 0x7e00!", 0

; we have to be 512 bytes, so fill the rest of the bytes with 0s
times 510 - ($-$$) db 0
dw 0xAA55 ; magic number

; this code is now in the new sectors that are loaded in (should be at 0x7e00)
mov al, 0x29 ; letter A
mov ah, 0eh ; display character
int 10h 
