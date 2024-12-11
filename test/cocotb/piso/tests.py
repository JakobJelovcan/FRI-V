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
    dut.i_we.value = 0
    dut.i_rst.value = 1
    await rising_edge(dut, 2)
    dut.i_rst.value = 0


@cocotb.test
async def piso_test_1(dut):
    data_i = 0xFF
    data_o = 0x00

    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    dut.i_we.value = 1
    dut.i_data.value = data_i

    await rising_edge(dut)

    dut.i_we.value = 0
    dut.i_data.value = 0

    for _ in range(8):
        data_o = data_o >> 1 | int(dut.o_data.value) << 7
        await rising_edge(dut, 2)
        dut.i_shift.value = 1
        await rising_edge(dut)
        dut.i_shift.value = 0

    assert data_o == data_i


@cocotb.test
async def piso_test_2(dut):
    data_i = 0xF0
    data_o = 0x00

    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    dut.i_we.value = 1
    dut.i_data.value = data_i

    await rising_edge(dut)

    dut.i_we.value = 0
    dut.i_data.value = 0

    for _ in range(8):
        data_o = data_o >> 1 | int(dut.o_data.value) << 7
        await rising_edge(dut)
        dut.i_shift.value = 1
        await rising_edge(dut)
        dut.i_shift.value = 0

    assert data_o == data_i


@cocotb.test
async def piso_test_3(dut):
    data_i = 0x0F
    data_o = 0x00

    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    dut.i_we.value = 1
    dut.i_data.value = data_i

    await rising_edge(dut)

    dut.i_we.value = 0
    dut.i_data.value = 0

    for _ in range(8):
        data_o = data_o >> 1 | int(dut.o_data.value) << 7
        await rising_edge(dut, 7)
        dut.i_shift.value = 1
        await rising_edge(dut)
        dut.i_shift.value = 0

    assert data_o == data_i


@cocotb.test
async def piso_test_4(dut):
    data_i = 0xAA
    data_o = 0x00

    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    dut.i_we.value = 1
    dut.i_data.value = data_i

    await rising_edge(dut)

    dut.i_we.value = 0
    dut.i_data.value = 0

    for _ in range(8):
        data_o = data_o >> 1 | int(dut.o_data.value) << 7
        await rising_edge(dut, 4)
        dut.i_shift.value = 1
        await rising_edge(dut)
        dut.i_shift.value = 0

    assert data_o == data_i


@cocotb.test
async def piso_test_5(dut):
    data_i = 0xAB
    data_o = 0x00

    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    dut.i_we.value = 1
    dut.i_data.value = data_i

    await rising_edge(dut)

    dut.i_we.value = 0
    dut.i_data.value = 0

    for _ in range(8):
        data_o = data_o >> 1 | int(dut.o_data.value) << 7
        await rising_edge(dut, 2)
        dut.i_shift.value = 1
        await rising_edge(dut)
        dut.i_shift.value = 0

    assert data_o == data_i
