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
`define OPCODE_MISC     7'b00_011_11
`define OPCODE_SYSTEM   7'b11_100_11

`define VALID_D         3'b00_1
`define VALID_AD        3'b01_1
`define VALID_AB        3'b11_0
`define VALID_ABD       3'b11_1
`define VALID_X         3'b00_0

`define IMM_I           3'b000
`define IMM_S           3'b001
`define IMM_U           3'b010
`define IMM_J           3'b100
`define IMM_B           3'b101
`define IMM_X           3'bxxx

`define SRC_RR          2'b00
`define SRC_RI          2'b10
`define SRC_PI          2'b11
`define SRC_X           2'bxx

`define ALSU_F37        {funct75, funct3}
`define ALSU_F3         {1'b0, funct3}
`define ALSU_ADD        4'b0000
`define ALSU_SUB        4'b1000
`define ALSU_SLT        4'b0010
`define ALSU_SLTU       4'b0011
`define ALSU_X          4'bxxxx

`define EXEC_ALSU       2'b00
`define EXEC_IMM        2'b01
`define EXEC_PC4        2'b10
`define EXEC_X          2'bxx

`define FLOW_JD         4'b1000
`define FLOW_JE         4'b0100
`define FLOW_BZ         4'b0010
`define FLOW_BNZ        4'b0011
`define FLOW_X          4'b0000

`define BEQ             3'b000
`define BNE             3'b001
`define BLT             3'b100
`define BGE             3'b101
`define BLTU            3'b110
`define BGEU            3'b111

module controller(
    // Instruction
    input logic[6:0] opcode,
    input logic[2:0] funct3,
    input logic funct75,
    // Controls
    output logic[1:0] rs_valid,
    output logic rd_valid,
    output logic[2:0] imm_sel,
    output logic[1:0] src_sel,
    output logic[3:0] alsu_func,
    output logic[1:0] exec_sel,
    output logic jump_d,
    output logic[2:0] flow_ctrl,
    output logic mem_write,
    output logic mem_read,
    output logic[2:0] mem_size,
    // Exception
    output logic system
);
    logic is_shift;
    logic[17:0] controls;

    assign is_shift = funct3[1:0] == 2'b01;

    assign mem_write = (opcode == `OPCODE_STORE);
    assign mem_read = (opcode == `OPCODE_LOAD);
    assign mem_size = funct3;

    assign {rs_valid, rd_valid, imm_sel, src_sel, alsu_func, exec_sel, jump_d, flow_ctrl} = controls;

    always_comb begin
        system = 0;
        case (opcode)
            // Reg + imm operations
            `OPCODE_OP_IMM:
                if (is_shift) controls = {`VALID_AD,  `IMM_I, `SRC_RI, `ALSU_F37,  `EXEC_ALSU, `FLOW_X  };
                else          controls = {`VALID_AD,  `IMM_I, `SRC_RI, `ALSU_F3,   `EXEC_ALSU, `FLOW_X  };
            // Reg + reg operations
            `OPCODE_OP:       controls = {`VALID_ABD, `IMM_X, `SRC_RR, `ALSU_F37,  `EXEC_ALSU, `FLOW_X  };
            // Load upper immediate
            `OPCODE_LUI:      controls = {`VALID_D,   `IMM_U, `SRC_X,  `ALSU_X,    `EXEC_IMM,  `FLOW_X  };
            // Add upper imm to PC
            `OPCODE_AUIPC:    controls = {`VALID_D,   `IMM_U, `SRC_PI, `ALSU_ADD,  `EXEC_ALSU, `FLOW_X  };
            // Load
            `OPCODE_LOAD:     controls = {`VALID_AD,  `IMM_I, `SRC_RI, `ALSU_ADD,  `EXEC_ALSU, `FLOW_X  };
            // Store
            `OPCODE_STORE:    controls = {`VALID_AB,  `IMM_S, `SRC_RI, `ALSU_ADD,  `EXEC_ALSU, `FLOW_X  };
            // Jump and link
            `OPCODE_JAL:      controls = {`VALID_D,   `IMM_J, `SRC_X,  `ALSU_X,    `EXEC_PC4,  `FLOW_JD };
            `OPCODE_JALR:     controls = {`VALID_AD,  `IMM_I, `SRC_RI, `ALSU_ADD,  `EXEC_PC4,  `FLOW_JE };
            // Branch
            `OPCODE_BRANCH:
                case (funct3)
                    `BEQ:     controls = {`VALID_AB,  `IMM_B, `SRC_RR, `ALSU_SUB,  `EXEC_X,    `FLOW_BZ };
                    `BNE:     controls = {`VALID_AB,  `IMM_B, `SRC_RR, `ALSU_SUB,  `EXEC_X,    `FLOW_BNZ};
                    `BLT:     controls = {`VALID_AB,  `IMM_B, `SRC_RR, `ALSU_SLT,  `EXEC_X,    `FLOW_BNZ};
                    `BGE:     controls = {`VALID_AB,  `IMM_B, `SRC_RR, `ALSU_SLT,  `EXEC_X,    `FLOW_BZ };
                    `BLTU:    controls = {`VALID_AB,  `IMM_B, `SRC_RR, `ALSU_SLTU, `EXEC_X,    `FLOW_BNZ};
                    `BGEU:    controls = {`VALID_AB,  `IMM_B, `SRC_RR, `ALSU_SLTU, `EXEC_X,    `FLOW_BZ };
                    default:  controls = {`VALID_X,   `IMM_X, `SRC_X,  `ALSU_X,    `EXEC_X,    `FLOW_X  };
                endcase
            // Fence (NOP)
            `OPCODE_MISC:     controls = {`VALID_X,   `IMM_X, `SRC_X,  `ALSU_X,    `EXEC_X,    `FLOW_X  };
            // System
            `OPCODE_SYSTEM: begin
                system = 1;   controls = {`VALID_X,   `IMM_X, `SRC_X,  `ALSU_X,    `EXEC_X,    `FLOW_X  };
            end
            // Invalid
            default: begin
                system = 1;   controls = {`VALID_X,   `IMM_X, `SRC_X,  `ALSU_X,    `EXEC_X,    `FLOW_X  };
            end
        endcase
    end
    
endmodule
