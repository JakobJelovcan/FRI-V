`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 12/10/2023 07:30:45 AM
// Design Name: 
// Module Name: data_bram
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


module data_bram #(
    parameter  int AW = 10,
    parameter  int DW = 32,
    localparam int SW = DW / 8
) (
    input  wire          i_clk,
    input  wire          i_rst,
    input  wire [AW-1:0] i_addr,
    input  wire          i_rden,
    input  wire          i_wren,
    input  wire [SW-1:0] i_strb,
    input  wire [DW-1:0] i_data,
    output reg  [DW-1:0] o_data
);
    reg [DW-1:0] r_memory[(2**AW)] = '{default: 0};

    always_ff @(negedge i_clk) begin
        if (i_rst) begin
            o_data <= '0;
        end else if (i_rden) begin
            o_data <= r_memory[i_addr];
        end
    end

    always_ff @(posedge i_clk) begin
        for (int i = 0; i < SW; ++i) begin
            if (i_wren && i_strb[i]) begin
                r_memory[i_addr][8*i+:8] <= i_data[8*i+:8];
            end
        end
    end

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                        Parameter validation                                         //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    generate
        if (AW < 1)
            $error($sformatf("Invalid address width (%d). Value has to be larger than 0.", AW));

        if (DW < 1)
            $error($sformatf("Invalid data width (%d). Value has to be larger than 0.", DW));
    endgenerate

endmodule
