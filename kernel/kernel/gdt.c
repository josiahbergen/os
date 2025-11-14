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
    uint64_t null_segment;
    uint64_t kernel_mode_cs;
    uint64_t kernel_mode_ds;
    uint64_t user_mode_cs;
    uint64_t user_mode_ds;
    // uint64_t task_state_segment;
};

void encode_descriptor(uint64_t *descriptor, struct pretty_gdt_entry src) {

    // limit cannot exceed 0xfffff (20 bits)
    if (src.limit > 0xfffff) {
        panic("gdt cannot encode limits larger than 0xfffff");
    }
    *descriptor = 0;

    // limit bits 0-15 (0-15)
    *descriptor |= (uint64_t)(src.limit & 0xFFFF);
    // base bits 0-23 (16-39)
    *descriptor |= (uint64_t)(src.base & 0xFFFFFF) << 16;
    // access byte (40-47)
    *descriptor |= (uint64_t)src.access << 40;
    // limit bits 16-19 (48-51)
    *descriptor |= (uint64_t)((src.limit >> 16) & 0x0F) << 48;
    // flags (52-55)
    *descriptor |= (uint64_t)(src.flags & 0x0F) << 52;
    // base bits 24-31 (56-63)
    *descriptor |= (uint64_t)((src.base >> 24) & 0xFF) << 56;
}

void load_gdt() {

    // we are going to not use segmentation (just paging)
    // so the only segment descriptors we need are the
    // null descriptor, code/data segments for kernel/user mode,
    // and system descriptors (i.e. task state segment)
    //
    // table layout:
    // https://wiki.osdev.org/GDT_Tutorial#Flat_/_Long_Mode_Setup

    KERNEL_LOG_BEG(LOG, "gdt init... ");
    asm volatile("cli"); // disable interrupts

    struct pretty_gdt_entry null_segment = {0, 0, 0, 0};
    struct pretty_gdt_entry kernel_mode_cs = {0, 0xFFFFF, 0x9A, 0x0C};
    struct pretty_gdt_entry kernel_mode_ds = {0, 0xFFFFF, 0x92, 0x0C};
    struct pretty_gdt_entry user_mode_cs = {0, 0xFFFFF, 0xFA, 0x0C};
    struct pretty_gdt_entry user_mode_ds = {0, 0xFFFFF, 0xF2, 0x0C};

    // TODO: add task state segment
    // struct pretty_gdt_entry p_task_state_segment = {0, 0, 0x89, 0x0};

    struct flat_mode_gdt gdt;
    encode_descriptor(&gdt.null_segment, null_segment);
    encode_descriptor(&gdt.kernel_mode_cs, kernel_mode_cs);
    encode_descriptor(&gdt.kernel_mode_ds, kernel_mode_ds);
    encode_descriptor(&gdt.user_mode_cs, user_mode_cs);
    encode_descriptor(&gdt.user_mode_ds, user_mode_ds);

    // prepare gdt descriptor (6 bytes: 16-bit limit and 32-bit base)
    // the struct must be marked as packed to stop the compiler
    // from adding padding, which would mess things up
    struct {
        uint16_t limit;
        uint32_t base;
    } __attribute__((packed)) gdtr;

    // https://wiki.osdev.org/Global_Descriptor_Table#GDTR
    gdtr.limit = sizeof(struct flat_mode_gdt) - 1;
    gdtr.base = (uint32_t)&gdt;

    // load it!!
    asm volatile("lgdt %0" : : "m"(gdtr));

    // reload segment registers, hopefully
    KERNEL_LOG_END(SUCCESS, "ok");

    // if no triple fault has occurred, then we should be good to go.
    // TODO: implement sanity checks and error handing
    KERNEL_LOG(WARN, "segment registers not reloaded");
    return;
}
