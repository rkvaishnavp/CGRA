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

module tile_2_tb();



reg rst;
reg clk;
reg jtag_data_in;
reg program_mode;
reg [255:0] recv_from_tile_data;
reg [4:0] recv_from_tile_addr;
wire jtag_data_out;
wire [255:0] send_to_tile_data;
wire [23:0] send_to_tile_addr;
wire [31:0] tile_output;

reg [11:0]jtag[0:0];
reg [11:0]addr;

tile_2 tile0(
    .rst(rst),
    .clk(clk),
    .jtag_data_in(jtag_data_in),
    .jtag_data_out(jtag_data_out),
    .program_mode(program_mode),
    .recv_from_tile_addr(recv_from_tile_addr),
    .recv_from_tile_data(recv_from_tile_data),
    .send_to_tile_addr(send_to_tile_addr),
    .send_to_tile_data(send_to_tile_data),
    .tile_output(tile_output)
);

always #1 clk = ~clk;
always begin jtag_data_in = jtag[addr];  #2 addr = addr + 1;  end
initial begin
    $monitor("clk=%b, data_in=%d, data_out=%d",clk,jtag_data_in,jtag_data_out);
    addr = 0;
    $readmemb("jtag.bin",jtag);
    rst = 0;
    clk = 0;
    program_mode = 1;
    repeat(5000) begin
    #1;
    end
end
endmodule
