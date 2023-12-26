module Connect_Four
	(
	input wire 			CLOCK_50,
	input wire			PS2_CLK,
	input wire 			PS2_DAT,
//	input wire 	[3:0] KEY,
//	input wire 	[9:0] SW,
	output wire [7:0] VGA_R,
	output wire [7:0] VGA_G,
	output wire [7:0] VGA_B,
	output wire 		VGA_CLK,
	output wire 		VGA_HS,
	output wire 		VGA_VS,
	output wire 		VGA_SYNC_N,
	output wire 		VGA_BLACK_N,
	output wire [6:0]	HEX0,
	output wire [6:0]	HEX1,
	output wire [6:0]	HEX2,
	output wire [6:0]	HEX3,
	output wire [6:0]	HEX4,
	output wire [6:0]	HEX5,
	output wire [9:0]	LEDR,
	
	input AUD_ADCDAT,
	
	inout AUD_BCLK,
	inout AUD_ADCLRCK,
	inout AUD_DACLRCK,
	inout FPGA_I2C_SDAT,
	
	output AUD_DACDAT,
	output AUD_XCK,
	output FPGA_I2C_SCLK
//	input [1:0] key_code
	);
	
	//////////////////// Internal connections ////////////////////
	wire [1:0] key_code; // Passed to ps2 module and returns key pressed
								// 00: no key pressed, 01: right arrow, 10: left arrow, 11: space key
	
	
	wire player_has_won;
	
	wire turn;
	wire [2:0] col;
	wire [2:0] game_state;
	
	wire drop_a_piece, done_drop_piece;
	wire done_check_winner;
	
	wire reset_ps2;
	
	wire check_for_winner;
	/////////////////////////////////////////////////////////////
	
	
	
	FSM_DP fd(
		.CLOCK_50(CLOCK_50),
		.bt(key_code),
		.player_has_won(player_has_won),
		.winner(player_has_won),
		.done_check_winner(done_check_winner),
		.turn(turn),
		.col(col),
		.game_state(game_state),
		.drop_a_piece(drop_a_piece),
		.done_drop_piece(done_drop_piece),
		.reset_ps2(reset_ps2),
		.check_for_winner(check_for_winner),

		.AUD_ADCDAT(AUD_ADCDAT),
	
		.AUD_BCLK(AUD_BCLK),
		.AUD_ADCLRCK(AUD_ADCLRCK),
		.AUD_DACLRCK(AUD_DACLRCK),
		.FPGA_I2C_SDAT(FPGA_I2C_SDAT),
		
		.AUD_DACDAT(AUD_DACDAT),
		.AUD_XCK(AUD_XCK),
		.FPGA_I2C_SCLK(FPGA_I2C_SCLK),
		.HEX0(HEX0)
		);
		
	PS2 ps2_our_decoder_not_the_given_one(
		.RESET(reset_ps2),
		.CLOCK_50(CLOCK_50),
		.PS2_CLK(PS2_CLK),
		.PS2_DAT(PS2_DAT),
		.KEY_TWO(key_code));
		
	Display_Controller dc
		(
		.CLOCK_50(CLOCK_50),
		.COL(col),
		.TURN(turn),
		.GAME_STATE(game_state),
		.DROP_A_PIECE(drop_a_piece),
		.CHECK_FOR_WINNER(check_for_winner),
		
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_CLK(VGA_CLK),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_SYNC_N(VGA_SYNC_N),
		.VGA_BLACK_N(VGA_BLACK_N),
		.LEDR(LEDR),
//		.HEX0(HEX0),
		.HEX1(HEX1),
		.HEX2(HEX2),
		.HEX3(HEX3),
		.HEX4(HEX4),
		
		.DONE_DROP_PIECE(done_drop_piece),
		.HAS_WON(player_has_won),
		.DONE_CHECK_WINNER(done_check_winner)
		);
		
	hex_decoder h5(game_state, HEX5);
endmodule
