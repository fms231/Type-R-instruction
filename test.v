`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:10:19 05/15/2022
// Design Name:   top_R
// Module Name:   D:/zuchengyuanli/r/test.v
// Project Name:  r
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top_R
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test;

	// Inputs
	reg rst;
	reg clk;

	// Outputs
	wire zf;
	wire of;
	wire [31:0] F;

	// Instantiate the Unit Under Test (UUT)
	top_R uut (
		.rst(rst), 
		.clk(clk), 
		.zf(zf), 
		.of(of), 
		.F(F)
	);

	initial begin
		// Initialize Inputs
		rst = 0;
		clk = 0;

		// Wait 100 ns for global reset to finish
		forever
		begin
		 #50
		 clk=~clk;
		end
	end
      
endmodule

