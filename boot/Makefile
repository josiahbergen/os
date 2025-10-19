BUILD_DIR=../build/boot
SRC_DIR=src

# discover sources from src directory, exclude util.asm (included via %include)
BOOTLOADER_SRCS := $(filter-out $(SRC_DIR)/util.asm,$(wildcard $(SRC_DIR)/*.asm))
BOOTLOADER_OBJS := $(patsubst $(SRC_DIR)/%.asm,$(BUILD_DIR)/%.o,$(BOOTLOADER_SRCS))

all: $(BOOTLOADER_OBJS)

# ensure boot1 is rebuilt when util.asm changes
$(BUILD_DIR)/boot1.o: $(SRC_DIR)/util.asm

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm
	@mkdir -p $(BUILD_DIR)
	@nasm -i$(SRC_DIR) $(EXTRA_NASM_FLAGS) -f bin $< -o $@

clean:
	@rm -f $(BUILD_DIR)/*
