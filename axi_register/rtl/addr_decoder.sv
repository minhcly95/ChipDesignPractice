// Decode AxADDR into components and check if the addr is in range
module addr_decoder #(
    parameter logic[31:0] BaseAddr = 32'h0000_0000,
    parameter int OffsetWidth = 6
)(
    input logic[31:0] addr,
    output logic[OffsetWidth-1:0] word_offset,
    output logic[1:0] byte_offset,
    output logic out_of_range
);
    localparam int AddressWidth = OffsetWidth + 2;

    // The spec requires addr to be aligned,
    // so we also assume so
    logic[31:AddressWidth] addr_tag;

    assign {addr_tag, word_offset, byte_offset} = addr;
    assign out_of_range = (addr_tag != BaseAddr[31:AddressWidth]);
endmodule
