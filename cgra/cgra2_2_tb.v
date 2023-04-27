`timescale 10us/10ns
module cgra2_2_tb;

reg rst;
reg clk;

reg program_mode;
reg jtag_data_in;
wire jtag_data_out;

cgra2_2 cgra2_2_DUT(.rst(rst),.clk(clk),.program_mode(program_mode),.jtag_data_in(jtag_data_in),.jtag_data_out(jtag_data_out));

reg [0:0]jtag[0:16384];
integer addr = 0;

always #1 clk = ~clk;
initial begin
    $readmemb("jtag.mem",jtag);
    rst = 0;
    clk = 0;
    program_mode = 1;
    #1 jtag_data_in = jtag[addr];
    repeat (16384) begin
        #2;
        addr = addr + 1;
        if(addr == 4096) begin
            addr = 0;
            jtag_data_in = jtag[addr];
        end
        else jtag_data_in = jtag[addr];
    end
end

endmodule