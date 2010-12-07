-- $Id: $
-- File name:   tb_rmedt_square.vhd
-- Created:     12/6/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

library IEEE;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library OSU_AMI05;
use OSU_AMI05.all;

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

  component rmedt_square
    PORT(
      CLK              : IN     std_logic;
      DMRH             : IN     std_logic;
      DMRS             : IN     std_logic;
      DPRH             : IN     std_logic;
      DPRS             : IN     std_logic;
      RST              : IN     std_logic;
      SERIAL_IN        : IN     std_logic;
      BSE_H            : OUT    std_logic;
      BSE_S            : OUT    std_logic;
      CRCE_H           : OUT    std_logic;
      CRCE_S           : OUT    std_logic;
      DMTH             : OUT    std_logic;
      DMTS             : OUT    std_logic;
      DPTH             : OUT    std_logic;
      DPTS             : OUT    std_logic;
      EMPTY_H          : OUT    STD_LOGIC;
      EMPTY_S          : OUT    STD_LOGIC;
      FULL_H           : OUT    STD_LOGIC;
      FULL_S           : OUT    STD_LOGIC;
      RE_H             : OUT    std_logic;
      RE_S             : OUT    std_logic;
      c_key_error      : OUT    std_logic;
      c_parity_error   : OUT    std_logic;
      c_prog_error     : OUT    std_logic;
      host_is_sending  : OUT    std_logic;
      slave_is_sending : OUT    std_logic
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
  signal DPHS : std_logic;
  signal DPSS : std_logic;
  signal DMHS : std_logic;
  signal DMSS : std_logic;
  signal DPTS_ex : std_logic;
  signal DMTS_ex : std_logic;
  signal DPTH_ex : std_logic;
  signal DMTH_ex : std_logic;
  signal host_is_sending : std_logic;
  signal slave_is_sending : std_logic;

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
                RST => RST,
                DMRH => DMRH,
                DMRS => DMRS,
                DPRH => DPRH,
                DPRS => DPRS,
                DMTH => DMTH,
                DMTS => DMTS,
                DPTH => DPTH,
                DPTS => DPTS,
                SERIAL_IN => SERIAL_IN,
                BSE_H => BSE_H,
                BSE_S => BSE_S,
                CRCE_H => CRCE_H,
                CRCE_S => CRCE_S,
                EMPTY_H => EMPTY_H,
                EMPTY_S => EMPTY_S,
                FULL_H => FULL_H,
                FULL_S => FULL_S,
                RE_H => RE_H,
                RE_S => RE_S,
                c_key_error => c_key_error,
                c_parity_error => c_parity_error,
                c_prog_error => c_prog_error,
                host_is_sending => host_is_sending,
                slave_is_sending => slave_is_sending
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
  DPHS <= '1';
  DMHS <= '0';
  DPSS <= 'H';
  DMSS <= 'L';
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
  
  HEXtoNRZI("10000000", BC, DPHS, DMHS);
  HEXtoNRZI(x"90", BC, DPHS, DMHS);
  STRINGtoNRZI("This is a long string", 21, BC, DPHS, DMHS);
  HEXtoNRZI(x"2C", BC, DPHS, DMHS);
  HEXtoNRZI(x"5E", BC, DPHS, DMHS);
  sendEOP(0, DPHS, DMHS); 
  BC := 0;
  
  HEXtoNRZI("10000000", BC, DPHS, DMHS);
  HEXtoNRZI(x"39", BC, DPHS, DMHS);
  STRINGtoNRZI("Let's see how long can you go with encryption", 45, BC, DPHS, DMHS);
  HEXtoNRZI(x"9B", BC, DPHS, DMHS);
  HEXtoNRZI(x"A2", BC, DPHS, DMHS);
  sendEOP(0, DPHS, DMHS);
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
  
  DPSS <= '1';
  DMSS <= '0';
  DPHS <= 'H';
  DMHS <= 'L';
  wait for 12 us;  
  
  HEXtoNRZI("10000000", BC, DPSS, DMSS);
  HEXtoNRZI(x"90", BC, DPSS, DMSS);
  STRINGtoNRZI("This is a long string", 21, BC, DPSS, DMSS);
  HEXtoNRZI(x"2C", BC, DPSS, DMSS);
  HEXtoNRZI(x"5E", BC, DPSS, DMSS);
  sendEOP(0, DPSS, DMSS); 
  wait;
    --CLK <= 
--    DMRH <= 
--    DMRS <= 
--    DPRH <= 
--    DPRS <= 
--    RST <= 
--    SERIAL_IN <= 

  end process;
  
  DPTH_ex <= 'Z' WHEN slave_is_sending = '0' ELSE DPTH;
  DMTH_ex <= 'Z' WHEN slave_is_sending = '0' ELSE DMTH;
  DPTS_ex <= 'Z' WHEN host_is_sending = '0' ELSE DPTS;
  DMTS_ex <= 'Z' WHEN host_is_sending = '0' ELSE DMTS;
  
  DPHS <= DPTH_ex WHEN slave_is_sending = '1' ELSE 'H';
  DMHS <= DMTH_ex WHEN slave_is_sending = '1' ELSE 'L';
  DPSS <= DPTS_ex WHEN host_is_sending = '1' ELSE 'H';
  DMSS <= DMTS_ex WHEN host_is_sending = '1' ELSE 'L';
  
  DPRH <= DPHS WHEN slave_is_sending = '0' ELSE 'H';
  DMRH <= DMHS WHEN slave_is_sending = '0' ELSE 'L';
  DPRS <= DPSS WHEN host_is_sending = '0' ELSE 'H';
  DMRS <= DMSS WHEN host_is_sending = '0' ELSE 'L';
  
end TEST;