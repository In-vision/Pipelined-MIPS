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

/*This module serves the purpose of mapping PC values of MARS since we get different values that don't match
 the PC in verilog*/

module JumpAddressDecoder 
(   
	/* ---------------------- INPUTS ----------------------*/
	input [25:0]  Address,
	input [31:0] PC_4,
	
	/* ---------------------- OUTPUT ----------------------*/	
   output reg [31:0] JumpAddress

);
   always @ (*)
     JumpAddress = {PC_4[31:28], Address, 2'b0};

endmodule 
// leftshift2//