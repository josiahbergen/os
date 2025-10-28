org 0x1000
bits 16

; these get re-defined by the makefile and
; passed in dynamically through nasm flags
%ifndef KERNEL_LBA
%define KERNEL_LBA 17
%endif

%ifndef KERNEL_SECTORS
%define KERNEL_SECTORS 128
%endif

%macro print_string 1
    mov bx, %1
    call b1_print
%endmacro

%macro print_hex 1
    mov dx, %1
    call b1_print_hex
%endmacro

; second stage loader
;
; this code is now in the new sectors that are loaded in
; it should be in memory at 0x0000:0x1000

start:
    ; we made it to 0x0000:0x1000. what next?
    ; top of the stack is 0x0000:0x7c00
    print_string b1_s_enter_menu

    mov ah, 0x00 ; get system timer
    int 0x1a
    mov bx, dx ; starting timer count (low 16 bits)

b1_wait_key_loop:

    ; check for keypress
    mov ax, 0x0100
    int 0x16
    cmp ax, 0x011b
    je b1_main_menu_init
    cmp ax, 0x1c0d
    je b1_enter_protected_mode

    ; check status of event timer
    mov ah, 0x00
    int 0x1a
    sub dx, bx ; compute elapsed ticks (16-bit wrap ok for short waits)
    cmp dx, 27 ; 1.5 seconds ish (18.2 ticks/sec)
    jb b1_wait_key_loop ; if less, keep waiting

    jmp b1_enter_protected_mode

b1_main_menu_init:

    call b1_background_init

    print_string b1_s_title
    ; print_string b1_s_welcome

    call b1_set_video
    call b1_get_memory

    print_string b1_s_load_finished
    jmp b1_draw_loop

b1_enter_protected_mode:

    call b1_newline

    ; load the global descriptor table:
    ; the descriptor lives at b1_gdt_descriptor, and
    ; we can use the lgdt to load it for us.
    mov bx, b1_s_load_gdt
    call b1_print

    lgdt [b1_gdt_descriptor] ; the magic!
    mov bx, b1_s_success
    call b1_print

    ; a20 is already enabled by the bios! less for me to do!
    call b1_load_kernel ; load kernel into 0x00010000

    print_string b1_s_protected

    ; reset video to a clean slate
    xor ah, ah ; set video mode
    mov al, 0x03 ; 80x25ch vga, see https://mendelson.org/wpdos/videomodes.txt
    int 0x10

    cli ; disable interrupts

    ; set constants for the addresses of the code and data segments
    CODE_SEG equ b1_gdt_kernel_code_segment - b1_gdt_start
    DATA_SEG equ b1_gdt_kernel_data_segment - b1_gdt_start

    ; enter protected mode:
    ; to enter protected mode, we need to set the last bit
    ; of a special register (cr0) to 1. to do this, we need to
    ; set eax and copy its value into cr0
    mov eax, cr0
    or eax, 1
    mov cr0, eax ; yay, 32-bit mode!!

    ; after this is done, the instruction pipeline needs to be cleared.
    ; to do this, we perform a far jump:
    jmp CODE_SEG:start_protected_mode

    hlt ; fallback

b1_cursor_pos: dd 0x0000

b1_draw_navbar:
    ; draw a line across the screen

    ; save the previous cursor position
    mov ah, 0x03
    xor bh, bh ; we zero the page number here, we dont have to do it later
    int 0x10
    mov [b1_cursor_pos], dx

    mov ah, 0x02 ; set cursor position
    mov dx, 0x01400 ; col:row
    int 0x10

    mov ah, 0x09 ; write character and attribte at cursor position
    mov al, " " ; character
    mov bl, 0x0f ; color: black on white
    mov cx, 0x50 ; number of times to print (85)
    int 0x10

    mov dl, 0x00 ; cursor position
    mov cx, 0x0f ; num of chars to print

    cmp [b1_navbar_selection], 0x01
    jne _reboot_not_selected
    mov dl, 0x12
    mov cx, 0x09
    _reboot_not_selected:

    cmp [b1_navbar_selection], 0x02
    jne _panic_not_selected
    mov dl, 0x1e
    mov cx, 0x09
    _panic_not_selected:

    cmp [b1_navbar_selection], 0x03
    jne _nothing_not_selected
    mov dl, 0x2a
    mov cx, 0x0e
    _nothing_not_selected:

    ; draw a red line at the address we just decided
    mov ah, 0x02 ; set cursor position
    int 0x10
    mov ah, 0x09 ; write character and attribte at cursor position
    mov al, " " ; character
    mov bl, 0xcf ; color
    int 0x10

    mov ah, 0x02 ; reset cursor position
    xor dl, dl ; to col 0
    int 0x10

    print_string b1_s_navbar_text

    mov ah, 0x02 ; reset cursor position
    xor bh, bh ; page 0
    mov dx, [b1_cursor_pos]
    int 0x10
    ret

b1_draw_loop:
    call b1_draw_navbar

    _b1_draw_input_loop:
    xor ah, ah
    int 0x16

    cmp ax, 0x1c0d ; enter
    je _b1_draw_pressed_enter

    cmp ax, 0x4b00 ; left arrow
    je _b1_draw_pressed_left

    cmp ax, 0x4d00 ; right arrow
    je _b1_draw_pressed_right

    jmp _b1_draw_input_loop ; restart the loop if any other key

    _b1_draw_pressed_left:
    cmp [b1_navbar_selection], 0x00
    je _b1_draw_loop_left
    dec [b1_navbar_selection]
    jmp b1_draw_loop

    _b1_draw_pressed_right:
    cmp [b1_navbar_selection], 0x03
    je _b1_draw_loop_right
    inc [b1_navbar_selection]
    jmp b1_draw_loop

    _b1_draw_loop_left:
    mov [b1_navbar_selection], 0x03
    jmp b1_draw_loop

    _b1_draw_loop_right:
    mov [b1_navbar_selection], 0x00
    jmp b1_draw_loop

    _b1_draw_pressed_enter:
    cmp [b1_navbar_selection], 0x00
    je b1_enter_protected_mode

    cmp [b1_navbar_selection], 0x01
    je b1_reboot

    cmp [b1_navbar_selection], 0x02
    je b1_panic

    jmp b1_draw_nothing ; do nothing is selected

b1_draw_nothing:
    xor ah, ah ; set video mode
    mov al, 0x03 ; 80x25ch vga
    int 0x10
    print_string b1_s_nothing
    xor ah, ah
    int 0x16
    jmp b1_main_menu_init

b1_panic:
    xor ah, ah ; set video mode
    mov al, 0x03
    int 0x10
    xor al, al; scroll all rows
    xor cx, cx ; top left corner (0, 0)
    mov bh, 0x4f ; light gray on black
    mov dx, 0x184F ; bottom right corner (24, 79)
    mov ah, 0x06 ; scroll screen
    int 0x10
    mov bx, b1_s_panic
    call b1_print

    mov ah, 0x00 ; get system timer
    int 0x1a
    mov bx, dx ; starting timer count (low 16 bits)

b1_panic_wait_loop:

    ; check for keypress
    mov ah, 0x01
    int 0x16
    jne b1_reboot

    ; check status of event timer
    mov ah, 0x00
    int 0x1a
    sub dx, bx ; compute elapsed ticks (16-bit wrap ok for short waits)
    cmp dx, 182 ; 10 seconds (18.2 ticks/sec)
    jb b1_panic_wait_loop ; if less, keep waiting
    jmp b1_reboot

b1_reboot:
    ; jump to reset vector
    jmp 0xffff:0

b1_get_memory:
    ; get low memory
    print_string b1_s_memory
    int 0x12 ; conventional memory is now in ax
    print_hex ax
    call b1_newline

    ; get upper memory
    ; ax = cx = extended memory between 1M and 16M, in K (max 3C00h = 15MB)
    ; bx = dx = extended memory above 16M, in 64K blocks
    mov ax, 0xe801
    int 0x15
    print_string b1_s_low_memory
    print_hex ax
    call b1_newline
    print_string b1_s_high_memory
    print_hex bx
    call b1_newline
    ret

b1_set_video:
    xor ax, ax ; so we can check their result after
    mov ah, 0x0f ; get current video mode
    int 0x10
    cmp al, 0x03 ; check if video is as expected
    jne b1_panic
    print_string b1_s_video_info
    call b1_newline
    ret

%include "util.asm"
%include "strings.asm"

b1_navbar_selection: dw 0x00

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
        db 0b10010010 ; access byte
        db 0b11001111 ; flags byte

        db 0x00 ; base 25-32

b1_gdt_end:

b1_gdt_descriptor:
    ; see https://wiki.osdev.org/Global_Descriptor_Table#GDTR
    dw b1_gdt_end - b1_gdt_start - 1 ; table size - 1
    dd b1_gdt_start ; start offset

b1_kernel_dap:
	db 0x10	; size of packet (16 bytes)
	db 0x00	; reserved
	dw KERNEL_SECTORS ; number of blocks to read
	dw 0x0000 ; offset
	dw 0x1000 ; segment (this gives us 0x00010000)
	dd KERNEL_LBA ; LBA low dword
	dd 0x00000000 ; LBA high dword

b1_load_kernel:

    print_string b1_s_loading_kernel

	push ax
	push bx
	push cx
	push dx
	push si

	; reset disk
	mov ah, 0x00
	mov dl, 0x80
	int 0x13

	; check extensions present
	mov ah, 0x41
	mov bx, 0x55aa
	mov dl, 0x80
	int 0x13
	cmp bx, 0xaa55
	jne b1_panic
	test cx, 1
	jz b1_panic

	; read disk
	mov si, b1_kernel_dap
	mov ah, 0x42
	mov dl, 0x80
	int 0x13
	jc b1_panic

	pop si
	pop dx
	pop cx
	pop bx
	pop ax

	print_string b1_s_success
	ret


[bits 32]
start_protected_mode:

    ; enable a20 (fast method)
    in al, 0x92
    or al, 2
    out 0x92, al

    ; set up flat data segments and a 32-bit stack
    mov ax, 10h
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x20000

    call pm_print_welcome

    ; jump to kernel entry linked at 0x00010000 (kernel_main)
    jmp 8:10000h
    jmp $

pm_print_welcome:

    ; video memory is at 0xb8000
    mov ah, 0xF2 ;  light gray on black
    mov al, 'O'
    mov [0xb809c], ax
    mov al, 'K'
    mov [0xb809e], ax
    ret
