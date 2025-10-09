BUILD_DIR=../build/boot

BOOTLOADER_SRCS := $(wildcard *.asm)
BOOTLOADER_OBJS := $(patsubst %.asm, $(BUILD_DIR)/%.o, $(BOOTLOADER_SRCS))

all: $(BOOTLOADER_OBJS)

$(BUILD_DIR)/%.o: %.asm
	@mkdir -p $(BUILD_DIR)
	@nasm -i/mnt/c/Github/os/build/boot -f bin $< -o $@

clean:
	@rm -f $(BUILD_DIR)/*
