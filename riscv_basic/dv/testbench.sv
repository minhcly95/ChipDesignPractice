module testbench();
    logic clk;
    logic reset;
    logic[31:0] pc;
    logic[31:0] instr;
    logic[31:0] d_addr;
    logic[31:0] d_wdata;
    logic[3:0] d_wstrb;
    logic[31:0] d_rdata;

    logic[31:0] basic_test_results[55];

    // ------------------ Device under test --------------------
    riscv dut(.*);

    // ---------------------- Environment ----------------------
    imem imem(pc, instr);
    dmem dmem(clk, d_addr, d_wdata, d_wstrb, d_rdata);
    
    // --------------------- Main program ----------------------
    initial begin
        #1;
        imem.load("basic_test");
        reset_dut();
        #2000;
        for (int i = 0; i < 55; i++) begin
            if (dmem.mem[i] !== basic_test_results[i])
            $display("Wrong value at addr %3d: %8h (expected %8h)", i * 4, dmem.mem[i], basic_test_results[i]);
        end
        $finish;
    end

    // ---------------------- Data load ------------------------
    initial begin
        $readmemh("asm/basic_test_results.dat", basic_test_results);
    end

    // --------------------- Boilerplate -----------------------
    initial begin
        clk = 1;
        reset = 0;
    end
    always #5 clk = ~clk;

    initial begin
        $dumpfile("out/wave.vcd");
		$dumpvars(0, testbench); 
    end

    task reset_dut();
        reset = 1;
        #20;
        reset = 0;
    endtask
    
endmodule
