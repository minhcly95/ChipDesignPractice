module pc_imm_adder(
    input logic[31:0] pc,
    input logic[31:0] imm,
    output logic[31:0] pc_imm
);
    assign pc_imm = pc + imm;
endmodule
