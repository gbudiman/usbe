-- $Id: $
-- File name:   h2s_tcu.vhd
-- Created:     11/2/2010
-- Author:      Michael Kelton
-- Lab Section: 337-01
-- Version:     1.0  Initial Design Entry
-- Description: The host to slave transmitter control unit.


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;


entity h2s_tcu is
  port( clk   :in std_logic;
        rst   :in std_logic;
        p_ready :in std_logic;
        p_data  :in std_logic_vector(7 downto 0);
        empty   :in std_logic;
        --crc_data:in std_logic_vector(7 downto 0);
        dp1_tx  :out  std_logic;
        dm1_tx  :out  std_logic
        );
  end h2s_tcu;
  
  architecture behavioral of h2s_tcu is
    
    signal present_val : std_logic_vector(7 downto 0); --signals for shiftreg
    signal next_val : std_logic_vector(7 downto 0);
    
    
    begin
      
      
     SHIFTREG: process (clk, rst)
      
      begin  -- process
        if rst = '0' then
           present_val <= "00000000";
        elsif rising_edge(CLK) then
          present_val <= next_val;
        end if;           
      end process;
      
      dp1_tx <= present_val(0);
         
      next_val <= '0' & present_val(7 downto 1);
                      
         --if p_ready = '1' then
           --present_val <= p_data(7 downto 0);
         --end if;
         
         
         
         --need to determine an internal flag for when p_data is ready to send a new byte but the shift register
         --is not ready for it

         --timer

  
         --state machine for tcu

end behavioral;    
