`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2025 10:54:25
// Design Name: 
// Module Name: tb_re_update
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


module tb_re_update();
localparam width=4;
localparam max_literals=8;

reg [max_literals-1:0] literal_assigned;
reg [max_literals-1:0] literal_bool;

reg [2:0] clause_in;
reg [3*width-1:0] CNF_CLAUSE_in;
reg  clause_active_in;
reg  clause_valid_in;

wire [2:0] clause_out;
wire [3*width-1:0] CNF_CLAUSE_out;
wire  clause_active_out;
wire  clause_valid_out;
 re_update #(.WIDTH(width),.MAX_LITERALS(max_literals))DUT(
    .literal_assigned(literal_assigned ),
    .literal_bool(literal_bool),
	// will be coming from sliding window or reupdate block, we need to select based on the select line
	.clause_in(clause_in),
	.CNF_CLAUSE_in_packed(CNF_CLAUSE_in),
	.clause_active_in(clause_active_in),
	.clause_valid_in(clause_valid_in),

	.clause_out(clause_out),
	.CNF_CLAUSE_out_packed(CNF_CLAUSE_out),
	.clause_active_out(clause_active_out),
	.clause_valid_out(clause_valid_out)
);

initial
begin
//literal_assigned = {(4){1'b0}};
//#10 clause_in = 3'b000; CNF_CLAUSE_in = {3'b001,3'b010,3'b011}; clause_active_in = 0; clause_valid_in = 1;
//#10 clause_in = 3'b011; CNF_CLAUSE_in = {3'b111,3'b110,3'b101}; clause_active_in = 1; clause_valid_in = 1;

//#10 clause_in = 3'b000; CNF_CLAUSE_in = {3'b001,3'b110,3'b101}; clause_active_in = 0; clause_valid_in = 1;
//#10 clause_in = 3'b011; CNF_CLAUSE_in = {3'b111,3'b010,3'b011}; clause_active_in = 1; clause_valid_in = 1; 

//#10 clause_in = 3'b000; CNF_CLAUSE_in = {3'b001,3'b101,3'b110}; clause_active_in = 0; clause_valid_in = 1; 
//#10 clause_in = 3'b011; CNF_CLAUSE_in = {3'b111,3'b011,3'b010}; clause_active_in = 1; clause_valid_in = 1;

//#10 clause_in = 3'b101; CNF_CLAUSE_in = {3'b010,3'b111,3'b101}; clause_active_in = 1; clause_valid_in = 1;
//#10 clause_in = 3'b000; CNF_CLAUSE_in = {3'b110,3'b001,3'b011}; clause_active_in = 0; clause_valid_in = 1;

//#10 clause_in = 3'b101; CNF_CLAUSE_in = {3'b011,3'b111,3'b110}; clause_active_in = 1; clause_valid_in = 1;
//#10 clause_in = 3'b000; CNF_CLAUSE_in = {3'b101,3'b001,3'b010}; clause_active_in = 0; clause_valid_in = 1;

literal_assigned = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0};
literal_bool =     {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
#10 clause_in = 3'b000; CNF_CLAUSE_in = {4'b0001,4'b0010,4'b0011}; clause_active_in = 0; clause_valid_in = 1;
#10 clause_in = 3'b000; CNF_CLAUSE_in = {4'b0001,4'b1110,4'b0011}; clause_active_in = 1; clause_valid_in = 1; 
#10 clause_in = 3'b000; CNF_CLAUSE_in = {4'b1111,4'b0100,4'b0101}; clause_active_in = 0; clause_valid_in = 1; 

#10 $finish;
end
endmodule

