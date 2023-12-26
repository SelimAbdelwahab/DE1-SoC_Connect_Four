library verilog;
use verilog.vl_types.all;
entity vga_controller is
    generic(
        H_ACTIVE        : vl_logic_vector(0 to 9) := (Hi1, Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        H_SS            : vl_logic_vector(0 to 9) := (Hi1, Hi0, Hi1, Hi0, Hi0, Hi1, Hi0, Hi0, Hi1, Hi1);
        H_SE            : vl_logic_vector(0 to 9) := (Hi1, Hi0, Hi1, Hi1, Hi1, Hi1, Hi0, Hi0, Hi1, Hi0);
        H_TOT           : vl_logic_vector(0 to 9) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi1, Hi0);
        V_ACTIVE        : vl_logic_vector(0 to 9) := (Hi0, Hi1, Hi1, Hi1, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0);
        V_SS            : vl_logic_vector(0 to 9) := (Hi0, Hi1, Hi1, Hi1, Hi1, Hi0, Hi1, Hi1, Hi0, Hi1);
        V_SE            : vl_logic_vector(0 to 9) := (Hi0, Hi1, Hi1, Hi1, Hi1, Hi0, Hi1, Hi1, Hi1, Hi0);
        V_TOT           : vl_logic_vector(0 to 9) := (Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi1, Hi0, Hi1)
    );
    port(
        CLOCK_25        : in     vl_logic;
        VGA_CLK         : out    vl_logic;
        VGA_HS          : out    vl_logic;
        VGA_VS          : out    vl_logic;
        VGA_BLANK_N     : out    vl_logic;
        VGA_SYNC_N      : out    vl_logic;
        current_buffer  : out    vl_logic;
        oX              : out    vl_logic_vector(9 downto 0);
        oY              : out    vl_logic_vector(9 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of H_ACTIVE : constant is 1;
    attribute mti_svvh_generic_type of H_SS : constant is 1;
    attribute mti_svvh_generic_type of H_SE : constant is 1;
    attribute mti_svvh_generic_type of H_TOT : constant is 1;
    attribute mti_svvh_generic_type of V_ACTIVE : constant is 1;
    attribute mti_svvh_generic_type of V_SS : constant is 1;
    attribute mti_svvh_generic_type of V_SE : constant is 1;
    attribute mti_svvh_generic_type of V_TOT : constant is 1;
end vga_controller;
