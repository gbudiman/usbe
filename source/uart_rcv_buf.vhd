------------------------------------------------
-- Purdue University - West Lafayette, IN     --
-- ECE 495d: ASIC design lab                  --
-- Lab 5: UART Receiver unit                  --
------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity uart_rcv_buf is
  Port ( CLK, RST, LOAD_RBUF : in std_logic;
         LOAD_DATA : in std_logic_vector(7 downto 0);
         RCV_DATA : out std_logic_vector(7 downto 0));
end uart_rcv_buf;

architecture Behavioral of uart_rcv_buf is

  signal Q_int : std_logic_vector(7 downto 0);

begin

RCV_DATA <= Q_int;


REGS: process(CLK,RST)
begin

  If RST = '1' then
    Q_int <= "00000000";
  elsif rising_edge(CLK) then
    if LOAD_RBUF = '1' then
      Q_int <= LOAD_DATA;
    end if;
  end if;

end process REGS;

end Behavioral;

