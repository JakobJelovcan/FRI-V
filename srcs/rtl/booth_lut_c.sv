`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 06/02/2024 06:38:58 AM
// Design Name: 
// Module Name: booth_lut_c
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


module booth_lut_c (
    output wire o_data_p,
    output wire o_data_g
);

    assign o_data_p = 1'b1;
    assign o_data_g = 1'b1;
endmodule
