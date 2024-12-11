SIM ?= verilator
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/types.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/carry_4.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/booth_fma.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/booth_decoder.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/booth_fma_fsm.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/booth_lut_a.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/booth_lut_b.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/booth_lut_c.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/booth_row.sv
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/booth_slice.sv

TOPLEVEL = booth_fma

MODULE = tests

include $(shell cocotb-config --makefiles)/Makefile.sim