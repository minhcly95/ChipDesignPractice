module mw_reg(
    input logic clk,
    input logic reset,
    input logic halted,
    // Memory
    input logic rd_valid_m,
    input logic[4:0] rd_m,
    input logic[31:0] reg_d_m,
    // Write-back
    output logic rd_valid_w,
    output logic[4:0] rd_w,
    output logic[31:0] reg_d_w
);
    // FF with reset
    floper #(1) floper(
        clk, reset, ~halted,
        rd_valid_m,
        rd_valid_w
    );

    // FF without reset
    flope #(37) flope(
        clk, ~halted,
        {rd_m, reg_d_m},
        {rd_w, reg_d_w}
    );
endmodule
