// Timing
task at_clk();
    @(posedge h_clk);
endtask

task tick();
    #1;
endtask

task after_clk();
    at_clk();
    tick();
endtask

task wait_clks(int num_clk);
    for (int i = 0; i < num_clk; i++)
        at_clk();
endtask

task wait_after_clks(int num_clk);
    for (int i = 0; i < num_clk; i++)
        after_clk();
endtask
