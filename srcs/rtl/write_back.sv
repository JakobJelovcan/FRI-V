`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Jakob Jelovcan
//
// Create Date: 06/24/2023 03:31:27 PM
// Design Name:
// Module Name: write_back
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

module write_back (
    input  wire                       i_clk,
    input  wire                       i_flush,
    input  wire                       i_valid,
    input  wire                       i_stall,
    input  wire                [ 1:0] i_offset,
    input  rv32_instruction_ma        i_inst,
    input  wire                [31:0] i_data,
    output wire                [31:0] o_data,
    output wire                [ 1:0] o_offset,
    output wire                       o_valid,
    output rv32_memop                 o_memop,
    output rv32_register              o_rd
);

    reg                        r_valid;
    reg                 [ 1:0] r_offset;
    reg                 [31:0] r_data;
    rv32_instruction_ma        r_inst;

    always_ff @(posedge i_clk) begin
        if (!i_stall) begin
            r_data   <= i_data;
            r_offset <= i_offset;
            r_inst   <= i_inst;
        end
    end

    always_ff @(posedge i_clk) begin
        if (i_flush) begin
            r_valid <= 1'b0;
        end else if (!i_stall) begin
            r_valid <= i_valid;
        end
    end

    assign o_valid  = r_valid;
    assign o_offset = r_offset;
    assign o_data   = r_data;
    assign o_memop  = r_inst.memop;
    assign o_rd     = r_inst.rd;
endmodule
