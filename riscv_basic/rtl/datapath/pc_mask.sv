module pc_mask(
    input logic[31:0] pc2,
    output logic[31:0] pc1
);
    assign pc1 = {pc2[31:1], 1'b0};
endmodule
