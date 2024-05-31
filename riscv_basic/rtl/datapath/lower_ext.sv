module lower_ext(
    input logic[31:12] a,
    output logic[31:0] y
);
    assign y = {a, 12'h0};
endmodule
