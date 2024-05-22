// A simple module that stores data from AXI
module axi_register #(
    parameter int NumWords = 64,                    // Should be a power of 2
    parameter logic[31:0] BaseAddr = 32'h0000_0000, // Should be aligned with NumWords
    parameter int FifoDepth = 4                     // Depth for the FIFOs
)(
    input logic a_clk,
    input logic a_reset_n,
    // Write request channel
    input logic aw_valid,
    output logic aw_ready,
    input logic[31:0] aw_addr,
    // Write data channel
    input logic w_valid,
    output logic w_ready,
    input logic[31:0] w_data,
    input logic[3:0] w_strb,
    // Write response channel
    output logic b_valid,
    input logic b_ready,
    output logic[1:0] b_resp,
    // Read request channel
    input logic ar_valid,
    output logic ar_ready,
    input logic[31:0] ar_addr,
    // Read response channel
    output logic r_valid,
    input logic r_ready,
    output logic[31:0] r_data,
    output logic[1:0] r_resp
);
    localparam int OffsetWidth = $clog2(NumWords);

    // FIFO signals
    logic aw_full, aw_empty;
    logic[31:0] aw_addr_out;

    logic w_full, w_empty;
    logic[3:0] w_strb_out;

    logic b_full, b_empty;
    logic[1:0] b_resp_in;

    logic ar_full, ar_empty;
    logic[31:0] ar_addr_out;

    logic r_full, r_empty;
    logic[1:0] r_resp_in;

    // Write logic signals
    logic w_req_in, w_error;
    logic[1:0] byte_offset;
    logic[OffsetWidth-1:0] reg_wa;
    logic[31:0] reg_wd;
    logic[3:0] reg_we;

    // Read logic signals
    logic r_req_in, r_error;
    logic[OffsetWidth-1:0] reg_ra;
    logic[31:0] reg_rd;

    // FIFOs
    fifo #(32, FifoDepth) aw_fifo(
        a_clk, a_reset_n,
        aw_addr, aw_addr_out,
        aw_valid, w_req_in,
        aw_full, aw_empty
    );
    fifo #(36, FifoDepth) w_fifo(
        a_clk, a_reset_n,
        {w_data, w_strb}, {reg_wd, w_strb_out},
        w_valid, w_req_in,
        w_full, w_empty
    );
    fifo #( 2, FifoDepth) b_fifo(
        a_clk, a_reset_n,
        b_resp_in, b_resp,
        w_req_in, b_ready,
        b_full, b_empty
    );
    fifo #(32, FifoDepth) ar_fifo(
        a_clk, a_reset_n,
        ar_addr, ar_addr_out,
        ar_valid, r_req_in,
        ar_full, ar_empty
    );
    fifo #(34, FifoDepth) r_fifo(
        a_clk, a_reset_n,
        {reg_rd, r_resp_in}, {r_data, r_resp},
        r_req_in, r_ready,
        r_full, r_empty
    );

    // Handshake logic
    assign aw_ready = ~aw_full;
    assign w_ready = ~w_full;
    assign b_valid = ~b_empty;

    assign ar_ready = ~ar_full;
    assign r_valid = ~r_empty;

    // Request in logic
    assign w_req_in = ~aw_empty & ~w_empty & ~b_full;
    assign r_req_in = ~ar_empty & ~r_full;

    // Components
    addr_decoder #(BaseAddr, OffsetWidth) w_addr_dec(aw_addr_out, reg_wa, byte_offset, w_error);
    lane_enabler lane_enb(byte_offset, w_error, w_req_in, w_strb_out, reg_we);
    resp_code w_resp_code(w_error, b_resp_in);

    addr_decoder #(BaseAddr, OffsetWidth) r_addr_dec(ar_addr_out, reg_ra, , r_error);
    resp_code r_resp_code(r_error, r_resp_in);

    // Register file
    reg_file #(NumWords) regs(a_clk, a_reset_n, reg_wa, reg_wd, reg_we, reg_ra, reg_rd);

endmodule
