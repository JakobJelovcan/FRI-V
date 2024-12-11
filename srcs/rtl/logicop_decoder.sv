`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 06/02/2024 10:16:34 AM
// Design Name: 
// Module Name: logicop_decoder
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

module logicop_decoder (
    input  wire         [31:0] i_inst,
    output rv32_logicop        o_logicop,
    output logic               o_invalid
);

    wire w_func7_valid = i_inst[31:25] ==? 7'b0?00000;
    
    always_comb begin
        case (i_inst[6:0])
            7'b0110011: begin
                case (i_inst[14:12])
                    3'b001: begin
                        o_logicop = logicop_sll;
                        o_invalid = !w_func7_valid || i_inst[30];
                    end
                    3'b100: begin
                        o_logicop = logicop_xor;
                        o_invalid = !w_func7_valid || i_inst[30];
                    end
                    3'b101: begin
                        o_logicop = (i_inst[30]) ? logicop_sra : logicop_srl;
                        o_invalid = !w_func7_valid;
                    end
                    3'b110: begin
                        o_logicop = logicop_orr;
                        o_invalid = !w_func7_valid || i_inst[30];
                    end
                    3'b111: begin
                        o_logicop = logicop_and;
                        o_invalid = !w_func7_valid || i_inst[30];
                    end
                    default: begin
                        o_logicop = logicop_nop;
                        o_invalid = 1'b1;
                    end
                endcase
            end
            7'b0010011: begin
                case (i_inst[14:12])
                    3'b001: begin
                        o_logicop = logicop_sll;
                        o_invalid = !w_func7_valid || i_inst[30];
                    end
                    3'b100: begin
                        o_logicop = logicop_xor;
                        o_invalid = 1'b0;
                    end
                    3'b101: begin
                        o_logicop = (i_inst[30]) ? logicop_sra : logicop_srl;
                        o_invalid = !w_func7_valid;
                    end
                    3'b110: begin
                        o_logicop = logicop_orr;
                        o_invalid = 1'b0;
                    end
                    3'b111: begin
                        o_logicop = logicop_and;
                        o_invalid = 1'b0;
                    end
                    default: begin
                        o_logicop = logicop_nop;
                        o_invalid = 1'b1;
                    end
                endcase
            end
            default: begin
                o_logicop = logicop_nop;
                o_invalid = 1'b1;
            end
        endcase
    end
endmodule
