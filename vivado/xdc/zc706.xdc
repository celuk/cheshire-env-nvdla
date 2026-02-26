set_property SEVERITY Warning [get_drc_checks LUTLP-1]

set_property PACKAGE_PIN H9 [get_ports clk_p]
set_property IOSTANDARD LVDS [get_ports clk_p]
set_property PACKAGE_PIN G9 [get_ports clk_n]
set_property IOSTANDARD LVDS [get_ports clk_n]
#create_clock -period 5.000 -name clk_200mhz_p [get_ports clk_p]
create_clock -period 5.000 [get_ports clk_p]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets u_pll/inst/clk_in1_clk_wiz_0]

# PMOD1_5_LS
#set_property PACKAGE_PIN AA20 [get_ports uart_rx_i]
#set_property IOSTANDARD LVCMOS25 [get_ports uart_rx_i]

set_property PACKAGE_PIN AA20 [get_ports program_rx_i]
set_property IOSTANDARD LVCMOS25 [get_ports program_rx_i]

# PMOD1_4_LS
set_property PACKAGE_PIN Y20 [get_ports uart_tx_o]
set_property IOSTANDARD LVCMOS25 [get_ports uart_tx_o]

# GPIO_LED_0
set_property PACKAGE_PIN A17 [get_ports prog_mode_led_o]
set_property IOSTANDARD LVCMOS15 [get_ports prog_mode_led_o]

# GPIO_DIP_SW3
set_property PACKAGE_PIN AJ13 [get_ports rst_ni]
set_property IOSTANDARD LVCMOS25 [get_ports rst_ni]

## JTAG
set_property PACKAGE_PIN AA13 [get_ports jtag_tdo_o]
set_property IOSTANDARD LVCMOS25 [get_ports jtag_tdo_o]
set_property PACKAGE_PIN AK13 [get_ports jtag_tck_i]
set_property IOSTANDARD LVCMOS25 [get_ports jtag_tck_i]
set_property PACKAGE_PIN AK12 [get_ports jtag_tms_i]
set_property IOSTANDARD LVCMOS25 [get_ports jtag_tms_i]
set_property PACKAGE_PIN AH18 [get_ports jtag_tdi_i]
set_property IOSTANDARD LVCMOS25 [get_ports jtag_tdi_i]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_tck_i_IBUF]
