`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 04/18/2024 11:05:37 AM
// Design Name: 
// Module Name: comparison_unit
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

module comparison_unit (
    input  wire      [3:0] i_flags,
    input  rv32_compop     i_compop,
    output logic           o_data
);

    wire w_flag_n, w_flag_z, w_flag_c, w_flag_v;

    assign {w_flag_v, w_flag_c, w_flag_z, w_flag_n} = i_flags;

    always_comb begin
        case (i_compop)
            compop_eq: begin
                o_data = w_flag_z;
            end
            compop_ne: begin
                o_data = !w_flag_z;
            end
            compop_lts: begin
                o_data = w_flag_n != w_flag_v;
            end
            compop_ltu: begin
                o_data = !w_flag_c;
            end
            compop_ges: begin
                o_data = w_flag_n == w_flag_v;
            end
            compop_geu: begin
                o_data = w_flag_c;
            end
            default: begin
                o_data = 1'b0;
            end
        endcase
    end
endmodule
