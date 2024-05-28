module controller #(
    parameter int NumWords = 64,
    parameter logic[31:0] BaseAddr = 32'h0000_0000,
    localparam int OffsetWidth = $clog2(NumWords)
)(
    input logic clk,
    input logic reset_n,
    // AHB
    input logic h_sel,
    input logic[1:0] h_trans,
    input logic h_ready,
    output logic h_readyout,
    output logic h_resp,
    input logic[3:0] h_wstrb,
    // Request
    input logic[31:0] req_addr,
    input logic req_write,
    input logic[2:0] req_size,
    // Datapath control
    output logic req_in,
    output logic[OffsetWidth-1:0] word_offset,
    output logic[3:0] reg_we
);
    logic[1:0] byte_offset;
    logic addr_in_range, addr_aligned, error;
    logic reg_access, write_en;
    logic[3:0] active_lanes;

    // Decoders
    addr_decoder #(BaseAddr, OffsetWidth) adec(req_addr, word_offset, byte_offset, addr_in_range);
    lane_decoder ldec(req_size, byte_offset, active_lanes, addr_aligned);

    // Take in request when HSEL, HREADY, and HTRANS = SEQ or NONSEQ
    assign req_in = h_sel & h_ready & h_trans[1];
    // Switch to ERROR state when address is not valid
    assign error = ~(addr_in_range & addr_aligned);

    // State machine
    controller_fsm fsm(clk, reset_n, req_in, error, h_readyout, h_resp, reg_access);

    // Write enabled
    assign write_en = reg_access & req_write;
    assign reg_we = active_lanes & h_wstrb & {4{write_en}};
endmodule
