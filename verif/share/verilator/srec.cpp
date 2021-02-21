
#include "srec.hpp"


namespace srec {

unsigned char hctoi (unsigned char hc) {
    if     (hc >= 'a') return hc- 87;
    else if(hc >= 'A') return hc- 55;
    else               return hc- 48;
}

srec_file::srec_file (
    std::string path
) {

    std::ifstream file (path);

    if(file.is_open()) {

        std::string line;

        while(std::getline(file,line)) {

            if(line.size() == 0) {
                // Ignore blank lines.
                continue;
            }

            bool skip_line = false;
        
            // First two chars are the record type.
            unsigned char rec_type = line[1] & 0xf;

            // Next two chars are the number of bytes in the record.
            unsigned char ch0      = line[2];
            unsigned char ch1      = line[3];
            if(ch0 > 'A') ch0 -= 55;
            if(ch1 > 'A') ch1 -= 55;
            unsigned int  rec_size = ((ch0 & 0xf) << 4) | (ch1 & 0xf);

            unsigned char data_bytes = rec_size - 5;

            unsigned long rec_addr = 0;

            // The next 2/3/4 bytes are the address.
            switch(rec_type) {
                case(0) :
                    // Ignore header information
                    skip_line = true;
                    break;
                case(3) : // 4-byte / 32 bit address
                    rec_addr |= (hctoi(line[4 ]) & 0x0F) << 28;
                    rec_addr |= (hctoi(line[5 ]) & 0x0F) << 24;
                    rec_addr |= (hctoi(line[6 ]) & 0x0F) << 20;
                    rec_addr |= (hctoi(line[7 ]) & 0x0F) << 16;
                    rec_addr |= (hctoi(line[8 ]) & 0x0F) << 12;
                    rec_addr |= (hctoi(line[9 ]) & 0x0F) <<  8;
                    rec_addr |= (hctoi(line[10]) & 0x0F) <<  4;
                    rec_addr |= (hctoi(line[11]) & 0x0F) <<  0;
                    rec_addr &= 0xffffffff;
                    break;
                case(7):
                    // Ignore start of execution address.
                    skip_line = true;
                    break;
                default:
                    std::cerr << "Unknown record type: " << rec_type 
                              << std::endl;
                    continue;
            }
            
            if(skip_line) {
                continue;
            }

            for(unsigned char i = 0; i < data_bytes; i ++  ) {

                int high_nibble  = hctoi(line[12 + 2*i]);
                int low_nibble   = hctoi(line[13 + 2*i]);

                // Mask and shift into a single byte.
                unsigned char d = ((high_nibble & 0x0F) << 4) |
                                  ((low_nibble  & 0x0F) << 0) ;

                this -> data[rec_addr + i] = d;
            }

        }

        file.close();

    }

}
        
/*!
*/
bool srec_file::dump_readmemh(
    unsigned char word_size,
    std::string   file_path
){
    
    std::ofstream fh (file_path);

    if(fh.is_open() == false) {
        return false;
    }


    long unsigned base_address = 0;
    long unsigned prev_address = 0;

    fh << "@" << std::hex << base_address << std::endl;
    prev_address = base_address;

    for(auto it = this -> data.begin();
             it != this -> data.end();
             ++it)
    {
        
        long unsigned offset = it -> first;
        unsigned char data   = it -> second;

        if(prev_address + 1 != base_address + offset) {
            long unsigned addr_to_write = (base_address + offset) & 0xFFFF;
            fh << "@" << std::hex << addr_to_write << std::endl;
        }
        prev_address = base_address + offset;
        
        fh << std::hex << (int)data << std::endl;

    }

    fh.close();

    return true;

}

}
