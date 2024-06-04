// Flip-flop with enabled async reset
module floper #(
    parameter int Width = 1,
    parameter logic[Width-1:0] ResetValue = 0
)(
    input logic clk,
    input logic reset,
    input logic en,
    input logic[Width-1:0] d,
    output logic[Width-1:0] q
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            q <= ResetValue;
        else if (en)
            q <= d; 
    end
endmodule
