module jtag2 #(
parameter num_of_tiles = 9,
parameter tile_id = 0,
parameter mem_cycles = 4096
)
(
    input clk,
    input data_in,
    input rst,
    input data_valid,
    output reg memory,
    output reg data_out
);
parameter clk_recv_min = num_of_tiles + (tile_id)*mem_cycles;
parameter clk_recv_max = num_of_tiles + (tile_id+1)*mem_cycles;

reg [20:0]clk_recv_count = 0;

always @(posedge clk ) begin
    data_out = data_in;
    if(!rst) begin
        if(clk_recv_count >= clk_recv_min && clk_recv_count <= clk_recv_max) begin
            if(data_valid) begin
                memory <= data_in;
            end
        end
        clk_recv_count <= clk_recv_count + 1;
    end
    else begin
        clk_recv_count = 0;
    end
end

endmodule
