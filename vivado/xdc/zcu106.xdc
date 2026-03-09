set_property SEVERITY Warning [get_drc_checks LUTLP-1]

#set_property PACKAGE_PIN H9 [get_ports clk_p]
#set_property IOSTANDARD LVDS [get_ports clk_p]
#set_property PACKAGE_PIN G9 [get_ports clk_n]
#set_property IOSTANDARD LVDS [get_ports clk_n]
#create_clock -period 8.000 [get_ports clk_p]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets u_pll/inst/clk_in1_clk_wiz_0]

#set_property PACKAGE_PIN AJ12        [get_ports "c0_sys_clk_n"] ;# Bank  66 VCCO - VCC1V2   - IO_L13N_T2L_N1_GC_QBC_66
#set_property IOSTANDARD  DIFF_SSTL12 [get_ports "c0_sys_clk_n"] ;# Bank  66 VCCO - VCC1V2   - IO_L13N_T2L_N1_GC_QBC_66
#set_property PACKAGE_PIN AH12        [get_ports "c0_sys_clk_p"] ;# Bank  66 VCCO - VCC1V2   - IO_L13P_T2L_N0_GC_QBC_66
#set_property IOSTANDARD  DIFF_SSTL12 [get_ports "c0_sys_clk_p"] ;# Bank  66 VCCO - VCC1V2   - IO_L13P_T2L_N0_GC_QBC_66

set_property PACKAGE_PIN AL17 [get_ports program_rx_i]
set_property IOSTANDARD LVCMOS12 [get_ports program_rx_i]

set_property PACKAGE_PIN AH17 [get_ports uart_tx_o]
set_property IOSTANDARD LVCMOS12 [get_ports uart_tx_o]

set_property PACKAGE_PIN AH17 [get_ports uart_tx_o]
set_property IOSTANDARD LVCMOS12 [get_ports uart_tx_o]

set_property PACKAGE_PIN AM15 [get_ports uart_rts_no]
set_property IOSTANDARD LVCMOS12 [get_ports uart_rts_no]

set_property PACKAGE_PIN AP17 [get_ports uart_cts_ni]
set_property IOSTANDARD LVCMOS12 [get_ports uart_cts_ni]

set_property PACKAGE_PIN AL11 [get_ports prog_mode_led_o]
set_property IOSTANDARD LVCMOS12 [get_ports prog_mode_led_o]

set_property PACKAGE_PIN A17 [get_ports rst_ni]
set_property IOSTANDARD LVCMOS18 [get_ports rst_ni]

## JTAG with PMOD headers
#set_property PACKAGE_PIN AN8      [get_ports "PMOD1_0_LS"] ;# Bank  66 VCCO - VCC1V2   - IO_L4N_T0U_N7_DBC_AD7N_66
#set_property IOSTANDARD  LVCMOS12 [get_ports "PMOD1_0_LS"] ;# Bank  66 VCCO - VCC1V2   - IO_L4N_T0U_N7_DBC_AD7N_66
#set_property PACKAGE_PIN AN9      [get_ports "PMOD1_1_LS"] ;# Bank  66 VCCO - VCC1V2   - IO_L4P_T0U_N6_DBC_AD7P_66
#set_property IOSTANDARD  LVCMOS12 [get_ports "PMOD1_1_LS"] ;# Bank  66 VCCO - VCC1V2   - IO_L4P_T0U_N6_DBC_AD7P_66
#set_property PACKAGE_PIN AP11     [get_ports "PMOD1_2_LS"] ;# Bank  66 VCCO - VCC1V2   - IO_L3N_T0L_N5_AD15N_66
#set_property IOSTANDARD  LVCMOS12 [get_ports "PMOD1_2_LS"] ;# Bank  66 VCCO - VCC1V2   - IO_L3N_T0L_N5_AD15N_66
#set_property PACKAGE_PIN AN11     [get_ports "PMOD1_3_LS"] ;# Bank  66 VCCO - VCC1V2   - IO_L3P_T0L_N4_AD15P_66
#set_property IOSTANDARD  LVCMOS12 [get_ports "PMOD1_3_LS"] ;# Bank  66 VCCO - VCC1V2   - IO_L3P_T0L_N4_AD15P_66
#set_property PACKAGE_PIN AP9      [get_ports "PMOD1_4_LS"] ;# Bank  66 VCCO - VCC1V2   - IO_L2N_T0L_N3_66
#set_property IOSTANDARD  LVCMOS12 [get_ports "PMOD1_4_LS"] ;# Bank  66 VCCO - VCC1V2   - IO_L2N_T0L_N3_66
#set_property PACKAGE_PIN AP10     [get_ports "PMOD1_5_LS"] ;# Bank  66 VCCO - VCC1V2   - IO_L2P_T0L_N2_66
#set_property IOSTANDARD  LVCMOS12 [get_ports "PMOD1_5_LS"] ;# Bank  66 VCCO - VCC1V2   - IO_L2P_T0L_N2_66
#set_property PACKAGE_PIN AP12     [get_ports "PMOD1_6_LS"] ;# Bank  66 VCCO - VCC1V2   - IO_L1N_T0L_N1_DBC_66
#set_property IOSTANDARD  LVCMOS12 [get_ports "PMOD1_6_LS"] ;# Bank  66 VCCO - VCC1V2   - IO_L1N_T0L_N1_DBC_66
# GENESYS2 pmod header equivalents in order: U27 (siyah), U28 (sari), T26 (turuncu), T27 (lacivert), T22 (gri), T23 (yesil), T20 (mor)
set_property PACKAGE_PIN AN8 [get_ports jtag_tdo_o]
set_property IOSTANDARD LVCMOS12 [get_ports jtag_tdo_o]
set_property PACKAGE_PIN AP9 [get_ports jtag_tck_i]
set_property IOSTANDARD LVCMOS12 [get_ports jtag_tck_i]
set_property PACKAGE_PIN AN9 [get_ports jtag_tms_i]
set_property IOSTANDARD LVCMOS12 [get_ports jtag_tms_i]
set_property PACKAGE_PIN AP10 [get_ports jtag_tdi_i]
set_property IOSTANDARD LVCMOS12 [get_ports jtag_tdi_i]
set_property PACKAGE_PIN AP11 [get_ports jtag_trst_ni]
set_property IOSTANDARD LVCMOS12 [get_ports jtag_trst_ni]
# devami AP12 (yesil), AN11 (mor)
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_tck_i_IBUF_inst/O]

## JTAG
# ZCU106 JTAG is just for PS side?? we need to drive from pmod headers?
#set_property PACKAGE_PIN G28 [get_ports jtag_tdo_o]
#set_property IOSTANDARD LVCMOS25 [get_ports jtag_tdo_o]
#set_property PACKAGE_PIN K27 [get_ports jtag_tck_i]
#set_property IOSTANDARD LVCMOS25 [get_ports jtag_tck_i]
#set_property PACKAGE_PIN H28 [get_ports jtag_tms_i]
#set_property IOSTANDARD LVCMOS25 [get_ports jtag_tms_i]
#set_property PACKAGE_PIN J27 [get_ports jtag_tdi_i]
#set_property IOSTANDARD LVCMOS25 [get_ports jtag_tdi_i]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_tck_i_IBUF]
