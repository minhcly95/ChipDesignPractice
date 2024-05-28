// A simple module that stores data from AHB
module ahb_register #(
    parameter int NumWords = 64,                    // Should be a power of 2
    parameter logic[31:0] BaseAddr = 32'h0000_0000  // Should be aligned with NumWords
)(
    input logic h_clk,
    input logic h_reset_n,
    input logic h_sel,
    input logic[1:0] h_trans,
    input logic h_ready,
    input logic[31:0] h_addr,
    input logic h_write,
    input logic[2:0] h_size,
    input logic[3:0] h_wstrb,
    input logic[31:0] h_wdata,
    output logic[31:0] h_rdata,
    output logic h_readyout,
    output logic h_resp
);
    localparam int OffsetWidth = $clog2(NumWords);

    logic req_in;
    logic[OffsetWidth-1:0] word_offset;
    logic[3:0] reg_we;

    logic[31:0] req_addr;
    logic req_write;
    logic[2:0] req_size;

    // Controller
    controller #(NumWords, BaseAddr) ctrl(.clk(h_clk), .reset_n(h_reset_n), .*);

    // Request registers
    floper #(32, 0) req_addr_ff(h_clk, h_reset_n, req_in, h_addr, req_addr);
    floper #(1, 0) req_write_ff(h_clk, h_reset_n, req_in, h_write, req_write);
    floper #(3, 0) req_size_ff(h_clk, h_reset_n, req_in, h_size, req_size);

    // Register file
    reg_file #(NumWords) regs(h_clk, h_reset_n, word_offset, h_wdata, reg_we, h_rdata);

endmodule
