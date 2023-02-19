/*"""
6 Instructions can be Sent to a tile
    0. Operation(ALU)
    1. Load  - Reg
    2.         Memory
    3. Store - Reg
    4.         Memory
    5. Tile  - Send
    6.         Recieve
"""

"""
2bit Direction of Tiles
N - 00
S - 01
E - 10
W - 11
"""

"""
Instruction Format

64 Bit Instructions

63:32 --> Data
31:25 --> Dummy
24:20 --> Source Register 2
19:15 --> Source Register 1
14:12 --> ALU Function
11:7  --> Destination Register
6:0   --> Opcode

24:7  --> ALU Specific


"""
*/
module tile (
    
    input [63:0] instruction,
    input rst;
    input clk,
    //Data Recieved from other tiles
    input[31:0] recv_from_tile_data,
    input[4:0] recv_from_tile_addr,

    //Data Sent to other tiles
    output[31:0] send_to_tile_data,
    output[31:0] send_to_tile_addr,
    );

    reg [31:0] register [31:0];
    
    alu alu1(
        .in1(rs1),
        .in2(rs2),
        .instruction(instruction[14:12]),
        .en(instruction[0]),
        .out(ALUOUT)
    );

    always @(posedge clk ) begin
        if (!rst) begin
            
        end
        else begin
            
        end
    end

endmodule