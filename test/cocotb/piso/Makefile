SIM ?= verilator
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/piso.sv
COMPILE_ARGS += -GN=8

TOPLEVEL = piso

MODULE = tests

include $(shell cocotb-config --makefiles)/Makefile.sim