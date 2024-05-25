// An AXI-APB bridge
module axi_apb_bridge #(
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
    // APB master interface
    input logic p_clk_en,
    output logic[31:0] p_addr,
    output logic p_sel,
    output logic p_enable,
    output logic p_write,
    output logic[31:0] p_wdata,
    input logic[31:0] p_rdata,
    input logic p_ready,
    input logic p_slverr
);
    // FIFO signals
    logic aw_full, aw_empty, aw_al_empty;
    logic[31:0] aw_addr_out;

    logic w_full, w_empty, w_al_empty;
    logic[31:0] w_data_out;

    logic b_full, b_al_full, b_empty;
    logic[1:0] resp_in;

    logic ar_full, ar_empty, ar_al_empty;
    logic[31:0] ar_addr_out;

    logic r_full, r_al_full, r_empty;
    logic[31:0] r_data_in;

    // Arbiter signals
    logic req, w_req, r_req;
    logic w_grant, r_grant;
    logic done, w_done, r_done;

    // FIFOs
    fifoa #(32, FifoDepth) aw_fifo(
        a_clk, a_reset_n,
        aw_addr, aw_addr_out,
        aw_valid, w_done,
        aw_full, ,
        aw_empty, aw_al_empty
    );
    fifoa #(32, FifoDepth) w_fifo(
        a_clk, a_reset_n,
        w_data, w_data_out,
        w_valid, w_done,
        w_full, ,
        w_empty, w_al_empty
    );
    fifoa #(2, FifoDepth) b_fifo(
        a_clk, a_reset_n,
        resp_in, b_resp,
        w_done, b_ready,
        b_full, b_al_full,
        b_empty,
    );
    fifoa #(32, FifoDepth) ar_fifo(
        a_clk, a_reset_n,
        ar_addr, ar_addr_out,
        ar_valid, r_done,
        ar_full, ,
        ar_empty, ar_al_empty
    );
    fifoa #(34, FifoDepth) r_fifo(
        a_clk, a_reset_n,
        {r_data_in, resp_in}, {r_data, r_resp},
        r_done, r_ready,
        r_full, r_al_full,
        r_empty,
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
        aw_al_empty,
        w_empty,
        w_al_empty,
        b_full,
        b_al_full,
        w_grant,
        w_req
    );
    r_req_logic r_req_logic(
        ar_empty,
        ar_al_empty,
        r_full,
        r_al_full,
        r_grant,
        r_req
    );
    assign req = w_req | r_req;

    // Arbiter logic
    rw_arbiter arbiter(a_clk, a_reset_n, p_clk_en, w_req, r_req, done, w_grant, r_grant);
    assign w_done = done & w_grant;
    assign r_done = done & r_grant;

    // APB interface
    apb_controller apb_ctrl(
        a_clk, a_reset_n,
        req,
        done,
        p_clk_en,
        p_sel,
        p_enable,
        p_ready
    );
    resp_code resp_code(p_slverr, resp_in);
    assign p_write = w_grant;
    assign p_wdata = w_data_out;
    assign r_data_in = p_rdata;
    assign p_addr = r_grant ? ar_addr_out : aw_addr_out;

endmodule
