module controller(
    // Instruction
    input logic[6:0] opcode,
    input logic[2:0] funct3,
    input logic funct7_5,
    // Controls
    output logic src_a_sel,
    output logic[1:0] src_b_sel,
    output logic[2:0] alu_func,
    output logic shamt_sel,
    output logic[1:0] shift_op,
    output logic[1:0] dest_sel,
    output logic reg_write
);
    // ----------------- Signals ---------------------
    logic recode;
    logic[2:0] alu_code;
    logic[2:0] alu_op;
    logic alu_set;

    // ---------------- Structure --------------------
    main_dec main_dec(.*);

    alu_dec alu_dec(funct3, funct7_5, recode, alu_code);
    mux2 #(3) alu_mux(alu_code, alu_op, alu_set, alu_func);

    assign shift_op = {funct7_5, funct3[2]};

endmodule
