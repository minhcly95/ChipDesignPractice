module testbench();
    parameter logic[31:0] BaseAddr = 32'h3000_1000;
    parameter logic[31:0] OtherAddr = 32'h2000_0000;

    // ---------------- Signal declarations --------------------
    logic a_clk;
    logic a_reset_n;
    // Write request channel
    logic aw_valid;
    logic aw_ready;
    logic[31:0] aw_addr;
    // Write data channel
    logic w_valid;
    logic w_ready;
    logic[31:0] w_data;
    logic[3:0] w_strb;
    // Write response channel
    logic b_valid;
    logic b_ready;
    logic[1:0] b_resp;
    // Read request channel
    logic ar_valid;
    logic ar_ready;
    logic[31:0] ar_addr;
    // Read response channel
    logic r_valid;
    logic r_ready;
    logic[31:0] r_data;
    logic[1:0] r_resp;

    int num_reset;
    
    // -------------------- Test subject -----------------------
    axi_register #(.BaseAddr(BaseAddr)) dut(.*);

    // -------------------- Main routine -----------------------
    initial begin
        tick();
        test_reset();
        test_rw_serial();
        test_rw_parallel();
        test_overwrite();
        test_delayed_w();
        test_delayed_aw();
        test_write_strobes();
        test_wrong_addr();
        test_throughput();
        $display("[%6t] Finished", $time);
        $finish;
    end

    // ---------------------- Test sets ------------------------
    task test_reset();
        reset("Test reset values");

        // Check data after reset
        fork
            // Read request
            for (int i = 0; i < 64; i++) begin
                axi_send_ar(BaseAddr + i * 4);
            end
            // Read data
            for (int i = 0; i < 64; i++) begin
                axi_recv_r(32'h0);
            end
        join
        axi_complete();
    endtask

    task test_rw_serial();
        logic[31:0] test_data[64];

        reset("Test R/W serial");

        // Generate random data
        for (int i = 0; i < 64; i++) begin
            test_data[i] = $urandom;
        end

        // Write test data
        fork
            // Write request and data
            for (int i = 0; i < 64; i++) begin
                axi_write(BaseAddr + i * 4, test_data[i]);
            end
            // Write response
            for (int i = 0; i < 64; i++) begin
                axi_recv_b();
            end
        join

        // Check if registers still hold data
        fork
            // Read request
            for (int i = 0; i < 64; i++) begin
                axi_send_ar(BaseAddr + i * 4);
            end
            // Read data
            for (int i = 0; i < 64; i++) begin
                axi_recv_r(test_data[i]);
            end
        join
        axi_complete();
    endtask

    task test_rw_parallel();
        logic[31:0] test_data[64];

        reset("Test R/W parallel");

        // Generate random data
        for (int i = 0; i < 64; i++) begin
            test_data[i] = $urandom;
        end

        // Write test data
        fork
            // Write request and data
            for (int i = 0; i < 64; i++) begin
                axi_write(BaseAddr + i * 4, test_data[i]);
            end
            // Write response
            for (int i = 0; i < 64; i++) begin
                axi_recv_b();
            end
        join_none

        // Read after write 5 cycles
        // (latency is 2 cycles so this should be fine)
        wait_after_clks(5);
        fork
            // Read request
            for (int i = 0; i < 64; i++) begin
                axi_send_ar(BaseAddr + i * 4);
            end
            // Read data
            for (int i = 0; i < 64; i++) begin
                axi_recv_r(test_data[i]);
            end
        join
        axi_complete();
    endtask

    task test_overwrite();
        logic[31:0] test_data[64];

        reset("Test overwrite");

        // Generate random data
        for (int i = 0; i < 64; i++) begin
            test_data[i] = $urandom;
        end

        // Write temp data
        fork
            // Write request and data
            for (int i = 0; i < 64; i++) begin
                axi_write(BaseAddr + i * 4, $urandom);
            end
            // Write response
            for (int i = 0; i < 64; i++) begin
                axi_recv_b();
            end
        join

        // Overwrite with test data
        fork
            // Write request and data
            for (int i = 0; i < 64; i++) begin
                axi_write(BaseAddr + i * 4, test_data[i]);
            end
            // Write response
            for (int i = 0; i < 64; i++) begin
                axi_recv_b();
            end
        join

        // Check if registers hold the new data
        fork
            // Read request
            for (int i = 0; i < 64; i++) begin
                axi_send_ar(BaseAddr + i * 4);
            end
            // Read data
            for (int i = 0; i < 64; i++) begin
                axi_recv_r(test_data[i]);
            end
        join
        axi_complete();
    endtask

    task test_delayed_w();
        logic[31:0] test_data[64];

        reset("Test write with delayed W");

        // Generate random data
        for (int i = 0; i < 64; i++) begin
            test_data[i] = $urandom;
        end

        // Write test data
        fork
            // Write request
            for (int i = 0; i < 64; i++) begin
                axi_send_aw(BaseAddr + i * 4);
            end
            // Write data
            for (int i = 0; i < 64; i++) begin
                wait_after_clks($urandom_range(3));
                axi_send_w(test_data[i]);
            end
            // Write response
            for (int i = 0; i < 64; i++) begin
                axi_recv_b();
            end
        join

        // Check if registers still hold data
        fork
            // Read request
            for (int i = 0; i < 64; i++) begin
                axi_send_ar(BaseAddr + i * 4);
            end
            // Read data
            for (int i = 0; i < 64; i++) begin
                axi_recv_r(test_data[i]);
            end
        join
        axi_complete();
    endtask

    task test_delayed_aw();
        logic[31:0] test_data[64];

        reset("Test write with delayed AW");

        // Generate random data
        for (int i = 0; i < 64; i++) begin
            test_data[i] = $urandom;
        end

        // Write test data
        fork
            // Write request
            for (int i = 0; i < 64; i++) begin
                wait_after_clks($urandom_range(3));
                axi_send_aw(BaseAddr + i * 4);
            end
            // Write data
            for (int i = 0; i < 64; i++) begin
                axi_send_w(test_data[i]);
            end
            // Write response
            for (int i = 0; i < 64; i++) begin
                axi_recv_b();
            end
        join

        // Check if registers still hold data
        fork
            // Read request
            for (int i = 0; i < 64; i++) begin
                axi_send_ar(BaseAddr + i * 4);
            end
            // Read data
            for (int i = 0; i < 64; i++) begin
                axi_recv_r(test_data[i]);
            end
        join
        axi_complete();
    endtask

    task test_write_strobes();
        logic[31:0] gen_data[64];
        logic[3:0] strb[64];
        logic[31:0] test_data[64];

        reset("Test write strobes");

        // Generate random data
        for (int i = 0; i < 64; i++) begin
            gen_data[i] = $urandom;
            strb[i] = $urandom[3:0];
            test_data[i] = apply_wstrb(gen_data[i], strb[i]);
        end

        // Write test data
        fork
            // Write request and data
            for (int i = 0; i < 64; i++) begin
                axi_write(BaseAddr + i * 4, gen_data[i], strb[i]);
            end
            // Write response
            for (int i = 0; i < 64; i++) begin
                axi_recv_b();
            end
        join

        // Check if registers still hold data
        fork
            // Read request
            for (int i = 0; i < 64; i++) begin
                axi_send_ar(BaseAddr + i * 4);
            end
            // Read data
            for (int i = 0; i < 64; i++) begin
                axi_recv_r(test_data[i]);
            end
        join
        axi_complete();
    endtask

    task test_wrong_addr();
        reset("Test wrong address");

        // Write test data
        fork
            // Write request and data
            begin
                axi_write(BaseAddr + 64 * 4, $urandom);
                axi_write(BaseAddr - 4, $urandom);
                axi_write(32'h0, $urandom);
                axi_write(OtherAddr, $urandom);
            end
            // Write response (error)
            for (int i = 0; i < 4; i++) begin
                axi_recv_b(2'b11);
            end
        join_none
        fork
            // Read request
            begin
                axi_send_ar(BaseAddr + 64 * 4);
                axi_send_ar(BaseAddr - 4);
                axi_send_ar(32'h0);
                axi_send_ar(OtherAddr);
            end
            // Read response (error)
            for (int i = 0; i < 4; i++) begin
                axi_recv_r_resp(2'b11);
            end
        join
        axi_complete();
    endtask

    task test_throughput();
        time start_time;

        reset("Test throughput and latency");

        // Write
        start_time = $time;
        fork
            // Write request and data
            for (int i = 0; i < 64; i++) begin
                axi_write(BaseAddr + $urandom_range(255), $urandom);
            end
            // Write response
            for (int i = 0; i < 64; i++) begin
                axi_recv_b();
            end
        join
        if ($time - start_time !== (64 + 2) * 10) begin
            $display("[%6t] Error: elapsed time does not match", $time);
            $display("        elapsed = %t, expected = %d", $time - start_time, (64 + 2) * 10);
        end

        // Read
        start_time = $time;
        fork
            // Read request
            for (int i = 0; i < 64; i++) begin
                axi_send_ar(BaseAddr + $urandom_range(255));
            end
            // Read data
            for (int i = 0; i < 64; i++) begin
                axi_skip_r();
            end
        join
        if ($time - start_time !== (64 + 2) * 10) begin
            $display("[%6t] Error: elapsed time does not match", $time);
            $display("        elapsed = %t, expected = %d", $time - start_time, (64 + 2) * 10);
        end

        axi_complete();
    endtask

    // --------------------- Subroutines -----------------------
    task reset(string title);
        num_reset++;
        $display("[%6t] #%02d %s", $time, num_reset, title);
        a_reset_n = 0;
        wait_after_clks(2);
        a_reset_n = 1;
        after_clk();
    endtask

    `include "dv/timing_tasks.sv"
    `include "dv/axi_tasks.sv"

    // Random 8-bit
    function logic[7:0] rand8();
        return $urandom[7:0];
    endfunction

    // Apply write strobes
    function logic[31:0] apply_wstrb(logic[31:0] data, logic[3:0] wstrb);
        return data & {{8{wstrb[3]}}, {8{wstrb[2]}}, {8{wstrb[1]}}, {8{wstrb[0]}}};
    endfunction

    // --------------------- Boilerplate -----------------------
    initial begin
        a_clk = 1;
        a_reset_n = 1;
        axi_init();
    end
    always #5 a_clk = ~a_clk;

    initial begin
        $dumpfile("out/wave.vcd");
		$dumpvars(0, testbench); 
    end
    
endmodule
