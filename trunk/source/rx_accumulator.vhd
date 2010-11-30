-- $Id: $
-- File name:   rx_accumulator.vhd
-- Created:     11/30/2010
-- Author:      Brent O'Brien
-- Lab Section: 337-01
-- Version:     1.0  Initial Design Entry
-- Description: Accumulator for checking CRC


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

Entity rx_accumulator is
  port(
    CLK:in std_logic;
    RST:in std_logic;
    RCV_DATA:in std_logic_vector(7 downto 0);
    W_ENABLE:in std_logic;
    rx_CHECK_CRC:out std_logic_vector(15 downto 0)
  );
end rx_accumulator;

architecture Behavioral of rx_accumulator is
  signal present_CHECK_CRC, new_CHECK_CRC : std_logic_vector(15 downto 0);
  Begin
  holdReg : process(CLK, RST)
    begin
      if (RST = '1') then
        present_CHECK_CRC <= x"0000";
      elsif(CLK'event and CLK = '1') then
        present_CHECK_CRC <= new_CHECK_CRC;
      end if;
    end process holdReg;
  
  new_CHECK_CRC <= present_CHECK_CRC(7 downto 0) & RCV_DATA(7 downto 0) when (W_ENABLE = '1')
                  else present_CHECK_CRC;
  rx_CHECK_CRC <= present_CHECK_CRC(15 downto 0);                                        
end architecture;