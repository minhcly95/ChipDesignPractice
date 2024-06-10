module riscv #(
    parameter logic[31:0] BootVector = 32'h0000_0000
)(
    input logic clk,
    input logic reset,
    output logic halted,
    input logic unhalt,
    // I-mem
    output logic[31:0] i_addr,
    input logic[31:0] i_data,
    // D-mem
    output logic[31:0] d_addr,
    output logic[31:0] d_wdata,
    output logic[3:0] d_wstrb,
    input logic[31:0] d_rdata
);
    // ----------------- Signals ---------------------
    // Fetch
    logic[31:0] instr_f;
    logic[31:0] pc_f;
    logic[31:0] pc4_f;
    // Decode
    logic[31:0] instr_d;
    logic[31:0] pc_d;
    logic[31:0] pc4_d;
    logic[2:0] mem_size_d;
    logic mem_write_d;
    logic mem_read_d;
    logic rd_valid_d;
    logic[1:0] exec_sel_d;
    logic[2:0] flow_ctrl_d;
    logic[3:0] alsu_func_d;
    logic[1:0] src_sel_d;
    logic[3:0] fwd_sel_d;
    logic[4:0] rd_d;
    logic[31:0] reg_a_d;
    logic[31:0] reg_b_d;
    logic[31:0] imm_d;
    logic[31:0] pc_imm_d;
    logic jump_d;
    // Execute
    logic[2:0] mem_size_e;
    logic mem_write_e;
    logic mem_read_e;
    logic rd_valid_e;
    logic[1:0] exec_sel_e;
    logic[2:0] flow_ctrl_e;
    logic[3:0] alsu_func_e;
    logic[1:0] src_sel_e;
    logic[3:0] fwd_sel_e;
    logic[4:0] rd_e;
    logic[31:0] reg_a_e;
    logic[31:0] reg_b_e;
    logic[31:0] imm_e;
    logic[31:0] pc_imm_e;
    logic[31:0] pc_e;
    logic[31:0] pc4_e;
    logic[31:0] exec_res_e;
    logic[31:0] fwd_b_e;
    logic[1:0] pc_sel_e;
    logic[31:0] alsu_res_e;
    // Memory
    logic[2:0] mem_size_m;
    logic mem_write_m;
    logic mem_read_m;
    logic rd_valid_m;
    logic[4:0] rd_m;
    logic[31:0] exec_res_m;
    logic[31:0] fwd_b_m;
    logic[31:0] reg_d_m;
    // Write-back
    logic rd_valid_w;
    logic[4:0] rd_w;
    logic[31:0] reg_d_w;

    // Pipeline control
    logic stall;
    logic flush;

    // Exceptions
    logic system;
    logic misaligned_pc;
    logic misaligned_addr;

    // ---------------- Pipeline ---------------------
    fetch_stage fetch(.*);
    fd_reg fd_reg(.*);

    decode_stage decode(.*);
    de_reg de_reg(.*);

    execute_stage execute(.*);
    em_reg em_reg(.*);

    memory_stage memory(.*);
    mw_reg mw_reg(.*);

    // ------------------ Misc -----------------------
    halt_ctrl halt_ctrl(.*);

endmodule
