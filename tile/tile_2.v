`timescale 1ns / 1ps
/*
Types of Instruction: [2:0]
1) Alu using DSP48E             000
2) send data to data memory     001   
3) recv data from data memory   010
4) send data to another tile    011
5) recv from other tile         100
6) send data from reg to output 101
7) reset                        110
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

TODO:
bits [63:36] shall be used for ALU

DSP48E:
Inputs: ????? TODO Data bits for DSP48e will change'
    // Will do as per datasheet
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
    

in program_mode we feed the instruction to tile
While sending data to other tile data is added and then 3 bits of direction

TODO: 
        add DSP48E call

*/
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
    input[255:0] recv_from_tile_data,
    input[4:0] recv_from_tile_addr,

    //Data Sent to other tiles
    output reg [255:0] send_to_tile_data,
    output reg [23:0] send_to_tile_addr,

    //Final Output
    output reg [31:0] tile_output
);

wire jtag_memory;
reg [11:0]addr=0;



jtag2 #(.num_of_tiles(4),.tile_id(tile_id)) jtag0
    (
        .clk(clk),
        .data_in(jtag_data_in),
        .data_valid(program_mode),
        .rst(rst),
        .memory(jtag_memory),
        .data_out(jtag_data_out)
    );

reg [63:0]insmemory[0:5];
reg [47:0]registers[0:3];
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

//DSP48E1 #(
// // Feature Control Attributes: Data Path Selection
// .A_INPUT("DIRECT"),               // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
// .B_INPUT("DIRECT"),               // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
// .USE_DPORT("FALSE"),              // Select D port usage (TRUE or FALSE)
// .USE_MULT("MULTIPLY"),            // Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
// .USE_SIMD("ONE48"),               // SIMD selection ("ONE48", "TWO24", "FOUR12")
// // Pattern Detector Attributes: Pattern Detection Configuration
// .AUTORESET_PATDET("NO_RESET"),    // "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH" 
// .MASK(48'h3fffffffffff),          // 48-bit mask value for pattern detect (1=ignore)
// .PATTERN(48'h000000000000),       // 48-bit pattern match for pattern detect
// .SEL_MASK("MASK"),                // "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2" 
// .SEL_PATTERN("PATTERN"),          // Select pattern value ("PATTERN" or "C")
// .USE_PATTERN_DETECT("NO_PATDET"), // Enable pattern detect ("PATDET" or "NO_PATDET")
// // Register Control Attributes: Pipeline Register Configuration
// .ACASCREG(0),                     // Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
// .ADREG(0),                        // Number of pipeline stages for pre-adder (0 or 1)
// .ALUMODEREG(0),                   // Number of pipeline stages for ALUMODE (0 or 1)
// .AREG(0),                         // Number of pipeline stages for A (0, 1 or 2)
// .BCASCREG(0),                     // Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
// .BREG(0),                         // Number of pipeline stages for B (0, 1 or 2)
// .CARRYINREG(0),                   // Number of pipeline stages for CARRYIN (0 or 1)
// .CARRYINSELREG(0),                // Number of pipeline stages for CARRYINSEL (0 or 1)
// .CREG(0),                         // Number of pipeline stages for C (0 or 1)
// .DREG(0),                         // Number of pipeline stages for D (0 or 1)
// .INMODEREG(0),                    // Number of pipeline stages for INMODE (0 or 1)
// .MREG(0),                         // Number of multiplier pipeline stages (0 or 1)
// .OPMODEREG(0),                    // Number of pipeline stages for OPMODE (0 or 1)
// .PREG(1)                          // Number of pipeline stages for P (0 or 1)
//)
//DSP48E1_inst (
// // Cascade: 30-bit (each) output: Cascade Ports
////  .ACOUT(ACOUT),                   // 30-bit output: A port cascade output
////  .BCOUT(BCOUT),                   // 18-bit output: B port cascade output
////  .CARRYCASCOUT(CARRYCASCOUT),     // 1-bit output: Cascade carry output
////  .MULTSIGNOUT(MULTSIGNOUT),       // 1-bit output: Multiplier sign cascade output
////  .PCOUT(PCOUT),                   // 48-bit output: Cascade output
// // Control: 1-bit (each) output: Control Inputs/Status Bits
// .OVERFLOW(flag[2]),             // 1-bit output: Overflow in add/acc output
// .PATTERNBDETECT(PATTERNBDETECT), // 1-bit output: Pattern bar detect output
// .PATTERNDETECT(PATTERNDETECT),   // 1-bit output: Pattern detect output
// .UNDERFLOW(flag[3]),           // 1-bit output: Underflow in add/acc output
// // Data: 4-bit (each) output: Data Ports
// .CARRYOUT(CARRYOUT),             // 4-bit output: Carry output
// .P(ALUOUT),                      // 48-bit output: Primary data output
// // Cascade: 30-bit (each) input: Cascade Ports
////  .ACIN(ACIN),                     // 30-bit input: A cascade data input
////  .BCIN(BCIN),                     // 18-bit input: B cascade input
////  .CARRYCASCIN(CARRYCASCIN),       // 1-bit input: Cascade carry input
////  .MULTSIGNIN(MULTSIGNIN),         // 1-bit input: Multiplier sign input
////  .PCIN(PCIN),                     // 48-bit input: P cascade input
// // Control: 4-bit (each) input: Control Inputs/Status Bits
// .ALUMODE(ALUMODE),               // 4-bit input: ALU control input
// .CARRYINSEL(CARRYINSEL),         // 3-bit input: Carry select input
// .CLK(CLK),                       // 1-bit input: Clock input
// .INMODE(INMODE),                 // 5-bit input: INMODE control input
// .OPMODE(OPMODE),                 // 7-bit input: Operation mode input
// // Data: 30-bit (each) input: Data Ports
// .A(operand1),                           // 30-bit input: A data input
// .B(operand2),                           // 18-bit input: B data input
// .C(operand3),                           // 48-bit input: C data input
// .CARRYIN(flag[0]),               // 1-bit input: Carry input signal
// .D(operand4),                           // 25-bit input: D data input
// // Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
// .CEA1(CEA1),                     // 1-bit input: Clock enable input for 1st stage AREG
// .CEA2(CEA2),                     // 1-bit input: Clock enable input for 2nd stage AREG
// .CEAD(CEAD),                     // 1-bit input: Clock enable input for ADREG
// .CEALUMODE(alu_en),           // 1-bit input: Clock enable input for ALUMODE
// .CEB1(CEB1),                     // 1-bit input: Clock enable input for 1st stage BREG
// .CEB2(CEB2),                     // 1-bit input: Clock enable input for 2nd stage BREG
// .CEC(CEC),                       // 1-bit input: Clock enable input for CREG
// .CECARRYIN(CECARRYIN),           // 1-bit input: Clock enable input for CARRYINREG
// .CECTRL(CECTRL),                 // 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
// .CED(CED),                       // 1-bit input: Clock enable input for DREG
// .CEINMODE(CEINMODE),             // 1-bit input: Clock enable input for INMODEREG
// .CEM(CEM),                       // 1-bit input: Clock enable input for MREG
// .CEP(CEP),                       // 1-bit input: Clock enable input for PREG
// .RSTA(RSTA),                     // 1-bit input: Reset input for AREG
// .RSTALLCARRYIN(RSTALLCARRYIN),   // 1-bit input: Reset input for CARRYINREG
// .RSTALUMODE(RSTALUMODE),         // 1-bit input: Reset input for ALUMODEREG
// .RSTB(RSTB),                     // 1-bit input: Reset input for BREG
// .RSTC(RSTC),                     // 1-bit input: Reset input for CREG
// .RSTCTRL(RSTCTRL),               // 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
// .RSTD(RSTD),                     // 1-bit input: Reset input for DREG and ADREG
// .RSTINMODE(RSTINMODE),           // 1-bit input: Reset input for INMODEREG
// .RSTM(RSTM),                     // 1-bit input: Reset input for MREG
// .RSTP(RSTP)                      // 1-bit input: Reset input for PREG
//);
DSP48E_custom alu(
    .clk(clk),
    // input data
    .A(operand1[29:0]),
    .B(operand2[17:0]),
    .C(operand3[47:0]),
    .D(operand4[24:0]),
    .CARRYIN(flag[0]),
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
                            send_to_tile_data[31:0] = registers[insmemory[ip][44:41]];
                            send_to_tile_addr[2:0] = registers[insmemory[ip][25:23]];
                        end
                        3'b001: begin
                            send_to_tile_data[63:32] = registers[insmemory[ip][44:41]];
                            send_to_tile_addr[6:3] = registers[insmemory[ip][25:23]];
                        end
                        3'b010: begin
                            send_to_tile_data[95:64] = registers[insmemory[ip][44:41]];
                            send_to_tile_addr[8:6] = registers[insmemory[ip][25:23]];
                        end
                        3'b011: begin
                            send_to_tile_data[127:96] = registers[insmemory[ip][44:41]];
                            send_to_tile_addr[11:9] = registers[insmemory[ip][25:23]];
                        end
                        3'b100: begin
                            send_to_tile_data[159:128] = registers[insmemory[ip][44:41]];
                            send_to_tile_addr[14:12] = registers[insmemory[ip][25:23]];
                        end
                        3'b101: begin
                            send_to_tile_data[191:160] = registers[insmemory[ip][44:41]];
                            send_to_tile_addr[17:15] = registers[insmemory[ip][25:23]];
                        end
                        3'b110: begin
                            send_to_tile_data[223:192] = registers[insmemory[ip][44:41]];
                            send_to_tile_addr[20:18] = registers[insmemory[ip][25:23]];
                        end
                        3'b111: begin
                            send_to_tile_data[255:224] = registers[insmemory[ip][44:41]];
                            send_to_tile_addr[23:21] = registers[insmemory[ip][25:23]];
                        end
                    endcase
                end

                //recv from other tile
                3'b100: begin
                    case (insmemory[ip][25:23])
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
                    tile_output = registers[insmemory[ip][22:19]];
                end

                default: begin
                    //NO Operation
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
