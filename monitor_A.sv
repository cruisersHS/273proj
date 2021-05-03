class monitor_A extends uvm_monitor;
	`uvm_component_utils(monitor_A)
	uvm_analysis_port #(string) port_A;

	reg clk;

	virtual dut_intf intf;


	function new(string name = "monitor_A", uvm_component parent = null);
		super.new(name,parent);
	endfunction : new


	function void build_phase(uvm_phase phase);
		port_A = new("port_A",this);
		if(uvm_config_db#(virtual dut_intf)::get(null, "daron", "intf", intf)); else begin
			`uvm_fatal("config","Error getting interface (monitor_A)")
		end
	endfunction : build_phase


	task run_phase(uvm_phase phase);
			clk = 0;
			
			fork
				forever begin
					#5 clk=~clk;
				end

				forever @(posedge clk) begin
					if(intf.pushout) begin
						string msg_A = {$sformatf("%b",intf.dataout)};
						port_A.write(msg_A);
					end
				end
			join
	endtask : run_phase

endclass : monitor_A
