module controller_fsm
(
    input logic clk,
    input logic reset_n,
    // Input
    input logic req_in,
    input logic error,
    // Output
    output logic h_readyout,
    output logic h_resp,
    output logic reg_access
);
    typedef enum logic[1:0] { ADDRESS = 0, DATA = 1, ERROR = 2 } state_e;
    state_e state, next_state;

    flopr #(2, ADDRESS) state_flop(clk, reset_n, next_state, state);

    // ------------------ Next state logic ---------------------
    always_comb begin
        case (state)
            ADDRESS:
                if (req_in) next_state = DATA;
                else next_state = ADDRESS;
            DATA:
                if (error) next_state = ERROR;
                else if (req_in) next_state = DATA;
                else next_state = ADDRESS;
            ERROR:
                if (req_in) next_state = DATA;
                else next_state = ADDRESS;
            default:            // Should not happen
                next_state = ADDRESS;
        endcase
    end

    // ------------------- Output logic ------------------------
    always_comb begin
        case (state)
            DATA: begin
                h_readyout = ~error;
                h_resp = error;
                reg_access = ~error;
            end
            ERROR: begin
                h_readyout = 1;
                h_resp = 1;
                reg_access = 0;
            end
            default: begin
                h_readyout = 1;
                h_resp = 0;
                reg_access = 0;
            end
        endcase
    end
endmodule
