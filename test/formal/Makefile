PLATFORM := $(shell uname -m)

ifeq ($(PLATFORM), x86_64)
	sv2v := sv2v_x64
else ifeq ($(PLATFORM), aarch64)
	sv2v := sv2v_aarch64
else
	$(error Unsupported architecture)
endif

all: uart_clk_div sipo piso bypass_unit wb_crossbar wb_timer wb_rom wb_plic

uart_clk_div: init_dir
	@./$(sv2v) --define=FORMAL --exclude=Assert --write=rtl ../../srcs/rtl/types.sv ../../srcs/rtl/constants.sv ../../srcs/rtl/uart_clk_div.sv
	sby -f -t -j 16 uart_clk_div.sby prove 

bypass_unit: init_dir
	@./$(sv2v) --define=FORMAL --exclude=Assert --write=rtl ../../srcs/rtl/types.sv ../../srcs/rtl/lzd.sv ../../srcs/rtl/bypass_unit.sv
	sby -f -t -j 16 bypass_unit.sby prove

sipo: init_dir
	@./$(sv2v) --define=FORMAL --exclude=Assert --write=rtl ../../srcs/rtl/types.sv ../../srcs/rtl/constants.sv ../../srcs/rtl/sipo.sv
	sby -f -t -j 16 sipo.sby prove

piso: init_dir
	@./$(sv2v) --define=FORMAL --exclude=Assert --write=rtl ../../srcs/rtl/types.sv ../../srcs/rtl/constants.sv ../../srcs/rtl/piso.sv
	sby -f -t -j 16 piso.sby prove 

wb_crossbar: init_dir
	@./$(sv2v) --define=FORMAL --exclude=Assert --write=rtl ../../srcs/rtl/types.sv ../../srcs/rtl/constants.sv ../../srcs/rtl/wb_crossbar_addr_decoder.sv ../../srcs/rtl/wb_crossbar_master_index_decoder.sv ../../srcs/rtl/wb_crossbar_slave_index_decoder.sv ../../srcs/rtl/wb_crossbar.sv ../../srcs/rtl/wb_crossbar_arbitrer.sv ../../srcs/rtl/functions.sv
	sby -f -t -j 16 wb_crossbar.sby prove cover

wb_timer: init_dir
	@./$(sv2v) --define=FORMAL --exclude=Assert --write=rtl ../../srcs/rtl/wb_timer.sv ../../srcs/rtl/address_validation_unit.sv
	sby -f -t -j 16 wb_timer.sby prove cover

wb_rom: init_dir
	@./$(sv2v) --define=FORMAL --exclude=Assert --write=rtl ../../srcs/rtl/wb_rom.sv ../../srcs/rtl/bram_rom.sv
	sby -f -t -j 16 wb_rom.sby prove cover

wb_plic: init_dir
	@./$(sv2v) --define=FORMAL --exclude=Assert --write=rtl ../../srcs/rtl/wb_plic.sv ../../srcs/rtl/priority_search_tree.sv ../../srcs/rtl/address_validation_unit.sv
	sby -f -t -j 16 wb_plic.sby prove cover

init_dir:
	@mkdir -p rtl

clean:
	@rm -rf rtl/
