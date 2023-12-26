`timescale 1ns/1ns

module Display_Controller (
	CLOCK_50,
	COL,
	TURN,
	GAME_STATE,
	DROP_A_PIECE,
	CHECK_FOR_WINNER,
	
	VGA_R,
	VGA_G,
	VGA_B,
	VGA_CLK,
	VGA_HS,
	VGA_VS,
	VGA_SYNC_N,
	VGA_BLACK_N,
	LEDR,
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	
	DONE_DROP_PIECE,
	HAS_WON,
	DONE_CHECK_WINNER

);
	////////////////////////// INOUT ///////////////////////////////
	input wire 			CLOCK_50;
	input wire 	[2:0]	COL;
	input wire			TURN;
	input wire 	[2:0]	GAME_STATE;
	input wire 			DROP_A_PIECE;
	input wire 			CHECK_FOR_WINNER;
	
	output wire [7:0] VGA_R;
	output wire [7:0] VGA_G;
	output wire [7:0] VGA_B;
	output wire 		VGA_CLK;
	output wire 		VGA_HS;
	output wire 		VGA_VS;
	output wire 		VGA_SYNC_N;
	output wire 		VGA_BLACK_N;
	output wire [9:0]	LEDR;
	output wire [6:0]	HEX0;
	output wire [6:0]	HEX1;
	output wire [6:0]	HEX2;
	output wire [6:0]	HEX3;
	output wire [6:0]	HEX4;
	
	output wire 		DONE_DROP_PIECE;
	output wire 		HAS_WON;
	output wire			DONE_CHECK_WINNER;
	///////////////////////////////////////////////////////////////


	localparam 		X_PIXELS = 640,
						Y_PIXELS = 480,
						SCREEN_WIDTH = 640,
						SCREEN_HEIGHT = 480,
						MAX = 640*480;
						
	localparam 	START = 0,
					GAME 	= 1,
					END 	= 2;
	
	wire 			CLOCK_25;
	wire 			current_buffer;
	
	reg 			downCount = 0;
	wire 	[2:0] 	pixelIn;
	wire	[2:0] 	q0;
	wire 	[2:0]		q1;
	wire			wren0, wren1;
	
	wire [9:0] x_out;
	wire [9:0] y_out;

	wire [23:0] c_in;
	wire [2:0]  clr_code;
	assign wren0 = (current_buffer == 1'b1 && VGA_BLACK_N && GAME_STATE != START) ? 1'b1 : 1'b0;
	assign wren1 = (current_buffer == 1'b0 && VGA_BLACK_N && GAME_STATE != START) ? 1'b1 : 1'b0;
		
	wire [18:0] addy = x_out + y_out * 640;
		
	integer i;
	integer x_c, y_c;
	integer x_i, y_i;
	
	always @(*) begin
		x_i = (7 * x_out) / SCREEN_WIDTH;
		y_i = ((y_out - 80) * 6) / (SCREEN_HEIGHT - 80);
		
		x_c = x_i * (SCREEN_WIDTH/7) + (SCREEN_WIDTH / 14);
		y_c = y_out >= 80 ? (y_i) *(SCREEN_HEIGHT / 7) + 85 + ((SCREEN_HEIGHT - 80 - 10) / 14) : 0; 
	end
	
	wire [2:0] 	board_add = y_out >= 80 ? ((y_out - 80) / ((SCREEN_HEIGHT-80) / 6)) : 0;
	wire [13:0] board_data;
		
	wire [13:0] data_out;
	
		
	
	always @(posedge CLOCK_50) begin
		if (downCount == 0) 
			downCount <= 1'b1;
		else
			downCount <= downCount - 1'b1;

	end
	
	
	assign CLOCK_25 = downCount == 1'b0 ? 1'b1 : 1'b0;
	
	
	wire [1:0] 	valAtGrid = y_out >= 80 && VGA_BLACK_N ? data_out[(6-x_i)*2+:2] : 0;
	
	wire [31:0] X_C; 
	assign X_C = x_c;
	wire [31:0] Y_C;
	assign Y_C = y_c;
	
	wire [31:0] X_ANI;
	wire [31:0] Y_ANI;
	
	wire animating;
	wire [1:0] ani_clr;
	
	assign clr_code = current_buffer == 1'b0 ? q0 : q1;
	
	
	wire [2:0] piece_col;
	wire [2:0] piece_row;
	
	add_piece ap(
		.CLOCK_50(CLOCK_50),
		.ROW_IN(board_add),
		.COL(COL),
		.LD_PIECE(DROP_A_PIECE),
		.TURN(TURN),
		.GAME_OVER(GAME_STATE == END),
		.DATA_OUT(data_out),
		.DONE(DONE_DROP_PIECE),
		.X_ANI(X_ANI),
		.Y_ANI(Y_ANI),
		.ANIMATING(animating),
		.CLR(ani_clr),
		.PIECE_COL(piece_col),
		.PIECE_ROW(piece_row)
//		.HEX1(HEX1)
	);
	
	wire who_won;
	
	check_winner cw
		(
		.CLOCK_50(CLOCK_50),
		.START_CHECK(CHECK_FOR_WINNER),
		.ROW_IN(board_add),
		.DATA_IN(data_out),
		.SR(piece_row), 
		.SC(piece_col),
		.TURN(TURN),
		.WON(LEDR[0]),
		.WHO_WON(who_won),
		.DONE_CHECK_WINNER(DONE_CHECK_WINNER),
		.LEDR(LEDR[7:1]),
		.HEX1(HEX1),
		.HEX2(HEX2),
		.HEX3(HEX3),
		.HEX4(HEX4)
		);
		
	assign HAS_WON = LEDR[0];
	
	wire [2:0] go_out;
	
	
	draw_screen #
		(.X_PIXELS(X_PIXELS), .Y_PIXELS(Y_PIXELS), .SCREEN_WIDTH(640), .SCREEN_HEIGHT(480)) 
		ds
		(
			.CLOCK_50(CLOCK_50),
			.DRAW(VGA_BLACK_N),
			.DROPPING_PIECE(animating),
			.D_CLR(ani_clr),
			.X_ANI(X_ANI),
			.Y_ANI(Y_ANI),
			.X(x_out),
			.Y(y_out),
			.X_C(X_C),
			.Y_C(Y_C),
			.VAL_AT_GRID(valAtGrid),
			.c_out(pixelIn)
		);
	
	game_over go(
		.address(addy),
		.clock(CLOCK_50),
		.q(go_out)
	);
	
	Buffer0 b0 (
		.address(addy),
		.clock(CLOCK_50),
		.data(GAME_STATE == GAME ? pixelIn : go_out),
		.wren(wren0),
		.q(q0));
		
	Buffer1 b1 (
		.data(GAME_STATE == GAME ? pixelIn : go_out),
		.rdaddress(addy),
		.wraddress(addy),
		.clock(CLOCK_50),
		.wren(wren1),
		.q(q1));
		
	get_colour clr_24(
		.clr_code(clr_code),
		.game_state(GAME_STATE),
		.clr_24(c_in),
		.who_won(who_won));

	vga_master #(.X_PIXELS(X_PIXELS), .Y_PIXELS(Y_PIXELS)) vgam(
		.CLOCK_25(CLOCK_25),
		.c_in(c_in),
				
		.VGA_CLK(VGA_CLK),  
		.VGA_HS(VGA_HS),							
		.VGA_VS(VGA_VS),						
		.VGA_BLANK_N(VGA_BLACK_N),					
		.VGA_SYNC_N(VGA_SYNC_N),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.x_out(x_out),
		.y_out(y_out),
		.current_buffer(current_buffer));
		
	hex_decoder h1(COL, HEX0);
	
endmodule

module check_winner(
	CLOCK_50,
	START_CHECK,
	ROW_IN,
	DATA_IN,
	SR, SC,
	TURN,
	DONE,
	HEX1, HEX2,
	HEX3, HEX4,
	LEDR,
	WON,
	WHO_WON,
	DONE_CHECK_WINNER
	);
	////////////////// INPUTS /////////////////////////
	input CLOCK_50;
	input START_CHECK;
	input [2:0] ROW_IN;
	input [13:0] DATA_IN;
	input [2:0] SR; // ROW_CHECK
	input [2:0] SC; // COL_CHECK
	input TURN;
	
	output [6:0] HEX1; // ROW_CHECK
	output [6:0] HEX2; // COL_CHECK
	output [6:0] HEX3; // ROW_CHECK
	output [6:0] HEX4; // COL_CHECK
	output reg [7:1]  LEDR;
	output reg DONE;
	output reg WON;
	output reg WHO_WON;
	output reg DONE_CHECK_WINNER;
	
	integer sr;
	integer sc;
	
	integer row_tracker = 10;
	
	
	/////////////////// LOCAL WIRES ///////////////////
	
	localparam 	IDLE = 0,
					WAIT_FOR_GOOD_START = 1,
					POPULATE_ARRAY = 2,
					CHECK_WINNER = 3,
					END = 4;
					
	reg [2:0]	current_state;
	reg [2:0]	next_state;
	
	reg array_filled = 1'b0;
	
	integer board[0:5][0:6];
	
	reg [2:0] row;
	reg [2:0] col;
	reg done_check = 1'b0;
	integer i;
	integer count[0:6];
	integer dirs[0:6];
	integer data_at_pos;
	
	integer count_down;
	
	reg checked;
		
	// STATE MACHINE
	integer turn;
	always @(*) begin : STATE_TABLE
		case (current_state)
			IDLE: begin
				next_state = IDLE;
				
				if (START_CHECK)
					next_state = WAIT_FOR_GOOD_START;
			end
			WAIT_FOR_GOOD_START: begin
				next_state = WAIT_FOR_GOOD_START;
				
				if (ROW_IN == 0) begin
					row_tracker = 10;
					next_state = POPULATE_ARRAY;
					count_down = 3;
					sr = SR;
					sc = SC;
					checked = 1'b0;
					turn = TURN;
				end
			end
			POPULATE_ARRAY: begin
				next_state = POPULATE_ARRAY;
				
//				if (row_tracker != ROW_IN && count_down == 0) begin
				
				if (array_filled) 
					next_state = CHECK_WINNER;
					
				
				
				row_tracker = ROW_IN;
			end
			
			CHECK_WINNER: begin
				LEDR[6:5] = board[sr][sc - 1] == 0 ? 2'b01 : board[sr][sc - 1] == 1 ? 2'b10 : 2'b00;
				LEDR[4:3] = board[sr][sc + 1] == 0 ? 2'b01 : board[sr][sc + 1] == 1 ? 2'b10 : 2'b00;
//				next_state = CHECK_WINNER;
				
//				if (checked == 1'b0) begin
					for (i = 1; i < 7; i = i + 1) begin
						if (i == 1) begin
							count[0] = 0;
							count[1] = 0;
							count[2] = 0;
							count[3] = 0;
							count[4] = 0;
							count[5] = 0;
							count[6] = 0;
							
							dirs[0] = 0;
							dirs[1] = 0;
							dirs[2] = 0;
							dirs[3] = 0;
							dirs[4] = 0;
							dirs[5] = 0;
							dirs[6] = 0;
						end
						if (!dirs[0] && (sr + i) < 6) begin
							if (board[sr + i][sc] == turn)
								count[0] = count[0] + 1;
							else
								dirs[0] = 1;
						end
//						
						if (!dirs[1] && sc - i >= 0) begin
							if (board[sr][sc - i] == turn)
								count[1] = count[1] + 1;
							else
								dirs[1] = 1;
						end
						
						if (!dirs[2] && sc + i < 7) begin
							if (board[sr][sc + i] == turn)
								count[2] = count[2] + 1;
							else
								dirs[2] = 1;
						end
						
						if (!dirs[3] && sc - i >= 0 && sr - i >= 0) begin
							if (board[sr - i][sc - i] == turn)
								count[3] = count[3] + 1;
							else
								dirs[3] = 1;
						end
						
						if (!dirs[4] && sc + i < 7 && sr + i < 6) begin
							if (board[sr + i][sc + i] == turn)
								count[4] = count[4] + 1;
							else
								dirs[4] = 1;
						end
						
						if (!dirs[5] && sc - i >= 0 && sr + i < 6) begin
							if (board[sr + i][sc - i] == turn)
								count[5] = count[5] + 1;
							else
								dirs[5] = 1;
						end
						
						if (!dirs[6] && SC + i < 7 && SR - i >= 0) begin
							if (board[sr - i][sc + i] == turn)
								count[6] = count[6] + 1;
							else
								dirs[6] = 1;
						end
					end
					
//					checked = 1'b1;
//				end
					
				next_state = END;
			end
			
			END: begin
				next_state = IDLE;
			end
			
			default:
				next_state = IDLE;
		endcase
	end
	
	always @(posedge CLOCK_50) begin
		LEDR[1] <= WON;
		LEDR[2] <= turn;
		
		case (current_state) 
			IDLE: begin
				DONE_CHECK_WINNER <= 1'b0;
				array_filled <= 1'b0;
				DONE <= 1'b0;
				done_check <= 1'b0;
//				turn <= TURN == 1'b0 ? 0 : 1;
			end
			POPULATE_ARRAY: begin
				for (i = 0; i < 7; i = i + 1) begin
					data_at_pos = DATA_IN[(6-i)*2+:2];
					
					case (data_at_pos)
						1: board[ROW_IN][i] = 0;
						2: board[ROW_IN][i] = 1;
						default: board[ROW_IN][i] = 5;
					endcase

				
					if (ROW_IN == 5 && i == 6)
						array_filled = 1'b1;
		
				end	
			end
			
			CHECK_WINNER: begin
			end
			
			END: begin
				WON <= 1 + count[0] >= 4 || 1 + count[1] + count[2] >= 4 || 1 + count[3] + count[4] >= 4 || 1 + count[5] + count[6] >= 4;
				DONE <= 1'b1;
				WHO_WON <= turn;
				DONE_CHECK_WINNER <= 1'b1;
			end
		endcase
	end
	
	always @(posedge CLOCK_50) begin
		current_state <= next_state;
	end
	
	hex_decoder hd1(1 + count[1] + count[2], HEX1);				// Count down
//	hex_decoder hd2(1 + count[1] + count[2], HEX2);	// Count horiz
//	hex_decoder hd3(1 + count[3] + count[4], HEX3);	// Count diag pos
//	hex_decoder hd4(1 + count[5] + count[6], HEX4);	// Count diag neg
	hex_decoder hd2(current_state, HEX2);	// Count horiz
	hex_decoder hd3(sr, HEX3);	// Count diag pos
	hex_decoder hd4(sc, HEX4);	// Count diag neg

endmodule
	
module add_piece #(parameter SCREEN_WIDTH=640, parameter SCREEN_HEIGHT=480)(
	CLOCK_50,
	ROW_IN,
	COL,
	LD_PIECE,
	GAME_OVER,
	TURN,
	DONE,
	DATA_OUT,
	ANIMATING,
	X_ANI,
	Y_ANI,
	CLR,
	PIECE_COL,
	PIECE_ROW,
	HEX1);
	
	input CLOCK_50;
	
	input [2:0] COL;
	input [2:0] ROW_IN;
	input LD_PIECE, GAME_OVER;
	input TURN;
	
	output reg DONE;
	output wire [13:0] DATA_OUT;
	
	output wire ANIMATING;
	output wire [31:0] X_ANI;
	output wire [31:0] Y_ANI;
	
	output wire [1:0] CLR;
	
	assign CLR = TURN ? 2'b10 : 2'b01;
	
	output reg [2:0] PIECE_COL;
	output reg [2:0] PIECE_ROW;
	
	output wire [6:0] HEX1;
	
	
	/////////////////////////////////////////////////
	
	reg [13:0] data_out_reg;
	
	reg [2:0] row;
	reg found_insert = 1'b0;
	
	localparam 	IDLE = 0,
					INSERTING_PIECE = 1,
					ANIMATE = 2,
					WAIT_FOR_VALID_INSERT = 3,
					DONE_INSERTING = 4;
					
	reg [3:0] current_state;
	reg [3:0] next_state;
	
	wire [1:0] 	valAtGrid = DATA_OUT[(6-COL)*2+:2];
	reg [13:0] prev_data; 
	
	wire [13:0] board_data;
	
	reg trigger = 1'b0;
	
	wire done_ani;
	reg [2:0] col;
					
	always @* begin
		case (current_state) 
			IDLE:	begin
				next_state = IDLE;
				if (LD_PIECE) next_state = INSERTING_PIECE;
			end
			INSERTING_PIECE: begin
				next_state = INSERTING_PIECE;
				
				if (found_insert) next_state = ANIMATE;
			end
			ANIMATE: begin
				next_state = ANIMATE;
				
				if (done_ani)
					next_state = WAIT_FOR_VALID_INSERT;
			end
			WAIT_FOR_VALID_INSERT: begin
				next_state = WAIT_FOR_VALID_INSERT;
				
				if (DONE)
					next_state = DONE_INSERTING;
			end
			DONE_INSERTING:
				next_state = IDLE;
			default:
				next_state = IDLE;
		endcase
	
	end
	
	
	always @(posedge CLOCK_50) begin
		case (current_state) 
			IDLE:	begin
				DONE <= 1'b0;
				found_insert <= 1'b0;
				row <= 1'b0;
				col <= COL;
			end
			
			INSERTING_PIECE: begin
				col <= COL;
				if (!found_insert && ROW_IN == row && trigger) begin
					if (row == 5 && valAtGrid == 2'b00) begin
						found_insert <= 1'b1;
						
					end 
					else if (valAtGrid != 2'b00) begin
						found_insert <= 1'b1;
						
						if (row != 0)
							row <= row - 1'b1;
					end else row <= row + 1;
				end
			end
			
			WAIT_FOR_VALID_INSERT: begin
				if (ROW_IN == row) begin
					DONE <= 1'b1;
					data_out_reg <= DATA_OUT;
					data_out_reg[(6-col)*2+:2] <= TURN ? 2'b10 : 2'b01;
				end
			end
			
			DONE_INSERTING: begin
				PIECE_COL <= col;
				PIECE_ROW <= row;
			end
		endcase
			
		current_state <= next_state;
		trigger <= ~trigger;
	end
	
	wire [13:0] data_write = data_out_reg;
	
	assign X_ANI = col * (SCREEN_WIDTH/7) + (SCREEN_WIDTH / 14);
	assign ANIMATING = current_state == ANIMATE ? 1'b1 : 1'b0;
	
	// TODO: Uncomment
		drop_piece dp(
		.CLOCK_50(CLOCK_50),
		.DROP(ANIMATING),
		.Y_ANI(Y_ANI),
		.Y_DEST((row) *(SCREEN_HEIGHT / 7) + 85 + ((SCREEN_HEIGHT - 80 - 10) / 14)),
		.DONE(done_ani)
	);
	
	Board_Mem bm(
		.address(DONE ? row : ROW_IN),
		.clock(CLOCK_50),
		.data(GAME_OVER ? 14'b0 : data_write),
		.wren(DONE | GAME_OVER),
		.q(DATA_OUT));
		
	hex_decoder h2(current_state, HEX1);
		
endmodule

module get_colour(
	clr_code,
	game_state,
	clr_24,
	who_won
	);
	input [2:0] clr_code;
	input [2:0] game_state;
	input who_won;
	output reg [23:0] clr_24;
	
	localparam 	START = 0,
					GAME 	= 1,
					END 	= 2;
					
	always @* begin
		case(game_state)
			START:	begin
				case (clr_code) 
					3'b000: clr_24 = 24'h_9E_D9_E1;
					3'b001: clr_24 = 24'h_48_8C_95;
					3'b010: clr_24 = 24'h_F6_FF_94;
					3'b011: clr_24 = 24'h_88_88_88;
					3'b100: clr_24 = 24'h_00_00_00;
				endcase
			end
			GAME: 	begin
				case (clr_code)
					0: begin	// Background
							clr_24 = 24'h_17_20_2A;
						end
					1:	begin	// Borders
							clr_24 = 24'h_61_6A_6B;
						end
					2:	begin	// Red piece
							clr_24 = 24'h_FF_00_00;//24'h_F1_94_8A;
						end
					3:	begin	// Yellow piece
							clr_24 = 24'h_1A_BC_9C;
						end
					4: begin	// Piece border
							clr_24 = 24'h_FF_FF_FF;
						end
				endcase
			end
			END: begin
				case (clr_code) 
					3'b000: begin
						clr_24 = 24'h566573;
					end
					
					3'b001: begin
						clr_24 = 24'hF7DC6F;
					end
					
					3'b010: begin
						clr_24  = 24'hB7950B;
					end
					
					3'b011: begin
						clr_24 = who_won == 1'b0 ? 24'h_FF_00_00 : 24'h_1A_BC_9C;
					end
					
//					3'b100: begin
//						clr_24 = 24'hD6EAF8;
//					end
//					
//					3'b101: begin
//						clr_24 = 24'hF1C40F;
//					end
//					
//					3'b110: begin
//						clr_24 = 24'h9A7D0A;
//					end
//					
//					3'b111: begin
//						clr_24 = 24'hF9E79F;
//					end
					default: clr_24 = 24'h000000;
				endcase
			end
		endcase
	end
endmodule

module drop_piece(
	CLOCK_50,
	DROP,
	Y_DEST,
	Y_ANI,
	DONE);
	
	input CLOCK_50;
	input DROP;
	input [31:0] Y_DEST;
	
	output reg [31:0] Y_ANI;
	output wire DONE;
	
	reg [22:0] downCount = 23'd100000;
	wire animate;
	
	always @(posedge CLOCK_50) begin
		if (downCount == 23'b0)
			downCount = 23'd100000;
		else
			downCount = downCount - 1'b1;
	end
	
	assign animate = downCount == 23'b0 ? 1'b1 : 1'b0;
	
	always @(posedge CLOCK_50) begin
		if (DROP) begin
			if (DONE)
				Y_ANI <= 0;
			
			if (animate) 
				Y_ANI <= Y_ANI + 1'b1;
		
		end
		else
			Y_ANI <= 32'b0;
	end
	
	assign DONE = (DROP && Y_ANI >= Y_DEST) ? 1'b1 : 1'b0;
endmodule


module draw_screen 
#(
	parameter X_PIXELS, 
	parameter Y_PIXELS, 
	parameter SCREEN_WIDTH, 
	parameter SCREEN_HEIGHT) 
	
(
	CLOCK_50,
	DRAW,
	DROPPING_PIECE,
	D_CLR,
	X_ANI,
	Y_ANI,
	X,
	Y,
	X_C,
	Y_C,
	VAL_AT_GRID,
	c_out
);
	input 			CLOCK_50;
	input 			DRAW;
	input						DROPPING_PIECE;
	input			[1:0]		D_CLR;
	input 		[31:0] 	X_ANI;
	input 		[31:0] 	Y_ANI;
	input 		[9:0] 	X;
	input 		[9:0] 	Y;
	input 		[31:0] 	X_C;
	input 		[31:0] 	Y_C;
	input			[1:0]		VAL_AT_GRID;
	output reg	[2:0] 	c_out;
	
	
	localparam 	BG = 3'b00,
					BORDER = 3'b01,
					RED = 3'b10,
					YELLOW = 3'b11,
					PIECE_BRD = 3'd4,
					radius = 25;
				
	always @(*) begin
		if (DRAW) begin
			c_out <= BG;
			
//			if (DROPPING_PIECE) begin
				if ($signed(X - X_ANI) * $signed(X - X_ANI) + $signed(Y - Y_ANI) * $signed(Y - Y_ANI) < radius * radius) begin
					case (D_CLR)
						1: c_out <= RED;
						2: c_out <= YELLOW;
						default:;//Do nothing Already taken care of
					endcase
					
				end
				
				if ($signed(X - X_ANI) * $signed(X - X_ANI) + $signed(Y - Y_ANI) * $signed(Y - Y_ANI) > (radius-5) * (radius-5) && $signed(X - X_ANI) * $signed(X - X_ANI) + $signed(Y - Y_ANI) * $signed(Y - Y_ANI) <= (radius) * (radius)) begin
					c_out <= PIECE_BRD;
				end
//			end
			
			if (Y >= 80) begin
				if ($signed(X - X_C) * $signed(X - X_C) + $signed(Y - Y_C) * $signed(Y - Y_C) < radius * radius) begin
					case (VAL_AT_GRID)
						1: c_out <= RED;
						2: c_out <= YELLOW;
						default:; //Do nothing Already taken care of
					endcase
					
				end
				
				if (VAL_AT_GRID != 0 && $signed(X - X_C) * $signed(X - X_C) + $signed(Y - Y_C) * $signed(Y - Y_C) > (radius-5) * (radius-5) && $signed(X - X_C) * $signed(X - X_C) + $signed(Y - Y_C) * $signed(Y - Y_C) <= (radius) * (radius)) begin
					c_out <= PIECE_BRD;
				end
			end
			
			
			// Draw vertical and horizontal borders of board
			if (Y >= 80 && (
				X <= 5 ||											// Top border
				X >= 93 && X < 93 + 4 ||					// Bar 1
				X >= 93 + 90 && X < 93 + 4 + 90 ||			// Bar 2
				X >= 93 + 90 * 2 && X < 93 + 4 + 90 * 2 ||	// Bar 3
				X >= 93 + 90 * 3 && X < 93 + 4 + 90 * 3 ||	// Bar 4
				X >= 93 + 90 * 4 && X < 93 + 4 + 90 * 4 ||	// Bar 5
				X >= 93 + 90 * 5 && X < 93 + 4 + 90 * 5 ||	// Bar 6
				X >= 93 + 90 * 6		 							// Bottom border
				)) 
			begin
				c_out <= BORDER;
			end
			
			if (
				Y >= 80 && Y < 85 ||							// Left border
				Y >= 148 && Y < 148 + 4 ||						// Bar 1
				Y >= 148 + 65 && Y < 148 + 65 + 4 ||			// Bar 2
				Y >= 148 + 65 * 2 && Y < 148 + 65 * 2 + 4 ||	// Bar 3
				Y >= 148 + 65 * 3 && Y < 148 + 65 * 3 + 4 ||	// Bar 4
				Y >= 148 + 65 * 4 && Y < 148 + 65 * 4 + 4 ||	// Bar 5
				Y >= 475										// Right border
				) 
			begin
				c_out <= BORDER;
			end
		end
	end
endmodule
