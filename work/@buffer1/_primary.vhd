library verilog;
use verilog.vl_types.all;
entity Buffer1 is
    port(
        clock           : in     vl_logic;
        data            : in     vl_logic_vector(2 downto 0);
        rdaddress       : in     vl_logic_vector(18 downto 0);
        wraddress       : in     vl_logic_vector(18 downto 0);
        wren            : in     vl_logic;
        q               : out    vl_logic_vector(2 downto 0)
    );
end Buffer1;
