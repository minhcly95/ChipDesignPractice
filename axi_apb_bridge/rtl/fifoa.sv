// FIFO with almost empty and almost full signals
module fifoa #(
    parameter int Width = 32,
    parameter int Depth = 8     // Must be a power of 2
)(
    input logic clk, reset_n,
    input logic[Width-1:0] data_in,
    output logic[Width-1:0] data_out,
    input logic push, pop,
    output logic full, almost_full,
    output logic empty, almost_empty
);
    localparam int DepthN = $clog2(Depth);

    logic[Width-1:0] regs[Depth];
    logic[DepthN-1:0] r_ptr, w_ptr;
    logic[DepthN:0] r_cnt, w_cnt;   // Counter = {lap, pointer}
    logic[DepthN-1:0] r_ptr_plus_1, r_ptr_minus_1;

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
            if (push & ~full) begin
                regs[w_ptr] <= data_in;
                w_cnt <= w_cnt + 1;
            end
            // Pop
            if (pop & ~empty) begin
                r_cnt <= r_cnt + 1;
            end
        end
    end

    // Read logic
    assign data_out = regs[r_ptr];

    // Full/empty logic
    always_comb begin
        full = 0;
        empty = 0;
        if (r_ptr == w_ptr) begin
            if (r_cnt[DepthN] == w_cnt[DepthN])
                // Read and write pointer on the same lap -> empty
                empty = 1;
            else
                // Read and write pointer on different laps -> full
                full = 1;
        end
    end

    // Almost empty logic
    assign r_ptr_plus_1 = r_ptr + 1;
    assign almost_empty = empty | (r_ptr_plus_1 == w_ptr);

    // Almost full logic
    assign r_ptr_minus_1 = r_ptr - 1;
    assign almost_full = full | (r_ptr_minus_1 == w_ptr);

endmodule
