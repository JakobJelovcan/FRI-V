`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Jakob Jelovcan
//
// Create Date: 06/23/2023 07:00:56 PM
// Design Name:
// Module Name: format_decoder
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
import functions::*;

module format_decoder (
    input  wire             [31:0] i_inst,
    output rv32_branch_type        o_branch_type,
    output logic                   o_alu_op_a_sel,
    output logic                   o_alu_op_b_sel,
    output logic                   o_ex_res_sel,
    output logic                   o_ma_res_sel,
    output logic                   o_sys_op_sel,
    output logic                   o_atomic,
    output logic            [ 4:0] o_rd,
    output logic            [ 4:0] o_rs1,
    output logic            [ 4:0] o_rs2,
    output logic            [31:0] o_immed
);

    always_comb begin
        case (i_inst[6:0])
            7'b0100011: begin
                o_branch_type  = branch_none;
                o_alu_op_a_sel = 1'b0;
                o_alu_op_b_sel = 1'b1;
                o_sys_op_sel   = 1'b0;
                o_rs2          = i_inst[24:20];
                o_rs1          = i_inst[19:15];
                o_rd           = 5'b0;
                o_immed        = decode_s_immed(i_inst);
                o_atomic       = 1'b0;
                o_ex_res_sel   = 1'b0;
                o_ma_res_sel   = 1'b0;
            end
            7'b1100011: begin
                o_branch_type  = branch_cond;
                o_alu_op_a_sel = 1'b0;
                o_alu_op_b_sel = 1'b0;
                o_sys_op_sel   = 1'b0;
                o_rs2          = i_inst[24:20];
                o_rs1          = i_inst[19:15];
                o_rd           = 5'b0;
                o_immed        = decode_b_immed(i_inst);
                o_atomic       = 1'b1;
                o_ex_res_sel   = 1'b0;
                o_ma_res_sel   = 1'b0;
            end
            7'b1101111: begin
                o_branch_type  = branch_rel_pc;
                o_alu_op_a_sel = 1'b1;
                o_alu_op_b_sel = 1'b1;
                o_sys_op_sel   = 1'b0;
                o_rs2          = 5'b0;
                o_rs1          = 5'b0;
                o_rd           = i_inst[11:7];
                o_immed        = decode_j_immed(i_inst);
                o_atomic       = 1'b1;
                o_ex_res_sel   = 1'b0;
                o_ma_res_sel   = 1'b0;
            end
            7'b1100111: begin
                o_branch_type  = branch_rel_rs;
                o_alu_op_a_sel = 1'b1;
                o_alu_op_b_sel = 1'b1;
                o_sys_op_sel   = 1'b0;
                o_rs2          = 5'b0;
                o_rs1          = i_inst[19:15];
                o_rd           = i_inst[11:7];
                o_immed        = decode_i_immed(i_inst);
                o_atomic       = 1'b1;
                o_ex_res_sel   = 1'b0;
                o_ma_res_sel   = 1'b0;
            end
            7'b0110011: begin
                o_branch_type  = branch_none;
                o_alu_op_a_sel = 1'b0;
                o_alu_op_b_sel = 1'b0;
                o_sys_op_sel   = 1'b0;
                o_rs2          = i_inst[24:20];
                o_rs1          = i_inst[19:15];
                o_rd           = i_inst[11:7];
                o_immed        = 32'b0;
                o_atomic       = 1'b0;
                o_ex_res_sel   = 1'b0;
                o_ma_res_sel   = 1'b0;
            end
            7'b0000011: begin
                o_branch_type  = branch_none;
                o_alu_op_a_sel = 1'b0;
                o_alu_op_b_sel = 1'b1;
                o_sys_op_sel   = 1'b0;
                o_rs2          = 5'b0;
                o_rs1          = i_inst[19:15];
                o_rd           = i_inst[11:7];
                o_immed        = decode_i_immed(i_inst);
                o_atomic       = 1'b0;
                o_ex_res_sel   = 1'b0;
                o_ma_res_sel   = 1'b1;
            end
            7'b0010011: begin
                o_branch_type  = branch_none;
                o_alu_op_a_sel = 1'b0;
                o_alu_op_b_sel = 1'b1;
                o_sys_op_sel   = 1'b0;
                o_rs2          = 5'b0;
                o_rs1          = i_inst[19:15];
                o_rd           = i_inst[11:7];
                o_immed        = decode_i_immed(i_inst);
                o_atomic       = 1'b0;
                o_ex_res_sel   = 1'b0;
                o_ma_res_sel   = 1'b0;
            end
            7'b0010111: begin
                o_branch_type  = branch_none;
                o_alu_op_a_sel = 1'b1;
                o_alu_op_b_sel = 1'b1;
                o_sys_op_sel   = 1'b0;
                o_rs2          = 5'b0;
                o_rs1          = 5'b0;
                o_rd           = i_inst[11:7];
                o_immed        = decode_u_immed(i_inst);
                o_atomic       = 1'b0;
                o_ex_res_sel   = 1'b0;
                o_ma_res_sel   = 1'b0;
            end
            7'b0110111: begin
                o_branch_type  = branch_none;
                o_alu_op_a_sel = 1'b0;
                o_alu_op_b_sel = 1'b1;
                o_sys_op_sel   = 1'b0;
                o_rs2          = 5'b0;
                o_rs1          = 5'b0;
                o_rd           = i_inst[11:7];
                o_immed        = decode_u_immed(i_inst);
                o_atomic       = 1'b0;
                o_ex_res_sel   = 1'b0;
                o_ma_res_sel   = 1'b0;
            end
            7'b1110011: begin
                o_branch_type  = branch_none;
                o_alu_op_a_sel = 1'b0;
                o_alu_op_b_sel = 1'b1;
                o_sys_op_sel   = i_inst[14];
                o_rs2          = 5'b0;
                o_rs1          = (i_inst[14]) ? 5'b0 : i_inst[19:15];
                o_rd           = i_inst[11:7];
                o_immed        = decode_z_immed(i_inst);
                o_atomic       = 1'b1;
                o_ex_res_sel   = 1'b1;
                o_ma_res_sel   = 1'b0;
            end
            default: begin
                o_branch_type  = branch_none;
                o_alu_op_a_sel = 1'b0;
                o_alu_op_b_sel = 1'b0;
                o_sys_op_sel   = 1'b0;
                o_rs2          = 5'b0;
                o_rs1          = 5'b0;
                o_rd           = 5'b0;
                o_immed        = 32'b0;
                o_atomic       = 1'b0;
                o_ex_res_sel   = 1'b0;
                o_ma_res_sel   = 1'b0;
            end
        endcase
    end
endmodule
