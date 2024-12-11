import cocotb
from cocotb.triggers import Timer


@cocotb.test
async def arithop_test_1(dut):
    dut.i_inst.value = 0x003100B3  # add x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_aluop == 1


@cocotb.test
async def arithop_test_2(dut):
    dut.i_inst.value = 0x00A10093  # addi x1, x2, 10
    await Timer(1, units="ns")
    assert dut.o_aluop == 1


@cocotb.test
async def arithop_test_3(dut):
    dut.i_inst.value = 0xFF610093  # addi x1, x2, -10
    await Timer(1, units="ns")
    assert dut.o_aluop == 1


@cocotb.test
async def arithop_test_4(dut):
    dut.i_inst.value = 0x0141A083  # lw x1, 20(x3)
    await Timer(1, units="ns")
    assert dut.o_aluop == 1


@cocotb.test
async def arithop_test_5(dut):
    dut.i_inst.value = 0x02918103  # lb x2, 41(x3)
    await Timer(1, units="ns")
    assert dut.o_aluop == 1


@cocotb.test
async def arithop_test_6(dut):
    dut.i_inst.value = 0x0240A423  # sw x4, 40(x1)
    await Timer(1, units="ns")
    assert dut.o_aluop == 1


@cocotb.test
async def arithop_test_7(dut):
    dut.i_inst.value = 0x02408423  # sb x4, 40(x1)
    await Timer(1, units="ns")
    assert dut.o_aluop == 1


@cocotb.test
async def arithop_test_8(dut):
    dut.i_inst.value = 0x403100B3  # sub x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_aluop == 1


@cocotb.test
async def arithop_test_9(dut):
    dut.i_inst.value = 0x000C8117  # auipc x2, 200
    await Timer(1, units="ns")
    assert dut.o_aluop == 1


@cocotb.test
async def logicop_test_1(dut):
    dut.i_inst.value = 0x0041F133  # and x2, x3, x4
    await Timer(1, units="ns")
    assert dut.o_aluop == 2


@cocotb.test
async def logicop_test_2(dut):
    dut.i_inst.value = 0x0141F113  # andi x2, x3, 20
    await Timer(1, units="ns")
    assert dut.o_aluop == 2


@cocotb.test
async def logicop_test_3(dut):
    dut.i_inst.value = 0x0041E133  # or x2, x3, x4
    await Timer(1, units="ns")
    assert dut.o_aluop == 2


@cocotb.test
async def logicop_test_4(dut):
    dut.i_inst.value = 0x0141E113  # ori x2, x3, 20
    await Timer(1, units="ns")
    assert dut.o_aluop == 2


@cocotb.test
async def logicop_test_5(dut):
    dut.i_inst.value = 0x0041C133  # xor x2, x3, x4
    await Timer(1, units="ns")
    assert dut.o_aluop == 2


@cocotb.test
async def logicop_test_6(dut):
    dut.i_inst.value = 0x0141C113  # xori x2, x3, 20
    await Timer(1, units="ns")
    assert dut.o_aluop == 2


@cocotb.test
async def compop_test_1(dut):
    dut.i_inst.value = 0x003120B3  # slt x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_aluop == 3


@cocotb.test
async def compop_test_2(dut):
    dut.i_inst.value = 0x00A12093  # slti x1, x2, 10
    await Timer(1, units="ns")
    assert dut.o_aluop == 3


@cocotb.test
async def compop_test_3(dut):
    dut.i_inst.value = 0x003130B3  # sltu x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_aluop == 3


@cocotb.test
async def compop_test_4(dut):
    dut.i_inst.value = 0x00A13093  # sltiu x1, x2, 10
    await Timer(1, units="ns")
    assert dut.o_aluop == 3


@cocotb.test
async def compop_test_5(dut):
    dut.i_inst.value = 0x0C208463  # beq x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_aluop == 3


@cocotb.test
async def compop_test_6(dut):
    dut.i_inst.value = 0x0C209463  # bne x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_aluop == 3


@cocotb.test
async def compop_test_7(dut):
    dut.i_inst.value = 0x0C20C463  # blt x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_aluop == 3


@cocotb.test
async def compop_test_8(dut):
    dut.i_inst.value = 0x0C20D463  # bge x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_aluop == 3


@cocotb.test
async def compop_test_9(dut):
    dut.i_inst.value = 0x0C20E463  # blt x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_aluop == 3


@cocotb.test
async def compop_test_10(dut):
    dut.i_inst.value = 0x0C20F463  # bgeu x1, x2, 200
    await Timer(1, units="ns")
    assert dut.o_aluop == 3


@cocotb.test
async def mulop_test_1(dut):
    dut.i_inst.value = 0x023100B3  # mul x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_aluop == 4


@cocotb.test
async def mulop_test_2(dut):
    dut.i_inst.value = 0x023110B3  # mulh x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_aluop == 4


@cocotb.test
async def mulop_test_3(dut):
    dut.i_inst.value = 0x023130B3  # mulhu x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_aluop == 4


@cocotb.test
async def mulop_test_4(dut):
    dut.i_inst.value = 0x023120B3  # mulhsu x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_aluop == 4


@cocotb.test
async def divop_test_1(dut):
    dut.i_inst.value = 0x023140B3  # div x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_aluop == 5


@cocotb.test
async def divop_test_2(dut):
    dut.i_inst.value = 0x023150B3  # divu x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_aluop == 5


@cocotb.test
async def divop_test_3(dut):
    dut.i_inst.value = 0x023160B3  # rem x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_aluop == 5


@cocotb.test
async def divop_test_4(dut):
    dut.i_inst.value = 0x023170B3  # remu x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_aluop == 5


@cocotb.test
async def nop_test_1(dut):
    dut.i_inst.value = 0x0000000  # invalid
    await Timer(1, units="ns")
    assert dut.o_aluop == 0


@cocotb.test
async def nop_test_2(dut):
    dut.i_inst.value = 0x178204FF  # invalid
    await Timer(1, units="ns")
    assert dut.o_aluop == 0


@cocotb.test
async def nop_test_3(dut):
    dut.i_inst.value = 0x00100073  # ebreak
    await Timer(1, units="ns")
    assert dut.o_aluop == 0


@cocotb.test
async def nop_test_4(dut):
    dut.i_inst.value = 0x00000073  # ecall
    await Timer(1, units="ns")
    assert dut.o_aluop == 0


@cocotb.test
async def nop_test_5(dut):
    dut.i_inst.value = 0x341190F3  # csrrw x1, mepc, x3
    await Timer(1, units="ns")
    assert dut.o_aluop == 0


@cocotb.test
async def nop_test_6(dut):
    dut.i_inst.value = 0x3411A0F3  # csrrs x1, mepc, x3
    await Timer(1, units="ns")
    assert dut.o_aluop == 0


@cocotb.test
async def nop_test_7(dut):
    dut.i_inst.value = 0x341570F3  # csrrci x1, mepc, 10
    await Timer(1, units="ns")
    assert dut.o_aluop == 0
