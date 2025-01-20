`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   04:58:45 12/24/2024
// Design Name:   processor_top
// Module Name:   /home/ise/Documents/Xilinx Projects/hw7/processor_top/processor_top_tb.v
// Project Name:  processor_top
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: processor_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module processor_top_tb;

    // Inputs
    reg clk;
    reg resetn;
    reg [15:0] instruction_input;
    reg mem_write;

    // Outputs
    wire [15:0] PC_out;

    // Internal signals to observe
    wire [15:0] registers[15:0];

    // Instantiate the processor top module
    processor_top uut (
        .clk(clk),
        .resetn(resetn),
        .instruction_input(instruction_input),
        .mem_write(mem_write),
        .PC_out(PC_out)
    );

    // Assign internal registers for observation
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : observe_registers
            assign registers[i] = uut.RF_inst.general_purpose_registers[i];
        end
    endgenerate

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 ns clock period
    end

    // Testbench logic
    initial begin
        // Initialize inputs
          resetn = 0;
          instruction_input = 16'b0101_0110_0001_1001;
//        mem_write = 1; // Enable memory write initially

        // Load instructions into instruction memory during reset
//        instruction_input = 16'b0101_0110_0001_1001; // ADD R2, R1
//        #30;
//        instruction_input = 16'b0000_0001_1001_0011; // SUB R3, R1
//        #30;
//        instruction_input = 16'b0100_0100_0000_0101; // LOAD R4, [R5]
//        #30;
//        instruction_input = 16'b0100_0110_0100_0111; // STORE R6, [R7]
//        #30;
//        instruction_input = 16'b1100_0000_0000_0010; // Bcond EQ, #2
//        #30;
//        instruction_input = 16'b0100_0000_1100_1000; // Jcond R8
//        #30;
//        instruction_input = 16'b0000_0001_0101_0010; // ADD R2, R1
//        #30;

//        // Disable memory write after loading instructions
        mem_write = 0;
//
//        // Remove reset and start the processor
        #10;
        resetn = 1;

        // Allow the processor to execute the program
        #400;

        // Monitor PC and registers
        $monitor($time, " PC: %h", PC_out,
                 " R0: %h R1: %h R2: %h R3: %h R4: %h R5: %h R6: %h R7: %h",
                 registers[0], registers[1], registers[2], registers[3],
                 registers[4], registers[5], registers[6], registers[7],
                 " R8: %h R9: %h R10: %h R11: %h R12: %h R13: %h R14: %h R15: %h",
                 registers[8], registers[9], registers[10], registers[11],
                 registers[12], registers[13], registers[14], registers[15]);

        // Stop simulation
        #500;
        $stop;
    end

endmodule
