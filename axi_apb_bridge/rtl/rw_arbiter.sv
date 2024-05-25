module rw_arbiter(
    input logic clk,
    input logic reset_n,
    input logic w_req,
    input logic r_req,
    input logic done,
    output logic w_grant,
    output logic r_grant
);
    typedef enum bit[1:0] { S_IDLE, S_READ, S_WRITE } state_e;
    
    state_e state, next_state;

    // State FF
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // Next state logic
    always_comb begin
        case (state)
            S_IDLE: begin
                if (w_req) next_state = S_WRITE;
                else if (r_req) next_state = S_READ;
                else next_state = S_IDLE;
            end
            S_READ: begin
                if (done) begin
                    if (w_req) next_state = S_WRITE;
                    else if (r_req) next_state = S_READ;
                    else next_state = S_IDLE;
                end
                else
                    next_state = S_READ;
            end
            S_WRITE: begin
                if (done) begin
                    if (r_req) next_state = S_READ;
                    else if (w_req) next_state = S_WRITE;
                    else next_state = S_IDLE;
                end
                else
                    next_state = S_WRITE;
            end
            default: next_state = S_IDLE;   // Should not happen
        endcase
    end

    // Output logic
    always_comb begin
        w_grant = 0;
        r_grant = 0;
        case (state)
            S_READ: r_grant = 1;
            S_WRITE: w_grant = 1;
            default: ;
        endcase
    end
endmodule
