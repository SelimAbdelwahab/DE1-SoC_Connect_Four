library verilog;
use verilog.vl_types.all;
entity Board_Mem is
    port(
        address         : in     vl_logic_vector(2 downto 0);
        clock           : in     vl_logic;
        data            : in     vl_logic_vector(13 downto 0);
        wren            : in     vl_logic;
        q               : out    vl_logic_vector(13 downto 0)
    );
end Board_Mem;
