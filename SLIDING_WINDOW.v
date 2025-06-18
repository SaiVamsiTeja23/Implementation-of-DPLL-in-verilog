`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.06.2025 16:47:56
// Design Name: 
// Module Name: SLIDING_WINDOW
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




module SLIDING_WINDOW #(parameter WIDTH=9, parameter MAX_SIZE=256, parameter MAX_ROTATION=256) (
  input clk,
  input total_ckt_reset,
  input [WIDTH-1:0]current_level,
  input load_data_in,

  input [MAX_SIZE*3-1:0] clause_in_packed ,
  input [MAX_SIZE*3*WIDTH-1:0] CNF_CLAUSE_packed ,
  input [MAX_SIZE-1:0] clause_active_in_packed ,
  input [MAX_SIZE-1:0] clause_valid_in_packed ,

  input [MAX_SIZE*(WIDTH-1)-1:0] mem_in_literals_packed ,                       // all literals in positive form
  input [MAX_SIZE-1:0] mem_in_bool_vals_packed ,
  input [MAX_SIZE-1:0] mem_in_unit_lit_or_pure_lit_packed,
  input [MAX_SIZE-1:0] mem_in_literal_valid_packed ,
  input [MAX_SIZE*WIDTH-1:0] mem_in_literal_updated_level_packed,

  output [MAX_SIZE*3-1:0] clause_out_packed ,
  output [MAX_SIZE*3*WIDTH-1:0] CNF_CLAUSE_OUT_packed ,
  output [MAX_SIZE-1:0] clause_valid_out_packed ,
  output [MAX_SIZE-1:0] clause_active_out_packed ,

  output reg job_done,
  output [MAX_SIZE-1:0] mark_all_unit_clauses ,
  output [MAX_SIZE-1:0] bool_vals_of_marked_unit_clauses
);

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  UNPACKING THE CLAUSE INFO (INPUTS) @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  wire [2:0] clause_in [0:MAX_SIZE-1];
  wire [WIDTH-1:0]CNF_CLAUSE [0:MAX_SIZE-1][0:2];
  wire clause_active_in [0:MAX_SIZE-1];
  wire clause_valid_in [0:MAX_SIZE-1];

genvar ia;
generate
  for (ia = 0; ia < MAX_SIZE; ia = ia + 1) begin
    assign clause_in[ia] = clause_in_packed[(ia+1)*3 - 1 -: 3];
    assign clause_active_in[ia] = clause_active_in_packed[ia];
    assign clause_valid_in[ia] = clause_valid_in_packed[ia];
  end
endgenerate
genvar ib, jb;
generate
    for (ib = 0; ib < MAX_SIZE; ib = ib + 1) begin 
        for (jb = 0; jb < 3; jb = jb + 1) begin 
            assign CNF_CLAUSE[ib][jb] 		   = CNF_CLAUSE_packed[(ib*3 + jb + 1)*WIDTH - 1 -: WIDTH];
        end
    end
endgenerate
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  UNPACKING THE LITERAL INFO (INPUTS) @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

//THERE IS ONLY ONE ARRAY INDICATING WHETHER THE LITERAL IS UNIT/PURE, that is "mem_in_unit_lit_or_not"

  wire [(WIDTH-1)-1:0] mem_in_literals_unpacked [0:MAX_SIZE-1];                       	// all literals
  wire mem_in_bool_vals_unpacked [0:MAX_SIZE-1];					// Boolean values of each literal
  wire mem_in_unit_lit_or_pure_lit_unpacked [0:MAX_SIZE-1];				// whether they are unit/pure literals are not. Only used when loading pure literals
  wire mem_in_literal_valid [0:MAX_SIZE-1];						// Valid literal or not
  wire [WIDTH-1:0] mem_in_literal_updated_level_unpacked [0:MAX_SIZE-1];


genvar ic;
generate
  for (ic = 0; ic < MAX_SIZE; ic = ic + 1) begin 
    	assign mem_in_literals_unpacked[ic] 		 = mem_in_literals_packed[ic*(WIDTH-1) +: (WIDTH-1)] ;
	assign mem_in_unit_lit_or_pure_lit_unpacked[ic]	 = mem_in_unit_lit_or_pure_lit_packed[ic];
	assign mem_in_bool_vals_unpacked[ic] 	 	 = mem_in_bool_vals_packed[ic] ;
	assign mem_in_literal_valid[ic]	 		 = mem_in_literal_valid_packed[ic] ;
	assign mem_in_literal_updated_level_unpacked[ic] = mem_in_literal_updated_level_packed[ic*WIDTH +: WIDTH];
  end
endgenerate
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  PACKING CLAUSE OUTPUTS  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  wire [2:0] clause_out [0:MAX_SIZE-1];
  wire [WIDTH-1:0]CNF_CLAUSE_OUT [0:MAX_SIZE-1][0:2];
  wire clause_active_out [0:MAX_SIZE-1];
  wire clause_valid_out [0:MAX_SIZE-1];

genvar id;
generate
  for (id = 0; id < MAX_SIZE; id = id + 1) begin
    assign clause_out_packed[id*3 +: 3] = clause_out[id];
    assign clause_valid_out_packed[id] = clause_valid_out[id];
    assign clause_active_out_packed[id] = clause_active_out[id];
  end
endgenerate

genvar ie, je;
generate
  for (ie = 0; ie < MAX_SIZE; ie = ie + 1) begin
    for (je = 0; je < 3; je = je + 1) begin
      assign CNF_CLAUSE_OUT_packed[(ie*3 + je)*WIDTH +: WIDTH] = CNF_CLAUSE_OUT[ie][je];
    end
  end
endgenerate

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ASSIGNING to CLAUSE OUTPUTS  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
genvar ih;
generate
  for (ih = 0; ih < MAX_SIZE; ih = ih + 1) begin
	       assign clause_out[ih]        = ff_clause[ih];
	       assign CNF_CLAUSE_OUT[ih][2]    = ff_CNF_CLAUSE[ih][2];
	       assign CNF_CLAUSE_OUT[ih][1]    = ff_CNF_CLAUSE[ih][1];
	       assign CNF_CLAUSE_OUT[ih][0]    = ff_CNF_CLAUSE[ih][0];
    	   assign  clause_valid_out[ih] = ff_clause_active[ih];
    	   assign clause_active_out[ih] = ff_clause_valid[ih];
  end
endgenerate
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ FLOP - Y  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 reg [MAX_SIZE-1:0] flop_y_mark_all_unit_clauses ;
 reg [MAX_SIZE-1:0] flop_y_bool_vals_of_marked_unit_clauses ;

 wire flop_y_reset;
 assign flop_y_reset = select_line;

genvar ij;
generate
  for (ij = 0; ij < MAX_SIZE; ij = ij + 1) begin
	assign mark_all_unit_clauses[ij]            = flop_y_mark_all_unit_clauses[ij];
	assign bool_vals_of_marked_unit_clauses[ij] = flop_y_bool_vals_of_marked_unit_clauses[ij];
  end
endgenerate
//***************************************************************************************************************************************************************************
//***************************************************   MODULE DESCRIPTION STARTS   *****************************************************************************************
//***************************************************************************************************************************************************************************
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   FLOPS THAT STORES CLAUSE INFORMATION   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
reg [2:0] 	ff_clause [0:MAX_SIZE-1];               // 256 Flip-Flops
reg [WIDTH-1:0] ff_CNF_CLAUSE [0:MAX_SIZE-1][0:2];      // 256 flops that stores real clauses and literals
reg       	ff_clause_active [0:MAX_SIZE-1];        // 256 flops that stores each clause active or not
reg       	ff_clause_valid [0:MAX_SIZE-1];	        // 256 flops that stores each clause valid or not
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   FLOPS THAT STORES LITERAL INFORMATION   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  reg [(WIDTH-1)-1:0] ff_literal_in [0:MAX_SIZE-1];                       	// all literals
  reg ff_literal_in_unit_lit_or_not [0:MAX_SIZE-1];				// whether they are unit/pure literals are not. Only used when loading pure literals
  reg ff_literal_in_bool_vals [0:MAX_SIZE-1];					// Boolean values of each literal
  reg ff_literal_in_literal_valid [0:MAX_SIZE-1];				// Valid literal or not.
  reg [WIDTH-1:0] ff_literal_updated_level [0:MAX_SIZE-1];                      //

  wire [(WIDTH-1)-1:0] mem_in [0:MAX_SIZE-1];                       	// all literals
  wire mem_in_unit_lit_or_not [0:MAX_SIZE-1];				// whether they are unit/pure literals are not. Only used when loading pure literals
  wire mem_in_bool_vals[0:MAX_SIZE-1];					// Boolean values of each literal
  wire mem_in_literal_valid[0:MAX_SIZE-1];
  wire mem_in_literal_updated_level [0:MAX_SIZE-1];
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   STALL-SHIFT LOGIC   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
reg [1:0] stall_counter;
wire select_line;
assign select_line = (stall_counter==3) & (!job_done);


// 
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     MUX's INFRONT OF FLOPS(which are having clause information)    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
reg [2:0] 	    mux_output_clause [0:MAX_SIZE-1]       ;
reg [WIDTH-1:0] mux_output_CNF_CLAUSE [0:MAX_SIZE-1]   ;
reg 		    mux_output_clause_active [0:MAX_SIZE-1];
reg 		    mux_output_clause_valid [0:MAX_SIZE-1] ;

integer m;
always@(*)
  begin
	for(m=0 ; m<MAX_SIZE ; m=m+1)
	  begin
		if(m==0)
		  begin
			mux_output_clause[m] 		    =   select_line ? combA_out_clause[MAX_SIZE-1] 			: ff_clause[m] ; 
			mux_output_CNF_CLAUSE[m][2]		=   select_line ? {combA_out_CNF_CLAUSE[MAX_SIZE-1][2]} 	: { ff_CNF_CLAUSE[m][2]};
			mux_output_CNF_CLAUSE[m][1]		=   select_line ? {combA_out_CNF_CLAUSE[MAX_SIZE-1][1]} 	: { ff_CNF_CLAUSE[m][1]};
			mux_output_CNF_CLAUSE[m][0]		=   select_line ? {combA_out_CNF_CLAUSE[MAX_SIZE-1][0]} 	: { ff_CNF_CLAUSE[m][0]};
			mux_output_clause_active[m]		=   select_line ? combA_out_clause_active[MAX_SIZE-1] 		: ff_clause_active[m] ;
			mux_output_clause_valid[m] 		=   select_line ? combA_out_clause_valid[MAX_SIZE-1] 		: ff_clause_valid[m] ; 
		  end
		else
		  begin
		 	mux_output_clause[m] 		    =   select_line ? combA_out_clause[m-1]     		 : ff_clause[m] ; 
			mux_output_CNF_CLAUSE[m][2]		=   select_line ? {combA_out_CNF_CLAUSE[m-1][2]} 	 : {ff_CNF_CLAUSE[m][2]} ;
			mux_output_CNF_CLAUSE[m][1]		=   select_line ? {combA_out_CNF_CLAUSE[m-1][1]} 	 : {ff_CNF_CLAUSE[m][1]} ;
			mux_output_CNF_CLAUSE[m][0]		=   select_line ? {combA_out_CNF_CLAUSE[m-1][0]} 	 : {ff_CNF_CLAUSE[m][0]} ;
			mux_output_clause_active[m]		=   select_line ? combA_out_clause_active[m-1] 	 	 : ff_clause_active[m] ;
			mux_output_clause_valid[m] 		=   select_line ? combA_out_clause_valid[m-1] 	 	 : ff_clause_valid[m] ;
		  end
	  end
  end

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
reg [WIDTH-1:0] rotation_count;
wire MAX_COUNT_REACHED;							     
assign MAX_COUNT_REACHED = rotation_count == (MAX_ROTATION-1);  
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
reg ff_y_atleast_one_unit_clause;
reg ff_z_atleast_one_unit_clause;
wire atleast_one_unit_clause;

reg [WIDTH-1:0] ff_x_unit_clauses 	  [0:MAX_SIZE-1] ;  // NEED TO PACK THIS. THIS IS THE INPUT TO COMB-C
reg 		ff_x_unit_clause_detected [0:MAX_SIZE-1] ;	
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     ALWAYS BLOCK STARTED    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
integer i;
always@(posedge clk)
  begin
	if(total_ckt_reset)
	  begin
		for(i = 0; i < MAX_SIZE; i=i+1)
	  	  begin
			ff_clause[i]                <= 0;
			ff_CNF_CLAUSE[i][2]            <= 0;
			ff_CNF_CLAUSE[i][1]            <= 0;
			ff_CNF_CLAUSE[i][0]            <= 0;
			ff_clause_active[i]         <= 0;
			ff_clause_valid[i]          <= 0;
	  	  end
		job_done <= 0;
		rotation_count <= 0;
		stall_counter <= 2'b00;
	  end
	else if(load_data_in)
	  begin
		for(i = 0; i < MAX_SIZE; i=i+1)
	  	  begin
			ff_clause[i]                   <= clause_in[i];
			ff_CNF_CLAUSE[i][2]            <= {CNF_CLAUSE[i][2]};
			ff_CNF_CLAUSE[i][1]            <= {CNF_CLAUSE[i][1]};
			ff_CNF_CLAUSE[i][0]            <= {CNF_CLAUSE[i][0]};
			ff_clause_active[i]            <= clause_active_in[i];
			ff_clause_valid[i]             <= clause_valid_in[i];
	  	  end
		stall_counter <= 2'b00;
	  end
	else if(MAX_COUNT_REACHED)
	  begin
		job_done <= 1;
	  end
	else
	  begin
		for(i = 0; i < MAX_SIZE; i=i+1)
	  	  begin
			ff_clause[i]                <= mux_output_clause[i];
			ff_CNF_CLAUSE[i][2]         <= mux_output_CNF_CLAUSE[i][2];
			ff_CNF_CLAUSE[i][1]         <= mux_output_CNF_CLAUSE[i][1];
			ff_CNF_CLAUSE[i][0]         <= mux_output_CNF_CLAUSE[i][0];
			ff_clause_active[i]         <= mux_output_clause_active[i];
			ff_clause_valid[i]          <= mux_output_clause_valid[i];
	  	  end

		stall_counter 	 <= stall_counter + 1;
		rotation_count   <= ff_z_atleast_one_unit_clause ? 0 :( (stall_counter==2'b11) ? rotation_count + 1 :  rotation_count ) ;
	  end

	
	ff_y_atleast_one_unit_clause <= flop_y_reset|total_ckt_reset ? 0 : atleast_one_unit_clause;
	ff_z_atleast_one_unit_clause <= flop_y_reset|total_ckt_reset ? 0 : ff_y_atleast_one_unit_clause;
	
	for(i=0;  i<MAX_SIZE;  i=i+1)
	  begin
			ff_literal_in[i] 			<= mem_in[i];
			ff_literal_in_unit_lit_or_not[i] 	<= mem_in_unit_lit_or_not[i];
			ff_literal_in_bool_vals[i] 		<= mem_in_bool_vals[i];
			ff_literal_in_literal_valid[i] 		<= mem_in_literal_valid[i];
	  end

	for(i=0;i<MAX_SIZE;i=i+1)
	  begin
		ff_x_unit_clauses[i]          <= flop_x_reset|total_ckt_reset ? 0 : combB_out_unit_clauses[i] ; 
		ff_x_unit_clause_detected[i]  <= flop_x_reset|total_ckt_reset ? 0 : combB_out_unit_clause_detected[i] ;
	  end

	for(i=0; i<MAX_SIZE; i=i+1)
	  begin
		flop_y_mark_all_unit_clauses[i]   	       <= flop_y_reset | total_ckt_reset ? 0 : temp_mark_unit_clauses_unpacked[i]   ;
		flop_y_bool_vals_of_marked_unit_clauses[i] <= flop_y_reset | total_ckt_reset ? 0 : temp_unit_lits_bool_vals_unpacked[i] ;
	  end
  end //################################################################################################################################# end of always block
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     ALWAYS BLOCK ENDED    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     COMB-A STARTED   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
wire [2:0] 	 combA_out_clause [0:MAX_SIZE-1]; 			// Outputs of COMB_CKT_A
wire [WIDTH-1:0] combA_out_CNF_CLAUSE [0:MAX_SIZE-1][0:2];		// Outputs of COMB_CKT_A
wire [WIDTH-1:0] combA_out_clause_updated_level [0:MAX_SIZE-1][0:2]; 	// Outputs of COMB_CKT_A
wire 		 combA_out_clause_active [0:MAX_SIZE-1]; 		// Outputs of COMB_CKT_A
wire 		 combA_out_clause_valid [0:MAX_SIZE-1]; 		// Outputs of COMB_CKT_A
//###################################################################################################################
//###########################   BY-PASSING THE INPUTS TO THE OUTPUTS OF COMB-A   ####################################
//###################################################################################################################
genvar n;
generate
    for (n = 0; n < MAX_SIZE; n = n + 1) begin : comb_assign
        assign combA_out_CNF_CLAUSE[n][2]   = ff_CNF_CLAUSE[n][2];
        assign combA_out_CNF_CLAUSE[n][1]   = ff_CNF_CLAUSE[n][1];
        assign combA_out_CNF_CLAUSE[n][0]   = ff_CNF_CLAUSE[n][0];
        assign combA_out_clause_valid[n] = ff_clause_valid[n];  
    end
endgenerate
//###################################################################################################################
//##################################    PACKING clause-info to SEND to COMB-A    ####################################
//###################################################################################################################

wire [3*WIDTH-1:0] ff_CNF_CLAUSE_packed_temp [0:MAX_SIZE-1];  // this is packed 

// remaining 3 signals no need to pack
genvar ab;
generate
  begin
	for(ab=0; ab<MAX_SIZE; ab=ab+1) begin
		assign ff_CNF_CLAUSE_packed_temp[ab] =              { ff_CNF_CLAUSE[jk][2],ff_CNF_CLAUSE[jk][1],ff_CNF_CLAUSE[jk][0] };
	end
  end
endgenerate
//###################################################################################################################
//##################################    INSTANTIATION of COMB-A    ##################################################
//###################################################################################################################
genvar jk;
generate
  begin
	for(jk = 0 ; jk < MAX_SIZE ; jk = jk+1)
	  begin
		CLAUSE_UPDATE_BASED_ON_UNIT_AND_PURE_LIT combA_inst(
		                            .current_level(current_level), 
									.clause_in(ff_clause[jk]), 
									.CNF_CLAUSE_packed(ff_CNF_CLAUSE_packed_temp[jk]),   
									.clause_active_in(ff_clause_active[jk]), 
									.clause_valid_in(ff_clause_valid[jk]), 
 
									.literal_in(ff_literal_in[jk]), 
									.bool_val_of_lit(ff_literal_in_bool_vals[jk]), 
									.unit_or_pure_literal(ff_literal_in_unit_lit_or_not[jk]),
									.literal_valid(ff_literal_in_literal_valid[jk]),
									 
									.clause_updated_level_out(combA_out_clause_updated_level_packed[jk]), 
									.clause_out(combA_out_clause[jk]), 
									.clause_active_out(combA_out_clause_active[jk])
							);
	  end
  end
endgenerate
//###################################################################################################################
//##################################    UNPACKING OUTPUTS from COMB-A    ############################################
//###################################################################################################################
wire [3*WIDTH-1:0] combA_out_clause_updated_level_packed [0:MAX_SIZE-1];

genvar ac, jc;
generate
  for (ac = 0; ac < MAX_SIZE; ac = ac + 1) begin
    for (jc = 0; jc < 3; jc = jc + 1) begin 
      assign combA_out_clause_updated_level[ac][jc] =
        combA_out_clause_updated_level_packed[ac][((jc+1)*WIDTH)-1 -: WIDTH];
    end
  end
endgenerate
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     COMB-A ENDED    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     COMB-B STARTED    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

//###################################################################################################################
//######################################    OUTPUTS from COMB-B    ##################################################
//###################################################################################################################
wire [WIDTH-1:0] combB_out_unit_clauses [0:MAX_SIZE-1]; // Outputs of COMB_CKT_B
wire 		 combB_out_unit_clause_detected [0:MAX_SIZE-1]; // Outputs of COMB_CKT_B
//###################################################################################################################
//######################################    PACKING THE INPUTS OF COMB-B    #########################################
//###################################################################################################################
wire [3*WIDTH-1:0] combB_in_CNF_CLAUSE_packed [0:MAX_SIZE-1];
genvar ae;
generate
  for (ae = 0; ae < MAX_SIZE; ae= ae + 1) begin  
    assign combB_in_CNF_CLAUSE_packed[ae] = {combA_out_CNF_CLAUSE[ae][2], combA_out_CNF_CLAUSE[ae][1], combA_out_CNF_CLAUSE[ae][0] };
  end
endgenerate
//###################################################################################################################
//######################################    INSTANTIATION OF COMB-B    ##############################################
//###################################################################################################################
genvar ad;
generate
  begin
	for(ad = 0 ; ad < MAX_SIZE ; ad = ad+1)
	  begin	
		FIND_UNIT_CLAUSE  combB_inst (  .CNF_clause(combB_in_CNF_CLAUSE_packed[ad]),
					 	.clause_in(combA_out_clause[ad]),
						.clause_active(combA_out_clause_active[ad]),
						.unit_clause(combB_out_unit_clauses[ad]), 
						.unit_clause_detected(combB_out_unit_clause_detected[ad]));
	  end
  end
endgenerate
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     COMB-B ENDED    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        FLOP-X       @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
wire flop_x_reset;
assign flop_x_reset = select_line;

wire [MAX_SIZE-1:0] unit_clauses_detected_packed_after_x;
genvar af;
generate
	for(af=0; af<MAX_SIZE-1;af=af+1) begin
		assign unit_clauses_detected_packed_after_x[af] = ff_x_unit_clause_detected[af];
	  end
endgenerate

assign atleast_one_unit_clause = (|unit_clauses_detected_packed_after_x);

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@       COMB - C      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

//###################################################################################################################
//##############################    PACKING THE FLOP-X outputs to send to COMB-C   ##################################
//###################################################################################################################
wire [MAX_SIZE*WIDTH-1:0] ff_x_unit_clauses_packed;
genvar ag;
generate
  for (ag = 0; ag < MAX_SIZE; ag = ag + 1) begin 
    assign ff_x_unit_clauses_packed[(ag+1)*WIDTH-1 -: WIDTH] = ff_x_unit_clauses[ag];
  end
endgenerate
//###################################################################################################################
//##############################    OUTPUT of COMB-C   ##############################################################
//###################################################################################################################
wire [MAX_SIZE-1:0]temp_mark_unit_clauses_packed  ;
wire [MAX_SIZE-1:0]temp_unit_lits_bool_vals_packed;
//###################################################################################################################
//##############################    INSTANTIATION OF COMB-C   #######################################################
//###################################################################################################################

MARK_UNIT_CLAUSE combC_inst( 	.unit_clauses_packed(ff_x_unit_clauses_packed), 
				.unit_clause_detected_packed(unit_clauses_detected_packed_after_x), 
				.mark_all_unit_clauses_packed(temp_mark_unit_clauses_packed), 
				.bool_val_of_unit_lits_packed(temp_unit_lits_bool_vals_packed)
);
//***************************************************************************************************************************************************************************
//***************************************************   MODULE DESCRIPTION ENDE   *****************************************************************************************
//***************************************************************************************************************************************************************************
endmodule
