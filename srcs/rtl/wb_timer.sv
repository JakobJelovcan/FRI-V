`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 10/29/2023 08:18:11 PM
// Design Name: 
// Module Name: wb_timer
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


module wb_timer #(
    parameter  bit          WB_REGISTERED      = 0,
    localparam logic [31:0] MTIME_LOW_ADDR     = 32'h???????0,
    localparam logic [31:0] MTIME_HIGH_ADDR    = 32'h???????4,
    localparam logic [31:0] MTIMECMP_LOW_ADDR  = 32'h???????8,
    localparam logic [31:0] MTIMECMP_HIGH_ADDR = 32'h???????c
) (
    input  wire         i_clk,
    input  wire         i_rst,
    input  wire         i_wb_stb,
    input  wire         i_wb_cyc,
    input  wire         i_wb_we,
    input  wire  [31:0] i_wb_addr,
    input  wire  [31:0] i_wb_data,
    input  wire  [ 3:0] i_wb_sel,
    input  wire  [ 2:0] i_wb_cti,
    output reg          o_wb_ack,
    output reg   [31:0] o_wb_data,
    output reg          o_wb_err,
    output wire         o_tim_int
);

    wire       w_error;

    reg [63:0] r_mtime;
    reg [63:0] r_mtimecmp;

    address_validation_unit #(
        .N(32),
        .M(4),
        .ADDR_MAP({
            32'h00000000,
            32'h00000004,
            32'h00000008,
            32'h0000000c
        }),
        .MASK_MAP({
            32'h0000000f,
            32'h0000000f,
            32'h0000000f,
            32'h0000000f
        }),
        .WO(4'b0000),
        .RO(4'b1100)
    ) instance_address_validation_unit (
        .i_addr(i_wb_addr),
        .i_valid(i_wb_stb),
        .i_we(i_wb_we),
        .o_error(w_error)
    );

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_mtime    <= 64'h0000000000000000;
            r_mtimecmp <= 64'hffffffffffffffff;
        end else begin
            r_mtime <= r_mtime + 1;
            if (i_wb_stb && i_wb_we) begin
                casez (i_wb_addr)
                    MTIMECMP_LOW_ADDR: begin
                        r_mtimecmp[31:0] <= i_wb_data;
                    end
                    MTIMECMP_HIGH_ADDR: begin
                        r_mtimecmp[63:32] <= i_wb_data;
                    end
                endcase
            end
        end
    end

    generate
        if (WB_REGISTERED) begin
            always_ff @(posedge i_clk) begin
                if (i_rst) begin
                    o_wb_data <= '0;
                end else if (i_wb_stb && !i_wb_we) begin
                    casez (i_wb_addr)
                        MTIME_LOW_ADDR: begin
                            o_wb_data <= r_mtime[31:0];
                        end
                        MTIME_HIGH_ADDR: begin
                            o_wb_data <= r_mtime[63:32];
                        end
                        MTIMECMP_LOW_ADDR: begin
                            o_wb_data <= r_mtimecmp[31:0];
                        end
                        MTIMECMP_HIGH_ADDR: begin
                            o_wb_data <= r_mtimecmp[63:32];
                        end
                        default: begin
                            o_wb_data <= '0;
                        end
                    endcase
                end else begin
                    o_wb_data <= '0;
                end
            end

            always_ff @(posedge i_clk) begin
                if (i_rst) begin
                    o_wb_ack <= '0;
                    o_wb_err <= '0;
                end else if (i_wb_stb && !(o_wb_ack || o_wb_err)) begin
                    o_wb_ack <= !w_error;
                    o_wb_err <= w_error;
                end else begin
                    o_wb_ack <= '0;
                    o_wb_err <= '0;
                end
            end
        end else begin
            always_comb begin
                casez (i_wb_addr)
                    MTIME_LOW_ADDR: begin
                        o_wb_data = r_mtime[31:0];
                    end
                    MTIME_HIGH_ADDR: begin
                        o_wb_data = r_mtime[63:32];
                    end
                    MTIMECMP_LOW_ADDR: begin
                        o_wb_data = r_mtimecmp[31:0];
                    end
                    MTIMECMP_HIGH_ADDR: begin
                        o_wb_data = r_mtimecmp[63:32];
                    end
                    default: begin
                        o_wb_data = '0;
                    end
                endcase
            end

            assign o_wb_err   = i_wb_stb && w_error;
            assign o_wb_ack   = i_wb_stb && !w_error;
        end
    endgenerate

    assign o_tim_int  = (unsigned'(r_mtime) >= unsigned'(r_mtimecmp));

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                         Formal verification                                         //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    `ifdef FORMAL
        initial restrict(i_rst);

        always @(posedge i_clk) begin
            if ($fell(i_rst)) begin
                assert(r_mtime == '0);
                assert(r_mtimecmp == ~'0);
            end else if (!i_rst) begin
                assert(r_mtime > $past(r_mtime) || r_mtime == '0);
                
                if (r_mtime >= r_mtimecmp)
                    assert(o_tim_int);
            end
        end    

        `define WB_SLAVE
        `include "../../test/formal/wb_formal.svh"
    `endif
endmodule
