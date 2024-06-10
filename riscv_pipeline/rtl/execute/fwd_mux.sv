module fwd_mux(
    input logic[31:0] reg_a,
    input logic[31:0] reg_b,
    input logic[31:0] exec_res_m,
    input logic[31:0] reg_d_w,
    input logic[3:0] fwd_sel,
    output logic[31:0] fwd_a,
    output logic[31:0] fwd_b
);
    assign fwd_a = fwd_sel[0] ? exec_res_m : (fwd_sel[2] ? reg_d_w : reg_a);
    assign fwd_b = fwd_sel[1] ? exec_res_m : (fwd_sel[3] ? reg_d_w : reg_b);
endmodule
