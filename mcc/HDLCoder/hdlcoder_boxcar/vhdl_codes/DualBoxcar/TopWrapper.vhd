LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ARCHITECTURE HDLCoderWrapper OF CustomWrapper IS
  -- Component Declarations

COMPONENT DSP -- Make sure this matches your VHDL code
  PORT( Clk                               :   IN    std_logic;
        Reset                             :   IN    std_logic;
        InputA                            :   IN    signed(15 DOWNTO 0);  -- int16
        InputB                            :   IN    signed(15 DOWNTO 0);  -- int16
        TriggerLevel                      :   IN    signed(15 DOWNTO 0);  -- int16
        TriggerDelay_0                    :   IN    signed(15 DOWNTO 0);  -- int16
        GateWidth_0                       :   IN    signed(15 DOWNTO 0);  -- int16
        AvgLength_0                       :   IN    signed(15 DOWNTO 0);  -- int16
        OutASwitch                        :   IN    std_logic;
        Gain_0                            :   IN    signed(31 DOWNTO 0);  -- int32
        TriggerDelayBaseline_0            :   IN    signed(15 DOWNTO 0);  -- int16
        FlagSwitch                        :   IN    std_logic;
        TriggerDelay_1                    :   IN    signed(15 DOWNTO 0);  -- int16
        GateWidth_1                       :   IN    signed(15 DOWNTO 0);  -- int16
        AvgLength_1                       :   IN    signed(15 DOWNTO 0);  -- int16
        TriggerDelayBaseline_1            :   IN    signed(15 DOWNTO 0);  -- int16
        Gain_1                            :   IN    signed(31 DOWNTO 0);  -- int32
        OutBSwitch                        :   IN    std_logic;
        AlignSwitch                       :   IN    std_logic;
        OutputA                           :   OUT   signed(15 DOWNTO 0);  -- int16
        OutputB                           :   OUT   signed(15 DOWNTO 0)  -- int16
        );
END COMPONENT;

  
BEGIN
  Averager:DSP
  PORT MAP(Clk=>Clk,
           Reset=>Reset,
           InputA=>InputA,
           InputB=>InputB,
           
           TriggerLevel           =>signed(Control0(15 downto 0)),
           
           TriggerDelay_0         =>signed(Control1(15 downto 0)),
           TriggerDelayBaseline_0 =>signed(Control2(15 downto 0)),
           GateWidth_0            =>signed(Control3(15 downto 0)),
           AvgLength_0            =>signed(Control4(15 downto 0)),
           Gain_0                 =>signed(Control5(31 downto 0)),
           
           TriggerDelay_1         =>signed(Control6(15 downto 0)),
           TriggerDelayBaseline_1 =>signed(Control7(15 downto 0)),
           GateWidth_1            =>signed(Control8(15 downto 0)),
           AvgLength_1            =>signed(Control9(15 downto 0)),
           Gain_1                 =>signed(Control10(31 downto 0)),
           
           OutBSwitch             =>Control15(0),
           FlagSwitch             =>Control15(1),
           OutASwitch             =>Control15(2),
           AlignSwitch            =>Control15(3),
           -- Averager_0 align : 1111
           -- Averager_0 avg   : 0111
           -- Averager_1 align : 1101
           -- Averager_1 avg   : 1001
           -- Both Averager    : 0100
           
           OutputA=>OutputA,
           OutputB=>OutputB
           );
end ARCHITECTURE;

