module w_req_logic(
    input logic aw_empty,
    input logic aw_al_empty,
    input logic w_empty,
    input logic w_al_empty,
    input logic b_full,
    input logic b_al_full,
    input logic w_grant,
    output logic w_req
);
    assign w_req = w_grant ?
        (~aw_al_empty & ~w_al_empty & ~b_al_full) :
        (~aw_empty & ~w_empty & ~b_full);
endmodule
