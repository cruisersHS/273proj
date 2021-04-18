
module ebtb (
	input clk,
	input reset,
	input k,
	input [7:0] eb,
	output [9:0] tb,
	output rd,			//running disparity out
	output k_err			//invalid control character requested
);

wire	[4:0]	lbin;	//5b
wire	[2:0]	mbin;	//3b
reg 	[3:0]	lbout;	//4b
reg 	[5:0]	mbout;	//6b

reg		[2:0]	balance;			//100: -2, 010: 0, 001: +2
reg				curr_state, next_state;		//0:rd-, 1:rd+
reg		[4:0]	ones;	

assign	lbin = eb[4:0];
assign	mbin = eb[7:5];
assign	tb = {mbout, lbout};

//rd-: 0;	rd+: 1
assign rd = curr_state;

//5 ones: rd=0, 6 ones: rd=1
//+2: 6 ones 4 zeros
//-2: 4 ones 6 zeros
always_comb begin
	ones = tb[0] + tb[1] + tb[2] + tb[3] + tb[4] + tb[5] + tb[6] + tb[7] + tb[8] + tb[9];
end

//balance (disparity)
always_comb begin
	balance = 3'b010;			//0
	if(ones == 6) balance = 3'b001;		//+2
	else if(ones == 4) balance = 3'b100;	//-2
end

//mbout	5b/6b table
always_comb begin
	mbout = 0;
	if(!k) begin		//D.xx
		case(lbin)
			5'b00000: mbout = curr_state ? 6'b011000 : 6'b100111;	//D.00
			5'b00001: mbout = curr_state ? 6'b100010 : 6'b011101;	//D.01
			5'b00010: mbout = curr_state ? 6'b010010 : 6'b101101;	//D.02
			5'b00011: mbout = 6'b110001;				//D.03
			5'b00100: mbout = curr_state ? 6'b001010 : 6'b110101;	//D.04
			5'b00101: mbout = 6'b101001;				//D.05
			5'b00110: mbout = 6'b011001;				//D.06
			5'b00111: mbout = curr_state ? 6'b000111 : 6'b111000;	//D.07
			5'b01000: mbout = curr_state ? 6'b000110 : 6'b111001;	//D.08
			5'b01001: mbout = 6'b100101;				//D.09
			5'b01010: mbout = 6'b010101;				//D.10
			5'b01011: mbout = 6'b110100;				//D.11
			5'b01100: mbout = 6'b001101;				//D.12
			5'b01101: mbout = 6'b101100;				//D.13
			5'b01110: mbout = 6'b011100;				//D.14
			5'b01111: mbout = curr_state ? 6'b101000 : 6'b010111;	//D.15
			5'b10000: mbout = curr_state ? 6'b100100 : 6'b011011;	//D.16
			5'b10001: mbout = 6'b100011;				//D.17
			5'b10010: mbout = 6'b010011;				//D.18
			5'b10011: mbout = 6'b110010;				//D.19
			5'b10100: mbout = 6'b001011;				//D.20
			5'b10101: mbout = 6'b101010;				//D.21
			5'b10110: mbout = 6'b011010;				//D.22
			5'b10111: mbout = curr_state ? 6'b000101 : 6'b111010;	//D.23+
			5'b11000: mbout = curr_state ? 6'b001100 : 6'b110011;	//D.24
			5'b11001: mbout = 6'b100110;				//D.25
			5'b11010: mbout = 6'b010110;				//D.26
			5'b11011: mbout = curr_state ? 6'b001001 : 6'b110110;	//D.27+
			5'b11100: mbout = 6'b001110;				//D.28
			5'b11101: mbout = curr_state ? 6'b010001 : 6'b101110;	//D.29+
			5'b11110: mbout = curr_state ? 6'b100001 : 6'b011110;	//D.30+
			5'b11111: mbout = curr_state ? 6'b010100 : 6'b101011;	//D.31
		endcase
	end else begin		//K
		case(lbin)
			5'b11100: mbout = curr_state ? 6'b110000 : 6'b001111;	//K.28
			5'b10111: mbout = curr_state ? 6'b000101 : 6'b111010;	//K.23
			5'b11011: mbout = curr_state ? 6'b001001 : 6'b110110;	//K.27 (not used)
			5'b11101: mbout = curr_state ? 6'b010001 : 6'b101110;	//K.29 (not used)
			5'b11110: mbout = curr_state ? 6'b100001 : 6'b011110;	//K.30 (not used)
		endcase
	end
end

//lbout 3b/4b table
always_comb begin
	lbout = 0;
	if(!k) begin		//D
		case(mbin)
			3'b000: lbout = curr_state ? 4'b0100 : 4'b1011;			//D.x.0
			3'b001: lbout = 4'b1001;								//D.x.1
			3'b010: lbout = 4'b0101;								//D.x.2
			3'b011: lbout = curr_state ? 4'b0011 : 4'b1100;			//D.x.3
			3'b100: lbout = curr_state ? 4'b0010 : 4'b1101;			//D.x.4
			3'b101: lbout = 4'b1010;								//D.x.5
			3'b110: lbout = 4'b0110;								//D.x.6
			3'b111: lbout = curr_state ? 4'b0001 : 4'b1110;			//D.x.P7+
			
		endcase
	end else begin		//K
		case(mbin)
			3'b000: lbout = curr_state ? 4'b1011 : 4'b0100;			//K.x.0
			3'b001: lbout = curr_state ? 4'b0110 : 4'b1001;			//K.x.1+
			3'b010: lbout = curr_state ? 4'b1010 : 4'b0101;			//K.x.2
			3'b011: lbout = curr_state ? 4'b1100 : 4'b0011;			//K.x.3
			3'b100: lbout = curr_state ? 4'b1101 : 4'b0010;			//K.x.4
			3'b101: lbout = curr_state ? 4'b0101 : 4'b1010;			//K.x.5+
			3'b110: lbout = curr_state ? 4'b1001 : 4'b0110;			//K.x.6
			3'b111: lbout = curr_state ? 4'b0111 : 4'b1000;			//K.x.7++
		endcase
	end
end


//next_state
always_comb begin
	next_state = 0;
	case(curr_state)
		0: begin	//rd-, if is disparity neutral, stay rd-
			if(balance == 3'b010 || balance == 3'b001) next_state = 0;
			else next_state = 1;
		end
		1: begin	//rd+, if is disparity neutral, stay rd+
			if(balance == 3'b010 || balance == 3'b100) next_state = 1;
			else next_state = 0;
		end
	endcase
end

//curr_state
always_ff @(posedge clk or posedge reset) begin
	if(reset)	curr_state <= 0;
	else		curr_state <= next_state;
end

endmodule : ebtb
