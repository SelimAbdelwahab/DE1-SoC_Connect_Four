library verilog;
use verilog.vl_types.all;
entity PS2 is
    port(
        CLOCK_50        : in     vl_logic;
        PS2_CLK         : in     vl_logic;
        PS2_DAT         : in     vl_logic;
        KEY_TWO         : out    vl_logic_vector(1 downto 0);
        RESET           : in     vl_logic;
        HEX2            : out    vl_logic_vector(6 downto 0);
        HEX3            : out    vl_logic_vector(6 downto 0);
        LEDR            : out    vl_logic_vector(9 downto 8)
    );
end PS2;
