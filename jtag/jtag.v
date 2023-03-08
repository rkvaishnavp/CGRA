module jtag #(
    parameter num_of_tiles = 9,
    parameter tile_id = 0,
    parameter mem_cycles = 4096
)(
    input data_in,
    input data_valid,
    input clk,
    input rst,
    output reg memory_out[7:0],
    output reg addr[11:0],
    output reg data_out
);

reg [1:0]state = 2'b00;
reg [7:0]id = 0;

reg [2:0]clk_count = 0;
reg [8:0]mem_count = 0;

reg [7:0]memory = 0;

always @(posedge clk ) begin
    if(!rst) begin
        case (state)

            2'b00: begin
                if(data_valid) begin
                    state = 2'b01;
                end
            end

            2'b01: begin
                id[7] <= data_in;
                id = id<<1;
                clk_count = clk_count + 1;
                if(clk_count == 8) begin
                    if(tile_id == id) begin
                        state = 2'b10;
                        clk_count = 0;
                    end
                    else begin
                        state = 2'b11;
                        clk_count = 0;
                    end
                end
            end

            2'b10: begin
                clk_count = clk_count + 1;
                if(clk_count == mem_cycles) begin
                    state = 2'b00;
                    clk_count = 0;
                end
                else begin
                    memory[7] <= data_in;
                    memory = memory<<1;
                    if(clk_count == 8) begin
                        mem_count <= mem_count + 1;
                        memory_out = memory;
                        if(mem_count == mem_cycles) begin
                            mem_count = 0;
                        end
                        clk_count = 0;
                    end
                end
            end

            2'b11: begin
                clk_count = clk_count + 1;
                data_out = id[0];
                id <= id<<1;
                if(clk_count == 8) begin
                    clk_count = 0;
                    state = 2'b00;
                end
            end

        endcase
    end
    else begin
        state = 2'b00;
        memory = 0;
        clk_count = 0;
        mem_count = 0;
        id = 0;
    end
end


endmodule
