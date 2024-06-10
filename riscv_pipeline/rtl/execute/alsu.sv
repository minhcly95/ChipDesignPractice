module alsu(
    input logic[31:0] a,
    input logic[31:0] b,
    input logic[3:0] f,
    output logic[31:0] s,
    output logic zero
);
    logic sub_en;
    logic[31:0] bb, sum, xor_res, or_res, and_res, shift_res;
    logic an, bn, sn, slt;

    // Subtraction control
    assign sub_en = f[3] | f[1];
    assign bb = {32{sub_en}} ^ b;

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

    // Shifter
    shifter shifter(a, b[4:0], f[3:2], shift_res);    

    // Output select
    always_comb
        case (f[2:0])
            3'b000: s = sum;
            3'b001: s = shift_res;
            3'b010: s = {31'h0, slt};
            3'b011: s = {31'h0, slt};
            3'b100: s = xor_res;
            3'b101: s = shift_res;
            3'b110: s = or_res;
            3'b111: s = and_res;
        endcase

    // Zero
    assign zero = ~|s;

endmodule
