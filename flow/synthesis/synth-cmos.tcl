
yosys -import

# Read in the design
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_counters.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_mmio_mux.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_fetch_buffer.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_fetch.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_decode_immediates.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_decode.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_exec_alu.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_exec_lsu.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_exec.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_csrs.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_regfile.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_top.sv

# Synthesise processes ready for SCC check.
procs

# Generic yosys synthesis command
synth -top core_top

# Map to CMOS cells
abc -g cmos

# Simple optimisations
opt fast

write_verilog   $::env(SYNTH_DIR)/synth-cmos.v
flatten

# Statistics: size and latency
tee -o $::env(SYNTH_DIR)/synth-cmos.rpt stat -tech cmos
tee -a $::env(SYNTH_DIR)/synth-cmos.rpt ltp  -noff
