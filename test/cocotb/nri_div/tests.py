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


async def divide(dut, n: int, d: int, op: int = 0):
    await rising_edge(dut)
    dut.i_data_n.value = n
    dut.i_data_d.value = d
    dut.i_divop.value = op
    dut.i_en.value = 1
    await rising_edge(dut)
    dut.i_en.value = 0
    await rising_edge(dut, 7)


@cocotb.test
async def nri_div_test_1(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 1, 1)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 1


@cocotb.test
async def nri_div_test_2(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 33, -7, 0)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0xFFFFFFFC


@cocotb.test
async def nri_div_test_3(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 2, -1, 0)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0xFFFFFFFE


@cocotb.test
async def nri_div_test_4(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 0xFFFFFFFF, 0xFFFFFFFF, 0)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x00000001


@cocotb.test
async def nri_div_test_5(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 5, 2, 0)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x00000002


@cocotb.test
async def nri_div_test_6(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 5, -2, 0)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0xFFFFFFFE


@cocotb.test
async def nri_div_test_7(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, -5, 2, 0)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0xFFFFFFFE


@cocotb.test
async def nri_div_test_8(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, -5, -2, 0)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x00000002


@cocotb.test
async def nri_div_test_9(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 615723, 71234, 0)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x00000008


@cocotb.test
async def nri_div_test_10(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 7689234, -12398, 0)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0xFFFFFD94


@cocotb.test
async def nri_div_test_11(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 2, 1, 1)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 2


@cocotb.test
async def nri_div_test_12(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 2, 2, 1)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 1


@cocotb.test
async def nri_div_test_13(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 15, 3, 1)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 5


@cocotb.test
async def nri_div_test_14(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 15, 4, 1)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 3


@cocotb.test
async def nri_div_test_15(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 0xFFFFFFFE, 4, 1)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x3FFFFFFF


@cocotb.test
async def nri_div_test_16(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 0xFFFFFFFE, 7, 1)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x24924924


@cocotb.test
async def nri_div_test_17(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 18727621, 679843, 1)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x0000001B


@cocotb.test
async def nri_div_test_18(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 678123, 81723687, 1)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x00000000


@cocotb.test
async def nri_div_test_19(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 0xFFFFFFFF, 0xFFFFFFFF, 1)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x00000001


@cocotb.test
async def nri_div_test_20(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 8673921, 1263781, 1)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x00000006


@cocotb.test
async def nri_div_test_21(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, -1, -1, 2)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0


@cocotb.test
async def nri_div_test_22(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, -1, -1, 2)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0


@cocotb.test
async def nri_div_test_23(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 1, -1, 2)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0


@cocotb.test
async def nri_div_test_24(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 1, 1, 2)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0


@cocotb.test
async def nri_div_test_25(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 17, 3, 2)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 2


@cocotb.test
async def nri_div_test_26(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 17, -3, 2)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x00000002


@cocotb.test
async def nri_div_test_27(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, -17, 3, 2)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0xFFFFFFFE


@cocotb.test
async def nri_div_test_28(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, -127638, 34578, 2)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0xFFFFA2A0


@cocotb.test
async def nri_div_test_29(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 17283, 7123, 2)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x00000BDD


@cocotb.test
async def nri_div_test_30(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, -125637, -7683, 2)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0xFFFFF56B


@cocotb.test
async def nri_div_test_31(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 8, 6, 3)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x00000002


@cocotb.test
async def nri_div_test_32(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 8, 8, 3)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x00000000


@cocotb.test
async def nri_div_test_33(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 0, 1, 3)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x00000000


@cocotb.test
async def nri_div_test_34(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 61723, 1234, 3)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x00000017


@cocotb.test
async def nri_div_test_35(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 0x00006712, 0xFFFFFFFF, 3)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x00006712


@cocotb.test
async def nri_div_test_36(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 0xFFFFFFFF, 0x00006712, 3)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x000030F3


@cocotb.test
async def nri_div_test_37(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 0xFFF00000, 0x000FFFFF, 3)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x00000FFF


@cocotb.test
async def nri_div_test_38(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 0x18263000, 0x71261273, 3)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x18263000


@cocotb.test
async def nri_div_test_39(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 0xFFFFFFFF, 0xFFFFFFFF, 3)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x00000000


@cocotb.test
async def nri_div_test_40(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 0x17282361, 0x00012312, 3)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x0000FDD7


@cocotb.test
async def nri_div_test_41(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 0xC0000000, 0x2, 0)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0xE0000000


@cocotb.test
async def nri_div_test_42(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 0x80000000, 0x2, 0)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0xC0000000


@cocotb.test
async def nri_div_test_42(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 0x80000000, 0xFFFFFFFE, 0)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x40000000


@cocotb.test
async def nri_div_by_zero_test_1(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 10, 0, 0)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0xFFFFFFFF


@cocotb.test
async def nri_div_by_zero_test_2(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 10, 0, 1)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0xFFFFFFFF


@cocotb.test
async def nri_div_by_zero_test_3(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 10, 0, 2)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 10


@cocotb.test
async def nri_div_by_zero_test_4(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 10, 0, 2)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 10


@cocotb.test
async def nri_div_by_zero_test_5(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, -10, 0, 0)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0xFFFFFFFF


@cocotb.test
async def nri_div_by_zero_test_6(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 0x80000000, 0, 1)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0xFFFFFFFF


@cocotb.test
async def nri_div_by_zero_test_7(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 0xFFFFFFF6, 0, 2)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0xFFFFFFF6


@cocotb.test
async def nri_div_by_zero_test_8(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 0x80000000, 0, 3)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x80000000


@cocotb.test
async def nri_overflow_test_1(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 0x80000000, 0xFFFFFFFF, 0)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0x80000000


@cocotb.test
async def nri_overflow_test_2(dut):
    await cocotb.start(clock_generator(dut))

    await divide(dut, 0x80000000, 0xFFFFFFFF, 2)

    assert dut.o_stall.value == 0
    assert dut.o_data.value == 0