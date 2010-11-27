-- $Id: $
-- File name:   tb_rfifo.vhd
-- Created:     11/27/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_rfifo is
  generic (Period : Time :=  10.4167 ns);
end tb_rfifo;

architecture TEST of tb_rfifo is

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

  component rfifo
    PORT(
         CLK : IN STD_LOGIC;
         RST : IN STD_LOGIC;
         W_ENABLE : IN STD_LOGIC;
         R_ENABLE : IN STD_LOGIC;
         RCV_DATA : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
         RCV_OPCODE : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
         DATA : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
         OUT_OPCODE: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
         BYTE_COUNT : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
         EMPTY : OUT STD_LOGIC;
         FULL : OUT STD_LOGIC
    );
  end component;

-- Insert signals Declarations here
  signal CLK : STD_LOGIC;
  signal RST : STD_LOGIC;
  signal W_ENABLE : STD_LOGIC;
  signal R_ENABLE : STD_LOGIC;
  signal RCV_DATA : STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal RCV_OPCODE : STD_LOGIC_VECTOR(1 DOWNTO 0);
  signal DATA : STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal OUT_OPCODE: STD_LOGIC_VECTOR(1 DOWNTO 0);
  signal BYTE_COUNT : STD_LOGIC_VECTOR(4 DOWNTO 0);
  signal EMPTY : STD_LOGIC;
  signal FULL : STD_LOGIC;

-- signal <name> : <type>;

PROCEDURE sendFIFO(
  CONSTANT RDATA: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
  CONSTANT ROPCODE: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
  SIGNAL RCV_DATA: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
  SIGNAL RCV_OPCODE: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
  SIGNAL W_ENABLE: OUT STD_LOGIC) IS
BEGIN
  W_ENABLE <= '1';
  RCV_DATA <= RDATA;
  RCV_OPCODE <= ROPCODE;
  wait for period;
  W_ENABLE <= '0';
  wait for 7 * period;
END sendFIFO;

PROCEDURE readFIFO(
  SIGNAL R_ENABLE: OUT STD_LOGIC) IS
BEGIN
  R_ENABLE <= '1';
  wait for period;
  R_ENABLE <= '0';
  wait for 7 * period;
END readFIFO;

begin
  DUT: rfifo port map(
                CLK => CLK,
                RST => RST,
                W_ENABLE => W_ENABLE,
                R_ENABLE => R_ENABLE,
                RCV_DATA => RCV_DATA,
                RCV_OPCODE => RCV_OPCODE,
                DATA => DATA,
                OUT_OPCODE => OUT_OPCODE,
                BYTE_COUNT => BYTE_COUNT,
                EMPTY => EMPTY,
                FULL => FULL
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
  RST <= '1';
  wait for 5 ns;
  RST <= '0';
  wait for 5 ns;
  W_ENABLE <= '0';
  R_ENABLE <= '0';
  
  sendFIFO(x"01", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"02", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"03", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"04", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"05", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"06", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"07", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"08", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"09", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"13", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"23", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"33", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"43", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"53", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"63", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"73", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"83", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"93", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"A3", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"B3", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"C3", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"D3", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"E3", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"F3", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"0A", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"0B", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"0C", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"0D", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"0E", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"0F", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"00", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"FF", "11", RCV_DATA, RCV_OPCODE, W_ENABLE);
  for i in 0 to 5 loop
    readFIFO(R_ENABLE);
  end loop;
  sendFIFO(x"80", "01", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"81", "01", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"82", "01", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"83", "01", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"84", "01", RCV_DATA, RCV_OPCODE, W_ENABLE);
  for i in 0 to 31 loop
    readFIFO(R_ENABLE);
  end loop;
    --CLK <= 
--    RST <= 
--    W_ENABLE <= 
--    R_ENABLE <= 
--    RCV_DATA <= 
--    RCV_OPCODE <= 

  wait;
  end process;
end TEST;