
SECTIONS {

    . = 0x10000000;

    .text : { *(.text.*) }
    .data : { *(.data.*) }
    .bss  : { *(.bss) }

    /DISCARD/ : { *(.comment) }

    . = ALIGN(16);

    PROVIDE (__fsbl_stack_start = 0x10003FF0);

}
