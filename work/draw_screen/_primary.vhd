library verilog;
use verilog.vl_types.all;
entity draw_screen is
    generic(
        X_PIXELS        : vl_notype;
        Y_PIXELS        : vl_notype;
        SCREEN_WIDTH    : vl_notype;
        SCREEN_HEIGHT   : vl_notype
    );
    port(
        CLOCK_50        : in     vl_logic;
        DRAW            : in     vl_logic;
        DROPPING_PIECE  : in     vl_logic;
        D_CLR           : in     vl_logic_vector(1 downto 0);
        X_ANI           : in     vl_logic_vector(31 downto 0);
        Y_ANI           : in     vl_logic_vector(31 downto 0);
        X               : in     vl_logic_vector(9 downto 0);
        Y               : in     vl_logic_vector(9 downto 0);
        X_C             : in     vl_logic_vector(31 downto 0);
        Y_C             : in     vl_logic_vector(31 downto 0);
        VAL_AT_GRID     : in     vl_logic_vector(1 downto 0);
        c_out           : out    vl_logic_vector(2 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of X_PIXELS : constant is 5;
    attribute mti_svvh_generic_type of Y_PIXELS : constant is 5;
    attribute mti_svvh_generic_type of SCREEN_WIDTH : constant is 5;
    attribute mti_svvh_generic_type of SCREEN_HEIGHT : constant is 5;
end draw_screen;
