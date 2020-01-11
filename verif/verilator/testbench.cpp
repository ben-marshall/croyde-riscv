
#include "testbench.hpp"


//! Construct all of the objects we need inside the testbench.
void testbench::build() {

    this -> bus         = new memory_bus();

    this -> default_ram = new memory_device_ram(
        this -> default_ram_base_addr,
        this -> default_ram_size
    );

    this -> uart_0 = new memory_device_uart (
        this -> uart_base_addr
    );

    this -> bus -> add_device(this -> default_ram);
    this -> bus -> add_device(this -> uart_0);

    this -> dut = new dut_wrapper(
        this -> bus,
        this -> waves_dump,
        this -> waves_file
    );

}
    
//! Called immediately before the run function.
void testbench::pre_run() {

    this -> dut -> dut_set_reset();

}

//! The main phase of the DUT simulation.
void testbench::run() {
   
    // Run the DUT for a few cycles while held in reset.
    for(int i = 0; i < 5; i ++) {
        dut -> dut_step_clk();
    }
    
    // Start running the DUT proper.
    dut -> dut_clear_reset();
    
    dut_trace_pkt_t trs_item;

    while(dut -> get_sim_time() < max_sim_time && !sim_finished) {
        
        dut -> dut_step_clk();

        if(dut -> dut_trace.empty() == false) {
            trs_item = dut -> dut_trace.front();
            
            if(trs_item.program_counter == pass_address) {
                sim_passed  = true;
                sim_finished= true;
            } else if (trs_item.program_counter == fail_address) {
                sim_passed  = false;
                sim_finished= true;
            }

            dut -> dut_trace.pop();
        }

    }

}

//! Called after the run function has returned.
void testbench::post_run() {
    
    if(this -> waves_dump) {
        dut -> trace_fh -> close();
    }

}
