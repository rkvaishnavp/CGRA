`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.04.2023 21:05:14
// Design Name: 
// Module Name: DSP48E_custom
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


module DSP48E_custom
(
    input clk,
    // input data
    input [29:0] A,
    input [17:0] B,
    input [47:0] C,
    input [24:0] D,
    input CARRYIN,
    input alu_en,
    // control strings
    input [3:0] ALUMODE,
    input [6:0] OPMODE,
    input [4:0] INMODE,
    // output data
    output reg [47:0] P
//    output reg OVERFLOW,
//    output reg UNDERFLOW,
//    output PATTERNBDETECT,
//    output PATTERNDETECT
    );
//------------------- constants -------------------------
//    localparam MAX_CARRYOUT   = 4;
//    localparam MAX_P          = 48;
//    localparam MAX_A          = 30;
//    localparam MAX_A_MULT     = 25;
//    localparam MAX_B          = 18;
//    localparam MAX_B_MULT     = 18;
//    localparam MAX_C          = 48;
//    localparam MAX_D          = 25;
//    localparam MAX_ALUMODE    = 4;
//    localparam MAX_OPMODE     = 7;
//    localparam MAX_INMODE     = 5;
//    // TODO: 
//    localparam MAX_ALU_FULL   = 48;
//    localparam MAX_ALU_HALF   = 24;
//    localparam MAX_ALU_QUART  = 12;
//    localparam MSB_P          = MAX_P - 1;
//    localparam MSB_A          = MAX_A - 1;
//    localparam MSB_ALUMODE    = MAX_ALUMODE - 1;
//    localparam MSB_A_MULT     = MAX_A_MULT - 1;
//    localparam MSB_B          = MAX_B - 1;
//    localparam MSB_B_MULT     = MAX_B_MULT - 1;
//    localparam MSB_C          = MAX_C - 1;
//    localparam MSB_D          = MAX_D - 1;
//    localparam MSB_OPMODE     = MAX_OPMODE - 1;
//    localparam MSB_INMODE     = MAX_INMODE - 1;
//    localparam MSB_ALU_FULL   = MAX_ALU_FULL  - 1;
//    localparam MSB_ALU_HALF   = MAX_ALU_HALF  - 1;
//    localparam MSB_ALU_QUART  = MAX_ALU_QUART - 1;
    
    
    // Variables
    reg [24:0] A_MULT;
    wire [47:0] M;
    reg [47:0] X;
    reg [47:0] Y;
    reg [47:0] Z;
    reg [47:0] P_OUT;
    // TODO: Line 182-186
    // (A op D) * B ->
    // Pre-adder
    // A, -A, D, 0, A + D, D - A
    // INMODE[3:0]
    // 0010, 0011, 1010, 1011 -> 0
    // 1101 -> D-A
    // 1001 -> -A
    // 0110, 0111, 1110, 1111 -> D
    // 0101 -> D+A
    // 0001 -> A
    always @(*)
    begin
        case(INMODE[3:0])
            4'b0010, 4'b0011, 4'b101, 4'b1011:
                A_MULT = 'b0;
            4'b1101:
                A_MULT = D - A[24:0];
            4'b1001:
                A_MULT = -A;
            4'b0110, 4'b0111, 4'b1110, 4'b1111:
                A_MULT = D;
            4'b0101:
                A_MULT = D + A[24:0];
            4'b001:
                A_MULT = A;
            default:
                A_MULT = 'b1;
        endcase
    end
    
    // Multiplier Out of PreAdd, and B
    // this commented part will use dsp48e
//    always @(*)
//    begin
//        M = B * A_MULT;
//    end
    // This will use mux and shift
    multiplier mult(
        .A_MULT(A_MULT),
        .B(B),
        .result(M)
    );
    
    always @(*)
    begin
        // X Mux
        case(OPMODE[1:0])
            2'b00:
                X = 2'b0;
            2'b01:
            begin
                if(OPMODE[3:2] == 2'b01)
                    X = M;
            end
            2'b10:
                X = P_OUT;
            2'b11:
                X = {A, B};
        endcase
        // Y Mux
        case(OPMODE[3:2])
            2'b00:
                Y = 2'b0;
            2'b01:
                if(OPMODE[1:0] == 2'b01)
                    Y = M;
            2'b10:
                Y = 48'hFFFFFFFFFFFF;
            2'b11:
                Y = C;            
        endcase
        // Z Mux
        case(OPMODE[6:4])
            3'b000:
                Z = 'b0;
            3'b010:
                Z = P_OUT;
            3'b011:
                Z = C;
            3'b100:
                if(OPMODE[3:2] == 2'b10 && OPMODE[1:0] == 2'b00)
                    Z = P_OUT;
            default:
                Z = 'b1;
        endcase
    end
    
    // ALU
    always @(*)
    begin
        case(ALUMODE[3:0])
            4'b0000:
                P_OUT = Z + X + Y + CARRYIN;
            4'b0011:
                P_OUT = Z - (X + Y + CARRYIN);
            4'b0001:
                P_OUT = ~Z + X + Y + CARRYIN;
            4'b0010:
                P_OUT = ~(Z + X + Y + CARRYIN);
            4'b0100:
                if(OPMODE[3:2] == 2'b00)
                    P_OUT = X ^ Z;
                else if(OPMODE[3:2] == 2'b10)
                    P_OUT = ~(X ^ Z);
            4'b0101:
                if(OPMODE[3:2] == 2'b00)
                    P_OUT = ~(X ^ Z);
                else if(OPMODE[3:2] == 2'b10)
                    P_OUT = X ^ Z;
            4'b0110:
                if(OPMODE[3:2] == 2'b00)
                    P_OUT = ~(X ^ Z);
                else if(OPMODE[3:2] == 2'b10)
                    P_OUT = X ^ Z;
            4'b0111:
                if(OPMODE[3:2] == 2'b00)
                    P_OUT = X ^ Z;
                else if(OPMODE[3:2] == 2'b10)
                    P_OUT = ~(X ^ Z);
            4'b1100:
                if(OPMODE[3:2] == 2'b00)
                    P_OUT = X & Z;
                else if(OPMODE[3:2] == 2'b10)
                    P_OUT = X | Z;
            4'b1101:
                if(OPMODE[3:2] == 2'b00)
                    P_OUT = X & (~Z);
                else if(OPMODE[3:2] == 2'b10)
                    P_OUT = X | (~Z);
            4'b1110:
                if(OPMODE[3:2] == 2'b00)
                    P_OUT = ~(X & Z);
                else if(OPMODE[3:2] == 2'b10)
                    P_OUT = ~(X | Z);
            4'b1111:
                if(OPMODE[3:2] == 2'b00)
                    P_OUT = (~X) | Z;
                else if(OPMODE[3:2] == 2'b10)
                    P_OUT = (~X) & Z;
        endcase
    end
    
    // OUTPUT
    always @(posedge clk)
    begin
        if(alu_en)
            P <= P_OUT;
        else
            P <= 'b1;
    end
endmodule