`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 03/15/2024 07:17:44 PM
// Design Name: 
// Module Name: uart_rx_fsm
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

module uart_rx_fsm (
    input  wire      i_clk,
    input  wire      i_rst,
    input  wire      i_rx,
    input  wire      i_uart_clk,
    input  uart_size i_size,
    output logic     o_shift,
    output wire      o_done,
    output wire      o_rst
);

    typedef enum logic [1:0] {
        idle,
        start_bit,
        rcv_bit,
        stop_bit
    } fsm_state;

    logic [3:0] w_max_index;
    logic [3:0] w_next_index;
    reg   [3:0] r_index;

    fsm_state r_state;
    fsm_state w_next_state;

    always_comb begin
        case (i_size)
            uart_5: begin
                w_max_index = 4'h4;
            end
            uart_6: begin
                w_max_index = 4'h5;
            end
            uart_7: begin
                w_max_index = 4'h6;
            end
            uart_8: begin
                w_max_index = 4'h7;
            end
            uart_9: begin
                w_max_index = 4'h8;
            end
            default: begin
                w_max_index = 4'h0;
            end
        endcase
    end

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_state <= idle;
            r_index <= 4'h0;
        end else begin
            r_state <= w_next_state;
            r_index <= w_next_index;
        end
    end

    always_comb begin
        if (i_uart_clk) begin
            if (r_state == rcv_bit) begin
                w_next_index = r_index + 1;
            end else begin
                w_next_index = 4'h0;
            end
        end else begin
            w_next_index = r_index;
        end
    end

    always_comb begin
        w_next_state = r_state;
        case (r_state)
            idle: begin
                if (!i_rx) begin
                    w_next_state = start_bit;
                end
            end
            start_bit: begin
                if (i_uart_clk) begin
                    w_next_state = rcv_bit;
                end
            end
            rcv_bit: begin
                if (i_uart_clk && r_index == w_max_index) begin
                    w_next_state = stop_bit;
                end
            end
            stop_bit: begin
                if (i_uart_clk) begin
                    w_next_state = idle;
                end
            end
            default: begin
            end
        endcase
    end

    always_comb begin
        case (r_state)
            start_bit, rcv_bit: begin
                o_shift = i_uart_clk;
            end
            default: begin
                o_shift = 1'b0;
            end
        endcase
    end

    assign o_rst  = (r_state == idle) && !i_rx || i_rst;
    assign o_done = (r_state == stop_bit) && i_uart_clk;
endmodule
