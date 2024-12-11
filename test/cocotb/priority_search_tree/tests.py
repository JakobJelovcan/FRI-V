import cocotb
from cocotb.triggers import Timer


@cocotb.test
async def priority_search_tree_test_1(dut):
    dut.i_priorities.value = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
    dut.i_pending.value = 0b00000000
    await Timer(1, units="ns")
    assert dut.o_valid.value == 0


@cocotb.test
async def priority_search_tree_test_2(dut):
    dut.i_priorities.value = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
    dut.i_pending.value = 0b00000001
    await Timer(1, units="ns")
    assert dut.o_valid.value == 1
    assert dut.o_index.value == 0


@cocotb.test
async def priority_search_tree_test_3(dut):
    dut.i_priorities.value = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1F, 0x00]
    dut.i_pending.value = 0b00000001
    await Timer(1, units="ns")
    assert dut.o_valid.value == 1
    assert dut.o_index.value == 0


@cocotb.test
async def priority_search_tree_test_4(dut):
    dut.i_priorities.value = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1F, 0x00]
    dut.i_pending.value = 0b00000011
    await Timer(1, units="ns")
    assert dut.o_valid.value == 1
    assert dut.o_index.value == 1


@cocotb.test
async def priority_search_tree_test_5(dut):
    dut.i_priorities.value = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1E, 0x1F]
    dut.i_pending.value = 0b00000011
    await Timer(1, units="ns")
    assert dut.o_valid.value == 1
    assert dut.o_index.value == 0


@cocotb.test
async def priority_search_tree_test_6(dut):
    dut.i_priorities.value = [0x00, 0x10, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F]
    dut.i_pending.value = 0b10000000
    await Timer(1, units="ns")
    assert dut.o_valid.value == 1
    assert dut.o_index.value == 7


@cocotb.test
async def priority_search_tree_test_7(dut):
    dut.i_priorities.value = [0x00, 0x10, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F]
    dut.i_pending.value = 0b10010000
    await Timer(1, units="ns")
    assert dut.o_valid.value == 1
    assert dut.o_index.value == 4


@cocotb.test
async def priority_search_tree_test_8(dut):
    dut.i_priorities.value = [0x11, 0x10, 0x10, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F]
    dut.i_pending.value = 0b11111111
    await Timer(1, units="ns")
    assert dut.o_valid.value == 1
    assert dut.o_index.value == 7
