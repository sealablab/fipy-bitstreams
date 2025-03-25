library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

entity ScanGen is
	Port (
		clk : in STD_LOGIC;
        reset : in std_logic;

        Trg_In: in signed(15 downto 0);
        Trg_Level: in signed(15 downto 0);

        Scan_Num_Fast : in unsigned(15 downto 0);
        Scan_Num_Slow : in unsigned(15 downto 0);      

        Scan_Fast : out signed(15 downto 0);
        Scan_Slow : out signed(15 downto 0)
	);
end ScanGen;

architecture Behavioural of ScanGen is
  
    type CounterState is (
        WaitForTrg,
        Scan,
        Dead
    );
    
    signal State : CounterState;
    signal NextState : CounterState;

    signal Trg_In_prev : signed(15 downto 0);
    signal ReverseFlag : std_logic;
    signal Counter_Fast : unsigned(15 downto 0);
    signal Counter_Slow : unsigned(15 downto 0);

    signal OutputTemp_Fast: std_logic_vector(15 downto 0);
    signal OutputTemp_Slow: std_logic_vector(15 downto 0);

begin

-----------------------------------------------------------------------------
-- Fast pattern read out
-----------------------------------------------------------------------------
    ROM_Fast : entity work.rom_fast
    generic map(
     rom_width => 10
      )
    port map(
      clk			  => clk,
      address         => std_logic_vector(Counter_Fast(15 downto 0)),
      data_out        => OutputTemp_Fast
    );  

-----------------------------------------------------------------------------
-- Slow pattern read out
-----------------------------------------------------------------------------
    ROM_Slow : entity work.rom_slow
    generic map(
     rom_width => 10
      )
    port map(
      clk			  => Clk,
      address         => std_logic_vector(Counter_Slow(15 downto 0)),
      data_out        => OutputTemp_Slow
    );  

------------------------------------------------------------------------------
-- Calculate next state
------------------------------------------------------------------------------
    process(all)
    begin

        case State is
            when WaitForTrg =>
                if (Trg_In_prev < Trg_Level and Trg_In > Trg_Level) then
                  if Counter_Slow >= (Scan_Num_Slow- to_unsigned(1,16)) 
                    and Counter_Fast >= (Scan_Num_Fast- to_unsigned(1,16)) 
                    and Scan_Num_Slow(0)='1' then
                    NextState <= Dead;
                  elsif Counter_Slow >= (Scan_Num_Slow- to_unsigned(1,16)) 
                    and Counter_Fast = to_unsigned(0,16)
                    and Scan_Num_Slow(0) = '0' then
                    NextState <= Dead;
                  else
                    NextState <= Scan;
                  end if;
                else
                  NextState <= WaitForTrg;
                end if;
                  
            when Scan =>
                NextState <= WaitForTrg;
                  
            when Dead =>
                NextState <= Dead;
                  
            when others => 
                NextState <= Dead;

        end case;
    end process;

------------------------------------------------------------------------------
-- Move to next state
------------------------------------------------------------------------------
    process(reset, clk) is
    begin
      if rising_edge(clk) then
        if reset then
          State <= WaitForTrg;
        else
          State <= NextState;
        end if;
      end if;
    end process;
------------------------------------------------------------------------------          

------------------------------------------------------------------------------
-- Reg trigger input to detect edges
------------------------------------------------------------------------------
    process(clk) is
    begin
      if rising_edge(clk) then
        Trg_In_prev <= Trg_In;
      end if;
    end process;
------------------------------------------------------------------------------          

------------------------------------------------------------------------------
-- Scan counters
------------------------------------------------------------------------------
    process(reset, clk) is
    begin
      if rising_edge(clk) then
        if reset then
          Scan_Fast <= (others => '0');
          Scan_Slow <= (others => '0');
      
          Counter_Fast <= (others => '0');
          Counter_Slow <= (others => '0');

          ReverseFlag <= '0';
        else
          Scan_Fast <= signed(OutputTemp_Fast);
          Scan_Slow <= signed(OutputTemp_Slow);
          if State = Scan then
            -- start decrementing
            if ( Counter_Fast >= (Scan_Num_Fast - to_unsigned(1,16)) and ReverseFlag = '0') then
              Counter_Fast <= Counter_Fast;
              Counter_Slow <= Counter_Slow + to_unsigned(1,16);
              ReverseFlag <= '1';
            -- decrementing
            elsif ( Counter_Fast > to_unsigned(0,16) and ReverseFlag = '1') then
              Counter_Fast <= Counter_Fast - to_unsigned(1,16);
              Counter_Slow <= Counter_Slow;
              ReverseFlag <= '1';
            -- restart incrementing
            elsif  ( Counter_Fast = to_unsigned(0,16) and ReverseFlag = '1') then
              Counter_Fast <= Counter_Fast;
              Counter_Slow <= Counter_Slow + to_unsigned(1,16);
              ReverseFlag <= '0';
            -- incrementing
            elsif (ReverseFlag = '0') then
              Counter_Fast <= Counter_Fast + to_unsigned(1,16);
              Counter_Slow <= Counter_Slow;
              ReverseFlag <= '0';
            -- hold on
            else
              Counter_Fast <= Counter_Fast;
              Counter_Slow <= Counter_Slow;
            end if;
          elsif State = Dead then
            -- Scan_Fast <= (others => '0');
            -- Scan_Slow <= (others => '0');
            
            Counter_Fast <= (others => '0');
            Counter_Slow <= (others => '0');

            ReverseFlag <= '0';
          end if;
        end if;
      end if;
    end process;
------------------------------------------------------------------------------      
                  
end Behavioural;
