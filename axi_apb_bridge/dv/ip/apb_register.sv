// A simple module that stores data from APB
module apb_register #(
    parameter int NumWords = 64,                // Should be a power of 2
    parameter logic[31:0] BaseAddr = 32'h0      // Should be aligned with NumWords
)(
    input logic p_clk,
    input logic p_reset_n,
    input logic[31:0] p_addr,
    input logic p_sel,
    input logic p_enable,
    input logic p_write,
    input logic[31:0] p_wdata,
    output logic[31:0] p_rdata,
    output logic p_ready,
    output logic p_slverr
);
    localparam AddrWidth = $clog2(NumWords * 4);

    // ---------------- Signal declarations --------------------
    // Registers
    logic[31:0] regs[NumWords];
    // Address decode
    logic[31:AddrWidth] addr_tag;
    logic[AddrWidth-1:2] word_offset;
    logic[1:0] byte_offset;
    logic addr_valid, addr_in_range, addr_aligned;
    // APB
    logic write_en, read_en;
    
    // -------------------- Definitions ------------------------
    // Register write
    always_ff @(posedge p_clk or negedge p_reset_n) begin
        if (~p_reset_n) begin
            // Reset
            for (int i = 0; i < NumWords; i++)
                regs[i] <= '0;
        end
        else begin
            // Write
            if (write_en & addr_valid)
                regs[word_offset] <= p_wdata;
        end
    end

    // Register read
    assign p_rdata = (read_en & addr_valid) ? regs[word_offset] : '0;

    // Address decode
    assign {addr_tag, word_offset, byte_offset} = p_addr;
    assign addr_in_range = (addr_tag == BaseAddr[31:AddrWidth]);
    assign addr_aligned = (byte_offset == '0);
    assign addr_valid = addr_in_range & addr_aligned;

    // APB
    assign write_en = p_sel & p_enable & p_write;
    assign read_en = p_sel & p_enable & ~p_write;
    // No wait states
    assign p_ready = p_sel & p_enable;
    // Raise error when address is invalid
    assign p_slverr = p_sel & p_enable & ~addr_valid;

endmodule
