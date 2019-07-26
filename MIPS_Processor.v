/******************************************************************
* Description
*	This is the top-level of a MIPS processor
* This processor is written Verilog-HDL. Also, it is synthesizable into hardware.
* Parameter MEMORY_DEPTH configures the program memory to allocate the program to
* be execute. If the size of the program changes, thus, MEMORY_DEPTH must change.
* This processor was made for computer organization class at ITESO.
******************************************************************/


module MIPS_Processor
#(
	parameter MEMORY_DEPTH = 256
)
(
	/* ---------------------- INPUTS ----------------------*/
	input clk,
	input reset,
	input [7:0] PortIn,
	/* ---------------------- OUTPUTS ----------------------*/
	output [31:0] ALUResultOut,
	output [31:0] PortOut
);

assign  PortOut = 0;

//******************************************************************/
//****************  WIRES TO INTERCONNECT MODULES   ****************/
//******************************************************************/
wire [3:0] ALUOperation_wire;
wire [31:0] Instruction_wire;
wire [31:0] ReadData1_wire;
wire [31:0] ReadData2_wire;
wire [31:0] InmmediateExtend_wire;
wire [31:0] ALUResult_wire;
wire [31:0] PC_4_wire;
wire [31:0] PC_wire;

wire [31:0] dataReadRam_wire;
wire [31:0] realPC_wire;

//ControlSignals Wire
wire [14:0] ControlSignals_wire;

/****************************** STAGE IF/ID *****************************************************/

//PIPELINE OUTPUT IF/ID WIRES
wire [31:0] ifId_InstructionWire;
wire [31:0] ifId_PCwire;


/****************************** STAGE ID/EX *****************************************************/

//PIPELINE OUTPUT ID/EX
wire [4:0] 	idEx_RegDstAdd1;
wire [4:0] 	idEx_RegDstAdd2;
wire [31:0]	idEx_ImmediateExtend;
wire [31:0] idEx_RdData1;
wire [31:0] idEx_RdData2;
wire [31:0] idEx_Instructionwire;
wire [31:0] idEx_PCwire;
wire [4:0] 	idEx_RegOperandRS;
wire [10:0] idEx_ControlSignals_wire;



/****************************** STAGE EX/MEM *****************************************************/

wire [4:0] exMem_RegDestAddress_wire;
wire [31:0]exMem_WriteDataRam_wire;
wire [31:0]exMem_AluResult_wire;
wire [31:0]exMem_Instruction_wire;
wire [31:0]exMem_PC_wire;
wire [4:0] exMem_ControlSignals_wire;


/****************************** STAGE MEM/WB *****************************************************/
wire	[4:0] memWB_RegDestAddress_wire;
wire	[31:0]memWB_ReadDataRam_wire;
wire	[31:0]memWB_AluResult_wire;
wire	[31:0]memWB_Instruction_wire;
wire	[31:0]memWB_PC_wire;
wire  [2:0] memWB_ControlSignals_wire;

/*MUX Output for WriteRegisterData*/
wire [31:0] muxWriteRegDataOutput_wire;

/*MUX Output for Forwarding Unit Read Data 1*/
wire [31:0] muxForwardingUnit_Data1Output_wire;

/*MUX Output for Forwarding Unit Read Data 2*/
wire [31:0] muxForwardingUnit_Data2Output_wire;

/*MUX Outputs for Forwarding Unit*/
wire [1:0] muxForwardA_Output;
wire [1:0] muxForwardB_Output;

/*Output for Equal*/
wire equal_wire;

/*Output for AndForBeq*/
wire andForBeq_wire;

/*Output for AndForBne*/
wire andForBne_wire;

/*Output for ORForBranches*/
wire orForBranches_wire;

/*Output for the Immediate Extend shifted two times to the left to calculate Branch Address*/
wire [31:0] shiftLeft2ImmExtend_wire;

/*Output for AdderBranchAddress*/
wire [31:0] adderBranchAddress_wire;

/*MUX Output for Branch Instruction*/
wire [31:0] muxBranchInstruction_wire;

/*Jump Address*/
wire [31:0] JumpAddress_wire;

/*MUX Output for Jump Instruction*/
wire [31:0] muxJumpInstruction_wire;

/*MUX Output for Jr Instruction*/
wire [31:0] muxJrInstruction_wire;

/*Hazard Detection Unit outputs*/
wire stall_wire;
wire flush_wire;
wire PCWrite_wire;
wire ifIdWrite_wire;

/*MUX Output for Jal Instruction*/
wire [31:0] muxJalInstruction_wire;

/*MUX Output for Jal Write in $ra*/
wire [4:0]  muxWriteInRaInstruction_wire;
	
//******************************************************************/
//**********  MODULES AND REGISTERS OF THE PROCESSOR    ************/
//******************************************************************/

/*Added two more signals, jal and jump. This signals will help us differentiate when the instruction is 
jump or jal. We also finished the implementation for the instruction of branches.*/
Control
ControlUnit
(
	/* ---------------------- INPUTS ----------------------*/
	.OP(ifId_InstructionWire[31:26]),
	.Funct(ifId_InstructionWire[5:0]),

	/* ---------------------- OUTPUTS ----------------------*/
	.ControlSignals(ControlSignals_wire)
);

/*AND Gate to verify if there is a BEQ Instruction*/
ANDGate
AndForBeq
(
	/* ---------------------- INPUTS ----------------------*/
	.A(ControlSignals_wire[4]),
	.B(equal_wire),
	
	/* ---------------------- OUTPUTS ----------------------*/
	.C(andForBeq_wire)
);

/*AND Gate to verify if there is a BNE Instruction*/
ANDGate
AndForBne
(
	/* ---------------------- INPUTS ----------------------*/
	.A(ControlSignals_wire[5]),
	.B(~equal_wire),
	
	/* ---------------------- OUTPUTS ----------------------*/
	.C(andForBne_wire)
);

/*OR Gate where we let a branch instruction pass*/
ORGate
ORForBranches
(
	/* ---------------------- INPUTS ----------------------*/
	.A(andForBeq_wire),
	.B(andForBne_wire),
	
	/* ---------------------- OUTPUTS ----------------------*/
	.C(orForBranches_wire)
);



//The new PC value will be the result of the multiplexor that verifies if the instruction is jr or not.
PC_Register
ProgramCounter
(
	/* ---------------------- INPUTS ----------------------*/
	.clk(clk),
	.reset(reset),
	.NewPC(muxJrInstruction_wire),
	.PC_Write(PCWrite_wire),
	
	/* ---------------------- OUTPUTS ----------------------*/	
	.PCValue(PC_wire)
);

/*Added another instance of Adder32b for the mapping of our PC (see inside the instance for a more
detailed explanation*/

Adder32bits
Mapping_PC
(
	/* ---------------------- INPUTS ----------------------*/
	.Data0(PC_wire),
	.Data1(-32'h00400000),
	
	/* ---------------------- OUTPUT ----------------------*/	
	.Result(realPC_wire)
);


ProgramMemory
#(
	.MEMORY_DEPTH(MEMORY_DEPTH)
)
ROMProgramMemory
(
	/* ---------------------- INPUT ----------------------*/
	.Address(realPC_wire),
	
	/* ---------------------- OUTPUT ----------------------*/
	.Instruction(Instruction_wire)
);

Adder32bits
PC_Puls_4
(
	/* ---------------------- INPUTS ----------------------*/
	.Data0(PC_wire),
	.Data1(4),

	/* ---------------------- OUTPUTS ----------------------*/	
	.Result(PC_4_wire)
);


//******************************************************************/
//******************  REGISTER IF/ID   *****************************/
//******************************************************************/
Register_IF_ID
Register_PL_IF_ID
(
	/* ---------------------- INPUTS ----------------------*/
	.clk(clk),
	.reset(reset),
	.Instruction(Instruction_wire),
	.PC(PC_4_wire),
	.Flush(flush_wire),
	.ifId_Write(ifIdWrite_wire),
	
	/* ---------------------- OUTPUTS ----------------------*/
	.Instruction_out(ifId_InstructionWire), 
	.PC_out(ifId_PCwire)
);

SignExtend
SignExtendForConstants
(   
	/* ---------------------- INPUT ----------------------*/
	.DataInput(ifId_InstructionWire[15:0]),
	
	/* ---------------------- OUTPUT ----------------------*/
   .SignExtendOutput(InmmediateExtend_wire)
);


/*ShiftLeft2 for Immediate Extend*/
ShiftLeft2
ShiftLeft2_ImmExtend
(
	/* ---------------------- INPUT ----------------------*/
	.DataInput(InmmediateExtend_wire),
	
	/* ---------------------- OUTPUT ----------------------*/
	.DataOutput(shiftLeft2ImmExtend_wire)
);

/*Branch Address Calculator*/
Adder32bits
AdderBranchAddress
(
	/* ---------------------- INPUTS ----------------------*/
	.Data0(ifId_PCwire),
	.Data1(shiftLeft2ImmExtend_wire),
	
	/* ---------------------- OUTPUTS ----------------------*/
	.Result(adderBranchAddress_wire)

);

/*MUX for Branch Instruction*/
Multiplexer2to1
#(
	.NBits(32)
)
Mux_BranchInstruction
(
	/* ---------------------- INPUTS ----------------------*/
	.Selector(orForBranches_wire),
	.MUX_Data0(PC_4_wire),
	.MUX_Data1(adderBranchAddress_wire),
	
	/* ---------------------- OUTPUT ----------------------*/
	.MUX_Output(muxBranchInstruction_wire)
);

JumpAddressDecoder
JumpAddressForMux
(
	/* ---------------------- INPUTS ----------------------*/
	.Address(ifId_InstructionWire[25:0]),
	.PC_4(ifId_PCwire),
	
	/* ---------------------- OUTPUT ----------------------*/	
   .JumpAddress(JumpAddress_wire)
);

/*MUX for Jump Instruction*/
Multiplexer2to1
#(
	.NBits(32)
)
Mux_JumpInstruction
(
	/* ---------------------- INPUTS ----------------------*/
	.Selector(ControlSignals_wire[12]),
	.MUX_Data0(muxBranchInstruction_wire),
	.MUX_Data1(JumpAddress_wire),
	
	/* ---------------------- OUTPUT ----------------------*/
	.MUX_Output(muxJumpInstruction_wire)
);

/*MUX for Jr Instruction*/
Multiplexer2to1
#(
	.NBits(32)
)
Mux_JrInstruction
(
	/* ---------------------- INPUTS ----------------------*/
	.Selector(ControlSignals_wire[14]),
	.MUX_Data0(muxJumpInstruction_wire),
	.MUX_Data1(ReadData1_wire),
	
	/* ---------------------- OUTPUT ----------------------*/
	.MUX_Output(muxJrInstruction_wire)
);

//******************************************************************/
//********************  HAZARD DETECTION UNIT   ********************/
//******************************************************************/
HazardDetectionUnit
HazardDetection_Unit
(
	/* ---------------------- INPUTS ----------------------*/
	.idEx_RegDstAddress1(idEx_RegDstAdd1), //rt
	.idEx_MemRead(idEx_ControlSignals_wire[5]),
	.ifId_RegOperandRS(ifId_InstructionWire[25:21]),
	.ifId_RegRt(ifId_InstructionWire[20:16]),
	.ifId_Jr(ControlSignals_wire[14]),
	.ifId_Jump(ControlSignals_wire[12]),
	.Branch(orForBranches_wire),
	
	
	/* ---------------------- OUTPUTS ----------------------*/
	.Stall(stall_wire),
	.Flush(flush_wire),
	.PC_Write(PCWrite_wire),
	.ifId_Write(ifIdWrite_wire)
);

//******************************************************************/
//********************  REGISTER FILE   ****************************/
//******************************************************************/
RegisterFile
Register_File
(
	/* ---------------------- INPUTS ----------------------*/
	.clk(clk),
	.reset(reset),
	.RegWrite(memWB_ControlSignals_wire[0]),
	.WriteRegister(muxWriteInRaInstruction_wire),
	.ReadRegister1(ifId_InstructionWire[25:21]),
	.ReadRegister2(ifId_InstructionWire[20:16]),
	.WriteData(muxJalInstruction_wire),
	
	/* ---------------------- OUTPUTS ----------------------*/
	.ReadData1(ReadData1_wire),
	.ReadData2(ReadData2_wire)

);

//********************************************************************/
//******************  Equal ******************************************/
//********************************************************************/

Equal
#(
	.N(32)
)
Compare_Rd1_Rd2
(
	/* ---------------------- INPUTS ----------------------*/
	.ReadData1(ReadData1_wire),
	.ReadData2(ReadData2_wire),
	
	/* ---------------------- OUTPUT ----------------------*/
	.Equal(equal_wire)
);

wire [10:0] theRealFinalCalculatorControlSignals;

Multiplexer2to1
#(
	.NBits(11)
)
Mux_ControlSignals
(
	/* ---------------------- INPUTS ----------------------*/
	.Selector(stall_wire),
	.MUX_Data0({ ControlSignals_wire[13],		 	   /*Jal*/
				    ControlSignals_wire[11],			/*RegDst*/
			    	 ControlSignals_wire[10],			/*ALUSrc*/
					 ControlSignals_wire[9],			/*MemtoReg*/
					 ControlSignals_wire[8],			/*RegWrite*/
					 ControlSignals_wire[7],			/*MemRead*/
					 ControlSignals_wire[6],			/*MemWrite*/
				    ControlSignals_wire[3:0] }),
	
	.MUX_Data1(11'b00000000000),
	
	/* ---------------------- OUTPUT ----------------------*/
	.MUX_Output(theRealFinalCalculatorControlSignals)
);


//******************************************************************/
//******************  REGISTER ID/EX   *****************************/
//******************************************************************/

// Jr  = ControlValues[14]
// Jal = ControlValues[13];
// Jump = ControlValues[12];
// RegDst = ControlValues[11];
// ALUSrc = ControlValues[10];
// MemtoReg = ControlValues[9];
// RegWrite = ControlValues[8];
// MemRead = ControlValues[7];
// MemWrite = ControlValues[6];
// BranchNE = ControlValues[5];
// BranchEQ = ControlValues[4];
// ALUOp = ControlValues[3:0];

Register_ID_EX
Register_PL_ID_EX
(
	/* ---------------------- INPUTS ----------------------*/
	.clk(clk),
	.reset(reset),
	.RegDestAddress1(ifId_InstructionWire[20:16]),
	.RegDestAddress2(ifId_InstructionWire[15:11]),
	.RegOperandRS(ifId_InstructionWire[25:21]),
	.Immediate(InmmediateExtend_wire),
	.ReadData1(ReadData1_wire),
	.ReadData2(ReadData2_wire),
	.Instruction(ifId_InstructionWire),
	.PC(ifId_PCwire),
	.ControlSignals(theRealFinalCalculatorControlSignals),
	
	
	/* ---------------------- OUTPUTS ----------------------*/
	.RegDestAddress1_out(idEx_RegDstAdd1),
	.RegDestAddress2_out(idEx_RegDstAdd2),
	.RegOperandRS_out(idEx_RegOperandRS),
	.Immediate_out(idEx_ImmediateExtend),
	.ReadData1_out(idEx_RdData1),
	.ReadData2_out(idEx_RdData2),
	.Instruction_out(idEx_Instructionwire),
	.PC_out(idEx_PCwire),
	.ControlSignals_out(idEx_ControlSignals_wire)

);

//******************************************************************/
//******************************************************************/
//******************************************************************/

wire [31:0] muxRegOrImmediateOutput_wire;

/*MUX for instruction R-I*/
Multiplexer2to1
#(
	.NBits(32)
)
MuxForInstructionTypeRI
(
	/* ---------------------- INPUTS ----------------------*/
	.Selector(idEx_ControlSignals_wire[8]),	//ALUSrc
   .MUX_Data0(muxForwardingUnit_Data2Output_wire),
	.MUX_Data1(idEx_ImmediateExtend),
	
	/* ---------------------- OUTPUT ----------------------*/
	.MUX_Output(muxRegOrImmediateOutput_wire)

);

/*MUX for Forwarding Unit Read Data 1*/
Multiplexer3to2
#(
	.NBits(32)
)
Mux_ForwardingUnit_ReadData1
(
	/* ---------------------- INPUTS ----------------------*/
	.Selector(muxForwardA_Output),
	.MUX_Data0(idEx_RdData1),
	.MUX_Data1(muxWriteRegDataOutput_wire),
	.MUX_Data2(exMem_AluResult_wire),
	
	/* ---------------------- OUTPUT ----------------------*/
	.MUX_Output(muxForwardingUnit_Data1Output_wire)
);

/*MUX for Forwarding Unit Read Data 2*/
Multiplexer3to2
#(
	.NBits(32)
)
Mux_ForwardingUnit_ReadData2
(
	/* ---------------------- INPUTS ----------------------*/
	.Selector(muxForwardB_Output),
	.MUX_Data0(idEx_RdData2),
	.MUX_Data1(muxWriteRegDataOutput_wire),
	.MUX_Data2(exMem_AluResult_wire),
	
	/* ---------------------- OUTPUT ----------------------*/
	.MUX_Output(muxForwardingUnit_Data2Output_wire)
);

//********************************************************************/
//******************  ALU CONTROL ************************************/
//********************************************************************/
ALUControl
ArithmeticLogicUnitControl
(
	/* ---------------------- INPUTS ----------------------*/
	.ALUOp(idEx_ControlSignals_wire[3:0]),		
	.ALUFunction(idEx_ImmediateExtend[5:0]),
	
	/* ---------------------- OUTPUT ----------------------*/	
	.ALUOperation(ALUOperation_wire),
	.Jr_Instruction()

);


wire [4:0] muxRegDestAddressOutput_wire;

/*MUX for RegDest*/
Multiplexer2to1
#(
	.NBits(5)
)
MuxForRegDest
(
	/* ---------------------- INPUTS ----------------------*/
	.Selector(idEx_ControlSignals_wire[9]),	//RegDest
   .MUX_Data0(idEx_RegDstAdd1),
	.MUX_Data1(idEx_RegDstAdd2),
	
	/* ---------------------- OUTPUT ----------------------*/
	.MUX_Output(muxRegDestAddressOutput_wire)

);

//************************************************************************/
//******************  ARITHMETIC LOGIC UNIT  *****************************/
//************************************************************************/
ALU
Arithmetic_Logic_Unit 
(
	/* ---------------------- INPUTS ----------------------*/
	.ALUOperation(ALUOperation_wire),
	.A(muxForwardingUnit_Data1Output_wire),
	.B(muxRegOrImmediateOutput_wire),
	.shamt(idEx_ImmediateExtend[10:6]),
	
	/* ---------------------- OUTPUTS ----------------------*/	
	.ALUResult(ALUResult_wire)
);

assign ALUResultOut = ALUResult_wire;

//******************************************************************/
//******************  FORWARDING UNIT  *****************************/
//******************************************************************/
ForwardingUnit 
Forwarding_Unit
(
	/* ---------------------- INPUTS ----------------------*/
	.idEx_RegDstAddress1(idEx_RegDstAdd1),
	.idEx_RegOperandRS(idEx_RegOperandRS),
	.exMem_RegisterRd(exMem_RegDestAddress_wire),
	.exMem_RegWrite(exMem_ControlSignals_wire[2]),
	.memWB_RegisterRd(memWB_RegDestAddress_wire),
	.memWB_RegWrite(memWB_ControlSignals_wire[0]),	
	
	/* ---------------------- OUTPUTS ----------------------*/
	.forwardA(muxForwardA_Output),
	.forwardB(muxForwardB_Output)
);

//******************************************************************/
//******************  REGISTER EX/MEM  *****************************/
//******************************************************************/

Register_EX_MEM
Register_PL_EX_MEM
(
	/* ---------------------- INPUTS ----------------------*/
	.clk(clk),
	.reset(reset),
	.RegDestAddress(muxRegDestAddressOutput_wire),
	.WriteDataRam(muxForwardingUnit_Data2Output_wire),
	.AluResult(ALUResult_wire),
	.Instruction(idEx_Instructionwire),
	.PC(idEx_PCwire),
//	
//	ControlSignals_wire[13],		/*Jal*/
//						  ControlSignals_wire[11],			/*RegDst*/
//						  ControlSignals_wire[10]			/*ALUSrc*/
//						  ControlSignals_wire[9],			/*MemtoReg*/
//						  ControlSignals_wire[8],			/*RegWrite*/
//						  ControlSignals_wire[7],			/*MemRead*/
//						  ControlSignals_wire[6],			/*MemWrite*/
//						  ControlSignals_wire[3:0] }),	/*ALUOp*/     
	
	
	.ControlSignals({idEx_ControlSignals_wire[10],		   /*Jal*/
						  idEx_ControlSignals_wire[7],			/*MemtoReg*/
						  idEx_ControlSignals_wire[6],			/*RegWrite*/
						  idEx_ControlSignals_wire[5],			/*MemRead*/
						  idEx_ControlSignals_wire[4]}),			/*MemWrite*/
	
	/* ---------------------- OUTPUTS ----------------------*/
	.RegDestAddress_out(exMem_RegDestAddress_wire),
	.WriteDataRam_out(exMem_WriteDataRam_wire),
	.AluResult_out(exMem_AluResult_wire),
	.Instruction_out(exMem_Instruction_wire),
	.PC_out(exMem_PC_wire),
	.ControlSignals_out(exMem_ControlSignals_wire)
);

//******************************************************************/
//******************************************************************/
//******************************************************************/



DataMemory 
RAMDataMemory
(
	/* ---------------------- INPUTS ----------------------*/
	.WriteData(exMem_WriteDataRam_wire), 	
	.Address(exMem_AluResult_wire), 	
	.MemWrite(exMem_ControlSignals_wire[0]), 	
	.MemRead(exMem_ControlSignals_wire[1]),		
	.clk(clk),		
	
	/* ---------------------- OUTPUT ----------------------*/
	.ReadData(dataReadRam_wire) 	
);



//******************************************************************/
//******************  REGISTER MEM/WB  *****************************/
//******************************************************************/

Register_MEM_WB
Register_PL_MEM_WB
(
	/* ---------------------- INPUTS ----------------------*/
	.clk(clk),
	.reset(reset),
	
	.RegDestAddress(exMem_RegDestAddress_wire),
	.ReadDataRam(dataReadRam_wire),
	.AluResult(exMem_AluResult_wire),
	.Instruction(exMem_Instruction_wire),
	.PC(exMem_PC_wire),
	
//	.ControlSignals({idEx_ControlSignals_wire[9],		   /*Jal*/
//						  idEx_ControlSignals_wire[7],			/*MemtoReg*/
//						  idEx_ControlSignals_wire[6],			/*RegWrite*/
//						  idEx_ControlSignals_wire[5],			/*MemRead*/
//						  idEx_ControlSignals_wire[4]}),			/*MemWrite*/
	
	.ControlSignals({exMem_ControlSignals_wire[4],		   /*Jal*/
						  exMem_ControlSignals_wire[3],			/*MemtoReg*/
						  exMem_ControlSignals_wire[2]}),		/*RegWrite*/
	
	
	/* ---------------------- OUTPUTS ----------------------*/
	.RegDestAddress_out(memWB_RegDestAddress_wire),
	.ReadDataRam_out(memWB_ReadDataRam_wire),
	.AluResult_out(memWB_AluResult_wire),
	.Instruction_out(memWB_Instruction_wire),
	.PC_out(memWB_PC_wire),
	.ControlSignals_out(memWB_ControlSignals_wire)
	
);

/*MUX for Jal write in $ra*/
Multiplexer2to1
#(
	.NBits(5)
)
MuxForWriteInRa
(
	/* ---------------------- INPUTS ----------------------*/
	.Selector(memWB_ControlSignals_wire[2]),	//Jal
   .MUX_Data0(memWB_RegDestAddress_wire),
	.MUX_Data1(5'b11111),
	
	/* ---------------------- OUTPUT ----------------------*/
	.MUX_Output(muxWriteInRaInstruction_wire)

);

/*MUX for WriteRegisterData*/
Multiplexer2to1
#(
	.NBits(32)
)
MuxForWriteRegisterData
(
	/* ---------------------- INPUTS ----------------------*/
	.Selector(memWB_ControlSignals_wire[1]),	//MemtoReg
   .MUX_Data0(memWB_AluResult_wire),
	.MUX_Data1(memWB_ReadDataRam_wire),
	
	/* ---------------------- OUTPUT ----------------------*/
	.MUX_Output(muxWriteRegDataOutput_wire)

);

/*MUX After WriteRegisterData for JAL*/
Multiplexer2to1
#(
	.NBits(32)
)
MuxForJal
(
	/* ---------------------- INPUTS ----------------------*/
	.Selector(memWB_ControlSignals_wire[2]),	//Jal
   .MUX_Data0(muxWriteRegDataOutput_wire),
	.MUX_Data1(memWB_PC_wire),
	
	/* ---------------------- OUTPUT ----------------------*/
	.MUX_Output(muxJalInstruction_wire)

);

//******************************************************************/
//******************************************************************/
//******************************************************************/


endmodule

