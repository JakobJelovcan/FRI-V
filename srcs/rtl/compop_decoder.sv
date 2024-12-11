`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 06/02/2024 10:16:34 AM
// Design Name: 
// Module Name: compop_decoder
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

module compop_decoder (
    input  wire        [31:0] i_inst,
    output rv32_compop        o_compop,
    output logic              o_invalid
);

    wire w_func7_valid = i_inst[31:25] == 7'b0000000;
    
    always_comb begin
        case (i_inst[6:0])
            7'b0110011: begin
                case (i_inst[14:12])
                    3'b010: begin
                        o_compop  = compop_lts;
                        o_invalid = !w_func7_valid;
                    end
                    3'b011: begin
                        o_compop  = compop_ltu;
                        o_invalid = !w_func7_valid;
                    end
                    default: begin
                        o_compop  = compop_nop;
                        o_invalid = 1'b1;
                    end
                endcase
            end
            7'b0010011: begin
                case (i_inst[14:12])
                    3'b010: begin
                        o_compop  = compop_lts;
                        o_invalid = 1'b0;
                    end
                    3'b011: begin
                        o_compop  = compop_ltu;
                        o_invalid = 1'b0;
                    end
                    default: begin
                        o_compop  = compop_nop;
                        o_invalid = 1'b1;
                    end
                endcase
            end
            7'b1100011: begin
                case (i_inst[14:12])
                    3'b000: begin
                        o_compop  = compop_eq;
                        o_invalid = 1'b0;
                    end
                    3'b001: begin
                        o_compop  = compop_ne;
                        o_invalid = 1'b0;
                    end
                    3'b100: begin
                        o_compop  = compop_lts;
                        o_invalid = 1'b0;
                    end
                    3'b101: begin
                        o_compop  = compop_ges;
                        o_invalid = 1'b0;
                    end
                    3'b110: begin
                        o_compop  = compop_ltu;
                        o_invalid = 1'b0;
                    end
                    3'b111: begin
                        o_compop  = compop_geu;
                        o_invalid = 1'b0;
                    end
                    default: begin
                        o_compop  = compop_nop;
                        o_invalid = 1'b1;
                    end
                endcase
            end
            default: begin
                o_compop  = compop_nop;
                o_invalid = 1'b1;
            end
        endcase
    end
endmodule
