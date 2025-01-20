
`timescale 1ns / 1ps

module control_unit (
    input wire clk,
    input wire resetn,
    output reg load_enable,
    output reg pc_enable,
	 output reg wen_rf_wb_state
);

    // State encoding
    localparam FETCH = 2'b00;
    localparam EXECUTE = 2'b01;
    localparam WRITE_BACK = 2'b10;

    reg [1:0] current_state, next_state;

    // Sequential state transition
    always @(posedge clk or negedge resetn) begin
        if (!resetn)
            current_state <= FETCH;
        else
            current_state <= next_state;
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            FETCH: next_state = EXECUTE;
            EXECUTE: next_state = WRITE_BACK;
            WRITE_BACK: next_state = FETCH;
            default: next_state = FETCH;
        endcase
    end

    // Output logic
    always @(*) begin        
        case (current_state)
            FETCH: begin
                   load_enable = 1;
                   pc_enable = 0;
						 wen_rf_wb_state = 0;
            end

            EXECUTE: begin
                     load_enable = 0;
            end

            WRITE_BACK: begin
                        pc_enable = 1;
								wen_rf_wb_state = 1;
            end
				
				default: begin
							load_enable = 0;
							pc_enable = 0;
							wen_rf_wb_state = 0;
				end				
        endcase
    end

endmodule

