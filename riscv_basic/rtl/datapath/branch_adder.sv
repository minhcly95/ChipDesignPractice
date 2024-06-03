module branch_adder(
    input logic[31:0] pc,
    input logic[31:0] imm,
    output logic[31:0] pc_branch
);
    assign pc_branch = pc + {imm[31:1], 1'b0};
endmodule
