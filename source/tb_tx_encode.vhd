-- $Id: $
-- File name:   tb_tx_encode.vhd
-- Created:     11/20/2010
-- Author:      Michael Kelton
-- Lab Section: 337-01
-- Version:     1.0  Initial Test Bench
library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_tx_encode is
  generic(period : time := 10.42 ns);
end tb_tx_encode;

architecture TEST of tb_tx_encode is

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

  component tx_encode
    PORT(
         clk : in std_logic;
         rst : in std_logic;
         SHIFT_ENABLE_E : in std_logic;
         d_encode : in std_logic;
         EOP : in std_logic;
         t_bitstuff : out std_logic;
         dp_tx_out : out std_logic;
         dm_tx_out : out std_logic
    );
  end component;

-- Insert signals Declarations here
  signal clk : std_logic;
  signal rst : std_logic;
  signal SHIFT_ENABLE_E : std_logic;
  signal d_encode : std_logic;
  signal EOP : std_logic;
  signal t_bitstuff : std_logic;
  signal dp_tx_out : std_logic;
  signal dm_tx_out : std_logic;

-- signal <name> : <type>;

begin
  DUT: tx_encode port map(
                clk => clk,
                rst => rst,
                SHIFT_ENABLE_E => SHIFT_ENABLE_E,
                d_encode => d_encode,
                EOP => EOP,
                t_bitstuff => t_bitstuff,
                dp_tx_out => dp_tx_out,
                dm_tx_out => dm_tx_out
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

    rst <= '0';
    EOP <= '0';
    SHIFT_ENABLE_E <= '0';
    wait for 5 ns;
    wait for period;
    rst <= '1';
    wait for period;
    
    rst <= '0';
    d_encode <= '1';
    SHIFT_ENABLE_E <= '1';
    wait for period;
    SHIFT_ENABLE_E <= '0';
    wait for period * 7;
    d_encode <= '1';
    SHIFT_ENABLE_E <= '1';
    wait for period;
    SHIFT_ENABLE_E <= '0';
    wait for period * 7;
    d_encode <= '1';
    SHIFT_ENABLE_E <= '1';
    wait for period;
    SHIFT_ENABLE_E <= '0';
    wait for period * 7;
    d_encode <= '1';
    SHIFT_ENABLE_E <= '1';
    wait for period;
    SHIFT_ENABLE_E <= '0';
    wait for period * 7;
    d_encode <= '1';
    SHIFT_ENABLE_E <= '1';
    wait for period;
    SHIFT_ENABLE_E <= '0';
    wait for period * 7;
    d_encode <= '1';
    SHIFT_ENABLE_E <= '1';
    wait for period;
    SHIFT_ENABLE_E <= '0';
    wait for period * 7;
    d_encode <= '0';
    SHIFT_ENABLE_E <= '1';
    wait for period;
    SHIFT_ENABLE_E <= '0';
    wait for period * 7;
    d_encode <= '0';
    SHIFT_ENABLE_E <= '1';
    wait for period;
    SHIFT_ENABLE_E <= '0';
    wait for period * 7;
    d_encode <= '1';
    SHIFT_ENABLE_E <= '1';
    wait for period;
    SHIFT_ENABLE_E <= '0';
    
    wait for period*7;
    
    -------------------------
    
    d_encode <= '1';
    SHIFT_ENABLE_E <= '1';
    wait for period;
    SHIFT_ENABLE_E <= '0';
    wait for period * 7;
    d_encode <= '1';
    SHIFT_ENABLE_E <= '1';
    wait for period;
    SHIFT_ENABLE_E <= '0';
    wait for period * 7;
    d_encode <= '1';
    SHIFT_ENABLE_E <= '1';
    wait for period;
    SHIFT_ENABLE_E <= '0';
    wait for period * 7;
    d_encode <= '1';
    SHIFT_ENABLE_E <= '1';
    wait for period;
    SHIFT_ENABLE_E <= '0';
    wait for period * 7;
    d_encode <= '1';
    SHIFT_ENABLE_E <= '1';
    wait for period;
    SHIFT_ENABLE_E <= '0';
    wait for period * 7;
    d_encode <= '1';
    SHIFT_ENABLE_E <= '1';
    wait for period;
    SHIFT_ENABLE_E <= '0';
    wait for period * 7;
    d_encode <= '0';
    SHIFT_ENABLE_E <= '1';
    wait for period;
    SHIFT_ENABLE_E <= '0';
    wait for period * 7;
    d_encode <= '1';
    SHIFT_ENABLE_E <= '1';
    wait for period;
    SHIFT_ENABLE_E <= '0';
    wait for period * 7;
    d_encode <= '1';
    SHIFT_ENABLE_E <= '1';
    wait for period;
    SHIFT_ENABLE_E <= '0';
    
    wait for period*7;
    
    ---

    EOP <= '1';
    wait for period;
    
    EOP <= '0';
    wait;

  end process;
end TEST;
