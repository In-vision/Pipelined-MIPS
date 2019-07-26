/******************************************************************
* Description
*	This is the data memory for the MIPS processor
*	1.0
* Author:
*	Dr. José Luis Pizano Escalante
* email:
*	luispizano@iteso.mx
* Date:
*	01/03/2014
******************************************************************/

module DataMemory 
#(	parameter DATA_WIDTH=32,		//Word size 32
	parameter MEMORY_DEPTH = 256		// 64 datos

)
(
	/* ---------------------- INPUTS ----------------------*/
	input [DATA_WIDTH-1:0] WriteData,
	input [DATA_WIDTH-1:0]  Address,
	input MemWrite,MemRead, clk,
	
	/* ---------------------- OUTPUT ----------------------*/
	output  [DATA_WIDTH-1:0]  ReadData
);
	
	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[MEMORY_DEPTH-1:0];
	wire [DATA_WIDTH-1:0] ReadDataAux;
//	wire [(DATA_WIDTH-1):0] RealAddress;

//	assign RealAddress = {2'b0,Address[(DATA_WIDTH-1):2]};	//Mapping addres

	always @ (posedge clk)
	begin
		// Write
		if (MemWrite)
			ram[Address] <= WriteData;
	end
	assign ReadDataAux = ram[Address];
  	assign ReadData = {DATA_WIDTH{MemRead}}& ReadDataAux;

endmodule
//datamemory//