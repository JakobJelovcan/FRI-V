`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 03/16/2024 07:00:21 AM
// Design Name: 
// Module Name: sipo
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


module sipo #(
    parameter int N = 8,
    parameter bit R = 0
) (
    input  wire         i_clk,
    input  wire         i_rst,
    input  wire         i_data,
    input  wire         i_shift,
    output wire [N-1:0] o_data
);

    reg [N-1:0] r_data;

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_data <= {(N) {R}};
        end else if (i_shift) begin
            r_data <= {i_data, r_data[N-1:1]};
        end
    end

    assign o_data = r_data;

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
                if ($past(i_shift)) begin
                    assert(r_data[N-1] == $past(i_data));
                end else begin
                    assert($stable(r_data));
                end
            end
        end
    `endif
endmodule
