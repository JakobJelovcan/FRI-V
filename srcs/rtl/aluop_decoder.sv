`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Jakob Jelovcan
//
// Create Date: 06/23/2023 07:23:59 PM
// Design Name:
// Module Name: aluop_decoder
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

module aluop_decoder (
    input  wire       [31:0] i_inst,
    output rv32_aluop        o_aluop
);

    always_comb begin
        case (i_inst[6:0])
            7'b0110011: begin
                case (i_inst[14:12])
                    3'b000: begin
                        o_aluop = (i_inst[25]) ? aluop_mul : aluop_ari;
                    end
                    3'b001: begin
                        o_aluop = (i_inst[25]) ? aluop_mul : aluop_log;
                    end
                    3'b010, 3'b011: begin
                        o_aluop = (i_inst[25]) ? aluop_mul : aluop_cmp;
                    end
                    3'b100, 3'b101, 3'b110, 3'b111: begin
                        o_aluop = (i_inst[25]) ? aluop_div : aluop_log;
                    end
                    default: begin
                        o_aluop = aluop_nop;
                    end
                endcase
            end
            7'b0010011: begin
                case (i_inst[14:12])
                    3'b000: begin
                        o_aluop = aluop_ari;
                    end
                    3'b010, 3'b011: begin
                        o_aluop = aluop_cmp;
                    end
                    3'b001, 3'b100, 3'b101, 3'b110, 3'b111: begin
                        o_aluop = aluop_log;
                    end
                    default: begin
                        o_aluop = aluop_nop;
                    end
                endcase
            end
            7'b1100011: begin
                o_aluop = aluop_cmp;
            end
            7'b0000011, 7'b0100011, 7'b1101111, 7'b1100111, 7'b0010111, 7'b0110111: begin
                o_aluop = aluop_ari;
            end
            default: begin
                o_aluop = aluop_nop;
            end
        endcase
    end
endmodule
