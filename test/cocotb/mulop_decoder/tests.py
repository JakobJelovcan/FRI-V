import cocotb
from cocotb.triggers import Timer


@cocotb.test
async def mulop_test_1(dut):
    dut.i_inst.value = 0x023100B3  # mul x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_mulop == 0
    assert dut.o_invalid == 0


@cocotb.test
async def mulop_test_2(dut):
    dut.i_inst.value = 0x023110B3  # mulh x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_mulop == 1
    assert dut.o_invalid == 0


@cocotb.test
async def mulop_test_3(dut):
    dut.i_inst.value = 0x023130B3  # mulhu x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_mulop == 2
    assert dut.o_invalid == 0


@cocotb.test
async def mulop_test_4(dut):
    dut.i_inst.value = 0x023120B3  # mulhsu x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_mulop == 3
    assert dut.o_invalid == 0


@cocotb.test
async def invalid_test_1(dut):
    dut.i_inst.value = 0x0240A423  # sw x4, 40(x1)
    await Timer(1, units="ns")
    assert dut.o_invalid == 1


@cocotb.test
async def invalid_test_2(dut):
    dut.i_inst.value = 0x02408423  # sb x4, 40(x1)
    await Timer(1, units="ns")
    assert dut.o_invalid == 1


@cocotb.test
async def invalid_test_3(dut):
    dut.i_inst.value = 0x0141A083  # lw x1, 20(x3)
    await Timer(1, units="ns")
    assert dut.o_invalid == 1


@cocotb.test
async def invalid_test_4(dut):
    dut.i_inst.value = 0x00A10093  # addi x1, x2, 10
    await Timer(1, units="ns")
    assert dut.o_invalid == 1


@cocotb.test
async def invalid_test_5(dut):
    dut.i_inst.value = 0x000C8117  # auipc x2, 200
    await Timer(1, units="ns")
    assert dut.o_invalid == 1
