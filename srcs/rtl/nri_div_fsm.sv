`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 05/27/2024 07:44:22 PM
// Design Name: 
// Module Name: nri_div_fsm
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


module nri_div_fsm #(
    parameter  int K = 4,
    localparam int J = $clog2(K)
) (
    input  wire          i_clk,
    input  wire          i_rst,
    input  wire          i_en,
    output wire  [J-1:0] o_index,
    output logic         o_stall,
    output logic         o_we
);
    reg       [J-1:0] r_index;
    logic     [J-1:0] w_next_index;
    wire              w_div_en;

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_index <= '0;
        end else if (w_div_en) begin
            r_index <= w_next_index;
        end
    end

    always_comb begin
        if (r_index == (J)'(K - 1)) begin
            w_next_index = '0;
        end else begin
            w_next_index = r_index + 1;
        end
    end

    assign w_div_en = i_en || (r_index > 0);
    assign o_index  = r_index;
    assign o_we     = w_div_en;
    assign o_stall  = w_div_en;

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                        Parameter validation                                         //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    generate
        if (K < 1)
            $error($sformatf("Invalid number of iterations (%d). Value has to be larger than 0.", K));
    endgenerate
    
endmodule
