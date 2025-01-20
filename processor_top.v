
`timescale 1ns / 1ps

module processor_top (
    input wire clk,
    input wire resetn,
	 input wire [15:0] instruction_input,
	 input wire mem_write,
	 output wire [15:0] PC_out
);

	wire pc_enable;
	wire load_enable;
	wire wen_rf_wb_state;
	wire wen_rf_sync;
	wire wen_rf;
	wire [15:0] instruction;
	wire [15:0] instruction_in;
	wire [3:0] opcode;
	wire [3:0] rdest;
	wire [3:0] rsrc;
	wire [3:0] imm_high;
	wire [3:0] imm_low;
	wire [3:0] alu_sel;
	wire is_branch;
	wire is_jump;
	wire is_jal;
	wire [7:0] disp;
	wire [15:0] read_data1;
	wire [15:0] read_data2;
	wire negative_flag;
	wire zero_flag;
	wire carry_flag;
	wire overflow_flag;
	wire low_flag;
	wire [15:0] PC;
	wire is_imm;
	wire [7:0] imm;
	reg [15:0] imm_ext;
	wire is_cmp;
	wire [3:0] cond;
	wire [4:0] shift_imm;
	wire [4:0] shift;
	wire [15:0] shifter_out;
	wire [2:0] wdata_sel_rf;
	wire [15:0] mem_data;
	wire [15:0] B_operand;
	wire [15:0] alu_result;
	reg [15:0] write_data;
	
	
	
	assign imm = {imm_high,imm_low};
	assign wen_rf_sync = wen_rf_wb_state && wen_rf;
	
    // Control Unit
		control_unit controller (
			 .clk(clk), 
			 .resetn(resetn), 
			 .load_enable(load_enable), 
			 .pc_enable(pc_enable), 
			 .wen_rf_wb_state(wen_rf_wb_state)
			 );
	

      // Program Counter
		program_counter pc_inst (
			 .clk(clk), 
			 .resetn(resetn), 
			 .cond(cond), 
			 .is_branch(is_branch), 
			 .is_jump(is_jump), 
			 .is_jal(is_jal), 
			 .disp(disp), 
			 .jump_target(read_data2), 
			 .PC_enb(pc_enable), 
			 .negative_flag(negative_flag), 
			 .zero_flag(zero_flag), 
			 .carry_flag(carry_flag), 
			 .overflow_flag(overflow_flag), 
			 .PC(PC)
			 );
			 
	assign PC_out = PC;
	
    // Instruction Register
    instruction_register IR_inst (
			.clk(clk), 
			.resetn(resetn), 
			.instruction_in(instruction_in), 
			.load_enable(load_enable), 
			.instruction_out(instruction)
    );

		instruction_decoder instr_decoder (
			 .instruction(instruction), 
			 .opcode(opcode), 
			 .rdest(rdest), 
			 .rsrc(rsrc), 
			 .imm_high(imm_high), 
			 .imm_low(imm_low), 
			 .alu_sel(alu_sel), 
			 .is_branch(is_branch), 
			 .is_jump(is_jump), 
			 .is_imm(is_imm), 
			 .is_imm_signext(is_imm_signext), 
			 .is_imm_zeroext(is_imm_zeroext), 
			 .is_imm_8bit_ls_ext(is_imm_8bit_ls_ext), 
			 .is_cmp(is_cmp), 
			 .wen_rf(wen_rf), 
			 .cond(cond), 
			 .is_shifter(), 
			 .shift_imm(shift_imm), 
			 .wdata_sel_rf(wdata_sel_rf), 
			 .wen_mem(wen_mem), 
			 .displacement(disp), 
			 .is_jal(is_jal)
			 );

	always@(*) begin
		if (is_imm_signext == 1) begin
			imm_ext = {{8{imm[7]}}, imm};
		end else if (is_imm_8bit_ls_ext == 1) begin
			imm_ext = {imm,{8{1'b0}}};
		end else begin
			imm_ext = {{8{1'b0}},imm};
		end
	end
		
	assign shift = (is_imm) ? shift_imm : read_data2[4:0];
	

    // Register File
		register_file RF_inst (
			 .clk(clk), 
			 .resetn(resetn), 
			 .read_addr1(rdest), 
			 .read_addr2(rsrc), 
			 .write_addr(rdest), 
			 .write_data(write_data), 
			 .write_enable(wen_rf_sync), 
			 .read_data1(read_data1), 
			 .read_data2(read_data2)
			 );


	always@(*) begin
		case(wdata_sel_rf)
			3'b000: write_data = alu_result;
			3'b001: write_data = B_operand;
			3'b010: write_data = imm_ext;
			3'b011: write_data = shifter_out;
			3'b100: write_data = PC + 1;
			3'b101: write_data = mem_data;
			default: write_data = alu_result;
		endcase
	end


    // ALU
		alu ALU_inst (
			 .A(read_data1), 
			 .B(B_operand), 
			 .sel(alu_sel), 
			 .clk(clk), 
			 .resetn(resetn), 
			 .is_compare(is_cmp), 
			 .S(alu_result), 
			 .NEGATIVE_reg(negative_flag), 
			 .ZERO_reg(zero_flag), 
			 .CARRY_reg(carry_flag), 
			 .OVERFLOW_reg(overflow_flag), 
			 .LOW_reg(low_flag)
			 );

	assign B_operand = (is_imm) ? imm_ext : read_data2;


			shifter brl_shifter (
			 .data_in(read_data1), 
			 .shift(shift), 
			 .data_out(shifter_out)
			 );
			 
		spblockram instr_mem (
			 .clk(clk), 
			 .mem_write(mem_write), 
			 .address(PC[4:0]), 
			 .write_data(instruction_input), 
			 .read_data(instruction_in)
			 );

		spblockram data_mem (
			 .clk(clk), 
			 .mem_write(wen_mem), 
			 .address(read_data2[4:0]), 
			 .write_data(read_data1), 
			 .read_data(mem_data)
			 );
			 
			 
endmodule