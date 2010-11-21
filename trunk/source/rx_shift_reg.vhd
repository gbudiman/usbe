-- $Id: $
-- File name:   rx_shift_reg.vhd
-- Created:     11/11/2010
-- Author:      Brent O'Brien
-- Lab Section: 337-01
-- Version:     1.0  Initial Design Entry
-- Description: receiver portion shift register


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

Entity rx_shift_reg is
  port(
    CLK:in std_logic;
    RST:in std_logic;
    SHIFT_ENABLE: in std_logic;
    D_ORIG: in std_logic;
    BITSTUFF: in std_logic;
    RCV_DATA:out std_logic_vector(7 downto 0)
  );
end rx_shift_reg;

ARCHITECTURE dataflow OF rx_shift_reg IS
       signal present_val : std_logic_vector(7 downto 0);
       signal next_val : std_logic_vector(7 downto 0);
BEGIN
   REG: process (CLK, RST)
   begin  -- process
    if RST = '1' then
      present_val <= "00000000";
    elsif rising_edge(CLK) then
      present_val <= next_val;
    end if; 
   end process;

   next_val <= D_ORIG & present_val(7 downto 1) when (SHIFT_ENABLE='1' AND BITSTUFF = '0')
              else present_val;

   RCV_DATA <= present_val(7 downto 0);

end dataflow;