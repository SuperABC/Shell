`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:13:28 07/01/2012 
// Design Name: 
// Module Name:    Counter_8253 
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
module Counter (input clk,
				input rst,
				input clk0,
				input counter_we,
				input [31:0] counter_val,

				output counter0_OUT,
				output [31:0] counter_out);
	reg [32:0] counter0;
	reg [31:0] counter0_Lock;

	reg M0,clr0;

	//Counter read or write & set		counter_ch=SC1 SC0; counter_Ctrl=XX M2 M1 M0 X
		
	always @ (posedge clk or posedge rst) begin 
		if (rst )
			counter0_Lock <=0;
		else if (counter_we) begin
			counter0_Lock <= counter_val;  
			M0<=1; 
		end	
		else begin 
			counter0_Lock <=counter0_Lock;
			if(clr0) M0<=0;
		end
	end

	// Counter channel 0			
	always @ (posedge clk0 or posedge rst) begin 
		if (rst) counter0<=0; 
		else begin 
			if (M0) begin
				counter0 <= {1'b0,counter0_Lock}; 
				clr0<=1; 
			end 
			else if (counter0[32]==0) begin 
				counter0 <= counter0 - 1'b1; 
				clr0<=0;
			end	
		end
	end
	
	assign counter0_OUT=counter0[32];
	assign counter_out =counter0[31:0];

endmodule
