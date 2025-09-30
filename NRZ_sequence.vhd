library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity NRZ_sequence is
  generic (
    DURATION_CLK_COUNTS : integer;
    CODE_0_HIGH_DURATION_CLK_COUNTS : integer;
    CODE_1_HIGH_DURATION_CLK_COUNTS : integer
  );
  
  port (
    clk : in std_logic;
    trigger : in std_logic;
    finished : in std_logic;
    bit_to_code : in std_logic;
    seq : out std_logic := '0'
  );

end entity;

architecture behavior of NRZ_sequence is
  signal step : integer range 0 to DURATION_CLK_COUNTS := 0;
  signal is_start : std_logic := '0';
  
  signal stim_start : std_logic;
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
      
        if step = DURATION_CLK_COUNTS then
          step <= 0;
        else
          step <= step + 1;
        end if;
      end if;
    end if;
  end process;
  
  stim_start <= '1' when (is_start = '0' and trigger = '1') or (trigger = '0' and is_start = '1' and step = 0) else '0';

  seq <= '1' when ((bit_to_code = '0' and step <= CODE_0_HIGH_DURATION_CLK_COUNTS) or (bit_to_code = '1' and step <= CODE_1_HIGH_DURATION_CLK_COUNTS)) and is_start = '1' else '0';
  
end architecture;
