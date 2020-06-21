
#include "memory_device.hpp"

#ifndef MEMORY_DEVICE_RAM_HPP
#define MEMORY_DEVICE_RAM_HPP

class memory_device_ram : public memory_device {

public:
    
    memory_device_ram (
        memory_address base,
        size_t         range
    ) : memory_device(base,range) {}

    /*!
    @brief Read a word from the address given.
    @returns true if the read succeeds. False otherwise.
    */
    bool read_word (
        memory_address addr,
        uint32_t     * dout
    );

    /*!
    @brief Write a single byte to the device.
    @return true if the write is in range, else false.
    */
    bool write_byte (
        memory_address addr,
        uint8_t        data
    );


    /*!
    @brief Return a single byte from the device.
    */
    uint8_t read_byte (
        memory_address addr
    );
    

protected:

    //! The underlying memory.
    std::map<memory_address, uint8_t> memory;   

};

#endif
