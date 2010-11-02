------------------------------------------------
-- Purdue University - West Lafayette, IN     --
-- ECE 495d: ASIC design lab                  --
-- Lab 5: UART Receiver unit                  --
------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_sb_check is
  
  port (
    RST, CLK  : in  std_logic;
    SBC_CLR   : in  std_logic;
    SBC_EN    : in  std_logic;
    STOP_DATA : in  std_logic_vector(1 downto 0);
    SB_DETECT : out std_logic;
    SBE       : out std_logic);

end uart_sb_check;

architecture behavioral of uart_sb_check is

signal SBE_prime : std_logic;
signal sb_detect_flag : std_logic;

begin  -- behavioral

  SBE_comb: process (SBC_CLR, SBC_EN, STOP_DATA)
  begin  -- process SBE_comb
    if (SBC_CLR = '1') then
      SBE_prime <= '0';
      sb_detect_flag <= '0';
    elsif (SBC_EN = '1') then
      if (STOP_DATA = "10") then
        SBE_prime <= '0';
        sb_detect_flag <= '1';
      else
        SBE_prime <= '1';
        sb_detect_flag <= '0';
      end if;
    else
      SBE_prime <= '0';
      sb_detect_flag <= '0';
    end if;
  end process SBE_comb;

  SBE_seq: process (CLK, RST)
  begin  -- process SBE_seq
    if (RST = '1') then
      SBE <= '0';
      sb_detect <= '0';
    elsif (CLK'event and CLK = '1') then
      SBE <= SBE_prime;
      sb_detect <= sb_detect_flag;
    end if;
  end process SBE_seq;
end behavioral;

