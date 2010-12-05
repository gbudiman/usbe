-- $Id: $
-- File name:   tb_t_r.vhd
-- Created:     12/4/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_t_r is
  generic (Period : Time :=  10.4167 ns);
end tb_t_r;

architecture TEST of tb_t_r is

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

  component t_r
    PORT(
         PRGA_OUT : IN std_logic_vector (7 DOWNTO 0);
         clk : IN std_logic;
         p_ready : IN std_logic;
         prga_opcode : IN std_logic_vector (1 DOWNTO 0);
         rst : IN std_logic;
         CRC_ERROR : OUT std_logic;
         EOP_EXTERNAL : OUT std_logic;
         NEXT_BYTE : OUT std_logic;
         OPCODE : OUT std_logic_vector (1 DOWNTO 0);
         RCV_DATA : OUT std_logic_vector (7 DOWNTO 0);
         R_ERROR : OUT std_logic
    );
  end component;

-- Insert signals Declarations here
  signal PRGA_OUT : std_logic_vector (7 DOWNTO 0);
  signal clk : std_logic;
  signal p_ready : std_logic;
  signal prga_opcode : std_logic_vector (1 DOWNTO 0);
  signal rst : std_logic;
  signal CRC_ERROR : std_logic;
  signal EOP_EXTERNAL : std_logic;
  signal NEXT_BYTE : std_logic;
  signal OPCODE : std_logic_vector (1 DOWNTO 0);
  signal RCV_DATA : std_logic_vector (7 DOWNTO 0);
  signal R_ERROR : std_logic;

-- signal <name> : <type>;
procedure sendTransmitter(
  constant data: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  constant opcode: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
  signal PRGA_OUT: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal PRGA_OPCODE: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  signal NEXT_BYTE: IN STD_LOGIC;
  signal P_READY: OUT STD_LOGIC) IS
begin
  if (NEXT_BYTE = '0') THEN
    report "spin wait" severity note;
    wait until NEXT_BYTE = '1';
  END IF;
  wait for 8 * period;
  PRGA_OUT <= data;
  PRGA_opcode <= opcode;
  P_READY <= '1';
  wait for period;
  P_READY <= '0';
end sendTransmitter;

begin
  DUT: t_r port map(
                PRGA_OUT => PRGA_OUT,
                clk => clk,
                p_ready => p_ready,
                prga_opcode => prga_opcode,
                rst => rst,
                CRC_ERROR => CRC_ERROR,
                EOP_EXTERNAL => EOP_EXTERNAL,
                NEXT_BYTE => NEXT_BYTE,
                OPCODE => OPCODE,
                RCV_DATA => RCV_DATA,
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
  
process

  begin

-- Insert TEST BENCH Code Here
    p_ready <= '0';
    prga_out <= x"80";
    prga_opcode <= "00";
    rst <= '1';
    wait for 5 ns;
    rst <= '0';
    wait for 5 ns;
    
    wait for 50 ns;
    P_READY <= '1';
    wait for period;
    P_READY <= '0';
    sendTransmitter("11111111", "00", PRGA_OUT, PRGA_OPCODE, NEXT_BYTE, P_READY);
    sendTransmitter("11011111", "01", PRGA_OUT, PRGA_OPCODE, NEXT_BYTE, P_READY);
    sendTransmitter("11101111", "01", PRGA_OUT, PRGA_OPCODE, NEXT_BYTE, P_READY);
    sendTransmitter("11101111", "01", PRGA_OUT, PRGA_OPCODE, NEXT_BYTE, P_READY);
    sendTransmitter("11111111", "11", PRGA_OUT, PRGA_OPCODE, NEXT_BYTE, P_READY);
    --PRGA_OUT <= 
    --clk <= 
    --p_ready <= 
    --prga_opcode <= 
    --rst <= 
    wait;
  end process;
end TEST;