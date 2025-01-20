

module instruction_decoder (
    input wire [15:0] instruction, // Input instruction from instruction register
    output reg [3:0] opcode,       // Opcode (15-12 bits)
    output reg [3:0] rdest,        // Destination register (11-8 bits)
    output reg [3:0] rsrc,         // Source register
    output reg [3:0] imm_high,     // Immediate high (updated dynamically)
    output reg [3:0] imm_low,      // Immediate low (updated dynamically)
    output reg [3:0] alu_sel,      // ALU select signal (sel[3:0])
    output reg is_branch,          // is branch operation
    output reg is_jump,            // is jump operation
    output reg is_imm,             // Immediate vs. Register operation flag
	 output reg is_imm_signext,     // Immediate sign extend
	 output reg is_imm_zeroext,     // Immediate zero extend
	 output reg is_imm_8bit_ls_ext, // Immediate 8-bit logical left shift extend
    output reg is_cmp,             // Comparison operation flag
	 output reg wen_rf,             // RF write enb.
	 output reg [3:0] cond,         // cond. code from instruction for Bcond Jcond operations
	 output reg is_shifter,         // LSH/LSHI operations
	 output reg [4:0] shift_imm,    // LSHI operation shift amount signed value
	 output reg [2:0] wdata_sel_rf, // RF wdata select, which operation writes data to register file 
											  // 000 = ALU result
											  // 001 = MOV/MOVI operation
											  // 010 = LUI
											  // 011 = LSH/LSHI
											  // 100 = JAL (PC+1 written to Rlink)
	 output reg wen_mem,
	 output reg [7:0] displacement,
	 output reg is_jal
);

    always @(*) begin
        // Default values
        opcode = instruction[15:12];
        rdest = instruction[11:8];
        rsrc = instruction[3:0];
        imm_high = instruction[7:4];
        imm_low = instruction[3:0];
        alu_sel = 4'b1010;
        is_branch = 0;
        is_jump = 0;
        is_imm = 0; 
        is_cmp = 0; 
		  wen_rf = 0;
		  is_imm_signext = 0;
		  is_imm_zeroext = 0;
		  is_imm_8bit_ls_ext = 0;
		  cond = 0;
		  is_shifter = 0;
		  wdata_sel_rf = 3'b000;
		  wen_mem = 0;
		  displacement = 0;
		  is_jal = 0;
		  
        // Decode based on opcode
        case (opcode)
            4'b0000: begin // ALU Register-Register operations (ADD, SUB, CMP, etc. + MOV which is not ALU op.)
				    rsrc = instruction[3:0];
					 rdest = instruction[11:8];
                case (instruction[7:4])
                    4'b0101: begin alu_sel = 4'b0100; // ADD
						                 wen_rf = 1;
											  wdata_sel_rf = 3'b000;
						           end
                    4'b1001: begin alu_sel = 4'b0101; // SUB
						                 wen_rf = 1;
											  wdata_sel_rf = 3'b000;
						           end
                    4'b1011: begin
                                   alu_sel = 4'b0101; // CMP uses SUB operation
                                   is_cmp = 1;
								           wen_rf = 0;
                             end
                    4'b0001: begin alu_sel = 4'b1000; // AND
						                 wen_rf = 1;
											  wdata_sel_rf = 3'b000;
						           end
                    4'b0010: begin alu_sel = 4'b1010; // OR
						                 wen_rf = 1;
											  wdata_sel_rf = 3'b000;
						           end
                    4'b0011: begin alu_sel = 4'b0000; // XOR
						                 wen_rf = 1;
											  wdata_sel_rf = 3'b000;
						           end
						  4'b1101: begin                    // MOV
									        wen_rf = 1;
											  wdata_sel_rf = 3'b001;
						           end
                    default: begin alu_sel = 4'b1010; // OR
						                 wen_rf = 1;
											  wdata_sel_rf = 3'b000;
						           end
                endcase
					 
            end
            4'b0101: begin // ADDI
                is_imm = 1; // Immediate operation
                imm_high = instruction[7:4]; // Immediate high part
                imm_low = instruction[3:0]; // Immediate low part
                is_imm_signext = 1;
					 alu_sel = 4'b0100; // ADD
					 wen_rf = 1;
					 wdata_sel_rf = 3'b000;
            end
				4'b0001: begin // ANDI
                is_imm = 1; // Immediate operation
                imm_high = instruction[7:4]; // Immediate high part
                imm_low = instruction[3:0]; // Immediate low part
                is_imm_zeroext = 1;
					 alu_sel = 4'b1000; // AND
					 wen_rf = 1;
					 wdata_sel_rf = 3'b000;
            end
				4'b1001: begin // SUBI
                is_imm = 1; // Immediate operation
                imm_high = instruction[7:4]; // Immediate high part
                imm_low = instruction[3:0]; // Immediate low part
                is_imm_signext = 1;
					 alu_sel = 4'b0101; // SUB
					 wen_rf = 1;
					 wdata_sel_rf = 3'b000;
            end
				4'b1101: begin // MOVI
                is_imm = 1; // Immediate operation
                imm_high = instruction[7:4]; // Immediate high part
                imm_low = instruction[3:0]; // Immediate low part
                is_imm_zeroext = 1;
					 wen_rf = 1;
					 wdata_sel_rf = 3'b001;
            end
				4'b0010: begin // ORI
                is_imm = 1; // Immediate operation
                imm_high = instruction[7:4]; // Immediate high part
                imm_low = instruction[3:0]; // Immediate low part
                is_imm_zeroext = 1;
					 alu_sel = 4'b1010; // OR
					 wen_rf = 1;
					 wdata_sel_rf = 3'b000;
            end
				4'b0011: begin // XORI
                is_imm = 1; // Immediate operation
                imm_high = instruction[7:4]; // Immediate high part
                imm_low = instruction[3:0]; // Immediate low part
                is_imm_zeroext = 1;
					 alu_sel = 4'b0000; // XOR
					 wen_rf = 1;
					 wdata_sel_rf = 3'b000;
            end
				4'b1011: begin // CMPI
                is_imm = 1; // Immediate operation
                imm_high = instruction[7:4]; // Immediate high part
                imm_low = instruction[3:0]; // Immediate low part
                is_imm_signext = 1;
					 alu_sel = 4'b0101; // CMP
					 is_cmp = 1;
            end
            4'b1111: begin // Load Upper Immediate (LUI)
                is_imm = 1; // Immediate operation
                imm_high = instruction[7:4];
                imm_low = instruction[3:0];
					 is_imm_8bit_ls_ext = 1;
					 wen_rf = 1;
					 wdata_sel_rf = 3'b010;
            end
            4'b1000: begin // Logical Shift operations
					 is_shifter = 1;
					 wen_rf = 1;
					 wdata_sel_rf = 3'b011;
                if (instruction[7:4] == 4'b0100) begin // LSH
                    rsrc = instruction[3:0];
						  rdest = instruction[11:8];
                end else if (instruction[7:4] == 4'b0000 || instruction[7:4] == 4'b0001) begin // LSHI
                    is_imm = 1;
						  shift_imm = instruction[4:0];
                end
            end
            4'b0100: begin // Memory operations (LOAD, STOR) or Jcond - JAL
                if (instruction[7:4] == 4'b0000) begin // LOAD
                    wdata_sel_rf = 3'b101;
						  wen_rf = 1;
                end else if (instruction[7:4] == 4'b0100) begin // STOR
                    rsrc = instruction[3:0];
						  rdest = instruction[11:8];
						  wen_mem = 1;
                end else if (instruction[7:4] == 4'b1000) begin // JAL
						wdata_sel_rf = 3'b100;
						is_jal = 1;
					 end else if (instruction[7:4] == 4'b1100) begin // Jcond
						cond = instruction[11:8];
						is_jump = 1;
					 end
            end
            4'b1100: begin // Branch instructions (Bcond)
                is_branch = 1;
					 cond = instruction[11:8];
					 displacement = instruction[7:0];
            end
            
        endcase
    end

endmodule

