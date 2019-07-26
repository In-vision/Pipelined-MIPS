/******************************************************************
* Description
*	This performs a shift left opeartion in roder to calculate the brances.
*	1.0
* Author:
*	Dr. José Luis Pizano Escalante
* email:
*	luispizano@iteso.mx
* Date:
*	01/03/2014
******************************************************************/
module ShiftLeft2 
(  
	/* ---------------------- INPUT ----------------------*/
	input [31:0]  DataInput,
	
	/* ---------------------- OUTPUT ----------------------*/
   output reg [31:0] DataOutput

);
   always @ (DataInput)
     DataOutput = {DataInput[29:0], 2'b0};

endmodule 
// leftshift2//'