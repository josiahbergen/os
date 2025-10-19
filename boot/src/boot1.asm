org 0x1000
bits 16

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

    call b1_background_init

    print_string b1_s_title
    print_string b1_s_welcome

    print_string b1_s_info
    call b1_get_memory
    call b1_set_video
    call b1_newline

    ; load the global descriptor table:
    ; the descriptor lives at b1_gdt_descriptor, and
    ; we can use the lgdt to load it for us.
    mov bx, b1_s_load_gdt
    call b1_print

    lgdt [b1_gdt_descriptor] ; the magic!
    mov bx, b1_s_success
    call b1_print

    print_string b1_s_load_finished

    jmp b1_draw_loop

b1_enter_protected_mode:

    call b1_newline

    mov bx, b1_s_protected
    call b1_print

    ; call b1_enable_a20 ; enable A20
    call b1_load_kernel ; load kernel into 0x00010000

    cli ; disable interrupts

    ; set constants for the addresses of the code and data segments
    CODE_SEG equ b1_gdt_kernel_code_segment - b1_gdt_start
    DATA_SEG equ b1_gdt_kernel_data_segment - b1_gdt_start

    ; enter protected mode:
    ; to enter protected mode, we need to set the last bit
    ; of a special register (cr0) to 1. to do this, we need to
    ; set eax (a 32-bit register) and copy its value into cr0
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
    mov dx, 0x01500 ; col:row
    int 0x10

    mov ah, 0x09 ; write character and attribte at cursor position
    mov al, " " ; character
    mov bl, 0xf0 ; color: black on white
    mov cx, 0x50 ; number of times to print (85)
    int 0x10

    mov dl, 0x09
    cmp [b1_navbar_selection], 0x01
    jne _reboot_not_selected
    mov dl, 0x1b
    _reboot_not_selected:

    cmp [b1_navbar_selection], 0x02
    jne _panic_not_selected
    mov dl, 0x29
    _panic_not_selected:

    cmp [b1_navbar_selection], 0x03
    jne _nothing_not_selected
    mov dl, 0x35
    _nothing_not_selected:

    ; draw a red pixel at the address we just decided
    mov ah, 0x02 ; set cursor position
    mov dh, 0x15 ; to row 0x14 (the col is set by the logic above)
    int 0x10
    mov ah, 0x09 ; write character and attribte at cursor position
    mov al, " " ; character
    mov bl, 0xcf ; color: black on white
    mov cx, 0x01 ; number of chars to print
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

    cmp ax, 0x3920 ; space
    je b1_enter_protected_mode

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

    jmp b1_draw_loop ; do nothing is selected

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

    mov ah, 0x86
    ; we want a delay of 0x004c4b40
    ; the timer is in cx:dx, thus we need 004c:4b40
    mov cx, 0x003d
    mov dx, 0x0900
    int 0x15
    jmp b1_reboot

b1_reboot:
    xor ah, ah ; set video mode
    mov al, 0x03
    int 0x10
    int 0x19
    jmp $

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

	push ax
	push bx
	push cx
	push dx
	push si

	; check extensions
	mov ah, 0x41
	mov bx, 0x55aa
	int 0x13
	cmp bx, 0xaa55
	jne b1_panic
	test cx, 1
	jz b1_panic

	mov ah, 0x41 ; "check extensions present" service

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
	ret

b1_enable_a20:
	; enable A20 via keyboard controller method
	call .b1_wait_input
	mov al, 0xAD ; disable keyboard
	out 0x64, al

	call .b1_wait_input
	mov al, 0xD0 ; read output port command
	out 0x64, al

	call .b1_wait_output
	in al, 0x60	; read current output port
	or al, 0000_0010b ; set A20 (bit 1)

	call .b1_wait_input
	mov ah, al ; save value in ah
	mov al, 0xD1 ; write output port command
	out 0x64, al
	call .b1_wait_input
	mov al, ah
	out 0x60, al

	call .b1_wait_input
	mov al, 0xAE ; re-enable keyboard
	out 0x64, al
	ret

.b1_wait_input:
	in al, 0x64
	test al, 0000_0010b	; input buffer full?
	jnz .b1_wait_input
	ret

.b1_wait_output:
	in al, 0x64
	test al, 0000_0001b	; output buffer full?
	jz .b1_wait_output
	ret

[bits 32]
start_protected_mode:

    ; set up flat data segments and a 32-bit stack
    mov ax, 10h
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x20000

    call pm_print_welcome

    ; jump to kernel entry linked at 0x00010000
    jmp 8:10000h

    pm_kernel_run_loop: hlt
    jmp pm_kernel_run_loop ; juuust in case

pm_print_welcome:

    ; video memory is at 0xb8000
    mov ah, 0xF2 ;  light gray on black
    mov al, 'O'
    mov [0xb809c], ax
    mov al, 'K'
    mov [0xb809e], ax
    ret
