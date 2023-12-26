library verilog;
use verilog.vl_types.all;
entity hex_decoder is
    port(
        c               : in     vl_logic_vector(3 downto 0);
        display         : out    vl_logic_vector(6 downto 0)
    );
end hex_decoder;
