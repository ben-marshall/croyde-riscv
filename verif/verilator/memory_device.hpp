
#include <cstdint>
#include <map>

#include "memory_txns.hpp"

#ifndef MEMORY_DEVICE_HPP
#define MEMORY_DEVICE_HPP


class memory_device {

public:

    memory_device (
        memory_address base,
        size_t         range
    );

    ~memory_device();

    memory_address get_base (){return this -> addr_base ;}
    size_t         get_range(){return this -> addr_range;}
    memory_address get_top  (){return this -> addr_top  ;}

    /*
    @brief Return true iff the supplied address is inside this device range
    */
    bool     in_range (
        memory_address addr //!< Base address
    ) {
        return (addr >= this -> get_base()) && (addr < this -> get_top());
    }
    
    /*!
    @brief Return true iff the supplied address range is wholly inside this
    device range
    */
    bool     in_range (
        memory_address addr,  //!< Base of the query
        size_t         size   //!< Size of the query
    ) {
        return  ((addr     ) >= this -> get_base()) &&
                ((addr+size) <= this -> get_top ());
    }
    
    /*!
    @brief Return true iff the supplied address range is wholly inside this
    device range
    */
    bool     in_range (
        memory_req_txn * req
    ) {
        return  this -> in_range(req -> addr(), req -> size());
    }

    /*!
    @brief Read a word from the address given.
    @returns true if the read succeeds. False otherwise.
    */
    virtual bool read_word (
        memory_address addr,
        uint32_t     * dout
    ) = 0;

    /*!
    @brief Write a single byte to the device.
    @return true if the write is in range, else false.
    */
    virtual bool write_byte (
        memory_address addr,
        uint8_t        data
    ) = 0;


    /*!
    @brief Return a single byte from the device.
    */
    virtual uint8_t read_byte (
        memory_address addr
    ) = 0;


    /*!
    @brief Read a range of bytes from the device
    */
    bool    read_range (
        memory_address addr,
        size_t         size,
        uint8_t      * rdata
    ) {
        for(size_t i = 0; i < size; i ++) {
            memory_address a = addr + i;
            if( in_range(a)) {
                rdata[i] = this -> read_byte(a);
            } else {
                return false;
            }
        }
        return true;
    }
    
    /*!
    @brief Write a range of bytes from the device
    */
    bool    write_range (
        memory_address addr,
        size_t         size,
        uint8_t      * wdata,
        bool         * strb
    ) {
        for(size_t i = 0; i < size; i ++) {
            memory_address a = addr + i;
            if( in_range(a) ) {
                if(strb[i]) {
                    this -> write_byte(a, wdata[i]);
                }
            } else {
                return false;
            }
        }
        return true;
    }

protected:

    memory_address addr_base ;    //!< Base address of the device.
    memory_address addr_top  ;    //!< Top address of the device.
    uint64_t       addr_range;    //!< Size of the device address range.

};

#endif

