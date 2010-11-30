-- $Id: $
-- File name:   tb_rx_accumulator.vhd
-- Created:     11/30/2010
-- Author:      Brent O'Brien
-- Lab Section: 337-01
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_rx_accumulator is
  generic(period : time := 10.42 ns);
end tb_rx_accumulator;

architecture TEST of tb_rx_accumulator is

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

  component rx_accumulator
    PORT(
         CLK : in std_logic;
         RST : in std_logic;
         RCV_DATA : in std_logic_vector(7 downto 0);
         W_ENABLE : in std_logic;
         rx_CHECK_CRC : out std_logic_vector(15 downto 0)
    );
  end component;

-- Insert signals Declarations here
  signal CLK : std_logic;
  signal RST : std_logic;
  signal RCV_DATA : std_logic_vector(7 downto 0);
  signal W_ENABLE : std_logic;
  signal rx_CHECK_CRC : std_logic_vector(15 downto 0);

-- signal <name> : <type>;

begin
  DUT: rx_accumulator port map(
                CLK => CLK,
                RST => RST,
                RCV_DATA => RCV_DATA,
                W_ENABLE => W_ENABLE,
                rx_CHECK_CRC => rx_CHECK_CRC
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
    RST <= '1';
    W_ENABLE <='0';
    RCV_DATA <= x"00";
    wait for 5 ns;
    wait for period;
    RST <= '0';
    RCV_DATA <= "11001100";
    wait for period;

    W_ENABLE <= '1';
    wait for period;
    W_ENABLE <= '0';
    wait for period * 62;
    RCV_DATA <= "00110011";
    wait for period;
    W_ENABLE <= '1';
    wait for period;
    W_ENABLE <= '0';
    wait for period * 62;
    RCV_DATA <= x"3C";
    wait for period;
    W_ENABLE <= '1';
    wait for period;
    W_ENABLE <= '0';
    wait for period;
    wait;
    

  end process;
end TEST;