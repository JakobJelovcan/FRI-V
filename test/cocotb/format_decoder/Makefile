SIM ?= verilator
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/types.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/functions.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/format_decoder.sv

TOPLEVEL = format_decoder

MODULE = tests

include $(shell cocotb-config --makefiles)/Makefile.sim