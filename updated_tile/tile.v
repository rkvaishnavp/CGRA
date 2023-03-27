/*
Types of Instruction: [2:0]
1) Alu using DSP48E             000
2) send data to data memory     001   
3) recv data from data memory   010
4) send data to another tile    011
5) recv from other tile         100
6) nop                          101

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
Tile Reg                    [40:36]

TODO:
Interact with other tile:
Can only interact with 8 nhbrs
5-bit Tile data reg address      [44:41]

DSP48E:
Inputs: ????? TODO Data bits for DSP48e will change'
    5bit INMODE [49:45]
    7bit OPMODE [56:50]
    4bit ALUMODE[60:57]
    3bit CARRRYINSEL[63:61]

in program_mode we feed the instruction to tile
it calls a checker and if id matches instruction is written to the tile's instruction memory
program_mode = set to 1
execution_mode = set to 0
While sending data to other tile data is added and then 3 bits of direction

TODO: 
        add DSP48E call
        
*/


module tile(
input [7:0] target_id,
input [7:0] tile_id,
input [63:0] instruction, // JTAG
input reset,
input clk,
input program_mode,

// input from data memory
input [31:0] data_from_mem,
input data_valid_from_mem,

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
parameter n = 8;
parameter m = 8;
// n, 32 bit registers
// TODO: change to 48 as largest data in ALU is 48 bit
// or we can keep them 0
reg [31:0] registers [n-1:0];

// 8, 64 bit instruction memory
reg [63:0] instructions[m-1:0];
reg [3:0] ip; // instruction pointer
reg instruction_wrt;
reg [7:0] data_mem_rd_addr;
reg [31:0] data_mem_rd_data;
reg data_mem_rd_valid;

// _ _ _ _ _ _ Z C
reg [8:0] flag;
reg [47:0] ALUOUT; // Assign to P
reg [3:0] CARRYOUT;
wire [4:0] INMODE = instruction[49:45];
wire [6:0] OPMODE = instruction[56:50];
wire [3:0] ALUMODE = instruction[60:57];
wire [2:0] CARRRYINSEL = instruction[63:61];
wire [31:0] operand1 = registers[instruction[6:3]]; // A
wire [31:0] operand2 = registers[instruction[10:7]]; // B
wire [31:0] operand3 = registers[instruction[14:11]]; // C
wire [31:0] operand4 = registers[instruction[18:15]]; // D
wire alu_en = (instruction[2:0] == 3'b0) ? 1 : 0;


// In program mode, we fill the memory
// In execution we execute so, we should set ip to 0
// to start from first instruction
always @(program_mode)begin
    ip = 4'b0;
    instruction_wrt = 1'b0;
end

// TODO: Call to DSP48E
DSP48E1 #(
  // Feature Control Attributes: Data Path Selection
  .A_INPUT("DIRECT"),               // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
  .B_INPUT("DIRECT"),               // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
  .USE_DPORT("FALSE"),              // Select D port usage (TRUE or FALSE)
  .USE_MULT("MULTIPLY"),            // Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
  .USE_SIMD("ONE48"),               // SIMD selection ("ONE48", "TWO24", "FOUR12")
  // Pattern Detector Attributes: Pattern Detection Configuration
  .AUTORESET_PATDET("NO_RESET"),    // "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH" 
  .MASK(48'h3fffffffffff),          // 48-bit mask value for pattern detect (1=ignore)
  .PATTERN(48'h000000000000),       // 48-bit pattern match for pattern detect
  .SEL_MASK("MASK"),                // "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2" 
  .SEL_PATTERN("PATTERN"),          // Select pattern value ("PATTERN" or "C")
  .USE_PATTERN_DETECT("NO_PATDET"), // Enable pattern detect ("PATDET" or "NO_PATDET")
  // Register Control Attributes: Pipeline Register Configuration
  .ACASCREG(1),                     // Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
  .ADREG(1),                        // Number of pipeline stages for pre-adder (0 or 1)
  .ALUMODEREG(1),                   // Number of pipeline stages for ALUMODE (0 or 1)
  .AREG(1),                         // Number of pipeline stages for A (0, 1 or 2)
  .BCASCREG(1),                     // Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
  .BREG(1),                         // Number of pipeline stages for B (0, 1 or 2)
  .CARRYINREG(1),                   // Number of pipeline stages for CARRYIN (0 or 1)
  .CARRYINSELREG(1),                // Number of pipeline stages for CARRYINSEL (0 or 1)
  .CREG(1),                         // Number of pipeline stages for C (0 or 1)
  .DREG(1),                         // Number of pipeline stages for D (0 or 1)
  .INMODEREG(1),                    // Number of pipeline stages for INMODE (0 or 1)
  .MREG(1),                         // Number of multiplier pipeline stages (0 or 1)
  .OPMODEREG(1),                    // Number of pipeline stages for OPMODE (0 or 1)
  .PREG(1)                          // Number of pipeline stages for P (0 or 1)
)
DSP48E1_inst (
  // Cascade: 30-bit (each) output: Cascade Ports
  .ACOUT(ACOUT),                   // 30-bit output: A port cascade output
  .BCOUT(BCOUT),                   // 18-bit output: B port cascade output
  .CARRYCASCOUT(CARRYCASCOUT),     // 1-bit output: Cascade carry output
  .MULTSIGNOUT(MULTSIGNOUT),       // 1-bit output: Multiplier sign cascade output
  .PCOUT(PCOUT),                   // 48-bit output: Cascade output
  // Control: 1-bit (each) output: Control Inputs/Status Bits
  .OVERFLOW(OVERFLOW),             // 1-bit output: Overflow in add/acc output
  .PATTERNBDETECT(PATTERNBDETECT), // 1-bit output: Pattern bar detect output
  .PATTERNDETECT(PATTERNDETECT),   // 1-bit output: Pattern detect output
  .UNDERFLOW(UNDERFLOW),           // 1-bit output: Underflow in add/acc output
  // Data: 4-bit (each) output: Data Ports
  .CARRYOUT(CARRYOUT),             // 4-bit output: Carry output
  .P(ALUOUT),                      // 48-bit output: Primary data output
  // Cascade: 30-bit (each) input: Cascade Ports
  .ACIN(ACIN),                     // 30-bit input: A cascade data input
  .BCIN(BCIN),                     // 18-bit input: B cascade input
  .CARRYCASCIN(CARRYCASCIN),       // 1-bit input: Cascade carry input
  .MULTSIGNIN(MULTSIGNIN),         // 1-bit input: Multiplier sign input
  .PCIN(PCIN),                     // 48-bit input: P cascade input
  // Control: 4-bit (each) input: Control Inputs/Status Bits
  .ALUMODE(ALUMODE),               // 4-bit input: ALU control input
  .CARRYINSEL(CARRYINSEL),         // 3-bit input: Carry select input
  .CLK(CLK),                       // 1-bit input: Clock input
  .INMODE(INMODE),                 // 5-bit input: INMODE control input
  .OPMODE(OPMODE),                 // 7-bit input: Operation mode input
  // Data: 30-bit (each) input: Data Ports
  .A(operand1),                           // 30-bit input: A data input
  .B(operand2),                           // 18-bit input: B data input
  .C(operand3),                           // 48-bit input: C data input
  .CARRYIN(flag[0]),               // 1-bit input: Carry input signal
  .D(operand4),                           // 25-bit input: D data input
  // Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
  .CEA1(CEA1),                     // 1-bit input: Clock enable input for 1st stage AREG
  .CEA2(CEA2),                     // 1-bit input: Clock enable input for 2nd stage AREG
  .CEAD(CEAD),                     // 1-bit input: Clock enable input for ADREG
  .CEALUMODE(CEALUMODE),           // 1-bit input: Clock enable input for ALUMODE
  .CEB1(CEB1),                     // 1-bit input: Clock enable input for 1st stage BREG
  .CEB2(CEB2),                     // 1-bit input: Clock enable input for 2nd stage BREG
  .CEC(CEC),                       // 1-bit input: Clock enable input for CREG
  .CECARRYIN(CECARRYIN),           // 1-bit input: Clock enable input for CARRYINREG
  .CECTRL(CECTRL),                 // 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
  .CED(CED),                       // 1-bit input: Clock enable input for DREG
  .CEINMODE(CEINMODE),             // 1-bit input: Clock enable input for INMODEREG
  .CEM(CEM),                       // 1-bit input: Clock enable input for MREG
  .CEP(CEP),                       // 1-bit input: Clock enable input for PREG
  .RSTA(RSTA),                     // 1-bit input: Reset input for AREG
  .RSTALLCARRYIN(RSTALLCARRYIN),   // 1-bit input: Reset input for CARRYINREG
  .RSTALUMODE(RSTALUMODE),         // 1-bit input: Reset input for ALUMODEREG
  .RSTB(RSTB),                     // 1-bit input: Reset input for BREG
  .RSTC(RSTC),                     // 1-bit input: Reset input for CREG
  .RSTCTRL(RSTCTRL),               // 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
  .RSTD(RSTD),                     // 1-bit input: Reset input for DREG and ADREG
  .RSTINMODE(RSTINMODE),           // 1-bit input: Reset input for INMODEREG
  .RSTM(RSTM),                     // 1-bit input: Reset input for MREG
  .RSTP(RSTP)                      // 1-bit input: Reset input for PREG
);


Tile_Checker Chk1(
    .caller_id(tile_id),
    .test_id(target_id),
    .clk(clk),
    .wrt(instruction_wrt)
);


always @(posedge clk) begin
    if(!program_mode && !reset) begin
        case (instructions[ip] [2:0])
            3'b000 : 
                registers[instructions[ip][22:19]] = ALUOUT;
            3'b001: begin
            // Send data to data Memory
                data_mem_cntrl = 1'b1;
                data_mem_valid = 1'b1;
                data_mem_wrt_addr = instructions[ip][35:26];
                data_mem_wrt_data = registers[instructions[ip][31:28]];
            end
            3'b010: begin
                data_mem_cntrl = 1'b0;
                data_mem_rd_addr = instructions[ip][35:26];
                registers[instructions[ip][31:28]] = data_from_mem;
                data_mem_rd_valid = data_valid_from_mem;
            end
            3'b011: begin
                case (instructions[ip][25:23])
                    3'b000: begin
                        send_to_tile_data[31:0] = registers[instructions[ip][44:41]];
                        send_to_tile_addr[2:0] = registers[instructions[ip][25:23]];
                    end
                    3'b001: begin
                        send_to_tile_data[63:32] = registers[instructions[ip][44:41]];
                        send_to_tile_addr[6:3] = registers[instructions[ip][25:23]];
                    end
                    3'b010: begin
                        send_to_tile_data[95:64] = registers[instructions[ip][44:41]];
                        send_to_tile_addr[8:6] = registers[instructions[ip][25:23]];
                    end
                    3'b011: begin
                        send_to_tile_data[127:96] = registers[instructions[ip][44:41]];
                        send_to_tile_addr[11:9] = registers[instructions[ip][25:23]];
                    end
                    3'b100: begin
                        send_to_tile_data[159:128] = registers[instructions[ip][44:41]];
                        send_to_tile_addr[14:12] = registers[instructions[ip][25:23]];
                    end
                    3'b101: begin
                        send_to_tile_data[191:160] = registers[instructions[ip][44:41]];
                        send_to_tile_addr[17:15] = registers[instructions[ip][25:23]];
                    end
                    3'b110: begin
                        send_to_tile_data[223:192] = registers[instructions[ip][44:41]];
                        send_to_tile_addr[20:18] = registers[instructions[ip][25:23]];
                    end
                    3'b111: begin
                        send_to_tile_data[255:224] = registers[instructions[ip][44:41]];
                        send_to_tile_addr[23:21] = registers[instructions[ip][25:23]];
                    end
                endcase
            end
            3'b100: begin
                case (instructions[ip][25:23])
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
            registers[i] = 32'b0; 
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
