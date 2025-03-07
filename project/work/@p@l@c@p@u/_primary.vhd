library verilog;
use verilog.vl_types.all;
entity PLCPU is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        inst_in         : in     vl_logic_vector(31 downto 0);
        Data_in         : in     vl_logic_vector(31 downto 0);
        PC_out          : out    vl_logic_vector(31 downto 0);
        Addr_out        : out    vl_logic_vector(31 downto 0);
        Data_out        : out    vl_logic_vector(31 downto 0);
        mem_w           : out    vl_logic;
        mem_r           : out    vl_logic
    );
end PLCPU;
