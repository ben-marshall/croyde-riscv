
#include <cstdint>
#include <vector>

#include "memory_txns.hpp"
#include "memory_device.hpp"

#ifndef MEMORY_BUS_HPP
#define MEMORY_BUS_HPP

/*!
@brief Acts as a manager of various memory devices.
@details Plays the part of a memory interconnect, recieving requests and
issuing responses.
*/
class memory_bus {

public:
    
    //! Initialise the memory bus object.
    memory_bus () {
        
    }

    /*
        this -> bus,
        this -> dump_waves,
        this -> wavefile!
    @brief Connect a new device to the bus.
    @returns True if the device was added successfully, or False if
        the device's memory range overlaps with an already added device.
    */
    bool add_device (
        memory_device   * device
    );

    //! Return the device to which the supplied address maps, or NULL.
    memory_device * get_device_at (
        memory_address addr
    );

    //! Issue a new request to the bus and get the response back.
    memory_rsp_txn * request (
        memory_req_txn * req
    );
    
    /*!
    @brief Return a single byte from the bus.
    */
    uint8_t read_byte (
        memory_address addr
    ) {
        memory_device * d = get_device_at(addr);

        if(d == NULL) {
            
            return -1;

        } else {

            return d -> read_byte(addr);

        }

    };
    
    
    /*!
    @brief Write a single byte to the bus.
    */
    bool write_byte (
        memory_address addr,
        uint8_t        data
    ) {
        memory_device * d = get_device_at(addr);

        if(d == NULL) {
            
            return -1;

        } else {

            return d -> write_byte(addr, data);

        }

    };

protected:
    
    //! The list of devices connected to the bus.
    std::vector<memory_device*> devices;


};

#endif
