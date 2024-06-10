// Flip-flop with enabled (no reset)
module flope #(
    parameter int Width = 1
)(
    input logic clk,
    input logic en,
    input logic[Width-1:0] d,
    output logic[Width-1:0] q
);
    always_ff @(posedge clk) begin
        if (en)
            q <= d; 
    end
endmodule
