module alu_dec(
    input logic[2:0] funct3,
    input logic funct7_5,
    input logic recode,
    output logic[2:0] alu_code
);
    always_comb begin
        if (recode)
            alu_code = funct3 | {2'h0, funct7_5};
        else
            alu_code = funct3;
    end
endmodule
