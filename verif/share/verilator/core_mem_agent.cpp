
#include <iostream>

#include "core_mem_agent.hpp"
    
    
core_mem_agent::core_mem_agent (
    memory_bus * mem
) {
    this -> mem = mem;
}


//! Put the interface in reset
void core_mem_agent::set_reset(){

    *mem_gnt = 0;
    
}


//! Take the interface out of reset
void core_mem_agent::clear_reset(){

}


//! Drive any signal updates
void core_mem_agent::drive_signals(){

    *mem_err    = n_mem_err  ;
    *mem_rdata  = n_mem_rdata;
    *mem_gnt    = n_mem_gnt  ;

}


//! Compute any *next* signal values
void core_mem_agent::posedge_clk(){

    if(*mem_req && *mem_gnt) {
        
        // There is an outstanding request

        this -> req_stall_len = 0;
        
        //
        // Construct the new memory request.

        size_t txn_length  = 8;

        memory_req_txn * req = new memory_req_txn(
            *mem_addr,
            txn_length,
            *mem_wen
        );

        if(*mem_wen) {

            for(int i = 0; i < txn_length ; i ++) {
                req -> data()[i] = (*mem_wdata>> (8*i)) & 0xFF;
                req -> strb()[i] = (bool)((*mem_strb >> i    ) & 0x1);
            }

        }

        //
        // Issue the memory request and get the response

        memory_rsp_txn * rsp = this -> mem -> request(req);

        n_mem_err   = rsp -> error();

        if(req -> is_read()) {
            n_mem_rdata = rsp -> data_dword();
        }

        if(n_mem_err) {
            std::cout   << "Error accessing address: " 
                        << std::hex<<rsp->addr()
                        << std::endl;
        }

        //
        // Clean up the requests/responses.
        delete req;
        delete rsp;

    } else {
        
        // There is no outstanding memory request.

        n_mem_err   = rand_chance(5,10);
        n_mem_rdata = ((uint64_t)rand() << 32) | rand();

    }
        
    n_mem_gnt   = rand_chance(9,10);

}
