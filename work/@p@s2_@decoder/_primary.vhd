library verilog;
use verilog.vl_types.all;
entity PS2_Decoder is
    port(
        CLOCK_50        : in     vl_logic;
        PS2_CLK         : in     vl_logic;
        PS2_DAT         : in     vl_logic;
        KEY_TWO         : in     vl_logic_vector(1 downto 0);
        RESET           : in     vl_logic;
        DAT_OUT         : out    vl_logic_vector(15 downto 0);
        LEDR            : out    vl_logic_vector(9 downto 8)
    );
end PS2_Decoder;
