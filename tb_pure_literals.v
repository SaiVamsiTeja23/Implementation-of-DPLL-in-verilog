`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.06.2025 23:16:44
// Design Name: 
// Module Name: tb_pure_literals
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


module tb_pure_literals();
localparam width = 4;
localparam outsize=16;
	reg reset,inputs_over,reduced_form,clk;
	reg [width:0] literal_in;
	wire valid_out;
	wire [outsize-1:0] pure_literal;

pure_literals #(.WIDTH(width),.OUT_SIZE(out_size)) inst(.reset(reset),
                                                           .clk(clk),
                                                           .inputs_over(inputs_over),
                                                           .literal_in_reduced_form(reduced_form),
                                                           .literal_in(literal_in),
                                                           .valid_out(valid_out),
                                                           .ff_pure_literals(pure_literal));
initial
begin
clk = 0;
reset = 0;
inputs_over=0;
end
always
    #5 clk = ~clk;
 initial
   begin
   #3 reset = 1;
   #5 reset = 0;
   #5 literal_in = -1 ; reduced_form = 1;   
   #5 literal_in =  2; reduced_form = 1;   
   #5 literal_in =  3; reduced_form = 1;   
   #5 literal_in =  2; reduced_form = 1;   
   #5 literal_in =  3; reduced_form = 1;   
   #5 literal_in =  4; reduced_form = 1;   
   #5 literal_in =  1; reduced_form = 1;   
   #5 literal_in =  -4; reduced_form = 1;   
   #5 literal_in =  5; reduced_form = 1;   
   #5 literal_in =  5; reduced_form = 1;   
   #5 literal_in =  6; reduced_form = 1;   
   #5 literal_in =  7; reduced_form = 1;
   #5 literal_in =  -7; reduced_form = 1;  
   #5 literal_in =  8; reduced_form = 1;  
   #5 literal_in =  1; reduced_form = 1;   
   #5 inputs_over = 1;
   #10 $finish;  
   end 
endmodule
