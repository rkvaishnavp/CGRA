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
    1000    -
    1001    -
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
module alu (
    in1, in2, en, instruction, out
);

input [31:0]in1;
input [31:0]in2;
input en;
input [18:15]instruction;
output [31:0] out;

reg [31:0] ALUOUT;

assign out = ALUOUT;

always @(*) begin
    if (en) begin
        case (instruction)
            4'b0000: begin
                ALUOUT = in1 + in2;
            end
            4'b0001: begin
                ALUOUT = in1 - in2;
            end
            4'b0010: begin
                ALUOUT = in1[15:0] * in2[15:0];
            end
            4'b0011: begin
                ALUOUT = in1 << in2;
            end
            4'b0100: begin
                ALUOUT = in1 >> in2;
            end
            4'b0101: begin
                ALUOUT = (in1 < in2)?32'b1:32'b0;
            end
            4'b0110: begin
                ALUOUT = (in1 > in2)?32'b1:32'b0;
            end
            4'b0111: begin
                ALUOUT = (in1 == in2)?32'b1:32'b0;
            end
        endcase
    end
    else begin
        ALUOUT = 32'b0;
    end
end
endmodule

module tile (
input instruction[63:0],
input rst;
input clk,

//Data Recieved from Data Memory
input[31:0] recv_from_memory_data;
input[2:0] recv_from_memory_addr;

//Data Sent to Data Memory
output[31:0] send_to_memory_data;
output[9:0] send_to_memory_addr;

//Data Recieved from other tiles
input[31:0] recv_from_tile_data[2:0],
input[2:0] recv_from_tile_addr[2:0],

//Data Sent to other tiles
output[31:0] send_to_tile_data[2:0],
output[2:0] send_to_tile_addr[2:0],

//Output from each tile to cgra_output
output [31:0] final_output;
);
parameter i = 0;
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
                send_to_tile_data[instruction[14:12]] = registers[instruction[8:6]];
                send_to_tile_addr[instruction[14:12]] = instruction[5:3]
            end

            3'b010: begin
                final_output = registers[instruction[8:6]];
            end

            3'b011: begin
                send_to_memory_data = registers[instruction[8:6]];
                send_to_memory_addr = instruction[28:19];
            end

            3'b100: begin
                registers[recv_from_tile_addr] = recv_from_tile_data[instruction[14:12]];
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
    elif begin
        for(i, i<n, i++) begin
            registers[i] = 32'b0;
        end
    end
end
endmodule