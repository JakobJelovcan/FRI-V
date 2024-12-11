SIM ?= verilator
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/types.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/wb_data_cache.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/data_bram.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/control_bram.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/write_mask_unit.sv

TOPLEVEL = wb_data_cache

MODULE = tests

include $(shell cocotb-config --makefiles)/Makefile.sim