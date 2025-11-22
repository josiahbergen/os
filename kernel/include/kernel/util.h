
void panic(char *message);
void halt();

void arch_halt();
void arch_reset();

#define PACKED __attribute__((packed))
#define INTPT __attribute__((interrupt))

#ifndef asm
#define asm __asm__ volatile
#endif
