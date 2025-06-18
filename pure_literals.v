`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.06.2025 23:07:13
// Design Name: 
// Module Name: pure_literals
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
module pure_literals #(parameter WIDTH=8,parameter OUT_SIZE=256) (
	input reset,
	input [WIDTH:0] literal_in,
	input literal_in_reduced_form,
	input clk,
	input inputs_came,

	output valid_out,
	output [OUT_SIZE-1:0] ff_pure_literal
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
////////////////////////// ALL register ////////////////////////////////////
reg [OUT_SIZE-1:0] ff_store_pos;
reg [OUT_SIZE-1:0] ff_store_neg;


integer i;
always@(posedge clk)
  begin
	if(reset)
	  begin
		for(i=0; i<OUT_SIZE; i=i+1)
		  begin
			ff_store_pos[i]    <= 0;
			ff_store_neg[i]    <= 0;
			ff_pure_literal[i] <= 0;
		  end
	  end
	else
	  begin
		for(i=0; i<OUT_SIZE; i=i+1)
		  begin
			ff_store_pos[i]    <= literal_in_reduced_form ? (demux1to2[0] ? demux1to2[0] : ff_store_pos[i]) : ff_store_pos[i];
			ff_store_neg[i]    <= literal_in_reduced_form ? (demux1to2[1] ? demux1to2[1] : ff_store_neg[i]) : ff_store_neg[i];
			ff_pure_literal[i] <= ~(ff_store_pos[i] & ff_store_neg[i]);
		  end
	  end

  end

assign valid_out = inputs_came;  // WHEN THE COUNTER REACHED MAXIMUM VALUE, WE SET VALID_OUT TO HIGH

endmodule
