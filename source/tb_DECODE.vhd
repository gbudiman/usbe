-- $Id: $
-- File name:   tb_DECODE.vhd
-- Created:     9/28/2010
-- Author:      Brent O'Brien
-- Lab Section: 337-01
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_DECODE is
  generic(period : time := 83 ns);
end tb_DECODE;

architecture TEST of tb_DECODE is

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

  component h2s_decode
    PORT(
         CLK : in std_logic;
         RST : in std_logic;
         DP1_RX : in std_logic;
         SHIFT_ENABLE : in std_logic;
         EOP : in std_logic;
         D_ORIG : out std_logic;
         bitstuff : out std_logic
    );
  end component;

-- Insert signals Declarations here
  signal CLK : std_logic;
  signal RST : std_logic;
  signal DP1_RX : std_logic;
  signal SHIFT_ENABLE : std_logic;
  signal EOP : std_logic;
  signal D_ORIG : std_logic;
  signal bitstuff : std_logic;

-- signal <name> : <type>;

begin
  DUT: h2s_decode port map(
                CLK => CLK,
                RST => RST,
                DP1_RX => DP1_RX,
                SHIFT_ENABLE => SHIFT_ENABLE,
                EOP => EOP,
                D_ORIG => D_ORIG,
                bitstuff => bitstuff
                );

--   GOLD: <GOLD_NAME> port map(<put mappings here>);
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
    EOP <= '0';
    RST <= '1';
    DP1_RX <= '1';
    SHIFT_ENABLE <='0';
    wait for 20 ns;
    wait for period;
    RST <= '0';
    wait for period;
    DP1_RX <= '1';
    SHIFT_ENABLE <= '0';
    wait for period;
    SHIFT_ENABLE <= '1';
    wait for period;
    SHIFT_ENABLE <= '0';
    wait for period * 2;
    wait for period;
    SHIFT_ENABLE <= '1';
    wait for period;
    SHIFT_ENABLE <= '0';
    wait for period * 2;
    wait for period;
    SHIFT_ENABLE <= '1';
    wait for period;
    SHIFT_ENABLE <= '0';
    wait for period * 2;
    wait for period;
    SHIFT_ENABLE <= '1';
    wait for period;
    SHIFT_ENABLE <= '0';
    wait for period * 2;
    wait for period;
    SHIFT_ENABLE <= '1';
    wait for period;
    SHIFT_ENABLE <= '0';
    wait for period * 2;
    wait for period;
    SHIFT_ENABLE <= '1';
    wait for period;
    SHIFT_ENABLE <= '0';
    wait for period * 2;
    DP1_RX <= '0';
    wait for period;
    SHIFT_ENABLE <= '1';
    wait for period;
    SHIFT_ENABLE <= '0';
    wait for period * 2;
    DP1_RX <= '1';
    wait for period;
    SHIFT_ENABLE <= '1';
    wait for period;
    SHIFT_ENABLE <= '0';
    wait for period * 2;
    RST <= '1';
    wait for period;
    
    RST <= '0';
    wait for period;
    DP1_RX <= '0';
    SHIFT_ENABLE <= '0';
    wait for period;
    SHIFT_ENABLE <= '1';
    wait for period;
    SHIFT_ENABLE <= '0';
    wait for period * 2;
    wait for period;
    SHIFT_ENABLE <= '1';
    wait for period;
    SHIFT_ENABLE <= '0';
    wait for period * 2;
    wait for period;
    SHIFT_ENABLE <= '1';
    wait for period;
    SHIFT_ENABLE <= '0';
    wait for period * 2;
    wait for period;
    SHIFT_ENABLE <= '1';
    wait for period;
    SHIFT_ENABLE <= '0';
    wait for period * 2;
    wait for period;
    SHIFT_ENABLE <= '1';
    wait for period;
    SHIFT_ENABLE <= '0';
    wait for period * 2;
    wait for period;
    SHIFT_ENABLE <= '1';
    wait for period;
    SHIFT_ENABLE <= '0';
    wait for period * 2;
    DP1_RX <= '1';
    wait for period;
    SHIFT_ENABLE <= '1';
    wait for period;
    SHIFT_ENABLE <= '0';
    wait for period * 2;
    DP1_RX <= '0';
    wait for period;
    SHIFT_ENABLE <= '1';
    wait for period;
    SHIFT_ENABLE <= '0';
    wait for period * 2;
    
    

    -- Tests what happens when EOP and SHIFT_ENABLE are both asserted
    -- Expect EOP to overwrite the shifting and both holds to go high.
    wait for period;
    EOP <= '1';
    wait for period;
    RST <= '1';
    wait;

  end process;
end TEST;