
#include <cstdint>
#include <cstdlib>

#ifndef MEMORY_TXNS_HPP
#define MEMORY_TXNS_HPP

//! Represents a single point in the address space.
typedef uint64_t memory_address;
    
//! Unique counter for assigning new id's
static uint64_t _memory_txn_id_counter = 0;

//! Base class for all memory transaction objects.
class memory_txn {

public:
    
    //! Create a new memory transaction object.
    memory_txn (
        memory_address  addr,   //!< Address being acessed
        size_t          size,   //!< The size of the access.
        bool            write   //!< Is this a write request?
    ) {
        this -> _id     = _memory_txn_id_counter++;
        this -> _addr   = addr  ;
        this -> _size   = size  ; 
        this -> _write  = write ;
        this -> _data   = (uint8_t*)calloc(size, sizeof(uint8_t));
        this -> _strb   = (bool   *)calloc(size, sizeof(bool   ));

        for(int i = 0; i < size; i ++) {
            this -> _strb[i] = true;
        }
    }

    ~memory_txn () {
        free(this -> _data);
        free(this -> _strb);
    }

    //! The address of the request.
    memory_address addr () {return this -> _addr    ;}
        
    //! The size of the request.
    size_t         size () {return this -> _size    ;}
    
    //! Is this a write request (true) or read request (false);
    bool           is_write() {return this -> _write   ;}
    
    //! Is this a write request (false) or read request (true);
    bool           is_read() {return !this -> _write   ;}

    //! The read/write data associate with the request.
    uint8_t *      data () {return this -> _data    ;}

    //! The write strobe bits associate with the request.
    bool    *      strb () {return this -> _strb    ;}

    //! Unique identifier associated with the transaction.
    uint64_t       id() {return this -> _id;}

    //! Return the first 4 bytes of data in the transaction as 32bit value.
    uint32_t       data_word() {
        uint32_t tr = 0;
        for(int i = 0; i < this -> size() && i < 4; i ++) {
            tr |= this -> data()[i] << (8*i);
        }
        return tr;
    }
    
    //! Return the first 8 bytes of data in the transaction as 32bit value.
    uint64_t       data_dword() {
        uint64_t tr = 0;
        for(int i = 0; i < this -> size() && i < 8; i ++) {
            tr |= (uint64_t)this -> data()[i] << (8*i);
        }
        return tr;
    }

protected:

    //! Unique identifier for the transaction.
    uint64_t        _id;

    // Address of the request.
    memory_address  _addr;
    
    // Number of bytes being read/written.
    size_t          _size;

    //! Is this a write?
    bool            _write;

    //! Read or write data.
    uint8_t *       _data;
    
    //! Write strobe bits.
    bool    *       _strb;

};

//! Represents memory requests.
class memory_req_txn : public memory_txn{
    
public:
    memory_req_txn (
        memory_address  addr,   //!< Address being acessed
        size_t          size,   //!< The size of the access.
        bool            write   //!< Is this a write request?
    ) : memory_txn (addr,size,write) {}

};

//! Represents memory responses.
class memory_rsp_txn : public memory_txn{

public:

    //! Create a new response transaction object.
    memory_rsp_txn (
        memory_req_txn  * req  , //!< The request this is a response to.
        bool              error  //!< Did this request result in an error?
    ) : memory_txn (
        req -> addr(),
        req -> size(),
        req -> is_write()
    ) {
        this -> _req   = req;
        this -> _error = error;
    }
    

    //! Set the error flag.
    void set_error() {this -> _error = true;}

    //! Did an error respose occur?
    bool error() {return this -> _error;}

    //! The request this response is associated with.
    memory_req_txn * req () {return this -> _req;}

protected:
    
    //! Did an error respose occur?
    bool _error;

    //! The request this response is associated with.
    memory_req_txn  * _req;

};

#endif
