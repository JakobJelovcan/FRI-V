SIM ?= verilator
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES += $(PWD)/../../../srcs/rtl/priority_search_tree.sv
VERILOG_SOURCES += $(PWD)/priority_search_tree_wrapper.sv
COMPILE_ARGS += -GN=8 -GW=5

TOPLEVEL = priority_search_tree_wrapper

MODULE = tests

include $(shell cocotb-config --makefiles)/Makefile.sim