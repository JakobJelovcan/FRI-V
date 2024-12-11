`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 04/28/2024 09:35:12 AM
// Design Name: Leading zero detector
// Module Name: lzd
// Project Name: RISC-V
// Target Devices: 
// Tool Versions: 
// Description: Calculates the index of the first 1 in the input vector from right to left. Valid indicates if a 1 was found
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lzd #(
    parameter  int N  = 4,          // Size of the input vector
    parameter  int B  = 4,          // Base of the lzd
    localparam int M  = $clog2(N),  // Size of the index
    localparam int HN = N / 2       // Size of the input vector for the next level
) (
    input  wire  [N-1:0] i_data,
    output logic [M-1:0] o_index,
    output wire          o_valid
);

    generate
        if (B == 2 && N == 2) begin
            assign o_valid = |i_data;
            always_comb begin
                casez (i_data)
                    2'b?1: begin
                        o_index = 1'b0;
                    end
                    2'b10: begin
                        o_index = 1'b1;
                    end
                    default: begin
                        o_index = 1'b0;
                    end
                endcase
            end
        end else if (B == 4 && N == 4) begin
            assign o_valid = |i_data;
            always_comb begin
                casez (i_data)
                    4'b???1: begin
                        o_index = 2'b00;
                    end
                    4'b??10: begin
                        o_index = 2'b01;
                    end
                    4'b?100: begin
                        o_index = 2'b10;
                    end
                    4'b1000: begin
                        o_index = 2'b11;
                    end
                    default begin
                        o_index = 2'b00;
                    end
                endcase
            end
        end else begin
            wire [M-2:0] upper_index;
            wire [M-2:0] lower_index;
            wire         upper_valid;
            wire         lower_valid;

            lzd #(
                .N(HN),
                .B(B)
            ) upper_lzd (
                .i_data (i_data[HN+:HN]),
                .o_index(upper_index),
                .o_valid(upper_valid)
            );

            lzd #(
                .N(HN),
                .B(B)
            ) lower_lzd (
                .i_data (i_data[0+:HN]),
                .o_index(lower_index),
                .o_valid(lower_valid)
            );

            assign o_valid = upper_valid || lower_valid;

            always_comb begin
                if (!lower_valid) begin
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
        if (N < 2 || (2 ** $clog2(N)) != N)
            $error($sformatf("Invalid number size (%d). Value has to be larger than 1 and a power of 2", N));
        
        if (B != 2 && B != 4)   
            $error($sformatf("Invalid base (%d). Only values 2 and 4 are allowed", B));
    endgenerate
endmodule
