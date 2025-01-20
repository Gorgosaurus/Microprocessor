`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:02:50 12/22/2024 
// Design Name: 
// Module Name:    register_file 
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

module register_file (
    input wire clk,                // Clock signal
    input wire resetn,             // Active low asynchronous reset
    input wire [3:0] read_addr1,   // First read address (4-bit, 16 registers)
    input wire [3:0] read_addr2,   // Second read address (4-bit, 16 registers)
    input wire [3:0] write_addr,   // Write address (4-bit, 16 registers)
    input wire [15:0] write_data,  // Data to write (16-bit)
    input wire write_enable,       // Write enable signal
    output reg [15:0] read_data1,  // First read data (16-bit)
    output reg [15:0] read_data2   // Second read data (16-bit)
);

    // Definition of 16 registers, each 16-bit wide
    reg [15:0] general_purpose_registers [15:0];

    // Read operation (combinational logic)
    always @(*) begin
        read_data1 = general_purpose_registers[read_addr1];
        read_data2 = general_purpose_registers[read_addr2];
    end
	 
	 integer i;
    // Write operation (positive edge-triggered clock)
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            // Reset: clear all registers to zero
            for (i = 0; i < 16; i = i + 1) begin
                general_purpose_registers[i] <= 16'b0;
            end
        end else if (write_enable) begin
            // Write operation: write data to the specified address
            general_purpose_registers[write_addr] <= write_data;
        end
    end

endmodule

