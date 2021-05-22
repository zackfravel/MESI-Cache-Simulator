/*

Team 3 - (Natalie, Megha, Zack, Karla)
ECE585 Final Project
Winter 2021

Cache_Defs.sv
--------------------
Description:

Contains the global typedefs, const, enum, etc. for the Cache simulation

*/

package Cache_Defs;

// define the cache constant parameter - width / number of bits
parameter Addr_size = 32;		// Total adress bits = 32 bits
parameter TagAddr_size = 12;		// Tag Address size = 12 bits
parameter IndexAddr_size = 14;		// Index_address size = 14 bits
parameter ByteAddr_size = 6;		// Byte Select bits size = 6 bits

parameter num_sets = 16*1024; 		// 16k sets
parameter num_ways_data = 8;		// Number of Ways = 8 in 8-set associative data cache
parameter num_ways_inst = 4;		// Number of Ways = 4 in 4-set associative instruction cache

parameter LRUsize_data = 3;	// Number of bits for LRU = 3 for 8-way set associative Data Cache
parameter LRUsize_inst = 2;	// Number of bits for LRU = 2 for 4-way set associative Instr Cache

// define cache states for MESI Protocol
typedef enum logic[1:0] {
	M = 2'b00, 	// Modified
	E = 2'b01,	// Exclusive
	S = 2'b10,	// Shared
	I = 2'b11	// Invalid
} MESI_States;

// Next state signals
MESI_States NextState_Data_Cache[num_sets-1:0][num_ways_data:0],
            NextState_Instruction_Cache[num_sets-1:0][num_ways_inst:0];

// Packs the logics for the tag, lru, and mesi logics and instantiates a the caches 
// by instantiating 16k x 8 ways cache lines for the data cache. Instruction cache is 16k x 4 ways cache lines. 
typedef struct packed {
	logic [TagAddr_size-1:0] tag;
	logic [LRUsize_data-1:0] lru;
	MESI_States mesi;
} DataCacheLine;

DataCacheLine [num_sets-1:0][num_ways_data:0] Data_Cache; 


typedef struct packed {
	logic [TagAddr_size-1:0] tag;
	logic [LRUsize_inst-1:0] lru;
	MESI_States mesi;
} InstructionCacheLine;

InstructionCacheLine [num_sets-1:0][num_ways_inst:0] Instruction_Cache; 


endpackage:Cache_Defs