`define SIZE_BYTE   2'b00
`define SIZE_HW     2'b01
`define SIZE_WORD   2'b10

module lane_dec(
    input logic[1:0] byte_offset,
    input logic[2:0] mem_size,
    output logic[3:0] lanes
);
    always_comb begin
        case (mem_size[1:0])
            `SIZE_BYTE:
                case (byte_offset)
                    2'h0: lanes = 4'b0001;
                    2'h1: lanes = 4'b0010;
                    2'h2: lanes = 4'b0100;
                    2'h3: lanes = 4'b1000;
                endcase
            `SIZE_HW:
                case (byte_offset)
                    2'h0: lanes = 4'b0011;
                    2'h2: lanes = 4'b1100;
                    default: lanes = 4'b0000;
                endcase
            `SIZE_WORD:
                lanes = (byte_offset == 2'h0) ? 4'b1111 : 4'b0000;
            default: lanes = 4'b0000;
        endcase
    end
endmodule
