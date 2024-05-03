// Init AHB
task ahb_init();
    h_trans = 0;
    h_size = 0;
    h_write = 0;
    h_addr = 0;
    h_wstrb = 4'b1111;
    h_wdata = 0;
    other_readyout = 1;
endtask

task ahb_idle();
    h_trans = 0;
    after_clk();
endtask

task ahb_idle_until_ready();
    h_trans = 0;
    ahb_wait_ready();
    tick();
endtask

// Write data to addr
task automatic ahb_write(logic[31:0] addr, logic[31:0] data, bit wait_ready = 1, logic[2:0] size = 3'b010);
    // Address phase
    h_addr = addr;
    h_trans = 2'b10;    // NONSEQ
    h_write = 1;
    h_size = size;
    ahb_wait_ready();
    tick();
    h_trans = 0;
    // Data phase (fork to other thread)
    fork
        begin
            h_wdata = data;
            if (wait_ready)
                ahb_wait_ready();
            else begin
                at_clk();
                if (~h_readyout) begin
                    $display("[%6t] Error: slave was not ready", $time);
                    $display("        addr = %8h, wdata = %8h", h_addr, h_wdata);
                end
            end
            if (h_resp) begin
                $display("[%6t] Error: slave raised an error while writing", $time);
                $display("        addr = %8h, wdata = %8h", h_addr, h_wdata);
            end
        end
    join_none
endtask

// Write data to addr and expect an error
task automatic ahb_write_throw(logic[31:0] addr, logic[31:0] data, bit wait_resp = 1, logic[2:0] size = 3'b010);
    // Address phase
    h_addr = addr;
    h_trans = 2'b10;    // NONSEQ
    h_write = 1;
    h_size = size;
    ahb_wait_ready();
    tick();
    h_trans = 0;
    // Data phase (fork to other thread)
    fork
        begin
            h_wdata = data;
            if (wait_resp)
                ahb_wait_resp();
            else begin
                at_clk();
            end
            if (~h_resp) begin
                $display("[%6t] Error: slave did not raise an error while writing (expecting an error)", $time);
                $display("        addr = %8h, wdata = %8h", h_addr, h_wdata);
            end
            else if (h_ready) begin
                $display("[%6t] Error: wrong error response (1st cycle)", $time);
                $display("        addr = %8h, wdata = %8h", h_addr, h_wdata);
            end
            else begin
                at_clk();
                if (~h_resp | ~h_ready) begin
                    $display("[%6t] Error: wrong error response (2nd cycle)", $time);
                    $display("        addr = %8h, wdata = %8h", h_addr, h_wdata);
                end
            end
        end
    join_none
endtask

// Read and check data from addr
task automatic ahb_read_check(logic[31:0] addr, logic[31:0] data, bit wait_ready = 1, bit no_check = 0, logic[2:0] size = 3'b010);
    // Address phase
    h_addr = addr;
    h_trans = 2'b10;    // NONSEQ
    h_write = 0;
    h_size = size;
    ahb_wait_ready();
    tick();
    h_trans = 0;
    // Data phase (fork to other thread)
    fork
        begin
            if (wait_ready)
                ahb_wait_ready();
            else begin
                at_clk();
                if (~h_readyout) begin
                    $display("[%6t] Error: slave was not ready", $time);
                    $display("        addr = %8h, rdata = %8h", h_addr, h_rdata);
                end
            end
            if (h_resp) begin
                $display("[%6t] Error: slave raised an error while reading", $time);
                $display("        addr = %8h, rdata = %8h", h_addr, h_rdata);
            end
            else if (~no_check && h_rdata !== data) begin
                $display("[%6t] Error: received data does not match", $time);
                $display("        addr = %8h, rdata = %8h, expected = %8h", h_addr, h_rdata, data);
            end
        end
    join_none
endtask

// Read from addr and expect an error
task automatic ahb_read_throw(logic[31:0] addr, bit wait_resp = 1, logic[2:0] size = 3'b010);
    // Address phase
    h_addr = addr;
    h_trans = 2'b10;    // NONSEQ
    h_write = 0;
    h_size = size;
    ahb_wait_ready();
    tick();
    h_trans = 0;
    // Data phase (fork to other thread)
    fork
        begin
            if (wait_resp)
                ahb_wait_resp();
            else begin
                at_clk();
            end
            if (~h_resp) begin
                $display("[%6t] Error: slave did not raise an error while reading (expecting an error)", $time);
                $display("        addr = %8h, rdata = %8h", h_addr, h_rdata);
            end
            else if (h_ready) begin
                $display("[%6t] Error: wrong error response (1st cycle)", $time);
                $display("        addr = %8h, rdata = %8h", h_addr, h_rdata);
            end
            else begin
                at_clk();
                if (~h_resp | ~h_ready) begin
                    $display("[%6t] Error: wrong error response (2nd cycle)", $time);
                    $display("        addr = %8h, rdata = %8h", h_addr, h_rdata);
                end
            end
        end
    join_none
endtask

// Write to other address
task automatic ahb_write_dummy(int wait_states = 0, logic[31:0] addr = OtherAddr + $urandom_range(255), logic[31:0] data = $urandom);
    // Address phase
    h_trans = 2'b10;    // NONSEQ
    h_size = 3'b010;    // Word
    h_write = 1;
    h_addr = addr;
    ahb_wait_ready();
    tick();
    h_trans = 0;
    // Data phase (fork to other thread)
    fork
        begin
            h_wdata = data;
            other_readyout = 0;
            wait_after_clks(wait_states);
            other_readyout = 1;
        end
    join_none
endtask

// Read from other address
task automatic ahb_read_dummy(int wait_states = 0, logic[31:0] addr = OtherAddr + $urandom_range(255));
    // Address phase
    h_trans = 2'b10;    // NONSEQ
    h_size = 3'b010;    // Word
    h_write = 0;
    h_addr = addr;
    ahb_wait_ready();
    tick();
    h_trans = 0;
    // Data phase (fork to other thread)
    fork
        begin
            other_readyout = 0;
            wait_after_clks(wait_states);
            other_readyout = 1;
        end
    join_none
endtask

// Wait until h_ready is high at clk (complain if wait for too long)
task automatic ahb_wait_ready(int max_clk = 1000);
    int i;

    at_clk();
    i = 0;
    while (~h_ready && i < max_clk) begin
        i++; 
        at_clk();
    end
    if (~h_ready) begin
        $display("[%6t] Error: waited for h_ready for too long", $time);
        $display("        addr = %8h, write = %b", h_addr, h_write);
    end
endtask

// Wait until h_resp is high at clk (complain if wait for too long)
task automatic ahb_wait_resp(int max_clk = 1000);
    int i;

    at_clk();
    i = 0;
    while (~h_resp && i < max_clk) begin
        i++; 
        at_clk();
    end
    if (~h_resp) begin
        $display("[%6t] Error: waited for h_resp for too long", $time);
        $display("        addr = %8h, write = %b", h_addr, h_write);
    end
endtask
