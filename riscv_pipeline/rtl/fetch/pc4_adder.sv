module pc4_adder(
    input logic[31:0] pc,
    output logic[31:0] pc4
);
    assign pc4 = pc + 4;
endmodule
