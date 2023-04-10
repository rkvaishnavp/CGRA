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
reg [383:0] recv_from_tile_data;
wire jtag_data_out;
wire [383:0] send_to_tile_data;
wire [47:0] tile_output;

reg [63:0]jtag = 64'b00000001111xx001000000000000000001000011001000010000000;
reg [12:0]addr;

tile_2 #(.tile_id(0)) tile0(
    .rst(rst),
    .clk(clk),
    .jtag_data_in(jtag_data_in),
    .jtag_data_out(jtag_data_out),
    .program_mode(program_mode),
    .recv_from_tile_data(recv_from_tile_data),
    .send_to_tile_data(send_to_tile_data),
    .tile_output(tile_output)
);

always #1 clk = ~clk;
integer i=0;

initial begin
    addr = 0;
    rst = 0;
    clk = 1;
    program_mode = 1;
    repeat(64) begin
        jtag_data_in = jtag[addr];
        #2;
        addr = addr + 1;
    end
    program_mode = 0;
    #10;
    $finish;
end
endmodule


