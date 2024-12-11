`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 04/19/2024 07:19:32 AM
// Design Name: 
// Module Name: memory_controller_fsm
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


module memory_controller_fsm #(
    localparam logic [2:0] READ_COMMAND  = 3'b001,
    localparam logic [2:0] WRITE_COMMAND = 3'b000
) (
    input  wire        i_mem_clk,
    input  wire        i_mem_rst,
    input  wire        i_mem_en,
    input  wire        i_mem_we,
    input  wire        i_mem_rdy,
    input  wire        i_mem_wdf_rdy,
    input  wire        i_mem_rd_valid,
    input  wire        i_mem_rd_end,
    input  wire        i_mem_rcv,
    output logic [2:0] o_mem_cmd,
    output logic       o_mem_wdf_end,
    output logic       o_mem_wdf_wren,
    output wire        o_mem_en,
    output wire        o_mem_done,
    output logic       o_rd_valid,
    output logic [0:0] o_rd_index,
    output logic [0:0] o_wr_index
);

    typedef enum logic [2:0] {
        idle,
        pre_read,
        pre_write,
        read,
        write_low,
        write_high,
        done,
        done_wait
    } fsm_state;

    fsm_state r_state;

    assign o_mem_done = (r_state == done);
    assign o_mem_en   = (r_state == pre_read || r_state == pre_write);

    always_ff @(posedge i_mem_clk) begin
        if (i_mem_rst) begin
            r_state <= idle;
        end else begin
            case (r_state)
                idle: begin
                    if (i_mem_en) begin
                        if (i_mem_we) begin
                            r_state <= pre_write;
                        end else begin
                            r_state <= pre_read;
                        end
                    end
                end
                pre_read: begin
                    if (i_mem_rdy) begin
                        r_state <= read;
                    end
                end
                pre_write: begin
                    if (i_mem_rdy) begin
                        r_state <= write_low;
                    end
                end
                read: begin
                    if (i_mem_rd_valid && i_mem_rd_end) begin
                        r_state <= done;
                    end
                end
                write_low: begin
                    if (i_mem_wdf_rdy) begin
                        r_state <= write_high;
                    end
                end
                write_high: begin
                    if (i_mem_wdf_rdy) begin
                        r_state <= done;
                    end
                end
                done: begin
                    if (i_mem_rcv) begin
                        r_state <= done_wait;
                    end
                end
                done_wait: begin
                    if (!i_mem_en) begin
                        r_state <= idle;
                    end
                end
            endcase
        end
    end

    always_comb begin
        case (r_state)
            pre_read, read: begin
                o_rd_valid = i_mem_rd_valid;
                o_rd_index = i_mem_rd_end;
            end
            default: begin
                o_rd_valid = 1'b0;
                o_rd_index = 1'b0;
            end
        endcase
    end

    // Write signals
    always_comb begin
        case (r_state)
            write_low: begin
                o_mem_wdf_wren = 1'b1;
                o_mem_wdf_end  = 1'b0;
                o_wr_index     = 1'b0;
            end
            write_high: begin
                o_mem_wdf_wren = 1'b1;
                o_mem_wdf_end  = 1'b1;
                o_wr_index     = 1'b1;
            end
            default: begin
                o_mem_wdf_wren = 1'b0;
                o_mem_wdf_end  = 1'b0;
                o_wr_index     = 1'b0;
            end
        endcase
    end

    // Memory command
    always_comb begin
        case (r_state)
            pre_write, write_low, write_high: begin
                o_mem_cmd = WRITE_COMMAND;
            end
            pre_read, read: begin
                o_mem_cmd = READ_COMMAND;
            end
            default: begin
                o_mem_cmd = 3'b0;
            end
        endcase
    end
endmodule
