module imm_dec(
    input logic[31:0] instr,
    input logic[2:0] imm_sel,
    output logic[31:0] imm
);
    logic sign;

    assign sign = instr[31];

    always_comb
        case (imm_sel)
            3'b000: imm = { {20{sign}}, instr[31:20] };                                 // I-type
            3'b001: imm = { {20{sign}}, instr[31:25], instr[11:7] };                    // S-type
            3'b010: imm = { instr[31:12], 12'h0 };                                      // U-type
            3'b100: imm = { {12{sign}}, instr[19:12], instr[20], instr[30:21], 1'b0 };  // J-type
            3'b101: imm = { {20{sign}}, instr[7], instr[30:25], instr[11:8], 1'b0 };    // B-type
            default: imm = 32'hx;
        endcase
endmodule
