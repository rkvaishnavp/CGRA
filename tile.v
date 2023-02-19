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

[14:12] -   Direction Bits
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
module tile (
input instruction[63:0],
input rst;
input clk,

//Data Recieved from Data Memory
input recv_from_memory_data[31:0];
input recv_from_memory_addr[4:0];

//Data Sent to Data Memory
output send_to_memory_data[31:0];
output send_to_memory_addr[9:0];

//Data Recieved from other tiles
input[2:0] recv_from_tile_data[31:0],
input[2:0] recv_from_tile_addr[4:0],

//Data Sent to other tiles
output[2:0] send_to_tile_data[31:0],
output[2:0] send_to_tile_addr[4:0],

//Output from each tile to cgra_output
output [31:0] final_output;
);

reg [31:0] registers [31:0];

wire [31:0]ALUOUT;
wire [31:0]source1data;
wire [31:0]source2data;

alu alu1(
    .in1(source1data),
    .in2(source2data),
    .instruction(instruction[14:12]),
    .en(instruction[0]),
    .out(ALUOUT)
);

assign  source1data = registers[instruction[19:15]];
assign  source2data = registers[instruction[24:20]];

always @(posedge clk ) begin
    if (!instruction[61]) begin
        
    end
end
endmodule
