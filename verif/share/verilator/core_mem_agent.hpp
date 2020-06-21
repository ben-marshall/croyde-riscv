
#include <queue>

#include "memory_txns.hpp"
#include "memory_bus.hpp"

#ifndef SRAM_AGENT_HPP
#define SRAM_AGENT_HPP

/*!
@brief Acts as an SRAM slave agent.
*/
class core_mem_agent {

public:

    core_mem_agent (
        memory_bus * mem
    );


    //! Put the interface in reset
    void set_reset();
    
    //! Take the interface out of reset
    void clear_reset();
    
    //! Compute any *next* signal values
    void posedge_clk();

    //! Drive any signal updates
    void drive_signals();

    uint8_t   * mem_req     ; // Memory request
    uint64_t  * mem_addr    ; // Memory request address
    uint8_t   * mem_wen     ; // Memory request write enable
    uint8_t   * mem_strb    ; // Memory request write strobe
    uint64_t  * mem_wdata   ; // Memory write data.
    uint8_t   * mem_gnt     ; // Memory response valid
    uint8_t   * mem_err     ; // Memory response error
    uint64_t  * mem_rdata   ; // Memory response read data

    //! Maximum length of a stalled request.
    uint32_t   max_req_stall = 2;

protected:

    //! Current request stall length.
    uint32_t   req_stall_len = 0;

    //! memory bus this agent can access.
    memory_bus * mem;
    
    uint8_t  n_mem_err  ;  // Next Error
    uint8_t  n_mem_gnt  ;  // Next Memory stall
    uint64_t n_mem_rdata;  // Next Read data
    
    uint8_t rand_chance(int a, int b) {
        return ((rand() % b) < a) ? 1 : 0;
    }
    
};

#endif
