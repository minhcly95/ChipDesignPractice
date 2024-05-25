module apb_controller(
    input logic clk,
    input logic reset_n,
    input logic req,
    output logic done,
    input logic p_clk_en,
    output logic p_sel,
    output logic p_enable,
    input logic p_ready
);
    typedef enum bit[1:0] { S_IDLE, S_ADDRESS, S_DATA } state_e;
    
    state_e state, next_state;

    // State FF
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n)
            state <= S_IDLE;
        else if (p_clk_en)
            state <= next_state;
    end

    // Next state logic
    always_comb begin
        case (state)
            S_IDLE: begin
                if (req) next_state = S_ADDRESS;
                else next_state = S_IDLE;
            end
            S_ADDRESS: next_state = S_DATA;
            S_DATA: begin
                if (p_ready) begin
                    if (req) next_state = S_ADDRESS;
                    else next_state = S_IDLE;
                end
                else
                    next_state = S_DATA;
            end
            default: next_state = S_IDLE;   // Should not happen
        endcase
    end

    // Output logic
    always_comb begin
        case (state)
            S_ADDRESS: begin
                p_sel = 1;
                p_enable = 0;
            end
            S_DATA: begin
                p_sel = 1;
                p_enable = 1;
            end
            default: begin
                p_sel = 0;
                p_enable = 0;
            end
        endcase
    end

    // Done logic (only asserted for 1 cycle at the transition)
    assign done = p_clk_en & (state == S_DATA) & p_ready;
endmodule
