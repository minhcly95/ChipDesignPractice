module write_shifter(
    input logic[31:0] wd,
    input logic[3:0] lanes,
    output logic[31:0] wdata
);
    // Reuse old wires to minimize logic
    always_comb
        casez (lanes)
            4'b??10: wdata = { wd[31:16], wd[7:0], wd[7:0] };
            4'b?100: wdata = { wd[15:0], wd[15:0] };
            4'b1000: wdata = { wd[7:0], wd[23:0] };
            default: wdata = wd;
        endcase
endmodule
