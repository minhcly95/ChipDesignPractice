module dmem_ctrl(
    // Input from datapath
    input logic[31:0] a,
    input logic[31:0] wd,
    output logic[31:0] rd,
    input logic mem_write,
    input logic[2:0] mem_size,
    // Output to Dmem
    output logic[31:0] d_addr,
    output logic[31:0] d_wdata,
    output logic[3:0] d_wstrb,
    input logic[31:0] d_rdata,
    // Exception
    output logic misaligned_addr
);
    logic[1:0] byte_offset;
    logic[3:0] lanes;

    addr_dec addr_dec(a, byte_offset, d_addr);
    lane_dec lane_dec(byte_offset, mem_size, lanes);

    write_shifter write_shifter(wd, lanes, d_wdata);
    read_shifter read_shifter(d_rdata, lanes, mem_size[2], rd);

    assign d_wstrb = lanes & {4{mem_write}};
    assign misaligned_addr = (lanes == 4'h0);
endmodule
