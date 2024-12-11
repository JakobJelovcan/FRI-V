import cocotb
from cocotb.triggers import Timer


@cocotb.test
async def lzd_test_1(dut):
    dut.i_data.value = 0x00
    await Timer(1, units="ns")
    assert dut.o_valid.value == 0


@cocotb.test
async def lzd_test_2(dut):
    dut.i_data.value = 0x01
    await Timer(1, units="ns")
    assert dut.o_valid.value == 1
    assert dut.o_index.value == 0


@cocotb.test
async def lzd_test_3(dut):
    dut.i_data.value = 0x02
    await Timer(1, units="ns")
    assert dut.o_valid.value == 1
    assert dut.o_index.value == 1


@cocotb.test
async def lzd_test_4(dut):
    dut.i_data.value = 0x03
    await Timer(1, units="ns")
    assert dut.o_valid.value == 1
    assert dut.o_index.value == 0


@cocotb.test
async def lzd_test_5(dut):
    dut.i_data.value = 0xFF
    await Timer(1, units="ns")
    assert dut.o_valid.value == 1
    assert dut.o_index.value == 0


@cocotb.test
async def lzd_test_6(dut):
    dut.i_data.value = 0x8
    await Timer(1, units="ns")
    assert dut.o_valid.value == 1
    assert dut.o_index.value == 3


@cocotb.test
async def lzd_test_7(dut):
    dut.i_data.value = 0x80
    await Timer(1, units="ns")
    assert dut.o_valid.value == 1
    assert dut.o_index.value == 7


@cocotb.test
async def lzd_test_8(dut):
    dut.i_data.value = 0x20
    await Timer(1, units="ns")
    assert dut.o_valid.value == 1
    assert dut.o_index.value == 5
