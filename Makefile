BUILD_DIR=build
BOOT0=$(BUILD_DIR)/boot/boot0.o
BOOT1=$(BUILD_DIR)/boot/boot1.o
OS=$(BUILD_DIR)/os/kernel.c
DISK_IMG=$(BUILD_DIR)/disk/disk.img

all: clear disk qemu

.PHONY: disk bootloader os

clear:
	@clear

bootloader:
	@echo "all: building bootloader"
	@make -s -C boot

os:
	@echo "all: building kernel"
	@# make -s -C kernel

disk: bootloader os
	@mkdir -p $(BUILD_DIR)/disk
	@dd if=/dev/zero of=$(DISK_IMG) bs=1M count=100 status=none
	@bytes=$$(dd conv=notrunc if=$(BOOT0) of=$(DISK_IMG) bs=512 count=1 seek=0 2>&1 | grep 'bytes transferred' | awk '{print $$1}'); \
	echo "all: wrote boot0 ($${bytes} bytes)"
	@bytes=$$(dd conv=notrunc if=$(BOOT1) of=$(DISK_IMG) bs=512 count=8 seek=1 2>&1 | grep 'bytes transferred' | awk '{print $$1}'); \
	echo "all: wrote boot1 ($${bytes} bytes)"

qemu:
	@echo "all: launching qemu..."
	@qemu-system-i386 -drive file=$(DISK_IMG),format=raw,index=0,media=disk -boot c

clean:
	@make -C boot clean
	@make -C kernel clean
	@rm -f $(DISK_IMG)
	@echo "clean: complete."
