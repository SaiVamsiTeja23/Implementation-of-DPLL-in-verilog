`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.06.2025 15:20:05
// Design Name: 
// Module Name: FIND_UNIT_CLAUSE
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


module FIND_UNIT_CLAUSE #(parameter WIDTH=9)(
 input [3*WIDTH-1:0]CNF_clause_packed,
 input clause_active,
 input [2:0]clause_in,
 output [WIDTH-1:0]unit_clause,
 output unit_clause_detected
);

wire [WIDTH-1:0]CNF_clause[0:2];
genvar i;
generate
  for (i = 0; i < 3; i = i + 1) begin : unpack_clause
    assign CNF_clause[i] = CNF_clause_packed[(i+1)*WIDTH-1 -: WIDTH];
  end
endgenerate

wire [2:0]temp;
assign temp[2] = clause_in == 3'b100 ;
assign temp[1] = clause_in == 3'b010 ;
assign temp[0] = clause_in == 3'b001 ;

assign unit_clause_detected = clause_active ? (|temp) : 0;
assign unit_clause = unit_clause_detected ? (temp[2] ? CNF_clause[2] : (temp[1] ? CNF_clause[1] : CNF_clause[0]) )  : 0 ;

endmodule
