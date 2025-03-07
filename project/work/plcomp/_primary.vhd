library verilog;
use verilog.vl_types.all;
entity plcomp is
    port(
        clk             : in     vl_logic;
        rstn            : in     vl_logic
    );
end plcomp;
