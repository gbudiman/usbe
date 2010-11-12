-- $Id: $
-- File name:   h2s_eopdetect.vhd
-- Created:     11/4/2010
-- Author:      Brent O'Brien
-- Lab Section: 337-01
-- Version:     1.0  Initial Design Entry
-- Description: 


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

Entity h2s_eopdetect is
  port(
    DP1_RX:in std_logic;
    DM1_RX:in std_logic;
    EOP:out std_logic
  );
end h2s_eopdetect;

architecture Behavioral of h2s_eopdetect is
  Begin

EOP <= DP1_RX NOR DM1_RX;
                                           
end architecture;