`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 09/10/2023 06:44:28 PM
// Design Name: 
// Module Name: wb_uart
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

module wb_uart #(
    parameter  bit          WB_REGISTERED = 0,
    localparam logic [31:0] UART_CR       = 32'h???????0,
    localparam logic [31:0] UART_RX       = 32'h???????4,
    localparam logic [31:0] UART_TX       = 32'h???????8
) (
    input  wire        i_clk,
    input  wire        i_rst,
    input  wire        i_wb_stb,
    input  wire        i_wb_cyc,
    input  wire        i_wb_we,
    input  wire [31:0] i_wb_addr,
    input  wire [31:0] i_wb_data,
    input  wire [ 3:0] i_wb_sel,
    input  wire [ 2:0] i_wb_cti,
    output wire        o_rx_int,
    output wire        o_tx_int,
    output reg         o_wb_ack,
    output reg  [31:0] o_wb_data,
    output reg         o_wb_err,

    input  wire i_rx,
    output wire o_tx
);
    wire               w_uart_rst;
    wire               w_error;
    logic              w_tx_we;
    wire               w_tx_done;
    wire               w_rx_done;

    wire         [8:0] w_rx_data;
    reg          [8:0] r_rx_data;
    uart_control       r_control;

    uart_rx instance_uart_rx (
        .i_clk (i_clk),
        .i_rst (w_uart_rst),
        .i_rx  (i_rx),
        .i_freq(r_control.freq),
        .i_size(r_control.size),
        .o_data(w_rx_data),
        .o_done(w_rx_done)
    );

    uart_tx instance_uart_tx (
        .i_clk (i_clk),
        .i_rst (w_uart_rst),
        .i_we  (w_tx_we),
        .i_data(i_wb_data[8:0]),
        .i_freq(r_control.freq),
        .i_size(r_control.size),
        .o_tx  (o_tx),
        .o_done(w_tx_done)
    );
    
    address_validation_unit #(
        .N(32),
        .M(3),
        .ADDR_MAP({
            32'h00000000,
            32'h00000004,
            32'h00000008
        }),
        .MASK_MAP({
            32'h0000000f,
            32'h0000000f,
            32'h0000000f
        }),
        .WO(3'b000),
        .RO(3'b010)
    ) instance_address_validation_unit (
        .i_addr(i_wb_addr),
        .i_valid(i_wb_stb),
        .i_we(i_wb_we),
        .o_error(w_error)
    );

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_control <= uart_control_default;
        end else begin
            r_control.rxne |= w_rx_done;
            r_control.txe  |= w_tx_done;
            if (i_wb_stb) begin
                casez (i_wb_addr)
                    UART_CR: begin
                        if (i_wb_we) begin
                            r_control.en        <= i_wb_data[0];
                            r_control.rx_int_en <= i_wb_data[9];
                            r_control.tx_int_en <= i_wb_data[10];
                            if (!r_control.en || !i_wb_data[0]) begin
                                r_control.freq <= uart_freq'(i_wb_data[5:3]);
                                r_control.size <= uart_size'(i_wb_data[8:6]);
                            end
                        end
                    end
                    UART_RX: begin
                        r_control.rxne &= i_wb_we;
                    end
                    UART_TX: begin
                        r_control.txe &= !i_wb_we;
                    end
                endcase
            end
        end
    end

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_rx_data <= '0;
        end else if (w_rx_done) begin
            r_rx_data <= w_rx_data;
        end
    end

    always_comb begin
        casez (i_wb_addr)
            UART_TX: begin
                w_tx_we = i_wb_we && i_wb_stb && r_control.txe;
            end
            default: begin
                w_tx_we = '0;
            end
        endcase
    end

    generate
        if (WB_REGISTERED) begin
            always_ff @(posedge i_clk) begin
                if (i_rst) begin
                    o_wb_data <= '0;
                end else if (i_wb_stb && !i_wb_we) begin
                    casez (i_wb_addr)
                        UART_CR: begin
                            o_wb_data <= {{(32 - $bits(uart_control)) {1'b0}}, r_control};
                        end
                        UART_RX: begin
                            o_wb_data <= {23'b0, r_rx_data};
                        end
                        default: begin
                            o_wb_data <= '0;
                        end
                    endcase
                end else begin
                    o_wb_data <= '0;
                end
            end

            always_ff @(posedge i_clk) begin
                if (i_rst) begin
                    o_wb_ack <= '0;
                    o_wb_err <= '0;
                end else if (i_wb_stb && !(o_wb_ack || o_wb_err)) begin
                    o_wb_ack <= !w_error;
                    o_wb_err <= w_error;
                end else begin
                    o_wb_ack <= '0;
                    o_wb_err <= '0;
                end
            end
        end else begin
            always_comb begin
                casez (i_wb_addr)
                    UART_CR: begin
                        o_wb_data = {{(32 - $bits(uart_control)) {1'b0}}, r_control};
                    end
                    UART_RX: begin
                        o_wb_data = {23'b0, r_rx_data};
                    end
                    default: begin
                        o_wb_data = '0;
                    end
                endcase
            end

            assign o_wb_err = i_wb_stb && w_error;
            assign o_wb_ack = i_wb_stb && !w_error;
        end
    endgenerate

    assign o_rx_int   = r_control.rx_int_en && w_rx_done;
    assign o_tx_int   = r_control.tx_int_en && w_tx_done;
    assign w_uart_rst = i_rst || !r_control.en;
endmodule
