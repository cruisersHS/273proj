class scoreboard_A extends uvm_scoreboard;
	uvm_tlm_analysis_fifo #(string) tlma_fifo_A;
	`uvm_component_utils(scoreboard_A)

	string msg_A;
	reg [9:0] rec_A;

	//Current State, Next State
	reg[3:0] CS, NS; 

	//State parameters for easier readability
	parameter state_Reset = 4'b0000, state_K1 = 4'b0001, state_K2 = = 4'b0010,state_K3= 4'b0011,state_K4= 4'b0100;
	parameter state_D1= 4'b0101,state_KK1= 4'b0110,state_CRC1= 4'b0111,state_CRC2= 4'b1000,state_CRC3= 4'b1001,state_=CRC4 4'b1010;

	function new(string name = "scoreboard_A", uvm_component parent = null);
		super.new(name,parent);
	endfunction : new


	function void build_phase(uvm_phase phase);
		tlma_fifo_A = new("analysis_fifo_A",this);
	endfunction : build_phase


	virtual task run_phase(uvm_phase phase);
		CS = state_Reset;
		forever begin
			//Get a 10b output from the FIFO
			tlma_fifo_A.get(msg_A);
			//Convert it from string back to reg[9:0]
			rec_A = msg_A.atobin();
			
			//Verification State Machine (Work in Progress)
			case(CS)
				state_Reset : 	if((rec_A == 10'b0011111001) ||(rec_A == 10'1100000110))begin
									NS = state_K1;
								end 
								else begin
									`uvm_error("Signal Order", "Error: Expected first K.28.1")	
									NS = state_Reset;	
								end
				state_K1 : 		if((rec_A == 10'b0011111001) ||(rec_A == 10'1100000110))begin
									NS = state_K2;
								end 
								else begin
									`uvm_error("Signal Order", "Error: Expected second K.28.1")	
									NS = state_Reset;	
								end
				state_K2 : 		if((rec_A == 10'b0011111001) ||(rec_A == 10'1100000110))begin
									NS = state_K3;
								end 
								else begin
									`uvm_error("Signal Order", "Error: Expected third K.28.1")	
									NS = state_Reset;	
								end
				state_K3 : 		if((rec_A == 10'b0011111001) ||(rec_A == 10'1100000110))begin
									NS = state_K4;
								end 
								else begin
									`uvm_error("Signal Order", "Error: Expected fourth K.28.1")	
									NS = state_Reset;	
								end	
				state_K4 : 		if(is_D_code(rec_A))begin
									NS = state_D1;
								end 
								else begin
									`uvm_error("Signal Order", "Error: Expected valid Data Code")	
									NS = state_Reset;	
								end
				state_D1 : 
				state_KK1 : 
				state_CRC1 : 
				state_CRC2 : 
				state_CRC3 : 
				state_CRC4 : 
			endcase

		end
	endtask : run_phase


	//Function to efficiently check if the 10b is a valid data code (Work in Progress)
	function reg is_D_code(reg [9:0] code);
		reg[9:0] Valid_Data_Codes[0:30] = '{10'b0011111001,10'b1100000110,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
		
		is_D_code = 0;
		for (int i = 0; i<31;i++) begin
			if (code == Valid_Data_Codes[i]) begin
				is_D_code = 1;
				break;
			end
		end 

	endfunction : is_D_code
	
	

endclass : scoreboard_A
