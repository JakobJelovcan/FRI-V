`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 03/16/2024 07:15:20 AM
// Design Name: 
// Module Name: piso
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


module piso #(
    parameter int N = 8,
    parameter bit R = 0
) (
    input  wire         i_clk,
    input  wire         i_rst,
    input  wire         i_we,
    input  wire         i_shift,
    input  wire [N-1:0] i_data,
    output wire         o_data
);

    reg [N-1:0] r_data;

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_data <= {(N) {R}};
        end else if (i_we) begin
            r_data <= i_data;
        end else if (i_shift) begin
            r_data <= {R, r_data[N-1:1]};
        end
    end

    assign o_data = r_data[0];

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                        Parameter validation                                         //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    generate
        if (N < 1)
            $error($sformatf("Invalid register size (%d). Value has to be larger than 0.", N));
    endgenerate

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                         Formal verification                                         //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    `ifdef FORMAL
        initial restrict(i_rst);

        always @(posedge i_clk) begin
            if ($fell(i_rst)) begin
                assert(r_data == 0);
            end else if (!i_rst) begin
                if ($past(i_we)) begin
                    assert(r_data == $past(i_data));
                end else if ($past(i_shift)) begin
                    assert($past(r_data[0]) == $past(o_data));
                    assert(r_data[0] == $past(r_data[1]));
                end else begin
                    assert($stable(r_data));
                end
            end
        end
    `endif
endmodule
