module read_shifter(
    input logic[31:0] rdata,
    input logic[3:0] lanes,
    input logic zeroext,
    output logic[31:0] rd
);
    always_comb
        case (lanes)
            // Byte
            4'b0001: rd = zeroext ? {24'h0, rdata[7:0]}   : {{24{rdata[7]}},  rdata[7:0]};
            4'b0010: rd = zeroext ? {24'h0, rdata[15:8]}  : {{24{rdata[15]}}, rdata[15:8]};
            4'b0100: rd = zeroext ? {24'h0, rdata[23:16]} : {{24{rdata[23]}}, rdata[23:16]};
            4'b1000: rd = zeroext ? {24'h0, rdata[31:24]} : {{24{rdata[31]}}, rdata[31:24]};
            // Half-word
            4'b0011: rd = zeroext ? {16'h0, rdata[15:0]}  : {{16{rdata[15]}}, rdata[15:0]};
            4'b1100: rd = zeroext ? {16'h0, rdata[31:16]} : {{16{rdata[31]}}, rdata[31:16]};
            // Word
            4'b1111: rd = rdata;
            // Invalid
            default: rd = 32'hx;
        endcase
endmodule
