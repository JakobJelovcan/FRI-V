import cocotb
from cocotb.triggers import Timer


@cocotb.test
async def comparison_test_1(dut):
    dut.i_flags.value = 0b0000

    dut.i_compop.value = 0
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 1
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 2
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 3
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 4
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 5
    await Timer(1, units="ns")
    assert dut.o_data == 0


@cocotb.test
async def comparison_test_2(dut):
    dut.i_flags.value = 0b0001

    dut.i_compop.value = 0
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 1
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 2
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 3
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 4
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 5
    await Timer(1, units="ns")
    assert dut.o_data == 0


@cocotb.test
async def comparison_test_3(dut):
    dut.i_flags.value = 0b0010

    dut.i_compop.value = 0
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 1
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 2
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 3
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 4
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 5
    await Timer(1, units="ns")
    assert dut.o_data == 0


@cocotb.test
async def comparison_test_4(dut):
    dut.i_flags.value = 0b0011

    dut.i_compop.value = 0
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 1
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 2
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 3
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 4
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 5
    await Timer(1, units="ns")
    assert dut.o_data == 0


@cocotb.test
async def comparison_test_5(dut):
    dut.i_flags.value = 0b0100

    dut.i_compop.value = 0
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 1
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 2
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 3
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 4
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 5
    await Timer(1, units="ns")
    assert dut.o_data == 1


@cocotb.test
async def comparison_test_6(dut):
    dut.i_flags.value = 0b0101

    dut.i_compop.value = 0
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 1
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 2
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 3
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 4
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 5
    await Timer(1, units="ns")
    assert dut.o_data == 1


@cocotb.test
async def comparison_test_7(dut):
    dut.i_flags.value = 0b0110

    dut.i_compop.value = 0
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 1
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 2
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 3
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 4
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 5
    await Timer(1, units="ns")
    assert dut.o_data == 1


@cocotb.test
async def comparison_test_8(dut):
    dut.i_flags.value = 0b0111

    dut.i_compop.value = 0
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 1
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 2
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 3
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 4
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 5
    await Timer(1, units="ns")
    assert dut.o_data == 1


@cocotb.test
async def comparison_test_9(dut):
    dut.i_flags.value = 0b1000

    dut.i_compop.value = 0
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 1
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 2
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 3
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 4
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 5
    await Timer(1, units="ns")
    assert dut.o_data == 0


@cocotb.test
async def comparison_test_10(dut):
    dut.i_flags.value = 0b1001

    dut.i_compop.value = 0
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 1
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 2
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 3
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 4
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 5
    await Timer(1, units="ns")
    assert dut.o_data == 0


@cocotb.test
async def comparison_test_11(dut):
    dut.i_flags.value = 0b1010

    dut.i_compop.value = 0
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 1
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 2
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 3
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 4
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 5
    await Timer(1, units="ns")
    assert dut.o_data == 0


@cocotb.test
async def comparison_test_12(dut):
    dut.i_flags.value = 0b1011

    dut.i_compop.value = 0
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 1
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 2
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 3
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 4
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 5
    await Timer(1, units="ns")
    assert dut.o_data == 0


@cocotb.test
async def comparison_test_13(dut):
    dut.i_flags.value = 0b1100

    dut.i_compop.value = 0
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 1
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 2
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 3
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 4
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 5
    await Timer(1, units="ns")
    assert dut.o_data == 1


@cocotb.test
async def comparison_test_14(dut):
    dut.i_flags.value = 0b1101

    dut.i_compop.value = 0
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 1
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 2
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 3
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 4
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 5
    await Timer(1, units="ns")
    assert dut.o_data == 1


@cocotb.test
async def comparison_test_15(dut):
    dut.i_flags.value = 0b1110

    dut.i_compop.value = 0
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 1
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 2
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 3
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 4
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 5
    await Timer(1, units="ns")
    assert dut.o_data == 1


@cocotb.test
async def comparison_test_16(dut):
    dut.i_flags.value = 0b1111

    dut.i_compop.value = 0
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 1
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 2
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 3
    await Timer(1, units="ns")
    assert dut.o_data == 0

    dut.i_compop.value = 4
    await Timer(1, units="ns")
    assert dut.o_data == 1

    dut.i_compop.value = 5
    await Timer(1, units="ns")
    assert dut.o_data == 1
