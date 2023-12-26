library verilog;
use verilog.vl_types.all;
entity get_colour is
    port(
        clr_code        : in     vl_logic_vector(2 downto 0);
        game_state      : in     vl_logic_vector(2 downto 0);
        clr_24          : out    vl_logic_vector(23 downto 0)
    );
end get_colour;
