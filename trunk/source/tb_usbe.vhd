-- $Id: $
-- File name:   tb_usbe.vhd
-- Created:     12/5/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_usbe is
  generic (Period : Time :=  10.4167 ns);
end tb_usbe;

architecture TEST of tb_usbe is

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

  component usbe
    PORT(
         CLK : IN std_logic;
         RST : IN std_logic;
         SERIAL_IN : IN std_logic;
         CRC_ERROR_HOST : OUT std_logic;
         CRC_ERROR_SLAVE : OUT std_logic;
         EMPTY_HOST : OUT STD_LOGIC;
         EMPTY_SLAVE : OUT STD_LOGIC;
         FULL_HOST : OUT STD_LOGIC;
         FULL_SLAVE : OUT STD_LOGIC;
         KEY_ERROR : OUT std_logic;
         PARITY_ERROR : OUT std_logic;
         PROG_ERROR : OUT std_logic;
         R_ERROR_HOST : OUT std_logic;
         R_ERROR_SLAVE : OUT std_logic;
         D_MINUS_HOSTSIDE : INOUT std_logic;
         D_MINUS_SLAVESIDE : INOUT std_logic;
         D_PLUS_HOSTSIDE : INOUT std_logic;
         D_PLUS_SLAVESIDE : INOUT std_logic
    );
  end component;

-- Insert signals Declarations here
  signal CLK : std_logic;
  signal RST : std_logic;
  signal SERIAL_IN : std_logic;
  signal CRC_ERROR_HOST : std_logic;
  signal CRC_ERROR_SLAVE : std_logic;
  signal EMPTY_HOST : STD_LOGIC;
  signal EMPTY_SLAVE : STD_LOGIC;
  signal FULL_HOST : STD_LOGIC;
  signal FULL_SLAVE : STD_LOGIC;
  signal KEY_ERROR : std_logic;
  signal PARITY_ERROR : std_logic;
  signal PROG_ERROR : std_logic;
  signal R_ERROR_HOST : std_logic;
  signal R_ERROR_SLAVE : std_logic;
  signal D_MINUS_HOSTSIDE : std_logic;
  signal D_MINUS_SLAVESIDE : std_logic;
  signal D_PLUS_HOSTSIDE : std_logic;
  signal D_PLUS_SLAVESIDE : std_logic;

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
  signal D_MIN: inout std_logic) is
  variable count: integer;
  variable D_Last: std_logic;
  begin
    count := bc_count;
    for i in 0 to 7 loop
      if (data(i) = '0') then
        count := 0;
        D <= not(D);
        D_MIN <= D;
      else
        if (count = 5) then
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
          count := count + 1;
          D <= D;
          D_MIN <= not(D);
        end if;
      end if;
      wait for 8*Period;
      bc_count := count;
    end loop;
  end HEXtoNRZI;

procedure STRINGtoNRZI (
  constant word: IN string;
  constant length: IN integer;
  variable bc_count: inout integer;
  signal D: inout std_logic;
  signal D_MIN: out std_logic) is
  variable count: integer;
  variable D_Last: std_logic;
  variable data: std_logic_vector(7 downto 0);
  begin
    count := bc_count;
    for i in 1 to length loop
      data := CONV_STD_LOGIC_VECTOR(CONV_INTEGER(CHARACTER'POS(word(i))), 8);
      for i in 0 to 7 loop
        if (data(i) = '0') then
          count := 0;
          D <= not(D);
          D_MIN <= D;
        else
          if (count = 5) then
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
            count := count + 1;
            D <= D;
            D_MIN <= not(D);
          end if;
        end if;
        wait for 8*Period;
      end loop;
    end loop;
    bc_count := count;
  end STRINGtoNRZI;

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
  DUT: usbe port map(
                CLK => CLK,
                RST => RST,
                SERIAL_IN => SERIAL_IN,
                CRC_ERROR_HOST => CRC_ERROR_HOST,
                CRC_ERROR_SLAVE => CRC_ERROR_SLAVE,
                EMPTY_HOST => EMPTY_HOST,
                EMPTY_SLAVE => EMPTY_SLAVE,
                FULL_HOST => FULL_HOST,
                FULL_SLAVE => FULL_SLAVE,
                KEY_ERROR => KEY_ERROR,
                PARITY_ERROR => PARITY_ERROR,
                PROG_ERROR => PROG_ERROR,
                R_ERROR_HOST => R_ERROR_HOST,
                R_ERROR_SLAVE => R_ERROR_SLAVE,
                D_MINUS_HOSTSIDE => D_MINUS_HOSTSIDE,
                D_MINUS_SLAVESIDE => D_MINUS_SLAVESIDE,
                D_PLUS_HOSTSIDE => D_PLUS_HOSTSIDE,
                D_PLUS_SLAVESIDE => D_PLUS_SLAVESIDE
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
  SERIAL_IN <= '1';
  RST <= '1';
  D_MINUS_HOSTSIDE <= '0';
  D_MINUS_SLAVESIDE <= '0';
  D_PLUS_HOSTSIDE <= '1';
  D_PLUS_SLAVESIDE <= '1';
  wait for 55 ns;
  RST <= '0';
  wait for 5 ns;
  
-- Insert TEST BENCH Code Here
  sendUART(x"21", serial_in); -- !
  sendUART(x"21", serial_in); -- !
  sendUART(x"54", serial_in); -- T
  sendUART(x"45", serial_in); -- E
  sendUART(x"52", serial_in); -- R
  sendUART(x"43", serial_in); -- C
  sendUART(x"45", serial_in); -- E
  sendUART(x"53", serial_in); -- S
  sendUART("11110111", serial_in); -- parity
  
  HEXtoNRZI("10000000", BC, D_PLUS_HOSTSIDE, D_MINUS_HOSTSIDE);
  HEXtoNRZI(x"11", BC, D_PLUS_HOSTSIDE, D_MINUS_HOSTSIDE);
  report "Sending..." severity note;
  STRINGtoNRZI("This is a long string", 21, BC, D_PLUS_HOSTSIDE, D_MINUS_HOSTSIDE);
  HEXtoNRZI(x"2C", BC, D_PLUS_HOSTSIDE, D_MINUS_HOSTSIDE);
  HEXtoNRZI(x"5E", BC, D_PLUS_HOSTSIDE, D_MINUS_HOSTSIDE);
  sendEOP(0, D_PLUS_HOSTSIDE, D_MINUS_HOSTSIDE);
--    CLK <= 
--    RST <= 
--    SERIAL_IN <= 
--    D_MINUS_HOSTSIDE <= 
--    D_MINUS_SLAVESIDE <= 
--    D_PLUS_HOSTSIDE <= 
--    D_PLUS_SLAVESIDE <= 
  wait;
  end process;
end TEST;