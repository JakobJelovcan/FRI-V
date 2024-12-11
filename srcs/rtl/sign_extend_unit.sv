`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Jakob Jelovcan
//
// Create Date: 06/24/2023 01:10:42 PM
// Design Name:
// Module Name: sign_extend_unit
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

module sign_extend_unit (
    input  wire       [31:0] i_data,
    input  wire       [ 1:0] i_offset,
    input  rv32_memop        i_memop,
    output logic      [31:0] o_data
);

    wire [1:0] w_b_offset;
    wire [0:0] w_h_offset;

    assign w_b_offset = i_offset;
    assign w_h_offset = i_offset[1];

    always_comb begin
        case (i_memop)
            memop_l_byte: begin
                o_data = 32'(signed'(i_data[w_b_offset*8+:8]));
            end
            memop_l_hword: begin
                o_data = 32'(signed'(i_data[w_h_offset*16+:16]));
            end
            memop_l_ubyte: begin
                o_data = 32'(unsigned'(i_data[w_b_offset*8+:8]));
            end
            memop_l_uhword: begin
                o_data = 32'(unsigned'(i_data[w_h_offset*16+:16]));
            end
            default: begin
                o_data = i_data;
            end
        endcase
    end
endmodule
