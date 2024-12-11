SIM ?= verilator
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/types.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/constants.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/csr_addr_decoder.sv

TOPLEVEL = csr_addr_decoder

MODULE = tests

include $(shell cocotb-config --makefiles)/Makefile.sim