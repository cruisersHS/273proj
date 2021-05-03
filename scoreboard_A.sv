class scoreboard_A extends uvm_scoreboard;
	uvm_tlm_analysis_fifo #(string) tlma_fifo_A;
	`uvm_component_utils(scoreboard_A)

	string msg_A;
	reg [9:0] rec_A;

	//Current State, Next State
	reg[3:0] CS, NS; 

	//State parameters for easier readability
	parameter state_Reset = 4'b0000, state_K1 = 4'b0001, state_K2 = 4'b0010,state_K3= 4'b0011,state_K4= 4'b0100;
	parameter state_D1= 4'b0101,state_KK1= 4'b0110,state_CRC1= 4'b0111,state_CRC2= 4'b1000,state_CRC3= 4'b1001,state_CRC4=4'b1010;

	function new(string name = "scoreboard_A", uvm_component parent = null);
		super.new(name,parent);
	endfunction : new


	function void build_phase(uvm_phase phase);
		tlma_fifo_A = new("tlma_fifo_A",this);
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
				state_Reset : 	if((rec_A == 10'b0011111001) ||(rec_A == 10'b1100000110))begin
									NS = state_K1;
								end 
								else begin
									//`uvm_error("Signal Order", "Error: Expected first K.28.1")	
									NS = state_Reset;	
								end
				state_K1 : 		if((rec_A == 10'b0011111001) ||(rec_A == 10'b1100000110))begin
									NS = state_K2;
								end 
								else begin
									`uvm_error("Signal Order (K1)", "Error: Expected second K.28.1")	
									NS = state_Reset;	
								end
				state_K2 : 		if((rec_A == 10'b0011111001) ||(rec_A == 10'b1100000110))begin
									NS = state_K3;
								end 
								else begin
									`uvm_error("Signal Order (K2)", "Error: Expected third K.28.1")	
									NS = state_Reset;	
								end
				state_K3 : 		if((rec_A == 10'b0011111001) ||(rec_A == 10'b1100000110))begin
									NS = state_K4;
								end 
								else begin
									`uvm_error("Signal Order (K3)", "Error: Expected fourth K.28.1")	
									NS = state_Reset;	
								end	
				state_K4 : 		if(is_valid_D(rec_A))begin
									NS = state_D1;
								end 
								else begin
									`uvm_error("Signal Order (K4)", "Error: Expected at least one valid Data Code")	
									NS = state_Reset;	
								end
				state_D1 : 		if(is_valid_D(rec_A))begin
									NS = state_D1;
								end 
								else if((rec_A == 10'b1110101000) ||(rec_A == 10'b0001010111)) begin
									NS = state_KK1;
								end
								else begin
									`uvm_error("Signal Order (D1)", "Error: Expected another Data Code or K.23.7")	
									NS = state_Reset;	
								end
				state_KK1 : 	if(is_valid_D(rec_A))begin
									NS = state_CRC1;
								end 
								else begin
									`uvm_error("Signal Order (KK1)", "Error: Expected first CRC Packet")	
									NS = state_Reset;	
								end
				state_CRC1 : 	if(is_valid_D(rec_A))begin
									NS = state_CRC2;
								end 
								else begin
									`uvm_error("Signal Order (CRC1)", "Error: Expected second CRC Packet")	
									NS = state_Reset;	
								end
				state_CRC2 : 	if(is_valid_D(rec_A))begin
									NS = state_CRC3;
								end 
								else begin
									`uvm_error("Signal Order (CRC2)", "Error: Expected third CRC Packet")	
									NS = state_Reset;	
								end
				state_CRC3 : 	if(is_valid_D(rec_A))begin
									NS = state_CRC4;
								end 
								else begin
									`uvm_error("Signal Order (CRC3)", "Error: Expected fourth CRC Packet")	
									NS = state_Reset;	
								end
				state_CRC4 : 	if((rec_A == 10'b0011111010) ||(rec_A == 10'b1100000101 ))begin
									NS = state_Reset;
								end 
								else begin
									`uvm_error("Signal Order (CRC4)", "Error: Expected K.28.5")	
									NS = state_Reset;	
								end	
			endcase

			CS = NS;

		end
	endtask : run_phase


	//Function to efficiently check if the 10b is a valid data code (Work in Progress)
	function reg is_valid_D(reg [9:0] code);
		reg D6x_valid, Dx4_valid;
		reg[5:0] Valid_Data6_Codes[0:43] = '{6'b100111, 6'b011000, 6'b011011, 6'b100100, 6'b011101, 6'b100010, 6'b100011, 6'b101101, 6'b010010, 6'b010011, 6'b110001, 6'b110010, 6'b110101, 6'b001010, 6'b001011, 6'b101001, 6'b101010, 6'b011001, 6'b011010, 6'b111000, 6'b000111, 6'b111010, 6'b000101, 6'b111001, 6'b000110, 6'b110011, 6'b001100, 6'b100101, 6'b100110, 6'b010101, 6'b010110, 6'b110100, 6'b110110, 6'b001001, 6'b001101, 6'b001110, 6'b101100, 6'b101110, 6'b010001, 6'b011100, 6'b011110, 6'b100001, 6'b010111, 6'b101000};
		reg[3:0] Valid_Data4_Codes[0:13] = '{4'b1011, 4'b0100, 4'b1001, 4'b0101, 4'b1100, 4'b0011, 4'b1101, 4'b0010, 4'b1010, 4'b0110, 4'b1110, 4'b0001, 4'b0111, 4'b1000};

		is_valid_D = 0;
		D6x_valid = 0;
		Dx4_valid = 0;

		for (int i = 0; i<44;i++) begin
			if (code[9:4] == Valid_Data6_Codes[i]) begin
				D6x_valid = 1;
				break;
			end
		end
		
		for (int i = 0; i<14;i++) begin
			if (code[3:0] == Valid_Data4_Codes[i]) begin
				Dx4_valid = 1;
				break;
			end
		end

		if(D6x_valid && Dx4_valid) begin
			is_valid_D = 1;
		end
	endfunction : is_valid_D
	
	

endclass : scoreboard_A
