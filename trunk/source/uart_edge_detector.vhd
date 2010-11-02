------------------------------------------------
-- Purdue University - West Lafayette, IN     --
-- ECE 495d: ASIC design lab                  --
-- Lab 5: UART Receiver unit                  --
------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity uart_edge_detector is
  Port ( CLK, RST, SERIAL_IN : in std_logic;
         START_BIT : out std_logic);
end uart_edge_detector;

architecture Behavioral of uart_edge_detector is

  signal Q_int, Q_int2 : std_logic;

begin

START_BIT <= not(Q_int) and Q_int2;

REGS: process(CLK,RST)
begin

  If RST = '1' then
    Q_int <= '0';
    Q_int2 <= '0';
  elsif rising_edge(CLK) then
    Q_int2 <= Q_int;
    Q_int <= SERIAL_IN;
  end if;

end process;

end Behavioral;

