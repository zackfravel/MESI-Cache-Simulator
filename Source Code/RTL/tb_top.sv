/*

Team 3 - (Zack, Karla, Megha, Natalie)
ECE585 Final Project
Winter 2021

tb_top.sv
--------------------
Description:

Top level testbench desiged to read .trace files containing our design stimulus.
Instantiates our file_parser module to read our .trace file and feeds the outputs
into our L1_Cache module where we have implemented a Split Cache with MESI Coherence.  
Outputs address and command signals to console for user verification.  

*/

timeunit 1ns/1ns;

// Module Declaration
module tb_top ();

// Signal Declaration 
logic clock, reset, instr_rdy; 
int command, mode, instr_reads, instr_hits, instr_misses, 
	data_reads, data_writes, data_hits, data_misses;
logic[31:0] address;

// Instantiate Module
trace_parser dut_parse (clock, reset, command, address, mode, instr_rdy);

// Instantiate Cache
L1_Cache dut_cache (.reset(reset), .clk(clock), .instruction_ready(instr_rdy), .n(command), .Address(address), .MODE(mode)); 

// Clock Generator 
always begin
	#1 clock = ~clock;
end

// Initialize Inputs
initial begin
	reset = 0;
	clock = 0;
end

// Monitor the outputs 
initial begin: monitor_commands_and_addresses
	// Creates a nicely formatted console output of our simulation run
	$monitor("\t", $time, " \t command:%1d   address:%h", command, address);
end: monitor_commands_and_addresses

endmodule : tb_top
