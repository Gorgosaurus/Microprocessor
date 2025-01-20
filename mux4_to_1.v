`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:15:39 12/22/2024 
// Design Name: 
// Module Name:    mux4_to_1 
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
module mux4_to_1 (
    input wire I0,
    input wire I1,
    input wire I2,
    input wire I3,
    input wire [1:0] sel,
    output reg Out
);
    always @(*) begin
        case (sel)
            2'b00: Out = I0;
            2'b01: Out = I1;
            2'b10: Out = I2;
            2'b11: Out = I3;
				default: Out = I0;
        endcase
    end
endmodule
