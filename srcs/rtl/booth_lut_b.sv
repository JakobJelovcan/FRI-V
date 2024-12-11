`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 06/02/2024 06:38:58 AM
// Design Name: 
// Module Name: booth_lut_b
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


module booth_lut_b (
    input  wire        i_data_a,
    input  wire  [2:0] i_data_b,
    input  wire        i_data_p,
    input  wire        i_signed,
    output logic       o_data_p,
    output wire        o_data_g
);

    logic w_booth_e;
    logic w_booth_c;

    always_comb begin
        case (i_data_b)
            3'b001, 3'b010, 3'b011: begin
                w_booth_e = i_data_a;
                w_booth_c = 1'b0;
            end
            3'b100, 3'b101, 3'b110: begin
                w_booth_e = !i_data_a;
                w_booth_c = 1'b1;
            end
            default: begin
                w_booth_e = 1'b0;
                w_booth_c = 1'b0;
            end
        endcase
    end

    always_comb begin
        if (i_signed) begin
            o_data_p = i_data_p ~^ w_booth_e;
        end else begin
            o_data_p = i_data_p ^ !w_booth_c;
        end
    end

    assign o_data_g = i_data_p;
endmodule
