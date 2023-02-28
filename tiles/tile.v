/*

Instructions
    1. Alu Operation

    2. send data from reg to other tile
    3. send data from reg to output
    4. send data from reg to data memory

    5. recv data from other tile to reg
    6. recv data from data memory to reg
    7. recv data from instruction to reg

Instruction encoding

[2:0]   -   Opcode
    000 -   ALU
    001 -   send data from reg to other tile
    010 -   send data from reg to output
    011 -   send data from reg to data memory
    100 -   recv data from other tile to reg
    101 -   recv data from data memory to reg
    110 -   recv data from instruction to reg
    111 -   no operation

[5:3]   -   Destination Register

[8:6]   -   Source 1
[11:9]  -   Source 2

[14:12] -   Direction Bit
    N   -   000
    NE  -   001
    E   -   010
    SE  -   011
    S   -   100
    SW  -   101
    W   -   110
    NW  -   111

[18:15] -   ALU Operation/Function
    0000    -   Add
    0001    -   Sub
    0010    -   Mul
    0011    -   Shift Left Logical
    0100    -   Shift Right Logical
    0101    -   Compare(in1<in2)
    0110    -   Compare(in1>in2)
    0111    -   Compare(in1==in2)
    1000    -   OR
    1001    -   AND
    1010    -   
    1011    -
    1100    -
    1101    -
    1110    -
    1111    -

[28:19] -   Destination Memory Address
[60:29] -   Data
[61:61] -   Reset Bit

*/
`include "../alu/alu.v"
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