import cocotb
from cocotb.triggers import Timer


@cocotb.test
async def sign_extend_test_1(dut):
    dut.i_data.value = 0x11223344
    dut.i_offset.value = 0
    dut.i_memop.value = 3  # load word
    await Timer(1, units="ns")
    assert dut.o_data == 0x11223344


@cocotb.test
async def sign_extend_test_2(dut):
    dut.i_data.value = 0x11223344
    dut.i_offset.value = 1
    dut.i_memop.value = 3  # load word
    await Timer(1, units="ns")
    assert dut.o_data == 0x11223344


@cocotb.test
async def sign_extend_test_3(dut):
    dut.i_data.value = 0x11223344
    dut.i_offset.value = 2
    dut.i_memop.value = 3  # load word
    await Timer(1, units="ns")
    assert dut.o_data == 0x11223344


@cocotb.test
async def sign_extend_test_4(dut):
    dut.i_data.value = 0x11223344
    dut.i_offset.value = 3
    dut.i_memop.value = 3  # load word
    await Timer(1, units="ns")
    assert dut.o_data == 0x11223344


@cocotb.test
async def sign_extend_test_5(dut):
    dut.i_data.value = 0x11223344
    dut.i_offset.value = 0
    dut.i_memop.value = 4  # load unsigned byte
    await Timer(1, units="ns")
    assert dut.o_data == 0x00000044


@cocotb.test
async def sign_extend_test_6(dut):
    dut.i_data.value = 0x11223344
    dut.i_offset.value = 1
    dut.i_memop.value = 4  # load unsigned byte
    await Timer(1, units="ns")
    assert dut.o_data == 0x00000033


@cocotb.test
async def sign_extend_test_7(dut):
    dut.i_data.value = 0x11223344
    dut.i_offset.value = 2
    dut.i_memop.value = 4  # load unsigned byte
    await Timer(1, units="ns")
    assert dut.o_data == 0x00000022


@cocotb.test
async def sign_extend_test_8(dut):
    dut.i_data.value = 0x11223344
    dut.i_offset.value = 3
    dut.i_memop.value = 4  # load unsigned byte
    await Timer(1, units="ns")
    assert dut.o_data == 0x00000011


@cocotb.test
async def sign_extend_test_9(dut):
    dut.i_data.value = 0x11223344
    dut.i_offset.value = 0
    dut.i_memop.value = 5  # load unsigned hword
    await Timer(1, units="ns")
    assert dut.o_data == 0x00003344


@cocotb.test
async def sign_extend_test_10(dut):
    dut.i_data.value = 0x11223344
    dut.i_offset.value = 2
    dut.i_memop.value = 5  # load unsigned hword
    await Timer(1, units="ns")
    assert dut.o_data == 0x00001122


@cocotb.test
async def sign_extend_test_11(dut):
    dut.i_data.value = 0xAA1122BB
    dut.i_offset.value = 0
    dut.i_memop.value = 1  # load signed byte
    await Timer(1, units="ns")
    assert dut.o_data == 0xFFFFFFBB


@cocotb.test
async def sign_extend_test_12(dut):
    dut.i_data.value = 0xAA1122BB
    dut.i_offset.value = 1
    dut.i_memop.value = 1  # load signed byte
    await Timer(1, units="ns")
    assert dut.o_data == 0x00000022


@cocotb.test
async def sign_extend_test_13(dut):
    dut.i_data.value = 0xAA1122BB
    dut.i_offset.value = 2
    dut.i_memop.value = 1  # load signed byte
    await Timer(1, units="ns")
    assert dut.o_data == 0x00000011


@cocotb.test
async def sign_extend_test_14(dut):
    dut.i_data.value = 0xAA1122BB
    dut.i_offset.value = 3
    dut.i_memop.value = 1  # load signed byte
    await Timer(1, units="ns")
    assert dut.o_data == 0xFFFFFFAA


@cocotb.test
async def sign_extend_test_15(dut):
    dut.i_data.value = 0xAA1122BB
    dut.i_offset.value = 0
    dut.i_memop.value = 2  # load signed hword
    await Timer(1, units="ns")
    assert dut.o_data == 0x000022BB


@cocotb.test
async def sign_extend_test_16(dut):
    dut.i_data.value = 0xAA1122BB
    dut.i_offset.value = 2
    dut.i_memop.value = 2  # load signed hword
    await Timer(1, units="ns")
    assert dut.o_data == 0xFFFFAA11
