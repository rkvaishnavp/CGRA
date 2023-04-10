/*
Types of Instruction: [2:0]
1) Alu using DSP48E             000
2) send data to data memory     001   
3) recv data from data memory   010
4) send data to another tile    011
5) recv from other tile         100
6) send data from reg to output 101
7) nop                          110
8) nop                          111

5 bit for source 1 [6:3]
5 bit for source 2 [10:7]
5 bit for source 3 [14:11]
5 bit for source 4 [18:15]
5 bit for Destination Register [22:19]

Direction Bit [25:23]
    N   -   000
    NE  -   001
    E   -   010
    SE  -   011
    S   -   100
    SW  -   101
    W   -   110
    NW  -   111
    
Interact with Data Memory:
Address                     [35:26]

FOR Using DSP48E1:-
INMODE                      [40:36]
OPMODE                      [47:41]
ALUMODE                     [51:48]

TODO:-
we have yet to Implement Pipelined and Cascaded Stages in DSP48E_Custom
so the instruction size will be increased accordingly and so does instruction memory
size.

In program_mode we feed the instruction to tile
While sending data to other tile data is added and then 3 bits of direction


*/
`include "../DSP48E_custom/DSP48E_custom.v"
`include "../DSP48E_custom/multiplier.v"
`include "../jtag/jtag2.v"
module tile_2 #(tile_id = 0)(
    input rst,
    input clk,

    //JTAG inputs and outputs
    input jtag_data_in,
    output jtag_data_out,

    //To know if its Programming or Not
    input program_mode,

    //Data Recieved from other tiles
    input[383:0] recv_from_tile_data,

    //Data Sent to other tiles
    output reg [383:0] send_to_tile_data,

    //Final Output
    output reg [47:0] tile_output
);

wire jtag_memory;
reg [11:0]addr=0;



jtag2 #(.num_of_tiles(4),.tile_id(tile_id)) jtag
    (
        .clk(clk),
        .data_in(jtag_data_in),
        .program_mode(program_mode),
        .rst(rst),
        .memory(jtag_memory),
        .data_out(jtag_data_out)
    );

reg [63:0]insmemory[0:63];
reg [47:0]registers[0:15];
reg [5:0]ip = 0;
// _ _ _ _ _ _ Z C
wire [8:0] flag;
wire [47:0] ALUOUT;
wire [3:0] CARRYOUT;
reg [4:0] INMODE;
reg [6:0] OPMODE;
reg [3:0] ALUMODE;
reg [2:0] CARRRYINSEL;
reg [47:0] operand1; // A
reg [47:0] operand2; // B
reg [47:0] operand3; // C
reg [47:0] operand4; // D
reg alu_en;

DSP48E_custom alu(
    .clk(clk),
    // input data
    .A(operand1[29:0]),
    .B(operand2[17:0]),
    .C(operand3[47:0]),
    .D(operand4[24:0]),
    .CARRYIN(flag[0]),
    .alu_en(alu_en),
    // control strings
    .ALUMODE(ALUMODE),
    .OPMODE(OPMODE),
    .INMODE(INMODE),
    .P(ALUOUT)
);
integer i, j;
always @(posedge clk ) begin
    if(!rst) begin
        if(program_mode) begin
            ip = 0;
            insmemory[addr/64][addr%64] = jtag_memory;
            addr = addr + 1;
        end
        else begin
            addr = 0;
            case (insmemory[ip][2:0])
                3'b000 : begin
                    INMODE = insmemory[ip][49:45];
                    OPMODE = insmemory[ip][56:50];
                    ALUMODE = insmemory[ip][60:57];
                    CARRRYINSEL = insmemory[ip][63:61];
                    operand1 = registers[insmemory[ip][6:3]];
                    operand2 = registers[insmemory[ip][10:7]];
                    operand3 = registers[insmemory[ip][14:11]];
                    operand4 = registers[insmemory[ip][18:15]];
                    alu_en = (insmemory[ip][2:0] == 3'b0) ? 1 : 0;
                    registers[insmemory[ip][22:19]] = ALUOUT;
                end

                //send data to data memory
                //recv data from data memory

                //send data to another tile
                3'b011: begin
                    case (insmemory[ip][25:23])
                        3'b000: begin
                            send_to_tile_data[47:0] = registers[insmemory[ip][6:3]];
                        end
                        3'b001: begin
                            send_to_tile_data[95:48] = registers[insmemory[ip][6:3]];
                        end
                        3'b010: begin
                            send_to_tile_data[143:96] = registers[insmemory[ip][6:3]];
                        end
                        3'b011: begin
                            send_to_tile_data[191:144] = registers[insmemory[ip][6:3]];
                        end
                        3'b100: begin
                            send_to_tile_data[239:192] = registers[insmemory[ip][6:3]];
                        end
                        3'b101: begin
                            send_to_tile_data[287:240] = registers[insmemory[ip][6:3]];
                        end
                        3'b110: begin
                            send_to_tile_data[335:288] = registers[insmemory[ip][6:3]];
                        end
                        3'b111: begin
                            send_to_tile_data[383:336] = registers[insmemory[ip][6:3]];
                        end
                    endcase
                end

                //recv from other tile
                3'b100: begin
                    case (insmemory[ip][25:23])
                        3'b000: begin
                            registers[insmemory[ip][22:19]] = recv_from_tile_data[47:0];
                        end
                        3'b001: begin
                            registers[insmemory[ip][22:19]] = recv_from_tile_data[95:48];
                        end
                        3'b010: begin
                            registers[insmemory[ip][22:19]] = recv_from_tile_data[143:96];
                        end
                        3'b011: begin
                            registers[insmemory[ip][22:19]] = recv_from_tile_data[191:144];
                        end
                        3'b100: begin
                            registers[insmemory[ip][22:19]] = recv_from_tile_data[239:192];
                        end
                        3'b101: begin
                            registers[insmemory[ip][22:19]] = recv_from_tile_data[287:240];
                        end
                        3'b110: begin
                            registers[insmemory[ip][22:19]] = recv_from_tile_data[335:288];
                        end
                        3'b111: begin
                            registers[insmemory[ip][22:19]] = recv_from_tile_data[383:336];
                        end
                    endcase
                end

                3'b101: begin
                    tile_output = registers[insmemory[ip][6:3]];
                end
            endcase
            ip = ip + 1;
        end
    end
    else begin
        ip = 0;
        for(i = 0;i<64;i = i + 1) begin
            insmemory[i] = 0;
        end
        for(j = 0;j<16;j = j + 1) begin
            registers[j] = 0;
        end
    end
end
endmodule