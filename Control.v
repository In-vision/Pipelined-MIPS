/******************************************************************
* Description
*	This is control unit for the MIPS processor. The control unit is 
*	in charge of generation of the control signals. Its only input 
*	corresponds to opcode from the instruction.
*	1.0
* Author:
*	Dr. José Luis Pizano Escalante
* email:
*	luispizano@iteso.mx
* Date:
*	01/03/2014
******************************************************************/

/*Added jal and jump signals to differentiate those two instructions*/
module Control
(
	/* ---------------------- INPUT ----------------------*/
	input [5:0]OP,
	input [5:0]Funct,   // To be able to detect Jr 
	/* ---------------------- OUTPUTS ----------------------*/
	output [14:0]ControlSignals
);

//Operations to be executed by the proccessor
/*
	
	First Instruction Set
	add, addi, or, ori, and, andi,nor, sll, srl y lui
	
	Type R: add, or, and, nor, sll, srl
	Type I: addi, ori, andi, lui
	Type R: 

	
*/

//Assign opcodes to local variables

localparam R_Type = 0;

localparam I_Type_ADDI = 6'h8;	
localparam I_Type_ORI = 6'h0d;	
localparam I_Type_ANDI = 6'h0c;
localparam I_Type_LUI = 6'h0f;
localparam I_Type_LW = 6'h023;
localparam I_Type_SW = 6'h02b;
localparam I_Type_BEQ = 6'h04;
localparam I_Type_BNE = 6'h05;

localparam J_Type_JUMP = 6'h02;
localparam J_Type_JAL = 6'h03;



reg [14:0] ControlValues;

//Compute control signals based in the opcode
always@(OP or Funct) begin
	casex(OP)
		R_Type:       	ControlValues= 15'b0_001_001_00_00_0111;

		I_Type_ADDI:	ControlValues= 15'b0_000_101_00_00_0000; 	// Verify control values
		I_Type_ORI:		ControlValues= 15'b0_000_101_00_00_0001;	// Verify control values
		I_Type_ANDI:	ControlValues= 15'b0_000_101_00_00_0010;
		I_Type_LUI:		ControlValues= 15'b0_000_101_00_00_0011;
	   I_Type_LW:		ControlValues= 15'b0_000_111_10_00_0100;
		I_Type_SW:		ControlValues= 15'b0_000_100_01_00_0101;
		I_Type_BEQ:		ControlValues= 15'b0_00x_0x0_00_01_0110;
		I_Type_BNE:		ControlValues= 15'b0_00x_0x0_00_10_1000;
		
		J_Type_JUMP:	ControlValues= 15'b0_010_000_00_00_0000;
		J_Type_JAL:    ControlValues= 15'b0_11x_x01_00_00_0000;

		default:
			ControlValues= 15'b00000000000000;
		endcase
		/*Add Jr case*/
	if(OP == 0 && Funct == 8)
			ControlValues[14] = 1;
end	

// Jr  = ControlValues[14]
// Jal = ControlValues[13];
// Jump = ControlValues[12];
// RegDst = ControlValues[11];
// ALUSrc = ControlValues[10];
// MemtoReg = ControlValues[9];
// RegWrite = ControlValues[8];
// MemRead = ControlValues[7];
// MemWrite = ControlValues[6];
// BranchNE = ControlValues[5];
// BranchEQ = ControlValues[4];
// ALUOp = ControlValues[3:0];
	
	assign ControlSignals = ControlValues;

endmodule
//control//

