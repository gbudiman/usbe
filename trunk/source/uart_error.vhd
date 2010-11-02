------------------------------------------------
-- Purdue University - West Lafayette, IN     --
-- ECE 495d: ASIC design lab                  --
-- Lab 5: UART Receiver unit                  --
------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

ENTITY uart_error IS
PORT (  RST, CLK      : IN std_logic;
        RBUF_FULL     : IN std_logic;
        CHK_ERROR     : IN std_logic;
        OE            : OUT std_logic);
END uart_error;

Architecture behavioral of uart_error IS
  signal OE_prime     : std_logic;

BEGIN

  OE_comb : PROCESS (CHK_ERROR, RBUF_FULL)
  BEGIN
    IF (CHK_ERROR = '1') then
      OE_prime <= RBUF_FULL;
    ELSE
      OE_prime <= '0';
    END IF;

  END PROCESS OE_comb;

  OE_seq : PROCESS (RST, CLK)
  BEGIN
     IF (RST = '1') THEN
         OE <= '0';
     ELSIF (CLK'event and CLK ='1') THEN
         OE <= OE_prime;
     END IF;

  END PROCESS OE_seq;

END behavioral;  



