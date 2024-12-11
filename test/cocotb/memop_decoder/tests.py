import cocotb
from cocotb.triggers import Timer


@cocotb.test
async def mulop_test_1(dut):
    dut.i_inst.value = 0x0C21A423  # sw x2, 200(x3)
    await Timer(1, units="ns")
    assert dut.o_memop == 8
    assert dut.o_invalid == 0


@cocotb.test
async def mulop_test_2(dut):
    dut.i_inst.value = 0x0C219423  # sh x2, 200(x3)
    await Timer(1, units="ns")
    assert dut.o_memop == 7
    assert dut.o_invalid == 0


@cocotb.test
async def mulop_test_3(dut):
    dut.i_inst.value = 0x0C218423  # sb x2, 200(x3)
    await Timer(1, units="ns")
    assert dut.o_memop == 6
    assert dut.o_invalid == 0


@cocotb.test
async def mulop_test_4(dut):
    dut.i_inst.value = 0x0C818103  # lb x2, 200(x3)
    await Timer(1, units="ns")
    assert dut.o_memop == 1
    assert dut.o_invalid == 0


@cocotb.test
async def mulop_test_5(dut):
    dut.i_inst.value = 0x0C819103  # lh x2, 200(x3)
    await Timer(1, units="ns")
    assert dut.o_memop == 2
    assert dut.o_invalid == 0


@cocotb.test
async def mulop_test_6(dut):
    dut.i_inst.value = 0x0C81A103  # lw x2, 200(x3)
    await Timer(1, units="ns")
    assert dut.o_memop == 3
    assert dut.o_invalid == 0


@cocotb.test
async def mulop_test_7(dut):
    dut.i_inst.value = 0x0C81C103  # lbu x2, 200(x3)
    await Timer(1, units="ns")
    assert dut.o_memop == 4
    assert dut.o_invalid == 0


@cocotb.test
async def mulop_test_8(dut):
    dut.i_inst.value = 0x0C81D103  # lhu x2, 200(x3)
    await Timer(1, units="ns")
    assert dut.o_memop == 5
    assert dut.o_invalid == 0


@cocotb.test
async def invalid_test_1(dut):
    dut.i_inst.value = 0x00000000  # invalid
    await Timer(1, units="ns")
    assert dut.o_invalid == 1


@cocotb.test
async def invalid_test_2(dut):
    dut.i_inst.value = 0x00418133  # add x2, x3, x4
    await Timer(1, units="ns")
    assert dut.o_invalid == 1


@cocotb.test
async def invalid_test_3(dut):
    dut.i_inst.value = 0x0c315463  # bge x2, x3, 200
    await Timer(1, units="ns")
    assert dut.o_invalid == 1


@cocotb.test
async def invalid_test_4(dut):
    dut.i_inst.value = 0x00100073  # ebreak
    await Timer(1, units="ns")
    assert dut.o_invalid == 1