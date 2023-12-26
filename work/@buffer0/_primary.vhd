library verilog;
use verilog.vl_types.all;
entity Buffer0 is
    port(
        address         : in     vl_logic_vector(18 downto 0);
        clock           : in     vl_logic;
        data            : in     vl_logic_vector(2 downto 0);
        wren            : in     vl_logic;
        q               : out    vl_logic_vector(2 downto 0)
    );
end Buffer0;
