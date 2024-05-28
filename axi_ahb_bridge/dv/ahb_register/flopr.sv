// Register with async reset
module flopr #(
    parameter int Width = 1,
    parameter logic[Width-1:0] ResetValue = '0
)(
    input logic clk, reset_n,
    input logic[Width-1:0] d,
    output logic[Width-1:0] q
);
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) q <= ResetValue;
        else q <= d;
    end
endmodule
