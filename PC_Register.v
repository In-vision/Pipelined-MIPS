/******************************************************************
* Description
*	This is a register of 32-bit that corresponds to the PC counter. 
*	This register does not have an enable signal.
* Version:
*	1.0
* Author:
*	Dr. José Luis Pizano Escalante
* email:
*	luispizano@iteso.mx
* Date:
*	01/03/2014
******************************************************************/

module PC_Register
#(
	parameter N=32
)
(
	/* ---------------------- INPUTS ----------------------*/
	input clk,
	input reset,
	input [N-1:0] NewPC,
	input PC_Write,
	
	/* ---------------------- OUTPUT ----------------------*/
	output reg [N-1:0] PCValue
);

always@(negedge reset or posedge clk) begin
	if(reset==0)
		PCValue <= 32'h0040_0000;
	else if(PC_Write != 1)
		PCValue<=NewPC;
end

endmodule
//pcreg//