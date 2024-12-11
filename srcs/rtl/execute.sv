`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Jakob Jelovcan
//
// Create Date: 06/24/2023 06:48:59 AM
// Design Name:
// Module Name: execute
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

module execute (
    input  wire                       i_clk,
    input  wire                       i_flush,
    input  wire                       i_stall,
    input  wire                       i_valid,
    input  wire                [31:0] i_pc,
    input  rv32_instruction_de        i_inst,
    input  wire                [31:0] i_data_a,
    input  wire                [31:0] i_data_b,
    input  wire                [31:0] i_immed,
    input  de_error                   i_de_error,
    output rv32_instruction_ex        o_inst,
    output reg                 [31:0] o_data_a,
    output reg                 [31:0] o_data_b,
    output reg                 [31:0] o_data_c,
    output wire                [31:0] o_pc,
    output wire                [31:0] o_memory_store_data,
    output wire                [31:0] o_branch_offset,
    output reg                 [31:0] o_branch_base,
    output wire                       o_valid,
    output ex_error                   o_ex_error,
    output rv32_branch_type           o_branch_type,
    output rv32_aluop                 o_aluop,
    output rv32_arithop               o_arithop,
    output rv32_logicop               o_logicop,
    output rv32_compop                o_compop,
    output rv32_sysop                 o_sysop,
    output rv32_divop                 o_divop,
    output rv32_mulop                 o_mulop,
    output rv32_csr_access            o_csr_access,
    output wire                       o_atomic,
    output wire                       o_ex_res_sel,
    output wire                       o_alu_en
);

    reg                        r_valid;
    reg                        r_alu_en;
    reg                 [31:0] r_pc;
    reg                 [31:0] r_data_a;
    reg                 [31:0] r_data_b;
    reg                 [31:0] r_immed;
    rv32_instruction_de        r_inst;
    de_error                   r_de_error;

    always_ff @(posedge i_clk) begin
        if (!i_stall) begin
            r_pc       <= i_pc;
            r_data_a   <= i_data_a;
            r_data_b   <= i_data_b;
            r_immed    <= i_immed;
            r_inst     <= i_inst;
            r_de_error <= i_de_error;
        end
    end

    always_ff @(posedge i_clk) begin
        if (i_flush) begin
            r_valid <= 1'b0;
        end else if (!i_stall) begin
            r_valid <= i_valid;
        end
    end

    always_ff @(posedge i_clk) begin
        if (i_flush) begin
            r_alu_en <= 1'b0;
        end else begin
            r_alu_en <= !i_stall;
        end
    end

    always_comb begin
        if (r_inst.alu_op_a_sel) begin
            o_data_a = r_pc;
        end else begin
            o_data_a = r_data_a;
        end
    end

    always_comb begin
        if (r_inst.alu_op_b_sel) begin
            o_data_b = r_immed;
        end else begin
            o_data_b = r_data_b;
        end
    end

    always_comb begin
        if (r_inst.sys_op_sel) begin
            o_data_c = {27'b0, r_immed[16:12]};
        end else begin
            o_data_c = r_data_a;
        end
    end

    always_comb begin
        case (r_inst.branch_type)
            branch_rel_rs: begin
                o_branch_base = r_data_a;
            end
            default: begin
                o_branch_base = r_pc;
            end
        endcase
    end

    always_comb begin
        if (r_valid) begin
            o_ex_error = '{
                r_de_error.access_fault,
                r_de_error.address_misaligned,
                r_de_error.invalid_inst,
                r_inst.sysop == sysop_eb,
                r_inst.sysop == sysop_ec
            };
        end else begin
            o_ex_error = '0;
        end
    end

    assign o_valid             = r_valid;
    assign o_branch_offset     = r_immed;
    assign o_memory_store_data = r_data_b;
    assign o_aluop             = r_inst.aluop;
    assign o_compop            = r_inst.compop;
    assign o_arithop           = r_inst.arithop;
    assign o_logicop           = r_inst.logicop;
    assign o_sysop             = r_inst.sysop;
    assign o_divop             = r_inst.divop;
    assign o_mulop             = r_inst.mulop;
    assign o_csr_access        = r_inst.csr_access;
    assign o_pc                = r_pc;
    assign o_branch_type       = r_inst.branch_type;
    assign o_ex_res_sel        = r_inst.ex_res_sel;
    assign o_atomic            = r_inst.atomic;
    assign o_inst              = '{rd: r_inst.rd, memop: r_inst.memop, ma_res_sel: r_inst.ma_res_sel};
    assign o_alu_en            = r_alu_en;
endmodule
