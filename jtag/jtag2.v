module jtag2 #(
parameter num_of_tiles = 9,
parameter tile_id = 0,
parameter mem_cycles = 32768,
)
(
    input clk,
    input data_in,
    input rst,
    output reg memory,
    output reg data_out,
);
parameter clk_recv_min = num_of_tiles + (tile_id)*mem_cycles;
parameter clk_recv_max = num_of_tiles + (tile_id+1)*mem_cycles;

reg data_valid;

reg [1:0]state=2'b00;
reg [20:0]clk_recv_count = 0;

always @(posedge clk ) begin
    data_out = data_in;
    if(!rst) begin
        clk_recv_count = clk_recv_count + 1;
        if(clk_recv_count == clk_recv_min) begin
            data_valid = data_in;
        end

        if(clk_recv_count >= clk_recv_min && clk_recv_count <= clk_recv_max) begin
            case (state)
                2'b00: begin
                    if(data_valid) begin
                        state = 2'b01;
                    end
                end
                2'b01: begin
                    memory = data_in;
                    if(clk_recv_count == clk_recv_max) begin
                        state = 2'b00;
                    end
                end
            endcase
        end
    end
    else begin
        clk_recv_count = 0;
        state = 2'b00;
        data_valid = 0;
    end
end

endmodule
