-- $Id: $
-- File name:   tb_KSA.vhd
-- Created:     11/9/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_KSA is
  generic (Period : Time :=  10.4167 ns);
end tb_KSA;

architecture TEST of tb_KSA is

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

  component KSA
    PORT(
         KEY : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
         CLK : IN STD_LOGIC;
         RST : IN STD_LOGIC;
         BYTE: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
         OPCODE: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
         BYTE_READY: IN STD_LOGIC;
         KEY_ERROR : IN STD_LOGIC;
         PDATA_READY : OUT STD_LOGIC;
         PROCESSED_DATA : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
  end component;

-- Insert signals Declarations here
  signal KEY : STD_LOGIC_VECTOR(63 DOWNTO 0);
  signal OPCODE: STD_LOGIC_VECTOR(1 DOWNTO 0);
  signal BYTE : STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal BYTE_READY : STD_LOGIC;
  signal CLK : STD_LOGIC;
  signal RST : STD_LOGIC;
  signal KEY_ERROR : STD_LOGIC;
  signal PDATA_READY : STD_LOGIC;
  signal PROCESSED_DATA : STD_LOGIC_VECTOR(7 DOWNTO 0);

-- signal <name> : <type>;
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
  DUT: KSA port map(
                KEY => KEY,
                OPCODE => OPCODE,
                BYTE => BYTE,
                BYTE_READY => BYTE_READY,
                CLK => CLK,
                RST => RST,
                KEY_ERROR => KEY_ERROR,
                PDATA_READY => PDATA_READY,
                PROCESSED_DATA => PROCESSED_DATA
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

  KEY <= x"5345435245542121";
  KEY_ERROR <= '0';
  BYTE_READY <= '0';
  RST <= '1';
  wait for 20 ns;
  RST <= '0';
  
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
  report "Next cycle" severity note;
  sendUSB(x"FF", "11", OPCODE, BYTE, BYTE_READY);
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
--  sendUSB(x"FA", BYTE, BYTE_READY); --T
--  sendUSB(x"4A", BYTE, BYTE_READY); --h
--  sendUSB(x"94", BYTE, BYTE_READY); --i
--  sendUSB(x"E6", BYTE, BYTE_READY); --s
--  sendUSB(x"51", BYTE, BYTE_READY); --
--  sendUSB(x"2B", BYTE, BYTE_READY); -- i
--  sendUSB(x"CE", BYTE, BYTE_READY); -- s
--  sendUSB(x"B3", BYTE, BYTE_READY); --
--  sendUSB(x"88", BYTE, BYTE_READY); -- a
--  sendUSB(x"56", BYTE, BYTE_READY); -- w
--  sendUSB(x"17", BYTE, BYTE_READY); -- e
--  sendUSB(x"E4", BYTE, BYTE_READY); -- s
--  sendUSB(x"F3", BYTE, BYTE_READY); -- o
--  sendUSB(x"0E", BYTE, BYTE_READY); -- m
--  sendUSB(x"31", BYTE, BYTE_READY); -- e
--  BYTE <= "T";
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
--  
--  BYTE <= ; 
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
--  
--  BYTE <= x"4F";
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
--  
--  BYTE <= x"52";
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
--  
--  BYTE <= x"49";
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
--  
--  BYTE <= x"41";
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;

  --BYTE <= x"E9";
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
--
--  BYTE <= x"6E"; 
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
--
--  BYTE <= x"B2";
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
--
--  BYTE <= x"C7";
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
--
--  BYTE <= x"38";
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
--
--  BYTE <= x"03";
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
  
  wait;
    --KEY <= 
    --CLK <= 
    --RST <= 
    --KEY_ERROR <= 

  end process;
end TEST;