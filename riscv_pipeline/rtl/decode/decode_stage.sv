module decode_stage(
    input logic clk,
    input logic halted,
    // Pipeline input
    input logic[31:0] instr_d,
    input logic[31:0] pc_d,
    // Pipeline output
    output logic[2:0] mem_size_d,
    output logic mem_write_d,
    output logic mem_read_d,
    output logic rd_valid_d,
    output logic[1:0] exec_sel_d,
    output logic[2:0] flow_ctrl_d,
    output logic[3:0] alsu_func_d,
    output logic[1:0] src_sel_d,
    output logic[3:0] fwd_sel_d,
    output logic[4:0] rd_d,
    output logic[31:0] reg_a_d,
    output logic[31:0] reg_b_d,
    output logic[31:0] imm_d,
    output logic[31:0] pc_imm_d,
    // To Fetch
    output logic jump_d,
    // From Write-back
    input logic[4:0] rd_w,
    input logic rd_valid_w,
    input logic[31:0] reg_d_w,
    // To Hazard Unit
    input logic[4:0] rd_e,
    input logic rd_valid_e,
    input logic[4:0] rd_m,
    input logic rd_valid_m,
    input logic mem_read_e,
    // Pipeline control
    output logic stall,
    input logic flush,
    // Exception
    output logic system
);
    // ----------------- Signals ---------------------
    logic[4:0] rs1;
    logic[4:0] rs2;

    logic[2:0] imm_sel;
    logic[1:0] rs_valid;

    logic mem_write_pre;
    logic mem_read_pre;
    logic rd_valid_pre;
    logic[2:0] flow_ctrl_pre;

    // ---------------- Structure --------------------
    // Decomposer
    decomposer decomposer(instr_d, rd_d, rs1, rs2);
    
    // Register file
    reg_file reg_file(
        .clk(clk),
        .a1(rs1),
        .rd1(reg_a_d),
        .a2(rs2),
        .rd2(reg_b_d),
        .a3(rd_w),
        .wd3(reg_d_w),
        .we3(~halted & rd_valid_w)
    );

    // Imm decoder
    imm_dec imm_dec(instr_d, imm_sel, imm_d);

    // PCImm adder
    pc_imm_adder pc_imm_adder(pc_d, imm_d, pc_imm_d);

    // Controller
    controller controller(
        .opcode(instr_d[6:0]),
        .funct3(instr_d[14:12]),
        .funct75(instr_d[30]),
        .rs_valid(rs_valid),
        .rd_valid(rd_valid_pre),
        .imm_sel(imm_sel),
        .src_sel(src_sel_d),
        .alsu_func(alsu_func_d),
        .exec_sel(exec_sel_d),
        .jump_d(jump_d),
        .flow_ctrl(flow_ctrl_pre),
        .mem_write(mem_write_pre),
        .mem_read(mem_read_pre),
        .mem_size(mem_size_d),
        .system(system)
    );

    // Hazard unit
    hazard_unit hazard_unit(
        .rs1(rs1),
        .rs2(rs2),
        .rs_valid(rs_valid),
        .rd_e(rd_e),
        .rd_valid_e(rd_valid_e),
        .rd_m(rd_m),
        .rd_valid_m(rd_valid_m),
        .mem_read_e(mem_read_e),
        .fwd_sel(fwd_sel_d),
        .stall(stall)
    );

    // NOP mask
    mux2 #(6) nop_mask(
        {mem_read_pre, mem_write_pre, rd_valid_pre, flow_ctrl_pre},
        6'd0,
        stall | flush,
        {mem_read_d, mem_write_d, rd_valid_d, flow_ctrl_d}
    );

endmodule
