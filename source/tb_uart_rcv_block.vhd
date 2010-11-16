-- $Id: $
-- File name:   tb_uart_rcv_block.vhd
-- Created:     11/1/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_uart_rcv_block is
  generic (Period : Time :=  10.4167 ns;
    DataPeriod: Time := 83.33 ns);
end tb_uart_rcv_block;

architecture TEST of tb_uart_rcv_block is

  function INT_TO_STD_LOGIC( X: INTEGER; NumBits: INTEGER )
     return STD_LOGIC_VECTOR is
    variable RES : STD_LOGIC_VECTOR(NumBits-1 downto 0);
    variable tmp : INTEGER;
  begin
    tmp := X;
    for i in 0 to NumBits-1 loop
      if (tmp mod 2)=1 then
        res(i) := '1';
      else
        res(i) := '0';
      end if;
      tmp := tmp/2;
    end loop;
    return res;
  end;

  component uart_rcv_block
    PORT(
         CLK : IN std_logic;
         --CLR_RBUF : IN std_logic;
         RST : IN std_logic;
         SERIAL_IN : IN std_logic;
         --OE : OUT std_logic;
         RBUF_FULL : OUT std_logic;
         --RCV_DATA : OUT std_logic_vector (7 DOWNTO 0);
         --SBE : OUT std_logic;
         KEY_ERROR: OUT std_logic;
         PROG_ERROR: OUT std_logic;
         PLAINKEY: OUT std_logic_vector (63 DOWNTO 0)
    );
  end component;

-- Insert signals Declarations here
  signal CLK : std_logic;
  --signal CLR_RBUF : std_logic;
  signal RST : std_logic;
  signal SERIAL_IN : std_logic;
  --signal OE : std_logic;
  signal RBUF_FULL : std_logic;
  --signal RCV_DATA : std_logic_vector (7 DOWNTO 0);
  --signal SBE : std_logic;
  signal KEY_ERROR: std_logic;
  signal PROG_ERROR: std_logic;
  signal PLAINKEY: std_logic_vector (63 DOWNTO 0);

-- signal <name> : <type>;
procedure sendUART(
  constant data_in: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal serial_in: OUT STD_LOGIC) is
begin
  serial_in <= '0';
  wait for 10 * period;
  for i in 0 to 7 loop
    serial_in <= data_in(i);
    wait for 10 * period;
  end loop;
  serial_in <= '0';
  wait for 10 * period;
  serial_in <= '1';
  wait for 30 * period;
end sendUART;

begin
  DUT: uart_rcv_block port map(
                CLK => CLK,
                --CLR_RBUF => CLR_RBUF,
                RST => RST,
                SERIAL_IN => SERIAL_IN,
                --OE => OE,
                RBUF_FULL => RBUF_FULL,
                --RCV_DATA => RCV_DATA,
                --SBE => SBE
                KEY_ERROR => KEY_ERROR,
                PROG_ERROR => PROG_ERROR,
                PLAINKEY => PLAINKEY
                );

--   GOLD: <GOLD_NAME> port map(<put mappings here>);

autoClock: process
  BEGIN
    clk <= '0';
    wait for period/2;
    clk <= '1';
    wait for period/2;
  END process autoClock;
  
process

  begin

-- Insert TEST BENCH Code Here

    --CLR_RBUF <= 
    --RST <= 
    --SERIAL_IN <= 
    --clr_rbuf <= '0';
    serial_in <= '1';
    rst <= '1';
    wait for 5 ns;
    rst <= '0';
    wait for dataperiod;
    sendUART(x"21", serial_in); -- !
    sendUART(x"22", serial_in); -- !
    sendUART(x"54", serial_in); -- T
    sendUART(x"45", serial_in); -- E
    sendUART(x"52", serial_in); -- R
    sendUART(x"43", serial_in); -- C
    sendUART(x"45", serial_in); -- E
    sendUART(x"53", serial_in); -- S
    sendUART(x"26", serial_in); -- &
    sendUART(x"26", serial_in); -- &
    sendUART(x"64", serial_in); -- d
    sendUART(x"45", serial_in); -- E
    sendUART(x"6e", serial_in); -- n
    sendUART(x"77", serial_in); -- w
    sendUART(x"61", serial_in); -- a
    sendUART(x"70", serial_in); -- p
    wait;
  end process;
end TEST;