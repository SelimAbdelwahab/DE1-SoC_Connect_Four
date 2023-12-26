module FSM_DP(
	input CLOCK_50,
	input [1:0] bt, 
	input player_has_won,
	input done_drop_piece,
	input done_check_winner,
	input winner,
	output reg turn,
	output reg [2:0] game_state,
	output reg [2:0] col,
	output reg drop_a_piece,
	output reg reset_ps2,
	output reg check_for_winner,
	
	input AUD_ADCDAT,
	
	inout AUD_BCLK,
	inout AUD_ADCLRCK,
	inout AUD_DACLRCK,
	inout FPGA_I2C_SDAT,
	
	output AUD_DACDAT,
	output AUD_XCK,
	output FPGA_I2C_SCLK,
	
	output [6:0] HEX0
);
	
//	turn = 1'b0;
	reg [4:0] curr;
	reg [4:0] next;
	//state table
	localparam 	StrtGm = 5'd0, start_wait = 5'd1, red_turn = 5'd2, red_turn_wait = 5'd3, 
				yellow_turn = 5'd4, yellow_turn_wait = 5'd5, move_left = 4'd6, move_left_wait = 5'd7,
				move_right = 5'd8, move_right_wait = 5'd9, check_winner = 4'd10, gameover = 5'd11,
				drop_piece = 5'd12, gameover_wait = 5'd13, play_sound = 5'd14;
		   
	
	localparam 	RED = 1'b0,
					YELLOW = 1'b1;
					
	reg [31:0] down_count;
	
	always@(*) begin: state_table
		case(curr)
			StrtGm: begin 
				if(bt == 2'b00) next = StrtGm;
				if(bt == 2'b11) next = start_wait;
					end
			
			start_wait: begin
				if(bt == 2'b11) next = start_wait;
				if(bt == 2'b00) next = red_turn;
			end
			red_turn: begin
				if(bt == 2'b11) next = red_turn_wait;
				if(bt == 2'b00) next = red_turn;
				if(bt == 2'b01) next = move_right;
				if(bt == 2'b10) next = move_left;
			end
			red_turn_wait: begin //should set turn = 0
				if(bt == 2'b11) next = red_turn_wait;
				if(bt == 2'b00) next = drop_piece; //check_winner;
			end
			yellow_turn: begin 
				if(bt == 2'b11) next = yellow_turn_wait;
				if(bt == 2'b00) next = yellow_turn;
				if(bt == 2'b01) next = move_right;
				if(bt == 2'b10) next = move_left;
			end
			yellow_turn_wait: begin //should set turn = 1
				if(bt == 2'b11) next = yellow_turn_wait;
				if(bt == 2'b00) next = drop_piece; //check_winner;
			end
			check_winner: begin
				next = check_winner;
				if (done_check_winner) begin
					if(winner == 0 && turn == RED) next = yellow_turn;
					if(winner == 0 && turn == YELLOW) next = red_turn;
					if(winner == 1) next = gameover;
				end
			end
			gameover: begin
				//go back to new game after displaying winner screen
				next = gameover;
				
				if (bt == 2'b11)
					next = start_wait; 
			end
			move_left: begin
				if(bt == 2'b00) next = move_left_wait;
				if(bt == 2'b10) next = move_left;
			end
			move_left_wait: begin
				if (turn == RED) next = red_turn;
				if (turn == YELLOW) next = yellow_turn;
			end
			move_right: begin
				if(bt == 2'b00) next = move_right_wait;
				if(bt == 2'b01) next = move_right;
			end
			move_right_wait: begin
				if (turn == RED) next = red_turn;
				if (turn == YELLOW) next = yellow_turn;
			end
			
			drop_piece: begin
				next = drop_piece;
				
				if (done_drop_piece)
					next = play_sound;
			end
			
			gameover_wait: begin
				if (bt == 2'b00) 
					next = red_turn;
			end
			
			play_sound: begin
				next = play_sound;
				
				if (down_count == 0)
					next = check_winner;
			end
			default: next = StrtGm;
		endcase
	end
	
	always @(posedge CLOCK_50) begin
		reset_ps2 <= 1'b0;

		case (curr)
			StrtGm: begin 
				col <= 3'b0;
				turn <= 1'b0;
				game_state <= 3'b0;
				drop_a_piece <= 1'b0;
			end
			
			start_wait: begin
				reset_ps2 <= 1'b1;
				col <= 3'b0;
				turn <= 1'b0;
				game_state <= 3'b0;
				drop_a_piece <= 1'b0;
			end	
			red_turn: begin
				turn = RED;

				game_state <= 3'b1;
			end
			red_turn_wait: begin //should set turn = 0
				turn = RED;
			end
			yellow_turn: begin 
				turn = YELLOW;

				game_state <= 3'b1;
			end
			yellow_turn_wait: begin //should set turn = 1
				turn = YELLOW;
			end
			check_winner: begin
				drop_a_piece <= 1'b0;
				check_for_winner <= 1'b1;
			end

			move_left: begin

			end
			move_left_wait: begin
				reset_ps2 <= 1'b1;
				
				if (col != 0)
					col <= col - 1;
				else 
					col <= 3'd6;
			end
			move_right: begin

			end
			move_right_wait: begin
				reset_ps2 <= 1'b1;
				
				if (col != 6)
					col <= col + 1;
				else
					col <= 3'b0;
			end
			
			drop_piece: begin
				drop_a_piece <= 1'b1;
				reset_ps2 <= 1'b1;
				down_count <= 5000000;
				check_for_winner <= 1'b0;
			end
			
			gameover: begin
				game_state <= 3'd2;
				
			end
			
			gameover_wait: begin
				col <= 3'b0;
			end
			
			play_sound: begin
				down_count <= down_count - 1;
				drop_a_piece <= 1'b0;
			end
		endcase
	end
	
	always @(posedge CLOCK_50) begin
		curr <= next;
	end
	
	hex_decoder (curr, HEX0);
	
	DE1_SoC_Audio_Example aud (
	// Inputs
	.CLOCK_50(CLOCK_50),
	.KEY({1'b1, 1'b1, 1'b1, 1'b1}),

	.AUD_ADCDAT(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK(AUD_BCLK),
	.AUD_ADCLRCK(AUD_ADCLRCK),
	.AUD_DACLRCK(AUD_DACLRCK),

	.FPGA_I2C_SDAT(FPGA_I2C_SDAT),

	// Outputs
	.AUD_XCK(AUD_XCK),
	.AUD_DACDAT(AUD_DACDAT),

	.FPGA_I2C_SCLK(FPGA_I2C_SCLK),
	.SW({1'b0, 1'b0, curr == play_sound ? 2'b11 : 2'b0})
);

endmodule
	