`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Jakob Jelovcan
//
// Create Date: 06/23/2023 06:22:48 PM
// Design Name:
// Module Name: fetch
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

module fetch (
    input  wire        i_clk,
    input  wire        i_flush,
    input  wire        i_stall,
    input  wire [31:0] i_branch_addr,
    input  wire        i_branch_taken,
    output wire [31:0] o_pc,
    output wire        o_valid
);

    reg [31:0] r_pc;

    always_ff @(posedge i_clk) begin
        if (i_flush) begin
            r_pc <= '0;
        end else if (!i_stall) begin
            if (i_branch_taken) begin
                r_pc <= i_branch_addr;
            end else begin
                r_pc <= r_pc + 4;
            end
        end
    end

    assign o_valid = 1'b1;
    assign o_pc    = r_pc;
endmodule
