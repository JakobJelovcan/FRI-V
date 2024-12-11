`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 05/21/2024 05:02:19 PM
// Design Name: 
// Module Name: booth_slice
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


module booth_slice #(
    parameter bit FIRST = 0,
    parameter bit LAST  = 0
) (
    input  wire [4:0] i_data_a,
    input  wire [2:0] i_data_b,
    input  wire [3:0] i_data_c,
    input  wire       i_carry,
    input  wire       i_signed,
    output wire [3:0] o_data,
    output wire       o_carry
);

    wire [3:0] w_data_p;
    wire [3:0] w_data_g;
    wire [3:0] w_carry;

    generate
        for (genvar i = 0; i < 4; ++i) begin
            if (i < 2 || !LAST) begin
                booth_lut_a instance_booth_lut_a (
                    .i_data_a(i_data_a[i+1:i]),
                    .i_data_b(i_data_b),
                    .i_data_p(i_data_c[i]),
                    .o_data_p(w_data_p[i]),
                    .o_data_g(w_data_g[i])
                );
            end else if (i == 2) begin
                booth_lut_b instance_booth_lut_b (
                    .i_data_a(i_data_a[i+1]),
                    .i_data_b(i_data_b),
                    .i_data_p(i_data_c[i]),
                    .i_signed(i_signed),
                    .o_data_p(w_data_p[i]),
                    .o_data_g(w_data_g[i])
                );
            end else begin
                booth_lut_c instance_booth_lut_c (                    
                    .o_data_p(w_data_p[i]),
                    .o_data_g(w_data_g[i])
                );
            end
        end
    endgenerate

    carry_4 instance_carry_4 (
        .CYINIT(FIRST),
        .CI    (i_carry),
        .CO    (w_carry),
        .O     (o_data),
        .DI    (w_data_g),
        .S     (w_data_p)
    );

    assign o_carry = w_carry[3];
endmodule
