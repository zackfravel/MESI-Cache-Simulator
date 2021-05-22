help:
	@echo " "
	@echo "ECE585 Final Project - Megha, Natalie, Karla, Zack - Winter 2021"
	@echo " "
	@echo "Welcome to our Split L1 Cache (with MESI Coherence) Verification Environment!"
	@echo " "
	@echo "Mode 0: Simulation displays cache contents and usage statistics only."
	@echo "Mode 1: Simulation displays cache contents, stats, and communication with the L2 cache."
	@echo " "
	@echo "Instructions:"
	@echo " 	1. make compile"
	@echo " 	2. make <test_name>_mode<0/1>"
	@echo " "
	@echo "     e.g. make scenario1_mode0   or   make scenario1_mode1 "
	@echo " "
	@echo "Tests: instruction_fetch  reset  test  test2  mode_error  trace_error"
	@echo "       consecutive  set0  set0too  set5  set78  set100  set1000  invalidate"
	@echo "       incorrectCommands  scenario1  scenario2  traceFile traceFile2"
	@echo " "
	@echo "Utilities: compile clean"
	@echo " "

compile: 
	vlib work
	vmap work work
	vlog ./RTL/Cache_defs.sv
	vlog ./RTL/trace_parser.sv
	vlog ./RTL/L1_Cache.sv
	vlog ./RTL/tb_top.sv
	

traceFile_mode0:
	vsim -c +trace="./STIMULUS/traceFile.trace" +mode=0 tb_top -do "run -all;quit"
traceFile_mode1:
	vsim -c +trace="./STIMULUS/traceFile.trace" +mode=1 tb_top -do "run -all;quit"

traceFile2_mode0:
	vsim -c +trace="./STIMULUS/traceFile2.trace" +mode=0 tb_top -do "run -all;quit"
traceFile2_mode1:
	vsim -c +trace="./STIMULUS/traceFile2.trace" +mode=1 tb_top -do "run -all;quit"

instruction_fetch_mode0:
	vsim -c +trace="./STIMULUS/instruction_fetch.trace" +mode=0 tb_top -do "run -all;quit"
instruction_fetch_mode1:
	vsim -c +trace="./STIMULUS/instruction_fetch.trace" +mode=1 tb_top -do "run -all;quit"

reset_mode0:
	vsim -c +trace="./STIMULUS/reset.trace" +mode=0 tb_top -do "run -all;quit"
reset_mode1:
	vsim -c +trace="./STIMULUS/reset.trace" +mode=1 tb_top -do "run -all;quit"

consecutive_mode0:
	vsim -c +trace="./STIMULUS/consecutive.trace" +mode=0 tb_top -do "run -all;quit"
consecutive_mode1:
	vsim -c +trace="./STIMULUS/consecutive.trace" +mode=1 tb_top -do "run -all;quit"

test_mode0:
	vsim -c +trace="./STIMULUS/test.trace" +mode=0 tb_top -do "run -all;quit"
test_mode1:
	vsim -c +trace="./STIMULUS/test.trace" +mode=1 tb_top -do "run -all;quit"

test2_mode0:
	vsim -c +trace="./STIMULUS/test2.trace" +mode=0 tb_top -do "run -all;quit"
test2_mode1:
	vsim -c +trace="./STIMULUS/test2.trace" +mode=1 tb_top -do "run -all;quit"

set0_mode0:
	vsim -c +trace="./STIMULUS/set0.trace" +mode=0 tb_top -do "run -all;quit"
set0_mode1:
	vsim -c +trace="./STIMULUS/set0.trace" +mode=1 tb_top -do "run -all;quit"

set0too_mode0:
	vsim -c +trace="./STIMULUS/set0too.trace" +mode=0 tb_top -do "run -all;quit"
set0too_mode1:
	vsim -c +trace="./STIMULUS/set0too.trace" +mode=1 tb_top -do "run -all;quit"

set5_mode0:
	vsim -c +trace="./STIMULUS/set5.trace" +mode=0 tb_top -do "run -all;quit"
set5_mode1:
	vsim -c +trace="./STIMULUS/set5.trace" +mode=1 tb_top -do "run -all;quit"

set78_mode0:
	vsim -c +trace="./STIMULUS/set78.trace" +mode=0 tb_top -do "run -all;quit"
set78_mode1:
	vsim -c +trace="./STIMULUS/set78.trace" +mode=1 tb_top -do "run -all;quit"

set1000_mode0:
	vsim -c +trace="./STIMULUS/set1000.trace" +mode=0 tb_top -do "run -all;quit"
set1000_mode1:
	vsim -c +trace="./STIMULUS/set1000.trace" +mode=1 tb_top -do "run -all;quit"

set100_mode0:
	vsim -c +trace="./STIMULUS/set100.trace" +mode=0 tb_top -do "run -all;quit"
set100_mode1:
	vsim -c +trace="./STIMULUS/set100.trace" +mode=1 tb_top -do "run -all;quit"

incorrectCommands_mode0:
	vsim -c +trace="./STIMULUS/incorrectCommands.trace" +mode=0 tb_top -do "run -all;quit"
incorrectCommands_mode1:
	vsim -c +trace="./STIMULUS/incorrectCommands.trace" +mode=1 tb_top -do "run -all;quit"

invalidate_mode0:
	vsim -c +trace="./STIMULUS/invalidate.trace" +mode=0 tb_top -do "run -all;quit"
invalidate_mode1:
	vsim -c +trace="./STIMULUS/invalidate.trace" +mode=1 tb_top -do "run -all;quit"

scenario1_mode0:
	vsim -c +trace="./STIMULUS/scenario1.trace" +mode=0 tb_top -do "run -all;quit"
scenario1_mode1:
	vsim -c +trace="./STIMULUS/scenario1.trace" +mode=1 tb_top -do "run -all;quit"

scenario2_mode0:
	vsim -c +trace="./STIMULUS/scenario2.trace" +mode=0 tb_top -do "run -all;quit"
scenario2_mode1:
	vsim -c +trace="./STIMULUS/scenario2.trace" +mode=1 tb_top -do "run -all;quit"

mode_error:
	vsim -c +trace="./STIMULUS/test2.trace" tb_top -do "run -all;quit"
trace_error:
	vsim -c +mode=1 tb_top -do "run -all;quit"

clean:
	rm -rf work modelsim.ini *.wlf *.log replay* transcript *.db
