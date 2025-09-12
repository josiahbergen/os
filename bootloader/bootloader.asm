org 0x7c00
bits 16
start: jmp boot

boot:
    ; welcome message
    mov bx, message
    call print

print:
    mov al, [bx]

    ; null check
    cmp al, 0
    je done

    ; print the character
    mov ah, 0x0e ; 0Eh: display character
    int 0x10 ; call bios video service

    ; increment the pointer
    inc bx
    jmp print

done: ret

message: db "hi marko!", 0

; we have to be 512 bytes, so fill the rest of the bytes with 0s
times 510 - ($-$$) db 0
dw 0xAA55 ; magic number
