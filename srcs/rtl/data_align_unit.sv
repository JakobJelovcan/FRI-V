`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 10/12/2023 01:54:05 PM
// Design Name: 
// Module Name: data_align_unit
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


module data_align_unit (
    input  wire [ 1:0] i_offset,
    input  wire [31:0] i_data,
    output wire [31:0] o_data
);

    assign o_data = i_data << {i_offset, 3'b0};
endmodule
