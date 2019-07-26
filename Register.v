/******************************************************************
* Description
*	This the basic register that is used in the register file
*	1.0
* Author:
*	Dr. José Luis Pizano Escalante
* email:
*	luispizano@iteso.mx
* Date:
*	01/03/2014
******************************************************************/
module Register
#(
	parameter N=32
)
(
	/* ---------------------- INPUTS ----------------------*/
	input clk,
	input reset,
	input enable,
	input  [N-1:0] DataInput,
	
	/* ---------------------- OUTPUT ----------------------*/
	output reg [N-1:0] DataOutput
);

always@(negedge reset or negedge clk) begin
	if(reset==0)
		DataOutput <= 0;
	else	
		if(enable==1)
			DataOutput<=DataInput;
end

endmodule
//register//