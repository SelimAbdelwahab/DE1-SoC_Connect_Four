vlib work

vlog Connect_Four.v FSM.v display_controller.v buffer0.v buffer1.v vga_all.v Board_Mem.v PS2.v C:/Users/mimo2/OneDrive/Desktop/UofT/Yr_2/Fall/ECE241/Lab2_Q/Part3/part3.v

vsim -L altera_mf_ver Connect_Four -novopt
set WildcardFilter [lsearch -not -all -inline $WildcardFilter Memory]

log {/*}


radix unsigned

#add wave {/*}
#add wave -divider Clock:
#add wave CLOCK_50
#add wave CLOCK_25

#add wave -divider Buffer:
#add wave -color yellow current_buffer
#add wave wren0 wren1 
#
#add wave -divider "(X, Y):"
#add wave x_out y_out
#
#add wave addy 
#
#add wave -divider "c_in"
#add wave c_in q0 q1
#
#add wave -divider "Board"
#add wave valAtGrid board_add X_C Y_C x_i y_i data_out

#add wave -divider Colors:
#add wave pixelIn
#add wave -color red -radix binary VGA_R
#add wave -color green -radix binary VGA_G
#add wave -color blue -radix binary VGA_B

#add wave -divider "Add Piece"
#add wave ap/*;

add wave dc/*;


add wave -divider "Check Winner"
add wave dc/cw/*;
delete wave cw/CLOCK_50

force CLOCK_50 1,0 10 ns -r 20 ns

force key_code 2#11
run 40ns

force key_code 2#00
run 40ns

force key_code 2#11
run 40ns

force key_code 2#00

#force GAME_STATE 10#1
#force {DROP_A_PIECE} 0
#force {COL} 3
#force {TURN} 1


run 10000000ps

force key_code 2#11
run 10000000ps

force key_code 2#00
#force {DROP_A_PIECE} 0

run 1000us;