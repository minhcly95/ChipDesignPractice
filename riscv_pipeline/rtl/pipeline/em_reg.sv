module em_reg(
    input logic clk,
    input logic reset,
    input logic halted,
    // Execute
    input logic[2:0] mem_size_e,
    input logic mem_write_e,
    input logic mem_read_e,
    input logic rd_valid_e,
    input logic[4:0] rd_e,
    input logic[31:0] exec_res_e,
    input logic[31:0] fwd_b_e,
    // Memory
    output logic[2:0] mem_size_m,
    output logic mem_write_m,
    output logic mem_read_m,
    output logic rd_valid_m,
    output logic[4:0] rd_m,
    output logic[31:0] exec_res_m,
    output logic[31:0] fwd_b_m
);
    // FF with reset
    floper #(3) floper(
        clk, reset, ~halted,
        {mem_read_e, mem_write_e, rd_valid_e},
        {mem_read_m, mem_write_m, rd_valid_m}
    );

    // FF without reset
    flope #(72) flope(
        clk, ~halted,
        {mem_size_e, rd_e, exec_res_e, fwd_b_e},
        {mem_size_m, rd_m, exec_res_m, fwd_b_m}
    );
endmodule
