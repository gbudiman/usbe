-- $Id: $
-- File name:   tb_RCU.vhd
-- Created:     10/14/2010
-- Author:      Brent O'Brien
-- Lab Section: 337-01
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_RX_RCU is
  generic(period : time := 10.42 ns);
end tb_RX_RCU;

architecture TEST of tb_RX_RCU is

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

  component RCU
    PORT(
         CLK : in std_logic;
         RST : in std_logic;
         D_EDGE : in std_logic;
         EOP : in std_logic;
         SHIFT_ENABLE : in std_logic;
         BITSTUFF : in std_logic;
         RCV_DATA : in std_logic_vector(7 downto 0);
         RX_CRC : in std_logic_vector(15 downto 0);
         RCVING : out std_logic;
         W_ENABLE : out std_logic;
         R_ERROR : out std_logic;
         OPCODE : out std_logic_vector(1 downto 0)
    );
  end component;

-- Insert signals Declarations here
  signal CLK : std_logic;
  signal BITSTUFF : std_logic;
  signal RST : std_logic;
  signal D_EDGE : std_logic;
  signal EOP : std_logic;
  signal SHIFT_ENABLE : std_logic;
  signal RX_CRC : std_logic_vector(15 downto 0);
  signal RCV_DATA : std_logic_vector(7 downto 0);
  signal RCVING : std_logic;
  signal W_ENABLE : std_logic;
  signal R_ERROR : std_logic;
  signal OPCODE : std_logic_vector(1 downto 0);

-- signal <name> : <type>;

begin
  DUT: RCU port map(
                CLK => CLK,
                BITSTUFF => BITSTUFF,
                RST => RST,
                D_EDGE => D_EDGE,
                EOP => EOP,
                SHIFT_ENABLE => SHIFT_ENABLE,
                RCV_DATA => RCV_DATA,
                RX_CRC => RX_CRC,
                RCVING => RCVING,
                W_ENABLE => W_ENABLE,
                R_ERROR => R_ERROR,
                OPCODE => OPCODE
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
    D_EDGE <= '0';
    EOP <= '0';
    SHIFT_ENABLE <= '0';
    RCV_DATA <= "00000000";
    RX_CRC <= "1100110011001100";
    BITSTUFF<='0';
    wait for 50 ns;
    RST <= '0';
    wait for period;
    D_EDGE <= '1';
    wait for period;
    D_EDGE <= '0';
    SHIFT_ENABLE <= '1';
    wait for period * 8;
    SHIFT_ENABLE <= '0';
    wait for period * 5;
    EOP <= '1';
    wait for period;
    EOP <= '0';
    wait for period * 4;
    D_EDGE <= '1';
    wait for period;
    D_EDGE <= '0';
    wait for period;
    D_EDGE <= '1';
    wait for period;
    D_EDGE <= '0';
    RCV_DATA <= "10000000";
    wait for period;
    SHIFT_ENABLE <= '1';
    wait for period * 7;
    SHIFT_ENABLE <= '0';
    wait for period * 4;
    SHIFT_ENABLE <= '1';
    wait for period;
    SHIFT_ENABLE <= '0';
    BITSTUFF <= '1';
    wait for period * 3;
    SHIFT_ENABLE <= '1';
    wait for period * 18;
    SHIFT_ENABLE <= '0';
    wait for period * 2;
    RCV_DATA <= "11001100";
    EOP <= '1';
    wait for period*3;
    D_EDGE <= '1';
    wait for period;
    D_EDGE<= '0';
    wait;
    
    
    
    
  end process;
end TEST;