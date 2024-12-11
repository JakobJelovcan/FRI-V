SIM ?= verilator
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/types.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/wb_inst_cache.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/data_bram.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/control_bram.sv

TOPLEVEL = wb_inst_cache

MODULE = tests

include $(shell cocotb-config --makefiles)/Makefile.sim