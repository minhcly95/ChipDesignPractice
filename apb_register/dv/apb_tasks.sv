// Init APB
task apb_init();
    p_sel = 0;
    p_enable = 0;
    p_write = 0;
    p_addr = 0;
    p_wdata = 0;
endtask

// Write data to addr
task apb_write(logic[31:0] addr, logic[31:0] data, bit wait_ready = 1, bit check_ready = 0);
    // Setup
    p_sel = 1;
    p_enable = 0;
    p_write = 1;
    p_addr = addr;
    p_wdata = data;
    after_clk();
    // Access
    p_enable = 1;
    if (wait_ready)
        apb_wait_ready();
    else begin
        at_clk();
        if (check_ready && ~p_ready) begin
            $display("[%6t] Error: slave was not ready", $time);
            $display("        addr = %8h, wdata = %8h", p_addr, p_wdata);
        end
    end
    if (p_slverr) begin
        $display("[%6t] Error: slave raised an error while writing", $time);
        $display("        addr = %8h, wdata = %8h", p_addr, p_wdata);
    end
    tick();
    // Stop
    p_enable = 0;
    p_sel = 0;
endtask

// Write data to addr and expect an error
task apb_write_throw(logic[31:0] addr, logic[31:0] data, bit wait_ready = 1, bit check_ready = 0);
    // Setup
    p_sel = 1;
    p_enable = 0;
    p_write = 1;
    p_addr = addr;
    p_wdata = data;
    after_clk();
    // Access
    p_enable = 1;
    if (wait_ready)
        apb_wait_ready();
    else begin
        at_clk();
        if (check_ready && ~p_ready) begin
            $display("[%6t] Error: slave was not ready", $time);
            $display("        addr = %8h, wdata = %8h", p_addr, p_wdata);
        end
    end
    if (~p_slverr) begin
        $display("[%6t] Error: slave did not raise an error while writing (expecting an error)", $time);
        $display("        addr = %8h, wdata = %8h", p_addr, p_wdata);
    end
    tick();
    // Stop
    p_enable = 0;
    p_sel = 0;
endtask

// Read and return the data from addr
task apb_read(logic[31:0] addr, logic[31:0] data, bit wait_ready = 1, bit check_ready = 0);
    // Setup
    p_sel = 1;
    p_enable = 0;
    p_write = 0;
    p_addr = addr;
    after_clk();
    // Access
    p_enable = 1;
    if (wait_ready)
        apb_wait_ready();
    else begin
        at_clk();
        if (check_ready && ~p_ready) begin
            $display("[%6t] Error: slave was not ready", $time);
            $display("        addr = %8h, rdata = %8h", p_addr, p_rdata);
        end
    end
    if (p_slverr) begin
        $display("[%6t] Error: slave raised an error while reading", $time);
        $display("        addr = %8h, rdata = %8h", p_addr, p_rdata);
    end
    else
        data = p_rdata;
    tick();
    // Stop
    p_enable = 0;
    p_sel = 0;
endtask

// Read and check data from addr
task apb_read_check(logic[31:0] addr, logic[31:0] data, bit wait_ready = 1, bit check_ready = 0);
    // Setup
    p_sel = 1;
    p_enable = 0;
    p_write = 0;
    p_addr = addr;
    after_clk();
    // Access
    p_enable = 1;
    if (wait_ready)
        apb_wait_ready();
    else begin
        at_clk();
        if (check_ready && ~p_ready) begin
            $display("[%6t] Error: slave was not ready", $time);
            $display("        addr = %8h, rdata = %8h", p_addr, p_rdata);
        end
    end
    if (p_slverr) begin
        $display("[%6t] Error: slave raised an error while reading", $time);
        $display("        addr = %8h, rdata = %8h", p_addr, p_rdata);
    end
    else if (p_rdata !== data) begin
        $display("[%6t] Error: received data does not match", $time);
        $display("        addr = %8h, rdata = %8h, expected = %8h", p_addr, p_rdata, data);
    end
    tick();
    // Stop
    p_enable = 0;
    p_sel = 0;
endtask

// Read and expect an error
task apb_read_throw(logic[31:0] addr, bit wait_ready = 1, bit check_ready = 0);
    // Setup
    p_sel = 1;
    p_enable = 0;
    p_write = 0;
    p_addr = addr;
    after_clk();
    // Access
    p_enable = 1;
    if (wait_ready)
        apb_wait_ready();
    else begin
        at_clk();
        if (check_ready && ~p_ready) begin
            $display("[%6t] Error: slave was not ready", $time);
            $display("        addr = %8h, rdata = %8h", p_addr, p_rdata);
        end
    end
    if (~p_slverr) begin
        $display("[%6t] Error: slave did not raise an error while reading (expecting an error)", $time);
        $display("        addr = %8h, rdata = %8h", p_addr, p_rdata);
    end
    tick();
    // Stop
    p_enable = 0;
    p_sel = 0;
endtask

// Wait until p_ready is high at clk (complain if wait for too long)
task automatic apb_wait_ready(int max_clk = 1000);
    int i;

    at_clk();
    i = 0;
    while (~p_ready && i < max_clk) begin
        i++; 
        at_clk();
    end
    if (~p_ready) begin
        $display("[%6t] Error: waited for p_ready for too long", $time);
        $display("        addr = %8h, write = %b", p_addr, p_write);
    end
endtask
