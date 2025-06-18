`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2025 08:52:05
// Design Name: 
// Module Name: tb_sat_check
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


module tb_sat_check();
localparam max_clauses=16;
reg [max_clauses*3-1:0] clauses ;
reg [max_clauses-1:0] clause_active ;
reg [max_clauses-1:0] clause_valid ;
wire return_true;
wire return_false;

sat_check #(.MAX_CLAUSES(max_clauses)) DUT(
	.clauses(clauses) ,
	.clause_active(clause_active) ,
	.clause_valid(clause_valid) ,
	.return_true(return_true),
	.return_false(return_false)
);

initial
begin
clauses=0;  clause_active=0;    clause_valid={ {6{1'b0}}, {10{1'b1}} };
#10 clauses=48'h000037FAB00D;   clause_active={ {6{1'b0}}, {8{1'b1}},1'b0,1'b1 };       clause_valid={ {6{1'b0}}, {10{1'b1}} };
#10 clauses=48'h000037FAB10D;   clause_active={ {6{1'b0}}, {8{1'b1}},1'b0,1'b1 };       clause_valid={ {6{1'b0}}, {10{1'b1}} };
#10 clauses=48'h000037FAB50D;   clause_active={ {6{1'b0}}, {8{1'b1}},1'b0,1'b1 };       clause_valid={ {6{1'b0}}, {10{1'b1}} };

#10 $finish;
end

endmodule
