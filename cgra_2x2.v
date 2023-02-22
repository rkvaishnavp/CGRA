module alu (
    in1, in2, en, instruction, out
);

input [31:0]in1;
input [31:0]in2;
input en;
input [18:15]instruction;
output reg [31:0] out;

always@(*) begin
    if (en) begin
        case (instruction)
            4'b0000: begin
                out = in1 + in2;
            end
            4'b0001: begin
                out = in1 - in2;
            end
            4'b0010: begin
                out = in1[15:0] * in2[15:0];
            end
            4'b0011: begin
                out = in1 << in2;
            end
            4'b0100: begin
                out = in1 >> in2;
            end
            4'b0101: begin
                out = (in1 < in2)?32'b1:32'b0;
            end
            4'b0110: begin
                out = (in1 > in2)?32'b1:32'b0;
            end
            4'b0111: begin
                out = (in1 == in2)?32'b1:32'b0;
            end
            4'b1000: begin
                out = in1 | in2;
            end
            4'b1001: begin
                out = in1 & in2;
            end
        endcase
    end
    else begin
        out = 32'b0;
    end
end
endmodule
module tile (
input [63:0]instruction,
input rst,
input clk,

//Data Recieved from Data Memory
input[31:0] recv_from_memory_data,
input[2:0] recv_from_memory_addr,

//Data Sent to Data Memory
output reg [31:0] send_to_memory_data,
output reg [9:0] send_to_memory_addr,

//Data Recieved from other tiles
input[255:0] recv_from_tile_data,
input[23:0] recv_from_tile_addr,

//Data Sent to other tiles
output reg [255:0] send_to_tile_data,
output reg [23:0] send_to_tile_addr,

//Output from each tile to cgra_output
output reg [31:0] final_output
);
integer i = 0;
integer j = 0;
parameter n = 8;

reg [7:0] registers [31:0];

wire [31:0]ALUOUT;
wire [31:0]source1data;
wire [31:0]source2data;
wire alu_en = (instruction[2:0]==000)? 1 : 0;

alu alu1(
    .in1(source1data),
    .in2(source2data),
    .instruction(instruction[18:15]),
    .en(alu_en),
    .out(ALUOUT)
);

assign  source1data = registers[instruction[19:15]];
assign  source2data = registers[instruction[24:20]];

always @(posedge clk ) begin
    if (!instruction[61]) begin
        case (instruction[2:0])
            
            3'b000: begin
                registers[instruction[5:3]] = ALUOUT; 
            end

            3'b001: begin
                case (instruction[14:12])
                    3'b000: begin
                        send_to_tile_data[31:0] = registers[instruction[8:6]];
                        send_to_tile_addr[2:0] = registers[instruction[8:6]];
                    end
                    3'b001: begin
                        send_to_tile_data[63:32] = registers[instruction[8:6]];
                        send_to_tile_addr[5:3] = registers[instruction[8:6]];
                    end
                    3'b010: begin
                        send_to_tile_data[95:64] = registers[instruction[8:6]];
                        send_to_tile_addr[8:6] = registers[instruction[8:6]];
                    end
                    3'b011: begin
                        send_to_tile_data[127:96] = registers[instruction[8:6]];
                        send_to_tile_addr[11:9] = registers[instruction[8:6]];
                    end
                    3'b100: begin
                        send_to_tile_data[159:128] = registers[instruction[8:6]];
                        send_to_tile_addr[14:12] = registers[instruction[8:6]];
                    end
                    3'b101: begin
                        send_to_tile_data[191:160] = registers[instruction[8:6]];
                        send_to_tile_addr[17:15] = registers[instruction[8:6]];
                    end
                    3'b110: begin
                        send_to_tile_data[223:192] = registers[instruction[8:6]];
                        send_to_tile_addr[20:18] = registers[instruction[8:6]];
                    end
                    3'b111: begin
                        send_to_tile_data[255:224] = registers[instruction[8:6]];
                        send_to_tile_addr[23:21] = registers[instruction[8:6]];
                    end
                endcase
            end

            3'b010: begin
                final_output = registers[instruction[8:6]];
            end

            3'b011: begin
                send_to_memory_data = registers[instruction[8:6]];
                send_to_memory_addr = instruction[28:19];
            end

            3'b100: begin
                case (instruction[14:12])
                    3'b000: begin
                        registers[recv_from_tile_addr] = recv_from_tile_data[31:0];
                    end
                    3'b001: begin
                        registers[recv_from_tile_addr] = recv_from_tile_data[63:32];
                    end
                    3'b010: begin
                        registers[recv_from_tile_addr] = recv_from_tile_data[95:64];
                    end
                    3'b011: begin
                        registers[recv_from_tile_addr] = recv_from_tile_data[127:96];
                    end
                    3'b100: begin
                        registers[recv_from_tile_addr] = recv_from_tile_data[159:128];
                    end
                    3'b101: begin
                        registers[recv_from_tile_addr] = recv_from_tile_data[191:160];
                    end
                    3'b110: begin
                        registers[recv_from_tile_addr] = recv_from_tile_data[223:192];
                    end
                    3'b111: begin
                        registers[recv_from_tile_addr] = recv_from_tile_data[255:224];
                    end
                endcase
            end

            3'b101: begin
                registers[recv_from_memory_addr] = recv_from_memory_data;
            end

            3'b110: begin
                registers[instruction[14:12]] = instruction[60:29];
            end
            /*default:*/ 
        endcase
    end
    else begin
        for(i=0 ; i<n; i=i+1 ) begin
            registers[i] = 32'b0;
        end
    end
end
endmodule
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