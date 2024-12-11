import cocotb
from cocotb.triggers import Timer


@cocotb.test
async def branch_test_1(dut):
    dut.i_branch_type.value = 0
    dut.i_alu_out.value = 0
    dut.i_valid.value = 0
    dut.i_branch_base.value = 0x00000000
    dut.i_branch_offset.value = 0x00000000
    dut.i_int_taken.value = 0
    dut.i_int_addr.value = 0x00000000
    await Timer(1, units="ns")
    assert dut.o_branch_taken == 0


@cocotb.test
async def branch_test_2(dut):
    dut.i_branch_type.value = 0
    dut.i_alu_out.value = 0
    dut.i_valid.value = 0
    dut.i_branch_base.value = 0x00000000
    dut.i_branch_offset.value = 0x00000000
    dut.i_int_taken.value = 1
    dut.i_int_addr.value = 0x11223344
    await Timer(1, units="ns")
    assert dut.o_branch_taken == 1
    assert dut.o_branch_addr == 0x11223344


@cocotb.test
async def branch_test_3(dut):
    dut.i_branch_type.value = 2
    dut.i_alu_out.value = 0
    dut.i_valid.value = 1
    dut.i_branch_base.value = 0xAABBCCDD
    dut.i_branch_offset.value = 0x00000001
    dut.i_int_taken.value = 1
    dut.i_int_addr.value = 0x11223344
    await Timer(1, units="ns")
    assert dut.o_branch_taken == 1
    assert dut.o_branch_addr == 0x11223344


@cocotb.test
async def branch_test_4(dut):
    dut.i_branch_type.value = 2
    dut.i_alu_out.value = 0
    dut.i_valid.value = 1
    dut.i_branch_base.value = 0xAABBCCDD
    dut.i_branch_offset.value = 0x00000001
    dut.i_int_taken.value = 0
    dut.i_int_addr.value = 0x11223344
    await Timer(1, units="ns")
    assert dut.o_branch_taken == 1
    assert dut.o_branch_addr == 0xAABBCCDE


@cocotb.test
async def branch_test_5(dut):
    dut.i_branch_type.value = 1
    dut.i_alu_out.value = 0
    dut.i_valid.value = 1
    dut.i_branch_base.value = 0xAABBCCDD
    dut.i_branch_offset.value = 0x00000001
    dut.i_int_taken.value = 0
    dut.i_int_addr.value = 0x11223344
    await Timer(1, units="ns")
    assert dut.o_branch_taken == 0


@cocotb.test
async def branch_test_6(dut):
    dut.i_branch_type.value = 1
    dut.i_alu_out.value = 1
    dut.i_valid.value = 1
    dut.i_branch_base.value = 0xAABBCCDD
    dut.i_branch_offset.value = 0x00000001
    dut.i_int_taken.value = 0
    dut.i_int_addr.value = 0x11223344
    await Timer(1, units="ns")
    assert dut.o_branch_taken == 1
    assert dut.o_branch_addr == 0xAABBCCDE


@cocotb.test
async def branch_test_7(dut):
    dut.i_branch_type.value = 1
    dut.i_alu_out.value = 1
    dut.i_valid.value = 1
    dut.i_branch_base.value = 0xAABBCCDD
    dut.i_branch_offset.value = 0x00000001
    dut.i_int_taken.value = 1
    dut.i_int_addr.value = 0x11223344
    await Timer(1, units="ns")
    assert dut.o_branch_taken == 1
    assert dut.o_branch_addr == 0x11223344
