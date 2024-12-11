SIM ?= verilator
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/types.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/carry_4.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/arithmetic_unit.sv

TOPLEVEL = arithmetic_unit

MODULE = tests

include $(shell cocotb-config --makefiles)/Makefile.sim