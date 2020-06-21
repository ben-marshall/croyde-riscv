
#include <assert.h>

#include <map>
#include <queue>
#include <string>
#include <iostream>
#include <cstdlib>
#include <cstdio>

#include "srec.hpp"
#include "memory_device.hpp"
#include "dut_wrapper.hpp"
#include "testbench.hpp"

uint32_t    TB_PASS_ADDRESS     = 0;
uint32_t    TB_FAIL_ADDRESS     = -1;

bool        quiet               = false;

bool        dump_waves          = false;
std::string vcd_wavefile_path   = "waves.vcd";

uint64_t    max_sim_time        = 10000;

bool        load_srec           = false;
std::string srec_path           = "";

// Maximum amounts of time for which memory reqests/responses
// will be stalled for.
uint32_t    max_stall_mem      = 0;

/*
@brief Responsible for parsing all of the command line arguments.
*/
void process_arguments(int argc, char ** argv) {

    for(int i =0; i < argc; i ++) {
        std::string s (argv[i]);

        if(s.find("+IMEM=") != std::string::npos) {
            // Extract the file path.
            srec_path = s.substr(6);
            load_srec = true;
        }
        else if(s.find("+WAVES=") != std::string::npos) {
            std::string fpath = s.substr(7);
            vcd_wavefile_path = fpath;
            if(vcd_wavefile_path != "") {
                dump_waves        = true;
                if(!quiet){
                std::cout << ">> Dumping waves to: " << vcd_wavefile_path 
                          << std::endl;
                }
            }
        }
        else if(s.find("+TIMEOUT=") != std::string::npos) {
            std::string time = s.substr(9);
            max_sim_time= std::stoul(time) * 10;
            if(!quiet) {
            std::cout << ">> Timeout after " << time <<" cycles."<<std::endl;
            }
        }
        else if(s.find("+MEM_MAX_STALL=") != std::string::npos) {
            std::string str = s.substr(16);
            max_stall_mem = std::stoul(str);
        }
        else if(s.find("+PASS_ADDR=") != std::string::npos) {
            std::string addr = s.substr(11);
            TB_PASS_ADDRESS = std::stoul(addr,NULL,0) & 0xFFFFFFFF;
            if(!quiet){
            std::cout << ">> Pass Address: 0x" << std::hex << TB_PASS_ADDRESS
                      << std::endl;
            }
        }
        else if(s.find("+FAIL_ADDR=") != std::string::npos) {
            std::string addr = s.substr(11);
            TB_FAIL_ADDRESS = std::stoul(addr,NULL,0) & 0xFFFFFFFF;
            if(!quiet){
            std::cout << ">> Fail Address: 0x" << std::hex << TB_FAIL_ADDRESS
                      << std::endl;
            }
        }
        else if(s == "+q") {
            quiet = true;
        }
        else if(s == "--help" || s == "-h") {
            std::cout << argv[0] << " [arguments]" << std::endl
            << "\t+q                            -" << std::endl
            << "\t+IMEM=<srec input file path>  -" << std::endl
            << "\t+WAVES=<VCD dump file path>   -" << std::endl
            << "\t+TIMEOUT=<timeout after N>    -" << std::endl
            << "\t+PASS_ADDR=<hex number>       -" << std::endl
            << "\t+FAIL_ADDR=<hex number>       -" << std::endl
            ;
            exit(0);
        }
    }
}


void load_srec_file (
    memory_bus * mem
) {
    std::cout <<">> Loading srec: " << srec_path << std::endl;

    srec::srec_file fh(srec_path);

    for(auto it  = fh.data.begin();
             it != fh.data.end();
             it ++) {
        mem -> write_byte(it -> first, it -> second);
    }
}

int a2h(char c)
{
    int num = (int) c;
    if(num < 58 && num > 47){
        return num - 48;
    }
    if(num < 103 && num > 96){
        return num - 87;
    }
    return num;
}


/*
@brief Top level simulation function.
*/
int main(int argc, char** argv) {

    printf("> ");
    for(int i = 0; i < argc; i ++) {
        printf("%s ",argv[i]);
    }
    printf("\n");

    process_arguments(argc, argv);

    testbench tb (vcd_wavefile_path, dump_waves);

    if(load_srec) {
        load_srec_file(tb.bus);
    }

    tb.pass_address = TB_PASS_ADDRESS;
    tb.fail_address = TB_FAIL_ADDRESS;
    tb.max_sim_time = max_sim_time;

    tb.dut -> set_mem_max_stall(max_stall_mem);

    tb.run_simulation();

    std::cout << ">> Finished after " 
              << std::dec<<tb.get_sim_time()/10
              << " simulated clock cycles" << std::endl;

    bool verif_result = true;

    if(tb.get_sim_time() >= max_sim_time) {
        
        std::cout << ">> TIMEOUT" << std::endl;
        return 1;

    } else if(tb.sim_passed) {
        
        std::cout << ">> SIM PASS" << std::endl;
        return 0;

    } else if(!verif_result) {
        
        std::cout << ">> SIG FAIL" << std::endl;
        return 3;
        
    } else {

        std::cout << ">> SIM FAIL" << std::endl;
        return 2;

    }

}
