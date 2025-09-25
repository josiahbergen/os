org 0x7c00 ; origin of the bootloader
bits 16 ; we're in 16-bit real mode

start:
    cli ; disable interrupts

    ; canonicalize cs:ip and jump to main boot code
    jmp 0:boot ; set code segment to 0x0000, and instruction pointer to boot's offset
    ; cs = 0x0000 is useful for when we eventually jump to a high-level kernel

boot:
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

    ; save our drive id for later
    mov ah, 0 ; clear high byte
    mov al, dl ; copy DL into AL
    push ax ; now push 16-bit AX

    sti ; re-enable interrupts

    ; welcome message
    mov bx, s_welcome
    call print
    mov bx, s_empty ; hack to print a newline
    call print 
    mov bx, s_title
    call print

    ; waiter! more sectors please!
    call load_sectors

    ; far jump to the loaded sector, here we go!
    jmp 0x0000:0x1000 

dap: ; disk address packet
	db 0x10 ; size of packet (16 bytes)
	db 0 ; reserved, always 0
	; number of segments to load
	; int 13 resets this to # of blocks actually read/written
	dw 2 ; read 2 sectors (2x512 bytes, 1kb)
    ; 4 byte memory buffer destination address (segment:offset format)
    ; we want the final address to be 0x0000:0x1000
    ; however, x86 is little endian so we put offset first and then segment
    ; memory map reference: https://www.cs.cmu.edu/~410-s07/p4/p4-boot.pdf
	dw 0x1000 ; offset
	dw 0x0000 ; segment
    dd 1 ; low 4 bytes of lba
	dd 0 ; high 4 bytes bits of lba

load_sectors:
    mov bx, s_drive
    call print

    mov ah, 00h ; reset disk
    mov dl, 0x80 ; first hard disk
    int 13h
    jc panic

   	mov ah, 41h ; "check extensions present" service
	mov bx, 0x55aa
	int 13h
	cmp bx, 0xaa55 ; on success, bx is set to hex aa55
	jne panic
	test cx, 1 ; Check support for the "fixed disk access subset"
	jz panic

    mov si, dap ; disk address packet
    mov ah, 42h ; extended read sectors from drive
    mov dl, 0x80
    int 13h
    jc panic

    ; maybe set data segments here for something that boot1 will like
    ; but for now, return
    ret

print:
    mov al, [bx]

    ; null check
    cmp al, 0
    je done

    ; print the character
    mov ah, 0eh ; display character
    int 10h ; call bios video service

    ; increment the pointer
    inc bx
    jmp print

done:
    ; put a newline at the end of each string we print
    ; so hacky but whatever works works

    mov ah, 03h ; get cursor position
    xor bh, bh ; page 0
    int 10h

    ; set cursor position
    mov ah, 02h
    inc dh ; cursor row is already in dh, so we need to add 1
    xor dl, dl ; col 0
    int 10h
    ret

panic:
    mov bx, s_panic
    call print
    jmp $


s_title: db "welcome to JaideOS v0.01", 0
s_welcome: db "hi marko!", 0
s_empty: db "", 0
s_drive: db "loading init sectors...", 0
s_panic: db "everything has gone wrong", 0
s_success: db "hello from address 0x0000:0x1000!", 0


; we have to be 512 bytes, so fill the rest of the bytes with 0s
times 510 - ($-$$) db 0
dw 0xAA55 ; magic number

; this code is now in the new sectors that are loaded in
; it should be in memory at 0x0000:0x1000)
jmp loader

loader: 
    mov bx, s_success
    call new_print
    jmp $

new_print:
    mov al, [bx]

    ; null check
    cmp al, 0
    je new_done

    ; print the character
    mov ah, 0eh ; display character
    int 10h ; call bios video service

    ; increment the pointer
    inc bx
    jmp new_print

new_done: ret
