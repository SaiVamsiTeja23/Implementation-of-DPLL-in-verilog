`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2025 00:25:58
// Design Name: 
// Module Name: check_random_literal
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
/////////////////////////////////////////////////////////////////////////////////
//1. Generate Random Value
//2. Check Unassigned literal
//3. if unassigned choose it else go to STEP-1
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
module check_random_literal #(parameter WIDTH=8, parameter N=256) (
	input clk,
	input rst,
	input ena,
	input [N-1:0] lit_assigned,
	
	output reg [WIDTH-1:0] rand_val_out,
	output reg valid_out
	
);
wire [WIDTH-1:0] prev_rand_val;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign prev_rand_val = rand_val_out;

wire [WIDTH-1:0] new_rand_val;
GENERATE_RANDOM_VALUE #(.WIDTH(WIDTH)) gen_rand_val_inst1 (.prev_rand_val(prev_rand_val), .rand_val(new_rand_val));

wire [WIDTH-1:0] mux_rand_val;
assign mux_rand_val = ena ? new_rand_val : prev_rand_val;

always@(posedge clk)
  begin
	if(rst)
	  begin
		rand_val_out <= 1;
		valid_out    <= ~lit_assigned[1];// why ?
	  end
	else
	  begin
		rand_val_out <= mux_rand_val;
		valid_out    <= ~lit_assigned[mux_rand_val] & ena;
	  end
  end
endmodule
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
module GENERATE_RANDOM_VALUE #(parameter WIDTH=8)
(
	input [WIDTH-1:0] prev_rand_val,
	output [WIDTH-1:0] rand_val
);

wire feedback;
 assign feedback = 
        (WIDTH == 3)  ? prev_rand_val[2] ^ prev_rand_val[0] :
        (WIDTH == 4)  ? prev_rand_val[3] ^ prev_rand_val[0] :
        (WIDTH == 5)  ? prev_rand_val[4] ^ prev_rand_val[2] :
        (WIDTH == 6)  ? prev_rand_val[5] ^ prev_rand_val[0] :
        (WIDTH == 7)  ? prev_rand_val[6] ^ prev_rand_val[0] :
        (WIDTH == 8)  ? prev_rand_val[7] ^ prev_rand_val[5] ^ prev_rand_val[4] ^ prev_rand_val[3] :
        (WIDTH == 9)  ? prev_rand_val[8] ^ prev_rand_val[4] : (prev_rand_val[9] ^ prev_rand_val[6]) ;  		
assign rand_val = {prev_rand_val[WIDTH-2:0] , feedback} ;
endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////