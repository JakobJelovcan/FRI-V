import cocotb
from cocotb.triggers import Timer


@cocotb.test
async def arithop_test_1(dut):
    dut.i_inst.value = 0x003100B3  # add x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_arithop == 0
    assert dut.o_invalid == 0


@cocotb.test
async def arithop_test_2(dut):
    dut.i_inst.value = 0x0C810093  # addi x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_arithop == 0
    assert dut.o_invalid == 0


@cocotb.test
async def arithop_test_3(dut):
    dut.i_inst.value = 0x01412083  # lw x1, 20(x2)
    await Timer(1, units="ns")
    assert dut.o_arithop == 0
    assert dut.o_invalid == 0


@cocotb.test
async def arithop_test_4(dut):
    dut.i_inst.value = 0x01611083  # lh x1, 22(x2)
    await Timer(1, units="ns")
    assert dut.o_arithop == 0
    assert dut.o_invalid == 0


@cocotb.test
async def arithop_test_5(dut):
    dut.i_inst.value = 0x01710083  # lb x1, 23(x2)
    await Timer(1, units="ns")
    assert dut.o_arithop == 0
    assert dut.o_invalid == 0


@cocotb.test
async def arithop_test_6(dut):
    dut.i_inst.value = 0x00112A23  # sw x1, 20(x2)
    await Timer(1, units="ns")
    assert dut.o_arithop == 0
    assert dut.o_invalid == 0


@cocotb.test
async def arithop_test_7(dut):
    dut.i_inst.value = 0x00111B23  # sh x1, 22(x2)
    await Timer(1, units="ns")
    assert dut.o_arithop == 0
    assert dut.o_invalid == 0


@cocotb.test
async def arithop_test_8(dut):
    dut.i_inst.value = 0x00110BA3  # sb x1, 23(x2)
    await Timer(1, units="ns")
    assert dut.o_arithop == 0
    assert dut.o_invalid == 0


@cocotb.test
async def arithop_test_9(dut):
    dut.i_inst.value = 0x0012C097  # auipc x1, 300
    await Timer(1, units="ns")
    assert dut.o_arithop == 0
    assert dut.o_invalid == 0


@cocotb.test
async def arithop_test_10(dut):
    dut.i_inst.value = 0x12C100E7  # jalr ra, 300(x2)
    await Timer(1, units="ns")
    assert dut.o_arithop == 2
    assert dut.o_invalid == 0


@cocotb.test
async def arithop_test_11(dut):
    dut.i_inst.value = 0x12C000EF  # jal ra, 300
    await Timer(1, units="ns")
    assert dut.o_arithop == 2
    assert dut.o_invalid == 0


@cocotb.test
async def arithop_test_12(dut):
    dut.i_inst.value = 0x403100B3  # sub x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_arithop == 1
    assert dut.o_invalid == 0


@cocotb.test
async def arithop_test_13(dut):
    dut.i_inst.value = 0x0C208463  # beq x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_arithop == 1
    assert dut.o_invalid == 0


@cocotb.test
async def arithop_test_14(dut):
    dut.i_inst.value = 0x0C209463  # bne x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_arithop == 1
    assert dut.o_invalid == 0


@cocotb.test
async def arithop_test_15(dut):
    dut.i_inst.value = 0x0C20C463  # blt x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_arithop == 1
    assert dut.o_invalid == 0


@cocotb.test
async def arithop_test_16(dut):
    dut.i_inst.value = 0x003120B3  # slt x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_arithop == 1
    assert dut.o_invalid == 0


@cocotb.test
async def arithop_test_17(dut):
    dut.i_inst.value = 0x0C812093  # slti x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_arithop == 1
    assert dut.o_invalid == 0


@cocotb.test
async def arithop_test_18(dut):
    dut.i_inst.value = 0x0C20E463  # bltu x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_arithop == 1
    assert dut.o_invalid == 0


@cocotb.test
async def arithop_test_19(dut):
    dut.i_inst.value = 0x003130B3  # sltu x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_arithop == 1
    assert dut.o_invalid == 0


@cocotb.test
async def arithop_test_20(dut):
    dut.i_inst.value = 0x0C813093  # sltiu x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_arithop == 1
    assert dut.o_invalid == 0


@cocotb.test
async def arithop_test_21(dut):
    dut.i_inst.value = 0x0C20D463  # bge x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_arithop == 1
    assert dut.o_invalid == 0


@cocotb.test
async def arithop_test_22(dut):
    dut.i_inst.value = 0x0C20F463  # bgeu x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_arithop == 1
    assert dut.o_invalid == 0


@cocotb.test
async def invalid_test_1(dut):
    dut.i_inst.value = 0x023140B3  # div x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_invalid == 1


@cocotb.test
async def invalid_test_2(dut):
    dut.i_inst.value = 0x023150B3  # divu x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_invalid == 1


@cocotb.test
async def invalid_test_3(dut):
    dut.i_inst.value = 0x023160B3  # rem x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_invalid == 1


@cocotb.test
async def invalid_test_4(dut):
    dut.i_inst.value = 0x023170B3  # remu x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_invalid == 1


@cocotb.test
async def invalid_test_5(dut):
    dut.i_inst.value = 0x023100B3  # mul x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_invalid == 1


@cocotb.test
async def invalid_test_6(dut):
    dut.i_inst.value = 0x023110B3  # mulh x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_invalid == 1


@cocotb.test
async def invalid_test_7(dut):
    dut.i_inst.value = 0x023130B3  # mulhu x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_invalid == 1


@cocotb.test
async def invalid_test_8(dut):
    dut.i_inst.value = 0x023120B3  # mulhsu x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_invalid == 1
