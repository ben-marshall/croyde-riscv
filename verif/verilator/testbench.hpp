
#include "memory_txns.hpp"
#include "memory_device.hpp"
#include "memory_device_ram.hpp"
#include "memory_device_uart.hpp"
#include "memory_bus.hpp"

#include "dut_wrapper.hpp"

#ifndef TESTBENCH_HPP
#define TESTBENCH_HPP

class testbench {

public:
    
    //! Create a new testbench.
    testbench (
        std::string waves_file,
        bool        waves_dump
    ) {
        
        this -> waves_file = waves_file;
        this -> waves_dump = waves_dump;

        this -> build();
    }

    //! Memory device bus.
    memory_bus  * bus;
    
    //! The default memory used in the testbench.
    memory_device_ram * default_ram;
    
    //! UART device used to print messages.
    memory_device_uart * uart_0;

    //! The design under test.
    dut_wrapper * dut;

    //! Run the simulation from beginning to end.
    void run_simulation() {
        this -> pre_run();   
        this -> run();   
        this -> post_run();
    }

    uint64_t        max_sim_time        = 10000;

    //! If the DUT traces out this address, indicate a pass.
    memory_address  pass_address     = 0;

    //! If the DUT traces out this address, indicate a failure.
    memory_address  fail_address     = -1;
    
    //! Return total simulation time so far.
    uint64_t get_sim_time() {
        return this -> dut -> get_sim_time();
    }

    bool            sim_finished    = false;

    bool            sim_passed      = false;

protected:
    
    //! Construct all of the objects we need inside the testbench.
    void build();
    
    //! Called immediately before the run function.
    void pre_run();
    
    //! The main phase of the DUT simulation.
    void run();

    //! Called after the run function has returned.
    void post_run();

    //! Where to dump waveforms.
    std::string waves_file;
    
    //! Whether or not to dump waveforms.
    bool        waves_dump;
    
    //! Default base address of the default memory.
    size_t      default_ram_base_addr = 0x80000000;
    
    //! Default base address of the default memory.
    size_t      uart_base_addr = 0x40600000;

    //! Default size of the default memory.
    size_t      default_ram_size = 0x20000;

};

#endif
