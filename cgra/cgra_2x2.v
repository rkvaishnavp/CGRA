`include "../alu/alu.v"
`include "../tiles/tile.v"

module cgra_2x2 (
    input [255:0]instruction,
    output reg [127:0] final_output,
    input clk,
    input [1:0]rst
);
wire [127:0] final_output1;
assign final_output1 = final_output;
wire [31:0]send_data_0_0x1_0;
wire [31:0]send_data_0_0x1_1;
wire [31:0]send_data_0_0x0_1;
wire [2:0]send_addr_0_0x1_0;
wire [2:0]send_addr_0_0x0_1;
wire [2:0]send_addr_0_0x1_1;

wire [31:0]send_data_1_0x0_0;
wire [31:0]send_data_1_0x1_1;
wire [31:0]send_data_1_0x0_1;
wire [2:0]send_addr_0_1x0_0;
wire [2:0]send_addr_0_1x1_0;
wire [2:0]send_addr_0_1x1_1;

wire [31:0]send_data_0_1x0_0;
wire [31:0]send_data_0_1x1_1;
wire [31:0]send_data_0_1x1_0;
wire [2:0]send_addr_1_0x0_0;
wire [2:0]send_addr_1_0x0_1;
wire [2:0]send_addr_1_0x1_1;

wire [31:0]send_data_1_1x0_0;
wire [31:0]send_data_1_1x1_0;
wire [31:0]send_data_1_1x0_1;
wire [2:0]send_addr_1_1x1_0;
wire [2:0]send_addr_1_1x0_1;
wire [2:0]send_addr_1_1x0_0;

tile tile_0_0(
    .instruction(instruction[63:0]),
    .rst(rst[0]),
    .clk(clk),

    .recv_from_memory_data(32'b0),
    .recv_from_memory_addr(10'b0),
    
    .send_to_memory_data(32'b0),
    .send_to_memory_addr(3'b0),
    
    .recv_from_tile_data({160'b0,send_data_0_1x0_0,send_data_1_1x0_0,send_data_1_0x0_0}),
    .recv_from_tile_addr({15'b0,send_addr_0_1x0_0,send_addr_1_1x0_0,send_addr_1_0x0_0}),
    
    .send_to_tile_data({160'b0,send_data_0_0x0_1,send_addr_0_0x1_1,send_addr_0_0x1_0}),
    .send_to_tile_addr({15'b0,send_addr_0_0x0_1,send_addr_0_0x1_1,send_addr_0_0x1_0}),
    
    .final_output(final_output1[31:0])
);
tile tile_1_0(
    .instruction(instruction[127:63]),
    .rst(rst[1]),
    .clk(clk),
    
    .recv_from_memory_data(32'b0),
    .recv_from_memory_addr(10'b0),
    
    .send_to_memory_data(32'b0),
    .send_to_memory_addr(3'b0),
    
    .recv_from_tile_data({send_data_0_1x1_0,send_data_0_0x1_0,160'b0,send_data_1_1x0_0}),
    .recv_from_tile_addr({send_addr_0_1x1_0,send_addr_0_0x1_0,15'b0,send_addr_1_1x0_0}),
    
    .send_to_tile_data({send_data_1_0x0_1,send_data_1_0x0_0,160'b0,send_data_0_0x1_1}),
    .send_to_tile_addr({send_addr_1_0x0_1,send_addr_1_0x0_0,15'b0,send_addr_0_0x1_1}),
    
    .final_output(final_output1[63:32])
);
tile tile_0_1(
    .instruction(instruction[191:128]),
    .rst(rst[2]),
    .clk(clk),
    
    .recv_from_memory_data(32'b0),
    .recv_from_memory_addr(10'b0),
    
    .send_to_memory_data(32'b0),
    .send_to_memory_addr(3'b0),
    
    .recv_from_tile_data({96'b0,send_data_0_0x0_1,send_data_1_0x0_1,send_data_1_1x0_1,64'b0}),
    .recv_from_tile_addr({9'b0,send_addr_0_0x0_1,send_addr_1_0x0_1,send_addr_1_1x0_1,6'b0}),
    
    .send_to_tile_data({96'b0,send_data_0_1x0_0,send_data_0_1x1_0,send_data_0_1x1_1,64'b0}),
    .send_to_tile_addr({9'b0,send_addr_0_1x0_0,send_addr_0_1x1_0,send_addr_0_1x1_1,6'b0}),
    
    .final_output(final_output1[95:64])
);
tile tile_1_1(
    .instruction(instruction[255:192]),
    .rst(rst[3]),
    .clk(clk),
    
    .recv_from_memory_data(32'b0),
    .recv_from_memory_addr(10'b0),
    
    .send_to_memory_data(32'b0),
    .send_to_memory_addr(3'b0),
    
    .recv_from_tile_data({32'b0,send_data_0_1x1_1,send_data_0_0x1_1,send_data_1_0x1_1,128'b0}),
    .recv_from_tile_addr({3'b0,send_addr_0_1x1_1,send_addr_0_0x1_1,send_addr_1_0x1_1,12'b0}),
    
    .send_to_tile_data({32'b0,send_data_1_1x0_1,send_data_1_1x0_0,send_data_1_1x1_0,128'b0}),
    .send_to_tile_addr({3'b0,send_addr_1_1x0_1,send_addr_1_1x0_0,send_addr_1_1x1_0,12'b0}),
    
    .final_output(final_output1[127:96])
);
    
endmodule