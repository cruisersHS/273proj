// This is our sequence

class seq1 extends uvm_sequence #(si);
`uvm_object_utils(seq1)
si sii;

function new(string name="seq1");
	super.new(name);
endfunction : new

//tasks
virtual task Reset();
	start_item(sii);
	sii.cmd=Dreset;
	sii.data=0;
	finish_item(sii);
endtask : Reset

virtual task Push281();
	start_item(sii);
	sii.cmd=Dpush281;
	finish_item(sii);
endtask : Push281

virtual task Pushdata(input reg [7:0] data);
	start_item(sii);
	sii.cmd=Dpushdata;
	sii.data=data;
	finish_item(sii);
endtask : Pushdata

virtual task Push285();
	start_item(sii);
	sii.cmd=Dpush285;
	finish_item(sii);
endtask : Push285

virtual task Wait();
	start_item(sii);
	sii.cmd=Dwait;
	finish_item(sii);
endtask : Wait

virtual task body();
	sii=si::type_id::create("sequence_Item_sdd");
	//************packet*************//
	repeat(5) Reset();
	repeat(4) Push281();
	sii.randomize() with {datalength>=4;};
	repeat(sii.datalength) begin
		sii.randomize();
		Pushdata(sii.data);
	end
	Push285();
	sii.randomize() with {sii.delay>10;};
	repeat(sii.delay) Wait();
	//*******************************//
endtask: body

//

endclass : seq1
