module r_req_logic(
    input logic[1:0] ar_empty,
    input logic[2:0] r_full,
    input logic r_phase1,
    input logic r_phase2,
    output logic r_req
);
    logic ar, r;

    assign ar = r_phase1 ? ar_empty[1] : ar_empty[0];
    always_comb begin
        unique case ({r_phase1, r_phase2})
            2'b00:        r = r_full[0];
            2'b01, 2'b10: r = r_full[1];
            2'b11:        r = r_full[2];
        endcase
    end

    assign r_req = ~ar & ~r;
endmodule
