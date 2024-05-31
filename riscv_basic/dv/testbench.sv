module testbench();
    logic clk;
    logic reset;
    logic[31:0] pc;
    logic[31:0] instr;

    // ------------------ Device under test --------------------
    riscv dut(clk, reset, pc, instr);

    // ---------------------- Environment ----------------------
    imem imem(pc, instr);
    
    // --------------------- Main program ---------------------
    initial begin
        #1;
        reset_dut();
        #1000;
        $finish;
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
