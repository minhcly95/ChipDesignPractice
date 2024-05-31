module imem(
    input logic[31:0] pc,
    output logic[31:0] instr
);
    logic[31:0] imem[64];
    int fd;

    initial begin
        fd = $fopen("asm/fibonacci.bin", "r");
        $fread(imem, fd);
        $fclose(fd);
        // Swap the byte order
        for (int i = 0; i < 64; i++) begin
            imem[i] = {imem[i][7:0], imem[i][15:8], imem[i][23:16], imem[i][31:24]};
        end
    end

    assign instr = imem[pc[7:2]];
endmodule
