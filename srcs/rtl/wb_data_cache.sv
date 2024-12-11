`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 10/05/2023 02:53:49 PM
// Design Name: 
// Module Name: wb_data_cache
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

module wb_data_cache #(
    parameter  int              DW              = 32,                           // Data width
    parameter  int              AW              = 32,                           // Address width
    parameter  int              BIW             = 10,                           // Block index width (cache size)
    parameter  int              BTW             = 14,                           // Block tag width
    parameter  int              BOW             = 2,                            // Block offset width (block size)
    localparam int              ALW             = 2,                            // Address low width (2 bits for byte index)
    localparam int              AHW             = AW - BTW - BIW - BOW - ALW,   // Address high width (msb bits not used in cache)
    localparam int              SW              = DW / 8,                       // Strobe width
    localparam int              CW              = 2,                            // Control width (dirty bit)
    parameter  logic [AW-1:0] CACHEABLE_ADDR    = 32'h00000000,
    parameter  logic [AW-1:0] CACHEABLE_MASK    = 32'hf0000000
) (
    // Cache
    input  wire                i_clk,
    input  wire                i_rst,
    input  wire                i_en,
    input  wire                i_we,
    input  rv32_memop          i_memop,
    input  wire       [AW-1:0] i_addr,
    input  wire       [DW-1:0] i_data,
    output logic      [DW-1:0] o_data,
    output logic               o_stall,
    output ma_error            o_error,

    // WB inputs/outputs
    input  wire           i_wb_ack,
    input  wire           i_wb_err,
    input  wire  [DW-1:0] i_wb_data,
    output logic [AW-1:0] o_wb_addr,
    output logic [DW-1:0] o_wb_data,
    output logic          o_wb_cyc,
    output logic          o_wb_stb,
    output logic          o_wb_we,
    output logic [SW-1:0] o_wb_sel,
    output logic [   2:0] o_wb_cti
);

    typedef enum logic [3:0] {
        idle,
        store,
        store_done,
        write,
        write_done,
        read,
        read_done,
        error_load_access,
        error_load_address,
        error_store_access,
        error_store_address
    } fsm_state;

    wire                    w_addr_error;

    wire                    w_cache_load;
    wire                    w_cache_write;
    wire                    w_cache_read;

    wire      [     DW-1:0] w_cache_r_data;
    logic     [     DW-1:0] w_cache_w_data;
    logic     [BIW+BOW-1:0] w_cache_addr;

    wire                    w_control_r_en;
    logic                   w_control_w_en;

    wire                    w_cache_r_en;
    wire                    w_cache_w_en;
    logic     [     SW-1:0] w_cache_we;

    wire                    w_cache_hit;
    wire                    w_cacheable;

    wire      [    ALW-1:0] w_addr_low;
    wire      [    BOW-1:0] w_addr_offset;
    wire      [    BIW-1:0] w_addr_index;
    wire      [    BTW-1:0] w_addr_tag;
    wire      [    AHW-1:0] w_addr_high;

    wire      [     SW-1:0] w_strb;
    wire                    w_control_r_present;
    logic                   w_control_w_present;
    wire                    w_control_r_dirty;
    logic                   w_control_w_dirty;
    wire      [    BTW-1:0] w_control_r_addr;
    logic     [    BTW-1:0] w_control_w_addr;

    reg       [    BOW-1:0] r_offset;
    reg       [    BOW-1:0] r_last_offset;

    reg       [     DW-1:0] r_wb_data;

    fsm_state               r_state;

    control_bram #(
        .AW(BIW),
        .DW(BTW + CW)
    ) instance_control_bram (
        .o_data({w_control_r_addr, w_control_r_dirty, w_control_r_present}),
        .i_data({w_control_w_addr, w_control_w_dirty, w_control_w_present}),
        .i_addr(w_addr_index),
        .i_rden(w_control_r_en),
        .i_clk (i_clk),
        .i_wren(w_control_w_en),
        .i_rst (i_rst)
    );

    data_bram #(
        .AW(BIW + BOW),
        .DW(DW)
    ) instance_cache_bram (
        .o_data(w_cache_r_data),
        .i_data(w_cache_w_data),
        .i_addr(w_cache_addr),
        .i_rden(w_cache_r_en),
        .i_strb(w_cache_we),
        .i_clk (i_clk),
        .i_wren(w_cache_w_en),
        .i_rst (i_rst)
    );

    write_mask_unit instance_write_mask (
        .i_index(w_addr_low),
        .i_memop(i_memop),
        .o_mask (w_strb),
        .o_error(w_addr_error)
    );

`ifdef DISABLE_DATA_CACHE
    assign w_cacheable = 1'b0;
`else
    assign w_cacheable = (((i_addr ^ CACHEABLE_ADDR) & CACHEABLE_MASK) == '0);
`endif

    // Split address
    assign {w_addr_high, w_addr_tag, w_addr_index, w_addr_offset, w_addr_low} = i_addr;

    // Outputs
    assign o_error.load_access_fault        = (r_state == error_load_access);
    assign o_error.load_address_misaligned  = (r_state == error_load_address);
    assign o_error.store_access_fault       = (r_state == error_store_access);
    assign o_error.store_address_misaligned = (r_state == error_store_address);

    // Stall
    always_comb begin
        case (r_state)
            idle: begin
                o_stall = !w_cache_hit && i_en;
            end
            store, write, read, store_done: begin
                o_stall = 1'b1;
            end
            default: begin
                o_stall = 1'b0;
            end
        endcase
    end

    // Cache addr
    always_comb begin
        case (r_state)
            store, read: begin
                w_cache_addr = {w_addr_index, r_offset};
            end
            default: begin
                w_cache_addr = {w_addr_index, w_addr_offset};
            end
        endcase
    end

    // Cache control
    assign w_cache_hit   = w_cacheable && w_control_r_present && (w_control_r_addr == w_addr_tag);
    assign w_cache_load  = w_cacheable && i_wb_ack && (r_state == read);
    assign w_cache_write = i_we && w_cache_hit && (i_en && (r_state == idle) || (r_state == read_done));
    assign w_cache_read  = i_en || (r_state != idle);

    // Cache enable
    assign w_control_w_en = w_cache_load || w_cache_write;
    assign w_cache_w_en   = w_cache_load || w_cache_write;
    assign w_control_r_en = w_cache_read;
    assign w_cache_r_en   = w_cache_read;

    // Cache write data
    always_comb begin
        case (r_state)
            idle, read_done, write_done: begin
                w_cache_w_data = i_data;
            end
            default: begin
                w_cache_w_data = i_wb_data;
            end
        endcase
    end

    // Cache strb
    always_comb begin
        if (w_cache_write) begin
            w_cache_we = w_strb;
        end else begin
            w_cache_we = {(SW) {1'b1}};
        end
    end

    // Cache read data
    always_comb begin
        if (w_cacheable) begin
            o_data = w_cache_r_data;
        end else begin
            o_data = r_wb_data;
        end
    end

    // Cache control data
    always_comb begin
        case (r_state)
            idle, read_done, write_done: begin
                w_control_w_addr    = w_addr_tag;
                w_control_w_dirty   = 1'b1;
                w_control_w_present = 1'b1;
            end
            default: begin
                w_control_w_addr    = w_addr_tag;
                w_control_w_dirty   = 1'b0;
                w_control_w_present = (r_offset == r_last_offset);
            end
        endcase
    end
    
    // WishBone write data & strb
    always_comb begin
        if (w_cacheable) begin
            o_wb_data = w_cache_r_data;
            o_wb_sel  = {(SW) {1'b1}};
        end else begin
            o_wb_data = i_data;
            o_wb_sel  = w_strb;
        end
    end

    // WishBone address
    always_comb begin
        case (r_state)
            store: begin
                o_wb_addr = {{(AHW){1'b0}}, w_control_r_addr, w_addr_index, r_offset, {(ALW){1'b0}}};
            end
            default: begin
                o_wb_addr = {w_addr_high, w_addr_tag, w_addr_index, r_offset, {(ALW){1'b0}}};
            end
        endcase
    end

    // WishBone we
    always_comb begin
        case (r_state)
            store, write: begin
                o_wb_we = 1'b1;
            end
            default: begin
                o_wb_we = 1'b0;
            end
        endcase
    end

    // WishBone cti
    always_comb begin
        if (r_offset == r_last_offset) begin
            o_wb_cti = 3'b111;
        end else begin
            o_wb_cti = 3'b010;
        end
    end

    // WishBone stb
    always_comb begin
        case (r_state)
            store, write, read: begin
                o_wb_stb = 1'b1;
            end
            default: begin
                o_wb_stb = 1'b0;
            end
        endcase
    end

    // WishBone cyc
    always_comb begin
        case (r_state)
            store, write, read: begin
                o_wb_cyc = 1'b1;
            end
            default: begin
                o_wb_cyc = 1'b0;
            end
        endcase
    end

    // Data read
    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_wb_data <= '0;
        end else if (i_wb_ack) begin
            r_wb_data <= i_wb_data;
        end
    end

    // FSM
    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_state       <= idle;
            r_offset      <= '0;
            r_last_offset <= '0;
        end else begin
            case (r_state)
                idle: begin
                    if (i_en) begin
                        if (w_addr_error) begin
                            if (i_we) begin
                                r_state <= error_store_address;
                            end else begin
                                r_state <= error_load_address;
                            end
                        end else if (w_cacheable) begin
                            if (!w_cache_hit) begin
                                if (w_control_r_present && w_control_r_dirty) begin
                                    r_state <= store;
                                end else begin
                                    r_state <= read;
                                end
                            end
                            r_offset      <= w_addr_offset;
                            r_last_offset <= w_addr_offset + (2 ** BOW - 1);
                        end else begin
                            if (i_we) begin
                                r_state <= write;
                            end else begin
                                r_state <= read;
                            end
                            r_offset      <= w_addr_offset;
                            r_last_offset <= w_addr_offset;
                        end
                    end
                end
                store: begin
                    if (i_wb_err) begin
                        r_state <= error_store_access;
                    end else if (i_wb_ack) begin
                        if (r_offset == r_last_offset) begin
                            r_offset <= w_addr_offset;
                            r_state  <= store_done;
                        end else begin
                            r_offset <= r_offset + 1;
                            r_state  <= store;
                        end
                    end
                end
                store_done: begin
                    r_state <= read;
                end
                write: begin
                    if (i_wb_err) begin
                        r_state <= error_store_access;
                    end else if (i_wb_ack) begin
                        if (r_offset == r_last_offset) begin
                            r_state <= write_done;
                        end else begin
                            r_offset <= r_offset + 1;
                            r_state  <= write;
                        end
                    end
                end
                read: begin
                    if (i_wb_err) begin
                        r_state <= error_load_access;
                    end else if (i_wb_ack) begin
                        if (r_offset == r_last_offset) begin
                            r_state <= read_done;
                        end else begin
                            r_offset <= r_offset + 1;
                            r_state  <= read;
                        end
                    end
                end
                default: begin
                    r_state <= idle;
                end
            endcase
        end
    end

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                        Parameter validation                                         //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    generate
        if (BIW + BTW + BOW + ALW > AW)
            $error("Sum of address components has to be same or lower than the address width");
    endgenerate
endmodule

