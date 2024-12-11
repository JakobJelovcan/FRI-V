`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 06/02/2024 10:16:34 AM
// Design Name: 
// Module Name: mulop_decoder
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

module mulop_decoder (
    input  wire       [31:0] i_inst,
    output rv32_mulop        o_mulop,
    output logic             o_invalid
);

    wire w_func7_valid = i_inst[31:25] == 7'b0000001;

    always_comb begin
        case (i_inst[6:0])
            7'b0110011: begin
                case (i_inst[14:12])
                    3'b000: begin
                        o_mulop   = mulop_mul;
                        o_invalid = !w_func7_valid;
                    end
                    3'b001: begin
                        o_mulop   = mulop_mulh;
                        o_invalid = !w_func7_valid;
                    end
                    3'b010: begin
                        o_mulop   = mulop_mulhsu;
                        o_invalid = !w_func7_valid;
                    end
                    3'b011: begin
                        o_mulop   = mulop_mulhu;
                        o_invalid = !w_func7_valid;
                    end
                    default: begin
                        o_mulop   = mulop_nop;
                        o_invalid = 1'b1;
                    end
                endcase
            end
            default: begin
                o_mulop   = mulop_nop;
                o_invalid = 1'b1;
            end
        endcase
    end
endmodule
