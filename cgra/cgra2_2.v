`include "../updated_tile/tile_2.v"
`include "../jtag/jtag2.v"

module cgra2_2(
    input rst,
    input clk,
    
    input program_mode,
    input jtag_data_in,
    output jtag_data_out
);
wire jtag_tile00_10;
wire jtag_tile10_11;
wire jtag_tile11_01;

tile_2 #(.tile_id(3)) tile00(.rst(rst),.clk(clk), .program_mode(program_mode),.jtag_data_in(jtag_data_in),.jtag_data_out(jtag_tile00_10));
tile_2 #(.tile_id(2)) tile10(.rst(rst),.clk(clk), .program_mode(program_mode),.jtag_data_in(jtag_tile00_10),.jtag_data_out(jtag_tile10_11));
tile_2 #(.tile_id(1)) tile11(.rst(rst),.clk(clk), .program_mode(program_mode),.jtag_data_in(jtag_tile10_11),.jtag_data_out(jtag_tile11_01));
tile_2 #(.tile_id(0)) tile01(.rst(rst),.clk(clk), .program_mode(program_mode),.jtag_data_in(jtag_tile11_01),.jtag_data_out(jtag_data_out));

endmodule