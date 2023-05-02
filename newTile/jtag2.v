module jtag2 #(
parameter integer num_of_tiles = 4,
parameter integer tile_id = 0,
parameter integer mem_cycles = 4096
)
(
    input clk,
    input data_in,
    input rst,
    input program_mode,
    output reg memory,
    output reg data_out
);
parameter clk_recv_min = (tile_id) + (tile_id)*mem_cycles;
parameter clk_recv_max = clk_recv_min + mem_cycles;

reg [20:0]clk_recv_count = 0;

always @(posedge clk ) begin
    data_out = data_in;
    if(!rst) begin
        if(program_mode) begin
            if(clk_recv_count >= clk_recv_min && clk_recv_count <= clk_recv_max) begin
                    memory <= data_in;
            end
            clk_recv_count <= clk_recv_count + 1;
        end
    end
    else begin
        clk_recv_count = 0;
    end
end

endmodule