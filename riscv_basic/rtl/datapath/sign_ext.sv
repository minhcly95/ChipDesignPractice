module sign_ext #(
    parameter int Input = 12
)(
    input logic[Input-1:0] a,
    output logic[31:0] y
);
    localparam int Extend = 32 - Input;
    assign y = {{Extend{a[Input-1]}}, a};
endmodule
