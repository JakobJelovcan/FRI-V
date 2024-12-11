`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 04/27/2024 07:51:03 PM
// Design Name: 
// Module Name: wb_rom
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


module wb_rom #(
    parameter string INIT_FILE = "None",
    parameter int    DW        = 16,
    parameter int    AW        = 8
) (
    input  wire        i_clk,
    input  wire        i_rst,
    input  wire        i_wb_stb,
    input  wire        i_wb_cyc,
    input  wire        i_wb_we,
    input  wire [31:0] i_wb_addr,
    input  wire [31:0] i_wb_data,
    input  wire [ 3:0] i_wb_sel,
    input  wire [ 2:0] i_wb_cti,
    output reg         o_wb_ack,
    output wire [31:0] o_wb_data,
    output wire        o_wb_err
);

    typedef enum logic [1:0] {
        idle,
        read_init,
        read_loop,
        error
    } fsm_state;

    wire      [AW-1:0] w_addr;
    logic              w_en;
    logic              w_wb_end;
    reg       [   1:0] r_index;
    reg       [AW-3:0] r_addr;
    fsm_state          r_state;

    bram_rom #(
        .DW(DW),
        .AW(AW),
        .INIT_FILE(INIT_FILE)
    ) instance_bram_rom (
        .i_clk (i_clk),
        .i_rst (i_rst),
        .i_en  (w_en),
        .i_addr(w_addr),
        .o_data(o_wb_data)
    );

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_state <= idle;
        end else begin
            case (r_state)
                idle: begin
                    if (i_wb_stb) begin
                        if (i_wb_we) begin
                            r_state <= error;
                        end else begin
                            r_state <= read_init;
                        end
                    end
                end
                read_init: begin
                    r_state <= read_loop;
                end
                read_loop: begin
                    if (i_wb_stb && w_wb_end || !i_wb_cyc) begin
                        r_state <= idle;
                    end
                end
                error: begin
                    r_state <= idle;
                end
            endcase
        end
    end

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_index <= 2'b0;
        end else begin
            case (r_state)
                idle: begin
                    if (i_wb_stb) begin
                        r_index <= i_wb_addr[3:2];
                    end
                end
                read_init,
                read_loop: begin
                    if (i_wb_stb && !w_wb_end) begin
                        r_index <= r_index + 1;
                    end
                end
            endcase
        end
    end

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_addr <= '0;
        end else begin
            case (r_state)
                idle: begin
                    if (i_wb_stb) begin
                        r_addr <= i_wb_addr[AW+1:4];
                    end
                end
            endcase
        end
    end

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            o_wb_ack <= 1'b0;
        end else begin
            case (r_state)
                read_init: begin
                    o_wb_ack <= i_wb_stb;
                end
                read_loop: begin
                    o_wb_ack <= i_wb_stb && !w_wb_end;
                end
                default: begin
                    o_wb_ack <= 1'b0;
                end
            endcase
        end
    end

    always_comb begin
        case (r_state)
            read_init: begin
                w_en = 1'b1;
            end
            read_loop: begin
                w_en = i_wb_stb && !w_wb_end;
            end
            default: begin
                w_en = 1'b0;
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

    assign o_wb_err = (r_state == error);
    assign w_addr   = {r_addr, r_index};

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                        Parameter validation                                         //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    generate
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

        `define WB_SLAVE
        `define WB_REGISTERED
        `define WB_SUPPORTS_ERROR
        `define WB_MAX_RSP_DELAY 3
        `include "../../test/formal/wb_formal.svh"
    `endif
endmodule