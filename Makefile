BUILD_DIR=build
BOOT0=$(BUILD_DIR)/boot/boot0.o
BOOT1=$(BUILD_DIR)/boot/boot1.o
KERNEL_BIN=$(BUILD_DIR)/kernel/kernel.bin
DISK_IMG=$(BUILD_DIR)/disk/disk.img

all: clear disk qemu

.PHONY: disk bootloader os

clear:
	@clear

bootloader:
	@echo "all: building bootloader"
	@make -s -C boot

os:
	@make -s -C kernel
	@echo "all: building kernel"

disk: bootloader os
	@mkdir -p $(BUILD_DIR)/disk
	@dd if=/dev/zero of=$(DISK_IMG) bs=1M count=100 status=none
	@if [ ! -f $(BOOT1) ]; then echo "Error: $(BOOT1) not found"; exit 1; fi
	@if [ ! -f $(KERNEL_BIN) ]; then echo "Error: $(KERNEL_BIN) not found"; exit 1; fi
	@BOOT1_SECTORS=$$(expr \( $$(stat -f%z $(BOOT1)) + 511 \) / 512); \
	KERNEL_SECTORS=$$(expr \( $$(stat -f%z $(KERNEL_BIN)) + 511 \) / 512); \
	KERNEL_LBA=$$((1 + $$BOOT1_SECTORS)); \
	echo "boot1 sectors=$$BOOT1_SECTORS kernel sectors=$$KERNEL_SECTORS lba=$$KERNEL_LBA"; \
	$(MAKE) -s -C boot EXTRA_NASM_FLAGS="-D B1_SECTORS=$$BOOT1_SECTORS -D KERNEL_LBA=$$KERNEL_LBA -D KERNEL_SECTORS=$$KERNEL_SECTORS"; \
	dd conv=notrunc if=$(BOOT0) of=$(DISK_IMG) bs=512 count=1 seek=0; \
	dd conv=notrunc if=$(BOOT1) of=$(DISK_IMG) bs=512 count=$$BOOT1_SECTORS seek=1; \
	dd conv=notrunc if=$(KERNEL_BIN) of=$(DISK_IMG) bs=512 count=$$KERNEL_SECTORS seek=$$KERNEL_LBA


qemu:
	@echo "all: launching qemu..."
	@qemu-system-i386 -drive file=$(DISK_IMG),format=raw,index=0,media=disk -boot c

clean:
	@make -C boot clean
	@make -C kernel clean
	@rm -f $(DISK_IMG)
	@echo "clean: complete."
