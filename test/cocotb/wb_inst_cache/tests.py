import cocotb
from cocotb.triggers import Timer, FallingEdge, RisingEdge
import cocotb.utils


async def rising_edge(dut, n: int = 1):
    for _ in range(n):
        await RisingEdge(dut.i_clk)
        await Timer(1, units="ps")


async def falling_edge(dut, n: int = 1):
    for _ in range(n):
        await FallingEdge(dut.i_clk)
        await Timer(1, units="ps")


async def clock_generator(dut):
    while True:
        dut.i_clk.value = 1
        await Timer(5, units="ns")
        dut.i_clk.value = 0
        await Timer(5, units="ns")


async def reset_circut(dut):
    dut.i_wb_ack.value = 0
    dut.i_wb_err.value = 0
    dut.i_en.value = 0
    dut.i_addr.value = 0x00000000

    dut.i_rst.value = 1
    await rising_edge(dut, 2)
    dut.i_rst.value = 0


async def cache_read(dut, addr: int = 0x00000000):
    dut.i_en.value = 1
    dut.i_addr.value = addr
    await rising_edge(dut)
    dut.i_en.value = 0


async def cache_verify_hit_read(dut, addr: int = 0x00000000, data: int = 0x00000000):
    dut.i_en.value = 1
    dut.i_addr.value = addr
    await falling_edge(dut)
    assert dut.o_data.value == data
    assert dut.o_stall.value == 0
    await rising_edge(dut)
    dut.i_en.value = 0


async def wb_send_reply(dut, data: list[int]):
    for val in data:
        await RisingEdge(dut.i_clk)
        dut.i_wb_data.value = val
        dut.i_wb_ack.value = 1
        dut.i_wb_err.value = 0

    await RisingEdge(dut.i_clk)
    dut.i_wb_data.value = 0x00000000
    dut.i_wb_ack.value = 0
    dut.i_wb_err.value = 0


async def wb_send_error(dut, data: list[int] = []):
    for val in data:
        await RisingEdge(dut.i_clk)
        dut.i_wb_data.value = val
        dut.i_wb_ack.value = 1
        dut.i_wb_err.value = 0

    await RisingEdge(dut.i_clk)
    dut.i_wb_data.value = 0x00000000
    dut.i_wb_ack.value = 0
    dut.i_wb_err.value = 1


def wb_verify_read(dut, addr: int = 0x00000000, last: bool = False):
    assert dut.o_wb_addr == addr
    assert dut.o_wb_cyc == 1
    assert dut.o_wb_stb == 1
    assert dut.o_wb_we == 0
    assert dut.o_wb_cti == 7 if last else 2


async def wb_verify_reads(dut, addr: list[int]):
    wb_verify_read(dut, addr[0])
    await rising_edge(dut, 2)
    for val in addr[1:-1]:
        wb_verify_read(dut, val)
        await rising_edge(dut)

    wb_verify_read(dut, addr[-1], True)


async def wb_verify_error(dut, addr: list[int]):
    if len(addr) > 0:
        wb_verify_read(dut, addr[0])
        await rising_edge(dut, 2)

    for val in addr[1:-1]:
        wb_verify_read(dut, val)
        await rising_edge(dut)

    await rising_edge(dut)
    assert dut.i_wb_err.value == 1


@cocotb.test
async def cache_test_1(dut):
    """
    Tests reading from an empty cache
    """

    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    await cache_read(dut, 0x00000000)
    assert dut.o_stall == 1

    await rising_edge(dut)

    await cocotb.start(
        wb_send_reply(dut, [0x11111111, 0x22222222, 0x33333333, 0x44444444])
    )

    await wb_verify_reads(dut, [0x00000000, 0x00000004, 0x00000008, 0x0000000C])

    await rising_edge(dut)
    assert dut.o_stall == 0

    await falling_edge(dut)
    assert dut.o_data == 0x11111111

    await cache_verify_hit_read(dut, 0x00000004, 0x22222222)
    await cache_verify_hit_read(dut, 0x0000000C, 0x44444444)


@cocotb.test
async def cache_test_2(dut):
    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    await cache_read(dut, 0x00000020)
    assert dut.o_stall == 1

    await rising_edge(dut)

    await cocotb.start(
        wb_send_reply(dut, [0x11111111, 0x22222222, 0x33333333, 0x44444444])
    )

    await wb_verify_reads(dut, [0x00000020, 0x00000024, 0x00000028, 0x0000002C])

    await rising_edge(dut)
    assert dut.o_stall == 0

    await falling_edge(dut)
    assert dut.o_data == 0x11111111

    await cache_verify_hit_read(dut, 0x00000020, 0x11111111)
    await cache_verify_hit_read(dut, 0x0000002C, 0x44444444)
    await cache_verify_hit_read(dut, 0x00000028, 0x33333333)

    await rising_edge(dut, 2)

    await cache_read(dut, 0x00004020)
    assert dut.o_stall == 1

    await rising_edge(dut)

    await cocotb.start(
        wb_send_reply(dut, [0xAAAAAAAA, 0xBBBBBBBB, 0xCCCCCCCC, 0xDDDDDDDD])
    )

    await wb_verify_reads(dut, [0x00004020, 0x00004024, 0x00004028, 0x0000402C])

    await rising_edge(dut)
    assert dut.o_stall == 0

    await falling_edge(dut)
    assert dut.o_data == 0xAAAAAAAA


@cocotb.test
async def cache_test_3(dut):
    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    await cache_read(dut, 0x00000040)
    assert dut.o_stall.value == 1

    await rising_edge(dut)
    await wb_send_error(dut)
    await rising_edge(dut)
    assert dut.o_error.value == 2


@cocotb.test
async def cache_test_4(dut):
    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    await cache_read(dut, 0x00000041)
    assert dut.o_error.value == 1


@cocotb.test
async def cache_test_5(dut):
    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    await cache_read(dut, 0x00000084)

    assert dut.o_stall.value == 1

    await rising_edge(dut)

    await cocotb.start(
        wb_send_reply(dut, [0xAAAAAAAA, 0xBBBBBBBB, 0xCCCCCCCC, 0xDDDDDDDD])
    )

    await wb_verify_reads(dut, [0x00000084, 0x00000088, 0x0000008C, 0x00000080])

    await rising_edge(dut)
    assert dut.o_stall.value == 0

    await falling_edge(dut)
    assert dut.o_data.value == 0xAAAAAAAA

    await rising_edge(dut, 2)

    await cache_read(dut, 0x00004080)
    assert dut.o_stall.value == 1

    await rising_edge(dut)

    await cocotb.start(wb_send_error(dut, [0x01234567, 0x89ABCDEF]))

    await wb_verify_error(dut, [0x00004080, 0x00004084])

    await rising_edge(dut)
    assert dut.o_stall.value == 0

    await rising_edge(dut, 2)

    await cache_read(dut, 0x00004080)
    assert dut.o_stall.value == 1
