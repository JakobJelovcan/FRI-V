import cocotb
from cocotb.triggers import Timer


@cocotb.test
async def sysop_test_1(dut):
    dut.i_inst.value = 0x341110F3  # csrrw x1, mepc, x2
    await Timer(1, units="ns")
    assert dut.o_sysop == 0
    assert dut.o_csr_access == 3
    assert dut.o_invalid == 0


@cocotb.test
async def sysop_test_2(dut):
    dut.i_inst.value = 0x34111073  # csrrw x0, mepc, x2
    await Timer(1, units="ns")
    assert dut.o_sysop == 0
    assert dut.o_csr_access == 1
    assert dut.o_invalid == 0


@cocotb.test
async def sysop_test_3(dut):
    dut.i_inst.value = 0x34101073  # csrrw x0, mepc, x0
    await Timer(1, units="ns")
    assert dut.o_sysop == 0
    assert dut.o_csr_access == 1
    assert dut.o_invalid == 0


@cocotb.test
async def sysop_test_4(dut):
    dut.i_inst.value = 0x341A5073  # csrrwi x0, mepc, 20
    await Timer(1, units="ns")
    assert dut.o_sysop == 0
    assert dut.o_csr_access == 1
    assert dut.o_invalid == 0


@cocotb.test
async def sysop_test_5(dut):
    dut.i_inst.value = 0x341A50F3  # csrrwi x1, mepc, 20
    await Timer(1, units="ns")
    assert dut.o_sysop == 0
    assert dut.o_csr_access == 3
    assert dut.o_invalid == 0


@cocotb.test
async def sysop_test_6(dut):
    dut.i_inst.value = 0x341120F3  # csrrs x1, mepc, x2
    await Timer(1, units="ns")
    assert dut.o_sysop == 1
    assert dut.o_csr_access == 3
    assert dut.o_invalid == 0


@cocotb.test
async def sysop_test_7(dut):
    dut.i_inst.value = 0x34112073  # csrrs x0, mepc, x2
    await Timer(1, units="ns")
    assert dut.o_sysop == 1
    assert dut.o_csr_access == 3
    assert dut.o_invalid == 0


@cocotb.test
async def sysop_test_8(dut):
    dut.i_inst.value = 0x341020F3  # csrrs x1, mepc, x0
    await Timer(1, units="ns")
    assert dut.o_sysop == 1
    assert dut.o_csr_access == 2
    assert dut.o_invalid == 0


@cocotb.test
async def sysop_test_9(dut):
    dut.i_inst.value = 0x341060F3  # csrrsi x1, mepc, 0
    await Timer(1, units="ns")
    assert dut.o_sysop == 1
    assert dut.o_csr_access == 2
    assert dut.o_invalid == 0


@cocotb.test
async def sysop_test_10(dut):
    dut.i_inst.value = 0x341560F3  # csrrsi x1, mepc, 10
    await Timer(1, units="ns")
    assert dut.o_sysop == 1
    assert dut.o_csr_access == 3
    assert dut.o_invalid == 0


@cocotb.test
async def sysop_test_11(dut):
    dut.i_inst.value = 0x341130F3  # csrrc x1, mepc, x2
    await Timer(1, units="ns")
    assert dut.o_sysop == 2
    assert dut.o_csr_access == 3
    assert dut.o_invalid == 0


@cocotb.test
async def sysop_test_12(dut):
    dut.i_inst.value = 0x34113073  # csrrc x0, mepc, x2
    await Timer(1, units="ns")
    assert dut.o_sysop == 2
    assert dut.o_csr_access == 3
    assert dut.o_invalid == 0


@cocotb.test
async def sysop_test_13(dut):
    dut.i_inst.value = 0x341030F3  # csrrc x1, mepc, x0
    await Timer(1, units="ns")
    assert dut.o_sysop == 2
    assert dut.o_csr_access == 2
    assert dut.o_invalid == 0


@cocotb.test
async def sysop_test_14(dut):
    dut.i_inst.value = 0x341070F3  # csrrci x1, mepc, 0
    await Timer(1, units="ns")
    assert dut.o_sysop == 2
    assert dut.o_csr_access == 2
    assert dut.o_invalid == 0


@cocotb.test
async def sysop_test_15(dut):
    dut.i_inst.value = 0x341570F3  # csrrci x1, mepc, 10
    await Timer(1, units="ns")
    assert dut.o_sysop == 2
    assert dut.o_csr_access == 3
    assert dut.o_invalid == 0


@cocotb.test
async def sysop_test_16(dut):
    dut.i_inst.value = 0x00100073  # ebreak
    await Timer(1, units="ns")
    assert dut.o_sysop == 4
    assert dut.o_csr_access == 0
    assert dut.o_invalid == 0


@cocotb.test
async def sysop_test_17(dut):
    dut.i_inst.value = 0x00000073  # ecall
    await Timer(1, units="ns")
    assert dut.o_sysop == 5
    assert dut.o_csr_access == 0
    assert dut.o_invalid == 0


@cocotb.test
async def sysop_test_18(dut):
    dut.i_inst.value = 0x30200073  # mret
    await Timer(1, units="ns")
    assert dut.o_sysop == 3
    assert dut.o_csr_access == 0
    assert dut.o_invalid == 0


@cocotb.test
async def invalid_test_1(dut):
    dut.i_inst.value = 0x00000000  # invalid
    await Timer(1, units="ns")
    assert dut.o_invalid == 1


@cocotb.test
async def invalid_test_2(dut):
    dut.i_inst.value = 0x30200074  # invalid
    await Timer(1, units="ns")
    assert dut.o_invalid == 1


@cocotb.test
async def invalid_test_3(dut):
    dut.i_inst.value = 0x30300073  # invalid
    await Timer(1, units="ns")
    assert dut.o_invalid == 1


@cocotb.test
async def invalid_test_4(dut):
    dut.i_inst.value = 0x10000073  # invalid
    await Timer(1, units="ns")
    assert dut.o_invalid == 1


@cocotb.test
async def invalid_test_5(dut):
    dut.i_inst.value = 0x00200073  # invalid
    await Timer(1, units="ns")
    assert dut.o_invalid == 1


@cocotb.test
async def invalid_test_6(dut):
    dut.i_inst.value = 0x0140A103  # lw x2, 20(x1)
    await Timer(1, units="ns")
    assert dut.o_invalid == 1
