`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.06.2025 09:05:12
// Design Name: 
// Module Name: UPDATE_CLAUSE_MEMORY
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


// UPDATE THE CLAUSE MODULE

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module UPDATE_CLAUSE_MEMORY #(parameter WIDTH=9, parameter MAX_CLAUSES = 1024, parameter MAX_LITERALS=256)(

	input [MAX_LITERALS-1:0] literal_assigned,
	input [MAX_LITERALS-1:0] literal_bool,

	input update_from_re_update_module, // literals got updated at level>=current_level will be unassigned
	input update_from_sliding_window,

	input [MAX_CLAUSES*3-1:0] clause_in_mem_packed,
	input [MAX_CLAUSES*3*WIDTH-1:0] CNF_CLAUSE_in_mem_packed,
	input [MAX_CLAUSES-1:0] clause_active_in_mem,
	input [MAX_CLAUSES-1:0] clause_valid_in_mem,

	// will be coming from sliding window or reupdate block, we need to select based on the select line
	input [MAX_CLAUSES*3-1:0] clause_in_packed_from_slw,
	input [MAX_CLAUSES*3*WIDTH-1:0] CNF_CLAUSE_in_packed_from_slw,
	input [MAX_CLAUSES-1:0] clause_active_in_from_slw,
	input [MAX_CLAUSES-1:0] clause_valid_in_from_slw,

	output  [MAX_CLAUSES*3-1:0] clause_out_packed,
	output  [MAX_CLAUSES*3*WIDTH-1:0] CNF_CLAUSE_out_packed,
	output  [MAX_CLAUSES-1:0] clause_active_out,
	output  [MAX_CLAUSES-1:0] clause_valid_out

);

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  UNPACKING THE MEMORY INPUTS  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// THESE WILL COME AS FEEDBACK FROM THE CLAUSE-INFO REGISTERS

	wire [2:0] clause_in_mem_unpacked [0:MAX_CLAUSES-1];
	wire [WIDTH-1:0] CNF_CLAUSE_in_mem_unpacked[0:MAX_CLAUSES-1][0:2];
genvar ab, ac;
generate
    for (ab = 0; ab < MAX_CLAUSES; ab = ab + 1) begin 
        assign clause_in_mem_unpacked[ab] = clause_in_mem_packed[ab*3 +: 3];

        for (ac = 0; ac < 3; ac = ac + 1) begin 
            assign CNF_CLAUSE_in_mem_unpacked[ab][ac] = CNF_CLAUSE_in_mem_packed[(ab * 3 + ac) * WIDTH +: WIDTH];
        end
    end
endgenerate
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  UNPACKING THE SLIDING_WINDOW INPUTS  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// THESE WILL COME FROM THE SLIDING_WINDOW_REGISTERS 
	wire [2:0] clause_in_unpacked_from_slw [0:MAX_CLAUSES-1];
	wire [WIDTH-1:0] CNF_CLAUSE_in_unpacked_from_slw[0:MAX_CLAUSES-1][0:2];
genvar ol, il;
generate
    for (ol = 0; ol < MAX_CLAUSES; ol = ol + 1) begin 
        assign clause_in_unpacked_from_slw[ol] = clause_in_packed_from_slw[ol*3 +: 3];
        for ( il = 0; il < 3; il = il + 1 ) begin 
            assign CNF_CLAUSE_in_unpacked_from_slw[ol][il] = CNF_CLAUSE_in_packed_from_slw[(ol * 3 + il) * WIDTH +: WIDTH];
        end
    end
endgenerate
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    MUX-1 outputs   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	wire [2:0] clause_in_unpacked_from_re  [0:MAX_CLAUSES-1];
	wire [WIDTH-1:0] CNF_CLAUSE_in_unpacked_from_re [0:MAX_CLAUSES-1][0:2];
	wire [MAX_CLAUSES-1:0] clause_active_in_from_re ;
	wire [MAX_CLAUSES-1:0] clause_valid_in_from_re ;
	
	wire [2:0] clause_in_unpacked_mux_1  [0:MAX_CLAUSES-1] ;
	wire [WIDTH-1:0] CNF_CLAUSE_in_unpacked_mux_1 [0:MAX_CLAUSES-1][0:2] ;
	wire [MAX_CLAUSES-1:0] clause_active_in_mux_1 ;
	wire [MAX_CLAUSES-1:0] clause_valid_in_mux_1 ;
	

genvar i;
generate
	for(i=0; i<MAX_CLAUSES; i=i+1)
	  begin
		assign clause_in_unpacked_mux_1[i] 	 	= update_from_re_update_module ? clause_in_unpacked_from_re[i]     : clause_in_unpacked_from_slw[i] ;
		assign CNF_CLAUSE_in_unpacked_mux_1[i][0] 	= update_from_re_update_module ? CNF_CLAUSE_in_unpacked_from_re[i][0] : CNF_CLAUSE_in_unpacked_from_slw[i][0];
		assign CNF_CLAUSE_in_unpacked_mux_1[i][1] 	= update_from_re_update_module ? CNF_CLAUSE_in_unpacked_from_re[i][1] : CNF_CLAUSE_in_unpacked_from_slw[i][1];
		assign CNF_CLAUSE_in_unpacked_mux_1[i][2] 	= update_from_re_update_module ? CNF_CLAUSE_in_unpacked_from_re[i][2] : CNF_CLAUSE_in_unpacked_from_slw[i][2];
		assign clause_active_in_mux_1[i]        	= update_from_re_update_module ? clause_active_in_from_re[i]       : clause_active_in_from_slw[i];
		assign clause_valid_in_mux_1[i]         	= update_from_re_update_module ? clause_valid_in_from_re[i]        : clause_valid_in_from_slw[i];
	  end
endgenerate


//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    MUX-2 outputs   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	
	wire [2:0] clause_in_unpacked_mux_2  [0:MAX_CLAUSES-1] ;
	wire [WIDTH-1:0] CNF_CLAUSE_in_unpacked_mux_2 [0:MAX_CLAUSES-1][0:2] ;
	wire [MAX_CLAUSES-1:0] clause_active_in_mux_2 ;
	wire [MAX_CLAUSES-1:0] clause_valid_in_mux_2 ;

wire mux_2_sel ;
assign mux_2_sel = (~update_from_re_update_module) && (~update_from_sliding_window);

genvar pq;
generate
	for(pq = 0; pq < MAX_CLAUSES; pq = pq + 1) begin
		assign clause_in_unpacked_mux_2[pq] 	     = ~mux_2_sel ? clause_in_unpacked_mux_1[pq]      : clause_in_mem_unpacked[pq] ;
		assign CNF_CLAUSE_in_unpacked_mux_2[pq][0] = ~mux_2_sel ? CNF_CLAUSE_in_unpacked_mux_1[pq][0] : CNF_CLAUSE_in_mem_unpacked[pq][0];
		assign CNF_CLAUSE_in_unpacked_mux_2[pq][1] = ~mux_2_sel ? CNF_CLAUSE_in_unpacked_mux_1[pq][1] : CNF_CLAUSE_in_mem_unpacked[pq][1];
		assign CNF_CLAUSE_in_unpacked_mux_2[pq][2] = ~mux_2_sel ? CNF_CLAUSE_in_unpacked_mux_1[pq][2] : CNF_CLAUSE_in_mem_unpacked[pq][2];
		assign clause_active_in_mux_2[pq]         = ~mux_2_sel ? clause_active_in_mux_1[pq]         : clause_active_in_mem[pq];
		assign clause_valid_in_mux_2[pq]          = ~mux_2_sel ? clause_valid_in_mux_1[pq]          : clause_valid_in_mem[pq];
	end
endgenerate

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      PACK MUX-2 OUTPUTS WHICH ARE FINAL OUTPUTS      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
genvar xy, xz;
generate
    for (xy = 0; xy < MAX_CLAUSES; xy = xy + 1) begin
        assign clause_out_packed[xy*3 +: 3] = clause_in_unpacked_mux_2[xy];
        for (xz = 0; xz < 3; xz = xz + 1) begin
            assign CNF_CLAUSE_out_packed[(xy*3 + xz)*WIDTH +: WIDTH] = CNF_CLAUSE_in_unpacked_mux_2[xy][xz];
        end
    end
endgenerate
        assign clause_active_out = clause_active_in_mux_2;
        assign clause_valid_out  = clause_valid_in_mux_2;
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    INSTANTIATING RE-UPDATE BLOCK    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@




wire [WIDTH*3-1:0] CNF_CLAUSE_in_mem_packed_to_re [0:MAX_CLAUSES-1];  // CNF_CLAUSE input to RE_UPDATE BLOCK
genvar w;
generate
    for (w = 0; w < MAX_CLAUSES; w = w + 1) begin
        assign CNF_CLAUSE_in_mem_packed_to_re[w] = { CNF_CLAUSE_in_mem_unpacked[w][2], CNF_CLAUSE_in_mem_unpacked[w][1], CNF_CLAUSE_in_mem_unpacked[w][0] };
    end
endgenerate

wire [3*WIDTH-1:0] CNF_CLAUSE_in_packed_from_re [0:MAX_CLAUSES-1];  // CNF_CLAUSE output from RE_UPDATE BLOCK
genvar u, v;
generate
    for (u = 0; u < MAX_CLAUSES; u = u + 1) begin
        for (v = 0; v < 3; v = v + 1) begin
            assign CNF_CLAUSE_in_unpacked_from_re[u][v] = CNF_CLAUSE_in_packed_from_re[u][v*WIDTH +: WIDTH];
        end
    end
endgenerate

genvar f;
generate
  for (f = 0; f < MAX_CLAUSES; f = f + 1) begin
    re_update_clause #(.WIDTH(WIDTH), .MAX_LITERALS(MAX_LITERALS)) re_update_inst (
      .literal_assigned(literal_assigned),
      .literal_bool(literal_bool),

      .clause_in(clause_in_mem_unpacked[f]),
      .CNF_CLAUSE_in_packed(CNF_CLAUSE_in_mem_packed_to_re[f]),
      .clause_active_in(clause_active_in_mem[f]),
      .clause_valid_in(clause_valid_in_mem[f]),

      .clause_out(clause_in_unpacked_from_re[f]),
      .CNF_CLAUSE_out_packed(CNF_CLAUSE_in_packed_from_re[f]),
      .clause_active_out(clause_active_in_from_re[f]),
      .clause_valid_out(clause_valid_in_from_re[f])
    );
  end
endgenerate


endmodule
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
module re_update_clause #(parameter WIDTH=9, parameter MAX_LITERALS=256)(

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

assign AND3_gates_0[1] = {  literal_assigned[pos_clause[0]] & (~CNF_CLAUSE_in_unpacked[0][WIDTH-1]) & (literal_bool[pos_clause[0]])  };
assign AND3_gates_0[0] = {  literal_assigned[pos_clause[0]] & (CNF_CLAUSE_in_unpacked[0][WIDTH-1]) & (~literal_bool[pos_clause[0]])  };

assign AND3_gates_1[1] = {  literal_assigned[pos_clause[1]] & (~CNF_CLAUSE_in_unpacked[1][WIDTH-1]) & (literal_bool[pos_clause[1]])  };
assign AND3_gates_1[0] = {  literal_assigned[pos_clause[1]] & (CNF_CLAUSE_in_unpacked[1][WIDTH-1]) & (~literal_bool[pos_clause[1]])  };

assign AND3_gates_2[1] = {  literal_assigned[pos_clause[2]] & (~CNF_CLAUSE_in_unpacked[2][WIDTH-1]) & (literal_bool[pos_clause[2]])  };
assign AND3_gates_2[0] = {  literal_assigned[pos_clause[2]] & (CNF_CLAUSE_in_unpacked[2][WIDTH-1]) & (~literal_bool[pos_clause[2]])  };

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
