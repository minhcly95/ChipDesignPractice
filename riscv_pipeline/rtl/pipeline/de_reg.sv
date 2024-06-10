module de_reg(
    input logic clk,
    input logic reset,
    input logic halted,
    // Decode
    input logic[2:0] mem_size_d,
    input logic mem_write_d,
    input logic mem_read_d,
    input logic rd_valid_d,
    input logic[1:0] exec_sel_d,
    input logic[2:0] flow_ctrl_d,
    input logic[3:0] alsu_func_d,
    input logic[1:0] src_sel_d,
    input logic[3:0] fwd_sel_d,
    input logic[4:0] rd_d,
    input logic[31:0] reg_a_d,
    input logic[31:0] reg_b_d,
    input logic[31:0] imm_d,
    input logic[31:0] pc_imm_d,
    input logic[31:0] pc_d,
    input logic[31:0] pc4_d,
    // Execute
    output logic[2:0] mem_size_e,
    output logic mem_write_e,
    output logic mem_read_e,
    output logic rd_valid_e,
    output logic[1:0] exec_sel_e,
    output logic[2:0] flow_ctrl_e,
    output logic[3:0] alsu_func_e,
    output logic[1:0] src_sel_e,
    output logic[3:0] fwd_sel_e,
    output logic[4:0] rd_e,
    output logic[31:0] reg_a_e,
    output logic[31:0] reg_b_e,
    output logic[31:0] imm_e,
    output logic[31:0] pc_imm_e,
    output logic[31:0] pc_e,
    output logic[31:0] pc4_e
);
    // FF with reset
    floper #(6) floper(
        clk, reset, ~halted,
        {mem_read_d, mem_write_d, rd_valid_d, flow_ctrl_d},
        {mem_read_e, mem_write_e, rd_valid_e, flow_ctrl_e}
    );

    // FF without reset
    flope #(212) flope(
        clk, ~halted,
        {mem_size_d, exec_sel_d, alsu_func_d, src_sel_d, fwd_sel_d, rd_d, reg_a_d, reg_b_d, imm_d, pc_imm_d, pc_d, pc4_d},
        {mem_size_e, exec_sel_e, alsu_func_e, src_sel_e, fwd_sel_e, rd_e, reg_a_e, reg_b_e, imm_e, pc_imm_e, pc_e, pc4_e}
    );
endmodule
