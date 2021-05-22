/*

Team 3 - (Megha, Natalie, Karla, Zack)
ECE585 Final Project
Winter 2021

L1_Cache.sv
--------------------
Description:

Project Design-Under-Test (DUT). Implements a split L1 Cache 
with 8-way associative data cache and 4-way associate instruction
cache with LRU eviction/replacement policy and MESI cache coherence. 
Designed to read trace files in conjunction with trace_parser.sv, 
takes an address and command (n) input along with the desired user
mode. 

Mode 0 - Simulation displays usage statistics and cache contents in 
		 response to command '9'

Mode 1 - Simulation displays all Mode 0 content, along with communication
		 to the L2 cache.

*/

import Cache_Defs::*;

module L1_Cache (
	input logic reset, clk,	instruction_ready,
	input logic [Addr_size-1:0] Address,
	input int n, MODE
);		

// Internal Variables
logic [IndexAddr_size-1:0] set;
logic [TagAddr_size-1:0] Tag, Old_Tag;
logic [2:0] way;

logic HIT;		    // HIT = 1 -> cache hit, HIT = 0 -> cache miss
int hit_index;		// index where a hit occurs
logic first_read_write =0;

// Statistics Variables
int instruction_reads = 0; 
int instruction_hits = 0; 
int instruction_misses = 0;
int data_reads = 0; 
int data_writes = 0; 
int data_hits = 0; 
int data_misses = 0;


//---------------------------------------Task / Functions Defenitions-------------------------------------//

// Task to Reset Cache Contents
task Reset_Cache_Contents();

	// Clearing Data Cache
	for(int i=0; i<num_sets; i++) begin
		for (int j=0; j<num_ways_data; j++) begin
			Data_Cache[i][j].tag = 'x;
			Data_Cache[i][j].lru = 'x;
			Data_Cache[i][j].mesi = I; 
		end
	end
	data_reads = 0; 
   	data_writes = 0;
	data_hits = 0;
	data_misses = 0;

	// Clearing Instruction Cache
	for(int i=0; i<num_sets; i++) begin
		for (int j=0; j<num_ways_inst; j++) begin
			Instruction_Cache[i][j].tag = 'x;
			Instruction_Cache[i][j].lru = 'x;
			Instruction_Cache[i][j].mesi = I; 
		end
	end
	instruction_reads = 0; 
	instruction_hits = 0; 
	instruction_misses = 0;

endtask

// Internal Signals for Statstics 
real hit_ratio; 
real total_ops;
real reads, hits, misses;
real writes; 

// Calcualate usage statistics / hit ratio for cache accesses
task calculate();
  reads = instruction_reads + data_reads;
  writes = data_writes;
  total_ops = reads + data_writes;
  hits = instruction_hits + data_hits;
  misses = instruction_misses + data_misses;
  hit_ratio = hits / total_ops;
endtask

// Print usage statistics and hit ratio
task print();
  $display(" ");
  $display("Number of Reads  = %d", reads);
  $display("Number of Writes = %d", writes);
  $display("Number of Hits   = %d", hits);
  $display("Number of Misses = %d", misses);
  $display("Hit Ratio        = %F or %d%%", hit_ratio, hit_ratio*100);
  $display(" ");
endtask

// Task to print Data and Instruction Cache Valid contents
task Print_Cache_Contents();
	
	// Printing DATA CACHE
	$display("\n\t\t*****DATA CACHE*****");
	for(int i=0; i<num_sets; i++)
		for (int j=0; j<num_ways_data; j++)
		begin
			if(Data_Cache[i][j].lru !== 'x)
			begin
				$display(" ");
				$display("Set = %h   Way = %d   Tag = %h   LRU = %b   MESI = %s", i, j, Data_Cache[i][j].tag, Data_Cache[i][j].lru, Data_Cache[i][j].mesi);
				$display(" ");
			end
		end

	// Printing INSTRUCTION CACHE
	$display("\t\t*****INSTRUCTION CACHE*****");
	for(int i=0; i<num_sets; i++)
		for (int j=0; j<num_ways_inst; j++)
		begin
			if(Instruction_Cache[i][j].lru !== 'x)
			begin
				$display(" ");
				$display("Set = %h   Way = %d   Tag = %h   LRU = %b   MESI = %s", i, j, Instruction_Cache[i][j].tag, Instruction_Cache[i][j].lru, Instruction_Cache[i][j].mesi);
				$display(" ");
			end
		end

	// Calculate usage statistics and hit ratio
	calculate();
	// Print usage statistics and hit ratio 
	print();

endtask


// Store tag 
task Tag_Update(logic [IndexAddr_size-1:0] set, logic [2:0] way, logic [TagAddr_size-1:0] Tag, int n);
	// store in instruction cache
	if (n == 2) begin		
		Instruction_Cache[set][way].tag = Tag;
	end
	// store in data cache
	else begin				
		Data_Cache[set][way].tag = Tag;
	end
endtask

// Update LRU bits on the cache line
task Update_LRUbits(input logic [IndexAddr_size-1:0] set, int hit_index, n);

	// instruction cache
	if (n == 2 )begin //&& hit_index != 9) begin	
		// empty way
		if (Instruction_Cache[set][hit_index].lru === 'x) begin		// empty way
			for (int i=0; i<hit_index; i++) begin					// loop until it reaches the empty way
				Instruction_Cache[set][i].lru = Instruction_Cache[set][i].lru + 1'b1;	// increment LRU bits
			end
			Instruction_Cache[set][hit_index].lru = '0;
		end

		// no empty way
		else begin
			for (int i=0; i<num_ways_inst; i++) begin
				if ( Instruction_Cache[set][i].lru < Instruction_Cache[set][hit_index].lru) begin
					Instruction_Cache[set][i].lru = Instruction_Cache[set][i].lru + 1'b1;	// increment LRU bits when they are less than the LRU bits of the hit index
				end
			end
			Instruction_Cache[set][hit_index].lru = '0;		// set MRU to 00, anything that is greater than LRU bits of the hit index is ignored
		end
	end

	// Data Cache
	else if(hit_index !=9) begin		
		// empty way
		if (Data_Cache[set][hit_index].lru === 'x) begin		// empty way
			for (int i=0; i<hit_index; i++) begin			// loop until it reaches the empty way
				Data_Cache[set][i].lru = Data_Cache[set][i].lru + 1'b1;		// increment LRU bits
			end
			Data_Cache[set][hit_index].lru = '0;
		end

		// no empty way
		else begin
			for (int i=0; i<num_ways_data; i++) begin
				if (Data_Cache[set][i].lru < Data_Cache[set][hit_index].lru) begin
					Data_Cache[set][i].lru = Data_Cache[set][i].lru + 1'b1;	// increment LRU bits when they are less than the LRU bits of the hit index
				end
			end
			Data_Cache[set][hit_index].lru = '0;	// set MRU to 000, anything that is greater than LRU bits of the hit index is ignored
		end
	end
endtask


// Function for checking Hit/Miss
function int Check_Cache_Hit(logic [IndexAddr_size-1:0] set, logic [TagAddr_size-1:0] Tag, int n);
    // Check Hit / Miss in Data Cache
    if( n == 0 || n==1 || n==3 || n==4)
	begin
		for (int j=0; j<num_ways_data; j++)
	    begin
			if(Data_Cache[set][j].tag == Tag)
			     return j;
	    end
		Check_Cache_Hit = 9;	// 9. Just to indicate it is not a number from 0-7 ways. Any better Idea?
  	end
    // Check Hit / Miss in Instruction Cache
    else if( n == 2)
  	begin
		for (int j=0; j<num_ways_inst; j++)
        begin
	    	if( Instruction_Cache[set][j].tag == Tag) 
	    	begin
				//$display("Instr hit index return: %d", j);
				return j;
			end
	     end
		return 9;
  	end
endfunction


// Find way number 
function automatic logic [3:0] Find_Insert_Data(logic [IndexAddr_size-1:0] set);

	logic [LRUsize_data-1:0] j = '0;
	logic [LRUsize_data-1:0] I_array [num_ways_data-1:0];			// use to store the index indicates I state
	logic [LRUsize_data-1:0] num_I_states = '0;				// number of I states
	logic [LRUsize_data-1:0] biggest_LRU_bits = '0;		// use to store a temperary biggest LRU bits, the bigger the value the less recently used
	logic [LRUsize_data-1:0] LRU_index;						// index indicates LRU way on the cache line
	logic first_rw = 0;

	// check if there is an empty way
	for (int i=0; i<num_ways_data; i++) 
	begin
		if ( Data_Cache[set][i].lru === 'x) 
			begin
				first_rw = 1;
				return {first_rw, i[2:0]};				// return way # when there is an empty way
			end
	end
								
	// check for the number of I states on the cache line
	for (int i=0; i<num_ways_data; i++) 
	begin
		if (Data_Cache[set][i].mesi === I) 
		begin
			num_I_states++;
			I_array[j] = i;				// For example, way-2 and way-5 are in I states then I_array = {1,4}
			j++;
		end
	end

	// one I state
	if (num_I_states == 1) 
		return {first_rw, I_array[0]};				// return the first element in I_array since there's only one I state	
	// more than one I state
	else if (num_I_states > 1) 
	begin
		for (int i=0; i<num_I_states; i++) 
		begin
			// if there is bigger LRU bits then store it as the biggest LRU bits, also store the index
			if (biggest_LRU_bits < Data_Cache[set][I_array[i]].lru) 
			begin
				biggest_LRU_bits = Data_Cache[set][I_array[i]].lru;
				LRU_index = I_array[i];
			end
		end
		return { first_rw, LRU_index};				// return I way # that is LRU
	end

	// no I state, then check for LRU bits
	else if (num_I_states == 0) 
	begin
		//$display("Meg:no I state, then check for LRU bits");
		for (int i=0; i<num_ways_data; i++) 
		begin
			if (Data_Cache[set][i].lru == 3'b111)	// 111 means LRU
			begin
				return {first_rw, i[2:0]};			// return the way # that has 111 LRU bits
			end
		end
	end

endfunction


// Find way number to be evicted in instruction cache
function automatic logic [LRUsize_inst-1:0] Find_Insert_Instr(logic [IndexAddr_size-1:0] set);

	// check if there is an empty way
	for (int i=0; i<num_ways_inst; i++) 
	begin
		if ( Instruction_Cache[set][i].lru === 'x) 
			begin
				return i;	// return way # when there is an empty way
			end
	end
							
	// no empty way
	for (int i=0; i<num_ways_inst; i++) 
	begin
		if (Instruction_Cache[set][i].lru == 2'b11)	// 11 means LRU
			begin
				return i;	// return the way # that has 11 LRU bits
			end
	end
	

endfunction


//--------------------------------always blocks----------------------------------------------------//


 assign set = Address[ByteAddr_size+IndexAddr_size-1 : ByteAddr_size];	//getting index addr bits from Address
 assign Tag = Address[ByteAddr_size+IndexAddr_size+TagAddr_size-1 : ByteAddr_size+IndexAddr_size];



//------------Read and Write count registers------------------
always_ff@(posedge clk) begin	
  if (reset)
	Reset_Cache_Contents();
  else
	begin
		if( n==0 || n==1 || n==3 || n==4)		
		begin
			Data_Cache[set][way].mesi <= NextState_Data_Cache[set][way];
		end

		else if ( n==2 )
		begin	
			Instruction_Cache[set][way].mesi <= NextState_Instruction_Cache[set][way];
		end

	end
end



//----------------------Program flow: find Hit/Miss, find Hit_index or evict location, LRU update, State Update...-----

// Logic is sensitive to changes in commands and addresses
// (FIXED) KNOWN BUG: if consecutive commands are the exact same command and address, design will not detect it as 2 instructions, but only 1
always @(n, Address, posedge instruction_ready) begin

case (n)
  0,1:	begin
	hit_index = Check_Cache_Hit(set, Tag, n);	// Returns hit_index for a hit
	// Checking if it is a HIT/MISS. i.e, what is retured in hit_index
	if( hit_index == 9 )
		begin
	        HIT = 0;
			data_misses++;
			{first_read_write, way}  = Find_Insert_Data(set); // way -> where the data to be entered (after evicting data if required)
			Old_Tag = Data_Cache[set][way].tag;
			Tag_Update(set, way, Tag, n);
		end
	else 
		begin
			HIT = 1;
			data_hits++;
			way = hit_index; // way -> where the tag is already present
		end

	Update_LRUbits(set, way, n);
	Cache_State_Update( n, set, way, MODE, HIT, Tag, Old_Tag, first_read_write);

	//Stat Update data
	if( n==0 )
	   data_reads++;
	else
	   data_writes++;
	end

  2:
	begin
	hit_index = Check_Cache_Hit(set, Tag, n);	// Returns hit_index for a hit
	// Checking if it is a HIT/MISS. i.e, what is retured in hit_index
	if( hit_index == 9 )
		begin
	        HIT = 0;
			instruction_misses++;
			way = Find_Insert_Instr(set);	// way -> where the data to be entered (after evicting data if required)
			Old_Tag = Data_Cache[set][way].tag;
			Tag_Update(set, way, Tag, n);
		end
	else 
		begin
			HIT = 1;
			instruction_hits++;
			way = hit_index; // way -> where the tag is already present
		end

	Update_LRUbits(set, way, n);
	Cache_State_Update( n, set, way, MODE, HIT, Tag, Old_Tag, first_read_write);

	//Stat Update data
	instruction_reads++;
	end

  3:
	begin
	hit_index = Check_Cache_Hit(set, Tag, n);	// Returns hit_index for a hit
	// Checking if it is a HIT/MISS. i.e, what is retured in hit_index
	if( hit_index == 9) //num_ways_data )
		begin
	        HIT = 0;
			// DO NOTHING
		end
	else 
		begin
			HIT = 1;
			way = hit_index;		// way -> where the tag is already present
		end

	Update_LRUbits(set, hit_index, n);
	Cache_State_Update( n, set, way, MODE, HIT, Tag, Old_Tag, first_read_write);

	end
  4:
	begin
	hit_index = Check_Cache_Hit(set, Tag, n);	// Returns hit_index for a hit
	// Checking if it is a HIT/MISS. i.e, what is retured in hit_index
	if( hit_index == 9 )
		begin
	        HIT = 0;
			// DO NOTHING
		end
	else 
		begin
			HIT = 1;
			way = hit_index;		// way -> where the tag is already present
		end

	Update_LRUbits(set, hit_index, n);
	Cache_State_Update( n, set, way, MODE, HIT, Tag, Old_Tag, first_read_write);

	end

  8:
	begin
		Reset_Cache_Contents();
		Cache_State_Update( n, set, way, MODE, HIT, Tag, Old_Tag, first_read_write);
	end

  9:
	begin
		Print_Cache_Contents();
		Cache_State_Update( n, set, way, MODE, HIT, Tag, Old_Tag, first_read_write);
	end

  default: $strobe("Invalid Operation (n = %1d)", n);
endcase

end


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Note : If required we can merge below task into above always_comb block,


//-----------------FSM Module -> Update States of Data and Instr Cache and Displays messages if Mode == 1   -----------------//

// State Machine for updating MESI States
task Cache_State_Update (	int n,	// n = 0, 1, 2, 3, 4, 8, 9
				logic [IndexAddr_size-1:0] set,	//set number range - 16383:0 (14-bit number)
				logic [3-1:0] way, 	// way number range -8:1 or 4:1 (3 bit number).
				logic MODE,
				logic HIT,
				logic [TagAddr_size-1:0] Tag,
				logic [TagAddr_size-1:0] Old_Tag,
				logic first_read_write );

  unique case (n)
  
  0:	// Read Request to L1 Data Cache
	
	begin
	unique case (HIT) 
	1'b1:  		// Cache Hit
		case (Data_Cache[set][way].mesi) 
		M:	NextState_Data_Cache[set][way] = M;
		E:	NextState_Data_Cache[set][way] = S;
		S:	NextState_Data_Cache[set][way] = S;
		I:	begin
			NextState_Data_Cache[set][way] = E;
			if ( MODE == 1 )     $strobe("Read from L2 <%h>", Tag);
			end
		endcase

	1'b0:	begin	// Cache Miss
		case (Data_Cache[set][way].mesi) 
		M:	begin
			NextState_Data_Cache[set][way] = E;
			if ( MODE == 1 )     $strobe("Write to L2 <%h>", Old_Tag);
			end
		E:	NextState_Data_Cache[set][way] = E;
		S:	NextState_Data_Cache[set][way] = E;
		I:	NextState_Data_Cache[set][way] = E;
		endcase
		if ( MODE == 1 )     $strobe("Read from L2 <%h>", Tag);
		end
	default:	NextState_Data_Cache[set][way] = I;
	endcase
	end	

  1:	// Write Request to L1 Data Cache

	begin
	unique case (HIT)	
	1'b1:  	        // Cache Hit
		case (Data_Cache[set][way].mesi) 
		M:	NextState_Data_Cache[set][way] = M;
		E:	NextState_Data_Cache[set][way] = M;
		S:	NextState_Data_Cache[set][way] = M;
		I:	begin
			NextState_Data_Cache[set][way] = M;
			if ( MODE == 1 )     $strobe("Read for Ownership from L2 <%h>", Tag);
			end
		endcase

	1'b0:	begin	// Cache Miss
		case (Data_Cache[set][way].mesi) 
		M:	begin
			NextState_Data_Cache[set][way] = M;
			if ( MODE == 1 )     $strobe("Write to L2 <%h>", Old_Tag);
			end
		E:	NextState_Data_Cache[set][way] = M;
		S:	NextState_Data_Cache[set][way] = M;
		I:	NextState_Data_Cache[set][way] = M;
		endcase
		if ( MODE == 1 )     
			begin 
			   if( first_read_write == 1)  
			      $strobe("Write to L2 <%h>", Tag);
			   else
			       $strobe("Read for Ownership from L2 <%h>", Tag);
			 end
		first_read_write =0;
		end
	default: ;
	endcase

	end
  2:	// Read Request to L1 Instruction Cache

	begin
	unique case (HIT)	
	1'b1:  	    // Cache Hit
		case (Instruction_Cache[set][way].mesi) 
		M:	$strobe("Impossible State\n");  // Instruction Cache is Read only. Cannot have M state
		E:	NextState_Instruction_Cache[set][way] = S;
		S:	NextState_Instruction_Cache[set][way] = S;
		I:	begin 
				NextState_Instruction_Cache[set][way] = E;
				if ( MODE == 1 ) $strobe("Read from L2 <%h>", Tag);
			end
		endcase

	1'b0:	begin	// Cache Miss
		case (Instruction_Cache[set][way].mesi) 
		M:	$strobe("Impossible State\n");  // Instruction Cache is Read only. Cannot have M state
		E:	NextState_Instruction_Cache[set][way] = E;
		S:	NextState_Instruction_Cache[set][way] = E;
		I:	NextState_Instruction_Cache[set][way] = E;
		endcase
		if ( MODE == 1 ) $strobe("Read from L2 <%h>", Tag);
		end
	default: ;
	endcase
	end

  3:	// Invalidate Command from L2

	begin
	unique case (HIT)	
	1'b1:  // Cache Hit
		case (Data_Cache[set][way].mesi) 
		M:	begin
				NextState_Data_Cache[set][way] = I;
				if ( MODE == 1 ) $strobe("Return Data to L2 <%h>", Tag);
			end
		E:	begin 
				NextState_Data_Cache[set][way] = I;
				$display("**Changing E to I: %b", NextState_Data_Cache[set][way]);
			end
		S:	NextState_Data_Cache[set][way] = I;
		I:	NextState_Data_Cache[set][way] = I;
		endcase

	1'b0: // Cache Miss
		; // Do Nothing
	default: ;
	endcase
	end

  4:	// Data Request from L2 (RFO)

	begin
	unique case (HIT)	
	1'b1:           // Cache Hit
		case (Data_Cache[set][way].mesi) 
		M:	begin
				NextState_Data_Cache[set][way] = I;
				if ( MODE == 1 ) $strobe("Return Data to L2 <%h>", Tag);
			end
		E:	NextState_Data_Cache[set][way] = I;
		S:	NextState_Data_Cache[set][way] = I;
		I:	NextState_Data_Cache[set][way] = I;
		endcase

	1'b0:		// Cache Miss
		; // Do Nothing
	default: ;
	endcase
	end

  8:	// Reset Cache

  	begin
	  if(Data_Cache[set][way].mesi == M) $strobe("Write to L2 <%h>", Tag);
	  NextState_Data_Cache[set][way] = I; 
	  NextState_Instruction_Cache[set][way] = I;
	end

  default: ; 
 
 endcase

endtask:Cache_State_Update



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


endmodule: L1_Cache





