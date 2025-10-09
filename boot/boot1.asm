org 0x1000
bits 16

; second stage loader
;
; this code is now in the new sectors that are loaded in
; it should be in memory at 0x0000:0x1000

start:
    ; we made it to 0x0000:0x1000. what next?
    ; top of the stack is 0x0000:0x7c00
    mov bx, b1_s_init
    call b1_print

    ; TODO: get available memory and video modes

    ; load the global descriptor table:
    ; the descriptor lives at b1_gdt_descriptor, and
    ; we can use the lgdt to load it for us.
    mov bx, b1_s_load_gdt
    call b1_print

    lgdt [b1_gdt_descriptor] ; the magic!
    mov bx, b1_s_success
    call b1_print

    ; set constants for the addresses of the code and data segments
    CODE_SEG equ b1_gdt_kernel_code_segment - b1_gdt_start
    DATA_SEG equ b1_gdt_kernel_data_segment - b1_gdt_start
    call b1_print_gdt_status

    cli ; disable interrupts

    ; enter protected mode:
    ; to enter protected mode, we need to set the last bit
    ; of a special register (cr0) to 1. to do this, we need to
    ; set eax (a 32-bit register) and copy its value into cr0
    mov bx, b1_s_protected
    call b1_print

    mov eax, cr0
    or eax, 1
    mov cr0, eax ; yay, 32-bit mode!!

    ; after this is done, the instruction pipeline needs to be cleared.
    ; to do this, we perform a far jump:
    jmp CODE_SEG:start_protected_mode

    jmp $

b1_print_gdt_status:
    mov bx, b1_s_code_segment
    call b1_print

    mov dx, CODE_SEG
    call b1_print_hex

    mov al, ":"
    mov ah, 0x0e ; display character
    int 0x10 ; bios video service

    mov dx, start_protected_mode
    call b1_print_hex
    call b1_newline


b1_panic:
    mov bx, b1_s_error
    call b1_print
    jmp $

%include "util.asm"

b1_s_init: db "hello from 0x0000:0x1000!", 10, 0
b1_s_load_gdt: db "loading global descriptor table... ", 0
b1_s_code_segment: db "kernel code segment is at ", 0
b1_s_protected: db "entering 32-bit protected mode... ", 0
b1_s_success: db "OK", 10, 0
b1_s_error: db "everything has gone terribly wrong.", 10, 0

b1_gdt_start: ; must be at the end of the real mode code

    ; global descriptor table
    ; we will be using the flat memory model (now, at least...)
    ; we will be creating a kernel mode code and data segment
    ; in the future, we can add user mode code/data segments as well..att_syntax
    ; to change to paging, set bit 31 in the CR0 register once in protected mode.
    ;
    ; the table consists of multiple qword "entries",
    ; each with a very complex structure.
    ; see http://www.osdever.net/tutorials/view/the-world-of-protected-mode

    b1_gdt_null_segment:
        ; null segment descriptor (offset 0x0000)
        dq 0 ; full entry of 0s. easy enough.

    b1_gdt_kernel_code_segment:
        ; kernel code segment descriptor (offset 0x0008)
        dw 0xffff ; segment limiter (16 bits)
        dw 0x0000 ; first 16 bits of the base address
        db 0x00 ; next 8 bits of the base address

        db 0b10011010 ; access byte, defined as follows:
        ; bit 7 - present bit:
        ; allows an entry to refer to a valid segment
        ; set to 1; valid segment.
        ;
        ; bits 6 and 5 - descriptor privilege level field:
        ; has 4 possible values, the lower the highest privelecge
        ; set to 0 for kernel (ring 0)!
        ;
        ; bit 4 - type bit:
        ; set to 0 if the descriptor defines a system segment (task state, etc.)
        ; set to 1 of it defines a code or data segment
        ; so we set it to 1.
        ;
        ; bit 3 - executable bit:
        ; if 0 the descriptor defines a data segment
        ; if 1 the descriptor defines a code segment which can be executed from.
        ; as this is the code segment, set to 1.
        ;
        ; bit 2 - direction/conforming bit:
        ; see https://wiki.osdev.org/Global_Descriptor_Table
        ; set to 0: code selector, cannot be executed from lower priveledged segments
        ;
        ; bit 1 - readable/writable bit:
        ; see https://wiki.osdev.org/Global_Descriptor_Table
        ; we want this code to be readable, so set to 1
        ;
        ; bit 0 - accessed bit:
        ; we want the CPU to manage this for us, so set to 0.

        db 0b11001111 ; flags byte, defined as follows:
        ; bits 7 to 5: unused
        ;
        ; bit 3 - granularity flag
        ; when this is one, limit is multiplied by 0x1000
        ; this allows us to access 4gb of memory!
        ; see https://wiki.osdev.org/Global_Descriptor_Table and https://youtu.be/Wh5nPn2U_1w?t=369
        ; we want 4gb of memory, so set to 1.
        ;
        ; bit 2 - size flag
        ; if 0, the segment is 16-bit
        ; if 1, the segment is 32-bit
        ; so we set to 1.
        ;
        ; bit 1 - long-mode code flag:
        ; if set, the descriptor defines a 64-bit code segment
        ; when set, bit 2 should always be clear.
        ; we set to 0 (we want 32 bits)
        ;
        ; bit 0 - reserved, set to 0

        db 0x00 ; final 8 bits of the base address

    b1_gdt_kernel_data_segment:
        ; kernel data segment descriptor (offset 0x0010)
        dw 0xffff ; limit
        dw 0x0000 ; base 1-16
        db 0x00 ; base 17-24

        ; see b1_gdt_kernel_code_segment for definitions
        dw 0b10010010 ; access byte
        db 0b11001111 ; flags byte

        db 0x00 ; base 25-32

b1_gdt_end:

b1_gdt_descriptor:
    ; see https://wiki.osdev.org/Global_Descriptor_Table#GDTR
    dw b1_gdt_end - b1_gdt_start - 1 ; table size - 1
    dd b1_gdt_start ; start offset

[BITS 32]
start_protected_mode:

    ; video memory is at 0xb8000
    ; set the low byte of ax to the character
    ; and the high byte of ax to the color
    ; this should

    mov al, 'J'
    mov ah, 0x0f ; white on black
    mov [0xb8000], ax
    jmp $
