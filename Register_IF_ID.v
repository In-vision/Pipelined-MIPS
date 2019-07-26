
module Register_IF_ID

(
	/* ---------------------- INPUTS ----------------------*/
	input clk,
	input reset,
	
	input [31:0] Instruction,
	input [31:0] PC,
	input			 Flush,
	input			 ifId_Write,
	
	/* ---------------------- OUTPUTS ----------------------*/
	output reg [31:0] Instruction_out, 
	output reg [31:0] PC_out
);

always@(negedge reset or posedge clk) begin
	if(reset==0)
		begin
		PC_out <= 32'h0040_0000;
		Instruction_out <= 0;
		end
	else if(!ifId_Write)
			begin
				if(Flush)
					begin
						PC_out <= 32'h0040_0000;
						Instruction_out <= 0;
					end
				else
					begin
						PC_out <= PC;
						Instruction_out <= Instruction;
					end
	end		
		
end
endmodule