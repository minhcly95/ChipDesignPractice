module resp_code(
    input logic p_slverr,
    output logic[1:0] resp
);
    assign resp = p_slverr ? 2'b10 : 2'b00;
endmodule
