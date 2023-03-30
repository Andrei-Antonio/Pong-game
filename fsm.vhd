library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity fsm is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           btnL : in std_logic_vector (2 downto 0);
           btnR : in std_logic_vector (2 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out std_logic_vector (3 downto 0);
           seg : out std_logic_vector (0 to 6);
           dp : out std_logic
           );
end fsm;

architecture Behavioral of fsm is

signal countForLeds : std_logic_vector (3 downto 0) := (others => '0');
    
type states is (idle, start, serva, prins, failed1, failed2);
signal score_counter1 : integer; 
signal score_counter2 : integer;
signal current_state, next_state : states;
    
signal i : integer range 0 to 15;    
signal rnd : STD_LOGIC_VECTOR (3 downto 0);

signal score : STD_LOGIC_VECTOR (15 downto 0);

component driver7seg is
    Port ( clk : in STD_LOGIC; --100MHz board clock input
           Din : in STD_LOGIC_VECTOR (15 downto 0); --16 bit binary data for 4 displays
           an : out STD_LOGIC_VECTOR (3 downto 0); --anode outputs selecting individual displays 3 to 0
           seg : out STD_LOGIC_VECTOR (0 to 6); -- cathode outputs for selecting LED-s in each display
           dp_in : in STD_LOGIC_VECTOR (3 downto 0); --decimal point input values
           dp_out : out STD_LOGIC; --selected decimal point sent to cathodes
           rst : in STD_LOGIC); --global reset
end component driver7seg;

begin

u : driver7seg port map (clk => clk,
                         Din => score,
                         an => an,
                         seg => seg,
                         dp_in => "0000",
                         dp_out => dp,
                         rst => rst);


process (clk, rst)
begin
  if rst = '1' then
    current_state <= start;
  elsif rising_edge(clk) then
    current_state <= next_state;
  end if;    
end process;

        
process (current_state, i)
begin
  case current_state is
    when idle => if btnL(i) = '1' then
                       next_state <= start;
                 else 
                       next_state <= idle;
                 end if; 
                 
    when start => if btnL(i) = '1' then
                       next_state <= serva;
                 else 
                       next_state <= start;
                 end if;  
                                   
  when serva => if btnR(i) = '1' then
                       next_state <= prins;
                 else 
                       next_state <= failed1;
                 end if; 
                 
  when prins => if btnL(i) = '1' then
                       next_state <= serva;
                 else 
                       next_state <= failed2;
                 end if;               
  when failed1 => score_counter1 <= score_counter1 + 1;
  when failed2 => score_counter2 <= score_counter2 + 1;

  end case;                                            
end process;


process (clk, countForLeds)
begin
    if rising_edge(clk) and clk = '1' then
        countForLeds <= countForLeds + 1;
    end if;   

case countForLeds is 
when "0000" => led(15 downto 0)<="1000000000000000";
when "0001" =>led(15 downto 0)<="0100000000000000";
when "0010" =>led(15 downto 0)<="0010000000000000";
when "0011" =>led(15 downto 0)<="0001000000000000";
when "0100" =>led(15 downto 0)<="0000100000000000";
when "0101" =>led(15 downto 0)<="0000010000000000";
when "0110" =>led(15 downto 0)<="0000001000000000";
when "0111" =>led(15 downto 0)<="0000000100000000";
when "1000" =>led(15 downto 0)<="0000000010000000";
when "1001" =>led(15 downto 0)<="0000000001000000";
when "1010" =>led(15 downto 0)<="0000000000100000";
when "1011" =>led(15 downto 0)<="0000000000010000";
when "1100" =>led(15 downto 0)<="0000000000001000";
when "1101" =>led(15 downto 0)<="0000000000000100";
when "1110" =>led(15 downto 0)<="0000000000000010";
when others =>led(15 downto 0)<="0000000000000001";

end case;
end process;
    
-- SSD display       
generate_scor: process (clk, rst)
  variable zeci1, unitati1, zeci2, unitati2: integer range 0 to 9 := 0;
begin
  if rst = '1' then
    score <= (others => '0');
    zeci1:= 0;
    unitati1 := 0;
    zeci2 := 0;
    unitati2 := 0;
  elsif rising_edge(clk) then
    if current_state = failed1 then
      if unitati2 = 9 then
        unitati2 := 0;
        if zeci2 = 9 then
          zeci2 := 0;
             else
              zeci2 := zeci2+1;
            end if;
          else
            unitati2 := unitati2+1;
          end if;
          if current_state = failed2 then
         if unitati1 = 9 then
        unitati1 := 0;
        if zeci1 = 9 then
          zeci1 := 0;
             else
              zeci1 := zeci1+1;
            end if;
          else
            unitati1 := unitati1+1;
          end if;
    
    score <= std_logic_vector(to_unsigned(zeci2,4)) &
             std_logic_vector(to_unsigned(unitati2,4)) &
             std_logic_vector(to_unsigned(zeci1,4)) &
             std_logic_vector(to_unsigned(unitati1,4));
    end if;
  end if;
 end if;
end process;     
     
end Behavioral;