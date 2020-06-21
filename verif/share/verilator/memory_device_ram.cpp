
#include "memory_device_ram.hpp"

/*!
*/
bool memory_device_ram::read_word (
    uint64_t addr,
    uint32_t * dout
){
    
    if(this -> in_range(addr, 3)) {
        
        *dout = 
            (uint32_t)this -> memory[addr+3] << 24 |
            (uint32_t)this -> memory[addr+2] << 16 |
            (uint32_t)this -> memory[addr+1] <<  8 |
            (uint32_t)this -> memory[addr+0] <<  0 ;

        return true;

    } else {

        return false;

    }
}
    
/*!
@brief Return a single byte from the device.
*/
uint8_t memory_device_ram::read_byte (
    memory_address addr
) {
    return memory[addr];
}

/*!
*/
bool memory_device_ram::write_byte (
    uint64_t addr,
    uint8_t  data
){
    if(this -> in_range(addr, 0)) {
        
        this -> memory[addr] = data;

        return true;

    } else {
        return false;
    }
}
