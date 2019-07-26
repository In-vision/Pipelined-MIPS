module Register_EX_MEM
(
	/* ---------------------- INPUTS ----------------------*/

	input clk,
	input reset,
	
	input [4:0]	RegDestAddress,
	input [31:0] WriteDataRam,
	input [31:0] AluResult,
	input [31:0] Instruction,
	input [31:0] PC,
	
	/*Control signals for EX/MEM*/
	/* Without Jr, Jal, Jump, Bne, Beq, these signals wont be used 
	   in Memory Stage*/
	
	input [4:0] ControlSignals,
	
	
	
	/* ---------------------- OUTPUTS ----------------------*/

	output reg [4:0] RegDestAddress_out,
	output reg [31:0] WriteDataRam_out,
	output reg [31:0] AluResult_out,
	output reg [31:0] Instruction_out,
	output reg [31:0] PC_out,
	
	/*Control signals for EX/MEM*/
	output reg [4:0] ControlSignals_out
);

always@(negedge reset or posedge clk) begin
	if(reset==0)
		begin
		PC_out <= 0;
		end
	else	
		begin
		RegDestAddress_out <= RegDestAddress;
		WriteDataRam_out <= WriteDataRam;
		AluResult_out <= AluResult;
		Instruction_out <= Instruction;
		PC_out <= PC;
		/*Control signals for EX/MEM*/
		ControlSignals_out <= ControlSignals;

		end
		
end

endmodule