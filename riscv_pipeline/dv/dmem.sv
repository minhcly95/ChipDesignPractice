module dmem(
    input logic clk,
    input logic[31:0] d_addr,
    input logic[31:0] d_wdata,
    input logic[3:0] d_wstrb,
    output logic[31:0] d_rdata
);
    logic[31:0] mem[1024];
    logic[9:0] offset;

    assign offset = d_addr[11:2];
    assign d_rdata = mem[offset];

    always_ff @(posedge clk) begin
        if (d_wstrb[0]) mem[offset][7:0]   <= d_wdata[7:0];
        if (d_wstrb[1]) mem[offset][15:8]  <= d_wdata[15:8];
        if (d_wstrb[2]) mem[offset][23:16] <= d_wdata[23:16];
        if (d_wstrb[3]) mem[offset][31:24] <= d_wdata[31:24];
    end
endmodule
