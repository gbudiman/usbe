-- $Id: $
-- File name:   tb_rbuffer.vhd
-- Created:     11/27/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_rbuffer is
  generic (Period : Time :=  10.4167 ns);
end tb_rbuffer;

architecture TEST of tb_rbuffer is

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

  component rbuffer
    PORT(
         CLK : IN STD_LOGIC;
         RST : IN STD_LOGIC;
         NEXT_BYTE : IN STD_LOGIC;
         DATA : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
         OPCODE : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
         BYTE_COUNT : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
         B_READY : OUT STD_LOGIC;
         R_ENABLE : OUT STD_LOGIC;
         PRGA_IN : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
         PRGA_OPCODE : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
    );
  end component;

-- Insert signals Declarations here
  signal CLK : STD_LOGIC;
  signal RST : STD_LOGIC;
  signal NEXT_BYTE : STD_LOGIC;
  signal DATA : STD_LOGIC_VECTOR (7 DOWNTO 0);
  signal OPCODE : STD_LOGIC_VECTOR (1 DOWNTO 0);
  signal BYTE_COUNT : STD_LOGIC_VECTOR (4 DOWNTO 0);
  signal B_READY : STD_LOGIC;
  signal R_ENABLE : STD_LOGIC;
  signal PRGA_IN : STD_LOGIC_VECTOR (7 DOWNTO 0);
  signal PRGA_OPCODE : STD_LOGIC_VECTOR (1 DOWNTO 0);

-- signal <name> : <type>;

begin
  DUT: rbuffer port map(
                CLK => CLK,
                RST => RST,
                NEXT_BYTE => NEXT_BYTE,
                DATA => DATA,
                OPCODE => OPCODE,
                BYTE_COUNT => BYTE_COUNT,
                B_READY => B_READY,
                R_ENABLE => R_ENABLE,
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
wait for 5 ns;
RST <= '0';
wait for 5 ns;
BYTE_COUNT <= "01111";
NEXT_BYTE <= '1';
DATA <= x"08";
OPCODE <= "01";
wait for 8 * period;
BYTE_COUNT <= "10000";

wait;
--    CLK <= 
--    RST <= 
--    NEXT_BYTE <= 
--    DATA <= 
--    OPCODE <= 
--    BYTE_COUNT <= 

  end process;
end TEST;