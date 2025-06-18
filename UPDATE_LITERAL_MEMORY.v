`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.06.2025 14:26:54
// Design Name: 
// Module Name: UPDATE_LITERAL_MEMORY
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


// UPDATE THE RESULTS MODULE

module UPDATE_RESULTS_MEMORY #(parameter WIDTH=9, parameter MAX_LITERALS = 256) (

 	input [WIDTH-2:0] choosen_lit,
 	input choosen_lit_bool_val,
	input [WIDTH-1:0] current_level,
	input [MAX_LITERALS*WIDTH-1:0]literal_updated_level_in_packed,

	// literals got updated at level==current_level will be unassigned
	input update_based_on_re_update, 
	input update_based_on_choosen_lit,
	input update_based_on_sliding_window,
	input update_based_on_pure_lit_module,

 	input [MAX_LITERALS-1:0] literal_assigned_in_pure_lit_mod,      //pure literal or not
 	input [MAX_LITERALS-1:0] literal_bool_val_in_pure_lit_mod,      //pure_lit bool_val

 	input [MAX_LITERALS-1:0] literal_assigned_in_sliding_window, 	//sliding window yes or not
 	input [MAX_LITERALS-1:0] literal_bool_val_in_sliding_window, 	// sliding window bool value
	input [MAX_LITERALS*WIDTH-1:0] literal_updated_level_in_sliding_window_packed,

	
	input [MAX_LITERALS-1:0] literal_assigned_in_from_lit_mem,
	input [MAX_LITERALS-1:0] literal_bool_val_in_from_lit_mem,
	input [MAX_LITERALS*WIDTH-1:0] literal_updated_level_in_from_lit_mem_packed,
	
	output reg [MAX_LITERALS-1:0] literal_assigned_out,
	output reg [MAX_LITERALS-1:0] literal_bool_val_out,
	output reg [MAX_LITERALS*WIDTH-1:0] literal_updated_level_out_packed
);

wire [WIDTH-1:0] literal_updated_level_in_sliding_window_unpacked [0:MAX_LITERALS-1];
genvar j;
generate
    for (j = 0; j < MAX_LITERALS; j = j + 1) begin 
        assign literal_updated_level_in_sliding_window_unpacked[j] = literal_updated_level_in_sliding_window_packed[(j+1)*WIDTH-1 -: WIDTH];
    end
endgenerate
//................................................................................................................................
wire [WIDTH-1:0] literal_updated_level_in_from_lit_mem_unpacked [0:MAX_LITERALS-1];
genvar k;
generate
    for (k = 0; k < MAX_LITERALS; k = k + 1) begin 
        assign literal_updated_level_in_from_lit_mem_unpacked[k] = literal_updated_level_in_from_lit_mem_packed[(k+1)*WIDTH-1 -: WIDTH];
    end
endgenerate
//................................................................................................................................
wire [WIDTH-1:0]literal_updated_level_in_unpacked [0:MAX_LITERALS-1];
genvar mn;
generate
  for (mn = 0; mn < MAX_LITERALS; mn = mn + 1) begin : unpack_loop
    assign literal_updated_level_in_unpacked[mn] = literal_updated_level_in_packed[(mn+1)*WIDTH-1 -: WIDTH];
  end
endgenerate
//................................................................................................................................
wire level_matched [0:MAX_LITERALS-1];
genvar g;
generate
	for (g = 0; g < MAX_LITERALS; g = g + 1) begin 
          assign level_matched[g] = literal_updated_level_in_unpacked[g] == current_level;
    end
endgenerate
//................................................................................................................................

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////  	   4 to 3 Decoder       ////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//###########################################################################################
//##### s : sliding_window  ;  p : pure_literals  ; c :  choosen_lit  ; r : re_update  ######
//###########################################################################################

//  { s,p,c,r } = {0,0,0,0} // STORE OLD VALUES
//  { s,p,c,r } = {1,0,0,0} // UPDATE BASED ON SLIDING WINDOW VALUES
//  { s,p,c,r } = {0,1,0,0} // UPDATE BASED ON PURE_LITERAL_MODULE VALUES
//  { s,p,c,r } = {0,0,1,0} // UPDATE BASED ON CHOOSEN_LITERAL
//  { s,p,c,r } = {0,0,0,1} // RE_UPDATE THE LITERAL MEMORY

wire x,y,z;

assign x = update_based_on_re_update;
assign y = update_based_on_pure_lit_module | update_based_on_sliding_window ;
assign z = update_based_on_pure_lit_module | update_based_on_choosen_lit ;

wire [2:0]select_line;
assign select_line = {x,y,z};

// since we cannot assign to wire literal_updated_level_out_unpacked, we defined same variable as 'reg' with suffix 'reg_' added to the variable name
reg [WIDTH-1:0] reg_literal_updated_level_out_unpacked [0:MAX_LITERALS-1];
integer i;
always@(*)
  begin
  	case(select_line)
	  3'd0:	begin   // store old values of memory
			for(i=0 ; i<MAX_LITERALS; i=i+1)
			  begin
				literal_assigned_out[i]  		<= literal_assigned_in_from_lit_mem[i];
				literal_bool_val_out[i]  		<= literal_bool_val_in_from_lit_mem[i];
				reg_literal_updated_level_out_unpacked[i] 	<= literal_updated_level_in_from_lit_mem_unpacked[i];
			  end
		end
	  3'd1:begin   // UPDATE BASED ON CHOOSEN LITERAL
			for(i=0 ; i<MAX_LITERALS; i=i+1)
			  begin
				literal_assigned_out[i]  		<= (i==choosen_lit) ? 1'b1 		   : literal_assigned_in_from_lit_mem[i];
				literal_bool_val_out[i]  		<= (i==choosen_lit) ? choosen_lit_bool_val : literal_bool_val_in_from_lit_mem[i];
				reg_literal_updated_level_out_unpacked[i] 	<= (i==choosen_lit) ? current_level 	   : literal_updated_level_in_from_lit_mem_unpacked[i];
			  end
		end
	  3'd2:begin   // UPDATE BASED ON SLIDING_WINDOW
			for(i=0 ; i<MAX_LITERALS; i=i+1)
			  begin
				literal_assigned_out[i]  		<= literal_assigned_in_sliding_window[i];
				literal_bool_val_out[i]  		<= literal_bool_val_in_sliding_window[i];
				reg_literal_updated_level_out_unpacked[i] 	<= literal_updated_level_in_sliding_window_unpacked[i];
			  end
		end
	  3'd3:begin   // UPDATE BASED ON PURE_LITERALS
			for(i=0 ; i<MAX_LITERALS; i=i+1)
			  begin
				literal_assigned_out[i]  		<= literal_assigned_in_pure_lit_mod[i] | literal_assigned_in_from_lit_mem[i] ;
				literal_bool_val_out[i]  		<= literal_assigned_in_pure_lit_mod[i] ? literal_bool_val_in_pure_lit_mod[i] : literal_bool_val_in_from_lit_mem[i];
				reg_literal_updated_level_out_unpacked[i] 	<= literal_assigned_in_pure_lit_mod[i] ? current_level : literal_updated_level_in_from_lit_mem_unpacked[i];
			  end
		end
	  3'd4:begin   // UPDATE BASED ON RE_UPDATE_MODULE
			for(i=0 ; i<MAX_LITERALS; i=i+1)
			  begin
				literal_assigned_out[i]  		<= level_matched[i] ? 0 : literal_assigned_in_from_lit_mem[i];
				literal_bool_val_out[i]  		<= level_matched[i] ? 0 : literal_bool_val_in_from_lit_mem[i];
				reg_literal_updated_level_out_unpacked[i] 	<= level_matched[i] ? 0 : literal_updated_level_in_from_lit_mem_unpacked[i];
			  end
		end

	  default : begin   // GENERALLY IT WONT OCCUR except start_state
			for(i=0 ; i<MAX_LITERALS; i=i+1)
			  begin
				literal_assigned_out[i]  		<= 0;
				literal_bool_val_out[i]  		<= 0;
				reg_literal_updated_level_out_unpacked[i] 	<= 0;
			  end
		end
	endcase
  end
  
// PACKING THE LITERAL_UPDATED_LEVEL_OUT
integer h;
always @(*) begin
    for (h = 0; h < MAX_LITERALS; h = h + 1) begin
        literal_updated_level_out_packed[(h+1)*WIDTH-1 -: WIDTH] = reg_literal_updated_level_out_unpacked[h];
    end
end

endmodule
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@       MODULE ENDED       @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
