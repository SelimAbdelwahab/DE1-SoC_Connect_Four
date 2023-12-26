library verilog;
use verilog.vl_types.all;
entity Display_Controller is
    port(
        CLOCK_50        : in     vl_logic;
        COL             : in     vl_logic_vector(2 downto 0);
        TURN            : in     vl_logic;
        GAME_STATE      : in     vl_logic_vector(2 downto 0);
        DROP_A_PIECE    : in     vl_logic;
        VGA_R           : out    vl_logic_vector(7 downto 0);
        VGA_G           : out    vl_logic_vector(7 downto 0);
        VGA_B           : out    vl_logic_vector(7 downto 0);
        VGA_CLK         : out    vl_logic;
        VGA_HS          : out    vl_logic;
        VGA_VS          : out    vl_logic;
        VGA_SYNC_N      : out    vl_logic;
        VGA_BLACK_N     : out    vl_logic;
        LEDR            : out    vl_logic_vector(9 downto 0);
        HEX0            : out    vl_logic_vector(6 downto 0);
        HEX1            : out    vl_logic_vector(6 downto 0);
        HEX2            : out    vl_logic_vector(6 downto 0);
        HEX3            : out    vl_logic_vector(6 downto 0);
        HEX4            : out    vl_logic_vector(6 downto 0);
        DONE_DROP_PIECE : out    vl_logic
    );
end Display_Controller;
