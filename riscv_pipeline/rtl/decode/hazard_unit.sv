module hazard_unit(
    // Sources
    input logic[4:0] rs1,
    input logic[4:0] rs2,
    input logic[1:0] rs_valid,
    // Destination
    input logic[4:0] rd_e,
    input logic rd_valid_e,
    input logic[4:0] rd_m,
    input logic rd_valid_m,
    // Control
    input logic mem_read_e,
    // Output
    output logic[3:0] fwd_sel,
    output logic stall
);
    always_comb begin
        fwd_sel = 4'b0000;
        stall = 1'b0;
        // Forward from ALUResM (stall if LOAD)
        if (rd_valid_e & rd_e != 5'd0) begin
            fwd_sel[0] = rs_valid[0] & (rs1 == rd_e);
            fwd_sel[1] = rs_valid[1] & (rs2 == rd_e);
            stall = mem_read_e & (fwd_sel[0] | fwd_sel[1]);
        end
        // Forward from RegDW
        if (rd_valid_m & rd_m != 5'd0) begin
            fwd_sel[2] = rs_valid[0] & (rs1 == rd_m);
            fwd_sel[3] = rs_valid[1] & (rs2 == rd_m);
        end
    end
endmodule
