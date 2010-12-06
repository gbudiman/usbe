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
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


entity tx_shiftreg is
  port( clk   :in std_logic;
        rst   :in std_logic;
        SHIFT_ENABLE_R :in std_logic;
        t_bitstuff  :in std_logic;
        t_strobe    :in std_logic;
        send_data  :in std_logic_vector(7 downto 0);
        d_encode  :out  std_logic
        );
  end tx_shiftreg;
  

  ARCHITECTURE dataflow OF tx_shiftreg IS
         signal present_val : std_logic_vector(7 downto 0);
         signal next_val : std_logic_vector(7 downto 0);
         signal count, next_count : std_logic_vector(2 downto 0);
 
  BEGIN
     STOREREG: process (CLK, RST)
     begin  
      if RST = '1' then 
        present_val <= "00000000";
        count <= "111";
      elsif rising_edge(CLK) then
        present_val <= next_val;
        count <= next_count;
      end if;
     end process;
     
     NEXT_VALUE: process (t_strobe, SHIFT_ENABLE_R, t_bitstuff, present_val, send_data)
     
     begin
       next_count <= count;
       if SHIFT_ENABLE_R = '1' then
         if t_bitstuff = '0' then
          next_count <= count + 1;
        end if;
       end if;
       
       if SHIFT_ENABLE_R = '1' AND count = "111" then
         next_val <= send_data;
         next_count <= "000";
       elsif SHIFT_ENABLE_R='1' AND t_bitstuff = '0' then 
         next_val <= '0' & present_val(7 downto 1);
       else next_val <= present_val;
       end if;
    
       d_encode <= present_val(0);
       
    end process NEXT_VALUE;
    
  end dataflow;
  
