BUILD_DIR=build
BOOT0=$(BUILD_DIR)/boot/boot0.o
BOOT1=$(BUILD_DIR)/boot/boot1.o
KERNEL_BIN=$(BUILD_DIR)/kernel/kernel.bin
DISK_IMG=$(BUILD_DIR)/disk/disk.img

all: clear prep boot kernel disk qemu

.PHONY: disk boot kernel

clear:
	@clear

prep:
	@mkdir -p build/boot
	@mkdir -p build/kernel
	@mkdir -p build/disk

boot:
	@echo "all: building bootloader..."
	@make -s -C boot

kernel:
	@make -s -C kernel
	@echo "all: building kernel..."

disk:
	@./scripts/disk.sh

qemu:
	@echo "all: launching qemu..."
	@qemu-system-i386 -drive file=$(DISK_IMG),format=raw,index=0,media=disk -boot c

clean:
	@make -C boot clean
	@make -C kernel clean
	@rm -rf $(BUILD_DIR)/disk
	@echo "clean: done"
