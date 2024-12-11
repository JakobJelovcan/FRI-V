`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Jakob Jelovcan
//
// Create Date: 06/24/2023 03:39:26 PM
// Design Name:
// Module Name: rv32_core
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
import types::*;

module rv32_core (
    input wire i_clk,
    input wire i_rst,
    input wire i_tim_int,
    input wire i_ext_int,

    // Instruction cache
    input  wire        i_wb_inst_ack,
    input  wire        i_wb_inst_err,
    input  wire [31:0] i_wb_inst_data,
    output wire [31:0] o_wb_inst_addr,
    output wire [31:0] o_wb_inst_data,
    output wire        o_wb_inst_cyc,
    output wire        o_wb_inst_stb,
    output wire        o_wb_inst_we,
    output wire [ 3:0] o_wb_inst_sel,
    output wire [ 2:0] o_wb_inst_cti,

    // Data cache
    input  wire        i_wb_data_ack,
    input  wire        i_wb_data_err,
    input  wire [31:0] i_wb_data_data,
    output wire [31:0] o_wb_data_addr,
    output wire [31:0] o_wb_data_data,
    output wire        o_wb_data_cyc,
    output wire        o_wb_data_stb,
    output wire        o_wb_data_we,
    output wire [ 3:0] o_wb_data_sel,
    output wire [ 2:0] o_wb_data_cti
);

    //-------------------------------------------------------------------------------------------------------
    // Exception signals
    //-------------------------------------------------------------------------------------------------------
    wire                       w_err_handled;
    wire                       w_err_pending;
    wire                [31:0] w_err_pc;
    wire                [31:0] w_err_cause;
    wire                [ 1:0] w_core_err;

    //-------------------------------------------------------------------------------------------------------
    // Fetch stage signals
    //-------------------------------------------------------------------------------------------------------
    wire                [31:0] w_pc_fetch;
    wire                [31:0] w_inst_fetch;
    wire                       w_stall_fetch;
    wire                       w_flush_fetch;
    wire                       w_valid_fetch;
    wire                       w_branch_taken;
    wire                       w_int_taken;
    wire                       w_data_hazard;
    wire                [31:0] w_branch_addr;
    wire                [31:0] w_int_addr;
    wire                       w_inst_cache_stall;
    fe_error                   w_fe_error;

    //-------------------------------------------------------------------------------------------------------
    // Decode stage signals
    //-------------------------------------------------------------------------------------------------------
    wire                [31:0] w_pc_decode;
    rv32_instruction_de        w_inst_decode;
    rv32_register              w_rs1_decode;
    rv32_register              w_rs2_decode;
    wire                       w_stall_decode;
    wire                       w_flush_decode;
    wire                       w_valid_decode;
    wire                [31:0] w_data_rs1_decode;
    wire                [31:0] w_data_rs2_decode;
    wire                [31:0] w_data_rd_decode;
    wire                [31:0] w_bypass_data_a_decode;
    wire                [31:0] w_bypass_data_b_decode;
    wire                [31:0] w_immed_decode;
    de_error                   w_de_error;

    //-------------------------------------------------------------------------------------------------------
    // Execute stage signals
    //-------------------------------------------------------------------------------------------------------
    rv32_instruction_ex        w_inst_execute;
    wire                       w_stall_execute;
    wire                       w_flush_execute;
    wire                       w_valid_execute;
    wire                       w_cmp_data_execute;
    wire                [31:0] w_data_a_execute;  // Operand A for ALU
    wire                [31:0] w_data_b_execute;  // Operand B for ALU
    wire                [31:0] w_data_c_execute;  // Operand for CSR unit
    wire                [31:0] w_pc_execute;
    wire                [31:0] w_store_data_execute;
    wire                [31:0] w_alu_data_execute;
    wire                [31:0] w_csr_data_execute;
    wire                [31:0] w_data_execute;
    wire                [31:0] w_branch_base_execute;
    wire                [31:0] w_branch_offset_execute;
    rv32_aluop                 w_aluop_execute;
    rv32_arithop               w_arithop_execute;
    rv32_logicop               w_logicop_execute;
    rv32_sysop                 w_sysop_execute;
    rv32_divop                 w_divop_execute;
    rv32_mulop                 w_mulop_execute;
    rv32_csr_access            w_csr_access_execute;
    rv32_compop                w_compop_execute;
    rv32_branch_type           w_branch_type_execute;
    ex_error                   w_ex_error;
    wire                       w_ex_atomic;
    wire                       w_ex_interrupted;
    wire                       w_ex_res_sel;
    wire                       w_alu_en_execute;
    wire                       w_alu_stall;

    //-------------------------------------------------------------------------------------------------------
    // Memory access stage signals
    //-------------------------------------------------------------------------------------------------------
    rv32_instruction_ma        w_inst_memory_access;
    wire                       w_stall_memory_access;
    wire                       w_flush_memory_access;
    wire                       w_valid_memory_access;
    wire                [31:0] w_pc_memory_access;
    wire                [31:0] w_store_data_memory_access;
    wire                [31:0] w_store_aligned_data_memory_access;
    wire                [31:0] w_load_data_memory_access;
    wire                [31:0] w_alu_data_memory_access;
    wire                [31:0] w_data_memory_access;
    wire                [31:0] w_addr_memory_access;
    wire                       w_data_cache_stall;
    ma_error                   w_ma_error;
    wire                       w_ma_res_sel;
    wire                       w_mem_en_memory_access;
    wire                       w_mem_we_memory_access;

    //-------------------------------------------------------------------------------------------------------
    // Write back stage signals
    //-------------------------------------------------------------------------------------------------------
    wire                       w_stall_write_back;
    wire                       w_flush_write_back;
    wire                       w_valid_write_back;
    wire                [ 1:0] w_offset_write_back;
    wire                [31:0] w_data_write_back;
    rv32_memop                 w_memop_write_back;
    rv32_register              w_rd_write_back;


    //-------------------------------------------------------------------------------------------------------
    // Control unit
    //-------------------------------------------------------------------------------------------------------
    control_unit instance_control_unit (
        .i_rst(i_rst),
        .i_data_hazard(w_data_hazard),
        .i_control_hazard(w_branch_taken),
        .i_err(w_core_err),
        .i_alu_stall(w_alu_stall),
        .i_cache_stall({w_data_cache_stall, w_inst_cache_stall}),
        .o_stall({
            w_stall_write_back,
            w_stall_memory_access,
            w_stall_execute,
            w_stall_decode,
            w_stall_fetch
        }),
        .o_flush({
            w_flush_write_back,
            w_flush_memory_access,
            w_flush_execute,
            w_flush_decode,
            w_flush_fetch
        })
    );

    //-------------------------------------------------------------------------------------------------------
    // Exception unit
    //-------------------------------------------------------------------------------------------------------

    exception_unit instance_exception_unit (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_err_handled(w_err_handled),
        .i_ex_error(w_ex_error),
        .i_ma_error(w_ma_error),
        .i_pc({w_pc_execute, w_pc_memory_access}),
        .o_core_err(w_core_err),
        .o_err_pending(w_err_pending),
        .o_err_pc(w_err_pc),
        .o_err_cause(w_err_cause)
    );

    //-------------------------------------------------------------------------------------------------------
    // Fetch stage
    //-------------------------------------------------------------------------------------------------------
    fetch instance_fetch (
        .i_clk(i_clk),
        .i_flush(w_flush_fetch),
        .i_stall(w_stall_fetch),
        .i_branch_addr(w_branch_addr),
        .i_branch_taken(w_branch_taken),
        .o_pc(w_pc_fetch),
        .o_valid(w_valid_fetch)
    );

    wb_inst_cache instance_instruction_cache (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_en(w_valid_fetch),
        .i_addr(w_pc_fetch),
        .o_data(w_inst_fetch),
        .o_stall(w_inst_cache_stall),
        .o_error(w_fe_error),
        .i_wb_ack(i_wb_inst_ack),
        .i_wb_err(i_wb_inst_err),
        .i_wb_data(i_wb_inst_data),
        .o_wb_addr(o_wb_inst_addr),
        .o_wb_data(o_wb_inst_data),
        .o_wb_cyc(o_wb_inst_cyc),
        .o_wb_stb(o_wb_inst_stb),
        .o_wb_we(o_wb_inst_we),
        .o_wb_sel(o_wb_inst_sel),
        .o_wb_cti(o_wb_inst_cti)
    );

    //-------------------------------------------------------------------------------------------------------
    // Decode stage
    //-------------------------------------------------------------------------------------------------------

    decode instance_decode (
        .i_clk(i_clk),
        .i_flush(w_flush_decode),
        .i_stall(w_stall_decode),
        .i_valid(w_valid_fetch),
        .i_pc(w_pc_fetch),
        .i_inst(w_inst_fetch),
        .i_fe_error(w_fe_error),
        .o_pc(w_pc_decode),
        .o_inst(w_inst_decode),
        .o_immed(w_immed_decode),
        .o_valid(w_valid_decode),
        .o_rs1(w_rs1_decode),
        .o_rs2(w_rs2_decode),
        .o_de_error(w_de_error)
    );

    register_unit instance_register_unit (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_we(w_valid_write_back),
        .i_rs1(w_rs1_decode),
        .i_rs2(w_rs2_decode),
        .i_rd(w_rd_write_back),
        .i_rd_data(w_data_rd_decode),
        .o_rs1_data(w_data_rs1_decode),
        .o_rs2_data(w_data_rs2_decode)
    );

    bypass_unit instance_bypass_unit (
        .i_ex_memop(w_inst_execute.memop),
        .i_rd_ex(w_inst_execute.rd),
        .i_ma_memop(w_inst_memory_access.memop),
        .i_rd_ma(w_inst_memory_access.rd),
        .i_rd_wb(w_rd_write_back),
        .i_data_a(w_data_rs1_decode),
        .i_data_b(w_data_rs2_decode),
        .i_data_ex(w_data_execute),
        .i_data_ma(w_data_memory_access),
        .i_data_wb(w_data_rd_decode),
        .i_valid_ex(w_valid_execute),
        .i_valid_ma(w_valid_memory_access),
        .i_valid_wb(w_valid_write_back),
        .i_rs1(w_rs1_decode),
        .i_rs2(w_rs2_decode),
        .o_data_a(w_bypass_data_a_decode),
        .o_data_b(w_bypass_data_b_decode),
        .o_hazard(w_data_hazard)
    );

    //-------------------------------------------------------------------------------------------------------
    // Execute stage
    //-------------------------------------------------------------------------------------------------------

    execute instance_execute (
        .i_clk(i_clk),
        .i_flush(w_flush_execute),
        .i_stall(w_stall_execute),
        .i_valid(w_valid_decode),
        .i_pc(w_pc_decode),
        .i_inst(w_inst_decode),
        .i_data_a(w_bypass_data_a_decode),
        .i_data_b(w_bypass_data_b_decode),
        .i_immed(w_immed_decode),
        .i_de_error(w_de_error),
        .o_inst(w_inst_execute),
        .o_pc(w_pc_execute),
        .o_data_a(w_data_a_execute),
        .o_data_b(w_data_b_execute),
        .o_data_c(w_data_c_execute),
        .o_memory_store_data(w_store_data_execute),
        .o_branch_offset(w_branch_offset_execute),
        .o_branch_base(w_branch_base_execute),
        .o_valid(w_valid_execute),
        .o_aluop(w_aluop_execute),
        .o_arithop(w_arithop_execute),
        .o_logicop(w_logicop_execute),
        .o_compop(w_compop_execute),
        .o_sysop(w_sysop_execute),
        .o_divop(w_divop_execute),
        .o_mulop(w_mulop_execute),
        .o_csr_access(w_csr_access_execute),
        .o_branch_type(w_branch_type_execute),
        .o_ex_error(w_ex_error),
        .o_ex_res_sel(w_ex_res_sel),
        .o_atomic(w_ex_atomic),
        .o_alu_en(w_alu_en_execute)
    );

    alu instance_alu (
        .i_clk(i_clk),
        .i_rst(w_flush_execute),
        .i_en(w_alu_en_execute),
        .i_data_a(w_data_a_execute),
        .i_data_b(w_data_b_execute),
        .i_aluop(w_aluop_execute),
        .i_arithop(w_arithop_execute),
        .i_logicop(w_logicop_execute),
        .i_divop(w_divop_execute),
        .i_mulop(w_mulop_execute),
        .i_compop(w_compop_execute),
        .o_data(w_alu_data_execute),
        .o_cmp_data(w_cmp_data_execute),
        .o_stall(w_alu_stall)
    );

    branch_unit instance_branch_unit (
        .i_branch_type(w_branch_type_execute),
        .i_alu_out(w_cmp_data_execute),
        .i_valid(w_valid_execute),
        .i_branch_base(w_branch_base_execute),
        .i_branch_offset(w_branch_offset_execute),
        .i_int_taken(w_int_taken),
        .i_int_addr(w_int_addr),
        .o_branch_addr(w_branch_addr),
        .o_branch_taken(w_branch_taken)
    );

    csr_unit instance_csr_unit (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_valid({w_valid_execute, w_valid_decode}),
        .i_en(!w_stall_execute),
        .i_sysop(w_sysop_execute),
        .i_atomic(w_ex_atomic),
        .i_csr_access(w_csr_access_execute),
        .i_data(w_data_c_execute),
        .i_addr(w_data_b_execute[11:0]),
        .i_pc({w_pc_execute, w_pc_decode, w_pc_fetch}),
        .i_err_pending(w_err_pending),
        .i_err_pc(w_err_pc),
        .i_err_cause(w_err_cause),
        .i_tim_int(i_tim_int),
        .i_ext_int(i_ext_int),
        .o_data(w_csr_data_execute),
        .o_int_addr(w_int_addr),
        .o_int_taken(w_int_taken),
        .o_err_handled(w_err_handled),
        .o_ex_interrupted(w_ex_interrupted)
    );

    assign w_data_execute = (w_ex_res_sel) ? w_csr_data_execute : w_alu_data_execute;

    //-------------------------------------------------------------------------------------------------------
    // Memory access
    //-------------------------------------------------------------------------------------------------------

    memory_access instance_memory_access (
        .i_clk(i_clk),
        .i_flush(w_flush_memory_access),
        .i_stall(w_stall_memory_access),
        .i_valid(w_valid_execute && !w_ex_interrupted),
        .i_pc(w_pc_execute),
        .i_inst(w_inst_execute),
        .i_alu_data(w_data_execute),
        .i_store_data(w_store_data_execute),
        .o_inst(w_inst_memory_access),
        .o_pc(w_pc_memory_access),
        .o_addr(w_addr_memory_access),
        .o_alu_data(w_alu_data_memory_access),
        .o_store_data(w_store_data_memory_access),
        .o_valid(w_valid_memory_access),
        .o_mem_en(w_mem_en_memory_access),
        .o_mem_we(w_mem_we_memory_access),
        .o_ma_res_sel(w_ma_res_sel)
    );

    data_align_unit instance_data_align (
        .i_offset(w_addr_memory_access[1:0]),
        .i_data  (w_store_data_memory_access),
        .o_data  (w_store_aligned_data_memory_access)
    );

    wb_data_cache instance_data_cache (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_en(w_mem_en_memory_access),
        .i_we(w_mem_we_memory_access),
        .i_memop(w_inst_memory_access.memop),
        .i_addr(w_addr_memory_access),
        .i_data(w_store_aligned_data_memory_access),
        .o_data(w_load_data_memory_access),
        .o_stall(w_data_cache_stall),
        .o_error(w_ma_error),
        .i_wb_ack(i_wb_data_ack),
        .i_wb_err(i_wb_data_err),
        .i_wb_data(i_wb_data_data),
        .o_wb_addr(o_wb_data_addr),
        .o_wb_data(o_wb_data_data),
        .o_wb_cyc(o_wb_data_cyc),
        .o_wb_stb(o_wb_data_stb),
        .o_wb_we(o_wb_data_we),
        .o_wb_sel(o_wb_data_sel),
        .o_wb_cti(o_wb_data_cti)
    );

    assign w_data_memory_access = (w_ma_res_sel) ? w_load_data_memory_access : w_alu_data_memory_access;

    //-------------------------------------------------------------------------------------------------------
    // Write back
    //-------------------------------------------------------------------------------------------------------

    write_back instance_write_back (
        .i_clk(i_clk),
        .i_flush(w_flush_write_back),
        .i_stall(w_stall_write_back),
        .i_valid(w_valid_memory_access),
        .i_offset(w_addr_memory_access[1:0]),
        .i_inst(w_inst_memory_access),
        .i_data(w_data_memory_access),
        .o_offset(w_offset_write_back),
        .o_data(w_data_write_back),
        .o_valid(w_valid_write_back),
        .o_memop(w_memop_write_back),
        .o_rd(w_rd_write_back)
    );

    sign_extend_unit instance_sign_extend_unit (
        .i_data  (w_data_write_back),
        .i_memop (w_memop_write_back),
        .i_offset(w_offset_write_back),
        .o_data  (w_data_rd_decode)
    );
endmodule
