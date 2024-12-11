import cocotb
from cocotb.triggers import Timer


@cocotb.test
async def write_mask_test_1(dut):
    dut.i_index.value = 0
    dut.i_memop.value = 3
    await Timer(1, units="ns")
    assert dut.o_mask == 0b1111
    assert dut.o_error == 0


@cocotb.test
async def write_mask_test_2(dut):
    dut.i_index.value = 1
    dut.i_memop.value = 3
    await Timer(1, units="ns")
    assert dut.o_error == 1


@cocotb.test
async def write_mask_test_3(dut):
    dut.i_index.value = 2
    dut.i_memop.value = 3
    await Timer(1, units="ns")
    assert dut.o_error == 1


@cocotb.test
async def write_mask_test_4(dut):
    dut.i_index.value = 3
    dut.i_memop.value = 3
    await Timer(1, units="ns")
    assert dut.o_error == 1


@cocotb.test
async def write_mask_test_5(dut):
    dut.i_index.value = 0
    dut.i_memop.value = 8
    await Timer(1, units="ns")
    assert dut.o_mask == 0b1111
    assert dut.o_error == 0


@cocotb.test
async def write_mask_test_6(dut):
    dut.i_index.value = 1
    dut.i_memop.value = 8
    await Timer(1, units="ns")
    assert dut.o_error == 1


@cocotb.test
async def write_mask_test_7(dut):
    dut.i_index.value = 2
    dut.i_memop.value = 8
    await Timer(1, units="ns")
    assert dut.o_error == 1


@cocotb.test
async def write_mask_test_8(dut):
    dut.i_index.value = 3
    dut.i_memop.value = 8
    await Timer(1, units="ns")
    assert dut.o_error == 1


@cocotb.test
async def write_mask_test_9(dut):
    dut.i_index.value = 0
    dut.i_memop.value = 1
    await Timer(1, units="ns")
    assert dut.o_mask == 0b0001
    assert dut.o_error == 0


@cocotb.test
async def write_mask_test_10(dut):
    dut.i_index.value = 1
    dut.i_memop.value = 1
    await Timer(1, units="ns")
    assert dut.o_mask == 0b0010
    assert dut.o_error == 0


@cocotb.test
async def write_mask_test_11(dut):
    dut.i_index.value = 2
    dut.i_memop.value = 1
    await Timer(1, units="ns")
    assert dut.o_mask == 0b0100
    assert dut.o_error == 0


@cocotb.test
async def write_mask_test_12(dut):
    dut.i_index.value = 3
    dut.i_memop.value = 1
    await Timer(1, units="ns")
    assert dut.o_mask == 0b1000
    assert dut.o_error == 0


@cocotb.test
async def write_mask_test_13(dut):
    dut.i_index.value = 0
    dut.i_memop.value = 6
    await Timer(1, units="ns")
    assert dut.o_mask == 0b0001
    assert dut.o_error == 0


@cocotb.test
async def write_mask_test_14(dut):
    dut.i_index.value = 1
    dut.i_memop.value = 6
    await Timer(1, units="ns")
    assert dut.o_mask == 0b0010
    assert dut.o_error == 0


@cocotb.test
async def write_mask_test_15(dut):
    dut.i_index.value = 2
    dut.i_memop.value = 6
    await Timer(1, units="ns")
    assert dut.o_mask == 0b0100
    assert dut.o_error == 0


@cocotb.test
async def write_mask_test_16(dut):
    dut.i_index.value = 3
    dut.i_memop.value = 6
    await Timer(1, units="ns")
    assert dut.o_mask == 0b1000
    assert dut.o_error == 0


@cocotb.test
async def write_mask_test_17(dut):
    dut.i_index.value = 0
    dut.i_memop.value = 2
    await Timer(1, units="ns")
    assert dut.o_mask == 0b0011
    assert dut.o_error == 0


@cocotb.test
async def write_mask_test_18(dut):
    dut.i_index.value = 1
    dut.i_memop.value = 2
    await Timer(1, units="ns")
    assert dut.o_error == 1


@cocotb.test
async def write_mask_test_19(dut):
    dut.i_index.value = 2
    dut.i_memop.value = 2
    await Timer(1, units="ns")
    assert dut.o_mask == 0b1100
    assert dut.o_error == 0


@cocotb.test
async def write_mask_test_20(dut):
    dut.i_index.value = 3
    dut.i_memop.value = 2
    await Timer(1, units="ns")
    assert dut.o_error == 1


@cocotb.test
async def write_mask_test_21(dut):
    dut.i_index.value = 0
    dut.i_memop.value = 7
    await Timer(1, units="ns")
    assert dut.o_mask == 0b0011
    assert dut.o_error == 0


@cocotb.test
async def write_mask_test_22(dut):
    dut.i_index.value = 1
    dut.i_memop.value = 7
    await Timer(1, units="ns")
    assert dut.o_error == 1


@cocotb.test
async def write_mask_test_23(dut):
    dut.i_index.value = 2
    dut.i_memop.value = 7
    await Timer(1, units="ns")
    assert dut.o_mask == 0b1100
    assert dut.o_error == 0


@cocotb.test
async def write_mask_test_24(dut):
    dut.i_index.value = 3
    dut.i_memop.value = 7
    await Timer(1, units="ns")
    assert dut.o_error == 1
