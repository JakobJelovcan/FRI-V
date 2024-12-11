`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Jakob Jelovcan
//
// Create Date: 06/24/2023 08:23:53 AM
// Design Name:
// Module Name: alu
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

module alu (
    input  wire                i_clk,
    input  wire                i_rst,
    input  wire                i_en,
    input  wire         [31:0] i_data_a,
    input  wire         [31:0] i_data_b,
    input  rv32_compop         i_compop,
    input  rv32_arithop        i_arithop,
    input  rv32_logicop        i_logicop,
    input  rv32_divop          i_divop,
    input  rv32_mulop          i_mulop,
    input  rv32_aluop          i_aluop,
    output logic        [31:0] o_data,
    output wire                o_cmp_data,
    output wire                o_stall
);
    wire  [31:0] w_arith_data;
    wire  [31:0] w_div_data;
    wire  [31:0] w_mul_data;
    wire  [31:0] w_logic_data;
    wire  [ 3:0] w_flags;
    wire         w_div_stall;
    wire         w_mul_stall;
    logic        w_div_en;
    logic        w_mul_en;

    arithmetic_unit instance_arithmetic_unit (
        .i_data_a(i_data_a),
        .i_data_b(i_data_b),
        .i_arithop(i_arithop),
        .o_data(w_arith_data),
        .o_flags(w_flags)
    );

    logic_unit instance_logic_unit (
        .i_data_a(i_data_a),
        .i_data_b(i_data_b),
        .i_logicop(i_logicop),
        .o_data(w_logic_data)
    );

    comparison_unit instance_comparison_unit (
        .i_flags (w_flags),
        .i_compop(i_compop),
        .o_data  (o_cmp_data)
    );

    nri_div #(
        .N(32)
    ) instance_nri_div (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_en(w_div_en),
        .i_divop(i_divop),
        .i_data_n(i_data_a),
        .i_data_d(i_data_b),
        .o_data(w_div_data),
        .o_stall(w_div_stall)
    );

    booth_fma #(
        .N(32)
    ) instance_booth_fma (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_en(w_mul_en),
        .i_mulop(i_mulop),
        .i_data_a(i_data_a),
        .i_data_b(i_data_b),
        .i_data_c(32'b0),
        .o_data(w_mul_data),
        .o_stall(w_mul_stall)
    );

    always_comb begin
        case (i_aluop)
            aluop_ari: begin
                o_data = w_arith_data;
            end
            aluop_cmp: begin
                o_data = {31'b0, o_cmp_data};
            end
            aluop_log: begin
                o_data = w_logic_data;
            end
            aluop_mul: begin
                o_data = w_mul_data;
            end
            aluop_div: begin
                o_data = w_div_data;
            end
            default: begin
                o_data = 32'b0;
            end
        endcase
    end

    always_comb begin
        case (i_aluop)
            aluop_div: begin
                w_div_en = i_en;
            end
            default: begin
                w_div_en = 1'b0;
            end
        endcase
    end

    always_comb begin
        case (i_aluop)
            aluop_mul: begin
                w_mul_en = i_en;
            end
            default: begin
                w_mul_en = 1'b0;
            end
        endcase
    end

    assign o_stall = w_mul_stall || w_div_stall;

endmodule
