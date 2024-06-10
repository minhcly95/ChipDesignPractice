module mux2 #(
    parameter int Width = 1
)(
    input logic[Width-1:0] a0,
    input logic[Width-1:0] a1,
    input logic sel,
    output logic[Width-1:0] y
);
    assign y = sel ? a1 : a0;
endmodule
