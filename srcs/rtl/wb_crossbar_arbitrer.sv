`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 06/04/2024 07:49:42 PM
// Design Name: 
// Module Name: wb_crossbar_arbitrer
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

import functions::*;

module wb_crossbar_arbitrer #(
    parameter  int NM  = 2,                  // Number of masters
    parameter  int NS  = 2,                  // Number of slaves
    localparam int NSW = max(1, $clog2(NS))  // Number of slaves width
) (
    input  wire [NM-1:0][NS-1:0] i_requested,
    input  wire [NM-1:0][NS-1:0] i_allocated,
    input  wire [NM-1:0]         i_m_allocated,
    input  wire [NS-1:0]         i_s_allocated,
    output wire [NM-1:0][NS-1:0] o_granted
);

    wire [NM-1:0][NS-1:0] w_allocated;

    generate
        assign w_allocated[0] = i_s_allocated;
        for (genvar m = 1; m < NM; ++m) begin
            assign w_allocated[m] = w_allocated[m-1] | i_requested[m-1];
        end
    endgenerate

    generate
        for (genvar m = 0; m < NM; ++m) begin
            for (genvar s = 0; s < NS; ++s) begin
                assign o_granted[m][s] = i_requested[m][s] && (i_allocated[m][s] || (!w_allocated[m][s] && !i_m_allocated[m]));
            end
        end
    endgenerate

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                        Parameter validation                                         //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    generate
        if (NM < 1)
            $error($sformatf("Invalid number of masters (%d). Value has to be larger than 0.", NM));

        if (NS < 1)
            $error($sformatf("Invalid number of slaves (%d). Value has to be larger than 0.", NS));
    endgenerate
endmodule
