module imem(
    input logic[31:0] addr,
    output logic[31:0] data
);
    logic[31:0] imem[1024];
    int fd;

    assign data = imem[addr[11:2]];

    task load(string name);
        fd = $fopen({"asm/", name, ".bin"}, "r");
        $fread(imem, fd);
        $fclose(fd);
        // Swap the byte order
        for (int i = 0; i < 1024; i++) begin
            imem[i] = {imem[i][7:0], imem[i][15:8], imem[i][23:16], imem[i][31:24]};
        end
    endtask
endmodule
