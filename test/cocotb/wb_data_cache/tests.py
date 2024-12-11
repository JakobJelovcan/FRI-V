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
    dut.i_wb_data.value = 0x0000000
    dut.i_wb_ack.value = 0
    dut.i_wb_err.value = 0
    dut.i_en.value = 0
    dut.i_we.value = 0
    dut.i_addr.value = 0x00000000
    dut.i_data.value = 0x00000000
    dut.i_memop.value = 0

    dut.i_rst.value = 1
    await rising_edge(dut, 2)
    dut.i_rst.value = 0


async def cache_read(dut, addr: int = 0x00000000, memop: int = 3):
    dut.i_en.value = 1
    dut.i_we.value = 0
    dut.i_memop.value = memop
    dut.i_addr.value = addr
    dut.i_data.value = 0x00000000
    await rising_edge(dut)
    dut.i_en.value = 0


async def cache_verify_hit_read(
    dut, addr: int = 0x00000000, data: int = 0x00000000, memop: int = 3
):
    dut.i_en.value = 1
    dut.i_we.value = 0
    dut.i_memop.value = memop
    dut.i_addr.value = addr
    dut.i_data.value = 0x00000000
    await falling_edge(dut)
    assert dut.o_data.value == data
    assert dut.o_stall.value == 0
    await rising_edge(dut)
    dut.i_en.value = 0


async def cache_write(
    dut, addr: int = 0x00000000, data: int = 0x00000000, memop: int = 3
):
    dut.i_en.value = 1
    dut.i_we.value = 1
    dut.i_memop.value = memop
    dut.i_addr.value = addr
    dut.i_data.value = data
    await rising_edge(dut)
    dut.i_en.value = 0


async def wb_send_reply(dut, data: list):
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


async def wb_verify_read_error(dut, addr: list[int]):
    if len(addr) > 0:
        wb_verify_read(dut, addr[0])
        await rising_edge(dut, 2)

    for val in addr[1:-1]:
        wb_verify_read(dut, val)
        await rising_edge(dut)

    await rising_edge(dut)
    assert dut.i_wb_err.value == 1


def wb_verify_write(
    dut, addr: int = 0x00000000, data: int = 0x00000000, last: bool = False
):
    assert dut.o_wb_addr == addr
    assert dut.o_wb_data == data
    assert dut.o_wb_cyc == 1
    assert dut.o_wb_stb == 1
    assert dut.o_wb_we == 1
    assert dut.o_wb_cti == 7 if last else 2


async def wb_verify_writes(dut, addr: list[int], data: list[int]):
    wb_verify_write(dut, addr[0], data[0])
    await falling_edge(dut, 3)
    for a, d in zip(addr[1:-1], data[1:-1]):
        wb_verify_write(dut, a, d)
        await falling_edge(dut)

    wb_verify_write(dut, addr[-1], data[-1], True)


async def wb_verify_write_error(dut, addr: list[int], data: list[int]):
    if len(addr) > 0:
        wb_verify_write(dut, addr[0], data[0])
        await falling_edge(dut, 3)

    for a, d in zip(addr[1:-1], data[1:-1]):
        wb_verify_write(dut, a, d)
        await falling_edge(dut)

    dut.i_wb_data.value = 0x00000000
    dut.i_wb_ack.value = 0
    dut.i_wb_err.value = 1


@cocotb.test
async def cache_test_1(dut):
    """
    Tests reading from an empty cache
    """

    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    await cache_read(dut, 0x08000000)
    assert dut.o_stall == 1

    await rising_edge(dut)

    await cocotb.start(
        wb_send_reply(dut, [0x11111111, 0x22222222, 0x33333333, 0x44444444])
    )

    await wb_verify_reads(dut, [0x08000000, 0x08000004, 0x08000008, 0x0800000C])

    await rising_edge(dut)
    assert dut.o_stall == 0

    await falling_edge(dut)
    assert dut.o_data == 0x11111111

    await cache_verify_hit_read(dut, 0x08000004, 0x22222222)


@cocotb.test
async def cache_test_2(dut):
    """
    Tests writing to an empty cache
    """

    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    await cache_write(dut, 0x08000010, 0xAAAAAAAA)
    assert dut.o_stall == 1

    await rising_edge(dut)

    await cocotb.start(
        wb_send_reply(dut, [0x00000000, 0x00000000, 0x00000000, 0x00000000])
    )

    await wb_verify_reads(dut, [0x08000010, 0x08000014, 0x08000018, 0x0800001C])

    await rising_edge(dut)
    assert dut.o_stall == 0

    await rising_edge(dut)

    await cache_verify_hit_read(dut, 0x08000010, 0xAAAAAAAA)


@cocotb.test
async def cache_test_3(dut):
    """
    Tests reading from the Wishbone bus
    """

    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    await cache_read(dut, 0x10000000)
    assert dut.o_stall == 1

    await rising_edge(dut)
    wb_verify_read(dut, 0x10000000, True)

    await cocotb.start(wb_send_reply(dut, [0xAAAAAAAA]))

    await rising_edge(dut, 2)
    await falling_edge(dut)
    assert dut.o_stall == 0
    assert dut.o_data == 0xAAAAAAAA


@cocotb.test
async def cache_test_4(dut):
    """
    Tests writing to the Wishbone bus
    """

    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    await cache_write(dut, 0x10000000, 0xAAAAAAAA)
    assert dut.o_stall == 1

    await rising_edge(dut)
    wb_verify_write(dut, 0x10000000, 0xAAAAAAAA, True)

    await cocotb.start(wb_send_reply(dut, [0x00000000]))

    await rising_edge(dut, 2)
    await falling_edge(dut)
    assert dut.o_stall == 0


@cocotb.test
async def cache_test_5(dut):
    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    await cache_read(dut, 0x08000020)
    assert dut.o_stall == 1

    await rising_edge(dut)

    await cocotb.start(
        wb_send_reply(dut, [0x11111111, 0x22222222, 0x33333333, 0x44444444])
    )

    await wb_verify_reads(dut, [0x08000020, 0x08000024, 0x08000028, 0x0800002C])

    await rising_edge(dut)
    assert dut.o_stall == 0

    await falling_edge(dut)
    assert dut.o_data == 0x11111111

    await rising_edge(dut, 2)

    await cache_read(dut, 0x0C000020)
    assert dut.o_stall == 1

    await rising_edge(dut)

    await cocotb.start(
        wb_send_reply(dut, [0xAAAAAAAA, 0xBBBBBBBB, 0xCCCCCCCC, 0xDDDDDDDD])
    )

    await wb_verify_reads(dut, [0x0C000020, 0x0C000024, 0x0C000028, 0x0C00002C])

    await rising_edge(dut)
    assert dut.o_stall == 0

    await falling_edge(dut)
    assert dut.o_data == 0xAAAAAAAA


@cocotb.test
async def cache_test_6(dut):
    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    await cache_read(dut, 0x08000030)
    assert dut.o_stall == 1

    await rising_edge(dut)

    await cocotb.start(
        wb_send_reply(dut, [0x11111111, 0x22222222, 0x33333333, 0x44444444])
    )

    await wb_verify_reads(dut, [0x08000030, 0x08000034, 0x08000038, 0x0800003C])

    await rising_edge(dut)
    assert dut.o_stall == 0

    await falling_edge(dut)
    assert dut.o_data == 0x11111111

    await rising_edge(dut, 2)

    await cache_write(dut, 0x08000030, 0x12121212)
    assert dut.o_stall == 0

    await rising_edge(dut, 2)

    await cache_read(dut, 0x0C000030)
    assert dut.o_stall == 1

    await rising_edge(dut)

    await cocotb.start(
        wb_send_reply(dut, [0x00000000, 0x00000000, 0x00000000, 0x00000000])
    )

    await wb_verify_writes(
        dut,
        [0x08000030, 0x08000034, 0x08000038, 0x0800003C],
        [0x12121212, 0x22222222, 0x33333333, 0x44444444],
    )

    await rising_edge(dut, 2)

    await cocotb.start(
        wb_send_reply(dut, [0xAAAAAAAA, 0xBBBBBBBB, 0xCCCCCCCC, 0xDDDDDDDD])
    )

    await wb_verify_reads(dut, [0x0C000030, 0x0C000034, 0x0C000038, 0x0C00003C])

    await rising_edge(dut)
    assert dut.o_stall == 0

    await falling_edge(dut)
    assert dut.o_data == 0xAAAAAAAA


@cocotb.test
async def cache_test_7(dut):
    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    await cache_read(dut, 0x08000040)
    assert dut.o_stall.value == 1

    await rising_edge(dut)
    await wb_send_error(dut)
    await rising_edge(dut)
    assert dut.o_error.value == 8


@cocotb.test
async def cache_test_8(dut):
    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    await cache_read(dut, 0x0800004C)
    assert dut.o_stall.value == 1
    await rising_edge(dut)
    await cocotb.start(
        wb_send_reply(dut, [0x01234567, 0x89ABCDEF, 0x76543210, 0xFEDCBA89])
    )

    await wb_verify_reads(dut, [0x0800004C, 0x08000040, 0x08000044, 0x08000048])

    await rising_edge(dut)
    assert dut.o_stall.value == 0

    await falling_edge(dut)
    assert dut.o_data.value == 0x01234567

    await cache_write(dut, 0x08000048, 0x11122233)
    assert dut.o_stall.value == 0

    await cache_read(dut, 0x0C000044)
    assert dut.o_stall.value == 1

    await rising_edge(dut)
    await wb_send_error(dut)
    await rising_edge(dut)
    assert dut.o_error.value == 2


@cocotb.test
async def cache_test_9(dut):
    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    await cache_read(dut, 0x08000041)
    assert dut.o_error.value == 4


@cocotb.test
async def cache_test_10(dut):
    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    await cache_write(dut, 0x08000043, 0x00000000)
    assert dut.o_error.value == 1


@cocotb.test
async def cache_test_11(dut):
    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    await cache_read(dut, 0x08000084)

    assert dut.o_stall.value == 1

    await rising_edge(dut)

    await cocotb.start(
        wb_send_reply(dut, [0xAAAAAAAA, 0xBBBBBBBB, 0xCCCCCCCC, 0xDDDDDDDD])
    )

    await wb_verify_reads(dut, [0x08000084, 0x08000088, 0x0800008C, 0x08000080])

    await rising_edge(dut)
    assert dut.o_stall.value == 0

    await falling_edge(dut)
    assert dut.o_data.value == 0xAAAAAAAA

    await rising_edge(dut, 2)

    await cache_read(dut, 0x08004080)
    assert dut.o_stall.value == 1

    await rising_edge(dut)

    await cocotb.start(wb_send_error(dut, [0x01234567, 0x89ABCDEF]))

    await wb_verify_read_error(dut, [0x08004080, 0x08004084])

    await rising_edge(dut)
    assert dut.o_stall.value == 0

    await rising_edge(dut, 2)

    await cache_read(dut, 0x08004080)
    assert dut.o_stall.value == 1


@cocotb.test
async def cache_test_12(dut):
    await cocotb.start(clock_generator(dut))
    await reset_circut(dut)

    await cache_read(dut, 0x08000094)

    assert dut.o_stall.value == 1

    await rising_edge(dut)

    await cocotb.start(
        wb_send_reply(dut, [0xAAAAAAAA, 0xBBBBBBBB, 0xCCCCCCCC, 0xDDDDDDDD])
    )

    await wb_verify_reads(dut, [0x08000094, 0x08000098, 0x0800009C, 0x08000090])

    await rising_edge(dut)
    assert dut.o_stall.value == 0

    await falling_edge(dut)
    assert dut.o_data.value == 0xAAAAAAAA

    await cache_verify_hit_read(dut, 0x0800009C, 0xCCCCCCCC)
    await cache_write(dut, 0x08000098, 0x01234567)
    await cache_verify_hit_read(dut, 0x08000098, 0x01234567)

    await rising_edge(dut, 2)

    await cache_read(dut, 0x08004090)
    assert dut.o_stall.value == 1

    await rising_edge(dut)

    await cocotb.start(wb_send_error(dut, [0x00000000, 0x00000000]))

    await wb_verify_write_error(dut, [0x08000090, 0x08000094], [0xDDDDDDDD, 0xAAAAAAAA])

    await rising_edge(dut)
    assert dut.o_stall.value == 0

    await rising_edge(dut, 2)

    await cache_verify_hit_read(dut, 0x08000090, 0xDDDDDDDD)
