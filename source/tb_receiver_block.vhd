-- $Id: $
-- File name:   tb_receiver_block.vhd
-- Created:     11/30/2010
-- Author:      Brent O'Brien
-- Lab Section: 337-01
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_receiver_block is
  generic(period : time := 10.42 ns);
end tb_receiver_block;

architecture TEST of tb_receiver_block is

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

  component receiver_block
    PORT(
         CLK : IN std_logic;
         DM1_RX : IN std_logic;
         DP1_RX : IN std_logic;
         RST : IN std_logic;
         CRC_ERROR : OUT std_logic;
         OPCODE : OUT std_logic_vector (1 DOWNTO 0);
         RCV_DATA : OUT std_logic_vector (7 DOWNTO 0);
         R_ERROR : OUT std_logic;
         W_ENABLE : OUT std_logic
    );
  end component;

-- Insert signals Declarations here
  signal CLK : std_logic;
  signal DM1_RX : std_logic;
  signal DP1_RX : std_logic;
  signal RST : std_logic;
  signal CRC_ERROR : std_logic;
  signal OPCODE : std_logic_vector (1 DOWNTO 0);
  signal RCV_DATA : std_logic_vector (7 DOWNTO 0);
  signal R_ERROR : std_logic;
  signal W_ENABLE : std_logic;

-- signal <name> : <type>;
signal DBUS : STD_LOGIC_VECTOR (7 DOWNTO 0);
signal grid : STD_LOGIC;

procedure sendByteFast (
    constant data : in std_logic_vector(7 downto 0);
    signal DP1_RX: OUT STD_LOGIC;
    signal DM1_RX: OUT STD_LOGIC) is
begin
    for i in 7 downto 0 loop
        DP1_RX <= data(i);
        DM1_RX <= NOT data(i);
        wait for 8*period * 1;
    end loop;
end sendByteFast;

procedure sendByteIncomplete (
    constant data : in std_logic_vector(7 downto 0);
    constant length : IN integer;
    signal DP1_RX: OUT STD_LOGIC;
    signal DM1_RX: OUT STD_LOGIC) is
begin
    for i in 7 downto length loop
        DP1_RX <= data(i);
        DM1_RX <= NOT data(i);
        wait for 8*period * 0.99;
        --if (i = 0 or i = 2 or i = 4 or i = 6) THEN
--            wait for 8*period * 0.99;
--          else
--            wait for 8*period * 1.01;
--          end if;
    end loop;
end sendByteIncomplete;

procedure sendEOP (
    constant repeat: IN integer;
    signal DP1_RX: OUT STD_LOGIC;
    signal DM1_RX: OUT STD_LOGIC) is
begin
  for i in 0 to repeat loop
    DP1_RX <= '0';
    DM1_RX <= '0';
    wait for 8*period;
  end loop;
  DP1_RX <= '1';
  DM1_RX <= '0';
  wait for 8*period;
end sendEOP;


begin
  DUT: receiver_block port map(
                CLK => CLK,
                DM1_RX => DM1_RX,
                DP1_RX => DP1_RX,
                RST => RST,
                CRC_ERROR => CRC_ERROR,
                OPCODE => OPCODE,
                RCV_DATA => RCV_DATA,
                R_ERROR => R_ERROR,
                W_ENABLE => W_ENABLE
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
    wait for 8*period/2;
    grid <= '1';
    wait for 8*period/2;
  END process autoGrid;
  
  
process

  begin

-- Insert TEST BENCH Code Here

    DM1_RX <= '1';
    DP1_RX <= '1';
    RST <= '1';
    wait for period;
    RST <= '0';
    wait for period;
    sendByteFast("01010100", DP1_RX, DM1_RX);
    
    sendByteFast("11010100", DP1_RX, DM1_RX);
    sendByteFast("00100011", DP1_RX, DM1_RX);
    sendByteFast("01000110", DP1_RX, DM1_RX);
    sendByteFast("00111000", DP1_RX, DM1_RX);
    sendByteFast("10110010", DP1_RX, DM1_RX);
    sendByteFast("10111010", DP1_RX, DM1_RX);
    sendByteFast("11001011", DP1_RX, DM1_RX);
    sendByteFast("01010100", DP1_RX, DM1_RX);
    
    sendByteFast("11010100", DP1_RX, DM1_RX);
    sendByteFast("00100011", DP1_RX, DM1_RX);
    sendByteFast("01000110", DP1_RX, DM1_RX);
    sendByteFast("00111000", DP1_RX, DM1_RX);
    sendByteFast("10110010", DP1_RX, DM1_RX);
    sendByteFast("11111101", DP1_RX, DM1_RX);
    sendByteIncomplete("10000000", 7, DP1_RX, DM1_RX);
    sendByteFast("01010100", DP1_RX, DM1_RX);
    
    sendEOP(0, DP1_RX, DM1_RX);
    
    sendByteFast("01010100", DP1_RX, DM1_RX);
    
    sendByteFast("11010100", DP1_RX, DM1_RX);
    sendByteFast("00100011", DP1_RX, DM1_RX);
    sendByteFast("01000110", DP1_RX, DM1_RX);
    sendByteFast("00111000", DP1_RX, DM1_RX);
    sendByteFast("10110010", DP1_RX, DM1_RX);
    sendByteFast("10111010", DP1_RX, DM1_RX);
    sendByteFast("11001011", DP1_RX, DM1_RX);
    sendByteFast("01010100", DP1_RX, DM1_RX);
    
    sendByteFast("11010100", DP1_RX, DM1_RX);
    sendByteFast("00100011", DP1_RX, DM1_RX);
    sendByteFast("01000110", DP1_RX, DM1_RX);
    sendByteFast("00111000", DP1_RX, DM1_RX);
    sendByteFast("10110010", DP1_RX, DM1_RX);
    sendByteFast("10111010", DP1_RX, DM1_RX);
    sendByteFast("10111111", DP1_RX, DM1_RX);
    sendByteIncomplete("00000000", 7, DP1_RX, DM1_RX);
    sendByteFast("01010100", DP1_RX, DM1_RX);
    
    sendEOP(0, DP1_RX, DM1_RX);
    wait;
  end process;
end TEST;