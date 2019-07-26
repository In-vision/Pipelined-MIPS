/******************************************************************
* Description
*	This is the control unit for the ALU. It receves an signal called 
*	ALUOp from the control unit and a signal called ALUFunction from
*	the intrctuion field named function.
* Version:
*	1.0
* Author:
*	Dr. José Luis Pizano Escalante
* email:
*	luispizano@iteso.mx
* Date:
*	01/03/2014
******************************************************************/
module ALUControl
(
	/* ---------------------- INPUTS ----------------------*/
	input [3:0] ALUOp,
	input [5:0] ALUFunction,
	
	/* ---------------------- OUTPUTS ----------------------*/
	output [3:0] ALUOperation,
	output reg Jr_Instruction

);

									// ALUOp _ ALUFunction
									
localparam R_Type_ADD    = 10'b0111_10_0000;
localparam R_Type_AND    = 10'b0111_10_0100;
localparam R_Type_OR     = 10'b0111_10_0101;
localparam R_Type_NOR    = 10'b0111_10_0111;
localparam R_Type_SLL    = 10'b0111_00_0000;
localparam R_Type_SRL    = 10'b0111_00_0010;
localparam R_Type_SUB    = 10'b0111_10_0010;
localparam R_Type_JR	    = 10'b0111_00_1000;


									// Ignore ALUFunction for I type operations
localparam I_Type_ADDI   = 10'b0000_xxxxxx;
localparam I_Type_ANDI   = 10'b0010_xxxxxx;
localparam I_Type_ORI    = 10'b0001_xxxxxx;
localparam I_Type_LUI    = 10'b0011_xxxxxx;
localparam I_Type_LW     = 10'b0100_xxxxxx;
localparam I_Type_SW     = 10'b0101_xxxxxx;
localparam I_Type_BEQ    = 10'b0110_xxxxxx;
localparam I_Type_BNE    = 10'b1000_xxxxxx;

localparam J_Type_JUMP   = 10'b1001_xxxxxx;
localparam J_Type_JAL    = 10'b1001_xxxxxx;



reg [3:0] ALUControlValues;
wire [9:0] Selector;

assign Selector = {ALUOp, ALUFunction};

/*
	ALUOperation (Output)
	Type of operations:
		TYPE									 CODE
		ADD -------------------------- 0000
		AND -------------------------- 0001
		OR  -------------------------- 0010
		NOR -------------------------- 0011
		SHIFT LEFT ------------------- 0100
		SHIT RIGHT ------------------- 0101
		LOAD UPPER ------------------- 0110
		
*/

always@(Selector)begin
	casex(Selector)
		R_Type_ADD:		ALUControlValues = 4'b0000;	// ALUOperation = add
		R_Type_AND:    ALUControlValues = 4'b0001;	// ALUOperation = and
		R_Type_OR: 		ALUControlValues = 4'b0010;	// ALUOperation = or
		R_Type_NOR:		ALUControlValues = 4'b0011;	// ALUOperation = nor
		R_Type_SLL:		ALUControlValues = 4'b0100;	// ALUOperation = sll
		R_Type_SRL:		ALUControlValues = 4'b0101;	// ALUOperation = srl
		R_Type_SUB:		ALUControlValues = 4'b0111;	// ALUOperation = sub
		R_Type_JR:		ALUControlValues = 4'b1001;	// ALUOperation = sub
		
		
		I_Type_ADDI:	ALUControlValues = 4'b0000;	// ALUOperation = add
		I_Type_ANDI:	ALUControlValues = 4'b0001;	// ALUOperation = and
		I_Type_ORI:		ALUControlValues = 4'b0010;	// ALUOperation = or
		I_Type_LUI:		ALUControlValues = 4'b0110;	// ALUOperation = lui
		I_Type_LW:		ALUControlValues = 4'b1010;	// ALUOperation = memoryMap	  
		I_Type_SW:		ALUControlValues = 4'b1010;	// ALUOperation = memoryMap
		I_Type_BEQ:		ALUControlValues = 4'b0111;	
		I_Type_BNE:		ALUControlValues = 4'b0111;	
		
		J_Type_JUMP:	ALUControlValues = 4'b1001;
		J_Type_JAL:	   ALUControlValues = 4'b1001;

		default: ALUControlValues = 4'b1010;
	endcase
	
	Jr_Instruction = (Selector == R_Type_JR) ? 1'b1 : 1'b0;
end


assign ALUOperation = ALUControlValues;

endmodule
//alucontrol//