module Equal
#(
	parameter N=32
)
(
	/* ---------------------- INPUTS ----------------------*/
	input [N-1:0] ReadData1,
	input [N-1:0] ReadData2,
	
	/* ---------------------- OUTPUT ----------------------*/
	output reg  Equal
);

always@(*) begin
	Equal = (ReadData1 == ReadData2) ? 1 : 0;
end

endmodule