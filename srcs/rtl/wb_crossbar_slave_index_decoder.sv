`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 04/28/2024 10:58:00 AM
// Design Name: 
// Module Name: wb_crossbar_slave_index_decoder
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

module wb_crossbar_slave_index_decoder #(
    parameter  int NM  = 2,                  // Number of masters
    parameter  int NS  = 2,                  // Number of slaves
    localparam int NMW = max(1, $clog2(NM))  // Number of masters width
) (
    input  wire  [NM-1:0][ NS-1:0] i_granted,
    input  wire  [NS-1:0]          i_s_allocated,
    output logic [NS-1:0][NMW-1:0] o_index,
    output logic [NS-1:0]          o_connect,
    output logic [NS-1:0]          o_disconnect
);

    generate
        for (genvar s = 0; s < NS; ++s) begin
            always_comb begin
                o_index[s]   = '0;
                o_connect[s] = '0;

                for (int m = NM - 1; m >= 0; --m) begin
                    if (i_granted[m][s]) begin
                        o_index[s]   = m;
                        o_connect[s] = 1;
                    end
                end
            end
        end
    endgenerate

    assign o_disconnect = ~o_connect & i_s_allocated;

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
