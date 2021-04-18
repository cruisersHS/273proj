//each packet start with 4 codes of K.28.1 and ends with one code of K.28.5  K.28.7 is not used in this communications system.

//The packet contains an IEEE normal CRC-32 https://en.wikipedia.org/wiki/Cyclic_redundancy_check#CRC-32_algorithm (Links to an external site.) . 
//The CRC register does not contain any of the K.28.1 codes (Used as a sync field).  it is initialized to all ones as illustrated in 
//https://www.xilinx.com/support/documentation/application_notes/xapp209.pdf (Links to an external site.)  . 
//A K.23.7 control code, and the 4 byte CRC result is inserted automatically by the DUT when is senses a code of K.28.5 , and
// then the K.28.5 is transmitted.  The CRC is transmitted little endian. To allow the DUT time to transmit the CRC code, 
//No input (pushin) may be active within 10 clocks of sending a K.28.5 code.

//For this project, create a DUT model (High level non-synthesizable SV is OK).  
//Divide up the work, and test all aspects of the coding including disparity, code generation, CRC generation, and CRC insertion.

module dut (dut_intf.dut m);
/* 		input clk,		//interface signals
		input reset,
		input pushin,
		input [8:0] datain,
		input startin,
		output pushout,
		output [9:0] dataout,
		output startout
 */

wire			k;
wire			rd;
wire			k_err;
wire	[7:0]	eb;
reg		[9:0]	tb;

reg		[7:0]	crc_in;
wire	[32:0]	crc_out;
wire			crc_in_valid;

assign k = m.datain[8];
assign eb = m.datain[7:0];
assign m.dataout = tb;

crc32 c(m.clk, m.reset, crc_in, crc_in_valid, crc_out);
ebtb e(m.clk, m.reset, k, eb, tb, rd, k_err);



//we receive signal and data from sequence, then send packet to the 8b10b?
//or we generate packet from the seqience?






endmodule : dut
