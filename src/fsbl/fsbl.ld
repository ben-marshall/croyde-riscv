
ENTRY(__fsbl_boot)

MEMORY {
    rom ( rx)    : ORIGIN = 0x00000000, LENGTH = 1K
    ram (wrx)    : ORIGIN = 0x00010000, LENGTH = 64K
}

SECTIONS {

    . = ORIGIN(rom);

    .text ALIGN(4) : SUBALIGN(4) {
        *(.text.fsbl) 
        *(.text.*) 
        *(.text) 
        . = ALIGN(4);
    } > rom
    .data ALIGN(4) : SUBALIGN(4) { *(.data.*) } > rom
    .bss  ALIGN(4) : SUBALIGN(4) { *(.bss)    } > rom

    /DISCARD/ : { *(.comment) }

    PROVIDE (__fsbl_stack_start = ORIGIN(ram) + LENGTH(ram) - 16);

    PROVIDE (__rom_begin        = ORIGIN(rom)               );
    PROVIDE (__rom_length       =               LENGTH(rom) );
    PROVIDE (__rom_end          = ORIGIN(rom) + LENGTH(rom) );
    
    PROVIDE (__ram_begin        = ORIGIN(ram)               );
    PROVIDE (__ram_length       =               LENGTH(ram) );
    PROVIDE (__ram_end          = ORIGIN(ram) + LENGTH(ram) );

}

