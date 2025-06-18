`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.06.2025 10:30:10
// Design Name: 
// Module Name: tb_stack_imp
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


module tb_stack_imp(    );

localparam depth = 16;
localparam width = 8;
reg clk,rst,push,pop;
reg [width-1:0] data_in;
reg choose_bool_val;
wire dout_bool;
wire empty,full;
wire [width-1:0] data_out;

wire pushing,popping;

stack_imp #(.WIDTH(width),.DEPTH(depth)) dut( .clk(clk),.rst(rst),.push(push),.pop(pop),
                                              .data_in(data_in),
                                              .choose_boolean_val(choose_bool_val),
                                              .empty(empty),.full(full),
                                              .data_out(data_out)   ,
                                              .dout_bool(dout_bool),
                                              .pushing(pushing), .popping(popping)                                           
);

initial
begin
clk = 0;
rst = 0;
push= 0;
pop = 0;
end
always #5 clk = ~clk;
initial
begin
#3 rst = 1;
#5 rst = 0; data_in = 5; push = 1; pop = 0; choose_bool_val=0;
#10 data_in = 15; push = 1; pop = 0;choose_bool_val=0;
#10 data_in = 1; push = 1; pop = 0;choose_bool_val=0;
#10 data_in = 2; push = 1; pop = 0;choose_bool_val=1;
#10 data_in = 3; push = 1; pop = 0;choose_bool_val=0;
#10               push = 0; pop = 1;
#10 data_in = 4; push = 1; pop = 0;choose_bool_val=1;
#10 data_in = 5; push = 1; pop = 0;choose_bool_val=1;
#10               push = 0; pop = 1;
#10 data_in = 6; push = 1; pop = 0;choose_bool_val=0;
#10               push = 0; pop = 1;
#10               push = 0; pop = 1;
#10               push = 0; pop = 1;
#10               push = 0; pop = 1;
#10               push = 0; pop = 1;
#10 $finish;
end

endmodule
