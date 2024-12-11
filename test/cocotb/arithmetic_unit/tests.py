import cocotb
from cocotb.triggers import Timer


@cocotb.test
async def arithmetic_test_1(dut):
    dut.i_data_a.value = 0x00000000
    dut.i_data_b.value = 0x00000000
    dut.i_arithop.value = 0
    await Timer(1, units="ns")
    assert dut.o_data == 0
    assert dut.o_flags == 0b0010


@cocotb.test
async def arithmetic_test_2(dut):
    dut.i_data_a.value = 0x0000000A
    dut.i_data_b.value = 0x00000014
    dut.i_arithop.value = 0
    await Timer(1, units="ns")
    assert dut.o_data == 0x0000001E
    assert dut.o_flags == 0b0000


@cocotb.test
async def arithmetic_test_3(dut):
    dut.i_data_a.value = 0x0000000A
    dut.i_data_b.value = 0x00000014
    dut.i_arithop.value = 1
    await Timer(1, units="ns")
    assert dut.o_data == 0xFFFFFFF6
    assert dut.o_flags == 0b0001


@cocotb.test
async def arithmetic_test_4(dut):
    dut.i_data_a.value = 0xFFFFFFFF
    dut.i_data_b.value = 0x00000001
    dut.i_arithop.value = 1
    await Timer(1, units="ns")
    assert dut.o_data == 0xFFFFFFFE
    assert dut.o_flags == 0b0101


@cocotb.test
async def arithmetic_test_5(dut):
    dut.i_data_a.value = 0xFFFFFFFF
    dut.i_data_b.value = 0x00000001
    dut.i_arithop.value = 0
    await Timer(1, units="ns")
    assert dut.o_data == 0x00000000
    assert dut.o_flags == 0b0110


@cocotb.test
async def arithmetic_test_6(dut):
    dut.i_data_a.value = 0xFFFFFFFF
    dut.i_data_b.value = 0x00000002
    dut.i_arithop.value = 0
    await Timer(1, units="ns")
    assert dut.o_data == 0x00000001
    assert dut.o_flags == 0b0100


@cocotb.test
async def arithmetic_test_7(dut):
    dut.i_data_a.value = 0x7FFFFFFF
    dut.i_data_b.value = 0x00000001
    dut.i_arithop.value = 0
    await Timer(1, units="ns")
    assert dut.o_data == 0x80000000
    assert dut.o_flags == 0b1001


@cocotb.test
async def arithmetic_test_8(dut):
    dut.i_data_a.value = 0x00000004
    dut.i_data_b.value = 0x00000000
    dut.i_arithop.value = 2
    await Timer(1, units="ns")
    assert dut.o_data == 0x00000008
    assert dut.o_flags == 0b0000


@cocotb.test
async def arithmetic_test_9(dut):
    dut.i_data_a.value = 0x00000004
    dut.i_data_b.value = 0x00000000
    dut.i_arithop.value = 3
    await Timer(1, units="ns")
    assert dut.o_data == 0x00000000
    assert dut.o_flags == 0b0110
