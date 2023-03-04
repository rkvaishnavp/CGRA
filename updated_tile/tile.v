/*
Types of Instruction: [2:0]
1) Alu using DSP48E             000
2) send data to data memory     001   
3) recv data from data memory   010
4) send data to another tile    011
5) recv from other tile         100
6) nop                          101

5 bit for source 1 [7:3]
5 bit for source 2 [12:8]
5 bit for Destination Register [17:13]

Direction Bit [20:18]
    N   -   000
    NE  -   001
    E   -   010
    SE  -   011
    S   -   100
    SW  -   101
    W   -   110
    NW  -   111
    
Interact with Data Memory:
Address                     [29:21]
Tile Reg                    [34:30]

TODO:
Interact with other tile:
Can only interact with 8 nhbrs
5-bit Tile data reg address      [39:35]

DSP48E:
Inputs: [44:40]
    input bits = 3 bit for sel, 2 for mode (may vary)
    A: The first input to the ALU. It can be a signed or unsigned value of up to 25 bits.
    B: The second input to the ALU. It can be a signed or unsigned value of up to 18 bits.
    C: The carry-in input to the ALU. It can be a 1-bit value.
    SEL: A 3-bit input that selects the ALU operation to be performed. The possible values are:
    000: A*B
    001: A+B
    010: A-B
    011: C+A*B
    100: A and B bitwise AND
    101: A or B bitwise OR
    110: A xor B
    111: not used
    Outputs:
    output bits = 50 bits
    P: The output of the ALU. It can be a signed or unsigned value of up to 48 bits.
    COUT: The carry-out output of the ALU. It can be a 1-bit value.
    ZERO: A 1-bit output that indicates whether the output P is zero.
    
8-bit tile_id [62:55]
1 bit Reset [63]

in program_mode we feed the instruction to tile
it calls a checker and if id matches instruction is written to the tile's instruction memory
program_mode = set to 1
execution_mode = set to 0
While sending data to other tile data is added and then 3 bits of direction

TODO: 
        add DSP48E call
        
*/


module tile(
input [7:0] tile_id,
input [63:0] instruction,
input reset,
input clk,
input program_mode,

//Data Recieved from other tiles
input[255:0] recv_from_tile_data,
input[4:0] recv_from_tile_addr,

//Data Sent to other tiles
output reg [255:0] send_to_tile_data,
output reg [23:0] send_to_tile_addr,


output reg [7:0] data_mem_wrt_addr,
output reg [31:0] data_mem_wrt_data,
output reg data_mem_cntrl,
output reg data_mem_valid,

output reg [63:0] instruction_out
);
integer i = 0;
parameter n = 32;
parameter m = 8;
// 32, 8 bit registers
reg [7:0] registers [n-1:0];

// 8, 64 bit instruction memory
reg [63:0] instructions[m-1:0];
reg [3:0] ip; // instruction pointer
reg instruction_wrt;
reg [7:0] data_mem_rd_addr;
reg [31:0] data_mem_rd_data;
reg data_mem_rd_valid;

// _ _ _ _ _ _ Z C
reg [8:0] flag;
reg [49:0] ALUOUT;
wire [31:0] operand1 = registers[instruction[7:3]];
wire [31:0] operand2 = registers[instruction[12:8]];
wire alu_en = (instruction[2:0] == 3'b0) ? 1 : 0;

initial begin
    ip = 4'b0;
end
// In program mode, we fill the memory
// In execution we execute so, we should set ip to 0
// to start from first instruction
always @(posedge program_mode or negedge program_mode)begin
    ip = 4'b0;
end

// TODO: Call to DSP48E



Tile_Checker Chk1(
    .caller_id(tile_id),
    .test_id(instruction[62:55]),
    .clk(clk),
    .wrt(instruction_wrt)
);


always @(posedge clk) begin
    if(!program_mode && instructions[ip][63] != 'b0) begin
        case (instructions[ip] [2:0])
            3'b000 : 
                registers[instructions[ip][17:13]] = ALUOUT;
            3'b001: begin
            // Send data to data Memory
                data_mem_cntrl = 1'b1;
                data_mem_valid = 1'b1;
                data_mem_wrt_addr = instructions[ip][29:21];
                data_mem_wrt_data = registers[instructions[ip][34:30]];
            end
            3'b010: begin
                data_mem_cntrl = 1'b0;
                data_mem_rd_addr = instructions[ip][29:21];
                // TODO: get data from data memory
                // not every tile can do this
            end
            3'b011: begin
                case (instructions[ip][20:18])
                    3'b000: begin
                        send_to_tile_data[31:0] = registers[instructions[ip][39:35]];
                        send_to_tile_addr[2:0] = registers[instructions[ip][20:18]];
                    end
                    3'b001: begin
                        send_to_tile_data[63:32] = registers[instructions[ip][39:35]];
                        send_to_tile_addr[5:3] = registers[instructions[ip][20:18]];
                    end
                    3'b010: begin
                        send_to_tile_data[95:64] = registers[instructions[ip][39:35]];
                        send_to_tile_addr[8:6] = registers[instructions[ip][20:18]];
                    end
                    3'b011: begin
                        send_to_tile_data[127:96] = registers[instructions[ip][39:35]];
                        send_to_tile_addr[11:9] = registers[instructions[ip][20:18]];
                    end
                    3'b100: begin
                        send_to_tile_data[159:128] = registers[instructions[ip][39:35]];
                        send_to_tile_addr[14:12] = registers[instructions[ip][20:18]];
                    end
                    3'b101: begin
                        send_to_tile_data[191:160] = registers[instructions[ip][39:35]];
                        send_to_tile_addr[17:15] = registers[instructions[ip][20:18]];
                    end
                    3'b110: begin
                        send_to_tile_data[223:192] = registers[instructions[ip][39:35]];
                        send_to_tile_addr[20:18] = registers[instructions[ip][20:18]];
                    end
                    3'b111: begin
                        send_to_tile_data[255:224] = registers[instructions[ip][39:35]];
                        send_to_tile_addr[23:21] = registers[instructions[ip][20:18]];
                    end
                endcase
            end
            3'b100: begin
                case (instructions[ip][20:18])
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
            3'b101:
                begin end
        endcase
    end
    else if(!program_mode) begin
        for(i = 0; i < n; i = i + 1) begin
            registers[i] = 8'b0; 
        end
        for(i = 0; i < m; i = i + 1) begin
            instructions[i] = 64'b0;
        end
    end
    else begin
        //  We are in program mode
        if(instruction_wrt)
            instructions[ip] = instruction;
            
        instruction_out = instruction;
    end
    ip = ip + 4'b0001;
end
endmodule
