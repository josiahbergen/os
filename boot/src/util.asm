b1_print_hex:
    ; prints the 16-bit hex value in dx
    ; adds the number of padding spaces in al
    ;
    ;
    ; start the counter: we want to print 4 characters
    ; 4 bits per char, so we're printing a total of 16 bits
    mov cx, 4

b1_char_loop:
    dec cx ; decrement the counter

    mov ax, dx ; copy dx into ax so we can mask it for the last chars
    shr dx, 4 ; shift bx 4 bits to the right
    and ax, 0xf ; mask ah to get the last 4 bits

    mov bx, b1_s_hex_out ; set bx to the memory address of our string
    add bx, 2 ; skip the '0x'
    add bx, cx ; add the current counter to the address

    cmp ax, 0xa ; check to see if it's a letter or number
    jl b1_set_letter ; if it's a number, go straight to setting the value
    add al, 0x27 ; if it's a letter, add 0x27, and plus 0x30 down below
    ; ASCII letters start 0x61 for "a" characters after
    ; decimal numbers. We need to cover that distance.
    jl b1_set_letter

b1_set_letter:
    add al, 0x30 ; For an ASCII number, add 0x30
    mov byte [bx], al ; Add the value of the byte to the char at bx

    cmp cx, 0          ; check the counter, compare with 0
    je b1_print_hex_done ; if the counter is 0, finish
    jmp b1_char_loop     ; otherwise, loop again

b1_print_hex_done:
    mov bx, b1_s_hex_out   ; print the string pointed to by bx
    call b1_print

b1_print:
    ; new print function
    ; requires a newline byte (10) to print a newline
    mov al, [bx]

    ; null check
    cmp al, 0
    je b1_done

    cmp al, 10
    je b1_print_loop_newline

    ; print the character
    mov ah, 0x0e ; display character
    int 0x10 ; bios video service

    ; increment the pointer
    inc bx
    jmp b1_print

b1_print_loop_newline:

    mov ah, 0x0e ; print character

    ; carriage return
    mov al, 0x0d
    int 0x10

    ; line feed
    mov al, 0x0a
    int 0x10

    inc bx ; so we don't infinitely print newlines
    jmp b1_print

b1_done:
    ret

b1_newline:
    mov ah, 0x0e ; print character

    ; carriage return
    mov al, 0x0d
    int 0x10

    ; line feed
    mov al, 0x0a
    int 0x10
    ret

; padding spaces at the end (so terrible)
b1_s_hex_out: db "0x0000", 0


b1_background_init:

    xor ah, ah ; set video mode
    mov al, 0x03 ; 80x25 vga, see https://mendelson.org/wpdos/videomodes.txt
    int 0x10

    mov ah, 0x05 ; set page...
    xor al, al ; ... to 0
    int 0x10

    xor al, al; scroll all rows
    xor cx, cx ; top left corner (0, 0)
    mov bh, 0x07 ; light gray on black
    mov dx, 0x184F ; bottom right corner (24, 79)
    mov ah, 0x06 ; scroll screen
    int 0x10

    ; scroll up to draw the three bottom lines
    mov al, 0x01
    mov bh, 0xB0
    int 0x10
    mov bh, 0x90
    int 0x10
    mov bh, 0x10
    int 0x10
    int 0x10

    ; draw the top line
    mov bh, 0xf0
    mov ah, 0x07
    int 0x10

    ; set cursor to 0:0
    xor bh, bh ; page 0
    xor dx, dx ; set row:col (dh:dl) to 0:0
    mov ah, 0x02 ; set cursor position
    int 0x10
    ret
