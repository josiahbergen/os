BUILD_DIR=build
BOOT0=$(BUILD_DIR)/bootloader/boot0.o
BOOT1=$(BUILD_DIR)/bootloader/boot1.o
OS=$(BUILD_DIR)/os/sample.o
DISK_IMG=disk.img

all: disk qemu

.PHONY: disk bootloader os

bootloader:
	@make -C bootloader

os:
	@make -C os

disk: bootloader os
	@dd if=/dev/zero of=$(DISK_IMG) bs=1M count=100
	@dd conv=notrunc if=$(BOOT0) of=$(DISK_IMG) bs=512 count=1 seek=0
	@dd conv=notrunc if=$(BOOT1) of=$(DISK_IMG) bs=512 count=1 seek=1


qemu:
	@qemu-system-i386 -drive file=$(DISK_IMG),format=raw,index=0,media=disk -boot c

clean:
	make -C bootloader clean
	make -C os clean
	rm -f $(DISK_IMG)
