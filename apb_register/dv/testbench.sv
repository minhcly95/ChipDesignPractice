module testbench();
    parameter logic[31:0] BaseAddr = 32'h4000_1000;

    // ---------------- Signal declarations --------------------
    logic p_clk;
    logic p_reset_n;
    logic[31:0] p_addr;
    logic p_sel;
    logic p_enable;
    logic p_write;
    logic[31:0] p_wdata;
    logic[31:0] p_rdata;
    logic p_ready;
    logic p_slverr;

    logic sel_en;

    int num_reset;
    
    // -------------------- Test subject -----------------------
    apb_register #(.BaseAddr(BaseAddr)) dut(
        .p_sel(p_sel & sel_en),
        .*
    );

    // -------------------- Main routine -----------------------
    initial begin
        tick();
        test_reset();
        test_rw_continuous();
        test_rw_sporadic();
        test_overwrite();
        test_ready();
        test_wrong_addr();
        test_apb_no_sel();
        $display("[%6t] Finished", $time);
        $finish;
    end

    // ---------------------- Test sets ------------------------
    task test_reset();
        logic[31:0] test_data[64];

        reset("Test reset values");

        // Check data after reset
        for (int i = 0; i < 64; i++) begin
            apb_read_check(BaseAddr + i * 4, 32'h0);
        end
    endtask

    task test_rw_continuous();
        logic[31:0] test_data[64];

        reset("Test R/W continuous");

        // Write test data
        for (int i = 0; i < 64; i++) begin
            test_data[i] = $urandom;
            apb_write(BaseAddr + i * 4, test_data[i]);
        end

        // Check if registers still hold data
        for (int i = 0; i < 64; i++) begin
            apb_read_check(BaseAddr + i * 4, test_data[i]);
        end
    endtask

    task test_rw_sporadic();
        logic[31:0] test_data[64];

        reset("Test R/W sporadic");

        // Write test data
        for (int i = 0; i < 64; i++) begin
            test_data[i] = $urandom;
            apb_write(BaseAddr + i * 4, test_data[i]);
            wait_after_clks($urandom_range(3));
        end

        // Check if registers still hold data
        for (int i = 0; i < 64; i++) begin
            apb_read_check(BaseAddr + i * 4, test_data[i]);
            wait_after_clks($urandom_range(3));
        end
    endtask

    task test_overwrite();
        logic[31:0] test_data[64];

        reset("Test overwrite");

        // Write temp data
        for (int i = 0; i < 64; i++) begin
            apb_write(BaseAddr + i * 4, $urandom);
        end

        // Overwrite with test data
        for (int i = 0; i < 64; i++) begin
            test_data[i] = $urandom;
            apb_write(BaseAddr + i * 4, test_data[i]);
        end

        // Check if registers hold the new data
        for (int i = 0; i < 64; i++) begin
            apb_read_check(BaseAddr + i * 4, test_data[i]);
        end
    endtask

    task test_ready();
        reset("Test ready");

        // Check if write has no wait states
        for (int i = 0; i < 64; i++) begin
            apb_write(BaseAddr + i * 4, $urandom, 0, 1);
        end

        // Check if read has no wait states
        for (int i = 0; i < 64; i++) begin
            apb_read(BaseAddr + i * 4, 32'hx, 0, 1);
        end
    endtask

    task test_wrong_addr();
        reset("Test wrong address");

        // Read/write to out of range address
        apb_write_throw(BaseAddr + 64 * 4, $urandom);
        apb_read_throw(BaseAddr + 64 * 4);
        apb_write_throw(BaseAddr - 4, $urandom);
        apb_read_throw(BaseAddr - 4);
        apb_write_throw(32'h0, $urandom);
        apb_read_throw(32'h0);
        apb_write_throw(32'h3000_3000, $urandom);
        apb_read_throw(32'h3000_3000);

        // Read/write to unaligned address
        for (int i = 0; i < 64 * 4; i++) begin
            if (i % 4 !== 0) begin
                apb_write_throw(BaseAddr + i, $urandom);
                apb_read_throw(BaseAddr + i);
            end
        end

        // Check if registers are written
        for (int i = 0; i < 64; i++) begin
            apb_read_check(BaseAddr + i * 4, 32'h0);
        end
    endtask

    task test_apb_no_sel();
        logic[31:0] test_data[64];

        reset("Test APB without SEL");

        // Write test data
        for (int i = 0; i < 64; i++) begin
            test_data[i] = $urandom;
            apb_write(BaseAddr + i * 4, test_data[i]);
        end

        sel_en = 0;
        // Write with no sel (should not write)
        for (int i = 0; i < 64; i++) begin
            apb_write(BaseAddr + i * 4, $urandom, 0);
        end
        // Read with no sel (should return 0)
        for (int i = 0; i < 64; i++) begin
            apb_read_check(BaseAddr + i * 4, 32'h0, 0);
        end
        sel_en = 1;

        // Check if registers still hold old data
        for (int i = 0; i < 64; i++) begin
            apb_read_check(BaseAddr + i * 4, test_data[i]);
        end
    endtask

    // --------------------- Subroutines -----------------------
    task reset(string title);
        num_reset++;
        $display("[%6t] #%02d %s", $time, num_reset, title);
        p_reset_n = 0;
        wait_after_clks(2);
        p_reset_n = 1;
    endtask

    `include "dv/timing_tasks.sv"
    `include "dv/apb_tasks.sv"

    // --------------------- Boilerplate -----------------------
    initial begin
        p_clk = 1;
        p_reset_n = 1;
        apb_init();
        sel_en = 1;
    end
    always #5 p_clk = ~p_clk;

    initial begin
        $dumpfile("out/wave.vcd");
		$dumpvars(0, testbench); 
    end
    
endmodule
