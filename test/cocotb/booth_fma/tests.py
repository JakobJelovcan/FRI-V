import cocotb
from cocotb.triggers import Timer, RisingEdge


async def rising_edge(dut, n: int = 1):
    for _ in range(n):
        await RisingEdge(dut.i_clk)
        await Timer(1, units="ps")


async def clock_generator(dut):
    while True:
        dut.i_clk.value = 1
        await Timer(5, units="ns")
        dut.i_clk.value = 0
        await Timer(5, units="ns")


async def multiply(dut, a: int, b: int, op: int = 0):
    dut.i_en.value = 1
    dut.i_mulop.value = op
    dut.i_data_a.value = a
    dut.i_data_b.value = b
    dut.i_data_c.value = 0

    await rising_edge(dut)
    dut.i_en.value = 0

    await rising_edge(dut, 3)


@cocotb.test
async def booth_fma_test_1(dut):
    # mul
    await cocotb.start(clock_generator(dut))
    await multiply(dut, 0, 0)

    assert dut.o_data.value == 0x00000000


@cocotb.test
async def booth_fma_test_2(dut):
    # mul
    await cocotb.start(clock_generator(dut))
    await multiply(dut, 1, 1)

    assert dut.o_data.value == 0x00000001


@cocotb.test
async def booth_fma_test_3(dut):
    # mul
    await cocotb.start(clock_generator(dut))
    await multiply(dut, -1, 1)

    assert dut.o_data.value == 0xFFFFFFFF


@cocotb.test
async def booth_fma_test_4(dut):
    # mul
    await cocotb.start(clock_generator(dut))
    await multiply(dut, 1, -1)

    assert dut.o_data.value == 0xFFFFFFFF


@cocotb.test
async def booth_fma_test_5(dut):
    # mul
    await cocotb.start(clock_generator(dut))
    await multiply(dut, -1, -1)

    assert dut.o_data.value == 0x00000001


@cocotb.test
async def booth_fma_test_6(dut):
    # mul
    await cocotb.start(clock_generator(dut))
    await multiply(dut, 255, 1023)

    assert dut.o_data.value == 0x0003FB01


@cocotb.test
async def booth_fma_test_7(dut):
    # mul
    await cocotb.start(clock_generator(dut))
    await multiply(dut, -1567, 12334)

    assert dut.o_data.value == 0xFED9166E


@cocotb.test
async def booth_fma_test_8(dut):
    # mul
    await cocotb.start(clock_generator(dut))
    await multiply(dut, -2, -2)

    assert dut.o_data.value == 0x00000004


@cocotb.test
async def booth_fma_test_9(dut):
    # mul
    await cocotb.start(clock_generator(dut))
    await multiply(dut, 2147483647, 2147483647)

    assert dut.o_data.value == 0x00000001


@cocotb.test
async def booth_fma_test_10(dut):
    # mul
    await cocotb.start(clock_generator(dut))
    await multiply(dut, -2147483648, -1)

    assert dut.o_data.value == 0x80000000


@cocotb.test
async def booth_fma_test_11(dut):
    # mulh
    await cocotb.start(clock_generator(dut))
    await multiply(dut, -2147483648, -1, 1)

    assert dut.o_data.value == 0x00000000


@cocotb.test
async def booth_fma_test_12(dut):
    # mulh
    await cocotb.start(clock_generator(dut))
    await multiply(dut, -1, -1, 1)

    assert dut.o_data.value == 0x00000000


@cocotb.test
async def booth_fma_test_13(dut):
    # mulh
    await cocotb.start(clock_generator(dut))
    await multiply(dut, 1, -1, 1)

    assert dut.o_data.value == 0xFFFFFFFF


@cocotb.test
async def booth_fma_test_14(dut):
    # mulh
    await cocotb.start(clock_generator(dut))
    await multiply(dut, 0x7FFFFFFF, 0x7FFFFFFF, 1)

    assert dut.o_data.value == 0x3FFFFFFF


@cocotb.test
async def booth_fma_test_15(dut):
    # mulh
    await cocotb.start(clock_generator(dut))
    await multiply(dut, -2, 1, 1)

    assert dut.o_data.value == 0xFFFFFFFF


@cocotb.test
async def booth_fma_test_16(dut):
    # mulhu
    await cocotb.start(clock_generator(dut))
    await multiply(dut, 0x7FFFFFFF, 0x7FFFFFFF, 2)

    assert dut.o_data.value == 0x3FFFFFFF


@cocotb.test
async def booth_fma_test_17(dut):
    # mulhu
    await cocotb.start(clock_generator(dut))
    await multiply(dut, 0xFFFFFFFF, 2, 2)

    assert dut.o_data.value == 0x00000001


@cocotb.test
async def booth_fma_test_18(dut):
    # mulhu
    await cocotb.start(clock_generator(dut))
    await multiply(dut, 0xFFFFFFFF, 0x7FFFFFFF, 2)

    assert dut.o_data.value == 0x7FFFFFFE


@cocotb.test
async def booth_fma_test_19(dut):
    # mulhu
    await cocotb.start(clock_generator(dut))
    await multiply(dut, 0xFFFFFFFF, 0x00000001, 2)

    assert dut.o_data.value == 0x00000000


@cocotb.test
async def booth_fma_test_20(dut):
    # mulhu
    await cocotb.start(clock_generator(dut))
    await multiply(dut, 0xFFFFFFFB, 0xFFFFFFFB, 2)

    assert dut.o_data.value == 0xFFFFFFF6


@cocotb.test
async def booth_fma_test_21(dut):
    # mulhsu
    await cocotb.start(clock_generator(dut))
    await multiply(dut, 0xFFFFFFFF, 0x00000002, 3)

    assert dut.o_data.value == 0xFFFFFFFF


@cocotb.test
async def booth_fma_test_22(dut):
    # mulhsu
    await cocotb.start(clock_generator(dut))
    await multiply(dut, 0x00000002, 0xFFFFFFFF, 3)

    assert dut.o_data.value == 0x00000001


@cocotb.test
async def booth_fma_test_23(dut):
    # mulhsu
    await cocotb.start(clock_generator(dut))
    await multiply(dut, 0xFFFFFFFF, 0xFFFFFFFF, 3)

    assert dut.o_data.value == 0xFFFFFFFF


@cocotb.test
async def booth_fma_test_24(dut):
    # mulhsu
    await cocotb.start(clock_generator(dut))
    await multiply(dut, 0x7FFFFFFF, 0xFFFFFFFF, 3)

    assert dut.o_data.value == 0x7FFFFFFE


@cocotb.test
async def booth_fma_test_25(dut):
    # mulhsu
    await cocotb.start(clock_generator(dut))
    await multiply(dut, 0x7FFFFFFF, 0x80000000, 3)

    assert dut.o_data.value == 0x3FFFFFFF