`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 06/02/2024 06:38:58 AM
// Design Name: 
// Module Name: booth_lut_a
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


module booth_lut_a (
    input  wire [1:0] i_data_a,
    input  wire [2:0] i_data_b,
    input  wire       i_data_p,
    output wire       o_data_p,
    output wire       o_data_g
);

    logic w_booth_s;
    logic w_booth_c;
    logic w_booth_z;
    logic w_data_a;

    always_comb begin
        case (i_data_b)
            3'b001, 3'b010: begin
                {w_booth_s, w_booth_c, w_booth_z} = 3'b000;
            end
            3'b011: begin
                {w_booth_s, w_booth_c, w_booth_z} = 3'b100;
            end
            3'b100: begin
                {w_booth_s, w_booth_c, w_booth_z} = 3'b110;
            end
            3'b101, 3'b110: begin
                {w_booth_s, w_booth_c, w_booth_z} = 3'b010;
            end
            default: begin
                {w_booth_s, w_booth_c, w_booth_z} = 3'b001;
            end
        endcase
    end

    always_comb begin
        if (w_booth_s) begin
            w_data_a = i_data_a[0];
        end else begin
            w_data_a = i_data_a[1];
        end
    end

    assign o_data_p = i_data_p ^ ((w_data_a ^ w_booth_c) & !w_booth_z);
    assign o_data_g = i_data_p;
endmodule
