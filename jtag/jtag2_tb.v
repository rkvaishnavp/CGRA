`timescale 10us / 10ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2023 10:14:14 PM
// Design Name: 
// Module Name: tile_2_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module jtag2_tb();

reg clk;
reg data_in;
reg rst;
reg data_valid;
wire memory;
wire data_out;

jtag2 jtag0(clk,data_in,rst,data_valid,memory,data_out);
reg [0:0]jtag[0:4095];
integer i;

always #1 clk = ~clk;
initial begin
    $readmemb("/home/rkvp/Desktop/Backup/Projects/HardWare/CGRA/jtag/jtag.txt",jtag);
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