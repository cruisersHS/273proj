//driver

class drv extends uvm_driver #(si);
`uvm_component_utils(drv)
si mr;
mimsg m;

virtual dut_intf xx;
reg		[3:0] count_281;

function new(string name="drv",uvm_component parent=null);
	super.new(name,parent);
endfunction : new

function void connect_phase(uvm_phase phase);
	if(uvm_config_db#(virtual dut_intf)::get(null,"daron","intf", xx)); 
	else begin
		`uvm_fatal("config","Didn't get daron intf")
	end
	
endfunction : connect_phase

task doReset(si m);
	xx.reset=1;
	xx.datain=0;
	xx.pushin=0;
	xx.startin=0;
	count_281=0;
	@(posedge xx.clk)
	xx.reset=0;
endtask : doReset

task K281();
	xx.datain=9'b100111100;
	if(!count_281) xx.startin=1;
	else xx.startin=0;
	xx.pushin=1;
	@(posedge xx.clk) count_281=count_281+1;
endtask: K281

task Data(si m);
	xx.datain=mr.data;
	xx.pushin=1;
	@(posedge xx.clk) xx.datain=9'b111111111;
endtask : Data

task K285();
	xx.datain=9'b110111100;
	xx.pushin=1;
	@(posedge xx.clk) xx.datain=9'b111111111;
endtask: K285

task doWait();
	xx.datain=9'b000000000;
	xx.pushin=0;
	@(posedge xx.clk) xx.datain=9'b111111111;
endtask: doWait

task run_phase(uvm_phase phase);
	forever begin
		seq_item_port.get_next_item(mr);
		case(mr.cmd)
			Dreset: doReset(mr);
			Dpush281: K281();
			Dpushdata: Data(mr);
			Dpush285: K285();
			Dwait: doWait();
		endcase
		seq_item_port.item_done();
	end
	
endtask : run_phase

endclass : drv
