
yosys -import

# Read in the design
read_verilog -sv -I$::env(REPO_HOME)/rtl/core $::env(REPO_HOME)/rtl/core/*.sv

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
tee -o $::env(SYNTH_DIR)/synth-cmos.rpt stat
tee -a $::env(SYNTH_DIR)/synth-cmos.rpt ltp  -noff
