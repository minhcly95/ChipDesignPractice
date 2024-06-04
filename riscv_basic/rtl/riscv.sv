module riscv #(
    parameter logic[31:0] BootVector = 32'h0000_0000
)(
    input logic clk,
    input logic reset,
    output logic halted,
    input logic unhalt,
    // I-mem
    output logic[31:0] pc,
    input logic[31:0] instr,
    // D-mem
    output logic[31:0] d_addr,
    output logic[31:0] d_wdata,
    output logic[3:0] d_wstrb,
    input logic[31:0] d_rdata
);
    // ----------------- Signals ---------------------
    // Instruction
    logic[6:0] opcode;
    logic[2:0] funct3;
    logic funct7_5;

    // Controls
    logic[2:0] imm_sel;
    logic src_a_sel;
    logic src_b_sel;
    logic[2:0] alu_func;
    logic[1:0] shift_op;
    logic exec_sel;
    logic mem_write;
    logic[2:0] mem_size;
    logic reg_write;
    logic[1:0] regd_sel;
    logic jump;
    logic branch;
    logic branch_neg;

    // Exceptions
    logic misaligned_pc;
    logic misaligned_addr;

    // ---------------- Structure --------------------
    datapath #(BootVector) dp(.*);
    controller ctrl(.*);

    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7_5 = instr[30];

endmodule
