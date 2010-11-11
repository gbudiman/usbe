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
         BYTE_READY: IN STD_LOGIC;
         KEY_ERROR : IN STD_LOGIC;
         PDATA_READY : OUT STD_LOGIC;
         PROCESSED_DATA : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
  end component;

-- Insert signals Declarations here
  signal KEY : STD_LOGIC_VECTOR(63 DOWNTO 0);
  signal BYTE : STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal BYTE_READY : STD_LOGIC;
  signal CLK : STD_LOGIC;
  signal RST : STD_LOGIC;
  signal KEY_ERROR : STD_LOGIC;
  signal PDATA_READY : STD_LOGIC;
  signal PROCESSED_DATA : STD_LOGIC_VECTOR(7 DOWNTO 0);

-- signal <name> : <type>;

begin
  DUT: KSA port map(
                KEY => KEY,
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
--  BYTE <= x"47";
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
--  
--  BYTE <= x"4C"; 
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

  BYTE <= x"E9";
  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;

  BYTE <= x"6E"; 
  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;

  BYTE <= x"B2";
  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;

  BYTE <= x"C7";
  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;

  BYTE <= x"38";
  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;

  BYTE <= x"03";
  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
  
  wait;
    --KEY <= 
    --CLK <= 
    --RST <= 
    --KEY_ERROR <= 

  end process;
end TEST;