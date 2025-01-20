`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    02:08:42 12/24/2024 
// Design Name: 
// Module Name:    program_counter 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module program_counter(
    input wire clk,
    input wire resetn,
    input wire [3:0] cond,
    input wire is_branch,
    input wire is_jump,
    input wire is_jal,
    input wire [7:0] disp,
    input wire [15:0] jump_target,
    input wire PC_enb,
	 input wire negative_flag,
	 input wire zero_flag,
	 input wire carry_flag,
	 input wire overflow_flag,
    output wire [15:0] PC
    );
	
	wire condition_met;
	wire jump;
	wire branch;
	wire signed [15:0] disp_ext;
	reg [15:0] PC_reg;
	wire [15:0] next_PC;
	wire [15:0] adder_out;
	
	condition_logic inst_cl (
		 .condition_code(cond), 
		 .negative_flag(negative_flag), 
		 .zero_flag(zero_flag), 
		 .carry_flag(carry_flag), 
		 .overflow_flag(overflow_flag), 
		 .condition_met(condition_met)
    );
	
	assign jump = (is_jal) ? 1 :
	              (is_jump) ? condition_met : 0;
	assign branch = (is_branch) ? condition_met : 0;
	assign disp_ext = {{8{disp[7]}}, disp}; // Sign extension
	assign adder_in = (branch) ? disp_ext : 1;
	assign adder_out = adder_in + PC_reg;
	assign next_PC = (jump) ? jump_target : adder_out;
	
	always@(posedge clk,negedge resetn) begin
		if (~resetn) begin
			PC_reg <= 0;
		end else if(PC_enb == 1) begin
			PC_reg <= next_PC;
		end	
	end
	
	assign PC = PC_reg;
	
endmodule
