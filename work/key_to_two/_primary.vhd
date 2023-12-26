library verilog;
use verilog.vl_types.all;
entity key_to_two is
    port(
        CLOCK_50        : in     vl_logic;
        KEY_CODE        : in     vl_logic_vector(15 downto 0);
        KEY_TWO         : out    vl_logic_vector(1 downto 0)
    );
end key_to_two;
