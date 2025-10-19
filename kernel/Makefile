CC = i686-elf-gcc
LD = i686-elf-ld
OBJCOPY = i686-elf-objcopy
SRC_DIR = src
BUILD_DIR = ../build/kernel

# Collect all C source files in kernel directory
SRC = $(wildcard $(SRC_DIR)/*.c)
OBJ = $(SRC:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)

# Build flags
CFLAGS = -m32 -ffreestanding -O2 -Wall -Wextra -I$(SRC_DIR)
LDFLAGS = -m elf_i386 -T linker.ld -nostdlib

# Output files
KERNEL_ELF = $(BUILD_DIR)/kernel.elf
KERNEL_BIN = $(BUILD_DIR)/kernel.bin

# Default target
all: $(KERNEL_BIN)

# Create build directory if it doesn't exist
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Compile each .c file into an object
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c -o $@ $<

# Link all objects into a kernel ELF
$(KERNEL_ELF): $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $^

# Convert ELF to raw binary
$(KERNEL_BIN): $(KERNEL_ELF)
	$(OBJCOPY) -O binary $< $@

# Clean build files
clean:
	rm -rf $(BUILD_DIR)
