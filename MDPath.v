`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:50:05 05/15/2017 
// Design Name: 
// Module Name:    MDPath 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module MDPath(input clk,
			  input reset,
			  input MIO_ready,		//=1
			  input IorD,
			  input IRWrite,
			  input[1:0] RegDst,
			  input RegWrite,
			  input[1:0]MemtoReg,
			  input[1:0] ALUSrcA,
			  input[1:0]ALUSrcB,
			  input[1:0]PCSource,
			  input PCWrite,
			  input PCWriteCond,	
			  input Branch,
			  input[2:0]ALU_operation,
			  input[31:0]data2CPU,
			  output[31:0]PC_Current,
			  output[31:0]Inst,
			  output[31:0]data_out,
			  output[31:0]M_addr,
			  output zero,
			  output overflow
			  );
	wire [31:0] MDR, Wt_data, rdata_A, A, B, res, PC_in, Imm_32, ALU_Out;
	wire [4:0] Wt_addr;
	wire PC_CE;
	assign PC_CE=MIO_ready&&(PCWrite||(PCWriteCond&&(~(Branch^zero))));
	REG32 IR(.clk(clk), .rst(reset), .CE(IRWrite), .D(data2CPU[31:0]), .Q(Inst[31:0]));
	REG32 mdr(.clk(clk), .rst(1'b0), .CE(1'b1), .D(data2CPU[31:0]), .Q(MDR[31:0]));
	REG32 ALUOut(.clk(clk), .rst(1'b0), .CE(1'b1), .D(res[31:0]), .Q(ALU_Out[31:0]));
	REG32 PC(.clk(clk), .rst(reset), .CE(PC_CE), .D(PC_in[31:0]), .Q(PC_Current[31:0]));
	
	alu U1(.ALU_operation(ALU_operation[2:0]), .A(A[31:0]), .B(B[31:0]), .zero(zero), .res(res[31:0]), .overflow(overflow));
	Regs U2(.clk(clk), .L_S(RegWrite), .rst(reset), .R_addr_A(Inst[25:21]), .R_addr_B(Inst[20:16]),
            .Wt_addr(Wt_addr[4:0]), .Wt_data(Wt_data[31:0]), .rdata_A(rdata_A[31:0]), .rdata_B(data_out[31:0]));
			
	MUX4T1_5 M1(.s(RegDst[1:0]), .I0(Inst[20:16]), .I1(Inst[15:11]), .I2(5'd31), .I3(), .o(Wt_addr[4:0]));
	MUX4T1_32 M2(.s(MemtoReg[1:0]), .I0(ALU_Out[31:0]), .I1(MDR[31:0]), .I2({Inst[15:0],16'd0}), .I3(PC_Current[31:0]), .o(Wt_data[31:0]));
	MUX4T1_32 M3(.s(ALUSrcA[1:0]), .I0(PC_Current[31:0]), .I1(rdata_A[31:0]), .I2(data_out[31:0]), .I3(), .o(A[31:0]));
	MUX4T1_32 M4(.s(ALUSrcB[1:0]), .I0(data_out[31:0]), .I1(32'd4), .I2(Imm_32[31:0]), .I3({Imm_32[29:0],2'b00}), .o(B[31:0]));
	MUX4T1_32 M5(.s(PCSource[1:0]), .I0(res[31:0]), .I1(ALU_Out[31:0]), .I2({PC_Current[31:28],Inst[25:0],2'b00}), .I3(ALU_Out[31:0]), .o(PC_in[31:0]));
	MUX2T1_32 M6(.s(IorD), .I0(PC_Current[31:0]), .I1(ALU_Out[31:0]), .o(M_addr[31:0]));

	Ext_32 Ext_32(.imm_16(Inst[15:0]), .Imm_32(Imm_32[31:0]));

endmodule
