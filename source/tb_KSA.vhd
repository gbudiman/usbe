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
         KEY_ERROR : IN STD_LOGIC;
         TABLE_READY : OUT STD_LOGIC;
         OUT_TABLE : OUT STD_LOGIC_VECTOR(2047 DOWNTO 0)
    );
  end component;

-- Insert signals Declarations here
  signal KEY : STD_LOGIC_VECTOR(63 DOWNTO 0);
  signal CLK : STD_LOGIC;
  signal RST : STD_LOGIC;
  signal KEY_ERROR : STD_LOGIC;
  signal TABLE_READY : STD_LOGIC;
  signal OUT_TABLE : STD_LOGIC_VECTOR(2047 DOWNTO 0);

-- signal <name> : <type>;

begin
  DUT: KSA port map(
                KEY => KEY,
                CLK => CLK,
                RST => RST,
                KEY_ERROR => KEY_ERROR,
                TABLE_READY => TABLE_READY,
                OUT_TABLE => OUT_TABLE
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
  RST <= '1';
  wait for 20 ns;
  RST <= '0';
  
  wait;
    --KEY <= 
    --CLK <= 
    --RST <= 
    --KEY_ERROR <= 

  end process;
end TEST;