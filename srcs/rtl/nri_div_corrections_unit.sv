`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/18/2024 02:17:50 PM
// Design Name: 
// Module Name: nri_div_corrections_unit
// Project Name: 
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


module nri_div_corrections_unit #(
    parameter int N = 32
) (
    input  wire  [N-1:0] i_data_n,
    input  wire  [N-1:0] i_data_d,
    input  wire  [N-1:0] i_data_q,
    input  wire  [  N:0] i_data_r,
    input  wire          i_signed,
    output logic [N-1:0] o_data_q,
    output logic [N-1:0] o_data_r
);
    wire         w_sign_r;
    wire [N-1:0] w_data_r;

    always_comb begin
        if (i_data_d == '0) begin
            o_data_q = ~'0;
            o_data_r = i_data_n;
        end else if (i_signed) begin
            if ((w_data_r == '0) || (w_data_r[N-1] == i_data_n[N-1]) && (w_data_r != i_data_d) && (w_data_r != -i_data_d)) begin
                o_data_q = (i_data_q << 1) + 1;
                o_data_r = w_data_r;
            end else if (w_data_r[N-1] == i_data_d[N-1]) begin
                o_data_q = (i_data_q << 1) + 2;
                o_data_r = w_data_r - i_data_d;
            end else begin
                o_data_q = (i_data_q << 1) + 0;
                o_data_r = w_data_r + i_data_d;
            end
        end else begin
            if (w_sign_r) begin
                o_data_q = i_data_q;
                o_data_r = w_data_r + i_data_d;
            end else begin
                o_data_q = i_data_q;
                o_data_r = w_data_r;
            end
        end
    end

    assign { w_sign_r, w_data_r } = i_data_r;
endmodule
