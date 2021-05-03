//top level for other components

class ssd extends uvm_test;
`uvm_component_utils(ssd)
seq1 sq1;
seqr sqr;
drv  driver;
monitor_A monA;
scoreboard_A sbA;

function new(string name="ssd",uvm_component parent=null);
	super.new(name,parent);
endfunction : new

function void build_phase(uvm_phase phase);
	sqr = seqr::type_id::create("sqr",this);
	driver = drv::type_id::create("driver",this);
	
	sbA = scoreboard_A::type_id::create("sbA",this);
	monA= monitor_A::type_id::create("monA",this);
endfunction: build_phase

function void connect_phase(uvm_phase phase);
	driver.seq_item_port.connect(sqr.seq_item_export);

	monA.port_A.connect(sbA.tlma_fifo_A.analysis_export);
endfunction: connect_phase

task run_phase(uvm_phase phase);
	sq1=seq1::type_id::create("seq1");
	phase.raise_objection(this);
	sq1.start(sqr);
	
	phase.drop_objection(this);
endtask: run_phase



endclass : ssd
