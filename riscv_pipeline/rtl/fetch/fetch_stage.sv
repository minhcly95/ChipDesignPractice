`define NOP 32'b000000000000_00000_000_00000_0010011

module fetch_stage #(
    parameter logic[31:0] BootVector = 32'h0000_0000
)(
    input logic clk,
    input logic reset,
    input logic halted,
    // I-mem
    output logic[31:0] i_addr,
    input logic[31:0] i_data,
    // Pipeline output
    output logic[31:0] instr_f,
    output logic[31:0] pc_f,
    output logic[31:0] pc4_f,
    // Backward paths
    input logic[31:0] pc_imm_d,
    input logic[31:0] pc_imm_e,
    input logic[31:0] alsu_res_e,
    input logic jump_d,
    input logic[1:0] pc_sel_e,
    // Pipeline control
    input logic stall,
    input logic flush,
    // Exceptions
    output logic misaligned_pc
);
    // ----------------- Signals ---------------------
    logic[31:0] pc1;
    logic[31:0] pc2;
    logic[31:0] pc3;

    // ---------------- Structure --------------------
    // PC register
    floper #(32, BootVector) pc_reg(clk, reset, ~halted & ~stall, pc1, pc_f);

    // PC input
    pc4_adder pc4_adder(pc_f, pc4_f);
    mux2 #(32) pc_mux_d(pc4_f, pc_imm_d, jump_d, pc3);
    mux4 #(32) pc_mux_e(pc3, pc_imm_e, alsu_res_e, alsu_res_e, pc_sel_e, pc2);
    pc_mask pc_mask(pc2, pc1, misaligned_pc);

    // Instruction memory
    assign i_addr = pc_f;

    // Flush mechanism
    mux2 #(32) instr_mux(i_data, `NOP, flush | jump_d, instr_f);

endmodule
