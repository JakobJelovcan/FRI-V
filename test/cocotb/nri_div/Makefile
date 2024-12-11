SIM ?= verilator
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/types.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/nri_div_fsm.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/nri_div_corrections_unit.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/nri_div_row.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/nri_div.sv
COMPILE_ARGS += "-Wno-UNOPTFLAT"

TOPLEVEL = nri_div

MODULE = tests

include $(shell cocotb-config --makefiles)/Makefile.sim