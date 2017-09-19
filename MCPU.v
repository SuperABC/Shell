`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:50:53 05/14/2017 
// Design Name: 
// Module Name:    MCPU 
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
module MCPU(input wire clk,
			input wire reset,
			input wire INT,
			input wire MIO_ready,// be used：=1
			output wire[31:0]PC_out,//Test
			output[31:0] inst_out,//TEST
			output wire mem_w,//存储器读写控制
			output wire[31:0]Addr_out,//数据空间访问地址
			output wire[31:0]Data_out,//数据输出总线
			input wire [31:0]Data_in,//数据输入总线
			output wire CPU_MIO,// Be used input wire INT//中断
			output[4:0]state//Test
			);
	wire zero,overflow,MemRead,MemWrite,IorD,IRWrite,RegWrite,PCWrite,PCWriteCond,Branch;
	wire [1:0] RegDst, MemtoReg, ALUSrcA, ALUSrcB, PCSource;
	wire [2:0] ALU_operation;
	MCtrl Cotroller(.clk(clk), .reset(reset), .zero(zero),
	                 .overflow(overflow), .MIO_ready(MIO_ready), .Inst_in(inst_out[31:0]),
					 .MemRead(MemRead), .MemWrite(MemWrite), .CPU_MIO(CPU_MIO),
					 .IorD(IorD), .IRWrite(IRWrite), .RegWrite(RegWrite),
					 .ALUSrcA(ALUSrcA[1:0]), .PCWrite(PCWrite), .PCWriteCond(PCWriteCond), .Branch(Branch),
					 .RegDst(RegDst[1:0]), .MemtoReg(MemtoReg[1:0]), .ALUSrcB(ALUSrcB[1:0]),
					 .PCSource(PCSource[1:0]), .ALU_operation(ALU_operation[2:0]), .state_out(state[4:0]));
					 
	MDPath DataPath(.clk(clk), .reset(reset), .MIO_ready(MIO_ready),
	                .IorD(IorD), .IRWrite(IRWrite), .RegWrite(RegWrite),
					.ALUSrcA(ALUSrcA[1:0]), .PCWrite(PCWrite), .PCWriteCond(PCWriteCond), .Branch(Branch),
					.RegDst(RegDst[1:0]), .MemtoReg(MemtoReg[1:0]), .ALUSrcB(ALUSrcB[1:0]),
					.PCSource(PCSource[1:0]), .ALU_operation(ALU_operation[2:0]), .data2CPU(Data_in[31:0]),
					.zero(zero), .overflow(overflow), .PC_Current(PC_out[31:0]), 
					.Inst(inst_out[31:0]), .data_out(Data_out[31:0]), .M_addr(Addr_out[31:0]));
					
	assign mem_w = (~MemRead)&(MemWrite);			
endmodule
