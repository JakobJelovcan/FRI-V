`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 05/27/2024 07:40:16 PM
// Design Name: 
// Module Name: nri_div_row
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


module nri_div_row #(
    parameter int N = 32
) (
    input  wire  [  N:0] i_data_r,
    input  wire  [N-1:0] i_data_q,
    input  wire  [N-1:0] i_data_d,
    input  wire          i_signed,
    output logic [  N:0] o_data_r,
    output logic [N-1:0] o_data_q
);
    logic         w_sel_1;
    logic         w_sel_2;
    logic         w_carry;
    wire  [  N:0] w_data_r;
    wire  [N-1:0] w_data_q;

    always_comb begin
        if (i_signed) begin
            w_sel_1 = i_data_r[N-1] ^ i_data_d[N-1];
            w_sel_2 = i_data_r[N-1] ^ i_data_d[N-1];
        end else begin
            w_sel_1 = i_data_r[N];
            w_sel_2 = o_data_r[N];
        end
    end

    always_comb begin
        if (w_sel_1) begin
            o_data_r = w_data_r + i_data_d;
        end else begin
            o_data_r = w_data_r - i_data_d;
        end
    end

    always_comb begin
        if (w_sel_2) begin
            o_data_q = w_data_q | 32'b0;
        end else begin
            o_data_q = w_data_q | 32'b1;
        end
    end

    assign {w_data_r, w_data_q} = {i_data_r, i_data_q} << 1;

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                        Parameter validation                                         //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    generate
        if (N < 4 || (2 ** $clog2(N)) != N)
            $error(
                $sformatf("Invalid size (%d). Value has to be larger than 3 and a power of 2.", N)
            );
    endgenerate

endmodule
