
#include <queue>

#include "memory_device.hpp"

#ifndef MEMORY_DEVICE_UART_HPP
#define MEMORY_DEVICE_UART_HPP

#define MEMORY_DEVICE_UART_RANGE 8

/*!
@brief A basic UART device for printing things during simulation.
@details:
Register Map:
Offset  |  Register
--------|----------------------
0x0     | TX
0x4     | RX
0x8     | CTRL
0x12    | STATUS
*/
class memory_device_uart : public memory_device {

public:
    
    memory_device_uart (
        memory_address base
    ) : memory_device(base,MEMORY_DEVICE_UART_RANGE) {
        addr_tx     = addr_base + 0 ;
        addr_rx     = addr_base + 4 ;
        addr_ctrl   = addr_base + 8 ;
        addr_status = addr_base + 12;
    }

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

    // Addresses of each register, calculated at instantiation.
    memory_address addr_tx;
    memory_address addr_rx;
    memory_address addr_ctrl;
    memory_address addr_status;
    
    // Contents of each register.
    uint32_t reg_tx;
    uint32_t reg_rx;
    uint32_t reg_ctrl;
    uint32_t reg_status;
    
    //! Stores characters to be read from this device via the TX register.
    std::queue<uint8_t> rx_buffer;

    //! Stores the data to be transmitted in a buffer until a newline is seen.
    std::queue<uint8_t> tx_buffer;

    //! Get the next char from the rx buffer and pop it from the buffer.
    uint8_t get_from_rx_buffer();

    //! Get the next char from the rx buffer and pop it from the buffer.
    void write_to_tx_buffer(uint8_t data);

};

#endif

