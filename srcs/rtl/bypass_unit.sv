`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Jakob Jelovcan
//
// Create Date: 06/24/2023 10:21:52 AM
// Design Name:
// Module Name: bypass_unit
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

module bypass_unit (
    input  rv32_memop           i_ex_memop,
    input  rv32_register        i_rd_ex,
    input  rv32_memop           i_ma_memop,
    input  rv32_register        i_rd_ma,
    input  rv32_register        i_rd_wb,
    input  wire          [31:0] i_data_a,
    input  wire          [31:0] i_data_b,
    input  wire          [31:0] i_data_ex,
    input  wire          [31:0] i_data_ma,
    input  wire          [31:0] i_data_wb,
    input  wire                 i_valid_ex,
    input  wire                 i_valid_ma,
    input  wire                 i_valid_wb,
    input  rv32_register        i_rs1,
    input  rv32_register        i_rs2,
    output wire          [31:0] o_data_a,
    output wire          [31:0] o_data_b,
    output wire                 o_hazard
);

    wire w_rs1_valid;
    wire w_rs2_valid;
    wire w_ex_valid;
    wire w_ma_valid;

    wire w_match_ex_a;
    wire w_match_ma_a;
    wire w_match_wb_a;

    wire w_match_ex_b;
    wire w_match_ma_b;
    wire w_match_wb_b;

    reg [3:0] w_hazard;

    wire [1:0] w_index_a;
    wire [1:0] w_index_b;

    wire [31:0] w_data_a[3:0];
    wire [31:0] w_data_b[3:0];

    lzd #(
        .N(4),
        .B(4)
    ) instance_lzd_a (
        .i_data ({1'b1, w_match_wb_a, w_match_ma_a, w_match_ex_a}),
        .o_index(w_index_a),
        .o_valid()
    );

    lzd #(
        .N(4),
        .B(4)
    ) instance_lzd_b (
        .i_data ({1'b1, w_match_wb_b, w_match_ma_b, w_match_ex_b}),
        .o_index(w_index_b),
        .o_valid()
    );

    assign w_ex_valid = !(i_ex_memop inside { rv32_l_memop });
    assign w_ma_valid = !(i_ma_memop inside { memop_l_byte, memop_l_ubyte, memop_l_hword, memop_l_uhword });
    assign w_rs1_valid = (i_rs1 != '0);
    assign w_rs2_valid = (i_rs2 != '0);

    assign w_match_ex_a = (w_rs1_valid && i_valid_ex && i_rs1 == i_rd_ex);
    assign w_match_ma_a = (w_rs1_valid && i_valid_ma && i_rs1 == i_rd_ma);
    assign w_match_wb_a = (w_rs1_valid && i_valid_wb && i_rs1 == i_rd_wb);

    assign w_match_ex_b = (w_rs2_valid && i_valid_ex && i_rs2 == i_rd_ex);
    assign w_match_ma_b = (w_rs2_valid && i_valid_ma && i_rs2 == i_rd_ma);
    assign w_match_wb_b = (w_rs2_valid && i_valid_wb && i_rs2 == i_rd_wb);

    assign w_data_a = {i_data_a, i_data_wb, i_data_ma, i_data_ex};
    assign w_data_b = {i_data_b, i_data_wb, i_data_ma, i_data_ex};
    assign w_hazard = {1'b0, 1'b0, !w_ma_valid, !w_ex_valid};

    assign o_hazard = w_hazard[w_index_a] || w_hazard[w_index_b];
    assign o_data_a = w_data_a[w_index_a];
    assign o_data_b = w_data_b[w_index_b];

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                         Formal verification                                         //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    `ifdef FORMAL
        always @ (*) begin
            if (w_match_ex_a) begin
                assert(o_data_a == i_data_ex);
                assert(w_hazard[w_index_a] != w_ex_valid);
                assert(w_index_a == 0);
            end else if (w_match_ma_a) begin
                assert(o_data_a == i_data_ma);
                assert(w_hazard[w_index_a] != w_ma_valid);
                assert(w_index_a == 1);
            end else if (w_match_wb_a) begin
                assert(o_data_a == i_data_wb);
                assert(!w_hazard[w_index_a]);
                assert(w_index_a == 2);
            end else begin
                assert(o_data_a == i_data_a);
                assert(!w_hazard[w_index_a]);
                assert(w_index_a == 3);
            end

            if (w_match_ex_b) begin
                assert(o_data_b == i_data_ex);
                assert(w_hazard[w_index_b] != w_ex_valid);
                assert(w_index_b == 0);
            end else if (w_match_ma_b) begin
                assert(o_data_b == i_data_ma);
                assert(w_hazard[w_index_b] != w_ma_valid);
                assert(w_index_b == 1);
            end else if (w_match_wb_b) begin
                assert(o_data_b == i_data_wb);
                assert(!w_hazard[w_index_b]);
                assert(w_index_b == 2);
            end else begin
                assert(o_data_b == i_data_b);
                assert(!w_hazard[w_index_b]);
                assert(w_index_b == 3);
            end

            if (!i_valid_ex && !i_valid_ma)
                assert(!o_hazard);

            if (i_rs1 == 0 && i_rs2 == 0)
                assert(!o_hazard);

            if (i_rs1 == 0)
                assert(w_index_a == 3);

            if (i_rs2 == 0)
                assert(w_index_b == 3);
        end
    `endif
endmodule
