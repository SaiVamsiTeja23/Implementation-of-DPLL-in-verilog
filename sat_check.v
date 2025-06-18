`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2025 08:49:06
// Design Name: 
// Module Name: sat_check
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


module sat_check #(parameter MAX_CLAUSES = 1024) (
	
	input [MAX_CLAUSES*3-1:0] clauses ,
	input [MAX_CLAUSES-1:0] clause_active ,
	input [MAX_CLAUSES-1:0] clause_valid ,

	output return_true,
	output return_false
);

	wire [2:0] clauses_unpacked [0:MAX_CLAUSES-1];

genvar j;
generate
    for (j = 0; j < MAX_CLAUSES; j = j + 1) begin 
        assign clauses_unpacked[j] = clauses[3*j +: 3];
    end
endgenerate

wire [MAX_CLAUSES-1:0] each_clause_valid_NAND_active;
wire [MAX_CLAUSES-1:0] each_clause_NOR;

genvar i;
generate
    for (i = 0; i < MAX_CLAUSES; i = i + 1) begin : unpack_loop
        assign each_clause_valid_NAND_active[i] = ~(clause_valid[i] & clause_active[i]);
	assign each_clause_NOR[i]               = ~(|(clauses_unpacked[i]));
    end
endgenerate

wire [MAX_CLAUSES-1:0] each_clause_valid_AND_active;
wire [MAX_CLAUSES-1:0] each_clause_valid_and_active_AND_clause_nor;

assign each_clause_valid_AND_active = ~(each_clause_valid_NAND_active);
assign each_clause_valid_and_active_AND_clause_nor = (each_clause_valid_AND_active & each_clause_NOR);

assign return_true  =  &(each_clause_valid_NAND_active);
assign return_false =  |(each_clause_valid_and_active_AND_clause_nor);

endmodule


