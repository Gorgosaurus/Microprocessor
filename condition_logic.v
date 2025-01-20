`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:15:05 12/23/2024 
// Design Name: 
// Module Name:    condition_logic 
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

`timescale 1ns / 1ps

module condition_logic (
    input wire [3:0] condition_code, // Condition field from instruction
    input wire negative_flag,
    input wire zero_flag,
    input wire carry_flag,
    input wire overflow_flag,
    output reg condition_met // Output: condition satisfied or not
);

    always @(*) begin
        case (condition_code)
            4'b0000: condition_met = zero_flag; // EQ: Equal
            4'b0001: condition_met = ~zero_flag; // NE: Not Equal
            4'b0010: condition_met = carry_flag; // CS: Carry Set
            4'b0011: condition_met = ~carry_flag; // CC: Carry Clear
            4'b0100: condition_met = negative_flag; // MI: Negative
            4'b0101: condition_met = ~negative_flag; // PL: Positive or Zero
            4'b0110: condition_met = overflow_flag; // VS: Overflow
            4'b0111: condition_met = ~overflow_flag; // VC: No Overflow
            4'b1000: condition_met = carry_flag & ~zero_flag; // HI: Higher
            4'b1001: condition_met = ~carry_flag | zero_flag; // LS: Lower or Same
            4'b1010: condition_met = negative_flag == overflow_flag; // GE: Greater or Equal
            4'b1011: condition_met = negative_flag != overflow_flag; // LT: Less Than
            4'b1100: condition_met = ~zero_flag & (negative_flag == overflow_flag); // GT: Greater Than
            4'b1101: condition_met = zero_flag | (negative_flag != overflow_flag); // LE: Less or Equal
            4'b1110: condition_met = 1'b1; // AL: Always
            default: condition_met = 1'b0; // Default to not met
        endcase
    end

endmodule
