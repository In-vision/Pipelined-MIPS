/******************************************************************
* Description
*	This module performes a sign-extend operation that is need with
*	in instruction like andi or ben.
* Version:
*	1.0
* Author:
*	Dr. José Luis Pizano Escalante
* email:
*	luispizano@iteso.mx
* Date:
*	01/03/2014
******************************************************************/
module SignExtend
(  
	/* ---------------------- INPUT ----------------------*/ 
	input [15:0]  DataInput,
	
	/* ---------------------- OUTPUT ----------------------*/
   output[31:0] SignExtendOutput
);

assign  SignExtendOutput = {{16{DataInput[15]}},DataInput[15:0]};

endmodule 
// signextend//
