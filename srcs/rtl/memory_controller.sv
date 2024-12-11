`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Jakob Jelovcan
//
// Create Date: 06/25/2023 01:57:01 PM
// Design Name:
// Module Name: memory_controller
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


module memory_controller (
    input  wire         i_clk,
    input  wire         i_rst,
    input  wire         i_mem_clk,
    input  wire         i_en,
    input  wire         i_we,
    input  wire [ 22:0] i_addr,
    input  wire [ 15:0] i_strb,
    input  wire [127:0] i_data,
    input  wire         i_ack,
    output wire [127:0] o_data,
    output wire         o_done,
    output wire         o_rcv,

    inout  wire [15:0] ddr2_dq,
    inout  wire [ 1:0] ddr2_dqs_n,
    inout  wire [ 1:0] ddr2_dqs_p,
    output wire [12:0] ddr2_addr,
    output wire [ 2:0] ddr2_ba,
    output wire        ddr2_ras_n,
    output wire        ddr2_cas_n,
    output wire        ddr2_we_n,
    output wire        ddr2_ck_p,
    output wire        ddr2_ck_n,
    output wire        ddr2_cke,
    output wire        ddr2_cs_n,
    output wire [ 1:0] ddr2_dm,
    output wire        ddr2_odt
);

    wire [ 22:0]       w_mem_addr;
    wire               w_mem_we;
    wire [ 15:0]       w_mem_strb;
    wire [127:0]       w_mem_data;

    reg  [ 22:0]       r_mem_addr;
    reg  [  1:0][ 7:0] r_mem_strb;
    reg  [  1:0][63:0] r_mem_data;

    reg                r_ack;
    wire               w_rcv;
    wire               w_done;

    wire               w_ui_clk;
    wire               w_ui_rst;
    wire [ 63:0]       w_mem_rd_data;
    wire               w_mem_rd_end;
    wire               w_mem_rd_valid;
    wire               w_mem_rdy;
    wire               w_mem_wdf_rdy;

    wire               w_mem_en;
    wire               w_mem_req;
    wire               w_rd_valid;
    wire               w_rd_index;
    wire               w_wr_index;
    wire               w_mem_wdf_end;
    wire               w_mem_wdf_wren;
    wire [  7:0]       w_mem_wdf_mask;
    wire [ 63:0]       w_mem_wdf_data;
    wire [  2:0]       w_mem_cmd;
    reg  [  1:0][63:0] r_mem_rd_data;

    // ddr2 model is used for simulating the real ddr2 memory module. It should only
    // be defined in a simulation
`ifdef SIMULATION
    ddr2 inst_ddr2_sim_model (
        .ck(ddr2_ck_p),
        .ck_n(ddr2_ck_n),
        .cke(ddr2_cke),
        .cs_n(ddr2_cs_n),
        .ras_n(ddr2_ras_n),
        .cas_n(ddr2_cas_n),
        .we_n(ddr2_we_n),
        .dm_rdqs(ddr2_dm),
        .ba(ddr2_ba),
        .addr(ddr2_addr),
        .dq(ddr2_dq),
        .dqs(ddr2_dqs_p),
        .dqs_n(ddr2_dqs_n),
        .rdqs_n(),
        .odt(ddr2_odt)
    );
`endif

    xpm_cdc_handshake #(
        .DEST_EXT_HSK(1),
        .DEST_SYNC_FF(2),
        .INIT_SYNC_FF(1),
        .SIM_ASSERT_CHK(1),
        .SRC_SYNC_FF(2),
        .WIDTH(168)
    ) instance_input_xpm_cdc_handshake (
        .dest_out({w_mem_addr, w_mem_we, w_mem_strb, w_mem_data}),
        .dest_req(w_mem_req),
        .src_rcv (o_rcv),
        .dest_ack(r_ack),
        .dest_clk(w_ui_clk),
        .src_clk (i_clk),
        .src_in  ({i_addr, i_we, i_strb, i_data}),
        .src_send(i_en)
    );

    xpm_cdc_handshake #(
        .DEST_EXT_HSK(1),
        .DEST_SYNC_FF(2),
        .INIT_SYNC_FF(1),
        .SIM_ASSERT_CHK(1),
        .SRC_SYNC_FF(2),
        .WIDTH(128)
    ) instance_output_xpm_cdc_handshake (
        .dest_out(o_data),
        .dest_req(o_done),
        .src_rcv (w_rcv),
        .dest_ack(i_ack),
        .dest_clk(i_clk),
        .src_clk (w_ui_clk),
        .src_in  (r_mem_rd_data),
        .src_send(w_done)
    );

    assign w_mem_wdf_mask = r_mem_strb[w_wr_index];
    assign w_mem_wdf_data = r_mem_data[w_wr_index];

    always_ff @(posedge w_ui_clk) begin
        if (w_ui_rst) begin
            r_mem_rd_data <= 128'b0;
        end else if (w_rd_valid) begin
            r_mem_rd_data[w_rd_index] <= w_mem_rd_data;
        end
    end

    always_ff @(posedge w_ui_clk) begin
        if (w_ui_rst) begin
            r_mem_addr <= 0;
            r_mem_strb <= 0;
            r_mem_data <= 0;
        end else if (w_mem_req) begin
            r_mem_addr <= w_mem_addr;
            r_mem_strb <= w_mem_strb;
            r_mem_data <= w_mem_data;
        end
    end
    
    always_ff @(posedge w_ui_clk) begin
        if (w_ui_rst) begin
            r_ack <= 1'b0;
        end else if (w_mem_req) begin
            r_ack <= 1'b1;
        end else begin
            r_ack <= 1'b0;
        end
    end

    memory_controller_fsm instance_memory_controller_fsm (
        .i_mem_clk(w_ui_clk),
        .i_mem_rst(w_ui_rst),
        .i_mem_en(w_mem_req),
        .i_mem_we(w_mem_we),
        .i_mem_rdy(w_mem_rdy),
        .i_mem_wdf_rdy(w_mem_wdf_rdy),
        .i_mem_rd_valid(w_mem_rd_valid),
        .i_mem_rd_end(w_mem_rd_end),
        .i_mem_rcv(w_rcv),
        .o_mem_cmd(w_mem_cmd),
        .o_mem_wdf_end(w_mem_wdf_end),
        .o_mem_wdf_wren(w_mem_wdf_wren),
        .o_mem_en(w_mem_en),
        .o_mem_done(w_done),
        .o_rd_valid(w_rd_valid),
        .o_rd_index(w_rd_index),
        .o_wr_index(w_wr_index)
    );

    mig inst_controller (
        .sys_clk_i(i_mem_clk),
        .app_addr({r_mem_addr, 4'b0}),
        .app_cmd(w_mem_cmd),
        .app_en(w_mem_en),
        .app_wdf_data(w_mem_wdf_data),
        .app_wdf_end(w_mem_wdf_end),
        .app_wdf_mask(~w_mem_wdf_mask),
        .app_wdf_wren(w_mem_wdf_wren),
        .app_rd_data(w_mem_rd_data),
        .app_rd_data_end(w_mem_rd_end),
        .app_rd_data_valid(w_mem_rd_valid),
        .app_rdy(w_mem_rdy),
        .app_wdf_rdy(w_mem_wdf_rdy),
        .app_sr_req(1'b0),
        .app_ref_req(1'b0),
        .app_zq_req(1'b0),
        .app_sr_active(),
        .app_ref_ack(),
        .app_zq_ack(),
        .ui_clk(w_ui_clk),
        .ui_clk_sync_rst(w_ui_rst),
        .init_calib_complete(),
        .sys_rst(~i_rst),
        .ddr2_dq(ddr2_dq),
        .ddr2_dqs_n(ddr2_dqs_n),
        .ddr2_dqs_p(ddr2_dqs_p),
        .ddr2_addr(ddr2_addr),
        .ddr2_ba(ddr2_ba),
        .ddr2_ras_n(ddr2_ras_n),
        .ddr2_cas_n(ddr2_cas_n),
        .ddr2_we_n(ddr2_we_n),
        .ddr2_ck_p(ddr2_ck_p),
        .ddr2_ck_n(ddr2_ck_n),
        .ddr2_cke(ddr2_cke),
        .ddr2_cs_n(ddr2_cs_n),
        .ddr2_dm(ddr2_dm),
        .ddr2_odt(ddr2_odt)
    );
endmodule
