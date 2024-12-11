open_project ../../Vivado/RISC-V.xpr
set_property top rv32_processor_tb [get_filesets sim_1]
set_property top_lib RISC [get_filesets sim_1]
set_param general.maxThreads 12
launch_simulation
remove_bps -all

run all
set simulation_status [get_value -radix unsigned /rv32_processor_tb/simulation_status]
exit $simulation_status