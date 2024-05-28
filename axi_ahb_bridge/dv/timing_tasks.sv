// Timing
task automatic at_clk();
    @(posedge a_clk);
endtask

task automatic tick();
    #1;
endtask

task automatic after_clk();
    at_clk();
    tick();
endtask

task automatic wait_clks(int num_clk);
    for (int i = 0; i < num_clk; i++)
        at_clk();
endtask

task automatic wait_after_clks(int num_clk);
    for (int i = 0; i < num_clk; i++)
        after_clk();
endtask
