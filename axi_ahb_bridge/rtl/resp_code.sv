module resp_code(
    input logic h_resp,
    output logic[1:0] resp_in
);
    assign resp_in = h_resp ? 2'b10 : 2'b00;
endmodule
