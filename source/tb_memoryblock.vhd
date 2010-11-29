-- $Id: $
-- File name:   tb_memoryblock.vhd
-- Created:     11/27/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_memoryblock is
  generic (Period : Time :=  10.4167 ns);
end tb_memoryblock;

architecture TEST of tb_memoryblock is

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

  component memoryblock
    PORT(
         CLK : IN STD_LOGIC;
         NEXT_BYTE : IN STD_LOGIC;
         RCV_DATA : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
         RCV_OPCODE : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
         RST : IN STD_LOGIC;
         EOP : IN STD_LOGIC;
         W_ENABLE : IN STD_LOGIC;
         EMPTY : OUT STD_LOGIC;
         FULL : OUT STD_LOGIC;
         B_READY: OUT STD_LOGIC;
         PRGA_IN : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
         PRGA_OPCODE : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
    );
  end component;

-- Insert signals Declarations here
  signal CLK : STD_LOGIC;
  signal NEXT_BYTE : STD_LOGIC;
  signal RCV_DATA : STD_LOGIC_VECTOR (7 DOWNTO 0);
  signal RCV_OPCODE : STD_LOGIC_VECTOR (1 DOWNTO 0);
  signal RST : STD_LOGIC;
  signal EOP : STD_LOGIC;
  signal W_ENABLE : STD_LOGIC;
  signal EMPTY : STD_LOGIC;
  signal FULL : STD_LOGIC;
  signal B_READY : STD_LOGIC;
  signal PRGA_IN : STD_LOGIC_VECTOR (7 DOWNTO 0);
  signal PRGA_OPCODE : STD_LOGIC_VECTOR (1 DOWNTO 0);

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

PROCEDURE cycleNB(
  SIGNAL NEXT_BYTE: OUT STD_LOGIC) IS
BEGIN
  NEXT_BYTE <= '0';
  wait for 1 * period;
  NEXT_BYTE <= '1';
  wait for 7 * period;
  NEXT_BYTE <= '0';
END cycleNB;

begin
  DUT: memoryblock port map(
                CLK => CLK,
                NEXT_BYTE => NEXT_BYTE,
                RCV_DATA => RCV_DATA,
                RCV_OPCODE => RCV_OPCODE,
                RST => RST,
                W_ENABLE => W_ENABLE,
                EOP => EOP,
                EMPTY => EMPTY,
                FULL => FULL,
                B_READY => B_READY,
                PRGA_IN => PRGA_IN,
                PRGA_OPCODE => PRGA_OPCODE
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
  NEXT_BYTE <= '1';
  W_ENABLE <= '0';
  wait for period;
  RST <= '0';
  wait for period;
  EOP <= '0';
  
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
  cycleNB(NEXT_BYTE);
  sendFIFO(x"73", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  cycleNB(NEXT_BYTE);
  sendFIFO(x"83", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  cycleNB(NEXT_BYTE);
  sendFIFO(x"93", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  cycleNB(NEXT_BYTE);
  sendFIFO(x"A3", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  cycleNB(NEXT_BYTE);
  sendFIFO(x"B3", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  cycleNB(NEXT_BYTE);
  sendFIFO(x"C3", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  cycleNB(NEXT_BYTE);
  sendFIFO(x"D3", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  cycleNB(NEXT_BYTE);
  sendFIFO(x"E3", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  cycleNB(NEXT_BYTE);
  sendFIFO(x"F3", "00", RCV_DATA, RCV_OPCODE, W_ENABLE);
  cycleNB(NEXT_BYTE);
  sendFIFO(x"FF", "11", RCV_DATA, RCV_OPCODE, W_ENABLE);
  for i in 0 to 16 loop
    cycleNB(NEXT_BYTE);
  end loop;
  sendFIFO(x"20", "01", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"21", "01", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"22", "01", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"23", "01", RCV_DATA, RCV_OPCODE, W_ENABLE);
  EOP <= '1';
  cycleNB(NEXT_BYTE);
  EOP <= '0';
  sendFIFO(x"24", "01", RCV_DATA, RCV_OPCODE, W_ENABLE);
  cycleNB(NEXT_BYTE);
  sendFIFO(x"25", "01", RCV_DATA, RCV_OPCODE, W_ENABLE);
  sendFIFO(x"F3", "11", RCV_DATA, RCV_OPCODE, W_ENABLE);
  cycleNB(NEXT_BYTE);
  cycleNB(NEXT_BYTE);
  cycleNB(NEXT_BYTE);
  cycleNB(NEXT_BYTE);
  wait;
    --CLK <= 
--    NEXT_BYTE <= 
--    RCV_DATA <= 
--    RCV_OPCODE <= 
--    RST <= 
--    W_ENABLE <= 

  end process;
end TEST;