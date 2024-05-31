// Constant definition
`define OPCODE_OP       7'b01_100_11
`define OPCODE_OP_IMM   7'b00_100_11
`define OPCODE_LUI      7'b01_101_11
`define OPCODE_AUIPC    7'b00_101_11

`define SRCA_PC         1'b0
`define SRCA_REG        1'b1
`define SRCA_X          1'bx

`define SRCB_REG        2'b00
`define SRCB_IMMI       2'b01
`define SRCB_IMMU       2'b10
`define SRCB_X          2'bxx

`define ALU_DEF         1'b0
`define ALU_SET         1'b1
`define ALU_X           1'bx

`define ALUOP_ADD       3'b000
`define ALUOP_SLT       3'b010
`define ALUOP_SLTU      3'b011
`define ALUOP_X         3'bxxx

`define SHAMT_REG       1'b0
`define SHAMT_IMM       1'b1
`define SHAMT_X         1'bx

`define DEST_ALU        2'b00
`define DEST_SHIFT      2'b01
`define DEST_IMMU       2'b10
`define DEST_X          2'bxx

`define REG_NOWR        1'b0
`define REG_WRITE       1'b1

module main_dec(
    // Instruction
    input logic[6:0] opcode,
    input logic[2:0] funct3,
    // Controls
    output logic src_a_sel,
    output logic[1:0] src_b_sel,
    output logic alu_set,
    output logic[2:0] alu_op,
    output logic shamt_sel,
    output logic[1:0] dest_sel,
    output logic reg_write,
    output logic recode
);
    logic is_shift;
    logic[10:0] controls;

    assign is_shift = funct3[1:0] == 2'b01;

    assign {src_a_sel, src_b_sel, alu_set, alu_op, shamt_sel, dest_sel, reg_write} = controls;

    always_comb begin
        recode = 0;
        case (opcode)
            // Reg + imm operations
            `OPCODE_OP_IMM:
                if (is_shift) controls = {`SRCA_X,   `SRCB_X,    `ALU_X,   `ALUOP_X,   `SHAMT_IMM, `DEST_SHIFT, `REG_WRITE};
                else          controls = {`SRCA_REG, `SRCB_IMMI, `ALU_DEF, `ALUOP_X,   `SHAMT_X,   `DEST_ALU,   `REG_WRITE};
            // Reg + reg operations
            `OPCODE_OP: begin
                recode = 1;
                if (is_shift) controls = {`SRCA_X,   `SRCB_X,    `ALU_X,   `ALUOP_X,   `SHAMT_REG, `DEST_SHIFT, `REG_WRITE};
                else          controls = {`SRCA_REG, `SRCB_REG,  `ALU_DEF, `ALUOP_X,   `SHAMT_X,   `DEST_ALU,   `REG_WRITE};
            end
            // Load upper immediate
            `OPCODE_LUI:       controls = {`SRCA_X,   `SRCB_X,    `ALU_X,   `ALUOP_X,   `SHAMT_X,   `DEST_IMMU,  `REG_WRITE};
            // Add upper imm to PC
            `OPCODE_AUIPC:     controls = {`SRCA_PC,  `SRCB_IMMU, `ALU_SET, `ALUOP_ADD, `SHAMT_X,   `DEST_ALU,   `REG_WRITE};
            // Invalid
            default:          controls = {`SRCA_X,   `SRCB_X,    `ALU_X,   `ALUOP_X,   `SHAMT_X,   `DEST_X,     `REG_NOWR };
        endcase
    end
    
endmodule
