BUILD_DIR=../build/boot
FULL_SRC_PATH="/Users/josiah/Projects/os/boot"

BOOTLOADER_SRCS := $(filter-out util.asm,$(wildcard *.asm))
BOOTLOADER_OBJS := $(patsubst %.asm, $(BUILD_DIR)/%.o, $(BOOTLOADER_SRCS))

all: $(BOOTLOADER_OBJS)

# ensure boot1 is rebuilt when util.asm changes
$(BUILD_DIR)/boot1.o: util.asm

$(BUILD_DIR)/%.o: %.asm
	@mkdir -p $(BUILD_DIR)
	@nasm -i$(FULL_SRC_PATH) -f bin $< -o $@

clean:
	@rm -f $(BUILD_DIR)/*
