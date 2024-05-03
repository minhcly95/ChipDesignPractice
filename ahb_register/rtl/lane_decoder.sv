// Decode HSIZE and byte offset to get the active byte lanes
module lane_decoder(
    input logic[2:0] h_size,
    input logic[1:0] byte_offset,
    output logic[3:0] active_lanes,
    output logic addr_aligned
);
    typedef enum logic[2:0] { SIZE_BYTE = 0, SIZE_HALFWORD = 1, SIZE_WORD = 2 } size_e;

    always_comb begin
        // Decode lanes based on little-endian order
        active_lanes = 4'b0000;
        addr_aligned = 1;
        case (h_size)
            SIZE_BYTE:
                case (byte_offset)
                    2'h0: active_lanes = 4'b0001;
                    2'h1: active_lanes = 4'b0010;
                    2'h2: active_lanes = 4'b0100;
                    2'h3: active_lanes = 4'b1000;
                endcase
            SIZE_HALFWORD:
                case (byte_offset)
                    2'h0: active_lanes = 4'b0011;
                    2'h2: active_lanes = 4'b1100;
                    default: addr_aligned = 0;  // Error: unaligned
                endcase
            SIZE_WORD:
                case (byte_offset)
                    2'h0: active_lanes = 4'b1111;
                    default: addr_aligned = 0;  // Error: unaligned
                endcase
            default: addr_aligned = 0;  // Error: size wider than bus width
        endcase
    end

    task automatic error();
    endtask
endmodule
