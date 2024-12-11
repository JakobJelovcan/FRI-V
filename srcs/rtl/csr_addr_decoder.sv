`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 05/03/2024 07:05:56 AM
// Design Name: 
// Module Name: csr_addr_decoder
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
import constants::*;

module csr_addr_decoder (
    input  wire         [11:0] i_addr,
    output csr_register        o_csr,
    output logic               o_valid
);

    always_comb begin
        casez (i_addr)
            MSTATUS_ADDR: begin
                o_csr   = mstatus;
                o_valid = 1'b1;
            end
            MIE_ADDR: begin
                o_csr   = mie;
                o_valid = 1'b1;
            end
            MTVEC_ADDR: begin
                o_csr   = mtvec;
                o_valid = 1'b1;
            end
            MSCRATCH_ADDR: begin
                o_csr   = mscratch;
                o_valid = 1'b1;
            end
            MEPC_ADDR: begin
                o_csr   = mepc;
                o_valid = 1'b1;
            end
            MCAUSE_ADDR: begin
                o_csr   = mcause;
                o_valid = 1'b1;
            end
            MIP_ADDR: begin
                o_csr   = mip;
                o_valid = 1'b1;
            end
            MTVAL_ADDR: begin
                o_csr   = mtval;
                o_valid = 1'b1;
            end
            default: begin
                o_csr   = csr_register'(0);
                o_valid = 1'b0;
            end
        endcase
    end
endmodule
