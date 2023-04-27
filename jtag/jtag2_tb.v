`timescale 10us / 10ns

module jtag2_tb();

reg clk;
reg data_in;
reg rst;
reg data_valid;
wire memory;
wire data_out;

jtag2 # (.num_of_tiles(4),.tile_id(0),.mem_cycles(4096)) jtag0(clk,data_in,rst,data_valid,memory,data_out);
reg [0:0]jtag[0:4095];
integer i;

always #1 clk = ~clk;
initial begin
    $readmemb("jtag.mem",jtag);
    rst = 0;
    clk = 1;
    data_valid = 1;
    i = 0;
    repeat(5000) begin
        data_in = jtag[i];
        #2;
        i = i + 1;
    end
end
endmodule