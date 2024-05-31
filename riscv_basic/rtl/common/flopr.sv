// Flip-flop with async reset
module flopr #(
    parameter int Width = 1,
    parameter logic[Width-1:0] ResetValue = 0
)(
    input logic clk,
    input logic reset,
    input logic[Width-1:0] d,
    output logic[Width-1:0] q
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            q <= ResetValue;
        else
            q <= d; 
    end
endmodule
