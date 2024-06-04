module halt_reg(
    input logic clk,
    input logic reset,
    input logic mem_en,
    input logic system,
    input logic misaligned_pc,
    input logic misaligned_addr,
    input logic unhalt,
    output logic halted
);
    logic halt_set;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            halted <= 0;
        else begin
            if (unhalt)
                halted <= 0;
            else if (halt_set)
                halted <= 1;
        end
    end

    assign halt_set = system | misaligned_pc | (mem_en & misaligned_addr);
endmodule
