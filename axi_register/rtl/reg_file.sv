// Register file
module reg_file #(
    parameter int NumWords = 64,
    localparam int OffsetWidth = $clog2(NumWords)
)(
    input logic clk, reset_n,
    // Write port
    input logic[OffsetWidth-1:0] wa,
    input logic[31:0] wd,
    input logic[3:0] we,
    // Read port
    input logic[OffsetWidth-1:0] ra,
    output logic[31:0] rd
);
    logic[31:0] regs[NumWords];

    // Register write
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            // Reset
            for (int i = 0; i < NumWords; i++)
                regs[i] <= '0;
        end
        else begin
            if (we[0]) regs[wa][7:0] <= wd[7:0];
            if (we[1]) regs[wa][15:8] <= wd[15:8];
            if (we[2]) regs[wa][23:16] <= wd[23:16];
            if (we[3]) regs[wa][31:24] <= wd[31:24];
        end
    end

    // Register read
    assign rd = regs[ra];
endmodule
