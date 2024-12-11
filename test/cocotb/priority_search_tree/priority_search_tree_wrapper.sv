
module priority_search_tree_wrapper #(
    parameter  int W  = 2,
    parameter  int N  = 4,
    localparam int M  = $clog2(N)
) (
    input  wire  [W-1:0] i_priorities[N-1:0],
    input  wire  [N-1:0] i_pending,
    output logic [M-1:0] o_index,
    output wire          o_valid
);

    priority_search_tree #(
        .W(W),
        .N(N)
    ) instance_priority_search_tree (
        .i_priorities(i_priorities),
        .i_pending(i_pending),
        .o_index(o_index),
        .o_valid(o_valid)
    );

endmodule