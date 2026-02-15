set_property SEVERITY Warning [get_drc_checks LUTLP-1]

set_property PACKAGE_PIN AD12 [get_ports clk_p]
set_property IOSTANDARD LVDS [get_ports clk_p]
set_property PACKAGE_PIN AD11 [get_ports clk_n]
set_property IOSTANDARD LVDS [get_ports clk_n]
create_clock -period 5.000 -name clk_200mhz_p [get_ports clk_p]

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

# SW0
set_property PACKAGE_PIN G19 [get_ports rst_ni]
set_property IOSTANDARD LVCMOS33 [get_ports rst_ni]

#set_property PACKAGE_PIN R19 [get_ports rst_ni]
#set_property IOSTANDARD LVCMOS33 [get_ports rst_ni]

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
# set_property -dict { PACKAGE_PIN Y29   IOSTANDARD LVCMOS33 } [get_ports { jtag_trst_ni }];
