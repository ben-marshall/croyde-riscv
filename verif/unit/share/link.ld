
SECTIONS {

    . = 0x10000000;

    .text : { *(.text.*) }
    .data : { *(.data.*) }
    .bss  : { *(.bss) }

    /DISCARD/ : { *(.comment) }

}
