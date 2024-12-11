`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 06/02/2024 10:16:34 AM
// Design Name: 
// Module Name: arithop_decoder
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

module arithop_decoder (
    input  wire         [31:0] i_inst,
    output rv32_arithop        o_arithop,
    output logic               o_invalid
);

    wire w_func7_valid = i_inst[31:25] ==? 7'b0?00000;

    always_comb begin
        case (i_inst[6:0])
            7'b0110011: begin
                case (i_inst[14:12])
                    3'b000: begin
                        o_arithop = (i_inst[30]) ? arithop_sub : arithop_add;
                        o_invalid = !w_func7_valid;
                    end
                    3'b010: begin
                        o_arithop = arithop_sub;
                        o_invalid = !w_func7_valid || i_inst[30];
                    end
                    3'b011: begin
                        o_arithop = arithop_sub;
                        o_invalid = !w_func7_valid || i_inst[30];
                    end
                    default: begin
                        o_arithop = arithop_nop;
                        o_invalid = 1'b1;
                    end
                endcase
            end
            7'b0010011: begin
                case (i_inst[14:12])
                    3'b000: begin
                        o_arithop = arithop_add;
                        o_invalid = 1'b0;
                    end
                    3'b010: begin
                        o_arithop = arithop_sub;
                        o_invalid = 1'b0;
                    end
                    3'b011: begin
                        o_arithop = arithop_sub;
                        o_invalid = 1'b0;
                    end
                    default: begin
                        o_arithop = arithop_nop;
                        o_invalid = 1'b1;
                    end
                endcase
            end
            7'b0000011: begin
                o_arithop = arithop_add;
                o_invalid = 1'b0;
            end
            7'b0100011: begin
                o_arithop = arithop_add;
                o_invalid = 1'b0;
            end
            7'b1100011: begin
                case (i_inst[14:12])
                    3'b000, 3'b001, 3'b100, 3'b101, 3'b110, 3'b111: begin
                        o_arithop = arithop_sub;
                        o_invalid = 1'b0;
                    end
                    default: begin
                        o_arithop = arithop_nop;
                        o_invalid = 1'b1;
                    end
                endcase
            end
            7'b1101111: begin
                o_arithop = arithop_inc;
                o_invalid = 1'b0;
            end
            7'b1100111: begin
                case (i_inst[14:12])
                    3'b000: begin
                        o_arithop = arithop_inc;
                        o_invalid = 1'b0;
                    end
                    default: begin
                        o_arithop = arithop_nop;
                        o_invalid = 1'b1;
                    end
                endcase
            end
            7'b0010111: begin
                o_arithop = arithop_add;
                o_invalid = 1'b0;
            end
            7'b0110111: begin
                o_arithop = arithop_add;
                o_invalid = 1'b0;
            end
            default: begin
                o_arithop = arithop_nop;
                o_invalid = 1'b1;
            end
        endcase
    end
endmodule
