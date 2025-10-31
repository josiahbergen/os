/* The bootloader will look at this image and start execution at the symbol
   designated at the entry point. */
ENTRY(_start)

/* Tell where the various sections of the object files will be put in the final
   kernel image. */
SECTIONS
{
	/* The kernel will live at 3GB + 1MB in the virtual address space,
	   which will be mapped to 1MB in the physical address space. */
	. = 0x00100000;

	_kernel_start = .;

	/* Now switch to virtual addresses (add 3GB) */
	. += 0xC0000000;

	/* Put the .text section first.
	   Note that we page-align the sections.
	   AT() directive specifies the physical load address.
	   Make sure .text starts at exactly 0x00100000 physical. */
	.text : AT(0x00100000)
	{
		*(.text)
	}
	/* Read-only data. */
	.rodata ALIGN(4K) : AT(ADDR(.rodata) - 0xC0000000)
	{
		*(.rodata)
	}

	/* Read-write data (initialized) */
	.data ALIGN(4K) : AT(ADDR(.data) - 0xC0000000)
	{
		*(.data)
	}

	/* Read-write data (uninitialized) and stack */
	.bss ALIGN(4K) : AT(ADDR(.bss) - 0xC0000000)
	{
		*(COMMON)
		*(.bss)
		*(.bootstrap_stack)
	}

	_kernel_end = .;
}


