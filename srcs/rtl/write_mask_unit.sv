`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 09/17/2023 07:34:59 AM
// Design Name: 
// Module Name: write_mask_unit
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

module write_mask_unit (
    input  wire       [1:0] i_index,
    input  rv32_memop       i_memop,
    output logic      [3:0] o_mask,
    output logic            o_error
);

    always_comb begin
        case (i_memop)
            memop_s_byte, memop_l_byte, memop_l_ubyte: begin
                o_mask  = 4'b0001 << i_index;
                o_error = i_index !=? 2'b??;
            end
            memop_s_hword, memop_l_hword, memop_l_uhword: begin
                o_mask  = 4'b0011 << i_index;
                o_error = i_index !=? 2'b?0;
            end
            memop_s_word, memop_l_word: begin
                o_mask  = 4'b1111;
                o_error = i_index !=? 2'b00;
            end
            default: begin
                o_mask  = 4'b0000;
                o_error = 1'b0;
            end
        endcase
    end
endmodule
