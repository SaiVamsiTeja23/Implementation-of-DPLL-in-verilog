`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2025 00:36:21
// Design Name: 
// Module Name: tb_check_random_literal
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_check_random_literal();
localparam width=4;
localparam n = 16;
reg clk,rst,ena;
reg [n-1:0] literal_status;
wire [width-1:0]rand_val_out;
wire valid_out;


check_random_literal #(.WIDTH(width),.N(n)) inst2(
    .clk(clk),
	.rst(rst),
	.ena(ena),
	.lit_assigned(literal_status),
	.rand_val_out(rand_val_out),
	.valid_out(valid_out)
	
);

initial
begin
clk=0;rst=0;ena=0;
end
always #5 clk=~clk;

// test vectors

initial
begin
#3 rst = 1; literal_status = 16'b0110101010001111 ;
#5 rst = 0; ena = 1;
#10 ena = 0;
#20 ena = 1;
#10 ena = 0;
#30 ena =1;
#20 ena = 0;
#10 ena = 1;
#30 ena =0;
// TEST CASE-2
//#3 rst = 1; literal_status = 16'b0110101010001111 ;
//#5 rst = 0; ena = 1;
//#10 ena = 1;
//#40 ena = 0;
//#20 ena = 1;
//#10 ena =0;
//#20 ena = 1;
//#10 ena = 0;
//#20 ena =1;

// TEST CASE-3
//#3 rst = 1; literal_status = 16'b0110101010001111 ;
//#5 rst = 0; ena = 1;
//#10 ena = 1;
//#10 ena = 0;
//#10 ena = 1;
//#10 ena =0;
//#50 ena = 1;
//#10 ena = 0;
//#30 ena =1;

end

initial
#220 $finish;

endmodule
