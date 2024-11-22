library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity NRZ_sequence_tb is
end entity;

architecture testbench of NRZ_sequence_tb is
	signal clk : std_logic;
	signal trigger : std_logic;
	signal finished : std_logic;
	signal bit_to_code : std_logic;
	signal sequence : std_logic;
begin
	UUT: entity work.NRZ_sequence
		generic map(
			duration_clk_counts => 5,
			code_0_high_duration_clk_counts => 1,
			code_1_high_duration_clk_counts => 3
		)
		port map(
			clk => clk,
			trigger => trigger,
			finished => finished,
			bit_to_code => bit_to_code,
			sequence => sequence
		);
		
	process
	begin
		clk <= '1'; wait for 20 ns;
		clk <= '0'; wait for 20 ns;
	end process;
	
	process
	begin
	
		bit_to_code <= '0';
		wait for 50 ns; trigger <= '1';
		wait for 5 ns; trigger <= '0';
		
--		wait for 30 ns;
--		bit_to_code <= '1';
--		wait for 50 ns; trigger <= '1';
--		wait for 5 ns; trigger <= '0';
		
		wait;
	end process;

end architecture;