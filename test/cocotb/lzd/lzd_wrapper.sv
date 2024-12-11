
module lzd_wrapper #(
    parameter  int N  = 4,
    parameter  int B  = 4,
    localparam int M  = $clog2(N)
) (
    input  wire  [N-1:0] i_data,
    output logic [M-1:0] o_index,
    output wire          o_valid
);
    lzd #(
        .N(N),
        .B(B)
    ) instance_lzd (
        .i_data(i_data),
        .o_index(o_index),
        .o_valid(o_valid)
    );
endmodule