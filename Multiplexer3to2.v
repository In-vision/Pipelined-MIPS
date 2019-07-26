/******************************************************************
* Description
*	This is a  an 3to1 multiplexer that can be parameterized in its bit-width.
*	1.0
* Author:
*	Luis Beltran and Isaac Cabrera
* Date:
*	18/07/2019
******************************************************************/

module Multiplexer3to2
#(
	parameter NBits=32
)
(
	/* ---------------------- INPUTS ----------------------*/
	input [NBits-31:0] Selector,
	input [NBits-1:0] MUX_Data0,
	input [NBits-1:0] MUX_Data1,
	input [NBits-1:0] MUX_Data2,
	
	/* ---------------------- OUTPUT ----------------------*/
	output reg [NBits-1:0] MUX_Output

);

	always@(Selector,MUX_Data1,MUX_Data0, MUX_Data2) begin
		if(Selector == 0)
			MUX_Output = MUX_Data0;
		else if(Selector == 2)
			MUX_Output = MUX_Data2;
		else
			MUX_Output = MUX_Data1;
	end

endmodule
//mux21//