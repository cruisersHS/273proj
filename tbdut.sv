
`timescale 1ns/10ps
`include "dut.sv"
`include "dut_intf.sv"
`include "crc32.sv"
`include "ebtb.sv"

module tbdut ();
reg clk, reset;
wire pushin;
wire [8:0] datain;
wire startin;
wire pushout;
wire [9:0] dataout;
wire startout;

assign pushin = m.pushin;
assign datain = m.datain;
assign startin = m.startin;
assign pushout = m.pushout;
assign dataout = m.dataout;
assign startout = m.startout;

dut_intf m(clk, reset);
dut c(m);

always begin
	#5 clk = 1;
	#5 clk = 0;
end

//	reg pushin;
//	reg [8:0] datain;
//	reg startin;
//	reg pushout;
//	reg [9:0] dataout;
//	reg startout;

initial begin
	#5 reset = 1;
	//#10 $finish;
	m.pushin = 0;
	m.startin = 0;
	m.datain = 0;
	#20 reset = 0;
	m.pushin = 1;
	m.startin = 1;
	m.datain = 9'b100111100;
	#10 m.startin = 0;
	//#10 $finish;
	#30 m.datain = 9'b000001010;
	
	#10 m.datain = 9'b000001100;
	
	#10 m.datain = 9'b000001110;
	
	#10 m.datain = 9'b000010000;
	#10 m.datain = 9'b000010010;
	#10 m.datain = 9'b000010100;
	#10 m.datain = 9'b000010110;
	#10 m.datain = 9'b000011000;
	#10 m.datain = 9'b110111100;	//k285
	//#50 $finish;
	//#10 m.datain = 9'b110111100;	//k285
	
	#10 m.pushin = 0;
	m.datain = 9'b000000000;		//the k control code must be set to 0
	#100 $finish;
end



initial begin
    $dumpfile("crc.vcd");
    $dumpvars();
    repeat(10000) @(posedge(clk));
    #5;
    $dumpoff;
end

endmodule : tbdut
