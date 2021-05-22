/*

Team 3 - (Zack, Karla, Megha, Natalie)
ECE585 Final Project
Winter 2021

trace_parser.sv
--------------------
Description:

Module desiged to read .trace files containing our design stimulus.
Outputs address signals and commands to cache modules every 5 clock 
cycles. Includes a reset task that is used to clear the cache in the 
beginning of a new test. Module is also responsible for communicating
with the cache modules which mode the user wants to run. 

*/

timeunit 1ns/1ns;

module trace_parser (
    input logic clock, reset,
    output int command, 
    output logic[31:0] address,
    output int mode,
    output logic instruction_ready
);

// Customizable parameter to size the buffer for up to 1M trace file
parameter buffer_size = 2**20;

// File Buffer and Filename variables
logic[buffer_size:0] trace_file;
string trace_name;

// Mode Variables
int mode_selection;

// Asynchronus Reset Detection
always_ff @(posedge reset) begin : reset_detection
  if(reset) cache_reset();
end : reset_detection

// Set Mode Output
initial begin : set_mode
  // If no mode parameter is included in simulation command-line, throw an error 
  if ($value$plusargs("mode=%b", mode_selection) == 0) 
    begin       
    $error("No mode selected. Please specify +mode=<0/1> in vsim command to test.");        
    $stop;
    end 
  // If it is found, display the mode
  else begin
    $display("Found mode! %d", mode_selection);
    // Set output to selected mode
    mode = mode_selection;
  end 
end : set_mode

// Reading Trace File and Setting Command and Address Outputs
// using the same method as the mode
initial begin : set_command_and_address
  instruction_ready = 0;
  // Check for filename argument in simulation command-line
  if ($value$plusargs("trace=%s", trace_name) == 0) 
    begin       
    // If no filename, show an error and quit.  
    $error("No .trace file given. Please specify +trace=<./STIMULUS/filename.trace> in vsim command to test.");        
    $finish;
    end 
  // If there's a filename, signal it's found, display the filename 
  // and read through the file, setting outputs accordingly.
  else 
    begin
      $display("Found .trace file! %s", trace_name);
      // Load the contents into buffer
      trace_file = $fopen(trace_name, "r");

      // Before reading file, initiate system reset
      cache_reset();

      // Read .trace file and set outputs accordingly
      $display("Beginning to read .trace file");
      // While there are lines to read, keep reading the file
      while(!$feof(trace_file)) 
        begin
          instruction_ready = 1;
          // Scan each line and assign outputs command (integer) and address (hexidecimal)
          $fscanf(trace_file, "%d %h", command, address);
          // Add some delay between reading commands
          #1
          instruction_ready = 0;
          // KNOWN BUG: if consecutive commands are the exact same command and address, design will not detect it as 2 instructions, but only 1
          #3;
        end 

    // Close trace file and end simulation 
    $display("Finished reading .trace file");
    $fclose(trace_file);
    // Add a little delay before stopping to allow values to print
    #1;
    $stop;
    end
end : set_command_and_address

// Reset Task - Wait 1 clock cycle, set the command output to 8, then wait 10 clock cycles 
// for the reset to propogate and settle in the design. 
task cache_reset();
    repeat(1) @(negedge clock);
    $display("System Reset Initiated, Clearing Cache");
    command = 8;
    repeat(5) @(posedge clock);
    $display("Reset Complete");
endtask 

endmodule
