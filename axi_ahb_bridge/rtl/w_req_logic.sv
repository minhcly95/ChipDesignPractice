module w_req_logic(
    input logic[1:0] aw_empty,
    input logic[1:0] w_empty,
    input logic[2:0] b_full,
    input logic w_phase1,
    input logic w_phase2,
    output logic w_req
);
    logic aw, w, b;

    assign aw = w_phase1 ? aw_empty[1] : aw_empty[0];
    assign w = w_phase1 ? w_empty[1] : w_empty[0];
    always_comb begin
        unique case ({w_phase1, w_phase2})
            2'b00:        b = b_full[0];
            2'b01, 2'b10: b = b_full[1];
            2'b11:        b = b_full[2];
        endcase
    end

    assign w_req = ~aw & ~w & ~b;
endmodule
