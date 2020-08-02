
# Documentation - Memory Interface

*Describes the core memory interfaces used to fetch instructions and
 read/write data.*

---

- The data and instruction interfaces use a simple "SRAM style"
  interface with stalling.

  - Can be easily re-mapped to AXI/AMBA/BRAM etc.

  - Easily attatches to caches.


Bits  | Driver | Name            | Description
------|--------|-----------------|----------------------------------------
  1   | Core   | `mem_req`       | Memory request
  1   | Core   | `mem_rtype`     | Request type: instruction / data.
 32   | Core   | `mem_addr`      | Memory request address
  1   | Core   | `mem_wen`       | Memory request write enable
  8   | Core   | `mem_strb`      | Memory request write strobe
 64   | Core   | `mem_wdata`     | Memory write data.
  2   | Core   | `mem_prv`       | Privilidge level: 2=MMode,1=UMode.
  1   | Memory | `mem_gnt`       | Memory response valid
  1   | Memory | `mem_err`       | Memory response error
 64   | Memory | `mem_rdata`     | Memory response read data

- A request is started by the core asserting `mem_req`

  - If `mem_gnt` is also asserted, then on the *next* cycle, the memory
    response will be recieved.

  - If `mem_gnt` is *not* asserted, then the  request signals must
    remain stable until it is.

- A new request can start when `mem_gnt` and `mem_req` are both asserted.

  - `mem_err` and `mem_rdata` can only be sampled the cycle after both
    `mem_gnt` and `mem_req` are asserted.

  - Core driven signals may change on the cycle where `mem_req` and
    `mem_gnt` are high.

