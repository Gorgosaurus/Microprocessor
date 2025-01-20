`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:09:27 12/24/2024 
// Design Name: 
// Module Name:    shifter 
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


module shifter(
    input wire [15:0] data_in,        // 16-bit input data
    input wire [4:0] shift,           // Signed 5-bit shift amount (2's complement)
    output reg [15:0] data_out        // 16-bit shifted output
);

    wire [15:0] left_shifted;         // Result of left shift
    wire [15:0] right_shifted;        // Result of right shift
    wire signed [4:0] signed_shift = shift; // Interpreting shift as signed

    // Perform left and right shifts
    assign left_shifted = data_in << signed_shift;
    assign right_shifted = data_in >> -signed_shift;

    always @(*) begin
        if (signed_shift >= 0) begin
            // Positive shift: perform left shift
            data_out = left_shifted;
        end else begin
            // Negative shift: perform right shift
            data_out = right_shifted;
        end
    end

endmodule

