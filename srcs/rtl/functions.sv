`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Jakob Jelovcan
//
// Create Date: 06/23/2023 07:37:46 PM
// Design Name:
// Module Name: functions
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



package functions;
    function automatic [31:0] decode_i_immed(input [31:0] inst);
        return 32'(signed'(inst[31:20]));
    endfunction

    function automatic [31:0] decode_s_immed(input [31:0] inst);
        return 32'(signed'({inst[31:25], inst[11:7]}));
    endfunction

    function automatic [31:0] decode_b_immed(input [31:0] inst);
        return 32'(signed'({inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}));
    endfunction

    function automatic [31:0] decode_u_immed(input [31:0] inst);
        return 32'(signed'({inst[31:12], 12'b0}));
    endfunction

    function automatic [31:0] decode_j_immed(input [31:0] inst);
        return 32'(signed'({inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}));
    endfunction

    function automatic [31:0] decode_z_immed(input [31:0] inst);
        return 32'(unsigned'({inst[19:15], inst[31:20]}));
    endfunction

    function automatic int max(input int a, input int b);
        return (a > b) ? a : b;
    endfunction

    function automatic int min(input int a, input int b);
        return (a < b) ? a : b;
    endfunction
endpackage
