module instr_dec(
    input logic[31:0] instr,
    output logic[4:0] rd,
    output logic[4:0] rs1,
    output logic[4:0] rs2,
    output logic[4:0] shamt
);
    assign rd = instr[11:7];
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign shamt = instr[24:20];
endmodule
