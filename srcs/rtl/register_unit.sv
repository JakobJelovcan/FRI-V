`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Jakob Jelovcan
//
// Create Date: 06/24/2023 06:28:22 AM
// Design Name:
// Module Name: register_unit
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

import types::*;

module register_unit #(
    parameter string MEMORY_TYPE = "block"
) (
    input  wire                 i_clk,
    input  wire                 i_rst,
    input  wire                 i_we,
    input  rv32_register        i_rs1,
    input  rv32_register        i_rs2,
    input  rv32_register        i_rd,
    input  logic         [31:0] i_rd_data,
    output logic         [31:0] o_rs1_data,
    output logic         [31:0] o_rs2_data
);

    generate
        if (MEMORY_TYPE == "block") begin
            (* ram_style="block" *)
            reg [31:0] r_registers_a[32] = '{default: 0};
            (* ram_style="block" *)
            reg [31:0] r_registers_b[32] = '{default: 0};

            always_ff @(negedge i_clk) begin
                o_rs1_data <= r_registers_a[i_rs1];
            end

            always_ff @(negedge i_clk) begin
                o_rs2_data <= r_registers_b[i_rs2];
            end

            always_ff @(posedge i_clk) begin
                if (i_we && i_rd != 0) begin
                    r_registers_a[i_rd] <= i_rd_data;
                    r_registers_b[i_rd] <= i_rd_data;
                end
            end
        end else if (MEMORY_TYPE == "distributed") begin
            reg [31:0] r_registers[1:31];

            always_ff @(posedge i_clk) begin
                if (i_rst) begin
                    r_registers = '{default: 0};
                end else if (i_rd != 5'b0 && i_we) begin
                    r_registers[i_rd] <= i_rd_data;
                end
            end

            always_comb begin
                if (i_rs1 == 5'b0) begin
                    o_rs1_data = 32'b0;
                end else begin
                    o_rs1_data = r_registers[i_rs1];
                end
            end

            always_comb begin
                if (i_rs2 == 5'b0) begin
                    o_rs2_data = 32'b0;
                end else begin
                    o_rs2_data = r_registers[i_rs2];
                end
            end
        end else begin
            $error(
                $sformatf("Unknown memory type \"%s\"", MEMORY_TYPE)
            );
        end
    endgenerate

endmodule
