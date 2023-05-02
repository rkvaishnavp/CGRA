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
    

FOR Using DSP48E1:-
ALUMODE                     [24:21]

Interact with Data Memory:
Address                     ?



In program_mode we feed the instruction to tile
While sending data to other tile data is added and then 3 bits of direction


*/
//`include "../DSP48E_custom/DSP48E_custom.v"
//`include "../DSP48E_custom/multiplier.v"
//`include "../jtag/jtag2.v"
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

reg [63:0]insmemory[0:127];
reg [31:0]registers[0:31];
reg [6:0]ip = 0;
// _ _ _ _ O E L Z
wire [8:0] flag;
wire [31:0] ALUOUT;
wire CARRYOUT;
reg [3:0] ALUMODE;
reg [2:0] CARRRYINSEL;
reg [31:0] operand1; // A
reg [31:0] operand2; // B
//reg alu_en;
reg DataValid;
ALU fu(
    .clk(clk),
    .A(operand1),
    .B(operand2),
    .S(ALUOUT),
    .carry(CARRYOUT),
    .overflow(flag[3]),
    .equalto(flag[2]),
    .lessthan(flag[1]),
    .zero(flag[0]),
    .control(ALUMODE)
);

integer i, j;
integer row = 0;
integer element = 0;
parameter mem_cycles = 4096;
parameter clk_recv_min = (tile_id) + (tile_id)*mem_cycles;
parameter clk_recv_max = clk_recv_min + mem_cycles;
reg [20:0]clk_recv_count = 0;


always @(posedge clk ) begin
    if(!rst) begin
        if(program_mode && (clk_recv_count >= clk_recv_min && clk_recv_count <= clk_recv_max)) begin 
        // ensure insmemory is written to only during clock_recv_count
            ip = 0;
            insmemory[row][element] = jtag_memory;
            if(element == 63) begin
                row = row + 1;
                element = 0;
            end
            else element = element + 1;
            clk_recv_count <= clk_recv_count + 1;
        end
        else begin
            addr = 0;
            case (insmemory[ip][2:0])
                3'b000 : begin
                    ALUMODE = insmemory[ip][24:21];
                    operand1 = registers[insmemory[ip][7:3]];
                    operand2 = registers[insmemory[ip][12:8]];
//                    alu_en = (insmemory[ip][2:0] == 3'b0) ? 1 : 0;
//                    
                end

                //send data to data memory
                //recv data from data memory

                //send data to another tile
                3'b011: begin
                    case (insmemory[ip][20:18])
                        3'b000: begin
                            send_to_tile_data[31:0] = registers[insmemory[ip][7:3]];
                        end
                        3'b001: begin
                            send_to_tile_data[63:32] = registers[insmemory[ip][7:3]];
                        end
                        3'b010: begin
                            send_to_tile_data[95:64] = registers[insmemory[ip][7:3]];
                        end
                        3'b011: begin
                            send_to_tile_data[127:96] = registers[insmemory[ip][7:3]];
                        end
                        3'b100: begin
                            send_to_tile_data[159:128] = registers[insmemory[ip][7:3]];
                        end
                        3'b101: begin
                            send_to_tile_data[191:160] = registers[insmemory[ip][7:3]];
                        end
                        3'b110: begin
                            send_to_tile_data[223:192] = registers[insmemory[ip][7:3]];
                        end
                        3'b111: begin
                            send_to_tile_data[255:224] = registers[insmemory[ip][7:3]];
                        end
                    endcase
                end

                //recv from other tile
                3'b100: begin
                    case (insmemory[ip][20:18])
                        3'b000: begin
                            registers[insmemory[ip][17:13]] = recv_from_tile_data[31:0];
                        end
                        3'b001: begin
                            registers[insmemory[ip][17:13]] = recv_from_tile_data[63:32];
                        end
                        3'b010: begin
                            registers[insmemory[ip][17:13]] = recv_from_tile_data[95:64];
                        end
                        3'b011: begin
                            registers[insmemory[ip][17:13]] = recv_from_tile_data[127:96];
                        end
                        3'b100: begin
                            registers[insmemory[ip][17:13]] = recv_from_tile_data[159:128];
                        end
                        3'b101: begin
                            registers[insmemory[ip][17:13]] = recv_from_tile_data[191:160];
                        end
                        3'b110: begin
                            registers[insmemory[ip][17:13]] = recv_from_tile_data[223:192];
                        end
                        3'b111: begin
                            registers[insmemory[ip][17:13]] = recv_from_tile_data[255:224];
                        end
                    endcase
                end

                3'b101: begin
                    tile_output = registers[insmemory[ip][17:13]];
                end
            endcase
//            ip = ip + 1;
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
always @(negedge clk) begin
    if (insmemory[ip][2:0] == 3'b0)
        registers[insmemory[ip][17:13]] <= ALUOUT;
    ip = ip + 1;
end
endmodule