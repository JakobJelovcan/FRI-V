`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2024 07:30:49 PM
// Design Name: 
// Module Name: exception_priority_unit
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


module exception_priority_unit #(
    parameter  int                 E         = 10,
    parameter  logic [E-1:0][31:0] C         = 0,
    localparam int                 M         = $clog2(E),
    localparam int                 N         = 2 ** M,
    localparam int                 B         = (N > 2) ? 4 : 2,
    localparam logic [N-1:0][31:0] EXC_CODES = {{(N - E) {32'b0}}, C}
) (
    input  wire         i_clk,
    input  wire         i_rst,
    input  wire         i_err_handled,
    input  wire [E-1:0] i_err_pending,
    output wire         o_err_pending,
    output wire [ 31:0] o_err_cause
);

    wire [E-1:0] w_err_pending;
    reg  [E-1:0] r_err_pending;
    wire [M-1:0] w_err_index;

    lzd #(
        .N(N),
        .B(B)
    ) instance_lzd (
        .i_data ((N)'(w_err_pending)),
        .o_index(w_err_index),
        .o_valid(o_err_pending)
    );

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_err_pending <= '0;
        end else if (i_err_handled) begin
            r_err_pending <= '0;
        end else begin
            r_err_pending <= w_err_pending;
        end
    end
    
    assign w_err_pending = r_err_pending | i_err_pending;
    assign o_err_cause   = EXC_CODES[w_err_index];
endmodule
