-- $Id: $
-- File name:   tb_rx_CRC_CALC.vhd
-- Created:     11/30/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_rx_CRC_CALC is
  generic (Period : Time :=  10.4167 ns);
end tb_rx_CRC_CALC;

architecture TEST of tb_rx_CRC_CALC is

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

  component rx_CRC_CALC
    PORT(
         CLK : in std_logic;
         RST : in std_logic;
         W_ENABLE : in std_logic;
         OPCODE : in std_logic_vector(1 downto 0);
         RCV_DATA : in std_logic_vector(7 downto 0);
         RX_CRC : out std_logic_vector(15 downto 0)
    );
  end component;

-- Insert signals Declarations here
  signal CLK : std_logic;
  signal RST : std_logic;
  signal W_ENABLE : std_logic;
  signal OPCODE : std_logic_vector(1 downto 0);
  signal RCV_DATA : std_logic_vector(7 downto 0);
  signal RX_CRC : std_logic_vector(15 downto 0);

-- signal <name> : <type>;

procedure scrc(
  CONSTANT data: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
  CONSTANT opin: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
  SIGNAL RCV_DATA: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL OPCODE: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL W_ENABLE: OUT STD_LOGIC) IS
BEGIN
  RCV_DATA <= data;
  OPCODE <= opin;
  W_ENABLE <= '1';
  wait for period;
  W_ENABLE <= '0';
END scrc;

begin
  DUT: rx_CRC_CALC port map(
                CLK => CLK,
                RST => RST,
                W_ENABLE => W_ENABLE,
                OPCODE => OPCODE,
                RCV_DATA => RCV_DATA,
                RX_CRC => RX_CRC
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
  W_ENABLE <= '0';
  wait for 10 ns;
  RST <= '0';
  
  scrc(x"61", "01", RCV_DATA, OPCODE, W_ENABLE);
  scrc(x"62", "01", RCV_DATA, OPCODE, W_ENABLE);
  scrc(x"63", "01", RCV_DATA, OPCODE, W_ENABLE);
  scrc(x"64", "01", RCV_DATA, OPCODE, W_ENABLE);
  scrc(x"30", "11", RCV_DATA, OPCODE, W_ENABLE);
  scrc(x"55", "00", RCV_DATA, OPCODE, W_ENABLE);
  scrc(x"F5", "00", RCV_DATA, OPCODE, W_ENABLE);
  scrc(x"61", "01", RCV_DATA, OPCODE, W_ENABLE);
  scrc(x"62", "01", RCV_DATA, OPCODE, W_ENABLE);
  scrc(x"63", "01", RCV_DATA, OPCODE, W_ENABLE);
  scrc(x"64", "01", RCV_DATA, OPCODE, W_ENABLE);
  wait;
    --CLK <= 
    --RST <= 
    --W_ENABLE <= 
    --OPCODE <= 
    --RCV_DATA <= 

  end process;
end TEST;