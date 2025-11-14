## small os hobby project

featuring a custom 32-bit x86 operating system kernel, custom two-stage MBR bootloader, and am easy(ish) cross-compiler toolchain!

the eventual goal is to create a small higher-half kernel that is capable of:

- running a shell
- memory paging
- reading and running binary files from a filesystem

### quickstart (macos only!)

firstly, install homebrew if you don't have it already: https://brew.sh

```bash
brew install i686-elf-gcc i686-elf-binutils nasm qemu

# optional deps (try these if i686-elf-gcc isn't installing)
# brew install pkgconf texinfo zstd

# build everything and lauch qemu
make # it's that easy!
```

there are a few other make targets, too...

```bash
# the build system automatically handles any dependencies.
make all           # build everything (default)
make help          # show available targets
make clean         # clean all build artifacts
make prep          # create build directories
make headers       # install system headers
make libc          # build libc library
make boot          # build bootloader
make kernel        # build kernel
make disk          # create disk image
make qemu          # launch qemu
```

### file structure

```
os/
├── Makefile               # main build system
├── boot/                  # bootloader source
├── kernel/                # kernel source
│   ├── arch/i386/         # architecture-specific code
│   ├── include/kernel/    # kernel headers
│   └── kernel/            # core kernel code
├── libc/                  # standard C library
├── scripts/               # build scripts
├── build/                 # build output (generated)
│   └── disk/              # disk image will be here!
└── sysroot/               # system root (generated)
```
