module execute_stage(
    // Pipeline input
    input logic[1:0] exec_sel_e,
    input logic[2:0] flow_ctrl_e,
    input logic[3:0] alsu_func_e,
    input logic[1:0] src_sel_e,
    input logic[3:0] fwd_sel_e,
    input logic[31:0] reg_a_e,
    input logic[31:0] reg_b_e,
    input logic[31:0] imm_e,
    input logic[31:0] pc_e,
    input logic[31:0] pc4_e,
    // Pipeline output
    output logic[31:0] exec_res_e,
    output logic[31:0] fwd_b_e,
    // To Fetch
    output logic[1:0] pc_sel_e,
    output logic[31:0] alsu_res_e,
    // Forwarding paths
    input logic[31:0] exec_res_m,
    input logic[31:0] reg_d_w,
    // Pipeline control
    output logic flush
);
    // ----------------- Signals ---------------------
    logic[31:0] fwd_a;
    logic[31:0] fwd_b;
    logic[31:0] src_a;
    logic[31:0] src_b;
    logic zero;

    // ---------------- Structure --------------------
    // Input mux
    fwd_mux fwd_mux(reg_a_e, reg_b_e, exec_res_m, reg_d_w, fwd_sel_e, fwd_a, fwd_b);
    src_mux src_mux(fwd_a, fwd_b, pc_e, imm_e, src_sel_e, src_a, src_b);
    assign fwd_b_e = fwd_b;

    // ALSU
    alsu alsu(src_a, src_b, alsu_func_e, alsu_res_e, zero);

    // Flow control
    flow_control flow_control(zero, flow_ctrl_e, pc_sel_e, flush);

    // Output mux
    mux4 #(32) exec_mux(alsu_res_e, imm_e, pc4_e, pc4_e, exec_sel_e, exec_res_e);

endmodule
