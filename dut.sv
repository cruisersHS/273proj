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


reg 			k;
wire			rd;
wire			k_err;
wire	[7:0]	d8b;
reg		[7:0]	eb;		//the actual 8bit data packet we are putting in to the crc
reg		[9:0]	tb;

wire	[7:0]	crc_in;
wire	[31:0]	crc_out;
wire			crc_in_valid;

reg		[2:0]	k_count;
reg		[2:0]	crc_index;

reg 			pushout, startout;

//assign k = m.datain[8];
assign d8b = m.datain[7:0];
assign m.dataout = tb;
assign m.startout = startout;
assign m.pushout = pushout;
assign crc_in = m.datain[7:0];

crc32 c(m.clk, m.reset, crc_in, crc_in_valid, crc_out);
ebtb e(m.clk, m.reset, k, eb, tb, rd, k_err);

//input: k281, k281, k281, k281, d.x.y..., k285
//output: k281, k281, k281, k281, d.x.y..., k237, crc(l), crc, crc, crc(h), k285 

typedef union packed{
	bit [31:0] d;
	bit [3:0][0:7] b;
} crcout;

crcout crc_out_reg;

enum [2:0] {
	IDLE,
	K281,
	DATA,
	K_END,
	CRC,
	ENDP
} curr_state, next_state;

//assign m.pushout = (m.pushin || curr_state != IDLE) ? 1 : 0;

reg k_d;
reg [7:0] eb_d;
wire pushout_d, startout_d;

//pushout, startout
assign pushout_d = m.pushin || (curr_state != IDLE);
assign startout_d = (curr_state == IDLE) && (next_state == K281);

always_ff @(posedge m.clk or posedge m.reset) begin
	if(m.reset) begin
		pushout <= 0;
		startout <= 0;
	end else begin
		pushout <= pushout_d;
		startout <= startout_d;
	end
end


//crc_index
always_ff @(posedge m.clk or posedge m.reset) begin
	if(m.reset) crc_index <= 0;
	else begin
		if(curr_state == CRC) crc_index <= crc_index + 1;
		else crc_index <= 0;
	end
end

//k_count
always_ff @(posedge m.clk or posedge m.reset) begin
	if(m.reset) k_count <= 0;
	else begin
		if(m.pushin && k &&(curr_state == IDLE || next_state == K281)) k_count <= k_count + 1;
		else k_count <= 0;
	end
end

//k
always_comb begin
	k_d = k;
	if(curr_state == ENDP || (curr_state == DATA && next_state == CRC)) k_d = 1;
	else if(curr_state == DATA) k_d = 0;
	else k_d = m.datain[8];
end

always_ff @(posedge m.clk or posedge m.reset) begin
	if(m.reset) k <= 0;
	else k <= k_d;
end

//eb
always_comb begin
	eb_d = eb;
	case(curr_state)
		DATA: begin 
			if (next_state != CRC) eb_d = d8b;
			else eb_d = 8'b11110111;		//K23.7
		end
		//K_END: eb = 8'b11110111;		//K23.7
		CRC: eb_d = crc_out_reg.b[crc_index];
		ENDP: eb_d = 8'b10111100;							//K28.5
		default: eb_d = d8b;
	endcase
end

//k_input, pushout, startout


always_ff @(posedge m.clk or posedge m.reset) begin
	if(m.reset) eb <= 0;
	else eb <= eb_d;
end

//crc_in_valid
assign crc_in_valid = (next_state == DATA) ? 1 : 0;

//crc_out_reg.d
always_ff @(posedge m.clk or posedge m.reset) begin
	if(m.reset) crc_out_reg.d <= 32'h0;
	else begin
		if(curr_state == DATA) crc_out_reg.d <= crc_out;
		else crc_out_reg.d <= crc_out_reg.d;
	end
end

//next_state
always_comb begin
	next_state = IDLE;
	case(curr_state)
		IDLE: begin
			if(m.pushin) next_state = K281;
			else next_state = IDLE; 
		end
		K281: begin
			if(k_count == 3) next_state = DATA;
			else next_state = K281;
		end
		DATA: begin
			if(d8b == 8'b10111100) begin next_state = CRC; end		//K28.5
			else next_state = DATA;
		end
		//K_END: next_state = CRC;
		CRC: begin
			if(crc_index == 3) next_state = ENDP;
			else next_state = CRC;
			//$finish;
		end
		ENDP: next_state = IDLE;
	endcase
end

//curr_state
always_ff @(posedge m.clk or posedge m.reset) begin
	if(m.reset) curr_state <= IDLE;
	else curr_state <= next_state;
end


endmodule : dut
