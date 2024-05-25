module r_req_logic(
    input logic ar_empty,
    input logic ar_al_empty,
    input logic r_full,
    input logic r_al_full,
    input logic r_grant,
    output logic r_req
);
    assign r_req = r_grant ?
        (~ar_al_empty & ~r_al_full) :
        (~ar_empty & ~r_full);
endmodule
