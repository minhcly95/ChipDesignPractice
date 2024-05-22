// Produces the write enabled for each byte lane
module lane_enabler(
    input logic[1:0] byte_offset,
    input logic w_error, w_req_in,
    input logic[3:0] w_strb,
    output logic[3:0] reg_we
);
    logic[3:0] offset_enb;
    logic w_enb;

    // Active lanes based on byte_offset
    always_comb begin
        case (byte_offset)
            2'b00: offset_enb = 4'b1111;
            2'b01: offset_enb = 4'b1110;
            2'b10: offset_enb = 4'b1100;
            2'b11: offset_enb = 4'b1000;
        endcase
    end

    // Global write enabled
    assign w_enb = ~w_error & w_req_in;

    // Lane enabled
    assign reg_we = {4{w_enb}} & offset_enb & w_strb;

endmodule
