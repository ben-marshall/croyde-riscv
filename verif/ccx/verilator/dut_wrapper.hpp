

#include <queue>
#include <vector>

#include "verilated.h"
#include "verilated_vcd_c.h"

#include "Vccx_top.h"

#include "memory_device.hpp"
#include "core_mem_agent.hpp"

#ifndef DUT_WRAPPER_HPP
#define DUT_WRAPPER_HPP

//! A trace packet emitted by the core post-writeback.
typedef struct dut_trace_pkt {
    uint64_t program_counter;
    uint32_t instr_word;
} dut_trace_pkt_t;

//! Wraps around the design under test.
class dut_wrapper {

public:

    //! Path to dump wave files too
    bool         dump_waves        = false;
    
    //! File path waves are dumped too.
    std::string  vcd_wavefile_path = "waves.vcd";

    /*!
    @brief Create a new dut_wrapper object
    @param in ctx - Pointer to a memory context obejct.
    @param in dump_waves - If true, write wave file.
    */
    dut_wrapper (
        memory_bus    * mem         ,
        bool            dump_waves  ,
        std::string     wavefile
    );

    
    //! Put the dut in reset.
    void dut_set_reset();
    
    //! Take the DUT out of reset.
    void dut_clear_reset();

    //! Simulate the DUT for a single clock cycle
    void dut_step_clk();
    
    //! Return the number of simulation ticks so far.
    uint64_t get_sim_time() {
        return this -> sim_time;
    }
    
    //! Handle to the VCD file for dumping waveforms.
    VerilatedVcdC* trace_fh;
    
    //! Trace of post-writeback PC and instructions.
    std::queue<dut_trace_pkt_t> dut_trace;

    void set_mem_max_stall (uint32_t stall) {
        mem_agent -> max_req_stall = stall;
    }

protected:
    
    //! Set of available memories. Fed to memory agents.
    memory_bus   * mem;

    //! Instruction memory SRAM agent
    core_mem_agent * mem_agent;

    //! Number of model evaluations per clock cycle
    const uint32_t  evals_per_clock = 10;
    
    //! Simulation time, incremented with each tick.
    uint64_t sim_time;
    
    //! The DUT object being wrapped.
    Vccx_top * dut;

    //! Called on every rising edge of the main clock.
    void posedge_gclk();

    /*!
    @brief Return a random boolean sample with an x in y chance of being
        true.
    */
    bool rand_chance(int x, int y);


    /*!
    @brief Randomly set a uint8_t to either 0 or 1 based on rand_chance
        called with x and y as parameters.
    */
    bool rand_set_uint8(int x, int y, vluint8_t * d);

};

#endif
