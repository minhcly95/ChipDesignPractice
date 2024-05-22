// Init AHB
task axi_init();
    aw_valid = 0;
    w_valid = 0;
    b_ready = 0;
    ar_valid = 0;
    r_ready = 0;
endtask

// Send write request
task automatic axi_send_aw(logic[31:0] addr);
    aw_addr = addr;
    aw_valid = 1;
    at_clk();
    while (~aw_ready)
        at_clk();
    tick();
    aw_valid = 0;
endtask

// Send write data
task automatic axi_send_w(logic[31:0] data, logic[3:0] strb = 4'b1111);
    w_data = data;
    w_strb = strb;
    w_valid = 1;
    at_clk();
    while (~w_ready)
        at_clk();
    tick();
    w_valid = 0;
endtask

// Send read request
task automatic axi_send_ar(logic[31:0] addr);
    ar_addr = addr;
    ar_valid = 1;
    at_clk();
    while (~ar_ready)
        at_clk();
    tick();
    ar_valid = 0;
endtask

// Expect write response
task automatic axi_recv_b(logic[1:0] resp = 2'b00);
    b_ready = 1;
    at_clk();
    while (~b_valid)
        at_clk();
    if (b_resp !== resp) begin
        $display("[%6t] Error: received write response does not match", $time);
        $display("        received = %2b, expected = %2b", b_resp, resp);
    end
    tick();
    b_ready = 0;
endtask

// Expect read data
task automatic axi_recv_r(logic[31:0] data);
    r_ready = 1;
    at_clk();
    while (~r_valid)
        at_clk();
    if (r_data !== data) begin
        $display("[%6t] Error: received read data does not match", $time);
        $display("        received = %8h, expected = %8h", r_data, data);
    end
    tick();
    r_ready = 0;
endtask

// Expect read error
task automatic axi_recv_r_resp(logic[1:0] resp);
    r_ready = 1;
    at_clk();
    while (~r_valid)
        at_clk();
    if (r_resp !== resp) begin
        $display("[%6t] Error: received read response does not match", $time);
        $display("        received = %2b, expected = %2b", r_resp, resp);
    end
    tick();
    r_ready = 0;
endtask

// Skip write response
task automatic axi_skip_b();
    b_ready = 1;
    at_clk();
    while (~b_valid)
        at_clk();
    tick();
    b_ready = 0;
endtask

// Skip read response
task automatic axi_skip_r();
    r_ready = 1;
    at_clk();
    while (~r_valid)
        at_clk();
    tick();
    r_ready = 0;
endtask

// Send write request and data
task automatic axi_write(logic[31:0] addr, logic[31:0] data, logic[3:0] strb = 4'b1111);
    fork
        axi_send_aw(addr);
        axi_send_w(data, strb);
    join
endtask

// Check if all transactions have been processed
task automatic axi_complete();
    assert(~b_valid);
    assert(~r_valid);
endtask

