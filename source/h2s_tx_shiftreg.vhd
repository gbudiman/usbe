-- $Id: $
-- File name:   tx_shiftreg.vhd
-- Created:     11/7/2010
-- Author:      Michael Kelton
-- Lab Section: 337-01
-- Version:     1.0  Initial Design Entry
-- Description: This is the shift register for the tcu.
--  


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity tx_shiftreg is
  port( clk   :in std_logic;
        rst   :in std_logic;
        p_ready :in std_logic;
        p_data  :in std_logic_vector(7 downto 0);
        --crc_data:in std_logic_vector(7 downto 0);
        dp1_tx  :out  std_logic;
        dm1_tx  :out  std_logic
        );
  end tx_shiftreg;
  
  architecture behavioral of tx_shiftreg is
    
    signal present_val : std_logic_vector(7 downto 0); --signals for shiftreg
    signal next_val : std_logic_vector(7 downto 0);
    

    begin
 
     SHIFTREG: process (clk, rst)
      
      begin  -- process
        if rst = '0' then
           present_val <= "00000000";
        elsif rising_edge(CLK) then
          if p_ready = '1' then
            present_val <= p_data(7 downto 0);
          else
            present_val <= next_val;
        end if;           
      end process;
      
      dp1_tx <= present_val(0);
      
      dm1_tx <= not present_val(0);

      next_val <= '0' & present_val(7 downto 1);


end behavioral;  