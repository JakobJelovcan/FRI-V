import cocotb
from cocotb.triggers import Timer


@cocotb.test
async def data_align_test_1(dut):
    dut.i_offset.value = 0
    dut.i_data.value = 0x11223344
    await Timer(1, units="ns")
    assert dut.o_data.value == 0x11223344


@cocotb.test
async def data_align_test_2(dut):
    dut.i_offset.value = 1
    dut.i_data.value = 0x11223344
    await Timer(1, units="ns")
    assert dut.o_data.value == 0x22334400


@cocotb.test
async def data_align_test_3(dut):
    dut.i_offset.value = 2
    dut.i_data.value = 0x11223344
    await Timer(1, units="ns")
    assert dut.o_data.value == 0x33440000


@cocotb.test
async def data_align_test_4(dut):
    dut.i_offset.value = 3
    dut.i_data.value = 0x11223344
    await Timer(1, units="ns")
    assert dut.o_data.value == 0x44000000
