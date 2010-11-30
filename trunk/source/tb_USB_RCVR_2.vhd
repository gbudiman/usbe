-- $Id: $
-- File name:   tb_USB_RCVR_2.vhd
-- Created:     10/6/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_USB_RCVR_2 is
  generic (Period : Time :=  83.33 ns;
      DataPeriod: Time := 666.67 ns);
end tb_USB_RCVR_2;

architecture TEST2 of tb_USB_RCVR_2 is

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
  
  component USB_RCVR
    PORT(
         CLK : IN STD_LOGIC;
         D_MINUS : IN STD_LOGIC;
         D_PLUS : IN STD_LOGIC;
         R_ENABLE : IN STD_LOGIC;
         RST_N : IN STD_LOGIC;
         EMPTY : OUT STD_LOGIC;
         FULL : OUT STD_LOGIC;
         RCVING : OUT STD_LOGIC;
         R_DATA : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
         R_ERROR : OUT STD_LOGIC
    );
  end component;

-- Insert signals Declarations here
  signal CLK : STD_LOGIC;
  signal D_MINUS : STD_LOGIC;
  signal D_PLUS : STD_LOGIC;
  signal R_ENABLE : STD_LOGIC;
  signal RST_N : STD_LOGIC;
  signal EMPTY : STD_LOGIC;
  signal FULL : STD_LOGIC;
  signal RCVING : STD_LOGIC;
  signal R_DATA : STD_LOGIC_VECTOR (7 DOWNTO 0);
  signal R_ERROR : STD_LOGIC;

-- signal <name> : <type>;
  signal DBUS : STD_LOGIC_VECTOR (7 DOWNTO 0);
  signal grid : STD_LOGIC;
  
  procedure sendByteFast (
      constant data : in std_logic_vector(7 downto 0);
      signal d_plus: OUT STD_LOGIC;
      signal d_minus: OUT STD_LOGIC) is
  begin
      for i in 7 downto 0 loop
          D_PLUS <= data(i);
          D_MINUS <= NOT data(i);
          wait for dataperiod * 1;
      end loop;
  end sendByteFast;
  
  procedure sendByteIncomplete (
      constant data : in std_logic_vector(7 downto 0);
      constant length : IN integer;
      signal d_plus: OUT STD_LOGIC;
      signal d_minus: OUT STD_LOGIC) is
  begin
      for i in 7 downto length loop
          D_PLUS <= data(i);
          D_MINUS <= NOT data(i);
          wait for dataperiod * 0.99;
          --if (i = 0 or i = 2 or i = 4 or i = 6) THEN
--            wait for dataperiod * 0.99;
--          else
--            wait for dataperiod * 1.01;
--          end if;
      end loop;
  end sendByteIncomplete;
  
  procedure sendEOP (
      constant repeat: IN integer;
      signal d_plus: OUT STD_LOGIC;
      signal d_minus: OUT STD_LOGIC) is
  begin
    for i in 0 to repeat loop
      d_plus <= '0';
      d_minus <= '0';
      wait for dataperiod;
    end loop;
    d_plus <= '1';
    d_minus <= '0';
    wait for dataperiod;
  end sendEOP;
  
begin
  DUT: USB_RCVR port map(
                CLK => CLK,
                D_MINUS => D_MINUS,
                D_PLUS => D_PLUS,
                R_ENABLE => R_ENABLE,
                RST_N => RST_N,
                EMPTY => EMPTY,
                FULL => FULL,
                RCVING => RCVING,
                R_DATA => R_DATA,
                R_ERROR => R_ERROR
                );

--   GOLD: <GOLD_NAME> port map(<put mappings here>);
autoClock: process
  BEGIN
    clk <= '0';
    wait for period/2;
    clk <= '1';
    wait for period/2;
  END process autoClock;
autoGrid: process
  BEGIN
    grid <= '0';
    wait for dataperiod/2;
    grid <= '1';
    wait for dataperiod/2;
  END process autoGrid;
  
process

  begin

-- Insert TEST BENCH Code Here
  RST_N <= '0';
  D_PLUS <= '1';
  D_MINUS <= '0';
  R_ENABLE <= '0';
  wait for 50 ns;
  RST_N <= '1';

  report "Sending incomplete SYNC byte (4 bits only)" severity note;
  sendByteIncomplete("01010100", 4, D_PLUS, D_MINUS);
  sendEOP(0, D_PLUS, D_MINUS);
  report "Done with incomplete SYNC byte (4 bits only)" severity note;
  report "Sending incomplete SYNC byte (7 bits)" severity note;
  sendByteIncomplete("01010100", 1, D_PLUS, D_MINUS);
  sendEOP(0, D_PLUS, D_MINUS);
  report "Done with incomplete SYNC byte (7 bits only)" severity note;
  report "Sending incorrect SYNC byte, followed by garbage and correct SYNC byte" severity note;
  sendByteFast("01010101", D_PLUS, D_MINUS);
  sendByteFast("01010001", D_PLUS, D_MINUS);
  sendByteFast("01010100", D_PLUS, D_MINUS);
  sendByteFast("11001010", D_PLUS, D_MINUS);
  sendEOP(0, D_PLUS, D_MINUS);
  report "Done with incorrect SYNC byte" severity note;
  report "Send 0 length packet" severity note;
  sendByteFast("01010100", D_PLUS, D_MINUS);
  sendEOP(0, D_PLUS, D_MINUS);
  report "Done with 0 length packet" severity note;
  report "Send 8 byte correct data" severity note;
  sendByteFast("01010100", D_PLUS, D_MINUS);
  sendByteFast("00000000", D_PLUS, D_MINUS);
  report "Observe 11111111 here" severity note;
  sendEOP(0, D_PLUS, D_MINUS);
  sendByteFast("01010100", D_PLUS, D_MINUS);
  sendByteFast("11111111", D_PLUS, D_MINUS);
  report "Observe 11111110 here" severity note;
  sendEOP(0, D_PLUS, D_MINUS);
  sendByteFast("01010100", D_PLUS, D_MINUS);
  sendByteFast("00000000", D_PLUS, D_MINUS);
  sendEOP(0, D_PLUS, D_MINUS);
  r_enable <= '1';
  wait for period;
  r_enable <= '0';
  report "Result: 00001010, 01111111";
  report "Send incomplete byte" severity note;
  sendByteFast("01010100", D_PLUS, D_MINUS);
  sendByteFast("11000011", D_PLUS, D_MINUS);
  sendByteIncomplete("11110011", 1, D_PLUS, D_MINUS);
  r_enable <= '1';
  wait for period;
  r_enable <= '0';
  report "Result: 10111010" severity note;
  report "Done with incomplete byte" severity note;
  sendEOP(0, D_PLUS, D_MINUS);
  report "Reset" severity note;
  
  RST_N <= '0';
  wait for 30 ns;
  RST_N <= '1';
  wait for 30 ns;
  report "Normal procedure" severity note;
  sendByteFast("01010100", D_PLUS, D_MINUS);
  
  sendByteFast("11010100", D_PLUS, D_MINUS);
  sendByteFast("00100011", D_PLUS, D_MINUS);
  sendByteFast("01000110", D_PLUS, D_MINUS);
  sendByteFast("00111000", D_PLUS, D_MINUS);
  sendByteFast("10110010", D_PLUS, D_MINUS);
  sendByteFast("10111010", D_PLUS, D_MINUS);
  sendByteFast("11001011", D_PLUS, D_MINUS);
  sendByteFast("01010100", D_PLUS, D_MINUS);
  
  sendByteFast("11010100", D_PLUS, D_MINUS);
  sendByteFast("00100011", D_PLUS, D_MINUS);
  sendByteFast("01000110", D_PLUS, D_MINUS);
  sendByteFast("00111000", D_PLUS, D_MINUS);
  sendByteFast("10110010", D_PLUS, D_MINUS);
  sendByteFast("10111010", D_PLUS, D_MINUS);
  sendByteFast("11001011", D_PLUS, D_MINUS);
  sendByteFast("01010100", D_PLUS, D_MINUS);
  
  sendEOP(0, D_PLUS, D_MINUS);
  report "Check result here" severity note;
  for i in 0 to 7 loop
    r_enable <= '1';
    wait for 1 * period;
    r_enable <= '0';
    wait for 7 * period;
  end loop;
  
    --CLK <= 
    --D_MINUS <= 
    --D_PLUS <= 
    --R_ENABLE <= 
    --RST_N <= 
  wait;
  
  end process;
end TEST2;