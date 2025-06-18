`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.06.2025 16:43:38
// Design Name: 
// Module Name: MARK_UNIT_CLAUSE
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


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////   combo ckt for marking all the unit literals using unit_clause_detected signals from SLIDING WINDOW BLOCK   ///////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




module MARK_UNIT_CLAUSE #(parameter WIDTH=9,parameter MAX_SIZE=256, parameter N=20, parameter MAX_ROTATION = 512) (
 
 input  [MAX_SIZE*WIDTH-1:0] unit_clauses_packed 	  ,   	  // this will come from 256 FLOP-X's
 input  [MAX_SIZE-1:0]	     unit_clause_detected_packed  ,	  // this will also come from 256 FLOP-X's
 output [MAX_SIZE-1:0]	     mark_all_unit_clauses_packed ,	 
 output [MAX_SIZE-1:0]	     bool_val_of_unit_lits_packed 
 
);

wire [MAX_SIZE-1:0] demux_out 		[0:MAX_SIZE-1];
wire [MAX_SIZE-1:0] demux_out_msb 	[0:MAX_SIZE-1];

reg [MAX_SIZE-1:0] temp_flags [0:MAX_SIZE-1];
reg [MAX_SIZE-1:0] temp_flags_msb [0:MAX_SIZE-1];
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  UNPACKING INPUTS  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 wire [WIDTH-1:0]  unit_clauses 	 [0:MAX_SIZE-1];   	  // this will come from 256 FLOP-X's
 wire 		   unit_clause_detected  [0:MAX_SIZE-1];

genvar w;
generate
    for (w= 0; w < MAX_SIZE; w = w + 1) 
      begin
        assign unit_clauses[w]         = unit_clauses_packed[w*WIDTH +: WIDTH];
	assign unit_clause_detected[w] = unit_clause_detected_packed[w];
      end
endgenerate
///////////////////////////////////////////////////////////////////////////////////////////////////////////
genvar a;
generate
    for(a = 0 ; a < MAX_SIZE ; a = a + 1)
	begin
		demux_1to256 #(.WIDTH(WIDTH), .MAX_SIZE(MAX_SIZE)) demux_inst( 
									.en(unit_clause_detected[a]), 
									.sel(unit_clauses[a]),
									.dout(demux_out[a]),
									.msb_out(demux_out_msb[a])
									);
	end
endgenerate


integer j,k;
always@(*)
  begin
	for(j=0; j < MAX_SIZE; j=j+1)
	  begin
		for(k=0; k < MAX_SIZE; k=k+1)
		  begin
			temp_flags[j][k] 	= demux_out[k][j];
			temp_flags_msb[j][k] 	= demux_out_msb[k][j];
		  end
	  end
  end

////////////////////////////////////////////////////////////////////////////////////////////////
wire mark_all_unit_lit [0:MAX_SIZE-1];
wire bool_val_of_unit_lit [0:MAX_SIZE-1];

genvar l;
generate
	for( l=0 ; l< MAX_SIZE; l=l+1)
	  begin
		assign mark_all_unit_lit[l]    = (|temp_flags[l]);
		assign bool_val_of_unit_lit[l] = (|temp_flags_msb[l]);
	  end
endgenerate

/////////////////////////////////  PACKING OUTPUTS  /////////////////////////////////////////////
genvar m;
generate
    for (m = 0; m < MAX_SIZE; m = m + 1) 
      begin
	assign mark_all_unit_clauses_packed[m] = mark_all_unit_lit[m];
	assign bool_val_of_unit_lits_packed[m] = bool_val_of_unit_lit[m];
      end
endgenerate
/////////////////////////////////////////////////////////////////////////////////////////////////
endmodule




///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////// 1to256 DEMUX ////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module demux_1to256 #(parameter WIDTH=9, parameter MAX_SIZE = 256)(

    input en,                     // Enable signal
    input [WIDTH-1:0] sel,        // 8-bit select line
    output [MAX_SIZE-1:0] dout,    // 256 outputs, each 8-bit wide
    output [MAX_SIZE-1:0]msb_out
);

 wire [WIDTH-1:0] temp;
 assign temp = sel[WIDTH-1] ? -sel : sel ;
wire [WIDTH-2:0] pos_sel;
assign pos_sel = temp[WIDTH-2:0];

genvar i;
generate
	for(i=0;i<MAX_SIZE;i=i+1) begin
		assign dout[i]    = (i==pos_sel) & en;
		assign msb_out[i] = (i==pos_sel) & (~sel[WIDTH-1]);
	end
endgenerate
endmodule
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
