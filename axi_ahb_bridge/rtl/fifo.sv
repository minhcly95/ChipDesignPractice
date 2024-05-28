// FIFO with multi-bit empty and full signals
module fifo #(
    parameter int Width = 32,
    parameter int Depth = 8,    // Must be a power of 2
    parameter int FullSignals = 1,
    parameter int EmptySignals = 1
)(
    input logic clk, reset_n,
    input logic[Width-1:0] data_in,
    output logic[Width-1:0] data_out,
    input logic push, pop,
    output logic[FullSignals-1:0] full,
    output logic[EmptySignals-1:0] empty
);
    localparam int DepthN = $clog2(Depth);

    logic[Width-1:0] regs[Depth];
    logic[DepthN-1:0] r_ptr, w_ptr;
    logic[DepthN:0] r_cnt, w_cnt;   // Counter = {lap, pointer}

    logic[DepthN-1:0] ptr_diff;
    logic[EmptySignals-1:-FullSignals+1] ptr_diff_onehot;

    logic same_lap, full_base, empty_base;

    // Aliases
    assign r_ptr = r_cnt[DepthN-1:0];
    assign w_ptr = w_cnt[DepthN-1:0];

    // Register logic
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            r_cnt <= 0;
            w_cnt <= 0;
        end
        else begin
            // Push
            if (push & ~full[0]) begin
                regs[w_ptr] <= data_in;
                w_cnt <= w_cnt + 1;
            end
            // Pop
            if (pop & ~empty[0]) begin
                r_cnt <= r_cnt + 1;
            end
        end
    end

    // Read logic
    assign data_out = regs[r_ptr];

    // Pointer difference
    assign ptr_diff = w_ptr - r_ptr;
    always_comb begin
        for (int i = -FullSignals+1; i <= EmptySignals-1; i++)
            ptr_diff_onehot[i] = (ptr_diff == i[DepthN-1:0]);
    end

    // Full/empty logic
    assign same_lap = r_cnt[DepthN] == w_cnt[DepthN];
    assign full_base = ptr_diff_onehot[0] & ~same_lap;
    assign empty_base = ptr_diff_onehot[0] & same_lap;

    generate
        assign full[0] = full_base;
        for (genvar i = 1; i < FullSignals; i++)
            assign full[i] = full_base | (|ptr_diff_onehot[-1:-i]);
    endgenerate

    generate
        assign empty[0] = empty_base;
        for (genvar i = 1; i < EmptySignals; i++)
            assign empty[i] = empty_base | (|ptr_diff_onehot[i:1]);
    endgenerate
endmodule
