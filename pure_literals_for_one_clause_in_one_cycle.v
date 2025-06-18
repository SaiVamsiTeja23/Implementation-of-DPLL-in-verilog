`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.06.2025 15:04:25
// Design Name: 
// Module Name: pure_literals_for_one_clause_in_one_cycle
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
module pure_literals_for_mutltiple_clauses_in_one_cycle #(parameter WIDTH=9,parameter OUT_SIZE=256) (
	input reset,
	input clk,

	input [WIDTH*3-1:0] clause_in1,
	input [2:0] clause_in_reduced_form1,

	input [WIDTH*3-1:0] clause_in2,
	input [2:0] clause_in_reduced_form2,

	input [WIDTH*3-1:0] clause_in3,
	input [2:0] clause_in_reduced_form3,

	input [WIDTH*3-1:0] clause_in4,
	input [2:0] clause_in_reduced_form4,

	output [WIDTH*3-1:0] clause_out1,
	output [2:0] clause_out_reduced_form1,

	output [WIDTH*3-1:0] clause_out2,
	output [2:0] clause_out_reduced_form2,

	output [WIDTH*3-1:0] clause_out3,
	output [2:0] clause_out_reduced_form3,

	output [WIDTH*3-1:0] clause_out4,
	output [2:0] clause_out_reduced_form4,

	output reg [OUT_SIZE-1:0] pure_literals
);

wire [OUT_SIZE-1:0] OR_inst_1_pos_seen, OR_inst_2_pos_seen, OR_inst_3_pos_seen, OR_inst_4_pos_seen;
wire [OUT_SIZE-1:0] OR_inst_1_neg_seen, OR_inst_2_neg_seen, OR_inst_3_neg_seen, OR_inst_4_neg_seen;
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ HERE I'M PASSING 4 CLAUSES IN 1 CYCLE @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ (IF NEEDED, ONE CAN EXTEND IT TO >4)  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
pure_literals_for_one_clause_in_one_cycle #(.WIDTH(WIDTH),.OUT_SIZE(OUT_SIZE)) level2_inst1(
	.clk(clk),
	.reset(reset),
	.CLAUSE_in(clause_in1),
	.clause_in_reduced_form(clause_in_reduced_form1),

	.CLAUSE_out(clause_out1),
	.clause_out_reduced_form(clause_out_reduced_form1),
	
	.OR_STAGE_1_pos(OR_inst_1_pos_seen),
	.OR_STAGE_1_neg(OR_inst_1_neg_seen)
);

pure_literals_for_one_clause_in_one_cycle #(.WIDTH(WIDTH),.OUT_SIZE(OUT_SIZE)) level2_inst2(
	.clk(clk),
	.reset(reset),
	.CLAUSE_in(clause_in2),
	.clause_in_reduced_form(clause_in_reduced_form2),

	.CLAUSE_out(clause_out2),
	.clause_out_reduced_form(clause_out_reduced_form2),
	
	.OR_STAGE_1_pos(OR_inst_2_pos_seen),
	.OR_STAGE_1_neg(OR_inst_2_neg_seen)
);

pure_literals_for_one_clause_in_one_cycle #(.WIDTH(WIDTH),.OUT_SIZE(OUT_SIZE)) level2_inst3(
	.clk(clk),
	.reset(reset),
	.CLAUSE_in(clause_in3),
	.clause_in_reduced_form(clause_in_reduced_form3),

	.CLAUSE_out(clause_out3),
	.clause_out_reduced_form(clause_out_reduced_form3),
	
	.OR_STAGE_1_pos(OR_inst_3_pos_seen),
	.OR_STAGE_1_neg(OR_inst_3_neg_seen)
);

pure_literals_for_one_clause_in_one_cycle #(.WIDTH(WIDTH),.OUT_SIZE(OUT_SIZE)) level2_inst4(
	.clk(clk),
	.reset(reset),
	.CLAUSE_in(clause_in4),
	.clause_in_reduced_form(clause_in_reduced_form4),

	.CLAUSE_out(clause_out4),
	.clause_out_reduced_form(clause_out_reduced_form4),
	
	.OR_STAGE_1_pos(OR_inst_4_pos_seen),
	.OR_STAGE_1_neg(OR_inst_4_neg_seen)
);


/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////      OUTPUTS      ////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

wire [OUT_SIZE-1:0] OR_stage_2_pos_seen;
wire [OUT_SIZE-1:0] OR_stage_2_neg_seen;

genvar k;
generate 
	for( k=0 ; k<OUT_SIZE ; k=k+1 )
	  begin
		assign OR_stage_2_pos_seen[k] = (OR_inst_1_pos_seen[k] | OR_inst_2_pos_seen[k] | OR_inst_3_pos_seen[k] | OR_inst_4_pos_seen[k]);
		assign OR_stage_2_neg_seen[k] = (OR_inst_1_neg_seen[k] | OR_inst_2_neg_seen[k] | OR_inst_3_neg_seen[k] | OR_inst_4_neg_seen[k]);
	  end
endgenerate

integer b;
always@(posedge clk)
  begin
	for( b=0 ; b<OUT_SIZE ; b=b+1 )
	  begin
		pure_literals[b] <=  OR_stage_2_pos_seen[b] ^ OR_stage_2_neg_seen[b] ;
	  end
  end

endmodule



///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
module pure_literals_for_one_clause_in_one_cycle #(parameter WIDTH=9,parameter OUT_SIZE=256) (
	input reset,
	input [3*WIDTH-1:0] CLAUSE_in,
	input [2:0] clause_in_reduced_form,
	input clk,
	
	output [3*WIDTH-1:0] CLAUSE_out,
	output [2:0] clause_out_reduced_form,

	output [OUT_SIZE-1:0] OR_STAGE_1_pos,
	output [OUT_SIZE-1:0] OR_STAGE_1_neg

);
wire [WIDTH-1:0] CLAUSE_in_unpacked [0:2];
genvar j;
generate
    for (j = 0; j < 3; j = j + 1) begin
        assign CLAUSE_in_unpacked[j] = CLAUSE_in[j*WIDTH +: WIDTH];
    end
endgenerate
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////      OUTPUTS      ////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

wire [OUT_SIZE-1:0]inst1_pos_seen;
wire [OUT_SIZE-1:0]inst2_pos_seen;
wire [OUT_SIZE-1:0]inst3_pos_seen;

wire [OUT_SIZE-1:0]inst1_neg_seen;
wire [OUT_SIZE-1:0]inst2_neg_seen;
wire [OUT_SIZE-1:0]inst3_neg_seen;

genvar i;
generate
	for( i=0 ; i<OUT_SIZE ; i=i+1 )
	  begin
		assign OR_STAGE_1_pos[i] = inst1_pos_seen[i] | inst2_pos_seen[i] | inst3_pos_seen[i] ;
		assign OR_STAGE_1_neg[i] = inst1_neg_seen[i] | inst2_neg_seen[i] | inst3_neg_seen[i] ;
	  end
endgenerate

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire [WIDTH-1:0] literal_out1,literal_out2,literal_out3;
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
pure_literals_for_one_lit_in_one_cycle #(.WIDTH(WIDTH),.OUT_SIZE(OUT_SIZE)) inst1 (
	.reset(reset),
	.literal_in(CLAUSE_in_unpacked[0]),
	.literal_in_reduced_form(clause_in_reduced_form[0]),
	.clk(clk),
	.literal_out(literal_out1),
	.literal_out_reduced_form(clause_out_reduced_form[0]),

	.ff_store_pos(inst1_pos_seen),
	.ff_store_neg(inst1_neg_seen)
);
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
pure_literals_for_one_lit_in_one_cycle #(.WIDTH(WIDTH),.OUT_SIZE(OUT_SIZE)) inst2 (
	.reset(reset),
	.literal_in(CLAUSE_in_unpacked[1]),
	.literal_in_reduced_form(clause_in_reduced_form[1]),
	.clk(clk),
	.literal_out(literal_out2),
	.literal_out_reduced_form(clause_out_reduced_form[1]),

	.ff_store_pos(inst2_pos_seen),
	.ff_store_neg(inst2_neg_seen)
);
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
pure_literals_for_one_lit_in_one_cycle #(.WIDTH(WIDTH),.OUT_SIZE(OUT_SIZE)) inst3 (
	.reset(reset),
	.literal_in(CLAUSE_in_unpacked[2]),
	.literal_in_reduced_form(clause_in_reduced_form[2]),
	.clk(clk),
	.literal_out(literal_out3),
	.literal_out_reduced_form(clause_out_reduced_form[2]),

	.ff_store_pos(inst3_pos_seen),
	.ff_store_neg(inst3_neg_seen)
);

assign CLAUSE_out = {literal_out3,literal_out2,literal_out1};

endmodule

////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
module pure_literals_for_one_lit_in_one_cycle #(parameter WIDTH=9,parameter OUT_SIZE=256) (
	input reset,
	input [WIDTH-1:0] literal_in,
	input literal_in_reduced_form,
	input clk,
	
	output reg [WIDTH-1:0] literal_out,
	output reg literal_out_reduced_form,

	output reg [OUT_SIZE-1:0] ff_store_pos,
	output reg [OUT_SIZE-1:0] ff_store_neg
);
wire [OUT_SIZE-1:0] demux_out ;
wire [WIDTH:0] pos_literal;
assign pos_literal = literal_in[WIDTH] ? -literal_in : literal_in;
// demux 1x256
    genvar j;
    generate
        for (j = 0; j < OUT_SIZE; j = j + 1) begin : gen_demux
            assign demux_out[j] = (pos_literal[WIDTH-1:0] == j) ? literal_in_reduced_form : 0 ;
        end
    endgenerate

// demux 1x2
wire sel;
assign sel = literal_in[WIDTH]; // MSB
wire [1:0] demux1to2;
    assign demux1to2[0] = (sel == 1'b0) ? 1'b1 : 1'b0;
    assign demux1to2[1] = (sel == 1'b1) ? 1'b1 : 1'b0;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////  ALWAYS BLOCK  /////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
integer i;
always@(posedge clk)
  begin
	if(reset)
	  begin
		for(i=0; i<OUT_SIZE; i=i+1)
		  begin
			ff_store_pos[i]    <= 0;
			ff_store_neg[i]    <= 0;			
		  end
	  end
	else
	  begin
		for(i=0; i<OUT_SIZE; i=i+1)
		  begin
			ff_store_pos[i]    <= literal_in_reduced_form ? (demux1to2[0] ? demux1to2[0] : ff_store_pos[i]) : ff_store_pos[i];
			ff_store_neg[i]    <= literal_in_reduced_form ? (demux1to2[1] ? demux1to2[1] : ff_store_neg[i]) : ff_store_neg[i];
		  end
	  end
  end
always@(posedge clk)
  begin
	literal_out <= literal_in;
	literal_out_reduced_form <= literal_in_reduced_form;
	
  end
endmodule

