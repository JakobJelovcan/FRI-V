`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 05/25/2024 06:28:11 PM
// Design Name: 
// Module Name: booth_fma
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

module booth_fma #(
    parameter  int N = 32,        // Width of the multiplier
    localparam int S = 4,         // Size of the iteration
    localparam int M = N / 2,     // Number of rows
    localparam int K = M / S,     // Number of iterations
    localparam int J = $clog2(K)  // Size of the iteration counter
) (
    input  wire               i_clk,
    input  wire               i_rst,
    input  wire               i_en,
    input  rv32_mulop         i_mulop,
    input  wire       [N-1:0] i_data_a,
    input  wire       [N-1:0] i_data_b,
    input  wire       [N-1:0] i_data_c,
    output logic      [N-1:0] o_data,
    output wire               o_stall
);
    wire                   w_we;
    logic                  w_signed;
    wire  [J-1:0]          w_index;
    logic [  S:0][  N+1:0] w_data_t;
    wire  [S-1:0][    1:0] w_data_p;
    wire  [N+3:0]          w_data_h;
    wire  [S-1:0][    2:0] w_data_b [K-1:0];

    reg   [N+1:0]          r_data_t;
    reg   [K-1:0][S*2-1:0] r_data_p;

    booth_fma_fsm #(
        .K(K)
    ) instance_booth_fma_fsm (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_en(i_en),
        .o_index(w_index),
        .o_stall(o_stall),
        .o_we(w_we)
    );

    booth_decoder #(
        .N(N),
        .S(S)
    ) instance_booth_decoder (
        .i_data(i_data_b),
        .o_data(w_data_b)
    );

    generate
        for (genvar i = 0; i < S; ++i) begin
            booth_row #(
                .N(N)
            ) instance_booth_row (
                .i_data_a(i_data_a),
                .i_data_b(w_data_b[w_index][i]),
                .i_data_c(w_data_t[i]),
                .i_signed(w_signed),
                .o_data  ({w_data_t[i+1], w_data_p[i]})
            );
        end
    endgenerate

    booth_row #(
        .N(N)
    ) instance_booth_row (
        .i_data_a(i_data_a),
        .i_data_b({2'b0, i_data_b[N-1]}),
        .i_data_c(r_data_t),
        .i_signed(w_signed),
        .o_data  (w_data_h)
    );

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_data_t <= {(N + 2) {1'b0}};
        end else if (w_we) begin
            r_data_t <= w_data_t[S];
        end
    end

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_data_p <= '{default: 0};
        end else if (w_we) begin
            r_data_p[w_index] <= w_data_p;
        end
    end

    always_comb begin
        case (i_mulop)
            mulop_mul: begin
                o_data = r_data_p;
            end
            mulop_mulh: begin
                o_data = r_data_t[N-1:0];
            end
            default: begin
                o_data = w_data_h[N-1:0];
            end
        endcase
    end

    always_comb begin
        if (w_index == 0) begin
            w_data_t[0] = {2'b10, i_data_c};
        end else begin
            w_data_t[0] = r_data_t;
        end
    end
    
    always_comb begin
        case (i_mulop)
            mulop_mulh,
            mulop_mulhsu: begin
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
            $error($sformatf("Invalid size (%d). Value has to be larger than 3 and a power of 2.", N));
    endgenerate  

endmodule
