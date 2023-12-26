library verilog;
use verilog.vl_types.all;
entity vga_master is
    generic(
        X_PIXELS        : integer := 640;
        Y_PIXELS        : integer := 480
    );
    port(
        CLOCK_25        : in     vl_logic;
        VGA_CLK         : out    vl_logic;
        VGA_HS          : out    vl_logic;
        VGA_VS          : out    vl_logic;
        VGA_BLANK_N     : out    vl_logic;
        VGA_SYNC_N      : out    vl_logic;
        VGA_R           : out    vl_logic_vector(7 downto 0);
        VGA_G           : out    vl_logic_vector(7 downto 0);
        VGA_B           : out    vl_logic_vector(7 downto 0);
        c_in            : in     vl_logic_vector(23 downto 0);
        x_out           : out    vl_logic_vector(9 downto 0);
        y_out           : out    vl_logic_vector(9 downto 0);
        current_buffer  : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of X_PIXELS : constant is 1;
    attribute mti_svvh_generic_type of Y_PIXELS : constant is 1;
end vga_master;
