`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.06.2025 15:59:03
// Design Name: 
// Module Name: re_update
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

module re_update #(parameter WIDTH=9, parameter MAX_LITERALS=256)(

	input [MAX_LITERALS-1:0] literal_bool,
	input [MAX_LITERALS-1:0] literal_assigned,

	input [2:0] clause_in,
	input [3*WIDTH-1:0] CNF_CLAUSE_in_packed,
	input  clause_active_in,
	input  clause_valid_in,

	output  [2:0] clause_out,
	output  [3*WIDTH-1:0] CNF_CLAUSE_out_packed,
	output   clause_active_out,
	output   clause_valid_out
	
);

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ UNPACK THE CLAUSE INFO @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

wire [WIDTH-1:0] CNF_CLAUSE_in_unpacked [0:2];
genvar i;
generate
    for (i = 0; i < 3; i = i + 1) begin 
        assign CNF_CLAUSE_in_unpacked[i] = CNF_CLAUSE_in_packed[(i+1)*WIDTH-1 -: WIDTH];
    end
endgenerate
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
wire [WIDTH-1:0] CNF_CLAUSE_out_unpacked [0:2];
assign CNF_CLAUSE_out_packed = {CNF_CLAUSE_in_unpacked[2],CNF_CLAUSE_in_unpacked[1],CNF_CLAUSE_in_unpacked[0]};

wire [WIDTH-1:0] pos_clause [0:2];
assign pos_clause[0] = CNF_CLAUSE_in_unpacked[0][WIDTH-1] ? -CNF_CLAUSE_in_unpacked[0] : CNF_CLAUSE_in_unpacked[0];
assign pos_clause[1] = CNF_CLAUSE_in_unpacked[1][WIDTH-1] ? -CNF_CLAUSE_in_unpacked[1] : CNF_CLAUSE_in_unpacked[1];
assign pos_clause[2] = CNF_CLAUSE_in_unpacked[2][WIDTH-1] ? -CNF_CLAUSE_in_unpacked[2] : CNF_CLAUSE_in_unpacked[2];

wire  [2:0] clause_out_temp;

assign clause_out_temp[0] = clause_in[0] | (~literal_assigned[pos_clause[0]]);
assign clause_out_temp[1] = clause_in[1] | (~literal_assigned[pos_clause[1]]);
assign clause_out_temp[2] = clause_in[2] | (~literal_assigned[pos_clause[2]]);


assign clause_valid_out = clause_valid_in;

wire clause_active_out_temp ;
assign clause_active_out_temp = clause_active_in | (|clause_out_temp);


wire [1:0] AND3_gates_0;
wire [1:0] AND3_gates_1;
wire [1:0] AND3_gates_2;

assign AND3_gates_0[1] = (  literal_assigned[pos_clause[0]] & (~CNF_CLAUSE_in_unpacked[0][WIDTH-1]) & (literal_bool[pos_clause[0]])  );
assign AND3_gates_0[0] = (  literal_assigned[pos_clause[0]] & (CNF_CLAUSE_in_unpacked[0][WIDTH-1]) & (~literal_bool[pos_clause[0]])  );

assign AND3_gates_1[1] = (  literal_assigned[pos_clause[1]] & (~CNF_CLAUSE_in_unpacked[1][WIDTH-1]) & (literal_bool[pos_clause[1]])  );
assign AND3_gates_1[0] = (  literal_assigned[pos_clause[1]] & (CNF_CLAUSE_in_unpacked[1][WIDTH-1]) & (~literal_bool[pos_clause[1]])  );

assign AND3_gates_2[1] = (  literal_assigned[pos_clause[2]] & (~CNF_CLAUSE_in_unpacked[2][WIDTH-1]) & (literal_bool[pos_clause[2]])  );
assign AND3_gates_2[0] = (  literal_assigned[pos_clause[2]] & (CNF_CLAUSE_in_unpacked[2][WIDTH-1]) & (~literal_bool[pos_clause[2]])  );

wire OR_0,OR_1,OR_2;
assign OR_0 = AND3_gates_0[1] | AND3_gates_0[0] ;
assign OR_1 = AND3_gates_1[1] | AND3_gates_1[0] ;
assign OR_2 = AND3_gates_2[1] | AND3_gates_2[0] ;

wire final_OR;
assign final_OR = OR_0 | OR_1 | OR_2 ; 

assign clause_out[0] = clause_out_temp[0] & (~final_OR);
assign clause_out[1] = clause_out_temp[1] & (~final_OR);
assign clause_out[2] = clause_out_temp[2] & (~final_OR);

assign clause_active_out = clause_active_out_temp & (~final_OR);

endmodule
