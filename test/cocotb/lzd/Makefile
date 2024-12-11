SIM ?= verilator
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/lzd.sv
VERILOG_SOURCES += $(PWD)/lzd_wrapper.sv
COMPILE_ARGS += -GN=8

TOPLEVEL = lzd_wrapper

MODULE = tests

include $(shell cocotb-config --makefiles)/Makefile.sim