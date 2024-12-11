`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 05/31/2024 06:48:54 PM
// Design Name: 
// Module Name: booth_decoder
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


module booth_decoder #(
    parameter  int N = 32,     // Data width
    parameter  int S = 4,      // Size of the iteration
    localparam int M = N / 2,  // Number of rows
    localparam int K = M / S   // Number of iterations
) (
    input wire [N-1:0] i_data,
    output wire [S-1:0][2:0] o_data[K-1:0]
);
    wire [N:0] w_data = {i_data, 1'b0};

    generate
        for (genvar i = 0; i < M; ++i) begin
            assign o_data[i/S][i%S] = w_data[i*2+2:i*2];
        end
    endgenerate

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                        Parameter validation                                         //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    generate
        if (N < 4 || (2 ** $clog2(N)) != N)
            $error(
                $sformatf("Invalid size (%d). Value has to be larger than 3 and a power of 2.", N)
            );

        if (S < 1)
            $error($sformatf("Invalid iteration size (%d). Value has to be larger than 0.", S));
    endgenerate

endmodule
