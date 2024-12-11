`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 05/27/2024 07:40:16 PM
// Design Name: Non Restoring Integer Divider
// Module Name: nri_div
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

module nri_div #(
    parameter  int N = 32,        // Data size
    localparam int S = 4,         // Iteration size
    localparam int K = N / S,     // Number of iterations
    localparam int J = $clog2(K)  // Size of the iteration counter
) (
    input  wire               i_clk,
    input  wire               i_rst,
    input  wire               i_en,
    input  rv32_divop         i_divop,
    input  wire       [N-1:0] i_data_n,
    input  wire       [N-1:0] i_data_d,
    output logic      [N-1:0] o_data,
    output wire               o_stall
);

    wire                 w_we;
    wire  [J-1:0]        w_index;
    logic [  S:0][  N:0] w_data_r;
    logic [  S:0][N-1:0] w_data_q;
    reg   [  N:0]        r_data_r;
    reg   [N-1:0]        r_data_q;
    logic                w_signed;

    wire  [N-1:0]        w_data_q_conv;
    wire  [N-1:0]        w_data_r_conv;

    nri_div_fsm #(
        .K(K)
    ) instance_nri_div_fsm (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_en(i_en),
        .o_index(w_index),
        .o_stall(o_stall),
        .o_we(w_we)
    );

    nri_div_corrections_unit #(
        .N(N)
    ) instance_nri_div_corrections_unit (
        .i_data_n(i_data_n),
        .i_data_d(i_data_d),
        .i_data_q(r_data_q),
        .i_data_r(r_data_r),
        .i_signed(w_signed),
        .o_data_q(w_data_q_conv),
        .o_data_r(w_data_r_conv)
    );

    generate
        for (genvar i = 0; i < S; ++i) begin
            nri_div_row #(
                .N(N)
            ) instance_nri_div_row (
                .i_data_r(w_data_r[i]),
                .i_data_q(w_data_q[i]),
                .i_data_d(i_data_d),
                .i_signed(w_signed),
                .o_data_r(w_data_r[i+1]),
                .o_data_q(w_data_q[i+1])
            );
        end
    endgenerate

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_data_q <= '0;
        end else if (w_we) begin
            r_data_q <= w_data_q[S];
        end
    end

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_data_r <= '0;
        end else if (w_we) begin
            r_data_r <= w_data_r[S];
        end
    end

    always_comb begin
        case (i_divop)
            divop_div, divop_divu: begin
                o_data = w_data_q_conv;
            end
            default: begin
                o_data = w_data_r_conv;
            end
        endcase
    end

    always_comb begin
        if (w_index != 0) begin
            {w_data_r[0], w_data_q[0]} = {r_data_r, r_data_q};
        end else if (w_signed) begin
            {w_data_r[0], w_data_q[0]} = (2 * N + 1)'(signed'(i_data_n));
        end else begin
            {w_data_r[0], w_data_q[0]} = (2 * N + 1)'(unsigned'(i_data_n));
        end
    end

    always_comb begin
        case (i_divop)
            divop_div, divop_rem: begin
                w_signed = 1'b1;
            end
            default: begin
                w_signed = 1'b0;
            end
        endcase
    end

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                        Parameter validation                                         //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    generate
        if (N < 4 || (2 ** $clog2(N)) != N)
            $error(
                $sformatf("Invalid size (%d). Value has to be larger than 3 and a power of 2.", N)
            );
    endgenerate

endmodule
