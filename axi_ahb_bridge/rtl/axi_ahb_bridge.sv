// An AXI-AHB bridge
module axi_ahb_bridge #(
    parameter int FifoDepth = 8     // Depth of the FIFOs, must be a power of 2
)(
    input logic a_clk,
    input logic a_reset_n,
    // AXI slave interface
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
    output logic[1:0] r_resp,
    // AHB master interface
    input logic h_clk_en,
    output logic[31:0] h_addr,
    output logic[1:0] h_trans,
    output logic h_write,
    output logic[31:0] h_wdata,
    output logic[3:0] h_wstrb,
    input logic[31:0] h_rdata,
    input logic h_ready,
    input logic h_resp
);
    // FIFO signals
    logic aw_full;
    logic[1:0] aw_empty;
    logic[31:0] aw_addr_out;

    logic w_full;
    logic[1:0] w_empty;
    logic[31:0] w_data_out;
    logic[3:0] w_strb_out;

    logic[2:0] b_full;
    logic b_empty;
    logic[1:0] resp_in;

    logic ar_full;
    logic[1:0] ar_empty;
    logic[31:0] ar_addr_out;

    logic[2:0] r_full;
    logic r_empty;
    logic[31:0] r_data_in;

    // Other signals
    logic next;
    logic w_req, r_req;
    logic w_phase1, r_phase1, w_phase2, r_phase2;
    logic trans;
    logic w_push, w_pop, r_push, r_pop;

    // FIFOs
    fifo #(32, FifoDepth, .EmptySignals(2)) aw_fifo(
        a_clk, a_reset_n,
        aw_addr, aw_addr_out,
        aw_valid, w_pop,
        aw_full, aw_empty
    );
    fifo #(36, FifoDepth, .EmptySignals(2)) w_fifo(
        a_clk, a_reset_n,
        {w_data, w_strb}, {w_data_out, w_strb_out},
        w_valid, w_pop,
        w_full, w_empty
    );
    fifo #(2, FifoDepth, .FullSignals(3)) b_fifo(
        a_clk, a_reset_n,
        resp_in, b_resp,
        w_push, b_ready,
        b_full, b_empty
    );
    fifo #(32, FifoDepth, .EmptySignals(2)) ar_fifo(
        a_clk, a_reset_n,
        ar_addr, ar_addr_out,
        ar_valid, r_pop,
        ar_full, ar_empty
    );
    fifo #(34, FifoDepth, .FullSignals(3)) r_fifo(
        a_clk, a_reset_n,
        {r_data_in, resp_in}, {r_data, r_resp},
        r_push, r_ready,
        r_full, r_empty
    );

    // Handshake logic
    assign aw_ready = ~aw_full;
    assign w_ready = ~w_full;
    assign b_valid = ~b_empty;
    assign ar_ready = ~ar_full;
    assign r_valid = ~r_empty;

    // Request logic
    w_req_logic w_req_logic(
        aw_empty,
        w_empty,
        b_full,
        w_phase1,
        w_phase2,
        w_req
    );
    r_req_logic r_req_logic(
        ar_empty,
        r_full,
        r_phase1,
        r_phase2,
        r_req
    );

    // Arbiter logic
    rw_arbiter arbiter(a_clk, a_reset_n, h_clk_en, h_ready, w_req, r_req, w_phase1, r_phase1);

    // Pipeline registers
    floper #(37) w_flop(a_clk, a_reset_n, next, {w_data_out, w_strb_out, w_phase1}, {h_wdata, h_wstrb, w_phase2});
    floper #(1) r_flop(a_clk, a_reset_n, next, r_phase1, r_phase2);

    // Pipeline logic
    assign next = h_clk_en & h_ready;
    assign w_pop = next & w_phase1;
    assign w_push = next & w_phase2;
    assign r_pop = next & r_phase1;
    assign r_push = next & r_phase2;

    // AHB interface
    assign trans = w_phase1 | r_phase1;
    trans_code trans_code(trans, h_trans);
    resp_code resp_code(h_resp, resp_in);
    assign h_write = w_phase1;
    assign r_data_in = h_rdata;
    assign h_addr = r_phase1 ? ar_addr_out : aw_addr_out;

endmodule
