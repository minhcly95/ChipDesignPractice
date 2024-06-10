module halt_ctrl(
    input logic clk,
    input logic reset,
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

    assign halt_set = system | misaligned_pc | misaligned_addr;
endmodule
