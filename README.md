# MESI-Cache-Simulator
Final project for ECE585 - Microprocessor Systems Design (Winter 2021, Portland State University) 

----------------------------------------------------------------------------------------------

ECE585 - Microprocessor System Design
Portland State University - Winter 2021

Team 3 (Zack, Megha, Natalie, Karla) - Split L1 MESI Cache Design and Verification

README

----------------------------------------------------------------------------------------------

Our makefile is designed to run on a linux server with mentor-questa-2019 installed. 

To ensure mentor-questa-2019 is on your linux machine, run addpkg and make sure 
[x] mentor-questa-2019 is checked. Once you have confirmed your simulator is installed,
follow these steps to run our simulations. . . 


	1. Navigate to 'Source Code' Folder and open a Terminal window.

	2. Type 'make help' to see instructions / options for execution and all test names.

	3. Type 'make compile' to compile the project.

	4. After compilation, the user can run as many tests as desired consecutively 
	by typing 'make <test_name>_mode<0|1>'.


To create and run custom tests / traces: 

	1. Create a set of traces and place them line-by-line in a file 
	that has a .trace extension (e.g. example.trace, NOT .txt) and place it in the 
	./STIMULUS/ folder of our verification environment. Make sure the end 
	of the file has a '9' command to view the contents and statistics. 

	2. After compiling, run the following command for either mode desired: 
	Mode 0 - vsim -c +trace="./STIMULUS/example.trace" +mode=0 tb_top -do "run -all;quit"
	Mode 1 - vsim -c +trace="./STIMULUS/example.trace" +mode=1 tb_top -do "run -all;quit"

	3. Alternatively, you can add both of those lines to the Makefile and create two 
	targets (example_mode0: and example_mode1:) for more convenient back to back runs. 
 
