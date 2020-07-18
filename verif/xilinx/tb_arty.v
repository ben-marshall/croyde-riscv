
//
// module: tb_arty
//
//  Simple testbench for visually checking the CCX + Vivado block
//  design works correctly.
//
module tb_arty ();

reg [3:0]   dip_switches_4bits_tri_i;
tri [3:0]   led_4bits_tri_io        ;
reg         resetn                  ;
reg         sys_clock               ;
reg         usb_uart_rxd            ;
wire        usb_uart_txd            ;

initial      resetn     = 1'b1;
initial #100 resetn     = 1'b0;
initial #200 resetn     = 1'b1;
initial  sys_clock      = 1'b1;
initial  usb_uart_rxd   = 1'b1;

always @(sys_clock) #10 sys_clock <= !sys_clock;

system_top_wrapper i_system_top_wrapper (
.dip_switches_4bits_tri_i(dip_switches_4bits_tri_i),
.led_4bits_tri_io        (led_4bits_tri_io        ),
.reset                   (resetn                  ),
.sys_clock               (sys_clock               ),
.usb_uart_rxd            (usb_uart_rxd            ),
.usb_uart_txd            (usb_uart_txd            )
);


endmodule
