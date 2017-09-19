`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:22:22 05/23/2017 
// Design Name: 
// Module Name:    MIO_BUS 
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
module MIO_BUS( input clk,
			    input rst,
			    input[3:0]BTN,
			    input[15:0]SW,
			    input mem_w,
			    input[31:0]Cpu_data2bus,				//data from CPU
			    input[31:0]addr_bus,
			    input[31:0]ram_data_out,
			    input[31:0]vram_out,
			    input[15:0]led_out,
			    input[31:0]counter_out,
			    input counter0_out,
			    input counter1_out,
			    input counter2_out,
			    input vga_rdn,
				 input [7:0]ps2_key,
			   
			    output reg[31:0]Cpu_data4bus,				//write to CPU
			    output reg[31:0]ram_data_in,				//from CPU write to Memory
			    output reg[11:0]vram_data_in,
			    output reg[9:0]ram_addr,						//Memory Address signals
			    output reg[12:0]cpu_vram_addr,
				 output reg vram_write,
			    output reg data_ram_we,
			    output reg GPIOf0000000_we,
			    output reg GPIOe0000000_we,
			    output reg counter_we,
			    output reg[31:0]Peripheral_in
			    );

	wire counter_over;
	reg ps2_ready;

	//RAM & IO decode signals:	
	always @* begin
		data_ram_we = 0;
		counter_we = 0;
		GPIOf0000000_we = 0;
		GPIOe0000000_we = 0;
		ram_addr = 10'h0;
		ram_data_in = 32'h0;
		Peripheral_in=32'h0;
		Cpu_data4bus = 32'h0;

		casex(addr_bus[31:8])
			24'h0000xx: begin 				// data_ram (00000000 - 0000ffff(00000ffc), actually lower 4KB RAM)
				vram_write = 1'b0;
				data_ram_we = mem_w;
				ram_addr=addr_bus[12:2];
				ram_data_in=Cpu_data2bus;
				Cpu_data4bus=ram_data_out;			
			end
			
			24'h000cxx: begin 				// Vram (000c0000 - c000ffff(000012c0), actually lower 4K?ив11bit VRAM)
				vram_write = mem_w ;
				cpu_vram_addr=addr_bus[12:0];
				vram_data_in=Cpu_data2bus[11:0];
				Cpu_data4bus=vga_rdn? {20'h0, vram_out[11:0]} :  32'hx ;			
			end		
			
			/*24'dxxxxx: begin
				vram_write=1'b0;
				cmdWe=mem_w;
				cmdAddr=addr_bus[7:0];
				cmdIn=Cpu_data2bus[7:0];
				Cpu_data4bus=cmdOut;
			end*/
			
			24'hffffdx: begin					//PS2 (ffffd000~ ffffdfff)
				vram_write = 1'b0;
				ps2_ready = ~mem_w;
				Cpu_data4bus = {ps2_ready,23'h0, ps2_key};				//read from PS2;
			end
			
			24'hexxxxx: begin  					// 7 Segement LEDs (fffffe00 - fffffeff, 4 7-seg display)
				vram_write = 1'b0;
				GPIOe0000000_we = mem_w;
				Peripheral_in = Cpu_data2bus;
				Cpu_data4bus =counter_out;					//read from Counter
			end
					
			24'hfxxxxx: begin 				  // LED   (ffffff00-ffffffff0,8 LEDs & counter, ffffff04-fffffff4)
				vram_write = 1'b0;
				if(addr_bus[2]) begin		  //f0000004  for addr of counter
					counter_we = mem_w;
					Peripheral_in = Cpu_data2bus;			//write Counter Value 
					Cpu_data4bus = counter_out;			//read from Counter;
				end 
				else begin							//f0000000
					GPIOf0000000_we = mem_w;
					Peripheral_in = Cpu_data2bus;	//write Counter set & Initialization and Button
					Cpu_data4bus = {counter0_out,counter1_out,counter2_out,17'b0,BTN[3:0],SW[7:0]};
					//Cpu_data4bus = {counter0_out,counter1_out,counter2_out,led_out[12:0], SW};
				end 
			end
		endcase
	end			// always end

endmodule
