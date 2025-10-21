CC = i686-elf-gcc
LD = i686-elf-ld
OBJCOPY = i686-elf-objcopy
SRC_DIR = src
BUILD_DIR = ../build/kernel

# flags
CFLAGS = -m32 -ffreestanding -O2 -Wall -Wextra -I$(SRC_DIR)
LDFLAGS = -m elf_i386 -T linker.ld -nostdlib

# get all c files, but ensure kernel.c comes first
KERNEL_SRC = $(SRC_DIR)/kernel.c
OTHER_SRC = $(filter-out $(KERNEL_SRC), $(wildcard $(SRC_DIR)/*.c))
SRC = $(KERNEL_SRC) $(OTHER_SRC)
OBJ = $(SRC:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)

# output
KERNEL_ELF = $(BUILD_DIR)/kernel.elf
KERNEL_BIN = $(BUILD_DIR)/kernel.bin
all: $(KERNEL_BIN)

# compile the c files into object files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c -o $@ $<

# link all object files to the kernel elf
$(KERNEL_ELF): $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $^

# convert to flat binary
$(KERNEL_BIN): $(KERNEL_ELF)
	$(OBJCOPY) -O binary $< $@

clean:
	@rm -rf $(BUILD_DIR)
