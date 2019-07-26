module Register_ID_EX
(
	/* ---------------------- INPUTS ----------------------*/
	input clk,
	input reset,
	
	input [4:0]	RegDestAddress1,
	input [4:0] RegDestAddress2,
	input [4:0] RegOperandRS,
	input [31:0] Immediate,
	
	/*Data for ALU*/
	input [31:0] ReadData1,
	input [31:0] ReadData2,
	
	input [31:0] Instruction,
	input [31:0] PC,
	
	/*Control signals for ID/EX*/
	/* Without Jr, Jal, Jump, Bne, Beq, these signals wont be used 
	   in Memory Stage*/
	input [10:0] ControlSignals,
	
	/* ---------------------- OUTPUTS ----------------------*/

	output reg [4:0] RegDestAddress1_out,
	output reg [4:0] RegDestAddress2_out,
	output reg [31:0] Immediate_out,
	output reg [4:0] RegOperandRS_out,
	
	/*Data for ALU*/
	output reg [31:0] ReadData1_out,
	output reg [31:0] ReadData2_out,
	
	output reg [31:0] Instruction_out,
	output reg [31:0] PC_out,
	
	/*Control signals for ID/EX*/
	output reg [10:0] ControlSignals_out
);

always@(negedge reset or posedge clk) begin
	if(reset==0)
		begin
		PC_out <= 0;
		end
	else	
		begin
		RegDestAddress1_out <= RegDestAddress1;
	   RegDestAddress2_out <= RegDestAddress2;
		Immediate_out <= Immediate;
		
	/*Data for ALU*/
		ReadData1_out <= ReadData1;
		ReadData2_out <= ReadData2;
		
		Instruction_out <= Instruction;
		PC_out <= PC;
		
	/*Control signals for ID/EX*/
		ControlSignals_out <= ControlSignals;
	
	/* Operand RS for forwarding unit */
		RegOperandRS_out <= RegOperandRS;

		end
		
end	
endmodule