//each packet start with 4 codes of K.28.1 and ends with one code of K.28.5  K.28.7 is not used in this communications system.

//The packet contains an IEEE normal CRC-32 https://en.wikipedia.org/wiki/Cyclic_redundancy_check#CRC-32_algorithm (Links to an external site.) . 
//The CRC register does not contain any of the K.28.1 codes (Used as a sync field).  it is initialized to all ones as illustrated in 
//https://www.xilinx.com/support/documentation/application_notes/xapp209.pdf (Links to an external site.)  . 
//A K.23.7 control code, and the 4 byte CRC result is inserted automatically by the DUT when is senses a code of K.28.5 , and
// then the K.28.5 is transmitted.  The CRC is transmitted little endian. To allow the DUT time to transmit the CRC code, 
//No input (pushin) may be active within 10 clocks of sending a K.28.5 code.

//For this project, create a DUT model (High level non-synthesizable SV is OK).  
//Divide up the work, and test all aspects of the coding including disparity, code generation, CRC generation, and CRC insertion.
`timescale 1ns/10ps

`include "dut_intf.sv"
`include "dut.sv"
`include "crc32.sv"
`include "ebtb.sv"
package proj;
import uvm_pkg::*;


`include "si.sv"
`include "mimsg.sv"
`include "seq.sv"
`include "seqr.sv"
`include "drv.sv"
`include "monitor_A.sv"
`include "scoreboard_A.sv"
`include "scoreboard_B.sv"
`include "ssd.sv"
endpackage : proj

import uvm_pkg::*;

module top ();

reg clk;
dut_intf intf(clk);

initial begin
	uvm_config_db #(virtual dut_intf)::set(null, "daron", "intf" , intf);
	run_test("ssd");
end

initial begin
	clk=0;
	forever begin
		 #5 clk=~clk;
	end
end

initial begin
	$dumpfile("grey.vcd");
	$dumpvars(9,top);
end

dut d(intf.dut);

endmodule : top
