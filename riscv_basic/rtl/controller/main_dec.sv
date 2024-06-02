// Constant definition
`define OPCODE_OP       7'b01_100_11
`define OPCODE_OP_IMM   7'b00_100_11
`define OPCODE_LUI      7'b01_101_11
`define OPCODE_AUIPC    7'b00_101_11
`define OPCODE_LOAD     7'b00_000_11
`define OPCODE_STORE    7'b01_000_11

`define IMM_I           3'b000
`define IMM_S           3'b001
`define IMM_U           3'b010
`define IMM_J           3'b100
`define IMM_B           3'b101
`define IMM_X           3'bxxx

`define SRC_RR          2'b10
`define SRC_RI          2'b11
`define SRC_PI          2'b01
`define SRC_X           2'bxx

`define ALU_DEF         4'b0xxx
`define ALU_ADD         4'b1000
`define ALU_SLT         4'b1010
`define ALU_SLTU        4'b1011
`define ALU_X           4'bxxxx

`define SHAMT_REG       1'b0
`define SHAMT_IMM       1'b1
`define SHAMT_X         1'bx

`define REGD_MEM        3'b100
`define REGD_ALU        3'b101
`define REGD_SFT        3'b110
`define REGD_IMM        3'b111
`define REGD_X          3'b0xx

module main_dec(
    // Instruction
    input logic[6:0] opcode,
    input logic[2:0] funct3,
    // Controls
    output logic[2:0] imm_sel,
    output logic src_a_sel,
    output logic src_b_sel,
    output logic alu_set,
    output logic[2:0] alu_op,
    output logic shamt_sel,
    output logic mem_write,
    output logic reg_write,
    output logic[1:0] regd_sel,
    output logic recode
);
    logic is_shift;
    logic[12:0] controls;

    assign is_shift = funct3[1:0] == 2'b01;
    assign recode = (opcode == `OPCODE_OP);
    assign mem_write = (opcode == `OPCODE_STORE);

    assign {imm_sel, src_a_sel, src_b_sel, alu_set, alu_op, shamt_sel, reg_write, regd_sel} = controls;

    always_comb begin
        case (opcode)
            // Reg + imm operations
            `OPCODE_OP_IMM:
                if (is_shift) controls = {`IMM_X, `SRC_X,  `ALU_X,   `SHAMT_IMM, `REGD_SFT};
                else          controls = {`IMM_I, `SRC_RI, `ALU_DEF, `SHAMT_X,   `REGD_ALU};
            // Reg + reg operations
            `OPCODE_OP:
                if (is_shift) controls = {`IMM_X, `SRC_X,  `ALU_X,   `SHAMT_REG, `REGD_SFT};
                else          controls = {`IMM_X, `SRC_RR, `ALU_DEF, `SHAMT_X,   `REGD_ALU};
            // Load upper immediate
            `OPCODE_LUI:      controls = {`IMM_U, `SRC_X,  `ALU_X,   `SHAMT_X,   `REGD_IMM};
            // Add upper imm to PC
            `OPCODE_AUIPC:    controls = {`IMM_U, `SRC_PI, `ALU_ADD, `SHAMT_X,   `REGD_ALU};
            // Load
            `OPCODE_LOAD:     controls = {`IMM_I, `SRC_RI, `ALU_ADD, `SHAMT_X,   `REGD_MEM};
            // Store
            `OPCODE_STORE:    controls = {`IMM_S, `SRC_RI, `ALU_ADD, `SHAMT_X,   `REGD_X  };
            // Invalid
            default:          controls = {`IMM_X, `SRC_X,  `ALU_X,   `SHAMT_X,   `REGD_X  };
        endcase
    end
    
endmodule
