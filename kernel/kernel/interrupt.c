#include <kernel/logging.h>
#include <kernel/util.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

#define IDT_ENTRIES 22

// the total entry is 64 bits long
struct gate_descriptor {
    uint32_t offset;
    uint16_t selector;        // https://wiki.osdev.org/Segment_Selector
    uint8_t gate_type;        // 4 bits
    uint8_t priveledge_level; // 2 bits
};

// idt with 256 gate descriptors (entres)
struct idt_32 {
    uint64_t entries[256];
};

// https://wiki.osdev.org/Interrupt_Descriptor_Table#Gate_Descriptor_2
void encode_gate_descriptor(uint64_t *desc, struct gate_descriptor gate) {

    if (gate.gate_type >> 4 > 0) {
        panic("idt gate type cannot contain > 4 bits");
    }
    if (gate.priveledge_level >> 2 > 0) {
        panic("idt gate priveledge level cannot contain > 2 bits");
    }

    *desc = 0;
    *desc |= (uint64_t)(gate.offset & 0xFFFF); // bits 0-15: offset part 1
    *desc |= (uint64_t)(gate.selector) << 16;  // bits 16-31: segment selector
    // bits 32-39 are reserved (set to zero at beginning)
    *desc |= (uint64_t)(gate.gate_type & 0xF) << 40; // bits 40-43: gate type
    // bit 44 is set to 0 at beginning
    *desc |= (uint64_t)(gate.priveledge_level & 0x3) << 45; // bits 45-46: dpl
    *desc |= (uint64_t)1 << 47; // bit 47 is the present bit, must be set to one
    // bits 48-63: offset part 2
    *desc |= (uint64_t)((gate.offset >> 16) & 0xFFFF) << 48;
}

struct interrupt_frame {
    uint32_t ip;
    uint32_t cs;
    uint32_t flags;
} PACKED;

static const char *exceptions[IDT_ENTRIES] = {"divide by zero",
                                              "debug",
                                              "NMI",
                                              "breakpoint",
                                              "overflow",
                                              "OOB",
                                              "invalid opcode",
                                              "no coprocessor",
                                              "double fault",
                                              "coprocessor segment overrun",
                                              "bad TSS",
                                              "segment not present",
                                              "stack fault",
                                              "general protection fault",
                                              "page fault",
                                              "unrecognized interrupt",
                                              "coprocessor fault",
                                              "alignment check",
                                              "machine check",
                                              "SIMD floating-point exception",
                                              "virtualization exception",
                                              "control protection exception"};

void int_panic(int entry, struct interrupt_frame *frame) {
    KERNEL_LOG(ERROR, "isr%d: %s", entry, exceptions[entry]);
    panic((char *)exceptions[entry]);
}

INTPT void isr0(struct interrupt_frame *frame) { int_panic(0, frame); }
INTPT void isr1(struct interrupt_frame *frame) { int_panic(1, frame); }
INTPT void isr2(struct interrupt_frame *frame) { int_panic(2, frame); }
INTPT void isr3(struct interrupt_frame *frame) { int_panic(3, frame); }
INTPT void isr4(struct interrupt_frame *frame) { int_panic(4, frame); }
INTPT void isr5(struct interrupt_frame *frame) { int_panic(5, frame); }
INTPT void isr6(struct interrupt_frame *frame) { int_panic(6, frame); }
INTPT void isr7(struct interrupt_frame *frame) { int_panic(7, frame); }
INTPT void isr8(struct interrupt_frame *frame) { int_panic(8, frame); }
INTPT void isr9(struct interrupt_frame *frame) { int_panic(9, frame); }
INTPT void isr10(struct interrupt_frame *frame) { int_panic(10, frame); }
INTPT void isr11(struct interrupt_frame *frame) { int_panic(11, frame); }
INTPT void isr12(struct interrupt_frame *frame) { int_panic(12, frame); }
INTPT void isr13(struct interrupt_frame *frame) { int_panic(13, frame); }
INTPT void isr14(struct interrupt_frame *frame) { int_panic(14, frame); }
INTPT void isr15(struct interrupt_frame *frame) { int_panic(15, frame); }
INTPT void isr16(struct interrupt_frame *frame) { int_panic(16, frame); }
INTPT void isr17(struct interrupt_frame *frame) { int_panic(17, frame); }
INTPT void isr18(struct interrupt_frame *frame) { int_panic(18, frame); }
INTPT void isr19(struct interrupt_frame *frame) { int_panic(19, frame); }
INTPT void isr20(struct interrupt_frame *frame) { int_panic(20, frame); }
INTPT void isr21(struct interrupt_frame *frame) { int_panic(21, frame); }

// isrs is an array of pointers to functions that
// take struct interrupt_frame * as an argument
static void (*isrs[])(struct interrupt_frame *) = {
    isr0,  isr1,  isr2,  isr3,  isr4,  isr5,  isr6,  isr7,
    isr8,  isr9,  isr10, isr11, isr12, isr13, isr14, isr15,
    isr16, isr17, isr18, isr19, isr20, isr21};

void load_idt() {
    KERNEL_LOG_BEG(LOG, "idt init... ");

    static struct idt_32 idt;
    for (int i = 0; i < IDT_ENTRIES; i++) {

        struct gate_descriptor gate;
        // entry point to the isr
        gate.offset = (uintptr_t)isrs[i];

        // https://wiki.osdev.org/Segment_Selector
        // also see page 3199 of Intel® 64 and IA-32 Architectures SDM
        gate.selector = 0x08; // kernel code segment

        // TODO: all interrupt (fatal) gates for now, some need to be traps
        gate.gate_type = 0xE;      // 32-bit Interrupt Gate
        gate.priveledge_level = 0; // ring 0 (kernel)

        encode_gate_descriptor(&idt.entries[i], gate);
    }

    // set up idtr (idt descriptor register)
    // https://wiki.osdev.org/Interrupt_Descriptor_Table#IDTR
    struct idt_descriptor {
        uint16_t size;
        uint32_t offset;
    } PACKED idtr;

    idtr.size = sizeof(struct idt_32) - 1; // size of idt - 1
    idtr.offset = (uint32_t)&idt;

    // load it
    asm("lidt %0" : : "m"(idtr));

    // hope for the best
    KERNEL_LOG_END(SUCCESS, "ok");
}
