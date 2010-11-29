-- $Id: $
-- File name:   tb_edblock.vhd
-- Created:     11/27/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_edblock is
  generic (Period : Time :=  10.4167 ns);
end tb_edblock;

architecture TEST of tb_edblock is

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

  component edblock
    PORT(
         BYTE : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
         BYTE_READY : IN STD_LOGIC;
         CLK : IN std_logic;
         OPCODE : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
         RST : IN std_logic;
         SERIAL_IN : IN std_logic;
         KEY_ERROR : OUT std_logic;
         PDATA_READY : OUT STD_LOGIC;
         PROCESSED_DATA : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
         PROG_ERROR : OUT std_logic;
         RBUF_FULL : OUT std_logic
    );
  end component;

-- Insert signals Declarations here
  signal BYTE : STD_LOGIC_VECTOR (7 DOWNTO 0);
  signal BYTE_READY : STD_LOGIC;
  signal CLK : std_logic;
  signal OPCODE : STD_LOGIC_VECTOR (1 DOWNTO 0);
  signal RST : std_logic;
  signal SERIAL_IN : std_logic;
  signal KEY_ERROR : std_logic;
  signal PDATA_READY : STD_LOGIC;
  signal PROCESSED_DATA : STD_LOGIC_VECTOR (7 DOWNTO 0);
  signal PROG_ERROR : std_logic;
  signal RBUF_FULL : std_logic;

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

PROCEDURE sendUSB (
  constant ASCII: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  constant OC: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
  signal OPCODE: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  signal BYTE: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal BYTE_READY: OUT STD_LOGIC ) IS
BEGIN
  BYTE <= ASCII;
  OPCODE <= OC;
  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 8 * period;
END sendUSB;

begin
  DUT: edblock port map(
                BYTE => BYTE,
                BYTE_READY => BYTE_READY,
                CLK => CLK,
                OPCODE => OPCODE,
                RST => RST,
                SERIAL_IN => SERIAL_IN,
                KEY_ERROR => KEY_ERROR,
                PDATA_READY => PDATA_READY,
                PROCESSED_DATA => PROCESSED_DATA,
                PROG_ERROR => PROG_ERROR,
                RBUF_FULL => RBUF_FULL
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
  serial_in <= '1';
  rst <= '1';
  wait for 5 ns;
  rst <= '0';
  wait for 37 ns;
  BYTE_READY <= '1';
  OPCODE <= "10";
  
  sendUART(x"21", serial_in); -- !
  sendUART(x"21", serial_in); -- !
  sendUART(x"54", serial_in); -- T
  sendUART(x"45", serial_in); -- E
  sendUART(x"52", serial_in); -- R
  sendUART(x"43", serial_in); -- C
  sendUART(x"45", serial_in); -- E
  sendUART(x"53", serial_in); -- S
  wait for 12 us;
  sendUSB(x"FF", "00", OPCODE, BYTE, BYTE_READY); --PID?
  sendUSB(x"54", "01", OPCODE, BYTE, BYTE_READY); --T
  sendUSB(x"68", "01", OPCODE, BYTE, BYTE_READY); --h
  sendUSB(x"69", "01", OPCODE, BYTE, BYTE_READY); --i
  sendUSB(x"73", "01", OPCODE, BYTE, BYTE_READY); --s
  sendUSB(x"20", "01", OPCODE, BYTE, BYTE_READY); --
  sendUSB(x"69", "01", OPCODE, BYTE, BYTE_READY); -- i
  sendUSB(x"73", "01", OPCODE, BYTE, BYTE_READY); -- s
  sendUSB(x"20", "01", OPCODE, BYTE, BYTE_READY); --
  sendUSB(x"61", "01", OPCODE, BYTE, BYTE_READY); -- a
  sendUSB(x"77", "01", OPCODE, BYTE, BYTE_READY); -- w
  sendUSB(x"65", "01", OPCODE, BYTE, BYTE_READY); -- e
  sendUSB(x"73", "01", OPCODE, BYTE, BYTE_READY); -- s
  sendUSB(x"6f", "01", OPCODE, BYTE, BYTE_READY); -- o
  sendUSB(x"6d", "01", OPCODE, BYTE, BYTE_READY); -- m
  sendUSB(x"65", "01", OPCODE, BYTE, BYTE_READY); -- e
  sendUSB(x"FF", "11", OPCODE, BYTE, BYTE_READY);
  wait;
    --BYTE <= 
--    BYTE_READY <= 
--    CLK <= 
--    OPCODE <= 
--    RST <= 
--    SERIAL_IN <= 

  end process;
end TEST;