`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.06.2025 15:21:44
// Design Name: 
// Module Name: tb_FIND_UNIT_CLAUSE
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


module tb_FIND_UNIT_CLAUSE();
localparam width = 9;
 reg [3*width-1:0]CNF_clause_packed;
 reg clause_active;
 reg [2:0]clause_in;

wire [width-1:0]unit_clause;
wire unit_clause_detected;

FIND_UNIT_CLAUSE #(.WIDTH(width)) dut_find_unit_clause (
 .CNF_clause_packed(CNF_clause_packed),
 .clause_active(clause_active),
 .clause_in(clause_in),
 .unit_clause(unit_clause),
 .unit_clause_detected(unit_clause_detected)
);

initial
begin
     CNF_clause_packed = {-9'd1,9'd6,9'd7};     clause_active = 1; clause_in = 3'b001;
#10  CNF_clause_packed = {9'd1,9'd2,9'd25};     clause_active = 1; clause_in = 3'b101;
#10  CNF_clause_packed = {-9'd5,-9'd6,9'd8};    clause_active = 1; clause_in = 3'b111;
#10  CNF_clause_packed = {-9'd8,-9'd2,-9'd3};   clause_active = 1; clause_in = 3'b100;
#10  CNF_clause_packed = {9'd6,9'd4,9'd3};      clause_active = 1; clause_in = 3'b001;
#10  CNF_clause_packed = {9'd6,9'd7,9'd47};     clause_active = 1; clause_in = 3'b101;
#10  CNF_clause_packed = {9'd8,9'd5,9'd67};     clause_active = 0; clause_in = 3'b001;
#10  CNF_clause_packed = {9'd54,-9'd53,-9'd14}; clause_active = 1; clause_in = 3'b101;
#10  CNF_clause_packed = {-9'd1,9'd46,9'd71};   clause_active = 1; clause_in = 3'b010;
#10  CNF_clause_packed = {-9'd15,9'd16,9'd17};  clause_active = 1; clause_in = 3'b101;
#10 $finish;
end
endmodule
