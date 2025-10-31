CC = i686-elf-gcc
LD = i686-elf-ld
OBJCOPY = i686-elf-objcopy
SRC_DIR = .
BUILD_DIR = ../build/kernel
SYSROOT = ../sysroot

# flags
CFLAGS = -m32 -ffreestanding -O2 -Wall -Wextra -I./include -I./arch/i386 -I$(SYSROOT)/usr/include
LDFLAGS = -m elf_i386 -T arch/i386/linker.ld -nostdlib -L$(SYSROOT)/usr/lib

# get all source files
ASM_SRC = $(wildcard arch/i386/*.s)
KERNEL_SRC = kernel/kernel.c
OTHER_SRC = $(filter-out $(KERNEL_SRC), $(wildcard kernel/*.c) $(wildcard arch/i386/*.c))
C_SRC = $(KERNEL_SRC) $(OTHER_SRC)
OBJ = $(ASM_SRC:%.s=$(BUILD_DIR)/%.o) $(C_SRC:%.c=$(BUILD_DIR)/%.o)

# output
KERNEL_ELF = $(BUILD_DIR)/kernel.elf
KERNEL_BIN = $(BUILD_DIR)/kernel.bin
all: $(KERNEL_BIN)

AS = i686-elf-as
ASFLAGS = --32

# compile assembly files
$(BUILD_DIR)/%.o: %.s | $(BUILD_DIR)
	@mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -o $@ $<

# compile the c files into object files
$(BUILD_DIR)/%.o: %.c | $(BUILD_DIR)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<


# link all object files to the kernel elf
$(KERNEL_ELF): $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $^ -lk

# convert to flat binary
$(KERNEL_BIN): $(KERNEL_ELF)
	$(OBJCOPY) -O binary $< $@

clean:
	@rm -rf $(BUILD_DIR)

install-headers:
	@mkdir -p $(SYSROOT)/usr/include
	@cp -R include/. $(SYSROOT)/usr/include/.

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)
