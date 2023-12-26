library verilog;
use verilog.vl_types.all;
entity drop_piece is
    port(
        CLOCK_50        : in     vl_logic;
        DROP            : in     vl_logic;
        Y_DEST          : in     vl_logic_vector(31 downto 0);
        Y_ANI           : out    vl_logic_vector(31 downto 0);
        DONE            : out    vl_logic
    );
end drop_piece;
