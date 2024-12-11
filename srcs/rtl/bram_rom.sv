`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 06/01/2024 08:51:04 AM
// Design Name: 
// Module Name: bram_rom
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


module bram_rom #(
    parameter int DW = 32,
    parameter int AW = 10,
    parameter string INIT_FILE = "None"
) (
    input  wire          i_clk,
    input  wire          i_rst,
    input  wire          i_en,
    input  wire [AW-1:0] i_addr,
    output wire [DW-1:0] o_data
);
    (* rom_style="block", keep="true" *)
    reg [DW-1:0] r_rom  [(2 ** AW) - 1:0];
    reg [DW-1:0] r_data;

    initial begin
        if (INIT_FILE == "None") begin
            r_rom = '{default: 0};
        end else begin
            $readmemh("rom.mem", r_rom, 0, (2 ** AW) - 1);
        end
    end

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            r_data <= {(DW) {1'b0}};
        end else if (i_en) begin
            r_data <= r_rom[i_addr];
        end
    end

    assign o_data = r_data;

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                        Parameter validation                                         //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    generate
        if (AW < 1)
            $error($sformatf("Invalid address width (%d). Value has to be larger than 0.", AW));

        if (DW < 1)
            $error($sformatf("Invalid data width (%d). Value has to be larger than 0.", DW));
    endgenerate

endmodule
