`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 04/21/2024 07:56:55 PM
// Design Name: 
// Module Name: fake_memory_controller
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


module fake_memory_controller #(
    parameter INIT_FILE = "NONE"
) (
    input  wire         i_clk,
    input  wire         i_mem_clk,
    input  wire         i_rst,
    input  wire         i_en,
    input  wire         i_we,
    input  wire         i_ack,
    input  wire [ 22:0] i_addr,
    input  wire [ 15:0] i_strb,
    input  wire [127:0] i_data,
    output reg  [127:0] o_data,
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

    `include "ddr2_parameters.vh"
    `define DQ_PER_DQS DQ_BITS/DQS_BITS
    `define BANKS      (1<<BA_BITS)
    `define MAX_BITS   (BA_BITS+ROW_BITS+COL_BITS-BL_BITS)
    `define MAX_SIZE   (1<<(BA_BITS+ROW_BITS+COL_BITS-BL_BITS))
    `define MEM_SIZE   (1<<MEM_BITS)
    `define MAX_PIPE   2*(AL_MAX + CL_MAX)
    
    typedef enum logic[1:0] {
        idle,
        read,
        write,
        done
    } fsm_state;
    fsm_state               r_state;

`ifdef MAX_MEM
    reg     [BL_MAX*DQ_BITS-1:0] memory  [0:`MAX_SIZE-1];
`else
    reg     [BL_MAX*DQ_BITS-1:0] memory  [0:`MEM_SIZE-1];
    reg     [`MAX_BITS-1:0]      address [0:`MEM_SIZE-1];
    reg     [MEM_BITS:0]         memory_index = 0;
    reg     [MEM_BITS:0]         memory_used = 0;
`endif

    logic [BA_BITS-1:0]     bank;
    logic [ROW_BITS-1:0]    row;
    logic [COL_BITS-1:0]    col;
    wire [26:0]             w_addr;
    
    initial begin
        memory_index = 0;
        memory_used = 0;
        memory_init;
    end
    
    always @ (posedge i_clk) begin
        if (i_rst) begin
            r_state      <= idle;
        end else begin
            case (r_state)
                idle: begin
                    if (i_en) begin
                        if (i_we) begin
                            r_state <= write;
                        end else begin
                            r_state <= read;
                        end
                    end
                end
                read: begin
                    r_state <= done;
                    memory_read(bank, row, col, o_data);
                end
                write: begin
                    r_state <= done;
                    memory_write(bank, row, col, i_strb, i_data);
                end
                done: begin
                    r_state <= idle;
                end
            endcase
        end
    end

    assign w_addr = {i_addr, 4'b0};
    assign col  = (w_addr & 32'h3ff);
    assign row  = (w_addr & 32'h7FFC00) >> 10;
    assign bank = (w_addr & 32'hFF800000) >> 23;
        
    assign o_rcv  = (r_state != idle);
    assign o_done = (r_state == done);
    assign o_ack  = (r_state == read || r_state == write);

    assign ddr2_dq    = 16'b0;
    assign ddr2_dqs_n = 2'b0;
    assign ddr2_dqs_p = 2'b0;
    assign ddr2_addr  = 13'b0;
    assign ddr2_ba    = 3'b0;
    assign ddr2_ras_n = 1'b0;
    assign ddr2_cas_n = 1'b0;
    assign ddr2_we_n  = 1'b0;
    assign ddr2_ck_p  = 1'b0;
    assign ddr2_ck_n  = 1'b0;
    assign ddr2_cke   = 1'b0;
    assign ddr2_cs_n  = 1'b0;
    assign ddr2_dm    = 2'b0;
    assign ddr2_odt   = 1'b0;
    
`ifdef MAX_MEM
`else
    function get_index;
        input [`MAX_BITS-1:0] addr;
        begin : index
            get_index = 0;
            for (memory_index=0; memory_index<memory_used; memory_index=memory_index+1) begin
                if (address[memory_index] == addr) begin
                    get_index = 1;
                    disable index;
                end
            end
        end
    endfunction
`endif
    task memory_init;
        if (INIT_FILE != "NONE") begin
            int file, res;
            string line, data_str, bank_str, row_str, col_str;
            logic [BA_BITS-1:0] bank;
            logic [ROW_BITS-1:0] row;
            logic [COL_BITS-1:0] col;
            logic [`MAX_BITS-1:0] addr;
            logic [BL_MAX*DQ_BITS-1:0] data;
            
            file = $fopen(INIT_FILE, "r");  
            if (file) begin
                while (!$feof(file)) begin
                    res = $fgets(line, file);
                    if (line[0] == "#")
                        continue;
                    
                    res = $sscanf(line, "%s %s %s %s", bank_str, row_str, col_str, data_str);
                    if (res != 4)
                        continue;    
                        
                    data = { data_str.substr(0,7).atohex(), data_str.substr(8,15).atohex(), data_str.substr(16,23).atohex(), data_str.substr(24,31).atohex() };  
                    
                    bank = bank_str.atohex();
                    row  = row_str.atohex();
                    col  = col_str.atohex();
                    addr = {bank, row, col}/BL_MAX;
                    `ifdef MAX_MEM
                        memory[addr] = data;
                    `else
                        if (get_index(addr)) begin
                            address[memory_index] = addr;
                            memory[memory_index] = data;
                        end else if (memory_used == `MEM_SIZE) begin
                            $display ("%m: at time %t ERROR: Memory overflow.  Write to Address %h with Data %h will be lost.\nYou must increase the MEM_BITS parameter or define MAX_MEM.", $time, addr, data);
                            if (STOP_ON_ERROR) $stop(0);
                        end else begin
                            address[memory_used] = addr;
                            memory[memory_used] = data;
                            memory_used = memory_used + 1;
                        end                        
                    `endif
                end                
                $fclose(file);
            end  
        end
    endtask

    task memory_write;
        input  [BA_BITS-1:0]  bank;
        input  [ROW_BITS-1:0] row;
        input  [COL_BITS-1:0] col;
        input  [15:0]         strb;
        input  [BL_MAX*DQ_BITS-1:0] data;
        
        reg    [`MAX_BITS-1:0] addr;
        reg    [BL_MAX*DQ_BITS-1:0] mask;
        begin
            // chop off the lowest address bits
            addr = {bank, row, col}/BL_MAX;
            
            for (int i = 0; i < 16; ++i) begin
                mask[i*8+:8] = {(8){strb[i]}};
            end
            
`ifdef MAX_MEM
            memory[addr] = data;
`else
            if (get_index(addr)) begin
                address[memory_index] = addr;
                memory[memory_index] = (memory[memory_index] & ~mask) | (data & mask);
                
            end else if (memory_used == `MEM_SIZE) begin
                $display ("%m: at time %t ERROR: Memory overflow.  Write to Address %h with Data %h will be lost.\nYou must increase the MEM_BITS parameter or define MAX_MEM.", $time, addr, data);
                if (STOP_ON_ERROR) $stop(0);
            end else begin
                address[memory_used] = addr;
                memory[memory_used] = (memory[memory_used] & ~mask) | (data & mask);
                memory_used = memory_used + 1;
            end
`endif
        end
    endtask

    task memory_read;
        input  [BA_BITS-1:0]  bank;
        input  [ROW_BITS-1:0] row;
        input  [COL_BITS-1:0] col;
        output [BL_MAX*DQ_BITS-1:0] data;
        reg    [`MAX_BITS-1:0] addr;
        begin
            addr = { bank, row, col } / BL_MAX;
`ifdef MAX_MEM
            data = memory[addr];
`else
            if (get_index(addr)) begin
                data = memory[memory_index];
            end else begin
                data = {BL_MAX*DQ_BITS{1'bx}};
            end
`endif            
        end
    endtask    
endmodule
