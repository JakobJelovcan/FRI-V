`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 04/28/2024 06:39:38 AM
// Design Name: 
// Module Name: wb_crossbar_addr_decoder
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


module wb_crossbar_addr_decoder #(
    parameter int NM = 2,  // Number of used masters
    parameter int NS = 2,  // Number of used slaves
    parameter int AW = 32,  // Address width
    parameter logic [NS-1:0][AW-1:0] ADDR_MAP = '0,
    parameter logic [NS-1:0][AW-1:0] MASK_MAP = '0,
    parameter logic [NM-1:0][NS-1:0] WHITE_LIST = '0
) (
    input  wire [NM-1:0][AW-1:0] i_addr,
    input  wire [NM-1:0]         i_valid,
    output wire [NM-1:0][NS-1:0] o_requested,
    output wire [NM-1:0]         o_valid
);

    generate
        for (genvar m = 0; m < NM; ++m) begin
            for (genvar s = 0; s < NS; ++s) begin
                assign o_requested[m][s] = (((i_addr[m] & MASK_MAP[s]) ^ ADDR_MAP[s]) == 0) && i_valid[m] && WHITE_LIST[m][s];
            end
            assign o_valid[m] = |(o_requested[m]);
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

        for (genvar i = 0; i < NS; ++i) begin
            for (genvar j = 0; j < NS; ++j) begin
                localparam [AW-1:0] mask_overlap = MASK_MAP[i] & MASK_MAP[j];
                if (i != j && ((ADDR_MAP[i] & mask_overlap) == (ADDR_MAP[j] & mask_overlap))) begin
                    $error(
                        $sformatf(
                            "Invalid address ranges. Address ranges %d and %d are overlapping", i, j
                        )
                    );
                end
            end
        end
    endgenerate
endmodule
