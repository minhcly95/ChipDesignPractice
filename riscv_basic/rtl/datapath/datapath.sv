module datapath #(
    parameter logic[31:0] BootVector = 32'h0000_0000
)(
    input logic clk,
    input logic reset,
    // I-mem
    output logic[31:0] pc,
    input logic[31:0] instr,
    // Controls
    input logic src_a_sel,
    input logic[1:0] src_b_sel,
    input logic[2:0] alu_func,
    input logic shamt_sel,
    input logic[1:0] shift_op,
    input logic[1:0] dest_sel,
    input logic reg_write
);
    // ----------------- Signals ---------------------
    // Fetch
    logic[31:0] pc_next;

    // Decode
    logic[4:0] rs1;
    logic[4:0] rs2;
    logic[4:0] rd;
    logic[4:0] shamt_imm;
    logic[11:0] imm_i;
    logic[31:12] imm_u;

    // Execute
    logic[31:0] reg_a;
    logic[31:0] reg_b;
    logic[31:0] sign_imm;
    logic[31:0] upper_imm;
    logic[31:0] src_a;
    logic[31:0] src_b;
    logic[4:0] shamt;
    logic[31:0] alu_res;
    logic[31:0] shift_res;
    logic[31:0] reg_d;

    // ---------------- Structure --------------------
    // Fetch
    flopr #(32, BootVector) pc_reg(clk, reset, pc_next, pc);
    pc_adder pc_adder(pc, pc_next);

    // Decode
    instr_dec instr_dec(instr, rd, rs1, rs2, shamt_imm, imm_i, imm_u);
    reg_file reg_file(clk, rs1, reg_a, rs2, reg_b, rd, reg_d, reg_write);
    sign_ext #(12) sign_ext(imm_i, sign_imm);
    lower_ext lower_ext(imm_u, upper_imm);

    // Execute
    mux2 #(32) src_a_mux(pc, reg_a, src_a_sel, src_a);
    mux4 #(32) src_b_mux(reg_b, sign_imm, upper_imm, 'x, src_b_sel, src_b);
    alu alu(src_a, src_b, alu_func, alu_res);

    mux2 #(5) shamt_mux(reg_b[4:0], shamt_imm, shamt_sel, shamt);
    shifter shifter(reg_a, shamt, shift_op, shift_res);
    mux4 #(32) dest_mux(alu_res, shift_res, upper_imm, 'x, dest_sel, reg_d);

endmodule
