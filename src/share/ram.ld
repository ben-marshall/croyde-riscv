
ENTRY(__fsbl_boot)

MEMORY {
    rom ( rx)    : ORIGIN = 0x00000000, LENGTH = 1K
    ram (wrx)    : ORIGIN = 0x00010000, LENGTH = 64K
}

SECTIONS {

    . = ORIGIN(ram);

    .text ALIGN(8) : SUBALIGN(8) {
        *(.text.fsbl) 
        *(.text.*) 
        *(.text) 
        . = ALIGN(4);
    } > ram
    .data ALIGN(8) : SUBALIGN(8) { *(.data.*) } > ram
    .bss  ALIGN(8) : SUBALIGN(8) { *(.bss)    } > ram
    .sbss  ALIGN(8) : SUBALIGN(8) { *(.sbss)    } > ram

    /DISCARD/ : { *(.comment) }

    PROVIDE (__fsbl_stack_start = ORIGIN(ram) + LENGTH(ram) - 16);

    PROVIDE (__rom_begin        = ORIGIN(rom)               );
    PROVIDE (__rom_length       =               LENGTH(rom) );
    PROVIDE (__rom_end          = ORIGIN(rom) + LENGTH(rom) );
    
    PROVIDE (__ram_begin        = ORIGIN(ram)               );
    PROVIDE (__ram_length       =               LENGTH(ram) );
    PROVIDE (__ram_end          = ORIGIN(ram) + LENGTH(ram) );

}

