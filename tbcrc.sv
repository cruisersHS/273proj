//tb for crc
`timescale 1ns/10ps

`include "crc32.sv"

module tbcrc ();
reg clk, reset;
reg [7:0] crc_in;
reg crc_in_valid;
wire [31:0] crc_out;

crc32 c(clk, reset, crc_in, crc_in_valid, crc_out);
	
always begin
	#5 clk = 1;
	#5 clk = 0;
end

initial begin
	reset = 1;
	crc_in = 0;
	crc_in_valid = 0;
	#30 reset = 0;
	#5 crc_in = 8'h0a;
	#10 crc_in_valid = 1;
	#10 crc_in = 8'h0c;
	#10 crc_in = 8'h0e;
	#10 crc_in = 8'h10;
	#10 crc_in = 8'h12;
	#50 crc_in_valid = 0;
	#50 crc_in_valid = 1;
	#70 $finish;
end


initial begin
    $dumpfile("crc.vcd");
    $dumpvars(9,c);
    repeat(100) @(posedge(clk));
    #5;
    $dumpoff;
end

endmodule : tbcrc
