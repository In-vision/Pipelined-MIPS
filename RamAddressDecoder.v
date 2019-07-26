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

//This module serves the purpose of mapping the memory addresses of the RAM
module RamAddressDecoder 
(   
	/* ---------------------- INPUT ----------------------*/
	input [31:0]  Address,
	
	/* ---------------------- OUTPUT ----------------------*/
   output reg [31:0] RamAddress

);
/*In here, since the base memory address in MARS is of 10010000 we want to subtract that number so 
we can start at the address of 0 in our RAM. We do a shift right of two because the top memory address
in MARS is of 1023 + 32'h1001000, so when we subtract we get the number of 1023, when we do a shift right
of two we get the value of 255, making the top memory address be of 255 fitting the total addresses in 
the RAM.*/
   always @ (*)
     RamAddress = (Address - 32'h10010000) >> 2;

endmodule 
