`timescale 1ns / 1ps

`include "header.vh"

module dram_controller_wb (
   input wire clk_i,
   input wire rst_i,

   input  wire [63:0] wb_adr_i,
   input  wire [63:0] wb_dat_i,
   input  wire        wb_we_i ,
   input  wire        wb_stb_i,
   input  wire [7:0]  wb_sel_i,
   input  wire        wb_cyc_i,
   output        wb_ack_o,
   output [63:0] wb_dat_o

   ,output ddr3_reset_n
   ,output ddr3_cke
   ,output ddr3_ck_p
   ,output ddr3_ck_n
   ,output ddr3_cs_n
   ,output ddr3_ras_n
   ,output ddr3_cas_n
   ,output ddr3_we_n
   ,output [2:0] ddr3_ba
    `ifdef DDR_32X
    ,output [14:0] ddr3_addr
    ,output ddr3_odt
    ,output [3:0] ddr3_dm
    ,inout [3:0] ddr3_dqs_p
    ,inout [3:0] ddr3_dqs_n
    ,inout [31:0] ddr3_dq
    `else
   ,output [13:0] ddr3_addr
   ,output ddr3_odt
   ,output [1:0] ddr3_dm
   ,inout [1:0] ddr3_dqs_p
   ,inout [1:0] ddr3_dqs_n
   ,inout [15:0] ddr3_dq
    `endif

   ,input clk100
   ,input clk_ddr
   ,input clk_ref
   ,input clk_ddr_dqs

   ,input wire uart_dram_write_we_i,
   input wire [31:0] uart_dram_write_addr_i,
   input wire [31:0] uart_dram_write_data_i,
   input wire uart_dram_write_rst_i
);

    reg [63:0] wb_read_data_r;
    reg [63:0] wb_read_data_next_r;
    assign wb_dat_o = wb_read_data_r;

    reg wb_ack_r;
    reg wb_ack_next_r;
    assign wb_ack_o = wb_ack_r;

    reg [63:0] DRAM_ADDRESS;
    reg [63:0] DRAM_ADDRESS_NEXT;
    reg [31:0] DRAM_DATA_WRITE0;
    reg [31:0] DRAM_DATA_WRITE0_NEXT;
    reg [31:0] DRAM_DATA_WRITE1;
    reg [31:0] DRAM_DATA_WRITE1_NEXT;
    reg [31:0] DRAM_DATA_WRITE2;
    reg [31:0] DRAM_DATA_WRITE2_NEXT;
    reg [31:0] DRAM_DATA_WRITE3;
    reg [31:0] DRAM_DATA_WRITE3_NEXT;
    `ifdef DDR_32X
    reg [31:0] DRAM_DATA_WRITE0_H;
    reg [31:0] DRAM_DATA_WRITE0_H_NEXT;
    reg [31:0] DRAM_DATA_WRITE1_H;
    reg [31:0] DRAM_DATA_WRITE1_H_NEXT;
    reg [31:0] DRAM_DATA_WRITE2_H;
    reg [31:0] DRAM_DATA_WRITE2_H_NEXT;
    reg [31:0] DRAM_DATA_WRITE3_H;
    reg [31:0] DRAM_DATA_WRITE3_H_NEXT;
    `endif
    reg DRAM_RE;
    reg DRAM_RE_NEXT;
    reg DRAM_WE;
    reg DRAM_WE_NEXT;
    reg [31:0] DRAM_WDG;
    reg [31:0] DRAM_WDG_NEXT;

    typedef enum logic [4:0] {
        IDLE,
        READ_START,
        READ_WAIT_ACCEPT,
        READ_WAIT_ACK,
        WRITE_RMW_START,
        WRITE_RMW_WAIT_ACCEPT,
        WRITE_RMW_WAIT_ACK,
        WRITE_START,
        WRITE_WAIT_ACCEPT,
        WRITE_WAIT_ACK,
        UART_WRITE_RMW_START,
        UART_WRITE_RMW_WAIT_ACCEPT,
        UART_WRITE_RMW_WAIT_ACK,
        UART_WRITE_START,
        UART_WRITE_WAIT_ACCEPT,
        UART_WRITE_WAIT_ACK
    } state_t;

    state_t state_r, state_next_r;

    reg [63:0] wb_adr_r, wb_adr_next_r;
    reg [63:0] wb_dat_r, wb_dat_next_r;
    reg [7:0]  wb_sel_r, wb_sel_next_r;

    reg [31:0] uart_adr_r, uart_adr_next_r;
    reg [31:0] uart_dat_r, uart_dat_next_r;

    `ifdef DDR_32X
    logic [255:0] modified_rmw_data;
    logic [127:0] modified_rmw_data_low;
    logic [127:0] modified_rmw_data_high;
    `else
    logic [127:0] modified_rmw_data;
    `endif
 
    `ifdef ZC706
    `ifdef DDR_32X
    wire [31:0]  ram_addr = {1'b0, DRAM_ADDRESS[31:1]};
    `else
    wire [31:0]  ram_addr = DRAM_ADDRESS[31:0];
    `endif
    wire         ram_wr = DRAM_WE;
    wire [127:0] ram_wr_data = {DRAM_DATA_WRITE3, DRAM_DATA_WRITE2, DRAM_DATA_WRITE1, DRAM_DATA_WRITE0};
    `ifdef DDR_32X
    wire [127:0] ram_wr_data_h = {DRAM_DATA_WRITE3_H, DRAM_DATA_WRITE2_H, DRAM_DATA_WRITE1_H, DRAM_DATA_WRITE0_H};
    `endif
    wire         ram_rd = DRAM_RE;
    wire [127:0] ram_rd_data;
    `ifdef DDR_32X
    wire [127:0] ram_rd_data_h;
    `endif
    wire         ram_accept;
    wire         ram_ack;
    wire         ram_ready;
 
    reg [15:0] ram_req_id = 0;

    wire ddr3_reset_i = (DRAM_WDG != 0);

    `ifdef DDR_32X
    wire [13:0] ddr3_addr_l;
    wire ddr3_reset_n_h;
    wire ddr3_cke_h;
    wire ddr3_ck_p_h;
    wire ddr3_ck_n_h;
    wire ddr3_ras_n_h;
    wire ddr3_cas_n_h;
    wire ddr3_we_n_h;
    wire [2:0] ddr3_ba_h;
    wire [13:0] ddr3_addr_h;
    wire ddr3_odt_h;
    wire ddr3_cs_n_h;

    assign ddr3_addr = {1'b0, ddr3_addr_l};
    `endif
 
    ddr3_controller 
    #(
       .DDR_MHZ(`DDR_MHZ)
    )
    ddr3_controller_inst(
       .rst_i(ddr3_reset_i),
       `ifdef DDR_100MHZ
       .clk(clk100),
       `else
       .clk(clk_i),
       `endif
       .clk_ddr(clk_ddr),
       .clk_ref(clk_ref),
       .clk_ddr_dqs(clk_ddr_dqs),
       .ram_addr(ram_addr),
       .wr_en(ram_wr),
       .wr_sel(16'b1111111111111111),
       .wr_data(ram_wr_data),
       .rd_en(ram_rd),
       .rd_data(ram_rd_data),
       .accepted(ram_accept),
       .acked(ram_ack),
       .ram_ready(ram_ready),

       .ddr3_reset_n(ddr3_reset_n),
       .ddr3_cke(ddr3_cke),
       .ddr3_ck_p(ddr3_ck_p),
       .ddr3_ck_n(ddr3_ck_n),
       .ddr3_ras_n(ddr3_ras_n),
       .ddr3_cas_n(ddr3_cas_n),
       .ddr3_we_n(ddr3_we_n),
       .ddr3_ba(ddr3_ba),
         `ifdef DDR_32X
         .ddr3_addr(ddr3_addr_l),
         .ddr3_odt(ddr3_odt),
         .ddr3_dm(ddr3_dm[1:0]),
         .ddr3_dqs_p(ddr3_dqs_p[1:0]),
         .ddr3_dqs_n(ddr3_dqs_n[1:0]),
         .ddr3_dq(ddr3_dq[15:0]),
         `else
         .ddr3_addr(ddr3_addr),
         .ddr3_odt(ddr3_odt),
         .ddr3_dm(ddr3_dm),
         .ddr3_dqs_p(ddr3_dqs_p),
         .ddr3_dqs_n(ddr3_dqs_n),
         .ddr3_dq(ddr3_dq),
         `endif
       .ddr3_cs_n(ddr3_cs_n)
 
       ,.ram_req_id(0)
    );

     `ifdef DDR_32X
     ddr3_controller 
     #(
         .DDR_MHZ(`DDR_MHZ)
     ) ddr3_controller_inst_h(
         .rst_i(ddr3_reset_i),
         `ifdef DDR_100MHZ
         .clk(clk100),
         `else
         .clk(clk_i),
         `endif
         .clk_ddr(clk_ddr),
         .clk_ref(clk_ref),
         .clk_ddr_dqs(clk_ddr_dqs),
         .ram_addr(ram_addr),
         .wr_en(ram_wr),
         .wr_sel(16'b1111111111111111),
         .wr_data(ram_wr_data_h),
         .rd_en(ram_rd),
         .rd_data(ram_rd_data_h),
         .accepted(),
         .acked(),
         .ram_ready(),

         .ddr3_reset_n(ddr3_reset_n_h),
         .ddr3_cke(ddr3_cke_h),
         .ddr3_ck_p(ddr3_ck_p_h),
         .ddr3_ck_n(ddr3_ck_n_h),
         .ddr3_ras_n(ddr3_ras_n_h),
         .ddr3_cas_n(ddr3_cas_n_h),
         .ddr3_we_n(ddr3_we_n_h),
         .ddr3_ba(ddr3_ba_h),
         .ddr3_addr(ddr3_addr_h),
         .ddr3_odt(ddr3_odt_h),
         .ddr3_dm(ddr3_dm[3:2]),
         .ddr3_dqs_p(ddr3_dqs_p[3:2]),
         .ddr3_dqs_n(ddr3_dqs_n[3:2]),
         .ddr3_dq(ddr3_dq[31:16]),
         .ddr3_cs_n(ddr3_cs_n_h)

         ,.ram_req_id(0)
     );
     `endif
    `else
     `ifdef DDR_32X
     wire [127:0] ram_rd_data = 0;
     wire [127:0] ram_rd_data_h = 0;
     `else
    wire [127:0] ram_rd_data = 0;
     `endif
    wire         ram_accept = 1;
    wire         ram_ack = 1;
    wire         ram_ready = 1;
    `endif

    always @* begin
        state_next_r = state_r;
        wb_ack_next_r = 0;
        wb_read_data_next_r = wb_read_data_r;
        wb_adr_next_r = wb_adr_r;
        wb_dat_next_r = wb_dat_r;
        wb_sel_next_r = wb_sel_r;
        uart_adr_next_r = uart_adr_r;
        uart_dat_next_r = uart_dat_r;

        DRAM_ADDRESS_NEXT = DRAM_ADDRESS;
        DRAM_DATA_WRITE0_NEXT = DRAM_DATA_WRITE0;
        DRAM_DATA_WRITE1_NEXT = DRAM_DATA_WRITE1;
        DRAM_DATA_WRITE2_NEXT = DRAM_DATA_WRITE2;
        DRAM_DATA_WRITE3_NEXT = DRAM_DATA_WRITE3;
        `ifdef DDR_32X
        DRAM_DATA_WRITE0_H_NEXT = DRAM_DATA_WRITE0_H;
        DRAM_DATA_WRITE1_H_NEXT = DRAM_DATA_WRITE1_H;
        DRAM_DATA_WRITE2_H_NEXT = DRAM_DATA_WRITE2_H;
        DRAM_DATA_WRITE3_H_NEXT = DRAM_DATA_WRITE3_H;
        `endif
        DRAM_RE_NEXT = DRAM_RE;
        DRAM_WE_NEXT = DRAM_WE;
        DRAM_WDG_NEXT = DRAM_WDG;

        `ifdef DDR_32X
        modified_rmw_data = 256'h0;
        modified_rmw_data_low = 128'h0;
        modified_rmw_data_high = 128'h0;
        `else
        modified_rmw_data = 128'h0;
        `endif

        case (state_r)
            IDLE: begin
                DRAM_RE_NEXT = 0;
                DRAM_WE_NEXT = 0;
                if (uart_dram_write_we_i) begin
                    uart_adr_next_r = uart_dram_write_addr_i;
                    uart_dat_next_r = uart_dram_write_data_i;
                    `ifdef DDR_32X
                    DRAM_ADDRESS_NEXT = uart_dram_write_addr_i & 32'hFFFFFFE0;
                    `else
                    DRAM_ADDRESS_NEXT = uart_dram_write_addr_i & 32'hFFFFFFF0;
                    `endif
                    state_next_r = UART_WRITE_RMW_START;
                end else if (wb_cyc_i && wb_stb_i && !wb_ack_r) begin
                    wb_adr_next_r = wb_adr_i;
                    `ifdef DDR_32X
                    DRAM_ADDRESS_NEXT = wb_adr_i & 64'hFFFFFFFFFFFFFFE0;
                    `else
                    DRAM_ADDRESS_NEXT = wb_adr_i & 64'hFFFFFFFFFFFFFFF0;
                    `endif
                    if (wb_we_i) begin
                        wb_dat_next_r = wb_dat_i;
                        wb_sel_next_r = wb_sel_i;
                        state_next_r = WRITE_RMW_START;
                    end
                    else begin
                        state_next_r = READ_START;
                    end
                end
            end

            READ_START: begin
                if (ram_ready) begin
                    DRAM_RE_NEXT = 1;
                    state_next_r = READ_WAIT_ACCEPT;
                end
            end

            READ_WAIT_ACCEPT: begin
                if (ram_accept) begin
                    state_next_r = READ_WAIT_ACK;
                end
            end

            READ_WAIT_ACK: begin
                if (ram_ack) begin
                    `ifdef DDR_32X
                    modified_rmw_data = {
                        ram_rd_data_h[127:112], ram_rd_data[127:112],
                        ram_rd_data_h[111:96],  ram_rd_data[111:96],
                        ram_rd_data_h[95:80],   ram_rd_data[95:80],
                        ram_rd_data_h[79:64],   ram_rd_data[79:64],
                        ram_rd_data_h[63:48],   ram_rd_data[63:48],
                        ram_rd_data_h[47:32],   ram_rd_data[47:32],
                        ram_rd_data_h[31:16],   ram_rd_data[31:16],
                        ram_rd_data_h[15:0],    ram_rd_data[15:0]
                    };
                    case (wb_adr_r[4:3])
                        2'b00: wb_read_data_next_r = modified_rmw_data[63:0];
                        2'b01: wb_read_data_next_r = modified_rmw_data[127:64];
                        2'b10: wb_read_data_next_r = modified_rmw_data[191:128];
                        2'b11: wb_read_data_next_r = modified_rmw_data[255:192];
                    endcase
                    `else
                    case (wb_adr_r[3])
                        1'b0: wb_read_data_next_r = ram_rd_data[63:0];
                        1'b1: wb_read_data_next_r = ram_rd_data[127:64];
                    endcase
                    `endif
                    wb_ack_next_r = 1;
                    state_next_r = IDLE;
                    DRAM_RE_NEXT = 0;
                end
            end

            WRITE_RMW_START: begin
                if (ram_ready) begin
                    DRAM_RE_NEXT = 1;
                    state_next_r = WRITE_RMW_WAIT_ACCEPT;
                end
            end

            WRITE_RMW_WAIT_ACCEPT: begin
                if (ram_accept) begin
                    state_next_r = WRITE_RMW_WAIT_ACK;
                end
            end

            WRITE_RMW_WAIT_ACK: begin
                if (ram_ack) begin
                    DRAM_RE_NEXT = 0;
                    `ifdef DDR_32X
                    modified_rmw_data = {
                        ram_rd_data_h[127:112], ram_rd_data[127:112],
                        ram_rd_data_h[111:96],  ram_rd_data[111:96],
                        ram_rd_data_h[95:80],   ram_rd_data[95:80],
                        ram_rd_data_h[79:64],   ram_rd_data[79:64],
                        ram_rd_data_h[63:48],   ram_rd_data[63:48],
                        ram_rd_data_h[47:32],   ram_rd_data[47:32],
                        ram_rd_data_h[31:16],   ram_rd_data[31:16],
                        ram_rd_data_h[15:0],    ram_rd_data[15:0]
                    };
                    case (wb_adr_r[4:3])
                        2'b00: begin
                            if(wb_sel_r[0]) modified_rmw_data[7:0]   = wb_dat_r[7:0];
                            if(wb_sel_r[1]) modified_rmw_data[15:8]  = wb_dat_r[15:8];
                            if(wb_sel_r[2]) modified_rmw_data[23:16] = wb_dat_r[23:16];
                            if(wb_sel_r[3]) modified_rmw_data[31:24] = wb_dat_r[31:24];
                            if(wb_sel_r[4]) modified_rmw_data[39:32] = wb_dat_r[39:32];
                            if(wb_sel_r[5]) modified_rmw_data[47:40] = wb_dat_r[47:40];
                            if(wb_sel_r[6]) modified_rmw_data[55:48] = wb_dat_r[55:48];
                            if(wb_sel_r[7]) modified_rmw_data[63:56] = wb_dat_r[63:56];
                        end
                        2'b01: begin
                            if(wb_sel_r[0]) modified_rmw_data[71:64]   = wb_dat_r[7:0];
                            if(wb_sel_r[1]) modified_rmw_data[79:72]   = wb_dat_r[15:8];
                            if(wb_sel_r[2]) modified_rmw_data[87:80]   = wb_dat_r[23:16];
                            if(wb_sel_r[3]) modified_rmw_data[95:88]   = wb_dat_r[31:24];
                            if(wb_sel_r[4]) modified_rmw_data[103:96]  = wb_dat_r[39:32];
                            if(wb_sel_r[5]) modified_rmw_data[111:104] = wb_dat_r[47:40];
                            if(wb_sel_r[6]) modified_rmw_data[119:112] = wb_dat_r[55:48];
                            if(wb_sel_r[7]) modified_rmw_data[127:120] = wb_dat_r[63:56];
                        end
                        2'b10: begin
                            if(wb_sel_r[0]) modified_rmw_data[135:128] = wb_dat_r[7:0];
                            if(wb_sel_r[1]) modified_rmw_data[143:136] = wb_dat_r[15:8];
                            if(wb_sel_r[2]) modified_rmw_data[151:144] = wb_dat_r[23:16];
                            if(wb_sel_r[3]) modified_rmw_data[159:152] = wb_dat_r[31:24];
                            if(wb_sel_r[4]) modified_rmw_data[167:160] = wb_dat_r[39:32];
                            if(wb_sel_r[5]) modified_rmw_data[175:168] = wb_dat_r[47:40];
                            if(wb_sel_r[6]) modified_rmw_data[183:176] = wb_dat_r[55:48];
                            if(wb_sel_r[7]) modified_rmw_data[191:184] = wb_dat_r[63:56];
                        end
                        2'b11: begin
                            if(wb_sel_r[0]) modified_rmw_data[199:192] = wb_dat_r[7:0];
                            if(wb_sel_r[1]) modified_rmw_data[207:200] = wb_dat_r[15:8];
                            if(wb_sel_r[2]) modified_rmw_data[215:208] = wb_dat_r[23:16];
                            if(wb_sel_r[3]) modified_rmw_data[223:216] = wb_dat_r[31:24];
                            if(wb_sel_r[4]) modified_rmw_data[231:224] = wb_dat_r[39:32];
                            if(wb_sel_r[5]) modified_rmw_data[239:232] = wb_dat_r[47:40];
                            if(wb_sel_r[6]) modified_rmw_data[247:240] = wb_dat_r[55:48];
                            if(wb_sel_r[7]) modified_rmw_data[255:248] = wb_dat_r[63:56];
                        end
                    endcase
                    modified_rmw_data_low = {
                        modified_rmw_data[239:224], modified_rmw_data[207:192],
                        modified_rmw_data[175:160], modified_rmw_data[143:128],
                        modified_rmw_data[111:96],  modified_rmw_data[79:64],
                        modified_rmw_data[47:32],   modified_rmw_data[15:0]
                    };
                    modified_rmw_data_high = {
                        modified_rmw_data[255:240], modified_rmw_data[223:208],
                        modified_rmw_data[191:176], modified_rmw_data[159:144],
                        modified_rmw_data[127:112], modified_rmw_data[95:80],
                        modified_rmw_data[63:48],   modified_rmw_data[31:16]
                    };
                    DRAM_DATA_WRITE0_NEXT = modified_rmw_data_low[31:0];
                    DRAM_DATA_WRITE1_NEXT = modified_rmw_data_low[63:32];
                    DRAM_DATA_WRITE2_NEXT = modified_rmw_data_low[95:64];
                    DRAM_DATA_WRITE3_NEXT = modified_rmw_data_low[127:96];
                    DRAM_DATA_WRITE0_H_NEXT = modified_rmw_data_high[31:0];
                    DRAM_DATA_WRITE1_H_NEXT = modified_rmw_data_high[63:32];
                    DRAM_DATA_WRITE2_H_NEXT = modified_rmw_data_high[95:64];
                    DRAM_DATA_WRITE3_H_NEXT = modified_rmw_data_high[127:96];
                    `else
                    modified_rmw_data = ram_rd_data;
                    case (wb_adr_r[3])
                        1'b0: begin
                            if(wb_sel_r[0]) modified_rmw_data[7:0]   = wb_dat_r[7:0];
                            if(wb_sel_r[1]) modified_rmw_data[15:8]  = wb_dat_r[15:8];
                            if(wb_sel_r[2]) modified_rmw_data[23:16] = wb_dat_r[23:16];
                            if(wb_sel_r[3]) modified_rmw_data[31:24] = wb_dat_r[31:24];
                            if(wb_sel_r[4]) modified_rmw_data[39:32] = wb_dat_r[39:32];
                            if(wb_sel_r[5]) modified_rmw_data[47:40] = wb_dat_r[47:40];
                            if(wb_sel_r[6]) modified_rmw_data[55:48] = wb_dat_r[55:48];
                            if(wb_sel_r[7]) modified_rmw_data[63:56] = wb_dat_r[63:56];
                        end
                        1'b1: begin
                            if(wb_sel_r[0]) modified_rmw_data[71:64]   = wb_dat_r[7:0];
                            if(wb_sel_r[1]) modified_rmw_data[79:72]   = wb_dat_r[15:8];
                            if(wb_sel_r[2]) modified_rmw_data[87:80]   = wb_dat_r[23:16];
                            if(wb_sel_r[3]) modified_rmw_data[95:88]   = wb_dat_r[31:24];
                            if(wb_sel_r[4]) modified_rmw_data[103:96]  = wb_dat_r[39:32];
                            if(wb_sel_r[5]) modified_rmw_data[111:104] = wb_dat_r[47:40];
                            if(wb_sel_r[6]) modified_rmw_data[119:112] = wb_dat_r[55:48];
                            if(wb_sel_r[7]) modified_rmw_data[127:120] = wb_dat_r[63:56];
                        end
                    endcase
                    DRAM_DATA_WRITE0_NEXT = modified_rmw_data[31:0];
                    DRAM_DATA_WRITE1_NEXT = modified_rmw_data[63:32];
                    DRAM_DATA_WRITE2_NEXT = modified_rmw_data[95:64];
                    DRAM_DATA_WRITE3_NEXT = modified_rmw_data[127:96];
                    `endif
                    state_next_r = WRITE_START;
                end
            end

            WRITE_START: begin
                if (ram_ready) begin
                    DRAM_WE_NEXT = 1;
                    state_next_r = WRITE_WAIT_ACCEPT;
                end
            end

            WRITE_WAIT_ACCEPT: begin
                if (ram_accept) begin
                    state_next_r = WRITE_WAIT_ACK;
                end
            end

            WRITE_WAIT_ACK: begin
                if (ram_ack) begin
                    wb_ack_next_r = 1;
                    state_next_r = IDLE;
                    DRAM_WE_NEXT = 0;
                end
            end
            
            UART_WRITE_RMW_START: begin
                if (ram_ready) begin
                    DRAM_RE_NEXT = 1;
                    state_next_r = UART_WRITE_RMW_WAIT_ACCEPT;
                end
            end

            UART_WRITE_RMW_WAIT_ACCEPT: begin
                if (ram_accept) begin
                    state_next_r = UART_WRITE_RMW_WAIT_ACK;
                end
            end

            UART_WRITE_RMW_WAIT_ACK: begin
                if (ram_ack) begin
                    DRAM_RE_NEXT = 0;
                    `ifdef DDR_32X
                    modified_rmw_data = {
                        ram_rd_data_h[127:112], ram_rd_data[127:112],
                        ram_rd_data_h[111:96],  ram_rd_data[111:96],
                        ram_rd_data_h[95:80],   ram_rd_data[95:80],
                        ram_rd_data_h[79:64],   ram_rd_data[79:64],
                        ram_rd_data_h[63:48],   ram_rd_data[63:48],
                        ram_rd_data_h[47:32],   ram_rd_data[47:32],
                        ram_rd_data_h[31:16],   ram_rd_data[31:16],
                        ram_rd_data_h[15:0],    ram_rd_data[15:0]
                    };
                    case (uart_adr_r[4:2])
                        3'b000: modified_rmw_data[31:0]    = uart_dat_r;
                        3'b001: modified_rmw_data[63:32]   = uart_dat_r;
                        3'b010: modified_rmw_data[95:64]   = uart_dat_r;
                        3'b011: modified_rmw_data[127:96]  = uart_dat_r;
                        3'b100: modified_rmw_data[159:128] = uart_dat_r;
                        3'b101: modified_rmw_data[191:160] = uart_dat_r;
                        3'b110: modified_rmw_data[223:192] = uart_dat_r;
                        3'b111: modified_rmw_data[255:224] = uart_dat_r;
                    endcase
                    modified_rmw_data_low = {
                        modified_rmw_data[239:224], modified_rmw_data[207:192],
                        modified_rmw_data[175:160], modified_rmw_data[143:128],
                        modified_rmw_data[111:96],  modified_rmw_data[79:64],
                        modified_rmw_data[47:32],   modified_rmw_data[15:0]
                    };
                    modified_rmw_data_high = {
                        modified_rmw_data[255:240], modified_rmw_data[223:208],
                        modified_rmw_data[191:176], modified_rmw_data[159:144],
                        modified_rmw_data[127:112], modified_rmw_data[95:80],
                        modified_rmw_data[63:48],   modified_rmw_data[31:16]
                    };
                    DRAM_DATA_WRITE0_NEXT = modified_rmw_data_low[31:0];
                    DRAM_DATA_WRITE1_NEXT = modified_rmw_data_low[63:32];
                    DRAM_DATA_WRITE2_NEXT = modified_rmw_data_low[95:64];
                    DRAM_DATA_WRITE3_NEXT = modified_rmw_data_low[127:96];
                    DRAM_DATA_WRITE0_H_NEXT = modified_rmw_data_high[31:0];
                    DRAM_DATA_WRITE1_H_NEXT = modified_rmw_data_high[63:32];
                    DRAM_DATA_WRITE2_H_NEXT = modified_rmw_data_high[95:64];
                    DRAM_DATA_WRITE3_H_NEXT = modified_rmw_data_high[127:96];
                    `else
                    modified_rmw_data = ram_rd_data;
                    case (uart_adr_r[3:2])
                        2'b00: modified_rmw_data[31:0]   = uart_dat_r;
                        2'b01: modified_rmw_data[63:32]  = uart_dat_r;
                        2'b10: modified_rmw_data[95:64]  = uart_dat_r;
                        2'b11: modified_rmw_data[127:96] = uart_dat_r;
                    endcase
                    DRAM_DATA_WRITE0_NEXT = modified_rmw_data[31:0];
                    DRAM_DATA_WRITE1_NEXT = modified_rmw_data[63:32];
                    DRAM_DATA_WRITE2_NEXT = modified_rmw_data[95:64];
                    DRAM_DATA_WRITE3_NEXT = modified_rmw_data[127:96];
                    `endif
                    state_next_r = UART_WRITE_START;
                end
            end

            UART_WRITE_START: begin
                if (ram_ready) begin
                    DRAM_WE_NEXT = 1;
                    state_next_r = UART_WRITE_WAIT_ACCEPT;
                end
            end

            UART_WRITE_WAIT_ACCEPT: begin
                if (ram_accept) begin
                    state_next_r = UART_WRITE_WAIT_ACK;
                end
            end

            UART_WRITE_WAIT_ACK: begin
                if (ram_ack) begin
                    wb_ack_next_r = 0; // No WB ack for UART writes
                    state_next_r = IDLE;
                    DRAM_WE_NEXT = 0;
                end
            end
        endcase

        if (DRAM_WDG > 0) begin
            DRAM_WDG_NEXT = DRAM_WDG - 1;
        end
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            wb_ack_r <= 0;
            wb_read_data_r <= 0;
    
            DRAM_ADDRESS <= 0;
            DRAM_DATA_WRITE0 <= 0;
            DRAM_DATA_WRITE1 <= 0;
            DRAM_DATA_WRITE2 <= 0;
            DRAM_DATA_WRITE3 <= 0;
            `ifdef DDR_32X
            DRAM_DATA_WRITE0_H <= 0;
            DRAM_DATA_WRITE1_H <= 0;
            DRAM_DATA_WRITE2_H <= 0;
            DRAM_DATA_WRITE3_H <= 0;
            `endif
            DRAM_RE <= 0;
            DRAM_WE <= 0;
            DRAM_WDG <= `CPU_CLK / 5000;

            state_r <= IDLE;
            wb_adr_r <= 0;
            wb_dat_r <= 0;
            wb_sel_r <= 0;
            uart_adr_r <= 0;
            uart_dat_r <= 0;
        end
        else begin
            wb_ack_r <= wb_ack_next_r;
            wb_read_data_r <= wb_read_data_next_r;
    
            DRAM_ADDRESS <= DRAM_ADDRESS_NEXT;
            DRAM_DATA_WRITE0 <= DRAM_DATA_WRITE0_NEXT;
            DRAM_DATA_WRITE1 <= DRAM_DATA_WRITE1_NEXT;
            DRAM_DATA_WRITE2 <= DRAM_DATA_WRITE2_NEXT;
            DRAM_DATA_WRITE3 <= DRAM_DATA_WRITE3_NEXT;
            `ifdef DDR_32X
            DRAM_DATA_WRITE0_H <= DRAM_DATA_WRITE0_H_NEXT;
            DRAM_DATA_WRITE1_H <= DRAM_DATA_WRITE1_H_NEXT;
            DRAM_DATA_WRITE2_H <= DRAM_DATA_WRITE2_H_NEXT;
            DRAM_DATA_WRITE3_H <= DRAM_DATA_WRITE3_H_NEXT;
            `endif
            DRAM_RE <= DRAM_RE_NEXT;
            DRAM_WE <= DRAM_WE_NEXT;
            DRAM_WDG <= DRAM_WDG_NEXT;

            state_r <= state_next_r;
            wb_adr_r <= wb_adr_next_r;
            wb_dat_r <= wb_dat_next_r;
            wb_sel_r <= wb_sel_next_r;
            uart_adr_r <= uart_adr_next_r;
            uart_dat_r <= uart_dat_next_r;
        end
    end
endmodule
