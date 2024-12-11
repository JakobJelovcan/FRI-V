`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 06/02/2024 10:16:34 AM
// Design Name: 
// Module Name: divop_decoder
// Project Name: RISC-V
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

import types::*;

module divop_decoder (
    input  wire       [31:0] i_inst,
    output rv32_divop        o_divop,
    output logic             o_invalid
);

    wire w_func7_valid = i_inst[31:25] == 7'b0000001;

    always_comb begin
        case (i_inst[6:0])
            7'b0110011: begin
                case (i_inst[14:12])
                    3'b100: begin
                        o_divop   = divop_div;
                        o_invalid = !w_func7_valid;
                    end
                    3'b101: begin
                        o_divop   = divop_divu;
                        o_invalid = !w_func7_valid;
                    end
                    3'b110: begin
                        o_divop   = divop_rem;
                        o_invalid = !w_func7_valid;
                    end
                    3'b111: begin
                        o_divop   = divop_remu;
                        o_invalid = !w_func7_valid;
                    end
                    default: begin
                        o_divop   = divop_nop;
                        o_invalid = 1'b1;
                    end
                endcase
            end
            default: begin
                o_divop   = divop_nop;
                o_invalid = 1'b1;
            end
        endcase
    end
endmodule
