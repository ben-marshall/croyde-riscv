
ENTRY(test_main)

MEMORY {
    rom (rx)    : ORIGIN = 0x00000000, LENGTH = 1K
    ram (rx)    : ORIGIN = 0x00010000, LENGTH = 64K
}

SECTIONS {

    . = ORIGIN(ram);

    .text ALIGN(4) : SUBALIGN(4) {
        *(.text.*) 
        *(.text) 
        . = ALIGN(4);
    } > ram
    .data ALIGN(4) : SUBALIGN(4) { *(.data.*) } > ram
    .bss  ALIGN(4) : SUBALIGN(4) { *(.bss)    } > ram

    /DISCARD/ : { *(.comment) }

    PROVIDE (__fsbl_stack_start = ORIGIN(ram) + LENGTH(ram) - 16);

    PROVIDE (__rom_begin        = ORIGIN(rom)               );
    PROVIDE (__rom_length       =               LENGTH(rom) );
    PROVIDE (__rom_end          = ORIGIN(rom) + LENGTH(rom) );
    
    PROVIDE (__ram_begin        = ORIGIN(ram)               );
    PROVIDE (__ram_length       =               LENGTH(ram) );
    PROVIDE (__ram_end          = ORIGIN(ram) + LENGTH(ram) );

}

