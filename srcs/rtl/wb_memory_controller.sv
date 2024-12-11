`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Jakob Jelovcan
//
// Create Date: 07/15/2023 02:31:19 PM
// Design Name:
// Module Name: wb_memory_controller
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

module wb_memory_controller (
    input wire i_clk,
    input wire i_rst,
    input wire i_mem_clk,

    input  wire        i_wb_cyc,
    input  wire        i_wb_stb,
    input  wire        i_wb_we,
    input  wire [ 2:0] i_wb_cti,
    input  wire [ 3:0] i_wb_sel,
    input  wire [31:0] i_wb_addr,
    input  wire [31:0] i_wb_data,
    output reg         o_wb_ack,
    output reg         o_wb_err,
    output wire [31:0] o_wb_data,

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

    typedef enum logic [3:0] {
        idle,
        read_mem,
        read_mem_wait,
        write_mem,
        write_mem_wait,
        read_init,
        read_loop,
        write_init,
        write_loop,
        done_mem_wait
    } fsm_state;

    reg       [ 1:0]       r_index;

    logic                  w_wb_end;
    reg                    w_mem_en;
    reg                    r_mem_we;
    wire                   w_mem_rcv;
    wire                   w_mem_done;
    reg                    r_mem_ack;
    reg       [22:0]       r_mem_addr;
    reg       [ 3:0][ 3:0] r_mem_strb;
    reg       [ 3:0][31:0] r_mem_w_data;
    reg       [ 3:0][31:0] r_mem_r_data;
    wire      [ 3:0][31:0] w_mem_r_data;

    fsm_state              r_state;

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_state <= idle;
        end else begin
            case (r_state)
                idle: begin
                    if (i_wb_stb) begin
                        if (i_wb_we) begin
                            r_state <= write_init;
                        end else begin
                            r_state <= read_mem;
                        end
                    end
                end
                write_mem: begin
                    if (w_mem_rcv) begin
                        r_state <= write_mem_wait;
                    end
                end
                write_mem_wait: begin
                    if (w_mem_done) begin
                        r_state <= done_mem_wait;
                    end
                end
                write_init: begin
                    r_state <= write_loop;
                end
                write_loop: begin
                    if (i_wb_stb && w_wb_end || !i_wb_cyc) begin
                        r_state <= write_mem;
                    end
                end
                read_mem: begin
                    if (w_mem_rcv) begin
                        r_state <= read_mem_wait;
                    end
                end
                read_mem_wait: begin
                    if (w_mem_done) begin
                        r_state <= read_init;
                    end
                end
                read_init: begin
                    r_state <= read_loop;
                end
                read_loop: begin
                    if (i_wb_stb && w_wb_end || !i_wb_cyc) begin
                        r_state <= done_mem_wait;
                    end
                end
                done_mem_wait: begin
                    if (!w_mem_done) begin
                        r_state <= idle;
                    end
                end
            endcase
        end
    end

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_mem_strb   <= '{default: 0};
            r_mem_w_data <= '{default: 0};
        end else begin
            case (r_state)
                idle: begin
                    r_mem_w_data <= '{default: 0};
                    r_mem_strb   <= '{default: 0};
                end
                write_loop: begin
                    if (i_wb_stb && i_wb_we) begin
                        r_mem_w_data[r_index] <= i_wb_data;
                        r_mem_strb[r_index]   <= i_wb_sel;
                    end
                end
            endcase
        end
    end

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_mem_we   <= 1'b0;
            r_mem_addr <= 23'b0;
        end else begin
            case (r_state)
                idle: begin
                    if (i_wb_stb) begin
                        r_mem_we   <= i_wb_we;
                        r_mem_addr <= i_wb_addr[26:4];
                    end
                end
            endcase
        end
    end

    always_ff @(posedge i_clk) begin
        case (r_state)
            read_init, write_init: begin
                o_wb_ack <= i_wb_stb;
            end
            read_loop, write_loop: begin
                o_wb_ack <= i_wb_stb && !w_wb_end;
            end
            default: begin
                o_wb_ack <= 1'b0;
            end
        endcase
    end

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_mem_r_data <= 0;
        end else if (w_mem_done) begin
            r_mem_r_data <= w_mem_r_data;
        end
    end
    
    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_mem_ack <= 1'b0;
        end else if (w_mem_done) begin
            r_mem_ack <= 1'b1;
        end else begin
            r_mem_ack <= 1'b0;
        end
    end
    
    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_index <= 2'b0;
        end else begin
            case (r_state)
                idle: begin
                    r_index <= i_wb_addr[3:2];
                end
                read_loop,
                write_loop: begin
                    if (i_wb_stb && !w_wb_end) begin
                        r_index <= r_index + 1;
                    end
                end
            endcase
        end
    end

    always_comb begin
        case (r_state)
            read_mem, write_mem: begin
                w_mem_en = 1'b1;
            end
            default: begin
                w_mem_en = 1'b0;
            end
        endcase
    end

    always_comb begin
        casez (i_wb_cti)
            3'b000,
            3'b1??: begin
                w_wb_end = 1'b1;
            end
            default: begin
                w_wb_end = 1'b0;
            end
        endcase
    end

    assign o_wb_err   = 1'b0;
    assign o_wb_data  = r_mem_r_data[r_index];

`ifdef USE_FAKE_DRAM
    fake_memory_controller instance_fake_memory_controller (
        .i_clk(i_clk),
        .i_mem_clk(i_mem_clk),
        .i_rst(i_rst),
        .i_en(w_mem_en),
        .i_we(r_mem_we),
        .i_addr(r_mem_addr),
        .i_strb(r_mem_strb),
        .i_data(r_mem_w_data),
        .i_ack(r_mem_ack),
        .o_data(w_mem_r_data),
        .o_done(w_mem_done),
        .o_rcv(w_mem_rcv),
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
`else
    memory_controller instance_memory_controller (
        .i_clk(i_clk),
        .i_mem_clk(i_mem_clk),
        .i_rst(i_rst),
        .i_en(w_mem_en),
        .i_we(r_mem_we),
        .i_addr(r_mem_addr),
        .i_strb(r_mem_strb),
        .i_data(r_mem_w_data),
        .i_ack(r_mem_ack),
        .o_data(w_mem_r_data),
        .o_done(w_mem_done),
        .o_rcv(w_mem_rcv),
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
`endif
endmodule
