`ifndef RTL_IF
`define RTL_IF
`timescale 1ns/1ps
interface rtl_if();
	
	logic clk;
	logic rst_n;

	logic SerDataIn;
	logic [8:0] PalDataOut;
	logic PalDataOutValid;


	logic [7:0] PalDataIn;
	logic PalDataInEn;
	logic PalDataInPermit;
	logic SerDataOut;


	localparam   CLK_PERIOD  = 82;    // 256000*16*3=12.288MHz=81.38ns
	localparam   BIT_PERIOD  = 3906;  // 256000bps = 3.906us (195 cycles)
	
  	always #(CLK_PERIOD/2) clk = ~clk;
	
	
  	initial begin
    	rst_n = 0;
	clk = 0;
    	//#100 rst_n = 1;
  	end

	task wait_baud_period();
		repeat(16*3) begin
			@(posedge vif.clk);
		end
	endtask

	task wait_baud_half_period();
		repeat(8*3) begin
			@(posedge vif.clk);
		end
	endtask

endinterface

`endif