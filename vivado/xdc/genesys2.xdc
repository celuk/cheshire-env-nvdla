set_property SEVERITY Warning [get_drc_checks LUTLP-1]

set_property PACKAGE_PIN AD12 [get_ports clk_p]
set_property IOSTANDARD LVDS [get_ports clk_p]
set_property PACKAGE_PIN AD11 [get_ports clk_n]
set_property IOSTANDARD LVDS [get_ports clk_n]
create_clock -period 5.000 -name clk_200mhz_p [get_ports clk_p]
#set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets sys_clk]

# PMOD1_5_LS
#set_property PACKAGE_PIN Y20 [get_ports uart_rx_i]
#set_property IOSTANDARD LVCMOS33 [get_ports uart_rx_i]

set_property PACKAGE_PIN Y20 [get_ports program_rx_i]
set_property IOSTANDARD LVCMOS33 [get_ports program_rx_i]

# PMOD1_4_LS
set_property PACKAGE_PIN Y23 [get_ports uart_tx_o]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx_o]

# GPIO_LED_0
set_property PACKAGE_PIN T28 [get_ports prog_mode_led_o]
set_property IOSTANDARD LVCMOS33 [get_ports prog_mode_led_o]

set_property PACKAGE_PIN V19 [get_ports init_calib_done_o]
set_property IOSTANDARD LVCMOS33 [get_ports init_calib_done_o]

# SW0
#set_property PACKAGE_PIN G19 [get_ports rst_ni]
#set_property IOSTANDARD LVCMOS12 [get_ports rst_ni]

set_property PACKAGE_PIN R19 [get_ports rst_ni]
set_property IOSTANDARD LVCMOS33 [get_ports rst_ni]

## JTAG
set_property PACKAGE_PIN W28 [get_ports jtag_tdo_o]
set_property IOSTANDARD LVCMOS33 [get_ports jtag_tdo_o]
set_property PACKAGE_PIN AD27 [get_ports jtag_tck_i]
set_property IOSTANDARD LVCMOS33 [get_ports jtag_tck_i]
set_property PACKAGE_PIN W29 [get_ports jtag_tms_i]
set_property IOSTANDARD LVCMOS33 [get_ports jtag_tms_i]
set_property PACKAGE_PIN W27 [get_ports jtag_tdi_i]
set_property IOSTANDARD LVCMOS33 [get_ports jtag_tdi_i]
set_property PACKAGE_PIN Y29 [get_ports jtag_trst_ni]
set_property IOSTANDARD LVCMOS33 [get_ports jtag_trst_ni]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_tck_i_IBUF]
set_property CLOCK_BUFFER_TYPE NONE [get_nets -of [get_ports jtag_tck_i]]


set all_in_mux [get_nets -of [ get_pins -filter { DIRECTION == IN } -of \
    [get_cells -hier -filter { ORIG_REF_NAME == tc_clk_mux2 || REF_NAME == tc_clk_mux2 }]]]
set_property CLOCK_DEDICATED_ROUTE FALSE $all_in_mux
set_property CLOCK_BUFFER_TYPE NONE $all_in_mux

set SOC_TCK 20.0
set soc_clk [get_clocks -of_objects [get_pins u_pll/clk_out5]]


set JTAG_TCK 100.0
create_clock -period $JTAG_TCK -name clk_jtag [get_ports jtag_tck_i]
set_input_jitter clk_jtag 1.000

# JTAG Clock is asynchronous to all other clocks
set_clock_groups -name jtag_async -asynchronous -group {clk_jtag}

set_input_delay -min -clock clk_jtag [expr { 0.10 * $JTAG_TCK }] [get_ports {jtag_tdi_i jtag_tms_i}]
set_input_delay -max -clock clk_jtag [expr { 0.20 * $JTAG_TCK }] [get_ports {jtag_tdi_i jtag_tms_i}]

set_output_delay -min -clock clk_jtag [expr { 0.10 * $JTAG_TCK }] [get_ports jtag_tdo_o]
set_output_delay -max -clock clk_jtag [expr { 0.20 * $JTAG_TCK }] [get_ports jtag_tdo_o]

set_max_delay -from [get_ports jtag_trst_ni] $JTAG_TCK
set_false_path -hold -from [get_ports jtag_trst_ni]


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

# DRAM AXI clock : 200 MHz (defined by MIG constraints)
set MIG_TCK 5

# False-path incoming reset
set MIG_RST_I [get_pins dram_controller/u_mig_7series_0/aresetn]
set_false_path -hold -setup -through $MIG_RST_I

# Constrain outgoing reset
set MIG_RST_O [get_pins dram_controller/u_mig_7series_0/ui_clk_sync_rst]
set_false_path -hold -through $MIG_RST_O
set_max_delay -through $MIG_RST_O $MIG_TCK

# Limit delay across DRAM CDC (hold already false-pathed)
set_max_delay -datapath_only \
    -from [get_pins dram_controller/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*reg*/C] \
    -to [get_pins dram_controller/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*i_sync/reg*/D] $MIG_TCK
set_max_delay -datapath_only \
    -from [get_pins dram_controller/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*reg*/C] \
    -to [get_pins dram_controller/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/i_spill_register/spill_register_flushable_i/*reg*/D] $MIG_TCK
