// Constant definition
`define OPCODE_OP       7'b01_100_11
`define OPCODE_OP_IMM   7'b00_100_11
`define OPCODE_LUI      7'b01_101_11
`define OPCODE_AUIPC    7'b00_101_11
`define OPCODE_LOAD     7'b00_000_11
`define OPCODE_STORE    7'b01_000_11
`define OPCODE_JAL      7'b11_011_11
`define OPCODE_JALR     7'b11_001_11
`define OPCODE_BRANCH   7'b11_000_11

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

`define SHAMT_REG       1'b0
`define SHAMT_IMM       1'b1
`define SHAMT_X         1'bx

`define EXEC_ALU        5'b0xxx0
`define EXEC_ADD        5'b10000
`define EXEC_SUB        5'b10010
`define EXEC_SLT        5'b10100
`define EXEC_SLTU       5'b10110
`define EXEC_SHIFT      5'bxxxx1
`define EXEC_X          5'bxxxxx

`define REGD_MEM        3'b100
`define REGD_EXEC       3'b101
`define REGD_IMM        3'b110
`define REGD_PC4        3'b111
`define REGD_X          3'b0xx

`define FLOW_JMP        3'b1xx
`define FLOW_BZ         3'b010
`define FLOW_BNZ        3'b011
`define FLOW_X          3'b00x

`define BEQ             3'b000
`define BNE             3'b001
`define BLT             3'b100
`define BGE             3'b101
`define BLTU            3'b110
`define BGEU            3'b111

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
    output logic exec_sel,
    output logic mem_write,
    output logic reg_write,
    output logic[1:0] regd_sel,
    output logic jump,
    output logic branch,
    output logic branch_neg,
    output logic recode
);
    logic is_shift;
    logic[16:0] controls;

    assign is_shift = funct3[1:0] == 2'b01;
    assign recode = (opcode == `OPCODE_OP);
    assign mem_write = (opcode == `OPCODE_STORE);

    assign {imm_sel, src_a_sel, src_b_sel, shamt_sel, alu_set, alu_op, exec_sel, reg_write, regd_sel, jump, branch, branch_neg} = controls;

    always_comb begin
        case (opcode)
            // Reg + imm operations
            `OPCODE_OP_IMM:
                if (is_shift) controls = {`IMM_X, `SRC_X,  `SHAMT_IMM, `EXEC_SHIFT, `REGD_EXEC, `FLOW_X  };
                else          controls = {`IMM_I, `SRC_RI, `SHAMT_X,   `EXEC_ALU,   `REGD_EXEC, `FLOW_X  };
            // Reg + reg operations
            `OPCODE_OP:
                if (is_shift) controls = {`IMM_X, `SRC_X,  `SHAMT_REG, `EXEC_SHIFT, `REGD_EXEC, `FLOW_X  };
                else          controls = {`IMM_X, `SRC_RR, `SHAMT_X,   `EXEC_ALU,   `REGD_EXEC, `FLOW_X  };
            // Load upper immediate
            `OPCODE_LUI:      controls = {`IMM_U, `SRC_X,  `SHAMT_X,   `EXEC_X,     `REGD_IMM,  `FLOW_X  };
            // Add upper imm to PC
            `OPCODE_AUIPC:    controls = {`IMM_U, `SRC_PI, `SHAMT_X,   `EXEC_ADD,   `REGD_EXEC, `FLOW_X  };
            // Load
            `OPCODE_LOAD:     controls = {`IMM_I, `SRC_RI, `SHAMT_X,   `EXEC_ADD,   `REGD_MEM,  `FLOW_X  };
            // Store
            `OPCODE_STORE:    controls = {`IMM_S, `SRC_RI, `SHAMT_X,   `EXEC_ADD,   `REGD_X,    `FLOW_X  };
            // Jump and link
            `OPCODE_JAL:      controls = {`IMM_J, `SRC_PI, `SHAMT_X,   `EXEC_ADD,   `REGD_PC4,  `FLOW_JMP};
            `OPCODE_JALR:     controls = {`IMM_I, `SRC_RI, `SHAMT_X,   `EXEC_ADD,   `REGD_PC4,  `FLOW_JMP};
            // Branch
            `OPCODE_BRANCH:
                case (funct3)
                    `BEQ:     controls = {`IMM_B, `SRC_RR, `SHAMT_X,   `EXEC_SUB,   `REGD_X,    `FLOW_BZ };
                    `BNE:     controls = {`IMM_B, `SRC_RR, `SHAMT_X,   `EXEC_SUB,   `REGD_X,    `FLOW_BNZ};
                    `BLT:     controls = {`IMM_B, `SRC_RR, `SHAMT_X,   `EXEC_SLT,   `REGD_X,    `FLOW_BNZ};
                    `BGE:     controls = {`IMM_B, `SRC_RR, `SHAMT_X,   `EXEC_SLT,   `REGD_X,    `FLOW_BZ };
                    `BLTU:    controls = {`IMM_B, `SRC_RR, `SHAMT_X,   `EXEC_SLTU,  `REGD_X,    `FLOW_BNZ};
                    `BGEU:    controls = {`IMM_B, `SRC_RR, `SHAMT_X,   `EXEC_SLTU,  `REGD_X,    `FLOW_BZ };
                    default:  controls = {`IMM_X, `SRC_X,  `SHAMT_X,   `EXEC_X,     `REGD_X,    `FLOW_X  };
                endcase
            // Invalid
            default:          controls = {`IMM_X, `SRC_X,  `SHAMT_X,   `EXEC_X,     `REGD_X,    `FLOW_X  };
        endcase
    end
    
endmodule
