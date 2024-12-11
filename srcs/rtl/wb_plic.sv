`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 03/11/2024 06:25:34 PM
// Design Name: 
// Module Name: wb_plic
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


module wb_plic #(
    parameter  bit          WB_REGISTERED = 0,
    parameter  int          INTERRUPTS    = 2,
    localparam int          M             = $clog2(INTERRUPTS),  // Number of bits needed to represent N
    localparam int          N             = 2 ** M,              // Number of interrupts rounded to a power of 2
    localparam int          P             = 5,
    localparam logic [31:0] INT_PRIORITY  = 32'b????????_????????_????????_0?????00,
    localparam logic [31:0] INT_PENDING   = 32'h??????80,
    localparam logic [31:0] INT_ENABLED   = 32'h??????84,
    localparam logic [31:0] INT_CLAIM     = 32'h??????88,
    localparam logic [31:0] INT_CLEAR     = 32'h??????8c
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
    output reg [31:0]   o_wb_data,
    output reg          o_wb_err,

    input  wire [N-1:0] i_int_request,
    output wire [N-1:0] o_int_cleared,
    output wire         o_ext_int
);

    initial begin
        assert (INTERRUPTS > 0 && INTERRUPTS <= 32);
    end

    wire         w_error;
    wire         w_valid;
    wire [M-1:0] w_claim;

    reg  [N-1:0] r_pending;
    reg  [N-1:0] r_enabled;
    reg  [P-1:0] r_priorities   [N-1:0];

    address_validation_unit #(
        .N(32),
        .M(5),
        .ADDR_MAP({
            32'h00000000,
            32'h00000080,
            32'h00000084,
            32'h00000088,
            32'h0000008c
        }),
        .MASK_MAP({
            32'h00000083,
            32'h0000008f,
            32'h0000008f,
            32'h0000008f,
            32'h0000008f
        }),
        .RO(5'b01010),
        .WO(5'b00001)
    ) instance_address_validation_unit (
        .i_addr(i_wb_addr),
        .i_valid(i_wb_stb),
        .i_we(i_wb_we),
        .o_error(w_error)
    );

    priority_search_tree #(
        .W(P),
        .N(N)
    ) instance_priority_search_tree (
        .i_priorities(r_priorities),
        .i_pending(r_pending),
        .o_index(w_claim),
        .o_valid(w_valid)
    );

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_pending    <= {(N){1'b0}};
            r_enabled    <= {(N){1'b0}};
            r_priorities <= '{default: 0};
        end else begin
            r_pending <= r_pending | (i_int_request & r_enabled);
            if (i_wb_stb) begin
                casez (i_wb_addr)
                    INT_PRIORITY: begin
                        if (i_wb_we) begin
                            r_priorities[i_wb_addr[M+1:2]] <= i_wb_data[4:0];
                        end
                    end
                    INT_ENABLED: begin
                        if (i_wb_we) begin
                            r_enabled <= i_wb_data[N-1:0];
                        end
                    end
                    INT_CLAIM: begin
                        if (!i_wb_we) begin
                            r_pending[w_claim] <= 1'b0;
                        end
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
                        INT_PRIORITY: begin
                            o_wb_data <= {{(32 - P) {1'b0}}, r_priorities[i_wb_addr[M+1:2]]};
                        end
                        INT_PENDING: begin
                            o_wb_data <= r_pending;
                        end
                        INT_ENABLED: begin
                            o_wb_data <= r_enabled;
                        end
                        INT_CLAIM: begin
                            o_wb_data <= w_claim;
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
                    INT_PRIORITY: begin
                        o_wb_data = {{(32 - P) {1'b0}}, r_priorities[i_wb_addr[M+1:2]]};
                    end
                    INT_PENDING: begin
                        o_wb_data = r_pending;
                    end
                    INT_ENABLED: begin
                        o_wb_data = r_enabled;
                    end
                    INT_CLAIM: begin
                        o_wb_data = w_claim;
                    end
                    default: begin
                        o_wb_data = 32'b0;
                    end
                endcase
            end

            assign o_wb_err = i_wb_stb && w_error;
            assign o_wb_ack = i_wb_stb && !w_error;
        end
    endgenerate

    assign o_ext_int = w_valid;
    assign o_int_cleared = 32'b0;

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                        Parameter validation                                         //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    generate
        if (INTERRUPTS < 1)
            $error($sformatf("Invalid number of interrupts (%d). Value has to be larger than 0.", INTERRUPTS));
    endgenerate

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                         Formal verification                                         //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    `ifdef FORMAL
        initial restrict(i_rst);

        always@ (posedge i_clk) begin
            if ($fell(i_rst)) begin
                assert(r_pending == '0);
                assert(r_enabled == '0);
                assert(r_priorities == '0);
                assert(!o_ext_int);
            end else if (!i_rst) begin
                if (r_pending & r_enabled)
                    assert(o_ext_int);

                if (r_pending)
                    assert(w_valid);
            end
        end

        `define WB_SLAVE
        `define WB_SUPPORTS_ERROR
        `include "../../test/formal/wb_formal.svh"
    `endif
endmodule
