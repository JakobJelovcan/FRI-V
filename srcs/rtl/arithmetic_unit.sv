`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 04/17/2024 07:20:55 PM
// Design Name: 
// Module Name: arithmetic_unit
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

module arithmetic_unit (
    input  wire         [31:0] i_data_a,
    input  wire         [31:0] i_data_b,
    input  rv32_arithop        i_arithop,
    output wire         [31:0] o_data,
    output wire         [ 3:0] o_flags
);

    wire [31:0] w_sub;
    wire [31:0] w_const;
    wire [31:0] w_carry;
    wire [31:0] w_generate;
    wire [31:0] w_propagate;

    wire        w_flag_n;
    wire        w_flag_z;
    wire        w_flag_c;
    wire        w_flag_v;

    assign w_flag_n = o_data[31];
    assign w_flag_z = (o_data == 32'h0);
    assign w_flag_c = w_carry[31];
    assign w_flag_v = w_carry[31] ^ w_carry[30];
    assign o_flags  = {w_flag_v, w_flag_c, w_flag_z, w_flag_n};

    assign w_sub    = {(32){i_arithop[0]}};
    assign w_const  = {(32){i_arithop[1]}};

    assign w_generate  = i_data_a & (((i_data_b & ~w_const) | (32'h4 & w_const)) ^ w_sub);
    assign w_propagate = i_data_a ^ (((i_data_b & ~w_const) | (32'h4 & w_const)) ^ w_sub);

    generate
        for (genvar i = 0; i < 8; ++i) begin
            carry_4 instance_carry_4 (
                .CO(w_carry[i*4+:4]),
                .O(o_data[i*4+:4]),
                .CI((i == 0) ? 1'b0 : w_carry[i*4-1]),
                .CYINIT((i == 0) ? w_sub[0] : 1'b0),
                .DI(w_generate[i*4+:4]),
                .S(w_propagate[i*4+:4])
            );
        end
    endgenerate
endmodule
