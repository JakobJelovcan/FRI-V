`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 09/10/2023 03:03:16 PM
// Design Name: 
// Module Name: uart_rx
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

module uart_rx (
    input  wire            i_clk,
    input  wire            i_rst,
    input  wire            i_rx,
    input  uart_freq       i_freq,
    input  uart_size       i_size,
    output logic     [8:0] o_data,
    output wire            o_done
);
    wire       w_uart_clk;
    wire       w_shift;
    wire       w_uart_rst;
    wire [8:0] w_data;

    uart_rx_fsm instance_uart_rx_fsm (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_rx(i_rx),
        .i_uart_clk(w_uart_clk),
        .i_size(i_size),
        .o_shift(w_shift),
        .o_done(o_done),
        .o_rst(w_uart_rst)
    );

    uart_clk_div #(
        .RESET_TO_HALF(1'b1)
    ) instance_uart_clk (
        .i_clk (i_clk),
        .i_rst (w_uart_rst),
        .i_freq(i_freq),
        .o_clk (w_uart_clk)
    );

    sipo #(
        .N(9)
    ) instance_sipo (
        .i_clk  (i_clk),
        .i_rst  (w_uart_rst),
        .i_data (i_rx),
        .i_shift(w_shift),
        .o_data (w_data)
    );

    always_comb begin
        case (i_size)
            uart_5: begin
                o_data = {4'b0, w_data[8:4]};
            end
            uart_6: begin
                o_data = {3'b0, w_data[8:3]};
            end
            uart_7: begin
                o_data = {2'b0, w_data[8:2]};
            end
            uart_8: begin
                o_data = {1'b0, w_data[8:1]};
            end
            uart_9: begin
                o_data = w_data[8:0];
            end
            default: begin
                o_data = 9'b0;
            end
        endcase
    end
endmodule
