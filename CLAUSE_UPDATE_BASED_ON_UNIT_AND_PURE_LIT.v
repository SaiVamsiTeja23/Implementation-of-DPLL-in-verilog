`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.06.2025 16:39:14
// Design Name: 
// Module Name: CLAUSE_UPDATE_BASED_ON_UNIT_AND_PURE_LIT
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

module CLAUSE_UPDATE_BASED_ON_UNIT_AND_PURE_LIT #(parameter WIDTH=9, parameter OUT_SIZE=256) (
  
  input [WIDTH-1:0]current_level,

  input [2:0]clause_in,
  input [3*WIDTH-1:0]CNF_CLAUSE_packed,
  input clause_active_in,
  input clause_valid_in,

  input [WIDTH-2:0]literal_in,
  input bool_val_of_lit,
  input unit_or_pure_literal,
  input literal_valid,
 
  
  output reg [2:0]clause_out,
  output reg clause_active_out
  
);
//##########################################################################################################
//############################################### UNPACKING INPUTS #########################################
//##########################################################################################################

  
  wire [WIDTH-1:0] CNF_CLAUSE[2:0];
  wire [WIDTH-1:0] clause_updated_level_in[2:0];

genvar i;
generate
  for (i = 0; i < 3; i = i + 1) begin : unpack_arrays
    assign CNF_CLAUSE[i]              = CNF_CLAUSE_packed[(i+1)*WIDTH-1 -: WIDTH];

  end
endgenerate

//##########################################################################################################
//############################################### PACKING OUTPUTS #########################################
//##########################################################################################################
  

  wire [WIDTH-1:0]clause_updated_level_out[0:2];
assign clause_updated_level_out_packed = { clause_updated_level_out[2],   clause_updated_level_out[1],    clause_updated_level_out[0]};

//##########################################################################################################
  wire [WIDTH-1:0] neg_literal;
  wire [WIDTH-1:0] literal;

assign literal = {1'b0,literal_in};

  wire [2:0] temp_pos;
  wire [2:0] temp_neg;

  assign temp_pos[2] = literal == CNF_CLAUSE[2];
  assign temp_pos[1] = literal == CNF_CLAUSE[1];
  assign temp_pos[0] = literal == CNF_CLAUSE[0];

  assign temp_neg[2] = neg_literal == CNF_CLAUSE[2];
  assign temp_neg[1] = neg_literal == CNF_CLAUSE[1];
  assign temp_neg[0] = neg_literal == CNF_CLAUSE[0];

  assign neg_literal = -literal;
 
  always@(*)
    begin
	if(clause_active_in & clause_valid_in & unit_or_pure_literal & literal_valid)
	  begin
		if(|temp_pos)
		  begin
			if(bool_val_of_lit)
			  begin
				clause_out		<= 3'b000;
				clause_active_out	<= 0;
			  end
			else
			  begin
				//...
				clause_out[2]   <=  temp_pos[2] ? 0 : clause_in[2]; 
                        	clause_out[1]   <=  temp_pos[1] ? 0 : clause_in[1]; 
				clause_out[0]   <=  temp_pos[0] ? 0 : clause_in[0];
				
				clause_active_out  <= clause_active_in;
			  end	
		  end
		else if(|temp_neg)
		  begin
			if(bool_val_of_lit)
			  begin
				clause_out[2]   <=  temp_neg[2] ? 0 : clause_in[2]; 
                        	clause_out[1]   <=  temp_neg[1] ? 0 : clause_in[1]; 
				clause_out[0]   <=  temp_neg[0] ? 0 : clause_in[0];

				clause_active_out  <=  clause_active_in;
			  end
			else
			  begin
				clause_out		<= 3'b000;
				clause_active_out  	<= 0;
			  end
			
		  end
		else
		  begin
			clause_out               <= clause_in;
			clause_active_out  	 <= clause_active_in;
		  end
	  end
	else
	  begin
		clause_out               <= clause_in;
		clause_active_out  	 <= clause_active_in;
	  end
    end


endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////  the above outputs will be given CHECK_UNIT_CLAUSE block  //////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

