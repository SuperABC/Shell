`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:23:26 05/16/2017 
// Design Name: 
// Module Name:    MCtrl 
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
module   MCtrl(input  clk,
			   input  reset,
			   input  [31:0] Inst_in,
		       input  zero,
			   input  overflow,
			   input  MIO_ready,
			   output reg [4:0]state_out,
			   output reg MemRead,
			   output reg MemWrite,
			   output reg[2:0]ALU_operation,
			   output reg CPU_MIO,
			   output reg IorD,
			   output reg IRWrite,
			   output reg [1:0]RegDst,
			   output reg RegWrite,
			   output reg [1:0]MemtoReg,
			   output reg [1:0]ALUSrcA,
			   output reg [1:0]ALUSrcB,
			   output reg [1:0]PCSource,
		       output reg PCWrite,
			   output reg PCWriteCond,
			   output reg Branch);
	wire [5:0] OP, FUN;
	
	assign OP=Inst_in[31:26];
	assign FUN=Inst_in[5:0];
	`define signals {MemRead,MemWrite,IorD,IRWrite,RegDst,RegWrite,MemtoReg,ALUSrcA,ALUSrcB,PCSource,PCWrite,PCWriteCond,Branch,ALU_operation,CPU_MIO}
	parameter IF = 5'b00000,
              ID = 5'b00001, 
			  EXC_MEM = 5'b00010, 
			  EXC_R = 5'b00011,
			  EXC_I = 5'b00100,
			  EXC_LUI = 5'b00101,
			  EXC_BEQ=5'b00110,
			  EXC_BNE=5'b00111,
			  EXC_J=5'b001000,
			  EXC_JAL=5'b01001,
			  EXC_JR=5'b01010,
			  EXC_JALR=5'b01011,
			  MEM_RD=5'b01100,
			  MEM_WD=5'b01101,
			  WB_LW=5'b01110,
			  WB_R=5'b01111,
			  WB_I=5'b10000,
			  ERROR=5'b11111; 	
	always@(posedge clk or posedge reset) begin
		if(reset) state_out<=IF;
		else begin
			case(state_out)
			IF:	begin
					if(MIO_ready)state_out<=ID;
					else state_out<=IF;
				end
			ID: begin
					case(OP)
					6'h00:begin 
							case(FUN)
							6'h9:state_out<=EXC_JALR;//jalr
							6'h8:state_out<=EXC_JR;//jr
							default:state_out<=EXC_R;	
							endcase
						end
					6'h23:state_out<=EXC_MEM;//lw
					6'h2B:state_out<=EXC_MEM;//sw
					6'h8:state_out<=EXC_I;//addi
					6'hC:state_out<=EXC_I;//andi
					6'hD:state_out<=EXC_I;//ori
					6'hE:state_out<=EXC_I;//xori
					6'hF:state_out<=EXC_LUI;//lui
					6'hA:state_out<=EXC_I;//slti
					6'h4:state_out<=EXC_BEQ;//beq
					6'h5:state_out<=EXC_BNE;//bne
					6'h2:state_out<=EXC_J;//j
					6'h3:state_out<=EXC_JAL;//jal
					default:state_out<=ERROR;
					endcase
				end
			EXC_MEM:begin
						case(Inst_in[31:26])
						6'h23:state_out<=MEM_RD;//lw
						6'h2B:state_out<=MEM_WD;//sw
						default:state_out<=ERROR;
						endcase
					end
			EXC_R:	state_out<=WB_R;
			EXC_I:	state_out<=WB_I;
			EXC_LUI:state_out<=IF;
			EXC_BEQ:state_out<=IF;
			EXC_BNE:state_out<=IF;
			EXC_J:	state_out<=IF;
			EXC_JAL:state_out<=IF;
			EXC_JR:	state_out<=IF;
			EXC_JALR:state_out<=IF;
			MEM_RD:	state_out<=WB_LW;
			MEM_WD:	state_out<=IF;
			WB_LW:	state_out<=IF;
			WB_R:	state_out<=IF;
			WB_I:	state_out<=IF;
			ERROR:	state_out<=ERROR;
			default:state_out<=ERROR;
			endcase
		end
	end
	always @* begin
		case(state_out)
		IF:	`signals<=22'b10_0100_0000_0010_0100_0101;
		ID:	`signals<=22'b00_0000_0000_0110_0000_0100;
		EXC_MEM:`signals<=22'b00_0000_0000_1100_0000_0100;
		EXC_R:begin
				case(FUN)
				6'h20:`signals<=22'b00_0000_0000_1000_0000_0100;//add
				6'h22:`signals<=22'b00_0000_0000_1000_0000_1100;//sub
				6'h2A:`signals<=22'b00_0000_0000_1000_0000_1110;//slt
				6'h24:`signals<=22'b00_0000_0000_1000_0000_0000;//and
				6'h25:`signals<=22'b00_0000_0000_1000_0000_0010;//or
				6'h26:`signals<=22'b00_0000_0000_1000_0000_0110;//xor
				6'h27:`signals<=22'b00_0000_0000_1000_0000_1000;//nor
				6'h2:`signals<=22'b00_0000_0001_0100_0000_1010;//srl
				default:`signals<=22'b00_0000_0000_1000_0000_xxx0;
				endcase
			end
		EXC_I:begin 
				case(OP)
				6'h8:`signals<=22'b00_0000_0000_1100_0000_0100;//addi
				6'hC:`signals<=22'b00_0000_0000_1100_0000_0000;//andi
				6'hD:`signals<=22'b00_0000_0000_1100_0000_0010;//ori
				6'hE:`signals<=22'b00_0000_0000_1100_0000_0110;//xori
				6'hA:`signals<=22'b00_0000_0000_1100_0000_1110;//slti
				endcase
			end
		EXC_LUI:`signals<=22'b00_0000_1100_1110_0000_0100;
		EXC_BEQ:`signals<=22'b00_0000_0000_1000_1011_1100;
		EXC_BNE:`signals<=22'b00_0000_0000_1000_1010_1100;
		EXC_J:	`signals<=22'b00_0000_0000_0111_0100_0100;
		EXC_JAL:`signals<=22'b00_0010_1110_0111_0100_0100;
		EXC_JR:	`signals<=22'b00_0000_0000_1000_0100_0100;
		EXC_JALR:`signals<=22'b00_0010_1110_1000_0100_0100;
		MEM_RD:	`signals<=22'b10_1000_0000_0000_0000_0101;
		MEM_WD:	`signals<=22'b01_1000_0000_0000_0000_0101;
		WB_LW:	`signals<=22'b00_0000_1010_0000_0000_0100;
		WB_R:	`signals<=22'b00_0001_1000_0000_0000_0100;
		WB_I:	`signals<=22'b00_0000_1000_1100_0000_0100;
		ERROR:	`signals<=22'b00_0000_0000_0000_0000_xxx0;
		default:`signals<=22'b00_0000_0000_0000_0000_xxx0;
		endcase
	end
endmodule
