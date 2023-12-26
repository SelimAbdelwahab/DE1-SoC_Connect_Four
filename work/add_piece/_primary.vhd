library verilog;
use verilog.vl_types.all;
entity add_piece is
    generic(
        SCREEN_WIDTH    : integer := 640;
        SCREEN_HEIGHT   : integer := 480
    );
    port(
        CLOCK_50        : in     vl_logic;
        ROW_IN          : in     vl_logic_vector(2 downto 0);
        COL             : in     vl_logic_vector(2 downto 0);
        LD_PIECE        : in     vl_logic;
        TURN            : in     vl_logic;
        DONE            : out    vl_logic;
        DATA_OUT        : out    vl_logic_vector(13 downto 0);
        ANIMATING       : out    vl_logic;
        X_ANI           : out    vl_logic_vector(31 downto 0);
        Y_ANI           : out    vl_logic_vector(31 downto 0);
        CLR             : out    vl_logic_vector(1 downto 0);
        PIECE_COL       : out    vl_logic_vector(2 downto 0);
        PIECE_ROW       : out    vl_logic_vector(2 downto 0);
        HEX1            : out    vl_logic_vector(6 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of SCREEN_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of SCREEN_HEIGHT : constant is 1;
end add_piece;
