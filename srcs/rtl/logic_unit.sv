`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 04/17/2024 07:21:13 PM
// Design Name: 
// Module Name: logic_unit
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

module logic_unit (
    input  wire signed   [31:0] i_data_a,
    input  wire signed   [31:0] i_data_b,
    input  rv32_logicop         i_logicop,
    output logic         [31:0] o_data
);

    wire unsigned [4:0] w_shamt = i_data_b[4:0];

    always_comb begin
        case (i_logicop)
            logicop_and: begin
                o_data = i_data_a & i_data_b;
            end
            logicop_orr: begin
                o_data = i_data_a | i_data_b;
            end
            logicop_xor: begin
                o_data = i_data_a ^ i_data_b;
            end
            logicop_sll: begin
                o_data = i_data_a << w_shamt;
            end
            logicop_srl: begin
                o_data = i_data_a >> w_shamt;
            end
            logicop_sra: begin
                o_data = i_data_a >>> w_shamt;
            end
            default: begin
                o_data = 32'b0;
            end
        endcase
    end
endmodule
