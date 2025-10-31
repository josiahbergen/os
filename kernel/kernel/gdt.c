#include <kernel/logging.h>
#include <kernel/tty.h>
#include <kernel/util.h>
#include <stdint.h>

struct pretty_gdt_entry {
    uint32_t base;
    // limit is technically a 20 bit value instead of 32
    // but this is checked in encode_gdt_entry
    uint32_t limit;
    uint8_t access;
    uint8_t flags;
};

struct flat_mode_gdt {
    struct pretty_gdt_entry null_segment;
    struct pretty_gdt_entry kernel_mode_cs;
    struct pretty_gdt_entry kernel_mode_ds;
    struct pretty_gdt_entry user_mode_cs;
    struct pretty_gdt_entry user_mode_ds;
    struct pretty_gdt_entry task_state_segment;
};

struct pretty_gdt_entry generate_null_entry() {
    struct pretty_gdt_entry null = {0, 0, 0, 0};
    return null;
}

void load_gdt();

void encode_gdt_entry(uint8_t *target, struct pretty_gdt_entry src) {

    // takes the pretty gdt entry format and converts it into usable
    // entries while moving the data into memory at target

    // limit cannot exceed 0xfffff
    if (src.limit > 0xfffff) {
        panic("gdt cannot encode limits larger than 0xfffff");
    }

    // encode limit
    target[0] = src.limit & 0xFF;
    target[1] = (src.limit >> 8) & 0xFF;
    target[6] = (src.limit >> 16) & 0x0F;

    // encode base
    target[2] = src.base & 0xFF;
    target[3] = (src.base >> 8) & 0xFF;
    target[4] = (src.base >> 16) & 0xFF;
    target[7] = (src.base >> 24) & 0xFF;

    // encode access byte
    target[5] = src.access;

    // encode flags
    target[6] |= (src.flags << 4);
}

void gdt_init() {

    // we are going to not use segmentation (just paging)
    // so the only segment descriptors we need are the
    // null descriptor, code/data segments for kernel/user mode,
    // and system descriptors (i.e. task state segment)
    //
    // table layout:
    // https://wiki.osdev.org/GDT_Tutorial#Flat_/_Long_Mode_Setup

    asm("cli"); // disable interrupts

    panic("gdt not implemented");
}
