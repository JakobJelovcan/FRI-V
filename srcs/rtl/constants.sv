`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jakob Jelovcan
// 
// Create Date: 11/09/2023 06:24:35 PM
// Design Name: 
// Module Name: constants
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


package constants;
    localparam int FREQUENCY = 50000000;  // CPU frequency in MHz

    // Uart frequency clkdiv values
    localparam int UART_9600_CNT = FREQUENCY / 9600;
    localparam int UART_19200_CNT = FREQUENCY / 19200;
    localparam int UART_38400_CNT = FREQUENCY / 38400;
    localparam int UART_57600_CNT = FREQUENCY / 57600;
    localparam int UART_115200_CNT = FREQUENCY / 115200;

    // Uart frequency clkdiv reset values
    localparam int UART_9600_CNT_RST = UART_9600_CNT / 2;
    localparam int UART_19200_CNT_RST = UART_19200_CNT / 2;
    localparam int UART_38400_CNT_RST = UART_38400_CNT / 2;
    localparam int UART_57600_CNT_RST = UART_57600_CNT / 2;
    localparam int UART_115200_CNT_RST = UART_115200_CNT / 2;

    // CSR addresses
    localparam MSTATUS_ADDR = 12'b001100000000;
    localparam MIE_ADDR = 12'b001100000100;
    localparam MTVEC_ADDR = 12'b001100000101;
    localparam MSCRATCH_ADDR = 12'b001101000000;
    localparam MEPC_ADDR = 12'b001101000001;
    localparam MCAUSE_ADDR = 12'b001101000010;
    localparam MTVAL_ADDR = 12'b001101000011;
    localparam MIP_ADDR = 12'b001101000100;

    // Uart clkdiv size
    localparam int UART_CNT_SIZE = $clog2(UART_9600_CNT);
endpackage
