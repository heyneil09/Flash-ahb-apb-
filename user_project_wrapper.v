module user_project_wrapper (
    input wire wb_clk_i, wb_rst_i, 
    input wire [31:0] wbs_adr_i, wbs_dat_i,
    input wire wbs_we_i, wbs_cyc_i,
    output wire [31:0] wbs_dat_o
);
    flash_memory flash_inst (
        .clk(wb_clk_i), .reset(wb_rst_i),
        .apb_sel(wbs_cyc_i), .apb_write(wbs_we_i),
        .apb_addr(wbs_adr_i[7:0]), .apb_wdata(wbs_dat_i),
        .apb_rdata(wbs_dat_o)
    );
endmodule
