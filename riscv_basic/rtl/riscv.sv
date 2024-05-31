module riscv #(
    parameter logic[31:0] BootVector = 32'h0000_0000
)(
    input logic clk,
    input logic reset,
    // I-mem
    output logic[31:0] pc,
    input logic[31:0] instr
);
    // ----------------- Signals ---------------------
    // Instruction
    logic[6:0] opcode;
    logic[2:0] funct3;
    logic funct7_5;

    // Controls
    logic src_a_sel;
    logic[1:0] src_b_sel;
    logic[2:0] alu_func;
    logic shamt_sel;
    logic[1:0] shift_op;
    logic[1:0] dest_sel;
    logic reg_write;

    // ---------------- Structure --------------------
    datapath #(BootVector) dp(.*);
    controller ctrl(.*);

    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7_5 = instr[30];

endmodule
