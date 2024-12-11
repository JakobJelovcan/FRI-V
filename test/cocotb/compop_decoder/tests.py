import cocotb
from cocotb.triggers import Timer


@cocotb.test
async def compop_test_1(dut):
    dut.i_inst.value = 0x0C208463  # beq x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_compop == 0
    assert dut.o_invalid == 0


@cocotb.test
async def compop_test_2(dut):
    dut.i_inst.value = 0x0C209463  # bne x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_compop == 1
    assert dut.o_invalid == 0


@cocotb.test
async def compop_test_3(dut):
    dut.i_inst.value = 0x0C20C463  # blt x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_compop == 2
    assert dut.o_invalid == 0


@cocotb.test
async def compop_test_4(dut):
    dut.i_inst.value = 0x003120B3  # slt x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_compop == 2
    assert dut.o_invalid == 0


@cocotb.test
async def compop_test_5(dut):
    dut.i_inst.value = 0x0C812093  # slti x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_compop == 2
    assert dut.o_invalid == 0


@cocotb.test
async def compop_test_6(dut):
    dut.i_inst.value = 0x0C20E463  # bltu x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_compop == 3
    assert dut.o_invalid == 0


@cocotb.test
async def compop_test_7(dut):
    dut.i_inst.value = 0x003130B3  # sltu x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_compop == 3
    assert dut.o_invalid == 0


@cocotb.test
async def compop_test_8(dut):
    dut.i_inst.value = 0x0C813093  # sltiu x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_compop == 3
    assert dut.o_invalid == 0


@cocotb.test
async def compop_test_9(dut):
    dut.i_inst.value = 0x0C20D463  # bge x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_compop == 4
    assert dut.o_invalid == 0


@cocotb.test
async def compop_test_10(dut):
    dut.i_inst.value = 0x0C20F463  # bgeu x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_compop == 5
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
