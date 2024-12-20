library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package my_types is
  type frequency is range 0 to 2147483647
    units
      Hz;
      KHz = 1000 Hz;
      MHz = 1000 KHz;
      GHz = 1000 MHz;
    end units;
   
  function "/" (L : integer; R : frequency) return time;
  function "/" (L : time; R : time) return integer;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_types.all;

entity NRZ_sequence is
  generic (
    clk_frequency : frequency := 50 MHz;
    duration_clk_counts : integer;
    code_0_high_duration_clk_counts : integer;
    code_1_high_duration_clk_counts : integer
  );
  
  port (
    clk : in std_logic;
    trigger : in std_logic;
    finished : in std_logic;
    bit_to_code : in std_logic;
    sequence : out std_logic := '0'
  );

end entity;

architecture behavior of NRZ_sequence is
  function "/" (L : integer; R : frequency) return time is
  begin
    return 20 ns;
  end function;
  
  function "/" (L : time; R : time) return integer is
  begin
    return 40;
  end function;


  signal step : integer range 0 to duration_clk_counts := 0;
  signal is_start : std_logic := '0';
  
  signal stim_start : std_logic;
  
  constant clk_period : time := 1 / clk_frequency;
  constant num_period_to_code_0 : integer := 800 ns / clk_period;
begin

  process(stim_start)
  begin
    if rising_edge(stim_start) then
      if trigger = '1' then
        is_start <= '1';
      else
        is_start <= '0';
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if is_start = '1' then
      
        if step = duration_clk_counts then
          step <= 0;
        else
          step <= step + 1;
        end if;
      end if;
    end if;
  end process;
  
  stim_start <= '1' when (is_start = '0' and trigger = '1') or (trigger = '0' and is_start = '1' and step = 0) else '0';

  sequence <= '1' when ((bit_to_code = '0' and step <= num_period_to_code_0) or (bit_to_code = '1' and step <= code_1_high_duration_clk_counts)) and is_start = '1' else '0';
  
end architecture;
