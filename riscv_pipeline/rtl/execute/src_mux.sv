module src_mux(
    input logic[31:0] fwd_a,
    input logic[31:0] fwd_b,
    input logic[31:0] pc,
    input logic[31:0] imm,
    input logic[1:0] src_sel,
    output logic[31:0] src_a,
    output logic[31:0] src_b
);
    assign src_a = src_sel[0] ? pc : fwd_a;
    assign src_b = src_sel[1] ? imm : fwd_b;
endmodule
