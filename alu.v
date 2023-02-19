module alu (
    in1, in2, en, instruction, out
);

input [31:0]in1;
input [31:0]in2;
input en;
/*
ALU Function Encoding
0000    -   Add
0001    -   Sub
0010    -   Mul
0011    -   Shift Left Logical
0100    -   Shift Right Logical
0101    -   Compare(in1<in2)
0110    -   Compare(in1>in2)
0111    -   Compare(in1==in2)
1000    -
1001    -
1010    -
1011    -
1100    -
1101    -
1110    -
1111    -
*/
input [18:15]instruction;
output [31:0] out;

reg [31:0] ALUOUT;

assign out = ALUOUT;

always @(*) begin
    if (en) begin
        case (instruction)
            5'b00000: begin
                ALUOUT = in1 + in2;
            end
            5'b00001: begin
                ALUOUT = in1 - in2;
            end
            5'b00010: begin
                ALUOUT = in1[15:0] * in2[15:0];
            end
            5'b00011: begin
                ALUOUT = in1 << in2;
            end
            5'b00100: begin
                ALUOUT = in1 >> in2;
            end
            5'b00101: begin
                ALUOUT = (in1 < in2)?32'b1:32'b0;
            end
            5'b00110: begin
                ALUOUT = (in1 > in2)?32'b1:32'b0;
            end
            5'b00111: begin
                ALUOUT = (in1 == in2)?32'b1:32'b0;
            end
        endcase
    end
    else begin
        ALUOUT = 32'b0;
    end
end
endmodule