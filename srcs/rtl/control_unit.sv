`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Jakob Jelovcan
//
// Create Date: 06/24/2023 09:53:38 AM
// Design Name:
// Module Name: control_unit
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


module control_unit (
    input  wire       i_rst,
    input  wire       i_data_hazard,
    input  wire       i_control_hazard,
    input  wire       i_alu_stall,
    input  wire [1:0] i_cache_stall,
    input  wire [1:0] i_err,
    output wire [4:0] o_stall,
    output wire [4:0] o_flush
);

    wire w_flush_fe, w_flush_de, w_flush_ex, w_flush_ma, w_flush_wb;
    wire w_stall_fe, w_stall_de, w_stall_ex, w_stall_ma, w_stall_wb;
    wire w_err_ma, w_err_ex;
    wire w_flush_err_wb, w_flush_err_ma, w_flush_err_ex, w_flush_err_de;
    wire w_cache_stall;

    assign w_cache_stall = |i_cache_stall;
    assign {w_err_ma, w_err_ex} = i_err;

    // Flush due to errors
    assign w_flush_err_wb = w_err_ma;  // Flush wb because of an error in the ma stage
    assign w_flush_err_ma = w_flush_err_wb || w_err_ex; // Flush ma because of an error in the ma or ex stage
    assign w_flush_err_ex = w_flush_err_ma; // Flush ex because of an error in the ma or ex stage
    assign w_flush_err_de = w_flush_err_ex; // Flush de because of an error in the ma or ex stage

    // Stage flush
    assign w_flush_fe = i_rst;
    assign w_flush_de = i_rst || w_flush_err_de || !w_stall_de && i_control_hazard;
    assign w_flush_ex = i_rst || w_flush_err_ex || !w_stall_ex && (i_control_hazard || i_data_hazard);
    assign w_flush_ma = i_rst || w_flush_err_ma;
    assign w_flush_wb = i_rst || w_flush_err_wb;

    // Stage stall
    assign w_stall_fe = w_cache_stall || i_alu_stall || (!i_control_hazard && i_data_hazard); // Data hazards do not matter in case of a branch because the decode and execute stages get flushed
    assign w_stall_de = w_cache_stall || i_alu_stall || (!i_control_hazard && i_data_hazard); // Data hazards do not matter in case of a branch because the decode and execute stages get flushed
    assign w_stall_ex = w_cache_stall || i_alu_stall;
    assign w_stall_ma = w_cache_stall || i_alu_stall;
    assign w_stall_wb = w_cache_stall || i_alu_stall;

    assign o_stall = {w_stall_wb, w_stall_ma, w_stall_ex, w_stall_de, w_stall_fe};
    assign o_flush = {w_flush_wb, w_flush_ma, w_flush_ex, w_flush_de, w_flush_fe};
endmodule
