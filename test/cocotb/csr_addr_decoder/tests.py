import cocotb
from cocotb.triggers import Timer


@cocotb.test
async def csr_addr_decoder_test_1(dut):
    dut.i_addr.value = 0x300
    await Timer(1, units="ps")
    assert dut.o_csr.value == 0
    assert dut.o_valid == 1


@cocotb.test
async def csr_addr_decoder_test_2(dut):
    dut.i_addr.value = 0x304
    await Timer(1, units="ps")
    assert dut.o_csr.value == 1
    assert dut.o_valid == 1


@cocotb.test
async def csr_addr_decoder_test_3(dut):
    dut.i_addr.value = 0x305
    await Timer(1, units="ps")
    assert dut.o_csr.value == 2
    assert dut.o_valid == 1


@cocotb.test
async def csr_addr_decoder_test_4(dut):
    dut.i_addr.value = 0x340
    await Timer(1, units="ps")
    assert dut.o_csr.value == 3
    assert dut.o_valid == 1


@cocotb.test
async def csr_addr_decoder_test_5(dut):
    dut.i_addr.value = 0x341
    await Timer(1, units="ps")
    assert dut.o_csr.value == 4
    assert dut.o_valid == 1


@cocotb.test
async def csr_addr_decoder_test_6(dut):
    dut.i_addr.value = 0x342
    await Timer(1, units="ps")
    assert dut.o_csr.value == 5
    assert dut.o_valid == 1


@cocotb.test
async def csr_addr_decoder_test_7(dut):
    dut.i_addr.value = 0x343
    await Timer(1, units="ps")
    assert dut.o_csr.value == 6
    assert dut.o_valid == 1


@cocotb.test
async def csr_addr_decoder_test_8(dut):
    dut.i_addr.value = 0x344
    await Timer(1, units="ps")
    assert dut.o_csr.value == 7
    assert dut.o_valid == 1


@cocotb.test
async def csr_addr_decoder_test_9(dut):
    dut.i_addr.value = 0x234
    await Timer(1, units="ps")
    assert dut.o_valid == 0


@cocotb.test
async def csr_addr_decoder_test_10(dut):
    dut.i_addr.value = 0x94
    await Timer(1, units="ps")
    assert dut.o_valid == 0


@cocotb.test
async def csr_addr_decoder_test_11(dut):
    dut.i_addr.value = 0x3A3
    await Timer(1, units="ps")
    assert dut.o_valid == 0


@cocotb.test
async def csr_addr_decoder_test_12(dut):
    dut.i_addr.value = 0xB00
    await Timer(1, units="ps")
    assert dut.o_valid == 0
