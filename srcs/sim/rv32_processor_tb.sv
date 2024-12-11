`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 09/30/2023 04:48:32 PM
// Design Name: 
// Module Name: rv32_processor_tb
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


module rv32_processor_tb ();
    localparam int EXCEPTION_COUNT = 15;
    int signed simulation_status = -1;
    int main_end_addr = 'h30;
    int exception_addr[EXCEPTION_COUNT] = {
        'h38, 'h3c, 'h40, 'h44, 'h48, 'h4c, 'h50, 'h54, 'h58, 'h5c, 'h60, 'h64, 'h68, 'h6c, 'h70
    };
    string exception_code[EXCEPTION_COUNT] = {"Instruction address misaligned",
                                              "Instruction access fault",
                                              "Illegal instruction",
                                              "Breakpoint",
                                              "Load address misaligned",
                                              "Load access fault",
                                              "Store address misaligned",
                                              "Store access fault",
                                              "Machine enviroment call",
                                              "Direct machine external interrupt",
                                              "Direct machine software interrupt",
                                              "Direct machine timer interrupt",
                                              "Machine software interrupt",
                                              "Machine timer interrupt",
                                              "Machine external interrupt"};

    logic clk;
    logic rst;
    logic uart;

    logic [31:0] execute_pc;
    logic execute_valid;

    rv32_processor processor (
        .i_clk(clk),
        .i_rst(rst),
        .o_tx (uart),
        .i_rx (uart)
    );

    assign rst = glbl.GSR;
    assign execute_pc    = processor.instance_core.instance_execute.r_pc;
    assign execute_valid = processor.instance_core.instance_execute.r_valid;

    initial begin
        clk = 1;
        forever #5 clk = ~clk;
    end

    initial begin
        wait (execute_pc == main_end_addr && execute_valid); // Main function has ended. Starting infinite loop
        assert(processor.instance_core.instance_register_unit.genblk1.r_registers_a[10] == 0) begin // If result from main is 0 the test has completed successfully
            simulation_status = 0;
        end else begin
            simulation_status = 1;
        end
        $finish;
    end

    generate
        for (genvar i = 0; i < EXCEPTION_COUNT; ++i) begin
            initial begin
                wait (execute_pc == exception_addr[i] && execute_valid);
                simulation_status = i + 2;
                $finish;
            end
        end
    endgenerate
endmodule
