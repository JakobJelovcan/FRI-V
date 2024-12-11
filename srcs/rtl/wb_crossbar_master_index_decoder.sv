`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 04/28/2024 10:58:00 AM
// Design Name: 
// Module Name: wb_crossbar_master_index_decoder
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

module wb_crossbar_master_index_decoder #(
    parameter  int NM  = 2,                  // Number of masters
    parameter  int NS  = 2,                  // Number of slaves
    localparam int NSW = max(1, $clog2(NS))  // Number of slaves width
) (
    input  wire  [NM-1:0][ NS-1:0] i_granted,
    input  wire  [NM-1:0]          i_m_allocated,
    output logic [NM-1:0][NSW-1:0] o_index,
    output logic [NM-1:0]          o_connect,
    output wire  [NM-1:0]          o_disconnect
);

    generate
        for (genvar m = 0; m < NM; ++m) begin
            always_comb begin
                o_index[m]   = '0;
                o_connect[m] = '0;

                for (int s = NS - 1; s >= 0; --s) begin
                    if (i_granted[m][s]) begin
                        o_index[m]   = s;
                        o_connect[m] = '1;
                    end
                end
            end
        end
    endgenerate

    assign o_disconnect = ~o_connect & i_m_allocated;

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
