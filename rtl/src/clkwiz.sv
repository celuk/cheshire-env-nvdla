module clkwiz (
  input  wire clk_in1,
  input  wire reset,
  output wire locked,
  output wire clk_50,
  output wire clk_48,
  output wire clk_20,
  output wire clk_10
);

  wire clk_out1;
  wire clk_out2;
  wire clk_out3;
  wire clk_out4;
  wire clk_out5;

  clk_wiz_0 i_clk_wiz_0 (
    .clk_in1  ( clk_in1 ),
    .reset    ( reset   ),
    .locked   ( locked  ),
    .clk_out1 ( clk_out1 ),
    .clk_out2 ( clk_out2 ),
    .clk_out3 ( clk_out3 ),
    .clk_out4 ( clk_out4 ),
    .clk_out5 ( clk_out5 )
  );

  assign clk_50 = clk_out1;
  assign clk_48 = clk_out2;
  assign clk_20 = clk_out3;
  assign clk_10 = clk_out4;

endmodule
