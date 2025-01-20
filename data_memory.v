
`timescale 1ns / 1ps

module spblockram (
    input wire clk,
    input wire mem_write,
    input wire [4:0] address, // Memory address
    input wire [15:0] write_data, // Data to write
    output [15:0] read_data // Data read
);

    // Memory array (32 words of 16-bit each)
    reg [15:0] RAM [0:31];
	 reg [4:0] read_addr;
	 
			initial begin
				 RAM[0] = 16'b0000_0001_1001_0011; // SUB R3, R1
				 RAM[1] = 16'b0101_0110_0001_1001; // ADDI #25, R6
				 RAM[2] = 16'b0100_0100_0000_0101; // LOAD R4, [R5]
				 RAM[3] = 16'b0100_0010_0100_0111; // STORE R2, [R7]
				 RAM[4] = 16'b0000_0000_0101_0110; // ADD R0, R6
				 RAM[5] = 16'b0101_0010_0000_0011; // ADDI #3, R2
				 RAM[6] = 16'b0000_0110_1001_0010; // SUB R6, R2
				 RAM[7] = 16'b0000_0100_0001_0110; // AND R4, R6
				 RAM[8] = 16'b0000_0000_0010_0010; // OR R0, R2
				 RAM[9] = 16'b0000_0100_0011_0010; // XOR R6, R2
				 RAM[10] = 16'b0000_0101_1101_0000; // MOV R5, R0
				 RAM[11] = 16'b1101_1100_0000_1100; // MOVI #12, R12
				 RAM[12] = 16'b1000_0000_0000_0001; // LSHI #1, R0
				 RAM[13] = 16'b1111_1110_0011_1100; // LUI #60, R14
				 RAM[14] = 16'b0100_0101_0010_0100; // LOAD R4, [R2]
				 RAM[15] = 16'b0100_0010_0100_0011; // STORE R3, [R4]
			end
		
    // Write operation (sequential)
    always @(posedge clk) begin
        if (mem_write) begin
            RAM[address] <= write_data;
        end
		  read_addr <= address;
    end
	 
	 assign read_data = RAM[read_addr];

endmodule



