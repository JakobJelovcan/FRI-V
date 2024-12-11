import cocotb
from cocotb.triggers import Timer


@cocotb.test
async def logicop_test_1(dut):
    dut.i_inst.value = 0x003170B3  # and x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_logicop == 0
    assert dut.o_invalid == 0


@cocotb.test
async def logicop_test_2(dut):
    dut.i_inst.value = 0x01417093  # andi x1, x2, 20
    await Timer(1, units="ns")
    assert dut.o_logicop == 0
    assert dut.o_invalid == 0


@cocotb.test
async def logicop_test_3(dut):
    dut.i_inst.value = 0x003160B3  # or x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_logicop == 1
    assert dut.o_invalid == 0


@cocotb.test
async def logicop_test_4(dut):
    dut.i_inst.value = 0x01416093  # ori x1, x2, 20
    await Timer(1, units="ns")
    assert dut.o_logicop == 1
    assert dut.o_invalid == 0


@cocotb.test
async def logicop_test_5(dut):
    dut.i_inst.value = 0x003140B3  # xor x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_logicop == 2
    assert dut.o_invalid == 0


@cocotb.test
async def logicop_test_6(dut):
    dut.i_inst.value = 0x01414093  # xori x1, x2, 20
    await Timer(1, units="ns")
    assert dut.o_logicop == 2
    assert dut.o_invalid == 0


@cocotb.test
async def logicop_test_7(dut):
    dut.i_inst.value = 0x003110B3  # sll x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_logicop == 3
    assert dut.o_invalid == 0


@cocotb.test
async def logicop_test_8(dut):
    dut.i_inst.value = 0x01411093  # slli x1, x2, 20
    await Timer(1, units="ns")
    assert dut.o_logicop == 3
    assert dut.o_invalid == 0


@cocotb.test
async def logicop_test_9(dut):
    dut.i_inst.value = 0x003150B3  # srl x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_logicop == 4
    assert dut.o_invalid == 0


@cocotb.test
async def logicop_test_10(dut):
    dut.i_inst.value = 0x01415093  # srli x1, x2, 20
    await Timer(1, units="ns")
    assert dut.o_logicop == 4
    assert dut.o_invalid == 0


@cocotb.test
async def logicop_test_11(dut):
    dut.i_inst.value = 0x403150B3  # sra x1, x2, x3
    await Timer(1, units="ns")
    assert dut.o_logicop == 5
    assert dut.o_invalid == 0


@cocotb.test
async def logicop_test_12(dut):
    dut.i_inst.value = 0x41415093  # srai x1, x2, 20
    await Timer(1, units="ns")
    assert dut.o_logicop == 5
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
