
ENTRY(__fsbl_boot)

MEMORY {
    rom (rx)    : ORIGIN = 0x00000000, LENGTH = 1K
}

SECTIONS {

    . = 0x00000000;

    .text ALIGN(4) : SUBALIGN(4) {
        *(.text.fsbl) 
        *(.text.*) 
        *(.text) 
        . = ALIGN(4);
    } > rom
    .data ALIGN(4) : SUBALIGN(4) { *(.data.*) } > rom
    .bss  ALIGN(4) : SUBALIGN(4) { *(.bss)    } > rom

    /DISCARD/ : { *(.comment) }

    . = ALIGN(16);

    PROVIDE (__fsbl_stack_start = .);

}

