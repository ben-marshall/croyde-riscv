
#include "memory_bus.hpp"
    
/*!
@brief Connect a new device to the bus.
@returns True if the device was added successfully, or False if
    the device's memory range overlaps with an already added device.
*/
bool memory_bus::add_device (
    memory_device   * device
) {


    for(auto const &it : this -> devices) {
        
        if(device -> get_base() >= it -> get_base() &&
           device -> get_base() <= it -> get_top()     ||
           device -> get_top()  >= it -> get_base() &&
           device -> get_top()  <= it -> get_top()     )
        {
            return false;
        }

    }

    this -> devices.push_back(device);

    return true;

}


//! Return the device to which the supplied address maps, or NULL.
memory_device * memory_bus::get_device_at (
    memory_address addr
) {

    for(auto const &it: this -> devices) {
        
        if(it -> in_range(addr)) {

            return it;

        }

    }

    return NULL;

}


/*!
@note If the requested memory address is not mapped, an error
      response transaction will be returned.

@note If the transaction ranges across multiple devices, an error response
      will be returned.
*/
memory_rsp_txn * memory_bus::request (
    memory_req_txn * req
) {

    memory_device * device = this -> get_device_at(req -> addr());

    if(device == NULL) {
        
        // No mapped device for the start of this transaction.
        return new memory_rsp_txn(req, true);

    }

    if(!device -> in_range (req)) {
        
        // Request spans multiple devices. Return an error.
        return new memory_rsp_txn(req, true);

    }

    bool result;

    memory_rsp_txn * rsp = new memory_rsp_txn(req, false);

    if(req -> is_write()) {
        
        result = device -> write_range (
            req -> addr(),
            req -> size(),
            req -> data(),
            req -> strb()
        );

    } else {
        
        result = device -> read_range (
            req -> addr(),
            req -> size(),
            rsp -> data()
        );

    }

    if(!result) {
        rsp -> set_error();
    }

    return rsp;

}
