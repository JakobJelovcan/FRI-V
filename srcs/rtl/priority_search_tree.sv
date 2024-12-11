`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 03/11/2024 07:18:21 PM
// Design Name: 
// Module Name: priority_search_tree
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


module priority_search_tree #(
    parameter  int W  = 2,
    parameter  int N  = 4,
    localparam int M  = $clog2(N),
    localparam int HN = N / 2
) (
    input  wire  [W-1:0] i_priorities[N-1:0],
    input  wire  [N-1:0] i_pending,
    output logic [M-1:0] o_index,
    output wire          o_valid
);

    generate
        if (N == 2) begin
            wire [W:0] upper_priority;
            wire [W:0] lower_priority;

            assign upper_priority = {i_pending[1], i_priorities[1]};
            assign lower_priority = {i_pending[0], i_priorities[0]};
            assign o_valid = i_pending[0] || i_pending[1];
            always_comb begin
                if (upper_priority > lower_priority) begin
                    o_index = 1'b1;
                end else begin
                    o_index = 1'b0;
                end
            end
        end else begin
            wire [M-2:0] upper_index;
            wire [M-2:0] lower_index;
            wire         upper_valid;
            wire         lower_valid;

            priority_search_tree #(
                .N(HN),
                .W(W)
            ) upper_priority_search_tree (
                .i_priorities(i_priorities[HN+:HN]),
                .i_pending(i_pending[HN+:HN]),
                .o_index(upper_index),
                .o_valid(upper_valid)
            );

            priority_search_tree #(
                .N(HN),
                .W(W)
            ) lower_priority_search_tree (
                .i_priorities(i_priorities[0+:HN]),
                .i_pending(i_pending[0+:HN]),
                .o_index(lower_index),
                .o_valid(lower_valid)
            );

            wire [W:0] upper_priority;
            wire [W:0] lower_priority;

            assign upper_priority = {upper_valid, i_priorities[{1'b1, upper_index}]};
            assign lower_priority = {lower_valid, i_priorities[{1'b0, lower_index}]};

            assign o_valid = lower_valid || upper_valid;
            always_comb begin
                if (upper_priority > lower_priority) begin
                    o_index = {1'b1, upper_index};
                end else begin
                    o_index = {1'b0, lower_index};
                end
            end
        end
    endgenerate

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                        Parameter validation                                         //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    generate
        if (W < 1)
            $error($sformatf("Invalid priority width (%d). Value has to be larger than 0.", W));

        if (N < 2 || (2 ** $clog2(N)) != N)
            $error($sformatf("Invalid item count (%d). Value has to be larger than 1 and a power of 2.", N));
    endgenerate

endmodule
