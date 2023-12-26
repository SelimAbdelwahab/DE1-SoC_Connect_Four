module PS2(
	CLOCK_50,
	PS2_CLK,
	PS2_DAT,
	KEY_TWO,
	RESET,
	HEX2,
	HEX3,
	LEDR);
	
	input 			CLOCK_50;
	input 			PS2_CLK;
	input 			PS2_DAT;
	input 			RESET;
	output [1:0] 	KEY_TWO;
	output [6:0] HEX2;
	output [6:0] HEX3;
	output [9:8] LEDR;
	
	wire [15:0] key_code;
	
	PS2_Decoder dec(
		.CLOCK_50(CLOCK_50),
		.PS2_CLK(PS2_CLK),
		.PS2_DAT(PS2_DAT),
		.KEY_TWO(KEY_TWO),
		.RESET(RESET),
		.DAT_OUT(key_code),
		.LEDR(LEDR));
		
	key_to_two ktt(
		.CLOCK_50(CLOCK_50),
		.KEY_CODE(key_code),
		.KEY_TWO(KEY_TWO));
		
	hex_decoder dec2(key_code[7:4], HEX3);
	hex_decoder dec3(key_code[3:0], HEX2);
endmodule

module PS2_Decoder(
	CLOCK_50,
	PS2_CLK,
	PS2_DAT,
	KEY_TWO,
	RESET,
	DAT_OUT,
	LEDR);
	
	input CLOCK_50;
	input PS2_CLK;
	input PS2_DAT;
	input [1:0] 	KEY_TWO;
	input 			RESET;
	output reg [15:0] DAT_OUT;
	output reg [9:8] LEDR;
	
	
	reg [2:0]	current_state;
	reg [2:0]	next_state;
	
	reg last_in, clk_prev;
	
	reg [3:0]	count;
	reg [8:0]	body;
//	wire			pulsed;
	
	localparam	CODE_EXT = 8'hE0,
					CODE_BRK = 8'hF0;
/*
	reg		long;
	reg 		breaking;
	reg		error;
	reg		backToIdle = 1'b0;
	reg clk_swap = 1'b0;
	
	localparam 	IDLE	= 0,	// CLK HIGH, DAT HIGH
				MAKE	= 1,	// Store 8 bits transmitted
				BREAK	= 2,	// Recieved break code
				LONG	= 3,
				ERR_CK	= 4,	// Check parity bit
				STOP	= 5,
				RESET = 6;
					
	reg done_reading = 1'b0;
	
	reg [9:0] down_count = 10'd249;
	
	always @(posedge CLOCK_50) begin
		if (down_count == 10'b0) begin
			down_count <= 10'd249;
		end else begin 
			down_count <= down_count - 1'b1; 
		end
	end
	
	assign pulsed = down_count == 1'b0 ? 1'b1 : 1'b0;
	
	always @(*) begin : STATE_TABLE
		case (current_state)
			IDLE: 	begin
				next_state = IDLE;
				
				if (pulsed && PS2_DAT == 1'b0 && PS2_CLK == 1'b0)
					next_state = MAKE;
			end
			
			MAKE:	begin
				if (done_reading) begin
					if (body[7:0] == CODE_EXT)
						next_state = LONG;
					else if (body[7:0] == CODE_BRK)
						next_state = BREAK;
					else
						next_state = STOP;
				end
				else
					next_state = MAKE;
			end
			
			BREAK:	begin
				next_state = STOP;
			end
			
			LONG:	begin
				next_state = STOP;
			end
			
			
			STOP:	begin
					next_state = IDLE;
			end
			
			RESET: begin
				next_state = IDLE;
			end
		endcase
	end
	
	always @(posedge CLOCK_50) begin
		LEDR[7:0] <= body[7:0];
		LEDR[9] <= 1'b0;

		
		if (PS2_CLK == 1'b0 && clk_prev == 1'b1) begin
			clk_swap <= 1'b1;
			last_in <= PS2_DAT;
		end
		else
			clk_swap <= 1'b0;
		
		if (pulsed) begin
			case (current_state)
				IDLE: 	begin
					count 		<= 4'b0;
					body		<= 8'b0;
					backToIdle	<= 1'b0;
				end
				
				MAKE:	begin
					if (pulsed) begin
						case (count)
							0: body[0] <= PS2_DAT;
							1: body[1] <= PS2_DAT;
							2: body[2] <= PS2_DAT;
							3: body[3] <= PS2_DAT;
							4: body[4] <= PS2_DAT;
							5: body[5] <= PS2_DAT;
							6: body[6] <= PS2_DAT;
							7: body[7] <= PS2_DAT;
							8: body[8] <= PS2_DAT;// TODO: Error check
							9: done_reading <= 1'b1;
							default: done_reading <= 1'b1;
						endcase
						count <= count + 1'b1;
					end
				end
				
				BREAK:	begin
					breaking <= 1'b1;
					count <= 4'b0;
				end
				
				LONG:	begin
					long <= 1'b1;
					count <= 4'b0;
					LEDR[9] <= 1'b1;
				end
				
				STOP:	begin
					if (breaking)
						DAT_OUT = 16'b0;
					else begin
						if (long)
							DAT_OUT[15:8] = 8'hE0;
						else
							DAT_OUT[15:8] = 8'b0;
						
						DAT_OUT[7:0] = body[7:0];
					end
					
					long 			<= 1'b0;
					breaking 	<= 1'b0;
					error 		<= 1'b0;
					count 		<= 4'b0;
					done_reading<= 1'b0;
				end
					
				RESET: begin
					count <= 4'b0;
					long <= 1'b0;
					breaking <= 1'b0;
					clk_prev <= 1'b0;
					error <= 1'b0;
					last_in <= 1'b1;
					DAT_OUT <= 16'b0;
				end
			endcase
		end
		current_state <= next_state;

		clk_prev <= PS2_CLK;

	end
	
	wire [2:0] cs;
	assign cs = current_state;
	
	wire [3:0] c;
	assign c = count;
	
	hex_decoder d1(cs, HEX1);
	hex_decoder d2(c, HEX2);
	*/
	
	reg [11:0] data_in;
	reg brk = 1'b0;
	
//	always @(negedge PS2_CLK) begin
//		data_in[10:0] = {PS2_DAT, data_in[10:1]};
//	end
//	
	reg clkp = 1'b1;
	reg done = 1'b0;
	reg pulsed = 1'b0;
	
	
	always @(posedge CLOCK_50) begin
		if (RESET) begin
			DAT_OUT <= 16'b0;
			done <= 1'b0;
			data_in <= 16'b0;
		end else begin
			if (data_in[0] == 1'b0 && data_in[10] == 1'b1) begin
					if (data_in[8:1] == CODE_EXT) begin
						DAT_OUT[15:8] <= CODE_EXT;
					end else if (data_in[8:1] == CODE_BRK) begin
						brk <= 1'b1;
					end else begin
						if (brk == 1'b0 && KEY_TWO == 0)
							DAT_OUT[7:0] <= data_in[8:1];
						else if (brk == 1'b1) begin
							DAT_OUT <= 16'b0;
						end
						
						done <= 1'b1;
					end
				end
				
			LEDR[9] <= brk;
			
			if (done && pulsed) begin 
				data_in <= 11'b0;
				done <= 1'b0;
				
				if (brk) begin
					DAT_OUT <= 16'b0;
					brk <= 1'b0;
				end
				
			end
			
			if (pulsed) begin
				data_in[10:0] <= {PS2_DAT, data_in[10:1]};
			end
			
			if (PS2_CLK == 1'b0 && clkp == 1'b1) begin
				pulsed <= 1'b1;
			end
			else
				pulsed <= 1'b0;
		end
		
		clkp <= PS2_CLK;
	end
endmodule

module key_to_two(
	CLOCK_50,
	KEY_CODE,
	KEY_TWO
);
	input 				CLOCK_50;
	input		[15:0] 	KEY_CODE;
	output	reg [1:0] 	KEY_TWO;
	
	localparam	R_ARROW	= 16'hE074,
				L_ARROW	= 16'hE06B,
				SPACE	= 16'hE072;

	always @(posedge CLOCK_50) begin
		case (KEY_CODE)
			R_ARROW:	KEY_TWO <= 2'b01;
			L_ARROW:	KEY_TWO <= 2'b10;
			SPACE:		KEY_TWO <= 2'b11;
			default:	KEY_TWO <= 2'b00;
		endcase
	end
endmodule