# Build directories
$BUILD_DIR = "build\bootloader"
New-Item -ItemType Directory -Force $BUILD_DIR | Out-Null

# Assemble all bootloader files
Get-ChildItem "bootloader\*.asm" | ForEach-Object {
    $output = "$BUILD_DIR\$($_.BaseName).o"
    nasm -iC:\GitHub\os\bootloader -f bin $_.FullName -o $output
}

# Create disk image
$disk = "disk.img"
$fs = [System.IO.File]::Create($disk)
$fs.SetLength(100MB)
$fs.Close()

# Write all bootloader components
$diskData = [System.IO.File]::ReadAllBytes($disk)
$pos = 0
Get-ChildItem "$BUILD_DIR\*.o" | ForEach-Object {
    $bootData = [System.IO.File]::ReadAllBytes($_.FullName)
    [Array]::Copy($bootData, 0, $diskData, $pos, $bootData.Length)
    $pos += $bootData.Length
}
[System.IO.File]::WriteAllBytes($disk, $diskData)

# Run QEMU
qemu-system-i386 -drive file=$disk,format=raw,index=0,media=disk -boot c