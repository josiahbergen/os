org 0x7c00 ; origin of the bootloader
bits 16 ; we're in 16-bit real mode

; first stage loader
;
; the first 512 bytes of this code is loaded into 0x0000:0x7c00 by the bios,
; and is executed once bios POST is done.
;
; goals:
; - canonicalize the code segment and instruction pointer registers (cs:ip)
; - set up the real mode stack pointer and associated registers
; - print out a nice welcome message
; - load more sectors from the disk into memory (specifically 0x0000:0x1000)
; - transfer execution to the second stage loader
; - notify and halt if any errors are encountered along the way

start:
    cli ; disable interrupts

    ; canonicalize cs:ip and jump to main boot code
    jmp 0x0000:b0_boot ; set code segment to 0x0000, and instruction pointer to boot's offset
    ; cs = 0x0000 is useful for when we eventually jump to a high-level kernel

b0_boot:
    ; set up real mode stack
    ; the stack pointer is a segment:offset pair (ss:sp),
    ; and will grow downwards from 0x0000:0x7c00.
    ; the stack must also not grow larger than 0x3800 bytes, as
    ; boot1 will be loaded into bytes 0x1000 -> 0x31ff
    xor ax, ax
    mov ss, ax ; set the segment to 0
    mov sp, 0x7c00 ; and the offset to 0x7c00
    mov ds, ax ; data segment
    mov es, ax ; extra segment

    sti ; re-enable interrupts

    ; welcome message
    mov bx, b0_s_title
    call b0_print
    mov bx, b0_s_welcome
    call b0_print

    ; waiter! more sectors please!
    call b0_load_sectors

    ; far jump to the loaded sectors, here we go!
    jmp 0x0000:0x1000

b0_dap: ; disk address packet
	db 0x10 ; size of packet (16 bytes)
	db 0 ; reserved, always 0
	; number of segments to load
	; int 13 resets this to # of blocks actually read/written
	dw 16 ; read 6 sectors (16x512 bytes, 8kb)
    ; 4 byte memory buffer destination address (segment:offset format)
    ; we want the final address to be 0x0000:0x1000
    ; however, x86 is little endian so we put offset first and then segment
    ; memory map reference: https://www.cs.cmu.edu/~410-s07/p4/p4-boot.pdf
	dw 0x1000 ; offset
	dw 0x0000 ; segment
	dd 1 ; low 4 bytes of logical block address (lba)
	dd 0 ; high 4 bytes bits of lba

b0_load_sectors:
    mov bx, b0_s_drive
    call b0_print

    mov ah, 0x00 ; reset disk
    mov dl, 0x80 ; first hard disk
    int 13h
    jc b0_panic

   	mov ah, 0x41 ; "check extensions present" service
	mov bx, 0x55aa
	int 0x13
	cmp bx, 0xaa55 ; on success, bx is set to hex aa55
	jne b0_panic
	test cx, 1 ; Check support for the "fixed disk access subset"
	jz b0_panic

    mov si, b0_dap ; disk address packet
    mov ah, 0x42 ; extended read sectors from drive
    mov dl, 0x80
    int 0x13
    jc b0_panic

    ; maybe set data segments here for something that boot1 will like
    ; but for now, return
    ret

b0_print:
    ; new print function
    ; requires a newline byte (10) to print a newline
    mov al, [bx]

    ; null check
    cmp al, 0
    je b0_done

    cmp al, 10
    je b0_newline

    ; print the character
    mov ah, 0x0e ; display character
    int 0x10 ; bios video service

    ; increment the pointer
    inc bx
    jmp b0_print

b0_newline:

    mov ah, 0x0e ; print character

    ; carriage return
    mov al, 0x0d
    int 0x10

    ; line feed
    mov al, 0x0a
    int 0x10

    inc bx ; so we don't infinitely print newlines
    jmp b0_print

b0_done:
    ret

b0_panic:
    mov bx, b0_s_panic
    call b0_print
    cli
    hlt

b0_s_title: db "welcome to the JaideOS bootloader v0.01", 10, 0
b0_s_welcome: db "hi marko!", 10, 10, 0
b0_s_drive: db "loading boot1 and kernel sectors...", 10, 0
b0_s_panic: db "everything has gone terribly wrong", 10, 0

; we have to be 512 bytes, so fill the rest of the bytes with 0s
times 510 - ($-$$) db 0
dw 0xAA55 ; magic number
