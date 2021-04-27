//interface of dut
interface dut_intf(input reg clk);
	reg reset;
	reg pushin;
	reg [8:0] datain;
	reg startin;
	reg pushout;
	reg [9:0] dataout;
	reg startout;
	

	modport dut (
		input clk,
		input reset,
		input pushin,
		input datain,
		input startin,
		output pushout,
		output dataout,
		output startout
	);




endinterface : dut_intf
