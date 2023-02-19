module alu (
    in1, in2, en, instruction, out
);

input [31:0]in1;
input [31:0]in2;
input en;
/*
ALU Function Encoding
000. Add
001. Sub
010. Mul
011. Shift Left Logical
100. Shift Right Logical
101. Compare(in1<in2)
110. Compare(in1>in2)
111. Compare(in1==in2)
*/
input [14:12]instruction;
output [31:0] out;

reg [31:0] ALUOUT;
assign out = ALUOUT;

always @(*) begin
    if (en) begin
        case (instruction)
            3'b000: begin
                ALUOUT = in1 + in2;
            end
            3'b001: begin
                ALUOUT = in1 - in2;
            end
            3'b010: begin
                ALUOUT = in1[15:0] * in2[15:0];
            end
            3'b011: begin
                ALUOUT = in1 << in2;
            end
            3'b100: begin
                ALUOUT = in1 >> in2;
            end
            3'b101: begin
                ALUOUT = (in1 < in2)?32'b1:32'b0;
            end
            3'b110: begin
                ALUOUT = (in1 > in2)?32'b1:32'b0;
            end
            3'b111: begin
                ALUOUT = (in1 == in2)?32'b1:32'b0;
            end
        endcase
    end
    else begin
        ALUOUT = 32'b0;
    end
end
endmodule