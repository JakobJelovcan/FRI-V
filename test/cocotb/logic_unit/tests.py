import cocotb
from cocotb.triggers import Timer


@cocotb.test
async def logic_test_1(dut):
    dut.i_data_a.value = 0x00000000
    dut.i_data_a.value = 0x00000000
    dut.i_logicop.value = 0
    await Timer(1, units="ns")
    assert dut.o_data == 0x00000000

    dut.i_data_a.value = 0xFFFFFFFF
    await Timer(1, units="ns")
    assert dut.o_data == 0x00000000

    dut.i_data_b.value = 0xAAAAAAAA
    await Timer(1, units="ns")
    assert dut.o_data == 0xAAAAAAAA

    dut.i_data_a.value = 0x55555555
    await Timer(1, units="ns")
    assert dut.o_data == 0x00000000

    dut.i_data_a.value = 0x00000001
    dut.i_data_b.value = 0x00000001
    await Timer(1, units="ns")
    assert dut.o_data == 0x00000001


@cocotb.test
async def logic_test_2(dut):
    dut.i_data_a.value = 0x00000000
    dut.i_data_b.value = 0x00000000
    dut.i_logicop.value = 1
    await Timer(1, units="ns")
    assert dut.o_data == 0x00000000

    dut.i_data_a.value = 0xFFFFFFFF
    await Timer(1, units="ns")
    assert dut.o_data == 0xFFFFFFFF

    dut.i_data_a.value = 0xAAAAAAAA
    dut.i_data_b.value = 0x55555555
    await Timer(1, units="ns")
    assert dut.o_data == 0xFFFFFFFF

    dut.i_data_a.value = 0x0000FFFF
    await Timer(1, units="ns")
    assert dut.o_data == 0x5555FFFF


@cocotb.test
async def logic_test_3(dut):
    dut.i_data_a.value = 0x00000000
    dut.i_data_b.value = 0x00000000
    dut.i_logicop.value = 2
    await Timer(1, units="ns")
    assert dut.o_data == 0x00000000

    dut.i_data_a.value = 0xFFFFFFFF
    await Timer(1, units="ns")
    assert dut.o_data == 0xFFFFFFFF

    dut.i_data_b.value = 0xFFFFFFFF
    await Timer(1, units="ns")
    assert dut.o_data == 0x00000000

    dut.i_data_a.value = 0xAAAAAAAA
    dut.i_data_b.value = 0x55555555
    await Timer(1, units="ns")
    assert dut.o_data == 0xFFFFFFFF

    dut.i_data_b.value = 0x0000FFFF
    await Timer(1, units="ns")
    assert dut.o_data == 0xAAAA5555


@cocotb.test
async def logic_test_4(dut):
    dut.i_data_a.value = 0x00000001
    dut.i_data_b.value = 0x00000001
    dut.i_logicop.value = 3
    await Timer(1, units="ns")
    assert dut.o_data == 0x00000002

    dut.i_data_b.value = 0x00000000
    await Timer(1, units="ns")
    assert dut.o_data == 0x00000001

    dut.i_data_b.value = 0x0000001F
    await Timer(1, units="ns")
    assert dut.o_data == 0x80000000

    dut.i_data_a.value = 0xFFFFFFFF
    await Timer(1, units="ns")
    assert dut.o_data == 0x80000000

    dut.i_data_b.value = 0x00000010
    await Timer(1, units="ns")
    assert dut.o_data == 0xFFFF0000

@cocotb.test
async def logic_test_5(dut):
    dut.i_data_a.value = 0x00000001
    dut.i_data_b.value = 0x00000001
    dut.i_logicop.value = 4
    await Timer(1, units="ns")
    assert dut.o_data == 0x00000000

    dut.i_data_b.value = 0x00000000
    await Timer(1, units="ns")
    assert dut.o_data == 0x00000001

    dut.i_data_a.value = 0x80000000
    dut.i_data_b.value = 0x0000001f
    await Timer(1, units="ns")
    assert dut.o_data == 0x00000001

    dut.i_data_a.value = 0xffffffff
    dut.i_data_b.value = 0x00000010
    await Timer(1, units="ns")
    assert dut.o_data == 0x0000ffff

@cocotb.test
async def logic_test_6(dut):
    dut.i_data_a.value = 0xffffffff
    dut.i_data_b.value = 0x00000001
    dut.i_logicop.value = 5
    await Timer(1, units="ns")
    assert dut.o_data == 0xffffffff

    dut.i_data_a.value = 0x00000001
    dut.i_data_b.value = 0x00000000
    await Timer(1, units="ns")
    assert dut.o_data == 0x00000001

    dut.i_data_a.value = 0x80000000
    dut.i_data_b.value = 0x00000001
    await Timer(1, units="ns")
    assert dut.o_data == 0xc0000000

    dut.i_data_b.value = 0x0000001f
    await Timer(1, units="ns")
    assert dut.o_data == 0xffffffff

    dut.i_data_a.value = 0x7fffffff
    dut.i_data_b.value = 0x00000001
    await Timer(1, units="ns")
    assert dut.o_data == 0x3fffffff


