module resp_code(
    input logic error,
    output logic[1:0] resp
);
    assign resp = error ? 2'b11 : 2'b00;
endmodule
