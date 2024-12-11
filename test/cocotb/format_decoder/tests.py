import cocotb
from cocotb.triggers import Timer


@cocotb.test
async def format_test_1(dut):
    dut.i_inst.value = 0x0140A103  # lw x2, 20(x1)
    await Timer(1, units="ns")
    assert dut.o_branch_type == 0
    assert dut.o_alu_op_a_sel == 0
    assert dut.o_alu_op_b_sel == 1
    assert dut.o_alu_op_b_sel == 1
    assert dut.o_ex_res_sel == 0
    assert dut.o_ma_res_sel == 1
    assert dut.o_atomic == 0
    assert dut.o_rd == 2
    assert dut.o_rs1 == 1
    assert dut.o_rs2 == 0
    assert dut.o_immed == 20


@cocotb.test
async def format_test_2(dut):
    dut.i_inst.value = 0x0020AA23  # sw x2, 20(x1)
    await Timer(1, units="ns")
    assert dut.o_branch_type == 0
    assert dut.o_alu_op_a_sel == 0
    assert dut.o_alu_op_b_sel == 1
    assert dut.o_ex_res_sel == 0
    assert dut.o_ma_res_sel == 0
    assert dut.o_atomic == 0
    assert dut.o_rd == 0
    assert dut.o_rs1 == 1
    assert dut.o_rs2 == 2
    assert dut.o_immed == 20


@cocotb.test
async def format_test_3(dut):
    dut.i_inst.value = 0x0C208463  # beq x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_branch_type == 1
    assert dut.o_alu_op_a_sel == 0
    assert dut.o_alu_op_b_sel == 0
    assert dut.o_ex_res_sel == 0
    assert dut.o_ma_res_sel == 0
    assert dut.o_atomic == 1
    assert dut.o_rd == 0
    assert dut.o_rs1 == 1
    assert dut.o_rs2 == 2
    assert dut.o_immed == 200


@cocotb.test
async def format_test_4(dut):
    dut.i_inst.value = 0x0C8000EF  # jal x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_branch_type == 2
    assert dut.o_alu_op_a_sel == 1
    assert dut.o_alu_op_b_sel == 1
    assert dut.o_ex_res_sel == 0
    assert dut.o_ma_res_sel == 0
    assert dut.o_atomic == 1
    assert dut.o_rd == 1
    assert dut.o_rs1 == 0
    assert dut.o_rs2 == 0
    assert dut.o_immed == 200


@cocotb.test
async def format_test_5(dut):
    dut.i_inst.value = 0x0C8100E7  # jalr x1, 200(x2)
    await Timer(1, units="ns")
    assert dut.o_branch_type == 3
    assert dut.o_alu_op_a_sel == 1
    assert dut.o_alu_op_b_sel == 1
    assert dut.o_ex_res_sel == 0
    assert dut.o_ma_res_sel == 0
    assert dut.o_atomic == 1
    assert dut.o_rd == 1
    assert dut.o_rs1 == 2
    assert dut.o_rs2 == 0
    assert dut.o_immed == 200


@cocotb.test
async def format_test_6(dut):
    dut.i_inst.value = 0x004B0137  # lui x2, 1200
    await Timer(1, units="ns")
    assert dut.o_branch_type == 0
    assert dut.o_alu_op_a_sel == 0
    assert dut.o_alu_op_b_sel == 1
    assert dut.o_ex_res_sel == 0
    assert dut.o_ma_res_sel == 0
    assert dut.o_atomic == 0
    assert dut.o_rd == 2
    assert dut.o_rs1 == 0
    assert dut.o_rs2 == 0
    assert dut.o_immed == 1200 << 12


@cocotb.test
async def format_test_7(dut):
    dut.i_inst.value = 0x0012C097  # auipc x1, 300
    await Timer(1, units="ns")
    assert dut.o_branch_type == 0
    assert dut.o_alu_op_a_sel == 1
    assert dut.o_alu_op_b_sel == 1
    assert dut.o_ex_res_sel == 0
    assert dut.o_ma_res_sel == 0
    assert dut.o_atomic == 0
    assert dut.o_rd == 1
    assert dut.o_rs1 == 0
    assert dut.o_rs2 == 0
    assert dut.o_immed == 300 << 12


@cocotb.test
async def format_test_8(dut):
    dut.i_inst.value = 0x00418133  # add x2, x3, x4
    await Timer(1, units="ns")
    assert dut.o_branch_type == 0
    assert dut.o_alu_op_a_sel == 0
    assert dut.o_alu_op_b_sel == 0
    assert dut.o_ex_res_sel == 0
    assert dut.o_ma_res_sel == 0
    assert dut.o_atomic == 0
    assert dut.o_rd == 2
    assert dut.o_rs1 == 3
    assert dut.o_rs2 == 4
    assert dut.o_immed == 0


@cocotb.test
async def format_test_9(dut):
    dut.i_inst.value = 0x40418133  # sub x2, x3, x4
    await Timer(1, units="ns")
    assert dut.o_branch_type == 0
    assert dut.o_alu_op_a_sel == 0
    assert dut.o_alu_op_b_sel == 0
    assert dut.o_ex_res_sel == 0
    assert dut.o_ma_res_sel == 0
    assert dut.o_atomic == 0
    assert dut.o_rd == 2
    assert dut.o_rs1 == 3
    assert dut.o_rs2 == 4
    assert dut.o_immed == 0


@cocotb.test
async def format_test_10(dut):
    dut.i_inst.value = 0x01418113  # addi x2, x3, 20
    await Timer(1, units="ns")
    assert dut.o_branch_type == 0
    assert dut.o_alu_op_a_sel == 0
    assert dut.o_alu_op_b_sel == 1
    assert dut.o_ex_res_sel == 0
    assert dut.o_ma_res_sel == 0
    assert dut.o_atomic == 0
    assert dut.o_rd == 2
    assert dut.o_rs1 == 3
    assert dut.o_rs2 == 0
    assert dut.o_immed == 20


@cocotb.test
async def format_test_11(dut):
    dut.i_inst.value = 0x0141F113  # andi x2, x3, 20
    await Timer(1, units="ns")
    assert dut.o_branch_type == 0
    assert dut.o_alu_op_a_sel == 0
    assert dut.o_alu_op_b_sel == 1
    assert dut.o_ex_res_sel == 0
    assert dut.o_ma_res_sel == 0
    assert dut.o_atomic == 0
    assert dut.o_rd == 2
    assert dut.o_rs1 == 3
    assert dut.o_rs2 == 0
    assert dut.o_immed == 20


@cocotb.test
async def format_test_12(dut):
    dut.i_inst.value = 0x0C81A113  # slti x2, x3, 200
    await Timer(1, units="ns")
    assert dut.o_branch_type == 0
    assert dut.o_alu_op_a_sel == 0
    assert dut.o_alu_op_b_sel == 1
    assert dut.o_ex_res_sel == 0
    assert dut.o_ma_res_sel == 0
    assert dut.o_atomic == 0
    assert dut.o_rd == 2
    assert dut.o_rs1 == 3
    assert dut.o_rs2 == 0
    assert dut.o_immed == 200


@cocotb.test
async def format_test_13(dut):
    dut.i_inst.value = 0x02418133  # mul x2, x3, x4
    await Timer(1, units="ns")
    assert dut.o_branch_type == 0
    assert dut.o_alu_op_a_sel == 0
    assert dut.o_alu_op_b_sel == 0
    assert dut.o_ex_res_sel == 0
    assert dut.o_ma_res_sel == 0
    assert dut.o_atomic == 0
    assert dut.o_rd == 2
    assert dut.o_rs1 == 3
    assert dut.o_rs2 == 4
    assert dut.o_immed == 0


@cocotb.test
async def format_test_14(dut):
    dut.i_inst.value = 0x0241C133  # div x2, x3, x4
    await Timer(1, units="ns")
    assert dut.o_branch_type == 0
    assert dut.o_alu_op_a_sel == 0
    assert dut.o_alu_op_b_sel == 0
    assert dut.o_ex_res_sel == 0
    assert dut.o_ma_res_sel == 0
    assert dut.o_atomic == 0
    assert dut.o_rd == 2
    assert dut.o_rs1 == 3
    assert dut.o_rs2 == 4
    assert dut.o_immed == 0


@cocotb.test
async def format_test_15(dut):
    dut.i_inst.value = 0x00000073  # ecall
    await Timer(1, units="ns")
    assert dut.o_branch_type == 0
    assert dut.o_ex_res_sel == 1
    assert dut.o_ma_res_sel == 0
    assert dut.o_atomic == 1
    assert dut.o_rd == 0
    assert dut.o_rs1 == 0
    assert dut.o_rs2 == 0


@cocotb.test
async def format_test_16(dut):
    dut.i_inst.value = 0x00100073  # ebreak
    await Timer(1, units="ns")
    assert dut.o_branch_type == 0
    assert dut.o_ex_res_sel == 1
    assert dut.o_ma_res_sel == 0
    assert dut.o_atomic == 1
    assert dut.o_rd == 0
    assert dut.o_rs1 == 0
    assert dut.o_rs2 == 0


@cocotb.test
async def format_test_17(dut):
    dut.i_inst.value = 0x341110F3  # csrrw x1, mepc, x2
    await Timer(1, units="ns")
    assert dut.o_branch_type == 0
    assert dut.o_ex_res_sel == 1
    assert dut.o_ma_res_sel == 0
    assert dut.o_atomic == 1
    assert dut.o_rd == 1
    assert dut.o_rs1 == 2
    assert dut.o_rs2 == 0
    assert dut.o_alu_op_a_sel == 0
    assert dut.o_alu_op_b_sel == 1
    assert dut.o_sys_op_sel == 0
    assert int(dut.o_immed) & 0x00000FFF == 833


@cocotb.test
async def format_test_18(dut):
    dut.i_inst.value = 0x341A50F3  # csrrwi x1, mepc, 20
    await Timer(1, units="ns")
    assert dut.o_branch_type == 0
    assert dut.o_ex_res_sel == 1
    assert dut.o_ma_res_sel == 0
    assert dut.o_atomic == 1
    assert dut.o_rd == 1
    assert dut.o_rs1 == 0
    assert dut.o_rs2 == 0
    assert dut.o_alu_op_a_sel == 0
    assert dut.o_alu_op_b_sel == 1
    assert dut.o_sys_op_sel == 1
    assert int(dut.o_immed) & 0x00000FFF == 833
    assert int(dut.o_immed) >> 12 == 20
