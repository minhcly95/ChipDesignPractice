module mux4 #(
    parameter int Width = 1
)(
    input logic[Width-1:0] a0,
    input logic[Width-1:0] a1,
    input logic[Width-1:0] a2,
    input logic[Width-1:0] a3,
    input logic[1:0] sel,
    output logic[Width-1:0] y
);
    always_comb
        case (sel)
            2'h0: y = a0;
            2'h1: y = a1;
            2'h2: y = a2;
            2'h3: y = a3;
        endcase
endmodule
