
MEMORY {
    rom ( rx)    : ORIGIN = 0x00000000, LENGTH = 1K
    ram (rwx)    : ORIGIN = 0x00010000, LENGTH = 64K
    ext (rwx)    : ORIGIN = 0x12000000, LENGTH = 64K
}

SECTIONS {

    . = ORIGIN(ram);

    .text ALIGN(8) : SUBALIGN(8) {
        *(.text.boot) 
        *(.text.*) 
        *(.text) 
        . = ALIGN(4);
    } > ram
    .data  ALIGN(8) : SUBALIGN(8) { *(.data.*) } > ram
    .sdata ALIGN(8) : SUBALIGN(8) { *(.sdata.*) } > ram
    .bss   ALIGN(8) : SUBALIGN(8) { *(.bss)    } > ram
    .sbss  ALIGN(8) : SUBALIGN(8) { *(.sbss)    } > ram

    /DISCARD/ : { *(.comment) }

    PROVIDE (__fsbl_stack_start = ORIGIN(ram) + LENGTH(ram) - 16);

    PROVIDE (__rom_begin        = ORIGIN(rom)               );
    PROVIDE (__rom_length       =               LENGTH(rom) );
    PROVIDE (__rom_end          = ORIGIN(rom) + LENGTH(rom) );
    
    PROVIDE (__ram_begin        = ORIGIN(ram)               );
    PROVIDE (__ram_length       =               LENGTH(ram) );
    PROVIDE (__ram_end          = ORIGIN(ram) + LENGTH(ram) );
    
    PROVIDE (__ext_begin        = ORIGIN(ext)               );
    PROVIDE (__ext_length       =               LENGTH(ext) );
    PROVIDE (__ext_end          = ORIGIN(ext) + LENGTH(ext) );

}

