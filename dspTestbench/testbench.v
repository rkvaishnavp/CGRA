`timescale 1ns / 1ps
module dsp_tb;
  
  // Inputs
  reg [29:0] A;
  reg [17:0] B;
  reg [47:0] C;
  reg [24:0] D;
  reg CIN;
  reg [6:0] OPMODE;
  reg [3:0] ALUMODE;
  reg [4:0] INMODE;
  
  // Outputs
  wire [4:0] COUT;
  wire [47:0] P;
  
  // Instantiate the module under test
  dsp uut (
    .clk(clk),
    .A(A),
    .B(B),
    .C(C),
    .D(D),
    .CIN(CIN),
    .OPMODE(OPMODE),
    .ALUMODE(ALUMODE),
    .INMODE(INMODE),
    .COUT(COUT),
    .P(P)
  );
  
  // Clock generation
  reg clk;
  always #5 clk = ~clk;
  
  // Test stimulus
  initial begin
    $dumpfile("dsp_tb.vcd");
    $dumpvars(0, dsp_tb);
    
    // Initialize inputs
    clk = 0;
    A = 0;
    B = 0;
    C = 0;
    D = 0;
    CIN = 0;
    OPMODE = 0;
    ALUMODE = 0;
    INMODE = 0;
    
    // Apply stimulus
    #10 A = 30'h000A;
    #0 B = 18'h009;
    #0 C = 48'h0;
    #0 D = 25'h0;
    #0 CIN = 1'b0;
    #0 OPMODE = 7'b0000101;
    #0 ALUMODE = 4'b0;
    #0 INMODE = 5'b0;
    
    // Wait for some time
    
    #100;
    
    // Display outputs
    $display("COUT = %b", COUT);
    $display("P = %h", P);
    
    // Finish simulation
    $finish;
  end
  
  always @(posedge clk) begin
    #1; // Toggle clock
  end
  
endmodule
