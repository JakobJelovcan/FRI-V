`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Jakob Jelovcan
//
// Create Date: 06/23/2023 06:47:53 PM
// Design Name:
// Module Name: decode
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

module decode (
    input  wire                       i_clk,
    input  wire                       i_flush,
    input  wire                       i_stall,
    input  wire                       i_valid,
    input  wire                [31:0] i_pc,
    input  wire                [31:0] i_inst,
    input  fe_error                   i_fe_error,
    output wire                [31:0] o_pc,
    output rv32_instruction_de        o_inst,
    output wire                [31:0] o_immed,
    output wire                       o_valid,
    output rv32_register              o_rs1,
    output rv32_register              o_rs2,
    output de_error                   o_de_error
);

    reg              [31:0] r_pc;
    reg              [31:0] r_inst;
    reg                     r_valid;
    fe_error                r_fe_error;

    rv32_compop             w_compop;
    rv32_memop              w_memop;
    rv32_aluop              w_aluop;
    rv32_divop              w_divop;
    rv32_mulop              w_mulop;
    rv32_sysop              w_sysop;
    rv32_arithop            w_arithop;
    rv32_logicop            w_logicop;
    rv32_branch_type        w_branch_type;
    rv32_csr_access         w_csr_access;
    wire                    w_atomic;
    wire                    w_alu_op_a_sel;
    wire                    w_alu_op_b_sel;
    wire                    w_ex_res_sel;
    wire                    w_ma_res_sel;
    wire                    w_sys_op_sel;
    rv32_register           w_rd;
    rv32_register           w_rs1;
    rv32_register           w_rs2;
    wire                    w_invalid_inst;

    wire                    w_memop_invalid;
    wire                    w_sysop_invalid;
    wire                    w_mulop_invalid;
    wire                    w_divop_invalid;
    wire                    w_logicop_invalid;
    wire                    w_arithop_invalid;
    wire                    w_compop_invalid;

    always_ff @(posedge i_clk) begin
        if (!i_stall) begin
            r_pc       <= i_pc;
            r_inst     <= i_inst;
            r_fe_error <= i_fe_error;
        end
    end

    always_ff @(posedge i_clk) begin
        if (i_flush) begin
            r_valid <= 1'b0;
        end else if (!i_stall) begin
            r_valid <= i_valid;
        end
    end

    aluop_decoder instance_aluop_decoder (
        .i_inst (r_inst),
        .o_aluop(w_aluop)
    );

    sysop_decoder instance_sysop_decoder (
        .i_inst      (r_inst),
        .o_sysop     (w_sysop),
        .o_csr_access(w_csr_access),
        .o_invalid   (w_sysop_invalid)
    );

    arithop_decoder instance_arithop_decoder (
        .i_inst   (r_inst),
        .o_arithop(w_arithop),
        .o_invalid(w_arithop_invalid)
    );

    logicop_decoder instance_logicop_decoder (
        .i_inst   (r_inst),
        .o_logicop(w_logicop),
        .o_invalid(w_logicop_invalid)
    );

    mulop_decoder instance_mulop_decoder (
        .i_inst   (r_inst),
        .o_mulop  (w_mulop),
        .o_invalid(w_mulop_invalid)
    );

    divop_decoder instance_divop_decoder (
        .i_inst   (r_inst),
        .o_divop  (w_divop),
        .o_invalid(w_divop_invalid)
    );

    compop_decoder instance_compop_decoder (
        .i_inst   (r_inst),
        .o_compop (w_compop),
        .o_invalid(w_compop_invalid)
    );

    memop_decoder instance_memop_decoder (
        .i_inst   (r_inst),
        .o_memop  (w_memop),
        .o_invalid(w_memop_invalid)
    );

    format_decoder instance_format_decoder (
        .i_inst        (r_inst),
        .o_branch_type (w_branch_type),
        .o_alu_op_a_sel(w_alu_op_a_sel),
        .o_alu_op_b_sel(w_alu_op_b_sel),
        .o_ex_res_sel  (w_ex_res_sel),
        .o_ma_res_sel  (w_ma_res_sel),
        .o_sys_op_sel  (w_sys_op_sel),
        .o_atomic      (w_atomic),
        .o_rd          (w_rd),
        .o_rs1         (w_rs1),
        .o_rs2         (w_rs2),
        .o_immed       (o_immed)
    );

    assign w_invalid_inst = (w_memop_invalid && w_sysop_invalid && w_compop_invalid && w_mulop_invalid && w_divop_invalid && w_arithop_invalid && w_logicop_invalid);
    assign o_pc = r_pc;
    assign o_rs1 = w_rs1;
    assign o_rs2 = w_rs2;
    assign o_valid = r_valid;
    assign o_inst = '{
            rd: w_rd,
            memop: w_memop,
            aluop: w_aluop,
            arithop: w_arithop,
            logicop: w_logicop,
            compop: w_compop,
            sysop: w_sysop,
            mulop: w_mulop,
            divop: w_divop,
            csr_access: w_csr_access,
            branch_type: w_branch_type,
            atomic: w_atomic,
            alu_op_a_sel: w_alu_op_a_sel,
            alu_op_b_sel: w_alu_op_b_sel,
            ex_res_sel: w_ex_res_sel,
            ma_res_sel: w_ma_res_sel,
            sys_op_sel: w_sys_op_sel
        };

    assign o_de_error = '{r_fe_error.access_fault, r_fe_error.address_misaligned, w_invalid_inst};
endmodule
