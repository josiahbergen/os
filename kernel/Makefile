CC = i686-elf-gcc
LD = i686-elf-ld
OBJCOPY = i686-elf-objcopy
SRC_DIR = kernel
BUILD_DIR = build

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

# Run with QEMU
run: $(KERNEL_BIN)
	qemu-system-i386 -kernel $(KERNEL_BIN)

# Debug with GDB stub
debug: $(KERNEL_ELF)
	qemu-system-i386 -kernel $(KERNEL_ELF) -S -s
	# Then in another terminal:
	# i386-elf-gdb -ex "target remote localhost:1234" -ex "symbol-file $(KERNEL_ELF)"

# Clean build files
clean:
	rm -rf $(BUILD_DIR)
