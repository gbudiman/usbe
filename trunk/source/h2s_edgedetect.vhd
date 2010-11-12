-- $Id: $
-- File name:   h2s_edgedetect.vhd
-- Created:     11/4/2010
-- Author:      Brent O'Brien
-- Lab Section: 337-01
-- Version:     1.0  Initial Design Entry
-- Description: .


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

Entity h2s_edgedetect is
  port(
    CLK:in std_logic;
    RST:in std_logic;
    DP1_RX:in std_logic;
    D_EDGE:out std_logic
  );
end h2s_edgedetect;

architecture Behavioral of h2s_edgedetect is
  signal DP_hold1, DP_hold2: std_logic;
  Begin
  holdReg : process(CLK, RST)
    begin
      if (RST = '0') then
        DP_hold1 <= '1';
        DP_hold2 <= '1';
      elsif(CLK'event and CLK = '1') then
        DP_hold1 <= DP1_RX;
        DP_hold2 <= DP_hold1;
      end if;
    end process holdReg;
  
  D_EDGE <= (DP_hold1 XOR DP_hold2) AND (RST);
                                           
end architecture;