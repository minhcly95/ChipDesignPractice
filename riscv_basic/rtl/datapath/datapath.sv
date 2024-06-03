module datapath #(
    parameter logic[31:0] BootVector = 32'h0000_0000
)(
    input logic clk,
    input logic reset,
    // I-mem
    output logic[31:0] pc,
    input logic[31:0] instr,
    // D-mem
    output logic[31:0] d_addr,
    output logic[31:0] d_wdata,
    output logic[3:0] d_wstrb,
    input logic[31:0] d_rdata,
    // Controls
    input logic[2:0] imm_sel,
    input logic src_a_sel,
    input logic src_b_sel,
    input logic[2:0] alu_func,
    input logic shamt_sel,
    input logic[1:0] shift_op,
    input logic exec_sel,
    input logic mem_write,
    input logic[2:0] mem_size,
    input logic reg_write,
    input logic[1:0] regd_sel,
    input logic jump,
    input logic branch,
    input logic branch_neg
);
    // ----------------- Signals ---------------------
    // Fetch
    logic[31:0] pc1;
    logic[31:0] pc2;
    logic[31:0] pc3;
    logic[31:0] pc4;
    logic[31:0] pc_branch;

    // Decode
    logic[4:0] rs1;
    logic[4:0] rs2;
    logic[4:0] rd;
    logic[4:0] shamt_imm;
    logic[31:0] imm;

    // Execute
    logic[31:0] reg_a;
    logic[31:0] reg_b;
    logic[31:0] src_a;
    logic[31:0] src_b;
    logic[4:0] shamt;
    logic[31:0] mem_res;
    logic[31:0] alu_res;
    logic[31:0] shift_res;
    logic[31:0] exec_res;
    logic[31:0] reg_d;

    // Branch logic
    logic alu_zero;
    logic branch_ok;
    logic pc_sel;

    // ---------------- Structure --------------------
    // Fetch
    flopr #(32, BootVector) pc_reg(clk, reset, pc1, pc);
    pc_adder pc_adder(pc, pc4);
    mux2 #(32) pc_mux2(pc4, pc_branch, pc_sel, pc3);
    mux2 #(32) pc_mux1(pc3, alu_res, jump, pc2);
    pc_mask pc_mask(pc2, pc1);

    // Decode
    instr_dec instr_dec(instr, rd, rs1, rs2, shamt_imm);
    reg_file reg_file(clk, rs1, reg_a, rs2, reg_b, rd, reg_d, reg_write);
    imm_dec imm_dec(instr, imm_sel, imm);

    // Execute
    mux2 #(32) src_a_mux(pc, reg_a, src_a_sel, src_a);
    mux2 #(32) src_b_mux(reg_b, imm, src_b_sel, src_b);
    alu alu(src_a, src_b, alu_func, alu_res);

    mux2 #(5) shamt_mux(reg_b[4:0], shamt_imm, shamt_sel, shamt);
    shifter shifter(reg_a, shamt, shift_op, shift_res);

    mux2 #(32) exec_mux(alu_res, shift_res, exec_sel, exec_res);
    
    // Branch logic
    branch_adder branch_adder(pc, imm, pc_branch);
    assign alu_zero = ~|alu_res;
    assign branch_ok = alu_zero ^ branch_neg;
    assign pc_sel = branch & branch_ok;

    // Memory
    dmem_ctrl dmem_ctrl(
        alu_res, reg_b, mem_res,
        mem_write, mem_size,
        d_addr, d_wdata, d_wstrb, d_rdata
    );

    // Write back
    mux4 #(32) regd_mux(mem_res, exec_res, imm, pc4, regd_sel, reg_d);

endmodule
