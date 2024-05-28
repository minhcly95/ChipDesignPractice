module trans_code(
    input logic trans,
    output logic[1:0] h_trans
);
    assign h_trans = trans ? 2'b10 : 2'b00;
endmodule
