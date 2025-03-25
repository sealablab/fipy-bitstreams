library IEEE;
use IEEE.Std_Logic_1164.All;
use IEEE.Numeric_Std.all;

architecture PulseGen of CustomWrapper is

begin

  ScanOut: entity work.ScanGen
  Port map(
    clk => clk,
    reset => Control0(0),

    Trg_In => InputA,
    Trg_Level => signed(Control1(15 downto 0)),

    Scan_Num_Fast => unsigned(Control2(15 downto 0)),
    Scan_Num_Slow => unsigned(Control3(15 downto 0)),

    Scan_Fast => OutputA,
    Scan_Slow => OutputB
  );
    
end architecture;