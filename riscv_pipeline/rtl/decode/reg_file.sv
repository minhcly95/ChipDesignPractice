module reg_file(
    input logic clk,
    input logic[4:0] a1,
    output logic[31:0] rd1,
    input logic[4:0] a2,
    output logic[31:0] rd2,
    input logic[4:0] a3,
    input logic[31:0] wd3,
    input logic we3
);
    logic[31:0] regs[32];
    
    // Write port (write on falling edges)
    always_ff @(negedge clk) begin
        if (we3 && a3 != 5'h0)
            regs[a3] <= wd3;
    end

    // Read ports
    assign rd1 = (a1 == 5'h0) ? 32'h0 : regs[a1];
    assign rd2 = (a2 == 5'h0) ? 32'h0 : regs[a2];
endmodule
