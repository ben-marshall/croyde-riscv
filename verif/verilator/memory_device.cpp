
#include "memory_device.hpp"
    
memory_device::memory_device (
    uint64_t base,
    uint64_t range
) {
    
    this -> addr_base = base;
    this -> addr_range= range;
    this -> addr_top  = base + range;

}

memory_device::~memory_device() {
}


