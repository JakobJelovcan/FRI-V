`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Jakob Jelovcan
//
// Create Date: 06/24/2023 09:35:47 AM
// Design Name:
// Module Name: branch_unit
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

module branch_unit (
    input  rv32_branch_type        i_branch_type,
    input  wire                    i_alu_out,
    input  wire                    i_valid,
    input  wire             [31:0] i_branch_base,
    input  wire             [31:0] i_branch_offset,
    input  wire                    i_int_taken,
    input  wire             [31:0] i_int_addr,
    output logic            [31:0] o_branch_addr,
    output logic                   o_branch_taken
);

    always_comb begin
        if (i_int_taken) begin
            o_branch_taken = 1'b1;
        end else begin
            case (i_branch_type)
                branch_rel_pc, branch_rel_rs: begin
                    o_branch_taken = i_valid;
                end
                branch_cond: begin
                    o_branch_taken = i_valid && i_alu_out;
                end
                default: begin
                    o_branch_taken = 1'b0;
                end
            endcase
        end
    end

    always_comb begin
        if (i_int_taken) begin
            o_branch_addr = i_int_addr;
        end else begin
            o_branch_addr = i_branch_base + i_branch_offset;
        end
    end
endmodule
