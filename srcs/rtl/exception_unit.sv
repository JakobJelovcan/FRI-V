`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 11/24/2023 06:57:24 PM
// Design Name: 
// Module Name: exception_unit
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

module exception_unit (
    input  wire                  i_clk,
    input  wire                  i_rst,
    input  wire                  i_err_handled,
    input  ma_error              i_ma_error,
    input  ex_error              i_ex_error,
    input  wire     [ 1:0][31:0] i_pc,
    output wire                  o_err_pending,
    output wire     [31:0]       o_err_pc,
    output wire     [31:0]       o_err_cause,
    output wire     [ 1:0]       o_core_err
);

    wire [1:0][31:0] w_err_pc;
    wire [1:0][31:0] w_err_cause;
    wire [1:0]       w_err_pending;
    wire             w_err_index;

    lzd #(
        .N(2),
        .B(2)
    ) instance_lzd (
        .i_data (w_err_pending),
        .o_index(w_err_index),
        .o_valid(o_err_pending)
    );

    exception_priority_unit #(
        .E(5),
        .C({32'h0b, 32'h03, 32'h02, 32'h01, 32'h00})
    ) instance_ex_exception_priority_unit (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_err_handled(i_err_handled),
        .i_err_pending({
            i_ex_error.ecall,
            i_ex_error.ebreak,
            i_ex_error.invalid_inst,
            i_ex_error.access_fault,
            i_ex_error.address_misaligned
        }),
        .o_err_pending(w_err_pending[1]),
        .o_err_cause(w_err_cause[1])
    );

    exception_priority_unit #(
        .E(4),
        .C({32'h07, 32'h06, 32'h05, 32'h04})
    ) instance_ma_exception_priority_unit (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_err_handled(i_err_handled),
        .i_err_pending({
            i_ma_error.store_access_fault,
            i_ma_error.store_address_misaligned,
            i_ma_error.load_access_fault,
            i_ma_error.load_address_misaligned
        }),
        .o_err_pending(w_err_pending[0]),
        .o_err_cause(w_err_cause[0])
    );

    assign o_err_cause = w_err_cause[w_err_index];
    assign o_err_pc    = i_pc[w_err_index];
    assign o_core_err  = {1'b0, w_err_pending[0], w_err_pending[1]};
endmodule
