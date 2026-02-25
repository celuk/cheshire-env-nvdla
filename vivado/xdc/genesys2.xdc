#############
# Sys Clock #
#############

set SYS_TCK 5
create_clock -period $SYS_TCK -name sys_clk [get_ports sys_clk_p]

set SOC_TCK 20.0
set soc_clk [get_clocks -of_objects [get_pins i_clkwiz/clk_50]]

#################
# Clock routing #
#################

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -of [get_ports jtag_tck_i]]
set_property CLOCK_BUFFER_TYPE NONE [get_nets -of [get_ports jtag_tck_i]]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -of [get_ports sys_resetn]]
set_property CLOCK_BUFFER_TYPE NONE [get_nets -of [get_ports sys_resetn]]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets sys_resetn_IBUF]

set all_in_mux [get_nets -of [ get_pins -filter { DIRECTION == IN } -of \
    [get_cells -hier -filter { ORIG_REF_NAME == tc_clk_mux2 || REF_NAME == tc_clk_mux2 }]]]
set_property CLOCK_DEDICATED_ROUTE FALSE $all_in_mux
set_property CLOCK_BUFFER_TYPE NONE $all_in_mux

# Keep both sys_clk MMCM loads in top CMTs to avoid Place 30-575 without BACKBONE.
set_property LOC MMCME2_ADV_X1Y3 [get_cells i_clkwiz/inst/mmcm_adv_inst]
set_property LOC MMCME2_ADV_X1Y2 [get_cells i_dram_wrapper/i_dram/u_mig_7series_0_mig/u_iodelay_ctrl/clk_ref_mmcm_gen.mmcm_i]

########
# JTAG #
########

set JTAG_TCK 100.0
create_clock -period $JTAG_TCK -name clk_jtag [get_ports jtag_tck_i]
set_input_jitter clk_jtag 1.000
set_clock_groups -name jtag_async -asynchronous -group {clk_jtag}

set_input_delay -min -clock clk_jtag [expr { 0.10 * $JTAG_TCK }] [get_ports {jtag_tdi_i jtag_tms_i}]
set_input_delay -max -clock clk_jtag [expr { 0.20 * $JTAG_TCK }] [get_ports {jtag_tdi_i jtag_tms_i}]
set_output_delay -min -clock clk_jtag [expr { 0.10 * $JTAG_TCK }] [get_ports jtag_tdo_o]
set_output_delay -max -clock clk_jtag [expr { 0.20 * $JTAG_TCK }] [get_ports jtag_tdo_o]
set_max_delay -from [get_ports jtag_trst_ni] $JTAG_TCK
set_false_path -hold -from [get_ports jtag_trst_ni]

########
# UART #
########

set UART_IO_SPEED 200.0
set_max_delay [expr { $UART_IO_SPEED * 0.35 }] -from [get_ports uart_rx_i]
set_false_path -hold -from [get_ports uart_rx_i]
set_max_delay [expr { $UART_IO_SPEED * 0.35 }] -to [get_ports uart_tx_o]
set_false_path -hold -to [get_ports uart_tx_o]

########
# CDCs #
########

set_property KEEP_HIERARCHY SOFT [get_cells -hier \
    -filter {ORIG_REF_NAME=="sync" || REF_NAME=="sync"}]
set_false_path -hold -through [get_pins -of_objects [get_cells -hier \
    -filter {ORIG_REF_NAME=="sync" || REF_NAME=="sync"}] -filter {NAME=~*serial_i}]
set_false_path -hold -through [get_pins -of_objects [get_cells -hier \
    -filter {ORIG_REF_NAME == axi_cdc_src || REF_NAME == axi_cdc_src}] -filter {NAME =~ *async*}]
set_false_path -hold -through [get_pins -of_objects [get_cells -hier \
    -filter {ORIG_REF_NAME == axi_cdc_dst || REF_NAME == axi_cdc_dst}] -filter {NAME =~ *async*}]

#######
# MIG #
#######

set MIG_TCK 5
set MIG_RST_I [get_pin i_dram_wrapper/i_dram/aresetn]
set_false_path -hold -setup -through $MIG_RST_I
set MIG_RST_O [get_pins i_dram_wrapper/i_dram/ui_clk_sync_rst]
set_false_path -hold -through $MIG_RST_O
set_max_delay -through $MIG_RST_O $MIG_TCK
set_max_delay -datapath_only \
    -from [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*reg*/C] \
    -to [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*i_sync/reg*/D] $MIG_TCK
set_max_delay -datapath_only \
    -from [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*reg*/C] \
    -to [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/i_spill_register/spill_register_flushable_i/*reg*/D] $MIG_TCK

###############
# Assign Pins #
###############

set_property -dict { PACKAGE_PIN AD11  IOSTANDARD LVDS     } [get_ports { sys_clk_n }]
set_property -dict { PACKAGE_PIN AD12  IOSTANDARD LVDS     } [get_ports { sys_clk_p }]
set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [get_ports { sys_resetn }]

set_property -dict { PACKAGE_PIN Y23   IOSTANDARD LVCMOS33 } [get_ports { uart_tx_o }]
set_property -dict { PACKAGE_PIN Y20   IOSTANDARD LVCMOS33 } [get_ports { uart_rx_i }]

set_property -dict { PACKAGE_PIN T28   IOSTANDARD LVCMOS33 } [get_ports { prog_mode_led_o }]
set_property -dict { PACKAGE_PIN V19   IOSTANDARD LVCMOS33 } [get_ports { init_calib_done_o }]

set_property -dict { PACKAGE_PIN AD27  IOSTANDARD LVCMOS33 } [get_ports { jtag_tck_i }]
set_property -dict { PACKAGE_PIN W27   IOSTANDARD LVCMOS33 } [get_ports { jtag_tdi_i }]
set_property -dict { PACKAGE_PIN W28   IOSTANDARD LVCMOS33 } [get_ports { jtag_tdo_o }]
set_property -dict { PACKAGE_PIN W29   IOSTANDARD LVCMOS33 } [get_ports { jtag_tms_i }]
set_property -dict { PACKAGE_PIN Y29   IOSTANDARD LVCMOS33 } [get_ports { jtag_trst_ni }]
