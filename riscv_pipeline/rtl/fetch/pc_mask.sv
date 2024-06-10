module pc_mask(
    input logic[31:0] pc2,
    output logic[31:0] pc1,
    output logic misaligned_pc
);
    assign pc1 = {pc2[31:2], 2'b0};
    assign misaligned_pc = pc2[1];
endmodule
