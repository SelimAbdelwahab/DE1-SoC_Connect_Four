library verilog;
use verilog.vl_types.all;
entity FSM_DP is
    port(
        CLOCK_50        : in     vl_logic;
        bt              : in     vl_logic_vector(1 downto 0);
        player_has_won  : in     vl_logic;
        done_drop_piece : in     vl_logic;
        winner          : in     vl_logic;
        turn            : out    vl_logic;
        game_state      : out    vl_logic_vector(2 downto 0);
        col             : out    vl_logic_vector(2 downto 0);
        drop_a_piece    : out    vl_logic;
        reset_ps2       : out    vl_logic
    );
end FSM_DP;
