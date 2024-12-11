`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Jakob Jelovcan
//
// Create Date: 08/25/2023 06:35:07 PM
// Design Name:
// Module Name: wb_crossbar
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

import functions::*;

module wb_crossbar #(
    parameter  int                    NM       = 2,                 // Number of masters
    parameter  int                    NS       = 5,                 // Number of slaves
    parameter  int                    DW       = 32,                // Data width
    parameter  int                    AW       = 32,                // Address width
    localparam int                    SW       = DW / 8,            // Strobe width
    localparam int                    NSW      = max(1, $clog2(NS)),        // Slave count width
    localparam int                    NMW      = max(1, $clog2(NM)),        // Master count width
    parameter  logic [NS-1:0][AW-1:0] ADDR_MAP = {
        32'h10000110,
        32'h10000100,
        32'h10000000,
        32'h08000000,
        32'h00000000
    },
    parameter  logic [NS-1:0][AW-1:0] MASK_MAP = {
        32'hfffffff0,
        32'hfffffff0,
        32'hffffff00,
        32'hf8000000,
        32'hffff8000
    },
    parameter  logic [NM-1:0][NS-1:0] WHITE_LIST = {
        5'b11111,
        5'b00011
    },
    parameter  bit LOW_POWER = 0
) (
    input wire i_clk,
    input wire i_rst,

    // Master inputs
    input wire [NM-1:0][AW-1:0] i_wb_m_addr,
    input wire [NM-1:0]         i_wb_m_cyc,
    input wire [NM-1:0]         i_wb_m_stb,
    input wire [NM-1:0]         i_wb_m_we,
    input wire [NM-1:0][DW-1:0] i_wb_m_data,
    input wire [NM-1:0][SW-1:0] i_wb_m_sel,
    input wire [NM-1:0][   2:0] i_wb_m_cti,

    // Master outputs
    output logic [NM-1:0]         o_wb_m_ack,
    output logic [NM-1:0]         o_wb_m_err,
    output logic [NM-1:0][DW-1:0] o_wb_m_data,

    // Slave inputs
    input wire [NS-1:0]         i_wb_s_ack,
    input wire [NS-1:0][DW-1:0] i_wb_s_data,
    input wire [NS-1:0]         i_wb_s_err,

    // Slave outputs
    output logic [NS-1:0]         o_wb_s_cyc,
    output logic [NS-1:0]         o_wb_s_stb,
    output logic [NS-1:0]         o_wb_s_we,
    output logic [NS-1:0][AW-1:0] o_wb_s_addr,
    output logic [NS-1:0][DW-1:0] o_wb_s_data,
    output logic [NS-1:0][SW-1:0] o_wb_s_sel,
    output logic [NS-1:0][   2:0] o_wb_s_cti
);

    wire [NM-1:0][ NS-1:0] w_requested;

    wire [NM-1:0]          w_m_addr_valid;
    wire [NM-1:0][NSW-1:0] w_m_index;
    wire [NM-1:0]          w_m_connect;
    wire [NM-1:0]          w_m_disconnect;
    wire [NS-1:0][NMW-1:0] w_s_index;
    wire [NS-1:0]          w_s_connect;
    wire [NS-1:0]          w_s_disconnect;
    wire [NM-1:0][NS-1:0]  w_granted;

    reg  [NS-1:0]          r_s_allocated;
    reg  [NM-1:0]          r_m_allocated;
    reg  [NM-1:0][NS-1:0]  r_allocated;

    reg  [NS-1:0][NMW-1:0] r_s_index;
    reg  [NM-1:0][NSW-1:0] r_m_index;

    wb_crossbar_addr_decoder #(
        .NM(NM),
        .NS(NS),
        .AW(AW),
        .ADDR_MAP(ADDR_MAP),
        .MASK_MAP(MASK_MAP),
        .WHITE_LIST(WHITE_LIST)
    ) instance_wb_crossbar_addr_decoder (
        .i_addr(i_wb_m_addr),
        .i_valid(i_wb_m_cyc),
        .o_requested(w_requested),
        .o_valid(w_m_addr_valid)
    );
    
    wb_crossbar_arbitrer #(
        .NM(NM),
        .NS(NS)
    ) instance_wb_crossbar_arbitrer (
        .i_requested(w_requested),
        .i_allocated(r_allocated),
        .i_m_allocated(r_m_allocated),
        .i_s_allocated(r_s_allocated),
        .o_granted(w_granted)
    );

    wb_crossbar_master_index_decoder #(
        .NM(NM),
        .NS(NS)
    ) instance_wb_crossbar_master_index_decoder (
        .i_granted(w_granted),
        .i_m_allocated(r_m_allocated),
        .o_index(w_m_index),
        .o_connect(w_m_connect),
        .o_disconnect(w_m_disconnect)
    );

    wb_crossbar_slave_index_decoder #(
        .NM(NM),
        .NS(NS)
    ) instance_wb_crossbar_slave_index_decoder (
        .i_granted(w_granted),
        .i_s_allocated(r_s_allocated),
        .o_index(w_s_index),
        .o_connect(w_s_connect),
        .o_disconnect(w_s_disconnect)
    );
    
    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_allocated <= '{default: 0};
        end else begin
            r_allocated <= w_granted;
        end
    end

    generate
        for (genvar m = 0; m < NM; ++m) begin
            always_ff @(posedge i_clk) begin
                if (i_rst) begin
                    r_m_allocated[m] <= 1'b0;
                    r_m_index[m]     <= {(NSW) {1'b0}};                
                end else if (w_m_connect[m]) begin
                    r_m_allocated[m] <= 1'b1;
                    r_m_index[m]     <= w_m_index[m];
                end else if (w_m_disconnect[m]) begin
                    r_m_allocated[m] <= 1'b0;
                    r_m_index[m]     <= {(NSW) {1'b0}};
                end
            end
        end
    endgenerate

    generate      
        for (genvar s = 0; s < NS; ++s) begin
            always_ff @(posedge i_clk) begin
                if (i_rst) begin
                    r_s_allocated[s] <= 1'b0;
                    r_s_index[s]     <= {(NMW) {1'b0}};
                end else if (w_s_connect[s]) begin
                    r_s_allocated[s] <= 1'b1;
                    r_s_index[s]     <= w_s_index[s];
                end else if (w_s_disconnect[s]) begin
                    r_s_allocated[s] <= 1'b0;
                    r_s_index[s]     <= {(NMW) {1'b0}};
                end
            end
        end
    endgenerate

    generate
        for (genvar m = 0; m < NM; ++m) begin
            wire [NSW-1:0] w_index = r_m_index[m];
            always_comb begin
                if (r_m_allocated[m]) begin
                    o_wb_m_ack[m]   = i_wb_s_ack[w_index];
                    o_wb_m_err[m]   = i_wb_s_err[w_index];
                end else begin
                    o_wb_m_ack[m]   = 1'b0;
                    o_wb_m_err[m]   = i_wb_m_cyc[m] && !w_m_addr_valid[m];
                end

                if (r_m_allocated[m] || !LOW_POWER) begin
                    o_wb_m_data[m]  = i_wb_s_data[w_index];
                end else begin
                    o_wb_m_data[m]  = {(DW) {1'b0}};
                end
            end
        end
    endgenerate

    generate
        for (genvar s = 0; s < NS; ++s) begin
            wire [NMW-1:0] w_index = r_s_index[s];
            always_comb begin
                if (r_s_allocated[s]) begin
                    o_wb_s_cyc[s]   = i_wb_m_cyc[w_index];
                    o_wb_s_stb[s]   = i_wb_m_stb[w_index];
                end else begin
                    o_wb_s_cyc[s]   = 1'b0;
                    o_wb_s_stb[s]   = 1'b0;
                end

                if (r_s_allocated[s] || !LOW_POWER) begin
                    o_wb_s_we[s]    = i_wb_m_we[w_index];
                    o_wb_s_sel[s]   = i_wb_m_sel[w_index];
                    o_wb_s_cti[s]   = i_wb_m_cti[w_index];
                    o_wb_s_addr[s]  = i_wb_m_addr[w_index];
                    o_wb_s_data[s]  = i_wb_m_data[w_index];
                end else begin
                    o_wb_s_we[s]    = 1'b0;
                    o_wb_s_sel[s]   = {(SW){1'b0}};
                    o_wb_s_cti[s]   = 3'b0;
                    o_wb_s_addr[s]  = {(AW){1'b0}};
                    o_wb_s_data[s]  = {(DW){1'b0}};
                end
            end
        end
    endgenerate

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                        Parameter validation                                         //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    generate
        if (NM < 1)
            $error($sformatf("Invalid number of masters (%d). Value has to be larger than 0.", NM));

        if (NS < 1)
            $error($sformatf("Invalid number of slaves (%d). Value has to be larger than 0.", NS));

        if (AW < 1)
            $error($sformatf("Invalid address width (%d). Value has to be larger than 0.", AW));

        if (DW < 1)
            $error($sformatf("Invalid data width (%d). Value has to be larger than 0.", DW));
    endgenerate

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                         Formal verification                                         //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    `ifdef FORMAL
        initial restrict(i_rst);

        (*anyconst*) int master_index_a;
        (*anyconst*) int master_index_b;

        (*anyconst*) int slave_index_a;
        (*anyconst*) int slave_index_b;

        always @(posedge i_clk) begin
            assume(master_index_a >= 0 && master_index_a < NM);
            assume(master_index_b >= 0 && master_index_b < NM);

            assume(slave_index_a >= 0 && slave_index_a < NS);
            assume(slave_index_b >= 0 && slave_index_b < NS);

            if (NS > 1)
                assume(slave_index_a != slave_index_b);

            if (NM > 1)
                assume(master_index_a != master_index_b);

            if ($fell(i_rst)) begin
                assert(!r_m_allocated[master_index_a]);
                assert(!r_s_allocated[slave_index_a]);
            end else if (!i_rst) begin
                if (NM > 1) begin
                    if (r_m_allocated[master_index_a] && r_m_allocated[master_index_b])
                        assert(r_m_index[master_index_a] != r_m_index[master_index_b]);

                    if (r_s_allocated[slave_index_a] && r_s_allocated[slave_index_b])
                        assert(r_s_index[slave_index_a] != r_s_index[slave_index_b]);
                end

                assert(!(w_m_connect[master_index_a] && w_m_disconnect[master_index_a]));
                assert(!(w_s_connect[slave_index_a] && w_s_disconnect[slave_index_a]));

                assert($onehot0(w_requested[master_index_a]));
                assert($onehot0(r_allocated[master_index_a]));

                if (r_m_allocated[master_index_a]) begin
                    assert(r_s_allocated[r_m_index[master_index_a]]);
                    assert(r_s_index[r_m_index[master_index_a]] == master_index_a);

                    assert(o_wb_m_ack[master_index_a] == i_wb_s_ack[r_m_index[master_index_a]]);
                    assert(o_wb_m_err[master_index_a] == i_wb_s_err[r_m_index[master_index_a]]);
                    assert(o_wb_m_data[master_index_a] == i_wb_s_data[r_m_index[master_index_a]]);

                    assert(i_wb_m_addr[master_index_a] == o_wb_s_addr[r_m_index[master_index_a]]);
                    assert(i_wb_m_data[master_index_a] == o_wb_s_data[r_m_index[master_index_a]]);
                    assert(i_wb_m_cti[master_index_a] == o_wb_s_cti[r_m_index[master_index_a]]);
                    assert(i_wb_m_stb[master_index_a] == o_wb_s_stb[r_m_index[master_index_a]]);
                    assert(i_wb_m_cyc[master_index_a] == o_wb_s_cyc[r_m_index[master_index_a]]);
                    assert(i_wb_m_sel[master_index_a] == o_wb_s_sel[r_m_index[master_index_a]]);
                    assert(i_wb_m_we[master_index_a] == o_wb_s_we[r_m_index[master_index_a]]);
                end

                if (r_s_allocated[slave_index_a]) begin
                    assert(r_m_allocated[r_s_index[slave_index_a]]);
                    assert(r_m_index[r_s_index[slave_index_a]] == slave_index_a);
                end

                if ($past(!i_wb_m_cyc[master_index_a]))
                    assert(!r_m_allocated[master_index_a]);
            end

            cover(r_s_index[slave_index_a]);
            cover(!r_s_index[slave_index_a]);

            cover(r_m_index[master_index_a]);
            cover(!r_m_index[master_index_a]);

            if (NM > 1 && NS > 1)
                cover(r_m_index[master_index_a] && r_m_index[master_index_b]);
        end
    `endif
endmodule
