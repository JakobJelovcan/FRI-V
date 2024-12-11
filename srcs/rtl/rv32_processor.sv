`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 09/29/2023 05:51:35 PM
// Design Name: 
// Module Name: rv32_processor
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


module rv32_processor (
    input  wire i_clk,
    input  wire i_rst,
    input  wire i_rx,
    output wire o_tx,

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

    localparam ADDR_MAP = {
        32'h10000110,
        32'h10000100,
        32'h10000000,
        32'h08000000,
        32'h00000000
    };
    localparam MASK_MAP = {
        32'hfffffff0,
        32'hfffffff0,
        32'hffffff00,
        32'hf8000000,
        32'hffff8000
    };
    localparam WHITE_LIST = {
        5'b00011,
        5'b11111
    };
    
    wire        w_cpu_clk;
    wire        w_mem_clk;
    wire        w_cpu_rst;

    wire        w_wb_inst_ack;
    wire        w_wb_inst_err;
    wire [31:0] w_wb_inst_master_data;
    wire [31:0] w_wb_inst_addr;
    wire        w_wb_inst_cyc;
    wire        w_wb_inst_stb;
    wire        w_wb_inst_we;
    wire [ 3:0] w_wb_inst_sel;
    wire [31:0] w_wb_inst_slave_data;
    wire [ 2:0] w_wb_inst_cti;

    wire        w_wb_data_ack;
    wire        w_wb_data_err;
    wire [31:0] w_wb_data_master_data;
    wire [31:0] w_wb_data_addr;
    wire        w_wb_data_cyc;
    wire        w_wb_data_stb;
    wire        w_wb_data_we;
    wire [ 3:0] w_wb_data_sel;
    wire [31:0] w_wb_data_slave_data;
    wire [ 2:0] w_wb_data_cti;

    wire        w_wb_mem_ack;
    wire        w_wb_mem_err;
    wire [31:0] w_wb_mem_master_data;
    wire [31:0] w_wb_mem_addr;
    wire        w_wb_mem_cyc;
    wire        w_wb_mem_stb;
    wire        w_wb_mem_we;
    wire [ 3:0] w_wb_mem_sel;
    wire [31:0] w_wb_mem_slave_data;
    wire [ 2:0] w_wb_mem_cti;

    wire        w_wb_rom_ack;
    wire        w_wb_rom_err;
    wire [31:0] w_wb_rom_master_data;
    wire [31:0] w_wb_rom_addr;
    wire        w_wb_rom_cyc;
    wire        w_wb_rom_stb;
    wire        w_wb_rom_we;
    wire [ 3:0] w_wb_rom_sel;
    wire [31:0] w_wb_rom_slave_data;
    wire [ 2:0] w_wb_rom_cti;

    wire        w_wb_uart_ack;
    wire        w_wb_uart_err;
    wire [31:0] w_wb_uart_master_data;
    wire [31:0] w_wb_uart_addr;
    wire        w_wb_uart_cyc;
    wire        w_wb_uart_stb;
    wire        w_wb_uart_we;
    wire [ 3:0] w_wb_uart_sel;
    wire [31:0] w_wb_uart_slave_data;
    wire [ 2:0] w_wb_uart_cti;

    wire        w_wb_timer_ack;
    wire        w_wb_timer_err;
    wire [31:0] w_wb_timer_master_data;
    wire [31:0] w_wb_timer_addr;
    wire        w_wb_timer_cyc;
    wire        w_wb_timer_stb;
    wire        w_wb_timer_we;
    wire [ 3:0] w_wb_timer_sel;
    wire [31:0] w_wb_timer_slave_data;
    wire [ 2:0] w_wb_timer_cti;

    wire        w_wb_plic_ack;
    wire        w_wb_plic_err;
    wire [31:0] w_wb_plic_master_data;
    wire [31:0] w_wb_plic_addr;
    wire        w_wb_plic_cyc;
    wire        w_wb_plic_stb;
    wire        w_wb_plic_we;
    wire [ 3:0] w_wb_plic_sel;
    wire [31:0] w_wb_plic_slave_data;
    wire [ 2:0] w_wb_plic_cti;

    wire        w_ext_int;
    wire        w_tim_int;
    wire        w_uart_rx_int;
    wire        w_uart_tx_int;

    mmcm instance_mmcm (
        .clk_in (i_clk),
        .mem_out(w_mem_clk),
        .cpu_out(w_cpu_clk)
    );

    xpm_cdc_sync_rst #(
        .DEST_SYNC_FF(2),
        .INIT(1),
        .INIT_SYNC_FF(1),
        .SIM_ASSERT_CHK(1)
    ) instance_cpu_rst_xpm_cdc (
        .dest_rst(w_cpu_rst),
        .dest_clk(w_cpu_clk),
        .src_rst (i_rst)
    );

    rv32_core instance_core (
        .i_clk(w_cpu_clk),
        .i_rst(w_cpu_rst),
        .i_tim_int(w_tim_int),
        .i_wb_inst_ack(w_wb_inst_ack),
        .i_wb_inst_err(w_wb_inst_err),
        .i_wb_inst_data(w_wb_inst_slave_data),
        .o_wb_inst_addr(w_wb_inst_addr),
        .o_wb_inst_data(w_wb_inst_master_data),
        .o_wb_inst_cyc(w_wb_inst_cyc),
        .o_wb_inst_stb(w_wb_inst_stb),
        .o_wb_inst_we(w_wb_inst_we),
        .o_wb_inst_sel(w_wb_inst_sel),
        .o_wb_inst_cti(w_wb_inst_cti),
        .i_wb_data_ack(w_wb_data_ack),
        .i_wb_data_err(w_wb_data_err),
        .i_wb_data_data(w_wb_data_slave_data),
        .o_wb_data_addr(w_wb_data_addr),
        .o_wb_data_data(w_wb_data_master_data),
        .o_wb_data_cyc(w_wb_data_cyc),
        .o_wb_data_stb(w_wb_data_stb),
        .o_wb_data_we(w_wb_data_we),
        .o_wb_data_sel(w_wb_data_sel),
        .o_wb_data_cti(w_wb_data_cti),
        .i_ext_int(w_ext_int)
    );

    wb_crossbar #(
        .NM(2),
        .NS(5),
        .AW(32),
        .DW(32),
        .ADDR_MAP(ADDR_MAP),
        .MASK_MAP(MASK_MAP),
        .WHITE_LIST(WHITE_LIST)
    ) instance_wb_crossbar (
        .i_clk(w_cpu_clk),
        .i_rst(w_cpu_rst),
        .i_wb_m_addr({w_wb_inst_addr, w_wb_data_addr}),
        .i_wb_m_cyc({w_wb_inst_cyc, w_wb_data_cyc}),
        .i_wb_m_stb({w_wb_inst_stb, w_wb_data_stb}),
        .i_wb_m_we({w_wb_inst_we, w_wb_data_we}),
        .i_wb_m_data({w_wb_inst_master_data, w_wb_data_master_data}),
        .i_wb_m_sel({w_wb_inst_sel, w_wb_data_sel}),
        .i_wb_m_cti({w_wb_inst_cti, w_wb_data_cti}),
        .o_wb_m_ack({w_wb_inst_ack, w_wb_data_ack}),
        .o_wb_m_err({w_wb_inst_err, w_wb_data_err}),
        .o_wb_m_data({w_wb_inst_slave_data, w_wb_data_slave_data}),

        .i_wb_s_ack({w_wb_timer_ack, w_wb_uart_ack, w_wb_plic_ack, w_wb_mem_ack, w_wb_rom_ack}),
        .i_wb_s_data({
            w_wb_timer_slave_data,
            w_wb_uart_slave_data,
            w_wb_plic_slave_data,
            w_wb_mem_slave_data,
            w_wb_rom_slave_data
        }),
        .i_wb_s_err({w_wb_timer_err, w_wb_uart_err, w_wb_plic_err, w_wb_mem_err, w_wb_rom_err}),
        .o_wb_s_cyc({w_wb_timer_cyc, w_wb_uart_cyc, w_wb_plic_cyc, w_wb_mem_cyc, w_wb_rom_cyc}),
        .o_wb_s_stb({w_wb_timer_stb, w_wb_uart_stb, w_wb_plic_stb, w_wb_mem_stb, w_wb_rom_stb}),
        .o_wb_s_we({w_wb_timer_we, w_wb_uart_we, w_wb_plic_we, w_wb_mem_we, w_wb_rom_we}),
        .o_wb_s_addr({
            w_wb_timer_addr, w_wb_uart_addr, w_wb_plic_addr, w_wb_mem_addr, w_wb_rom_addr
        }),
        .o_wb_s_data({
            w_wb_timer_master_data,
            w_wb_uart_master_data,
            w_wb_plic_master_data,
            w_wb_mem_master_data,
            w_wb_rom_master_data
        }),
        .o_wb_s_sel({w_wb_timer_sel, w_wb_uart_sel, w_wb_plic_sel, w_wb_mem_sel, w_wb_rom_sel}),
        .o_wb_s_cti({w_wb_timer_cti, w_wb_uart_cti, w_wb_plic_cti, w_wb_mem_cti, w_wb_rom_cti})
    );

    wb_memory_controller instance_wb_memory_controller (
        .i_clk(w_cpu_clk),
        .i_rst(w_cpu_rst),
        .i_mem_clk(w_mem_clk),
        .i_wb_cyc(w_wb_mem_cyc),
        .i_wb_stb(w_wb_mem_stb),
        .i_wb_we(w_wb_mem_we),
        .i_wb_cti(w_wb_mem_cti),
        .i_wb_sel(w_wb_mem_sel),
        .i_wb_addr(w_wb_mem_addr),
        .i_wb_data(w_wb_mem_master_data),
        .o_wb_ack(w_wb_mem_ack),
        .o_wb_err(w_wb_mem_err),
        .o_wb_data(w_wb_mem_slave_data),
        .ddr2_addr(ddr2_addr),
        .ddr2_ba(ddr2_ba),
        .ddr2_cas_n(ddr2_cas_n),
        .ddr2_ck_n(ddr2_ck_n),
        .ddr2_ck_p(ddr2_ck_p),
        .ddr2_cke(ddr2_cke),
        .ddr2_ras_n(ddr2_ras_n),
        .ddr2_we_n(ddr2_we_n),
        .ddr2_dq(ddr2_dq),
        .ddr2_dqs_n(ddr2_dqs_n),
        .ddr2_dqs_p(ddr2_dqs_p),
        .ddr2_cs_n(ddr2_cs_n),
        .ddr2_dm(ddr2_dm),
        .ddr2_odt(ddr2_odt)
    );

    wb_uart instance_uart (
        .i_clk(w_cpu_clk),
        .i_rst(w_cpu_rst),
        .i_rx(i_rx),
        .o_tx(o_tx),
        .i_wb_stb(w_wb_uart_stb),
        .i_wb_cyc(w_wb_uart_cyc),
        .i_wb_we(w_wb_uart_we),
        .i_wb_addr(w_wb_uart_addr),
        .i_wb_data(w_wb_uart_master_data),
        .i_wb_sel(w_wb_uart_sel),
        .i_wb_cti(w_wb_uart_cti),
        .o_wb_ack(w_wb_uart_ack),
        .o_wb_data(w_wb_uart_slave_data),
        .o_wb_err(w_wb_uart_err),
        .o_rx_int(w_uart_rx_int),
        .o_tx_int(w_uart_tx_int)
    );

    wb_timer instance_timer (
        .i_clk(w_cpu_clk),
        .i_rst(w_cpu_rst),
        .o_tim_int(w_tim_int),
        .i_wb_stb(w_wb_timer_stb),
        .i_wb_cyc(w_wb_timer_cyc),
        .i_wb_we(w_wb_timer_we),
        .i_wb_addr(w_wb_timer_addr),
        .i_wb_data(w_wb_timer_master_data),
        .i_wb_sel(w_wb_timer_sel),
        .i_wb_cti(w_wb_timer_cti),
        .o_wb_ack(w_wb_timer_ack),
        .o_wb_data(w_wb_timer_slave_data),
        .o_wb_err(w_wb_timer_err)
    );

    wb_plic instance_plic (
        .i_clk(w_cpu_clk),
        .i_rst(w_cpu_rst),
        .o_ext_int(w_ext_int),
        .i_int_request({w_uart_tx_int, w_uart_rx_int}),
        .o_int_cleared(),
        .i_wb_stb(w_wb_plic_stb),
        .i_wb_cyc(w_wb_plic_cyc),
        .i_wb_we(w_wb_plic_we),
        .i_wb_addr(w_wb_plic_addr),
        .i_wb_data(w_wb_plic_master_data),
        .i_wb_sel(w_wb_plic_sel),
        .i_wb_cti(w_wb_plic_cti),
        .o_wb_ack(w_wb_plic_ack),
        .o_wb_data(w_wb_plic_slave_data),
        .o_wb_err(w_wb_plic_err)
    );

    wb_rom #(
        .DW(32),
        .AW(13),
        .INIT_FILE("rom.mem")
    ) instance_rom (
        .i_clk(w_cpu_clk),
        .i_rst(w_cpu_rst),
        .i_wb_stb(w_wb_rom_stb),
        .i_wb_cyc(w_wb_rom_cyc),
        .i_wb_we(w_wb_rom_we),
        .i_wb_addr(w_wb_rom_addr),
        .i_wb_data(w_wb_rom_master_data),
        .i_wb_sel(w_wb_rom_sel),
        .i_wb_cti(w_wb_rom_cti),
        .o_wb_ack(w_wb_rom_ack),
        .o_wb_data(w_wb_rom_slave_data),
        .o_wb_err(w_wb_rom_err)
    );
endmodule
