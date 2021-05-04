//sequence item

typedef enum {
	Dreset,
	Dpush281,
	Dpushdata,
	Dpush285,
	Dwait
} Dcmd;

class si extends uvm_sequence_item;
`uvm_object_utils(si)

Dcmd cmd;
rand logic [7:0] data;
//rand logic [8:0] datain;
rand logic [4:0] delay;
rand logic [3:0] datalength;
//		input startin,
//		output pushout,
//		output [9:0] dataout,
//		output startout

function new(string name="si");
	super.new(name);
endfunction : new

endclass: si
