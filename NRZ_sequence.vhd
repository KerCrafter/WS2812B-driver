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
    bit_to_code : in std_logic;
    seq : out std_logic := '0'
  );

end entity;

architecture behavior of NRZ_sequence is
  signal step : integer range 0 to DURATION_CLK_COUNTS := 0;
begin

  process(clk)
  begin
    if rising_edge(clk) then
      if trigger = '1' then
        step <= 0;
      end if;

      if step /= DURATION_CLK_COUNTS then
        step <= step + 1;
      end if;
    end if;
  end process;
  
  seq <= '1' when ((bit_to_code = '0' and step <= CODE_0_HIGH_DURATION_CLK_COUNTS) or (bit_to_code = '1' and step <= CODE_1_HIGH_DURATION_CLK_COUNTS)) else '0';
  
end architecture;
