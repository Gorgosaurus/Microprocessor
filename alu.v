`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:49:14 12/22/2024 
// Design Name: 
// Module Name:    alu 
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

module alu (
    input wire [15:0] A, // Operand A
    input wire [15:0] B, // Operand B
    input wire [3:0] sel, // Operation selector
    input wire clk,
    input wire resetn,
	 input wire is_compare,
    output wire [15:0] S, // ALU result directly from adder chain
    output reg NEGATIVE_reg, // Negative flag
    output reg ZERO_reg, // Zero flag
    output reg CARRY_reg, // Carry flag
    output reg OVERFLOW_reg, // Overflow flag
	 output reg LOW_reg // Low flag
);

    wire [15:0] B_muxed;
    wire [15:0] Cin_sig;
    wire [15:0] C_out;
	 wire [15:0] S_out;
	 
    reg NEGATIVE;
    reg ZERO;
    reg CARRY;
    reg OVERFLOW;
	 reg LOW;

    // Negate B if subtraction is selected
    assign B_muxed = sel[0] ? ~B : B;

    // Full adder chain with mux integration
    generate
        genvar i;
        for (i = 0; i < 16; i = i + 1) begin
            if (i == 0) begin
                mux4_to_1 m4_to_1 (
                    .I0(1'b0),
                    .I1(1'b1),
                    .I2(sel[0]),
                    .I3(B[i]),
                    .sel(sel[2:1]),
                    .Out(Cin_sig[i])
                );
                full_adder fa (
                    .A(A[i]),
                    .B(B_muxed[i]),
                    .Cin(Cin_sig[i]),
                    .Sum(S_out[i]),
                    .Cout(C_out[i])
                );
            end else begin
                mux4_to_1 m4_to_1 (
                    .I0(1'b0),
                    .I1(1'b1),
                    .I2(C_out[i-1]),
                    .I3(B[i]),
                    .sel(sel[2:1]),
                    .Out(Cin_sig[i])
                );
                full_adder fa (
                    .A(A[i]),
                    .B(B_muxed[i]),
                    .Cin(Cin_sig[i]),
                    .Sum(S_out[i]),
                    .Cout(C_out[i])
                );
            end
        end
    endgenerate
	 
	 assign S[15:0] = sel[3] ? C_out[15:0] : S_out[15:0];

    // flags
	always @(*) begin
		case(sel)
			4'b0100 : begin // SUM
							CARRY = C_out[15];
							OVERFLOW = Cin_sig[15] ^ C_out[15];
							NEGATIVE = 0;
							ZERO = 0;
							LOW = 0;
						 end
			4'b0101 : begin 
							if (is_compare == 0) begin // SUB
								CARRY = ~C_out[15];
								OVERFLOW = Cin_sig[15] ^ C_out[15];
								LOW = 0;
								NEGATIVE = S_out[15] ^ C_out[15] ^ Cin_sig[15];
							end else begin // CMP
								LOW = ~C_out[15];
								NEGATIVE = S_out[15] ^ C_out[15] ^ Cin_sig[15];
								CARRY = 0;
								OVERFLOW = 0;
							end
							if (S == 0) begin // IF RESULT IS ZERO WHEN SUB/CMP
								ZERO = 1;
							end else begin
								ZERO = 0;
							end
						 end
			default: begin
							if (S == 0) begin
								ZERO = 1;
							end else begin
								ZERO = 0;
							end
							CARRY = 0;
							OVERFLOW = 0;
							LOW = 0;
							NEGATIVE = 0;
						end
		endcase
	end

    // Sequential block for reset
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            NEGATIVE_reg <= 0;
            ZERO_reg <= 0;
            CARRY_reg <= 0;
            OVERFLOW_reg <= 0;
				LOW_reg <= 0;
        end else begin
            NEGATIVE_reg <= NEGATIVE;
            ZERO_reg <= ZERO;
            CARRY_reg <= CARRY;
            OVERFLOW_reg <= OVERFLOW;
				LOW_reg <= LOW;
        end
    end

endmodule



