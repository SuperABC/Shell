`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:21:14 09/03/2017 
// Design Name: 
// Module Name:    clkchg 
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
module clkchg(
    input N,
    input P,
    output reg out100,
	 output reg out50,
	 output reg out25
    );
	 
	wire clk200mhz;
	 
	clk_diff cd(.clk200P(P), .clk200N(N), .clk200MHz(clk200mhz));
	
	always@(posedge clk200mhz)begin
		out100 = ~out100;
	end

	always@(posedge out100)begin
		out50 = ~out50;
	end
	
	always@(posedge out50)begin
		out25 = ~out25;
	end

endmodule
