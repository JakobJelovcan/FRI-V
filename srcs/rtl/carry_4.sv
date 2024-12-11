`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Jakob Jelovcan
//
// Create Date: 08/11/2024 11:49:32 AM
// Design Name:
// Module Name: carry_4
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

module carry_4 (
    input  wire       CI,
    input  wire       CYINIT,
    input  wire [3:0] DI,
    input  wire [3:0] S,
    output wire [3:0] CO,
    output wire [3:0] O
);

`ifdef XILINX
    CARRY4 instance_carry4 (
        .CO(CO),
        .O(O),
        .CI(CI),
        .CYINIT(CYINIT),
        .DI(DI),
        .S(S)
    );
`else
    wire w_carry_0 = S[0] ? CI || CYINIT : DI[0];
    wire w_carry_1 = S[1] ? w_carry_0 : DI[1];
    wire w_carry_2 = S[2] ? w_carry_1 : DI[2];
    wire w_carry_3 = S[3] ? w_carry_2 : DI[3];

    assign CO = {w_carry_3, w_carry_2, w_carry_1, w_carry_0};
    assign O  = S ^ {w_carry_2, w_carry_1, w_carry_0, CI || CYINIT};
`endif

endmodule
