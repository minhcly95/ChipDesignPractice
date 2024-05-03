module testbench();
    parameter logic[31:0] BaseAddr = 32'h3000_1000;
    parameter logic[31:0] OtherAddr = 32'h2000_0000;

    // ---------------- Signal declarations --------------------
    logic h_clk;
    logic h_reset_n;
    logic h_sel;
    logic[1:0] h_trans;
    logic h_ready;
    logic[31:0] h_addr;
    logic h_write;
    logic[2:0] h_size;
    logic[3:0] h_wstrb;
    logic[31:0] h_wdata;
    logic[31:0] h_rdata;
    logic h_readyout;
    logic h_resp;

    logic last_sel, force_sel;
    logic other_readyout;
    int num_reset;
    
    // -------------------- Test subject -----------------------
    ahb_register #(.BaseAddr(BaseAddr)) dut(.*);

    // -------------------- Main routine -----------------------
    initial begin
        tick();
        test_reset();
        test_rw_continuous();
        test_rw_sporadic();
        test_overwrite();
        test_size_hw();
        test_size_byte();
        test_write_strobes();
        test_wrong_addr();
        test_data_timing();
        test_error_timing();
        $display("[%6t] Finished", $time);
        $finish;
    end

    // ---------------------- Test sets ------------------------
    task test_reset();
        logic[31:0] test_data[64];

        reset("Test reset values");

        // Check data after reset
        for (int i = 0; i < 64; i++) begin
            ahb_read_check(BaseAddr + i * 4, 32'h0);
        end
        ahb_idle_until_ready();
    endtask

    task test_rw_continuous();
        logic[31:0] test_data[64];

        reset("Test R/W continuous");

        // Write test data
        for (int i = 0; i < 64; i++) begin
            test_data[i] = $urandom;
            ahb_write(BaseAddr + i * 4, test_data[i]);
        end
        // Check if registers still hold data
        for (int i = 0; i < 64; i++) begin
            ahb_read_check(BaseAddr + i * 4, test_data[i]);
        end
        ahb_idle_until_ready();
    endtask

    task test_rw_sporadic();
        logic[31:0] test_data[64];

        reset("Test R/W sporadic");

        // Write test data
        for (int i = 0; i < 64; i++) begin
            test_data[i] = $urandom;
            ahb_write(BaseAddr + i * 4, test_data[i]);
            // Do random transfer in between
            make_dummy_transfers($urandom_range(3));
        end
        // Check if registers still hold data
        for (int i = 0; i < 64; i++) begin
            ahb_read_check(BaseAddr + i * 4, test_data[i]);
            // Do random transfer in between
            make_dummy_transfers($urandom_range(3));
        end
        ahb_idle_until_ready();
    endtask

    task test_overwrite();
        logic[31:0] test_data[64];

        reset("Test overwrite");

        // Write temp data
        for (int i = 0; i < 64; i++) begin
            ahb_write(BaseAddr + i * 4, $urandom);
        end
        // Overwrite with test data
        for (int i = 0; i < 64; i++) begin
            test_data[i] = $urandom;
            ahb_write(BaseAddr + i * 4, test_data[i]);
        end
        // Check if registers hold the new data
        for (int i = 0; i < 64; i++) begin
            ahb_read_check(BaseAddr + i * 4, test_data[i]);
        end
        ahb_idle_until_ready();
    endtask

    task test_size_hw();
        logic[31:0] test_data[64];

        reset("Test size (halfword)");

        // Write 2 bytes at a time
        for (int i = 0; i < 64; i++) begin
            test_data[i] = $urandom;
            ahb_write(BaseAddr + 4 * i, {$urandom[31:16], test_data[i][15:0]}, 1, 3'b001);
            ahb_write(BaseAddr + 4 * i + 2, {test_data[i][31:16], $urandom[15:0]}, 1, 3'b001);
        end
        // Check if registers hold correct data
        for (int i = 0; i < 64; i++) begin
            ahb_read_check(BaseAddr + i * 4, test_data[i]);
        end
        ahb_idle_until_ready();
    endtask

    task test_size_byte();
        logic[31:0] test_data[64];

        reset("Test size (byte)");

        // Write a byte at a time
        for (int i = 0; i < 64; i++) begin
            test_data[i] = $urandom;
            ahb_write(BaseAddr + 4 * i, {rand8(), rand8(), rand8(), test_data[i][7:0]}, 1, 3'b000);
            ahb_write(BaseAddr + 4 * i + 1, {rand8(), rand8(), test_data[i][15:8], rand8()}, 1, 3'b000);
            ahb_write(BaseAddr + 4 * i + 2, {rand8(), test_data[i][23:16], rand8(), rand8()}, 1, 3'b000);
            ahb_write(BaseAddr + 4 * i + 3, {test_data[i][31:24], rand8(), rand8(), rand8()}, 1, 3'b000);
        end
        // Check if registers hold correct data
        for (int i = 0; i < 64; i++) begin
            ahb_read_check(BaseAddr + i * 4, test_data[i]);
        end
        ahb_idle_until_ready();
    endtask
    
    task test_write_strobes();
        logic[31:0] gen_data[64];
        logic[31:0] test_data[64];

        reset("Test write strobes");

        // Write with write strobes
        for (int i = 0; i < 64; i++) begin
            gen_data[i] = $urandom;
            ahb_write(BaseAddr + 4 * i, gen_data[i]);
            // Set h_wstrb in the data phase
            h_wstrb = $urandom[3:0];
            test_data[i] = apply_wstrb(gen_data[i], h_wstrb);
        end
        // Check if registers hold correct data
        for (int i = 0; i < 64; i++) begin
            ahb_read_check(BaseAddr + i * 4, test_data[i]);
        end
        ahb_idle_until_ready();
    endtask

    task test_wrong_addr();
        reset("Test wrong address");

        // Force h_sel to be 1
        force_sel = 1;
        // Read/write to out of range address
        ahb_write_throw(BaseAddr + 64 * 4, $urandom);
        ahb_write_throw(BaseAddr - 4, $urandom);
        ahb_write_throw(32'h0, $urandom);
        ahb_write_throw(OtherAddr, $urandom);
        ahb_read_throw(BaseAddr + 64 * 4);
        ahb_read_throw(BaseAddr - 4);
        ahb_read_throw(32'h0);
        ahb_read_throw(OtherAddr);
        // Read/write to unaligned address (WORD)
        for (int i = 0; i < 64 * 4; i++) begin
            if (i % 4 === 0) begin
                ahb_write(BaseAddr + i, 0, 1, 3'b010);
                ahb_read_check(BaseAddr + i, 0, 1, 0, 3'b010);
            end
            else begin
                ahb_write_throw(BaseAddr + i, $urandom, 1, 3'b010);
                ahb_read_throw(BaseAddr + i, 1, 3'b010);
            end
        end
        // Read/write to unaligned address (HALFWORD)
        for (int i = 0; i < 64 * 4; i++) begin
            if (i % 2 === 0) begin
                ahb_write(BaseAddr + i, 0, 1, 3'b001);
                ahb_read_check(BaseAddr + i, 0, 1, 0, 3'b001);
            end
            else begin
                ahb_write_throw(BaseAddr + i, $urandom, 1, 3'b001);
                ahb_read_throw(BaseAddr + i, 1, 3'b001);
            end
        end
        // All byte should be accessible (BYTE)
        for (int i = 0; i < 64 * 4; i++) begin
            ahb_write(BaseAddr + i, 0, 1, 3'b000);
            ahb_read_check(BaseAddr + i, 0, 1, 0, 3'b000);
        end
        ahb_idle_until_ready();
        // Recover h_sel
        force_sel = 0;
    endtask

    task test_data_timing();
        reset("Test data timing");

        // Check if write has no wait states
        for (int i = 0; i < 64; i++) begin
            ahb_write(BaseAddr + i * 4, $urandom, 0);
        end
        // Check if read has no wait states
        for (int i = 0; i < 64; i++) begin
            ahb_read_check(BaseAddr + i * 4, 0, 0, 1);
        end
        ahb_idle_until_ready();
    endtask

    task test_error_timing();
        reset("Test error timing");

        // Check if the error response is correct
        for (int i = 0; i < 256; i++) begin
            if (i % 4 === 0)
                // Write to aligned address (no error)
                ahb_write(BaseAddr + i, $urandom);
            else
                // Write to unaligned address (error)
                ahb_write_throw(BaseAddr + i, $urandom, 0);
        end
        for (int i = 0; i < 256; i++) begin
            if (i % 4 === 0)
                // Read from aligned address (no error)
                ahb_read_check(BaseAddr + i, 0, 1, 1);
            else
                // Read from unaligned address (error)
                ahb_read_throw(BaseAddr + i, 0);
        end
        ahb_idle_until_ready();
    endtask

    // --------------------- Subroutines -----------------------
    task reset(string title);
        num_reset++;
        $display("[%6t] #%02d %s", $time, num_reset, title);
        h_reset_n = 0;
        wait_after_clks(2);
        h_reset_n = 1;
    endtask

    `include "dv/timing_tasks.sv"
    `include "dv/ahb_tasks.sv"

    // Dummy action
    task automatic make_dummy_transfers(int num_transfers, int max_wait_states = 3);
        for (int j = 0; j < num_transfers; j++) begin
            int proc = $urandom_range(2);
            if (proc === 0)
                ahb_idle_until_ready();
            else if (proc === 1)
                ahb_write_dummy($urandom_range(max_wait_states));
            else if (proc === 2)
                ahb_read_dummy($urandom_range(max_wait_states));
        end
    endtask

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
        h_clk = 1;
        h_reset_n = 1;
        ahb_init();
        last_sel = 0;
        force_sel = 0;
    end
    always #5 h_clk = ~h_clk;

    // AHB interconnect
    always_comb begin
        h_sel = force_sel | (h_addr >= BaseAddr) & (h_addr < BaseAddr + 64 * 4);
        h_ready = last_sel ? h_readyout : other_readyout;
    end
    always_ff @(posedge h_clk) begin
        if (h_ready) last_sel <= h_sel;
    end

    initial begin
        $dumpfile("out/wave.vcd");
		$dumpvars(0, testbench); 
    end
    
endmodule
