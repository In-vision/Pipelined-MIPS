module HazardDetectionUnit
(
	/* ---------------------- INPUTS ----------------------*/
	input [4:0]	idEx_RegDstAddress1, //rt
	input  		idEx_MemRead,
	input [4:0] ifId_RegOperandRS,
	input [4:0] ifId_RegRt,
	input 		ifId_Jr,
	input 		ifId_Jump,
	input  		Branch,
	
	
	
	
	/* ---------------------- OUTPUTS ----------------------*/
	output reg	Stall,
	output reg	Flush,
	output reg	PC_Write,
	output reg	ifId_Write
	
);

	always@(*) begin
      if(idEx_MemRead && ((idEx_RegDstAddress1 == ifId_RegOperandRS) 
		   || (idEx_RegDstAddress1 == ifId_RegRt)))
			begin
				Stall <= 1;
				PC_Write <= 1;
				ifId_Write <= 1;
			end
      else
			begin
				Stall <= 0;
				PC_Write <= 0;
				ifId_Write <= 0;
			end
      Flush <= (Branch|ifId_Jump|ifId_Jr);
	end

endmodule