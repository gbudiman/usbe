-- $Id: $
-- File name:   tb_rmed.vhd
-- Created:     11/30/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_rmed is
  generic (Period : Time :=  10.4167 ns);
end tb_rmed;

architecture TEST of tb_rmed is

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

  component rmed
    PORT(
         CLK : IN std_logic;
         DM1_RX : IN std_logic;
         DP1_RX : IN std_logic;
         NEXT_BYTE : IN STD_LOGIC;
         RST : IN std_logic;
         SERIAL_IN : IN std_logic;
         CRC_ERROR : OUT std_logic;
         EMPTY : OUT STD_LOGIC;
         FULL : OUT STD_LOGIC;
         KEY_ERROR : OUT std_logic;
         PDATA_READY : OUT STD_LOGIC;
         PRGA_OPCODE : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
         PROCESSED_DATA : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
         PROG_ERROR : OUT std_logic;
         PARITY_ERROR : OUT std_logic;
         RBUF_FULL : OUT std_logic;
         R_ERROR : OUT std_logic
    );
  end component;

-- Insert signals Declarations here
  signal CLK : std_logic;
  signal DM1_RX : std_logic;
  signal DP1_RX : std_logic;
  signal NEXT_BYTE : STD_LOGIC;
  signal RST : std_logic;
  signal SERIAL_IN : std_logic;
  signal CRC_ERROR : std_logic;
  signal EMPTY : STD_LOGIC;
  signal FULL : STD_LOGIC;
  signal KEY_ERROR : std_logic;
  signal PDATA_READY : STD_LOGIC;
  signal PRGA_OPCODE : STD_LOGIC_VECTOR (1 DOWNTO 0);
  signal PROCESSED_DATA : STD_LOGIC_VECTOR (7 DOWNTO 0);
  signal PROG_ERROR : std_logic;
  signal PARITY_ERROR : std_logic;
  signal RBUF_FULL : std_logic;
  signal R_ERROR : std_logic;

-- signal <name> : <type>;
procedure sendUART(
  constant data_in: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal serial_in: OUT STD_LOGIC) is
begin
  serial_in <= '0';
  report "Start" severity note;
  wait for 10 * period;
  for i in 0 to 7 loop
    serial_in <= data_in(i);
    wait for 10 * period;
  end loop;
  report "End" severity note;
  serial_in <= '0';
  wait for 10 * period;
  serial_in <= '1';
  wait for 30 * period;
end sendUART;

procedure sendByteFast (
    constant data : in std_logic_vector(7 downto 0);
    signal d_plus: OUT STD_LOGIC;
    signal d_minus: OUT STD_LOGIC) is
begin
    for i in 7 downto 0 loop
        D_PLUS <= data(i);
        D_MINUS <= NOT data(i);
        wait for period * 8;
    end loop;
end sendByteFast;

procedure HEXtoNRZI (
  constant data : in std_logic_vector(7 downto 0);
  signal D    : inout std_logic; 
  signal D_MIN: out std_logic) is
begin
  for i in 0 to 7 loop
    if (data(i) = '0') then
      D <= not(D);
      D_MIN <= D;
    else
      D <= D;
      D_MIN <= not(D);
    end if;
    wait for 8*Period;
  end loop;
end HEXtoNRZI;

procedure sendEOP (
    constant repeat: IN integer;
    signal d_plus: OUT STD_LOGIC;
    signal d_minus: OUT STD_LOGIC) is
begin
  for i in 0 to repeat loop
    d_plus <= '0';
    d_minus <= '0';
    wait for 8 * period;
  end loop;
  d_plus <= '1';
  d_minus <= '0';
  wait for 8 * period;
end sendEOP;

PROCEDURE cycleNB(
  SIGNAL B_READY: IN STD_LOGIC;
  SIGNAL NEXT_BYTE: OUT STD_LOGIC) IS
BEGIN
  NEXT_BYTE <= '0';
  report "waiting" severity note;
  if empty = '0' then
    wait until B_READY = '1';
  end if;
  NEXT_BYTE <= '1';
  wait for 25 * period;
END cycleNB;

begin
  DUT: rmed port map(
                CLK => CLK,
                DM1_RX => DM1_RX,
                DP1_RX => DP1_RX,
                NEXT_BYTE => NEXT_BYTE,
                RST => RST,
                SERIAL_IN => SERIAL_IN,
                CRC_ERROR => CRC_ERROR,
                EMPTY => EMPTY,
                FULL => FULL,
                KEY_ERROR => KEY_ERROR,
                PDATA_READY => PDATA_READY,
                PRGA_OPCODE => PRGA_OPCODE,
                PROCESSED_DATA => PROCESSED_DATA,
                PROG_ERROR => PROG_ERROR,
                PARITY_ERROR => PARITY_ERROR,
                RBUF_FULL => RBUF_FULL,
                R_ERROR => R_ERROR
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
  RST <= '1';
  wait for 25 ns;
  SERIAL_IN <= '1';
  NEXT_BYTE <= '1';
  DM1_RX <= '1';
  DP1_RX <= '1';
  RST <= '0';
  wait for 25 ns;
  
  sendUART(x"21", serial_in); -- !
  sendUART(x"21", serial_in); -- !
  sendUART(x"54", serial_in); -- T
  sendUART(x"45", serial_in); -- E
  sendUART(x"52", serial_in); -- R
  sendUART(x"43", serial_in); -- C
  sendUART(x"45", serial_in); -- E
  sendUART(x"53", serial_in); -- S
  sendUART("10101100", serial_in); -- parity
  wait for 8 us;
  report "Begin normal operation" severity note;
--  sendByteFast("01010100", DP1_RX, DM1_RX);
--  sendByteFast(x"76", DP1_RX, DM1_RX);
--  sendByteFast(x"77", DP1_RX, DM1_RX);
--  sendByteFast(x"78", DP1_RX, DM1_RX);
--  sendByteFast(x"79", DP1_RX, DM1_RX);
--  sendByteFast(x"72", DP1_RX, DM1_RX);
  HEXtoNRZI("10000000", DP1_RX, DM1_RX);
  HEXtoNRZI(x"74", DP1_RX, DM1_RX);
  HEXtoNRZI(x"30", DP1_RX, DM1_RX);
  HEXtoNRZI(x"31", DP1_RX, DM1_RX);
  HEXtoNRZI(x"32", DP1_RX, DM1_RX);
  HEXtoNRZI(x"33", DP1_RX, DM1_RX);
  HEXtoNRZI(x"6F", DP1_RX, DM1_RX);
  HEXtoNRZI(x"74", DP1_RX, DM1_RX);
  sendEOP(1, DP1_RX, DM1_RX);
  cycleNB(PDATA_READY, NEXT_BYTE);
  cycleNB(PDATA_READY, NEXT_BYTE);
  cycleNB(PDATA_READY, NEXT_BYTE);
  cycleNB(PDATA_READY, NEXT_BYTE);
  wait;
    --CLK <= 
--    DM1_RX <= 
--    DP1_RX <=
--    NEXT_BYTE <= 
--    RST <= 
--    SERIAL_IN <= 

  end process;
end TEST;