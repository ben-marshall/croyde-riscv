
#include <assert.h>

#include "dut_wrapper.hpp"

/*!
*/
dut_wrapper::dut_wrapper (
    memory_bus    * mem         ,
    bool            dump_waves  ,
    std::string     wavefile
){


    this -> dut                    = new Vcore_top();

    this -> dump_waves             = dump_waves;
    this -> vcd_wavefile_path      = wavefile;
    this -> mem                    = mem;

    this -> imem_agent               = new core_mem_agent(mem);
    this -> imem_agent -> mem_req   = &this -> dut -> imem_req  ;
    this -> imem_agent -> mem_addr  = &this -> dut -> imem_addr ;
    this -> imem_agent -> mem_wen   = &this -> dut -> imem_wen  ;
    this -> imem_agent -> mem_strb  = &this -> dut -> imem_strb ;
    this -> imem_agent -> mem_wdata = &this -> dut -> imem_wdata;
    this -> imem_agent -> mem_gnt   = &this -> dut -> imem_gnt  ;
    this -> imem_agent -> mem_err   = &this -> dut -> imem_err  ;
    this -> imem_agent -> mem_rdata = &this -> dut -> imem_rdata;

    Verilated::traceEverOn(this -> dump_waves);

    if(this -> dump_waves){
        
        this -> trace_fh = new VerilatedVcdC;

        this -> dut      -> trace(this -> trace_fh, 99);

        this -> trace_fh -> open(this ->vcd_wavefile_path.c_str());


    }

    this -> sim_time               = 0;

}
    
//! Put the dut in reset.
void dut_wrapper::dut_set_reset() {

    // Put model in reset.
    this -> dut -> g_resetn     = 0;
    this -> dut -> g_clk        = 0;

    this -> imem_agent -> set_reset();

}
    
//! Take the DUT out of reset.
void dut_wrapper::dut_clear_reset() {
    
    this -> dut -> g_resetn = 1;
    
    this -> imem_agent -> clear_reset();

}


//! Simulate the DUT for a single clock cycle
void dut_wrapper::dut_step_clk() {

    for(uint32_t i = 0; i < this -> evals_per_clock; i++) {

        if(i == this -> evals_per_clock / 2) {
            
            this -> dut -> g_clk = !this -> dut -> g_clk;
            
            if(this -> dut -> g_clk == 1){

                this -> posedge_gclk();
            }
       
        } 
        
        this -> dut      -> eval();
        
        // Drive interface agents
        this -> imem_agent -> drive_signals();

        this -> dut -> eval();

        this -> sim_time ++;

        if(this -> dump_waves) {
            this -> trace_fh -> dump(this -> sim_time);
        }

    }

}


void dut_wrapper::posedge_gclk () {

    this -> imem_agent -> posedge_clk();

    // Do we need to capture a trace item?
    if(this -> dut -> trs_valid) {
        this -> dut_trace.push (
            {
                this -> dut -> trs_pc,
                this -> dut -> trs_instr
            }
        );
    }
}


bool dut_wrapper::rand_chance(int x, int y) {
    return (rand() % y) < x;
}


bool dut_wrapper::rand_set_uint8(int x, int y, vluint8_t * d) {
    if(rand_chance(x,y)) {
        *d = 1;
        return true;
    } else {
        *d = 0;
        return false;
    }
}

