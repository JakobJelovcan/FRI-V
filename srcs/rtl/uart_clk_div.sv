`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 03/15/2024 07:44:36 PM
// Design Name: 
// Module Name: uart_clk_div
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
import constants::*;

module uart_clk_div #(
    parameter bit RESET_TO_HALF = 0
) (
    input  wire      i_clk,
    input  wire      i_rst,
    input  uart_freq i_freq,
    output wire      o_clk
);

    logic [UART_CNT_SIZE-1:0] w_max_val;
    reg   [UART_CNT_SIZE-1:0] r_counter;

    always_comb begin
        case (i_freq)
            uart_9600: begin
                w_max_val = UART_9600_CNT;
            end
            uart_19200: begin
                w_max_val = UART_19200_CNT;
            end
            uart_38400: begin
                w_max_val = UART_38400_CNT;
            end
            uart_57600: begin
                w_max_val = UART_57600_CNT;
            end
            uart_115200: begin
                w_max_val = UART_115200_CNT;
            end
            default: begin
                w_max_val = 0;
            end
        endcase
    end

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            if (RESET_TO_HALF == 1'b1) begin
                r_counter <= w_max_val >> 1;
            end else begin
                r_counter <= 0;
            end
        end else if (r_counter == w_max_val) begin
            r_counter <= 0;
        end else begin
            r_counter <= r_counter + 1;
        end
    end

    assign o_clk = (r_counter == w_max_val);

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                         Formal verification                                         //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    `ifdef FORMAL
        initial restrict(i_rst);

        always @(posedge i_clk) begin

            assume(i_freq == uart_9600 ||
                   i_freq == uart_19200 ||
                   i_freq == uart_38400 ||
                   i_freq == uart_57600 ||
                   i_freq == uart_115200);
            
            if (!i_rst) begin
                assume($stable(i_freq));
                if (RESET_TO_HALF) begin
                    assert(r_counter == w_max_val >> 1 || r_counter == $past(r_counter) + 1);
                end else begin
                    assert(r_counter == 0 || r_counter == $past(r_counter) + 1);
                end
                assert((r_counter == w_max_val) ~^ o_clk);
                assert(r_counter <= w_max_val);
                cover(o_clk);
            end

            if ($fell(i_rst)) begin
                if (RESET_TO_HALF) begin
                    assert(r_counter == w_max_val >> 1);
                end else begin
                    assert(r_counter == 0);
                end
                assert(!o_clk);
            end
        end
    `endif
endmodule
