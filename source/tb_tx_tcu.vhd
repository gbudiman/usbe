-- $Id: $
-- File name:   tb_tx_tcu.vhd
-- Created:     11/29/2010
-- Author:      Michael Kelton
-- Lab Section: 337-01
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_tx_tcu is
  generic(period : time := 10.42 ns);
end tb_tx_tcu;

architecture TEST of tb_tx_tcu is

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

  component tx_tcu
    PORT(
         clk : in std_logic;
         rst : in std_logic;
         p_ready : in std_logic;
         t_bitstuff : in std_logic;
         prga_opcode : in std_logic_vector(1 downto 0);
         PRGA_OUT : in std_logic_vector(7 downto 0);
         t_crc : in std_logic_vector (15 downto 0)
    );
  end component;

-- Insert signals Declarations here
  signal clk : std_logic;
  signal rst : std_logic;
  signal p_ready : std_logic;
  signal t_bitstuff : std_logic;
  signal prga_opcode : std_logic_vector(1 downto 0);
  signal PRGA_OUT : std_logic_vector(7 downto 0);
  signal t_crc : std_logic_vector(15 downto 0);

-- signal <name> : <type>;

begin
  DUT: tx_tcu port map(
                clk => clk,
                rst => rst,
                p_ready => p_ready,
                t_bitstuff => t_bitstuff,
                PRGA_OUT => PRGA_OUT,
                prga_opcode => prga_opcode,
                t_crc => t_crc
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
    p_ready <= '0';
    t_bitstuff <= '0';
    PRGA_OUT <= "00000000";
    prga_opcode <= "00";
    wait for 5 ns;
    wait for period;
    
    rst <= '1';
    wait for period;
    
    
    rst <= '0';

    
    t_bitstuff <= '0';
    PRGA_OUT <= "10101010";
    
    p_ready <= '1';
    wait for period;
    p_ready <= '0';
    wait for period;
    
    wait for period*50;
        
    p_ready <= '1';
    wait for period;
    p_ready <= '0';
    wait for period;
    
    PRGA_OUT <= "11111111";
    t_bitstuff <= '1';
    wait for period*7;
    t_bitstuff <= '0';
    
    wait for period*59;
    
    p_ready <= '1';
    wait for period*2;
    p_ready <= '0';
    wait for period;
    
    
    wait for period*100;
    
    prga_opcode <= "11";
    wait for period;
    
    wait;

  end process;
end TEST;