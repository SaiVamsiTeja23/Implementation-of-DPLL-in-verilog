`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.06.2025 10:24:32
// Design Name: 
// Module Name: stack_imp
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


// stack implementation

module stack_imp #(parameter WIDTH = 8,parameter DEPTH = 16) (
    input clk,
    input rst,
    input push,
    input pop,
    input [WIDTH-1:0] data_in,
    input choose_boolean_val,
    output reg [WIDTH-1:0] data_out,
    output reg dout_bool,
    output reg empty,
    output reg full,
    output pushing,
    output popping
);
// Stack memory
assign pushing = push;
assign popping = pop;
    reg [WIDTH-1:0] stack_mem [0:DEPTH-1];
    reg             stack_mem_bool [0:DEPTH-1]; // we will stroe the boolean value of element that are stored in stack_mem  
// Stack pointer
    reg [$clog2(DEPTH):0] sp;               

    always @(posedge clk) 
     begin
        if (rst) 
	       begin
            sp <= 0;
            empty <= 1;
            full <= 0;
           end 
	    else 
	       begin
            if (push && (~full)) 
	           begin
                stack_mem[sp] <= data_in;
                stack_mem_bool[sp] <= choose_boolean_val;
                sp <= sp + 1;
               end 
            if (pop && (~empty))
 	           begin
                sp <= sp - 1;
                data_out <= stack_mem[sp-1];
                dout_bool <= stack_mem_bool[sp-1];
               end
            empty <= (sp == 0);
            full <= (sp == DEPTH);
           end
      end
endmodule

