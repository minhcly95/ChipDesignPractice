// Funnel shifter
module shifter (
    input logic[31:0] a,
    input logic[4:0] shamt,
    input logic[1:0] f,
    output logic[31:0] y
);
    logic[63:0] bc;
    logic[4:0] k;
    
    logic[47:0] d4;
    logic[39:0] d3;
    logic[35:0] d2;
    logic[33:0] d1;
    logic[32:0] d0;

    // Funnel input
    always_comb
        case (f)
            2'b00: bc = {a, 32'h0};
            2'b01: bc = {32'h0, a};
            2'b10: bc = {a, 32'h0};
            2'b11: bc = {{32{a[31]}}, a};
        endcase

    // Right shift amount
    assign k = {5{~f[0]}} ^ shamt;

    // Funnel
    assign d4 = k[4] ? bc[63:16] : bc[47:0];
    assign d3 = k[3] ? d4[47:8] : d4[39:0];
    assign d2 = k[2] ? d3[39:4] : d3[35:0];
    assign d1 = k[1] ? d2[35:2] : d2[33:0];
    assign d0 = k[0] ? d1[33:1] : d1[32:0];
    assign y = f[0] ? d0[31:0] : d0[32:1];

endmodule
