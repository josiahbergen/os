org 0x7c00
bits 16
start:
    mov bx, message
    call welcome ; say hello

welcome:
    mov al, [bx]

    ; null check
    cmp al, 0
    je done

    ; print the character
    mov ah, 0x0e ; 0Eh: display character
    int 0x10 ; call bios video service

    ; increment the pointer
    inc bx
    jmp welcome

done: ret

message: db "and hello kernel!", 0
