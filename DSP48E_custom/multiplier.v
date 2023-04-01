`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.04.2023 22:33:58
// Design Name: 
// Module Name: mult
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

module multiplier(
  input [24:0] A_MULT,
  input [17:0] B,
  output [47:0] result
);
    integer i;
    reg [24:0] A_reg;
    reg [17:0] B_reg;
    reg [47:0] partial_product;
 
    always @(*) begin
        A_reg = A_MULT;
        B_reg = B;
    
        partial_product = {48{1'b0}};
        for (i = 0; i < 18; i = i + 1) begin
            if (B_reg[i] == 1'b1) begin
                partial_product = partial_product + (A_reg << i);
            end
        end
    end
 
 
    assign result = partial_product;
 
endmodule


