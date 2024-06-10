`define BASIC_TEST_SIZE 66

module testbench();
    logic clk;
    logic reset;
    logic halted;
    logic unhalt;
    logic[31:0] i_addr;
    logic[31:0] i_data;
    logic[31:0] d_addr;
    logic[31:0] d_wdata;
    logic[3:0] d_wstrb;
    logic[31:0] d_rdata;

    logic[31:0] basic_test_results[`BASIC_TEST_SIZE];

    // ------------------ Device under test --------------------
    riscv dut(.*);

    // ---------------------- Environment ----------------------
    imem imem(i_addr, i_data);
    dmem dmem(clk, d_addr, d_wdata, d_wstrb, d_rdata);
    
    // --------------------- Main program ----------------------
    initial begin
        #1;
        $display("-------- Basic test started ---------");
        imem.load("basic_test");
        reset_dut();
        wait_halt();
        for (int i = 0; i < `BASIC_TEST_SIZE; i++) begin
            if (dmem.mem[i] !== basic_test_results[i])
            $display("Wrong value at addr %3d: %8h (expected %8h)", i * 4, dmem.mem[i], basic_test_results[i]);
        end
        $display("--------- Basic test done -----------");
        $finish;
    end

    // ------------------------ Tasks --------------------------
    task reset_dut();
        reset = 1;
        unhalt = 0;
        #20;
        reset = 0;
    endtask

    task wait_halt();
        @(posedge halted);
    endtask

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

endmodule
