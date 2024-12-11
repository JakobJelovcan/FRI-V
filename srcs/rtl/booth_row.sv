`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 05/21/2024 05:34:34 PM
// Design Name: 
// Module Name: booth_row
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


module booth_row #(
    parameter  int N = 8,
    localparam int M = N / 4
) (
    input  wire [N-1:0] i_data_a,
    input  wire [  2:0] i_data_b,
    input  wire [N+1:0] i_data_c,
    input  wire         i_signed,
    output wire [N+3:0] o_data
);

    logic [N+4:0] w_data_a;
    wire  [N+3:0] w_data_c;
    wire  [N+3:0] w_data_o;
    wire  [M+1:0] w_carry;

    generate
        for (genvar i = 0; i <= M; ++i) begin
            booth_slice #(
                .FIRST(i == 0),
                .LAST (i == M)
            ) instance_booth_slice (
                .i_data_a(w_data_a[i*4+4:i*4]),
                .i_data_b(i_data_b),
                .i_data_c(w_data_c[i*4+3:i*4]),
                .i_signed(i_signed),
                .i_carry (w_carry[i]),
                .o_data  (w_data_o[i*4+3:i*4]),
                .o_carry (w_carry[i+1])
            );
        end
    endgenerate

    always_comb begin
        if (i_signed) begin
            w_data_a = (N + 5)'(signed'(i_data_a)) << 2;
        end else begin
            w_data_a = (N + 5)'(unsigned'(i_data_a)) << 2;
        end
    end

    assign w_carry[0] = 1'b0;
    assign w_data_c   = {1'b1, i_data_c, 1'b0};
    assign o_data     = {w_carry[M+1], w_data_o[N+3:1]};

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
