-- $Id: $
-- File name:   tb_tx_timer.vhd
-- Created:     11/21/2010
-- Author:      Michael Kelton
-- Lab Section: 337-01
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_tx_timer is
  generic(period : time := 10.42 ns);
end tb_tx_timer;

architecture TEST of tb_tx_timer is

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

  component tx_timer
    PORT(
         CLK : in std_logic;
         RST : in std_logic;
         SENDING:in std_logic;
         SHIFT_ENABLE_R:out std_logic;
         SHIFT_ENABLE_E:out std_logic
    );
  end component;

-- Insert signals Declarations here
  signal CLK : std_logic;
  signal RST : std_logic;
  signal SENDING: std_logic;
  signal SHIFT_ENABLE_R: std_logic;
  signal SHIFT_ENABLE_E: std_logic;

-- signal <name> : <type>;

begin
  DUT: tx_timer port map(
                CLK => CLK,
                RST => RST,
                SENDING => SENDING,
                SHIFT_ENABLE_R => SHIFT_ENABLE_R,
                SHIFT_ENABLE_E => SHIFT_ENABLE_E
                );

process
  begin
  CLK <= '1';
  wait for period/2;
  CLK <= '0';
  wait for period/2;
end process;

process

  begin

-- Insert TEST BENCH Code Here
    RST <= '1';
    wait for period;
    
    RST <= '0';
    wait for period;
    
    SENDING <= '1';
    wait for period * 65;
    
    SENDING <= '0';
    wait for period * 9;
    wait; 

  end process;
end TEST;