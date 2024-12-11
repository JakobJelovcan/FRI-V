`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Jakob Jelovcan
//
// Create Date: 10/08/2023 09:01:17 AM
// Design Name:
// Module Name: csr_unit
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
import constants::*;

module csr_unit (
    input  wire                         i_clk,
    input  wire                         i_rst,
    input  wire            [ 1:0]       i_valid,
    input  wire                         i_en,
    input  rv32_csr_access              i_csr_access,
    input  rv32_sysop                   i_sysop,
    input  wire                         i_atomic,
    input  wire            [11:0]       i_addr,
    input  wire            [31:0]       i_data,
    input  wire            [ 2:0][31:0] i_pc,
    input  wire                         i_err_pending,
    input  wire            [31:0]       i_err_pc,
    input  wire            [31:0]       i_err_cause,
    input  wire                         i_tim_int,
    input  wire                         i_ext_int,
    output logic           [31:0]       o_data,
    output logic           [31:0]       o_int_addr,
    output wire                         o_int_taken,
    output wire                         o_err_handled,
    output wire                         o_ex_interrupted
);
    reg  [31:0] r_csr[7:0];
    reg         r_err;
    reg  [31:0] r_int_pc;
    wire [31:0] w_pc[3:0];
    wire [ 3:0] w_pc_valid;
    wire [ 1:0] w_pc_index;
    wire [31:0] w_pc_fe;
    wire [31:0] w_pc_de;
    wire [31:0] w_pc_ex;

    wire w_valid_de;
    wire w_valid_ex;

    wire w_int_en;  // Interrupt enable
    wire w_sft_en;  // Software interrupt enable
    wire w_tim_en;  // Timer interrupt enable
    wire w_ext_en;  // External interrupt enable

    wire w_sft_pe;  // Software interrupt pending
    wire w_tim_pe;  // Timer interrupt pending
    wire w_ext_pe;  // External interrupt pending

    wire w_sft_int;  // Software interrupt
    wire w_tim_int;  // Timer interrupt
    wire w_ext_int;  // External interrupt
    wire w_err_int;  // Error interrupt

    wire w_int_enter;  // Interrupt pending
    wire w_int_exit;
    wire w_ext_requested;  // External interrupt requested
    wire w_tim_requested;  // Timer interrupt requested
    wire w_err_requested;  // Error interrupt requested
    wire w_ex_interrupted;  // Ex instruction did not finish due to an interrupt

    logic        w_we;
    csr_register w_csr;
    logic        w_valid;

    lzd #(
        .N(4),
        .B(4)
    ) instance_lzd (
        .i_data (w_pc_valid),
        .o_index(w_pc_index),
        .o_valid()
    );

    csr_addr_decoder instance_csr_addr_decoder (
        .i_addr (i_addr),
        .o_csr  (w_csr),
        .o_valid(w_valid)
    );

    always_comb begin
        if (w_valid) begin
            o_data = r_csr[w_csr];
        end else begin
            o_data = 32'b0;
        end
    end

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_csr <= '{default: 0};
            r_err <= 1'b0;
        end else if (i_en) begin
            if (w_int_enter) begin  // Enter interrupt
                r_csr[mepc]       <= r_int_pc;
                r_csr[mstatus][7] <= r_csr[mstatus][3];
                r_csr[mstatus][3] <= 1'b0;
                r_err             <= 1'b0;
            end else if (w_err_requested) begin  // Handle errors
                r_err         <= 1'b1;
                r_csr[mcause] <= i_err_cause;
            end else if (w_ext_requested) begin  // Handle external interrupts
                r_csr[mip][11] <= 1'b1;
                r_csr[mcause]  <= 32'h8000000b;
            end else if (w_tim_requested) begin
                r_csr[mip][7] <= 1'b1;
                r_csr[mcause] <= 32'h80000007;
            end else begin
                case (i_sysop)
                    sysop_mret: begin
                        r_csr[mstatus][3] <= r_csr[mstatus][7];
                        r_csr[mstatus][7] <= 1'b1;
                    end
                    sysop_rw: begin
                        if (w_we) begin
                            r_csr[w_csr] <= i_data;
                        end
                    end
                    sysop_rs: begin
                        if (w_we) begin
                            r_csr[w_csr] <= r_csr[w_csr] | i_data;
                        end
                    end
                    sysop_rc: begin
                        if (w_we) begin
                            r_csr[w_csr] <= r_csr[w_csr] & ~i_data;
                        end
                    end
                    default: begin
                        r_csr[mip][7] <= r_csr[mip][7] && i_tim_int; //Clear timer interrupt flag
                    end
                endcase
            end
        end
    end

    // Output pc
    always_comb begin
        casez ({
            w_int_enter, r_csr[mcause][31], r_csr[mtvec][1:0]
        })
            4'b0???: begin
                o_int_addr = r_csr[mepc];
            end
            4'b1100, 4'b10??: begin
                o_int_addr = r_csr[mtvec] & ~32'h3;
            end
            default: begin
                o_int_addr = (r_csr[mtvec] & ~32'h3) + (r_csr[mcause] << 2);
            end
        endcase
    end

    always_comb begin
        case (i_csr_access)
            csr_wo, csr_rw: begin
                w_we = w_valid;
            end
            default: begin
                w_we = 1'b0;
            end
        endcase
    end

    // PC value to store into mepc
    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_int_pc <= '0;
        end else if (i_en) begin
            r_int_pc <= w_pc[w_pc_index];
        end
    end

    assign {w_pc_ex, w_pc_de, w_pc_fe} = i_pc;
    assign {w_valid_ex, w_valid_de} = i_valid;

    assign w_pc = {w_pc_fe, w_pc_de, w_pc_ex, i_err_pc};
    assign w_pc_valid = {1'b1, w_valid_de, w_ex_interrupted, i_err_pending};

    assign w_int_en = r_csr[mstatus][3];  // Interrupts enabled
    assign w_sft_en = r_csr[mie][3];      // Software interrupt enabled
    assign w_tim_en = r_csr[mie][7];      // Timer interrupt enabled
    assign w_ext_en = r_csr[mie][11];     // External interrupt enabled
    assign w_sft_pe = r_csr[mip][3];      // Software interrupt pending
    assign w_tim_pe = r_csr[mip][7];      // Timer interrupt pending
    assign w_ext_pe = r_csr[mip][11];     // External interrupt pending

    assign w_sft_int = w_sft_en && w_sft_pe && w_int_en;  // Software interrupt
    assign w_tim_int = w_tim_en && w_tim_pe && w_int_en;  // Timer interrupt
    assign w_ext_int = w_ext_en && w_ext_pe && w_int_en;  // External interrupt
    assign w_err_int = r_err;                             // Error interrupt (non maskable)

    assign w_ext_requested = i_ext_int && w_ext_en && w_int_en;  // External interrupt requested
    assign w_tim_requested = i_tim_int && w_tim_en && w_int_en;  // Timer interrupt requested
    assign w_err_requested = i_err_pending && !w_err_int;        // Error interrupt requested
    assign w_ex_interrupted = (w_err_requested || w_ext_requested || w_tim_requested) && i_atomic && w_valid_ex; // Execute stage did not complete because of an external interrupt or error

    assign w_int_exit = (i_sysop == sysop_mret);
    assign w_int_enter = w_sft_int || w_tim_int || w_ext_int || w_err_int; // Entering interrupt (internal signal)
    assign o_int_taken = (w_int_enter || w_int_exit);                      // Entering (or exiting) interrupt (external branch signal)

    assign o_err_handled = w_err_int;  // Error interrupt handled
    assign o_ex_interrupted = w_ex_interrupted;
endmodule
