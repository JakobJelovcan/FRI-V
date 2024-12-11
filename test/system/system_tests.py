import subprocess as sp
import pytest
import shutil


def run_test(file: str) -> int:
    shutil.copy(f"./bin/{file}", "../../srcs/rtl/rom.mem")
    vivado = sp.run(
        [
            "vivado",
            "-nolog",
            "-nojournal",
            "-mode",
            "batch",
            "-source",
            "./run_test.tcl",
        ],
        shell=True,
        capture_output=True,
        text=True,
    )
    return vivado.returncode


@pytest.mark.parametrize(
    "file, expected",
    [
        ("pass_test.mem", 0),
        ("fail_test.mem", 1),
        ("ubyte_access_test.mem", 0),
        ("sbyte_access_test.mem", 0),
        ("uhword_access_test.mem", 0),
        ("shword_access_test.mem", 0),
        ("bypass_test_1.mem", 0),
        ("bypass_test_2.mem", 0),
        ("bypass_test_3.mem", 0),
        ("bypass_test_4.mem", 0),
        ("bypass_test_5.mem", 0),
        ("ubyte_test.mem", 0),
        ("sbyte_test.mem", 0),
        ("uhword_test.mem", 0),
        ("shword_test.mem", 0),
        ("word_test.mem", 0),
        ("dot_test.mem", 0),
        ("fib_test.mem", 0),
        ("pi_test.mem", 0),
        ("qsort_test.mem", 0),
        ("det_test.mem", 0),
        ("malloc_test_0.mem", 0),
        ("malloc_test_1.mem", 0),
        ("malloc_test_2.mem", 0),
        ("timer_test_0.mem", 0),
        ("timer_test_1.mem", 0),
        ("uart_test.mem", 0),
        ("uart_freq_size_test.mem", 0),
        ("uart_int_test_0.mem", 0),
        ("uart_int_test_1.mem", 0),
        ("instruction_address_misaligned_test.mem", 2),
        ("instruction_access_fault_test.mem", 3),
        ("illegal_instruction_test.mem", 4),
        ("breakpoint_test.mem", 5),
        ("load_address_misaligned_test.mem", 6),
        ("load_access_fault_test.mem", 7),
        ("store_address_misaligned_test.mem", 8),
        ("store_access_fault_test.mem", 9),
        ("rom_access_fault_test.mem", 9),
        ("plic_access_fault_test.mem", 9),
        ("uart_access_fault_test.mem", 9),
        ("timer_access_fault_test.mem", 9),
        ("machine_system_call_test.mem", 10),
        ("software_interrupt_test.mem", 14),
        ("disabled_timer_interrupt_test.mem", 0),
        ("disabled_software_interrupt_test.mem", 0),
        ("disabled_external_interrupt_test.mem", 0),
        ("direct_timer_interrupt_test.mem", 13),
        ("direct_software_interrupt_test.mem", 12),
        ("direct_external_interrupt_test.mem", 11),
    ],
)
def test_system(file, expected):
    rc = run_test(file)

    assert rc == expected
