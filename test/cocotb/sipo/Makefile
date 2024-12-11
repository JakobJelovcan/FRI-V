SIM ?= verilator
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/sipo.sv
COMPILE_ARGS += -GN=8

TOPLEVEL = sipo

MODULE = tests

include $(shell cocotb-config --makefiles)/Makefile.sim