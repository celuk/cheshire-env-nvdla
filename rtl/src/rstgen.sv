// Copied from pulp-platform/common_cells and tech_cells_generic
// Minimal implementation for Cheshire SoC wrapper

module tc_clk_mux2 (
    input  logic clk0_i,
    input  logic clk1_i,
    input  logic clk_sel_i,
    output logic clk_o
);
    assign clk_o = clk_sel_i ? clk1_i : clk0_i;
endmodule

module rstgen_bypass #(
    parameter int unsigned NumRegs = 4
) (
    input  logic clk_i,
    input  logic rst_ni,
    input  logic rst_test_mode_ni,
    input  logic test_mode_i,
    output logic rst_no,
    output logic init_no
);

    // internal reset
    logic rst_n_int;

    logic [NumRegs-1:0] synch_regs_q;

    // input mux: in test mode, select test reset
    tc_clk_mux2 i_tc_clk_mux2_rst_n (
        .clk0_i     ( rst_ni ),
        .clk1_i     ( rst_test_mode_ni ),
        .clk_sel_i  ( test_mode_i ),
        .clk_o      ( rst_n_int )
    );

    // Synchronizer: async assert (clear), sync deassert (shift in 1s)
    always_ff @(posedge clk_i or negedge rst_n_int) begin
        if (!rst_n_int) begin
            synch_regs_q <= {NumRegs{1'b0}};
        end else begin
            synch_regs_q <= {synch_regs_q[NumRegs-2:0], 1'b1};
        end
    end

    // output muxes
    tc_clk_mux2 i_tc_clk_mux2_rst_no (
        .clk0_i     ( synch_regs_q[NumRegs-1] ),
        .clk1_i     ( rst_test_mode_ni ),
        .clk_sel_i  ( test_mode_i ),
        .clk_o      ( rst_no )
    );

    tc_clk_mux2 i_tc_clk_mux2_init_no (
        .clk0_i     ( synch_regs_q[NumRegs-1] ),
        .clk1_i     ( 1'b1 ),
        .clk_sel_i  ( test_mode_i ),
        .clk_o      ( init_no )
    );

endmodule

module rstgen (
    input  logic clk_i,
    input  logic rst_ni,
    input  logic test_mode_i,
    output logic rst_no,
    output logic init_no
);

    rstgen_bypass i_rstgen_bypass (
        .clk_i            ( clk_i       ),
        .rst_ni           ( rst_ni      ),
        .rst_test_mode_ni ( rst_ni      ), // Tied together in top-level for simple case
        .test_mode_i      ( test_mode_i ),
        .rst_no           ( rst_no      ),
        .init_no          ( init_no     )
    );

endmodule
