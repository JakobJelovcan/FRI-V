`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Jakob Jelovcan
//
// Create Date: 10/6/2024 09:25:53 AM
// Design Name:
// Module Name: address_validation_unit
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

module address_validation_unit #(
    parameter int                N        = 32,
    parameter int                M        = 1,
    parameter bit [M-1:0][N-1:0] ADDR_MAP = '0,
    parameter bit [M-1:0][N-1:0] MASK_MAP = '0,
    parameter bit [M-1:0]        WO       = '0,
    parameter bit [M-1:0]        RO       = '0
) (
    input  wire [N-1:0] i_addr,
    input  wire         i_valid,
    input  wire         i_we,
    output logic        o_error
);
    wire [M-1:0] w_valid;

    generate
        for (genvar i = 0; i < M; ++i) begin
            assign w_valid[i] = (((i_addr & MASK_MAP[i]) ^ ADDR_MAP[i]) == 0 && !(RO[i] && i_we || WO[i] && !i_we));
        end
    endgenerate

    assign o_error = i_valid && !(|w_valid);
endmodule
