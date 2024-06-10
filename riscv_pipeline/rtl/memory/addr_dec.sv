module addr_dec(
    input logic[31:0] addr,
    output logic[1:0] byte_offset,
    output logic[31:0] word_addr
);
    assign byte_offset = addr[1:0];
    assign word_addr = {addr[31:2], 2'b00};
endmodule
