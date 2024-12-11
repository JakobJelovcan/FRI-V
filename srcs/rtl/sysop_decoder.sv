`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 10/28/2023 06:47:29 PM
// Design Name: 
// Module Name: sysop_decoder
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

module sysop_decoder (
    input  wire            [31:0] i_inst,
    output rv32_sysop             o_sysop,
    output rv32_csr_access        o_csr_access,
    output logic                  o_invalid
);
    wire w_rd_x0  = (i_inst[11:7] == '0);
    wire w_rs1_x0 = (i_inst[19:15] == '0);

    always_comb begin
        case (i_inst[6:0])
            7'b1110011: begin
                case (i_inst[14:12])
                    3'b000: begin
                        case (i_inst[31:7])
                            25'h604000: begin
                                o_sysop      = sysop_mret;
                                o_csr_access = csr_nop;
                                o_invalid    = 1'b0;
                            end
                            25'h000000: begin
                                o_sysop      = sysop_ec;
                                o_csr_access = csr_nop;
                                o_invalid    = 1'b0;
                            end
                            25'h002000: begin
                                o_sysop      = sysop_eb;
                                o_csr_access = csr_nop;
                                o_invalid    = 1'b0;
                            end
                            default: begin
                                o_sysop      = sysop_nop;
                                o_csr_access = csr_nop;
                                o_invalid    = 1'b1;
                            end
                        endcase
                    end
                    3'b001, 3'b101: begin
                        o_sysop      = sysop_rw;
                        o_csr_access = rv32_csr_access'({!w_rd_x0, 1'b1});
                        o_invalid    = 1'b0;
                    end
                    3'b010, 3'b110: begin
                        o_sysop      = sysop_rs;
                        o_csr_access = rv32_csr_access'({1'b1, !w_rs1_x0});
                        o_invalid    = 1'b0;
                    end
                    3'b011, 3'b111: begin
                        o_sysop      = sysop_rc;
                        o_csr_access = rv32_csr_access'({1'b1, !w_rs1_x0});
                        o_invalid    = 1'b0;
                    end
                    default: begin
                        o_sysop      = sysop_nop;
                        o_csr_access = csr_nop;
                        o_invalid    = 1'b1;
                    end
                endcase
            end
            default: begin
                o_csr_access = csr_nop;
                o_sysop      = sysop_nop;
                o_invalid    = 1'b1;
            end
        endcase
    end
endmodule
