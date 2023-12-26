library verilog;
use verilog.vl_types.all;
entity vga_plotter is
    port(
        c_in            : in     vl_logic_vector(23 downto 0);
        DISPLAY_VALID   : in     vl_logic;
        VGA_R           : out    vl_logic_vector(7 downto 0);
        VGA_G           : out    vl_logic_vector(7 downto 0);
        VGA_B           : out    vl_logic_vector(7 downto 0)
    );
end vga_plotter;
