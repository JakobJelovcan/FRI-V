`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Jakob Jelovcan
//
// Create Date: 06/23/2023 03:39:19 PM
// Design Name:
// Module Name: types
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

package types;
    typedef logic [4:0] rv32_register;

    typedef enum logic [3:0] {
        memop_nop,
        memop_l_byte,
        memop_l_hword,
        memop_l_word,
        memop_l_ubyte,
        memop_l_uhword,
        memop_s_byte,
        memop_s_hword,
        memop_s_word
    } rv32_memop;

    typedef enum logic [2:0] {
        aluop_nop,
        aluop_ari,  // Arithmetic
        aluop_log,  // Logical
        aluop_cmp,  // comparison
        aluop_mul,
        aluop_div
    } rv32_aluop;

    typedef enum logic [1:0] {
        arithop_add = 2'b00,
        arithop_sub = 2'b01,
        arithop_inc = 2'b10,
        arithop_dec = 2'b11
    } rv32_arithop;

    typedef enum logic [2:0] {
        logicop_and,
        logicop_orr,
        logicop_xor,
        logicop_sll,
        logicop_srl,
        logicop_sra
    } rv32_logicop;

    typedef enum logic [2:0] {
        compop_eq,
        compop_ne,
        compop_lts,
        compop_ltu,
        compop_ges,
        compop_geu
    } rv32_compop;

    typedef enum logic [2:0] {
        sysop_rw,    // ReadWrite
        sysop_rs,    // ReadSet
        sysop_rc,    // ReadClear
        sysop_mret,  // Return from machine mode trap
        sysop_eb,    // ebreak
        sysop_ec,    // ecall
        sysop_nop
    } rv32_sysop;

    typedef enum logic [1:0] {
        csr_rw  = 2'b11,
        csr_ro  = 2'b10,
        csr_wo  = 2'b01,
        csr_nop = 2'b00
    } rv32_csr_access;

    typedef enum logic [1:0] {
        mulop_mul,
        mulop_mulh,
        mulop_mulhu,
        mulop_mulhsu
    } rv32_mulop;

    typedef enum logic [1:0] {
        divop_div,
        divop_divu,
        divop_rem,
        divop_remu
    } rv32_divop;

    typedef enum logic [1:0] {
        branch_none,    // No branch
        branch_cond,    // Conditional branch (beq, bne, ...)
        branch_rel_pc,  // Unconditional branch relative to PC (jal)
        branch_rel_rs   // Unconditional branch relative to rs (jalr)
    } rv32_branch_type;

    typedef enum logic [2:0] {
        uart_9600   = 3'h0,
        uart_19200  = 3'h1,
        uart_38400  = 3'h2,
        uart_57600  = 3'h3,
        uart_115200 = 3'h4
    } uart_freq;

    typedef enum logic [2:0] {
        uart_5 = 3'h0,
        uart_6 = 3'h1,
        uart_7 = 3'h2,
        uart_8 = 3'h3,
        uart_9 = 3'h4
    } uart_size;

    typedef enum logic [2:0] {
        mstatus  = 3'h0,
        mie      = 3'h1,
        mtvec    = 3'h2,
        mscratch = 3'h3,
        mepc     = 3'h4,
        mcause   = 3'h5,
        mtval    = 3'h6,
        mip      = 3'h7
    } csr_register;

    typedef struct packed {
        logic access_fault;
        logic address_misaligned;
    } fe_error;

    typedef struct packed {
        logic access_fault;
        logic address_misaligned;
        logic invalid_inst;
    } de_error;

    typedef struct packed {
        logic access_fault;
        logic address_misaligned;
        logic invalid_inst;
        logic ebreak;
        logic ecall;
    } ex_error;

    typedef struct packed {
        logic load_access_fault;
        logic load_address_misaligned;
        logic store_access_fault;
        logic store_address_misaligned;
    } ma_error;


    typedef struct packed {
        rv32_register    rd;
        rv32_memop       memop;
        rv32_aluop       aluop;
        rv32_arithop     arithop;
        rv32_logicop     logicop;
        rv32_mulop       mulop;
        rv32_divop       divop;
        rv32_compop      compop;
        rv32_sysop       sysop;
        rv32_csr_access  csr_access;
        rv32_branch_type branch_type;
        logic            atomic;
        logic            alu_op_a_sel;
        logic            alu_op_b_sel;
        logic            ex_res_sel;
        logic            ma_res_sel;
        logic            sys_op_sel;
    } rv32_instruction_de;

    typedef struct packed {
        rv32_register rd;
        rv32_memop    memop;
        logic         ma_res_sel;
    } rv32_instruction_ex;

    typedef struct packed {
        rv32_register rd;
        rv32_memop    memop;
    } rv32_instruction_ma;

    typedef struct packed {
        logic     tx_int_en;
        logic     rx_int_en;
        uart_size size;
        uart_freq freq;
        logic     rxne;
        logic     txe;
        logic     en;
    } uart_control;

    localparam rv32_mulop mulop_nop = mulop_mul;
    localparam rv32_divop divop_nop = divop_div;
    localparam rv32_compop compop_nop = compop_eq;
    localparam rv32_logicop logicop_nop = logicop_and;
    localparam rv32_arithop arithop_nop = arithop_add;
    localparam rv32_memop rv32_l_memop[5] = {
        memop_l_byte, memop_l_hword, memop_l_word, memop_l_ubyte, memop_l_uhword
    };
    localparam rv32_memop rv32_s_memop[3] = {memop_s_byte, memop_s_hword, memop_s_word};

    localparam rv32_instruction_de rv32_instruction_de_default = '{
        default: 0,
        csr_access: csr_nop,
        sysop: sysop_nop,
        memop: memop_nop,
        aluop: aluop_nop,
        mulop: mulop_mul,
        divop: divop_div,
        arithop: arithop_add,
        logicop: logicop_nop,
        branch_type: branch_none,
        compop: compop_nop
    };
    localparam rv32_instruction_ex rv32_instruction_ex_default = '{default: 0, memop: memop_nop};
    localparam rv32_instruction_ma rv32_instruction_ma_default = '{default: 0, memop: memop_nop};
    localparam uart_control uart_control_default = '{
        default: 0,
        txe: 1'b1,
        freq: uart_9600,
        size: uart_5
    };
endpackage
