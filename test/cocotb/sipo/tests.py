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


async def reset_circut(dut):
    dut.i_data.value = 0
    dut.i_shift.value = 0
    dut.i_rst.value = 1
    await rising_edge(dut, 2)
    dut.i_rst.value = 0


@cocotb.test
async def sipo_test_1(dut):
    data = 0xFF

    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    for i in range(8):
        await rising_edge(dut)
        dut.i_shift.value = 1
        dut.i_data.value = (data >> i) & 1
        await rising_edge(dut)
        dut.i_shift.value = 0
        dut.i_data.value = 0

        await rising_edge(dut, 2)

    assert dut.o_data.value == data


@cocotb.test
async def sipo_test_2(dut):
    data = 0x0F

    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    for i in range(8):
        await rising_edge(dut)
        dut.i_shift.value = 1
        dut.i_data.value = (data >> i) & 1
        await rising_edge(dut)
        dut.i_shift.value = 0
        dut.i_data.value = 0

        await rising_edge(dut)

    assert dut.o_data.value == data


@cocotb.test
async def sipo_test_3(dut):
    data = 0xF0

    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    for i in range(8):
        await rising_edge(dut)
        dut.i_shift.value = 1
        dut.i_data.value = (data >> i) & 1
        await rising_edge(dut)
        dut.i_shift.value = 0
        dut.i_data.value = 0

        await rising_edge(dut, 4)

    assert dut.o_data.value == data


@cocotb.test
async def sipo_test_4(dut):
    data = 0xAA

    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    for i in range(8):
        await rising_edge(dut)
        dut.i_shift.value = 1
        dut.i_data.value = (data >> i) & 1
        await rising_edge(dut)
        dut.i_shift.value = 0
        dut.i_data.value = 0

        await rising_edge(dut)

    assert dut.o_data.value == data


@cocotb.test
async def sipo_test_5(dut):
    data = 0x00

    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    for i in range(8):
        await rising_edge(dut)
        dut.i_shift.value = 1
        dut.i_data.value = (data >> i) & 1
        await rising_edge(dut)
        dut.i_shift.value = 0
        dut.i_data.value = 0

        await rising_edge(dut, 3)

    assert dut.o_data.value == data


@cocotb.test
async def sipo_test_6(dut):
    data = 0xBA

    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    for i in range(8):
        await rising_edge(dut)
        dut.i_shift.value = 1
        dut.i_data.value = (data >> i) & 1
        await rising_edge(dut)
        dut.i_shift.value = 0
        dut.i_data.value = 0

    assert dut.o_data.value == data
