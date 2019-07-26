module ForwardingUnit
(
	/* ---------------------- INPUTS ----------------------*/
	input [4:0]	idEx_RegDstAddress1, //rt
	input [4:0] idEx_RegOperandRS,
	input [4:0] exMem_RegisterRd,
	input 		exMem_RegWrite,
	input [4:0] memWB_RegisterRd,
	input  		memWB_RegWrite,
	
	
	
	
	/* ---------------------- OUTPUTS ----------------------*/
	output reg [1:0] forwardA,
	output reg [1:0] forwardB
);

	always@(*) begin
	forwardA <= 0;
	forwardB <= 0;
	
	if( exMem_RegWrite && 
	   (exMem_RegisterRd != 0) &&  
		(exMem_RegisterRd == idEx_RegOperandRS) )
			forwardA <= 2;
			
	if( exMem_RegWrite && 
	   (exMem_RegisterRd != 0) && 
		(exMem_RegisterRd == idEx_RegDstAddress1))
			forwardB <= 2;	
		
	if( memWB_RegWrite && 
	   (memWB_RegisterRd != 0) &&  (exMem_RegisterRd != idEx_RegOperandRS) && 
		(memWB_RegisterRd == idEx_RegOperandRS))
			forwardA <= 1;
		
	if  (memWB_RegWrite && 
	    (memWB_RegisterRd != 0) && (exMem_RegisterRd != idEx_RegDstAddress1) && 
		 (memWB_RegisterRd == idEx_RegDstAddress1))	
			forwardB <= 1;
	end

endmodule