yosys -import
read_verilog -sv -formal $::env(REPO_HOME)/rtl/prim/prim_clock_gate.sv
read_verilog -sv -formal $::env(REPO_HOME)/rtl/core/core_clock_ctrl.sv
read_verilog -sv -formal $::env(REPO_HOME)/rtl/core/core_pipe_fetch_buffer.sv
read_verilog -sv -formal $::env(REPO_HOME)/rtl/core/core_pipe_fetch.sv
read_verilog -sv -formal $::env(REPO_HOME)/rtl/core/core_pipe_decode_immediates.sv
read_verilog -sv -formal $::env(REPO_HOME)/rtl/core/core_pipe_decode.sv
read_verilog -sv -formal $::env(REPO_HOME)/rtl/core/core_pipe_exec_alu.sv
read_verilog -sv -formal $::env(REPO_HOME)/rtl/core/core_pipe_exec_cfu.sv
read_verilog -sv -formal $::env(REPO_HOME)/rtl/core/core_pipe_exec_lsu.sv
read_verilog -sv -formal $::env(REPO_HOME)/rtl/core/core_pipe_exec_mdu.sv
read_verilog -sv -formal $::env(REPO_HOME)/rtl/core/core_pipe_exec.sv
read_verilog -sv -formal $::env(REPO_HOME)/rtl/core/core_pipe_wb.sv
read_verilog -sv -formal $::env(REPO_HOME)/rtl/core/core_csrs.sv
read_verilog -sv -formal $::env(REPO_HOME)/rtl/core/core_pmp.sv
read_verilog -sv -formal $::env(REPO_HOME)/rtl/core/core_regfile.sv
read_verilog -sv -formal $::env(REPO_HOME)/rtl/core/core_interrupts.sv
read_verilog -sv -formal $::env(REPO_HOME)/rtl/core/core_top.sv

