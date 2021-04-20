//tb for 8b10b
`timescale 1ns/10ps

`include "ebtb.sv"

module tb810 ();
	reg clk;
	reg reset;
	reg k;
	reg [7:0] eb;
	wire [9:0] tb;
	wire rd;			//running disparity out
	wire k_err;

ebtb c(clk, reset, k, eb, tb, rd, k_err);

always begin
	#5 clk = 1;
	#5 clk = 0;
end

initial begin
	reset = 1;
	eb = 0;			//D0.0
	k = 0;
	#15 reset = 0;
	k = 1;
	eb = 8'b00011100;	//K28.0
	#10 eb = 8'b00111100;	//K28.1
	#10 k=0;
	eb = 8'b11000001;	//D1.6
	#10 eb = 8'b11100000;	//D0.7
	#10 eb = 8'b11111111;	//D31.7
	#20 eb = 0;			//D0.0
	#50 $finish;
	
end


initial begin
    $dumpfile("crc.vcd");
    $dumpvars(9,c);
    repeat(100) @(posedge(clk));
    #5;
    $dumpoff;
end


endmodule : tb810
