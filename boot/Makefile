BUILD_DIR=../build/boot
SRC_DIR=src

# discover sources from src directory, exclude stuff that is %included
SRC := $(SRC_DIR)/boot0.asm $(SRC_DIR)/boot1.asm
OBJ := $(patsubst $(SRC_DIR)/%.asm,$(BUILD_DIR)/%.o,$(SRC))

all: $(OBJ)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm
	@mkdir -p $(BUILD_DIR)
	@nasm -i$(SRC_DIR) $(EXTRA_NASM_FLAGS) -f bin $< -o $@

clean:
	@rm -f $(BUILD_DIR)/*
