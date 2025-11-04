#include <kernel/util.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>

// https://wiki.osdev.org/Interrupt_Descriptor_Table#IDTR
struct idt_descriptor {
    uint16_t size;
    uint32_t offset;
};

// the total entry is 64 bits long
struct pretty_gate_descriptor {
    uint32_t offset;
    uint16_t segment_selector; // https://wiki.osdev.org/Segment_Selector
    uint8_t gate_type;         // 4 bits
    uint8_t priveledge_level;  // 2 bits
    bool present;              // a single bit, must be set to true
};

struct pretty_segment_descriptor {};

// https://wiki.osdev.org/Segment_Selector
uint16_t encode_segment_descriptor() {
    uint16_t desc = 0; // TODO: implement
    return desc;
}

// https://wiki.osdev.org/Interrupt_Descriptor_Table#Gate_Descriptor_2
uint64_t encode_gate_descriptor() {
    uint64_t desc = 0; // TODO: implement
    return desc;
}

void load_idt() { panic("idt not implemented"); }

// struct interrupt_frame {
//     uint32_t ip;
//     uint32_t cs;
//     uint32_t flags;
//     uint32_t sp;
//     uint32_t ss;
// };

// __attribute__((interrupt)) void
// interrupt_handler(struct interrupt_frame *frame) {
//     printf("interrupt called: %p", frame);
// }
