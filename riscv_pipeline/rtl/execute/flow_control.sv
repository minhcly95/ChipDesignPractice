module flow_control(
    input logic zero,
    input logic[2:0] flow_ctrl,
    output logic[1:0] pc_sel_e,
    output logic flush
);
    logic branch_cond, branch_taken;
    
    assign branch_cond = zero ^ flow_ctrl[0];
    assign branch_taken = branch_cond & flow_ctrl[1];
    assign pc_sel_e = {flow_ctrl[2], branch_taken};
    assign flush = branch_taken | flow_ctrl[2];
endmodule
