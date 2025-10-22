#!/usr/bin/env bash
set -euo pipefail

BUILD_DIR="build"
BOOT0="$BUILD_DIR/boot/boot0.o"
BOOT1="$BUILD_DIR/boot/boot1.o"
KERNEL_BIN="$BUILD_DIR/kernel/kernel.bin"
DISK_IMG="$BUILD_DIR/disk/disk.img"

get_sectors() {
    local file="$1"
    local size
    size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file") # macOS vs Linux
    echo $(( (size + 511) / 512 ))
}

mkdir -p "$BUILD_DIR/disk"
dd if=/dev/zero of="$DISK_IMG" bs=1M count=100 status=none

BOOT0_SECTORS=$(get_sectors "$BOOT0")
BOOT1_SECTORS=$(get_sectors "$BOOT1")
KERNEL_SECTORS=$(get_sectors "$KERNEL_BIN")

BOOT0_LBA=0
BOOT1_LBA=1
KERNEL_LBA=$((BOOT1_LBA + BOOT1_SECTORS))
END_LBA=$((KERNEL_LBA + KERNEL_SECTORS))

echo "make: amending lba macros..."
make -s -C boot clean
make -s -C boot EXTRA_NASM_FLAGS="-D B1_SECTORS=$BOOT1_SECTORS -D KERNEL_SECTORS=$KERNEL_SECTORS -D KERNEL_LBA=$KERNEL_LBA"

echo "make: writing disk image to $DISK_IMG..."

BOOT0_BYTES=$(dd conv=notrunc if="$BOOT0" of="$DISK_IMG" bs=512 count=1 seek=0 2>&1 | grep 'bytes transferred' | awk '{print $1}')
BOOT1_BYTES=$(dd conv=notrunc if="$BOOT1" of="$DISK_IMG" bs=512 count="$BOOT1_SECTORS" seek=1 2>&1 | grep 'bytes transferred' | awk '{print $1}')
KERNEL_BYTES=$(dd conv=notrunc if="$KERNEL_BIN" of="$DISK_IMG" bs=512 count="$KERNEL_SECTORS" seek="$KERNEL_LBA" 2>&1 | grep 'bytes transferred' | awk '{print $1}')

# Pretty summary table
echo "______________________________________"
printf "| %-9s | %-9s | %-10s |\n" "boot0 ($BOOT0_LBA)" "boot1 ($BOOT1_LBA)" "kernel ($KERNEL_LBA)"
printf "| %-9s | %-9s | %-10s |\n" "$BOOT0_BYTES b" "$BOOT1_BYTES b" "$KERNEL_BYTES b"
echo "‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"
echo "make: build complete!"
