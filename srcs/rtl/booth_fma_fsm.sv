`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 05/25/2024 06:34:30 PM
// Design Name: 
// Module Name: booth_fma_fsm
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

module booth_fma_fsm #(
    parameter  int K = 4,         // Number of iterations
    localparam int J = $clog2(K)  // Size of the iteration counter
) (
    input  wire          i_clk,
    input  wire          i_rst,
    input  wire          i_en,
    output wire  [J-1:0] o_index,
    output logic         o_stall,
    output logic         o_we
);
    reg       [J-1:0] r_index;
    logic     [J-1:0] w_next_index;
    wire              w_mul_en;

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_index <= '0;
        end else if (w_mul_en) begin
            r_index <= w_next_index;
        end
    end

    always_comb begin
        if (r_index == (J)'(K - 1)) begin
            w_next_index = '0;
        end else begin
            w_next_index = r_index + 1;
        end
    end

    assign w_mul_en = i_en || (r_index > 0);
    assign o_index  = r_index;
    assign o_we     = w_mul_en;
    assign o_stall  = w_mul_en;

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                        Parameter validation                                         //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    generate
        if (K < 1)
            $error(
                $sformatf("Invalid number of iterations (%d). Value has to be larger than 0.", K)
            );
    endgenerate

endmodule
