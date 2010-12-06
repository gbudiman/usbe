-- $Id: $
-- File name:   tb_rmedt_square.vhd
-- Created:     12/6/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_rmedt_square is
  generic (Period : Time :=  10.4167 ns);
end tb_rmedt_square;

architecture TEST of tb_rmedt_square is

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

  component rmedt_square
    PORT(
         CLK : IN std_logic;
         DMRH : IN std_logic;
         DMRS : IN std_logic;
         DPRH : IN std_logic;
         DPRS : IN std_logic;
         RST : IN std_logic;
         SERIAL_IN : IN std_logic;
         BSE_H : OUT std_logic;
         BSE_S : OUT std_logic;
         CRCE_H : OUT std_logic;
         CRCE_S : OUT std_logic;
         DMTH : OUT std_logic;
         DMTS : OUT std_logic;
         DPTH : OUT std_logic;
         DPTS : OUT std_logic;
         EMPTY_H : OUT STD_LOGIC;
         EMPTY_S : OUT STD_LOGIC;
         FULL_H : OUT STD_LOGIC;
         FULL_S : OUT STD_LOGIC;
         RE_H : OUT std_logic;
         RE_S : OUT std_logic;
         c_key_error : OUT std_logic;
         c_parity_error : OUT std_logic;
         c_prog_error : OUT std_logic
    );
  end component;

-- Insert signals Declarations here
  signal CLK : std_logic;
  signal DMRH : std_logic;
  signal DMRS : std_logic;
  signal DPRH : std_logic;
  signal DPRS : std_logic;
  signal RST : std_logic;
  signal SERIAL_IN : std_logic;
  signal BSE_H : std_logic;
  signal BSE_S : std_logic;
  signal CRCE_H : std_logic;
  signal CRCE_S : std_logic;
  signal DMTH : std_logic;
  signal DMTS : std_logic;
  signal DPTH : std_logic;
  signal DPTS : std_logic;
  signal EMPTY_H : STD_LOGIC;
  signal EMPTY_S : STD_LOGIC;
  signal FULL_H : STD_LOGIC;
  signal FULL_S : STD_LOGIC;
  signal RE_H : std_logic;
  signal RE_S : std_logic;
  signal c_key_error : std_logic;
  signal c_parity_error : std_logic;
  signal c_prog_error : std_logic;

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
  DUT: rmedt_square port map(
                CLK => CLK,
                DMRH => DMRH,
                DMRS => DMRS,
                DPRH => DPRH,
                DPRS => DPRS,
                RST => RST,
                SERIAL_IN => SERIAL_IN,
                BSE_H => BSE_H,
                BSE_S => BSE_S,
                CRCE_H => CRCE_H,
                CRCE_S => CRCE_S,
                DMTH => DMTH,
                DMTS => DMTS,
                DPTH => DPTH,
                DPTS => DPTS,
                EMPTY_H => EMPTY_H,
                EMPTY_S => EMPTY_S,
                FULL_H => FULL_H,
                FULL_S => FULL_S,
                RE_H => RE_H,
                RE_S => RE_S,
                c_key_error => c_key_error,
                c_parity_error => c_parity_error,
                c_prog_error => c_prog_error
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
  DPRH <= '1';
  DMRH <= '0';
  DPRS <= '1';
  DMRS <= '0';
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
  sendUART("11110111", serial_in); -- correct parity
  
  wait for 12 us;
  
  report "Begin normal operation" severity note;
  
  HEXtoNRZI("10000000", BC, DPRH, DMRH);
  HEXtoNRZI(x"90", BC, DPRH, DMRH);
  STRINGtoNRZI("This is a long string", 21, BC, DPRH, DMRH);
  HEXtoNRZI(x"2C", BC, DPRH, DMRH);
  HEXtoNRZI(x"5E", BC, DPRH, DMRH);
  sendEOP(0, DPRH, DMRH); 
  BC := 0;
  
  HEXtoNRZI("10000000", BC, DPRS, DMRS);
  HEXtoNRZI(x"39", BC, DPRS, DMRS);
  STRINGtoNRZI("Let's see how long can you go with encryption", 45, BC, DPRS, DMRS);
  HEXtoNRZI(x"9B", BC, DPRS, DMRS);
  HEXtoNRZI(x"A2", BC, DPRS, DMRS);
  sendEOP(0, DPRS, DMRS);
  BC := 0;
  
  wait for 12 us;
  
  sendUART(x"22", serial_in); -- "
  sendUART(x"54", serial_in); -- T
  sendUART(x"45", serial_in); -- E
  sendUART(x"52", serial_in); -- R
  sendUART(x"43", serial_in); -- C
  sendUART(x"45", serial_in); -- E
  sendUART(x"53", serial_in); -- S
  sendUART(x"22", serial_in); -- "
  sendUART("11110101", serial_in); -- parity
  
  wait for 12 us;
  
  HEXtoNRZI("10000000", BC, DPRS, DMRS);
  HEXtoNRZI(x"90", BC, DPRS, DMRS);
  STRINGtoNRZI("This is a long string", 21, BC, DPRS, DMRS);
  HEXtoNRZI(x"2C", BC, DPRS, DMRS);
  HEXtoNRZI(x"5E", BC, DPRS, DMRS);
  sendEOP(0, DPRS, DMRS); 
  wait;
    --CLK <= 
--    DMRH <= 
--    DMRS <= 
--    DPRH <= 
--    DPRS <= 
--    RST <= 
--    SERIAL_IN <= 

  end process;
end TEST;