`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Jakob Jelovcan
//
// Create Date: 06/23/2023 08:07:05 PM
// Design Name:
// Module Name: memop_decoder
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

module memop_decoder (
    input  wire       [31:0] i_inst,
    output rv32_memop        o_memop,
    output logic             o_invalid
);

    always_comb begin
        case (i_inst[6:0])
            7'b0000011: begin
                case (i_inst[14:12])
                    3'b000: begin
                        o_memop   = memop_l_byte;
                        o_invalid = 1'b0;
                    end
                    3'b001: begin
                        o_memop   = memop_l_hword;
                        o_invalid = 1'b0;
                    end
                    3'b010: begin
                        o_memop   = memop_l_word;
                        o_invalid = 1'b0;
                    end
                    3'b100: begin
                        o_memop   = memop_l_ubyte;
                        o_invalid = 1'b0;
                    end
                    3'b101: begin
                        o_memop   = memop_l_uhword;
                        o_invalid = 1'b0;
                    end
                    default: begin
                        o_memop   = memop_nop;
                        o_invalid = 1'b1;
                    end
                endcase
            end
            7'b0100011: begin
                case (i_inst[14:12])
                    3'b000: begin
                        o_memop   = memop_s_byte;
                        o_invalid = 1'b0;
                    end
                    3'b001: begin
                        o_memop   = memop_s_hword;
                        o_invalid = 1'b0;
                    end
                    3'b010: begin
                        o_memop   = memop_s_word;
                        o_invalid = 1'b0;
                    end
                    default: begin
                        o_memop   = memop_nop;
                        o_invalid = 1'b1;
                    end
                endcase
            end
            default: begin
                o_memop   = memop_nop;
                o_invalid = 1'b1;
            end
        endcase
    end
endmodule
