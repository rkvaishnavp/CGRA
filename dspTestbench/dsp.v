`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.05.2023 00:17:33
// Design Name: 
// Module Name: dsp
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dsp(
input clk,
input [29:0] A,
input [17:0] B,
input [47:0] C,
input [24:0] D,
input CIN,
input [6:0] OPMODE,
input [3:0] ALUMODE,
input [4:0] INMODE,
output [4:0] COUT,
output [47:0] P
    );
DSP48E1 #(
      // Feature Control Attributes: Data Path Selection
      .A_INPUT("DIRECT"),               // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
      .B_INPUT("DIRECT"),               // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
      .USE_DPORT("TRUE"),              // Select D port usage (TRUE or FALSE)
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
      .AREG(2),                         // Number of pipeline stages for A (0, 1 or 2)
      .BCASCREG(1),                     // Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
      .BREG(2),                         // Number of pipeline stages for B (0, 1 or 2)
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
//      .ACOUT(ACOUT),                   // 30-bit output: A port cascade output
//      .BCOUT(BCOUT),                   // 18-bit output: B port cascade output
//      .CARRYCASCOUT(CARRYCASCOUT),     // 1-bit output: Cascade carry output
//      .MULTSIGNOUT(MULTSIGNOUT),       // 1-bit output: Multiplier sign cascade output
//      .PCOUT(PCOUT),                   // 48-bit output: Cascade output
      // Control: 1-bit (each) output: Control Inputs/Status Bits
//      .OVERFLOW(OVERFLOW),             // 1-bit output: Overflow in add/acc output
//      .PATTERNBDETECT(PATTERNBDETECT), // 1-bit output: Pattern bar detect output
//      .PATTERNDETECT(PATTERNDETECT),   // 1-bit output: Pattern detect output
//      .UNDERFLOW(UNDERFLOW),           // 1-bit output: Underflow in add/acc output
      // Data: 4-bit (each) output: Data Ports
      .CARRYOUT(COUT),             // 4-bit output: Carry output
      .P(P),                           // 48-bit output: Primary data output
      // Cascade: 30-bit (each) input: Cascade Ports
//      .ACIN(ACIN),                     // 30-bit input: A cascade data input
//      .BCIN(BCIN),                     // 18-bit input: B cascade input
//      .CARRYCASCIN(CARRYCASCIN),       // 1-bit input: Cascade carry input
//      .MULTSIGNIN(MULTSIGNIN),         // 1-bit input: Multiplier sign input
//      .PCIN(PCIN),                     // 48-bit input: P cascade input
      // Control: 4-bit (each) input: Control Inputs/Status Bits
      .ALUMODE(ALUMODE),               // 4-bit input: ALU control input
      .CARRYINSEL(3'b0),         // 3-bit input: Carry select input
      .CLK(clk),                       // 1-bit input: Clock input
      .INMODE(INMODE),                 // 5-bit input: INMODE control input
      .OPMODE(OPMODE),                 // 7-bit input: Operation mode input
      // Data: 30-bit (each) input: Data Ports
      .A(A),                           // 30-bit input: A data input
      .B(B),                           // 18-bit input: B data input
      .C(C),                           // 48-bit input: C data input
      .CARRYIN(CIN),               // 1-bit input: Carry input signal
      .D(D),                           // 25-bit input: D data input
      // Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
      .CEA1(1'b1),                     // 1-bit input: Clock enable input for 1st stage AREG
      .CEA2(1'b1),                     // 1-bit input: Clock enable input for 2nd stage AREG
      .CEAD(1'b1),                     // 1-bit input: Clock enable input for ADREG
      .CEALUMODE(1'b1),           // 1-bit input: Clock enable input for ALUMODE
      .CEB1(1'b1),                     // 1-bit input: Clock enable input for 1st stage BREG
      .CEB2(1'b1),                     // 1-bit input: Clock enable input for 2nd stage BREG
      .CEC(1'b1),                       // 1-bit input: Clock enable input for CREG
      .CECARRYIN(1'b1),           // 1-bit input: Clock enable input for CARRYINREG
      .CECTRL(1'b1),                 // 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
      .CED(1'b1),                       // 1-bit input: Clock enable input for DREG
      .CEINMODE(1'b1),             // 1-bit input: Clock enable input for INMODEREG
      .CEM(1'b1),                       // 1-bit input: Clock enable input for MREG
      .CEP(1'b1),                       // 1-bit input: Clock enable input for PREG
      .RSTA(1'b0),                     // 1-bit input: Reset input for AREG
      .RSTALLCARRYIN(1'b0),   // 1-bit input: Reset input for CARRYINREG
      .RSTALUMODE(1'b0),         // 1-bit input: Reset input for ALUMODEREG
      .RSTB(1'b0),                     // 1-bit input: Reset input for BREG
      .RSTC(1'b0),                     // 1-bit input: Reset input for CREG
      .RSTCTRL(1'b0),               // 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
      .RSTD(),                     // 1-bit input: Reset input for DREG and ADREG
      .RSTINMODE(1'b0),           // 1-bit input: Reset input for INMODEREG
      .RSTM(1'b0),                     // 1-bit input: Reset input for MREG
      .RSTP(1'b0)                      // 1-bit input: Reset input for PREG
   );
endmodule
