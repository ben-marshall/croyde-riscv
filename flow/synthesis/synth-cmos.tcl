
yosys -import

# Read in the design
read_verilog -sv $::env(REPO_HOME)/rtl/prim/prim_clock_gate.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_clock_ctrl.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_counters.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_fetch_buffer.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_fetch.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_decode_immediates.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_decode.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_exec_alu.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_exec_cfu.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_exec_lsu.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_exec_mdu.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_exec_crypto_aes_mix_columns.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_exec_crypto_sboxes.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_exec_crypto_aes64.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_exec_crypto_sha256.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_exec_crypto_sha512.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_exec_crypto_sm3.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_exec_crypto_sm4.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_exec_crypto.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_exec.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_pipe_wb.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_csrs.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_regfile.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_interrupts.sv
read_verilog -sv $::env(REPO_HOME)/rtl/core/core_top.sv

# Generic yosys synthesis command
synth -top core_top -flatten

# Map to CMOS cells
abc -g cmos4

# Simple optimisations
opt fast

write_verilog   $::env(SYNTH_DIR)/synth-cmos.v

# Statistics: size and latency
tee -o $::env(SYNTH_DIR)/synth-cmos.rpt stat
tee -a $::env(SYNTH_DIR)/synth-cmos.rpt ltp  -noff
