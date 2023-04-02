module tile_tb;

reg [63:0]instruction;
reg rst;
reg clk;

//Data Recieved from Data Memory
reg[31:0] recv_from_memory_data;
reg[2:0] recv_from_memory_addr;

//Data Sent to Data Memory
wire [31:0] send_to_memory_data;
wire [9:0] send_to_memory_addr;

//Data Recieved from other tiles
reg[255:0] recv_from_tile_data;
reg[23:0] recv_from_tile_addr;

//Data Sent to other tiles
wire [255:0] send_to_tile_data;
wire [23:0] send_to_tile_addr;

//Output from each tile to cgra_output
wire [31:0] final_output;

tile DUT(instruction,rst,clk,recv_from_memory_data,recv_from_memory_addr,send_to_memory_data,send_to_memory_addr,recv_from_tile_data,recv_from_tile_addr,send_to_tile_data,send_to_tile_addr,final_output);

always #5 clk = ~clk;
initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,DUT);
    clk = 1'b0;
    rst = 1'b1;
    #5
    rst = 1'b0;
    instruction = 64'b000000000000000000000000000000111100000000000000000000000000110;
    #10
    instruction = 64'b000000000000000000000000000000000000000000000000000000000000010;
end
endmodule