`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Jakob Jelovcan
//
// Create Date: 06/24/2023 11:29:50 AM
// Design Name:
// Module Name: memory_access
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

module memory_access (
    input  wire                       i_clk,
    input  wire                       i_flush,
    input  wire                       i_valid,
    input  wire                       i_stall,
    input  rv32_instruction_ex        i_inst,
    input  wire                [31:0] i_pc,
    input  wire                [31:0] i_alu_data,
    input  wire                [31:0] i_store_data,
    output rv32_instruction_ma        o_inst,
    output wire                [31:0] o_pc,
    output wire                [31:0] o_addr,
    output wire                [31:0] o_alu_data,
    output wire                [31:0] o_store_data,
    output wire                       o_valid,
    output wire                       o_mem_en,
    output wire                       o_mem_we,
    output wire                       o_ma_res_sel
);

    rv32_instruction_ex        r_inst;
    reg                 [31:0] r_pc;
    reg                 [31:0] r_alu_data;
    reg                 [31:0] r_store_data;
    reg                        r_valid;
    reg                        r_stall;

    always_ff @(posedge i_clk) begin
        if (i_flush) begin
            r_stall <= 1'b0;
        end else begin
            r_stall <= i_stall;
        end
    end

    always_ff @(posedge i_clk) begin
        if (!i_stall) begin
            r_pc         <= i_pc;
            r_store_data <= i_store_data;
            r_alu_data   <= i_alu_data;
            r_inst       <= i_inst;
        end
    end

    always_ff @(posedge i_clk) begin
        if (i_flush) begin
            r_valid <= 1'b0;
        end else if (!i_stall) begin
            r_valid <= i_valid;
        end
    end

    assign o_pc         = r_pc;
    assign o_valid      = r_valid;
    assign o_addr       = r_alu_data;
    assign o_store_data = r_store_data;
    assign o_alu_data   = r_alu_data;
    assign o_mem_en     = r_valid && !r_stall && (r_inst.memop != memop_nop);
    assign o_mem_we     = r_inst.memop inside { rv32_s_memop };
    assign o_ma_res_sel = r_inst.ma_res_sel;
    assign o_inst       = '{rd: r_inst.rd, memop: r_inst.memop};
endmodule
