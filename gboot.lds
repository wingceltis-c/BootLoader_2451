OUTPUT_ARCH(arm)
ENTRY(_start)
SECTIONS{
	. = 0x40000000;

	. = ALIGN(4);
		.text :
		{
			start.o(.text)
			*(.text)
		}
	 . = ALIGN(4);
		.rodata : 
		{
			*(.rodata*)
		} 
		
	. = ALIGN(4);
		.data :
		{
			*(.data)
		}

	. = ALIGN(4);
		bss_start = .;
		.bss :
		{
			*(.bss)
		}
		bss_end = .;
}
