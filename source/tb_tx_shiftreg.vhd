-- $Id: $
-- File name:   tb_tx_shiftreg.vhd
-- Created:     11/21/2010
-- Author:      Michael Kelton
-- Lab Section: 337-01
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_tx_shiftreg is
  generic(period : time := 10.42 ns);
end tb_tx_shiftreg;

architecture TEST of tb_tx_shiftreg is

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

  component tx_shiftreg
    PORT(
         clk : in std_logic;
         rst : in std_logic;
         SHIFT_ENABLE_R : in std_logic;
         t_bitstuff : in std_logic;
         t_strobe : in std_logic;
         send_data  :in std_logic_vector(7 downto 0);
         d_encode  :out  std_logic
    );
  end component;

-- Insert signals Declarations here
  signal clk : std_logic;
  signal rst : std_logic;
  signal SHIFT_ENABLE_R : std_logic;
  signal t_bitstuff : std_logic;
  signal t_strobe : std_logic;
  signal send_data  : std_logic_vector(7 downto 0);
  signal d_encode  : std_logic;

-- signal <name> : <type>;

begin
  DUT: tx_shiftreg port map(
                clk => clk,
                rst => rst,
                SHIFT_ENABLE_R => SHIFT_ENABLE_R,
                t_bitstuff => t_bitstuff,
                t_strobe => t_strobe,
                send_data => send_data,
                d_encode => d_encode
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

    rst <= '1';
    wait for period;
    
    SHIFT_ENABLE_R <= '0'; 
    t_bitstuff <= '0';
    t_strobe <= '0';
    send_data <= "10101010";
    wait for period;
    
    rst <= '0';
    wait for period;
    wait for 5 ns;
    
    t_strobe <= '1';
    SHIFT_ENABLE_R <= '1';
    wait for period;
    SHIFT_ENABLE_R <= '0';
    wait for period*7;
    t_strobe <= '0';
    
    SHIFT_ENABLE_R <= '1';
    wait for period;
    SHIFT_ENABLE_R <= '0';
    wait for period*7;
    
    SHIFT_ENABLE_R <= '1';
    wait for period;
    SHIFT_ENABLE_R <= '0';
    wait for period*7;
    
    SHIFT_ENABLE_R <= '1';
    t_bitstuff <= '1';
    wait for period;
    SHIFT_ENABLE_R <= '0';
    wait for period*7;
    t_bitstuff <= '0';
    SHIFT_ENABLE_R <= '1';
    wait for period;
    SHIFT_ENABLE_R <= '0';
    wait for period*7;
    
    SHIFT_ENABLE_R <= '1';
    wait for period;
    SHIFT_ENABLE_R <= '0';
    wait for period*7;
    
    SHIFT_ENABLE_R <= '1';
    wait for period;
    SHIFT_ENABLE_R <= '0';
    wait for period*7;
    
    SHIFT_ENABLE_R <= '1';
    wait for period;
    SHIFT_ENABLE_R <= '0';
    wait for period*7;
    
    SHIFT_ENABLE_R <= '1';
    wait for period;
    SHIFT_ENABLE_R <= '0';
    wait for period*7;
    
    

  end process;
end TEST;