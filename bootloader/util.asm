print_hex:
    ; prints the 16-bit hex value in dx
    ; adds the number of padding spaces in al
    ;
    ;
    ; start the counter: we want to print 4 characters
    ; 4 bits per char, so we're printing a total of 16 bits
    mov cx, 4

char_loop:
    dec cx ; decrement the counter

    mov ax, dx ; copy dx into ax so we can mask it for the last chars
    shr dx, 4 ; shift bx 4 bits to the right
    and ax, 0xf ; mask ah to get the last 4 bits

    mov bx, hex_out ; set bx to the memory address of our string
    add bx, 2 ; skip the '0x'
    add bx, cx ; add the current counter to the address

    cmp ax, 0xa ; check to see if it's a letter or number
    jl set_letter ; if it's a number, go straight to setting the value
    add al, 0x27 ; if it's a letter, add 0x27, and plus 0x30 down below
    ; ASCII letters start 0x61 for "a" characters after
    ; decimal numbers. We need to cover that distance.
    jl set_letter

set_letter:
    add al, 0x30 ; For an ASCII number, add 0x30
    mov byte [bx], al ; Add the value of the byte to the char at bx

    cmp cx, 0          ; check the counter, compare with 0
    je print_hex_done ; if the counter is 0, finish
    jmp char_loop     ; otherwise, loop again

print_hex_done:
    mov bx, hex_out   ; print the string pointed to by bx
    call print

print:
    ; new print function
    ; requires a newline byte (10) to print a newline

    mov al, [bx]

    ; null check
    cmp al, 0
    je done

    cmp al, 10
    je newline

    ; print the character
    mov ah, 0eh ; display character
    int 10h ; call bios video service

    ; increment the pointer
    inc bx
    jmp print

newline:
    pusha ; save the stack values for later

    mov ah, 03h ; get cursor position
    xor bh, bh ; page 0
    int 10h

    ; set cursor position
    mov ah, 02h
    inc dh ; cursor row is already in dh, so we need to add 1
    xor dl, dl ; col 0
    int 10h

    popa ; pop the values back from the stack
    inc bx ; so we don't infinitely print newlines
    jmp print

done:
    ret

; padding spaces at the end (so terrible)
hex_out: db "0x0000  ", 0
