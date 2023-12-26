library verilog;
use verilog.vl_types.all;
entity check_winner is
    port(
        CLOCK_50        : in     vl_logic;
        START_CHECK     : in     vl_logic;
        ROW_IN          : in     vl_logic_vector(2 downto 0);
        DATA_IN         : in     vl_logic_vector(13 downto 0);
        SR              : in     vl_logic_vector(2 downto 0);
        SC              : in     vl_logic_vector(2 downto 0);
        TURN            : in     vl_logic;
        DONE            : out    vl_logic;
        HEX1            : out    vl_logic_vector(6 downto 0);
        HEX2            : out    vl_logic_vector(6 downto 0);
        HEX3            : out    vl_logic_vector(6 downto 0);
        HEX4            : out    vl_logic_vector(6 downto 0);
        LEDR            : out    vl_logic_vector(7 downto 1);
        WON             : out    vl_logic
    );
end check_winner;
