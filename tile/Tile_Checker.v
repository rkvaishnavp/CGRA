`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.03.2023 03:17:03
// Design Name: 
// Module Name: Tile_Checker
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


module Tile_Checker(
    input [7:0] caller_id,
    input [7:0] test_id,
    input clk,
    output reg wrt
);
parameter MAX_ID = 8'b0;
assign error = (test_id <= MAX_ID);
always @(posedge clk) begin
    if ((!error) & (caller_id == test_id)) 
        wrt = 1'b1;
    else
        wrt = 1'b0;
end
endmodule
