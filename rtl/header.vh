`define COMMON_CELLS_ASSERTS_OFF 1
`define ASSERTS_OFF 1
`define TARGET_SYNTHESIS

`define DRAM_SIM
//`define SIM
//`define GENESYS2
`define ZC706
`define ZC706_MIG

//`define ZCU106

`define CPU_CLK 50_000_000
`define BAUD_RATE 115200
`define DDR_MHZ 50

`define SV_TESTPOINTS_OFF 1
`define DESIGNWARE_NOEXIST 1
`define SYNTHESIS 1
`define FPGA 1
`define VLIB_BYPASS_POWER_CG 1
`define NV_FPGA_FIFOGEN 1
`define FIFOGEN_MASTER_CLK_GATING_DISABLED 1
//`define NV_FPGA_SYSTEM 1
//`define NV_FPGA_UNIT 1

`define JTAG

`define DDR3_SIM_INIT_CHIP0 "../../../cheshire/sw/tests/helloworld.mem_init_chip0.txt"
`define DDR3_SIM_INIT_CHIP1 "../../../cheshire/sw/tests/helloworld.mem_init_chip1.txt"
`define DDR3_SIM_INIT_CHIP2 "../../../cheshire/sw/tests/helloworld.mem_init_chip2.txt"
`define DDR3_SIM_INIT_CHIP3 "../../../cheshire/sw/tests/helloworld.mem_init_chip3.txt"
