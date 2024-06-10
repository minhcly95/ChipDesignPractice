`define NOP 32'b000000000000_00000_000_00000_0010011

module fd_reg(
    input logic clk,
    input logic reset,
    input logic halted,
    input logic stall,
    // Fetch
    input logic[31:0] instr_f,
    input logic[31:0] pc_f,
    input logic[31:0] pc4_f,
    // Decode
    output logic[31:0] instr_d,
    output logic[31:0] pc_d,
    output logic[31:0] pc4_d
);
    // FF with reset
    floper #(32,`NOP) floper(
        clk, reset, ~halted & ~stall,
        instr_f,
        instr_d
    );

    // FF without reset
    flope #(64) flope(
        clk, ~halted & ~stall,
        {pc_f, pc4_f},
        {pc_d, pc4_d}
    );
endmodule
