b1_s_title: db "WELCOME TO THE JAIDEOS BOOTLOADER (v0.01)", 10, 0
b1_s_welcome: db "hi marko!", 10, 10, 0

b1_s_memory: db "conventional memory (kb): ", 0
b1_s_low_memory: db "extended memory between 1m and 16m (kb): ", 0
b1_s_high_memory: db "64k blocks of extended memory above 16m: ", 0
b1_s_set_video: db "setting video mode... ", 0
b1_s_video_info: db "current video mode: 720x400px (80x25ch) 16 color VGA", 0
b1_s_load_gdt: db "loading global descriptor table... ", 0

b1_s_navbar_text: db "[ LOAD KERNEL ]   [ RESTART ]   [ PANIC ]   [ DO NOTHING ]", 0
b1_s_load_finished: db 10, "press ENTER to boot or use the arrow keys to select another action. ", 0

b1_s_loading_kernel: db "loading kernel into 0x00010000... ", 0
b1_s_enabling_a20: db "checking and enabling a20... ", 0
b1_s_protected: db "entering 32-bit protected mode...", 0

b1_s_success: db "OK", 10, 0
b1_s_panic: db "PANIC: bootloader failure", 10, "everything has gone terribly wrong", 10, 10, "this computer will automatically reboot in 5 seconds.", 10, 0
