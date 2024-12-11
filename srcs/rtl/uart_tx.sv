`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 09/10/2023 02:03:11 PM
// Design Name: 
// Module Name: uart_tx
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

module uart_tx (
    input  wire            i_clk,
    input  wire            i_rst,
    input  wire            i_we,
    input  wire      [8:0] i_data,
    input  uart_size       i_size,
    input  uart_freq       i_freq,
    output wire            o_tx,
    output wire            o_done
);
    wire         w_uart_clk;
    wire         w_shift;
    logic [10:0] w_data;

    uart_tx_fsm instance_uart_tx_fsm (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_en(i_we),
        .i_uart_clk(w_uart_clk),
        .i_size(i_size),
        .o_shift(w_shift),
        .o_done(o_done)
    );

    uart_clk_div #(
        .RESET_TO_HALF(1'b0)
    ) instance_uart_clk (
        .i_clk (i_clk),
        .i_rst (i_rst),
        .i_freq(i_freq),
        .o_clk (w_uart_clk)
    );

    piso #(
        .N(11),
        .R(1'b1)
    ) instance_piso (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_we(i_we),
        .i_shift(w_shift),
        .i_data(w_data),
        .o_data(o_tx)
    );

    always_comb begin
        case (i_size)
            uart_5: begin
                w_data = {4'hf, i_data[4:0], 2'b01};
            end
            uart_6: begin
                w_data = {3'h7, i_data[5:0], 2'b01};
            end
            uart_7: begin
                w_data = {2'h3, i_data[6:0], 2'b01};
            end
            uart_8: begin
                w_data = {1'h1, i_data[7:0], 2'b01};
            end
            uart_9: begin
                w_data = {i_data[8:0], 2'b01};
            end
            default: begin
                w_data = 0;
            end
        endcase
    end
endmodule
