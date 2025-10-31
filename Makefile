# OS Build System
# Main Makefile for building the operating system

# Build configuration
BUILD_DIR = build
SYSROOT = sysroot
HOST = i686-elf
HOSTARCH = i386

# Toolchain
CROSS_CC = $(HOST)-gcc
CROSS_LD = $(HOST)-ld
CROSS_AR = $(HOST)-ar
CROSS_AS = $(HOST)-as
CROSS_OBJCOPY = $(HOST)-objcopy

# Paths
BOOT0 = $(BUILD_DIR)/boot/boot0.o
BOOT1 = $(BUILD_DIR)/boot/boot1.o
KERNEL_BIN = $(BUILD_DIR)/kernel/kernel.bin
DISK_IMG = $(BUILD_DIR)/disk/disk.img

QEMU_FLAGS =

# Environment variables
export HOST
export HOSTARCH
export DESTDIR = $(CURDIR)/$(SYSROOT)
export MAKE
export AR = $(CROSS_AR)
export AS = $(CROSS_AS)
export CC = $(CROSS_CC) --sysroot=$(CURDIR)/$(SYSROOT)
export PREFIX = /usr
export EXEC_PREFIX = $(PREFIX)
export BOOTDIR = /boot
export LIBDIR = $(EXEC_PREFIX)/lib
export INCLUDEDIR = $(PREFIX)/include
export CFLAGS = -O2 -g
export CPPFLAGS =

# Work around that the -elf gcc targets doesn't have a system include directory
ifeq ($(findstring -elf,$(HOST)),-elf)
export CC = $(CROSS_CC) --sysroot=$(CURDIR)/$(SYSROOT) -isystem=$(INCLUDEDIR)
endif

# Projects
SYSTEM_HEADER_PROJECTS = libc kernel
PROJECTS = libc kernel

.PHONY: all clean prep headers libc boot kernel disk qemu help

# Default target
all: prep headers libc boot kernel disk qemu clean
tidy: prep headers libc boot kernel disk qemu clean

# Help target
help:
	@echo "available make targets:"
	@echo "you could probably look at the readme for help as well"
	@echo "  all         build it all (default)"
	@echo "  clean       clean all build artifacts"
	@echo "  prep        create build directories"
	@echo "  libc        build libc library"
	@echo "  boot        build bootloader"
	@echo "  kernel      build kernel"
	@echo "  disk        create disk image"
	@echo "  qemu        launch qemu"
	@echo "  help        show this help"

# Clear screen
clear:
	@clear

# Create build directories
prep:
	@echo "make: creating build directories..."
	@mkdir -p $(BUILD_DIR)/boot
	@mkdir -p $(BUILD_DIR)/kernel
	@mkdir -p $(BUILD_DIR)/disk

# Install system headers
headers: prep
	@echo "make: installing system headers..."
	@mkdir -p $(SYSROOT)
	@for project in $(SYSTEM_HEADER_PROJECTS); do \
		(cd $$project && $(MAKE) -s install-headers); \
	done

# Build libc library
libc: headers
	@echo "make: building libc..."
	@$(MAKE) -s -C libc install

# Build bootloader
boot: prep
	@echo "make: building bootloader..."
	@$(MAKE) -s -C boot

# Build kernel
kernel: libc
	@echo "make: building kernel..."
	@$(MAKE) -s -C kernel

# Create disk image
disk: boot kernel
	@echo "make: creating disk image..."
	@./scripts/disk.sh

# Launch QEMU
qemu: disk
	@echo "make: launching qemu..."
	@qemu-system-i386 -drive file=$(DISK_IMG),format=raw,index=0,media=disk -boot c $(QEMU_FLAGS)

# Clean build artifacts
clean:
	@echo "clean: removing build artifacts..."
	@$(MAKE) -s -C boot clean
	@$(MAKE) -s -C kernel clean
	@$(MAKE) -s -C libc clean
	@rm -rf $(BUILD_DIR)/disk
	@rm -rf $(SYSROOT)
	@echo "clean: done."
