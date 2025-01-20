`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:12:29 12/22/2024 
// Design Name: 
// Module Name:    instruction_register 
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

module instruction_register (
    input wire clk,                // Clock signal
    input wire resetn,             // Active low reset
    input wire [15:0] instruction_in, // Instruction fetched from memory
    input wire load_enable,        // Enable signal to load instruction
    output reg [15:0] instruction_out // Output of the instruction register
);

    // Load instruction into the register or reset to zero
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            // Reset the instruction register to zero
            instruction_out <= 16'b0;
        end else if (load_enable) begin
            // Load the new instruction
            instruction_out <= instruction_in;
        end
    end

endmodule
