-- $Id: $
-- File name:   tb_rmedt.vhd
-- Created:     12/3/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_rmedt is
  generic (Period : Time :=  10.4167 ns);
end tb_rmedt;

architecture TEST of tb_rmedt is

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

  component rmedt
    PORT(
         CLK : IN std_logic;
         DM1_RX : IN std_logic;
         DP1_RX : IN std_logic;
         dm_tx_out : OUT std_logic;
         dp_tx_out : OUT std_logic;
         RST : IN std_logic;
         SERIAL_IN : IN std_logic;
         CRC_ERROR : OUT std_logic;
         EMPTY : OUT STD_LOGIC;
         FULL : OUT STD_LOGIC;
         KEY_ERROR : OUT std_logic;
         PROG_ERROR : OUT std_logic;
         PARITY_ERROR : OUT std_logic;
         RBUF_FULL : OUT std_logic;
         R_ERROR : OUT std_logic
    );
  end component;

-- Insert signals Declarations here
  signal CLK : std_logic;
  signal DM1_RX : std_logic;
  signal DP1_RX : std_logic;
  signal DM1_TX : std_logic;
  signal DP1_TX : std_logic;
  signal RST : std_logic;
  signal SERIAL_IN : std_logic;
  signal CRC_ERROR : std_logic;
  signal EMPTY : STD_LOGIC;
  signal FULL : STD_LOGIC;
  signal KEY_ERROR : std_logic;
  signal PROG_ERROR : std_logic;
  signal PARITY_ERROR : std_logic;
  signal RBUF_FULL : std_logic;
  signal R_ERROR : std_logic;

-- signal <name> : <type>;
procedure sendUART(
  constant data_in: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal serial_in: OUT STD_LOGIC) is
begin
  serial_in <= '0';
  report "Start" severity note;
  wait for 10 * period;
  for i in 0 to 7 loop
    serial_in <= data_in(i);
    wait for 10 * period;
  end loop;
  report "End" severity note;
  serial_in <= '0';
  wait for 10 * period;
  serial_in <= '1';
  wait for 30 * period;
end sendUART;

procedure HEXtoNRZI (
  constant data : in std_logic_vector(7 downto 0);
  variable bc_count : inout integer;
  signal D    : inout std_logic; 
  signal D_MIN: out std_logic) is
  variable count: integer;
  variable D_Last: std_logic;
  begin
    count := bc_count;
--    case count is
--      when 0 => report "0";
--      when 1 => report "1";
--      when 2 => report "2";
--      when 3 => report "3";
--      when 4 => report "4";
--      when 5 => report "5";
--      when 6 => report "6";
--      when 7 => report "7";
--      when others => report "HUH?";
--    end case;
    for i in 0 to 7 loop
      -- report "IN" severity note;
      if (count = 6) then
        D_Last := D;
        if (data(i) = '0') then
          count := 1;
        else
          count := 0;
        end if;
        D <= not(D);
        D_MIN <= D;
        wait for 8*Period;
        if (data(i) = '0') then
          D <= not(D_Last);
          D_MIN <= D_Last;
        else
          D <= (D_LAST);
          D_MIN <= not(D_Last);
        end if;
      else
        if (data(i) = '0') then
          count := 0;
          D <= not(D);
          D_MIN <= D;
        else
          count := count + 1;
          D <= D;
          D_MIN <= not(D);
        end if;
      end if;
      wait for 8*Period;
      bc_count := count;
    end loop;
  end HEXtoNRZI;

procedure sendEOP (
    constant repeat: IN integer;
    signal d_plus: OUT STD_LOGIC;
    signal d_minus: OUT STD_LOGIC) is
begin
  for i in 0 to repeat loop
    d_plus <= '0';
    d_minus <= '0';
    wait for 8 * period;
  end loop;
  d_plus <= '1';
  d_minus <= '0';
  wait for 8 * period;
end sendEOP;

begin
  DUT: rmedt port map(
                CLK => CLK,
                DM1_RX => DM1_RX,
                DP1_RX => DP1_RX,
                dm_tx_out => DM1_TX,
                dp_tx_out => DP1_TX,
                RST => RST,
                SERIAL_IN => SERIAL_IN,
                CRC_ERROR => CRC_ERROR,
                EMPTY => EMPTY,
                FULL => FULL,
                KEY_ERROR => KEY_ERROR,
                PROG_ERROR => PROG_ERROR,
                PARITY_ERROR => PARITY_ERROR,
                RBUF_FULL => RBUF_FULL,
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
  variable bc: integer;
  begin
  bc := 0;
-- Insert TEST BENCH Code Here
  RST <= '1';
  DP1_RX <= '1';
  DM1_RX <= '0';
  SERIAL_IN <= '1';
  wait for 12 ns;
  RST <= '0';
  wait for 12 ns;
  
  sendUART(x"21", serial_in); -- !
  sendUART(x"21", serial_in); -- !
  sendUART(x"54", serial_in); -- T
  sendUART(x"45", serial_in); -- E
  sendUART(x"52", serial_in); -- R
  sendUART(x"43", serial_in); -- C
  sendUART(x"45", serial_in); -- E
  sendUART(x"53", serial_in); -- S
  sendUART(x"36", serial_in); -- wrong parity
  
  sendUART(x"21", serial_in); -- !
  sendUART(x"21", serial_in); -- !
  sendUART(x"54", serial_in); -- T
  sendUART(x"45", serial_in); -- E
  sendUART(x"52", serial_in); -- R
  sendUART(x"43", serial_in); -- C
  sendUART(x"45", serial_in); -- E
  sendUART(x"53", serial_in); -- S
  sendUART("11110111", serial_in); -- parity
  
  wait for 12 us;
  
  report "Begin normal operation" severity note;
  
  --for i in 0 to 15 loop
--    report "Sending..." severity note;
--    HEXtoNRZI("10000000", BC, DP1_RX, DM1_RX);
--    HEXtoNRZI(x"11", BC, DP1_RX, DM1_RX);
--    for j in 0 to 15 loop
--      HEXtoNRZI(CONV_STD_LOGIC_VECTOR(i * 16 + j, 8), BC, DP1_RX, DM1_RX);
--    end loop;
--    HEXtoNRZI(x"ED", BC, DP1_RX, DM1_RX);
--    HEXtoNRZI(x"BD", BC, DP1_RX, DM1_RX);
--    sendEOP(0, DP1_RX, DM1_RX);
--  end loop;
  HEXtoNRZI("10000000", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"90", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"61", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"62", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"63", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"64", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"3D", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"EF", BC, DP1_RX, DM1_RX);
  sendEOP(0, DP1_RX, DM1_RX);
  wait for 8 us;
  
  sendUART(x"21", serial_in); -- !
  sendUART(x"21", serial_in); -- !
  sendUART(x"54", serial_in); -- T
  sendUART(x"45", serial_in); -- E
  sendUART(x"52", serial_in); -- R
  sendUART(x"43", serial_in); -- C
  sendUART(x"45", serial_in); -- E
  sendUART(x"53", serial_in); -- S
  sendUART("11110111", serial_in); -- parity

  wait for 12 us;
  BC := 0;
  report "Starting new data" severity note;
  HEXtoNRZI("10000000", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"11", BC, DP1_RX, DM1_RX);
  
  HEXtoNRZI(x"9E", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"13", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"CF", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"A6", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"45", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"77", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"8b", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"a4", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"d9", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"02", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"40", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"a4", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"a8", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"56", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"62", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"5d", BC, DP1_RX, DM1_RX);
  
  HEXtoNRZI(x"e6", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"27", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"c6", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"c6", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"b3", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"9d", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"b2", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"86", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"84", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"b0", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"fd", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"d0", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"c7", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"d7", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"11", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"da", BC, DP1_RX, DM1_RX);
  
  HEXtoNRZI(x"2a", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"55", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"c2", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"b7", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"28", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"c1", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"c8", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"dc", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"83", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"e6", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"57", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"92", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"2b", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"46", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"c5", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"3e", BC, DP1_RX, DM1_RX);
  
  HEXtoNRZI(x"32", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"a6", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"ba", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"ab", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"00", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"c7", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"2c", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"2e", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"7d", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"79", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"eb", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"94", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"05", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"cc", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"fa", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"31", BC, DP1_RX, DM1_RX);
  
  HEXtoNRZI(x"79", BC, DP1_RX, DM1_RX);
  HEXtoNRZI(x"6C", BC, DP1_RX, DM1_RX);
  sendEOP(0, DP1_RX, DM1_RX);

  wait;
  
    --CLK <= 
    --DM1_RX <= 
    --DP1_RX <= 
    --RST <= 
    --SERIAL_IN <= 

  end process;
end TEST;