# PowerShell build script for OS project (simplified)

# Configuration
$BUILD_DIR = "build"
$BOOTLOADER_DIR = "$BUILD_DIR\bootloader"
$DISK_IMG = "disk.img"

# Function to create directory if it doesn't exist
function Test-Directory {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Host "Created directory: $Path"
    }
}

# Function to build bootloader
function New-Bootloader {
    Write-Host "Building bootloader..."
    
    # Find all .asm files in bootloader directory
    $asmFiles = Get-ChildItem -Path "bootloader" -Filter "*.asm"
    
    if ($asmFiles.Count -eq 0) {
        Write-Error "No .asm files found in bootloader directory"
        return $false
    }
    
    Test-Directory $BOOTLOADER_DIR
    
    foreach ($file in $asmFiles) {
        $outputFile = "$BOOTLOADER_DIR\$($file.BaseName).o"
        Write-Host "  Assembling $($file.Name) -> $outputFile"
        
        # Use nasm to assemble the file
        $result = & nasm -f bin $file.FullName -o $outputFile 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to assemble $($file.Name): $result"
            return $false
        }
    }
    
    Write-Host "Bootloader build completed successfully"
    return $true
}

# Function to create disk image
function New-Disk {
    Write-Host "Creating disk image..."
    
    $bootloaderFile = "$BOOTLOADER_DIR\bootloader.o"
    # $osFile = "$OS_DIR\sample.o"
    
    # Check if bootloader exists
    if (-not (Test-Path $bootloaderFile)) {
        Write-Error "Bootloader not found: $bootloaderFile"
        return $false
    }
    
    # Create 100MB disk image filled with zeros
    Write-Host "Creating 100MB disk image..."
    $null = New-Item -ItemType File -Path $DISK_IMG -Force
    $fs = [System.IO.File]::Create($DISK_IMG)
    $fs.SetLength(100 * 1024 * 1024)  # 100MB
    $fs.Close()
    
    # Write bootloader to first sector (512 bytes)
    Write-Host "Writing bootloader to disk..."
    $bootloaderData = [System.IO.File]::ReadAllBytes($bootloaderFile)
    $diskData = [System.IO.File]::ReadAllBytes($DISK_IMG)
    
    # Copy bootloader to first 512 bytes
    for ($i = 0; $i -lt [Math]::Min($bootloaderData.Length, 512); $i++) {
        $diskData[$i] = $bootloaderData[$i]
    }
    
    [System.IO.File]::WriteAllBytes($DISK_IMG, $diskData)
    
    Write-Host "Disk image created successfully: $DISK_IMG"
    return $true
}

# Function to run QEMU
function Start-QEMU {
    Write-Host "Starting QEMU..."
    
    if (-not (Test-Path $DISK_IMG)) {
        Write-Error "Disk image not found: $DISK_IMG"
        return $false
    }
    
    # Check if QEMU is available
    $qemuPath = Get-Command qemu-system-i386 -ErrorAction SilentlyContinue
    if (-not $qemuPath) {
        Write-Error "QEMU not found. Please install QEMU and ensure it's in your PATH."
        return $false
    }
    
    # Start QEMU with the disk image
    Write-Host "Launching QEMU with disk image: $DISK_IMG"
    & qemu-system-i386 -drive file=$DISK_IMG,format=raw,index=0,media=disk -boot c
}

## Main execution: build all and run

# Check if nasm is available
$nasmPath = Get-Command nasm -ErrorAction SilentlyContinue
if (-not $nasmPath) {
    Write-Error "NASM not found. Please install NASM and ensure it's in your PATH."
    exit 1
}

Write-Host "Building all components and running QEMU..."

if (-not (New-Bootloader)) {
    Write-Error "Bootloader build failed"
    exit 1
}

if (-not (New-Disk)) {
    Write-Error "Disk image creation failed"
    exit 1
}

Start-QEMU
Write-Host "Success"
