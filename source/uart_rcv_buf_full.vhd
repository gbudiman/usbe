------------------------------------------------
-- Purdue University - West Lafayette, IN     --
-- ECE 495d: ASIC design lab                  --
-- Lab 5: UART Receiver unit                  --
------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity uart_rcv_buf_full is
  Port ( CLK, RST, CLR_RBUF, SET_RBUF_FULL : in std_logic;
         RBUF_FULL : out std_logic);
end uart_rcv_buf_full;

architecture Behavioral of uart_rcv_buf_full is

  signal Q_int,Q_next : std_logic;

begin

RBUF_FULL <= Q_int;

REGS: process(CLK,RST,CLR_RBUF)
begin

  If RST = '1' then
    Q_int <= '0';
  elsif CLR_RBUF = '1' then  -- CLR_RBUF is an external asynchronous reset
    Q_int <= '0';
  elsif rising_edge(CLK) then
    Q_int <= Q_next;
  end if;

end process REGS;

Q_next <= '1' when SET_RBUF_FULL = '1' else
	Q_int; 

end Behavioral;

