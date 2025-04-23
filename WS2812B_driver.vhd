library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WS2812B_driver is
  generic (
    max_pos : integer := 16
  );
  
  port (
    clk : in std_logic;
    enable : in std_logic;
    leds_line : out std_logic := '0';
    
    update_frame : in std_logic;
    
    program_led_number : buffer integer range 0 to max_pos-1;
    program_red_intensity : in std_logic_vector(7 downto 0);
    program_blue_intensity : in std_logic_vector(7 downto 0);
    program_green_intensity : in std_logic_vector(7 downto 0)
  );
end entity;

architecture beh of WS2812B_driver is
  constant step_max : integer := 62;
  constant bit_proceed_max : integer := 23;

  signal step : integer range 0 to step_max;
  signal bit_proceed : integer range 0 to bit_proceed_max;
  signal reset_step : integer range 0 to 2600;

  constant WaitTrigger : std_logic_vector(1 downto 0) := "00";
  constant SendLEDsData : std_logic_vector(1 downto 0) := "01";
  constant ValidateSeq : std_logic_vector(1 downto 0) := "10";
  constant WaitTriggerRelease : std_logic_vector(1 downto 0) := "11";
  
  signal stage : std_logic_vector(1 downto 0) := WaitTrigger;
  
  signal seq_trigger : std_logic;
  signal seq_finished : std_logic;
  signal seq_bit_to_code : std_logic;
  
  constant HIGH_DURATION_FOR_CODE_1 : integer := 39;
  constant HIGH_DURATION_FOR_CODE_0 : integer := 19;
  
  function serial_state_led_line_for_color (
    step : integer range 0 to step_max;
    bit_proceed : integer range 0 to bit_proceed_max;
    
    green: integer range 0 to 255;
    red: integer range 0 to 255;
    blue: integer range 0 to 255
  ) return std_logic is
    variable data :  std_logic_vector(0 to bit_proceed_max);
  begin
    data := std_logic_vector( to_unsigned( green, 8)) & std_logic_vector( to_unsigned( red, 8)) & std_logic_vector( to_unsigned( blue, 8));
  
    if data(bit_proceed) = '0' and step <= HIGH_DURATION_FOR_CODE_0 then
      return '1';
    elsif data(bit_proceed) = '1' and step <= HIGH_DURATION_FOR_CODE_1 then
      return '1';
    else
      return '0';
    end if;
  end function;
begin
  NRZ_sequence : entity work.NRZ_sequence
    generic map(
      duration_clk_counts => 62,
      code_1_high_duration_clk_counts => 39,
      code_0_high_duration_clk_counts => 19
    )
    port map (
      clk => clk,
      trigger => seq_trigger,
      finished => seq_finished,
      bit_to_code => seq_bit_to_code,
      seq => leds_line
    );

  process(clk)
    variable data :  std_logic_vector(0 to bit_proceed_max);
  begin
  
    data := program_green_intensity & program_red_intensity & program_blue_intensity;
  
    if rising_edge(clk) then
      case stage is
        when WaitTrigger =>
          if enable = '1' or update_frame = '1' then
            seq_trigger <= '1';
            seq_bit_to_code <= data(bit_proceed);
            stage <= SendLEDsData;
          else
            seq_trigger <= '0';
          end if;   
        when SendLEDsData =>
          if seq_trigger = '1' then 
            seq_trigger <= '0';
          end if;
          
          if step = step_max then
            step <= 0;
            
            if bit_proceed = bit_proceed_max then
              bit_proceed <= 0;
              
              if program_led_number = max_pos-1 then
                program_led_number <= 0;
                
                stage <= ValidateSeq;
              else
                program_led_number <= program_led_number + 1;
                
                seq_bit_to_code <= data(0);
                seq_trigger <= '1';
              end if;
            else
              seq_trigger <= '1';

              bit_proceed <= bit_proceed + 1;
              seq_bit_to_code <= data(bit_proceed + 1);
            end if;
          else
            step <= step + 1;
          end if;
        
        when ValidateSeq =>
          if reset_step = 2600 then
            stage <= WaitTriggerRelease;
            seq_trigger <= '0';
            reset_step <= 0;
          else
            reset_step <= reset_step + 1;
          end if;

        when WaitTriggerRelease =>
          if update_frame = '0' and enable = '0' then
            stage <= WaitTrigger;
          end if;
          
        when others =>
          -- nothing todo

      end case;
    end if;

  end process;

end architecture;
