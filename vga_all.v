module vga_master
#
(
	parameter X_PIXELS = 640,
	parameter Y_PIXELS = 480
)

(

	CLOCK_25,
	VGA_CLK,   						//	VGA Clock		Must be asserted to the input clock (i.e. VGA_CLK = CLOCK_25)
	VGA_HS,							//	VGA H_SYNC
	VGA_VS,							//	VGA V_SYNC
	VGA_BLANK_N,					//	VGA BLANK: 		Should be logic 1 when within active regions (h_counter < 640, v_counter < 480)
	VGA_SYNC_N,						//	VGA SYNC: 		Should always be 1
	VGA_R,   						//	VGA Red[9:0]
	VGA_G,	 						//	VGA Green[9:0]
	VGA_B,   						//	VGA Blue[9:0]
	c_in,
	x_out,							// 	current x_val
	y_out,							// 	current y_val  
	current_buffer
);
	
	input			CLOCK_25;
	input	[23:0]	c_in;
	
	
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;			//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	output	[9:0]	x_out;
	output	[9:0]	y_out;
	
	// Keeps track of which buffer is driving RGB values
	output			current_buffer;

	vga_controller vgac (
		.CLOCK_25(CLOCK_25),
		.VGA_CLK(VGA_CLK),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK_N(VGA_BLANK_N),
		.VGA_SYNC_N(VGA_SYNC_N),
		.current_buffer(current_buffer),
		.oX(x_out),
		.oY(y_out));
	
	vga_plotter vgap (
		.c_in(c_in),
		.DISPLAY_VALID(VGA_BLANK_N),
		.VGA_R(VGA_R),
		.VGA_B(VGA_B),
		.VGA_G(VGA_G));


endmodule

module vga_controller
(
	CLOCK_25,
	VGA_CLK,   						//	VGA Clock
	VGA_HS,							//	VGA H_SYNC
	VGA_VS,							//	VGA V_SYNC
	VGA_BLANK_N,					//	VGA BLANK
	VGA_SYNC_N,						//	VGA SYNC
	
	current_buffer,					// Selected buffer 
	oX,								// Current x pixel
	oY								// Current y pixel
);
	
	input			CLOCK_25;	

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output	reg	VGA_HS;					//	VGA H_SYNC
	output	reg	VGA_VS;					//	VGA V_SYNC
	output	reg	VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC

	output 	reg		current_buffer = 0;
	output	reg		[9:0]	oX;
	output 	reg		[9:0]	oY;
	
	parameter H_ACTIVE  = 10'd640;
	parameter H_SS  	= 10'd659;
	parameter H_SE   	= 10'd754; //(C_HORZ_SYNC_START + 96 - 1); 
	parameter H_TOT 	= 10'd800;	
//	parameter H_TOT 	= 10'd10;	
	
	parameter V_ACTIVE  = 10'd480;
	parameter V_SS  	= 10'd493;
	parameter V_SE    	= 10'd494; //(C_VERT_SYNC_START + 2 - 1); 
	parameter V_TOT 	= 10'd525;
	
	reg [9:0] h_counter = 0;
	reg [9:0] v_counter = 0;
		
	reg hs, vs, blank;
	
	always @(posedge CLOCK_25) begin : ITERATOR_LOGIC
		if (h_counter == H_TOT) begin
			h_counter <= 10'b0;
			
			v_counter <= v_counter + 1'b1;
			
			if (v_counter == V_TOT) begin
				v_counter <= 10'b0;
				
				current_buffer <= current_buffer == 1'b1 ? 1'b0 : 1'b1;
			end
		end else begin
			h_counter <= h_counter + 1'b1;
		end
	end
	
	always @(posedge CLOCK_25) begin : SYNC_LOGIC
		hs <= ~((h_counter >= H_SS) && (h_counter <= H_SE));
		vs <= ~((v_counter >= V_SS) && (v_counter <= V_SE));
		
		blank <= ((h_counter < H_ACTIVE) && (v_counter < V_ACTIVE));
		
		VGA_HS <= hs;
		VGA_VS <= vs;
		VGA_BLANK_N <= blank;
		
		oX <= h_counter;
		oY <= v_counter;
	end
	
	assign VGA_CLK = CLOCK_25;
	assign VGA_SYNC_N = 1'b1;
endmodule

module vga_plotter
(
	c_in,
	DISPLAY_VALID,
	VGA_R,   						//	VGA Red[9:0]
	VGA_G,	 						//	VGA Green[9:0]
	VGA_B   						//	VGA Blue[9:0]
);
	input [23:0] c_in;
	input DISPLAY_VALID;
	output reg [7:0] VGA_R;
	output reg [7:0] VGA_G;
	output reg [7:0] VGA_B;
	
	always @(*) begin
		// Set default color to black
		VGA_R <= 8'b0;
		VGA_G <= 8'b0;
		VGA_B <= 8'b0;
		
		// If x is within 640px and y within 480 assign colors
		if (DISPLAY_VALID) begin			
//			case (c_in)
//				0: begin	// Background
//						{VGA_R, VGA_G, VGA_B} <= 24'h_34_49_5E;
//					end
//				1:	begin	// Borders
//						{VGA_R, VGA_G, VGA_B} <= 24'h_FF_FF_FF;
//					end
//				2:	begin	// Red piece
//						{VGA_R, VGA_G, VGA_B} <= 24'h_F1_94_8A;
//					end
//				3:	begin	// Yellow piece
//						{VGA_R, VGA_G, VGA_B} <= 24'h_F9_E7_9F;
//					end
//			endcase
			{VGA_R, VGA_G, VGA_B} <= c_in;
		end
	end

endmodule