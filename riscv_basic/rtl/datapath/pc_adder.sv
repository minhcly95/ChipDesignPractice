module pc_adder(
    input logic[31:0] pc,
    output logic[31:0] pc_plus_4
);
    assign pc_plus_4 = pc + 4;
endmodule
