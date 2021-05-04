//This is to check the disparity

class scoreboard_B extends uvm_scoreboard;
	uvm_tlm_analysis_fifo #(string) tlma_fifo_B;
	`uvm_component_utils(scoreboard_B)

	string msg_A;
	reg [9:0] rec_A;
	reg [3:0] num;

	//Current State, Next State
	reg rd_in, rd_out; //0-->rd-, 1-->rd+ column

	
       //New function to connect this scoreboard with its base class
	function new(string name = "scoreboard_B", uvm_component parent = null);
		super.new(name,parent);
	endfunction : new


	function void build_phase(uvm_phase phase);
		tlma_fifo_B = new("tlma_fifo_B",this);
	endfunction : build_phase

	virtual task run_phase(uvm_phase phase);
		rd_in  = 0;//start with rd- column
		forever begin
			tlma_fifo_B.get(msg_A);
			rec_A = msg_A.atobin();
				num = 0;
			for(int i = 0;i<$size(rec_A);i=i+1) begin
				num +=rec_A[i];
			end
			if (num>=4 && num<=6) begin

			case(rd_in)
				0 : begin
					if(num == 5)
						rd_out = 0; //if equal number of 1's and 0's stay in rd-
					else if (num == 6)
						rd_out = 1;//rd+
						
				      end
		
				1 : begin
					if(num == 4)
						rd_out = 0;//rd-
					else if (num == 5)
						rd_out = 1;//if equal no. of 1's and 0's stay in rd+
				      end
			
			endcase
			rd_in = rd_out;
				//$display("The #1's = %d, and the disparity is = %d", num, rd_out);
		end
		else 
			`uvm_error("[Disparity Error]", $sformatf("Error, num = %d",num));


			
		end
	endtask : run_phase

endclass : scoreboard_B
