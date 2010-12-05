-- $Id: $
-- File name:   tb_rmedt_rmed.vhd
-- Created:     12/4/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_rmedt_rmed is
  generic (Period : Time :=  10.4167 ns);
end tb_rmedt_rmed;

architecture TEST of tb_rmedt_rmed is

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

  component rmedt_rmed
    PORT(
         CLK : IN std_logic;
         DM1_RX : IN std_logic;
         DP1_RX : IN std_logic;
         NEXT_BYTE : IN STD_LOGIC;
         RST : IN std_logic;
         SERIAL_IN : IN std_logic;
         EMPTY : OUT STD_LOGIC;
         EMPTY1 : OUT STD_LOGIC;
         FULL : OUT STD_LOGIC;
         FULL1 : OUT STD_LOGIC;
         PDATA_READY : OUT STD_LOGIC;
         PRGA_OPCODE : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
         PROCESSED_DATA : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
         dout : OUT std_logic;
         dout1 : OUT std_logic;
         dout2 : OUT std_logic;
         dout3 : OUT std_logic;
         dout4 : OUT std_logic
    );
  end component;

-- Insert signals Declarations here
  signal CLK : std_logic;
  signal DM1_RX : std_logic;
  signal DP1_RX : std_logic;
  signal NEXT_BYTE : STD_LOGIC;
  signal RST : std_logic;
  signal SERIAL_IN : std_logic;
  signal EMPTY : STD_LOGIC;
  signal EMPTY1 : STD_LOGIC;
  signal FULL : STD_LOGIC;
  signal FULL1 : STD_LOGIC;
  signal PDATA_READY : STD_LOGIC;
  signal PRGA_OPCODE : STD_LOGIC_VECTOR (1 DOWNTO 0);
  signal PROCESSED_DATA : STD_LOGIC_VECTOR (7 DOWNTO 0);
  signal dout : std_logic;
  signal dout1 : std_logic;
  signal dout2 : std_logic;
  signal dout3 : std_logic;
  signal dout4 : std_logic;

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

procedure cycleNB(
  signal NEXT_BYTE: INOUT STD_LOGIC;
  signal P_READY: IN STD_LOGIC) is
begin
  NEXT_BYTE <= '1';
  if P_READY = '0' then
    report "spin wait" severity note;
    wait until P_READY = '1';
    NEXT_BYTE <= '0';
  end if;
  wait for 25 ns;
end cycleNB;

begin
  DUT: rmedt_rmed port map(
                CLK => CLK,
                DM1_RX => DM1_RX,
                DP1_RX => DP1_RX,
                NEXT_BYTE => NEXT_BYTE,
                RST => RST,
                SERIAL_IN => SERIAL_IN,
                EMPTY => EMPTY,
                EMPTY1 => EMPTY1,
                FULL => FULL,
                FULL1 => FULL1,
                PDATA_READY => PDATA_READY,
                PRGA_OPCODE => PRGA_OPCODE,
                PROCESSED_DATA => PROCESSED_DATA,
                dout => dout,
                dout1 => dout1,
                dout2 => dout2,
                dout3 => dout3,
                dout4 => dout4
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

-- Insert TEST BENCH Code Here
    variable bc: integer;
    begin
    bc := 0;
-- Insert TEST BENCH Code Here
    RST <= '1';
    DP1_RX <= '1';
    DM1_RX <= '0';
    SERIAL_IN <= '1';
    NEXT_BYTE <= '1';
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
    sendUART("11110111", serial_in); -- parity
    
    wait for 12 us;
    
    report "Begin normal operation" severity note;
    
    HEXtoNRZI("10000000", BC, DP1_RX, DM1_RX);
    HEXtoNRZI(x"11", BC, DP1_RX, DM1_RX);
    report "Sending..." severity note;
    STRINGtoNRZI("This is a long string", 21, BC, DP1_RX, DM1_RX);
    sendEOP(0, DP1_RX, DM1_RX);
    for i in 0 to 32 loop
      cycleNB(NEXT_BYTE, PDATA_READY);
    end loop;
    wait for 12 us;
    HEXtoNRZI("10000000", BC, DP1_RX, DM1_RX);
    HEXtoNRZI(x"11", BC, DP1_RX, DM1_RX);
    STRINGtoNRZI("Another long string following the previous string", 49, BC, DP1_RX, DM1_RX);
    sendEOP(0, DP1_RX, DM1_RX);
    --HEXtoNRZI(x"30", BC, DP1_RX, DM1_RX);
--    HEXtoNRZI(x"31", BC, DP1_RX, DM1_RX);
--    HEXtoNRZI(x"32", BC, DP1_RX, DM1_RX);
--    HEXtoNRZI(x"33", BC, DP1_RX, DM1_RX);
--    HEXtoNRZI(x"34", BC, DP1_RX, DM1_RX);
--    HEXtoNRZI(x"35", BC, DP1_RX, DM1_RX);
--    HEXtoNRZI(x"36", BC, DP1_RX, DM1_RX);
--    HEXtoNRZI(x"37", BC, DP1_RX, DM1_RX);
    --HEXtoNRZI(x"9e", BC, DP1_RX, DM1_RX);
--    HEXtoNRZI(x"13", BC, DP1_RX, DM1_RX);
--    HEXtoNRZI(x"cf", BC, DP1_RX, DM1_RX);
--    HEXtoNRZI(x"a6", BC, DP1_RX, DM1_RX);
--    HEXtoNRZI(x"45", BC, DP1_RX, DM1_RX);
--    HEXtoNRZI(x"77", BC, DP1_RX, DM1_RX);
--    HEXtoNRZI(x"8b", BC, DP1_RX, DM1_RX);
--    HEXtoNRZI(x"a4", BC, DP1_RX, DM1_RX);
--    HEXtoNRZI(x"BE", BC, DP1_RX, DM1_RX);
--    HEXtoNRZI(x"BE", BC, DP1_RX, DM1_RX);
--    sendEOP(0, DP1_RX, DM1_RX);
    
    for i in 0 to 64 loop
      cycleNB(NEXT_BYTE, PDATA_READY);
    end loop;
    --CLK <= 
    --DM1_RX <= 
    --DP1_RX <= 
    --NEXT_BYTE <= 
    --RST <= 
    --SERIAL_IN <= 
    wait;
  end process;
end TEST;