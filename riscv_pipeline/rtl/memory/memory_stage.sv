module memory_stage(
    input logic halted,
    // D-mem
    output logic[31:0] d_addr,
    output logic[31:0] d_wdata,
    output logic[3:0] d_wstrb,
    input logic[31:0] d_rdata,
    // Pipeline input
    input logic[2:0] mem_size_m,
    input logic mem_write_m,
    input logic mem_read_m,
    input logic[31:0] exec_res_m,
    input logic[31:0] fwd_b_m,
    // Pipeline output
    output logic[31:0] reg_d_m,
    // Exception
    output logic misaligned_addr
);
    // ----------------- Signals ---------------------
    logic[31:0] mem_res;
    logic mem_op_m;
    logic misaligned_addr_pre;

    // ---------------- Structure --------------------
    dmem_ctrl dmem_ctrl(
        .a(exec_res_m),
        .wd(fwd_b_m),
        .rd(mem_res),
        .mem_write(~halted & mem_write_m),
        .mem_size(mem_size_m),
        .d_addr(d_addr),
        .d_wdata(d_wdata),
        .d_wstrb(d_wstrb),
        .d_rdata(d_rdata),
        .misaligned_addr(misaligned_addr_pre)
    );

    mux2 #(32) mem_mux(exec_res_m, mem_res, mem_read_m, reg_d_m);
    assign mem_op_m = mem_read_m | mem_write_m;
    assign misaligned_addr = misaligned_addr_pre & mem_op_m;

endmodule
