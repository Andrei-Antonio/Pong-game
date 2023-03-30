----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/18/2022 08:29:57 AM
-- Design Name: 
-- Module Name: driver7segmente - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity driver7segmente is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           din : in STD_LOGIC_VECTOR (15 downto 0);
           dp_in : in STD_LOGIC_VECTOR (3 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           seg : out STD_LOGIC_VECTOR (0 to 6);
           dp_out : out STD_LOGIC);
end driver7segmente;

architecture Behavioral of driver7segmente is

    signal count : integer;
    constant factor_divizare : integer := 100000;
    signal en1KHz : std_logic;
    signal digit_aprins : integer range 0 to 3;
    signal digit_curent : std_logic_vector(3 downto 0);
    
begin

    aprinde : process(clk, rst)
    begin   
        if (rst = '1') then 
            digit_aprins <= 0;
        elsif rising_edge(clk) then 
            if en1KHz = '1' then
                if digit_aprins = 3 then    
                    digit_aprins <= 0;
                else
                    digit_aprins <= digit_aprins + 1;
                end if;
            end if;
        end if;
    end process;
    
    activeaza_anod : process (clk, rst)
    begin   
        if (rst = '1') then
            an <= "1111";
        elsif rising_edge(clk) then
            an <= "1111";
            an(digit_aprins) <= '0';
        end if;
    end process;
    
    dp_out <= dp_in(digit_aprins);
    
    
    digit_curent <= din(digit_aprins*4 + 3  downto digit_aprins*4);

    
    decodare7segmente : process (clk, rst)
    begin
            case digit_curent is
              when "0000" =>  seg <= "0000001"; 
              when "0001" =>  seg <= "1001111"; 
              when "0010" =>  seg <= "0010010"; 
              when "0011" =>  seg <= "0000110"; 
              when "0100" =>  seg <= "1001100"; 
              when "0101" =>  seg <= "0100100"; 
              when "0110" =>  seg <= "0100000"; 
              when "0111" =>  seg <= "0001111";
              when "1000" =>  seg <= "0000000"; 
              when "1001" =>  seg <= "0000100"; 
              when "1010" =>  seg <= "0000010"; 
              when "1011" =>  seg <= "1100000"; 
              when "1100" =>  seg <= "0110001"; 
              when "1101" =>  seg <= "1000010"; 
              when "1110" =>  seg <= "0110000"; 
              when "1111" =>  seg <= "0111000"; 
              when others =>  seg <= "1111111";
            end case;
      end process;        

    div_freq : process (clk,rst)
    begin   
        if (rst = '1') then 
            count <= 0;
            en1KHz <= '0';
        elsif rising_edge(clk) then
            if count = factor_divizare then 
                count <= 0;
                en1KHz <= '1';
            else
                count <= count + 1;
                en1KHz <= '0';
            end if;
        end if;
    end process;
    
    


end Behavioral;
