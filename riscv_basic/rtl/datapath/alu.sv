module alu(
    input logic[31:0] a,
    input logic[31:0] b,
    input logic[2:0] f,
    output logic[31:0] s
);
    logic sub_en;
    logic[31:0] bb, sum, xor_res, or_res, and_res;
    logic an, bn, sn, slt;

    // Subtraction control
    assign sub_en = f[0] | f[1];
    assign bb = sub_en ? ~b : b;

    // Adder, XOR, OR, AND
    assign sum = a + bb + sub_en;
    assign xor_res = a ^ b;
    assign or_res = a | b;
    assign and_res = a & b;

    // Set if less than
    assign an = a[31];
    assign bn = b[31];
    assign sn = sum[31];
    
    always_comb
        case ({an, bn})
            2'b00: slt = sn;
            2'b01: slt = f[0];
            2'b10: slt = ~f[0];
            2'b11: slt = sn;
        endcase

    // Output select
    always_comb
        case (f[2:1])
            2'b00: s = sum;
            2'b01: s = {31'h0, slt};
            2'b10: s = xor_res;
            2'b11: s = f[0] ? and_res : or_res;
        endcase

endmodule
