`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 10/05/2023 02:45:34 PM
// Design Name: 
// Module Name: wb_inst_cache
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

module wb_inst_cache #(
    parameter  int              DW              = 32,                           // Data width
    parameter  int              AW              = 32,                           // Address width
    parameter  int              BIW             = 10,                           // Block index width (cache size)
    parameter  int              BTW             = 14,                           // Block tag width
    parameter  int              BOW             = 2,                            // Block offset width (block size)
    localparam int              ALW             = 2,                            // Address low width (2 bits for byte index)
    localparam int              AHW             = AW - BTW - BIW - BOW - ALW,   // Address high width (msb bits not used in cache)
    localparam int              SW              = DW / 8,                       // Strobe width
    localparam int              CW              = 1,                            // Control width (dirty bit)
    parameter  logic [AW-1:0]   CACHEABLE_ADDR  = 32'h00000000,
    parameter  logic [AW-1:0]   CACHEABLE_MASK  = 32'hf0000000
) (
    // Cache inputs/outputs
    input  wire              i_clk,
    input  wire              i_rst,
    input  wire              i_en,
    input  wire     [AW-1:0] i_addr,
    output logic    [DW-1:0] o_data,
    output logic             o_stall,
    output fe_error          o_error,

    // WB inputs/outputs
    input  wire           i_wb_ack,
    input  wire           i_wb_err,
    input  wire  [DW-1:0] i_wb_data,
    output logic [AW-1:0] o_wb_addr,
    output logic [DW-1:0] o_wb_data,
    output logic          o_wb_cyc,
    output logic          o_wb_stb,
    output wire           o_wb_we,
    output logic [SW-1:0] o_wb_sel,
    output logic [   2:0] o_wb_cti
);

    typedef enum logic [2:0] {
        idle,
        read,
        read_done,
        error_load_access,
        error_load_address
    } fsm_state;

    wire                w_addr_error;

    wire                w_cache_load;
    wire                w_cache_read;

    wire  [     DW-1:0] w_cache_r_data;
    logic [     DW-1:0] w_cache_w_data;
    logic [BIW+BOW-1:0] w_cache_addr;

    wire                w_control_r_en;
    logic               w_control_w_en;

    wire                w_cache_r_en;
    wire                w_cache_w_en;

    wire                w_cache_hit;
    wire                w_cacheable;

    wire  [    ALW-1:0] w_addr_low;
    wire  [    BOW-1:0] w_addr_offset;
    wire  [    BIW-1:0] w_addr_index;
    wire  [    BTW-1:0] w_addr_tag;
    wire  [    AHW-1:0] w_addr_high;

    wire                w_control_r_present;
    logic               w_control_w_present;
    wire  [    BTW-1:0] w_control_r_addr;
    logic [    BTW-1:0] w_control_w_addr;

    reg   [    BOW-1:0] r_offset;
    reg   [    BOW-1:0] r_last_offset;

`ifdef DISABLE_INST_CACHE
    reg   [     DW-1:0] r_wb_data;
`endif

    fsm_state r_state;

    control_bram #(
        .AW(BIW),
        .DW(BTW + CW)
    ) instance_control_bram (
        .o_data({w_control_r_addr, w_control_r_present}),
        .i_data({w_control_w_addr, w_control_w_present}),
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
        .i_strb({(SW) {1'b1}}),
        .i_clk (i_clk),
        .i_wren(w_cache_w_en),
        .i_rst (i_rst)
    );

`ifdef DISABLE_INST_CACHE
    assign w_cacheable = 1'b0;
`else
    assign w_cacheable = (((i_addr ^ CACHEABLE_ADDR) & CACHEABLE_MASK) == '0);
`endif

    // Split address
    assign {w_addr_high, w_addr_tag, w_addr_index, w_addr_offset, w_addr_low} = i_addr;

    // Address error
    assign w_addr_error = (w_addr_low != '0);
    
    // Outputs
    assign o_error.access_fault       = (r_state == error_load_access);
    assign o_error.address_misaligned = (r_state == error_load_address);

    // Stall
    always_comb begin
        case (r_state)
            read: begin
                o_stall = 1'b1;
            end
            idle: begin
                o_stall = !w_cache_hit && i_en;
            end
            default: begin
                o_stall = 1'b0;
            end
        endcase
    end

    // Cache addr
    always_comb begin
        case (r_state)
            read: begin
                w_cache_addr = {w_addr_index, r_offset};
            end
            default: begin
                w_cache_addr = {w_addr_index, w_addr_offset};
            end
        endcase
    end
    
    // Cache control
    assign w_cache_hit  = w_cacheable && w_control_r_present && (w_control_r_addr == w_addr_tag);
    assign w_cache_load = w_cacheable && i_wb_ack && (r_state == read);
    assign w_cache_read = i_en || (r_state != idle);

    // Cache enable
    assign w_control_w_en = w_cache_load;
    assign w_control_r_en = w_cache_read;
    assign w_cache_w_en = w_cache_load;
    assign w_cache_r_en = w_cache_read;

    // Cache control data
    assign w_control_w_addr    = w_addr_tag;
    assign w_control_w_present = (r_offset == r_last_offset);

    // Cache write data
    assign w_cache_w_data = i_wb_data;

`ifdef DISABLE_INST_CACHE
    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_wb_data <= '0;
        end else if (i_wb_ack) begin
            r_wb_data <= i_wb_data;
        end
    end    

    // Cache read data
    assign o_data = r_wb_data;
`else
    // Cache read data
    assign o_data = w_cache_r_data;
`endif

    // WishBone data
    assign o_wb_data = '0;

    // WishBone strobe
    assign o_wb_sel  = '0;

    // WishBone address
    assign o_wb_addr = { w_addr_high, w_addr_tag, w_addr_index, r_offset, {(ALW){1'b0}} };

    // WishBone we
    assign o_wb_we = 1'b0;

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
            read: begin
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
            read: begin
                o_wb_cyc = 1'b1;
            end
            default: begin
                o_wb_cyc = 1'b0;
            end
        endcase
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
                            r_state <= error_load_address;
                        end else begin
                            r_offset <= w_addr_offset;
`ifdef DISABLE_INST_CACHE
                            r_state       <= read;
                            r_last_offset <= w_addr_offset;
`else
                            if (!w_cache_hit) begin
                                r_state <= read;
                            end
                            r_last_offset <= w_addr_offset + (2 ** BOW - 1);
`endif
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

